# Catlenight

Metroidvania gótico original em 2.5D, feito para estudo. O nome **Catlenight** é provisório e pode ser trocado.

A cena de verificação tem chão com colisão, um manequim humanoide de 1,70 m, uma plataforma, um arco de pedra, uma luz e uma câmera lateral ortográfica. O manequim cai, anda e pula, e vira o perfil para o lado da caminhada.

O piloto do primeiro golpe é `scenes/verification/06_primeiro_golpe.tscn`. Ele reaproveita o vestíbulo e a galeria. Na galeria há um boneco vermelho. A tecla X dá um golpe curto na última direção olhada. Se a lâmina alcança o boneco, o tronco e a cabeça ficam amarelos por um instante.

O piloto do primeiro inimigo é `scenes/verification/07_primeiro_inimigo.tscn`. Na galeria, uma sentinela de pedra anda entre dois marcos. O olho iluminado mostra o lado da marcha. Dá para pular por cima com a seta e Espaço, ou derrubá-la com três toques de X. A cena 06 continua disponível para o boneco.

O piloto da vida é `scenes/verification/08_vida_do_jogador.tscn`. Ele reaproveita a cena 07. O jogador começa com 3 pontos. Se a sentinela viva encosta nele, o canto da tela passa a “Vida 2/3” e o modelo pisca, sem deixar de mostrar o lado para o qual está virado. A proteção dura 1,0 s. Em zero, o mesmo jogador volta ao marcador `Retorno` da sala, com a vida cheia. Atravessar a porta conserva a vida atual. A cena 07 e o F5 da cena principal não usam essa regra.

O piloto da relíquia é `scenes/verification/09_reliquia_do_salto_duplo.tscn`. No vestíbulo, à esquerda do arco, há uma sacada com uma janela iluminada. O salto simples não alcança o topo. Na galeria, uma gema violeta fica sobre a plataforma, longe da sentinela. Ao tocá-la, o texto “Salto duplo adquirido — aperte Espaço outra vez no ar” aparece embaixo, e o indicador de vida continua no canto. Depois disso, Espaço no ar dá o segundo impulso. A cena 08 continua sem a sacada e sem a relíquia.

O piloto da capela é `scenes/verification/10_capela_da_lua.tscn`. Ele reaproveita a cena 09. A janela pequena some, e no lugar dela abre um vão iluminado do tamanho do protagonista. Com os pés na sacada e diante desse vão, a base da tela mostra “↑ Entrar na capela”. A seta para cima, num toque novo, leva à Capela da Lua. Lá, o mesmo toque com “↑ Voltar ao vestíbulo” devolve os pés à sacada. A cena 09 continua com a janela pequena, para o exercício do salto duplo.

O piloto do altar é `scenes/verification/11_altar_de_salvamento.tscn`. Ele reaproveita a cena 10 e coloca um altar de pedra ao lado do vitral. Ao abrir, o menu oferece “Novo jogo” e “Continuar”. As setas esquerda e direita escolhem; Espaço confirma. “Continuar” só acende quando existe `user://catlenight_piloto_11.json` válido. No altar, a seta para cima grava a vida atual, o salto duplo e a vida da sentinela. A cena 10 continua sem menu e sem altar.

## Versão do Godot

O projeto foi escrito para **Godot 4.7 estável**, de preferência **4.7.2**, com **GDScript**. Use a build padrão, sem .NET. A build .NET serve para C# e este projeto não precisa dela.

Na preparação desta etapa, em 19/11/2026:

