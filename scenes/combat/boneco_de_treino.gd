extends StaticBody3D

## Alvo provisório. receber_acerto soma um acerto e troca a cor por um instante.
## acertos é a contagem que o teste lê.

@export var cor_do_acerto: Color = Color(1, 0.88, 0.25)
@export_range(0.1, 1.2, 0.05, "suffix:s") var duracao_do_flash_s: float = 0.45

var acertos := 0

var _tempo := 0.0
var _materiais: Array[StandardMaterial3D] = []
var _cores: Array[Color] = []


func _ready() -> void:
	for caminho in ["Tronco", "Cabeca"]:
		var malha := get_node(caminho) as MeshInstance3D
		var origem := malha.get_active_material(0) as StandardMaterial3D
		var copia := StandardMaterial3D.new()
		copia.albedo_color = origem.albedo_color
		copia.roughness = origem.roughness
		malha.material_override = copia
		_materiais.append(copia)
		_cores.append(copia.albedo_color)


func receber_acerto() -> void:
	acertos += 1
	_tempo = duracao_do_flash_s
	for material in _materiais:
		material.albedo_color = cor_do_acerto
		material.emission_enabled = true
		material.emission = cor_do_acerto
		material.emission_energy_multiplier = 1.6


func _process(delta: float) -> void:
	if _tempo <= 0.0:
		return
	_tempo -= delta
	if _tempo > 0.0:
		return
	for indice in _materiais.size():
		_materiais[indice].albedo_color = _cores[indice]
		_materiais[indice].emission_enabled = false
