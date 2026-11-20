extends SceneTree

## Percurso contínuo da estrutura 15-D. Não faz parte do jogo.


func _initialize() -> void:
	var driver := Driver.new()
	root.add_child(driver)


class Driver extends Node:
	const _CENA := "res://scenes/verification/15d_estrutura_completa_do_prologo.tscn"
	var _cena: Node
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _menu: CanvasLayer
	var _fase := "menu"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _tempo := 0.0
	var _marcos := {}
	var _z_max := 0.0
	var _impulso := 0.0
	var _segurou := 0.0
	var _pulou := false
	var _salto_do_vao := false
	var _pista := false
	var _segurar_pulo := 0

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		_cena = (load(_CENA) as PackedScene).instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer
		if str(ProjectSettings.get_setting("application/run/main_scene")) != "res://scenes/verification/main.tscn":
			_falhar("o F5 mudou")
			return
		_pronto = true

	func _physics_process(delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		if _fase != "menu":
			_tempo += delta
			_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		match _fase:
			"menu":
				_escolher_menu()
			"nascer":
				_nascer()
			"subir":
				_ate(-22.7, 0.7, 2.0, "meio", "parar")
			"parar":
				_parar()
			"alto":
				_ate(-25.2, 2.5, 99.0, "alto", "descer")
			"descer":
				_descer()
			"trono":
				_ate_trono()
			"parede":
				_parede(delta)
			"acesso":
				_ate_acesso()
			"galeria":
				_galeria()
			"esquerda":
				_extremo(-42.6, "esquerda", "direita")
			"direita":
				_extremo_direita()
			"voltar":
				_voltar()

	func _escolher_menu() -> void:
		if not _menu.visible and not get_tree().paused:
			_soltar("pulo")
			_ir("nascer")
			return
		if _frames == 8:
			_pressionar("pulo")
		if _frames == 12:
			_soltar("pulo")
		if _frames > 90:
			_falhar("menu")

	func _nascer() -> void:
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.15:
			_marca("nascimento")
			_ir("subir")
		elif _frames > 180:
			_falhar("nascimento")

	func _ate(x_limite: float, y_min: float, y_max: float, nome: String, proxima: String) -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		_vigiar_impulso()
		var p := _jogador.global_position
		if _jogador.is_on_floor() and p.x < x_limite and p.y > y_min and p.y < y_max:
			_marca(nome)
			_ir(proxima)
		elif _frames > 500:
			_falhar("%s x=%.2f y=%.2f" % [nome, p.x, p.y])

	func _parar() -> void:
		_soltar("esquerda")
		_soltar("direita")
		if _frames > 25 and _jogador.is_on_floor() and absf(_jogador.velocity.x) < 0.05:
			_marca("parada")
			var superficie := _superficie_exterior(_jogador.global_position.x)
			print("SOLA pes=%.3f superficie=%.3f folga=%.3f" % [_jogador.global_position.y, superficie, _jogador.global_position.y - superficie])
			_ir("alto")
		elif _frames > 80:
			_falhar("parada")

	func _descer() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_vigiar_impulso()
		var p := _jogador.global_position
		if _jogador.is_on_floor() and p.y < 0.15 and p.x > -21.1:
			_marca("desceu")
			_ir("trono")
		elif _frames > 700:
			_falhar("descer x=%.2f y=%.2f" % [p.x, p.y])

	func _ate_trono() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var p := _jogador.global_position
		if _jogador.is_on_floor() and p.x < -47.2 and p.y > 2.9:
			_marca("trono")
			_segurou = 0.0
			_pulou = false
			_ir("parede")
		elif _frames > 900:
			_falhar("trono x=%.2f y=%.2f" % [p.x, p.y])

	func _parede(delta: float) -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		_segurou += delta
		if not _pulou and _segurou > 0.4:
			_pressionar("pulo")
			_pulou = true
		if _pulou and _segurou > 0.6:
			_soltar("pulo")
		var p := _jogador.global_position
		if p.x < -48.7 or p.y < 2.4 or p.x > -30.0:
			_falhar("parede x=%.2f y=%.2f" % [p.x, p.y])
			return
		if _segurou >= 2.0 and _jogador.is_on_floor() and p.y > 2.9:
			_marca("parede")
			_teto("salao", Vector3(-46.5, 4.3, 0.0))
			_ir("acesso")
		elif _frames > 200:
			_falhar("parede tempo")

	func _ate_acesso() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		var p := _jogador.global_position
		if p.x > -32.2 and p.x < -31.0 and _jogador.is_on_floor() and p.y < 3.2:
			_soltar("direita")
			if _frames > 8:
				_pressionar("interagir")
			if p.y > 5.3:
				_soltar("interagir")
				_marca("escada")
				_ir("galeria")
		elif p.y > 5.3:
			_soltar("interagir")
			_marca("escada")
			_ir("galeria")
		elif _frames > 700:
			_falhar("acesso x=%.2f y=%.2f" % [p.x, p.y])

	func _galeria() -> void:
		_soltar("interagir")
		_soltar("direita")
		_pressionar("esquerda")
		var p := _jogador.global_position
		if _jogador.is_on_floor() and p.y > 6.0 and p.x < -33.8:
			_teto("galeria", p + Vector3(0, 1.6, 0))
			_marca("galeria")
			_ir("esquerda")
		elif _frames > 900:
			_falhar("galeria x=%.2f y=%.2f" % [p.x, p.y])

	func _extremo(limite: float, nome: String, proxima: String) -> void:
		var p := _jogador.global_position
		if p.y < 5.5:
			_falhar("%s caiu x=%.2f y=%.2f" % [nome, p.x, p.y])
			return
		_soltar("pulo")
		_soltar("direita")
		_pressionar("esquerda")
		if _jogador.is_on_floor() and p.x < limite and p.y > 6.0:
			_marca(nome)
			_salto_do_vao = false
			_pista = false
			_ir(proxima)
		elif _frames > 500:
			_falhar("%s x=%.2f y=%.2f" % [nome, p.x, p.y])

	func _extremo_direita() -> void:
		var p := _jogador.global_position
		if p.y < 5.5:
			_falhar("direita caiu x=%.2f y=%.2f" % [p.x, p.y])
			return
		if not _pista:
			if p.x > -42.5:
				_pressionar("esquerda")
				_soltar("direita")
				_soltar("pulo")
				return
			_pista = true
		if true:
			_soltar("esquerda")
			_pressionar("direita")
			if not _salto_do_vao and _jogador.is_on_floor() and p.x > -34.55 and _jogador.velocity.x > 3.0:
				_pressionar("pulo")
				_salto_do_vao = true
				_segurar_pulo = 8
			elif _segurar_pulo > 0:
				_segurar_pulo -= 1
			else:
				_soltar("pulo")
		if _jogador.is_on_floor() and p.x > -25.2 and p.y > 6.0:
			_marca("direita")
			_ir("voltar")
		elif _frames > 500:
			_falhar("direita x=%.2f y=%.2f" % [p.x, p.y])

	func _voltar() -> void:
		var p := _jogador.global_position
		if _frames > 700:
			_falhar("voltar x=%.2f y=%.2f" % [p.x, p.y])
			return
		if not _pista:
			if p.x > -33.5:
				_soltar("direita")
				_pressionar("esquerda")
				return
			_pista = true
		_soltar("esquerda")
		if p.y > 5.85:
			_pressionar("direita")
			return
		_soltar("direita")
		if p.y > 5.5 and p.y < 6.1 and p.x > -33.0 and p.x < -31.2 and _jogador.is_on_floor():
			if _frames > 6:
				_pressionar("interagir")
		if p.y < 3.0 and p.y > 2.4:
			_soltar("interagir")
			_marca("voltou")
			print("IMPULSO max_vy_no_chao=%.3f z_max=%.4f" % [_impulso, _z_max])
			print("RESULTADO ok")
			_encerrado = true
			get_tree().quit(0)
		elif _frames > 700:
			_falhar("voltar x=%.2f y=%.2f" % [p.x, p.y])

	func _superficie_exterior(x: float) -> float:
		var x0 := -21.2
		var x1 := -24.32
		var t := clampf((x - x0) / (x1 - x0), 0.0, 1.0)
		return lerpf(0.0, 2.64, t)

	func _teto(nome: String, origem: Vector3) -> void:
		var estado := _jogador.get_world_3d().direct_space_state
		var consulta := PhysicsRayQueryParameters3D.create(origem, origem + Vector3(0, 12, 0))
		consulta.exclude = [_jogador.get_rid()]
		var golpe := estado.intersect_ray(consulta)
		if golpe.is_empty():
			print("TETO %s sem_contato" % nome)
			return
		print("TETO %s y=%.3f distancia=%.3f" % [nome, golpe.position.y, origem.distance_to(golpe.position)])

	func _vigiar_impulso() -> void:
		if _jogador.is_on_floor():
			_impulso = maxf(_impulso, absf(_jogador.velocity.y))

	func _marca(nome: String) -> void:
		var p := _jogador.global_position
		_marcos[nome] = p
		print("MEDICAO %s t=%.3f x=%.3f y=%.3f z=%.3f chao=%s camera=%.2f,%.2f" % [
			nome, _tempo, p.x, p.y, p.z, _jogador.is_on_floor(), _camera.global_position.x, _camera.global_position.y,
		])

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("interagir")
		_pista = false
		_salto_do_vao = false
		_segurar_pulo = 0
		_frames = 0
		_fase = proxima

	func _falhar(mensagem: String) -> void:
		print("FALHA " + mensagem)
		_encerrado = true
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
