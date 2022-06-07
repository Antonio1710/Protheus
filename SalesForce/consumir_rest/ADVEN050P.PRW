#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'Topconn.ch'
/*/{Protheus.doc} User Function ADVEN050P
	Função para envio de pedidos de venda ao SalesForce. Chamado 037261.
	@type  Function
	@author Everson
	@since 19/12/2017
	@version 01
	@history Everson, 20/04/2020, Chamado 056247 - Tratamento para bloqueio de pedidos de venda vinculados a boletos de pagamentos antecipados.
	@history Everson, 12/08/2020, Chamado 060229 - Tratamento para envio de mensagem de boleto ao Salesforce.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Everson, 18/04/2022, Chamado 71231 - ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN050P(cParamBsc,lAut,lCredito,cExpSql,lAprovFin,lItem,lDtE,_lBon,_lDoa,lPlcLog,nOpc,nBolAnt) //Everson - 20/04/2020. Chamado 056247. // U_ADVEN050P("9A2ZJ6",.F.) // U_ADVEN050P("9A2ZG8",.F.,.F.,,.F.,.T.)

	//Variáveis.
	Local aArea   	:= GetArea()

	Default cParamBsc := ""
	Default lAut	  := .F.
	Default	lCredito  := .F.
	Default cExpSql	  := ""
	Default lItem	  := .F.
	Default lDtE	  := .F.
	Default _lBon	  := .F.
	Default _lDoa	  := .F.
	Default lPlcLog	  := .F.
	Default nOpc      := 0

	Default nBolAnt	  := 0
	
	Private lLibFin	  := lCredito
	Private lAprFin	  := lAprovFin
	Private lDtEntr	  := lDtE
	Private lBon	  := _lBon
	Private lDoa	  := _lDoa
	Private lPlaca	  := lPlcLog	
	Private nExecStat := nOpc

	Private aChkStat  := {}

	Private nBoleto	  := nBolAnt //Everson - 20/04/2020. Chamado 056247.
	
	Conout("ADVEN050P - >>>>>>>>>>>>>>>>>> ADVEN050P nOpc " + cValToChar(nOpc) )
	
	//	
	If ! lAut
		MsAguarde({|| Processar(cParamBsc,lCredito,lAprovFin,lItem,lDtE,cExpSql,lAut,nOpc) },"Aguarde","Enviando registros(SF)...")
	
	Else
		//Checa duplicidade de Id Salesforce.

	    Processar(cParamBsc,lCredito,lAprovFin,lItem,lDtE,cExpSql,lAut,nOpc)          
		
		//
		/*CONOUT("U_ADVEN087P >>>>>>>>>>>>>> " + cValToChar(IsInCallStack("U_ADVEN087P")))
		If IsInCallStack("U_ADVEN087P")
			Conout("ADVEN050P - >>>> Checagem de duplicidade de Id " + cValToChar(nAux) )
			nAux++
			chkDuplic(lAut)
			While chkDuplic(lAut) > 0 .And. nAux < 10
				nAux++
				Conout("ADVEN050P - >>>> Checagem de duplicidade de Id " + cValToChar(nAux) )
				Processar(cParamBsc,lCredito,lAprovFin,lItem,lDtE,cExpSql,lAut,nOpc)
				
			EndDo
		
		EndIf*/
	
	EndIF
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} Processar
	Aprovação ou reprovação de pedido pelo crédito. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 22/02/2018
	@version 01
	/*/
Static Function Processar(cPedido,lCredito,lAprovFin,lItem,lDtE,cExpSql,lAut,nOpc)

	//Variáveis.
	Local aParametros := {}
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Order/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "pedido"
	Local cChvExt	:= "Codigo_Protheus__c/"
	Local aRetOk	:= {}
	Local lMetodo	:= Iif(lCredito .Or. lPlaca,.T.,.F.)
	
	Default nOpc    := 0
	
	conout("ADVEN050P - >>>>>>>>>>>>>>>>>> Processar nOpc " + cValToChar(nOpc)) 
	
	//Efetura login no SalesForce.
	//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obtém a query.
	cQuery := scriptSql(cPedido,aResponse,cExpSql)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN050P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"montJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)

	//Processa os registros.
	If  ! lAut
	
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,Iif(lMetodo,.F.,.T.),Iif(lMetodo,"PATCH",""),@aRetOk,Iif(lMetodo,.F.,.T.),.T.,"",.T.,.F.,lCredito) },"Aguarde","Enviando pedidos de venda (SF)...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,Iif(lMetodo,.F.,.T.),Iif(lMetodo,"PATCH",""),@aRetOk,Iif(lMetodo,.F.,.T.),.T.,"",.T.,.F.,lCredito) },"Aguarde","Enviando pedidos de venda (SF)...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,Iif(lMetodo,.F.,.T.),Iif(lMetodo,"PATCH",""),@aRetOk,Iif(lMetodo,.F.,.T.),.T.,"",.T.,.F.,lCredito)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4(@aParametros,Iif(lMetodo,.F.,.T.),Iif(lMetodo,"PATCH",""),@aRetOk,Iif(lMetodo,.F.,.T.),.T.,"",.T.,.F.,lCredito)

		//Static Call(ADVEN075P,ProcessarB,@aParametros,Iif(lMetodo,.F.,.T.),Iif(lMetodo,"PATCH",""),@aRetOk,Iif(lMetodo,.F.,.T.),.T.,"",.T.,.F.)

		If nOpc == 1 .And. ! lLibFin
			Conout("ADVEN050P - 60 segundos para envio das correções de itens de pedido de venda")
			Sleep(60000)
			itemNEnv(lAut,aResponse)
		
		EndIf
			             
	EndIf

Return Nil
/*/{Protheus.doc} itemNEnv
	Função para enviar os itens não processados para SalesForce. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 19/09/2018
	@version 01
	/*/
Static Function itemNEnv(lAut,aResponse)

	//Variáveis.	
	Local aArea	:= GetArea()
	
	//
	Conout("ADVEN050P - Início ADVEN050P - Correção envio de itens de pedido de venda.")
	
	//
	envItens("",lAut,"",aResponse)
	
	//
	Conout("ADVEN050P - Fim ADVEN050P - Correção envio de itens de pedido de venda.")
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} montJson
	Monta json do cabeçalho do pedido. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 19/12/2017
	@version 01
	/*/
