# 10 — A passagem da sacada e a Capela da Lua

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/10_capela_da_lua.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_10.tscn`. O percurso rodou em `tests/verificar_capela_10.gd`. O F5 continua em `scenes/verification/main.tscn`. A cena 09 continua com a janela pequena, para o exercício do salto duplo.

## O percurso

`10_capela_da_lua.tscn` instancia `09_reliquia_do_salto_duplo.tscn`. O jogador, as duas salas, a sacada, a relíquia, a sentinela e o `IndicadorDeVida` são os mesmos. Neste piloto a janela pequena fica oculta. Entram quatro peças:

- `Vestibulo/VaoDaCapela`, o vão iluminado de 1,05 m por 1,90 m, com a área `Passagem`
- `Vestibulo/ChegadaDaSacada`, o marcador da volta, em X = −4,55 e Y = 2,42
- `CapelaDaLua`, a sala em X = 48
- `AvisoDaPassagem`, o texto na base da tela

O topo de `Vestibulo/Sacada/Laje` continua em Y = 2,350. A área da passagem fica acima da cabeça de quem está no piso. O salto simples, medido na etapa 09 em 1,590 m, não chega a esse topo. O salto duplo chega. As portas entre vestíbulo e galeria continuam automáticas, com as setas laterais.

## O caminho de um toque na seta para cima

A tecla está no Mapa de Entrada como a ação `interagir`.

1. `PassagemInterativa._physics_process` lê `Input.is_action_just_pressed("interagir")`.
2. No mesmo quadro, `PassagemInterativa._jogador_apoiado` procura o `Jogador` dentro da área, com `is_on_floor()` verdadeiro e a menos de 2,2 m do centro. No ar, ou com a tecla já presa desde o pouso, a troca não começa.
3. `PassagemInterativa._pedir` sobe pelos pais até achar `solicitar_passagem` e chama `salas_conectadas.solicitar_passagem`.
4. No quadro de física seguinte, `salas_conectadas._aplicar` lê `sala_de_destino` e `chegada` dessa passagem, coloca o mesmo `Jogador` no marcador com Z = 0, chama `definir_ponto_de_retorno` com o `Retorno` da sala e `_enquadrar` copia o `Enquadramento` para `CameraLateral`.

`_quadros_de_folga` fica em 10. Um segundo pedido, com a tecla ainda presa, não entra. As portas horizontais continuam em `passagem.gd`: o corpo atravessa, `_ao_cruzar` marca a passagem e o mesmo `_aplicar` troca a sala.

Na volta, `CapelaDaLua/Saida` aponta para `Vestibulo/ChegadaDaSacada`. Os pés nascem em Y = 2,42 e assentam no topo da laje, em Y = 2,350, com folga até as bordas.

## O que o teste mediu

`tests/verificar_capela_10.gd`: `RESULTADO ok`. O percurso começou no vestíbulo, coletou a relíquia por contato e pousou na sacada com os saltos. Não houve teleporte para simular a coleta nem o pouso.

- Topo da laje: 2,350 m. A ação `interagir` existe. O F5 segue em `main.tscn`
- Antes da relíquia: pés em X = −4,433 e Y = 0, câmera em X = 0
- Coleta na plataforma: “Vida 3/3”
- Um contato com a sentinela viva baixou a vida para 2
- Cruzou a área no ar com a tecla presa e pousou em X = −4,233 e Y = 2,350, câmera em X = 0, vida 2
- Um toque novo: pés em X = 45,800 e Y = 0, câmera em X = 48, vida 2, uma entrada
- O vitral ficou visível. Ao passar de X = 47,6 o aviso sumiu
- Volta: pés em X = −4,608 e Y = 2,350 por 8 quadros, câmera em X = 0, vida 2, `salto_duplo_adquirido` verdadeiro, uma volta
- Depois de descer, a ida à galeria e a volta ao vestíbulo terminaram em X = 2,942, câmera em X = 0
- Um só `Jogador`

As capturas saíram da câmera do jogo, 1280×720. A janela abriu por `tests/capturar_10.tscn`, não pelo F6. Nessa gravação a vida ficou em 3, porque o script não encostou na sentinela. O aviso da relíquia ainda estava na base, dentro dos 2,4 s.

- `10-entrada-na-sacada.png` — vestíbulo, `camera_x` = 0. Os pés estão em X = −4,225 e Y = 2,350, dentro do vão iluminado. O texto é “↑ Entrar na capela”. “Vida 3/3” fica no canto
- `10-capela-da-lua.png` — capela, `camera_x` = 48. Os pés estão em X = 45,800 e Y = 0. A lua crescente está na parede do fundo. O texto é “↑ Voltar ao vestíbulo”

Os testes das salas e da relíquia, depois da passagem nova:

- `tests/verificar_salas_05.gd`: `RESULTADO ok`. Seis trocas entre vestíbulo e galeria, queda na galeria e o vão do arco
- `tests/verificar_reliquia_09.gd`: `RESULTADO ok`. Pico simples 1,590 m, pico duplo 3,174 m, pouso em X = −4,225 e Y = 2,350

## Comandos

```
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_capela_10.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_salas_05.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_reliquia_09.gd
Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight res://tests/capturar_10.tscn
```

Os três testes terminaram com `RESULTADO ok` e saída 0. A captura terminou com saída 0 e gravou os dois PNG.

## Arquivos

- `project.godot` — ação `interagir` na seta para cima
- `scenes/verification/salas_conectadas.gd` — `solicitar_passagem`
- `scenes/environment/passagem_interativa.gd`
- `scenes/environment/vao_da_capela.tscn`
- `scenes/environment/capela_da_lua.tscn`
- `scenes/interface/aviso_da_passagem.gd` e `scenes/interface/aviso_da_passagem.tscn`
- `scenes/verification/10_capela_da_lua.tscn`
- `tests/verificar_capela_10.gd`, `tests/capturar_10.gd` e `tests/capturar_10.tscn`
- `MD-usario/prompts/10-capela-da-lua.md`
- `MD-usario/relatorios/10-capela-da-lua.md`
- `MD-usario/relatorios/evidencias/10-entrada-na-sacada.png`
- `MD-usario/relatorios/evidencias/10-capela-da-lua.png`
- `README.md`, `docs/ROADMAP.md` e `CLAUDE.md`

`jogador.gd`, `sacada.tscn` e `09_reliquia_do_salto_duplo.tscn` não foram editados.

## Como repetir

Abra `scenes/verification/10_capela_da_lua.tscn` e aperte F6. A passagem iluminada está no alto, à esquerda do arco. Seta direita atravessa o arco, sobe na plataforma da galeria e encosta na gema. Seta esquerda volta ao vestíbulo. Perto da sacada, Espaço e Espaço outra vez no ar, com a seta esquerda, pousam na laje. “↑ Entrar na capela” aparece. Solte a seta para cima, se ela estiver presa, e aperte de novo. Na capela, a lua crescente fica na parede do fundo. Afaste-se da entrada e o aviso some. Volte para a entrada, aperte a seta para cima e os pés ficam na sacada. Seta direita desce e o caminho da galeria continua aberto.

## Exercício

1. Abra `scenes/verification/10_capela_da_lua.tscn`.
2. Selecione o nó `CapelaDaLua/Chegada`.
3. No Inspetor, em Transform, a posição X original é **−2,2**.
4. Mude X para **−1,7**. Isso desloca a chegada 0,5 m para o lado da lua, ainda sobre o piso, que vai de X local −4 a 4. Salve com Ctrl+S.
5. Aperte F6, pegue a relíquia, pouse na sacada e entre. O personagem aparece meio metro mais longe do portal.
6. Feche o jogo. Devolva a posição X de `Chegada` para **−2,2** e salve.

## Pendências

O F6 no editor continua pendente. A janela desta etapa foi aberta pelo script de captura. O restante da interface, outras habilidades, a animação da espada, a roupa, o equipamento e o áudio continuam para as próximas tarefas.
