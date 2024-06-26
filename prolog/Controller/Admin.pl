:- module(telaAdmin, [menuAdmin/0]).
:- use_module("../LocalDB/ConnectionDB").
:- use_module("../LocalDB/DatabaseOperations").
:- use_module(library(date)).
:- use_module("../util").
:- use_module("../Controller/Jogo").

menuAdmin :-
    writeln("================================================================================"),
    writeln("                             HOME - ADMINISTRADOR                               "),
    writeln("================================================================================"),
    writeln('|1. Adicionar Jogo                  |'),
    writeln('|2. Exibir Jogo                     |'),
    writeln('|3. Atualizar Jogo                  |'),
    writeln('|4. Remover Jogo                    |'),
    writeln('|5. Exibir Denuncia                 |'),
    writeln('|6. DashBoard                       |'),
    writeln('|7. Sair                            |'),
    write('Escolha uma opção: '),
    read_line_to_string(user_input, Opcao),
    writeln(''),
    (Opcao == "1" -> limparTela, cadastraJogo;
     Opcao == "2" -> limparTela, exibirJogo;
     Opcao == "3" -> limparTela, atualizarJogo;
     Opcao == "4" -> limparTela, apagarJogo;
     Opcao == "5" -> limparTela, exibirDenuncia;
     Opcao == "6" -> limparTela, dashboard;
     Opcao == "7" -> limparTela;
     limparTela, writeln('Opcao invalida, por favor, tente novamente'), menuAdmin).

cadastraJogo :-
    get_connection(Connection),
    writeln(''),
    writeln("================================================================================"),
    writeln('                       | Digite as informações do jogo |'),
    writeln("================================================================================"),
    write('|Nome do jogo: '),
    read_line_to_string(user_input, NomeJogo),
    (
        gameAlreadyExistByName(Connection, NomeJogo) -> limparTela, writeln("Nome de jogo ja existente, por favor, tente novamente."), cadastraJogo;
        write('|Descrição do jogo: '),
        read_line_to_string(user_input, DescricaoJogo),
        writeln('|1. Ação e Aventura'),
        writeln('|2. RPG '),
        writeln('|3. Terror'),
        writeln('|4. Estratégia'),
        writeln('|5. FPS'),
        write('|Selecione o gênero do jogo: '),
        read_line_to_string(user_input, Option),
        converteGenero(Option, GeneroJogo),
        write('|Valor do jogo: '),
        read_line_to_string(user_input, ValorDoJogoString),
        (
            not(verificaCamposNaoVazios([NomeJogo, DescricaoJogo, ValorDoJogoString])) -> 
            limparTela,
            writeln("Você digitou um campo vazio, por favor, tente novamente."),
            cadastraJogo;
            atom_number(ValorDoJogoString, ValorDoJogo),
            (ValorDoJogo < 0 -> limparTela, writeln("O valor do jogo não pode ser menor que zero, por favor, tente novamen"),
            cadastraJogo;
            /* Transformando a data atual para o formato YYYY-MM-DD */
            get_time(TStamp),
            format_time(string(Txt),'%FT%T%z',TStamp),
            split_string(Txt, "T", "", DataSplitada),
            nth0(0, DataSplitada, DataFormatada),
            Q = "INSERT INTO jogo (game_nome, game_genero, game_description, game_data_lancamento, game_avaliacao, game_price) values ('%w', '%w', '%w', '%w', %w, %w)",
            db_parameterized_query_no_return(Connection, Q, [NomeJogo, GeneroJogo, DescricaoJogo, DataFormatada, 0.0, ValorDoJogo]),
            limparTela,
            writeln("Jogo cadastrado com sucesso!"),
            encerrandoDatabase(Connection),
            menuAdmin)
    )).

converteGenero("1", "Ação e Aventura") :-!.
converteGenero("2", "RPG") :- !.
converteGenero("3", "Terror") :- !.
converteGenero("4", "Estratégia") :-!.
converteGenero("5", "FPS") :-!.
converteGenero(_, _) :- limparTela, writeln("Opção inválida, tente novamente."), cadastraJogo, !.

exibirJogo :-
    get_connection(Connection),
    getJogosAdm(Connection, Jogos),
    printJogosIdNome("1", Jogos),
    write("Digite o id do jogo que deseja exibir as informacoes: "),
    read_line_to_string(user_input, IdJogo),
    (
        jogoExisteAdm(Connection, IdJogo) ->
        getJogosByIdAdm(Connection, IdJogo, [Jogo|_]),
        limparTela,
        printJogoDetalhadoAdm(Jogo),
        menuAdmin;
        limparTela,
        writeln("Nao existe nenhum jogo com esse ID, por favor, tente novamente."),
        exibirJogo
    ).

