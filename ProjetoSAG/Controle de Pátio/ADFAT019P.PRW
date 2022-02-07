#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIG"
Static cTitulo := "Ticket de Pesagem"
Static cTiMast := "Dados do Ticket de Pesagem"
Static xPula   := Chr(13) + Chr(10)

PUBLISH USER MODEL REST NAME ticketsdepesagem

/*/{Protheus.doc} User Function ADFAT019P
    Cadastro de Ticket de Pesagem.
    Cad Ticket Pesagem
    Chamado 18465.
    @type  Function
    @author Everson
    @since 19/11/2021
    @version 01
    /*/
User Function ADFAT019P() // U_ADFAT019P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT019P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT019P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT019P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT19", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cPesInicia := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_INICIA")))
    Local cCP        := oModel:GetValue("MD_MASTER", "ZIG_CTPATI")
    //Local cOrdem     := oModel:GetValue("MD_MASTER", "ZIG_ORDEM")
    Local cTktGua    := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_NUMGUA")))
    
    Local nPesIni    := oModel:GetValue("MD_MASTER", "ZIG_PESINI")
    Local cPesIniD   := Alltrim(cValToChar(DToS(oModel:GetValue("MD_MASTER", "ZIG_DTPES1"))))
    Local cPesIniH   := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_HRPES1")))
    
    Local nPesFim    := oModel:GetValue("MD_MASTER", "ZIG_PESFIM")
    Local cPesFimD   := Alltrim(cValToChar(DToS(oModel:GetValue("MD_MASTER", "ZIG_DTPES2"))))
    Local cPesFimH   := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_HRPES2")))

    Local nPesLiq    := oModel:GetValue("MD_MASTER", "ZIG_PESOLI")

    Local cPesManual := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_MANUAL")))
    Local cPesAutoma := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_AUTOMA")))
    //Local cOrdAgrupa := Alltrim(cValToChar(Posicione("ZIF",2, FWxFilial("ZIF") + cOrdem, "ZIF_AGRUPA")))
    Local cSeq       := ""

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        // If lRet .And. ! Empty(cOrdAgrupa)
        //     lRet := .F.
        //     Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Selecione a ordem agrupadora " + cOrdAgrupa + " para vincular ao ticket de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        // EndIF

        If lRet
            cSeq := cValToChar(Val(cValToChar(obtSeq(cCP) )) + 1)
            oModel:SetValue("MD_MASTER","ZIG_SEQTKT",cSeq)

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        If cPesInicia $"2/3" .And. Empty(cPesManual)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Necessário informar se a pesagem é manual.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If cPesInicia $"2/3" .And. Empty(cPesAutoma)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Necessário informar se a pesagem é automática.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "2" .And. nPesIni <= 0
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Pesagem inicial inválida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "2" .And. (Empty(cPesIniD) .Or. Empty(cPesIniH))
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Necessário informar data e hora da pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. nPesFim <= 0
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Pesagem fim inválida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. (Empty(cPesFimD) .Or. Empty(cPesFimH))
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Necessário informar data e hora da pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. nPesLiq <= 0
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "Peso líquido inválido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
        
        If cPesInicia $"2/3/4" .Or. ! Empty(cTktGua)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "O ticket de pesagem não pode ser cancelado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT019P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} obtSeq
    Obtém a sequência dos tickets vinculados ao controle de pátio.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function obtSeq(cCP)

    //Variáveis.
    Local nNum   := 0
    Local cQuery := " SELECT MAX(ZIG_SEQTKT) AS TOTTKT FROM " + RetSqlName("ZIG") + " AS ZIG (NOLOCK) WHERE ZIG_FILIAL = '" + FWxFilial("ZIG") + "' AND ZIG_CTPATI = '" + cCP + "' AND ZIG.D_E_L_E_T_ = '' "

    If Select("QTDTKT") > 0
        QTDTKT->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "QTDTKT"
    DbSelectArea("QTDTKT")
        nNum := Val(cValToChar(QTDTKT->TOTTKT))
    QTDTKT->(DbCloseArea())

Return nNum
/*/{Protheus.doc} ADFT191
    Altera ticket de pesagem.
    @type  User Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
User Function ADFT191(cTicket, cCampo, cValor)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local cMsgError := ""

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->(DbSeek( FWxFilial("ZIG") + cTicket ))
        Help(Nil, Nil, "Função ADFT191(ADFAT019P)", Nil, "Ticket de pesagem " + cTicket + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT019P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER", cCampo, cValor)

    If oModel:VldData()
        oModel:CommitData()
        lRet := .T.

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFT191(ADFAT019P)", Nil, "Erro na atualização de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
