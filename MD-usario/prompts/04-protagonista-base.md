Continue o projeto Catlenight em D:\Progr\catlenight. Execute a Tarefa 04. Quero abrir o jogo com F5 e controlar um personagem humanoide 3D original, com 1,70 m de altura, usando o controlador que já passou nos testes. Ele deve olhar para a direita quando andar para a direita, olhar para a esquerda quando andar para a esquerda e conservar a última direção quando parar.

1. PREPARE A ETAPA

Salve este prompt integralmente em MD-usario/prompts/04-protagonista-base.md. Leia CLAUDE.md, os relatórios 02 e 03, scenes/player/jogador.tscn e scenes/player/jogador.gd. Confira como o teste de movimento e o teste de travessia do arco são executados.

Use as instalações já verificadas de Blender e Godot. Aproveite o fluxo de .blend e GLB da Tarefa 03. Use os recursos nativos das duas ferramentas.

2. MODELE O CORPO NO BLENDER

Crie um manequim humanoide de estudo com cabeça, pescoço, tórax, pelve, braços, antebraços, mãos, coxas, pernas e pés. Dê volume às peças e nomes que eu consiga localizar no Outliner. Diferencie esquerda e direita anatômicas nos nomes dos membros. Coloque os pivôs de braços, antebraços, coxas e pernas nas articulações correspondentes. Assim poderei selecionar um antebraço e experimentar uma rotação pelo cotovelo.

Modele uma pose de repouso simples para a câmera lateral. Deixe os joelhos levemente flexionados e desloque um pé um pouco à frente do outro. Dê à cabeça um perfil reconhecível e aos pés uma ponta visível. Use poucos materiais, com contraste suficiente para distinguir o braço próximo do tórax e a perna próxima da perna distante. Confira a silhueta em tamanho de jogo antes de detalhar dedos ou rosto.

Na pose entregue, meça 1,70 m da sola apoiada ao topo da cabeça. Posicione a origem da raiz no piso, entre os pés. Documente qual eixo é a frente do personagem no Blender e para onde ele olha depois da importação no Godot.

Salve o editável em arte-fonte/blender/protagonista_base.blend e exporte em assets/models/characters/protagonista_base.glb. Se gerar o modelo por Python, entregue também o script junto ao .blend. O procedimento de exportação precisa permitir que eu altere uma peça à mão e leve essa alteração ao jogo.

3. INTEGRE O MODELO AO JOGADOR

Abra scenes/player/jogador.tscn e substitua a malha vermelha provisória pelo GLB como filho de Visual. Confira o alinhamento em repouso: com a origem do Jogador no piso, a sola do pé de apoio deve tocar o chão. Confira também a altura importada e a escala da instância. Corrija eventuais diferenças de unidade ou eixo na exportação.

Use a direção horizontal já lida pelo controlador para orientar somente o nó Visual. Com entrada para a direita, o perfil deve apontar para +X; com entrada para a esquerda, para -X. Use rotação em torno do eixo vertical. Ao soltar as teclas ou pular sem entrada horizontal, mantenha a última orientação. Preserve o alinhamento dos pés e evite deslocamento lateral no instante da virada.

Mantenha a colisão existente de 0,80 × 1,70 × 0,50 m, a origem do corpo nos pés, a velocidade de caminhada de 3,5 m/s e a velocidade inicial de pulo de 5,5 m/s. O corpo físico continua responsável pela locomoção. A entrega visual desta etapa é a pose-base com mudança de direção. Esqueleto, ciclos de caminhada, roupas e equipamentos ficam para as próximas tarefas.

4. VALIDE NA CÂMERA DO JOGO

- Rode os testes existentes de movimento e travessia do arco. Registre os resultados.
- Rode a cena principal. Confira se o protagonista cai, se apoia no chão e alcança a plataforma com o mesmo controle.
- Ande para a direita, solte a tecla, volte para a esquerda e pule parado. Verifique se a última direção é mantida e se a colisão permanece alinhada nas duas orientações.
- Atravesse o arco nos dois sentidos. Observe se ainda é possível identificar a cabeça e o sentido do movimento durante a passagem pelo pilar da frente.
- Salve em MD-usario/relatorios/evidencias/ uma imagem do corpo inteiro no Blender em três quartos e duas capturas reais do jogo, uma em cada direção. Use o mesmo enquadramento Size = 8. Faça pelo menos uma das capturas junto ao arco, com o personagem visível. Use nomes iniciados por 04-.
- Avalie as capturas em 1280×720. Se a frente e as costas forem difíceis de distinguir, ajuste primeiro o perfil da cabeça, a posição dos pés ou o contraste dos membros e teste outra vez.

5. DOCUMENTE O QUE EU PRECISO APRENDER

Atualize docs/ROADMAP.md e salve o relatório em MD-usario/relatorios/04-protagonista-base.md. Inclua os caminhos do .blend, do GLB e da cena, a altura medida antes e depois da importação, a convenção dos eixos, as evidências e qualquer pendência.

Explique, usando os nós reais do projeto, o que acontece quando aperto a seta esquerda: onde o controlador lê a ação, como o corpo se desloca e qual nó gira o modelo. Mostre também como visualizar a forma de colisão enquanto o jogo está rodando para eu comparar os pés desenhados com o apoio físico.

Termine com um exercício de cinco minutos: selecionar o antebraço no Blender, dobrá-lo um pouco pelo cotovelo, reexportar o personagem inteiro e conferir a nova pose com F5. Indique o eixo correto para o modelo que você criou e como restaurar a pose original.
