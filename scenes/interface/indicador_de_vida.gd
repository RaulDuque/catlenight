extends CanvasLayer

## Fica na tela, então acompanha a câmera nas duas salas.
## mostrar recebe os pontos assim que a vida muda.

var _derrota := 0.0


func _ready() -> void:
	add_to_group("indicador_de_vida")


func mostrar(atual: int, maximo: int) -> void:
	if _derrota > 0.0:
		return
	$Vida.text = "Vida %d/%d" % [atual, maximo]


func mostrar_derrota() -> void:
	$Vida.text = "Derrota"
	_derrota = 0.6


func _process(delta: float) -> void:
	if _derrota <= 0.0:
		return
	_derrota -= delta
	if _derrota > 0.0:
		return
	var jogador := get_parent().get_node("Jogador")
	mostrar(int(jogador.get("pontos_de_vida")), int(jogador.get("pontos_maximos")))
