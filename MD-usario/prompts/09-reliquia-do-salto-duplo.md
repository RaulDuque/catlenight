Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 09 — Relíquia do salto duplo.

Quero jogar um pequeno percurso de exploração: ver uma sacada alta no vestíbulo, tentar alcançá-la, encontrar uma relíquia na galeria e voltar para subir àquela mesma sacada. O mundo continua 3D, com câmera lateral e movimento em Z = 0.

1. Guarde o prompt e prepare o piloto

Salve este texto integralmente em MD-usario/prompts/09-reliquia-do-salto-duplo.md. Leia CLAUDE.md, docs/ROADMAP.md e o relatório da Tarefa 08. Confira como o jogador pula, troca de sala, retorna de uma queda e recupera a vida após a derrota.

Crie scenes/verification/09_reliquia_do_salto_duplo.tscn reaproveitando o piloto 08, seu jogador, as duas salas, a sentinela e o indicador de vida. Preserve a cena 08 como exercício independente e mantenha a configuração atual de F5.

2. Construa um lugar que dê vontade de revisitar

Coloque no vestíbulo uma sacada de pedra com espaço para pousar. Ela deve ser visível pela câmera atual e ter um detalhe reconhecível no alto, como uma janela iluminada. Escolha um trecho fora do arco, com espaço lateral para se aproximar e saltar sem bater a cabeça na parte de baixo da sacada.

O pulo atual chegou a cerca de 1,59 m nos testes anteriores. Use essa medida como ponto de partida e escolha a altura final jogando. Confira que o salto simples fica aquém do topo, que o salto duplo deixa margem para pousar e que o jogador pode descer e continuar andando. Verifique também se o arco ou outra colisão próxima permite subir antes de conseguir a habilidade.

3. Coloque a relíquia na galeria

Crie uma relíquia 3D original com formas simples do Godot. Coloque-a numa posição alcançável com as habilidades iniciais. Use a plataforma ou outro ponto seguro da galeria, fora do contato imediato da sentinela. O jogador deve poder escolher entre evitar ou enfrentar a pedra.

Ao tocar a relíquia, o jogador aprende a habilidade uma única vez. A peça desaparece e uma mensagem breve aparece: “Salto duplo adquirido — aperte Espaço outra vez no ar”. Mantenha o indicador de vida legível. Escolha um único lugar para guardar se a habilidade foi adquirida.

4. Implemente o segundo salto

Reutilize a ação pulo, já ligada a Espaço. Antes da coleta, o controle continua com o salto simples. Depois da coleta, um novo pressionamento no ar permite um impulso vertical adicional. Defina a velocidade vertical desse segundo salto em uma propriedade do Inspetor. Comece testando com 5,5 m/s, o valor atual do primeiro impulso.

Segurar Espaço desde o chão produz apenas o primeiro salto. Apertar de novo no ar consome o impulso extra. Um terceiro toque antes de pousar não dá outro impulso. Ao aterrissar no chão ou numa plataforma, o jogador recupera o salto extra para a próxima travessia. Se sair andando de uma borda já com a relíquia, pode usar o salto aéreo uma vez para tentar se recuperar.

A habilidade adquirida acompanha o mesmo jogador nas trocas de sala, nas quedas e no retorno após a derrota. Ao começar uma nova execução da cena, a relíquia volta ao lugar e o jogador começa com o salto simples.

5. Valide o percurso pelas ações reais

Crie tests/verificar_reliquia_09.gd. Use a física do Godot e as ações do Input Map. Faça pelo menos um percurso completo em sequência: comece no vestíbulo, tente a sacada, atravesse para a galeria, colete a relíquia por contato, volte e pouse na sacada.

Registre a altura do topo da sacada, o pico dos pés com salto simples, o pico com salto duplo e a posição final dos pés após o pouso. Use o mesmo piso de partida para comparar as alturas. Confirme que o jogador ficou apoiado na sacada por vários quadros.

Confira também que segurar Espaço não gasta o impulso extra, que o terceiro toque no ar não altera a subida e que pousar devolve o uso. Verifique a persistência da habilidade após trocar de sala, cair e ser derrotado. Rode o teste de movimento anterior e os testes 07 e 08 para conferir o salto sobre a sentinela e o comportamento da vida.

Salve duas capturas reais em MD-usario/relatorios/evidencias/: 09-coleta-da-reliquia.png, com a mensagem visível, e 09-pouso-na-sacada.png, com os pés apoiados no alto. Registre se a cena abriu pelo editor ou por script.

6. Documente e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/09-reliquia-do-salto-duplo.md. Explique com os nomes reais dos nós e das funções onde a coleta libera a habilidade, onde o segundo Espaço consome o impulso e onde o pouso o devolve.

Termine com um exercício de cinco minutos: reduzir em 20% apenas a velocidade do segundo impulso, tentar alcançar a mesma sacada e restaurar o valor original. Indique a cena, o nó, a propriedade e os valores usados.

Com os testes aprovados, revise o diff, faça commit dos arquivos da tarefa e push conforme o CLAUDE.md. Confira se o hash remoto corresponde ao local. Na resposta final, informe a cena para F6, como fazer o percurso, as três alturas medidas e o link do commit publicado.
