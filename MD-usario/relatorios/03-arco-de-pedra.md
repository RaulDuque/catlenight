# Relatório — Tarefa 03, arco de pedra

Data: 19/11/2026. Godot: `4.7.2.stable.official.ed1daf0bf`, em `C:\Users\Raul\Tools\Godot\4.7.2-stable`. Blender: `5.3.0`, hash `02f0899d78e3`, compilado em 10/11/2026, em `C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe`.

## O que foi feito

O primeiro arco do castelo está no chão, antes da plataforma. Ele foi modelado em metros no Blender, exportado em GLB e instanciado numa cena reutilizável. As colisões ficam nessa cena, não dentro do GLB. O bloco vermelho da Tarefa 02 atravessa o vão andando.

Não havia Blender na máquina. O ZIP portátil oficial `blender-5.3.0-windows-x64.zip` foi baixado de `https://download.blender.org/release/Blender5.3/`. O SHA-256 conferiu com o arquivo oficial: `3ac567a63d59d9934f7b9213bfb27ba05760e1fb366f8f55c381573ec3eabfa8`. O programa ficou fora do projeto.

## Arquivos

Criados:

- `arte-fonte/.gdignore`
- `arte-fonte/blender/criar_arco_de_pedra.py`
- `arte-fonte/blender/arco_de_pedra.blend`
- `assets/models/environment/arco_de_pedra.glb`
- `assets/models/environment/arco_de_pedra.glb.import`
- `scenes/environment/arco_de_pedra.tscn`
- `tests/verificar_arco.gd` e `tests/verificar_arco.gd.uid`
- `tests/capturar_arco.gd`, `tests/capturar_arco.gd.uid` e `tests/capturar_arco.tscn`
- `MD-usario/prompts/03-arco-de-pedra.md`
- `MD-usario/relatorios/03-arco-de-pedra.md`
- `MD-usario/relatorios/evidencias/03-arco-no-blender.png`
- `MD-usario/relatorios/evidencias/03-personagem-sob-o-arco.png`

Alterados: `scenes/verification/main.tscn`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `CLAUDE.md` e `README.md`.

O controlador, as ações, o tamanho do jogador e o `Size` da câmera continuam os da Tarefa 02.

## Como a peça está montada

O script `criar_arco_de_pedra.py` constrói a pedra e grava o `.blend` e o GLB. Para repetir a geração inteira:

```
C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe --background --python D:\Progr\catlenight\arte-fonte\blender\criar_arco_de_pedra.py
```

Esse comando recria o arquivo. Ele não serve para o exercício de cor, mais abaixo: lá a mudança é feita no Blender e só o GLB é exportado de novo.

No Blender, Z é a altura. A origem do vazio `ArcoDePedra` é o centro da passagem, no piso. O exportador glTF entrega isso ao Godot com Y para cima e 1 unidade = 1 metro. A pasta `arte-fonte/` tem `.gdignore`, então o Godot não importa o `.blend`.

A cena `scenes/environment/arco_de_pedra.tscn` tem dois filhos:

- `Visual` é a instância do GLB. Não tem colisão.
- `Colisao` é um `StaticBody3D`. Cada pedra grossa da estrutura tem um `CollisionShape3D` com um `BoxShape3D`. O vão central não tem caixa.

Na cena principal, o nó `ArcoDePedra` está em X = -2,05 e Y = 0, com rotação Y = 14 graus. O nascimento continua em (-3,2, 1, 0). A plataforma continua de X = 0,2 a X = 4,2. O arco fica no chão entre os dois. Um pilar fica em Z positivo e o outro em Z negativo.

Para mexer na posição sem abrir o Blender: abra `scenes/verification/main.tscn`, clique em `ArcoDePedra` e use **Transform > Position** e **Transform > Rotation**. A rotação Y está em graus.

Para alargar uma caixa de colisão: abra `scenes/environment/arco_de_pedra.tscn`, clique no `CollisionShape3D` (por exemplo `PilarFrente`) e mude **Shape > Size**. Uma nova exportação do GLB não apaga essas caixas.

