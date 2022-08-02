#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"

Static xPula := Chr(13) + Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADVEN059P   º Autor ³ Everson          º Data ³  13/11/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cadastro de promotores.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADVEN059P() // U_ADVEN059P()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	   := GetArea()
	Local oBrowse  := Nil
	Local cFunName := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de promotores.')
	
	ChkFile("ZC4")
	
	SetFunName("ADVEN059P")
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("ZC4")
		oBrowse:SetDescription("Cadastro de Promotor")

		oBrowse:Activate()
		
	SetFunName(cFunName)
	
	RestArea(aArea)
	
Return Nil

Static Function ViewDef()

	Local oModel := ModelDef()
	Local oStruct:= FwFormStruct(2,'ZC4')
	Local oView  := FwFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER',oStruct,'MASTERALIAS')
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView('VIEW_MASTER','TELA')

Return oView

Static Function MenuDef()
	
	//Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADVEN059P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADVEN059P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ADVEN059P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "VIEWDEF.ADVEN059P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Env AWS"      ACTION "U_ADVEN591()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} User Function ADVEN591
	Envia cadastro para o AWS.
	@type  Function
	@author user
	@since 31/07/2022
	@version 01
/*/
User Function ADVEN591()

	//Variáveis.
	Local aArea  	:= GetArea()
	Local cMsgError	:= ""
	Local cUrl   	:= Alltrim(cValToChar(GetMV("MV_#VEN591",,"http://3.23.20.133:8082/api")))
	Local cToken 	:= ""
	Local lReRest	:= .F.
	Local cPrtDe	:= ""
	Local cPrtAte 	:= ""

	If ! Pergunte("ADVEN0591", .T.)
		RestArea(aArea)
		Return Nil

	EndIf

	cPrtDe	:= MV_PAR01
	cPrtAte := MV_PAR02

	MsAguarde({|| lReRest := U_ADVEN592(cUrl, @cToken, @cMsgError) }, "Função ADVEN592(ADVEN059P)", "Efetuando login...")

	If ! lReRest
		MsgInfo("Não foi possível efetuar login " + xPula + cMsgError, "Função ADVEN592(ADVEN059P)")
		RestArea(aArea)
		Return Nil

	EndIf
	
	MsAguarde({|| procEnv(cPrtDe, cPrtAte, cUrl, cToken) }, "Função ADVEN592(ADVEN059P)", "Enviando cadastros...")

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} procEnv
	Processa envio de cadastro.
	@type  Static Function
	@author Everson
	@since 31/07/2022
	@version 01
/*/
Static Function procEnv(cPrtDe, cPrtAte, cUrl, cToken)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cServico	:= ""
	Local cQuery	:= ""
	Local oJson     := Nil
	Local cBody		:= ""
	Local cDefPass  := Alltrim(cValToChar(GetMV("MV_#VEN594",,"123456")))
	Local cCodAWS	:= ""
	Local cMetodo	:= ""
	Local cMsg		:= ""
	Local lRetEnv	:= .F.

	cQuery := ""
	cQuery += " SELECT "
		cQuery += " ZC4_IDAWS, ZC4_NOME, ZC4_EMAIL, ZC4_COD " 
	cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZC4") + " (NOLOCK) AS ZC4 " 
	cQuery += " WHERE " 
		cQuery += " ZC4_FILIAL = '" + FwxFilial("ZC4") + "' " 
		cQuery += " AND ZC4_COD >= '" + cPrtDe + "' " 
		cQuery += " AND ZC4_COD <= '" + cPrtAte + "' " 
		cQuery += " AND ZC4.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY ZC4_COD " 

	If Select("D_PROMOT") > 0
		D_PROMOT->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_PROMOT"
	DbSelectArea("D_PROMOT")
	D_PROMOT->(DbGoTop())

	While ! D_PROMOT->(Eof())

		cCodAWS := Alltrim(cValToChar(D_PROMOT->ZC4_IDAWS))
		
		If Empty(cCodAWS)
			cMetodo := "Post"
			cServico	:= "/users"

		Else
			cMetodo := "Put"
			cServico	:= "/users/" + cCodAWS

		EndIf

		oJson := JsonObject():new()

		oJson['userName']   := Alltrim(cValToChar(D_PROMOT->ZC4_NOME))
		oJson['name'] 		:= Alltrim(cValToChar(D_PROMOT->ZC4_NOME))
		oJson['email'] 		:= Alltrim(cValToChar(D_PROMOT->ZC4_EMAIL))
		oJson['portfolio'] 	:= Alltrim(cValToChar(D_PROMOT->ZC4_COD))

		If cMetodo == "Post"
			oJson['password'] 	:= cDefPass

		EndIf
		
		cBody := oJson:toJSON()

		FreeObj(oJson)
		oJson := Nil

		lRetEnv := U_ADVEN593(cUrl, cServico, cMetodo, cToken, cBody, @cMsg)

        If ! lRetEnv
            U_TExTelaMen("Erro - Promotor " + D_PROMOT->ZC4_COD, cMsg, "Arial",10,,.F.,.F.)
            D_PROMOT->(DbSkip())
            Loop

        ElseIf lRetEnv .And. (cMetodo == "Post" .Or. cMetodo == "Put") 
            tratSucess(cMsg, D_PROMOT->ZC4_COD)

        EndIf

		D_PROMOT->(DbSkip())

	End

	D_PROMOT->(DbCloseArea())

	MsgInfo("Processo finalizado", "Função procEnv(ADVEN059P)")

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} tratSucess
    Grava id da api no cadastro do promotor.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function tratSucess(xMsg, cCodigo)
    
    //Variáveis.
    Local aArea := GetArea()
    Local oJson := JsonObject():new()
    Local cId   := ""

	oJson := JsonObject():new()
	oJson:fromJson(xMsg)

	cId := cValToChar(oJson['_id'])

	FreeObj(oJson)
	oJson := Nil

	DbSelectArea("ZC4")
	ZC4->(DbSetOrder(1))
	ZC4->(DbGoTop())

	If ZC4->(DbSeek( FwxFilial("ZC4") + cCodigo ))

		RecLock("ZC4", .F.)
			ZC4->ZC4_IDAWS := cId
		ZC4->(MsUnlock())

	EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADVEN591
	Efetua login.
	@type  User Function
	@author Everson
	@since 31/07/2022
	@version 01
