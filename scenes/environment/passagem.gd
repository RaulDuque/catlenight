extends Area3D

## Detecta o jogador e guarda para onde a travessia vai.
## sala_de_destino e chegada são caminhos a partir deste nó.
## A chegada fica fora do volume que dispararia a volta.

@export var sala_de_destino: NodePath
@export var chegada: NodePath
## 0 aceita os dois sentidos. -1 só entra andando para −X. 1 só entra andando para +X.
@export var sentido_x: int = 0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	add_to_group("passagem")
