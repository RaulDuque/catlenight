extends Control

## Mapa desenhado por cima da cena 3D.
## A sala atual é a mesma que salas_conectadas enquadra.
## A capela só entra no desenho depois que essa troca termina.

const _IDS := {
	"Vestibulo": "vestibulo",
	"Galeria": "galeria",
	"CapelaDaLua": "capela_da_lua",
	"EscadariaExterior": "escadaria_exterior",
}
const _NOMES := {
	"vestibulo": "Vestíbulo",
	"galeria": "Galeria",
	"capela_da_lua": "Capela da Lua",
	"escadaria_exterior": "Escadaria",
}
const _CAIXAS := {
	"vestibulo": Rect2(500, 330, 200, 88),
	"galeria": Rect2(820, 330, 200, 88),
	"capela_da_lua": Rect2(250, 140, 230, 88),
	"escadaria_exterior": Rect2(230, 330, 210, 88),
}
const _SALAS: Array[String] = ["escadaria_exterior", "vestibulo", "galeria", "capela_da_lua"]

var visitadas: Array[String] = []
var sala_atual_id := ""
var aberto := false

var _ativo := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var camada := get_parent()
	camada.process_mode = Node.PROCESS_MODE_ALWAYS
	camada.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("mapa_das_salas")
	$Ajuda.text = "M Fecha o mapa"
	_atualizar()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("abrir_mapa"):
		_alternar()
		return
	if not _ativo or aberto or get_tree().paused:
		return
	_observar_sala()


func iniciar_jogo_novo() -> void:
	var id := "vestibulo"
	var raiz := get_parent().get_parent()
	var sala := raiz.get("sala_atual") as Node3D
	if sala != null and _IDS.has(String(sala.name)):
		id = String(_IDS[String(sala.name)])
	visitadas = [id]
	sala_atual_id = id
	_ativo = true
	_atualizar()


func aplicar_gravacao(lista: Array, atual: String) -> void:
	visitadas.clear()
	for item in lista:
		var id := String(item)
		if not visitadas.has(id):
			visitadas.append(id)
	sala_atual_id = atual
	_ativo = true
	_atualizar()


func aplicar_legado() -> void:
	# O altar da etapa 11 só era alcançado depois das três salas.
	visitadas = ["vestibulo", "galeria", "capela_da_lua"]
	sala_atual_id = "capela_da_lua"
	_ativo = true
	_atualizar()


func para_gravacao() -> Dictionary:
	return {
		"salas_visitadas": visitadas.duplicate(),
		"sala_atual": sala_atual_id,
	}


func ligacoes() -> Array[String]:
	var saida: Array[String] = []
	if visitadas.has("escadaria_exterior") and visitadas.has("vestibulo"):
		saida.append("escadaria_exterior-vestibulo")
	if visitadas.has("vestibulo") and visitadas.has("galeria"):
		saida.append("vestibulo-galeria")
	if visitadas.has("vestibulo") and visitadas.has("capela_da_lua"):
		saida.append("vestibulo-capela_da_lua")
	return saida


func _alternar() -> void:
	if not _ativo:
		return
	var menu := get_tree().get_first_node_in_group("menu_do_piloto")
	if menu != null and menu.visible:
		return
	if aberto:
		_fechar()
	else:
		_abrir()


func _abrir() -> void:
	aberto = true
	get_parent().visible = true
	get_tree().paused = true
	_atualizar()


func _fechar() -> void:
	aberto = false
	get_parent().visible = false
	get_tree().paused = false


func _observar_sala() -> void:
	var raiz := get_parent().get_parent()
	var sala := raiz.get("sala_atual") as Node3D
	if sala == null or not _IDS.has(String(sala.name)):
		return
	var id := String(_IDS[String(sala.name)])
	var mudou := id != sala_atual_id
	sala_atual_id = id
	if not visitadas.has(id):
		visitadas.append(id)
		mudou = true
	if mudou:
		_atualizar()


func _atualizar() -> void:
	for item in _SALAS:
		var id := String(item)
		var rotulo := get_node(_no_do_nome(id)) as Label
		var caixa: Rect2 = _CAIXAS[id]
		rotulo.position = caixa.position
		rotulo.size = caixa.size
		rotulo.text = String(_NOMES[id])
		rotulo.visible = visitadas.has(id)
	var marcador := $Marcador as Label
	if _CAIXAS.has(sala_atual_id) and visitadas.has(sala_atual_id):
		var caixa_atual: Rect2 = _CAIXAS[sala_atual_id]
		marcador.position = caixa_atual.position + Vector2(0, caixa_atual.size.y + 6)
		marcador.size = Vector2(caixa_atual.size.x, 36)
		marcador.visible = true
	else:
		marcador.visible = false
	queue_redraw()


func _no_do_nome(id: String) -> String:
	match id:
		"vestibulo":
			return "NomeVestibulo"
		"galeria":
			return "NomeGaleria"
		"escadaria_exterior":
			return "NomeEscadaria"
		_:
			return "NomeCapela"


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.016, 0.03, 0.9))
	var centros: Dictionary = {}
	for item in _SALAS:
		var id := String(item)
		if visitadas.has(id):
			var caixa: Rect2 = _CAIXAS[id]
			centros[id] = caixa.get_center()
	var traco := Color(0.78, 0.72, 0.58)
	if centros.has("escadaria_exterior") and centros.has("vestibulo"):
		draw_line(centros["escadaria_exterior"] as Vector2, centros["vestibulo"] as Vector2, traco, 4.0)
	if centros.has("vestibulo") and centros.has("galeria"):
		draw_line(centros["vestibulo"] as Vector2, centros["galeria"] as Vector2, traco, 4.0)
	if centros.has("vestibulo") and centros.has("capela_da_lua"):
		draw_line(centros["vestibulo"] as Vector2, centros["capela_da_lua"] as Vector2, traco, 4.0)
	for chave in centros.keys():
		var sala_id := String(chave)
		var caixa_sala: Rect2 = _CAIXAS[sala_id]
		var atual := sala_id == sala_atual_id
		draw_rect(caixa_sala, Color(0.4, 0.33, 0.22) if atual else Color(0.22, 0.21, 0.19))
		draw_rect(caixa_sala, Color(0.96, 0.86, 0.58) if atual else Color(0.55, 0.52, 0.46), false, 3.0)
