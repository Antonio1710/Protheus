#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*{Protheus.doc} User Function ADFIN078R
	Relatorio financeiro - Adiantamentos x NF
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 048584 - FWNM            - 29/08/2019 - Regra para nao listar notas se o fornecedor nao possuir adiantamentos  
	@history Chamado 052131 - FWNM            - 09/10/2019 - Listar CNPJ
	@history Chamado 053203 - FWNM            - 06/11/2019 - Duplicidades de titulos
*/

User Function ADFIN078R()

	Private cAliasTRB    := ""
	Private cPerg        := "ADFIN078R"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio financeiro - Adiantamentos x NF')
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}
	
	u_xPutSx1(cPerg,"01","Filial de      "    , "Filial de      "    , "Filial de      "    , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"02","Filial ate     "    , "Filial ate     "    , "Filial ate     "    , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"03","Dt Emissao De  "    , "Dt Emissao De  "    , "Dt Emissao De  "    , "mv_ch3","D",08,0,0,"G",""   ,"","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"04","Dt Emissao Ate "    , "Dt Emissao Ate "    , "Dt Emissao Ate "    , "mv_ch4","D",08,0,0,"G",""   ,"","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"05","Dt Vencrea De  "    , "Dt Vencto De   "    , "Dt Vencto De   "    , "mv_ch5","D",08,0,0,"G",""   ,"","","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"06","Dt Vencrea Ate "    , "Dt Vencto Ate  "    , "Dt Vencto Ate  "    , "mv_ch6","D",08,0,0,"G",""   ,"","","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"07","Fornecedor De  "	  , "Fornecedor     "    , "Fornecedor     "    , "mv_ch7","C",6 ,0,0,"G","","SA2","","","mv_par07",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"08","Loja De        "	  , "Loja           "    , "Loja           "    , "mv_ch8","C",2 ,0,0,"G",""   ,"","","","mv_par08",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"09","Fornecedor Ate "	  , "Fornecedor     "    , "Fornecedor     "    , "mv_ch9","C",6 ,0,0,"G","","SA2","","","mv_par09",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"10","Loja Ate       "	  , "Loja           "    , "Loja           "    , "mv_cha","C",2 ,0,0,"G",""   ,"","","","mv_par10",""      ,"","","","","","","","","","","","","","","")

	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*{Protheus.doc} Static Function ReportDef
	Relatorio financeiro - Adiantamentos x NF
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oFinanceiro
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	
	Local cTitulo := "Fornecedores - Adiantamentos x Notas"

	cAliasTRB := "SE2"
	
	oReport := TReport():New("ADFIN078R",OemToAnsi(cTitulo), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )
	
	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oFinanceiro := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
	TRCell():New(oFinanceiro,	"E2_FILIAL"  ,"","Filial"    /*Titulo*/,                        /*Picture*/,TamSX3("E2_FILIAL")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_PREFIXO" ,"","Prefixo"  /*Titulo*/,                        /*Picture*/,TamSX3("E2_PREFIXO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_NUM"     ,"","N. Título" /*Titulo*/,                        /*Picture*/,TamSX3("E2_NUM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_PARCELA" ,"","Parcela"   /*Titulo*/,                       /*Picture*/,TamSX3("E2_PARCELA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_TIPO"    ,"","Tipo"      /*Titulo*/,                        /*Picture*/,TamSX3("E2_TIPO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_NATUREZ" ,"","Natureza"  /*Titulo*/,                        /*Picture*/,TamSX3("E2_NATUREZ")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"A2_CGC"     ,"","CNPJ Tronco"/*Titulo*/,                        /*Picture*/,TamSX3("A2_CGC")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_FORNECE" ,"","Fornecedor"/*Titulo*/,                        /*Picture*/,TamSX3("E2_FORNECE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_LOJA"    ,"","Loja"      /*Titulo*/,                        /*Picture*/,TamSX3("E2_LOJA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_NOMFOR"  ,"","Nome Fantasia" /*Titulo*/,                    /*Picture*/,TamSX3("E2_NOMFOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_EMISSAO" ,"","Emissão"   /*Titulo*/,                        /*Picture*/,TamSX3("E2_EMISSAO")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_VENCREA" ,"","Vencto Real" /*Titulo*/,                        /*Picture*/,TamSX3("E2_VENCREA")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"DIAS"       ,"","Dias Aberto" /*Titulo*/,                        /*Picture*/,05 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_VALOR"	 ,"","Valor Título" /*Titulo*/,                        /*Picture*/,TamSX3("E2_VALOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oFinanceiro,	"E2_SALDO"   ,"","Saldo"      /*Titulo*/,                        /*Picture*/,TamSX3("E2_SALDO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	//oBreak1 := TRBreak():New(oReport,oFinanceiro:Cell("E2_NOMFOR"),"S",.F.)
	oBreak1 := TRBreak():New(oReport,oFinanceiro:Cell("A2_CGC"),"S",.F.)
	
	TRFunction():New(oFinanceiro:Cell("E2_VALOR"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oFinanceiro:Cell("E2_SALDO"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	
	oBreak1:SetTitle('Totais Fornecedor')
	
	//oReport:SetLineStyle()

Return(oReport)

/*{Protheus.doc} Static Function ReportPrint
	Relatorio financeiro - Adiantamentos x NF
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static Function ReportPrint(cAliasTRB)

	Local oFinanceiro := oReport:Section(1)
	
	MakeSqlExpr(cPerg)
	
	// Cria e popula TRB para impressão
	fSeleciona()
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) ) // A2_CGC+E2_FORNECE+E2_LOJA 
	
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
		oFinanceiro:Cell("E2_FILIAL")  :SetBlock( {|| TRB->E2_FILIAL} )
		oFinanceiro:Cell("E2_PREFIXO") :SetBlock( {|| TRB->E2_PREFIXO} )
		oFinanceiro:Cell("E2_NUM")     :SetBlock( {|| TRB->E2_NUM} )
		oFinanceiro:Cell("E2_PARCELA") :SetBlock( {|| TRB->E2_PARCELA} )
		oFinanceiro:Cell("E2_TIPO")    :SetBlock( {|| TRB->E2_TIPO} )
		oFinanceiro:Cell("E2_NATUREZ") :SetBlock( {|| TRB->E2_NATUREZ} )
		oFinanceiro:Cell("A2_CGC")     :SetBlock( {|| TRB->A2_CGC} )
		oFinanceiro:Cell("E2_FORNECE") :SetBlock( {|| TRB->E2_FORNECE} )
		oFinanceiro:Cell("E2_LOJA")    :SetBlock( {|| TRB->E2_LOJA} )
		oFinanceiro:Cell("E2_NOMFOR")  :SetBlock( {|| TRB->E2_NOMFOR} )
		oFinanceiro:Cell("E2_EMISSAO") :SetBlock( {|| TRB->E2_EMISSAO} )
		oFinanceiro:Cell("E2_VENCREA") :SetBlock( {|| TRB->E2_VENCREA} )
		oFinanceiro:Cell("DIAS")       :SetBlock( {|| TRB->DIAS} )
		oFinanceiro:Cell("E2_VALOR")   :SetBlock( {|| TRB->E2_VALOR} )
		oFinanceiro:Cell("E2_SALDO")   :SetBlock( {|| TRB->E2_SALDO} )
	
		oFinanceiro:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oFinanceiro:Finish()
	
	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("SE2ADI") > 0
		SE2ADI->( dbCloseArea() )
	EndIf
	
	If Select("SE2TIT") > 0
		SE2TIT->( dbCloseArea() )
	EndIf
	
	If Select("SE2FILTRADO") > 0
		SE2FILTRADO->( dbCloseArea() )
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

	Local cQuery := ""
	Local _aStr  := {}
	
	// Arquivo TRB
	aAdd( _aStr, {'E2_FILIAL' ,TamSX3("E2_FILIAL")[3] ,TamSX3("E2_FILIAL")[1]} )
	aAdd( _aStr, {'E2_PREFIXO',TamSX3("E2_PREFIXO")[3],TamSX3("E2_PREFIXO")[1]} )
	aAdd( _aStr, {'E2_NUM'    ,TamSX3("E2_NUM")[3]    ,TamSX3("E2_NUM")[1]} )
	aAdd( _aStr, {'E2_PARCELA',TamSX3("E2_PARCELA")[3],TamSX3("E2_PARCELA")[1]} )
	aAdd( _aStr, {'E2_TIPO'   ,TamSX3("E2_TIPO")[3]   ,TamSX3("E2_TIPO")[1]} )
	aAdd( _aStr, {'E2_NATUREZ',TamSX3("E2_NATUREZ")[3],TamSX3("E2_NATUREZ")[1]} )
	aAdd( _aStr, {'E2_FORNECE',TamSX3("E2_FORNECE")[3],TamSX3("E2_FORNECE")[1]} )
	aAdd( _aStr, {'E2_LOJA'   ,TamSX3("E2_LOJA")[3]   ,TamSX3("E2_LOJA")[1]} )
	aAdd( _aStr, {'E2_NOMFOR' ,TamSX3("E2_NOMFOR")[3] ,TamSX3("E2_NOMFOR")[1]} )
	aAdd( _aStr, {'E2_EMISSAO',TamSX3("E2_EMISSAO")[3],TamSX3("E2_EMISSAO")[1]} )
	aAdd( _aStr, {'E2_VENCREA',TamSX3("E2_VENCREA")[3],TamSX3("E2_VENCREA")[1]} )
	aAdd( _aStr, {'DIAS'      ,'N',9,0} )
	aAdd( _aStr, {'E2_VALOR'  ,TamSX3("E2_VALOR")[3]  ,TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2]} )
	aAdd( _aStr, {'E2_SALDO'  ,TamSX3("E2_SALDO")[3]  ,TamSX3("E2_SALDO")[1], TamSX3("E2_SALDO")[2]} )
	aAdd( _aStr, {'A2_CGC'    ,TamSX3("A2_CGC")[3]    ,TamSX3("A2_CGC")[1]} ) // Chamado n. 052131 || OS 053469 || FINANCAS || FLAVIA || 8461 || REL. FORNECEDORS - fwnm - 09/10/2019

	_cArqTmp := CriaTrab(_aStr, .T.)
	dbUseArea(.T.,,_cArqTmp,"TRB",.F.,.F.)

	// Chamado n. 053203 || OS 054559 || TECNOLOGIA || LUIZ || 8451 || REL.APAGAR - FWNM - 06/11/2019
	_cIndTmp1 := CriaTrab(_aStr,.T.)
	_cIndex1  := "A2_CGC+E2_FORNECE+E2_LOJA"	
	IndRegua("TRB",_cIndTmp1,_cIndex1,,,"Criando Indices...")

	_cIndTmp2 := CriaTrab(_aStr,.T.)
	_cIndex2  := "E2_FORNECE+E2_LOJA"
	IndRegua("TRB",_cIndTmp2,_cIndex2,,,"Criando Indices...")

	dbClearIndex()
    dbSetIndex(_cIndTmp1+OrdBagExt())
    dbSetIndex(_cIndTmp2+OrdBagExt())    
    //
	
	// Querys
	SE2Filtrado()
	ProcRegua( SE2FILTRADO->( LastRec() ) )

	SE2FILTRADO->( dbGoTop() )
	Do While SE2FILTRADO->( !EOF() )	

		IncProc( "Gerando dados... " + SE2FILTRADO->E2_FORNECE + " " + SE2FILTRADO->E2_LOJA )
			
		// Adiantamentos
		SE2ADI()
		
		SE2ADI->( dbGoTop() )
		Do While SE2ADI->( !EOF() )

			RecLock("TRB", .T.)
			
				TRB->E2_FILIAL  := SE2ADI->E2_FILIAL
				TRB->E2_PREFIXO := SE2ADI->E2_PREFIXO
				TRB->E2_NUM     := SE2ADI->E2_NUM
				TRB->E2_PARCELA := SE2ADI->E2_PARCELA
				TRB->E2_TIPO    := SE2ADI->E2_TIPO
				TRB->E2_NATUREZ := SE2ADI->E2_NATUREZ
				TRB->E2_FORNECE := SE2ADI->E2_FORNECE
				TRB->E2_LOJA    := SE2ADI->E2_LOJA
				TRB->E2_NOMFOR  := SE2ADI->E2_NOMFOR
				TRB->E2_EMISSAO := StoD(SE2ADI->E2_EMISSAO)
				TRB->E2_VENCREA := StoD(SE2ADI->E2_VENCREA)
				TRB->DIAS       := SE2ADI->DIAS
				TRB->E2_VALOR   := SE2ADI->E2_VALOR * -1
				TRB->E2_SALDO   := SE2ADI->E2_SALDO * -1
				TRB->A2_CGC     := Posicione("SA2",1,FWxFilial("SA2")+SE2ADI->(E2_FORNECE+E2_LOJA),"A2_CGC") // Chamado n. 052131 || OS 053469 || FINANCAS || FLAVIA || 8461 || REL. FORNECEDORS - fwnm - 09/10/2019 
		
			TRB->( msUnLock() )
			
			SE2ADI->( dbSkip() )
			
		EndDo
		     
		// Titulos
		SE2TIT()
		
		SE2TIT->( dbGoTop() )
		Do While SE2TIT->( !EOF() )

			// Chamado n. 048584 || Incrementar regra para não listar notas se não existir adiantamentos - fwnm - 04/09/2019
			TRB->( dbSetOrder(2) ) // E2_FORNECE+E2_LOJA
			If TRB->( dbSeek(SE2TIT->(E2_FORNECE+E2_LOJA)) ) // 053203 || OS 054559 || TECNOLOGIA || LUIZ || 8451 || REL.APAGAR - fwnm - 06/11/2019
			
				RecLock("TRB", .T.)
				
					TRB->E2_FILIAL  := SE2TIT->E2_FILIAL
					TRB->E2_PREFIXO := SE2TIT->E2_PREFIXO
					TRB->E2_NUM     := SE2TIT->E2_NUM
					TRB->E2_PARCELA := SE2TIT->E2_PARCELA
					TRB->E2_TIPO    := SE2TIT->E2_TIPO
					TRB->E2_NATUREZ := SE2TIT->E2_NATUREZ
					TRB->E2_FORNECE := SE2TIT->E2_FORNECE
					TRB->E2_LOJA    := SE2TIT->E2_LOJA
					TRB->E2_NOMFOR  := SE2TIT->E2_NOMFOR
					TRB->E2_EMISSAO := StoD(SE2TIT->E2_EMISSAO)
					TRB->E2_VENCREA := StoD(SE2TIT->E2_VENCREA)
					TRB->DIAS       := SE2TIT->DIAS
					TRB->E2_VALOR   := SE2TIT->E2_VALOR
					TRB->E2_SALDO   := SE2TIT->E2_SALDO
					TRB->A2_CGC     := Posicione("SA2",1,FWxFilial("SA2")+SE2TIT->(E2_FORNECE+E2_LOJA),"A2_CGC") // Chamado n. 052131 || OS 053469 || FINANCAS || FLAVIA || 8461 || REL. FORNECEDORS - fwnm - 09/10/2019 
			
				TRB->( msUnLock() )
			
			EndIf
			
			SE2TIT->( dbSkip() )
			
		EndDo
		
		SE2FILTRADO->( dbSkip() )
		
	EndDo

Return

/*{Protheus.doc} Static Function SE2FILTRADO
	Cria arquivos de trabalho com parametros do usuario
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static Function SE2Filtrado()
	
	If Select("SE2FILTRADO") > 0
		SE2FILTRADO->( dbCloseArea() )
	EndIf
	
	BeginSQL Alias "SE2FILTRADO"

		%NoPARSER%

		SELECT DISTINCT E2_FORNECE, E2_LOJA

		FROM %Table:SE2% SE2 (NOLOCK)
		
	    WHERE E2_FILIAL BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02% 
		AND E2_EMISSAO BETWEEN %EXP:DtoS(MV_PAR03)% AND %EXP:DtoS(MV_PAR04)% 
		AND E2_VENCREA BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)% 
		AND E2_FORNECE BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR09% 
		AND E2_LOJA BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR10% 
		AND E2_SALDO>0
		AND E2_TIPO NOT IN ('RJ')
		AND SE2.D_E_L_E_T_=''
		
	EndSQl

Return

/*{Protheus.doc} Static Function SE2FILTRADO
	Cria arquivos de trabalho dos adiantamentos 
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static Function SE2ADI()
	
	Local cForCod := SE2FILTRADO->E2_FORNECE
	Local cForLoj := SE2FILTRADO->E2_LOJA

	If Select("SE2ADI") > 0
		SE2ADI->( dbCloseArea() )
	EndIf

	BeginSQL Alias "SE2ADI"

		%NoPARSER%

		SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, DateDiff(DAY,E2_EMISSAO,GETDATE()) AS DIAS

		FROM %Table:SE2% SE2 (NOLOCK)

	    WHERE E2_FILIAL BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02% 
		AND E2_EMISSAO BETWEEN %EXP:DtoS(MV_PAR03)% AND %EXP:DtoS(MV_PAR04)% 
		AND E2_VENCREA BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)% 
		AND E2_FORNECE = %EXP:cForCod%
		AND E2_LOJA = %EXP:cForLoj%
		AND E2_SALDO>0
		AND E2_TIPO IN ('PA', 'NDF')
		AND SE2.D_E_L_E_T_=''

	EndSQl

Return

/*{Protheus.doc} Static Function SE2FILTRADO
	Cria arquivos de trabalho das notas fiscais
	@type  Function
	@author Fernando Macieira
	@since 29/08/2009
	@version 01
	@history Chamado 
*/

Static Function SE2TIT()
	
	Local cForCod := SE2FILTRADO->E2_FORNECE
	Local cForLoj := SE2FILTRADO->E2_LOJA

	If Select("SE2TIT") > 0
		SE2TIT->( dbCloseArea() )
	EndIf

	BeginSQL Alias "SE2TIT"

		%NoPARSER%

		SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, DateDiff(DAY,E2_EMISSAO,GETDATE()) AS DIAS

		FROM %Table:SE2% SE2 (NOLOCK)

	    WHERE E2_FILIAL BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02% 
		AND E2_EMISSAO BETWEEN %EXP:DtoS(MV_PAR03)% AND %EXP:DtoS(MV_PAR04)% 
		AND E2_VENCREA BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)% 
		AND E2_FORNECE = %EXP:cForCod%
		AND E2_LOJA = %EXP:cForLoj%
		AND E2_SALDO>0
		AND E2_TIPO NOT IN ('PA', 'NDF', 'RJ')
		AND SE2.D_E_L_E_T_=''

	EndSQl

Return