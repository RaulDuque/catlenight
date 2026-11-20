extends Node

## Grava a prancha dos dois modos e a chegada ao trono.
## Não faz parte do jogo.

var _cena: Node
var _jogador: CharacterBody3D
var _menu: CanvasLayer
var _fase := "menu"
var _frames := 0
var _blocos: Image
var _gravando := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/15c_blockout_do_prologo.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer


func _physics_process(_delta: float) -> void:
	if _gravando or _jogador == null:
		return
	_frames += 1
	if _fase == "menu":
		_escolher_menu()
	elif _fase == "subir":
		_subir()
	elif _fase == "blocos":
		_guardar_blocos()
	elif _fase == "arte":
		_guardar_arte()
	elif _fase == "trono":
		_ir_ao_trono()
	elif _fase == "quadro":
		_guardar_trono()


func _escolher_menu() -> void:
	if not _menu.visible and not get_tree().paused:
		_soltar("pulo")
		_frames = 0
		_fase = "subir"
		return
	if _frames == 8:
		_pressionar("pulo")
	if _frames == 12:
		_soltar("pulo")
	if _frames > 90:
		_falhar("menu")


func _subir() -> void:
	if not Input.is_action_pressed("esquerda"):
		_pressionar("esquerda")
	var posicao := _jogador.global_position
	if _jogador.is_on_floor() and posicao.x < -24.2 and posicao.x > -25.6 and posicao.y > 0.8:
		_soltar("esquerda")
		_frames = 0
		_fase = "blocos"
	elif _frames > 400:
		_falhar("meio")


func _guardar_blocos() -> void:
	_soltar("esquerda")
	if _frames < 12:
		return
	_gravando = true
	call_deferred("_ler_blocos")


func _ler_blocos() -> void:
	await RenderingServer.frame_post_draw
	_blocos = get_viewport().get_texture().get_image()
	_pressionar("alternar_apresentacao")
	_gravando = false
	_frames = 0
	_fase = "arte"


func _guardar_arte() -> void:
	_soltar("alternar_apresentacao")
	if _frames < 8:
		return
	_gravando = true
	call_deferred("_ler_arte")


func _ler_arte() -> void:
	await RenderingServer.frame_post_draw
	var arte := get_viewport().get_texture().get_image()
	_blocos.convert(Image.FORMAT_RGBA8)
	arte.convert(Image.FORMAT_RGBA8)
	var prancha := Image.create(1280, 1440, false, Image.FORMAT_RGBA8)
	prancha.blit_rect(_blocos, Rect2i(0, 0, 1280, 720), Vector2i(0, 0))
	prancha.blit_rect(arte, Rect2i(0, 0, 1280, 720), Vector2i(0, 720))
	prancha.save_png("D:/Progr/catlenight/MD-usario/relatorios/evidencias/15c-blocos-e-arte.png")
	print("PRANCHA %dx%d pes=%.3f,%.3f" % [prancha.get_width(), prancha.get_height(), _jogador.global_position.x, _jogador.global_position.y])
	_gravando = false
	_frames = 0
	_fase = "trono"


func _ir_ao_trono() -> void:
	if not Input.is_action_pressed("esquerda"):
		_pressionar("esquerda")
	var estrado := _cena.get_node("EscadariaExterior/SalaDoPrologo/ArteManual/Estrado") as Node3D
	var posicao := _jogador.global_position
	if _jogador.is_on_floor() and absf(posicao.x - estrado.global_position.x) < 0.55 and posicao.y > estrado.global_position.y - 0.15:
		_soltar("esquerda")
		_frames = 0
		_fase = "quadro"
	elif _frames > 900:
		_falhar("trono x=%.3f y=%.3f" % [posicao.x, posicao.y])


func _guardar_trono() -> void:
	if _frames < 10:
		return
	_gravando = true
	call_deferred("_ler_trono")


func _ler_trono() -> void:
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	var caminho := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/15c-chegada-ao-trono.png"
	imagem.save_png(caminho)
	var camera := _cena.get_node("CameraLateral") as Camera3D
	print("TRONO %dx%d x=%.3f y=%.3f z=%.3f camera_x=%.2f near=%.2f far=%.2f" % [
		imagem.get_width(), imagem.get_height(),
		_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
		camera.global_position.x, camera.near, camera.far,
	])
	get_tree().quit(0)


func _falhar(mensagem: String) -> void:
	print("FALHA " + mensagem)
	get_tree().quit(1)


func _pressionar(acao: String) -> void:
	if Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = true
	Input.parse_input_event(evento)
	Input.flush_buffered_events()


func _soltar(acao: String) -> void:
	if not Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = false
	Input.parse_input_event(evento)
	Input.flush_buffered_events()
