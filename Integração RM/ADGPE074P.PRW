#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADGPE074P
    Cadastro de elegíveis para o Kit Adoro (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE074P()
/*/

Static cTitulo := "..:: Cadastro Seção ::.."

User Function ADGPE074P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE074P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI5")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE074P",, {|| .T.})
 Local oStrutZI5	:= FWFormStruct(1,"ZI5")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZI5",nil,oStrutZI5)

 oModel:setPrimaryKey({"ZI5_FILIAL","ZI5_CODIGO"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE074P")
 Local oStrutZI5	:= FWFormStruct(2,"ZI5")
  
 DbSelectArea("ZI5")
 
 ZI5->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZI5",oStrutZI5,"CABEC_ZI5")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZI5","V_CABEC")
  
Return oView