apagarJogo:-
    get_connection(Connection),
    getJogosAdm(Connection, Jogos),
    printJogosIdNome("1", Jogos),
    write("Digite o id do jogo que deseja apagar: "),
    read_line_to_string(user_input, IdJogo),
    (
        jogoExisteAdm(Connection, IdJogo) ->
        format(atom(StringFormatada), "Tem certeza que deseja apagar o jogo com o id ~w? [S/N]: ", [IdJogo]),
        write(StringFormatada),
        read_line_to_string(user_input, Option),
        string_lower(Option, LowerOption),
        (
            atom_string(LowerOption, 's') -> apagarJogoBD(Connection, IdJogo),
            limparTela,
            writeln("Jogo apagado com sucesso."),
            menuAdmin;
            limparTela,
            atom_string(LowerOption, 'n')-> writeln("Operacao de remoçao abortada."),
            menuAdmin;
            limparTela,
            writeln("Opcao invalida, por favor, tente novamente."),
            apagarJogo
        );
        limparTela,
        writeln("Nao existe nenhum jogo com esse ID, por favor, tente novamente."),
        apagarJogo
    ).     

apagarJogoBD(Connection, IdJogo):-
    Q = 'DELETE FROM jogo WHERE game_id = %w',
    db_parameterized_query_no_return(Connection, Q, [IdJogo]).

atualizarJogo :-
    get_connection(Connection),
    getJogosAdm(Connection, Jogos),
    printJogosIdNome("1", Jogos),
    write("Digite o id do jogo que deseja atualizar: "),
    read_line_to_string(user_input, IdJogo),
        (
        jogoExisteAdm(Connection, IdJogo) ->
        limparTela,
        atualizaNomeJogo(Connection, IdJogo),
        atualizaDescricaoJogo(Connection, IdJogo),
        atualizaGeneroJogo(Connection, IdJogo),
        atualizaPrecoJogo(Connection, IdJogo),
        menuAdmin;
        limparTela,
        writeln("Nao existe nenhum jogo com esse ID, por favor, tente novamente."),
        atualizarJogo
    ). 

atualizaNomeJogo(Connection, IdJogo):-
    write("Deseja atualizar o nome do jogo? [S/N]: "),
    read_line_to_string(user_input, NameOption),
    string_lower(NameOption, NameOptionLower),
    (
    atom_string(NameOptionLower, 's') ->
    write("Digite o novo nome do jogo: "),
    read_line_to_string(user_input, NomeNovo),
    analisaNomeNovoJogo(Connection, NomeNovo, IdJogo);
    atom_string(NameOptionLower, 'n') -> limparTela;
    limparTela, writeln("Opcao invalida, por favor tente novamente!"), atualizaNomeJogo(Connection, IdJogo)
    ).

analisaNomeNovoJogo(Connection, NomeNovo, IdJogo) :-
   gameAlreadyExistByName(Connection, NomeNovo) -> limparTela, writeln("Nome de jogo ja existente, por favor, tente novamente."), atualizaNomeJogo(Connection, IdJogo);
   not(verificaCamposNaoVazios([NomeNovo])) -> limparTela, writeln("O nome do jogo nao poder ser vazio, por favor, tente novamente.") , atualizaNomeJogo(Connection, IdJogo);
   Q = "UPDATE jogo SET game_nome = '%w' WHERE game_id = '%w'",
   db_parameterized_query_no_return(Connection, Q, [NomeNovo, IdJogo]),
   limparTela,
   writeln("O nome do jogo atualizado com sucesso!").  

atualizaDescricaoJogo(Connection, IdJogo):-
    write("Deseja atualizar a descricao do jogo? [S/N]: "),
    read_line_to_string(user_input, DescOption),
    string_lower(DescOption, DescOptionLower),
    (
    atom_string(DescOptionLower, 's') -> write("Digite a nova descricao do jogo: "),
    read_line_to_string(user_input, DescricaoNova),
    analisaDescricaoNovaJogo(Connection, DescricaoNova, IdJogo);
    atom_string(DescOptionLower, 'n') -> limparTela;
    limparTela, writeln("Opcao invalida, por favor tente novamente!"), atualizaDescricaoJogo(Connection, IdJogo)
    ).

analisaDescricaoNovaJogo(Connection, DescricaoNova, IdJogo) :-
    not(verificaCamposNaoVazios([DescricaoNova])) -> limparTela, writeln("A descricao nao pode ser vazia, por favor, tente novamente!"), atualizaDescricaoJogo(Connection, IdJogo);
    limparTela,
    Q = "UPDATE jogo SET game_description = '%w' WHERE game_id = '%w'",
    db_parameterized_query_no_return(Connection, Q, [DescricaoNova, IdJogo]),
    writeln("A descricao do jogo foi alterada com sucesso!").

