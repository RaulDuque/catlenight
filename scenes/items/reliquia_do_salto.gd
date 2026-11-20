extends Node3D

## Peça original da galeria. O toque chama aprender_salto_duplo uma vez.

var _coletada := false


func _ready() -> void:
	var coleta := $Coleta as Area3D
	coleta.collision_layer = 0
	coleta.collision_mask = 1
	coleta.monitoring = true
	coleta.body_entered.connect(_ao_tocar)


func _ao_tocar(corpo: Node) -> void:
	if _coletada or corpo == null or not corpo.has_method("aprender_salto_duplo"):
		return
	_coletada = true
	corpo.aprender_salto_duplo()
	($Coleta as Area3D).set_deferred("monitoring", false)
	visible = false
	queue_free()