## Medidas

Tudo em metros.

| Medida | Valor |
| --- | --- |
| Abertura entre as faces internas dos pilares | 2,40 |
| Bases, um pouco mais largas | 0,58 × 0,56 × 0,22 |
| Cada fiada do pilar | 0,42 × 0,38 |
| Capitel | 0,50 × 0,50 × 0,18 |
| Espessura das cunhas | 0,52 |
| Espessura da pedra central | 0,60 |
| Linha de onde o arco nasce | 2,48 |
| Raio interno do arco ogival | 2,40 |
| Ponta inferior da pedra central | 4,22 |
| Topo da pedra central | 5,12 |
| Chanfro das arestas | 0,012 |
| Altura livre na faixa do corpo, depois de girar | 4,227 |
| Distância entre as faces internas depois dos 14° | 2,33 |

A faixa do corpo usada na conta é 0,80 m em X e 0,60 m em Z, um pouco maior que os 0,50 m reais de profundidade. O ponto mais baixo dessa faixa, na malha já importada e girada, é a ponta da pedra central, a 4,227 m. O corpo de 1,70 m passa com folga. As bases avançam cerca de 9 cm para dentro do vão, só na altura do piso; o tronco não as alcança.

A caixa do modelo importado, já na cena, vai de X = -2,735 a -1,364, de Y = 0 a 5,115 e de Z = -1,691 a 1,691. Y = 0 confirma que as bases encostam no piso e que a escala não virou centímetros nem multiplicou por cem.

As cores, no seletor do Blender e no albedo do Godot, são:

| Material | Hex |
| --- | --- |
| `PedraClara` | `#C9C0B4` |
| `PedraMedia` | `#A69C90` |
| `PedraEscura` | `#7A736C` |
| `PedraCentral` | `#C6A36A` |

A rugosidade exportada é 0,84. Os tons ficam próximos, e as juntas de alguns centímetros separam as pedras na vista de 1280×720.

Os 14 graus foram escolhidos olhando a `CameraLateral`. Com menos giro o arco vira uma coluna só. Com mais giro o pilar da frente cobre o bloco por mais tempo. Em 14 graus a ogiva e a pedra central continuam reconhecíveis, e o bloco vermelho aparece ao lado do arco antes de entrar e dentro do vão durante a travessia.

## Testes

Importação com `--import`: código 0. O GLB entrou sem erro.

`tests/verificar_arco.gd`, com a física e as ações `direita` e `esquerda`:

| Medida | Valor |
| --- | --- |
| X ao entrar, indo para a direita | -2,558 |
| X ao sair, indo para a direita | -1,450 |
| X ao entrar na volta | -1,508 |
| X ao sair na volta | -2,617 |
| Altura dos pés durante a travessia | 0,0003 |
| Maior afastamento em Z | 0 |
| Raio da altura do pilar até `PilarFrente` | acertou o `StaticBody3D` `Colisao` |
| Raio em Y = 1,05 e Z = 0, atravessando o vão | livre |
| Resultado | ok |

A zona usada nessa conta é o centro do arco mais ou menos 0,55 m, um pouco maior que a espessura da passagem.

`tests/verificar_movimento.gd` rodou de novo depois do arco e repetiu os números da Tarefa 02: pouso em Y = 0,0003, pico do pulo em 1,5904, plataforma em X = 2,108 e Y = 0,701, volta ao chão em X = 5,958, Z = 0, retorno à borda ok. Código de saída 0. O arco não atrapalhou o percurso antigo.

O F5 foi pressionado no editor, na cena principal. A janela `Catlenight (DEBUG)` abriu em 1280×720. O bloco caiu à esquerda do arco. A seta direita levou o bloco para debaixo da ogiva. A saída mostrou o cabeçalho do motor, a RTX 3060 Ti e `Debugging process stopped`, sem erro de script. O jogo foi parado com F8 e o editor foi fechado.

