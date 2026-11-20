# Gera o arco gótico de pedra, salva o .blend e exporta o GLB.
#
# Reproduzir, a partir de qualquer pasta:
#   C:\Users\Raul\Tools\Blender\5.3.0\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_arco_de_pedra.py
#
# Unidades: 1 unidade do Blender = 1 metro. Z é a altura. A origem fica no
# centro da passagem, no piso. O exportador glTF converte Z para cima em Y
# para cima; no Godot, X continua o eixo da travessia.

import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector


RAIZ_DO_PROJETO = Path(__file__).resolve().parents[2]
CAMINHO_BLEND = RAIZ_DO_PROJETO / "arte-fonte" / "blender" / "arco_de_pedra.blend"
CAMINHO_GLB = RAIZ_DO_PROJETO / "assets" / "models" / "environment" / "arco_de_pedra.glb"
CAMINHO_IMAGEM = (
    RAIZ_DO_PROJETO / "MD-usario" / "relatorios" / "evidencias" / "03-arco-no-blender.png"
)

# A cena do Godot usa estes mesmos números. A rotação é aplicada lá, não aqui.
POSICAO_X_NO_GODOT = -2.05
ROTACAO_Y_GRAUS = 14.0

CHANFRO_M = 0.012
FOLGA_DA_CUNHA = 0.016
ABERTURA_INTERNA_M = 2.40
MEIA_ABERTURA = ABERTURA_INTERNA_M / 2.0
MOLA_M = 2.48
RAIO_INTERNO = ABERTURA_INTERNA_M
RAIO_EXTERNO = 2.82
ESPESSURA_DO_ARCO = 0.52
ESPESSURA_DO_PILAR = 0.42
PROFUNDIDADE_DO_PILAR = 0.38
ESPESSURA_DA_BASE = 0.58
PROFUNDIDADE_DA_BASE = 0.56
ALTURA_DA_BASE = 0.22

# sRGB, como o seletor de cor do Blender mostra. A pedra central é o tom quente.
CORES_SRGB = {
    "PedraClara": (201, 192, 180),
    "PedraMedia": (166, 156, 144),
    "PedraEscura": (122, 115, 108),
    "PedraCentral": (198, 163, 106),
}


def srgb_para_linear(canal: float) -> float:
    valor = canal / 255.0
    if valor <= 0.04045:
        return valor / 12.92
    return ((valor + 0.055) / 1.055) ** 2.4


def linear_para_hex(cor_linear) -> str:
    def canal(valor: float) -> int:
        if valor <= 0.0031308:
            srgb = 12.92 * valor
        else:
            srgb = 1.055 * (valor ** (1.0 / 2.4)) - 0.055
        return max(0, min(255, round(srgb * 255)))

    return "#{:02X}{:02X}{:02X}".format(*(canal(c) for c in cor_linear[:3]))


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
    cor = (
        srgb_para_linear(vermelho),
        srgb_para_linear(verde),
        srgb_para_linear(azul),
        1.0,
    )
    principled.inputs["Base Color"].default_value = cor
    principled.inputs["Roughness"].default_value = 0.84
    if "Metallic" in principled.inputs:
        principled.inputs["Metallic"].default_value = 0.0
    for nome_especular in ("Specular IOR Level", "Specular"):
        if nome_especular in principled.inputs:
            principled.inputs[nome_especular].default_value = 0.28
            break
    material["cor_srgb_hex"] = "#{:02X}{:02X}{:02X}".format(vermelho, verde, azul)
    return material


def criar_prisma(nome: str, perfil_yz, meia_espessura: float, material, centro_x: float = 0.0):
    import bmesh

    malha = bpy.data.meshes.new(nome)
    objeto = bpy.data.objects.new(nome, malha)
    bm = bmesh.new()
    negativos = []
    positivos = []
    for y, z in perfil_yz:
        negativos.append(bm.verts.new((centro_x - meia_espessura, y, z)))
        positivos.append(bm.verts.new((centro_x + meia_espessura, y, z)))
    bm.faces.new(list(reversed(negativos)))
    bm.faces.new(positivos)
    total = len(perfil_yz)
    for indice in range(total):
        proximo = (indice + 1) % total
        bm.faces.new(
            (
                negativos[indice],
                negativos[proximo],
                positivos[proximo],
                positivos[indice],
            )
        )
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(malha)
    bm.free()
    malha.materials.append(material)
    for poligono in malha.polygons:
        poligono.use_smooth = False
    bpy.context.scene.collection.objects.link(objeto)
    return objeto


