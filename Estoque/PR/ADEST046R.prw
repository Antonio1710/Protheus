#include "protheus.ch"
#include "topconn.ch"
#include "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} User Function ADEST046R
    Relatório Evolução Estoque Adoro (baseado no padrão MATR320)
    @type  Function
    @author FWNM
    @since 11/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 050270 || OS 051560 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || EVOLUCAO ESTOQUE
    @history ticket 97 - Fernando Macieira - 19/01/2021 - Requisição - Relatório Evolução Estoque Vertical
	@history ticket 97 - Fernando Macieira - 04/02/2021 - Parâmetros para saldo terceiros
/*/
User Function ADEST046R()

	Private bValid := Nil
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	Private cAliasTRB := ""
	Private cPerg     := "ADEST046R"
	Private dDtDe, dDtAte, cProdDe, cProdAte, cGrupoDe, cGrupoAte, cTipoDe, cTipoAte, cAlmox, dDtDe3, dDtAte3, nTipo3
	Private oTempTable
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}
	
	u_xPutSx1(cPerg,'01','Data de  ?'       ,'','','mv_ch1','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	u_xPutSx1(cPerg,'02','Data ate ?'       ,'','','mv_ch2','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	u_xPutSx1(cPerg,'03','Produto de  ?'    ,'','','mv_ch3','C',TamSX3("B1_COD")[1],0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR03')
	u_xPutSx1(cPerg,'04','Produto ate ?'    ,'','','mv_ch4','C',TamSX3("B1_COD")[1],0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR04')
    u_xPutSx1(cPerg,'05','Grupo de  ?'      ,'','','mv_ch5','C',TamSX3("B1_GRUPO")[1],0,0,'G',bValid,"SBM",cSXG,cPyme,'MV_PAR05')
	u_xPutSx1(cPerg,'06','Grupo ate ?'      ,'','','mv_ch6','C',TamSX3("B1_GRUPO")[1],0,0,'G',bValid,"SBM",cSXG,cPyme,'MV_PAR06')
    u_xPutSx1(cPerg,'07','Tipo de  ?'       ,'','','mv_ch7','C',TamSX3("B1_TIPO")[1],0,0,'G',bValid,"",cSXG,cPyme,'MV_PAR07')
	u_xPutSx1(cPerg,'08','Tipo ate ?'       ,'','','mv_ch8','C',TamSX3("B1_TIPO")[1],0,0,'G',bValid,"",cSXG,cPyme,'MV_PAR08')
    u_xPutSx1(cPerg,'09','Almoxarifado ?'   ,'','','mv_ch9','C',TamSX3("NNR_CODIGO")[1],0,0,'G',bValid,"NNR",cSXG,cPyme,'MV_PAR09')
	// @history ticket 97 - Fernando Macieira - 04/02/2021 - Parâmetros para saldo terceiros
	u_xPutSx1(cPerg,'10','Dt Terceiro de ?' ,'','','mv_cha','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR10')
	u_xPutSx1(cPerg,'11','Dt Terceiro ate ?','','','mv_chb','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR11')
	u_xPutSx1(cPerg,'12','Tipo Terceiro ?'  ,'','','mv_chc','N',1,0,0,'C',bValid,cF3,cSXG,cPyme,'MV_PAR12')
	//
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oProdutos
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	
	Local cTitulo := "Adoro - Resumo Entradas e Saídas"

	cAliasTRB := "QRY"
	
	oReport := TReport():New("ADEST046R",OemToAnsi(cTitulo), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oProdutos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
	TRCell():New(oProdutos,	"B1_COD"     ,"","Produto"        /*Titulo*/,  /*Picture*/,TamSX3("B1_COD")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"B1_DESC"    ,"","Desc Produto"   /*Titulo*/,  /*Picture*/,TamSX3("B1_DESC")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"B1_TIPO"    ,"","Tipo"           /*Titulo*/,  /*Picture*/,TamSX3("B1_TIPO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"NNR_CODIGO" ,"","Armazém"  	  /*Titulo*/,  /*Picture*/,TamSX3("NNR_CODIGO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"NNR_DESCRI" ,"","Nome Armazém"   /*Titulo*/,  /*Picture*/,TamSX3("NNR_DESCRI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"B9_QINI"    ,"","Saldo Inicial"  /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"COMPRA"     ,"","Compras"        /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"INTERNO"    ,"","Internos"       /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"REQUISICAO" ,"","Requisicoes"    /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"TRANSF"     ,"","Transferencias" /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+11 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"PRODUCAO"   ,"","Producoes"      /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"VENDA"      ,"","NF Saída"       /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"DEVVEN"     ,"","Dev Vendas"     /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"DEVCOM"     ,"","Dev Compras"    /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"B9_QFIM"    ,"","Saldo Final"    /*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProdutos,	"SALTER"     ,"","Saldo Terceiros"/*Titulo*/,  "@E 999,999,999,999,999.9999" /*Picture*/,TamSX3("B9_QINI")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	oBreak1 := TRBreak():New(oReport,oProdutos:Cell("NNR_CODIGO"),"S",.F.)
	
	//TRFunction():New(oProdutos:Cell("B9_QINI"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	
	//oBreak1:SetTitle('Totais Fornecedor')
	
	//oReport:SetLineStyle()

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oProdutos := oReport:Section(1)
	
	MakeSqlExpr(cPerg)
	
	// Pergunte
	dDtDe     := MV_PAR01
	dDtAte    := MV_PAR02
	cProdDe   := MV_PAR03
	cProdAte  := MV_PAR04
	cGrupoDe  := MV_PAR05
	cGrupoAte := MV_PAR06
	cTipoDe   := MV_PAR07
	cTipoAte  := MV_PAR08
	cAlmox    := MV_PAR09
	dDtDe3    := MV_PAR10
	dDtAte3   := MV_PAR11
	nTipo3    := MV_PAR12

	// Cria e popula TRB para impressão
	fSeleciona()
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) ) // 
	
	oProdutos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oProdutos:IncMeter()
		
		oProdutos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oProdutos:Cell("B1_COD")    :SetBlock( {|| TRB->B1_COD} )
		oProdutos:Cell("B1_DESC")   :SetBlock( {|| TRB->B1_DESC} )
		oProdutos:Cell("B1_TIPO")   :SetBlock( {|| TRB->B1_TIPO} )
		oProdutos:Cell("NNR_CODIGO"):SetBlock( {|| TRB->NNR_CODIGO} )
		oProdutos:Cell("NNR_DESCRI"):SetBlock( {|| TRB->NNR_DESCRI} )
		oProdutos:Cell("B9_QINI")   :SetBlock( {|| TRB->B9_QINI} )
		oProdutos:Cell("COMPRA")    :SetBlock( {|| TRB->COMPRA} )
		oProdutos:Cell("INTERNO")   :SetBlock( {|| TRB->INTERNO} )
		oProdutos:Cell("REQUISICAO"):SetBlock( {|| TRB->REQUISICAO} )
		oProdutos:Cell("TRANSF")    :SetBlock( {|| TRB->TRANSF} )
		oProdutos:Cell("PRODUCAO")  :SetBlock( {|| TRB->PRODUCAO} )
		oProdutos:Cell("VENDA")     :SetBlock( {|| TRB->VENDA} )
		oProdutos:Cell("DEVVEN")    :SetBlock( {|| TRB->DEVVEN} )
		oProdutos:Cell("DEVCOM")    :SetBlock( {|| TRB->DEVCOM} )
		oProdutos:Cell("B9_QFIM")   :SetBlock( {|| TRB->B9_QFIM} )
		oProdutos:Cell("SALTER")    :SetBlock( {|| TRB->SALTER} )
	
		oProdutos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oProdutos:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	oTempTable:Delete()  

