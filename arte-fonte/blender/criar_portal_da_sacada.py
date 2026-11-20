# Gera o portal ogival da sacada.
#
# Reproduzir:
#   C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_portal_da_sacada.py
#
# Medidas da passagem, lidas na cena 14 antes deste modelo:
# parede lisa 2,400 m de largura; vão livre entre ombreiras 1,040 m;
# vão luminoso 1,900 m acima do topo da laje (Y = 2,350);
# face da parede em Z = -0,840, a 0,840 m dos pés em Z = 0.
#
# O portal usa o vão livre e sobe em ogiva abaixo da cornija da cantaria.
# 1 unidade = 1 metro. A origem é o centro da soleira, na altura dos pés.
# X é a largura, Z é a altura. Y = 0 é a face da parede.
# O relevo avança para Y negativo, que o glTF entrega ao Godot como Z positivo.

import math
from pathlib import Path

import bpy
from mathutils import Vector


RAIZ = Path(__file__).resolve().parents[2]
PASTA_BLEND = RAIZ / "arte-fonte" / "blender"
PASTA_GLB = RAIZ / "assets" / "models" / "environment" / "vestibulo"
CAMINHO_BLEND = PASTA_BLEND / "portal_da_sacada.blend"
CAMINHO_GLB = PASTA_GLB / "portal_da_sacada.glb"
CAMINHO_IMAGEM = RAIZ / "MD-usario" / "relatorios" / "evidencias" / "14-portal-no-blender.png"

# Meia largura do vão na soleira. A curva estreita um pouco na altura da cabeça.
W = 0.56
# Centros dos arcos, mais próximos que o vão, para a ogiva não alcançar a cornija.
C = 0.36
Z_ARRANCO = 1.42
ESPESSURA = 0.28
R_IN = C + W
R_OUT = R_IN + ESPESSURA
FOLGA_JUNTA = 0.08
ALTURA_REFERENCIA = 1.70

CORES_SRGB = {
    "PedraClara": (201, 192, 180),
    "PedraMedia": (166, 156, 144),
    "PedraEscura": (122, 115, 108),
    "Argamassa": (74, 68, 62),
    "VaoQuente": (255, 214, 128),
    "Referencia": (214, 220, 230),
}


def srgb_para_linear(canal: float) -> float:
    valor = canal / 255.0
    if valor <= 0.04045:
        return valor / 12.92
    return ((valor + 0.055) / 1.055) ** 2.4


def limpar_cena() -> None:
    if bpy.ops.object.mode_set.poll():
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for colecao in (bpy.data.meshes, bpy.data.materials, bpy.data.lights, bpy.data.cameras):
        for bloco in list(colecao):
            if bloco.users == 0:
                colecao.remove(bloco)


def preparar_unidades() -> None:
    cena = bpy.context.scene
    cena.unit_settings.system = "METRIC"
    cena.unit_settings.scale_length = 1.0
    cena.unit_settings.length_unit = "METERS"
    try:
        cena.view_settings.view_transform = "Standard"
    except TypeError:
        pass
    mundo = cena.world
    if mundo is None:
        mundo = bpy.data.worlds.new("Mundo")
        cena.world = mundo
    mundo.use_nodes = False
    if hasattr(mundo, "color"):
        mundo.color = (0.04, 0.045, 0.06)


def novo_material(nome: str, emissao: float = 0.0):
    material = bpy.data.materials.new(nome)
    material.use_nodes = True
    if hasattr(material, "use_backface_culling"):
        material.use_backface_culling = emissao <= 0.0
    principled = material.node_tree.nodes.get("Principled BSDF")
    vermelho, verde, azul = CORES_SRGB[nome]
    cor = (
        srgb_para_linear(vermelho),
        srgb_para_linear(verde),
        srgb_para_linear(azul),
        1.0,
    )
    principled.inputs["Base Color"].default_value = cor
    principled.inputs["Roughness"].default_value = 0.9 if emissao <= 0.0 else 0.45
    if "Metallic" in principled.inputs:
        principled.inputs["Metallic"].default_value = 0.0
    if emissao > 0.0:
        for nome_cor in ("Emission Color", "Emission"):
            if nome_cor in principled.inputs:
                principled.inputs[nome_cor].default_value = cor
                break
        if "Emission Strength" in principled.inputs:
            principled.inputs["Emission Strength"].default_value = emissao
    material["cor_srgb_hex"] = "#{:02X}{:02X}{:02X}".format(vermelho, verde, azul)
    return material


