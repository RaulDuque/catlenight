extends Node

## Coloca o jogador sob o arco com as ações reais, para a captura da câmera lateral.


var _jogador: CharacterBody3D
var _pronto := false
var _frames := 0
var _parado := 0


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	var sala := (load("res://scenes/verification/main.tscn") as PackedScene).instantiate()
	add_child(sala)
	_jogador = sala.get_node("Jogador") as CharacterBody3D
	_pronto = true


func _physics_process(_delta: float) -> void:
	if not _pronto:
		return
	_frames += 1
	if not _jogador.is_on_floor():
		return
	if _jogador.global_position.x < -2.07:
		_pressionar("direita")
		return
	_soltar("direita")
	_parado += 1
	if _parado == 1:
		print(
			"QUADRO frame=%d x=%.3f y=%.3f z=%.4f"
			% [_frames, _jogador.global_position.x, _jogador.global_position.y, _jogador.global_position.z]
		)
	if _parado > 12:
		get_tree().quit(0)


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
