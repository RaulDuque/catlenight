extends Node

## Abre a janela do piloto 12 e grava o mapa. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"
const _ARQUIVO := "user://catlenight_piloto_11.json"

var modo := "vestibulo"
var _cena: Node
var _jogador: CharacterBody3D
var _menu: CanvasLayer
var _mapa: Node
var _fase := "menu"
var _frames := 0
var _gravando := false
var _texto := ""
var _no_chao := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		modo = String(args[0])
	call_deferred("_montar")


func _montar() -> void:
	_texto = _ler()
	_cena = (load("res://scenes/verification/12_mapa_das_salas.tscn") as PackedScene).instantiate()
	add_child(_cena)
	_jogador = _cena.get_node("Jogador") as CharacterBody3D
	_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer
	_mapa = get_tree().get_first_node_in_group("mapa_das_salas")


func _physics_process(_delta: float) -> void:
	if _gravando or _jogador == null or _mapa == null:
		return
	_frames += 1
	if _fase == "menu":
		_menu_escolher(modo == "capela")
		return
	if not _jogador.is_on_floor() or _jogador.global_position.y > 0.35:
		if _frames > 180:
			print("FALHA sem o piso")
			get_tree().quit(1)
		return
	if not _no_chao:
		_no_chao = true
		_frames = 0
		return
	if not bool(_mapa.get("aberto")):
		if _frames == 8:
			_pressionar("abrir_mapa")
		if _frames == 12:
			_soltar("abrir_mapa")
		if _frames > 80:
			print("FALHA o mapa não abriu")
			get_tree().quit(1)
		return
	_soltar("abrir_mapa")
	if Input.is_action_pressed("abrir_mapa"):
		return
	_gravar()


func _menu_escolher(continuar: bool) -> void:
	if not _menu.visible and not get_tree().paused:
		_soltar("pulo")
		_soltar("direita")
		_frames = 0
		_fase = "mapa"
		return
	if continuar:
		if _frames == 6:
			_pressionar("direita")
		if _frames == 8:
			_soltar("direita")
	if (not continuar and _frames == 8) or (continuar and _frames == 14):
		_pressionar("pulo")
	if (not continuar and _frames == 12) or (continuar and _frames == 18):
		_soltar("pulo")
	if _frames > 90:
		print(
			"FALHA menu selecao=%s habilitado=%s"
			% [String(_menu.get("selecao")), bool(_menu.get("continuar_habilitado"))]
		)
		get_tree().quit(1)


func _gravar() -> void:
	_gravando = true
	if _ler() != _texto:
		print("FALHA a captura alterou o arquivo")
		get_tree().quit(1)
		return
	await RenderingServer.frame_post_draw
	var imagem := get_viewport().get_texture().get_image()
	var nome := "12-mapa-primeira-visita.png" if modo == "vestibulo" else "12-mapa-na-capela.png"
	imagem.save_png(_PASTA + nome)
	var vida := _cena.get_node("IndicadorDeVida/Vida") as Label
	var camera := _cena.get_node("CameraLateral") as Camera3D
	var vistas: Array = _mapa.get("visitadas")
	print(
		"POSE modo=%s atual=%s visitadas=%s vida=%s x=%.3f y=%.3f camera_x=%.2f quadro=%dx%d"
		% [
			modo,
			String(_mapa.get("sala_atual_id")),
			",".join(_textos(vistas)),
			vida.text,
			_jogador.global_position.x,
			_jogador.global_position.y,
			camera.global_position.x,
			imagem.get_width(),
			imagem.get_height(),
		]
	)
	get_tree().quit(0)


func _textos(valor: Array) -> PackedStringArray:
	var saida: PackedStringArray = []
	for item in valor:
		saida.append(String(item))
	return saida


func _ler() -> String:
	if not FileAccess.file_exists(_ARQUIVO):
		return ""
	return FileAccess.get_file_as_string(_ARQUIVO)


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
