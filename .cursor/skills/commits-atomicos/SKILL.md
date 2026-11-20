---
name: commits-atomicos
description: >-
  Cria commits atômicos no Git ao terminar um prompt que alterou o projeto.
  Use no fim de cada prompt, tarefa ou pedido que deixou arquivos modificados,
  e quando o usuário falar em commit, comitar, atomic commit ou salvar no Git.
---

# Commits atômicos

No fim de cada prompt que mudou arquivos deste repositório, grave tudo em commits atômicos. O pedido que criou esta skill autoriza esses commits. Não espere outro "pode commitar".

Não faça push, não crie remoto e não altere `git config`.

## Quando parar sem commit

- O prompt só perguntou ou explicou, e a árvore de trabalho está limpa.
- O commit incluiria segredo (`.env`, chave, token, senha). Avise e deixe o arquivo de fora.
- Um arquivo passa de 100 MB. O GitHub recusa. Deixe-o no `.gitignore` e avise.

## O que é um commit atômico

Um commit, um propósito. O conjunto dos commits cobre toda a mudança do prompt. No fim, `git status` fica limpo.

Um prompt com uma tarefa só vira um commit. Separe só o que não se explica com a mesma frase: código do jogo numa, skill ou ferramenta noutra.

## Passos

1. Em paralelo: `git status`, `git diff` e `git log -5 --oneline`.
2. Agrupe os arquivos por propósito. Inclua o que o prompt criou e o que ainda estava solto, para a árvore não ficar suja.
3. Para cada grupo, `git add` só desses caminhos e grave a mensagem pelo Bash do Git:

```bash
git -c user.name="$(git log -1 --format=%an)" -c user.email="$(git log -1 --format=%ae)" commit -m "$(cat <<'EOF'
Frase curta do porquê, em português.

EOF
)"
```

Se ainda não existe commit, use o nome e o e-mail que o `gh api user` devolver, no `-c`, sem gravar `git config`. O e-mail vazio vira `ID+LOGIN@users.noreply.github.com`.

4. Rode `git status` de novo. Se sobrar arquivo, ele entra num commit ou você explica por que ficou de fora.

A mensagem diz o porquê, em uma ou duas frases. Sem assinatura de ferramenta.
