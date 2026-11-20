# 07 — Primeiro inimigo da galeria

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/07_primeiro_inimigo.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_07.tscn`. O encontro rodou em `tests/verificar_inimigo_07.gd`. O F5 continua em `scenes/verification/main.tscn`. A cena 06 continua com o boneco de treino.

## O trecho e a sentinela

`07_primeiro_inimigo.tscn` instancia `05_salas_conectadas.tscn`. O vestíbulo, a galeria, a câmera e o jogador são os mesmos. A sentinela reutilizável é `scenes/enemies/sentinela_da_galeria.tscn`, colocada em `Galeria/SentinelaDaGaleria`, no X local 5,4.

O piso da galeria vai do X mundo 17 ao 31. A plataforma ocupa até o X 27,3 e o topo dela está em Y = 1,2. O trecho livre à direita da plataforma cabe a patrulha e os dois pousos:

- `Galeria/PatrulhaEsquerda` em X local 4,7, mundo 28,700
- `Galeria/PatrulhaDireita` em X local 6,15, mundo 30,150

A caixa `Colisao` mede 0,58 × 1,10 × 0,42 m. O topo fica em Y = 1,10. A lâmina do jogador passa em Y = 1,15, então o golpe alcança a pedra. O pulo medido na Tarefa 06 sobe os pés até cerca de 1,59 m, então o mesmo corpo pode ser pulado. O nó `Visual/Olho` é uma esfera à frente, no +X local de `Visual`, com emissão amarela.

`velocidade_da_patrulha_m_por_s` aparece no Inspetor, no grupo Patrulha. O valor original é 1,2 m/s. `pontos_de_vida` começa em 3.

## Onde ela vira, como o X chega e o que zera a vida

`SentinelaDaGaleria._ready` chama `_ler_limites`. Essa função lê o X mundo de `PatrulhaEsquerda` e de `PatrulhaDireita` e guarda os dois números.

Em cada quadro, `_physics_process` soma `sentido * velocidade_da_patrulha_m_por_s` ao X e força Y do piso e Z = 0. Se o X alcança o limite direito, `sentido` passa a −1 e `_apontar` põe `Visual.rotation.y` em PI. O olho, filho de `Visual`, gira junto e passa a apontar para a esquerda. No limite esquerdo, `sentido` volta a 1 e `Visual.rotation.y` volta a 0.

A tecla X continua sendo a ação `atacar`. `Jogador._atualizar_golpe` vê `Input.is_action_just_pressed("atacar")` no chão. `_comecar_golpe` copia a direção para `Golpe`. `_ligar_lamina` mostra `Golpe/Lamina` e liga `AreaDoGolpe`. Quando a sentinela entra nessa área, `body_entered` chama `Jogador._ao_atingir`, que chama `_registrar_acerto`. A lista `_alvos_deste_golpe` guarda o id da sentinela. O segundo quadro de contato aumenta `quadros_sobre_o_alvo`, mas não chama `receber_acerto` de novo. Segurar X também não começa outro golpe, porque `is_action_just_pressed` só vale no quadro em que a tecla desce.

`SentinelaDaGaleria.receber_acerto` tira 1 de `pontos_de_vida` e clareia `Visual/Corpo` e `Visual/Cabeca`. Quando a vida chega a 0, `receber_acerto` chama `_encerrar_patrulha`. Essa função marca `derrotada`, adia o desligamento de `Colisao` e de `collision_layer`, deita `Visual` e apaga o olho. No quadro seguinte, `_physics_process` encontra `derrotada` e volta sem andar. A sentinela fica no lugar. Sair e voltar não recria a galeria, então o caminho continua livre. F6 carrega a cena de novo e a sentinela nasce com 3 pontos.

## O que o teste mediu

`tests/verificar_inimigo_07.gd`: `RESULTADO ok`.

- Velocidade 1,20. Vida inicial 3. Limites 28,700 e 30,150
- Patrulha: X mínimo 28,700, X máximo 30,150, Y = 0, Z = 0. Virou nos dois limites
- Salto, com a sentinela andando: antes, jogador em X = 27,800 e Y = 0, sentinela em 30,150. Depois, jogador em X = 29,900 e Y = 0, sentinela em 28,750. Os pés passaram acima do topo. A vida ficou em 3
- Golpe frontal, segurando X: vida 2, um acerto neste golpe, 7 quadros de contato, lâmina visível
- De costas: vida 2, nenhum acerto, lâmina visível
- Fora do alcance: vida 2, nenhum acerto, lâmina visível
- Golpe seguinte: vida 1, um acerto
- Terceiro golpe: vida 0, um acerto, `derrotada` e `Colisao` desligada
- Saída para o vestíbulo: X = 2,942, câmera em X = 0, vida 0
- Volta à galeria: X = 20,033, câmera em X = 24, vida 0
- Travessia do ponto caído: pés em Y = 0, sentinela parada em X = 29,940. O jogador passou e o teste o leu em X = 31,032, ainda com os pés no piso, na borda direita do chão
- Um só nó `Jogador`. Z máximo 0

As capturas, pela câmera da galeria, `Size` = 8, 1280×720, `camera_x` = 24:

- `07-patrulha-na-galeria.png` — jogador em X = 21,200, sentinela em 29,660, olho à direita, andando para +X
- `07-salto-sobre-sentinela.png` — pés em Y = 1,420, sentinela em 29,690, olho à esquerda. Os pés estão acima da pedra

O código do jogador e o das salas não mudaram. Mesmo assim:

- `tests/verificar_golpe_06.gd`: `RESULTADO ok`. O boneco continua com um acerto por golpe
- `tests/verificar_salas_05.gd`: `RESULTADO ok`. Seis trocas e a queda na galeria em X = 21,0000

## Arquivos

- `scenes/enemies/sentinela_da_galeria.gd` e `scenes/enemies/sentinela_da_galeria.tscn`
- `scenes/verification/07_primeiro_inimigo.tscn`
- `tests/verificar_inimigo_07.gd`, `tests/capturar_07.gd` e `tests/capturar_07.tscn`
- `MD-usario/prompts/07-primeiro-inimigo.md`
- `MD-usario/relatorios/07-primeiro-inimigo.md`
- `MD-usario/relatorios/evidencias/07-patrulha-na-galeria.png`
- `MD-usario/relatorios/evidencias/07-salto-sobre-sentinela.png`
- `README.md`, `docs/ROADMAP.md` e `CLAUDE.md`

`06_primeiro_golpe.tscn`, `jogador.gd` e `project.godot` não foram editados. O F5 segue na cena principal.

## Como repetir

Abra `scenes/verification/07_primeiro_inimigo.tscn` e aperte F6. Seta direita atravessa o vestíbulo. Na galeria, a sentinela anda no fim do piso. O olho amarelo aponta o lado da marcha. Seta direita e Espaço pulam por cima. Três toques de X, de frente e perto, derrubam a pedra. Depois dá para passar andando, voltar ao vestíbulo e encontrar o mesmo vão livre.

## Exercício

1. Abra `scenes/verification/07_primeiro_inimigo.tscn`.
2. Abra `Galeria` e selecione `SentinelaDaGaleria`.
3. No Inspetor, grupo **Patrulha**, a propriedade é `velocidade_da_patrulha_m_por_s`. O valor original é **1,2**.
4. Mude para **1,5**. Isso é 25% a mais. Salve com Ctrl+S.
5. Aperte F6. Vá até a galeria e pare com os pés em X = 27,8, olhando para a direita. Espere o olho vir da direita para a esquerda. Segure a seta direita e aperte Espaço. O salto ainda passa por cima; a sentinela anda mais rápido.
6. Feche o jogo. Devolva `velocidade_da_patrulha_m_por_s` para **1,2** e salve.

## Pendências

- F6 no editor, com a cena 07 em foco. A janela desta etapa abriu por `tests/capturar_07.tscn`.
- A sentinela ainda não tira vida do jogador quando encosta.
- Interface, progressão, áudio e a animação da espada continuam sem começar.
