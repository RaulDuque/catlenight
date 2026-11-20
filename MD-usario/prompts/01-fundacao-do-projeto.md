Você vai trabalhar comigo em um projeto pessoal de estudo de desenvolvimento de jogos. Sou o responsável pelo projeto e quero entender como cada parte funciona para conseguir alterá-la sozinho.

OBJETIVO DO JOGO

Desenvolver um metroidvania gótico original em 2.5D, com exploração de salas conectadas, combate de ação e progressão do personagem. Castlevania: Symphony of the Night é referência para estudar exploração, ritmo e progressão. Crie conteúdo próprio para o projeto. Use formas geométricas provisórias nesta etapa.

O cenário, o personagem, a iluminação e a física serão 3D. A câmera será lateral e ortográfica. A convenção do jogo será X para deslocamento horizontal, Y para altura e Z para profundidade. Quando o controlador for implementado, o personagem deverá permanecer no plano Z definido para a fase.

TAREFA 01 — FUNDAÇÃO E CENA DE VERIFICAÇÃO

1. Inspecione a pasta aberta e preserve todo conteúdo existente. Confira se Godot 4 e Git estão disponíveis. Registre as versões que de fato verificar. Use Godot 4 estável e GDScript. Adote um nome provisório para o projeto e registre que ele pode ser trocado.

2. Crie ou configure o projeto Godot e organize estes arquivos:
   - README.md — objetivo, versão do Godot, como abrir e executar.
   - CLAUDE.md — regras de trabalho, convenção dos eixos e limites da etapa.
   - docs/GAME_DESIGN.md — visão do jogo, pilares e primeiro objetivo jogável.
   - docs/ROADMAP.md — etapas, critérios de conclusão e status real de cada uma.
   - docs/DECISIONS.md — decisões tomadas, motivo e impacto.
   - MD-usario/prompts/01-fundacao-do-projeto.md — cópia integral deste prompt.
   - MD-usario/relatorios/01-fundacao-do-projeto.md — entrega e validação da etapa.

3. Crie uma cena inicial 3D e configure-a como cena principal. Monte um chão visível com colisão estática, um bloco provisório para marcar a posição do personagem, uma luz e uma Camera3D ortográfica lateral. Posicione a câmera para enquadrar o plano XY. Use somente os nós e recursos necessários para esse teste. Movimentação, combate, inimigos e interface entram nas próximas tarefas.

4. Prepare o .gitignore para o Godot. Se ainda não houver repositório Git e o Git estiver disponível, inicialize um repositório local. Preserve as alterações existentes e deixe publicação, remotos e push para quando eu pedir.

5. Use as ferramentas disponíveis para validar a importação do projeto, o carregamento da cena principal e, se houver acesso gráfico, a execução pela janela. Registre separadamente o que foi verificado automaticamente e o que foi observado em tela. Se o Godot estiver ausente, faça o que puder na pasta, documente como instalar a versão adequada e marque a execução como pendente.

REGRAS DE APRENDIZADO E ORGANIZAÇÃO

- Use ferramentas gratuitas e documente a função de qualquer pacote, extensão ou skill que adicionar. Para esta etapa, priorize os recursos nativos do Godot.
- Salve cada prompt antes de implementar a tarefa correspondente. Registre na mesma pasta qualquer prompt complementar que eu aprovar.
- Explique os nós novos em linguagem direta, com o caminho da cena no editor e a propriedade que eu posso alterar para testar cada conceito.
- Atualize o roadmap ao concluir a tarefa e deixe claro quais critérios foram verificados.
- Trabalhe somente na Tarefa 01. Apresente o resultado antes de avançar.

CRITÉRIOS DE ACEITE

- O projeto tem uma cena principal configurada.
- A cena contém chão com colisão, bloco provisório, luz e câmera ortográfica lateral.
- Ao executar com F5, espera-se ver a cena em perspectiva lateral e o bloco apoiado visualmente sobre o chão. Registre se esse teste foi executado.
- O prompt, as decisões, o roadmap e as instruções para abrir o projeto estão salvos nos caminhos indicados.

RELATÓRIO FINAL

Informe os arquivos criados ou modificados, a versão do Godot verificada, os testes executados e o que ainda falta conferir. Inclua um exercício de cinco minutos para eu alterar o tamanho ortográfico da câmera no Inspector, observar a diferença ao rodar a cena e restaurar o valor original.
