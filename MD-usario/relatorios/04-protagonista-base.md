# Relatório — Tarefa 04, protagonista base

Data: 19/11/2026. Godot: `4.7.2.stable.official.ed1daf0bf`, em `C:\Users\Raul\Tools\Godot\4.7.2-stable`. Blender: `5.3.0`, hash `02f0899d78e3`, compilado em 10/11/2026, em `C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe`.

## O que foi feito

O bloco vermelho saiu de `scenes/player/jogador.tscn`. No lugar dele, o nó `Visual` carrega um manequim humanoide original de 1,70 m. O corpo físico continua o da Tarefa 02: a colisão mede 0,80 × 1,70 × 0,50 m, a origem fica nos pés, a caminhada é 3,5 m/s e o pulo sai a 5,5 m/s.

A direção é só visual. Seta direita aponta o perfil para +X. Seta esquerda aponta o perfil para −X. Soltar as setas, ou pular sem seta, conserva a última direção. A colisão não gira.

Esqueleto, ciclo de caminhada, roupa e equipamento ficam para as próximas tarefas. Esta entrega é a pose de repouso com a troca de direção.

## Arquivos

Criados:

- `arte-fonte/blender/criar_protagonista_base.py`
- `arte-fonte/blender/protagonista_base.blend`
- `assets/models/characters/protagonista_base.glb`
- `assets/models/characters/protagonista_base.glb.import`
- `tests/verificar_direcao.gd` e `tests/verificar_direcao.gd.uid`
- `tests/capturar_protagonista.gd`, `tests/capturar_protagonista.gd.uid` e `tests/capturar_protagonista.tscn`
- `MD-usario/prompts/04-protagonista-base.md`
- `MD-usario/relatorios/04-protagonista-base.md`
- `MD-usario/relatorios/evidencias/04-protagonista-no-blender.png`
- `MD-usario/relatorios/evidencias/04-personagem-direita.png`
- `MD-usario/relatorios/evidencias/04-personagem-esquerda.png`

Alterados: `scenes/player/jogador.tscn`, `scenes/player/jogador.gd`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `CLAUDE.md` e `README.md`.

A cena principal, a câmera (`Size` = 8), o arco e a plataforma continuam os da Tarefa 03.

## Altura e eixos

No Blender, antes da exportação, a sola do pé de apoio (`PeDireito`) estava em Z = 0,0000 e o topo da cabeça em Z = 1,7000. A altura medida foi 1,7000 m.

Depois da importação no Godot, a caixa da malha no espaço do `Jogador` começa em (−0,23, 0, −0,278) e mede (0,44, 1,70, 0,566). A sola importada fica em Y = 0,0000. A escala do nó `Modelo`, filho de `Visual`, é (1, 1, 1).

| | Blender, Z para cima | Godot, Y para cima |
| --- | --- | --- |
| Frente (nariz e ponta dos pés) | +X | +X |
| Direita anatômica | −Y | +Z, o lado da câmera quando ele olha para a direita |
| Esquerda anatômica | +Y | −Z |
| Altura | +Z | +Y |

O glTF converte (x, y, z) do Blender em (x, z, −y) no Godot. A frente permanece em +X, então a rotação de repouso do `Visual` já aponta para a direita da tela.

O pé de apoio é o `PeDireito`, um pouco atrás: X de −0,210 a 0,070. O `PeEsquerdo` fica à frente: X de −0,070 a 0,210. A origem da raiz `Protagonista` está no piso, no meio dos dois pés.

## O manequim

As peças têm volume e nome no Outliner: `Cabeca`, `Pescoco`, `Torax`, `Pelve`, `BracoDireito`, `AntebracoDireito`, `MaoDireita`, e o mesmo trio com `Esquerdo` e `Esquerda`. Nas pernas: `CoxaDireita`, `PernaDireita`, `PeDireito`, e o trio `Esquerda` / `Esquerdo`.

A hierarquia é `Protagonista` → `Pelve` → `Torax` → `Pescoco` → `Cabeca`. Os braços nascem do `Torax`. As pernas nascem da `Pelve`. Cada peça de membro é filha da peça acima dela.

Braços, antebraços, coxas e pernas têm rotação zero e a origem na articulação. No lado direito, os pivôs medidos no Blender foram:

| Peça | Origem (X, Y, Z), em metros |
| --- | --- |
| `BracoDireito` | −0,110, −0,200, 1,360 |
| `AntebracoDireito` | −0,050, −0,250, 1,040 |
| `CoxaDireita` | −0,130, −0,090, 0,920 |
| `PernaDireita` | −0,020, −0,100, 0,480 |

