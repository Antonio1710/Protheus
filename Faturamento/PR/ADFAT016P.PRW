#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIF"
Static cTitulo := "Ordem de Pesagem"
Static cTiMast := "Dados da Ordem de Pesagem"
Static xPula   := Chr(13) + Chr(10)

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

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"      ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"     ACTION "VIEWDEF.ADFAT016P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	      ACTION "VIEWDEF.ADFAT016P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"        ACTION "VIEWDEF.ADFAT016P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	      ACTION "VIEWDEF.ADFAT016P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Env Barramento" ACTION 'MsAguarde({|| U_ADFAT16J() }, "Aguarde", "Enviando...")'       OPERATION 10  ACCESS 0

Return aRotina
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
    Obtém situação da ordem de pesagem.
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
        Aadd(aSituacao,{cStatus, "Aberto", "BR_BRANCO"})

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
    @since 23/03/2022
    @version 01
/*/
Static Function getStOS(cStatus)

    //Variáveis.
    Local aSituacao := {}

    cStatus := Alltrim(cValToChar(cStatus))

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

    cStatus := Alltrim(cValToChar(cStatus))

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
/*/{Protheus.doc} ADFAT169
    Gera ordem de pesagem do tipo "Outras".
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFAT169(cCP, cPlaca, cOrdem)

    //Variáveis.
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local cUsuario  := Iif(Empty(__cUserID), "000000", __cUserID)

    Default cOrdem  := ""

    oModel := FwLoadModel("ADFAT016P")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER", "ZIF_CTPATI", cCP)
    oModel:SetValue("MD_MASTER", "ZIF_DATA"  , Date())
    oModel:SetValue("MD_MASTER", "ZIF_HORA"  , Time())
    oModel:SetValue("MD_MASTER", "ZIF_USUARI", cUsuario)
    oModel:SetValue("MD_MASTER", "ZIF_PLACA" , cPlaca)
    oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "O")
    oModel:SetValue("MD_MASTER", "ZIF_EAGRUP", "2")
    oModel:SetValue("MD_MASTER", "ZIF_ENVBAR", "2")

    If oModel:VldData()
        oModel:CommitData()
        lRet := .T.
        cOrdem := ZIF->ZIF_NUMERO

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT169(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(O)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT162
    Gera ordem de pesagem do tipo "Entrada".
    @type  User Function
    @author Everson
    @since 09/12/2021
    @version 01
/*/
User Function ADFAT162(cCP, cNF, cSerie, cFornece, cLjForn, cOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cPlaca    := ""
    Local cNmFornec := ""
    Local cUsuario  := Iif(Empty(__cUserID), "000000", __cUserID)
    Local cProdSAG  := ""
    Local cStatLab  := ""
    Local cCliFor   := ""

    Default cOrdem    := ""
    Default cMsgError := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return .T.

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    If ! ZIB->(DbSeek( FWxFilial("ZIB") + cCP))
        Help(Nil, Nil, "Função ADFAT162(ADFAT016P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf   

    cPlaca := ZIB->ZIB_PLACA

    DbSelectArea("SD1")
    SD1->(DbSetOrder(1))
    If ! SD1->(DbSeek( FWxFilial("SD1") + cNF + cSerie + cFornece + cLjForn ))
        Help(Nil, Nil, "Função ADFAT162(ADFAT016P)", Nil, "Nota fiscal não localizada " + cNF + "/" + cSerie + "-" + cFornece + cLjForn, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    If SD1->D1_TIPO == "B"
        cNmFornec := Alltrim(Posicione("SA1", 1, FWxFilial("SA1") + cFornece + cLjForn, "A1_NOME"))
        cCliFor := "C"

    Else
        cNmFornec := Alltrim(Posicione("SA2", 1, FWxFilial("SA2") + cFornece + cLjForn, "A2_NOME"))
        cCliFor := "F"

    EndIf

    //Deleta ordem de pesagem do tipo "Entrada".
    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(4))
    If  ZIF->(DbSeek( FWxFilial("ZIF") + cFornece + cLjForn + cNF + cSerie))
        If ! U_ADFAT163(cCP)
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

            If ! U_ADFAT20C(SD1->D1_COD)
                cMsgError := "Não há o produto Protheus " + Alltrim(cValToChar(SD1->D1_COD)) + " na tabela ZIM."
                DisarmTransaction()
                Break

            EndIf

            cStatGemba:= Iif(Alltrim(cValToChar(ZIM->ZIM_TPEMB)) == "1", "2", "4")
            cProdSAG  := ZIM->ZIM_PRDSAG
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
            oModel:SetValue("MD_MASTER", "ZIF_CLIFOR", cCliFor)
            oModel:SetValue("MD_MASTER", "ZIF_NF"    , cNF)
            oModel:SetValue("MD_MASTER", "ZIF_SERIE" , cSerie)
            oModel:SetValue("MD_MASTER", "ZIF_PRDPRO", SD1->D1_COD)
            oModel:SetValue("MD_MASTER", "ZIF_PRDSAG", cProdSAG)
            oModel:SetValue("MD_MASTER", "ZIF_ITEMNF", SD1->D1_ITEM)
            oModel:SetValue("MD_MASTER", "ZIF_QUANT" , SD1->D1_QUANT)
            oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "E")
            oModel:SetValue("MD_MASTER", "ZIF_STATUS", Iif(cStatLab == "2", "2", "1"))
            oModel:SetValue("MD_MASTER", "ZIF_LOTE"  , "") //Aguarda o lote vir do barramento.
            oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatLab)
            oModel:SetValue("MD_MASTER", "ZIF_PEDCOM", SD1->D1_PEDIDO)
            oModel:SetValue("MD_MASTER", "ZIF_ENVBAR", ZIA->ZIA_MVESTO)
            oModel:SetValue("MD_MASTER", "ZIF_EAGRUP", "2")
            oModel:SetValue("MD_MASTER", "ZIF_GEMBA" , cStatGemba)

            If oModel:VldData()
                oModel:CommitData()
                lRet := .T.
                cOrdem := ZIF->ZIF_NUMERO

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
        Help(Nil, Nil, "Função ADFAT162(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(E)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT163
    Deleta ordem de pesagem do tipo "Entrada" vinculadas ao controle de pátio.
    @type  User Function
    @author Everson
    @since 10/12/2021
    @version 01
/*/
User Function ADFAT163(cCP, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cNmOrdem  := ""
    Local cQuery    := ""
    Local aNotas    := {}
    Local cAlias    := ""
    Local cAgrupador:= ""

    Default cMsgError := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return .T.

    EndIf

    //Posiciona na ordem de pesagem pelo controle de pátio.
    If ! U_ADFAT17U(cCP)
        RestArea(aArea)
        Return .T.

    EndIf   

    cQuery := " SELECT ZIF_NUMERO, ZIF_AGRUPA, ZIF_NF, ZIF_SERIE, ZIF_FORNEC, ZIF_LJFORN FROM " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF WHERE  ZIF_FILIAL = '" + FWxFilial("ZIF") + "' AND ZIF_CTPATI = '" + cCP + "' AND ZIF.D_E_L_E_T_ = '' ORDER BY ZIF_NUMERO "

    cAlias := GetNextAlias()

    DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .T., .F. )

    (cAlias)->(DbGoTop())

    Begin Transaction

        While ! (cAlias)->(Eof()) 

            cNmOrdem    := (cAlias)->ZIF_NUMERO
            cAgrupador  := (cAlias)->ZIF_AGRUPA

            If ! U_ADFAT16I(cCP, cNmOrdem, cAgrupador, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

            Aadd(aNotas,{(cAlias)->ZIF_NF,  (cAlias)->ZIF_SERIE, (cAlias)->ZIF_FORNEC, (cAlias)->ZIF_LJFORN})

            (cAlias)->(DbSkip())

        End

        //Marca nota fiscal de entrada.
        U_ADFAT16H(aNotas, "2")

        lRet := .T.

    End Transaction

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT16I
    Deleta ordem de pesagem de entrada.
    @type  User Function
    @author Everson
    @since 21/07/2022
    @version 01
/*/
User Function ADFAT16I(cCP, cNmOrdem, cAgrupador, cMsgError)

    //Variáveis.
    Local aArea := GetArea()

    Default cMsgError := ""

    If U_ADFAT196(Iif(!Empty(cAgrupador),cAgrupador,cNmOrdem))

        //Cancela ticket de pesagem.
        If ! U_ADFAT172(cCP, ZIG->ZIG_ORDEM, ZIG->ZIG_NUMERO,"E",,@cMsgError)
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    //Cancela ordem de pesagem.
    If ! U_ADFAT166(cNmOrdem, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT16H
    Marca notas de entrada.
    @type  User Function
    @author Everson
    @since 21/07/2022
    @version 01
/*/
User Function ADFAT16H(aNotas, cMarca)

    //Variáveis.
    Local aArea := GetArea()
    Local nAux  := 1

    DbSelectArea("SF1")
    SF1->(DbSetOrder(1))
    SF1->(DbGoTop())

    For nAux := 1 To Len(aNotas)

        If ! SF1->(DbSeek( FWxFilial("SF1") + aNotas[nAux][1] + aNotas[nAux][2] + aNotas[nAux][3] + aNotas[nAux][4]  ))
            Loop

        EndIf

        RecLock("SF1", .F.)
            SF1->F1_XPOSORD := cMarca // 1=Possui ordem pesagem vinculada, 2=Não possui ordem de pesagem vinculada.
        SF1->(MsUnlock())

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT167
    Gera ordem de pesagem do tipo "Ração".
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT167(cOrdem, cCP, cPlaca, cOrdemC, cRoteiro, cFornece, cLjForn, cNmFornec, cLote, cProdSAG, cProdPro, nQtd)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local cUsuario  := Iif(Empty(__cUserID), "000000", __cUserID)
    Local cStatLab  := ""
    Local cRotPes   := ""
    Local cCliFor   := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT32G(cOrdemC)
        Help(Nil, Nil, "Função ADFAT167(ADFAT016P)", Nil, "Ordem de carregamento de ração " + cOrdemC + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cCliFor := ZIR->ZIR_CLIFOR

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    ZIB->(DbGoTop())
    If ! ZIB->( DbSeek( FWxFilial("ZIB") + cCP ) )
        Help(Nil, Nil, "Função ADFAT167(ADFAT016P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    cRotPes  := ZIB->ZIB_CODROT

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())

    Begin Transaction

        If ! ZIA->(DbSeek( FWxFilial("ZIA") + cRotPes + cProdSAG ))
            cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser pesado no roteiro " + Alltrim(cValToChar(cRotPes)) + "."
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
        oModel:SetValue("MD_MASTER", "ZIF_CLIFOR", cCliFor)
        oModel:SetValue("MD_MASTER", "ZIF_PRDPRO", cProdPro)
        oModel:SetValue("MD_MASTER", "ZIF_PRDSAG", cProdSAG)
        oModel:SetValue("MD_MASTER", "ZIF_QUANT" , nQtd)
        oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "R")
        oModel:SetValue("MD_MASTER", "ZIF_STATUS", "1")
        oModel:SetValue("MD_MASTER", "ZIF_LOTE"  , cLote)
        oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatLab)
        oModel:SetValue("MD_MASTER", "ZIF_ENVBAR", ZIA->ZIA_MVESTO)
        oModel:SetValue("MD_MASTER", "ZIF_EAGRUP", "2")
        oModel:SetValue("MD_MASTER", "ZIF_ORDRAC", cOrdemC)
        oModel:SetValue("MD_MASTER", "ZIF_ROTEIR", cRoteiro)
        oModel:SetValue("MD_MASTER", "ZIF_STATLC", "A")

        If oModel:VldData()
            oModel:CommitData()
            lRet := .T.
            cOrdem := ZIF->ZIF_NUMERO

        Else
            aError := oModel:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))
            DisarmTransaction()
            Break

        EndIf

        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

    End Transaction


    If ValType(oModel) <> "U"
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

    EndIf

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT167(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(R)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT167
    Gera ordem de pesagem do tipo "Saída".
    @type  User Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT168(cOrdem, cPedS, cPedSItem, cProduto, cCP, cPlaca,;
                      cCliFor, cFornece, cLjForn, cNmFornec, cLote, cProdSAG, cProdPro, nQtd)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local cUsuario  := Iif(Empty(__cUserID), "000000", __cUserID)
    Local cStatLab  := ""
    Local cRotPes   := ""
    Local cFilter   := ""

    Default cOrdem  := ""

    If Empty(Alltrim(cValToChar(cCP)))
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("SC5")
    SC5->(DbsetOrder(1))
    SC5->(DbGoTop())

    DbSelectArea("SC6")
    SC6->(DbsetOrder(1))
    SC6->(DbGoTop())

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    ZIB->(DbGoTop())

    If ! ZIB->( DbSeek( FWxFilial("ZIB") + cCP ) )
        Help(Nil, Nil, "Função ADFAT168(ADFAT016P)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida lote.
    If ! U_ADFAT18C(cProdSAG, cProdPro, cLote) 
        RestArea(aArea)
        Return .F.

    EndIf

    cRotPes := ZIB->ZIB_CODROT

    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())

    Begin Transaction

        If ! ZIA->(DbSeek( FWxFilial("ZIA") + cRotPes + cProdSAG ))
            cMsgError := "O produto " + Alltrim(cValToChar(cProdSAG)) + " não pode ser pesado no roteiro " + Alltrim(cValToChar(cRotPes)) + "."
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
        oModel:SetValue("MD_MASTER", "ZIF_CLIFOR", cCliFor)
        oModel:SetValue("MD_MASTER", "ZIF_PRDPRO", cProdPro)
        oModel:SetValue("MD_MASTER", "ZIF_PRDSAG", cProdSAG)
        oModel:SetValue("MD_MASTER", "ZIF_QUANT" , nQtd)
        oModel:SetValue("MD_MASTER", "ZIF_TPMOVI", "S")
        oModel:SetValue("MD_MASTER", "ZIF_STATUS", "1")
        oModel:SetValue("MD_MASTER", "ZIF_LOTE"  , cLote)
        oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatLab)
        oModel:SetValue("MD_MASTER", "ZIF_ENVBAR", ZIA->ZIA_MVESTO)
        oModel:SetValue("MD_MASTER", "ZIF_EAGRUP", "2")

        If oModel:VldData()
            oModel:CommitData()
            
            cOrdem := ZIF->ZIF_NUMERO

            If ! SC5->( DbSeek( FWxFilial("SC5") + cPedS ) )
                cMsgError := "SC5-Não foi possível atualizar o pedido " + cPedS  + "."
                lRet := .F.
                DisarmTransaction()
                Break

            Else
                RecLock("SC5")
                    SC5->C5_XLIBSAG := "1"
                SC5->(MsUnlock())

            EndIf

            If ! SC6->( DbSeek( FWxFilial("SC6") + cPedS + cPedSItem ) )
                cMsgError := "SC6-Não foi possível atualizar o item do pedido " + cPedS  + " " + cPedSItem  + " " + cProduto + "."
                lRet := .F.
                DisarmTransaction()
                Break

            Else
                RecLock("SC6")
                    SC6->C6_XORDPES := cOrdem
                    SC6->C6_XLIBSAG := "1"
                SC6->(MsUnlock())

            EndIf

            cFilter := " C6_FILIAL ='" + FWxFilial("SC6") + "' .And. C6_NUM = '" + cPedS + "' "
	
            U_ADFAT27D("SC5", 1, FWxFilial("SC5") + cPedS,;
                    "SC6", 1, FWxFilial("SC6") + cPedS, "C6_ITEM", cFilter,;
                    "pedidos_de_saida_protheus", "I",;
                    .T., .T.,.T., Nil)

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

    End Transaction

    If ValType(oModel) <> "U"
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

    EndIf

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT168(ADFAT016P)", Nil, "Erro na geração de registro de ordem de pesagem(S)." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT16C
    Executa exclusão de ordem de pesagem do tipo "Saída".
    @type  User Function
    @author Everson
    @since 25/03/2022
    @version 01
