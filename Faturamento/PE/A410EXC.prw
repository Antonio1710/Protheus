#Include 'Protheus.ch'


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北哪哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪哪哪哪目北
北砅rograma  ?A410EXC   ?Autor  ?William Costa       		?Data ? 25/11/2014 潮?北?		 ?Desc.     ?Cria玢o da regra para ajustar o ZB1 liberado para poder	 潮?北?		  		     ?utilizar o refaturamento de novo 						 潮?北?---------------------------------------------------------------------------------潮?北?				     ?Autor  ?Leonardo Rios - KF System 	?Data ? 13/04/2016 潮?北?		 ?Desc.     ?Cria玢o da fun玢o ValPED010()					 		 潮?北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪哪拇北
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so		 ?SIGAFAT                                                    	 		潮?北?		 ?MATA410 - Pedido de Vendas								     		 潮?北?		 ?Ponto de Entrada para validar a exclus鉶 do pedido de vendas  		 潮?北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
*/
User Function A410EXC()

	Local lRet := .T.
										//Everson - 01/03/2018. Chamado 037261.SalesForce.
	If Alltrim(cEmpAnt) = "01" .And. ! IsInCallStack('RESTEXECUTE') .And. ! IsInCallStack('U_RESTEXECUTE')	//Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804

		/*BEGINDOC
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?		//?Quando o Pedido for deletado sera ajustado o ZB1 liberado ?		//?para poder utilizar o refaturamento de novo. 			  ?		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?		ENDDOC*/
		If Alltrim(SC5->C5_REFATUR) == "S"
			lRet := .T.    

			DBSELECTAREA("ZB1")
			DBSETORDER(2)
			DBGOTOP()	
			IF DBSEEK(xFilial("ZB1")+SC5->C5_NUM)

				RecLock("ZB1",.F.)                                                
				ZB1->ZB1_PEDIDO := ''  //limpa a informa玢o do pedido de venda
				ZB1->ZB1_STATUS := 'I' //muda o status do refaturamento
				ZB1->( MsUnLock() ) // Confirma e finaliza a opera玢o


			ENDIF  

			ZB1->(dbCloseArea())    	

		Endif

		&&Mauricio - 01/10/15 - verificacao para nao excluir um pedido de venda ja excluido...
		DbSelectArea("SC5")
		If Deleted()
			lRet := .F.
		Endif

		/*BEGINDOC
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?		//?Execu玢o da Fun玢o ValPED010() para analisar se este pedido foi gerado a partir da tabela intermedi醨ia PED010. Ap髎 a execu玢o ?		//?da fun玢o ser?verificada se foi permitido a exclus鉶 tanto na valida玢o anterior como na valida玢o na fun玢o ValPED010()	    ?		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?		ENDDOC*/
		lRet := lRet .AND. ValPED010()
		
		//Everson - 01/03/2018. Chamado 037261.
		lRet := lRet .AND. valSalesForce()

	EndIf	

Return lRet
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北哪哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履穆哪履履哪哪哪哪哪目北
北矲un玢o	 ?ValPED010   ?Autor ?Leonardo Rios - KF System  ?Data ?13.04.16 	 潮?北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪哪拇北
北矰escri玢o ?Regra de neg骳io criada para n鉶 permitir excluir um pedido   		 潮?北?		 ?de venda cujo campo C5_CODIGEN (Numerico 10) seja maior que 0 		 潮?北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so		 ?MATA410 - Pedido de Vendas								     		 潮?北?		 ?Ponto de Entrada para validar a exclus鉶 do pedido de vendas  		 潮?北?		 ?Projeto SAG II												 		 潮?北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
*/
Static Function ValPED010()
	Local lRetAux := .T. // Vari醰el respons醰el para retornar se ser?liberado a exclus鉶(lRet:=.T.) ou n鉶(lRet:=.F.)

	//Local lRetAux := IIf(SC5->C5_CODIGEN < 1, .T., .F.) 
	// If !lRetAux

	If !(SC5->C5_CODIGEN <1 ) 
		lRetAux := .F.
		cMensErro := "N鉶 ser?poss韛el executar a exclus鉶 deste pedido porque ele foi gerado a partir da tabela intermedi醨ia SGPED010" 
		U_ExTelaMen("Tratamento de exclus鉶 do pedido!", cMensErro, "Arial", 12, , .F., .T.)
	
	EndIf

Return lRetAux
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北哪哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履穆哪履履哪哪哪哪哪目北
北矲un玢o	 ?valSalesForce   ?Autor ?Everson     - KF System  ?Data ?01.03.18  潮?北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪哪拇北
北矰escri玢o ?Regra de neg骳io criada para n鉶 permitir excluir um pedido   		 潮?北?		 ?de venda cujo campo C5_CODIGEN (Numerico 10) seja maior que 0 		 潮?北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so		 ?MATA410 - Pedido de Vendas								     		 潮?北?		 ?Ponto de Entrada para validar a exclus鉶 do pedido de vendas  		 潮?北?		 ?Projeto SalesForce.											 		 潮?北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
*/
Static Function valSalesForce()

	Local lRetAux := .T. 

/*	If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> "" .And. Upper(Alltrim(cValToChar(SC5->C5_LIBEROK))) <> "S"
		U_ADVEN050P("",.F.,.T., " AND C5_NUM IN ('" + Alltrim(cValToChar(SC5->C5_NUM)) + "') AND C5_XPEDSAL <> '' " , .F. )
		
	EndIf*/

Return lRetAux
