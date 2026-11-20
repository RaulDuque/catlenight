extends Node

## A escadaria conserva o quadro da 15-B. Depois do limiar, a câmera acompanha X.


const _X_DA_ESCADA := -26.2
const _A_PARTIR_DE := -30.0
const _X_MINIMO := -43.5


func _physics_process(_delta: float) -> void:
	var jogador := get_parent().get_node_or_null("Jogador") as Node3D
	var camera := get_parent().get_node_or_null("CameraLateral") as Camera3D
	if jogador == null or camera == null:
		return
	var no_salao := jogador.global_position.x < _A_PARTIR_DE
	var x := _X_DA_ESCADA
	if no_salao:
		x = clampf(jogador.global_position.x + 4.2, _X_MINIMO, _X_DA_ESCADA)
	camera.global_position.x = x
	var ceu := get_parent().get_node_or_null("EscadariaExterior/CeuPintado") as Node3D
	var apresentacao := get_parent().get_node_or_null("Apresentacao")
	if ceu != null and apresentacao != null:
		ceu.visible = bool(apresentacao.get("com_arte")) and not no_salao
