extends SceneTree

## Percurso por ações. Os alvos vêm da leitura independente dos pixels da prancha.
const CENA := preload("res://scenes/verification/15e_prologo_em_escala.tscn")
const PX_M := 26.0
var sala: Node3D
var jogador: CharacterBody3D
var quadro := 0
var anterior := 0
var falhou := false
var setor := ""
var medindo_interna := false
var entrada := 0

func _initialize() -> void:
	call_deferred("_percurso")

func _erro(texto: String) -> void:
	if not falhou:
		push_error("FALHA %s | quadro %d | pés %s | normal %s" % [texto, quadro, jogador.position, jogador.get_floor_normal()])
	falhou = true
	quit(1)

func _tecla(acao: String, pressionada: bool) -> void:
	var evento := InputEventAction.new()
	evento.action = acao
	evento.pressed = pressionada
	Input.parse_input_event(evento)
	Input.flush_buffered_events()

func _passos(n: int) -> void:
	for i in n:
		await physics_frame
		quadro += 1
		_cronometrar_lance()
		if absf(jogador.position.z) > 0.001:
			_erro("fora do plano")

func _cronometrar_lance() -> void:
	var atual := ""
	var u := jogador.position.x * PX_M + 1552.0
	if jogador.position.y < 11.0 and u >= 1264 and u <= 1520:
		atual = "exterior"
	elif medindo_interna and u >= 880 and u <= 976:
		atual = "interno inferior"
	elif medindo_interna and u >= 736 and u <= 816:
		atual = "interno superior"
	if atual != setor:
		if not setor.is_empty():
			print("TRAVESSIA %s %.3f s" % [setor, (quadro-entrada)/float(Engine.physics_ticks_per_second)])
		entrada = quadro
		setor = atual

func _marca(nome: String) -> void:
	print("%s | %.3f s | %s" % [nome, (quadro-anterior)/float(Engine.physics_ticks_per_second), jogador.position])
	anterior = quadro

func _x(pixel: float) -> float:
	return (pixel - 1552.0) / PX_M

func _y(pixel: float) -> float:
	return (928.0 - pixel) / PX_M

func _andar(pixel: float) -> void:
	var alvo := _x(pixel)
	var sentido := signf(alvo - jogador.position.x)
	var tecla := "direita" if sentido > 0 else "esquerda"
	_tecla(tecla, true)
	var parado := 0
	for i in 1200:
		var inicio := jogador.position.x
		await _passos(1)
		if sentido * (alvo - jogador.position.x) <= 0.001:
			break
		parado = parado + 1 if absf(inicio - jogador.position.x) < 0.001 else 0
		if parado == 20 or i == 1199:
			_erro("travou rumo ao pixel %.0f (%s)" % [pixel, tecla])
			break
	_tecla(tecla, false)
	await _passos(3)

func _piso(nome: String, pixel_y: float, tolerancia := 0.025) -> void:
	if not jogador.is_on_floor() or absf(jogador.position.y - _y(pixel_y)) > tolerancia:
		_erro("piso " + nome)
	_marca(nome)

func _interagir() -> void:
	_tecla("interagir", true)
	await _passos(2)
	_tecla("interagir", false)
	await _passos(5)

func _raio(a: Vector3, b: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a,b)
	q.exclude = [jogador.get_rid()]
	return jogador.get_world_3d().direct_space_state.intersect_ray(q)

func _teto(u: float, v_piso: float, v_teto: float) -> void:
	var base := Vector3(_x(u), _y(v_piso) + 0.02, 0)
	var hit := _raio(base, base + Vector3.UP * 20)
	if hit.is_empty() or absf(hit.position.y - _y(v_teto)) > 0.015:
		_erro("teto em %s: %s" % [u, hit])

func _conferir_lance(nome: String, alto: Vector2, baixo: Vector2) -> void:
	var col := sala.get_node("Sala/Gerado/" + nome + "/Colisao") as CollisionShape3D
	var h := (col.shape as BoxShape3D).size * 0.5
	for i in [0,1]:
		var esperado := alto if i == 0 else baixo
		var face := col.to_global(Vector3(h.x if i == 0 else -h.x,h.y,0))
		if face.distance_to(Vector3(_x(esperado.x),_y(esperado.y),0)) > 0.002:
			_erro("extremo medido do " + nome)

func _apoio(nome: String) -> void:
	var inicio := jogador.position
	await _passos(18)
	if not jogador.is_on_floor() or jogador.position.distance_to(inicio) > 0.005:
		_erro("parada " + nome)
	var contato := KinematicCollision3D.new()
	if not jogador.test_move(jogador.global_transform, Vector3.DOWN*0.02, contato, 0.001, true):
		_erro("contato ausente em " + nome)
		return
	var esperada := "LanceExterior"
	if nome.begins_with("inferior"):
		esperada = "LanceInferior"
	elif nome.begins_with("superior"):
		esperada = "LanceSuperior"
	if contato.get_collider().name != esperada or contato.get_normal().dot(Vector3(1,1,0).normalized()) < 0.999:
		_erro("lance encurtado ou inclinação incorreta em " + nome)
	var melhor_folga := INF
	var sola := Vector3.ZERO
	var face := Vector3.ZERO
	for pe in jogador.find_children("Pe*", "MeshInstance3D", true, false):
		if pe.name not in [&"PeDireito", &"PeEsquerdo"]:
			continue
		var pontos: PackedVector3Array = pe.mesh.get_faces()
		var minimo := INF
		for p in pontos:
			var mundo: Vector3 = pe.to_global(p)
			minimo = minf(minimo, mundo.y)
		for p in pontos:
			var mundo: Vector3 = pe.to_global(p)
			if mundo.y > minimo + 0.001:
				continue
			var hit := _raio(mundo + Vector3.UP, mundo + Vector3.DOWN)
			if hit.is_empty():
				continue
			var folga: float = mundo.y - hit.position.y
			if folga < melhor_folga:
				melhor_folga = folga
				sola = mundo
				face = hit.position
	if melhor_folga == INF:
		_erro("sola indisponível")
	print("APOIO %s origem=%s contato=%s normal=%s sola=%s piso=%s folga=%.4f" % [nome,jogador.position,contato.get_position(),contato.get_normal(),sola,face,melhor_folga])
	if OS.get_environment("CATLENIGHT_CAPTURAS") != "":
		var cam: Camera3D = sala.get_node("CameraLateral")
		var seguir := sala.get_node("Enquadramento")
		seguir.set_physics_process(false)
		cam.position = jogador.position + Vector3(0,0.7,14)
		cam.size = 3.3
		await process_frame
		await RenderingServer.frame_post_draw
		var imagem := root.get_texture().get_image()
		imagem.save_png(OS.get_environment("CATLENIGHT_CAPTURAS").path_join(nome+".png"))
		cam.size = 8
		seguir.set_physics_process(true)

