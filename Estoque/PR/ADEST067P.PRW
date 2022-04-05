#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZIL"
Static cTitulo := "Conferência de Produtos Ensacados"
Static cTiMast := "Dados da conferência de produtos ensacados"
Static xPula   := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADEST067P
    Conferência de Produtos Ensacados
    Cad Conf Prd Ensacados
    Chamado 18465.
    @type  Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
User Function ADEST067P() // U_ADEST067P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADEST067P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADEST067P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADEST067P" 	OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADEST674(4)" 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "U_ADEST674(5)" 	    OPERATION MODEL_OPERATION_DELETE   ACCESS 0

Return aRotina
/*/{Protheus.doc} ADEST674
    Validação para alteração e exclusão de registro.
    @type  User Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
User Function ADEST674(nOpc)

    //Variáveis.
    Local aArea     := GetArea()

    If ZIL->ZIL_PESADO == "1"
        MsgInfo("Ordem com peso final. Operação não permitida.","Função ADEST674(ADEST067P)")
        RestArea(aArea)
        Return Nil

    EndIf

    FWExecView("", "ADEST067P", nOpc)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ "ZIL_FILIAL;ZIL_PLACA;ZIL_ORDEM;ZIL_CTPATI;ZIL_TPENSA;ZIL_PESADO;ZIL_SEQUEN;"})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := Nil

    bPost := {|oModel| vldPos(oModel)}

    oModel := MPFormModel():New("ADEST67", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
    
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,,,,)
    oModel:GetModel("MD_GRID"):SetNoDeleteLine(.T.)
    oModel:GetModel("MD_GRID"):SetNoInsertLine(.T.)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIL_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIL_ORDEM", "ZIL_ORDEM"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID")
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cCP        := oModel:GetValue("MD_MASTER", "ZIL_CTPATI")
    Local cNmOrdem   := oModel:GetValue("MD_MASTER", "ZIL_ORDEM")
    Local cPlaca     := oModel:GetValue("MD_MASTER", "ZIL_PLACA")
    Local cPesado    := oModel:GetValue("MD_MASTER", "ZIL_PESADO")
    Local cSeqAtu    := oModel:GetValue("MD_MASTER", "ZIL_SEQUEN")
    Local nPesoLiq   := 0
    Local nPLiqT     := 0
    Local cPrdPro    := ""
    Local cPrdSag    := ""
    Local cProduto   := ""
    Local aDdSeq     := {}
    Local cEntSai    := ""
    Local oGrid      := oModel:GetModel("MD_GRID")
    Local nLength    := oGrid:length()
    Local nAux       := 1
    Local nQtdOrd    := 0
    Local cQtdOrd    := ""

    If lRet .And. cPesado == "2" .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
        
        If lRet .And. Empty(cSeqAtu) .And. nOperation == MODEL_OPERATION_INSERT

            cSeqAtu := getSeqP(cCP, cNmOrdem)

            lRet := U_ADFAT192(cCP, cNmOrdem, cSeqAtu)
            
            If lRet
                oModel:SetValue("MD_MASTER","ZIL_SEQUEN", cSeqAtu)

            EndIf

        EndIf

        If lRet

            For nAux := 1 To nLength
                
                oGrid:GoLine(nAux)

                nPesoLiq    := oGrid:GetValue("ZIL_PESLIQ", nAux)
                nPLiqT      += nPesoLiq
                cPrdPro     := oGrid:GetValue("ZIL_PRDPRO", nAux) 
                cPrdSag     := oGrid:GetValue("ZIL_PRDSAG", nAux) 
                cProduto    +=  Alltrim(cValToChar(cPrdPro)) + Space(1) + Alltrim(cValToChar(U_ADFAT176(cPrdSag,""))) + Space(1)

                If nLength > 1
                    nQtdOrd  := Posicione("ZIF", 6, FWxFilial("ZIF") + cNmOrdem + cPrdPro,"ZIF_QUANT")
                    cQtdOrd  := Alltrim(cValToChar(Transform(nQtdOrd, "999,999,999.999")))
                    cProduto += "Qtd.: " + Alltrim(cValToChar(Transform(nPesoLiq, "999,999,999.999"))) + " Ordem:" + cQtdOrd + " Dif: " + Alltrim(cValToChar(Transform(nPesoLiq - nQtdOrd, "999,999,999.999"))) + xPula

                EndIf

            Next nAux
            
            lRet := vldPeso(cNmOrdem, nPLiqT, @aDdSeq, @cEntSai)

            If ! lRet
                lRet := U_ADEST673(aDdSeq, cEntSai, nPLiqT, cNmOrdem, cPlaca, cProduto)

            EndIf

        EndIf

    EndIf

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
        
        lRet := U_ADEST683(cNmOrdem, cMsgError)

    EndIf
    
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} getSeqP
    Obtém sequência de pesagem. 
    de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function getSeqP(cCP, cNmOrdem)

    //Variáveis.
    Local cSeq  := ""
    Local cQuery:= " SELECT ISNULL(MAX(ZIL_SEQUEN),0)+1 AS ZIL_SEQUEN FROM " + RetSqlName("ZIL") + " (NOLOCK) AS ZIL WHERE ZIL_FILIAL = '" + FWxFilial("ZIL") + "' AND ZIL_CTPATI = '" + cCP + "' AND ZIL_ORDEM <> '" + cNmOrdem + "' AND D_E_L_E_T_ = '' "

    If Select("D_SEQ") > 0
        D_SEQ->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_SEQ"
    DbSelectArea("D_SEQ")
        cSeq := cValToChar(D_SEQ->ZIL_SEQUEN)
    D_SEQ->(DbCloseArea())

Return cSeq
/*/{Protheus.doc} vldPeso
    Valida peso informado na conferência 
    de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