/*/
User Function ADFAT16C(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cPedS     := ""
    Local cFilter   := ""
    Local lLibSC6   := .F.
    Local oModel    := Nil
    Local aError    := {}

    Default cMsgError   := ""

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não encontrada."
        Help(Nil, Nil, "Função ADFAT16C(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())
    
    DbSelectArea("SC6")
    SC6->(DbSetOrder(17))
    SC6->(DbGoTop())

    oModel := FwLoadModel("ADFAT016P")
    oModel:SetOperation(MODEL_OPERATION_DELETE)
    oModel:Activate()

    Begin Transaction

        If oModel:VldData()
            oModel:CommitData()

            If SC6->( DbSeek( FWxFilial("SC6") + cNmOrdem ) )

                cPedS := SC6->C6_NUM

                RecLock("SC6")
                    SC6->C6_XORDPES := ""
                SC6->(MsUnlock())

                lLibSC6 := U_ADFAT16D(cPedS)

                If ! SC5->( DbSeek( FWxFilial("SC5") + cPedS ) )
                    cMsgError := "SC5-Não foi possível atualizar o pedido " + cPedS  + "."
                    DisarmTransaction()
                    Break

                Else
                    RecLock("SC5")
                        SC5->C5_XLIBSAG := Iif(lLibSC6,"2","1")
                    SC5->(MsUnlock())

                EndIf

                cFilter := " C6_FILIAL ='" + FWxFilial("SC6") + "' .And. C6_NUM = '" + cPedS + "' "

                U_ADFAT27D("SC5", 1, FWxFilial("SC5") + cPedS,;
                        "SC6", 1, FWxFilial("SC6") + cPedS, "C6_ITEM", cFilter,;
                        "pedidos_de_saida_protheus", "A",;
                        .T., .T.,.T., Nil)

                lRet := .T.

            EndIf

        Else
            aError := oModel:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT166(ADFAT016P)", Nil, "Erro na exclusão de registro da ordem de pesagem " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT16D
    Verifica se todos os itens do pedido de saída estão liberados do corte de produto.
    @type  User Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT16D(cPedS)

    //Variáveis.
    Local aArea     := GetArea()
    Local lLibSC6   := .T.

    SC6->(DbSetOrder(1))
    SC6->(DbGoTop())
    If ! SC6->( DbSeek( FWxFilial("SC6") + cPedS ) )
        RestArea(aArea)
        Return .T.

    EndIf

    While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cPedS

        If Alltrim(cValTochar(SC6->C6_XLIBSAG)) == "1"
            lLibSC6 := .F.
            
        EndIf

        SC6->(DbSkip())

    End

    RestArea(aArea)

Return lLibSC6
/*/{Protheus.doc} ADFAT16B
    Deleta todas as ordens de pesagem do tipo "Saída" não utilizadas e vinculadas a controle de pátio.
    @type  User Function
    @author Everson
    @since 23/03/2022
    @version 01
