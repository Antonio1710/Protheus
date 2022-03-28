#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*/{Protheus.doc} User Function ADFIN062P
	Preencher o campo Juros de um dia do CNAB ITAU - coluna de detalhe 161-173
	@type  Function
	@author Willam Costa
	@since 02/02/2015
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 70022 - Fernando Macieira - 28/03/2022 - Erro Remessa valor Mora
/*/
USER FUNCTION ADFIN062P()

	Local cValor := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para preencher o campo Juros de um dia do CNAB ITAU coluna de detalhe 161-173')
	
	//cValor := STRZERO(VAL(STRTRAN(CVALTOCHAR(ROUND((SE1->E1_SALDO*(SEE->EE_ZZMORA/100))/30,2)),'.','')),13)
	cValor := StrZero(Val(cValToChar(Round((SE1->E1_SALDO*(SEE->EE_ZZMORA/100))/30,2)*100)),13) // @history ticket 70022 - Fernando Macieira - 28/03/2022 - Erro Remessa valor Mora
	
RETURN(cValor)
