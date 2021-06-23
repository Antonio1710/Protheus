#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"

//Variáveis Estáticas.
Static cTitulo := 'Produtos com exceção de desconto'

/*/{Protheus.doc} User ADVEN060P
	(Produtos com exceção de desconto)
	@type  Function
	@author Everson
	@since 29/11/17
	@version 01
	/*/

User Function ADVEN060P() // U_ADVEN060P()

	// Declaração de variáveis.
	Local aArea	   := GetArea()
	Local oBrowse  := Nil
	Local cFunName := FunName()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Produtos com exceção de desconto')

	ChkFile("ZC5")

	SetFunName("ADVEN060P")

	DbSelectArea("ZC5")
	ZC5->(DbSetOrder(1))
	ZC5->(DbGoTop())
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZC5")
	oBrowse:SetDescription(cTitulo)

	oBrowse:Activate()

	SetFunName(cFunName)

	RestArea(aArea)

Return Nil

Static Function ModelDef()

	// Declaração de variáveis.
	Local oModel := Nil
	Local oStruct:= FwFormStruct(1,'ZC5')

	oModel:= MpFormModel():New('_VEN060P',Nil)
	oModel:AddFields('MASTERALIAS',Nil,oStruct)
	oModel:SetDescription(cTitulo)
	oModel:GetModel('MASTERALIAS'):SetDescription(cTitulo)

	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()

	// Declaração de variáveis.
	Local oModel := ModelDef()
	Local oStruct:= FwFormStruct(2,'ZC5')
	Local oView  := FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER',oStruct,'MASTERALIAS')
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView('VIEW_MASTER','TELA')

Return oView

Static Function MenuDef()	

	Local aRotina 		:= {}

	ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.ADVEN060P' OPERATION 2  ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.ADVEN060P' OPERATION 3  ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.ADVEN060P' OPERATION 4  ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.ADVEN060P' OPERATION 5  ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.ADVEN060P' OPERATION 8  ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.ADVEN060P' OPERATION 9  ACCESS 0
	ADD OPTION aRotina Title 'Env. SF'     Action 'U_exDCSfExp()'     OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Imp. CSV'    Action 'U_exDCSCSV()'      OPERATION 11 ACCESS 0

Return aRotina

/*/{Protheus.doc} User Function exDCSfExp
	(Exporta dados para o Sales Force)
	@type  Function
	@author Everson
	@since 29/11/17
	@version 01
	/*/
