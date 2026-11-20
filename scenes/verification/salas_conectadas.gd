extends Node3D

## Um jogador atravessa as salas.
## SaidaDireita e SaidaEsquerda entram no grupo passagem e trocam ao encostar.
## A passagem da capela pede solicitar_passagem, com a tecla e os pés no chão.
## Ao cruzar, os pés vão para o marcador chegada, em Z = 0.
## CameraLateral copia o Enquadramento da sala de destino.
## O Retorno dessa sala passa a ser o ponto de queda do Jogador.

@onready var _jogador = $Jogador
@onready var _camera: Camera3D = $CameraLateral

var _quadros_de_folga := 0
var _passagem_pendente: Area3D
var sala_atual: Node3D


func _ready() -> void:
	for passagem in get_tree().get_nodes_in_group("passagem"):
		passagem.body_entered.connect(_ao_cruzar.bind(passagem))
	_enquadrar(get_node("Vestibulo") as Node3D)


func _physics_process(_delta: float) -> void:
	if _passagem_pendente != null:
		var passagem := _passagem_pendente
		_passagem_pendente = null
		_aplicar(passagem)
	elif _quadros_de_folga > 0:
		_quadros_de_folga -= 1


func solicitar_passagem(passagem: Area3D) -> void:
	if _quadros_de_folga > 0 or _passagem_pendente != null:
		return
	_passagem_pendente = passagem


func _ao_cruzar(corpo: Node3D, passagem: Area3D) -> void:
	if corpo != _jogador or _quadros_de_folga > 0 or _passagem_pendente != null:
		return
	_passagem_pendente = passagem


func _aplicar(passagem: Area3D) -> void:
	var caminho_sala := passagem.get("sala_de_destino") as NodePath
	var caminho_chegada := passagem.get("chegada") as NodePath
	if caminho_sala.is_empty() or caminho_chegada.is_empty():
		push_error("Passagem sem destino: %s" % passagem.name)
		return
	var sala := passagem.get_node(caminho_sala) as Node3D
	var marco := passagem.get_node(caminho_chegada) as Node3D
	var ponto := marco.global_position
	ponto.z = 0.0
	if _jogador.has_method("encerrar_golpe"):
		_jogador.encerrar_golpe()
	var avanco: float = _jogador.velocity.x
	_jogador.global_position = ponto
	_jogador.velocity = Vector3(avanco, 0.0, 0.0)
	_jogador.reset_physics_interpolation()
	var retorno := sala.get_node("Retorno") as Node3D
	_jogador.definir_ponto_de_retorno(retorno.global_position)
	_enquadrar(sala)
	_quadros_de_folga = 10


func definir_sala_atual(sala: Node3D) -> void:
	# A restauração do altar usa o mesmo enquadramento da travessia.
	_enquadrar(sala)


func _enquadrar(sala: Node3D) -> void:
	sala_atual = sala
	var marco := sala.get_node("Enquadramento") as Node3D
	_camera.global_transform = marco.global_transform
