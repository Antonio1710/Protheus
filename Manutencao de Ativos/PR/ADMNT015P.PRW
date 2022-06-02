#Include "Protheus.ch"
#INCLUDE "MNTA400.ch"
#INCLUDE "MNTA280.ch"
#INCLUDE 'FWMVCDEF.CH'
#Include "Restful.ch"
#Include "Topconn.ch"

Static cFormatRet := "application/json"
/*/{Protheus.doc} ADMNT015P
    Serviço Rest para utilização com o App de manuteção de ativos Ad'oro.
    @type  Function
    @author Everson
    @since 28/01/2021
    @version 01
    @history Everson, 18/05/2021, Chamado 7936. Tratamento para apontamento das horas no fechamento da OS, adicionado  login.
    @history Everson, 07/07/2021, Chamado 16369. Tratamento para apontamento de fechamento na SS.
    @history Everson, 29/07/2021, Chamado 17344. Tratamento para apontamento de horas maior que 24, no fechamento da OS.
    @history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    */
User Function ADMNT015P
Return Nil
WsRestFul manutencao Description "Serviço REST para controle de ordens de serviço de manutenção"

	WsMethod Post Description "Efetua login no sistema."  WsSyntax "/data/{resource}"
	WsMethod Get  Description "Obtém as ordens de serviço pendentes."  WsSyntax "/data/{resource}" //Não foi possível utilizar o ID para haver métodos repetidos.
	WsMethod Put  Description "Alteração de ordem de serviço." WsSyntax "/data/{resource}/{id}"

End WsRestFul
/*/{Protheus.doc} Post
    Método post para validação de acesso.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
WsMethod Post WsService manutencao

    //Variáveis.
    Local cBody 	    := Self:GetContent()
    Local aParametros	:= Self:aURLParms
    Local cRecurso      := "" 
    Local cJsonResp     := ""
    Local oJson         := Nil
    Local xRet          := Nil
    Local cUser         := ""
    Local cSenha        := ""
    Local cEmpresa      := ""
    Local cFil          := ""

    //
    Self:SetContentType(cFormatRet)

    //
    If Len(aParametros) <> 2
        Conout( DToC(Date()) + " " + Time() + " - ADMNT015P - Dados inválidos [aParametros]")
        SetRestFault(400,EncodeUTF8("Dados inválidos."),.T.)
        Return .F.

    EndIf

    //
    If Empty(cBody)
        Conout( DToC(Date()) + " " + Time() + " - ADMNT015P - Dados inválidos [cBody]")
        SetRestFault(400,EncodeUTF8("Dados inválidos."),.T.)
        Return .F.

    EndIf

    //
    oJson := JsonObject():New()

    //
    xRet := oJson:FromJson(cBody)
    
    //
    If ValType(xRet) == "C"
        Conout( DToC(Date()) + " " + Time() + " - ADMNT015P - Falha ao converter a string json para objeto json")
        SetRestFault(400,EncodeUTF8("Falha ao converter a string json para objeto json."),.T.)
        FreeObj(oJson)
        oJson := Nil
        Return .F.

    EndIf

    //
    cRecurso:= Alltrim(aParametros[2])
    
    //
    cUser   := oJson["user"]
    cSenha  := oJson["password"]
    cEmpresa:= oJson["empresa"]
    cFil    := oJson["filial"]

    //
    If cRecurso == "login"
        If ! procLogin(cEmpresa, cFil, cUser, cSenha, @cJsonResp, cBody)
            SetRestFault(401,EncodeUTF8("Usuário não autorizado"),.T.)
            Return .F.

        EndIf
        
    Else
        SetRestFault(404,EncodeUTF8("Recurso " + cRecurso + " não encontrado."),.T.)
        Return .F.

    EndIf

    //
    FreeObj(oJson)
    oJson := Nil
    Self:SetResponse(cJsonResp)

Return .T.
/*/{Protheus.doc}
    Metódo Get retorna dados de OS, Funcionários e motivos de atraso.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
WsMethod Get WsService manutencao

    //Variáveis.
    //Variáveis.
    Local cEmpresa      := Alltrim(Self:GetHeader("Empresa"))
    Local cFil          := Alltrim(Self:GetHeader("Filial"))
    Local cAuth         := Alltrim(Self:GetHeader("Authorizationx")) //Everson, 31/08/2021, Chamado 7936.
    Local aCreden       := {}
    Local cUser         := ""
    Local cSenha        := ""
    Local cJsonResp     := ""
    Local aParametros	:= Self:aURLParms
    Local aFiltros      := Self:aQueryString
    Local nAux          := 1
    Local cFiltros      := ""
    Local cRecurso      := ""
    Local lRet          := .F.

    //
    Self:SetContentType(cFormatRet)

    //
    If Len(aParametros) <> 2
        SetRestFault(400,EncodeUTF8("Dados inválidos."),.T.)
        Return .F.

    EndIf

    //
    cRecurso:= Alltrim(aParametros[2])
    
    //
    If cRecurso <> "companies"

        //
        If Empty(cEmpresa) .Or. Empty(cFil) .Or. Empty(cAuth)
            SetRestFault(400,EncodeUTF8("Dados inválidos."),.T.)
            Return .F.

        EndIf

        //
        aCreden := Separa(Decode64(Separa(cAuth, " ",.T.)[2]),":")
        cUser   := aCreden[1]
        cSenha  := aCreden[2]

        //
        vldUser(@lRet, cUser, cSenha, cEmpresa, cFil)

        //
        If ! lRet
            SetRestFault(401,EncodeUTF8("Usuário não autorizado"),.T.)
            Return .F.

        EndIf

    Else
        cEmpresa := cEmpAnt
        cFil := cFilAnt

    EndIf

    //
    For nAux := 1 To Len(aFiltros)
        cFiltros += aFiltros[nAux][2]

    Next nAux

    //
    cJsonResp := StartJob("U_ADMNT15A",GetEnvServer(),.T., cEmpresa, cFil, cRecurso, cUser, cFiltros)
    If Empty(cJsonResp)
        SetRestFault(404,EncodeUTF8("Dados não encontrados."),.T.)
        Return .F.

    EndIf

    //
    Self:SetResponse(cJsonResp)