User Function exDCSfExp()

	//Declaração de variáveis.
	Local aArea		:= GetArea()
	Local cCodLoja	:= ""

	U_ADINF009P('ADVEN060P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Produtos com exceção de desconto')
	
	cCodLoja := Alltrim(cValToChar(ZC5->ZC5_CODCLI)) + Alltrim(cValToChar(ZC5->ZC5_LOJA))

	//
	If ! MsgYesNo("Deseja enviar o contrato do cliente " + cCodLoja + " para o Sales Force?","Função sfExportar")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If FindFunction("U_ADVEN055P")
		U_ADVEN055P(cCodLoja,.F.,"") 
		
	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} User Function exDCSCSV
	(Ponto de entrada para envio de inserção/alteração. SalesForce)
	@type  Function
	@author Everson
	@since 30/01/2018
	@version 01
	/*/

User Function  exDCSCSV()

	// Declaração de variáveis.
	Local aArea := GetArea()
	Local cArq	:= ""

	U_ADINF009P('ADVEN060P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Produtos com exceção de desconto')
	
	//
	cArq	:= cGetFile("Arquivo CSV|*.*", "Selecione o arquivo CSV com os grupos de compra.",,'C:\',.T., GETF_LOCALHARD + GETF_NETWORKDRIVE)
	cArq	:= Alltrim(cValToChar(cArq))

	//
	If Empty(cArq)
		RestArea(aArea)
		Return Nil

	EndIf
		
	//
	Processa({|| processar(cArq) },"Lendo arquivo...")

	//
	MsgInfo("Arquivo processado.","Função ADVEN060P")
	
	//
	RestArea(aArea)	
	
Return Nil
/*/{Protheus.doc} Static Function processar
	(Processa arquivo CSV)
	@type  Function
	@author Everson
	@since 22/11/2017
	@version 01
	@history Leon	- 17/01/2020.Chamado 054956.Alteração no calculo de divisão das variáveis ZC5, retirado /100.
	/*/
Static Function processar(cArq)
	
	//Declaração de variáveis
	Local aArea			:= GetArea()
	Local nHdl			:= 0
	Local nTotLinhas	:= 0
	Local aLinha		:= {}
	Local cBuffer		:= ""
	Local nLinha		:= 0

	Local cCodCli		:= ""
	Local cLojaCli		:= ""
	Local cProduto		:= ""
	Local cForneci		:= ""
	Local cCresci	    := ""			
	Local cAniver	    := ""
	Local cInaugu	    := ""
	Local cReinau	    := ""													
	Local cLog	    	:= ""		
	Local cQueTroc		:= ""
	Local cVerbaInv		:= ""								
	Local cWeb	    	:= ""
	Local cAssoc	    := ""
		
	//Abre o Arquivo.
	nHdl := FT_FUse(cArq) 

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq + ".","Função ADVEN060P")
		Return Nil

	EndIf

	//
	FT_FGoTop()

	//
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da régua.
	ProcRegua(nTotLinhas)

	//
	FT_FEof()
	nLinha := 0
	While ! FT_FEof()

		nLinha++

		cBuffer:= DecodeUTF8(FT_FReadln())

		aLinha	:= StrToKarr(cBuffer,";")

		//
		If Len(aLinha) <> 14
			MsgStop("Por favor, reveja o arquivo CSV, pois o total de campos por linha deve ser igual a 14, mas a linha " + cValToChar(nLinha) + " está com " + cValToChar(Len(aLinha)) + " campo(s).","Função ADVEN060P")
			RestArea(aArea)	
			Return Nil

		EndIf

		//
		cCodCli		:= Alltrim(cValToChar(aLinha[1]))
		cLojaCli	:= Alltrim(cValToChar(aLinha[2]))
		cProduto	:= Alltrim(cValToChar(aLinha[3]))
		
		//Leon Toledo - Chamado 054956 - 17/01/2020
		cForneci	:= Val(Alltrim(cValToChar(aLinha[5])))
		cCresci	    := Val(Alltrim(cValToChar(aLinha[6])))
		cAniver	    := Val(Alltrim(cValToChar(aLinha[7])))
		cInaugu	    := Val(Alltrim(cValToChar(aLinha[8])))
		cReinau	    := Val(Alltrim(cValToChar(aLinha[9])))
		cLog	    := Val(Alltrim(cValToChar(aLinha[10])))
		cQueTroc	:= Val(Alltrim(cValToChar(aLinha[11])))
		cVerbaInv	:= Val(Alltrim(cValToChar(aLinha[12])))
		cWeb	    := Val(Alltrim(cValToChar(aLinha[13])))
		cAssoc	    := Val(Alltrim(cValToChar(aLinha[14])))

		IncProc("Processando cliente | " + cCodCli + "/" + cLojaCli + " | " + cProduto)

		//
		DbSelectArea("ZC5")
		ZC5->(DbSetOrder(1))
		ZC5->(DbGoTop())
		If ! ZC5->( DbSeek(xFilial("ZC5") + cCodCli + cLojaCli + cProduto ) )
			
			RecLock("ZC5",.T.)
				ZC5->ZC5_FILIAL := xFilial("ZC5")
				ZC5->ZC5_CODCLI := cCodCli
				ZC5->ZC5_LOJA   := cLojaCli
				ZC5->ZC5_PRODUT := cProduto
				ZC5->ZC5_ANIVER := cAniver
				ZC5->ZC5_INAUGU := cInaugu
				ZC5->ZC5_FORNEC := cForneci
				ZC5->ZC5_LOGIST := cLog
				ZC5->ZC5_REINAU := cReinau
				ZC5->ZC5_QBRTRC := cQueTroc
				ZC5->ZC5_ASSOCI := cAssoc
				ZC5->ZC5_CRESCI := cCresci
				ZC5->ZC5_INVCOO := cVerbaInv
				ZC5->ZC5_WEB    := cWeb
			ZC5->(MsUnlock())
			
		Else
			
			RecLock("ZC5",.F.)
				ZC5->ZC5_PRODUT := cProduto
				ZC5->ZC5_ANIVER := cAniver
				ZC5->ZC5_INAUGU := cInaugu
				ZC5->ZC5_FORNEC := cForneci
				ZC5->ZC5_LOGIST := cLog
				ZC5->ZC5_REINAU := cReinau
				ZC5->ZC5_QBRTRC := cQueTroc
				ZC5->ZC5_ASSOCI := cAssoc
				ZC5->ZC5_CRESCI := cCresci
				ZC5->ZC5_INVCOO := cVerbaInv
				ZC5->ZC5_WEB    := cWeb
			ZC5->(MsUnlock())			
			
		EndIf
		
		//
		DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE->ZBE_FILIAL 	WITH xFilial("ZBE")
			Replace ZBE->ZBE_DATA 	   	WITH dDataBase
			Replace ZBE->ZBE_HORA 	   	WITH Time()
			Replace ZBE->ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
			Replace ZBE->ZBE_LOG	    WITH ("Alteração de exceção de desconto comercial (ZC5)")
			Replace ZBE->ZBE_MODULO	    WITH "COMERCIAL"
			Replace ZBE->ZBE_ROTINA	    WITH "ADVEN060P" 
			Replace ZBE->ZBE_PARAME     WITH ("CLIENTE:" + cCodCli + "-" + cLojaCli + " PRODUTO: " + cProduto )
		ZBE->( MsUnLock())
		
		//Envio para o SalesForce.
		If FindFunction("U_ADVEN055P")
			U_ADVEN055P(cCodCli + cLojaCli,.F.,"")  
		
		EndIf
		
		FT_FSkip()

	EndDo
	
	//
	FT_FUse(cArq) 
	
	//
	MsgInfo("Importação finalizada.","Função ADVEN060P")

	//
	RestArea(aArea)		

Return Nil

/*/{Protheus.doc} User Function _VEN060P
	(Ponto de entrada para envio de inserção/alteração. SalesForce Chamado 037261)
	@type  Function
	@author Everson
	@since 30/01/2018
	@version 01
	/*/
	
User Function _VEN060P()

	//³ Declaração de variáveis.
	Local aArea		:= GetArea()
	Local aParam    := PARAMIXB
	Local oObj      := ""
	Local cIdPonto  := ""
	Local cIdModel  := ""
	Local cCodLoja	:= ""
	Local cProduto	:= ""

	U_ADINF009P('ADVEN060P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Produtos com exceção de desconto')
	
	//
	If aParam <> NIL
		
		//
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		//
		If cIdPonto == 'FORMCOMMITTTSPOS'
			
			//
			If Findfunction("U_ADVEN055P")
				cCodLoja := Alltrim(cValToChar(oObj:GetModel('MASTERALIAS'):GetValue(cIdModel, 'ZC5_CODCLI' ) )) + Alltrim(cValToChar(oObj:GetModel('MASTERALIAS'):GetValue(cIdModel, 'ZC5_LOJA' ) ))
				cProduto := Alltrim(cValToChar(oObj:GetModel('MASTERALIAS'):GetValue(cIdModel, 'ZC5_PRODUT' ) ))
				
				U_ADVEN055P(cCodLoja,.F.,"") 
			
			EndIf
			
		EndIf

	EndIf
	
	//
	RestArea(aArea)
	
Return .T.