Static Function montJson(cMetodo,cChvExt,cNmAlias,aResponse)

	//Variáveis.
	Local cJson	 	:= ""
	Local cData	 	:= ""
	Local cIdVend	:= ""
	Local cCliVdOr	:= ""
	Local cCodVend	:= ""
	
	Local cMen1 	:= ""
	Local cMen2 	:= ""
	Local cMen3 	:= ""
	Local cMen4 	:= ""
	Local cMen5  	:= ""

	Local cPlaca 	:= "" //Everson - 12/08/2020. Chamado 060229.
	
	//
	If nBoleto > 0 //Everson - 20/04/2020. Chamado 056247.

		//
		cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Order"', '"v41.0/sobjects/Order/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
			cJson += '"richInput":{'

				//Everson - 12/08/2020. Chamado 060229.
				cPlaca := Alltrim(cValToChar((cNmAlias)->C5_PLACA))
				If Empty(cPlaca)
					cPlaca := "XXXXXXX"

				EndIf	
				
				//Everson - 12/08/2020. Chamado 060229.
				If nBoleto == 1

					//
					cJson += '"placa__c" : "' + cPlaca + '",'
					cJson += '"Texto_boleto__c" : "' + Alltrim(cValToChar(GetMv("MV_#SFBOLG"))) + '"' //Everson - 12/08/2020. Chamado 060229. //Everson - 12/08/2020. Chamado 060229.

				ElseIf nBoleto == 2

					//
					cJson += '"placa__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_PLACA)) + '",'
					cJson += '"Texto_boleto__c" : ""'

				ElseIf nBoleto == 3 //Everson - 12/08/2020. Chamado 060229.

					//
					cJson += '"placa__c" : "' + cPlaca + '",'
					cJson += '"Texto_boleto__c" : "' + Alltrim(cValToChar(GetMv("MV_#SFBOLA"))) + '"'

				EndIf

			cJson += '}'

	   cJson += '},'		

	ElseIf lLibFin //Liberação/bloqueio o pedido de venda pelo financeiro.
	
		cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Order"', '"v41.0/sobjects/Order/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
			cJson += '"richInput":{'	
				
				//
				If lAprFin
					
					//
					If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) 
						Aadd(aChkStat,{Alltrim(cValtoChar((cNmAlias)->CHVSF)),.T.})
						cJson += '"Status" : "Faturado",'
						
					Else
						Aadd(aChkStat,{Alltrim(cValtoChar((cNmAlias)->CHVSF)),.F.})
						cJson += '"Status" : "' + cValToChar(statipPed(Alltrim(cValToChar((cNmAlias)->C5_NUM)),1)) + '",'
					
					EndIf
					
					//
					If Alltrim(cValToChar((cNmAlias)->C5_XGERSF)) = "1"
						cJson += '"Aprovacao_de_Rede__c":null,'
						
					EndIf
					
					If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) .And. Empty(Alltrim(cValToChar((cNmAlias)->C5_PLACA)))
						cJson += '"placa__c" : "XXXXXXX"'
						
					Else
						cJson += '"placa__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_PLACA)) + '"'
					
					EndIf
				
				Else
					cJson += '"Status" : "Reprovado Financeiro",'
					cJson += '"placa__c" : "XXXXXXX"'
					
				EndIf
				
			cJson += '}'

	   cJson += '},'
	
	ElseIf lPlaca //Envio de placa.
		
		cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Order"', '"v41.0/sobjects/Order/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
			cJson += '"richInput":{'	
			
				//
				If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) 
					cJson += '"Status" : "Faturado",'
					
				Else
					cJson += '"Status" : "' + cValToChar(statipPed(Alltrim(cValToChar((cNmAlias)->C5_NUM)),1)) + '",'
				
				EndIf

				//
				If Alltrim(cValToChar((cNmAlias)->C5_XGERSF)) = "1"
					cJson += '"Aprovacao_de_Rede__c":null,'
					
				EndIf
								
				If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) .And. Empty(Alltrim(cValToChar((cNmAlias)->C5_PLACA)))
					cJson += '"placa__c" : "XXXXXXX"'
					
				Else
					cJson += '"placa__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_PLACA)) + '"'
				
				EndIf
				
			cJson += '}'

	   cJson += '},'
	   	  
	ElseIf lDtEntr //Alteração de data de entrega do pedido de venda.
	
		cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Order"', '"v41.0/sobjects/Order/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
			cJson += '"richInput":{'	

				cData := cValToChar((cNmAlias)->C5_DTENTR)
				cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
				
				//
				If Alltrim(cValToChar((cNmAlias)->C5_XGERSF)) = "1"
					cJson += '"Aprovacao_de_Rede__c":null,'
					
				EndIf
			
				cJson += '"Data__c" : "' + cData + '"'				
		
			cJson += '}'

	   cJson += '},'		
		
	Else
		
		//Obtém o código de vendedor de agrupamento no cadastro do cliente.
		cCodVend := Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + Alltrim(cValtoChar((cNmAlias)->C5_VEND1)), "A3_XAGRSF" )))
		
		//Se não houver código de agrupamento, considera o código de vendedor no pedido de venda.
		If Empty(cCodVend)
			cCodVend := Alltrim(cValtoChar((cNmAlias)->C5_VEND1))
			
		EndIf
		
		//Obtém o Id de usuário do Salesforce.
		cIdVend := Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + cCodVend, "A3_XIDSF" )))
		
		If Empty(cIdVend)
			//Static Call(ADVEN075P,chkVend,aResponse,@cIdVend,cCodVend)
			//@history Ticket 70142 , Edvar   / Flek Solution , 23/03/2022 , Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A6( aResponse,@cIdVend,cCodVend )
			cIdVend := StrTran(cIdVend,"'","")
		
		EndIf

		//
		cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Order"', '"v41.0/sobjects/Order/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
			cJson += '"richInput":{'	
		
				If cMetodo == "POST"
					cJson += '"Codigo_Protheus__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_NUM)) + '",'
			
				EndIf
				
				cJson += '"Pricebook2": {"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_TABELA)) + '"},'
				
				//
				If IsInCallStack("U_ADVEN087P") .And. Empty(Alltrim(cValToChar((cNmAlias)->IDSALES)))
					cJson += '"Status" : "Aprovado Financeiro",'
					
				Else
					
					If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) 
						cJson += '"Status" : "Faturado",'
							
					ElseIf Alltrim(cValToChar((cNmAlias)->C5_BLQ)) == "1"
						cJson += '"Status" : "Pendente Comercial",'
											
					Else
						cJson += '"Status" : "' + cValToChar(statipPed(Alltrim(cValToChar((cNmAlias)->C5_NUM)),1)) + '",'
					
					EndIf
				
				EndIF
				
				//
				If lBon
					cJson += '"Type" : "Bonificação",'
				
				ElseIf lDoa
					cJson += '"Type" : "Doação",'
		
				Else
					cJson += '"Type" : "'   + cValToChar(statipPed(Alltrim(cValToChar((cNmAlias)->C5_NUM)),2)) + '",'
				
				EndIf
				
				//
				cJson += '"Account" : {"Chave_Externa__c": "' + Alltrim(cValToChar((cNmAlias)->C5_CLIENTE)) + Alltrim(cValToChar((cNmAlias)->C5_LOJACLI)) + '"},'
				cJson += '"Condicao_de_Pagamento__r" : {"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_CONDPAG)) + '"},'
				cJson += '"Tipo_Frete__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_TPFRETE)) + '",'
				cJson += '"OwnerId" : "' + cIdVend + '",'
				
				//Data de entrega.
				cData := cValToChar((cNmAlias)->C5_DTENTR)
				cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
				cJson += '"Data__c" : "' + cData + '",'
				
				//Data de emissão.
				cData := cValToChar((cNmAlias)->C5_EMISSAO)
				cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)			
				cJson += '"EffectiveDate" : "' + cData + '",'
				
				cMen1 := StrTran(FwCutOff(Alltrim(cValToChar((cNmAlias)->C5_MENNOTA)),.F.),'"','')
				cMen2 := StrTran(FwCutOff(Alltrim(cValToChar((cNmAlias)->C5_MENNOT2)),.F.),'"','')
				cMen3 := StrTran(FwCutOff(Alltrim(cValToChar((cNmAlias)->C5_MENNOT3)),.F.),'"','')
				cMen4 := StrTran(FwCutOff(Alltrim(cValToChar((cNmAlias)->C5_MENNOT4)),.F.),'"','')
				cMen5 := StrTran(FwCutOff(Alltrim(cValToChar((cNmAlias)->C5_MENNOT5)),.F.),'"','')
				
				cJson += '"Mensagem_Nota_1__c":"' + cMen1 + '",'
				cJson += '"Mensagem_Nota_2__c":"' + cMen2 + '",'
				cJson += '"Mensagem_Nota_3__c":"' + cMen3 + '",'
				cJson += '"Mensagem_Nota_4__c":"' + cMen4 + '",'
				cJson += '"Mensagem_Nota_5__c":"' + cMen5 + '",'
				
				//Pedido de venda à ordem.
				If ! Empty( Alltrim(cValToChar((cNmAlias)->C5_XPEDORD)) )
					cCliVdOr := Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + Alltrim(cValToChar((cNmAlias)->C5_XPEDORD)),"C5_CLIENTE"))) + Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + Alltrim(cValToChar((cNmAlias)->C5_XPEDORD)),"C5_LOJACLI")))
					cJson += '"Cliente_Venda_Ordem__r":{"Code__c":"' + cCliVdOr + '"},'
					cJson += '"Pedido_Venda_Ordem__r":{"Codigo_Protheus__c":"' + Alltrim(cValToChar((cNmAlias)->C5_XPEDORD)) + '"},'
				
				EndIf
				
				//
				If Alltrim(cValToChar((cNmAlias)->C5_XGERSF)) = "1"
					cJson += '"Aprovacao_de_Rede__c":null,'
					
				EndIf
				
				cJson += '"Operador_Logistico__c":"' + Alltrim(cValToChar((cNmAlias)->C5_OPLOG)) + '",'
				
				If ! Empty(Alltrim(cValToChar((cNmAlias)->C5_NOTA))) .And. ! Empty(Alltrim(cValToChar((cNmAlias)->C5_SERIE))) .And. Empty(Alltrim(cValToChar((cNmAlias)->C5_PLACA)))
					cJson += '"placa__c" : "XXXXXXX"'
					
				Else
					cJson += '"placa__c" : "' + Alltrim(cValToChar((cNmAlias)->C5_PLACA)) + '"'
				
				EndIf
				
			cJson += '}'

	   cJson += '},'
	
	EndIf
	
