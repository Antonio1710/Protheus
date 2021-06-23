#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Cadastro de Motivo Parada"


/*/{Protheus.doc} User Function ADLFV015P
    Funcao para realizar os Cadastro de Motivo Parada
    @type  Function
    @author Everson
    @since 18/05/2021
    @version 01
/*/

User Function ADLFV015P()

  Local oBrowse := FwLoadBrw("ADLFV015P")
  oBrowse:Activate()

Return

// BROWSEDEF() SERÝ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
  Local oBrowse := FwMBrowse():New()

  oBrowse:SetAlias("ZEE")
  oBrowse:SetDescription(STR0001)

  oBrowse:AddLegend("ZEE_STATUS=='1'", "GREEN", "Ativo")
  oBrowse:AddLegend("ZEE_STATUS=='2'", "RED"  , "Bloqueado")
  
  oBrowse:SetMenuDef("ADLFV015P")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
  Local aRotina := FWMVCMenu("ADLFV015P")
Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
  Local oModel := MPFormModel():New("ADLFV15M")
  Local oStruZEE := FwFormStruct(1, "ZEE")

  oModel:AddFields("ZEEMASTER", NIL, oStruZEE)

  oModel:SetDescription(STR0001)

  // DESCRIÇÃO DO SUBMODELO
  //oModel:GetModel("ZEEMASTER"):SetDescription(STR0001)

  oModel:GetModel( 'ZEEMASTER' ):SetPrimaryKey( { "ZEE_CODIGO" } )
Return (oModel)

// INTERFACE GRÝFICA
Static Function ViewDef()
  Local oView := FwFormView():New()
  Local oStruZEE := FwFormStruct(2, "ZEE")
  Local oModel := FwLoadModel("ADLFV015P")

  oView:SetModel(oModel)

  oView:AddField("VIEW_ZEE",oStruZEE ,"ZEEMASTER")

  oStruZEE:RemoveField('ZEE_FILIAL')

  oView:CreateHorizontalBox("TELA"	,100)

  oView:SetOwnerView("VIEW_ZEE", "TELA")

  // DEFINE OS TíTULOS DAS SUBVIEWS
  // oView:EnableTitleView("VIEW_ZEE")
Return (oView)
