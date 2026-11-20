extends Node

## Gravação do piloto 11. Um arquivo, com versão.
## A escrita vai primeiro para um temporário. O arquivo anterior só sai do lugar
## depois que o temporário foi lido de volta e validado.
## salas_visitadas e sala_atual são opcionais. Um arquivo da etapa 11, sem essas
## chaves, continua válido: o altar só era alcançado depois das três salas.

const VERSAO := 1
const ARQUIVO := "user://catlenight_piloto_11.json"
const _TEMPORARIO := "user://catlenight_piloto_11.json.tmp"
const _NOME := "catlenight_piloto_11.json"
const _NOME_TEMP := "catlenight_piloto_11.json.tmp"
const _NOME_RESERVA := "catlenight_piloto_11.json.bak"
const SALA := "capela_da_lua"
const MARCADOR := "AoLadoDoAltar"

const _CHAVES: Array[String] = [
	"versao",
	"sala",
	"marcador",
	"vida",
	"vida_maxima",
	"salto_duplo",
	"sentinela_vida",
	"sentinela_derrotada",
]
const _OPCIONAIS: Array[String] = ["salas_visitadas", "sala_atual"]
const _SALAS_DO_MAPA: Array[String] = ["escadaria_exterior", "vestibulo", "galeria", "capela_da_lua"]

var gravacoes := 0


func _ready() -> void:
	add_to_group("progresso_do_piloto")


func reunir(cena: Node) -> Dictionary:
	var jogador := cena.get_node("Jogador")
	var sentinela := cena.get_node("Galeria/SentinelaDaGaleria")
	var ficha := {
		"versao": VERSAO,
		"sala": SALA,
		"marcador": MARCADOR,
		"vida": int(jogador.get("pontos_de_vida")),
		"vida_maxima": int(jogador.get("pontos_maximos")),
		"salto_duplo": bool(jogador.get("salto_duplo_adquirido")),
		"sentinela_vida": int(sentinela.get("pontos_de_vida")),
		"sentinela_derrotada": bool(sentinela.get("derrotada")),
	}
	var mapa := cena.get_tree().get_first_node_in_group("mapa_das_salas")
	if mapa != null and mapa.has_method("para_gravacao"):
		var extra := mapa.call("para_gravacao") as Dictionary
		ficha["salas_visitadas"] = extra["salas_visitadas"]
		ficha["sala_atual"] = extra["sala_atual"]
	return ficha


func validar(bruto: Variant) -> Dictionary:
	if bruto == null or typeof(bruto) != TYPE_DICTIONARY:
		return {}
	var dados := bruto as Dictionary
	for chave in _CHAVES:
		if not dados.has(chave):
			return {}
	for chave in dados.keys():
		var nome := String(chave)
		if not _CHAVES.has(nome) and not _OPCIONAIS.has(nome):
			return {}
	var mapa := _validar_mapa(dados)
	if mapa.has("invalido"):
		return {}
	var versao: Variant = _inteiro(dados["versao"])
	var vida: Variant = _inteiro(dados["vida"])
	var vida_maxima: Variant = _inteiro(dados["vida_maxima"])
	var sentinela_vida: Variant = _inteiro(dados["sentinela_vida"])
	if versao == null or vida == null or vida_maxima == null or sentinela_vida == null:
		return {}
	if int(versao) != VERSAO or int(vida_maxima) != 3:
		return {}
	if int(vida) < 1 or int(vida) > int(vida_maxima):
		return {}
	if typeof(dados["sala"]) != TYPE_STRING or String(dados["sala"]) != SALA:
		return {}
	if typeof(dados["marcador"]) != TYPE_STRING or String(dados["marcador"]) != MARCADOR:
		return {}
	if typeof(dados["salto_duplo"]) != TYPE_BOOL or typeof(dados["sentinela_derrotada"]) != TYPE_BOOL:
		return {}
	var derrotada := bool(dados["sentinela_derrotada"])
	if derrotada and int(sentinela_vida) != 0:
		return {}
	if not derrotada and (int(sentinela_vida) < 1 or int(sentinela_vida) > 3):
		return {}
	var ficha := {
		"versao": int(versao),
		"sala": SALA,
		"marcador": MARCADOR,
		"vida": int(vida),
		"vida_maxima": int(vida_maxima),
		"salto_duplo": bool(dados["salto_duplo"]),
		"sentinela_vida": int(sentinela_vida),
		"sentinela_derrotada": derrotada,
	}
	if not mapa.is_empty():
		ficha["salas_visitadas"] = mapa["salas_visitadas"]
		ficha["sala_atual"] = mapa["sala_atual"]
	return ficha


func _validar_mapa(dados: Dictionary) -> Dictionary:
	var tem_lista := dados.has("salas_visitadas")
	var tem_atual := dados.has("sala_atual")
	if not tem_lista and not tem_atual:
		return {}
	if tem_lista != tem_atual:
		return {"invalido": true}
	if typeof(dados["salas_visitadas"]) != TYPE_ARRAY or typeof(dados["sala_atual"]) != TYPE_STRING:
		return {"invalido": true}
	var atual := String(dados["sala_atual"])
	if not _SALAS_DO_MAPA.has(atual):
		return {"invalido": true}
	var vistas: Array[String] = []
	for item in dados["salas_visitadas"]:
		if typeof(item) != TYPE_STRING:
			return {"invalido": true}
		var id := String(item)
		if not _SALAS_DO_MAPA.has(id) or vistas.has(id):
			return {"invalido": true}
		vistas.append(id)
	if vistas.is_empty() or not vistas.has("vestibulo") or not vistas.has(atual):
		return {"invalido": true}
	return {"salas_visitadas": vistas, "sala_atual": atual}


