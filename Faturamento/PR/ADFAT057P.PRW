#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "FWPrintSetup.ch"
#Include "RPTDEF.CH"

Static xPula    := Chr(13) + Chr(10)
Static cTbMast  := "ZHR"
Static cTitulo  := "Refaturamento de Carga de Ração"
Static cTiMast  := "Dados do refaturamento da carga de ração"
Static cTpMv    := "1" //1=Refaturamento de Ração;2=Sobra de Ração

/*/{Protheus.doc} User Function ADFAT057P
    Refaturamento de ordem de ração.
    Refaturamento Ração
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/06/2022
    @version 01
    @history ticket   TI    - Everson           - 10/07/2022 - Removida transmissão automática de NF.
    /*/
User Function ADFAT057P() // U_ADFAT057P()

    //Variáveis.
    Local oBrowse := Nil

    If FWIsAdmin() .Or. __cUserID $ Alltrim(cValToChar(GetMv("MV_#ADF574",,"")))

        If ! Pergunte("ADFAT057P1",.T.)
            Return Nil

        EndIf   

        If Empty(MV_PAR01)
            MsgInfo("Necessário escolher uma opção", "Função ADFAT057P")
            Return Nil

        EndIf 

        cTpMv := cValToChar(MV_PAR01)

    EndIf 

    If cTpMv == "2"
        cTitulo  := "Sobra de Ração"
        cTiMast  := "Sobra de ração"

    EndIf
    
    oBrowse := FwLoadBrw("ADFAT057P")

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
    Local cFiltro := " " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' .AND. ZHR_TIPO = '" + cTpMv + "' "

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZHR_STATUS = '1' ","BR_VERDE"   , "Aberto"    )
    oBrowse:AddLegend("ZHR_STATUS = '2' ","BR_AZUL"    , "Aprovado"    )
    oBrowse:AddLegend("ZHR_STATUS = '3' ","BR_VERMELHO", "Pedido Gerado" )
    oBrowse:AddLegend("ZHR_STATUS = '4' ","BR_PRETO"   , "Faturado" )

    oBrowse:SetFilterDefault(cFiltro)

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
    Local cUsrGer := Alltrim(cValToChar(GetMv("MV_#ADF573",,"")))

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0

    If FWIsAdmin() .Or. __cUserID $cUsrInc
        ADD OPTION aRotina TITLE "Incluir" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
        ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
        ADD OPTION aRotina TITLE "Excluir" 	ACTION "VIEWDEF.ADFAT057P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0

    EndIf

    If cTpMv == "1" .And. FWIsAdmin() .Or. __cUserID $cUsrApv
        ADD OPTION aRotina TITLE "Aprovar"  ACTION "U_ADFAT57D()"       OPERATION 10  ACCESS 0

    EndIf

    If FWIsAdmin() .Or. __cUserID $cUsrGer
        ADD OPTION aRotina TITLE "Processar Dev"   ACTION "U_ADFAT57E(1)"      OPERATION 11  ACCESS 0
        ADD OPTION aRotina TITLE "Processar Saída" ACTION "U_ADFAT57E(2)"      OPERATION 11  ACCESS 0
        ADD OPTION aRotina TITLE "SPEDNFe"         ACTION "SPEDNFe()"          OPERATION 11  ACCESS 0

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
            {"ZHR_NFRURA"  , "ZHR_NFRURA"},;
            {"ZHR_SRRURA"  , "ZHR_SRRURA"},;
            {"ZHR_NMUSR"   , "ZHR_NMUSR"},;
            {"ZHR_TIPO"    , "ZHR_TIPO"},;
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
    Local cNumero    := oModel:GetValue("MD_MASTER","ZHR_NUMERO")
    Local cOrdRac    := oModel:GetValue("MD_MASTER","ZHR_ORRORI")
    Local cMotivo    := oModel:GetValue("MD_MASTER","ZHR_MOTIVO")
    Local cStatus    := oModel:GetValue("MD_MASTER","ZHR_STATUS")
    Local cDesGro    := oModel:GetValue("MD_MASTER","ZHR_DESGOR")
    Local cPrdSAG    := oModel:GetValue("MD_MASTER","ZHR_PRDSAG")
    Local cProdPro   := oModel:GetValue("MD_MASTER","ZHR_PRDPRO")
    Local cQtdOri    := Val(cValToChar(oModel:GetValue("MD_MASTER","ZHR_QTDORI")))
    Local cQtdDes    := Val(cValToChar(oModel:GetValue("ADFAT57TOT","ZHR_QTDTOT")))
    Local cMsgError  := ""
    Local cOperacao  := ""

    If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

        If nOperation == MODEL_OPERATION_UPDATE .And. cStatus == "3" .And. ! IsInCallStack("U_ADFAT57E")
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Registro não pode ser alterado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. Empty(cOrdRac) .And. cTpMv == "1"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar a ordem de carregamento de ração de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. Empty(cMotivo) .And. cTpMv == "1"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar o motivo do refaturamento.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "1" .And. cQtdOri <> cQtdDes
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Quantidade total dos destinos está divergente do total de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "2" .And. cQtdDes <= 0
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Quantidade de destino inválida.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "2" .And. Empty(cDesGro)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar a granjada de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "2" .And. Empty(cPrdSAG)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar o produto.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "2" .And. Empty(cProdPro)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Necessário informar o produto(Protheus).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cTpMv == "1" .And. cStatus <> "3" .And. nOperation == MODEL_OPERATION_UPDATE .And. ! IsInCallStack("U_ADFAT57E")
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

        If lRet .And. cTpMv == "2" .And. cStatus == "1"
            oModel:SetValue("MD_MASTER","ZHR_STATUS", "2")

        EndIf

        If lRet
            oModel:SetValue("MD_MASTER","ZHR_NMUSR", cUserName)
            oModel:SetValue("MD_MASTER","ZHR_TIPO", cTpMv)

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. cStatus == "3"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT057P)", Nil, "Registro não pode ser excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

    EndIf

    If lRet

        If  nOperation == MODEL_OPERATION_INSERT
            cOperacao := "INCLUSAO"

        ElseIf  nOperation == MODEL_OPERATION_UPDATE
            cOperacao := "ALTERACAO"

        ElseIf  nOperation == MODEL_OPERATION_DELETE
            cOperacao := "EXCLUSAO"

        EndIf

        U_GrLogZBE(Date(), Time(), cUserName, cOperacao, Iif(cTpMv == "1", "FATURAMENTO DE RACAO", "SOBRA DE RACAO"), "ADFAT057P",;
                   cNumero, ComputerName(), LogUserName())

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
 
    
    If cTpMv == "1"
        oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
        oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
        oView:AddField("VW_CALC",   oStrTotal,"ADFAT57TOT")
        oView:CreateHorizontalBox("MAIN", 50)
        oView:CreateHorizontalBox("GRID", 35)
        oView:CreateHorizontalBox("CALC", 15)

        oView:SetOwnerView("VW_MASTER", "MAIN")
        oView:SetOwnerView("VW_GRID", "GRID")
        oView:SetOwnerView("VW_CALC", "CALC")

        oStrMast:RemoveField("ZHR_NFRURA")
        oStrMast:RemoveField("ZHR_SRRURA")

    ElseIf cTpMv == "2"
        oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
        oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
        oView:AddField("VW_CALC",   oStrTotal,"ADFAT57TOT")
        oView:CreateHorizontalBox("MAIN", 50)
        oView:CreateHorizontalBox("GRID", 35)
        oView:CreateHorizontalBox("CALC", 15)

        oView:SetOwnerView("VW_MASTER", "MAIN")
        oView:SetOwnerView("VW_GRID", "GRID")
        oView:SetOwnerView("VW_CALC", "CALC")

        oStrMast:RemoveField("ZHR_ORRORI")
        oStrMast:RemoveField("ZHR_MOTIVO")
        oStrMast:RemoveField("ZHR_ROTEIR")
        oStrMast:RemoveField("ZHR_ORPORI")
        oStrMast:RemoveField("ZHR_NFORI")
        oStrMast:RemoveField("ZHR_SERORI")
        oStrMast:RemoveField("ZHR_FORORI")
        oStrMast:RemoveField("ZHR_LOJORI")
        oStrMast:RemoveField("ZHR_QTDORI")
        oStrMast:RemoveField("ZHR_CDAPRV")
        oStrMast:RemoveField("ZHR_NMAPRV")
        oStrMast:RemoveField("ZHR_DTAPRV")
        oStrMast:RemoveField("ZHR_HRAPRV")
        oStrMast:RemoveField("ZHR_PLACA")

    EndIf

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
    Local cDesGro := oModel:GetValue("MD_MASTER","ZHR_DESGOR")
    Local cProdSAG:= oModel:GetValue("MD_MASTER","ZHR_PRDSAG")
    Local cProdPro:= oModel:GetValue("MD_MASTER","ZHR_PRDPRO")
    Local nVlrUnit:= Val(cValToChar(oModel:GetValue("MD_MASTER","ZHR_VLRUNT")))

    If cTpMv == "1" .And. Empty(cOrdRac)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar a ordem de carregamento de ração de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()
    
    ElseIf cTpMv == "1" .And. Empty(cNota)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Nota fiscal não carregada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()

    ElseIf cTpMv == "1" .And. Empty(cMotivo)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar o motivo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_ORRORI"):OCtrl:OGet:SetFocus()

    EndIf

    If cTpMv == "2" .And. Empty(cDesGro)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar a granjada de origem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_DESGOR"):OCtrl:OGet:SetFocus()

    ElseIf cTpMv == "2" .And. Empty(cProdSAG)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar o produto.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_DESGOR"):OCtrl:OGet:SetFocus()

    ElseIf cTpMv == "2" .And. Empty(cProdPro)
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar o produto (Protheus).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_DESGOR"):OCtrl:OGet:SetFocus()

    ElseIf cTpMv == "2" .And. nVlrUnit <= 0
        Help(Nil, Nil, "Função gridFocus(ADFAT057P)", Nil, "Necessário informar o valor unitário.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHR_DESGOR"):OCtrl:OGet:SetFocus()

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
Return "ZHR_FILIAL;ZHR_NFRURA;ZHR_TIPO;ZHR_SRRURA;ZHR_NMUSR;ZHR_NUMERO;ZHR_PLACA;ZHR_STATUS;ZHR_ROTEIR;ZHR_ORRORI;ZHR_DESGOR;ZHR_ORPORI;ZHR_NFORI;ZHR_SERORI;ZHR_FORORI;ZHR_LOJORI;ZHR_PRDSAG;ZHR_PRDPRO;ZHR_DESPRT;ZHR_QTDORI;ZHR_VLRUNT;ZHR_MOTIVO;ZHR_CDAPRV;ZHR_NMAPRV;ZHR_DTAPRV;ZHR_HRAPRV"
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
    Local cTopico   := "refaturamentos_de_racao_protheus"

    If cTpMv == "2"
        cTopico := "sobras_de_racao_protheus"

    EndIf
    
    cFilter := " ZHR_FILIAL ='" + FWxFilial("ZHR") + "' .And. ZHR_NUMERO = '" + cNumero + "' "

    U_ADFAT27D("ZHR", 1, FWxFilial("ZHR") + cNumero,;
        "ZHR", 6, FWxFilial("ZHR") + cNumero, "ZHR_ITEM", cFilter,;
        cTopico, cOperacao,;
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

        Begin Transaction

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

            U_GrLogZBE(Date(), Time(), cUserName, "APROVACAO", "FATURAMENTO", "ADFAT057P",;
                ZHR->ZHR_NUMERO, ComputerName(), LogUserName())

            grvBarr("A", cNum)

        End Transaction

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
User Function ADFAT57E(nOpc)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .F.
    Local cNum       := ZHR->ZHR_NUMERO
    Local cRegistros := ""
    Local aPedInc    := {}
    Local cPedProth  := ""
    Local nAux       := 1

    If ZHR->ZHR_STATUS <> "2"
        MsgInfo("Ação não permitida.", "Função ADFAT57E(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! MsgYesNo("Deseja processar o refaturamento " + cNum + "?", "Função ADFAT57E(ADFAT057P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If nOpc == 1 //Gera nota fiscal de devolução.

        If ZHR->ZHR_TIPO == "1"
            MsAguarde({|| lRet := gerDev(cNum, @cRegistros) }, "Aguarde", "Gerando NF de devolução...")

        EndIf

        If ZHR->ZHR_TIPO  == "2"
            MsAguarde({|| lRet := gerDevS(cNum, @cRegistros) }, "Aguarde", "Gerando NF de devolução...")

        EndIf

    EndIf

    If nOpc == 2 //Gera pedidos de venda.

        Begin Transaction

            MsAguarde({|| lRet := gerPedS(cNum, @cRegistros, @aPedInc) }, "Aguarde", "Gerando pedido(s) de saída...")

            If ! lRet
                DisarmTransaction()
                Break
                
            EndIf

            grvBarr("A", cNum)

            lRet := .T.

        End Transaction

    EndIf

    U_TExTelaMen("Geração de NF de Devolução e Pedido de Saída", cRegistros, "Arial",10,,.F.,.F.)

    //Geração de nota fiscal.
    If Len(aPedInc) > 0 .And. MsgYesNo("Deseja emitir nota(s) fiscal(is)?", "Função ADFAT57E(ADFAT057P)")

		For nAux := 1 To Len(aPedInc)
			cPedProth += "'" + aPedInc[nAux] + "',"
			
		Next nAux
		
		cPedProth := Substr(cPedProth,1,Len(cPedProth) - 1)

        MsAguarde({|| U_ADFAT574(cPedProth) },"Aguarde","Emitindo nota(s) fiscal(is) de saída...")

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function gerDev
    Gera entrada por devolução.
    @type  Function
    @author Everson
    @since 05/07/2022
    @version 01
/*/
Static Function gerDev(cNum, cRegistros)

    //Variáveis.
    Local aArea     := GetArea()
    Local aItens    := {}
    Local aCab      := {}
    Local cNumero   := ""
    Local cTes      := Alltrim(cValToChar(GETMV("MV_#ADF575",,"15A"))) //"15A" //Sobra de ração 15C
    Local cItemCC   := Alltrim(cValToChar(GETMV("MV_#ADF576",,"114"))) //"114"
    Local cSerie	:= Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
    Local cTpNrNfs  := ""
    Local cNFOri    := ""
    Local cSerOri   := ""
    Local cForOri   := ""
    Local cLojOri   := ""
    Local aNFTrans  := {}

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.

    Default cRegistros  := ""

    cRegistros += xPula

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))
        cRegistros += "Faturamento " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.
        
    EndIf

    DbSelectArea("SD2")
    SD2->(DbSetOrder(3))
    If ! SD2->(DbSeek( FWxFilial("SD2") + ZHR->ZHR_NFORI + ZHR->ZHR_SERORI ))
        cRegistros += "Nota de origem " + cValToChar(ZHR->ZHR_NFORI) + "/" + cValToChar(ZHR->ZHR_SERORI) + " não localizada"
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
    If SD1->( DbSeek( FWxFilial("SD1") + cNFOri + cSerOri + cForOri + cLojOri ))
        cRegistros += "Nota de devolução já gerada: " + SD1->D1_DOC + " " + SD1->D1_SERIE
        RestArea(aArea)
        Return .T.

    EndIf

    cTpNrNfs := SuperGetMV("MV_TPNRNFS")
    cNumero  := NxtSX5Nota(Padr(cSerie, TamSX3("D2_SERIE")[1], " "),.T.,cTpNrNfs)

    If Empty(cNumero)
        cRegistros += "Função NxtSX5Nota não retornou próximo número disponível para emissão de nota fiscal"
        RestArea(aArea)
        Return .F.

    EndIf

	Aadd(aItens,{{"D1_FILIAL" ,FWxFilial("SD1"),Nil},;
				{"D1_COD"    ,SD2->D2_COD     ,Nil},;
				{"D1_TES"    ,cTes            ,Nil},;
				{"D1_NFORI"  ,SD2->D2_DOC     ,Nil},;
				{"D1_SERIORI",SD2->D2_SERIE   ,Nil},;
				{"D1_ITEMORI",SD2->D2_ITEM    ,Nil},;
				{"D1_DOC"    ,cNumero         ,Nil},;
				{"D1_SERIE"  ,cSerie          ,Nil},;
				{"D1_ITEM"   ,"0001"          ,Nil},;
				{"D1_UM"     ,SD2->D2_UM      ,Nil},;
				{"D1_QUANT"  ,SD2->D2_QUANT   ,Nil},;
				{"D1_VUNIT"  ,SD2->D2_PRCVEN  ,Nil},;
				{"D1_TOTAL"  ,SD2->D2_TOTAL   ,Nil},;
				{"D1_FORNECE",SD2->D2_CLIENTE ,Nil},;
				{"D1_LOJA"   ,SD2->D2_LOJA    ,Nil},;
				{"D1_EMISSAO", Date()         ,Nil},;
				{"D1_DTDIGIT", Date()         ,Nil},;
				{"D1_LOCAL"  ,SD2->D2_LOCAL   ,Nil},;
				{"D1_CC"     ,SD2->D2_CCUSTO  ,Nil},;
				{"D1_FORMUL" ,"S"             ,Nil},;
				{"D1_TIPO"   ,"N"             ,Nil},;
                {"D1_ITEMCTA",cItemCC         ,Nil},;
                {"D1_CONTA"  ,SD2->D2_CONTA   ,Nil},;
                {"D1_GRUPO"  ,SD2->D2_GRUPO   ,Nil},;
                {"D1_NFRURAL",SD2->D2_DOC     ,Nil},;
                {"D1_SRRURAL",SD2->D2_SERIE   ,Nil},;
                {"D1_TP"     ,SD2->D2_TP      ,Nil}})
				
        aCab := {{"F1_FILIAL" ,FWxFilial("SF1") ,Nil},;
                 {"F1_TIPO"   ,"N"              ,Nil},;
                 {"F1_FORMUL" ,"S"              ,Nil},;
                 {"F1_DOC"    ,cNumero          ,Nil},;
                 {"F1_SERIE"  ,cSerie           ,Nil},;
                 {"F1_EMISSAO",Date()           ,Nil},;
                 {"F1_DTDIGIT",Date()           ,Nil},;
                 {"F1_FORNECE",SD2->D2_CLIENTE  ,Nil},;
                 {"F1_LOJA"   ,SD2->D2_LOJA     ,Nil},;
                 {"F1_ESPECIE","SPED"           ,Nil},;
                 {"F1_VALMERC",SD2->D2_TOTAL    ,Nil},;
                 {"F1_VALBRUT",SD2->D2_TOTAL    ,Nil}}

    aCab   := FWVetByDic(aCab,  "SF1",.F.,1)

    aItens := FWVetByDic(aItens,"SD1",.T.,1)

    MsExecAuto({|x,y| MATA103(x,y)}, aCab, aItens, 3)

    If lMsErroAuto
        cRegistros += MostraErro()
        RestArea(aArea)
        Return .F.

    Else

        DbSelectArea("SD1")
        SD1->(DbSetOrder(19))
        SD1->(DbGoTop())
        If ! SD1->( DbSeek( FWxFilial("SD1") + cNFOri + cSerOri + cForOri + cLojOri ))
            cRegistros += "Nota de devolução não lançada."
            RestArea(aArea)
            Return .F.

        EndIf

        Aadd(aNFTrans, {cNumero, cSerie})

        cRegistros += "Nota de devolução gerada: " + cNumero + " " + cSerie

        U_GrLogZBE(Date(), Time(), cUserName, "DEVOLUCAO DE NF " + cNumero + " " + cSerie, "FATURAMENTO", "ADFAT057P",;
            ZHR->ZHR_NUMERO, ComputerName(), LogUserName())

    EndIf

    If Len(aNFtrans) > 0
	    //MsAguarde({|| transmNF(aNFTrans, cSerie, "D", cForOri, cLojOri) },"Aguarde","Transmitindo NF's...") //Everson - 10/07/2022. Chamado TI

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function gerDev
    Gera entrada por devolução de sobra.
    @type  Function
    @author Everson
    @since 07/07/2022
    @version 01
/*/
Static Function gerDevS(cNum, cRegistros)

    //Variáveis.
    Local aArea     := GetArea()
    Local aItens    := {}
    Local aCab      := {}
    Local cNumero   := ""
    Local cTes      := Alltrim(cValToChar(GETMV("MV_#ADF577",,"15C"))) //"15A" //Sobra de ração 15C
    Local cItemCC   := Alltrim(cValToChar(GETMV("MV_#ADF578",,"114"))) //"114"
    Local cLocal    := Alltrim(cValToChar(GETMV("MV_#ADF579",,"08"))) //"114"
    Local cContaC   := Alltrim(cValToChar(GETMV("MV_#ADF57A",,"111520004"))) //"114"
    Local cSerie	:= Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
    Local cTpNrNfs  := ""
    Local cForOri   := ""
    Local cLojOri   := ""
    Local aNFTrans  := {}
    Local cGranjada := ""
    Local nTotal    := 0
    Local nVlTotal  := 0

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.

    Default cRegistros  := ""

    cRegistros += xPula

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))
        cRegistros += "Faturamento " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.
        
    EndIf

    cGranjada := ZHR->ZHR_DESGOR

    If ! U_ADLFV22C(cGranjada)
        cRegistros += "Granjada " + cGranjada + " não localizada"
        RestArea(aArea)
        Return .F.

    EndIf

    While ! ZHR->(Eof()) .And. ZHR->ZHR_FILIAL == FWxFilial("ZHR") .And. ZHR->ZHR_NUMERO == cNum

        nTotal += ZHR->ZHR_QTDDES

        ZHR->(DbSkip())

    End

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))
        cRegistros += "Faturamento " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.
        
    EndIf

    nVlTotal := Round(nTotal * ZHR->ZHR_VLRUNT,2)
    cForOri  := ZIS->ZIS_FORNEC
    cLojOri  := ZIS->ZIS_LOJA

    cTpNrNfs := SuperGetMV("MV_TPNRNFS")
    cNumero  := NxtSX5Nota(Padr(cSerie, TamSX3("D2_SERIE")[1], " "),.T.,cTpNrNfs)

    If Empty(cNumero)
        cRegistros += "Função NxtSX5Nota não retornou próximo número disponível para emissão de nota fiscal"
        RestArea(aArea)
        Return .F.

    EndIf

	Aadd(aItens,{{"D1_FILIAL" ,FWxFilial("SD1"),Nil},;
				{"D1_COD"    ,ZHR->ZHR_PRDPRO ,Nil},;
				{"D1_TES"    ,cTes            ,Nil},; //15C
				{"D1_DOC"    ,cNumero         ,Nil},;
				{"D1_SERIE"  ,cSerie          ,Nil},;
				{"D1_ITEM"   ,"0001"          ,Nil},;
				{"D1_UM"     ,"KG"            ,Nil},;
				{"D1_QUANT"  ,nTotal          ,Nil},;
				{"D1_VUNIT"  ,ZHR->ZHR_VLRUNT ,Nil},;
				{"D1_TOTAL"  ,nVlTotal        ,Nil},;
				{"D1_FORNECE",cForOri         ,Nil},;
				{"D1_LOJA"   ,cLojOri         ,Nil},;
				{"D1_EMISSAO", Date()         ,Nil},;
				{"D1_DTDIGIT", Date()         ,Nil},;
				{"D1_LOCAL"  ,cLocal          ,Nil},; //08
				{"D1_FORMUL" ,"S"             ,Nil},;
				{"D1_TIPO"   ,"N"             ,Nil},;
                {"D1_ITEMCTA",cItemCC         ,Nil},; //114
                {"D1_CONTA"  ,cContaC         ,Nil},; //111520004 
                {"D1_NFRURAL",ZHR->ZHR_NFRURA ,Nil},;
                {"D1_SRRURAL",ZHR-ZHR_SRRURA  ,Nil}})
