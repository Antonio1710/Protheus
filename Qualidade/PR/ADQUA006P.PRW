#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZHV"
Static cTitulo := "Exame Laboratorial"
Static cTiMast := "Exame Laboratorial"

/*/{Protheus.doc} User Function ADQUA006P
    Exame laboratorial
    Chamado 18465.
    @type  Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
User Function ADQUA006P() // U_ADQUA006P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADQUA006P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
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
    @since 25/07/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADQUA006P" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ADQUA006P" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ADQUA006P" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ADQUA006P" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.ADQUA006P" OPERATION 8 ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ getCmps()})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
 
    oModel := MPFormModel():New("ADQUA6", /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
 
    oModel:AddFields("MD_MASTER", NIL, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid, ,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZHV_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZHV_NUMERO", "ZHV_NUMERO"},;
            {"ZHV_NOME"  , "ZHV_NOME"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID"):SetUniqueLine({"ZHV_CODITE"})

    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({"ZHV_FILIAL","ZHV_NUMERO"})

Return oModel
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := Nil
    Local oModel    := FWLoadModel("ADQUA006P")
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
 
    oView:AddIncrementField("VW_GRID", "ZHV_ITEM")

Return oView
/*/{Protheus.doc} gridFocus
    Função executada quando a grid ganha foco.
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function gridFocus(oView)

    //Variáveis.
    Local aArea   := GetArea()
    Local oModel  := oView:GetModel()
    Local cNome   := oModel:GetValue("MD_MASTER","ZHV_NOME")

    If Empty(cNome)
        Help(Nil, Nil, "Função gridFocus(ADQUA006P)", Nil, "Necessário informar o nome do exame.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        oView:GetViewObj("VW_MASTER")[3]:GetFWEditCTRL("ZHV_NOME"):OCtrl:SetFocus()
    
    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCmps
    Retorna campos do cabeçalho.
    @type  Static Function
    @author Everson
    @since 25/07/2022
    @version 01
/*/
Static Function getCmps()
Return "ZHV_FILIAL;ZHV_NUMERO;ZHV_NOME;"
/*/{Protheus.doc} ADQUA6
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 26/07/2022
    @version 01
/*/
User Function ADQUA6()

    //Variáveis.
    Local aArea     := GetArea()
	Local aParam	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
    Local oModelx   := Nil
    Local nOperation:= 0
    Local cNumero   := ""

	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZHV_NUMERO")

            If nOperation == MODEL_OPERATION_INSERT
                cOperacao := "I"

            ElseIf nOperation == MODEL_OPERATION_UPDATE
                cOperacao := "A"

            ElseIf nOperation == MODEL_OPERATION_DELETE
                cOperacao := "D"

            EndIf

            If ! Empty(cOperacao) .And. ! Empty(cNumero)
                grvBarr(cOperacao, cNumero)

            EndIf

		EndIf

	EndIf

    RestArea(aArea)

Return xRet
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  Static Function
    @author Everson
    @since 26/07/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea     := GetArea()
    Local cFilter   := ""
    Local cCmp      := getCmps()
    Local cTopico   := "exame_laboratorio_protheus"

    
    cFilter := " ZHV_FILIAL ='" + FWxFilial("ZHV") + "' .And. ZHV_NUMERO = '" + cNumero + "' "

    U_ADFAT27D("ZHV", 1, FWxFilial("ZHV") + cNumero,;
        "ZHV", 1, FWxFilial("ZHV") + cNumero, "ZHV_ITEM", cFilter,;
        cTopico, cOperacao,;
        .T., .T., .T.,;
        cCmp) 

    RestArea(aArea)

Return Nil
