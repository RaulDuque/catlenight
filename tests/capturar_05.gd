extends Node

## Grava a câmera da cena das salas, uma vez em cada sala. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"

var _cena: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _camera: Camera3D
var _fila: Array[Dictionary] = []
var _espera := 0


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/05_salas_conectadas.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_camera = _cena.get_node("CameraLateral") as Camera3D
	_jogador.set_physics_process(false)
	_fila = [
		{
			"nome": "05-vestibulo.png",
			"posicao": Vector3(-3.2, 0.0, 0.0),
			"enquadramento": _cena.get_node("Vestibulo/Enquadramento") as Node3D,
		},
		{
			"nome": "05-galeria.png",
			"posicao": _cena.get_node("Galeria/ChegadaEsquerda").global_position,
			"enquadramento": _cena.get_node("Galeria/Enquadramento") as Node3D,
		},
	]
	_posar()


func _posar() -> void:
	var item: Dictionary = _fila[0]
	var marco := item["enquadramento"] as Node3D
	_camera.global_transform = marco.global_transform
	_camera.current = true
	var ponto: Vector3 = item["posicao"]
	ponto.y = 0.0
	ponto.z = 0.0
	_jogador.global_position = ponto
	_visual.rotation.y = 0.0
	_espera = 6


func _process(_delta: float) -> void:
	if _espera <= 0:
		return
	_espera -= 1
	if _espera > 0:
		return
	var item: Dictionary = _fila.pop_front()
	var caminho := _PASTA + str(item["nome"])
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(caminho)
	print(
		"POSE arquivo=%s x=%.4f y=%.4f z=%.4f camera_x=%.4f camera_size=%.2f quadro=%dx%d"
		% [
			item["nome"],
			_jogador.global_position.x,
			_jogador.global_position.y,
			_jogador.global_position.z,
			_camera.global_position.x,
			_camera.size,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	if _fila.is_empty():
		get_tree().quit(0)
		return
	_posar()
