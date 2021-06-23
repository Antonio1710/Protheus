#Include "Protheus.ch"
#Include "Rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADOA07
	(CSV - Transporte - Geracao do arquivo de averbacao de carga)
	@type  Function
	@author hcconsys Everson
	@since 08/05/2008
	@version 01
	@history Chamado:053757 POR ADRIANO SAVOINE 03/12/2019 - Foi criada uma nova coluna Data Entrega pegando a data da SC5.
	/*/


User Function ADOA07()

	//Local cPerg	:= "ADOA07"
	Local cPerg	:= PADR("ADOA07",10," ")  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'(CSV - Transporte - Geracao do arquivo de averbacao de carga)') 

	ValidPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		Return ( .T. )
	EndIf

	MsgRun("Aguarde, Gerando Planilha ...","",{|| CursorWait(),GeraSF2(),CursorArrow()})

Return


/**********************/
Static Function GeraSF2()

	Local aStru		:= {}
	Local aRegs		:= {}


	Local cArq		:= " "
	Local _xFilSF2 	:= xFilial("SF2")   
	Local _xFilSD2 	:= xFilial("SD2")
	Local _cPlacAnt	:= ""
	Local _dDtAnt	:= ctod("  /  /  ")
	Local cCamposF2 := ""
	Local _seqArq	:= 0
	Local _cUFOri			:= GETMV("MV_ESTADO")
	Local _cCFOP		:= GETMV("MV_ADCFOP") // define cfop de venda 

	Local cArq		:= "AVERBACAO" 

	//_ProxNum	:= _nProxNum + 1

	dbSelectArea("SF2")
	dbSetOrder(1)

	// MONTA CABECALHO EXCEL

	aStru := {	{"FILIAL"				, "C", 02, 0},; //Data do Embarque
	{"DATAEMB"			, "D", 10, 0},; //Data do Embarque
	{"PLCVEI"			, "C", 07, 0},; //Placa do Veiculo
	{"SERIENF"			, "C", 03, 0},; //Numero da Nota fiscal
	{"NUMNF"				, "C", 06, 0},; //Numero da Nota fiscal	// PRECISA ALTERAR
	{"UFORI"				, "C", 02, 0},; //UF Origem
	{"UFDES"				, "C", 02, 0},; //UF Destino
	{"PESOLIQ"				, "N", 15, 2},; //Peso liquido
	{"TOTNF"				, "N", 15, 2},; //Valor total da nota
	{"CFOP"				, "C",  4, 0},;	
	{"CNPJ"			    , "C",  8, 0},;  //Cnpj do cliente
	{"REDE"		    	, "C",  40, 0},;  //Nome do cliente
	{"NOME"		    	, "C",  6, 0},;  //Codigo da Rede do cliente
	{"DTENTREG"			, "D", 10, 0} }  // Data de Entrega Pedido Venda SC5 por Adriano Savoine Chamado: 053757

	//TRATAMENTO DO MV_PAR03 PREENCHIDO PELA FUNCAO cSITUACAO DO SX1

	//For i:=1 to Len(mv_par03)
	//	cStrQry += "'" + SubStr((mv_par03),i,1) + "'"
	//	If I != Len(mv_par03)
	//		cStrQry += ","
	//	EndIf
	//Next

	//cStrQry += ")"


	cQuery := "SELECT F2_FILIAL,F2_EMISSAO,F2_PLACA,F2_SERIE,F2_DOC,F2_EST,F2_VALBRUT,F2_CLIENTE,F2_LOJA, F2_PLIQUI,"
	cQuery += " SUBSTRING(A1_CGC,1,8) AS CNPJ, A1_NOME, C5_DTENTR "
	cQuery += " FROM "+RetSqlName("SF2")
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQuery += " LEFT  JOIN "+RetSqlName("SC5")+" ON C5_NOTA = F2_DOC AND C5_FILIAL = F2_FILIAL "  // CHAMADO: 053757 POR ADRIANO SAVOINE 03/12/2019
	cQuery += " WHERE F2_FILIAL = '"+_xFilSF2+"' "
	cQuery += "	AND F2_EMISSAO >= '"+Dtos(mv_par01)+"' AND F2_EMISSAO <='"+Dtos(mv_par02)+"' "
	cQuery += " AND F2_PLACA 	BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " AND F2_PLACA 	<> ' '"
	cQuery += " AND "+RetSqlName("SF2")+".D_E_L_E_T_ = ' ' "
	cQuery += " AND "+RetSqlName("SA1")+".D_E_L_E_T_ = ' ' "
	cQuery += " AND "+RetSqlName("SC5")+".D_E_L_E_T_ = ' ' "  // CHAMADO: 053757 POR ADRIANO SAVOINE 03/12/2019
	cQuery += "ORDER BY F2_FILIAL,F2_EMISSAO, F2_PLACA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

	tcsetfield("QRY","F2_FILIAL"	,"C",2)
	tcsetfield("QRY","F2_EMISSAO"	,"D")
	tcsetfield("QRY","F2_PLACA"		,"C",7)
	tcsetfield("QRY","F2_SERIE"		,"C",3)
	tcsetfield("QRY","F2_DOC"		,"C",6)
	tcsetfield("QRY","F2_EST"		,"C",2)
	tcsetfield("QRY","F2_VALBRUT"	,"N",14,2)
	tcsetfield("QRY","F2_PLIQUI"	,"N",14,2)
	tcsetfield("QRY","F2_CLIENTE"		,"C",6)
	tcsetfield("QRY","F2_LOJA"		,"C",2)
	tcsetfield("QRY","CNPJ"	    	,"C",8)
	tcsetfield("QRY","A1_NOME"	   	,"C",40)
	tcsetfield("QRY","REDE"	    	,"C",6)
	tcsetfield("QRY","C5_DTENTR"	,"D") // CHAMADO: 053757 POR ADRIANO SAVOINE 03/12/2019


	QRY->(dbGotop())

	While QRY->(!EOF())
		
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(_xFilSD2 + QRY->F2_DOC + QRY->F2_SERIE  + QRY->F2_CLIENTE + QRY->F2_LOJA)
		
		IF _xFilSF2 == "02" .AND.  !ALLTRIM(SD2->D2_CF)  $ _cCFOP //"5118/5101/6101/5116/6107"
			dbSelectArea("QRY")
			dbskip()
			loop
	//	ELSEIF  _xFilSF2 == "03" .AND.  !ALLTRIM(SD2->D2_CF) $  _cCFOP //"5151"
		ELSEIF  _xFilSF2 == "03" //.AND.  !ALLTRIM(SD2->D2_CF) $  _cCFOP //"5151" RETIRADO POR SOLICITAÇÃO ROSANGELA EM 16/05/08
			dbSelectArea("QRY")
			dbskip()
			loop
		endif
		
		_cCodRede := ""
		dbSelectArea("SZF")
		dbSetOrder(1)
		If dbSeek(xFilial("SZF")+Alltrim(QRY->CNPJ))
			_cCodRede := SZF->ZF_REDE
		Endif
		
		cCamposF2 := Alltrim(QRY->F2_FILIAL) +";"							 					// 00
		cCamposF2 += Alltrim(DTOC(QRY->F2_EMISSAO))+";"							 					// 00
		cCamposF2 += Alltrim(QRY->F2_PLACA)	+";"														// 01
		cCamposF2 += Alltrim(QRY->F2_SERIE)	+";"														// 02
		cCamposF2 += Alltrim(QRY->F2_DOC)	+";"														// 03
		cCamposF2 += Alltrim(_cUFOri)		+";"														// 04
		cCamposF2 += Alltrim(QRY->F2_EST)	+";"														// 05
		cCamposF2 += Alltrim(Str(QRY->F2_PLIQUI)) +";"
		cCamposF2 += Alltrim(str(QRY->F2_VALBRUT))+";"  												// 08
		cCamposF2 += SD2->D2_CF+";"
		cCamposF2 += Alltrim(QRY->CNPJ)+";"
		cCamposF2 += Alltrim(_cCodRede)+";"
		cCamposF2 += Alltrim(QRY->A1_NOME)+";"
		cCamposF2 += Alltrim(DTOC(QRY->C5_DTENTR)) // CHAMADO: 053757 POR ADRIANO SAVOINE 03/12/2019
			
		
		AAdd(aRegs,cCamposF2)
		
		
		QRY->(DbSkip())
		
	EndDo

	CriaExcel(aStru,aRegs,cArq)

	QRY->(dbCloseArea())

