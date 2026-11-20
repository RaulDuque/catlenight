extends SceneTree

## Percurso do piloto 12, com user:// isolado. Não faz parte do jogo.


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
	const _CENA := "res://scenes/verification/12_mapa_das_salas.tscn"
	const _ARQUIVO := "user://catlenight_piloto_11.json"
	const _SALVAR := "↑ Salvar progresso"
	const _PRONTO := "Progresso salvo"
	const _LEGADO := "{\n\t\"marcador\": \"AoLadoDoAltar\",\n\t\"sala\": \"capela_da_lua\",\n\t\"salto_duplo\": true,\n\t\"sentinela_derrotada\": false,\n\t\"sentinela_vida\": 1,\n\t\"versao\": 1,\n\t\"vida\": 2,\n\t\"vida_maxima\": 3\n}"

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
	var _momento := ""
	var _passo := 0
	var _texto_antes := ""
	var _segurou := 0
	var _px := 0.0
	var _py := 0.0
	var _sx := 0.0
	var _sy := 0.0
	var _vida_pausa := 0
	var _golpe := ""
	var _lamina_antes := false
	var _t0 := 0
	var _sx_depois := 0.0

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		if fase_inicial == "legado":
			_escrever(_LEGADO)
		_texto_antes = _ler()
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
		if _encerrado or not _pronto or _cena == null:
			return
		_frames += 1
		match _fase:
			"menu":
				_menu_escolher(fase_inicial == "continuar" or fase_inicial == "legado")
			"cair":
				_cair()
			"mapa":
				_mapa()
			"galeria":
				_galeria()
			"plataforma":
				_plataforma()
			"coletar":
				_coletar()
			"posicionar":
				_posicionar()
			"pausa":
				_pausa()
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
			"conferir":
				_conferir_continuacao()

	func _menu_escolher(continuar: bool) -> void:
		if _menu == null or not _menu.visible:
			if get_tree().paused:
				return
			_soltar("pulo")
			_soltar("direita")
			_frames = 0
			if fase_inicial == "primeira" or fase_inicial == "novo_mapa":
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
			_conferir_tecla()
			if _encerrado:
				return
			var principal := str(ProjectSettings.get_setting("application/run/main_scene"))
			if principal != "res://scenes/verification/main.tscn":
				_falhar("o F5 mudou: %s" % principal)
				return
		if _jogador.is_on_floor() and _frames > 12:
			if fase_inicial == "novo_mapa":
				_ir_mapa("novo_mapa")
			else:
				_ir_mapa("vestibulo")

	func _galeria() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_soltar("esquerda")
		var x := _jogador.global_position.x
		if _camera.global_position.x > 20.0 and x > 18.0 and x < 22.5 and _jogador.is_on_floor() and _jogador.global_position.y < 0.4:
			_ir_mapa("galeria")
		elif _frames > 450:
			_falhar("não chegou à galeria. x=%.3f" % x)

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
			_ir("coletar")
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
			_ir("posicionar")
		elif _frames > 240:
			_falhar("não coletou a relíquia. x=%.3f" % x)

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
			_ir("pausa")
		elif _frames > 500:
			_falhar("não chegou ao alcance. x=%.3f y=%.3f" % [x, y])

	func _pausa() -> void:
		var mapa := _folha()
		var lamina := _jogador.get_node("Golpe/Lamina") as MeshInstance3D
		if _passo == 0:
			if not bool(mapa.get("aberto")):
				if _frames == 3:
					_pressionar("abrir_mapa")
				if _frames == 8:
					_soltar("abrir_mapa")
				if _frames > 40:
					_falhar("o mapa da pausa não abriu")
				return
			_soltar("abrir_mapa")
			if Input.is_action_pressed("abrir_mapa"):
				return
			_px = _jogador.global_position.x
			_py = _jogador.global_position.y
			_sx = _sentinela.global_position.x
			_sy = _sentinela.global_position.y
			_vida_pausa = int(_jogador.get("pontos_de_vida"))
			_golpe = String(_jogador.get("_fase_do_golpe"))
			_lamina_antes = lamina.visible
			_pressionar("atacar")
			_pressionar("pulo")
			_pressionar("interagir")
			_t0 = Time.get_ticks_msec()
			_passo = 1
			_frames = 0
			return
		if _passo == 1:
			var espera: int = Time.get_ticks_msec() - _t0
			if not get_tree().paused or not bool(mapa.get("aberto")):
				_falhar("a consulta não segurou a pausa. ms=%d pausado=%s aberto=%s" % [espera, get_tree().paused, bool(mapa.get("aberto"))])
				return
			if espera < 1100:
				return
			if absf(_jogador.global_position.x - _px) > 0.001 or absf(_jogador.global_position.y - _py) > 0.001:
				_falhar("o jogador andou com o mapa aberto")
				return
			if absf(_sentinela.global_position.x - _sx) > 0.001 or absf(_sentinela.global_position.y - _sy) > 0.001:
				_falhar("a sentinela andou com o mapa aberto. dx=%.4f" % absf(_sentinela.global_position.x - _sx))
				return
			if int(_jogador.get("pontos_de_vida")) != _vida_pausa or _vida.text != "Vida %d/3" % _vida_pausa:
				_falhar("a vida mudou com o mapa aberto. vida=%d" % int(_jogador.get("pontos_de_vida")))
				return
			if String(_jogador.get("_fase_do_golpe")) != _golpe or lamina.visible != _lamina_antes:
				_falhar("o golpe mudou com o mapa aberto")
				return
			print("MEDICAO pausa ms=%d x=%.3f sx=%.3f vida=%d golpe=%s" % [espera, _px, _sx, _vida_pausa, _golpe])
			_passo = 2
			_frames = 0
			return
		if _passo == 2:
			if bool(mapa.get("aberto")):
				if _frames == 2:
					_pressionar("abrir_mapa")
				if _frames == 5:
					_soltar("abrir_mapa")
				if _frames > 40:
					_falhar("não fechou o mapa da pausa")
				return
			_passo = 4
			_frames = 0
			return
		if _passo == 4:
			if get_tree().paused:
				_falhar("o jogo continuou pausado")
				return
			if _frames < 10:
				if not _jogador.is_on_floor() or _jogador.velocity.y > 0.05:
					_falhar("o pulo saiu ao fechar o mapa. y=%.3f vy=%.3f" % [_jogador.global_position.y, _jogador.velocity.y])
					return
				if String(_jogador.get("_fase_do_golpe")) != "" or lamina.visible:
					_falhar("o golpe saiu ao fechar o mapa")
					return
				if _camera.global_position.x > 30.0 or (_aviso.visible and _aviso.text == _PRONTO):
					_falhar("fechar o mapa disparou passagem ou salvamento")
					return
				return
			_soltar("atacar")
			_soltar("pulo")
			_soltar("interagir")
			_sx_depois = _sentinela.global_position.x
			_passo = 3
			_frames = 0
			return
		if absf(_sentinela.global_position.x - _sx_depois) > 0.08:
			print("MEDICAO patrulha dx=%.3f" % absf(_sentinela.global_position.x - _sx_depois))
			_ir("voltar")
		elif _frames > 180:
			_falhar("a sentinela não voltou a andar. sx=%.3f" % _sentinela.global_position.x)

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
			if not bool(_jogador.get("salto_duplo_adquirido")):
				_falhar("voltou sem a relíquia")
				return
			_pulou = false
			_impulso = false
			_ir_mapa("reliquia")
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
			_ir_mapa("capela")
		elif _frames > 140:
			_falhar("não entrou na capela. camera=%.2f aviso=%s" % [_camera.global_position.x, _aviso.text])

	func _ate_altar() -> void:
		if not Input.is_action_pressed("direita"):
			_pressionar("direita")
		_soltar("esquerda")
		_soltar("interagir")
		if _jogador.is_on_floor() and _aviso.visible and _aviso.text == _SALVAR:
			_segurou = 0
			_ir_mapa("altar")
		elif _frames > 240:
			_falhar("o altar não ofereceu salvar. texto=%s x=%.3f" % [_aviso.text, _jogador.global_position.x])

	func _salvar() -> void:
		if _frames == 4:
			_pressionar("interagir")
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
			_conferir_arquivo_novo()
		elif _frames > 80 and _segurou == 0:
			_falhar("não confirmou o salvamento. texto=%s" % _aviso.text)

	func _conferir_continuacao() -> void:
		if _frames < 8:
			return
		if not _jogador.is_on_floor() or _camera.global_position.x < 40.0:
			if _frames > 40:
				_falhar("continuar não ficou na capela. camera=%.2f" % _camera.global_position.x)
			return
		var dados := _json(_texto_antes)
		if dados.is_empty():
			_falhar("a gravação lida não é válida")
			return
		if absf(_jogador.global_position.x - 47.95) > 0.03 or absf(_jogador.global_position.y) > 0.05 or absf(_jogador.global_position.z) > 0.001:
			_falhar("os pés não voltaram ao altar. x=%.3f y=%.3f" % [_jogador.global_position.x, _jogador.global_position.y])
			return
		if int(_jogador.get("pontos_de_vida")) != int(dados["vida"]) or _vida.text != "Vida %d/3" % int(dados["vida"]):
			_falhar("a vida restaurada diverge do arquivo. vida=%s" % _vida.text)
			return
		if bool(_jogador.get("salto_duplo_adquirido")) != bool(dados["salto_duplo"]):
			_falhar("a relíquia restaurada diverge do arquivo")
			return
		if int(_sentinela.get("pontos_de_vida")) != int(dados["sentinela_vida"]):
			_falhar("a sentinela restaurada diverge do arquivo")
			return
		if _ler() != _texto_antes:
			_falhar("continuar reescreveu o arquivo antes do mapa")
			return
		if fase_inicial == "legado":
			if int(dados["vida"]) != 2 or int(dados["sentinela_vida"]) != 1 or not bool(dados["salto_duplo"]):
				_falhar("o arquivo legado não trouxe os valores da etapa 11")
				return
			if dados.has("salas_visitadas") or dados.has("sala_atual"):
				_falhar("o arquivo legado já trazia o mapa")
				return
		_ir_mapa(fase_inicial)

	func _mapa() -> void:
		var mapa := _folha()
		if mapa == null:
			_falhar("o mapa não está na cena")
			return
		if _passo == 0:
			if not bool(mapa.get("aberto")):
				if _frames == 3:
					_pressionar("abrir_mapa")
				if _frames == 8:
					_soltar("abrir_mapa")
				if _frames > 40:
					_falhar("o mapa não abriu em %s" % _momento)
				return
			_soltar("abrir_mapa")
			if Input.is_action_pressed("abrir_mapa"):
				return
			if not get_tree().paused:
				_falhar("o mapa aberto não pausou em %s" % _momento)
				return
			_conferir_momento(mapa)
			if _encerrado:
				return
			_passo = 1
			_frames = 0
			return
		if not bool(mapa.get("aberto")):
			if get_tree().paused:
				_falhar("o mapa fechou e o jogo continuou pausado")
				return
			if _ler() != _texto_antes and _momento != "altar":
				_falhar("abrir o mapa alterou o arquivo em %s" % _momento)
				return
			_depois_do_mapa()
			return
		if _frames == 3:
			_pressionar("abrir_mapa")
		if _frames == 6:
			_soltar("abrir_mapa")
		if _frames > 40:
			_falhar("o mapa não fechou em %s" % _momento)

	func _conferir_momento(mapa: Node) -> void:
		var atual := String(mapa.get("sala_atual_id"))
		var vistas := _lista(mapa.get("visitadas"))
		var ligacoes := mapa.call("ligacoes") as Array
		var capela := mapa.get_node("NomeCapela") as Label
		var marcador := mapa.get_node("Marcador") as Label
		var ajuda := mapa.get_node("Ajuda") as Label
		var titulo := mapa.get_node("Titulo") as Label
		var sala := _cena.get("sala_atual") as Node3D
		print("MEDICAO mapa momento=%s atual=%s visitadas=%s ligacoes=%s sala=%s" % [ _momento, atual, ",".join(vistas), ",".join(_textos(ligacoes)), sala.name if sala != null else "" ])
		if titulo.text != "Mapa" or ajuda.text != "M Fecha o mapa" or not marcador.visible or marcador.text != "Você está aqui":
			_falhar("o mapa não explica como voltar ou onde o jogador está")
			return
		var esperado_atual := ""
		var esperado_vistas := ""
		var espera_capela := false
		match _momento:
			"vestibulo", "novo_mapa":
				esperado_atual = "vestibulo"
				esperado_vistas = "vestibulo"
			"galeria":
				esperado_atual = "galeria"
				esperado_vistas = "vestibulo,galeria"
			"reliquia":
				esperado_atual = "vestibulo"
				esperado_vistas = "vestibulo,galeria"
			"capela", "altar", "continuar", "legado":
				esperado_atual = "capela_da_lua"
				esperado_vistas = "vestibulo,galeria,capela_da_lua"
				espera_capela = true
			_:
				_falhar("momento desconhecido")
				return
		if atual != esperado_atual or ",".join(vistas) != esperado_vistas:
			_falhar("o mapa de %s mostrou atual=%s visitadas=%s" % [_momento, atual, ",".join(vistas)])
			return
		if capela.visible != espera_capela:
			_falhar("a capela apareceu no momento errado: %s" % _momento)
			return
		var marca_x := 500.0
		var marca_y := 330.0
		if esperado_atual == "galeria":
			marca_x = 820.0
		elif esperado_atual == "capela_da_lua":
			marca_x = 250.0
			marca_y = 140.0
		if absf(marcador.position.x - marca_x) > 1.0 or marcador.position.y < marca_y + 80.0:
			_falhar("o marcador não ficou na sala atual")
			return
		if espera_capela:
			if not ligacoes.has("vestibulo-galeria") or not ligacoes.has("vestibulo-capela_da_lua"):
				_falhar("faltou uma ligação no caminho completo")
				return
		else:
			if ligacoes.has("vestibulo-capela_da_lua") or vistas.has("capela_da_lua"):
				_falhar("a passagem da capela foi revelada em %s" % _momento)
				return
		if _momento == "galeria" and not ligacoes.has("vestibulo-galeria"):
			_falhar("a galeria apareceu sem a ligação")
			return
		if _momento == "reliquia" and not bool(_jogador.get("salto_duplo_adquirido")):
			_falhar("o terceiro mapa foi aberto sem a relíquia")
			return
		if _momento == "altar":
			var gravacoes: int = _cena.get_node("ProgressoDoPiloto").get("gravacoes")
			if gravacoes != 0 or _ler() != "":
				_falhar("consultar o mapa gravou a partida")
				return
		if _momento == "novo_mapa" or _momento == "continuar" or _momento == "legado":
			if _ler() != _texto_antes:
				_falhar("o mapa reescreveu a gravação em %s" % _momento)
				return
		if sala == null:
			_falhar("a sala atual do percurso sumiu")
			return
		var nome_esperado := "Vestibulo"
		if esperado_atual == "galeria":
			nome_esperado = "Galeria"
		elif esperado_atual == "capela_da_lua":
			nome_esperado = "CapelaDaLua"
		if sala.name != nome_esperado:
			_falhar("o mapa e a sala do percurso divergiram. sala=%s" % sala.name)

	func _conferir_arquivo_novo() -> void:
		var texto := _ler()
		var dados := _json(texto)
		if dados.is_empty():
			_falhar("a gravação nova não validou")
			return
		var vistas := _lista(dados["salas_visitadas"])
		if String(dados["sala_atual"]) != "capela_da_lua" or ",".join(vistas) != "vestibulo,galeria,capela_da_lua":
			_falhar("a gravação não trouxe o mapa. atual=%s" % String(dados.get("sala_atual", "")))
			return
		if int(dados["vida"]) != int(_jogador.get("pontos_de_vida")) or bool(dados["salto_duplo"]) != true:
			_falhar("a gravação não trouxe vida e relíquia")
			return
		if int(dados["sentinela_vida"]) != int(_sentinela.get("pontos_de_vida")):
			_falhar("a gravação não trouxe a sentinela")
			return
		print("MEDICAO arquivo=%s" % texto)
		_ok()

	func _depois_do_mapa() -> void:
		match _momento:
			"vestibulo":
				_ir("galeria")
			"galeria":
				_ir("plataforma")
			"reliquia":
				_ir("aproximar")
			"capela":
				_ir("ate_altar")
			"altar":
				_ir("salvar")
			"novo_mapa", "continuar", "legado":
				_ok()
			_:
				_falhar("não há continuação para %s" % _momento)

	func _ir_mapa(momento: String) -> void:
		_momento = momento
		_passo = 0
		_ir("mapa")

	func _conferir_tecla() -> void:
		if not InputMap.has_action("abrir_mapa"):
			_falhar("abrir_mapa não existe")
			return
		var eventos := InputMap.action_get_events("abrir_mapa")
		if eventos.size() != 1:
			_falhar("abrir_mapa não tem um único evento")
			return
		var tecla := eventos[0] as InputEventKey
		if tecla == null or tecla.physical_keycode != KEY_M:
			_falhar("abrir_mapa não está na tecla M")
			return
		for acao in InputMap.get_actions():
			if String(acao) == "abrir_mapa":
				continue
			for evento in InputMap.action_get_events(acao):
				var outra := evento as InputEventKey
				if outra != null and outra.physical_keycode == KEY_M:
					_falhar("M já pertence a %s" % String(acao))
					return

	func _folha() -> Node:
		return get_tree().get_first_node_in_group("mapa_das_salas")

	func _lista(valor: Variant) -> PackedStringArray:
		var saida: PackedStringArray = []
		if typeof(valor) != TYPE_ARRAY:
			return saida
		for item in valor:
			saida.append(String(item))
		return saida

	func _textos(valor: Array) -> PackedStringArray:
		var saida: PackedStringArray = []
		for item in valor:
			saida.append(String(item))
		return saida

	func _json(texto: String) -> Dictionary:
		var leitor := JSON.new()
		if leitor.parse(texto) != OK or typeof(leitor.data) != TYPE_DICTIONARY:
			return {}
		return leitor.data as Dictionary

	func _ir(proxima: String) -> void:
		_soltar("esquerda")
		_soltar("direita")
		_soltar("pulo")
		_soltar("atacar")
		_soltar("interagir")
		_soltar("abrir_mapa")
		_passo = 0
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
