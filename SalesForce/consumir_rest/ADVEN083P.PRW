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
	@history Everson, 18/04/2022, Chamado 71231 - ajuste para atender a nova filial 0B.
	/*/
User Function ADVEN083P(cEmp, cFil) //U_ADVEN083P()
	//Declaração de variávies
	Local cDt		:= ""

	//verson, 18/04/2022, Chamado 71231.
	Default cEmp 	:= "01"
	Default cFil 	:= "02"
	
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de notas fiscais de saída ao SalesForce. ')

	PtInternal(1,ALLTRIM(PROCNAME()))

	conout("Início atualização nota fiscal (saída) SalesForce")
	logZBN("1")
	cDt := Alltrim( cValToChar( GetMv("MV_#SFDTPD" ) ))
	
		U_ADVEN074P(cEmp, cFil,"",.T.," AND F2_EMISSAO >= '" + cDt + "' AND DATEDIFF(DAY,F2_EMISSAO,GETDATE()) <= 2 ")
	
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
