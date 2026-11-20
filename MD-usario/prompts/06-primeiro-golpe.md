Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 06 — Primeiro golpe corpo a corpo na galeria.

Quero abrir o piloto com F6, atravessar o vestíbulo, chegar perto de um boneco de treino e apertar X para golpear. Pela câmera lateral, preciso conseguir ver para que lado bati e perceber se acertei ou errei.

1. Guarde o prompt e leia o projeto

Salve este texto integralmente em MD-usario/prompts/06-primeiro-golpe.md antes da implementação. Leia CLAUDE.md, docs/ROADMAP.md, o relatório 05-salas-conectadas.md, a cena scenes/verification/05_salas_conectadas.tscn e os scripts do jogador e da troca de sala. Confira no Input Map se a tecla X está livre.

2. Monte o piloto de combate

Crie scenes/verification/06_primeiro_golpe.tscn reaproveitando a cena 05 por herança ou composição. Use o mesmo Jogador e as duas salas conectadas. Mantenha a cena 05 disponível para repetir o exercício anterior e conserve a configuração atual de F5.

Coloque na galeria um boneco de treino 3D simples, com silhueta e cor reconhecíveis na câmera atual. Escolha um trecho de piso onde seja possível chegar aos dois lados do alvo sem cair nem acionar a saída. Deixe livres a chegada, o ponto de retorno e o acesso à plataforma.

3. Implemente o golpe

Crie a ação atacar no Input Map e associe a tecla X, se estiver livre. Para este primeiro exercício, o golpe começa com o jogador no chão e usa a última direção para a qual ele olhou, inclusive quando está parado.

Um toque inicia um golpe curto. No começo, fixe a direção daquele golpe. Durante a parte ativa, mostre uma lâmina provisória ou um arco de golpe à frente do corpo e detecte o contato com o alvo usando a física 3D. Faça o efeito visual corresponder ao alcance real. Um jogador que erra também deve ver o próprio golpe.

Cada golpe pode acertar o mesmo boneco uma única vez, mesmo que o contato dure vários quadros. Segurar X deve produzir um único golpe. Depois que ele terminar, soltar e apertar X novamente permite outro. Se o jogador trocar de sala ou reaparecer após cair, encerre qualquer golpe em andamento naquele instante.

Use geometria simples do Godot. O objetivo desta rodada é aprender alcance, direção e tempo de contato. A animação definitiva da espada pode vir depois.

4. Mostre quando o golpe acertou

Ao receber um acerto, faça o boneco mudar brevemente de cor e voltar ao estado inicial. Permita repetir o exercício dos dois lados. Mantenha uma contagem de acertos que o teste consiga consultar. O jogador deve conseguir distinguir acerto de erro olhando para o boneco na janela do jogo.

5. Teste pelo caminho que o jogador usa

Execute a cena 06. Reaproveite os testes existentes e acrescente um teste focado no combate, usando a ação atacar e passos reais da física. Verifique e registre:

- De frente para o boneco e dentro do alcance, um toque gera exatamente um acerto. Repita do outro lado.
- De costas para o boneco ou fora do alcance, o golpe aparece e a contagem fica igual.
- Segurar X por mais tempo que um golpe inteiro gera só um acerto. Soltar e apertar de novo gera o segundo.
- Acionar a troca de sala durante um golpe encerra a área ativa e o efeito visual. Confira também o retorno após uma queda.
- Andar, virar, pular, atravessar as salas e reaparecer na sala correta continuam funcionando, com um único Jogador e Z = 0.

Capture um acerto com a câmera normal da galeria, num quadro em que seja possível ver o personagem, o golpe e a reação do alvo. Salve em MD-usario/relatorios/evidencias/06-acerto-na-galeria.png. Use a contagem por golpe para comprovar a regra de um acerto. Se conseguir operar o editor, teste F6 na cena 06 e registre como abriu a janela.

6. Documente para eu aprender

Atualize o README com a tecla e a cena do piloto, atualize docs/ROADMAP.md e salve MD-usario/relatorios/06-primeiro-golpe.md. Inclua arquivos alterados, testes executados, resultados e pendências.

Explique um acerto do início ao fim usando os nomes reais dos nós e das funções implementadas. Quero conseguir acompanhar no Cursor onde X vira a ação atacar, onde a direção é escolhida, quando a área fica ativa e por que o segundo quadro de contato não conta como outro golpe.

Termine com um exercício de cinco minutos no Inspetor: aumentar um pouco o alcance, tentar acertar da mesma posição e restaurar o valor original. Indique qual cena abrir, qual nó selecionar, qual propriedade mudar e os valores exatos.