/*/
User Function ADVEN592(cUrl, cToken, cMsgError)

	//Variáveis.
	Local aArea  	:= GetArea()
	Local lRet   	:= .F.
	Local cServico 	:= "/auth/signin"
	Local cUser  	:= Alltrim(cValToChar(GetMV("MV_#VEN592",,"sistemas@adoro.com.br")))
	Local cPassword := Alltrim(cValToChar(GetMV("MV_#VEN593",,"123456")))
	Local aHeader	:= {}
	Local oJson     := JsonObject():new()
	Local cBody		:= ""
	Local cMsg		:= ""
	Local lRest		:= .F.
	
	Default cToken	:= ""

	Aadd(aHeader, "Content-Type: application/json")
	
	oJson['email']    := cUser
	oJson['password'] := cPassword

	cBody := oJson:toJSON()

	FreeObj(oJson)
	oJson := Nil

	oRestClient := FWRest():New(cUrl)
	oRestClient:setPath(cServico)

	oRestClient:SetPostParams(cBody)
	lRest := oRestClient:Post(aHeader)

	If ! lRest
		cMsgError := Alltrim(cValToChar(oRestClient:GetLastError())) + xPula + Alltrim(cValToChar(oRestClient:GetResult()))
		
	Else
		lRet := .T.
		cMsg := Alltrim(cValToChar(oRestClient:GetResult()))

		oJson := JsonObject():new()
        oJson:fromJson(cMsg)

		cToken := oJson['accessToken']

		FreeObj(oJson)
		oJson := Nil

	EndIf

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADVEN593
    Envia requisição.
    @type  User Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVEN593(cUrl, cServico, cMetodo, cToken, cBodyRq, cMsg)

    //Variáveis.
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local oRestClient 	:= Nil
	Local lRest			:= .F.

    Private aHeader	:= {}
    Private cBody       := cBodyRq

	Default cServico	:= ""
	Default cBody		:= ""
	Default cMsg		:= ""
	Default aResponse	:= {}

    Aadd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "x-access-token: " + cToken)

	oRestClient := FWRest():New(cUrl)
	oRestClient:setPath(cServico)

    If cMetodo == "Post"
        oRestClient:SetPostParams(cBody)
        lRest := oRestClient:Post(aHeader)

    ElseIf cMetodo == "Put"
        lRest := oRestClient:Put(aHeader, cBody)

    Endif

	cMsg := ""

	If ! lRest

		If Substr(Alltrim(cValToChar(oRestClient:GetLastError())),1,1) <> "2" 

			cMsg := Alltrim(cValToChar(oRestClient:GetLastError())) + Chr(13) + Chr(10)
			cMsg += "URL: "      + cUrl + Chr(13) + Chr(10)
			cMsg += "EndPoint: " + cServico + Chr(13) + Chr(10)
			cMsg += "Método: "   + cMetodo + Chr(13) + Chr(10)
			cMsg += "Body: "     + Chr(13) + Chr(10) + cValToChar(cBody) + Chr(13) + Chr(10)
			cMsg += "Resp: "     + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetResult())) + Chr(13) + Chr(10)
			lRet := .F.

		EndIf

	EndIf
	
	If lRet 
        cMsg := Alltrim(cValToChar(oRestClient:GetResult()))

	EndIf

	FreeObj(oRestClient)
	oRestClient := Nil
	RestArea(aArea)

Return lRet
