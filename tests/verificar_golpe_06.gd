extends SceneTree

## Golpe na cena 06, com a ação atacar e a física do jogador. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _X_ESQUERDA := 28.8
	const _X_DIREITA := 30.5
	const _X_LONGE := 27.95
	const _X_CANCELAR := 18.9

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _visual: Node3D
	var _lamina: MeshInstance3D
	var _area: Area3D
	var _boneco: Node3D
	var _camera: Camera3D
	var _animacao: AnimationPlayer
	var _retorno_galeria: Node3D
	var _enquadramento_galeria: Node3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _z_max := 0.0
	var _x_marca := 0.0
	var _pico_pulo := 0.0
	var _colocado := false
	var _viu_lamina := false
	var _acertos_antes := 0
	var _correu := false
	var _andou_direita := false
	var _andou_esquerda := false
	var _pulou := false
	var _um_jogador := false
	var _quadros_esquerda := 0
	var _quadros_direita := 0
	var _segurou_um := false
	var _segundo_toque := false
	var _golpe_encerrado_na_troca := false
	var _renasceu_na_galeria := false
	var _alcance_maior_acertou := false
	var _longe_errou := false

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/06_primeiro_golpe.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_visual = _jogador.get_node("Visual") as Node3D
		_lamina = _jogador.get_node("Golpe/Lamina") as MeshInstance3D
		_area = null
		_boneco = _cena.get_node("Galeria/BonecoDeTreino") as Node3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_retorno_galeria = _cena.get_node("Galeria/Retorno") as Node3D
		_enquadramento_galeria = _cena.get_node("Galeria/Enquadramento") as Node3D
		_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
		var corpos := _cena.find_children("*", "CharacterBody3D", true, false)
		_um_jogador = corpos.size() == 1
		if not _um_jogador:
			_falhar("havia %d jogadores" % corpos.size())
		if _animacao == null:
			_falhar("a corrida não entrou no piloto")
		var anda: float = _jogador.get("velocidade_caminhada_m_por_s")
		var pulo: float = _jogador.get("velocidade_inicial_do_pulo_m_por_s")
		var anim: float = _jogador.get("velocidade_da_animacao")
		var alcance: float = _jogador.get("alcance_do_golpe_m")
		print("MEDICAO velocidades anda=%.2f pulo=%.2f anim=%.2f alcance=%.2f" % [anda, pulo, anim, alcance])
		print("MEDICAO boneco_x=%.3f chegada_x=%.3f retorno_x=%.3f" % [
			_boneco.global_position.x,
			_cena.get_node("Galeria/ChegadaEsquerda").global_position.x,
			_retorno_galeria.global_position.x,
		])
		if absf(anda - 3.5) > 0.01 or absf(pulo - 5.5) > 0.01 or absf(anim - 1.3) > 0.01:
			_falhar("velocidades alteradas")
		if absf(alcance - 1.15) > 0.01:
			_falhar("alcance inicial %.2f" % alcance)
		_marcar_livre("ChegadaEsquerda", 1.5)
		_marcar_livre("Retorno", 1.5)
		_marcar_livre("SaidaEsquerda", 2.0)
		var plataforma := _cena.get_node("Galeria/Plataforma") as Node3D
		if absf(_boneco.global_position.x - plataforma.global_position.x) < 2.6:
			_falhar("o boneco cobre a plataforma")
		_pronto = true

	func _marcar_livre(nome: String, minimo: float) -> void:
		var marco := _cena.get_node("Galeria/%s" % nome) as Node3D
		var distancia := absf(_boneco.global_position.x - marco.global_position.x)
		print("MEDICAO folga_%s=%.3f" % [nome, distancia])
		if distancia < minimo:
			_falhar("boneco perto de %s: %.3f" % [nome, distancia])

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		if _area == null:
			_area = get_tree().get_first_node_in_group("area_do_golpe") as Area3D
			if _area == null:
				return
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		if _frames > 3600:
			_falhar("tempo esgotado na fase %s" % _fase)
			_encerrar()
			return
		match _fase:
			"cair":
				_cair()
			"direita":
				_direita()
			"esquerda":
				_esquerda_anda()
			"pulo":
				_pulo()
			"ir_galeria":
				_ir_galeria()
			"acerto_esquerda":
				_colocar_e_golpear(_X_ESQUERDA, true, "medir_esquerda")
			"medir_esquerda":
				_medir_acerto("esquerda", "acerto_direita")
			"acerto_direita":
				_colocar_e_golpear(_X_DIREITA, false, "medir_direita")
			"medir_direita":
				_medir_acerto("direita", "costas")
			"costas":
				_colocar_e_golpear(_X_ESQUERDA, false, "medir_costas")
			"medir_costas":
				_medir_erro("costas", "longe")
			"longe":
				_colocar_e_golpear(_X_LONGE, true, "medir_longe")
			"medir_longe":
				_medir_erro("longe", "alcance_maior")
			"alcance_maior":
				_alcance_maior()
			"medir_alcance":
				_medir_acerto("alcance_maior", "segurar")
			"segurar":
				_segurar()
			"segurar_espera":
				_segurar_espera()
			"segundo":
				_segundo()
			"medir_segundo":
				_medir_acerto("segundo", "cancelar")
			"cancelar":
				_cancelar()
			"cancelar_anda":
				_cancelar_anda()
			"voltar":
				_voltar()
			"queda":
				_queda()
			"queda_no_ar":
				_queda_no_ar()
			_:
				_falhar("fase desconhecida %s" % _fase)
				_encerrar()

	func _cair() -> void:
		if _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
			_x_marca = _jogador.global_position.x
			_frames = 0
			_pressionar("direita")
			_fase = "direita"
		elif _frames > 180:
			_falhar("não pousou")
			_encerrar()

	func _direita() -> void:
		if _frames < 18:
			_observar_corrida(true)
			return
		if _jogador.global_position.x - _x_marca <= 0.4:
			_falhar("não andou para a direita")
		if absf(_visual.rotation.y) > 0.05:
			_falhar("não virou para +X")
		_andou_direita = true
		_soltar("direita")
		_x_marca = _jogador.global_position.x
		_frames = 0
		_pressionar("esquerda")
		_fase = "esquerda"

	func _esquerda_anda() -> void:
		if _frames < 18:
			_observar_corrida(false)
			return
		if _jogador.global_position.x - _x_marca >= -0.4:
			_falhar("não andou para a esquerda")
		if absf(_visual.rotation.y - PI) > 0.05:
			_falhar("não virou para -X")
		_andou_esquerda = true
		_soltar("esquerda")
		_frames = 0
		_pico_pulo = _jogador.global_position.y
		_pressionar("pulo")
		_fase = "pulo"

	func _pulo() -> void:
		_pico_pulo = maxf(_pico_pulo, _jogador.global_position.y)
		if _frames == 6:
			_soltar("pulo")
		if _frames > 12 and _jogador.is_on_floor():
			if _pico_pulo > 0.8:
				_pulou = true
			else:
				_falhar("o pulo subiu pouco: %.3f" % _pico_pulo)
			_frames = 0
			_pressionar("direita")
			_fase = "ir_galeria"
		elif _frames > 180:
			_falhar("não pousou depois do pulo")
			_encerrar()

	func _ir_galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 12.0:
			_soltar("direita")
			if _camera.global_position.distance_to(_enquadramento_galeria.global_position) > 0.05:
				_falhar("câmera fora da galeria na chegada")
			_frames = 0
			_fase = "acerto_esquerda"
		elif _frames > 500:
			_falhar("não atravessou para a galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

	func _colocar_e_golpear(x: float, direita: bool, seguinte: String) -> void:
		if not _no_lugar(x, direita):
			return
		_acertos_antes = int(_boneco.get("acertos"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = seguinte

	func _medir_acerto(nome: String, seguinte: String) -> void:
		_observar_lamina()
		if _viu_lamina:
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("golpe de %s não terminou" % nome)
				_encerrar()
			return
		_soltar("atacar")
		var agora: int = _boneco.get("acertos")
		var deste: int = _jogador.get("acertos_deste_golpe")
		var quadros: int = _jogador.get("quadros_sobre_o_alvo")
		print("MEDICAO acerto_%s total=%d deste=%d quadros=%d lamina=%s" % [nome, agora, deste, quadros, _viu_lamina])
		if agora != _acertos_antes + 1 or deste != 1:
			_falhar("%s contou %d neste golpe, total %d, antes %d" % [nome, deste, agora, _acertos_antes])
		if not _viu_lamina:
			_falhar("%s não mostrou a lâmina" % nome)
		if nome == "esquerda":
			_quadros_esquerda = quadros
			if quadros < 2:
				_falhar("contato da esquerda durou %d quadro" % quadros)
		elif nome == "direita":
			_quadros_direita = quadros
		elif nome == "alcance_maior":
			_alcance_maior_acertou = true
			_jogador.set("alcance_do_golpe_m", 1.15)
		elif nome == "segurar":
			_segurou_um = true
		elif nome == "segundo":
			_segundo_toque = true
		_frames = 0
		_colocado = false
		_fase = seguinte

	func _medir_erro(nome: String, seguinte: String) -> void:
		_observar_lamina()
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("golpe de %s não terminou" % nome)
				_encerrar()
			return
		_soltar("atacar")
		var agora: int = _boneco.get("acertos")
		var deste: int = _jogador.get("acertos_deste_golpe")
		print("MEDICAO erro_%s total=%d deste=%d lamina=%s" % [nome, agora, deste, _viu_lamina])
		if agora != _acertos_antes or deste != 0:
			_falhar("%s alterou a contagem: deste %d total %d antes %d" % [nome, deste, agora, _acertos_antes])
		if not _viu_lamina:
			_falhar("%s não mostrou a lâmina" % nome)
		if nome == "longe":
			_longe_errou = true
		_frames = 0
		_colocado = false
		_fase = seguinte

	func _alcance_maior() -> void:
		if not _no_lugar(_X_LONGE, true):
			return
		_jogador.set("alcance_do_golpe_m", 1.55)
		_acertos_antes = int(_boneco.get("acertos"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = "medir_alcance"

	func _segurar() -> void:
		if not _no_lugar(_X_ESQUERDA, true):
			return
		_acertos_antes = int(_boneco.get("acertos"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = "segurar_espera"

	func _segurar_espera() -> void:
		_observar_lamina()
		if not Input.is_action_pressed("atacar"):
			_pressionar("atacar")
		if _frames < 55 or not _viu_lamina:
			if _frames > 100:
				_falhar("segurar não mostrou a lâmina")
				_encerrar()
			return
		if _lamina.visible or _area.monitoring:
			if _frames > 100:
				_falhar("segurar não terminou o golpe")
				_encerrar()
			return
		var agora: int = _boneco.get("acertos")
		var deste: int = _jogador.get("acertos_deste_golpe")
		print("MEDICAO segurar total=%d deste=%d lamina=%s" % [agora, deste, _viu_lamina])
		if agora != _acertos_antes + 1 or deste != 1:
			_falhar("segurar contou %d neste golpe, total %d, antes %d" % [deste, agora, _acertos_antes])
		_segurou_um = true
		_soltar("atacar")
		_frames = 0
		_colocado = false
		_fase = "segundo"

	func _segundo() -> void:
		_soltar("atacar")
		if _frames < 8:
			return
		if not _no_lugar(_X_ESQUERDA, true):
			return
		_acertos_antes = int(_boneco.get("acertos"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = "medir_segundo"

	func _cancelar() -> void:
		if not _no_lugar(_X_CANCELAR, false):
			return
		_pressionar("atacar")
		_acertos_antes = int(_boneco.get("acertos"))
		_viu_lamina = false
		_frames = 0
		_fase = "cancelar_anda"

	func _cancelar_anda() -> void:
		_observar_lamina()
		if _viu_lamina and not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _viu_lamina and _jogador.global_position.x < 12.0:
			var lamina_sumiu := not _lamina.visible and not _area.monitoring
			var agora: int = _boneco.get("acertos")
			print("MEDICAO troca x=%.3f camera_x=%.3f lamina_sumiu=%s acertos=%d" % [
				_jogador.global_position.x, _camera.global_position.x, lamina_sumiu, agora,
			])
			if not lamina_sumiu:
				_falhar("a troca deixou o golpe ativo")
			if agora != _acertos_antes:
				_falhar("a troca mudou os acertos")
			if _camera.global_position.x > 5.0:
				_falhar("a câmera não voltou ao vestíbulo")
			_golpe_encerrado_na_troca = true
			_soltar("esquerda")
			_soltar("atacar")
			_frames = 0
			_pressionar("direita")
			_fase = "voltar"
			return
		if _frames > 200:
			_falhar("não trocou de sala durante o golpe. x=%.3f lamina=%s" % [_jogador.global_position.x, _lamina.visible])
			_encerrar()

	func _voltar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 12.0:
			_soltar("direita")
			if _camera.global_position.distance_to(_enquadramento_galeria.global_position) > 0.05:
				_falhar("câmera fora da galeria na volta")
			_frames = 0
			_colocado = false
			_fase = "queda"
		elif _frames > 400:
			_falhar("não voltou à galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

	func _queda() -> void:
		if not _no_lugar(28.8, false):
			return
		_pressionar("atacar")
		_frames = 0
		_fase = "queda_no_ar"

	func _queda_no_ar() -> void:
		_observar_lamina()
		if _lamina.visible and _jogador.global_position.y > -1.0:
			_jogador.global_position = Vector3(33.0, -3.0, 0.0)
			_jogador.velocity = Vector3.ZERO
			return
		if _jogador.global_position.y < -1.0:
			return
		var retorno: Vector3 = _retorno_galeria.global_position
		var pos: Vector3 = _jogador.global_position
		if absf(pos.x - retorno.x) < 0.4 and pos.y > 0.3:
			_renasceu_na_galeria = true
		if _renasceu_na_galeria and _jogador.is_on_floor() and absf(pos.y) <= 0.08 and not _lamina.visible and not _area.monitoring:
			if _camera.global_position.distance_to(_enquadramento_galeria.global_position) > 0.05:
				_falhar("a câmera saiu da galeria depois da queda")
			print("MEDICAO queda x=%.4f y=%.4f camera_x=%.4f" % [pos.x, pos.y, _camera.global_position.x])
			_encerrar()
			return
		if _frames > 200:
			_falhar("a queda não devolveu à galeria. pos=%s" % pos)
			_encerrar()

	func _observar_lamina() -> void:
		if _lamina.visible:
			_viu_lamina = true

	func _golpe_quieto() -> bool:
		if not _viu_lamina or _frames < 8:
			return false
		return not _lamina.visible and not _area.monitoring

	func _no_lugar(x: float, direita: bool) -> bool:
		if not _colocado:
			_soltar("direita")
			_soltar("esquerda")
			_soltar("pulo")
			_jogador.global_position = Vector3(x, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_visual.rotation.y = 0.0 if direita else PI
			_colocado = true
			_frames = 0
			return false
		_visual.rotation.y = 0.0 if direita else PI
		if _frames > 10 and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08 and absf(_jogador.global_position.x - x) < 0.35:
			return true
		if _frames > 90:
			_falhar("não firmou os pés em x=%.2f, pos=%s" % [x, _jogador.global_position])
			_encerrar()
		return false

	func _observar_corrida(direita: bool) -> void:
		if _animacao == null or not _jogador.is_on_floor():
			return
		var correndo := _animacao.is_playing() and _animacao.current_animation == "corrida"
		var giro: float = _visual.rotation.y
		if direita and _jogador.velocity.x > 3.0 and absf(giro) < 0.05 and correndo:
			_correu = true
		if not direita and _jogador.velocity.x < -3.0 and absf(giro - PI) < 0.05 and correndo:
			_correu = true

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("direita")
		_soltar("esquerda")
		_soltar("pulo")
		_soltar("atacar")
		if _z_max > 0.001:
			_falhar("Z saiu do plano: %.6f" % _z_max)
		if not _andou_direita or not _andou_esquerda or not _pulou or not _correu:
			_falhar("movimento incompleto dir=%s esq=%s pulo=%s corrida=%s" % [_andou_direita, _andou_esquerda, _pulou, _correu])
		if not _segurou_um or not _segundo_toque:
			_falhar("segurar=%s segundo=%s" % [_segurou_um, _segundo_toque])
		if not _golpe_encerrado_na_troca:
			_falhar("a troca de sala não encerrou o golpe")
		if not _renasceu_na_galeria:
			_falhar("a queda não devolveu à galeria")
		if not _longe_errou or not _alcance_maior_acertou:
			_falhar("exercício do alcance errou=%s maior=%s" % [_longe_errou, _alcance_maior_acertou])
		if not _um_jogador:
			_falhar("mais de um jogador")
		print("MEDICAO z_max=%.6f pulo=%.3f quadros_esq=%d quadros_dir=%d" % [_z_max, _pico_pulo, _quadros_esquerda, _quadros_direita])
		print("MEDICAO troca=%s queda=%s" % [_golpe_encerrado_na_troca, _renasceu_na_galeria])
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