Static Function vldPeso(cNmOrdem, nPesoLiq, aDdSeq, cEntSai)

    //Variáveis.
    Local aArea     := GetArea()
    Local nZIFIndex := 2
    // Local cRoteiro  := ""
    // Local cProdSAG  := ""
    Local lRet      := .F.
    Local lLib      := .F.

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())
    If ! ZIG->( DbSeek( FWxFilial("ZIG") + cNmOrdem ) )
        Help(,,"Função vldPeso(ADEST067P)",,"Ordem de pesagem " + cNmOrdem + " não localizada.", 1, 0 )
        RestArea(aArea)
        Return .F.
        
    EndIf

    If ZIG->ZIG_AGRUPA == "1"
        nZIFIndex := 3

    EndIf

    // DbSelectArea("ZIF")
    // ZIF->(DbSetOrder(nZIFIndex))
    // ZIF->(DbGoTop())
    // If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
    //     Help(,,"Função vldPeso(ADEST067P)",,"Ordem de pesagem " + cNmOrdem + " não localizada.", 1, 0 )
    //     RestArea(aArea)
    //     Return .F.
        
    // EndIf

    // cRoteiro := Posicione("ZIB", 1, FWxFilial("ZIB") + ZIF->ZIF_CTPATI, "ZIB_CODROT")
    // cProdSAG := ZIF->ZIF_PRDSAG   
    // cEntSai  := ZIF->ZIF_TPMOVI

    //U_ADFAT177(cRoteiro, ZIF->ZIF_CTPATI, cProdSAG, ZIG->ZIG_PESORD, nPesoLiq, @aDdSeq)

    lLib := ZIG->ZIG_PESORD == nPesoLiq

    Aadd(aDdSeq, { lLib, "R", "KG", 0, (nPesoLiq - ZIG->ZIG_PESORD), Iif(ZIG->ZIG_PESORD <= 0, 0, ((nPesoLiq - ZIG->ZIG_PESORD)/ZIG->ZIG_PESORD)) * 100, "", ZIG->ZIG_PESORD })

    If Len(aDdSeq) > 0
        lRet := aDdSeq[1][1]

    Else
        Help(,,"Função vldPeso(ADEST067P)",,"Não foi possível validar a quebra de peso.", 1, 0)

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oModel    := FWLoadModel("ADEST067P")
    Local oView     := Nil
    Local cCampos   := "ZIL_FILIAL;ZIL_PLACA;ZIL_ORDEM;ZIL_CTPATI;ZIL_TPENSA;ZIL_PESADO;ZIL_SEQUEN;"
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID")
 
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)

    oView:AddUserButton("Carregar Ordens","",{|oView| U_ADEST671(oView) } ,"",, {MODEL_OPERATION_INSERT} , .T. )   
 
    oView:AddIncrementField("VW_GRID", "ZIL_ITEM")

