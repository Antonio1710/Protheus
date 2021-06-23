#Include "FWMVCDef.ch"
/*/{Protheus.doc} User Function ADLOG021P
    AxCadastro da tabela ZBB Controle de WEbservice do CTAPLUS  
    onde é um controle para verificação se o ID ja foi para     
    Logistica e Estoque e se já foi enviado para o CTAPLUS volta
    @type  Function
    @author William
    @since 28/07/2016
    @version 01
    @history Everson, 12/03/2020, Ch: 053926. Adaptação da rotina para MVC.
    @history Everson, 13/03/2020, Ch: 053926. Adicionado validação para registros já importados para o controle de frete.
    @history Everson, 17/03/2020, Ch: 053926. Tratamento para registro incluído por aprovador já entrar aprovado.
    @history Everson, 17/06/2020, Ch: 058732. Inclusão do campo de centro de custo para baixa de estoque.
	@history Andre  , 10/04/2021, tkt: 10098. Registar o nome do usuário que alterou o campo “Centro de Custo”.- ZBB_USALCC
/*/

User Function ADLOG021P()

    //Variáveis.
    Local cTitulo     := "Registros de Abastecimento"
    Local cFiltro     := ""
    
    //
    Private cFiltro2  := ""

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Ax Cadastro da tabela ZBB Controle de WEbservice do CTAPLUS onde é um controle para verificação se o ID ja foi para Logistica e Estoque e se já foi enviado para o CTAPLUS volta')

    //
    If cEmpAnt+cFilAnt = "0103" .Or. cEmpAnt+cFilAnt = "0701"
        cFiltro := "B"
        cFiltro2:= "N"

    Else
        cFiltro := "A"
        cFiltro2:= "M"

    EndIf

    //
    DbSelectArea("ZBB")
    ZBB->(DbSetOrder(1))

    //
    oBrowse := FWMBrowse():New()

    //
    If ! Empty(cFiltro)
        oBrowse:SetFilterDefault(" ZBB_SISTEM = '" + cFiltro + "' .Or. ZBB_SISTEM = '" + cFiltro2 + "' ")
        
    EndIf

    //
    oBrowse:AddLegend("ZBB_APRMOV <> 'N'","GREEN" ,"Liberado")
	oBrowse:AddLegend("ZBB_APRMOV  = 'N'","RED"	  ,"Pendente Aprovação")
    oBrowse:SetAlias("ZBB")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author user
    @since 10/03/2020
    @version 01
    /*/
Static Function MenuDef()
	
    //Variáveis.
    Local aRot        := {}
    Local cUsrAprov   := Alltrim(GetMv("MV_#APRVABS",,""))
     
    //
    ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.ADLOG021P"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.ADLOG021P"   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.ADLOG021P"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.ADLOG021P"   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE "Legenda"    ACTION "U_ADLG21B()"       	OPERATION 9  ACCESS 0

    //
    If __cUserId $cUsrAprov
        ADD OPTION aRot TITLE 'Aprovar'    ACTION "U_ADLG21A()"         OPERATION 10 ACCESS 0

    EndIf
 
Return aRot
/*/{Protheus.doc} ModelDef
    Modelo MVC.
    @type  Static Function
    @author Everson
    @since 10/03/2020
    @version 01
    /*/
Static Function ModelDef()

    //Variáveis.
	Local oModel		:= Nil
	Local oStruZBB 		:= FWFormStruct( 1, "ZBB" )
	Local bPre			:= {|oModel| .T.}
	Local bPost			:= {|oModel| vldPos(oModel)}
	Local bCancel		:= {||.T.}
	Local bPreSub		:= {||.T.}
	Local bPosSub		:= {||.T.}
	Local bCarga		:= Nil
    Local aAux := {}

	aAux := FwStruTrigger('ZBB_CC', 'ZBB_USALCC' ,'cUserName',.f.,,0,)
	oStruZBB:AddTrigger( aAux[1], aAux[2] ,aAux[3] ,aAux[4] )	

    //
    If cFiltro2 == "N"
        oStruZBB:SetProperty("ZBB_CCWINF"   , MODEL_FIELD_OBRIGAT,.T.)

    EndIf

    //Everson - 17/06/2020. Chamado 058732.
    If cFiltro2 $"A|M"
        oStruZBB:SetProperty("ZBB_CC"   , MODEL_FIELD_OBRIGAT,.T.)

    EndIf

	//
	oModel:= MPFormModel():New("ADLOG21", bPre, bPost, /*bCommit*/, bCancel)
	oModel:AddFields("ZBBMASTER","", oStruZBB, bPreSub, bPosSub, bCarga)
	oModel:GetModel("ZBBMASTER"):SetDescription("Registros de Abastecimento")
	oModel:SetPrimaryKey( {"ZBB_FILIAL","ZBB_IDABAS" } )

Return oModel
/*/{Protheus.doc} ViewDef
    View Def.
    @type  Static Function
    @author Everson
    @since 10/03/2020
    @version 01
    /*/
