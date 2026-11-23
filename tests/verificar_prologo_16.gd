extends SceneTree

const PROLOGO := "res://scenes/prologo/prologo.tscn"
var cena: Node
var jogador: Jogador
var guardiao: AnimatableBody3D
var falhou := false

func _initialize() -> void:
	call_deferred("_percurso")

func _conferir(valido: bool, mensagem: String) -> void:
	if not valido:
		falhou = true
		push_error(mensagem)
		quit(1)

func _tecla(nome: String, ativa: bool) -> void:
	var evento := InputEventAction.new()
	evento.action = nome
	evento.pressed = ativa
	Input.parse_input_event(evento)
	Input.flush_buffered_events()

func _quadros(n: int) -> void:
	for i in n:
		await physics_frame

func _foto(nome: String) -> void:
	var pasta := OS.get_environment("CATLENIGHT_CAPTURAS")
	if not pasta.is_empty():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(pasta.path_join(nome+".png"))

func _iniciar() -> void:
	cena = current_scene
	jogador = cena.get_node("Jogador")
	guardiao = cena.get_node("Guardiao")
	await _quadros(8)
	_tecla("pulo",true)
	await _quadros(4)
	_tecla("pulo",false)
	await _quadros(24)
	_conferir(not paused and jogador.pontos_de_vida == 3,"início")
	_conferir(not guardiao.em_combate and guardiao.pontos_de_vida == 5,"vigília")

func _andar_ate(x: float) -> void:
	var sinal := signf(x - jogador.position.x)
	var tecla := "direita" if sinal > 0 else "esquerda"
	_tecla(tecla,true)
	for i in 1200:
		await _quadros(1)
		if sinal * (x - jogador.position.x) <= 0.01:
			break
	_tecla(tecla,false)
	await _quadros(3)
	_conferir(absf(jogador.position.x - x) < 0.16,"destino %.2f" % x)

func _passagem() -> void:
	_tecla("interagir",true)
	await _quadros(2)
	_tecla("interagir",false)
	await _quadros(6)

func _saltar(sentido: String) -> void:
	_tecla(sentido,true)
	_tecla("pulo",true)
	await _quadros(4)
	_tecla("pulo",false)
	await _quadros(69)
	_tecla(sentido,false)
	_conferir(jogador.position.y > 22 and jogador.is_on_floor(),"travessia do vão")

func _galeria() -> void:
	await _andar_ate(-19.69)
	await _passagem()
	_conferir(absf(jogador.position.y-15.385)<0.02,"entrada interna")
	await _andar_ate(-27.1)
	_conferir(absf(jogador.position.y-19.077)<0.02,"descanso")
	await _andar_ate(-43.7)
	await _foto("16-galeria")
	await _andar_ate(-31.65)
	await _saltar("direita")
	await _andar_ate(-17.8)
	await _andar_ate(-28.38)
	await _saltar("esquerda")
	await _andar_ate(-19.69)
	await _passagem()
	_conferir(absf(jogador.position.y-8)<0.02,"volta ao salão")

func _enfrentar() -> void:
	for i in 2300:
		if guardiao.derrotada:
			break
		var dx: float = guardiao.position.x - jogador.position.x
		var andar := absf(dx) > 0.88
		_tecla("esquerda",andar and dx < 0)
		_tecla("direita",andar and dx > 0)
		if absf(dx) <= 1.25 and (i % 31 == 0):
			_tecla("atacar",true)
		elif i % 31 == 3:
			_tecla("atacar",false)
		await _quadros(1)
	_tecla("atacar",false)
	_tecla("esquerda",false)
	_tecla("direita",false)
	_conferir(guardiao.derrotada and paused and cena.get_node("HUD/Fim").visible,"fim do confronto")

func _percurso() -> void:
	change_scene_to_file(PROLOGO)
	await scene_changed
	await _iniciar()
	_tecla("esquerda", true)
	await _quadros(140)
	await _foto("16-escadaria")
	_tecla("esquerda",false)
	await _galeria()
	_tecla("esquerda",true)
	for i in 1000:
		if jogador.retornos_por_derrota > 0:
			break
		await _quadros(1)
	_tecla("esquerda",false)
	await _quadros(4)
	print("TENTATIVA jogador=",jogador.position," vida=",jogador.pontos_de_vida," retornos=",jogador.retornos_por_derrota," guardiao=",guardiao.position," fase=",guardiao._fase)
	_conferir(jogador.retornos_por_derrota == 1 and absf(jogador.position.x+33)<0.3,"retorno ao salão")
	_conferir(not guardiao.em_combate and guardiao.pontos_de_vida == 5,"reinício do encontro")
	_tecla("esquerda", true)
	await _andar_ate(-38)
	_tecla("esquerda",false)
	await _foto("16-trono")
	await _enfrentar()
	await _foto("16-fim")
	cena.get_node("HUD/Fim/Repetir").grab_focus()
	_tecla("ui_accept",true)
	await _quadros(1)
	_tecla("ui_accept",false)
	await _quadros(6)
	_conferir(current_scene != cena and current_scene.scene_file_path == PROLOGO,"repetir")
	await _iniciar()
	await _enfrentar()
	_tecla("ui_accept",true)
	await _quadros(1)
	_tecla("ui_accept",false)
	await _quadros(10)
	_conferir(current_scene.scene_file_path.ends_with("depois_do_prologo.tscn") and not paused,"entrada no castelo")
	_conferir(current_scene.has_node("Vestibulo") and not current_scene.get_node("MenuDoPiloto").visible,"vestíbulo jogável")
	# O mixer usa tempo real mesmo no teste acelerado por --fixed-fps.
	var fim_do_audio := Time.get_ticks_msec() + 650
	while Time.get_ticks_msec() < fim_do_audio:
		await process_frame
	if not falhou:
		print("RESULTADO ok: derrota, retorno, duas vitórias, repetição e chegada ao vestíbulo")
		quit(0)
