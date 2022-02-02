#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA200FA  ºAutor  ³Fernando Macieira   º Data ³ 11/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada chamado no encerramento do projeto.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 047792 - FWNM - 11/03/2019 - Forcar o encerramento do prj  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 ||    º±±
±±º          ³ || PROJETO ENCERRADO - FWNM - 26/06/2019                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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