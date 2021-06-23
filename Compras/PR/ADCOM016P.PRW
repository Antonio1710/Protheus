#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GatSldPrj ºAutor  ³Fernando Macieira   º Data ³  11/17/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao contida no X3_VLDUSER do campo C7_PROJETO            º±±
±±º          ³Funcao contida no X3_VLDUSER do campo D1_PROJETO            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 046284 - fwnm - 08/01/2019 - Novas regras alteracao valor  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADCOM016P(cOrigem, cTabela)

	Local lSldAtv  := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj := GetMV("MV_PRJINIC",,"05")

	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  
	
	Local lRet       := .t.
	Local cCodPrj    := ""
	Local nSldPrj    := ""
	Local nTtItem    := ""
	Local nC7_TOTAL  := ""
	Local nC7_VLDESC := ""
	
	Local aAreaATU   := GetArea()
	Local aAreaAF8   := AF8->(GetArea())
	
	Default cOrigem  := ""
	Default cTabela  := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	// Controle Saldo Projeto ativo
	If lSldAtv
		
		If cTabela == "SD1" 
			// Documento de Entrada         
			cCodPrj    := Iif(AllTrim(cOrigem)=="GATILHO", M->D1_PROJETO, gdFieldGet("D1_PROJETO", n))
			
			nC7_TOTAL  := gdFieldGet("D1_TOTAL", n)
			nC7_VLDESC := gdFieldGet("D1_VALDESC", n)
	
		Else 
			// Pedido de Compra
			cCodPrj    := Iif(AllTrim(cOrigem)=="GATILHO", M->C7_PROJETO, gdFieldGet("C7_PROJETO", n))
			
			nC7_TOTAL  := gdFieldGet("C7_TOTAL", n)
			nC7_VLDESC := gdFieldGet("C7_VLDESC", n)
		EndIf
			
		AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
		If AF8->( dbSeek(xFilial("AF8")+cCodPrj) )
			
			// Consiste fase do projeto para checar se esta na central de aprovacao
			//If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE) // Chamado n. 046284
			If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284

				lRet := .f.
					
				Aviso(	"ADCOM016P-01",;
				"Projeto n. " + AllTrim(cCodPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) +  "Uso ainda não permitido..." + chr(13) + chr(10) + ;
				"",;
				{ "&Retorna" },,;
				"Projeto não aprovado" )
				
			EndIf
	
		
			// Consistencia para projetos ja existentes nao sofrerem problemas com a falta do saldo, conceito implementado a partir de JAN/2018
			//		If DtoS(AF8->AF8_DATA) <= "20180101"
			If AF8->AF8_XVALOR == 0
				Return lRet
			EndIf
			
			// Busca consumo projeto
			nSldPrj := u_ADCOM017P(cCodPrj)
			
			nTtItem := (nC7_TOTAL-nC7_VLDESC)
			
			// Consiste saldo informado no pedido de compras x saldo do projeto (AF8)
			If nTtItem > nSldPrj
				
				lRet := .f.
				
				Aviso(	"ADCOM016P-02",;
				"Total do item excede saldo do projeto! Verifique..." + chr(13) + chr(10) + chr(13) + chr(10) +;
				"Saldo Projeto: " + Transform(nSldPrj, PesqPict("SC7","C7_TOTAL")) + chr(13) + chr(10) +;
				"Total - Desconto do item: " + Transform(nTtItem, PesqPict("SC7","C7_TOTAL")),;
				{ "&Retorna" },,;
				"Projeto sem saldo" )
				
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea( aAreaAF8 )
	RestArea( aAreaATU )

Return lRet