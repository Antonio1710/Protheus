#Include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SocketTag ºAutor  ³Everson             º Data ³  05/09/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Leitura de Tag no conversor serial.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SocketTag(nPort,cIp) // U_SocketTag(8881,"10.6.3.230")

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Define Variaveis                                             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea     := GetArea()
    Local oObj      := TSocketClient():New()
    Local nX        := 1
    Local nTEspC    := 10000        //Criar MV.
    Local nNumT     := 3            //Criar MV.
    Local nResp     := -1           //Criar MV.
    Local nSleep    := 2000         //Criar MV.
    Local nTEspR    := 10000        //Criar MV.
    Local cBuffer   := ""           //Criar MV.
    Local cErro     := ""
 
    //Tenta conectar.
    For nX := 1 To nNumT        
    
        //
        FWMsgRun(, {|oSay| nResp := oObj:Connect( nPort,cIp, nTEspC ) }, "Aguarde", "Estabelecendo conexão...")

        //Se conectou sai o For.
        If(nResp == 0 )
            exit

        Else
            Conout( DToC(Date()) + " " + Time() + " --> Tentativa de Conexão porta: " + cValToChar(nPort) + " IP: " + cValToChar(cIp) + " " + StrZero(nX,3) )
            Sleep(nSleep)
            continue

        EndIf

    Next nX          
     
    // Verifica se a conexão foi bem sucedida.
    If( ! oObj:IsConnected() )
        Conout( DToC(Date()) + " " + Time() + " --> Falha na conexão ")
        MsgStop("Não foi possível estabelecer conexão.","Função ")
        RestArea(aArea)
        Return Nil 

    Else 
        Conout( DToC(Date()) + " " + Time() + " --> Conexão OK ")

    EndIf 
 
    // Teste de recebimento do socket.
    If( ! oObj:IsConnected() )
        Conout( DToC(Date()) + " " + Time() + " --> Falha na conexão ")
        RestArea(aArea)
        Return Nil
    
    Else 
        Conout( DToC(Date()) + " " + Time() + " --> Conectado ")

    EndIf
    
    //
    FWMsgRun(, {|oSay| nResp := oObj:Receive( @cBuffer, nTEspR ) }, "Aguarde", "Efetuando leitura...")
    Conout( DToC(Date()) + " " + Time() + " --> nResp " + cValToChar(nResp) )
    If ( nResp >= 0 )
        Conout( DToC(Date()) + " " + Time() + " --> cBuffer " + cValToChar(cBuffer) )

    ElseIf nResp < 0
        oObj:GetError(@cErro)
        Conout( DToC(Date()) + " " + Time() + " --> Erro " + cValToChar(cErro) )
        MsgStop("Ocorreu erro na leitura dos dados." + Chr(13) + Chr(10) + cValToChar(cErro) ,"Função ")

    EndIf 
 
    //Fecha conexão.
    oObj:CloseConnection()
    Conout( DToC(Date()) + " " + Time() +  " --> Conexão fechada" )

    //
    RestArea(aArea)

Return cBuffer