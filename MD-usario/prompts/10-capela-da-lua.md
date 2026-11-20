Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 10 — A passagem da sacada e a Capela da Lua.

Quero começar no vestíbulo, ver a passagem iluminada no alto, buscar a relíquia na galeria, voltar com o salto duplo e entrar na primeira sala secreta do castelo. Ao sair da capela, quero reaparecer em pé na mesma sacada e poder descer para continuar jogando.

1. Guarde o prompt e leia o projeto

Salve este texto integralmente em MD-usario/prompts/10-capela-da-lua.md. Leia CLAUDE.md, docs/ROADMAP.md e os relatórios 05 e 09. Confira como as salas atuais definem destino, chegada, enquadramento da câmera e ponto de retorno após queda. Confira também como a cena 09 posiciona a sacada e a janela.

Crie scenes/verification/10_capela_da_lua.tscn reaproveitando o piloto 09. Mantenha a cena 09 disponível para o exercício do salto duplo e conserve a entrada atual do F5.

2. Faça da janela uma passagem que o jogador consegue entender

Aproveite o vão iluminado que já chama a atenção no alto da sacada. Dê a ele aparência de passagem no tamanho do protagonista. Preserve o topo da laje em Y = 2,350 m e o espaço necessário para aterrissar e descer.

Crie a ação interagir e associe a seta para cima, após conferir o Input Map. Quando o jogador estiver apoiado na sacada e diante da passagem, mostre “↑ Entrar na capela”. Um novo toque nessa tecla leva à capela. Passar diante da porta durante o salto ou pousar segurando a tecla deve permitir continuar na sacada. Na capela, use a mesma tecla e a indicação “↑ Voltar ao vestíbulo”.

A altura da sacada já é o requisito de acesso. Reaproveite essa regra física. As passagens horizontais entre vestíbulo e galeria continuam funcionando com as setas laterais.

3. Construa a Capela da Lua

Crie a sala reutilizável em scenes/environment/capela_da_lua.tscn. Faça uma sala pequena, inteiramente 3D, com piso caminhável, entrada reconhecível e um vitral de lua crescente na parede do fundo. Use geometria e materiais originais. O objetivo visual é chegar, reconhecer a silhueta da lua pela câmera lateral e perceber por onde voltar. Deixe espaço para andar entre a entrada e o vitral.

Use um único Jogador e a CameraLateral existente. Configure os marcadores de chegada, câmera e retorno da capela pelo padrão das outras salas. Na volta, coloque os pés sobre a sacada com margem da borda. Segurar a tecla durante uma travessia deve gerar uma única troca.

4. Valide o percurso completo

Crie tests/verificar_capela_10.gd e use as ações reais do Input Map. Faça um percurso contínuo desde o início, sem teletransportar o jogador para simular a conquista da relíquia ou o pouso na sacada.

Confira e registre:
- Antes da coleta, o salto simples e a tecla de interação deixam o jogador no vestíbulo.
- Depois da coleta, cruzar a área da porta no ar e pousar com a tecla já apertada deixam o jogador na sacada. Soltar e apertar de novo efetua uma única entrada.
- Ao entrar, o jogador chega apoiado no piso da capela. A câmera enquadra a sala, o vitral aparece e o aviso da porta some quando o jogador se afasta.
- Ao voltar, os pés permanecem apoiados na sacada por vários quadros. Registre a sala ativa, a posição dos pés e a posição da câmera nas duas direções.
- A vida atual e a habilidade atravessam a porta com o mesmo jogador. Verifique a vida também com um valor abaixo do máximo, para detectar uma restauração acidental.
- Depois de descer da sacada, ainda é possível ir até a galeria e voltar. Rode os testes 05 e 09 e os testes correspondentes a qualquer outro comportamento compartilhado alterado.

Salve duas capturas reais pela câmera do jogo em MD-usario/relatorios/evidencias/: 10-entrada-na-sacada.png, com a indicação de entrada, e 10-capela-da-lua.png, com o personagem e o vitral. Registre como a cena foi executada.

5. Documente para eu aprender e publique

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/10-capela-da-lua.md com os arquivos alterados, testes, resultados e pendências. Explique o caminho de um toque na seta para cima: onde a ação é lida, quem verifica se os pés estão apoiados, quem escolhe o marcador de destino e quem move a câmera.

Termine com um exercício de cinco minutos no Inspetor: deslocar o marcador de chegada dentro da capela em 0,5 m para um lado seguro, entrar de novo e observar o que mudou. Indique o nó, a coordenada original e como restaurá-la.

Com os testes aprovados, revise o diff, faça commit dos arquivos da tarefa e push conforme o CLAUDE.md. Confira o hash remoto. Na resposta final, entregue a cena para F6, o percurso pelos controles e o link completo do commit publicado.
