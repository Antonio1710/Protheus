#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Apwizard.ch" 
#Include "Fileio.ch"  
#Include "Tbiconn.ch"
/*/{Protheus.doc} User Function ADFIS039P
	Lançamento de documento de entrada (CT-e) por xml. Chamado 054941. 
	@type  Function
	@author Everson
	@since 06/03/2020
	@version 01
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	/*/
User Function ADFIS039P() // U_ADFIS039P()
	//Declaracao de Variaveis
	Local cEmp	:= "07"
	Local cFil	:= ""
	Local aFil	:= {}
	Local nAux	:= 1
	Local cEmail:= ""

	//
	Aadd(aFil,"01")
	
	//Inicia o ambiente.
	For nAux := 1 To Len(aFil)
		//
		cFil := aFil[nAux]

		//
		RpcClearEnv()
		RPCSetType(3)
		RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		// If !LockByName("ADFIS039P", .T., .F.)
		// 	ConOut("[ADFIS039P] - Existe outro processamento sendo executado! Verifique...")
		// 	RPCClearEnv()
		// 	Return
		// EndIf

		PtInternal(1,ALLTRIM(PROCNAME()))

		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Lançamento de documento de entrada (CT-e) por xml')
		
		logZBN("1") //Log início.

		//
		cEmail	:= GetMv("MV_#AUTCTE",,"")
		
		Conout( DToC(Date()) + " " + Time() + " ADFIS039P - Início " + cFilAnt )
		StaticCall(ADFIS032P,processa,cEmail)
		Conout( DToC(Date()) + " " + Time() + " ADFIS039P - Fim " + cFilAnt )
			
		logZBN("2") //Log fim.
		
		//Destrava a rotina para o usuário
		// UnLockByName("ADFIS039P")

		//Fecha o ambiente.
		RpcClearEnv()
	Next nAux
Return Nil

/*/{Protheus.doc} logZBN
	Gera log na ZBN. Chamado 054941.
	@type  Static Function
	@author Everson
	@since 06/1103/2020
	@version 01
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIS039P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS039P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS039P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
	
	RestArea(aArea)
Return Nil
