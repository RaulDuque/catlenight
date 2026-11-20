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

## Prólogo

A primeira área é o prólogo: o jogador nasce fora do castelo e sobe até a entrada. A referência de composição e de percurso é a prancha “Final Stage: Bloodlines”, mapeada por Revned em [Revned’s Video Game Maps](https://revned77.github.io/games/SymphonyOfTheNight.html). A cópia de consulta fica em `assets-exemple-2d/Final Stage - _Bloodlines_.png`. Ela estuda a disposição dos espaços. O que o jogador vê enquanto anda continua dependendo do vídeo da abertura, quando essa imagem estiver disponível. O cenário jogável é feito com as peças 3D do Catlenight.

A faixa de baixo da prancha organiza a sequência exterior, patamar, salão e trono. Nesta etapa só a escadaria e a passagem para o vestíbulo estão montadas. O nascimento fica no patamar inferior direito. A seta esquerda sobe em −X até o patamar superior esquerdo, onde o vão iluminado marca a troca do céu aberto pelo interior. A seta direita desce.

Ficam anotados para etapas futuras, sem caminho definido pela prancha:

- o salão do trono, a sala larga com colunas, cortinas e a mesa ao centro;
- o espaço superior alongado, com as figuras repetidas e as luzes;
- o espaço superior em degraus, o lance quebrado entre esse corredor e o salão.

## Fora desta etapa

Movimento, combate, inimigos, várias salas, interface, animação e áudio não fazem parte da fundação.