Capturas:

- `MD-usario/relatorios/evidencias/03-arco-no-blender.png` — o modelo em três quartos, com as pedras separadas.
- `MD-usario/relatorios/evidencias/03-personagem-sob-o-arco.png` — a câmera lateral do jogo, com o bloco sob o arco. Esse quadro saiu de `tests/capturar_arco.tscn`, que instancia a cena principal e anda com a ação `direita` até o centro do vão.

## Primeira abertura do .blend

1. Abra o Blender em `C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe`.
2. **File > Open** e escolha `D:\Progr\catlenight\arte-fonte\blender\arco_de_pedra.blend`.
3. Se a vista não mostrar o arco inteiro, pressione Home. Isso enquadra tudo.
4. No Outliner, canto superior direito, clique numa pedra, por exemplo `PilarFrente1` ou `CunhaAFrente`. Ela fica selecionada em laranja.
5. Pressione N. Na aba **Item**, **Dimensions** é o tamanho da pedra em metros. **Location** é o centro dela. As unidades da cena estão em metros.
6. A origem da passagem é o vazio `ArcoDePedra`. Clique nele. A Location dele é 0, 0, 0, no centro do vão e na altura do piso. Os eixos pequenos desse vazio marcam esse ponto. Em **Viewport Overlays** (os dois círculos no canto da vista), ligue **Object Origins** para ver o ponto laranja de cada objeto.
7. Cada pedra tem um modificador `Chanfro`, de 0,012 m. O ícone de chave inglesa mostra **Width**. Não aplique o modificador se ainda quiser mover as pedras como blocos simples.

Para exportar de novo para o mesmo GLB:

1. Na vista 3D, pressione A para selecionar tudo.
2. No Outliner, segure Shift e clique em `CameraTresQuartos`, `Sol` e `Preenchimento` para tirar esses três da seleção. O vazio e as pedras ficam selecionados.
3. **File > Export > glTF 2.0 (.glb/.gltf)**.
4. Pasta `D:\Progr\catlenight\assets\models\environment`, nome `arco_de_pedra.glb`, substitua o arquivo.
5. No painel da direita do exportador: formato **glTF Binary (.glb)**, **Selected Objects** ligado e **Apply Modifiers** ligado. Confirme.

No Godot, o arquivo reimporta quando o editor percebe a troca. Para ver a peça nova: abra `scenes/environment/arco_de_pedra.tscn`, expanda `Visual` e clique em `PedraCentral`. A cor está no material dessa malha. O nó `Colisao` não muda. Depois abra a cena principal e pressione F5. A `CameraLateral` mostra o arco no mesmo lugar.

## Exercício de cinco minutos

Troque só a cor da pedra central e ache a diferença no jogo, sem refazer a cena nem as colisões.

1. Abra o `.blend` e clique em `PedraCentral` no Outliner.
2. No editor de materiais (o ícone da esfera), a cor base está em `#C6A36A`. Anote isso. Mude para um vermelho evidente, por exemplo `#B4463A`.
3. Exporte por cima do mesmo GLB, com os passos da seção anterior. Não rode `criar_arco_de_pedra.py`: esse script reconstrói o arquivo e apaga a cor que você acabou de escolher.
4. Volte ao Godot. Se a cor não mudar sozinha, clique em `arco_de_pedra.glb` no Sistema de Arquivos e use **Reimportar**.
5. Pressione F5. Olhe o topo do arco pela câmera lateral. A pedra clara do meio fica vermelha. As caixas de `Colisao` continuam as mesmas.

Para restaurar, repita a troca com `#C6A36A` e exporte de novo para o mesmo GLB.

## Pendências

- O protagonista continua o bloco vermelho. A malha dele é a próxima tarefa.
- A colisão usa caixas simples, não o contorno de cada cunha. O vão de caminhada está livre, e o pulo atual não alcança a curva: a cabeça chegaria perto de 3,3 m, e a pedra central começa em 4,22 m.
- O Git continua ausente. Não há repositório.
