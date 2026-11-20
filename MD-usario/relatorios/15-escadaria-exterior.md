# 15 — Escadaria exterior de acesso ao castelo

Data: 20/11/2026. Godot 4.7.2 e Blender 5.3.0. A cena para o F6 é `scenes/verification/15_escadaria_exterior.tscn`. O F6 do editor não foi pressionado. A janela abriu por script, em `tests/capturar_15.tscn`. O percurso rodou em `tests/verificar_escadaria_15.gd`, com `APPDATA` em `tests/dados_15`. O F5 continua em `scenes/verification/main.tscn`. A cena 14 continua sem a saída da esquerda.

## Onde a passagem cabe

O piso do vestíbulo vai de X = −6 a X = 6, com o topo em Y = 0. A sacada ocupa X de −5,75 a −3,55 e o topo em Y = 2,350. Embaixo dela o corpo de 1,70 m passa. A cantaria fica em Z = −2,25 e não tem colisão. Não havia volume bloqueando a borda esquerda do piso.

A saída nova, só na cena 15, é `Vestibulo/SaidaEsquerda`, em (−5,65, 1,10, 0), com volume 0,80 × 2,40 × 1,40. A chegada de volta ao castelo é `Vestibulo/ChegadaDaEscadaria`, em (−4,20, 0, 0), à direita desse volume. A porta da sacada, `Vestibulo/VaoDaCapela/Passagem`, continua levando à Capela da Lua.

## O lance

O editável é `arte-fonte/blender/escadaria_exterior.blend`, gerado por `arte-fonte/blender/criar_escadaria_exterior.py`. A origem do eixo `LanceDeEscada` é o pé do primeiro espelho. São 12 degraus. Cada espelho tem 0,220 m e cada piso 0,460 m.

- Desnível total: 2,640 m.
- Comprimento horizontal: 5,520 m.
- Inclinação: 25,56°.

No Blender, X corre a subida, Z é a altura e o perfil da câmera fica em Y positivo, que o glTF leva para Z negativo no Godot. A mureta de cada degrau fica desse lado, atrás das pernas.

O exportador grava só o lance em `assets/models/environment/exterior/lance_de_escada.glb`. A importação veio antes da medida final. A caixa local tem X de 0 a 5,520, Y de 0 a 3,200 e Z de −0,390 a −0,020. São 36 malhas e nenhum corpo físico. A face voltada para a câmera para em Z = −0,020, então as pernas em Z = 0 ficam na frente.

## Quem desenha e quem sustenta

A malha dos degraus é `EscadariaExterior/Lance/Degraus`. Esse nó instancia o GLB. Os blocos visíveis se chamam `Degrau_0` a `Degrau_11`. As juntas são `Junta_*` e a mureta é `Mureta_*`. O nó está 0,180 m acima da origem do lance, para o piso visível encontrar a bota.

A forma que sustenta o personagem é `EscadariaExterior/Lance/Rampa/Colisao`, um `BoxShape3D` de 6,119 × 0,400 × 2,400 m. A face de cima liga (0, 0) a (5,520, 2,640): é a mesma reta das quinas e encontra os dois patamares sem degrau. Os patamares são `PatamarInferior/Colisao` e `PatamarSuperior/Colisao`. A caixa do corpo tem 0,80 m de largura e o fundo horizontal. Na subida, o canto de baixo encosta na rampa e a origem dos pés fica cerca de 0,190 m acima dessa face. O deslocamento de 0,180 m da malha aproxima o piso visível dessa sola.

A passagem para o vestíbulo é `EscadariaExterior/Saida`. O destino é `Vestibulo` e a chegada é `Vestibulo/ChegadaDaEscadaria`. A volta usa `Vestibulo/SaidaEsquerda` e chega em `EscadariaExterior/Chegada`, no patamar de cima, em (6,350, 2,640, 0) local. A sala inteira está em X = −22, então esse marco fica em X = −15,650 no mundo.

## O que aparece na tela

O nascimento está em `MD-usario/relatorios/evidencias/15-primeira-vista-do-castelo.png`. Os pés ficam em X = −23,200, Y = 0,000 e Z = 0, com o perfil para +X. A câmera está em X = −18,80 e Y = 2,85, `Size` = 8, quadro 1280×720. Dá para achar o portão de imediato: é o vão amarelo no alto, à direita, sobre a cantaria. A linha dos degraus liga o patamar a esse vão. A lua e as silhuetas ficam atrás do plano de jogo.

A subida está em `15-subida-ao-portao.png`. Os pés pararam em X = −20,060, Y = 1,120 e Z = 0. A sola aparece apoiada na quina do degrau, com a perna inteira na frente da mureta. O que ainda lê como bloco: a emenda do patamar de cima com a parede, à esquerda do vão, e as silhuetas distantes, que são caixas escuras no canto.

## O percurso

“Novo jogo” deixa “Vida 3/3” e o mapa só com `escadaria_exterior`. Segurar a direita sobe. Soltar no meio mantém o corpo parado. Segurar de novo entra no vestíbulo numa única troca: pés em X = −4,142, Y = 0 e Z = 0, câmera em X = 0. O mapa então mostra a escadaria, o vestíbulo e a ligação `escadaria_exterior-vestibulo`. A esquerda volta numa única troca, com a câmera em X = −18,80 e os pés em Y = 2,640. A descida segue até Y = 0,400, ainda sobre a rampa.

“Continuar” restaura o altar: pés em X = 47,950 e Y = 0, vida 3/3, salto duplo e as salas `vestibulo`, `galeria` e `capela_da_lua`. O exterior não entra nessa gravação. Sair da capela, descer da sacada e atravessar `Vestibulo/SaidaEsquerda` acrescenta `escadaria_exterior` e a ligação nova, sem apagar as três salas.

As fases `primeira`, `continuar`, `novo_mapa` e `legado` de `tests/verificar_mapa_12.gd` deram `RESULTADO ok`, assim como `verificar_portal_14.gd`, `verificar_capela_10.gd` e `verificar_vestibulo_13.gd`.

## Exercício de cinco minutos

Abra `scenes/verification/15_escadaria_exterior.tscn`. No menu **Depurar**, ligue **Formas de colisão visíveis**. Selecione `EscadariaExterior/Lance/Rampa/Colisao`. Rode a cena com F6, suba com a seta direita e solte no meio.

Na subida, a linha da rampa acompanha as quinas de `Lance/Degraus` e entrega os pés a `PatamarSuperior/Colisao` sem um lábio. Na descida, a mesma linha leva os pés até `PatamarInferior/Colisao`. A malha visível fica 0,180 m acima dessa linha: a sola encontra o piso desenhado, e a linha de depuração fica logo abaixo dele.