def novo_eixo(nome: str):
    eixo = bpy.data.objects.new(nome, None)
    bpy.context.scene.collection.objects.link(eixo)
    eixo.empty_display_type = "PLAIN_AXES"
    eixo.empty_display_size = 0.35
    return eixo


def criar_malha(nome: str, vertices, faces, material, pai):
    import bmesh

    centro = Vector((0.0, 0.0, 0.0))
    for vertice in vertices:
        centro += Vector(vertice)
    centro /= float(len(vertices))
    locais = [Vector(vertice) - centro for vertice in vertices]
    malha = bpy.data.meshes.new(nome)
    malha.from_pydata([tuple(item) for item in locais], [], faces)
    malha.validate()
    bm = bmesh.new()
    bm.from_mesh(malha)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(malha)
    bm.free()
    malha.update()
    objeto = bpy.data.objects.new(nome, malha)
    malha.materials.append(material)
    for poligono in malha.polygons:
        poligono.use_smooth = False
    bpy.context.scene.collection.objects.link(objeto)
    objeto.parent = pai
    objeto.location = centro
    return objeto


def criar_caixa(nome: str, centro, tamanho, material, pai):
    vertices = []
    for dz in (-0.5, 0.5):
        for dy in (-0.5, 0.5):
            for dx in (-0.5, 0.5):
                vertices.append((
                    centro[0] + dx * tamanho[0],
                    centro[1] + dy * tamanho[1],
                    centro[2] + dz * tamanho[2],
                ))
    # Ordem dos cantos: z externo, depois y, depois x.
    faces = [
        (0, 1, 3, 2),
        (4, 6, 7, 5),
        (0, 2, 6, 4),
        (1, 5, 7, 3),
        (0, 4, 5, 1),
        (2, 3, 7, 6),
    ]
    return criar_malha(nome, vertices, faces, material, pai)


def ponto_do_arco(centro_x: float, raio: float, angulo: float):
    return (
        centro_x + math.cos(angulo) * raio,
        Z_ARRANCO + math.sin(angulo) * raio,
    )


def criar_anel(nome, centro_x, angulo_a, angulo_b, y_tras, y_frente, material, pai, raio_in=R_IN, raio_out=R_OUT):
    perfil = []
    for angulo in (angulo_a, angulo_b):
        perfil.append(ponto_do_arco(centro_x, raio_in, angulo))
        perfil.append(ponto_do_arco(centro_x, raio_out, angulo))
    # a interno, a externo, b interno, b externo. Reordena o anel.
    ordem = (perfil[0], perfil[1], perfil[3], perfil[2])
    vertices = []
    for y in (y_tras, y_frente):
        for x, z in ordem:
            vertices.append((x, y, z))
    faces = [
        (4, 5, 6, 7),
        (0, 3, 2, 1),
        (0, 1, 5, 4),
        (1, 2, 6, 5),
        (2, 3, 7, 6),
        (3, 0, 4, 7),
    ]
    return criar_malha(nome, vertices, faces, material, pai)


def criar_prisma(nome, perfil, y_tras, y_frente, material, pai):
    vertices = []
    for y in (y_tras, y_frente):
        for x, z in perfil:
            vertices.append((x, y, z))
    quantidade = len(perfil)
    faces = [tuple(quantidade + indice for indice in range(quantidade))]
    faces.append(tuple(reversed(range(quantidade))))
    for indice in range(quantidade):
        proximo = (indice + 1) % quantidade
        faces.append((
            indice,
            proximo,
            quantidade + proximo,
            quantidade + indice,
        ))
    return criar_malha(nome, vertices, faces, material, pai)


