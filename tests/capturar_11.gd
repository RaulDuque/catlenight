extends Node

## Grava o altar com a confirmação. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"
const _SALVAR := "↑ Salvar progresso"
const _PRONTO := "Progresso salvo"

var _cena: Node
var _jogador: CharacterBody3D
var _aviso: Label
var _menu: CanvasLayer
var _fase := "menu"
var _frames := 0
var _gravando := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_montar")


func _montar() -> void:
	_cena = (load("res://scenes/verification/11_altar_de_salvamento.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
	_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer


func _physics_process(_delta: float) -> void:
	if _gravando or _jogador == null:
		return
	_frames += 1
	if _fase == "menu":
		_menu_continuar()
		return
	if not _jogador.is_on_floor() or _jogador.global_position.y > 0.2:
		if _frames > 90:
			print("FALHA sem o piso")
			get_tree().quit(1)
		return
	if _aviso.visible and _aviso.text == _PRONTO:
		_gravar()
		return
	if _aviso.visible and _aviso.text == _SALVAR and _frames > 8 and not Input.is_action_pressed("interagir"):
		_pressionar("interagir")
	elif _frames > 160:
		print("FALHA sem a confirmação. texto=%s" % _aviso.text)
		get_tree().quit(1)


func _menu_continuar() -> void:
	if not _menu.visible and not get_tree().paused:
		_soltar("pulo")
		_soltar("direita")
		_frames = 0
		_fase = "altar"
		return
	if _frames == 6:
		_pressionar("direita")
	if _frames == 8:
		_soltar("direita")
	if _frames == 14:
		_pressionar("pulo")
	if _frames == 18:
		_soltar("pulo")
	if _frames > 90:
		print(
			"FALHA menu selecao=%s habilitado=%s pausado=%s"
			% [String(_menu.get("selecao")), bool(_menu.get("continuar_habilitado")), get_tree().paused]
		)
		get_tree().quit(1)


func _gravar() -> void:
	_gravando = true
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	imagem.save_png(_PASTA + "11-altar-progresso-salvo.png")
	var vida := _cena.get_node("IndicadorDeVida/Vida") as Label
	var camera := _cena.get_node("CameraLateral") as Camera3D
	print(
		"POSE texto=%s vida=%s x=%.3f y=%.3f camera_x=%.2f quadro=%dx%d"
		% [
			_aviso.text if _aviso.visible else "",
			vida.text,
			_jogador.global_position.x,
			_jogador.global_position.y,
			camera.global_position.x,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	get_tree().quit(0)


func _pressionar(acao: String) -> void:
	if Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = true
	Input.parse_input_event(evento)
	Input.flush_buffered_events()


func _soltar(acao: String) -> void:
	if not Input.is_action_pressed(acao):
		return
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = false
	Input.parse_input_event(evento)
	Input.flush_buffered_events()
