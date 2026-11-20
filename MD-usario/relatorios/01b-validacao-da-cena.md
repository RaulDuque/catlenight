# Relatório — 01b, validação da cena principal

Data: 19/11/2026. A Tarefa 01 não foi reescrita. Este arquivo registra a execução da fundação que já existia.

Nenhuma correção na cena ou em `project.godot` foi necessária. O arquivo da cena continua com `size = 8.0`.

## Configuração conferida antes de rodar

`project.godot` aponta a cena principal para `res://scenes/verification/main.tscn`. O nome provisório segue Catlenight. A feature declarada é `4.7`, com Forward Plus. A janela pedida é 1280×720.

A busca da Tarefa 01 não tinha encontrado um executável. Ele continuava ausente no PATH. O editor usado abaixo foi baixado nesta validação.

## Versão oficial

O arquivo oficial de versões do site do Godot, `_data/versions.yml`, contém:

- nome: `4.7.2`
- tipo: `stable`
- data: `18 August 2026`

A 4.7.2 indicada no relatório 01 está disponível. A versão do projeto não foi alterada.

## Executável

Pasta, fora do projeto: `C:\Users\Raul\Tools\Godot\4.7.2-stable`

Arquivo baixado: `Godot_v4.7.2-stable_win64.exe.zip`, do release oficial `4.7.2-stable` no repositório `godotengine/godot`. É a edição padrão, sem .NET.

SHA-512 publicado em `SHA512-SUMS.txt` para esse ZIP:

`83decd58fdf67b9d657958a1ae6bf1929c20785315a81effe245874cdc57acb709bf868e00778a96984338c1b29dafdb453c6847747694621c6ecf5da2259993`

O hash calculado no arquivo baixado foi o mesmo.

O ZIP traz dois executáveis. O de console é o que imprime no terminal. O outro abre o editor sem console.

Comando:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --version`

Saída real:

`4.7.2.stable.official.ed1daf0bf`

## Importação

Comando:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight --import`

Resultado: código de saída 0. O Godot escaneou o projeto, importou `icon.svg` e carregou o editor sem mensagem de erro. Surgiu `icon.svg.import`, que guarda o ajuste de importação do ícone, e a pasta `.godot\`, que é cache e já está no `.gitignore`.

`project.godot` e `scenes/verification/main.tscn` não foram reescritos.

## Execução pelo terminal

Comando, ainda sem janela:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight --quit-after 30`

Resultado: código de saída 0. A única linha além do cabeçalho do motor foi vazia de erro. O comando não recebeu o caminho da cena. Quem escolheu a cena foi `run/main_scene` dentro de `project.godot`.

## Janela

Comando:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight --write-movie C:\Users\Raul\Tools\Godot\4.7.2-stable\capture\frame.png --quit-after 120`

O `--path` é o ponto de entrada. De novo, a cena não foi passada na linha de comando. `--quit-after 120` fechou a janela depois de 120 quadros. Isso não é o teste da tecla F5.

Saída relevante:

`Vulkan 1.4.357 - Forward+ - Using Device #0: NVIDIA - NVIDIA GeForce RTX 3060 Ti`

`Movie Maker mode enabled, recording movie in 1280×720 @ 60 FPS...`

Código de saída: 0.

## Inspeção visual

A imagem guardada é um quadro renderizado por essa execução, em 1280×720:

`MD-usario/relatorios/evidencias/01b-cena-principal.png`

O que a imagem mostra:

- O chão aparece como uma barra horizontal escura, com folga dos dois lados e espaço escuro acima. Está enquadrado, não ocupa a tela inteira.
- O bloco vermelho aparece de lado, no centro, e a base encosta no topo do chão. Não há vão visível entre os dois.
- O vermelho do bloco se separa do fundo quase preto e do cinza do chão.
- O arquivo da cena, depois da execução, continua com `CameraLateral` em `size = 8.0`. O enquadramento observado é o original: a barra de 12 m cabe na largura visível de uma câmera com altura 8 m em 16:9.

## F5

Não testado. Nenhuma tecla F5 foi pressionada no editor. A janela veio do executável, com o projeto como ponto de entrada.

## Caminho até a primeira imagem

1. O executável recebe a pasta do projeto.
2. Ele lê `project.godot` nessa pasta.
3. A chave `run/main_scene` diz qual cena abrir quando o projeto roda.
4. Essa cena traz a `CameraLateral` com `current = true`. É essa câmera que desenha o quadro.
5. `window/size/viewport_width` e `viewport_height` definem 1280×720, o tamanho da captura.

Se `run/main_scene` apontasse para outro arquivo, o mesmo comando mostraria outra cena. Por isso a execução sem o caminho da cena na linha de comando também testa essa configuração.