def meia_abertura(altura: float) -> float:
    if altura <= Z_ARRANCO:
        return W
    dz = altura - Z_ARRANCO
    dentro = R_IN * R_IN - dz * dz
    if dentro <= 0.0:
        return 0.0
    return -C + math.sqrt(dentro)


def angulo_da_coroa() -> float:
    return math.acos(-C / R_IN)


def conferir_proporcao() -> float:
    abertura_cabeca = meia_abertura(ALTURA_REFERENCIA) * 2.0
    ponta = Z_ARRANCO + math.sqrt(R_OUT * R_OUT - C * C)
    print("PROPORCAO abertura_na_soleira=%.3f abertura_na_cabeca=%.3f ponta_z=%.3f" % (
        W * 2.0,
        abertura_cabeca,
        ponta,
    ))
    if abertura_cabeca < 0.95:
        raise RuntimeError("a cabeça de 1,70 m não cabe no vão")
    if ponta > 2.65:
        raise RuntimeError("a ponta invade a cornija. z=%.3f" % ponta)
    if ponta < ALTURA_REFERENCIA + 0.45:
        raise RuntimeError("a ogiva não se destaca da cabeça")
    return ponta


def adicionar_ombreiras(materiais, pai) -> None:
    andares = (
        ("Base", 0.00, 0.40, "PedraEscura"),
        ("Fuste", 0.48, 0.88, "PedraMedia"),
        ("Capitel", 0.96, 1.34, "PedraClara"),
    )
    for sinal, lado in ((-1.0, "Esquerda"), (1.0, "Direita")):
        criar_caixa(
            "Argamassa%s" % lado,
            (sinal * (W + ESPESSURA * 0.5), 0.005, 0.70),
            (ESPESSURA + 0.04, 0.11, 1.40),
            materiais["Argamassa"],
            pai,
        )
        for nome, z0, z1, tom in andares:
            criar_caixa(
                "Ombreira%s%s" % (nome, lado),
                (sinal * (W + ESPESSURA * 0.5), -0.07, (z0 + z1) * 0.5),
                (ESPESSURA, 0.18, z1 - z0),
                materiais[tom],
                pai,
            )


def adicionar_ogiva(materiais, pai):
    coroa = angulo_da_coroa()
    coroa_direita = math.pi - coroa
    margem = FOLGA_JUNTA / ((R_IN + R_OUT) * 0.5)
    criar_anel(
        "ArgamassaDoArcoEsq",
        C,
        math.pi,
        coroa,
        0.06,
        -0.05,
        materiais["Argamassa"],
        pai,
        R_IN,
        R_OUT + 0.02,
    )
    criar_anel(
        "ArgamassaDoArcoDir",
        -C,
        0.0,
        coroa_direita,
        0.06,
        -0.05,
        materiais["Argamassa"],
        pai,
        R_IN,
        R_OUT + 0.02,
    )
    cortes_esquerda = (
        ("AduelaInferiorEsquerda", math.pi, coroa + (math.pi - coroa) * 2.0 / 3.0, "PedraMedia", -0.16),
        ("AduelaSuperiorEsquerda", coroa + (math.pi - coroa) * 2.0 / 3.0, coroa + (math.pi - coroa) / 3.0, "PedraEscura", -0.16),
    )
    for nome, a0, a1, tom, frente in cortes_esquerda:
        inicio = a0 - margem * 0.5
        fim = a1 + margem * 0.5
        if nome.startswith("AduelaInferior"):
            inicio = a0
        criar_anel(nome, C, inicio, fim, 0.02, frente, materiais[tom], pai)
    cortes_direita = (
        ("AduelaInferiorDireita", 0.0, coroa_direita / 3.0, "PedraMedia", -0.16),
        ("AduelaSuperiorDireita", coroa_direita / 3.0, coroa_direita * 2.0 / 3.0, "PedraEscura", -0.16),
    )
    for nome, a0, a1, tom, frente in cortes_direita:
        inicio = a0 + (margem * 0.5 if a0 > 0.0 else 0.0)
        fim = a1 - margem * 0.5
        criar_anel(nome, -C, inicio, fim, 0.02, frente, materiais[tom], pai)
    pedra = criar_malha_da_pedra_central(materiais["PedraClara"], pai, coroa, coroa_direita, margem)
    return pedra


