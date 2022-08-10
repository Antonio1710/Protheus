#Include "Rwmake.ch"
#Include 'AP5mail.ch'
#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Topconn.ch'

Static cEmp := "01"
Static cFil := "02"

/*/{Protheus.doc} User Function ADVEN112P 
	Segundo Job para processamento de alteração de pedido de venda SalesForce.
	@type  Function
	@author Everson
	@since 09/05/2018
	@version 01
/*/
User Function ADVEN112P(aXEmpFil) // U_ADVEN112P()

	//Declaração de variávies
	Local cDiaS		:= ""
	Local cHDe		:= ""
	Local cHAt		:= ""
	Local lAutoJob  := .T.
	local cRobo		:= "B"
    Local lRobo     := .F.
	Local cEmp	    := aXEmpFil[1]
	Local cFil	    := aXEmpFil[2]

	//Inicia o ambiente.
	If Select("SX6") == 0
		lAutoJob  := .T.

	Else
		lAutoJob  := .F.

	EndIf


	if lAutoJob
		RPCClearEnv()
		RPCSetType(3)
		RpcSetEnv(cEmp, cFil,,,,GetEnvServer(),{})

	Else
		MsgInfo("Modo debug Início", "Modo Debug")

	EndIf

        lRobo := GetMv("MV_#VEN901",,.F.)

		Conout(DToC(Date()) + " " + Time() + " ADVEN112P - Início inclusão/atualização/exclusão de pedido de venda SalesForce.")
		
		cDiaS := Alltrim(cValToChar(GetMv("MV_#SFDSEM")))
		cHDe  := Alltrim(cValToChar(GetMv("MV_#SFHDE")))
		cHAt  := Alltrim(cValToChar(GetMv("MV_#SFHATE")))
		
		If lRobo .And. (cValToChar(DOW(Date()))) $cDiaS //.And. Time() >= cHDe .And. Time() <= cHAt
			
			logZBN("1") //Log início.

				U_ADVEN90A(cRobo)

			logZBN("2") //Log início.

		EndIf
		
		Conout(DToC(Date()) + " " + Time() + " ADVEN112P - Fim inclusão/atualização/exclusão de pedido de venda SalesForce.")

		UnLockByName("ADVEN112P")

	RpcClearEnv()

	if lAutoJob
		RpcClearEnv()

	Else
		MsgInfo("Modo debug Término", "Modo Debug")

	EndIf

Return Nil
/*/{Protheus.doc} logZBN
	Gera log na ZBN.
	@type  Static Function
	@author Everson
	@since 10/08/2020
	@version 01
/*/
Static Function logZBN(cStatus)

    //Variáveis.
	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN112P'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN112P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADVEN112P'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)

Return Nil
