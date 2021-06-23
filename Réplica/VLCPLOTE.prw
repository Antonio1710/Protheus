#include "protheus.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VLCPLOTE  �Autor  �Microsiga           � Data �  01/29/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para tratar a variavel clote              ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro - Utilizado no ambiente PRODUCAO                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function VLCPLOTE()

Local lRet := .t.
Local lServPR := GetMv("MV_#SERVPR",,.F.)
Local cProces := Posicione("SX5",1,Space(2)+"_X","X5_CHAVE")

If lServPR
	If AllTrim( FunName() ) == "CTBA101"
		If cProces == "PROCES"
			lRet := .f.
			Aviso(	"Lan�amento Cont�bil",;
			"Lote Contabil nao podera ser alterado. Processamento SIG em andamento. Contate a Contabilidade.",;
			{"&Ok"},,;
			"Altera��o Inv�lida" )
		EndIf
	ElseIf AllTrim( FunName() ) == "CTBA102"
		If cProces == "PROCES"
			lRet := .f.
			Aviso(	"Lan�amento Cont�bil",;
			"Lote Contabil nao podera ser alterado. Processamento SIG em andamento. Contate a Contabilidade.",;
			{"&Ok"},,;
			"Altera��o Inv�lida" )
		EndIf
	EndIf
EndIf

Return lRet
