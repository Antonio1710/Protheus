#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*/{Protheus.doc} User Function ADVEN096P
	(Chamado 037261 - Job para envio de notas de devolução ao SalesForce)
	@type  Function
	@author Everson
	@since 22/05/2018
	@version 1.0
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Everson, 18/04/2022, Chamado 71231 - ajuste para atender a nova filial 0B.
	@history 19/04/2022, Everson, Chamado 71231, ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN096P(aXEmpFil)

	//Declaração de variávies
	Local cDt		:= ""
	
	//Everson, 18/04/2022, Chamado 71231.
	Default aXEmpFil :={ "01", "02" }
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ })

	PtInternal(1,ALLTRIM(PROCNAME()))

	conout("Início atualização nota fiscal (entrada) SalesForce")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de notas de devolução ao SalesForce.')
	
	logZBN("1")
	cDt := Alltrim( cValToChar( GetMv("MV_#SFDTPD" ) ))
	
		U_ADVEN077P(cEmp, cFil,"",.T.," AND F1_DTDIGIT >= '" + cDt + "' AND DATEDIFF(DAY,F1_DTDIGIT,GETDATE()) <= 2 AND F1_XSALES = '' ")
	
	logZBN("2")

	conout("Fim atualização nota fiscal (entrada) SalesForce")

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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN096P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN096P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN096P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
