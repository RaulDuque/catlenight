extends Node

## Grava um acerto na câmera da galeria. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"

var _cena: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _lamina: MeshInstance3D
var _boneco: Node3D
var _camera: Camera3D
var _fase := "esperar"
var _frames := 0
var _quadros_ate_gravar := -1


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/06_primeiro_golpe.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_lamina = _jogador.get_node("Golpe/Lamina") as MeshInstance3D
	_boneco = _cena.get_node("Galeria/BonecoDeTreino") as Node3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	var enquadramento := _cena.get_node("Galeria/Enquadramento") as Node3D
	_camera.global_transform = enquadramento.global_transform
	_camera.current = true
	_jogador.global_position = Vector3(28.8, 0.2, 0.0)
	_jogador.velocity = Vector3.ZERO
	_visual.rotation.y = 0.0


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _fase == "esperar":
		if _frames > 12 and _jogador.is_on_floor():
			_visual.rotation.y = 0.0
			var evento := InputEventAction.new()
			evento.action = "atacar"
			evento.pressed = true
			Input.parse_input_event(evento)
			_fase = "golpear"
		return
	if _fase != "golpear":
		return
	var acertos: int = _boneco.get("acertos")
	if _lamina.visible and acertos >= 1 and _frames > 8:
		_quadros_ate_gravar = 2
		_fase = "visto"
		return
	if _frames > 180:
		print("FALHA captura sem acerto visível. acertos=%s lamina=%s" % [_boneco.get("acertos"), _lamina.visible])
		get_tree().quit(1)


func _gravar_depois_do_desenho() -> void:
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_PASTA + "06-acerto-na-galeria.png")
	var acertos_gravados: int = _boneco.get("acertos")
	print(
		"POSE arquivo=06-acerto-na-galeria.png x=%.4f y=%.4f z=%.4f acertos=%d deste=%d camera_x=%.2f camera_size=%.2f quadro=%dx%d"
		% [
			_jogador.global_position.x,
			_jogador.global_position.y,
			_jogador.global_position.z,
			acertos_gravados,
			int(_jogador.get("acertos_deste_golpe")),
			_camera.global_position.x,
			_camera.size,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	_fase = "fim"


func _process(_delta: float) -> void:
	if _quadros_ate_gravar > 0:
		_quadros_ate_gravar -= 1
		if _quadros_ate_gravar == 0:
			_gravar_depois_do_desenho()
		return
	if _fase != "fim":
		return
	var acertos: int = _boneco.get("acertos")
	var deste: int = _jogador.get("acertos_deste_golpe")
	if int(_jogador.get("quadros_sobre_o_alvo")) < 2 and _lamina.visible:
		return
	print("MEDICAO captura acertos=%d deste=%d quadros=%d" % [acertos, deste, int(_jogador.get("quadros_sobre_o_alvo"))])
	if acertos != 1 or deste != 1:
		print("FALHA a captura contou mais de um acerto")
		get_tree().quit(1)
		return
	get_tree().quit(0)
