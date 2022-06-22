#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "FWPrintSetup.ch"
#Include "RPTDEF.CH"

Static cTbMast  := "ZHS"
Static cTitulo  := "Pedido de Transferência entre Filiais"
Static cTiMast  := "Dados do pedido de transferência"

/*/{Protheus.doc} User Function ADFAT058P
    Pedido de transferência.
    Transf Entre Filiais
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/06/2022
    @version 01
    /*/
User Function ADFAT058P() // U_ADFAT058P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT058P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZHS_STATUS = '1' ","BR_VERDE"   , "Aberto"    )
    oBrowse:AddLegend("ZHS_STATUS = '2' ","BR_AZUL"    , "Aprovado"    )
    oBrowse:AddLegend("ZHS_STATUS = '3' ","BR_VERMELHO", "Pedido Gerado" )

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}
    //Local cUsrInc := Alltrim(cValToChar(GetMv("MV_#ADF581",,"")))
    Local cUsrApv := Alltrim(cValToChar(GetMv("MV_#ADF582",,"")))
    //Local cUsrGer := Alltrim(cValToChar(GetMv("MV_#ADF583",,"")))

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT058P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0

    //If FWIsAdmin() .Or. __cUserID $cUsrInc
        ADD OPTION aRotina TITLE "Incluir" 	ACTION "VIEWDEF.ADFAT058P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
        ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.ADFAT058P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
        ADD OPTION aRotina TITLE "Excluir" 	ACTION "VIEWDEF.ADFAT058P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0

    //EndIf

    If FWIsAdmin() .Or. __cUserID $cUsrApv
        ADD OPTION aRotina TITLE "Aprovar"  ACTION "U_ADFAT58D()"       OPERATION 10  ACCESS 0

    EndIf

    //If FWIsAdmin() .Or. __cUserID $cUsrGer
        ADD OPTION aRotina TITLE "Processar" ACTION "U_ADFAT58E()"       OPERATION 11  ACCESS 0

    //EndIf

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := Nil

    bPost := {|oModel| vldPos(oModel)}

    oModel := MPFormModel():New("ADFAT58", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
    
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,{|oModelGrid| vldGrid(oModelGrid) },,,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHS_FILIAL"  , 'FWxFilial("' + cTbMast + '")'},;
            {"ZHS_NUMERO"  , "ZHS_NUMERO"},;
            {"ZHS_PLACA"   , "ZHS_PLACA"},;
            {"ZHS_FRETE"   , "ZHS_FRETE"},;
            {"ZHS_DESTIN"  , "ZHS_DESTIN"},;
            {"ZHS_GERSAI"  , "ZHS_GERSAI"},;
            {"ZHS_CODROT"  , "ZHS_CODROT"},;
            {"ZHS_STATUS"  , "ZHS_STATUS"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

    oModel:GetModel("MD_GRID"):SetUniqueLine({"ZHS_PRDSAG"}) 

    oModel:AddCalc("ADFAT58TOT", "MD_MASTER", "MD_GRID", "ZHS_QUANT", "ZHS_QTDTOT", "SUM", { | oFW | ADFAT57CAL( oFW, .T. ) },,"Quantidade Total")

Return oModel
/*/{Protheus.doc} vldGrid
    Valida grid.
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function vldGrid(oModelGrid)

    //Variáveis.
    Local cLote   := oModelGrid:GetValue("ZHS_LOTE")
    Local cPrdSAG := oModelGrid:GetValue("ZHS_PRDSAG")
    Local cPrdPro := oModelGrid:GetValue("ZHS_PRDPRO")

Return U_ADFAT18D(cLote, cPrdSAG, cPrdPro) .And. U_ADFAT58C(cPrdSAG)
/*/{Protheus.doc} ADFAT57CAL
    Calcular.
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function ADFAT57CAL(oFW, LALGO)
Return .T.
/*/{Protheus.doc} vldPre
    Pós validação.
    @type  Static Function
    @author Everson
    @since 10/06/2022
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
    @since 10/06/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cPlaca     := oModel:GetValue("MD_MASTER","ZHS_PLACA")
    Local cRotPes    := oModel:GetValue("MD_MASTER","ZHS_CODROT")
    Local cDestino   := oModel:GetValue("MD_MASTER","ZHS_DESTIN")
    Local cStatus    := oModel:GetValue("MD_MASTER","ZHS_STATUS")
    Local cQtdDes    := Val(cValToChar(oModel:GetValue("ADFAT58TOT","ZHS_QTDTOT")))

    If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)

        If lRet .And. nOperation == MODEL_OPERATION_UPDATE .And. cStatus == "3" .And. ! IsInCallStack("gerPedS")
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Registro não pode ser alterado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

        If lRet .And. Empty(cRotPes)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Necessário informar o roteiro de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. Empty(cPlaca)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Necessário informar a placa do veículo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. Empty(cDestino)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Necessário informar o destino.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cQtdDes <= 0
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Necessário informar a quantidade.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

        If lRet .And. cStatus <> "3" .And. nOperation == MODEL_OPERATION_UPDATE .And. ! IsInCallStack("gerPedS")
            oModel:SetValue("MD_MASTER","ZHS_CDAPRV", "")
            oModel:SetValue("MD_MASTER","ZHS_NMAPRV", "")
            oModel:SetValue("MD_MASTER","ZHS_DTAPRV", SToD(" / / "))
            oModel:SetValue("MD_MASTER","ZHS_HRAPRV", "")
            oModel:SetValue("MD_MASTER","ZHS_STATUS", "1")

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. cStatus == "3"
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT058P)", Nil, "Registro não pode ser excluído.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        
        EndIf

    EndIf

    RestArea(aArea)
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oModel    := FWLoadModel("ADFAT058P")
    Local oView     := Nil
    Local cCampos   := getCmps()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})
    Local oStrTotal := FWCalcStruct( oModel:GetModel("ADFAT58TOT") )

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
    oView:AddField("VW_CALC",   oStrTotal,"ADFAT58TOT")
 
    oView:CreateHorizontalBox("MAIN", 50)
    oView:CreateHorizontalBox("GRID", 35)
    oView:CreateHorizontalBox("CALC", 15)

    oView:SetOwnerView("VW_MASTER", "MAIN")
    oView:SetOwnerView("VW_GRID", "GRID")
    oView:SetOwnerView("VW_CALC", "CALC")

    oView:EnableControlBar(.T.)

    oView:AddIncrementField("VW_GRID", "ZHS_ITEM")

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cPlaca  := oModel:GetValue("MD_MASTER","ZHS_PLACA")
    Local cDest   := oModel:GetValue("MD_MASTER","ZHS_DESTIN")
    Local cRot    := oModel:GetValue("MD_MASTER","ZHS_CODROT")

    If Empty(cPlaca)
        Help(Nil, Nil, "Função gridFocus(ADFAT058P)", Nil, "Necessário informar a placa do veículo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHS_PLACA"):OCtrl:OGet:SetFocus()
        Return .F.

    EndIf

    If Empty(cDest)
        Help(Nil, Nil, "Função gridFocus(ADFAT058P)", Nil, "Necessário informar o destino.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHS_PLACA"):OCtrl:OGet:SetFocus()
        Return .F.

    EndIf

    If Empty(cRot)
        Help(Nil, Nil, "Função gridFocus(ADFAT058P)", Nil, "Necessário informar o roteiro de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHS_CODROT"):OCtrl:OGet:SetFocus()
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} getCmps
    Função retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function getCmps()
Return "ZHS_FILIAL;ZHS_NUMERO;ZHS_PLACA;ZHS_FRETE;ZHS_CODROT;ZHS_DESTIN;ZHS_GERSAI;ZHS_STATUS;ZHS_CDAPRV;ZHS_NMAPRV;ZHS_DTAPRV;ZHS_HRAPRV;"
/*/{Protheus.doc} ADFAT57
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
User Function ADFAT58()

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
            cNumero := oModelx:GetValue("MD_MASTER", "ZHS_NUMERO")

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
    @since 10/06/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea     := GetArea()
    Local cFilter   := ""
    Local cCmp      := getCmps()
    
    cFilter := " ZHS_FILIAL ='" + FWxFilial("ZHS") + "' .And. ZHS_NUMERO = '" + cNumero + "' "

    U_ADFAT27D("ZHS", 1, FWxFilial("ZHS") + cNumero,;
        "ZHS", 2, FWxFilial("ZHS") + cNumero, "ZHS_ITEM", cFilter,;
        "pedidos_de_transferencia_filiais_protheus", cOperacao,;
        .T., .T., .T.,;
        cCmp)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFAT58D
    Aprova registro.
    @type  Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
User Function ADFAT58D()

    //Variáveis.
    Local aArea := GetArea()
    Local cNum  := ZHS->ZHS_NUMERO

    If ZHS->ZHS_STATUS <> "1"
        MsgInfo("Ação não permitida.", "Função ADFAT58D(ADFAT058P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! MsgYesNo("Deseja aprovar o pedido de transferência " + cNum + "?", "Função ADFAT58D(ADFAT058P)")
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZHS")
    ZHS->(DbSetOrder(1))
    If ZHS->(DbSeek( FWxFilial("ZHS") + cNum ))

        While ! ZHS->(Eof()) .And. ZHS->ZHS_FILIAL == FWxFilial("ZHS") .And. ZHS->ZHS_NUMERO == cNum

            RecLock("ZHS", .F.)
                ZHS->ZHS_STATUS := "2"
                ZHS->ZHS_CDAPRV := __cUserID
                ZHS->ZHS_NMAPRV := cUserName
                ZHS->ZHS_DTAPRV := Date()
                ZHS->ZHS_HRAPRV := Time()
            ZHS->(MsUnlock())

            ZHS->(DbSkip())

        End

        grvBarr("A", cNum)

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFAT58E
    Gera pedido de saída.
    @type  Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
User Function ADFAT58E()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local cNum  := ZHS->ZHS_NUMERO
    Local cRegistros := ""

    If ZHS->ZHS_STATUS <> "2"
        MsgInfo("Ação não permitida.", "Função ADFAT58E(ADFAT058P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! MsgYesNo("Deseja processar a transferência " + cNum + "?", "Função ADFAT58E(ADFAT058P)")
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

    U_TExTelaMen("Geração de Pedido de Saída", cRegistros, "Arial",10,,.F.,.F.)

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function gerPedS
    Gera pedido de saída.
    @type  Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
Static Function gerPedS(cNum, cRegistros)

    //Variáveis.
    Local aArea    := GetArea()
    Local cRotPes  := ""//GetMv("MV_#ADF584",,"")
    Local aCabec   := {}
    Local aLinha   := {}
    Local aItens   := {}

    Local cTpPed   := ""
    Local cFornece := ""
    Local cLjForn  := ""
    Local aCampo   := {}
    Local cTpFrt   := ""
    Local cPlaca   := ""
    Local cTransp  := ""
    Local cUFPlaca := ""
    Local nPesoLiq := 0
    Local cPesoTot := 0
    Local cProduto := ""
    Local nVlrUnit := 0
    Local nTotal   := 0
    Local cTes     := ""
    Local cLocPad  := ""
    Local nItemPed := 1
    Local cItemPed := ""

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .F.

    Default cRegistros := ""

    //Posiciona no registro de pedido de transferência.
    If ! U_ADFAT582(cNum)
        cRegistros := "Pedido de transferência " + cNum + " não localizado"
        RestArea(aArea)
        Return .F.

    EndIf

    cRotPes  := ZHS->ZHS_CODROT
    
    cRegistros += Chr(13) + Chr(10) + Chr(13) + Chr(10)  + "Pedidos gerados: " + Chr(13) + Chr(10) 

    //Posiciona no cadastro de roteiro de pesagem.
    If ! U_ADFAT15B(cRotPes)
        cRegistros := "Roteiro de pesagem " +  cRotPes + " não localizado."
        RestArea(aArea)
        Return .F.

    EndIf

    cCliFor  := "C"
    cTpPed   := "N"
    cTpFrt   := ZHS->ZHS_FRETE
    cPlaca   := ZHS->ZHS_PLACA

    If ZHS->ZHS_DESTIN == "1"
        cFornece := "014999"
        cLjForn  := "00"

    ElseIf ZHS->ZHS_DESTIN == "2" .Or. ZHS->ZHS_DESTIN == "3"
        cFornece := "025652"
        cLjForn  := "00"

    EndIf

    If ! getInfo(cCliFor, @aCampo, @cTpPed, cFornece, cLjForn, @cRegistros)
        RestArea(aArea)
        Return .F.

    EndIf

    While ! ZHS->(Eof()) .And. ZHS->ZHS_FILIAL == FWxFilial("ZHS") .And. ZHS->ZHS_NUMERO == cNum

        aLinha   := {}

        cProduto := ZHS->ZHS_PRDPRO
        nPesoLiq := ZHS->ZHS_QUANT
        nVlrUnit := ZHS->ZHS_VLRUNT
        nTotal   := Round(ZHS->ZHS_VLRUNT * ZHS->ZHS_QUANT, TamSX3("C6_VALOR")[2])
        cLocPad  := ""
        
        cTes     := Iif(Alltrim(cValToChar(aCampo[2,2])) == "SP", ZI9->ZI9_TESEST, ZI9->ZI9_TESINT)
        
        cPesoTot += ZHS->ZHS_QUANT

        //Posiciona no item do cadastro de pesagem.
        DbSelectArea("ZIA")
        ZIA->(DbSetOrder(2))
        ZIA->(DbGoTop())
        If ! ZIA->( DbSeek( FWxFilial("ZIA") + cRotPes + ZHS->ZHS_PRDSAG))
            cRegistros := "Item do roteiro de pesagem " +  cRotPes + " " + ZHS->ZHS_PRDSAG + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf  

        //Posiciona no item de exceção de TES do cadastro de roteiro de pesagem.
        DbSelectArea("ZIU")
        ZIU->(DbSetOrder(4)) //Everson - 10/06/2022. ticket 18465.
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

        cItemPed := StrZero(nItemPed,2)

        Aadd( aLinha, { "C6_ITEM"	 , cItemPed	, Nil } )
        Aadd( aLinha, { "C6_PRODUTO" , cProduto	, Nil } )
        Aadd( aLinha, { "C6_UNSVEN"	 , nPesoLiq	,0 , Nil } )
        Aadd( aLinha, { "C6_PRCVEN"	 , nVlrUnit	,0 , Nil } )
        Aadd( aLinha, { "C6_VALOR"	 , nTotal	,0 , Nil } )
        Aadd( aLinha, { "C6_TES"	 , cTes	    ,.F. } )
        Aadd( aLinha, { "C6_LOCAL"	 , cLocPad  , Nil } )
        Aadd( aLinha, { "C6_PRUNIT"	 , nVlrUnit	,0 , Nil } )

        Aadd(aItens, aLinha)

        nItemPed++

        ZHS->(DbSkip())

    End

    Aadd( aCabec, { "C5_TIPO"	  , cTpPed     , Nil } )
    Aadd( aCabec, { "C5_CLIENTE"  , cFornece   , Nil } )
    Aadd( aCabec, { "C5_LOJACLI"  , cLjForn    , Nil } )
    Aadd( aCabec, { "C5_LOJAENT"  , cLjForn    , Nil } )
    Aadd( aCabec, { "C5_CONDPAG"  , aCampo[5,2], Nil } )
    Aadd( aCabec, { "C5_ENDERE"   , aCampo[1,2], Nil } )
    Aadd( aCabec, { "C5_EST"      , aCampo[2,2], Nil } )
    Aadd( aCabec, { "C5_BAIRRO"   , aCampo[3,2], Nil } )
    Aadd( aCabec, { "C5_CIDADE"   , aCampo[4,2], Nil } )
    Aadd( aCabec, { "C5_DTENTR"   , Date() + 7 , Nil } )
    Aadd( aCabec, { "C5_EMISSAO"  , Date()     , Nil } )
    Aadd( aCabec, { "C5_TPFRETE"  , cTpFrt     , .F. } )
    Aadd( aCabec, { "C5_FRETE"    , 0          , .F. } )
    Aadd( aCabec, { "C5_PLACA"    , cPlaca     , .F. } )
    Aadd( aCabec, { "C5_TRANSP"   , cTransp    , .F. } )
    Aadd( aCabec, { "C5_UFPLACA"  , cUFPlaca   , .F. } )
    Aadd( aCabec, { "C5_PESOL"    , cPesoTot   , Nil } )
    Aadd( aCabec, { "C5_PESOTOT"  , cPesoTot   , Nil } )

    MSExecAuto( { |x, y, z, p| MATA410(x, y, z,,,,,,, p) }, aCabec, aItens, 3 )

    If lMsErroAuto
        cRegistros := MostraErro()
        RestArea(aArea)
        Return .F.

    Else
        cRegistros += SC5->C5_NUM + Chr(13) + Chr(10)

        //Posiciona no registro de pedido de transferência.
        If ! U_ADFAT582(cNum)
            cRegistros := "Pedido de transferência " + cNum + " não localizado"
            RestArea(aArea)
            Return .F.

        EndIf

        While ! ZHS->(Eof()) .And. ZHS->ZHS_FILIAL == FWxFilial("ZHS") .And. ZHS->ZHS_NUMERO == cNum

            RecLock("ZHS", .F.)
                ZHS->ZHS_NVPED  := SC5->C5_NUM
                ZHS->ZHS_STATUS := "3"
            ZHS->(MsUnlock())

            ZHS->(DbSkip())

        End        

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} getInfo
    Obtém informações de cliente e fornecedor.
    @type  Static Function
    @author Everson
    @since 10/06/2022
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
/*/{Protheus.doc} ADFAT582
    Posiciona no registro de pedido de transferência.
    @type  User Function
    @author Everson
    @since 10/06/2022
    @version 01
/*/
User Function ADFAT582(cPedTrf)

    DbSelectArea("ZHS")
    ZHS->(DbSetOrder(1))
    If ! ZHS->(DbSeek( FWxFilial("ZHS") + cPedTrf ))
        Return .F.
        
    EndIf

Return .T.
/*/{Protheus.doc} ADFAT58A
    Filtro da consulta padrão de lote ZI8ZHS.
    @type  User Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
User Function ADFAT58A()

    //Variáveis.
    Local lRet     := .F.
    Local oView    := FWViewActive()   
    Local oGrid    := Nil
    Local cProduto := ""
    Local oDlg, oLbx
    Local aCpos    := {}
    Local aRet     := {}
    Local cQuery   := ""
    Local cAlias   := GetNextAlias()

    Default cFiltro := ""

    oGrid := oView:GetModel("MD_GRID")
    cProduto := Alltrim(cValToChar(oGrid:GetValue("ZHS_PRDSAG")))

    cQuery := " SELECT ZI8_CDLOTE, ZI8_DESLOT, ZI8_PRDSAG, ZI8_PRDPRT FROM " + RetSqlName("ZI8") + " (NOLOCK) AS ZI8 WHERE ZI8_FILIAL = '" + FWxFilial("ZI8") + "' AND ZI8_PRDSAG = '" + cProduto + "' AND ZI8_STATUS IN ('1','2') AND ZI8_LAUTO = '2' AND ZI8_LTCUST > 0 AND ZI8.D_E_L_E_T_ = '' ORDER BY ZI8_CDLOTE "

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

    While (cAlias)->(!Eof())

        Aadd(aCpos,{(cAlias)->(ZI8_CDLOTE), (cAlias)->(ZI8_DESLOT), (cAlias)->(ZI8_PRDSAG), (cAlias)->(ZI8_PRDPRT) })

        (cAlias)->(DbSkip())

    End
    (cAlias)->(DbCloseArea())

    If Len(aCpos) < 1
        Aadd(aCpos,{" "," "," ", " "})

    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Lotes - " + cProduto FROM 0,0 TO 240,500 PIXEL

        @ 10,10 LISTBOX oLbx FIELDS HEADER 'Código', 'Descrição', 'Prd Externo', 'Prd Protheus' SIZE 230,95 OF oDlg PIXEL

        oLbx:SetArray( aCpos )
        oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4] }}
        oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4] }}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4] })  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[1])
            lRet := .F.

        Else
            ZI8->(DbSetOrder(1))
            ZI8->(DbSeek( FWxFilial("ZI8")+aRet[1]) )

        EndIf

    EndIf

Return lRet   
/*/{Protheus.doc} ADFAT58B
    Validação de roteiro.
    @type  User Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
User Function ADFAT58B(cRotPesa)

    //Variáveis.
    Local aArea := GetArea()

    If ! U_ADFAT15B(cRotPesa)
        Help(Nil, Nil, "Função ADFAT58B(ADFAT058P)", Nil, "Roteiro " + cValToChar(cRotPesa) + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI9_TPMOVI <> "S"
        Help(Nil, Nil, "Função ADFAT58B(ADFAT058P)", Nil, "Roteiro " + cValToChar(cRotPesa) + " não é de saída.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI9_ATIVO <> "1"
        Help(Nil, Nil, "Função ADFAT58B(ADFAT058P)", Nil, "Roteiro " + cValToChar(cRotPesa) + " não está ativo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT58C
    Validação de produto.
    @type  User Function
    @author Everson
    @since 10/02/2022
    @version 01
/*/
User Function ADFAT58C(cProduto)

    //Variáveis.
    Local aArea   := GetArea()
    Local oView   := FWViewActive()  
    Local oModel  := oView:GetModel("MD_MASTER")
    Local cRotPes := Alltrim(cValToChar(oModel:GetValue("ZHS_CODROT"))) 

    //Posiciona no item do cadastro de pesagem.
    DbSelectArea("ZIA")
    ZIA->(DbSetOrder(2))
    ZIA->(DbGoTop())
    If ! ZIA->( DbSeek( FWxFilial("ZIA") + cRotPes + cProduto))
        Help(Nil, Nil, "Função ADFAT58C(ADFAT058P)", Nil, "Item do roteiro de pesagem " +  cRotPes + " " + cProduto + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf 

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT582
    Posiciona no registro de pedido de transferência pelo pedido de venda + item.
    @type  User Function
    @author Everson
    @since 22/06/2022
    @version 01
/*/
User Function ADFAT583(cPedido, cItem)

    DbSelectArea("ZHS")
    ZHS->(DbSetOrder(3))
    If ! ZHS->(DbSeek( FWxFilial("ZHS") + cPedido + cItem ))
        Return .F.
        
    EndIf

Return .T.
