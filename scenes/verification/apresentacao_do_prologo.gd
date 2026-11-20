extends Node

## B alterna Blocos e Com arte. A colisão, o jogador e a câmera ficam no lugar.

var com_arte := false
var _aviso: Label

const _BLOCOS: Array[String] = [
	"EscadariaExterior/Lance/Rampa/Bloco",
	"EscadariaExterior/PatamarInferior/Bloco",
	"EscadariaExterior/PatamarSuperior/Bloco",
	"EscadariaExterior/LimiarBloco",
	"EscadariaExterior/MarcaDeAltura",
	"EscadariaExterior/Ceu",
	"EscadariaExterior/Lua",
	"EscadariaExterior/TorreDistante",
	"EscadariaExterior/TorreMenor",
	"EscadariaExterior/TelhadoDistante",
]
const _ARTE: Array[String] = [
	"EscadariaExterior/Lance/Degraus",
	"EscadariaExterior/PatamarInferior/Malha",
	"EscadariaExterior/PatamarSuperior/Malha",
	"EscadariaExterior/Portao",
	"EscadariaExterior/Muro_0",
	"EscadariaExterior/Muro_1",
	"EscadariaExterior/CeuPintado",
	"EscadariaExterior/TorreRecorte",
	"EscadariaExterior/MuroIluminado",
]


func _ready() -> void:
	_desligar_passagens_antigas()
	_criar_aviso()
	aplicar()


func _desligar_passagens_antigas() -> void:
	var raiz := get_parent()
	for caminho in ["EscadariaExterior/Saida", "Vestibulo/SaidaEsquerda"]:
		var passagem := raiz.get_node_or_null(caminho) as Area3D
		if passagem == null:
			continue
		passagem.monitoring = false
		passagem.monitorable = false


func _criar_aviso() -> void:
	var camada := CanvasLayer.new()
	camada.name = "AvisoDaApresentacao"
	camada.layer = 30
	_aviso = Label.new()
	_aviso.position = Vector2(560, 16)
	_aviso.add_theme_font_size_override("font_size", 28)
	_aviso.add_theme_color_override("font_color", Color(0.93, 0.9, 0.82))
	camada.add_child(_aviso)
	get_parent().add_child.call_deferred(camada)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("alternar_apresentacao"):
		com_arte = not com_arte
		aplicar()


func aplicar() -> void:
	var raiz := get_parent()
	if _aviso != null:
		_aviso.text = "Com arte" if com_arte else "Blocos"
	for caminho in _BLOCOS:
		var no := raiz.get_node_or_null(caminho) as Node3D
		if no != null:
			no.visible = not com_arte
	for caminho in _ARTE:
		var no := raiz.get_node_or_null(caminho) as Node3D
		if no != null:
			no.visible = com_arte