Return

/*/{Protheus.doc} Static Function CriaExcel
	(Gera o arquivo excel de acordo com a estrutura, registros e nome passados a funcao.)
	@type  Function
	@author user
	@since 08/05/2008
	@version 01
	@history Uso Generico Especifico Adoro
	/*/


Static Function CriaExcel(aStru,aRegs,cArq)

	Local cDirDocs 	:= MsDocPath()
	Local cPath		:= AllTrim(GetTempPath())
	Local oExcelApp
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local nHandle
	Local nX

	ProcRegua(Len(aRegs)+2)

	if file(cPath+"\"+cArq+".CSV")
		FErase(cPath+"\"+cArq+".CSV")		
	endif

	nHandle := MsfCreate(cDirDocs+"\"+cArq+".CSV",0)

	If nHandle > 0
		
		// Grava o cabecalho do arquivo
		
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		
		aEval(aStru, {|e,nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		
		fWrite(nHandle, cCrLf ) // Pula linha
		
		For nX := 1 to Len(aRegs)
			IncProc("Aguarde! Gerando arquivo de integração com Excel...")
			fWrite(nHandle,aRegs[nX])
			fWrite(nHandle, cCrLf ) // Pula linha
		Next
		
		IncProc("Aguarde! Abrindo o arquivo..." )
		
		fClose(nHandle)
		
		
		CpyS2T( cDirDocs+"\"+cArq+".CSV" , cPath, .T. )
		
		
		If ! ApOleClient('MsExcel')
			MsgAlert("Excel nao instalado!")
			Return
		Else
			
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath+cArq+".CSV" ) // Abre uma planilha
			oExcelApp:SetVisible(.T.)
		
		EndIf
	Else
		MsgAlert( "Falha na criacao do arquivo" )
	Endif

	Return


	/******************************/
	Static Function ValidPerg(cPerg)

		Local _sAlias := Alias()
		Local aRegs   := {}
		Local i, j

		dbSelectArea("SX1")
		dbSetOrder(1)

		cPerg := Padr(cPerg,10," ")

		aAdd(aRegs,{cPerg,"01","Data de        ","Data de   	 ","Data de        "				,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Data Ate       ","Data Ate       ","Data Ate       "				,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Placa de	   ",".     	     ",".			   "				,"mv_ch3","C",07,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"04","Placa Ate      ",".     	     ",".			   "				,"mv_ch4","C",07,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
		//aadd(aRegs,{cperg,"05","Diretorio gravacao ?","Diretorio gravacao ?","Diretorio gravacao ?"	,"mv_ch5","C",30,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})

		For i := 1 to Len(aRegs)
			If 	!dbSeek( cPerg + aRegs[i,2] )
				RecLock("SX1", .T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
				MsUnlock("SX1")
			Endif
		Next

		dbSelectArea(_sAlias)

Return
