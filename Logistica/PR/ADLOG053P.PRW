#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "Totvs.ch"
/*/{Protheus.doc} User Function ADLOG053P
	Cadastro de Negociação de Frete. Chamado 044314.
	@type  Function
	@author Ricardo Lima 
	@since 12/02/2019
	@version 01
	@history Everson-Ch:044314-28/03/2019| Envio do registro para a central de aprovação.                 
	@history Everson-Ch:044314-12/04/2019| Incluida validação na inclusão e alteração do registro.       
	@history Everson-Ch:044314-07/06/2019| Corrigida validação na alteração.                              
	@history Everson-Ch:044314-19/06/2019| Removida validação de data de entrega e implementada nova regra
			 para que seja possível alterar a data de entrega, sem a necessidade de nova aprovação.       
	@history Everson-Ch:044314-27/06/2019| Adicionado log na tabela ZBE.                                 
	@history Everson-Ch:044314-16/07/2019| Validação de motorista vinculado ao veículo.                   
	@history Everson-Ch:044314-05/08/2019| Incluído campos de usuário, data e hora de inclusão/alteração. 
	@history Everson-Ch:044314-13/12/2019| Tratamento para envio de registro para aprovação. 
    /*/
User Function ADLOG053P()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local   oBrowse	:= Nil
    Private aRotina	:= AdMnDf()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Negociação de Frete.')
    
    //
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("ZFF")
	oBrowse:SetDescription("Cadastro de Negociação de Frete Abatido")
	oBrowse:AddLegend("ZFF_APROVA = 'S' .AND. ZFF_USANEG = 'N'","BR_VERDE"    , "Aprovada"  )
	oBrowse:AddLegend("ZFF_APROVA = 'N' .AND. ZFF_USANEG = 'N'","BR_AZUL"     , "Bloqueada" )
	oBrowse:AddLegend("ZFF_APROVA = 'S' .AND. ZFF_USANEG = 'S'","BR_VERMELHO" , "Utilizada" )
	oBrowse:AddLegend("ZFF_APROVA = 'R' .AND. ZFF_USANEG = 'N'","BR_PRETO"    , "Reprovada" ) //Everson-Ch:044314-28/03/2019
	oBrowse:Activate()
	
Return Nil
/*/{Protheus.doc} AdMnDf
	Menu.
	@type  Static Function
	@author user
	@since 13/12/2019
	@version 01
	/*/
Static Function AdMnDf()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRotina := {}
	
	//
	ADD OPTION aRotina TITLE "Visualizar"      	  ACTION "VIEWDEF.ADLOG053P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"         	  ACTION "VIEWDEF.ADLOG053P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"         	  ACTION "VIEWDEF.ADLOG053P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"         	  ACTION "VIEWDEF.ADLOG053P" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"         	  ACTION "U_ADLG0531()"      OPERATION 9 ACCESS 0

