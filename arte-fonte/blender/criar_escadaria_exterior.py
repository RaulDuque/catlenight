# Gera o lance da escadaria exterior.
#
# Reproduzir:
#   C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_escadaria_exterior.py
#
# A origem é o início da subida: o pé do primeiro espelho, no piso do patamar.
# 12 degraus. Espelho 0,22 m. Piso 0,46 m. Desnível 2,64 m. Comprimento 5,52 m.
# X corre a subida, Z é a altura. O perfil voltado para a câmera fica em Y negativo.

import math
from pathlib import Path

import bpy
from mathutils import Vector


RAIZ = Path(__file__).resolve().parents[2]
PASTA_BLEND = RAIZ / "arte-fonte" / "blender"
PASTA_GLB = RAIZ / "assets" / "models" / "environment" / "exterior"
CAMINHO_BLEND = PASTA_BLEND / "escadaria_exterior.blend"
CAMINHO_GLB = PASTA_GLB / "lance_de_escada.glb"

DEGRAUS = 12
ESPELHO = 0.22
PISO = 0.46

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
    for colecao in (bpy.data.meshes, bpy.data.materials):
        for bloco in list(colecao):
            if bloco.users == 0:
                colecao.remove(bloco)


def preparar_unidades() -> None:
    cena = bpy.context.scene
    cena.unit_settings.system = "METRIC"
    cena.unit_settings.scale_length = 1.0
    cena.unit_settings.length_unit = "METERS"


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
    principled.inputs["Roughness"].default_value = 0.9
    return material


def novo_eixo(nome: str):
    eixo = bpy.data.objects.new(nome, None)
    bpy.context.scene.collection.objects.link(eixo)
    eixo.empty_display_type = "PLAIN_AXES"
    eixo.empty_display_size = 0.4
    return eixo


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
    bpy.context.scene.collection.objects.link(objeto)
    objeto.parent = pai
    return objeto


def adicionar_lance(materiais, pai) -> None:
    tons = ("PedraClara", "PedraMedia", "PedraEscura")
    for indice in range(DEGRAUS):
        x0 = indice * PISO
        x1 = x0 + PISO
        z1 = (indice + 1) * ESPELHO
        tom = materiais[tons[indice % 3]]
        criar_caixa(
            "Junta_%d" % indice,
            ((x0 + x1) * 0.5, 0.18, z1 * 0.5),
            (PISO, 0.32, z1),
            materiais["Argamassa"],
            pai,
        )
        criar_caixa(
            "Degrau_%d" % indice,
            ((x0 + 0.03 + x1 - 0.02) * 0.5, 0.20, (0.02 + z1 - 0.02) * 0.5),
            (PISO - 0.05, 0.36, z1 - 0.04),
            tom,
            pai,
        )
        criar_caixa(
            "Mureta_%d" % indice,
            ((x0 + x1) * 0.5, 0.28, z1 + 0.28),
            (PISO - 0.04, 0.22, 0.56),
            materiais["PedraEscura"] if indice % 2 else materiais["PedraMedia"],
            pai,
        )


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


def main() -> None:
    limpar_cena()
    preparar_unidades()
    desnivel = DEGRAUS * ESPELHO
    comprimento = DEGRAUS * PISO
    print("MEDIDA degraus=%d espelho=%.3f piso=%.3f desnivel=%.3f comprimento=%.3f" % (
        DEGRAUS, ESPELHO, PISO, desnivel, comprimento,
    ))
    print("MEDIDA inclinacao_graus=%.2f" % math.degrees(math.atan(desnivel / comprimento)))
    materiais = {nome: novo_material(nome) for nome in CORES_SRGB}
    lance = novo_eixo("LanceDeEscada")
    adicionar_lance(materiais, lance)
    bpy.context.view_layer.update()
    exportar(lance)
    PASTA_BLEND.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(CAMINHO_BLEND))
    print("SALVO %s" % CAMINHO_BLEND)


if __name__ == "__main__":
    main()
