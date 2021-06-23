#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ADCOM018P � Autor � WILLIAM COSTA         � Data �27/12/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o �MOSTRA CONTEUDO DO CAMPO MEMO DO PEDIDO DE COMPRA           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGACOM - 038389                                            ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function ADCOM018P()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	IF EMPTY(SC7->C7_XMEMO)
     	MsgInfo("O item: "+ALLTRIM(SC7->C7_DESCRI)+ " n�o possu� MEMO digitado ...","Consulta Memo")
   ELSE
   		MsgInfo(SC7->C7_XMEMO,"Consulta Memo")
   ENDIF
   
Return(.T.)