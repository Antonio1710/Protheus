#include "protheus.ch"
#include "topconn.ch"
#include "REPORT.CH"

#DEFINE	 cEol        CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA200ENC ºAutor  ³Fernando Macieira   º Data ³ 11/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada executado no encerramento do projeto.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 049774 || OS 051078 || ENGENHARIA || SILVANA || 8406 ||    º±±
±±º          ³ || PROJETO ENCERRADO - FWNM - 26/06/2019                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PMA200ENC()

	Local lPrjOk   := .t.
	Local lEncOK   := PARAMIXB[1]
	Local cFaseEnc := AllTrim(GetMV("MV_#FASENC",,"04")) 
	Local cFaseAtu := AF8->AF8_FASE
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E. encerramento do projeto')

	If lEncOK
		If AllTrim(M->AF8_FASE) == cFaseEnc
			
			lPrjOk := ChkMovOpen()
		
			If !lPrjOk
				M->AF8_FASE   := cFaseAtu
				M->AF8_ENCPRJ := "2" // Aberto			
			
				If msgYesNo("Deseja visualizar os movimentos em aberto deste projeto n. " + AF8->AF8_PROJET + " que deseja encerrar?")
					ListMovOpen()
				EndIf
			
			EndIf
		
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMA200ENC ºAutor  ³Microsiga           º Data ³  06/26/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkMovOpen()

	Local lRet   := .t.
	Local cQuery := ""
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	// Checo pedidos de compras em aberto  
	cQuery := " SELECT COUNT(1) TT "
	cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK) "
	cQuery += " WHERE C7_FILIAL BETWEEN '' AND 'z' "
	cQuery += " AND ( (C7_QUANT-C7_QUJE) > 0 ) "	
	cQuery += " AND C7_RESIDUO='' "
	cQuery += " AND C7_ENCER<>'E' "
	cQuery += " AND C7_PROJETO='"+AF8->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcquery cquery new alias "Work"
	
	Work->( dbGoTop() )

	If Work->TT >= 1
		lRet := .f.
		msgAlert("[PMA200ENC-01] - Encerramento do projeto não permitido! Existem pedidos de compras em aberto para este projeto... Elimine resíduos ou alinhe com o departamento de compras sobre as notas fiscais pendentes!")
	EndIf
	
	// Checo notas fiscais em aberto
	If lRet                         

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) "
		cQuery += " WHERE D1_FILIAL BETWEEN '' AND 'z' "
		cQuery += " AND D1_TES='' "
		cQuery += " AND D1_PROJETO='"+AF8->AF8_PROJET+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcquery cquery new alias "Work"
		
		Work->( dbGoTop() )
		If Work->TT >= 1
			lRet := .f.
			msgAlert("[PMA200ENC-02] - Encerramento do projeto não permitido! Existem notas fiscais pendentes de classificação para este projeto... Classifique-as ou alinhe com o departamento fiscal sobre estas pendências!")
		EndIf
	
	EndIf	
	
	// Checo solicitacoes ao armazem em aberto
	If lRet                         

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM " + RetSqlName("SCP") + " (NOLOCK) "
		cQuery += " WHERE CP_FILIAL BETWEEN '' AND 'z' "
		cQuery += " AND CP_STATUS<>'E' "
		cQuery += " AND CP_CONPRJ='"+AF8->AF8_PROJET+"' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcquery cquery new alias "Work"
		
		Work->( dbGoTop() )
		If Work->TT >= 1
			lRet := .f.
			msgAlert("[PMA200ENC-03] - Encerramento do projeto não permitido! Existem solicitações ao armazém pendentes para este projeto... Encerre-as ou alinhe com o almoxarifado sobre estas pendências!")
		EndIf
	
	EndIf	

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADSIG009P ºAutor  ³Microsiga           º Data ³  11/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ListMovOpen()

	Private cAliasTRB := ""
	Private cDescrRel := "Projetos Investimentos - Listagem movimentos em aberto"
	
	oReport := ReportDef(@cAliasTRB)
	oReport:oPage:lPageTotal := .t.
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADSIG009P ºAutor  ³Microsiga           º Data ³  11/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef(cAliasTRB)

	Local oReport
	Local oProjeto
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	Local cRotina := "PMA200ENC" 
	Local cTitulo := cDescrRel
	
	cAliasTRB := "QRY"
	
	oReport := TReport():New(cRotina,OemToAnsi(cDescrRel), , ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+cEol+;
	OemToAnsi("")+cEol+;
	OemToAnsi("") )
	
	
	oReport:SetLandscape() // sugere formato paisagem
	//oReport:nFontBody := 9.5
	//oReport:lBold := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do relatorio															  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProjeto := TRSection():New(oReport, OemToAnsi(cTitulo),{"QRY"}, aOrdem /*{}*/, .F., .F.)
		
	TRCell():New(oProjeto,"IDTAB"   ,"","Tabela"         /*Titulo*/,/*Picture*/ ,04  /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"PROJETO" ,"","Projeto"        /*Titulo*/,/*Picture*/ ,15 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"FORNECE" ,"","Fornecedor"     /*Titulo*/,/*Picture*/ ,10 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"LOJA"    ,"","Loja" 	         /*Titulo*/,/*Picture*/ ,04 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"FANTASIA","","Nome Fantasia"  /*Titulo*/,/*Picture*/ ,30 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"FILIAL"  ,"","Filial"    	 /*Titulo*/,/*Picture*/ ,04  /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"NUMERO"  ,"","Numero" 	     /*Titulo*/,/*Picture*/ ,15 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"ITEM"	,"","Item"	         /*Titulo*/,/*Picture*/ ,08 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_QTDORI }*/)
	TRCell():New(oProjeto,"SERIE"   ,"","Serie" 	     /*Titulo*/,/*Picture*/ ,06 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"PRODUTO" ,"","Produto"        /*Titulo*/,/*Picture*/ ,20 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"DESCRI"  ,"","Descricao"      /*Titulo*/,/*Picture*/ ,40 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)

	DEFINE BREAK oBreak2 OF oProjeto When {|| QRY->IDTAB } TOTAL IN LINE // para pular linha a cada tabela

	//oBreak1 := TRBreak():New(oProjeto,oProjeto:Cell("ZFJ_IDTAB"),"S",.F.)
	//oBreak1:SetTitle('Total Geral')

	//TRFunction():New(oProjeto:Cell("ZFJ_PROVEN"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)
	//TRFunction():New(oProjeto:Cell("ZFJ_DESCON"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)
	//TRFunction():New(oProjeto:Cell("ZFJ_LIQUID"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)

