#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIM"
Static cTitulo := "Produto SAG x Produto Protheus"
Static cTiMast := "Dados Produto SAG x Produto Protheus"

PUBLISH USER MODEL REST NAME produtossagxprotheus

/*/{Protheus.doc} User Function ADFAT020P
    Cadastro de Produto SAG x Produto Protheus.
    Cad Prd SAG x Prd Protheus
    Chamado 18465.
    @type  Function
    @author Everson
    @since 25/11/2021
    @version 01
    /*/
User Function ADFAT020P() // U_ADFAT020P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT020P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT020P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT020P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT20", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 25/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    //Local cPrdSAG    := oModel:GetValue("MD_MASTER", "ZIM_PRDSAG")

    If lRet .And. nOperation == MODEL_OPERATION_DELETE
    
        // If ExistCpo("ZI8", cPrdSAG, 3)
        //     lRet := .F.
        //     Help(Nil, Nil, "Função vldPos(ADFAT020P)", Nil, "Há registro de lote vinculado ao produto.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        // EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 25/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT020P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
