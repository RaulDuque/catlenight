Continue o projeto Catlenight em D:\Progr\catlenight. Implemente a Tarefa 02 e execute os testes que estiverem ao seu alcance.

OBJETIVO

Quero abrir o jogo, ver o personagem cair até o chão, andar com as setas, pular com Espaço e aterrissar sobre uma plataforma. Estou aprendendo programação de jogos. O mundo, o personagem e as colisões são 3D. A câmera observa a sala de lado. X é deslocamento horizontal, Y é altura e o plano de jogo fica em Z = 0.

1. GUARDE O PROMPT E LEIA O PROJETO

Salve este texto integralmente em MD-usario/prompts/02-movimento-e-pulo.md antes da implementação. Leia CLAUDE.md, docs/ROADMAP.md, o relatório 01-B, project.godot e scenes/verification/main.tscn. Aproveite a instalação já validada do Godot em C:\Users\Raul\Tools\Godot\4.7.2-stable.

2. PREPARE A REFERÊNCIA E A SKILL

Consulte o exemplo oficial Kinematic Character 3D para entender como o jogador move seu próprio corpo durante o passo de física:
https://github.com/godotengine/godot-demo-projects/tree/master/3d/kinematic_character

Para o Claude Code, confira a skill godot-gdscript-patterns:
https://github.com/wshobson/agents/tree/main/plugins/game-development/skills/godot-gdscript-patterns

Se a licença permitir a inclusão, adicione somente essa skill ao escopo local do projeto em .claude/skills/godot-gdscript-patterns/, junto com os avisos de licença aplicáveis. Registre a origem e a revisão obtida. Se já estiver instalada, aproveite a existente. Se a instalação estiver indisponível, registre isso e prossiga com a implementação. O jogo deve executar com os recursos nativos do Godot.

3. CRIE O JOGADOR

Crie uma cena reutilizável com CharacterBody3D na raiz, CollisionShape3D para a física e um nó visual separado para receber futuramente um modelo do Blender. Reaproveite a aparência vermelha e a altura de 1,70 m do marcador. Alinhe a base da malha com a base da colisão. Documente onde está a origem do personagem para podermos alinhar o modelo futuro.

Instancie o jogador no lugar do marcador da cena principal. Deixe os pés cerca de 1 m acima do chão no início. A primeira coisa que devo ver é o bloco cair e parar por causa da colisão.

4. IMPLEMENTE MOVIMENTO E PULO

Crie ações nomeadas no Input Map para esquerda, direita e pulo. Associe as setas horizontais e Espaço. Implemente um controlador curto em GDScript tipado, usando _physics_process(delta), velocity e move_and_slide().

O personagem deve andar enquanto a seta estiver pressionada, parar ao soltá-la e pular uma vez por pressionamento quando estiver no chão. Aplique gravidade durante a queda e a subida. Trave o deslocamento em Z, inclusive durante colisões. Exponha no Inspector a velocidade de caminhada e a velocidade inicial do salto, com nomes e unidades compreensíveis.

5. MONTE UM TESTE QUE EU POSSA JOGAR

Aproveite o chão, a iluminação e a câmera ortográfica com Size = 8. Coloque uma plataforma 3D baixa, com malha e colisão alinhadas, ao lado do ponto de nascimento. Escolha uma altura que o pulo realmente alcance e deixe espaço para aterrissar e voltar ao chão. Mantenha o percurso inteiro visível.

Como o chão tem bordas, permita repetir o teste depois de uma queda. Uma solução suficiente é devolver o personagem ao ponto inicial e zerar a velocidade quando ele cair abaixo da sala.

6. VALIDE O COMPORTAMENTO

Rode o projeto usando project.godot como entrada. Verifique e registre:
- O jogador nasce no ar, cai e se estabiliza sobre o chão.
- As duas setas movem o jogador nas direções esperadas. Soltar a seta interrompe a caminhada.
- Espaço inicia o salto no chão. Apertar novamente no ar não produz outro salto. Segurar Espaço durante a aterrissagem não dispara um novo pulo.
- É possível subir na plataforma com um salto, ficar em pé sobre ela e voltar ao chão.
- O Z do corpo permanece em zero durante o percurso, dentro da tolerância numérica da física.
- Sair pela borda permite retornar ao teste.
- A cena principal abre sem erro de script ou de recurso.

Use a execução real da física para verificar o que puder. Uma captura parada documenta a aparência. Para comprovar movimento e colisão, use observação durante o jogo ou medições em quadros sucessivos. Se puder operar o editor, aproveite para testar F5. Identifique no relatório qualquer teste que dependa de mim.

7. DOCUMENTE PARA EU APRENDER

Atualize o README com os controles e o roadmap com os resultados. Salve o relatório em MD-usario/relatorios/02-movimento-e-pulo.md. Liste os arquivos alterados, as referências usadas, os testes executados e as pendências.

Explique o caminho de um salto usando o código que você escreveu: onde Espaço vira uma ação, onde o script consulta o chão, onde a velocidade vertical muda e onde a colisão é resolvida. Indique o arquivo e a função para eu conseguir acompanhar no Cursor.

Termine com um exercício de cinco minutos: anote a velocidade inicial do pulo, aumente-a em 20% no Inspector, rode o jogo e observe o que muda na altura e no tempo de voo. Explique como restaurar o valor original.

Conclua a entrega no primeiro controlador jogável. A próxima tarefa será modelar um arco de pedra no Blender e passar por baixo dele com esse mesmo personagem.
