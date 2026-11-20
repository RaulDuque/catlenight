extends Node

## A cena 15 abre o mapa e a câmera na escadaria, antes de o menu confirmar.


func _ready() -> void:
	# O _ready do piloto enquadra o vestíbulo depois dos filhos.
	# O adiamento devolve a câmera à escadaria antes do primeiro quadro.
	call_deferred("_enquadrar")


func _enquadrar() -> void:
	var salas := get_parent()
	var escada := salas.get_node_or_null("EscadariaExterior") as Node3D
	if escada != null and salas.has_method("definir_sala_atual"):
		salas.definir_sala_atual(escada)