Return .T.
/*/{Protheus.doc}
    Metódo Put para encerramento de OS.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
WsMethod Put WsService manutencao

    //Variáveis.
    Local cEmpresa      := Alltrim(Self:GetHeader("Empresa"))
    Local cFil          := Alltrim(Self:GetHeader("Filial"))
    Local cAuth         := Alltrim(Self:GetHeader("Authorization"))
    Local cRecurso      := ""
    Local cBody 	    := Self:GetContent()
    Local aCreden       := {}
    Local cUser         := ""
    Local cSenha        := ""
    Local lRet          := .F.
    Local aParametros	:= Self:aURLParms
    Local cId           := ""
    Local aErro         := {}
    Local cJsonResp     := "[]"

    //
    Self:SetContentType(cFormatRet)

    //
    If Empty(cEmpresa) .Or. Empty(cFil) .Or. Empty(cAuth) .Or. Empty(cBody) .Or. Len(aParametros) <> 3
        SetRestFault(400,EncodeUTF8("Dados inválidos."),.T.)
        Return .F.

    EndIf

    //
    aCreden := Separa(Decode64(Separa(cAuth, " ")[2]),":")
    cUser   := aCreden[1]
    cSenha  := aCreden[2]
    cRecurso:= Alltrim(aParametros[2])
    cId     := Alltrim(aParametros[3])

    //
    vldUser(@lRet, cUser, cSenha, cEmpresa, cFil)

    //
    If ! lRet
        SetRestFault(401,EncodeUTF8("Usuário não autorizado"),.T.)
        Return .F.

    EndIf

    //
    If cRecurso == "serviceOrders"
        aErro := StartJob("U_ADMNT15B", GetEnvServer(),.T., cEmpresa, cFil, cId, cBody, cUser)

    ElseIf cRecurso == "password"
        aErro := StartJob("U_ADMNT15C", GetEnvServer(),.T., cEmpresa, cFil, cId, cBody, cUser)

    ElseIf cRecurso == "timeEntry"
        aErro := StartJob("U_ADMNT15D", GetEnvServer(),.T., cEmpresa, cFil, cId, cBody, cUser)

    ElseIf cRecurso == "assingServiceOrder"
        aErro := StartJob("U_ADMNT15E", GetEnvServer(),.T., cEmpresa, cFil, cId, cBody, cUser)

    Else 
        SetRestFault(404,EncodeUTF8("Recurso " + cRecurso + " não encontrado."),.T.)
        Return .F.

    EndIf

    //
    If Len(aErro) > 0
        SetRestFault(aErro[1][1], EncodeUTF8(aErro[1][2]), .T.)
        Return .F.

    EndIf

    //
    Self:SetResponse(cJsonResp)

Return .T.
/*/{Protheus.doc} procLogin
    Processa requisição de login.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function procLogin(cEmpresa, cFil, cUser, cSenha, cJsonResp, cBody)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    //
    logZBE(cUser,cBody,"login")

    //
    cJsonResp := vldUser(@lRet, cUser, cSenha, cEmpresa, cFil, .T.)

    //
    If ! lRet
        Return .F.

    EndIf

    //
    Conout(DToC(Date()) + " " + Time() + " - ADMINT015P - [Login] " + cJsonResp)

    //
    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADMNT15A
    Processa solicitações de dados.
    @type  User Function
    @author Everson
    @since 27/01/2021
    @version 01
    /*/
User Function ADMNT15A(cEmpresa, cFil, cRecurso, cUser, cFiltros)

    //Variáveis.
    Local aArea := GetArea()

    Default cFiltros := ""

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

        //
        lVisT := cUser $ Alltrim(cValToChar(GetMv("MV_#GEMAT",,"")))

        //
        logZBE(cUser,"","GET " + cRecurso)
    
        //
        If cRecurso == "companies"
            cJsonResp := Empresas()

        ElseIf cRecurso == "serviceOrders" .Or. cRecurso == "serviceOrdersFiltered" 
            cJsonResp := OsData(cUser, lVisT, cFiltros)

        ElseIf cRecurso == "serviceOrdersPending" 
            cJsonResp := OsData(cUser, lVisT, cFiltros, 2)

        ElseIf cRecurso == "employees"
            cJsonResp := FuncData()

        ElseIf cRecurso == "delayReasons"
            cJsonResp := MotAtrData()

        ElseIf cRecurso == "services"
            cJsonResp := Services()

        ElseIf cRecurso == "tasks"
            cJsonResp := Tasks()

        Else
            Return cJsonResp

        EndIf

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return cJsonResp
/*/{Protheus.doc} ADMNT15B
    Função processa o retorno da OS.
    @type  User Function
    @author Everson
    @since 26/01/2021
    @version 01
    /*/
User Function ADMNT15B(cEmpresa, cFil, cOS, cBody, cUser)

    //Variáveis.
    Local aArea     := GetArea()
    Local aErro     := {}
    Local oJson     := JsonObject():New()
    Local xRet      := Nil
    Local cErro     := ""

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

    //
    xRet := oJson:FromJson(cBody)
    
    //
    If ValType(xRet) == "C"
        Aadd(aErro,{400,"Falha ao converter a string json para objeto json."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    //
    DbSelectArea("STJ")
    STJ->(DbSetOrder(1))
    STJ->(DbGoTop())
    If ! STJ->(DbSeek( FWxFilial("STJ") + cOs ))
        Aadd(aErro,{404,"Ordem de serviço " + cOs + " não localizada."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    //OS já encerrada.
    If STJ->TJ_TERMINO == "S"
        Aadd(aErro,{400,"Ordem de serviço " + cOs + " já finalizada. Recarregue os dados do aplicativo."})
        RestArea(aArea)
        Return aErro

    EndIf

    //
    logZBE(cUser,cBody,"Encerramento " + cOS)

    //
    Begin Transaction

        //Atualização das tarefas.
        cErro := updtEtp(cFil, cOS, cUser, oJson)
        If ! Empty(Alltrim(cErro))
            DisarmTransaction()
            Aadd(aErro,{400,cErro})
            FreeObj(oJson)
            oJson := Nil
            RestArea(aArea)
            Return aErro

        EndIf

        //Encerra OS.
        cErro := encerOS(cFil, cOS, cUser, oJson)
        If ! Empty(Alltrim(cErro))
            DisarmTransaction()
            Aadd(aErro,{400,cErro})
            FreeObj(oJson)
            oJson := Nil
            RestArea(aArea)
            Return aErro

        EndIf

        //Encerra SS.
        If ! Empty(STJ->TJ_SOLICI)

            //
            cErro := encerSS(STJ->TJ_ORDEM)
            If ! Empty(Alltrim(cErro))
                DisarmTransaction()
                Aadd(aErro,{400,cErro})
                FreeObj(oJson)
                oJson := Nil
                RestArea(aArea)
                Return aErro

            EndIf

        EndIf
        
    End Transaction

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return aErro
/*/{Protheus.doc} ADMNT15C
    Altera senha.
    @type  User Function
    @author Everson
    @since 18/05/2021
    @version 01
    /*/
User Function ADMNT15C(cEmpresa, cFil, cOS, cBody, cUser)

    //Variáveis.
    Local aArea     := GetArea()
    Local aErro     := {}
    Local oJson     := JsonObject():New()
    Local xRet      := Nil
    Local cNvSenha   := ""

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

    //
    xRet := oJson:FromJson(cBody)
    
    //
    If ValType(xRet) == "C"
        Aadd(aErro,{400,"Falha ao converter a string json para objeto json."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    //
    cNvSenha := Alltrim(cValToChar(oJson["newPassword"]))
    If Empty(cNvSenha)
        Aadd(aErro,{401,"Senha inválida."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    //
    DbSelectArea("ST1")
    ST1->(DbSetOrder(1))
    ST1->(DbGoTop())
    If ! ST1->(DbSeek( FWxFilial("ST1") + cUser ))
        Aadd(aErro,{404,"Usuário " + cUser + " não localizado."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    Else
        RecLock("ST1",.F.)
            ST1->T1_SENHA := cNvSenha
        ST1->(MsUnlock())

    EndIf

    //
    logZBE(cUser,cBody,"Alteração de senha " + cUser)

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return aErro
/*/{Protheus.doc} ADMNT15D
    Apontamento de horas.
    @type  User Function
    @author Everson
    @since 20/04/2021
    @version 01
    /*/
User Function ADMNT15D(cEmpresa, cFil, cId, cBody, cUser)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local aErro     := {}
    Local oJson     := JsonObject():New()
    Local xRet      := Nil
    Local cOs       := ""

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

    //
    xRet := oJson:FromJson(cBody)
    
    //
    If ValType(xRet) == "C"
        Aadd(aErro,{400,"Falha ao converter a string json para objeto json."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    cOs := oJson["OS"]

    //
    DbSelectArea("STJ")
    STJ->(DbSetOrder(1))
    STJ->(DbGoTop())
    If ! STJ->(DbSeek( FWxFilial("STJ") + cOs ))
        Aadd(aErro,{404,"Ordem de serviço " + cOs + " não localizada."})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return aErro

    EndIf

    //OS já encerrada.
    If STJ->TJ_TERMINO == "S"
        Aadd(aErro,{400,"Ordem de serviço " + cOs + " já finalizada. Recarregue os dados do aplicativo."})
        RestArea(aArea)
        Return aErro

    EndIf

    //
    logZBE(cUser,cBody,"Apontamento de mão de obra " + cOS)

    //
    Begin Transaction

        //Lançamento de mão de obra reportda.
        cErro := lancaIns(cFil, cOS, cUser, oJson)
        If ! Empty(Alltrim(cErro))
            DisarmTransaction()
            Aadd(aErro,{400,cErro})
            FreeObj(oJson)
            oJson := Nil
            RestArea(aArea)
            Return aErro

        EndIf 

    End Transaction

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return aErro
/*/{Protheus.doc} ADMNT15E
    Lançamento de insumo previsto - mão de obra.
    @type  Static Function
    @author Everson
    @since 24/02/2021
    @version 01
    /*/
User Function ADMNT15E(cEmpresa, cFil, cId, cBody, cUser)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local aErro     := {}
    Local oJson     := JsonObject():New()
    Local xRet      := Nil
    Local cOs       := ""
	Local lSEQTAR   := Nil
	Local nCost     := 0
    Local aVDataHora:= {}
    Local cHoras    := ""
    Local cDefUnity := ""
    Local cNGUNIDT  := ""
    Local dDtIni    := Nil
    Local cHrIni    := Nil
    Local cTpReg    := ""
    Local cUM       := ""
    Local cSeqIns   := ""

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

        //
        // If ADMNT15F(cUser) <> "S"
        //     Aadd(aErro,{401,"Usuário não autorizado."})
        //     RestArea(aArea)
        //     Return aErro

        // EndIf

        lSEQTAR   := NGCADICBASE("TL_SEQTARE","A","STL",.F.)
        cDefUnity := SuperGetMV("MV_NGUNIDT",.F.,"S")
        cNGUNIDT  := AllTrim(GetMv("MV_NGUNIDT"))

        //
        xRet := oJson:FromJson(cBody)
        
        //
        If ValType(xRet) == "C"
            Aadd(aErro,{400,"Falha ao converter a string json para objeto json."})
            FreeObj(oJson)
            oJson := Nil
            RestArea(aArea)
            Return aErro

        EndIf

        cOs := oJson["so"]

        //
        logZBE(cUser,cBody,"Atribuição de executante - OS " + cOS)

        //
        DbSelectArea("STJ")
        STJ->(DbSetOrder(1))
        STJ->(DbGoTop())
        If ! STJ->(DbSeek( FWxFilial("STJ") + cOs ))
            Aadd(aErro,{404,"Ordem de serviço " + cOs + " não localizada."})
            FreeObj(oJson)
            oJson := Nil
            RestArea(aArea)
            Return aErro

        EndIf

        //OS já encerrada.
        If STJ->TJ_TERMINO == "S"
            Aadd(aErro,{400,"Ordem de serviço " + cOs + " já finalizada. Recarregue os dados do aplicativo."})
            RestArea(aArea)
            Return aErro

        EndIf

        cUser  := oJson["user"]
        cHoras := oJson["prevHour"]
        dDtIni := SToD(oJson["dtIni"])
        cHrIni := oJson["hrIni"]
        cTarefa:= oJson["task"]
        cTpReg := oJson["regType"]
        cUM    := oJson["um"]

        cHoras := hrPVal(cHoras, ":")
        cHoras := If( cDefUnity <> "D", NGRHODSEXN(cHoras,"D"), cHoras )

        nCost := NGCALCUSTI( cUser, cTpReg, cHoras,, cNGUNIDT )

        aVDataHora := NGDTHORFIM( STJ->TJ_DTMPINI, STJ->TJ_HOMPINI, cHoras )

        DbSelectArea("STL")
        STL->(DbSetOrder(1))
        If STL->(DbSeek( FWxFilial("STL") + STJ->TJ_ORDEM + STJ->TJ_PLANO ))

            While ! STL->(Eof()) .And. FWxFilial("STL") == STL->TL_FILIAL .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

                If Alltrim(cValToChar(STL->TL_TIPOREG)) == "M" .And. Alltrim(cValToChar(STL->TL_CODIGO)) == Alltrim(cValToChar(cUser)) .And. Alltrim(cValToChar(STL->TL_SEQRELA)) == "0"
                    RecLock("STL",.F.)
                        DbDelete()
                    STL->(MsUnLock())
                EndIf

                STL->(DbSkip())

            End

        EndIf

        cSeqIns := seqInsNR(cOs)

        //
        RecLock("STL",.T.)
            STL->TL_FILIAL  := FWxFilial("STL")
            STL->TL_ORDEM   := STJ->TJ_ORDEM
            STL->TL_PLANO   := STJ->TJ_PLANO
            STL->TL_TAREFA  := cTarefa
            STL->TL_TIPOREG := cTpReg
            STL->TL_CODIGO  := cUser
            STL->TL_SEQRELA := "0  "
        	If lSEQTAR
        	    STL->TL_SEQTARE := cSeqIns
        	EndIf
            STL->TL_DTINICI := STJ->TJ_DTMPINI
            STL->TL_HOINICI := STJ->TJ_HOMPINI
            STL->TL_DTFIM   := aVDataHora[1]
            STL->TL_HOFIM   := aVDataHora[2]

            STL->TL_QUANREC := 0
            STL->TL_QUANTID := cHoras
            STL->TL_UNIDADE := cUM
            STL->TL_DESTINO := ""
            STL->TL_LOCAL   := "02"

            STL->TL_TIPOHOR := cNGUNIDT
            STL->TL_USACALE := "N"
            STL->TL_CUSTO   := nCost
            STL->TL_FORNEC  := ""
            STL->TL_LOJA    := ""
            STL->TL_NUMSA   := ""
            STL->TL_ITEMSA  := ""
            STL->TL_OBSERVA := ""

        STL->(MsUnlock())

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return aErro
/*/{Protheus.doc} seqInsNR
    Sequência de insumos previstos.
    @type  Static Function
    @author Everson
    @since 26/04/2021
    @version 01
    /*/
Static Function seqInsNR(cOs)

    //Variáveis.
    Local aArea  := GetArea()
    Local cQuery := ""
    Local cSeq   := ""

    //
    cQuery += " SELECT  " 
    cQuery += " RIGHT('000' + CAST(CAST(ISNULL(MAX(TL_SEQTARE),0) AS NUMERIC) + 1 AS VARCHAR),3) AS TL_SEQTARE " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("STL") + " (NOLOCK) AS STL " 
    cQuery += " WHERE " 
    cQuery += " TL_FILIAL = '" + FWxFilial("STL") + "' " 
    cQuery += " AND TL_ORDEM = '" + cOs + "' " 
    cQuery += " AND TL_SEQRELA = '0' " 
    cQuery += " AND STL.D_E_L_E_T_ = '' " 

    //
    If Select("D_SEQINS") > 0
        D_SEQINS->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_SEQINS"
    DbSelectArea("D_SEQINS")
    D_SEQINS->(DbGoTop())
        cSeq := D_SEQINS->TL_SEQTARE
    D_SEQINS->(DbCloseArea())

    //
    RestArea(aArea)

Return cSeq
/*/{Protheus.doc} lancaIns
    Função faz o lançamento de insumos.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function lancaIns(cFil, cOS, cUser, oJson)

    //Variáveis.
    Local aArea     := GetArea()
    Local cDefUnity := SuperGetMV("MV_NGUNIDT",.F.,"S")
    Local cHrTotal  := oJson["hrtot"]
    Local cTipOS    := oJson["OSType"]
    Local cCodFun   := oJson["user"]
    Local cFunc     := oJson["userName"]
    Local cDtIni    := oJson["dtIni"]
    Local cHrIni    := oJson["hrIni"]
    Local cDtFim    := oJson["dtFim"]
    Local cHrFim    := oJson["hrFim"]
    Local nQtdHr    := hrPVal(cHrTotal, ":")
    Local cTarefa   := oJson["tarefa"]
    Local cLocal    := ""
    Local cErro     := ""

    //
    Conout(DToC(Date()) + " " + Time() + " - ADMINT015P [Início lançamento de mão de obra - lancaIns]")

    //
    If Empty(cTarefa)
        cErro += 'Lançamento de Mão de Obra | Tarefa não informada.'
        RestArea(aArea)
        Return cErro

    EndIf

    //
    nQtdHr := If( cDefUnity <> "D", NGRHODSEXN(nQtdHr,"D"), nQtdHr )

    //Valida se há conflito de horários nos insumos de mão de obra.
    If ! NGVALDATIN(cCodFun,STJ->TJ_ORDEM,STJ->TJ_PLANO,SToD(cDtIni),cHrIni,SToD(cDtFim),cHrFim,"M",,"STL",,)[1]
        RestArea(aArea)
        Return "Conflito de horários no insumo de mão de obra do funcionário " + cFunc

    EndIf
    
    //
    If ! NGRETINS(   STJ->TJ_ORDEM,; // PORDEM
                STJ->TJ_PLANO,;         // PPLANO
                cTipOS,;                // PTIPO
                ,;                      // PCODBEM
                ,;                      // PSERVICO
                ,;				        // PSEQ
                cTarefa,;    // PTAREFA
                "M",;                   // PTIPOINS
                cCodFun,;               // PCODIGO
                nQtdHr,;                // PQUANTID
                "H",;                   // PUNIDADE
                ,;                      // PDESTINO
                "Insumo Realizado.",;   //PDESCRIC
                SToD(cDtIni),;          // PDATAINI
                cHrIni,;                // PHORAINI
                "F",;   //PGERAFES
                cLocal,;      // PLOCAL
                ,;      //PLOTEC
                ,;      //PNUMLOTE
                ,;      //PDTVALID 23
                ,;      // PLOCALIZ
                ,;      //PERCMDOE
                "N",;                   // PCALEND
                "N",;                   //PGARANT
                ,;                      // PLOCAPL
                ,;                      //PQTDGAR
                ,;                      // PUNIGAR
                ,;                      // PCONGAR
                .T.,;                   //PLEST
                @cErro,)                //cErro

        //
        cErro += "Lançamento de Mão de Obra | " + Alltrim(cValToChar(cErro))

        //
        RestArea(aArea)
        Return cErro

    Else

        //
        RecLock("STL",.F.)
            STL->TL_LOCAL := "02"
        STL->(MsUnLock())

        //Gera o custo.
        U_NG400INS()

    EndIf

    //
    RestArea(aArea)

