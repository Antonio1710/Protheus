#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZHX"
Static cTitulo := "Visita Esporádica Promotor"
Static cTiMast := "Dados da visita esporádica promotor"

Static xPula := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADVEN109P
    Visita Esporadica Promotor
    @type  Function
    @author Everson
    @since 31/07/2022
    /*/
User Function ADVEN109P() // U_ADVEN109P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADVEN109P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADVEN109P")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

    oBrowse:AddLegend("ZHX_STATUS = '1'", "BR_VERDE"    , "Aguardando")
	oBrowse:AddLegend("ZHX_STATUS = '2'", "BR_VERMELHO" , "Programada")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADVEN109P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADVEN109P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADVN1093(4)" 	    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "U_ADVN1093(5)" 	    OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADVN1091()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} User Function ADVN1093
    Alteração e exclusão.
    @type  Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1093(nOPc)

    //Variáveis.
    Local aArea := GetArea()

    If ZHX->ZHX_STATUS <> "1"
        MsgInfo("Ação não permitida, programação realizada.", "Função ADVN1093(ADVEN109P)")
        RestArea(aArea)
        Return Nil

    EndIf
    
    FWExecView("", "ADVEN109P", nOPc)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| .T. }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADVN109", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADVEN109P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT18A
    Integra registros de visitas.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1091()

    //Variáveis.
    Local aArea     := GetArea()
    Local lReRest   := .F.
    Local cUrl      := Alltrim(cValToChar(GetMV("MV_#VEN591",,"http://3.23.20.133:8082/api")))
    Local cToken    := ""
    Local cMsgError := ""
    Local cQuery    := ""
    Local data      := ""
    Local portfolio := ""
    Local cCliente  := ""
    Local cLoja     := ""
    Local cTopico   := ""
    Local cTipo     := ""
    Local cHInicio  := ""
    Local cHFim     := ""

    MsAguarde({|| lReRest := U_ADVEN592(cUrl, @cToken, @cMsgError) }, "Função ADVN1091(ADVEN109P)", "Efetuando login...")

	If ! lReRest
		MsgInfo("Não foi possível efetuar login " + xPula + cMsgError, "Função ADVN1091(ADVEN109P)")
		RestArea(aArea)
		Return Nil

	EndIf

    cQuery := ""
    cQuery += " SELECT *  " 
    cQuery += " FROM " + RetSqlName("ZHX") + " (NOLOCK) AS ZHX " 
    cQuery += " WHERE " 
        cQuery += " ZHX_FILIAL = '" + FWxFilial("ZHX") + "' " 
        cQuery += " AND ZHX_STATUS = '1' " 
        cQuery += " AND CAST(ZHX_DATAIN AS DATE) BETWEEN CAST(GETDATE() AS DATE) AND CAST(GETDATE() +1 AS DATE) " 
    cQuery += " ORDER BY ZHX_NUMERO " 

	If Select("D_VISESP") > 0
		D_VISESP->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_VISESP"
	DbSelectArea("D_VISESP")
	D_VISESP->(DbGoTop())

    While ! D_VISESP->(Eof())

        data      := SubStr(D_VISESP->ZHX_DATAIN, 1, 4) + "-" + Padl(SubStr(D_VISESP->ZHX_DATAIN, 5, 2), 2, "0") + "-" + Padl(SubStr(D_VISESP->ZHX_DATAIN, 8, 2), 2, "0")
        portfolio := Alltrim(cValToChar(D_VISESP->ZHX_PROMOT))
        cCliente  := Alltrim(cValToChar(D_VISESP->ZHX_CLIENT))
        cLoja     := Alltrim(cValToChar(D_VISESP->ZHX_LOJA))
        cTopico   := "Visita Esporádica"
        cTipo     := "sporadic"
        cHInicio  := Padl(Alltrim(cValToChar(D_VISESP->ZHX_HORARI)), 2, "0") + ":00" 
        cHFim     := Padl(Alltrim(cValToChar(Val(D_VISESP->ZHX_HORARI)+1)), 2, "0") + ":00" 

        MsAguarde({|| U_ADVN1092(.T., cUrl, cToken,;
                                 data, portfolio, cCliente, cLoja, cTopico, cTipo, cHInicio, cHFim) }, "Função ADVN1091(ADVEN109P)", "Enviando visitas...")

        D_VISESP->(DbSkip())

	End

	D_VISESP->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADVN1092
	Processa envio de visita.
	@type  Static Function
	@author Everson
	@since 31/07/2022
	@version 01
/*/
User Function ADVN1092(lTSucess, cUrl, cToken,;
                       data, portfolio, cCliente, cLoja, cTopico, cTipo, cHInicio, cHFim)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cBody		:= ""
	Local cMsg		:= ""
	Local lRetEnv	:= .F.
    Local cMetodo   := "Post"
    Local cServico  := "/events"
	Local oJson     := Nil
    Local oEnderec  := Nil
    Local oContato  := Nil
    Local cQuery    := ""
    Local aProdutos := {}
    Local oProduto  := Nil
    Local cEnd      := ""
    Local cNumero   := ""
    Local cPosVirg  := 0

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())
    SA1->(DbSeek( FWxFilial("SA1") + cCliente + cLoja ))

    oJson    := JsonObject():new()
    oEnderec := JsonObject():new()
    oContato := JsonObject():new()

    oJson['date']       := data
    oJson['portfolio']  := portfolio
    oJson['sa1'] 		:= cCliente + cLoja
    oJson['name']       := Alltrim(cValToChar(SA1->A1_NOME))

        cPosVirg :=  At(",", Alltrim(cValToChar(SA1->A1_END)))
        
        If cPosVirg > 0
            cEnd    := Substr(Alltrim(cValToChar(SA1->A1_END)), 1, cPosVirg -1)
            cNumero := Substr(Alltrim(cValToChar(SA1->A1_END)), cPosVirg + 1, 1000)

        EndIf

        oEnderec['city']     := Alltrim(cValToChar(SA1->A1_MUN))
        oEnderec['country']  := "Brasil"
        oEnderec['district'] := Alltrim(cValToChar(SA1->A1_BAIRRO))
        oEnderec['isoCountryCode'] := "BR"
        oEnderec['region'] := Alltrim(cValToChar(SA1->A1_EST))
        oEnderec['street'] := Iif(Empty(cEnd), Alltrim(cValToChar(SA1->A1_END)), cEnd)
        oEnderec['streetNumber'] := cNumero
 
    oJson['address'] 	:= oEnderec

        oContato['name'] := Alltrim(cValToChar(SA1->A1_CONTATO))
        oContato['email'] := Alltrim(cValToChar(SA1->A1_EMAICO))
        oContato['phone'] := Alltrim(cValToChar(SA1->A1_DDD)) + Alltrim(cValToChar(SA1->A1_TEL))
        oContato['celPhone'] := Alltrim(cValToChar(SA1->A1_TEL5))

    oJson['contact'] := oContato

    If !Empty(SA1->A1_XLATITU) .And. !Empty(SA1->A1_XLONGIT)
        oJson['latitude']  := Alltrim(cValToChar(SA1->A1_XLATITU))
        oJson['longitude'] := Alltrim(cValToChar(SA1->A1_XLONGIT))

    EndIf

    oJson['category']  := ""
    oJson['startTime'] := cHInicio
    oJson['endTime']   := cHFim
    oJson['topic']     := cTopico
    oJson['type']      := cTipo

    cQuery := ""
    cQuery += " SELECT  " 
        cQuery += " ZHT_PRODUT, " 
        cQuery += " ZHT_DESC " 
    cQuery += " FROM  " 
        cQuery += " " + RetSqlName("ZHT") + " (NOLOCK) AS ZHT " 
    cQuery += " WHERE " 
        cQuery += " ZHT_FILIAL = '" + FWxFilial("ZHT") + "' " 
        cQuery += " AND ZHT.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZHT_ITEM " 

    If Select("D_PRODF") > 0
        D_PRODF->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PRODF"
    DbSelectArea("D_PRODF")
    D_PRODF->(DbGoTop())

    While ! D_PRODF->(Eof())

        oProduto := JsonObject():new()
        oProduto['code'] := Alltrim(cValToChar(D_PRODF->ZHT_PRODUT))
        oProduto['name'] := Alltrim(cValToChar(D_PRODF->ZHT_DESC))

        Aadd(aProdutos, oProduto)

        D_PRODF->(DbSkip())

    End

    D_PRODF->(DbCloseArea())

    oJson['products']  := aProdutos

    cBody := EncodeUTF8(oJson:toJSON())

    FreeObj(oJson)
    oJson := Nil

    FreeObj(oEnderec)
    oEnderec := Nil

    FreeObj(oContato)
    oContato := Nil

    FreeObj(oProduto)
    oProduto := Nil

    If Len(aProdutos) <= 0
        MsgInfo("Cliente " + cCliente + cLoja + " " +  Alltrim(cValToChar(SA1->A1_NOME)) + " não possui cadastro de produtos foco.", "Função U_ADVN1092(ADVEN109P)")
        RestArea(aArea)
        Return Nil

    EndIf

    lRetEnv := U_ADVEN593(cUrl, cServico, cMetodo, cToken, cBody, @cMsg)

    If ! lRetEnv
        U_TExTelaMen("Erro - Visita Esporádica " + D_VISESP->ZHX_NUMERO, cMsg, "Arial",10,,.F.,.F.)

    Else

        If lTSucess
            tratSucess(D_VISESP->ZHX_NUMERO)

        EndIf

    EndIf

	MsgInfo("Processo finalizado", "Função U_ADVN1092(ADVEN109P)")

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} tratSucess
    Marca visita como agendada.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function tratSucess(cCodigo)
    
    //Variáveis.
    Local aArea := GetArea()

	DbSelectArea("ZHX")
	ZHX->(DbSetOrder(1))
	ZHX->(DbGoTop())

	If ZHX->(DbSeek( FwxFilial("ZHX") + cCodigo ))

		RecLock("ZHX", .F.)
			ZHX->ZHX_STATUS := "2"
		ZHX->(MsUnlock())

	EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT18A
    Job para integrar registros de visitas.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1094() // U_ADVN1094()

    RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        U_ADVN1091()

	RpcClearEnv()

Return Nil
