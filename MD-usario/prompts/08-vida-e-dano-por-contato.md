Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 08 — Vida do jogador e dano por contato.

Quero abrir a cena com F6, chegar à galeria e entender o que aconteceu pelo que vejo na tela. Se a sentinela encostar no protagonista, ele perde um ponto de vida e pisca brevemente. Se eu pular por cima dela, atravesso com a vida intacta. Se eu perder os três pontos, reapareço no ponto de retorno da galeria e posso tentar de novo.

1. Guarde o prompt e leia o que já funciona

Salve este texto integralmente em MD-usario/prompts/08-vida-e-dano-por-contato.md. Leia CLAUDE.md, docs/ROADMAP.md e o relatório da Tarefa 07. Confira como a sentinela patrulha e é derrotada, como o jogador encerra o golpe e como a sala guarda seu ponto de retorno.

Crie scenes/verification/08_vida_do_jogador.tscn reaproveitando a cena 07, o mesmo jogador e a mesma sentinela. Ative as novas regras neste piloto. Preserve os exercícios anteriores e a cena principal usada pelo F5.

2. Implemente a vida e o contato

O jogador começa com 3 de 3 pontos de vida. O contato corporal com uma sentinela viva tira 1 ponto. Use a física 3D para detectar esse contato. Confira as formas de colisão no jogo: o contato deve funcionar quando a pedra encosta no jogador parado e quando o jogador anda contra ela. A área da lâmina é independente, para que seja possível acertar a sentinela à distância de um golpe e sair ileso.

Depois de sofrer dano, o jogador fica protegido por 1,0 segundo e continua podendo andar, pular e atacar. Exponha essa duração no Inspetor. Se os corpos ainda estiverem em contato quando a proteção terminar, aplique o próximo dano uma única vez e reinicie o intervalo. Se já estiverem separados, a vida fica como está. Uma sentinela derrotada perde imediatamente a capacidade de causar dano.

3. Mostre o resultado na tela

Coloque um indicador simples “Vida 3/3” em um canto da tela. Ele acompanha a câmera nas duas salas e atualiza assim que a vida muda. Durante a proteção, faça o modelo do jogador piscar ou mudar temporariamente de aparência. Use um efeito que permita continuar vendo a direção do personagem, inclusive sob o arco.

4. Reaproveite o retorno da sala

Ao chegar a zero, encerre qualquer golpe ativo e dê uma indicação breve de derrota. Reposicione o mesmo jogador no marcador Retorno da sala atual, com velocidade zerada, vida cheia e aparência normal. A câmera deve continuar mostrando a sala correta.

Ao atravessar a porta normalmente, conserve a vida atual. Uma sentinela já derrotada continua derrotada ao sair e voltar à galeria. Preserve o comportamento de queda que o projeto já tem e documente como ele interage com a vida neste piloto.

5. Teste o encontro com a física real

Use as ações do Input Map e registre os resultados em tests/verificar_vida_08.gd. Para validar dano, provoque o encontro entre os corpos pela cena jogável. Chamar diretamente a função que subtrai vida deixaria a detecção de contato sem teste.

Confira estes casos:

- Encostar muda a vida de 3 para 2. Registre o instante do dano e a vida alguns quadros depois, ainda durante a proteção.
- Manter contato permite um segundo dano somente após o intervalo configurado. Afastar-se antes do fim mantém a vida em 2 mesmo depois que o intervalo passa.
- Saltar sobre a sentinela em movimento conserva a vida dos dois. Acertá-la com a ponta da lâmina reduz apenas a vida dela.
- Receber dano, sair da galeria e voltar conserva a vida do jogador e o valor exibido.
- Chegar a zero produz um único retorno. Verifique posição, câmera, vida restaurada, lâmina inativa e existência de um único Jogador.
- Derrotar a sentinela permite atravessar o trecho sem perder vida. Rode também os testes 06 e 07 e o teste de salas se o código de retorno tiver mudado.

Salve uma captura real em MD-usario/relatorios/evidencias/08-dano-na-galeria.png. Escolha um quadro que mostre o jogador visível e o indicador em “Vida 2/3”. Informe se a cena abriu por F6 no editor ou por script.

6. Documente e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/08-vida-e-dano-por-contato.md com os arquivos, comandos, resultados e pendências. Explique, usando os nomes reais das funções, quem detecta o toque, quem decide se o jogador pode perder vida naquele instante e como o indicador recebe o novo valor.

Termine com um exercício no Inspetor: aumentar a proteção de 1,0 para 2,0 segundos, repetir o contato e restaurar o valor original. Indique a cena, o nó e a propriedade.

Com os testes aprovados, revise o diff, faça commit dos arquivos da tarefa e push normal para origin conforme o CLAUDE.md. Confira o hash remoto. Na resposta final, entregue o caminho da cena, os controles, o intervalo medido entre dois danos e o link do commit publicado.
