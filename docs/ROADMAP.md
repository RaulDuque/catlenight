# Roadmap

Plano de estudo do Catlenight. As tarefas 01, 02, 03 e 04 foram verificadas em 19/11/2026 com o Godot 4.7.2. A Tarefa 05 foi verificada em 20/11/2026. O relatório da Tarefa 01 permanece como histórico. Combate, inimigos, interface, progressão, animação e áudio continuam sem começar.

## 01 — Fundação e cena de verificação

**Status: concluída na validação posterior.** O F5 foi pressionado no editor em 19/11/2026, já com o jogador da Tarefa 02. A janela mostrou a vista lateral, o bloco apoiado no chão e a plataforma. O relatório 02 guarda o detalhe.

Critérios e o que foi verificado:

| Critério | Status |
| --- | --- |
| Cena principal configurada em `project.godot` | Verificado no arquivo e na execução: `res://scenes/verification/main.tscn` |
| Chão com colisão estática | Verificado no texto da cena: `Chao` (`StaticBody3D`) e `Colisao` (`CollisionShape3D`) |
| Bloco provisório do personagem | Verificado no texto da cena e na captura |
| Luz | Verificado no texto da cena: `Luz` (`DirectionalLight3D`) |
| Câmera ortográfica lateral enquadrando XY | Verificado no texto da cena e na imagem: vista de lado, `size = 8.0` |
| Base do bloco no topo do chão (Y = 0) | Verificado por conta e na captura `MD-usario/relatorios/evidencias/01b-cena-principal.png` |
| Importação do projeto pelo Godot | Verificado em 19/11/2026. `--import` terminou com código 0. Detalhe no relatório 01b |
| Carregamento da cena principal pelo Godot | Verificado. O projeto foi o ponto de entrada, sem passar o arquivo da cena na linha de comando |
| F5 com a cena lateral e o bloco apoiado no chão | Verificado no editor em 19/11/2026. F5 abriu `Catlenight (DEBUG)` sem erro de script |
| Prompt, decisões, roadmap e instruções de abertura salvos | Verificado pela presença dos arquivos nos caminhos pedidos |

## 02 — Movimento no plano da fase

**Status: concluída.** Medida com a física do Godot 4.7.2 em 19/11/2026. O F5 no editor mostrou a cena depois da queda. O relatório está em `MD-usario/relatorios/02-movimento-e-pulo.md`.

| Critério | Status |
| --- | --- |
| Nasce no ar, cai e para no chão | Verificado. Pés em Y = 1,000; pouso em Y = 0,0003 |
| Setas movem e soltar interrompe | Verificado na física. Direita aumenta X, esquerda diminui X, soltar zera o deslocamento |
| Espaço pula uma vez no chão | Verificado. Pico medido em Y = 1,590 m. Segundo aperto no ar não aumentou a subida. Segurar até pousar não gerou outro pulo |
| Sobe na plataforma, fica em pé e volta ao chão | Verificado. Parou em X = 2,108 e Y = 0,701; depois voltou ao chão em X = 5,958 e Y = 0,001 |
| Z permanece em 0 | Verificado. Maior afastamento medido: 0 |
| Cair da borda devolve ao início | Verificado. O corpo voltou a (-3,2, 1, 0) com velocidade zerada |
| Cena principal sem erro de script | Verificado no teste, na execução da janela e no F5. A saída do editor mostrou o cabeçalho do motor e o dispositivo Vulkan |

## 03 — Arco de pedra

**Status: concluída.** Modelada no Blender 5.3.0 e testada no Godot 4.7.2 em 19/11/2026. O relatório está em `MD-usario/relatorios/03-arco-de-pedra.md`.

| Critério | Status |
| --- | --- |
| Peça original com pilares, bases, cunhas e pedra central | Verificado no `.blend` e na captura `03-arco-no-blender.png` |
| Origem no centro da passagem, no piso, em metros | Verificado. Depois da importação, a caixa da malha começa em Y = 0 e a altura mede 5,115 m |
| Vão livre para o corpo de 1,70 m por 0,50 m | Verificado na malha girada: altura livre de 4,227 m na faixa do corpo. A abertura entre as faces internas dos pilares é 2,40 m |
| GLB importado e cena reutilizável com colisão fora do modelo | Verificado. `scenes/environment/arco_de_pedra.tscn` guarda as caixas; o GLB é só o visual |
| Travessia de ida e volta com as ações reais | Verificado. Pés em Y = 0,0003 e Z = 0. O teste de movimento da Tarefa 02 continuou ok |
| Colisão representa a pedra e deixa o corredor livre | Verificado. Um raio no pilar acertou `Colisao`; um raio na altura do tronco, em Z = 0, não acertou nada |
| F5 com o personagem sob o arco | Verificado no editor. A seta direita levou o bloco para debaixo do arco, em 1280×720, sem erro de script |

