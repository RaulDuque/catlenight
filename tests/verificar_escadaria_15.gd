extends SceneTree

## Percurso da cena 15. percurso sobe e volta. continuar restaura o altar.
## Não faz parte do jogo.


func _initialize() -> void:
	var fase := "percurso"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		fase = String(args[0])
	if fase == "continuar":
		var arquivo := FileAccess.open("user://catlenight_piloto_11.json", FileAccess.WRITE)
		arquivo.store_string(JSON.stringify({
			"versao": 1,
			"sala": "capela_da_lua",
			"marcador": "AoLadoDoAltar",
			"vida": 3,
			"vida_maxima": 3,
			"salto_duplo": true,
			"sentinela_vida": 3,
			"sentinela_derrotada": false,
			"salas_visitadas": ["vestibulo", "galeria", "capela_da_lua"],
			"sala_atual": "capela_da_lua",
		}, "\t"))
		arquivo.close()
	var driver := Driver.new()
	driver.fase_inicial = fase
	root.add_child(driver)


class Driver extends Node:
	const _CENA := "res://scenes/verification/15_escadaria_exterior.tscn"
	var fase_inicial := "percurso"
	var _cena: Node
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _menu: CanvasLayer
	var _vida: Label
	var _fase := "menu"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _trocas := 0
	var _sala := ""
	var _parado := Vector3.ZERO
	var _passos_parado := 0
	var _na_porta := 0
	var _mapa_visto := false
	var _pes_iniciais := false
	var _topo_visto := false

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		_cena = (load(_CENA) as PackedScene).instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer
		_vida = _cena.get_node("IndicadorDeVida/Vida") as Label
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if principal != "res://scenes/verification/main.tscn":
			_falhar("o F5 mudou: %s" % principal)
			return
		if absf(_camera.size - 8.0) > 0.001:
			_falhar("a câmera não está com Size 8")
			return
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		_contar_troca()
		match _fase:
			"menu":
				_escolher_menu()
			"mapa_antes":
				_consultar("antes")
			"subir":
				_subir()
			"parar":
				_parar()
			"portao":
				_portao()
			"mapa_depois":
				_consultar("depois")
			"voltar":
				_voltar()
			"descer":
				_descer()
			"altar":
				_altar()
			"sair_capela":
				_sair_capela()
			"descer_sacada":
				_descer_sacada()
			"buscar_exterior":
				_buscar_exterior()
			"mapa_visita":
				_consultar("visita")

	func _contar_troca() -> void:
		var sala := _cena.get("sala_atual") as Node3D
		if sala == null:
			return
		if _sala == "":
			_sala = sala.name
			return
		if sala.name != _sala:
			_trocas += 1
			_sala = sala.name

	func _escolher_menu() -> void:
		var continuar := fase_inicial == "continuar"
		if not _menu.visible and not get_tree().paused:
			_soltar("pulo")
			_soltar("direita")
			_frames = 0
			_fase = "altar" if continuar else "mapa_antes"
			return
		if continuar and _frames == 6:
			_pressionar("direita")
		if continuar and _frames == 8:
			_soltar("direita")
		if (not continuar and _frames == 8) or (continuar and _frames == 14):
			_pressionar("pulo")
		if (not continuar and _frames == 12) or (continuar and _frames == 18):
			_soltar("pulo")
		if _frames > 90:
			_falhar("o menu não fechou")

	func _consultar(momento: String) -> void:
		var mapa := get_tree().get_first_node_in_group("mapa_das_salas")
		var aberto := bool(mapa.get("aberto"))
		if not _mapa_visto:
			if not aberto:
				if _frames == 4:
					_pressionar("abrir_mapa")
				if _frames == 8:
					_soltar("abrir_mapa")
				if _frames > 40:
					_falhar("o mapa não abriu em %s" % momento)
				return
			_soltar("abrir_mapa")
			if Input.is_action_pressed("abrir_mapa"):
				return
			var atual := String(mapa.get("sala_atual_id"))
			var vistas := _lista(mapa.get("visitadas"))
			var ligacoes := _lista(mapa.call("ligacoes"))
			print("MEDICAO mapa momento=%s atual=%s visitadas=%s ligacoes=%s sala=%s" % [
				momento, atual, ",".join(vistas), ",".join(ligacoes), _sala,
			])
			if momento == "antes":
				if atual != "escadaria_exterior" or ",".join(vistas) != "escadaria_exterior" or _vida.text != "Vida 3/3":
					_falhar("o jogo novo não começou só na escadaria. vida=%s" % _vida.text)
					return
			elif momento == "depois":
				if atual != "vestibulo" or not vistas.has("escadaria_exterior") or not vistas.has("vestibulo"):
					_falhar("entrar no castelo não revelou o vestíbulo")
					return
				if not ligacoes.has("escadaria_exterior-vestibulo"):
					_falhar("a ligação da escadaria não apareceu")
					return
			elif momento == "visita":
				if not vistas.has("escadaria_exterior") or not vistas.has("vestibulo") or not vistas.has("galeria") or not vistas.has("capela_da_lua"):
					_falhar("a visita ao exterior apagou salas antigas")
					return
				if atual != "escadaria_exterior":
					_falhar("o marcador não foi para a escadaria")
					return
			_mapa_visto = true
			_frames = 0
			return
		if aberto:
			if _frames == 4:
				_pressionar("abrir_mapa")
			if _frames == 8:
				_soltar("abrir_mapa")
			if _frames > 40:
				_falhar("o mapa não fechou em %s" % momento)
			return
		_soltar("abrir_mapa")
		if momento == "antes":
			_trocas = 0
			_ir("subir")
		elif momento == "depois":
			_trocas = 0
			_ir("voltar")
		else:
			_ok()

	func _subir() -> void:
		if not _pes_iniciais:
			if _jogador.is_on_floor() and _jogador.global_position.y < 0.2:
				_pes_iniciais = true
				print("MEDICAO inicio x=%.3f y=%.3f z=%.3f" % [
					_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
				])
			elif _frames > 180:
				_falhar("não assentou no patamar. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			return
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var x := _jogador.global_position.x
		if _jogador.is_on_floor() and x < -24.2 and x > -25.6 and _jogador.global_position.y > 0.8:
			_ir("parar")
		elif _frames > 360:
			_falhar("não chegou ao meio da escada. x=%.3f y=%.3f" % [x, _jogador.global_position.y])

	func _parar() -> void:
		_soltar("direita")
		_soltar("esquerda")
		if _frames == 6:
			_parado = _jogador.global_position
		if _frames > 6:
			var delta := _jogador.global_position - _parado
			if absf(delta.x) < 0.05 and absf(delta.y) < 0.05 and _jogador.is_on_floor():
				_passos_parado += 1
			else:
				_passos_parado = 0
		if _passos_parado >= 20:
			print("MEDICAO parada x=%.3f y=%.3f z=%.3f" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
			])
			_ir("portao")
		elif _frames > 80:
			_falhar("não ficou parado no meio. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _portao() -> void:
		if not _topo_visto and _sala == "EscadariaExterior" and _jogador.is_on_floor() and _jogador.global_position.x < -27.45 and _jogador.global_position.y > 2.55:
			_topo_visto = true
			print("MEDICAO fim x=%.3f y=%.3f z=%.3f" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
			])
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _sala == "Vestibulo" and absf(_camera.global_position.x) < 1.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.2:
			if _trocas != 1:
				_falhar("a entrada trocou de sala %d vezes" % _trocas)
				return
			if absf(_jogador.global_position.z) > 0.001:
				_falhar("o corpo saiu de Z = 0")
				return
			print("MEDICAO entrou x=%.3f y=%.3f z=%.3f camera=%.2f trocas=%d" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
				_camera.global_position.x, _trocas,
			])
			_ir("mapa_depois")
		elif _frames > 400:
			_falhar("não entrou no vestíbulo. x=%.3f sala=%s" % [_jogador.global_position.x, _sala])

	func _voltar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _sala == "EscadariaExterior" and _camera.global_position.x < -10.0 and _jogador.is_on_floor() and _jogador.global_position.y > 2.0:
			if _trocas != 1:
				_falhar("a volta trocou de sala %d vezes" % _trocas)
				return
			if absf(_jogador.global_position.z) > 0.001:
				_falhar("a volta saiu de Z = 0")
				return
			print("MEDICAO voltou x=%.3f y=%.3f camera=%.2f" % [
				_jogador.global_position.x, _jogador.global_position.y, _camera.global_position.x,
			])
			_ir("descer")
		elif _frames > 300:
			_falhar("não voltou ao exterior. x=%.3f sala=%s" % [_jogador.global_position.x, _sala])

	func _descer() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		var y := _jogador.global_position.y
		if _jogador.is_on_floor() and y < 0.4 and _jogador.global_position.x > -21.6:
			print("MEDICAO desceu x=%.3f y=%.3f z=%.3f" % [_jogador.global_position.x, y, _jogador.global_position.z])
			_ok()
		elif _frames > 300:
			_falhar("não desceu a escada. x=%.3f y=%.3f" % [_jogador.global_position.x, y])

	func _altar() -> void:
		if _frames < 8:
			return
		if _camera.global_position.x < 40.0 or not _jogador.is_on_floor():
			if _frames > 40:
				_falhar("continuar não abriu na capela")
			return
		var mapa := get_tree().get_first_node_in_group("mapa_das_salas")
		var vistas := _lista(mapa.get("visitadas"))
		print("MEDICAO altar x=%.3f y=%.3f vida=%s salto=%s visitadas=%s" % [
			_jogador.global_position.x, _jogador.global_position.y, _vida.text,
			bool(_jogador.get("salto_duplo_adquirido")), ",".join(vistas),
		])
		if absf(_jogador.global_position.x - 47.95) > 0.08 or absf(_jogador.global_position.y) > 0.08:
			_falhar("os pés não voltaram ao altar")
			return
		if _vida.text != "Vida 3/3" or not bool(_jogador.get("salto_duplo_adquirido")):
			_falhar("a restauração não trouxe vida e relíquia")
			return
		if vistas.has("escadaria_exterior") or ",".join(vistas) != "vestibulo,galeria,capela_da_lua":
			_falhar("a gravação antiga não conservou as três salas")
			return
		_ir("sair_capela")

	func _sair_capela() -> void:
		var x := _jogador.global_position.x
		if x > 46.4:
			_pressionar("esquerda")
			_soltar("interagir")
			_na_porta = 0
		else:
			_soltar("esquerda")
			_na_porta += 1
			if _na_porta == 6:
				_pressionar("interagir")
			if _na_porta == 10:
				_soltar("interagir")
		if _camera.global_position.x < 10.0 and _jogador.is_on_floor() and _jogador.global_position.y > 2.0:
			_ir("descer_sacada")
		elif _frames > 280:
			_falhar("não saiu da capela. x=%.3f" % x)

	func _descer_sacada() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.3 and _jogador.global_position.x > -3.5:
			_ir("buscar_exterior")
		elif _frames > 240:
			_falhar("não desceu da sacada. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _buscar_exterior() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _sala == "EscadariaExterior" and _camera.global_position.x < -10.0 and _jogador.is_on_floor():
			print("MEDICAO visitou x=%.3f camera=%.2f" % [_jogador.global_position.x, _camera.global_position.x])
			_ir("mapa_visita")
		elif _frames > 360:
			_falhar("a gravação antiga não revelou o exterior. x=%.3f sala=%s" % [_jogador.global_position.x, _sala])

	func _lista(valor: Variant) -> PackedStringArray:
		var saida: PackedStringArray = []
		if typeof(valor) != TYPE_ARRAY:
			return saida
		for item in valor:
			saida.append(String(item))
		return saida

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("interagir")
		_soltar("abrir_mapa")
		_frames = 0
		_passos_parado = 0
		_mapa_visto = false
		_fase = proxima

	func _ok() -> void:
		print("RESULTADO ok")
		_encerrado = true
		get_tree().quit(0)

	func _falhar(mensagem: String) -> void:
		if _encerrado:
			return
		_encerrado = true
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
