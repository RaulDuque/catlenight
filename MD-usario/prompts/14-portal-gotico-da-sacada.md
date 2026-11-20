Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 14 — Portal gótico da sacada.

Quero reconhecer a entrada da Capela da Lua em dois momentos: do piso do vestíbulo, quando ainda estou pensando em como subir, e de perto, quando pouso na sacada e aparece “↑ Entrar na capela”. Use o Blender e o Godot já instalados.

1. Guarde o prompt e meça a passagem existente

Salve este texto integralmente em MD-usario/prompts/14-portal-gotico-da-sacada.md. Leia CLAUDE.md e os relatórios 10 e 13. Abra a cena 13 e a captura 13-porta-na-sacada.png. Identifique os nós que desenham a moldura retangular, a parede lisa e a luz quente. Identifique também a colisão da laje, o detector de interação e o marcador onde o jogador chega ao voltar da capela.

Crie scenes/verification/14_portal_da_sacada.tscn reaproveitando a cena 13. Meça a largura disponível, a altura desde o topo da laje e a profundidade entre o personagem e a parede. Use essas medidas para escolher o tamanho do portal. Registre os valores antes de modelar.

2. Modele um portal que se encaixe na cantaria

Crie arte-fonte/blender/portal_da_sacada.blend. Modele duas ombreiras de pedra, as peças curvas que formam a ponta da ogiva e uma pedra central no alto. Reaproveite a escala e a paleta do módulo de cantaria de 2,00 m. Use poucas peças, com juntas que ainda apareçam na câmera lateral em 1280×720.

Coloque a origem no centro da soleira, na altura em que os pés se apoiam. Confira a proporção com uma referência de 1,70 m no Blender. Exporte somente o portal para assets/models/environment/vestibulo/portal_da_sacada.glb.

3. Integre a arte ao piloto

Substitua, na cena 14, a moldura provisória pelo portal. Resolva o encontro da parede lisa com a cantaria usando primeiro as peças e os materiais existentes. Confira as extremidades para evitar frestas e faces sobrepostas. Aproveite a luz quente da passagem e mantenha as alterações visuais restritas à região da sacada.

Preserve o apoio da laje em Y = 2,350 m, a posição da interação e o retorno da capela. O portal é uma peça visual. Do ponto de vista da câmera, suas pedras devem deixar visíveis a cabeça e o tronco do personagem parado na soleira.

4. Compare o resultado e jogue o percurso

Importe os GLB com o Godot antes de medir os recursos. A primeira medição da Tarefa 13 rodou cedo demais. Teste a cena 14 já importada.

Faça uma prancha com duas linhas e duas colunas. Na primeira linha, mostre a porta vista do chão nas cenas 13 e 14. Na segunda, mostre o protagonista diante da porta nas duas cenas. Para cada par, use a mesma posição, direção, câmera e resolução. Salve em MD-usario/relatorios/evidencias/14-portal-antes-depois.png.

Abra a prancha e confira três coisas: se a ponta da ogiva se distingue do fundo, se o personagem cabe visualmente no vão e se ainda aparece uma emenda lisa destoando da parede. Corrija o que prejudicar a leitura e registre o que continuar visível.

Na própria cena 14, percorra a galeria, colete a relíquia, volte pelo arco e suba à sacada com o salto duplo. Confira o aviso, entre com um toque novo em ↑ e volte pela capela. Registre a altura dos pés antes de entrar e depois de voltar. Reaproveite o teste do vestíbulo 13 e rode os testes de passagem afetados. Informe como a janela foi aberta e quais verificações foram feitas em execução real.

5. Documente e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/14-portal-gotico-da-sacada.md. Indique a largura livre do vão, a altura da ponta em relação à soleira, o caminho do .blend, o GLB usado e o nó que recebe o modelo no Godot.

Termine com um exercício de cinco minutos no Blender: selecionar a pedra central, afastá-la 10 cm para cima no eixo vertical e observar quais juntas se abrem. Dê o nome real do objeto e explique como desfazer o movimento antes de salvar.

Com os testes aprovados, revise o diff, faça commit e push conforme o CLAUDE.md e confirme o hash remoto. Na resposta final, entregue a cena para F6, a prancha comparativa e o link completo do commit publicado.