def criar_caixa(nome: str, centro, tamanho, material):
    cx, cy, cz = centro
    sx, sy, sz = tamanho
    perfil = (
        (cy - sy / 2.0, cz - sz / 2.0),
        (cy + sy / 2.0, cz - sz / 2.0),
        (cy + sy / 2.0, cz + sz / 2.0),
        (cy - sy / 2.0, cz + sz / 2.0),
    )
    return criar_prisma(nome, perfil, sx / 2.0, material, cx)


def chanfrar(objeto) -> None:
    modificador = objeto.modifiers.new(name="Chanfro", type="BEVEL")
    modificador.width = CHANFRO_M
    modificador.segments = 1
    if hasattr(modificador, "limit_method"):
        modificador.limit_method = "ANGLE"
    if hasattr(modificador, "angle_limit"):
        modificador.angle_limit = math.radians(40.0)
    elif hasattr(modificador, "angle"):
        modificador.angle = math.radians(40.0)
    if hasattr(modificador, "harden_normals"):
        modificador.harden_normals = True


def ponto_do_arco(lado: int, raio: float, angulo: float):
    # lado +1: metade Y positivo. lado -1: metade Y negativo.
    # O ângulo 0 nasce na imposta e cresce até a pedra central.
    y = -lado * MEIA_ABERTURA + lado * raio * math.cos(angulo)
    z = MOLA_M + raio * math.sin(angulo)
    return (y, z)


def altura_interna(y_blender: float) -> float:
    afastamento = abs(y_blender) + MEIA_ABERTURA
    if afastamento >= RAIO_INTERNO:
        return MOLA_M
    return MOLA_M + math.sqrt(RAIO_INTERNO * RAIO_INTERNO - afastamento * afastamento)


def adicionar_cunhas(materiais) -> None:
    limites = (0.02, 0.24, 0.46, 0.68, 0.90)
    nomes = ("CunhaA", "CunhaB", "CunhaC", "CunhaD")
    tons = (
        materiais["PedraMedia"],
        materiais["PedraEscura"],
        materiais["PedraMedia"],
        materiais["PedraEscura"],
    )
    for lado, sufixo in ((1, "Fundo"), (-1, "Frente")):
        for indice, nome in enumerate(nomes):
            inicio = limites[indice] + FOLGA_DA_CUNHA
            fim = limites[indice + 1] - FOLGA_DA_CUNHA
            perfil = (
                ponto_do_arco(lado, RAIO_INTERNO, inicio),
                ponto_do_arco(lado, RAIO_INTERNO, fim),
                ponto_do_arco(lado, RAIO_EXTERNO, fim),
                ponto_do_arco(lado, RAIO_EXTERNO, inicio),
            )
            pedra = criar_prisma(
                f"{nome}{sufixo}",
                perfil,
                ESPESSURA_DO_ARCO / 2.0,
                tons[indice],
            )
            chanfrar(pedra)


def adicionar_pedra_central(material) -> None:
    # Hexágono que atravessa o encontro das duas metades e desce um pouco
    # abaixo da curva, para a pedra central continuar legível de lado.
    perfil = (
        (0.0, 4.22),
        (0.16, 4.34),
        (0.40, 4.92),
        (0.0, 5.12),
        (-0.40, 4.92),
        (-0.16, 4.34),
    )
    pedra = criar_prisma("PedraCentral", perfil, 0.30, material)
    chanfrar(pedra)


def adicionar_pilares(materiais) -> None:
    centro_y = MEIA_ABERTURA + PROFUNDIDADE_DO_PILAR / 2.0
    cursos = (
        (0.24, 0.906, "PedraClara", "1"),
        (0.926, 1.592, "PedraMedia", "2"),
        (1.612, 2.278, "PedraEscura", "3"),
    )
    for sinal, lado in ((-1.0, "Frente"), (1.0, "Fundo")):
        cy = sinal * centro_y
        base = criar_caixa(
            f"Base{lado}",
            (0.0, cy, ALTURA_DA_BASE / 2.0),
            (ESPESSURA_DA_BASE, PROFUNDIDADE_DA_BASE, ALTURA_DA_BASE),
            materiais["PedraEscura"],
        )
        chanfrar(base)
        for z0, z1, tom, indice in cursos:
            bloco = criar_caixa(
                f"Pilar{lado}{indice}",
                (0.0, cy, (z0 + z1) / 2.0),
                (ESPESSURA_DO_PILAR, PROFUNDIDADE_DO_PILAR, z1 - z0),
                materiais[tom],
            )
            chanfrar(bloco)
        capitel = criar_caixa(
            f"Capitel{lado}",
            (0.0, cy, 2.39),
            (0.50, 0.50, 0.18),
            materiais["PedraMedia"],
        )
        chanfrar(capitel)


