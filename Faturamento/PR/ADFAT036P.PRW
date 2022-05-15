#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIW"
Static cTitulo := "Cadastro de Silo"
Static cTiMast := "Dados do cadastro de silo"

/*/{Protheus.doc} User Function ADFAT036P
    Cadastro de Silo.
    Cad Silo
    Chamado 18465.
    @type  Function
    @author Everson
    @since 28/02/2022
    @version 01
    /*/
User Function ADFAT036P() // U_ADFAT036P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT036P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 28/02/2022
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
    @since 28/02/2022
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT036P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 28/02/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|oModel| vldPre(oModel)}
    Local bPost     := {|oModel| vldPos(oModel)}
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT36", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPre
    Pós validação.
    @type  Static Function
    @author Everson
    @since 28/02/2022
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
    @since 28/02/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local lRet       := .T.
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 28/02/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT036P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} User Function ADFAT20B
    Posiciona no registro do silo.
    @type  Function
    @author Everson
    @since 13/05/2022
    @version 01
    /*/
User Function ADFAT36A(cSilo)

    DbSelectArea("ZIW")
    ZIW->(DbSetOrder(1))
    If ! ZIW->( DbSeek( FWxFilial("ZIW") + cSilo) )
        Return .F.

    EndIf

Return .T.