//Data de lancamento --834922  019782 02
				
        aCab := {{"F1_FILIAL" ,FWxFilial("SF1") ,Nil},;
                 {"F1_TIPO"   ,"N"              ,Nil},;
                 {"F1_FORMUL" ,"S"              ,Nil},;
                 {"F1_DOC"    ,cNumero          ,Nil},;
                 {"F1_SERIE"  ,cSerie           ,Nil},;
                 {"F1_EMISSAO",Date()           ,Nil},;
                 {"F1_DTDIGIT",Date()           ,Nil},;
                 {"F1_DTLANC" ,Date()           ,Nil},;
                 {"F1_FORNECE",cForOri          ,Nil},;
                 {"F1_LOJA"   ,cLojOri          ,Nil},;
                 {"F1_ESPECIE","SPED"           ,Nil},;
                 {"F1_VALMERC",nVlTotal         ,Nil},;
                 {"F1_VALBRUT",nVlTotal         ,Nil}}

    aCab   := FWVetByDic(aCab,  "SF1",.F.,1)

    aItens := FWVetByDic(aItens,"SD1",.T.,1)

    MsExecAuto({|x,y| MATA103(x,y)}, aCab, aItens, 3)

    If lMsErroAuto
        cRegistros += MostraErro()
        RestArea(aArea)
        Return .F.

    Else

        Aadd(aNFTrans, {cNumero, cSerie})

        cRegistros += "Nota de devolução gerada: " + cNumero + " " + cSerie

        U_GrLogZBE(Date(), Time(), cUserName, "DEVOLUCAO DE NF " + cNumero + " " + cSerie, "FATURAMENTO", "ADFAT057P",;
            ZHR->ZHR_NUMERO, ComputerName(), LogUserName())

    EndIf

    If Len(aNFtrans) > 0
	    //MsAguarde({|| transmNF(aNFTrans, cSerie, "D", cForOri, cLojOri) },"Aguarde","Transmitindo NF's...") //Everson - 10/07/2022. Chamado TI

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function gerPedS
    Gera pedido de saída.
    @type  Function
    @author Everson
    @since 03/06/2022
    @version 01
