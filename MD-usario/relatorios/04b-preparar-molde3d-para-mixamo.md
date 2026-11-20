# 04-B — Preparar um molde para o Mixamo

Data: 20/11/2026. Blender 5.3.0. A cena jogável da Tarefa 04 permanece com o manequim.

O OBJ foi reimportado e validado no Blender. O auto-rig no Mixamo continua pendente: ele depende do upload na conta do Adobe e ainda não foi feito. O Godot não entrou nesta etapa.

## Modelos em molde3d

A pasta é `D:\Progr\catlenight\molde3d`. Não há subpastas. Os quatro arquivos formam dois personagens, os dois numa malha única, sem armature e sem animação.

| Arquivo | Tamanho | Triângulos | O que é |
| --- | --- | --- | --- |
| `white_mesh.glb` | 8,32 MB | 484908 | Humanoide de casaco, capa e espada. Uma única ilha: arma, capa e corpo estão fundidos |
| `white_mesh.fbx` | 16,77 MB | 484908 | A mesma malha do GLB acima |
| `white_mesh.obj` | 191,30 MB | 484908 | A mesma malha, exportada em milímetros |
| `white_mesh (1).glb` | 2,85 MB | 165900 | O mesmo tipo de figura, sem espada, sem capa e sem casaco. Uma ilha, corpo completo |

A variante com espada foi inspecionada de frente, de lado e em três quartos (`04b-candidato-a-frente_y.png` e as vistas ao lado). A espada sai da mão e a capa liga os braços ao tronco. Como isso está fundido na mesma casca, cortar agora abriria a malha. A variante limpa já existe, então ela foi a escolhida.

## Arquivo escolhido

`D:\Progr\catlenight\molde3d\white_mesh (1).glb`

- Pose original: em pé, rosto para −Y do Blender, braços ao lado do corpo, pernas afastadas. A folga medida era de cerca de 2 cm entre mão e coxa e 3 cm na axila.
- Peças: um objeto de malha, filho de um vazio chamado `world`. O nome interno da malha é o temporário do Hunyuan, `tmp20kju4ip.ply`. Não há espada, bainha, base de exposição nem cenário. O cabelo longo fica atrás das costas e não fecha o vão das pernas.
- Armature: nenhuma. Animação: nenhuma.
- UVs: nenhuma. Materiais: nenhum. A cópia editável conserva esse estado.
- Triângulos da geometria avaliada, antes de qualquer redução: 165900.

A captura de origem está em `MD-usario/relatorios/evidencias/04b-candidato-b-frente_y.png`.

## O que foi preparado

Arquivo de trabalho: `D:\Progr\catlenight\arte-fonte\blender\protagonista_mixamo_preparado.blend`

- Coleção `PecasEditaveis`: a importação original, sem mudança de pose nem de escala.
- Coleção `CopiaExportacao`: o objeto `ProtagonistaUpload`.

Na cópia, só os vértices ligados à mão e ao braço foram girados cerca de 22° para fora, com transição no ombro. Tronco, calça, botas e cabelo ficaram no lugar. Não havia modificador nem armature para aplicar. A altura foi levada a 1,70 m (fator 0,8687), com as solas no Z = 0. O rosto foi virado para o +Z do OBJ, que é a frente que o Mixamo costuma esperar num arquivo com Y para cima.

A união não teve o que agrupar: a cópia já era um objeto. Nenhum vértice de dedos, braços ou pernas foi soldado por distância.

A malha estava acima da faixa de 30 a 60 mil triângulos. A redução foi em dois passos, por colapso de arestas: 165900, depois 100000, depois 52000. Queixo, pulsos, cotovelos, joelhos e botas continuam legíveis. Os dedos ficaram mais simples, e o polegar continua separado da palma.

Medidas da cópia já em 1,70 m, depois da redução:

| Medida | Valor |
| --- | --- |
| Triângulos | 52000 |
| Largura, profundidade, altura no Blender | 0,9600 × 0,4819 × 1,6999 m |
| Sola | Z = 0,0001 |
| Topo da cabeça | Z = 1,7000 |
| Folga da axila | cerca de 4,2 cm de cada lado |
| Mão e coxa | a mão mais baixa fica a 4,3 cm da coxa; a outra sobe o bastante para o vão aparecer na captura |

## OBJ reimportado e validado no Blender

Arquivo exportado e reaberto numa cena vazia:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_mixamo_upload.obj`

| Conferência | Resultado |
| --- | --- |
| Objetos de malha | 1, de nome `ProtagonistaUpload` |
| Triângulos | 52000 |
| Tamanho em disco | 3,95 MB (4138548 bytes) |
| Eixos dentro do OBJ | X largura 0,9600 m, Y altura 1,6999 m, Z profundidade 0,4819 m. O nariz aponta para +Z |
| Depois que o Blender reimporta e volta o arquivo para Z para cima | sola em 0,0001 m, topo em 1,7000 m |
| Espada | ausente |
| Mãos, pernas e botas | no lugar, com vão entre os braços e o tronco e entre as coxas |

Captura frontal do OBJ reimportado: `MD-usario/relatorios/evidencias/04b-modelo-para-mixamo.png`.

O perfil da mesma reimportação está em `04b-modelo-para-mixamo-perfil.png`. A aproximação das mãos e dos joelhos está em `04b-maos.png`.

## Auto-rig no Mixamo

Este passo é manual. O auto-rig ainda não foi confirmado.

1. Em [mixamo.com](https://www.mixamo.com), abra Upload Character e selecione:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_mixamo_upload.obj`

2. Se a prévia entrar deitada ou de costas, use o controle de rotação da página até a figura ficar em pé e o rosto virar para você. A captura frontal do projeto é a referência dos marcadores.

Na captura `04b-modelo-para-mixamo.png`, de cima para baixo:

- **Queixo.** No centro do rosto, na dobra logo abaixo da boca e acima do colarinho. O cabelo desce dos dois lados; o ponto fica na pele do queixo, entre as mechas.
- **Pulsos.** Na boca de cada manga, onde a mão começa. Na captura, a mão da esquerda está um pouco mais baixa, na altura do quadril. A mão da direita fica um pouco mais alta. O marcador é a linha estreita entre o punho da manga e a palma, não o meio da mão.
- **Cotovelos.** No meio de cada manga, na altura do cinto, onde o braço sai do tronco e segue até a mão. A manga é folgada. A articulação está no centro do volume da manga, por baixo do tecido, e não na borda externa da roupa.
- **Joelhos.** No volume redondo da calça, logo acima da boca da bota. A bota cobre a canela; a articulação fica no centro desse volume, um pouco para dentro da silhueta. É ali que a perna dobra para a frente, do lado do rosto.
- **Virilha.** No centro do corpo, no ponto em que as duas pernas se separam, abaixo do cinto e no topo do vão entre as coxas.

3. Na prévia do auto-rig, observe três movimentos:

- Os braços sobem e o tronco permanece parado.
- Os joelhos dobram para a frente.
- As botas acompanham os pés.

Se a manga puxar o peito, o cotovelo está na roupa: traga o marcador para o centro da manga. Se a bota ficar para trás do pé, o joelho está baixo demais: suba o marcador para o volume redondo acima da bota.

4. Se essa prévia funcionar, escolha uma corrida. Quando existir a opção In Place, deixe-a marcada, para o ciclo não andar para a frente. Baixe o primeiro FBX com With Skin e salve em:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_hunyuan_corrida.fbx`

A cena `scenes/verification/main.tscn` e o jogador `scenes/player/jogador.tscn` não foram alterados. O manequim continua sendo o personagem que anda e pula.
