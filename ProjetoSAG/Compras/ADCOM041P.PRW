#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIE"
Static cTitulo := "Padrões de Produto para Compra de MP"
Static cTiMast := "Dados dos padrões de produto para compra de MP"

PUBLISH USER MODEL REST NAME padroesdeprodutoparacomprademp  

/*/{Protheus.doc} User Function ADCOM041P
    Padrões de Produto para Compra.
    Cad Padr Prod Compra
    Chamado 18465.
    @type  Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
User Function ADCOM041P() // U_ADCOM041P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADCOM041P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
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
    @since 07/12/2021
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADCOM041P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ "ZIE_FILIAL;ZIE_NUMERO;ZIE_CODPRD;ZIE_DESPRD;"})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADFAT41", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIE_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIE_NUMERO", "ZIE_NUMERO"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetMaxLine(9999)
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({"ZIE_FILIAL","ZIE_NUMERO"})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel('ADCOM041P')
    Local cCampos   := "ZIE_FILIAL;ZIE_NUMERO;ZIE_CODPRD;ZIE_DESPRD;"
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

// Static Function fValidGrid(oModel)

//     //Variáveis.
//     Local lRet     := .T.
//     Local nDeletados := 0
//     Local nLinAtual :=0
//     Local oModelGRID := oModel:GetModel("MD_GRID")
//     Local oModelMain := oModel:GetModel("MD_MASTER")
//     Local nValorMain := oModelMain:GetValue("ZAF_VALOR")
//     Local nValorGrid := 0
//     Local cPictVlr   := PesqPict('ZAF', 'ZAF_VALOR')
 
//     //Percorrendo todos os itens da grid
//     For nLinAtual := 1 To oModelGRID:Length() 
//         //Posiciona na linha
//         oModelGRID:GoLine(nLinAtual) 
         
//         //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
//         If oModelGRID:IsDeleted()
//             nDeletados++
//         Else
//             nValorGrid += NoRound(oModelGRID:GetValue("ZAF_TCOMB"), 4)
//         EndIf
//     Next nLinAtual
 
//     //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
//     If oModelGRID:Length()==nDeletados
//         lRet :=.F.
//         Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
//     EndIf
 
//     If lRet
    
//         If nValorMain != nValorGrid
//             //lRet := .F.
//             MsgAlert("O valor do cabeçalho (" + Alltrim(Transform(nValorMain, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Atenção")
        
//         EndIf

//     EndIf
 
// Return lRet
