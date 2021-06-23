
#include "PROTHEUS.CH"
#include "Ap5Mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaHtml บAutor  ณFernando Macieira   บ Data ณ  01/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para gerar o HTML que sera enviado na recusa do Prj บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADPRJ005P(aWFCabec, aWFItens, cTitulo)

Local cHTML  := ""
Local nVlTot := 0
Local cWidth, cWdt

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para gerar o HTML que sera enviado na recusa do Prj')

aEval(aWFItens,{|x,y| nVlTot += x[2] })
cWidth := AllTrim(STR(nVlTot,4))

cHTML := '<html>' + CRLF
cHTML += '<BODY>' + CRLF
cHTML += CRLF

cHTML += '<table border="2" width="80%" bgcolor="#FFFFFF">' + CRLF
cHTML += '<tr>'  + CRLF
cHTML += '   <td width="' + cWidth + '%" align="center" bgcolor="white">'  + CRLF
cHTML += '   <font size="4" Color="#000000" face="Arial">' + Alltrim( SM0->M0_NOME ) + '</font></b>'  + CRLF
cHTML += '   <br>'  + CRLF
cHTML += '   <font size="2" Color="#000000" face="Arial">' + cTitulo + '</font></b>' + CRLF
cHTML += '</tr>' + CRLF

cHTML += '</table>' + CRLF
cHTML += '<table border="1" width="80%" bgcolor="#000080">' + CRLF
cHTML += '<tr>' + CRLF

For nXy := 1 to Len(aWFCabec)
	cWdt  := AllTrim( STR(aWFCabec[nXy,2],3) )
	cHTML += '   <td width="'+cWdt+'%" align="center" bgcolor="#CCFFCC">' + CRLF
	cHTML += '   <font size="1" face="Arial" Color="000000"><b>' + aWFCabec[nXy,1] +  '</b></font></td>' + CRLF
Next nXy

cHTML += '</tr>' + CRLF
cHTML += '<tr>' + CRLF

For nXy := 1 to Len( aWFItens )
	cWdt  := AllTrim( STR(aWFItens[nXy,2],3) )
	cHTML += '   <td width="'+ cWdt + '%" align="'+aWFItens[nXy,3]+'" bgcolor="#FFFFFF">' + CRLF
	cHTML += '   <font size="1" face="Arial" Color="000000"><b>' + Iif(ValType(aWFItens[nXy,1])=="C", aWFItens[nXy,1], AllTrim(Str(aWFItens[nXy,1]))) + '</b></font></td>' + CRLF
Next nXy
cHTML += '</tr>' + CRLF
	
cHTML += '</table>' + CRLF
cHTML += '<Br>'   + CRLF
cHTML += '<BODY>' + CRLF
cHTML += '<html>' + CRLF

Return cHTML