Return cJson
/*/{Protheus.doc} statipPed 
	Checa status do pedido e tipo de pedido. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 09/03/2018
	@version 01
	/*/
Static Function statipPed(cPed,nOpc)

	//Variáveis.	
	Local aArea	  := GetArea()
	Local cRet	  := ""
	Local cQuery  := ""
	Local cTesDoa := Alltrim(GetMv("MV_XTESDOA"))
	Local cTesBoQ := Alltrim(GetMv("MV_XTESBOQ"))
	
	Default nOpc  := 1
	
	//
	If nOpc == 1     // Status do Pedido.
	
		cRet := "Aprovado Financeiro"
		cQuery := " SELECT C9_PEDIDO, C9_BLCRED  FROM " + RetSqlName("SC9") + " AS SC9 WHERE C9_FILIAL = '" + FwxFilial("SC9") + "' AND C9_PEDIDO = '" + cPed + "' AND SC9.D_E_L_E_T_ = '' " //Everson, 18/04/2022, Chamado 71231.
		
		TcQuery cQuery New Alias "BLOQ"
		DbSelectArea("BLOQ")
		BLOQ->(DbGoTop())
		If (BLOQ->(Eof()))
			cRet := "Pendente Financeiro"
			
		EndIf
		
		//
		While ! (BLOQ->(Eof()))
			
			If Alltrim(cValToChar(BLOQ->C9_BLCRED)) <> "" .And. Alltrim(cValToChar(BLOQ->C9_BLCRED)) <> "10"
				cRet := "Pendente Financeiro"
				Exit 
			EndIf
			
			BLOQ->(DbSkip())
		EndDo
		BLOQ->(DbCloseArea())
	
	ElseIf nOpc == 2
			
		cRet := ""
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		If SC6->(DbSeek(xFilial("SC6") + cPed ))
		
			While !Eof() .And. SC6->C6_NUM == cPed
				
				//Bonificação.
				If Alltrim(SC6->C6_TES) $ cTesDoa
					cRet := "Bonificação"	
							
				Endif
				
				//Doação.
				If Alltrim(SC6->C6_TES) $ cTesBoQ
					cRet := "Doação"
					
				Endif

				SC6->(DbSkip())

			EndDo

		EndIf
		
		//Pedido venda ordem.
		cPedVdOr := Alltrim(cValToChar(Posicione("SC5",21,xFilial("SC5") + cPed,"C5_NUM")))
		If ! Empty(cPedVdOr)
			cRet := "Venda à ordem"
			
		EndIf
		
		//
		If Empty(cRet)
			cRet := "Pedido de venda"
		
		EndIf
			
	EndIf
	
	//
	RestArea(aArea)
	
Return cRet
/*/{Protheus.doc} scriptSql 
	Script sql para consulta. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 04/01/2018
	@version 01
	/*/
