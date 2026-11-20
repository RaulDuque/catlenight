extends AnimatableBody3D

## Sentinela de pedra. A origem são os pés.
## A caixa de colisão tem 1,10 m de altura. A lâmina do jogador passa em Y = 1,15,
## e o pulo sobe os pés até cerca de 1,59 m, então dá para acertar e também para passar por cima.
## O olho fica no +X local de Visual e mostra o lado da marcha.
## pontos_de_vida começa em 3. receber_acerto tira 1. Em 0, _encerrar_patrulha deita o corpo.

@export_group("Patrulha")
@export_range(0.2, 4.0, 0.05, "suffix:m/s") var velocidade_da_patrulha_m_por_s: float = 1.2
@export var limite_esquerdo: NodePath
@export var limite_direito: NodePath

@export_group("Vida")
@export_range(1, 8, 1) var pontos_iniciais: int = 3

var pontos_de_vida := 3
var derrotada := false
var sentido := 1.0

var _limite_esquerdo_x := 0.0
var _limite_direito_x := 0.0
var _y_do_piso := 0.0
var _flash := 0.0
var _material_corpo: StandardMaterial3D
var _material_cabeca: StandardMaterial3D
var _material_olho: StandardMaterial3D
var _cor_corpo: Color
var _cor_cabeca: Color

const _FLASH_S := 0.28
const _COR_DO_ACERTO := Color(0.95, 0.82, 0.45)


func _ready() -> void:
	pontos_de_vida = pontos_iniciais
	_y_do_piso = global_position.y
	global_position.z = 0.0
	_ler_limites()
	_preparar_materiais()
	_apontar()
	add_to_group("sentinela")


func _ler_limites() -> void:
	var esquerdo := get_node_or_null(limite_esquerdo) as Node3D
	var direito := get_node_or_null(limite_direito) as Node3D
	if esquerdo != null and direito != null:
		_limite_esquerdo_x = esquerdo.global_position.x
		_limite_direito_x = direito.global_position.x
	else:
		_limite_esquerdo_x = global_position.x - 1.1
		_limite_direito_x = global_position.x + 1.1
	if _limite_esquerdo_x > _limite_direito_x:
		var troca := _limite_esquerdo_x
		_limite_esquerdo_x = _limite_direito_x
		_limite_direito_x = troca


func _physics_process(delta: float) -> void:
	if derrotada:
		global_position.z = 0.0
		return
	var x := global_position.x + sentido * velocidade_da_patrulha_m_por_s * delta
	if x >= _limite_direito_x:
		x = _limite_direito_x
		sentido = -1.0
		_apontar()
	elif x <= _limite_esquerdo_x:
		x = _limite_esquerdo_x
		sentido = 1.0
		_apontar()
	global_position = Vector3(x, _y_do_piso, 0.0)


func _apontar() -> void:
	$Visual.rotation.y = 0.0 if sentido > 0.0 else PI


func receber_acerto() -> void:
	if derrotada:
		return
	pontos_de_vida -= 1
	_flash = _FLASH_S
	_material_corpo.albedo_color = _COR_DO_ACERTO
	_material_cabeca.albedo_color = _COR_DO_ACERTO
	_material_corpo.emission_enabled = true
	_material_cabeca.emission_enabled = true
	_material_corpo.emission = _COR_DO_ACERTO
	_material_cabeca.emission = _COR_DO_ACERTO
	_material_corpo.emission_energy_multiplier = 0.8
	_material_cabeca.emission_energy_multiplier = 0.8
	if pontos_de_vida <= 0:
		_encerrar_patrulha()


func _encerrar_patrulha() -> void:
	derrotada = true
	pontos_de_vida = 0
	sentido = 0.0
	$Colisao.set_deferred("disabled", true)
	set_deferred("collision_layer", 0)
	var visual := $Visual as Node3D
	visual.rotation.z = -PI * 0.5
	visual.position = Vector3(0.32, 0.36, 0.0)
	_material_corpo.albedo_color = Color(0.16, 0.15, 0.14)
	_material_cabeca.albedo_color = Color(0.16, 0.15, 0.14)
	_material_corpo.emission_enabled = false
	_material_cabeca.emission_enabled = false
	_material_olho.emission_enabled = false
	_flash = 0.0


func _process(delta: float) -> void:
	if derrotada or _flash <= 0.0:
		return
	_flash -= delta
	if _flash > 0.0:
		return
	_material_corpo.albedo_color = _cor_corpo
	_material_cabeca.albedo_color = _cor_cabeca
	_material_corpo.emission_enabled = false
	_material_cabeca.emission_enabled = false


func _preparar_materiais() -> void:
	_material_corpo = _copiar_material($"Visual/Corpo")
	_material_cabeca = _copiar_material($"Visual/Cabeca")
	_material_olho = _copiar_material($"Visual/Olho")
	_cor_corpo = _material_corpo.albedo_color
	_cor_cabeca = _material_cabeca.albedo_color


func _copiar_material(malha: MeshInstance3D) -> StandardMaterial3D:
	var origem := malha.get_active_material(0) as StandardMaterial3D
	var copia := StandardMaterial3D.new()
	copia.albedo_color = origem.albedo_color
	copia.roughness = origem.roughness
	copia.emission_enabled = origem.emission_enabled
	copia.emission = origem.emission
	copia.emission_energy_multiplier = origem.emission_energy_multiplier
	malha.material_override = copia
	return copia
