#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"   
#Include "FINC030.CH"
#Include "AP5mail.ch"
Static nTipoFrt
/*/{Protheus.doc} User Function ADLOG066P
	Montagem de carga de ovos/pintinhos.
	@type  Function
	@author Everson
	@since 20/01/2020
	@version 01
	@history Everson, 22/01/2020, Chamado 054941. Adicionado restarea antes da chamada de alteração/exclusão e tratamento para pedido vinculado a nota fiscal.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	/*/
User Function ADLOG066P() // U_ADLOG066P()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oBrowse	:= Nil
	Local cDescFrt	:= ""
	Local cFilSec	:= Alltrim(cValToChar(FWxFilial("ZFD")))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Montagem de carga de ovos/pintinhos.')

	//
	If ! Pergunte("ADLOG040P",.T.)
		Return Nil 

	EndIf

	//
	nTipoFrt := MV_PAR01

	//
	//cDescFrt :=  Static Call(ADLOG040P, retDescFrt, MV_PAR01)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	cDescFrt :=  u_LOG040A0( MV_PAR01 )

    //
	oBrowse := FWMBrowse():New()
	oBrowse:SetFilterDefault(" ZFD_FILIAL = '" + cFilSec + "' .And. ZFD_VA = '" + cValToChar(nTipoFrt) + "'")
	oBrowse:SetAlias("ZFD")
	oBrowse:SetDescription("Montagem de Carga - " + cDescFrt)
	oBrowse:AddLegend("ZFD_FEZNF <> 'S'","GREEN","Carga Aberta")
	oBrowse:AddLegend("ZFD_FEZNF == 'S'","RED"  ,"Carga Fechada")
	oBrowse:Activate()

Return Nil
/*/{Protheus.doc} User Function ADLG40H
	Retorna o tipo de frete (1=Frt Abatido,2=Frt Frango Vivo,3=Frt Ovo;4=Frt Pintinho,5=Frt Ração)
	@type  Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
User Function ADLOG66C()

Return nTipoFrt
/*/{Protheus.doc} nomeStaticFunction
	Menu MVC.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static Function MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRotina := {}

	Add Option aRotina TITLE "Visualizar" Action "ViewDef.ADLOG066P" Operation 2 Access 0
	Add Option aRotina TITLE "Incluir"    Action "ViewDef.ADLOG066P" Operation 3 Access 0
	Add Option aRotina TITLE "Alterar"    Action "U_ADLOG663(4)"     Operation 4 Access 0
	Add Option aRotina TITLE "Excluir"    Action "U_ADLOG663(5)"     Operation 5 Access 0
	Add Option aRotina TITLE "Legenda"    Action "U_ADLOG66B()"      Operation 9 Access 0
	
