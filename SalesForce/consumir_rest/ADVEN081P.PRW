#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADVEN081P
	(Chamado 037261 - Job para envio de tabelas de preço ao Salesforce.)
	@type  Function
	@author Everson
	@since 19/03/2018
	@version 1.0
	@history Leon - 21/07/2020 - Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	/*/
User Function ADVEN081P() //U_ADVEN081()
	//Declaração de variávies
	Local cEmp 		:= "01"
	Local cFil 		:= "02"
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	// If !LockByName("ADVEN081P", .T., .F.)
	// 	ConOut("[ADVEN081P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de tabelas de preço ao SalesForce')

	PtInternal(1,ALLTRIM(PROCNAME()))
		
	conout("Início atualização tabela de preço SalesForce")
	logZBN("1") //Log início.
	
	U_ADVEN072P("","",.T.,"")
	
	logZBN("2") //Log fim.
	conout("Fim atualização tabela de preço SalesForce")
	
	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN081P")

	//Fecha o ambiente.
	RpcClearEnv()
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
