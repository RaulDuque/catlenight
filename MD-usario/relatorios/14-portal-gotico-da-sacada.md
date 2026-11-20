# 14 — Portal gótico da sacada

Data: 20/11/2026. Godot 4.7.2 e Blender 5.3.0. A cena de entrada é `scenes/verification/14_portal_da_sacada.tscn`. O F6 do editor não foi pressionado. A janela da prancha abriu por `tests/capturar_14.tscn`. O percurso rodou em `tests/verificar_portal_14.gd`. O F5 continua em `scenes/verification/main.tscn`. A cena 13 continua com a moldura retangular.

## O que já existia

A moldura retangular está em `scenes/environment/vao_da_capela.tscn`: `Vao`, `OmbreiraEsquerda`, `OmbreiraDireita` e `Lintel`. A parede lisa é `Vestibulo/Sacada/Parede`. A luz quente é `Vestibulo/LuzDaPorta`. Os pés se apoiam em `Vestibulo/Sacada/Laje/Colisao`. O detector é `Vestibulo/VaoDaCapela/Passagem`. A volta da capela usa o marcador `Vestibulo/ChegadaDaSacada`.

Medido na cena 14, antes de modelar:

- Parede lisa: 2,400 m de largura, de X = −5,85 a −3,45 e de Y = 2,200 a 4,800. A face voltada para a câmera está em Z = −0,840.
- Vão livre entre as ombreiras: 1,040 m.
- Vão luminoso: 1,900 m acima do topo da laje. O topo continua em Y = 2,350.
- Profundidade dos pés, em Z = 0, até essa face: 0,840 m.
- Passagem em (−4,55, 3,15, 0). Chegada em (−4,55, 2,42, 0). Luz em (−4,55, 3,55, −0,35).

O portal usa esse vão e fica abaixo da cornija da cantaria. Na soleira o vão livre passou a 1,120 m. Na altura de 1,70 m ele ainda tem 1,033 m. A ponta da malha fica 2,543 m acima da soleira.

## Da pedra no Blender até o nó

O editável é `arte-fonte/blender/portal_da_sacada.blend`, gerado por `arte-fonte/blender/criar_portal_da_sacada.py`. A origem do eixo `PortalDaSacada` é o centro da soleira, na altura dos pés. No Blender, Z sobe e o relevo avança para Y negativo.

A pedra do alto se chama `PedraCentral`. As ombreiras são `OmbreiraBase`, `OmbreiraFuste` e `OmbreiraCapitel`, de cada lado. As curvas são `AduelaInferior` e `AduelaSuperior`, também dos dois lados. O brilho do vão é a malha `Vao`, no mesmo arquivo, para a ponta não ficar escura por dentro.

O exportador grava só o portal em `assets/models/environment/vestibulo/portal_da_sacada.glb`. A cena reutilizável é `scenes/environment/portal_da_sacada.tscn`. No piloto, o nó é `Vestibulo/PortalDaSacada`, dentro de `scenes/verification/14_portal_da_sacada.tscn`. A posição é X = −4,55, Y = 2,35, Z = −0,84. Z = −0,84 encosta a face de referência na antiga face da parede. O relevo aponta para a câmera.

Depois da importação, a caixa local mede X de −0,860 a 0,860, Y de 0 a 2,543 e Z de −0,140 a 0,220. São 16 malhas e nenhum corpo físico. A `Vao` chegou com emissão ligada, força 3,20.

## O que a prancha mostra

A comparação está em `MD-usario/relatorios/evidencias/14-portal-antes-depois.png`. Em cima, a porta vista do chão. Embaixo, o protagonista na soleira. A esquerda é a cena 13 e a direita é a cena 14. Os dois de cima usam pés em X = −0,5241, Y = 0,0009 e Z = 0, rotação Y = 0. Os dois de baixo usam X = −4,175, Y = 2,350 e Z = 0, rotação Y = π. Câmera em X = 0, `Size` = 8, 1280×720.

A ponta da ogiva se separa da cantaria: o brilho sobe em triângulo e a pedra clara fecha o alto. Na soleira, a cabeça e o tronco ficam dentro do vão, com claro acima da cabeça, e o texto “↑ Entrar na capela” continua legível. A parede lisa some. No lugar dela aparece a mesma cantaria do resto do vestíbulo. Não ficou uma emenda retangular de outro tom.

O que ainda se vê e pode melhorar: as aduelas são poucas e leem como blocos, não como um talhe fino. A sombra do arco de pedra na parede continua dura. O portal da própria capela, do outro lado da passagem, segue retangular.

A conferência no Blender, com a referência de 1,70 m e a câmera na escala do jogo, está em `14-portal-no-blender.png`.

## O percurso

`verificar_portal_14.gd` carregou a cena 14, com `APPDATA` em `tests/dados_14`. Nasceu no vestíbulo, atravessou o arco, coletou a relíquia, voltou e pousou na sacada com o salto duplo. Antes de entrar, os pés estavam em X = −4,175 e Y = 2,350, com “↑ Entrar na capela”. Um toque novo em ↑ levou à capela, em X = 45,800 e Y = 0. Depois de se afastar e voltar à saída, outro toque devolveu os pés à sacada, em X = −4,608 e Y = 2,350.

A janela não foi o F6. As quatro vistas da prancha abriram por `tests/capturar_14.tscn`. O percurso acima rodou sem janela, com as mesmas ações do mapa de entrada.

`verificar_vestibulo_13.gd` e `verificar_capela_10.gd` também deram `RESULTADO ok`. A laje, o detector e a chegada não foram movidos.

## Exercício de cinco minutos

Abra `arte-fonte/blender/portal_da_sacada.blend`.

1. No Outliner, selecione `PedraCentral`. No painel de propriedades, em Object, Transform, Location está em X = `0.0061`, Y = `-0.1000` e Z = `2.2905`. Z é o eixo vertical.
2. Com a pedra selecionada, aperte G, depois Z, digite `0.1` e confirme com Enter. Ela sobe 10 cm. As juntas com `AduelaSuperiorEsquerda` e `AduelaSuperiorDireita` abrem.
3. Antes de salvar, aperte Ctrl+Z. A pedra volta para Z = `2.2905` e as juntas fecham. Se o Ctrl+Z já não estiver disponível, devolva o Z para `2.2905` à mão e não grave por cima.

A referência `Referencia170` fica no vão só para comparar a altura. Ela não entra no GLB.
