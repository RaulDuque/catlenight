extends Node

## Grava o aviso na sacada e o vitral da capela. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"
const _TEXTO := "↑ Entrar na capela"

var _cena: Node3D
var _jogador: CharacterBody3D
var _camera: Camera3D
var _aviso: Label
var _topo := 2.35
var _fase := "coletar"
var _frames := 0
var _pulou := false
var _impulso := false
var _gravando := false


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/10_capela_da_lua.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
	var enquadramento := _cena.get_node("Vestibulo/Enquadramento") as Node3D
	_camera.global_transform = enquadramento.global_transform
	_camera.current = true
	_jogador.global_position = Vector3(24.15, 1.45, 0.0)
	_jogador.velocity = Vector3.ZERO


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _gravando or _jogador == null:
		return
	if _fase == "coletar":
		if bool(_jogador.get("salto_duplo_adquirido")) and _jogador.is_on_floor():
			var vestibulo := _cena.get_node("Vestibulo/Enquadramento") as Node3D
			_camera.global_transform = vestibulo.global_transform
			_jogador.global_position = Vector3(-3.0, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_pulou = false
			_impulso = false
			_frames = 0
			_fase = "pouso"
		elif _frames > 180:
			print("FALHA sem a relíquia")
			get_tree().quit(1)
		return
	if _fase == "pouso":
		_pousar()
		return
	if _fase == "capela":
		if _camera.global_position.x > 40.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.2:
			_gravar("10-capela-da-lua.png", "fim")
		elif _frames > 120:
			print("FALHA sem a capela. camera=%.2f" % _camera.global_position.x)
			get_tree().quit(1)


func _pousar() -> void:
	var x := _jogador.global_position.x
	var y := _jogador.global_position.y
	if not _pulou and _jogador.is_on_floor() and _frames > 4:
		_pressionar("pulo")
		_pulou = true
		_frames = 0
	if _pulou and _frames > 4 and not _jogador.is_on_floor():
		_soltar("pulo")
	if _pulou and not _impulso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
		_pressionar("pulo")
		_impulso = true
	if y > _topo + 0.02 and x > -4.15:
		_pressionar("esquerda")
	else:
		_soltar("esquerda")
	var no_alto := _jogador.is_on_floor() and absf(y - _topo) < 0.12 and x < -3.7 and x > -5.7
	if no_alto and _aviso.visible and _aviso.text == _TEXTO:
		_soltar("esquerda")
		_soltar("pulo")
		_gravar("10-entrada-na-sacada.png", "capela")
	elif _frames > 280:
		print("FALHA sem o aviso. x=%.3f y=%.3f texto=%s" % [x, y, _aviso.text])
		get_tree().quit(1)


func _gravar(arquivo: String, seguinte: String) -> void:
	_gravando = true
	_fase = seguinte
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_PASTA + arquivo)
	var vida := _cena.get_node("IndicadorDeVida/Vida") as Label
	print(
		"POSE arquivo=%s texto=%s vida=%s x=%.3f y=%.3f camera_x=%.2f quadro=%dx%d"
		% [
			arquivo,
			_aviso.text if _aviso.visible else "",
			vida.text,
			_jogador.global_position.x,
			_jogador.global_position.y,
			_camera.global_position.x,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	_gravando = false
	if seguinte == "capela":
		_pressionar("interagir")
		_frames = 0
		return
	_soltar("interagir")
	get_tree().quit(0)


func _pressionar(acao: String) -> void:
	if Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = true
	Input.parse_input_event(evento)


func _soltar(acao: String) -> void:
	if not Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = false
	Input.parse_input_event(evento)
