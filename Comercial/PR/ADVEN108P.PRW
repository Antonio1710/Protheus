#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast := "ZHT"
Static cTitulo  := "Cliente x Produto Foco"
Static cTiMast  := "Dados do cliente x produto foco"

/*/{Protheus.doc} User Function ADVEN108P
    Exame laboratorial
    @type  Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVEN108P() // U_ADVEN108P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADVEN108P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    // oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADVEN108P" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADVEN108P" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADVEN108P" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADVEN108P" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.ADVEN108P" OPERATION 8 ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := {|oModel| vldPos(oModel)}
 
    oModel := MPFormModel():New("ADVN108", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHT_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZHT_CLIENT", "ZHT_CLIENT"},;
            {"ZHT_LOJA"  , "ZHT_LOJA"},;
            {"ZHT_NOME"  , "ZHT_NOME"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetUniqueLine({"ZHT_PRODUT"})

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cCliente   := oModel:GetValue("MD_MASTER", "ZHT_CLIENT")
    Local cLoja      := oModel:GetValue("MD_MASTER", "ZHT_LOJA")
    Local cNome      := oModel:GetValue("MD_MASTER", "ZHT_NOME")

    If lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) 

        If lRet .And. ( Empty(cCliente) .Or. Empty(cNome) .Or. Empty(cLoja) )
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADVEN108P)",,"Necessário informar o cliente.", 1, 0 )

        EndIf

        If lRet
            DbSelectArea("SA1")
            SA1->(DbSetOrder(1))
            If ! SA1->( DbSeek( FWxFilial("SA1") + cCliente + cLoja ) )
                lRet := .F.
                Help(Nil, Nil, "Função vldPos(ADVEN108P)",,"Cliente " + cCliente + cLoja + " não localizado(SA1).", 1, 0 )

            EndIf

        EndIf

    EndIf

    RestArea(aArea)
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel("ADVEN108P")
    Local cCampos   := getCmps()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID",,{|| gridFocus(oView) })
 
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)
 
    oView:AddIncrementField("VW_GRID", "ZHT_ITEM")

    oView:AddUserButton("Carregar Produtos","",{|oView| carProd() } ,"",, {MODEL_OPERATION_INSERT} , .T. )  

    oView:SetViewProperty( "VW_GRID" , "ENABLENEWGRID" ) 
    // oView:SetViewProperty( "VW_GRID", "GRIDNOORDER")
    oView:SetViewProperty( "VW_GRID", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty( "VW_GRID", "GRIDSEEK", {.T.})

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cCodigo := oModel:GetValue("MD_MASTER","ZHT_CLIENT")
    Local cLoja   := oModel:GetValue("MD_MASTER","ZHT_LOJA")
    Local cNome   := oModel:GetValue("MD_MASTER","ZHT_NOME")
    Local nOperation := oModel:GetOperation()

    If Empty(cCodigo) .Or. Empty(cLoja) .Or. Empty(cNome)
        Help(Nil, Nil, "Função gridFocus(ADVEN108P)", Nil, "Necessário informar o cliente.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHT_CLIENT"):OCtrl:SetFocus()
    
    EndIf

    DbSelectArea("ZHT")
    ZHT->(DbSetOrder(1))
    ZHT->(DbGoTop())
    If nOperation == MODEL_OPERATION_INSERT .And. ZHT->(DbSeek( FWxFilial("ZHT") + cCodigo + cLoja ))
        Help(Nil, Nil, "Função gridFocus(ADVEN108P)", Nil, "Cliente já possui cadastro.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHT_CLIENT"):OCtrl:SetFocus()

    EndIF

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCmps
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
Static Function getCmps()
Return "ZHT_FILIAL;ZHT_CLIENT;ZHT_LOJA;ZHT_NOME;"
/*/{Protheus.doc} carProd
    Carrega produtos do cliente.
    @type  Static Function
    @author Everson
    @since 15/07/2022
    @version 01
