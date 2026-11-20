# 05 — Primeiras duas salas conectadas

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/05_salas_conectadas.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_05.tscn`. As três viagens rodaram em `tests/verificar_salas_05.gd`. O F5 continua na cena principal, com o manequim.

O jogador é o mesmo `scenes/player/jogador.tscn`. Nesta instância, `modelo_da_corrida` aponta para o GLB da corrida. A caminhada continua em 3,5 m/s, o pulo em 5,5 m/s e `velocidade_da_animacao` em 1,3. A luz e o ambiente repetem o piloto da Tarefa 04-D: `Luz` com Energy = 0,7 e `Ambiente` com Energy = 0,12, cor (0,62, 0,58, 0,54).

## As duas salas

`Vestibulo` é a cena `scenes/environment/vestibulo.tscn`, na origem. O chão mede 12 m. O arco fica em X = −2,05, com o mesmo giro da cena principal. É essa silhueta que identifica a sala.

`Galeria` é a cena `scenes/environment/galeria.tscn`, deslocada para X = 24, para as duas não caberem no mesmo enquadramento. O chão mede 14 m e é mais frio. `Plataforma` está em (1,2, 0,6, 0), com 4,2 × 1,2 × 1,4 m, então o topo fica em Y = 1,2. `ColunaFundoEsquerda` e `ColunaFundoDireita` ficam em Z = −2,15, atrás do plano de jogo. A câmera está em Z = 14 e olha para −Z, então as colunas aparecem atrás do corpo e não o cobrem.

`CameraLateral` tem `Size` = 8. Cada sala tem um `Enquadramento` em (0, 2,4, 14) no espaço local. No vestíbulo a câmera fica em X = 0. Na galeria, em X = 24.

As capturas, com o personagem parado e os pés em Y = 0:

- `05-vestibulo.png` — jogador em (−3,2, 0, 0), câmera em X = 0
- `05-galeria.png` — jogador em `ChegadaEsquerda`, mundo (19,8, 0, 0), câmera em X = 24

## Uma travessia, com os nomes dos nós

Há um só `Jogador`, filho de `SalasConectadas`. Ele não é duplicado dentro das salas.

A saída da direita é `Vestibulo/SaidaDireita`. É uma `Area3D` com o script `scenes/environment/passagem.gd` e o volume `Volume`. No Inspetor, duas propriedades dizem o destino:

- `sala_de_destino` = `../../Galeria`
- `chegada` = `../../Galeria/ChegadaEsquerda`

Quando o corpo do `Jogador` entra nesse volume, `SaidaDireita` emite `body_entered`. O script `salas_conectadas.gd`, no nó `SalasConectadas`, guarda a passagem e aplica a troca no próximo quadro de física. Assim o deslocamento do quadro não continua dentro do volume antigo.

A troca faz quatro coisas:

1. Copia a posição de `Galeria/ChegadaEsquerda` para o `Jogador` e força Z = 0. Os pés ficam no piso, em Y = 0. O marcador está em X local −4,2, que no mundo é 19,8. O volume de `SaidaEsquerda` ocupa o X local de −6,6 a −5,8, então a chegada fica cerca de 1,6 m para dentro, fora da área que dispararia a volta.
2. Copia o `Transform` de `Galeria/Enquadramento` para `CameraLateral`.
3. Chama `definir_ponto_de_retorno` no `Jogador` com a posição de `Galeria/Retorno`. Esse marcador está em (−3, 1, 0) na galeria, no mundo (21, 1, 0).
4. Ignora outra passagem por 10 quadros. A folga, somada à distância até o volume de volta, impede uma segunda troca enquanto a seta continua presa.

A volta usa a mesma regra. `Galeria/SaidaEsquerda` aponta `sala_de_destino` para `../../Vestibulo` e `chegada` para `../../Vestibulo/ChegadaDireita`. Esse marcador está em (3, 0, 0). `SaidaDireita` ocupa o X de 4,8 a 5,6, então dá para parar, virar e atravessar de novo. A câmera passa a copiar `Vestibulo/Enquadramento`, e o retorno da queda passa a ser `Vestibulo/Retorno`, em (−3,2, 1, 0).

Na abertura, o `Jogador` ainda guarda o próprio lugar de início, que coincide com `Vestibulo/Retorno`. O ponto só muda quando uma passagem entrega outra sala.

O pilar do vestíbulo continua com o script `visibilidade_do_piloto.gd`, agora no nó `Visibilidade`. Os caminhos apontam para o `Jogador` e para o arco de dentro do vestíbulo. `alcance_do_pilar_m` = 0,62 e `alpha_do_pilar` = 0,28.

## O que o teste mediu

`tests/verificar_salas_05.gd`: `RESULTADO ok`.

- Velocidades: caminhada 3,50, pulo 5,50, animação 1,30
- Seis trocas, três idas e três voltas
- Na galeria, a leitura ficou em X = 19,8583, Y = 0, Z = 0 e `camera_x` = 24. Os 5,8 cm além do marcador são um quadro a 3,5 m/s, porque a medida acontece depois do passo seguinte
- No vestíbulo, X = 2,9417 e `camera_x` = 0
- Na terceira ida a seta direita ficou presa por 20 quadros depois da troca. Não houve segunda troca, e o corpo parou na galeria
- A corrida tocou nos dois sentidos: perfil para +X e para −X
- Alfa do pilar: 0,280 na passagem e 1,000 ao sair
- Z máximo: 0
- Queda na galeria, além da borda direita do chão: reapareceu em X = 21,0000, pousou em Y = 0,0003, e a câmera ficou em X = 24

Na cena principal e no piloto, depois da mudança no controlador e no script de visibilidade:

- `tests/verificar_movimento.gd`: `RESULTADO ok`. Pouso em Y = 0,0003, pico em Y = 1,5904, plataforma em X = 2,1083 e Y = 0,7009, volta em X = 5,9583 e Y = 0,0009, retorno ao início, Z = 0
- `tests/verificar_direcao.gd`: `RESULTADO ok`. Altura 1,7000 m
- `tests/verificar_arco.gd`: `RESULTADO ok`. Pés em Y = 0,0003, Z = 0, vão livre
- `tests/verificar_piloto_04d.gd`: `RESULTADO ok`. Alfa 0,280 e 1,000, plataforma em X = 2,1086 e Y = 0,7009

## Como repetir

Abra `scenes/verification/05_salas_conectadas.tscn` e aperte F6. Seta direita atravessa `Vestibulo/SaidaDireita` e chega em `Galeria/ChegadaEsquerda`. Seta esquerda atravessa `Galeria/SaidaEsquerda` e volta a `Vestibulo/ChegadaDireita`. Soltar a seta para. Espaço pula. Cair abaixo de Y = −2 na galeria devolve a `Galeria/Retorno`.

Para ver a chegada no Inspetor: abra `scenes/environment/galeria.tscn`, selecione `ChegadaEsquerda` e olhe Transform > Position. O X original é **−4,2**.

## Exercício

1. Abra `scenes/environment/galeria.tscn`.
2. Selecione o nó `ChegadaEsquerda`.
3. No Inspetor, em Transform > Position, mude X de −4,2 para −3,7. Meio metro para dentro da galeria. Salve com Ctrl+S.
4. Abra `scenes/verification/05_salas_conectadas.tscn` e aperte F6.
5. Segure a seta direita até cruzar `Vestibulo/SaidaDireita`. Os pés aparecem em `Galeria/ChegadaEsquerda`, meio metro mais para dentro do que antes. A câmera continua no `Enquadramento` da galeria.
6. Feche o jogo. Devolva o X de `ChegadaEsquerda` para −4,2 e salve de novo.

O marcador faz parte da cena da galeria, não da cena de entrada. Por isso a mudança é em `galeria.tscn`. Na cena de entrada o nó aparece como `Galeria/ChegadaEsquerda`.