Static Function ViewDef()

    //Variáveis.
	Local oView		:= Nil
	Local oModel   	:= FWLoadModel( "ADLOG021P" )
	Local oStruZBB 	:= FWFormStruct( 2, "ZBB" )
    
    

	//
    If cFiltro2 <> "N"
        oStruZBB:RemoveField("ZBB_CCWINF") 

    EndIf

    //Everson - 17/06/2020. Chamado 058732.
    If ! cFiltro2 $"A|M"
        oStruZBB:RemoveField("ZBB_CC") 

    EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField("VIEW_ZBB", oStruZBB, "ZBBMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )

	//
	oView:SetCloseOnOk( { || .T. } )

Return oView
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Everson
    @since 10/03/2020
    @version 01
    /*/
Static Function vldPos(oModel)

    //Variáveis.
	Local aArea			:= GetArea()	
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
    Local cTpReg        := oModel:GetValue( "ZBBMASTER" , "ZBB_SISTEM" )
    Local cNumSA        := oModel:GetValue( "ZBBMASTER" , "ZBB_NUMSA" )
    Local cRegAprv      := oModel:GetValue( "ZBBMASTER" , "ZBB_APRMOV" )
    Local cCodReg       := Alltrim(oModel:GetValue( "ZBBMASTER" , "ZBB_IDABAS" ))
    Local lFchFrt       := oModel:GetValue( "ZBBMASTER" , "ZBB_FCHFRT" ) //Everson - 13/03/2020. Chamado 053926.
    Local cUsrAprov     := Alltrim(GetMv("MV_#APRVABS",,"")) //Everson - 17/03/2020. Chamado 053926.
    Local lUsrAp        := __cUserId $cUsrAprov //Everson - 17/03/2020. Chamado 053926.

	//
	If lRet .And. ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE ) 

        //
        If lRet .And.;
           (! Empty(cNumSA) .Or. lFchFrt) .And.; //Everson - 13/03/2020. Chamado 053926.
           (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE)

           //
           lRet := .F.
           Help(Nil, Nil, "Função vldPos(ADLOG021P)", Nil, "Operação não permitida. Registro já possui número de solicitação ao armazém e/ou já foi importado para o controle de frete.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""}) //Everson - 13/03/2020. Chamado 053926.

        EndIf

        //
        If lRet .And.;
           nOperation == MODEL_OPERATION_DELETE .And.;
           cTpReg $"A/B"
           
           //
           lRet := .F.
           Help(Nil, Nil, "Função vldPos(ADLOG021P)", Nil, "Operação não permitida. Lançamento automático não pode ser excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

	EndIf 

    //
    If lRet .And. Empty(cTpReg)
        oModel:SetValue( "ZBBMASTER" , "ZBB_SISTEM", cFiltro2 )
        cTpReg:= cFiltro2

    EndIf

    //
    If lRet .And. Empty(cCodReg) 
        cCodReg := GetSXEnum("ZBB","ZBB_IDABAS")
        ConfirmSX8()
        oModel:SetValue( "ZBBMASTER" , "ZBB_IDABAS", cCodReg )
        
    EndIf

	//Everson
	If lRet .And. ! (nOperation == MODEL_OPERATION_DELETE ) .And. cTpReg $cFiltro2

		//
		oModel:SetValue( "ZBBMASTER", "ZBB_USUARI", cUserName )
		oModel:SetValue( "ZBBMASTER", "ZBB_DATAIN", Date() )
		oModel:SetValue( "ZBBMASTER", "ZBB_HORA"  , Time() )
        oModel:SetValue( "ZBBMASTER", "ZBB_NOMAPR", "" )

		//
		If !lUsrAp .And. ( Empty(cRegAprv) .Or. cRegAprv = "N" .Or. ! Empty(Alltrim(oModel:GetValue( "ZBBMASTER", "ZBB_USRAPR"))) ) //Everson - 17/03/2020. Chamado 053926.
			oModel:SetValue( "ZBBMASTER", "ZBB_APRMOV", "N" )
			oModel:SetValue( "ZBBMASTER", "ZBB_USRAPR", "" )
			oModel:SetValue( "ZBBMASTER", "ZBB_NOMAPR", "" )
			oModel:SetValue( "ZBBMASTER", "ZBB_DTAPRO", SToD("") )
			oModel:SetValue( "ZBBMASTER", "ZBB_HRAPRO", "" )

        ElseIf lUsrAp //Everson - 17/03/2020. Chamado 053926.
  			oModel:SetValue( "ZBBMASTER", "ZBB_APRMOV", "" )
			oModel:SetValue( "ZBBMASTER", "ZBB_USRAPR", __cUserId )
			oModel:SetValue( "ZBBMASTER", "ZBB_NOMAPR", cUserName )
			oModel:SetValue( "ZBBMASTER", "ZBB_DTAPRO", Date() )
			oModel:SetValue( "ZBBMASTER", "ZBB_HRAPRO", Time() )      

		EndIf

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADLG21A
    Aprovação de registros manuais.
    @type  Function
    @author Everson
    @since 11/03/2020
    @version 01
    /*/
User Function ADLG21A()

    //Variáveis.
	Local aArea := GetArea()

    U_ADINF009P('ADLOG021P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Registros de abastecimento.')

    //
    If Alltrim(cValToChar(ZBB->ZBB_APRMOV)) <> "N"
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    If ! MsgYesNo("Deseja aprovar o registro selecionado?","Funçao ADLG21A(ADLOG021P)") 
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    RecLock("ZBB",.F.)
	    ZBB->ZBB_APRMOV := ""
	    ZBB->ZBB_USRAPR := __cUserId
	    ZBB->ZBB_NOMAPR := cUserName
	    ZBB->ZBB_DTAPRO := Date()
	    ZBB->ZBB_HRAPRO := Time()
    MsUnlock()

    //
    MsgInfo("Registro aprovado.","Função ADLG021P(ADLOG021P)")	

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLG21B
    Legenda.
    @type  Function
    @author Everson
    @since 11/03/2020
    @version 01
    /*/
User Function ADLG21B()

    //Variáveis.
	Local aLegenda := {}

	U_ADINF009P('ADLOG021P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Registros de abastecimento.')

	Aadd(aLegenda,{"BR_VERDE"   ,"Liberado" })
	Aadd(aLegenda,{"BR_VERMELHO","Pendente Aprovação"})

	BrwLegenda("Registros de Abastecimento","Legenda",aLegenda)

Return Nil
