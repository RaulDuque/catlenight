extends SceneTree

## Encontro com a sentinela: patrulha, salto e três golpes. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _X_SALTO := 27.8
	const _TOPO_DA_SENTINELA := 1.1

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _visual: Node3D
	var _lamina: MeshInstance3D
	var _area: Area3D
	var _sentinela: AnimatableBody3D
	var _olho: Node3D
	var _colisao: CollisionShape3D
	var _camera: Camera3D
	var _enquadramento_galeria: Node3D
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _z_max := 0.0
	var _colocado := false
	var _viu_lamina := false
	var _vida_antes := 0
	var _limite_esquerdo := 0.0
	var _limite_direito := 0.0
	var _x_min := 1000.0
	var _x_max := -1000.0
	var _virou_esquerda := false
	var _virou_direita := false
	var _patrulha_ok := false
	var _y_sentinela_max := 0.0
	var _salto_passou := false
	var _vida_no_salto := 0
	var _x_antes := 0.0
	var _y_antes := 0.0
	var _sx_antes := 0.0
	var _x_depois := 0.0
	var _y_depois := 0.0
	var _sx_depois := 0.0
	var _pes_acima := false
	var _soltou_seta := false
	var _segurou := false
	var _errou_costas := false
	var _errou_longe := false
	var _vida_um := false
	var _derrotou := false
	var _caminho_livre := false
	var _voltou := false
	var _um_jogador := false
	var _x_parado := 0.0
	var _x_golpe := 0.0

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/07_primeiro_inimigo.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_visual = _jogador.get_node("Visual") as Node3D
		_lamina = _jogador.get_node("Golpe/Lamina") as MeshInstance3D
		_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria") as AnimatableBody3D
		_olho = _sentinela.get_node("Visual/Olho") as Node3D
		_colisao = _sentinela.get_node("Colisao") as CollisionShape3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_enquadramento_galeria = _cena.get_node("Galeria/Enquadramento") as Node3D
		_limite_esquerdo = _cena.get_node("Galeria/PatrulhaEsquerda").global_position.x
		_limite_direito = _cena.get_node("Galeria/PatrulhaDireita").global_position.x
		var jogadores := 0
		for corpo in _cena.find_children("*", "CharacterBody3D", true, false):
			if corpo.name == "Jogador":
				jogadores += 1
		_um_jogador = jogadores == 1
		if not _um_jogador:
			_falhar("havia %d jogadores" % jogadores)
		var velocidade: float = _sentinela.get("velocidade_da_patrulha_m_por_s")
		var vida: int = _sentinela.get("pontos_de_vida")
		print("MEDICAO velocidade=%.2f vida=%d limite_esq=%.3f limite_dir=%.3f" % [velocidade, vida, _limite_esquerdo, _limite_direito])
		if absf(velocidade - 1.2) > 0.01:
			_falhar("velocidade inicial %.2f" % velocidade)
		if vida != 3:
			_falhar("vida inicial %d" % vida)
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if str(principal) != "res://scenes/verification/main.tscn":
			_falhar("F5 mudou para %s" % principal)
		_pronto = true

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		if _area == null:
			_area = get_tree().get_first_node_in_group("area_do_golpe") as Area3D
			if _area == null:
				return
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		_z_max = maxf(_z_max, absf(_sentinela.global_position.z))
		_observar_patrulha()
		if _frames > 4500:
			_falhar("tempo esgotado na fase %s" % _fase)
			_encerrar()
			return
		match _fase:
			"cair":
				_cair()
			"ir_galeria":
				_ir_galeria()
			"preparar_salto":
				_preparar_salto()
			"esperar_volta":
				_esperar_volta()
			"saltando":
				_saltando()
			"frente":
				_colocar_golpe(true, 0.95, "medir_frente")
			"medir_frente":
				_medir_frente()
			"costas":
				_colocar_golpe(false, 0.95, "medir_costas")
			"medir_costas":
				_medir_erro("costas", "longe")
			"longe":
				_colocar_golpe(true, 1.65, "medir_longe")
			"medir_longe":
				_medir_erro("longe", "segundo")
			"segundo":
				_colocar_golpe(true, 0.95, "medir_segundo")
			"medir_segundo":
				_medir_vida(1, "terceiro")
			"terceiro":
				_colocar_golpe(true, 0.95, "medir_terceiro")
			"medir_terceiro":
				_medir_derrota()
			"sair":
				_sair()
			"entrar":
				_entrar()
			"atravessar":
				_atravessar()

	func _observar_patrulha() -> void:
		if _patrulha_ok:
			return
		var x := _sentinela.global_position.x
		var y := _sentinela.global_position.y
		_y_sentinela_max = maxf(_y_sentinela_max, absf(y))
		_x_min = minf(_x_min, x)
		_x_max = maxf(_x_max, x)
		if x < _limite_esquerdo - 0.08 or x > _limite_direito + 0.08:
			_falhar("saiu do trecho: x=%.3f" % x)
			_encerrar()
			return
		var giro: float = _sentinela.get_node("Visual").rotation.y
		var sentido: float = _sentinela.get("sentido")
		if x >= _limite_direito - 0.05 and sentido < 0.0 and absf(giro - PI) < 0.08:
			_virou_direita = true
		if x <= _limite_esquerdo + 0.05 and sentido > 0.0 and absf(giro) < 0.08:
			_virou_esquerda = true
		if _virou_esquerda and _virou_direita and _x_max - _x_min > 1.2:
			_patrulha_ok = true
			print("MEDICAO patrulha x_min=%.3f x_max=%.3f y=%.4f z=%.4f virou_esq=%s virou_dir=%s" % [
				_x_min, _x_max, y, _sentinela.global_position.z, _virou_esquerda, _virou_direita,
			])

	func _cair() -> void:
		if _frames > 20 and _jogador.is_on_floor():
			_frames = 0
			_pressionar("direita")
			_fase = "ir_galeria"
		elif _frames > 180:
			_falhar("não pousou no vestíbulo")
			_encerrar()

	func _ir_galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 20.0:
			_soltar("direita")
			if _camera.global_position.distance_to(_enquadramento_galeria.global_position) > 0.05:
				_falhar("câmera fora da galeria")
			_frames = 0
			_colocado = false
			_fase = "preparar_salto"
		elif _frames > 500:
			_falhar("não entrou na galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

	func _preparar_salto() -> void:
		if not _no_lugar(_X_SALTO, true):
			return
		_frames = 0
		_fase = "esperar_volta"

	func _esperar_volta() -> void:
		var sentido: float = _sentinela.get("sentido")
		var sx := _sentinela.global_position.x
		if sentido < 0.0 and sx > _limite_direito - 0.35 and _jogador.is_on_floor():
			_x_antes = _jogador.global_position.x
			_y_antes = _jogador.global_position.y
			_sx_antes = sx
			_vida_no_salto = int(_sentinela.get("pontos_de_vida"))
			_pes_acima = false
			_soltou_seta = false
			_pressionar("direita")
			_pressionar("pulo")
			_frames = 0
			_fase = "saltando"
			return
		if _frames > 400:
			_falhar("a sentinela não voltou para o salto. x=%.3f sentido=%.0f" % [sx, sentido])
			_encerrar()

	func _saltando() -> void:
		if _frames == 6:
			_soltar("pulo")
		var sx := _sentinela.global_position.x
		var cruza := absf(_jogador.global_position.x - sx) < 0.7
		if cruza and _jogador.global_position.y > _TOPO_DA_SENTINELA + 0.12:
			_pes_acima = true
		if not _soltou_seta and _pes_acima and _jogador.global_position.x > sx + 0.35:
			_soltar("direita")
			_soltou_seta = true
		if _soltou_seta and _frames > 12 and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
			_x_depois = _jogador.global_position.x
			_y_depois = _jogador.global_position.y
			_sx_depois = _sentinela.global_position.x
			var vida: int = _sentinela.get("pontos_de_vida")
			print("MEDICAO salto antes x=%.3f y=%.3f sent=%.3f depois x=%.3f y=%.3f sent=%.3f pes_acima=%s vida=%d" % [
				_x_antes, _y_antes, _sx_antes, _x_depois, _y_depois, _sx_depois, _pes_acima, vida,
			])
			if not _pes_acima:
				_falhar("os pés não passaram acima da sentinela")
			if _x_depois <= _sx_depois:
				_falhar("pousou antes da sentinela. x=%.3f sent=%.3f" % [_x_depois, _sx_depois])
			if _x_depois > 30.6:
				_falhar("pousou fora do piso. x=%.3f" % _x_depois)
			if vida != 3:
				_falhar("o salto mudou a vida para %d" % vida)
			_salto_passou = _pes_acima and _x_depois > _sx_depois and vida == 3
			_soltar("direita")
			_soltar("pulo")
			_frames = 0
			_colocado = false
			_fase = "frente"
			return
		if _frames > 180:
			_falhar("não pousou depois do salto. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			_encerrar()

	func _medir_frente() -> void:
		_observar_lamina()
		if not Input.is_action_pressed("atacar"):
			_pressionar("atacar")
		if _frames < 55 or not _viu_lamina:
			if _frames > 100:
				_falhar("o golpe frontal não mostrou a lâmina")
				_encerrar()
			return
		if _lamina.visible or _area.monitoring:
			if _frames > 110:
				_falhar("segurar X não terminou o golpe")
				_encerrar()
			return
		var vida: int = _sentinela.get("pontos_de_vida")
		var deste: int = _jogador.get("acertos_deste_golpe")
		var quadros: int = _jogador.get("quadros_sobre_o_alvo")
		print("MEDICAO frente vida=%d deste=%d quadros=%d lamina=%s" % [vida, deste, quadros, _viu_lamina])
		if vida != 2 or deste != 1:
			_falhar("frontal vida=%d deste=%d, antes %d" % [vida, deste, _vida_antes])
		if quadros < 2:
			_falhar("o contato durou %d quadro" % quadros)
		_segurou = vida == 2 and deste == 1
		_soltar("atacar")
		_frames = 0
		_colocado = false
		_fase = "costas"

	func _colocar_golpe(direita: bool, distancia: float, seguinte: String) -> void:
		if not _colocado and not _posicao_estavel(seguinte):
			return
		if not _colocado:
			_x_golpe = _sentinela.global_position.x - distancia
		if not _no_lugar(_x_golpe, direita):
			return
		_vida_antes = int(_sentinela.get("pontos_de_vida"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = seguinte

	func _posicao_estavel(seguinte: String) -> bool:
		var sentido: float = _sentinela.get("sentido")
		var sx := _sentinela.global_position.x
		if seguinte == "medir_longe":
			return sentido > 0.0 and sx > 29.6 and sx < 29.95
		return sentido > 0.0 and sx > _limite_esquerdo + 0.25 and sx < _limite_direito - 0.45

	func _medir_erro(nome: String, seguinte: String) -> void:
		_observar_lamina()
		if _viu_lamina:
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("golpe de %s não terminou" % nome)
				_encerrar()
			return
		_soltar("atacar")
		var vida: int = _sentinela.get("pontos_de_vida")
		var deste: int = _jogador.get("acertos_deste_golpe")
		print("MEDICAO erro_%s vida=%d deste=%d lamina=%s" % [nome, vida, deste, _viu_lamina])
		if vida != _vida_antes or deste != 0:
			_falhar("%s mudou a vida: %d deste %d antes %d" % [nome, vida, deste, _vida_antes])
		if not _viu_lamina:
			_falhar("%s não mostrou a lâmina" % nome)
		if nome == "costas":
			_errou_costas = true
		elif nome == "longe":
			_errou_longe = true
		_frames = 0
		_colocado = false
		_fase = seguinte

	func _medir_vida(esperada: int, seguinte: String) -> void:
		_observar_lamina()
		if _viu_lamina:
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("golpe até %d não terminou" % esperada)
				_encerrar()
			return
		_soltar("atacar")
		var vida: int = _sentinela.get("pontos_de_vida")
		var deste: int = _jogador.get("acertos_deste_golpe")
		print("MEDICAO vida=%d deste=%d antes=%d" % [vida, deste, _vida_antes])
		if vida != esperada or deste != 1:
			_falhar("esperava vida %d e um acerto, veio %d e %d" % [esperada, vida, deste])
		if esperada == 1:
			_vida_um = true
		_frames = 0
		_colocado = false
		_fase = seguinte

	func _medir_derrota() -> void:
		_observar_lamina()
		if _viu_lamina:
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("o terceiro golpe não terminou")
				_encerrar()
			return
		_soltar("atacar")
		var vida: int = _sentinela.get("pontos_de_vida")
		var deste: int = _jogador.get("acertos_deste_golpe")
		var derrotada: bool = _sentinela.get("derrotada")
		print("MEDICAO derrota vida=%d deste=%d derrotada=%s colisao=%s" % [vida, deste, derrotada, _colisao.disabled])
		if vida != 0 or deste != 1 or not derrotada or not _colisao.disabled:
			_falhar("derrota incompleta vida=%d deste=%d" % [vida, deste])
		_derrotou = vida == 0 and derrotada and _colisao.disabled
		_x_parado = _sentinela.global_position.x
		_frames = 0
		_fase = "sair"

	func _sair() -> void:
		if _frames < 20:
			if absf(_sentinela.global_position.x - _x_parado) > 0.02:
				_falhar("a patrulha continuou depois da derrota")
				_encerrar()
			return
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and _jogador.global_position.x > 23.0 and _jogador.global_position.x < 28.2:
			if Input.is_action_pressed("pulo"):
				_soltar("pulo")
			else:
				_pressionar("pulo")
		if _jogador.global_position.x < 12.0 and _camera.global_position.x < 5.0:
			_soltar("esquerda")
			var vida: int = _sentinela.get("pontos_de_vida")
			print("MEDICAO saida x=%.3f camera_x=%.3f vida=%d" % [_jogador.global_position.x, _camera.global_position.x, vida])
			if vida != 0 or not bool(_sentinela.get("derrotada")):
				_falhar("a sentinela voltou ao sair")
			_frames = 0
			_pressionar("direita")
			_fase = "entrar"
		elif _frames > 500:
			_falhar("não saiu da galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

	func _entrar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 20.0 and _camera.global_position.x > 20.0:
			_soltar("direita")
			var vida: int = _sentinela.get("pontos_de_vida")
			print("MEDICAO volta x=%.3f camera_x=%.3f vida=%d" % [_jogador.global_position.x, _camera.global_position.x, vida])
			if vida != 0 or not _colisao.disabled:
				_falhar("o caminho não continuou livre na volta")
			_voltou = true
			_frames = 0
			_colocado = false
			_fase = "atravessar"
		elif _frames > 500:
			_falhar("não voltou à galeria. x=%.3f" % _jogador.global_position.x)
			_encerrar()

	func _atravessar() -> void:
		var meta := _sentinela.global_position.x + 1.05
		if not _colocado:
			_soltar("direita")
			_soltar("esquerda")
			_jogador.global_position = Vector3(_sentinela.global_position.x - 1.3, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_colocado = true
			_frames = 0
			return
		if _frames > 8 and _jogador.is_on_floor():
			_pressionar("direita")
		if _jogador.global_position.x > meta and _jogador.is_on_floor() and _jogador.global_position.y < 0.2:
			_soltar("direita")
			_caminho_livre = true
			print("MEDICAO atravessou x=%.3f y=%.3f sent=%.3f" % [
				_jogador.global_position.x, _jogador.global_position.y, _sentinela.global_position.x,
			])
			_encerrar()
			return
		if _frames > 180:
			_falhar("não atravessou a sentinela caída. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			_encerrar()

	func _no_lugar(x: float, direita: bool) -> bool:
		if not _colocado:
			_soltar("direita")
			_soltar("esquerda")
			_soltar("pulo")
			_soltar("atacar")
			_jogador.global_position = Vector3(x, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_visual.rotation.y = 0.0 if direita else PI
			_colocado = true
			_frames = 0
			return false
		_visual.rotation.y = 0.0 if direita else PI
		if _frames > 8 and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08 and absf(_jogador.global_position.x - x) < 0.4:
			return true
		if _frames > 90:
			_falhar("não firmou os pés em x=%.2f, pos=%s" % [x, _jogador.global_position])
			_encerrar()
		return false

	func _observar_lamina() -> void:
		if _lamina.visible:
			_viu_lamina = true

	func _golpe_quieto() -> bool:
		if not _viu_lamina or _frames < 8:
			return false
		return not _lamina.visible and not _area.monitoring

	func _encerrar() -> void:
		if _encerrado:
			return
		_encerrado = true
		_soltar("direita")
		_soltar("esquerda")
		_soltar("pulo")
		_soltar("atacar")
		if not _patrulha_ok:
			_falhar("patrulha incompleta esq=%s dir=%s" % [_virou_esquerda, _virou_direita])
		if _y_sentinela_max > 0.02:
			_falhar("a sentinela saiu do piso: %.4f" % _y_sentinela_max)
		if _z_max > 0.001:
			_falhar("Z saiu do plano: %.6f" % _z_max)
		if not _salto_passou:
			_falhar("o salto não passou por cima")
		if not _segurou or not _errou_costas or not _errou_longe or not _vida_um or not _derrotou:
			_falhar("golpes segurou=%s costas=%s longe=%s um=%s derrota=%s" % [_segurou, _errou_costas, _errou_longe, _vida_um, _derrotou])
		if not _caminho_livre or not _voltou:
			_falhar("caminho livre=%s volta=%s" % [_caminho_livre, _voltou])
		if not _um_jogador:
			_falhar("mais de um jogador")
		if _olho == null:
			_falhar("o olho não está na sentinela")
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
