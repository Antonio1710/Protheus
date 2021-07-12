#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function ADEST071P
    Rotina para seleção de cliente.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 07/07/2021
    @version 01
	@history Chamado 8465 - Leonardo P. Monteiro - 07/07/2021 - Desenvolvimento inicial.
	
    /*/
Static cTitulo := "Modelo CSI"
 
 
User Function ADEST071P()  //U_ADEST071P()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("ADEST071P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZEL")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    //oBrowse:AddLegend( "ZEL->ZEL_MSBLQL = '2'", "GREEN",  "Ativo" )
    //oBrowse:AddLegend( "ZEL->ZEL_MSBLQL = '1'", "RED",    "Bloqueado" )
     
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 


Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADEST071P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_EC003Leg'       OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADEST071P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADEST071P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADEST071P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADEST071P",, {|| .T.})
 Local oStrutZEL	:= FWFormStruct(1,"ZEL")
 
 oModel:SetDescription("..:: Cadastro Modelos CSI ::..")
 
 // CabeÃ§alho ZT3 (Pedidos)
 oModel:addFields("CABEC_ZEL",nil,oStrutZEL)

 oModel:setPrimaryKey({"ZEL_FILIAL","ZEL_COD"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADEST071P")
 Local oStrutZEL	:= FWFormStruct(2,"ZEL")
  
 DbSelectArea("ZEL")
 
 ZEL->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZEL",oStrutZEL,"CABEC_ZEL")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZEL","V_CABEC")
  
Return oView
