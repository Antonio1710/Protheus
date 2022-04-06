#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

Static xPula :=  Chr(13) + Chr(10) 

/*/{Protheus.doc} ADFAT030P
    Job para envio de dados para o barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/02/2022
    @version 01
    /*/
User Function ADFAT030P() // U_ADFAT030P()

    //Variáveis.
    // Local cEmp := ""
    // Local cFil := ""

	RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })

        U_ADFAT30A()

    RpcClearEnv()

Return Nil
/*/{Protheus.doc} ADFAT30A
    Executa processamento pendente.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/02/2022
    @version 01
    /*/
User Function ADFAT30A()

    //Variáveis.
    Local aArea         := GetArea()
    Local cAliasAux     := GetNextAlias()
    Local cQuery        := ""
    Local cMsgError     := ""
    Local cJson         := ""
    Local cId           := ""
    Local cUrl          := "https://4icniy3gqa.execute-api.us-east-2.amazonaws.com"
    Local cKey          := "7PZkSJom027jDIpTVfOrp77WyLieDbi26O0rEL5K"
    Local cArn          := "arn:aws:sns:us-east-2:025477848976:"
    Local oRestClient   := Nil
    Local aCabecalho    := {}
    Local oJson         := Nil
    Local xRet          := Nil
    Local cJsonRet      := ""

    cQuery += " SELECT  " 
    cQuery += " ZIQ_UUID, "
    cQuery += " ZIQ_OPERAC, "
    cQuery += " R_E_C_N_O_ AS RECNO "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIQ") + " (NOLOCK) AS ZIQ  " 
    cQuery += " WHERE  " 
    cQuery += " ZIQ_FILIAL = '" + FWxFilial("ZIM") + "'  " 
    cQuery += " AND ZIQ_TIPO = 'S' "  
    cQuery += " AND ZIQ_PROCES = '2' OR (ZIQ_PROCES = '1' AND ZIQ_STATPR = '2') " 
    cQuery += " AND ZIQ.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY RECNO " 

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAux, .F., .T.)
    (cAliasAux)->(DbGoTop())

    oRestClient := FWRest():New(cUrl)
    oRestClient:SetPath("/test/barramento")

    While ! (cAliasAux)->(Eof())

        ZIQ->(DbGoto((cAliasAux)->RECNO))
        
        cId   := Alltrim(cValToChar(ZIQ->ZIQ_UUID))
        cJson := Alltrim(cValToChar(ZIQ->ZIQ_DADOS))

        oRestClient:SetPostParams(cJson)

        aCabecalho := {}
        Aadd(aCabecalho, "Content-Type: application/json")
        Aadd(aCabecalho, "x-api-key: " + cKey)
        Aadd(aCabecalho, "TopicArn: " + cArn + Alltrim(cValToChar(ZIQ->ZIQ_TOPICO)))

        If ! oRestClient:Post(aCabecalho)
            cMsgError := Alltrim(cValToChar(oRestClient:GetLastError()))
            procResult(cId, "2", cMsgError)
            Help(Nil, Nil, "Função ADFAT30A(ADFAT030P)", Nil, "Erro no envio do registro." + xPula + cId + xPula + Alltrim(cValToChar(ZIQ->ZIQ_TOPICO)) + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        Else
            cJsonRet := oRestClient:GetResult()
            oJson    := JsonObject():New()
            xRet     := oJson:FromJson(cJsonRet)

            If ! ValType(xRet) == "U"
                cMsgError := "Não foi possível converter a string para objeto json." + xPula + cId + xPula + Alltrim(cValToChar(ZIQ->ZIQ_TOPICO))
                procResult(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT30A(ADFAT030P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cAliasAux)->(DbSkip())
                Loop

            EndIf

            cMsgError := Alltrim(cValToChar(oJson['Error']))

            If ! Empty(cMsgError)
                procResult(cId, "2", cJsonRet)

            Else
                procResult(cId, "1", cJsonRet)

            EndIf

        EndIf

        (cAliasAux)->(DbSkip())

    End

    (cAliasAux)->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procResult
    Salva resultado do processamento no registro do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
Static Function procResult(cId, cResult, cObserv)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))
    If ! ZIQ->(DbSeek( FWxFilial("ZIQ") + cId ))
        U_GrLogZBE (;
            Date(),;
            Time(),;
            cUserName,;
            "procResult - Id não encontrado " + cId,;
            "FATURAMENTO",;
            "ADFAT029P",;
            cId,;
            ComputerName(),;
            LogUserName();
        )

        RestArea(aArea)
        Return Nil

    EndIf

    oModel := FwLoadModel("ADFAT027P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)

    oModel:Activate()

    oModel:SetValue("MD_MASTER", "ZIQ_PROCES", "1")
    oModel:SetValue("MD_MASTER", "ZIQ_DTPROC", Date())
    oModel:SetValue("MD_MASTER", "ZIQ_HRPROC", Time())
    oModel:SetValue("MD_MASTER", "ZIQ_STATPR", cResult)
    oModel:SetValue("MD_MASTER", "ZIQ_OBS", cObserv)

    If oModel:VldData()
        oModel:CommitData()
        lRet := .T.

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função procResult(ADFAT029P)", Nil, "Erro na atualização de registro de barramento " + cId + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return Nil
