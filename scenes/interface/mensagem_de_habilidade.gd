extends CanvasLayer

## Aviso curto no centro inferior. O indicador de vida fica no canto.

var _restante := 0.0


func _ready() -> void:
	add_to_group("mensagem_de_habilidade")
	$Texto.visible = false


func mostrar(texto: String) -> void:
	$Texto.text = texto
	$Texto.visible = true
	_restante = 2.4


func _process(delta: float) -> void:
	if _restante <= 0.0:
		return
	_restante -= delta
	if _restante <= 0.0:
		$Texto.visible = false
