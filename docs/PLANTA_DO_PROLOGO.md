# Planta do prólogo

A prancha de consulta é `assets-exemple-2d/Final Stage - _Bloodlines_.png`, 1664 × 1024 px, mapeada por Revned. A origem do jogo é a superfície do patamar inferior direito: X cresce para a direita e Y para cima. Z fica em 0.

As linhas brancas entre os painéis ligam vãos correspondentes. O comprimento delas não entra na planta.

## Escala

O vídeo da abertura não está no disco local. A calibração usa a escadaria exterior, que já era jogável com 2,64 m de desnível.

Na prancha, o lance vai do pixel (1412, 804) ao pixel (1516, 892): 104 px na horizontal e 88 px na vertical. O ângulo medido é 40,2°. O fator único é 88 / 2,64 = 33,3 px por metro, nos dois eixos.

A segunda medida é o vão da galeria superior, da face de baixo do teto (y ≈ 35) ao piso (y ≈ 224): 189 px, ou 5,67 m. Uma pessoa de 1,70 m ocupa cerca de 57 px nessa planta. A proporção galeria/salão, lida em outro trecho do mesmo desenho, fica na casa de 1,3. O fator não muda.

“Vinte vezes menor” não aparece nesses números. A galeria mede cerca de 700 px úteis, 21 m. O salão antigo da 15-C tem 23 m de piso. A diferença é da ordem de uma vez, não de vinte. Quem compara o corpo na tela de 8 m de altura com o bonequinho da prancha vê o mapa pequeno; a planta usa o mesmo metro nos dois eixos.

O arredondamento do lance exterior é zero nesse fator: 104 px viram 3,12 m e 88 px viram 2,64 m.

## Setores

| Setor | Largura jogável | Desnível | Pé-direito | Fechamento | Vão |
| --- | --- | --- | --- | --- | --- |
| Escadaria exterior | Patamares de 2,40 m; lance de 3,12 m | 2,64 m | Aberto. Não há teto | Parede de 0,60 m no fim do patamar direito, até Y = 2,40 | Limiar em X = −26,72, Y = 2,64 |
| Salão e trono | 21,18 m, de X = −47,90 a −26,72 | Estrado sobe 0,50 m | Teto do trono a 4,16 m do piso (face inferior em Y = 6,80) | Parede atrás do trono, X = −48,50 a −47,90, de Y = 2,64 a 6,80 | O teto para em X = −44,00. Dali para a direita o salão fica aberto até o acesso |
| Escadaria interna | Lance de 1,70 m | 0,60 m, de Y = 5,60 a 6,20 | Teto da escada em Y = 9,20 sobre a boca | O patamar de baixo tem 0,90 m | Boca entre X = −34,00 e −31,50 |
| Galeria superior | Lado esquerdo 9,40 m; lado direito 7,30 m | Piso em Y = 6,20 | 5,67 m, face inferior do teto em Y = 11,87 | Paredes em X = −44,00 e X = −24,20, até o teto | O vão entre os pisos é a boca da escada. O salto da esquerda alcança o piso direito |

A largura total, da parede direita do patamar (X = −18,20) à parede do trono (X = −48,50), é 30,30 m. Do patamar Y = 0 ao piso da galeria Y = 6,20 sobem 6,20 m.

## Rampas

| Rampa | Extremo baixo | Extremo alto | Avanço | Elevação | Ângulo |
| --- | --- | --- | --- | --- | --- |
| Exterior | (−21,20, 0,00) | (−24,32, 2,64) | 3,12 m | 2,64 m | 40,2° |
| Estrado | (−44,00, 2,64) | (−45,30, 3,14) | 1,30 m | 0,50 m | 21,0° |
| Interna | (−32,30, 5,60) | (−34,00, 6,20) | 1,70 m | 0,60 m | 19,4° |

O alto da rampa interna fica à esquerda. Subir é a seta esquerda, como na escadaria.

## O que veio da prancha e o que foi escolhido

Medido: o lance exterior a 40,2°, os patamares curtos, o salão longo até o trono, a parede do fundo, o teto da galeria em 5,67 m e a boca no piso da galeria.

Escolhido para o corpo de 1,70 m andar:

- Os patamares da prancha medem cerca de 1,7 m e 1,9 m. No jogo ficam em 2,40 m, para o corpo de 0,80 m parar contra a parede.
- A escadaria interna da prancha está perto de 45°. O controlador trata inclinação maior que `floor_max_angle` como parede. O padrão é 45°, e a caixa de 0,80 × 1,70 m empaca por volta de 37° mesmo com o limite do piloto em 50°. O lance construído fica em 19,4°. O desnível que a prancha mostra acima do salão entra em parte na ligação provisória.
- A ligação do salão para o patamar da escada interna não está desenhada como porta. É provisória: seta para cima no piso amarelo, em X = −31,60 e Y = 2,64, leva a X = −31,60 e Y = 5,60. A mesma tecla no patamar devolve o corpo a X = −29,00 e Y = 2,64. O nome no editor é `AcessoDoSalao` e `AcessoDaEscada`.

## Antes e depois

| Trecho | 15-C | 15-D |
| --- | --- | --- |
| Lance exterior | 5,52 m por 2,64 m, 25,6° | 3,12 m por 2,64 m, 40,2° |
| Fim do patamar de baixo | Aberto | Parede até Y = 2,40 |
| Salão | Piso sem teto e sem parede no fundo | Piso, teto sobre o trono e parede até o teto |
| Acima do salão | Nada | Escada interna e galeria com os dois lados |

A grade de 1,00 × 0,44 m da 15-C continua no JSON antigo. A 15-D não usa células: cada sólido e cada rampa entram com os extremos em metros, em `dados/estrutura_do_prologo.json`. O gerador lê esse arquivo quando o nó `Sala` aponta `dados_caminho`. Sem esse campo, a fonte continua `dados/sala_do_prologo.json`.
