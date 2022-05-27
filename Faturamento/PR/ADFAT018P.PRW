#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZI8"
Static cTitulo := "Lote de Produto SAG"
Static cTiMast := "Dados do lote de produto SAG"

// PUBLISH USER MODEL REST NAME lotesdeprodutossag

/*/{Protheus.doc} User Function ADFAT018P
    Cadastro de Lote de Produto SAG.
    Cad Lote de Produto SAG
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/11/2021
    @version 01
    @history Everson, 09/05/2022, Chamado TI - Removida a publicação de web service PUBLISH USER MODEL REST.
    /*/
User Function ADFAT018P() // U_ADFAT018P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT018P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT018P")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT018P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADFAT018P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ADFAT018P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "VIEWDEF.ADFAT018P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADFAT18A()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| .T. }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT18", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 17/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT018P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT18A
    Processa registros pendentes de integração vindos do barramento.
    @type  Static Function
    @author Everson
    @since 09/02/2022
    @version 01
/*/
User Function ADFAT18A()

    //Variáveis.
    Local aArea := GetArea()

    MsAguarde({|| U_ADFAT29C() }, "Aguarde", "Processando...", .F.)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT18B
    Gatilho do lote aberto ou em uso.
    @type  User Function
    @author Everson
    @since 03/03/2022
    @version 01
/*/
User Function ADFAT18B(cProSAg, cPrdPro)

    //Variáveis.
    Local aArea  := GetArea()
    Local cLotUs := ""
    Local cLotAb := ""
    Local cLote  := ""

    Default cProSAg := ""
    Default cPrdPro := ""

    If Empty(cProSAg) .And. ! Empty(cPrdPro)
        cProSAg := Posicione("ZIM", 2, FWxFilial("ZIM") + cPrdPro, "ZIM_PRDSAG")

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(3))
    ZI8->(DbGoTop())
    If ZI8->(DbSeek( FWxFilial("ZI8") + cProSAg))

        While ! ZI8->(Eof()) .And. ZI8->ZI8_FILIAL == FWxFilial("ZI8") .And. ZI8->ZI8_PRDSAG == cProSAg

            If ZI8->ZI8_STATUS == "1" //Aberto.
                cLotAb := ZI8->ZI8_CDLOTE

            ElseIf ZI8->ZI8_STATUS == "2" //Em uso.
                cLotUs := ZI8->ZI8_CDLOTE

            EndIf

            ZI8->(DbSkip())

        End

    EndIf

    cLote := Iif(Empty(cLotUs), cLotAb, cLotUs)

    RestArea(aArea)

Return cLote
/*/{Protheus.doc} ADFAT18C
    Valida o lote.
    @type  User Function
    @author Everson
    @since 28/03/2022
    @version 01
/*/
User Function ADFAT18C(cProSAg, cPrdPro, Lote)

    //Variáveis.
    Local aArea  := GetArea()

    Default cProSAg := ""
    Default cProSAg := ""
    Default Lote    := ""

    If Empty(Lote)
        RestArea(aArea)
        Return .T.

    EndIf

    If Empty(cProSAg) .And. ! Empty(cPrdPro)
        cProSAg := Posicione("ZIM", 2, FWxFilial("ZIM") + cPrdPro, "ZIM_PRDSAG")

    ElseIf ! Empty(cProSAg)
        cPrdPro := Posicione("ZIM", 1, FWxFilial("ZIM") + cPrdPro, "ZIM_PRDPRO")

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    ZI8->(DbGoTop())
    If ! ZI8->(DbSeek( FWxFilial("ZI8") + Lote))
        Help(Nil, Nil, "Função ADFAT18C(ADFAT018P)", Nil, "Lote " + Lote + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If Alltrim(cProSAg) <> Alltrim(ZI8->ZI8_PRDSAG)
        Help(Nil, Nil, "Função ADFAT18C(ADFAT018P)", Nil, "Lote " + Lote + " inválido para o produto " + cProSAg + " | " +  cPrdPro + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_LAUTO == "1"
        Help(Nil, Nil, "Função ADFAT18C(ADFAT018P)", Nil, "Lote " + Lote + " não é válido(automático).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_STATUS == "4"
        Help(Nil, Nil, "Função ADFAT18C(ADFAT018P)", Nil, "Lote " + Lote + " não é válido(encerrado).", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} prVldLote
    Valida lote de produto.
    @type  Static Function
    @author Everson
    @since 19/05/2022
    @version 01
/*/
User Function ADFAT18D(cLote, cPrdSag, cPrdPro, cMsgError)

    //Variáveis.
    Local aArea := GetArea()

    Default cPrdSag   := ""
    Default cPrdPro   := ""
    Default cMsgError := ""

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    If ! ZI8->( DbSeek( FWxFilial("ZI8") + cLote ) )
        cMsgError := "Lote " + cLote + " não localizado."
        Help(Nil, Nil, "Função ADFAT18D(ADFAT018P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_LAUTO == "1"
        cMsgError := "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " não é válido(automático)."
        Help(Nil, Nil, "Função ADFAT18D(ADFAT018P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ZI8->ZI8_STATUS == "4"
        cMsgError := "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " não é válido(encerrado)."
        Help(Nil, Nil, "Função ADFAT18D(ADFAT018P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ! Empty(cPrdSag) .And. Alltrim(cValToChar(cPrdSag)) <> Alltrim(cValToChar(ZI8->ZI8_PRDSAG))
        cMsgError := "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " - produto externo divergente."
        Help(Nil, Nil, "Função ADFAT18D(ADFAT018P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    If ! Empty(cPrdPro) .And. Alltrim(cValToChar(cPrdPro)) <> Alltrim(cValToChar(ZI8->ZI8_PRDPRT))
        cMsgError := "Lote " + Alltrim(cValToChar(ZI8->ZI8_DESLOT)) + " - produto protheus divergente."
        Help(Nil, Nil, "Função ADFAT18D(ADFAT018P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