## 04 — Protagonista base

**Status: concluída.** Modelado no Blender 5.3.0 e testado no Godot 4.7.2 em 19/11/2026. O relatório está em `MD-usario/relatorios/04-protagonista-base.md`.

| Critério | Status |
| --- | --- |
| Manequim original de 1,70 m, origem no piso | Verificado no Blender: sola em Z = 0,0000 e topo da cabeça em Z = 1,7000. No Godot, a sola importada fica em Y = 0 e a escala do `Modelo` é 1 |
| Peças nomeadas, com pivô de braço, antebraço, coxa e perna na articulação | Verificado no `.blend`. `AntebracoDireito` tem a origem em (−0,050, −0,250, 1,040) e rotação zero |
| GLB filho de `Visual` no lugar do bloco vermelho | Verificado em `scenes/player/jogador.tscn`. O nó `Modelo` instancia `protagonista_base.glb` |
| Direita olha para +X, esquerda olha para −X, parar conserva a direção | Verificado em `tests/verificar_direcao.gd`. Soltar a tecla e pular sem seta mantêm `Visual.rotation.y`. A colisão não gira e o `Visual` não desloca em X |
| Colisão, caminhada e pulo iguais aos da Tarefa 02 | Verificado. Caixa 0,80 × 1,70 × 0,50 m. Os testes de movimento e de travessia do arco continuaram ok depois do modelo final |
| F5 com queda, chão e as duas direções | Verificado no editor. O manequim apoiou no chão, andou até o pilar e virou para a esquerda. A saída não mostrou erro de script |
| Frente e costas legíveis em 1280×720 | Verificado nas capturas `04-personagem-direita.png` e `04-personagem-esquerda.png`, com `Size` = 8. A da direita está na passagem do arco, com a cabeça visível |

Esqueleto, ciclo de caminhada, roupa e equipamento ficam para as próximas tarefas. A colisão continua a caixa, um pouco mais estreita em Z do que os braços.

## 04-A — Piloto Hunyuan e Mixamo

**Status: em andamento.** A ferramenta foi instalada e a geometria do exemplo oficial foi gerada em 20/11/2026. O relatório está em `MD-usario/relatorios/04a-personagem-hunyuan-mixamo.md`. O manequim da Tarefa 04 continua jogável.

| Critério | Status |
| --- | --- |
| Hunyuan3D-2mini local, só geometria, na RTX 3060 Ti | Verificado. Driver 621.01, 8192 MiB. A geração do exemplo oficial levou 37,0 s depois dos pesos carregados |
| Imagem original do protagonista | Pendente. Não havia arquivo no projeto. O caminho de entrada é `arte-fonte/hunyuan/entrada/protagonista.png` |
| Malha de 1,70 m e FBX para o Mixamo | O FBX da corrida foi conferido na Tarefa 04-C. A imagem de entrada do protagonista continua pendente |
| Cena de teste com a corrida no controlador | Verificado na Tarefa 04-C, na cena `scenes/verification/04c_corrida_mixamo.tscn`. A cena principal segue com o manequim |
| Interface local para gerar outros moldes | Verificado. A página respondeu em `http://127.0.0.1:8080`. O atalho para reabrir é `D:\Tools\Hunyuan3D\abrir_hunyuan.bat`. Nesta placa a geração é só geometria |

## 04-B — Preparar um molde para o Mixamo

**Status: em andamento.** O OBJ foi preparado e reimportado no Blender em 20/11/2026. O relatório está em `MD-usario/relatorios/04b-preparar-molde3d-para-mixamo.md`. O manequim da Tarefa 04 continua jogável.

| Critério | Status |
| --- | --- |
| Escolha de um humanoide completo, com braços, tronco e pernas separados | Verificado. Fonte: `molde3d\white_mesh (1).glb`, 165900 triângulos, sem armature e sem animação. A variante com espada e capa fundidas ficou de fora |
| Cópia editável e cópia de exportação no mesmo `.blend` | Verificado em `arte-fonte/blender/protagonista_mixamo_preparado.blend`. Coleções `PecasEditaveis` e `CopiaExportacao` |
| Pose ereta, 1,70 m, solas no piso, mãos fora das coxas | Verificado na cópia. Sola em Z = 0,0001 e topo em Z = 1,7000. Axilas com cerca de 4,2 cm de vão |
| OBJ único, sem espada, reimportado no Blender | Verificado. `arte-fonte/mixamo/protagonista_mixamo_upload.obj`, 3,95 MB, 52000 triângulos, um objeto. Captura: `04b-modelo-para-mixamo.png` |
| Auto-rig confirmado no Mixamo | O FBX `arte-fonte/mixamo/protagonista_hunyuan_corrida.fbx` contém a malha, o esqueleto mixamorig e o clipe. A medição está no relatório 04-C |
| Cena jogável da Tarefa 04 | Preservada. `jogador.tscn` e `main.tscn` não foram editados |

