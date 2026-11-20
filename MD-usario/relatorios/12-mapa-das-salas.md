# 12 — Mapa das salas exploradas

Data: 20/11/2026. Godot 4.7.2. A cena de entrada é `scenes/verification/12_mapa_das_salas.tscn`. O F6 do editor não foi pressionado. A janela do Godot abriu essa cena pelo script `tests/capturar_12.tscn`. O percurso rodou em `tests/verificar_mapa_12.gd`, cada etapa num processo novo. O F5 continua em `scenes/verification/main.tscn`. A cena 11 continua sem o mapa, para o exercício de salvamento.

## O percurso

`12_mapa_das_salas.tscn` instancia `11_altar_de_salvamento.tscn` e acrescenta o nó `MapaDasSalas`. A tecla M está na ação `abrir_mapa`. Um toque abre o desenho. Outro toque fecha. A própria tela diz “M Fecha o mapa”.

O vestíbulo fica no centro. A galeria fica à direita. A capela fica acima, do lado da sacada. Essa disposição segue as portas que o jogador atravessa. O X = 48 da câmera da capela só enquadra a sala 3D. Ele não escolhe o lugar da capela no desenho.

No nascimento, o desenho tem uma caixa: “Vestíbulo” e “Você está aqui”. Na primeira chegada à galeria, as duas salas aparecem ligadas. Ao voltar ao vestíbulo com a relíquia, o marcador volta para o vestíbulo e a capela continua fora do desenho. A primeira entrada na capela acrescenta “Capela da Lua”, a ligação com o vestíbulo e o marcador nessa sala.

## Onde cada função entra

A troca de sala termina em `salas_conectadas._aplicar`, que chama `_enquadrar`. `_enquadrar` guarda a sala em `sala_atual` e copia o `Enquadramento` para `CameraLateral`. O mapa lê essa mesma sala. Não lê o X da câmera.

`mapa_das_salas._observar_sala` só corre com a partida em andamento. Ela traduz o nome do nó:

| Nó | Identificador |
| --- | --- |
| `Vestibulo` | `vestibulo` |
| `Galeria` | `galeria` |
| `CapelaDaLua` | `capela_da_lua` |

Se o identificador mudou, a sala atual do desenho muda. Se ele ainda não está em `visitadas`, entra no fim da lista. Uma revisita só muda “Você está aqui”. `_atualizar` mostra o nome da sala visitada e esconde as outras. `_draw` pinta a caixa e, quando as duas pontas já foram visitadas, a linha `vestibulo-galeria` ou `vestibulo-capela_da_lua`.

Ver a janela da sacada, pegar a gema ou chegar perto da porta não chama `_enquadrar` para a capela. Por isso a passagem continua secreta até a troca terminar.

`MenuDoPiloto._confirmar`, na escolha “Novo jogo”, chama `mapa_das_salas.iniciar_jogo_novo` antes de soltar a pausa. Essa função marca só `vestibulo` e não mexe no arquivo.

## A pausa

`MapaDasSalas` e o filho `Folha` usam o modo de processo “sempre”. `_abrir` faz `get_tree().paused = true`. O jogador, a sentinela, as portas e o altar ficam parados. `_physics_process` do mapa continua, porque o modo “sempre” ignora a pausa da árvore. O próximo `Input.is_action_just_pressed("abrir_mapa")` chama `_fechar`, que esconde o desenho e devolve `paused` a falso.

X, Espaço e a seta para cima, apertados enquanto o mapa está aberto, não encontram o jogador nem a porta nesse quadro. `is_action_just_pressed` só vale no quadro em que a tecla desce. Quando a partida volta, a tecla pode continuar presa, mas o toque novo já passou. Não sai golpe, pulo, passagem nem salvamento.

Na galeria, com a sentinela em marcha, o mapa ficou aberto 1103 ms. O jogador permaneceu em X = 27,891. A sentinela permaneceu em X = 29,770. A vida ficou em 3. A fase do golpe ficou vazia e a lâmina, recolhida. Depois de fechar, a patrulha andou 0,080 m. Dez quadros com X, Espaço e ↑ ainda presos deixaram os pés no chão, a lâmina recolhida e a câmera na galeria.

Diante do altar, abrir e fechar o mapa deixou `gravacoes` em 0. O arquivo só nasceu no toque seguinte de salvar.

## O arquivo

O caminho continua `user://catlenight_piloto_11.json`. Os testes trocaram `APPDATA` para `D:\Progr\catlenight\tests\dados_12`. A partida pessoal, em `C:\Users\Raul\AppData\Roaming\Godot\app_userdata\Catlenight`, não foi usada. A pasta de teste está no `.gitignore`.

`ProgressoDoPiloto.reunir` só acrescenta `salas_visitadas` e `sala_atual` quando o grupo `mapa_das_salas` existe. A cena 11 não tem esse grupo, então o arquivo dela continua com as oito chaves da etapa 11. `para_gravacao` entrega a lista e a sala atual do mapa.

