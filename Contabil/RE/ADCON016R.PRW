#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADCON016R
    Relatório AgriStats.
    @type  Function
    @author Everson
    @since 30/06/2020
    @version 01
    @Ticket 7192  - 28/12/2020 - ADRIANO SAVOINE   - Alterada a tabela CT2050 para CT2050xx No SIG.
    @Ticket 51887 - 04/10/2021 - Fernando Macieira - Relatorio Agristats nao esta gerando
/*/
User Function ADCON016R() // U_ADCON016R()

    //Variáveis.
    Local aArea := GetArea()
    Local aPergs:= {}
    Local aRet  := {}

    // @Ticket 51887 - 04/10/2021 - Fernando Macieira - Relatorio Agristats nao esta gerando
    Private cLinked := GetMV("MV_#LINKPR",,"SBPL") 
	Private cSGBD   := GetMV("MV_#SIGSQL",,"CCZERN_120609_PR_PD")

    //
    Aadd(aPergs,{1,"Mês ",cValToChar(Space(2)),"" ,'.T.',,'.T.',15,.T.})
	Aadd(aPergs,{1,"Ano" ,cValToChar(Space(4)),"" ,'.T.',,'.T.',30,.T.})
    Aadd(aPergs,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

    //
    If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
        Processa({|| geraRel(aRet[1],aRet[2],aRet[3]) },"Função ADCON016R(ADCON016R)","Gerando relatório",.F.)

    EndIf

    //
    RestArea(aArea)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' Relatório AgriStats')


Return Nil
/*/{Protheus.doc} processa
    Processa o relatório.
    @type  Static Function
    @author Everson
    @since 30/06/2020
    @version 01
    /*/
Static Function geraRel(cMes,cAno,cDiret)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := scriptSql(cMes,cAno)
    Local oExcel    := objExcel()
    Local cAliasD   := GetNextAlias()
    Local cArq      := "rel_ct2_" + RetCodUsr() + "_" + DToS(Date()) + "_" + StrTran(Time(),":","_") + "_.xml"
    Local oExcelApp := Nil

    //
    MsAguarde({|| DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAliasD, .F., .T.) },"Função geraRel(ADCON016R)","Obtendo dados...")

    //
    (cAliasD)->(DbGoTop())
    ProcRegua(Contar(cAliasD,"!Eof()"))
    (cAliasD)->(DbGoTop())
    While ! (cAliasD)->(Eof())

        //
        IncProc()

        //
        If (cAliasD)->VALOR < 0
            oExcel:SetCelFrColor("#FF0000")

        Else
            oExcel:SetCelFrColor("#000000")

        EndIf

        //
        oExcel:AddRow("Dados","Movimentos", {cAno + "." + cMes,;
                                            "3",;
                                            (cAliasD)->CONTA,;
                                            (cAliasD)->CT1_DESC01,;
                                            (cAliasD)->CC,;
                                            (cAliasD)->CTT_DESC01,;
                                            (cAliasD)->ITEM,;
                                            (cAliasD)->CTD_DESC01,;
                                            (cAliasD)->VALOR},;
                                            {9})
        (cAliasD)->(DbSkip())

    End

    //
    (cAliasD)->(DbCloseArea())

    //
    oExcel:Activate()

    //
    oExcel:GetXmlFile(cDiret + cArq)
    FreeObj(oExcel)
    oExcel := Nil 

    //
    If apOleCliente("MsExcel")
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open(cDiret + cArq)
        oExcelApp:SetVisible(.T.)
        oExcelApp:Destroy()

    Else 
        WinExec("Explore.exe " + cDiret )

    EndIf

    //
    MsgInfo("Relatório gerado.","Função processa(ADCON016R)")


    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptSql
    Retorna script sql do relatório.
    @type  Static Function
    @author Everson
    @since 30/06/2020
    @version 01
    /*/
