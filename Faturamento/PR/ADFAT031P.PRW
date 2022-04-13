#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

Static xPula :=  Chr(13) + Chr(10) 

/*/{Protheus.doc} ADFAT031P
    Job para obter dados da fila de mensagens mortas do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/02/2022
    @version 01
    /*/
User Function ADFAT031P() // U_ADFAT031P()

    //Vari√°veis.

	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        U_ADFAT31A()

    RpcClearEnv()

Return Nil
/*/{Protheus.doc} ADFAT31A
    Processa importaÁ„o da fila de registros do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/02/2022
    @version 01
    /*/
User Function ADFAT31A(Emp, Fil)

    //Vari√°veis.
    Local aArea         := GetArea()
    Local cMsgError     := ""
    Local cId           := ""
    Local cUrl          := "https://4icniy3gqa.execute-api.us-east-2.amazonaws.com"
    Local cPath         := "/test/barramento"
    Local cKey          := "7PZkSJom027jDIpTVfOrp77WyLieDbi26O0rEL5K"
    Local oRestClient   := Nil
    Local aCabecalho    := {}
    Local oJson         := Nil
    Local xRet          := Nil
    Local cJsonRet      := ""
    Local cFila         := "protheus.fifo"
    Local oError        := ErrorBlock( {|e| cMsgError := e:Description , Break(e) } )

    logZBE("ADFAT31A", "INÕCIO", "")

    Aadd(aCabecalho, "Content-Type: application/json")
    Aadd(aCabecalho, "x-api-key: " + cKey)
    Aadd(aCabecalho, "queue: " + cFila)

    While .T.

        oRestClient := FWRest():New(cUrl)
        oRestClient:SetPath(cPath)

        Begin Sequence

            If ! oRestClient:Get(aCabecalho)
                cMsgError := Alltrim(cValToChar(oRestClient:GetLastError()))
                logZBE("ADFAT31A", "ERRO - oRestClient", cMsgError, .T.)
                Help(Nil, Nil, "Fun√ß√£o ADFAT31A(ADFAT031P)", Nil, "Erro no envio do registro." + xPula + cId + xPula + Alltrim(cValToChar(ZIQ->ZIQ_TOPICO)) + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                RestArea(aArea)
                Return .F.

            Else
                cJsonRet := oRestClient:GetResult()
                logZBE("ADFAT31A", "RETORNO", cJsonRet)

                oJson    := JsonObject():New()
                xRet     := oJson:FromJson(cJsonRet)

                If ! ValType(xRet) == "U"
                    cMsgError := "N√£o foi poss√≠vel converter a string para objeto json." + xPula + cId + xPula + Alltrim(cValToChar(ZIQ->ZIQ_TOPICO))
                    logZBE("ADFAT31A", "ERRO - xRet", cMsgError, .T.)
                    Help(Nil, Nil, "Fun√ß√£o ADFAT31A(ADFAT031P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                    RestArea(aArea)
                    Return .F.

                EndIf

                If Len(oJson['data']) <= 0
                    logZBE("ADFAT31A", "RETORNO - N√O H¡ DADOS", cJsonRet)
                    RestArea(aArea)
                    Return .T.

                EndIf

                procRet(oJson['data'], @cMsgError)

            EndIf

        Recover
            logZBE("ADFAT31A", "RETORNO - ErrorLog", cMsgError, .T.)

        End Sequence

        FreeObj(oRestClient)
        oRestClient := Nil

    End

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procRet
    Processa retorno.
    @type  Static Function
    @author Everson
    @since 17/02/2022
    @version 01
/*/
Static Function procRet(aDados, cMsgError)

    //Vari√°veis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local oElemento := Nil
    Local cBody     := ""
    Local aRetErro  := {}

    For nAux := 1 To Len(aDados)

        cBody     := ""
        aRetErro  := {}
        oElemento := aDados[nAux]

        If (oElemento['hasError'])
            logZBE("ADFAT031-procRet", "RETORNO - hasError", cJsonRet, .T.)

        Else

            cBody:= ""

            If ! U_ADFAT28A(cBody, @aRetErro)

                If Len(aRetErro) > 0
                    cMsgError := aRetErro[1][2]

                EndIf

                logZBE("ADFAT31A", "RETORNO - U_ADFAT28A", cMsgError, .T.)

            EndIf

        EndIf

    Next nAux

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} logZBE
    Gera log ZBE.
    @type  Static Function
    @author Everson
    @since 17/02/2022
    @version 01
/*/
Static Function logZBE(cLog, cParam, cLogMemo, lErro)
    
    //Vari√°veis.
	Local aArea     := GetArea()
    Local cMessage  := ""
    Local cEmail    := "everson.silva@adoro.com.br"

    Default cLog    := ""
    Default cParam  := ""
    Default cLogMemo:= ""
    Default lErro   := .F.

	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
        Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
        Replace ZBE_DATA 	   	WITH dDataBase
        Replace ZBE_HORA 	   	WITH Time()
        Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
        Replace ZBE_LOG	        WITH cLog
        Replace ZBE_MODULO	    WITH "FATURAMENTO"
        Replace ZBE_ROTINA	    WITH "ADFAT031P" 
        Replace ZBE_PARAME      WITH cParam
        Replace ZBE_LOGMEM      WITH cLogMemo
	ZBE->( MsUnLock())

    If lErro

        cMessage += "cLog: "     + cLog + xPula
        cMessage += "cParam: "   + cParam + xPula
        cMessage += "cLogMemo: " + cLogMemo + xPula

        U_EnviaEmail(GetMv("MV_RELFROM"), cEmail, cMessage, "ERRO - INTEGRA«√O AWS - BARRAMENTO - ADFAT031P","")

    EndIf

	RestArea(aArea)

Return Nil
