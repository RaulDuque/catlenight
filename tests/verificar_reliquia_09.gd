extends SceneTree

## Percurso da relíquia com a física e as ações do Input Map. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _X_PISO := 0.8
	const _X_APROX := -3.0
	const _TEXTO := "Salto duplo adquirido — aperte Espaço outra vez no ar"

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _sentinela: AnimatableBody3D
	var _camera: Camera3D
	var _reliquia: Node3D
	var _mensagem: Label
	var _vida: Label
	var _retorno_vestibulo: Node3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _topo := 0.0
	var _pico_simples := 0.0
	var _pico_arco := 0.0
	var _pico_duplo := 0.0
	var _pes_x := 0.0
	var _pes_y := 0.0
	var _apoiado := 0
	var _vy_antes_terceiro := 0.0
	var _vy_depois_terceiro := 0.0
	var _segurou_ok := false
	var _terceiro_ok := false
	var _repos_ok := false
	var _porta_ok := false
	var _queda_ok := false
	var _derrota_ok := false
	var _pouso_ok := false
	var _vida_antes_da_queda := 0
	var _pulou := false
	var _impulso_do_pouso := false
	var _segundo_dado := false
	var _quadros_no_chao := 0
	var _z_max := 0.0

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/09_reliquia_do_salto_duplo.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria") as AnimatableBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_reliquia = _cena.get_node("Galeria/ReliquiaDoSalto") as Node3D
		_mensagem = _cena.get_node("MensagemDaHabilidade/Texto") as Label
		_vida = _cena.get_node("IndicadorDeVida/Vida") as Label
		_retorno_vestibulo = _cena.get_node("Vestibulo/Retorno") as Node3D
		var forma := _cena.get_node("Vestibulo/Sacada/Laje/Colisao") as CollisionShape3D
		var caixa := forma.shape as BoxShape3D
		_topo = forma.global_position.y + caixa.size.y * 0.5
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		var segundo: float = _jogador.get("velocidade_do_segundo_salto_m_por_s")
		var adquirido: bool = _jogador.get("salto_duplo_adquirido")
		print("MEDICAO topo=%.3f segundo=%.2f adquirido=%s f5=%s" % [_topo, segundo, adquirido, principal])
		if adquirido or absf(segundo - 5.5) > 0.01:
			_falhar("o piloto não começou com salto simples e 5,5 m/s")
		if principal != "res://scenes/verification/main.tscn":
			_falhar("F5 mudou: %s" % principal)
		if not _reliquia.is_inside_tree():
			_falhar("a relíquia não estava na galeria")
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		match _fase:
			"cair":
				_cair()
			"simples":
				_simples()
			"tentar":
				_tentar()
			"arco":
				_arco()
			"galeria":
				_galeria()
			"plataforma":
				_plataforma()
			"coletar":
				_coletar()
			"voltar":
				_voltar()
			"segurar":
				_segurar()
			"terceiro":
				_terceiro()
			"repor":
				_repor()
			"pousar":
				_pousar()
			"descer":
				_descer()
			"queda":
				_queda()
			"ir_derrota":
				_ir_derrota()
			"derrota":
				_derrota()

	func _cair() -> void:
		if _jogador.is_on_floor() and _frames > 8:
			_colocar(_X_PISO)
			_pulou = false
			_frames = 0
			_fase = "simples"

	func _simples() -> void:
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		if _pulou and _frames == 4:
			_soltar("pulo")
		if _pulou:
			_pico_simples = maxf(_pico_simples, _jogador.global_position.y)
		if _pulou and _frames > 20 and _jogador.is_on_floor():
			print("MEDICAO pico_simples=%.3f" % _pico_simples)
			if _pico_simples >= _topo - 0.05:
				_falhar("o salto simples alcançou a sacada. pico=%.3f topo=%.3f" % [_pico_simples, _topo])
			_colocar(_X_APROX)
			_pulou = false
			_frames = 0
			_fase = "tentar"
		elif _frames > 180:
			_falhar("o salto simples não pousou")
			_encerrar()

	func _tentar() -> void:
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("esquerda")
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		if _pulou and _frames == 4:
			_soltar("pulo")
		if _pulou and _frames > 25 and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			_soltar("esquerda")
			if _jogador.global_position.y > _topo - 0.3:
				_falhar("subiu na sacada sem a relíquia")
				_encerrar()
				return
			_colocar(-2.05)
			_pulou = false
			_frames = 0
			_fase = "arco"
		elif _frames > 200:
			_falhar("a tentativa na sacada não voltou ao piso. y=%.3f" % _jogador.global_position.y)
			_encerrar()

	func _arco() -> void:
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		if _pulou and _frames == 4:
			_soltar("pulo")
		if _pulou:
			_pico_arco = maxf(_pico_arco, _jogador.global_position.y)
		if _pulou and _frames > 20 and _jogador.is_on_floor() and _jogador.global_position.y < 0.4:
			if _pico_arco > _topo - 0.2:
				_falhar("o arco serviu de degrau. pico=%.3f" % _pico_arco)
			_soltar("esquerda")
			_soltar("direita")
			_pressionar("direita")
			_frames = 0
			_fase = "galeria"
		elif _frames > 180:
			_falhar("o salto no arco não voltou ao piso. y=%.3f" % _jogador.global_position.y)
			_encerrar()

	func _galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _camera.global_position.x > 20.0 and _jogador.global_position.x > 18.0 and _jogador.global_position.x < 22.0:
			_soltar("direita")
			_frames = 0
			_fase = "plataforma"
		elif _frames > 400:
			_falhar("não chegou à galeria. x=%.3f camera=%.3f" % [_jogador.global_position.x, _camera.global_position.x])
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
			_soltar("pulo")
			_frames = 0
			_fase = "coletar"
		elif _frames > 300:
			_falhar("não subiu na plataforma. x=%.3f y=%.3f" % [x, y])
			_encerrar()

	func _coletar() -> void:
		var alvo := 24.15
		var x := _jogador.global_position.x
		if x < alvo - 0.15:
			_pressionar("direita")
			_soltar("esquerda")
		elif x > alvo + 0.15:
			_pressionar("esquerda")
			_soltar("direita")
		else:
			_soltar("direita")
			_soltar("esquerda")
		var aprendeu: bool = _jogador.get("salto_duplo_adquirido")
		if aprendeu and _mensagem.visible and _mensagem.text == _TEXTO and not is_instance_valid(_reliquia):
			if _vida.text != "Vida 3/3":
				_falhar("a coleta cobriu ou mudou a vida: %s" % _vida.text)
			print("MEDICAO coleta texto=%s vida=%s" % [_mensagem.text, _vida.text])
			_soltar("direita")
			_soltar("esquerda")
			_pressionar("esquerda")
			_frames = 0
			_fase = "voltar"
		elif _frames > 240:
			_falhar("não coletou por contato. x=%.3f aprendeu=%s texto=%s" % [x, aprendeu, _mensagem.text])
			_encerrar()

	func _voltar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if y > 0.8 and _jogador.is_on_floor() and x < 26.0:
			_pressionar("esquerda")
		elif not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _camera.global_position.x < 5.0 and x < 6.0 and x > 1.0:
			var ainda: bool = _jogador.get("salto_duplo_adquirido")
			_porta_ok = ainda
			if not ainda:
				_falhar("a troca de sala esqueceu o salto duplo")
			_soltar("esquerda")
			_colocar(_X_PISO)
			_pulou = false
			_frames = 0
			_fase = "segurar"
		elif _frames > 500:
			_falhar("não voltou ao vestíbulo. x=%.3f camera=%.3f" % [x, _camera.global_position.x])
			_encerrar()

	func _segurar() -> void:
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		var extra: bool = _jogador.get("_impulso_extra_disponivel")
		var y := _jogador.global_position.y
		if not _jogador.is_on_floor() and y > _pico_simples + 0.25:
			_falhar("segurar Espaço gastou o segundo impulso. y=%.3f" % y)
			_encerrar()
			return
		if _frames > 15 and not _jogador.is_on_floor() and not extra:
			_falhar("segurar Espaço consumiu o impulso extra")
			_encerrar()
			return
		if _frames > 30 and _jogador.is_on_floor():
			_segurou_ok = extra
			if not extra:
				_falhar("ao pousar segurando, o impulso não estava disponível")
			_soltar("pulo")
			_frames = 0
			_fase = "terceiro"
		elif _frames > 200:
			_falhar("segurar Espaço não voltou ao piso")
			_encerrar()

	func _terceiro() -> void:
		var y := _jogador.global_position.y
		var vy := _jogador.velocity.y
		_pico_duplo = maxf(_pico_duplo, y)
		if not _segundo_dado and _frames == 2:
			_pressionar("pulo")
		if not _segundo_dado and _frames == 6:
			_soltar("pulo")
		if not _segundo_dado and _frames > 8 and y > 1.15 and vy < 0.6 and not _jogador.is_on_floor():
			_pressionar("pulo")
			_segundo_dado = true
			_frames = 0
			_quadros_no_chao = 0
			return
		if _segundo_dado and _frames == 3:
			_soltar("pulo")
		if _segundo_dado and _frames == 8:
			_vy_antes_terceiro = vy
			_pressionar("pulo")
		if _segundo_dado and _frames == 12:
			_vy_depois_terceiro = _jogador.velocity.y
			_soltar("pulo")
		if _segundo_dado and _jogador.is_on_floor() and _frames > 14:
			_quadros_no_chao += 1
		else:
			_quadros_no_chao = 0
		if _quadros_no_chao >= 3:
			print("MEDICAO pico_duplo=%.3f terceiro_antes=%.3f terceiro_depois=%.3f" % [_pico_duplo, _vy_antes_terceiro, _vy_depois_terceiro])
			_terceiro_ok = _vy_depois_terceiro <= _vy_antes_terceiro + 0.25 and _pico_duplo > _topo + 0.2
			if _vy_depois_terceiro > _vy_antes_terceiro + 0.25:
				_falhar("o terceiro toque aumentou a subida")
			if _pico_duplo <= _topo + 0.2:
				_falhar("o salto duplo não deixou margem. pico=%.3f topo=%.3f" % [_pico_duplo, _topo])
			var extra: bool = _jogador.get("_impulso_extra_disponivel")
			_repos_ok = extra
			if not extra:
				_falhar("pousar não devolveu o impulso extra")
			_colocar(_X_APROX)
			_pulou = false
			_impulso_do_pouso = false
			_frames = 0
			_fase = "pousar"
		elif _frames > 220:
			_falhar("o salto duplo não pousou. y=%.3f" % y)
			_encerrar()

	func _repor() -> void:
		pass

	func _pousar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
			_frames = 0
		if _pulou and _frames > 4 and not _jogador.is_on_floor():
			_soltar("pulo")
		if _pulou and not _impulso_do_pouso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
			_impulso_do_pouso = true
		if y > _topo + 0.02 and x > -4.15:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		var no_alto := _jogador.is_on_floor() and absf(y - _topo) < 0.12 and x < -3.7 and x > -5.7
		if no_alto:
			_apoiado += 1
		else:
			_apoiado = 0
		if _apoiado >= 8:
			_pes_x = x
			_pes_y = y
			_pouso_ok = true
			print("MEDICAO pouso x=%.3f y=%.3f quadros=%d" % [x, y, _apoiado])
			_soltar("esquerda")
			_pressionar("direita")
			_frames = 0
			_fase = "descer"
		elif _frames > 240:
			_falhar("não ficou apoiado na sacada. x=%.3f y=%.3f chao=%s" % [x, y, _jogador.is_on_floor()])
			_encerrar()

	func _descer() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		var y := _jogador.global_position.y
		var x := _jogador.global_position.x
		if _jogador.is_on_floor() and y < 0.2 and x > -3.3:
			_soltar("direita")
			_vida_antes_da_queda = int(_jogador.get("pontos_de_vida"))
			_pressionar("esquerda")
			_frames = 0
			_fase = "queda"
		elif _frames > 200:
			_falhar("não desceu da sacada. x=%.3f y=%.3f" % [x, y])
			_encerrar()

	func _queda() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var perto := _jogador.global_position.distance_to(_retorno_vestibulo.global_position) < 1.2
		if _frames > 20 and perto and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			var ainda: bool = _jogador.get("salto_duplo_adquirido")
			var vida: int = _jogador.get("pontos_de_vida")
			_queda_ok = ainda and vida == _vida_antes_da_queda
			if not ainda:
				_falhar("a queda esqueceu o salto duplo")
			if vida != _vida_antes_da_queda:
				_falhar("a queda mudou a vida de %d para %d" % [_vida_antes_da_queda, vida])
			print("MEDICAO queda x=%.3f vida=%d habilidade=%s" % [_jogador.global_position.x, vida, ainda])
			_soltar("esquerda")
			_pressionar("direita")
			_frames = 0
			_fase = "ir_derrota"
		elif _frames > 400:
			_falhar("cair da borda não devolveu ao vestíbulo. pos=%s" % _jogador.global_position)
			_encerrar()

	func _ir_derrota() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and y < 0.3 and x > 22.0 and x < 26.0:
			if not Input.is_action_pressed("pulo"):
				_pressionar("pulo")
		if y > 0.45:
			_soltar("pulo")
		if y > 0.8 and x > 24.0 and x < 27.0 and _frames > 180:
			_jogador.global_position = Vector3(27.6, 0.25, 0.0)
			_jogador.velocity = Vector3.ZERO
			_soltar("pulo")
		if _camera.global_position.x > 20.0 and x > 26.2 and x < 28.2 and y < 0.4:
			_soltar("direita")
			_soltar("pulo")
			_frames = 0
			_fase = "derrota"
		elif _frames > 500:
			_falhar("não chegou à sentinela. x=%.3f y=%.3f vel=%s sent=%.3f" % [x, y, _jogador.velocity, _sentinela.global_position.x])
			_encerrar()

	func _derrota() -> void:
		var retornos: int = _jogador.get("retornos_por_derrota")
		if retornos > 0:
			var ainda: bool = _jogador.get("salto_duplo_adquirido")
			var vida: int = _jogador.get("pontos_de_vida")
			var perto := absf(_jogador.global_position.x - 21.0) < 0.8
			_derrota_ok = ainda and vida == 3 and perto and retornos == 1
			if not _derrota_ok:
				_falhar("a derrota não conservou a habilidade. vida=%d retornos=%d x=%.3f hab=%s" % [vida, retornos, _jogador.global_position.x, ainda])
			print("MEDICAO derrota x=%.3f vida=%d retornos=%d habilidade=%s" % [_jogador.global_position.x, vida, retornos, ainda])
			_soltar("direita")
			_encerrar()
			return
		var y := _jogador.global_position.y
		if y > 0.35:
			y = 0.12
		_jogador.global_position = Vector3(_sentinela.global_position.x - 0.45, y, 0.0)
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _frames > 240:
			_falhar("o contato não derrubou o jogador. vida=%s" % str(_jogador.get("pontos_de_vida")))
			_encerrar()

	func _colocar(x: float) -> void:
		_jogador.global_position = Vector3(x, 0.2, 0.0)
		_jogador.velocity = Vector3.ZERO

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		if _z_max > 0.001:
			_falhar("Z saiu do plano: %.6f" % _z_max)
		var jogadores := 0
		for corpo in _cena.find_children("*", "CharacterBody3D", true, false):
			if corpo.name == "Jogador":
				jogadores += 1
		if jogadores != 1:
			_falhar("havia %d jogadores" % jogadores)
		print("MEDICAO resumo topo=%.3f simples=%.3f duplo=%.3f pes=%.3f,%.3f" % [_topo, _pico_simples, _pico_duplo, _pes_x, _pes_y])
		print("MEDICAO segurar=%s terceiro=%s repos=%s porta=%s queda=%s derrota=%s pouso=%s" % [_segurou_ok, _terceiro_ok, _repos_ok, _porta_ok, _queda_ok, _derrota_ok, _pouso_ok])
		if not _segurou_ok or not _terceiro_ok or not _repos_ok or not _porta_ok or not _queda_ok or not _derrota_ok or not _pouso_ok:
			if _falhas.is_empty():
				_falhar("algum trecho do percurso ficou sem confirmação")
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
