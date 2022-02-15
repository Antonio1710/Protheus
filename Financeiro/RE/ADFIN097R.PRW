#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} ADFIN097R
    Relatório de manutenção de cadastros de clientes.
    @type  Function
    @author Everson
    @since 02/10/2020
    @version 01
    @history Everson, 06/10/2020, Chamado 432. Incluídas as colunas com o nome do vendedor e supervisor.
    /*/
User Function ADFIN097R() // U_ADFIN097R()

    //Variáveis.
    Local aArea     := GetArea()
    Local aParamBox := {}
    Local aRet      := {}
    Local cVinc     := "1"

    //
	Aadd( aParamBox ,{1,"Data Inicial "   ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    Aadd( aParamBox ,{1,"Data Final "     ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    Aadd( aParamBox ,{1,"Vendedor De "    ,Space(6),"" ,'.T.',"SA3",'.T.',80,.F.,})
    Aadd( aParamBox ,{1,"Vendedor Até "   ,Space(6),"" ,'.T.',"SA3",'.T.',80,.T.,})
    Aadd( aParamBox ,{1,"Supervisor De "  ,Space(6),"" ,'.T.',"SZR2",'.T.',80,.F.})
    Aadd( aParamBox ,{1,"Supervisor Até " ,Space(6),"" ,'.T.',"SZR2",'.T.',80,.T.})
    Aadd( aParamBox ,{2,"Status"          ,cVinc,{"1=Todos","2=Aprovados","3=Rejeitados"},80,"",.T.})

	//
	If ! ParamBox(aParamBox, "", @aRet,,,,,,,,.T.,.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf

    //
    MsAguarde({|| gerRel(aRet[1],aRet[2],aRet[3],aRet[4],aRet[5],aRet[6],aRet[7]) },"Função ADFIN097R(ADFIN097R)","Gerando relatório...")

    //
    RestArea(aArea)

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de manutenção de cadastros de clientes')

    
Return Nil
/*/{Protheus.doc} gerRel
    Processa a geração do relatório.
    @type  Static Function
    @author Everson
    @since 02/10/2020
    @version 01
    /*/
Static Function gerRel(dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim,cStatus)

    //Variáveis.
    Local aArea   := GetArea()
    Local oReport := Nil

    //
	oReport := reptDef(dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim,cStatus)
	oReport:PrintDialog()

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} reptDef
    Definição do TReport.
    @type  Static Function
    @author Everson
    @since 02/10/2020
    @version 01
    /*/
