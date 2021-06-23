#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACD060VE  �Autor  �Microsiga           � Data �  08/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada na Validacao do Endereco do ACDV060 - ENDER���
���          �Variaveis PRIVATE: cProd|cArmazem|cEndereco                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACD060VE()
Local lRet := .T.
Local nI

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Ponto de Entrada na Validacao do Endereco do ACDV060 - ENDER Variaveis PRIVATE: cProd|cArmazem|cEndereco')

For nI:= 1 to len(aHisEti)
	lRet :=	 U_XVALENPD(aHisEti[nI,1],cArmazem,cEndereco)
	If !lRet
		Exit
	Endif
Next

Return lRet