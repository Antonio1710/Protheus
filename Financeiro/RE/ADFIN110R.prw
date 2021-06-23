#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} ADFIN110R
    Relatório de Cambio
    @type  Function
    @author Fernando Macieira
    @since 07/04/2021
    @version 01
    @ticket 11199 - Criação Relatório Protheus de Cambio.
/*/
User Function ADFIN110R()

    Local aParamBox := {}
    Local aRet      := {}

    Private dDtIni  := CtoD("//")
    Private dDtFim  := CtoD("//")

	Aadd( aParamBox ,{1,"Dt Emissao de  "   ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    Aadd( aParamBox ,{1,"Dt Emissao ate "   ,CtoD(Space(8)),"" ,'.T.',,'.T.',80,.T.})
    //Aadd( aParamBox ,{1,"Moeda "    ,Space(6),"" ,'.T.',"RELFIN",'.T.',80,.T.,})

	If !ParamBox(aParamBox, "", @aRet,,,,,,,,.T.,.T.)
		Return Nil
	EndIf

    dDtIni := aRet[1]
    dDtFim := aRet[2]

    MsAguarde({|| gerRel() },"Função ADFIN110R ","Gerando relatório... ")
    
Return Nil

/*/{Protheus.doc} ADFIN110R
    Relatório de Cambio
    @type  Function
    @author Fernando Macieira
    @since 07/04/2021
    @version 01
    @ticket 11199 - Criação Relatório Protheus de Cambio.
/*/
Static Function gerRel()

    Local oReport := Nil

	oReport := reptDef()
	oReport:PrintDialog()

Return Nil 

/*/{Protheus.doc} ADFIN110R
    Relatório de Cambio
    @type  Function
    @author Fernando Macieira
    @since 07/04/2021
    @version 01
    @ticket 11199 - Criação Relatório Protheus de Cambio.
