#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADGPE069P
    Cadastro de DePara entre Coligadas e Filais Protheus x RM.
    @type  Function
    @author Leonardo P. Monteiro
    @since 20/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE069P()
/*/

Static cTitulo := "..:: Cadastro de Coligadas/Filiais Protheus x RM ::.."

User Function ADGPE069P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE069P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI2")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( "ZI2->ZI2_MSBLQL == '1' ", "BR_VERMELHO"     ,  "Registro Bloqueado." )
    oBrowse:AddLegend( "ZI2->ZI2_MSBLQL != '1' ", "BR_VERDE"        ,  "REgistro Ativo." )
    
    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE069P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE069P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE069P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE069P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE069P",, {|| .T.})
 Local oStrutZI2	:= FWFormStruct(1,"ZI2")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZI2",nil,oStrutZI2)

 oModel:setPrimaryKey({"ZI2_FILIAL","ZI2_EMPPRO","ZI2_FILPRO"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE069P")
 Local oStrutZI2	:= FWFormStruct(2,"ZI2")
  
 DbSelectArea("ZI2")
 
 ZI2->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZI2",oStrutZI2,"CABEC_ZI2")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZI2","V_CABEC")
  
Return oView
