#INCLUDE 'PROTHEUS.CH'
#include 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LP527001  �Autor  �William Costa       � Data �  06/11/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento padrao de cancelamento de baixa contas a receber ���
�������������������������������������������������������������������������͹��
���Uso       � CONTABILIDADE GERENCIA LANCAMENTO PADRAO                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION LP527001()

	Local nValor := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	nValor := IF(SE1->E1_SITUACA $ "1/0/F/G/H/Z",IF(!ALLTRIM(SE5->E5_MOTBX)$"DAC,LIQ,DEV,SIN,DEA,JPN".AND.SE5->E5_TIPO<>"RA ".AND.ALLTRIM(SE5->E5_TIPODOC)<>"JR",SE5->E5_VALOR,0),0)                                                                        
	
RETURN(nValor)