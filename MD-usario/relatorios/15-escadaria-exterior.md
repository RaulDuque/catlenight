# 15 — Escadaria exterior de acesso ao castelo

Data: 20/11/2026. Godot 4.7.2 e Blender 5.3.0. A cena para o F6 é `scenes/verification/15_escadaria_exterior.tscn`. O F6 do editor não foi pressionado. A janela abriu por script, em `tests/capturar_15.tscn`. O percurso rodou em `tests/verificar_escadaria_15.gd`, com `APPDATA` em `tests/dados_15`. O F5 continua em `scenes/verification/main.tscn`. A cena 14 continua sem a saída da esquerda.

A atualização 15-B inverteu o sentido da subida a partir da prancha “Final Stage: Bloodlines”. O prompt está em `MD-usario/prompts/15b-referencia-do-prologo.md`.

## Referência

A prancha de consulta é `assets-exemple-2d/Final Stage - _Bloodlines_.png`. O mapa é de Revned, em [Revned’s Video Game Maps](https://revned77.github.io/games/SymphonyOfTheNight.html). Ela serviu para a disposição dos espaços. O vídeo da abertura não estava disponível: a imagem do disco continua ausente, como ficou registrado na etapa 15-A. As duas capturas abaixo são do Catlenight, não da prancha.

A faixa de baixo pede a sequência exterior, patamar, salão e trono. Nesta entrega entram a escadaria e a passagem para o vestíbulo já existente. O salão do trono, o espaço superior alongado e o espaço superior em degraus ficam anotados em `docs/GAME_DESIGN.md`. A prancha não define como se entra neles.

## Onde a passagem cabe

O piso do vestíbulo vai de X = −6 a X = 6, com o topo em Y = 0. A sacada ocupa X de −5,75 a −3,55 e o topo em Y = 2,350. A cena 15 acrescenta `Vestibulo/PisoDaEntrada`, de X = −9,80 a X = −5,90, no mesmo topo. Esse trecho só existe nesta cena. O vestíbulo da cena 14 não muda.

A saída, só na cena 15, é `Vestibulo/SaidaEsquerda`, em (−5,35, 1,10, 0), com volume 0,80 × 2,40 × 1,40. A chegada vinda da escadaria é `Vestibulo/ChegadaDaEscadaria`, em (−7,40, 0, 0), à esquerda desse volume e sobre o piso novo. Segurar a seta esquerda depois de entrar afasta o corpo do gatilho. A volta é a seta direita, de encontro a esse volume. A porta da sacada continua levando à Capela da Lua.

## O lance

O editável é `arte-fonte/blender/escadaria_exterior.blend`, gerado por `arte-fonte/blender/criar_escadaria_exterior.py`. A origem do eixo `LanceDeEscada` é o pé do primeiro espelho. São 12 degraus. Cada espelho tem 0,220 m e cada piso 0,460 m.

- Desnível total: 2,640 m.
- Comprimento horizontal: 5,520 m.
- Inclinação: 25,56°.

No Blender, X corre a subida do molde, Z é a altura e o perfil da câmera fica em Y positivo, que o glTF leva para Z negativo no Godot. A mureta de cada degrau fica desse lado, atrás das pernas.

O exportador grava só o lance em `assets/models/environment/exterior/lance_de_escada.glb`. A caixa local do GLB tem X de 0 a 5,520, Y de 0 a 3,200 e Z de −0,390 a −0,020. São 36 malhas e nenhum corpo físico. Na cena, `EscadariaExterior/Lance/Degraus` usa escala X = −1 e fica 0,180 m acima da origem, então a subida visível corre para −X e a face da câmera continua atrás das pernas.

## Quem desenha e quem sustenta

A malha dos degraus é `EscadariaExterior/Lance/Degraus`. Os blocos visíveis se chamam `Degrau_0` a `Degrau_11`. As juntas são `Junta_*` e a mureta é `Mureta_*`.

A forma que sustenta o personagem é `EscadariaExterior/Lance/Rampa/Colisao`, um `BoxShape3D` de 6,119 × 0,400 × 2,400 m. A face de cima liga (0, 0) a (−5,520, 2,640), no espaço da sala. Os patamares são `PatamarInferior/Colisao`, à direita, e `PatamarSuperior/Colisao`, à esquerda. A caixa do corpo tem 0,80 m de largura. Na subida, a origem dos pés fica cerca de 0,190 m acima da face da rampa. O deslocamento de 0,180 m da malha aproxima o piso visível dessa sola.

A passagem para o vestíbulo é `EscadariaExterior/Saida`, em X local = −7,55. O destino é `Vestibulo` e a chegada é `Vestibulo/ChegadaDaEscadaria`. A propriedade `sentido_x` vale −1: o volume só troca de sala quando o corpo anda para −X. Andar para a direita, na descida, atravessa o mesmo vão sem voltar ao vestíbulo. A volta chega em `EscadariaExterior/Chegada`, no patamar de cima, em (−9,050, 2,640, 0) local. A sala está em X = −22.

O portão iluminado fica nesse patamar. A torre é `TorreDistante`, atrás do plano de jogo e à esquerda do vão. A lua é `Lua`, no céu à direita.

## O que aparece na tela

As duas imagens são capturas do Catlenight, em 1280×720. A referência de Revned não foi colada nelas.

O nascimento está em `MD-usario/relatorios/evidencias/15-primeira-vista-do-castelo.png`. Os pés ficam em X = −20,800, Y = 0,000 e Z = 0, com o perfil para −X. A câmera está em X = −26,20 e Y = 2,85, `Size` = 8. O corpo está no patamar inferior direito. A diagonal dos degraus sobe para a esquerda, o vão amarelo marca a entrada e a torre fica atrás dele. A lua está no céu, à direita. A mureta não cobre as botas.

A subida está em `15-subida-ao-portao.png`. Os pés pararam em X = −24,225, Y = 1,256 e Z = 0, depois de soltar a seta esquerda. A sola aparece na quina do degrau, com a perna na frente da mureta. O fim da escada, já no patamar superior, ficou em X = −27,470 e Y = 2,640.

O que ainda lê como bloco: a torre é uma caixa escura com uma cobertura larga, e a lua é um disco, não o crescente da prancha.

## O percurso

“Novo jogo” deixa “Vida 3/3” e o mapa só com `escadaria_exterior`. Segurar a esquerda sobe. Soltar no meio mantém o corpo parado, em X = −24,225 e Y = 1,256. Segurar de novo entra no vestíbulo numa única troca: pés em X = −7,458, Y = 0 e Z = 0, câmera em X = 0. O mapa então mostra a escadaria, o vestíbulo e a ligação `escadaria_exterior-vestibulo`.

A direita volta numa única troca. Os pés chegam em X = −30,992 e Y = 2,640, no patamar superior, com a câmera em X = −26,20. A mesma seta desce até o patamar de baixo, em X = −21,573 e Y = 0. Z permanece 0.

“Continuar” restaura o altar: pés em X = 47,950 e Y = 0, vida 3/3, salto duplo e as salas `vestibulo`, `galeria` e `capela_da_lua`. Sair da capela, descer da sacada e atravessar `Vestibulo/SaidaEsquerda` acrescenta `escadaria_exterior` e as ligações `escadaria_exterior-vestibulo`, `vestibulo-galeria` e `vestibulo-capela_da_lua`, sem apagar as três salas. A rota entre vestíbulo, galeria e capela continua jogável.

Os testes do mapa, do portal, da capela e do vestíbulo não foram regravados nesta atualização: os arquivos desses sistemas não mudaram. O percurso e o “Continuar” da cena 15 deram `RESULTADO ok` depois da inversão.

## Exercício de cinco minutos

Abra `scenes/verification/15_escadaria_exterior.tscn`. No menu **Depurar**, ligue **Formas de colisão visíveis**. Selecione `EscadariaExterior/Lance/Rampa/Colisao`. Rode a cena com F6. A seta esquerda sobe; a seta direita desce. Solte no meio para ver a parada.

Na subida, a linha da rampa acompanha as quinas de `Lance/Degraus` e entrega os pés a `PatamarSuperior/Colisao`. Na descida, a mesma linha leva os pés até `PatamarInferior/Colisao`. A malha visível fica 0,180 m acima dessa linha.
