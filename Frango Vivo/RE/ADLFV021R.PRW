#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#Include "Colors.ch"

/*/{Protheus.doc} User Function ADLFV021R()
  Relatorio de paradas
  @type tkt -  63014
  @author Rodrigo Romão
  @since 04/11/2021
  @history Ticket 63014 - Leonardo P. Monteiro - 04/11/2021 - Desenvolvimento.
/*/

User Function ADLFV021R()
  
    Local cTitulo       := "Relatório Frango Vivo"
  
    private cPerg       := "ADLFV021R"
    private dDtAbatDe   := ctod("")
	private dDtAbatAte  := ctod("")
	private cGranjaDe   := ""
	private cGranjaAte  := ""
    private cStatus     := ""
    private lAnalitc    := .F.
    //private CRLF        := Chr(13)+Chr(10)

	DbSelectArea("ZV2")

	lPerguntas := Perguntas()

	if lPerguntas

		oReport := TReport():New(cPerg,cTitulo,{|| Perguntas() },{|oReport| PrintReport(oReport) })
		oReport:SetTitle(cTitulo)

		oReport:SetPortrait(.T.)

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

	oSection1   := TRSection():New(oReport,"Dados Sintéticos")
    

	TRCell():New(oSection1,"GRANJA"  	            ,"","Granja"        ,"@!"               	    ,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //01
	TRCell():New(oSection1,"GRANOM"  	            ,"","Nome Granja"   ,"@!"               	    ,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //01
    TRCell():New(oSection1,"QTD_AVES"  	            ,"","Qtd. Aves"     ,"@E 9,999,999"        	    ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //02
	TRCell():New(oSection1,"MORT_AVES"     	        ,"","Mort. Aves"    ,"@E 9,999,999.999"         ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //03
	TRCell():New(oSection1,"MEDIA_MORT" 	        ,"","Méd % Mort"    ,"@E 999.99"               	,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //04
	TRCell():New(oSection1,"PESO_MED_REAL"          ,"","Peso Med Real" ,"@E 9,999,999.999"         ,030,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //05
	TRCell():New(oSection1,"PESO_MED_PROG"          ,"","Peso Med Prog" ,"@E 9,999,999.999"         ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //06
	

    oSection2   := TRSection():New(oSection1,"Dados Analíticos")


	TRCell():New(oSection2,"PLACA"  	            ,"","Placa Veículo" ,"@!"               	    ,010,  ,,"LEFT" ,,"LEFT"  ,,,,,,,) //01
    TRCell():New(oSection2,"QTD_AVES"  	            ,"","Qtd. Aves"     ,"@E 9,999,999"        	    ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //02
	TRCell():New(oSection2,"MORT_AVES"     	        ,"","Mort. Aves"    ,"@E 9,999,999.999"         ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //03
	TRCell():New(oSection2,"MEDIA_MORT" 	        ,"","Méd % Mort"    ,"@E 999.99"               	,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //04
	TRCell():New(oSection2,"PESO_MED_REAL"          ,"","Peso Med Real" ,"@E 9,999,999.999"         ,030,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //05
	TRCell():New(oSection2,"PESO_MED_PROG"          ,"","Peso Med Prog" ,"@E 9,999,999.999"         ,010,  ,,"RIGHT" ,,"RIGHT"  ,,,,,,,) //06
	
    //oSection2:Cell("DESCPROD"):SetLineBreak()

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
    local oSection2 := oReport:Section(1):Section(1)

	Private cAlias    := getNextAlias()
    Private cAlias2   := getNextAlias()

    fSQLSint()

  Count To nTotal
  (cAlias)->(DbGoTop())
  oReport:SetMeter(nTotal)

	if !lAnalitc
        oSection1:Init()
    endif

	While (cAlias)->(!Eof()) .and. !oReport:Cancel()
        
        if lAnalitc
            oSection1:Init()
        endif
        
        If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

        
		oSection1:Cell("GRANJA"   	    ):SetValue((cAlias)->ZV1_PGRANJ)
        oSection1:Cell("GRANJA"   	    ):SetSize(10)
        oSection1:Cell("GRANOM"   	    ):SetValue((cAlias)->A2_NOME)
        oSection1:Cell("GRANOM"   	    ):SetSize(40)
		oSection1:Cell("QTD_AVES"  	    ):SetValue((cAlias)->TOTAL_AVES)
        oSection1:Cell("QTD_AVES"   	):SetSize(15)
		oSection1:Cell("MORT_AVES"     	):SetValue((cAlias)->MORTALIDADE)
        oSection1:Cell("MORT_AVES"   	):SetSize(15)
		oSection1:Cell("MEDIA_MORT" 	):SetValue((cAlias)->MORTAL_MED )
        oSection1:Cell("MEDIA_MORT"   	):SetSize(15)
		oSection1:Cell("PESO_MED_REAL"  ):SetValue((cAlias)->PESO_MED_REAL)
        oSection1:Cell("PESO_MED_REAL"  ):SetSize(15)
		oSection1:Cell("PESO_MED_PROG"  ):SetValue((cAlias)->PESO_MED_INF)
        oSection1:Cell("PESO_MED_PROG"  ):SetSize(15)
        //oSection1:Cell("GRANJA"):Disable()
        oSection1:PrintLine()
        //oReport:SkipLine()
        
        if lAnalitc

            fSqlAnalit()
            
            oSection2:Init()
            
            While (cAlias2)->(!Eof()) .and. !oReport:Cancel()
                oReport:PrintsHeader()

                If oReport:Cancel()
                    Exit
                EndIf
                
                oSection2:Cell("PLACA"   	    ):SetValue((cAlias2)->ZV1_RPLACA)
                oSection2:Cell("PLACA"          ):SetSize(10)
                oSection2:Cell("QTD_AVES"  	    ):SetValue((cAlias2)->TOTAL_AVES)
                oSection2:Cell("QTD_AVES"       ):SetSize(15)
                oSection2:Cell("MORT_AVES"     	):SetValue((cAlias2)->MORTALIDADE)
                oSection2:Cell("MORT_AVES"      ):SetSize(15)
                oSection2:Cell("MEDIA_MORT" 	):SetValue((cAlias2)->MORTAL_MED )
                oSection2:Cell("MEDIA_MORT"     ):SetSize(15)
                oSection2:Cell("PESO_MED_REAL"  ):SetValue((cAlias2)->PESO_MED_REAL)
                oSection2:Cell("PESO_MED_REAL"  ):SetSize(15)
                oSection2:Cell("PESO_MED_PROG"  ):SetValue((cAlias2)->PESO_MED_INF)
                oSection2:Cell("PESO_MED_PROG"  ):SetSize(15)

                oSection2:PrintLine()
                
                
                (cAlias2)->(DbSkip())
            enddo
            
            oSection2:Finish()
            (cAlias2)->(DbCloseArea())
        endif

        oReport:SkipLine()

        
        if lAnalitc
            oSection1:Finish()
        endif

		(cAlias)->(DbSkip())
	enddo

    if !lAnalitc
        oSection1:Finish()
    endif

  

	(cAlias)->(DbCloseArea())

Return


Static function fSQLSint()
    Local cQuery := ""

    cQuery := " SELECT ZV1.ZV1_PGRANJ, " + CRLF
    cQuery += "    ISNULL(A2.A2_NOME,'') A2_NOME,  "
    cQuery += "    SUM(ZV1.ZV1_PAVES) TOTAL_AVES, " + CRLF
    cQuery += "    SUM(ZV1_MORTAL) MORTALIDADE, " + CRLF
    cQuery += "    ROUND(SUM(CASE WHEN ZV1.ZV1_PAVES > 0 THEN ZV1.ZV1_MORTAL/ZV1.ZV1_PAVES*100 ELSE 0 END)/COUNT(*),2) MORTAL_MED, " + CRLF
    cQuery += "    ROUND(SUM(CASE WHEN ZV1.ZV1_PAVES > 0 THEN ZV1.ZV1_RPESOT/ZV1.ZV1_PAVES ELSE 0 END)/COUNT(*),2) PESO_MED_REAL, " + CRLF
    
    cQuery += "    ROUND(sum(ZV1.ZV1_PESOME)/count(*),2) PESO_MED_INF " + CRLF
	
	
    cQuery += " FROM  "+ RetSqlName("ZV1") +" (NOLOCK) ZV1 LEFT JOIN "+ RetSqlName("SA2") +" (NOLOCK) A2 ON ZV1.ZV1_CODFOR=A2.A2_COD AND ZV1.ZV1_LOJFOR=A2.A2_LOJA " + CRLF
	cQuery += " WHERE ZV1.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "  AND ZV1.ZV1_PGRANJ BETWEEN '" + cGranjaDe + "' AND '" + cGranjaAte + "'" + CRLF
	cQuery += "  AND ZV1.ZV1_DTABAT BETWEEN '" + dTos(dDtAbatDe) + "' AND '" + dTos(dDtAbatAte) + "' " + CRLF
    
    if cStatus != "T" .AND. !Empty(cStatus)
        cQuery += " AND ZV1.ZV1_STATUS ='"+ cStatus +"' "
    endif

  	cQuery += " GROUP BY ZV1.ZV1_PGRANJ, A2.A2_NOME" + CRLF
    cQuery += " ORDER BY ZV1.ZV1_PGRANJ, A2.A2_NOME;"

	TCQUERY cQuery NEW ALIAS (cAlias)
	DbSelectArea(cAlias)

   TcSetField(cAlias, "ZV1_DTABAT"	, "D", 8, 0)

return

Static function fSqlAnalit()
    Local cQuery := ""

    cQuery := " SELECT ZV1.ZV1_RPLACA, " + CRLF
    cQuery += "    SUM(ZV1.ZV1_PAVES) TOTAL_AVES, " + CRLF
    cQuery += "    SUM(ZV1_MORTAL) MORTALIDADE, " + CRLF
    cQuery += "    ROUND(SUM(CASE WHEN ZV1.ZV1_PAVES > 0 THEN ZV1.ZV1_MORTAL/ZV1.ZV1_PAVES*100 ELSE 0 END)/COUNT(*),2) MORTAL_MED, " + CRLF
    cQuery += "    ROUND(SUM(CASE WHEN ZV1.ZV1_PAVES > 0 THEN ZV1.ZV1_RPESOT/ZV1.ZV1_PAVES ELSE 0 END)/COUNT(*),2) PESO_MED_REAL, " + CRLF
    
    cQuery += "    ROUND(sum(ZV1.ZV1_PESOME)/count(*),2) PESO_MED_INF " + CRLF
	
	
    cQuery += " FROM  "+ RetSqlName("ZV1") +" (NOLOCK) ZV1 " + CRLF
	cQuery += " WHERE ZV1.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "  AND ZV1.ZV1_PGRANJ = '"+ (cAlias)->ZV1_PGRANJ +"'" + CRLF
	cQuery += "  AND ZV1.ZV1_DTABAT BETWEEN '" + dTos(dDtAbatDe) + "' AND '" + dTos(dDtAbatAte) + "' " + CRLF
    
    if cStatus != "T" .AND. !Empty(cStatus)
        cQuery += " AND ZV1.ZV1_STATUS ='"+ cStatus +"' "
    endif

  	cQuery += " GROUP BY ZV1.ZV1_RPLACA" + CRLF
    cQuery += " ORDER BY ZV1.ZV1_RPLACA;"

	TCQUERY cQuery NEW ALIAS (cAlias2)
	DbSelectArea(cAlias2)

   TcSetField(cAlias2, "ZV1_DTABAT"	, "D", 8, 0)

return

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
	Local lPergunta     := .F.
    //Local cPergunta     := "LFV021R"
    
    if Pergunte(cPerg)
		dDtAbatDe   := MV_PAR01
		dDtAbatATE  := MV_PAR02
		cGranjaDe   := MV_PAR03
		cGranjaAte  := MV_PAR04

        if (MV_PAR05 == 1)
            cStatus     := "T"
        elseif (MV_PAR05 == 2)
            cStatus     := "R"
        elseif (MV_PAR05 == 3)
            cStatus     := "I"
        else
            cStatus     := "T"
        endif
        lAnalitc    := iif(MV_PAR06==1,.T.,.F.)

        lPergunta := .T.
	endif

Return lPergunta
