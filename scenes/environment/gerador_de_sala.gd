@tool
extends Node3D

## Lê dados/sala_do_prologo.json e reconstrói só o nó Gerado.
## A primeira string de "linhas" é a fileira mais alta. A coluna 1 fica à esquerda.
## A origem é o canto inferior esquerdo da célula da fileira de baixo, coluna 1.
## "/" sobe para a esquerda. "\" sobe para a direita.
## Abrir a cena no editor ou executar o piloto chama gerar() de novo.

const DADOS := "res://dados/sala_do_prologo.json"

@export_file("*.json") var dados_caminho: String = DADOS

var _erros: PackedStringArray = PackedStringArray()


func _ready() -> void:
	gerar()


func gerar() -> String:
	_erros = PackedStringArray()
	var gerado := _pegar_gerado()
	_limpar(gerado)
	var dados := _ler()
	if dados.is_empty():
		return "\n".join(_erros)
	var linhas: PackedStringArray = dados["linhas"]
	var fileiras := linhas.size()
	var largura := 1.0
	var altura := 1.0
	var fundo := 2.4
	var espessura := 0.32
	var origem := Vector3.ZERO
	if fileiras > 0:
		largura = float(dados["celula_largura_m"])
		altura = float(dados["celula_altura_m"])
		fundo = float(dados["profundidade_m"])
		espessura = float(dados["espessura_da_rampa_m"])
		origem = Vector3(float(dados["origem_x"]), float(dados["origem_y"]), float(dados["origem_z"]))
	for indice in fileiras:
		var texto := linhas[indice]
		var linha := indice + 1
		if texto.length() == 0:
			_erro(linha, 1, "linha vazia")
			continue
		if indice > 0 and texto.length() != linhas[0].length():
			_erro(linha, mini(texto.length(), linhas[0].length()) + 1, "tamanho %d, esperado %d" % [texto.length(), linhas[0].length()])
			continue
		var desde_baixo := fileiras - 1 - indice
		var coluna := 0
		while coluna < texto.length():
			var simbolo := texto.substr(coluna, 1)
			if not _conhecido(simbolo):
				_erro(linha, coluna + 1, "símbolo desconhecido \"%s\"" % simbolo)
				coluna += 1
				continue
			if simbolo == ".":
				coluna += 1
				continue
			var fim := coluna
			while fim + 1 < texto.length() and texto.substr(fim + 1, 1) == simbolo:
				fim += 1
			_colocar(gerado, simbolo, desde_baixo, coluna, fim, largura, altura, fundo, espessura, origem)
			coluna = fim + 1
	_explicitos(gerado, dados)
	return "\n".join(_erros)


func descrever_celula(linha: int, coluna: int) -> Dictionary:
	var dados := _ler()
	var vazio := {"simbolo": "", "linha": linha, "coluna": coluna}
	if dados.is_empty():
		vazio["erro"] = "\n".join(_erros)
		return vazio
	var linhas: PackedStringArray = dados["linhas"]
	if linha < 1 or linha > linhas.size() or coluna < 1 or coluna > linhas[linha - 1].length():
		vazio["erro"] = "célula fora da matriz"
		return vazio
	var simbolo := linhas[linha - 1].substr(coluna - 1, 1)
	var largura := float(dados["celula_largura_m"])
	var altura := float(dados["celula_altura_m"])
	var origem := Vector3(float(dados["origem_x"]), float(dados["origem_y"]), float(dados["origem_z"]))
	var desde_baixo := linhas.size() - linha
	var x0 := origem.x + float(coluna - 1) * largura
	var base := origem.y + float(desde_baixo) * altura
	var topo := base + altura
	var apoio := Vector3(x0 + largura * 0.5, topo, origem.z)
	var lado := ""
	if simbolo == "/":
		lado = "esquerda"
		apoio.y = topo + altura * 0.5
	elif simbolo == "\\":
		lado = "direita"
		apoio.y = topo + altura * 0.5
	return {
		"simbolo": simbolo,
		"linha": linha,
		"coluna": coluna,
		"x0": x0,
		"x1": x0 + largura,
		"y_base": base,
		"y_topo": topo,
		"lado_alto": lado,
		"apoio": apoio,
	}


func corpos() -> int:
	var gerado := get_node_or_null("Gerado")
	if gerado == null:
		return 0
	var total := 0
	for filho in gerado.get_children():
		if filho is StaticBody3D:
			total += 1
	return total


