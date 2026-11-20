# Gera o manequim do protagonista, salva o .blend e exporta o GLB.
#
# Reproduzir:
#   C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_protagonista_base.py
#
# Eixos no Blender, com Z para cima:
#   frente do personagem = +X (nariz e ponta dos pés)
#   direita anatômica = -Y
#   esquerda anatômica = +Y
# O glTF entrega isso ao Godot com Y para cima. A frente continua em +X,
# a direita anatômica fica em +Z (lado da câmera, quando ele olha para a direita).
#
# Braços, antebraços, coxas e pernas têm a origem na articulação e rotação
# zero. Dobrar o cotovelo para a frente é Rotation Y negativo no antebraço.

import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector


RAIZ_DO_PROJETO = Path(__file__).resolve().parents[2]
CAMINHO_BLEND = RAIZ_DO_PROJETO / "arte-fonte" / "blender" / "protagonista_base.blend"
CAMINHO_GLB = RAIZ_DO_PROJETO / "assets" / "models" / "characters" / "protagonista_base.glb"
CAMINHO_IMAGEM = (
    RAIZ_DO_PROJETO / "MD-usario" / "relatorios" / "evidencias" / "04-protagonista-no-blender.png"
)

ALTURA_ALVO_M = 1.70
CHANFRO_M = 0.006