Return cErro
/*/{Protheus.doc} hrPVal
    Função convert hora para valor.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function hrPVal(cHora, cSep)

    //Variáveis.
    Local aArea   := GetArea()
    Local nAux    := 0
    Local cMin    := ""
    Local nValor  := 0
    Local nPosSep := 0

    Default cHora := ""
    Default cSep  := ":"

    //
    If !Empty(cHora)
        nPosSep := RAt(cSep, cHora)
        nAux    := Val(SubStr(cHora, nPosSep+1, 2))
        nAux    := Int(Round((nAux*100)/60, 0))
        cMin    := Iif(nAux > 10, cValToChar(nAux), "0"+cValToChar(nAux))
        nValor  := Val(SubStr(cHora, 1, nPosSep-1)+"."+cMin)
    EndIf

    //
    RestArea(aArea)

Return nValor
/*/{Protheus.doc} valPHrF
    Função convert valor para hora.
    @type  Static Function
    @author Everson
    @since 07/07/2021
    @version 01
    /*/
Static Function valPHrF(cVal, cSep)

    //Variáveis.
    Local aArea   := GetArea()
    Local nAuxH   := 0
    Local nAuxM   := 0
    Local cMin    := ""
    Local cHora   := ""
    Local nPosSep := 0

    Default cVal := ""
    Default cSep := "."

    //
    cVal := Alltrim(cValToChar(cVal))

    //
    If !Empty(cVal)

        nPosSep := RAt(cSep, cVal)
        if nPosSep > 0
            nAuxH   := Right("0000" + Left(cVal, nPosSep-1),4)
            nAuxM   := Int(Round(Val(Substr(cVal, nPosSep+1, Len(cVal)))*0.60,0))
            cMin    := Iif(nAuxM >= 10, cValToChar(nAuxM), "0" + cValToChar(nAuxM))
            cHora   := nAuxH + ":" + cMin + ":00"

        Else 
            //0000:30:00
            cHora := Right("00000" + cVal + ":00:00",10)

        EndIf

    EndIf

    //
    RestArea(aArea)

Return cHora
/*/{Protheus.doc} lancaMtr
    Função lança motivo de atraso.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function lancaMtr(cFil, cOS, cUser, oJson)

    //Variáveis.
    Local aArea     := GetArea()
    Local cErro     := ""
    Local nAux      := 1
    Local aNGGRAVA  := Nil
    Local aMotAtrs  := oJson["serviceOrder"]["motivosDeAtrasos"]["dados"]
    Local dDtIni    := oJson["serviceOrder"]["header"]["inicio"]["data"]
    Local cHrIni    := oJson["serviceOrder"]["header"]["inicio"]["hora"]
    Local dDtFim    := oJson["serviceOrder"]["header"]["fim"]["data"]
    Local cHrFim    := oJson["serviceOrder"]["header"]["fim"]["hora"]
    Local cCod      := ""

    //
    If Len(aMotAtrs) <= 0
        RestArea(aArea)
        Return cErro

    EndIf
    
    //
    For nAux := 1 To Len(aMotAtrs)

        //
        cCod   := aMotAtrs[nAux]["codigo"]

        //
        aNGGRAVA := NGCKINTDAT(cOS, cCod, SToD(dDtIni), cHrIni, SToD(dDtFim), cHrFim,.T.)
        
        //
        If aNGGRAVA[1]
            RecLock("TPL",.T.)
                TPL->TPL_FILIAL:= FWxFilial("TPL")
                TPL->TPL_ORDEM := cOS
                TPL->TPL_DTINIC:= SToD(dDtIni)
                TPL->TPL_DTFIM := SToD(dDtFim)
                TPL->TPL_HOINIC:= cHrIni
                TPL->TPL_HOFIM := cHrFim
                TPL->TPL_CODMOT:= cCod
            TPL->(MsUnlock())

        Else
            RestArea(aArea)
            Return ' Motivo de atraso | ' + Alltrim(cValToChar(aNGGRAVA[2]))

        EndIf 

    Next nAux

    //
    RestArea(aArea)

