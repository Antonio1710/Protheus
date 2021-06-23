#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F370CTBUSR
    Contabilização das baixas de AB-
    @type Function
    @author Fernando Macieira
    @since 04/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 053791 - FWNM          - 10/12/2019 - OS 055181 || CONTROLADORIA || || 8441 || DESCONTOS DUPLICADOS
    @history chamado 054200 - FWNM          - 16/12/2019 - OS 055595 || CONTROLADORIA || CRISTIANE_MELO || 8441 || CONTABILIZACAO AB-
    @history chamado 054283 - FWNM          - 18/12/2019 - OS 055697 || CONTROLADORIA || CRISTIANE_MELO || 8441 || CONTABILIZACAO
    @history ticket  451    - FWNM          - 27/08/2020 - CONTABILIZAÇÃO AB- (DUPLICIDADE)
    @history ticket  452    - FWNM          - 27/08/2020 - RCONCCLI
    @history ticket  3731   - William Costa - 29/10/2020 - Identificado que o Saldo do Ab- pode estar zerado, mais o Saldo do Titulo Principal, faltando por exemplo 0,01 centavo para a baixa, então foi feito uma dupla validaçaõ no Select para verificar se o titulo principal, também está zerado para aí fazer a contabilização do Ab-
    @history ticket  7868   - Leonardo P. Monteiro - 11/01/2021 - Correção na função ABIsDuplic para desconsiderar arquivos deletados na tabela CT2.
    @history ticket  7868   - Leonardo P. Monteiro - 13/01/2021 - Correção/ajuste na consulta aos títulos para considerar somente os títulos com as últimas baixas dentro do período selecionado pelo parâmetro de contabilização.
    @history ticket  7868   - Leonardo P. Monteiro - 18/01/2021 - Quando ocorre mais de um estorno ou exclusão ele não considera os novos registros na contabilidade.
    @history ticket  7868   - Leonardo P. Monteiro - 25/01/2021 - Ajustes no fonte e correção da mensagem de alerta. Ajuste e lógica na consulta de duplicidades.
    @history ticket  9118   - Leonardo P. Monteiro - 08/02/2021 - Reformulação da rotina de contabilização de abatimentos em substituição ao ponto de entrada F370CTBUSR.
