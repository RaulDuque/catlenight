extends Node

## Restringe a câmera ao interior de cada painel da prancha (coordenadas de pixel).
@onready var camera: Camera3D = $"../CameraLateral"
@onready var jogador: Jogador = $"../Jogador"

func _physics_process(_delta: float) -> void:
	var p := jogador.global_position
	var u := p.x * 26 + 1552
	var v := 928 - p.y * 26
	var limites := Rect2(368,528,1280,224)
	if p.y > 14:
		limites = Rect2(624,320,512,224) if v > 354 else Rect2(368,144,768,224)
	elif u >= 1136:
		limites = Rect2(1136,528,512,480)
	var meia_altura := camera.size * 13
	var tela := camera.get_viewport().get_visible_rect().size
	var meia_largura := minf(meia_altura*tela.aspect(),limites.size.x/2)
	var cx := clampf(u,limites.position.x+meia_largura,limites.end.x-meia_largura)
	# O salão e o exterior compartilham o mesmo painel. Deixe o limiar cruzar a tela.
	if p.y < 14:
		cx = clampf(u,368+meia_largura,1648-meia_largura)
	var cy := clampf(v-55,limites.position.y+meia_altura,limites.end.y-meia_altura)
	camera.position = Vector3((cx-1552)/26,(928-cy)/26,14)
