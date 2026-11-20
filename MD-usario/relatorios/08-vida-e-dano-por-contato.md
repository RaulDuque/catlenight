# 08 — Vida do jogador e dano por contato

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/08_vida_do_jogador.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_08.tscn`. O encontro rodou em `tests/verificar_vida_08.gd`. O F5 continua em `scenes/verification/main.tscn`. As cenas 06 e 07 continuam sem dano por contato.

## O piloto

`08_vida_do_jogador.tscn` instancia `07_primeiro_inimigo.tscn`. O vestíbulo, a galeria, a câmera, o `Jogador` e a `SentinelaDaGaleria` são os mesmos. O nó novo é `IndicadorDeVida`, um `CanvasLayer` com o rótulo `Vida`. Como a camada fica na tela, o texto acompanha a câmera quando ela salta do vestíbulo para a galeria.

A regra nova só vale com `vida_ativa` ligado. O padrão do script é desligado. A cena 08 marca `vida_ativa = true` no `Jogador` herdado. As cenas 06, 07 e a principal deixam o valor em falso.

O jogador começa com `pontos_de_vida` = `pontos_maximos` = 3. `duracao_da_protecao_s` aparece no Inspetor, no grupo Vida, e vale 1,0 s.

## Quem detecta o toque e quem decide o dano

O toque é lido por `Jogador._ha_contato_com_sentinela_viva`, no fim de `_physics_process`, depois de `move_and_slide`. A função olha as colisões do deslize e, em seguida, faz `intersect_shape` com a caixa `Colisao` do jogador. `Jogador._e_sentinela_viva` exige o grupo `sentinela` e `derrotada` falso. Uma sentinela derrotada deixa de causar dano no mesmo quadro, antes mesmo de a colisão ser desligada.

Quem decide se aquele toque tira vida é `Jogador._atualizar_vida`. Se `tempo_de_protecao_s` ainda é positivo, a função só desconta o quadro e volta. Quando o tempo chega a zero e os corpos ainda se tocam, ela chama `_aplicar_dano` uma vez e o intervalo recomeça em `duracao_da_protecao_s`. Se já estiverem separados, a vida fica como está.

`_aplicar_dano` tira 1 de `pontos_de_vida`, guarda o intervalo em `intervalo_do_ultimo_dano_s` e chama `_avisar_indicador`. Essa função acha o grupo `indicador_de_vida` e chama `IndicadorDeVida.mostrar`. `mostrar` grava `IndicadorDeVida/Vida.text` como “Vida N/M”.

Durante a proteção, `Jogador._process` alterna `material_overlay` nas malhas de `Visual`. A malha continua desenhada, então o perfil segue legível, inclusive debaixo do arco. O script do pilar não mexe no jogador.

A lâmina continua sendo a `AreaDoGolpe`, solta na raiz da cena. Ela não é a caixa do corpo. Por isso um golpe na ponta alcança a sentinela sem o corpo do jogador encostar nela.

## Derrota, porta e queda

Em zero, `_aplicar_dano` chama `_sofrer_derrota`. Essa função soma `retornos_por_derrota`, chama `encerrar_golpe`, apaga a piscada, põe o mesmo jogador em `_ponto_de_retorno` com Z = 0 e velocidade zero, restaura `pontos_maximos` e chama `IndicadorDeVida.mostrar_derrota`. O rótulo fica “Derrota” por 0,6 s e depois volta a “Vida 3/3”. O marcador é o que `salas_conectadas.gd` gravou com `definir_ponto_de_retorno`. Na galeria, a câmera permanece no enquadramento da galeria.

Atravessar a porta não recria o jogador nem a sentinela. `pontos_de_vida` e o texto seguem os valores atuais. Uma sentinela já derrotada continua derrotada.

A queda usa o caminho que o projeto já tinha: `_retornar_se_cair_da_sala`. Se Y passa de `altura_minima_da_sala_m` (−2), ela chama `encerrar_golpe`, teleporta para `_ponto_de_retorno` e zera a velocidade. Ela não mexe em `pontos_de_vida` e não conta como derrota. Neste piloto, cair e perder a vida são retornos diferentes: a queda conserva os pontos; a derrota restaura os três.

## O que o teste mediu

`tests/verificar_vida_08.gd`: `RESULTADO ok`. O teste usa as ações do Mapa de Entrada e provoca o encontro dos corpos. Ele não chama `_aplicar_dano`.

- Início: vida 3/3, proteção 1,00 s, `vida_ativa` verdadeiro
- Salto sobre a sentinela em movimento: jogador em X = 29,900 e Y = 0, sentinela em 28,750. Vida do jogador 3, vida da sentinela 3
- Ponta da lâmina: vida do jogador 3, sentinela 3 → 2, lâmina visível
- Encostar parado: t = 5,033 s, vida 2, texto “Vida 2/3”, seta direita solta
- Oito quadros depois, ainda na proteção: t = 5,167 s, vida 2, proteção 0,867 s, texto “Vida 2/3”
- Afastar antes do fim do intervalo: vida 2 com a proteção já em 0
- Sair e voltar à galeria: vida 2, texto “Vida 2/3”, sentinela ainda em 2
- Andar contra a pedra: t = 14,567 s, vida 1, seta direita pressionada
- Manter o contato: intervalo medido 1,000 s, e `intervalo_do_ultimo_dano_s` também 1,000 s
- Derrota: um retorno, X = 21,038, Y = 0, câmera em X = 24, vida 3, lâmina inativa
- Sentinela derrubada e trecho atravessado: jogador em X = 30,257 com vida 3

A captura `08-dano-na-galeria.png` saiu da câmera da galeria, `Size` = 8, 1280×720, `camera_x` = 24. O texto na imagem é “Vida 2/3”. O jogador está em pé em X = 28,789 e Y = 0, de perfil para a direita. A sentinela está em X = 29,780, com o olho visível. A janela abriu por `tests/capturar_08.tscn`, não pelo F6.

Os testes anteriores, depois da mudança em `jogador.gd`:

- `tests/verificar_golpe_06.gd`: `RESULTADO ok`
- `tests/verificar_inimigo_07.gd`: `RESULTADO ok`. Na cena 07, `vida_ativa` continua falso, então o contato não tira vida

`salas_conectadas.gd` e `_retornar_se_cair_da_sala` não foram editados. O teste das salas não foi repetido.

## Comandos

```
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_vida_08.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_golpe_06.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_inimigo_07.gd
Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight res://tests/capturar_08.tscn
```

Os três testes terminaram com `RESULTADO ok` e saída 0. A captura terminou com saída 0 e gravou o PNG.

## Arquivos

- `scenes/player/jogador.gd`
- `scenes/interface/indicador_de_vida.gd` e `scenes/interface/indicador_de_vida.tscn`
- `scenes/verification/08_vida_do_jogador.tscn`
- `tests/verificar_vida_08.gd`, `tests/capturar_08.gd` e `tests/capturar_08.tscn`
- `MD-usario/prompts/08-vida-e-dano-por-contato.md`
- `MD-usario/relatorios/08-vida-e-dano-por-contato.md`
- `MD-usario/relatorios/evidencias/08-dano-na-galeria.png`
- `README.md`, `docs/ROADMAP.md` e `CLAUDE.md`

`07_primeiro_inimigo.tscn`, `06_primeiro_golpe.tscn`, `sentinela_da_galeria.gd` e `project.godot` não foram editados. O F5 segue na cena principal.

## Como repetir

Abra `scenes/verification/08_vida_do_jogador.tscn` e aperte F6. Seta direita chega à galeria. O canto mostra “Vida 3/3”. Se a pedra encostar, o texto passa a “Vida 2/3” e o modelo pisca por 1,0 s. Seta e Espaço ainda pulam por cima. X ainda golpeia. Três contatos, sem sair do corpo dela, levam a zero: o mesmo jogador reaparece no `Retorno` da galeria, com “Derrota” por um instante e depois “Vida 3/3”.

## Exercício

1. Abra `scenes/verification/08_vida_do_jogador.tscn`.
2. Selecione o nó `Jogador`.
3. No Inspetor, grupo **Vida**, a propriedade é `duracao_da_protecao_s`. O valor original é **1,0**.
4. Mude para **2,0**. Salve com Ctrl+S.
5. Aperte F6. Vá até a galeria e deixe a sentinela encostar, ou ande contra ela. O primeiro contato tira um ponto. Se continuar encostado, o segundo ponto só sai depois de cerca de 2 s.
6. Feche o jogo. Devolva `duracao_da_protecao_s` para **1,0** e salve.

## Pendências

O F6 no editor continua pendente. A janela desta etapa foi aberta pelo script de captura. A animação da espada, a roupa, o equipamento, o restante da interface, a progressão e o áudio continuam para as próximas tarefas.
