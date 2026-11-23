Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 15-E — Conferência de escala e reconstrução estrutural do prólogo.

Quero aprovar as proporções do mapa antes de trabalhar na arte. Use blocos simples, a prancha original e o jogador de 1,70 m. Ao final, quero enxergar a correspondência entre o mapa de referência e as colisões do jogo e percorrer a escadaria interna inteira com os controles normais.

1. Guarde o prompt e estabeleça a comparação

Salve este texto em MD-usario/prompts/15e-escala-e-escadas-do-prologo.md. Leia CLAUDE.md, docs/PLANTA_DO_PROLOGO.md, dados/estrutura_do_prologo.json e o relatório 15-D. Use a 15-D como comparação reproduzível. Crie a cena scenes/verification/15e_prologo_em_escala.tscn e dê a ela seus próprios dados de geometria. Reaproveite o gerador, o jogador e os testes existentes.

2. Meça os lances completos na prancha

Abra assets-exemple-2d/Final Stage - _Bloodlines_.png na resolução nativa. Amplie por vizinho mais próximo e marque as superfícies onde os pés apoiariam. Na escada exterior, localize a mudança de inclinação entre o patamar superior e o primeiro degrau, depois a mudança entre o último degrau e o patamar inferior. Use a borda caminhável. Corrimão, base de alvenaria e linhas entre os painéis têm outras funções no desenho.

Mostre na mesma imagem esses dois extremos e os dois pontos usados na 15-D. Informe se os antigos cobriam o lance inteiro ou só um segmento. Repita o procedimento para o lance inferior, o descanso e o lance superior da escada interna. Meça também as faces internas das paredes da galeria e o pé-direito livre. Confira a origem dos 189 px usados antes: indique se o ponto superior escolhido cai na face de baixo do teto ou dentro da pedra.

Determine primeiro as proporções em pixels, que já podem ser verificadas mesmo com a escala absoluta pendente. Para converter em metros, procure um quadro disponível do jogo original com o personagem em pé e uma peça arquitetônica reconhecível na prancha. Use a peça para relacionar as duas resoluções e documente a hipótese de equivalência com o protagonista do Catlenight. Se faltar essa evidência, use uma escala de trabalho explícita, apresente o que ainda é estimativa e prossiga. Evite calibrar o tamanho da escada usando o desnível antigo da própria escada.

3. Construa as superfícies medidas

Aplique a mesma escala em X e Y. Refaça a escada exterior com os extremos completos. Na escada interna, construa o patamar inferior, o primeiro lance, o descanso intermediário, o segundo lance e a chegada à galeria. Acerte os pisos, paredes e tetos ao redor desses volumes. Confira o pé-direito ao longo das duas subidas.

A interação em ↑ pode continuar como ligação provisória entre painéis onde o acesso original estiver incerto. Coloque a chegada no início do percurso interno: dali até a galeria, o jogador deve ganhar caminhando o desnível dos dois lances. Dê ao retorno uma posição segura e documente os dois marcadores. No salão, confira quais partes do teto são fechadas pelo próprio piso superior e quais realmente precisam de uma peça ou de uma abertura.

4. Resolva o apoio do jogador com uma medição local

Teste a inclinação medida com o controlador real. Se ele enroscar, descubra em qual emenda, sentido e quadro perde o avanço. Inspecione a forma do jogador, a normal da superfície e o encontro da rampa com o patamar. Experimente a menor correção local que permita caminhar pela inclinação da referência nos dois sentidos. Preserve altura, velocidade de caminhada, salto e Z = 0. Registre qualquer desvio das medidas que ainda for necessário.

No meio de cada tipo de rampa, meça separadamente a origem do corpo, o contato físico e o ponto mais baixo da sola visível do pé de apoio. Compare a sola com a superfície no mesmo X da sola. Capture uma vista lateral aproximada com a colisão ligada. A meta é eu conseguir distinguir apoio pelo canto da caixa, folga visual da bota e perda real de contato.

5. Prove a forma da sala e o percurso

Gere uma sobreposição por setor usando o contorno extraído dos dados reais da cena 15-E. Alinhe cada painel da prancha por um marco identificado e use uma única escala; não estique cada painel para fazê-lo coincidir. Marque os extremos dos lances, o descanso, as paredes, os tetos e as adaptações. Guarde a comparação com a referência junto ao material local de estudo. Salve em MD-usario/relatorios/evidencias/15e-planta-em-escala.png uma planta própria do Catlenight com régua e cotas para o repositório.

Rode um percurso contínuo desde “Novo jogo”. Suba a escada exterior, pare no meio, atravesse o salão, segure ← e pule contra a parede do trono. Vá ao acesso superior. Registre a posição no início da escada interna, no descanso e no topo. Visite as duas extremidades da galeria e volte ao piso inicial. Verifique também a descida e a parada em cada lance. Use consultas de física para confirmar os tetos e os vãos. Meça os tempos por trecho a partir da entrada em cada trecho.

O teste deve detectar uma escada interna encurtada: chegar à galeria só conta depois de passar pelo descanso e subir o segundo lance pelos controles. Repita a regressão da 15-D se alterar código compartilhado.

6. Documente e publique

Atualize docs/PLANTA_DO_PROLOGO.md com a tabela “15-D / referência medida / 15-E”. Inclua largura total, desnível exterior, comprimento dos dois lances internos, largura do descanso, pé-direito e altura da galeria. Identifique a fonte de cada medida e o que continua provisório. Preserve o relatório 15-D como histórico.

Atualize README.md e docs/ROADMAP.md. Salve MD-usario/relatorios/15e-escala-e-escadas-do-prologo.md. Termine com um exercício simples: abrir a planta, escolher os dois extremos de um lance e conferir no Inspetor o avanço horizontal e o desnível correspondentes.

Com os testes aprovados, faça commit e push conforme o CLAUDE.md. Na resposta final, entregue a cena para F6, a planta cotada, o caminho da sobreposição local, as medidas antes/depois e o link completo do commit.
