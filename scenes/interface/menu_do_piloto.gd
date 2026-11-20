extends CanvasLayer

## Abre o piloto 11. Esquerda e direita escolhem. Espaço confirma.
## Continuar só fica disponível com um arquivo válido. Novo jogo não apaga esse arquivo.

var continuar_habilitado := false
var selecao := "novo"

var _aguardando_soltar := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("menu_do_piloto")
	var progresso := get_tree().get_first_node_in_group("progresso_do_piloto")
	continuar_habilitado = progresso != null and progresso.has_method("tem_gravacao_valida") and bool(progresso.tem_gravacao_valida())
	_pintar()
	get_tree().paused = true


func _physics_process(_delta: float) -> void:
	if not visible:
		return
	if _aguardando_soltar:
		if Input.is_action_pressed("pulo") or Input.is_action_pressed("esquerda") or Input.is_action_pressed("direita"):
			return
		_confirmar()
		return
	if Input.is_action_just_pressed("esquerda") or Input.is_action_just_pressed("direita"):
		_alternar()
	if Input.is_action_just_pressed("pulo"):
		if selecao == "continuar" and not continuar_habilitado:
			return
		_aguardando_soltar = true


func _alternar() -> void:
	if not continuar_habilitado:
		selecao = "novo"
	elif selecao == "novo":
		selecao = "continuar"
	else:
		selecao = "novo"
	_pintar()


func _confirmar() -> void:
	if selecao == "continuar":
		var progresso := get_tree().get_first_node_in_group("progresso_do_piloto")
		var cena := get_parent()
		if progresso == null or cena == null or not bool(progresso.restaurar(cena)):
			_aguardando_soltar = false
			return
	visible = false
	get_tree().paused = false


func _pintar() -> void:
	_cor($NovoJogo, selecao == "novo", true)
	_cor($Continuar, selecao == "continuar", continuar_habilitado)


func _cor(rotulo: Label, ativo: bool, habilitado: bool) -> void:
	var cor := Color(0.5, 0.48, 0.44)
	if not habilitado:
		cor = Color(0.34, 0.33, 0.32)
	elif ativo:
		cor = Color(0.98, 0.94, 0.82)
	rotulo.add_theme_color_override("font_color", cor)
