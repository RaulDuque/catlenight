# Roadmap

Plano de estudo do Catlenight. As tarefas 01, 02, 03 e 04 foram verificadas em 19/11/2026 com o Godot 4.7.2. As tarefas 05, 06, 07 e 08 foram verificadas em 20/11/2026. A Tarefa 06-B, no mesmo dia, conferiu que o erro citado depois da Tarefa 06 não se reproduz no commit `0e9ee6e`. O relatório da Tarefa 01 permanece como histórico. O restante da interface, a progressão, a animação e o áudio continuam sem começar.

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

## 06 — Primeiro golpe corpo a corpo

**Status: concluída na cena de verificação.** Medida no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/06-primeiro-golpe.md`. O F6 do editor não foi pressionado. A janela abriu a cena por `tests/capturar_06.tscn`. O combate rodou em `tests/verificar_golpe_06.gd`. A cena 05 e o F5 da cena principal não mudaram.

| Critério | Status |
| --- | --- |
| Cena 06 com o mesmo jogador e as duas salas | Verificado. `06_primeiro_golpe.tscn` instancia `05_salas_conectadas.tscn`. Há um só `Jogador` |
| Boneco na galeria, alcançável dos dois lados | Verificado. `Galeria/BonecoDeTreino` em X local 5,6, mundo 29,6. Folga até a chegada 9,8 m, até o retorno 8,6 m e até a saída 11,8 m |
| Um toque de frente, dentro do alcance, conta um acerto de cada lado | Verificado. Esquerda em X = 28,8: total 1, `acertos_deste_golpe` 1, 10 quadros de contato. Direita em X = 30,5: total 2, deste 1, 10 quadros |
| De costas ou fora do alcance, o golpe aparece e a contagem não muda | Verificado. A lâmina ficou visível e o total permaneceu 2 |
| Segurar X gera um acerto; soltar e apertar gera o segundo | Verificado. O total foi de 3 para 4 no aperto longo e de 4 para 5 no segundo toque |
| Troca de sala e queda encerram o golpe | Verificado. Na troca, a lâmina sumiu, os acertos ficaram em 5, o corpo chegou em X = 2,942 e a câmera em X = 0. Na queda, reapareceu em X = 21,0000, Y = 0,0003, câmera em X = 24 |
| Andar, virar, pular, atravessar e Z = 0 | Verificado. Pico do pulo 1,590. Z máximo 0. Velocidades 3,50 / 5,50 / 1,30. Alcance inicial 1,15 |
| Acerto visível na câmera da galeria | Verificado em `06-acerto-na-galeria.png`, 1280×720, `Size` = 8. Pés em X = 28,8000, um acerto neste golpe |
| O mesmo lugar erra com 1,15 m e acerta com 1,55 m | Verificado em X = 27,95, olhando para +X |
| Testes do código alterado | Verificado. Movimento, direção, arco, piloto 04-D e salas 05 deram `RESULTADO ok` |
| F6 no editor | Pendente. A cena executada foi `scenes/verification/06_primeiro_golpe.tscn`, aberta pelo teste, sem o atalho do editor |

## 06-B — Verificar o teste que encerrou com erro

**Status: falha original não reproduzida.** Conferida no Godot 4.7.2 em 20/11/2026, sobre o commit `0e9ee6e`. O diagnóstico está em `MD-usario/relatorios/06b-verificar-teste-anterior.md`. Nenhum arquivo do jogo foi alterado.

| Critério | Status |
| --- | --- |
| Log da execução que motivou a mensagem | Encontrado. Teste `tests/verificar_golpe_06.gd`. Primeira explicação: `acertos_deste_golpe` não declarado em `jogador.gd`. Código de saída 4294967295, processo interrompido |
| Repetir o mesmo comando antes de editar | Verificado. `RESULTADO ok`, saída 0 |
| Segunda execução de `tests/verificar_golpe_06.gd` | Verificado. `RESULTADO ok`, saída 0. Um acerto por golpe, lâmina nos erros, troca e queda encerram o ataque |
| Efeito no golpe entregue ou nas mecânicas anteriores | O commit `0e9ee6e` já declara a variável. A falha era de um script incompleto durante a edição e não entrou no commit |

## 07 — Primeiro inimigo da galeria

**Status: concluída na cena de verificação.** Medida no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/07-primeiro-inimigo.md`. O F6 do editor não foi pressionado. A janela abriu a cena por `tests/capturar_07.tscn`. O encontro rodou em `tests/verificar_inimigo_07.gd`. A cena 06 e o F5 da cena principal não mudaram.

