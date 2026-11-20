# Decisões

Registro do que foi escolhido na fundação, por quê, e o que muda se a decisão for revista. Data: 19/11/2026.

## D001 — Nome provisório Catlenight

A pasta do projeto já se chama `catlenight`. O nome exibido no Godot ficou igual, para a janela, a pasta e os textos apontarem para a mesma coisa.

Pode ser trocado em **Project > Project Settings > Application > Config > Name**. Isso altera `config/name` em `project.godot`. Renomear a pasta é outro passo e não é necessário para trocar o título.

## D002 — Godot 4.7 estável e GDScript

A tarefa pede Godot 4 estável e GDScript. A estável publicada no site oficial em 19/11/2026 é a **4.7.2** (18/08/2026). O `project.godot` declara a feature `4.7` e o renderizador **Forward Plus**, que é o padrão do Godot 4 para 3D.

A build .NET não foi escolhida porque ela existe para C#. GDScript já vem na build padrão.

Impacto: abrir o projeto numa 4.8 beta, ou numa 4.x mais antiga, pode fazer o editor reescrever `config/features`. A execução desta etapa não confirmou um binário local; veja D007.

## D003 — Mundo 3D, câmera lateral ortográfica, plano Z = 0

Cenário, corpo, luz e física ficam em 3D para a profundidade existir de verdade. A câmera ortográfica tira a perspectiva, então o lado da tela não "afunda" com a distância.

X é o chão da esquerda para a direita, Y é a altura e Z é a profundidade. A câmera desta cena está em Z = 14, com rotação zerada, olhando para -Z. O quadro é o plano XY.

O plano de jogo desta fase de teste é Z = 0. O bloco está nesse Z. O controlador futuro deve prender o personagem ao Z da fase; isso ainda não existe em código.

## D004 — Formas geométricas provisórias

Não há arte final. O chão é um paralelepípedo cinza e, na fundação, o personagem era um bloco vermelho escuro. As cores serviam para separar chão e corpo na verificação. Não há asset de Castlevania nem de outro jogo. A Tarefa 04 substituiu o bloco pelo manequim; o registro desta decisão fica como o ponto de partida.

## D005 — Cena única, sem script

A cena `scenes/verification/main.tscn` é a cena principal. Ela contém só o que o teste pede: chão estático, malha, colisão, bloco visual, luz direcional e câmera.

O bloco é um `MeshInstance3D`. Ele não cai e não anda. A colisão do chão fica pronta para a próxima tarefa, mas ninguém a usa ainda. Não foi criado um script vazio.

## D006 — Gitignore no formato do Godot 4.7, repositório ainda não criado

O `.gitignore` começa com o texto que o Godot 4.7.2 grava ao gerar metadados de Git:

- `.godot/` — cache do editor e arquivos importados;
- `/android/` — pasta criada numa exportação Android, que este projeto ainda não tem.

Foi acrescentado `*.translation`, pedido pela documentação estável do Godot 4.1+ para traduções binárias geradas a partir de CSV. Também ainda não existem.

O `.gitattributes` é o outro arquivo que o mesmo gerador do Godot 4.7.2 cria. Ele força fim de linha LF nos textos, o que evita o Git marcar arquivo como modificado só por causa do Windows.

O Git não estava instalado. O repositório local não foi inicializado. Não há remoto, commit nem push.

## D007 — Execução marcada como pendente