Return cErro
/*/{Protheus.doc} updtEtp
    Função realiza a atualização das etapas.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function updtEtp(cFil, cOS, cUser, oJson)

    //Variáveis.
    Local aArea     := GetArea()
    Local cErro     := ""
    Local aEtap     := oJson["serviceOrder"]["etaPasPrevRep"]["dados"]
    Local nAux      := 1 
    Local cMarca    := ""
    Local cPlan     := ""
    Local aEtapas   := {}
    Local cResp     := ""

    //
    If Len(aEtap) <= 0
        RestArea(aArea)
        Return cErro

    EndIf

    //
    DbSelectArea("STQ")
	DbSetOrder(1)
    STQ->(DbGoTop())

    //
    DbSelectArea("TPC")
    TPC->(DbSetOrder(1))
    
    //
    For nAux := 1 To Len(aEtap)

        //
        If STQ->(DbSeek(FWxFilial("STQ") + aEtap[nAux]["ordem"] + aEtap[nAux]["plano"] + aEtap[nAux]["tarefa"]["codigo"] + aEtap[nAux]["etapa"] + aEtap[nAux]["seqTarefa"] ))

            //
            cPlan := aEtap[nAux]["plano"]
            cMarca:= GetMark()
            cResp := Alltrim(cValToChar(Posicione("TPC",1,FWxFilial("TPC") + aEtap[nAux]["etapa"] + aEtap[nAux]["opcao"], "TPC_DESOPC")))

            //
            If Empty(cResp)
            
                //
                RecLock("STQ", .F.)
                    //STQ->TQ_OK := cMarca
                    STQ->TQ_CODFUNC := cUser
                    //STQ->TQ_OPCAO := aEtap[nAux]["opcao"]
                    STQ->TQ_OBSERVA := DecodeUTF8(aEtap[nAux]["resposta"])
                STQ->(MsUnlock())

            Else
                Aadd(aEtapas,{STQ->TQ_TAREFA,STQ->TQ_ETAPA,STQ->TQ_SEQETA,STQ->TQ_SEQTARE,cUser,cMarca, {aEtap[nAux]["opcao"], DecodeUTF8(aEtap[nAux]["resposta"])} })

            EndIf 

        EndIf

    Next nAux

    //
    If Len(aEtapas) > 0
        cErro := getSTQ(cOS, cPlan, aEtapas)

    EndIf 

    //
    RestArea(aArea)

Return cErro
/*/{Protheus.doc} getSTQ
    Função encerra OS.
    @type  Static Function
    @author Everson
    @since 13/04/2021
    @version 01
    /*/
Static Function getSTQ(cOrder, cPlan, aEtapas)

    //Variáveis.
	Local aArea     := GetArea()
	Local cError    := ""
	Local nI        := 1
    Local nX        := 1
    Local nY        := 1
	Local oStep     := Nil
	Local aOSGeradas:= {}
	Local aSSGeradas:= {}
	Local cTarefa   := ""
	Local cEtapa    := ""
	Local cSeqTare  := ""

	Local aAnswers  := {}
	Local nOperat   := 4
	Local aCols     := {}
	Local aExcluir  := {}
	Local aNoSTQ    := {}
	Local aInfoList := {}

	//------------------------------------
	// Exclusões de etapas
	//------------------------------------

	DbSelectArea("STQ")
	STQ->(DbSetOrder(1))
	If STQ->(DbSeek(xFilial("STQ") +  cOrder + cPlan))
		While ! STQ->(Eof()) .And. cOrder + cPlan == STQ->TQ_ORDEM + STQ->TQ_PLANO
			If aScan(aEtapas,{|x|Alltrim(x[1]) == Alltrim(STQ->TQ_TAREFA)  .And.;
								Alltrim(x[2]) == Alltrim(STQ->TQ_ETAPA )}) == 0
				aAdd(aExcluir,{STQ->TQ_ORDEM, STQ->TQ_PLANO, STQ->TQ_TAREFA, STQ->TQ_ETAPA, STQ->TQ_SEQTARE})
			EndIf
			STQ->(DbSkip())
		EndDo
	EndIf

	For nX := 1 to Len(aExcluir)

		oStep := MNTStep():New()
		oStep:setAsk(.F.)//Não apresenta mensagens condicionais (.F.)
		oStep:setOperation(5)//seta operação como 'excluir'
		oStep:Load({xFilial("STQ") + ;
					aExcluir[nX][1] + ;
					aExcluir[nX][2] + ;
					aExcluir[nX][3] + ;
					aExcluir[nX][4] + ;
					aExcluir[nX][5]})

		If oStep:valid()// Realiza as validações de Etapas
			oStep:delete()//Deleta a Etapa
		Else
			cError := "Operação excluir etapa :" + Space(1) +  aExcluir[nX][4] + Space(1)
			cError += "Erro :" + Space(1) + oStep:GetErrorList()[1]
			Exit
		EndIf

	Next nX

	If Empty(cError)

		//------------------------------------
		// Alterações e inclusões de etapas
		//------------------------------------
		For nI := 1 to Len(aEtapas)

			cTarefa := aEtapas[nI][1]
			cEtapa  := aEtapas[nI][2]
			cSeqEta := aEtapas[nI][3]
			cSeqTare:= aEtapas[nI][4]
			cCodFun := aEtapas[nI][5]
			cOk     := aEtapas[nI][6]
			aAnswers:= aEtapas[nI][7]

            //
			oStep := MNTStep():New()
			oStep:setAsk(.F.)//Não apresenta mensagens condicionais (.F.)
			oStep:setOperation(nOperat)//set

            oStep:Load({xFilial("STQ") + cOrder + cPlan + cTarefa + cEtapa + cSeqTare})

			oStep:setValue("TQ_FILIAL" , xFilial("STQ"))
			oStep:setValue("TQ_ORDEM"  , cOrder)
			oStep:setValue("TQ_PLANO"  , cPlan)
			oStep:setValue("TQ_TAREFA" , cTarefa)
			oStep:setValue("TQ_ETAPA"  , cEtapa)
			oStep:setValue("TQ_SEQETA" , cSeqEta)
			oStep:setValue("TQ_SEQTARE", cSeqTare)
			oStep:setValue("TQ_CODFUNC", cCodFun)
			oStep:setValue("TQ_OK"     , cOk)

			//-------------------------------------------------------
			//Carrega acols de acordo com respostas
			//-------------------------------------------------------
			aHeaderAux:= oStep:GetHeader("TPQ")
			aCols := fCargaAcols(cOrder, cPlan, cTarefa, cEtapa, aAnswers, aHeaderAux,nOperat)

			oStep:setCols("TPQ", aCols)

			aInfoList := {}

			If oStep:valid()// Realiza as validações de Etapas
				If oStep:upsert()//Realiza a gravação das Etapas

					//----------------------------------------
					//recupera ordens geradas pelas respostas
					//-----------------------------------------
					aAdd(aOSGeradas,aClone(oStep:getResultList()[1]))

					//----------------------------------------
					//recupera solicitações geradas pelas respostas
					//-----------------------------------------
					aAdd(aSSGeradas,aClone(oStep:getResultList()[2]))

				Else
					cError:= "Operação alterar/incluir etapa :" + Space(1) +  cEtapa + Space(1)
					cError+= "Erro :" + oStep:GetErrorList()[1]
					Exit

				EndIf
			Else

				//-----------------------------------------------
				//recupera informações das respostas não geradas
				//-----------------------------------------------
				aInfoList := oStep:getInfoList()
				If Len(aInfoList) > 0
					For nX := 1 to Len(aInfoList)
						aAdd(aNoSTQ, {cTarefa, cEtapa, aInfoList[nX]})
					Next nX
				Else
					cError:= "Operação alterar/incluir etapa :" + Space(1) +  cEtapa + Space(1)
					cError+= "Erro :" + oStep:GetErrorList()[1]
					Exit
				EndIf
                
			EndIf
		Next nI
	EndIf

    //
    If Len(aOSGeradas) > 0
        
        //
        DbSelectArea("STJ")
        STJ->(DbSetOrder(1))

        //
        For nY := 1 To Len(aOSGeradas)

            VarInfo('aOSGeradas',aOSGeradas)

            //
            If Len(aOSGeradas[nY]) > 0
                If STJ->(DbSeek( FWxFilial("STJ") + aOSGeradas[nY][1][4] ))
                    RecLock("STJ",.F.)
                        STJ->TJ_OBSERVA := STJ->TJ_OBSERVA + Chr(13) + Chr(10) + cValToChar(aAnswers[2])
                    STJ->(MsUnlock())

                EndIf

            EndIf

        Next nY

    EndIf

    //
    RestArea(aArea)

Return cError
/*/{Protheus.doc} fCargaAcols
    Função Carrega aCols.
    @type  Static Function
    @author Everson
    @since 14/04/2021
    @version 01
    /*/
Static Function fCargaAcols(cOrder, cPlan, cTarefa, cEtapa, aAnswers, aHeaderAux,nOperat)

    //Variáveis.
	Local aArea      := GetArea()
	Local aLinha     := BlankGetd(aHeaderAux)[1]
	Local aCols      := {}
	Local nPosFilial := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_FILIAL" })
	Local nPosOrdem  := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_ORDEM"  })
	Local nPosPlano  := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_PLANO"  })
	Local nPosTarefa := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_TAREFA" })
	Local nPosEtapa  := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_ETAPA"  })
	Local nPosOk     := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_OK"     })
	Local nPosOpcao  := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_OPCAO"  })
	Local nPosRespos := aScan( aHeaderAux , {|x| Alltrim(x[2]) == "TPQ_RESPOS" })
	Local cMarca  := GetMark()

    //
    aLinha[nPosFilial] := xFilial("TPQ")
    aLinha[nPosOrdem]  := cOrder
    aLinha[nPosPlano]  := cPlan
    aLinha[nPosTarefa] := cTarefa
    aLinha[nPosEtapa]  := cEtapa
    aLinha[nPosOk]     := cMarca
    aLinha[nPosOpcao]  := aAnswers[1]
    aLinha[nPosRespos] := aAnswers[2]

    aAdd(aCols,aClone(aLinha))

    //
	If nOperat > 3
		dbSelectArea("TPQ")
		dbSetOrder(1)
		If dbSeek(xFilial("TPQ") + cOrder + cPlan + cTarefa + cEtapa)

			While !Eof() .And. cOrder + cPlan + cTarefa + cEtapa == ;
				TPQ->TPQ_ORDEM + TPQ->TPQ_PLANO + TPQ->TPQ_TAREFA + TPQ->TPQ_ETAPA

				If aAnswers[1] == TPQ->TPQ_OPCAO
					aLinha[nPosFilial] := xFilial("TPQ")
					aLinha[nPosOrdem]  := cOrder
					aLinha[nPosPlano]  := cPlan
					aLinha[nPosTarefa] := cTarefa
					aLinha[nPosEtapa]  := cEtapa
					aLinha[nPosOpcao]  := TPQ->TPQ_OPCAO
					aTail(aLinha)      := .T. //deletada

					aAdd(aCols,aClone(aLinha))
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf

    //
    RestArea(aArea)

Return aCols
/*/{Protheus.doc} encerOS
    Função encerra OS.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function encerOS(cFil, cOS, cUser, oJson)

    //Variáveis.
    Local aArea  := GetArea()
    Local cPlan  := Alltrim(cValToChar(oJson["serviceOrder"]["plano"]))
    Local cObs   := DecodeUTF8(Alltrim(cValToChar(oJson["serviceOrder"]["obs"]["complemento"])))
    Local cNmUsr := retNmUsr(cUser)

    //Everson - 11/02/2021. Chamado 7936.
    Local dDtIni    := ""
    Local cHrIni    := ""
    Local dDtFim    := ""
    Local cHrFim    := ""
	Local cEquipment:= ""
    Local cQuery    := ""

	Private cNGERROR := ""

    //
    DbSelectArea("STJ")
	STJ->(DbSetOrder(1))
	If ! STJ->(DbSeek( FWxFilial( "STJ" ) + cOS + cPlan ))
        RestArea(aArea)
        Return "[encerOS] Ordem de serviço " + cOS + " não encontrada."

    EndIf

	//Verifica se obriga a resposta das etapas e executante
	If ! NGRESPETAEX(cOS,.F.)[1]
        RestArea(aArea)
        Return "Existe(m) etapa(s) sem resposta(s) e/ou sem o executante para a ordem de serviço: " + cOS + "."

    EndIf

    //Verifica insumos realizados.
    If ! verifyInput(STJ->TJ_ORDEM, STJ->TJ_PLANO)
        RestArea(aArea)
        Return "Existe(m) etapa(s) sem resposta(s) e/ou sem o executante para a ordem de serviço: " + cOS + "."

    EndIf

    //
    cEquipment := STJ->TJ_CODBEM

    //
    RecLock("STJ",.F.)

        If !Empty(cObs)
            STJ->TJ_OBSERVA = STJ->TJ_OBSERVA + Chr(13) + Chr(10) + cObs
            
        EndIf

        //STJ->TJ_IRREGU := cFault
        STJ->TJ_USUAFIM := Substr(cNmUsr,1,15)
        STJ->TJ_USUARIO := Substr(cNmUsr,1,15)

    STJ->(MsUnlock())

    //variáveis private utilizadas na função NGFinal
    vVETRE := {}
    lPRIMD := .T.
    
    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " MIN(TL_DTINICI+TL_HOINICI) AS INI, " 
    cQuery += " MAX(TL_DTFIM+TL_HOFIM) AS FIM " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("STL") + " (NOLOCK) AS STL " 
    cQuery += " WHERE " 
    cQuery += " TL_FILIAL = '" + FWxFilial("STL") + "' " 
    cQuery += " AND TL_ORDEM = '" + cOS + "' " 
    cQuery += " AND TL_SEQRELA <> '0' " 
    cQuery += " AND TL_TIPOREG = 'M' "
    cQuery += " AND STL.D_E_L_E_T_ = '' "

    //
    TcQuery cQuery New Alias "D_DATAS"
    DbSelectArea("D_DATAS")
    If D_DATAS->(Eof())
        D_DATAS->(DbCloseArea())
        RestArea(aArea)
        Return "Não há horas apontadas para OS " + cOS + "."

    EndIf

    //
    dDtIni := SToD(Substr(D_DATAS->INI,1,8))
    cHrIni := Substr(D_DATAS->INI,9,5)
    dDtFim := SToD(Substr(D_DATAS->FIM,1,8))
    cHrFim := Substr(D_DATAS->FIM,9,5)

    //
    D_DATAS->(DbCloseArea())

    //
    Conout(DToC(Date()) + " " + Time() + " - ADMINT015PInício NGFINAL")
    If ! NGFINAL(cOS,cPlan,dDtIni,cHrIni,dDtFim,cHrFim,0,0,cEquipment,,,,.T.) //Everson - 11/02/2021. Chamado 7936.
        Conout(DToC(Date()) + " " + Time() + " - ADMINT015P Erro NGFINAL")
        Conout(DToC(Date()) + " " + Time() + " - ADMINT015P " + cNGERROR)
        RestArea(aArea)
        Return "Ocorreu um problema ao finalizar a ordem de serviço. " + cNGERROR

    Else
        Conout(DToC(Date()) + " " + Time() + " - ADMINT015P Sucesso NGFINAL")
        MsUnlock()

    EndIf

