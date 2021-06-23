#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "FiveWin.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN007P º Autor ³ Mauricio - MDS TEC º Data ³  06/04/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Permite usuario alterar parametro MV_#MAILLC               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO - ALBERTO                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADFIN007P()

Private oDlg    := Nil
Private _cMVPAR   := Alltrim(GetMV("MV_#MAILLC"))+Space(150)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Permite usuario alterar parametro MV_#MAILLC')

cAlias:=Alias()
Index :=IndexOrd()
Rec   :=Recno()

@0,0 TO 220,500 DIALOG oDlg TITLE "Alteração Parametro email Limite Credito"

@10,5 SAY "CONTEUDO : "
@10,80 MSGET _cMVPAR SIZE 120,10 PIXEL OF oDlg

@ 88,100 BUTTON "&Alterar" SIZE 33,14 PIXEL ACTION oCons()
@ 88,200 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()  

ACTIVATE DIALOG oDlg CENTER

RETURN

STATIC FUNCTION oCons()
IF !MSGBOX("Tem certeza?","CONFIRMACAO","YESNO")
	return
endif

_nLim := _cMVPAR

GetMV("MV_#MAILLC")
DbSelectArea("SX6")
While !MsRlock(); End
MsRlock()                           
    SX6->X6_CONTEUD:=_nLim
    SX6->X6_CONTENG:=_nLim
    SX6->X6_CONTSPA:=_nLim
MsRunlock()
         
dbSelectArea(cAlias)
dbSetOrder(Index)
dbGoto(Rec)

Close(oDlg)

RETURN(.T.)