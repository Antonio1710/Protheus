#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Apwizard.ch" 
#Include "Fileio.ch"  
#Include "Tbiconn.ch"

/*/{Protheus.doc} User Function ADFIS040P
	Lançamento de documento de entrada (CT-e) por xml. Chamado 054941. 
	@type  Function
	@author Everson
	@since 17/03/2020
	@version 01
	@history 21/07/2020, Leon, Comentar LockByName para contornar falta de execução de rotinas de agendamento;
<<<<<<< HEAD
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
=======
>>>>>>> master
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	/*/
User Function ADFIS040P() // U_ADFIS040P()
	//Declaracao de Variaveis
	Local cEmp	:= "01"
	Local cFil	:= ""
	Local aFil	:= {}
	Local nAux	:= 1
	Local cEmail:= ""

	//
	Aadd(aFil,"03")
	
	//Inicia o ambiente.
	For nAux := 1 To Len(aFil) 
		//
		cFil := aFil[nAux]

		//
		RpcClearEnv()
		RPCSetType(3)
		RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		// If !LockByName("ADFIS040P", .T., .F.)
		// 	ConOut("[ADFIS040P] - Existe outro processamento sendo executado! Verifique...")
		// 	RPCClearEnv()
		// 	Return
		// EndIf

		//@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
		//FWMonitorMsg(ALLTRIM(PROCNAME()))

		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Lançamento de documento de entrada (CT-e) por xml')
		logZBN("1") //Log início.

		//
		cEmail	:= GetMv("MV_#AUTCTE",,"")
		
		Conout( DToC(Date()) + " " + Time() + " ADFIS040P - Início " + cFilAnt )
		//Static Call(ADFIS032P,processa,cEmail)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_FIS032A1( cMail )
		Conout( DToC(Date()) + " " + Time() + " ADFIS040P - Fim " + cFilAnt )
			
		logZBN("2") //Log fim.

		//Destrava a rotina para o usuário
		// UnLockByName("ADFIS040P")
		
		//Fecha o ambiente.
		RpcClearEnv()
	Next nAux
Return Nil

/*/{Protheus.doc} logZBN
	Gera log na ZBN. Chamado 054941.
	@type  Static Function
	@author Everson
	@since 17/03/2020
	@version 01
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIS040P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS040P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS040P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
	
	RestArea(aArea)
Return Nil
