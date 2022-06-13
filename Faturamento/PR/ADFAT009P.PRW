#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Topconn.ch'
/*
	Programa  ณADFAT009P บAutor  ณEverson             บ Data ณ  19/10/2018
	Desc.     ณFun็ใo para importa็ใo de cargas Edata.                    
	Uso       ณChamado .                                                  
	Everson 20/12/2018. Chamado TI. Tratamento para ser importado         
	pela data de de carregamento do Edata.                                
	@history Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
*/
User Function ADFAT009P() // U_ADFAT009P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	 := GetArea()
	Local cAlias := "ZCP"
	Local cUsrImp:= GetMv("MV_#USRIMP",,"")

	Private cCadastro := "Cargas Edata"
	Private aRotina   := { }

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para importa็ใo de cargas Edata.')
	
	ChkFile("ZCP")
	SetKey(VK_F12, {|| U_impCSVED(2) })

	Aadd(aRotina, { "Pesquisar"        , "AxPesqui"      , 0, 1 })
	Aadd(aRotina, { "Visualizar"       , "AxVisual"      , 0, 2 })
	Aadd(aRotina, { "Importar CSV"     , "U_impCSVED(2)" , 0, 6 })
	Aadd(aRotina, { "Exportar CSV"     , "U_expSSVED('" + cAlias + "')"  , 0, 7 })
	Aadd(aRotina, { "Importar Edata"   , "U_intEdtImp()"   , 0, 8 })
	
	//
	If __cUserID $cUsrImp
		Aadd(aRotina, { "Importar CSV Sub" , "U_impCSVED(1)"  , 0, 8 })
	
	EndIf

	DbSelectArea(cAlias)
	DbSetOrder(1)
	MBrowse(6, 1, 22, 75, cAlias)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCSVED  บAutor  ณEverson             บ Data ณ  18/10/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de CSV.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function impCSVED(nOPc)

	Default nOPc := 2

	U_ADINF009P('ADFAT009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para importa็ใo de cargas Edata.')
	
	//
	Processa({|| procCSV(nOPc) },"Aguarde","Lendo arquivo CSV...",.F.)
	
Return Nil