func _colocar(gerado: Node3D, simbolo: String, desde_baixo: int, inicio: int, fim: int, largura: float, altura: float, fundo: float, espessura: float, origem: Vector3) -> void:
	var x0 := origem.x + float(inicio) * largura
	var x1 := origem.x + float(fim + 1) * largura
	var base := origem.y + float(desde_baixo) * altura
	var topo := base + altura
	if simbolo == "#":
		var corpo := StaticBody3D.new()
		corpo.name = "Piso_%d_%d" % [desde_baixo, inicio]
		var tamanho := Vector3(x1 - x0, altura, fundo)
		corpo.position = Vector3((x0 + x1) * 0.5, base + altura * 0.5, origem.z)
		_forma(corpo, tamanho, _cor_do_piso(desde_baixo))
		_marcas(gerado, x0, x1, topo, origem.z, fundo, desde_baixo, inicio)
		gerado.add_child(corpo)
		return
	var sobe := 1.0 + float(fim - inicio)
	var y_alto := topo + altura * sobe
	var alto := Vector3(x0 if simbolo == "/" else x1, y_alto, origem.z)
	var baixo := Vector3(x1 if simbolo == "/" else x0, topo, origem.z)
	var corpo_rampa := StaticBody3D.new()
	corpo_rampa.name = "Rampa_%d_%d" % [desde_baixo, inicio]
	baixo.x += 0.18 if simbolo == "/" else -0.18
	var eixo_x := (alto - baixo).normalized()
	var eixo_y := Vector3(eixo_x.y, -eixo_x.x, 0.0)
	if eixo_y.y < 0.0:
		eixo_y = -eixo_y
	var eixo_z := eixo_x.cross(eixo_y)
	var meio := (alto + baixo) * 0.5
	corpo_rampa.transform = Transform3D(Basis(eixo_x, eixo_y, eixo_z), meio - eixo_y * (espessura * 0.5))
	_forma(corpo_rampa, Vector3(alto.distance_to(baixo), espessura, fundo), Color(0.78, 0.46, 0.16))
	gerado.add_child(corpo_rampa)


func _forma(corpo: StaticBody3D, tamanho: Vector3, cor: Color) -> void:
	var colisao := CollisionShape3D.new()
	colisao.name = "Colisao"
	var caixa := BoxShape3D.new()
	caixa.size = tamanho
	colisao.shape = caixa
	corpo.add_child(colisao)
	var malha := MeshInstance3D.new()
	malha.name = "Malha"
	var bloco := BoxMesh.new()
	bloco.size = tamanho
	malha.mesh = bloco
	var materia := StandardMaterial3D.new()
	materia.albedo_color = cor
	materia.roughness = 0.95
	malha.material_override = materia
	malha.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	corpo.add_child(malha)


func _marcas(gerado: Node3D, x0: float, x1: float, topo: float, z: float, fundo: float, desde_baixo: int, inicio: int) -> void:
	var passo := 0
	var x := x0
	while x <= x1 + 0.001:
		var marca := MeshInstance3D.new()
		marca.name = "Marca_%d_%d_%d" % [desde_baixo, inicio, passo]
		var bloco := BoxMesh.new()
		bloco.size = Vector3(0.04, 0.12, 0.04)
		marca.mesh = bloco
		marca.position = Vector3(x, topo - 0.06, z + fundo * 0.5 - 0.04)
		var materia := StandardMaterial3D.new()
		materia.albedo_color = Color(0.05, 0.06, 0.08)
		marca.material_override = materia
		marca.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gerado.add_child(marca)
		x += 1.0
		passo += 1


func _cor_do_piso(desde_baixo: int) -> Color:
	if desde_baixo > 0:
		return Color(0.48, 0.32, 0.58)
	return Color(0.22, 0.48, 0.62)


func _conhecido(simbolo: String) -> bool:
	return simbolo == "." or simbolo == "#" or simbolo == "/" or simbolo == "\\"