func _rampa(nome: String, meio: float) -> void:
	await _andar(meio)
	await _apoio(nome)
	_marca(nome)

func _saltar_vao(sentido: String, destino: float) -> void:
	_tecla(sentido, true)
	_tecla("pulo", true)
	await _passos(3)
	_tecla("pulo", false)
	await _passos(70)
	_tecla(sentido, false)
	await _andar(destino)
	_piso("extremo " + sentido, 352)

func _percurso() -> void:
	debug_collisions_hint = not OS.get_environment("CATLENIGHT_CAPTURAS").is_empty()
	sala = CENA.instantiate()
	root.add_child(sala)
	jogador = sala.get_node("Jogador")
	_exportar_contornos()
	_conferir_lance("LanceExterior",Vector2(1264,672),Vector2(1520,928))
	_conferir_lance("LanceInferior",Vector2(880,432),Vector2(976,528))
	_conferir_lance("LanceSuperior",Vector2(736,352),Vector2(816,432))
	await _passos(8)
	_tecla("pulo", true)
	await _passos(4)
	_tecla("pulo", false)
	await _passos(24)
	if paused or sala.get_node("MenuDoPiloto").visible:
		_erro("Novo jogo")
	_piso("nascimento", 928)
	await _rampa("exterior-subida",1392)
	await _andar(1240)
	_piso("alto exterior",672)
	await _andar(380)
	_tecla("esquerda",true)
	await _passos(30)
	var parede := jogador.position
	_tecla("pulo",true)
	await _passos(8)
	if jogador.position.y <= parede.y + 0.1:
		_erro("salto contra parede")
	_tecla("pulo",false)
	await _passos(112)
	_tecla("esquerda",false)
	if absf(jogador.position.x-parede.x)>0.015:
		_erro("atravessou parede do trono")
	_piso("parede do trono",688)
	_teto(480,688,544)
	await _andar(1040)
	await _interagir()
	_piso("início interno",528)
	medindo_interna = true
	await _rampa("inferior-subida",928)
	await _andar(848)
	_piso("descanso na subida",432)
	await _rampa("superior-subida",776)
	await _andar(708)
	_piso("topo interno",352)
	medindo_interna = false
	await _andar(412)
	_piso("extremo esquerdo",352)
	await _andar(729)
	await _saltar_vao("direita",1092)
	await _andar(815)
	await _saltar_vao("esquerda",700)
	medindo_interna = true
	await _rampa("superior-descida",776)
	await _andar(848)
	_piso("descanso na descida",432)
	await _rampa("inferior-descida",928)
	await _andar(1040)
	_piso("base interna",528)
	medindo_interna = false
	for u in range(736, 977, 2):
		var v := clampf(u - 736.0, 0.0, 80.0) + 352.0 + maxf(u - 880.0, 0.0)
		var pe := Vector3(_x(u), _y(v) + 0.01, 0)
		var cobertura := _raio(pe, pe + Vector3.UP * 30)
		if cobertura.is_empty() or cobertura.position.y - pe.y < 1.7:
			_erro("pé-direito interno no pixel %d" % u)
	_teto(560,352,192)
	_teto(928,480,358)
	_teto(812,428,358)
	var vao := _raio(Vector3(_x(764),_y(344),0),Vector3(_x(764),_y(364),0))
	if not vao.is_empty():
		_erro("boca da galeria obstruída")
	await _interagir()
	_piso("volta ao salão",720)
	await _rampa("exterior-descida",1392)
	await _andar(1584)
	_piso("fim no nascimento",928)
	if not falhou:
		print("RESULTADO ok")
		quit(0)

## Contornos XY das caixas físicas já instanciadas, incluindo a rotação das rampas.
func _exportar_contornos() -> void:
	var caminho := OS.get_environment("CATLENIGHT_CONTORNOS")
	if caminho.is_empty():
		return
	var poligonos := {}
	for corpo in sala.get_node("Sala/Gerado").get_children():
		var col := corpo.get_node("Colisao") as CollisionShape3D
		var h := (col.shape as BoxShape3D).size * 0.5
		var vertices := []
		for canto in [Vector2(-1,-1), Vector2(1,-1), Vector2(1,1), Vector2(-1,1)]:
			var v := col.to_global(Vector3(h.x*canto.x,h.y*canto.y,0))
			vertices.append([v.x,v.y])
		poligonos[String(corpo.name)] = vertices
	var arquivo := FileAccess.open(caminho,FileAccess.WRITE)
	if arquivo == null:
		_erro("gravar contornos")
		return
	arquivo.store_string(JSON.stringify(poligonos))
