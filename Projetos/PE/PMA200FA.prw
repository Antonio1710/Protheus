#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA200FA  �Autor  �Fernando Macieira   � Data � 11/03/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada chamado no encerramento do projeto.       ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������͹��
���Chamado   � 047792 - FWNM - 11/03/2019 - Forcar o encerramento do prj  ���
�������������������������������������������������������������������������͹��
���Chamado   � 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 ||    ���
���          � || PROJETO ENCERRADO - FWNM - 26/06/2019                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PMA200FA()

	Local cCodPrj  := PARAMIXB[1]
	Local cFasPrj  := AllTrim(PARAMIXB[2])
	Local cFaseApr := AllTrim(GetMV("MV_#FASEOK",,"03"))
	Local cFaseEnc := AllTrim(GetMV("MV_#FASENC",,"04"))
	Local aAreaAF8 := AF8->( GetArea() ) 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E - Encerramento do projeto ')

	If cFasPrj == cFaseEnc

		AF8->( dbSetOrder(1) )
		If AF8->( dbSeek(FWxFilial("AF8")+cCodPrj) )
			RecLock("AF8", .f.)
				AF8->AF8_ENCPRJ := "1" // Encerrado
				//AF8->AF8_FASE   := cFaseEnc 
			AF8->( msUnLock() )
		EndIf

	Else
	
		// Chamado n. 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 || PROJETO ENCERRADO - FWNM - 26/06/2019               
		AF8->( dbSetOrder(1) )
		If AF8->( dbSeek(FWxFilial("AF8")+cCodPrj) )
			RecLock("AF8", .f.)
				AF8->AF8_ENCPRJ := "2" // Aberto
				//AF8->AF8_FASE   := cFaseApr
			AF8->( msUnLock() )
		EndIf
	
	EndIf
	
	RestArea( aAreaAF8 )

Return