Static Function scriptSql(cParamBsc,aResponse,cExpSql)

	//Variáveis.
	Local cQuery 	:= ""	

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	cQuery := ""
	cQuery += " SELECT 'SC5' AS TAB, C5_NUM AS CHVSF, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_TABELA, C5_DTENTR, " 
	cQuery += " C5_VEND1, C5_CODRED, C5_XIPTAB, C5_MENNOTA, C5_MENNOT2, C5_MENNOT3, C5_MENNOT4, C5_MENNOT5, C5_TOTDIG, C5_OPLOG, "
	cQuery += " C5_XPEDORD, C5_VALORNF, C5_FRETAPV, C5_TPFRETE, C5_TOTTAB, C5_VOLUME1, C5_CONDPAG, C5_BLQ, C5_XPEDSAL AS IDSALES, "
	cQuery += " C5_FLAGFIN, C5_PLACA, C5_NOTA, C5_SERIE, C5_XGERSF "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " WHERE " 
	
	cQuery += " C5_FILIAL = '" + FwxFilial("SC5") + "' AND C5_MOEDA = '1' AND C5_APRVDOA = '' AND C5_TABELA <> '' AND C5_TIPO = 'N' " //Everson, 18/04/2022, Chamado 71231.
	
	If ! lLibFin .And. ! nBoleto > 0 // Se não for rotina de mundança de status de pedidos de venda. //Everson - 20/04/2020. Chamado 056247.
		
		cQuery += " AND SC5.D_E_L_E_T_ = '' AND SC5.C5_NOTA <> '' AND SC5.C5_SERIE <> '' AND SC5.C5_SERIE <> 'XXX' "
		
	EndIf
	
	//
	cQuery += " AND C5_VEND1 IN "
	cQuery += " ( 
	
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE1.CODV AS A3_COD "
		cQuery += " FROM "
		cQuery += " (SELECT DISTINCT A3_COD AS CODV, CASE WHEN A3_XAGRSF = '' OR A3_XAGRSF IS NULL THEN A3_COD ELSE A3_XAGRSF END AS A3_COD, A3_XAGRSF FROM " + RetSqlName("SA3") + " AS SA3 WHERE SA3.A3_FILIAL = '" + FWxFilial("SA3") + "' AND SA3.D_E_L_E_T_ = '') AS FONTE1 " //Everson, 18/04/2022, Chamado 71231.
		cQuery += " INNER JOIN "
		cQuery += " (SELECT A3_COD, A3_XIDSF FROM " + RetSqlName("SA3") + " AS SA3 WHERE SA3.A3_FILIAL = '" + FwxFilial("SA3") + "' AND SA3.D_E_L_E_T_ = '' AND A3_XSALES = '2') AS FONTE2 " //Everson, 18/04/2022, Chamado 71231.
		cQuery += " ON FONTE1.A3_COD = FONTE2.A3_COD "
	
	cQuery += " )"

	//
	If ! Empty(cParamBsc)
		cQuery += " AND C5_NUM = '" + cParamBsc + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
		
	EndIf

	cQuery += " ORDER BY C5_NUM " 

Return cQuery
/*/{Protheus.doc} envItens 
	Processamento dos envios (itens). Chamado 037261.
	@type  Static Function
	@author Everson
	@since 10/01/2018
	@version 01
	/*/
Static Function envItens(cParamBsc,lAut,cChvTab,aResponse,cMetodo,lItem)

	//Variáveis.
	Local aParametros := {}
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/OrderItem/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "item pedido de venda"
	Local cChvExt	:= "Chave_Externa__c/"
	Local cMsg		:= ""
	Local loginSF	:= .F.
	Local aRetOk    := {}
	
	Default lItem	:= .F.
	
	
	Default aResponse := {}
	
	//
	If Len(aResponse) <= 0

		//Efetura login no SalesForce.
		//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    	lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)
	
		//
		If ! lLogin
			Return Nil
	
		EndIf		
	
	EndIf

	//Obtém a query.
	cQuery := iscriptSql(cParamBsc)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN050P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"imontJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)

	//Processa os registros em lote.
	If  ! lAut
		
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) itens ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) itens ...",.T.)
		
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,,{}) },"Aguarde","Processando registro(s) itens ...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F. )
		
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,,{})

	EndIf

Return Nil
/*/{Protheus.doc} imontJson 
	Monta json. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 05/01/2018
	@version 01
	/*/
Static Function imontJson(cMetodo,cChvExt,cNmAlias)

	//Variáveis.
	Local cJson	 	:= ""
	Local cTabela	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + Alltrim(cValToChar((cNmAlias)->C6_NUM)) ,"C5_TABELA")))

	//
	cJson += '{'
	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/OrderItem"', '"v41.0/sobjects/OrderItem/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
	cJson += '"richInput":{'

			If cMetodo == "POST"
				cJson += '"Order":{"Codigo_Protheus__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_NUM)) + '"},'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_NUM)) + Alltrim(cValToChar((cNmAlias)->C6_PRODUTO)) + '",'
				cJson += '"PricebookEntry" : {"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_PRODUTO)) + cTabela + '"},'
		
			EndIf

			cJson += '"Preco_de_venda__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_PRCVEN)) + '",'
			cJson += '"Tab_FOB__c" : "' + Alltrim(cValToChar((cNmAlias)->PRCFOB)) + '",'
			cJson += '"Preco_Minimo_Supervisor__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_PLTSP)) + '",'
			cJson += '"Desconto_Comercial__c" : "' + cValToChar(Val(cValToChar((cNmAlias)->A1_DESC))/100) + '",'
			cJson += '"Custo__c" : "' + Alltrim(cValToChar((cNmAlias)->PRCCUST)) + '",'
			cJson += '"Frete__c" : "' + Alltrim(cValToChar((cNmAlias)->FRETE)) + '",'
			cJson += '"Alcada_Vendedor__c" : "' + Alltrim(cValToChar((cNmAlias)->ALCAVND)) + '",'
			cJson += '"Quantity" : "' + Alltrim(cValToChar((cNmAlias)->C6_QTDVEN)) + '",'
			cJson += '"Codigo_Produto__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_PRODUTO)) + '",'
			cJson += '"Preco_Tabela_IP__c" : "' + Alltrim(cValToChar((cNmAlias)->PRCIP)) + '",'
			cJson += '"UnitPrice" : "' + Alltrim(cValToChar((cNmAlias)->C6_PRCVEN)) + '",'
			cJson += '"Preco_Minimo_CIA__c" : "' + Alltrim(cValToChar((cNmAlias)->VL_MIN)) + '",'
			cJson += '"Preco_Minimo_Vendedor__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_PLTVD)) + '",'
			cJson += '"Volume_Kg__c" : "' + Alltrim(cValToChar((cNmAlias)->C6_QTDVEN)) + '"'
	
		cJson += '}'

	cJson += '},'

Return cJson
/*/{Protheus.doc} iscriptSql 
	Script sql para consulta itens. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 15/01/2018
	@version 01
	/*/
