# Gera a parede, a pilastra e a faixa do piso do vestíbulo.
#
# Reproduzir:
#   C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_vestibulo_modular.py
#
# 1 unidade = 1 metro. Z é a altura. X cresce para a direita.
# Y = 0 é a face de referência. O relevo avança para Y negativo.
# O glTF converte isso para o Godot: X continua X, Z vira Y, Y negativo vira Z positivo.
# No Godot, Z positivo aponta para a câmera. A face visível é essa.

import math
from pathlib import Path

import bpy
from mathutils import Vector


RAIZ = Path(__file__).resolve().parents[2]
PASTA_BLEND = RAIZ / "arte-fonte" / "blender"
PASTA_GLB = RAIZ / "assets" / "models" / "environment" / "vestibulo"
CAMINHO_BLEND = PASTA_BLEND / "vestibulo_modular.blend"
CAMINHO_IMAGEM = RAIZ / "MD-usario" / "relatorios" / "evidencias" / "13-modulos-no-blender.png"

LARGURA_M = 2.0
ALTURA_PAREDE_M = 5.60
ALTURA_PILASTRA_M = 5.92
ALTURA_FAIXA_M = 1.02

CORES_SRGB = {
    "PedraClara": (201, 192, 180),
    "PedraMedia": (166, 156, 144),
    "PedraEscura": (122, 115, 108),
    "Argamassa": (74, 68, 62),
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
        mundo.color = (0.025, 0.028, 0.036)


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
    principled.inputs["Roughness"].default_value = 0.86
    if "Metallic" in principled.inputs:
        principled.inputs["Metallic"].default_value = 0.0
    for nome_especular in ("Specular IOR Level", "Specular"):
        if nome_especular in principled.inputs:
            principled.inputs[nome_especular].default_value = 0.22
            break
    material["cor_srgb_hex"] = "#{:02X}{:02X}{:02X}".format(vermelho, verde, azul)
    return material


def criar_caixa(nome: str, centro, tamanho, material, pai):
    import bmesh

    malha = bpy.data.meshes.new(nome)
    bm = bmesh.new()
    resultado = bmesh.ops.create_cube(bm, size=1.0)
    for vertice in resultado["verts"]:
        vertice.co.x = vertice.co.x * tamanho[0] + centro[0]
        vertice.co.y = vertice.co.y * tamanho[1] + centro[1]
        vertice.co.z = vertice.co.z * tamanho[2] + centro[2]
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(malha)
    bm.free()
    objeto = bpy.data.objects.new(nome, malha)
    malha.materials.append(material)
    for poligono in malha.polygons:
        poligono.use_smooth = False
    bpy.context.scene.collection.objects.link(objeto)
    objeto.parent = pai
    return objeto


def novo_eixo(nome: str):
    eixo = bpy.data.objects.new(nome, None)
    bpy.context.scene.collection.objects.link(eixo)
    eixo.empty_display_type = "PLAIN_AXES"
    eixo.empty_display_size = 0.35
    return eixo


def adicionar_parede(materiais, pai) -> None:
    criar_caixa(
        "Maciço",
        (LARGURA_M / 2.0, 0.20, ALTURA_PAREDE_M / 2.0),
        (LARGURA_M, 0.40, ALTURA_PAREDE_M),
        materiais["Argamassa"],
        pai,
    )
    altura_bloco = 0.56
    passo = 0.64
    for indice in range(8):
        z0 = 0.04 + indice * passo
        z1 = z0 + altura_bloco
        avanco = 0.10 if indice % 2 == 0 else 0.06
        tom = materiais["PedraClara"] if indice % 2 == 0 else materiais["PedraMedia"]
        if indice % 4 == 3:
            tom = materiais["PedraEscura"]
        if indice % 2 == 0:
            faixas = ((0.04, 0.96), (1.04, 1.96))
        else:
            faixas = ((0.04, 0.62), (0.70, 1.30), (1.38, 1.96))
        for ordem, (x0, x1) in enumerate(faixas):
            relevo = avanco if ordem % 2 == 0 else avanco + 0.04
            criar_caixa(
                "Bloco_%d_%d" % (indice, ordem),
                ((x0 + x1) / 2.0, -relevo / 2.0, (z0 + z1) / 2.0),
                (x1 - x0, relevo, z1 - z0),
                tom,
                pai,
            )
    criar_caixa(
        "Cornija",
        (LARGURA_M / 2.0, -0.08, 5.36),
        (LARGURA_M, 0.16, 0.48),
        materiais["PedraClara"],
        pai,
    )


def adicionar_pilastra(materiais, pai) -> None:
    criar_caixa(
        "Alma",
        (0.0, 0.16, ALTURA_PILASTRA_M / 2.0),
        (0.50, 0.32, ALTURA_PILASTRA_M),
        materiais["Argamassa"],
        pai,
    )
    criar_caixa(
        "Base",
        (0.0, -0.12, 0.16),
        (0.66, 0.24, 0.32),
        materiais["PedraEscura"],
        pai,
    )
    for indice in range(7):
        z0 = 0.36 + indice * 0.72
        criar_caixa(
            "Fuste_%d" % indice,
            (0.0, -0.11, z0 + 0.30),
            (0.46, 0.22, 0.60),
            materiais["PedraMedia"] if indice % 2 else materiais["PedraClara"],
            pai,
        )
    criar_caixa(
        "Capitel",
        (0.0, -0.14, 5.76),
        (0.72, 0.28, 0.32),
        materiais["PedraClara"],
        pai,
    )


def adicionar_faixa(materiais, pai) -> None:
    criar_caixa(
        "Nucleo",
        (LARGURA_M / 2.0, -0.08, -ALTURA_FAIXA_M / 2.0),
        (LARGURA_M, 0.16, ALTURA_FAIXA_M),
        materiais["Argamassa"],
        pai,
    )
    cursos = (
        ((0.04, 0.96), (1.04, 1.96), -0.34, -0.02, 0.14, "PedraEscura"),
        ((0.04, 0.62), (0.70, 1.30), (1.38, 1.96), -0.68, -0.40, 0.18, "PedraMedia"),
        ((0.04, 0.96), (1.04, 1.96), -1.02, -0.74, 0.15, "PedraClara"),
    )
    for indice, curso in enumerate(cursos):
        faixas = curso[:-4]
        z0, z1, relevo, tom = curso[-4:]
        for ordem, (x0, x1) in enumerate(faixas):
            avanço = relevo if ordem % 2 == 0 else relevo + 0.03
            criar_caixa(
                "Fiada_%d_%d" % (indice, ordem),
                ((x0 + x1) / 2.0, -avanço / 2.0, (z0 + z1) / 2.0),
                (x1 - x0, avanço, z1 - z0),
                materiais[tom] if ordem % 2 == 0 else materiais["PedraClara"],
                pai,
            )


def limites(raiz):
    minimo = Vector((999.0, 999.0, 999.0))
    maximo = Vector((-999.0, -999.0, -999.0))
    objetos = [raiz] + list(raiz.children_recursive)
    for objeto in objetos:
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


def conferir_encaixe(parede) -> None:
    copia = parede.copy()
    copia.name = "ParedeDeCantaria_copia"
    bpy.context.scene.collection.objects.link(copia)
    for filho in parede.children:
        clone = filho.copy()
        clone.parent = copia
        bpy.context.scene.collection.objects.link(clone)
    copia.location.x = LARGURA_M
    bpy.context.view_layer.update()
    _, direita = limites(parede)
    esquerda, _ = limites(copia)
    folga = esquerda.x - direita.x
    print(
        "ENCAIXE max_x=%.4f min_copia=%.4f folga=%.4f"
        % (direita.x, esquerda.x, folga)
    )
    if abs(folga) > 0.001:
        raise RuntimeError("as paredes não encaixam. folga=%.4f" % folga)
    return copia


def exportar(raiz, caminho: Path) -> None:
    caminho.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for filho in raiz.children_recursive:
        filho.select_set(True)
    bpy.context.view_layer.objects.active = raiz
    argumentos = {
        "filepath": str(caminho),
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
    print("EXPORTADO %s" % caminho)


def preparar_camera(alvo) -> None:
    cena = bpy.context.scene
    camera_data = bpy.data.cameras.new("CameraDoJogo")
    camera_data.type = "ORTHO"
    # 1280×720 e Size = 8 no Godot: a altura visível é 8 m e a largura é 14,22 m.
    camera_data.ortho_scale = 8.0 * (1280.0 / 720.0)
    camera = bpy.data.objects.new("CameraDoJogo", camera_data)
    cena.collection.objects.link(camera)
    camera.location = (alvo.x, alvo.y - 12.0, alvo.z)
    camera.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    cena.camera = camera
    sol = bpy.data.lights.new("Sol", "SUN")
    sol.energy = 3.2
    sol.color = (1.0, 0.94, 0.86)
    luz = bpy.data.objects.new("Sol", sol)
    cena.collection.objects.link(luz)
    luz.rotation_euler = (math.radians(58.0), math.radians(-18.0), math.radians(24.0))
    enchimento = bpy.data.lights.new("Enchimento", "SUN")
    enchimento.energy = 0.7
    enchimento.color = (0.75, 0.82, 0.95)
    luz_fria = bpy.data.objects.new("Enchimento", enchimento)
    cena.collection.objects.link(luz_fria)
    luz_fria.rotation_euler = (math.radians(78.0), math.radians(10.0), math.radians(-140.0))


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
    cena.world.color = (0.03, 0.034, 0.045)
    CAMINHO_IMAGEM.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.render.render(write_still=True)
    print("RENDERIZADO %s" % CAMINHO_IMAGEM)


def imprimir_peca(nome: str, raiz) -> None:
    minimo, maximo = limites(raiz)
    print(
        "PECA %s largura_x=%.3f profundidade_y=%.3f altura_z=%.3f origem_no_canto=%.3f,%.3f,%.3f frente_y=%.3f"
        % (
            nome,
            maximo.x - minimo.x,
            maximo.y - minimo.y,
            maximo.z - minimo.z,
            minimo.x,
            minimo.y,
            minimo.z,
            minimo.y,
        )
    )


def main() -> None:
    limpar_cena()
    preparar_unidades()
    materiais = {nome: novo_material(nome) for nome in CORES_SRGB}
    parede = novo_eixo("ParedeDeCantaria")
    adicionar_parede(materiais, parede)
    pilastra = novo_eixo("PilastraDeCantaria")
    adicionar_pilastra(materiais, pilastra)
    faixa = novo_eixo("FaixaDoPiso")
    adicionar_faixa(materiais, faixa)
    bpy.context.view_layer.update()
    copia = conferir_encaixe(parede)
    imprimir_peca("parede", parede)
    imprimir_peca("pilastra", pilastra)
    imprimir_peca("faixa", faixa)
    pilastra.location.x = LARGURA_M
    bpy.context.view_layer.update()
    preparar_camera(Vector((LARGURA_M, 0.0, 2.2)))
    renderizar()
    pilastra.location.x = 0.0
    bpy.context.view_layer.update()
    exportar(parede, PASTA_GLB / "parede_de_cantaria.glb")
    exportar(pilastra, PASTA_GLB / "pilastra_de_cantaria.glb")
    exportar(faixa, PASTA_GLB / "faixa_do_piso.glb")
    # No arquivo editável, a pilastra fica em cima da junta da cópia de conferência.
    pilastra.location.x = LARGURA_M
    PASTA_BLEND.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(CAMINHO_BLEND))
    print("SALVO %s" % CAMINHO_BLEND)


if __name__ == "__main__":
    main()
