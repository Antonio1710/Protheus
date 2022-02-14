#Include "TOPCONN.Ch"
#Include "FILEIO.Ch"

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} User Function xCTBA500
	Contabilização CSV
	@type  Function
	@author Fernando Macieira
	@since 07/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 055592 - FWNM - OS 057029 || CONTROLADORIA || JOYCE || 8386 || TXT - SIG NOVO
	@history ticket  8674   - Fernando Macieira - 03/02/2021 - Erro arquivo csv
	@history ticket  66191  - Everson - 04/01/2022 - Tratamento para error log.
/*/
User Function xCTBA500() // U_xCTBA500()

	Local aSays 	:= {}
	Local aButtons	:= {}
	Local dDataSalv := dDataBase
	Local nOpca 	:= 0
	
	Private cPerg     := PadR( "CTB500", Len(SX1->X1_GRUPO) )
	Private cCadastro := "Contabilização de Arquivos CSV"
	Private lAtureg:= .T.    
	    
	//Ponto de entrada provisorio ate correção do Remote. BOPS 00000138556
	If ExistBlock("CT500REG")
		lAtureg:=ExecBlock("CT500REG",.F.,.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01 // Mostra Lan‡amentos Cont beis                     ³
	//³ mv_par02 // Aglutina Lan‡amentos Cont beis                   ³
	//³ mv_par03 // Arquivo a ser importado                          ³
	//³ mv_par04 // Numero do Lote                                   ³
	//³ mv_par05 // Quebra Linha em Doc.							 ³
	//³ mv_par06 // Tamanho da linha	 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.f.)
	
	AADD(aSays,OemToAnsi( "O objetivo deste programa é gerar lançamentos contábeis" ) )
	AADD(aSays,OemToAnsi( "a partir de um arquivo texto convertido em CSV e com leiaute específico" ) )
	AADD(aSays,OemToAnsi( "Debito;Credito;CC Debito;CC Credito;Item Debito;Item Credito;Classe Debito;Classe Credito;Valor;Historico;Lote Recria" ) )
	
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
		
	IF nOpca == 1

		If FindFunction("CTBSERIALI")
			While !CTBSerialI("CTBPROC","ON")
			EndDo
		EndIf

		Processa({|lEnd| Ctb500Proc()})

		If FindFunction("CTBSERIALI")
			CTBSerialF("CTBPROC","ON")
		EndIf

	Endif
	
	dDataBase := dDataSalv

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Contabilização CSV')

Return

/*/{Protheus.doc} Static Function Ctb500Proc
	(long_description)
	@type  Static Function
	@author user
	@since 07/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Ctb500Proc()

	Local cLote		:= CriaVar("CT2_LOTE")
	Local cArquivo
	Local cPadrao
	Local lHead		:= .F.					// Ja montou o cabecalho?
	Local lPadrao
	Local lAglut
	Local nTotal	:=0
	Local nHdlPrv	:=0
	Local nBytes	:=0
	Local nHdlImp
	Local nTamArq := 0
	Local nTamLinha := 2048

	// Ricardo Lima-13/02/2019
	Local nValorct  := 0
	Local cCcDbt    := ''
	Local aArea // Ricardo Lima-14/02/2019

	// Chamado n. 055592 || OS 057029 || CONTROLADORIA || JOYCE || 8386 || TXT - SIG NOVO - FWNM - 07/02/2020
	Local cTXT := ""
	Local cVerTab := ""
	Local aDadXLS := {}
	Local cEmpZCN := GetMV("MV_#ZCNEMP",,"07")
	Local cFilZCN := GetMV("MV_#ZCNFIL",,"70")
	Local nTotLinha := 0 //Everson - 04/01/2022. Chamado 66191.
	// 
	
	PRIVATE xBuffer	:=Space(nTamLinha)
	Private aRotina := {	{ "","" , 0 , 1},;
							{ "","" , 0 , 2 },;
							{ "","" , 0 , 3 },;
							{ "","" , 0 , 4 } }
	Private Inclui := .T.							
	
	If Empty(mv_par03)
		Help(" ",1,"NOFLEIMPOR")
		Return
	End	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o N£mero do Lote                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLote := mv_par04
	If Empty(cLote)
		Help(" ",1,"NOCT210LOT")
		Return
	EndIf	

	//@history ticket  8674   - Fernando Macieira - 03/02/2021 - Erro arquivo csv
	Pergunte(cPerg,.f.)
	MV_PAR02 := 2 // Aglutina Não (Aglutinado o lote recria não funciona!)
	//

	ProcRegua(nTamArq)
	
	// Chamado n. 055592 || OS 057029 || CONTROLADORIA || JOYCE || 8386 || TXT - SIG NOVO - FWNM - 07/02/2020

	// Consisto extensão arquivo
	If At(".CSV", upper(MV_PAR03)) <= 0
		Aviso("XCTBA500-03", "Arquivo precisa ser em CSV! Converta o arquivo XLS...", {"&Ok"},, "CSV (Separado por virgulas)(*.csv)")
		Return
	EndIf

	// Abro arquivo
	If ft_fUse(MV_PAR03) == -1	
		Aviso("XCTBA500-02", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
		Return
	EndIf

	ft_fGoTop()

	cVerTab := "Debito;Credito;CC Debito;CC Credito;Item Debito;Item Credito;Classe Debito;Classe Credito;Valor;Historico;Lote Recria"
	
	cTxt := AllTrim(ft_fReadLn())
	
	If cVerTab <> cTXT
		Aviso("XCTBA500-01", "A importação não poderá ser realizada! Coloque as colunas do excel antes da conversão em CSV nesta ordem e com estes títulos: " + chr(13) + chr(10) + cVerTab, {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
		Return
	Else
		ft_fSkip() // Pula linha do cabeçalho
	EndIf
	//
	
	Do While !ft_fEOF()
		
		nTotLinha++ //Everson - 04/01/2022. Chamado 66191.

		If lAtureg
			IncProc()
		EndIf	
	
		xBuffer := ft_fReadLn()    
		
		// Chamado n. 055592 || OS 057029 || CONTROLADORIA || JOYCE || 8386 || TXT - SIG NOVO - FWNM - 07/02/2020
		aDadXLS := Separa(xBuffer, ";") 

		//Everson - 04/01/2022. Chamado 66191.
		If Len(aDadXLS) <> 11
			Aviso("XCTBA500-04", "A linha " + cValToChar(nTotLinha) + " não será processada, pois não possui 11 colunas.", {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
			ft_fSkip()
			Loop

		EndIf
		//

		// Variaveis utilizadas no LP CSV
		DEBITO   := aDadXLS[1]
		CREDITO    := aDadXLS[2]
		CCD        := aDadXLS[3]
		CCC        := aDadXLS[4]
		ITEMD      := aDadXLS[5]
		ITEMC      := aDadXLS[6]
		CLVLD      := aDadXLS[7]
		CLVLC      := aDadXLS[8]
		VALOR      := Val(StrTran(StrTran(StrTran(aDadXLS[9],".",""),",","."),"R$",""))
		HISTORICO  := aDadXLS[10]
		LOTERECRIA := aDadXLS[11]
		//

		cPadrao	:= "CSV"
		lPadrao	:= VerPadrao(cPadrao)
		IF lPadrao
			IF !lHead
				lHead := .T.
				nHdlPrv:=HeadProva(cLote,"CTBA500",Substr(cUsuario,7,6),@cArquivo)
			End
			nTotal += DetProva(nHdlPrv,cPadrao,"CTBA500",cLote)
			If mv_par05 == 1			// Cada linha contabilizada sera um documento
				RodaProva(nHdlPrv,nTotal)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lan‡amento Cont bil                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lDigita	:=IIF(mv_par01==1,.T.,.F.)
				lAglut 	:=IIF(mv_par02==1,.T.,.F.)
				cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
				lHead	:= .F.
			EndIf

			// Chamado n. 055592 || OS 057029 || CONTROLADORIA || JOYCE || 8386 || TXT - SIG NOVO - FWNM - 07/02/2020

			// Ricardo Lima-13/02/2019
			/*
			If cEmpAnt = "07"
			
				IF !Empty( Alltrim(SubStr(xBuffer,61,10)) )
					aArea := GetArea() // Ricardo Lima-14/02/2019
					dbSelectArea("ZCN")
					dbSetOrder(3)
					If dbSeek( FWxFilial("ZCN") + Alltrim(SubStr(xBuffer,61,10)) )
						nValorct := U_xCtbB500()
						cCcDbt   := u_XCTBC500( Alltrim(SubStr(xBuffer,51,04)) )
						TcSqlExec( " UPDATE "+RetSqlName("CTK")+" SET CTK_XLTXCC = '"+ZCN->ZCN_LOTE+"' , CTK_XDLXCC = '"+ZCN->ZCN_DESCLT+"' WHERE CTK_DATA = '"+DtoS(dDatabase)+"' AND CTK_VLR01 = "+Alltrim(Str(nValorct))+" AND CTK_CCD = '"+cCcDbt+"' AND D_E_L_E_T_ = ' ' " )
					Endif
					RestArea(aArea)	// Ricardo Lima-14/02/2019
				Endif

			Endif
			*/

			// Lote Recria RNX2
			If cEmpAnt $ cEmpZCN .or. cFilAnt $ cFilZCN 
				If !Empty(LOTERECRIA)
					ZCN->( dbSetOrder(3) ) // ZCN_FILIAL+ZCN_DESCLT
					If ZCN->( dbSeek( FWxFilial("ZCN") + ALLTRIM(LOTERECRIA) ) )
						nValorct := VALOR
						cCcDbt   := CCD
						If nValorct > 0
							tcSqlExec( " UPDATE " + RetSqlName("CTK") + " SET CTK_XLTXCC = '"+ZCN->ZCN_LOTE+"' , CTK_XDLXCC = '"+ZCN->ZCN_DESCLT+"' WHERE CTK_DATA = '"+DtoS(dDatabase)+"' AND CTK_VLR01 = "+Alltrim(Str(nValorct))+" AND CTK_CCD = '"+cCcDbt+"' AND D_E_L_E_T_ = ' ' " )
						EndIf
					Endif
				Endif

			EndIf
			//

		EndIf

		ft_fSkip()

	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Rodape                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHead
		RodaProva(nHdlPrv,nTotal)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para Lan‡amento Cont bil                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lDigita := IIF(mv_par01==1,.T.,.F.)
		lAglut  := IIF(mv_par02==1,.T.,.F.)
		cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	Endif
	
	FT_FUSE()//Fecha o arquivo
	
	If fRename(MV_PAR03, AllTrim(MV_PAR03)+".CONTABILIZADO") == -1
		Aviso("Renomear arquivo",;
				"Não foi possível renomear o nome do arquivo utilizado para esta contabilização!!! " + CRLF +;
				"Renomeie manualmente para maior segurança do seu controle... " + CRLF + CRLF +;
				"Arquivo: " + AllTrim(Upper(MV_PAR03)),;
				{"Ok"},2)
	Else
		Aviso("Contabilização",;
				"Realizada com sucesso!!! " + CRLF +;
				"O arquivo utilizado para esta contabilização foi renomeado." + CRLF + CRLF +;
				"Arquivo: " + AllTrim(Upper(MV_PAR03))+".CONTABILIZADO",;
				{"Ok"},2)
	EndIf

Return
