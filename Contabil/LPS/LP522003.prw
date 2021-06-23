#include 'protheus.ch'
#include 'parmtype.ch'

user function LP522003()

	Local nValor := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	nValor := IIF(SE5->E5_BANCO == 'KOB',IF(!SE5->E5_TIPODOC$"BOF,J2",SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA+SE5->E5_VLDESCO-SE5->E5_VLCORRE,0) ,SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA+SE5->E5_VLDESCO-SE5->E5_VLCORRE)                                                                                                                           
	
return(nValor)