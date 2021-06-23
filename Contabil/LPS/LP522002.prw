#include 'protheus.ch'
#include 'parmtype.ch'

user function LP522002()

	Local nValor := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nValor := IIF(SE5->E5_BANCO == 'KOB',IF(!SE5->E5_TIPODOC$"BOF,J2",SE5->E5_VALOR-SE5->E5_VLJUROS,0) ,IF(!SE5->E5_TIPODOC$"BOF,J2",SE5->E5_VALOR,0) )
	
return(nValor)