
#include "protheus.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISVALNFE �Autor  �Fernando Macieira   � Data �  05/30/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para impedir transmissao de serie VC       ���
���          �Chamado n. 041819                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FISVALNFE()

Local lTran		:=.T.
Local cTipo		:=PARAMIXB[1]
Local cFil		:=PARAMIXB[2]
Local cEmissao	:=PARAMIXB[3]
Local cNota		:=PARAMIXB[4]
Local cSerie	:=PARAMIXB[5]
Local cClieFor	:=PARAMIXB[6]
Local cLoja		:=PARAMIXB[7]
Local cEspec	:=PARAMIXB[8]
Local cFormul	:=PARAMIXB[9]

SF3->( dbSetOrder(6) ) // F3_FILIAL+F3_NFISCAL+F3_SERIE                                                                                                                                   
If SF3->( dbSeek( cFil+cNota+cSerie ) )
	
	// Nao permite transmitir s�rie VC (Via Cega)
	If AllTrim(cSerie) == "VC"
		lTran := .F.
	EndIf
	
EndIf

Return lTran
