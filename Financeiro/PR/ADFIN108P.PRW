#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADFIN108P (F370CTBUSR)
    ContabilizaÃ§Ã£o das baixas de AB-. ReformulaÃ§Ã£o do ponto de entrada F370CTBUSR.
    @type Function
    @author Fernando Macieira (Leonardo P. Monteiro)
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
    @history ticket  451    - FWNM          - 27/08/2020 - CONTABILIZAÃ‡ÃƒO AB- (DUPLICIDADE)
    @history ticket  452    - FWNM          - 27/08/2020 - RCONCCLI
    @history ticket  3731   - William Costa - 29/10/2020 - Identificado que o Saldo do Ab- pode estar zerado, mais o Saldo do Titulo Principal, faltando por exemplo 0,01 centavo para a baixa, entÃ£o foi feito uma dupla validaÃ§aÃµ no Select para verificar se o titulo principal, tambÃ©m estÃ¡ zerado para aÃ­ fazer a contabilizaÃ§Ã£o do Ab-
    @history ticket  7868   - Leonardo P. Monteiro - 11/01/2021 - CorreÃ§Ã£o na funÃ§Ã£o ABIsDuplic para desconsiderar arquivos deletados na tabela CT2.
    @history ticket  7868   - Leonardo P. Monteiro - 13/01/2021 - CorreÃ§Ã£o/ajuste na consulta aos tÃ­tulos para considerar somente os tÃ­tulos com as Ãºltimas baixas dentro do perÃ­odo selecionado pelo parÃ¢metro de contabilizaÃ§Ã£o.
    @history ticket  7868   - Leonardo P. Monteiro - 18/01/2021 - Quando ocorre mais de um estorno ou exclusÃ£o ele nÃ£o considera os novos registros na contabilidade.
    @history ticket  7868   - Leonardo P. Monteiro - 25/01/2021 - Ajustes no fonte e correÃ§Ã£o da mensagem de alerta. Ajuste e lÃ³gica na consulta de duplicidades.
    @history ticket  9118   - Leonardo P. Monteiro - 08/02/2021 - Reformulação da rotina de contabilização de abatimentos em substituição ao ponto de entrada F370CTBUSR.
    @history ticket  9118   - Leonardo P. Monteiro - 08/02/2021 - Ajustes na validação de títulos compilados em duplicidade.
    @history ticket 10355   - Leonardo P. Monteiro - 22/03/2021 - Implementada a tratativa para o estorno das contabilizações de títulos cancelados/excluídos do tipo 'AB-' e que já tenham sido contabilizado.
    @history ticket 10355   - Leonardo P. Monteiro - 25/03/2021 - Ajuste na data da contabilização para o dia em que a rotina está sendo executada, conforme pedido da Jade.
    @history ticket 13678   - Leonardo P. Monteiro - 12/05/2021 - Tratamento dos cancelamentos de baixas dos títulos AB- para uma nova contabilização.
    @history ticket 15279   - Fernando Macieira    - 02/07/2021 - Mensagem de duplicidade em todos os títulos
    @history ticket 17717   - Fernando Macieira    - 12/07/2021 - Verificação de lote sem contabilização AB-
