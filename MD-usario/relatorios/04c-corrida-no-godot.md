# 04-C — Corrida no Godot

Data: 20/11/2026. Godot 4.7.2 e Blender 5.3.0.

O FBX baixado do Mixamo entrou no piloto. A cena principal continua com o manequim da Tarefa 04. O F5 do editor não foi pressionado. A janela do Godot abriu pelo script `tests/capturar_corrida.tscn`, que carrega a cena do piloto, aperta as teclas e grava a vista da câmera.

## O que o FBX contém

Arquivo original, preservado: `arte-fonte/mixamo/protagonista_hunyuan_corrida.fbx` (3,41 MB, gravado às 01:45).

O Blender encontrou uma malha, um esqueleto de 41 ossos `mixamorig` ligado a ela e um clipe. A malha tem 175816 triângulos. É o corpo preparado na Tarefa 04-B, sem casaco e sem espada. O nome da malha no arquivo é `unamed`, grafia que veio do Mixamo.

O clipe no FBX se chama `Armature|mixamo.com|Layer0`. Vai do quadro 1 ao quadro 23, a 30 fps. O quadro 23 repete o quadro 1, então o movimento único dura 22 quadros. No Godot, o clipe se chama `corrida` e mede 0,7667 s.

Dois ciclos foram reproduzidos. Ombros, punhos, joelhos e botas acompanham a passada. Os joelhos continuam flexionados durante a corrida. O cabelo solto deforma de forma irregular, com mechas saindo do volume da cabeça. Isso ficou visível em `04c-blender-frente.png`, `04c-blender-ciclo-a.png` e `04c-blender-ciclo-b.png`.

O quadril do quadro 23 coincide com o do quadro 1. O clipe não empurra o personagem para a frente a cada volta. O balanço do tronco foi mantido. O quadril sobe e desce cerca de 9 cm ao longo do ciclo.

## A cópia usada no jogo

A pose de referência mede 1,7000 m, com a sola em Z = 0. A face aponta para +X no Blender, que continua +X no Godot.

A corrida, no arquivo original, deixava o repouso com os pés no centro do corpo e usava a altura do quadril para pôr a sola no chão. Na cópia, o repouso foi apoiado no piso e o canal vertical do quadril desceu 0,954 m em todos os quadros. A sola dos quadros de apoio ficou entre 0,2 cm e 0,4 cm do piso. A flexão dos joelhos e o sobe-e-desce do quadril permaneceram.

Arquivos dessa cópia:

- `arte-fonte/blender/protagonista_hunyuan_corrida.blend`
- `assets/models/characters/protagonista_hunyuan_corrida.glb` (6,03 MB)

## A cena do piloto

`scenes/verification/04c_corrida_mixamo.tscn` repete a sala da cena principal: chão, arco, plataforma e `CameraLateral` com `Size` = 8.

O jogador é a mesma cena `scenes/player/jogador.tscn`. Nesta instância, a propriedade `modelo_da_corrida` aponta para o GLB novo. Na cena principal essa propriedade fica vazia, e o manequim continua no lugar. Para ver o valor: abra o piloto, selecione `Jogador` e olhe o grupo **Corrida** no Inspetor.

O controlador não mudou de papel. A caminhada continua em 3,5 m/s, o pulo em 5,5 m/s, o `Visual` gira e a colisão fica parada. O plano Z = 0 permanece.

A velocidade do clipe está em `Jogador`, grupo **Corrida**, propriedade `velocidade_da_animacao`. O valor usado é **1,3**. Com 1,0, o tornozelo do pé de apoio andava cerca de 0,32 m para a frente durante a passada. Com 1,3, um apoio inteiro deslocou o tornozelo 0,0025 m e o seguinte −0,119 m.

## O trecho que liga e desliga a corrida

Em `scenes/player/jogador.gd`, o clipe só existe quando o piloto trocou o modelo. No manequim, `_preparar_corrida` não acha o `AnimationPlayer` e o resto do controlador segue igual.

```gdscript
func _preparar_corrida() -> void:
	_animacao = _visual.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_esqueleto = _visual.find_child("Skeleton3D", true, false) as Skeleton3D
	if _animacao == null or not _animacao.has_animation(_CLIP):
		_animacao = null
		return
	var clipe := _animacao.get_animation(_CLIP)
	clipe.loop_mode = Animation.LOOP_LINEAR
	_animacao.speed_scale = velocidade_da_animacao


func _atualizar_corrida(no_chao: bool, eixo_horizontal: float) -> void:
	if _animacao == null:
		return
	var deve_correr := no_chao and eixo_horizontal != 0.0
	if not no_chao:
		if _correndo:
			_quadro_suspenso = _animacao.current_animation_position
			_animacao.pause()
			_correndo = false
			_suspensa = true
		return
	if deve_correr:
		if not _correndo:
			_animacao.play(_CLIP)
			if _suspensa:
				_animacao.seek(_quadro_suspenso, true)
			_correndo = true
			_suspensa = false
		return
	if _correndo or _suspensa:
		_animacao.stop()
		if _esqueleto:
			_esqueleto.reset_bone_poses()
		_correndo = false
		_suspensa = false
```

