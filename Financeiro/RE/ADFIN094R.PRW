#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Report.ch"

/*/{Protheus.doc} User Function ADFIN094R
    Relatório de alteração de limite de crédito.
    @type  Function
    @author Everson
    @since 31/08/2020
    @version 01
    @history Everson, 03/09/2020, chamado 262. Substituída a classe FWMsExcelEx por TReport para que não ocorra erro de limitação ao abrir o arquivo no Excel
    e alterada regra do cálculo de saldo em aberto.
    @history Everson, 24/09/2020, chamado TI. Alteração do cálculo de maior acumulo.
    /*/
User Function ADFIN094R() // U_ADFIN094R()

    //Variáveis.
    Local aArea     := GetArea()
    Local aParamBox := {}
    Local aRet      := {}

    //
	Aadd( aParamBox ,{1,"Data De "     ,CtoD(space(8)),"" ,'.T.',,'.T.',80,.T.})
	Aadd( aParamBox ,{1,"Data Até"     ,CtoD(space(8)),"" ,'.T.',,'.T.',80,.T.})
	
	//
	If ! ParamBox(aParamBox, "", @aRet,,,,,,,,.T.,.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf

    //
    Processa({|| gerRel(aRet[1],aRet[2]) },"Função ADFIN094R(ADFIN094R)","Gerando relatório...")

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scptSql
    Processa a geração do relatório.
    @type  Static Function
    @author Everson
    @since 31/08/2020
    @version 01
    /*/
Static Function gerRel(dDtIni,dDtFim)

    //Variáveis.
    Local aArea   := GetArea()
    Local oReport := Nil

    //
	oReport := reptDef(dDtIni,dDtFim)
	oReport:PrintDialog()

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} Everson
    Definição do TReport.
    @type  Static Function
    @author Everson
    @since 01/09/2020
    @version 01
    /*/
Static Function reptDef(dDtIni,dDtFim)

    //Variáveis.
    Local oReport := Nil
    Local aOrdem  := {}
    
    //Everson, 03/09/2020, chamado 262.
    oReport := TReport():New("RELLIM",OemToAnsi("Relatório de Limites de Crédito Alterados"), Nil, ;
	{|oReport| repPrint(oReport,dDtIni,dDtFim)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("") +CRLF+;
	OemToAnsi("") )
	
    //
	oLimSec := TRSection():New(oReport, OemToAnsi("Limites de Crédito Alterados"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
    //
	TRCell():New(oLimSec,	"DATA",   "","Data"       /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"HORA",   "","Hora"       /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"CLIENTE","","Cod. Cli"   /*Titulo*/,                        /*Picture*/,06 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LOJA",   "","Loja Cli"   /*Titulo*/,                        /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"NOME",   "","Nome"       /*Titulo*/,                        /*Picture*/,25 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"CNPJ",   "","CNPJ"       /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"REDE",   "","Cod. Rede"  /*Titulo*/,                        /*Picture*/,08 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LANT",   "","Lmt Ant"    /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,18 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LATU",   "","Lmt Atu"    /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,18 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"USR",    "","Usuário"    /*Titulo*/,                        /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"RCISP",  "","Rat CISP"   /*Titulo*/,                        /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"SLDA",   "","Sld Aberto" /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,18 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"DTACU",  "","Dt M Acum"  /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"VACU",   "","Vl M Acum"  /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,18 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"PERFIL", "","Perfil"     /*Titulo*/,                        /*Picture*/,06 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"PARECER","","Parecer"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport
/*/{Protheus.doc} repPrint
    Impressão do TReport.
    @type  Static Function
    @author Everson
    @since 03/09/2020
    @version 01
    /*/
Static Function repPrint(oReport,dDtIni,dDtFim)

    //Variáveis.
	Local oLimSec := oReport:Section(1)
	Local cQuery  := scptSql(dDtIni,dDtFim)
    Local cParecer:= ""
    Local nVlrSld := 0
    Local nVlrAcum:= 0

    //
    If Select("D_REL") > 0
        D_REL->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_REL"
    DbSelectArea("D_REL")
    D_REL->(DbGoTop())

	//
	oLimSec:SetMeter( Contar("D_REL","!Eof()") )
	
    //
	D_REL->(DbGoTop())
	Do While D_REL->(!EOF())
		
        //
		oLimSec:IncMeter()
		
        //
		oLimSec:Init()
		
        //
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit

		EndIf

        //
        cParecer := getParecer(D_REL->PB3_COD,D_REL->PB3_LOJA,D_REL->PB9_DATA)

        //
        If !Empty(D_REL->PB3_CODRED)
            nVlrSld  := sldRede(D_REL->PB3_CODRED,D_REL->PB9_DATA)
            nVlrAcum := D_REL->ACUMR

        Else 
            nVlrSld  := sldVar(Alltrim(D_REL->PB3_COD)+Alltrim(D_REL->PB3_LOJA),D_REL->PB9_DATA)
            nVlrAcum := D_REL->A1_VLACUMU

        EndIf
		
		//
		oLimSec:Cell("DATA"):SetBlock( {|| DToC(SToD(D_REL->PB9_DATA)) } )
		oLimSec:Cell("HORA"):SetBlock( {|| D_REL->PB9_HORA } )
		oLimSec:Cell("CLIENTE"):SetBlock( {|| D_REL->PB3_CODSA1} )
		oLimSec:Cell("LOJA"):SetBlock( {|| D_REL->PB3_LOJSA1} )
		oLimSec:Cell("NOME"):SetBlock( {|| D_REL->PB3_NOME} )
		oLimSec:Cell("CNPJ"):SetBlock( {|| D_REL->A1_CGC} )
		oLimSec:Cell("REDE"):SetBlock( {|| D_REL->PB3_CODRED} )
		oLimSec:Cell("LANT"):SetBlock( {|| Val(cValToChar(D_REL->PB9_CPOANT)) } )
		oLimSec:Cell("LATU"):SetBlock( {|| Val(cValToChar(D_REL->PB9_CPODEP))} )
		oLimSec:Cell("USR"):SetBlock(  {|| D_REL->PB9_USUARI} )
		oLimSec:Cell("RCISP"):SetBlock({|| D_REL->A1_XRISCO} )
		oLimSec:Cell("SLDA"):SetBlock( {|| nVlrSld} )
		oLimSec:Cell("DTACU"):SetBlock({|| DToC(SToD(D_REL->A1_DTACUMU)) } )
		oLimSec:Cell("VACU"):SetBlock( {|| nVlrAcum} )
		oLimSec:Cell("PERFIL"):SetBlock( {|| D_REL->PERFIL} )
		oLimSec:Cell("PARECER"):SetBlock( {|| cParecer} )
    
        //
		oLimSec:PrintLine()
		oReport:IncMeter()

        //
		D_REL->(DbSkip())
		
	Enddo
	
    //
	oLimSec:Finish()
	
    //
	D_REL->(dbCloseArea())

Return Nil
/*/{Protheus.doc} scptSql
    Retorna script sql.
    @type  Static Function
    @author Everson
    @since 31/08/2020
    @version 01
    /*/
Static Function scptSql(dDtIni,dDtFim)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " PB9_DATA,  " 
    cQuery += " PB9_HORA,  " 
    cQuery += " PB3_CODSA1,  " 
    cQuery += " PB3_LOJSA1,  " 
    cQuery += " PB3_NOME,  " 
    cQuery += " PB3_CODRED,  " 
    cQuery += " REPLACE(REPLACE(PB9_CPOANT,'Credito Aprovado:',''),'Dados Cadastrais:','') AS PB9_CPOANT, "
    cQuery += " REPLACE(REPLACE(PB9_CPODEP,'Credito Aprovado:',''),'Dados Cadastrais:','') AS PB9_CPODEP, "
    cQuery += " PB9_USUARI, " 
    cQuery += " A1_XRISCO, " 
    cQuery += " E1_SALDO, " 
    cQuery += " A1_DTACUMU, " 
    cQuery += " A1_VLACUMU, " 

    cQuery += " (SELECT MAX(ZF_VLACUMU) AS ZF_VLACUMU FROM SZF010 (NOLOCK) WHERE ZF_REDE = PB3_CODRED AND D_E_L_E_T_ = '') ACUMR, " //Everson - 24/09/2020. Chamado T.I.

    cQuery += " A1_CGC, "
    cQuery += " '' AS PERFIL, " 
    cQuery += " PB3_OBSMEM, PB3_COD, PB3_LOJA " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("PB9") + " (NOLOCK) AS PB9 " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS PB3 ON " 
    cQuery += " PB9_CODIGO = PB3_COD " 
    cQuery += " AND PB9_LOJA = PB3_LOJA " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
    cQuery += " PB3_CODSA1 = A1_COD " 
    cQuery += " AND PB3_LOJSA1 = A1_LOJA " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " ( " 
    cQuery += " SELECT  " 
    cQuery += " E1_CLIENTE, E1_LOJA ,  " 
    cQuery += " SUM(E1_SALDO) AS E1_SALDO, " 
    cQuery += " SUM(E1_VALOR) AS E1_VALOR " 
    cQuery += " FROM   " 
    cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1 " 
    cQuery += " WHERE  " 
    cQuery += " E1_SALDO > 0  " 
    cQuery += " AND E1_TIPO NOT IN ('NCC','RA') " 
    cQuery += " AND D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY  " 
    cQuery += " E1_CLIENTE, E1_LOJA " 
    cQuery += " ) AS TIT_AB ON " 
    cQuery += " A1_COD = TIT_AB.E1_CLIENTE " 
    cQuery += " AND A1_LOJA = TIT_AB.E1_LOJA " 
    cQuery += " WHERE " 
    cQuery += " PB9_CPOALT = 'Limite' " 
    cQuery += " AND PB9_CPOANT <> PB9_CPODEP " 
    cQuery += " AND PB9_DATA >= '" + DToS(dDtIni) + "' " 
    cQuery += " AND PB9_DATA <= '" + DToS(dDtFim) + "' " 
    cQuery += " AND PB9.D_E_L_E_T_ = '' " 
    cQuery += " AND PB3.D_E_L_E_T_ = '' " 
    cQuery += " AND SA1.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY " 
    cQuery += " PB9_DATA, PB3_CODSA1, PB3_LOJSA1 " 

Return cQuery
/*/{Protheus.doc} getParecer
    Função retorna o parecer do registro.
    @type  Static Function
    @author Everson
    @since 31/08/2020
    @version 01
    /*/
Static Function getParecer(cCli,cLoja,cData)

    //Variáveis.
    Local cParecer := ""
    Local cQuery   := ""

    //
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " PBA_CODMEM  " 
    cQuery += " FROM  " 
    cQuery += " PBA010 (NOLOCK) AS PBA " 
    cQuery += " WHERE  " 
    cQuery += " PBA_CODCLI = '" + cCli + "'  " 
    cQuery += " AND PBA_LOJACL = '" + cLoja + "' " 
    cQuery += " AND PBA_DATA = '" + cData + "' " 
    cQuery += " AND PBA.D_E_L_E_T_ = '' " 

    //
    If Select("D_PAREC") > 0
        D_PAREC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_PAREC"
    DbSelectArea("D_PAREC")
    While ! D_PAREC->(Eof())

        //
        cParecer += StrTran(StrTran(StrTran(AllTrim(MSMM(D_PAREC->PBA_CODMEM)),";"," "),Chr(13)," "),Chr(10)," ")

        D_PAREC->(DbSkip())
    End 
    D_PAREC->(DbCloseArea())

Return cParecer
/*/{Protheus.doc} sldRede
    Função retorna saldo em aberto da rede.
    @type  Static Function
    @author Everson
    @since 31/08/2020
    @version 01
    /*/
Static Function sldRede(cRede,cDt)

    //Variáveis.
    Local nSaldo := 0
    Local cQuery := ""

    //Everson, 03/09/2020, chamado 262.
    cQuery += " SELECT    " 
    cQuery += " SUM(E1_VALOR) - ISNULL(SUM(SE5S.E5_VALOR),0) AS SLDREDE " 
    cQuery += " FROM     " 
    cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1   " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " ( " 
    cQuery += " SELECT " 
    cQuery += " E5_FILIAL, E5_CLIFOR, E5_LOJA, E5_NUMERO, E5_PREFIXO,  " 
    cQuery += " E5_PARCELA, " 
    cQuery += " SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR*-1 ELSE E5_VALOR END) AS E5_VALOR " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("SE5") + "  " 
    cQuery += " WHERE " 
    cQuery += " E5_DATA <= '" + cDt + "' " 
    cQuery += " AND E5_CLIFOR + E5_LOJA IN ( "
    cQuery += " SELECT A1_COD+A1_LOJA FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE A1_CODRED = '" + cRede + "' AND SA1.D_E_L_E_T_ = '' "
    cQuery += " ) "
    cQuery += " AND D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY " 
    cQuery += " E5_FILIAL, E5_CLIFOR, E5_LOJA, E5_NUMERO, E5_PREFIXO, E5_PARCELA " 
    cQuery += " ) AS SE5S ON " 
    cQuery += " E1_FILIAL = SE5S.E5_FILIAL " 
    cQuery += " AND E1_CLIENTE = SE5S.E5_CLIFOR " 
    cQuery += " AND E1_LOJA = SE5S.E5_LOJA " 
    cQuery += " AND E1_NUM = SE5S.E5_NUMERO " 
    cQuery += " AND E1_PREFIXO = SE5S.E5_PREFIXO " 
    cQuery += " AND E1_PARCELA = SE5S.E5_PARCELA " 
    cQuery += " WHERE " 
    cQuery += " E1_TIPO NOT IN ('NCC','RA')  "
    cQuery += " AND E1_EMISSAO <= '" + cDt + "' "  
    cQuery += " AND E1_VENCREA >= '" + cDt + "' " 
    cQuery += " AND (E1_BAIXA = '' OR E1_BAIXA >= '" + cDt + "') " 
    cQuery += " AND D_E_L_E_T_ = ''  " 
    cQuery += " AND E1_CLIENTE + E1_LOJA IN ( "
    cQuery += " SELECT A1_COD+A1_LOJA FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE A1_CODRED = '" + cRede + "' AND SA1.D_E_L_E_T_ = '' "
    cQuery += " ) "
    
    //
    If Select("D_SLDR") > 0
        D_SLDR->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_SLDR"

    //
    DbSelectArea("D_SLDR")
    D_SLDR->(DbGoTop())
    nSaldo := Val(cValToChar(D_SLDR->SLDREDE))
    nSaldo := Iif(nSaldo < 0,0,nSaldo)

    //
    D_SLDR->(DbCloseArea())
    
Return nSaldo
/*/{Protheus.doc} sldVar
    Função retorna saldo em aberto varejo.
    @type  Static Function
    @author Everson
    @since 01/09/2020
    @version 01
    /*/
Static Function sldVar(cCliente,cDt)

    //Variáveis.
    Local nSaldo := 0
    Local cQuery := ""

    //Everson, 03/09/2020, chamado 262.
    cQuery += " SELECT    " 
    cQuery += " SUM(E1_VALOR) - ISNULL(SUM(SE5S.E5_VALOR),0) AS SLDVRJ " 
    cQuery += " FROM     " 
    cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1   " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " ( " 
    cQuery += " SELECT " 
    cQuery += " E5_FILIAL, E5_CLIFOR, E5_LOJA, E5_NUMERO, E5_PREFIXO,  " 
    cQuery += " E5_PARCELA, " 
    cQuery += " SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR*-1 ELSE E5_VALOR END) AS E5_VALOR " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("SE5") + "  " 
    cQuery += " WHERE " 
    cQuery += " E5_DATA <= '" + cDt + "' " 
    cQuery += " AND E5_CLIFOR + E5_LOJA = '" + cCliente + "' "
    cQuery += " AND D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY " 
    cQuery += " E5_FILIAL, E5_CLIFOR, E5_LOJA, E5_NUMERO, E5_PREFIXO, E5_PARCELA " 
    cQuery += " ) AS SE5S ON " 
    cQuery += " E1_FILIAL = SE5S.E5_FILIAL " 
    cQuery += " AND E1_CLIENTE = SE5S.E5_CLIFOR " 
    cQuery += " AND E1_LOJA = SE5S.E5_LOJA " 
    cQuery += " AND E1_NUM = SE5S.E5_NUMERO " 
    cQuery += " AND E1_PREFIXO = SE5S.E5_PREFIXO " 
    cQuery += " AND E1_PARCELA = SE5S.E5_PARCELA " 
    cQuery += " WHERE " 
    cQuery += " E1_CLIENTE + E1_LOJA = '" + cCliente + "' " 
    cQuery += " AND E1_TIPO NOT IN ('NCC','RA')  " 
    cQuery += " AND E1_EMISSAO <= '" + cDt + "' "  
    cQuery += " AND E1_VENCREA >= '" + cDt + "' " 
    cQuery += " AND (E1_BAIXA = '' OR E1_BAIXA >= '" + cDt + "') "
    cQuery += " AND D_E_L_E_T_ = ''  " 
    
    //
    If Select("D_SLDV") > 0
        D_SLDV->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_SLDV"

    //
    DbSelectArea("D_SLDV")
    D_SLDV->(DbGoTop())
    nSaldo := Val(cValToChar(D_SLDV->SLDVRJ))
    nSaldo := Iif(nSaldo < 0,0,nSaldo)

    //
    D_SLDV->(DbCloseArea())
    
Return nSaldo
