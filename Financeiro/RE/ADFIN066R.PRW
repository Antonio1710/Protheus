#include "protheus.ch"
#INCLUDE "rwmake.ch"  
#INCLUDE "TOTVS.CH"

// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : ADFIN066R
// ----------+-------------------+----------------------------------------------+---------------
// Data      | Autor             | Descricao                                    | Chamado
// ----------+-------------------+----------------------------------------------+---------------
// 20/08/18  | Ricardo Lima      | Relatorio de Itens da Central de Aprovação   | 
// ----------+-------------------+----------------------------------------------+---------------
// 10/12/2018|William Costa      | Campo Vencimento para varios tipos de titulos| 045446
// ----------+-------------------+----------------------------------------------+---------------
// #############################################################################################

User Function ADFIN066R

    MontaPerg()
    Pergunte("ADFIN066R",.F.)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Itens da Central de Aprovação')

    oReport := ReportDef()	
    oReport:PrintDialog()	
Return

// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : ReportDef
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 19/12/17 | Ricardo Lima      | Relatorio de Itens da Central de Aprovação | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

Static Function ReportDef()

    Local oReport
    Local oSection
    public oBreak

    oReport := TReport():New("ADFIN066R","Central Aprovação","ADFIN066R",{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de Titulo da Central Aprovação, conforme os parametros solicitados.")
    oReport:SetDevice(4) // ABRE COM A SELECAO DE GERAR EM PLANILHA
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)

    oSection := TRSection():New(oReport,OemToAnsi("Central Aprovação"),{"ZC7"},{"Central Aprovação-ZC7"} )

    TRCell():New(oSection,"ZC7APROVA"  ,,"Aprovador") 
    TRCell():New(oSection,"ZC7_RECPAG" ,"ZC7")
    TRCell():New(oSection,"ZC7_TPBLQ"  ,"ZC7") 
    TRCell():New(oSection,"ZC7_DSCBLQ" ,"ZC7")
    TRCell():New(oSection,"ZC7_FILIAL" ,"ZC7")
    TRCell():New(oSection,"ZC7_PREFIX ","ZC7")
    TRCell():New(oSection,"ZC7_NUM"    ,"ZC7")
    TRCell():New(oSection,"ZC7_TIPO"   ,"ZC7")
    TRCell():New(oSection,"ZC7_PARCEL" ,"ZC7")
    TRCell():New(oSection,"ZC7_CLIFOR ","ZC7")
    TRCell():New(oSection,"ZC7_LOJA"   ,"ZC7")
    TRCell():New(oSection,"ZC7CLIFOR"  ,,"Nome") 
    TRCell():New(oSection,"ZC7_VLRBLQ" ,"ZC7")
    TRCell():New(oSection,"ZC7_PROJET" ,"ZC7")
    TRCell():New(oSection,"ZC7_DATA"   ,"ZC7")
    TRCell():New(oSection,"ZC7_NDTVEN" ,"ZC7")
    TRCell():New(oSection,"ZC7_NDTVCR" ,"ZC7")
    TRCell():New(oSection,"ZC7_VLRJUR" ,"ZC7")
    TRCell():New(oSection,"ZC7_DECRES" ,"ZC7")
    TRCell():New(oSection,"ZC7_ACRESC" ,"ZC7")
    TRCell():New(oSection,"ZC7_CNABDE" ,"ZC7")
    TRCell():New(oSection,"ZC7_NIVEL"  ,"ZC7")
    TRCell():New(oSection,"ZC7_CNABAC" ,"ZC7")
    TRCell():New(oSection,"ZC7_ODTVEN" ,"ZC7")
    TRCell():New(oSection,"ZC7_ODTVCR" ,"ZC7")
    TRCell():New(oSection,"ZC7_CUSFIN" ,"ZC7")
    TRCell():New(oSection,"ZC7_PERCUS" ,"ZC7")
    TRCell():New(oSection,"ZC7_NUMCAL" ,"ZC7")
    TRCell():New(oSection,"ZC7_NIVSEG" ,"ZC7")
    TRCell():New(oSection,"ZC7APROVADOR" ,,"Aprovado por") 
    TRCell():New(oSection,"ZC7_OBS"    ,"ZC7")

    // QUEBRA DE PAGINA E TOTALIZADORES
    oBreak := TRBreak():New(oSection,oSection:Cell("ZC7_TPBLQ"),"S",.F.)
    TRFunction():New(oSection:Cell("ZC7_VLRBLQ"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
    TRFunction():New(oSection:Cell("ZC7_VLRJUR"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
    TRFunction():New(oSection:Cell("ZC7_DECRES"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
    TRFunction():New(oSection:Cell("ZC7_ACRESC"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)
    TRFunction():New(oSection:Cell("ZC7_CNABDE"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.)

Return oReport

// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : PrintReport
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 19/12/17 | Ricardo Lima      | Relatorio de Fluxo de Caixa com balizador  | 039396
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

Static Function PrintReport(oReport)

Local oSection := oReport:Section(1)
Local nOrdem   := oReport:Section(1):GetOrder() 
Local cAliasTop := "ZC7"
Local cAlia2Top := "ZCF"
Local sNivBlq   := ""
Local sIniNiv   := ""
Local sFimNiv   := ""
Local sNomeApr  := ""
Local sNomeAnt  := ""
Local sNomePrj  := ""
Local sNomPrjA
Local sUsrApr := ""
lOCAL ndvc := oReport:NDevice
Local dDataini
Local dDatafim

IF ndvc <> 4
    ApMsgInfo("É Recomendado a Geração em Planilha, outro formato pode desconfigurar o relatório, pois a número de colunas é grande.")
EndIf

if MV_PAR09 = 1
    sUsrApr := ""
Else
    sUsrApr := MV_PAR13
EndIf

if MV_PAR09 = 1
    If MV_PAR10 = 1
        if MV_PAR11 = "01" .or. MV_PAR11 = "00"
            sIniNiv := ""
        Else
            sIniNiv := MV_PAR11
        EndIf
        if MV_PAR12 = "01" .or. MV_PAR11 = "00"
            sFimNiv := ""
        Else
            sFimNiv := MV_PAR12
        EndIf
    Else
        DbSelectArea(cAlia2Top)	
        DbCloseArea() 
        BeginSql Alias cAlia2Top
            SELECT ZCF_NIVEL
            FROM ZCF010 ZCF
            WHERE ZCF_APROVA = %EXP:MV_PAR13%
            AND ZCF.%NotDel%
            ORDER BY ZCF_NIVEL
        EndSql
        If (cAlia2Top)->ZCF_NIVEL = '01'
            sIniNiv := ""
        Else
            sIniNiv := (cAlia2Top)->ZCF_NIVEL
        EndIf

        DbSelectArea(cAlia2Top)	
        DbCloseArea() 
        BeginSql Alias cAlia2Top
            SELECT ZCF_NIVEL
            FROM ZCF010 ZCF
            WHERE ZCF_APROVA = %EXP:MV_PAR13%
            AND ZCF.%NotDel%
            ORDER BY ZCF_NIVEL DESC
        EndSql
        If (cAlia2Top)->ZCF_NIVEL = '01'
            sFimNiv := ""
        Else
            sFimNiv := (cAlia2Top)->ZCF_NIVEL
        EndIf
    EndIf
    dDataini := ""
    dDatafim := "ZZZZZZZZ"
Else
    sIniNiv := '  '
    sFimNiv := '99'

    dDataini := DTOS(MV_PAR15)
    dDatafim := DTOS(MV_PAR16)
Endif
oSection:Init() 
 
  BeginSql Alias cAliasTop
  
    //Column ZC7_DTAPR as Date
    Column ZC7_NDTVEN as Date
    Column ZC7_NDTVCR as Date
    Column ZC7_ODTVEN as Date
    Column ZC7_ODTVCR as Date

    SELECT ZC7_FILIAL, 
           ZC7_PREFIX, 
           ZC7_NUM, 
           ZC7_PARCEL, 
           ZC7_CLIFOR, 
           ZC7_LOJA, 
           ZC7_VLRBLQ, 
           ZC7_TPBLQ, 
           ZC7_DSCBLQ, 
           ZC7_PROJET, 
           ZC7_USRAPR, 
           ZC7_NOMAPR, 
           ZC7_DTAPR, 
           ZC7_HRAPR, 
           ZC7_OBS, 
           ZC7_NDTVEN, 
           ZC7_NDTVCR, 
           ZC7_VLRJUR, 
           ZC7_DECRES, 
           ZC7_ACRESC, 
           ZC7_CNABDE, 
           ZC7_RECPAG, 
           ZC7_NIVEL, 
           ZC7_CNABAC, 
           ZC7_ODTVEN, 
           ZC7_ODTVCR, 
           ZC7_TIPO, 
           ZC7_CUSFIN, 
           ZC7_PERCUS, 
           ZC7_NUMCAL, 
           ZC7_NIVSEG, 
           CASE WHEN ZC7_DATA <> '' THEN CONVERT(VARCHAR, CAST(ZC7_DATA AS DATETIME), 103) ELSE CASE WHEN ZC7_RECPAG = 'P' THEN (SELECT TOP(1) CONVERT(VARCHAR, CAST(E2_VENCREA AS DATETIME), 103) FROM SE2010 WHERE E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND D_E_L_E_T_ <> '*') ELSE (SELECT TOP(1) CONVERT(VARCHAR, CAST(E1_VENCREA AS DATETIME), 103) FROM SE1010 WHERE E1_FILIAL = ZC7_FILIAL AND E1_PREFIXO = ZC7_PREFIX AND E1_NUM = ZC7_NUM AND E1_PARCELA = ZC7_PARCEL AND E1_CLIENTE = ZC7_CLIFOR AND E1_LOJA = ZC7_LOJA AND D_E_L_E_T_ <> '*') END END AS ZC7_DATA //10/12/2018 William Costa chamado 045446 || OS 046605 || FINANCAS || ANA || 8384 || REL. CENTRAL APROV
    FROM %table:ZC7% ZC7 
    WHERE ZC7_FILIAL BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR08%
    AND ZC7_USRAPR = %EXP:sUsrApr%
    AND ZC7_CLIFOR BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
    AND ZC7_LOJA BETWEEN %EXP:MV_PAR05% AND %EXP:MV_PAR06%
    AND ZC7_TPBLQ BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
    AND ZC7_NIVEL BETWEEN %EXP:sIniNiv% AND %EXP:sFimNiv%
    AND ZC7_DTAPR BETWEEN %EXP:dDataini% AND %EXP:dDatafim%
    AND ZC7.%NotDel%
    ORDER BY ZC7_TPBLQ, ZC7_FILIAL
     
  EndSql

    oReport:SetMeter(RecCount())

  While !(cAliasTop)->(Eof())

    if Empty((cAliasTop)->ZC7_NIVEL)
        sNivBlq := Soma1( (cAliasTop)->ZC7_NIVEL)
    Else
        sNivBlq := (cAliasTop)->ZC7_NIVEL
    Endif   

    DbSelectArea(cAlia2Top)	
    DbCloseArea() 
    If (cAliasTop)->ZC7_TPBLQ = '000003'
        BeginSql Alias cAlia2Top
            SELECT ZC3_CODUSU, ZC3_NOMUSU, ZC3_APRATV 
            FROM %table:ZC3% ZC3 
            WHERE ZC3_TABPRJ = %EXP:(cAliasTop)->ZC7_TPBLQ% AND ZC3_APRATV <> '1' AND ZC3.%NotDel% 
        EndSql
    Else
        BeginSql Alias cAlia2Top
            SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV 
            FROM %table:ZC3% ZC3 
            INNER JOIN ZCF010 ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.%NotDel%
            WHERE ZCF_CODIGO = %EXP:(cAliasTop)->ZC7_TPBLQ% AND ZCF_NIVEL >= %EXP:sNivBlq% AND ZC3_APRATV <> '1' AND ZC3.%NotDel%
            ORDER BY ZCF_NIVEL 
        EndSql
    EndIf
    
    if MV_PAR09 = 1
        If (cAliasTop)->ZC7_TPBLQ = '000003'
            While (cAlia2Top)->(!Eof())
                sNomePrj += UsrRetName( (cAlia2Top)->ZC3_CODUSU ) + ' | '
            DbSelectArea(cAlia2Top)	
            DbSkip() 
            End
            sNomePrj := substr( Alltrim(sNomePrj) , 1 , len(Alltrim(sNomePrj)) -2 )
            if sNomPrjA <> sNomePrj
                oSection:Cell("ZC7APROVA") :SetValue( sNomePrj )
                sNomPrjA := ""
                sNomPrjA := sNomePrj
            Else
                oSection:Cell("ZC7APROVA") :SetValue( "" )
            Endif
        Else
            sNomeApr := UsrRetName( (cAlia2Top)->ZC3_CODUSU )
            if sNomeAnt <> sNomeApr 
                oSection:Cell("ZC7APROVA") :SetValue( sNomeApr )
                sNomeAnt := ""
                sNomeAnt := sNomeApr 
            Else
                oSection:Cell("ZC7APROVA") :SetValue( "" )
            EndIf    
        EndIf
        
        BeginSql Alias 'ZC7TMP'
            SELECT ZC7_USRAPR, ZC7_NOMAPR, ZC7_DTAPR, ZC7_HRAPR, ZC7_OBS
            FROM %table:ZC7% ZC7
            WHERE ZC7_FILIAL = %EXP:(cAliasTop)->ZC7_FILIAL%
            AND ZC7_CLIFOR = %EXP:(cAliasTop)->ZC7_CLIFOR% AND ZC7_LOJA = %EXP:(cAliasTop)->ZC7_LOJA%
            AND ZC7_PREFIX = %EXP:(cAliasTop)->ZC7_PREFIX% AND ZC7_NUM = %EXP:(cAliasTop)->ZC7_NUM% AND ZC7_PARCEL = %EXP:(cAliasTop)->ZC7_PARCEL% AND ZC7_TIPO = %EXP:(cAliasTop)->ZC7_TIPO%
            AND ZC7_USRAPR <> ' ' AND ZC7.%NotDel%
            ORDER BY ZC7_NIVEL DESC
        EndSql

        oSection:Cell("ZC7APROVADOR") :SetValue( ZC7TMP->ZC7_NOMAPR +"-"+ ZC7TMP->ZC7_DTAPR +"-"+ ZC7TMP->ZC7_HRAPR )
        oSection:Cell("ZC7_OBS") :SetValue( ZC7TMP->ZC7_OBS )
    Else
        //oSection:Cell("ZC7APROVA") :SetValue( UsrRetName( (cAliasTop)->ZC7_USRAPR ) ) 
        oSection:Cell("ZC7APROVADOR") :SetValue( (cAliasTop)->ZC7_NOMAPR +"-"+ DtoC(StoD((cAliasTop)->ZC7_DTAPR)) +"-"+ (cAliasTop)->ZC7_HRAPR )
    EndIf

    if (cAliasTop)->ZC7_RECPAG = 'P'
        oSection:Cell("ZC7CLIFOR") :SetValue( Posicione( "SA2" , 1 , xFilial("SA2") + (cAliasTop)->ZC7_CLIFOR + (cAliasTop)->ZC7_LOJA , "A2_NOME") )
    Else
        oSection:Cell("ZC7CLIFOR") :SetValue( Posicione( "SA1" , 1 , xFilial("SA1") + (cAliasTop)->ZC7_CLIFOR + (cAliasTop)->ZC7_LOJA , "A1_NOME") )
    EndIf
    
    oSection:PrintLine()
    oBreak:SetTitle('Total')		
    
    DbSelectArea(cAliasTop)	
    DbSkip()      
    oReport:IncMeter()
    DbSelectArea(cAlia2Top)	
    DbCloseArea()
    sNomeApr := ""
    sNomePrj := ""
    if MV_PAR09 = 1
        DbSelectArea('ZC7TMP')	
        DbCloseArea()
    EndIf
  End
oSection:Finish()

DbSelectArea(cAliasTop)	
DbCloseArea()

Return

// ########################################################################################## 
// Modulo : SIGAFIN
// Fonte  : MontaPerg
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 20/08/18 | Ricardo Lima      | Monta Pergunta para o Relatorio            | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
Static Function MontaPerg() 
                                 
 Private bValid := Nil 
 Private cF3	:= Nil
 Private cSXG   := Nil
 Private cPyme  := Nil
 Private cPerg  := "ADFIN066R"

	xPutSx1(cPerg,'01','Tipo Bloqueio De ?' , 'Tipo Bloqueio De ?' , 'Tipo Bloqueio De ?' , 'mv_ch1','C',6,0,0,'G',bValid,"SX5ZC3"  ,cSXG,cPyme,'MV_PAR01')
	xPutSx1(cPerg,'02','Tipo Bloqueio Ate?' , 'Tipo Bloqueio Ate?' , 'Tipo Bloqueio Ate?' , 'mv_ch2','C',6,0,0,'G',bValid,"SX5ZC3"  ,cSXG,cPyme,'MV_PAR02') 
	xPutSx1(cPerg,'03','Cli/Forn De  ?'   , 'Cli/Forn De  ?' , 'Cli/Forn De  ?' , 'mv_ch3','C',6,0,0,'G',bValid,"SA2",cSXG,cPyme,'MV_PAR03')
    xPutSx1(cPerg,'04','Cli/Forn Ate ?'   , 'Cli/Forn Ate ?' , 'Cli/Forn Ate ?' , 'mv_ch4','C',6,0,0,'G',bValid,"SA2",cSXG,cPyme,'MV_PAR04')
	xPutSx1(cPerg,'05','Loja De  ?'       , 'Loja De  ?'     , 'Loja De  ?'     , 'mv_ch5','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
	xPutSx1(cPerg,'06','Loja Ate ?'       , 'Loja Ate ?'     , 'Loja Ate ?'     , 'mv_ch6','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
	xPutSx1(cPerg,'07','Filial De  ?'     , 'Filial De  ?'   , 'Filial De  ?'   , 'mv_ch7','C',2,0,0,'G',bValid,"SM0",cSXG,cPyme,'MV_PAR07')
	xPutSx1(cPerg,'08','Filial Ate ?'     , 'Filial Ate ?'   , 'Filial Ate ?'   , 'mv_ch8','C',2,0,0,'G',bValid,"SM0",cSXG,cPyme,'MV_PAR08')
    xPutSx1(cPerg,'09','Tipo ?'           , 'Tipo ?'         , 'Tipo ?'         , 'mv_ch9','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR09','Aberto','','','1','Aprovado','','')
    xPutSx1(cPerg,'10','Nivel ou Aprovador?','Nivel ou Aprovador?','Nivel ou Aprovador?', 'mv_cha','C',1,0,0,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR10','Nivel','','','1','Aprovador','','')
    xPutSx1(cPerg,'11','Nivel De  ?'      , 'Nivel De  ?'    , 'Nivel De  ?'    , 'mv_chb','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR11')
	xPutSx1(cPerg,'12','Nivel Ate ?'      , 'Nivel Ate ?'    , 'Nivel Ate ?'    , 'mv_chc','C',2,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR12')
    xPutSx1(cPerg,'13','Aprovador De  ?'  , 'Aprovador De  ?', 'Aprovador De  ?', 'mv_chd','C',6,0,0,'G',bValid,"ZC3",cSXG,cPyme,'MV_PAR13')
	xPutSx1(cPerg,'14','Aprovador Ate ?'  , 'Aprovador Ate ?', 'Aprovador Ate ?', 'mv_che','C',6,0,0,'G',bValid,"ZC3",cSXG,cPyme,'MV_PAR14')
    xPutSx1(cPerg,'15','Aprovado De  ?'  , 'Aprovado De  ?', 'Aprovado De  ?', 'mv_chf','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR15')
	xPutSx1(cPerg,'16','Aprovado Ate ?'  , 'Aprovado Ate ?', 'Aprovado Ate ?', 'mv_chg','D',8,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR16')
		
Return

// ########################################################################################## 
// Modulo : SIGAFIN
// Fonte  : MontaPerg
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 20/08/18 | Ricardo Lima      | Monta Pergunta para o Relatorio            | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa  := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme   := Iif( cPyme   == Nil, "" , cPyme   ) 
cF3     := Iif( cF3     == NIl, "" , cF3     ) 
cGrpSxg := Iif( cGrpSxg == Nil, "" , cGrpSxg ) 
cCnt01  := Iif( cCnt01  == Nil, "" , cCnt01  ) 
cHelp   := Iif( cHelp   == Nil, "" , cHelp   ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
    cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
    cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

    Reclock( "SX1" , .T. ) 

    Replace X1_GRUPO   With cGrupo 
    Replace X1_ORDEM   With cOrdem 
    Replace X1_PERGUNT With cPergunt 
    Replace X1_PERSPA  With cPerSpa 
    Replace X1_PERENG  With cPerEng 
    Replace X1_VARIAVL With cVar 
    Replace X1_TIPO    With cTipo 
    Replace X1_TAMANHO With nTamanho 
    Replace X1_DECIMAL With nDecimal 
    Replace X1_PRESEL  With nPresel 
    Replace X1_GSC     With cGSC 
    Replace X1_VALID   With cValid 
    Replace X1_VAR01   With cVar01 
    Replace X1_F3      With cF3 
    Replace X1_GRPSXG  With cGrpSxg 

    If Fieldpos("X1_PYME") > 0 
        If cPyme != Nil 
            Replace X1_PYME With cPyme 
        Endif 
    Endif 

    Replace X1_CNT01   With cCnt01 
    If cGSC == "C"               // Mult Escolha 
        Replace X1_DEF01   With cDef01 
        Replace X1_DEFSPA1 With cDefSpa1 
        Replace X1_DEFENG1 With cDefEng1 
        Replace X1_DEF02   With cDef02 
        Replace X1_DEFSPA2 With cDefSpa2 
        Replace X1_DEFENG2 With cDefEng2 
        Replace X1_DEF03   With cDef03 
        Replace X1_DEFSPA3 With cDefSpa3 
        Replace X1_DEFENG3 With cDefEng3 
        Replace X1_DEF04   With cDef04 
        Replace X1_DEFSPA4 With cDefSpa4 
        Replace X1_DEFENG4 With cDefEng4 
        Replace X1_DEF05   With cDef05 
        Replace X1_DEFSPA5 With cDefSpa5 
        Replace X1_DEFENG5 With cDefEng5 
    Endif 

    Replace X1_HELP With cHelp 
    PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 
    MsUnlock() 
Else 

    lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
    lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA) 
    lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG) 

    If lPort .Or. lSpa .Or. lIngl 
        RecLock("SX1",.F.) 
        If lPort 
            SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
        EndIf 
        If lSpa 
            SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
        EndIf 
        If lIngl 
            SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
        EndIf 
        SX1->(MsUnLock()) 
    EndIf 
Endif 
RestArea( aArea ) 

Return
