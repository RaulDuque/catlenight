extends SceneTree

## Percurso até a capela com as ações do Input Map. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _TOPO := 2.35
	const _TEXTO_ENTRAR := "↑ Entrar na capela"
	const _TEXTO_VOLTAR := "↑ Voltar ao vestíbulo"

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _aviso: Label
	var _vida: Label
	var _passagem: Area3D
	var _vitral: Node3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _pulou := false
	var _impulso := false
	var _cruzou_no_ar := false
	var _segurou_ok := false
	var _entrou_ok := false
	var _voltou_ok := false
	var _portas_ok := false
	var _apoiado := 0
	var _entradas := 0
	var _voltas := 0
	var _vida_baixa := 3
	var _camera_capela := 0.0
	var _pes_capela := Vector3.ZERO
	var _camera_sacada := 0.0
	var _pes_sacada := Vector3.ZERO

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/10_capela_da_lua.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
		_vida = _cena.get_node("IndicadorDeVida/Vida") as Label
		_passagem = _cena.get_node("Vestibulo/VaoDaCapela/Passagem") as Area3D
		_vitral = _cena.get_node("CapelaDaLua/Vitral") as Node3D
		var forma := _cena.get_node("Vestibulo/Sacada/Laje/Colisao") as CollisionShape3D
		var caixa := forma.shape as BoxShape3D
		var topo := forma.global_position.y + caixa.size.y * 0.5
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		var adquirido: bool = _jogador.get("salto_duplo_adquirido")
		print("MEDICAO topo=%.3f adquirido=%s f5=%s acao=%s" % [topo, adquirido, principal, InputMap.has_action("interagir")])
		if absf(topo - _TOPO) > 0.001:
			_falhar("o topo da laje mudou: %.3f" % topo)
		if adquirido or principal != "res://scenes/verification/main.tscn" or not InputMap.has_action("interagir"):
			_falhar("o piloto não começou no vestíbulo, com salto simples e a ação interagir")
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		match _fase:
			"cair":
				_cair()
			"simples":
				_simples()
			"galeria":
				_galeria()
			"plataforma":
				_plataforma()
			"coletar":
				_coletar()
			"ferir":
				_ferir()
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
			"descer":
				_descer()
			"revisitar":
				_revisitar()

	func _cair() -> void:
		if _jogador.is_on_floor() and _frames > 8:
			_pressionar("esquerda")
			_frames = 0
			_fase = "simples"

	func _simples() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if x > -4.35:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		if not _pulou and _jogador.is_on_floor() and x < -4.2 and _frames > 6:
			_pressionar("pulo")
			_pressionar("interagir")
			_pulou = true
			_frames = 0
		if _pulou and not _jogador.is_on_floor():
			_soltar("pulo")
		if _pulou and _frames > 18 and _jogador.is_on_floor() and y < 0.3:
			_soltar("interagir")
			_soltar("pulo")
			if _camera.global_position.x > 10.0 or y > 0.4:
				_falhar("antes da relíquia a interação tirou o jogador do vestíbulo")
				_encerrar()
				return
			print("MEDICAO simples x=%.3f y=%.3f camera=%.2f" % [x, y, _camera.global_position.x])
			_soltar("esquerda")
			_pressionar("direita")
			_pulou = false
			_frames = 0
			_fase = "galeria"
		elif _pulou and _frames > 180:
			_falhar("o salto simples não voltou ao piso. y=%.3f" % y)
			_encerrar()

	func _galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _camera.global_position.x > 20.0 and _jogador.global_position.x > 18.0 and _jogador.global_position.x < 22.5:
			_frames = 0
			_fase = "plataforma"
		elif _frames > 450:
			_falhar("não chegou à galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

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
			_soltar("direita")
			_frames = 0
			_fase = "coletar"
		elif _frames > 320:
			_falhar("não subiu na plataforma. x=%.3f y=%.3f" % [x, y])
			_encerrar()

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
		var aprendeu: bool = _jogador.get("salto_duplo_adquirido")
		if aprendeu:
			print("MEDICAO coleta vida=%s" % _vida.text)
			_soltar("esquerda")
			_pressionar("direita")
			_frames = 0
			_fase = "ferir"
		elif _frames > 240:
			_falhar("não coletou a relíquia. x=%.3f" % x)
			_encerrar()

	func _ferir() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		var vida: int = _jogador.get("pontos_de_vida")
		if vida < 3 and vida > 0:
			_vida_baixa = vida
			_soltar("direita")
			_pressionar("esquerda")
			_frames = 0
			_fase = "voltar"
			return
		if vida <= 0:
			_falhar("a sentinela derrubou o jogador antes da capela")
			_encerrar()
			return
		_soltar("esquerda")
		if x < 28.5:
			_pressionar("direita")
		if _jogador.is_on_floor() and y < 0.3 and x > 26.4 and x < 27.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.55:
			_soltar("pulo")
		if x > 28.6 and y < 0.35:
			_soltar("direita")
			_soltar("pulo")
		if _frames > 500:
			_falhar("não tomou dano da sentinela. x=%.3f y=%.3f vida=%d" % [x, y, vida])
			_encerrar()

	func _voltar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		_soltar("direita")
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and y < 0.35 and x < 28.6 and x > 23.2 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.55:
			_soltar("pulo")
		if _camera.global_position.x < 5.0 and x < 6.0 and x > 1.0 and y < 0.4:
			var ainda: bool = _jogador.get("salto_duplo_adquirido")
			var vida: int = _jogador.get("pontos_de_vida")
			if not ainda or vida != _vida_baixa:
				_falhar("a volta da galeria mudou vida ou habilidade. vida=%d hab=%s" % [vida, ainda])
			_soltar("esquerda")
			_pressionar("esquerda")
			_frames = 0
			_fase = "aproximar"
		elif _frames > 500:
			_falhar("não voltou ao vestíbulo depois do dano. x=%.3f camera=%.2f" % [x, _camera.global_position.x])
			_encerrar()

	func _aproximar() -> void:
		var x := _jogador.global_position.x
		if x > -2.95:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		if x <= -2.95 and x > -3.4 and _jogador.is_on_floor() and _jogador.global_position.y < 0.3:
			_soltar("esquerda")
			_pulou = false
			_impulso = false
			_cruzou_no_ar = false
			_frames = 0
			_fase = "pousar"
		elif _frames > 300:
			_falhar("não se aproximou da sacada. x=%.3f" % x)
			_encerrar()

	func _pousar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		if _pulou and not _jogador.is_on_floor():
			_soltar("pulo")
			_pressionar("interagir")
			if _passagem.get_overlapping_bodies().has(_jogador):
				_cruzou_no_ar = true
		if _pulou and not _impulso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
			_impulso = true
		if y > _TOPO + 0.02 and x > -4.15:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		var no_alto := _jogador.is_on_floor() and absf(y - _TOPO) < 0.12 and x < -3.7 and x > -5.7
		if no_alto and Input.is_action_pressed("interagir") and _camera.global_position.x < 10.0:
			_apoiado += 1
		else:
			_apoiado = 0
		if _apoiado >= 8:
			_segurou_ok = _cruzou_no_ar
			if not _cruzou_no_ar:
				_falhar("o salto não cruzou a área da porta no ar")
			if _camera.global_position.x > 10.0:
				_falhar("pousar com a tecla apertada entrou na capela")
			print("MEDICAO segurou x=%.3f y=%.3f camera=%.2f cruzou=%s vida=%d" % [x, y, _camera.global_position.x, _cruzou_no_ar, int(_jogador.get("pontos_de_vida"))])
			_soltar("esquerda")
			_soltar("interagir")
			_apoiado = 0
			_frames = 0
			_fase = "entrar"
		elif _camera.global_position.x > 10.0:
			_falhar("a tecla presa durante o salto abriu a capela")
			_encerrar()
		elif _frames > 260:
			_falhar("não pousou na sacada com a tecla presa. x=%.3f y=%.3f" % [x, y])
			_encerrar()

	func _entrar() -> void:
		if _frames < 8:
			return
		if _frames == 8:
			_pressionar("interagir")
		if _frames == 12:
			_soltar("interagir")
		if _camera.global_position.x > 40.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			_entradas += 1
			var vida: int = _jogador.get("pontos_de_vida")
			var ainda: bool = _jogador.get("salto_duplo_adquirido")
			_camera_capela = _camera.global_position.x
			_pes_capela = _jogador.global_position
			_entrou_ok = vida == _vida_baixa and ainda and _vitral.visible and _entradas == 1
			if _entradas != 1:
				_falhar("a entrada não foi única: %d" % _entradas)
			if vida != _vida_baixa or not ainda:
				_falhar("a capela alterou vida ou habilidade. vida=%d hab=%s" % [vida, ainda])
			if not _vitral.visible:
				_falhar("o vitral não apareceu")
			print("MEDICAO entrou sala=capela pes=%.3f,%.3f camera=%.2f vida=%d aviso=%s" % [_pes_capela.x, _pes_capela.y, _camera_capela, vida, _aviso.text if _aviso.visible else ""])
			_soltar("interagir")
			_pressionar("direita")
			_frames = 0
			_fase = "afastar"
		elif _frames > 120:
			_falhar("o toque não entrou na capela. camera=%.2f aviso=%s" % [_camera.global_position.x, _aviso.text])
			_encerrar()

	func _afastar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 47.6 and not _aviso.visible:
			print("MEDICAO afastou aviso=%s vitral=%s" % [_aviso.visible, _vitral.visible])
			_soltar("direita")
			_pressionar("esquerda")
			_frames = 0
			_fase = "retornar"
		elif _frames > 240:
			_falhar("o aviso não sumiu ao se afastar. texto=%s x=%.3f" % [_aviso.text, _jogador.global_position.x])
			_encerrar()

	func _retornar() -> void:
		var x := _jogador.global_position.x
		if _camera.global_position.x < 10.0:
			_soltar("interagir")
			_soltar("esquerda")
			var y := _jogador.global_position.y
			var no_alto := _jogador.is_on_floor() and absf(y - _TOPO) < 0.15 and x < -3.6 and x > -5.6
			if no_alto:
				_apoiado += 1
			if _apoiado >= 8:
				_voltas += 1
				var vida: int = _jogador.get("pontos_de_vida")
				var ainda: bool = _jogador.get("salto_duplo_adquirido")
				_camera_sacada = _camera.global_position.x
				_pes_sacada = _jogador.global_position
				_voltou_ok = _voltas == 1 and vida == _vida_baixa and ainda
				if not _voltou_ok:
					_falhar("a volta não ficou na sacada. vida=%d voltas=%d y=%.3f" % [vida, _voltas, y])
				print("MEDICAO voltou sala=vestibulo pes=%.3f,%.3f camera=%.2f vida=%d quadros=%d" % [_pes_sacada.x, _pes_sacada.y, _camera_sacada, vida, _apoiado])
				_pressionar("direita")
				_frames = 0
				_fase = "descer"
			elif _frames > 300:
				_falhar("não voltou à sacada. x=%.3f camera=%.2f aviso=%s" % [x, _camera.global_position.x, _aviso.text])
				_encerrar()
			return
		if not (_aviso.visible and _aviso.text == _TEXTO_VOLTAR and _jogador.is_on_floor()):
			_pressionar("esquerda")
			if _frames > 300:
				_falhar("não achou a saída da capela. x=%.3f aviso=%s" % [x, _aviso.text])
				_encerrar()
			return
		_soltar("esquerda")
		if not Input.is_action_pressed("interagir"):
			_pressionar("interagir")

	func _descer() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.25 and _jogador.global_position.x > -3.2:
			_frames = 0
			_fase = "revisitar"
		elif _frames > 200:
			_falhar("não desceu da sacada. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			_encerrar()

	func _revisitar() -> void:
		var x := _jogador.global_position.x
		var camera := _camera.global_position.x
		if camera < 10.0:
			if not Input.is_action_pressed("direita"):
				_pressionar("direita")
			_soltar("esquerda")
		elif x > 18.0:
			_soltar("direita")
			_pressionar("esquerda")
		if camera < 5.0 and x < 6.0 and x > 1.0 and _frames > 30 and not Input.is_action_pressed("direita"):
			_portas_ok = true
			print("MEDICAO revisita x=%.3f camera=%.2f" % [x, camera])
			_soltar("esquerda")
			_encerrar()
		elif _frames > 700:
			_falhar("depois da sacada não atravessou a galeria. x=%.3f camera=%.2f" % [x, camera])
			_encerrar()

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("interagir")
		var jogadores := 0
		for corpo in _cena.find_children("*", "CharacterBody3D", true, false):
			if corpo.name == "Jogador":
				jogadores += 1
		if jogadores != 1:
			_falhar("havia %d jogadores" % jogadores)
		if not _segurou_ok or not _entrou_ok or not _voltou_ok or not _portas_ok:
			if _falhas.is_empty():
				_falhar("algum trecho ficou sem confirmação")
		print("MEDICAO resumo vida=%d segurou=%s entrou=%s voltou=%s portas=%s" % [_vida_baixa, _segurou_ok, _entrou_ok, _voltou_ok, _portas_ok])
		if _falhas.is_empty():
			print("RESULTADO ok")
			get_tree().quit(0)
		else:
			for falha in _falhas:
				print("FALHA %s" % falha)
			print("RESULTADO falhou")
			get_tree().quit(1)

	func _falhar(texto: String) -> void:
		_falhas.append(texto)

	func _pressionar(acao: String) -> void:
		if Input.is_action_pressed(acao):
			return
		var evento := InputEventAction.new()
		evento.action = acao
		evento.pressed = true
		Input.parse_input_event(evento)

	func _soltar(acao: String) -> void:
		if not Input.is_action_pressed(acao):
			return
		var evento := InputEventAction.new()
		evento.action = acao
		evento.pressed = false
		Input.parse_input_event(evento)
