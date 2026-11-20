Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 15-C — Sala de blocos do prólogo e cenário híbrido 2.5D.

OBJETIVO

Quero aprender a construir o castelo em duas etapas. Primeiro, quero jogar o percurso com blocos, rampas e cores simples, enxergando exatamente onde o personagem pisa. Depois, quero ligar a arte e percorrer o mesmo lugar com torre, lua e arquitetura ao fundo. Quero também conseguir editar um trecho do mapa pela matriz e conferir a alteração no Godot.

A engine deste projeto é Godot 4 com física 3D. O personagem se desloca em X, pula em Y e permanece em Z = 0. A câmera observa de lado, em projeção ortográfica. Blender é a ferramenta de modelagem. O protagonista 3D e sua corrida já existem no projeto.

1. PARTA DA ENTREGA QUE JÁ FUNCIONA

Salve este prompt integralmente em MD-usario/prompts/15c-blockout-do-prologo.md. Leia CLAUDE.md, docs/ROADMAP.md, docs/GAME_DESIGN.md e MD-usario/relatorios/15-escadaria-exterior.md. Confira o estado atual da branch e use como referência a entrega 15-B do commit 7678af125ce1ee0fbaed91c0ff3485df24d5e976. Trabalhe sobre a versão atual do projeto.

Abra scenes/verification/15_escadaria_exterior.tscn e scenes/environment/escadaria_exterior.tscn. Identifique o jogador, a câmera, os patamares, Lance/Rampa/Colisao, o GLB dos degraus, a saída direcional e os marcadores de chegada. Reaproveite essas peças. Os 12 degraus existentes sobem 2,64 m ao longo de 5,52 m horizontais. Essa é a referência física de partida.

Crie scenes/verification/15c_blockout_do_prologo.tscn para abrir com F6. Preserve a cena 15-B como exercício independente e o F5 na cena principal atual.

2. MONTE A FAIXA INFERIOR DO PRÓLOGO

Abra a referência local assets-exemple-2d/Final Stage - _Bloodlines_.png. Consulte a faixa inferior da prancha de Revned para organizar o percurso da direita para a esquerda:

patamar inferior → escadaria exterior → patamar superior → limiar iluminado → salão horizontal → estrado com trono provisório.

O jogador começa à direita, olha para −X e sobe segurando ←. Ao chegar ao limiar e continuar para a esquerda, deve conseguir atravessar o salão e alcançar o estrado. Com → faz o caminho de volta. No piloto 15-C, organize a ligação ao salão de modo que nenhum gatilho antigo de retorno capture o jogador enquanto ele avança. Documente como esse percurso se relaciona com o vestíbulo já construído. Confira que a rota de estudo anterior entre vestíbulo, galeria e capela continua jogável na cena 15-B.

Use o alcance da câmera, a altura de 1,70 m do protagonista e o tempo de caminhada para definir as dimensões do salão. O mapa completo serve para ler a disposição dos espaços. A câmera enquadra o trecho que o jogador atravessa. O trono pode ser reconhecível com três formas: base elevada, assento e encosto alto. As salas superiores, o chefe e a sequência de diálogo ficam para uma tarefa posterior.

3. CRIE UMA MATRIZ EDITÁVEL E UM GERADOR PEQUENO EM GDSCRIPT

Use a matriz no trecho novo do salão e do estrado. A escadaria aprovada continua sendo uma peça reutilizável com sua própria rampa. Quero que o gerador resolva um problema real da fase, sem reconstruir a mesma colisão duas vezes.

Escolha um arquivo de dados simples e legível no Cursor, como um JSON com um array de strings. Comece com uma legenda pequena: vazio, sólido e, se usados no trecho, os dois sentidos de rampa. Declare o tamanho de cada célula em metros, onde fica a origem, como linhas e colunas viram X e Y e qual lado de uma rampa é o mais alto. Guarde portas e chegadas como marcadores explícitos se isso aproveitar melhor o sistema atual.

Faça o script gerar a geometria visível de estudo e a respectiva colisão 3D a partir dos mesmos dados. Una trechos contíguos de piso onde isso evitar emendas que prendem os pés. Uma rampa desenhada como rampa precisa oferecer uma superfície inclinada à física. Ao reconstruir o trecho, substitua apenas os nós gerados e mantenha os marcadores e a arte manual. Duas reconstruções consecutivas devem produzir as mesmas peças, sem duplicatas. Se a matriz tiver um símbolo desconhecido ou uma linha inválida, indique a linha e a coluna do problema.

Escolha o caminho mais simples para eu editar o arquivo e enxergar o resultado. Documente se a atualização acontece ao abrir a cena, executar o piloto ou usar um comando no editor. Não preciso de um editor de mapas completo.

4. ORGANIZE A SALA EM GEOMETRIA JOGÁVEL E ARTE

