#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADFIN062P �Autor  �William Costa       � Data �  02/02/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para preencher o campo Juros de um dia do CNAB ITAU���
���          �coluna de detalhe 161-173                                   ���
�������������������������������������������������������������������������͹��
���Uso       � CNAB ITAU - ITAU.REM                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION ADFIN062P()

	Local cValor := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para preencher o campo Juros de um dia do CNAB ITAU coluna de detalhe 161-173')
	
	cValor := STRZERO(VAL(STRTRAN(CVALTOCHAR(ROUND((SE1->E1_SALDO*(SEE->EE_ZZMORA/100))/30,2)),'.','')),13)
	
RETURN(cValor)