#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADGPE079P
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

    U_ADGPE079P()
/*/

Static cTitulo := "..:: Cadastro de Colaboradores e Terceiros ::.."

User Function ADGPE079P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE079P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI1")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( "ZI1->ZI1_CODTIP == 'N' ", "BR_AZUL"     ,  "Registro do tipo Normal." )
    oBrowse:AddLegend( "ZI1->ZI1_CODTIP == 'D' ", "BR_LARANJA"  ,  "Registro do tipo diretor." )
    oBrowse:AddLegend( "ZI1->ZI1_CODTIP == 'T' ", "BR_VERDE"    ,  "Registro como terceiro." )
    oBrowse:AddLegend( "ZI1->ZI1_CODTIP == 'Z' ", "BR_AMARELO"  ,  "Registro do tipo aprendiz." )
    
    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE079P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE079P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE079P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE079P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE079P",, {|| .T.})
 Local oStrutZI1	:= FWFormStruct(1,"ZI1")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZI1",nil,oStrutZI1)

 oModel:setPrimaryKey({"ZI1_FILIAL","ZI1_MAT","ZI1_PERIOD","ZI1_PRODUT"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE079P")
 Local oStrutZI1	:= FWFormStruct(2,"ZI1")
  
 DbSelectArea("ZI1")
 
 ZI1->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZI1",oStrutZI1,"CABEC_ZI1")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZI1","V_CABEC")
  
Return oView