Return ""
/*/{Protheus.doc} encerOS
    Função encerra SS.
    @type  Static Function
    @author Everson
    @since 23/02/2021
    @version 01
    /*/
Static Function encerSS(cOS)

    //Variáveis.
	Local aArea     := GetArea()

    //Everson - 07/07/2021. Chamado 16369.
    Local cHrTot    := ""
    Local dDtFim    := STJ->TJ_DTMRFIM
    Local cHrFim    := STJ->TJ_HOMRFIM

    //Everson - 07/07/2021. Chamado 16369. //Everson - 29/07/2021. Chamado 17344.
    cQuery := ""
    cQuery += " SELECT " 
    
    cQuery += " RIGHT('0000'+RIGHT('00'+CAST(CAST(BASE_SEC.TL_QUANTID AS INT)/3600 AS VARCHAR),2)+ " 
    cQuery += " ':'+LEFT(CAST(CAST(BASE_SEC.TL_QUANTID AS INT)%3600/60 AS VARCHAR(2))+'00' ,2) + ':00',10) AS TL_QUANTID " 

    cQuery += " FROM " 
    cQuery += " ( " 
    cQuery += " SELECT " 
    cQuery += " SUM( " 
    cQuery += " CASE   " 
    cQuery += " WHEN CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR)) > 0    " 
    cQuery += " THEN    " 
    cQuery += " SUBSTRING(CAST(TL_QUANTID AS VARCHAR),1,CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR))-1)*3600 +   " 
    cQuery += " SUBSTRING(CAST(TL_QUANTID AS VARCHAR),CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR))+1,10)*60  " 
    cQuery += " ELSE   " 
    cQuery += " TL_QUANTID*3600   " 
    cQuery += " END " 
    cQuery += " )  " 
    cQuery += " AS TL_QUANTID " 
    cQuery += " FROM     " 
    cQuery += " " + RetSqlName("STL") + "  (NOLOCK) AS STL     " 
    cQuery += " WHERE     " 
    cQuery += " TL_FILIAL = '" + FWxFilial("STL") + "' " 
    cQuery += " AND TL_ORDEM = '" + cOS + "'     " 
    cQuery += " AND TL_SEQRELA <> '0'     " 
    cQuery += " AND TL_TIPOREG = 'M'    " 
    cQuery += " AND STL.D_E_L_E_T_ = '' " 
    cQuery += " ) AS BASE_SEC   " 

    //
    TcQuery cQuery New Alias "D_DATAS"
    DbSelectArea("D_DATAS")
    If D_DATAS->(Eof())
        D_DATAS->(DbCloseArea())
        RestArea(aArea)
        Return "Não há horas apontadas para OS " + cOS + "."

    EndIf

    //
    cHrTot := D_DATAS->TL_QUANTID

    //
    D_DATAS->(DbCloseArea())

    //
    DbSelectArea("TQB")
    TQB->(DbSetOrder(04))
    If TQB->(DbSeek(FWxFilial("TQB") + cOS))
        MNW29502(TQB->TQB_CDSOLI)

    EndIf

    //
    DbSelectArea("TQB")
    TQB->(DbSetOrder(04))
    If TQB->(DbSeek(FWxFilial("TQB")+cOS))
        If TQB->TQB_SOLUCA == "D"

            //execauto
            cErro := ssAtutom(dDtFim, cHrFim, cHrTot)

        Else
            cErro := "'" + NGRETTITULO("TQB_SOLUCA") + "' da SS " + cOS + " não está como '"  +NGRETSX3BOX("TQB_SOLUCA","D") + "'."  //"da SS "##" não está como"
        
        EndIf

    Else
        cErro := "Não existe SS para a OS"

    EndIf

    //
	RestArea(aArea)

Return cErro
/*/{Protheus.doc} ssAtutom
    Execauto encerramento SS.
    @type  Static Function
    @author Everson
    @since 24/02/2021
    @version 01
    /*/
Static Function ssAtutom(dDtFim, cHrFim, cHrTot)

    //Variáveis.
    Local aArea     := GetArea()
    Local cErro     := ""

    Private lFacilit  := MNTINTFAC()

    //
	MNT280CPO(3,4)
	MNT280REG(4, a280Relac, a280Memos)
    DbSelectArea("TQB")
    RegToMemory("TQB",.F.)
    conout(DToC(Date()) + " " + Time() + " - ADMINT015P - Solicitação " + cValToChar(TQB->TQB_SOLICI))
    cErro += grvSS(3, 4, a280Memos, dDtFim, cHrFim, cHrTot)

    //
    RestArea(aArea)

