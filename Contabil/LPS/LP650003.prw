#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LP650003  �Autor  �WILLIAM COSTA       � Data �  03/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento padrao 650003 conta contabil                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
���Alteracoes� Adriana chamado 051044 em 27/08/2019 para SAFEGG           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION LP650003()

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
		OTHERWISE
			cRet := "111610006"	
	ENDCASE
	
	IF cEmpAnt = "09" //Incluido por Adriana chamado 051044 em 27/08/2019
			cRet := "111610021"
	Endif
	
RETURN(cRet)