#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function ADFIN105P
  Configuração de Borderôs Automáticos
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
	@history Ticket   4883 - Abel Babini - 28/12/2020 - Geração de borderôs automática
  /*/
User Function ADFIN105P()

	lOCAL oBrowse

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	cCabCampos := "ZG5_MODALI|ZG5_TIPOPG"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZG5")
	oBrowse:SetDescription('Configuração Borderô Automático')

	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} User Function MenuDef
  MenuDef
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
  /*/
Static Function MenuDef()

	Local aRotina		:= {}

	ADD OPTION aRotina TITLE 'Visualizar'		ACTION 'VIEWDEF.ADFIN105P'	OPERATION 2	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'			ACTION 'VIEWDEF.ADFIN105P'	OPERATION 3	ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'			ACTION 'VIEWDEF.ADFIN105P'	OPERATION 4	ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'			ACTION 'VIEWDEF.ADFIN105P'	OPERATION 5	ACCESS 0 //OPERATION 5

Return aRotina

/*/{Protheus.doc} User Function ModelDef
  ModelDef
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
  /*/
Static Function ModelDef()

	LOCAL oStruZG5  := FWFormStruct( 1, "ZG5",{|cCabCampos| AllTrim(cCabCampos) $ "ZG5_MODALI|ZG5_TIPOPG"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oStru2ZG5 := FWFormStruct( 1, "ZG5",{|cCabCampos| !AllTrim(cCabCampos) $ "ZG5_MODALI|ZG5_TIPOPG"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oModel
	LOCAL bMPosVld		:= { |oModel| xMPosVld(oModel) }
	LOCAL bDPosVld		:= { |oModel| xDPosVld(oModel) }

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, bMPosVld, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('ZG5MASTER', /*cOwner*/, oStruZG5 )
	oModel:SetPrimaryKey( { 'ZG5_FILIAL', 'ZG5_MODALI', 'ZG5_TIPOPG', 'ZG5_ORDEM' } )
	
	oModel:AddGrid("ZG5DETAIL", "ZG5MASTER", oStru2ZG5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, bDPosVld, /*BLoad*/ )
	oModel:GetModel("ZG5DETAIL"):SetUniqueLine( {'ZG5_ORDEM' } )

	oModel:SetRelation("ZG5DETAIL", { { "ZG5_FILIAL", 'xFilial("ZG5")' }, { "ZG5_MODALI", "ZG5_MODALI" }, { "ZG5_TIPOPG", "ZG5_TIPOPG" } }, ZG5->( IndexKey( 1 ) ) )

	oModel:GetModel("ZG5DETAIL"):SetOptional( .T. )

	oModel:GetModel("ZG5MASTER"):SetDescription("Configuração Borderô Automático")
	oModel:GetModel("ZG5DETAIL"):SetDescription("Configuração de contas para borderô automático")

Return oModel

/*/{Protheus.doc} User Function ViewDef
  ViewDef
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
  /*/
Static Function ViewDef()

	LOCAL oView
	LOCAL oModelVd	:= ModelDef()
	LOCAL oStruZG5	:= FWFormStruct( 2, "ZG5" , {|cCabCampos| AllTrim(cCabCampos) $ "ZG5_MODALI|ZG5_TIPOPG"} )
	LOCAL oStru2ZG5	:= FWFormStruct( 2, "ZG5" ,{|cCabCampos| !AllTrim(cCabCampos) $ "ZG5_MODALI|ZG5_TIPOPG"} )

	// Cria o objeto de View
	oView := FWFormView():New()
	oView:SetModel( oModelVd )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "VIEW_ZG5", oStruZG5, "ZG5MASTER" )
	oView:AddGrid( "VIEW_ZG5D", oStru2ZG5, "ZG5DETAIL" )

	//Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("SUPERIOR", 25 )
	oView:CreateHorizontalBox("INFERIOR", 75 )

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_ZG5", "SUPERIOR" )
	oView:SetOwnerView("VIEW_ZG5D", "INFERIOR" )

	//Liga a identificacao do componente
	oView:EnableTitleView("VIEW_ZG5", "Configuração de contas para borderô automático")
	
	// Auto Incrementa o campo do parametro
	oView:AddIncrementField("VIEW_ZG5D", "ZG5_ITEM")

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )

Return oView

/*/{Protheus.doc} User Function xMPosVld
  xMPosVld
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
  /*/
Static Function xMPosVld(oModel)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	// Local oModelDad	:= FWModelActive()
	Local cModali		:= oModel:GetValue('ZG5MASTER', 'ZG5_MODALI')
	Local cTipoPg		:= oModel:GetValue('ZG5MASTER', 'ZG5_TIPOPG')
	Local nOpc			:= oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT
		dbSelectArea('ZG5')
		ZG5->(DbSetOrder(1))

		If ZG5->( MsSeek( xFilial('ZG5') + cModali + cTipoPg) )
			Aviso('Atenção', 'Modalidade e Tipo de Pagamento já configurados', {'OK'}, 02)
			lRet:= .F.
		Endif
	Endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} User Function xDPosVld
  xDPosVld
  @type  User Function
  @author Abel Babini
  @since 15/12/2020
  /*/
Static Function xDPosVld(oModel)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local aColsAux:= oModel:GetData()
	Local nOpc			:= oModel:GetOperation()	
	Local aBACAux		:= {}
	Local _i				:= 0

	If nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_INSERT

		aBACAux	:= {}
		For _i := 1 to Len(aColsAux)

			//Valida Numero de Ordem
			IF Empty(Alltrim(DTOS(aColsAux[_i][1][1][9]))) .AND. ASCAN(aBACAux, {|x| x  == aColsAux[_i][1][1][3]+aColsAux[_i][1][1][4]+aColsAux[_i][1][1][6] }) > 0  .AND. !oModel:IsDeleted(_i)
				Help( ,, 'ADFIN105P-2',, 'O banco selecionado na linha '+Alltrim(str(_i))+' já foi utilizado anteriormente para essa mesma modalidade / tipo de pagamento!', 1, 0)
				lRet := .F.
				EXIT
			ELSEIF Empty(Alltrim(DTOS(aColsAux[_i][1][1][9]))) .AND. !oModel:IsDeleted(_i)
				aAdd(aBACAux, aColsAux[_i][1][1][3]+aColsAux[_i][1][1][4]+aColsAux[_i][1][1][6])
			ENDIF
		Next _i

	Endif

	RestArea(aArea)

Return lRet