atualizaGeneroJogo(Connection, IdJogo):-
    write("Deseja atualizar o genero do jogo? [S/N]: "),
    read_line_to_string(user_input, GeneroOption),
    string_lower(GeneroOption, GeneroOptionLower),
    (
    atom_string(GeneroOptionLower, 's') ->
    writeln('|1. Ação e Aventura'),
    writeln('|2. RPG '),
    writeln('|3. Terror'),
    writeln('|4. Estratégia'),
    writeln('|5. FPS'),
    write('|Selecione o gênero do jogo: '),
    read_line_to_string(user_input, Option),
    converteGeneroAtualiza(Option, Connection, IdJogo);
    atom_string(GeneroOptionLower, 'n') -> limparTela;
    limparTela, writeln("Opcao invalida, por favor tente novamente!"), atualizaGeneroJogo(Connection, IdJogo)
    ).

converteGeneroAtualiza("1", Connection, IdJogo) :- Q = "UPDATE jogo SET game_genero = 'Ação e Aventura' WHERE game_id = '%w'", db_parameterized_query_no_return(Connection, Q, [IdJogo]), limparTela, writeln("Genero do jogo atualizado com sucesso!").

converteGeneroAtualiza("2", Connection, IdJogo) :- Q = "UPDATE jogo SET game_genero = 'RPG' WHERE game_id = '%w'", db_parameterized_query_no_return(Connection, Q, [IdJogo]), limparTela, writeln("Genero do jogo atualizado com sucesso!").

converteGeneroAtualiza("3", Connection, IdJogo) :- Q = "UPDATE jogo SET game_genero = 'Terror' WHERE game_id = 'Terror'", db_parameterized_query_no_return(Connection, Q, [IdJogo]), limparTela, writeln("Genero do jogo atualizado com sucesso!").

converteGeneroAtualiza("4", Connection, IdJogo) :- Q = "UPDATE jogo SET game_genero = 'Estratégia' WHERE game_id = 'Terror'", db_parameterized_query_no_return(Connection, Q, [IdJogo]), limparTela, writeln("Genero do jogo atualizado com sucesso!").

converteGeneroAtualiza("5", Connection, IdJogo) :- Q = "UPDATE jogo SET game_genero = 'FPS' WHERE game_id = 'Terror'", db_parameterized_query_no_return(Connection, Q, [IdJogo]), limparTela, writeln("Genero do jogo atualizado com sucesso!").

converteGeneroAtualiza(_, Connection, IdJogo) :- limparTela, writeln("Opção inválida, tente novamente."), atualizaGeneroJogo(Connection, IdJogo), !.

atualizaPrecoJogo(Connection, IdJogo):-
    write("Deseja atualizar o preco do jogo? [S/N]: "),
    read_line_to_string(user_input, PrecoOption),
    string_lower(PrecoOption, PrecoOptionLower),
    (
    atom_string(PrecoOptionLower, 's') -> write("Digite o novo preco do jogo: "),
    read_line_to_string(user_input, PrecoNovo),
    analisaPrecoNovoJogo(Connection, PrecoNovo, IdJogo);
    atom_string(PrecoOptionLower, 'n') -> limparTela;
    limparTela, writeln("Opcao invalida, por favor tente novamente!"), atualizaDescricaoJogo(Connection, IdJogo)
    ).

analisaPrecoNovoJogo(Connection, PrecoNovoString, IdJogo) :-
    not(verificaCamposNaoVazios([PrecoNovoString])) -> limparTela, writeln("O preco do jogo nao pode ser vazio, por favor, tente novamente!"), atualizaPrecoJogo(Connection, IdJogo);
    atom_number(PrecoNovoString, PrecoNovo),
    PrecoNovo < 0 -> limparTela, writeln("O valor do jogo não pode ser menor que zero, por favor, tente novamente"),atualizaPrecoJogo(Connection, IdJogo);
    limparTela, atom_number(PrecoNovoString, PrecoNovo), Q = "UPDATE jogo SET game_price = '%w' WHERE game_id = '%w'",
    db_parameterized_query_no_return(Connection, Q, [PrecoNovo, IdJogo]), writeln("Preco do jogo atualizado com sucesso!").

exibirDenuncia :-
    get_connection(Connection),
    (not(existeDenuncia(Connection)) -> limparTela, writeln('Nao existe nenhuma denuncia no momento!'), menuAdmin;
    getDenuncia(Connection, [Denuncia]),
    (Denuncia == [] -> limparTela, writeln('Nao existe nenhuma denuncia no momento!'), menuAdmin;
    printDenuncia(Denuncia),
    writeln('Com base nessa denuncia, o que deseja fazer?'),
    writeln('|1. Excluir o Jogo'),
    writeln('|2. Ocultar o Jogo'),
    writeln('|3. Desconciderar denuncia'),
    write('Escolha uma opção: '),
    read_line_to_string(user_input, Opcao),
    writeln(''),
    (Opcao == "1" -> limparTela, excluirJogoDenuncia(Connection, Denuncia), writeln('Jogo apagado com sucesso'), menuAdmin;
     Opcao == "2" -> limparTela, ocultaJogoDenuncia(Connection, Denuncia), writeln('Jogo ocultado com sucesso'), menuAdmin;
     Opcao == "3" -> limparTela, getDenunciaId(Denuncia, IdDenuncia), apagaDenuncia(Connection, IdDenuncia), writeln('Denuncia desconciderada!'), menuAdmin;
     imparTela, writeln('Opcao invalida, por favor, tente novamente!'), exibirDenuncia))).

excluirJogoDenuncia(Connection, Denuncia) :-
    getJogoIdDenuncia(Denuncia, IdJogo), 
    getDenunciaId(Denuncia, IdDenuncia),
    apagarJogoBD(Connection, IdJogo), 
    apagaDenuncia(Connection, IdDenuncia).

ocultaJogoDenuncia(Connection, Denuncia) :-
    getJogoIdDenuncia(Denuncia, IdJogo), 
    getDenunciaId(Denuncia, IdDenuncia),
    ocultaJogo(Connection, IdJogo),
    apagaDenuncia(Connection, IdDenuncia).

printDenuncia([]).

printDenuncia(row(IdDenuncia, IdUsuario, IdJogo, Motivo, Descricao, date(Ano, Mes, Dia))) :-
    writeln("================================================================================"),
    writeln("                             INFORMACOES DENUNCIA                               "),
    writeln("================================================================================"),
    format('ID da Denuncia : ~d~nID do Usuario: ~d~nID do Jogo: ~d~nMotivo: ~w~nDescricao: ~w~nData da denuncia: ~d/~d/~d~n', [IdDenuncia, IdUsuario, IdJogo, Motivo, Descricao, Dia, Mes, Ano]),
    writeln("================================================================================").

getDenuncia(Connection, Denuncia) :-
    Q = "SELECT * FROM  denuncia LIMIT 1",
    db_query(Connection, Q, Denuncia).

getDenunciaId(row(IdDenuncia, _, _, _, _, _), IdDenuncia).

getJogoIdDenuncia(row(_, _, IdJogo, _, _ ,_), IdJogo).

ocultaJogo(Connection, IdJogo) :-
    Q = "UPDATE jogo SET game_visibilidade = 'false' WHERE game_id = '%w'",
    db_parameterized_query_no_return(Connection, Q, [IdJogo]).

apagaDenuncia(Connection, IdDenuncia) :-
    Q = "DELETE FROM denuncia WHERE denuncia_id = '%w'",
    db_parameterized_query_no_return(Connection, Q, [IdDenuncia]).

existeDenuncia(Connection) :-
    Q = "SELECT COUNT(*) FROM denuncia",
    db_query(Connection, Q, [row(CountRow)]),
    (CountRow > 0).

dashboard :-
    get_connection(Connection),
    writeln("================================================================================"),
    writeln("                             MENU - DASHBOARD                               "),
    writeln("================================================================================"),
    writeln('|1. Jogos mais vendido'),
    writeln('|2. Jogos melhores avaliados'),
    writeln('|3. Jogos mais caros'),
    writeln('|4. Jogos mais baratos'),
    writeln('|5. Jogos por data de lancamento'),
    writeln('|6. Jogos por ordem alfabetica'),
    writeln('|7. Voltar para o menu'),
    writeln(''),
    write('Escolha uma opção: '),
    read_line_to_string(user_input, Opcao),
    writeln(''),
    (Opcao == "1" -> ((existeAlgumJogoVendido(Connection) -> limparTela, getJogosMaisVendidos(Connection, Jogos), printJogosIdNome("4", Jogos), menuAdmin);
    limparTela, writeln('Nenhuma venda foi realizada ainda!'), menuAdmin);
     Opcao == "2" -> limparTela, getJogosOrderByRatingAdm(Connection,Jogos), printJogosIdNome("6", Jogos), menuAdmin;
     Opcao == "3" -> limparTela, getJogosOrderByBiggestPriceAdm(Connection, Jogos), printJogosIdNome("2", Jogos), menuAdmin;
     Opcao == "4" -> limparTela, getJogosOrderByPriceAdm(Connection, Jogos), printJogosIdNome("2", Jogos), menuAdmin;
     Opcao == "5" -> limparTela, getJogosOrderByDateAdm(Connection, Jogos), printJogosIdNome("5", Jogos), menuAdmin;
     Opcao == "6" -> limparTela, getJogosOrderByNameAdm(Connection, Jogos), printJogosIdNome("1", Jogos), menuAdmin;
     Opcao == "7" -> limparTela, menuAdmin;
     limparTela, writeln('Opcao invalida, por favor, tente novamente'), dashboard).

