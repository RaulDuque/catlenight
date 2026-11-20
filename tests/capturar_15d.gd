extends SceneTree

## Gera as duas imagens da estrutura. Não faz parte do jogo.


func _initialize() -> void:
	var passo := Passo.new()
	root.add_child(passo)


class Passo extends Node:
	var _cena: Node
	var _frames := 0

	func _init() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _ready() -> void:
		call_deferred("_montar")

	func _montar() -> void:
		_cena = (load("res://scenes/verification/15d_estrutura_completa_do_prologo.tscn") as PackedScene).instantiate()
		get_tree().root.add_child(_cena)
		var menu := _cena.get_node("MenuDoPiloto") as CanvasLayer
		menu.visible = false
		get_tree().paused = false
		_marcas()

	func _physics_process(_delta: float) -> void:
		_frames += 1
		if _frames == 12:
			var planta := _cena.get_node("CameraPlanta") as Camera3D
			planta.current = true
			(_cena.get_node("CameraLateral") as Camera3D).current = false
		elif _frames == 24:
			var imagem := get_viewport().get_texture().get_image()
			imagem.save_png("D:/Progr/catlenight/MD-usario/relatorios/evidencias/15d-planta-estrutural.png")
			print("PLANTA %dx%d" % [imagem.get_width(), imagem.get_height()])
			var jogador := _cena.get_node("Jogador") as CharacterBody3D
			jogador.global_position = Vector3(-40.0, 6.4, 0.0)
			jogador.velocity = Vector3.ZERO
			(_cena.get_node("CameraLateral") as Camera3D).current = true
			(_cena.get_node("CameraPlanta") as Camera3D).current = false
		elif _frames == 48:
			var imagem := get_viewport().get_texture().get_image()
			imagem.save_png("D:/Progr/catlenight/MD-usario/relatorios/evidencias/15d-galeria-superior.png")
			var jogador := _cena.get_node("Jogador") as CharacterBody3D
			print("GALERIA x=%.3f y=%.3f z=%.3f" % [jogador.global_position.x, jogador.global_position.y, jogador.global_position.z])
			get_tree().quit(0)

	func _marcas() -> void:
		var raiz := Node3D.new()
		raiz.name = "Planta"
		_cena.add_child(raiz)
		for x in range(-48, -17, 5):
			_caixa(raiz, Vector3(float(x), 0.15, 0.0), Vector3(0.06, 0.3, 0.06), Color(0.95, 0.9, 0.7))
		for ponto in [Vector3(-20.0, 0.0, 0.4), Vector3(-40.0, 2.64, 0.4), Vector3(-40.0, 6.2, 0.4)]:
			_caixa(raiz, ponto + Vector3(0, 0.85, 0), Vector3(0.28, 1.7, 0.12), Color(0.95, 0.82, 0.25))
		_texto(raiz, Vector3(-26.7, 4.2, 0), "Limiar")
		_texto(raiz, Vector3(-31.6, 7.2, 0), "Acesso")
		_texto(raiz, Vector3(-38.0, 8.0, 0), "Galeria")

	func _caixa(pai: Node3D, centro: Vector3, tamanho: Vector3, cor: Color) -> void:
		var malha := MeshInstance3D.new()
		var bloco := BoxMesh.new()
		bloco.size = tamanho
		malha.mesh = bloco
		var materia := StandardMaterial3D.new()
		materia.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		materia.albedo_color = cor
		malha.material_override = materia
		malha.position = centro
		pai.add_child(malha)

	func _texto(pai: Node3D, ponto: Vector3, texto: String) -> void:
		var rotulo := Label3D.new()
		rotulo.text = texto
		rotulo.font_size = 48
		rotulo.pixel_size = 0.01
		rotulo.position = ponto
		rotulo.modulate = Color(0.98, 0.92, 0.7)
		pai.add_child(rotulo)
