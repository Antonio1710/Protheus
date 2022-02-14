#Include "Protheus.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} ADFIN095R
    Relatório de fechamento de receitas financeiras.
    Chamado 424.
    @type  Function
    @author Everson
    @since 18/09/2020
    @version 01
    /*/
User Function ADFIN095R() // U_ADFIN095R()

    //Variáveis.
    Local aArea     := GetArea()
    Local aParamBox := {}
    Local aRet      := {}

    //
	Aadd( aParamBox ,{1,"Data base " ,CtoD(space(8)),""    ,".T."       ,"",".T.",80,.T.})
    Aadd( aParamBox ,{1,"Prazo "     ,180,"@E 999,999,999" ,"Positivo()","",".T.",80,.F.})
	
	//
	If ! ParamBox(aParamBox, "Informe os Parâmetros", @aRet,,,,,,,,.T.,.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf

    //
    MsAguarde({|| gerRel(aRet[1]-aRet[2]) },"Função ADFIN095R(ADFIN095R)","Gerando relatório...")

    //
    RestArea(aArea)

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de fechamento de receitas financeiras.')

    
Return Nil
/*/{Protheus.doc} gerRel
    Processa a geração do relatório.
    @type  Static Function
    @author Everson
    @since 18/09/2020
    @version 01
    /*/
Static Function gerRel(dData)

    //Variáveis.
    Local aArea   := GetArea()
    Local oReport := Nil

    //
	oReport := reptDef(dData)
	oReport:PrintDialog()

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} reptDef
    Definição do TReport.
    @type  Static Function
    @author Everson
    @since 18/09/2020
    @version 01
    /*/
Static Function reptDef(dData)

    //Variáveis.
    Local oReport := Nil
    Local aOrdem  := {}
    
    //
    oReport := TReport():New("ADFIN095R",OemToAnsi("Relatório de Receitas Financeiras"), Nil, ;
	{|oReport| repPrint(oReport,dData)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("") +CRLF+;
	OemToAnsi("") )
	
    //
	oLimSec := TRSection():New(oReport, OemToAnsi("Relatório de Receitas Financeiras"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
    //
	TRCell():New(oLimSec,	"FIL",   "","Filial"    /*Titulo*/,                        /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"TIPO",  "","Tipo"      /*Titulo*/,                        /*Picture*/,05 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"NUM",   "","Número"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"COD",   "","Cod"       /*Titulo*/,                        /*Picture*/,06 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"LOJA",  "","Loja"      /*Titulo*/,                        /*Picture*/,02 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"NOME",  "","Nome"      /*Titulo*/,                        /*Picture*/,25 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"EMISS", "","Emissão"   /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oLimSec,	"VENC",  "","Vencto"    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"VLR",   "","Valor"     /*Titulo*/,"@E 999,999,999.99"     /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oLimSec,	"SLD",   "","Saldo"     /*Titulo*/,"@E 999,999,999.99"     /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport
/*/{Protheus.doc} repPrint
    Impressão do TReport.
    @type  Static Function
    @author Everson
    @since 18/09/2020
    @version 01
    /*/
Static Function repPrint(oReport,dData)

    //Variáveis.
	Local oLimSec := oReport:Section(1)
	Local cQuery  := scptSql(dData)

    //
    If Select("D_REL") > 0
        D_REL->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_REL"
    DbSelectArea("D_REL")
    D_REL->(DbGoTop())
	
    //
	D_REL->(DbGoTop())
	Do While D_REL->(!EOF())

        //
		oLimSec:Init()
		
        //
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit

		EndIf
	
		//
		oLimSec:Cell("FIL"):SetBlock({|| D_REL->E1_FILIAL } )
		oLimSec:Cell("TIPO"):SetBlock( {|| D_REL->E1_TIPO } )
        oLimSec:Cell("NUM"):SetBlock(  {|| D_REL->E1_NUM} )
        oLimSec:Cell("COD"):SetBlock(  {|| D_REL->E1_CLIENTE} )
        oLimSec:Cell("LOJA"):SetBlock(  {|| D_REL->E1_LOJA} )
        oLimSec:Cell("NOME"):SetBlock(  {|| D_REL->E1_NOMCLI} )
        oLimSec:Cell("EMISS"):SetBlock( {|| DToC(SToD(D_REL->E1_EMISSAO)) } )
		oLimSec:Cell("VENC"):SetBlock( {||DToC(SToD(D_REL->E1_VENCREA)) } )
		oLimSec:Cell("VLR"):SetBlock( {|| D_REL->E1_VALOR} )
		oLimSec:Cell("SLD"):SetBlock( {|| D_REL->E1_SALDO} )
    
        //
		oLimSec:PrintLine()

        //
		D_REL->(DbSkip())
		
	Enddo
	
    //
	oLimSec:Finish()
	
    //
	D_REL->(dbCloseArea())

Return Nil
/*/{Protheus.doc} sctSql
    Função retorna script sql.
    @type  Static Function
    @author Everson
    @since 18/09/2020
    @version 01
    /*/
Static Function scptSql(dData)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NATUREZ,  " 
    cQuery += " E1_PORTADO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO,  " 
    cQuery += " E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_VEND1,  " 
    cQuery += " E1_HIST " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1 " 
    cQuery += " WHERE  " 
    cQuery += " SE1.D_E_L_E_T_= '' " 
    cQuery += " AND SE1.E1_SALDO > 0  " 
    cQuery += " AND SE1.E1_VENCREA < '" + DToS(dData) + "' " 
    cQuery += " AND SE1.E1_TIPO In ('NCC','RA ') " 
    cQuery += " ORDER BY E1_TIPO,  E1_VENCREA "
    
Return cQuery
