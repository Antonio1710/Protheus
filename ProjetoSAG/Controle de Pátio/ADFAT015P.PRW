#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZI9"
Static cTbDeta := "ZIA"
Static cTitulo := "Cadastro de Roteiro de Pesagem"
Static cTiMast := "Dados do Roteiro"
Static cTiDeta := "Dados dos Produtos"

PUBLISH USER MODEL REST NAME roteirosdepesagem

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
Return (FwMVCMenu("ADFAT015P"))
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
    Local aRelation := {} 
    Local bLinePre  :=  { |oModelGrid, nLine, cAction, cField| vldLInha(oModelGrid, nLine, cAction, cField) }                                                  
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    //AddGrid(<cId >, <cOwner >, <oModelStruct >, <bLinePre >, <bLinePost >, <bPre >, <bLinePost >, <bLoad >)
    oModel:AddGrid("MD_DETAIL", "MD_MASTER", oStrDeta, , , , bLinePre)

    Aadd(aRelation, {"ZIA_FILIAL", "ZI9_FILIAL"})
    Aadd(aRelation, {"ZIA_CODROT", "ZI9_CODROT"})

    oModel:SetRelation("MD_DETAIL", aRelation, (cTbDeta)->(IndexKey(1)))
    oModel:GetModel("MD_DETAIL"):SetUniqueLine({"ZIA_FILIAL","ZIA_CODROT","ZIA_PRDPRT"}) 
    oModel:SetPrimaryKey({})

    oModel:GetModel("MD_DETAIL"):SetOptional(.T.)

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)
    oModel:GetModel("MD_DETAIL"):SetDescription(cTiDeta)

Return oModel
/*/{Protheus.doc} vldPos
    Valida inclusão de registro.
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

        If ExistCpo("ZIB", cCodRot, 2)
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
    // Local oModel  := oModelGrid:GetModel()
    // Local nTole   := oModel:GetValue( "MD_DETAIL" , "ZIA_QTTOLE")
    // Local cUNTole := Alltrim(cValToChar(oModel:GetValue( "MD_DETAIL" , "ZIA_UNTOLE")))

    // If nTole > 0 .And. Empty(cUNTole)
    //     lRet := .F.
    //     Help(Nil, Nil, "Função vldLInha(ADFAT015P)", Nil, "Informe a unidade de medida da tolerância.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    // EndIf

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

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_DETAIL", oStrDeta, "MD_DETAIL")

    oView:CreateHorizontalBox("BOX_SUPERIOR", 30)
    oView:CreateHorizontalBox("BOX_INFERIOR", 70)

    oView:SetOwnerView("VW_MASTER", "BOX_SUPERIOR")
    oView:SetOwnerView("VW_DETAIL", "BOX_INFERIOR")

    oView:AddIncrementField("VW_DETAIL", "ZIA_ITEMRT")

    oView:EnableTitleView("MD_MASTER", cTiMast)
    oView:EnableTitleView("MD_DETAIL", cTiDeta)

Return oView