/*/
Static Function carProd()

    //Variáveis.
    Local aArea     := GetArea()
    Local oView     := FWViewActive()
    Local oHeader   := oView:GetModel("MD_MASTER")
    Local oGrid     := oView:GetModel("MD_GRID")
    Local cQuery    := ""
    Local cCliente  := oHeader:GetValue("ZHT_CLIENT")
    Local cLoja     := oHeader:GetValue("ZHT_LOJA")
    Local cNome     := oHeader:GetValue("ZHT_NOME")

    If Empty(cCliente) .Or. Empty(cLoja) .Or. Empty(cNome)
        MsgInfo("Necessário escolher o cliente.", "Função carProd(ADVEN108P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! Pergunte("ADVEN1081", .T.)
        RestArea(aArea)
        Return Nil

    EndIf

    cQuery := ""
    cQuery += " SELECT " 
        cQuery += " DISTINCT D2_COD, B1_DESC " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
    cQuery += " INNER JOIN "
    cQuery += " " + RetSqlName("SB1") + " (NOLOCK) AS SB1 ON "
    cQuery += " D2_COD = B1_COD "
    cQuery += " WHERE " 
        cQuery += " D2_FILIAL = '" + FWxFilial("SD2") + "' " 
        cQuery += " AND B1_FILIAL = '" + FWxFilial("SB1") + "' " 
        cQuery += " AND D2_CLIENTE = '" + cCliente + "' " 
        cQuery += " AND D2_LOJA = '" + cLoja + "' " 
        cQuery += " AND D2_EMISSAO >= '" + DToS(MV_PAR01) + "' " 
        cQuery += " AND D2_EMISSAO <= '" + DToS(MV_PAR02) + "' " 
        cQuery += " AND SD2.D_E_L_E_T_ = '' " 
        cQuery += " AND SB1.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY D2_COD " 

    If Select("D_PROD") > 0
        D_PROD->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_PROD"
    DbSelectArea("D_PROD")

    U_ADVN1081()

    If ! D_PROD->(Eof())

        FWFldPut("ZHT_CLIENT", cCliente)
        FWFldPut("ZHT_LOJA", cLoja)
        FWFldPut("ZHT_NOME", cNome)

        oGrid:setValue("ZHT_FILIAL", FWxFilial("ZHT"))
        oGrid:setValue("ZHT_CLIENT", cCliente)
        oGrid:setValue("ZHT_LOJA"  , cLoja)
        oGrid:setValue("ZHT_NOME"  , cNome)
        oGrid:setValue("ZHT_PRODUT", Alltrim(cValToChar(D_PROD->D2_COD)))
        oGrid:setValue("ZHT_DESC"  , Alltrim(cValToChar(D_PROD->B1_DESC)))

        While ! D_PROD->(Eof())

            oGrid:addLine()

            oGrid:setValue("ZHT_FILIAL", FWxFilial("ZHT"))
            oGrid:setValue("ZHT_CLIENT", cCliente)
            oGrid:setValue("ZHT_LOJA"  , cLoja)
            oGrid:setValue("ZHT_NOME"  , cNome)
            oGrid:setValue("ZHT_PRODUT", Alltrim(cValToChar(D_PROD->D2_COD)))
            oGrid:setValue("ZHT_DESC"  , Alltrim(cValToChar(D_PROD->B1_DESC)))

            D_PROD->(DbSkip())

        End

    Else
        oGrid:addLine()

    EndIf

    D_PROD->(DbCloseArea())

    oGrid:goLine(1)

    oView:refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADEST732
    Apaga dados da grid.
    @type  User Function
    @author Everson
    @since 31/07/2022
    @version 01
/*/
User Function ADVN1081()

    //Variáveis.
    Local oView  := FWViewActive()
    Local oGrid  := Nil

    oGrid := oView:GetModel("MD_GRID")
    oGrid:ClearData()

    oView:refresh()

Return oGrid:length() == 1