Static Function scriptSql(cMes,cAno)

    //Variáveis.
    Local cQuery := ""

    cQuery += " SELECT * " 
    cQuery += " FROM " 
    cQuery += " ( " 
    //cQuery += " SELECT * FROM OPENQUERY ( VPSRV03 ,' " 
    cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", ' " // @Ticket 51887 - 04/10/2021 - Fernando Macieira - Relatorio Agristats nao esta gerando
    cQuery += " SELECT DISTINCT " 
    cQuery += " FONTE.*, CTT.CTT_DESC01, CT1.CT1_DESC01, CTD.CTD_DESC01 " 
    cQuery += " FROM " 
    cQuery += " ( " 
    cQuery += " SELECT " 
    cQuery += " CT2_DEBITO AS CONTA,CT2_CCD AS CC , CT2_ITEMD AS ITEM, SUM(CT2_VALOR) AS VALOR " 
    cQuery += " FROM " 
    //cQuery += " [SIG].[dbo].CT2050XX AS CT2 "  // Ticket 7192 - 28/12/2020 - ADRIANO SAVOINE
    cQuery += " [" + cSGBD + "].[dbo].CT2010 AS CT2 "  // @Ticket 51887 - 04/10/2021 - Fernando Macieira - Relatorio Agristats nao esta gerando
    cQuery += " WHERE " 
    cQuery += " CT2_CCD NOT IN(''ACLOC'') " 
    cQuery += " AND CT2_CCC NOT IN(''ACLOC'') " 
    cQuery += " AND MONTH(CT2.CT2_DATA) = " + cMes + " " 
    cQuery += " AND YEAR(CT2.CT2_DATA) = " + cAno + " " 
    cQuery += " AND CT2.D_E_L_E_T_ ='''' " 
    cQuery += " AND CT2_DEBITO <> '''' " 
    cQuery += " GROUP BY CT2_DEBITO,CT2_CCD , CT2_ITEMD " 
    cQuery += " UNION ALL " 
    cQuery += " SELECT " 
    cQuery += " CT2_CREDIT,CT2_CCC , CT2_ITEMC, SUM(CT2_VALOR * -1) AS VALOR " 
    cQuery += " FROM " 
    cQuery += " [" + cSGBD + "].[dbo].CT2010 AS CT2 "  // @Ticket 51887 - 04/10/2021 - Fernando Macieira - Relatorio Agristats nao esta gerando
    cQuery += " WHERE " 
    cQuery += " CT2_CCD NOT IN(''ACLOC'') " 
    cQuery += " AND CT2_CCC NOT IN(''ACLOC'') " 
    cQuery += " AND MONTH(CT2.CT2_DATA) = " + cMes + " " 
    cQuery += " AND YEAR(CT2.CT2_DATA) = " + cAno + " " 
    cQuery += " And CT2.D_E_L_E_T_ ='''' " 
    cQuery += " AND CT2_CREDIT <> '''' " 
    cQuery += " GROUP BY CT2_CREDIT,CT2_CCC , CT2_ITEMC " 
    cQuery += " ) AS FONTE " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " (SELECT CTT_CUSTO, CTT_DESC01 FROM [" + cSGBD + "].[dbo].CTT010 AS CTT WHERE CTT.D_E_L_E_T_ = '''') AS CTT ON  FONTE.CC = CTT_CUSTO " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " (SELECT CT1_CONTA, CT1_DESC01 FROM [" + cSGBD + "].[dbo].CT1010 AS CT1 WHERE CT1.D_E_L_E_T_ = '''' ) AS CT1 ON FONTE.CONTA = CT1.CT1_CONTA " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " (SELECT CTD_ITEM, CTD_DESC01 FROM [" + cSGBD + "].[dbo].CTD010 AS CTD WHERE CTD.D_E_L_E_T_ = '''') AS CTD ON FONTE.ITEM = CTD.CTD_ITEM " 
    cQuery += " ORDER BY FONTE.ITEM ') " 
    cQuery += " AS FONTE " 

    //CONOUT( DToC(Date()) + " " + Time() + " " + cQuery)
    //
    MemoWrite("C:\TEMP\ADCON016R.TXT", cQuery)

Return cQuery
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 30/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function objExcel()

    //Variáveis.
    Local oExcel := FWMsExcelEx():New()

    //
    oExcel:AddWorkSheet("Dados")
    oExcel:AddTable("Dados","Movimentos")
    oExcel:AddColumn("Dados","Movimentos","Referência",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","Tipo Movimento",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","Conta",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","DescrCta",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","CCusto",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","DescrCC",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","Item",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","DescrItem",1,1,.F.)
    oExcel:AddColumn("Dados","Movimentos","Valor",3,2,.F.)
    
Return oExcel
