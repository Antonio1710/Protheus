#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*/{Protheus.doc} User Function ADVEN103P
	(Popula os indicadores da diretoria comercial no Salesforce.)
	@type  Function
	@author Everson
	@since 20/03/2019
	@version 01
	@history Everson - 26/03/2019.Chamado TI. Incluída quantidade em caixas na string de envio para o Salesforce;
	@history Everson - 29/03/2019.Chamado TI. Envio dos registros por lote;
	@history Everson - 09/04/2019.Chamado TI. Adicionados código e nome do supervisor;
	@history Everson - 12/04/2019.Chamado TI. Removido filtro por segmento de mercado;
	@history Everson - 16/04/2019.Chamado TI. Removido filtro;
	@history Everson - 23/04/2019.Chamado TI. Alterado SA3 por SZR;
	@history Sigoli	 - 25/04/2019.Chamado TI. Tratamento exceção CFOP;
	@history Leon	 - 14/01/2020.Chamado TI. Adicionar campo de nome do vendedor para atribuição do objeto Indicadores Diretoria;
	@history Everson - 20/05/2020.Chamado TI. Tratamento para pedidos de complemento de preço.
	@history Leon	 - 21/07/2020.Chamato TI. Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history, Everson, 18/04/2022, Chamado 71231 - ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN103P() // U_ADVEN103P()
	
	//Declaração de variáveis
	Local cEmp	:= "01"
	Local cFil := "02"
	
	//Inicia o ambiente
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
		
	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	// If !LockByName("ADVEN103P", .T., .F.)
	// 	ConOut("[ADVEN103P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	conout("Início envio de dados dos indicadores Salesforce")
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Popula os indicadores da diretoria comercial no Salesforce')
	logZBN("1") //Log início
	
		Processar()
	
	logZBN("2") //Log fim
	conout("Fim envio de dados dos indicadores Salesforce")
	
	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN103P")

	//Fecha o ambiente
	RpcClearEnv()
Return Nil

/*/{Protheus.doc} Processar
	(Processa o envio dos dados.)
	@type  Static Function
	@author Everson
	@since 20/03/2019
	@version 01
	@history Everson-09/04/2019.Chamado TI. Incluído nome e código do supervisor.
	/*/
