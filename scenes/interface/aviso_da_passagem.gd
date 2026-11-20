extends CanvasLayer

## Indica a passagem enquanto os pés estão diante dela. A vida fica no canto.

var _origem := 0


func _ready() -> void:
	add_to_group("aviso_da_passagem")
	$Texto.visible = false


func mostrar(texto: String, origem: Node) -> void:
	_origem = origem.get_instance_id()
	$Texto.text = texto
	$Texto.visible = true


func esconder(origem: Node) -> void:
	if _origem != origem.get_instance_id():
		return
	$Texto.visible = false
	_origem = 0
