#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZI8"
Static cTitulo := "Lote de Produto SAG"
Static cTiMast := "Dados do lote de produto SAG"

PUBLISH USER MODEL REST NAME lotesdeprodutossag

/*/{Protheus.doc} User Function ADFAT018P
    Cadastro de Lote de Produto SAG.
    Cad Lote de Produto SAG
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/11/2021
    @version 01
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
