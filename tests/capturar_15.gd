extends Node

## Grava a primeira vista e a subida real da cena 15.
## Não faz parte do jogo.

var _modo := "nascimento"
var _saida := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/15-primeira-vista-do-castelo.png"
var _cena: Node
var _jogador: CharacterBody3D
var _camera: Camera3D
var _menu: CanvasLayer
var _fase := "menu"
var _frames := 0
var _gravando := false
var _parado := Vector3.ZERO
var _passos := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2:
		_modo = String(args[0])
		_saida = String(args[1])
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/15_escadaria_exterior.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer


func _physics_process(_delta: float) -> void:
	if _gravando or _jogador == null:
		return
	_frames += 1
	if _fase == "menu":
		_menu_novo()
	elif _modo == "nascimento":
		_esperar_patamar()
	elif _fase == "subir":
		_subir()
	else:
		_esperar_parada()


func _menu_novo() -> void:
	if not _menu.visible and not get_tree().paused:
		_soltar("pulo")
		_frames = 0
		_fase = "patamar" if _modo == "nascimento" else "subir"
		return
	if _frames == 8:
		_pressionar("pulo")
	if _frames == 12:
		_soltar("pulo")
	if _frames > 90:
		_falhar("menu")


func _esperar_patamar() -> void:
	var posicao := _jogador.global_position
	if _jogador.is_on_floor() and posicao.y < 0.15 and posicao.x < -22.0 and absf(_camera.global_position.x + 18.8) < 1.0:
		_passos += 1
	else:
		_passos = 0
	if _passos >= 8:
		_gravar()
	elif _frames > 120:
		_falhar("nascimento x=%.3f y=%.3f camera=%.2f" % [posicao.x, posicao.y, _camera.global_position.x])


func _subir() -> void:
	if not Input.is_action_pressed("direita"):
		_pressionar("direita")
	var posicao := _jogador.global_position
	if _jogador.is_on_floor() and posicao.x > -20.1 and posicao.x < -18.4 and posicao.y > 0.7:
		_soltar("direita")
		_frames = 0
		_fase = "parar"
	elif _frames > 360:
		_falhar("meio x=%.3f y=%.3f" % [posicao.x, posicao.y])


func _esperar_parada() -> void:
	_soltar("direita")
	_soltar("esquerda")
	if _frames == 8:
		_parado = _jogador.global_position
	if _frames > 8:
		var delta := _jogador.global_position - _parado
		if absf(delta.x) < 0.04 and absf(delta.y) < 0.04 and _jogador.is_on_floor():
			_passos += 1
		else:
			_passos = 0
			_parado = _jogador.global_position
	if _passos >= 12:
		_gravar()
	elif _frames > 90:
		_falhar("parada x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])


func _gravar() -> void:
	_gravando = true
	_soltar("direita")
	_soltar("esquerda")
	call_deferred("_quadro")


func _quadro() -> void:
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_saida)
	var visual := _jogador.get_node("Visual") as Node3D
	print(
		"POSE %s x=%.4f y=%.4f z=%.4f rotacao_y=%.4f camera_x=%.2f camera_y=%.2f camera_size=%.2f quadro=%dx%d"
		% [
			_modo,
			_jogador.global_position.x,
			_jogador.global_position.y,
			_jogador.global_position.z,
			visual.rotation.y,
			_camera.global_position.x,
			_camera.global_position.y,
			_camera.size,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
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
