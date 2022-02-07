#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Cadastro de Motivo Mortalidade"


/*/{Protheus.doc} User Function ADLFV016P
    Cadastro de Motivo Mortalidade
    @type  Function
    @author Everson
    @since 18/05/2021
    @version 01
/*/
User Function ADLFV016P()

  Local oBrowse := FwLoadBrw("ADLFV016P")
  
  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Motivo Mortalidade')

  oBrowse:Activate()

Return

// BROWSEDEF() SERÝ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
  Local oBrowse := FwMBrowse():New()

  oBrowse:SetAlias("ZEG")
  oBrowse:SetDescription(STR0001)

  oBrowse:AddLegend("ZEG_STATUS=='1'", "GREEN", "Ativo")
  oBrowse:AddLegend("ZEG_STATUS=='2'", "RED"  , "Bloqueado")
  
  oBrowse:SetMenuDef("ADLFV016P")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
  Local aRotina := FWMVCMenu("ADLFV016P")
Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
  Local oModel    := MPFormModel():New("ADLFV16M")
  Local oStruZEG  := FwFormStruct(1, "ZEG")

  oModel:AddFields("ZEGMASTER", NIL, oStruZEG)

  oModel:SetDescription(STR0001)

  // DESCRIÇÃO DO SUBMODELO
  //oModel:GetModel("ZEGMASTER"):SetDescription(STR0001)

  oModel:GetModel( 'ZEGMASTER' ):SetPrimaryKey( { "ZEG_CODIGO" } )
Return (oModel)

// INTERFACE GRÝFICA
Static Function ViewDef()
  Local oView     := FwFormView():New()
  Local oStruZEG  := FwFormStruct(2, "ZEG")
  Local oModel    := FwLoadModel("ADLFV016P")

  oView:SetModel(oModel)

  oView:AddField("VIEW_ZEG",oStruZEG ,"ZEGMASTER")

  oStruZEG:RemoveField('ZEG_FILIAL')

  oView:CreateHorizontalBox("TELA"	,100)

  oView:SetOwnerView("VIEW_ZEG", "TELA")

  // DEFINE OS TíTULOS DAS SUBVIEWS
  // oView:EnableTitleView("VIEW_ZEG")
Return (oView)
