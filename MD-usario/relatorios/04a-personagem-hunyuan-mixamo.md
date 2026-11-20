# Relatório — Tarefa 04-A, piloto Hunyuan e Mixamo

Data: 20/11/2026. Esta rodada valida a ferramenta. O manequim da Tarefa 04 continua em `scenes/player/jogador.tscn`. A cena principal e o controlador não foram alterados.

## O que ficou pronto

O Hunyuan3D-2 oficial está fora do jogo, em `D:\Tools\Hunyuan3D`. A geração usa só geometria, com o modelo `tencent/Hunyuan3D-2mini`, subpasta `hunyuan3d-dit-v2-mini`. A RTX 3060 Ti tem 8192 MiB. O driver NVIDIA é o 621.01. A RAM da máquina é 31,8 GB. O disco C: tinha cerca de 57 GB livres, então Python, ambiente e pesos foram para o disco D:.

Não havia imagem original do protagonista no projeto. As imagens em `MD-usario/relatorios/evidencias/` são capturas do jogo e do manequim. A pasta de exemplos do repositório também não traz um humanoide original autorizado para o Catlenight. A validação usou o exemplo oficial citado no README: `assets/demo.png`, um pinguim com uma placa. Esse resultado é teste da ferramenta, não o personagem do jogo.

## Onde colocar a imagem do protagonista

Salve o conceito neste caminho, com este nome:

`D:\Progr\catlenight\arte-fonte\hunyuan\entrada\protagonista.png`

Corpo inteiro, braços afastados do tronco, pernas separadas e pés visíveis. Fundo transparente ou liso. A imagem precisa ser original ou autorizada para o Catlenight. Com esse arquivo no lugar, a próxima rodada gera a malha, prepara o FBX e entrega o passo do Mixamo.

## Arquivos desta rodada

Fora do jogo:

- Código: `D:\Tools\Hunyuan3D\Hunyuan3D-2\Hunyuan3D-2-f8db63096c8282cb27354314d896feba5ba6ff8a`
- Revisão do GitHub: `f8db63096c8282cb27354314d896feba5ba6ff8a`, de 28/10/2025
- Pesos: `tencent/Hunyuan3D-2mini`, snapshot `f90a0f7df7d5e6f71109cf333f6a95a0ae3194a6`, em `D:\Tools\Hunyuan3D\hf-home`
- Python: 3.13.17, em `D:\Tools\Python313`
- Ambiente: `D:\Tools\Hunyuan3D\venv`
- Script que gerou a malha: `D:\Tools\Hunyuan3D\gerar_geometria.py`

No projeto:

- `arte-fonte/hunyuan/teste-ferramenta/demo.png` — cópia do exemplo oficial
- `arte-fonte/hunyuan/bruto/teste_ferramenta_demo.glb` — malha bruta, sem textura
- `arte-fonte/blender/teste_ferramenta_hunyuan.blend` — a mesma malha aberta no Blender
- `MD-usario/relatorios/evidencias/04a-teste-ferramenta-blender.png`
- `arte-fonte/hunyuan/entrada/LEIA.txt`

Não foram criados `protagonista_hunyuan_piloto.blend` nem `arte-fonte/mixamo/protagonista_hunyuan_upload.fbx`. Esses nomes ficam reservados para a malha do protagonista.

## Versões que funcionaram

A primeira tentativa, com `transformers` 5.23.0, não carregou o codificador de imagem: os nomes dos pesos do DINO não batiam. O conjunto que carregou o modelo e gerou a malha foi:

| Peça | Versão |
| --- | --- |
| torch | 2.11.0+cu128 |
| torchvision | 0.26.0+cu128 |
| transformers | 4.46.3 |
| diffusers | 0.32.2 |
| huggingface_hub | 0.36.2 |
| trimesh | 5.2.1 |
| pymeshlab | 2025.7.post1 |