func ler_valido() -> Dictionary:
	if not FileAccess.file_exists(ARQUIVO):
		return {}
	var texto := FileAccess.get_file_as_string(ARQUIVO)
	return validar(_ler_json(texto))


func tem_gravacao_valida() -> bool:
	return not ler_valido().is_empty()


func gravar(cena: Node) -> bool:
	var texto := JSON.stringify(reunir(cena), "\t")
	if texto.is_empty() or not _escrever_temporario(texto):
		return false
	if validar(_ler_json(FileAccess.get_file_as_string(_TEMPORARIO))).is_empty():
		_apagar_se_for_arquivo(_NOME_TEMP)
		return false
	if not _substituir():
		return false
	gravacoes += 1
	return true


func restaurar(cena: Node) -> bool:
	var dados := ler_valido()
	if dados.is_empty():
		return false
	return _aplicar(cena, dados)


func _aplicar(cena: Node, dados: Dictionary) -> bool:
	var marcador := cena.get_node_or_null("CapelaDaLua/AltarDeSalvamento/AoLadoDoAltar") as Node3D
	var jogador := cena.get_node_or_null("Jogador") as CharacterBody3D
	var sentinela := cena.get_node_or_null("Galeria/SentinelaDaGaleria")
	var camera := cena.get_node_or_null("CameraLateral") as Camera3D
	var enquadramento := cena.get_node_or_null("CapelaDaLua/Enquadramento") as Node3D
	var retorno := cena.get_node_or_null("CapelaDaLua/Retorno") as Node3D
	if marcador == null or jogador == null or sentinela == null:
		return false
	if camera == null or enquadramento == null or retorno == null:
		return false
	if not sentinela.has_method("aplicar_estado_gravado"):
		return false
	var ponto := marcador.global_position
	ponto.z = 0.0
	if jogador.has_method("encerrar_golpe"):
		jogador.encerrar_golpe()
	jogador.global_position = ponto
	jogador.velocity = Vector3.ZERO
	jogador.reset_physics_interpolation()
	if jogador.has_method("definir_ponto_de_retorno"):
		var queda := retorno.global_position
		queda.z = 0.0
		jogador.definir_ponto_de_retorno(queda)
	jogador.set("pontos_de_vida", int(dados["vida"]))
	jogador.set("salto_duplo_adquirido", bool(dados["salto_duplo"]))
	var indicador := cena.get_node_or_null("IndicadorDeVida")
	if indicador != null and indicador.has_method("mostrar"):
		indicador.mostrar(int(dados["vida"]), int(dados["vida_maxima"]))
	if bool(dados["salto_duplo"]):
		var gema := cena.get_node_or_null("Galeria/ReliquiaDoSalto")
		if gema != null:
			gema.visible = false
			gema.queue_free()
	sentinela.call("aplicar_estado_gravado", int(dados["sentinela_vida"]))
	var capela := cena.get_node_or_null("CapelaDaLua") as Node3D
	if capela != null and cena.has_method("definir_sala_atual"):
		cena.call("definir_sala_atual", capela)
	else:
		camera.global_transform = enquadramento.global_transform
	var mapa := cena.get_tree().get_first_node_in_group("mapa_das_salas")
	if mapa != null:
		if dados.has("salas_visitadas") and mapa.has_method("aplicar_gravacao"):
			mapa.call("aplicar_gravacao", dados["salas_visitadas"], String(dados["sala_atual"]))
		elif mapa.has_method("aplicar_legado"):
			mapa.call("aplicar_legado")
	return true


func _escrever_temporario(texto: String) -> bool:
	var caminho := ProjectSettings.globalize_path(_TEMPORARIO)
	if DirAccess.dir_exists_absolute(caminho):
		return false
	var arquivo := FileAccess.open(_TEMPORARIO, FileAccess.WRITE)
	if arquivo == null:
		return false
	arquivo.store_string(texto)
	var erro := arquivo.get_error()
	arquivo.flush()
	if arquivo.get_error() != OK:
		erro = arquivo.get_error()
	arquivo.close()
	return erro == OK


func _substituir() -> bool:
	var pasta := DirAccess.open("user://")
	if pasta == null:
		return false
	if pasta.file_exists(_NOME_RESERVA):
		pasta.remove(_NOME_RESERVA)
	if pasta.file_exists(_NOME):
		if pasta.rename(_NOME, _NOME_RESERVA) != OK:
			return false
		if pasta.rename(_NOME_TEMP, _NOME) != OK:
			pasta.rename(_NOME_RESERVA, _NOME)
			return false
		pasta.remove(_NOME_RESERVA)
		return true
	return pasta.rename(_NOME_TEMP, _NOME) == OK


func _apagar_se_for_arquivo(nome: String) -> void:
	var pasta := DirAccess.open("user://")
	if pasta != null and pasta.file_exists(nome):
		pasta.remove(nome)


func _ler_json(texto: String) -> Variant:
	if texto.is_empty():
		return null
	var leitor := JSON.new()
	if leitor.parse(texto) != OK:
		return null
	return leitor.data


func _inteiro(valor: Variant) -> Variant:
	if typeof(valor) == TYPE_INT:
		return int(valor)
	if typeof(valor) == TYPE_FLOAT and is_finite(float(valor)) and float(valor) == floor(float(valor)):
		return int(valor)
	return null