def criar_raiz():
    raiz = bpy.data.objects.new("ArcoDePedra", None)
    raiz.empty_display_type = "PLAIN_AXES"
    raiz.empty_display_size = 0.35
    bpy.context.scene.collection.objects.link(raiz)
    return raiz


def adotar(raiz, objeto) -> None:
    objeto.parent = raiz
    objeto.matrix_parent_inverse = Matrix.Identity(4)


def configurar_camera_e_luzes() -> None:
    cena = bpy.context.scene
    camera_dados = bpy.data.cameras.new("CameraTresQuartos")
    camera_dados.lens = 50
    camera_dados.clip_end = 80
    camera = bpy.data.objects.new("CameraTresQuartos", camera_dados)
    camera.location = (10.0, -12.0, 5.6)
    direcao = Vector((0.0, 0.0, 2.45)) - camera.location
    camera.rotation_euler = direcao.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.collection.objects.link(camera)
    cena.camera = camera

    sol_dados = bpy.data.lights.new("Sol", "SUN")
    sol_dados.energy = 4.2
    sol_dados.angle = math.radians(3.0)
    sol = bpy.data.objects.new("Sol", sol_dados)
    sol.rotation_euler = (math.radians(52.0), math.radians(6.0), math.radians(38.0))
    bpy.context.scene.collection.objects.link(sol)

    preenchimento_dados = bpy.data.lights.new("Preenchimento", "SUN")
    preenchimento_dados.energy = 1.5
    preenchimento = bpy.data.objects.new("Preenchimento", preenchimento_dados)
    preenchimento.rotation_euler = (math.radians(68.0), 0.0, math.radians(-145.0))
    bpy.context.scene.collection.objects.link(preenchimento)

    mundo = bpy.data.worlds.new("Fundo")
    cena.world = mundo
    mundo.use_nodes = True
    fundo = mundo.node_tree.nodes.get("Background")
    fundo.inputs["Color"].default_value = (0.045, 0.05, 0.065, 1.0)
    fundo.inputs["Strength"].default_value = 0.55


def enquadrar_ao_abrir() -> None:
    for janela in bpy.context.window_manager.windows:
        for area in janela.screen.areas:
            if area.type != "VIEW_3D":
                continue
            for espaco in area.spaces:
                if espaco.type != "VIEW_3D":
                    continue
                try:
                    espaco.shading.type = "MATERIAL"
                except TypeError:
                    espaco.shading.type = "SOLID"
                espaco.clip_end = 200
                if hasattr(espaco.overlay, "show_object_origins"):
                    espaco.overlay.show_object_origins = True
                espaco.region_3d.view_location = (0.0, 0.0, 2.1)
                espaco.region_3d.view_distance = 8.5
                espaco.region_3d.view_rotation = Vector((0.55, -0.45, 0.15)).to_track_quat(
                    "Z", "Y"
                )


def godot_de_blender(ponto):
    x, y, z = ponto
    return (x, z, -y)


