#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVLCPLOTE  บAutor  ณMicrosiga           บ Data ณ  01/29/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para tratar a variavel clote              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro - Utilizado no ambiente PRODUCAO                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VLCPLOTE()

Local lRet := .t.
Local lServPR := GetMv("MV_#SERVPR",,.F.)
Local cProces := Posicione("SX5",1,Space(2)+"_X","X5_CHAVE")

If lServPR
	If AllTrim( FunName() ) == "CTBA101"
		If cProces == "PROCES"
			lRet := .f.
			Aviso(	"Lan็amento Contแbil",;
			"Lote Contabil nao podera ser alterado. Processamento SIG em andamento. Contate a Contabilidade.",;
			{"&Ok"},,;
			"Altera็ใo Invแlida" )
		EndIf
	ElseIf AllTrim( FunName() ) == "CTBA102"
		If cProces == "PROCES"
			lRet := .f.
			Aviso(	"Lan็amento Contแbil",;
			"Lote Contabil nao podera ser alterado. Processamento SIG em andamento. Contate a Contabilidade.",;
			{"&Ok"},,;
			"Altera็ใo Invแlida" )
		EndIf
	EndIf
EndIf

Return lRet
