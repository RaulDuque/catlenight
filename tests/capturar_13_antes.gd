extends Node

## Grava o vestíbulo pela câmera do jogo. Não faz parte do jogo.

const _CENA := "res://scenes/verification/12_mapa_das_salas.tscn"

var _cena: Node
var _jogador: CharacterBody3D
var _camera: Camera3D
var _menu: CanvasLayer
var _fase := "menu"
var _frames := 0
var _gravando := false
var _saida := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/13-vestibulo-antes.png"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_saida = String(args[0])
	call_deferred("_montar")


func _montar() -> void:
	var caminho := _CENA
	var args := OS.get_cmdline_user_args()
	if args.size() > 1:
		caminho = String(args[1])
	_cena = (load(caminho) as PackedScene).instantiate()
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
		return
	var x := _jogador.global_position.x
	if x < -0.58:
		_pressionar("direita")
		_soltar("esquerda")
	elif x > -0.48:
		_pressionar("esquerda")
		_soltar("direita")
	else:
		_soltar("direita")
		_soltar("esquerda")
	var parado := _jogador.is_on_floor() and _jogador.global_position.y < 0.05 and absf(_jogador.velocity.x) < 0.04
	if parado and x >= -0.58 and x <= -0.48 and _frames > 8:
		_gravar()
	elif _frames > 400:
		print("FALHA pose x=%.3f y=%.3f" % [x, _jogador.global_position.y])
		get_tree().quit(1)


func _menu_novo() -> void:
	if not _menu.visible and not get_tree().paused:
		_soltar("pulo")
		_frames = 0
		_fase = "andar"
		return
	if _frames == 8:
		_pressionar("pulo")
	if _frames == 12:
		_soltar("pulo")
	if _frames > 90:
		print("FALHA menu")
		get_tree().quit(1)


func _gravar() -> void:
	_gravando = true
	var visual := _jogador.get_node("Visual") as Node3D
	print(
		"POSE x=%.4f y=%.4f z=%.4f rotacao_y=%.4f camera_x=%.2f camera_size=%.2f quadro_pedido=%s"
		% [
			_jogador.global_position.x,
			_jogador.global_position.y,
			_jogador.global_position.z,
			visual.rotation.y,
			_camera.global_position.x,
			_camera.size,
			_saida,
		]
	)
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_saida)
	print("QUADRO %dx%d" % [imagem.get_width(), imagem.get_height()])
	get_tree().quit(0)


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
