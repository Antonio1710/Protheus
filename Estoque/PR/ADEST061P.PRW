#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} User Function ADEST061P
    Tela de manutenção dos cadastros:
        - Requisitos de Mercado (PGA).
        - Mercados.
        - Países.
        - Produtos.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 12/02/2021
    @version 01
/*/

// --------------------------------------------------------------------------------------------------------
// Início da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADEST061P",, {|| .T.})
 Local oStrutZE3	:= FWFormStruct(1,"ZE3")

 U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de manutenção dos cadastros PGA2')

 
 oModel:SetDescription("..:: Cadastro Mercado ::..")
 
 // Cabeçalho ZT3 (Pedidos)
 oModel:addFields("CABEC_ZE3",nil,oStrutZE3)

 oModel:setPrimaryKey({"ZE3_FILIAL","ZE3_MERCAD","ZE3_ZE1REQ"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADEST061P")
 Local oStrutZE3	:= FWFormStruct(2,"ZE3")
  
 DbSelectArea("ZE3")
 
 ZE3->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZE3",oStrutZE3,"CABEC_ZE3")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZE3","V_CABEC")
  
Return oView
