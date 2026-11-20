extends Node

## Para o protagonista na passagem do arco, nas duas direções.


var _jogador: CharacterBody3D
var _visual: Node3D
var _pronto := false
var _frames := 0
var _fase := "cair"
var _parado := 0


func _ready() -> void:
	call_deferred("_montar")


func _montar() -> void:
	var sala := (load("res://scenes/verification/main.tscn") as PackedScene).instantiate()
	add_child(sala)
	_jogador = sala.get_node("Jogador") as CharacterBody3D
	_visual = _jogador.get_node("Visual") as Node3D
	_pronto = true


func _physics_process(_delta: float) -> void:
	if not _pronto:
		return
	_frames += 1
	if _fase == "cair":
		if _jogador.is_on_floor():
			_pressionar("direita")
			_fase = "direita"
		return
	if _fase == "direita":
		if _jogador.global_position.x < -2.12:
			return
		_soltar("direita")
		_parado += 1
		if _parado == 1:
			print(
				"QUADRO_DIREITA frame=%d x=%.3f y=%.3f rot=%.3f"
				% [_frames, _jogador.global_position.x, _jogador.global_position.y, _visual.rotation.y]
			)
		if _parado > 10:
			_parado = 0
			_pressionar("esquerda")
			_fase = "esquerda"
		return
	if _jogador.global_position.x > -3.15:
		return
	_soltar("esquerda")
	_parado += 1
	if _parado == 1:
		print(
			"QUADRO_ESQUERDA frame=%d x=%.3f y=%.3f rot=%.3f"
			% [_frames, _jogador.global_position.x, _jogador.global_position.y, _visual.rotation.y]
		)
	if _parado > 10:
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