def _amostra(centro_x: float, raio: float, angulo: float, y: float):
    return (
        centro_x + math.cos(angulo) * raio,
        y,
        Z_ARRANCO + math.sin(angulo) * raio,
    )


def criar_malha_da_pedra_central(material, pai, coroa_esquerda, coroa_direita, margem):
    # Uma pedra só atravessa a ponta. Cada junta de baixo recua meia folga.
    span = math.pi - coroa_esquerda
    a_esquerda = coroa_esquerda + span / 3.0 - margem * 0.5
    a_direita = coroa_direita * 2.0 / 3.0 + margem * 0.5
    vertices = []
    for y in (0.02, -0.22):
        internos = []
        for passo in range(5):
            angulo = a_esquerda + (coroa_esquerda - a_esquerda) * passo / 4.0
            internos.append(_amostra(C, R_IN, angulo, y))
        for passo in range(1, 5):
            angulo = coroa_direita + (a_direita - coroa_direita) * passo / 4.0
            internos.append(_amostra(-C, R_IN, angulo, y))
        externos = []
        for passo in range(4, -1, -1):
            angulo = coroa_direita + (a_direita - coroa_direita) * passo / 4.0
            externos.append(_amostra(-C, R_OUT, angulo, y))
        for passo in range(3, -1, -1):
            angulo = a_esquerda + (coroa_esquerda - a_esquerda) * passo / 4.0
            externos.append(_amostra(C, R_OUT, angulo, y))
        vertices.extend(internos)
        vertices.extend(externos)
    quantidade = len(vertices) // 2
    faces = [tuple(range(quantidade))]
    faces.append(tuple(reversed(range(quantidade, quantidade * 2))))
    for indice in range(quantidade):
        proximo = (indice + 1) % quantidade
        faces.append((indice, proximo, quantidade + proximo, quantidade + indice))
    return criar_malha("PedraCentral", vertices, faces, material, pai)


def perfil_do_vao():
    coroa = angulo_da_coroa()
    pontos = [(-W, 0.02), (-W, Z_ARRANCO)]
    for passo in range(1, 9):
        angulo = math.pi + (coroa - math.pi) * passo / 8.0
        pontos.append(ponto_do_arco(C, R_IN - 0.01, angulo))
    coroa_direita = math.pi - coroa
    for passo in range(1, 8):
        angulo = coroa_direita + (0.0 - coroa_direita) * passo / 8.0
        pontos.append(ponto_do_arco(-C, R_IN - 0.01, angulo))
    pontos.append((W, Z_ARRANCO))
    pontos.append((W, 0.02))
    return pontos


def adicionar_referencia(material) -> None:
    criar_caixa(
        "Referencia170",
        (0.0, -0.9, ALTURA_REFERENCIA * 0.5),
        (0.42, 0.22, ALTURA_REFERENCIA),
        material,
        None,
    )


def adicionar_fundo(material) -> None:
    criar_caixa(
        "FundoDeConferencia",
        (0.0, 0.46, 2.15),
        (4.2, 0.12, 4.5),
        material,
        None,
    )


def limites(raiz):
    minimo = Vector((999.0, 999.0, 999.0))
    maximo = Vector((-999.0, -999.0, -999.0))
    for objeto in [raiz] + list(raiz.children_recursive):
        if objeto.type != "MESH":
            continue
        for canto in objeto.bound_box:
            mundo = objeto.matrix_world @ Vector(canto)
            minimo.x = min(minimo.x, mundo.x)
            minimo.y = min(minimo.y, mundo.y)
            minimo.z = min(minimo.z, mundo.z)
            maximo.x = max(maximo.x, mundo.x)
            maximo.y = max(maximo.y, mundo.y)
            maximo.z = max(maximo.z, mundo.z)
    return minimo, maximo


