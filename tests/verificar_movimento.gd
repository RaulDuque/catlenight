extends SceneTree

## Mede a física real da cena principal. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _TOLERANCIA_CHAO_M := 0.08

	var _jogador: CharacterBody3D
	var _fase := "cair"
	var _frames := 0
	var _falhas: PackedStringArray = []
	var _z_max := 0.0
	var _y_inicial := 0.0
	var _y_pouso := 0.0
	var _x_marca := 0.0
	var _pico_pulo := 0.0
	var _vy_antes_do_segundo := 0.0
	var _vy_depois_do_segundo := 0.0
	var _y_ao_pousar_segurando := 0.0
	var _subiu_segurando := false
	var _y_na_plataforma := 0.0
	var _x_na_plataforma := 0.0
	var _y_de_volta := 0.0
	var _x_de_volta := 0.0
	var _retorno_ok := false
	var _encerrado := false
	var _pronto := false

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/main.tscn") as PackedScene
		var sala := packed.instantiate()
		get_tree().root.add_child(sala)
		_jogador = sala.get_node("Jogador") as CharacterBody3D
		_y_inicial = _jogador.global_position.y
		if _jogador.is_on_floor():
			_falhar("nasceu já no chão")
		if _y_inicial < 0.8:
			_falhar("pés começaram abaixo de 0,8 m: %.3f" % _y_inicial)
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		match _fase:
			"cair":
				_cair()
			"direita":
				_direita()
			"parada":
				_parada()
			"esquerda":
				_esquerda()
			"pulo":
				_pulo()
			"segundo_pulo":
				_segundo_pulo()
			"esperar_chao":
				_esperar_chao()
			"segurar_impulso":
				_segurar_impulso()
			"segurar_no_ar":
				_segurar_no_ar()
			"segurar_no_chao":
				_segurar_no_chao()
			"plataforma":
				_plataforma()
			"voltar":
				_voltar()
			"borda":
				_borda()
			_:
				_falhar("fase desconhecida: %s" % _fase)
				_encerrar()

	func _cair() -> void:
		var y := _jogador.global_position.y
		if _jogador.is_on_floor() and absf(y) <= _TOLERANCIA_CHAO_M:
			_y_pouso = y
			_x_marca = _jogador.global_position.x
			_frames = 0
			_pressionar("direita")
			_fase = "direita"
		elif _frames > 180:
			_falhar("não pousou no chão. y=%.3f" % y)
			_encerrar()

	func _direita() -> void:
		if _frames == 1:
			_x_marca = _jogador.global_position.x
		if _frames < 24:
			return
		var dx := _jogador.global_position.x - _x_marca
		if dx <= 0.4:
			_falhar("seta direita não avançou o bastante: dx=%.3f" % dx)
		_soltar("direita")
		_x_marca = _jogador.global_position.x
		_frames = 0
		_fase = "parada"

	func _parada() -> void:
		if _frames == 3:
			_x_marca = _jogador.global_position.x
		if _frames < 18:
			return
		var dx := absf(_jogador.global_position.x - _x_marca)
		if dx > 0.02:
			_falhar("soltar a seta não interrompeu a caminhada: dx=%.3f" % dx)
		_x_marca = _jogador.global_position.x
		_pressionar("esquerda")
		_frames = 0
		_fase = "esquerda"

	func _esquerda() -> void:
		if _frames < 24:
			return
		var dx := _jogador.global_position.x - _x_marca
		if dx >= -0.4:
			_falhar("seta esquerda não recuou o bastante: dx=%.3f" % dx)
		_soltar("esquerda")
		_pico_pulo = _jogador.global_position.y
		_pressionar("pulo")
		_frames = 0
		_fase = "pulo"

	func _pulo() -> void:
		_pico_pulo = maxf(_pico_pulo, _jogador.global_position.y)
		if _frames == 8 and _jogador.is_on_floor():
			_falhar("o pulo não tirou o corpo do chão")
		if _frames < 12:
			return
		_soltar("pulo")
		_vy_antes_do_segundo = _jogador.velocity.y
		_pressionar("pulo")
		_frames = 0
		_fase = "segundo_pulo"

	func _segundo_pulo() -> void:
		_pico_pulo = maxf(_pico_pulo, _jogador.global_position.y)
		if _frames < 3:
			return
		_vy_depois_do_segundo = _jogador.velocity.y
		if _vy_depois_do_segundo > _vy_antes_do_segundo + 0.25:
			_falhar("segundo aperto no ar aumentou a subida: antes %.3f depois %.3f" % [_vy_antes_do_segundo, _vy_depois_do_segundo])
		if _pico_pulo < 1.0:
			_falhar("o pulo subiu pouco: pico %.3f" % _pico_pulo)
		_soltar("pulo")
		_frames = 0
		_fase = "esperar_chao"

	func _esperar_chao() -> void:
		_pico_pulo = maxf(_pico_pulo, _jogador.global_position.y)
		if _jogador.is_on_floor():
			_frames = 0
			_pressionar("pulo")
			_fase = "segurar_impulso"
		elif _frames > 180:
			_falhar("não voltou ao chão depois do pulo")
			_encerrar()

	func _segurar_impulso() -> void:
		if not _jogador.is_on_floor() and _frames > 2:
			_frames = 0
			_fase = "segurar_no_ar"
		elif _frames > 30:
			_falhar("segurar Espaço no chão não iniciou o pulo")
			_encerrar()

	func _segurar_no_ar() -> void:
		if _jogador.is_on_floor() and _frames > 4:
			_y_ao_pousar_segurando = _jogador.global_position.y
			_frames = 0
			_fase = "segurar_no_chao"
		elif _frames > 180:
			_falhar("não aterrissou com Espaço segurado")
			_encerrar()

	func _segurar_no_chao() -> void:
		if _jogador.global_position.y > _y_ao_pousar_segurando + 0.15:
			_subiu_segurando = true
		if _frames < 20:
			return
		if _subiu_segurando:
			_falhar("segurar Espaço na aterrissagem disparou outro pulo")
		_soltar("pulo")
		_pressionar("esquerda")
		_frames = 0
		_fase = "borda"

	func _plataforma() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if x >= -1.5 and not Input.is_action_pressed("pulo") and _jogador.is_on_floor():
			_pressionar("pulo")
		var sobre := _jogador.is_on_floor() and y > 0.45 and x > 0.2 and x < 4.2
		if sobre:
			_y_na_plataforma = y
			_x_na_plataforma = x
			_soltar("pulo")
			_frames = 0
			_fase = "voltar"
		elif _frames > 420:
			_falhar("não ficou em pé na plataforma. x=%.3f y=%.3f chão=%s" % [x, y, _jogador.is_on_floor()])
			_encerrar()

	func _voltar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if _jogador.is_on_floor() and y <= _TOLERANCIA_CHAO_M and x > 4.2:
			_y_de_volta = y
			_x_de_volta = x
			_soltar("direita")
			_encerrar()
			return
		elif _frames > 300:
			_falhar("não voltou ao chão depois da plataforma. x=%.3f y=%.3f" % [x, y])
			_encerrar()

	func _borda() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var nascimento := Vector3(-3.2, 1.0, 0.0)
		var pos := _jogador.global_position
		if pos.distance_to(nascimento) < 0.15 and _jogador.velocity.length() < 0.05 and _frames > 20:
			_retorno_ok = true
			_soltar("esquerda")
			_pressionar("direita")
			_frames = 0
			_fase = "plataforma"
			return
		if _frames > 500:
			_falhar("cair da borda não devolveu ao início. pos=%s vel=%s" % [pos, _jogador.velocity])
			_encerrar()

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		if _z_max > 0.001:
			_falhar("Z saiu do plano: |z| máximo %.6f" % _z_max)
		print("MEDICAO y_inicial=%.4f" % _y_inicial)
		print("MEDICAO y_pouso=%.4f" % _y_pouso)
		print("MEDICAO pico_pulo=%.4f" % _pico_pulo)
		print("MEDICAO vy_antes_segundo=%.4f vy_depois_segundo=%.4f" % [_vy_antes_do_segundo, _vy_depois_do_segundo])
		print("MEDICAO plataforma x=%.4f y=%.4f" % [_x_na_plataforma, _y_na_plataforma])
		print("MEDICAO volta x=%.4f y=%.4f" % [_x_de_volta, _y_de_volta])
		print("MEDICAO z_max=%.6f" % _z_max)
		print("MEDICAO retorno=%s" % _retorno_ok)
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