Return aRotina
/*/{Protheus.doc} User Function ADLOG663
	Alteração/Exclusão.
	@type  Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
User Function ADLOG663(nOPc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}	
	Local cCarga	:= Alltrim(cValToChar(ZFD->ZFD_COD)) 

	U_ADINF009P('ADLOG066P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Montagem de carga de ovos/pintinhos.')

	//
	DbSelectArea("ZFD")
	ZFD->(DbSetOrder(1))
	ZFD->(DbGoTop())
	ZFD->(DbSeek( FWxFilial("ZFD") + cCarga ))

	//
	While ! ZFD->(Eof()) .And. FWxFilial("ZFD") == Alltrim(cValToChar(ZFD->ZFD_FILIAL)) .And. cCarga == Alltrim(cValToChar(ZFD->ZFD_COD))

		//
		If Alltrim(ZFD->ZFD_FEZNF) == "S"
			MsgStop("Registro fechado, operação não permitida.","Função ADLOG663 (ADLOG066P)")
			RestArea(aArea)
			Return Nil 

		EndIf

		//
		ZFD->(DbSkip())

	End

	//
	RestArea(aArea) //Everson - 22/01/2020. Chamado 054941.

	//
	aArea := GetArea() //Everson - 22/01/2020. Chamado 054941.

	//
	FWExecView("","ADLOG066P", nOPc, , { || .T. }, , ,aButtons )

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ModelDef
	Model MVC.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static Function ModelDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local oStruZFD  := FWFormStruct( 1, "ZFD",{|cCmp| AllTrim(cCmp) $ cmpCabec()} )
	Local oStru2ZFD := FWFormStruct( 1, "ZFD",{|cCmp| AllTrim(cCmp) $ cmpGrid() } )
	Local oModel	:= Nil
	Local bPosVld 	:= {|oModel| ADLOG66A(oModel)}

	//
	oStruZFD:SetProperty("ZFD_COD"   , MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_CAMINH", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_CAMINH", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('ZV4')") )
	oStruZFD:SetProperty("ZFD_MOTORI", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_NOMEMO", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_DTENTR", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_DTENTR", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "U_ADLOG66D(M->ZFD_DTENTR)") )
	oStruZFD:SetProperty("ZFD_TRANSP", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_LOJTRA", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_NOMTRA", MODEL_FIELD_OBRIGAT,.T.)
	oStruZFD:SetProperty("ZFD_DATA"  , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
	oStruZFD:SetProperty("ZFD_DATA"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "Date()"))
	oStruZFD:SetProperty("ZFD_HORA"  , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
	oStruZFD:SetProperty("ZFD_HORA"  , MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "Time()"))
	
	//
	oStru2ZFD:SetProperty("ZFD_HRSTAR" , MODEL_FIELD_OBRIGAT,.T.)
	oStru2ZFD:SetProperty("ZFD_PEDIDO" , MODEL_FIELD_OBRIGAT,.T.)
	oStru2ZFD:SetProperty("ZFD_PEDIDO" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "U_ADLOG66E(M->ZFD_PEDIDO,M->ZFD_COD)") )
	oStru2ZFD:SetProperty("ZFD_VLRFRT" , MODEL_FIELD_OBRIGAT,.T.)
	oStru2ZFD:SetProperty("ZFD_VLRFRT" , MODEL_FIELD_VALID, FWBuildFeatures(STRUCT_FEATURE_VALID, "Positivo()"))
	oStru2ZFD:SetProperty("ZFD_KMGER"  , MODEL_FIELD_OBRIGAT,.T.)
	oStru2ZFD:SetProperty("ZFD_KMGER"  , MODEL_FIELD_VALID, FWBuildFeatures(STRUCT_FEATURE_VALID, "Positivo()"))

	//
	oModel := MPFormModel():New("ADLOG66", /*bPreVld*/ , bPosVld, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields("ZFDMASTER", /*cOwner*/, oStruZFD )
	oModel:SetPrimaryKey( { "ZFD_FILIAL","ZFD_COD","ZFD_SEQCAR"} )

	//
	oModel:AddGrid("ZFDDETAIL", "ZFDMASTER", oStru2ZFD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:GetModel("ZFDDETAIL"):SetUniqueLine( {"ZFD_PEDIDO"} )

	//
	oModel:SetRelation("ZFDDETAIL", { { "ZFD_FILIAL",'FWxFilial("ZFD")' },{"ZFD_COD","ZFD_COD"} }, ZFD->( IndexKey( 1 ) ) )

	//
	oModel:GetModel("ZFDMASTER"):SetDescription("Montagem de Carga")
	oModel:GetModel("ZFDDETAIL"):SetDescription("Itens da Carga")

	//
	RestArea(aArea)

Return oModel
/*/{Protheus.doc} User Function ADLOG66D
	(long_description)
	@type  Function
	@author user
	@since 20/01/2020
	@version 01
	/*/
User Function ADLOG66D(dData)
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()

	U_ADINF009P('ADLOG066P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Montagem de carga de ovos/pintinhos.')

	//
	If dData < Date()
		RestArea(aArea)
		Return .F.

	EndIf

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} nomeStaticFunction
	View MVC.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static Function ViewDef()
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local oView		:= Nil
	Local oModelVd	:= FWLoadModel("ADLOG066P")
	Local oStruZFD	:= FWFormStruct( 2, "ZFD" ,{|cCmp | AllTrim(cCmp)  $ cmpCabec()} )
	Local oStru2ZFD	:= FWFormStruct( 2, "ZFD" ,{|cCmp | AllTrim(cCmp)  $ cmpGrid()}  ) 

	//
	oStruZFD:SetProperty("ZFD_DTENTR" , MVC_VIEW_TITULO, "Data Carreg.")
	oStruZFD:SetProperty("ZFD_MOTORI" , MVC_VIEW_CANCHANGE, .F.)
	oStruZFD:SetProperty("ZFD_TRANSP" , MVC_VIEW_CANCHANGE, .F.)

	//
	oStru2ZFD:SetProperty("ZFD_CLIENT" , MVC_VIEW_CANCHANGE, .F.)
	oStru2ZFD:SetProperty("ZFD_LOJA"   , MVC_VIEW_CANCHANGE, .F.)
	oStru2ZFD:SetProperty("ZFD_NOMECL" , MVC_VIEW_CANCHANGE, .F.)
	oStru2ZFD:SetProperty("ZFD_HRSTAR" , MVC_VIEW_TITULO, "Hora")
	oStru2ZFD:RemoveField("ZFD_FEZNF")
	oStru2ZFD:RemoveField("ZFD_DTENTR")
	 
	//
	oView := FWFormView():New()
	oView:SetModel( oModelVd )
	oView:AddField( "VIEW_ZFD", oStruZFD , "ZFDMASTER" )
	oView:AddGrid( "VIEW_ZFDD", oStru2ZFD, "ZFDDETAIL" )

	//
	oView:CreateHorizontalBox("SUPERIOR", 50 )
	oView:CreateHorizontalBox("INFERIOR", 50 )

	//
	oView:SetOwnerView("VIEW_ZFD" , "SUPERIOR" )
	oView:SetOwnerView("VIEW_ZFDD", "INFERIOR" )

	//
	oView:AddIncrementField("VIEW_ZFDD", "ZFD_SEQCAR")
    oView:SetCloseOnOk( { || .T. } )
	oView:SetProgressBar(.T.)

	//
	RestArea(aArea)

