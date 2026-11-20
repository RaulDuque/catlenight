extends Area3D

## Só troca de sala com os pés no chão e um toque novo em interagir.
## sala_de_destino e chegada são caminhos a partir deste nó.

@export var sala_de_destino: NodePath
@export var chegada: NodePath
@export var texto_do_aviso: String = ""


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false


func _physics_process(_delta: float) -> void:
	var apoiado := _jogador_apoiado()
	if apoiado == null:
		_aviso(false)
		return
	_aviso(true)
	if Input.is_action_just_pressed("interagir"):
		_pedir()


func _jogador_apoiado() -> CharacterBody3D:
	for corpo in get_overlapping_bodies():
		if corpo is CharacterBody3D and corpo.name == "Jogador" and (corpo as CharacterBody3D).is_on_floor():
			if corpo.global_position.distance_to(global_position) > 2.2:
				continue
			return corpo as CharacterBody3D
	return null


func _aviso(ligado: bool) -> void:
	var aviso := get_tree().get_first_node_in_group("aviso_da_passagem")
	if aviso == null:
		return
	if ligado and aviso.has_method("mostrar"):
		aviso.mostrar(texto_do_aviso, self)
	elif aviso.has_method("esconder"):
		aviso.esconder(self)


func _pedir() -> void:
	var no: Node = self
	while no != null:
		if no.has_method("solicitar_passagem"):
			no.solicitar_passagem(self)
			_aviso(false)
			return
		no = no.get_parent()