/*/
User Function F370CTBUSR()

    if SupergetMV("MV_#F370HA",,.F.) 
        
        //msAguarde( { || StartJob("u_RunF370CTB", GetEnvServer(), .T., cEmpAnt, cFilAnt ) }, "Aguarde", "Gerando indexadores das baixas AB- contabilizadas..." )
        if msgYesNo("Deseja contabilizar os títulos do tipo Abatimento(AB-)?")
            msAguarde( {|| RunF370CTB() },"Contabilizando","(AB-) e seus indexadores..." )
        endif
    
    endif
    
Return

/*/{Protheus.doc} Static Function RunF370CTB
    Contabilização das baixas de AB-
    @type Static Function
    @author FWNM
    @since 18/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunF370CTB()
    
    //Local nHdlImp
    Local cArquivo
    Local cQuery  := ""
    Local aStru   := {}
    Local cPadrao := ""
    Local lPadrao := .t.
    Local lHead	  := .F.					// Ja montou o cabecalho?
    Local nTotal  := 0
    Local nHdlPrv := 0
    Local nBytes  := 0
    Local cLote   := "008850"
    Local lDigita := .f.
    Local lAglut  := .F.
    Local dDtBx   := CtoD("//")
    Local aTabRecOri := {}
    Local aDiario    := {}
    Local aFlagCTB   := {}
    Local lUsaFlag	 := .T. // SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
    Local cPrograma  := "F370CTBUSR"
    Local lPosiciona := .T.
    Local cSequen    := ""
    Local nI

    cQuery  := ""
    aStru   := SE1->( dbStruct() )
    cPadrao := GetMV("MV_#CTBAB-",,"AB-")
    lPadrao := VerPadrao(cPadrao)
    lHead	:= .F.					// Ja montou o cabecalho?
    nTotal  := 0
    nHdlPrv := 0
    nBytes  := 0
    cLote   := "008850"
    lDigita := Iif(MV_PAR01==1,.T.,.F.)
    lAglut  := .F.
    dDtBx   := CtoD("//")
    
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    //Ticket  7868   - Leonardo P. Monteiro - 13/01/2021 - Correção da consulta ao banco.
    cQuery := " SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, SE1.RECNO, SE1.E5_DTDISPO "
    cQuery += " FROM (SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1.R_E_C_N_O_ RECNO, MAX(E5_DTDISPO) E5_DTDISPO  "
    cQuery += "       FROM " + RetSqlName("SE1") + " E1 (NOLOCK) INNER JOIN " + RetSqlName("SE5") + " E5 (NOLOCK) ON E1.D_E_L_E_T_='' AND E5.D_E_L_E_T_='' AND E5.E5_FILIAL=E1.E1_FILIAL AND E5.E5_PREFIXO=E1.E1_PREFIXO AND E5.E5_NUMERO=E1.E1_NUM AND E5.E5_PARCELA=E1.E1_PARCELA AND E5.E5_CLIFOR=E1.E1_CLIENTE AND E5.E5_LOJA=E1.E1_LOJA AND E5.E5_SITUACA='' AND E5.E5_RECPAG='R' "
    cQuery += "       WHERE E1.D_E_L_E_T_='' AND E1.E1_FILIAL BETWEEN '' AND 'ZZ' AND E5.E5_DTDISPO >= '"+DtoS(MV_PAR04)+"' AND E1_LA<>'S' AND E1_TIPO='AB-' AND E1_SALDO=0 "
    cQuery += "       GROUP BY E1.E1_FILIAL, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_CLIENTE, E1.E1_LOJA, E1.E1_VALOR, E1.R_E_C_N_O_ ) SE1 "
    cQuery += " WHERE SE1.E5_DTDISPO BETWEEN '"+DtoS(MV_PAR04)+"' AND '"+DtoS(MV_PAR05)+"' "
    cQuery += " AND (SELECT TOP(1) E1_SALDO "
    cQuery += "      FROM " + RetSqlName("SE1") + " (NOLOCK)  SE1_TITPRINCIPAL "
    cQuery += "      WHERE SE1_TITPRINCIPAL.E1_FILIAL  = SE1.E1_FILIAL AND SE1_TITPRINCIPAL.E1_PREFIXO = SE1.E1_PREFIXO AND SE1_TITPRINCIPAL.E1_NUM     = SE1.E1_NUM AND SE1_TITPRINCIPAL.E1_PARCELA = SE1.E1_PARCELA AND SE1_TITPRINCIPAL.E1_CLIENTE = SE1.E1_CLIENTE AND SE1_TITPRINCIPAL.E1_LOJA    = SE1.E1_LOJA AND SE1_TITPRINCIPAL.E1_TIPO    <> 'AB-' AND SE1_TITPRINCIPAL.D_E_L_E_T_ = '' ) = 0 "
    cQuery += " ORDER BY 10 "

    //Ticket  7868   - Leonardo P. Monteiro - 13/01/2021 - Correção da consulta ao banco.
    /*
        cQuery := " SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, SE1.R_E_C_N_O_ RECNO, MAX(E5_DTDISPO) E5_DTDISPO
    cQuery += " FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) 
    cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 (NOLOCK) ON E5_FILIAL=E1_FILIAL AND E5_PREFIXO=E1_PREFIXO AND E5_NUMERO=E1_NUM AND E5_PARCELA=E1_PARCELA AND E5_CLIFOR=E1_CLIENTE AND E5_LOJA=E1_LOJA AND E5_SITUACA='' AND E5_RECPAG='R' AND SE5.D_E_L_E_T_='' 
    cQuery += " WHERE E1_FILIAL BETWEEN '' AND 'ZZ' 
    cQuery += " AND E5_DTDISPO BETWEEN '"+DtoS(MV_PAR04)+"' AND '"+DtoS(MV_PAR05)+"'
    cQuery += " AND E1_TIPO='AB-' 
    cQuery += " AND E1_SALDO=0 
    cQuery += " AND (SELECT TOP(1) E1_SALDO FROM SE1010 SE1_TITPRINCIPAL WHERE SE1_TITPRINCIPAL.E1_FILIAL  = SE1.E1_FILIAL AND SE1_TITPRINCIPAL.E1_PREFIXO = SE1.E1_PREFIXO AND SE1_TITPRINCIPAL.E1_NUM     = SE1.E1_NUM AND SE1_TITPRINCIPAL.E1_PARCELA = SE1.E1_PARCELA AND SE1_TITPRINCIPAL.E1_CLIENTE = SE1.E1_CLIENTE AND SE1_TITPRINCIPAL.E1_LOJA    = SE1.E1_LOJA AND SE1_TITPRINCIPAL.E1_TIPO    <> 'AB-' AND SE1_TITPRINCIPAL.D_E_L_E_T_ = '' ) = 0
    cQuery += " AND E1_LA<>'S' 
    cQuery += " AND SE1.D_E_L_E_T_='' 
    cQuery += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, SE1.R_E_C_N_O_
    cQuery += " ORDER BY 10

    */

    tcQuery cQuery New Alias "Work"

    For nI := 1 TO LEN(aStru)
        If aStru[nI][2] != "C"
            tcSetField("Work", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
        EndIf
    Next

	aTamSX3 := TamSX3("E5_DTDISPO")
	tcSetField("Work", "E5_DTDISPO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )

    //dDtBx := Work->E1_XDTDISP // @history ticket 452 - FWNM - 27/08/2020 - RCONCCLI
    dDtBx := Work->E5_DTDISPO //UpE5DISPO()

    Do While Work->( !EOF() )

        // @history ticket 451 - FWNM - 27/08/2020 - CONTABILIZAÇÃO AB- (DUPLICIDADE)
        If ABIsDuplic()
            Work->( dbSkip() )
            Loop
        EndIf
        //

        SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA
        SA1->( dbSeek( FWxFilial("SA1")+Work->(E1_CLIENTE+E1_LOJA) ))

        SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
        If SE1->( dbSeek(Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))

            If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
                aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
            Endif

            aDiario := {{"SE1",SE1->(recno()),SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"}}

            aTabRecOri := { 'SE1', SE1->( RECNO() ) }

            // @history ticket 452 - FWNM - 28/08/2020
            If Empty(SE1->E1_XDTDISP)
                RecLock("SE1", .f.)
                    SE1->E1_XDTDISP := Work->E5_DTDISPO
                SE1->( msUnLock() )
            EndIf
            //

        EndIf

        If lPadrao

            //If dDtBx <> Work->E1_XDTDISP
            If dDtBx <> Work->E5_DTDISPO //UpE5DISPO()

                cSequen := CTK->CTK_SEQUEN

                RodaProva(nHdlPrv,nTotal)

                //cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
                cA100Incl( cArquivo,;
                    nHdlPrv,;
                    3 /*nOpcx*/,;
                    cLote,;
                    lDigita,;
                    lAglut,;
                /*cOnLine*/,;
                    dDtBx,;
                    dDtBx,;
                    @aFlagCTB,;
                /*aDadosProva*/,;
                /*aDiario*/ )

                aFlagCTB := {}
                aDiario  := {}
                lHead  := .F.
                nTotal := 0

                // Gera indexadores - Chamado n. 053791 || OS 055181 || CONTROLADORIA || || 8441 || DESCONTOS DUPLICADOS - fwnm - 10/12/2019
                UpIndex(cSequen)

            EndIf

            If !lHead
                lHead := .T.
                nHdlPrv := HeadProva(cLote,cPrograma,Substr(cUsuario,7,6),@cArquivo)
            EndIf

            // nTotal += DetProva(nHdlPrv,cPadrao,"F370CTBUSR",cLote)
            nTotal += DetProva( nHdlPrv,;
                cPadrao,;
                cPrograma,;
                cLote,;
                0 /*nLinha*/,;
                .T. /*lExecuta*/,;
                cPrograma /*cCriterio*/,;
            /*lRateio*/,;
            /*cChaveBusca*/,;
            /*aCT5*/,;
                lPosiciona,;
                @aFlagCTB,;
                aTabRecOri,;
            /*aDadosProva*/ )

        EndIf

        //dDtBx := Work->E1_XDTDISP // @history ticket 452 - FWNM - 27/08/2020 - RCONCCLI
        dDtBx := Work->E5_DTDISPO //UpE5DISPO()

        Work->( dbSkip() )

    EndDo

    If lHead

        cSequen := CTK->CTK_SEQUEN

        RodaProva(nHdlPrv,nTotal)

        //cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
        cA100Incl( cArquivo,;
            nHdlPrv,;
            3 /*nOpcx*/,;
            cLote,;
            lDigita,;
            lAglut,;
        /*cOnLine*/,;
            dDtBx,;
            dDtBx,;
            @aFlagCTB,;
        /*aDadosProva*/,;
        /*aDiario*/ )

        aFlagCTB := {}
        aDiario  := {}

        // Gera indexadores - Chamado n. 053791 || OS 055181 || CONTROLADORIA || || 8441 || DESCONTOS DUPLICADOS - fwnm - 10/12/2019
        UpIndex(cSequen)

    Endif

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} Static Function UpIndex
    Grava indexadores na tabela CT2 nos campos customizados
    @type  Static Function
    @author FWNM
    @since 10/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 053791
/*/
Static Function UpIndex(cSequen)

    Local cQuery   := ""
    Local aAreaSE1 := SE1->( GetArea() )
    Local aAreaCT2 := CT2->( GetArea() )
    Local aStru    := CV3->( dbStruct() )
    Local nI

    If Select("WorkCV3")
        WorkCV3->( dbCloseArea() )
    EndIf

    cQuery := " SELECT CV3_RECORI, CV3_RECDES, CV3_SEQUEN, CV3_VLR01
    cQuery += " FROM " + RetSqlName("CV3") + " (NOLOCK)
    cQuery += " WHERE CV3_FILIAL='"+FWxFilial("CV3")+"'
    cQuery += " AND CV3_DTSEQ='"+DtoS(dDataBase)+"'
    cQuery += " AND CV3_SEQUEN='"+cSequen+"'
    cQuery += " AND CV3_TABORI='SE1'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkCV3"

    For nI := 1 TO LEN(aStru)
        If aStru[nI][2] != "C"
            tcSetField("WorkCV3", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
        EndIf
    Next

    WorkCV3->( dbGoTop() )
    Do While WorkCV3->( !EOF() )

        // Posiciono no SE1
        dbSelectArea("SE1")
        dbGoTo( Val(WorkCV3->CV3_RECORI) )

        // Posiciono no CT2
        dbSelectArea("CT2")
        dbGoTo( Val(WorkCV3->CV3_RECDES) )

        // @history ticket 451 - FWNM - 27/08/2020
        If CT2->( !EOF() ) .and. CT2->CT2_SEQUEN==WorkCV3->CV3_SEQUEN .and. CT2->(RecNo())==Val(WorkCV3->CV3_RECDES) .and. SE1->(RECNO())==Val(WorkCV3->CV3_RECORI) .and. CT2->CT2_VALOR==WorkCV3->CV3_VLR01

            RecLock("CT2", .f.)
                CT2->CT2_FILKEY := SE1->E1_FILIAL
                CT2->CT2_PREFIX := SE1->E1_PREFIXO
                CT2->CT2_NUMDOC := SE1->E1_NUM
                CT2->CT2_PARCEL := SE1->E1_PARCELA
                CT2->CT2_TIPODC := SE1->E1_TIPO
                CT2->CT2_CLIFOR := SE1->E1_CLIENTE
                CT2->CT2_LOJACF := SE1->E1_LOJA
            CT2->( msUnLock() )

        EndIf

        WorkCV3->( dbSkip() )

    EndDo

    If Select("WorkCV3")
        WorkCV3->( dbCloseArea() )
    EndIf

    RestArea( aAreaSE1 )
    RestArea( aAreaCT2 )

Return

/*/{Protheus.doc} Static Function ABIsDuplic
    Checa se o AB- já está contabilizado
    @type  Static Function
    @author FWNM
    @since 27/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 451
/*/
Static Function ABIsDuplic()

    Local lDuplic  := .f.
    Local cQuery   := ""
    Local aAreaAtu := GetArea()
    Local aAreaCV3 := CV3->( GetArea() )
    Local aAreaCT2 := CT2->( GetArea() )
    Local aAreaSE1 := SE1->( GetArea() )

    //Ticket  7868   - Leonardo P. Monteiro - 25/01/2021 - Quando ocorre mais de um estorno ou exclusão ele não considera os novos registros na contabilidade.
    //                                                      Ajuste na consulta e correção de lógica.
    cQuery := " SELECT COUNT(*) CONTADOR "
    cQuery += " FROM "+ Retsqlname("CV3") +" CV3 (NOLOCK) INNER JOIN "+ RetSqlname("CT2") +" CT2 (NOLOCK) ON CT2.CT2_SEQUEN=CV3.CV3_SEQUEN AND CT2.R_E_C_N_O_=CV3.CV3_RECDES "
	cQuery += " WHERE CT2.D_E_L_E_T_='' AND CV3.D_E_L_E_T_='' AND CV3.CV3_FILIAL='"+ FWxFilial("CV3") +"' AND CV3.CV3_TABORI='SE1' AND CV3.CV3_RECORI='"+ AllTrim(Str(Work->RECNO)) +"'; "
    
    TcQuery cQuery ALIAS "QCV3" NEW

    if QCV3->(!EOF())
        IF QCV3->CONTADOR <> 0
            lDuplic := .T.
        ENDIF
    endif
    
    QCV3->(Dbclosearea())

    /* Ticket  7868   - Leonardo P. Monteiro - 18/01/2021 - Quando ocorre mais de um estorno ou exclusão ele não considera os novos registros na contabilidade.
    CV3->( dbSetOrder(3) ) // CV3_FILIAL, CV3_TABORI, CV3_RECORI, CV3_RECDES, R_E_C_N_O_, D_E_L_E_T_
    If CV3->( dbSeek(FWxFilial("CV3")+"SE1"+PadR(AllTrim(Str(Work->RECNO)),TamSX3("CV3_RECORI")[1])) )

        dbSelectArea("CT2")
        dbGoTo( Val(CV3->CV3_RECDES) )

        lDuplic := .f.
        //Ticket  7868   - Leonardo P. Monteiro - 11/01/2021 - Correção na função ABIsDuplic para desconsiderar arquivos deletados na tabela CT2.
        If CT2->( !EOF() ) .and. CT2->(!deleted()) .and. CT2->CT2_SEQUEN==CV3->CV3_SEQUEN .and. CT2->CT2_DTCV3==CV3->CV3_DTSEQ .and. CT2->(RecNo())==Val(CV3->CV3_RECDES) .and. Work->RECNO==Val(CV3->CV3_RECORI) .and. CT2->CT2_VALOR==CV3->CV3_VLR01
        //If CT2->( !EOF() ) .and. CT2->CT2_SEQUEN==CV3->CV3_SEQUEN .and. CT2->CT2_DTCV3==CV3->CV3_DTSEQ .and. CT2->(RecNo())==Val(CV3->CV3_RECDES) .and. Work->RECNO==Val(CV3->CV3_RECORI) .and. CT2->CT2_VALOR==CV3->CV3_VLR01
            lDuplic := .t.
        EndIf

    EndIf
    */

    // @history ticket 452 - FWNM - 28/08/2020
    SE1->( dbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
    If SE1->( dbSeek(Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))

        If Empty(SE1->E1_XDTDISP)
            RecLock("SE1", .f.)
                SE1->E1_XDTDISP := Work->E5_DTDISPO
            SE1->( msUnLock() )
        EndIf
    
    EndIf
    
    RestArea( aAreaSE1 )
    RestArea( aAreaCV3 )
    RestArea( aAreaCT2 )
    RestArea( aAreaAtu )

Return lDuplic

/*/{Protheus.doc} Static Function UpE5DISPO
    Busca E5_DTDISPO do título AB- baixado
    @type  Static Function
    @author FWNM
    @since 27/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 452
/*/
/*
Static Function UpE5DISPO()

    Local cQuery  := ""
    Local dDtBxE5 := CtoD("//")

    If Select("WorkE5") > 0
        WorkE5->( dbCloseArea() )
    EndIf

    cQuery := " SELECT MAX(E5_DTDISPO) E5_DTDISPO
    cQuery += " FROM " + RetSqlName("SE5") + " SE5 (NOLOCK)
    cQuery += " WHERE E5_FILIAL='"+Work->E1_FILIAL+"'
    cQuery += " AND E5_PREFIXO='"+Work->E1_PREFIXO+"'
    cQuery += " AND E5_NUMERO='"+Work->E1_NUM+"'
    cQuery += " AND E5_PARCELA='"+Work->E1_PARCELA+"'
    cQuery += " AND E5_CLIFOR='"+Work->E1_CLIENTE+"'
    cQuery += " AND E5_LOJA='"+Work->E1_LOJA+"'
    cQuery += " AND E5_RECPAPG='R'
    cQuery += " AND E5_SITUACA=''
    cQuery += " AND D_E_L_E_T_=''
    
    tcQuery cQuery New Alias "WorkE5"

	aTamSX3 := TamSX3("E5_DTDISPO")
	tcSetField("WorkE5", "E5_DTDISPO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    dDtBxE5 := WorkE5->E5_DTDISPO

    If Select("WorkE5") > 0
        WorkE5->( dbCloseArea() )
    EndIf

Return dDtBxE5
*/
