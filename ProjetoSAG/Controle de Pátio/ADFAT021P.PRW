#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIK"
Static cTitulo := "Solicitação de Pesagem Manual"
Static cTiMast := "Dados da solicitação de pesagem manual"

PUBLISH USER MODEL REST NAME solicitacoesdepesagemmanual

/*/{Protheus.doc} User Function ADFAT021P
    Solicitação de Pesagem Manual.
    Cad Sol Pes Manual
    Chamado 18465.
    @type  Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
User Function ADFAT021P() // U_ADFAT021P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT021P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT021P")
    oBrowse:AddLegend("ZIK_STATUS = '1'" ,"BLUE"  ,"Pendente")
	oBrowse:AddLegend("ZIK_STATUS = '2'" ,"GREEN" ,"Aprovada")
	oBrowse:AddLegend("ZIK_STATUS = '3'" ,"RED"	  ,"Reprovada")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT021P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADFAT212()" 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ADFAT211()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ADFAT212
    Alteração.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
User Function ADFAT212()

    If ZIK->ZIK_STATUS <> "1"
        Help(Nil, Nil, "Função ADFAT212(ADFAT021P)", Nil, "Registro já passou por processo de aprovação.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

	FWExecView("Aprovação/Reprovação", "ADFAT021P", 4)

Return Nil
/*/{Protheus.doc} ADFAT211
    Legenda.
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
User Function ADFAT211()

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
    @since 29/11/2021
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|oModel| vldPre(oModel)}
    Local bPost     := {|oModel| vldPos(oModel)}
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT21", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 29/11/2021
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
    @since 29/11/2021
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cStatus    := oModel:GetValue("MD_MASTER", "ZIK_STATUS")

    If lRet .And. nOperation == MODEL_OPERATION_UPDATE

        If cStatus $"2/3"
            oModel:SetValue("MD_MASTER","ZIK_DTAPRO", Date())
            oModel:SetValue("MD_MASTER","ZIK_HRAPRO", Time())
            oModel:SetValue("MD_MASTER","ZIK_APROVA", __cUserID)
            oModel:SetValue("MD_MASTER","ZIK_NMAPRV", cUserName)

        EndIf

    EndIf

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 29/11/2021
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT021P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
