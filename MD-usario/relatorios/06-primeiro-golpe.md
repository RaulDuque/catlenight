# 06 — Primeiro golpe corpo a corpo

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/06_primeiro_golpe.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_06.tscn`. O combate rodou em `tests/verificar_golpe_06.gd`. O F5 continua em `scenes/verification/main.tscn`, com o manequim. A cena 05 continua disponível.

## O que entrou

`06_primeiro_golpe.tscn` instancia `05_salas_conectadas.tscn` e acrescenta `Galeria/BonecoDeTreino`. O jogador é o mesmo `scenes/player/jogador.tscn`, com a corrida do piloto. A caminhada continua em 3,5 m/s, o pulo em 5,5 m/s e `velocidade_da_animacao` em 1,3.

O boneco fica em X local 5,6 da galeria, que no mundo é 29,6. O chão da galeria vai até X = 31. Dá para ficar à esquerda e à direita do alvo sem cair, sem pisar na plataforma e sem entrar em `SaidaEsquerda`. A chegada fica 9,8 m à esquerda, o retorno 8,6 m e a saída 11,8 m.

A ação nova é `atacar`, no Mapa de Entrada, ligada à tecla X (`physical_keycode` 88). Antes desta etapa o X não tinha ação.

## Um acerto, do X até a cor

1. A tecla X está em `project.godot`, na ação `atacar`.
2. No quadro de física, `Jogador._atualizar_golpe` olha o chão e `Input.is_action_just_pressed("atacar")`. Isso só é verdade no quadro em que a tecla desce, e só quando `_fase_do_golpe` está vazia. Segurar X não começa outro golpe.
3. `_comecar_golpe` copia `Visual.rotation.y` para `Golpe.rotation.y`. Essa cópia prende a direção daquele golpe, inclusive se o personagem está parado. A fase vira `espera` por 0,06 s. A lâmina continua escondida. Enquanto a fase não está vazia, `_orientar_visual` não gira o perfil.
4. No fim da espera, `_ligar_lamina` muda a fase para `ativo` por `duracao_ativa_s`, que vale 0,16 s. `_ajustar_lamina` monta a caixa de `Golpe/Lamina` do mesmo tamanho da área: começa 0,45 m à frente dos pés e termina em `alcance_do_golpe_m`. O valor original é 1,15 m. A lâmina fica visível.
5. A área que detecta o alvo se chama `AreaDoGolpe`. `_soltar_area` cria esse nó ao lado das salas, filho da raiz da cena, e liga `body_entered` a `_ao_atingir`. Uma `Area3D` nascida dentro do `CharacterBody3D` ficava no lugar certo e mesmo assim não avisava o boneco. A área criada fora do corpo avisa.
6. `_ligar_lamina` liga `AreaDoGolpe.monitoring` e depois `_posicionar_area` coloca a área no centro da lâmina, usando o giro já gravado em `Golpe`.
7. Quando o boneco entra, `_ao_atingir` chama `_registrar_acerto`. A função pede `get_instance_id()` e guarda o número em `_alvos_deste_golpe`. Se o número já está na lista, ela volta sem fazer nada. Na primeira vez soma `acertos_deste_golpe` e chama `BonecoDeTreino.receber_acerto`.
8. `receber_acerto` soma `acertos` e pinta o `material_override` de `Tronco` e de `Cabeca` com `cor_do_acerto`, amarelo (1, 0,88, 0,25), também na emissão. `_process` devolve as cores depois de `duracao_do_flash_s`, 0,45 s.

O segundo quadro de contato não conta outro golpe porque o id do boneco já está em `_alvos_deste_golpe`. O corpo continua na lista de `get_overlapping_bodies`, e `quadros_sobre_o_alvo` sobe. Nos dois acertos de frente, essa contagem chegou a 10. `acertos_deste_golpe` ficou em 1.

Depois da parte ativa vem a recuperação, 0,22 s, com a lâmina escondida e `monitoring` desligado. Só então a fase fica vazia. Se X ainda estiver preso, `is_action_just_pressed` continua falso. Soltar e apertar de novo começa outro golpe.

`salas_conectadas.gd`, em `_aplicar`, chama `encerrar_golpe` antes de mover o jogador. `Jogador._retornar_se_cair_da_sala` faz o mesmo antes de voltar ao ponto da sala. `encerrar_golpe` esvazia a fase, esconde `Golpe/Lamina` e desliga `monitoring`.

Um golpe que erra também mostra a lâmina. `_ligar_lamina` não depende de ter acertado alguém.

## O que o teste mediu

`tests/verificar_golpe_06.gd`: `RESULTADO ok`.

- Velocidades: caminhada 3,50, pulo 5,50, animação 1,30. Alcance inicial 1,15
- Boneco em X = 29,600. Chegada em 19,800. Retorno em 21,000
- De frente, à esquerda, pés em X = 28,8: total 1, deste golpe 1, 10 quadros, lâmina visível
- Do outro lado, pés em X = 30,5, perfil para −X: total 2, deste golpe 1, 10 quadros
- De costas, no mesmo X = 28,8: lâmina visível, total permaneceu 2
- Fora do alcance, pés em X = 27,95, olhando para +X: lâmina visível, total permaneceu 2
- O mesmo lugar com `alcance_do_golpe_m` = 1,55: total 3, deste golpe 1, 10 quadros. O teste devolveu o alcance para 1,15
- Segurar X por mais que um golpe: total 4, deste golpe 1
- Soltar e apertar de novo: total 5, deste golpe 1, 10 quadros
- Troca no meio do golpe, a partir de X = 18,9 olhando para −X: a lâmina sumiu, os acertos ficaram em 5, o corpo chegou em X = 2,942 e a câmera em X = 0
- Queda durante o golpe: reapareceu em X = 21,0000, pousou em Y = 0,0003, câmera em X = 24
- Pico do pulo 1,590. Z máximo 0. Um só `Jogador`

A captura `06-acerto-na-galeria.png` é a câmera da galeria, `Size` = 8, 1280×720, `camera_x` = 24. Os pés estão em X = 28,8000, Y = 0,0002, Z = 0. O perfil olha para a direita. A barra do golpe sai do peito e encosta no boneco, que está amarelo. A medida da captura: `acertos` = 1 e `acertos_deste_golpe` = 1.

Depois da mudança no controlador, nas salas e no mapa de entrada:

- `tests/verificar_movimento.gd`: `RESULTADO ok`. Pouso em Y = 0,0003, pico em Y = 1,5904, plataforma em X = 2,1083 e Y = 0,7009, volta em X = 5,9583 e Y = 0,0009, Z = 0
- `tests/verificar_direcao.gd`: `RESULTADO ok`. Altura 1,7000 m
- `tests/verificar_arco.gd`: `RESULTADO ok`. Pés em Y = 0,0003, Z = 0, vão livre
- `tests/verificar_piloto_04d.gd`: `RESULTADO ok`. Alfa 0,280 e 1,000, plataforma em X = 2,1086 e Y = 0,7009
- `tests/verificar_salas_05.gd`: `RESULTADO ok`. Seis trocas, queda na galeria em X = 21,0000 e Y = 0,0003, Z = 0

## Arquivos

- `project.godot` — ação `atacar` na tecla X
- `scenes/player/jogador.gd` e `scenes/player/jogador.tscn` — fases do golpe, lâmina e área
- `scenes/verification/salas_conectadas.gd` — encerra o golpe ao trocar de sala
- `scenes/combat/boneco_de_treino.gd` e `scenes/combat/boneco_de_treino.tscn`
- `scenes/verification/06_primeiro_golpe.tscn`
- `tests/verificar_golpe_06.gd`, `tests/capturar_06.gd` e `tests/capturar_06.tscn`
- `MD-usario/prompts/06-primeiro-golpe.md`
- `MD-usario/relatorios/06-primeiro-golpe.md`
- `MD-usario/relatorios/evidencias/06-acerto-na-galeria.png`
- `README.md`, `docs/ROADMAP.md` e `CLAUDE.md`

A cena `05_salas_conectadas.tscn` e a cena principal não foram editadas.

## Como repetir

Abra `scenes/verification/06_primeiro_golpe.tscn` e aperte F6. Seta direita atravessa o vestíbulo e chega à galeria. Passe a plataforma e chegue perto do boneco vermelho, no fim do piso. Solte a seta. X golpeia para o lado em que o perfil ficou. Acertar deixa o boneco amarelo. Errar mostra a lâmina e o boneco continua vermelho.

## Exercício

1. Abra `scenes/verification/06_primeiro_golpe.tscn`.
2. Selecione o nó `Jogador`.
3. No Inspetor, no grupo **Golpe**, a propriedade é `alcance_do_golpe_m`. O valor original é **1,15**.
4. Aperte F6. Vá até a galeria, passe a plataforma e pare com os pés em X = **27,95**, olhando para a direita. No jogo em execução, a aba Remote mostra esse X em `Jogador`, Transform > Position. Aperte X. A lâmina aparece e o boneco continua vermelho.
5. Feche o jogo. Mude `alcance_do_golpe_m` para **1,55**. Salve com Ctrl+S.
6. Aperte F6 de novo e pare no mesmo X = 27,95, olhando para a direita. Aperte X. O boneco fica amarelo.
7. Feche o jogo. Devolva `alcance_do_golpe_m` para **1,15** e salve.

O boneco não se move. Quem muda é o comprimento da lâmina e da área, os dois no mesmo valor.

## Pendências

- F6 no editor, com a cena 06 em foco. A janela desta etapa abriu por `tests/capturar_06.tscn`.
- A lâmina é uma caixa. A animação da espada fica para outra tarefa.
- Inimigos, interface, progressão e áudio continuam sem começar.