CORES_SRGB = {
    "Corpo": (214, 196, 176),
    "MembroDireito": (58, 104, 132),
    "MembroEsquerdo": (122, 78, 64),
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


def novo_material(nome: str):
    material = bpy.data.materials.new(nome)
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    vermelho, verde, azul = CORES_SRGB[nome]
    principled.inputs["Base Color"].default_value = (
        srgb_para_linear(vermelho),
        srgb_para_linear(verde),
        srgb_para_linear(azul),
        1.0,
    )
    principled.inputs["Roughness"].default_value = 0.72
    if "Metallic" in principled.inputs:
        principled.inputs["Metallic"].default_value = 0.0
    material["cor_srgb_hex"] = "#{:02X}{:02X}{:02X}".format(vermelho, verde, azul)
    return material


def criar_malha(nome: str, vertices, faces, material, pivo: Vector):
    malha = bpy.data.meshes.new(nome)
    objeto = bpy.data.objects.new(nome, malha)
    locais = [(vertice - pivo) for vertice in vertices]
    malha.from_pydata(locais, [], faces)
    malha.update()
    import bmesh

    bm = bmesh.new()
    bm.from_mesh(malha)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(malha)
    bm.free()
    malha.materials.append(material)
    for poligono in malha.polygons:
        poligono.use_smooth = False
    objeto.location = pivo
    bpy.context.scene.collection.objects.link(objeto)
    return objeto


def chanfrar(objeto, largura: float = CHANFRO_M) -> None:
    modificador = objeto.modifiers.new(name="Chanfro", type="BEVEL")
    modificador.width = largura
    modificador.segments = 1
    if hasattr(modificador, "limit_method"):
        modificador.limit_method = "ANGLE"
    if hasattr(modificador, "angle_limit"):
        modificador.angle_limit = math.radians(40.0)
    elif hasattr(modificador, "angle"):
        modificador.angle = math.radians(40.0)


def caixa(nome, centro: Vector, tamanho: Vector, material, pivo: Vector, chanfro: float = CHANFRO_M):
    meia = tamanho * 0.5
    cantos = []
    for sinal_x in (-1.0, 1.0):
        for sinal_y in (-1.0, 1.0):
            for sinal_z in (-1.0, 1.0):
                cantos.append(
                    centro
                    + Vector((meia.x * sinal_x, meia.y * sinal_y, meia.z * sinal_z))
                )
    faces = (
        (0, 2, 3, 1),
        (4, 5, 7, 6),
        (0, 1, 5, 4),
        (2, 6, 7, 3),
        (0, 4, 6, 2),
        (1, 3, 7, 5),
    )
    objeto = criar_malha(nome, cantos, faces, material, pivo)
    if chanfro > 0.0:
        chanfrar(objeto, chanfro)
    return objeto


def membro(nome, junta: Vector, ponta: Vector, raio: float, material):
    eixo = ponta - junta
    comprimento = eixo.length
    eixo.normalize()
    auxiliar = Vector((0.0, 1.0, 0.0))
    if abs(eixo.dot(auxiliar)) > 0.8:
        auxiliar = Vector((1.0, 0.0, 0.0))
    lateral = eixo.cross(auxiliar).normalized()
    normal = lateral.cross(eixo).normalized()
    recuo = junta - eixo * 0.012
    vertices = []
    for extremidade in (recuo, ponta):
        for sinal_a in (-1.0, 1.0):
            for sinal_b in (-1.0, 1.0):
                vertices.append(
                    extremidade + lateral * (raio * sinal_a) + normal * (raio * 0.82 * sinal_b)
                )
    faces = (
        (0, 2, 3, 1),
        (4, 5, 7, 6),
        (0, 1, 5, 4),
        (2, 6, 7, 3),
        (0, 4, 6, 2),
        (1, 3, 7, 5),
    )
    objeto = criar_malha(nome, vertices, faces, material, junta)
    chanfrar(objeto, min(CHANFRO_M, raio * 0.18))
    objeto["comprimento_m"] = comprimento
    return objeto


def adicionar_pe(nome, tornozelo: Vector, material):
    x, y, z = tornozelo
    sola = z - 0.075
    topo = sola + 0.055
    baixo = (
        Vector((x - 0.06, y - 0.042, sola)),
        Vector((x - 0.06, y + 0.042, sola)),
        Vector((x + 0.08, y + 0.036, sola)),
        Vector((x + 0.22, y, sola + 0.028)),
        Vector((x + 0.08, y - 0.036, sola)),
    )
    cima = (
        Vector((x - 0.045, y - 0.032, topo)),
        Vector((x - 0.045, y + 0.032, topo)),
        Vector((x + 0.06, y + 0.026, topo)),
        Vector((x + 0.16, y, sola + 0.07)),
        Vector((x + 0.06, y - 0.026, topo)),
    )
    vertices = list(baixo) + list(cima)
    faces = [(0, 1, 2, 3, 4), (5, 9, 8, 7, 6)]
    for indice in range(5):
        proximo = (indice + 1) % 5
        faces.append((indice, proximo, proximo + 5, indice + 5))
    return criar_malha(nome, vertices, faces, material, tornozelo)


def adicionar_cabeca(base: Vector, material):
    # Silhueta lateral: nuca para -X e nariz comprido para +X.
    perfil = (
        Vector((0.02, 0.00)),
        Vector((-0.07, 0.03)),
        Vector((-0.10, 0.12)),
        Vector((-0.04, 0.21)),
        Vector((0.04, 0.22)),
        Vector((0.08, 0.16)),
        Vector((0.16, 0.11)),
        Vector((0.07, 0.07)),
        Vector((0.09, 0.02)),
    )
    meia_largura = 0.075
    vertices = []
    for sinal in (-1.0, 1.0):
        for ponto in perfil:
            vertices.append(base + Vector((ponto.x, sinal * meia_largura, ponto.y)))
    total = len(perfil)
    faces = [tuple(range(total)), tuple(reversed(range(total, total * 2)))]
    for indice in range(total):
        proximo = (indice + 1) % total
        faces.append((indice, proximo, proximo + total, indice + total))
    return criar_malha("Cabeca", vertices, faces, material, base)


def construir(materiais):
    corpo = materiais["Corpo"]
    direito = materiais["MembroDireito"]
    esquerdo = materiais["MembroEsquerdo"]
    objetos = {}

    objetos["Pelve"] = caixa(
        "Pelve",
        Vector((0.0, 0.0, 0.96)),
        Vector((0.18, 0.30, 0.18)),
        corpo,
        Vector((0.0, 0.0, 0.96)),
    )
    objetos["Torax"] = caixa(
        "Torax",
        Vector((0.015, 0.0, 1.22)),
        Vector((0.22, 0.36, 0.36)),
        corpo,
        Vector((0.015, 0.0, 1.22)),
        0.01,
    )
    objetos["Pescoco"] = caixa(
        "Pescoco",
        Vector((0.01, 0.0, 1.45)),
        Vector((0.09, 0.09, 0.10)),
        corpo,
        Vector((0.01, 0.0, 1.40)),
        0.004,
    )
    objetos["Cabeca"] = adicionar_cabeca(Vector((0.0, 0.0, 1.48)), corpo)

    quadril_direito = Vector((0.0, -0.09, 0.92))
    joelho_direito = Vector((0.11, -0.10, 0.48))
    tornozelo_direito = Vector((-0.02, -0.10, 0.075))
    objetos["CoxaDireita"] = membro("CoxaDireita", quadril_direito, joelho_direito, 0.075, direito)
    objetos["PernaDireita"] = membro("PernaDireita", joelho_direito, tornozelo_direito, 0.055, direito)
    objetos["PeDireito"] = adicionar_pe("PeDireito", tornozelo_direito, direito)

    quadril_esquerdo = Vector((0.02, 0.09, 0.92))
    joelho_esquerdo = Vector((0.16, 0.10, 0.50))
    tornozelo_esquerdo = Vector((0.12, 0.10, 0.075))
    objetos["CoxaEsquerda"] = membro("CoxaEsquerda", quadril_esquerdo, joelho_esquerdo, 0.075, esquerdo)
    objetos["PernaEsquerda"] = membro("PernaEsquerda", joelho_esquerdo, tornozelo_esquerdo, 0.055, esquerdo)
    objetos["PeEsquerdo"] = adicionar_pe("PeEsquerdo", tornozelo_esquerdo, esquerdo)

    ombro_direito = Vector((0.02, -0.20, 1.36))
    cotovelo_direito = Vector((0.08, -0.25, 1.04))
    pulso_direito = Vector((0.15, -0.24, 0.78))
    objetos["BracoDireito"] = membro("BracoDireito", ombro_direito, cotovelo_direito, 0.048, direito)
    objetos["AntebracoDireito"] = membro("AntebracoDireito", cotovelo_direito, pulso_direito, 0.038, direito)
    objetos["MaoDireita"] = caixa(
        "MaoDireita",
        pulso_direito + Vector((0.035, 0.0, -0.04)),
        Vector((0.07, 0.05, 0.08)),
        direito,
        pulso_direito,
        0.003,
    )

    ombro_esquerdo = Vector((0.0, 0.20, 1.36))
    cotovelo_esquerdo = Vector((0.03, 0.24, 1.04))
    pulso_esquerdo = Vector((0.06, 0.23, 0.78))
    objetos["BracoEsquerdo"] = membro("BracoEsquerdo", ombro_esquerdo, cotovelo_esquerdo, 0.048, esquerdo)
    objetos["AntebracoEsquerdo"] = membro(
        "AntebracoEsquerdo", cotovelo_esquerdo, pulso_esquerdo, 0.038, esquerdo
    )
    objetos["MaoEsquerda"] = caixa(
        "MaoEsquerda",
        pulso_esquerdo + Vector((0.02, 0.0, -0.04)),
        Vector((0.06, 0.045, 0.08)),
        esquerdo,
        pulso_esquerdo,
        0.003,
    )
    return objetos


def mundo(objeto, local: Vector) -> Vector:
    # Antes de parentear, rotação e escala são identidade.
    return objeto.location + local


def limites(objeto):
    minimo = Vector((999.0, 999.0, 999.0))
    maximo = Vector((-999.0, -999.0, -999.0))
    for canto in objeto.bound_box:
        ponto = mundo(objeto, Vector(canto))
        for eixo in range(3):
            minimo[eixo] = min(minimo[eixo], ponto[eixo])
            maximo[eixo] = max(maximo[eixo], ponto[eixo])
    return minimo, maximo


def ajustar_pose(objetos) -> None:
    sola = limites(objetos["PeDireito"])[0].z
    topo = limites(objetos["Cabeca"])[1].z
    for objeto in objetos.values():
        objeto.location.z -= sola
    topo -= sola
    fator = ALTURA_ALVO_M / topo
    for objeto in objetos.values():
        objeto.location *= fator
        for vertice in objeto.data.vertices:
            vertice.co *= fator
        objeto.data.update()

    minimo_direito, maximo_direito = limites(objetos["PeDireito"])
    minimo_esquerdo, maximo_esquerdo = limites(objetos["PeEsquerdo"])
    meio = Vector(
        (
            (minimo_direito.x + maximo_direito.x + minimo_esquerdo.x + maximo_esquerdo.x) * 0.25,
            (minimo_direito.y + maximo_direito.y + minimo_esquerdo.y + maximo_esquerdo.y) * 0.25,
            0.0,
        )
    )
    for objeto in objetos.values():
        objeto.location.x -= meio.x
        objeto.location.y -= meio.y
    bpy.context.view_layer.update()


def medir(objetos) -> bool:
    sola = limites(objetos["PeDireito"])[0].z
    topo = limites(objetos["Cabeca"])[1].z
    pe_direito = limites(objetos["PeDireito"])
    pe_esquerdo = limites(objetos["PeEsquerdo"])
    print("MEDIDA sola_de_apoio_z %.4f" % sola)
    print("MEDIDA topo_da_cabeca_z %.4f" % topo)
    print("MEDIDA altura_m %.4f" % (topo - sola))
    print(
        "MEDIDA pe_direito_x %.3f %.3f y %.3f %.3f"
        % (pe_direito[0].x, pe_direito[1].x, pe_direito[0].y, pe_direito[1].y)
    )
    print(
        "MEDIDA pe_esquerdo_x %.3f %.3f y %.3f %.3f"
        % (pe_esquerdo[0].x, pe_esquerdo[1].x, pe_esquerdo[0].y, pe_esquerdo[1].y)
    )
    for nome in ("BracoDireito", "AntebracoDireito", "CoxaDireita", "PernaDireita"):
        pivo = objetos[nome].matrix_world.translation
        print("MEDIDA pivo_%s %.3f %.3f %.3f" % (nome, pivo.x, pivo.y, pivo.z))
    print("MEDIDA frente_blender +X")
    print("MEDIDA direita_anatomica_blender -Y")
    print("MEDIDA frente_godot +X")
    print("MEDIDA direita_anatomica_godot +Z")
    ok = abs(sola) < 0.002 and abs((topo - sola) - ALTURA_ALVO_M) < 0.01
    print("MEDIDA resultado %s" % ("ok" if ok else "falhou"))
    return ok


def criar_raiz(objetos):
    raiz = bpy.data.objects.new("Protagonista", None)
    raiz.empty_display_type = "PLAIN_AXES"
    raiz.empty_display_size = 0.25
    bpy.context.scene.collection.objects.link(raiz)
    pais = {
        "Pelve": raiz,
        "Torax": objetos["Pelve"],
        "Pescoco": objetos["Torax"],
        "Cabeca": objetos["Pescoco"],
        "BracoDireito": objetos["Torax"],
        "AntebracoDireito": objetos["BracoDireito"],
        "MaoDireita": objetos["AntebracoDireito"],
        "BracoEsquerdo": objetos["Torax"],
        "AntebracoEsquerdo": objetos["BracoEsquerdo"],
        "MaoEsquerda": objetos["AntebracoEsquerdo"],
        "CoxaDireita": objetos["Pelve"],
        "PernaDireita": objetos["CoxaDireita"],
        "PeDireito": objetos["PernaDireita"],
        "CoxaEsquerda": objetos["Pelve"],
        "PernaEsquerda": objetos["CoxaEsquerda"],
        "PeEsquerdo": objetos["PernaEsquerda"],
    }
    for nome, objeto in objetos.items():
        mundo_atual = objeto.matrix_world.copy()
        objeto.parent = pais[nome]
        objeto.matrix_world = mundo_atual
    bpy.context.view_layer.update()
    return raiz


def configurar_camera_e_luzes() -> None:
    cena = bpy.context.scene
    camera_dados = bpy.data.cameras.new("CameraTresQuartos")
    camera_dados.lens = 50
    camera_dados.clip_end = 40
    camera = bpy.data.objects.new("CameraTresQuartos", camera_dados)
    camera.location = (4.8, -4.15, 1.15)
    direcao = Vector((0.0, 0.0, 0.82)) - camera.location
    camera.rotation_euler = direcao.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.collection.objects.link(camera)
    cena.camera = camera

    sol_dados = bpy.data.lights.new("Sol", "SUN")
    sol_dados.energy = 4.4
    sol = bpy.data.objects.new("Sol", sol_dados)
    sol.rotation_euler = (math.radians(58.0), math.radians(4.0), math.radians(-28.0))
    bpy.context.scene.collection.objects.link(sol)

    preenchimento_dados = bpy.data.lights.new("Preenchimento", "SUN")
    preenchimento_dados.energy = 1.6
    preenchimento = bpy.data.objects.new("Preenchimento", preenchimento_dados)
    preenchimento.rotation_euler = (math.radians(72.0), 0.0, math.radians(150.0))
    bpy.context.scene.collection.objects.link(preenchimento)

    mundo = bpy.data.worlds.new("Fundo")
    cena.world = mundo
    mundo.use_nodes = True
    fundo = mundo.node_tree.nodes.get("Background")
    fundo.inputs["Color"].default_value = (0.045, 0.05, 0.065, 1.0)
    fundo.inputs["Strength"].default_value = 0.55


def exportar_glb(raiz) -> None:
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


def renderizar() -> None:
    cena = bpy.context.scene
    motores = ("BLENDER_EEVEE", "BLENDER_EEVEE_NEXT", "BLENDER_WORKBENCH")
    disponiveis = {
        item.identifier
        for item in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items
    }
    for motor in motores:
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
    CAMINHO_IMAGEM.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.render.render(write_still=True)
    print("RENDERIZADO %s" % CAMINHO_IMAGEM)


def main() -> None:
    limpar_cena()
    preparar_unidades()
    materiais = {nome: novo_material(nome) for nome in CORES_SRGB}
    for nome, material in materiais.items():
        print("COR %s %s" % (nome, material["cor_srgb_hex"]))
    objetos = construir(materiais)
    ajustar_pose(objetos)
    medidas_ok = medir(objetos)
    raiz = criar_raiz(objetos)
    configurar_camera_e_luzes()
    bpy.ops.wm.save_as_mainfile(filepath=str(CAMINHO_BLEND))
    print("SALVO %s" % CAMINHO_BLEND)
    renderizar()
    exportar_glb(raiz)
    if not medidas_ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
