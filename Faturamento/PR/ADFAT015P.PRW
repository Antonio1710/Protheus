#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static xPula   := Chr(13) + Chr(10)
Static cTbMast := "ZI9"
Static cTbDeta := "ZIA"
Static cTbDet2 := "ZIU"
Static cTitulo := "Cadastro de Roteiro de Pesagem"
Static cTiMast := "Dados do Roteiro"
Static cTiDeta := "Dados dos Produtos Pesados no Roteiro"
Static cTiDet2 := "Exceções de TES do Roteiro"

/*/{Protheus.doc} User Function ADFAT015P
    Cadastro de Fluxo de Roteiro de Pesagem.
    Cad Roteiro de Pesagem
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/11/2021
    @version 01
    /*/
User Function ADFAT015P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT015P")

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

    oBrowse:SetMenuDef("ADFAT015P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADFAT015P" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADFAT015P" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADFAT015P" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADFAT015P" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.ADFAT015P" OPERATION 8 ACCESS 0

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
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT15", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)
    Local oStrDeta  := FwFormStruct(1, cTbDeta)
    Local oStrDet2  := FwFormStruct(1, cTbDet2)
    Local bDetPre   :=  { |oModelGrid, nLine, cAction, cField| vldLInha(oModelGrid, nLine, cAction, cField) }                                                  
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    //AddGrid(<cId >, <cOwner >, <oModelStruct >, <bDetPre >, <bLinePost >, <bPre >, <bLinePost >, <bLoad >)
    oModel:AddGrid("MD_DETAIL", "MD_MASTER", oStrDeta, , , , bDetPre)

    //AddGrid(<cId >, <cOwner >, <oModelStruct >, <bDetPre >, <bLinePost >, <bPre >, <bLinePost >, <bLoad >)
    oModel:AddGrid("MD_DETAI2", "MD_DETAIL", oStrDet2, , , ,)

    oModel:SetRelation("MD_DETAIL", {{"ZIA_FILIAL", "ZI9_FILIAL"}, {"ZIA_CODROT", "ZI9_CODROT"}}, (cTbDeta)->(IndexKey(1)))
    oModel:SetRelation("MD_DETAI2", {{"ZIU_FILIAL", "ZI9_FILIAL"}, {"ZIU_CODROT", "ZI9_CODROT"}}, (cTbDet2)->(IndexKey(3)))

    oModel:GetModel("MD_DETAIL"):SetUniqueLine({"ZIA_FILIAL","ZIA_CODROT", "ZIA_PRDPRT"}) 
    oModel:GetModel("MD_DETAI2"):SetUniqueLine({"ZIU_FILIAL","ZIU_CODROT", "ZIU_CLIFOR", "ZIU_CODIGO", "ZIU_LOJA"}) 
    oModel:SetPrimaryKey({})

    oModel:GetModel("MD_DETAIL"):SetOptional(.T.)
    oModel:GetModel("MD_DETAI2"):SetOptional(.T.)

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)
    oModel:GetModel("MD_DETAIL"):SetDescription(cTiDeta)
    oModel:GetModel("MD_DETAI2"):SetDescription(cTiDet2)

