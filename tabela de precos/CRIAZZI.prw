#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CRIAZZI  บ Autor ณ Lt. Paulo - TDS    บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Especํfico para popular a tabela ZZI - FRETES              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CRIAZZI()

Local lRet 	 := .F.
Local oDlg01
Local oFont1

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Especํfico para popular a tabela ZZI - FRETES')

Define MsDialog oDlg01 From 00,00 To 145,370 Title OemToAnsi("Cria็ใo das Contas Or็amentแrias") Pixel
Define Font oFont1 Name "Arial" Size 0,-14 Bold
@005,005 To 045,180 of oDlg01 Pixel
@010,020 Say OemToAnsi("Este programa tem como objetivo fazer a")  Font oFont1 of oDlg01 Pixel
@020,020 Say OemToAnsi("Cria็ใo das Contas Or็amentแrias,atrav้s") Font oFont1 of oDlg01 Pixel
@030,020 Say OemToAnsi("das Contas de Despesas/Receitas do CTB")   Font oFont1 of oDlg01 Pixel
@050,115 BmpButton Type 1 Action(lRet := .T.,Close(oDlg01))
@050,150 BmpButton Type 2 Action(lRet := .F.,Close(oDlg01))
Activate Dialog oDlg01 Centered

If lRet
   Processa( {|| POPZZI() } )
EndIf

Return

 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ POPZZI   บ Autor ณ Lt. Paulo - TDS    บ Data ณ  16/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para popular a tabela ZZI - FRETES                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function POPZZI

Local _cQuery := ""
Local _nX     := 1
Local _aValor := {3.9,2.9,3.5,4,2.7,3,2.2,1.8,2,3.2,1.3,2.4,2.7,3.3,2.8,2.8,2.9,1.5,1.2,3.3,3.7,4,2.3,2,3.1,1.1,3}
// Ordena a tabela de municipio por ESTADO
_cQuery := "SELECT DISTINCT CC2_EST FROM "+RetSqlName("CC2")+" WHERE D_E_L_E_T_ <> '*' ORDER BY CC2_EST"
TCQUERY _cQuery NEW ALIAS "TMPM"

dbSelectArea("TMPM")
dbGoTop()

While !Eof()
   
   dbSelectArea("ZZI")
   dbSetOrder(2)
   If !dbSeek(xFilial("ZZI") + TMPM->CC2_EST)
      Reclock("ZZI",.T.)
      ZZI->ZZI_FILIAL := '02'
      ZZI->ZZI_ESTADO := TMPM->CC2_EST
      ZZI->ZZI_VALOR  := _aValor[_nX] 
   EndIf
   
   _nX++
   
   dbSelectArea("TMPM")
   dbSkip()

EndDo            

ApMsgAlert(OemToAnsi("F I M"))

Return