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
	/*/
User Function ADVEN083P() //U_ADVEN083P()
	//Declaração de variávies
	Local cEmp 		:= "01"
	Local cFil 		:= "02"
	Local cDt		:= ""
	Local aEmpFil	:= {}
	Local i			:= 1
	
	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	// If !LockByName("ADVEN083P", .T., .F.)
	// 	ConOut("[ADVEN083P] - Existe outro processamento sendo executado! Verifique...")
	// 	RPCClearEnv()
	// 	Return
	// EndIf
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de notas fiscais de saída ao SalesForce. ')

	PtInternal(1,ALLTRIM(PROCNAME()))

	conout("Início atualização nota fiscal (saída) SalesForce")
	logZBN("1") //Log início.
	cDt := Alltrim( cValToChar( GetMv("MV_#SFDTPD" ) ))
	
	Aadd(aEmpFil,{"01","02"})
	//Aadd(aEmpFil,{"01","03"})
	
	For i := 1 To Len(aEmpFil)
		U_ADVEN074P(aEmpFil[i][1],aEmpFil[i][2],"",.T.," AND F2_EMISSAO >= '" + cDt + "' AND DATEDIFF(DAY,F2_EMISSAO,GETDATE()) <= 2 ")
	Next i
	
	logZBN("2") //Log fim.

	conout("Fim atualização nota fiscal (saída) SalesForce")
	
	//Destrava a rotina para o usuário
	// UnLockByName("ADVEN083P")

	//Fecha o ambiente.
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
