# 15-A — Referência visual da abertura de Richter

Data: 20/11/2026. A pasta `D:\Progr\csotn` existia e estava vazia. Nada foi reaproveitado de uma instalação anterior.

## Versão instalada

A release atual no GitHub é a tag `v1.2.0p`, publicada em 14/11/2026. A página da release chama o pacote de pré-release da 1.0.0. A API marca `prerelease` como falso. Não há uma 1.0 estável acima dela. O README confirma que a versão estável 1.0 ainda não saiu.

A máquina é Windows x64. O pacote escolhido é o Windows x64.

| | |
| --- | --- |
| Tag | `v1.2.0p` |
| Pacote | `SymphonyRecomp-v1.2.0p-windows-x64.zip` |
| URL | https://github.com/BlackLabelHQ/SymphonyRecomp/releases/download/v1.2.0p/SymphonyRecomp-v1.2.0p-windows-x64.zip |
| SHA-256 publicado | `3d3e5f0a46896737a6a0a3bcddbc9b1b0c58e0d5f91e0de16bd44f64451ef662` |
| SHA-256 do arquivo baixado | o mesmo |

O ZIP foi extraído em `D:\Progr\csotn`. A cópia baixada ficou em `D:\Progr\csotn\_download`.

A release exige o runtime .NET 10. Ele não estava instalado. Entrou o pacote `Microsoft.DotNet.Runtime.10`, versão 10.0.15. O `sotn.runtimeconfig.json` pede `Microsoft.NETCore.App` 10.0.0. O pacote já traz `soft_oal.dll`, e o programa abriu sem um OpenAL separado.

## Como abrir de novo

O executável é `D:\Progr\csotn\sotn.exe`. A janela se chama `SymphonyRecomp v1.2.0p`. O caminho do disco fica em `D:\Progr\csotn\settings.json`, na chave `system.discPath`. Nesta primeira abertura ela ficou vazia.

## O que o primeiro uso fez

| Pergunta | Resultado |
| --- | --- |
| O pacote foi instalado? | Sim. Extraído em `D:\Progr\csotn` |
| O programa abriu? | Sim. A janela apareceu e o aviso de beta foi confirmado |
| O jogo chegou ao prólogo? | Não |

Depois do aviso, a janela mostrou o diálogo **Imagem do disco não encontrada**, com o texto **Informe o caminho do arquivo de disco do jogo.** O botão **Procurar...** abre o seletor **Abrir**, e o tipo pedido aparece como **Imagem de disco**. Não selecionei arquivo nenhum.

Procurei `.cue` e `.chd` com Symphony ou Castlevania em `D:\Progr`, em Downloads, em Documentos e na Área de Trabalho. Não havia imagem. Os originais não foram alterados porque não estavam nesses lugares.

## O que falta para retomar

Coloque a cópia norte-americana NTSC, sem renomear os originais se eles já tiverem outro nome no lugar de onde você os guarda. A pasta preparada para a cópia de trabalho é `D:\Progr\csotn\disc`.

Para BIN/CUE, os nomes que o README da release usa são:

- `Castlevania - Symphony of the Night (USA) (Track 1).bin`
- `Castlevania - Symphony of the Night (USA) (Track 2).bin`
- `Castlevania - Symphony of the Night (USA).cue`

O CUE precisa apontar para esses dois nomes reais. O modelo publicado no README é:

```
FILE "Castlevania - Symphony of the Night (USA) (Track 1).bin" BINARY
  TRACK 01 MODE2/2352
    INDEX 01 00:00:00
FILE "Castlevania - Symphony of the Night (USA) (Track 2).bin" BINARY
  TRACK 02 AUDIO
    INDEX 00 00:00:00
    INDEX 01 00:02:00
```

Se a cópia for CHD, um arquivo só basta. Abra `D:\Progr\csotn\sotn.exe`, clique em **Procurar...** e selecione o `.cue` ou o `.chd`. As capturas da abertura, quando o jogo rodar, vão para `D:\Progr\csotn\referencias\abertura-richter\`. Essa pasta foi criada e está vazia.

## O que não foi medido no jogo

O prólogo não rodou. Não há resolução da área de jogo, não há proporção descontada de barras pretas e não há os três quadros. A altura de Richter como porcentagem da área de jogo continua sem medida. As opções de letterbox e widescreen da release não foram lidas numa imagem em movimento.

A cena 15 já existe: `scenes/verification/15_escadaria_exterior.tscn`. As capturas reais são `MD-usario/relatorios/evidencias/15-primeira-vista-do-castelo.png` e `15-subida-ao-portao.png`, as duas em 1280×720.

Medido nesses PNGs, só na figura clara do manequim:

- No nascimento, o corpo vai de Y = 464 a Y = 613. Altura 149 px, 20,7% dos 720 px.
- No meio da escada, o corpo vai de Y = 363 a Y = 512. A mesma altura, 149 px.
- O núcleo claro do portão, nos dois quadros, vai de X = 848 a X = 1206 e de Y = 112 a Y = 459.

Isso é medida da nossa cena. Não é medida de Richter.

## Três decisões para a tarefa de arte

A cena 15 não foi alterada.

1. A escala do corpo fica como está até a medida de Richter existir. O que foi medido aqui é o manequim a 20,7% da altura do quadro. O que falta observar é a altura dele na área efetiva do prólogo, com as barras pretas fora da conta. A conferência, na câmera lateral de 1280×720, é repetir essa contagem no quadro do nascimento e no quadro exterior do jogo, lado a lado.

2. O portão continua no primeiro quadro. O que foi medido é o núcleo claro já visível à direita, a partir de X = 848. O que falta observar é o momento em que o portão entra no quadro enquanto Richter sobe, e se a câmera anda com ele ou fica parada. A conferência é o PNG do nascimento: o vão precisa continuar sendo a região mais clara, à direita dos degraus.

3. A mureta continua atrás das pernas. O que foi observado no PNG do meio da escada é o corpo claro inteiro, com a mesma altura de 149 px, sobre os degraus. O que falta observar é o limiar e a sala do trono: o primeiro ponto que puxa o olhar, e o papel das colunas, das cortinas e da luz. A conferência do limiar, quando o quadro existir, é ver se a cabeça e o tronco ainda se leem contra o vão em 1280×720. Até lá, `EscadariaExterior/Lance/Degraus` e `Lance/Rampa/Colisao` permanecem como a etapa 15 os deixou.