/*/
Static Function gerPedS(cNum, cRegistros, aPedInc)

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
    Local cOrdPOri := ""

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.

    Default cRegistros := ""

    cRegistros += xPula
    
    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(1))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cNum ))
        cRegistros += "Faturamento " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.
        
    EndIf


    If ZHR->ZHR_TIPO == "1"

        cNFOri  := ZHR->ZHR_NFORI
        cSerOri := ZHR->ZHR_SERORI
        cForOri := ZHR->ZHR_FORORI
        cLojOri := ZHR->ZHR_LOJORI


        DbSelectArea("SD1")
        SD1->(DbSetOrder(19))
        SD1->(DbGoTop())
        If ! SD1->( DbSeek( FWxFilial("SD1") + cNFOri + cSerOri + cForOri + cLojOri ))
            cRegistros += "Nota de devolução não lançada."
            RestArea(aArea)
            Return .F.

        EndIf

        cOrdPOri := ZHR->ZHR_ORPORI

    Else

        cOrdPOri := obtUltOrd(ZHR->ZHR_DESGOR, ZHR->ZHR_PRDSAG)

        If Empty(cOrdPOri)
            cRegistros += "Não há envio do produto " + cValToChar(ZHR->ZHR_PRDSAG) + " para granjada " + cValToChar(ZHR->ZHR_DESGOR) + ""
            RestArea(aArea)
            Return .F.

        EndIf

    EndIf

    cRegistros += "Pedidos gerados: " + xPula

    While ! ZHR->(Eof()) .And. ZHR->ZHR_FILIAL == FWxFilial("ZHR") .And. ZHR->ZHR_NUMERO == cNum

        //Posiciona na ordem de pesagem.
        If ! U_ADFAT16A(cOrdPOri)
            cRegistros += "Ordem de pesagem " + cValToChar(cOrdPOri) + " não localizada."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no registro de pátio selecionado.
        If ! U_ADFAT17U(ZIF->ZIF_CTPATI)
            cRegistros += "Controle de pátio não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no cadastro de veículo.
        DbSelectArea("ZV4")
        ZV4->(DbSetOrder(1))
        ZV4->(DbGoTop())
        If ! ZV4->( DbSeek( FWxFilial("ZV4") + ZHR->ZHR_PLACAD))
            cRegistros += "Veículo " + ZHR->ZHR_PLACAD + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        //Posiciona no cadastro de roteiro de pesagem.
        If ! U_ADFAT15B(ZIB->ZIB_CODROT)
            cRegistros += "Roteiro de pesagem " +  ZIB->ZIB_CODROT + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf      

        //Posiciona no item do cadastro de pesagem.
        DbSelectArea("ZIA")
        ZIA->(DbSetOrder(2))
        ZIA->(DbGoTop())
        If ! ZIA->( DbSeek( FWxFilial("ZIA") + ZIB->ZIB_CODROT + ZIF->ZIF_PRDSAG))
            cRegistros += "Item do roteiro de pesagem " +  ZIB->ZIB_CODROT + " " + ZIF->ZIF_PRDSAG + " não localizado."
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
        cNmOrdem := cOrdPOri
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
        Aadd( aCabec, { "C5_OBS"      , "REFATURAMENTO", .F. } )

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
            cRegistros += MostraErro()
            RestArea(aArea)
            Return .F.

        Else

            U_GrLogZBE(Date(), Time(), cUserName, "PEDIDO DE VENDA " + SC5->C5_NUM, "FATURAMENTO", "ADFAT057P",;
                ZHR->ZHR_NUMERO, ComputerName(), LogUserName())

            Aadd(aPedInc, SC5->C5_NUM)
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
            cRegistros += "Cliente " + cCodCF + cLoja + " não localizado."

        Else
            lRet := .T.
            aCampo  := {{"A1_END", SA1->A1_END}, {"A1_EST", SA1->A1_EST}, {"A1_BAIRRO", SA1->A1_BAIRRO}, {"A1_CIDADE", SA1->A1_Mun}, {"A1_COND", SA1->A1_COND}}
            cTpPed  := "N"

        EndIf

    Else

        If ! SA2->( DbSeek( FWxFilial("SA2") + cCodCF + cLoja))
            cRegistros += "Fornecedor " + cCodCF + cLoja + " não localizado."

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
/*/{Protheus.doc} ADFAT573
    Posiciona no registro de refaturamento pelo pedido.
    @type  User Function
    @author Everson
    @since 14/06/2022
    @version 01
