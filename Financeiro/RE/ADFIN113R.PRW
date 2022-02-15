#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Fileio.ch"

/*/{Protheus.doc} User Function ADFIN113R
    Relatório de apuração de desconto financeiro por NCC.
    Chamado 13526.
    @type  Function
    @author Everson
    @since 18/10/2021
    @version 01
    /*/
User Function ADFIN113R() // U_ADFIN113R()

    //Variáveis.
    Local cPerg := "ADFIN113R"

    //
    If ! Pergunte(cPerg, .T.)
        Return Nil

    EndIf

    //
    Processa({|| processRel(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09) })


    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de apuração de desconto financeiro por NCC')
    //

Return Nil
/*/{Protheus.doc} processRel
    Função processa o relatório.
    @type  Static Function
    @author Everson
    @since 18/10/2021
    @version 01
/*/
Static Function processRel(dDtIni, dDtFim, cCliDe, cLjIni, cCliFim, cLjFrim, cRdDe, cRdFim, cPath)

    //Variáveis.
    Local oExcel    := FWMsExcelEx():New()
    Local cQuery    := getQuery(dDtIni, dDtFim, cCliDe, cLjIni, cCliFim, cLjFrim, cRdDe, cRdFim)
    Local nLinha    := 0
    Local nExcel    := 1
    Local cTitulo   := "Desconto Financeiro"
    Local cArqXLS   := "REL_DESC_FIN_" + DToS(Date()) + "_" + StrTran(Time(),":","") + ".xml"
    Local aLinhas   := {}

    //
    cPath := AllTrim(cPath)

    //
    If Select("D_DADOS") > 0
        D_DADOS->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery new Alias "D_DADOS"
    DbSelectArea("D_DADOS")
    D_DADOS->(DbGoTop())

    //
    If D_DADOS->(Eof())
        MsgInfo("Não há dados disponíveis.", "processRel(ADFIN113R)")
        D_DADOS->(DbCloseArea())
        Return Nil

    EndIf

    //
    If Right(AllTrim(cPath),1) <> "\"
        cPath := cPath + "\"

    EndIf

    //
    oExcel:AddworkSheet(cArqXLS)
	oExcel:AddTable (cArqXLS,cTitulo)
    oExcel:AddColumn(cArqXLS,cTitulo,"Emissão"    ,1,1) // 01 A
	oExcel:AddColumn(cArqXLS,cTitulo,"NF"         ,1,1) // 02 B
	oExcel:AddColumn(cArqXLS,cTitulo,"Série"      ,1,1) // 03 C
	oExcel:AddColumn(cArqXLS,cTitulo,"Cód. Rede"  ,1,1) // 04 D
	oExcel:AddColumn(cArqXLS,cTitulo,"Cliente"    ,1,1) // 05 E
	oExcel:AddColumn(cArqXLS,cTitulo,"Loja"       ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"Nome"       ,1,1) // 07 G
	oExcel:AddColumn(cArqXLS,cTitulo,"Valor"      ,3,2) // 08 H
	oExcel:AddColumn(cArqXLS,cTitulo,"Vlr. Desc"  ,3,2) // 09 I
	oExcel:AddColumn(cArqXLS,cTitulo,"% Desc"     ,3,2) // 10 J

    //
    While ! D_DADOS->(Eof())

        //
    	nLinha++

        //
	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 09 I  
	   	               ""  ; // 10 J 
	   	})
        
        //
		aLinhas[nLinha][01] := D_DADOS->F2_EMISSAO //A
		aLinhas[nLinha][02] := D_DADOS->F2_DOC     //B
		aLinhas[nLinha][03] := D_DADOS->F2_SERIE   //C
		aLinhas[nLinha][04] := D_DADOS->A1_CODRED  //D
		aLinhas[nLinha][05] := D_DADOS->A1_COD     //E
		aLinhas[nLinha][06] := D_DADOS->A1_LOJA    //F
		aLinhas[nLinha][07] := D_DADOS->A1_NOME    //G
		aLinhas[nLinha][08] := D_DADOS->E1_VALOR   //H
		aLinhas[nLinha][09] := D_DADOS->F2_XVLRNCC //I
		aLinhas[nLinha][10] := D_DADOS->F2_XPERNCC //J

        D_DADOS->( DbSkip() )

    End

	//
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArqXLS,cTitulo,{aLinhas[nExcel][01],;   // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09],; // 09 I  
	                                     aLinhas[nExcel][10] ; // 10 J
	                                                        })
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArqXLS)

    MsgInfo("Arquivo " + cArqXLS + " gerado com sucesso no path: " + cPath, "processRel (ADFIN113R)")
    
    //
    If MsgYesNo("Deseja abrí-lo agora?", "processRel (ADFIN113R)")
        
        //
        If ! ApOleClient( 'MsExcel' )
            MsgStop( 'Excel não instalado! Abra o arquivo manualmente no diretório:' + cPath, "processRel (ADFIN113R)")
            Return Nil

        EndIf
        
        //
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open( cPath + cArqXLS )
        oExcelApp:SetVisible(.T.)
        
    EndIf

Return Nil
/*/{Protheus.doc} getQuery
    Função retorna script sql.
    @type  Static Function
    @author Everson
    @since 11/10/2021
    @version 01
/*/
Static Function getQuery(dDtIni, dDtFim, cCliDe, cLjIni, cCliFim, cLjFrim, cRdDe, cRdFim)

    //Variáveis.
    Local cQuery := ""

    //Variáveis
    cQuery += " SELECT  " 
        cQuery += " F2_EMISSAO, F2_DOC, F2_SERIE, A1_CODRED, A1_COD, A1_LOJA, "
        cQuery += " A1_NOME, SUM(E1_VALOR) AS E1_VALOR, F2_XVLRNCC, F2_XPERNCC " 
    
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
        cQuery += " F2_CLIENTE = A1_COD " 
        cQuery += " AND F2_LOJA = A1_LOJA " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1 ON " 
        cQuery += " F2_FILIAL = E1_FILIAL " 
        cQuery += " AND F2_CLIENTE = E1_CLIENTE " 
        cQuery += " AND F2_LOJA = E1_LOJA " 
        cQuery += " AND F2_DOC = E1_NUM " 
        cQuery += " AND F2_SERIE = E1_PREFIXO " 
    
    cQuery += " WHERE " 
        cQuery += " F2_FILIAL = '" + FWxFilial("SF2") + "' " 
        cQuery += " AND F2_XPERNCC > 0 " 
        cQuery += " AND F2_EMISSAO BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "' " 
        cQuery += " AND F2_CLIENTE BETWEEN '" + cCliDe + "' AND '" + cCliFim + "' " 
        cQuery += " AND F2_LOJA BETWEEN '" + cLjIni + "' AND '" + cLjFrim + "' " 
        cQuery += " AND A1_CODRED BETWEEN '" + cRdDe + "' AND '" + cRdFim + "' " 
        cQuery += " AND E1_TIPO = 'NF' " 
        cQuery += " AND SF2.D_E_L_E_T_ = '' " 
        cQuery += " AND SA1.D_E_L_E_T_ = '' " 
        cQuery += " AND SE1.D_E_L_E_T_ = '' " 
    
    cQuery += " GROUP BY " 
        cQuery += " F2_EMISSAO, F2_DOC, F2_SERIE, A1_CODRED, A1_COD, A1_LOJA, A1_NOME, F2_XVLRNCC, F2_XPERNCC " 
    
    cQuery += " ORDER BY " 
        cQuery += " F2_EMISSAO, F2_DOC, F2_SERIE " 

Return cQuery
