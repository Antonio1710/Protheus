#Include "PROTHEUS.CH"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISTRFNFE   ³ Autor ³ Ana Helena         ³ Data ³15/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto-de-Entrada: FISTRFNFE - Inclusão de botões           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição:                                                             ³±±
±±³Este ponto de entrada tem por finalidade incluir novos botões          ³±±
±±³na rotina SPEDNFE().                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

User Function FISTRFNFE()

aadd(aRotina,{'Mensagem NF','U_GRAVAMSGNF' , 0 , 3,0,NIL})

Return Nil              

User Function GRAVAMSGNF()

Static oDlg
Static oButton1
Static oGet1
Static cNota := space(9)
Static oGet2
Static cSerie := space(3)
Static oGet3
Static cMsgNf := space(70)

U_ADINF009P('FISTRFNFE' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If MsgBox("Deseja incluir uma mensagem na nota fiscal?"," CONFIRMA INCLUSAO ","YESNO")   

	DEFINE MSDIALOG oDlg TITLE "Mensagem NF" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

    @ 009, 048 MSGET oGet1 VAR cNota SIZE 046, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 010, 006 SAY oSay1 PROMPT "Numero da Nota" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 023, 006 SAY oSay2 PROMPT "Série" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 048 MSGET oGet2 VAR cSerie SIZE 023, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 035, 006 SAY oSay3 PROMPT "Mensagem" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 048 MSGET oGet3 VAR cMsgNf SIZE 195, 010 OF oDlg COLORS 0, 16777215 PIXEL        	
    @ 057, 096 BUTTON OemToAnsi("&Confirma")  SIZE 030, 013 ACTION ( nOpc := 0, oDlg:End()) OF oDlg PIXEL	
	
	ACTIVATE MSDIALOG oDlg CENTERED	                          

	dbSelectArea("SC5")
	dbSetOrder(15)	
	If dbSeek(xFilial("SC5")+cNota+cSerie) 		
		If Alltrim(SC5->C5_MENNOT5) = ""
			RecLock("SC5",.F.)
			SC5->C5_MENNOT5 := cMsgNf
			MsUnlock()
		Else 
			Alert("Mensagem nao sera gravada. Campo ja esta preenchido")
		Endif	
	Else 
		Alert("Nf "+cNota+" "+cSerie+" não encontrada!")
	Endif
	
Endif	
	
Return .F. 