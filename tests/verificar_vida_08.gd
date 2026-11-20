extends SceneTree

## Vida e dano por contato na cena 08. O dano vem do encontro dos corpos. Não faz parte do jogo.


func _initialize() -> void:
	root.add_child(Driver.new())


class Driver extends Node:
	const _X_SALTO := 27.8
	const _TOPO := 1.1

	var _cena: Node3D
	var _jogador: CharacterBody3D
	var _visual: Node3D
	var _lamina: MeshInstance3D
	var _area: Area3D
	var _sentinela: AnimatableBody3D
	var _camera: Camera3D
	var _enquadramento: Node3D
	var _retorno: Node3D
	var _rotulo: Label
	var _fase := "cair"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _falhas: PackedStringArray = []
	var _colocado := false
	var _z_max := 0.0
	var _um_jogador := false
	var _vida_sentinela_antes := 0
	var _pes_acima := false
	var _soltou_seta := false
	var _salto_ok := false
	var _lamina_ok := false
	var _viu_lamina := false
	var _x_golpe := 0.0
	var _parado_ok := false
	var _afastou_ok := false
	var _porta_ok := false
	var _andou_ok := false
	var _segurou_ok := false
	var _derrota_ok := false
	var _caminho_ok := false
	var _intervalo := 0.0
	var _relogio := 0.0
	var _marca_dano := -1.0
	var _vida_vista := 3
	var _limite_direito := 0.0

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		var packed := load("res://scenes/verification/08_vida_do_jogador.tscn") as PackedScene
		_cena = packed.instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_visual = _jogador.get_node("Visual") as Node3D
		_lamina = _jogador.get_node("Golpe/Lamina") as MeshInstance3D
		_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria") as AnimatableBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_enquadramento = _cena.get_node("Galeria/Enquadramento") as Node3D
		_retorno = _cena.get_node("Galeria/Retorno") as Node3D
		_rotulo = _cena.get_node("IndicadorDeVida/Vida") as Label
		_limite_direito = _cena.get_node("Galeria/PatrulhaDireita").global_position.x
		var jogadores := 0
		for corpo in _cena.find_children("*", "CharacterBody3D", true, false):
			if corpo.name == "Jogador":
				jogadores += 1
		_um_jogador = jogadores == 1
		if not _um_jogador:
			_falhar("havia %d jogadores" % jogadores)
		var vida: int = _jogador.get("pontos_de_vida")
		var maximo: int = _jogador.get("pontos_maximos")
		var protecao: float = _jogador.get("duracao_da_protecao_s")
		var ativa: bool = _jogador.get("vida_ativa")
		print("MEDICAO vida=%d/%d protecao=%.2f ativa=%s" % [vida, maximo, protecao, ativa])
		if vida != 3 or maximo != 3 or not ativa or absf(protecao - 1.0) > 0.01:
			_falhar("vida inicial incorreta")
		var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
		if principal != "res://scenes/verification/main.tscn":
			_falhar("F5 mudou para %s" % principal)
		_pronto = true

	func _physics_process(delta: float) -> void:
		if _encerrado or not _pronto:
			return
		_frames += 1
		_relogio += delta
		if _area == null:
			_area = get_tree().get_first_node_in_group("area_do_golpe") as Area3D
			if _area == null:
				return
		_z_max = maxf(_z_max, absf(_jogador.global_position.z))
		_z_max = maxf(_z_max, absf(_sentinela.global_position.z))
		if _frames > 5000:
			_falhar("tempo esgotado na fase %s" % _fase)
			_encerrar()
			return
		match _fase:
			"cair":
				_cair()
			"ir_galeria":
				_ir_galeria()
			"preparar_salto":
				if _no_lugar(_X_SALTO, true):
					_frames = 0
					_fase = "esperar_volta"
			"esperar_volta":
				_esperar_volta()
			"saltando":
				_saltando()
			"golpe":
				_colocar_golpe()
			"medir_golpe":
				_medir_golpe()
			"parado":
				_parado()
			"parado_olhar":
				_parado_olhar()
			"afastar":
				_afastar()
			"sair":
				_sair()
			"entrar":
				_entrar()
			"andar":
				_andar()
			"segurar":
				_segurar()
			"derrota":
				_derrota()
			"acabar":
				_colocar_golpe()
			"medir_acabar":
				_medir_acabar()
			"atravessar":
				_atravessar()

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
			_frames = 0
			_colocado = false
			_fase = "preparar_salto"
		elif _frames > 500:
			_falhar("não entrou na galeria")
			_encerrar()

	func _esperar_volta() -> void:
		var sentido: float = _sentinela.get("sentido")
		if sentido < 0.0 and _sentinela.global_position.x > _limite_direito - 0.35 and _jogador.is_on_floor():
			_vida_sentinela_antes = int(_sentinela.get("pontos_de_vida"))
			_pes_acima = false
			_soltou_seta = false
			_pressionar("direita")
			_pressionar("pulo")
			_frames = 0
			_fase = "saltando"
		elif _frames > 400:
			_falhar("a sentinela não voltou para o salto")
			_encerrar()

	func _saltando() -> void:
		if _frames == 6:
			_soltar("pulo")
		var sx := _sentinela.global_position.x
		if absf(_jogador.global_position.x - sx) < 0.7 and _jogador.global_position.y > _TOPO + 0.12:
			_pes_acima = true
		if not _soltou_seta and _pes_acima and _jogador.global_position.x > sx + 0.35:
			_soltar("direita")
			_soltou_seta = true
		if _soltou_seta and _frames > 12 and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
			var vida: int = _jogador.get("pontos_de_vida")
			var deles: int = _sentinela.get("pontos_de_vida")
			print("MEDICAO salto x=%.3f y=%.3f sent=%.3f vida=%d sentinela=%d pes=%s" % [
				_jogador.global_position.x, _jogador.global_position.y, sx, vida, deles, _pes_acima,
			])
			_salto_ok = _pes_acima and vida == 3 and deles == _vida_sentinela_antes
			if not _salto_ok:
				_falhar("o salto mudou a vida vida=%d sentinela=%d" % [vida, deles])
			_soltar("direita")
			_frames = 0
			_colocado = false
			_fase = "golpe"
		elif _frames > 180:
			_falhar("não pousou depois do salto")
			_encerrar()

	func _colocar_golpe() -> void:
		if not _posicao_estavel():
			return
		if not _colocado:
			_x_golpe = _sentinela.global_position.x - 1.05
		if not _no_lugar(_x_golpe, true):
			return
		_vida_sentinela_antes = int(_sentinela.get("pontos_de_vida"))
		_viu_lamina = false
		_pressionar("atacar")
		_frames = 0
		_fase = "medir_acabar" if _fase == "acabar" else "medir_golpe"

	func _medir_golpe() -> void:
		if _lamina.visible:
			_viu_lamina = true
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("o golpe da lâmina não terminou")
				_encerrar()
			return
		var vida: int = _jogador.get("pontos_de_vida")
		var deles: int = _sentinela.get("pontos_de_vida")
		print("MEDICAO lamina vida=%d sentinela=%d antes=%d lamina=%s" % [vida, deles, _vida_sentinela_antes, _viu_lamina])
		_lamina_ok = vida == 3 and deles == _vida_sentinela_antes - 1 and _viu_lamina
		if not _lamina_ok:
			_falhar("a lâmina não feriu só a sentinela")
		_soltar("atacar")
		_frames = 0
		_colocado = false
		_fase = "parado"

	func _parado() -> void:
		if not _colocado:
			_soltar("direita")
			_soltar("esquerda")
			_soltar("atacar")
			_jogador.global_position = Vector3(29.3, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_colocado = true
			_frames = 0
			return
		if int(_jogador.get("pontos_de_vida")) == 2:
			print("MEDICAO toque t=%.3f vida=%d texto=%s direita=%s" % [
				_relogio, int(_jogador.get("pontos_de_vida")), _rotulo.text, Input.is_action_pressed("direita"),
			])
			if Input.is_action_pressed("direita"):
				_falhar("o primeiro toque aconteceu andando")
			_frames = 0
			_fase = "parado_olhar"
			return
		if _frames > 400:
			_falhar("a sentinela não encostou no jogador parado")
			_encerrar()

	func _parado_olhar() -> void:
		if _frames < 8:
			return
		var vida: int = _jogador.get("pontos_de_vida")
		var protecao: float = _jogador.get("tempo_de_protecao_s")
		print("MEDICAO durante t=%.3f vida=%d protecao=%.3f texto=%s" % [_relogio, vida, protecao, _rotulo.text])
		_parado_ok = vida == 2 and protecao > 0.4 and _rotulo.text == "Vida 2/3"
		if not _parado_ok:
			_falhar("a proteção não segurou a vida em 2")
		_jogador.global_position = Vector3(22.0, 0.2, 0.0)
		_jogador.velocity = Vector3.ZERO
		_frames = 0
		_fase = "afastar"

	func _afastar() -> void:
		var protecao: float = _jogador.get("tempo_de_protecao_s")
		if _frames < 100 or protecao > 0.0:
			if _frames > 200:
				_falhar("a proteção não terminou longe da sentinela")
				_encerrar()
			return
		var vida: int = _jogador.get("pontos_de_vida")
		print("MEDICAO afastado vida=%d protecao=%.3f" % [vida, protecao])
		_afastou_ok = vida == 2
		if not _afastou_ok:
			_falhar("afastar mudou a vida para %d" % vida)
		_frames = 0
		_pressionar("esquerda")
		_fase = "sair"

	func _sair() -> void:
		if _jogador.is_on_floor() and _jogador.global_position.x > 23.0 and _jogador.global_position.x < 28.2:
			if Input.is_action_pressed("pulo"):
				_soltar("pulo")
			else:
				_pressionar("pulo")
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.global_position.x < 12.0 and _camera.global_position.x < 5.0:
			_soltar("esquerda")
			_soltar("pulo")
			_frames = 0
			_pressionar("direita")
			_fase = "entrar"
		elif _frames > 500:
			_falhar("não saiu da galeria")
			_encerrar()

	func _entrar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 20.0 and _camera.global_position.x > 20.0:
			_soltar("direita")
			var vida: int = _jogador.get("pontos_de_vida")
			print("MEDICAO volta vida=%d texto=%s sentinela=%d" % [vida, _rotulo.text, int(_sentinela.get("pontos_de_vida"))])
			_porta_ok = vida == 2 and _rotulo.text == "Vida 2/3" and int(_sentinela.get("pontos_de_vida")) == 2
			if not _porta_ok:
				_falhar("a porta não conservou a vida")
			_frames = 0
			_pressionar("direita")
			_fase = "andar"
		elif _frames > 500:
			_falhar("não voltou à galeria")
			_encerrar()

	func _andar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.x < 27.6:
			if Input.is_action_pressed("pulo"):
				_soltar("pulo")
			else:
				_pressionar("pulo")
		else:
			_soltar("pulo")
		if int(_jogador.get("pontos_de_vida")) == 1:
			print("MEDICAO andando t=%.3f vida=%d direita=%s" % [_relogio, 1, Input.is_action_pressed("direita")])
			_andou_ok = Input.is_action_pressed("direita")
			if not _andou_ok:
				_falhar("o dano andando não usou a seta")
			_marca_dano = _relogio
			_vida_vista = 1
			_frames = 0
			_fase = "segurar"
			return
		if _frames > 400:
			_falhar("andar contra a sentinela não tirou vida")
			_encerrar()

	func _segurar() -> void:
		var retornos_agora: int = _jogador.get("retornos_por_derrota")
		if retornos_agora > 0:
			_intervalo = _relogio - _marca_dano
			var interno_agora: float = _jogador.get("intervalo_do_ultimo_dano_s")
			print("MEDICAO intervalo=%.3f interno=%.3f" % [_intervalo, interno_agora])
			_segurou_ok = _intervalo >= 0.95 and _intervalo <= 1.25
			if not _segurou_ok:
				_falhar("intervalo fora de 1 s: %.3f" % _intervalo)
			_soltar("direita")
			_frames = 0
			_fase = "derrota"
			return
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		var sx := _sentinela.global_position.x
		var y := _jogador.global_position.y
		if y > 0.3:
			y = 0.12
		_jogador.global_position = Vector3(sx - 0.45, y, 0.0)
		var vida: int = _jogador.get("pontos_de_vida")
		if _relogio - _marca_dano < 0.7 and vida != 1:
			_falhar("o segundo dano chegou cedo, vida=%d" % vida)
			_encerrar()
			return
		if vida == 0 or int(_jogador.get("retornos_por_derrota")) > 0:
			_intervalo = _relogio - _marca_dano
			var interno: float = _jogador.get("intervalo_do_ultimo_dano_s")
			print("MEDICAO intervalo=%.3f interno=%.3f" % [_intervalo, interno])
			_segurou_ok = _intervalo >= 0.95 and _intervalo <= 1.2
			if not _segurou_ok:
				_falhar("intervalo fora de 1 s: %.3f" % _intervalo)
			_frames = 0
			_fase = "derrota"
			return
		if _frames > 120:
			_falhar("manter contato não aplicou o segundo dano. vida=%d" % vida)
			_encerrar()

	func _derrota() -> void:
		var retornos: int = _jogador.get("retornos_por_derrota")
		var vida: int = _jogador.get("pontos_de_vida")
		var perto := absf(_jogador.global_position.x - _retorno.global_position.x) < 0.6
		if retornos == 1 and vida == 3 and perto and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.15:
			var lamina_off := not _lamina.visible and not _area.monitoring
			var camera_ok := _camera.global_position.distance_to(_enquadramento.global_position) < 0.05
			print("MEDICAO derrota x=%.3f y=%.3f camera_x=%.3f vida=%d retornos=%d lamina=%s" % [
				_jogador.global_position.x, _jogador.global_position.y, _camera.global_position.x, vida, retornos, not lamina_off,
			])
			_derrota_ok = lamina_off and camera_ok and retornos == 1
			if not _derrota_ok:
				_falhar("o retorno da derrota ficou incompleto")
			_soltar("direita")
			_frames = 0
			_colocado = false
			_fase = "acabar"
			return
		if _frames > 200:
			_falhar("não houve um único retorno. x=%.3f vida=%d retornos=%d" % [
				_jogador.global_position.x, vida, retornos,
			])
			_encerrar()

	func _medir_acabar() -> void:
		if _lamina.visible:
			_viu_lamina = true
			_soltar("atacar")
		if not _golpe_quieto():
			if _frames > 120:
				_falhar("o golpe final não terminou")
				_encerrar()
			return
		_soltar("atacar")
		if int(_sentinela.get("pontos_de_vida")) > 0:
			_frames = 0
			_colocado = false
			_viu_lamina = false
			_fase = "acabar"
			return
		print("MEDICAO sentinela_derrotada vida_jogador=%d" % int(_jogador.get("pontos_de_vida")))
		_frames = 0
		_colocado = false
		_fase = "atravessar"

	func _atravessar() -> void:
		var meta := _sentinela.global_position.x + 0.9
		if not _colocado:
			_soltar("direita")
			_jogador.global_position = Vector3(_sentinela.global_position.x - 1.3, 0.2, 0.0)
			_jogador.velocity = Vector3.ZERO
			_colocado = true
			_frames = 0
			return
		if _frames > 8 and _jogador.is_on_floor():
			_pressionar("direita")
		var vida: int = _jogador.get("pontos_de_vida")
		if vida < 3:
			_falhar("a sentinela derrotada tirou vida")
			_encerrar()
			return
		if _jogador.global_position.x > meta and _jogador.is_on_floor() and _jogador.global_position.y < 0.2:
			_soltar("direita")
			_caminho_ok = true
			print("MEDICAO atravessou x=%.3f vida=%d" % [_jogador.global_position.x, vida])
			_encerrar()
			return
		if _frames > 180:
			_falhar("não atravessou a sentinela caída")
			_encerrar()

	func _posicao_estavel() -> bool:
		var sentido: float = _sentinela.get("sentido")
		var sx := _sentinela.global_position.x
		return sentido > 0.0 and sx > 28.95 and sx < 29.35

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
		if _frames > 8 and _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08 and absf(_jogador.global_position.x - x) < 0.45:
			return true
		if _frames > 90:
			_falhar("não firmou os pés em x=%.2f" % x)
			_encerrar()
		return false

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
		if _z_max > 0.001:
			_falhar("Z saiu do plano: %.6f" % _z_max)
		if not _salto_ok or not _lamina_ok or not _parado_ok or not _afastou_ok:
			_falhar("salto=%s lamina=%s parado=%s afastou=%s" % [_salto_ok, _lamina_ok, _parado_ok, _afastou_ok])
		if not _porta_ok or not _andou_ok or not _segurou_ok or not _derrota_ok or not _caminho_ok:
			_falhar("porta=%s andou=%s segurou=%s derrota=%s caminho=%s" % [_porta_ok, _andou_ok, _segurou_ok, _derrota_ok, _caminho_ok])
		if not _um_jogador:
			_falhar("mais de um jogador")
		if int(_jogador.get("retornos_por_derrota")) != 1:
			_falhar("retornos=%d" % int(_jogador.get("retornos_por_derrota")))
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
