/*/{Protheus.doc} ADLOG078P
    Função para inicialização dos campos  ZFA_TPFABT e ZFA_DSFABT.
    @type  Function
    @author Everson
    @since 23/09/2021
    @version 01
    /*/
User Function ADLOG078P(cTpCarga, cCampo, nOpc) 

    //Variáveis.
    Local aArea   := GetArea()
    Local cRet    := "" 

    //
    If cTpCarga <> "1"
        RestArea(aArea)
        Return cRet

    EndIf

    //
    If nOpc == 1 //Inicializador padrão.
        cRet := initPadrao(cCampo)

    ElseIf nOpc == 2 //Inicilizador do browser.
        cRet := initBrowser(cCampo)

    EndIf

    //
    RestArea(aArea)

Return cRet
/*/{Protheus.doc} initBrowser
    Função para inicialização do browser.
    @type  Static Function
    @author Everson
    @since 23/09/2021
    @version 01
/*/
Static Function initPadrao(cCampo)

    //IIF(!FINDFUNCTION("U_ADLOG078P"),"",U_ADLOG078P(ZFA->ZFA_VA,"ZFA_TPFABT",1))
    //IIF(!FINDFUNCTION("U_ADLOG078P"),"",U_ADLOG078P(ZFA->ZFA_VA,"ZFA_DSFABT",1))

    //Variáveis.
    Local aArea   := GetArea()
    Local cRet    := ""
    Local cData   := ""
    Local cPlaca  := ""
    Local cRoteiro:= ""

    //
    If INCLUI
        RestArea(aArea)
        Return cRet
        
    EndIf

    //
    cData   := ZFA->ZFA_DATA
    cPlaca  := ZFA->ZFA_VEICUL
    cRoteiro:= ZFA->ZFA_ROTEIR

    //Campo de código.
    If cCampo == "ZFA_TPFABT"
        cRet := Posicione("SZK",4,FWXFILIAL("SZK") + DToS(cData) + cPlaca + cRoteiro,"ZK_TPFRETE")

    EndIf

    //Campo descrição.
    If cCampo == "ZFA_DSFABT"
        cRet := Posicione("SZK",4,FWXFILIAL("SZK") + DToS(cData) + cPlaca + cRoteiro,"ZK_DESCRI")

    EndIf

    //
    RestArea(aArea)

Return cRet
/*/{Protheus.doc} initBrowser
    Função para inicialização do browser.
    @type  Static Function
    @author Everson
    @since 23/09/2021
    @version 01
/*/
Static Function initBrowser(cCampo)

    //IIF(!FINDFUNCTION("U_ADLOG078P"),"",U_ADLOG078P(ZFA->ZFA_VA,"ZFA_TPFABT",2))
    //IIF(!FINDFUNCTION("U_ADLOG078P"),"",U_ADLOG078P(ZFA->ZFA_VA,"ZFA_DSFABT",2))

    //Variáveis.
    Local aArea   := GetArea()
    Local cRet    := ""
    Local cData   := ""
    Local cPlaca  := ""
    Local cRoteiro:= ""

    //
    cData   := ZFA->ZFA_DATA
    cPlaca  := ZFA->ZFA_VEICUL
    cRoteiro:= ZFA->ZFA_ROTEIR

    //Campo de código.
    If cCampo == "ZFA_TPFABT"
        cRet := Posicione("SZK",4,FWXFILIAL("SZK") + DToS(cData) + cPlaca + cRoteiro,"ZK_TPFRETE")

    EndIf

    //Campo descrição.
    If cCampo == "ZFA_DSFABT"
        cRet := Posicione("SZK",4,FWXFILIAL("SZK") + DToS(cData) + cPlaca + cRoteiro,"ZK_DESCRI")

    EndIf

    //
    RestArea(aArea)

Return cRet