User Function expSSVED(cArquivo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		 := GetArea()
	Local cFiltroRet := ""
	Local cTabela	 := ""

	U_ADINF009P('ADFAT009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para importa็ใo de cargas Edata.')

	//
	cArquivo := Alltrim(cValToChar(cArquivo))

	If Empty(cArquivo)
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	If SX2->(DbSeek(cArquivo))   
		cTabela := X2Nome()

	EndIf
	     
	cFiltroRet := BuildExpr(cArquivo,,cFiltroRet,.T.,,,,cArquivo + " | " + cTabela)
	cFiltroRet := Alltrim(cValToChar(cFiltroRet))

	If ! Empty(cFiltroRet)

		If Substr(cFiltroRet,1,3) == "AND" .Or. Substr(cFiltroRet,1,2) == "OR"
			MsgStop("A expressใo nใo pode iniciar com 'AND' ou 'OR'. A expressใo nใo poderแ ser salva.","Fun็ใo expSSVED")
			RestArea(aArea)
			Return Nil

		EndIf
		
		//
		Processa({|| expCSV(cFiltroRet) },"Aguarde","Gerando arquivo CSV...",.F.)
		
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณexpCSV    บAutor  ณEverson             บ Data ณ  08/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa gera็ใo de CSV.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function expCSV(cFiltroRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	Local cDir		:= ""
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	Local cQuery	:= ""
	Local oJanela	:= GetObjBrow()
	Local cArq		:= "ExpCEdata_" + DToS(Date()) + "_" + StrTran(Time(),":","") + "_.xml"
	Local aCmpTipo	:= {}
	Local aRow		:= {}
	Local cTipoData	:= ""
	Local nTotReg	:= 0
	Local oExcel 	:= Nil
	Local nAux		:= 1
	
	Private aCampos	:= oJanela:AMAPFIELD
	Private i		:= 1
	Private cCampo	:= ""
	
	cDir := cGetFile("Arquivo CSV.", "Selecione o diret๓rio para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil
		
	EndIf
	
	//
	cQuery := sqlScript(cFiltroRet)
	If Select("D_ZCP") > 0
		D_ZCP->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_ZCP"
	DbSelectArea("D_ZCP")
	D_ZCP->(DbGoTop())
		nTotReg := Contar("D_ZCP","!Eof()")
		ProcRegua(nTotReg)
	D_ZCP->(DbGoTop())
	
	//
	oExcel := FWMsExcelEx():New()
	oExcel:AddworkSheet("Dados de Cargas")
	oExcel:AddTable("Dados de Cargas","Dados de Cargas")

	For i := 1 To Len(aCampos)
		
		cTipoData := Alltrim(cValToChar(GetSx3Cache(aCampos[i],"X3_TIPO")))
		
		oExcel:AddColumn("Dados de Cargas","Dados de Cargas",Alltrim(cValToChar(GetSx3Cache(aCampos[i],"X3_TITULO"))),1,Iif(cTipoData == "N",2,Iif(cTipoData == "D",4,1)))
		Aadd(aCmpTipo,{aCampos[i], cTipoData })
	
	Next i
	
	cLin += cEof
	
	While ! D_ZCP->(Eof())
		
		For i := 1 To Len(aCmpTipo)
			
			cCampo := D_ZCP->&(Alltrim(cValToChar(aCmpTipo[i][1])))
	
			//
			If  aCmpTipo[i][2] == "D"
				cCampo := Substr(cCampo,7,2) +"/"+ Substr(cCampo,5,2) +"/"+ Substr(cCampo,1,4)

			EndIf
			
			Aadd(aRow,cCampo)
			
		Next i
		
		oExcel:AddRow("Dados de Cargas","Dados de Cargas",aRow)
		aRow := {}
		
		IncProc("Registro " + cValToChar(nAux) + "/" + cValToChar(nTotReg) )"
		nAux++		
		D_ZCP->(DbSkip())
		
	End
	
	//
	D_ZCP->(DbCloseArea())
	
	oExcel:Activate()
	oExcel:GetXMLFile(cDir+cArq)
	
	WinExec("Explorer.exe" + Space(1) + cDir )
	
	MsgInfo("Arquivo gerado.","Fun็ใo grLRCCSV")
	
	RestArea(aArea)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsqlScript บAutor  ณEverson             บ Data ณ  08/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para gera็ใo de CSV.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function sqlScript(cFiltroRet)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZCP") + " (NOLOCK) AS ZCP " 
	cQuery += " WHERE " 
	cQuery += " ZCP.ZCP_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND ZCP.D_E_L_E_T_ = '' " 
	If !Empty(cFiltroRet)
		cQuery += " AND " + cFiltroRet
	
	EndIf
	
	//
	RestArea(aArea)

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocCSV   บAutor  ณEverson             บ Data ณ  18/10/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo processa importa็ใo de CSV.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procCSV(nOPc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cArq		:= ""
	Local cBuffer	:= ""
	Local nAux		:= 1
	Local aDados	:= {}
	Local lCria		:= .T.
	
	Private cEOL    := CHR(13) + CHR(10)
	Private nBuffer := 1000
	Private nFilePos:= 1000
	Private nPos    := 0
	Private cLine   := ""
	Private _oObj	:= Nil
	
	//
	_oObj := GetObjBrow()
	_oObj:Refresh()

	//
	cArq := cGetFile('Arquivo CSV|*.csv|Arquivo *|*.csv','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		MsgStop( "Nใo foi possํvel obter o arquivo.","Fun็ใo procCSV (ADVEN095P)")
		Return Nil

	Endif
	
	//
	hFile    := FOpen(cArq, 32) 
	If hFile < 0
		MsgStop("Nใo foi possํvel abrir o arquivo " + cValToChar(cArq) + ".","Fun็ใo procCSV")
		RestArea(aArea)
		Return Nil
		
	EndIf
	  
	nFilePos := FSeek(hFile, 0, 0)   
	cBuffer  := Space(nBuffer)                   
	nRead    := FRead(hFile, cBuffer, nBuffer)    
	nPos     := At(cEOL, cBuffer)                 
	ProcRegua(nFilePos)
	
	//
	DbSelectArea("ZCP")
	ZCP->(DbSetOrder(nOPc))
	ZCP->(DbGoTop())
	While !(nRead == 0)
	
		//
	    While (nPos == 0)                               
	        nBuffer  += 1000                             
	        cBuffer  := Space(nBuffer)                   
	        nFilePos := FSeek(hFile, nFilePos, 0)       
	        nRead    := FRead(hFile, cBuffer, nBuffer)     
	        nPos     := At(cEOL, cBuffer)                  
	    End
	  
	    cLine := Substr(cBuffer, 0, nPos)
	    
	    If ! Empty(cLine)

			aDados	 := Separa(Alltrim(cLine),";",.T.)
	
			If nAux == 1
				
				If ! chkCabe(aDados)
					FClose(hFile)
					RestArea(aArea)
					Return Nil
					
				EndIf
			
			Else
				
				If Len(Alltrim(cValToChar(aDados[1]))) >= 18 .And. ! Empty(Alltrim(cValToChar(aDados[2]))) .And. Len(aDados) == 49
					
					For i := 1 To Len(aDados)
						
						If i == 9 .Or. i == 19 .Or. i == 21 .Or. i == 22 .Or. i == 23 .Or. i == 24 .Or. i == 38 //Converter para data.
							aDados[i] := Iif(!Empty(Alltrim(cValToChar(aDados[i]))),CToD(cValToChar(aDados[i])),"")
	
						EndIf
						
						If i == 14 .Or. i == 15 .Or. i == 16 .Or. i == 17 .Or. i == 18 .Or. i == 39 .Or.i == 40 .Or. i == 49 //Converter para n๚mero.
							aDados[i] :=  Iif(!Empty(Alltrim(cValToChar(aDados[i]))),Val(StrTran(cValToChar(aDados[i]),",",".")),0)
							
						EndIf
						
					Next i
					
					ZCP->(DbGoTop())
					lCria := .T.
					If nOPc = 1
					
						If ZCP->( DbSeek( xFilial("ZCP") + Alltrim(cValToChar(aDados[1])) ) )
							
							While ! ZCP->(Eof()) .And. Alltrim(cValToChar(ZCP->ZCP_FILIAL)) == xFilial("ZCP") .And. Alltrim(cValToChar(ZCP->ZCP_IDENTI)) == Alltrim(cValToChar(aDados[1]))
							
								Reclock("ZCP",.F.)
									DbDelete()
								MsUnlock()
								
								ZCP->(DbSkip())
							End
							
						EndIf
						
					Else
					
						If ZCP->( DbSeek( xFilial("ZCP") + (Alltrim(cValToChar(aDados[1])) + Space( (TamSX3("ZCP_IDENTI")[1]) - (Len(Alltrim(cValToChar(aDados[1])))) ) ) + (Alltrim(cValToChar(aDados[2])) + Space( (TamSX3("ZCP_NUCAR")[1]) - (Len(Alltrim(cValToChar(aDados[2])))) ) ) + (Alltrim(cValToChar(aDados[7])) + Space( (TamSX3("ZCP_PLACA")[1]) - (Len(Alltrim(cValToChar(aDados[7])))) ) ) ) )
							lCria := .F.
							
						EndIf
						
					EndIf
						
					//
					If Reclock("ZCP",lCria)
					
						ZCP->ZCP_FILIAL	 := xFilial("ZCP")
						ZCP->ZCP_IDENTI  :=  Alltrim(cValToChar(aDados[1]))
						ZCP->ZCP_NUCAR   :=  Alltrim(cValToChar(aDados[2]))
						ZCP->ZCP_STATUS  :=  aDados[3]
						ZCP->ZCP_TIPOC   :=  aDados[4]
						ZCP->ZCP_CODEX   :=  aDados[5]
						ZCP->ZCP_NUCON   :=  aDados[6]
						ZCP->ZCP_PLACA   :=  Alltrim(cValToChar(aDados[7]))
						ZCP->ZCP_TRANSP  :=  aDados[8]
						
						If ! Empty(aDados[9])
							ZCP->ZCP_DATAC   :=  aDados[9]
						EndIf
						
						ZCP->ZCP_CODPR   :=  aDados[10]
						ZCP->ZCP_DESCRI  :=  aDados[11]
						ZCP->ZCP_CODEXP  :=  aDados[12]
						ZCP->ZCP_NUPAL   :=  aDados[13]
						ZCP->ZCP_PESOB   :=  aDados[14]
						ZCP->ZCP_PESOL   :=  aDados[15]
						ZCP->ZCP_PESOV   :=  aDados[16]
						ZCP->ZCP_DESVIO  :=  aDados[17]
						ZCP->ZCP_PDESV   :=  aDados[18]
						
						If ! Empty(aDados[19])
							ZCP->ZCP_DATAP   :=  aDados[19]
						EndIf
						
						ZCP->ZCP_HORAP   :=  aDados[20]
						
						If ! Empty(aDados[21])
							ZCP->ZCP_DATAPR  :=  aDados[21]
						EndIf
						If ! Empty(aDados[22])
							ZCP->ZCP_DATAE   :=  aDados[22]
						EndIf
						If ! Empty(aDados[23])
							ZCP->ZCP_DATAV   :=  aDados[23]
						EndIf
						If ! Empty(aDados[24])
							ZCP->ZCP_DATACA  :=  aDados[24]
						EndIf
						ZCP->ZCP_HORAC   :=  aDados[25]
						ZCP->ZCP_INTERV  :=  aDados[26]
						ZCP->ZCP_MODALI  :=  aDados[27]
						ZCP->ZCP_NUPED   :=  aDados[28]
						ZCP->ZCP_CODEPE  :=  aDados[29]
						ZCP->ZCP_ETIQUE  :=  aDados[30]
						ZCP->ZCP_LOTER   :=  aDados[31]
						ZCP->ZCP_MOTORI  :=  aDados[32]
						ZCP->ZCP_REGIAO  :=  aDados[33]
						ZCP->ZCP_SUBREG  :=  aDados[34]
						ZCP->ZCP_CIDADE  :=  aDados[35]
						ZCP->ZCP_ESTADO  :=  aDados[36]
						ZCP->ZCP_PAIS    :=  aDados[37]
						If ! Empty(aDados[38])
							ZCP->ZCP_DATAF   :=  aDados[38]
						EndIf
						ZCP->ZCP_TARAE   :=  aDados[39]
						ZCP->ZCP_PESOBR  :=  aDados[40]
						ZCP->ZCP_DATAFA  :=  aDados[41]
						ZCP->ZCP_NOTAFI  :=  aDados[42]
						ZCP->ZCP_CODCLI  :=  aDados[43]
						ZCP->ZCP_RAZAO   :=  aDados[44]
						ZCP->ZCP_NOMEF   :=  aDados[45]
						ZCP->ZCP_CODEXT  :=  aDados[46]
						ZCP->ZCP_NUEMP   :=  aDados[47]
						ZCP->ZCP_TIPOR   :=  aDados[48]
						ZCP->ZCP_QTDEP   :=  aDados[49]
							
						MsUnlock()
						
					EndIf
	
				Else
				
					If nAux > 1
						MsgStop("Linha: " + cValToChar(nAux) + " nใo poderแ ser importada." + Chr(13) + Chr(10) +;
						        "Tamanho Id: " + cValToChar(Len(Alltrim(cValToChar(aDados[1])))) + ""  + Chr(13) + Chr(10) +;
						        "Conte๚do posi็ใo 2: " + Alltrim(cValToChar(aDados[2])) + ""  + Chr(13) + Chr(10) +; 
						        "Qtd. colunas: " + cValToChar(Len(aDados)),"Fun็ใo procCSV")
					
					EndIf
									
				EndIf
			
			EndIf
			
		Else
			
			If nAux > 1
				MsgStop("Linha " + cValToChar(nAux) + " nใo poderแ ser importada.","Fun็ใo procCSV")
			
			EndIf

		EndIf
		
		//Incrementa regua de processamento.
		IncProc("Registro " + Iif(Len(aDados) > 0,cValToChar(aDados[1]),"") + "/" + cValToChar(nAux) + " TmLn " + cValToChar(Len(aDados)) )
		
		//
	    cBuffer  := Space(nBuffer)             
	    nFilePos += nPos + 1                    
	    nFilePos := FSeek(hFile, nFilePos, 0)  
	    nRead    := FRead(hFile, cBuffer, nBuffer)
	    nPos     := At(cEOL, cBuffer)   
	    nAux++
	                
	End
	
	//
	FClose(hFile)
	_oObj := GetObjBrow()
	_oObj:Refresh()
	
	//
	MsgInfo("Processamento concluํdo.","Fun็ใo procCSV (ADVEN095P)")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkCabe   บAutor  ณEverson             บ Data ณ  29/10/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCompara cabe็alho.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkCabe(aCabec)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	  := GetArea()
	Local cCabcom := "Identifica็ใo;Nบ Carga;Status;Tipo Carregamento;C๓d. Ext. Carga;Nบ Container;Placa;Transportador;Data Carga;C๓d. Produto;Descri็ใo do Produto;C๓d. Ext. Produto;Nบ Palete;Peso Base Palete;Peso Lํquido;Peso Venda;Desvio;% Desvio;Data Produ็ใo;Hora Produ็ใo;Data Padrใo;Data Elabora็ใo;Data Vencimento;Data Carregamento;Hora Carregamento;Intervalo Prod. x Exp.;Modalidade Registro;Nบ Pedido;C๓d. Ext. Pedido;Etiqueta Impressa?;Lote Rastreabilidade;Motorista;Regiใo Logํstica;Subregiใo Logํstica;Cidade;Estado;Paํs;Data Faturamento Pedido;Tara Embalagem;Peso Bruto;Data Fechamento Carga;N๚mero Ext. Nota Fiscal;C๓d.Cliente;Razใo Social Cliente;Nome Fantasia Cliente;C๓d.Externo Cliente;Nบ Empenho;Tipo Registro;Qtde. Prod/Emba" + cEOL
	Local aCabcom := Separa(cCabcom,";",.T.)
	Local i		  := 1
	
	Default aCabec:= {}
	
	//
	If Len(aCabcom) <> Len(aCabec)
		MsgStop("Quantidade de colunas divergentes no cabe็alho. Esperado: " + cValToChar(Len(aCabcom)) + " Recebido: " + cValToChar(Len(aCabec)),"Fun็ใo chkCabe")
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//
	For i := 1 To Len(aCabcom)
		If Alltrim(cValToChar(aCabcom[i])) <> Alltrim(cValToChar(aCabec[i]))
			MsgStop("Informa็ใo divergente no cabe็alho na posi็ใo " + cValToChar(i) +  "." + Chr(13) + Chr(10) +;
			"Esperado: " + Alltrim(cValToChar(aCabcom[i]))+  "" + Chr(13) + Chr(10) +;
			"Recebido: " + Alltrim(cValToChar(aCabec[i])) ,"Fun็ใo chkCabe")
			RestArea(aArea)
			Return .F.		
			
		EndIf
	Next i  
	
	//
	RestArea(aArea)
	
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณinterfEdatบAutor  ณEverson             บ Data ณ  14/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para importa็ใo de dados do Edata.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function intEdtImp()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	  := GetArea()	
	
	U_ADINF009P('ADFAT009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para importa็ใo de cargas Edata.')
	
	//
	If ! Pergunte("IMPEDATA",.T.)
		RestArea(aArea)
		Return Nil
	EndIf
	
	//
	If Empty(Alltrim(DToS(MV_PAR01))) .Or. Empty(Alltrim(DToS(MV_PAR02)))
		MsgAlert("Necessแrio informar as datas de inํcio e fim do perํodo a ser importado.","Fun็ใo intEdtImp")
		
	Else
		Processa({|| dadosEdata(DToS(MV_PAR01),DToS(MV_PAR02)) },"Aguarde","Importando registros...")
	
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptEdatบAutor  ณEverson             บ Data ณ  14/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql Edata.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function dadosEdata(cDtIni,cDtFim,lAut)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	  	:= GetArea()	
	//Everson 20/12/2018. Chamado TI.
	//Local cQuery 	:= " SELECT *, LEFT(CONVERT(VARCHAR, DtFechCarg, 103),10)  + ' ' + RIGHT(CONVERT(VARCHAR, DtFechCarg, 120),8) AS DtFechM FROM [LNKMIMS].[SMART].[dbo].vw_Adoro_EXP033 WHERE DtProducao = '" + cDtIni + "' AND DtProducao <= '" + cDtFim + "' "
	Local cLnkSrv		:= Alltrim(SuperGetMV("MV_#UEPSRV",,"LNKMIMS")) //Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	Local cQuery 	:= " SELECT *, LEFT(CONVERT(VARCHAR, DtFechCarg, 103),10)  + ' ' + RIGHT(CONVERT(VARCHAR, DtFechCarg, 120),8) AS DtFechM FROM ["+cLnkSrv+"].[SMART].[dbo].vw_Adoro_EXP033 WHERE CONVERT(date, DtCarregam) >= '" + cDtIni + "' AND CONVERT(date, DtCarregam) <= '" + cDtFim + "' " //Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	Local nTotReg	:= 0
	Local nAux		:= 0
	
	Default lAut	:= .F.
	
	Conout("cDtIni " + cDtIni)
	Conout("cDtFim"  + cDtFim)
	Conout("lAut" + cValToChar(lAut) )
	//
	If Select("D_EDATA") > 0
		D_EDATA->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_EDATA"
	DbSelectArea("D_EDATA")
	D_EDATA->(DbGoTop())
	
	//
	If ! lAut
		nTotReg := Contar("D_EDATA","!Eof()")
		If !MsgYesNo("Serใo importados " + cValToChar(nTotReg) + " registros. Deseja prosseguir?","Fun็ใo dadosEdata")
			D_EDATA->(DbGoTop())
			RestArea(aArea)
			Return Nil
			
		EndIf
		
		ProcRegua(nTotReg)
		D_EDATA->(DbGoTop())
		
	EndIf
	
	//
	DbSelectArea("ZCP")
	ZCP->(DbSetOrder(1))
	ZCP->(DbGoTop())
	
	//
	Conout("cQuery " + cQuery)
	
	//
	While ! D_EDATA->(Eof())
	
		If ZCP->( DbSeek( xFilial("ZCP") + Alltrim(cValToChar(D_EDATA->Identifica )) ) )
								
			While ! ZCP->(Eof()) .And. Alltrim(cValToChar(ZCP->ZCP_FILIAL)) == xFilial("ZCP") .And. Alltrim(cValToChar(ZCP->ZCP_IDENTI)) == Alltrim(cValToChar(D_EDATA->Identifica ))
			
				Reclock("ZCP",.F.)
					DbDelete()
				MsUnlock()
				
				ZCP->(DbSkip())
			End
			
		EndIf
	
		//
		If Reclock("ZCP",.T.)
		
			ZCP->ZCP_FILIAL	 :=  xFilial("ZCP")
			ZCP->ZCP_IDENTI  :=  Alltrim(cValToChar(D_EDATA->Identifica))
			ZCP->ZCP_NUCAR   :=  Alltrim(cValToChar(D_EDATA->NroCarga))
			ZCP->ZCP_STATUS  :=  Alltrim(cValToChar(D_EDATA->Status))
			ZCP->ZCP_TIPOC   :=  Alltrim(cValToChar(D_EDATA->TpCarregam))
			ZCP->ZCP_CODEX   :=  Alltrim(cValToChar(D_EDATA->CodExtCarg))
			ZCP->ZCP_NUCON   :=  Alltrim(cValToChar(D_EDATA->NroContain))
			ZCP->ZCP_PLACA   :=  Alltrim(cValToChar(D_EDATA->Placa))
			ZCP->ZCP_TRANSP  :=  Alltrim(cValToChar(D_EDATA->Transporta))
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtCarga)))
				ZCP->ZCP_DATAC   :=  D_EDATA->DtCarga
			EndIf
			ZCP->ZCP_CODPR   :=  Alltrim(cValToChar(D_EDATA->CodProduto))
			ZCP->ZCP_DESCRI  :=  Alltrim(cValToChar(D_EDATA->DesProduto))
			ZCP->ZCP_CODEXP  :=  Alltrim(cValToChar(D_EDATA->CodExtProd))
			ZCP->ZCP_NUPAL   :=  Alltrim(cValToChar(D_EDATA->NroPalete))
			ZCP->ZCP_PESOB   :=  D_EDATA->PesoBasePa
			ZCP->ZCP_PESOL   :=  D_EDATA->PesoLiqui
			ZCP->ZCP_PESOV   :=  D_EDATA->PesoVenda
			ZCP->ZCP_DESVIO  :=  D_EDATA->PercDesvio 
			ZCP->ZCP_PDESV   :=  D_EDATA->Desvio
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtProducao)))
				ZCP->ZCP_DATAP   :=  D_EDATA->DtProducao
			EndIf
			ZCP->ZCP_HORAP   :=  Alltrim(cValToChar(D_EDATA->HrProducao))
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtPadrao)))
				ZCP->ZCP_DATAPR  :=  D_EDATA->DtPadrao
			EndIf
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtElabora)))
				ZCP->ZCP_DATAE   :=  D_EDATA->DtElabora
			EndIf
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtVenci)))
				ZCP->ZCP_DATAV   :=  D_EDATA->DtVenci
			EndIf
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtCarregam)))
				ZCP->ZCP_DATACA  :=  D_EDATA->DtCarregam
			EndIf
			ZCP->ZCP_HORAC   :=  Alltrim(cValToChar(D_EDATA->HrCarregam))
			ZCP->ZCP_INTERV  :=  Alltrim(cValToChar(D_EDATA->DifProdExp))
			ZCP->ZCP_MODALI  :=  Alltrim(cValToChar(D_EDATA->ModRegistr))
			ZCP->ZCP_NUPED   :=  Alltrim(cValToChar(D_EDATA->NroPedido))
			ZCP->ZCP_CODEPE  :=  Alltrim(cValToChar(D_EDATA->CodExtPedi))
			ZCP->ZCP_ETIQUE  :=  Alltrim(cValToChar(D_EDATA->EtqImpress)) 
			ZCP->ZCP_LOTER   :=  Alltrim(cValToChar(D_EDATA->LoteRastre))
			ZCP->ZCP_MOTORI  :=  Alltrim(cValToChar(D_EDATA->Motorista))
			ZCP->ZCP_REGIAO  :=  Alltrim(cValToChar(D_EDATA->RegLogisti)) 
			ZCP->ZCP_SUBREG  :=  Alltrim(cValToChar(D_EDATA->SubRegLogi))
			ZCP->ZCP_CIDADE  :=  Alltrim(cValToChar(D_EDATA->Cidade))
			ZCP->ZCP_ESTADO  :=  Alltrim(cValToChar(D_EDATA->Estado))
			ZCP->ZCP_PAIS    :=  Alltrim(cValToChar(D_EDATA->Pais)) 
			If ! Empty(Alltrim(cValToChar(D_EDATA->DtFatuPedi)))
				ZCP->ZCP_DATAF   :=  D_EDATA->DtFatuPedi
			EndIf
			ZCP->ZCP_TARAE   :=  D_EDATA->TaraEmbala
			ZCP->ZCP_PESOBR  :=  D_EDATA->PesoBruto
			ZCP->ZCP_DATAFA  :=  Iif(Empty(Alltrim(cValToChar(D_EDATA->DtFechM))),"",D_EDATA->DtFechM)
			ZCP->ZCP_NOTAFI  :=  Alltrim(cValToChar(D_EDATA->NroExtNF))
			ZCP->ZCP_CODCLI  :=  Alltrim(cValToChar(D_EDATA->CodCliente))
			ZCP->ZCP_RAZAO   :=  Alltrim(cValToChar(D_EDATA->RazSocClie))
			ZCP->ZCP_NOMEF   :=  Alltrim(cValToChar(D_EDATA->NmFanClie))
			ZCP->ZCP_CODEXT  :=  Alltrim(cValToChar(D_EDATA->CodExtClie))
			ZCP->ZCP_NUEMP   :=  Alltrim(cValToChar(D_EDATA->NroEmpenho))
			ZCP->ZCP_TIPOR   :=  Alltrim(cValToChar(D_EDATA->TpRegistro))
			ZCP->ZCP_QTDEP   :=  D_EDATA->QtProdEmba
				
			MsUnlock()
			
		EndIf
		
		//
		If ! lAut
			nAux++
			IncProc("Id " + Alltrim(cValToChar(D_EDATA->Identifica)) + " - " + cValToChar(nAux) + "/" + cValToChar(nTotReg) )
		
		EndIf
		
		D_EDATA->(DbSkip())
		
	End
	
	D_EDATA->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return cQuery

/*/{Protheus.doc} u_FAT009A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_FAT009A0( uPar1, uPar2, uPar3 )
Return( dadosEdata( uPar1, uPar2, uPar3 ) )
