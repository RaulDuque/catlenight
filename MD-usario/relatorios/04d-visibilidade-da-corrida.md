# 04-D — Visibilidade da corrida

Data: 20/11/2026. Godot 4.7.2. A cena é a do piloto, `scenes/verification/04c_corrida_mixamo.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa mesma cena pelo script `tests/capturar_04d.tscn`. O F5 continua na cena principal, com o manequim e a luz de 1,15.

O modelo, o clipe `corrida`, a caminhada de 3,5 m/s, o pulo de 5,5 m/s e a velocidade da animação de 1,3 ficaram iguais aos da Tarefa 04-C.

## As duas poses, antes de mudar qualquer coisa

Câmera `CameraLateral`, propriedade `Size` = 8. Janela 1280×720.

| Pose | Arquivo | X | Y | Z | `Visual` em Y | Clipe |
| --- | --- | --- | --- | --- | --- | --- |
| Pilar na frente do corpo, olhando para a direita | `04d-arco-antes.png` | −1,714 | 0 | 0 | 0 | `corrida` em 0,270 s |
| O mesmo ponto, olhando para a esquerda | `04d-arco-antes-esquerda.png` | −1,714 | 0 | 0 | 3,1416 | `corrida` em 0,270 s |
| Chão livre, entre o arco e a plataforma | `04d-livre-antes.png` | −0,600 | 0 | 0 | 0 | `corrida` em 0,270 s |

O X = −1,714 é o centro do `PilarFrente` no mundo. É o ponto em que a pedra mais cobre o corpo. O X = −0,600 fica no chão, depois do arco e antes da plataforma.

Sob o arco, o que some é o tronco e a cabeça: a pedra está entre a câmera e o jogador. As pernas ainda aparecem dos lados. Isso é um objeto na frente, não uma sombra.

No chão livre não há pedra na frente. O corpo saía quase branco. A malha do GLB tem albedo (1, 1, 1), rugosidade 1 e sombreamento por pixel. A média das normais ficou em (0,000, 0,001, 0,000), então as normais não estão viradas. A luz `Luz`, com energia 1,15, estourava esse branco e apagava o volume.

## O que mudou no piloto

A luz ambiente de 0,20 sozinha aumentou ainda mais a parte estourada. O ajuste que ficou é menor na luz principal e um ambiente baixo, só nesta cena.

No nó `Ambiente`, recurso `Environment`:

- Ambient Light > Source = Color
- Ambient Light > Color = (0,62, 0,58, 0,54)
- Ambient Light > Energy = 0,12

No nó `Luz`:

- Light > Energy = 0,7
- Shadow > Enabled continua ligado

A cena principal conserva Energy = 1,15.

Girar o arco poucos graus só desloca o pilar. Com cerca de 8 graus a mais, o centro da pedra anda uns 18 cm e o tronco continua atrás dela. Um giro grande mudaria o arco na sala inteira e o corpo ainda sumiria no novo alinhamento. A instância do arco ficou no lugar. A malha e a colisão continuam no mesmo nó.

Enquanto o corpo está atrás do pilar, as pedras da frente ficam transparentes. Fora dessa faixa, voltam a ser opacas. As pedras são `BaseFrente`, `PilarFrente1`, `PilarFrente2`, `PilarFrente3` e `CapitelFrente`. Cada uma recebe uma cópia do material, para a cena principal não mudar.

No nó raiz `CorridaMixamo`, script `visibilidade_do_piloto.gd`:

- `alcance_do_pilar_m` = 0,62
- `alpha_do_pilar` = 0,28

Durante a passagem o material copia fica com Transparency = Alpha e Albedo Color com alfa 0,28. Ao sair, Transparency = Disabled e o alfa volta a 1.

## O que a prancha mostra

`MD-usario/relatorios/evidencias/04d-antes-depois.png` usa o mesmo recorte e a mesma pose em cada par.

- Sob o arco, antes: a perna atravessa a pedra; tronco e cabeça ficam atrás do pilar.
- Sob o arco, depois: a cabeça, o tronco, o braço e a perna de trás aparecem através da pedra, que continua visível.
- Chão livre, antes: o corpo é uma mancha clara.
- Chão livre, depois: o cinza separa o tronco, a perna de trás e o volume do cabelo.

A esquerda, no mesmo X do pilar, está em `04d-arco-depois-esquerda.png`. O perfil vira e o corpo também fica legível.

## O que o teste mediu

`tests/verificar_piloto_04d.gd`, na cena do piloto: `RESULTADO ok`.

- Alfa do pilar com o corpo atrás: 0,280
- Alfa ao parar ao lado do arco: 1,000
- Raio no vão, em Z = 0 e na altura do tronco: livre
- Raio no `PilarFrente`: acertou a colisão
- Plataforma: X = 2,1086, Y = 0,7009
- Z máximo: 0
- Velocidades: caminhada 3,50, pulo 5,50, animação 1,30

Na cena principal, depois dessa mudança:

- `tests/verificar_movimento.gd`: `RESULTADO ok`. Pouso em Y = 0,0003, pico em Y = 1,5904, plataforma em X = 2,1083 e Y = 0,7009, volta em X = 5,9583 e Y = 0,0009, Z = 0.
- `tests/verificar_direcao.gd`: `RESULTADO ok`. Altura do manequim 1,7000 m.
- `tests/verificar_arco.gd`: `RESULTADO ok`. Ida e volta pelo vão, pés em Y = 0,0003, Z = 0.

## Como repetir a comparação

Abra `scenes/verification/04c_corrida_mixamo.tscn` e pressione **F6**. O **F5** abre a cena principal.

1. Seta para a direita até o corpo alinhar com o pilar da frente. A pedra fica translúcida e a corrida continua visível.
2. Solte a seta ao lado do arco. A pedra volta a ficar opaca e o personagem para em pé.
3. Seta para a esquerda, atravessando de novo.
4. Seta para a direita e, antes da plataforma, Espaço.

Para refazer os quatro quadros com a mesma pose, rode `tests/capturar_04d.tscn`. O argumento depois de `--` vira o sufixo do arquivo. As posições estão no começo de `tests/capturar_04d.gd`: X do arco −1,714, X livre −0,600, clipe em 0,270 s.
