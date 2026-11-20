extends Node

## Acompanha o corpo em X e Y. A vista geral da planta fica noutra câmera.


func _physics_process(_delta: float) -> void:
	var jogador := get_parent().get_node_or_null("Jogador") as Node3D
	var camera := get_parent().get_node_or_null("CameraLateral") as Camera3D
	if jogador == null or camera == null or not camera.current:
		return
	camera.global_position = Vector3(jogador.global_position.x, jogador.global_position.y + 2.2, 14.0)
