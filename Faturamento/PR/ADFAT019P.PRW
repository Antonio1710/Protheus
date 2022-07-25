#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIG"
Static cTitulo := "Ticket de Pesagem"
Static cTiMast := "Dados do Ticket de Pesagem"
Static xPula   := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADFAT019P
    Cadastro de Ticket de Pesagem.
    Cad Ticket Pesagem
    Chamado 18465.
    @type  Function
    @author Everson
    @since 19/11/2021
    @version 01
    @history, Everson, 26/06/2022, Ticket 18465 - Tratamento para não deixar abrir pesagem quando há nota fiscal vinculada
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
    
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '1'", "BR_AZUL"        , "Não iniciada")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '2'", "BR_VERDE"       , "Peso inicial")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '3'", "BR_VERDE_ESCURO", "Peso final")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '4'", "BR_VERMELHO"    , "Sequestrada")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '5'", "BR_LARANJA"     , "Sequestro liberado")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT019P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0

    If FWIsAdmin()
        ADD OPTION aRotina TITLE "Incluir" 	ACTION "VIEWDEF.ADFAT019P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
        ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.ADFAT019P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
        ADD OPTION aRotina TITLE "Excluir" 	     ACTION "VIEWDEF.ADFAT019P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0

    EndIf

    ADD OPTION aRotina TITLE "Abrir Pesagem" ACTION "U_ADFAT19B()"       OPERATION 10  ACCESS 0

