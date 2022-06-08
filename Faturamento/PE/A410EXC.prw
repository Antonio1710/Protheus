#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function A410EXC
    Ponto de Entrada para validar a exclus�o do pedido de vendas.
	Cria��o da regra para ajustar o ZB1 liberado para poder utilizar o refaturamento de novo 						 
    @type  Function
    @author William Costa 
    @since 25/11/2014
    @version 01
	@history Leonardo Rios - KF System 	?Data ? 13/04/2016 ��?��?		 ?Desc.     ?Cria��o da fun��o ValPED010()
	@history Everson, 23/03/2022. Chamado 18465. Valida��o de exclus�o de pedido de sa�da com ordem de pesagem vinculada.
	@history Everson, 27/05/2022. Chamado 18465. Valida��o de exclus�o de pedido de sa�da com ordem de pesagem vinculada (trocada fun��o).
/*/
User Function A410EXC()

	Local lRet := .T.
										//Everson - 01/03/2018. Chamado 037261.SalesForce.
	If Alltrim(cEmpAnt) = "01" .And. ! IsInCallStack('RESTEXECUTE') .And. ! IsInCallStack('U_RESTEXECUTE')	//Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804

		/*BEGINDOC
		//������������������������������������������������������������?		//?Quando o Pedido for deletado sera ajustado o ZB1 liberado ?		//?para poder utilizar o refaturamento de novo. 			  ?		//������������������������������������������������������������?		ENDDOC*/
		If Alltrim(SC5->C5_REFATUR) == "S"
			lRet := .T.    

			DBSELECTAREA("ZB1")
			DBSETORDER(2)
			DBGOTOP()	
			IF DBSEEK(xFilial("ZB1")+SC5->C5_NUM)

				RecLock("ZB1",.F.)                                                
				ZB1->ZB1_PEDIDO := ''  //limpa a informa��o do pedido de venda
				ZB1->ZB1_STATUS := 'I' //muda o status do refaturamento
				ZB1->( MsUnLock() ) // Confirma e finaliza a opera��o


			ENDIF  

			ZB1->(dbCloseArea())    	

		Endif

		&&Mauricio - 01/10/15 - verificacao para nao excluir um pedido de venda ja excluido...
		DbSelectArea("SC5")
		If Deleted()
			lRet := .F.
		Endif

		/*BEGINDOC
		//����������������������������������������������������������������������������������������������������������������������������������?		//?Execu��o da Fun��o ValPED010() para analisar se este pedido foi gerado a partir da tabela intermedi�ria PED010. Ap�s a execu��o ?		//?da fun��o ser?verificada se foi permitido a exclus�o tanto na valida��o anterior como na valida��o na fun��o ValPED010()	    ?		//����������������������������������������������������������������������������������������������������������������������������������?		ENDDOC*/
		lRet := lRet .AND. ValPED010()
		
		//Everson - 01/03/2018. Chamado 037261.
		lRet := lRet .AND. valSalesForce()

		//Everson - 23/03/2022. Chamado 018465.
		lRet := lRet .And. U_ADFAT41A(SC5->C5_NUM) //Everson - 27/05/2022. Chamado 018465.

	EndIf	

Return lRet
/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o	 ?ValPED010   ?Autor ?Leonardo Rios - KF System  ?Data ?13.04.16 	 ��?������������������������������������������������������������������������������������Ĵ��
���Descri��o ?Regra de neg�cio criada para n�o permitir excluir um pedido   		 ��?��?		 ?de venda cujo campo C5_CODIGEN (Numerico 10) seja maior que 0 		 ��?������������������������������������������������������������������������������������Ĵ��
���Uso		 ?MATA410 - Pedido de Vendas								     		 ��?��?		 ?Ponto de Entrada para validar a exclus�o do pedido de vendas  		 ��?��?		 ?Projeto SAG II												 		 ��?������������������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Static Function ValPED010()
	Local lRetAux := .T. // Vari�vel respons�vel para retornar se ser?liberado a exclus�o(lRet:=.T.) ou n�o(lRet:=.F.)

	//Local lRetAux := IIf(SC5->C5_CODIGEN < 1, .T., .F.) 
	// If !lRetAux

	If !(SC5->C5_CODIGEN <1 ) 
		lRetAux := .F.
		cMensErro := "N�o ser?poss�vel executar a exclus�o deste pedido porque ele foi gerado a partir da tabela intermedi�ria SGPED010" 
		U_ExTelaMen("Tratamento de exclus�o do pedido!", cMensErro, "Arial", 12, , .F., .T.)
	
	EndIf

Return lRetAux
/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o	 ?valSalesForce   ?Autor ?Everson     - KF System  ?Data ?01.03.18  ��?������������������������������������������������������������������������������������Ĵ��
���Descri��o ?Regra de neg�cio criada para n�o permitir excluir um pedido   		 ��?��?		 ?de venda cujo campo C5_CODIGEN (Numerico 10) seja maior que 0 		 ��?������������������������������������������������������������������������������������Ĵ��
���Uso		 ?MATA410 - Pedido de Vendas								     		 ��?��?		 ?Ponto de Entrada para validar a exclus�o do pedido de vendas  		 ��?��?		 ?Projeto SalesForce.											 		 ��?������������������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Static Function valSalesForce()

	Local lRetAux := .T. 

/*	If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> "" .And. Upper(Alltrim(cValToChar(SC5->C5_LIBEROK))) <> "S"
		U_ADVEN050P("",.F.,.T., " AND C5_NUM IN ('" + Alltrim(cValToChar(SC5->C5_NUM)) + "') AND C5_XPEDSAL <> '' " , .F. )
		
	EndIf*/

Return lRetAux
