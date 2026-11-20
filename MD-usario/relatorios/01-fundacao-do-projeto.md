# Relatório — Tarefa 01, fundação e cena de verificação

Data: 19/11/2026. Etapa encerrada só até onde a pasta e as ferramentas desta máquina permitiram. A execução com F5 continua pendente.

## O que a pasta tinha antes

`D:\Progr\catlenight` estava vazia. Nada foi apagado.

## Arquivos criados

| Arquivo | Função |
| --- | --- |
| `project.godot` | Projeto Godot. Nome provisório Catlenight. Cena principal `res://scenes/verification/main.tscn` |
| `icon.svg` | Ícone geométrico próprio: barra e bloco |
| `scenes/verification/main.tscn` | Cena 3D de verificação |
| `.gitignore` | Ignora o cache do Godot 4, no formato do gerador da 4.7.2, mais `*.translation` |
| `.gitattributes` | Fim de linha LF, o par que o Godot 4.7.2 grava junto com o `.gitignore` |
| `README.md` | Objetivo, versão, instalação, abertura e execução |
| `CLAUDE.md` | Regras de trabalho, eixos e limite da etapa |
| `docs/GAME_DESIGN.md` | Visão, pilares e primeiro objetivo jogável |
| `docs/ROADMAP.md` | Etapas, critérios e status real |
| `docs/DECISIONS.md` | Decisões, motivo e impacto |
| `MD-usario/prompts/01-fundacao-do-projeto.md` | Cópia integral do prompt, gravada antes do restante da implementação |
| `MD-usario/relatorios/01-fundacao-do-projeto.md` | Este relatório |

Nenhum arquivo antigo foi modificado, porque não havia nenhum. Nenhum pacote, extensão, plugin ou skill foi adicionado.

## Versões de fato verificadas

