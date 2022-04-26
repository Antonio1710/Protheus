#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
	±±ºPrograma  ³LP650123  ºAutor  ³WILLIAM COSTA       º Data ³  03/05/2019 º±±
	±±ºDesc.     ³Lancamento padrao 650003 conta contabil                     º±±
	±±ºUso       ³ SIGAFAT                                                    º±±
	±±ºAlteracoes³ Adriana chamado 051044 em 27/08/2019 para SAFEGG           º±±
		@history Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
*/

USER FUNCTION LP650123()

	cRet := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	DO CASE
		CASE SD1->D1_FILIAL == "02"
			cRet := "111610019"
		CASE SD1->D1_FILIAL == "03"
			cRet := "111610020"
		CASE SD1->D1_FILIAL == "04"
			cRet := "111610021"
		CASE SD1->D1_FILIAL == "05"
			cRet := "111610022"
		CASE SD1->D1_FILIAL == "08"
			cRet := "111610024"		
		CASE SD1->D1_FILIAL == "0B" //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
			cRet := "111610030"	
		OTHERWISE
			cRet := "111610006"	
	ENDCASE
	
	IF cEmpAnt = "09" //Incluido por Adriana chamado 051044 em 27/08/2019
			cRet := "111610021"
	ENDIF

RETURN(cRet)
