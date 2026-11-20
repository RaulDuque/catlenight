extends SceneTree

## Duas ou mais execuções do piloto 11, com user:// isolado. Não faz parte do jogo.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var fase := "primeira"
	if args.size() > 0:
		fase = String(args[0])
	var driver := Driver.new()
	driver.fase_inicial = fase
	root.add_child(driver)


class Driver extends Node:
	const _TOPO := 2.35
	const _CENA := "res://scenes/verification/11_altar_de_salvamento.tscn"
	const _ARQUIVO := "user://catlenight_piloto_11.json"
	const _TEMP := "user://catlenight_piloto_11.json.tmp"
	const _SALVAR := "↑ Salvar progresso"
	const _PRONTO := "Progresso salvo"
	const _FALHA_TEXTO := "Não foi possível salvar"
	const _VOLTAR := "↑ Voltar ao vestíbulo"

	var fase_inicial := "primeira"
	var _cena: Node
	var _jogador: CharacterBody3D
	var _camera: Camera3D
	var _aviso: Label
	var _vida: Label
	var _menu: CanvasLayer
	var _sentinela: Node
	var _fase := "menu"
	var _frames := 0
	var _pronto := false
	var _encerrado := false
	var _pulou := false
	var _impulso := false
	var _ataque := 0
	var _espera := 0
	var _pontos_antes := 3
	var _alvo := 1
	var _apos_golpe := "voltar"
	var _texto_antes := ""
	var _segurou := 0

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		if fase_inicial == "arquivo":
			_escrever("{ \"versao\": 1, \"sala\": \"capela_da_lua\", \"sentinela_derrotada\": true, \"sentinela_vida\": 1 }")
			_fase = "arquivo_ruim"
		_abrir_cena()
		print("MEDICAO pasta=%s fase=%s" % [OS.get_user_data_dir(), fase_inicial])
		_pronto = true

	func _abrir_cena() -> void:
		_cena = (load(_CENA) as PackedScene).instantiate()
		get_tree().root.add_child(_cena)
		_jogador = _cena.get_node("Jogador") as CharacterBody3D
		_camera = _cena.get_node("CameraLateral") as Camera3D
		_aviso = _cena.get_node("AvisoDaPassagem/Texto") as Label
		_vida = _cena.get_node("IndicadorDeVida/Vida") as Label
		_menu = _cena.get_node("MenuDoPiloto") as CanvasLayer
		_sentinela = _cena.get_node("Galeria/SentinelaDaGaleria")
		_frames = 0

	func _physics_process(_delta: float) -> void:
		if _encerrado or not _pronto:
			return
		if _cena == null and _fase != "esperar_cena":
			return
		_frames += 1
		match _fase:
			"menu":
				_menu_escolher(fase_inicial != "primeira" and fase_inicial != "novo_jogo")
			"cair":
				_cair()
			"galeria":
				_galeria()
			"plataforma":
				_plataforma()
			"coletar":
				_coletar()
			"ferir":
				_ferir()
			"recuar":
				_recuar()
			"posicionar":
				_posicionar()
			"golpear":
				_golpear()
			"voltar":
				_voltar()
			"aproximar":
				_aproximar()
			"pousar":
				_pousar()
			"entrar":
				_entrar()
			"ate_altar":
				_ate_altar()
			"salvar":
				_salvar()
			"fim_continuar":
				_fim_continuar()
			"falha":
				_falha_de_escrita()
			"porta":
				_porta()
			"conferir":
				_conferir_continuacao()
			"sair":
				_sair_capela()
			"descer":
				_descer()
			"atravessar":
				_atravessar()
			"arquivo_ruim":
				_arquivo_ruim()
			"arquivo_lixo":
				_arquivo_lixo()
			"arquivo_ausente":
				_arquivo_ausente()
			"esperar_cena":
				_esperar_cena()

	func _menu_escolher(continuar: bool) -> void:
		if _menu == null or not _menu.visible:
			if get_tree().paused:
				return
			_soltar("pulo")
			_soltar("direita")
			_frames = 0
			if fase_inicial == "primeira":
				_fase = "cair"
			elif fase_inicial == "novo_jogo":
				_fase = "cair"
			else:
				_fase = "conferir"
			return
		if continuar:
			if _frames == 6:
				_pressionar("direita")
			if _frames == 8:
				_soltar("direita")
		if (not continuar and _frames == 8) or (continuar and _frames == 14):
			if continuar and String(_menu.get("selecao")) != "continuar":
				_falhar("Continuar não ficou selecionado")
				return
			_pressionar("pulo")
		if (not continuar and _frames == 12) or (continuar and _frames == 18):
			_soltar("pulo")
		if _frames > 90:
			_falhar("o menu não fechou. selecao=%s continuar=%s" % [String(_menu.get("selecao")), bool(_menu.get("continuar_habilitado"))])

	func _cair() -> void:
		if fase_inicial == "primeira" and _frames == 2:
			var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
			if principal != "res://scenes/verification/main.tscn":
				_falhar("o F5 mudou: %s" % principal)
				return
			if bool(_menu.get("continuar_habilitado")):
				_falhar("Continuar apareceu sem arquivo")
				return
		if fase_inicial == "novo_jogo" and _frames == 2:
			_texto_antes = _ler()
			if not bool(_menu.get("continuar_habilitado")):
				_falhar("Continuar estava desligado com uma gravação válida")
				return
		if _jogador.is_on_floor() and _frames > 8:
			if fase_inicial == "novo_jogo":
				_conferir_novo_jogo()
				return
			_pressionar("direita")
			_ir("galeria")

	func _galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_soltar("esquerda")
		if _camera.global_position.x > 20.0 and _jogador.global_position.x > 18.0 and _jogador.global_position.x < 22.5:
			_ir("plataforma")
		elif _frames > 450:
			_falhar("não chegou à galeria. x=%.3f" % _jogador.global_position.x)

	func _plataforma() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and y < 0.3 and x > 22.0 and x < 22.7 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.45:
			_soltar("pulo")
		if _jogador.is_on_floor() and y > 0.9 and x > 23.2 and x < 27.0:
			_ir("coletar" if fase_inicial == "primeira" else "posicionar")
		elif _frames > 360:
			_falhar("não subiu na plataforma. x=%.3f y=%.3f" % [x, y])

	func _coletar() -> void:
		var x := _jogador.global_position.x
		if x < 24.0:
			_pressionar("direita")
			_soltar("esquerda")
		elif x > 24.35:
			_pressionar("esquerda")
			_soltar("direita")
		else:
			_soltar("direita")
			_soltar("esquerda")
		if bool(_jogador.get("salto_duplo_adquirido")):
			print("MEDICAO coleta vida=%s" % _vida.text)
			_ir("ferir")
		elif _frames > 240:
			_falhar("não coletou a relíquia. x=%.3f" % x)

	func _ferir() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		var vida: int = _jogador.get("pontos_de_vida")
		if vida == 2:
			_ir("recuar")
			return
		if vida < 2:
			_falhar("a vida caiu além de 2. vida=%d" % vida)
			return
		_soltar("esquerda")
		if x < 28.5:
			_pressionar("direita")
		if _jogador.is_on_floor() and y < 0.3 and x > 26.4 and x < 27.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.55:
			_soltar("pulo")
		if x > 28.6 and y < 0.35:
			_soltar("direita")
		if _frames > 500:
			_falhar("não tomou dano. x=%.3f vida=%d" % [x, vida])

	func _recuar() -> void:
		var x := _jogador.global_position.x
		_soltar("direita")
		if x > 27.85:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		if _jogador.is_on_floor() and x < 27.85 and x > 27.45 and _jogador.global_position.y < 0.35:
			_alvo = 1
			_apos_golpe = "voltar"
			_ataque = 0
			_ir("golpear")
		elif _frames > 200:
			_falhar("não recuou da sentinela. x=%.3f vida=%d" % [x, int(_jogador.get("pontos_de_vida"))])

	func _posicionar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if y > 0.45:
			if x < 27.85:
				_pressionar("direita")
			else:
				_soltar("direita")
			_soltar("esquerda")
			_soltar("pulo")
			if _frames > 400:
				_falhar("não desceu da plataforma. x=%.3f y=%.3f" % [x, y])
			return
		if x > 27.9:
			_pressionar("esquerda")
			_soltar("direita")
		elif x < 27.5:
			_pressionar("direita")
			_soltar("esquerda")
		else:
			_soltar("direita")
			_soltar("esquerda")
		if _jogador.is_on_floor() and y < 0.35 and x >= 27.5 and x <= 27.9:
			_ataque = 0
			_ir("golpear" if fase_inicial != "derrota" else "atravessar")
		elif _frames > 500:
			_falhar("não chegou ao alcance. x=%.3f y=%.3f" % [x, y])

	func _golpear() -> void:
		var vida: int = _jogador.get("pontos_de_vida")
		if vida != 2:
			_falhar("o golpe mudou a vida do jogador. vida=%d" % vida)
			return
		var pontos: int = _sentinela.get("pontos_de_vida")
		var x := _jogador.global_position.x
		if x < 27.45:
			_pressionar("direita")
		elif x > 27.95:
			_pressionar("esquerda")
		else:
			_soltar("direita")
			_soltar("esquerda")
		var visual := _jogador.get_node("Visual") as Node3D
		var folga: float = _sentinela.global_position.x - x
		if _ataque == 0 and absf(visual.rotation.y) > 0.2 and folga > 1.05:
			_pressionar("direita")
			return
		if _ataque == 0:
			_soltar("direita")
		var distancia: float = folga
		if _ataque == 0 and _jogador.is_on_floor() and distancia > 0.85 and distancia < 1.35:
			_pressionar("atacar")
			_pontos_antes = pontos
			_ataque = 1
			_espera = 0
			return
		if _ataque == 1:
			_soltar("atacar")
			_ataque = 2
			return
		if _ataque == 2:
			_espera += 1
			if pontos < _pontos_antes:
				_ataque = 0
				_frames = 5
			elif _espera > 45:
				_ataque = 0
		if pontos == _alvo:
			print("MEDICAO golpe sentinela=%d vida=%s" % [pontos, _vida.text])
			_ir(_apos_golpe)
		elif pontos < _alvo:
			_falhar("a sentinela passou do ponto pedido. pontos=%d alvo=%d" % [pontos, _alvo])
		elif _frames > 900:
			_falhar("não alcançou o ponto da sentinela. pontos=%d x=%.3f sx=%.3f" % [pontos, x, _sentinela.global_position.x])

	func _voltar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		_soltar("direita")
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _jogador.is_on_floor() and y < 0.35 and x < 28.0 and x > 23.2 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
		if y > 0.55:
			_soltar("pulo")
		if _camera.global_position.x < 5.0 and x < 6.0 and x > 1.0 and y < 0.4:
			_pulou = false
			_impulso = false
			_ir("aproximar")
		elif _frames > 500:
			_falhar("não voltou ao vestíbulo. x=%.3f camera=%.2f" % [x, _camera.global_position.x])

	func _aproximar() -> void:
		var x := _jogador.global_position.x
		if x > -2.95:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		if x <= -2.95 and x > -3.4 and _jogador.is_on_floor() and _jogador.global_position.y < 0.3:
			_pulou = false
			_impulso = false
			_ir("pousar")
		elif _frames > 300:
			_falhar("não se aproximou da sacada. x=%.3f" % x)

	func _pousar() -> void:
		var x := _jogador.global_position.x
		var y := _jogador.global_position.y
		if not _pulou and _jogador.is_on_floor() and _frames > 4:
			_pressionar("pulo")
			_pulou = true
		if _pulou and _frames > 4 and not _jogador.is_on_floor():
			_soltar("pulo")
		if _pulou and not _impulso and _frames > 8 and not _jogador.is_on_floor() and y > 1.2 and _jogador.velocity.y < 0.8 and not Input.is_action_pressed("pulo"):
			_pressionar("pulo")
			_impulso = true
		if y > _TOPO + 0.02 and x > -4.15:
			_pressionar("esquerda")
		else:
			_soltar("esquerda")
		var no_alto := _jogador.is_on_floor() and absf(y - _TOPO) < 0.12 and x < -3.7 and x > -5.7
		if no_alto:
			_ir("entrar")
		elif _frames > 280:
			_falhar("não pousou na sacada. x=%.3f y=%.3f" % [x, y])

	func _entrar() -> void:
		if _frames < 6:
			return
		if _frames == 6:
			_pressionar("interagir")
		if _frames == 10:
			_soltar("interagir")
		if _camera.global_position.x > 40.0 and _jogador.is_on_floor() and _jogador.global_position.y < 0.25:
			_ir("ate_altar")
		elif _frames > 140:
			_falhar("não entrou na capela. camera=%.2f aviso=%s" % [_camera.global_position.x, _aviso.text])

	func _ate_altar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_soltar("esquerda")
		_soltar("interagir")
		if _jogador.is_on_floor() and _aviso.visible and _aviso.text == _SALVAR:
			_segurou = 0
			_ir("falha" if fase_inicial == "de_novo" else "salvar")
		elif _frames > 240:
			_falhar("o altar não ofereceu salvar. texto=%s x=%.3f" % [_aviso.text, _jogador.global_position.x])

	func _salvar() -> void:
		if _frames == 4:
			_pressionar("interagir")
		if _frames == 8:
			pass
		if _aviso.visible and _aviso.text == _PRONTO:
			_segurou += 1
		if _segurou > 0 and _segurou < 16:
			if not (_aviso.visible and _aviso.text == _PRONTO):
				_falhar("a confirmação sumiu com a tecla presa. texto=%s" % _aviso.text)
				return
		if _segurou == 16:
			_soltar("interagir")
			var progresso: int = _cena.get_node("ProgressoDoPiloto").get("gravacoes")
			if progresso != 1:
				_falhar("a tecla presa gravou mais de uma vez: %d" % progresso)
				return
			if fase_inicial == "primeira":
				_ir("porta")
			else:
				_conferir_arquivo_derrota()
		elif _frames > 80 and _segurou == 0:
			_falhar("não confirmou o salvamento. texto=%s" % _aviso.text)

	func _falha_de_escrita() -> void:
		if _frames == 2:
			_texto_antes = _ler()
			var pasta := DirAccess.open("user://")
			if pasta == null or pasta.make_dir("catlenight_piloto_11.json.tmp") != OK:
				_falhar("não preparou a falha de escrita")
				return
		if _frames == 6:
			_pressionar("interagir")
		if _aviso.visible and _aviso.text == _FALHA_TEXTO:
			var progresso: int = _cena.get_node("ProgressoDoPiloto").get("gravacoes")
			if _ler() != _texto_antes or progresso != 0:
				_falhar("a falha de escrita alterou o arquivo")
				return
			_soltar("interagir")
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_TEMP))
			print("MEDICAO falha_preservou=true")
			_segurou = 0
			_ir("salvar")
		elif _frames > 40:
			_falhar("a falha não avisou. texto=%s" % _aviso.text)

	func _porta() -> void:
		_soltar("interagir")
		if not Input.is_action_pressed("esquerda"):
			_pressionar("esquerda")
		if _aviso.visible and _aviso.text == _VOLTAR and _jogador.is_on_floor():
			var dados: Variant = JSON.parse_string(_ler())
			var vida: int = _jogador.get("pontos_de_vida")
			var pontos: int = _sentinela.get("pontos_de_vida")
			if vida != 2 or not bool(_jogador.get("salto_duplo_adquirido")) or pontos != 1:
				_falhar("o altar mudou o encontro. vida=%d pontos=%d" % [vida, pontos])
				return
			print("MEDICAO arquivo=%s" % _ler())
			print("MEDICAO salvou vida=%s sentinela=%d camera=%.2f x=%.3f" % [_vida.text, pontos, _camera.global_position.x, _jogador.global_position.x])
			_ok()
		elif _frames > 240:
			_falhar("a porta não ofereceu a volta. texto=%s x=%.3f" % [_aviso.text, _jogador.global_position.x])

	func _conferir_continuacao() -> void:
		if not (_jogador.is_on_floor() and _jogador.global_position.y < 0.2 and _frames > 8):
			if _frames > 60:
				_falhar("não assentou na capela. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			return
		var marco := _cena.get_node("CapelaDaLua/AltarDeSalvamento/AoLadoDoAltar") as Node3D
		var lamina := _jogador.get_node("Golpe/Lamina") as MeshInstance3D
		var gema := _cena.get_node_or_null("Galeria/ReliquiaDoSalto")
		var vida: int = _jogador.get("pontos_de_vida")
		var pontos: int = _sentinela.get("pontos_de_vida")
		var derrotada: bool = _sentinela.get("derrotada")
		var salto: bool = _jogador.get("salto_duplo_adquirido")
		if absf(_jogador.global_position.x - marco.global_position.x) > 0.35:
			_falhar("os pés não ficaram no marcador. x=%.3f marco=%.3f" % [_jogador.global_position.x, marco.global_position.x])
			return
		if absf(_jogador.global_position.z) > 0.001 or absf(_camera.global_position.x - 48.0) > 0.01:
			_falhar("sala ou câmera erradas. z=%.3f camera=%.2f" % [_jogador.global_position.z, _camera.global_position.x])
			return
		if _vida.text != "Vida 2/3" or vida != 2 or not salto or lamina.visible or gema != null:
			_falhar("o progresso do jogador não voltou. vida=%s salto=%s lamina=%s gema=%s" % [_vida.text, salto, lamina.visible, gema != null])
			return
		if absf(_jogador.velocity.x) > 0.05 or absf(_jogador.velocity.z) > 0.05:
			_falhar("a velocidade não zerou")
			return
		if fase_inicial == "derrota":
			var colisao := _sentinela.get_node("Colisao") as CollisionShape3D
			if not derrotada or pontos != 0 or not colisao.disabled:
				_falhar("a sentinela derrotada não voltou livre. pontos=%d" % pontos)
				return
			print("MEDICAO restaurada_derrota camera=%.2f x=%.3f vida=%s" % [_camera.global_position.x, _jogador.global_position.x, _vida.text])
			_ir("sair")
			return
		if derrotada or pontos != 1:
			_falhar("a sentinela não voltou com 1 ponto. pontos=%d derrotada=%s" % [pontos, derrotada])
			return
		print("MEDICAO restaurou sala=capela x=%.3f y=%.3f z=%.3f camera=%.2f vida=%s salto=%s sentinela=%d" % [_jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z, _camera.global_position.x, _vida.text, salto, pontos])
		if fase_inicial == "continuar":
			_alvo = 0
			_apos_golpe = "fim_continuar"
		else:
			_alvo = 0
			_apos_golpe = "voltar"
		_ir("sair")

	func _sair_capela() -> void:
		if _camera.global_position.x < 10.0:
			_soltar("interagir")
			_soltar("esquerda")
			_ir("descer")
			return
		if not (_aviso.visible and _aviso.text == _VOLTAR and _jogador.is_on_floor()):
			_pressionar("esquerda")
			_soltar("interagir")
			if _frames > 300:
				_falhar("não achou a volta. x=%.3f aviso=%s" % [_jogador.global_position.x, _aviso.text])
			return
		_soltar("esquerda")
		if not Input.is_action_pressed("interagir"):
			_pressionar("interagir")

	func _descer() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.is_on_floor() and _jogador.global_position.y < 0.25 and _jogador.global_position.x > -3.2:
			_ir("galeria")
		elif _frames > 220:
			_falhar("não desceu da sacada. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])

	func _atravessar() -> void:
		var vida: int = _jogador.get("pontos_de_vida")
		if vida != 2:
			_falhar("atravessar mudou a vida. vida=%d" % vida)
			return
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		if _jogador.global_position.x > 30.4 and _jogador.is_on_floor():
			print("MEDICAO caminho_livre x=%.3f vida=%s" % [_jogador.global_position.x, _vida.text])
			_ok()
		elif _frames > 240:
			_falhar("o corpo derrotado bloqueou o caminho. x=%.3f" % _jogador.global_position.x)

	func _conferir_novo_jogo() -> void:
		var vida: int = _jogador.get("pontos_de_vida")
		var pontos: int = _sentinela.get("pontos_de_vida")
		var gema := _cena.get_node_or_null("Galeria/ReliquiaDoSalto")
		if _vida.text != "Vida 3/3" or vida != 3 or pontos != 3 or gema == null or bool(_jogador.get("salto_duplo_adquirido")):
			_falhar("novo jogo não começou limpo. vida=%s pontos=%d gema=%s" % [_vida.text, pontos, gema != null])
			return
		if _ler() != _texto_antes:
			_falhar("novo jogo substituiu o arquivo")
			return
		if _camera.global_position.x > 5.0:
			_falhar("novo jogo abriu fora do vestíbulo")
			return
		print("MEDICAO novo vida=%s pontos=%d arquivo_igual=true" % [_vida.text, pontos])
		_ok()

	func _fim_continuar() -> void:
		var dados: Variant = JSON.parse_string(_ler())
		if typeof(dados) != TYPE_DICTIONARY:
			_falhar("arquivo ilegível depois do golpe")
			return
		var ficha := dados as Dictionary
		var pontos: int = _sentinela.get("pontos_de_vida")
		if not bool(_sentinela.get("derrotada")) or pontos != 0:
			_falhar("um golpe não derrotou a sentinela de 1 ponto. pontos=%d" % pontos)
			return
		if int(ficha["vida"]) != 2 or int(ficha["sentinela_vida"]) != 1 or bool(ficha["sentinela_derrotada"]):
			_falhar("sair sem salvar alterou a gravação")
			return
		if int(_jogador.get("pontos_de_vida")) != 2:
			_falhar("o golpe mudou a vida gravada no jogador")
			return
		print("MEDICAO sem_salvar sentinela_viva=%d arquivo_sentinela=%s vida=%s" % [pontos, str(ficha["sentinela_vida"]), _vida.text])
		_ok()

	func _conferir_arquivo_derrota() -> void:
		var dados: Variant = JSON.parse_string(_ler())
		if typeof(dados) != TYPE_DICTIONARY:
			_falhar("arquivo ilegível depois da derrota")
			return
		var ficha := dados as Dictionary
		if int(ficha["sentinela_vida"]) != 0 or not bool(ficha["sentinela_derrotada"]) or int(ficha["vida"]) != 2:
			_falhar("a derrota não entrou no arquivo")
			return
		print("MEDICAO arquivo_derrota=%s" % _ler())
		_ok()

	func _arquivo_ruim() -> void:
		if _frames < 4:
			return
		if bool(_menu.get("continuar_habilitado")) or absf(_camera.global_position.x) > 1.0:
			_falhar("arquivo inconsistente foi aceito. camera=%.2f" % _camera.global_position.x)
			return
		if _ler() != "{ \"versao\": 1, \"sala\": \"capela_da_lua\", \"sentinela_derrotada\": true, \"sentinela_vida\": 1 }":
			_falhar("o menu alterou o arquivo inconsistente")
			return
		_texto_antes = _ler()
		_escrever("isto nao e json")
		_trocar_cena("arquivo_lixo")

	func _arquivo_lixo() -> void:
		if _frames < 4:
			return
		if bool(_menu.get("continuar_habilitado")):
			_falhar("arquivo inválido habilitou Continuar")
			return
		_texto_antes = _ler()
		if _frames == 8:
			_pressionar("pulo")
		if _frames == 12:
			_soltar("pulo")
		if not _menu.visible and not get_tree().paused and _jogador.is_on_floor() and _frames > 16:
			if int(_jogador.get("pontos_de_vida")) != 3 or _ler() != _texto_antes or absf(_camera.global_position.x) > 1.0:
				_falhar("o arquivo inválido alterou a partida ou a gravação")
				return
			_apagar()
			print("MEDICAO invalido_preservado=true")
			_trocar_cena("arquivo_ausente")
		elif _frames > 180:
			_falhar("o jogo novo do arquivo inválido não começou")

	func _arquivo_ausente() -> void:
		if _frames < 4:
			return
		if bool(_menu.get("continuar_habilitado")) or FileAccess.file_exists(_ARQUIVO):
			_falhar("arquivo ausente ainda oferece Continuar")
			return
		print("MEDICAO ausente continuar=false")
		_ok()

	func _esperar_cena() -> void:
		if _frames < 3:
			return
		_abrir_cena()
		_fase = _apos_golpe
		_frames = 0

	func _trocar_cena(proxima: String) -> void:
		get_tree().paused = false
		_cena.queue_free()
		_cena = null
		_menu = null
		_apos_golpe = proxima
		_frames = 0
		_fase = "esperar_cena"

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("atacar")
		_soltar("interagir")
		_frames = 0
		_fase = proxima

	func _ok() -> void:
		if _encerrado:
			return
		var jogadores := 0
		for corpo in _cena.find_children("*", "CharacterBody3D", true, false):
			if corpo.name == "Jogador":
				jogadores += 1
		if jogadores != 1:
			_falhar("jogadores=%d" % jogadores)
			return
		print("RESULTADO ok")
		_encerrado = true
		get_tree().quit(0)

	func _falhar(mensagem: String) -> void:
		if _encerrado:
			return
		_encerrado = true
		print("FALHA " + mensagem)
		get_tree().quit(1)

	func _ler() -> String:
		if not FileAccess.file_exists(_ARQUIVO):
			return ""
		return FileAccess.get_file_as_string(_ARQUIVO)

	func _escrever(texto: String) -> void:
		var arquivo := FileAccess.open(_ARQUIVO, FileAccess.WRITE)
		arquivo.store_string(texto)
		arquivo.close()

	func _apagar() -> void:
		var pasta := DirAccess.open("user://")
		if pasta != null and pasta.file_exists("catlenight_piloto_11.json"):
			pasta.remove("catlenight_piloto_11.json")

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