Selecionar `AntebracoDireito` e girar o objeto gira o antebraço em torno do cotovelo. O lado esquerdo usa o mesmo arranjo.

Três materiais separam as peças. `Corpo` é `#D6C4B0` (cabeça, pescoço, tórax e pelve). `MembroDireito` é `#3A6884` e fica do lado da câmera quando o perfil aponta para a direita. `MembroEsquerdo` é `#7A4E40`. A rugosidade é 0,72. Na virada, a cor do lado próximo troca junto com o nariz e a ponta do pé.

A cabeça é um perfil extrudado, com a nuca para −X e o nariz para +X. Os joelhos ficam levemente dobrados. A ponta do pé sobe um pouco para aparecer na câmera lateral. Não há dedos nem rosto.

O `.blend` guarda um chanfro de 6 mm ainda não aplicado, para a cabeça e os pés ficarem com a altura exata. A exportação aplica esse chanfro no GLB.

O script recria o arquivo inteiro. Para repetir a geração:

```
C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_protagonista_base.py
```

Esse comando apaga uma dobra feita à mão. O exercício do fim deste relatório usa a exportação do Blender, sem rodar o script.

## O que acontece com a seta esquerda

A ação `esquerda` está no Mapa de Entrada de `project.godot` e responde à seta esquerda.

Em `scenes/player/jogador.tscn`, o nó `Jogador` é um `CharacterBody3D`. No `_physics_process` de `scenes/player/jogador.gd`, a linha

```gdscript
var eixo_horizontal: float = Input.get_axis("esquerda", "direita")
```

lê as duas ações. Com a seta esquerda sozinha, o eixo fica negativo. A linha seguinte grava `velocity.x = eixo_horizontal * velocidade_caminhada_m_por_s`, então a velocidade horizontal fica −3,5 m/s. `move_and_slide()` desloca o corpo do `Jogador` para −X. A propriedade `axis_lock_linear_z` e a função `_travar_no_plano_z()` mantêm Z em 0.

Quem gira o modelo é o nó `Visual`, na função `_orientar_visual`. Eixo negativo põe `rotation.y` em PI (180°). A rotação positiva em Y leva o +X local para −Z; com 180°, o nariz que estava em +X passa a apontar para −X. O filho `Modelo` gira junto porque está dentro de `Visual`.

O nó `Colisao` é irmão de `Visual`, não filho. A caixa permanece parada. O teste de direção conferiu a base da colisão igual à identidade e a posição X do `Visual` igual à do corpo, com folga de 1 mm. A virada não empurra os pés para o lado.

Eixo zero — tecla solta, ou pulo sem seta — não entra em nenhum dos dois ramos. A última rotação fica onde está.

Para experimentar a velocidade sem abrir o script: cena `scenes/player/jogador.tscn`, nó `Jogador`, grupo **Movimento**, propriedades `velocidade_caminhada_m_por_s` (3,5) e `velocidade_inicial_do_pulo_m_por_s` (5,5). O grupo **Queda** tem `altura_minima_da_sala_m` (−2).

## Ver a colisão com o jogo rodando

No editor, com o jogo parado, abra o menu **Depuração** e marque **Formas de colisão visíveis**. Pressione F5.

A caixa desenhada é o nó `Colisao` de `scenes/player/jogador.tscn`. No Inspector, `Colisao` > Transform > Position tem Y = 0,85, e Shape > Size é (0,80, 1,70, 0,50). A base da caixa fica em Y = 0, no mesmo piso da origem do `Jogador`. Compare essa base com a sola desenhada do `PeDireito`. As duas foram medidas em Y = 0.

A malha é um pouco mais funda que a caixa: 0,566 m contra 0,50 m. Os braços passam cerca de 3 cm da caixa na direção da câmera. A largura da malha em X cabe dentro dos 0,80 m da colisão. O tamanho da caixa foi mantido de propósito.

## Testes

`tests/verificar_movimento.gd`, depois do modelo final: `RESULTADO ok`. Pouso em Y = 0,0003, pico do pulo em Y = 1,5904, plataforma em X = 2,1083 e Y = 0,7009, volta ao chão em X = 5,9583 e Y = 0,0009, Z máximo 0, retorno ao cair confirmado.

