extends Node

## Grava a patrulha e o salto na câmera da galeria. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"

var _cena: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _sentinela: AnimatableBody3D
var _camera: Camera3D
var _fase := "esperar"
var _frames := 0
var _gravando := false


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/07_primeiro_inimigo.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria") as AnimatableBody3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	var enquadramento := _cena.get_node("Galeria/Enquadramento") as Node3D
	_camera.global_transform = enquadramento.global_transform
	_camera.current = true
	_jogador.global_position = Vector3(21.2, 0.2, 0.0)
	_jogador.velocity = Vector3.ZERO
	_visual.rotation.y = 0.0


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _gravando or _jogador == null:
		return
	if _fase == "esperar":
		if _frames > 12 and _jogador.is_on_floor():
			_fase = "patrulha"
		return
	if _fase == "patrulha":
		var sentido: float = _sentinela.get("sentido")
		var sx := _sentinela.global_position.x
		if sentido > 0.0 and sx > 29.3 and sx < 29.9:
			_gravar("07-patrulha-na-galeria.png", "salto_colocar")
		elif _frames > 400:
			print("FALHA sem quadro de patrulha")
			get_tree().quit(1)
		return
	if _fase == "salto_colocar":
		_jogador.global_position = Vector3(27.8, 0.2, 0.0)
		_jogador.velocity = Vector3.ZERO
		_visual.rotation.y = 0.0
		_frames = 0
		_fase = "salto_esperar"
		return
	if _fase == "salto_esperar":
		var sentido_volta: float = _sentinela.get("sentido")
		if _frames > 10 and _jogador.is_on_floor() and sentido_volta < 0.0 and _sentinela.global_position.x > 29.9:
			var direita := InputEventAction.new()
			direita.action = "direita"
			direita.pressed = true
			Input.parse_input_event(direita)
			var pulo := InputEventAction.new()
			pulo.action = "pulo"
			pulo.pressed = true
			Input.parse_input_event(pulo)
			_frames = 0
			_fase = "saltando"
		elif _frames > 400:
			print("FALHA a sentinela não voltou para a captura")
			get_tree().quit(1)
		return
	if _fase != "saltando":
		return
	var sx_salto := _sentinela.global_position.x
	var acima := absf(_jogador.global_position.x - sx_salto) < 0.65 and _jogador.global_position.y > 1.22
	if acima:
		_gravar("07-salto-sobre-sentinela.png", "fim")
		return
	if _frames > 180:
		print("FALHA sem quadro do salto. x=%.3f y=%.3f sent=%.3f" % [
			_jogador.global_position.x, _jogador.global_position.y, sx_salto,
		])
		get_tree().quit(1)


func _gravar(arquivo: String, seguinte: String) -> void:
	_gravando = true
	_fase = seguinte
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_PASTA + arquivo)
	print(
		"POSE arquivo=%s x=%.3f y=%.3f sent=%.3f sentido=%.0f camera_x=%.2f quadro=%dx%d"
		% [
			arquivo,
			_jogador.global_position.x,
			_jogador.global_position.y,
			_sentinela.global_position.x,
			float(_sentinela.get("sentido")),
			_camera.global_position.x,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	_gravando = false
	if seguinte == "fim":
		get_tree().quit(0)