def medir(raiz) -> bool:
    angulo = math.radians(ROTACAO_Y_GRAUS)
    cosseno = math.cos(angulo)
    seno = math.sin(angulo)
    print("MEDIDA abertura_entre_faces_internas_m %.3f" % ABERTURA_INTERNA_M)
    print("MEDIDA mola_m %.3f" % MOLA_M)
    print("MEDIDA raio_interno_m %.3f" % RAIO_INTERNO)
    print("MEDIDA chanfro_m %.3f" % CHANFRO_M)

    menor_altura = 99.0
    ponto_critico = (0.0, 0.0)
    dentro_de_pedra = False
    # O corpo mede 0,80 m em X e 0,50 m em Z. A amostra cobre essa faixa
    # enquanto o centro atravessa a peça já girada.
    for indice_z in range(-5, 6):
        z_mundo = indice_z * 0.05
        for indice_x in range(-28, 29):
            x_mundo = indice_x * 0.05
            x_local = cosseno * x_mundo - seno * z_mundo
            z_godot_local = seno * x_mundo + cosseno * z_mundo
            y_blender = -z_godot_local
            for y_corpo in (0.02, 0.45, 0.90, 1.30, 1.70):
                if _ponto_dentro_de_pilar(x_local, y_blender, y_corpo):
                    dentro_de_pedra = True
                    print(
                        "MEDIDA corpo_invade_pilar x %.3f z %.3f y %.3f"
                        % (x_mundo, z_mundo, y_corpo)
                    )
            if abs(y_blender) >= MEIA_ABERTURA:
                continue
            if abs(x_local) > 0.30:
                continue
            altura = altura_interna(y_blender)
            if abs(y_blender) <= 0.16 and abs(x_local) <= 0.30:
                altura = min(altura, 4.22 + (4.34 - 4.22) * (abs(y_blender) / 0.16))
            if altura < menor_altura:
                menor_altura = altura
                ponto_critico = (x_mundo, z_mundo)

    print("MEDIDA altura_livre_minima_na_faixa_do_corpo_m %.3f" % menor_altura)
    print(
        "MEDIDA ponto_da_altura_livre_x %.3f z %.3f"
        % (ponto_critico[0], ponto_critico[1])
    )
    print("MEDIDA posicao_x_godot %.3f" % POSICAO_X_NO_GODOT)
    print("MEDIDA rotacao_y_graus %.1f" % ROTACAO_Y_GRAUS)
    print(
        "MEDIDA transform_godot Transform3D(%.6f, 0, %.6f, 0, 1, 0, %.6f, 0, %.6f, %.2f, 0, 0)"
        % (cosseno, seno, -seno, cosseno, POSICAO_X_NO_GODOT)
    )
    caixa = _limites_do_arco(raiz)
    print(
        "MEDIDA limites_blender_xyz %.3f %.3f y %.3f %.3f z %.3f %.3f"
        % caixa
    )
    ok = menor_altura >= 2.30 and not dentro_de_pedra and abs(caixa[4]) < 0.001
    print("MEDIDA resultado %s" % ("ok" if ok else "falhou"))
    return ok


def _ponto_dentro_de_pilar(x_local: float, y_blender: float, altura: float) -> bool:
    centro = MEIA_ABERTURA + PROFUNDIDADE_DO_PILAR / 2.0
    caixas = (
        (ESPESSURA_DA_BASE, PROFUNDIDADE_DA_BASE, 0.0, ALTURA_DA_BASE),
        (ESPESSURA_DO_PILAR, PROFUNDIDADE_DO_PILAR, 0.24, 2.278),
        (0.50, 0.50, 2.30, 2.48),
    )
    for sinal in (-1.0, 1.0):
        cy = sinal * centro
        for largura, profundidade, z0, z1 in caixas:
            if abs(x_local) <= largura / 2.0 and abs(y_blender - cy) <= profundidade / 2.0:
                if z0 <= altura <= z1:
                    return True
    return False


def _limites_do_arco(raiz):
    minimo = [999.0, 999.0, 999.0]
    maximo = [-999.0, -999.0, -999.0]
    for objeto in raiz.children_recursive:
        if objeto.type != "MESH":
            continue
        for canto in objeto.bound_box:
            mundo = objeto.matrix_world @ Vector(canto)
            for eixo in range(3):
                minimo[eixo] = min(minimo[eixo], mundo[eixo])
                maximo[eixo] = max(maximo[eixo], mundo[eixo])
    return (
        minimo[0],
        maximo[0],
        minimo[1],
        maximo[1],
        minimo[2],
        maximo[2],
    )


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
    disponiveis = {item.identifier for item in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
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
    cena.render.film_transparent = False
    CAMINHO_IMAGEM.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.render.render(write_still=True)
    print("RENDERIZADO %s" % CAMINHO_IMAGEM)


def main() -> None:
    limpar_cena()
    preparar_unidades()
    materiais = {nome: novo_material(nome) for nome in CORES_SRGB}
    for nome, material in materiais.items():
        print("COR %s %s" % (nome, material["cor_srgb_hex"]))
    raiz = criar_raiz()
    adicionar_pilares(materiais)
    adicionar_cunhas(materiais)
    adicionar_pedra_central(materiais["PedraCentral"])
    for objeto in list(bpy.context.scene.objects):
        if objeto is not raiz and objeto.type == "MESH":
            adotar(raiz, objeto)
    configurar_camera_e_luzes()
    try:
        enquadrar_ao_abrir()
    except Exception as erro:
        print("AVISO enquadramento %s" % erro)
    medidas_ok = medir(raiz)
    bpy.ops.wm.save_as_mainfile(filepath=str(CAMINHO_BLEND))
    print("SALVO %s" % CAMINHO_BLEND)
    renderizar()
    exportar_glb(raiz)
    if not medidas_ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