Static Function iscriptSql(cParamBsc)

	//Variáveis.
	Local cQuery := ""	
	Local cTabIP := Alltrim(cValToChar( GetMv("MV_#SFTBIP") ))
	
	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))
	
	If ! Empty(cParamBsc)
		Conout("ADVEN050P - >>>>>>>>>>>>>>>Envio de item de pedido de venda com parâmetro")
		cQuery := ""
		cQuery +=" SELECT 'SC6' AS TAB, RTRIM(LTRIM(C6_NUM)) + RTRIM(LTRIM(C6_PRODUTO)) AS CHVSF, C6_NUM, C6_CLI, C6_LOJA, C6_PRODUTO, C6_PRCVEN, C6_QTDVEN, "
		cQuery +=" B1_CONV,B1_TIPCONV, A1_DESC, ISNULL(CASE WHEN VLRFRT.FRTREG IS NULL THEN VLRFRT.FRTEST ELSE VLRFRT.FRTREG END,0) AS FRETE, "
		cQuery +=" MAXI.DA1_XPRLIQ AS VL_MAX, MINI.DA1_XPRLIQ AS VL_MIN, C6_PLTSP, C6_PLTVD, C6_PRCVEN, IP.DA1_XPRLIQ AS PRCIP, FOB.DA1_XPRLIQ AS PRCFOB, "
		cQuery +=" A1_TABELA, ISNULL(CUSTO.ZZS_VALOR,0) AS PRCCUST, SC5.C5_BLQ, ((100-FOB.DA0_XVENDE)/100) AS ALCAVND, C6_PRTABV, C6_XIDSF AS IDSALES "
		cQuery +=" FROM "
		cQuery +=" " + RetSqlName("SC6") + " AS SC6 "
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SB1") + " AS SB1 "
		cQuery +=" ON C6_PRODUTO = B1_COD "
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SA1") + " AS SA1 "
		cQuery +=" ON C6_CLI = A1_COD "
		cQuery +=" AND C6_LOJA = A1_LOJA "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT "
		cQuery +=" CC2_EST, CC2_CODMUN, CC2_XREGIA, FRTREG.ZZI_VALOR AS FRTREG, FRTEST.ZZI_VALOR AS FRTEST "
		cQuery +=" FROM "
		cQuery +=" " + RetSqlName("CC2") + " AS CC2 "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZI_REGIAO,ZZI_VALOR FROM " + RetSqlName("ZZI") + " AS ZZI WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "' AND ZZI.D_E_L_E_T_ = '') AS FRTREG "
		cQuery +=" ON CC2_XREGIA = FRTREG.ZZI_REGIAO "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZI_ESTADO, MAX(ZZI_VALOR) AS ZZI_VALOR FROM " + RetSqlName("ZZI") + " AS ZZI WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "' AND ZZI.D_E_L_E_T_ = '' GROUP BY ZZI_ESTADO) AS FRTEST "
		cQuery +=" ON CC2_EST = FRTEST.ZZI_ESTADO "
		cQuery +=" WHERE "
		cQuery +=" CC2_FILIAL = '" + FWxFilial("CC2") + "' AND CC2.D_E_L_E_T_ = '') AS VLRFRT "
		cQuery +=" ON A1_EST = VLRFRT.CC2_EST "
		cQuery +=" AND A1_COD_MUN = VLRFRT.CC2_CODMUN "
		
		//Tabela de preço máximo.
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FwxFilial("DA1") + "' AND DA1_CODTAB IN ('Y00') AND DA1.D_E_L_E_T_ = '') AS MAXI " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = MAXI.DA1_CODPRO "
		
		//Tabela de preço mínimo.
		cQuery +=" LEFT OUTER JOIN  "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FwxFilial("DA1") + "' AND DA1_CODTAB IN ('Z01') AND DA1.D_E_L_E_T_ = '') AS MINI " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = MINI.DA1_CODPRO "
		
		//Tabela IP.
		cQuery +=" LEFT OUTER JOIN  "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FwxFilial("DA1") + "' AND DA1_CODTAB IN ('" + cTabIP + "') AND DA1.D_E_L_E_T_ = '') AS IP " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = IP.DA1_CODPRO "
		
		//Preço FOB.
		cQuery +=" INNER JOIN "
		cQuery +=" ( "
		cQuery +=" SELECT DA1_CODTAB, DA1_CODPRO, DA1_XPRLIQ, DA1_VLRDES, DA0_XVENDE "
		cQuery +=" FROM " 
		cQuery +=" " + RetSqlName("DA1") + " AS DA1 " 
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("DA0") + " AS DA0 ON "
		cQuery +=" DA1_FILIAL = DA0_FILIAL "
		cQuery +=" AND DA1_CODTAB = DA0_CODTAB "
		cQuery +=" WHERE "
		cQuery +=" DA1_FILIAL = '" + FWxFilial("DA1") + "' " 
		cQuery +=" AND DA1.D_E_L_E_T_ = '' "
		cQuery +=" AND DA0.D_E_L_E_T_ = '' "
		cQuery +=" ) AS FOB "
		cQuery +=" ON A1_TABELA = FOB.DA1_CODTAB "
		cQuery +=" AND C6_PRODUTO = FOB.DA1_CODPRO "
		
		//Cabeçalho do pedido de venda.
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SC5") + " AS SC5 ON "
		cQuery +=" C6_FILIAL = C5_FILIAL "
		cQuery +=" AND C6_NUM = C5_NUM "
		
		//Preço custo.
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZS_DATA, ZZS_GRUPO, ZZS_VALOR FROM " + RetSqlName("ZZS") + " AS ZZS WHERE ZZS_FILIAL = '" + FWxFilial("ZZS") + "' AND ZZS.D_E_L_E_T_ = '') AS CUSTO "
		cQuery +=" ON SC5.C5_EMISSAO = CUSTO.ZZS_DATA "
		cQuery +=" AND B1_GRUPO = CUSTO.ZZS_GRUPO "
	
		cQuery +=" WHERE "
		cQuery +=" C6_FILIAL = '" + FWxFilial("SC6") + "' "
		cQuery +=" AND C6_NUM = '" + cParamBsc + "' "
		cQuery +=" AND C6_UNSVEN > 0 "
		cQuery +=" AND SC6.D_E_L_E_T_ = '' "
		cQuery +=" AND SB1.D_E_L_E_T_ = '' "
		cQuery +=" AND SA1.D_E_L_E_T_ = '' "
		cQuery +=" ORDER BY C6_NUM, C6_ITEM "
	
	Else
		Conout("ADVEN050P - >>>>>>>>>>>>>>>Envio de item de pedido de venda sem parâmetro")
		cQuery := ""
		cQuery +=" SELECT 'SC6' AS TAB, RTRIM(LTRIM(C6_NUM)) + RTRIM(LTRIM(C6_PRODUTO)) AS CHVSF, C6_NUM, C6_CLI, C6_LOJA, C6_PRODUTO, C6_PRCVEN, C6_QTDVEN, "
		cQuery +=" B1_CONV,B1_TIPCONV, A1_DESC, ISNULL(CASE WHEN VLRFRT.FRTREG IS NULL THEN VLRFRT.FRTEST ELSE VLRFRT.FRTREG END,0) AS FRETE, "
		cQuery +=" MAXI.DA1_XPRLIQ AS VL_MAX, MINI.DA1_XPRLIQ AS VL_MIN, C6_PLTSP, C6_PLTVD, C6_PRCVEN, IP.DA1_XPRLIQ AS PRCIP, FOB.DA1_XPRLIQ AS PRCFOB, "
		cQuery +=" A1_TABELA, ISNULL(CUSTO.ZZS_VALOR,0) AS PRCCUST, SC5.C5_BLQ, ((100-FOB.DA0_XVENDE)/100) AS ALCAVND, C6_PRTABV, C6_XIDSF AS IDSALES "
		cQuery +=" FROM "
		cQuery +=" " + RetSqlName("SC6") + " AS SC6 "
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SB1") + " AS SB1 "
		cQuery +=" ON C6_PRODUTO = B1_COD "
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SA1") + " AS SA1 "
		cQuery +=" ON C6_CLI = A1_COD "
		cQuery +=" AND C6_LOJA = A1_LOJA "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT "
		cQuery +=" CC2_EST, CC2_CODMUN, CC2_XREGIA, FRTREG.ZZI_VALOR AS FRTREG, FRTEST.ZZI_VALOR AS FRTEST "
		cQuery +=" FROM "
		cQuery +=" " + RetSqlName("CC2") + " AS CC2 "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZI_REGIAO,ZZI_VALOR FROM " + RetSqlName("ZZI") + " AS ZZI WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "' AND ZZI.D_E_L_E_T_ = '') AS FRTREG "
		cQuery +=" ON CC2_XREGIA = FRTREG.ZZI_REGIAO "
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZI_ESTADO, MAX(ZZI_VALOR) AS ZZI_VALOR FROM " + RetSqlName("ZZI") + " AS ZZI WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "' AND ZZI.D_E_L_E_T_ = '' GROUP BY ZZI_ESTADO) AS FRTEST "
		cQuery +=" ON CC2_EST = FRTEST.ZZI_ESTADO "
		cQuery +=" WHERE "
		cQuery +=" CC2.D_E_L_E_T_ = '') AS VLRFRT "
		cQuery +=" ON A1_EST = VLRFRT.CC2_EST "
		cQuery +=" AND A1_COD_MUN = VLRFRT.CC2_CODMUN "
		
		//Tabela de preço máximo.
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FWxFilial("DA1") + "' AND DA1_CODTAB IN ('Y00') AND DA1.D_E_L_E_T_ = '') AS MAXI " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = MAXI.DA1_CODPRO "
		
		//Tabela de preço mínimo.
		cQuery +=" LEFT OUTER JOIN  "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FWxFilial("DA1") + "' AND DA1_CODTAB IN ('Z01') AND DA1.D_E_L_E_T_ = '') AS MINI " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = MINI.DA1_CODPRO "
		
		//Tabela IP.
		cQuery +=" LEFT OUTER JOIN  "
		cQuery +=" (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " AS DA1 WHERE DA1_FILIAL = '" + FWxFilial("DA1") + "' AND DA1_CODTAB IN ('" + cTabIP + "') AND DA1.D_E_L_E_T_ = '') AS IP " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" ON B1_COD = IP.DA1_CODPRO "
		
		//Preço FOB.
		cQuery +=" INNER JOIN "
		cQuery +=" ( "
		cQuery +=" SELECT DA1_CODTAB, DA1_CODPRO, DA1_XPRLIQ, DA1_VLRDES, DA0_XVENDE "
		cQuery +=" FROM " 
		cQuery +=" " + RetSqlName("DA1") + " AS DA1 " 
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("DA0") + " AS DA0 ON "
		cQuery +=" DA1_FILIAL = DA0_FILIAL "
		cQuery +=" AND DA1_CODTAB = DA0_CODTAB "
		cQuery +=" WHERE "
		cQuery +=" DA1_FILIAL = '" + FWxFilial("DA1") + "' " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" AND DA1.D_E_L_E_T_ = '' "
		cQuery +=" AND DA0.D_E_L_E_T_ = '' "
		cQuery +=" ) AS FOB "
		cQuery +=" ON A1_TABELA = FOB.DA1_CODTAB "
		cQuery +=" AND C6_PRODUTO = FOB.DA1_CODPRO "
		
		//Cabeçalho do pedido de venda.
		cQuery +=" INNER JOIN "
		cQuery +=" " + RetSqlName("SC5") + " AS SC5 ON "
		cQuery +=" C6_FILIAL = C5_FILIAL "
		cQuery +=" AND C6_NUM = C5_NUM "
		
		//Preço custo.
		cQuery +=" LEFT OUTER JOIN "
		cQuery +=" (SELECT ZZS_DATA, ZZS_GRUPO, ZZS_VALOR FROM " + RetSqlName("ZZS") + " AS ZZS WHERE ZZS_FILIAL = '" + FWxFilial("ZZS") + "' AND ZZS.D_E_L_E_T_ = '') AS CUSTO "
		cQuery +=" ON SC5.C5_EMISSAO = CUSTO.ZZS_DATA "
		cQuery +=" AND B1_GRUPO = CUSTO.ZZS_GRUPO "
	
		cQuery +=" WHERE "
		cQuery +=" SC6.C6_FILIAL = '" + FWxFilial("SC6") + "' " //Everson, 18/04/2022, Chamado 71231.
		cQuery +=" AND SC6.C6_UNSVEN > 0 "
		cQuery +=" AND SC5.C5_XGERSF = '1' "
		cQuery +=" AND SC5.C5_XPEDSAL <> '' "
		cQuery +=" AND SC5.C5_DTENTR >= '" + DToS(Date()-2) + "' "
		//cQuery += " AND DATEDIFF(DAY,C5_DTENTR,GETDATE()) <= 2 " 
		cQuery +=" AND SC6.C6_XIDSF = '' "	
		cQuery +=" AND SC6.D_E_L_E_T_ = '' "
		cQuery +=" AND SB1.D_E_L_E_T_ = '' "
		cQuery +=" AND SA1.D_E_L_E_T_ = '' "
		cQuery +=" ORDER BY C6_NUM, C6_ITEM "
		
	EndIf
	