/*/
User Function ADFIN108P()

    // @history ticket 17717   - Fernando Macieira    - 12/07/2021 - Verificação de lote sem contabilização AB-
    Local nOpca     := 0
    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'Contabilização AB-'
    Local clDesc1   := 'Esta rotina oferece 2 funções: '
    Local clDesc2   := '- Contabilizar AB-'
    Local clDesc3   := '- Excluir contabilizações AB-'
    Local clDesc4   := ''
    Local clDesc5   := ''
    Local cHoraIni  := Time()
    Local cTmpTt    := ""
    Local lRet      := .t.

    // Mensagens de Tela Inicial
    aAdd(alSay, clDesc1)
    aAdd(alSay, clDesc2)
    aAdd(alSay, clDesc3)
    aAdd(alSay, clDesc4)
    aAdd(alSay, clDesc5)

    // Botoes do Formatch
    AADD(alButton, {15,.T., {|| nOpca:=15, ProcLogView(cFilAnt,"ADFIN108P") }})
    aAdd(alButton, {1, .T., {|| nOpca:=1, lOk := .T., FechaBatch()}})
    aAdd(alButton, {3, .T., {|| nOpca:=2, lOk := .T., FechaBatch()}})

    FormBatch(clTitulo, alSay, alButton)

    If lOk

        // Garanto uma única thread sendo executada
        If !LockByName("ADFIN108P", .T., .F.)
            Aviso("Atenção", "Existe outro processamento sendo executado! Verifique com seu colega de trabalho...", {"OK"}, 3)
            Return
        EndIf
        
        cHoraIni := Time()
    
        If nOpca == 1
            msAguarde( {|| RunCtbAB() },"Contabilizando","(AB-) e seus indexadores..." )
        ElseIf nOpca == 2
            msAguarde( { || lRet := FixAB() }, "Restaurando contabilizações AB- do período..." )
        EndIf

        //³Destrava a rotina para o usuário
    	UnLockByName("ADFIN108P")

        cTmpTt := ElapTime( cHoraIni, Time() )

        If nOpca==2
            If lRet
                msgInfo("Restauração finalizada com sucesso - Tempo total: " + cTmpTt)
            Else
                Alert("Restauração não realizada! Verifique...")
            EndIf
        EndIf

        If nOpca==1
            msgInfo("Contabilização finalizada - Tempo total: " + cTmpTt)
        EndIf
        
    EndIf
 
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ContabilizaÃ§Ã£o das baixas de AB-')

Return

/*/{Protheus.doc} Static Function RunF370CTB
    ContabilizaÃ§Ã£o das baixas de AB-
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
Static Function RunCtbAB()
    
    //Local nHdlImp
    Local aCabec    := {}
    Local aDados    := {}
    Local aRet      := {}
    Local aParamBox := {}
    Local nDados    := 0
    Local aArea     := GetArea()
    
    aAdd(aParamBox,{1,"Data Inicial",Ctod(Space(8)),"","","","",50,.F.})
    aAdd(aParamBox,{1,"Data Final"  ,Ctod(Space(8)),"","","","",50,.F.})

    if ParamBox(aParamBox,"Contabilização AB-",@aRet)

        nDados := fexecSQL(@aDados,@aCabec)

        if nDados > 0
            fContab(aDados,aCabec)
        endif
        
        fProcExc()

        if nDados > 0
            Msginfo("Não existe registro a serem processados!")
        endif
    endif
    
    
    RestArea(aArea)
Return

