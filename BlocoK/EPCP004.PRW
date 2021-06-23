#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EPCP004   ºAutor  ³Guilherme Santos    º Data ³  03/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao de Historico de Inventario                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNumInv  --> Numero do Inventario                          º±±
±±º          ³ nCodHist --> Codigo do Historico                           º±±
±±º          ³ lTipo    --> Tipo de Lancamento:                           º±±
±±º          ³              .T. --> INV (Processamento de Inventario)     º±±
±±º          ³              .F. --> EST (Estorno de Inventario)           º±±
±±º          ³ cOp      --> Ordem de Producaoco                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet --> .T. ou .F.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CMP                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EPCP004 (cNumInv, nCodHist, lTipo, cOp, cErro, nQtdRat, nPerc)

Local aArea			:= GetArea()
Local cTipo			:= "INV- "
Local cItmAtu, cObs

DEFAULT nCodHist := 8
DEFAULT lTipo 	 := .T.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Inclusao de Historico de Inventario')

DbSelectArea("ZAN")
DbSetOrder(1)

//Verifica se ja existe historico para o Numero de Inventario
If DbSeek(xFilial("ZAN") + cNumInv)
	cItmAtu := ZAN->ZAN_ITEM
	While !Eof() .And. ZAN->ZAN_NUM == cNumInv
		If ZAN->ZAN_NUM == cNumInv
			cItmAtu := ZAN->ZAN_ITEM
		EndIf
		dbSkip()
	End
	cItmAtu := Soma1(cItmAtu)
Else
	cItmAtu := "001"
EndIf

If !lTipo
	cTipo := "EST- "
EndIf

Do Case
	Case nCodHist == 0
		cObs := cTipo + "Processamento OK    "
	Case nCodHist == 1
		cObs := cTipo + "Sem OP's no Periodo "
	Case nCodHist == 2
		cObs := cTipo + "Saldo Bloqueado"
	Case nCodHist == 3
		cObs := cTipo + "Saldo Insuficiente"
	Case nCodHist == 4
		cObs := cTipo + "Divergencia SB2 X SBF  "
	Case nCodHist == 5
		cObs := cTipo + "Erro ExecAuto       "
	Case nCodHist == 6
		cObs := cTipo + "Qtd.OPs Insuficiente"
	Case nCodHist == 7
		cObs := cTipo + "EXEC - " + cErro  
	Case nCodHist == 8
		cObs := cTipo + "Inventario Nulo"	
	Case nCodHist == 9
		cObs := cTipo + "Sem Saldo no Endereco"	
	Case nCodHist == 10
		cObs := cTipo + "Saldo Atual Negativo"			
EndCase


	//Gravacao do Registro
	RecLock("ZAN",.T.)
	ZAN->ZAN_FILIAL := xFilial("ZAN")
	ZAN->ZAN_NUM	:= cNumInv
	ZAN->ZAN_ITEM	:= cItmAtu
	ZAN->ZAN_USUARI	:= Substr(cUsuario,7,15)
	ZAN->ZAN_DATA	:= dDatabase
	ZAN->ZAN_HORA	:= Time()
	ZAN->ZAN_TIPO	:= StrZero(nCodHist,1)
	ZAN->ZAN_OBS	:= cObs 
	If lTipo .And. nCodHist == 7
		ZAN->ZAN_OP  	:= cOp
		ZAN->ZAN_PERC  	:= nPerc
		ZAN->ZAN_QTDRAT	:= nQtdRat 
	Endif
	MsUnlock()

RestArea(aArea)
Return