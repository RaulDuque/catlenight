extends SceneTree

## Percurso da cena 13, com user:// isolado. Não faz parte do jogo.


func _initialize() -> void:
	var driver := Driver.new()
	root.add_child(driver)


class Driver extends Node:
	const _TOPO := 2.35
	const _CENA := "res://scenes/verification/13_vestibulo_do_castelo.tscn"
	const _ENTRAR := "↑ Entrar na capela"

	var _cena: Node
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _aviso: Label
	var _menu: CanvasLayer
	var _fase := "menu"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _pulou := false
	var _impulso := false
	var _passo := 0

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		_cena = (load(_CENA) as PackedScene).instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
		_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer
		_conferir_montagem()
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		match _fase:
			"menu":
				_menu_novo()
			"galeria":
				_galeria()
			"plataforma":
				_plataforma()
			"coletar":
				_coletar()
			"voltar":
				_voltar()
			"aproximar":
				_aproximar()
			"pousar":
				_pousar()
			"mapa":
				_mapa()
			"entrar":
				_entrar()

	func _conferir_montagem() -> void:
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if principal != "res://scenes/verification/main.tscn":
			_falhar("o F5 mudou: %s" % principal)
			return
		if absf(_camera.size - 8.0) > 0.001:
			_falhar("a câmera não está com Size 8")
			return
		var primeira := _cena.get_node("Vestibulo/Revestimento/Parede_0") as Node3D
		var segunda := _cena.get_node("Vestibulo/Revestimento/Parede_1") as Node3D
		if absf(segunda.position.x - primeira.position.x - 2.0) > 0.001:
			_falhar("o módulo não está deslocado 2 m")
			return
		if primeira.position.z >= 0.0:
			_falhar("a parede não ficou atrás do plano Z = 0")
			return
		var corpos := _cena.get_node("Vestibulo/Revestimento").find_children("*", "CollisionObject3D", true, false)
		if corpos.size() != 0:
			_falhar("o revestimento ganhou colisão")
			return

	func _menu_novo() -> void:
		if not _menu.visible and not get_tree().paused:
			_soltar("pulo")
			_frames = 0
			_fase = "galeria"
			return
		if _frames == 8:
			_pressionar("pulo")
		if _frames == 12:
			_soltar("pulo")
		if _frames > 90:
			_falhar("o menu não fechou")

	func _galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_soltar("esquerda")
		var x := _jogador.global_position.x
		if _camera.global_position.x > 20.0 and x > 18.0 and x < 22.5 and _jogador.is_on_floor() and _jogador.global_position.y < 0.4:
			_ir("plataforma")
		elif _frames > 450:
			_falhar("não chegou à galeria. x=%.3f" % x)

	func _plataforma() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and y < 0.3 and x > 22.0 and x < 22.7 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.45:
			_soltar("pulo")
		if _jogador.is_on_floor() and y > 0.9 and x > 23.2 and x < 27.0:
			_ir("coletar")
		elif _frames > 360:
			_falhar("não subiu na plataforma. x=%.3f y=%.3f" % [x, y])

	func _coletar() -> void:
		var x := _jogador.global_position.x
		if x < 24.0:
			_pressionar("direita")
			_soltar("esquerda")
		elif x > 24.35:
			_pressionar("esquerda")
			_soltar("direita")
		else:
			_soltar("direita")
			_soltar("esquerda")
		if bool(_jogador.get("salto_duplo_adquirido")):
			_ir("voltar")
		elif _frames > 240:
			_falhar("não coletou a relíquia. x=%.3f" % x)

	func _voltar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		_soltar("direita")
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and y < 0.35 and x < 28.0 and x > 23.2 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.55:
			_soltar("pulo")
		if _camera.global_position.x < 5.0 and x < 6.0 and x > 1.0 and y < 0.4:
			_pulou = false
			_impulso = false
			_ir("aproximar")
		elif _frames > 500:
			_falhar("não voltou ao vestíbulo. x=%.3f" % x)

	func _aproximar() -> void:
		var x := _jogador.global_position.x
		if x > -2.95:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		if x <= -2.95 and x > -3.4 and _jogador.is_on_floor() and _jogador.global_position.y < 0.3:
			_pulou = false
			_impulso = false
			_ir("pousar")
		elif _frames > 300:
			_falhar("não se aproximou da sacada. x=%.3f" % x)

	func _pousar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
		if _pulou and _frames > 4 and not _jogador.is_on_floor():
			_soltar("pulo")
		if _pulou and not _impulso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
			_impulso = true
		if y > _TOPO + 0.02 and x > -4.15:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		var no_alto := _jogador.is_on_floor() and absf(y - _TOPO) < 0.02 and x < -3.7 and x > -5.7
		if no_alto and _aviso.visible and _aviso.text == _ENTRAR:
			print("MEDICAO sacada x=%.3f y=%.3f aviso=%s" % [x, y, _aviso.text])
			_passo = 0
			_ir("mapa")
		elif _frames > 280:
			_falhar("não pousou na sacada. x=%.3f y=%.3f aviso=%s" % [x, y, _aviso.text])

	func _mapa() -> void:
		var mapa := get_tree().get_first_node_in_group("mapa_das_salas")
		if _passo == 0:
			if not bool(mapa.get("aberto")):
				if _frames == 3:
					_pressionar("abrir_mapa")
				if _frames == 8:
					_soltar("abrir_mapa")
				if _frames > 40:
					_falhar("o mapa não abriu antes da capela")
				return
			_soltar("abrir_mapa")
			if Input.is_action_pressed("abrir_mapa"):
				return
			var atual := String(mapa.get("sala_atual_id"))
			var vistas := _lista(mapa.get("visitadas"))
			print("MEDICAO mapa_antes atual=%s visitadas=%s" % [atual, ",".join(vistas)])
			if atual != "vestibulo" or vistas.has("capela_da_lua"):
				_falhar("a capela apareceu antes da entrada")
				return
			_passo = 1
			_frames = 0
			return
		if bool(mapa.get("aberto")):
			if _frames == 3:
				_pressionar("abrir_mapa")
			if _frames == 6:
				_soltar("abrir_mapa")
			if _frames > 40:
				_falhar("o mapa não fechou antes da capela")
			return
		_ir("entrar")

	func _entrar() -> void:
		if _frames == 6:
			_pressionar("interagir")
		if _frames == 10:
			_soltar("interagir")
		if _camera.global_position.x > 40.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			_conferir_mapa_da_capela()
		elif _frames > 140:
			_falhar("não entrou na capela. camera=%.2f" % _camera.global_position.x)

	func _conferir_mapa_da_capela() -> void:
		var mapa := get_tree().get_first_node_in_group("mapa_das_salas")
		if not bool(mapa.get("aberto")):
			if _frames == 14:
				_pressionar("abrir_mapa")
			if _frames == 18:
				_soltar("abrir_mapa")
			if _frames > 80:
				_falhar("o mapa não abriu na capela")
			return
		var atual := String(mapa.get("sala_atual_id"))
		var vistas := _lista(mapa.get("visitadas"))
		var sala := _cena.get("sala_atual") as Node3D
		print("MEDICAO mapa_depois atual=%s visitadas=%s sala=%s" % [atual, ",".join(vistas), sala.name])
		if atual != "capela_da_lua" or not vistas.has("vestibulo") or not vistas.has("galeria") or sala.name != "CapelaDaLua":
			_falhar("o marcador não foi para a capela")
			return
		_ok()

	func _lista(valor: Variant) -> PackedStringArray:
		var saida: PackedStringArray = []
		if typeof(valor) != TYPE_ARRAY:
			return saida
		for item in valor:
			saida.append(String(item))
		return saida

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("interagir")
		_soltar("abrir_mapa")
		_frames = 0
		_fase = proxima

	func _ok() -> void:
		print("RESULTADO ok")
		_encerrado = true
		get_tree().quit(0)

	func _falhar(mensagem: String) -> void:
		if _encerrado:
			return
		_encerrado = true
		print("FALHA " + mensagem)
		get_tree().quit(1)

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
