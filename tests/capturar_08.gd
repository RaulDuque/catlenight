extends Node

## Grava o jogador na galeria com o indicador em "Vida 2/3". Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"

var _cena: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _sentinela: AnimatableBody3D
var _camera: Camera3D
var _rotulo: Label
var _frames := 0
var _gravando := false


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/08_vida_do_jogador.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria") as AnimatableBody3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	var enquadramento := _cena.get_node("Galeria/Enquadramento") as Node3D
	_camera.global_transform = enquadramento.global_transform
	_camera.current = true
	_rotulo = _cena.get_node("IndicadorDeVida/Vida") as Label
	_jogador.global_position = Vector3(29.25, 0.2, 0.0)
	_jogador.velocity = Vector3.ZERO
	_visual.rotation.y = 0.0


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _gravando or _jogador == null:
		return
	var texto := _rotulo.text
	var no_chao := _jogador.is_on_floor() and _jogador.global_position.y < 0.2
	if texto == "Vida 2/3" and no_chao and _frames > 8:
		_gravar()
		return
	if _frames > 400:
		print("FALHA sem quadro de dano. texto=%s x=%.3f y=%.3f vida=%s" % [
			texto, _jogador.global_position.x, _jogador.global_position.y, str(_jogador.get("pontos_de_vida")),
		])
		get_tree().quit(1)


func _gravar() -> void:
	_gravando = true
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	var arquivo := "08-dano-na-galeria.png"
	imagem.save_png(_PASTA + arquivo)
	print(
		"POSE arquivo=%s texto=%s x=%.3f y=%.3f sent=%.3f camera_x=%.2f quadro=%dx%d"
		% [
			arquivo,
			_rotulo.text,
			_jogador.global_position.x,
			_jogador.global_position.y,
			_sentinela.global_position.x,
			_camera.global_position.x,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	get_tree().quit(0)
