#INCLUDE "rwmake.ch"   
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function RELNFHR
	Exporta para excel notas de saida de acordo com parametro de data / hora
	@type  Function
	@author Ana Helena
	@since 10/05/13
	@history Ticket  31644 - Abel Babini - 14/09/2021 - Ajuste error.log referente a função DBFCDXADS que foi descontinuada
	/*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³   º Autor ³          º Data ³     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³   º±±
±±º                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |fDados    | Autor ³ Luana Ferrari      º Data ³  06/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//GERACAO DOS DADOS EM EXCEL
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function expExcel(cArqTRC)
	//Ticket  31644 - Abel Babini - 14/09/2021 - Ajuste error.log referente a função DBFCDXADS que foi descontinuada
	Local oExcel     := FWMSEXCELEX():New()
	Local oMsExcel   := NIL
	Local cWrkFld		:= 'RelNFHR'
	Local cWrkSht		:= 'RelNFHR'

	cArquivo := AllTrim(GetTempPath()) +  'RELNFHR' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'

	oExcel:AddworkSheet(cWrkFld)
	oExcel:AddTable(cWrkFld,cWrkSht)
	oExcel:AddColumn(cWrkFld,cWrkSht,'F2_HORA'		,1,1) // 01 A
	oExcel:AddColumn(cWrkFld,cWrkSht,'F2_EMISSAO'	,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'D2_DOC'			,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'D2_SERIE'		,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'D2_COD'			,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'D2_CLIENTE'	,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'D2_LOJA'		,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_UNSVEN'	,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_SEGUM'		,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_QTDVEN'	,2,2) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_UM'			,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_PRCVEN'	,2,3) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_VALOR'		,2,3) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_TES'		,1,1) // 02 B
	oExcel:AddColumn(cWrkFld,cWrkSht,'C6_CF'		,1,1) // 02 B

	("TMPQRY")->(dbGoTOP())
	While !("TMPQRY")->(eof())
		oExcel:AddRow(cWrkFld,cWrkSht,{	("TMPQRY")->F2_HORA,;
																		("TMPQRY")->F2_EMISSAO,;
																		("TMPQRY")->D2_DOC,;
																		("TMPQRY")->D2_SERIE,;
																		("TMPQRY")->D2_COD,;
																		("TMPQRY")->D2_CLIENTE,;
																		("TMPQRY")->D2_LOJA,;
																		("TMPQRY")->C6_UNSVEN,;
																		("TMPQRY")->C6_SEGUM,;
																		("TMPQRY")->C6_QTDVEN,;
																		("TMPQRY")->C6_UM,;
																		("TMPQRY")->C6_PRCVEN,;
																		("TMPQRY")->C6_VALOR,;
																		("TMPQRY")->C6_TES,;
																		("TMPQRY")->C6_CF})
		("TMPQRY")->(dbSkip())
	EndDo
	oExcel:AddRow(cWrkFld,cWrkSht,{"","","","","","","","","","","","","","",""})
	
	("TMPQRY")->(dbGoTOP())
	
	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)

	IF ( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(cArquivo)
		oMsExcel:SetVisible( .T. )
		oMsExcel:Destroy()
	ELSE
		Alert("Nao Existe Excel Instalado ou não foi possível localizá-lo. Tente novamente!")
	ENDIF

/*
	dbSelectArea("TMPQRY")
	cDirDocs := MsDocPath()
	cPath    := AllTrim(GetTempPath())
	cArq:="\RELNFHR"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".DBF"
	_cCamin:=cDirDocs+cArq
	//COPY TO &_cCamin VIA "DBFCDXADS"
	CpyS2T(_cCamin, cPath, .T. )

		//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return
	EndIf
	oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
	oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)
*/
Return   
