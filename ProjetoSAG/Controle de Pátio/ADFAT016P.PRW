#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIF"
Static cTitulo := "Ordem de Pesagem"
Static cTiMast := "Dados da Ordem de Pesagem"
Static xPula   := Chr(13) + Chr(10)

PUBLISH USER MODEL REST NAME ordensdepesagem

/*/{Protheus.doc} User Function ADFAT016P
    Cadastro de Ordem de Pesagem.
    Cad Pesagem
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/11/2021
    @version 01
    /*/
User Function ADFAT016P() // U_ADFAT016P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT016P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT016P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT016P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT16", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 23/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cOrdem     := oModel:GetValue("MD_MASTER", "ZIF_NUMERO")
    Local cTicket    := ""

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
        
        cTicket := Alltrim(cValToChar(Posicione("ZIG",3, FWxFilial("ZIF") + cOrdem + "O", "ZIG_NUMERO")))
        If ! Empty(cTicket)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT016P)", Nil, "Há o ticket de pesagem " + cTicket + " vinculado à ordem de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT016P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT161
    Obtém situação da ordem de pesagem outras.
    @type  User Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFAT161(cTpOrdem, cStatus)
    
    //Variáveis.
    Local aSituacao := {}

    If cTpOrdem == "E" //Entradas.
        aSituacao := getStOE(cStatus)

    ElseIf cTpOrdem == "S" //Saída.
        aSituacao := getStOS(cStatus)

    ElseIf cTpOrdem == "O" //Outras.
       aSituacao := getStOO(cStatus)
        
    ElseIf cTpOrdem == "R" //Ração.
        aSituacao := getStOR(cStatus)

    EndIf

Return aSituacao
/*/{Protheus.doc} getStOO
    Obtém situação da ordem de pesagem outras.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function getStOO(cStatus)

    //Variáveis.
    Local aSituacao := {}

    If cStatus == "1"
        Aadd(aSituacao,{cStatus, "Aberta", "BR_BRANCO"})

    ElseIf cStatus == "2"
        Aadd(aSituacao,{cStatus, "Aguardando Pesagem", "BR_LARANJA"})

    ElseIf cStatus == "3"
        Aadd(aSituacao,{cStatus, "Pré-cadastro Guardian", "BR_AZUL"})

    ElseIf cStatus == "4"
        Aadd(aSituacao,{cStatus, "Peso Inicial", "BR_VERDE"})

    ElseIf cStatus == "5"
        Aadd(aSituacao,{cStatus, "Encerrada", "BR_VERDE_ESCURO"})

    ElseIf cStatus == "6"
        Aadd(aSituacao,{cStatus, "Sequestrada", "BR_VERMELHO"})

    ElseIf cStatus == "7"
        Aadd(aSituacao,{cStatus, "Sequestro liberado", "BR_VERDE"})

    EndIf

Return aSituacao
/*/{Protheus.doc} getStOE
    Obtém situação da ordem de pesagem de entrada.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function getStOE(cStatus)

    //Variáveis.
    Local aSituacao := {}

    If cStatus == "1"
        Aadd(aSituacao,{cStatus, "Aguardando Agrupamento", "BR_BRANCO"})

    ElseIf cStatus == "2"
        Aadd(aSituacao,{cStatus, "Pendente laboratório", "BR_BRANCO"})

    ElseIf cStatus == "3"
        Aadd(aSituacao,{cStatus, "Aprovado laboratório", "BR_AZUL"})

    ElseIf cStatus == "4"
        Aadd(aSituacao,{cStatus, "Reprovado laboratório", "BR_VERMELHO"})

    ElseIf cStatus == "5"
        Aadd(aSituacao,{cStatus, "Aprovado comercial", "BR_AZUL"})

    ElseIf cStatus == "6"
        Aadd(aSituacao,{cStatus, "Pend. Aprov. Transf.", "BR_AMARELO"})

    ElseIf cStatus == "7"
        Aadd(aSituacao,{cStatus, "Transf. aprovada", "BR_AZUL"})
        
    ElseIf cStatus == "8"
        Aadd(aSituacao,{cStatus, "Aguardando Pesagem", "BR_LARANJA"})

    ElseIf cStatus == "9"
        Aadd(aSituacao,{cStatus, "Pré-cadastro Guardian", "BR_AZUL"})

    ElseIf cStatus == "10"
        Aadd(aSituacao,{cStatus, "Peso inicial", "BR_VERDE"})

    ElseIf cStatus == "11"
        Aadd(aSituacao,{cStatus, "Encerrada", "BR_VERDE_ESCURO"})

    ElseIf cStatus == "12"
        Aadd(aSituacao,{cStatus, "Sequestrada", "BR_VERMELHO"})

    ElseIf cStatus == "13"
        Aadd(aSituacao,{cStatus, "Sequestro liberado", "BR_VERDE"})

    ElseIf cStatus == "14"
        Aadd(aSituacao,{cStatus, "Reprovado comercial", "BR_VERMELHO"})

    EndIf

