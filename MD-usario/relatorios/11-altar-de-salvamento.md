# 11 — Altar de salvamento na Capela da Lua

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/11_altar_de_salvamento.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_11.tscn`. O percurso rodou em `tests/verificar_altar_11.gd`, cada etapa num processo novo. O F5 continua em `scenes/verification/main.tscn`. A cena 10 continua sem menu e sem altar.

## O percurso

`11_altar_de_salvamento.tscn` instancia `10_capela_da_lua.tscn`. O altar fica em `CapelaDaLua/AltarDeSalvamento`, à esquerda da lua crescente e longe da porta. O marcador `AoLadoDoAltar` está ao lado da pedra. `MenuDoPiloto` cobre a tela até a escolha. `ProgressoDoPiloto` lê e grava o arquivo.

No menu, a seta esquerda e a seta direita alternam “Novo jogo” e “Continuar”. Espaço confirma. “Continuar” só fica claro quando `tem_gravacao_valida` encontra um arquivo inteiro válido. “Novo jogo” deixa o jogador no vestíbulo, com Vida 3/3, a gema no lugar e a sentinela com 3 pontos. Essa escolha não apaga o arquivo.

Diante do altar, com os pés no chão, a base mostra “↑ Salvar progresso”. A seta para cima, num toque novo, chama `gravar`. Se a troca do arquivo termina bem, o texto passa a “Progresso salvo” e permanece enquanto a tecla fica presa. Se a escrita falha, o texto é “Não foi possível salvar” e o arquivo anterior continua no lugar. Ao caminhar até a porta, o aviso volta a “↑ Voltar ao vestíbulo”.

## Onde cada função entra

`ProgressoDoPiloto.reunir` lê, na cena aberta, a vida do `Jogador`, `salto_duplo_adquirido` e os pontos da `SentinelaDaGaleria`. Também grava a sala `capela_da_lua` e o marcador `AoLadoDoAltar`.

`ProgressoDoPiloto.validar` confere o arquivo inteiro antes de qualquer mudança: versão 1, as chaves esperadas, vida entre 1 e 3, salto duplo como verdadeiro ou falso, e a sentinela coerente. Derrotada só vale com 0 pontos. Viva só vale de 1 a 3. `ler_valido` lê o texto e entrega o resultado de `validar`.

`ProgressoDoPiloto.restaurar` chama `validar` e, só então, `_aplicar`. Os pés vão para `AoLadoDoAltar`, com Z = 0, velocidade zero e `encerrar_golpe`. A câmera copia `CapelaDaLua/Enquadramento`. O retorno de queda passa a ser o da capela. O indicador recebe a vida gravada, sem cura. Se o salto duplo está gravado, a gema sai. `SentinelaDaGaleria.aplicar_estado_gravado` devolve os pontos ou deita o corpo.

O altar não soma vida. `reunir` copia `pontos_de_vida` como está.

## O arquivo

O caminho no jogo é `user://catlenight_piloto_11.json`. Nesta máquina, sem desvio, `OS.get_user_data_dir()` respondeu:

`C:\Users\Raul\AppData\Roaming\Godot\app_userdata\Catlenight`