Return cQuery
/*/{Protheus.doc} mrkReg 
	Marca registro. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 16/03/2018
	@version 01
	/*/
Static Function mrkReg(cChave,lAut,cId,cMetodo,aResponse,cAliasS)

	//Variáveis.
	Local aArea	  := GetArea()
	Local cUpdate := ""
	Local cMsg	  := ""
	Local nPos	  := .F.
	
	//Remove Marca de nota de saída e código da empresa.
	cChave := Alltrim(cValToChar(cChave))
	cId    := Alltrim(cValToChar(cId))
	
	//
	If Empty(cId) .And. !lLibFin
		Return Nil
	
	EndIf
	
	//
	If lLibFin
	
		//
		Conout("ADVEN050P - >>>>>>>>>>>>>>>>>>>>> nExecStat <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " + cValToChar(nExecStat) )
		
		//
		If nExecStat == 0
		
		    Conout("ADVEN050P - Envio status financeiro " + cChave)
		
			If lAprFin .And. !Empty(cChave)
				
				If Len(aChkStat) > 0 .And. Ascan(aChkStat,{|x| x[1] ==  cChave}) > 0
					nPos := Ascan(aChkStat,{|x| x[1] ==  cChave})
					Conout("aChkStat[nPos][2] " + cValToChar(aChkStat[nPos][2]) )
					If aChkStat[nPos][2]
						cUpdate := "  UPDATE " + RetSqlName("SC5") + " SET C5_XSFSTAT = '2' WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND C5_NUM = '" + cChave + "' AND C5_NOTA NOT IN ('XXXXXXXXX','') AND D_E_L_E_T_ = '' "
					
					EndIf
					
				Else
					Conout("ADVEN050P -  Não atualizou status " + cChave)
					
				EndIf
				
			ElseIf !Empty(cChave) //Pedidos reprovados/excluídos.
				cUpdate := "  UPDATE " + RetSqlName("SC5") + " SET C5_XSFSTAT = '2' WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND C5_NUM = '" + cChave + "' AND ( C5_FLAGFIN = 'B' OR D_E_L_E_T_ <> '')  "
				
			EndIf
			
		ElseIf nExecStat == 1 .And. !Empty(cChave)
			cUpdate := "  UPDATE " + RetSqlName("SC5") + " SET C5_XSFSTAT = '3' WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND C5_NUM = '" + cChave + "' "
		
		EndIf
		
		Conout("ADVEN050P - Envio status financeiro " + cChave)
		
	Else
		
		If Alltrim(cValToChar((cAliasS)->TAB)) == "SC5" .And. !Empty(cId) .And. !Empty(cChave)
			Conout("ADVEN050P - Envio cabeçalho SC5 " + cChave)
			cUpdate := "  UPDATE " + RetSqlName("SC5") + " SET C5_XPEDSAL = '" + cId + "' WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND C5_NUM = '" + cChave + "' AND D_E_L_E_T_ = '' "
		
		ElseIf Alltrim(cValToChar((cAliasS)->TAB)) == "SC6" .And. !Empty(cId) .And. !Empty(cChave)
			
			Conout("ADVEN050P - ADVEN050P - Envio item SC6 " + cChave)
			//If checkSC6(cId)
				cUpdate := "  UPDATE " + RetSqlName("SC6") + " SET C6_XIDSF = '" + cId + "' WHERE C6_FILIAL = '" +  FWxFilial("SC6") + "' AND RTRIM(LTRIM(C6_NUM)) + RTRIM(LTRIM(C6_PRODUTO))  = '" + cChave + "' AND D_E_L_E_T_ = '' "
				Conout("ADVEN050P - ADVEN050P - Update envio item SC6 " + cChave)
				Conout("ADVEN050P - UPDATE ITEM >>> " + cUpdate)
			//EndIf
			
		EndIf
		
	EndIf
	
	//Atualiza o registro na SC5.
	If !Empty(cUpdate)
		If TCSqlExec(cUpdate) < 0
			
			cMsg := "Não foi possível atualizar o registro " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
			If !lAut
				MsgAlert(cMsg,"Função mrkReg (ADVEN050P)")
				
			Else
				//Static Call(ADVEN075P,envErros,cMsg + "Função mrkReg (ADVEN050P)")
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A2(cMsg + "Função mrkReg (ADVEN050P)")
				
			EndIf
		
		EndIf
	
	EndIf
	
	//Checa duplicidade de Id Salesforce.
	//chkDuplic(lAut)
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} checkSC6 
	Checa registro SC6. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 25/09/2018
	@version 01
	/*/
Static Function checkSC6(cId)

	//Variáveis.	
	Local aArea	 := GetArea()
	Local cQuery := ""
	Local lRet	 := .T.
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(C6_NUM))+RTRIM(LTRIM(C6_PRODUTO)) AS CHV " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 " 
	cQuery += " WHERE " 
	cQuery += " C6_FILIAL = '" +  FWxFilial("SC6") + "' " 
	cQuery += " AND C6_XIDSF = '" + cId + "' " 
	cQuery += " AND SC6.D_E_L_E_T_ = '' " 
	
	//
	If Select("ID_SC6") > 0
		ID_SC6->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "ID_SC6"
	DbSelectArea("ID_SC6")
	ID_SC6->(DbGoTop())
	
	If ! ID_SC6->(Eof())
		Conout("ADVEN050P - >>>>> Já há registro para o Id " + cId + " >>>>> " + Alltrim(cValToChar(ID_SC6->CHV)) )
		lRet := .F.
		
	EndIf
	
	//
	ID_SC6->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} chkDuplic 
	Checa id's duplicados. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 04/10/2018
	@version 01
	/*/
