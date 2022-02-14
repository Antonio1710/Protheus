#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDEF.CH"

// Variaveis estaticas
Static cTitulo    := "..:: Cadastro de Ingredientes ::.."
Static cTabela    := "ZEC"

/*/{Protheus.doc} User Function ADEST063P
    Tela de cadastro de ingredientes.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 29/02/2021
    @version 01
/*/
User Function ADEST063P()

    Local   oBrowse
    Private aRotina		:= MenuDef()

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' Tela de cadastro de ingredientes')

    // Instanciando FWMBROWSE - Somente com dicionario de dados
    oBrowse := FWMBrowse():New()

    // Setando a tabela de cadastros 
    oBrowse:SetAlias(cTabela)

    // Setando a descricao da rotina
    oBrowse:SetDescription(cTitulo)

    // Ativa o browse
    oBrowse:Activate()

Return

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e MenuDef.
// --------------------------------------------------------------------------------------------------------
Static Function MenuDef()

    LOCAL aRotina := {}

    // Adicionando opcoes
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.ADEST063P"  OPERATION MODEL_OPERATION_VIEW      ACCESS 0
    ADD OPTION aRotina TITLE "Inclusão"     ACTION "VIEWDEF.ADEST063P"  OPERATION MODEL_OPERATION_INSERT    ACCESS 0
    ADD OPTION aRotina TITLE "Alteração"    ACTION "VIEWDEF.ADEST063P"  OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
    ADD OPTION aRotina TITLE "Exclusão"     ACTION "VIEWDEF.ADEST063P"  OPERATION MODEL_OPERATION_DELETE    ACCESS 0

Return aRotina


// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADEST063P",, {|| .T.})
 Local oStrutZEC	:= FWFormStruct(1,"ZEC")
 
 oModel:SetDescription(cTitulo)
 
 // CabeÃ§alho ZT3 (Pedidos)
 oModel:addFields("CABEC_ZEC",nil,oStrutZEC)

 oModel:setPrimaryKey({"ZEC_FILIAL","ZEC_CODIO"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADEST063P")
 Local oStrutZEC	:= FWFormStruct(2,"ZEC")
  
 DbSelectArea("ZEC")
 
 ZEC->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZEC",oStrutZEC,"CABEC_ZEC")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZEC","V_CABEC")
  
Return oView
