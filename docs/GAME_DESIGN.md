# Visão do jogo

Catlenight é um metroidvania gótico original em 2.5D. O jogador atravessa salas ligadas de uma fortaleza noturna, luta de perto e volta a lugares já vistos quando uma capacidade nova abre um caminho que antes estava fechado.

O nome é provisório.

Castlevania: Symphony of the Night serve para estudar exploração, ritmo e progressão. O projeto não copia mapa, personagens, nomes, trilha ou regras desse jogo. Enquanto a arte final não existe, personagens, chão e obstáculos são formas geométricas.

## Como o espaço funciona

Cenário, personagem, luz e física são 3D. A câmera é lateral e ortográfica, então a leitura na tela é a de um jogo de lado.

- X move para a esquerda e para a direita.
- Y é a altura: chão, pulo e queda.
- Z é a profundidade. O personagem fica no plano Z da fase, em vez de andar livremente para dentro da tela.

A cena atual usa o plano **Z = 0**.

## Pilares

1. **Leitura do espaço.** A câmera lateral mostra o chão, o corpo e o trecho que ainda não dá para alcançar.
2. **Salas conectadas.** Cada sala é um lugar com entradas. Voltar por outra porta muda o sentido da exploração.
3. **Combate curto.** O inimigo ocupa o mesmo plano do personagem. A decisão acontece no movimento, durante a ação.
4. **Progressão no corpo.** O que o personagem aprende muda quais salas e alturas passam a ser acessíveis.

## Primeiro objetivo jogável

Ainda não está implementado. O alvo da próxima etapa de jogo é este:

Em uma sala só, o corpo provisório anda em X, pula, cai e para no chão com colisão. Ele permanece em Z = 0. A câmera lateral mostra esse movimento.

A cena `scenes/verification/main.tscn` é o cenário desse teste futuro. Hoje ela só deixa o chão, o bloco, a luz e a câmera visíveis e parados.

## Fora desta etapa

Movimento, combate, inimigos, várias salas, interface, animação e áudio não fazem parte da fundação.
