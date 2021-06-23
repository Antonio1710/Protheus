#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"
// #############################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN058P
// ---------+-------------------+-----------------------------------------------+---------------
// Data     | Autor             | Descricao                                     | Chamado
// ---------+-------------------+-----------------------------------------------+---------------
// 28/06/18 | Ricardo Lima      | Cadastro de Nivel de Segurança para aprovação |
// ---------+-------------------+-----------------------------------------------+---------------
//          |                   |                                               |
// ---------+-------------------+-----------------------------------------------+---------------
// #############################################################################################

USER Function ADFIN058P

	LOCAL oBrowse
	PRIVATE aRotina := MDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Nivel de Segurança para aprovação')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCK")
	oBrowse:SetDescription("Cadastro de Nivel de Segurança")
	oBrowse:Activate()
	
Return NIL

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : MDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 28/06/18 | Ricardo Lima      |                                            |  
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function MDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.ADFIN058P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"         ACTION "VIEWDEF.ADFIN058P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"         ACTION "VIEWDEF.ADFIN058P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"         ACTION "VIEWDEF.ADFIN058P" OPERATION 5 ACCESS 0
	
Return aRotina

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ModelDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 28/06/18 | Ricardo Lima      |                                            |  
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZCK := FWFormStruct( 1, "ZCK", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Cadastro de Nivel de Segurança")
	oModel:AddFields("ZCKMASTER", /*cOwner*/, oStruZCK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZCK_CODNIV" } )

Return oModel

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ViewDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 28/06/18 | Ricardo Lima      |                                            |  
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZCK	:= FWFormStruct( 2, "ZCK" )

	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("VIEW_ZCK", oStruZCK, "ZCKMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetCloseOnOk( { || .T. } )
Return oView