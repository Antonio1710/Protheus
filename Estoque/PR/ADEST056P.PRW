#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} User Function ADEST056P
    Tela de manutenção do cadastro do Estabelecimento.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 23/02/2021
    @version 01
    /*/
User Function ADEST056P()
	Local oBrowser
	
	Private aRotina 	:= MenuDef()

	if type("cFilAnt") == "U"
        RpcsetType(3)
        //Rpcsetenv("01","02","LEONARDO_MONTEIRO","Lodale0!")
        nAlt    := GetScreenRes()[02]*0.965
        nLarg   := GetScreenRes()[01]
    else
        aSize   := MsAdvSize(.T.)
        nAlt    := aSize[06]
        nLarg   := aSize[05]
    endif

	DbSelectArea("ZE0")
	
	// Declara o objeto Browse.
	oBrowser := FWMBrowse():New()
	// Declara o Alias.
	oBrowser:SetAlias("ZE0")
	
	// Declara o tÃ­tulo da tela.
	oBrowser:SetDescription("..:: Cadastro SIGSIF-PGA ::..")
	//oBrowser:DisableDetails()

	// Ativa o objeto Browse.
	oBrowser:Activate()
	
	oBrowser:Destroy()

Return nil

Static Function MenuDef()
	Local aRotina 	:= {}
	/*
	ADD OPTION aRotina Title 'Visualizar' 	Action 'U_ADEST056()' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'InclusÃ£o'		Action 'U_ADEST056()' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 'U_ADEST056()' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 'U_ADEST056()' 	OPERATION 5 ACCESS 0
	*/
    //ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.ADEST055' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' 	Action 'U_ADEST056P()' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'U_ADEST056P()' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 'U_ADEST056P()' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 'U_ADEST056P()' 	OPERATION 5 ACCESS 0
	
Return( aRotina )

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 //Local oModel		:= MPFormModel():New("mdlADEST055",, {|| fVldForm()})
 Local oModel		:= MPFormModel():New("mdlADEST056P",, {|| .T.})
 Local oStrutZE0	:= FWFormStruct(1,"ZE0")
 
 oModel:SetDescription("..:: Cadastro SIGSIF-PGA ::..")
 
 // CabeÃ§alho ZT3 (Pedidos)
 oModel:addFields("CABEC_ZE0",nil,oStrutZE0)

 oModel:setPrimaryKey({"ZE0_FILIAL","ZE0_REGIST"})

return oModel


Static Function viewDef()
 Local oView			:= Nil
 Local oModel		:= FWLoadModel("ADEST056P")
 Local oStrutZE0	:= FWFormStruct(2,"ZE0")
  
 DbSelectArea("ZE0")
 
 ZE0->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZE0",oStrutZE0,"CABEC_ZE0")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZE0","V_CABEC")

 //oView:SetAfterOkButton({|oView|  fButAftAc(oView)})
 oView:SetViewAction("BUTTONOK"		, {|oView| fVldModel(oView)})
Return oView

Static Function fVldModel(oView)

	Local lRet					:= .T.
	Local oModel		:= FWModelActive()
	Local oModCAB		:= oModel:getModel("CABEC_ZE0")
	// Estabelecimento é cadastrado por empresa. Por isso, fazemos a exclusão por filial ou empresa, caso, esteja compartilhado.
	//Local cEstabel		:= oModCAB:getValue("ZE0_REGIST")
	Local nOper         := oView:getOperation()
    
    // Operação de exclusão.
    if nOper == 5
		If MsgYesNo("A exclusão desse estabelecimento de mercado irá excluir todos os relacionamentos de Requisito de Mercado, Mercados, Países e produtos."+chr(13)+chr(10)+;
		" Deseja confirmar essa ação?","Confirmação de Exclusão")
			lRet := .T.
		else
			lRet := .F.
		EndIF

	endif

Return lRet
