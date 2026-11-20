Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 13 — Arte modular 3D do vestíbulo.

Quero abrir o jogo e reconhecer a entrada de um castelo gótico. O piso deve parecer feito de pedra, a parede deve ter profundidade e a porta alta da sacada deve chamar minha atenção desde a primeira visita. Quero aprender como uma peça feita no Blender vira parte de uma sala jogável no Godot.

1. Guarde o prompt e registre a aparência atual

Salve este texto integralmente em MD-usario/prompts/13-arte-do-vestibulo.md. Leia CLAUDE.md, docs/ROADMAP.md e os relatórios do arco, da visibilidade do personagem e do mapa.

Crie scenes/verification/13_vestibulo_do_castelo.tscn a partir do piloto 12. Antes da mudança visual, capture o vestíbulo pela câmera do jogo, com o protagonista parado em um ponto a partir do qual apareçam o arco e a sacada. Anote a posição e a direção do personagem para repetir o quadro depois. Mantenha o piloto 12 disponível para comparação e conserve a configuração atual do F5.

2. Modele um pequeno conjunto reutilizável no Blender

Use o Blender já instalado para criar três peças originais: um trecho de parede de cantaria, uma pilastra que marque a união entre trechos e uma faixa de acabamento para a borda visível do piso. Planeje as dimensões a partir da sala existente e do protagonista de 1,70 m. Use o arco de pedra já modelado como referência de escala e aparência.

Antes de detalhar, coloque duas cópias da parede lado a lado. Confira se as extremidades encaixam e se os relevos continuam legíveis à distância da câmera do jogo. Use materiais simples que permitam distinguir as pedras e as juntas. Escolha poucas variações de tom para os detalhes continuarem visíveis na vista lateral.

Salve o editável em arte-fonte/blender/vestibulo_modular.blend. Exporte as peças em GLB para assets/models/environment/vestibulo/. Documente a largura, a altura, a origem e a direção da face visível de cada peça. Quero conseguir selecionar uma parede no Godot, duplicá-la e saber quantos metros deslocar a cópia para encaixá-la na primeira.

3. Vista a sala preservando o percurso

Monte a parede e as pilastras atrás do plano de jogo. Alinhe a faixa de pedra ao piso que já sustenta o jogador. Aproveite o arco existente e sua transparência durante a travessia. Deixe as colisões a cargo dos corpos físicos atuais. Confira os recursos importados para evitar colisão adicional ou superfícies sobrepostas piscando.

Dê à porta elevada um contorno legível e uma luz mais quente que a parede ao redor. Do chão, quero perceber que há algo alcançável lá em cima. Sobre a sacada, quero enxergar o personagem e ler “↑ Entrar na capela”. Confira também o extremo direito da sala: a composição deve sugerir que o caminho continua até a galeria.

Use a câmera ortográfica atual com Size = 8. Avalie o resultado em 1280×720. Se um detalhe só aparecer com a câmera aproximada no editor, simplifique-o ou aumente seu tamanho no modelo.

4. Confira a arte pela câmera e a jogabilidade pelos controles

Capture novamente o primeiro enquadramento com o personagem na mesma posição e direção. Salve a comparação em MD-usario/relatorios/evidencias/13-vestibulo-antes-depois.png. Salve também 13-porta-na-sacada.png com o jogador apoiado diante da porta. Inspecione as imagens e registre o que realmente ficou legível, inclusive algum defeito visual que ainda mereça trabalho.

Jogue o percurso da cena 13 pelas ações reais: nasça no vestíbulo, passe sob o arco, vá à galeria, colete a relíquia, volte, use o salto duplo e entre na capela. Confira que os pés continuam apoiados em Y = 2,350 m na sacada. Abra M antes de entrar na capela e depois da travessia para conferir o marcador da sala atual.

Reaproveite os testes existentes do arco, da passagem e do mapa. Faça pelo menos uma validação carregando a própria cena 13, para detectar problemas introduzidos na montagem nova. Use dados de usuário isolados nas execuções de teste e registre se a janela abriu pelo editor ou por script.

5. Documente a técnica e publique

Atualize README.md e docs/ROADMAP.md. Salve o relatório em MD-usario/relatorios/13-arte-do-vestibulo.md. Explique o caminho de uma peça específica: nome do objeto no Blender, arquivo GLB exportado, nó que o instancia no Godot e posição em relação ao plano Z = 0. Indique também onde fica a colisão que sustenta os pés.

Termine com um exercício de cinco minutos usando duas cópias da parede em uma cena de estudo temporária. Mostre como encaixá-las usando a largura do módulo e como deslocar uma delas 10 cm para enxergar a junta abrir. Dê os valores reais dos campos no Inspetor para eu conseguir repetir.

Com os testes aprovados, revise o diff, faça commit e push conforme o CLAUDE.md e confira o hash remoto. Na resposta final, informe a cena para F6, o caminho do .blend, a largura do módulo de parede, onde abrir a comparação visual e o link completo do commit publicado.
