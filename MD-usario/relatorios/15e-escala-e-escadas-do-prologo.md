# 15-E — Escala e escadas do prólogo

**Cena para F6** `scenes/verification/15e_prologo_em_escala.tscn`. Executada com Godot 4.7.2 no Linux, pela mesma cena que o editor abre com F6. As capturas foram feitas em uma janela OpenGL com colisões visíveis. A tecla F6 do editor não foi pressionada. O menu, o personagem de 1,70 m, o controlador e o gerador são os da 15-D.

[Planta cotada](evidencias/15e-planta-em-escala.png) · [Detalhe das colisões e da sola](evidencias/15e-apoio-e-colisao.png) · [Tabela 15-D / referência / 15-E](../../docs/PLANTA_DO_PROLOGO.md#15-e--medição-pelo-protagonista-e-pelos-pisos).

A arte permanece em espera da aprovação das proporções. A escala usa a gravação do jogo original aos 12 s e a prancha de Revned, *Final Stage: Bloodlines*. A captura de circulação do protótipo não foi usada na calibração. A planta foi desenhada a partir dos quatro cantos XY de cada BoxShape3D, transformados para o mundo pelo próprio Godot. A comparação local, em ampliação 2× por vizinho mais próximo, mostra os contornos em ciano, os marcos de referência em amarelo e os dois pontos antigos em rosa no exterior.

## Percurso e tempo de simulação

Novo jogo nasce em (1,231; 0). A origem X da cena difere da 15-D. Subir leva ao patamar fora do castelo, em Y = 9,846. A soleira desce para o chão do salão. Segurar ← e saltar contra a parede do trono terminou em (−45,138; 9,231). Acesso em ↑ no salão, início da escada interna em (−19,692; 15,385), descanso em (−27,081; 19,077) e topo em (−32,511; 22,154). Só há teleporte entre o salão e a base da escada. O teste atravessou o vão nos dois sentidos, voltou ao salão em (−17,846; 8,000) e terminou no patamar inicial em (1,246; 0,000). Z ficou dentro da tolerância de 0,001 m em todos os quadros.

| Trecho cronometrado da entrada à saída da projeção X do lance | Subida | Descida |
| --- | ---: | ---: |
| Exterior | 5,850 s | 3,133 s |
| Interno inferior | 2,333 s | 1,400 s |
| Interno superior | 2,000 s | 1,217 s |

Os tempos incluem a parada no meio. A velocidade X solicitada é 3,5 m/s, o impulso do salto é 5,5 m/s. Os raios verificaram o teto do trono, o teto da galeria, a abertura no seu piso e a altura livre na escada interna a cada 2 px.

## Apoio e bloqueio investigado

Com a borda direita do vão no u = 800 original, o teste detectou 20 quadros seguidos sem progresso na subida do lance superior, reportados no quadro 3050 em (−29,059; 20,229). A normal do piso era (0,707; 0,707; 0). A caixa de 0,80 × 1,70 m tocava a rampa e entrava sob a borda do piso superior. Mover somente o início desse piso para u = 810 (0,385 m à direita) liberou a passagem com os três lances a 45°. As duas extremidades de cada lance foram verificadas contra as coordenadas da prancha.

No meio do lance, o teste deixou as teclas soltas por 18 quadros, verificou apoio e deslocamento inferior a 5 mm e consultou o contato com um movimento-teste de 2 cm para baixo. Nas duas malhas dos pés buscou a faixa inferior de vértices (1 mm) e, dentre eles, a sola mais próxima do piso. O raio vertical atravessa o mesmo X **e Z** desse vértice.

| Parada subindo | Origem X/Y | Contato X/Y | Sola X/Y | Piso no X da sola | Folga |
| --- | --- | --- | --- | ---: | ---: |
| Exterior | −6,158 / 5,329 | −6,558 / 5,327 | −6,228 / 5,329 | 4,997 | 0,331 m |
| Inferior | −24,019 / 17,651 | −24,419 / 17,650 | −24,089 / 17,651 | 17,319 | 0,331 m |
| Superior | −29,856 / 21,027 | −30,257 / 21,026 | −29,926 / 21,027 | 20,696 | 0,331 m |

O canto da caixa sustenta o corpo a 0,40 m do centro em X. Ao inverter a direção, o manequim gira e a folga medida da bota cai para 0,190 m nos três lances. Essa folga é visível na captura e continua pendente para o trabalho de pose. A física conserva o apoio nos dois sentidos.

## Repetição

Na raiz, após a importação dos recursos, execute `godot --headless --fixed-fps 60 -s res://tests/verificar_escala_15e.gd`. Resultado registrado: saída 0, RESULTADO ok. A regressão 15-D também terminou com saída 0. Em cópia de teste, encurtar em 0,50 m o extremo X do lance superior produziu saída 1; com os dados restaurados, saída 0.

Para reconstruir a sobreposição local no Windows, use PowerShell na raiz, com o Godot no PATH e Pillow disponível para Python:

```powershell
$env:CATLENIGHT_CONTORNOS = Join-Path $env:TEMP 'contornos-15e.json'
godot --headless --fixed-fps 60 -s res://tests/verificar_escala_15e.gd
python tests/desenhar_planta_15e.py $env:CATLENIGHT_CONTORNOS
```

A saída de consulta é `assets-exemple-2d/estudo-local/15e-sobreposicao.png`. O script também refaz a planta própria em `MD-usario/relatorios/evidencias/`. Para repetir os quadros das botas, indique uma pasta existente em `CATLENIGHT_CAPTURAS` e execute o teste em janela com `--debug-collisions`.

## Exercício

Abra a planta e localize o lance interno inferior entre o piso de chegada e o descanso. Abra a cena, expanda **Medidas** e selecione **BaseDoLanceInferior** e depois **FimDoLanceInferior**. No Inspetor, leia **Transform > Position** dos dois marcadores. A diferença em X é −3,692 m e a diferença em Y é +3,692 m. Os dois comprimentos iguais formam o ângulo de 45° mostrado na planta.