/*/
User Function ADFAT573(cPedido)

    DbSelectArea("ZHR")
    ZHR->(DbSetOrder(7))
    If ! ZHR->(DbSeek( FWxFilial("ZHR") + cPedido ))
        Return .F.
        
    EndIf

Return .T.
/*/{Protheus.doc} ADFAT574
	Interface para seleção de pedidos a serem faturados. Chamado 033511.
	@type  Function
	@author Everson
	@since 05/07/2022
	@version 01
/*/
User Function ADFAT574(cPedProth)

	//Variáveis.	
	Local aArea		:= GetArea() 
	Local cQuery	:= ""
	Local nNFGer	:= 0
	Local nNFErr    := 0
	Local lRetNf	:= .F.
	Local cNota     := ""
	Local cSerie	:= Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
	Local aNFTrans	:= {}
	Local cNFErro	:= ""
	Local cAliasF2	:= ""
	
	Private aNfGerada 	:= {}

	If Empty(cSerie)
		MsgStop("Série da nota fiscal não definida no parâmetro MV_#SRNFIT.", "Função ADFAT574(ADFAT057P)")
		RestArea(aArea)
		Return aNFTrans
			
	EndIf
	
	cQuery := ""
	cQuery += " SELECT " 
	    cQuery += " C5_FILIAL, CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_PEDSAG, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_PLACA, C5_TRANSP " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " AS SC5 (NOLOCK) " 
	cQuery += " WHERE " 
        cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
        cQuery += " AND C5_NOTA = '' " 
        cQuery += " AND C5_SERIE = '' " 
        cQuery += " AND C5_NUM IN (" + cPedProth + ")"
        cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY C5_NUM " 
	
	cAliasF2 := GetNextAlias()

	MsAguarde({|| DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasF2, .F., .T.) },"Função ADFAT574(ADFAT057P)","Carregando registros...")
	
	DbSelectArea(cAliasF2)
	(cAliasF2)->(DbGoTop())
	
	If (cAliasF2)->(Eof())
		(cAliasF2)->(DbCloseArea())
		MsgStop("Não há pedidos para emissão doc de saída.","Função ADFAT574(ADFAT057P)")
		RestArea(aArea)
		Return aNFTrans
		
	EndIf
	
	While ! (cAliasF2)->(Eof())
		
		lRetNf := .F.

		MsAguarde({|| NfLot(Alltrim(cValToChar((cAliasF2)->C5_NUM)), @cNota, @lRetNf, cSerie) },"Aguarde", "Emitindo NF, pedido " + Alltrim(cValToChar((cAliasF2)->C5_NUM + "...")))
		
		If lRetNf
			nNFGer++
			
		Else
			nNFErr++
			
		EndIf

		Aadd(aNfGerada, {cNota, Alltrim(cValToChar((cAliasF2)->C5_NUM)), lRetNf, cSerie} )
		
		If lRetNf
			Aadd(aNFTrans, {cNota, cSerie, (cAliasF2)->C5_NUM})
			
		EndIf
		
		If ! lRetNf
			cNFErro += Alltrim(cValToChar((cAliasF2)->C5_NUM)) + " " + cNota + Chr(13) + Chr(10)
		
		EndIf
		
		(cAliasF2)->(DbSkip())
		
	End

	If ! Empty(cNFErro)
		cNFErro := "Não foram geradas as notas fiscais para os pedidos abaixo: " + Chr(13) + Chr(10) + cNFErro
		MsgAlert(cNFErro,"Função ADFAT574(ADFAT057P)")
	
	EndIf
	
	If Len(aNFTrans) > 0
        U_ADFAT575(aNFTrans)
	 	//MsAguarde({|| transmNF(@aNFTrans, cSerie, "S") }, "Aguarde", "Transmitindo NF's...") //Everson - 10/07/2022. Chamado TI

	EndIf
	
	RestArea(aArea)
	
Return aNFTrans
/*/{Protheus.doc} ADFAT575
	Altera status do registro de refaturamento.
	@type  Static Function
	@author Everson
	@since 05/07/2022
	@version 01
