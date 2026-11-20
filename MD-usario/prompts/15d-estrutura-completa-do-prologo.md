Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 15-D — Planta estrutural completa do prólogo Bloodlines.

PRIORIDADE DESTA ENTREGA

Quero abrir o Godot e jogar a estrutura inteira do prólogo em blocos. Preciso conferir dimensões, pisos, paredes, tetos, vãos, rampas e ligação entre os três níveis. A tarefa termina com os quatro setores construídos e percorríveis. Suspenda o trabalho de arte: use cores chapadas para inspecionar a geometria.

1. Parta da versão correta

Salve este prompt integralmente em MD-usario/prompts/15d-estrutura-completa-do-prologo.md. Leia CLAUDE.md e confira o estado atual do Git. A referência conhecida é o commit 4870648d64638315328d4d93bee30e90a2678f54, que já ampliou o salão e o piso do trono. Trabalhe sobre a versão mais recente que contenha essa alteração.

Abra dados/sala_do_prologo.json, scenes/environment/gerador_de_sala.gd, a cena 15-C, o controlador e o script de câmera. Rode a cena atual uma vez. Segure ← além do trono e verifique se o jogador para, cai ou retorna ao nascimento. Registre o comportamento da versão realmente executada.

Crie scenes/verification/15d_estrutura_completa_do_prologo.tscn para F6. Use dados próprios da 15-D, mantendo a 15-C disponível para comparação. O gerador atual aponta para um JSON fixo. Se for reutilizá-lo, permita configurar a fonte por instância e conserve o caminho antigo como padrão. Use Godot, GDScript e colisões 3D no plano Z = 0.

2. Faça a planta em escala antes de aumentar o cenário

Abra assets-exemple-2d/Final Stage - _Bloodlines_.png em sua resolução original. Salve a planta de trabalho em docs/PLANTA_DO_PROLOGO.md. Adote uma origem clara, por exemplo a superfície do patamar inferior direito, com X crescendo para a direita e Y para cima.

Marque no PNG os pontos que definem a estrutura: começo e fim de cada lance, patamares, limiar, início e fim do salão, borda e fundo do estrado, faces internas das paredes, parte inferior dos tetos, vãos e extremos da galeria superior. Meça as superfícies jogáveis. Desconte a moldura do atlas, o quadro de título, as margens pretas e as linhas editoriais que ligam os painéis. Essas linhas indicam correspondência entre espaços; o comprimento delas não é uma distância para construir no jogo.

Estabeleça uma escala única de pixels da planta para metros do mundo. Prefira calibrá-la com um quadro original em que seja possível medir o personagem e reconhecer uma peça arquitetônica também visível na planta. Corrija eventual diferença de resolução entre o vídeo e o PNG usando essa peça comum. Use o protagonista de 1,70 m como referência do Catlenight. Se o vídeo original não estiver disponível localmente, faça uma calibração provisória com uma abertura identificável, declare a altura adotada e confira a proporção com uma segunda medida independente. A falta do SymphonyRecomp não bloqueia a construção.

Entregue uma tabela de coordenadas que outra pessoa consiga usar para reconstruir a fase. Para cada setor, informe largura, desnível, pé-direito, espessura dos fechamentos e posição dos vãos. Para cada rampa, dê X/Y dos dois extremos, avanço horizontal, elevação e ângulo calculado. Identifique o que foi medido na referência e o que foi escolhido para tornar o percurso jogável. Compare, por setor, as medidas anteriores e as novas. Trate “20 vezes menor” como percepção a investigar. Use o mesmo fator nos eixos X e Y e apresente o fator que os dados sustentam.

3. Construa os quatro setores nesta tarefa

A. Escadaria exterior. Comece no canto inferior direito. Faça o patamar inferior, o lance principal que sobe para a esquerda, o patamar superior e o limiar. Recalcule o lance com a planta. Aproveite o trabalho anterior onde as medidas coincidirem. Dê um limite físico ao fim do patamar inicial. Acima da ponte, conserve o espaço aberto do exterior.

B. Salão inferior e sala do trono. A partir do limiar, siga para a esquerda pelo corredor até o estrado. Dê a cada trecho seu comprimento e pé-direito medidos. Construa piso contínuo, teto, estrado e parede sólida atrás do trono. Prolongue o fechamento lateral do piso até o teto. O assento provisório serve para localizar o destino. A parede tem de deter o corpo mesmo se ele passar pelo assento ou pular contra o canto.

C. Escadaria interna intermediária. Construa o setor mostrado no painel do meio, com seus lances, descanso, paredes laterais, teto e aberturas de entrada e saída. Alinhe cada extremidade com a superfície onde os pés precisam chegar. Meça a folga entre a rampa e o teto para o personagem de 1,70 m durante toda a subida.