/*/
User Function ADFAT16B(cCP)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    ZIF->(DbGoTop())

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    DbSelectArea("SC6")
    SC6->(DbSetOrder(17))
    SC6->(DbGoTop())

    DbSelectArea("SC5")
    SC6->(DbSetOrder(1))
    SC6->(DbGoTop())

    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cCP ) )
        RestArea(aArea)
        Return .T.

    EndIf

    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP

        If ZIG->( DbSeek( FWxFilial("ZIG") + ZIF->ZIF_NUMERO )) 
            ZIF->(DbSkip())
            Loop

        EndIf
        
        If ! U_ADFAT16C(ZIF->ZIF_NUMERO)
            lRet := .F.
            Exit

        EndIf

        ZIF->(DbSkip())

    End

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT164
    Executa a atualização de status da ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
User Function ADFAT164(cNmOrdem, cStatus, nStatus, cMsgError)
    
    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}

    Default cMsgError := ""

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não encontrada."
        Help(Nil, Nil, "Função atlStOrd(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT016P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate() 

    If nStatus == 1 //Status da ordem.
        oModel:SetValue("MD_MASTER", "ZIF_STATUS", cStatus)

    ElseIf nStatus == 2 //Status laboratório.
        oModel:SetValue("MD_MASTER", "ZIF_STATLA", cStatus)

    ElseIf nStatus == 3 //Status lacre.
        oModel:SetValue("MD_MASTER", "ZIF_STATLC", cStatus)

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
        Help(Nil, Nil, "Função ADFAT164(ADFAT016P)", Nil, "Erro na atualização de registro de ordem de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT165
    Atualiza ordem de pesagem.
    @type  User Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
User Function ADFAT165(cNmOrdem, cCampo, xValor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""
    
    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não encontrada."
        Help(Nil, Nil, "Função ADFAT165(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

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
        Help(Nil, Nil, "Função ADFAT165(ADFAT016P)", Nil, "Erro na atualização de registro da ordem de pesagem " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT166
    Executa exclusão de ordem de pesagem.
    @type  User Function
    @author Everson
    @since 22/02/2022
    @version 01
/*/
User Function ADFAT166(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}

    Default cMsgError := ""

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não encontrada."
        Help(Nil, Nil, "Função ADFAT166(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT016P")
    oModel:SetOperation(MODEL_OPERATION_DELETE)
    oModel:Activate()

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
        Help(Nil, Nil, "Função ADFAT166(ADFAT016P)", Nil, "Erro na exclusão de registro da ordem de pesagem " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT16
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 14/02/2022
    @version 01
/*/
User Function ADFAT16()

    //Variáveis.
    Local aArea     := GetArea()
	Local aParam	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
    Local oModelx   := Nil
    Local nOperation:= 0
    Local cNumero   := ""
    Local cEnvBar   := ""

	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZIF_NUMERO")
            cEnvBar := oModelx:GetValue("MD_MASTER", "ZIF_ENVBAR")

            If nOperation == MODEL_OPERATION_INSERT
                cOperacao := "I"

            ElseIf nOperation == MODEL_OPERATION_UPDATE
                cOperacao := "A"

            ElseIf nOperation == MODEL_OPERATION_DELETE
                cOperacao := "D"

            EndIf

            If cEnvBar == "1" .And. ! Empty(cOperacao) .And. ! Empty(cNumero)
                grvBarr(cOperacao, cNumero)

            EndIf

		EndIf

	EndIf

    RestArea(aArea)

Return xRet
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  User Function
    @author Everson
    @since 14/02/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C("ZIF", 2, "ordens_de_pesagem_protheus", cOperacao, FWxFilial("ZIF") + cNumero)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT16A
    Posiciona no registro de ordem de pesagem.
    @type  User Function
    @author Everson
    @since 31/03/2022
    @version 01
/*/
User Function ADFAT16A(cNmOrdem)

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(2))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADFAT16E
    Posiciona no registro de ordem de pesagem pelo número da ordem de ração.
    @type  User Function
    @author Everson
    @since 17/05/2022
    @version 01
