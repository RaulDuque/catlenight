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

@export_group("Golpe")
@export_range(0.7, 2.2, 0.05, "suffix:m") var alcance_do_golpe_m: float = 1.15:
	set(valor):
		alcance_do_golpe_m = valor
		if is_node_ready():
			_ajustar_lamina()
@export_range(0.05, 0.35, 0.01, "suffix:s") var duracao_ativa_s: float = 0.16

var _ponto_de_retorno: Vector3 = Vector3.ZERO
var _animacao: AnimationPlayer
var _esqueleto: Skeleton3D
var _correndo := false
var _suspensa := false
var _quadro_suspenso := 0.0
var _fase_do_golpe := ""
var _tempo_do_golpe := 0.0
var _alvos_deste_golpe: Array[int] = []
var _material_da_lamina: StandardMaterial3D
var _area_fora_do_corpo := false
var acertos_deste_golpe := 0
var quadros_sobre_o_alvo := 0

const _CLIP := "corrida"
const _ESPERA_DO_GOLPE_S := 0.06
const _RECUPERACAO_DO_GOLPE_S := 0.22
const _INICIO_DA_LAMINA_M := 0.45
const _ALTURA_DA_LAMINA_M := 0.5
const _Y_DA_LAMINA_M := 1.15
const _PROFUNDIDADE_DA_LAMINA_M := 0.3

@onready var _visual: Node3D = $Visual
@onready var _golpe: Node3D = $Golpe
@onready var _lamina: MeshInstance3D = $Golpe/Lamina
@onready var _area: Area3D = $Golpe/Area
@onready var _forma: CollisionShape3D = $Golpe/Area/Forma


func _ready() -> void:
	_ponto_de_retorno = global_position
	_trocar_modelo_da_corrida()
	_preparar_corrida()
	_material_da_lamina = StandardMaterial3D.new()
	_material_da_lamina.albedo_color = Color(0.93, 0.84, 0.55)
	_material_da_lamina.roughness = 0.35
	_material_da_lamina.emission_enabled = true
	_material_da_lamina.emission = Color(0.85, 0.72, 0.35)
	_material_da_lamina.emission_energy_multiplier = 0.6
	_ajustar_lamina()
	_lamina.visible = false
	_area.monitoring = false
	_area.collision_layer = 1
	_area.collision_mask = 1
	call_deferred("_soltar_area")


func _soltar_area() -> void:
	var raiz := get_parent()
	if raiz == null:
		return
	var nova := Area3D.new()
	nova.name = "AreaDoGolpe"
	nova.collision_layer = 1
	nova.collision_mask = 1
	nova.monitoring = false
	var forma := CollisionShape3D.new()
	forma.name = "Forma"
	nova.add_child(forma)
	raiz.add_child(nova)
	nova.body_entered.connect(_ao_atingir)
	if is_instance_valid(_area):
		_area.queue_free()
	_area = nova
	_forma = forma
	_area_fora_do_corpo = true
	nova.add_to_group("area_do_golpe")


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
	_atualizar_golpe(delta, is_on_floor())


func _orientar_visual(eixo_horizontal: float) -> void:
	if _fase_do_golpe != "":
		return
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
	encerrar_golpe()
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


func encerrar_golpe() -> void:
	_fase_do_golpe = ""
	_tempo_do_golpe = 0.0
	_alvos_deste_golpe.clear()
	if _lamina:
		_lamina.visible = false
	if _area:
		_area.monitoring = false


func _atualizar_golpe(delta: float, no_chao: bool) -> void:
	if _fase_do_golpe == "":
		if no_chao and Input.is_action_just_pressed("atacar"):
			_comecar_golpe()
		return
	if _fase_do_golpe == "ativo":
		_posicionar_area()
		for corpo in _area.get_overlapping_bodies():
			if corpo.has_method("receber_acerto"):
				quadros_sobre_o_alvo += 1
	_tempo_do_golpe -= delta
	if _tempo_do_golpe > 0.0:
		return
	if _fase_do_golpe == "espera":
		_ligar_lamina()
	elif _fase_do_golpe == "ativo":
		_lamina.visible = false
		_area.monitoring = false
		_fase_do_golpe = "recuperacao"
		_tempo_do_golpe = _RECUPERACAO_DO_GOLPE_S
	else:
		_fase_do_golpe = ""


func _comecar_golpe() -> void:
	# A direção fica presa no nó Golpe. O Visual pode esperar até o fim.
	_fase_do_golpe = "espera"
	_tempo_do_golpe = _ESPERA_DO_GOLPE_S
	_alvos_deste_golpe.clear()
	acertos_deste_golpe = 0
	quadros_sobre_o_alvo = 0
	_golpe.rotation.y = _visual.rotation.y
	_lamina.visible = false
	_area.monitoring = false


func _ligar_lamina() -> void:
	_fase_do_golpe = "ativo"
	_tempo_do_golpe = duracao_ativa_s
	_ajustar_lamina()
	_area.monitoring = true
	_posicionar_area()
	_lamina.visible = true


func _ao_atingir(corpo: Node3D) -> void:
	if _fase_do_golpe != "ativo":
		return
	_registrar_acerto(corpo)


func _registrar_acerto(corpo: Node3D) -> void:
	if not corpo.has_method("receber_acerto"):
		return
	var id := corpo.get_instance_id()
	if _alvos_deste_golpe.has(id):
		return
	_alvos_deste_golpe.append(id)
	acertos_deste_golpe += 1
	corpo.receber_acerto()


func _ajustar_lamina() -> void:
	var centro := _centro_da_lamina()
	var comprimento := maxf(alcance_do_golpe_m - _INICIO_DA_LAMINA_M, 0.2)
	var malha := BoxMesh.new()
	malha.size = Vector3(comprimento, _ALTURA_DA_LAMINA_M, _PROFUNDIDADE_DA_LAMINA_M)
	_lamina.mesh = malha
	_lamina.set_surface_override_material(0, _material_da_lamina)
	_lamina.position = centro
	var forma := BoxShape3D.new()
	forma.size = malha.size
	_forma.shape = forma
	_forma.position = Vector3.ZERO
	if _area_fora_do_corpo:
		_posicionar_area()
	else:
		_area.position = centro


func _centro_da_lamina() -> Vector3:
	var comprimento := maxf(alcance_do_golpe_m - _INICIO_DA_LAMINA_M, 0.2)
	return Vector3(_INICIO_DA_LAMINA_M + comprimento * 0.5, _Y_DA_LAMINA_M, 0.0)


func _posicionar_area() -> void:
	_area.global_transform = _golpe.global_transform * Transform3D(Basis(), _centro_da_lamina())
