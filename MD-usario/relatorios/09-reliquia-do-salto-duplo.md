# 09 — Relíquia do salto duplo

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/09_reliquia_do_salto_duplo.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_09.tscn`. O percurso rodou em `tests/verificar_reliquia_09.gd`. O F5 continua em `scenes/verification/main.tscn`. A cena 08 continua sem a sacada e sem a relíquia.

## O percurso

`09_reliquia_do_salto_duplo.tscn` instancia `08_vida_do_jogador.tscn`. O jogador, as duas salas, a sentinela e o `IndicadorDeVida` são os mesmos. Três nós entram só neste piloto:

- `Vestibulo/Sacada`, com `Laje`, `Parede` e `Janela`
- `Galeria/ReliquiaDoSalto`, com `Pedestal`, `Gema` e `Coleta`
- `MensagemDaHabilidade`, com o rótulo `Texto`

A sacada fica à esquerda do arco. O topo de `Laje` está em Y = 2,350. A `Janela` é um bloco claro, com emissão, no alto da parede, atrás do plano de jogo. A câmera do vestíbulo, `Size` = 8, enquadra a janela e a laje. O vão do arco continua em Z = 0; o salto feito debaixo dele voltou ao piso e não serviu de degrau.

A gema fica sobre a plataforma da galeria, em X local 0,15. A sentinela patrulha no fim do piso, à direita. Dá para subir na plataforma e pegar a relíquia sem encostar na pedra.

## Onde a coleta libera, onde o Espaço gasta e onde o pouso devolve

O toque chega em `ReliquiaDoSalto._ao_tocar`, pela área `Coleta`. Se o corpo tem `aprender_salto_duplo`, a função chama esse método uma vez, apaga a área e some com a peça.

`Jogador.aprender_salto_duplo` é o único lugar que grava a habilidade: põe `salto_duplo_adquirido` em verdadeiro. Em seguida chama `MensagemDaHabilidade.mostrar`, que escreve em `Texto`: “Salto duplo adquirido — aperte Espaço outra vez no ar”. O aviso fica 2,4 s na base da tela. `IndicadorDeVida/Vida` continua no canto.

O segundo Espaço é resolvido em `Jogador._atualizar_salto`, chamada no começo de `_physics_process`. No chão, e com a tecla acabando de descer, a velocidade vertical vira `velocidade_inicial_do_pulo_m_por_s`. No ar, a mesma função chama `_usar_impulso_extra`. Essa função só age se `salto_duplo_adquirido` é verdadeiro e `_impulso_extra_disponivel` ainda está livre. Aí a velocidade vertical vira `velocidade_do_segundo_salto_m_por_s` e o impulso extra passa a falso. Um terceiro toque encontra o impulso já gasto e não muda a subida.

Segurar Espaço desde o chão só produz `is_action_just_pressed` no quadro em que a tecla desce. O ar, com a tecla ainda presa, não chama `_usar_impulso_extra`.

O pouso devolve o uso no mesmo `_atualizar_salto`: enquanto `is_on_floor()` é verdadeiro, `_impulso_extra_disponivel` volta a copiar `salto_duplo_adquirido`. Sair andando de uma borda deixa o impulso como estava. Com a relíquia, esse impulso ainda pode ser usado uma vez no ar.

A propriedade do segundo impulso está no Inspetor, nó `Jogador`, grupo **Movimento**, nome `velocidade_do_segundo_salto_m_por_s`. O valor original é 5,5 m/s, o mesmo do primeiro salto. A habilidade em si não é uma propriedade exportada: uma execução nova da cena nasce com `salto_duplo_adquirido` falso e a relíquia no lugar.

A troca de sala, a queda e a derrota não zeram essa variável. A queda continua em `_retornar_se_cair_da_sala` e não mexe na vida. A derrota continua em `_sofrer_derrota`, restaura os três pontos e também deixa a habilidade como está.

## O que o teste mediu

`tests/verificar_reliquia_09.gd`: `RESULTADO ok`. O percurso usou as ações do Mapa de Entrada e a física do Godot. A coleta foi o corpo entrando em `Coleta`.

- Topo da sacada: 2,350 m
- Pico dos pés com salto simples, no piso X = 0,8: 1,590 m
- Pico dos pés com salto duplo, no mesmo piso: 3,174 m
- Pouso: pés em X = −4,225 e Y = 2,350, apoiados por 8 quadros
- A tentativa sem a relíquia voltou ao piso. O salto debaixo do arco também
- Coleta: texto exato da habilidade, `Vida` ainda “Vida 3/3”, peça fora da árvore
- Segurar Espaço não gastou o impulso extra
- Terceiro toque: a velocidade vertical passou de 4,520 para 3,867 m/s, sem impulso novo
- Ao pousar, o impulso extra voltou
- Depois da porta, `salto_duplo_adquirido` continuou verdadeiro
- Queda: voltou ao retorno do vestíbulo, vida 3, habilidade verdadeira
- Derrota por contato com a sentinela viva: um retorno, X = 21,000, vida 3, habilidade verdadeira
- Um só `Jogador`. Z máximo 0. F5 segue em `main.tscn`

As capturas saíram da câmera do jogo, 1280×720. A janela abriu por `tests/capturar_09.tscn`, não pelo F6.

- `09-coleta-da-reliquia.png` — galeria, `camera_x` = 24. O jogador está na plataforma, em X = 24,150 e Y = 1,200. O aviso está na base e “Vida 3/3” no canto. A sentinela aparece à direita, fora do contato
- `09-pouso-na-sacada.png` — vestíbulo, `camera_x` = 0. Os pés estão em X = −4,225 e Y = 2,350, sobre a laje, com a janela acesa ao lado. “Vida 3/3” continua no canto

Os testes anteriores, depois da mudança em `jogador.gd`:

- `tests/verificar_movimento.gd`: `RESULTADO ok`. O segundo aperto no ar, sem a relíquia, não aumentou a subida. Pico 1,5904 m
- `tests/verificar_inimigo_07.gd`: `RESULTADO ok`. O salto sobre a sentinela conservou a vida 3
- `tests/verificar_vida_08.gd`: `RESULTADO ok`. O contato, a proteção e o retorno da vida seguiram iguais

## Comandos

```
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_reliquia_09.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_movimento.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_inimigo_07.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_vida_08.gd
Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight res://tests/capturar_09.tscn
```

Os quatro testes terminaram com `RESULTADO ok` e saída 0. A captura terminou com saída 0 e gravou os dois PNG.

## Arquivos

- `scenes/player/jogador.gd`
- `scenes/environment/sacada.tscn`
- `scenes/items/reliquia_do_salto.gd` e `scenes/items/reliquia_do_salto.tscn`
- `scenes/interface/mensagem_de_habilidade.gd` e `scenes/interface/mensagem_de_habilidade.tscn`
- `scenes/verification/09_reliquia_do_salto_duplo.tscn`
- `tests/verificar_reliquia_09.gd`, `tests/capturar_09.gd` e `tests/capturar_09.tscn`
- `MD-usario/prompts/09-reliquia-do-salto-duplo.md`
- `MD-usario/relatorios/09-reliquia-do-salto-duplo.md`
- `MD-usario/relatorios/evidencias/09-coleta-da-reliquia.png`
- `MD-usario/relatorios/evidencias/09-pouso-na-sacada.png`
- `README.md`, `docs/ROADMAP.md` e `CLAUDE.md`

`08_vida_do_jogador.tscn` e `project.godot` não foram editados.

## Como repetir

Abra `scenes/verification/09_reliquia_do_salto_duplo.tscn` e aperte F6. A sacada e a janela acesa estão à esquerda. Seta esquerda e Espaço não alcançam o topo. Seta direita atravessa o arco, sobe na plataforma da galeria e encosta na gema violeta. O aviso aparece embaixo. Seta esquerda volta ao vestíbulo. Perto da sacada, aperte Espaço, e aperte Espaço outra vez no alto do salto, segurando a seta esquerda para pousar. Seta direita desce da laje e segue pelo piso.

## Exercício

1. Abra `scenes/verification/09_reliquia_do_salto_duplo.tscn`.
2. Selecione o nó `Jogador`.
3. No Inspetor, grupo **Movimento**, a propriedade é `velocidade_do_segundo_salto_m_por_s`. O valor original é **5,5**.
4. Mude para **4,4**. Isso é 20% a menos, só no segundo impulso. Salve com Ctrl+S.
5. Aperte F6. Pegue a relíquia e tente a mesma sacada. O primeiro salto continua igual; o segundo sobe menos.
6. Feche o jogo. Devolva `velocidade_do_segundo_salto_m_por_s` para **5,5** e salve.

## Pendências

O F6 no editor continua pendente. A janela desta etapa foi aberta pelo script de captura. Outras habilidades, o resto da interface, a animação da espada, a roupa, o equipamento e o áudio continuam para as próximas tarefas.
