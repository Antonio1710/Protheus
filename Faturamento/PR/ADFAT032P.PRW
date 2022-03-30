#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIR"
Static cTitulo := "Ordem de Carregamento de Ra��o"
Static cTiMast := "Dados da ordem de carregamento de ra��o"
Static xPula   := Chr(13) + Chr(10)

Static cMsg1   := "Ordem de carregamento possui roteiro."
Static cMsg2   := "Ordem de pesagem est� vinculada a ticket de pesagem."

/*/{Protheus.doc} User Function ADFAT032P
    Cadastro de ordem de carregamento de ra��o.
    Cad Ordem Ra��o.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 21/02/2022
    @version 01
    /*/
User Function ADFAT032P() // U_ADFAT032P()

    //Vari�veis.
    Local oBrowse := FwLoadBrw("ADFAT032P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function BrowseDef()

    //Vari�veis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZIR->ZIR_STATUS = '1'", "Blue",  "Pendente")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '2'", "Green", "Aprovada")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '3'", "Black", "N�o aprovada")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '4'", "Red",   "Pesada")
    oBrowse:SetSeeAll(.F.)

    oBrowse:SetMenuDef("ADFAT032P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function MenuDef()

    //Vari�veis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT032P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADFAT032P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADFAT32B(4)" 	    OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "U_ADFAT32B(5)" 	    OPERATION MODEL_OPERATION_DELETE    ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Vari�veis.
    Local bPre      := {|| .T. }
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT32", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPos
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Vari�veis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cAgrupa    := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIR_ORAGRP")))
    Local lAprova    := GetMv("MV_#APRRAC",,.F.)
    Local cOrdemP    := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIR_ORDEM")))

    If lRet .And. nOperation == MODEL_OPERATION_INSERT
    
        If lAprova
            oModel:SetValue("MD_MASTER", "ZIR_STATUS", "2")

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. ! Empty(cOrdemP) .And. ! U_ADFAT32E(cOrdemP, "")
            lRet := .F.
            Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, cMsg2, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf
        
        If lRet .And. ! Empty(cAgrupa)
            lRet := .F.
            Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, cMsg1, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf
 
    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE 

        If lRet .And.;
           ! FWIsInCallStack("U_ADFAT171") .And.;
           ! FWIsInCallStack("U_ADFAT35F") .And.;
           ! Empty(cOrdemP) .And.;
           ! U_ADFAT32E(cOrdemP, "")
            lRet := .F.
            Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, cMsg2, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And.;
            ! Empty(cAgrupa) .And.;
            ! FWIsInCallStack("U_ADFAT34B") .And.; //Montagem de carga.
            ! FWIsInCallStack("U_ADFAT35F") .And.; //Atualiza quantidade da ordem de carregamento.
            ! FWIsInCallStack("U_ADFAT17A") .And.; //Cria��o de ordem de pesagem.
            ! FWIsInCallStack("U_ADFAT171") //Atualiza��o de pesagem final.
            lRet := .F. 
            Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, cMsg1, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf
    
        If lRet .And.;
            ! FWIsInCallStack("U_ADFAT33A") .And.; //Aprova��o de ordem de carregamento.
            ! FWIsInCallStack("U_ADFAT34B") .And.; //Montagem de carga.
            ! FWIsInCallStack("U_ADFAT17A") .And.;//Cria��o de ordem de pesagem.
            ! FWIsInCallStack("U_ADFAT171") //Atualiza��o de pesagem final.

                oModel:SetValue("MD_MASTER","ZIR_STATUS" , Iif(lAprova, "2", "1"))
                oModel:SetValue("MD_MASTER","ZIR_CODAPV" , "")
                oModel:SetValue("MD_MASTER","ZIR_NMAPV"  , "")
                oModel:SetValue("MD_MASTER","ZIR_DTAPV"  , SToD(" / / "))
                oModel:SetValue("MD_MASTER","ZIR_HRAPV"  , "")
                oModel:SetValue("MD_MASTER","ZIR_OK"     , "")

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Vari�veis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT032P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT32B
    Valida��o para altera��o e exclus�o de registro.
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT32B(nOpc)

    //Vari�veis.
    Local aArea     := GetArea()
    Local cAgrupa   := ZIR->ZIR_ORAGRP

    If ! Empty(cAgrupa)
        MsgInfo(cMsg1, "Fun��o ADFAT32B(ADFAT032P)")
        RestArea(aArea)
        Return Nil

    EndIf

    FWExecView("", "ADFAT032P", nOpc)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT32A
    Processa aprova��o das ordens de carregamento de ra��o.
    @type  User Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
User Function ADFAT32A(cOrdemC, cStatus)

    //Vari�veis.
    Local aArea     := GetArea()
    Local aError    := {}
    Local cMsgError := ""
    Local oOrdRac   := FwLoadModel("ADFAT032P")

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(1))
    If ! ZIR->(DbSeek( FWxFilial("ZIR") + cOrdemC ))
        Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, "Ordem de carregamento " + cOrdemC + " n�o encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil
        
    EndIf
    
    oOrdRac:SetOperation(MODEL_OPERATION_UPDATE)
    oOrdRac:Activate() 

    oOrdRac:SetValue("MD_MASTER","ZIR_STATUS" , cStatus)
    oOrdRac:SetValue("MD_MASTER","ZIR_CODAPV" , __cUserId)
    oOrdRac:SetValue("MD_MASTER","ZIR_NMAPV"  , cUserName)
    oOrdRac:SetValue("MD_MASTER","ZIR_DTAPV"  , Date())
    oOrdRac:SetValue("MD_MASTER","ZIR_HRAPV"  , Time())

    If oOrdRac:VldData()
        oOrdRac:CommitData()

    Else
        aError := oOrdRac:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oOrdRac:DeActivate()
    oOrdRac:Destroy()
    oOrdRac := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT32C
    Atualiza dados da carga.
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT32C(cOrdemC, cCarga, cPlaca, dData)

    //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local aError    := {}
    Local cMsgError := ""
    Local oOrdRac   := FwLoadModel("ADFAT032P")
    Local cTrans    := ""
    Local cLoja     := ""
    Local cNmTrans  := ""

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(1))
    If ! ZIR->(DbSeek( FWxFilial("ZIR") + cOrdemC ))
        Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, "Ordem de carregamento " + cOrdemC + " n�o encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil
        
    EndIf

    If ! Empty(cPlaca)
        DbSelectArea("ZV4")
        ZV4->(DbSetOrder(1))
        If ! ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
            Help(Nil, Nil, "Fun��o ADFAT32A(ADFAT032P)", Nil, "Ve�cula " + cPlaca + " n�o localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return Nil

        EndIf

        cTrans    := ZV4->ZV4_FORNEC
        cLoja     := ZV4->ZV4_LOJFOR
        cNmTrans  := ZV4->ZV4_NOMFOR

    EndIf
    
    oOrdRac:SetOperation(MODEL_OPERATION_UPDATE)
    oOrdRac:Activate() 

    oOrdRac:SetValue("MD_MASTER","ZIR_ORAGRP" , cCarga)
    oOrdRac:SetValue("MD_MASTER","ZIR_PLACA"  , cPlaca)
    oOrdRac:SetValue("MD_MASTER","ZIR_TRANSP" , cTrans)
    oOrdRac:SetValue("MD_MASTER","ZIR_TLOJA"  , cLoja)
    oOrdRac:SetValue("MD_MASTER","ZIR_TNOME"  , cNmTrans)
    oOrdRac:SetValue("MD_MASTER","ZIR_DTCAR"  , dData)
    oOrdRac:SetValue("MD_MASTER","ZIR_ORDEM"  , "")

    If oOrdRac:VldData()
        oOrdRac:CommitData()
        lRet := .T.

    Else
        lRet := .F.
        aError := oOrdRac:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oOrdRac:DeActivate()
    oOrdRac:Destroy()
    oOrdRac := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Fun��o ADFAT32C(ADFAT032P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT165
    Atualiza ordem de carregamento.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT32D(cNmOrdem, aDados, cMsgError)

    //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local nAux      := 1
    
    Default cMsgError := ""
    
    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(1))
    If ! ZIR->(DbSeek( FWxFilial("ZIR") + cNmOrdem ))
        Help(Nil, Nil, "Fun��o ADFAT32D(ADFAT032P)", Nil, "Ordem de carregamento de ra��o " + cNmOrdem + " n�o encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT032P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    For nAux := 1 To Len(aDados)
        oModel:SetValue("MD_MASTER", aDados[nAux][1], aDados[nAux][2])

    Next nAux

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
        Help(Nil, Nil, "Fun��o ADFAT32D(ADFAT032P)", Nil, "Erro na atualiza��o de registro da ordem de carregamento de ra��o " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT32E
    Valida��o de ticket de pesagem.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT32E(cOrdemP, cTicket, cOrdemC)

    //Vari�veis.
    Local aArea := GetArea()
    Local lRet  := .T.

    Default cOrdemP := ""
    Default cTicket := ""
    Default cOrdemC := ""

    If ! Empty(cTicket)
        lRet := .F.

    ElseIf ! Empty(cOrdemP)

        DbSelectArea("ZIG")
        ZIG->(DbSetOrder(2))
        If ZIG->( DbSeek( FWxFilial("ZIG") + cOrdemP))
            lRet := .F.

        EndIf

    ElseIf ! Empty(cOrdemC)

        DbSelectArea("ZIF")
        ZIF->(DbSetOrder(7))
        If ZIF->( DbSeek( FWxFilial("ZIF") + cOrdemC))
            
            DbSelectArea("ZIG")
            ZIG->(DbSetOrder(2))
            If ZIG->( DbSeek( FWxFilial("ZIG") + ZIF->ZIF_NUMERO))
                lRet := .F.

            EndIf

        EndIf  

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADAFT32F
    Gatilho do lote.
    @type  User Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
User Function ADAFT32F(cProSAg)

    //Vari�veis.
    Local aArea  := GetArea()
    Local cLotUs := ""
    Local cLotAb := ""
    Local cLote  := ""

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(3))
    ZI8->(DbGoTop())
    If ZI8->(DbSeek( FWxFilial("ZI8") + cProSAg))

        While ! ZI8->(Eof()) .And. ZI8->ZI8_FILIAL == FWxFilial("ZI8") .And. ZI8->ZI8_PRDSAG == cProSAg

            If ZI8->ZI8_STATUS == "1" //Aberto.
                cLotAb := ZI8->ZI8_CDLOTE

            ElseIf ZI8->ZI8_STATUS == "2" //Em uso.
                cLotUs := ZI8->ZI8_CDLOTE

            EndIf

            ZI8->(DbSkip())

        End

    EndIf

    cLote := Iif(Empty(cLotUs), cLotAb, cLotUs)

    RestArea(aArea)

Return cLote
/*/{Protheus.doc} ADAFT32F
    Copia ordem de carregamento.
    @type  User Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
User Function ADFAT32F(cOrdemC, cPrdSAG, cLote, nQtd, cNvOrdC, cMsgError)

   //Vari�veis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aCampos   := TCStruct(RetSqlName("ZIR"))
    Local cCampo    := ""
    Local xValor    := Nil
    Local nAux      := 1
    Local cPrdPro   := Posicione("ZIM", 1, FWxFilial("ZIM") + cPrdSAG, "ZIM_PRDPRO")
    Local cDesPrd   := Posicione("ZIM", 1, FWxFilial("ZIM") + cPrdSAG, "ZIM_DESSAG")
    Local cDesLot   := Posicione("ZI8", 1, FWxFilial("ZI8") + cLote,   "ZI8_DESLOT")

    Default cNvOrdC   := ""
    Default cMsgError := ""

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(1))
    If ! ZIR->(DbSeek( FWxFilial("ZIR") + cOrdemC ))
        Help(Nil, Nil, "Fun��o ADFAT32F(ADFAT032P)", Nil, "Ordem de carregamento de ra��o " + cOrdemC + " n�o encontrada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT032P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    For nAux := 1 To Len(aCampos)

        cCampo := Alltrim(cValToChar(aCampos[nAux][1]))

        If cCampo == "D_E_L_E_T_" .Or. cCampo == "R_E_C_N_O_" .Or.;
           cCampo == "R_E_C_D_E_L_" .Or. Empty(cCampo) .Or.;
           cCampo == "ZIR_FILIAL" .Or. cCampo == "ZIR_NUMERO" .Or.;
           cCampo == "ZIR_ORDEM" .Or. cCampo == Nil

            Loop
            
        EndIf

        xValor := ZIR->&(cCampo)

        If cCampo == "ZIR_QUANT"
            oModel:SetValue("MD_MASTER", cCampo, nQtd)

        ElseIf cCampo == "ZIR_PRDSAG"
            oModel:SetValue("MD_MASTER", cCampo, cPrdSAG)

        ElseIf cCampo == "ZIR_PRDPRO"
            oModel:SetValue("MD_MASTER", cCampo, cPrdPro)

        ElseIf cCampo == "ZIR_DESC"
            oModel:SetValue("MD_MASTER", cCampo, cDesPrd)

        ElseIf cCampo == "ZIR_LOTPRD"
            oModel:SetValue("MD_MASTER", cCampo, cLote)

        ElseIf cCampo == "ZIR_DESLOT"
            oModel:SetValue("MD_MASTER", cCampo, cDesLot)

        Else
            oModel:SetValue("MD_MASTER", cCampo, xValor)

        EndIf

    Next nAux

    If oModel:VldData()
        oModel:CommitData()
        cNvOrdC := ZIR->ZIR_NUMERO
        lRet := .T.

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Fun��o ADFAT32F(ADFAT032P)", Nil, "Erro na c�pia de registro da ordem de carregamento de ra��o " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT32
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 16/03/2022
    @version 01
/*/
User Function ADFAT32()

    //Vari�veis.
    Local aArea     := GetArea()
	Local aParam	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
    Local nOperation:= 0
    Local cNumero   := ""

	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZIR_NUMERO")

            If nOperation == MODEL_OPERATION_INSERT
                cOperacao := "I"

            ElseIf nOperation == MODEL_OPERATION_UPDATE
                cOperacao := "A"

            ElseIf nOperation == MODEL_OPERATION_DELETE
                cOperacao := "D"

            EndIf

            If ! Empty(cOperacao) .And. ! Empty(cNumero)
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
    @since 16/03/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Vari�veis.
    Local aArea := GetArea()

	U_ADFAT27C("ZIR", 1, "ordens_de_carregamento_de_racao_protheus", cOperacao, FWxFilial("ZIR") + cNumero)

    RestArea(aArea)

Return Nil