Return oModel
/*/{Protheus.doc} vldPos
    @type  Static Function
    @author Everson
    @since 19/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cCodRot    := oModel:GetValue("MD_MASTER", "ZI9_CODROT")

    If lRet .And. nOperation == MODEL_OPERATION_DELETE

        If lRet .And. ExistCpo("ZIB", cCodRot, 2)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT015P)", Nil, "Há registro de controle de pátio vinculado ao roteiro de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} vldLInha
    Função valida linha.
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function vldLInha(oModelGrid, nLine, cAction, cField)

    //Variáveis.
    Local lRet    := .T.

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
    Local oModel    := FwLoadModel("ADFAT015P")
    Local oStrMast  := FwFormStruct(2, cTbMast)
    Local oStrDeta  := FwFormStruct(2, cTbDeta)
    Local oStrDet2  := FwFormStruct(2, cTbDet2)

    oStrDet2:RemoveField("ZIU_CODROT")

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER",oStrMast, "MD_MASTER")

    oView:AddGrid("VW_DETAIL", oStrDeta, "MD_DETAIL")
    oView:AddGrid("VW_DETAI2", oStrDet2, "MD_DETAI2")

    oView:CreateHorizontalBox("BOX_SUPERIOR", 30)
    oView:CreateHorizontalBox("BOX_MEIO", 50)
    oView:CreateHorizontalBox("BOX_INFERIOR", 20)

    oView:SetOwnerView("VW_MASTER", "BOX_SUPERIOR")
    oView:SetOwnerView("VW_DETAIL", "BOX_MEIO")
    oView:SetOwnerView("VW_DETAI2", "BOX_INFERIOR")

    oView:AddIncrementField("VW_DETAIL", "ZIA_ITEMRT")
    oView:AddIncrementField("VW_DETAI2", "ZIU_ITEMRT")

    oView:EnableTitleView("MD_MASTER", cTiMast)
    oView:EnableTitleView("MD_DETAIL", cTiDeta)
    oView:EnableTitleView("MD_DETAI2", cTiDet2)

    oView:SetViewProperty( "VW_DETAIL" , "ENABLENEWGRID" ) 
    oView:SetViewProperty( "VW_DETAIL", "GRIDNOORDER")
    oView:SetViewProperty( "VW_DETAIL", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty( "VW_DETAIL", "GRIDSEEK", {.T.})

Return oView
/*/{Protheus.doc} ADFAT15A
    @type  Static Function
    @author Everson
    @since 21/03/2022
    @version 01
/*/
User Function ADFAT15A(cOper, cRotPesa, cProduto, nToleran, cUNTole, envBar, cMsgError)

    //Variáveis.
    Local aArea         := GetArea()
    Local lRet          := .F.
    Local oModel        := Nil
    Local oGrid         := Nil
    Local nPrxSeq       := "001"
    Local lAchou        := .F.

    Default nToleran    := 0
    Default cUNTole     := "PC"
    Default envBar      := "2"
    Default cMsgError   := ""

    If Empty(envBar)
        envBar := "2"
        
    EndIf

    If ! U_ADFAT15B(cRotPesa)
        cMsgError := "ADFAT15A-Roteiro " + cRotPesa + " não localizado(tabela ZI9)."
        Help(Nil, Nil, "Função ADFAT15A(ADFAT015P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADFAT015P")
    oGrid := oModel:GetModel("MD_DETAIL")

    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate() 

    If oGrid:Length() > 0
        oGrid:GoLine(oGrid:Length())
        nPrxSeq := Soma1(oGrid:GetValue("ZIA_ITEMRT"))

    EndIf

    lAchou := oGrid:SeekLine( { {"ZIA_FILIAL",FWxFilial("ZIA")}, {"ZIA_CODROT", cRotPesa}, {"ZIA_PRDPRT", cProduto} }, .F./*lDeleted*/, .T. /*lLocate*/ )
        
    If cOper == "D"

        If ! lAchou            
            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil
            RestArea(aArea)
            Return .T.

        Else
            oGrid:DeleteLine()

        EndIf

    Else
    
        If ! lAchou 
            oGrid:addLine()
            oGrid:SetValue("ZIA_ITEMRT",  nPrxSeq)
            oGrid:SetValue("ZIA_PRDPRT",  cProduto)

        EndIf

        oGrid:SetValue("ZIA_QTTOLE",  nToleran)
        oGrid:SetValue("ZIA_UNTOLE",  cUNTole)
        oGrid:SetValue("ZIA_MVESTO",  envBar)

    EndIf

    If oModel:VldData()
        oModel:CommitData()
        lRet := .T.

    Else
        aError := oModel:GetErrorMessage()
        cMsgError := "ADFAT15A-" + Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT15A(ADFAT015P)", Nil, "Erro na atualização de registro de roteiro de pesagem." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT15B
    Posiciona no registro de roteiro de pesagem.
    @type  User Function
    @author Everson
    @since 31/03/2022
    @version 01
/*/
User Function ADFAT15B(cRotPesa)

    DbSelectArea("ZI9")
    ZI9->(DbSetOrder(1))
    If ! ZI9->(DbSeek( FWxFilial("ZI9") + cRotPesa ))
        Return .F.

    EndIf

Return .T.
