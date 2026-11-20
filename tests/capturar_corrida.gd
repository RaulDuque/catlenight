extends Node

## Percorre a cena do piloto e guarda quadros da corrida. Não faz parte do jogo.

const _PASTA := "D:/Progr/catlenight/MD-usario/relatorios/evidencias/"

var _sala: Node3D
var _jogador: CharacterBody3D
var _visual: Node3D
var _animacao: AnimationPlayer
var _esqueleto: Skeleton3D
var _pe_esquerdo := -1
var _pe_direito := -1
var _quadril := -1
var _fase := "cair"
var _frames := 0
var _pronto := false
var _falhas: PackedStringArray = []
var _pendentes: PackedStringArray = []
var _apoios := 0
var _pe_atual := ""
var _x_apoio := 0.0
var _frames_apoio := 0
var _maior_deslize := 0.0
var _quadro_no_ar := -1.0
var _quadro_ao_pousar := -1.0
var _quadril_inicio := 0.0
var _quadril_depois := 0.0
var _x_plataforma := 0.0
var _y_plataforma := 0.0
var _z_max := 0.0


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	_sala = (load("res://scenes/verification/04c_corrida_mixamo.tscn") as PackedScene).instantiate()
	add_child(_sala)
	_jogador = _sala.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_esqueleto = _visual.find_child("Skeleton3D", true, false) as Skeleton3D
	if _animacao == null:
		_falhar("AnimationPlayer ausente")
	else:
		print("CLIPES %s" % _animacao.get_animation_list())
		if _animacao.has_animation("corrida"):
			print("CLIP duracao=%.4f" % _animacao.get_animation("corrida").length)
	if _esqueleto == null:
		_falhar("Skeleton3D ausente")
	else:
		_pe_esquerdo = _indice("LeftFoot")
		_pe_direito = _indice("RightFoot")
		_quadril = _indice("Hips")
		print("OSSOS peE=%d peD=%d quadril=%d" % [_pe_esquerdo, _pe_direito, _quadril])
	_pronto = true


func _physics_process(_delta: float) -> void:
	if not _pronto:
		return
	_frames += 1
	_z_max = maxf(_z_max, absf(_jogador.global_position.z))
	match _fase:
		"cair":
			_cair()
		"direita":
			_direita()
		"repouso":
			_repouso()
		"esquerda":
			_esquerda()
		"pulo":
			_pulo()
		"ar":
			_ar()
		"plataforma":
			_plataforma()


func _process(_delta: float) -> void:
	if _pendentes.is_empty():
		return
	var imagem := get_viewport().get_texture().get_image()
	var caminho := _pendentes[0]
	_pendentes.remove_at(0)
	imagem.save_png(caminho)
	print("QUADRO %s" % caminho)


func _cair() -> void:
	if _jogador.is_on_floor() and absf(_jogador.global_position.y) <= 0.08:
		_pressionar("direita")
		_frames = 0
		_fase = "direita"
	elif _frames > 180:
		_falhar("não pousou")
		_encerrar()


func _direita() -> void:
	if _jogador.velocity.x > 2.0:
		_medir_deslize(1.0)
	if _frames == 24 and _quadril >= 0:
		_quadril_inicio = _quadril_local()
	if _frames == 52 and _quadril >= 0:
		_quadril_depois = _quadril_local()
	if _apoios < 4 and _frames >= 24 and (_frames - 24) % 11 == 0:
		_pedir_quadro("04c-godot-apoio-%02d.png" % (_apoios + 1))
		_apoios += 1
	if _jogador.global_position.x > -0.2:
		_soltar("direita")
		_frames = 0
		_fase = "repouso"


func _repouso() -> void:
	if _frames < 8:
		return
	if _animacao != null and _animacao.is_playing():
		_falhar("a corrida continuou depois de soltar a seta")
	if absf(_visual.rotation.y) > 0.01:
		_falhar("soltar a direita girou o visual: %.3f" % _visual.rotation.y)
	_pedir_quadro("04c-godot-repouso.png")
	_pressionar("esquerda")
	_frames = 0
	_fase = "esquerda"


