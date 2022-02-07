#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Cadastro de Motivo Parada"


/*/{Protheus.doc} User Function ADLFV015P
    Funcao para realizar os Cadastro de Departamento/Motivo Parada
    @type  Function
    @author Everson
    @since 18/05/2021
    @version 01
    @history Ticket 13294 	- Leonardo P. Monteiro - 13/08/2021 - Melhoria para o projeto apontamento de paradas p/ o recebimento do frango vivo. 
/*/

User Function ADLFV015P()

  Local oBrowse := FwLoadBrw("ADLFV015P")
  
  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Motivo Parada')
  
  oBrowse:Activate()

Return

// BROWSEDEF() SER› ⁄TIL PARA FUTURAS HERAN«AS: FWLOADBRW()
Static Function BrowseDef()
  Local oBrowse := FwMBrowse():New()

  oBrowse:SetAlias("ZGC")
  oBrowse:SetDescription(STR0001)

  oBrowse:AddLegend("ZGC_STATUS=='1'", "GREEN", "Ativo")
  oBrowse:AddLegend("ZGC_STATUS=='2'", "RED"  , "Bloqueado")
  
  oBrowse:SetMenuDef("ADLFV015P")
Return (oBrowse)

// OPERA«’ES DA ROTINA
Static Function MenuDef()
  Local aRotina := FWMVCMenu("ADLFV015P")
Return (aRotina)

// REGRAS DE NEG”CIO
Static Function ModelDef()
  Local oModel := MPFormModel():New("ADLFV15M")
  Local oStruZGC := FwFormStruct(1, "ZGC")
  Local oStruZEE := FwFormStruct(1, "ZEE")

  oModel:AddFields("ZGCMASTER", NIL, oStruZGC)
  oModel:AddGrid("ZEEDETAIL", "ZGCMASTER", oStruZEE)
  
  oModel:SetDescription(STR0001)

  oModel:SetRelation("ZEEDETAIL", {{"ZEE_FILIAL", "xFilial('ZEE')"},{"ZEE_DEPTO","ZGC_DEPTO"}}, ZEE->(IndexKey(1)))
  
  oModel:GetModel( 'ZGCMASTER' ):SetPrimaryKey( { "ZGC_DEPTO" } )
Return (oModel)

// INTERFACE GR›FICA
Static Function ViewDef()
  Local oView := FwFormView():New()
  Local oStruZGC := FwFormStruct(2, "ZGC")
  Local oStruZEE := FwFormStruct(2, "ZEE")

  Local oModel := FwLoadModel("ADLFV015P")

  oView:SetModel(oModel)

  oView:AddField("VIEW_ZGC",oStruZGC ,"ZGCMASTER")
  oView:AddGrid("VIEW_ZEE" ,oStruZEE ,"ZEEDETAIL")

  oStruZGC:RemoveField('ZGC_FILIAL')
  oStruZEE:RemoveField('ZEE_FILIAL')
  oStruZEE:RemoveField('ZEE_DEPTO')

  oView:AddIncrementField( "VIEW_ZEE", "ZEE_CODIGO" )

  oView:CreateHorizontalBox("TELA"	,020)
  oView:CreateHorizontalBox("ITEM"	,080)

  oView:SetOwnerView("VIEW_ZGC", "TELA")
  oView:SetOwnerView("VIEW_ZEE", "ITEM")

  oView:EnableTitleView("VIEW_ZGC", "Departamento", RGB(224, 30, 43))
  oView:EnableTitleView("VIEW_ZEE", "Motivos da Parada", RGB(224, 30, 43))
	// DEFINE OS TITULOS DAS SUBVIEWS
	oView:EnableTitleView("VIEW_ZGC")
	//oView:EnableTitleView("VIEW_ZEI")
	oView:EnableTitleView("VIEW_ZEE")
  // DEFINE OS TÌTULOS DAS SUBVIEWS
  // oView:EnableTitleView("VIEW_ZGC")
Return (oView)
