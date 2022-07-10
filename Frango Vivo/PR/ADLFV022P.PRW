#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIS"
Static cTitulo := "Granjada"
Static cTiMast := "Dados da granjada"

/*/{Protheus.doc} User Function ADLFV022P
    Cadastro de granjada.
    Cad Granjada.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 21/02/2022
    @version 01
    /*/
User Function ADLFV022P() // U_ADLFV022P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADLFV022P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADLFV022P")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADLFV022P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADLFV022P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ADLFV022P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "VIEWDEF.ADLFV022P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADLFV22A()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|oModel| vldPos(oModel) }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADLFV22", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPos
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADLFV022P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADLFV22A
    Processa registros pendentes de integração vindos do barramento.
    @type  Static Function
    @author Everson
    @since 16/03/2022
    @version 01
/*/
User Function ADLFV22A()

    //Variáveis.
    Local aArea := GetArea()

    MsAguarde({|| U_ADFAT29E() }, "Aguarde", "Processando...", .F.)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADLFV22B
    Posiciona no registro de granjada.
    @type  Static Function
    @author Everson
    @since 13/05/2022
    @version 01
/*/
User Function ADLFV22B(cGranjada)

    DbSelectArea("ZIS")
    ZIS->(DbSetOrder(1))
    If ! ZIS->( DbSeek( FWxFilial("ZIS") + cGranjada) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADLFV22B
    Posiciona no registro de granjada pela descrição.
    @type  Static Function
    @author Everson
    @since 07/07/2022
    @version 01
/*/
User Function ADLFV22C(cDesc)

    DbSelectArea("ZIS")
    ZIS->(DbSetOrder(3))
    If ! ZIS->( DbSeek( FWxFilial("ZIS") + cDesc) )
        Return .F.

    EndIf

Return .T.