Return aRotina
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author 12/02/2019
	@since 13/12/2019
	@version 01
	/*/
Static Function ModelDef()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oModel	:= Nil
	Local oStruZFF	:= FWFormStruct( 1, "ZFF", /*bAvalCampo*/, /*lViewUsado*/ )
    //Local bCommit 	:= {|oModel| ADLG0532(oModel)}
    Local bPosVal	:= {|oModel| ADLG0534(oModel)} //Everson-Ch:044314-28/03/2019
    //Local bPreVal 	:= {|oModel| ADLG0533(oModel)}

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreVal*/ , bPosVal, /*bCommit*/ , /*bCancel*/ ) //Everson-Ch:044314-19/06/2019.

	oModel:SetDescription("Cadastro de Negociação de Frete")
	oModel:AddFields("ZFFMASTER", /*cOwner*/, oStruZFF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZFF_FILIAL" , "ZFF_DTENTR" , "ZFF_PLACA" } )

Return oModel
/*/{Protheus.doc} ViewDef
	View do Model.
	@type  Static Function
	@author Ricardo Lima
	@since 12/02/2019
	@version 01
	/*/
Static Function ViewDef()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oView
	Local oModel   := ModelDef()
	Local oStruZFF := FWFormStruct( 2, "ZFF" )

	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("VIEW_ZFF", oStruZFF, "ZFFMASTER" )
	oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetCloseOnOk( { || .T. } )
    
Return oView
/*/{Protheus.doc} User Function ADLG0531
	Cadastro de Negociação de Frete 
	@type  Function
	@author Ricardo Lima
	@since 12/02/2019
	@version 01
	/*/
User Function ADLG0531()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aLegenda := {}

	U_ADINF009P('ADLOG053P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Negociação de Frete.')

	aAdd(aLegenda,{"BR_VERDE"    ,"Aprovada" })
	aAdd(aLegenda,{"BR_AZUL"     ,"Bloqueada"})
	aAdd(aLegenda,{"BR_VERMELHO" ,"Utilizada"})
	aAdd(aLegenda,{"BR_PRETO"    ,"Reprovada"}) //Everson-Ch:044314-28/03/2019

	BrwLegenda("Cadastro de Negociação de Frete","Legenda",aLegenda)

Return NiL
/*/{Protheus.doc} nomeStaticFunction
	Cadastro de Negociação de Frete
	@type  Static Function
	@author Ricardo Lima
	@since 12/02/2019
	@version 01
	/*/
Static function ADLG0532(oModel)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()
    
    //
    If nOperation == 4
        oModel:SetValue( 'ZFFMASTER' , 'ZFF_APROVA' , 'N' )
        oModel:SetValue( 'ZFFMASTER' , 'ZFF_USRAPR' , '' )
        oModel:SetValue( 'ZFFMASTER' , 'ZFF_NOMAPR' , '' )
        oModel:SetValue( 'ZFFMASTER' , 'ZFF_DTAPR'  , STOD('') )
        oModel:SetValue( 'ZFFMASTER' , 'ZFF_HRAPRO' , '' )
        
	EndIf

	fwformcommit(oModel)
	
Return lRet
/*/{Protheus.doc} ADLG0533
	Cadastro de Negociação de Frete  
	@type  Static Function
	@author Ricardo Lima
	@since 12/02/2019
	@version 01
	/*/
Static Function ADLG0533(oModel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    Local aArea			:= GetArea() //Everson-Ch:044314-28/03/2019
    Local lRet 			:= .T.
    Local nOperation 	:= oModel:GetOperation()
    
    //
    If nOperation == 4 .And. oModel:GetValue( 'ZFFMASTER','ZFF_USANEG' ) = 'S'
        lRet := .F.   
        Help( ,, "Ação não Permitida",, "Não é possível alterar uma negociação já utilizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Cadastre uma nova Negociação de frete"})
    
    EndIf
    
    //
    RestArea(aArea) //Everson-Ch:044314-28/03/2019.
    
Return lRet
/*/{Protheus.doc} ADLG0534
	Pós validação do modelo.   
	@type  Static Function
	@author Everson
	@since 28/03/2019
	@version 01
	/*/
Static Function ADLG0534(oModel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    Local aArea			:= GetArea() //Everson - 27/02/2019. Chamado 044314.
    Local lRet 			:= .T.
    Local nOperation 	:= oModel:GetOperation()
    Local cOcorr		:= GetMv("MV_#ADL461",,"011")
    Local cCod   		:= oModel:GetValue( 'ZFFMASTER' , 'ZFF_COD' )
    Local cLojtr 		:= oModel:GetValue( 'ZFFMASTER' , 'ZFF_LOJTRA' )
    Local cTrans 		:= oModel:GetValue( 'ZFFMASTER' , 'ZFF_CODTRA' )
    Local cPlaca		:= oModel:GetValue( 'ZFFMASTER' , 'ZFF_PLACA' ) //Everson-16/07/2019-Ch:044314.
	Local nVlrFr 		:= oModel:GetValue( 'ZFFMASTER' , 'ZFF_VALOR' )
	Local cDesco 		:= Posicione("ZF7",1, FWxFilial("ZF7") + cOcorr ,"ZF7_DESC" )
   
    //
    If nOperation == 4 .And. oModel:GetValue( 'ZFFMASTER','ZFF_USANEG' ) = 'S'
        lRet := .F.   
        Help( ,, "Ação não Permitida",, "Não é possível alterar uma negociação já utilizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Cadastre uma nova Negociação de frete."})
    
    ElseIf nOperation == 5 .And. oModel:GetValue( 'ZFFMASTER','ZFF_USANEG' ) = 'S'
    	lRet := .F.   
        Help( ,, "Ação não Permitida",, "Não é possível excluir uma negociação já utilizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    
    ElseIf ( nOperation == 3 .Or. nOperation == 4 ) //Everson - 12/04/2019. Chamado 044314.
    	
        //Everson-16/07/2019-Ch:044314.
        DbselectArea("ZV4")
		ZV4->(DbSetOrder(1))
		If ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
			cCpfM     := ZV4->ZV4_CPF
			cNomeMoto := ZV4->ZV4_MOTORI
			
		EndIf
		
		//Everson-16/07/2019-Ch:044314.
		If Empty(cCpfM) .Or. Empty(cNomeMoto)
			Help( ,, "Ação não Permitida",, "Não será possível efetuar o lançamento de frete combinado, pois o veículo informado não possui motorista vinculado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			lRet := .F.
			
		EndIf	
        
        //
	    If lRet
	    	lRet := chkReg(oModel,cCod)
	    
	    EndIf
	    
	    //Everson - 05/08/2019. Chamado 044314.
	    If lRet
	    	oModel:SetValue( 'ZFFMASTER', 'ZFF_INCUSR', cUserName )
	    	oModel:SetValue( 'ZFFMASTER', 'ZFF_HRINC' , Time() )
	    	oModel:SetValue( 'ZFFMASTER', 'ZFF_DTINCL', Date() )
	    	
	    EndIf
        
    EndIf
	
	//Gera registro de aprovação.
	If lRet

		lBlqMov := FWFormCommit(oModel)
		If lBlqMov
			//ADLOG050P( ZFACOD , ZFAOCORRE , ZFALOJTRA , ZFATRANSP , ZFAVALOR , ZFADESCOC , nOpc, cOrigem, cTpBloq )
			//Everson-Ch:044314-19/03/2019
			If nOperation == MODEL_OPERATION_DELETE
				U_ADLOG050P( cCod , cOcorr , cLojtr , cTrans , nVlrFr , cDesco , 5, "ADLOG053P", "000006" ) //Everson - 13/12/2019 - Chamado 029058.
				
			ElseIf ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT ) .And. oModel:GetValue( 'ZFFMASTER','ZFF_APROVA' ) = 'N' //Everson-Ch:044314-19/06/2019.
				U_ADLOG050P( cCod , cOcorr , cLojtr , cTrans , nVlrFr , cDesco , 3, "ADLOG053P", "000006" ) //Everson - 13/12/2019 - Chamado 029058.
				
			EndIf
			
		EndIf
		
	EndIf
	
	//Everson-Ch:044314-27/06/2019.
	If lRet
		logZBE("Frete combinado código " + cValToChar(cCod),"Operação " + cValToChar(nOperation) )
	
	EndIf
    
    //
    RestArea(aArea) 
    
Return lRet
/*/{Protheus.doc} chkReg
	Valida registro
	@type  Static Function
	@author Everson
	@since 12/04/2019
	@version 01
	/*/
Static Function chkReg(oModel,cCod)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    Local aArea	 	:= GetArea()
    Local lRet	 	:= .T.
    Local dDtEntr	:= oModel:GetValue( 'ZFFMASTER','ZFF_DTENTR' )
    Local sCodPlc	:= oModel:GetValue( 'ZFFMASTER','ZFF_PLACA' )
    Local cRoteiro	:= oModel:GetValue( 'ZFFMASTER','ZFF_ROTFRT' )
    
    //
    DbSelectArea("ZFF")
    ZFF->(DbSetOrder(1))
    ZFF->(DbGoTop())
    If ZFF->( ZFF->(DbSeek( FWxFilial("ZFF") + DToS(dDtEntr) + sCodPlc )) )
    	
    	//Everson - 07/06/2019. Chamado 044314.
    	While ZFF->ZFF_FILIAL == FWxFilial("ZFF") .And. ZFF->ZFF_DTENTR == dDtEntr .And. ZFF->ZFF_PLACA == sCodPlc
    	
	    	If ZFF->ZFF_USANEG == "N" .And. cCod <> ZFF->ZFF_COD .And. ZFF->ZFF_ROTFRT == cRoteiro
		    	lRet := .F.
		    	Help( ,, "Ação não Permitida",, "Já uma negociação de frete para a placa, data e roteiro informados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Reveja a data ou placa informadas ou altere o registro já inserido."})
		    	
	    	EndIf
    		
    		ZFF->(DbSkip())
    		
    	End
    	
    EndIf

    //
    RestArea(aArea)
    
Return lRet
/*/{Protheus.doc} logZBE
	Rotina para gerar log na tabela ZBE. 
	@type  Static Function
	@author Everson
	@since 27/06/2019
	@version 01
	/*/
Static Function logZBE(cLog,cParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cLog
		Replace ZBE_PARAME 		With cParam
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG053P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil