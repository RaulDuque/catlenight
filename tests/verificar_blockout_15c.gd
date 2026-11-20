extends SceneTree

## Percurso, troca de apresentação e matriz do piloto 15-C.
## Não faz parte do jogo.


func _initialize() -> void:
	var driver := Driver.new()
	root.add_child(driver)


class Driver extends Node:
	const _CENA := "res://scenes/verification/15c_blockout_do_prologo.tscn"
	const _DADOS := "res://dados/sala_do_prologo.json"
	var _cena: Node
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _menu: CanvasLayer
	var _apresentacao: Node
	var _gerador: Node
	var _limiar: Node3D
	var _estrado: Node3D
	var _fase := "menu"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _trocas := 0
	var _sala := ""
	var _tempo := 0.0
	var _tempo_limiar := 0.0
	var _andando := false
	var _parado := Vector3.ZERO
	var _passos := 0
	var _camera_parada := 0.0
	var _pes_parados := Vector3.ZERO
	var _texto_original := ""

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
		_apresentacao = _cena.get_node("Apresentacao")
		_gerador = _cena.get_node("EscadariaExterior/SalaDoPrologo")
		_limiar = _cena.get_node("EscadariaExterior/Limiar") as Node3D
		_estrado = _cena.get_node("EscadariaExterior/SalaDoPrologo/ArteManual/Estrado") as Node3D
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if principal != "res://scenes/verification/main.tscn":
			_falhar("o F5 mudou: %s" % principal)
			return
		_pronto = true

	func _physics_process(delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		if _andando:
			_tempo += delta
		_contar_troca()
		match _fase:
			"menu":
				_escolher_menu()
			"nascer":
				_nascer()
			"subir":
				_subir()
			"parar":
				_parar()
			"alternar":
				_alternar()
			"alto":
				_alto()
			"limiar":
				_limiar_fase()
			"trono":
				_trono()
			"voltar":
				_voltar()
			"arte":
				_arte()
			"arte_trono":
				_arte_trono()
			"arte_volta":
				_arte_volta()
			"matriz":
				_matriz()

	func _contar_troca() -> void:
		var sala := _cena.get("sala_atual") as Node3D
		if sala == null:
			return
		if _sala == "":
			_sala = sala.name
			return
		if sala.name != _sala:
			_trocas += 1
			_sala = sala.name

	func _escolher_menu() -> void:
		if not _menu.visible and not get_tree().paused:
			_soltar("pulo")
			_frames = 0
			_fase = "nascer"
			return
		if _frames == 8:
			_pressionar("pulo")
		if _frames == 12:
			_soltar("pulo")
		if _frames > 90:
			_falhar("o menu não fechou")

	func _nascer() -> void:
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.15 and _jogador.global_position.x > -21.2:
			print("MEDICAO nascimento x=%.3f y=%.3f z=%.3f camera_near=%.2f camera_far=%.2f" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
				_camera.near, _camera.far,
			])
			var celula: Dictionary = _gerador.call("descrever_celula", 2, 4)
			print("CELULA simbolo=%s linha=%d coluna=%d x0=%.3f x1=%.3f y_topo=%.3f apoio_x=%.3f apoio_y=%.3f lado=%s" % [
				celula["simbolo"], celula["linha"], celula["coluna"], celula["x0"], celula["x1"],
				celula["y_topo"], celula["apoio"].x, celula["apoio"].y, celula["lado_alto"],
			])
			var rampa := _cena.get_node("EscadariaExterior/SalaDoPrologo/Gerado/Rampa_0_3/Colisao") as CollisionShape3D
			var caixa := rampa.shape as BoxShape3D
			print("RAMPA tamanho x=%.3f y=%.3f z=%.3f corpos=%d" % [caixa.size.x, caixa.size.y, caixa.size.z, _gerador.call("corpos")])
			_andando = true
			_tempo = 0.0
			_ir("subir")
		elif _frames > 180:
			_falhar("não assentou. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _subir() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var x := _jogador.global_position.x
		if _jogador.is_on_floor() and x < -24.2 and x > -25.6 and _jogador.global_position.y > 0.8:
			_ir("parar")
		elif _frames > 400:
			_falhar("não chegou ao meio. x=%.3f y=%.3f" % [x, _jogador.global_position.y])

	func _parar() -> void:
		_soltar("esquerda")
		_soltar("direita")
		if _frames == 6:
			_parado = _jogador.global_position
		if _frames > 6:
			var delta := _jogador.global_position - _parado
			if absf(delta.x) < 0.05 and absf(delta.y) < 0.05 and _jogador.is_on_floor():
				_passos += 1
			else:
				_passos = 0
				_parado = _jogador.global_position
		if _passos >= 20:
			print("MEDICAO parada x=%.3f y=%.3f z=%.3f camera=%.2f" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _camera.global_position.x,
			])
			_pes_parados = _jogador.global_position
			_camera_parada = _camera.global_position.x
			_passos = 0
			_ir("alternar")
		elif _frames > 80:
			_falhar("não ficou parado")

	func _alternar() -> void:
		_soltar("esquerda")
		_soltar("direita")
		if _frames == 2:
			_pressionar("alternar_apresentacao")
		if _frames == 4:
			_soltar("alternar_apresentacao")
		if _frames == 10:
			_conferir_troca(true)
		if _frames == 12:
			_pressionar("alternar_apresentacao")
		if _frames == 14:
			_soltar("alternar_apresentacao")
		if _frames == 20:
			_conferir_troca(false)
			_ir("alto")
		elif _frames > 40:
			_falhar("a troca de apresentação não concluiu")

	func _conferir_troca(arte: bool) -> void:
		if bool(_apresentacao.get("com_arte")) != arte:
			_falhar("a apresentação ficou em %s" % str(_apresentacao.get("com_arte")))
			return
		var delta := _jogador.global_position - _pes_parados
		if absf(delta.x) > 0.04 or absf(delta.y) > 0.04 or not _jogador.is_on_floor():
			_falhar("a troca moveu os pés. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			return
		if absf(_camera.global_position.x - _camera_parada) > 0.02:
			_falhar("a troca moveu a câmera")
			return
		var rampa := _cena.get_node("EscadariaExterior/Lance/Rampa/Colisao") as CollisionShape3D
		if rampa.disabled:
			_falhar("a troca desligou a colisão da rampa")
			return
		print("MEDICAO troca arte=%s x=%.3f y=%.3f camera=%.2f" % [arte, _jogador.global_position.x, _jogador.global_position.y, _camera.global_position.x])

	func _alto() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and _jogador.global_position.x < -27.45 and _jogador.global_position.y > 2.55:
			print("MEDICAO alto x=%.3f y=%.3f z=%.3f trocas=%d" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _trocas,
			])
			_ir("limiar")
		elif _frames > 400:
			_falhar("não chegou ao alto. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _limiar_fase() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and _jogador.global_position.x < _limiar.global_position.x and _jogador.global_position.y > 2.4:
			_tempo_limiar = _tempo
			print("MEDICAO limiar t=%.3f x=%.3f y=%.3f z=%.3f trocas=%d" % [
				_tempo, _jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _trocas,
			])
			_ir("trono")
		elif _frames > 500:
			_falhar("não atravessou o limiar. x=%.3f sala=%s" % [_jogador.global_position.x, _sala])

	func _trono() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var alvo := _estrado.global_position
		if _jogador.is_on_floor() and absf(_jogador.global_position.x - alvo.x) < 0.55 and _jogador.global_position.y > alvo.y - 0.15:
			print("MEDICAO trono t_trecho=%.3f t_total=%.3f x=%.3f y=%.3f z=%.3f" % [
				_tempo - _tempo_limiar, _tempo, _jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z,
			])
			if _trocas != 0:
				_falhar("um gatilho antigo trocou de sala %d vezes" % _trocas)
				return
			_ir("voltar")
		elif _frames > 700:
			_falhar("não chegou ao estrado. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _voltar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.2 and _jogador.global_position.x > -21.3:
			print("MEDICAO volta x=%.3f y=%.3f z=%.3f" % [_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z])
			_pressionar("alternar_apresentacao")
			_ir("arte")
		elif _frames > 900:
			_falhar("não voltou ao patamar. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _arte() -> void:
		_soltar("alternar_apresentacao")
		_soltar("direita")
		if not bool(_apresentacao.get("com_arte")):
			if _frames > 20:
				_falhar("não entrou no modo com arte")
			return
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.global_position.x < _limiar.global_position.x and _jogador.global_position.y > 2.4:
			_ir("arte_trono")
		elif _frames > 700:
			_falhar("a arte não repetiu a subida. x=%.3f" % _jogador.global_position.x)

	func _arte_trono() -> void:
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		var alvo := _estrado.global_position
		if _jogador.is_on_floor() and absf(_jogador.global_position.x - alvo.x) < 0.55 and _jogador.global_position.y > alvo.y - 0.15:
			print("MEDICAO arte_trono x=%.3f y=%.3f z=%.3f" % [_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z])
			_ir("arte_volta")
		elif _frames > 700:
			_falhar("a arte não chegou ao estrado. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _arte_volta() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.2 and _jogador.global_position.x > -21.3:
			print("MEDICAO arte_volta x=%.3f y=%.3f z=%.3f trocas=%d" % [
				_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _trocas,
			])
			_ir("matriz")
		elif _frames > 900:
			_falhar("a arte não voltou. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _matriz() -> void:
		_soltar("direita")
		_texto_original = FileAccess.get_file_as_string(_DADOS)
		var antes := int(_gerador.call("corpos"))
		var ruim := _texto_original.replace("###/##########", "###?##########")
		_gravar_dados(ruim)
		var erro := str(_gerador.call("gerar"))
		_gravar_dados(_texto_original)
		_gerador.call("gerar")
		if not erro.contains("linha 2, coluna 4"):
			_falhar("o símbolo ruim não apontou a célula. %s" % erro)
			return
		var base := int(_gerador.call("corpos"))
		if base != antes:
			_falhar("restaurar a matriz não devolveu %d corpos, ficou %d" % [antes, base])
			return
		var passo := _texto_original.replace("###...........", "###......#....")
		_gravar_dados(passo)
		_gerador.call("gerar")
		var com_degrau := int(_gerador.call("corpos"))
		var degrau := _cena.get_node_or_null("EscadariaExterior/SalaDoPrologo/Gerado/Piso_1_9") as StaticBody3D
		if degrau == null:
			_gravar_dados(_texto_original)
			_gerador.call("gerar")
			_falhar("a célula nova não criou Piso_1_9")
			return
		var caixa := (degrau.get_node("Colisao") as CollisionShape3D).shape as BoxShape3D
		var degrau_x := degrau.position.x
		var degrau_y := degrau.position.y
		var degrau_tamanho := caixa.size.x
		_gerador.call("gerar")
		var repetido := int(_gerador.call("corpos"))
		var ainda := _cena.get_node_or_null("EscadariaExterior/SalaDoPrologo/Gerado/Piso_1_9") != null
		_gravar_dados(_texto_original)
		_gerador.call("gerar")
		var restaurado := int(_gerador.call("corpos"))
		print("MEDICAO matriz antes=%d degrau=%d repetido=%d restaurado=%d x=%.3f y=%.3f tamanho=%.3f ainda=%s" % [
			base, com_degrau, repetido, restaurado, degrau_x, degrau_y, degrau_tamanho, ainda,
		])
		if com_degrau != base + 1 or repetido != com_degrau or restaurado != base or not ainda:
			_falhar("a geração duplicou ou não restaurou. %d %d %d %d" % [base, com_degrau, repetido, restaurado])
			return
		if absf(_jogador.global_position.z) > 0.001:
			_falhar("o corpo saiu de Z = 0")
			return
		print("RESULTADO ok")
		_encerrado = true
		get_tree().quit(0)

	func _gravar_dados(texto: String) -> void:
		var arquivo := FileAccess.open(_DADOS, FileAccess.WRITE)
		arquivo.store_string(texto)
		arquivo.close()

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_frames = 0
		_passos = 0
		_fase = proxima

	func _falhar(mensagem: String) -> void:
		if _texto_original != "":
			_gravar_dados(_texto_original)
			_gerador.call("gerar")
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
