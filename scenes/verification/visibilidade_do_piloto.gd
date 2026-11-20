extends Node3D

## O pilar dianteiro fica transparente enquanto cobre o corpo.
## Fora dessa faixa, a pedra volta ao material opaco.
## No piloto, os caminhos padrão acham Jogador e ArcoDePedra na raiz.
## Na cena das salas, o nó Visibilidade aponta esses caminhos para o vestíbulo.

@export_range(0.2, 1.2, 0.05, "suffix:m") var alcance_do_pilar_m: float = 0.62
@export_range(0.05, 0.8, 0.05) var alpha_do_pilar: float = 0.28
@export var caminho_do_jogador: NodePath = NodePath("Jogador")
@export var caminho_do_pilar: NodePath = NodePath("ArcoDePedra/Colisao/PilarFrente")
@export var caminho_do_visual: NodePath = NodePath("ArcoDePedra/Visual/ArcoDePedra")

var _jogador: CharacterBody3D
var _pilar: Node3D
var _materiais: Array[StandardMaterial3D] = []


func _ready() -> void:
	_jogador = get_node(caminho_do_jogador) as CharacterBody3D
	_pilar = get_node(caminho_do_pilar) as Node3D
	var visual := get_node(caminho_do_visual)
	for nome in ["BaseFrente", "PilarFrente1", "PilarFrente2", "PilarFrente3", "CapitelFrente"]:
		_copiar_material(visual.get_node(nome) as MeshInstance3D)


func _process(_delta: float) -> void:
	var cobre := absf(_jogador.global_position.x - _pilar.global_position.x) <= alcance_do_pilar_m
	for material in _materiais:
		if cobre:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = alpha_do_pilar
		else:
			material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			material.albedo_color.a = 1.0


func _copiar_material(malha: MeshInstance3D) -> void:
	var original := malha.get_active_material(0) as StandardMaterial3D
	if original == null:
		original = malha.mesh.surface_get_material(0) as StandardMaterial3D
	var copia := original.duplicate() as StandardMaterial3D
	malha.set_surface_override_material(0, copia)
	_materiais.append(copia)
