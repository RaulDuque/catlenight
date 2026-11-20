Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 11 — Altar de salvamento na Capela da Lua.

Quero chegar ao vitral, usar um altar para salvar meu progresso, fechar o jogo e continuar dali em outra execução. Use as ferramentas gratuitas já instaladas e os recursos nativos do Godot.

1. Guarde o prompt e prepare o piloto

Salve este texto integralmente em MD-usario/prompts/11-altar-de-salvamento.md. Leia CLAUDE.md, docs/ROADMAP.md e o relatório da Tarefa 10. Confira onde o projeto guarda a vida do jogador, a aquisição da relíquia, a vida da sentinela e a sala ativa.

Crie scenes/verification/11_altar_de_salvamento.tscn reaproveitando o piloto 10. O salvamento pertence ao piloto 11. Preserve as cenas de estudo anteriores e a entrada atual do F5.

2. Coloque o altar perto do vitral

Crie um altar de pedra simples e reconhecível pela câmera lateral. Posicione-o perto da lua crescente, com espaço suficiente entre o altar e a porta para que apenas uma indicação apareça de cada vez.

Quando o jogador estiver apoiado diante do altar, mostre “↑ Salvar progresso”. Reutilize a ação interagir. Um novo toque grava uma vez e mostra “Progresso salvo” após a escrita ter sucesso. Segurar a tecla deve permitir ler a confirmação. Afaste-se e confira que a porta continua oferecendo “↑ Voltar ao vestíbulo”.

3. Defina o que a gravação conserva

Use um único arquivo com versão de formato, por exemplo user://catlenight_piloto_11.json. Grave a identificação da capela e de um marcador seguro ao lado do altar, a vida atual do jogador, a aquisição do salto duplo e a vida atual da sentinela. Se ela tinha 1 ponto ao salvar, deve voltar com 1. Se estava derrotada, o caminho continua livre.

Ao carregar, coloque o jogador apoiado no marcador, em Z = 0, com a câmera da capela, a velocidade zerada e a lâmina recolhida. Atualize o indicador de vida e a presença da gema a partir do progresso restaurado. O altar preserva a vida com que o jogador chegou. Ele não concede cura.

Valide o arquivo inteiro antes de aplicar seus dados. Faça a gravação de modo que uma falha de escrita preserve o último salvamento válido. Se algo falhar, mostre uma mensagem honesta e mantenha a partida jogável.

4. Permita escolher como começar

Ao abrir o piloto 11, ofereça “Novo jogo” e “Continuar” em uma tela simples operável pelo teclado. Habilite “Continuar” quando houver um salvamento válido. “Novo jogo” começa no vestíbulo, com Vida 3/3, gema disponível e sentinela completa. O arquivo anterior só é substituído quando o jogador volta a usar o altar.

“Continuar” restaura a última gravação. As portas, quedas e derrotas conservam as regras já ensinadas nas tarefas anteriores. O jogador controla quando grava no altar.

5. Comprove que o progresso sobrevive ao fechamento do jogo

Crie um teste reproduzível com os dados de usuário isolados. Os testes precisam poder rodar mesmo quando eu já tiver uma partida pessoal salva. Registre os comandos das duas execuções:

- Primeira execução: comece um jogo novo, colete a gema, deixe o jogador com Vida 2/3 e a sentinela com 1 ponto. Chegue à capela pelos controles, salve no altar e encerre o processo.
- Segunda execução: abra um novo processo do Godot, escolha “Continuar” e confira sala, posição, câmera, Vida 2/3 e salto duplo. Volte à galeria: a gema continua coletada e um único golpe válido derrota a sentinela que tinha 1 ponto.
- Saia sem salvar essa derrota. Ao continuar novamente, a sentinela deve ter o 1 ponto da gravação. Depois salve com ela derrotada e confirme que esse novo estado também pode ser restaurado.
- Confira “Novo jogo” com uma gravação existente e verifique que sair antes de usar o altar preserva a gravação anterior. Teste também arquivo ausente e arquivo inválido usando apenas a pasta isolada.
- Rode o teste 10 e os testes das mecânicas compartilhadas que você alterar.

Salve uma captura real em MD-usario/relatorios/evidencias/11-altar-progresso-salvo.png. Enquadre o jogador junto ao altar, a confirmação e o indicador de vida. Registre como a janela foi executada.

6. Documente e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/11-altar-de-salvamento.md. Mostre um exemplo pequeno do conteúdo real do arquivo e explique onde o Godot o gravou no Windows. Indique qual função reúne os dados, qual valida a leitura e qual restaura o jogador e a sentinela.

Termine com um exercício de cinco minutos usando o menu: salvar com Vida 2/3, iniciar um jogo novo, observar Vida 3/3, fechar antes de chegar ao altar e escolher “Continuar”. Explique de onde vem o valor mostrado em cada abertura.

Com os testes aprovados, revise o diff, faça commit e push conforme o CLAUDE.md. Inclua o prompt, o relatório e a captura. Mantenha os arquivos de partidas pessoais fora do Git. Na resposta final, informe a cena para F6, os controles do menu e do altar, o resultado da restauração em outro processo e o link completo do commit publicado.