**Godot, por execução: não verificado.** `godot` e `godot4` não existem no terminal. Nenhum `Godot*.exe` apareceu no PATH, nas pastas comuns de instalação, nos atalhos, no Steam ou numa busca de dois níveis em `C:\Users\Raul` e em `D:\`.

Consulta ao site oficial em 19/11/2026: a estável atual é **Godot 4.7.2** (18/08/2026), build padrão para Windows x86_64. O projeto foi escrito para essa linha (`4.7`, Forward Plus, GDScript). A build .NET não é necessária.

Evidência antiga, não reexecutada: o log de outro projeto, "Survival Game", em 13/10/2026, começa com `Godot Engine v4.7.2.stable.official.ed1daf0bf`. O executável desse log não foi encontrado agora.

**Git, por execução: não instalado.** `git --version` respondeu que o comando não é reconhecido. Os caminhos padrão do Git for Windows também não existem. Não há pasta `.git`. O repositório local não foi criado. Não há remoto nem push.

## Cena

Caminho no editor, painel FileSystem: `scenes/verification/main.tscn`.

Árvore:

```
Verificacao (Node3D)
├── Chao (StaticBody3D)
│   ├── Malha (MeshInstance3D)
│   └── Colisao (CollisionShape3D)
├── MarcadorPersonagem (MeshInstance3D)
├── Luz (DirectionalLight3D)
└── CameraLateral (Camera3D)
```

Conta feita no arquivo, sem abrir o Godot: o topo do chão e a base do bloco se encontram em Y = 0. O bloco está em Z = 0. A câmera está em Z = 14, com rotação zerada, olhando para -Z, então o quadro é o plano XY. `projection = 1` é o modo ortográfico. `size = 8.0` é o valor original do tamanho vertical, em metros.

## Nós e a propriedade para testar cada um

Abra a cena, clique no nó na árvore **Scene** e use o **Inspector**. Os nomes de propriedade abaixo são os do editor em inglês, que é o padrão. Entre parênteses, o equivalente se o editor estiver em português.

**Verificacao** — raiz. Só agrupa os outros nós. Não desenha e não colide. Propriedade: Transform > Position (Posição). Valor original: `0, 0, 0`. Mudar esse valor desloca a cena inteira.

**Chao** — corpo físico imóvel. A física futura vai tratá-lo como chão. Propriedade: Transform > Position > Y. Valor original: `-0.5`. Junto com a altura 1 da caixa, isso deixa o topo em Y = 0. Aumentar o Y faz o chão subir.

**Malha**, filha de Chao — a parte visível. Propriedade: Mesh > Size (Tamanho), no recurso BoxMesh. Valor original: X `12`, Y `1`, Z `6`. X é a largura na tela, Y a espessura, Z a profundidade para dentro da cena. A câmera lateral mostra sobretudo X e Y.

**Colisao**, filha de Chao — a forma que a física usa. No jogo ela fica invisível; no editor aparece como contorno. Propriedade: Shape > Size. Valor original: `12, 1, 6`, igual ao da malha. Se só a malha mudar, o desenho muda e a colisão continua no tamanho antigo.

**MarcadorPersonagem** — bloco vermelho escuro no lugar do futuro personagem. Não tem colisão e não se move. Propriedade: Transform > Position > Y. Valor original: `0.85`. A altura da caixa é 1.7, então a base fica em Y = 0, encostada no chão. Subir o Y faz o bloco flutuar. Z original: `0`, o plano desta fase.

**Luz** — luz direcional, o equivalente a um sol distante. A posição quase não muda o resultado; a rotação muda de onde a luz chega. Propriedade: Shadow Enabled (Sombra ativada). Valor original: ligada. Desmarcar e rodar de novo tira a sombra do bloco sobre o chão.

**CameraLateral** — câmera ativa (`current` ligado). Propriedade: Projection (Projeção) = Orthogonal (Ortogonal). A propriedade do exercício é **Size** (Tamanho). Valor original: **8**. Esse número é a altura visível, em metros. Com a janela em 1280×720, a largura visível fica perto de 14,2 m, o bastante para ver o chão de 12 m com uma folga nas laterais. Afasta a câmera em Z não muda o zoom ortográfico. Quem muda o enquadramento é Size.

## Verificação automática

Feita por leitura dos arquivos, em 19/11/2026:

- `project.godot` contém `config_version=5`, o nome Catlenight, a feature `4.7`, Forward Plus e a cena principal correta.
- A cena existe e contém, uma vez cada: `Verificacao`, `Chao` como `StaticBody3D`, `Malha`, `Colisao` com `BoxShape3D`, `MarcadorPersonagem`, `Luz` com sombra, `CameraLateral` com `projection = 1`, `current = true` e `size = 8.0`.
- A malha do chão e a forma de colisão usam o mesmo `Vector3(12, 1, 6)`.
- Topo do chão = 0. Base do bloco = 0.
- `git`, `godot` e `godot4` ausentes. Pasta `.git` ausente.

## Observação em tela

Nenhuma. O Godot não foi aberto e a janela do jogo não foi executada. Não há captura desta cena.

## O que ainda falta conferir

1. Instalar o Godot 4.7.2 padrão, como descrito no `README.md`.
2. Importar `D:\Progr\catlenight\project.godot`.
3. Pressionar F5 e confirmar, com os olhos: vista lateral, chão visível e bloco apoiado sobre ele.
4. Na primeira abertura, o Godot cria `.godot\` e pode criar `icon.svg.import`. A pasta `.godot` fica de fora do Git. O `.import` ao lado do ícone, quando existir, deve ser guardado.
5. Instalar o Git quando quiser histórico local. A inicialização do repositório ainda não foi feita. Publicação, remoto e push continuam esperando um pedido explícito.

## Exercício de cinco minutos

Objetivo: ver o que o tamanho ortográfico faz e devolver a câmera ao valor original.

1. Importe e abra o projeto no Godot 4.7.2.
2. No painel FileSystem, abra `scenes/verification/main.tscn` com dois cliques.
3. Na árvore Scene, clique em `CameraLateral`.
4. No Inspector, em Projection / Projeção, ache **Size** / **Tamanho**. Confira que está **8**.
5. Troque para **14**.
6. Pressione **F6** para rodar a cena aberta. A barra de chão e o bloco devem aparecer menores, e deve sobrar mais espaço vazio em volta. A vista continua de lado.
7. Pare o jogo com o botão de parar, ou com **F8**.
8. Volte **Size** para **8**.
9. Se a aba da cena estiver marcada como alterada, salve com **Ctrl+S**.
10. Rode de novo com **F6**. O enquadramento deve voltar ao da primeira execução.

Não mova a câmera em Z durante o exercício. No modo ortográfico, esse deslocamento não é o zoom.
