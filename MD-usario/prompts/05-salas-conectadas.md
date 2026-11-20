Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 05 — primeiras duas salas conectadas.

OBJETIVO JOGÁVEL

Quero abrir uma cena pelo F6, correr com o protagonista por um vestíbulo, atravessar a saída à direita, entrar em uma galeria e conseguir voltar ao vestíbulo pela esquerda. Essa será a primeira ligação explorável do castelo.

1. Registre o prompt em MD-usario/prompts/05-salas-conectadas.md. Leia CLAUDE.md, docs/ROADMAP.md e os relatórios 04-C e 04-D. Reaproveite o jogador, a corrida, o arco e os ajustes de visibilidade. Use Godot e os recursos que já temos.

2. Crie uma cena de entrada em scenes/verification/05_salas_conectadas.tscn. Monte o vestíbulo e a galeria como cenas reutilizáveis. O arco já modelado identifica o vestíbulo. Dê à galeria uma silhueta própria usando peças simples, por exemplo uma plataforma elevada e duas colunas ao fundo. Pela câmera lateral, quero reconhecer em qual sala estou mesmo com o personagem parado.

3. Mantenha um único jogador durante a travessia. Cada passagem deve identificar a sala de destino e um ponto de chegada. Ao cruzar a saída direita do vestíbulo, coloque os pés do jogador sobre o piso na entrada esquerda da galeria, em Z = 0. Faça o trajeto inverso funcionar pela mesma regra. Coloque a chegada fora da área que dispara o retorno, com espaço suficiente para parar, virar e atravessar de volta. Posicione a câmera na sala correta assim que o jogador chegar.

4. Confira o retorno depois de uma queda. O controlador atual guarda o ponto de retorno na inicialização. Ao entrar em outra sala, atualize esse ponto para um local seguro da sala atual. Esse detalhe faz parte da tarefa: se eu cair na galeria, devo reaparecer na galeria. Preserve os controles e os valores já verificados de movimento, pulo e animação.

5. Teste pela cena nova. Faça três viagens completas de ida e volta. Em uma delas, segure a seta durante a travessia e depois solte: deve ocorrer uma única troca por passagem, e o personagem deve poder parar na sala de destino. Verifique também câmera, piso, Z, corrida nos dois sentidos e retorno após uma queda na segunda sala. Rode os testes existentes que cubram o código alterado e corrija eventuais regressões.

6. Salve duas capturas reais pela câmera de jogo, uma em cada sala, em MD-usario/relatorios/evidencias/ com o prefixo 05-. Atualize o roadmap e escreva MD-usario/relatorios/05-salas-conectadas.md. Explique o percurso de uma travessia usando os nomes reais dos nós: quem detecta o jogador, onde está o destino e como a câmera e o ponto de retorno são atualizados.

7. Termine com um exercício curto no Inspector: mover o ponto de chegada da galeria meio metro para dentro da sala, atravessar a porta para observar o resultado e restaurar a posição original. Informe o caminho da cena e dos nós para eu conseguir repetir sozinho.