Return cErro
/*/{Protheus.doc} verifyInput
    Função Verifica se possui pelo menos um insumo realizado.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function verifyInput(cCode, cPlan)

    //Variáveis.
    Local aArea := GetArea()

    //
	DbSelectArea("STL")
	STL->(DbSetOrder(1))
	STL->(DbSeek(FWxFilial("STL")+cCode+cPlan))
	While ! STL->(Eof()) .And. STL->TL_FILIAL == FWxFilial("STL") .And. STL->TL_ORDEM == cCode .And. STL->TL_PLANO == cPlan

        //
		If Val(STL->TL_SEQRELA) > 0
            RestArea(aArea)
			Return .T.

		EndIf

		STL->(DbSkip())

	End

    //
    RestArea(aArea)

Return .F.
/*/{Protheus.doc} OsData
    Função retorna dados de OS pendentes.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function OsData(cUser, lVisT, cFiltros, nOpcSql, cServico, cDtIni, cDtFim)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cJsonResp := "[]"
    Local cNmIns    := ""
    Local cTpIns    := ""
    Local cDesEtp   := ""
    Local cTpMan    := ""
    Local cCaract   := ""
    Local cNmTrf    := ""
    Local nToInPrv  := 0

    Default nOpcSql := 1

    //
    If Select("D_OS") > 0
        D_OS->(DbCloseArea())

    EndIf

    //
    If nOpcSql == 1

        //
        cQuery += " SELECT DISTINCT " 

        cQuery += "   TJ_FILIAL " 
        cQuery += " , TJ_ORDEM " 
        cQuery += " , T4_NOME " 
        cQuery += " , STF.TF_NOMEMAN, TJ_DTMPINI " 

        cQuery += " FROM  " 

        cQuery += " " + RetSqlName("STJ") + " (NOLOCK) AS STJ " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("STL") + " (NOLOCK) AS STL ON " 
        cQuery += " TJ_FILIAL = TL_FILIAL " 
        cQuery += " AND TJ_ORDEM = TL_ORDEM " 

        cQuery += " INNER JOIN "
        cQuery += " " + RetSqlName("ST4") + " (NOLOCK) AS ST4 ON "
        cQuery += " TJ_FILIAL = T4_FILIAL "
        cQuery += " AND TJ_SERVICO = T4_SERVICO "

        cQuery += " LEFT OUTER JOIN "
        cQuery += " ( SELECT TF_FILIAL, TF_CODBEM, TF_SERVICO, TF_SEQRELA, TF_NOMEMAN FROM " + RetSqlName("STF") + " (NOLOCK) AS STF WHERE TF_FILIAL = '" + FWxFilial("STF") + "' AND STF.D_E_L_E_T_ = '' ) AS STF ON "
        cQuery += " TJ_FILIAL = TF_FILIAL "
        cQuery += " AND TJ_CODBEM = TF_CODBEM"
        cQuery += " AND TJ_SERVICO = TF_SERVICO"
        cQuery += " AND TJ_SEQRELA= TF_SEQRELA"

        cQuery += " WHERE  " 
        cQuery += " TJ_FILIAL = '" + FWxFilial("STJ") + "'  " 
        cQuery += " AND TJ_SITUACA = 'L' " 
        cQuery += " AND TJ_TERMINO = 'N'  " 
        cQuery += " AND TL_TIPOREG = 'M' " 
        cQuery += " AND TL_SEQRELA = '0' "

        //
        If ! lVisT
            cQuery += " AND TL_CODIGO = '" + cUser + "' " 

        EndIf 

        If ! Empty(cFiltros)
            cQuery += cFiltros
            
        EndIf

        cQuery += " AND STJ.D_E_L_E_T_ = ''  " 
        cQuery += " AND STL.D_E_L_E_T_ = '' " 
        cQuery += " AND ST4.D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY TJ_DTMPINI, TJ_ORDEM " 

    ElseIf nOpcSql == 2

        //
        cQuery += " SELECT  " 
        cQuery += " * " 
        cQuery += " FROM " 
        cQuery += " ( " 
        cQuery += "  " 
        cQuery += " SELECT  " 
        cQuery += " DISTINCT TJ_FILIAL, TJ_ORDEM, T4_NOME, STF.TF_NOMEMAN, TJ_DTMPINI, TJ_SERVICO, " 
        cQuery += " CASE WHEN SUM(CASE WHEN TL_TIPOREG = 'M' AND TL_SEQRELA = '0' THEN 1 ELSE 0 END) > 0 THEN 'atribuidas' ELSE 'pendentes' END AS STATUS " 
        cQuery += " FROM " 
        cQuery += " " + RetSqlName("STJ") + " (NOLOCK) AS STJ " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " (SELECT TL_FILIAL, TL_ORDEM, TL_TIPOREG, TL_SEQRELA FROM " + RetSqlName("STL") + " (NOLOCK) AS STL WHERE TL_FILIAL = '" + FWxFilial("STF") + "' AND STL.D_E_L_E_T_ = '') AS STL ON   " 
        cQuery += " TJ_FILIAL = TL_FILIAL " 
        cQuery += " AND TJ_ORDEM = TL_ORDEM " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ST4") + " (NOLOCK) AS ST4 ON " 
        cQuery += " TJ_FILIAL = T4_FILIAL " 
        cQuery += " AND TJ_SERVICO = T4_SERVICO " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " (SELECT TF_FILIAL, TF_CODBEM, TF_SERVICO, TF_SEQRELA, TF_NOMEMAN FROM " + RetSqlName("STF") + " (NOLOCK) AS STF WHERE TF_FILIAL = '" + FWxFilial("STF") + "' AND STF.D_E_L_E_T_ = '') AS STF ON " 
        cQuery += " TJ_FILIAL = TF_FILIAL " 
        cQuery += " AND TJ_CODBEM = TF_CODBEM " 
        cQuery += " AND TJ_SERVICO = TF_SERVICO " 
        cQuery += " AND TJ_SEQRELA= TF_SEQRELA " 
        cQuery += " WHERE " 
        cQuery += " TJ_FILIAL = '" + FWxFilial("STF") + "' " 
        cQuery += " AND TJ_TERMINO = 'N' " 
        cQuery += " AND TJ_SITUACA = 'L' " 
        cQuery += " AND STJ.D_E_L_E_T_ = '' " 
        cQuery += " AND ST4.D_E_L_E_T_ = '' " 
        cQuery += " GROUP BY " 
        cQuery += " TJ_FILIAL, TJ_ORDEM, T4_NOME, STF.TF_NOMEMAN, TJ_DTMPINI, TJ_SERVICO " 
        cQuery += " ) AS FONTE " 
        cQuery += " WHERE " 
        cQuery += " FONTE.TJ_FILIAL = '" + FWxFilial("STF") + "' " 
        cQuery += cFiltros
        cQuery += " ORDER BY " 
        cQuery += " FONTE.TJ_DTMPINI, FONTE.TJ_ORDEM " 

    EndIf

    //
    TcQuery cQuery New Alias "D_OS"
    DbSelectArea("D_OS")
    D_OS->(DbGoTop())

    //
    If ! D_OS->(Eof())

        //
        DbSelectArea("STJ")
        STJ->(DbSetOrder(1))
        STJ->(DbGoTop())

        //
        DbSelectArea("STL")
        STL->(DbSetOrder(1))
        STL->(DbGoTop())

        //
        DbSelectArea("STQ")
        STQ->(DbSetOrder(1))
        STQ->(DbGoTop())

        //
        cJsonResp := '[' 
        While ! D_OS->(Eof())

            //
            nToInPrv := 0

            //
            If ! STJ->(DbSeek( D_OS->TJ_FILIAL + D_OS->TJ_ORDEM ))
                STJ->(DbSkip())
                Loop

            EndIf

            cJsonResp += '{' 

                //Dados sem grupo.
                cTpMan  := rmvAcento(Alltrim(Posicione("STE",1, STJ->TJ_FILIAL + STJ->TJ_TIPO,"TE_NOME")))
                cCaract := rmvAcento(Alltrim(Posicione("STE",1, STJ->TJ_FILIAL + STJ->TJ_TIPO,"TE_CARACTE")))

                //
                cJsonResp += '"empresa":"' + cEmpAnt + '",' 
                cJsonResp += '"filial":"' + cFilAnt + '",' 
                cJsonResp += '"user":"' + cUser + '",' 
                cJsonResp += '"id":"' + Alltrim(cValToChar(STJ->TJ_ORDEM)) + '",' 
                cJsonResp += '"plano":"' + Alltrim(cValToChar(STJ->TJ_PLANO)) + '",' 
                cJsonResp += '"ss":"' + Alltrim(cValToChar(STJ->TJ_SOLICI)) + '",'

                cJsonResp += '"tipoMan":{'
                    cJsonResp += '"codigo":"' + STJ->TJ_TIPO + '",'
                    cJsonResp += '"descricao":"' + cTpMan + '",'
                    cJsonResp += '"caractere":"' + cCaract + '"'
                cJsonResp += '},' 

                cJsonResp += '"status":"aberta",' 
                cJsonResp += '"situacao":"' + Iif(STJ->TJ_DTMPINI < Date(),'1', Iif(STJ->TJ_DTMPINI = Date(),'2','3') ) + '",' 
                cJsonResp += '"hrTotal":"",' 

                //Observações.
                cObs := Alltrim(STJ->TJ_OBSERVA)
                cObs := rmvAcento(cObs)
                cJsonResp += '"obs":{' 
                    cJsonResp += '"titulo":"Observações",' 
                    cJsonResp += '"inicial":"' + cObs + '",'
                    cJsonResp += '"complemento":""' 
                cJsonResp += '},'

                //Cabeçalho.
                cJsonResp += '"header":{' 

                    cJsonResp += '"bem": {'
                        cJsonResp += '"codigo":"'    + Alltrim(STJ->TJ_CODBEM) + '",' 
                        cJsonResp += '"descricao":"' + rmvAcento(Posicione("ST9", 1, STJ->TJ_FILIAL + STJ->TJ_CODBEM, "T9_NOME")) + '"' 
                    cJsonResp += '},'  

                    cJsonResp += '"servico":{'
                        cJsonResp += '"codigo":"' + Alltrim(STJ->TJ_SERVICO) + '",'
                        cJsonResp += '"descricao":"' + Alltrim(D_OS->T4_NOME) + '"'
                    cJsonResp += '},' 

                    cJsonResp += '"manutencao":"' + Iif(rmvAcento(Alltrim(D_OS->TF_NOMEMAN)) = '', cTpMan, rmvAcento(Alltrim(D_OS->TF_NOMEMAN))) + '",'
                    cJsonResp += '"sequencia":"' + cValToChar(STJ->TJ_SEQUENC) + '",' 

                    cJsonResp += '"emissao":{' 
                        cJsonResp += '"data":"' + DToS(STJ->TJ_DTORIGI) + '",' 
                        cJsonResp += '"hora":""' 
                    cJsonResp += '},' 

                    cJsonResp += '"inicioPrev":{'
                        cJsonResp += '"data":"' + DToS(STJ->TJ_DTMPINI) + '",' 
                        cJsonResp += '"hora":"' + STJ->TJ_HOMPINI + '"' 
                    cJsonResp += '},'

                    cJsonResp += '"inicio":{'
                        cJsonResp += '"data":"",' 
                        cJsonResp += '"hora":""' 
                    cJsonResp += '},'

                    cJsonResp += '"fim":{'
                        cJsonResp += '"data":"",' 
                        cJsonResp += '"hora":""' 
                    cJsonResp += '}'

                cJsonResp += '},' 

                //Insumos previstos.
                nToInPrv := 0
                cJsonResp += '"insumosPrevistos":{' 
                    cJsonResp += '"titulo":"Insumos Previstos",' 
                    cJsonResp += '"dados":[' 

                        //
                        STL->(DbGoTop())
                        If STL->( DbSeek(STJ->TJ_FILIAL + STJ->TJ_ORDEM) )

                            While !STL->(Eof()) .And. STL->TL_FILIAL == STJ->TJ_FILIAL .And. STL->TL_ORDEM == STJ->TJ_ORDEM

                                If Alltrim(STL->TL_SEQRELA) == "0"

                                    cNmIns := rmvAcento(Alltrim(NOMINSBRW(STL->TL_TIPOREG,STL->TL_CODIGO)))
                                    cTpIns := rmvAcento(Alltrim(TIPREGBRW(STL->TL_TIPOREG))) 
                                    LCORRET:=If(Val(stj->tj_plano) = 0,.T.,.f.)
                                    cNmTrf := rmvAcento(Alltrim(VSAY("06")))

                                    //
                                    If Empty(cNmIns) .And. STL->TL_TIPOREG == "M"
                                        cNmIns := rmvAcento(Alltrim(Posicione("ST1",1,STL->TL_FILIAL + STL->TL_CODIGO,"T1_NOME")))

                                    EndIf

                                    cJsonResp += '{' 

                                        cJsonResp += '"tarefa":{'
                                            cJsonResp += '"codigo":"' + Alltrim(STL->TL_TAREFA) + '",'
                                            cJsonResp += '"descricao":"' + cNmTrf + '"'
                                        cJsonResp += '},' 

                                        cJsonResp += '"plano":"' + Alltrim(STL->TL_PLANO) + '",' 
                                        cJsonResp += '"seqRetorno":"' + Alltrim(STL->TL_SEQRELA) + '",' 
                                        cJsonResp += '"tipo":"' + cTpIns + '",' 
                                        cJsonResp += '"codigo":"' + Alltrim(STL->TL_CODIGO) + '",' 
                                        cJsonResp += '"descricao":"' + cNmIns  + '",' 
                                        cJsonResp += '"quantidade":"' + cValToChar(STL->TL_QUANREC) + '",' 
                                        cJsonResp += '"consumo":"'    + cValToChar(STL->TL_QUANTID) + '",' 
                                        cJsonResp += '"caracTipo":"'    + cValToChar(STL->TL_TIPOREG) + '",' 
                                        cJsonResp += '"unidade":"' + Alltrim(STL->TL_UNIDADE) + '"' 

                                    cJsonResp += '},' 

                                    nToInPrv++

                                EndIf

                                STL->(DbSkip())

                            End
                            
                            //
                            If nToInPrv > 0
                                cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)

                            EndIf

                        EndIf

                    cJsonResp += ']'

                cJsonResp += '},' 

                //Insumos reportados.
                cJsonResp += '"insumosReportados":{' 
                        cJsonResp += '"titulo":"Mão de Obra Reportada",' 
                        cJsonResp += '"dados":[]' 
                cJsonResp += '},' 

                //Horas reportadas.
                nToInPrv := 0
                cJsonResp += '"horasReportadas":{' 
                        cJsonResp += '"titulo":"Horas Reportadas",' 
                        cJsonResp += '"dados":['

                            //
                            STL->(DbGoTop())
                            If STL->( DbSeek(STJ->TJ_FILIAL + STJ->TJ_ORDEM) )

                                While !STL->(Eof()) .And. STL->TL_FILIAL == STJ->TJ_FILIAL .And. STL->TL_ORDEM == STJ->TJ_ORDEM

                                    If Alltrim(STL->TL_SEQRELA) <> "0" .And. Alltrim(STL->TL_TIPOREG) == "M"

                                        cTpIns := rmvAcento(Alltrim(TIPREGBRW(STL->TL_TIPOREG))) 
                                        LCORRET:=If(Val(stj->tj_plano) = 0,.T.,.f.)
                                        cNmIns := rmvAcento(Alltrim(Posicione("ST1",1,STL->TL_FILIAL + STL->TL_CODIGO,"T1_NOME")))

                                        cJsonResp += '{' 

                                            cJsonResp += '"codigo":"' + Alltrim(STL->TL_CODIGO) + '",' 
                                            cJsonResp += '"nome":"' + cNmIns  + '",' 
                                            cJsonResp += '"consumo":"'    + convHrF(cValToChar(STL->TL_QUANTID)) + '",' 
                                            cJsonResp += '"unidade":"' + Alltrim(STL->TL_UNIDADE) + '"' 

                                        cJsonResp += '},' 

                                        nToInPrv++

                                    EndIf

                                    STL->(DbSkip())

                                End
                                
                                //
                                If nToInPrv > 0
                                    cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)

                                EndIf

                            EndIf

                        cJsonResp += ']' 
                cJsonResp += '},' 

                //Etapas previstas/reportadas.
                cJsonResp += '"etaPasPrevRep":{' 
                    cJsonResp += '"titulo":"Etapas Previstas",' 

                    cJsonResp += '"dados":[' 

                    //
                    STQ->(DbGoTop())
                    If STQ->( DbSeek(STJ->TJ_FILIAL + STJ->TJ_ORDEM) )

                        While !STQ->(Eof()) .And. STQ->TQ_FILIAL == STQ->TQ_FILIAL .And. STQ->TQ_ORDEM == STJ->TJ_ORDEM
                            
                            cDesEtp := rmvAcento(Posicione("TPA",1,STQ->TQ_FILIAL + STQ->TQ_ETAPA,"TPA_DESCRI"))
                            cNmTrf := rmvAcento(Alltrim(VSAY("06")))

                            cJsonResp += '{'

                                cJsonResp += '"ordem":"' + STQ->TQ_ORDEM + '",'
                                cJsonResp += '"plano":"' + STQ->TQ_PLANO + '",'

                                cJsonResp += '"tarefa":{'
                                    cJsonResp += '"codigo":"' + STQ->TQ_TAREFA + '",'
                                    cJsonResp += '"descricao":"' + cNmTrf + '"'
                                cJsonResp += '},'
                            
                                cJsonResp += '"etapa":"' + STQ->TQ_ETAPA + '",'
                                cJsonResp += '"descricao":"' + cDesEtp + '",'

                                cJsonResp += '"seqTarefa":"' + STQ->TQ_SEQTARE + '",'
                                cJsonResp += '"seqEtapa":"' + STQ->TQ_SEQETA + '",'
                                cJsonResp += '"opcao":"' + Iif(Empty(Alltrim(cValToChar(STQ->TQ_OPCAO))), "1", Alltrim(cValToChar(STQ->TQ_OPCAO))) + '", '
                                cJsonResp += '"resposta":"' + rmvAcento(Alltrim(TIPREGBRW(STQ->TQ_OBSERVA))) + '"'

                            cJsonResp += '},' 

                            STQ->(DbSkip())

                        End

                        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)

                    EndIf

                    cJsonResp += ']' 

                cJsonResp += '},'

                //Motivos de atraso.
                cJsonResp += '"motivosDeAtrasos":{' 
                    cJsonResp += '"titulo":"Motivos de Atraso",' 
                    cJsonResp += '"dados":[]'
                cJsonResp += '}' 

            cJsonResp += '},' 

            D_OS->(DbSkip())
        End  

        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)
        cJsonResp += ']'

    EndIf

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} convHrF
    Convert para formato em horas com ":".
    @type  Static Function
    @author Everson
    @since 26/04/2021
    @version 01
    /*/
Static Function convHrF(cHr)

    //Variáveis.
    Local cHora  := ""
    Local nPOSTI := At (".",cHr)
    Local cH     := ""
    Local cM     := ""

    //
    If nPOSTI == 0
        cHora := Right("00" + cHr + ":00",5)

    Else
        cH :=  Padl(Substr(cHr,1,nPOSTI-1),2,"0")
        cM :=  Padr(Substr(cHr,nPOSTI+1,2),2,"0")
        cHora := cH + ":" + cM

    EndIf

Return cHora
/*/{Protheus.doc} FuncData
    Função retorna string json com os funcionários
    do departamento de manutenção.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function FuncData()

    //Variáveis.
    Local aArea     := GetArea()
    Local cJsonResp := "[]"
    Local cQuery    := ""

    //
    cQuery += " SELECT "
    cQuery += " T1_CODFUNC, "
    cQuery += " RTRIM(LTRIM(T1_NOME)) AS T1_NOME 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ST1") + " (NOLOCK) AS ST1 "
    cQuery += " WHERE "
    cQuery += " T1_FILIAL ='" + FWxFilial("ST1") + "' " 
    cQuery += " AND T1_DTFIMDI = '' "
    cQuery += " AND ST1.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY T1_NOME "

    //
    If Select("D_FUNC") > 0
        D_FUNC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_FUNC"
    DbSelectArea("D_FUNC")
    D_FUNC->(DbGoTop())

    //
    If ! D_FUNC->(Eof())

        cJsonResp := '['

            //
            While !D_FUNC ->(Eof())
                cJsonResp += '{"codigo":"' + Alltrim(cValToChar(D_FUNC->T1_CODFUNC)) + '","label":"' + rmvAcento(Alltrim(cValToChar(D_FUNC->T1_NOME))) + '"},'

                D_FUNC->(DbSkip())
            End

        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)
        cJsonResp += ']'

    EndIf

    //
    D_FUNC->(DbCloseArea())

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} MotAtrData
    Função retorna string json com os motivos de atraso.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function MotAtrData()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := " SELECT TPJ_CODMOT, TPJ_DESMOT FROM " + RetSqlName("TPJ") + " WHERE TPJ_FILIAL = '" + FWxFilial("TPJ") + "' AND D_E_L_E_T_ = '' "
    Local cJsonResp := "[]"

    //
    If Select("D_MOT") > 0
        D_MOT->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_MOT"
    DbSelectArea("D_MOT")
    D_MOT->(DbGoTop())

    //
    If ! D_MOT->(Eof())
        cJsonResp := '['

            While ! D_MOT->(Eof())
                
                cJsonResp += '{"codigo":"' + Alltrim(D_MOT->TPJ_CODMOT) + '","desc":"' + rmvAcento(Alltrim(D_MOT->TPJ_DESMOT)) + '"},'

                D_MOT->(DbSkip())
            End

        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)
        cJsonResp += ']'

    EndIf

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} Empresas
    Retorna dados de empresas e filiais liberadas.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function Empresas()

    //Variáveis.
    Local cJsonResp := ""
    
    //
    cJsonResp += '['
        cJsonResp += '{"key": "01", "empresa": "01", "filial" : "02", "label": "Emp 01 Adoro Filial: 02"},'
        cJsonResp += '{"key": "02", "empresa": "01", "filial" : "03", "label": "Emp 01 Adoro Filial: 03"},'
        cJsonResp += '{"key": "03", "empresa": "02", "filial" : "01", "label": "Emp 02 Ceres Filial: 01"}'
    cJsonResp += ']'

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} Services
    Valida usuário.
    @type  Static Function
    @author Everson
    @since 19/04/2021
    @version 01
    /*/
Static Function Services()

    //Variáveis.
    Local aArea     := GetArea()
    Local cJsonResp := "[]"
    Local cQuery    := ""

    //
    cQuery += " SELECT "
    cQuery += " T4_SERVICO, "
    cQuery += " RTRIM(LTRIM(T4_NOME)) AS T4_NOME 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ST4") + " (NOLOCK) AS ST4 "
    cQuery += " WHERE "
    cQuery += " T4_FILIAL ='" + FWxFilial("ST4") + "' " 
    cQuery += " AND ST4.T4_NOME NOT IN ('','-') "
    cQuery += " AND ST4.T4_SERVICO NOT IN ('','-') "
    cQuery += " AND ST4.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY T4_SERVICO, T4_NOME "

    //
    If Select("D_FUNC") > 0
        D_FUNC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_FUNC"
    DbSelectArea("D_FUNC")
    D_FUNC->(DbGoTop())

    //
    If ! D_FUNC->(Eof())

        cJsonResp := '['

            //
            While !D_FUNC ->(Eof())
                cJsonResp += '{"codigo":"' + Alltrim(cValToChar(D_FUNC->T4_SERVICO)) + '","label":"' + Alltrim(cValToChar(D_FUNC->T4_SERVICO)) + ' ' + rmvAcento(Alltrim(cValToChar(D_FUNC->T4_NOME))) + '"},'

                D_FUNC->(DbSkip())
            End

        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)
        cJsonResp += ']'

    EndIf

    //
    D_FUNC->(DbCloseArea())

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} Tasks
    Obtém as tarefas.
    @type  Static Function
    @author Everson
    @since 23/04/2021
    @version 01
    /*/
