/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C7CODPROJ    � Autor � Ana Helena        � Data � 25/04/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � AxCadastro em SZN - SEGMENTO DE MERCADO                    ���
���Descri��o � AxCadastro em SZN - SEGMENTO DE MERCADO                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Adoro Alimenticia                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "rwmake.ch"  

User Function C7CODPROJ()    

Local lRet := .F.    

Local nCC	:= (aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})])

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If SUBSTR(nCC,1,1) == "9" 
	lRet := .T.
Endif                   
	
Return(lRet)