#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function F340COMP
	Validação para não permitir compensar títulos em borderô
	@type  Function
	@author Fernando Sigoli
	@since 10/09/2020
	@version 01
	@history Chamado    712 - O ponto de entrada F340COMP possibilita incluir validação para permitir compensar o tí­tulo selecionado ou não
*/

USER FUNCTION F340COMP()

	Local lRet		:= .T.   
	Local cNcompen 	:= GetMV("MV_#NCOMP",,"PA,")
	Local aAreaAtu 	:= GetArea()

	If !Empty(SE2->E2_NUMBOR) .and. !(Alltrim(SE2->E2_TIPO) $ cNcompen)

		MsgStop("Título " + SE2->E2_NUM  +" em Bordero. Não é permitido compensar", "Atenção. F340COMP-01 " )
		lRet := .F.

	EndIf

	

RestArea( aAreaAtu )

Return lRet
