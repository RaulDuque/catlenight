class_name Jogador
extends CharacterBody3D

## Origem do personagem: os pés, no ponto local (0, 0, 0).
## A colisão mede 0,80 × 1,70 × 0,50 m e tem o centro em Y = 0,85.
## Visual carrega o GLB, com a sola no mesmo piso e a frente em +X.
## Girar Visual em Y troca o perfil sem mover a colisão.
## modelo_da_corrida só é preenchido na cena do piloto. Vazio, o manequim fica.

@export_group("Movimento")
@export_range(0.5, 12.0, 0.1, "suffix:m/s") var velocidade_caminhada_m_por_s: float = 3.5
@export_range(0.5, 15.0, 0.1, "suffix:m/s") var velocidade_inicial_do_pulo_m_por_s: float = 5.5

@export_group("Queda")
@export var altura_minima_da_sala_m: float = -2.0

@export_group("Corrida")
@export var modelo_da_corrida: PackedScene
@export_range(0.2, 3.0, 0.05) var velocidade_da_animacao: float = 1.3

var _ponto_de_retorno: Vector3 = Vector3.ZERO
var _animacao: AnimationPlayer
var _esqueleto: Skeleton3D
var _correndo := false
var _suspensa := false
var _quadro_suspenso := 0.0

const _CLIP := "corrida"

@onready var _visual: Node3D = $Visual


func _ready() -> void:
	_ponto_de_retorno = global_position
	_trocar_modelo_da_corrida()
	_preparar_corrida()


func definir_ponto_de_retorno(ponto: Vector3) -> void:
	# A passagem chama isto ao entrar em outra sala.
	# A queda seguinte usa esse ponto, no lugar de onde a cena abriu.
	_ponto_de_retorno = ponto


func _physics_process(delta: float) -> void:
	var no_chao: bool = is_on_floor()
	if not no_chao:
		velocity += get_gravity() * delta

	if no_chao and Input.is_action_just_pressed("pulo"):
		velocity.y = velocidade_inicial_do_pulo_m_por_s

	var eixo_horizontal: float = Input.get_axis("esquerda", "direita")
	velocity.x = eixo_horizontal * velocidade_caminhada_m_por_s
	velocity.z = 0.0
	_orientar_visual(eixo_horizontal)

	move_and_slide()
	_travar_no_plano_z()
	_retornar_se_cair_da_sala()
	_atualizar_corrida(is_on_floor(), eixo_horizontal)


func _orientar_visual(eixo_horizontal: float) -> void:
	if eixo_horizontal > 0.0:
		_visual.rotation.y = 0.0
	elif eixo_horizontal < 0.0:
		_visual.rotation.y = PI


func _travar_no_plano_z() -> void:
	global_position.z = 0.0
	velocity.z = 0.0


func _retornar_se_cair_da_sala() -> void:
	if global_position.y >= altura_minima_da_sala_m:
		return
	global_position = _ponto_de_retorno
	velocity = Vector3.ZERO
	reset_physics_interpolation()


func _trocar_modelo_da_corrida() -> void:
	if modelo_da_corrida == null:
		return
	var antigo := _visual.get_node_or_null("Modelo")
	if antigo:
		antigo.free()
	var novo := modelo_da_corrida.instantiate()
	novo.name = "Modelo"
	_visual.add_child(novo)


func _preparar_corrida() -> void:
	_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_esqueleto = _visual.find_child("Skeleton3D", true, false) as Skeleton3D
	if _animacao == null or not _animacao.has_animation(_CLIP):
		_animacao = null
		return
	var clipe := _animacao.get_animation(_CLIP)
	clipe.loop_mode = Animation.LOOP_LINEAR
	_animacao.speed_scale = velocidade_da_animacao


func _atualizar_corrida(no_chao: bool, eixo_horizontal: float) -> void:
	if _animacao == null:
		return
	var deve_correr := no_chao and eixo_horizontal != 0.0
	if not no_chao:
		if _correndo:
			_quadro_suspenso = _animacao.current_animation_position
			_animacao.pause()
			_correndo = false
			_suspensa = true
		return
	if deve_correr:
		if not _correndo:
			_animacao.play(_CLIP)
			if _suspensa:
				_animacao.seek(_quadro_suspenso, true)
			_correndo = true
			_suspensa = false
		return
	if _correndo or _suspensa:
		_animacao.stop()
		if _esqueleto:
			_esqueleto.reset_bone_poses()
		_correndo = false
		_suspensa = false