O arquivo pessoal ficaria em `C:\Users\Raul\AppData\Roaming\Godot\app_userdata\Catlenight\catlenight_piloto_11.json`. Os testes não escreveram aí. Cada processo de teste trocou `APPDATA` para `D:\Progr\catlenight\tests\dados_11`, e o Godot gravou em `tests\dados_11\Godot\app_userdata\Catlenight\`. Essa pasta está no `.gitignore`.

Exemplo gravado na primeira execução, com a sentinela ainda em 1 ponto:

```json
{
	"marcador": "AoLadoDoAltar",
	"sala": "capela_da_lua",
	"salto_duplo": true,
	"sentinela_derrotada": false,
	"sentinela_vida": 1,
	"versao": 1,
	"vida": 2,
	"vida_maxima": 3
}
```

A escrita monta um temporário, lê esse temporário de volta e só então troca o arquivo anterior. Uma pasta no lugar do temporário fez `gravar` devolver falso. O texto anterior permaneceu e a tela mostrou “Não foi possível salvar”.

## O que os processos mediram

A pasta isolada começou vazia. Todos os comandos usaram o Godot 4.7.2 de console e terminaram com `RESULTADO ok`.

Primeira execução, jogo novo:

```
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_altar_11.gd -- primeira
```

Com `APPDATA=D:\Progr\catlenight\tests\dados_11`. Coleta em “Vida 3/3”. Um contato deixou o jogador em 2. Dois golpes deixaram a sentinela em 1. O altar gravou uma vez. A porta mostrou “↑ Voltar ao vestíbulo”.

Segunda execução, outro processo:

```
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_altar_11.gd -- continuar
```

Pés em X = 47,950, Y = 0 e Z = 0. Câmera em X = 48. “Vida 2/3”. Salto duplo verdadeiro. Gema ausente. Lâmina oculta. Um golpe levou a sentinela de 1 a 0, com a vida do jogador ainda em 2. O processo fechou sem gravar. O arquivo continuou com sentinela 1.

Terceira execução, `de_novo`: a sentinela voltou com 1 ponto. Depois da derrota, a falha de escrita preservou o arquivo. O salvamento seguinte gravou `sentinela_derrotada` verdadeiro, `sentinela_vida` 0 e `vida` 2.

Quarta execução, `derrota`: os pés atravessaram o trecho até X = 30,457. “Vida 2/3” permaneceu.

`novo_jogo`, com esse arquivo ainda presente: “Vida 3/3”, gema presente, sentinela em 3, câmera no vestíbulo. O texto do arquivo não mudou.

`arquivo`: um JSON incoerente deixou “Continuar” apagado e não moveu a câmera. O texto “isto nao e json” também deixou “Continuar” apagado; o jogo novo ficou em vida 3 e os bytes do arquivo não mudaram. Sem arquivo, “Continuar” continuou apagado.

A captura, com a mesma `APPDATA` e a gravação de vida 2:

```
Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight res://tests/capturar_11.tscn
```

`11-altar-progresso-salvo.png`, 1280×720. A janela abriu por `tests/capturar_11.tscn`, não pelo F6. Os pés estão em X = 47,950 e Y = 0, ao lado do altar. O texto é “Progresso salvo”. O canto mostra “Vida 2/3”. A câmera está em X = 48.

Os testes das mecânicas compartilhadas:

- `tests/verificar_capela_10.gd`: `RESULTADO ok`
- `tests/verificar_inimigo_07.gd`: `RESULTADO ok`
- `tests/verificar_vida_08.gd`: `RESULTADO ok`

A sentinela ganhou `aplicar_estado_gravado`. O restante do encontro não mudou.

## Arquivos

- `scenes/verification/11_altar_de_salvamento.tscn`
- `scenes/environment/altar_de_salvamento.gd` e `scenes/environment/altar_de_salvamento.tscn`
- `scenes/progresso/progresso_do_piloto.gd`
- `scenes/interface/menu_do_piloto.gd` e `scenes/interface/menu_do_piloto.tscn`
- `scenes/enemies/sentinela_da_galeria.gd`
- `tests/verificar_altar_11.gd`, `tests/capturar_11.gd` e `tests/capturar_11.tscn`
- `MD-usario/prompts/11-altar-de-salvamento.md`
- `MD-usario/relatorios/11-altar-de-salvamento.md`
- `MD-usario/relatorios/evidencias/11-altar-progresso-salvo.png`
- `README.md`, `docs/ROADMAP.md`, `CLAUDE.md` e `.gitignore`

`jogador.gd`, a cena 10 e o F5 não foram editados. A partida pessoal não entra no Git.

## Como repetir

Abra `scenes/verification/11_altar_de_salvamento.tscn` e aperte F6. No menu, deixe “Novo jogo” marcado e aperte Espaço. Seta direita até a galeria, Espaço na plataforma e encoste na gema. Encoste uma vez na sentinela para ficar em Vida 2/3. Seta esquerda, sacada com dois Espaços, seta para cima na passagem. Ande até o altar. “↑ Salvar progresso” aparece. Solte a seta para cima e aperte de novo. “Progresso salvo” fica na tela enquanto a tecla estiver presa. Feche a janela.

Abra a mesma cena outra vez. Seta direita até “Continuar” e Espaço. Os pés voltam ao lado do altar, com a vida que foi gravada.

## Exercício

1. Abra `scenes/verification/11_altar_de_salvamento.tscn` e aperte F6.
2. Escolha “Novo jogo” com Espaço. Chegue ao altar com Vida 2/3 e grave. Esse 2 vem do contato com a sentinela e entra no arquivo por `reunir`.
3. Feche e abra de novo. Escolha “Novo jogo”. O canto mostra Vida 3/3. Esse 3 vem de `Jogador._ready`, que copia `pontos_maximos`. O arquivo não é lido.
4. Feche antes de chegar ao altar. O arquivo continua com vida 2.
5. Abra outra vez e escolha “Continuar”. O canto mostra Vida 2/3. Esse 2 vem de `validar` e de `restaurar`, que colocam no indicador o valor do arquivo.

## Pendências

O F6 no editor continua pendente. A janela desta etapa foi aberta pelo script de captura. O restante da interface, outras habilidades, a animação da espada, a roupa, o equipamento e o áudio continuam para as próximas tarefas.
