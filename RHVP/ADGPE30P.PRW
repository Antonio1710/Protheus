#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CESTAB    ºAutor  ³Fernando Macieira   º Data ³ 09/02/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formula U_CESTAB                                           º±±
±±º          ³ Apaga verbas de cesta basica de acordo com as regras       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CESTAB()

Local aAreaSRC, aAreaRGB, aAreaAtu
Local lFalta    := .f.
Local nQtdHoras := 0

// Regra - hora mínima para exclusao
Local nRef := 2.01

// Verbas envolvidas
Local cPDFalta := "409" // Verba 409 (Falta - Desconto)
Local cPDCesta := "441" // Verba 441 (Cesta Básica - Desconto)
Local cPDBase  := "770" // Verba 770 (Cesta Básica - Base)
Local cPDEmp   := "788" // Verba 788 (Cesta Básica Parte Empresa - Base)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Apaga verbas de cesta basica de acordo com as regras')

// Checa empresa e filial permitida
//If cEmpAnt == "01" .and. AllTrim(SRA->RA_FILIAL) == "02"
If (cEmpAnt == "01" .and. AllTrim(SRA->RA_FILIAL) == "02") .OR. (cEmpAnt == "02")  // Alterado por Adriana para atender Ceres -  chamado 040408
	
	aAreaSRC  := SRC->( GetArea() )
	aAreaRGB  := RGB->( GetArea() )
	aAreaAtu  := GetArea()
	
	// Funcionário possui falta
	RGB->( dbSetOrder(1) ) // RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ
	If RGB->( dbSeek(xFilial("RGB")+SRA->RA_MAT+cPDFalta) )
		
		// Referencia em Horas
		If AllTrim(RGB->RGB_TIPO1) == "H"
			lFalta := .t.
			nQtdHoras := RGB->RGB_HORAS
		EndIf
	
	EndIf
	
	If !lFalta
		SRC->( dbSetOrder(1) )   // RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ
		If SRC->( dbSeek(xFilial("SRC")+SRA->RA_MAT+cPDFalta) )
			
			// Referencia em Horas
			If AllTrim(SRC->RC_TIPO1) == "H"
				lFalta := .t.          
				nQtdHoras := RGB->RGB_HORAS
			EndIf
		
		EndIf
	
	EndIf
	
	
	If lFalta
		
		// Minimo para deleção das verbas
		If nQtdHoras > nRef
			
			// Apaga as verbas - Tabela SRC
			fDelPd(cPDCesta)
			fDelPd(cPDBase)
			fDelPd(cPDEmp)
			
			
			// Apaga verbas - Tabela RGB
			RGB->( dbSetOrder(1) ) // RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ
			
			// Cesta Basica - Desconto
			If RGB->( dbSeek(xFilial("RGB")+SRA->RA_MAT+cPDCesta) )
				RecLock("RGB", .f.)
					RGB->( dbDelete() )
				RGB->( msUnLock() )
			EndIf
			
			// Cesta Basica - Base
			If RGB->( dbSeek(xFilial("RGB")+SRA->RA_MAT+cPDBase) )
				RecLock("RGB", .f.)
					RGB->( dbDelete() )
				RGB->( msUnLock() )
			EndIf
			
			// Cesta Basica - Empresa
			If RGB->( dbSeek(xFilial("RGB")+SRA->RA_MAT+cPDEmp) )
				RecLock("RGB", .f.)
					RGB->( dbDelete() )
				RGB->( msUnLock() )
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea( aAreaAtu )
	RestArea( aAreaRGB )
	RestArea( aAreaSRC )
	
EndIf


Return