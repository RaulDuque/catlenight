# 15-D — Planta estrutural do prólogo

A cena para F6 é `scenes/verification/15d_estrutura_completa_do_prologo.tscn`. O F6 do editor não foi pressionado. A janela das imagens abriu por `tests/capturar_15d.gd`. O percurso rodou em `tests/verificar_estrutura_15d.gd`, com a física real e `APPDATA` isolado em `tests/dados_15d`. O F5 continua em `scenes/verification/main.tscn`.

A planta está em `docs/PLANTA_DO_PROLOGO.md`. Os blocos saem de `dados/estrutura_do_prologo.json`. A 15-C continua em `dados/sala_do_prologo.json`.

## O que a 15-C faz além do trono

Na versão executada, commit `4870648`, segurar a seta esquerda depois do estrado tira o corpo do piso. Uma passagem mediu X = −59,915 e Y = −1,578, ainda caindo. O controlador devolve o jogador ao nascimento quando Y passa de −2. Não há parede no fundo.

## Escala

88 px da escadaria na prancha valem os 2,64 m já jogáveis. O fator é 33,3 px/m nos dois eixos. A galeria da prancha, 189 px de piso a teto, vira 5,67 m. Não há fator 20: a galeria mede cerca de 21 m e o salão da 15-C já tinha 23 m de piso.

## Antes e depois

| Trecho | 15-C | 15-D |
| --- | --- | --- |
| Lance exterior | 5,52 m × 2,64 m, 25,6° | 3,12 m × 2,64 m, 40,2° |
| Patamar de baixo | Sem limite à direita | Parede até Y = 2,40 |
| Salão | Piso até a queda | 21,18 m, teto sobre o trono, parede até Y = 6,80 |
| Acima | Nada | Escada interna e galeria nos dois lados |

A sola no meio do lance ficou em Y = 1,620 e a face da rampa em Y = 1,280. A folga é 0,340 m. A malha do bloco é a mesma caixa da colisão. A origem do corpo é a base da caixa; numa rampa de 40° o canto de baixo toca primeiro e o centro sobe. Nesta cena o manequim não troca de animação.

O limite de chão do piloto está em 50°. A caixa empaca perto de 37°, então o lance interno ficou em 19,4°, abaixo do que a prancha desenha. O motivo está na planta.

## Caminho

Espaço confirma “Novo jogo”. A seta esquerda sobe a escadaria, atravessa o salão e chega à parede do trono. No retângulo amarelo, perto de X = −31,60, a seta para cima entra na escada interna. A seta esquerda sobe ao piso da galeria e segue até a parede esquerda. Para o piso direito, corre para a direita e salta o vão. A seta direita chega à parede direita. Para descer, a seta esquerda volta ao piso da esquerda e a seta direita desce a rampa; a seta para cima no patamar devolve o corpo ao salão, em X = −29,00.

## Medidas do percurso

| Marco | Tempo | X | Y |
| --- | --- | --- | --- |
| Nascimento | 0,200 s | −20,000 | 0,000 |
| Parada no lance | 1,817 s | −22,713 | 1,620 |
| Alto da escadaria | 2,800 s | −25,220 | 2,641 |
| Volta ao patamar | 4,033 s | −20,940 | 0,118 |
| Estrado | 12,233 s | −47,245 | 3,140 |
| Dois segundos na parede | 14,250 s | −47,499 | 3,140 |
| Patamar da escada interna | 18,683 s | −31,600 | 5,600 |
| Galeria | 19,317 s | −33,846 | 6,200 |
| Parede esquerda | 21,850 s | −42,654 | 6,200 |
| Parede direita | 26,867 s | −25,154 | 6,201 |
| De volta ao salão | 29,600 s | −29,000 | 2,640 |

O maior desvio em Z foi 0. No chão, o maior impulso vertical medido foi 0. O teto do trono respondeu ao raio em Y = 6,800, a 2,500 m da consulta. O teto sobre a boca da galeria respondeu em Y = 9,200.

A regressão `tests/verificar_blockout_15c.gd` deu `RESULTADO ok`. A matriz da 15-C passou de 4 para 5 corpos e voltou a 4.

## Exercício

Abre a cena 15-D. No painel Cena, abre `Sala`, depois `Gerado`, e seleciona `ParedeDoTrono`. O filho `Colisao` é a caixa. A base dela está em Y = 2,64 e o topo em Y = 6,80. `TetoSalaoEsquerdo` começa nessa mesma altura.
