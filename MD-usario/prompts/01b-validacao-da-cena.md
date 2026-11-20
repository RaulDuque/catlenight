Continue o projeto Catlenight na pasta D:\Progr\catlenight. Sua tarefa é executar e validar a cena principal que já existe. O objetivo de estudo é entender o caminho entre o arquivo project.godot e a primeira imagem do jogo.

1. Salve este prompt integralmente em MD-usario/prompts/01b-validacao-da-cena.md. Leia o relatório da Tarefa 01 e confira a configuração atual de project.godot. Aproveite a busca pelo executável já documentada.

2. Prepare o Godot para Windows. Confira no arquivo oficial de versões do Godot se a versão 4.7.2 indicada no relatório está disponível. Se estiver, baixe o ZIP oficial da edição padrão para Windows x86_64, verifique o checksum publicado quando disponível e extraia em uma pasta de ferramentas do usuário, fora do projeto. Use o executável pelo caminho completo. Registre a saída real de --version. Se a versão indicada estiver incorreta ou indisponível, registre o que encontrou antes de propor uma mudança de versão do projeto.

3. Importe o projeto e execute primeiro uma verificação pelo terminal. Depois abra a cena principal em uma janela usando o projeto como ponto de entrada. Isso testa também se a configuração da cena principal funciona. Se aparecer um erro, registre a mensagem exata, corrija a causa dentro do escopo desta tarefa e repita o teste.

4. Confira na janela ou em uma captura real:
   - O chão está visível e enquadrado.
   - O bloco vermelho aparece de lado, com a base encostada no topo do chão.
   - A imagem permite distinguir o bloco do fundo.
   - A câmera mantém o enquadramento original com Size = 8.

   Se conseguir capturar a janela, salve a imagem em MD-usario/relatorios/evidencias/01b-cena-principal.png. Se conseguir abrir a janela, mas depender de mim para olhar, deixe-a aberta e me diga exatamente o que conferir. Registre separadamente o resultado da importação, da execução e da inspeção visual. Só registre “F5 testado” se o teste tiver sido feito pelo editor com F5.

5. Crie MD-usario/relatorios/01b-validacao-da-cena.md com a versão executada, o comando usado, o resultado e qualquer correção. Atualize docs/ROADMAP.md conforme o que foi comprovado. Preserve o relatório 01 como histórico. Se precisar da minha confirmação visual, deixe esse item pendente.

6. Termine com uma explicação curta para estudo: por que o bloco desta cena pode parecer apoiado no chão mesmo sem ter um corpo físico? Indique os dois valores da cena que explicam esse resultado.

Escopo: validar a fundação existente. Movimentação e pulo pertencem à Tarefa 02.
