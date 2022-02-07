#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#Include "Colors.ch"

/*/{Protheus.doc} User Function ADLFV020R()
  Relatorio de paradas
  @type tkt -  13294
  @author Rodrigo Romão
  @since 20/05/2021
  @history Ticket 13294 - Leonardo P. Monteiro - 13/08/2021 - Melhoria para o projeto apontamento de paradas p/ o recebimento do frango vivo.
/*/

User Function ADLFV020R()
  
	local cTitulo       := "RELAÇÃO DE PARADAS"
  
	private cPerg       := "ADLFV020R"	
	private dDtAbatDe   := ctod("")
	private dDtAbatATE  := ctod("")
	private cOrdCarrDe  := ""
	private cOrdCarrAte := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de paradas')
	

	DbSelectArea("ZV2")

	lPerguntas := Perguntas()

	if lPerguntas

		oReport := TReport():New(cPerg,cTitulo,{|| Perguntas() },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo)

		oReport:SetLandScape(.T.)

		//Define as seções do relatório
		ReportDef(oReport)

		//Dialogo do TReport
		oReport:PrintDialog()
	endif

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

	oSection1 := TRSection():New(oReport,"Dados Paradas")
	TRCell():New(oSection1,"NUMOC"   	            ,"","N. DA OC"      ,"@!"               	,008,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //01
	TRCell():New(oSection1,"ITEM"   	            ,"","Item"          ,"@!"               	,008,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //02
	TRCell():New(oSection1,"GRANJA"  	            ,"","Granja"        ,"@!"               	,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //03
	TRCell():New(oSection1,"DTABATE"  	            ,"","Dt. Abate"     ,"@!"               	,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //04
	TRCell():New(oSection1,"PLACA"     	            ,"","Placa"         ,"@!"               	,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //05
	TRCell():New(oSection1,"CODPARADA" 	            ,"","Cod. Parada"   ,"@!"               	,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //06
	TRCell():New(oSection1,"PARADADESCRICAO"        ,"","Descricao"     ,"@!"               	,030,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //07
	TRCell():New(oSection1,"DEPARTAMENTO"           ,"","Departamento"  ,"@!"               	,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //08
	TRCell():New(oSection1,"DEPARTAMENTODESCRICAO"  ,"","Descricao"     ,"@!"               	,030,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //09
	TRCell():New(oSection1,"MINUTOS"                ,"","Minutos"       ,"@!"               	,010,  ,,"RIGHT",,"RIGHT" ,,,,,,,) //10
	TRCell():New(oSection1,"OBSERVACAO"             ,"","Obs"           ,"@!"               	,060,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //11

  oBreak1 := TRBreak():New(oSection1,oSection1:Cell("DTABATE"),"SUB. TOTAL",.F.)	
	TRFunction():New(oSection1:Cell("MINUTOS")		,NIL,"SUM"		,oBreak1,NIL	,"@E 9,999,999.99"	,NIL,.F.,.F.)

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
	cQuery += "	 ZEI.ZEI_NUMOC, ZEI.ZEI_ITEM, ZEI.ZEI_NUMMP, ZEI.ZEI_MINUTO, ZEI.ZEI_OBS, " + CRLF
	cQuery += "	 ZV1.ZV1_PGRANJ, ZV1.ZV1_DTABAT, ZV1.ZV1_RPLACA, " + CRLF
	cQuery += "	 ZEE.ZEE_DESCRI,ZEE.ZEE_DEPTO,ZGC.ZGC_NOME " + CRLF
  	cQuery += "FROM " + RetSqlTab("ZEI") + " " + CRLF
  	cQuery += " INNER JOIN " + RetSqlTab("ZV1") + " " + CRLF
	cQuery += "  ON  ZEI.ZEI_NUMOC  = ZV1.ZV1_NUMOC" + CRLF
	cQuery += "  AND ZV1.ZV1_FILIAL = '" + xFilial("ZV1") + "'" + CRLF
	cQuery += "  AND ZV1.D_E_L_E_T_ <> '*' " + CRLF
  	cQuery += "  INNER JOIN  "+ RetSqlName("ZGC") +" ZGC " + CRLF
  	cQuery += "  ON  ZEI.ZEI_DEPTO = ZGC.ZGC_DEPTO " + CRLF
  	cQuery += "  AND ZGC.ZGC_FILIAL = '  ' " + CRLF
  	cQuery += "  AND ZGC.D_E_L_E_T_ <> '*' " + CRLF
 	cQuery += "  INNER JOIN  "+ RetSqlName("ZEE") +" ZEE " + CRLF
  	cQuery += "  ON  ZEI.ZEI_DEPTO = ZEE.ZEE_DEPTO " + CRLF 
  	cQuery += "  AND ZEI.ZEI_NUMMP = ZEE.ZEE_CODIGO " + CRLF
  	cQuery += "  AND ZEE.ZEE_FILIAL = '  ' " + CRLF
  	cQuery += "  AND ZEE.D_E_L_E_T_ <> '*' " + CRLF
	/*
	cQuery += " INNER JOIN " + RetSqlTab("ZEE") + " " + CRLF
	cQuery += "  ON  ZEI.ZEI_NUMMP = ZEE.ZEE_CODIGO " + CRLF
	cQuery += "  AND ZEE.ZEE_FILIAL = '" + xFilial("ZEE") + "'" + CRLF
	cQuery += "  AND ZEE.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += " INNER JOIN " + RetSqlTab("ZGC") + " ZGC " + CRLF
	cQuery += "  ON  ZEI.ZEI_DEPTO = ZEE.ZEE_CODIGO " + CRLF
	cQuery += "  AND ZEE.ZEE_FILIAL = '" + xFilial("ZEE") + "'" + CRLF
	cQuery += "  AND ZEE.D_E_L_E_T_ <> '*'" + CRLF
  	*/
	cQuery += "WHERE ZEI.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " AND ZEI.ZEI_NUMOC BETWEEN '" + cOrdCarrDe + "' AND '" + cOrdCarrAte + "'" + CRLF
	cQuery += " AND ZV1.ZV1_DTABAT BETWEEN '" + dTos(dDtAbatDe) + "' AND '" + dTos(dDtAbatATE) + "'" + CRLF
  	cQuery += " ORDER BY ZEI.ZEI_NUMOC, ZEI.ZEI_ITEM "

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

   TcSetField(cAlias, "ZV1_DTABAT"	, "D", 8, 0)

  Count To nTotal
  (cAlias)->(DbGoTop())
  oReport:SetMeter(nTotal)

	oSection1:Init()

	While (cAlias)->(!Eof())

		oReport:IncMeter()

		oSection1:Cell("NUMOC"   	              ):SetValue((cAlias)->ZEI_NUMOC)
		oSection1:Cell("ITEM"   	              ):SetValue((cAlias)->ZEI_ITEM)
		oSection1:Cell("GRANJA"  	              ):SetValue((cAlias)->ZV1_PGRANJ)
		oSection1:Cell("DTABATE"  	            ):SetValue((cAlias)->ZV1_DTABAT)
		oSection1:Cell("PLACA"     	            ):SetValue((cAlias)->ZV1_RPLACA)
		oSection1:Cell("CODPARADA" 	            ):SetValue((cAlias)->ZEI_NUMMP)
		oSection1:Cell("PARADADESCRICAO"        ):SetValue((cAlias)->ZEE_DESCRI)
		oSection1:Cell("DEPARTAMENTO"           ):SetValue((cAlias)->ZEE_DEPTO)
		oSection1:Cell("DEPARTAMENTODESCRICAO"  ):SetValue((cAlias)->ZGC_NOME)
		oSection1:Cell("MINUTOS"                ):SetValue((cAlias)->ZEI_MINUTO)
		oSection1:Cell("OBSERVACAO"             ):SetValue((cAlias)->ZEI_OBS)

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
	local dData         := ctod("")
	local cOrdCarreg    := SPACE(6)

	aAdd(aParBox, {1, "Dt Abate De "	        , dData				, ""					, "", ""		,    "", 60, .F.})	// MV_PAR01
	aAdd(aParBox, {1, "Dt Abate Ate"	        , dData				, ""					, "", ""		,    "", 60, .F.}) 	// MV_PAR02
	aAdd(aParBox, {1, "Ord. Carregamento De"	, cOrdCarreg	, ""					, "", ""		,    "", 40, .F.}) 	// MV_PAR03
	aAdd(aParBox, {1, "Ord. Carregamento Ate"	, cOrdCarreg	, ""					, "", ""		,    "", 40, .F.}) 	// MV_PAR04

	lPergunta := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

	if lPergunta
		dDtAbatDe   := MV_PAR01
		dDtAbatATE  := MV_PAR02
		cOrdCarrDe  := MV_PAR03
		cOrdCarrAte := MV_PAR04
	endif

Return lPergunta