Return aRotina
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
    Local cNumTkt    := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_NUMERO")))
    Local cPesInicia := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_INICIA")))
    Local cCP        := oModel:GetValue("MD_MASTER", "ZIG_CTPATI")
    Local cTktGua    := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_NUMGUA")))
    // Local cNmOrdem   := oModel:GetValue("MD_MASTER", "ZIG_ORDEM")
    // Local cTpOrdem   := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_TPMOV")))
    
    Local nPesIni    := oModel:GetValue("MD_MASTER", "ZIG_PESINI")
    Local cPesIniD   := Alltrim(cValToChar(DToS(oModel:GetValue("MD_MASTER", "ZIG_DTPES1"))))
    Local cPesIniH   := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_HRPES1")))
    
    Local nPesFim    := oModel:GetValue("MD_MASTER", "ZIG_PESFIM")
    Local cPesFimD   := Alltrim(cValToChar(DToS(oModel:GetValue("MD_MASTER", "ZIG_DTPES2"))))
    Local cPesFimH   := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_HRPES2")))

    Local nPesLiq    := oModel:GetValue("MD_MASTER", "ZIG_PESOLI")

    Local cPesManual := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_MANUAL")))
    Local cPesAutoma := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_AUTOMA")))
    Local cSeq       := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIG_SEQTKT")))
    Local cMsgError  := ""
    Local cBalanca   := ""
    Local cUrl       := ""

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        If lRet .And. Empty(cSeq)
            cSeq := cValToChar(Val(cValToChar(obtSeq(cCP) )) + 10)
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
        
        If ! FWIsInCallStack("U_ADFAT17P") .And. cPesInicia <> "1"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, "O ticket de pesagem vinculado não pode ser cancelado, pois já possui pesagem iniciada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. ! Empty(cTktGua)
        
            cBalanca   := Posicione("ZIG", 1, FWxFilial("ZIG") + cNumTkt, "ZIG_BALANC")
            cUrl       := Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + cBalanca, "DX5_URL")))

            If ! FWIsInCallStack("U_ADFAT17Q") .And. ! U_ADFAT249(cUrl, @cMsgError, cTktGua, 4, "WS G", "01")
                lRet := .F.
                Help(Nil, Nil, "Função vldPos(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            EndIf

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
/*/{Protheus.doc} ADFAT191
    Altera ticket de pesagem.
    @type  User Function
    @author Everson
    @since 15/12/2021
    @version 01
/*/
User Function ADFAT191(cTicket, cCampo, xValor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " não encontrado."
        Help(Nil, Nil, "Função ADFAT191(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT019P")
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
        Help(Nil, Nil, "Função ADFAT191(ADFAT019P)", Nil, "Erro na atualização de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT19
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 14/02/2022
    @version 01
/*/
User Function ADFAT19()

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
            cNumero := oModelx:GetValue("MD_MASTER", "ZIG_NUMERO")
            cEnvBar := oModelx:GetValue("MD_MASTER", "ZIG_ENVBAR")

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
    @type  Static Function
    @author Everson
    @since 14/02/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C("ZIG", 1, "ticket_de_pesagem_protheus", cOperacao, FWxFilial("ZIG") + cNumero)

    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} ADFAT19A
    Carrega dados da pesagens anterior.
    @type  User Function
    @author Everson
    @since 14/02/2022
    @version 01
/*/
User Function ADFAT19A(cCP, cNmOrdem, aDdPAnt)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local cQuery:= ""

    cQuery += " SELECT  " 
    cQuery += " TOP  1 *  " 
    cQuery += " FROM " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG  " 
    cQuery += " WHERE  " 
    cQuery += " ZIG_FILIAL = '" + FWxFilial("ZIG") + "'  " 
    cQuery += " AND ZIG_CTPATI = '" + cCP + "' " 
    cQuery += " AND ZIG_PESFIM > 0 " 
    cQuery += " AND ZIG_ORDEM <> " + cNmOrdem + " " 
    cQuery += " AND ZIG_DTPES2 <> '' " 
    cQuery += " AND ZIG_HRPES2 <> '' " 
    cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIG_DTPES2 DESC, ZIG_HRPES2 DESC " 

    If Select("D_PANT") > 0
        D_PANT->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PANT"
    DbSelectArea("D_PANT")

    If ! D_PANT->(Eof())
        lRet := .T.

        Aadd(aDdPAnt,{;
            D_PANT->ZIG_NUMERO,;
            D_PANT->ZIG_PESFIM,;
            D_PANT->ZIG_DTPES2,;
            D_PANT->ZIG_HRPES2;
        })

    EndIf

    D_PANT->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT192
    Ajusta sequência de pesagem.
    @type  User Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
User Function ADFAT192(cCP, cOrdeSlc, cTktNv, cSeqNV, cMsgError) //Ordem de pesagem selecionada e novo ticket de pesagem.

    //Variáveis.
    Local aArea    := GetArea()
    Local lRet     := .F.
    
    Local cStat2   := ""
    Local cSeq2    := ""
    Local cTkt2    := ""
    Local cStaTkt  := ""
    Local nPesOrd1 := 0
    Local cAgrSlc  := ""

    Local cOrd2    := ""
    Local cStatNv  := ""
    Local cTktSq2  := Posicione("ZIG", 5, FWxFilial("ZIG") + cCP + cSeqNV, "ZIG_NUMERO") //Ticket de pesagem da sequência trocada.
    Local nPesOrd2 := 0
    Local cAgr2    := ""

    Default cMsgError := ""

    //Obtém dados da ordem selecionada.
    If U_ADFAT16A(cOrdeSlc) //Valida se é ordem de pesagem.

        cStat2   := ZIF->ZIF_STATUS //Status da ordem de pesagem selecionada.
        cSeq2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_SEQTKT") //Sequência de pesagem da ordem selecionada.
        cTkt2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_NUMERO") //Ticket de pesagem da ordem selecionada.
        cStaTkt  := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_INICIA") //Ticket de pesagem da ordem selecionada.
        nPesOrd1 := ZIF->ZIF_QUANT //Peso da ordem selecionada.


    ElseIf U_ADFAT16F(cOrdeSlc) //Valida se é agrupador.

        cAgrSlc  := ZIF->ZIF_AGRUPA
        cStat2   := ZIF->ZIF_STATUS //Status da ordem de pesagem selecionada.
        cSeq2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cAgrSlc, "ZIG_SEQTKT") //Sequência de pesagem da ordem selecionada.
        cTkt2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cAgrSlc, "ZIG_NUMERO") //Ticket de pesagem da ordem selecionada.
        cStaTkt  := Posicione("ZIG", 2, FWxFilial("ZIG") + cAgrSlc, "ZIG_INICIA") //Ticket de pesagem da ordem selecionada.
        nPesOrd1 := U_ADFAT16G(cAgrSlc)[1]

    Else

        cMsgError := "Ordem/agrupador " + cOrdeSlc + " não localizada(ADFAT019P-ADFAT192)"
        RestArea(aArea)
        Return .F.

    EndIf

    cOrd2 := Posicione("ZIG", 1, FWxFilial("ZIG") + cTktNv,"ZIG_ORDEM") //Ordem de pesagem vinculada ao novo ticket de pesagem.

    //Obtém dados da ordem trocada.
    If U_ADFAT16A(cOrd2) //Valida se é ordem de pesagem.

        cStatNv  := ZIF->ZIF_STATUS //Novo status.
        nPesOrd2 := ZIF->ZIF_QUANT  //Peso da ordem selecionada.


    ElseIf U_ADFAT16F(cOrd2) //Valida se é agrupador.

        cAgr2    := ZIF->ZIF_AGRUPA
        cStatNv  := ZIF->ZIF_STATUS      //Novo status.
        nPesOrd2 := U_ADFAT16G(cAgr2)[2] //Quantidade do agrupador.

    Else

        cMsgError := "Ordem/agrupador " + cOrd2 + " não localizada(ADFAT019P-ADFAT192)"
        RestArea(aArea)
        Return .F.

    EndIf

    If cStaTkt == "4" .Or. (cOrdeSlc == cOrd2 .And.;
                           cSeqNV == cSeq2 .And.;
                           cStatNv == cStat2 .And.;
                           cTkt2 == cTktSq2 .And.;
                           nPesOrd1 == nPesOrd2)
       
        RestArea(aArea)
        Return .T.

    EndIf

    Begin Transaction

        If Empty(cAgrSlc)
        
            //Altera o status da ordem selecionada.
            If ! U_ADFAT164(cOrdeSlc, cStatNv, 1, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        Else

            //Altera o status das ordens vinculadas ao agrupador.
            If ! altAgrup(cAgrSlc, cStatNv, @cMsgError)
                DisarmTransaction()
                Break

            EndIf


        EndIf

        If Empty(cAgr2)
        
            //Altera o status da ordem tomada.
            If ! U_ADFAT164(cOrd2, cStat2, 1, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        Else

            //Altera o status das ordens tomadas vinculadas ao agrupador.
            If ! altAgrup(cAgr2, cStat2, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        EndIf

        //Altera a ordem do ticket de pesagem selecionado.
        If ! U_ADFAT191(cTktNv, "ZIG_ORDEM", cOrdeSlc, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT191(cTktNv, "ZIG_AGRUPA", Iif(Empty(cAgrSlc), "2", "1"), @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera a ordem do ticket de pesagem tomado.
        If ! U_ADFAT191(cTkt2, "ZIG_ORDEM", cOrd2, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        If ! U_ADFAT191(cTkt2, "ZIG_AGRUPA", Iif(Empty(cAgr2), "2", "1"), @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera o peso da ordem no ticket de pesagem selecionado.
        If ! U_ADFAT191(cTktNv, "ZIG_PESORD", nPesOrd1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera o peso da ordem no ticket de pesagem tomado.
        If ! U_ADFAT191(cTkt2, "ZIG_PESORD", nPesOrd2, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        If cTktNv <> cTktSq2

            //Altera sequência do ticket de pesagem selecionado.
            If ! U_ADFAT191(cTktNv, "ZIG_SEQTKT", cSeqNv, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

            //Altera sequência do ticket de pesagem tomado.
            If ! U_ADFAT191(cTktSq2, "ZIG_SEQTKT", cSeq2, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        EndIf

        lRet := .T.

    End transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} altAgrup
    Altera ordens do agrupamento.
    @type  User Function
    @author Everson
    @since 17/06/2022
    @version 01
/*/
Static Function altAgrup(cAgrupador, cStatus, cMsgError)

    //Variáveis
    Local aArea := GetArea()

    Default cMsgError := ""

    If ! U_ADFAT16F(cAgrupador)
        cMsgError := "Ordem/agrupador de pesagem " + cAgrupador + " não localizada."
        Help(Nil, Nil, "Função altAgrup(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == cAgrupador

                If ! U_ADFAT164(ZIF->ZIF_NUMERO, cStatus, 1, @cMsgError)
                    DisarmTransaction()
                    Break

                EndIf

            ZIF->(DbSkip())

        End

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função altAgrup(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT193
    Processa cancelamento de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 04/03/2022
    @version 01
/*/
User Function ADFAT193(cTicket, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel   := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " não localizado."
        Help(Nil, Nil, "Função ADFAT193(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT019P")
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
        Help(Nil, Nil, "Função ADFAT193(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT193
    Efetua liberação de sequestro de ticket de pesagem de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 04/03/2022
    @version 01
/*/
User Function ADFAT194(cTicket, cTpLSeq, cObs)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local oModel   := Nil

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " não localizado."
        Help(Nil, Nil, "Função ADFAT194(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT019P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    oModel:SetValue("MD_MASTER" , "ZIG_DTLSEQ" , Date())
    oModel:SetValue("MD_MASTER"  , "ZIG_HRLSEQ" , Time())
    oModel:SetValue("MD_MASTER"  , "ZIG_TPLSEQ" , cTpLSeq)
    oModel:SetValue("MD_MASTER"  , "ZIG_OBLSEQ" , cObs)
    oModel:SetValue("MD_MASTER"  , "ZIG_USLSEQ" , __cUserID)
    oModel:SetValue("MD_MASTER"  , "ZIG_NMLSEQ" , cUserName)
    oModel:SetValue("MD_MASTER"  , "ZIG_INICIA" , "5")

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
        Help(Nil, Nil, "Função ADFAT194(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} Static Function ADFAT195
	Posiciona no registro de ticket de pesagem.
	@type  Static Function
	@author Everson
	@since 07/03/2022
	@version 01
/*/
User Function ADFAT195(cTicket)

    //Variáveis.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cTicket ) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} Static Function ADFAT196
	Posiciona no registro de ticket de pesagem pela ordem de pesagem.
	@type  Static Function
	@author Everson
	@since 10/03/2022
	@version 01
/*/
User Function ADFAT196(cNmOrdem)

    //Variáveis.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cNmOrdem ) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} User Function ADFAT19B
    Abrir pesagem.
    @type  Function
    @author Everson
    @since 09/05/2022
    @version 01
    /*/
User Function ADFAT19B()

    //Variáveis.
    Local aArea     := GetArea()
    Local cTicket   := ZIG->ZIG_NUMERO
    Local oModal    := Nil
    Local aOrdens   := {}
    Local nAux      := 1
    Local lAgrupa   := .F.
    Local lEnsacado := .F.

    If ZIG->ZIG_INICIA == "1"
        MsgInfo("Ticket não possui pesagem.", "Função ADFAT19B(ADFAT019R)")
        RestArea(aArea)
        Return Nil

    EndIf

    //Verifica se há ordem de pesagem com peso inicial e sem peso final.
    If ! U_ADFAT19C(ZIG->ZIG_CTPATI, ZIG->ZIG_ORDEM)
        Help(Nil, Nil, "Função ADFAT19B(ADFAT019P)", Nil, "Há ordem de pesagem com peso inicial, mas não finalizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIF

    //Posiciona no registro de pátio selecionado.
    If ! U_ADFAT17U(ZIG->ZIG_CTPATI)
        MsgInfo("Controle de pátio " + ZIG->ZIG_CTPATI + " não localizado.", "Função ADFAT19B(ADFAT019P)")
        RestArea(aArea)
        Return Nil

    EndIf

    //
    If ! U_ADFAT15B(ZIB->ZIB_CODROT)
        MsgInfo("Roteiro de pesagem " + ZIB->ZIB_CODROT + " não localizado.", "Função ADFAT19B(ADFAT019P)")
        RestArea(aArea)
        Return Nil

    EndIf

    lEnsacado := ZI9->ZI9_ENSACA == "1"

    DbSelectArea("SC5") //Everson - 26/05/2022. Chamado 18465.
    SC5->(DbSetOrder(28))
    SC5->(DbGoTop())
    If SC5->( DbSeek( FWxFilial("SC5") + ZIG->ZIG_ORDEM))

        While ! SC5->(Eof()) .And. SC5->C5_FILIAL == FWxFilial("SC5") .And. SC5->C5_XORDPES == ZIG->ZIG_ORDEM 
    
            If Empty(SC5->C5_PEDSAG) .And. ! Empty(SC5->C5_NOTA)

                MsgInfo("Há a nota fiscal " + SC5->C5_NOTA + " " + SC5->C5_SERIE + " vinculada à pesagem. Operação não permitida.", "Função ADFAT19B(ADFAT019R)")
                RestArea(aArea)
                Return Nil            

            EndIf

            SC5->(DbSkip())

        End

    EndIf

    lAgrupa := ZIG->ZIG_AGRUPA == "1"

    If ! lAgrupa //Ticket não é referente a ordens de pesagem agrupadas.
        
        Aadd(aOrdens, ZIG->ZIG_ORDEM)

    Else

        If ! U_ADFAT16F(ZIG->ZIG_ORDEM)
            MsgInfo("Agrupador " + ZIG->ZIG_ORDEM + " não localizado.", "Função ADFAT19B(ADFAT019R)")
            RestArea(aArea)
            Return Nil  

        EndIf

        While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_AGRUPA == ZIG->ZIG_ORDEM

            Aadd(aOrdens, ZIF->ZIF_NUMERO)

            ZIF->(DbSkip())

        End

    EndIf

    DbSelectArea("SC6")
    SC6->(DbSetOrder(17))
    SC6->(DbGoTop())

    For nAux := 1 To Len(aOrdens)

        If SC6->(DbSeek( FWxFilial("SC6") + aOrdens[nAux] ))

            While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_XORDPES == aOrdens[nAux]

                If ! Empty(SC6->C6_NOTA)

                    MsgInfo("Há a nota fiscal " + SC6->C6_NOTA + " " + SC6->C6_SERIE + " vinculada à pesagem. Operação não permitida.", "Função ADFAT19B(ADFAT019R)")
                    RestArea(aArea)
                    Return Nil            

                EndIf

                SC6->(DbSkip())

            End

        EndIf

    Next nAux

    oModal := FWDialogModal():New() 
    oModal:SetBackground( .T. ) 
	oModal:setTitle("Abrir Pesagem - Ticket " + cTicket)
	oModal:setSize( 070 , 200 )
    oModal:EnableFormBar( .T. )
    oModal:SetEscClose(.F.)
	oModal:createDialog()
    oModal:CreateFormBar()
    oModal:addCloseButton(Nil, "Cancelar")

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        TButton():New(005,010,"1-Refazer pesagem inicial" , oContainer,{|| Iif(! procAbrP(cTicket, "1", lEnsacado, ZIG->ZIG_TPMOV), Nil, oModal:DeActivate()) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New(005,110,"2-Refazer pesagem final"   , oContainer,{|| Iif(! procAbrP(cTicket, "2", lEnsacado, ZIG->ZIG_TPMOV), Nil, oModal:DeActivate()) },080,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	oModal:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} procAbrP
    Processa a abertura da pesagem.
    @type  Static Function
    @author Everson
    @since 09/05/2022
    @version 01
/*/
Static Function procAbrP(cTicket, cStatus, lEnsacado, cTpMov)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cCP       := ZIG->ZIG_CTPATI
    Local cNmOrdem  := ZIG->ZIG_ORDEM
    Local cTpOrdem  := ZIG->ZIG_TPMOV
    Local cMsgError := ""

    If cStatus == ZIG->ZIG_INICIA
        MsgInfo("Ticket já está com o status solicitado.", "Função procAbrP(ADFAT019R)")
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no controle de pátio.
    If ! U_ADFAT17U(cCP)
        MsgInfo("Controle de pátio " + cCP + " não localizado.", "Função procAbrP(ADFAT019R)")
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida controle de pátio.
    If ! U_ADFAT179(ZIB->ZIB_PLACA, cCP, "", .T.)
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        lRet := lRet .And. U_ADEST739(cNmOrdem, @cMsgError)

        //Atualiza ticket de pesagem.
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_INICIA", cStatus)

        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_DTPES2",CToD("//"))
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_HRPES2", "")
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_PESFIM", 0)
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_PESOLI", 0)

        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_UNTOLE", "")
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_QTTOLE", 0)
        lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_QUEBRA", 0)

        If cStatus == "1"
            lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_DTPES1", CToD("//"))
            lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_HRPES1", "")
            lRet := lRet .And. U_ADFAT191(cTicket, "ZIG_PESINI", 0)

        EndIf
        //

        If cTpOrdem $"O/R/S" .And. cStatus == "1" //Liberado/Aguardando pesagem.
            cStatOrd := "2"

        ElseIf cTpOrdem == "E" .And. cStatus == "1" //Liberado/Aguardando pesagem.
            cStatOrd := "8"
        
        ElseIf cTpOrdem $"O/R/S" .And. cStatus == "2" //Pesagem inicial.
            cStatOrd := "4"

        ElseIf cTpOrdem == "E" .And. cStatus == "2" //Pesagem inicial.
            cStatOrd := "10"

        EndIf

        If U_ADFAT17W(cCP) < 2
            cStatCp  := "3"

        Else
            cStatCp  := "4"

        EndIf

        lRet := lRet .And. U_ADFAT175(cNmOrdem, cStatOrd, 1) //Atualiza status da ordem.

        lRet := lRet .And. U_ADFAT174(cCP, "ZIB_STATUS", cStatCp) //Atualiza status do controle de pátio.

        lRet := lRet .And. logZBE("Abertura de pesagem do ticket " + cTicket + " para status " + cStatus)

        If lRet .And. lEnsacado .And. cTpMov == "S" .And. U_ADEST738(cNmOrdem) .And. ! U_ADEST735(cNmOrdem, 3, "ZIL_PESADO", "2")
            lRet := .F.

        EndIf

        If ! lRet
            DisarmTransaction()
            Break

        EndIf

    End Transaction

    If lRet
        MsgInfo("Pesagem aberta.", "Função procAbrP(ADFAT019P)")

    Else
        Help(Nil, Nil, "Função procAbrP(ADEST019P)", Nil, "Ocorreu erro na abertura da pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} nomeStaticFunction
    Gera log na tabela ZBE.
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function logZBE(cMsg)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With Date()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMsg
		Replace ZBE_MODULO	    With "FATURAMENTO"
		Replace ZBE_ROTINA	    With "ADFAT019P" 
	ZBE->( msUnlock() )

Return .T.
/*/{Protheus.doc} ADFAT197
    Ajusta sequência de pesagem de ordem agrupadas.
    @type  User Function
    @author Everson
    @since 17/06/2022
    @version 01
/*/
User Function ADFAT197(cCP, cOrdeSlc, cTktNv, cSeqNV, cMsgError) //Ordem de pesagem selecionada e novo ticket de pesagem.

    //Variáveis.
    Local aArea    := GetArea()
    Local lRet     := .F.
    Local cOrd2    := Posicione("ZIG", 1, FWxFilial("ZIG") + cTktNv,"ZIG_ORDEM")  //Ordem de pesagem vinculada ao novo ticket de pesagem.
    Local cStatNv  := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrd2, "ZIF_STATUS") //Novo status.
    Local cStat2   := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrdeSlc, "ZIF_STATUS") //Status da ordem de pesagem selecionada.
    Local cSeq2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_SEQTKT") //Sequência de pesagem da ordem selecionada.
    Local cTkt2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_NUMERO") //Ticket de pesagem da ordem selecionada.
    Local cStaTkt  := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_INICIA") //Ticket de pesagem da ordem selecionada.
    Local cTktSq2  := Posicione("ZIG", 5, FWxFilial("ZIG") + cCP + cSeqNV, "ZIG_NUMERO") //Ticket de pesagem da sequência trocada.
    Local nPesOrd1 := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrdeSlc, "ZIF_QUANT") //Peso da ordem selecionada.
    Local nPesOrd2 := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrd2, "ZIF_QUANT") //Peso da ordem trocada.

    Default cMsgError := ""

    If cStaTkt == "4" .Or. (cOrdeSlc == cOrd2 .And.;
                           cSeqNV == cSeq2 .And.;
                           cStatNv == cStat2 .And.;
                           cTkt2 == cTktSq2 .And.;
                           nPesOrd1 == nPesOrd2)
       
        RestArea(aArea)
        Return .T.

    EndIf

    Begin Transaction

        //Altera o status da ordem selecionada.
        If ! U_ADFAT164(cOrdeSlc, cStatNv, 1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf
        
        //Altera o status da ordem tomada.
        If ! U_ADFAT164(cOrd2, cStat2, 1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera a ordem do ticket de pesagem selecionado.
        If ! U_ADFAT191(cTktNv, "ZIG_ORDEM", cOrdeSlc, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera a ordem do ticket de pesagem tomado.
        If ! U_ADFAT191(cTkt2, "ZIG_ORDEM", cOrd2, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera o peso da ordem no ticket de pesagem selecionado.
        If ! U_ADFAT191(cTktNv, "ZIG_PESORD", nPesOrd1, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera o peso da ordem no ticket de pesagem tomado.
        If ! U_ADFAT191(cTkt2, "ZIG_PESORD", nPesOrd2, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        If cTktNv <> cTktSq2

            //Altera sequência do ticket de pesagem selecionado.
            If ! U_ADFAT191(cTktNv, "ZIG_SEQTKT", cSeqNv, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

            //Altera sequência do ticket de pesagem tomado.
            If ! U_ADFAT191(cTktSq2, "ZIG_SEQTKT", cSeq2, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        EndIf

        lRet := .T.

    End transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT19C
    Verifica se há ordem de pesagem com peso inicial e sem peso final.
    @type  Static Function
    @author Everson
    @since 21/06/2022
    @version 01
/*/
User Function ADFAT19C(cCP, cNmOrdem)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(5))
    ZIG->(DbGoTop())
    If ZIG->( DbSeek( FWxFilial("ZIG") + cCP ) )

        While ! ZIG->(Eof()) .And. ZIG->ZIG_FILIAL == FWxFilial("ZIG") .And. ZIG->ZIG_CTPATI == cCP

            If ZIG->ZIG_INICIA $"2/4/5" .And.; //Peso inicial, Sequestrada e Sequestro Liberado.
               ZIG->ZIG_ORDEM <> cNmOrdem
                lRet := .F.
                Exit
                
            EndIf

            ZIG->(DbSkip())
            
        End

    EndIf
    RestArea(aArea)

Return lRet
/*/{Protheu
