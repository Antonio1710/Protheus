#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} ADFIN098R
    Relatório de manutenção de cadastros de clientes.
    @type  Function
    @author Everson
    @since 15/10/2020
    @version 01
    /*/
User Function ADFIN098R() // U_ADFIN098R()

    //Variáveis.
    Local aArea     := GetArea()
    Local aParamBox := {}
    Local aRet      := {}

    //
	Aadd( aParamBox ,{1,"Data Inicial "   ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    Aadd( aParamBox ,{1,"Data Final "     ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    Aadd( aParamBox ,{1,"Usuário De "     ,Space(6),"" ,'.T.',"RELFIN",'.T.',80,.F.,})
    Aadd( aParamBox ,{1,"Usuário Até "    ,Space(6),"" ,'.T.',"RELFIN",'.T.',80,.T.,})

	//
	If ! ParamBox(aParamBox, "", @aRet,,,,,,,,.T.,.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf

    //
    MsAguarde({|| gerRel(aRet[1],aRet[2],aRet[3],aRet[4]) },"Função ADFIN098R(ADFIN098R)","Gerando relatório...")

    //
    RestArea(aArea)

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de manutenção de cadastros de clientes')

    
Return Nil
/*/{Protheus.doc} gerRel
    Processa a geração do relatório.
    @type  Static Function
    @author Everson
    @since 15/10/2020
    @version 01
    /*/
Static Function gerRel(dDtIni,dDtFim,cUsrIni,cUsrFim)

    //Variáveis.
    Local aArea   := GetArea()
    Local oReport := Nil

    //
	oReport := reptDef(dDtIni,dDtFim,cUsrIni,cUsrFim)
	oReport:PrintDialog()

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} reptDef
    Definição do TReport.
    @type  Static Function
    @author Everson
    @since 15/10/2020
    @version 01
    /*/
