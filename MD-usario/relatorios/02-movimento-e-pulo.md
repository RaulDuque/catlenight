# Relatório — Tarefa 02, movimento e pulo

Data: 19/11/2026. Godot usado: `4.7.2.stable.official.ed1daf0bf`, em `C:\Users\Raul\Tools\Godot\4.7.2-stable`.

## O que foi feito

O marcador parado virou um jogador reutilizável. Ao abrir o jogo, o bloco nasce com os pés 1 m acima do chão, cai e para na colisão. As setas andam em X, Espaço pula uma vez no chão, e o corpo permanece em Z = 0. Uma plataforma baixa fica à direita do nascimento.

## Referências

- Exemplo oficial Kinematic Character 3D, arquivo `3d/kinematic_character/player/cubio.gd` no repositório `godotengine/godot-demo-projects`, ramo `master`. O jogador altera `velocity` dentro de `_physics_process` e chama `move_and_slide()`. A gravidade usa `get_gravity()`. O demo também devolve o corpo ao início quando cai. O pulo do demo usa `is_action_pressed` depois da colisão; o Catlenight não copia isso, porque Espaço segurado dispararia outro salto.
- Skill `godot-gdscript-patterns`, revisão `51b6e0b507aa7942e36c6d33a94fc63aefc53d07` (28/09/2026), licença MIT. Copiada para `.claude/skills/godot-gdscript-patterns/` com `LICENSE` e `ORIGEM.md`. Dela saíram a cena reutilizável e o GDScript tipado. O jogo não carrega essa pasta.

## Arquivos

Criados:

- `scenes/player/jogador.tscn`
- `scenes/player/jogador.gd`
- `scenes/player/jogador.gd.uid`
- `tests/verificar_movimento.gd`
- `tests/verificar_movimento.gd.uid`
- `.claude/skills/godot-gdscript-patterns/` com `SKILL.md`, `references/`, `LICENSE` e `ORIGEM.md`
- `.claude/.gdignore`
- `MD-usario/prompts/02-movimento-e-pulo.md`
- `MD-usario/relatorios/02-movimento-e-pulo.md`
- `MD-usario/relatorios/evidencias/02-queda-quadro-00.png`
- `MD-usario/relatorios/evidencias/02-queda-quadro-20.png`
- `MD-usario/relatorios/evidencias/02-queda-quadro-45.png`

Alterados:

- `scenes/verification/main.tscn`
- `project.godot`
- `README.md`
- `CLAUDE.md`
- `docs/ROADMAP.md`
- `docs/DECISIONS.md`

O editor, ao abrir, também gerou `.import` para os PNG de evidência e para o ícone. A pasta `.godot` continua sendo cache.

## Cena do jogador

Caminho: `scenes/player/jogador.tscn`.

```
Jogador (CharacterBody3D)
├── Colisao (CollisionShape3D)
└── Visual (Node3D)
    └── Malha (MeshInstance3D)
```

A origem do `Jogador` são os pés. A malha e a colisão medem 0,8 × 1,70 × 0,5 m e ficam com o centro em Y = 0,85. As duas bases encostam em Y = 0. O modelo futuro do Blender entra como filho de `Visual`, com a origem nos pés.

Na cena principal, o nó `Jogador` está em X = -3,2, Y = 1, Z = 0. A plataforma está em X = 2,2, com 4 m de largura e topo em Y = 0,7. A câmera continua com Size = 8.

## Caminho de um salto

1. Espaço vira a ação `pulo` no `project.godot`, seção `[input]`. A tecla física é o código 32.
2. Em `scenes/player/jogador.gd`, a função `_physics_process` pergunta se o corpo está no chão com `is_on_floor()`.
3. Se estiver, e se `Input.is_action_just_pressed("pulo")` for verdadeiro, a linha `velocity.y = velocidade_inicial_do_pulo_m_por_s` grava 5,5 m/s para cima.
4. Enquanto não está no chão, inclusive na subida, `velocity += get_gravity() * delta` puxa o corpo para baixo.
5. `move_and_slide()` empurra o corpo e resolve a colisão com o chão e com a plataforma.

`is_action_just_pressed` só é verdadeiro no quadro em que Espaço desce. Por isso um segundo aperto no ar, ou Espaço que continua segurado na aterrissagem, não grava de novo a velocidade do pulo.

## Testes

### Física, pelo script de medição

Comando:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --headless --path D:\Progr\catlenight -s res://tests/verificar_movimento.gd`

Resultado: código 0, `RESULTADO ok`.

| Medida | Valor |
| --- | --- |
| Y inicial dos pés | 1,0000 m |
| Y ao estabilizar no chão | 0,0003 m |
| Pico do pulo | 1,5904 m |
| Velocidade vertical antes do segundo Espaço | 3,8667 m/s |
| Velocidade vertical depois do segundo Espaço | 3,3767 m/s |
| Parado sobre a plataforma | X = 2,1083 m, Y = 0,7009 m |
| De volta ao chão, à direita | X = 5,9583 m, Y = 0,0009 m |
| Maior afastamento em Z | 0 |
| Retorno depois da borda | verdadeiro, de volta a (-3,2, 1, 0) |

O segundo Espaço diminuiu a subida em vez de reiniciá-la. Isso é a gravidade agindo, não um novo pulo.

### Janela, com o projeto como entrada

Comando, sem passar a cena na linha de comando:

`C:\Users\Raul\Tools\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe --path D:\Progr\catlenight --write-movie ... --quit-after 50`

Código 0. Vulkan, Forward+, RTX 3060 Ti, quadro de 1280×720. Sem erro de script ou de recurso.

Quadros sucessivos da queda:

- `MD-usario/relatorios/evidencias/02-queda-quadro-00.png` — bloco no ar, plataforma à direita
- `MD-usario/relatorios/evidencias/02-queda-quadro-20.png` — bloco mais baixo, ainda com vão
- `MD-usario/relatorios/evidencias/02-queda-quadro-45.png` — base encostada no topo do chão

### F5 no editor

O editor 4.7.2 foi aberto e a tecla F5 foi pressionada. A janela `Catlenight (DEBUG)` mostrou o bloco vermelho de lado, apoiado no chão, com a plataforma azul-acinzentada à direita. O painel Saída mostrou o cabeçalho do motor e a linha do Vulkan. Não apareceu erro de script. O jogo foi encerrado em seguida.

As setas e o Espaço não foram pressionados por uma pessoa dentro dessa janela. Quem apertou as ações foi o script de medição, na execução headless. Falta a você sentir o controle com as próprias mãos.

## Pendências

- Jogar uma vez com as setas e o Espaço para conferir o ritmo. A física correspondente já foi medida.
- A próxima tarefa, o arco de pedra no Blender, não foi começada.
