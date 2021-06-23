#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFAT
// Fonte  : ADVEN093P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Log Recepção Json - Sales Force            | 
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
USER Function ADVEN093P

LOCAL oBrowse
PRIVATE aRotina := MenuDef()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Log Recepção Json - Sales Force')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCI")
	oBrowse:SetDescription("Log Recepção Json - Sales Force")
	
	oBrowse:Activate()
	
Return NIL

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFAT
// Fonte  : MENUDEF
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Log Recepção Json - Sales Force            | 
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.ADVEN093P" OPERATION 2 ACCESS 0

Return aRotina

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFAT
// Fonte  : MODELDEF
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Log Recepção Json - Sales Force            | 
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZCI := FWFormStruct( 1, "ZCI", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Log Recepção Json - Sales Force")
	oModel:AddFields("ZCIMASTER", /*cOwner*/, oStruZCI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZCI_FILIAL" } )

Return oModel

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFAT
// Fonte  : VIEWDEF
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Log Recepção Json - Sales Force            | 
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZCI	:= FWFormStruct( 2, "ZCI" )

	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("VIEW_ZCI", oStruZCI, "ZCIMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView