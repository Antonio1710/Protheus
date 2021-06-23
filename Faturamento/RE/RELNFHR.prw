#INCLUDE "rwmake.ch"   
#INCLUDE "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RELNFHR  บ Autor ณ Ana Helena         บ Data ณ  10/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exporta para excel notas de saida de acordo com parametro  บฑฑ
ฑฑบ de data / hora                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RELNFHR()
                   
Local _aStr   := {}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para excel notas de saida de acordo com parametro de data / hora')

cPerg   := PADR('RELNFHR',10," ")
If !Pergunte(cPerg,.T.)
	Return
EndIf

fDados()

bBloco:={|| expExcel()}
MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)

dbCloseArea("TMPQRY")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |fDados    | Autor ณ Luana Ferrari      บ Data ณ  06/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fDados()

Local cQuery:=""

If Select("TMPQRY") > 0
	DbSelectArea("TMPQRY")
	DbCloseArea("TMPQRY")
Endif         

cQuery := " SELECT F2_HORA, "
cQuery += " SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) AS F2_EMISSAO, "
cQuery += " D2_DOC, "
cQuery += " D2_SERIE, "
cQuery += " D2_COD, "
cQuery += " D2_CLIENTE, "
cQuery += " D2_LOJA, "
cQuery += " C6_UNSVEN, "
cQuery += " C6_SEGUM, "
cQuery += " C6_QTDVEN, "
cQuery += " C6_UM, "
cQuery += " C6_PRCVEN, "
cQuery += " C6_VALOR, "
cQuery += " C6_TES, "
cQuery += " C6_CF "
cQuery += " FROM " + RetSqlName("SF2") + " "
cQuery += " INNER JOIN " + RetSqlName("SD2") + " "
cQuery += "  ON F2_FILIAL = D2_FILIAL "
cQuery += " AND F2_DOC = D2_DOC "
cQuery += " AND F2_SERIE = D2_SERIE "
cQuery += " AND D2_CLIENTE = F2_CLIENTE " 
cQuery += " INNER JOIN " + RetSqlName("SC6") + " "
cQuery += "  ON C6_FILIAL = D2_FILIAL "
cQuery += " AND C6_NOTA = D2_DOC "
cQuery += " AND C6_SERIE = D2_SERIE "
cQuery += " AND C6_CLI = D2_CLIENTE "
cQuery += " AND C6_PRODUTO = D2_COD "
cQuery += " WHERE F2_FILIAL          = " + " '" + xFilial("SF2") + "' "
cQuery += "   AND F2_EMISSAO        >= " + " '" + DTOS(MV_PAR01) + "' "
cQuery += "   AND F2_EMISSAO        <= " + " '" + DTOS(MV_PAR02) + "' "
cQuery += "   AND F2_HORA           >= " + " '" + MV_PAR03 + "' "
cQuery += "   AND F2_HORA           <= " + " '" + MV_PAR04 + "' "
cQuery += "   AND C6_CF             IN ('5101','6101','5105','6105','5410','6410','5118','6118','5122','6122','7101','7105') "
cQuery += "   AND "+RetSqlName("SF2")+ ".D_E_L_E_T_ <> '*' "
cQuery += "   AND "+RetSqlName("SD2")+ ".D_E_L_E_T_ <> '*' "
cQuery += "   AND "+RetSqlName("SC6")+ ".D_E_L_E_T_ <> '*' "

cQuery += "  ORDER BY F2_EMISSAO,F2_HORA,"+RetSqlName("SD2")+ ".D2_DOC,D2_SERIE,D2_CLIENTE,D2_COD "

TCQUERY cQuery NEW ALIAS "TMPQRY"

dbselectArea("TMPQRY")
DbgoTop()


Return()

                      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//GERACAO DOS DADOS EM EXCEL
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function expExcel(cArqTRC)
 
dbSelectArea("TMPQRY")
cDirDocs := MsDocPath()
cPath    := AllTrim(GetTempPath())
cArq:="\RELNFHR"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".DBF"
_cCamin:=cDirDocs+cArq
COPY TO &_cCamin VIA "DBFCDXADS"
CpyS2T(_cCamin, cPath, .T. )
//------------------------------
// Abre MS-EXCEL
//------------------------------
If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo nใo estแ instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return   