/*/{Protheus.doc} Static Function fProcExc
    Consulta e processa os itens excluídos.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 22/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fProcExc()
    Local dDtTmp   := Stod("")
    Local aLanc     := {}
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT CT2.CT2_FILIAL, CT2.CT2_DATA, CT2.CT2_LOTE, CT2.CT2_SBLOTE, CT2.CT2_DOC, CT2.CT2_LINHA, CT2.CT2_DC, CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_VALOR, CT2.CT2_HIST, CT2.CT2_CCD, CT2.CT2_CCC, CT2.CT2_ITEMD, CT2.CT2_ITEMC, "+cEOL
	cQuery += "         CT2.CT2_MOEDLC, CT2.CT2_ORIGEM, CT2.CT2_ROTINA, CT2.CT2_LP, CT2.CT2_KEY, CT2_EMPORI, CT2_FILORI, "+cEOL
	cQuery += "         CT2.CT2_FILKEY, CT2.CT2_PREFIX, CT2.CT2_NUMDOC, CT2.CT2_PARCEL, CT2.CT2_TIPODC, CT2.CT2_CLIFOR, CT2.CT2_LOJACF, "+cEOL
    cQuery += "         E1.R_E_C_N_O_ SE1REG  "+cEOL
    cQuery += " FROM "+RetSqlName("CT2")+" (NOLOCK) CT2 INNER JOIN "+ retSqlname("SE1") +" (NOLOCK) E1 ON E1.D_E_L_E_T_='*' AND CT2.D_E_L_E_T_='' AND E1.E1_FILIAL=CT2.CT2_FILKEY AND E1.E1_PREFIXO=CT2.CT2_PREFIX AND"+cEOL
	cQuery += " 									E1.E1_NUM=CT2.CT2_NUMDOC AND E1.E1_PARCELA=CT2.CT2_PARCEL AND E1.E1_TIPO=CT2.CT2_TIPODC AND E1.E1_CLIENTE=CT2.CT2_CLIFOR AND"+cEOL
	cQuery += " 									E1.E1_LOJA=CT2.CT2_LOJACF"+cEOL
    cQuery += " WHERE E1.D_E_L_E_T_='*' AND CT2.CT2_ROTINA='CONTAB' AND CT2.CT2_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND E1.E1_LA='S' AND LEFT(E1.E1_HIST,3)!='CB=' "+cEOL
    cQuery += " ORDER BY CT2.CT2_FILIAL, CT2.CT2_DATA; "

    tcQuery cQuery New Alias "Work"
    //U_ADFIN108P()
	tcSetField("Work", "CT2_DATA"   , "D", 8,  0)
    tcSetField("Work", "CT2_VALOR"  , "N", 12, 4)

    While work->(!eof())
        if dDtTmp != work->CT2_DATA .AND. !Empty(dDtTmp)
            IncluiCT2(aLanc)
            aLanc   := {}
        endif
        
        aadd(aLanc,{WORK->CT2_FILIAL,; //*01*/
                    WORK->CT2_DATA,; //*02*/
                    Alltrim(WORK->CT2_LOTE),;  //*03*/
                    Alltrim(WORK->CT2_SBLOTE),; //*04*/
                    Alltrim(WORK->CT2_DOC),; //*05*/
                    Alltrim(WORK->CT2_LINHA),; //*06*/
                    Alltrim(WORK->CT2_DC),; //*07*/
                    Alltrim(WORK->CT2_DEBITO),; //*08*/
                    Alltrim(WORK->CT2_CREDIT),; //*09*/
                    WORK->CT2_VALOR,; //*10*/
                    Alltrim(WORK->CT2_HIST),; //*11*/
                    Alltrim(WORK->CT2_CCD),; //*12*/
                    Alltrim(WORK->CT2_CCC),; //*13*/
                    Alltrim(WORK->CT2_ITEMD),; //*14*/
                    Alltrim(WORK->CT2_ITEMC),;  //*15*/
	                Alltrim(WORK->CT2_MOEDLC),; //*16*/
                    Alltrim(WORK->CT2_ORIGEM),; //*17*/
                    Alltrim(WORK->CT2_ROTINA),; //*18*/
                    Alltrim(WORK->CT2_LP),; //*19*/
                    Alltrim(WORK->CT2_KEY),; //*20*/
	                Alltrim(WORK->CT2_FILKEY),; //*21*/
                    Alltrim(WORK->CT2_PREFIX),; //*22*/
                    Alltrim(WORK->CT2_NUMDOC),; //*23*/
                    Alltrim(WORK->CT2_PARCEL),; //*24*/
                    Alltrim(WORK->CT2_TIPODC),; //*25*/
                    Alltrim(WORK->CT2_CLIFOR),; //*26*/
                    Alltrim(WORK->CT2_LOJACF),; //*27*/
                    Alltrim(WORK->CT2_EMPORI),; //*28*/
                    Alltrim(WORK->CT2_FILORI),; //*29*/
                    WORK->SE1REG}) //*30*/


        work->(Dbskip())
    enddo

    if Len(aLanc) > 0
        fGerCT2(aLanc)
    endif
    work->(DbcloseArea())
return

