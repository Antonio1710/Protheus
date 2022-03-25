#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIT"
Static cTitulo := "Cadastro de Apontamento de Lacre"
Static cTiMast := "Dados do cadastro de apontamento de lacre"

/*/{Protheus.doc} User Function ADFAT038P
    Cadastro de Apontamento de lacre.
    Cad Apt Lacre
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/03/2022
    @version 01
    /*/
User Function ADFAT038P() // U_ADFAT038P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT038P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 01/03/2022
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
    @since 01/03/2022
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT038P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|oModel| vldPre(oModel)}
    Local bPost     := {|oModel| vldPos(oModel)}
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT38", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 01/03/2022
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
    @since 01/03/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    // Local cRoteiro   := oModel:GetValue("MD_MASTER", "ZIT_ROTEIR")
    // Local cPlaca     := oModel:GetValue("MD_MASTER", "ZIT_PLACA")
    // Local cLacre     := oModel:GetValue("MD_MASTER", "ZIT_LACRE")

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        // DbSelectArea("ZIT")
        // ZIT->(DbSetOrder(6))
        // ZIT->(DbGoTop())
        // If ZIT->( DbSeek( FwxFilial("ZIT") + cRoteiro + cPlaca + cLacre ) )
        //     lRet := .F.
        //     Help(Nil, Nil, "Função vldPos(ADFAT038P)", Nil, "Lacre " + cLacre + " já utilizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        // EndIf
            
    EndIf
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 01/03/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT038P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} User Function ADFAT38A
    Gera apontamento de lacre.
    @type  Function
    @author Everson
    @since 01/03/2022
    @version 01
    /*/
User Function ADFAT38A(cCP, cRoteiro, cOrdem, cPlaca, cLacre, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    oModel := FwLoadModel("ADFAT038P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER","ZIT_CTPATI" ,cCP)
    oModel:SetValue("MD_MASTER","ZIT_ROTEIR" ,cRoteiro)
    oModel:SetValue("MD_MASTER","ZIT_ORDEM"  ,cOrdem)
    oModel:SetValue("MD_MASTER","ZIT_PLACA"  ,cPlaca)
    oModel:SetValue("MD_MASTER","ZIT_LACRE"  ,cLacre)

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

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT38A(ADFAT038P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT38B
    Excluí apontamento de lacre.
    @type  Function
    @author Everson
    @since 01/03/2022
    @version 01
    /*/
User Function ADFAT38B(cRoteiro, cPlaca, cLacre, cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    DbSelectArea("ZIT")
    ZIT->(DbSetOrder(7))
    ZIT->(DbGoTop())
    If ! ZIT->( DbSeek( FwxFilial("ZIT") + cRoteiro + cPlaca + cLacre + cNmOrdem ) )
        cMsgError := "Lacre " + cLacre + " não localizado."
        Help(Nil, Nil, "Função ADFAT38B(ADFAT038P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    oModel := FwLoadModel("ADFAT038P")
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

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADFAT38B(ADFAT038P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
