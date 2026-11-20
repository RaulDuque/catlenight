extends SceneTree

## Confere a travessia e a transparência na cena do piloto. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	var _sala: Node3D
	var _jogador: CharacterBody3D
	var _pilar: Node3D
	var _material: StandardMaterial3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _falhas: PackedStringArray = []
	var _z_max := 0.0
	var _alpha_no_pilar := 1.0
	var _alpha_fora := 0.0
	var _x_plataforma := 0.0
	var _y_plataforma := 0.0
	var _passou := false
	var _corredor_livre := false
	var _pilar_solido := false

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		_sala = (load("res://scenes/verification/04c_corrida_mixamo.tscn") as PackedScene).instantiate()
		get_tree().root.add_child(_sala)
		_jogador = _sala.get_node("Jogador") as CharacterBody3D
		_pilar = _sala.get_node("ArcoDePedra/Colisao/PilarFrente") as Node3D
		var malha := _sala.get_node("ArcoDePedra/Visual/ArcoDePedra/PilarFrente2") as MeshInstance3D
		_material = malha.get_surface_override_material(0) as StandardMaterial3D
		_conferir_raios()
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if not _pronto:
			return
		_frames += 1
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		match _fase:
			"cair":
				if _jogador.is_on_floor():
					_pressionar("direita")
					_fase = "direita"
					_frames = 0
			"direita":
				_direita()
			"parado":
				_parado()
			"esquerda":
				_esquerda()
			"pulo":
				_pulo()
			"ar":
				if _jogador.is_on_floor() and _jogador.global_position.y > 0.45:
					_x_plataforma = _jogador.global_position.x
					_y_plataforma = _jogador.global_position.y
					_soltar("direita")
					_soltar("pulo")
					_encerrar()
				elif _frames > 180:
					_falhar("não pousou na plataforma")
					_encerrar()

	func _direita() -> void:
		var distancia := absf(_jogador.global_position.x - _pilar.global_position.x)
		if distancia <= 0.3:
			_alpha_no_pilar = minf(_alpha_no_pilar, _material.albedo_color.a)
			if _jogador.global_position.x > _pilar.global_position.x:
				_passou = true
		if _jogador.global_position.x > _pilar.global_position.x + 0.9:
			_soltar("direita")
			_frames = 0
			_fase = "parado"
		elif _frames > 240:
			_falhar("não atravessou o arco para a direita")
			_encerrar()

	func _parado() -> void:
		if _frames < 8:
			return
		_alpha_fora = _material.albedo_color.a
		if _jogador.velocity.length() > 0.05:
			_falhar("não parou junto ao arco")
		_pressionar("esquerda")
		_frames = 0
		_fase = "esquerda"

	func _esquerda() -> void:
		var distancia := absf(_jogador.global_position.x - _pilar.global_position.x)
		if distancia <= 0.3:
			_alpha_no_pilar = minf(_alpha_no_pilar, _material.albedo_color.a)
		if _jogador.global_position.x < _pilar.global_position.x - 0.8:
			_soltar("esquerda")
			_pressionar("direita")
			_frames = 0
			_fase = "pulo"
		elif _frames > 240:
			_falhar("não voltou pela passagem")
			_encerrar()

	func _pulo() -> void:
		if _jogador.global_position.x >= -1.5 and _jogador.is_on_floor() and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if not _jogador.is_on_floor() and _jogador.velocity.y > 0.0:
			_frames = 0
			_fase = "ar"
		elif _frames > 240:
			_falhar("não pulou para a plataforma")
			_encerrar()

	func _conferir_raios() -> void:
		var espaco := _jogador.get_world_3d().direct_space_state
		var corredor := PhysicsRayQueryParameters3D.create(Vector3(-2.8, 1.0, 0.0), Vector3(-0.5, 1.0, 0.0))
		corredor.collide_with_areas = false
		var livre := espaco.intersect_ray(corredor)
		_corredor_livre = livre.is_empty()
		if not _corredor_livre:
			print("RAIO corredor %s" % livre)
		var origem := _pilar.global_position + Vector3(0.0, 0.2, 0.4)
		var pedra := PhysicsRayQueryParameters3D.create(origem, _pilar.global_position)
		var acerto := espaco.intersect_ray(pedra)
		_pilar_solido = not acerto.is_empty()

	func _encerrar() -> void:
		print("MEDICAO alpha_no_pilar=%.3f alpha_fora=%.3f" % [_alpha_no_pilar, _alpha_fora])
		print("MEDICAO passou=%s corredor_livre=%s pilar_solido=%s" % [_passou, _corredor_livre, _pilar_solido])
		print("MEDICAO plataforma x=%.4f y=%.4f z_max=%.6f" % [_x_plataforma, _y_plataforma, _z_max])
		var caminhada: float = _jogador.get("velocidade_caminhada_m_por_s")
		var pulo: float = _jogador.get("velocidade_inicial_do_pulo_m_por_s")
		var animacao: float = _jogador.get("velocidade_da_animacao")
		print("MEDICAO velocidades caminhada=%.2f pulo=%.2f animacao=%.2f" % [caminhada, pulo, animacao])
		if not _passou:
			_falhar("o corpo não passou do pilar")
		if _alpha_no_pilar > 0.5:
			_falhar("o pilar não ficou transparente na passagem")
		if _alpha_fora < 0.99:
			_falhar("a pedra não voltou a ficar opaca fora da passagem")
		if not _corredor_livre:
			_falhar("o vão em Z = 0 está bloqueado")
		if not _pilar_solido:
			_falhar("a colisão do pilar dianteiro sumiu")
		if _z_max > 0.001:
			_falhar("Z saiu do plano")
		if absf(caminhada - 3.5) > 0.01 or absf(pulo - 5.5) > 0.01 or absf(animacao - 1.3) > 0.01:
			_falhar("as velocidades mudaram")
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
