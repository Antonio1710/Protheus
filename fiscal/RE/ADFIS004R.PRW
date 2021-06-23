#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS004R บAutor  ณEverson           บ Data ณ  30/01/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gerar relat๓rio HTML do arquivo de NF-e do     บฑฑ
ฑฑ           ณ software espiใo x Protheus.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADFIS004R() // U_ADFIS004R()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local oButton1
	Local oButton2
	Local oComboBo1
	Local cStatus := 1
	Local oSay1
	Local aStatus := {"1=Todos","2=Nใo Est. e Canc.","3=Nใo Escriturado","4=Valor divergente","5=Escrit. e Canc.","6=Filial incorreta"}

	Static oDlg
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para gerar relat๓rio HTML do arquivo de NF-e do software espiใo x Protheus.')

	DEFINE MSDIALOG oDlg TITLE "Relat๓rio" FROM 000, 000  TO 200, 250 COLORS 0, 16777215 PIXEL Style 128
	
	@ 012, 004 SAY oSay1 PROMPT "Por favor, selecione o status do relat๓rio." SIZE 116, 013 OF oDlg COLORS 0, 16777215 PIXEL
	
    @ 037, 004 MSCOMBOBOX oComboBo1 VAR cStatus ITEMS aStatus SIZE 115, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 091 BUTTON oButton1 PROMPT "Cancelar" SIZE 028, 012 OF oDlg ACTION oDlg:End() PIXEL
    @ 080, 051 BUTTON oButton2 PROMPT "Ok" SIZE 028, 012 OF oDlg ACTION (oDlg:End(),MsAguarde({||processarRel(cValToChar(cStatus))},"Aguarde","Imprimindo relat๓rio...")) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessarRel บAutor  ณEverson        บ Data ณ  30/01/2016   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o relat๓rio.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processarRel(cStatus)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery		:= ""
	Local cQuery2		:= ""
	Local nNumReg		:= 0
	Local cBuffer		:= ""
	Local cRelName		:= "Relat๓rio Notas Emitidas(Espiใo)"
	Local folder		:= "C:\temp\ "
	Local arq			:= "rel_notas_emitidas.html"
	Local nHandle	
	
	Local cPulaLin		:= Chr(13) + Chr(10)
	Local nNumExiste	:= 0
	Local nNumNExiste	:= 0
	Local nNumCancel	:= 0
	Local nNumEntOutFil	:= 0
	Local nNumCancEscrit:= 0
	Local nNumVlrDiverg	:= 0
	Local cCabecalho	:= ""
	
	Local cTpDoc		:= ""
	
	cQuery2 := ""
	cQuery2 += " SELECT  " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '' THEN 1 ELSE 0 END) AS  'B', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '2' THEN 1 ELSE 0 END) AS '_2', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '3' THEN 1 ELSE 0 END) AS '_3', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '4' THEN 1 ELSE 0 END) AS '_4', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '5' THEN 1 ELSE 0 END) AS '_5', " 
	cQuery2 += " SUM(CASE WHEN ZBK_STPROT = '6' THEN 1 ELSE 0 END) AS '_6' " 
	cQuery2 += " FROM " + RetSqlName("ZBK") + " AS ZBK  " 
	cQuery2 += " WHERE  " 
	cQuery2 += " ZBK.D_E_L_E_T_ = ''  " 
	
	If cStatus <> "1"
		cQuery2 += " AND ZBK_STPROT = '" + cStatus + "'  "
	
	Else
		cQuery2 += " AND ZBK_STPROT <> '1'  "
		
	EndIf
	 
	cQuery2 += " AND ZBK_BAIXA = ''  " //Everson - 04/05/2017. Chamado 034986.
	cQuery2 += " AND ZBK_FILIAL = '" + xFilial("ZBK") + "' " 
	
	If Select("CABECALHO") > 0
		CABECALHO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery2 New Alias "CABECALHO"
	
	DbSelectArea("CABECALHO")
	CABECALHO->(DbGoTop())
		nNumNExiste 	:= CABECALHO->_3
		nNumCancel		:= CABECALHO->_2
		nNumEntOutFil	:= CABECALHO->_6
		nNumCancEscrit	:= CABECALHO->_5
		nNumVlrDiverg	:= CABECALHO->_4

	//
	cQuery := ""
	cQuery += " SELECT  * "  
	cQuery += " FROM " + RetSqlName("ZBK") + " AS ZBK  " 
	cQuery += " WHERE  " 
	cQuery += " ZBK.D_E_L_E_T_ = ''  " 
	
	If cStatus <> "1"
		cQuery += " AND ZBK_STPROT = '" + cStatus + "'  "
	
	Else
		cQuery += " AND ZBK_STPROT <> '1'  "
		
	EndIf
	 
	cQuery += " AND ZBK_BAIXA = ''  " //Everson - 04/05/2017. Chamado 034986.
	cQuery += " AND ZBK_FILIAL = '" + xFilial("ZBK") + "' ORDER BY ZBK_DTPROC DESC, ZBK_CNPJ, ZBK_SERIE, ZBK_DOC " 

	If Select("DADOSZBK") > 0
		DADOSZBK->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "DADOSZBK"
	DbSelectArea("DADOSZBK")
	DADOSZBK->(DbGoTop())
	nNumReg := Contar("DADOSZBK","!Eof()")
	
	//Atribui o tamanho da r้gua.
	ProcRegua(nNumReg)
	
	//Abre o arquivo HTML.
	nHandle	:= FCreate(Alltrim(folder)+arq, FC_NORMAL)
	If nHandle == -1      
		MsgStop('Erro de abertura de arquivo : ' + cPulaLin + 'FERROR ' + cValToChar(ferror(),4),"Fun็ใo Monta_HTML")	
		Return Nil
		  
	Endif   
	
	//Inํcio do HTML.
	cBuffer := ""
	cBuffer += "<html>"
	cBuffer += "<head><title>" + cRelName + "</title><head>"
	cBuffer += "<h1 align='center'><FONT FACE='times' SIZE='6'>" + cRelName + "</FONT></h1>"
	
	cBuffer += "<table>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Data de emissใo do relat๓rio: 	       </b></td><td align='LEFT'><font face='tahoma' size=2>"+DTOC(DATE())+"	</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Filial:			       				</b></td><td align='LEFT'><font face='tahoma' size=2>" + cFilAnt + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2><b>Relat๓rio emitido por:			                 </b></td><td align='LEFT'><font face='tahoma' size=2>" + cUserName + "			</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='red'><b>Nro Sem Entrada(S/E):	   </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumNExiste) + "		</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='purple'><b>Nro Canceladas(NC):   </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumCancel) + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='blue'><b>Nro Entrada em outra filial(Filial):	</b></td><td align='LEFT'><font face='tahoma' size=2>" +cValToChar(nNumEntOutFil) + "	</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='orange'><b>Nro Escriturado, mas cancelado(E/C): </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumCancEscrit) + "</td>"
	cBuffer += "<tr><td align='RIGHT' style='background-color:#DCDCDC'><font face='tahoma' size=2 color='yellow'><b>Nro Valor Divergente(V/D): </b></td><td align='LEFT'><font face='tahoma' size=2>" + cValToChar(nNumVlrDiverg) + "</td>"
	cBuffer += "</tr>"
	cBuffer += "</table>"	
	cBuffer += "<br/>"	
	
	cBuffer += "<table id='regProcessado' border=3 cellspacing=1 cellpadding=1 bordercolor='666633'>"
		cBuffer += "<tr><font face='tahoma' size=1>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Processamento				</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Tipo        			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Chave_Acesso			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Doc						</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>S้rie					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emissao					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Total					</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emitente_CNPJ			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Emitente_Nome			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Data_Recebimento		</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Situacao_NFE			</td>"
			cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;	font-weight: bold; background: #292929; color: #FFF; padding: 3px;'>Obs.					</td>"
			
		cBuffer += "</tr>"	

		//Grava no arquivo e limpa a variแvel para nใo dar estouro de variแvel (mแximo 1 MB).
		FWrite(nHandle, cBuffer + cPulaLin)  
		cBuffer := ""
		

	DADOSZBK->(DbGoTop())
	While ! DADOSZBK->(Eof())
	
		cCor := ""
		cObs := ""
		
		If     Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "1"
			cTpDoc := "NF-e"
		
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "2"
			cTpDoc := "CT-e"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_TPDOC)) == "3"
			cTpDoc := "ND"
			
		EndIf
		
		cDataProc	:= DToC(SToD(cValToChar(DADOSZBK->ZBK_DTPROC)))
		cChave		:= Alltrim(cValToChar(DADOSZBK->ZBK_CHAVE))
		cSerie_cDoc	:= Alltrim(cValToChar(DADOSZBK->ZBK_SERIE + "/" + DADOSZBK->ZBK_DOC))
		cSerie		:= Alltrim(cValToChar(DADOSZBK->ZBK_SERIE))
		cDoc		:= Alltrim(cValToChar(DADOSZBK->ZBK_DOC))
		cEmissao	:= DToC(SToD(Alltrim(cValToChar(DADOSZBK->ZBK_DATA))))
		cValor		:= Transform(Val(Alltrim(cValToChar(DADOSZBK->ZBK_VALOR))),"@E 999,999,999.99")
		cCNPJ		:= Alltrim(cValToChar(DADOSZBK->ZBK_CNPJ))
		cNome		:= Alltrim(cValToChar(DADOSZBK->ZBK_NOME))
		cDtReceb	:= DToC(SToD(Alltrim(cValToChar(DADOSZBK->ZBK_DTRECE))))
		cSituacao	:= Alltrim(cValToChar(DADOSZBK->ZBK_STATUS))

		If		Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '2'	//Nใo escriturado e cancelado.
			nNumCancel ++
			cObs := "NC"
			cCor := "purple"	
			
		ElseIf  Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '3' 	//Nใo escriturado.
			nNumNExiste ++
			cObs := "S/E"
			cCor := "red"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '4' 	//Valor divergente.
			nNumVlrDiverg++
			cObs := "V/D"
			cCor := "yellow"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '5'    //Escriturado, mas cancelado.
			nNumCancEscrit++
			cObs := "E/C"
			cCor := "orange"
			
		ElseIf Alltrim(cValToChar(DADOSZBK->ZBK_STPROT)) == '6'   //Escriturado em filial incorreta.
			nNumEntOutFil++
			cObs := Alltrim(cValToChar(DADOSZBK->ZBK_LOG))
			cCor := "blue"		
			
		EndIf
		
		cBuffer += corpoTabela(cBuffer,cDataProc,cChave,cSerie,cDoc,cEmissao,cValor,cCNPJ,cNome,cDtReceb,cSituacao,cObs,cCor,cTpDoc)
			
		FWrite(nHandle, cBuffer + cPulaLin)
		
		cBuffer := ""
		
		//Incrementa regua de processamento.
		IncProc("DOC " + cSerie_cDoc + " | CNPJ " + cCNPJ)
		
		DADOSZBK->(DbSkip())
		
	EndDo
	
	cBuffer += "</table>"	
	cBuffer += "<hr>"
	
	cBuffer += scriptCSV()
	cBuffer += "</body>"
	cBuffer += "</html>"

	FWrite(nHandle, cBuffer+cPulaLin)
	FClose(nHandle)
	
	Sleep(1500)
	
	MsAguarde({||shellExecute("Open", "C:\temp\rel_notas_emitidas.html", "NULL", "C:\",3)},"Aguarde","Abrindo relat๓rio...")

	MsgInfo("Processo finalizado.","Monta_HTML") 
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcorpoTabela บAutor  ณEverson          บ Data ณ  30/01/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Corpo da tabela.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function corpoTabela(cBuffer,cDataProc,cChave,cSerie,cDoc,cEmissao,cValor,cCNPJ,cNome,cDtReceb,cSituacao,cObs,cCor,cTpDoc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	

	cBuffer += "<tr><font face='tahoma' size=1>" 
		
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDataProc     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cTpDoc        + "	</td>"										
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cChave        + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDoc   		 + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cSerie		 + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cEmissao      + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cValor        + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cCNPJ         + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cNome         + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cDtReceb      + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER;'>	"+ cSituacao     + "	</td>"
		cBuffer += "<td style='border-collapse: collapse; border: 1px solid #292929; text-align: CENTER; background-color:"   + cCor + "'>	"+ cObs +	"	</td>"
	
	cBuffer += "</tr>

Return cBuffer
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptCSV บAutor  ณEverson            บ Data ณ  25/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ JavaScript a ser adicionado na pแgina do relat๓rio        .บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptCSV()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
	Local cScript := ""
	
	cScript += " <script src='https://code.jquery.com/jquery-3.1.1.min.js' integrity='sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=' crossorigin='anonymous'></script> "
	cScript += " <script> "
	cScript += " function download(strData, strFileName, strMimeType) {var D = document, a = D.createElement('a');strMimeType= strMimeType || 'application/octet-stream'; "
	cScript += " if (navigator.msSaveBlob) {return navigator.msSaveBlob(new Blob([strData], {type: strMimeType}), strFileName);} "
	cScript += " if ('download' in a) { a.href = 'data:' + strMimeType + ',' + encodeURIComponent(strData); a.setAttribute('download', "
 	cScript += " strFileName); a.innerHTML = 'downloading...';D.body.appendChild(a); setTimeout(function() {a.click(); D.body.removeChild(a);}, 66);return true;} "
 	cScript += " var f = D.createElement('iframe'); "
    cScript += " D.body.appendChild(f); f.src = 'data:' +  strMimeType   + ',' + encodeURIComponent(strData);setTimeout(function() { D.body.removeChild(f);}, 333);return true;} "	
	cScript += " jQuery.fn.table2CSV = function(options){var options = jQuery.extend({separator: ';',header: [],headerSelector: 'th',columnSelector: 'td', "
	cScript += " delivery: 'popup',filename: 'poweredd_by_sinri.csv',transform_gt_lt: true},	options); "
	cScript += " var csvData = [];var headerArr = [];var el = this; "
	cScript += " var numCols = options.header.length;var tmpRow = []; "
	cScript += " if (numCols > 0){for (var i = 0; i < numCols; i++) {tmpRow[tmpRow.length] = formatData(options.header[i]);}"
	cScript += " } else {$(el).filter(':visible').find(options.headerSelector).each(function() {if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});} "
	cScript += " row2CSV(tmpRow); "
	cScript += " $(el).find('tr').each(function() {var tmpRow = [];$(this).filter(':visible').find(options.columnSelector).each(function() { "
	cScript += " if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).html());});row2CSV(tmpRow);}); "
	cScript += " if (options.delivery == 'popup') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " return popup(mydata);}"
	cScript += " else if(options.delivery == 'download') {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);} "
	cScript += " var url='data:text/csv;charset=utf8,' + encodeURIComponent(mydata);	window.open(url);	return true;} "
	cScript += " else {var mydata = csvData.join('\n');if(options.transform_gt_lt){mydata=sinri_recover_gt_and_lt(mydata);}return mydata;} "
	cScript += " function sinri_recover_gt_and_lt(input){var regexp=new RegExp(/&gt;/g);var input=input.replace(regexp,'>'); "
	cScript += " var regexp=new RegExp(/&lt;/g);var input=input.replace(regexp,'<');	return input;} "
	cScript += " function row2CSV(tmpRow) {var tmp = tmpRow.join(''); if (tmpRow.length > 0 && tmp != '') {	var mystr = tmpRow.join(options.separator); "
	cScript += " csvData[csvData.length] = mystr;	}} "
	cScript += " function formatData(input) {
	cScript += " var regexp = new RegExp(/[']/g); "
	cScript += " var output = input.replace(regexp, '“'); "
	cScript += " var regexp = new RegExp(/\<[^\<]+\>/g); "
	cScript += " var output = output.replace(regexp, ''); "
	cScript += " output = output.replace(/&nbsp;/gi,' '); "
	cScript += " if (output == '') return ''; "
	cScript += " return '"
	cScript += '"'
	cScript += " ' "
	cScript += " + output.trim() + '"
	cScript += '"'
	cScript += " '; } "
			
	cScript += " function popup(data) { "
	cScript += " var generator = window.open('', 'csv', 'height=400,width=600'); "
	cScript += " generator.document.write('<html><head><title>CSV</title>'); "
	cScript += " generator.document.write('</head><body >'); "
	cScript += " generator.document.write('<textArea cols=70 "
	cScript += ' rows=15 wrap="off" '
	cScript += " >'); "
	cScript += " generator.document.write(data); "
	cScript += " generator.document.write('</textArea>'); "
	cScript += " generator.document.write('</body></html>'); "
	cScript += " generator.document.close(); "
	cScript += " return true; "
	cScript += " } "
	cScript += " }; "
	
	cScript += " $(document).ready(function () { "
	
	cScript += " $('#regProcessado').each(function () { "
	cScript += " var $table = $(this); "
	cScript += " var $button = $"
	cScript += ' ("<button '
	cScript += " type='button'> "
	cScript += ' "); '
	cScript += ' $button.text("Exportar"); '
	cScript += " $button.insertBefore($table); "
	cScript += " $button.click(function () { "
	cScript += " var csv = $table.table2CSV({ "
	cScript += " delivery: 'value' "
	cScript += " }); "
	cScript += ' download(csv, "processado.csv", "text/csv");'
	cScript += " }); "
	cScript += " }); "
	
	cScript += " $('#regHistorico').each(function () { "
	cScript += " var $table = $(this); "
	cScript += " var $button = $"
	cScript += ' ("<button '
	cScript += " type='button'> "
	cScript += ' "); '
	cScript += ' $button.text("Exportar"); '
	cScript += " $button.insertBefore($table); "
	cScript += " $button.click(function () { "
	cScript += " var csv = $table.table2CSV({ "
	cScript += " delivery: 'value' "
	cScript += " }); "
	cScript += ' download(csv, "historico.csv", "text/csv"); '
	cScript += " }); "
	cScript += " }); "
	
	cScript += " }) "
		
	cScript += "</script>"
		
Return cScript