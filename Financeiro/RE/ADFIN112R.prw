#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#Include "Colors.ch"

/*/{Protheus.doc} User Function ADLFV020R
  (long_description)
  @type  Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function ADFIN112R()
  
  local cTitulo       := "Relação de Bonificação"
  
  	private cPerg         := "ADFIN112R"	
  	private dEmissaoDe    := ctod("")
	private dEmissaoAte   := ctod("")
	private cClienteDe    := ""
	private cClienteAte   := ""
	private cRedeDe       := ""
	private cRedeAte      := ""
  	private cContaDebito  := ""

	lPerguntas := Perguntas()

	if lPerguntas

		oReport := TReport():New(cPerg,cTitulo,{|| Perguntas() },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo + " " + Dtoc(MV_PAR01) + " - " + Dtoc(MV_PAR02))

		oReport:SetLandScape(.T.)

		//Define as seções do relatório
		ReportDef(oReport)

		//Dialogo do TReport
		oReport:PrintDialog()
	endif

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relação de Bonificação')
	//

Return

/*/{Protheus.doc} ReportDef
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function ReportDef(oReport)

	oSection1 := TRSection():New(oReport,"Bonificação")
	TRCell():New(oSection1,"CLIENTE"   	            ,"","Cliente"           ,"@!"               	,008,  ,,"LEFT"   ,,"LEFT"  ,,,,,,,) //01
	// TRCell():New(oSection1,"NOME"   	              ,"","Nome"              ,"@!"               	,040,  ,,"LEFT"   ,,"LEFT"  ,,,,,,,) //02
	TRCell():New(oSection1,"VLRORIGINAL"            ,"","Vlr. Original"     ,"@E 999,999,999.99"  ,030,  ,,"RIGHT"  ,,"RIGHT" ,,,,,,,) //03
	TRCell():New(oSection1,"VLRBONIFICACAO"         ,"","Vlr. Bonificacao"  ,"@E 999,999,999.99"  ,030,  ,,"RIGHT"  ,,"RIGHT" ,,,,,,,) //04

  oBreak1 := TRBreak():New(oSection1,{|| },"TOTAL",.F.)
	TRFunction():New(oSection1:Cell("VLRORIGINAL")		  ,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)
	TRFunction():New(oSection1:Cell("VLRBONIFICACAO")		,NIL,"SUM"		,oBreak1,NIL	,"@E 999,999,999.99"	,NIL,.F.,.F.)

Return