Return oView
/*/{Protheus.doc} ADLOG66A
	Validação model MVC.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static function ADLOG66A(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local lRet      := .T.
	Local nOperation:= oModel:GetOperation()
	Local dDtEnt	:= oModel:GetValue("ZFDMASTER","ZFD_DTENTR")
	Local cCarga	:= oModel:GetValue("ZFDMASTER","ZFD_COD")
	Local oModelIt 	:= oModel:GetModel( "ZFDDETAIL" )
	Local nI        := 0

	//
	If lRet 

		//
		For nI := 1 To oModelIt:Length()

			//
			oModelIt:GoLine(nI) 

			//
			If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT)

				//
				If ! oModelIt:isDeleted() .And. ! U_ADLOG66E(oModelIt:GetValue("ZFD_PEDIDO"),cCarga)
					lRet := .F.
					RestArea(aArea)
					Return lRet

				EndIf

				//
				If lRet .And. oModelIt:GetValue("ZFD_DTENTR") <> dDtEnt
					oModelIt:SetValue("ZFD_DTENTR",dDtEnt)

				EndIf

			EndIf

		Next nI

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADLOG66E
	Valida pedido de venda selecionado.
	@type  Function
	@author user
	@since 20/01/2020
	@version 01
	/*/
User Function ADLOG66E(cPed,cCarga)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea := GetArea()

	U_ADINF009P('ADLOG066P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Montagem de carga de ovos/pintinhos.')

	//
	cPed 	:= Alltrim(cValToChar(cPed))
	cCarga	:= Alltrim(cValToChar(cCarga))

	//Everson - 22/01/2020. Chamado 054941.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->( DbSeek( FWxFilial("SC5") + cPed ) )
		Help(Nil, Nil, "Função ADLOG66E(ADLOG066P)", Nil,"Pedido não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return .F.

	EndIf

	//Everson - 22/01/2020. Chamado 054941.
	If ! Empty(Alltrim(SC5->C5_NOTA))
		Help(Nil, Nil, "Função ADLOG66E(ADLOG066P)", Nil,"Pedido vinculado a nota fiscal " + Alltrim(SC5->C5_NOTA) + "/" + Alltrim(SC5->C5_SERIE) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
		RestArea(aArea)
		Return .F.

	EndIf

	//
	DbSelectArea("ZFD")
	ZFD->(DbSetOrder(5))
	ZFD->(DbGoTop())
	If ZFD->( DbSeek(FWxFilial("ZFD") + cPed) )

		//
		While ! ZFD->(Eof()) .And. FWxFilial("ZFD") == Alltrim(cValToChar(ZFD->ZFD_FILIAL)) .And. cPed == Alltrim(cValToChar(ZFD->ZFD_PEDIDO))

			//
			If cCarga <> Alltrim(cValToChar(ZFD->ZFD_COD)) 
				Help(Nil, Nil, "Função ADLOG66E(ADLOG066P)", Nil,"Pedido " + cPed + " já utilizado na carga " + Alltrim(cValToChar(ZFD->ZFD_COD))  + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
				Return .F.

			EndIf

			//
			ZFD->(DbSkip())

		End

	EndIf 

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADLOG66B
	Legenda.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
User Function ADLOG66B(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aLegenda := {}

	U_ADINF009P('ADLOG066P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Montagem de carga de ovos/pintinhos.')

	Aadd(aLegenda,{"BR_VERDE"   ,"Carga Aberta" })
	Aadd(aLegenda,{"BR_VERMELHO","Carga Fechada"})

	BrwLegenda("Montagem de Carga","Legenda",aLegenda)

Return Nil
/*/{Protheus.doc} cmpCabec
	Campos do cabeçalho da montagem de carga.
	@type  Static Function
	@author Everson
	@since 20/01/2020
	@version 01
	/*/
Static Function cmpCabec()
Return "ZFD_COD|ZFD_DTENTR|ZFD_CAMINH|ZFD_MOTORI|ZFD_NOMEMO|ZFD_TRANSP|ZFD_LOJTRA|ZFD_NOMTRA|ZFD_DATA|ZFD_HORA||ZFD_VA|ZFD_USUARI"
/*/{Protheus.doc} nomeStaticFunction
	Campos da grid da montagem de carga.
	@type  Static Function
	@author user
	@since 20/01/2020
	@version 01
	/*/
Static Function cmpGrid()
Return "ZFD_SEQCAR|ZFD_HRSTAR|ZFD_PEDIDO|ZFD_CLIENT|ZFD_LOJA|ZFD_KMGER|ZFD_VLRFRT|ZFD_NOMECL|ZFD_NUMNF|ZFD_SERIE|ZFD_FEZNF|ZFD_DTENTR"
