Continue o projeto Catlenight em D:\Progr\catlenight. Execute a Tarefa 07 — Primeiro inimigo da galeria.

Quero abrir a cena com F6, entrar na galeria e encontrar uma sentinela de pedra patrulhando o chão. Quero ter duas opções: pular por cima dela e seguir em frente ou derrotá-la com três golpes de X. O jogo é inteiramente 3D, com câmera lateral e movimento no plano Z = 0.

1. Guarde o prompt e leia o projeto

Antes de implementar, salve este prompt integralmente em MD-usario/prompts/07-primeiro-inimigo.md. Leia CLAUDE.md, docs/ROADMAP.md e os relatórios das tarefas 06 e 06-B. Abra scenes/verification/06_primeiro_golpe.tscn e confira como o golpe de X chama receber_acerto no boneco de treino.

2. Crie a sentinela e o piloto

Crie uma cena reutilizável em scenes/enemies/sentinela_da_galeria.tscn e uma cena jogável em scenes/verification/07_primeiro_inimigo.tscn. Reaproveite o vestíbulo, a galeria, a câmera e o jogador existentes. A cena 06 deve continuar disponível para testar o boneco, e F5 deve continuar abrindo a cena principal.

Modele a sentinela com formas 3D simples do Godot. Faça um detalhe frontal, como um olho de pedra iluminado, para eu perceber de longe para qual lado ela está andando. Escolha a altura usando o pulo atual do jogador como referência.

Na galeria, meça um trecho de piso onde haja espaço para a sentinela patrulhar e para o jogador aterrissar dos dois lados. A sentinela deve andar em X, virar ao alcançar cada extremo e permanecer em Z = 0. Exponha a velocidade de patrulha em m/s no Inspetor.

3. Ligue a sentinela ao golpe que já funciona

A sentinela começa com 3 pontos de vida. Reutilize o caminho de acerto da Tarefa 06. Cada golpe válido tira 1 ponto, mesmo quando a lâmina permanece em contato por vários quadros. Segurar X continua produzindo um único golpe.

Dê uma reação visível a cada acerto. No terceiro, mostre a derrota, encerre a patrulha e desative a colisão e a recepção de golpes. O jogador deve poder atravessar aquele ponto, voltar ao vestíbulo e reencontrar o caminho livre ao entrar de novo na galeria. Reiniciar a cena com F6 permite repetir o encontro.

O escopo desta tarefa é patrulha, salto sobre o inimigo, acerto e derrota. Vida do jogador, dano por contato, interface e animação definitiva da espada ficam para etapas posteriores.

4. Valide o encontro no Godot

Execute o piloto com a física real e as ações do Input Map. Registre estes resultados:

- A sentinela completa uma ida e volta, vira nos dois limites e permanece sobre o piso em Z = 0.
- Com a sentinela em movimento, o jogador usa seta e Espaço, passa por cima dela e pousa do outro lado. Registre as posições antes e depois. A sentinela termina a travessia com 3 pontos de vida.
- Um golpe frontal dentro do alcance reduz a vida de 3 para 2. Manter X pressionado conserva os 2 pontos. Um golpe de costas e outro fora do alcance também conservam os 2 pontos.
- Dois novos golpes válidos completam a sequência 2 → 1 → 0. Depois da derrota, o caminho fica livre mesmo após sair e voltar à galeria. Continua existindo um único Jogador.
- Execute tests/verificar_golpe_06.gd e tests/verificar_salas_05.gd. Se alterar outro comportamento compartilhado, rode também o teste correspondente.

Salve duas capturas pela câmera do jogo em MD-usario/relatorios/evidencias/: 07-patrulha-na-galeria.png e 07-salto-sobre-sentinela.png. Na segunda, mostre os pés do jogador passando acima da sentinela. Informe se a janela abriu com F6 no editor ou por script.

5. Documente para eu aprender

Atualize README.md e docs/ROADMAP.md. Salve o relatório em MD-usario/relatorios/07-primeiro-inimigo.md com arquivos alterados, comandos, testes, resultados e pendências.

Explique com os nomes reais dos nós e das funções: onde a sentinela decide virar, como o X do jogador chega até ela e qual trecho encerra a patrulha quando a vida chega a zero.

Termine com um exercício de cinco minutos no Inspetor. Mostre como aumentar a velocidade da patrulha em 25%, testar o mesmo salto e restaurar o valor original. Indique a cena, o nó, a propriedade e os dois valores.

6. Faça commit e push

Registre no CLAUDE.md que autorizo o Claude Code a fazer commit e push das tarefas concluídas do Catlenight, sem pedir confirmação a cada entrega.

Quando os testes passarem, revise o diff, inclua os arquivos desta tarefa e preserve alterações pessoais que já estavam na pasta. Faça o commit e o push normal da branch de trabalho para origin no repositório RaulDuque/catlenight. Confira se o hash remoto corresponde ao commit local. Se o push for recusado, preserve o commit e informe a mensagem do Git, sem usar force push.

Na resposta final, diga qual cena abrir com F6, quais teclas usar, o que os testes comprovaram e o link do commit publicado.
