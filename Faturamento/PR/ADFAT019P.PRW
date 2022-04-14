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
    /*/
User Function ADFAT019P() // U_ADFAT019P()

    //Vari�veis.
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

    //Vari�veis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT019P")
    
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '1'", "BR_AZUL"        , "N�o iniciada")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '2'", "BR_VERDE"       , "Peso inicial")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '3'", "BR_VERDE_ESCURO", "Peso final")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '4'", "BR_VERMELHO"    , "Sequestrada")
    oBrowse:AddLegend("ZIG->ZIG_INICIA = '5'", "BR_LARANJA"     , "Sequestro liberado")

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
    
    //Vari�veis.
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
    P�s valida��o.
    @type  Static Function
    @author Everson
    @since 24/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Vari�veis.
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
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Necess�rio informar se a pesagem � manual.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If cPesInicia $"2/3" .And. Empty(cPesAutoma)
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Necess�rio informar se a pesagem � autom�tica.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "2" .And. nPesIni <= 0
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Pesagem inicial inv�lida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "2" .And. (Empty(cPesIniD) .Or. Empty(cPesIniH))
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Necess�rio informar data e hora da pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. nPesFim <= 0
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Pesagem fim inv�lida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. (Empty(cPesFimD) .Or. Empty(cPesFimH))
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Necess�rio informar data e hora da pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. cPesInicia == "3" .And. nPesLiq <= 0
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "Peso l�quido inv�lido.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
        
        If ! FWIsInCallStack("U_ADFAT17P") .And. cPesInicia <> "1"
            lRet := .F.
            Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, "O ticket de pesagem vinculado n�o pode ser cancelado, pois j� possui pesagem iniciada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. ! Empty(cTktGua)
        
            cBalanca   := Posicione("ZIG", 1, FWxFilial("ZIG") + cNumTkt, "ZIG_BALANC")
            cUrl       := Alltrim(cValToChar(Posicione("DX5" , 1, FwxFilial("DX5") + cBalanca, "DX5_URL")))

            If ! FWIsInCallStack("U_ADFAT17Q") .And. ! U_ADFAT249(cUrl, @cMsgError, cTktGua, 4, "WS G", "01")
                lRet := .F.
                Help(Nil, Nil, "Fun��o vldPos(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

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
    
    //Vari�veis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT019P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} obtSeq
    Obt�m a sequ�ncia dos tickets vinculados ao controle de p�tio.
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function obtSeq(cCP)

    //Vari�veis.
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

    //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " n�o encontrado."
        Help(Nil, Nil, "Fun��o ADFAT191(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
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
        Help(Nil, Nil, "Fun��o ADFAT191(ADFAT019P)", Nil, "Erro na atualiza��o de ticket de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

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

    //Vari�veis.
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

    //Vari�veis.
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

    //Vari�veis.
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
    Ajusta sequ�ncia de pesagem.
    @type  User Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
User Function ADFAT192(cCP, cOrdeSlc, cTktNv, cSeqNV, cMsgError) //Ordem de pesagem selecionada e novo ticket de pesagem.

    //Vari�veis.
    Local aArea    := GetArea()
    Local lRet     := .F.
    Local cOrd2    := Posicione("ZIG", 1, FWxFilial("ZIG") + cTktNv,"ZIG_ORDEM")  //Ordem de pesagem vinculada ao novo ticket de pesagem.
    Local cStatNv  := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrd2, "ZIF_STATUS") //Novo status.
    Local cStat2   := Posicione("ZIF", 2, FWxFilial("ZIF") + cOrdeSlc, "ZIF_STATUS") //Status da ordem de pesagem selecionada.
    Local cSeq2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_SEQTKT") //Sequ�ncia de pesagem da ordem selecionada.
    Local cTkt2    := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_NUMERO") //Ticket de pesagem da ordem selecionada.
    Local cStaTkt  := Posicione("ZIG", 2, FWxFilial("ZIG") + cOrdeSlc, "ZIG_INICIA") //Ticket de pesagem da ordem selecionada.
    Local cTktSq2  := Posicione("ZIG", 5, FWxFilial("ZIG") + cCP + cSeqNV, "ZIG_NUMERO") //Ticket de pesagem da sequ�ncia trocada.
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

            //Altera sequ�ncia do ticket de pesagem selecionado.
            If ! U_ADFAT191(cTktNv, "ZIG_SEQTKT", cSeqNv, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

            //Altera sequ�ncia do ticket de pesagem tomado.
            If ! U_ADFAT191(cTktSq2, "ZIG_SEQTKT", cSeq2, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

        EndIf

        lRet := .T.

    End transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT193
    Processa cancelamento de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 04/03/2022
    @version 01
/*/
User Function ADFAT193(cTicket, cMsgError)

    //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel   := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " n�o localizado."
        Help(Nil, Nil, "Fun��o ADFAT193(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
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
        Help(Nil, Nil, "Fun��o ADFAT193(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT193
    Efetua libera��o de sequestro de ticket de pesagem de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 04/03/2022
    @version 01
/*/
User Function ADFAT194(cTicket, cTpLSeq, cObs)

    //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local oModel   := Nil

    If ! U_ADFAT195(cTicket)
        cMsgError := "Ticket de pesagem " + cTicket + " n�o localizado."
        Help(Nil, Nil, "Fun��o ADFAT194(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
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
        Help(Nil, Nil, "Fun��o ADFAT194(ADFAT019P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

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

    //Vari�veis.

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

    //Vari�veis.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cNmOrdem ) )
        Return .F.

    EndIf

Return .T.