#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "FWPrintSetup.ch"
#Include "RPTDEF.CH"

Static cTbMast  := "ZHR"
Static cTitulo  := "Refaturamento de Carga de Ração"
Static cTiMast  := "Dados do refaturamento da carga de ração"

/*/{Protheus.doc} User Function ADFAT057P
    Refaturamento de ordem de ração.
    Refaturamento Ração
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/06/2022
    @version 01
    /*/
User Function ADFAT057P() // U_ADFAT057P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT057P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZHR_STATUS = '1' ","BR_VERDE"   , "Aberto"    )
    oBrowse:AddLegend("ZHR_STATUS = '2' ","BR_AZUL"    , "Aprovado"    )
    oBrowse:AddLegend("ZHR_STATUS = '3' ","BR_VERMELHO", "Pedido Gerado" )

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}
    Local cUsrInc := Alltrim(cValToChar(GetMv("MV_#ADF571",,"")))
    Local cUsrApv := Alltrim(cValToChar(GetMv("MV_#ADF572",,"")))
    Local cUsrGer := Alltrim(cValToChar(GetMv("MV_#ADF572",,"")))

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0

    If FWIsAdmin() .Or. __cUserID $cUsrInc
        ADD OPTION aRotina TITLE "Incluir" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
        ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
        ADD OPTION aRotina TITLE "Excluir" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0

    EndIf

    If FWIsAdmin() .Or. __cUserID $cUsrApv
        ADD OPTION aRotina TITLE "Aprovar"  ACTION "U_ADFAT57D()"       OPERATION 10  ACCESS 0

    EndIf

    If FWIsAdmin() .Or. __cUserID $cUsrGer
        ADD OPTION aRotina TITLE "Processar" ACTION "U_ADFAT57E()"       OPERATION 11  ACCESS 0

    EndIf

    ADD OPTION aRotina TITLE "Imp. Ticket" 	ACTION "U_ADFAT57F()" 	   OPERATION 12  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := Nil

    bPost := {|oModel| vldPos(oModel)}

    oModel := MPFormModel():New("ADFAT57", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
    
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,,,,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHR_FILIAL"  , 'FWxFilial("' + cTbMast + '")'},;
            {"ZHR_NUMERO"  , "ZHR_NUMERO"},;
            {"ZHR_PLACA"   , "ZHR_PLACA"},;
            {"ZHR_ROTEIR"  , "ZHR_ROTEIR"},;
            {"ZHR_ORRORI"  , "ZHR_ORRORI"},;
            {"ZHR_ORPORI"  , "ZHR_ORPORI"},;
            {"ZHR_NFORI"   , "ZHR_NFORI"},;
            {"ZHR_SERORI"  , "ZHR_SERORI"},;
            {"ZHR_FORORI"  , "ZHR_FORORI"},;
            {"ZHR_LOJORI"  , "ZHR_LOJORI"},;
            {"ZHR_PRDSAG"  , "ZHR_PRDSAG"},;
            {"ZHR_PRDPRO"  , "ZHR_PRDPRO"},;
            {"ZHR_DESPRT"  , "ZHR_DESPRT"},;
            {"ZHR_MOTIVO"  , "ZHR_MOTIVO"},;
            {"ZHR_ROTEIR"  , "ZHR_ROTEIR"},;
            {"ZHR_DESGOR"  , "ZHR_DESGOR"},;
            {"ZHR_VLRUNT"  , "ZHR_VLRUNT"},;
            {"ZHR_CDAPRV"  , "ZHR_CDAPRV"},;
            {"ZHR_NMAPRV"  , "ZHR_NMAPRV"},;
            {"ZHR_DTAPRV"  , "ZHR_DTAPRV"},;
            {"ZHR_HRAPRV"  , "ZHR_HRAPRV"},;
            {"ZHR_STATUS"  , "ZHR_STATUS"},;
            {"ZHR_NFSERD"  , "ZHR_NFSERD"},;
            {"ZHR_QTDORI"  , "ZHR_QTDORI"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

    oModel:AddCalc("ADFAT57TOT", "MD_MASTER", "MD_GRID", "ZHR_QTDDES", "ZHR_QTDTOT", "SUM", { | oFW | ADFAT57CAL( oFW, .T. ) },,"Quantidade Total")

Return oModel
/*/{Protheus.doc} ADFAT57CAL
    Calcular.
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function ADFAT57CAL(oFW, LALGO)
Return .T.
/*/{Protheus.doc} vldPre
    Pós validação.
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function vldPre(oModel)

    //Variáveis.
    Local lRet       := .T.

Return lRet
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cOrdRac    := oModel:GetValue("MD_MASTER","ZHR_ORRORI")
    Local cMotivo    := oModel:GetValue("MD_MASTER","ZHR_MOTIVO")
    Local cStatus    := oModel:GetValue("MD_MASTER","ZHR_STATUS")
    Local cQtdOri    := Val(cValToChar(oModel:GetValue("MD_MASTER","ZHR_QTDORI")))
    Local cQtdDes    := Val(cValToChar(oModel:GetValue("ADFAT57TOT","ZHR_QTDTOT")))
    Local cMsgError  := ""

    If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

        If nOperation == MODEL_OPERATION_UPDATE .And. cStatus == "3" .And. ! IsInCallStack("gerPedS")
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Registro não pode ser alterado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. Empty(cOrdRac)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar a ordem de carregamento de ração de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. Empty(cMotivo)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar o motivo do refaturamento.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cQtdOri <> cQtdDes
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Quantidade total dos destinos está divergente do total de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cStatus <> "3" .And. nOperation == MODEL_OPERATION_UPDATE .And. ! IsInCallStack("gerPedS")
            oModel:SetValue("MD_MASTER","ZHR_CDAPRV", "")
            oModel:SetValue("MD_MASTER","ZHR_NMAPRV", "")
            oModel:SetValue("MD_MASTER","ZHR_DTAPRV", SToD(" / / "))
            oModel:SetValue("MD_MASTER","ZHR_HRAPRV", "")
            oModel:SetValue("MD_MASTER","ZHR_STATUS", "1")

        EndIf

        If lRet .And. ! vldHH(oModel, @cMsgError)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. cStatus == "3"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Registro não pode ser excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

    EndIf

    RestArea(aArea)
  
Return lRet
/*/{Protheus.doc} User Function vldTranf
    Valida transferência HH.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
Static Function vldHH(oModel, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cHH       := Alltrim(cValToChar(GetMv("MV_#CODHH",,"247011")))
    Local cForOri   := oModel:GetValue("MD_MASTER","ZHR_FORORI")
    Local oGrid     := oModel:GetModel("MD_GRID")
    Local nLength   := oGrid:length()
    Local nDiff     := 0
    Local nAux      := 0

    Default cMsgError := ""

    If cHH <> cForOri
        RestArea(aArea)
        Return .T.

    EndIf

    For nAux := 1 To nLength
    
        oGrid:GoLine(nAux)

        cForOri := oGrid:GetValue("ZHR_FORDES", nAux)

        If cForOri <> cHH
            nDiff++
            
        EndIf

    Next nAux

    If nDiff <= 0
        cMsgError := "Não é possível fazer a transferência de " + cForOri + " apenas para " + cHH + "."
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oModel    := FWLoadModel("ADFAT057P")
    Local oView     := Nil
    Local cCampos   := getCmps()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})
    Local oStrTotal := FWCalcStruct( oModel:GetModel("ADFAT57TOT") )

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
    oView:AddField("VW_CALC",   oStrTotal,"ADFAT57TOT")
 
    oView:CreateHorizontalBox("MAIN", 50)
    oView:CreateHorizontalBox("GRID", 35)
    oView:CreateHorizontalBox("CALC", 15)

    oView:SetOwnerView("VW_MASTER", "MAIN")
    oView:SetOwnerView("VW_GRID", "GRID")
    oView:SetOwnerView("VW_CALC", "CALC")

    oView:EnableControlBar(.T.)

    oView:AddIncrementField("VW_GRID", "ZHR_ITEM")

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 07/06/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cOrdRac := oModel:GetValue("MD_MASTER","ZHR_ORRORI")
    Local cNota   := oModel:GetValue("MD_MASTER","ZHR_NFORI")
    Local cMotivo := oModel:GetValue("MD_MASTER","ZHR_MOTIVO")

    If Empty(cOrdRac)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar a ordem de carregamento de ração de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()

    EndIf

    If Empty(cNota)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Nota fiscal não carregada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()

    EndIf

    If Empty(cMotivo)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar o motivo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCmps
    Função retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 01/06/2022
    @version 01
/*/
Static Function getCmps()
Return "ZHR_FILIAL;ZHR_NFSERD;ZHR_NUMERO;ZHR_PLACA;ZHR_STATUS;ZHR_ROTEIR;ZHR_ORRORI;ZHR_DESGOR;ZHR_ORPORI;ZHR_NFORI;ZHR_SERORI;ZHR_FORORI;ZHR_LOJORI;ZHR_PRDSAG;ZHR_PRDPRO;ZHR_DESPRT;ZHR_QTDORI;ZHR_VLRUNT;ZHR_MOTIVO;ZHR_CDAPRV;ZHR_NMAPRV;ZHR_DTAPRV;ZHR_HRAPRV"
/*/{Protheus.doc} ADFAT57
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 02/06/2022
    @version 01
/*/
User Function ADFAT57()

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

	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZHR_NUMERO")

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
    @type  Static Function
    @author Everson
    @since 02/06/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea     := GetArea()
    Local cFilter   := ""
    Local cCmp      := getCmps()
    
    cFilter := " ZHR_FILIAL ='" + FWxFilial("ZHR") + "' .And. ZHR_NUMERO = '" + cNumero + "' "

    U_ADFAT27D("ZHR", 1, FWxFilial("ZHR") + cNumero,;
        "ZHR", 1, FWxFilial("ZHR") + cNumero, "ZHR_ITEM", cFilter,;
        "refaturamentos_de_racao_protheus", cOperacao,;
        .T., .T., .T.,;
        cCmp)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFAT57A
    Função utilizada em gatilho, para preenchimento de dados do cabeçalho.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
    /*/
User Function ADFAT57A(cCmpDes, cNmOrdem)  // U_ADFAT57A("VLRUNIT",M->ZHR_ORPORI)

    //Variáveis.
    Local aArea    := GetArea()
    Local xRetorno := ""
    Local cPrdSAG  := ""

    cNmOrdem := Alltrim(cValToChar(cNmOrdem))
    
    If ! Empty(cNmOrdem)

        DbSelectArea("SC5")
        SC5->(DbSetOrder(28))
        SC5->(DbGoTop())

        If ! SC5->(DbSeek( FWxFilial("SC5") + cNmOrdem ))
            RestArea(aArea)
            Return ""

        EndIf

        While ! SC5->(Eof()) .And. SC5->C5_FILIAL == FWxFilial("SC5") .And. SC5->C5_XORDPES == cNmOrdem

            If Empty(SC5->C5_PEDSAG) .And. ! Empty(SC5->C5_NOTA) .And. ! Empty(SC5->C5_SERIE)
                
                If cCmpDes == "NF"
                    xRetorno := SC5->C5_NOTA

                ElseIf cCmpDes == "SERIE"
                    xRetorno := SC5->C5_SERIE

                ElseIf cCmpDes == "FORORI"
                    xRetorno := SC5->C5_CLIENTE

                ElseIf cCmpDes == "LOJAORI"
                    xRetorno := SC5->C5_LOJACLI

                ElseIf cCmpDes == "PRODSAG"
                    xRetorno := Posicione("ZIF", 2, FWxFilial("ZIF") + cNmOrdem, "ZIF_PRDSAG")

                ElseIf cCmpDes == "PRODPROTH"
                    xRetorno := Posicione("ZIF", 2, FWxFilial("ZIF") + cNmOrdem, "ZIF_PRDPRO")

                ElseIf cCmpDes == "DESCPROD"
                    cPrdSAG  := Posicione("ZIF", 2, FWxFilial("ZIF") + cNmOrdem, "ZIF_PRDSAG")
                    xRetorno := Posicione("ZIM", 1, FWxFilial("ZIM") + cPrdSAG, "ZIM_DESSAG")

                ElseIf cCmpDes == "QTDORI"
                    xRetorno := Val(cValToChar(SC5->C5_PESOL))

                ElseIf cCmpDes == "VLRUNIT" //As notas de ração estão saindo com apenas um item.
                    xRetorno := Val(cValToChar( Posicione("SC6", 1, FWxFilial("SC6") +  SC5->C5_NUM , "C6_PRCVEN") ))

                EndIf

                Exit

            EndIf

            SC5->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return xRetorno
/*/{Protheus.doc} User Function ADFAT57B
    Valida ordem de carregamento de ração.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
User Function ADFAT57B(cOrdRac) // U_ADFAT57B(M->ZHR_ORRORI)

    //Variáveis.
    Local aArea := GetArea()
    Local lPedV := .F.

    If ! U_ADFAT16E(cOrdRac)
        MsgInfo("Ordem de pesagem não localizada.", "Função ADFAT57B(ADFAT057P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(5))
    ZHR->(DbGoTop())
    If ZHR->( DbSeek( FWxFilial("ZHR") + cOrdRac ) )
        MsgInfo("Ordem de carregamento de ração " + cOrdRac + " já utilizada.", "Função ADFAT57B(ADFAT057P)")
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("SC5")
    SC5->(DbSetOrder(28))
    SC5->(DbGoTop())
    If ! SC5->( DbSeek( FWxFilial("SC5") + ZIF->ZIF_NUMERO ) )
        MsgInfo("Não há pedido de saída(SC5) vinculado à ordem de pesagem " + cValToChar(ZIF->ZIF_NUMERO ) + ".", "Função ADFAT57B(ADFAT057P)")
        RestArea(aArea)
        Return .F.

    Else

        While ! SC5->(Eof()) .And. SC5->C5_FILIAL == FWxFilial("SC5") .And. SC5->C5_XORDPES == ZIF->ZIF_NUMERO

            If Empty(SC5->C5_PEDSAG)
                lPedV := .T.
                Exit
            EndIf

            SC5->(DbSkip())

        End

    EndIf

    If ! lPedV
        MsgInfo("Não há pedido de saída(SC5) vinculado à ordem de pesagem " + cValToChar(ZIF->ZIF_NUMERO ) + ".", "Função ADFAT57B(ADFAT057P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(SC5->C5_NOTA) .Or. Empty(SC5->C5_SERIE)
        MsgInfo("Pedido de venda " + cValToChar(SC5->C5_NUM) + " não está faturado.", "Função ADFAT57B(ADFAT057P)")
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT57D
    Aprova registro.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
User Function ADFAT57D()

    //Variáveis.
    Local aArea := GetArea()
    Local cNum  := ZHR->ZHR_NUMERO

    If ZHR->ZHR_STATUS <> "1"
        MsgInfo("Ação não permitida.", "Função ADFAT57D(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! MsgYesNo("Deseja aprovar o refaturamento " + cNum + "?", "Função ADFAT57D(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))

        While ! ZHR->(Eof()) .And. ZHR->ZHR_FILIAL == FWxFilial("ZHR") .And. ZHR->ZHR_NUMERO == cNum

            RecLock("ZHR", .F.)
                ZHR->ZHR_STATUS := "2"
                ZHR->ZHR_CDAPRV := __cUserID
                ZHR->ZHR_NMAPRV := cUserName
                ZHR->ZHR_DTAPRV := Date()
                ZHR->ZHR_HRAPRV := Time()
            ZHR->(MsUnlock())

            ZHR->(DbSkip())

        End

        grvBarr("A", cNum)

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFAT57E
    Gera pedido de saída.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
User Function ADFAT57E()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local cNum  := ZHR->ZHR_NUMERO
    Local cRegistros := ""

    If ZHR->ZHR_STATUS <> "2"
        MsgInfo("Ação não permitida.", "Função ADFAT57E(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! MsgYesNo("Deseja processar o refaturamento " + cNum + "?", "Função ADFAT57E(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    Begin Transaction

        MsAguarde({|| lRet := gerPedS(cNum, @cRegistros) }, "Aguarde", "Gerando pedido(s) de saída...")

        If ! lRet
            DisarmTransaction()
            Break
            
        EndIf

        grvBarr("A", cNum)

        lRet := .T.

    End Transaction

    U_TExTelaMen("Geração de NF de Devolução e Pedido de Saída", cRegistros, "Arial",10,,.F.,.F.)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function gerPedS
    Gera pedido de saída.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
Static Function gerPedS(cNum, cRegistros)

    //Variáveis.
    Local aArea    := GetArea()
    Local aCabec   := {}
    Local aLinha   := {}
    Local aItens   := {}

    Local cTpPed   := ""
    Local cCliFor  := ""
    Local cFornece := ""
    Local cLjForn  := ""
    Local aCampo   := {}
    Local cMemNf2  := ""
    Local cGranja  := ""
    Local cGranjada:= ""
    Local cTpFrt   := ""
    Local cPlaca   := ""
    Local cTransp  := ""
    Local cUFPlaca := ""
    Local nPesoLiq := 0
    Local cNmOrdem := ""
    Local cTabGene := ""
    Local cProduto := ""
    Local nVlrUnit := 0
    Local nTotal   := 0
    Local cTes     := ""
    Local cLocPad  := ""
    Local cNFOri   := ""
    Local cSerOri  := ""
    Local cForOri  := ""
    Local cLojOri  := ""

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.
    
    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))
        cRegistros := "Faturamento " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.
        
    EndIf

    cNFOri  := ZHR->ZHR_NFORI
    cSerOri := ZHR->ZHR_SERORI
    cForOri := ZHR->ZHR_FORORI
    cLojOri := ZHR->ZHR_LOJORI

    DbSelectArea("SD1")
    SD1->(DbSetOrder(19))
    SD1->(DbGoTop())
    If ! SD1->( DbSeek( FWxFilial("SD1") + cNFOri + cSerOri + cForOri + cLojOri ))
        cRegistros := "Nota de devolução não lançada."
        RestArea(aArea)
        Return .F.

    EndIf

    cRegistros += Chr(13) + Chr(10) + Chr(13) + Chr(10)  +"Pedidos gerados: " + Chr(13) + Chr(10) 

    While ! ZHR->(Eof()) .And. ZHR->ZHR_FILIAL == FWxFilial("ZHR") .And. ZHR->ZHR_NUMERO == cNum

        //Posiciona na ordem de pesagem.
        If ! U_ADFAT16A(ZHR->ZHR_ORPORI)
            cRegistros := "Ordem de pesagem " + cValToChar(ZHR->ZHR_ORPORI) + " não localizada."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no registro de pátio selecionado.
        If ! U_ADFAT17U(ZIF->ZIF_CTPATI)
            cRegistros := "Controle de pátio não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no cadastro de veículo.
        DbSelectArea("ZV4")
        ZV4->(DbSetOrder(1))
        ZV4->(DbGoTop())
        If ! ZV4->( DbSeek( FWxFilial("ZV4") + ZHR->ZHR_PLACAD))
            cRegistros := "Veículo " + ZHR->ZHR_PLACAD + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no cadastro de roteiro de pesagem.
        If ! U_ADFAT15B(ZIB->ZIB_CODROT)
            cRegistros := "Roteiro de pesagem " +  ZIB->ZIB_CODROT + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf      

        //Posiciona no item do cadastro de pesagem.
        DbSelectArea("ZIA")
        ZIA->(DbSetOrder(2))
        ZIA->(DbGoTop())
        If ! ZIA->( DbSeek( FWxFilial("ZIA") + ZIB->ZIB_CODROT + ZIF->ZIF_PRDSAG))
            cRegistros := "Item do roteiro de pesagem " +  ZIB->ZIB_CODROT + " " + ZIF->ZIF_PRDSAG + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf  

        aCabec  := {}
        aItens  := {}
        aLinha  := {}

        cTpPed   := ""
        cCliFor  := ZHR->ZHR_CLIFOR
    
        cFornece := ZHR->ZHR_FORDES
        cLjForn  := ZHR->ZHR_LOJDES
        cMemNf2  := "Granja.: " + ZHR->ZHR_DESGRJ
        cGranja  := ZHR->ZHR_INTCOD
        cGranjada:= Posicione("ZIS", 1, FWxFilial("ZIS") + ZHR->ZHR_GRANJD, "ZIS_GRAJDA")
        cTpFrt   := "C"
        cPlaca   := ZHR->ZHR_PLACAD
        cTransp  := ZV4->ZV4_FORNEC
        cUFPlaca := ZV4->ZV4_EST
        nPesoLiq := ZHR->ZHR_QTDDES
        cNmOrdem := ZHR->ZHR_ORPORI
        cTabGene := ""
        cProduto := ZHR->ZHR_PRDPRO
        nVlrUnit := ZHR->ZHR_VLRUNT
        nTotal   := Round(ZHR->ZHR_VLRUNT * ZHR->ZHR_QTDDES, TamSX3("C6_VALOR")[2])
        cLocPad  := ""

        aCampo   := {}

        If ! getInfo(cCliFor, @aCampo, @cTpPed, cFornece, cLjForn, @cRegistros)
            RestArea(aArea)
            Return .F.

        EndIf
        
        cTes     := Iif(Alltrim(cValToChar(aCampo[2,2])) == "SP", ZI9->ZI9_TESEST, ZI9->ZI9_TESINT)

        //Posiciona no item de exceção de TES do cadastro de roteiro de pesagem.
        DbSelectArea("ZIU")
        ZIU->(DbSetOrder(4)) //Everson - 03/06/2022. ticket 18465.
        ZIU->(DbGoTop())
        If ZIU->( DbSeek( FWxFilial("ZIU") + ZIA->ZIA_CODROT + cCliFor + cFornece + cLjForn )) //Verifica se tem cadastro de exceção de tes por fornecedor / cliente.
            cTes := ZIU->ZIU_TES

        Else

            //Pega Tes do cadastro do item do roteiro de pesagem.
            If Alltrim(cValToChar(aCampo[2,2])) == "SP" .And. ! Empty(ZIA->ZIA_TESEST)
                cTes := ZIA->ZIA_TESEST

            ElseIf  Alltrim(cValToChar(aCampo[2,2])) <> "SP" .And. ! Empty(ZIA->ZIA_TESINT)
                cTes := ZIA->ZIA_TESINT

            EndIf

        EndIf        

        If ! RetArqProd(cProduto)
            cLocPad := Posicione("SBZ",1, FWxFilial("SBZ") + cProduto, "BZ_LOCPAD")
            
        Else
            cLocPad := Posicione("SB1",1, FWxFilial("SB1") + cProduto, "B1_LOCPAD")
    
        EndIf

        Aadd( aCabec, { "C5_TIPO"	  , cTpPed, Nil } )
        Aadd( aCabec, { "C5_CLIENTE"  , cFornece, Nil } )
        Aadd( aCabec, { "C5_LOJACLI"  , cLjForn, Nil } )
        Aadd( aCabec, { "C5_LOJAENT"  , cLjForn, Nil } )
        Aadd( aCabec, { "C5_CONDPAG"  , aCampo[5,2], Nil } )
        Aadd( aCabec, { "C5_ENDERE"   , aCampo[1,2], Nil } )
        Aadd( aCabec, { "C5_EST"      , aCampo[2,2], Nil } )
        Aadd( aCabec, { "C5_BAIRRO"   , aCampo[3,2], Nil } )
        Aadd( aCabec, { "C5_CIDADE"   , aCampo[4,2], Nil } )
        Aadd( aCabec, { "C5_DTENTR"   , Date() + 7 , Nil } )
        Aadd( aCabec, { "C5_EMISSAO"  , Date()   , Nil } )

        Aadd( aCabec, { "C5_MENNOT2"  , cMemNf2  , Nil } )
        Aadd( aCabec, { "C5_GRANJA"   , cGranja  , Nil } )
        Aadd( aCabec, { "C5_GRANJDA"  , cGranjada, Nil} )

        Aadd( aCabec, { "C5_TPFRETE"  , cTpFrt  , .F. } )
        Aadd( aCabec, { "C5_FRETE"    , 0       , .F. } )
        Aadd( aCabec, { "C5_PLACA"    , cPlaca  , .F. } )
        Aadd( aCabec, { "C5_TRANSP"   , cTransp , .F. } )
        Aadd( aCabec, { "C5_UFPLACA"  , cUFPlaca, .F. } )
        Aadd( aCabec, { "C5_PESOL"    , nPesoLiq, Nil } )
        Aadd( aCabec, { "C5_PESOTOT"  , nPesoLiq, Nil } )
        Aadd( aCabec, { "C5_XORDPES"  , cNmOrdem, .F. } )
        Aadd( aCabec, { "C5_TABEGEN"  , cTabGene, .F. } )

        //Item.
        Aadd( aLinha, { "C6_ITEM"	 , "001"	, Nil } )
        Aadd( aLinha, { "C6_PRODUTO" , cProduto	, Nil } )
        Aadd( aLinha, { "C6_UNSVEN"	 , nPesoLiq	,0 , Nil } )
        Aadd( aLinha, { "C6_PRCVEN"	 , nVlrUnit	,0 , Nil } )
        Aadd( aLinha, { "C6_VALOR"	 , nTotal	,0 , Nil } )
        Aadd( aLinha, { "C6_TES"	 , cTes	    ,.F. } )
        Aadd( aLinha, { "C6_LOCAL"	 , cLocPad  , Nil } )
        Aadd( aLinha, { "C6_PRUNIT"	 , nVlrUnit	,0 , Nil } )

        //Itens.
        Aadd(aItens, aLinha)

        MSExecAuto( { |x, y, z, p| MATA410(x, y, z,,,,,,, p) }, aCabec, aItens, 3 )

        If lMsErroAuto
            cRegistros := MostraErro()
            RestArea(aArea)
            Return .F.

        Else
            cRegistros += SC5->C5_NUM + Chr(13) + Chr(10)

            RecLock("ZHR", .F.)
                ZHR->ZHR_NVPED  := SC5->C5_NUM
                ZHR->ZHR_STATUS := "3"
            ZHR->(MsUnlock())

        EndIf

        ZHR->(DbSkip())

    End

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} getInfo
    Obtém informações de cliente e fornecedor.
    @type  Static Function
    @author Everson
    @since 07/06/2022
    @version 01
/*/
Static Function getInfo(cCliFor, aCampo, cTpPed, cCodCF, cLoja, cRegistros)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.

    Default cRegistros := ""

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbGoTop())

    If cCliFor == "C"

        If ! SA1->( DbSeek( FWxFilial("SA1") + cCodCF + cLoja))
            cRegistros := "Cliente " + cCodCF + cLoja + " não localizado."

        Else
            lRet := .T.
            aCampo  := {{"A1_END", SA1->A1_END}, {"A1_EST", SA1->A1_EST}, {"A1_BAIRRO", SA1->A1_BAIRRO}, {"A1_CIDADE", SA1->A1_Mun}, {"A1_COND", SA1->A1_COND}}
            cTpPed  := "N"

        EndIf

    Else

        If ! SA2->( DbSeek( FWxFilial("SA2") + cCodCF + cLoja))
            cRegistros := "Fornecedor " + cCodCF + cLoja + " não localizado."

        Else
            lRet := .T.
            aCampo  := {{"A2_END", SA2->A2_END}, {"A2_EST", SA2->A2_EST}, {"A2_BAIRRO", SA2->A2_BAIRRO}, {"A2_CIDADE", SA2->A2_Mun}, {"A2_COND", SA2->A2_COND},  {"A2_COND", SA2->A2_COND}}
            cTpPed  := "B"

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT57F
    Imprimi ticket de transferência de produto.
    @type  Static Function
    @author Everson
    @since 07/06/202252
    @version 01
/*/
User Function ADFAT57F()

    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cDtLoj    := ""
    Local cDtAbt    := ""
    Local cEnd      := ""
    Local cCabec2   := ""
    Local cNF       := ""

    If ! MsgYesNo("Deseja imprimir o ticket?", "Função ADFAT57F(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If cFilAnt == "03"
        cCabec2 := "CNPJ: 60.037.058/0004-84 EST. S CARLOS A RIB BONITO, KM 157 - ZONA RURAL - (016) 2106-3501 - São Carlos"
        cTpRac := "Frango"

    ElseIf cFilAnt == "05"
        cCabec2 := "CNPJ:  60.037.058/0018-80 EST. S CARLOS A RIB BONITO, KM 154 - ZONA RURAL - (016)  - São Carlos"
        cTpRac := "Matrizes"

    EndIf

    cDtLoj := DToC(Posicione("ZIS", 1, FWxFilial("ZIS") + ZHR->ZHR_GRANJD, "ZIS_DTALOJ"))
    cDtAbt := DToC(Posicione("ZIS", 1, FWxFilial("ZIS") + ZHR->ZHR_GRANJD, "ZIS_DTALOJ") + 48)

    If ZHR->ZHR_CLIFOR == "F"
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))
        SA2->(DbGoTop())
        If SA2->( DbSeek( FWxFilial("SA2") +ZHR->ZHR_FORDES + ZHR->ZHR_LOJDES) )
            cEnd   := Alltrim(SA2->A2_END) + ", " + Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN) + " - " + Alltrim(SA2->A2_EST)
        
        EndIf

    ElseIf ZHR->ZHR_CLIFOR == "C"
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1))
        SA1->(DbGoTop())
        If SA1->( DbSeek( FWxFilial("SA1") +ZHR->ZHR_FORDES + ZHR->ZHR_LOJDES) )
            cEnd   := Alltrim(SA1->A1_END) + ", " + Alltrim(SA1->A1_BAIRRO) + " - " + Alltrim(SA1->A1_MUN) + " - " + Alltrim(SA1->A1_EST)

        EndIf

    EndIf

    oPrinter := FWMSPrinter():New(ZHR->ZHR_NUMERO, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)
 
    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro Fábrica de Ração " + cTpRac, oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ticket de Pesagem - Transferência de Produto", oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(145,  20, "Refat.: ", oFt16B)
            oPrinter:Say(145, 100, ZHR->ZHR_NUMERO, oFt14N)

            oPrinter:Say(165,  20, "Placa: ", oFt16B)
            oPrinter:Say(165, 100, ZHR->ZHR_PLACAD, oFt14N)

            oPrinter:Say(185,  20, "Lote: ", oFt16B)
            oPrinter:Say(185, 100, ZHR->ZHR_DESGRJ, oFt14N) //Everson - 02/06/2022. Chamado 18465.

            oPrinter:Say(205,  20, "Endereço: ", oFt16B)
            oPrinter:Say(205, 100, cEnd, oFt14N)

            oPrinter:Say(225,  20, "Produto: ", oFt16B)
            oPrinter:Say(225, 100, ZHR->ZHR_DESPRT, oFt14N)

            oPrinter:Say(245,  20, "Pedido: ", oFt16B)
            oPrinter:Say(245, 100, ZHR->ZHR_NVPED, oFt14N)

            If ! Empty(ZHR->ZHR_NVPED)
                cNF := Posicione("SC5", 1, FWxFilial("SC5") + ZHR->ZHR_NVPED, "C5_NOTA") + " " + Posicione("SC5", 1, FWxFilial("SC5") + ZHR->ZHR_NVPED, "C5_SERIE")

            EndIf

            oPrinter:Say(265,  20, "NF: ", oFt16B)
            oPrinter:Say(265, 100, cNF, oFt14N)

        //Coluna 2.
            oPrinter:Say(185, 210, "Data Aloj.: ", oFt16B)
            oPrinter:Say(185, 280, cDtLoj, oFt14N)
   
            oPrinter:Say(305, 210, "Líquido: ", oFt16B)
            oPrinter:SayAlign(292, 240, Alltrim(cValToChar(Transform(ZHR->ZHR_QTDDES, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)

        //Coluna 3.
            If cFilAnt == "03"
                oPrinter:Say(185, 420, "Abate: ", oFt16B)
                oPrinter:Say(185, 490, cDtAbt, oFt14N)

            EndIf

        oPrinter:Say(470,  20, "Ass. Recebedor:________________________________________________________________", oFt14N)
        oPrinter:Say(425,  20, "Usuário:________________________________________________________________________", oFt14N)

    oPrinter:EndPage()
    
    oPrinter:Setup()

    If oPrinter:nModalResult == PD_OK
        oPrinter:Preview()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT571
    Atualiza ordem de carregamento.
    @type  User Function
    @author Everson
    @since 09/06/2022
    @version 01
/*/
User Function ADFAT571(cNmRft, aDados, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local nAux      := 1
    
    Default cMsgError := ""
    
    If ! U_ADFAT572(cNmRft)
        Help(Nil, Nil, "Função ADFAT571(ADFAT057P)", Nil, "Refaturamento " + cNmRft + " não encontrado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADFAT057P")
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
        Help(Nil, Nil, "Função ADFAT571(ADFAT057P)", Nil, "Não foi possível atualizar o registro de refaturamento " + cNmRft + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT572
    Posiciona no registro de refaturamento.
    @type  User Function
    @author Everson
    @since 09/06/2022
    @version 01
/*/
User Function ADFAT572(cNmRft)

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNmRft ))
        Return .F.
        
    EndIf

Return .T.
