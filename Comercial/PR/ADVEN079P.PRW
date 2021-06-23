#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

// #########################################################################################################
// Projeto: Projeto Sales Force
// Modulo : SIGAFAT
// Fonte  : ADVEN079P
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 15/02/18 | Ricardo Lima      | Complemento de Cliente para integração do Sales Force     | 038609
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

USER Function ADVEN079P

LOCAL oBrowse
PRIVATE aRotina		:= MenuDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Complemento de Cliente para integração do Sales Force')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCG")
	oBrowse:SetDescription("Complemento do Cadastro de Cliente")
	
	oBrowse:Activate()
	
Return NIL

// #########################################################################################################
// Projeto: Projeto Sales Force
// Modulo : SIGAFAT
// Fonte  : MenuDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 15/02/18 | Ricardo Lima      | Complemento de Cliente para integração do Sales Force     | 038609
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADVEN079P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADVEN079P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADVEN079P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADVEN079P" OPERATION 5 ACCESS 0

Return aRotina

// #########################################################################################################
// Projeto: Projeto Sales Force
// Modulo : SIGAFAT
// Fonte  : ModelDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 15/02/18 | Ricardo Lima      | Complemento de Cliente para integração do Sales Force     | 038609
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZCG := FWFormStruct( 1, "ZCG", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Complemento do Cadastro de Cliente")

	oModel:AddFields("ZCGMASTER", /*cOwner*/, oStruZCG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetPrimaryKey( {"ZCG_FILIAL" } )

Return oModel

// #########################################################################################################
// Projeto: Projeto Sales Force
// Modulo : SIGAFAT
// Fonte  : ViewDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 15/02/18 | Ricardo Lima      | Complemento de Cliente para integração do Sales Force     | 038609
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZCG	:= FWFormStruct( 2, "ZCG" )

	oView := FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField("VIEW_ZCG", oStruZCG, "ZCGMASTER" )

	oView:CreateHorizontalBox("TELA" , 100 )

	oView:EnableTitleView("VIEW_ZCG" , "Complemento do Cadastro de Cliente" )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView