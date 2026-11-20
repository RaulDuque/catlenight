extends SceneTree

## Confere a altura importada e a virada do nó Visual. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	var _jogador: CharacterBody3D
	var _visual: Node3D
	var _colisao: CollisionShape3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _x_marca := 0.0
	var _caixa := AABB()
	var _caixa_iniciada := false
	var _sola := 99.0

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var sala := (load("res://scenes/verification/main.tscn") as PackedScene).instantiate()
		get_tree().root.add_child(sala)
		_jogador = sala.get_node("Jogador") as CharacterBody3D
		_visual = _jogador.get_node("Visual") as Node3D
		_colisao = _jogador.get_node("Colisao") as CollisionShape3D
		_medir_modelo()
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		match _fase:
			"cair":
				_cair()
			"direita":
				_andar("direita", 0.0)
			"parado_direita":
				_parar(0.0, "esquerda")
			"esquerda":
				_andar("esquerda", PI)
			"parado_esquerda":
				_parar(PI, "pulo")
			"pulo":
				_pulo()
			_:
				_falhar("fase desconhecida")
				_encerrar()

	func _cair() -> void:
		if _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
			_conferir_sola()
			_frames = 0
			_x_marca = _jogador.global_position.x
			_pressionar("direita")
			_fase = "direita"
		elif _frames > 180:
			_falhar("não pousou")
			_encerrar()

	func _andar(acao: String, rotacao: float) -> void:
		if _frames < 10:
			return
		_conferir_orientacao(rotacao)
		var dx := _jogador.global_position.x - _x_marca
		if acao == "direita" and dx <= 0.2:
			_falhar("direita não avançou: dx=%.3f" % dx)
		if acao == "esquerda" and dx >= -0.2:
			_falhar("esquerda não recuou: dx=%.3f" % dx)
		_soltar(acao)
		_frames = 0
		_x_marca = _jogador.global_position.x
		_fase = "parado_direita" if acao == "direita" else "parado_esquerda"

	func _parar(rotacao: float, proxima: String) -> void:
		if _frames == 3:
			_x_marca = _jogador.global_position.x
		if _frames < 12:
			return
		_conferir_orientacao(rotacao)
		if absf(_jogador.global_position.x - _x_marca) > 0.02:
			_falhar("soltar a tecla não parou o corpo")
		_frames = 0
		_x_marca = _jogador.global_position.x
		_pressionar(proxima)
		_fase = "esquerda" if proxima == "esquerda" else "pulo"

	func _pulo() -> void:
		if _frames < 6:
			return
		if _jogador.is_on_floor():
			_falhar("o pulo parado não tirou os pés do chão")
		_conferir_orientacao(PI)
		if absf(_jogador.rotation.y) > 0.001:
			_falhar("o corpo físico girou")
		_soltar("pulo")
		_encerrar()

	func _conferir_orientacao(rotacao: float) -> void:
		if absf(wrapf(_visual.rotation.y - rotacao, -PI, PI)) > 0.01:
			_falhar("Visual não ficou na rotação %.3f: %.3f" % [rotacao, _visual.rotation.y])
		if absf(_visual.global_position.x - _jogador.global_position.x) > 0.001:
			_falhar("a virada deslocou Visual em X")
		if absf(_visual.global_position.z) > 0.001:
			_falhar("Visual saiu de Z = 0")
		var base := _colisao.global_transform.basis
		if not base.is_equal_approx(Basis.IDENTITY):
			_falhar("a colisão girou com o modelo")

	func _medir_modelo() -> void:
		_varrer(_visual)
		print("MEDIDA aabb_pos %s" % _caixa.position)
		print("MEDIDA aabb_size %s" % _caixa.size)
		var altura := _caixa.position.y + _caixa.size.y
		print("MEDIDA altura_importada_m %.4f" % altura)
		print("MEDIDA sola_importada_y %.4f" % _caixa.position.y)
		print("MEDIDA escala_visual %s" % _visual.scale)
		if altura < 1.65 or altura > 1.75:
			_falhar("altura importada fora de 1,70 m: %.3f" % altura)
		if absf(_caixa.position.y) > 0.02:
			_falhar("a sola não encosta na origem: y=%.3f" % _caixa.position.y)

	func _varrer(no: Node) -> void:
		if no is MeshInstance3D and (no as MeshInstance3D).mesh != null:
			var malha := no as MeshInstance3D
			var global := _jogador.global_transform.affine_inverse() * malha.global_transform * malha.mesh.get_aabb()
			if not _caixa_iniciada:
				_caixa = global
				_caixa_iniciada = true
			else:
				_caixa = _caixa.merge(global)
		for filho in no.get_children():
			_varrer(filho)

	func _conferir_sola() -> void:
		_sola = 99.0
		_menor_vertice(_visual)
		_sola -= _jogador.global_position.y
		print("MEDIDA sola_no_chao_y %.4f" % _sola)
		if absf(_sola) > 0.02:
			_falhar("a sola de apoio não tocou o piso: %.3f" % _sola)

	func _menor_vertice(no: Node) -> void:
		if no is MeshInstance3D and (no as MeshInstance3D).mesh != null:
			var malha := no as MeshInstance3D
			var superficies := malha.mesh.get_surface_count()
			for indice in superficies:
				var arrays: Array = malha.mesh.surface_get_arrays(indice)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				for vertice in vertices:
					var ponto: Vector3 = malha.global_transform * vertice
					_sola = minf(_sola, ponto.y)
		for filho in no.get_children():
			_menor_vertice(filho)

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("direita")
		_soltar("esquerda")
		_soltar("pulo")
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
