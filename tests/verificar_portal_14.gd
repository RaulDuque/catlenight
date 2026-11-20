extends SceneTree

## Percurso da cena 14, com user:// isolado. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _TOPO := 2.35
	const _CENA := "res://scenes/verification/14_portal_da_sacada.tscn"
	const _ENTRAR := "↑ Entrar na capela"
	const _VOLTAR := "↑ Voltar ao vestíbulo"

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
	var _apoiado := 0
	var _pes_antes := 0.0

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
			"entrar":
				_entrar()
			"afastar":
				_afastar()
			"retornar":
				_retornar()

	func _conferir_montagem() -> void:
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if principal != "res://scenes/verification/main.tscn":
			_falhar("o F5 mudou: %s" % principal)
			return
		if absf(_camera.size - 8.0) > 0.001:
			_falhar("a câmera não está com Size 8")
			return
		if (_cena.get_node("Vestibulo/Sacada/Parede") as Node3D).visible:
			_falhar("a parede lisa continua visível")
			return
		for nome in ["Vao", "OmbreiraEsquerda", "OmbreiraDireita", "Lintel"]:
			if (_cena.get_node("Vestibulo/VaoDaCapela/%s" % nome) as Node3D).visible:
				_falhar("a moldura retangular continua visível: %s" % nome)
				return
		var portal := _cena.get_node("Vestibulo/PortalDaSacada") as Node3D
		if portal.position.distance_to(Vector3(-4.55, 2.35, -0.84)) > 0.001:
			_falhar("o portal não está na soleira")
			return
		if portal.find_children("*", "CollisionObject3D", true, false).size() != 0:
			_falhar("o portal ganhou colisão")
			return
		var chegada := _cena.get_node("Vestibulo/ChegadaDaSacada") as Node3D
		if chegada.position.distance_to(Vector3(-4.55, 2.42, 0.0)) > 0.001:
			_falhar("a chegada da sacada mudou")
			return
		var passagem := _cena.get_node("Vestibulo/VaoDaCapela/Passagem") as Node3D
		if passagem.position.distance_to(Vector3(-4.55, 3.15, 0.0)) > 0.001:
			_falhar("o detector da passagem mudou")
			return
		var laje := _cena.get_node("Vestibulo/Sacada/Laje/Colisao") as CollisionShape3D
		var topo := laje.global_position.y + (laje.shape as BoxShape3D).size.y * 0.5
		if absf(topo - _TOPO) > 0.001:
			_falhar("o topo da laje mudou: %.3f" % topo)

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
			_pes_antes = y
			print("MEDICAO antes x=%.3f y=%.3f aviso=%s" % [x, y, _aviso.text])
			_ir("entrar")
		elif _frames > 280:
			_falhar("não pousou na sacada. x=%.3f y=%.3f aviso=%s" % [x, y, _aviso.text])

	func _entrar() -> void:
		if _frames == 6:
			_pressionar("interagir")
		if _frames == 10:
			_soltar("interagir")
		if _camera.global_position.x > 40.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			print("MEDICAO entrou x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			_ir("afastar")
		elif _frames > 140:
			_falhar("não entrou na capela. camera=%.2f" % _camera.global_position.x)

	func _afastar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 47.6 and _aviso.text != _VOLTAR:
			_ir("retornar")
		elif _frames > 240:
			_falhar("o aviso não sumiu. x=%.3f texto=%s" % [_jogador.global_position.x, _aviso.text])

	func _retornar() -> void:
		if _camera.global_position.x < 10.0:
			_soltar("interagir")
			_soltar("esquerda")
			var y := _jogador.global_position.y
			var no_alto := _jogador.is_on_floor() and absf(y - _TOPO) < 0.02 and _jogador.global_position.x < -3.6 and _jogador.global_position.x > -5.6
			if no_alto:
				_apoiado += 1
			if _apoiado >= 8:
				print("MEDICAO voltou x=%.3f y=%.3f antes=%.3f" % [_jogador.global_position.x, y, _pes_antes])
				if absf(_pes_antes - _TOPO) > 0.02 or absf(y - _TOPO) > 0.02:
					_falhar("os pés não ficaram em 2,350")
					return
				_ok()
			elif _frames > 300:
				_falhar("não assentou na sacada. y=%.3f" % y)
			return
		if not (_aviso.visible and _aviso.text == _VOLTAR and _jogador.is_on_floor()):
			_pressionar("esquerda")
			if _frames > 300:
				_falhar("não achou a saída. x=%.3f aviso=%s" % [_jogador.global_position.x, _aviso.text])
			return
		_soltar("esquerda")
		if _frames > 20 and not Input.is_action_pressed("interagir"):
			_pressionar("interagir")

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("interagir")
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