| Critério | Status |
| --- | --- |
| Sentinela reutilizável e piloto com as salas atuais | Verificado. `sentinela_da_galeria.tscn` entra em `07_primeiro_inimigo.tscn`, que instancia a cena 05. F5 continua em `main.tscn` |
| Ida e volta no piso, virando nos dois limites, Z = 0 | Verificado. X de 28,700 a 30,150, Y = 0, Z = 0. Virou nos dois extremos |
| Salto por cima com seta e Espaço, vida permanece 3 | Verificado. Antes: jogador (27,800, 0), sentinela 30,150. Depois: jogador (29,900, 0), sentinela 28,750. Os pés passaram acima. Vida 3 |
| Um golpe frontal tira 1 ponto e segurar X não tira outro | Verificado. Vida 3 → 2, um acerto, 7 quadros de contato |
| Golpe de costas e golpe longe conservam os 2 pontos | Verificado. A lâmina apareceu e a vida ficou em 2 |
| Dois golpes completam 2 → 1 → 0 e o caminho continua livre | Verificado. Depois da derrota, a saída chegou em X = 2,942 e a volta em X = 20,033, com a vida em 0. O jogador atravessou o ponto com os pés em Y = 0. Um só `Jogador` |
| Testes do golpe e das salas | Verificado. `verificar_golpe_06.gd` e `verificar_salas_05.gd` deram `RESULTADO ok` |
| F6 no editor | Pendente. A cena executada foi `scenes/verification/07_primeiro_inimigo.tscn`, aberta pelo teste, sem o atalho do editor |

## 08 — Vida do jogador e dano por contato

**Status: concluída na cena de verificação.** Medida no Godot 4.7.2 em 20/11/2026. O relatório está em `MD-usario/relatorios/08-vida-e-dano-por-contato.md`. O F6 do editor não foi pressionado. A janela abriu a cena por `tests/capturar_08.tscn`. O encontro rodou em `tests/verificar_vida_08.gd`. A cena 07, a cena 06 e o F5 da cena principal continuam sem essa regra.

| Critério | Status |
| --- | --- |
| Piloto reutiliza a cena 07 e liga a vida só nele | Verificado. `08_vida_do_jogador.tscn` instancia a cena 07 e marca `vida_ativa` no `Jogador`. F5 continua em `main.tscn` |
| Contato parado e contato andando tiram 1 ponto | Verificado. Parado: 3 → 2 em t = 5,033 s, seta solta. Andando: 2 → 1 em t = 14,567 s, seta direita pressionada. O texto passou a “Vida 2/3” |
| Proteção de 1,0 s e um segundo dano só se o contato continuar | Verificado. Oito quadros depois do primeiro toque a vida seguia 2 e a proteção em 0,867 s. Afastar manteve 2 depois do intervalo. Manter contato mediu 1,000 s até o dano seguinte |
| Pular conserva as duas vidas; a ponta da lâmina só tira vida da sentinela | Verificado. Depois do salto, jogador em (29,900, 0) e sentinela em 28,750, ambos com a vida de antes. O golpe seguinte deixou o jogador em 3 e a sentinela em 2 |
| Sair e voltar conserva a vida e o texto | Verificado. Volta com vida 2, texto “Vida 2/3” e sentinela ainda em 2 |
| Zero produz um único retorno | Verificado. X = 21,038, Y = 0, câmera em X = 24, vida 3, um retorno, lâmina inativa |
| Sentinela derrotada não tira vida | Verificado. Depois dos golpes restantes, o jogador atravessou o trecho em X = 30,257 com vida 3 |
| Testes 06 e 07 | Verificado. `verificar_golpe_06.gd` e `verificar_inimigo_07.gd` deram `RESULTADO ok`. O retorno das salas não foi editado, então o teste 05 não foi repetido |
| F6 no editor | Pendente. A cena executada foi `scenes/verification/08_vida_do_jogador.tscn`, aberta pelo teste, sem o atalho do editor |

## Estudo futuro — Interface

**Status: não iniciada, fora o indicador da etapa 08.**

O canto da tela do piloto 08 já mostra “Vida 3/3”. O restante da interface continua para quando houver mais informação de jogo sem esconder a câmera lateral.

## Estudo futuro — Progressão

**Status: não iniciada.**

Concluir quando uma capacidade nova abrir um caminho que já estava visível e fechado.

## Como atualizar este arquivo

Ao fechar uma etapa, troque o status e marque cada critério como verificado, pendente ou dispensado. Não marque execução em tela se o Godot não tiver sido aberto.
