Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 04-D no piloto scenes/verification/04c_corrida_mixamo.tscn.

Objetivo: ao correr nos dois sentidos, quero conseguir acompanhar a cabeça, o tronco e a passada do protagonista, inclusive quando ele atravessa o arco. Quero aprender a distinguir um problema de iluminação de um objeto que cobre o jogador.

1. Salve este prompt em MD-usario/prompts/04d-visibilidade-da-corrida.md. Leia o relatório 04-C, a cena do piloto e tests/capturar_corrida.gd. Use o piloto existente pelo F6. Preserve o comportamento da cena principal pelo F5.

2. Antes de editar, capture duas posições reproduzíveis com a câmera lateral em Size = 8 e resolução 1280×720: uma na passagem onde o pilar mais encobre o corpo e outra em chão livre, entre o arco e a plataforma. Anote posição do jogador, direção e instante do clipe para repetir as mesmas imagens depois. Salve as evidências desta tarefa com o prefixo 04d-.

3. Comece pelo trecho livre. Teste uma luz de preenchimento suave ou iluminação ambiente só no piloto. Procure o menor ajuste que permita distinguir o tronco, o braço próximo e a perna de trás, mantendo volume no rosto e no cabelo. Se o corpo continuar com regiões quase pretas sob luz de preenchimento, inspecione o material e as normais do GLB antes de aumentar mais a intensidade. Compare o resultado no tamanho normal do jogo.

4. Depois trate a passagem sob o arco. Observe o ponto de maior ocultação andando para a direita e para a esquerda. Experimente primeiro um ajuste pequeno de rotação ou colocação da instância do arco no piloto. Mantenha a malha e a colisão alinhadas e confirme que o vão continua atravessável em Z = 0. Se a geometria continuar escondendo quase todo o jogador, teste transparência temporária apenas nas pedras do pilar dianteiro enquanto ele encobrir o corpo. Adote a solução mais simples que funcionar nas duas direções e preserve o aspecto de pedra fora da passagem.

5. Mantenha nesta tarefa a caminhada em 3,5 m/s, o pulo em 5,5 m/s e a velocidade da animação em 1,3. Use o mesmo modelo e clipe para que o antes e depois mostre o efeito das alterações visuais.

6. Execute o percurso no piloto: corra nos dois sentidos, pare junto ao arco e pule na plataforma. Rode os testes existentes de movimento, direção e travessia. Confira também a travessia na própria cena modificada, pois os testes da cena principal, sozinhos, não validam a nova posição do arco no piloto.

7. Entregue uma prancha em MD-usario/relatorios/evidencias/04d-antes-depois.png com quatro quadros: sob o arco antes e depois, em chão livre antes e depois. Use enquadramento e pose equivalentes em cada par. Salve o relatório em MD-usario/relatorios/04d-visibilidade-da-corrida.md e atualize docs/ROADMAP.md. Explique quais propriedades do Inspector produziram a diferença e como posso repetir a comparação.