/*/
User Function ADFAT16E(cOrdemC)

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(7))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cOrdemC) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADFAT16F
    Posiciona no registro de ordem de pesagem pelo número do agrupador.
    @type  User Function
    @author Everson
    @since 13/06/2022
    @version 01
/*/
User Function ADFAT16F(cAgrupador)

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(3))
    If ! ZIF->( DbSeek( FWxFilial("ZIF") + cAgrupador) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADFAT16G
    Obtém a quantidade de ordens e peso total dentro do agrupador.
    @type  User Function
    @author Everson
    @since 17/06/2022
    @version 01
/*/
User Function ADFAT16G(cAgrupador)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local nTotOrd   := 0
    Local nPesoT    := 0

    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " COUNT(DISTINCT ZIF_NUMERO) AS QTD_ORDENS, SUM(ZIF_QUANT) AS QTD_PEST " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
    cQuery += " WHERE " 
    cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
    cQuery += " AND ZIF_AGRUPA = '" +  cAgrupador + "' " 
    cQuery += " AND ZIF.D_E_L_E_T_ = '' " 

    If Select("D_TAGRP") > 0
        D_TAGRP->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_TAGRP"
    DbSelectArea("D_TAGRP")
    If ! D_TAGRP->(Eof())

        nTotOrd := Val(cValToChar(D_TAGRP->QTD_ORDENS))
        nPesoT  := Val(cValToChar(D_TAGRP->QTD_PEST))

    EndIf
    D_TAGRP->(DbCloseArea())

    RestArea(aArea)

Return {nTotOrd, nPesoT}
/*/{Protheus.doc} User Function ADFAT16J
    Envia ordem para o barramento.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADFAT16J()

    //Variáveis.
    Local aArea     := GetArea()
    Local cNmOrdem  := ZIF->ZIF_NUMERO

    If ! MsgYesNo("Deseja enviar a ordem de pesagem " + cNmOrdem + "?", "Função ADFAT16J(ADFAT016P)")
        RestArea(aArea)
        Return Nil

    EndIf

    grvBarr("A", cNmOrdem)

    RestArea(aArea)
    
Return Nil
