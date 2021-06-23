#INCLUDE "Totvs.ch"
#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CEXPCCTD  ºAutor  ³Abel Babini Filho   º Data ³  21/01/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela do Painel Fiscal                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ºChamado   ³                                                            º±±
±±ºInterno TI³Tolerancia no recebimento de Frete-Abel Babini - 08/07/2019 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CEXPCCTD
	Local lRetorno	:= .T.
	Local nPTot		:= 0
	Local nPPed		:= 0
	Local nRegSC7	:= SC7->(RecNo())
	Local nVlTCTe	:= 0
	Local nVlTPed	:= 0
	Local nVlTol	:= GETMV("MV_#TOLCTE",,0)
	 
	For i:=1 to Len(aHeader)
		IF aHeader[i,2]=="XIT_TOTNFE"
			nPTot	:= i
		ENDIF
		IF aHeader[i,2]=="XIT_PEDIDO"
			nPPed	:= i
		ENDIF
	Next i
	
	For i:=1 to len(aCols)
		nVlTCTe += aCols[i,nPTot]
	Next i
	
	While !SC7->(eof()) .AND. SC7->C7_NUM == aCols[1,nPPed]
		nVlTPed += SC7->C7_TOTAL
		SC7->(dbSkip())
	EndDo
	SC7->(dbGoTo(nRegSC7))
	
	IF Abs(nVlTCTe - nVlTPed) > nVlTol
		lRetorno := .F.
	ELSE
		lRetorno := .T.
	ENDIF
	
Return lRetorno