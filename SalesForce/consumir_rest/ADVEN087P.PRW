#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADVEN087P
	(Chamado 037261 - Job para envio de pedidos de venda)
	@type  Function
	@author Everson
	@since 19/03/2018
	@version 1.0
	@history Leon - 21/07/2020 - Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	/*/
User Function ADVEN087P(aXEmpFil) //18/04/2022, Everson, Chamado 71231. // U_ADVEN094P()
	
	//Declaração de variávies
	Local cScript	:= ""
	Local cExpSql	:= ""

	//18/04/2022, Everson, Chamado 71231.
	Default aXEmpFil :={ "01", "02" }
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ })

	//Inicia o ambiente.
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	// If !LockByName("ADVEN087P", .T., .F.)
	// 	ConOut("[ADVEN087P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de pedidos de venda.')

	PtInternal(1,ALLTRIM(PROCNAME()))
	
	conout("ADVEN087P - Início envio de pedidos de venda ao SalesForce")
	logZBN("1") //Log início.
	
	//Envio de pedidos de venda.
	Conout("ADVEN087P - >>>>>>>>>>>>>>>>>>>>>>>>>>>> Envio de pedidos de venda gerados no Protheus")
	cScript := scriptSql(1)
	cExpSql += " AND C5_XSFSTAT NOT IN ('3','2') "
	U_ADVEN050P("",.T.,," AND C5_NUM IN ( " + cScript +  " ) ",,,,,,,1)
	
	//Alteração do status do pedido de venda.
	Conout("ADVEN087P - 60 segundos para envio de status de pedidos de venda")
	Sleep(60000)
	cScript := scriptSql(2)
	Conout("ADVEN087P - >>>>>>>>>>>>>>>>>>>>>>>>>>>> Alteração dos status dos pedidos de venda gerados no Protheus")
	cExpSql := ""
	//cExpSql += " AND C5_PLACA <> '' "
	cExpSql += " AND C5_XPEDSAL <> '' "
	cExpSql += " AND C5_BLQ = '' "
	cExpSql += " AND C5_XSFSTAT NOT IN ('3','2') "
	cExpSql += " AND (SC5.C5_FLAGFIN = 'L' OR (C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX')) "
	cExpSql += " AND C5_NUM IN ( " + cScript +  " ) "
	//
	U_ADVEN050P("",.T.,.T.,cExpSql,.T.,,,,,,1)

	//Envio de nota fiscal de saída.
	cScript := scriptSql(2)
	Conout("ADVEN087P - >>>>>>>>>>>>>>>>>>>>>>>>>>>> Envio da nota fiscal de saída dos pedidos de venda gerados no Protheus")
	cExpSql := ""
	cExpSql += " AND RTRIM(LTRIM(F2_DOC)) + RTRIM(LTRIM(F2_SERIE)) IN ( "
	cExpSql += " SELECT RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) AS NF FROM " + RetSqlName("SC5") + " AS SC5 "
	cExpSql += " WHERE C5_FILIAL = '" + cFil + "' AND  C5_NUM IN ( " + cScript +  " ) AND C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX' "
	cExpSql += " ) "
	//
	U_ADVEN074P(cEmp,cFil,"",.T.,cExpSql)
	
	//Envio de nota fiscal de devolução.
	//Obtém os script sql dos pedidos de venda a serem enviados ao SalesForce.
	cScript := scriptSql()
	Conout("ADVEN087P - >>>>>>>>>>>>>>>>>>>>>>>>>>>> Envio da nota fiscal de entrada (devoluções) dos pedidos de venda gerados no Protheus")
	cExpSql := ""
	cExpSql := " AND F1_XSALES = '' AND RTRIM(F1_FILIAL) +  RTRIM(F1_DOC) + RTRIM(F1_SERIE) + RTRIM(F1_FORNECE) + RTRIM(F1_LOJA) IN ( "	
	cExpSql += " SELECT  " 
	cExpSql += " DISTINCT RTRIM(D1_FILIAL) +  RTRIM(D1_DOC) + RTRIM(D1_SERIE) + RTRIM(D1_FORNECE) + RTRIM(D1_LOJA)  " 
	cExpSql += " FROM " + RetSqlName("SD1") + " (NOLOCK) AS SD1 " 
	cExpSql += " INNER JOIN " 
	cExpSql += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
	cExpSql += " D1_FILIAL = C5_FILIAL " 
	cExpSql += " AND D1_NFORI = C5_NOTA " 
	cExpSql += " AND D1_SERIORI = C5_SERIE " 
	cExpSql += " AND D1_FORNECE = C5_CLIENTE " 
	cExpSql += " AND D1_LOJA = C5_LOJACLI " 
	cExpSql += " WHERE  " 
	cExpSql += " D1_FILIAL = '" + cFil + "'  " 
	cExpSql += " AND  C5_NUM IN ( " + cScript +  " ) " 
	cExpSql += " AND SC5.D_E_L_E_T_ = '' " 
	cExpSql += " AND SD1.D_E_L_E_T_ = '' "  
	cExpSql += " ) "
	//
	U_ADVEN077P(cEmp,cFil,"",.T.,cExpSql,.F.)
	
	logZBN("2") //Log fim.
	conout("ADVEN087P - Fim envio de pedidos de venda ao SalesForce")

	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN087P")

	//Fecha o ambiente.
	RpcClearEnv()
Return Nil
/*/{Protheus.doc} scriptSql
	(Chamado 037261 - Pedidos a serem enviados ao SalesForce)
	@type  Static Function
	@author Everson
	@since 18/09/2018
	@version 1.0
	/*/
Static Function scriptSql(nOPc)
	//Declaração de variávies
	Local cQuery := ""
	Default nOPc := 0
	
	cQuery += " SELECT " 
	cQuery += " DISTINCT C5_NUM " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 " 
	cQuery += " ON C5_FILIAL = C6_FILIAL " 
	cQuery += " AND C5_NUM = C6_NUM  " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SB1") + " (NOLOCK) AS SB1 " 
	cQuery += " ON C6_PRODUTO = B1_COD " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT A1_COD, A1_LOJA FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE SA1.D_E_L_E_T_ = '' AND A1_XIDSF <> '') AS SA1 " 
	cQuery += " ON C5_CLIENTE = A1_COD " 
	cQuery += " AND C5_LOJACLI = A1_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += " (SELECT F4_CODIGO FROM " + RetSqlName("SF4") + " (NOLOCK) AS SF4 WHERE SF4.D_E_L_E_T_ = '' AND F4_DUPLIC = 'S') AS SF4 " 
	cQuery += " ON C6_TES = F4_CODIGO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " ON C6_FILIAL = D2_FILIAL " 
	cQuery += " AND C6_NUM = D2_PEDIDO " 
	cQuery += " AND C6_CLI = D2_CLIENTE " 
	cQuery += " AND C6_LOJA = D2_LOJA " 
	cQuery += " AND C6_PRODUTO = D2_COD " 
	
	//Checa se todos os itens dos pedidos foram integrados.
	If nOPc == 2
		cQuery += " INNER JOIN "
		cQuery += " ( "
		cQuery += " SELECT " 
		cQuery += " DISTINCT CHECKENV.C6_NUM AS PED " 
		cQuery += " FROM " 
		cQuery += " ( " 
		cQuery += " SELECT C6_NUM, COUNT(C6_PRODUTO) AS QTD_ITEM, SUM(CASE WHEN C6_XIDSF <> '' THEN 1 ELSE 0 END) AS QTD_EXP " 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5  " 
		cQuery += " ON C6_FILIAL = C5_FILIAL " 
		cQuery += " AND C6_NUM = C5_NUM " 
		cQuery += " WHERE  " 
		cQuery += " SC6.C6_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND C5_XGERSF = '1' " 
		cQuery += " AND C5_XPEDSAL <> '' " 
		cQuery += " AND SC6.C6_UNSVEN > 0 "
		cQuery += " GROUP BY C6_NUM " 
		cQuery += " ) AS CHECKENV " 
		cQuery += " WHERE " 
		cQuery += " CHECKENV.QTD_EXP = CHECKENV.QTD_EXP "
		cQuery += " )CHKLIB ON  SC5.C5_NUM = CHKLIB.PED
	EndIf
	
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND C5_TIPO = 'N' " 
	cQuery += " AND C5_XGERSF = '1' " 
	If nOPc == 1
		cQuery += " AND C5_XPEDSAL = '' " 
	Else
		cQuery += " AND C5_XPEDSAL <> '' "
	EndIf

	cQuery +=" AND SC5.C5_DTENTR >= '" + DToS(Date()-4) + "' AND SC5.C5_DTENTR <= '" + DToS(Date()+2) + "' "
	cQuery += " AND B1_XSALES = '2' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND SC6.D_E_L_E_T_ = '' " 
	cQuery += " AND SB1.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' "
Return cQuery

/*/{Protheus.doc} logZBN
	(Chamado 037261 - Gera log na ZBN)
	@type  Static Function
	@author Everson
	@since 30/05/2017
	@version 1.0
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN087P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN087P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN087P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)
Return Nil
