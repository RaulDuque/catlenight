# 15-C — Sala de blocos do prólogo e cenário híbrido

Data: 20/11/2026. Godot 4.7.2. A cena para o F6 é `scenes/verification/15c_blockout_do_prologo.tscn`. O F6 do editor não foi pressionado. A janela abriu por script, em `tests/capturar_15c.tscn`. O percurso rodou em `tests/verificar_blockout_15c.gd`, com `APPDATA` em `tests/dados_15c`. O F5 continua em `scenes/verification/main.tscn`.

A cena 15-B permanece em `scenes/verification/15_escadaria_exterior.tscn`. Lá, `EscadariaExterior/Saida` ainda leva ao vestíbulo. No piloto 15-C essa saída e `Vestibulo/SaidaEsquerda` ficam com `monitoring` desligado depois que a cena abre, para a seta esquerda continuar no salão. A rota antiga foi conferida de novo: `verificar_escadaria_15.gd` nas fases `percurso` e `continuar` deu `RESULTADO ok`, com vestíbulo, galeria, capela e as três ligações.

## Como a faixa está montada

O jogador e a câmera vêm da cena 15. O nascimento continua no patamar inferior direito. A escadaria reaproveitada sobe 2,640 m em 5,520 m. A câmera fica em X = −26,20 enquanto o corpo está na escada, com `Size` = 8, perto 0,05 e longe 40. Depois que o corpo passa de X = −30, `EnquadramentoDoPrologo` acompanha X. No script `scenes/verification/enquadramento_do_prologo.gd`, a câmera fica em X do jogador + 2,00 m, sem passar de −26,20 para a direita nem de −56,00 para a esquerda. Não há paralaxe.

O salão e a sala do trono saem de `dados/sala_do_prologo.json`. Cada célula tem 1,00 m de largura e 0,44 m de altura. A origem é o canto inferior esquerdo da fileira de baixo, coluna 1, no espaço de `EscadariaExterior`, que está em X = −22 no mundo. A primeira string é a fileira mais alta. Coluna 1 é a da esquerda, e X cresce para a direita. `/` deixa o lado esquerdo mais alto. `\` deixa o lado direito mais alto.

A fileira de baixo é o salão: 14 m de piso, do limiar até a rampa, com o topo em Y = 2,640, o mesmo do patamar superior. A rampa sobe 0,440 m em 1,00 m, cerca de 24°. A fileira de cima, nos 8 m à esquerda dessa rampa, é o piso da sala do trono, com o topo em Y = 3,080. O assento e o encosto ficam no lado esquerdo desse piso, em `SalaDoPrologo/ArteManual`, e não entram na geração. O marcador `Estrado` fica à direita deles, para o corpo parar de frente para o trono.

O gerador é `scenes/environment/gerador_de_sala.gd`, no nó `EscadariaExterior/SalaDoPrologo`. Ele roda ao abrir a cena no editor e de novo ao executar o piloto. Cada chamada apaga só os filhos de `Gerado` e os refaz. `ArteManual` fica no lugar.

## Uma célula, do caractere aos pés

Abra `dados/sala_do_prologo.json`. Na segunda string, a nona letra é `/`.

- Linha 2, coluna 9.
- O gerador calcula o vão de X = −26,120 a X = −25,120, no espaço da escadaria. A base dessa fileira termina em Y = 2,640. O lado esquerdo sobe até Y = 3,080.
- O centro da face inclinada, onde a sola se apoia no meio da célula, fica em X = −25,620, Y = 2,860 e Z = 0. No mundo, esse X é −47,620.
- O corpo é `EscadariaExterior/SalaDoPrologo/Gerado/Rampa_0_8`. `Colisao` é um `BoxShape3D` de 1,259 × 0,320 × 2,400 m. O eixo longo segue a rampa e o lado esquerdo é o mais alto. A ponta baixa entra 0,18 m no piso do salão, para a emenda não abrir um vão.
- A chegada medida no piso da sala do trono, que é o alto dessa rampa, deixou os pés em X = −53,264, Y = 3,080 e Z = 0. Y = 3,080 é o topo da faixa `#` da fileira de cima. O marcador `Estrado` está à direita do assento, então o corpo para de frente para ele.

