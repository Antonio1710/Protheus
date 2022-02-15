#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADGPE084P
    Cadastro de horários e turnos dos elegíveis (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 07/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE084P()
/*/

Static cTitulo := "..:: Cadastro Armários ::.."

User Function ADGPE084P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE084P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZHL")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE084P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE084P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE084P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE084P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE084P",, {|| .T.})
 Local oStrutZHL	:= FWFormStruct(1,"ZHL")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZHL",nil,oStrutZHL)

 oModel:setPrimaryKey({"ZHL_FILIAL","ZHL_CODIGO"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE084P")
 Local oStrutZHL	:= FWFormStruct(2,"ZHL")
  
 DbSelectArea("ZHL")
 
 ZHL->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZHL",oStrutZHL,"CABEC_ZHL")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZHL","V_CABEC")
  
Return oView