A textura pede extensões em C++. Elas não foram compiladas. Esta etapa é só geometria.

Comando da geração, depois do ambiente pronto:

```
$env:HF_HOME = "D:\Tools\Hunyuan3D\hf-home"
D:\Tools\Hunyuan3D\venv\Scripts\python.exe D:\Tools\Hunyuan3D\gerar_geometria.py IMAGEM SAIDA.glb
```

Na validação, `IMAGEM` foi o `assets/demo.png` do repositório e `SAIDA` foi `arte-fonte/hunyuan/bruto/teste_ferramenta_demo.glb`.

## Medição da malha de teste

O modelo já estava em disco. Carregar os pesos levou 21,8 s. A geração, com 30 passos, `octree_resolution` 320 e `num_chunks` 8000, levou 37,0 s. O total do processo foi 58,9 s. A malha tem 232403 vértices e 464816 faces.

No Blender, depois da conversão do glTF, a caixa mede 1,305 × 1,105 × 1,994 m. O eixo alto é o Z. O corpo está centrado: a base fica em Z = −1,001, não no piso. Há um único objeto, `geometry_0`. O `trimesh` separou 2 componentes e a malha não é fechada. As nadadeiras encostam nas hastes da placa; não são peças soltas. Axilas, mãos, virilha e botas não existem nesse exemplo, então essa conferência fica para a imagem do protagonista.

A licença do repositório é a Tencent Hunyuan 3D 2.0 Community License. Para este estudo pessoal ela é gratuita. A distribuição do modelo ou de um produto com mais de 1 milhão de usuários ativos pede leitura do arquivo `LICENSE` e, nesse caso, um pedido à Tencent. O piloto não entra na cena jogável.

## O que continua pendente

- Gerar a malha a partir de `arte-fonte/hunyuan/entrada/protagonista.png`.
- Ajustar essa malha para 1,70 m, sola no piso, corpo ereto e de frente, e exportar `D:\Progr\catlenight\arte-fonte\mixamo\protagonista_hunyuan_upload.fbx`.
- O passo manual no Mixamo, com a sua conta Adobe.
- Importar o FBX animado, exportar o GLB do piloto e montar a cena de teste. A corrida deve seguir o movimento horizontal no chão e parar quando a seta for solta. O deslocamento continua no controlador. A frente visual, nessa integração, aponta para +X, como o manequim.
- A integração no Godot está pendente. `scenes/player/jogador.tscn` e `scenes/verification/main.tscn` permanecem os da Tarefa 04.

## Passo do Mixamo, para quando o FBX existir

Não envie o pinguim. O arquivo de envio, quando a malha do protagonista estiver pronta, será:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_hunyuan_upload.fbx`

No site [mixamo.com](https://www.mixamo.com), entre com a conta Adobe e use Upload Character. Os marcadores automáticos precisam cair nestes pontos: queixo, pulsos, cotovelos, virilha e joelhos. Se algum ficar fora da junta, arraste o marcador para o centro dela. O cotovelo fica no meio do braço, entre ombro e pulso. O joelho fica no meio da perna, entre quadril e tornozelo.

Na prévia, gire um cotovelo e um joelho. O antebraço deve dobrar para a frente e a canela também. Se o membro torcer para o lado ou a dobra nascer no meio do osso, recoloque o marcador e confirme de novo.

Na biblioteca, busque a animação **Running**. Se houver mais de uma, use a `Running` simples, de corrida para a frente. No painel da animação, marque **In Place** quando a opção aparecer, para o ciclo não andar por conta própria. O deslocamento no jogo continua sendo o do controlador.

No download: formato FBX, pele incluída (**With Skin**), 30 quadros por segundo. Salve o arquivo exatamente como:

`D:\Progr\catlenight\arte-fonte\mixamo\protagonista_hunyuan_corrida.fbx`

Com esse arquivo na pasta, a integração no Godot pode continuar.
