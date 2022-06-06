#Include "Protheus.ch"
#Include "Restful.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADFAT028P
    Api Rest para integração de dados do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/02/2022
    @version 01
    @history, Everson, 06/06/2022, ticket 18645 - tratamento para reclock.
/*/
User Function ADFAT028P()                                    
Return Nil

WsRestFul barramento Description "Serviço REST para inclusão de registros vindos do barramento."

	WsMethod Post Description "Inclui de registros vindos do barramento."    WsSyntax "/registros"
	WsMethod Get  Description "Obtém registros não enviados ao barramento."  WsSyntax "/registros"
	WsMethod Put  Description "Marca registro como já processado"            WsSyntax "/registros/{uuid}"

End WsRestFul
/*/{Protheus.doc} User Function Post
	Método Post
	@type  Function
	@author Everson
	@since 10/02/2022
	@version 01
/*/
WsMethod Post WsService barramento

    //Variáveis.
    Local lRet      := .F.
    Local cBody     := Self:GetContent()
    Local aRetErro  := {}
    Local nCodErro  := 0
    Local cMsgErro  := ""

    logZBE("Início POST", "", cBody)

    Self:SetContentType("application/json")

    lRet := U_ADFAT28A(cBody, @aRetErro)

    If ! lRet .Or. Len(aRetErro) > 0
        nCodErro := aRetErro[1][1]
        cMsgErro := aRetErro[1][2]
        SetRestFault(nCodErro,EncodeUtf8(cMsgErro))
        Return .F.

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT28A
    Processa requisições Post.
    @type  Static Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
User Function ADFAT28A(cBody, aRetErro)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    Local cMsgError := ""
    Local cEmpOrg   := ""
    Local cFilOrg   := ""
    Local cDtOrig   := ""
    Local cHrOrig   := ""
    Local cOperacao := ""
    Local cSisGer   := ""
    Local cTopico   := ""
    Local cId       := ""
    Local cDados    := ""
    Local oJson     := Nil
    Local xRet      := Nil
    Local cHash     := ""

    oJson := JsonObject():New()

    xRet  := oJson:FromJson(cBody)

    If ! ValType(xRet) == "U"
        cMsgError := "Não foi possível converter a string json para objeto json."
        logZBE("ADFAT28A", cMsgError, cBody)
        Aadd(aRetErro, {400, cMsgError})
        RestArea(aArea)
        Return .F.

    EndIf

    cId := Alltrim(cValToChar(oJson['uuid']))

    If Empty(cId)
        cMsgError := "Não foi possível obter o uuid."
        logZBE("ADFAT28A", cMsgError, cBody)
        Aadd(aRetErro, {400, cMsgError})
        RestArea(aArea)
        Return .F.

    EndIf

    DbselectArea("ZIQ")
    ZIQ->(DbSetOrder(1))
    If ZIQ->( DbSeek(FWxFilial("ZIQ") + cId) )
        cMsgError := "Id " + cId + " já recebido."
        logZBE("ADFAT28A", cMsgError, cBody)
        Aadd(aRetErro, {400, cMsgError})
        RestArea(aArea)
        Return .F.

    EndIf

    cEmpOrg     := Alltrim(cValToChar(oJson['empresa']))
    cFilOrg     := Alltrim(cValToChar(oJson['filial']))
    cDtOrig     := Alltrim(cValToChar(oJson['data']))
    cHrOrig     := Alltrim(cValToChar(oJson['hora']))
    cOperacao   := Alltrim(cValToChar(oJson['operacao']))
    cSisGer     := Alltrim(cValToChar(oJson['sistGera']))
    cTopico     := Alltrim(cValToChar(oJson['topico']))
    cDados      := Alltrim(cValToChar(cBody))
    cHash       := SHA1(cEmpOrg + cFilOrg + cDtOrig + cHrOrig + Alltrim(cValToChar(oJson['dados'])))

    DbselectArea("ZIQ")
    ZIQ->(DbSetOrder(2))
    If ZIQ->( DbSeek(FWxFilial("ZIQ") + cHash) )
        cMsgError := "Hash " + cHash + " já recebido."
        logZBE("ADFAT28A", cMsgError, cBody)
        Aadd(aRetErro, {400, cMsgError})
        FreeObj(oJson)
        oJson := Nil
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT027P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("MD_MASTER", "ZIQ_TIPO"  , "E")
    oModel:SetValue("MD_MASTER", "ZIQ_EMPRES", cEmpOrg)
    oModel:SetValue("MD_MASTER", "ZIQ_FILINT", cFilOrg)
    oModel:SetValue("MD_MASTER", "ZIQ_OPERAC", cOperacao)
    oModel:SetValue("MD_MASTER", "ZIQ_DTORIG", SToD(cDtOrig))
    oModel:SetValue("MD_MASTER", "ZIQ_HRORIG", cHrOrig)
    oModel:SetValue("MD_MASTER", "ZIQ_DTGRV" , Date())
    oModel:SetValue("MD_MASTER", "ZIQ_HRGRV" , Time())
    oModel:SetValue("MD_MASTER", "ZIQ_SISGER", cSisGer)
    oModel:SetValue("MD_MASTER", "ZIQ_TOPICO", cTopico)
    oModel:SetValue("MD_MASTER", "ZIQ_UUID"  , cId)
    oModel:SetValue("MD_MASTER", "ZIQ_DADOS" , cDados)
    oModel:SetValue("MD_MASTER", "ZIQ_PROCES", "2")
    oModel:SetValue("MD_MASTER", "ZIQ_HASH"  , cHash)

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
        Aadd(aRetErro, {400, cMsgError})

    EndIf

    FreeObj(oJson)
    oJson := Nil
        
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function Get
	Método Get
	@type  Function
	@author Everson
	@since 14/03/2022
	@version 01
/*/
WsMethod Get WsService barramento

    //Variáveis.
    Local lRet      := .F.
    Local cJson     := ""

    logZBE("Início GET", "", "")

    Self:SetContentType("application/json")

    lRet := U_ADFAT28B(@cJson)

    Self:SetResponse(cJson)

