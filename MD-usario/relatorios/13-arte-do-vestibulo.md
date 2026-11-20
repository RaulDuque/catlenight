# 13 — Arte modular 3D do vestíbulo

Data: 20/11/2026. Godot 4.7.2 e Blender 5.3.0. A cena de entrada é `scenes/verification/13_vestibulo_do_castelo.tscn`. O F6 do editor não foi pressionado. As janelas abriram pelos scripts `tests/capturar_13_antes.tscn` e `tests/capturar_13_porta.tscn`. O percurso rodou em `tests/verificar_vestibulo_13.gd`. O F5 continua em `scenes/verification/main.tscn`. A cena 12 continua sem o revestimento.

## O que a câmera mostra

O quadro de comparação está em `MD-usario/relatorios/evidencias/13-vestibulo-antes-depois.png`. Os dois lados usam a mesma pose: pés em X = −0,5241, Y = 0,0009 e Z = 0, rotação Y do `Visual` = 0, câmera em X = 0 com `Size` = 8, janela 1280×720. O protagonista está à direita do arco, de perfil para a galeria. O arco e a porta da sacada cabem no mesmo enquadramento.

À esquerda, o vestíbulo de antes: piso liso, porta isolada no escuro e o lado direito vazio. À direita, a parede de cantaria fica atrás do plano de jogo, a faixa de pedra cobre a face do piso voltada para a câmera e a porta ganha uma luz mais quente que a parede.

`13-porta-na-sacada.png` mostra o jogador apoiado na sacada, em X = −4,175, Y = 2,350 e Z = 0, com o texto “↑ Entrar na capela”. O corpo continua legível dentro do vão.

O que ficou legível: as fiadas e as juntas da parede, a pilastra na união dos módulos, a cornija, a faixa do piso e o brilho da porta. O extremo direito da parede termina numa pilastra e o piso segue um pouco mais, para o escuro da passagem até a galeria.

O que ainda merece trabalho: a moldura da porta continua sendo o retângulo da etapa 10, não um arco ogival. A parede antiga da sacada é mais lisa que a cantaria nova. A sombra do arco na parede nova sai dura. O vão da direita sugere a continuação, mas ainda não tem um batente próprio.

## De uma peça no Blender até o Godot

O editável é `arte-fonte/blender/vestibulo_modular.blend`, gerado por `arte-fonte/blender/criar_vestibulo_modular.py`. O Blender usado foi `C:\Users\Raul\Tools\Blender\5.3.0\blender-5.3.0-windows-x64\blender.exe`.

A peça da parede se chama `ParedeDeCantaria`. É um eixo vazio. Os filhos são `Maciço`, os `Bloco_*` e a `Cornija`. A origem do eixo é o canto esquerdo, no piso. No Blender, X é a largura, Z é a altura e Y = 0 é a face de referência. O relevo avança para Y negativo, que o glTF entrega ao Godot como Z positivo: o lado da câmera.

O exportador grava `assets/models/environment/vestibulo/parede_de_cantaria.glb`. A cena reutilizável é `scenes/environment/parede_de_cantaria.tscn`. No vestíbulo jogável, o primeiro módulo é o nó `Vestibulo/Revestimento/Parede_0`, dentro de `scenes/verification/13_vestibulo_do_castelo.tscn`. A posição dele é X = −6, Y = 0, Z = −2,25. Z negativo coloca a parede atrás do plano de jogo. A face visível aponta para a câmera.

No Godot, a caixa dessa malha mede 2,000 m em X, 5,600 m em Y e 0,560 m em Z. A origem local fica na aresta esquerda. A cópia `Parede_1` está em X = −4. A diferença é exatamente a largura do módulo: 2 m. Para encaixar outra, some 2 ao X.

A pilastra `PilastraDeCantaria` tem a origem no centro da junta e no piso. Vai para `pilastra_de_cantaria.glb` e para o nó `Pilastra_*`, no mesmo Z da parede, com o X da junta. A faixa `FaixaDoPiso` tem a origem na aresta esquerda e na linha do piso. O GLB é `faixa_do_piso.glb`. Cada `Faixa_*` fica em Z = 3,05, cinco centímetros à frente da face do piso, que termina em Z = 3. Por isso as duas superfícies não ficam no mesmo plano.

Antes de exportar, o script colocou duas paredes lado a lado. A folga medida foi 0,000 m. A captura dessa conferência, na escala da câmera do jogo, está em `13-modulos-no-blender.png`.

As três importações não criaram `CollisionObject3D`. O teste da cena 13 confirmou que o grupo `Revestimento` continua sem corpo físico.

## Onde os pés se apoiam

No chão do vestíbulo, o apoio é `Vestibulo/Chao/Colisao`. O `Chao` está em Y = −0,5 e a caixa tem 1 m de altura, então o topo fica em Y = 0. A malha nova só cobre a face que a câmera vê. Na sacada, o apoio é `Vestibulo/Sacada/Laje/Colisao`. O teste pousou com os pés em Y = 2,350 e o aviso “↑ Entrar na capela”.

O arco, a transparência do pilar e as portas não foram trocados. A luz nova é `Vestibulo/LuzDaPorta`, uma `OmniLight3D` em X = −4,55, Y = 3,55 e Z = −0,35, cor mais quente que a parede e sem sombra.

## O percurso

`verificar_vestibulo_13.gd` carregou a própria cena 13, com `APPDATA` em `tests/dados_13`. Nasceu no vestíbulo, passou sob o arco, chegou à galeria, coletou a relíquia, voltou, usou o salto duplo e entrou na capela. Antes da entrada, M mostrou a sala `vestibulo` e as visitadas `vestibulo,galeria`, sem a capela. Depois da travessia, M mostrou `capela_da_lua` e a sala do percurso era `CapelaDaLua`.

Os testes já existentes também deram `RESULTADO ok`: `verificar_arco.gd`, `verificar_capela_10.gd` e as fases `primeira`, `continuar`, `novo_mapa` e `legado` de `verificar_mapa_12.gd`. O mapa usou `tests/dados_12`. As janelas de captura não foram o F6 do editor.

## Exercício de cinco minutos

Abra `scenes/verification/13_estudo_da_parede.tscn` com F6. A câmera já está com `Size` = 8.

1. Selecione `ParedeB`. No Inspetor, em Transform, Position X está em `2`. `ParedeA` está em `0`. A diferença é a largura do módulo, 2 m, e as extremidades se encostam.
2. Mude o Position X de `ParedeB` para `2.1`. Os 10 cm a mais abrem uma fresta escura na junta.
3. Volte o Position X para `2`. A junta fecha de novo.

Não deixe o `2.1` gravado. Essa cena é só para ver o encaixe. O vestíbulo jogável continua em `13_vestibulo_do_castelo.tscn`.
