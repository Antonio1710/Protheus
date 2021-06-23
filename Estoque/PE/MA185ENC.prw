#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA185ENC  �Autor  �Fernando Macieira   � Data �  10/06/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto Entrada no encerramento da SA para ajustar valor     ���
���          �consumido nos projetos de investimentos                     ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������͹��
���Chamado   � 049479 || OS 050768 || ENGENHARIA || SILVANA || 8406 ||    ���
���          � || CONSUMO PROJETO - FWNM - 10/06/2019                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA185ENC()

	Local nVlrNew := 0
	
	If AllTrim(SCP->CP_STATUS) == "E"
	
		nVlrNew := (SCP->CP_XPRJVLR / SCP->CP_QUANT) * SCP->CP_QUJE
		
		RecLock("SCP", .f.)
			SCP->CP_XPRJVLR := nVlrNew
		SCP->( msUnLock() )
	
	EndIf

Return