## 04-B2 — Comparar o darkcastle

**Status: concluída no Blender.** A prancha e os dois OBJ estão prontos em 20/11/2026. O relatório está em `MD-usario/relatorios/04b2-avaliar-darkcastle.md`. O auto-rig no Mixamo continua pendente.

| Critério | Status |
| --- | --- |
| Origem da captura em três quartos | Verificado no script de render. A imagem é `molde3d\white_mesh.glb` |
| Medidas do `darkcastle.obj` e das junções | Verificado. 418482 triângulos, uma ilha, 1,992 m de altura original, sem material. Mãos a cerca de 3 mm das coxas; espada na mesma superfície da mão |
| Prancha na mesma escala, com o tamanho do jogo | Verificado em `04b2-comparacao-personagens.png`. Os três estão a 1,70 m. O perfil pequeno tem 153 px |
| OBJ próprio do darkcastle, reimportado | Verificado. `arte-fonte/mixamo/darkcastle_mixamo_upload.obj`, 3,95 MB, 52000 triângulos, sola no piso |
| Primeiro arquivo indicado para o Mixamo | `arte-fonte/mixamo/protagonista_mixamo_upload.obj`, preservado. A escolha usa a separação dos membros |
| Auto-rig confirmado no Mixamo | Pendente |

## 04-C — Corrida no Godot

**Status: concluída no piloto.** O FBX foi medido no Blender 5.3.0 e a cena rodou no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/04c-corrida-no-godot.md`. O F5 do editor não foi pressionado. A janela abriu por `tests/capturar_corrida.tscn`. A cena principal continua com o manequim.

| Critério | Status |
| --- | --- |
| FBX com a malha, o esqueleto ligado e um clipe de corrida | Verificado. 175816 triângulos, 41 ossos `mixamorig`, clipe `Armature\|mixamo.com\|Layer0`, quadros 1 a 23 a 30 fps. O quadro 23 repete o quadro 1. O arquivo original não foi alterado |
| Dois ciclos com ombros, mãos, joelhos e botas | Verificado nas capturas `04c-blender-frente.png`, `04c-blender-ciclo-a.png` e `04c-blender-ciclo-b.png`. Os joelhos dobram, os punhos fecham e as botas acompanham os pés. O cabelo solto deforma de forma irregular |
| 1,70 m, solas no piso, frente em +X | Verificado na pose de repouso: sola em Z = 0 e topo em Z = 1,7000. No Godot, a seta direita mostra o rosto voltado para a plataforma |
| Sem avanço acumulado por ciclo | Verificado. O quadril do quadro 23 coincide com o do quadro 1. O balanço horizontal ficou. Só o canal vertical do quadril desceu 0,954 m, para a sola de apoio encostar no piso |
| GLB com malha, esqueleto e animação | Verificado depois da importação. O Godot lista o clipe `corrida`, com duração 0,7667 s |
| Sala atual, controlador atual, modelo trocado só no piloto | Verificado. `04c_corrida_mixamo.tscn` reusa chão, arco, plataforma e câmera com `Size` = 8. `jogador.tscn` e `main.tscn` continuam com o manequim |
| Corrida em loop no chão, repouso ao soltar, pausa no pulo | Verificado no percurso. O clipe estava em 0,6298 s no ar e em 0,6515 s ao pousar na plataforma |
| Deslocamento, pulo, colisão e Z = 0 | Verificado. Os testes de movimento, direção e arco deram `RESULTADO ok`. No piloto, Z máximo = 0 e a plataforma ficou em X = 3,9407 e Y = 0,7009 |
| Pé de apoio e velocidade do clipe | Verificado. Com `velocidade_da_animacao` = 1,3, um apoio inteiro deslocou o tornozelo 0,0025 m e o seguinte −0,119 m. O quadril local foi de −0,097 m para −0,088 m |
| Quadros da corrida no Godot | Verificado em `04c-godot-apoio-01.png` a `04c-godot-apoio-04.png`. As pernas trocam o apoio entre o arco e a plataforma |

## 04-D — Visibilidade da corrida

**Status: concluída no piloto.** Medida no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/04d-visibilidade-da-corrida.md`. O F6 do editor não foi pressionado. A janela abriu a cena do piloto por `tests/capturar_04d.tscn`. A cena principal e o F5 não mudaram.

