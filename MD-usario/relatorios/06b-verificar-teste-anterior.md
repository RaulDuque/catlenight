# 06-B — Verificar o teste que encerrou com erro

Data: 20/11/2026. Godot 4.7.2. O commit conferido é `0e9ee6e`, “Dá o primeiro golpe no boneco da galeria, com um acerto por ataque.” O relatório `MD-usario/relatorios/06-primeiro-golpe.md` permanece como histórico. Nenhum arquivo do jogo foi alterado.

## O que o Git mostrava

`git rev-parse HEAD` devolveu `0e9ee6e966fd39974c1b8fb7d802cae3f566ce7d`. `git diff 0e9ee6e` estava vazio. A única alteração local, feita para guardar este pedido, é `MD-usario/prompts/06b-verificar-teste-anterior.md`.

## A execução que motivou a mensagem

O log original está disponível. A execução começou às 13:27, horário de Brasília, e foi encerrada cerca de 35 s depois.

- Teste: `tests/verificar_golpe_06.gd`
- Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_golpe_06.gd`
- Código de saída: 4294967295. O Godot não imprimiu `RESULTADO` e o processo foi interrompido
- Primeira mensagem que explica a falha: `SCRIPT ERROR: Parse Error: Identifier "acertos_deste_golpe" not declared in the current scope.` O aviso aponta `scenes/player/jogador.gd`, linha 219, chamado a partir de `tests/verificar_golpe_06.gd`, função `_montar`

Naquele instante o script do jogador usava `acertos_deste_golpe` sem a linha que declara a variável. O Godot recusou o script. O teste nem chegou a medir golpe, direção ou queda. Em `0e9ee6e` a declaração existe: `var acertos_deste_golpe := 0`, na linha 40 de `jogador.gd`.

## Falha original não reproduzida

O mesmo comando foi repetido duas vezes, no commit atual, antes de qualquer correção. As duas saíram com código 0 e `RESULTADO ok`.

Comando, nas duas vezes:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_golpe_06.gd`

As duas impressões coincidiram:

- alcance inicial 1,15; caminhada 3,50; pulo 5,50; animação 1,30
- acerto à esquerda, X = 28,8: total 1, deste golpe 1, 10 quadros, lâmina visível
- acerto à direita, X = 30,5: total 2, deste golpe 1, 10 quadros
- de costas e fora do alcance: lâmina visível, total permaneceu 2
- alcance 1,55 no mesmo lugar longe: deste golpe 1; o teste devolveu 1,15
- segurar X: deste golpe 1; soltar e apertar: o segundo, total 5
- troca de sala: lâmina sumiu, acertos ficaram em 5, corpo em X = 2,942, câmera em X = 0
- queda: X = 21,0000, Y = 0,0003, câmera em X = 24
- Z máximo 0; pico do pulo 1,590

Como nenhum script compartilhado mudou, os testes de movimento, direção, arco, piloto 04-D e salas 05 não foram repetidos nesta tarefa. O log original existia, então a lista de regressão do relatório 06 não precisou ser reexecutada para descobrir a falha.

## O que isso significa no jogo

Quem joga o commit `0e9ee6e` não encontra essa falha. O personagem carrega, o X golpeia e o boneco muda de cor como o relatório 06 descreve. A mensagem de erro vinha de um arquivo ainda sendo escrito: o contador do golpe era usado antes de existir. Se aquele texto incompleto tivesse ficado salvo, a cena do jogador não abriria e não haveria golpe para ver. Isso não aconteceu. A nova execução comprovou de novo um acerto por golpe, a lâmina quando o golpe erra e o fim do ataque ao trocar de sala ou cair.