O comando `godot` não foi reconhecido. A busca por `Godot*.exe` no PATH, em pastas de instalação comuns, no Steam e até dois níveis em `C:\Users\Raul` e `D:\` não achou o editor. Um log de outro projeto, "Survival Game", de 13/10/2026, menciona Godot 4.7.2, mas o executável correspondente não estava acessível nesta sessão.

Sem o binário, a importação, o carregamento da cena e a janela do F5 ficam pendentes. O que deu para conferir foi o texto dos arquivos. O modo de instalar a 4.7.2 está no `README.md`.

## D008 — Pasta `MD-usario`

Os prompts e relatórios ficam em `MD-usario/`, com essa grafia, porque foi o caminho pedido. Nenhum pacote foi usado para isso: são arquivos Markdown.

## D010 — Origem do jogador nos pés

O `CharacterBody3D` usa o ponto local (0, 0, 0) como os pés. A malha e a colisão têm 1,70 m e o centro em Y = 0,85, então as duas bases coincidem com a origem. O modelo futuro do Blender entra como filho de `Visual`, com a origem nos pés e 1 unidade igual a 1 metro.

## D011 — Pulo por pressionamento, parada imediata

O exemplo oficial `cubio.gd` aplica o pulo com `is_action_pressed` depois de `move_and_slide()`. Isso repetiria o salto se Espaço continuasse segurado. Aqui o pulo usa `is_action_just_pressed` junto com `is_on_floor()`, antes de `move_and_slide()`. Segurar Espaço na aterrissagem não cria outro salto.

A caminhada grava a velocidade horizontal direto da seta. Soltar a seta zera essa velocidade no quadro seguinte, sem desaceleração.

O plano Z = 0 fica travado de dois jeitos: a propriedade `axis_lock_linear_z` do corpo e, depois da colisão, a função `_travar_no_plano_z()`.

## D012 — Skill local de GDScript

A skill `godot-gdscript-patterns` não estava no projeto. A licença do repositório `wshobson/agents` é MIT, então a cópia entrou em `.claude/skills/godot-gdscript-patterns/`, com `LICENSE` e `ORIGEM.md`. A revisão obtida é `51b6e0b507aa7942e36c6d33a94fc63aefc53d07`, de 28 de setembro de 2026. Ela orienta cena reutilizável e GDScript tipado. O jogo não a executa.

## D013 — Retorno ao cair da sala

O chão tem bordas. Se o corpo passa de Y = -2, `_retornar_se_cair_da_sala()` devolve o jogador à posição em que nasceu e zera a velocidade. O valor aparece no Inspector, no grupo Queda.

## D014 — Blender 5.3.0 fora do projeto, colisão no Godot

Em 19/11/2026 não havia Blender instalado. A estável publicada no site oficial era a 5.3.0, de 10/11/2026. O ZIP portátil para Windows x64 foi baixado de `download.blender.org`, o SHA-256 conferiu, e o executável ficou em `C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe`. A saída de `--version` foi `Blender 5.3.0`, hash `02f0899d78e3`.

O arco é gerado por `arte-fonte/blender/criar_arco_de_pedra.py`, salvo em `.blend` e exportado em GLB com 1 unidade = 1 metro. A pasta `arte-fonte/` tem `.gdignore`, então o Godot importa só o GLB. As colisões são caixas em `scenes/environment/arco_de_pedra.tscn`. Uma nova exportação troca o visual e deixa as caixas no lugar.

## D015 — Direção no nó Visual, frente em +X

O manequim da Tarefa 04 olha para a direita da tela com `Visual.rotation.y` em 0 e para a esquerda com essa rotação em PI. Eixo horizontal zero, inclusive no pulo parado, não mexe na rotação. A caixa `Colisao` é irmã de `Visual`, então a virada não gira o corpo físico nem desloca os pés.

No Blender a frente é +X e a direita anatômica é −Y. Depois do glTF, a frente continua em +X no Godot e a direita anatômica fica em +Z, do lado da câmera quando o perfil aponta para a direita. O script `criar_protagonista_base.py` reconstrói o `.blend`. Uma alteração feita à mão vai ao jogo pela exportação glTF, com os modificadores aplicados.

## D016 — Hunyuan3D-2mini fora do jogo, só geometria

A Tarefa 04-A pediu o repositório oficial Hunyuan3D-2 para um piloto de personagem. A licença é a Tencent Hunyuan 3D 2.0 Community License, gratuita para este estudo. Ela não é uma licença MIT: distribuir o modelo, ou usar o resultado num produto com mais de 1 milhão de usuários ativos no mês anterior, exige o texto da licença e, nesse segundo caso, um pedido à Tencent.

A ferramenta ficou em `D:\Tools\Hunyuan3D`, com Python 3.13.17 em `D:\Tools\Python313`. O modelo desta etapa é o `tencent/Hunyuan3D-2mini`, subpasta `hunyuan3d-dit-v2-mini`, só geometria. A textura não foi compilada. O conjunto que carregou os pesos foi torch 2.11.0+cu128, transformers 4.46.3 e diffusers 0.32.2. O manequim da Tarefa 04 continua sendo o visual do `Jogador`.

## D009 — Godot 4.7.2 oficial, fora do projeto

Em 19/11/2026, o arquivo oficial `versions.yml` do site do Godot listou a 4.7.2 como estável, publicada em 18 de agosto de 2026. A versão indicada no relatório 01 estava correta, então `project.godot` não mudou de linha.

O ZIP padrão para Windows x86_64 foi baixado do release oficial, o SHA-512 conferiu com `SHA512-SUMS.txt`, e os executáveis ficaram em `C:\Users\Raul\Tools\Godot\4.7.2-stable`. Eles não entram na pasta do jogo. A saída real de `--version` foi `4.7.2.stable.official.ed1daf0bf`.
