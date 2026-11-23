extends "res://scenes/enemies/sentinela_da_galeria.gd"

signal vencido
signal preparando_investida
signal atingido

@export var distancia_da_investida := 2.7
var em_combate := false
var _fase := "repouso"
var _tempo := 0.0
var _alvo_x := 0.0
var _jogador: Jogador

func despertar(jogador: Jogador) -> void:
	if em_combate or derrotada:
		return
	em_combate = true
	_jogador = jogador
	_preparar()

func _preparar() -> void:
	sentido = 1 if _jogador.position.x >= position.x else -1
	_apontar()
	_alvo_x = clampf(position.x + sentido * distancia_da_investida, _limite_esquerdo_x, _limite_direito_x)
	_fase = "aviso"
	_tempo = 0.85 if pontos_de_vida > 2 else 0.55
	$Visual/Aviso.visible = true
	preparando_investida.emit()

func _physics_process(delta: float) -> void:
	if not em_combate or derrotada:
		return
	if global_position.distance_to(_jogador.global_position) > 8.0:
		return
	_tempo -= delta
	match _fase:
		"aviso":
			if _tempo <= 0:
				$Visual/Aviso.visible = false
				_fase = "investida"
		"investida":
			var posicao := global_position
			posicao.x = move_toward(posicao.x, _alvo_x, 4.0 * delta)
			global_position = posicao
			if is_equal_approx(posicao.x, _alvo_x):
				var distancia: Vector3 = _jogador.global_position - posicao
				if absf(distancia.x) < 1.25 and absf(distancia.y) < 0.75:
					_jogador.receber_dano_de_inimigo()
				_fase = "recuperacao"
				_tempo = 1.15
		"recuperacao":
			if _tempo <= 0:
				_preparar()

func receber_acerto() -> void:
	if not em_combate or derrotada:
		return
	super()
	if not derrotada:
		atingido.emit()
	if derrotada:
		$Visual/Aviso.visible = false
		vencido.emit()

func recomecar() -> void:
	em_combate = false
	pontos_de_vida = pontos_iniciais
	_fase = "repouso"
	$Visual/Aviso.visible = false
