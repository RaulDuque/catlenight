extends SceneTree

## Mede a travessia do arco com a física e as ações reais. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _ARCO_X := -2.05
	const _MEIA_PASSAGEM := 0.55

	var _jogador: CharacterBody3D
	var _arco: Node3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _entrou := false
	var _y_pes_min := 99.0
	var _y_pes_max := -99.0
	var _z_max := 0.0
	var _x_entrada := 0.0
	var _x_saida := 0.0
	var _x_entrada_volta := 0.0
	var _x_saida_volta := 0.0
	var _voltou := false
	var _caixa := AABB()
	var _caixa_iniciada := false
	var _menor_vao := 99.0
	var _fisica_consultada := false

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/main.tscn") as PackedScene
		var sala := packed.instantiate()
		get_tree().root.add_child(sala)
		_jogador = sala.get_node("Jogador") as CharacterBody3D
		_arco = sala.get_node("ArcoDePedra") as Node3D
		_conferir_malha()
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		if not _fisica_consultada:
			_fisica_consultada = true
			_consultar_fisica()
		_frames += 1
		match _fase:
			"cair":
				_cair()
			"ir":
				_ir()
			"voltar":
				_voltar()
			_:
				_falhar("fase desconhecida")
				_encerrar()

	func _cair() -> void:
		if _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
			_frames = 0
			_pressionar("direita")
			_fase = "ir"
		elif _frames > 180:
			_falhar("não pousou antes da travessia")
			_encerrar()

	func _ir() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not _entrou and x >= _ARCO_X - _MEIA_PASSAGEM:
			_entrou = true
			_x_entrada = x
		if _entrou and x < _ARCO_X + _MEIA_PASSAGEM:
			_y_pes_min = minf(_y_pes_min, y)
			_y_pes_max = maxf(_y_pes_max, y)
			_z_max = maxf(_z_max, absf(_jogador.global_position.z))
			if not _jogador.is_on_floor():
				_falhar("os pés deixaram o chão dentro do arco")
		if _entrou and x >= _ARCO_X + _MEIA_PASSAGEM:
			_x_saida = x
			_soltar("direita")
			_pressionar("esquerda")
			_frames = 0
			_fase = "voltar"
		elif _frames > 240:
			_falhar("não atravessou o arco. x=%.3f" % x)
			_encerrar()

	func _voltar() -> void:
		var x := _jogador.global_position.x
		if _x_entrada_volta == 0.0 and x <= _ARCO_X + _MEIA_PASSAGEM:
			_x_entrada_volta = x
		if not _voltou and x <= _ARCO_X - _MEIA_PASSAGEM:
			_voltou = true
			_x_saida_volta = x
			_y_pes_min = minf(_y_pes_min, _jogador.global_position.y)
			_y_pes_max = maxf(_y_pes_max, _jogador.global_position.y)
			_z_max = maxf(_z_max, absf(_jogador.global_position.z))
			_soltar("esquerda")
			_encerrar()
		elif _frames > 240:
			_falhar("não voltou pelo arco. x=%.3f" % x)
			_encerrar()

	func _conferir_malha() -> void:
		_varrer_malha(_arco.get_node("Visual"))
		print("MEDIDA aabb_pos %s" % _caixa.position)
		print("MEDIDA aabb_size %s" % _caixa.size)
		print("MEDIDA altura_livre_visual_m %.3f" % _menor_vao)
		if _caixa.size.y < 4.0 or _caixa.size.y > 6.0:
			_falhar("escala fora de metros: altura %.3f" % _caixa.size.y)
		if absf(_caixa.position.y) > 0.03:
			_falhar("a base não encosta no piso: y=%.3f" % _caixa.position.y)
		if _menor_vao < 2.3:
			_falhar("vão livre abaixo de 2,3 m: %.3f" % _menor_vao)

	func _varrer_malha(no: Node) -> void:
		if no is MeshInstance3D and (no as MeshInstance3D).mesh != null:
			var malha := no as MeshInstance3D
			var global := malha.global_transform * malha.mesh.get_aabb()
			if not _caixa_iniciada:
				_caixa = global
				_caixa_iniciada = true
			else:
				_caixa = _caixa.merge(global)
			var superficies := malha.mesh.get_surface_count()
			for indice in superficies:
				var material := malha.mesh.surface_get_material(indice) as StandardMaterial3D
				if material != null:
					print(
						"MATERIAL %s albedo %s rugosidade %.2f"
						% [malha.name, material.albedo_color, material.roughness]
					)
				var arrays: Array = malha.mesh.surface_get_arrays(indice)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				for vertice in vertices:
					var mundo: Vector3 = malha.global_transform * vertice
					if absf(mundo.z) > 0.30:
						continue
					if absf(mundo.x - _arco.global_position.x) > 0.45:
						continue
					if mundo.y > 1.2:
						_menor_vao = minf(_menor_vao, mundo.y)
		for filho in no.get_children():
			_varrer_malha(filho)

	func _consultar_fisica() -> void:
		var estado := _jogador.get_world_3d().direct_space_state
		var pilar := _arco.get_node("Colisao/PilarFrente") as CollisionShape3D
		var centro_pilar := pilar.global_position
		var desde_o_corredor := Vector3(centro_pilar.x, centro_pilar.y, 0.0)
		var no_pilar := _raio(estado, desde_o_corredor, centro_pilar)
		if no_pilar.is_empty():
			_falhar("o pilar não foi encontrado pela física")
		else:
			print("MEDIDA raio_pilar %s" % no_pilar.collider)
		var origem := Vector3(_ARCO_X - 0.9, 1.05, 0.0)
		var destino := Vector3(_ARCO_X + 0.9, 1.05, 0.0)
		var no_corredor := _raio(estado, origem, destino)
		if no_corredor.is_empty():
			print("MEDIDA raio_corredor livre")
		else:
			_falhar("o corredor na altura do tronco está bloqueado por %s" % no_corredor.collider)

	func _raio(estado: PhysicsDirectSpaceState3D, de: Vector3, ate: Vector3) -> Dictionary:
		var consulta := PhysicsRayQueryParameters3D.create(de, ate)
		consulta.collide_with_areas = false
		consulta.exclude = [_jogador.get_rid()]
		return estado.intersect_ray(consulta)

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("direita")
		_soltar("esquerda")
		print("MEDIDA x_entrada %.3f" % _x_entrada)
		print("MEDIDA x_saida %.3f" % _x_saida)
		print("MEDIDA x_entrada_volta %.3f" % _x_entrada_volta)
		print("MEDIDA x_saida_volta %.3f" % _x_saida_volta)
		print("MEDIDA pes_y_min %.4f pes_y_max %.4f" % [_y_pes_min, _y_pes_max])
		print("MEDIDA z_max %.6f" % _z_max)
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