- O comando `godot` não existia no terminal, e nenhum `Godot*.exe` foi encontrado na máquina.
- Por isso a versão **não foi confirmada executando o editor**.
- O site oficial, consultado na mesma data, apontava **4.7.2 stable** (18/08/2026) como a estável atual: [godotengine.org/download/windows](https://godotengine.org/download/windows/).
- Um log antigo de outro projeto, de 13/10/2026, cita `Godot Engine v4.7.2.stable.official.ed1daf0bf`.

Na validação 01b, no mesmo dia, o ZIP oficial foi extraído fora do projeto, em `C:\Users\Raul\Tools\Godot\4.7.2-stable`. O comando `--version` do executável de console respondeu `4.7.2.stable.official.ed1daf0bf`. O detalhe está em `MD-usario/relatorios/01b-validacao-da-cena.md`.

Não use a linha 4.8 enquanto ela estiver em beta.

## Instalar o Godot, se ele não abrir

1. Baixe **Godot Engine 4.7.2**, Windows x86_64, a versão padrão (não a .NET).
2. Extraia o ZIP. O Godot não pede instalador: o executável já abre o editor.
3. Guarde a pasta extraída onde você costuma deixar ferramentas, por exemplo `D:\Progr\Godot`.
4. Na primeira abertura, o Windows pode pedir confirmação do SmartScreen. O executável oficial é assinado pela Prehensile Tales B.V.

## Abrir o projeto

1. Abra o executável do Godot.
2. Na lista de projetos, escolha **Import**.
3. Aponte para `D:\Progr\catlenight\project.godot` e confirme.
4. Abra o projeto. A primeira abertura cria a pasta `.godot\` com cache. Ela não entra no Git.

A cena principal já está configurada em **Project > Project Settings > Application > Run > Main Scene**:

`res://scenes/verification/main.tscn`

## Executar

Com o projeto aberto, pressione **F5**. O Godot roda a cena principal. A primeira coisa que acontece é o manequim cair e parar no chão, à esquerda do arco, de perfil para a direita. Segure a seta direita para passar por baixo do arco e seguir até a plataforma. A seta esquerda vira o perfil para a esquerda. Soltar a seta conserva essa direção.

## Controles

As ações estão em **Projeto > Configurações do Projeto > Mapa de Entrada**.

| Ação | Tecla | Efeito |
| --- | --- | --- |
| `esquerda` | Seta para a esquerda | Anda para X negativo enquanto a tecla está pressionada |
| `direita` | Seta para a direita | Anda para X positivo enquanto a tecla está pressionada |
| `pulo` | Espaço | Salta uma vez, só quando os pés estão no chão. No piloto 09 e no 10, depois da relíquia, um segundo toque no ar dá o impulso extra |
| `atacar` | X | Dá um golpe curto, no chão, para o lado em que o perfil está virado |
| `interagir` | Seta para cima | No piloto 10, entra na capela ou volta à sacada. No piloto 11, também grava no altar quando os pés estão apoiados diante dele |

Soltar a seta interrompe a caminhada. Apertar Espaço no ar não faz outro salto. Segurar Espaço até aterrissar também não faz outro salto: é preciso soltar e apertar de novo.

Segurar X durante o golpe inteiro produz um só ataque. Para outro, solte X e aperte de novo. O golpe usa a última direção, mesmo com o personagem parado. No ar, X não começa o golpe.

Se o corpo cair abaixo de Y = -2, ele volta ao ponto onde nasceu, com a velocidade zerada. O nascimento fica com os pés 1 m acima do chão. O arco está no chão antes da plataforma, com um pilar de cada lado de Z = 0.

Para subir na plataforma, corra na direção dela e aperte Espaço antes de encostar na lateral. Dá para descer pelo lado direito e voltar ao chão.

## Valores no Inspector

Abra `scenes/verification/main.tscn`, clique em `Jogador` e use o grupo **Movimento**:

- `velocidade_caminhada_m_por_s`: 3,5 m/s
- `velocidade_inicial_do_pulo_m_por_s`: 5,5 m/s

A cena do jogador, reutilizável, é `scenes/player/jogador.tscn`. A origem dela são os pés. O nó `Visual` carrega o filho `Modelo`, que é o GLB `assets/models/characters/protagonista_base.glb`, com escala 1. Quem gira na troca de direção é o `Visual`. A caixa `Colisao` permanece parada.

O arco reutilizável é `scenes/environment/arco_de_pedra.tscn`. Na cena principal, o nó `ArcoDePedra` está em X = -2,05, com rotação Y = 14 graus. Essas duas propriedades ficam no Inspector, em Transform. O GLB é o filho `Visual`. As caixas de colisão são os filhos de `Colisao`; o tamanho de cada uma está em Shape > Size.

## Trocar o nome provisório

No editor: **Project > Project Settings > Application > Config > Name**.

Isso grava `config/name` em `project.godot` e muda o título da janela. A pasta do projeto pode continuar `catlenight` até você decidir renomeá-la.

## O que ainda não existe

O indicador “Vida 3/3” existe a partir do piloto 08. O salto duplo existe no piloto 09, depois da relíquia. A passagem da sacada e a Capela da Lua existem no piloto 10. O altar e o menu de continuar existem no piloto 11. O resto da interface, outras habilidades e o áudio ficam para as próximas tarefas. As salas ligadas, o primeiro golpe, a sentinela, a vida por contato, a sacada, a capela e o salvamento estão nas cenas de verificação. A cena principal continua com o manequim, sem esqueleto, roupa nem equipamento. A animação definitiva da espada também fica para depois.

## Mapa dos textos

| Arquivo | Função |
| --- | --- |
| `CLAUDE.md` | Regras de trabalho, eixos e limite da etapa |
| `docs/GAME_DESIGN.md` | Visão, pilares e primeiro objetivo jogável |
| `docs/ROADMAP.md` | Etapas, critérios e status real |
| `docs/DECISIONS.md` | Decisões, motivo e impacto |
| `MD-usario/prompts/` | Cópia de cada prompt antes da implementação |
| `MD-usario/relatorios/` | Entrega e validação de cada etapa |

A skill em `.claude/skills/godot-gdscript-patterns/` é uma referência local para o editor de código. O jogo em execução usa só nós e GDScript nativos do Godot.
