#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} User Function ADFIN079R
	(long_description)
	@type  Function
	@author FWNM
	@since 29/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado n. 051182 - FWNM          - 05/09/2019 - OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO
	@history Chamado n. 052132 - FWNM          - 09/10/2019 - OS 053473 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTO PA
	@history Chamado n. 054604 - FWNM          - 03/01/2020 - OS 055999 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTOS
	@history Chamado n. 058206 - WILLIAM COSTA - 19/05/2020 - Adicionado campo Nr do Cheque
/*/
User Function ADFIN079R()

	Private cAliasTRB    := ""
	Private cPerg        := "ADFIN079R"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}
	
	u_xPutSx1(cPerg,"01","Dt VencRea/Baixa De  "    , ""    , ""    , "mv_ch1","D",08,0,0,"G",""   ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"02","Dt VencRea/Baixa Ate "    , ""    , ""    , "mv_ch2","D",08,0,0,"G",""   ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"03","Banco          "	  		, ""    , ""    , "mv_ch3","C",03,0,0,"G","","SA6","","","mv_par03",""      ,"","","","","","","","","","","","","","","")
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function ReportDef
	(long_description)
	@type  Static Function
	@author FWNM
	@since 29/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport, oFinanceiro, oSection1, oSection2, oBreak1, oBreak2, oFunc1, oFunc2
	Local aOrdem := {}
	  
	Local cTitulo := "Relação de Pagamentos"

	cAliasTRB := "SE2"
	
	Pergunte(cPerg,.F.)
	
	oReport := TReport():New("ADFIN079R",OemToAnsi(cTitulo), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )
	
	//oReport:SetLandscape()
	oReport:SetPortrait()
	
	// Capa
	oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo),{"SEA"}, aOrdem /*{}*/, .F., .T.)
	
	oSection1:SetTotalInLine(.F.)
	oSection1:SetHeaderBreak(.T.)   
	oSection1:SetLeftMargin(3)	//Identacao da Secao

	// Quebras de Secao
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText("")	

	TRCell():New(oSection1,	"E2_PORTADO"  ,"","Banco"  /*Titulo*/,                        /*Picture*/,TamSX3("E2_PORTADO")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection1,	"EA_MODELO"  ,"","Modelo"  /*Titulo*/,                        /*Picture*/,TamSX3("EA_MODELO")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection1,	"X5_DESCRI"  ,"",""            /*Titulo*/,                        /*Picture*/,TamSX3("X5_DESCRI")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection1,	"E2_VENCREA" ,"","Data" /*Titulo*/,                        /*Picture*/,TamSX3("E2_VENCREA")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection1,	"QUANTIDADE" ,"","Quantidade"  /*Titulo*/,                        /*Picture*/,9 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection1, "E2_SALDO"   ,"","Total Pagamentos/Baixas"      /*Titulo*/,           /*Picture*/,TamSX3("E2_SALDO")[1]+15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	/*
	Sintaxe
	TRBreak():New( <oParent> , <uBreak> , <uTitle> , <lTotalInLine> , <cName> , <lPageBreak> )
	*/
	//oBreak1 := TRBreak():New(oReport,oSection1:Cell("E2_PORTADO"),"Total Pagamentos Capa")
		
	/*
	TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)

	Onde:
	lEndSection Imprime o totalizador na quebra de seção se .T.
	lEndReport   Imprime o totalizador no final do relatório se .T.
	lEndPage     Imprime o totalizador no final de cada página se .T.
	*/
	TRFunction():New(oSection1:Cell("QUANTIDADE"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999",/*uFormula*/,.T.,.F.,.F.,oSection1)
	TRFunction():New(oSection1:Cell("E2_SALDO")  ,NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.T.,.F.,.F.,oSection1)
	

	// Relacao de Pagamentos
	oSection2 := TRSection():New(oReport, OemToAnsi(cTitulo),{"SE2"}, aOrdem /*{}*/, .F., .T.)
	
	oSection2:SetTotalInLine(.F.)
	oSection2:SetHeaderBreak(.T.)   
	oSection2:SetLeftMargin(3)	//Identacao da Secao

	// Quebras de Secao
	oSection2:SetPageBreak(.T.)
	oSection2:SetTotalText("")	

	TRCell():New(oSection2,	"E2_PORTADO" ,"","Banco"  /*Titulo*/,                            /*Picture*/,TamSX3("E2_PORTADO")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"EA_MODELO"  ,"","Modelo" /*Titulo*/,                             /*Picture*/,TamSX3("EA_MODELO")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"X5_DESCRI"  ,"",""            /*Titulo*/,                        /*Picture*/,TamSX3("X5_DESCRI")[1]-20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_FILIAL"  ,"","Filial"     /*Titulo*/,                         /*Picture*/,TamSX3("E2_FILIAL")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_NUM"     ,"","N. Título"  /*Titulo*/,                         /*Picture*/,TamSX3("E2_NUM")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_NUMBCO"  ,"","N. CHEQUE"  /*N. CHEQUE*/,                      /*Picture*/,TamSX3("E2_NUMBCO")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_TIPO"    ,"","Tipo" /*Titulo*/,                               /*Picture*/,TamSX3("E2_FORNECE")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) // Chamado n. 052132 || OS 053473 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTO PA - FWNM - 09/10/2019
	TRCell():New(oSection2,	"E2_FORNECE" ,"","Fornecedor" /*Titulo*/,                         /*Picture*/,TamSX3("E2_FORNECE")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_LOJA"    ,"","Loja"       /*Titulo*/,                         /*Picture*/,TamSX3("E2_LOJA")[1]+5 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_NOMFOR"  ,"","Nome Fantasia"    /*Titulo*/,                   /*Picture*/,TamSX3("E2_NOMFOR")[1]+20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2,	"E2_VENCREA" ,"","Data" /*Titulo*/,                               /*Picture*/,TamSX3("E2_VENCREA")[1]+10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oSection2, "E2_SALDO"   ,"","Valor"      /*Titulo*/,                         /*Picture*/,TamSX3("E2_SALDO")[1]+15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

	oBreak2 := TRBreak():New(oReport,oSection2:Cell("X5_DESCRI"),"Total do Modelo",.F.)
	
	TRFunction():New(oSection2:Cell("E2_NUM"),"Quantidade Títulos Modelo","COUNT",oBreak2,"Quantidade Títulos Modelo","@E 999,999,999,999,999",/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection2:Cell("E2_SALDO"),NIL,"SUM",oBreak2,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)

Return(oReport)

/*/{Protheus.doc} Static Function ReportPrint
	(long_description)
	@type  Static Function
	@author FWNM
	@since 29/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportPrint(cAliasTRB)

	Local aCampos   := {}
	Local cQuery    := ""
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	 
	Local oTempTable
		
	MakeSqlExpr(cPerg)
	
	// Crio TRB para impressão
	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New("TRB")
	
	aAdd(aCampos,{'E2_FILIAL'  ,TamSX3("E2_FILIAL")[3]  ,TamSX3("E2_FILIAL")[1] ,0})
	aAdd(aCampos,{'E2_PREFIXO' ,TamSX3("E2_PREFIXO")[3] ,TamSX3("E2_PREFIXO")[1],0})
	aAdd(aCampos,{'E2_NUM'     ,TamSX3("E2_NUM")[3]     ,TamSX3("E2_NUM")[1]    ,0})
	aAdd(aCampos,{'E2_NUMBCO'  ,TamSX3("E2_NUMBCO")[3]  ,TamSX3("E2_NUMBCO")[1] ,TamSX3("E2_NUMBCO")[2]})
	aAdd(aCampos,{'E2_PARCELA' ,TamSX3("E2_PARCELA")[3] ,TamSX3("E2_PARCELA")[1],0})
	aAdd(aCampos,{'E2_TIPO'    ,TamSX3("E2_TIPO")[3]    ,TamSX3("E2_TIPO")[1]   ,0})
    aAdd(aCampos,{'E2_FORNECE' ,TamSX3("E2_FORNECE")[3] ,TamSX3("E2_FORNECE")[1],0})
	aAdd(aCampos,{'E2_LOJA'    ,TamSX3("E2_LOJA")[3]    ,TamSX3("E2_LOJA")[1]   ,0})
    aAdd(aCampos,{'E2_NOMFOR'  ,TamSX3("E2_NOMFOR")[3]  ,TamSX3("E2_NOMFOR")[1] ,0})

	aAdd(aCampos,{'E2_NUMBOR'  ,TamSX3("E2_NUMBOR")[3]  ,TamSX3("E2_NUMBOR")[1] ,0})
	aAdd(aCampos,{'E2_PORTADO' ,TamSX3("E2_PORTADO")[3] ,TamSX3("E2_PORTADO")[1],0})
    aAdd(aCampos,{'EA_MODELO'  ,TamSX3("EA_MODELO")[3]  ,TamSX3("EA_MODELO")[1] ,0})
	aAdd(aCampos,{'X5_DESCRI'  ,TamSX3("X5_DESCRI")[3]  ,TamSX3("X5_DESCRI")[1] ,0})
   	aAdd(aCampos,{'E2_VENCREA' ,TamSX3("E2_VENCREA")[3] ,TamSX3("E2_VENCREA")[1],TamSX3("E2_VENCREA")[2]})
   	aAdd(aCampos,{'E2_SALDO'   ,TamSX3("E2_SALDO")[3]   ,TamSX3("E2_SALDO")[1]  ,TamSX3("E2_SALDO")[2]})
	
	
	oTemptable:SetFields(aCampos)
	//oTempTable:AddIndex("01", {"CHAVE"} )
	oTempTable:Create()
    
	// Busco dados do painel contas a pagar pois o relatorio sera sempre comparado com o resultado dela
	cQuery := StaticCall( ADFIN033P, scriptCPD, MV_PAR01, MV_PAR02 )

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	tcQuery cQuery New Alias "Work"
	
	// Populo TRB
	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		cModelo := ""
		cX5Desc := ""
		
		// debug
		/*
		If AllTrim(Work->E2_NUM)=="000006709"
			cDebug := ""
		EndIf
		*/
		//
		
		// Modelo
		If !Empty(Work->E2_NUMBOR)
			cModelo := UpModelo(Work->E2_FIL, Work->E2_NUMBOR, Work->E2_PREFIXO, Work->E2_NUM, Work->E2_PARCELA, Work->E2_TIPO, Work->E2_FORNECE, Work->E2_LOJA)
			cX5Desc := AllTrim(Posicione("SX5",1,FWxFilial("SX5")+"58"+cModelo,"X5_DESCRI"))
		Else
			SE2->( dbSetOrder(1) ) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
 			If SE2->( dbSeek( Work->E2_FIL + Work->E2_PREFIXO + Work->E2_NUM + Work->E2_PARCELA + Work->E2_TIPO + Work->E2_FORNECE + Work->E2_LOJA ) )
				If Left(AllTrim(SE2->E2_ORIGEM),3) == "GPE"
					cModelo := "BX"
					cX5Desc := "BAIXA MANUAL RH"
				Else
					cModelo := "BX"
					cX5Desc := "BAIXA MANUAL FORNECEDOR"
				EndIf
			EndIf
		EndIf

		// Insere arquivo TRB
		RecLock("TRB", .T.)

			TRB->E2_FILIAL  := Work->E2_FIL
			TRB->E2_PREFIXO := Work->E2_PREFIXO
			TRB->E2_NUM     := Work->E2_NUM
			TRB->E2_PARCELA := Work->E2_PARCELA
			TRB->E2_TIPO    := Work->E2_TIPO
			TRB->E2_FORNECE := Work->E2_FORNECE
			TRB->E2_LOJA    := Work->E2_LOJA
			TRB->E2_NOMFOR  := Work->E2_NOMFOR
			TRB->E2_PORTADO := Work->E2_PORTADO
			TRB->E2_NUMBOR  := Work->E2_NUMBOR
			TRB->E2_VENCREA := StoD(Work->PAGTO)
			TRB->E2_SALDO   := Work->VALOR
			TRB->E2_NUMBCO  := Work->E2_NUMBCO

			TRB->EA_MODELO := cModelo
			TRB->X5_DESCRI := cX5Desc
		
		TRB->( msUnLock() )

		Work->( dbSkip() )
	
	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	// Capa
	If Select("WorkCapa") > 0
		WorkCapa->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT E2_PORTADO, EA_MODELO, X5_DESCRI, E2_VENCREA, COUNT(DISTINCT E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) QTD, SUM(E2_SALDO) E2_SALDO "
	cQuery += " FROM " + oTempTable:GetRealName() + " (NOLOCK) "
	cQuery += " WHERE E2_PORTADO='"+MV_PAR03+"' "
	cQuery += " GROUP BY E2_PORTADO, EA_MODELO, X5_DESCRI, E2_VENCREA "
	cQuery += " ORDER BY E2_SALDO DESC "
	
	tcQuery cQuery New Alias "WorkCapa"
	
	oReport:SetMeter( WorkCapa->( LastRec() ) )	
	
	WorkCapa->( dbGoTop() )
	Do While WorkCapa->( !EOF() )
		
		If oReport:Cancel()
			Exit
		EndIf
		
		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()
		
		IncProc("Imprimindo CAPA " + AllTrim(WorkCapa->X5_DESCRI))

		oSection1:Cell("E2_PORTADO") :SetBlock( {|| WorkCapa->E2_PORTADO} )
		oSection1:Cell("EA_MODELO")  :SetBlock( {|| WorkCapa->EA_MODELO} )
		oSection1:Cell("X5_DESCRI")  :SetBlock( {|| WorkCapa->X5_DESCRI} )
		oSection1:Cell("E2_VENCREA") :SetBlock( {|| DtoC(StoD(WorkCapa->E2_VENCREA))} )
		oSection1:Cell("QUANTIDADE") :SetBlock( {|| WorkCapa->QTD} )
		oSection1:Cell("E2_SALDO")   :SetBlock( {|| WorkCapa->E2_SALDO} )

		oSection1:Printline()	

		WorkCapa->( dbSkip() )

	EndDo
	
	//imprimo uma linha para separar 
	oReport:ThinLine()	
		
	//finalizo a primeira seção
	oSection1:Finish()

	If Select("WorkCAPA") > 0
		WorkCAPA->( dbCloseArea() )
	EndIf

	//////////////////////////////////////////////////////////////////////////////////////////

	// Relacao de pagamentos (analitico)
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT E2_PORTADO, EA_MODELO, X5_DESCRI, E2_FILIAL, E2_PREFIXO, E2_NUM,E2_NUMBCO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_VENCREA, E2_SALDO "
	cQuery += " FROM " + oTempTable:GetRealName() + " (NOLOCK) "
	cQuery += " WHERE E2_PORTADO='"+MV_PAR03+"' "
	cQuery += " ORDER BY X5_DESCRI, E2_SALDO DESC "
		
	tcQuery cQuery New Alias "Work"

	oReport:SetMeter( Work->( LastRec() ) )	
	
	Work->( dbGoTop() )
	Do While Work->( !EOF() )
		
		If oReport:Cancel()
			Exit
		EndIf
		
		//inicializo a segunda seção
		oSection2:Init()

		oReport:IncMeter()
		
		IncProc("Imprimindo relação de pagamentos " + AllTrim(Work->E2_FILIAL+E2_NUM+E2_FORNECE+E2_LOJA+E2_NOMFOR))

		oSection2:Cell("E2_PORTADO") :SetBlock( {|| Work->E2_PORTADO} )
		oSection2:Cell("EA_MODELO")  :SetBlock( {|| Work->EA_MODELO} )
		oSection2:Cell("X5_DESCRI")  :SetBlock( {|| Work->X5_DESCRI} )
		oSection2:Cell("E2_FILIAL")  :SetBlock( {|| Work->E2_FILIAL} )
		oSection2:Cell("E2_NUM") 	 :SetBlock( {|| Work->E2_NUM} )
		oSection2:Cell("E2_NUMBCO")  :SetBlock( {|| Work->E2_NUMBCO})
		oSection2:Cell("E2_TIPO")    :SetBlock( {|| Work->E2_TIPO} ) // Chamado n. 052132 || OS 053473 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTO PA - FWNM - 09/10/2019
		oSection2:Cell("E2_FORNECE") :SetBlock( {|| Work->E2_FORNECE} )
		oSection2:Cell("E2_LOJA")    :SetBlock( {|| Work->E2_LOJA} )
		oSection2:Cell("E2_NOMFOR")  :SetBlock( {|| Work->E2_NOMFOR} )
		oSection2:Cell("E2_VENCREA") :SetBlock( {|| DtoC(StoD(Work->E2_VENCREA))} )
		oSection2:Cell("E2_SALDO")   :SetBlock( {|| Work->E2_SALDO} )
		
		oSection2:Printline()	

		Work->( dbSkip() )
		
	EndDo
	
	//imprimo uma linha para separar 
	//oReport:ThinLine()	
		
	//finalizo a primeira seção
	oSection2:Finish()

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	oTempTable:Delete()

Return

/*/{Protheus.doc} Static Function UpModelo
	(long_description)
	@type  Static Function
	@author FWNM
	@since 29/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpModelo(cE2_FIL, cE2_NUMBOR, cE2_PREFIXO, cE2_NUM, cE2_PARCELA, cE2_TIPO, cE2_FORNECE, cE2_LOJA)

	Local cModelo := ""
	Local cQuery := ""
	
	If Select("WorkSEA") > 0
		WorkSEA->( dbCloseArea() )
	EndIf

	cQuery := " SELECT EA_MODELO "
	cQuery += " FROM " + RetSqlName("SEA") + " SEA (NOLOCK) "
	cQuery += " WHERE EA_FILORIG='"+cE2_FIL+"' "
	cQuery += " AND EA_NUMBOR='"+cE2_NUMBOR+"' "
	cQuery += " AND EA_PREFIXO='"+cE2_PREFIXO+"' "
	cQuery += " AND EA_NUM='"+cE2_NUM+"' "
	cQuery += " AND EA_PARCELA='"+cE2_PARCELA+"' "
	cQuery += " AND EA_TIPO='"+cE2_TIPO+"' "
	cQuery += " AND EA_CART='P' "
	cQuery += " AND D_E_L_E_T_='' "

	tcQuery cQuery New Alias "WorkSEA"
	
	WorkSEA->( dbGoTop() )
	If WorkSEA->( !EOF() )
		cModelo := WorkSEA->EA_MODELO
	EndIf
	
	If Select("WorkSEA") > 0
		WorkSEA->( dbCloseArea() )
	EndIf

Return cModelo