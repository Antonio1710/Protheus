#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIJ"
Static cTitulo := "Pedido adicional"
Static cTiMast := "Dados do pedido adicional"

/*/{Protheus.doc} User Function ADFAT042P
    Cadastro de caixas de veículo.
    Cad Caixas Veiculo
    Chamado 18465.
    @type  Function
    @author Everson
    @since 11/03/2022
    @version 01
    /*/
User Function ADFAT042P() // U_ADFAT042P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT042P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 11/03/2022
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
    @since 11/03/2022
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT042P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ "ZIJ_FILIAL;ZIJ_NUMERO;ZIJ_CONDIC;ZIJ_DESC;ZIJ_TPMOVI;"})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := Nil

    bPost := {|oModel| vldPos(oModel)}

    oModel := MPFormModel():New("ADFAT42", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
    
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,,,,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIJ_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIJ_NUMERO", "ZIJ_NUMERO"},;
            {"ZIJ_CONDIC", "ZIJ_CONDIC"},;
            {"ZIJ_TPMOVI", "ZIJ_TPMOVI"},;
            {"ZIJ_DESC"  , "ZIJ_DESC"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID")
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} vldPre
    Pós validação.
    @type  Static Function
    @author Everson
    @since 11/03/2022
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
    @since 11/03/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cCondicao  := oModel:GetValue("MD_MASTER", "ZIJ_CONDIC")
    Local cDesc      := oModel:GetValue("MD_MASTER", "ZIJ_DESC")
    Local cTpMov     := oModel:GetValue("MD_MASTER", "ZIJ_TPMOVI")

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        If Empty(cCondicao) .Or. Empty(cDesc) .Or. Empty(cTpMov)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT042P)", Nil, "Preencha os campos Tes Condição, Tipo de Ordem e Descrição.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    RestArea(aArea)
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oModel    := FWLoadModel("ADFAT042P")
    Local oView     := Nil
    Local cCampos   := "ZIJ_FILIAL;ZIJ_NUMERO;ZIJ_CONDIC;ZIJ_DESC;ZIJ_TPMOVI;"
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

    oView:AddIncrementField("VW_GRID", "ZIJ_ITEM")

Return oView
/*/{Protheus.doc} ADFAT42A
    Valida a condição selecionada.
    @type  User Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
User Function ADFAT42A(cCondição) // U_ADFAT42A(M->ZIJ_CONDIC)

    //Variáveis.
    Local lRet := ExistCpo("ZIJ", cCondição , 3)

Return ! lRet