Return (oReport) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADSIG009P ºAutor  ³Microsiga           º Data ³  11/05/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(cAliasTRB)

	Local cQuery    := ""
	Local oProjeto  := oReport:Section(1)

	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia Query 																	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// pedidos de compras em aberto  
	cQuery := " SELECT 'SC7' IDTAB, C7_PROJETO PROJETO, C7_FILIAL FILIAL, C7_NUM NUMERO, '' SERIE, C7_FORNECE FORNECE, C7_LOJA LOJA, C7_ITEM ITEM, C7_PRODUTO PRODUTO, C7_DESCRI DESCRI, '' FANTASIA "
	cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK) "
	cQuery += " WHERE C7_FILIAL BETWEEN '' AND 'z' "
	cQuery += " AND ( (C7_QUANT-C7_QUJE) > 0 ) "	
	cQuery += " AND C7_RESIDUO='' "
	cQuery += " AND C7_ENCER<>'E' "
	cQuery += " AND C7_PROJETO='"+AF8->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_='' "

	cQuery += " UNION ALL "

	// notas fiscais em aberto
	cQuery += " SELECT 'SD1' IDTAB, D1_PROJETO PROJETO, D1_FILIAL FILIAL, D1_DOC NUMERO, D1_SERIE SERIE, D1_FORNECE FORNECE, D1_LOJA LOJA, D1_ITEM ITEM, D1_COD PRODUTO, '' DESCRI, '' FANTASIA "
	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) "
	cQuery += " WHERE D1_FILIAL BETWEEN '' AND 'z' "
	cQuery += " AND D1_TES='' "
	cQuery += " AND D1_PROJETO='"+AF8->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_='' "

	cQuery += " UNION ALL "

	// solicitacoes ao armazem em aberto
	cQuery += " SELECT 'SCP' IDTAB, CP_CONPRJ PROJETO, CP_FILIAL FILIAL, CP_NUM NUMERO, '' SERIE, '' FORNECE, '' LOJA, CP_ITEM ITEM, CP_PRODUTO PRODUTO, CP_DESCRI DESCRI, '' FANTASIA "
	cQuery += " FROM " + RetSqlName("SCP") + " (NOLOCK) "
	cQuery += " WHERE CP_FILIAL BETWEEN '' AND 'z' "
	cQuery += " AND CP_STATUS<>'E' "
	cQuery += " AND CP_CONPRJ='"+AF8->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_='' "

	cQuery += " ORDER BY 1, 3, 6, 7, 4, 8 "
	
	TcQuery cQuery New Alias "QRY"
	
	QRY->( dbGoTop() )
	aEval( ( "ZFJ" )->( dbStruct() ) ,{ |x| If( x[2] != "C" , tcSetField( ( "QRY" ) , AllTrim( x[1] ), x[2] , x[3] , x[4] ) , Nil ) } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva Query																		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("QRY")
	
	QRY->( dbGoTop() )
	Do While QRY->( !EOF() )
		
		oReport:SetMeter(QRY->(LastRec()))
		
		oProjeto:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//impressao propriamente dita....
		oProjeto:Cell("IDTAB")	  :SetBlock( {|| QRY->IDTAB   } )
		oProjeto:Cell("PROJETO")  :SetBlock( {|| QRY->PROJETO } )
		oProjeto:Cell("FILIAL")   :SetBlock( {|| QRY->FILIAL  } )
		oProjeto:Cell("NUMERO")	  :SetBlock( {|| QRY->NUMERO  } )
		oProjeto:Cell("SERIE")	  :SetBlock( {|| QRY->SERIE   } )
		oProjeto:Cell("FORNECE")  :SetBlock( {|| QRY->FORNECE } )
		oProjeto:Cell("LOJA")  	  :SetBlock( {|| QRY->LOJA	  } )
		oProjeto:Cell("PRODUTO")  :SetBlock( {|| QRY->PRODUTO } )
		oProjeto:Cell("DESCRI")   :SetBlock( {|| Posicione("SB1",1,FWxFilial("SB1")+QRY->PRODUTO,"B1_DESC") } )
		oProjeto:Cell("FANTASIA") :SetBlock( {|| Posicione("SA2",1,FWxFilial("SA2")+QRY->FORNECE+QRY->LOJA,"A2_NREDUZ") } )
		oProjeto:Cell("ITEM")  	  :SetBlock( {|| QRY->ITEM	  } )
	
		oProjeto:PrintLine()
		oReport:IncMeter()
		
		QRY->( dbSkip() )
	
	Enddo
	
	oProjeto:Finish()
	
	QRY->( dbCloseArea() )

Return