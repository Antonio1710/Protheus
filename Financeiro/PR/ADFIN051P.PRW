#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cCabCampos := ""

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN051P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 11/01/18 | Ricardo Lima      | Alcada de Aprovadores                      | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

USER Function ADFIN051P

	LOCAL oBrowse

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	cCabCampos := "ZCF_CODIGO|ZCF_CCUSTO"
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCF")
	oBrowse:SetDescription("Grupo de Aprovadores")

	oBrowse:Activate()

Return NIL

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : MenuDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 11/01/18 | Ricardo Lima      | Alcada de Aprovadores                      | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.ADFIN051P"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.ADFIN051P"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    		ACTION "VIEWDEF.ADFIN051P" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    		ACTION "VIEWDEF.ADFIN051P" 	OPERATION 5 ACCESS 0

Return aRotina

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ModelDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 11/01/18 | Ricardo Lima      | Alcada de Aprovadores                      | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ModelDef()

	LOCAL oStruZCF := FWFormStruct( 1, "ZCF",{|cCabCampos| AllTrim(cCabCampos) $ "ZCF_CODIGO|ZCF_CCUSTO"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oStru2ZCF := FWFormStruct( 1, "ZCF",{|cCabCampos| !AllTrim(cCabCampos) $ "ZCF_CODIGO|ZCF_CCUSTO"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oModel

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('ZCFMASTER', /*cOwner*/, oStruZCF )
	oModel:SetPrimaryKey( { 'ZCF_FILIAL', 'ZCF_CODIGO', 'ZCF_ITEM', 'ZCF_APROVA' } )
	
	oModel:AddGrid("ZCFDETAIL", "ZCFMASTER", oStru2ZCF, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:GetModel("ZCFDETAIL"):SetUniqueLine( {'ZCF_APROVA' } )

	oModel:SetRelation("ZCFDETAIL", { { "ZCF_FILIAL", 'xFilial("ZCF")' }, { "ZCF_CODIGO", "ZCF_CODIGO" } }, ZCF->( IndexKey( 1 ) ) )

	oModel:GetModel("ZCFDETAIL"):SetOptional( .T. )

	oModel:GetModel("ZCFMASTER"):SetDescription("Grupo de Aprovadores")
	oModel:GetModel("ZCFDETAIL"):SetDescription("Item Grupo de Aprovadores")

Return oModel



// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ViewDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 11/01/18 | Ricardo Lima      | Alcada de Aprovadores                      | 038609
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ViewDef()

	LOCAL oView
	LOCAL oModelVd	:= ModelDef()
	LOCAL oStruZCF	:= FWFormStruct( 2, "ZCF" , {|cCabCampos| AllTrim(cCabCampos) $ "ZCF_CODIGO|ZCF_CCUSTO"} )
	LOCAL oStru2ZCF	:= FWFormStruct( 2, "ZCF" ,{|cCabCampos| !AllTrim(cCabCampos) $ "ZCF_CODIGO|ZCF_CCUSTO"} )

	// Cria o objeto de View
	oView := FWFormView():New()
	oView:SetModel( oModelVd )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "VIEW_ZCF", oStruZCF, "ZCFMASTER" )
	oView:AddGrid( "VIEW_ZCFD", oStru2ZCF, "ZCFDETAIL" )

	//Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("SUPERIOR", 25 )
	oView:CreateHorizontalBox("INFERIOR", 75 )

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_ZCF", "SUPERIOR" )
	oView:SetOwnerView("VIEW_ZCFD", "INFERIOR" )

	//Liga a identificacao do componente
	oView:EnableTitleView("VIEW_ZCF", "Item Grupo de Aprovadores")
	
	// Auto Incrementa o campo do parametro
	oView:AddIncrementField("VIEW_ZCFD", "ZCF_ITEM")

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )

Return oView