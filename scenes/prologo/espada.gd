extends Node3D

## A área do golpe continua pertencendo ao controlador. O punho é o pivô do arco visual.
var tempo := 0.0

func _ready() -> void:
	get_parent().layers = 0
	visibility_changed.connect(_reiniciar)

func _reiniciar() -> void:
	tempo = 0.0
	rotation.z = 0.58

func _process(delta: float) -> void:
	if is_visible_in_tree():
		tempo += delta
		rotation.z = lerpf(0.58,-0.32,clampf(tempo / 0.16,0,1))
