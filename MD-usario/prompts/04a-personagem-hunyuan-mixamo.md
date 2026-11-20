Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 04-A — primeiro personagem gerado com Hunyuan3D e preparado para animação no Mixamo.

A Tarefa 04 está concluída. O manequim de 1,70 m já funciona em scenes/player/jogador.tscn, como Modelo dentro de Visual. Ele será nossa referência de escala e direção. Faça o piloto em arquivos próprios e em uma cena de teste. Preserve o manequim, a cena principal e o controlador que já passaram nos testes.

1. REGISTRE O PROMPT

Salve este texto integralmente em MD-usario/prompts/04a-personagem-hunyuan-mixamo.md. Leia CLAUDE.md e MD-usario/relatorios/04-protagonista-base.md para aproveitar as convenções do projeto.

2. PREPARE O HUNYUAN3D LOCAL

Use o repositório oficial https://github.com/Tencent-Hunyuan/Hunyuan3D-2. Confira no Windows a VRAM da RTX 3060 Ti, o driver NVIDIA e o espaço livre. Prepare a ferramenta fora da pasta do jogo, em um ambiente Python isolado. Comece com Hunyuan3D-2mini e geração somente de geometria. Use processamento local e ferramentas gratuitas. Registre a revisão, os pesos, as versões e os comandos que funcionarem.

3. GERE A PRIMEIRA MALHA

Procure uma imagem de conceito original ou autorizada para o Catlenight. Prefira uma figura de corpo inteiro, com braços afastados do tronco, pernas separadas e pés visíveis. Registre o arquivo escolhido.

Se não encontrar a imagem do protagonista, valide a instalação com um exemplo oficial do Hunyuan. Nesse caso, identifique o resultado como teste da ferramenta e indique o caminho exato onde devo colocar a imagem do personagem para retomar.

Com a referência do protagonista disponível, gere a malha, guarde o resultado bruto e registre o tempo de geração. Abra a malha no Blender e examine principalmente axilas, mãos, virilha e botas. Se houver partes unidas que impeçam a animação, faça uma correção ou uma nova tentativa e explique o que resolveu.

4. PREPARE O ARQUIVO PARA O MIXAMO

Ajuste o personagem para 1,70 m, com as solas no piso. Para o envio ao Mixamo, deixe o humanoide ereto, voltado de frente e com os membros separados. Na integração posterior com o Godot, a frente visual deverá apontar para +X, como no manequim aprovado.

Salve o editável em arte-fonte/blender/protagonista_hunyuan_piloto.blend. Exporte o personagem inteiro para arte-fonte/mixamo/protagonista_hunyuan_upload.fbx. Reabra o FBX no Blender para conferir que o corpo chegou inteiro, com orientação e escala corretas.

5. ME ENTREGUE O PASSO MANUAL DO MIXAMO

Quando o FBX estiver pronto, me dê as instruções em português para executar a parte que usa minha conta Adobe:
- O caminho completo do FBX que devo enviar.
- Onde posicionar os marcadores no corpo.
- Como conferir a dobra dos joelhos e cotovelos na prévia.
- Qual animação de corrida selecionar e onde ativar In Place, se disponível.
- Como baixar o primeiro FBX animado com a malha incluída (With Skin).
- O caminho completo e o nome que devo usar para salvar o download.

Se o retorno do Mixamo ainda depender de mim, encerre essa rodada com o FBX pronto e o relatório atualizado. Deixe a integração no Godot marcada como pendente.

6. RETOME QUANDO O FBX ANIMADO ESTIVER DISPONÍVEL

Importe o retorno no Blender, confira ombros, joelhos e apoio das botas e exporte um GLB próprio do piloto. Monte uma cena de teste que reutilize o jogador existente e troque apenas o visual nessa instância. Ligue a corrida ao movimento horizontal no chão. Ao soltar a seta, o ciclo deve parar. O deslocamento continua vindo do controlador.

Teste as duas direções, a parada, o pulo e a travessia do arco. Confira se o personagem permanece em Z = 0 e se a animação introduz deslocamento extra ou faz os pés escorregarem. Compare a silhueta com o manequim no enquadramento normal da câmera.

7. DOCUMENTE O RESULTADO

Mantenha MD-usario/relatorios/04a-personagem-hunyuan-mixamo.md atualizado com a origem da imagem, os arquivos gerados, as medições, os testes executados e o próximo passo. Quando a cena animada realmente rodar, inclua uma captura em tamanho normal e registre se esse fluxo produziu um personagem adequado para continuar o projeto.