/*/
Static Function reptDef()

    Local oReport := Nil
    Local aOrdem  := {}
    
    oReport := TReport():New("RELCAMBIO",OemToAnsi("Relatório Câmbio"), Nil, ;
	{|oReport| repPrint(oReport)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("") +CRLF+;
	OemToAnsi("") )
	
	oCambio := TRSection():New(oReport, OemToAnsi("Relatório Câmbio"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	
    TRCell():New(oCambio,	"E1_FILIAL" ,  "", "Filial"  /*Titulo*/,  /*Picture*/,TamSX3("E1_FILIAL")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_PREFIXO",  "", "Prefixo" /*Titulo*/,  /*Picture*/,TamSX3("E1_PREFIXO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_NUM"    ,  "", "Numero"  /*Titulo*/,  /*Picture*/,TamSX3("E1_NUM")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) 
    TRCell():New(oCambio,	"E1_PARCELA",  "", "Parcela" /*Titulo*/,  /*Picture*/,TamSX3("E1_PARCELA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_CLIENTE",  "", "Cliente" /*Titulo*/,  /*Picture*/,TamSX3("E1_CLIENTE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_LOJA"   ,  "", "Loja"    /*Titulo*/,  /*Picture*/,TamSX3("E1_LOJA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_NOMCLI" ,  "", "Nome Cliente" /*Titulo*/,  /*Picture*/,TamSX3("E1_NOMCLI")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oCambio,	"E1_EMISSAO",  "", "Dt Emissao"   /*Titulo*/,  /*Picture*/,TamSX3("E1_EMISSAO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oCambio,	"E1_VENCTO",   "", "Dt Vencto"    /*Titulo*/,  /*Picture*/,TamSX3("E1_VENCTO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_VENCREA",  "", "Dt Vencrea"   /*Titulo*/,  /*Picture*/,TamSX3("E1_VENCREA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_VALOR"  ,  "", "Valor"        /*Titulo*/, "@E 999,999,999.99"     /*Picture*/,TamSX3("E1_VALOR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_MOEDA"  ,  "", "Moeda"        /*Titulo*/,  /*Picture*/,TamSX3("E1_MOEDA")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_VLCRUZ" ,  "", "Vlr R$"       /*Titulo*/, "@E 999,999,999.99"     /*Picture*/,TamSX3("E1_VLCRUZ")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_SALDO"  ,  "", "Saldo"        /*Titulo*/, "@E 999,999,999.99"     /*Picture*/,TamSX3("E1_SALDO")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"E1_HIST"   ,  "", "Historico"    /*Titulo*/,  /*Picture*/,TamSX3("E1_HIST")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

    TRCell():New(oCambio,	"EEC_STTDES",  "", "Status"    /*Titulo*/,  /*Picture*/,TamSX3("EEC_STTDES")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"EEC_NRODUE",  "", "Nr DUE"    /*Titulo*/,  /*Picture*/,TamSX3("EEC_NRODUE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"EEC_CHVDUE",  "", "Chave DUE" /*Titulo*/,  /*Picture*/,TamSX3("EEC_CHVDUE")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
    TRCell():New(oCambio,	"EEC_DSCDES",  "", "Destino"   /*Titulo*/,  /*Picture*/,TamSX3("Y9_DESCR")[1] /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} ADFIN110R
    Relatório de Cambio
    @type  Function
    @author Fernando Macieira
    @since 07/04/2021
    @version 01
    @ticket 11199 - Criação Relatório Protheus de Cambio.
/*/
Static Function repPrint(oReport)

	Local oCambio := oReport:Section(1)
	Local cQuery  := ""
    Local cEmb    := ""
    Local cEECSTTDES := ""
    Local cEECNRODUE := ""
    Local cEECCHVDUE := ""
    Local cEECDSCDES := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR, E1_MOEDA, E1_VLCRUZ, E1_SALDO, E1_HIST
    cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK) AS SE1
    cQuery += " WHERE E1_FILIAL BETWEEN '' AND 'z'
    cQuery += " AND E1_EMISSAO BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "'
    cQuery += " AND E1_MOEDA<>'1'
    cQuery += " AND SE1.D_E_L_E_T_ = ''
    cQuery += " ORDER BY 5,6,1,8

    tcQuery cQuery New Alias "Work"

    aTamSX3	:= TamSX3("E1_VALOR")
	tcSetField("Work", "E1_VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3	:= TamSX3("E1_VLCRUZ")
	tcSetField("Work", "E1_VLCRUZ", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3	:= TamSX3("E1_SALDO")
	tcSetField("Work", "E1_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )
    oReport:SetMeter(Contar("Work","!EOF()"))

    oCambio:Init()
    
    Work->( dbGoTop() )
    Do While Work->( !EOF() )

        cEECSTTDES := ""
        cEECNRODUE := ""
        cEECCHVDUE := ""
        cEECDSCDES := ""

        cEmb := AllTrim(Subs(AllTrim(Work->E1_HIST),6,TamSX3("EEC_PREEMB")[1]))

        EEC->( dbSetOrder(1) ) // EEC_FILIAL, EEC_PREEMB, R_E_C_N_O_, D_E_L_E_T_
        If EEC->( dbSeek(Work->E1_FILIAL+PadR(cEmb,TamSX3("EEC_PREEMB")[1])) )
            
            cEECSTTDES := EEC->EEC_STTDES
            cEECNRODUE := EEC->EEC_NRODUE
            cEECCHVDUE := EEC->EEC_CHVDUE
            cEECDSCDES := Posicione("SY9",1,FWxFilial("SY9")+EEC->EEC_DEST,"Y9_DESCR")

        EndIf

        oReport:IncMeter() 
        
        If oReport:Cancel()
            oReport:PrintText(OemToAnsi("Cancelado"))
            Exit
        EndIf
        
        oCambio:Cell("E1_FILIAL"):SetBlock( {|| Work->E1_FILIAL } )
        oCambio:Cell("E1_PREFIXO"):SetBlock( {|| Work->E1_PREFIXO } )
        oCambio:Cell("E1_NUM"):SetBlock( {|| Work->E1_NUM } ) 
        oCambio:Cell("E1_PARCELA"):SetBlock( {|| Work->E1_PARCELA } )
        oCambio:Cell("E1_CLIENTE"):SetBlock( {|| Work->E1_CLIENTE } )          
        oCambio:Cell("E1_LOJA"):SetBlock( {|| Work->E1_LOJA } )
        oCambio:Cell("E1_NOMCLI"):SetBlock( {|| Work->E1_NOMCLI } )
        oCambio:Cell("E1_EMISSAO"):SetBlock( {|| DtoC(StoD(Work->E1_EMISSAO)) } )
        oCambio:Cell("E1_VENCTO"):SetBlock( {|| DtoC(StoD(Work->E1_VENCTO)) } )
        oCambio:Cell("E1_VENCREA"):SetBlock( {|| DtoC(StoD(Work->E1_VENCREA)) } )
        oCambio:Cell("E1_VALOR"):SetBlock( {|| Work->E1_VALOR } )
        oCambio:Cell("E1_MOEDA"):SetBlock( {|| Work->E1_MOEDA } )
        oCambio:Cell("E1_VLCRUZ"):SetBlock( {|| Work->E1_VLCRUZ } )
        oCambio:Cell("E1_SALDO"):SetBlock( {|| Work->E1_SALDO } )
        oCambio:Cell("E1_HIST"):SetBlock( {|| Work->E1_HIST } )

        oCambio:Cell("EEC_STTDES"):SetBlock( {|| cEECSTTDES } )
        oCambio:Cell("EEC_NRODUE"):SetBlock( {|| cEECNRODUE } )
        oCambio:Cell("EEC_CHVDUE"):SetBlock( {|| cEECCHVDUE } )
        oCambio:Cell("EEC_DSCDES"):SetBlock( {|| cEECDSCDES } )

        oCambio:PrintLine()

        Work->( dbSkip() )
        
    EndDo

    oCambio:Finish()

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return Nil
