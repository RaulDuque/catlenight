# Regras de trabalho

Catlenight é um projeto pessoal de estudo. Quem conduz o projeto precisa entender cada parte o bastante para alterá-la sozinho. Explique o que for novo em linguagem direta: caminho da cena no editor e a propriedade que dá para mudar para testar a ideia.

O nome Catlenight é provisório. Pode ser trocado em Project Settings, em Application > Config > Name.

## Ferramentas

- Godot 4 estável, linha 4.7, de preferência 4.7.2. Build padrão, com GDScript.
- Recursos nativos do Godot têm prioridade.
- Pacote, extensão ou skill só entra se for gratuito e se a função dele estiver escrita em `docs/DECISIONS.md`.
- A skill em `.claude/skills/` é referência de trabalho. O jogo não a carrega.

## Eixos

O mundo é 3D. A câmera é lateral e ortográfica.

| Eixo | Uso no jogo |
| --- | --- |
| X | Deslocamento horizontal |
| Y | Altura |
| Z | Profundidade |

A câmera fica no lado positivo de Z e olha para -Z, de modo que a imagem mostra o plano XY. O plano de jogo desta cena de verificação é **Z = 0**. Quando existir controlador, o personagem permanece no Z definido para a fase. Nesta cena, esse Z é 0.

Unidades do Godot são metros. O tamanho ortográfico da câmera também está em metros.

## Limite atual

A etapa 01 entregou a cena de verificação. A etapa 02 entregou o primeiro controlador: o jogador cai, anda em X, pula e permanece em Z = 0. A etapa 03 entregou o primeiro arco de pedra, modelado no Blender, importado em GLB e atravessável por esse jogador. A etapa 04 trocou o bloco vermelho pelo manequim de 1,70 m. O nó `Visual` aponta o perfil para +X ou para −X conforme a seta, e conserva a última direção quando a seta é solta.

O manequim da cena principal continua sem esqueleto. O piloto da etapa 04-C usa o esqueleto e a corrida do Mixamo. A etapa 04-D deixou esse piloto mais legível: luz mais baixa, ambiente suave e o pilar dianteiro transparente só enquanto cobre o corpo. A etapa 05 ligou duas salas na cena de verificação: o vestíbulo, reconhecido pelo arco, e a galeria, com plataforma elevada e duas colunas ao fundo. Um único jogador atravessa as duas e, se cair na galeria, reaparece na galeria. A etapa 06 colocou um boneco de treino na galeria e o primeiro golpe na tecla X. A lâmina provisória usa a última direção olhada. Um acerto deixa o boneco amarelo por um instante. A etapa 07 colocou a sentinela de pedra na galeria: ela patrulha em X, pode ser pulada e cai com três golpes. A etapa 08 ligou a vida nesse encontro: a sentinela viva tira um ponto ao encostar, o canto da tela mostra “Vida 3/3” e, em zero, o jogador volta ao retorno da sala. A etapa 09 colocou uma sacada no vestíbulo e uma relíquia na galeria: o salto simples não alcança a sacada; depois da relíquia, Espaço no ar dá o segundo impulso. A etapa 10 transformou o vão iluminado dessa sacada numa passagem: com os pés apoiados diante dela, a seta para cima entra na Capela da Lua e o mesmo toque devolve o jogador à sacada. A etapa 11 colocou um altar ao lado do vitral: um toque grava a vida, o salto duplo e a sentinela num arquivo, e outra execução pode continuar dali. A etapa 12 desenha o caminho já percorrido: M abre o mapa, a galeria aparece ao chegar nela e a capela só aparece depois da primeira entrada. A etapa 13 vestiu o vestíbulo com módulos de cantaria feitos no Blender: parede, pilastra e faixa do piso, sem trocar a colisão que sustenta os pés. A animação definitiva da espada, a roupa e o equipamento ficam para as próximas tarefas.

A etapa 04-A instalou o Hunyuan3D-2mini fora da pasta do jogo e gerou a geometria do exemplo oficial. A interface local abre por `D:\Tools\Hunyuan3D\abrir_hunyuan.bat`, em `http://127.0.0.1:8080`, e gera quantos moldes forem precisos. Ela produz geometria; a textura continua desligada nesta placa de 8 GB.

A etapa 04-B preparou `arte-fonte/mixamo/protagonista_mixamo_upload.obj` a partir de `molde3d\white_mesh (1).glb`. O OBJ foi reimportado e medido no Blender: 1,70 m, 52000 triângulos, mãos e pernas separadas. O FBX baixado desse envio foi conferido na etapa 04-C. O manequim segue sendo o personagem da cena principal.

A etapa 04-B2 comparou `molde3d\darkcastle.obj` com a captura do casaco. Esse molde também tem uma cópia em `arte-fonte/mixamo/darkcastle_mixamo_upload.obj`. O primeiro envio ao Mixamo continua sendo o OBJ da etapa 04-B, por causa da separação dos braços e das pernas.

Ainda ficam para depois:

- o restante da interface, além do indicador de vida, do aviso da relíquia, do aviso da passagem, do menu do altar e do mapa das salas;
- outras habilidades, além do salto duplo;
- animação e áudio.

Não avance para a tarefa seguinte sem apresentar o resultado da tarefa atual.

## Organização

- Salve cada prompt em `MD-usario/prompts/` antes de implementar a tarefa correspondente.
- Prompts complementares aprovados vão para a mesma pasta.
- O relatório da etapa vai em `MD-usario/relatorios/`.
- Ao concluir uma tarefa, atualize `docs/ROADMAP.md` com o status real e com os critérios que foram de fato verificados.
- Tarefas concluídas do Catlenight podem ir para o Git e para o origin sem pedir confirmação a cada entrega. O remoto continua `RaulDuque/catlenight`. Não crie outro remoto e não use force push.
- Preserve o que já existe na pasta. Não apague conteúdo para "limpar" o projeto.

## Git

O `.gitignore` e o `.gitattributes` já estão preparados no formato que o Godot 4.7 gera. O repositório local só deve ser criado quando o Git estiver instalado e a inicialização for pedida ou estiver autorizada pela tarefa.

Quem conduz o projeto autoriza o Claude Code a fazer commit e push das tarefas concluídas do Catlenight, sem pedir confirmação a cada entrega. O push é o envio normal da branch de trabalho para `origin`. Se o remoto recusar, o commit local fica e a mensagem do Git é informada.
