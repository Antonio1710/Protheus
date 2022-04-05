#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZID"
Static cTitulo := "Solicitação de Liberação de Pesagem de Ensacados"
Static cTiMast := "Dados da solicitação de liberação de pesagem de ensacados"
Static xPula   := Chr(13) + Chr(10)

/*/{Protheus.doc} User Function ADEST068P
    Solicitação de Liberação de Pesagem de Ensacado.
    Cad Lib Pes Ensacados
    Chamado 18465.
    @type  Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
User Function ADEST068P() // U_ADEST068P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADEST068P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADEST068P")
    oBrowse:AddLegend("ZID_STATUS = '1'" ,"BLUE"  ,"Pendente")
	oBrowse:AddLegend("ZID_STATUS = '2'" ,"GREEN" ,"Aprovada")
	oBrowse:AddLegend("ZID_STATUS = '3'" ,"RED"	  ,"Reprovada")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADEST068P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADEST681()" 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ADEST682()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ADEST681
    Alteração.
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
User Function ADEST681()

    If ZID->ZID_STATUS <> "1"
        Help(Nil, Nil, "Função ADEST681(ADEST068P)", Nil, "Registro já passou por processo de aprovação.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

	FWExecView("", "ADEST068P", 4)

Return Nil
/*/{Protheus.doc} ADEST682
    Legenda.
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
User Function ADEST682()

	//Variáveis.
	Local aLegenda := {}

	Aadd(aLegenda,{"BR_AZUL"    ,"Pendente" })
	Aadd(aLegenda,{"BR_VERDE"   ,"Liberada"})
	Aadd(aLegenda,{"BR_VERMELHO","Reprovada"})

	BrwLegenda("Solic. Pesagem Manual","Legenda",aLegenda)

Return Nil
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|oModel| vldPre(oModel)}
    Local bPost     := {|oModel| vldPos(oModel)}
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADEST68", bPre, bPost, /*bCommit*/, bCancel)
    Local oStrMast  := FwFormStruct(1, cTbMast)                                                
     
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)

    oModel:SetPrimaryKey({})

    //oModel:SetDescription(cTitulo)

    oModel:GetModel("MD_MASTER"):SetDescription(cTiMast)

Return oModel
/*/{Protheus.doc} vldPre
    Pós validação.
    @type  Static Function
    @author Everson
    @since 17/12/2021
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
    @since 17/12/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cStatus    := oModel:GetValue("MD_MASTER", "ZID_STATUS")

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        If cStatus $"2/3"
            oModel:SetValue("MD_MASTER","ZID_DTAPRO", Date())
            oModel:SetValue("MD_MASTER","ZID_HRAPRO", Time())
            oModel:SetValue("MD_MASTER","ZID_APROVA", __cUserID)
            oModel:SetValue("MD_MASTER","ZID_NMAPRV", cUserName)

        EndIf

    EndIf

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 17/12/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADEST068P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADEST683
    Exclusão de solicitação de liberação de pesagem de produtos ensacados.
    @type  User Function
    @author Everson
    @since 22/12/2021
    @version 01
/*/
User Function ADEST683(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.
    Local oSolic:= Nil

    Default cMsgError := ""

    DbSelectArea("ZID")
    ZID->(DbSetOrder(2))
    If ! ZID->( DbSeek( FWxFilial("ZID") + cNmOrdem ) )
        RestArea(aArea)
        Return .T.

    EndIf

    oSolic := FwLoadModel("ADEST068P")

    oSolic:SetOperation(MODEL_OPERATION_DELETE)
    oSolic:Activate() 

    If oSolic:VldData()
        oSolic:CommitData()

        lRet := .T.
        
    Else
        aError := oSolic:GetErrorMessage()
        cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

    EndIf

    oSolic:DeActivate()
    oSolic:Destroy()
    oSolic := Nil

    If ! Empty(cMsgError)
        Help(Nil, Nil, "Função ADEST683(ADEST068P)", Nil, "Erro na exclusão na solicitação de liberação de pesagem de produtos ensacados." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