Return oView
/*/{Protheus.doc} ADEST671
    Consulta padrão customizada.
    @type  User Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
User Function ADEST671(oView)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModal    := Nil
    Local aButtons  := {}
    Local oContainer:= Nil
    Local oOrdens   := Nil
    Local aOrdens   := {}
    Local oCabec    := oView:GetModel("MD_MASTER")
    Local cPlaca    := Alltrim(cValToChar(oCabec:GetValue("ZIL_PLACA")))

    If Empty(cPlaca)
        Help(,,"Função ADEST671(ADEST067P)",,"Informe a placa do veículo.", 1, 0 )
        RestArea(aArea)
        Return Nil

    EndIf

    carOrdEn(@aOrdens, cPlaca)

    If Len(aOrdens) <= 0
        Help(,,"Função ADEST671(ADEST067P)",,"Não há ordens de pesagem de ensacados para o veículo " + cPlaca + ".", 1, 0 )
        RestArea(aArea)
        Return Nil

    EndIf

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Ordens de Carregamento - " + cPlaca)
	oModal:setSize(150, 350)
	oModal:createDialog()
	oModal:addCloseButton(Nil, "Fechar")
    Aadd(aButtons,{Nil,"Confimar",{|| Iif(! prcOrd(aOrdens, cPlaca), Nil, oModal:DeActivate()) },"","",.T.,.F.})
	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        oOrdens := FwBrowse():New()
        oOrdens:setOwner(oContainer)
        oOrdens:setDataArray()
        oOrdens:setArray(aOrdens)
        oOrdens:disableConfig()
        oOrdens:disableReport()
    
        oOrdens:AddMarkColumns({|| Iif(aOrdens[oOrdens:nAt,01], "LBOK", "LBNO")},;
                                {|| selecOrd(oOrdens, @aOrdens)},;
                                {|| /*selecTAgr(oOrdens, @aOrdens, @lMarker)*/ })
    
        oOrdens:addColumn({"Número"          , {||aOrdens[oOrdens:nAt,02]}, "C", "", 1, 015 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,02]",, .F., .T., , "ID02" })
        oOrdens:addColumn({"Ordem/Agrupador" , {||aOrdens[oOrdens:nAt,05]}, "C", "", 1, 015 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,05]",, .F., .T., , "ID05" })
        oOrdens:addColumn({"Tp Ordem"        , {||aOrdens[oOrdens:nAt,03]}, "C", "", 1, 010 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,03]",, .F., .T., , "ID03" })
        oOrdens:addColumn({"Produto"         , {||aOrdens[oOrdens:nAt,04]}, "C", "", 1, 060 , , .T. , , .F.,, "aOrdens[oOrdPes:nAt,04]",, .F., .T., , "ID04" })
       
        oOrdens:Activate()

	oModal:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} selecOrd
    Marca registro.
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function selecOrd(oBrowse, aArquivo)

    //Variáveis.
    Local nLinha    := oBrowse:nAt
    Local cNmOrdem  := aArquivo[nLinha,02]
    Local nAux      := 1

    For nAux := 1 To Len(aArquivo)

        If aArquivo[nAux,02] == cNmOrdem
            aArquivo[nAux,01] := .T.

        Else
            aArquivo[nAux,01] := .F.

        EndIf

    Next nAux

    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} carOrdEn
    Carrega dados das ordens de pesagem.
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function carOrdEn(aOrdens, cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cDescProd := ""
    Local cRotPesa  := ""

    cQuery += " SELECT  DISTINCT " 
        cQuery += " CASE WHEN ZIF_AGRUPA <> '' THEN ZIF_AGRUPA ELSE ZIF_NUMERO END AS ORDEM, " 
        cQuery += " CASE WHEN ZIF_TPMOVI = 'E' THEN 'Entrada' ELSE 'Saída' END AS ENT_SAI, " 
        cQuery += " ZIF_TPMOVI, " 
        cQuery += " ZIF_PRDPRO, " 
        cQuery += " ZIF_PRDSAG, " 
        cQuery += " ZIF_STATUS, " 
        cQuery += " ZIF_STATLA, " 
        cQuery += " ZIF_CTPATI, " 
        cQuery += " CASE WHEN ZIF_AGRUPA <> '' THEN 'Agrupador' ELSE 'Ordem' END AS AGR_ORD " 
    cQuery += " FROM  " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF  " 
    cQuery += " WHERE  " 
        cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "'  " 
        cQuery += " AND ZIF_PLACA = '" + cPlaca + "'  " 
        cQuery += " AND ZIF_TPMOVI IN ('E','S') " 
        cQuery += " AND ZIF_STATUS NOT IN ('E','S') " 
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ORDEM " 

    If Select("D_DORD") > 0
        D_DORD->(DbCloseArea())

    EndIf

    DbSelectArea("ZIB")
    ZIB->(DbSetOrder(1))
    ZIB->(DbGoTop())

    DbSelectArea("ZIL")
    ZIL->(DbSetOrder(3))
    ZIL->(DbGoTop())

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    TcQuery cQuery New Alias "D_DORD"
    DbSelectArea("D_DORD")
    While ! D_DORD->(Eof())

        If ZIB->( DbSeek( FWxFilial("ZIB") + D_DORD->ZIF_CTPATI ))
            If ZIB->ZIB_STATUS == "5" .Or. ZIB->ZIB_STATUS == "6"
                D_DORD->(Dbskip())
                Loop

            EndIf

        EndIf

        If ZIL->( DbSeek( FWxFilial("ZIL") + D_DORD->ORDEM ) )
            D_DORD->(Dbskip())
            Loop

        EndIf

        cRotPesa := Posicione("ZIB", 1, FWxFilial("ZIB") + D_DORD->ZIF_CTPATI, "ZIB_CODROT")

        If ! U_ADFAT15B(cRotPesa)
            D_DORD->(Dbskip())
            Loop

        EndIf

        If ZI9->ZI9_ENSACA <> "1"
            D_DORD->(Dbskip())
            Loop
            
        EndIf

        If ! ZIG->( DbSeek( FWxFilial("ZIG") + D_DORD->ORDEM ) )
            D_DORD->(Dbskip())
            Loop

        EndIf

        If ZIG->ZIG_INICIA <> "2"
            D_DORD->(Dbskip())
            Loop

        EndIf

        cDescProd := Alltrim(Posicione("ZIM",1, FWxFilial("ZIM") + D_DORD->ZIF_PRDSAG, "ZIM_DESSAG"))
        Aadd(aOrdens,{.F., D_DORD->ORDEM, D_DORD->ENT_SAI, cDescProd, D_DORD->AGR_ORD, D_DORD->ZIF_TPMOVI, D_DORD->ZIF_CTPATI, D_DORD->ZIF_PRDSAG, D_DORD->ZIF_PRDPRO})
        
        D_DORD->(Dbskip())

    End

    D_DORD->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} prcOrd
    Processa ordens selecionadas.
    @type  Static Function
    @author Everson
    @since 16/12/2021
    @version 01
/*/
Static Function prcOrd(aOrdens, cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local oView     := FWViewActive()
    Local oGrid     := oView:GetModel("MD_GRID")
    Local cNmOrdem  := ""
    Local cCP       := ""
    Local cEntSai   := ""
    Local cPrdPro   := ""
    Local cPrdSAG   := ""
    Local cDesProd  := ""

    oGrid:setNoInsertLine(.F.)
    oGrid:setNoDeleteLine(.F.)

    U_ADEST672() //Apaga grid.

    For nAux := 1 To Len(aOrdens)

        If ! aOrdens[nAux][1]
            Loop

        EndIf

        If Empty(cNmOrdem)
            cNmOrdem := aOrdens[nAux,2]
            cCP      := aOrdens[nAux,7]
            cEntSai  := aOrdens[nAux,6]
            FWFldPut("ZIL_ORDEM",cNmOrdem)
            FWFldPut("ZIL_CTPATI",cCP)
            FWFldPut("ZIL_TPENSA",cEntSai)
            FWFldPut("ZIL_PESADO","2")

        EndIf

        If nAux > 1
            oGrid:addLine()

        EndIf
        
        cPrdPro   := aOrdens[nAux,9]  
        cPrdSAG   := aOrdens[nAux,8]
        cDesProd  := aOrdens[nAux,4]

        oGrid:loadValue("ZIL_PLACA",  cPlaca)
        oGrid:loadValue("ZIL_ORDEM",  cNmOrdem)
        oGrid:loadValue("ZIL_CTPATI", cCP)
        oGrid:loadValue("ZIL_TPENSA", cEntSai)
        oGrid:loadValue("ZIL_PRDPRO", cPrdPro)
        oGrid:loadValue("ZIL_PRDSAG", cPrdSAG)
        oGrid:loadValue("ZIL_DESPRO", cDesProd)
        oGrid:loadValue("ZIL_PESADO", "2")

    Next nAux

    oGrid:setNoInsertLine(.T.)
    oGrid:setNoDeleteLine(.T.)

    oGrid:goLine(1)

    oView:refresh()

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADEST672
    Apaga dados da grid.
    @type  User Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
User Function ADEST672() // U_ADEST672()

    //Variáveis.
    Local oView  := FWViewActive()
    Local oGrid  := Nil

    oGrid := oView:GetModel("MD_GRID")
    oGrid:ClearData(.F.,.T.)

    oGrid:goLine(1)

    oView:refresh()

Return oGrid:length() == 1
/*/{Protheus.doc} ADEST673
    Interface de contrassenha.
    @type  User Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
User Function ADEST673(aDdSeq, cEntSai, nPesoLiq, cNmOrdem, cPlaca, cProduto)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModal    := Nil
    Local aButtons  := {}
    Local oContainer:= Nil
    Local cCodSol   := Alltrim(cValToChar(__cUserID))
    Local cSolic    := UsrFullName(__cUserID)
    Local cMotivo   := Space(100)
    Local nValor    := nPesoLiq
    Local nLimite   := aDdSeq[1][8]
    Local nDife     := aDdSeq[1][5]
    Local cNumLib   := ""
    Local cMsg      := ""

    oModal := FWDialogModal():New()        
	oModal:SetEscClose(.F.)
	oModal:setTitle("Autorização - Quebra fora da tolerância permitida")
	oModal:setSize(150, 275)
	oModal:createDialog()
	oModal:addCloseButton(Nil, "Cancelar")

    Aadd(aButtons,{Nil,"Solicitar",{|| solicLib("", cNmOrdem, nValor, nLimite, nDife, @cNumLib, cPlaca, cProduto, cMotivo) },"","",.T.,.F.})
    Aadd(aButtons,{Nil,"Confirmar",{|| Iif(! verifLib(@lRet, cNumLib), Nil, oModal:DeActivate()) },"","",.T.,.F.})

	oModal:addButtons(aButtons)

        oContainer := TPanel():New(025,,, oModal:getPanelMain())
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT
        TGet():New(010,010,{|u|If(PCount() == 0,cCodSol,cCodSol := u)}  ,oContainer,125,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cCodSol",,,,.T.,,,"Cod. Solicitante",1)
        TGet():New(010,140,{|u|If(PCount() == 0,cSolic,cSolic := u)}    ,oContainer,125,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cSolic",,,,.T.,,,"Solicitante",1) 

        TGet():New(040,010,{|u|If(PCount() == 0,cMotivo,cMotivo := u)}  ,oContainer,255,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| Empty(cNumLib) },.F.,.F.,,.F.,.F. ,,"cMotivo",,,,.T.,,,"Motivo",1)  
        
        TGet():New(070,010,{|u|If(PCount() == 0,cNumLib,cNumLib := u)}  ,oContainer,125,015,"",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNumLib",,,,.T.,,,"Solicitação",1)  

    oModal:Activate()
    
    cMsg := "A conferênca de ensacados não pôde ser salva, pois a quebra de peso necessita de aprovação."
    If ! Empty(cNumLib) 
    
        If excLib("", cNumLib)
            Help(Nil, Nil, "Função ADEST673(ADEST067P)", Nil, cMsg, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    ElseIf Empty(cNumLib)
        Help(Nil, Nil, "Função ADEST673(ADEST067P)", Nil, cMsg, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    
    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} solicLib
    Solicitação de aprovação de liberação de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
Static Function solicLib(cMsgError, cNmOrdem, nValor, nLimite, nDife, cNumLib, cPlaca, cProduto, cMotivo)

    //Variáveis.
    Local aArea := GetArea()
    Local oSolic:= Nil

    Default cMsgError := ""

    If ! Empty(cNumLib)
        MsgInfo("Já há a solicitação " + cNumLib + ".", "Função solicLib(ADEST067P)")
        RestArea(aArea)
        Return Nil  

    EndIf

    If Empty(cMotivo)
        MsgInfo("Necessário informar o motivo.", "Função solicLib(ADEST067P)")
        RestArea(aArea)
        Return Nil  

    EndIf

    DbSelectArea("ZID")
    ZID->(DbSetOrder(2))
    If ZID->(DbSeek( FWxFilial("ZID") + cNmOrdem ))
        If ZID->ZID_STATUS == "1"
            cNumLib := ZID->ZID_NUMERO
            //Help(Nil, Nil, "Função solicLib(ADEST067P)", Nil, "Já há a solicitação " + ZID->ZID_NUMERO + " para ordem " + cNmOrdem + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            RestArea(aArea)
            Return Nil

        EndIf

    EndIf

    oSolic := FwLoadModel("ADEST068P")

    oSolic:SetOperation(MODEL_OPERATION_INSERT)
    oSolic:Activate() 

    oSolic:SetValue("MD_MASTER","ZID_DATA"  ,Date())
    oSolic:SetValue("MD_MASTER","ZID_HORA"  ,Time())
    oSolic:SetValue("MD_MASTER","ZID_PLACA" ,cPlaca)
    oSolic:SetValue("MD_MASTER","ZID_ORDEM" ,cNmOrdem)
    oSolic:SetValue("MD_MASTER","ZID_MEMPRO",cProduto)
    oSolic:SetValue("MD_MASTER","ZID_VALOR" ,nValor)
    oSolic:SetValue("MD_MASTER","ZID_LIMITE",nLimite)
    oSolic:SetValue("MD_MASTER","ZID_DIFERE",nDife)
    oSolic:SetValue("MD_MASTER","ZID_MOTIVO",cMotivo)
    oSolic:SetValue("MD_MASTER","ZID_SOLIC" ,__cUserID)
    oSolic:SetValue("MD_MASTER","ZID_NMSOLI",cUserName)

    Begin Transaction

        If oSolic:VldData()
            oSolic:CommitData()

            cNumLib := ZID->ZID_NUMERO
            Help(Nil, Nil, "Função solicLib(ADEST067P)", Nil, "Solicitação gerada " + cNumLib + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        Else
            aError := oSolic:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oSolic:DeActivate()
    oSolic:Destroy()
    oSolic := Nil

    If ! Empty(cMsgError)
        MsgStop("Erro na geração de registro de solicitação de liberação." + xPula + cMsgError, "Função solicLib(ADEST067P)")

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} excLib
    Exclui a solicitação de aprovação de liberação de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
Static Function excLib(cMsgError, cNumLib)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oSolic:= Nil

    Default cMsgError := ""

    DbSelectArea("ZID")
    ZID->(DbSetOrder(1))
    If ! ZID->(DbSeek( FWxFilial("ZID") + cNumLib ))
        RestArea(aArea)
        Return .F.

    EndIf

    If ZID->ZID_STATUS <> "1"
        RestArea(aArea)
        Return .F.

    EndIf

    oSolic := FwLoadModel("ADEST068P")

    oSolic:SetOperation(MODEL_OPERATION_DELETE)
    oSolic:Activate() 

    Begin Transaction

        If oSolic:VldData()
            oSolic:CommitData()
            lRet := .T.

        Else
            aError := oSolic:GetErrorMessage()
            cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

        EndIf

    End Transaction

    oSolic:DeActivate()
    oSolic:Destroy()
    oSolic := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função excLib(ADEST067P)", Nil, "Erro na exclusão do registro de solicitação de liberação." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} verifLib
    Verifica a solicitação de aprovação de liberação de produtos ensacados.
    @type  Static Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
Static Function verifLib(lRet, cNumLib)

    //Variáveis.
    Local aArea := GetArea()

    lRet := .F.

    If Empty(cNumLib)
        MsgInfo("Necessário gerar a solicitação de liberação.","Função verifLib(ADEST067P)")
        RestArea(aArea)
        Return .F.

    EndIF

    DbSelectArea("ZID")
    ZID->(DbSetOrder(1))
    If  ! ZID->(DbSeek( FWxFilial("ZID") + cNumLib ))
        MsgInfo("Solicitação de liberação " + cNumLib + " não localizada.","Função verifLib(ADEST067P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ZID->ZID_STATUS == "1"
        MsgInfo("Solicitação de liberação " + cNumLib + " não passou pelo processo de aprovação.","Função verifLib(ADEST067P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If ZID->ZID_STATUS == "2"
        lRet := .T.
        MsgInfo("Solicitação de liberação " + cNumLib + " aprovada.","Função verifLib(ADEST067P)")
        RestArea(aArea)
        Return .T.

    EndIf

    If ZID->ZID_STATUS == "3"
        lRet := .F.
        MsgInfo("Solicitação de liberação " + cNumLib + " reprovada.","Função verifLib(ADEST067P)")
        RestArea(aArea)
        Return .T.

    EndIf

    RestArea(aArea)

Return .F.
/*/{Protheus.doc} ADEST675
    Atualiza.
    @type  User Function
    @author Everson
    @since 13/12/2021
    @version 01
/*/
User Function ADEST675(cNmOrdem, nIndex, cCampo, xValor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    
    Default cMsgError := ""
    
    DbSelectArea("ZIL")
    ZIL->(DbSetOrder(nIndex))
    If ! ZIL->(DbSeek( FWxFilial("ZIL") + cNmOrdem ))
        cMsgError := "Registro " + cNmOrdem + " não encontrado. Não há apontamento de ensacados."
        Help(Nil, Nil, "Função ADEST675(ADFAT017P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return lRet

    EndIf

    oModel := FwLoadModel("ADEST067P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    oModel:SetValue("MD_MASTER", cCampo, xValor)
    oModel:SetValue("MD_GRID", cCampo, xValor)

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
        Help(Nil, Nil, "Função ADEST675(ADFAT016P)", Nil, "Erro na atualização de registro de conferência de ensacado " + cNmOrdem + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet

