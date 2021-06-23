
#include "protheus.ch"
#include "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS025P บAutor  ณFernando Macieira   บ Data ณ  04/23/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para consistir especies que serao permitidas via    บฑฑ
ฑฑบ          ณ rotina pre-nota e documento de entrada                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADFIS025P()

Local lRet    := .T.

Local cEspBlq := GetMV("MV_#NFEESP",,"CTE#SPED")
Local cEmpAut := GetMV("MV_#NFEEMP",,"")
Local cLogAut := GetMV("MV_#NFEUSR",,"")

Local cSpecLo := IIF(AllTrim(FunName()) == "MATA116",c116Especie,cEspecie) //fernando sigoli Chamado: 041718 18/05/2018 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para consistir especies que serao permitidas via rotina pre-nota e documento de entrada')

// Nใo validar qdo central xml
If !IsInCallStack("CENTNFEXM")
	
	// Consisto especies nao permitidas
	If AllTrim(cSpecLo) $ cEspBlq
		
		// Consisto as empresas/filiais que nใo deverใo sofrer consist๊ncias
		If !(cEmpAut $ AllTrim(cEmpAnt)+"/"+AllTrim(cFilAnt))
			
			// Consisto o login que poderแ incluir manualmente sem bloqueio
			If !(cLogAut $ AllTrim(__cUserID))
				
				// Validar somente no DOCUMENTO ENTRADA
				If AllTrim(FunName()) == "MATA103" .or. AllTrim(FunName()) == "MATA116"
				
					lRet := .F.
					
					// Aviso ao usuario
					Aviso(	"ADFIS025P-01",;
					"Esp้cie nใo permitida por esta rotina... Utilize a Central XML ou PRษ-NOTA!" + chr(13) + chr(10) +;
					"" + chr(13) + chr(10) +;
					"" ,;
					{ "&OK" },,;
					"Esp้cie nใo permitida" )
				
				EndIf

			EndIf
			
		EndIf
		
	EndIf
	
EndIf


Return lRet
