#Include "rwmake.ch"

/*/{Protheus.doc} User Function LP597
    Este LP retorna dados para o LP 597 (compensação contas a pagar. 
    Trata o posicionamento dos títulos. Adaptado do rdmake originalmente elaborado por Martelli.
    @type  Function
    @author Donizete
    @since 10/07/2004
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 058405 - FWNM - 26/05/2020 - OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002
/*/
User Function LP597(_cPar1,_cPar2)    

    // Chamado n. 058405 - FWNM - 26/05/2020 - OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002
    Local cNFTXTHist := ""
    Local cPATXTHist := ""
    //

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    Public _aArea   	:= GetArea()
    Public _aAreaSE1	:= {}
    Public _aAreaSE5	:= {}
    Public _aAreaSA1	:= {}
    Public _aAreaSED	:= {}
    Public _cRet		:= Space(20)
    Public _cCod		:= Space(TamSX3("A2_COD")[1])
    Public _cLoja		:= Space(TamSX3("A2_LOJA")[1])
    Public _cConta		:= Space(TamSX3("CT1_CONTA")[1])
    Public _cNat		:= Space(TamSX3("ED_CODIGO")[1])
    Public _cContaDeb   := Space(TamSX3("E2_DEBITO")[1]) // CHAMADO 041551 WILLIAM COSTA
    Public _cChavePA	:= Space(23)
    Public _cChaveNF	:= Space(23)
    Public _cChave		:= Space(23)
    Public _cForPA		:= Space(15)
    Public _cForNF		:= Space(15)

    _cPar1 := Upper(Alltrim(_cPar1)) // Tipo de Dado a ser retornado.
    _cPar2 := Upper(Alltrim(_cPar2)) // Tipo de Dado a ser retornado.

    dbSelectArea("SE5")

    _aAreaSE5 := GetArea()

    If Alltrim(SE5->E5_TIPO) $ "PA/NDF" // Usuário compensou posicionando na NF.
        //_cChaveNF := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
        _cChaveNF := SUBSTR(SE5->E5_DOCUMEN,1,18)+SE5->E5_CLIFOR+SE5->E5_LOJA // Chamado n. 058405 || OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002 - FWNM - 26/05/2020
        _cChavePA := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
    Else // Usuário compensou posicionando no PA/NDF
        _cChaveNF := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
        _cChavePA := SUBSTR(SE5->E5_DOCUMEN,1,18)+SE5->E5_CLIFOR+SE5->E5_LOJA  // Chamado n. 058405 || OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002 - FWNM - 26/05/2020
        //_cChavePA := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
    EndIf

    // Chamado n. 058405 || OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002 - FWNM - 26/05/2020
    //PPPNNNNNNNNNPPPTTTFFFFFFLL
    cNFTXTHist := Left(AllTrim(_cChaveNF),3) + " " + Subs(AllTrim(_cChaveNF),4,9) + " " + Subs(AllTrim(_cChaveNF),13,3) + " " + Subs(AllTrim(_cChaveNF),16,3) + " " + Subs(AllTrim(_cChaveNF),19,6) + " " + Right(AllTrim(_cChaveNF),2)
    cPATXTHist := Left(AllTrim(_cChavePA),3) + " " + Subs(AllTrim(_cChavePA),4,9) + " " + Subs(AllTrim(_cChavePA),13,3) + " " + Subs(AllTrim(_cChavePA),16,3) + " " + Subs(AllTrim(_cChavePA),19,6) + " " + Right(AllTrim(_cChavePA),2)
    //

    RestArea(_aAreaSE5)
    dbSelectArea("SE2")
    _aAreaSE2 := GetArea()
    dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

    // Obtem nome do fornecedor da NF.
    dbSeek(xFilial("SE2")+_cChaveNF,.T.)
    If Found()
        _cForNF	  := Alltrim(SE2->E2_NOMFOR)
    EndIf

    // Obtem nome do fornecedor do PA.
    dbSeek(xFilial("SE2")+_cChavePA,.T.)
    If Found()
        _cForPA	  := Alltrim(SE2->E2_NOMFOR)
    EndIf

    // Verifica tipo de dado solicitado pelo usuário.
    If _cPar2 == "NF"
        _cChave := _cChaveNF
    Else
        _cChave := _cChavePA
    EndIf

    // Posiciona no título conforme tipo escolhido pelo usuário.
    dbSeek(xFilial("SE2")+_cChave,.T.)

    _cCod	   := SE2->E2_FORNECE
    _cLoja     := SE2->E2_LOJA
    _cNat      := SE2->E2_NATUREZ
    _cContaDeb := SE2->E2_DEBITO // CHAMADO 041551 WILLIAM COSTA

    RestArea(_aAreaSE2)

    // Retorna dados conforme solicitado.
    If _cPar1 == "SA2" // Retorna conta do fornecedor.

        dbSelectArea("SA2")
        _aAreaSA2 := GetArea()
        dbSetOrder(1)
        dbSeek(xFilial("SA2")+_ccod+_cloja)
        
        If Found()
            _cRet := SA2->A2_CONTA
        EndIf

        RestArea(_aAreaSA2)
        
    ElseIf _cPar1 == "COD" // Retorna o codigo e loja do fornecedor - Everaldo Casaroli em producao 10/03/2008

        dbSelectArea("SA2")
        _aAreaSA2 := GetArea()
        dbSetOrder(1)
        dbSeek(xFilial("SA2")+_ccod+_cloja)

        IF SA2->A2_XCT2IMP=="S"	

            If Found()
                _cRet := "F."+SA2->(A2_COD+A2_LOJA)+"-"
            EndIf

        Endif

        RestArea(_aAreaSA2)

    ElseIf _cPar1 == "SED" // Retorna dados da natureza financeira, pode ser a conta por exemplo.

        dbSelectArea("SED")
        _aAreaSED := GetArea()
        dbSetOrder(1)
        dbSeek(xFilial("SED")+_cNat)

        If Found()
    //		_cRet := SED->ED_ZZCTAA
            _cRet := SED->ED_CONTA
        EndIf

        RestArea(_aAreaSED)

    ElseIf _cPar1 == "HIS" // Retorna histórico para o LP.
        //_cRet := "COMP.CP." + ALLTRIM(_cChaveNF) + "-" + " C/ " + ALLTRIM(_cChavePA) + "-" + ALLTRIM(_cForPA)
        _cRet := "COMP.CP. " + ALLTRIM(cNFTXTHist) + " " + " C/ " + ALLTRIM(cPATXTHist) + " " + ALLTRIM(_cForPA) // Chamado n. 058405 || OS 059902 || CONTROLADORIA || MONIK_MACEDO || 11996108893 || LP 597-002 - FWNM - 26/05/2020
    
    ElseIf SubStr(_cPar1,1,3) == "E5_"
        _cRet := "SE5->(" + Alltrim(_cPar1) + ")"
        _cRet := &_cRet

    ElseIf SubStr(_cPar1,1,3) == "E1_"
        _cRet := "SE1->(" + Alltrim(_cPar1) + ")"
        _cRet := &_cRet	

    ElseIf SubStr(_cPar1,1,3) == "E2_"

        // *** INICIO CHAMADO 041551 || CONTROLADORIA || MONIK_MACEDO || LANCAMENTO PADRAO WILLIAM COSTA 14/05/2018  *** // 
        IF ALLTRIM(_cPar1) == 'E2_DEBITO'
        
            // *** INICIO WILLIAM COSTA 18/06/2018 CHAMADO 042110 || CONTROLADORIA || MONIK_MACEDO || 8956 || REGRA LP *** // 
            IF EMPTY(_cContaDeb)
            
                _aAreaSED := GetArea()

                dbSelectArea("SED")
                dbSetOrder(1)
                dbSeek(xFilial("SED")+_cNat)

                If Found()
                    _cRet := SED->ED_CONTA
                EndIf

                RestArea(_aAreaSED)
            
            ELSE
        
                _cRet := _cContaDeb
            
            ENDIF
            // *** FINAL WILLIAM COSTA 18/06/2018 CHAMADO 042110 || CONTROLADORIA || MONIK_MACEDO || 8956 || REGRA LP *** //
        // *** FINAL CHAMADO 041551 || CONTROLADORIA || MONIK_MACEDO || LANCAMENTO PADRAO WILLIAM COSTA 14/05/2018  *** //
        
        ELSE
        
            _cRet := "SE2->(" + Alltrim(_cPar1) + ")"
            _cRet := &_cRet
        
        ENDIF

    EndIf

    RestArea(_aArea)
    
Return(_cRet)