/*/{Protheus.doc} PrintReport
  (long_description)
  @type  Static Function
  @author user
  @since 20/05/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function PrintReport(oReport)
	local oSection1 := oReport:Section(1)
	local cQuery    := ""
	local cAlias    := getNextAlias()

	cQuery := "SELECT " + CRLF
  	cQuery += "	 SA1.A1_CODRED      AS CODCLIENTE, " + CRLF
  	// cQuery += "	 SA1.A1_NOME        AS NOME_CLIENTE, " + CRLF
  	cQuery += "	 SUM(SE1.E1_VALOR)  AS VALOR_ORIGINAL, " + CRLF
	cQuery += "	 SUM(CT2.CT2_VALOR) AS VALOR_BONIFICACAO " + CRLF

  	cQuery += "FROM " + RetSqlTab("CT2") + " " + CRLF
  
  	cQuery += " INNER JOIN " + RetSqlTab("SE1") + " " + CRLF
  	cQuery += "   ON  SE1.E1_PREFIXO = CT2.CT2_PREFIX " + CRLF
	cQuery += "   AND SE1.E1_NUM     = CT2.CT2_NUMDOC " + CRLF
  	cQuery += "   AND SE1.E1_PARCELA = CT2.CT2_PARCEL" + CRLF
  	cQuery += "   AND SE1.E1_CLIENTE = CT2.CT2_CLIFOR" + CRLF
  	cQuery += "   AND SE1.E1_LOJA    = CT2.CT2_LOJACF" + CRLF
  	cQuery += "   AND SE1.E1_TIPO    = 'NF'" + CRLF
  	cQuery += "   AND SE1.D_E_L_E_T_ <> '*' " + CRLF
  
  	cQuery += " INNER JOIN " + RetSqlTab("SA1") + " " + CRLF
	cQuery += "  ON  SA1.A1_COD  = SE1.E1_CLIENTE " + CRLF	
	cQuery += "  AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF	
	cQuery += "  AND SA1.D_E_L_E_T_ <> '*'" + CRLF
  
  	cQuery += "WHERE 1=1 " + CRLF
  	cQuery += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
  	cQuery += " AND CT2.CT2_FILIAL = '" + xFilial("CT2") + "' " + CRLF
	cQuery += " AND SA1.A1_CODRED BETWEEN '" + cRedeDe          + "' AND '" + cRedeAte          + "'" + CRLF
	cQuery += " AND SA1.A1_COD    BETWEEN '" + cClienteDe       + "' AND '" + cClienteAte       + "'" + CRLF
	cQuery += " AND CT2.CT2_DATA  BETWEEN '" + dTos(dEmissaoDe) + "' AND '" + dTos(dEmissaoAte) + "'" + CRLF
  	cQuery += " AND CT2.CT2_DEBITO = '" + cContaDebito + "'" + CRLF
  
  	// cQuery += " AND SE1.E1_EMISSAO>='" + dTos(dEmissaoDe) + "'" + CRLF
  
  	cQuery += " GROUP BY  SA1.A1_CODRED " + CRLF
  	cQuery += " ORDER BY  SA1.A1_CODRED"

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

  //  TcSetField(cAlias, "ZV1_DTABAT"	, "D", 8, 0)

  Count To nTotal
  (cAlias)->(DbGoTop())
  oReport:SetMeter(nTotal)

	oSection1:Init()

	While (cAlias)->(!Eof())

		oReport:IncMeter()

		oSection1:Cell("CLIENTE"   	    ):SetValue((cAlias)->CODCLIENTE)
		// oSection1:Cell("NOME"   	      ):SetValue((cAlias)->NOME_CLIENTE)
		oSection1:Cell("VLRORIGINAL"   	):SetValue((cAlias)->VALOR_ORIGINAL)
		oSection1:Cell("VLRBONIFICACAO" ):SetValue((cAlias)->VALOR_BONIFICACAO)

    oSection1:PrintLine()

		(cAlias)->(DbSkip())
	end

  oSection1:Finish()

	(cAlias)->(DbCloseArea())

Return


/*/{Protheus.doc} Perguntas
	(long_description)
	@type  Static Function
	@author user
	@since 27/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function Perguntas()
	local lPergunta     := .F.
	local aParBox		    := {}

	aAdd(aParBox, {1, "Emissão De"	  , ctod("")	, ""	, "", ""	, "", 50, .F.}) // MV_PAR01
	aAdd(aParBox, {1, "Emissão Ate"	  , ctod("")	, ""	, "", ""	, "", 50, .F.}) // MV_PAR02
	aAdd(aParBox, {1, "Rede De "	    , SPACE(06)	, ""	, "", ""  , "", 50, .F.}) // MV_PAR03
	aAdd(aParBox, {1, "Rede Ate"	    , SPACE(06)  , ""	, "", ""	, "", 50, .F.}) // MV_PAR04
	aAdd(aParBox, {1, "Cliente De"	  , SPACE(06)	, ""	, "", ""	, "", 50, .F.}) // MV_PAR05
	aAdd(aParBox, {1, "Cliente Ate"	  , SPACE(06)	, ""	, "", ""	, "", 50, .F.}) // MV_PAR06
	aAdd(aParBox, {1, "Conta Debito"	, SPACE(20)	, ""	, "", ""	, "", 60, .F.}) // MV_PAR07

	lPergunta := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

	if lPergunta
    	dEmissaoDe    := MV_PAR01
	  	dEmissaoAte   := MV_PAR02
	  	cRedeDe       := MV_PAR03
	  	cRedeAte      := MV_PAR04
	  	cClienteDe    := MV_PAR05
	  	cClienteAte   := MV_PAR06
    	cContaDebito  := MV_PAR07
	endif

Return lPergunta