/*/
User Function ADFAT575(aNFTrans)

    //Variáveis.
    Local aArea := GetArea()
    Local nAux  := 1
    Local cNvPed:= ""

    For nAux := 1 To Len(aNFTrans)

        cNvPed := aNFTrans[nAux][3]

        If ! U_ADFAT573(cNvPed)
            Loop

        EndIf

        While ! ZHR->(Eof()) .And. ZHR->ZHR_FILIAL == FWxFilial("ZHR") .And. ZHR->ZHR_NVPED == cNvPed

            RecLock("ZHR", .F.)
                ZHR->ZHR_STATUS := "4"
                ZHR->ZHR_NFSERD := cValToChar(aNFTrans[nAux][1]) + cValToChar(aNFTrans[nAux][2])
            ZHR->(MsUnlock())

            ZHR->(DbSkip())

        End

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} NfLot
	Gera nota fiscal de saída.
	@type  Static Function
	@author Everson
	@since 05/07/2022
	@version 01
/*/
Static Function NfLot(cNumPed,cNota,lRetNf,cSerie)

    //Variáveis.
	Local aArea	  	    := GetArea()
	Local aPvlNfs 	    := {}
	Local lRet		    := .F.
	
	//Localiza pedido de venda - cabeçalho.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(MsSeek(FWxFilial("SC5") + cNumPed))
	If SC5->(Eof())
		cNota := "Pedido não localizado (SC5)."
		RestArea(aArea)
		Return lRet

	EndIf

	//Localiza condição de pagamento do pedido.
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(MsSeek(FWxFilial("SE4") + SC5->C5_CONDPAG))
	If SE4->(Eof())
		cNota := "Condição de pagamento não localizada (SE4): " + Alltrim(cValToChar(SC5->C5_CONDPAG)) + "."
		RestArea(aArea)
		Return lRet

	EndIf

	//Localiza pedido de venda - itens.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(MsSeek(FWxFilial("SC6") + cNumPed))
	If SC6->(Eof())
		cNota := "Pedido não localizado (SC6)."
		RestArea(aArea)
		Return lRet

	EndIf
	
	//Abre tabelas e configura os índices a serem usados.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))	

	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	
	//Itera sobre os itens do pedido de venda.
	While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_NUM)) == cNumPed
	
	 	If SC9->(MsSeek(FWxFilial("SC9") + SC6->(C6_NUM + C6_ITEM))) // Valida se o item está liberado na tabela SC9.
	 		
	 		If Empty(Alltrim(cValToChar(SC9->C9_BLCRED))) .And. Empty(Alltrim(cValToChar(SC9->C9_BLEST))) // Valida se o item está liberado pelo financeiro e estoque.
	 			
	 			//Localiza cadastro do produto.
				SB1->(MsSeek(FWxFilial("SB1") + SC6->C6_PRODUTO))
				If SB1->(Eof())
					cNota := "Produto não localizado: " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
				
				//Localiza cadastro de saldos físico e financeiro do produto para o local informado.
				SB2->(MsSeek(FWxFilial("SB2") + SC6->(C6_PRODUTO + C6_LOCAL)))
				If SB2->(Eof())
					cNota := "Produto sem cadastro de saldos físicos e financeiros (SB2): " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + " Local: " + Alltrim(cValToChar(SC6->C6_LOCAL)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
				
				//Localiza o cadastro do TES informado.			
				SF4->(MsSeek(FWxFilial("SF4") + SC6->C6_TES))
				If SF4->(Eof())
					cNota := "TES não localizado (SF4): " + Alltrim(cValToChar(SC6->C6_TES)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
				
				//Monta array para geração da NF de saída.		 	
				Aadd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			
			Else
				cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
				RestArea(aArea)
				Return lRet	
			
			EndIf
			
		Else

			cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
			RestArea(aArea)
			Return lRet			
			
		EndIf
		
		SC6->(DbSkip())
	
	End
	
	/*
	±±³Descri‡…o ³Inclusao de Nota fiscal de Saida atraves do PV liberado     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os itens a serem gerados                   ³±±
	±±³          ³ExpC2: Serie da Nota Fiscal                                 ³±±
	±±³          ³ExpC3: Numero da Nota Fiscal                                ³±±
	±±³          ³ExpL4: Lancamento 610                                       ³±±
	±±³          ³ExpL5: Lancamento 620                                       ³±±
	±±³          ³ExpN6: Controle de contabilizacao                           ³±±
	±±³          ³ExpN7: Handle do arquivo de contabilizacao                  ³±±
	±±³          ³ExpL8: Reajuste de preco na nota fiscal                     ³±±
	±±³          ³ExpN9: Tipo de Acrescimo Financeiro                         ³±±
	±±³          ³ExpNA: Tipo de Arredondamento                               ³±±
	±±³          ³ExpLB: Atualiza Amarracao Cliente x Produto                 ³±±
	±±³          ³ExplC: Cupom Fiscal                                         ³±±
	±±³          ³ExpCD: Numero do Embarque de Exportacao                     ³±±
	±±³          ³ExpBE: Code block para complemento de atualizacao dos titu- ³±±
	±±³          ³       los financeiros.                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	*/

	If Len(aPvlNfs) > 0

        DbSelectArea("SX5")
        cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
        lRet   := .T.
        lRetNf := .T.

	Else
		cNota := "Pedido de venda não liberado (SC9)."
		
	EndIf
	
	RestArea(aArea)

return lRet
/*/{Protheus.doc} transmNF
	Transmissão de nota fiscal.
	@type  Static Function
	@author Everson
	@since 05/07/2022
	@version 01
	/*/
Static Function transmNF(aNFTrans, cSerie, cTpMv, cFornec, cLoja)

    //Variáveis.
	Local aArea		:= GetArea()
	Local cIdent    := ""
    Local oWs       := Nil
	Local cURL		:= ""
	Local cNFIni	:= aNFTrans[1][1]
	Local cNFFim	:= aNFTrans[Len(aNFTrans)][1]
	Local cNFT 		:= ""
	Local cAmbiTrans:= ""
	Local nAux		:= 1
	
	MsgInfo("Notas geradas de " + cNFIni + " até " + cNFFim + ".","Função transmNF", "Função transmNF(ADFAT057P)")

    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " ADFAT057P - transmNF - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a transmissão automática, faça a transmissão manual." ,"Função transmNF(ADFAT057P)")
		RestArea(aArea)
        Return .F. 

    EndIf

    cIdent := RetIdEnti()

    oWs := WsSpedCfgNFe():New()

    cURL := PadR(GetMv("MV_SPEDURL"),250)

    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT := cIdent
    oWS:nAmbiente := 0
    oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    
    If oWS:CFGAMBIENTE()
        cAmbiTrans := oWS:cCfgAmbienteResult
        cAmbiTrans := Substr(cAmbiTrans,1,1)

    EndIf

    Conout( DToC(Date()) + " " + Time() + " ADFAT057P - transmNF - ambiente para transmissão NF " + cAmbiTrans)
	
	If Empty(cAmbiTrans)
		Conout( DToC(Date()) + " " + Time() + " ADFAT057P - transmNF - Não foi possível obter o ambiente de transmissão de nota fiscal.")
		MsgStop("Não foi possível obter o ambiente de transmissão de nota fiscal.","Função transmNF(ADFAT057P)")
		RestArea(aArea)
		Return .F.
		
	EndIf

    If cTpMv == "D"

        DbSelectArea("SF1")
        SF1->(DbSetOrder(1))
        SF1->(DbGoTop())

        If SF1->(DbSeek( xFilial("SF1") + cNFIni + cSerie + Space(TamSX3("F1_SERIE")[1] - Len(cSerie)) +  cFornec +  cLoja ))
            MsAguarde({|| AutoNfeEnv(cEmpAnt, SF1->F1_FILIAL, "5", cAmbiTrans, SF1->F1_SERIE, cNFIni, cNFFim) },"Transmitindo NF","De " + cNFIni + " até " + cNFFim + " Série: " + cValToChar(SF1->F1_SERIE) + " ..." )
            
        Else
            MsgStop("Não foi possível efetuar a transmissão das notas fiscais.","Função transmNF(ADFAT057P)")
        
        EndIf

    ElseIf cTpMv == "S"

        DbSelectArea("SF2")
        SF2->(DbSetOrder(1))
        SF2->(DbGoTop())
        
        For nAux := 1 To Len(aNFTrans) 

            cNFT := aNFTrans[nAux][1]

            SF2->(DbGoTop())
            If SF2->(DbSeek( FWxFilial("SF2") + cNFT + cSerie ))
                
                If SM0->M0_CODFIL == SF2->F2_FILIAL
                    MsAguarde({|| AutoNfeEnv(FWCodEmp(),SF2->F2_FILIAL,"1",cAmbiTrans,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC) },"Transmitindo NF","De " + cNFT + " até " + cNFT + " Série: " + cSerie + " ..." )
                
                Else
                    MsgStop("A filial corrente está divergente da NF para transmissão " + cNFT + cSerie + ".", "Função transmNF(ADFAT057P)")

                Endif

            Else 
                MsgStop("NF não encontrada para transmissão " + cNFT + cSerie + ".", "Função transmNF(ADFAT057P)")
                
            EndIf 

        Next nAux 

    EndIf

	MsAguarde({|| imprimeNF(cValToChar(aNFTrans[1][1]),cValToChar(aNFTrans[Len(aNFTrans)][1]), cTpMv) },"Aguarde","Imprimindo notas fiscais...")

	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} imprimeNF
	Carrega o conteúdo na variável da pergunta. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 05/07/2022
	@version 01
