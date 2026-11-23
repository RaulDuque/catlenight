# 16 — Prólogo jogável

Abra `scenes/prologo/prologo.tscn` e pressione F6. Espaço inicia a partida. Segure ← para subir a escada exterior, entre no salão e siga até o trono. ↑ no acesso permite explorar os dois lances internos e a galeria antes de enfrentar o guardião. O comando do Cursor `/start-game` abre esse mesmo percurso.

## Da planta ao jogo

A cena herda a geometria da 15-E. O cenário usa quatro regiões da prancha “Final Stage: Bloodlines” existente no projeto, a 26 px/m, e pequenos recortes da própria pedra na soleira e no patamar. A câmera lateral acompanha o jogador dentro dos limites dos painéis. O protagonista usa a corrida 3D do Catlenight. Um ajuste visual em função da inclinação aproxima a bota da superfície; o apoio de cada pé durante a passada ainda é aproximado. Arte do jogo Castlevania: Symphony of the Night, mapa organizado por Revned. [Fonte](https://revned77.github.io/games/SymphonyOfTheNight.html).

## Guardião do Trono

O guardião tem cinco pontos e anuncia a investida com um sinal de exclamação e um som. O aviso dura menos quando restam dois pontos. Espaço permite saltar sobre ele e X golpeia de perto. A derrota repõe a vida do jogador e a do guardião e devolve o protagonista ao salão. A vitória abre a escolha entre repetir o prólogo e entrar no vestíbulo. A música e os sons são sintetizados para este piloto.

## Verificação

Godot 4.7.2. O percurso `tests/verificar_prologo_16.gd` passou em modo headless e em janela OpenGL. Entrou por Novo jogo, subiu a escadaria, visitou a galeria, voltou, provocou uma derrota e venceu em duas partidas. Verificou as duas opções de saída e a chegada ao vestíbulo. As capturas vieram da janela do teste. O F6 manual ficou para conferência no editor. Os testes de movimento, golpe 06, vida 08, escala 15-E e altar 11 (primeira partida e continuação) também passaram com dados de teste isolados.

[Quatro quadros da execução](evidencias/16-prologo-jogavel.webp). Da esquerda para a direita, a linha superior mostra a escadaria e a galeria. A inferior mostra o trono e o encerramento.
