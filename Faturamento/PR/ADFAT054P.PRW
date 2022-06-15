#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ADFAT054P
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Motivos de Cortes                                        | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

User Function ADFAT054P()

LOCAL oBrowse
PRIVATE aRotina		:= MenuDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Motivos de Cortes')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZHE")
	oBrowse:SetDescription("Motivos de Cortes")
	
	oBrowse:Activate()
	
Return NIL

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : MenuDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Motivos de Cortes                                       | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################

STATIC Function MenuDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADFAT054P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADFAT054P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADFAT054P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADFAT054P" OPERATION 5 ACCESS 0

Return aRotina

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ModelDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos  | Motivos de Cortes                                       | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################


STATIC Function ModelDef()

	LOCAL oModel
	LOCAL oStruZHE := FWFormStruct( 1, "ZHE", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:SetDescription("Motivos de Cortes")

	oModel:AddFields("ZHEMASTER", /*cOwner*/, oStruZHE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetPrimaryKey( {"ZHE_FILIAL","ZHE_CODIGO" } )

Return oModel

// #########################################################################################################
// Projeto: Projeto Banco de dados para confecção do BI
// Modulo : SIGAFAT
// Fonte  : ViewDef
// ---------+-------------------+-----------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                 | Chamado
// ---------+-------------------+-----------------------------------------------------------+---------------
// 20/05/22 | Antonio Domingos      | Motivos de Cortes                                   | 68089
// ---------+-------------------+-----------------------------------------------------------+---------------
//          |                   |                                                           |
// ---------+-------------------+-----------------------------------------------------------+---------------
// #########################################################################################################
STATIC Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStruZHE	:= FWFormStruct( 2, "ZHE" )

	oView := FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField("VIEW_ZHE", oStruZHE, "ZHEMASTER" )

	oView:CreateHorizontalBox("TELA" , 100 )

	oView:EnableTitleView("VIEW_ZHE" , "Motivos de Cortes" )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk( { || .T. } )
Return oView

