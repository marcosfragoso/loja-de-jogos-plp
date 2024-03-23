{-# LANGUAGE OverloadedStrings #-}
module Controller.User where
import Database.PostgreSQL.Simple
import Data.Time.Format
import Data.Time.Clock
import Data.Int (Int64)
import Data.Maybe (listToMaybe)


import Controller.Util
import Controller.Cliente (menuCliente)

menuInicial::Connection -> IO()
menuInicial conn = do
    putStrLn "============================================================"
    putStrLn "MENU:"
    putStrLn ""
    putStrLn "1 - Login"
    putStrLn "2 - Criar uma conta"
    putStrLn "3 - Sair"
    putStrLn ""
    putStrLn "============================================================"
    putStrLn "Selecione uma opção > "

    opcao <- getLine

    putStrLn "============================================================"

    case opcao of
        "1" -> do
            putStrLn "Preencha seus dados abaixo:\n"
            login conn
        "2" -> do
            putStrLn "Preencha seus dados abaixo:\n"
            criarConta conn
        "3" -> return ()
        _ -> do
            putStrLn "Opção inválida! Por favor, tente novamente."
            menuInicial conn

login::Connection->IO()
login conn = do
    putStrLn "Digite o e-mail:"
    email <- getLine
    putStrLn "Digite a senha:"
    senha <- getLine
    putStrLn "============================================================"
    if (Prelude.null email || Prelude.null senha) then do
        putStrLn "Nenhum campo pode estar vazio!"
        putStrLn "Preencha novamente os seus dados:"
        login conn
    else do
        userID <- getUserEmailSenha conn email senha
        case userID of
            Just (id, tipo) -> do
                if (tipo == "Padrão") then do
                    -- Transição para a tela do cliente após o login
                    limparTela
                    menuCliente conn id
                else do
                    putStrLn "Administrador" -- Transição para as telas do Administrador
            Nothing -> do
                putStrLn "Email ou senha incorretos! Tente novamente.\n"
                login conn

getUserEmailSenha::Connection->String->String->IO (Maybe (Int64, String))
getUserEmailSenha conn email senha = do
    user <- query conn "SELECT user_id, user_tipo FROM usuario WHERE user_email = ? AND user_senha = ?" (email, senha)
    return $ listToMaybe user


criarConta::Connection->IO()
criarConta conn = do
    putStrLn "Nickname:"
    nickname <- getLine
    putStrLn "Nome:"
    nome <- getLine
    putStrLn "E-mail:"
    email <- getLine
    putStrLn "Senha:"
    senha <- getLine
    putStrLn "Confirmar Senha:"
    confirmarSenha <- getLine
    putStrLn "============================================================"
    if (Prelude.null nickname || Prelude.null nome || Prelude.null email || Prelude.null senha || Prelude.null confirmarSenha) then do
        putStrLn "Nenhum campo pode estar vazio!"
        putStrLn "Preencha novamente os seus dados:"
        criarConta conn
    else if (senha /= confirmarSenha) then do
        putStrLn "Senhas digitadas não são iguais!"
        putStrLn "Preencha novamente os seus dados:"
        criarConta conn
    else do
        nicknameExistente <- checarNicknameExistente conn nickname
        if (nicknameExistente) then do
            putStrLn "Nickname já exite!"
            putStrLn "Preencha novamente utilizando outro nickname."
            criarConta conn
        else do
            emailExistente <- checarEmailExistente conn email
            if (emailExistente) then do
                putStrLn "Email já cadastrado!"
                putStrLn "Preencha novamente utilizando outro endereço de email."
                criarConta conn
            else
                cadastrarConta conn nickname nome email senha
    menuInicial conn

cadastrarConta::Connection->String->String->String->String->IO()
cadastrarConta conn nickname nome email senha = do
    -- Obter a hora atual
    currentTime <- getCurrentTime
    -- Formatar a data atual (YYYY-MM-DD)
    let dataFormatada = formatTime defaultTimeLocale "%Y-%m-%d" currentTime
    let q = "INSERT INTO usuario\
                    \(user_nickname, \
                    \user_nome, \
                    \user_email, \
                    \user_senha, \
                    \user_tipo, \
                    \user_date, \
                    \user_saldo) \
                    \values (?, ?, ?, ?, ?, ?, ?)"
    execute_ conn "BEGIN"
    _ <- execute conn q (nickname, nome, email, senha, "Padrão"::String, dataFormatada, 0::Float)
    execute_ conn "COMMIT"
    putStrLn "Cadastro realizado com sucesso!"
    return()




    