Return

/*/{Protheus.doc} Static Function fSeleciona
	Cria arquivos de trabalho
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static function fSeleciona()

	Local aCampos := aSalTer := {}
	Local nB9QIni := nCompra := nInterno := nRequisicao := nTransf := nProducao := nVenda := nDevVen := nDevCom := nTerEnt := nTerSai := nB9QFim := nSalTer := 0
	Local cAlmoxDesc := AllTrim(Posicione("NNR",1,FWxFilial("NNR")+cAlmox,"NNR_DESCRI"))

    If Select("TRB") > 0
        TRB->( dbCloseArea() )
    EndIf
		
	// Crio TRB para impressão
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	
	// Arquivo TRB
	aAdd( aCampos, {'B1_COD'     ,TamSX3("B1_COD")[3]     ,TamSX3("B1_COD")[1]    , 0} )
	aAdd( aCampos, {'B1_DESC'    ,TamSX3("B1_DESC")[3]    ,TamSX3("B1_DESC")[1]   , 0} )
	aAdd( aCampos, {'B1_TIPO'    ,TamSX3("B1_TIPO")[3]    ,TamSX3("B1_TIPO")[1]   , 0} )
	aAdd( aCampos, {'NNR_CODIGO' ,TamSX3("NNR_CODIGO")[3] ,TamSX3("NNR_CODIGO")[1], 0} )
	aAdd( aCampos, {'NNR_DESCRI' ,TamSX3("NNR_DESCRI")[3] ,TamSX3("NNR_DESCRI")[1], 0} )
	aAdd( aCampos, {'B9_QINI'    ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'COMPRA'     ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'INTERNO'    ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'REQUISICAO' ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'TRANSF'     ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'PRODUCAO'   ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'VENDA'      ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'DEVVEN'     ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'DEVCOM'     ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'B9_QFIM'    ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )
	aAdd( aCampos, {'SALTER'     ,TamSX3("B9_QINI")[3]    ,TamSX3("B9_QINI")[1]   , 4} )

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"NNR_CODIGO","B1_TIPO","B1_COD"} )
	oTempTable:Create()

	// Query
	QryFiltro()
	ProcRegua( QRY->( LastRec() ) )

	QRY->( dbGoTop() )
	Do While QRY->( !EOF() )	

		IncProc( "Gerando dados... " + QRY->B1_DESC )
			
		// Saldo Inicial
		//nB9QIni := UpB9QIni(QRY->B1_COD)
		nB9QIni := CalcEst(QRY->B1_COD,cAlmox,MV_PAR01+1)[1]

		// Compras 
		nCompra := UpCompra(QRY->B1_COD)

		// Interno
		nInterno := UpInterno(QRY->B1_COD)

		// Requisições
		nRequisicao := UpRequisicao(QRY->B1_COD)
		
		// Transferências
		nTransf := UpTransf(QRY->B1_COD)
		
		// Produção
		nProducao := UpProducao(QRY->B1_COD)
		
		// Venda
		nVenda := UpVenda(QRY->B1_COD)
		
		// Devolução Venda
		nDevVen := UpDevVenda(QRY->B1_COD)
		
		// Devolução Compra
		nDevCom := UpDevCompra(QRY->B1_COD)

		// Saldo Final
		nB9QFim := nB9QINI + nCompra + nInterno + nRequisicao + nTransf + nProducao - nVenda + nDevVen - nDevCom

		// Terceiros Entradas
		//nTerEnt := UpTercEnt(QRY->B1_COD)

		// Terceiros Saída
		//nTerSai := UpTercSai(QRY->B1_COD)

		// Terceiros Saldo
		nSalTer := SalTer(QRY->B1_COD)

		RecLock("TRB", .T.)

			TRB->B1_COD     := QRY->B1_COD
			TRB->B1_DESC    := QRY->B1_DESC
			TRB->B1_TIPO    := QRY->B1_TIPO
			TRB->NNR_CODIGO := cAlmox
			TRB->NNR_DESCRI := cAlmoxDesc
			TRB->B9_QINI    := nB9QIni
			TRB->COMPRA     := nCompra
			TRB->INTERNO    := nInterno
			TRB->REQUISICAO := nRequisicao
			TRB->TRANSF     := nTransf
			TRB->PRODUCAO   := nProducao
			TRB->VENDA      := nVenda
			TRB->DEVVEN     := nDevVen
			TRB->DEVCOM     := nDevCom
			TRB->B9_QFIM    := nB9QFim
			TRB->SALTER     := nSalTer

		TRB->( msUnLock() )
			
		QRY->( dbSkip() )
			
	EndDo
		     
Return

/*/{Protheus.doc} Static Function QryFiltro
	Cria arquivos de trabalho com parametros do usuario
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function QryFiltro()
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	BeginSQL Alias "QRY"

		%NoPARSER%

		SELECT B1_COD, B1_DESC, B1_TIPO, B1_GRUPO

		FROM %Table:SB1% SB1 (NOLOCK)
		
	    WHERE B1_FILIAL = %EXP:FWxFilial("SB1")%
		AND B1_COD BETWEEN %EXP:cProdDe% AND %EXP:cProdAte% 
		AND B1_GRUPO BETWEEN %EXP:cGrupoDe% AND %EXP:cGrupoAte% 
		AND B1_TIPO BETWEEN %EXP:cTipoDe% AND %EXP:cTipoAte% 
		AND SB1.D_E_L_E_T_=''
		
	EndSQl

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpB9QIni(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""
	Local lSB9   := .f.
	Local cDtFiltro := ""
	Local nAno := nMes := 0

	nAno := Year(dDtDe)
	nMes := Month(dDtDe)

	If nMes == 12
		nMes := nMes--
		nAno := nAno--
	Else
		nMes := nMes--
	EndIf

	cDtFiltro := AllTrim(Str(nAno)) + AllTrim(StrZero(nMes,2))
		
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT TOP 1 ISNULL(B9_QINI,0) B9_QINI
	cQuery += " FROM " + RetSqlName("SB9") + " SB9 (NOLOCK)
	cQuery += " WHERE B9_FILIAL='"+FWxFilial("SB9")+"' 
	cQuery += " AND B9_COD='"+cB1_COD+"' 
	cQuery += " AND B9_LOCAL='"+cAlmox+"' 
	cQuery += " AND B9_DATA LIKE '"+cDtFiltro+"%'
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ORDER BY B9_DATA DESC 

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("B9_QINI")
	tcSetField("Work", "B9_QINI", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		lSB9 := .T.
		nVlr := Work->B9_QINI
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	If !lSB9

		cQuery := " SELECT TOP 1 ISNULL(B9_QINI,0) B9_QINI
		cQuery += " FROM " + RetSqlName("SB9") + " SB9 (NOLOCK)
		cQuery += " WHERE B9_FILIAL='"+FWxFilial("SB9")+"' 
		cQuery += " AND B9_COD='"+cB1_COD+"' 
		cQuery += " AND B9_LOCAL='"+cAlmox+"' 
		cQuery += " AND D_E_L_E_T_=''
		cQuery += " ORDER BY B9_DATA DESC 

		tcQuery cQuery New Alias "Work"

		aTamSX3	:= TamSX3("B9_QINI")
		tcSetField("Work", "B9_QINI", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		Work->( dbGoTop() )

		If Work->( !EOF() )
			nVlr := Work->B9_QINI
		EndIf

	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpCompra(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(D1_QUANT),0) D1_QUANT
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+ "' AND F4_CODIGO=D1_TES AND F4_ESTOQUE='S' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE D1_FILIAL='"+FWxFilial("SD1")+"' 
	cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D1_COD='"+cB1_COD+"' 
	cQuery += " AND D1_LOCAL='"+cAlmox+"' 
	cQuery += " AND D1_TIPO<>'D'
	cQuery += " AND SD1.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D1_QUANT")
	tcSetField("Work", "D1_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D1_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	https://tdn.totvs.com.br/pages/releaseview.action?pageId=374314575
	PEST01017 - O que significa o campo Tipo RE/DE tabela SD3? (D3_CF, RE0, RE1, RE2, RE3, RE4, RE5, RE6, RE7, RE8, RE9, REA)
	O código gravado no conteúdo do campo D3_CF identifica o tipo de movimentação interna registrada no estoque. Sendo que, representam:
	RE? = Requisição (Saída de Produto do Armazém)
	DE? = Devolução (Entrada de Produto no Armazém)
	PR? = Produção (Entrada de Produto no Armazém)
	Em que ? pode ser:
	E0  = Operação Manual (custo médio no estoque)                   - Manual de Material Apropriação direta
	E1  = Operação Automática (custo médio no estoque)               - Automático de Material Apropriação direta
	E2  = Operação Automática (apropriação interna)                  - Automático de apropriação indireta
	E3  = Operação Manual (Apropriação Interna)                      - Manual de material apropriação indireta
	E4  = Transferência (custo médio no estoque por local físico)    - Transferência em geral
	E5  = Requisição para OP na NF (usa o custo do documento fiscal) - Apropriação direta entrada na OP
	E6  = Requisição Valorizada                                      - Manual de material valorizado
	E7  = Transferência Múltipla (desmontagem de produtos)           - Desmontagem produto
	E8  = Essa tipo de movimentação foi descontinuado. Integração com NF de Produtos Importados (SIGAEIC até a versão Advanced Protheus 6.09)
	E9  = Movimentos para OP sem agreg custo
	A   = Movimento Interno REA / DEA Gerado pela rotina MATA338     - Movimentos de Reavaliaçao de Custo
	PR0 = Produção manual
	PR1 = Produção automática
	ER0 = Estorno de produção manual.
	ER1 = Estorno de automática.
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpInterno(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT SUM(D3_QUANT) D3_QUANT FROM ( 
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0) D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'DE%' 
	cQuery += " AND D3_CF NOT IN ('DE4','DE7') 
	cQuery += " AND D3_OP=''
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " UNION ALL
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0)*-1 D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'RE%' 
	cQuery += " AND D3_CF NOT IN ('RE4','RE7') 
	cQuery += " AND D3_OP=''
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ) INTERNO

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D3_QUANT")
	tcSetField("Work", "D3_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D3_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	https://tdn.totvs.com.br/pages/releaseview.action?pageId=374314575
	PEST01017 - O que significa o campo Tipo RE/DE tabela SD3? (D3_CF, RE0, RE1, RE2, RE3, RE4, RE5, RE6, RE7, RE8, RE9, REA)
	O código gravado no conteúdo do campo D3_CF identifica o tipo de movimentação interna registrada no estoque. Sendo que, representam:
	RE? = Requisição (Saída de Produto do Armazém)
	DE? = Devolução (Entrada de Produto no Armazém)
	PR? = Produção (Entrada de Produto no Armazém)
	Em que ? pode ser:
	E0  = Operação Manual (custo médio no estoque)                   - Manual de Material Apropriação direta
	E1  = Operação Automática (custo médio no estoque)               - Automático de Material Apropriação direta
	E2  = Operação Automática (apropriação interna)                  - Automático de apropriação indireta
	E3  = Operação Manual (Apropriação Interna)                      - Manual de material apropriação indireta
	E4  = Transferência (custo médio no estoque por local físico)    - Transferência em geral
	E5  = Requisição para OP na NF (usa o custo do documento fiscal) - Apropriação direta entrada na OP
	E6  = Requisição Valorizada                                      - Manual de material valorizado
	E7  = Transferência Múltipla (desmontagem de produtos)           - Desmontagem produto
	E8  = Essa tipo de movimentação foi descontinuado. Integração com NF de Produtos Importados (SIGAEIC até a versão Advanced Protheus 6.09)
	E9  = Movimentos para OP sem agreg custo
	A   = Movimento Interno REA / DEA Gerado pela rotina MATA338     - Movimentos de Reavaliaçao de Custo
	PR0 = Produção manual
	PR1 = Produção automática
	ER0 = Estorno de produção manual.
	ER1 = Estorno de automática.
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpRequisicao(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT SUM(D3_QUANT) D3_QUANT FROM ( 
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0) D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'DE%' 
	cQuery += " AND D3_CF NOT IN ('DE4','DE7') 
	cQuery += " AND D3_OP<>''
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " UNION ALL
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0)*-1 D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'RE%' 
	cQuery += " AND D3_CF NOT IN ('RE4','RE7') 
	cQuery += " AND D3_OP<>''
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ) REQUISICAO

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D3_QUANT")
	tcSetField("Work", "D3_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D3_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	https://tdn.totvs.com.br/pages/releaseview.action?pageId=374314575
	PEST01017 - O que significa o campo Tipo RE/DE tabela SD3? (D3_CF, RE0, RE1, RE2, RE3, RE4, RE5, RE6, RE7, RE8, RE9, REA)
	O código gravado no conteúdo do campo D3_CF identifica o tipo de movimentação interna registrada no estoque. Sendo que, representam:
	RE? = Requisição (Saída de Produto do Armazém)
	DE? = Devolução (Entrada de Produto no Armazém)
	PR? = Produção (Entrada de Produto no Armazém)
	Em que ? pode ser:
	E0  = Operação Manual (custo médio no estoque)                   - Manual de Material Apropriação direta
	E1  = Operação Automática (custo médio no estoque)               - Automático de Material Apropriação direta
	E2  = Operação Automática (apropriação interna)                  - Automático de apropriação indireta
	E3  = Operação Manual (Apropriação Interna)                      - Manual de material apropriação indireta
	E4  = Transferência (custo médio no estoque por local físico)    - Transferência em geral
	E5  = Requisição para OP na NF (usa o custo do documento fiscal) - Apropriação direta entrada na OP
	E6  = Requisição Valorizada                                      - Manual de material valorizado
	E7  = Transferência Múltipla (desmontagem de produtos)           - Desmontagem produto
	E8  = Essa tipo de movimentação foi descontinuado. Integração com NF de Produtos Importados (SIGAEIC até a versão Advanced Protheus 6.09)
	E9  = Movimentos para OP sem agreg custo
	A   = Movimento Interno REA / DEA Gerado pela rotina MATA338     - Movimentos de Reavaliaçao de Custo
	PR0 = Produção manual
	PR1 = Produção automática
	ER0 = Estorno de produção manual.
	ER1 = Estorno de automática.
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpTransf(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT SUM(D3_QUANT) D3_QUANT FROM ( 
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0) D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF IN ('DE4','DE7') 
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " UNION ALL
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0)*-1 D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF IN ('RE4','RE7')
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ) TRANSF

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D3_QUANT")
	tcSetField("Work", "D3_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D3_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	https://tdn.totvs.com.br/pages/releaseview.action?pageId=374314575
	PEST01017 - O que significa o campo Tipo RE/DE tabela SD3? (D3_CF, RE0, RE1, RE2, RE3, RE4, RE5, RE6, RE7, RE8, RE9, REA)
	O código gravado no conteúdo do campo D3_CF identifica o tipo de movimentação interna registrada no estoque. Sendo que, representam:
	RE? = Requisição (Saída de Produto do Armazém)
	DE? = Devolução (Entrada de Produto no Armazém)
	PR? = Produção (Entrada de Produto no Armazém)
	Em que ? pode ser:
	E0  = Operação Manual (custo médio no estoque)                   - Manual de Material Apropriação direta
	E1  = Operação Automática (custo médio no estoque)               - Automático de Material Apropriação direta
	E2  = Operação Automática (apropriação interna)                  - Automático de apropriação indireta
	E3  = Operação Manual (Apropriação Interna)                      - Manual de material apropriação indireta
	E4  = Transferência (custo médio no estoque por local físico)    - Transferência em geral
	E5  = Requisição para OP na NF (usa o custo do documento fiscal) - Apropriação direta entrada na OP
	E6  = Requisição Valorizada                                      - Manual de material valorizado
	E7  = Transferência Múltipla (desmontagem de produtos)           - Desmontagem produto
	E8  = Essa tipo de movimentação foi descontinuado. Integração com NF de Produtos Importados (SIGAEIC até a versão Advanced Protheus 6.09)
	E9  = Movimentos para OP sem agreg custo
	A   = Movimento Interno REA / DEA Gerado pela rotina MATA338     - Movimentos de Reavaliaçao de Custo
	PR0 = Produção manual
	PR1 = Produção automática
	ER0 = Estorno de produção manual.
	ER1 = Estorno de automática.
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpProducao(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT SUM(D3_QUANT) D3_QUANT FROM ( 
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0) D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'PR%' 
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " UNION ALL
	cQuery += " SELECT ISNULL(SUM(D3_QUANT),0)*-1 D3_QUANT
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)
	cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D3_COD='"+cB1_COD+"' 
	cQuery += " AND D3_LOCAL='"+cAlmox+"'
	cQuery += " AND D3_CF LIKE 'ER%' 
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ) PRODUCAO

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D3_QUANT")
	tcSetField("Work", "D3_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D3_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpVenda(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(D2_QUANT),0) D2_QUANT
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+ "' AND F4_CODIGO=D2_TES AND F4_ESTOQUE='S' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE D2_FILIAL='"+FWxFilial("SD2")+"' 
	cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D2_COD='"+cB1_COD+"' 
	cQuery += " AND D2_TIPO<>'D'
	cQuery += " AND D2_LOCAL='"+cAlmox+"'
	cQuery += " AND SD2.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D2_QUANT")
	tcSetField("Work", "D2_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D2_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpDevVenda(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(D1_QUANT),0) D1_QUANT
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+ "' AND F4_CODIGO=D1_TES AND F4_ESTOQUE='S' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE D1_FILIAL='"+FWxFilial("SD1")+"' 
	cQuery += " AND D1_DTDIGIT BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D1_COD='"+cB1_COD+"' 
	cQuery += " AND D1_LOCAL='"+cAlmox+"' 
	cQuery += " AND D1_TIPO='D'
	cQuery += " AND SD1.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D1_QUANT")
	tcSetField("Work", "D1_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D1_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpDevCompra(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(D2_QUANT),0) D2_QUANT
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON F4_FILIAL='"+FWxFilial("SF4")+ "' AND F4_CODIGO=D2_TES AND F4_ESTOQUE='S' AND SF4.D_E_L_E_T_=''
	cQuery += " WHERE D2_FILIAL='"+FWxFilial("SD2")+"' 
	cQuery += " AND D2_EMISSAO BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND D2_COD='"+cB1_COD+"' 
	cQuery += " AND D2_LOCAL='"+cAlmox+"' 
	cQuery += " AND D2_TIPO='D'
	cQuery += " AND SD2.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("D2_QUANT")
	tcSetField("Work", "D2_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->D2_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpTercEnt(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(B6_QUANT),0) B6_QUANT
	cQuery += " FROM " + RetSqlName("SB6") + " SB6 (NOLOCK)
	cQuery += " WHERE B6_FILIAL='"+FWxFilial("SB6")+"' 
	cQuery += " AND B6_DTDIGIT BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND B6_PRODUTO='"+cB1_COD+"' 
	cQuery += " AND B6_LOCAL='"+cAlmox+"' 
	cQuery += " AND B6_PODER3='D'
	cQuery += " AND SB6.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("B6_QUANT")
	tcSetField("Work", "B6_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->B6_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpTercSai(cB1_COD)

	Local nVlr   := 0
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ISNULL(SUM(B6_QUANT),0) B6_QUANT
	cQuery += " FROM " + RetSqlName("SB6") + " SB6 (NOLOCK)
	cQuery += " WHERE B6_FILIAL='"+FWxFilial("SB6")+"' 
	cQuery += " AND B6_DTDIGIT BETWEEN '"+DtoS(dDtDe)+"' AND '"+DtoS(dDtAte)+"' 
	cQuery += " AND B6_PRODUTO='"+cB1_COD+"' 
	cQuery += " AND B6_LOCAL='"+cAlmox+"' 
	cQuery += " AND B6_PODER3='R'
	cQuery += " AND SB6.D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	aTamSX3	:= TamSX3("B6_QUANT")
	tcSetField("Work", "B6_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	Work->( dbGoTop() )

	If Work->( !EOF() )
		nVlr := Work->B6_QUANT
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return nVlr

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 12/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SalTer(cB1_COD)

	Local aSalTer  := {}
	Local nSalTer  := 0
	Local aAreaAtu := GetArea() 

	cAliasSB6 := GetNextAlias()
	aStrucSB6 := SB6->(dbStruct())

	cQuery	   := " SELECT SB6.*, SB6.R_E_C_N_O_ AS RECNO, SF4.F4_PODER3 "
	cQuery	   += " FROM " + RetSqlName("SB6") + " SB6 (NOLOCK) "

	cQuery	   += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON ( SB1.B1_FILIAL = '"   + FWxFilial("SB1") + "' "
	cQuery	   += " 			AND SB1.B1_COD = SB6.B6_PRODUTO  ) "

	cQuery	   += " 	INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON ( SF4.F4_FILIAL = '"   + FWxFilial("SF4") + "' "
	cQuery	   += " 			AND SF4.F4_CODIGO = SB6.B6_TES AND SF4.F4_PODER3 <> 'D' AND SF4.D_E_L_E_T_ = ' ' ) "

	cQuery    += " WHERE SB6.B6_FILIAL = '"   + FWxFilial("SB6") + "' "
//	cQuery    += " AND ((SB6.B6_TPCF = 'C' AND B6_CLIFOR >= '" + mv_par01 + "' AND B6_CLIFOR <= '" + mv_par02 + "' ) "
//	cQuery    += " OR  ( SB6.B6_TPCF = 'F' AND B6_CLIFOR >= '" + mv_par03 + "' AND B6_CLIFOR <= '" + mv_par04 + "' ))"
	cQuery    += " AND SB6.B6_PRODUTO >= '" + cB1_COD + "' "
	cQuery    += " AND SB6.B6_PRODUTO <= '" + cB1_COD + "' "
	cQuery    += " AND SB6.B6_DTDIGIT >= '"+ DTOS(dDtDe3) +"' AND SB6.B6_DTDIGIT <= '" + DTOS(dDtAte3) + "' "

	// @history ticket 97 - Fernando Macieira - 04/02/2021 - Parâmetros para saldo terceiros
	If mv_par12 == 1
		cQuery  += " AND SB6.B6_TIPO = 'D' "
	ElseIf mv_par12 == 2
		cQuery  += " AND SB6.B6_TIPO = 'E' "
	EndIf
	//

	cQuery   += " AND SB6.B6_QUANT <> 0 AND SB6.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
	cQuery   += " ORDER BY B6_FILIAL,B6_DTDIGIT,B6_PRODUTO,B6_CLIFOR,B6_LOJA "

	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSB6,.F.,.T.)

	dbSelectArea(cAliasSB6)
	For nX := 1 To Len(aStrucSB6)
		If ( aStrucSB6[nX][2] <> "C" .And. FieldPos(aStrucSB6[nX][1])<>0 )
			TcSetField(cAliasSB6,aStrucSB6[nX][1],aStrucSB6[nX][2],aStrucSB6[nX][3],aStrucSB6[nX][4])
		EndIf
	Next nX

	Do While (cAliasSB6)->( !EOF() )

		aSalTer  := (cAliasSB6)->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,dDtDe3,dDtAte3))
		nSalTer  += aSalTer[1]

		(cAliasSB6)->( dbSkip() )

	EndDo

Return nSalTer
