#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIY"
Static cTitulo := "Cadastro de Apontamento de Silo"
Static cTiMast := "Dados do apontamento de silo"

/*/{Protheus.doc} User Function ADFAT040P
    Cadastro de Apontamento de silo.
    Cad Apt Silo
    Chamado 18465.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT040P() // U_ADFAT040P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT040P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 02/03/2022
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
    @since 02/03/2022
    @version 01
/*/
Static Function MenuDef()
Return (FwMVCMenu("ADFAT040P"))
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|oModel| vldPre(oModel)}
    Local bPost     := {|oModel| vldPos(oModel)}
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT40", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 02/03/2022
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
    @since 02/03/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cSilo      := oModel:GetValue("MD_MASTER", "ZIY_SILO")

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        DbSelectArea("ZIW")
        ZIW->(DbSetOrder(1))
        ZIW->(DbGoTop())
        If ! ZIW->( DbSeek( FwxFilial("ZIW") + cSilo ) )
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT040P)", Nil, "Silo " + cSilo + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf
            
    EndIf
  
Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 02/03/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT040P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} User Function ADFAT38A
    Gera apontamento de silo.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT40A(cCP, cRoteiro, cOrdem, cPlaca, cSilo, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    oModel := FwLoadModel("ADFAT040P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER","ZIY_CTPATI" ,cCP)
    oModel:SetValue("MD_MASTER","ZIY_ROTEIR" ,cRoteiro)
    oModel:SetValue("MD_MASTER","ZIY_ORDEM"  ,cOrdem)
    oModel:SetValue("MD_MASTER","ZIY_PLACA"  ,cPlaca)
    oModel:SetValue("MD_MASTER","ZIY_SILO"   ,cSilo)

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
        Help(Nil, Nil, "Função ADFAT40A(ADFAT040P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT40B
    Excluí apontamento de silo.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT40B(cRoteiro, cPlaca, cOrdem, cSilo, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    DbSelectArea("ZIY")
    ZIY->(DbSetOrder(1))
    ZIY->(DbGoTop())
    If ! ZIY->( DbSeek( FwxFilial("ZIY") + cRoteiro + cPlaca + cOrdem + cSilo ) )
        cMsgError := "Silo " + cSilo + " não localizado."
        Help(Nil, Nil, "Função ADFAT40B(ADFAT040P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    oModel := FwLoadModel("ADFAT040P")
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
        Help(Nil, Nil, "Função ADFAT40B(ADFAT040P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
