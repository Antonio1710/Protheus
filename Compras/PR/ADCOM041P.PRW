#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZII"
Static cTitulo := "Padrões de Produto para Compra de MP"

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
    Local oBrowse := Nil
    
    oBrowse := FwLoadBrw("ADCOM041P")

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

    // oBrowse:AddLegend("ZII->ZII_PARAMF <> ''" , "BR_VERDE" , "Informado Padrão Fornecedor")
    // oBrowse:AddLegend("ZII->ZII_PARAMF = ''"  , "BR_AZUL"  , "Não Informado Padrão Fornecedor")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

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
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADCOM41", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,,)
    oModel:GetModel("MD_GRID"):SetNoInsertLine(.T.)
    oModel:GetModel("MD_GRID"):SetNoDeleteLine(.T.)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZII_FILIAL"  , 'FWxFilial("' + cTbMast + '")'},;
            {"ZII_NUMERO"  , "ZII_NUMERO"},;
            {"ZII_CONTRA"  , "ZII_CONTRA"},;
            {"ZII_VERSAO"  , "ZII_VERSAO"},;
            {"ZII_CTITEM"  , "ZII_CTITEM"},;
            {"ZII_FORNEC"  , "ZII_FORNEC"},;
            {"ZII_LOJA"    , "ZII_LOJA"},;
            {"ZII_NOME"    , "ZII_NOME"},;
            {"ZII_PRDPRO"  , "ZII_PRDPRO"},;
            {"ZII_PRDSAG"  , "ZII_PRDSAG"},;
            {"ZII_DESC"    , "ZII_DESC"};
        }, (cTbMast)->(IndexKey(2)))

    oModel:SetPrimaryKey({})

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
    Local cCampos   := getCmps()
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo)   $ cCampos})
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
 
    oView:AddIncrementField("VW_GRID", "ZII_ITEM")

    oView:SetViewProperty( "VW_GRID" , "ENABLENEWGRID" ) 
    // oView:SetViewProperty( "VW_GRID", "GRIDNOORDER")
    oView:SetViewProperty( "VW_GRID", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty( "VW_GRID", "GRIDSEEK", {.T.})

Return oView
/*/{Protheus.doc} getCmps
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
Static Function getCmps()
Return "ZII_FILIAL;ZII_NUMERO;ZII_CONTRATO,ZII_VERSAO;ZII_CTITEM;ZII_FORNEC;ZII_LOJA;ZII_NOME;ZII_PRDPRO;ZII_PRDSAG;ZII_DESC;"
/*/{Protheus.doc} User Function ADCOM411
    (long_description)
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM411(cContrato, cVersao, cItemCT, cFornece, cLoja, cNmFornec, cProduto)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .T.
    Local oModel    := Nil
    Local aError    := {}
    Local cQuery    := ""
    Local cItem     := "001"
    Local cNxtAlias := ""
    Local cParamA   := ""
    
    Default cMsgError := ""

    cQuery += " SELECT  " 
        cQuery += " DISTINCT ZHW_PRODUT, ZHW_DESC, ZHV_NUMERO, ZHV_NOME, ZHV_ITEM, "
        cQuery += " ZHV_CODITE, ZHV_DESCIT, ZHV_ANITEM, ZHU_TPDADO, ZHU_VLRTXT, ZHU_MINIMO, ZHU_MAXIMO " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZHW") + " (NOLOCK) AS ZHW " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZHV") + " (NOLOCK) AS ZHV ON " 
        cQuery += " ZHW_FILIAL = ZHV_FILIAL " 
        cQuery += " AND ZHW_CODEXA = ZHV_NUMERO " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZHU") + " (NOLOCK) AS ZHU ON  " 
        cQuery += " ZHV_FILIAL = ZHU_FILIAL " 
        cQuery += " AND ZHV_CODITE = ZHU_NUMERO " 
    cQuery += " WHERE " 
        cQuery += " ZHW_FILIAL = '" + FWxFilial("ZII") + "' " 
        cQuery += " AND ZHW_PRODUT = '" + cProduto + "' " 
        cQuery += " AND ZHU_RESULT = '2' " 
        cQuery += " AND ZHU_TPDADO = '2' " 
        cQuery += " AND ZHW.D_E_L_E_T_ = '' " 
        cQuery += " AND ZHV.D_E_L_E_T_ = '' " 
        cQuery += " AND ZHU.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZHV_NUMERO, ZHV_ITEM, ZHV_CODITE " 

    cNxtAlias := GetNextAlias()

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cNxtAlias, .F., .T.)

    (cNxtAlias)->(DbGoTop())   

    Begin Transaction

        While ! (cNxtAlias)->(Eof())

            cParamA := Transform(Val(cValToChar((cNxtAlias)->ZHU_MINIMO)), "@E 999,999.99") + " - " + Transform(Val(cValToChar((cNxtAlias)->ZHU_MAXIMO)), "@E 999,999.99")

            oModel := FwLoadModel("ADCOM041P")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()

            oModel:SetValue("MD_MASTER", "ZII_CONTRA", cContrato)
            oModel:SetValue("MD_MASTER", "ZII_VERSAO", cVersao)
            oModel:SetValue("MD_MASTER", "ZII_CTITEM", cItemCT)
            oModel:SetValue("MD_MASTER", "ZII_FORNEC", cFornece)
            oModel:SetValue("MD_MASTER", "ZII_LOJA"  , cLoja)
            oModel:SetValue("MD_MASTER", "ZII_NOME"  , cNmFornec)
            oModel:SetValue("MD_MASTER", "ZII_PRDPRO", (cNxtAlias)->ZHW_PRODUT)
            oModel:SetValue("MD_MASTER", "ZII_DESC"  , (cNxtAlias)->ZHW_DESC)

            oModel:SetValue("MD_GRID", "ZII_ITEM"  , cItem)
            oModel:SetValue("MD_GRID", "ZII_NUMEXA", (cNxtAlias)->ZHV_NUMERO)
            oModel:SetValue("MD_GRID", "ZII_NMEXAM", (cNxtAlias)->ZHV_NOME)
            oModel:SetValue("MD_GRID", "ZII_EXITEM", (cNxtAlias)->ZHV_ITEM)
            oModel:SetValue("MD_GRID", "ZII_NUMANA", (cNxtAlias)->ZHV_CODITE)
            oModel:SetValue("MD_GRID", "ZII_NMANAL", (cNxtAlias)->ZHV_DESCIT)
            oModel:SetValue("MD_GRID", "ZII_ITEANA", (cNxtAlias)->ZHV_ANITEM)
            oModel:SetValue("MD_GRID", "ZII_PARAMA", cParamA)

            If oModel:VldData()
                oModel:CommitData()

            Else
                lRet := .F.
                aError    := oModel:GetErrorMessage()
                cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))
                DisarmTransaction()
                Break

            EndIf

            cItem := Soma1(cItem)

            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

            cItem := Soma1(cItem)

            (cNxtAlias)->(DbSkip())

        End

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADCOM411(ADCOM041P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    (cNxtAlias)->(DbCloseArea())

    RestArea(aArea)
    
Return lRet
/*/{Protheus.doc} User Function ADCOM412
    Posiciona.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM412(cContrato, cVersao, cItemCT, cFornece, cLoja, cProduto)

    //Variáveis.
    Local lRet := .F.

    Default cContrato := ""
    Default cVersao   := ""  
    Default cItemCT   := ""
    Default cFornece  := ""
    Default cLoja     := ""
    Default cProduto  := ""

    DbSelectArea("ZII")
    ZII->(DbSetOrder(3))
    ZII->(DbGoTop())

    lRet := ZII->( DbSeek( FWxFilial("ZII") + cContrato + cVersao + cItemCT + cFornece + cLoja + cProduto ) )

Return lRet 
/*/{Protheus.doc} User Function ADCOM413
    Posiciona pelo contrato.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM413(cContrato, cVersao)

    //Variáveis.
    Local lRet := .F.

    Default cContrato := ""
    Default cVersao   := ""

    DbSelectArea("ZII")
    ZII->(DbSetOrder(1))
    ZII->(DbGoTop())

    lRet := ZII->( DbSeek( FWxFilial("ZII") + cContrato + cVersao ) )

Return lRet 
/*/{Protheus.doc} User Function ADCOM414
    Apaga os registros vinculados a um contrato.
    @type  Function
    @author Everson
    @since 04/08/2022
    @version 01
/*/
User Function ADCOM414(cContrato, cVersao)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil

    If ! U_ADCOM413(cContrato, cVersao)
        RestArea(aArea)
        Return .F. 

    EndIf

    Begin Transaction

        While ! ZII->(Eof()) .And. ZII->ZII_FILIAL == cContrato .And. ZII->ZII_VERSAO == cVersao

            oModel := FwLoadModel("ADCOM041P")
            oModel:SetOperation(MODEL_OPERATION_DELETE)
            oModel:Activate()

            If oModel:VldData()
                oModel:CommitData()

            Else
                aError := oModel:GetErrorMessage()
                cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))
                DisarmTransaction()
                Break

            EndIf

            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

            ZII->(DbSkip())

        End

    End Transaction

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADCOM414(ADCOM041P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADCOM415
    Valida se é necessário fazer carga de dados.
    @type  Function
    @author Everson
    @since 05/08/2022
    @version 01
/*/
User Function ADCOM415(cContrato, cVersao)
Return Type("lLoadEx") == "L" .And. lLoadEx
/*/{Protheus.doc} User Function ADCOM416
    Deleta registro.
    @type  Function
    @author Everson
    @since 05/08/2022
    @version 01
/*/
User Function ADCOM416(cContrato, cVersao, cItemCT, cMsgError)

    //Variáveis.
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local oModel := Nil
    Local aError := {}

    Default cMsgError := ""

    If !  U_ADCOM412(cContrato, cVersao, cItemCT)
        cMsgError := "Contrato/versão/item não localizado " + cContrato + cVersao + cItemCT
        RestArea(aArea)
        Return .F.

    EndIf

    oModel := FwLoadModel("ADCOM041P")
    oModel:SetOperation(MODEL_OPERATION_DELETE)
    oModel:Activate()

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

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADCOM417
    Deleta registros sem contratos vinculados.
    @type  Function
    @author Everson
    @since 05/08/2022
    @version 01
/*/
User Function ADCOM417()

    //Variáveis.
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cNxtAlias := ""

    cQuery += " SELECT  " 
        cQuery += " ZII_CONTRA, ZII_VERSAO, ZII_CTITEM " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZII") + " AS ZII " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " " + RetSqlName("ZIO") + " AS ZIO ON  " 
        cQuery += " ZII_FILIAL = ZIO_FILIAL " 
        cQuery += " AND ZII_CONTRA = ZIO_NUMERO " 
        cQuery += " AND ZII_VERSAO = ZIO_VERSAO " 
        cQuery += " AND ZII_CTITEM = ZIO_ITEM " 
        cQuery += " AND ZIO.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIO_NUMERO IS NULL " 
    cQuery += " WHERE " 
        cQuery += " ZII_FILIAL = '" + FWxFilial("ZII") + "' " 
        cQuery += " AND ZII.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZII_CONTRA, ZII_VERSAO, ZII_CTITEM " 

    cNxtAlias := GetNextAlias()

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cNxtAlias, .F., .T.)

    (cNxtAlias)->(DbGoTop())   

    While ! (cNxtAlias)->(Eof())

        U_ADCOM416((cNxtAlias)->ZII_CONTRA, (cNxtAlias)->ZII_VERSAO, (cNxtAlias)->ZII_CTITEM)

        (cNxtAlias)->(DbSkip())

    End

    (cNxtAlias)->(DbCloseArea())

    RestArea(aArea)

Return Nil
