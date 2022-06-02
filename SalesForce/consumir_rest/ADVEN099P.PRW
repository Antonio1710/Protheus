#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADVEN099P
	(Chamado 035024 - Job para envio de condições de pagamento ao SalesForce)
	@type  Function
	@author Everson
	@since 18/10/2018
	@version 1.0
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	/*/
User Function ADVEN099P() //U_ADVEN099P()
	//Declaração de variávies
	Local cEmp 		:= "01"
	Local cFil 		:= "02"
	
	//Inicia o ambiente.
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	// If !LockByName("ADVEN099P", .T., .F.)
	// 	ConOut("[ADVEN099P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	conout("Início atualização de condição de pagamento SalesForce")
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de condições de pagamento ao SalesForce.')
	logZBN("1") //Log início.
	
	U_ADVEN070P("","",.T.,"")
	
	logZBN("2") //Log fim.
	conout("Fim atualização de condição de pagamento SalesForce")
	
	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN099P")
	
	//Fecha o ambiente.
	RpcClearEnv()
Return Nil

/*/{Protheus.doc} logZBN
	(Chamado 035024 - Gera log na ZBN)
	@type  Static Function
	@author Everson
	@since 18/10/2018
	@version 1.0
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN099P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN099P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN099P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)
Return Nil