`_CLIP` é `"corrida"`. A função roda no fim de `_physics_process`, depois do `move_and_slide`. No chão e com seta, `play` começa o clipe. Ao soltar, `stop` e a pose de repouso do esqueleto. No ar, `pause`. Ao pousar ainda com seta, `play` seguido de `seek` continua do quadro em que a corrida parou.

## O que apareceu na janela

A câmera é a lateral da sala, `Size` = 8, 1280×720.

- `04c-godot-apoio-01.png`: debaixo do arco, correndo para a direita, uma perna estendida para trás e a outra no chão.
- `04c-godot-apoio-02.png` e `04c-godot-apoio-03.png`: já saiu do arco, em direção à plataforma. A perna de trás trocou.
- `04c-godot-apoio-04.png`: o outro passo, ainda antes da plataforma.
- `04c-godot-repouso.png`: seta solta, corpo em pé, pés no chão, rosto continuando para a direita.
- `04c-godot-esquerda.png`: seta esquerda, perfil virado para a esquerda e corrida de novo.

O cabelo aparece como um volume claro atrás da cabeça. O corpo permanece junto da passagem e da plataforma, sem ficar para trás da colisão.

## O que o teste mediu

Percurso do piloto, na mesma janela:

| Medida | Valor |
| --- | --- |
| Clipe no Godot | `corrida`, 0,7667 s |
| Tornozelo num apoio inteiro | 0,0025 m em 18 quadros |
| Tornozelo no apoio seguinte | −0,119 m em 16 quadros |
| Quadril local no começo e no fim da corrida livre | −0,0965 m e −0,0881 m |
| Posição do clipe no ar e ao pousar | 0,6298 s e 0,6515 s |
| Plataforma | X = 3,9407, Y = 0,7009 |
| Maior Z | 0 |

Os testes antigos rodaram de novo com o script final, na cena principal:

- `tests/verificar_movimento.gd`: `RESULTADO ok`. Pouso em Y = 0,0003, pico do pulo em Y = 1,5904, plataforma em X = 2,1083 e Y = 0,7009, volta ao chão em X = 5,9583 e Y = 0,0009, Z = 0.
- `tests/verificar_direcao.gd`: `RESULTADO ok`. Altura importada do manequim 1,7000 m, sola em Y = 0. Direita, soltar, esquerda, soltar e pulo sem seta conservaram a rotação do `Visual`.
- `tests/verificar_arco.gd`: `RESULTADO ok`. Ida e volta pelo vão, pés em Y = 0,0003, Z = 0.

## Arquivos

Criados:

- `MD-usario/prompts/04c-corrida-no-godot.md`
- `arte-fonte/blender/protagonista_hunyuan_corrida.blend`
- `assets/models/characters/protagonista_hunyuan_corrida.glb`
- `scenes/verification/04c_corrida_mixamo.tscn`
- `tests/capturar_corrida.gd`
- `tests/capturar_corrida.tscn`
- `MD-usario/relatorios/evidencias/04c-godot-apoio-01.png` a `04c-godot-apoio-04.png`
- `MD-usario/relatorios/evidencias/04c-godot-repouso.png`
- `MD-usario/relatorios/evidencias/04c-godot-esquerda.png`
- `MD-usario/relatorios/evidencias/04c-blender-ciclo-a.png`
- `MD-usario/relatorios/evidencias/04c-blender-ciclo-b.png`
- `MD-usario/relatorios/evidencias/04c-blender-frente-x.png`

Alterados: `scenes/player/jogador.gd`, `docs/ROADMAP.md`, `CLAUDE.md`.

`scenes/player/jogador.tscn` e `scenes/verification/main.tscn` ficaram como estavam.

## Como repetir

Abra `scenes/verification/04c_corrida_mixamo.tscn`.

Pressione **F6** (Executar Cena Atual). O **F5** abre a cena principal, que continua com o manequim.

Teclas:

1. Seta para a direita: corre sob o arco, de frente para a direita.
2. Solte a seta: para em pé, olhando para a direita.
3. Seta para a esquerda: vira e corre para a esquerda.
4. Seta para a direita de novo e, antes da plataforma, Espaço: pula. Se a seta continuar apertada, a corrida volta quando os pés tocam a plataforma.

Para sentir o pé no chão, mude `velocidade_da_animacao` no `Jogador`. O valor desta etapa é 1,3. A caminhada de 3,5 m/s fica no grupo **Movimento**.