D. Galeria superior. Construa a sala comprida do painel de cima, incluindo piso dos dois lados da abertura, vão de acesso, paredes de ambas as extremidades e teto. O jogador deve alcançar os dois lados, parar contra cada parede e conseguir descer pelo acesso.

Quando a prancha indicar a correspondência entre dois vãos, use-a para posicionar a ligação. Se ela não demonstrar o mecanismo original de abertura, implemente uma ligação de estudo simples e reversível e identifique-a na planta como provisória. Pode usar os marcadores e transições já existentes. A entrada deve ser alcançável pelos controles normais a partir de “Novo jogo”. Os dois setores superiores precisam estar jogáveis nesta entrega.

4. Faça a geometria funcionar como estrutura

Reaproveite o gerador, mas escolha a resolução da grade conforme as medidas. A célula atual de 1,00 × 0,44 m já determina o ângulo de uma rampa de uma célula. Para um lance com outra inclinação, use vértices ou extremos explícitos, ou uma grade que represente o declive medido. Documente o arredondamento produzido.

Use colisão contínua onde o piso for contínuo e deixe recortes somente nos vãos previstos. Em cada junção, confira a altura da superfície de apoio da rampa e a altura do patamar no mesmo X. Teste a passagem nos dois sentidos antes de escolher sobreposição ou margem. Verifique a inclinação máxima que o controlador reconhece como chão. Se um ajuste for necessário para subir a escada de referência, aplique-o no escopo do piloto e registre o motivo.

Faça o visual de blocos acompanhar a face que realmente sustenta os pés. Na captura anterior, a sola parece acima da faixa marrom. Meça a posição da sola, a base da colisão do jogador e a superfície inclinada naquele X para descobrir se a diferença vem da física, do desenho do bloco ou do modelo animado.

Preserve a altura do personagem, a velocidade de caminhada e os impulsos de salto já aprovados. Ajuste os limites da câmera por setor para acompanhar o corpo em X e Y até o último piso. Separe a vista lateral jogável da vista geral usada para inspecionar a planta.

5. Teste as paredes e os acessos, além da chegada ao trono

Implemente tests/verificar_estrutura_15d.gd e rode a própria cena 15-D com a física real. Faça ao menos um percurso contínuo pelas ações do Input Map, sem reposicionar o jogador pelo teste para alcançar os andares superiores.

- Suba a escada exterior com ←, pare no meio e retome. Na volta, desça com →. Registre apoio e coordenadas antes, durante e depois das duas emendas. Verifique se há perda de contato, travamento ou impulso vertical inesperado.
- No fundo da sala do trono, sustente ← por pelo menos 2 segundos e pule contra a parede. O corpo precisa permanecer na sala, sem cair, atravessar a parede ou disparar o retorno.
- Alcance a escadaria intermediária pelo acesso previsto, suba até a galeria superior, visite as duas extremidades e volte ao piso inferior. Registre o caminho pelos controles para eu conseguir repeti-lo.
- Em cada sala interna, confira a presença física do teto e das paredes. Onde o teto ficar alto demais para alcançar num salto, use uma consulta de física a partir do interior. Confira também que os vãos previstos estão livres.
- Meça o percurso por trecho, o maior desvio em Z e a posição final dos pés. Confira que o jogador está visível durante toda a subida ao andar superior. Rode a regressão da 15-C se houver mudança no gerador compartilhado.

6. Entregue evidência que me permita julgar as proporções

Salve em MD-usario/relatorios/evidencias/15d-planta-estrutural.png uma vista lateral ortográfica do conjunto, com os quatro setores, régua em metros, indicação dos acessos e uma silhueta de 1,70 m em cada nível. Gere essa vista a partir da geometria implementada. Ela precisa mostrar onde as paredes terminam, onde o teto abre e para onde cada abertura leva.

Salve também 15d-galeria-superior.png pela câmera normal do jogo, com o protagonista apoiado no último andar. Use a mesma unidade da planta para informar a largura total jogável e a diferença de altura entre o patamar inicial e o piso superior. Registre como a cena foi aberta e quais testes foram realmente executados.

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/15d-estrutura-completa-do-prologo.md com a tabela antes/depois, o critério de escala, os comandos, os resultados e as conexões provisórias. Inclua um exercício curto no editor: selecionar a parede atrás do trono, encontrar sua colisão e conferir onde ela encontra o teto.

Com a entrega validada, faça commit e push conforme o CLAUDE.md. Informe a cena para F6, o caminho pelos controles até a galeria superior, as dimensões finais, a localização da planta e o link completo do commit.