`validar` exige as oito chaves de sempre. As duas do mapa são opcionais e precisam vir juntas. A lista só aceita os três identificadores, sem repetir, e precisa incluir `vestibulo` e a sala atual. Uma chave desconhecida continua inválida. A versão permanece 1.

Exemplo gravado ao chegar no altar, sem ter levado dano:

```json
{
	"marcador": "AoLadoDoAltar",
	"sala": "capela_da_lua",
	"sala_atual": "capela_da_lua",
	"salas_visitadas": [
		"vestibulo",
		"galeria",
		"capela_da_lua"
	],
	"salto_duplo": true,
	"sentinela_derrotada": false,
	"sentinela_vida": 3,
	"versao": 1,
	"vida": 3,
	"vida_maxima": 3
}
```

`restaurar` chama `_aplicar`. Além da vida, do salto e da sentinela, `_aplicar` chama `definir_sala_atual` na capela. Essa função usa o mesmo `_enquadrar` da travessia, então a câmera e `sala_atual` ficam no mesmo estado. Se o arquivo traz o mapa, `aplicar_gravacao` restaura a lista. Se não traz, `aplicar_legado` marca as três salas e deixa a capela como atual.

Essa leitura do arquivo antigo está documentada de propósito. No piloto 11, o único altar fica na capela, e chegar até ele exigia atravessar vestíbulo, galeria e capela. Um arquivo válido daquela etapa, sem as chaves novas, portanto já percorreu as três. O teste escreveu esse texto, abriu “Continuar” e conferiu o mapa antes de qualquer gravação nova. A vida restaurada foi 2, a sentinela ficou em 1, as três salas apareceram e os bytes do arquivo continuaram iguais.

“Novo jogo”, com esse tipo de arquivo presente, mostra só o vestíbulo e não substitui o texto até o próximo salvamento no altar.

## Como o piloto foi executado

O Godot de console foi o `4.7.2.stable.official.ed1daf0bf`. Cada processo recebeu `APPDATA=D:\Progr\catlenight\tests\dados_12` e a fase depois de `--`.

| Processo | O que o mapa mostrou |
| --- | --- |
| `primeira` | Vestíbulo sozinho; depois vestíbulo e galeria; na volta com a relíquia, ainda sem capela; na entrada, as três salas e o marcador na capela |
| `continuar` | As três salas, marcador em `capela_da_lua`, vida 3, relíquia e sentinela em 3. O arquivo não mudou |
| `novo_mapa` | Só o vestíbulo. O arquivo anterior permaneceu |
| `legado` | Arquivo da etapa 11, sem chaves de mapa. Três salas, marcador na capela, vida 2 e sentinela em 1. Os bytes não mudaram |

As capturas abriram janela, sem `--headless`, pela cena `tests/capturar_12.tscn`. A primeira, em “Novo jogo”, gravou `MD-usario/relatorios/evidencias/12-mapa-primeira-visita.png`: só “Vestíbulo”, “Você está aqui” e “M Fecha o mapa”. A segunda, em “Continuar”, gravou `12-mapa-na-capela.png`: as três salas, as duas ligações e o marcador na Capela da Lua. As duas têm 1280×720. A captura não reescreveu o arquivo.

Também deram `RESULTADO ok`: `verificar_salas_05.gd`, `verificar_capela_10.gd` e as fases `primeira`, `continuar`, `de_novo`, `derrota`, `novo_jogo` e `arquivo` de `verificar_altar_11.gd`. O teste 11 usou `tests/dados_11`, separado desta partida de mapa.

## Exercício de cinco minutos

Abra `scenes/verification/12_mapa_das_salas.tscn` com F6. Escolha “Novo jogo”.

1. Ainda no vestíbulo, antes de buscar a gema, aperte M. O desenho tem só “Vestíbulo” e “Você está aqui”. Não há linha saindo da caixa.
2. Pegue a gema na galeria e volte ao vestíbulo. Aperte M de novo. Agora existem “Vestíbulo” e “Galeria”, com uma linha entre elas. O marcador voltou ao vestíbulo. “Capela da Lua” continua ausente. O salto duplo já é seu: Espaço no ar dá o segundo impulso. Essa habilidade não é uma sala visitada.
3. Suba na sacada, entre na capela e aperte M. Aí sim aparecem o nome “Capela da Lua”, a linha desde o vestíbulo e “Você está aqui” debaixo dessa caixa.

O que separa as duas ideias: ter a habilidade é o segundo impulso no ar, com a capela ainda fora do mapa. Ter visitado a sala é o nome, a ligação e o marcador depois que a troca de sala terminou.

O desenho mora em `MapaDasSalas/Folha`, no script `scenes/interface/mapa_das_salas.gd`. As caixas estão na constante `_CAIXAS`. A da capela é `Rect2(250, 140, 230, 88)`. Se quiser ver a caixa andar no papel, troque o 250 por 180, rode a cena e volte o 250. O X = 48 da câmera 3D permanece o enquadramento da capela.
