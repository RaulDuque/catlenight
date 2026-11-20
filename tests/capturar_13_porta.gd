extends Node

## Grava o jogador diante da porta da sacada. Não faz parte do jogo.

const _TOPO := 2.35
const _ENTRAR := "↑ Entrar na capela"
const _SAIDA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/13-porta-na-sacada.png"

var _cena: Node
var _jogador: CharacterBody3D
var _camera: Camera3D
var _aviso: Label
var _menu: CanvasLayer
var _fase := "menu"
var _frames := 0
var _gravando := false
var _pulou := false
var _impulso := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/13_vestibulo_do_castelo.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
	_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer


func _physics_process(_delta: float) -> void:
	if _gravando or _jogador == null:
		return
	_frames += 1
	if _fase == "menu":
		if not _menu.visible and not get_tree().paused:
			_soltar("pulo")
			_frames = 0
			_fase = "galeria"
			return
		if _frames == 8:
			_pressionar("pulo")
		if _frames == 12:
			_soltar("pulo")
		return
	if _fase == "galeria":
		_andar_ate_galeria()
	elif _fase == "plataforma":
		_subir()
	elif _fase == "coletar":
		_coletar()
	elif _fase == "voltar":
		_voltar()
	elif _fase == "aproximar":
		_aproximar()
	elif _fase == "pousar":
		_pousar()


func _andar_ate_galeria() -> void:
	if not Input.is_action_pressed("direita"):
		_pressionar("direita")
	var x := _jogador.global_position.x
	if _camera.global_position.x > 20.0 and x > 18.0 and x < 22.5 and _jogador.is_on_floor():
		_soltar("direita")
		_frames = 0
		_fase = "plataforma"


func _subir() -> void:
	var x := _jogador.global_position.x
	var y := _jogador.global_position.y
	if not Input.is_action_pressed("direita"):
		_pressionar("direita")
	if _jogador.is_on_floor() and y < 0.3 and x > 22.0 and x < 22.7 and not Input.is_action_pressed("pulo"):
		_pressionar("pulo")
	if y > 0.45:
		_soltar("pulo")
	if _jogador.is_on_floor() and y > 0.9 and x > 23.2 and x < 27.0:
		_frames = 0
		_fase = "coletar"


func _coletar() -> void:
	var x := _jogador.global_position.x
	if x < 24.0:
		_pressionar("direita")
		_soltar("esquerda")
	elif x > 24.35:
		_pressionar("esquerda")
		_soltar("direita")
	else:
		_soltar("direita")
		_soltar("esquerda")
	if bool(_jogador.get("salto_duplo_adquirido")):
		_frames = 0
		_fase = "voltar"


func _voltar() -> void:
	var x := _jogador.global_position.x
	var y := _jogador.global_position.y
	_soltar("direita")
	if not Input.is_action_pressed("esquerda"):
		_pressionar("esquerda")
	if _jogador.is_on_floor() and y < 0.35 and x < 28.0 and x > 23.2 and not Input.is_action_pressed("pulo"):
		_pressionar("pulo")
	if y > 0.55:
		_soltar("pulo")
	if _camera.global_position.x < 5.0 and x < 6.0 and x > 1.0 and y < 0.4:
		_soltar("esquerda")
		_pulou = false
		_impulso = false
		_frames = 0
		_fase = "aproximar"


func _aproximar() -> void:
	var x := _jogador.global_position.x
	if x > -2.95:
		_pressionar("esquerda")
	else:
		_soltar("esquerda")
	if x <= -2.95 and x > -3.4 and _jogador.is_on_floor() and _jogador.global_position.y < 0.3:
		_pulou = false
		_impulso = false
		_frames = 0
		_fase = "pousar"


func _pousar() -> void:
	var x := _jogador.global_position.x
	var y := _jogador.global_position.y
	if not _pulou and _jogador.is_on_floor() and _frames > 4:
		_pressionar("pulo")
		_pulou = true
	if _pulou and _frames > 4 and not _jogador.is_on_floor():
		_soltar("pulo")
	if _pulou and not _impulso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
		_pressionar("pulo")
		_impulso = true
	if y > _TOPO + 0.02 and x > -4.15:
		_pressionar("esquerda")
	else:
		_soltar("esquerda")
	if _jogador.is_on_floor() and absf(y - _TOPO) < 0.02 and x < -3.7 and x > -5.7 and _aviso.visible and _aviso.text == _ENTRAR:
		_gravar()
	elif _frames > 500:
		print("FALHA porta x=%.3f y=%.3f aviso=%s" % [x, y, _aviso.text])
		get_tree().quit(1)


func _gravar() -> void:
	_gravando = true
	_soltar("esquerda")
	_soltar("pulo")
	print(
		"POSE porta x=%.3f y=%.3f z=%.3f aviso=%s camera_x=%.2f"
		% [_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _aviso.text, _camera.global_position.x]
	)
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_SAIDA)
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