Static Function reptDef(dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim,cStatus)

    //Variáveis.
    Local oReport := Nil
    Local aOrdem  := {}
    
    //
    oReport := TReport():New("RELMAC",OemToAnsi("Relatório de Manutenção de Cadastros"), Nil, ;
	{|oReport| repPrint(oReport,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim,cStatus)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("") +CRLF+;
	OemToAnsi("") )
	
    //
	oLimSec := TRSection():New(oReport, OemToAnsi("Manutenção de Cadastros"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
    //
    TRCell():New(oLimSec,	"STATUS", "","Status"     /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"SUPER",  "","Supervisor" /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"NMSUPER",  "","Nm Sup"   /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) //Everson - 06/10/2020. Chamado 432.

    TRCell():New(oLimSec,	"VENDED", "","Vendedor"   /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"NMVEND", "","Nm Vend"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) //Everson - 06/10/2020. Chamado 432.
    
    TRCell():New(oLimSec,	"CODCAD", "","Cod Cad"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"CLIENTE","","Cod Cli"    /*Titulo*/,                        /*Picture*/,06 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LOJA",   "","Loja Cli"   /*Titulo*/,                        /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"NOME",   "","Nome"       /*Titulo*/,                        /*Picture*/,25 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"CNPJ",   "","CNPJ"       /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"REDE",   "","Cod Rede"   /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"DATAM",  "","Dt Mant"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"HORA",   "","Hora"       /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"CMALT",  "","Alteração"  /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"DEALT",  "","De"         /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"PRALT",  "","Para"       /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport
/*/{Protheus.doc} repPrint
    Impressão do TReport.
    @type  Static Function
    @author Everson
    @since 02/10/2020
    @version 01
    /*/
Static Function repPrint(oReport,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim,cStatus)

    //Variáveis.
	Local oLimSec := oReport:Section(1)
	Local cQuery  := ""
    Local nAux    := 1

    //
    If cStatus == "1"

        //
        For nAux := 1 To 2

            //
            cQuery  += scptSql(nAux,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim)

            //
            If nAux == 1
                cQuery += " UNION ALL "
                
            EndIf

        Next nAux

    ElseIf cStatus == "2"

        cQuery  += scptSql(1,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim)

    ElseIf cStatus == "3"

        cQuery  += scptSql(2,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim)

    EndIf

    //
    cQuery += " ORDER BY   " 
    cQuery += " PB3_COD, PB3_LOJA, PB9.R_E_C_N_O_, PB9_DATA, PB9_HORA " 

    //
    If Select("D_REL") > 0
        D_REL->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_REL"
    DbSelectArea("D_REL")
    D_REL->(DbGoTop())
    oReport:SetMeter(Contar("D_REL","!Eof()"))

    //
    oLimSec:Init()
    
    //
    D_REL->(DbGoTop())
    Do While D_REL->(!EOF())

        //
        oReport:IncMeter() 
        
        //
        If oReport:Cancel()
            oReport:PrintText(OemToAnsi("Cancelado"))
            Exit

        EndIf
        
        //
        oLimSec:Cell("STATUS"):SetBlock( {|| D_REL->STATUS } )
        oLimSec:Cell("SUPER"):SetBlock( {|| Alltrim(D_REL->ZR_CODIGO) } )
        oLimSec:Cell("NMSUPER"):SetBlock( {|| Alltrim(D_REL->ZR_DESCRIC) } ) //Everson - 06/10/2020. Chamado 432.

        oLimSec:Cell("VENDED"):SetBlock( {|| Alltrim(D_REL->A3_COD) } )
        oLimSec:Cell("NMVEND"):SetBlock( {|| Alltrim(D_REL->A3_NOME) } )     //Everson - 06/10/2020. Chamado 432.
        
        oLimSec:Cell("CODCAD"):SetBlock( {|| Alltrim(D_REL->PB9_CODIGO) + Alltrim(D_REL->PB9_LOJA) } )
        oLimSec:Cell("CLIENTE"):SetBlock( {|| D_REL->PB3_CODSA1} )
        oLimSec:Cell("LOJA"):SetBlock( {|| D_REL->PB3_LOJSA1} )
        oLimSec:Cell("NOME"):SetBlock( {|| D_REL->PB3_NOME} )
        oLimSec:Cell("CNPJ"):SetBlock( {|| D_REL->PB3_CGC} )
        oLimSec:Cell("REDE"):SetBlock( {|| D_REL->PB3_CODRED} )
        oLimSec:Cell("DATAM"):SetBlock( {|| DToC(SToD(D_REL->PB9_DATA)) } )
        oLimSec:Cell("HORA"):SetBlock( {||  D_REL->PB9_HORA } )
        oLimSec:Cell("CMALT"):SetBlock( {|| D_REL->PB9_CPOALT} )
        oLimSec:Cell("DEALT"):SetBlock( {|| D_REL->PB9_CPOANT} )
        oLimSec:Cell("PRALT"):SetBlock( {|| D_REL->PB9_CPODEP} )

        //
        oLimSec:PrintLine()

        //
        D_REL->(DbSkip())
        
    End

    //
    oLimSec:Finish()

    //
    D_REL->(dbCloseArea())

Return Nil
/*/{Protheus.doc} sctSql
    Função retorna script sql.
    @type  Static Function
    @author Everson
    @since 02/10/2020
    @version 01
    /*/
Static Function scptSql(nOpc,dDtIni,dDtFim,cVedIni,cVedFim,cSupIni,cSupFim)

    //Variáveis.
    Local cQuery := ""
    Local cAFin	 := Alltrim(cValToChar(GetMv("MV_#URJCAD")))
    Local aAFin  := {}
    Local i      := 1

    //
    aAFin := StrToKarr(cAFin,"/")
	cAFin := ""
	For i := 1 To Len(aAFin)
		
		cAFin += "'" + Alltrim(cValToChar(aAFin[i])) + "',"
		
	Next i
	cAFin := Substr(cAFin,1,Len(cAFin) - 1)

    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " PB9.R_E_C_N_O_ AS REC, "

    cQuery += " '" + Iif(nOpc == 1,"Aprovado","Rejeitado") + "' AS STATUS, " 

    cQuery += " PB9_CPOALT, " 
    cQuery += " PB9_DATA,    " 
    cQuery += " PB9_HORA,    " 
    cQuery += " PB9.PB9_CODIGO, "
    cQuery += " PB9.PB9_LOJA, "
    cQuery += " PB3_CODSA1,    " 
    cQuery += " PB3_LOJSA1,    " 
    cQuery += " PB3_NOME,    " 
    cQuery += " PB3_CODRED,    " 
    cQuery += " REPLACE(REPLACE(PB9_CPOANT,'Credito Aprovado:',''),'Dados Cadastrais:','') AS PB9_CPOANT,  " 
    cQuery += " REPLACE(REPLACE(PB9_CPODEP,'Credito Aprovado:',''),'Dados Cadastrais:','') AS PB9_CPODEP,  " 
    cQuery += " PB9_USUARI,   " 
    cQuery += " PB3_CGC,  " 
    cQuery += " PB3_OBSMEM,  " 
    cQuery += " PB3_COD,  " 
    cQuery += " PB3_LOJA, INICIO.A3_COD, INICIO.ZR_CODIGO, A3_NOME, ZR_DESCRIC " //Everson - 06/10/2020. Chamado 432.
    cQuery += " FROM   " 
    cQuery += " " + RetSqlName("PB9") + "  (NOLOCK) AS PB9   " 
    cQuery += " INNER JOIN   " 
    cQuery += " " + RetSqlName("PB3") + "  (NOLOCK) AS PB3 ON " 
    cQuery += " PB9_CODIGO = PB3_COD   " 
    cQuery += " AND PB9_LOJA = PB3_LOJA   " 

    cQuery += " INNER JOIN " 
    cQuery += " ( " 

    //
    If nOpc == 1
        cQuery += " SELECT PB9_CODIGO, PB9_LOJA FROM " + RetSqlName("PB9") + " WHERE PB9_CPOALT LIKE '%Integracao%' " 
        cQuery += " AND PB9_DATA >= '" + DToS(dDtIni) + "' AND PB9_DATA <= '" + DToS(dDtFim) + "' " 

    ElseIf nOpc == 2
        cQuery += " SELECT PB9_CODIGO, PB9_LOJA FROM " + RetSqlName("PB9") + " WHERE PB9_CPOALT = 'Situacao' AND PB9_CPODEP = 'Rejeitado' " 
        cQuery += " AND PB9_DATA >= '" + DToS(dDtIni) + "' AND PB9_DATA <= '" + DToS(dDtFim) + "' "

    EndIf

    //
    If ! Empty(cAFin)
        cQuery += " AND PB9_USUARI IN (" + cAFin + ") "
    
    EndIf 

    //
    cQuery += " ) AS APRREP ON " 
    cQuery += " PB3_COD = APRREP.PB9_CODIGO " 
    cQuery += " AND PB3_LOJA = APRREP.PB9_LOJA " 
    cQuery += " INNER JOIN " 
    cQuery += " ( " 
    cQuery += " SELECT    " 
    cQuery += " DISTINCT PB9_CODIGO, PB9_LOJA, A3_COD, ZR_CODIGO, A3_NOME, ZR_DESCRIC " //Everson - 06/10/2020. Chamado 432.
    cQuery += " FROM    " 
    cQuery += " " + RetSqlName("PB9") + " (NOLOCK) PB9 " 
    cQuery += " INNER JOIN " + RetSqlName("PB3") + "  (NOLOCK) AS CAD ON (CAD.PB3_COD=PB9.PB9_CODIGO) AND (CAD.PB3_LOJA=PB9.PB9_LOJA) AND (CAD.D_E_L_E_T_ = '')   " 
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SA3") + "  (NOLOCK) AS VEN ON (CAD.PB3_CODVEN=VEN.A3_COD) AND (VEN.D_E_L_E_T_ = '')   " 
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SZR") + "  (NOLOCK) AS SUP ON (VEN.A3_CODSUP=SUP.ZR_CODIGO) AND (SUP.D_E_L_E_T_ = '') "
    cQuery += " WHERE    " 
    cQuery += " PB9.D_E_L_E_T_ = '' " 
    cQuery += " AND VEN.D_E_L_E_T_ = '' " 

    cQuery += " AND VEN.A3_COD >= '" + cVedIni + "' "
    cQuery += " AND VEN.A3_COD <= '" + cVedFim + "' "
    cQuery += " AND SUP.ZR_CODIGO >= '" + cSupIni + "' "
    cQuery += " AND SUP.ZR_CODIGO <= '" + cSupFim + "' "
    cQuery += " AND PB9_CPOALT = 'Vend. Encami' " 
    cQuery += " AND PB9_DATA >= '" + DToS(dDtIni) + "' " 
    cQuery += " ) AS INICIO ON " 
    cQuery += " PB3_COD = INICIO.PB9_CODIGO " 
    cQuery += " AND PB3_LOJA = INICIO.PB9_LOJA " 
    cQuery += " WHERE   " 
    cQuery += " PB9_CPOANT <> PB9_CPODEP   " 
    cQuery += " AND PB9_DATA >= '" + DToS(dDtIni) + "'  " 

    //
    If nOpc == 2
        cQuery += " AND PB3.PB3_MOTREJ <> '' " 

    EndIf 

    //
    cQuery += " AND PB9.D_E_L_E_T_ = ''   " 
    cQuery += " AND PB3.D_E_L_E_T_ = ''   " 
    cQuery += " AND PB9_CPOALT <> 'Envio E-mail' " 

Return cQuery
