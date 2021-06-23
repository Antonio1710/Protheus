#include "protheus.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F110CPOS  �Autor  �Fernando Macieira   � Data �  12/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para definir as colunas que serao exibdas ���
���          � no markbrowse da baixa automatica CR - CHAMADO N. 045499   ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F110CPOS()

	Local aCmp := PARAMIXB
	Local cExibe := "E1_OK|E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_CLIENTE|E1_LOJA|E1_NOMCLI|E1_EMISSAO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_XAB|E1_PORTADO|E1_NUMBOR"
	Local aExibe := Separa(cExibe,"|")
	Local aRet := {}
	Local nI := 0
	
	For ni := 1 to Len(aCmp)
		
		If Alltrim(aCmp[nI][1]) $ cExibe
			Aadd(aRet, aCmp[nI])
		EndIf
		
	Next ni

Return aRet