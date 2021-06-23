#include "protheus.ch"

/*/{Protheus.doc} User Function nomeFunction
	ponto de entrada F330DTFIN para permitir ao cliente decidir se quer validar a data do parâmetro MV_DATAFIN ou não. 
	O RdMake precisa apenas retornar:
	.T.: Para que o sistema efetue a validação;
	.F.: Para que o sistema ignore a validação;
	@type  Function
	@author FWNM
	@since 26/09/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 051550 || OS 052878 || CONTROLADORIA || MONIK_MACEDO || 8956 || INDEXADORES 
	@history chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA 
/*/
User Function F330DTFIN()

	Local lRet := .T.
	
	// Chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA 
	/*
	If IsInCallStack("FINA330") // Compensacao CR
		If (SE1->E1_TIPO $ MVABATIM) .or. (SE1->E1_TIPO $ MVRECANT) .or. (SE1->E1_TIPO $ MV_CRNEG)
			lRet := .T.
			Alert("[ F330DTFIN-01 ] - Compensação/Estorno não permitido! Necessário posicionar sobre a NF...")
		EndIf
	EndIf
	*/

Return lRet
