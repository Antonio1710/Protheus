//Bibliotecas
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
Static cTitulo := "Cadastro de Regiões"
/*/{Protheus.doc} ADLOG071P
	Cadastro de regiões - Logística.
	@author Everson
	@since 15/09/2020
	@version 1.0
/*/
User Function ADLOG071P()// U_ADLOG071P()

	//Variáveis.
    Local aArea   	:= GetArea()
    Local oBrowse	:= Nil

	//
	Private cTabela	:= "_3"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de regiões - logística.')

	//
	SetKey(VK_F12, {|| Processa( {|| U_ADLOG71A() },"Aguarde","Processando arquivo...") })

	//
    DbSelectArea("SX5")
    SX5->(DbSetOrder(1))
    SX5->(DbGoTop())

    //
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SX5")
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetFilterDefault("SX5->X5_TABELA = '" + cTabela + "' .AND. SX5->X5_FILIAL = '" + FWxFilial("SX5") + "' ")
	oBrowse:SetFilial({FWxFilial("SX5")})
	oBrowse:SetOnlyFields({"X5_FILIAL","X5_CHAVE","X5_DESCRI"})
    oBrowse:Activate()

	//
	SetKey(VK_F12, {||})

	//
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} MenuDef
	Menu MVC.
	@type  Static Function
	@author Everson
	@since 15/09/2020
	@version 01
	/*/
Static Function MenuDef()

	//Variáveis.
    Local aRot := {}

    //
    ADD OPTION aRot TITLE "Visualizar"   ACTION "VIEWDEF.ADLOG071P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE "Incluir"      ACTION "VIEWDEF.ADLOG071P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE "Alterar"      ACTION "VIEWDEF.ADLOG071P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE "Excluir"      ACTION "VIEWDEF.ADLOG071P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE "Imp. Regiões" ACTION "Processa( {|| U_ADLOG71A() },'Aguarde','Processando arquivo...')" OPERATION 10 ACCESS 0 
	ADD OPTION aRot TITLE "Imp. Clientes"ACTION "Processa( {|| U_ADLOG71B() },'Aguarde','Processando arquivo...')" OPERATION 11 ACCESS 0 

Return aRot
/*/{Protheus.doc} ModelDef
	Model MVC.
	@type  Static Function
	@author Everson
	@since 15/09/2020
	@version 01
	/*/
Static Function ModelDef()
	
	//Variáveis.
    Local oModel := Nil
    Local oStSX5 := FWFormStruct(1, "SX5")
	Local bPos   := {|oModel| vldPos(oModel) }

    //                                                                                                  
	oStSX5:SetProperty('X5_TABELA', MODEL_FIELD_OBRIGAT, .F.)    
	oStSX5:SetProperty('X5_CHAVE',  MODEL_FIELD_OBRIGAT, .F.)   
	oStSX5:SetProperty('X5_DESCRI', MODEL_FIELD_OBRIGAT, .T.)                                                            

    //
    oModel := MPFormModel():New("ADLOG71",/*bPre*/,bPos,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)
    oModel:SetPrimaryKey({'X5_FILIAL', "X5_TABELA", "X5_CHAVE"})
    oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
    oModel:GetModel("FORMSX5"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel
/*/{Protheus.doc} vldPos
	Valida as informações/operação.
	@type  Static Function
	@author Everson
	@since 15/09/2020
	@version 01
	/*/
Static Function vldPos(oModel)

	//Variáveis.
	Local aArea	 		:= GetArea()
	Local lRet   		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cInit  		:= ""
	Local cChave		:= Alltrim(cValToChar(oModel:GetValue("FORMSX5" , "X5_CHAVE")))
	Local cDesc			:= Alltrim(cValToChar(oModel:GetValue("FORMSX5" , "X5_DESCRI")))

	//
	If lRet .And. !(nOperation == MODEL_OPERATION_DELETE)

		//
		If Empty(cChave) 
			cInit := U_ADLOG71C()
			oModel:SetValue("FORMSX5","X5_CHAVE", cInit)

		EndIf

		//
		oModel:SetValue("FORMSX5","X5_FILIAL" , FWxFilial("SX5"))
		oModel:SetValue("FORMSX5","X5_TABELA" , cTabela)
		oModel:SetValue("FORMSX5","X5_DESCSPA", cDesc)
		oModel:SetValue("FORMSX5","X5_DESCENG", cDesc)

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
	View MVC.
	@type  Static Function
	@author Everson
	@since 15/09/2020
	@version 01
	/*/
Static Function ViewDef()
    
	//Variáveis.
    Local oModel := FWLoadModel("ADLOG071P")
    Local oStSX5 := FWFormStruct(2, "SX5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'}o
    Local oView  := Nil

    //
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")
    oView:CreateHorizontalBox("TELA",100)
    oView:EnableTitleView("VIEW_SX5", "Dados - " + cTitulo )  
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_SX5","TELA")
	oStSX5:RemoveField("X5_TABELA")
    oStSX5:RemoveField("X5_DESCSPA")
	oStSX5:RemoveField("X5_DESCENG")
	oStSX5:RemoveField("X5_CHAVE")

Return oView
/*/{Protheus.doc} ADLOG71C
	Função para geração de chave.
	@type function
	@author Atilio
	@since 05/08/2016
	@version 1.0
/*/
User Function ADLOG71C()

	//Variáveis.
    Local aArea    	:= GetArea()
    Local cChave   	:= ""
	Local cQuery	:= ""

	U_ADINF009P('ADLOG071P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de regiões - logística')

	//
	cQuery += " SELECT  " 
	cQuery += " MAX(X5_CHAVE) AS X5_CHAVE " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " (NOLOCK) AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " X5_FILIAL = '" + FWxFilial("SX5") + "' " 
	cQuery += " AND X5_TABELA = '" + cTabela + "' " 
	cQuery += " AND SX5.D_E_L_E_T_ = '' " 

	//
	If Select("D_SESX") > 0
		D_SESX->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_SESX"
	DbSelectArea("D_SESX")
	D_SESX->(DbGoTop())

	//
	If ! D_SESX->(Eof())

		//
		cChave := D_SESX->X5_CHAVE

	EndIf 

	//
	cChave := Soma1(cChave)

	//
	cChave := Padl(cChave,TamSX3("X5_CHAVE")[1],"0")

	//
	D_SESX->(DbCloseArea())

	//
    RestArea(aArea)

Return cChave
/*/{Protheus.doc} User Function ADLOG71A
    Função para importação de regiões por CSV.
    @type  Function
    @author Everson
    @since 15/09/2020
    @version 01
    /*/
User Function ADLOG71A()

	//Variáveis.
	Local aArea			:= GetArea()
	Local cArq			:= ""
	Local nHdl			:= 0
	Local nTotLinhas	:= 0
	Local aInfo			:= {}
	Local lErro			:= .F.
	Local aDados		:= {}
	Local nAux			:= 0
	Local cBuffer		:= ""
	Local i				:= 1
	Local aError		:= {} 

	//
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.

	U_ADINF009P('ADLOG071P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de regiões - logística')

	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		Help(Nil, Nil, "Função ADLOG71A(ADLOG071P) Função ADLOG71A(ADLOG071P)", Nil,"Não foi possível obter o arquivo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG071P - ADLOG71A - cArq " + cArq )

	//
	nHdl := FT_FUse(cArq)
	If nHdl == -1
		Help(Nil, Nil, "Função ADLOG71A(ADLOG071P) Função ADLOG71A(ADLOG071P)", Nil,"Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	FT_FGoTop()

	//
	nTotLinhas := FT_FLastRec()

	//
	ProcRegua(nTotLinhas)

	//
	FT_FGoTop()

	//
	While ! FT_FEof()

		//
		IncProc()

		//
		nAux++

		//
		cBuffer  := Alltrim(cValToChar(FT_FReadln()))

		//
		If Empty(cBuffer)
			Conout( DToC(Date()) + " " + Time() + " ADLOG071P - ADLOG71A - cBuffer vazio . Linha " + cValToChar(nAux) )
			FT_FSkip()
			Loop

		EndIf		

		//
		aInfo := Separa(cBuffer,';',.T.)
		
		//
		If Len(aInfo) <> 1
			MsgStop("Quantidade incorreta de campos. Linha " + cValToChar(nAux) + ".","Função ADLOG71A(ADLOG071P)")
			lErro := .T.
			Exit

		EndIf		

		//
		Aadd(aDados,{aInfo[1]})

		//
		FT_FSkip()

	EndDo

	//
	If ! lErro .And. Len(aDados) > 0

		//
		If ! MsgYesNo("Serão importados " + cValToChar(Len(aDados)) + " registros. Deseja prosseguir?","Função ADLOG71A(ADLOG071P)")
			RestArea(aArea)
			Return Nil

		EndIf 
		
		//
		Begin Transaction

			//
			For i := 1 To Len(aDados)
				
				//
				oModel:= FwLoadModel ("ADLOG071P")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				oModel:SetValue("FORMSX5","X5_DESCRI"  	,aDados[i][1])

				//
				If oModel:VldData()
					oModel:CommitData()

				Else
					aError := oModel:GetErrorMessage()
					MsgStop(aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION],"Função ADLOG71A(ADLOG071P)")
					DisarmTransaction()
					Break
					
				EndIf       
					
				oModel:DeActivate()
				oModel:Destroy()
				
				oModel := Nil

			Next i

		End Transaction

	EndIf

	//
	FT_FUse(cArq)

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} User Function ADLOG71B
    Rotina para atualização de cadastro de cliente via CSV.
    @type  Function
    @author Everson
    @since 15/09/2020
    @version 01
    /*/
User Function ADLOG71B()

	//Variáveis.
	Local aArea			:= GetArea()
	Local cArq			:= ""
	Local nHdl			:= 0
	Local nTotLinhas	:= 0
	Local aInfo			:= {}
	Local lErro			:= .F.
	Local aDados		:= {}
	Local nAux			:= 0
	Local cBuffer		:= ""
	Local i				:= 1

	U_ADINF009P('ADLOG071P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de regiões - logística')

	//
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())

	//
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	SX5->(DbGoTop())

	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		Help(Nil, Nil, "Função ADLOG71B(ADLOG071P) Função ADLOG71B(ADLOG071P)", Nil,"Não foi possível obter o arquivo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG071P - ADLOG71B - cArq " + cArq )

	//
	nHdl := FT_FUse(cArq)
	If nHdl == -1
		Help(Nil, Nil, "Função ADLOG71B(ADLOG071P) Função ADLOG71B(ADLOG071P)", Nil,"Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return Nil

	Endif

	//
	FT_FGoTop()

	//
	nTotLinhas := FT_FLastRec()

	//
	ProcRegua(nTotLinhas)

	//
	FT_FGoTop()

	//
	While ! FT_FEof()

		//
		IncProc()

		//
		nAux++

		//
		cBuffer  := Alltrim(cValToChar(FT_FReadln()))

		//
		If Empty(cBuffer)
			Conout( DToC(Date()) + " " + Time() + " ADLOG071P - ADLOG71B - cBuffer vazio . Linha " + cValToChar(nAux) )
			FT_FSkip()
			Loop

		EndIf		

		//
		aInfo := Separa(cBuffer,';',.T.)

		//
		If Len(aInfo) <> 3
			MsgStop("Quantidade incorreta de campos. Linha " + cValToChar(nAux) + ".","Função ADLOG71B(ADLOG071P)")
			lErro := .T.
			Exit

		EndIf	

		//
		If ! SA1->(DbSeek( FWxFilial("SA1") +  aInfo[1] + aInfo[2] ))
			MsgStop("Cliente não localizado: " + aInfo[1] + "/" + aInfo[2] + ".","Função ADLOG71B(ADLOG071P)")
			lErro := .T.
			Exit

		EndIf

		//
		If ! SX5->(DbSeek( FWxFilial("SX5") + cTabela + aInfo[3] ))
			MsgStop("Código de região não localizado: " + aInfo[3] + ".","Função ADLOG71B(ADLOG071P)")
			lErro := .T.
			Exit

		EndIf

		//
		Aadd(aDados,{aInfo[1],aInfo[2],aInfo[3]})

		//
		FT_FSkip()

	EndDo

	//
	If ! lErro .And. Len(aDados) > 0

		//
		If ! MsgYesNo("Serão atualizados " + cValToChar(Len(aDados)) + " registros. Deseja prosseguir?","Função ADLOG71B(ADLOG071P)")
			RestArea(aArea)
			Return Nil

		EndIf 
		
		//
		For i := 1 To Len(aDados)

			//
			If SA1->(DbSeek( FWxFilial("SA1") +  aDados[i][1] + aDados[i][2] ))
				RecLock("SA1",.F.)
					SA1->A1_REGIAO2 := aDados[i][3]
				SA1->(MsUnlock())

			EndIf 

		Next i

	EndIf

	//
	FT_FUse(cArq)

	//
	RestArea(aArea)

Return Nil