Static Function reptDef(dDtIni,dDtFim,cUsrIni,cUsrFim)

    //Variáveis.
    Local oReport := Nil
    Local aOrdem  := {}
    
    //
    oReport := TReport():New("RELANALISE",OemToAnsi("Relatório de Manutenção de Cadastros"), Nil, ;
	{|oReport| repPrint(oReport,dDtIni,dDtFim,cUsrIni,cUsrFim)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("") +CRLF+;
	OemToAnsi("") )
	
    //
	oLimSec := TRSection():New(oReport, OemToAnsi("Manutenção de Cadastros"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
    //
    TRCell():New(oLimSec,	"DTENV",  "", "Dt. Envio"  /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"SUPER",  "", "Supervisor" /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"NMSUPER","", "Nm Sup"     /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) 
    TRCell():New(oLimSec,	"VENDED", "", "Vendedor"   /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"NMVEND", "", "Nm Vend"    /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"CODCAD", "", "Cod Cad"    /*Titulo*/,  /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"CLIENTE","", "Cod Cli"    /*Titulo*/,  /*Picture*/,06 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LOJA",   "", "Loja Cli"   /*Titulo*/,  /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"NOME",   "", "Nome"       /*Titulo*/,  /*Picture*/,25 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"CGC",   "" , "CNPJ"       /*Titulo*/,  /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"LIMS",   "","Lmt Solic"   /*Titulo*/,"@E 999,999,999.99"     /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"USER",   "", "Usuário"    /*Titulo*/,  /*Picture*/,25 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"MOT",    "", "Motivo"     /*Titulo*/,  /*Picture*/,50 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport
/*/{Protheus.doc} repPrint
    Impressão do TReport.
    @type  Static Function
    @author Everson
    @since 15/10/2020
    @version 01
    /*/
Static Function repPrint(oReport,dDtIni,dDtFim,cUsrIni,cUsrFim)

    //Variáveis.
	Local oLimSec := oReport:Section(1)
	Local cQuery  := ""
    Local cUsr    := ""

    //
    cQuery  := scptSql(dDtIni,dDtFim,cUsrIni,cUsrFim)
    cQuery += " ORDER BY PB3_DTENVI, PB3_COD, PB3_LOJA " 

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
        oLimSec:Cell("DTENV"):SetBlock( {|| DToC(SToD(D_REL->PB3_DTENVI)) } )
        oLimSec:Cell("SUPER"):SetBlock( {|| Alltrim(D_REL->ZR_CODIGO) } )
        oLimSec:Cell("NMSUPER"):SetBlock( {|| Alltrim(D_REL->ZR_DESCRIC) } ) 
        oLimSec:Cell("VENDED"):SetBlock( {|| Alltrim(D_REL->A3_COD) } )
        oLimSec:Cell("NMVEND"):SetBlock( {|| Alltrim(D_REL->A3_NOME) } )          
        oLimSec:Cell("CODCAD"):SetBlock( {|| Alltrim(D_REL->PB3_COD) + Alltrim(D_REL->PB3_LOJA) } )
        oLimSec:Cell("CLIENTE"):SetBlock( {|| D_REL->PB3_CODSA1} )
        oLimSec:Cell("LOJA"):SetBlock( {|| D_REL->PB3_LOJSA1} )
        oLimSec:Cell("NOME"):SetBlock( {|| D_REL->PB3_NOME} )
        oLimSec:Cell("CGC"):SetBlock( {|| D_REL->PB3_CGC} )
        oLimSec:Cell("LIMS"):SetBlock( {|| D_REL->PB3_LC} )

        cUsr := UsrRetName(D_REL->PB3_VENENC)
        oLimSec:Cell("USER"):SetBlock( {|| cUsr } )
        oLimSec:Cell("MOT"):SetBlock( {|| D_REL->PB3_MOTACE } )

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
    @since 15/10/2020
    @version 01
    /*/
Static Function scptSql(dDtIni,dDtFim,cUsrIni,cUsrFim)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " PB3_DTENVI, " 
    cQuery += " PB3_COD,    " 
    cQuery += " PB3_LOJA,   " 
    cQuery += " PB3_CODSA1, " 
    cQuery += " PB3_LOJSA1, " 
    cQuery += " PB3_NOME, " 
    cQuery += " VEN.A3_COD, " 
    cQuery += " VEN.A3_NOME, " 
    cQuery += " SZR.ZR_CODIGO, " 
    cQuery += " SZR.ZR_DESCRIC, " 
    cQuery += " PB3_ENCAMI, " 
    cQuery += " PB3_VENENC, " 
    cQuery += " PB3_MOTACE, " 
    cQuery += " PB3_LC, PB3_CGC " 
    cQuery += " FROM    " 
    cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS CAD " 
    cQuery += " LEFT OUTER JOIN   " 
    cQuery += " " + RetSqlName("SA3") + " (NOLOCK) AS VEN ON  " 
    cQuery += " VEN.A3_COD = CAD.PB3_CODVEN  " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("SZR") + " (NOLOCK) AS SZR ON " 
    cQuery += " VEN.A3_CODSUP = SZR.ZR_CODIGO " 
    cQuery += " WHERE " 
    cQuery += " PB3_FILIAL = ''   " 
    //cQuery += " AND PB3_SITUAC <> '' " 
    cQuery += " AND PB3_VENENC <> '' " 
    cQuery += " AND PB3_DTENVI >= '" + DToS(dDtIni) + "' " 
    cQuery += " AND PB3_DTENVI <= '" + DToS(dDtFim) + "' " 
    cQuery += " AND PB3_VENENC >= '" + cUsrIni + "' " 
    cQuery += " AND PB3_VENENC <= '" + cUsrFim + "' " 
    cQuery += " AND CAD.D_E_L_E_T_ = ''   " 
    cQuery += " AND VEN.D_E_L_E_T_ = ''  " 
    cQuery += " AND SZR.D_E_L_E_T_ = ''  " 

Return cQuery
