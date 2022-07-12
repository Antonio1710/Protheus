#include "totvs.ch"

/*/{Protheus.doc} User Function FA290OK
	PE para consistir se o número da fatura está em uso
	@type  Function
	@author Fernando Macieira
	@since 12/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 76254 - 12/07/2022 - GERAÇÃO DE FATURAS - CONTAS A PAGAR
/*/
User Function FA290OK()

	Local lRet := .t.

	If !LockByName(AllTrim(cFatura), .T., .F.)
		lRet := .f.
		MESSAGEBOX( "Número da fatura está em uso pelo seu colega de trabalho... ", "Fatura n. " + cFatura, 16 )
	Else
		lRet := .t.
	EndIf
	
Return lRet