def exportar(raiz) -> None:
    CAMINHO_GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for filho in raiz.children_recursive:
        filho.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    argumentos = {
        "filepath": str(CAMINHO_GLB),
        "export_format": "GLB",
        "use_selection": True,
        "export_apply": True,
        "export_yup": True,
        "export_materials": "EXPORT",
    }
    propriedades = set(bpy.ops.export_scene.gltf.get_rna_type().properties.keys())
    if "export_cameras" in propriedades:
        argumentos["export_cameras"] = False
    if "export_lights" in propriedades:
        argumentos["export_lights"] = False
    bpy.ops.export_scene.gltf(**argumentos)
    print("EXPORTADO %s" % CAMINHO_GLB)


def preparar_camera() -> None:
    cena = bpy.context.scene
    camera_data = bpy.data.cameras.new("CameraDoJogo")
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = 8.0 * (1280.0 / 720.0)
    camera = bpy.data.objects.new("CameraDoJogo", camera_data)
    cena.collection.objects.link(camera)
    camera.location = (0.0, -12.0, 1.7)
    camera.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    cena.camera = camera
    sol = bpy.data.lights.new("Sol", "SUN")
    sol.energy = 3.2
    sol.color = (1.0, 0.94, 0.86)
    luz = bpy.data.objects.new("Sol", sol)
    cena.collection.objects.link(luz)
    luz.rotation_euler = (math.radians(58.0), math.radians(-18.0), math.radians(24.0))


def renderizar() -> None:
    cena = bpy.context.scene
    disponiveis = {item.identifier for item in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    for motor in ("BLENDER_EEVEE", "BLENDER_EEVEE_NEXT", "BLENDER_WORKBENCH"):
        if motor in disponiveis:
            cena.render.engine = motor
            break
    print("RENDER motor %s" % cena.render.engine)
    if hasattr(cena, "eevee") and hasattr(cena.eevee, "taa_render_samples"):
        cena.eevee.taa_render_samples = 16
    cena.render.resolution_x = 1280
    cena.render.resolution_y = 720
    cena.render.resolution_percentage = 100
    cena.render.filepath = str(CAMINHO_IMAGEM)
    cena.render.image_settings.file_format = "PNG"
    cena.render.film_transparent = False
    CAMINHO_IMAGEM.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.render.render(write_still=True)
    print("RENDERIZADO %s" % CAMINHO_IMAGEM)


def main() -> None:
    limpar_cena()
    preparar_unidades()
    ponta = conferir_proporcao()
    materiais = {nome: novo_material(nome) for nome in ("PedraClara", "PedraMedia", "PedraEscura", "Argamassa", "Referencia")}
    materiais["VaoQuente"] = novo_material("VaoQuente", 3.2)
    portal = novo_eixo("PortalDaSacada")
    adicionar_ombreiras(materiais, portal)
    pedra = adicionar_ogiva(materiais, portal)
    criar_prisma("Vao", perfil_do_vao(), 0.08, 0.14, materiais["VaoQuente"], portal)
    adicionar_referencia(materiais["Referencia"])
    adicionar_fundo(materiais["PedraMedia"])
    bpy.context.view_layer.update()
    minimo, maximo = limites(portal)
    print(
        "PECA portal largura_x=%.3f profundidade_y=%.3f altura_z=%.3f ponta_z=%.3f"
        % (maximo.x - minimo.x, maximo.y - minimo.y, maximo.z - minimo.z, ponta)
    )
    print(
        "PECA PedraCentral location=%.4f,%.4f,%.4f"
        % (pedra.location.x, pedra.location.y, pedra.location.z)
    )
    preparar_camera()
    renderizar()
    exportar(portal)
    PASTA_BLEND.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(CAMINHO_BLEND))
    print("SALVO %s" % CAMINHO_BLEND)


if __name__ == "__main__":
    main()