/*/{Protheus.doc} Static Function fGetDoc
    Pega o último documento disponível.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 22/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fGetDoc(dDtLanc, cLote, cSbLote, cDoc)
    Local cRetDoc   := cDoc
    Local cQuery    := ""

    cQuery  := " SELECT MAX(CT2_DOC) CT2DOC "
    cQuery  += " FROM "+ RetSqlName("CT2") +" (NOLOCK) "
    cQuery  += " WHERE D_E_L_E_T_='' AND CT2_FILIAL='"+ xFilial("CT2") +"' AND CT2_DATA='"+ Dtos(dDtLanc) +"' AND CT2_LOTE='"+ cLote +"' AND CT2_SBLOTE='"+ cSbLote +"'; "

    TcQuery cQuery ALIAS "QCT2" NEW

    if QCT2->(!eof())
        cRetDoc := StrZero(Val(QCT2->CT2DOC)+1,6)
    else
        cRetDoc := "000001"
    endif

    QCT2->(DbCloseArea())
return cRetDoc

/*/{Protheus.doc} Static Function fGerCT2
    Grava os lançamentos de estorno.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 22/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fGerCT2(aLanc)
    Local aItens    := {}
    Local aCabec    := {}
    Local aItens    := {}
    Local cHist     := ""
    Local nX        := 0
    Local _lOk      := .T.
    Local cLastDoc  := fGetDoc(aLanc[01][02], aLanc[01][03], aLanc[01][04], aLanc[01][05])
    /*
    Local aCabec := { {'DDATALANC'  ,aLanc[01][02]      ,NIL},;
                    {'CLOTE'        ,aLanc[01][03]      ,NIL},;
                    {'CSUBLOTE'     ,aLanc[01][04]      ,NIL},;
                    {'CDOC'         ,cLastDoc           ,NIL},;
                    {'CPADRAO'      ,''                 ,NIL},;
                    {'NTOTINF'      ,0                  ,NIL},;
                    {'NTOTINFLOT'   ,0                  ,NIL} }
    */
    Local aCabec := { {'DDATALANC'  ,dDatabase          ,NIL},;
                    {'CLOTE'        ,aLanc[01][03]      ,NIL},;
                    {'CSUBLOTE'     ,aLanc[01][04]      ,NIL},;
                    {'CDOC'         ,cLastDoc           ,NIL},;
                    {'CPADRAO'      ,''                 ,NIL},;
                    {'NTOTINF'      ,0                  ,NIL},;
                    {'NTOTINFLOT'   ,0                  ,NIL} }
    
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private CTF_LOCK        := 0
    Private lSubLote        := .T.

    dbSelectArea("CT2")
    CT2->(dbSetOrder(1))

    for nX := 1 to Len(aLanc)
        aAdd(aItens,{ {'CT2_FILIAL'     ,xFilial("CT2"), NIL},;
                    {'CT2_LINHA'        ,StrZero(nX,3) , NIL},;
                    {'CT2_MOEDLC'       ,aLanc[nX][16] , NIL},;
                    {'CT2_DC'           ,aLanc[nX][07] , NIL},;
                    {'CT2_CREDIT'       ,aLanc[nX][08] , NIL},;
                    {'CT2_DEBITO'       ,aLanc[nX][09] , NIL},;
                    {'CT2_VALOR'        ,aLanc[nX][10] , NIL},;
                    {'CT2_HIST'         ,"CANC.-"+aLanc[nX][11] , NIL},;
                    {'CT2_CCD'          ,aLanc[nX][13] , NIL},;
                    {'CT2_CCC'          ,aLanc[nX][12] , NIL},;
                    {'CT2_ITEMD'        ,aLanc[nX][15] , NIL},;
                    {'CT2_ITEMC'        ,aLanc[nX][14] , NIL},;
                    {'CT2_EMPORI'       ,aLanc[nX][28] , NIL},;
                    {'CT2_FILORI'       ,aLanc[nX][29] , NIL},;
                    {'CT2_ORIGEM'       ,aLanc[nX][17] , NIL},;
                    {'CT2_ROTINA'       ,aLanc[nX][18] , NIL},;
                    {'CT2_LP'           ,aLanc[nX][19] , NIL},;
                    {'CT2_KEY'          ,aLanc[nX][20] , NIL},;
                    {'CT2_FILKEY'       ,aLanc[nX][21] , NIL},;
                    {'CT2_PREFIX'       ,aLanc[nX][22] , NIL},;
                    {'CT2_NUMDOC'       ,aLanc[nX][23] , NIL},;
                    {'CT2_PARCEL'       ,aLanc[nX][24] , NIL},;
                    {'CT2_TIPODC'       ,aLanc[nX][25] , NIL},;
                    {'CT2_CLIFOR'       ,aLanc[nX][26] , NIL},;
                    {'CT2_LOJACF'       ,aLanc[nX][27] , NIL},;
                    {'CT2_HP'           ,''            , NIL} } )

                    cHist += Chr(13)+chr(10)+aLanc[nX][11]

    next nX
    
    //U_ADFIN108P()
    MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCabec ,aItens, 3)
    If lMsErroAuto <> Nil
        If !lMsErroAuto
            _lOk := .T.
            fGrvHist(aLanc)
            If !IsBlind()
                MsgInfo('Contablizado os cancelamentos dos títulos tipo "AB-" dia '+ Dtoc(aLanc[01][02]) +': ' + cHist)
            EndIf
        Else
            _lOk := .F.
            
            If !IsBlind()
                MsgAlert('Erro na contablização dos cancelamentos dos títulos tipo "AB-" dia '+ Dtoc(aLanc[01][02]) +': ' + cHist)
            Endif
        EndIf
    EndIf

