#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function ADEEC005P
    Gatilho para preenchimento do grupo de inspeção para envio para o eData.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 05/03/2021
    @version 01
	@history Leonardo P. Monteiro - 16/04/2021. Chamado 8465 - Gatilho para preenchimento do campo Grupo de Inspeção.
/*/

User Function ADEEC005P(nOpc)
	Local cRet		:= ""
	Local aArea		:= GetArea()
	Local cA1_GRPIN	:= POSICIONE("SA1",1,xFilial("SA1")+M->EE7_CONSIG+M->EE7_COLOJA,"A1_XGRPINS")
	Local cYA_GRPIN	:= POSICIONE("SYA",1,xFilial("SYA")+M->EE7_PAISET,"YA_XGRPINS")
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao disparada por Gatilho em EE7_CONSIG para preencher os campos EE7_MENSG, EE7_MENSG2, EE7_MENSG3')
	
	//if Empty(M->EE7_XGRPIN)
	if !Empty(cA1_GRPIN)
		cRet := cA1_GRPIN
	elseIF !Empty(cYA_GRPIN)
		cRet := cYA_GRPIN
	else
		cRet := "01"
	endif
	/*
	else
		cRet	:= M->EE7_XGRPIN
	endif
	*/
	RestArea(aArea)

Return(cRet)
