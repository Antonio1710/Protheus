#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function ADEST051P
	(Gatilho para campo virtual CP_XQTEE)
	@type  Function
	@author Adriano Savoine
	@since 23/12/2020
	@version 01
	@history Ticket 6783 - 23/12/2020 - Adriano Savoine - Função para Gatilho do campo CP_XQTEE, nesse campo grava a quantidade disponivel para solicitar retirando as solicitações já criadas.
	/*/

USER FUNCTION ADEST051P()

	Local aArea      := GetArea()
	Local nValor 	 := 0
	Local nLocpad    := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF !RetArqProd(M->CP_PRODUTO)

		nLocpad:= POSICIONE("SBZ",1,xFilial("SBZ")+M->CP_PRODUTO,"BZ_LOCPAD")

		ELSE

		nLocpad:= POSICIONE("SB1",1,xFilial("SB1")+M->CP_PRODUTO,"B1_LOCPAD")

	ENDIF

	IF (!EMPTY(M->CP_PRODUTO))  
	
		DbSelectArea("SB2")
		DbSetOrder(1)
		dbSeek(xFilial("SB2")+M->CP_PRODUTO+nLocpad)
			
		nValor := (SB2->B2_QATU - SB2->B2_QEMP) - SB2->B2_QEMPSA
		
	ENDIF

	RestArea(aArea)

RETURN(nValor)
	