func _ler() -> Dictionary:
	var caminho := dados_caminho if dados_caminho != "" else DADOS
	if not FileAccess.file_exists(caminho):
		_erro(1, 1, "arquivo ausente")
		return {}
	var texto := FileAccess.get_file_as_string(caminho)
	var dados: Variant = JSON.parse_string(texto)
	if typeof(dados) != TYPE_DICTIONARY:
		_erro(1, 1, "o JSON não é um objeto")
		return {}
	var tem_grade: bool = dados.has("linhas") and typeof(dados["linhas"]) == TYPE_ARRAY
	var tem_extra: bool = (dados.has("solidos") and typeof(dados["solidos"]) == TYPE_ARRAY) or (dados.has("rampas") and typeof(dados["rampas"]) == TYPE_ARRAY)
	if tem_grade:
		for chave in ["celula_largura_m", "celula_altura_m", "profundidade_m", "espessura_da_rampa_m", "origem_x", "origem_y", "origem_z"]:
			if not dados.has(chave):
				_erro(1, 1, "falta %s" % chave)
				return {}
		var linhas := PackedStringArray()
		for item in dados["linhas"]:
			linhas.append(String(item))
		dados["linhas"] = linhas
	elif not tem_extra:
		_erro(1, 1, "linhas não é uma lista")
		return {}
	else:
		dados["linhas"] = PackedStringArray()
	return dados


func _pegar_gerado() -> Node3D:
	var gerado := get_node_or_null("Gerado") as Node3D
	if gerado == null:
		gerado = Node3D.new()
		gerado.name = "Gerado"
		add_child(gerado)
	return gerado


func _limpar(gerado: Node) -> void:
	var indice := 0
	while gerado.get_child_count() > 0:
		var filho := gerado.get_child(0)
		filho.name = "apagado_%d" % indice
		gerado.remove_child(filho)
		filho.free()
		indice += 1


func _explicitos(gerado: Node3D, dados: Dictionary) -> void:
	if dados.has("solidos") and typeof(dados["solidos"]) == TYPE_ARRAY:
		for item in dados["solidos"]:
			if typeof(item) != TYPE_DICTIONARY:
				_erro(1, 1, "sólido inválido")
				continue
			var largura := float(item["largura"])
			var altura := float(item["altura"])
			var fundo := float(item["profundidade"]) if item.has("profundidade") else 2.4
			var corpo := StaticBody3D.new()
			corpo.name = String(item["nome"])
			corpo.position = Vector3(float(item["x"]) + largura * 0.5, float(item["y"]) + altura * 0.5, float(item["z"]) if item.has("z") else 0.0)
			_forma(corpo, Vector3(largura, altura, fundo), _cor_nome(String(item.get("cor", "chao"))))
			gerado.add_child(corpo)
	if dados.has("rampas") and typeof(dados["rampas"]) == TYPE_ARRAY:
		for item in dados["rampas"]:
			if typeof(item) != TYPE_DICTIONARY:
				_erro(1, 1, "rampa inválida")
				continue
			_rampa_explicita(gerado, item)


func _rampa_explicita(gerado: Node3D, item: Dictionary) -> void:
	var a := Vector3(float(item["x0"]), float(item["y0"]), 0.0)
	var b := Vector3(float(item["x1"]), float(item["y1"]), 0.0)
	var alto := a if a.y >= b.y else b
	var baixo := b if a.y >= b.y else a
	var espessura := float(item["espessura"]) if item.has("espessura") else 0.32
	var fundo := float(item["profundidade"]) if item.has("profundidade") else 2.4
	var corpo := StaticBody3D.new()
	corpo.name = String(item["nome"])
	var eixo_x := (alto - baixo).normalized()
	var eixo_y := Vector3(eixo_x.y, -eixo_x.x, 0.0)
	if eixo_y.y < 0.0:
		eixo_y = -eixo_y
	var eixo_z := eixo_x.cross(eixo_y)
	var meio := (alto + baixo) * 0.5
	corpo.transform = Transform3D(Basis(eixo_x, eixo_y, eixo_z), meio - eixo_y * (espessura * 0.5))
	_forma(corpo, Vector3(alto.distance_to(baixo), espessura, fundo), _cor_nome(String(item.get("cor", "rampa"))))
	gerado.add_child(corpo)


func _cor_nome(nome: String) -> Color:
	match nome:
		"rampa":
			return Color(0.78, 0.46, 0.16)
		"parede":
			return Color(0.32, 0.36, 0.4)
		"teto":
			return Color(0.55, 0.5, 0.42)
		"estrado":
			return Color(0.48, 0.3, 0.55)
		"patamar":
			return Color(0.36, 0.55, 0.34)
		_:
			return Color(0.22, 0.48, 0.62)


func _erro(linha: int, coluna: int, texto: String) -> void:
	var mensagem := "sala_do_prologo.json: linha %d, coluna %d: %s" % [linha, coluna, texto]
	_erros.append(mensagem)
	push_error(mensagem)