Static Function Processar()
	//Declaração de variáveis
	Local aArea		:= GetArea()
	
	//Variáveis obrigatórias para a função ADVEN102P
	Local cObjeto	:= "Indicadores_Diretoria__c" //Nome do objeto no Salesforce
	Local cCmpProth	:= "Chave_Protheus__c" //Campo da chave estrangeira no Salesforce (chave Protheus)
	Local aChaves	:= {} //Associação dos campos da query com as tags do Json
	Local cQuery	:= getQuery()  //Script sql com os dados
	
	/*** A query deve conter o campo CHV que serve com chave estrangeia no Salesforce ***/
	
	//
	Aadd(aChaves,{"DATA","Data__c"})
	Aadd(aChaves,{"QTD_PEDIDO","Qtd_pedidos__c"})
	Aadd(aChaves,{"QTD_CLIENTE","Numero_de_Clientes__c"})
	Aadd(aChaves,{"_Val_Tot","Total_de_vendas_R__c"})
	Aadd(aChaves,{"_Qtd_Qui","Total_de_vendas_Kg__c"})
	Aadd(aChaves,{"_Qtd_Cxs","Total_de_vendas_Cx__c"})
	Aadd(aChaves,{"C6_VEND","Codigo_Vendedor__c"})
	Aadd(aChaves,{"A3_XNFSF","Nome_Vendedor__c"})	//TI - Leon Toledo 14/01/2020
	Aadd(aChaves,{"A3_NOME","Nome_Carteira__c"})	//TI - Leon Toledo 14/01/2020
	Aadd(aChaves,{"DEVR","Total_devolu_o__c"})
	Aadd(aChaves,{"DEVK","Total_devolu_o_Kg__c"})
	
	//Everson - 09/04/2019. Chamado TI.
	Aadd(aChaves,{"CODSUP","Codigo_Supervisor__c"})
	Aadd(aChaves,{"NMSUP","Nome_Supervisor__c"})
	//
	
	Aadd(aChaves,{"HORA","Hora__c"})
	
	//
	U_ADVEN102P(cObjeto,cCmpProth,aChaves,cQuery)
	
	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} getQuery
	(Processa o envio dos dados.)
	@type  Static Function
	@author Everson
	@since 20/03/2019
	@version 01
	/*/
Static Function getQuery()
	//Declaracao de Variaveis
	Local cQuery	:= ""

	//
	cQuery := ""
	cQuery += " SELECT "
	//O campo CHV é obrigatório, pois é a chave estrangeira no Salesforce.
	cQuery += " RTRIM(LTRIM(C6_ENTREG)) + RTRIM(LTRIM(C6_VEND)) AS CHV, " 
	cQuery += " SUBSTRING(C6_ENTREG,1,4) + '-' + SUBSTRING(C6_ENTREG,5,2) + '-' + SUBSTRING(C6_ENTREG,7,2) AS DATA, "
	cQuery += " CONVERT(VARCHAR(10), GETDATE(), 108) AS HORA, "
	cQuery += " 0 AS DEVR, "
	cQuery += " 0 AS DEVK, "
	cQuery += " C6_ENTREG, 
	cQuery += " C6_VEND, 
	cQuery += " A3_NOME, " 
	cQuery += " A3_XNFSF, "  //TI - Chamado Leon Toledo 14/01/2020
	cQuery += " COUNT(DISTINCT C6_NUM) AS QTD_PEDIDO, " 
	cQuery += " COUNT(DISTINCT C6_CLI+C6_LOJA) AS QTD_CLIENTE, " 
	cQuery += " SUM(C6_UNSVEN) AS _Qtd_Cxs, " 
	cQuery += " SUM(C6_QTDVEN) AS _Qtd_Qui, " 
	cQuery += " SUM(C6_VALOR) AS _Val_Tot, " 
	cQuery += " SUM(C6_VALOR) / SUM(C6_QTDVEN) AS PREMED, SUPER.CODSUP, SUPER.NMSUP " 
	
	cQuery += " FROM " + RetSqlName("SC6") + " " 
	cQuery += " INNER JOIN " + RetSqlName("SA3") + " " 
	cQuery += " ON A3_FILIAL          = '' " 
	cQuery += " AND A3_COD             = C6_VEND " 
	cQuery += " AND A3_CODSUP         >= '000001' " 
	cQuery += " AND A3_CODSUP         <= '000300' " 
	cQuery += " AND SA3010.D_E_L_E_T_ <> '*' " 
	cQuery += " INNER JOIN " + RetSqlName("SZR") + " " 
	cQuery += " ON ZR_FILIAL          = '' " 
	cQuery += " AND ZR_CODIGO          = A3_CODSUP " 
	//cQuery += " AND ZR_SEGMERC        >= '001' "  //Everson 12/04/2019. Chamado T.I.
	//cQuery += " AND ZR_SEGMERC        <= '002' " 
	cQuery += " AND SZR010.D_E_L_E_T_ <> '*' " 
	
	cQuery += " LEFT OUTER JOIN "
	//Everson - 23/04/2019.Chamado TI.
	cQuery += " (SELECT ZR_FILIAL AS FILSUP, ZR_CODIGO AS CODSUP, ZR_DESCRIC AS NMSUP FROM " 
	cQuery += " " + RetSqlName("SZR") + " AS SZR WHERE SZR.D_E_L_E_T_ = '') AS SUPER ON "
	cQuery += " A3_FILIAL = SUPER.FILSUP "
	cQuery += " AND A3_CODSUP = SUPER.CODSUP "
	
	// cQuery += " WHERE C6_FILIAL = '" + FwxFilial("SC6") + "' " //Everson - 18/04/2022. Chamado 71231.
	cQuery += " WHERE C6_FILIAL IN ('02','0B') " //Everson - 18/04/2022. Chamado 71231.
	cQuery += " AND C6_ENTREG >= CONVERT(VARCHAR(8), (GETDATE()), 112) " 
	cQuery += " AND C6_CF NOT IN ('5949')" //TI - Fernando Sigoli 25/04/2019
	cQuery += " AND SC6010.D_E_L_E_T_ <> '*' " 
	cQuery += " GROUP BY C6_ENTREG, C6_VEND, A3_NOME, A3_XNFSF, SUPER.CODSUP, SUPER.NMSUP " //TI - Leon Toledo 14/01/2020
	cQuery += " HAVING SUM(C6_QTDVEN) > 0 " //Everson - 20/05/2020.Chamado TI.
	cQuery += " ORDER BY C6_ENTREG, SUPER.CODSUP, SUPER.NMSUP, C6_VEND, A3_NOME "
	
	Conout( DToC(Date()) + " " + Time() + " ADVEN103P - getQuery - cQuery " + cQuery )
Return cQuery 

/*/{Protheus.doc} logZBN
	(Gera log na ZBN. Chamado 037261)
	@type  Static Function
	@author Everson
	@since 29/03/2019
	@version 01
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN081P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN081P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN081P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)
Return Nil
