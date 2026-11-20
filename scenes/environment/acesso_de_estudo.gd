extends Area3D

## Ligação provisória. Seta para cima, com os pés no chão, leva ao marcador.
## Andar por cima do volume não troca de lugar.

@export var destino: NodePath
@export var texto: String = "↑"


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false


func _physics_process(_delta: float) -> void:
	var jogador := _apoiado()
	var aviso := get_node_or_null("Texto") as Label3D
	if aviso != null:
		aviso.visible = jogador != null
	if jogador == null or not Input.is_action_just_pressed("interagir"):
		return
	var marca := get_node_or_null(destino) as Node3D
	if marca == null:
		return
	jogador.global_position = marca.global_position
	jogador.velocity = Vector3.ZERO


func _apoiado() -> CharacterBody3D:
	for corpo in get_overlapping_bodies():
		if corpo is CharacterBody3D and corpo.name == "Jogador" and (corpo as CharacterBody3D).is_on_floor():
			return corpo as CharacterBody3D
	return null