/*/
Static Function imprimeNF(cNFIni,cNFFim, cTpMv)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cCondicao := "F2_FILIAL=='"+FWxFilial("SF2")+"'"

	Private aFilBrw	:=	{'SF2',cCondicao}

	Default cNFIni	:= ""
	Default cNFFim	:= ""
	
	If ! Empty(cNFIni) .And. ! Empty(cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR01", cNFIni)
		zAtuPerg("NFSIGW", "MV_PAR02", cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR04", Iif(cTpMv == "D", 1, 2))
		
	EndIf
	
	SpedDanfe()
	
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} zAtuPerg
	Carrega o conteúdo na variável da pergunta.
	@type  Static Function
	@author Everson
	@since 05/07/2022
	@version 01
/*/
Static Function zAtuPerg(cPergAux, cParAux, xConteud)

	//Variáveis.
	Local aArea      := GetArea()
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}

	Default xConteud := ''

	If Empty(cPergAux) .Or. Empty(cParAux)
		Return Nil

	EndIf

	//Chama a pergunta em memória.
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR.
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parâmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

		//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD("+dToS(xConteud)+")")

		//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parâmetros
		__SaveParam(cPergAux, aPergAux)

	EndIf

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT576
	Valida granjada selecionada.
	@type  Function
	@author Everson
	@since 07/07/2022
	@version 01
