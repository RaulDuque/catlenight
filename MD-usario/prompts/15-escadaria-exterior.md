Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 15 — Escadaria exterior de acesso ao castelo.

Quero que “Novo jogo” comece do lado de fora. O protagonista aparece ao pé de uma escadaria de pedra. Do ponto de nascimento já consigo ver, mais acima e à direita, a entrada iluminada do castelo. Seguro a seta direita, subo os degraus e atravesso a entrada para chegar ao vestíbulo da cena 14. Quero poder voltar pelo mesmo caminho.

A referência visual que enviei mostra Richter numa escadaria contra o céu noturno e, depois, num interior de colunas altas e luz de velas. Para esta etapa, estude a primeira passagem, do exterior para o interior. Crie geometria e materiais originais do Catlenight. A descrição acima é suficiente para trabalhar se o vídeo estiver disponível apenas na conversa.

1. Organize a etapa

Salve este prompt integralmente em MD-usario/prompts/15-escadaria-exterior.md. Leia CLAUDE.md, o roadmap e os relatórios 12 a 14. Crie scenes/verification/15_escadaria_exterior.tscn reaproveitando o piloto 14. Preserve a cena anterior como exercício e mantenha a configuração atual do F5.

Antes de modelar, confira onde cabem a saída e a chegada no lado esquerdo do vestíbulo. A nova entrada chega ao nível do piso. A porta elevada da sacada continua levando à Capela da Lua.

2. Monte a subida e jogue antes de detalhar

Crie scenes/environment/escadaria_exterior.tscn. Faça primeiro uma versão simples com patamar inferior, subida e patamar superior diante do portão. Use degraus na malha visível e experimente uma rampa contínua na colisão. Ajuste a inclinação com o controlador real: segurar direita deve bastar para subir, esquerda deve bastar para descer e soltar a seta no meio deve permitir ficar parado.

Observe os pés de perfil durante a subida e a descida. Ajuste a posição da rampa se as botas entrarem demais na pedra ou flutuarem acima das quinas. Registre o desnível total, o comprimento horizontal e como a colisão se relaciona com os degraus visíveis.

3. Construa a vista de chegada

Use a câmera ortográfica lateral e o personagem de 1,70 m como referências de escala. Componha o primeiro quadro com três elementos legíveis em 1280×720: a silhueta do protagonista no patamar, a linha dos degraus e o portão no alto. Use um céu noturno frio e concentre a luz quente na entrada. Coloque a massa da torre e as silhuetas distantes atrás do plano de jogo. Confira que o corrimão ou a mureta deixam as pernas visíveis durante a caminhada.

Reaproveite a cantaria de 2 m onde ela encaixar. Modele no Blender pelo menos o lance de escada como peça editável, com a origem no início da subida. Salve em arte-fonte/blender/escadaria_exterior.blend e exporte o GLB para assets/models/environment/exterior/. Importe o GLB no Godot antes das medições finais.

4. Conecte a sala ao jogo, ao mapa e ao altar

Use o sistema existente de destinos, chegadas, enquadramentos e retornos. “Novo jogo” na cena 15 começa no patamar inferior com Vida 3/3. “Continuar” segue restaurando a partida no altar da capela.

No mapa, a Escadaria Exterior fica à esquerda do Vestíbulo. Numa partida nova, M mostra apenas a escadaria. Entrar no castelo revela o vestíbulo e a ligação entre os dois. Em uma gravação antiga, preserve as salas já descobertas e revele o exterior quando o jogador o visitar. Use uma pasta de dados isolada durante os testes.

5. Valide o percurso e registre o que aparece na tela

Teste a própria cena 15 pelas ações do Input Map. Suba, pare no meio, continue até o portão, entre no vestíbulo e volte ao exterior. Faça o percurso nos dois sentidos. Confira que segurar a seta gera uma única transição por passagem, que a câmera mostra a sala correta e que o corpo permanece em Z = 0. Abra M antes e depois de entrar. Confira também uma restauração no altar e rode os testes existentes afetados pela mudança.

Salve dois quadros reais da câmera em MD-usario/relatorios/evidencias/: 15-primeira-vista-do-castelo.png, no nascimento, e 15-subida-ao-portao.png, com o protagonista no meio dos degraus. Inspecione os quadros no tamanho normal do jogo. Relate se é possível localizar o portão de imediato e enxergar o apoio das botas. Informe se a janela abriu pelo editor ou por script.

6. Documente e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/15-escadaria-exterior.md. Explique, pelos nomes reais dos nós, qual malha desenha os degraus, qual forma sustenta o personagem e qual passagem leva ao vestíbulo.

Termine com um exercício de cinco minutos no editor: ativar a visualização das colisões, parar na metade da escada e comparar a linha que sustenta os pés com as quinas dos degraus. Indique a cena, o nó e o que observar na subida e na descida.

Com os testes aprovados, revise o diff, faça commit e push conforme o CLAUDE.md e confirme o hash remoto. Na resposta final, informe a cena para F6, o caminho da primeira captura, as medidas da escada e o link completo do commit.
