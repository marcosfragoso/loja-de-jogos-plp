# :video_game:🕹️ Loja de Jogos  

Neste projeto, criaremos um sistema de uma loja de jogos digitais, possibilitando ao usuário uma forma fácil de adquirir seus jogos e mantê-los em sua biblioteca, gerenciar sua carteira digital e diversas outras funcionalidades utilizando apenas o terminal de linha de comando.  

Cada usuário possuirá uma conta, podendo esta ser administrador (admin) ou padrão. Assim, após a criação da conta, o usuário padrão poderá realizar login no sistema para visualizar os jogos, avaliá-los, deixar comentários sobre o jogo, comprar os jogos que desejar, gerenciar sua carteira digital com operações de depósito e consulta de saldo, e também bater um papo com outro usuário através de um chat privado.  

Para facilitar a busca de jogos por parte do usuário, além da pesquisa por nome, o sistema conta com métodos de filtragem para exibição dos jogos (mais vendidos, mais jogados, lançamentos, gêneros como RPG, terror, puzzle, etc).  

O usuário administrador tem privilégios no sistema, como cadastrar jogos, atualizar jogos, ter um dashboard com diversas estatísticas do sistema e analisar as denúncias feitas pelos usuários.  

# :gear::clipboard: Funcionalidades  
- **Gerais**
  - Criar conta;
  - Fazer login.
 
- **Administrador**
  - Adicionar, atualizar, visualizar e remover jogos;
  - Analisar denúncias;
  - Visualizar dashboard com estatísticas do sistema.

- **Usuário padrão**
  - Visualizar jogos disponíveis (A visualização pode ser filtrada por gênero, mais vendidos, data de lançamento, mais avaliados, nome e preço);
  - Comprar jogos disponíveis;
  - Avaliar jogos;
  - Favoritar jogos;
  - Gerenciar carteira digital (depósito e consulta de saldo);
  - Comentar jogo;
  - Denunciar jogo;
  - Conversar através de chat privado com outros usuários.

  

# :wrench::computer: Como executar  
## Instalação do PostgreSQL
1. Baixe o PostgreSQL:
   
   - [Tutorial para Windows](https://www.youtube.com/watch?v=L_2l8XTCPAE&list=LL&index=5)
   - [Tutorial para Linux Ubuntu](https://www.youtube.com/watch?v=1jSb4LJH1dw)
   - [Tutorial para Linux Mint (Em caso de problemas no vídeo acima)](https://www.youtube.com/watch?v=rDh3iq8nmDg)
     
3. Após a instalação, entre no pgAdmin e crie a database com o nome "lojajogos"
4. Configurações iniciais
   - Caso peça para configurar username e password antes do passo 2, configure da seguinte forma:
     
      ```
      username: postgres
      password: postgres
      host name/address: localhost
      port: 5432
      ```
   - Caso não peça, clique com o botão direito no servidor onde está sua database, vá em connection e configure com as informações acima.

       
**Observação**: A configuração deve seguir a mesma que o tutorial acima. Caso contrário, a aplicação pode resultar em erros. 

# 👨‍💻👩‍💻 Equipe  

- [Marcos Vinícius](https://github.com/marcosfragoso)
- [Marcos Antônio](https://github.com/MarcosAntonio15243)
- [Leila Farias](https://github.com/LeilaFarias)
- [João Victor](https://github.com/VictorCosme)
- [Hildon Regis](https://github.com/Hildon27)