Return

/*/{Protheus.doc} Static Function fGrvHist
    Grava no histórico do título cancelado a marcação de que foi gerado o lançamento de estorno.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 22/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fGrvHist(aLanc)
    Local nA    := 1
    Local nArr  := Len(aLanc)
    
    DbSelectArea("SE1")

    for nA := 1 to nArr
        nRecno := aLanc[nA][Len(aLanc[nA])]
        SE1->(DbGoto(nRecno))

        if nRecno == SE1->(recno())
            If Reclock("SE1",.F.)
                E1_HIST := "CB="+E1_HIST
                SE1->(Msunlock())
            endif
        endif

    next nA
return

/*/{Protheus.doc} Static Function fContab
    Executa a contabilizaÃ§Ã£o dos tÃ­tulos.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 08/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fContab(aDados, aCabec)
    Local aItens        := {}
    Local aFlagCTB      := {}
    Local nA            := 1
    Local nB            := 1
    Local nDados        := Len(aDados)
    Local nTotal        := 0
    Local dDtCont       := dDatabase
    Local nValor        := 0
    //Parâmetros da contabilização
    Local cPadrao       := "AB-"
	Local lPadrao       := VerPadrao(cPadrao)
    //Local lDigita := Iif(MV_PAR01==1,.T.,.F.)
    Local lDigita       := .T. //Iif(MV_PAR01==1,.T.,.F.)
    Local lAglutina     := .F.
    Local nHdlPrv       := 0
    Local cLote         := "008850"
    Local cArquivo      := ""
    Local aTabRecOri    := {}

    //Posição dos campos no cabeçalho.
    //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, SE1.RECNO, SE1.E5_DTDISPO
    Local nPosCli   := fGetfield("E1_CLIENTE"  , aCabec)
    Local nPosLoja  := fGetfield("E1_LOJA"     , aCabec)
    //Local nPosDtDis := fGetfield("E5_DTDISPO"  , aCabec)
    Local nPosRecno := fGetfield("RECNO"       , aCabec)

    if lPadrao
        DbSelectArea("SA1")
        SA1->(Dbsetorder(1))

        DbSelectArea("SE1")
        SE1->(Dbsetorder(1))

        nTotal := 0

        for nA := 1 To nDados

            dDtCont := aDados[nA][01]
            aItens  := aDados[nA][02]
            nItens  := Len(aItens)
            nTotal  := 0
            nB      := 1

            nHdlPrv := HeadProva( cLote, "CONTAB" /*cPrograma*/, Substr( cUsuario, 7, 6 ), @cArquivo )
            

            for nB := 1 To nItens
                SA1->(DbSeek(xFilial("SA1")+aItens[nB][nPosCli]+aItens[nB][nPosLoja]))
                SE1->(DbGoto(aItens[nB][nPosRecno]))
                
                aTabRecOri := { 'SE1', SE1->( RECNO() ) }

                nValor := DetProva( nHdlPrv,; 
                                    cPadrao,; 
                                    "CONTAB" /*cPrograma*/,; 
                                    cLote,;
                                    /*nLinha*/,; 
                                    /*lExecuta*/,; 
                                    /*cCriterio*/,; 
                                    /*lRateio*/,;
                                    /*cChaveBusca*/,; 
                                    /*aCT5*/,; 
                                    /*lPosiciona*/,; 
                                    @aFlagCTB,; 
                                    aTabRecOri /*aTabRecOri*/,; 
                                    /*aDadosProva*/)
                
                nTotal += nValor

                if nValor > 0
                    if RecLock("SE1",.F.)
                        SE1->E1_LA := "S"
                        SE1->(Msunlock())
                    endif
                endif                
                
            next nB++
            
            if nTotal > 0
                
                    //nHdlPrv := HeadProva( cLote, "CONTAB" /*cPrograma*/, Substr( cUsuario, 7, 6 ), @cArquivo )
                RodaProva(nHdlPrv, nTotal)
                    
                cA100Incl(  cArquivo,; 
                            nHdlPrv,; 
                            3 /*nOpcx*/,; 
                            cLote,; 
                            lDigita,; 
                            lAglutina,; 
                            /*cOnLine*/,; 
                            dDtCont /*dData*/,; 
                            /*dReproc*/,; 
                            @aFlagCTB,; 
                            /*aDadosProva*/,; 
                            /*aDiario*/)
                
            endif
            
            aFlagCTB := {}

        next nA++

    else
        Msginfo("Não existem regras de contabilização válidas cadastradas no sistema!")
    endif
