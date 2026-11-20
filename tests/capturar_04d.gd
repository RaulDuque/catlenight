extends Node

## Repete duas poses do piloto para comparar a visibilidade. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"
const _X_ARCO := -1.714
const _X_LIVRE := -0.6
const _TEMPO_DO_CLIPE := 0.27

var _etapa := "antes"
var _sala: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _animacao: AnimationPlayer
var _camera: Camera3D
var _fila: Array[Dictionary] = []
var _espera := 0


func _ready() -> void:
	var argumentos := OS.get_cmdline_user_args()
	if argumentos.size() > 0:
		_etapa = argumentos[0]
	call_deferred("_montar")


func _montar() -> void:
	_sala = (load("res://scenes/verification/04c_corrida_mixamo.tscn") as PackedScene).instantiate()
	add_child(_sala)
	_jogador = _sala.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_camera = _sala.get_node("CameraLateral") as Camera3D
	_jogador.set_physics_process(false)
	_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_fila = [
		{"nome": "04d-arco-%s.png" % _etapa, "x": _X_ARCO, "rotacao": 0.0},
		{"nome": "04d-arco-%s-esquerda.png" % _etapa, "x": _X_ARCO, "rotacao": PI},
		{"nome": "04d-livre-%s.png" % _etapa, "x": _X_LIVRE, "rotacao": 0.0},
	]
	_posar()


func _posar() -> void:
	var item: Dictionary = _fila[0]
	_jogador.global_position = Vector3(item["x"], 0.0, 0.0)
	_visual.rotation.y = item["rotacao"]
	if _animacao != null and _animacao.has_animation("corrida"):
		_animacao.play("corrida")
		_animacao.seek(_TEMPO_DO_CLIPE, true)
		_animacao.pause()
	_espera = 3


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
	var tempo := _animacao.current_animation_position if _animacao != null else -1.0
	print(
		"POSE arquivo=%s x=%.4f y=%.4f z=%.4f rot=%.4f clipe=%.4f camera=%.2f quadro=%dx%d"
		% [
			item["nome"],
			_jogador.global_position.x,
			_jogador.global_position.y,
			_jogador.global_position.z,
			_visual.rotation.y,
			tempo,
			_camera.size,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	if _fila.is_empty():
		get_tree().quit(0)
		return
	_posar()