/*/
User Function ADFAT576(cGranjada)

    //Variáveis.
    Local aArea := GetArea()

    Default cGranjada := ""

    If U_ADFAT578() == "1"
        RestArea(aArea)
        Return .T.
        
    EndIf

    If ! U_ADLFV22C(cGranjada)
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Granjada " + cGranjada + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIS->ZIS_ATIVO <> "1"
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Granjada " + cGranjada + " está bloqueada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT577
	Valida produto selecionado.
	@type  Function
	@author Everson
	@since 07/07/2022
	@version 01
/*/
User Function ADFAT577(cPrdSAG)

    //Variáveis.
    Local aArea  := GetArea()
    Local lLote  := .F.

    Default cPrdSAG := ""

    If U_ADFAT578() == "1"
        RestArea(aArea)
        Return .T.

    EndIf

    FWFldPut("ZHR_PRDPRO", Space(TamSX3("ZHR_PRDPRO")[1]))
    FWFldPut("ZHR_DESPRT", Space(TamSX3("ZHR_DESPRT")[1]))
    FWFldPut("ZHR_VLRUNT", 0)

    If ! U_ADFAT20B(cPrdSAG)
        Help(Nil, Nil, "Função ADFAT577(ADFAT057P)", Nil, "Produto " + cPrdSAG + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ! ("RACAO" $ZIM->ZIM_GRPSAG)
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Produto " + cPrdSAG + " não é ração.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZIM->ZIM_ATIVO <> "1"
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Produto " + cPrdSAG + " está bloqueado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(obtUltOrd(Alltrim(cValToChar(M->ZHR_DESGOR)), cPrdSAG))
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Não há envio do produto " + cPrdSAG + " para granjada " + cValToChar(M->ZHR_DESGOR) + "", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(3))
    ZI8->(DbGoTop())

    If ! ZI8->( DbSeek( FWxFilial("ZI8") + cPrdSAG))
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Produto " + cPrdSAG + " não possui lote.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    While ! ZI8->(Eof()) .And. ZI8->ZI8_FILIAL == FWxFilial("ZI8") .And. Alltrim(cValToChar(ZI8->ZI8_PRDSAG)) == Alltrim(cValToChar(cPrdSAG))

        If ZI8->ZI8_STATUS $"1"
            lLote := .T.

        EndIf

        If ZI8->ZI8_STATUS $"2"
            lLote := .T.
            Exit

        EndIf

        ZI8->(DbSkip())

    End

    If ! lLote
        Help(Nil, Nil, "Função ADFAT576(ADFAT057P)", Nil, "Produto " + cPrdSAG + " não possui lote em aberto ou em uso.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    Else
        FWFldPut("ZHR_PRDPRO", ZIM->ZIM_PRDPRO)
        FWFldPut("ZHR_DESPRT", ZIM->ZIM_DESSAG)
        FWFldPut("ZHR_VLRUNT", ZI8->ZI8_LTCUST)

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT578
	Retorna o tipo de registro.
	@type  Function
	@author Everson
	@since 08/07/2022
	@version 01
/*/
User Function ADFAT578()
Return cTpMv
/*/{Protheus.doc} obtUltOrd
	Retorna a última ordem a ser enviada para granjada de um determinado produto.
	@type  Static Function
	@author Everson
	@since 08/07/2022
	@version 01
/*/
Static Function obtUltOrd(cDescGrj, cPrdSAG)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cNmOrdem  := ""

    cQuery := ""
    cQuery += " SELECT " 
        cQuery += " MAX(ZIF_NUMERO) AS ZIF_NUMERO " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIR") + "  (NOLOCK) AS ZIR ON " 
        cQuery += " ZIF_FILIAL = ZIR_FILIAL " 
        cQuery += " AND ZIF_ORDRAC = ZIR_NUMERO " 
    cQuery += " WHERE " 
        cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
        cQuery += " AND ZIR_DESGRJ = '" + cDescGrj + "' " 
        cQuery += " AND ZIR_PRDSAG = '" + cPrdSAG + "' " 
        cQuery += " AND ZIF_TPMOVI = 'R' " 
        cQuery += " AND ZIF_STATUS IN ('5','6') " //5=Encerrada, 6=Sequestro liberado.
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIR.D_E_L_E_T_ = '' " 

    If Select("D_ULTORD") > 0
        D_ULTORD->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ULTORD"
    DbSelectArea("D_ULTORD")

        cNmOrdem := Alltrim(cValToChar(D_ULTORD->ZIF_NUMERO))

    D_ULTORD->(DbCloseArea())

    RestArea(aArea)

Return cNmOrdem
