extends Node3D

const CASTELO := "res://scenes/prologo/depois_do_prologo.tscn"

@onready var jogador: Jogador = $Jogador
@onready var guardiao := $Guardiao
var _derrotas := 0
var _concluido := false
var _abrindo := false
var _retorno_definido := false

func _ready() -> void:
	$MenuDoPiloto/Titulo.text = "Prólogo · O Guardião do Trono"
	$MenuDoPiloto/Continuar.hide()
	$MenuDoPiloto/Ajuda.text = "Espaço para começar"
	guardiao.preparando_investida.connect(_tocar.bind(preload("res://assets/audio/prologo/aviso.wav")))
	guardiao.atingido.connect(_tocar.bind(preload("res://assets/audio/prologo/impacto.wav")))
	guardiao.vencido.connect(_concluir)
	$HUD/Fim/Seguir.pressed.connect(_abrir_castelo)
	$HUD/Fim/Repetir.pressed.connect(_repetir)
	$HUD.visible = false
	$IndicadorDeVida.visible = false

func _physics_process(_delta: float) -> void:
	if _concluido:
		return
	_apoiar_visual_na_inclinacao(_delta)
	$HUD.visible = true
	$IndicadorDeVida.visible = true
	if jogador.retornos_por_derrota != _derrotas:
		_derrotas = jogador.retornos_por_derrota
		guardiao.recomecar()
		guardiao.global_position = $Vigilia.global_position
	if jogador.position.x < -18 and jogador.position.y < 12 and not _retorno_definido:
		jogador.definir_ponto_de_retorno($RetornoSalao.global_position)
		_retorno_definido = true
	if jogador.position.x < -37 and jogador.position.y < 13:
		guardiao.despertar(jogador)
	if guardiao.em_combate and jogador.position.y < 13 and jogador.position.x < -33:
		$HUD/Pista.text = "Guardião do Trono   %d/%d   ·   ! anuncia a investida" % [guardiao.pontos_de_vida, guardiao.pontos_iniciais]
	elif jogador.position.y > 14:
		$HUD/Pista.text = "Galeria superior   ·   Volte pelo patamar de entrada"
	elif jogador.position.x < -15:
		$HUD/Pista.text = "Salão do trono   ·   Siga para a esquerda"
	else:
		$HUD/Pista.text = "← Subir ao castelo     Espaço  Pular     X  Golpear"

func _concluir() -> void:
	_concluido = true
	$Musica.stop()
	_tocar(preload("res://assets/audio/prologo/vitoria.wav"))
	jogador.encerrar_golpe.call_deferred()
	$HUD/Pista.hide()
	$HUD/Fim.show()
	$HUD/Fim/Seguir.grab_focus()
	get_tree().paused = true

func _abrir_castelo() -> void:
	_mudar_cena(CASTELO)

func _repetir() -> void:
	_mudar_cena(scene_file_path)

func _mudar_cena(caminho: String) -> void:
	if _abrindo:
		return
	_abrindo = true
	$Efeito.stop()
	$Musica.stop()
	get_tree().paused = false
	var erro := get_tree().change_scene_to_file(caminho)
	if erro != OK:
		push_error(error_string(erro))
		get_tree().paused = true
		_abrindo = false


func _tocar(som: AudioStream) -> void:
	$Efeito.stream = som
	$Efeito.play()

func _apoiar_visual_na_inclinacao(delta: float) -> void:
	# A origem física da caixa sobe pelo canto dianteiro. Estime o apoio no eixo da passada.
	var visual: Node3D = jogador.get_node("Visual")
	var alvo := 0.0
	if jogador.is_on_floor():
		var normal := jogador.get_floor_normal()
		if normal.y > 0.5:
			alvo = -0.30 * absf(normal.x / normal.y)
	visual.position.y = move_toward(visual.position.y, alvo, 3.0 * delta)