| Critério | Status |
| --- | --- |
| Duas poses iguais antes de editar, em 1280×720 e `Size` = 8 | Verificado. Sob o arco em X = −1,714 e no chão livre em X = −0,600. Direção +X, clipe `corrida` em 0,270 s |
| Distinguir luz de objeto que cobre o corpo | Verificado na prancha `04d-antes-depois.png`. No chão livre o corpo estourava no branco. Sob o arco o pilar dianteiro escondia tronco e cabeça |
| Material e normais antes de aumentar a luz | Verificado. Albedo branco, rugosidade 1, sombreamento por pixel. A média das normais ficou perto de zero. A luz do piloto baixou de 1,15 para 0,7 |
| Ambiente só no piloto, com volume no cabelo e no corpo | Verificado. `Ambiente`, energia 0,12, cor (0,62, 0,58, 0,54). O depois mostra tronco, perna de trás e cabelo em cinza |
| Pilar dianteiro nas duas direções, pedra opaca fora da passagem | Verificado. Alpha 0,280 com o corpo atrás do pilar e 1,000 ao lado. Direita e esquerda aparecem em `04d-arco-depois.png` e `04d-arco-depois-esquerda.png` |
| Vão em Z = 0 e colisão do pilar | Verificado em `tests/verificar_piloto_04d.gd`. O raio do vão passou livre. O raio no pilar acertou a pedra. Plataforma em X = 2,1086 e Y = 0,7009. Z máximo 0 |
| Velocidades 3,5 / 5,5 / 1,3 | Verificado no mesmo teste |
| Testes da cena principal | Verificado. Movimento, direção e arco deram `RESULTADO ok` |

## 05 — Primeiras duas salas conectadas

**Status: concluída na cena de verificação.** Medida no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/05-salas-conectadas.md`. O F6 do editor não foi pressionado. A janela abriu a cena por `tests/capturar_05.tscn`. A travessia rodou em `tests/verificar_salas_05.gd`. A cena principal e o F5 não mudaram.

| Critério | Status |
| --- | --- |
| Vestíbulo e galeria reutilizáveis, arco só no vestíbulo | Verificado. `vestibulo.tscn` instancia o arco. `galeria.tscn` tem `Plataforma`, `ColunaFundoEsquerda` e `ColunaFundoDireita` |
| As duas salas se reconhecem com o personagem parado | Verificado em `05-vestibulo.png` e `05-galeria.png`, 1280×720, `CameraLateral` com `Size` = 8 |
| Um jogador, pés no piso da chegada, Z = 0 | Verificado em três idas e três voltas. Na galeria, X = 19,8583, Y = 0, Z = 0. No vestíbulo, X = 2,9417 |
| Uma troca por passagem, mesmo segurando a seta | Verificado na terceira ida. O total ficou em 6 trocas. Depois de soltar, o corpo parou na galeria |
| Câmera na sala de destino | Verificado. `camera_x` = 24 na galeria e 0 no vestíbulo |
| Queda na galeria devolve à galeria | Verificado. Reapareceu em X = 21,0000 e pousou em Y = 0,0003. A câmera ficou em X = 24 |
| Caminhada, pulo, animação e corrida nos dois sentidos | Verificado. 3,50 / 5,50 / 1,30. O clipe `corrida` tocou para a direita e para a esquerda. Z máximo 0 |
| Pilar do vestíbulo continua legível | Verificado. Alfa 0,280 ao passar e 1,000 ao sair |
| Testes do código alterado | Verificado. Movimento, direção, arco e o piloto 04-D deram `RESULTADO ok` |
| F6 no editor | Pendente. A cena executada foi `scenes/verification/05_salas_conectadas.tscn`, aberta pelo teste, sem o atalho do editor |

## Estudo futuro — Combate de ação

**Status: não iniciada.**

Concluir quando um ataque corpo a corpo, feito no plano da fase, tiver um resultado visível em um alvo provisório.

## Estudo futuro — Inimigos

**Status: não iniciada.**

Concluir quando um oponente geométrico ocupar o mesmo plano, reagir ao jogador e puder ser vencido ou evitado.

## Estudo futuro — Interface

**Status: não iniciada.**

Concluir quando a informação mínima de jogo aparecer sem esconder a leitura da câmera lateral.

## Estudo futuro — Progressão

**Status: não iniciada.**

Concluir quando uma capacidade nova abrir um caminho que já estava visível e fechado.

## Como atualizar este arquivo

Ao fechar uma etapa, troque o status e marque cada critério como verificado, pendente ou dispensado. Não marque execução em tela se o Godot não tiver sido aberto.
