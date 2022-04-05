#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZII"
Static cTitulo := "Análise laboratorial"
Static cTiMast := "Dados da análise laboratorial"

/*/{Protheus.doc} User Function ADQUA004P
    Análise laboratorial
    Cad Análise laboratorial
    Chamado 18465.
    @type  Function
    @author Everson
    @since 30/12/2021
    @version 01
/*/
User Function ADQUA004P() // U_ADQUA004P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADQUA004P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 30/12/2021
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
    @since 30/12/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADQUA004P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 30/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ "ZII_FILIAL;ZII_NUMERO;ZII_ORDEM;"})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADQUA4", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZII_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZII_NUMERO", "ZII_NUMERO"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetMaxLine(9999)
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({"ZII_FILIAL","ZII_NUMERO"})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 30/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel('ADQUA004P')
    Local cCampos   := "ZII_FILIAL;ZII_NUMERO;ZII_ORDEM;"
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
 
    oView:AddIncrementField("VW_GRID", "ZIE_ITEM")

Return oView