Static Function Tasks()

    //Variáveis.
    Local aArea     := GetArea()
    Local cJsonResp := "[]"
    Local cQuery    := ""

    //
    cQuery += " SELECT TT9_TAREFA, TT9_DESCRI FROM " + RetSqlName("TT9") + " (NOLOCK) AS TT9 WHERE TT9_FILIAL = '" + FWxFilial("TT9") + "' AND TT9.D_E_L_E_T_ = '' ORDER BY TT9_TAREFA, TT9_DESCRI "

    //
    If Select("D_TAREFA") > 0
        D_TAREFA->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_TAREFA"
    DbSelectArea("D_TAREFA")
    D_TAREFA->(DbGoTop())

    //
    If ! D_TAREFA->(Eof())

        cJsonResp := '['

            //
            While ! D_TAREFA ->(Eof())
                cJsonResp += '{"codigo":"' + Alltrim(cValToChar(D_TAREFA->TT9_TAREFA)) + '","label":"' + Alltrim(cValToChar(D_TAREFA->TT9_TAREFA)) + ' ' +rmvAcento(Alltrim(cValToChar(D_TAREFA->TT9_DESCRI))) + '"},'
                
                D_TAREFA->(DbSkip())
            End

        cJsonResp := Substr(cJsonResp,1,Len(cJsonResp)-1)
        cJsonResp += ']'

    EndIf

    //
    D_TAREFA->(DbCloseArea())

    //
    RestArea(aArea)

Return EncodeUTF8(cJsonResp)
/*/{Protheus.doc} vldUser
    Valida usuário.
    @type  Static Function
    @author Everson
    @since 19/01/2021
    @version 01
    /*/
Static Function vldUser(lRet, cUser, cSenha, cEmpresa, cFil, login)

    //Variáveis.
    Local aArea     := GetArea()
    Local cJsonResp := ""
    Local cQuery    := " SELECT T1_NOME, T1_SENHA FROM ST1" + cEmpresa + "0 (NOLOCK) AS ST1 WHERE T1_FILIAL = '" + cFil + "' AND T1_CODFUNC = '" + cUser + "' AND ST1.D_E_L_E_T_ = '' "
    Local cAtrOs    := ""

    Default login   := .F.

    //
    If Empty(Alltrim(cValToChar(cSenha)))
        RestArea(aArea)
        return .F.

    EndIf

    //
    If Select("D_FUNC") > 0
        D_FUNC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_FUNC"
    DbSelectArea("D_FUNC")
    D_FUNC->(DbGoTop())
    If D_FUNC->(Eof())
        lRet := .F.

    Else
        If Alltrim(cValToChar(cSenha)) <> Alltrim(cValToChar(D_FUNC->T1_SENHA))
            lRet := .F.

        Else
            lRet := .T.
            If login
                cAtrOs := StartJob("U_ADMNT15F",GetEnvServer(),.T., cEmpresa, cFil, cUser) //ADMNT15F(cEmpresa, cFil, cUser)
                cJsonResp := '{"user":"' + cUser + '", "name":"' + rmvAcento(Alltrim(D_FUNC->T1_NOME)) + '", "associaOS": "' + cAtrOs + '" }'
            
            EndIf

        EndIf

    EndIf 

    //
    D_FUNC->(DbCloseArea())
    RestArea(aArea)

Return cJsonResp
/*/{Protheus.doc} ADMNT15F
    Checa se usuário faz atribuição de OS.
    @type  User Function
    @author Everson
    @since 26/04/2021
    @version 01
    /*/
