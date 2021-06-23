#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "report.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*{Protheus.doc} User Function ADGPE053R
	Relatorio conferencia titulos RH x integrados FIN
	@type  Function
	@author Fernando Macieira
	@since 07/11/2019
	@version 01
	@history Chamado 053139 || OS 054556 || RECURSOS || AMANDA || 8393 || REL. TITULOS APAGAR
*/

User Function ADGPE053R()

	Private cAliasTRB    := ""
	Private cPerg        := "ADGPE053R"
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio conferencia titulos RH x integrados FIN')
	
	u_xPutSx1(cPerg,"01","Dt Vencrea De  "    , "Dt Vencrea De  "    , "Dt Vencrea De  "    , "mv_ch1","D",08,0,0,"G",""   ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"02","Dt Vencrea Ate "    , "Dt Vencrea Ate "    , "Dt Vencrea Ate "    , "mv_ch2","D",08,0,0,"G",""   ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")

	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*{Protheus.doc} Static Function ReportDef
	Relatorio conferencia titulos RH x integrados FIN
	@type  Function
	@author Fernando Macieira
	@since 07/11/2019
	@version 01
	@history Chamado 053139 || OS 054556 || RECURSOS || AMANDA || 8393 || REL. TITULOS APAGAR
*/

Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oFinanceiro
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	
	Local cTitulo := "Titulos RH x Integrados FIN"

	cAliasTRB := "RC1"
	
	oReport := TReport():New(cPerg,OemToAnsi(cTitulo), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )
	
	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oFinanceiro := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
	TRCell():New(oFinanceiro,	"RC1_FILTIT" ,"","Filial"    /*Titulo*/,                        /*Picture*/,TamSX3("E2_FILIAL")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_PREFIX" ,"","Prefixo"  /*Titulo*/,                         /*Picture*/,TamSX3("E2_PREFIXO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_NUMTIT" ,"","N. Título" /*Titulo*/,                        /*Picture*/,TamSX3("E2_NUM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_PARC"   ,"","Parcela"   /*Titulo*/,                        /*Picture*/,TamSX3("E2_PARCELA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_TIPO"   ,"","Tipo"      /*Titulo*/,                        /*Picture*/,TamSX3("E2_TIPO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_FORNEC" ,"","Fornecedor"/*Titulo*/,                        /*Picture*/,TamSX3("E2_FORNECE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_LOJA"   ,"","Loja"      /*Titulo*/,                        /*Picture*/,TamSX3("E2_LOJA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_NOMFOR"  ,"","Nome Fantasia" /*Titulo*/,                    /*Picture*/,TamSX3("E2_NOMFOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_EMISSA" ,"","Emissão"   /*Titulo*/,                        /*Picture*/,TamSX3("E2_EMISSAO")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_VENREA" ,"","Vencto Real (GPE)" /*Titulo*/,                /*Picture*/,TamSX3("E2_VENCREA")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_VENCREA" ,"","Vencto Real (FIN)" /*Titulo*/,                /*Picture*/,TamSX3("E2_VENCREA")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"RC1_VALOR"	 ,"","Valor Título" /*Titulo*/,                     /*Picture*/,TamSX3("E2_VALOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_SALDO"   ,"","Saldo"      /*Titulo*/,                       /*Picture*/,TamSX3("E2_SALDO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	TRCell():New(oFinanceiro,	"CROSSCHECK" ,"","Financeiro?"      /*Titulo*/,                 /*Picture*/,TamSX3("E2_NOMFOR")[1]+20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	

	oBreak1 := TRBreak():New(oReport,oFinanceiro:Cell("E2_NOMFOR"),"S",.F.)
	//oBreak1 := TRBreak():New(oReport,oFinanceiro:Cell("A2_CGC"),"S",.F.)
	
	TRFunction():New(oFinanceiro:Cell("RC1_VALOR"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oFinanceiro:Cell("E2_SALDO"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	
	oBreak1:SetTitle('Totais')
	
	//oReport:SetLineStyle()

Return(oReport)

/*{Protheus.doc} Static Function ReportPrint
	Relatorio conferencia titulos RH x integrados FIN
	@type  Function
	@author Fernando Macieira
	@since 07/11/2019
	@version 01
	@history Chamado 053139 || OS 054556 || RECURSOS || AMANDA || 8393 || REL. TITULOS APAGAR
*/

Static Function ReportPrint(cAliasTRB)

	Local oFinanceiro := oReport:Section(1)
	
	MakeSqlExpr(cPerg)
	
	// Cria e popula TRB para impressão
	fSeleciona()
	
	dbSelectArea("TRB")
	
	oFinanceiro:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oFinanceiro:IncMeter()
		
		oFinanceiro:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oFinanceiro:Cell("RC1_FILTIT") :SetBlock( {|| TRB->RC1_FILTIT} )
		oFinanceiro:Cell("RC1_PREFIX") :SetBlock( {|| TRB->RC1_PREFIX} )
		oFinanceiro:Cell("RC1_NUMTIT") :SetBlock( {|| TRB->RC1_NUMTIT} )
		oFinanceiro:Cell("RC1_PARC")   :SetBlock( {|| TRB->RC1_PARC} )
		oFinanceiro:Cell("RC1_TIPO")   :SetBlock( {|| TRB->RC1_TIPO} )
		oFinanceiro:Cell("RC1_FORNEC") :SetBlock( {|| TRB->RC1_FORNEC} )
		oFinanceiro:Cell("RC1_LOJA")   :SetBlock( {|| TRB->RC1_LOJA} )
		oFinanceiro:Cell("E2_NOMFOR")  :SetBlock( {|| TRB->E2_NOMFOR} )
		oFinanceiro:Cell("RC1_EMISSA") :SetBlock( {|| DtoC(StoD(TRB->RC1_EMISSA))} )
		oFinanceiro:Cell("RC1_VENREA") :SetBlock( {|| DtoC(StoD(TRB->RC1_VENREA))} )
		oFinanceiro:Cell("E2_VENCREA") :SetBlock( {|| DtoC(StoD(TRB->E2_VENCREA))} )
		oFinanceiro:Cell("RC1_VALOR")  :SetBlock( {|| TRB->RC1_VALOR} )
		oFinanceiro:Cell("E2_SALDO")   :SetBlock( {|| TRB->E2_SALDO} )
		
		oFinanceiro:Cell("CROSSCHECK") :SetBlock( {|| Iif(AllTrim(TRB->E2_NUM)=="NULL", "TITULO NAO ENCONTRADO", "OK")} )
	
		oFinanceiro:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oFinanceiro:Finish()
	
	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
Return

/*{Protheus.doc} Static Function fSeleciona
	Cria arquivos de trabalho
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static function fSeleciona()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	BeginSQL Alias "TRB"

		%NoPARSER%
                                                                                                                 
		SELECT RC1_FILTIT, RC1_PREFIX, RC1_NUMTIT, RC1_PARC, RC1_TIPO, RC1_FORNEC, RC1_LOJA, E2_NOMFOR, RC1_EMISSA, RC1_VENREA, E2_VENCREA, RC1_VALOR, E2_SALDO, ISNULL(E2_NUM,'NULL') E2_NUM

		FROM %Table:RC1% RC1 (NOLOCK)
		
		LEFT JOIN %Table:SE2% SE2 (NOLOCK) ON E2_FILIAL=RC1_FILTIT AND E2_PREFIXO=RC1_PREFIX AND E2_NUM=RC1_NUMTIT AND E2_PARCELA=RC1_PARC AND E2_TIPO=RC1_TIPO AND E2_FORNECE=RC1_FORNEC AND E2_LOJA=RC1_LOJA AND SE2.D_E_L_E_T_=''
		
	    WHERE RC1_VENREA BETWEEN %EXP:DtoS(MV_PAR01)% AND %EXP:DtoS(MV_PAR02)% 
		AND RC1.D_E_L_E_T_=''
		
		ORDER BY 6,7,13 DESC
		
	EndSQl

Return