Return aSituacao
/*/{Protheus.doc} getStOS
    Obtém situação da ordem de pesagem de saída.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function getStOS(cStatus)

    //Variáveis.
    Local aSituacao := {}

Return aSituacao
/*/{Protheus.doc} getStOR
    Obtém situação da ordem de pesagem de ração.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function getStOR(cStatus)

    //Variáveis.
    Local aSituacao := {}

Return aSituacao
/*/{Protheus.doc} ADFT161
    Gera ordem de pesagem do tipo "Outras".
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFT161(cCP, dData, cHora, cUsuario, cPlaca)

    //Variáveis.
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""

    oModel := FwLoadModel("ADFAT016P")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER", "ZIF_CTPATI", cCP)
    oModel:SetValue("MD_MASTER", "ZIF_DATA"  , dData)
    oModel:SetValue("MD_MASTER", "ZIF_HORA"  , cHora)
    oModel:SetValue("MD_MASTER", "ZIF_USUARI", cUsuario)
    oModel:SetValue("MD_MASTER", "ZIF_PLACA" , cPlaca)
    oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "O")
    oModel:SetValue("MD_MASTER", "ZIF_EAGRUP", "2")

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
        Help(Nil, Nil, "Função ADFT161(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(O)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return lRet
/*/{Protheus.doc} ADFT161
    Gera ordem de pesagem do tipo "Entrada".
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFT162(cCP, cNF, cSerie, cFornece, cLjForn)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local cPlaca    := ""
    Local cNmFornec := ""
    Local cUsuario  := Iif(Empty(__cUserID), "000000", __cUserID)
    Local cLoteAuth := ""
    Local cProdSAG  := ""
    Local cStatLab  := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return .T.

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP))
        Help(Nil, Nil, "Função ADFT162(ADFAT016P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf   

    cPlaca := ZIB->ZIB_PLACA

    DbSelectArea("SD1")
    SD1->(DbSetOrder(1))
    If ! SD1->(DbSeek( FWxFilial("SD1") + cNF + cSerie + cFornece + cLjForn ))
        Help(Nil, Nil, "Função ADFT162(ADFAT016P)", Nil, "Nota fiscal não localizada " + cNF + "/" + cSerie + "-" + cFornece + cLjForn, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    cNmFornec := Alltrim(Posicione("SA2", 1, FWxFilial("SA2") + cFornece + cLjForn, "A2_NOME"))

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(4))
    If  ZIF->(DbSeek( FWxFilial("ZIF") + cFornece + cLjForn + cNF + cSerie))
        If ! U_ADFT163(cCP)
            RestArea(aArea)
            Return lRet

        EndIf

    EndIf 

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())

    Begin Transaction

        While ! SD1->(Eof()) .And. SD1->D1_FILIAL == FWxFilial("SD1") .And.;
            SD1->D1_DOC == cNF .And. SD1->D1_SERIE == cSerie .And.;
            SD1->D1_FORNECE == cFornece .And. SD1->D1_LOJA == cLjForn

            If SD1->D1_QUANT <= 0
                SD1->(DbSkip())
                Loop
                
            EndIf

            cLoteAuth := Alltrim(cValToChar(Posicione("ZI8", 4, FWxFilial("ZI8") + SD1->D1_COD + "1" + "1", "ZI8_CDLOTE")))
            cProdSAG  := Alltrim(cValToChar(Posicione("ZIM", 2, FWxFilial("ZIM") + SD1->D1_COD, "ZIM_PRDSAG")))
            cRoteiro  := Posicione("ZIB", 1, FWxFilial("ZIB") + cCP, "ZIB_CODROT")  

            If Empty(cProdSAG)
                cMsgError := "Não há produto SAG relacionado ao produto Protheus " + Alltrim(cValToChar(SD1->D1_COD)) + "."
                DisarmTransaction()
                Break

            EndIf

            If ! ZIA->(DbSeek( FWxFilial("ZIA") + cRoteiro + cProdSAG ))
                cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser pesado no roteiro " + Alltrim(cValToChar(cRoteiro)) + "."
                DisarmTransaction()
                Break

            EndIf

            If Alltrim(cValToChar(ZIA->ZIA_ANLABO)) == "1"
                cStatLab := "2"

            Else 
                cStatLab := "1"

            EndIf

            oModel := FwLoadModel("ADFAT016P")

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate() 

            oModel:SetValue("MD_MASTER", "ZIF_CTPATI", cCP)
            oModel:SetValue("MD_MASTER", "ZIF_DATA"  , Date())
            oModel:SetValue("MD_MASTER", "ZIF_HORA"  , Time())
            oModel:SetValue("MD_MASTER", "ZIF_USUARI", cUsuario)
            oModel:SetValue("MD_MASTER", "ZIF_PLACA" , cPlaca)
            oModel:SetValue("MD_MASTER", "ZIF_FORNEC", cFornece)
            oModel:SetValue("MD_MASTER", "ZIF_LJFORN", cLjForn)
            oModel:SetValue("MD_MASTER", "ZIF_NMFOR",  cNmFornec)
            oModel:SetValue("MD_MASTER", "ZIF_CLIFOR", "F")
            oModel:SetValue("MD_MASTER", "ZIF_NF"    , cNF)
            oModel:SetValue("MD_MASTER", "ZIF_SERIE" , cSerie)
            oModel:SetValue("MD_MASTER", "ZIF_PRDPRO", SD1->D1_COD)
            oModel:SetValue("MD_MASTER", "ZIF_PRDSAG", cProdSAG)
            oModel:SetValue("MD_MASTER", "ZIF_ITEMNF", SD1->D1_ITEM)
            oModel:SetValue("MD_MASTER", "ZIF_QUANT" , SD1->D1_QUANT)
            oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "E")
            oModel:SetValue("MD_MASTER", "ZIF_STATUS", "1")
            oModel:SetValue("MD_MASTER", "ZIF_LOTE"  , cLoteAuth)
            oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatLab)
            oModel:SetValue("MD_MASTER", "ZIF_PEDCOM", SD1->D1_PEDIDO)
            oModel:SetValue("MD_MASTER", "ZIF_ENVBAR", ZIA->ZIA_MVESTO)

            If oModel:VldData()
                oModel:CommitData()
                lRet := .T.

            Else
                aError := oModel:GetErrorMessage()
                cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))
                DisarmTransaction()
                Break

            EndIf

            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

            SD1->(DbSkip())

        End

    End Transaction

    If ValType(oModel) <> "U"
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

    EndIf

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFT162(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(E)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT163
    Deleta ordem de pesagem do tipo "Entrada".
    @type  User Function
    @author Everson
    @since 10/12/2021
    @version 01
/*/
User Function ADFT163(cCP)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cNmOrdem  := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return lRet

    EndIf
 
    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + cCP))
        RestArea(aArea)
        Return lRet

    EndIf   

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))

    Begin Transaction

        While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And.;
            ZIF->ZIF_CTPATI == cCP

            cNmOrdem := Iif(Empty(ZIF->ZIF_AGRUPA), ZIF->ZIF_NUMERO, ZIF->ZIF_AGRUPA)

            If ZIG->(DbSeek(FWxFilial("ZIG") + cNmOrdem))

                If ! U_ADFT172(cCP, ZIG->ZIG_ORDEM, ZIG->ZIG_NUMERO)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            EndIf

            ZIF->(DbSkip())

        End

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT164
    Executa a atualização de status da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFT164(cNmOrdem, cStatus, nStatus)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local cMsgError := ""

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))
        Help(Nil, Nil, "Função atlStOrd(ADFAT017P)", Nil, "Ordem de pesagem " + cNmOrdem + " não encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT016P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate() 

    If nStatus == 1 //Status da ordem.
        oModel:SetValue("MD_MASTER", "ZIF_STATUS", cStatus)

    ElseIf nStatus == 2 //Status laboratório.
        oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatus)

    EndIf

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
        Help(Nil, Nil, "Função ADFT164(ADFAT016P)", Nil, "Erro na atualização de registro de ordem de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFT165
    Atualiza ordem de pesagem.
    @type  User Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
User Function ADFT165(cNmOrdem, cCampo, xValor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""
    
    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + cNmOrdem ))
        Help(Nil, Nil, "Função ADFT165(ADFAT017P)", Nil, "Ordem de pesagem " + cNmOrdem + " não encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT016P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    oModel:SetValue("MD_MASTER", cCampo, xValor)

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
        Help(Nil, Nil, "Função ADFT165(ADFAT016P)", Nil, "Erro na atualização de registro da ordem de pesagem " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