Static Function chkDuplic(lAut)

	//Variáveis.	
	Local aArea	 := GetArea()	
	Local cQuery := ""
	Local nPedido:= 0
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " COUNT(FONTE.C5_NUM) AS NR_PED " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT C5_NUM FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE SC5.C5_FILIAL = '" +  FWxFilial("SC5") + "' AND CAST(SC5.C5_DTENTR AS DATE) >= CAST(GETDATE()-4 AS DATE) AND SC5.D_E_L_E_T_ = '' AND SC5.C5_XPEDSAL IN ( " 
	cQuery += " SELECT FONTE.C5_XPEDSAL FROM ( " 
	cQuery += " SELECT C5_XPEDSAL, COUNT(C5_NUM) AS TOT_PED FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE SC5.C5_FILIAL = '" +  FWxFilial("SC5") + "' AND SC5.C5_XPEDSAL <> '' AND SC5.D_E_L_E_T_ = '' AND CAST(SC5.C5_DTENTR AS DATE) >= CAST(GETDATE()-60 AS DATE) GROUP BY SC5.C5_XPEDSAL " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.TOT_PED > 1 " 
	cQuery += " ) " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT C6_NUM FROM " + RetSqlName("SC6") + " (NOLOCK) AS SC6 WHERE SC6.C6_FILIAL = '" +  FWxFilial("SC6") + "' AND CAST(SC6.C6_ENTREG AS DATE) >= CAST(GETDATE()-4 AS DATE) AND SC6.D_E_L_E_T_ = '' AND SC6.C6_XIDSF IN( " 
	cQuery += " SELECT FONTE.C6_XIDSF FROM ( " 
	cQuery += " SELECT C6_XIDSF, COUNT(C6_NUM) AS TOT_PED FROM " + RetSqlName("SC6") + " (NOLOCK) AS SC6 WHERE SC6.C6_FILIAL = '" +  FWxFilial("SC6") + "' AND  SC6.C6_XIDSF <> '' AND SC6.D_E_L_E_T_ = '' AND CAST(SC6.C6_ENTREG AS DATE) >= CAST(GETDATE()-60 AS DATE) GROUP BY SC6.C6_XIDSF " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.TOT_PED > 1 " 
	cQuery += " ) " 
	cQuery += " ) AS FONTE " 
	
	//
	If Select("D_DUPPED") > 0
		D_DUPPED->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_DUPPED"
	DbSelectArea("D_DUPPED")
	D_DUPPED->(DbGoTop())
		nPedido := Val(cValToChar(D_DUPPED->NR_PED))
	D_DUPPED->(DbCloseArea())
	
	//
	If nPedido > 0
		rmvDuplic(lAut)
	
	EndIf

	//
	RestArea(aArea)
	
Return nPedido
/*/{Protheus.doc} rmvDuplic 
	Remove id's duplicados. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 03/10/2018
	@version 01
	/*/
Static Function rmvDuplic(lAut)

	//Variáveis.	
	Local aArea	 := GetArea()
	Local cUpSC5 := ""
	Local cUpSC6 := ""
	Local cMsg	 := ""
	
	Conout("ADVEN050P - >>>>>>>>>>>>>>>>>>>> Checa Duplicidade")
	
	cUpSC6 := ""
	cUpSC6 += " UPDATE " + RetSqlName("SC6") + " SET C6_XIDSF = '' WHERE C6_FILIAL = '" +  FWxFilial("SC6") + "' AND CAST(C6_ENTREG AS DATE) >= CAST(GETDATE()-4 AS DATE) AND D_E_L_E_T_ = '' AND C6_NUM IN ( " 
	cUpSC6 += " SELECT C5_NUM FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE SC5.C5_FILIAL = '" +  FWxFilial("SC5") + "' AND SC5.D_E_L_E_T_ = '' AND DATEDIFF(DAY,SC5.C5_DTENTR,GETDATE()) <= 4 AND SC5.C5_XPEDSAL IN ( " 
	cUpSC6 += " SELECT FONTE.C5_XPEDSAL FROM ( " 
	cUpSC6 += " SELECT C5_XPEDSAL, COUNT(C5_NUM) AS TOT_PED FROM " + RetSqlName("SC5") + " WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND C5_XPEDSAL <> '' AND D_E_L_E_T_ = '' AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE()-60 AS DATE) GROUP BY C5_XPEDSAL " 
	cUpSC6 += " ) AS FONTE " 
	cUpSC6 += " WHERE FONTE.TOT_PED > 1 " 
	cUpSC6 += " ) " 
	cUpSC6 += " ) " 

	//
	If TCSqlExec(cUpSC6) < 0

		cMsg := "Não foi possível remover duplicidade 1-SC5/SC6 " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
		Conout(cMsg)
		If !lAut
			MsgAlert(cMsg,"Função mrkReg (ADVEN050P)")
			
		Else
			//Static Call(ADVEN075P,envErros,cMsg + "Função chkDuplic (ADVEN050P)")
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A2( cMsg + "Função chkDuplic (ADVEN050P)" )
			
		EndIf
	
	EndIf	
	
	cUpSC6 := ""
	cUpSC6 += " UPDATE " + RetSqlName("SC6") + " SET C6_XIDSF = '' WHERE C6_FILIAL = '" +  FWxFilial("SC6") + "' AND CAST(C6_ENTREG AS DATE) >= CAST(GETDATE()-4 AS DATE) AND D_E_L_E_T_ = '' AND C6_XIDSF IN( " 
	cUpSC6 += " SELECT FONTE.C6_XIDSF FROM ( " 
	cUpSC6 += " SELECT C6_XIDSF, COUNT(C6_NUM) AS TOT_PED FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = '" +  FWxFilial("SC6") + "' AND C6_XIDSF <> '' AND D_E_L_E_T_ = '' AND CAST(C6_ENTREG AS DATE) >= CAST(GETDATE()-60 AS DATE) GROUP BY C6_XIDSF " 
	cUpSC6 += " ) AS FONTE " 
	cUpSC6 += " WHERE FONTE.TOT_PED > 1 " 
	cUpSC6 += " ) " 

	//
	If TCSqlExec(cUpSC6) < 0

		cMsg := "Não foi possível remover duplicidade 2-SC6 " + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
		Conout(cMsg)
		If !lAut
			MsgAlert(cMsg,"Função mrkReg (ADVEN050P)")
			
		Else
			//Static Call(ADVEN075P,envErros,cMsg + "Função chkDuplic (ADVEN050P)")
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A2( cMsg + "Função chkDuplic (ADVEN050P)" )
			
		EndIf
	
	EndIf	
	
	cUpSC5 := ""
	cUpSC5 += " UPDATE " + RetSqlName("SC5") + " SET C5_XPEDSAL ='', C5_XSFSTAT = '' WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE()-4 AS DATE AND D_E_L_E_T_ = '' AND C5_XPEDSAL IN ( " 
	cUpSC5 += " SELECT FONTE.C5_XPEDSAL FROM ( " 
	cUpSC5 += " SELECT C5_XPEDSAL, COUNT(C5_NUM) AS TOT_PED FROM " + RetSqlName("SC5") + " WHERE C5_FILIAL = '" +  FWxFilial("SC5") + "' AND C5_XPEDSAL <> '' AND D_E_L_E_T_ = '' AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE()-60 AS DATE) GROUP BY C5_XPEDSAL " 
	cUpSC5 += " ) AS FONTE " 
	cUpSC5 += " WHERE FONTE.TOT_PED > 1 " 
	cUpSC5 += " ) " 
	
	//
	If TCSqlExec(cUpSC5) < 0

		cMsg := "Não foi possível remover duplicidade SC5 " + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
		Conout(cMsg)
		If !lAut
			MsgAlert(cMsg,"Função mrkReg (ADVEN050P)")
			
		Else
			//Static Call(ADVEN075P,envErros,cMsg + "Função chkDuplic (ADVEN050P)")
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A2( cMsg + "Função chkDuplic (ADVEN050P)" )
		EndIf	
			
	EndIf

	//
	RestArea(aArea)
	
Return Nil
