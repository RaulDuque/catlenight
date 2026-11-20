Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 04-C usando o arquivo que já baixei do Mixamo:

arte-fonte/mixamo/protagonista_hunyuan_corrida.fbx

1. Registre e confira a entrada

Salve este prompt integralmente em MD-usario/prompts/04c-corrida-no-godot.md. Leia o relatório da Tarefa 04, scenes/player/jogador.tscn e scenes/player/jogador.gd para entender como Visual vira o personagem e como o controlador move o corpo.

Abra o FBX no Blender. Confira se contém a malha do meu personagem, o esqueleto ligado a ela e um clipe de corrida. Reproduza o clipe por dois ciclos e observe ombros, mãos, joelhos e botas. Registre o nome real do clipe, sua duração e se o personagem avança ao longo da animação. Preserve o FBX original.

2. Prepare o modelo para o jogo

Use a pose de referência para conferir a altura de 1,70 m, as solas no piso e a frente voltada para +X no Godot. Preserve a flexão natural dos joelhos durante a corrida. Se o clipe deslocar o personagem para a frente a cada ciclo, corrija o avanço na cópia de trabalho, mantendo o balanço do tronco e o movimento vertical do quadril.

Exporte a malha, o esqueleto e a animação juntos em assets/models/characters/protagonista_hunyuan_corrida.glb. Confira a reprodução do clipe após a importação no Godot.

3. Monte a cena jogável do piloto

Crie scenes/verification/04c_corrida_mixamo.tscn reaproveitando a sala atual, com chão, arco, plataforma e câmera lateral Size = 8. Reutilize o jogador e o controlador existentes. Troque o modelo sob Visual apenas na instância do piloto. Mantenha a cena principal com o manequim para comparação.

Faça a corrida entrar em loop quando o personagem estiver apoiado e se deslocando horizontalmente. Inicie o clipe na entrada desse estado para que ele avance normalmente pelos quadros. Ao soltar a seta, use uma pose de repouso estável. Durante o pulo, suspenda a corrida e retome-a ao aterrissar se ainda houver movimento. Para este piloto basta o clipe que já temos.

O controlador continua responsável pelo deslocamento de 3,5 m/s, pelo pulo de 5,5 m/s e pela orientação de Visual. Preserve a colisão e o plano Z = 0.

4. Teste o percurso completo

Execute a cena do piloto. Corra para a direita sob o arco, solte a tecla, volte para a esquerda e pule até a plataforma. Confira se o perfil acompanha a direção correta, se a animação para em repouso e se o modelo permanece junto à colisão depois de vários ciclos. Observe de lado o pé que toca o chão. Se ele escorregar de forma evidente, ajuste a velocidade de reprodução e registre o valor usado.

Rode também os testes existentes de movimento, direção e travessia. Salve em MD-usario/relatorios/evidencias/ uma sequência curta de quadros da corrida real no Godot que mostre as pernas alternando o apoio. Registre o que foi observado em tela e o que foi medido por teste.

5. Documente para eu conseguir testar

Atualize docs/ROADMAP.md e salve o relatório em MD-usario/relatorios/04c-corrida-no-godot.md. Informe os arquivos criados, o nome do clipe no Godot e o trecho do script que inicia e interrompe a animação. Termine com o caminho da cena que devo abrir e as teclas para repetir o percurso.
