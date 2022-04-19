#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*/{Protheus.doc} User Function ADVEN094P
	(Chamado 037261 - Job para envio de status financeiro e placa para o SalesForce)
	@type  Function
	@author Everson
	@since 10/05/2018
	@version 1.0
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history 18/04/2022, Everson, Chamado 71231, ajuste para atender a nova filial 0B.
	@history 19/04/2022, Everson, Chamado 71231, ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN094P(aXEmpFil) //18/04/2022, Everson, Chamado 71231. // U_ADVEN094P()
	
	//Declaração de variávies
	//18/04/2022, Everson, Chamado 71231.
	Default aXEmpFil :={ "01", "02" }
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	// If !LockByName("ADVEN094P", .T., .F.)
	// 	ConOut("[ADVEN094P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf

	PtInternal(1,ALLTRIM(PROCNAME()))

	conout("Início envio status financeiro e placa SalesForce")
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de status financeiro e placa para o SalesForce')
	logZBN("1") //Log início.
	
	processar()
	
	logZBN("2") //Log fim.
	conout("Fim envio status financeiro e placa SalesForce")
	
	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN094P")

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil

/*/{Protheus.doc} processar
	(long_description)
	@type  Static Function
	@author Everson
	@since 10/05/2018
	@version 1.0
	/*/
Static Function processar()
	procCancNf( DToS(Date()-2),DToS(Date()+5))
	
	procAprv( DToS(Date()-2),DToS(Date()+5))
	
	procBlq( DToS(Date()-2),DToS(Date()+5))
Return Nil

/*/{Protheus.doc} procAprv
	(Chamado 037261 - Processa pedidos aprovados)
	@type  Static Function
	@author Everson
	@since 13/04/2018
	@version 1.0
	/*/
Static Function procAprv(cDtDe,cDtAt)
	//Declaracao de Variaveis
	Local aArea 	:= GetArea()
	Local cExpSql	:= ""
	//
	cExpSql += " AND C5_XPEDSAL <> '' "
	cExpSql += " AND C5_BLQ = '' "
	cExpSql += " AND (C5_XGERSF = '2' OR (C5_XGERSF = '1' AND (C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX') )) "
	cExpSql += " AND C5_XSFSTAT <> '2' "
	cExpSql += " AND (SC5.C5_FLAGFIN = 'L' OR (C5_NOTA <>'' AND C5_SERIE <> '' AND C5_NOTA <> 'XXXXXXXXX')) "
	cExpSql += " AND SC5.C5_DTENTR >= '" + cDtDe + "' "
	cExpSql += " AND SC5.C5_DTENTR <= '" + cDtAt + "' "
	cExpSql += " AND SC5.D_E_L_E_T_ = '' "
	
	U_ADVEN050P("",.T.,.T.,cExpSql,.T.)
	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} ProcCancNf
	(Chamado 037261 - Processa pedidos com nf cancelada)
	@type  Static Function
	@author Everson
	@since 01/10/2018
	@version 1.0
	/*/
Static Function procCancNf(cDtDe,cDtAt)
	//Declaracao de Variaveis
	Local aArea 	:= GetArea()
	Local cExpSql	:= ""
	
	//
	cExpSql += " UPDATE " + RetSqlName("SC5") + " SET C5_XSFSTAT = '' WHERE C5_FILIAL = '" + FwxFilial("SC5") + "' "
	cExpSql += " AND C5_NUM IN ( "
	cExpSql += " SELECT " 
	cExpSql += " DISTINCT C5_NUM " 
	cExpSql += " FROM " 
	cExpSql += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cExpSql += " INNER JOIN " 
	cExpSql += " (SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_LOJA FROM " + RetSqlName("SD2") + " (NOLOCK) AS SD2 WHERE SD2.D2_FILIAL = '" + FwxFilial("SD2") + "' AND SD2.D_E_L_E_T_ = '*') AS SD2 " 
	cExpSql += " ON SC5.C5_FILIAL = SD2.D2_FILIAL " 
	cExpSql += " AND SC5.C5_NUM = SD2.D2_PEDIDO " 
	cExpSql += " AND SC5.C5_CLIENTE = SD2.D2_CLIENTE " 
	cExpSql += " AND SC5.C5_LOJACLI = SD2.D2_LOJA " 
	cExpSql += " INNER JOIN " 
	cExpSql += " (SELECT * FROM " + RetSqlName("SF3") + " (NOLOCK) AS SF3 WHERE SF3.F3_FILIAL = '" + FwxFilial("SF3") + "' AND SF3.D_E_L_E_T_ = '' AND F3_DTCANC <> '') AS SF3 " 
	cExpSql += " ON SD2.D2_FILIAL = SF3.F3_FILIAL " 
	cExpSql += " AND SD2.D2_DOC = SF3.F3_NFISCAL " 
	cExpSql += " AND SD2.D2_SERIE = SF3.F3_SERIE " 
	cExpSql += " AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR " 
	cExpSql += " AND SD2.D2_LOJA = SF3.F3_LOJA " 
	cExpSql += " WHERE " 
	cExpSql += " SC5.C5_FILIAL = '" + FwxFilial("SC5") + "' " 
	cExpSql += " AND SC5.D_E_L_E_T_ = '' " 
	cExpSql += " AND SC5.C5_XPEDSAL <> '' " 
	cExpSql += " AND SC5.C5_DTENTR >= '" + cDtDe + "'  AND SC5.C5_DTENTR <= '" + cDtAt + "' "
	cExpSql += " ) "
	
	If (TCSqlExec(cExpSql)) < 0
		Conout("ADVEN094P - >>>>>>>>>>> Erro update SC5 status de envio Salesforce " + TCSQLError() )
	EndIf
	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} procAprv
	(Chamado 037261 - Processa pedidos reprovados)
	@type  Static Function
	@author Everson
	@since 13/04/2018
	@version 1.0
	/*/
Static Function procBlq(cDtDe,cDtAt)
	//Declaracao de Variaveis
	Local aArea 	:= GetArea()
	Local cExpSql	:= ""

	//
	cExpSql += " AND C5_XPEDSAL <> '' "
	cExpSql += " AND C5_BLQ = '' "
	cExpSql += " AND C5_XGERSF = '2' "
	cExpSql += " AND C5_XSFSTAT <> '2' "
	cExpSql += " AND ( SC5.C5_FLAGFIN = 'B' OR SC5.D_E_L_E_T_ <> '') "
	cExpSql += " AND SC5.C5_DTENTR >= '" + cDtDe + "' "
	cExpSql += " AND SC5.C5_DTENTR <= '" + cDtAt + "' ""
	cExpSql += " AND C5_NUM NOT IN (SELECT DISTINCT ZCI_NUMP FROM " + RetSqlName("ZCI") + " (NOLOCK) AS ZCI WHERE ZCI_FILIAL = '" + FwxFilial("ZCI") + "' AND ZCI_METD = 'DELETE' AND ZCI.D_E_L_E_T_ = '' AND DATEDIFF(DAY,ZCI_DATA,GETDATE()) <= 5) "
		
	U_ADVEN050P("",.T.,.T.,cExpSql,.F.)
	
	//
	RestArea(aArea)
Return Nil

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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN094P'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN094P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 
	Else
		RecLock("ZBN",.T.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN094P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	
	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)
Return Nil