return

Static Function fGetfield(cField, aHeader)
    Local nRet  := 0
    Local nX    := 0

    cField := Alltrim(Upper(cField))

    for nX := 1 to len(aHeader)
        if cField == Alltrim(Upper(aHeader[nX][01]))
            nRet := nX
        endif
    next nX++

return nRet

/*/{Protheus.doc} Static Function fExecSQL
    Processa a consulta SQL e faz a carga na array.
    @type  Static Function
    @author Leonardo P. Monteiro
    @since 08/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
static function fexecSQL(aDados,aCabec)
    
    Local cTipo     := Alltrim(GetMV("MV_#CTBAB-",,"AB-"))
    Local dDtAtua   := Stod("")
    Local nLinha    := 1
    Local nMax      := 0
    Local nCabec    := 0
    Local aCabec    := {}
    Local aItens    := {}
    Local cDtDe     := Dtos(MV_PAR01)
    Local cDtAte    := Dtos(MV_PAR02)
    Local nA

    cQuery := " SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, SE1.RECNO, SE1.E5_DTDISPO "
    cQuery += " FROM (SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1.R_E_C_N_O_ RECNO, MAX(E5_DTDISPO) E5_DTDISPO  "
    cQuery += "       FROM " + RetSqlName("SE1") + " E1 (NOLOCK) INNER JOIN " + RetSqlName("SE5") + " E5 (NOLOCK) ON E1.D_E_L_E_T_='' AND E5.D_E_L_E_T_='' "
    cQuery += "             AND E5.E5_FILIAL=E1.E1_FILIAL AND E5.E5_PREFIXO=E1.E1_PREFIXO AND E5.E5_NUMERO=E1.E1_NUM AND E5.E5_PARCELA=E1.E1_PARCELA "
    cQuery += "             AND E5.E5_CLIFOR=E1.E1_CLIENTE AND E5.E5_LOJA=E1.E1_LOJA AND E5.E5_SITUACA='' AND E5.E5_RECPAG='R' "
    cQuery += "       WHERE E1.D_E_L_E_T_='' AND E1.E1_FILIAL BETWEEN '' AND 'ZZ' AND E5.E5_DTDISPO >= '"+cDtDe+"' AND E1_LA<>'S' AND E1_TIPO='"+cTipo+"' AND E1_SALDO=0 "
    cQuery += "       GROUP BY E1.E1_FILIAL, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_CLIENTE, E1.E1_LOJA, E1_NOMCLI, E1.E1_VALOR, E1.R_E_C_N_O_ ) SE1 "
    cQuery += " WHERE SE1.E5_DTDISPO BETWEEN '"+cDtDe+"' AND '"+cDtAte+"' "
    cQuery += " AND (SELECT TOP(1) E1_SALDO "
    cQuery += "      FROM " + RetSqlName("SE1") + " (NOLOCK)  SE1PRI "
    cQuery += "      WHERE SE1PRI.E1_FILIAL  = SE1.E1_FILIAL AND SE1PRI.E1_PREFIXO = SE1.E1_PREFIXO AND SE1PRI.E1_NUM = SE1.E1_NUM "
    cQuery += "              AND SE1PRI.E1_PARCELA = SE1.E1_PARCELA AND SE1PRI.E1_CLIENTE = SE1.E1_CLIENTE AND SE1PRI.E1_LOJA = SE1.E1_LOJA "
    cQuery += "             AND SE1PRI.E1_TIPO <> '"+cTipo+"' AND SE1PRI.D_E_L_E_T_ = '' ) = 0 "
    //cQuery += " ORDER BY 10 "
    cQuery += " ORDER BY SE1.E1_FILIAL, SE1.E5_DTDISPO, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA; "

    tcQuery cQuery New Alias "Work"

	tcSetField("Work", "E5_DTDISPO", "D", 8, 0)
    
    aCabec  := work->(dbStruct())
    nCabec  := Len(aCabec)

    Work->( dbGoTop() )

    while work->(!eof())
 
        if !ABIsDuplic()
        
            if !empty(dDtAtua) .and. dDtAtua != work->E5_DTDISPO .AND. leN(aItens) > 0
                AADD(aDados, {dDtAtua, aItens})
                aItens := {}
            endif

            AADD(aItens,Array(nCabec))
            nMax := Len(aItens)

            for nA := 1 TO nCabec
                aItens[nMax][nA] := &("work->"+Alltrim(aCabec[nA][01]))
            next nA++

            dDtAtua := work->E5_DTDISPO
        
        endif
        
        work->(dbskip())
    enddo
    
    if !empty(dDtAtua) .and. dDtAtua != work->E5_DTDISPO .AND. leN(aItens) > 0
        AADD(aDados, {dDtAtua, aItens})

            aItens := {}
    endif

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

return Len(aDados)

/*/{Protheus.doc} Static Function ABIsDuplic
    Checa se o AB- jÃ¡ estÃ¡ contabilizado
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

    //Ticket  7868   - Leonardo P. Monteiro - 25/01/2021 - Quando ocorre mais de um estorno ou exclusÃ£o ele nÃ£o considera os novos registros na contabilidade.
    //                                                      Ajuste na consulta e correÃ§Ã£o de lÃ³gica.
    cQuery := " SELECT COUNT(*) CONTADOR "
    cQuery += " FROM "+ Retsqlname("CV3") +" CV3 (NOLOCK) INNER JOIN "+ RetSqlname("CT2") +" CT2 (NOLOCK) ON CT2.CT2_SEQUEN=CV3.CV3_SEQUEN AND CT2.R_E_C_N_O_=CV3.CV3_RECDES "
	cQuery += " WHERE CT2.D_E_L_E_T_='' AND CV3.D_E_L_E_T_='' AND CV3.CV3_FILIAL='"+ FWxFilial("CV3") +"' AND CV3.CV3_TABORI='SE1' AND CV3.CV3_RECORI='"+ AllTrim(Str(Work->RECNO)) +"'; "
    
    TcQuery cQuery ALIAS "QCV3" NEW

    if QCV3->(!EOF())
        IF QCV3->CONTADOR <> 0
            //@history ticket 13678   - Leonardo P. Monteiro - 12/05/2021 - Tratamento dos cancelamentos de títulos AB-.
            /*
            if msgYesNo("Já existe lançamento contábil para o título "+ alltrim(WORK->E1_PREFIXO)+"/"+ALLTRIM(work->E1_NUM)+"/"+ALLTRIM(work->E1_TIPO)+"/"+ ALLTRIM(Work->E1_PARCELA) +", deseja confirmar mesmo assim a contabilização?")
                lDuplic := .F.
            else
                lDuplic := .T.
            endif
            */
            lDuplic := .t. // @history ticket 15279   - Fernando Macieira    - 02/07/2021 - Mensagem de duplicidade em todos os títulos
        ENDIF
    endif
    
    QCV3->(Dbclosearea())


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

