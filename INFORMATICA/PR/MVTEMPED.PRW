#INCLUDE "rwmake.ch"
#include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บ Autor ณMauricio            บ Data ณ  06/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Programa para alteracao do parametro MV_TEMPED             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MVTEMPED()

Local aAreaAnt := GetArea() 
Local nOpc := 0

Static oDlg
Static oButton1
Static oButton2
Static oGet1
Static _cHora1 := GETMV("MV_TEMPED1")
Static oGet2
Static _cHora2 := GETMV("MV_TEMPED2")
Static oGet3
Static _cHora3 := GETMV("MV_TEMPED3")
Static oGet4
Static _cHora4 := GETMV("MV_TEMPED4")
Static oSay1
Static oSay2
Static oSay3
Static oSay4

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

  DEFINE MSDIALOG oDlg TITLE "Manutencao de Horario - Pedido de Vendas" FROM 000, 000  TO 300, 300 COLORS 0, 16777215 PIXEL
    @ 033, 006 SAY oSay1 PROMPT "ESTADUAL" SIZE 033, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 006 SAY oSay2 PROMPT "INTERESTADUAL" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 006 SAY oSay3 PROMPT "SUPERVISORES" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 073, 006 SAY oSay4 PROMPT "REGIAO SUL" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 033, 060 MSGET oGet1 VAR _cHora1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 046, 060 MSGET oGet2 VAR _cHora2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 059, 060 MSGET oGet3 VAR _cHora3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 072, 060 MSGET oGet4 VAR _cHora4 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 107, 032 BUTTON OemToAnsi("&Confirma") SIZE 037, 012 ACTION ( nOpc := 1, oDlg:End()) OF oDlg PIXEL
    @ 107, 081 BUTTON OemToAnsi("&Cancela")  SIZE 037, 012 ACTION ( nOpc := 0, oDlg:End()) OF oDlg PIXEL
  ACTIVATE MSDIALOG oDlg CENTERED                                                                                               
                                           
If nOpc == 1                                       
	PutMv("MV_TEMPED1",	_cHora1) 
	PutMv("MV_TEMPED2",	_cHora2) 
	PutMv("MV_TEMPED3",	_cHora3) 
	PutMv("MV_TEMPED4",	_cHora4)	
Endif	

RestArea(aAreaAnt)

Return 