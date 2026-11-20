extends Area3D

## Perto do vitral. Um toque novo em interagir grava uma vez.
## Segurar a tecla deixa a confirmação na tela.

const TEXTO := "↑ Salvar progresso"
const CONFIRMACAO := "Progresso salvo"
const FALHA := "Não foi possível salvar"

var _confirmando := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false


func _physics_process(_delta: float) -> void:
	var apoiado := _jogador_apoiado()
	if apoiado == null:
		_confirmando = false
		_aviso(false)
		return
	if Input.is_action_just_pressed("interagir"):
		var progresso := get_tree().get_first_node_in_group("progresso_do_piloto")
		var ok := progresso != null and progresso.has_method("gravar") and bool(progresso.gravar(_cena()))
		_confirmando = true
		_mostrar(CONFIRMACAO if ok else FALHA)
		return
	if _confirmando and Input.is_action_pressed("interagir"):
		return
	_confirmando = false
	_mostrar(TEXTO)


func _cena() -> Node:
	var no: Node = self
	while no != null:
		if no.has_node("Jogador"):
			return no
		no = no.get_parent()
	return get_tree().current_scene


func _jogador_apoiado() -> CharacterBody3D:
	for corpo in get_overlapping_bodies():
		if corpo is CharacterBody3D and corpo.name == "Jogador" and (corpo as CharacterBody3D).is_on_floor():
			if corpo.global_position.distance_to(global_position) > 2.2:
				continue
			return corpo as CharacterBody3D
	return null


func _mostrar(texto: String) -> void:
	var aviso := get_tree().get_first_node_in_group("aviso_da_passagem")
	if aviso != null and aviso.has_method("mostrar"):
		aviso.mostrar(texto, self)


func _aviso(ligado: bool) -> void:
	if ligado:
		_mostrar(TEXTO)
		return
	var aviso := get_tree().get_first_node_in_group("aviso_da_passagem")
	if aviso != null and aviso.has_method("esconder"):
		aviso.esconder(self)