func _esquerda() -> void:
	if _frames < 12:
		return
	if absf(wrapf(_visual.rotation.y - PI, -PI, PI)) > 0.01:
		_falhar("esquerda não virou para -X: %.3f" % _visual.rotation.y)
	if _frames == 12:
		_pedir_quadro("04c-godot-esquerda.png")
	if _jogador.global_position.x < -1.2:
		_soltar("esquerda")
		_pressionar("direita")
		_frames = 0
		_fase = "pulo"


func _pulo() -> void:
	if _jogador.global_position.x >= -1.5 and _jogador.is_on_floor() and not Input.is_action_pressed("pulo"):
		_pressionar("pulo")
	if not _jogador.is_on_floor() and _jogador.velocity.y > 0.0:
		_quadro_no_ar = _animacao.current_animation_position if _animacao != null else -1.0
		if _animacao != null and _animacao.is_playing():
			_falhar("a corrida continuou no ar")
		_frames = 0
		_fase = "ar"
	elif _frames > 240:
		_falhar("não saiu do chão para a plataforma")
		_encerrar()


func _ar() -> void:
	var sobre := _jogador.is_on_floor() and _jogador.global_position.y > 0.45
	if sobre:
		_quadro_ao_pousar = _animacao.current_animation_position if _animacao != null else -1.0
		_x_plataforma = _jogador.global_position.x
		_y_plataforma = _jogador.global_position.y
		if _animacao != null and not _animacao.is_playing() and absf(_jogador.velocity.x) > 0.1:
			_falhar("a corrida não retomou na plataforma")
		_soltar("pulo")
		_soltar("direita")
		_frames = 0
		_fase = "plataforma"
	elif _frames > 180:
		_falhar("não pousou na plataforma")
		_encerrar()


func _plataforma() -> void:
	if _frames < 6:
		return
	_encerrar()


func _medir_deslize(sentido: float) -> void:
	if _pe_esquerdo < 0 or _pe_direito < 0:
		return
	var esquerdo := _osso_global(_pe_esquerdo)
	var direito := _osso_global(_pe_direito)
	var apoio := "E" if esquerdo.y <= direito.y else "D"
	var x := esquerdo.x if apoio == "E" else direito.x
	if apoio != _pe_atual:
		if _pe_atual != "" and _frames_apoio >= 4:
			var x_plantado := esquerdo.x if _pe_atual == "E" else direito.x
			var deslize := (x_plantado - _x_apoio) * sentido
			_maior_deslize = maxf(_maior_deslize, deslize)
			print("DESLIZE pe=%s dx=%.4f quadros=%d" % [_pe_atual, deslize, _frames_apoio])
		_pe_atual = apoio
		_x_apoio = x
		_frames_apoio = 0
		return
	_frames_apoio += 1


func _quadril_local() -> float:
	var ponto := _esqueleto.global_transform * _esqueleto.get_bone_global_pose(_quadril).origin
	return (_jogador.global_transform.affine_inverse() * ponto).x


func _indice(final: String) -> int:
	for indice in _esqueleto.get_bone_count():
		var nome := _esqueleto.get_bone_name(indice)
		if nome.ends_with(final):
			return indice
	return -1


func _osso_global(indice: int) -> Vector3:
	return _esqueleto.global_transform * _esqueleto.get_bone_global_pose(indice).origin


func _pedir_quadro(nome: String) -> void:
	_pendentes.append(_PASTA + nome)


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


func _falhar(texto: String) -> void:
	_falhas.append(texto)
	print("FALHA %s" % texto)


func _encerrar() -> void:
	print("MEDICAO deslize_pe_m %.4f" % _maior_deslize)
	print("MEDICAO quadril_local inicio %.4f depois %.4f" % [_quadril_inicio, _quadril_depois])
	print("MEDICAO quadro_no_ar %.4f quadro_ao_pousar %.4f" % [_quadro_no_ar, _quadro_ao_pousar])
	print("MEDICAO plataforma x=%.4f y=%.4f" % [_x_plataforma, _y_plataforma])
	print("MEDICAO z_max=%.6f" % _z_max)
	print("MEDICAO rotacao %.4f" % _visual.rotation.y)
	if _z_max > 0.001:
		_falhar("Z saiu do plano")
	if absf(_quadril_depois - _quadril_inicio) > 0.35:
		_falhar("o modelo se afastou da colisão")
	if _falhas.is_empty():
		print("RESULTADO ok")
		get_tree().quit(0)
	else:
		print("RESULTADO falhou")
		get_tree().quit(1)
