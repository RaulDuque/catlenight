extends Node

func _ready() -> void:
	var menu := get_parent().get_node("MenuDoPiloto")
	menu.iniciar_novo_jogo.call_deferred()
