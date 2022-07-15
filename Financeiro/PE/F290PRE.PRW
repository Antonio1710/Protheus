#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F290PRE
	PE para consistir se o número da fatura está em uso e/ou os títulos que serão gerados
	@type  Function
	@author Fernando Macieira
	@since 13/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 76254 - 13/07/2022 - GERAÇÃO DE FATURAS - CONTAS A PAGAR
/*/
User Function F290PRE()

	Local cQuery    := ""
	Local lExiste   := .f.
	Local lMudou    := .f.

	Do While .t.	

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

		cQuery := " SELECT E2_FATPREF, E2_FATURA, E2_TIPOFAT
		cQuery += " FROM " + RetSqlName("SE2") + "(NOLOCK)
		cQuery += " WHERE E2_FATURA='"+AllTrim(cFatura)+"' 
		cQuery += " AND D_E_L_E_T_=''

		tcQuery cQuery New Alias "Work"

		Work->( dbGoTop() )
		If Work->( !EOF() )
			lExiste := .t.
			MESSAGEBOX( "Fatura já existe na base! A numeração será modificada... ", "Fatura: " + cFatura, 8 )
		EndIf

		If lExiste .or. !LockByName(AllTrim(cFatura), .T., .F.)

			lExiste := .f.

			aTam := TamSx3("E2_NUM")
			cFatura	:= Soma1(cFatura, aTam[1])
			cFatura	:= Pad(cFatura,aTam[1])

			lMudou := .t.

		Else

			Exit

		EndIf

	EndDo

	If lMudou
		msgInfo("Número da fatura modificado para " + cFatura)
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return