Deixe a árvore da cena fácil de estudar. Quero localizar os corpos físicos, as malhas de debug, os elementos visuais e os marcadores de interação. O modo de blocos precisa mostrar os limites do piso e da rampa, os patamares e o estrado com cores legíveis. Use uma grade discreta ou marcas de escala onde ajudarem a medir o personagem e o pulo.

Acrescente uma forma simples de alternar entre “Blocos” e “Com arte” na própria execução. Confira uma tecla livre no Input Map e documente-a. A troca altera a apresentação e conserva o mesmo jogador, as mesmas colisões, a posição, a câmera e o estado da partida. Quero poder parar no meio da rampa e comparar as duas vistas sem deslocar os pés.

5. FAÇA UMA PROVA DE ARTE HÍBRIDA NO EXTERIOR

Concentre o acabamento artístico desta tarefa no exterior. O salão e o trono podem permanecer em blocos. Use imagens originais do Catlenight em Sprite3D ou QuadMesh para substituir visualmente a torre provisória e compor o céu com a lua. Mantenha os degraus, a mureta e o limiar em 3D onde o volume ajuda a entender a passagem.

Organize as distâncias em Z a partir da câmera real e confira seus planos de recorte antes de posicionar o horizonte. Use uma textura opaca para um fundo contínuo e recorte transparente onde a silhueta da torre exigir. Para uma superfície próxima que deva receber a luz do portão, use um material iluminado e confira o efeito na janela. Use normal map apenas se o relevo fizer diferença no enquadramento do jogo. Registre os materiais, as distâncias e as luzes que realmente funcionaram.

Mantenha a projeção ortográfica. Use sobreposição, contraste, cor e escala desenhada para transmitir distância. Se a câmera atual ficar fixa por trecho, não acrescente paralaxe artificial só para demonstrar a técnica. Priorize três leituras em 1280×720: as botas sobre a escada, a diagonal da subida e o vão iluminado no alto.

Use a prancha do jogo como referência de composição. O gerador usa dados de sala do Catlenight e as imagens usadas em execução devem ser originais ou ter licença de reutilização registrada. O trabalho pode ser concluído com os recursos locais, mesmo se o SymphonyRecomp estiver aguardando a imagem do disco.

6. VALIDE O PILOTO QUE EU VOU JOGAR

Execute a própria cena 15-C com a física real e as ações do Input Map. Reaproveite os testes existentes onde fizer sentido e confira:

- Nascer no patamar inferior direito, subir com ←, parar no meio e continuar. Anote X e Y dos pés no nascimento, na parada e no alto. Compare com a 15-B.
- Atravessar o limiar, chegar ao estrado e voltar com →. Meça separadamente o tempo do nascimento ao limiar e do limiar ao trono. Confira as emendas entre as peças e o Z do jogador durante a travessia.
- Alternar a arte com o personagem parado no meio da rampa. Confira os pés, a câmera e a colisão antes e depois. Repita o percurso nos dois modos.
- Alterar uma célula de teste no trecho gerado e comprovar que o desenho e a colisão mudam juntos. Repetir a geração e verificar que a quantidade de corpos não aumenta. Restaurar os dados originais ao concluir.
- Executar tests/verificar_escadaria_15.gd e os testes de passagem, mapa ou salvamento se esses sistemas forem alterados. Use dados de usuário isolados.

Salve em MD-usario/relatorios/evidencias/ uma prancha 15c-blocos-e-arte.png com o mesmo enquadramento da escada nos dois modos e uma captura 15c-chegada-ao-trono.png pela câmera do jogador. Registre quais testes rodaram, os resultados e se a janela abriu por script ou pelo F6 do editor.

7. DOCUMENTE PARA EU APRENDER E PUBLIQUE

Atualize docs/DECISIONS.md com a decisão de arte híbrida, docs/GAME_DESIGN.md com o percurso, docs/ROADMAP.md com o estado real e o README com a cena e os controles. Salve MD-usario/relatorios/15c-blockout-do-prologo.md.

No relatório, siga uma célula real da matriz: mostre o caractere, sua linha e coluna, a posição em metros que o gerador calculou, a forma de colisão resultante e o ponto em que os pés se apoiam. Depois escolha a torre e mostre seu arquivo de imagem, seu nó na cena, a posição Z e o material. Quero conseguir abrir o Cursor e o Godot e seguir os dois exemplos.

Termine com um exercício de cinco minutos: indique exatamente uma célula que eu possa alterar para criar ou estender um pequeno degrau, como atualizar a cena, como testar o apoio dos pés e como restaurar o caractere original.

Com a entrega validada, revise o diff, faça commit e push conforme o CLAUDE.md e confira o hash remoto. Na resposta final, entregue a cena para F6, a tecla que alterna blocos e arte, o caminho da matriz, os dois tempos de percurso, a prancha comparativa e o link completo do commit.
