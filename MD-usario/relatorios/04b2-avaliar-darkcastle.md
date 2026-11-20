# 04-B2 — Comparar o darkcastle com a captura escolhida

Data: 20/11/2026. Blender 5.3.0. O OBJ da Tarefa 04-B foi preservado. A cena jogável continua com o manequim.

## Os três arquivos

A captura `04b-candidato-a-tres_quartos.png` foi gerada por `D:\Tools\Hunyuan3D\renderizar_moldes.py`. Nesse script, a marca `a` é `molde3d\white_mesh.glb`. A malha da imagem está confirmada.

| Papel | Arquivo | Triângulos | O que mostra |
| --- | --- | --- | --- |
| Referência visual | `molde3d\white_mesh.glb` (8,32 MB) | 484908 | Casaco, capa, espada e cabelo longo. É a figura da captura |
| Molde novo | `molde3d\darkcastle.obj` (15,9 MB) | 418482 | O mesmo tipo de figura, noutra geração |
| Upload já preparado | `arte-fonte\mixamo\protagonista_mixamo_upload.obj` (3,95 MB) | 52000 | Outra malha, vinda de `white_mesh (1).glb`, sem casaco e sem espada |

Não há `.mtl` nem textura ao lado de `darkcastle.obj`. O arquivo traz só vértices e faces. Não há UVs nem material.

## Inspeção do darkcastle.obj

Uma malha, 209173 vértices, 418482 triângulos, uma única ilha. No Blender o eixo alto é Z. A caixa original mede 1,187 × 1,287 × 1,992 m. O rosto aponta para −Y. Não há armature nem animação.

As partes que parecem encostar foram medidas na geometria:

| Junção | O que a malha faz |
| --- | --- |
| Cabelo e ombros | O cabelo sai da cabeça. A ponta fica a cerca de 2,2 cm do casaco, já na escala de 1,70 m. Não é uma segunda peça pousada no ombro |
| Mangas e tronco | O casaco fecha a maior parte da axila. De um lado quase não há manga livre; do outro, o vão medido fica em cerca de 5 cm, num trecho pequeno |
| Mãos e coxas | As duas mãos ficam a cerca de 3 mm da perna. Estão na mesma casca |
| Espada e mão | A lâmina faz parte da mesma superfície da mão. Uma caminhada a partir da ponta percorre a espada e continua no corpo |
| Botas e calça | O cano da bota é a continuação da perna. Não há uma bota separada por cima da calça |

A espada, a capa e o casaco estão fundidos no corpo. Abrir os braços ou cortar a espada rasgaria o casaco. A cópia de upload conservou essa aparência. O encontro da mão com a espada e com a aba do casaco está em `MD-usario/relatorios/evidencias/04b2-fusao-mao-espada.png`.

## Comparação

Os três foram colocados a 1,70 m, com os pés no mesmo piso, o mesmo cinza e a mesma luz. A prancha está em `MD-usario/relatorios/evidencias/04b2-comparacao-personagens.png`.

A primeira coluna é a malha da captura. A terceira coluna avisa que o OBJ já preparado é outra malha. A faixa de baixo mostra o perfil com 153 px de altura, que é o tamanho do personagem na câmera do jogo com Size = 8 e janela de 720 px.

## Cópia do darkcastle para um segundo teste

Arquivo editável: `arte-fonte/blender/darkcastle_mixamo_preparado.blend`

- Coleção `Original`: o OBJ importado, sem escala nova.
- Coleção `Exportacao`: `DarkcastleUpload`, a 1,70 m, solas no piso.

A redução foi conferida em 100 mil e em 52 mil triângulos. Nas duas, o rosto, o cabelo, as mangas, a espada, a capa e as botas continuam legíveis. Ficou em 52 mil, o mesmo orçamento do outro upload.

OBJ reimportado numa cena vazia:

`D:\Progr\catlenight\arte-fonte\mixamo\darkcastle_mixamo_upload.obj`

| Conferência | Resultado |
| --- | --- |
| Objetos | 1 |
| Triângulos | 52000 |
| Tamanho | 3,95 MB (4138689 bytes) |
| No Blender, depois da reimportação | sola em Z = −0,0001, topo em Z = 1,7001 |
| No arquivo | Y é a altura; o rosto e a espada apontam para +Z |
| Pose | em pé, com a espada na mão e a capa no lugar |

A vista do OBJ reimportado está em `04b2-darkcastle-upload.png`.

## Respostas

O candidato mais próximo da captura em três quartos, e com a mesma silhueta de lado, é `darkcastle.obj`. O casaco, a capa, a espada e o cabelo repetem `white_mesh.glb`. O perfil do casaco é o desenho largo dessa imagem. `protagonista_mixamo_upload.obj` é o corpo sem esse casaco.

O OBJ para enviar primeiro ao Mixamo é o que já estava preparado. Os braços estão afastados, as mãos ficam a cerca de 4 cm das coxas e não há espada nem capa ligadas aos membros. O darkcastle está em pé e com os pés visíveis, mas as mãos encostam nas pernas e a espada faz parte da mão. Esse arquivo fica guardado para um segundo teste, se o primeiro rig funcionar e você quiser o casaco.

Arquivo do primeiro upload:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_mixamo_upload.obj`

O auto-rig continua pendente até o teste na sua conta do Mixamo. O manequim da Tarefa 04 segue na cena jogável.