/*/{Protheus.doc} Static Function FIXAB
    Exclui contabilizações AB- do período
    @type  Static Function
    @author FWNM
    @since 12/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 17717   - Fernando Macieira    - 12/07/2021 - Verificação de lote sem contabilização AB-
/*/
Static Function FIXAB()

    Local lRet      := .f.
    Local aRet      := {}
    Local aParamBox := {}
    Local lOpenCTG  := .t.
    Local cSql      := ""
    Local nStatus   := 0
	Local cUsrAut   := GetMV("MV_#USRAB-",,"001428|002362") // Usuarios autorizados DANIELLE_MEIRA e DYANE
    
    Private cDtIni  := ""
    Private cDtFim  := ""

	// Consisto usuarios autorizados
    If !(RetCodUsr() $ cUsrAut)
        lRet := .f.
        Aviso(	"Exclusão AB- (ADFIN108P-01)",;
                "Login não autorizado! Verifique...",;
                { "&Retorna" },,;
                "Parâmetro MV_#USRAB-" )
        Return lRet
    EndIf
    
    aAdd(aParamBox,{1,"Data Inicial",Ctod(Space(8)),"","","","",50,.F.})
    aAdd(aParamBox,{1,"Data Final"  ,Ctod(Space(8)),"","","","",50,.F.})

    If ParamBox(aParamBox,"Exclusão AB-",@aRet)

        cDtIni := MV_PAR01
        cDtFim := MV_PAR02
        
        lOpenCTG := ChkCTG(aRet)
        If !lOpenCTG
            Alert("Calendário contábil não está aberto! Os lançamentos contábeis AB- não foram excluídos! Verifique...")
            Return lRet
        EndIf

        // Excluo AB- do período e limpo flag SIG
        cSql := " UPDATE " + RetSqlName("CT2") + " SET CT2_MSEXP='', D_E_L_E_T_='*', R_E_C_D_E_L_=R_E_C_N_O_
        cSql += " WHERE CT2_FILIAL='"+FWxFilial("CT2")+"'
        cSql += " AND CT2_DATA BETWEEN '"+DtoS(cDtIni)+"' AND '"+DtoS(cDtFim)+"'
        cSql += " AND CT2_LOTE='008850'
        cSql += " AND CT2_SBLOTE='001'
        cSql += " AND CT2_LP='AB-'
        cSql += " AND D_E_L_E_T_=''

        nStatus := tcSqlExec(cSql)

        If nStatus < 0

            lRet := .f.
            Alert("Exclusão das contabilizações AB- não realizadas devido erro " + TCSQLError())

        Else

            //gera log
            u_GrLogZBE (msDate(),TIME(),cUserName,"CONTABILIZACAO AB-","CONTROLADORIA","ADFIN108P",;
            "EXCLUSAO CONTABILIZACAO AB- PERIODO " + DtoC(cDtIni) + " ATE " + DtoC(cDtFim),ComputerName(),LogUserName())

            nStatus := 0

            // Excluo AB- do período e limpo flag SIG
            cSql := " UPDATE " + RetSqlName("SE1") + " SET E1_LA=''
            cSql += " WHERE E1_FILIAL='"+FWxFilial("SE1")+"'
            cSql += " AND E1_XDTDISP BETWEEN '"+DtoS(cDtIni)+"' AND '"+DtoS(cDtFim)+"'
            cSql += " AND E1_TIPO='AB-'
            cSql += " AND E1_SALDO=0
            cSql += " AND D_E_L_E_T_=''

            nStatus := tcSqlExec(cSql)

            If nStatus < 0
                lRet := .f.
                Alert("Flags de contabilização dos títulos tipo AB- não foram limpados para recontabilização devido erro " + TCSQLError())
            Else
                lRet := .t.
                //gera log
                u_GrLogZBE (msDate(),TIME(),cUserName,"CONTABILIZACAO AB-","CONTROLADORIA","ADFIN108P",;
                "LIMPADO FLAG AB- PARA RECONTABILIZACAO - PERIODO " + DtoC(cDtIni) + " ATE " + DtoC(cDtFim),ComputerName(),LogUserName())
            EndIf
        
        EndIf
    
    EndIf

Return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 12/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkCTG(aRet)

	Local lOpen  := .t.
	Local cQuery := ""

    If Empty(cDtIni) .and. Empty(cDtFim)
        cDtIni := DtoS(aRet[1])
        cDtFim := DtoS(aRet[2])
    EndIf

	If Select("WorkCTG") > 0
		WorkCTG->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT CTG_STATUS "
	cQuery += " FROM " + RetSqlName("CTG") + " WITH (NOLOCK) "
	cQuery += " WHERE CTG_FILIAL='"+FWxFilial("CTG")+"' "
	cQuery += " AND CTG_DTINI LIKE '"+Left(AllTrim(DtoS(cDtIni)),6)+"%' "
	cQuery += " AND CTG_DTFIM LIKE '"+Left(AllTrim(DtoS(cDtFim)),6)+"%' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "WorkCTG"
	
	WorkCTG->( dbGoTop() )
	
	If WorkCTG->CTG_STATUS <> "1" //	- Campo CTG_STATUS (1=Aberto;2=Fechado;3=Transportado;4=Bloqueado)
		lOpen := .f.
	EndIf
	
	If Select("WorkCTG") > 0
		WorkCTG->( dbCloseArea() )
	EndIf

Return lOpen