User Function ADMNT15F(cEmpresa, cFil, cUser)

    //Variáveis.
    Local aArea := GetArea()
    Local lVisT := .F.
    Local cEspe := ""
    Local lChk  := .F.

    //
    RpcSetType(3)
    RpcSetEnv(cEmpresa,cFil,,,,GetEnvServer(),{ })

        lVisT := cUser $ Alltrim(cValToChar(GetMv("MV_#GEMAT",,"XXXXXX")))
        cEspe := Alltrim(cValToChar(GetMv("MV_#GEESP",,"XXXXXX")))

        //
        DbSelectArea("ST2")
        ST2->(DbSetOrder(1))
        If ST2->(DbSeek( FWxFilial("ST2") + cUser ))

            While ! ST2->(Eof()) .And. FWxFilial("ST2") == ST2->T2_FILIAL .And. ST2->T2_CODFUNC == cUser

                If Alltrim(cValToChar(ST2->T2_ESPECIA)) $ cEspe
                    lChk := .T.

                EndIf

                ST2->(DbSkip())

            End

        EndIf 

    //
    RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return Iif(lVisT .Or. lChk,"S","N")
/*/{Protheus.doc} rmvAcento
    Função remove acentos de textos.
    @type  Static Function
    @author Everson
    @since 25/01/2021
    @version 01
    /*/
Static Function rmvAcento(cTexto)
//Return Static Call(ADFIN064P, rmvAcento,cTexto)
//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
Return u_FIN064A0(cTexto)

/*/{Protheus.doc} logZBE
    Gera log.
    @type  Static Function
    @author Everson
    @since 28/01/2021
    @version 01
    /*/
Static Function logZBE(cUser,cBody,cLog)
    
    //Variáveis.
	Local aArea   := GetArea()
    Local cNmUsr := retNmUsr(cUser)

	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
        Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
        Replace ZBE_DATA 	   	With dDataBase
        Replace ZBE_HORA 	   	With Time()
        Replace ZBE_USUARI	    With cNmUsr
        Replace ZBE_LOG	        With cLog
        Replace ZBE_PARAME      With "Código Usr ST1 " + cUser
        Replace ZBE_MODULO	    With "MANUTENÇÃO"
        Replace ZBE_ROTINA	    With "ADMNT015P" 
        Replace ZBE_LOGMEM      With cBody
	ZBE->( MsUnLock())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} logZBE
    Gera log.
    @type  Static Function
    @author Everson
    @since 28/01/2021
    @version 01
    /*/
Static Function retNmUsr(cUser)

    //Variáveis.
    Local aArea := GetArea()
    Local cNome := ""

    //
    If ! Empty(Alltrim(cValToChar(cUser)))
        cNome := Posicione("ST1",1,FWxFilial("ST1") + cUser,"T1_NOME")

    EndIf

    //
    RestArea(aArea)

Return cNome
/*/{Protheus.doc} grvSS
    Grava dados da SS.
    @type  Static Function
    @author Everson
    @since 24/02/2021
    @version 01
    /*/
Static Function grvSS(nModo, nOpcx, aMemos, dDtFim, cHrFim, cHrTot)

    //Variáveis.
	Local aArea     := GetArea()
    Local i
    lOCAL nRecno
    lOCAL nSMM
	Local cCodSS
    lOCAL cVarMemo
    lOCAL cVarCpo
    lOCAL cCodFlwUp
	Local oTmpW025
	Local oTmpW040
	Local oTmpW045
	Local aDbfW045   := {}
    Local lGerWorkF  := GetNewPar("MV_NGSSWRK","N") == "S"
	
	Private cTrbW045 := GetNextAlias()
	Private cTrbW025 := GetNextAlias()
	Private cTrbW040 := GetNextAlias()

    //
    If lGerWorkF
        MNTW025Tmp(@cTrbW025, @oTmpW025)
        cMNTW040Tmp(@cTrbW040, @oTmpW040)
        MNTW045Tmp(@cTrbW045, @oTmpW045, @aDbfW045)
        
    EndIf

    //
    Begin Transaction

        M->TQB_DTFECH := dDtFim
        M->TQB_HOFECH := cHrFim
        M->TQB_TEMPO  := cHrTot

        Conout(DToC(Date()) + " " + Time() + " - ADMINT015P M->TQB_SOLICI " + cValtoChar(M->TQB_SOLICI))

        //
        If Empty(Alltrim(cValToChar(M->TQB_SOLICI)))
            RestArea(aArea)
            Return "Solicitação de serviço nula [ADMNT015P-grvSS]"

        EndIf

        //
        DbSelectArea("TQB")
        TQB->(DbSetOrder(1))
        If ! TQB->(DbSeek(FWxFilial("TQB")+M->TQB_SOLICI))
            RestArea(aArea)
            Return "Solicitação não localizada"

        EndIf

        //
        RecLock("TQB",.F.)

            //
            For i:=1 to FCount()
                If "_FILIAL"$FieldName(i)
                    FieldPut(i, xFilial("TQB"))

                Else
                    FieldPut(i, &("M->"+FieldName(i)))

                EndIf

            Next i

        //
        TQB->(MsUnlock())

        //
        DbSelectArea("TQB")
        nSMM := If(nOpcx == 3 .Or. nOpcx == 4,1,2)

        //
        For i:=1 to Len(aMemos)
            cVarCpo := aMemos[i][1]
            cVarMemo:= aMemos[i][2]
            If nOpcx == 3
                MSMM(,,,&cVarMemo,nSMM,,,"TQB",aMemos[i][1])

            Else
                MSMM(&cVarCpo,,,&cVarMemo,nSMM,,,"TQB",aMemos[i][1])

            EndIf

        Next i

        //
        EvalTrigger()

        //
        cCodSS := TQB->TQB_SOLICI

        //
        DbSelectArea("TQB")
        RecLock("TQB",.F.)
            TQB->TQB_SOLUCA := "E"
        MsUnLock("TQB")

        //
        EvalTrigger()

        //
        If FieldPos("TQB_PRIOR2") > 0
            If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
                dbSelectArea("TT7")
                dbSetOrder(1)
                dbSeek(xFilial("TT7")+TQB->TQB_SOLICI)
                While !Eof() .And. TT7->TT7_FILIAL == xFilial("TT7") .And. TT7->TT7_SOLICI == TQB->TQB_SOLICI
                    dbSelectArea("STJ")
                    dbSetOrder(1)
                    If dbSeek(xFilial("STJ")+TT7->TT7_ORDEM)
                        RecLock("STJ",.F.)
                            STJ->TJ_PRIORID := TQB->TQB_PRIOR2
                        MsUnLock("STJ")
                    EndIf
                    dbSelectArea("TT7")
                    dbSkip()
                End
            Else
                If !Empty(TQB->TQB_ORDEM)
                    dbSelectArea("STJ")
                    dbSetOrder(1)
                    If dbSeek(xFilial("STJ")+TQB->TQB_ORDEM)
                        RecLock("STJ",.F.)
                        STJ->TJ_PRIORID := TQB->TQB_PRIOR2
                        MsUnLock("STJ")
                    EndIf
                EndIf
            EndIf

        EndIf

        If AllTrim(SuperGetMv("MV_NGSSWRK",.F.,"")) == "S"
            If AliasInDic("TUQ")
                cContVar := AllTrim(SuperGetMv("MV_NGPESST",.F.,""))
                aQuest := fRetQuesti(cContVar,TQB->TQB_SOLICI,.F.,TQB->TQB_SEQQUE)
                //Verifica se o Questionário está habilitado ou não (1=Sim;2=Não)
                If Len(aQuest) > 0 .And. aQuest[4] <> "1" //Verifica se há questionário de Satisfação cadastrado antes da validação.
                    MNT307QUE(.F.,TQB->TQB_SOLICI,.T.)
                EndIf
            EndIf
            DbSelectArea("TQB")
            nRecno := TQB->(Recno())

            MNTW035(nRecno) //Envia workflow para o solicitante da SS;

            dbSelectArea("TQB")
            TQB->(dbGoto(nRecno))

        EndIf

        If  NGCADICBASE("ZZY_DTREPR","D","ZZY",.F.) .And. NGCADICBASE("ZZY_SEQUEN","D","ZZY",.F.) .And. ;
            NGCADICBASE("ZZY_SERVIC","D","ZZY",.F.) .And. NGCADICBASE("TJ_STATUS","D","STJ",.F.)
            lCervPetro := .t.
            U_CER1W002(TQB->TQB_CDSOLI)

        ElseIf NGCADICBASE("ZZ7_NUMPI","D","ZZ7",.F.)
            lEnercan := .t.
            U_ENE1W002(TQB->TQB_CDSOLI)

        EndIf

        //
        If lFacilit

            //
            cCodFlwUp := "06"

            //Grava Follow-up
            MNT280GFU(cCodSS,cCodFlwUp,,,,,,,cCodFun,cCodFilAte)

        EndIf

    End Transaction

    //
    If lGerWorkF
        oTmpW025:Delete()
        oTmpW040:Delete()
        oTmpW045:Delete()

    EndIf

    //
    Conout("----------------------------------------------------")
    Conout(DToC(Date()) + " " + Time() + " TQB->TQB_DTFECH " + cValToChar(TQB->TQB_DTFECH))
    Conout(DToC(Date()) + " " + Time() + " TQB->TQB_HOFECH " + cValToChar(TQB->TQB_HOFECH))
    Conout(DToC(Date()) + " " + Time() + " TQB->TQB_TEMPO " + cValToChar(TQB->TQB_TEMPO))
    Conout(DToC(Date()) + " " + Time() + " TQB->TQB_SOLUCA " + cValToChar(TQB->TQB_SOLUCA))

    //
	DbSelectArea("TQB")

    //
    RestArea(aArea)

Return ""
/*/{Protheus.doc} cMNTW040Tmp
    Cria tabela temporária.
    @type  Static Function
    @author Everson
    @since 24/02/2021
    @version 01
    /*/
Static Function cMNTW040Tmp(cTrbW040, oTmpW040)

	Local aDBF := {}

	//Número S.S. / Tipo S.S. / Nome do Bem / Código do Executante / Data Abertura / Tipo Serviço / Solicitante e Descrição do Serviço
	aDBF := {	{"SOLICI" ,"C",TAMSX3("TQB_SOLICI")[1],0},;
				{"TIPOSS" ,"C",1,0},;
				{"NOMBEM" ,"C",20,0},;
				{"CDEXEC" ,"C",25,0},;
				{"DTABER" ,"D",8,0},;
				{"HRABER" ,"C",5,0},;
				{"CDSERV" ,"C",TAMSX3("TQB_CDSERV")[1],0},;
				{"NMSERV" ,"C",25,0},;
				{"CDSOLI" ,"C",TAMSX3("TQB_CDSOLI")[1],0},;
				{"NMSOLI" ,"C",25,0},;
				{"CDRESP" ,"C",Len(TQ3->TQ3_CDRESP),0},;
				{"EMAIL"  ,"C",100,0},;
				{"CODMSS" ,"C",06,0},;
				{"DESMSS" ,"M",80,0}	}

	//Intancia classe FWTemporaryTable
	oTmpW040 := FWTemporaryTable():New( cTrbW040, aDBF )
	//Cria indices
	oTmpW040:AddIndex( "Ind01" , {"SOLICI"} )
	//Cria a tabela temporaria
	oTmpW040:Create()

Return Nil
