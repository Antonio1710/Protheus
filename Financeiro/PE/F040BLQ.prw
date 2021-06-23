#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F040BLQ   �Autor  �Fernando Macieira   � Data � 20/03/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto Entrada - Contas Receber                             ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������͹��
���Chamado   � 047829 || OS 049134 || CONTROLADORIA || ANA_CAROLINA       ���
���          � || 8464 || DATAFIN X EXCLUSAO - FWNM - 20/03/2019          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F040BLQ()

	Local lRet     := .t.
	Local dDataEmi := SE1->E1_EMISSAO 
	Local dDataFin := GetMV("MV_DATAFIN")
	
	If INCLUI .or. ALTERA
		If dDataBase < dDataFin 
			lRet := .f.
			Aviso("F040BLQ-01", "Movimenta��o n�o permitida! Financeiro bloqueado nesta data. Mude a database ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	
	Else
		If dDataEmi < dDataFin 
			lRet := .f.
			Aviso("F040BLQ-02", "Movimenta��o n�o permitida! Financeiro bloqueado nesta data. Contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
		EndIf
	
	EndIf
	
Return lRet