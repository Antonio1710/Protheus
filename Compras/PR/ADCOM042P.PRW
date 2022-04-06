#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIO"
Static cTitulo := "Contrato de Compra de Matéria Prima"
Static cTiMast := "Dados do contrato de compra de matéria prima"

/*/{Protheus.doc} User Function ADCOM042P
    Contrato de Compra de Matéria Prima.
    Cad Contrato de Compra MP
    Chamado 18465.
    @type  Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
User Function ADCOM042P() // U_ADCOM042P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADCOM042P")

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
Return (FwMVCMenu("ADCOM042P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast)
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADFAT42", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIO_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIO_NUMERO", "ZIO_NUMERO"},;
            {"ZIO_VERSAO", "ZIO_VERSAO"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetMaxLine(9999)
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({"ZIO_FILIAL","ZIO_NUMERO","ZIO_VERSAO"})

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
    Local oModel    := FWLoadModel('ADCOM042P')
    Local cCampos   := "ZIO_FILIAL;ZIO_NUMERO;ZIO_VERSAO;ZIO_DESC;ZIO_TIPO;ZIO_STATUS;ZIO_DTINI;ZIO_DTFIM;ZIO_VLTOTA;ZIO_DTAPRO;ZIO_HRAPRO;ZIO_CODAPR;ZIO_NMAPRO;ZIO_OBAPRO"
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo)   $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID")
 
    oView:CreateHorizontalBox("MAIN", 50)
    oView:CreateHorizontalBox("GRID", 50)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)
 
    oView:AddIncrementField("VW_GRID", 'ZIO_ITEM')

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