## A torre

A imagem é `assets/textures/environment/prologo/torre_do_prologo.png`. O fundo é transparente. O nó é `EscadariaExterior/TorreRecorte`, um `MeshInstance3D` com `QuadMesh` de 1,90 × 6,60 m. A posição local é X = −9,55, Y = 3,35, Z = −4. A câmera está em Z = 14, então a torre fica a 18 m dela, dentro do intervalo 0,05 a 40.

O material é um `StandardMaterial3D` sem iluminação, com transparência por recorte e limiar 0,5. O céu é `EscadariaExterior/CeuPintado`, em Z = −8, com `assets/textures/environment/prologo/ceu_do_prologo.png` opaca e sem iluminação. Quando a câmera entra no salão, esse céu se oculta. A parede que recebe a luz do portão é `EscadariaExterior/MuroIluminado`, em Z = −1,55, com `pedra_iluminada.png`, rugosidade 0,92 e iluminação ligada. A luz é `EscadariaExterior/LuzDoPortao`, energia 6, alcance 7,5, sem sombra. Não usei normal map: o relevo não mudava a leitura dos degraus.

## O que a prova mediu

“Novo jogo” no piloto 15-C. A seta esquerda sobe. Os pés nascem em X = −20,800 e Y = 0,000, os mesmos da 15-B. A parada no meio ficou em X = −24,225 e Y = 1,256, também a mesma. O alto da escada ficou em X = −27,470 e Y = 2,640. Z permaneceu 0.

Do nascimento ao limiar, 3,683 s. Os pés cruzaram o limiar em X = −29,570 e Y = 2,640, sem troca de sala. Do limiar ao piso da sala do trono, 6,833 s. A chegada ficou em X = −53,264 e Y = 3,080. A seta direita devolveu o corpo ao patamar, em Y = 0. O mesmo percurso, com a arte ligada, chegou de novo a esse piso e voltou.

No meio da rampa, B passou a “Com arte” e voltou a “Blocos”. Os pés ficaram em X = −24,225 e Y = 1,256. A câmera ficou em X = −26,20. `Lance/Rampa/Colisao` continuou ativa.

A prancha dos dois modos, no mesmo enquadramento, está em `MD-usario/relatorios/evidencias/15c-blocos-e-arte.png`. A chegada ao estrado está em `MD-usario/relatorios/evidencias/15c-chegada-ao-trono.png`. As duas são capturas do Catlenight.

Um `?` na linha 2, coluna 9, fez o gerador apontar `sala_do_prologo.json: linha 2, coluna 9`. Trocar um `.` da fileira de cima por `#` levou os corpos de 4 para 5. Gerar de novo manteve 5. Restaurar o arquivo voltou a 4. O JSON original foi gravado de volta ao fim do teste.

## Exercício de cinco minutos

1. Abra `dados/sala_do_prologo.json`. Na primeira string, a letra 16 é `.`. É a linha 1, coluna 16, já dentro do salão.
2. Troque esse `.` por `#`. Salve.
3. No Godot, abra `scenes/verification/15c_blockout_do_prologo.tscn` ou rode com F6. O gerador refaz `Gerado` ao abrir e ao executar. Escolha “Novo jogo”.
4. Segure a seta esquerda até passar do limiar e entrar no salão. O degrau novo é o bloco de 0,44 m com o topo em Y = 3,080. Pule com Espaço e olhe se a sola para nesse topo. No editor, o corpo é `SalaDoPrologo/Gerado/Piso_1_15` e a forma é `Colisao`.
5. Volte essa letra para `.` e salve. Rode de novo: o degrau some e a contagem de corpos volta à anterior.
