duas coisa primeirta tem como habiri o hunyan 3d local para eu poder gera quanto moldes eu quiser ?  segundo 
Continue o Catlenight em D:\Progr\catlenight. Execute a Tarefa 04-B — preparar no Blender um dos personagens da pasta molde3d para o auto-rig do Mixamo.

O personagem já foi gerado manualmente com Hunyuan3D-2. Use os modelos existentes. Trabalhe em cópias, preserve as peças modulares originais e mantenha a cena jogável da Tarefa 04 como está.

1. ESCOLHA O MODELO

Salve este prompt integralmente em MD-usario/prompts/04b-preparar-molde3d-para-mixamo.md. Localize a pasta molde3d e seus subdiretórios. Identifique os modelos por nome, formato e tamanho. Agrupe as variantes do mesmo personagem.

Inspecione os candidatos no Blender. Escolha o humanoide que tiver o corpo completo e a melhor separação entre braços, tronco e pernas. Registre o arquivo escolhido, a pose, as peças presentes, a existência de armature ou animação e a contagem inicial de triângulos da geometria avaliada.

2. PREPARE O CORPO SEM PERDER A MODULARIDADE

Crie arte-fonte/blender/protagonista_mixamo_preparado.blend. Nesse arquivo, mantenha uma versão editável com as peças, UVs e materiais existentes e uma coleção separada para a cópia de exportação.

Selecione explicitamente as peças de um único personagem. Reconheça a espada e outros acessórios pela geometria e pela hierarquia, além do nome. Deixe fora da cópia de upload a espada, a bainha, a base de exposição e os objetos de cenário. Examine a capa: se cobrir as pernas ou ligar visualmente os braços ao tronco, retire-a da cópia quando for uma peça separada. Se arma ou capa estiverem fundidas ao corpo, confira a geometria antes de cortar. Preserve mãos, dedos e roupa. Se houver outra variante mais limpa, prefira essa variante.

Prepare uma pose frontal e ereta, aproximadamente simétrica, com braços afastados do tronco, mãos visíveis e espaço entre as pernas. Confira de frente e de perfil se a geometria da mão está realmente separada da coxa e se há abertura nas axilas. Ajuste a altura para 1,70 m, com as solas no piso.

3. CRIE UMA CÓPIA ESTÁTICA E LEVE

Na cópia de exportação, avalie os modificadores de cada peça individualmente antes de unir os objetos. Se houver armature, obtenha a geometria estática na pose preparada. Preserve as transformações de cada peça para evitar que ombreiras, mãos ou botas mudem de lugar.

Una apenas essas cópias para produzir o objeto de upload. A união deve agrupar as peças; evite soldar vértices próximos entre superfícies distintas, especialmente dedos, braços e pernas.

Meça os triângulos reais da malha avaliada. Se o modelo estiver pesado, simplifique gradualmente. Use 30 a 60 mil triângulos como alvo de trabalho deste piloto, ajustável de acordo com a silhueta. Se o modelo já estiver leve e bem definido, mantenha a geometria. Confira principalmente queixo, pulsos, cotovelos, joelhos e botas depois da redução. Registre o total final medido.

4. EXPORTE E TESTE O ARQUIVO EXATO DO UPLOAD

Exporte somente a cópia preparada, como OBJ simples de geometria, para:
D:\Progr\catlenight\arte-fonte\mixamo\protagonista_mixamo_upload.obj

Reimporte esse mesmo OBJ em uma cena vazia do Blender. Confira se contém um único personagem completo, em pé, com 1,70 m, mãos e pernas separadas e espada ausente. Verifique também se as peças continuam no lugar. Registre tamanho em MB, triângulos e dimensões após a reimportação.

Salve uma captura frontal do OBJ reimportado em:
MD-usario/relatorios/evidencias/04b-modelo-para-mixamo.png

5. ENTREGUE O PASSO MANUAL

Informe o caminho completo do OBJ que devo selecionar em Upload Character. Usando a captura frontal do meu modelo, explique onde colocar os marcadores de queixo, pulsos, cotovelos, joelhos e virilha. Se a armadura esconder uma articulação, indique onde fica a articulação por baixo da peça.

Explique o que observar na prévia do auto-rig: se os braços levantam sem puxar o tronco, se os joelhos dobram para a frente e se as botas acompanham os pés. Se a montagem funcionar, oriente a escolher uma corrida com In Place, quando disponível, e baixar o primeiro FBX com With Skin para:
D:\Progr\catlenight\arte-fonte\mixamo\protagonista_hunyuan_corrida.fbx

Salve o relatório em MD-usario/relatorios/04b-preparar-molde3d-para-mixamo.md e atualize o roadmap. Diferencie “OBJ reimportado e validado no Blender” de “auto-rig confirmado no Mixamo”. Se algum defeito da malha impedir a preparação, mostre o defeito em uma captura e identifique o arquivo afetado.