Return lRet
/*/{Protheus.doc} ADFAT28B
    Obtém registros de saída faltantes de processamento.
    @type  Static Function
    @author Everson
    @since 14/03/2022
    @version 01
/*/
User Function ADFAT28B(cJson)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local aDados    := {}
    Local oJsonLn   := Nil
    Local oJson     := Nil
    Local cQuery    := " SELECT R_E_C_N_O_ AS RECNO FROM " + RetSqlName("ZIQ") + " (NOLOCK) AS ZIQ WHERE ZIQ_FILIAL = '" + FWxFilial("ZIQ") + "' AND ZIQ_TIPO = 'S' AND ZIQ_PROCES = '2' AND ZIQ.D_E_L_E_T_ = '' ORDER BY ZIQ_DTGRV, ZIQ_HRGRV, R_E_C_N_O_ "

    If Select("D_ZIQS") > 0
        D_ZIQS->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ZIQS"
    DbSelectArea("D_ZIQS")
    D_ZIQS->(DbGoTop())
    If D_ZIQS->(Eof())
        cJson := "[]"
        D_ZIQS->(DbCloseArea())
        RestArea(aArea)
        Return .T.
    EndIf

    oJson := JsonObject():New()

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))
    ZIQ->(DbGoTop())

    While ! D_ZIQS->(Eof())

        ZIQ->(DbGoTo(D_ZIQS->RECNO))

        oJsonLn := JsonObject():New()
        oJsonLn:FromJSON( ZIQ->ZIQ_DADOS )

        Aadd(aDados, oJsonLn)

        FreeObj(oJsonLn)
        oJsonLn := Nil

        D_ZIQS->(Dbskip())

    End

    oJson["dados"] := aDados

    cJson := oJson:toJSON()

    FreeObj(oJson)
    oJson := Nil

    lRet := .T.

    D_ZIQS->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function Get
	Método Get
	@type  Function
	@author Everson
	@since 14/03/2022
	@version 01
/*/
WsMethod Put WsService barramento

    //Variáveis.
    Local lRet          := .F.
    Local aRetErro      := {}
    Local nCodErro      := 0
    Local cMsgErro      := ""
    Local aParametros	:= Self:aURLParms

    logZBE("Início PUT", "", "")

    Self:SetContentType("application/json")

    Sleep(Random(0, 7)*1000) //Everson - 06/06/2022.

    lRet := U_ADFAT28C(aParametros, @aRetErro)

    If ! lRet .Or. Len(aRetErro) > 0
        nCodErro := aRetErro[1][1]
        cMsgErro := aRetErro[1][2]
        SetRestFault(nCodErro,EncodeUtf8(cMsgErro))
        Return .F.

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT28B
    Marca registro como já processado.
    @type  Static Function
    @author Everson
    @since 14/03/2022
    @version 01
/*/
User Function ADFAT28C(aParametros, aRetErro)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cUuid     := ""
    Local cMsgError := ""

    If Len(aParametros) == 0
        Aadd(aRetErro, {400, EncodeUtf8("Necessário informar o uuid do registro.")})
        RestArea(aArea)
        Return .F.

    EndIf

    cUuid := Alltrim(cValToChar(aParametros[2]))

    If ! U_ADFAT29D(cUuid, "1", "", @cMsgError)
        Aadd(aRetErro, {400, cMsgError})

    Else
        lRet := .T.

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} logZBE
    Gera log ZBE.
    @type  Static Function
    @author Everson
    @since 15/02/2022
    @version 01
/*/
Static Function logZBE(cLog, cParam, cLogMemo)
    
    //Variáveis.
	Local aArea := GetArea()

    Default cLog    := ""
    Default cParam  := ""
    Default cLogMemo:= ""

	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
        Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
        Replace ZBE_DATA 	   	WITH dDataBase
        Replace ZBE_HORA 	   	WITH Time()
        Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
        Replace ZBE_LOG	        WITH cLog
        Replace ZBE_MODULO	    WITH "FATURAMENTO"
        Replace ZBE_ROTINA	    WITH "ADFAT028P" 
        Replace ZBE_PARAME      WITH cParam
        Replace ZBE_LOGMEM      WITH cLogMemo
	ZBE->( MsUnLock())

	RestArea(aArea)

Return Nil
