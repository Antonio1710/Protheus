#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "Topconn.ch"

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : ADCOM019P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

USER Function ADCOM019P

	LOCAL oBrowse
	Private aRotina := aMenuDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCJ")
	oBrowse:SetDescription("Agendamento de Workflow")

	oBrowse:AddLegend("ZCJ_WFATIV = '1'", "BR_VERDE"    , "Ativo")
	oBrowse:AddLegend("ZCJ_WFATIV = '2'", "BR_VERMELHO" , "Inativo")
	
	oBrowse:Activate()
	
Return NIL

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : 19MenuDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function AMenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"      ACTION "VIEWDEF.ADCOM019P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"         ACTION "VIEWDEF.ADCOM019P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"         ACTION "VIEWDEF.ADCOM019P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"         ACTION "VIEWDEF.ADCOM019P" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Legenda"         ACTION "U_ADCOM19L()"     OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Execução Manual" ACTION "Processa({||U_ADCOM020P()},,'Processando Workflow')"     OPERATION 9 ACCESS 0

Return aRotina

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : ADCOM19L
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
User Function ADCOM19L()

Local aLegenda := {}

aAdd( aLegenda, { "BR_VERDE"   , "Ativo" })
aAdd( aLegenda, { "BR_VERMELHO", "Inativo" })

BrwLegenda( "Agendamento de Workflow", "Legenda", aLegenda )

Return Nil

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : ModelDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZCJ := FWFormStruct( 1, "ZCJ", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:SetDescription("Agendamento de Workflow")
	oModel:AddFields("ZCJMASTER", /*cOwner*/, oStruZCJ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZCJ_FILIAL" } )

Return oModel

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : ViewDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZCJ	:= FWFormStruct( 2, "ZCJ" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField("VIEW_ZCJ", oStruZCJ, "ZCJMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView
