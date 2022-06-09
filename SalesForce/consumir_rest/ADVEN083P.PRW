#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADVEN083P
	(Chamado 035024 - Job para envio de notas fiscais de saída ao SalesForce)
	@type  Function
	@author Everson
	@since 21/03/2018
	@version 1.0
	@history Leon - 21/07/2020 - Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Everson, 18/04/2022, Chamado 71231 - ajuste para atender a nova filial 0B.
	@history 19/04/2022, Everson, Chamado 71231, ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN083P(aXEmpFil) //18/04/2022, Everson, Chamado 71231. // U_ADVEN094P()
	
	//Declaração de variávies
	//18/04/2022, Everson, Chamado 71231.
	Default aXEmpFil :={ "01", "02" }
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ })

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de notas fiscais de saída ao SalesForce. ')

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	conout("Início atualização nota fiscal (saída) SalesForce")
	logZBN("1")
	cDt := Alltrim( cValToChar( GetMv("MV_#SFDTPD" ) ))
	
		U_ADVEN074P(aXEmpFil[1], aXEmpFil[2],"",.T.," AND F2_EMISSAO >= '" + cDt + "' AND DATEDIFF(DAY,F2_EMISSAO,GETDATE()) <= 2 ")
	
	logZBN("2")

	conout("Fim atualização nota fiscal (saída) SalesForce")
	
	RpcClearEnv()

Return Nil

/*/{Protheus.doc} logZBN
	(Chamado 035024 - Gera log na ZBN)
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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN083P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN083P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADVEN083P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)
	
Return Nil
