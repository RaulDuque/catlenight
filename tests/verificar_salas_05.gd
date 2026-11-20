extends SceneTree

## Três idas e voltas na cena das salas. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _LIMITE_X := 12.0
	const _TOLERANCIA_CHAO_M := 0.08

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _visual: Node3D
	var _animacao: AnimationPlayer
	var _pilar: Node3D
	var _material: StandardMaterial3D
	var _chegada_galeria: Node3D
	var _chegada_vestibulo: Node3D
	var _retorno_galeria: Node3D
	var _enquadramento_galeria: Node3D
	var _enquadramento_vestibulo: Node3D
	var _fase := "cair"
	var _frames := 0
	var _viagem := 1
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _sala := ""
	var _trocas := 0
	var _trocas_ao_segurar := -1
	var _z_max := 0.0
	var _alpha_min := 1.0
	var _alpha_longe := -1.0
	var _correu_direita := false
	var _correu_esquerda := false
	var _segurou_sem_segunda := false
	var _renasceu_na_galeria := false
	var _queda_armada := false
	var _y_apos_queda := 0.0
	var _x_apos_queda := 0.0
	var _camera_apos_queda := 0.0

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/05_salas_conectadas.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_visual = _jogador.get_node("Visual") as Node3D
		_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
		_pilar = _cena.get_node("Vestibulo/ArcoDePedra/Colisao/PilarFrente") as Node3D
		var pedra := _cena.get_node("Vestibulo/ArcoDePedra/Visual/ArcoDePedra/PilarFrente1") as MeshInstance3D
		_material = pedra.get_surface_override_material(0) as StandardMaterial3D
		_chegada_galeria = _cena.get_node("Galeria/ChegadaEsquerda") as Node3D
		_chegada_vestibulo = _cena.get_node("Vestibulo/ChegadaDireita") as Node3D
		_retorno_galeria = _cena.get_node("Galeria/Retorno") as Node3D
		_enquadramento_galeria = _cena.get_node("Galeria/Enquadramento") as Node3D
		_enquadramento_vestibulo = _cena.get_node("Vestibulo/Enquadramento") as Node3D
		if _animacao == null:
			_falhar("a corrida não entrou no jogador")
		var anda: float = _jogador.get("velocidade_caminhada_m_por_s")
		var pulo: float = _jogador.get("velocidade_inicial_do_pulo_m_por_s")
		var anim: float = _jogador.get("velocidade_da_animacao")
		print("MEDICAO velocidades anda=%.2f pulo=%.2f anim=%.2f" % [anda, pulo, anim])
		if absf(anda - 3.5) > 0.01 or absf(pulo - 5.5) > 0.01 or absf(anim - 1.3) > 0.01:
			_falhar("velocidades alteradas: %.2f %.2f %.2f" % [anda, pulo, anim])
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		_observar_sala()
		_observar_corrida()
		_observar_pilar()
		match _fase:
			"cair":
				_cair()
			"ida":
				_ida()
			"segurar":
				_segurar()
			"parar":
				_parar()
			"queda":
				_queda()
			"esperar_queda":
				_esperar_queda()
			"volta":
				_volta()
			"parar_volta":
				_parar_volta()
			_:
				_falhar("fase desconhecida: %s" % _fase)
				_encerrar()

	func _observar_sala() -> void:
		var nome := "galeria" if _jogador.global_position.x > _LIMITE_X else "vestibulo"
		if _sala == "":
			_sala = nome
		elif nome != _sala:
			_sala = nome
			_trocas += 1
			print(
				"MEDICAO troca=%d sala=%s x=%.4f y=%.4f z=%.4f camera_x=%.4f"
				% [_trocas, nome, _jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _camera.global_position.x]
			)

	func _observar_corrida() -> void:
		if _animacao == null or not _jogador.is_on_floor():
			return
		var correndo := _animacao.is_playing() and _animacao.current_animation == "corrida"
		if _jogador.velocity.x > 3.0 and absf(_visual.rotation.y) < 0.05 and correndo:
			_correu_direita = true
		if _jogador.velocity.x < -3.0 and absf(_visual.rotation.y - PI) < 0.05 and correndo:
			_correu_esquerda = true

	func _observar_pilar() -> void:
		if _material == null:
			return
		var perto := absf(_jogador.global_position.x - _pilar.global_position.x) <= 0.3
		if perto:
			_alpha_min = minf(_alpha_min, _material.albedo_color.a)
		elif _jogador.global_position.x > 0.5 and _jogador.global_position.x < _LIMITE_X and _alpha_longe < 0.0:
			_alpha_longe = _material.albedo_color.a

	func _cair() -> void:
		if _jogador.is_on_floor() and absf(_jogador.global_position.y) <= _TOLERANCIA_CHAO_M:
			_frames = 0
			_pressionar("direita")
			_fase = "ida"
		elif _frames > 180:
			_falhar("não pousou no vestíbulo. y=%.3f" % _jogador.global_position.y)
			_encerrar()

	func _ida() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _sala != "galeria":
			if _frames > 400:
				_falhar("não entrou na galeria. x=%.3f" % _jogador.global_position.x)
				_encerrar()
			return
		_conferir_chegada("galeria", _chegada_galeria, _enquadramento_galeria)
		if _viagem < 3:
			_soltar("direita")
			_frames = 0
			_fase = "parar"
			return
		_trocas_ao_segurar = _trocas
		_frames = 0
		_fase = "segurar"

	func _segurar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _trocas > _trocas_ao_segurar:
			_falhar("segurar a seta trocou de sala outra vez")
			_encerrar()
			return
		if _frames < 20:
			return
		_segurou_sem_segunda = true
		_soltar("direita")
		_frames = 0
		_fase = "parar"

	func _parar() -> void:
		if _frames < 10:
			return
		if not _parado_no_chao():
			if _frames > 90:
				_falhar("não parou na galeria. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
				_encerrar()
			return
		if _sala != "galeria":
			_falhar("parou fora da galeria")
			_encerrar()
			return
		if _viagem == 1:
			_frames = 0
			_fase = "queda"
			return
		_frames = 0
		_pressionar("esquerda")
		_fase = "volta"

	func _queda() -> void:
		_soltar("direita")
		_soltar("esquerda")
		if _queda_armada:
			return
		_queda_armada = true
		_jogador.global_position = Vector3(33.0, 1.0, 0.0)
		_jogador.velocity = Vector3.ZERO
		_frames = 0
		_fase = "esperar_queda"

	func _esperar_queda() -> void:
		var retorno: Vector3 = _retorno_galeria.global_position
		var pos: Vector3 = _jogador.global_position
		if absf(pos.x - retorno.x) < 0.35 and pos.y > 0.4:
			_renasceu_na_galeria = true
		if _renasceu_na_galeria and _jogador.is_on_floor() and absf(pos.y) <= _TOLERANCIA_CHAO_M and absf(pos.x - retorno.x) < 0.35:
			_x_apos_queda = pos.x
			_y_apos_queda = pos.y
			_camera_apos_queda = _camera.global_position.x
			if _camera.global_position.distance_to(_enquadramento_galeria.global_position) > 0.05:
				_falhar("a câmera saiu da galeria depois da queda")
			if absf(pos.x - (-3.2)) < 1.0:
				_falhar("a queda na galeria devolveu ao vestíbulo")
			_frames = 0
			_pressionar("esquerda")
			_fase = "volta"
			return
		if _frames > 240:
			_falhar("a queda não devolveu ao retorno da galeria. pos=%s" % pos)
			_encerrar()

	func _volta() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _sala != "vestibulo":
			if _frames > 400:
				_falhar("não voltou ao vestíbulo. x=%.3f" % _jogador.global_position.x)
				_encerrar()
			return
		_conferir_chegada("vestibulo", _chegada_vestibulo, _enquadramento_vestibulo)
		_soltar("esquerda")
		_frames = 0
		_fase = "parar_volta"

	func _parar_volta() -> void:
		if _frames < 10:
			return
		if not _parado_no_chao():
			if _frames > 90:
				_falhar("não parou no vestíbulo. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
				_encerrar()
			return
		if _sala != "vestibulo":
			_falhar("parou fora do vestíbulo")
			_encerrar()
			return
		if _viagem >= 3:
			_encerrar()
			return
		_viagem += 1
		_frames = 0
		_pressionar("direita")
		_fase = "ida"

	func _conferir_chegada(sala: String, marco: Node3D, enquadramento: Node3D) -> void:
		var dist := _jogador.global_position.distance_to(marco.global_position)
		if dist > 0.8:
			_falhar("chegada de %s longe do marcador: %.3f" % [sala, dist])
		if absf(_jogador.global_position.y) > _TOLERANCIA_CHAO_M:
			_falhar("pés fora do piso em %s. y=%.3f" % [sala, _jogador.global_position.y])
		if absf(_jogador.global_position.z) > 0.001:
			_falhar("Z saiu de 0 em %s" % sala)
		if _camera.global_position.distance_to(enquadramento.global_position) > 0.05:
			_falhar("câmera fora do enquadramento de %s" % sala)

	func _parado_no_chao() -> bool:
		return _jogador.is_on_floor() and absf(_jogador.global_position.y) <= _TOLERANCIA_CHAO_M and absf(_jogador.velocity.x) < 0.05

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("direita")
		_soltar("esquerda")
		if _z_max > 0.001:
			_falhar("Z saiu do plano: |z| máximo %.6f" % _z_max)
		if _trocas != 6:
			_falhar("esperava 6 trocas e mediu %d" % _trocas)
		if not _segurou_sem_segunda:
			_falhar("a terceira ida não segurou a seta depois da troca")
		if not _renasceu_na_galeria:
			_falhar("não reapareceu na galeria")
		if not _correu_direita or not _correu_esquerda:
			_falhar("corrida incompleta direita=%s esquerda=%s" % [_correu_direita, _correu_esquerda])
		if _material == null:
			_falhar("o pilar do vestíbulo não recebeu material próprio")
		elif _alpha_min > 0.5:
			_falhar("o pilar não abriu ao passar. alfa=%.3f" % _alpha_min)
		elif _alpha_longe >= 0.0 and _alpha_longe < 0.99:
			_falhar("o pilar continuou transparente fora da passagem. alfa=%.3f" % _alpha_longe)
		print("MEDICAO trocas=%d segurou=%s queda_x=%.4f queda_y=%.4f camera_queda=%.4f" % [_trocas, _segurou_sem_segunda, _x_apos_queda, _y_apos_queda, _camera_apos_queda])
		print("MEDICAO z_max=%.6f alpha_min=%.3f alpha_longe=%.3f direita=%s esquerda=%s" % [_z_max, _alpha_min, _alpha_longe, _correu_direita, _correu_esquerda])
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
