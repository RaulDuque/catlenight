extends Node3D

## Cada região usa a escala e a translação de painel medidas na 15-E.
## Arte de Symphony of the Night, prancha "Final Stage: Bloodlines", mapeada por Revned.
const PRANCHA := preload("res://assets-exemple-2d/Final Stage - _Bloodlines_.png")
const PIXELS_POR_METRO := 26.0

func _ready() -> void:
	_painel("Salao",Rect2i(368,528,768,224),0)
	_painel("Exterior",Rect2i(1136,528,512,480),0)
	_painel("EscadaInterna",Rect2i(624,272,512,224),48)
	_painel("Galeria",Rect2i(368,16,768,224),128)
	for corpo in $"../Sala/Gerado".get_children():
		corpo.get_node("Malha").hide()
	$"../Sala/Assento".hide()
	$"../Sala/Encosto".hide()
	# A boca inferior precisa de piso para o marcador. Repete a pedra do mesmo patamar.
	for u in range(992,1072,16):
		_recorte("Laje",Rect2i(1072,480,16,16),Vector2(u+8,536),-0.93)
	# A soleira acrescentada no blockout atravessa o desnível de 48 px junto à porta.
	for i in 6:
		_recorte("Degrau",Rect2i(1120,720,8,16),Vector2(1140+8*i,724-8*i),-0.93)

func _painel(nome: String,regiao: Rect2i,deslocamento_y: int) -> void:
	_recorte(nome,regiao,Vector2(regiao.get_center()) + Vector2(0,deslocamento_y),-1.0)

func _recorte(nome: String,regiao: Rect2i,centro: Vector2,z: float) -> void:
	var imagem := Sprite3D.new()
	imagem.name = nome
	imagem.texture = PRANCHA
	imagem.region_enabled = true
	imagem.region_rect = Rect2(regiao)
	imagem.pixel_size = 1.0/PIXELS_POR_METRO
	imagem.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	imagem.double_sided = false
	imagem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	imagem.position = Vector3((centro.x-1552)/PIXELS_POR_METRO,(928-centro.y)/PIXELS_POR_METRO,z)
	add_child(imagem,true)
