Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 03 até obter uma peça de cenário modelada no Blender, importada no Godot e atravessável pelo jogador da Tarefa 02.

OBJETIVO DE ESTUDO

Quero aprender o caminho completo de uma peça de cenário: definir medidas, modelar em 3D, posicionar a origem, aplicar materiais, exportar em GLB, montar uma cena reutilizável no Godot e testar a peça durante o jogo. Ao pressionar F5, quero poder andar com a seta direita e passar sob o primeiro arco de pedra do castelo.

1. PREPARE A ETAPA

Salve este prompt integralmente em MD-usario/prompts/03-arco-de-pedra.md. Leia CLAUDE.md, o relatório 02, a cena principal e tests/verificar_movimento.gd. Confira as posições reais do nascimento e da plataforma antes de escolher onde colocar o arco.

Use o Godot 4.7.2 já validado. Procure o Blender instalado no Windows e confira a versão pelo executável. Se estiver ausente, obtenha uma distribuição estável gratuita pelo site oficial do Blender e prepare-a fora do projeto. Você pode usar a API Python nativa do Blender em modo background para criar o modelo e exportá-lo. Se houver um bloqueio real, registre a etapa exata que conseguiu executar.

2. MODELE UMA PEÇA ORIGINAL

Crie um arco gótico de pedra com dois pilares, bases ligeiramente mais largas, pedras em cunha formando um topo pontudo e uma pedra central destacada. Dê espessura real às peças. Use um pequeno chanfro nas arestas para a luz revelar a forma na câmera do jogo. Use dois ou três tons próximos de pedra e confira se as juntas continuam legíveis na resolução de 1280×720.

Trabalhe em metros. Use o personagem de 1,70 m de altura e 0,50 m de profundidade como referência. Comece com aproximadamente 2,4 m de abertura entre as faces internas dos pilares. Garanta ao menos 2,3 m de altura livre ao longo de toda a faixa ocupada pelo corpo durante a travessia a pé. Meça o vão depois de posicionar e girar a peça.

Coloque a origem no centro da passagem, no nível do piso. Salve o modelo editável em arte-fonte/blender/arco_de_pedra.blend e exporte a peça em assets/models/environment/arco_de_pedra.glb. Use arte-fonte/.gdignore para que o Godot importe somente o GLB deste fluxo. Confira a escala em metros depois da importação. Se criar um script para gerar o modelo, guarde-o junto ao .blend e documente o comando para reproduzi-lo.

3. INTEGRE O ARCO À SALA

Crie uma cena reutilizável, por exemplo scenes/environment/arco_de_pedra.tscn, com o GLB instanciado como visual e colisões estáticas simples para a estrutura. Deixe o vão central livre. Monte as colisões na cena do Godot para que uma nova exportação do modelo preserve a configuração da peça.

Instancie o arco em um trecho de chão alcançável a partir do nascimento, de preferência antes da plataforma. Posicione um pilar de cada lado do plano Z = 0. Gire a peça levemente em torno de Y e confira o resultado pela CameraLateral. Escolha o ângulo observando duas coisas: se o arco continua reconhecível na imagem e se o jogador continua visível o bastante para acompanhar a travessia. Se o pilar da frente esconder o bloco por tempo demais, ajuste primeiro o ângulo ou a espessura do pilar.

Preserve o controlador, os controles, as dimensões do jogador e o enquadramento Size = 8. A peça deve funcionar com a sala que já temos.

4. TESTE NO JOGO

- Importe o GLB e abra o projeto pela cena principal. Confira materiais, orientação, escala e contato das bases com o chão.
- Faça o jogador atravessar andando desde antes até depois do arco e voltar pelo mesmo caminho. Use as ações normais de movimento e a física real. Registre as posições X de entrada e saída, a altura dos pés e o maior desvio em Z.
- Verifique se as colisões representam a pedra: uma consulta física na altura de um pilar deve encontrá-lo, enquanto o corredor na altura do tronco do jogador deve estar livre.
- Execute novamente tests/verificar_movimento.gd e registre o resultado. Se a peça interferir no percurso anterior, corrija sua colocação ou a geometria da colisão.
- Salve uma captura do modelo no Blender em vista de três quartos e uma captura real do Godot com o personagem sob o arco. Use MD-usario/relatorios/evidencias/ e nomes iniciados por 03-. A primeira imagem deve mostrar a construção da peça; a segunda deve mostrar o que o jogador vê.

5. DOCUMENTE PARA EU CONSEGUIR REPETIR

Atualize docs/ROADMAP.md e salve o relatório em MD-usario/relatorios/03-arco-de-pedra.md. Registre os arquivos, a versão do Blender, as medidas finais, a orientação, os testes realizados e as pendências reais.

Inclua um guia curto para alguém abrindo o .blend pela primeira vez. Explique como selecionar uma pedra, localizar suas dimensões, visualizar a origem e exportar novamente para o mesmo GLB. Mostre onde conferir a peça reimportada no Godot.

Termine com um exercício de cinco minutos: alterar a cor da pedra central no Blender, reexportar, abrir o jogo e localizar a mudança pela câmera lateral. Explique como restaurar a cor. Esse exercício precisa funcionar sem recriar a cena ou refazer as colisões.

O entregável desta etapa é um arco completo e reutilizável. O protagonista continua com a malha provisória até a Tarefa 04.
