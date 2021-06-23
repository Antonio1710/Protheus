#INCLUDE "rwmake.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � LP596003 � Autor � WILLIAM COSTA        � Data � 30/03/2017���
�������������������������������������������������������������������������͹��
���Descricao � Retorna a conta do fornecedor lancamento padrao 596-003    ���
���          �                                                            ���
��� Alteracao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico ADORO                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/*/

User Function LP596003()

	Local aArea := GetArea()
	Local cConta :="" 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	cConta	:= IIF(AT("JP",SE5->E5_DOCUMEN) > 0,"191110097",IIF(ALLTRIM(SE5->E5_TIPO)=="JP","191110097",IIF(AT("NDC",SE5->E5_DOCUMEN) > 0,"111720002",IIF(ALLTRIM(SA1->A1_EST) <> "EX",TABELA("Z@","A00",.F.),TABELA("Z@","A01",.F.)))))
	
	RestArea(aArea)
	
Return (cConta)