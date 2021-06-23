#include "rwmake.ch"
User Function F060EXIT

If Alltrim(ProcName(2)) == "FA060TRANS"
	If (Alltrim(SE1->E1_SITUACA) == "0" .AND. Alltrim(SE5->E5_NATUREZ) == "DESCONT" .AND. Alltrim(SE5->E5_BANCO) == "KOB")
		If SE5->E5_VALOR != SE1->E1_SALDO               
			Reclock("SE1",.F.)
			SE1->E1_PORTADO := "KOB"	
			SE1->E1_AGEDEP  := "KOB"
			SE1->E1_CONTA   := "00000"
			SE1->E1_SITUACA := "2"
			MsUnLock()
		Endif	
	Endif	
Endif	

Return