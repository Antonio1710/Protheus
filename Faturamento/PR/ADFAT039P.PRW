#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIZ"
Static cTitulo := "Cadastro de Apontamento de Caixa"
Static cTiMast := "Dados do apontamento de caixa"

/*/{Protheus.doc} User Function ADFAT039P
    Cadastro de Apontamento de caixa do veículo.
    Cad Apt Caixa
    Chamado 18465.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT039P() // U_ADFAT039P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT039P")

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
Return (FwMVCMenu("ADFAT039P"))
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
    Local oModel    := MPFormModel():New("ADFAT39", bPre, bPost, /*bCommit*/, bCancel)
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
    //Local cRoteiro   := oModel:GetValue("MD_MASTER", "ZIZ_ROTEIR")
    Local cPlaca     := oModel:GetValue("MD_MASTER", "ZIZ_PLACA")
    Local cCaixa     := oModel:GetValue("MD_MASTER", "ZIZ_CAIXA")

    If lRet .And. nOperation == MODEL_OPERATION_INSERT

        // DbSelectArea("ZIZ")
        // ZIZ->(DbSetOrder(1))
        // ZIZ->(DbGoTop())
        // If ZIZ->( DbSeek( FwxFilial("ZIZ") + cRoteiro + cPlaca + cCaixa ) )
        //     lRet := .F.
        //     Help(Nil, Nil, "Função vldPos(ADFAT039P)", Nil, "Caixa " + cCaixa + " já utilizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        // EndIf

        DbSelectArea("ZIX")
        ZIX->(DbSetOrder(1))
        ZIX->(DbGoTop())
        If ! ZIX->( DbSeek( FwxFilial("ZIX") + cPlaca + cCaixa ) )
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT039P)", Nil, "Veículo " + cPlaca + " não possui caixa " + cCaixa + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

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
    Local oModel    := FwLoadModel("ADFAT039P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} User Function ADFAT38A
    Gera apontamento de caixa.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT39A(cCP, cRoteiro, cOrdem, cPlaca, cCaixa, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    oModel := FwLoadModel("ADFAT039P")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate() 

    oModel:SetValue("MD_MASTER","ZIZ_CTPATI" ,cCP)
    oModel:SetValue("MD_MASTER","ZIZ_ROTEIR" ,cRoteiro)
    oModel:SetValue("MD_MASTER","ZIZ_ORDEM"  ,cOrdem)
    oModel:SetValue("MD_MASTER","ZIZ_PLACA"  ,cPlaca)
    oModel:SetValue("MD_MASTER","ZIZ_CAIXA"  ,cCaixa)

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
        Help(Nil, Nil, "Função ADFAT39A(ADFAT039P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT39B
    Excluí apontamento de caixa.
    @type  Function
    @author Everson
    @since 02/03/2022
    @version 01
    /*/
User Function ADFAT39B(cRoteiro, cPlaca, cCaixa, cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local oModel    := Nil
    Local aError    := {}
    
    Default cMsgError := ""

    DbSelectArea("ZIZ")
    ZIZ->(DbSetOrder(5))
    ZIZ->(DbGoTop())
    If ! ZIZ->( DbSeek( FwxFilial("ZIZ") + cPlaca + cCaixa + cNmOrdem ) )
        cMsgError := "Caixa " + cCaixa + " não localizada."
        Help(Nil, Nil, "Função ADFAT39B(ADFAT039P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return .T.

    EndIf

    oModel := FwLoadModel("ADFAT039P")
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
        Help(Nil, Nil, "Função ADFAT39B(ADFAT039P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT39
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 19/05/2022
    @version 01
/*/
User Function ADFAT39()

    //Variáveis.
    Local aArea       := GetArea()
	Local aParam	  := PARAMIXB
	Local xRet 		  := .T.
	Local oObj 		  := ""
	Local cIdPonto 	  := ""
	Local cIdModel 	  := ""
    Local oModelx     := Nil
    Local nOperation  := 0
    Local cNumero     := ""
    
	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZIZ_PLACA") +;
                       oModelx:GetValue("MD_MASTER", "ZIZ_CAIXA") +;
                       oModelx:GetValue("MD_MASTER", "ZIZ_ORDEM")

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
    @type  User Function
    @author Everson
    @since 19/05/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C(cTbMast, 5, "caixas_de_racao_protheus", cOperacao, FWxFilial(cTbMast) + cNumero)

    RestArea(aArea)

Return Nil
