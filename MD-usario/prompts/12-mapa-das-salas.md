Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 12 — Mapa das salas exploradas.

Quero apertar M durante o jogo e reconhecer o caminho que percorri. No começo, vejo só o vestíbulo. Depois de andar até a galeria, vejo as duas salas ligadas. A Capela da Lua aparece pela primeira vez quando entro nela. Ao continuar uma partida salva no altar, quero abrir o mapa e reconhecer onde estou.

1. Guarde o prompt e prepare o piloto

Salve este texto integralmente em MD-usario/prompts/12-mapa-das-salas.md. Leia CLAUDE.md, docs/ROADMAP.md e os relatórios 10 e 11. Localize o código que confirma uma troca de sala, o que inicia “Novo jogo” e o que restaura “Continuar”.

Crie scenes/verification/12_mapa_das_salas.tscn reaproveitando o piloto 11. Preserve a cena 11 para o exercício de salvamento e mantenha a entrada atual do F5.

2. Registre a descoberta das salas

Use identificadores estáveis para o vestíbulo, a galeria e a capela. Em “Novo jogo”, marque o vestíbulo como visitado. Nas travessias, registre a sala de destino quando a troca for concluída. Ver a janela da sacada, obter a gema ou chegar perto de uma porta ainda não revela a capela.

Uma revisita muda a indicação de localização atual sem duplicar a descoberta. Leia a sala atual do mesmo estado que já orienta as transições e a câmera.

3. Desenhe um mapa que explique o percurso

Confira se M está livre no Input Map e crie a ação abrir_mapa. Um toque abre o mapa durante a partida. Outro toque fecha. Mostre na própria tela como voltar ao jogo.

Use os controles 2D nativos do Godot para desenhar sobre a cena 3D. Coloque o vestíbulo no centro, a galeria à direita e a capela acima do lado da sacada. Essa disposição representa as portas que o jogador atravessa. A posição X = 48 da câmera da capela serve ao enquadramento da cena e não determina a posição dela no desenho.

Mostre o nome das salas visitadas, as ligações já percorridas e um marcador “Você está aqui” na sala atual. Enquanto a capela estiver por descobrir, o desenho deve guardar o segredo da passagem.

Com o mapa aberto, pause o jogo e mantenha o comando de fechar disponível. Quero poder consultar o mapa perto da sentinela sem perder vida. Ao fechar, retome a partida do mesmo ponto. X, Espaço e ↑ apertados durante a consulta não devem produzir golpe, pulo, passagem ou salvamento ao voltar.

4. Integre ao altar e preserve as partidas

Reaproveite o fluxo da Tarefa 11. O altar grava também as salas descobertas. “Continuar” restaura o mapa com a capela como sala atual. “Novo jogo” começa com apenas o vestíbulo descoberto e conserva o arquivo anterior até a próxima gravação no altar.

Confira uma gravação válida do formato 11 em uma pasta de teste. No percurso do piloto 11, chegar ao altar exigia atravessar vestíbulo, galeria e capela. Use esse fato para recuperar o mapa de uma gravação antiga. Documente essa escolha. Carregar o arquivo antigo deve funcionar antes de qualquer nova escrita. Isole os dados de teste da minha partida pessoal.

5. Valide pelo percurso jogável

Use ações do Input Map e a física real. Abra o mapa em quatro momentos: nascimento no vestíbulo, primeira chegada à galeria, retorno ao vestíbulo com a relíquia e primeira entrada na capela. Registre a sala atual e as salas reveladas em cada momento. No terceiro, a capela ainda deve estar escondida.

Abra o mapa na galeria com a sentinela em marcha. Mantenha-o aberto por mais de 1 segundo real e compare posição, vida e estado do golpe antes e depois. Feche e confirme que a patrulha volta a andar. Teste também abrir e fechar perto do altar: consultar o mapa por si só não grava a partida.

Salve no altar, encerre o processo, abra outro e escolha “Continuar”. Confirme as três salas no mapa, o marcador na capela e os valores gravados de vida, relíquia e sentinela. Rode os testes 10, 11 e os demais afetados pelas mudanças.

Salve duas capturas reais em MD-usario/relatorios/evidencias/: 12-mapa-primeira-visita.png, só com o vestíbulo, e 12-mapa-na-capela.png, com o caminho completo. Registre como o piloto foi executado.

6. Documente e publique

Atualize o README e docs/ROADMAP.md. Escreva MD-usario/relatorios/12-mapa-das-salas.md. Explique com os nomes reais dos arquivos e funções como entrar numa sala faz aparecer um novo trecho no mapa e como M ainda consegue fechá-lo com a física pausada.

Termine com um exercício de cinco minutos: abra o mapa no vestíbulo antes de buscar a gema, depois de voltar com ela e depois de visitar a capela. Indique o que observar para distinguir “tenho a habilidade para entrar” de “já visitei esta sala”.

Com os testes aprovados, revise o diff, faça commit e push conforme o CLAUDE.md e confira o hash no remoto. Na resposta final, informe a cena para F6, a tecla do mapa, o resultado do teste de pausa e o link completo do commit publicado.