`tests/verificar_arco.gd`, na mesma rodada: `RESULTADO ok`. Ida de X = −2,558 a −1,450, volta de X = −1,508 a −2,617, pés em Y = 0,0003, Z máximo 0. O raio no pilar acertou `Colisao`. O raio do corredor, na altura do tronco e em Z = 0, passou livre. A altura livre visual na faixa do corpo continua 4,227 m.

`tests/verificar_direcao.gd`, depois de reimportar o GLB final: `RESULTADO ok`. Altura importada 1,7000 m, sola em Y = 0, escala do `Visual` (1, 1, 1). Andar para a direita põe `Visual.rotation.y` em 0 e aumenta X. Soltar conserva 0 e para o corpo. Andar para a esquerda põe a rotação em PI e diminui X. Soltar conserva PI. O pulo sem seta tira os pés do chão e conserva PI. A rotação do `Jogador` permanece 0.

## F5 e capturas

O editor foi aberto em `main.tscn`. F5 mostrou a janela `Catlenight (DEBUG)` em 1280×720. O manequim caiu e ficou em pé no chão, à esquerda do arco, de perfil para a direita. A seta direita levou o corpo até o pilar da frente, ainda de perfil para a direita, com a cabeça legível. A seta esquerda virou o perfil para a esquerda: o lado marrom ficou para a câmera e a ponta do pé apontou para a esquerda. Depois do Espaço, sem seta, ele estava de novo no chão, ainda virado para a esquerda. A saída do editor mostrou o cabeçalho do motor, a linha Vulkan e `Debugging process stopped`, sem erro de script. F8 encerrou o jogo e o editor foi fechado.

O quadro no ar desse Espaço não foi congelado na janela do editor. A medida do pulo está no teste de movimento, e a conservação da direção durante o pulo está no teste de direção.

As capturas do jogo usam a mesma câmera, com `Size` = 8:

- `MD-usario/relatorios/evidencias/04-protagonista-no-blender.png` — corpo inteiro em três quartos, no Blender.
- `MD-usario/relatorios/evidencias/04-personagem-direita.png` — perfil para a direita, na passagem do arco, com a cabeça visível ao lado do pilar da frente. X = −2,092, rotação do `Visual` = 0.
- `MD-usario/relatorios/evidencias/04-personagem-esquerda.png` — perfil para a esquerda, com o arco ainda no quadro. X = −3,200, rotação do `Visual` = 3,142.

Em 1280×720 a frente e as costas se separam pelo nariz, pela ponta do pé e pela cor do membro próximo. O nariz da primeira versão não se lia nesse tamanho; a cabeça atual é o perfil mais longo, e estas capturas são dessa versão.

## Pendências

Não há esqueleto, ciclo de caminhada, roupa nem equipamento. A colisão continua a caixa de 0,80 × 1,70 × 0,50 m, um pouco mais estreita em Z do que os braços. Git ainda não está instalado e o repositório local não foi criado. Salas, combate, inimigos, interface, progressão e áudio continuam no estudo futuro.

## Exercício de cinco minutos

Abra `arte-fonte/blender/protagonista_base.blend`. No Outliner, selecione `AntebracoDireito`. Fique no Modo Objeto.

A origem dessa peça é o cotovelo e a rotação dela começa em zero. O eixo certo deste modelo é o **Y**. Pressione `R`, depois `Y`, e gire no sentido negativo. No painel `N`, aba Item, deixe **Rotation Y** em cerca de −20 graus. A mão avança para +X, que é a frente do personagem, e sobe um pouco. O braço fica parado porque o pivô está no cotovelo.

Não rode `criar_protagonista_base.py`. Esse comando reconstrói o `.blend` e apaga a dobra.

Para levar a pose ao jogo:

1. No Modo Objeto, pressione `A` para selecionar tudo.
2. No Outliner, com Shift, clique em `CameraTresQuartos`, `Sol` e `Preenchimento` para tirá-los da seleção.
3. File > Export > glTF 2.0. Sobrescreva `assets/models/characters/protagonista_base.glb`.
4. Formato glTF Binary. Marque **Selected Objects** e **Apply Modifiers**. Exporte.
5. No Godot, se o braço antigo continuar na tela, clique no GLB no dock Sistema de Arquivos e use Reimportar. Pressione F5.

Para restaurar a pose original, volte **Rotation Y** de `AntebracoDireito` para 0 e exporte do mesmo jeito. Se o `.blend` não foi salvo, reabri-lo já traz a rotação em 0; exporte de novo para o jogo voltar à pose de repouso. Não use Ctrl+A para aplicar a rotação: isso grava a dobra na malha e tira o pivô do cotovelo.
