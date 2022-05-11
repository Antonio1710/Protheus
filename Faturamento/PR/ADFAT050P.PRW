#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "Apwebsrv.ch"

Static xPula   := Chr(13) + Chr(10)
Static cTbMast := "ZHQ"
Static cTitulo := "Carregamento Guemba"
Static cTiMast := "Dados do carregamento Guemba"

/*/{Protheus.doc} User Function ADFAT050P
    Carregamento Guemba.
    Cad Carr Guemba
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT050P() // U_ADFAT050P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT050P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT050P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" 		ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.ADFAT050P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.ADFAT050P" 	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    		ACTION "VIEWDEF.ADFAT050P" 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    		ACTION "VIEWDEF.ADFAT050P" 	OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina TITLE "Importar Dados"   ACTION "U_ADFAT50A()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local bPre      := {|| .T. }
    Local bPost     := {|| .T. }
    Local bCancel   := {|| .T. }
    Local oModel    := MPFormModel():New("ADFAT50", bPre, bPost, /*bCommit*/, bCancel)
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
    @since 10/05/2022
    @version 01
/*/
Static Function ViewDef()
    
    //Variáveis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT050P")
    Local oStrMast  := FwFormStruct(2, cTbMast)

    oView:SetModel(oModel)

    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")

Return oView
/*/{Protheus.doc} ADFAT50A
    Importar dados.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50A()
    
Return Nil
/*/{Protheus.doc} ADFAT50B
    Processa registros de carregamento Guemba.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50B()

    //Variáveis.
    Local aArea       := GetArea()
    Local lRet        := .T.
    Local cQuery      := ""
    Local cMsgError   := ""
    Local aRecAtu     := {}
    Local cCP         := ""
    Local cRoteiro    := ""
    Local cOrdem      := ""
    Local cPlaca      := ""
    Local aLacres     := {}
    Local aCaixas     := {}
    Local aSilos      := {}
    Local nAux        := 1

    cQuery := ""
    cQuery += " SELECT " 
        cQuery += " ZHQ_ORDEM, ZHQ_PLACA, ZHQ_INTEGR, ZHQ_GRJADA, ZHQ_SILOS, ZHQ_LACRES, ZHQ_PRODUT, ZHQ_PESO, ZHQ_CAIXAS, " 
        cQuery += " ZHQ_PROCES, ZHQ_ERRO, ZHQ.R_E_C_N_O_ AS REC, " 
        cQuery += " ZIF_NUMERO, ZIF_CTPATI, ZIF_PLACA, ZIF_ROTEIR " 
    cQuery += " FROM  " 
        cQuery += " " + RetSqlName("ZHQ") + " (NOLOCK) AS ZHQ " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF ON " 
        cQuery += " ZHQ_FILIAL = ZIF_FILIAL " 
        cQuery += " AND ZHQ_ORDEM = ZIF_NUMERO " 
    cQuery += " WHERE " 
        cQuery += " ZHQ_FILIAL = '" + FWxFilial("ZHQ") + "' " 
        cQuery += " AND ZHQ_PROCES = '2' " 
        cQuery += " AND ZHQ.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY REC " 

    TcQuery cQuery New Alias "D_GUEMBA"
    DbSelectArea("D_GUEMBA")
    While ! D_GUEMBA->(Eof())

        cMsgError   := ""

        cCP         := D_GUEMBA->ZIF_CTPATI
        cRoteiro    := D_GUEMBA->ZIF_ROTEIR
        cOrdem      := D_GUEMBA->ZIF_NUMERO
        cPlaca      := D_GUEMBA->ZIF_PLACA
        aLacres     := Separa(Alltrim(cValToChar(D_GUEMBA->ZHQ_LACRES)),"#", .F.)
        aCaixas     := Separa(Alltrim(cValToChar(D_GUEMBA->ZHQ_CAIXAS)),"#", .F.)
        aSilos      := Separa(Alltrim(cValToChar(D_GUEMBA->ZHQ_SILOS)) ,"#", .F.)

        Begin Transaction

            //Lança lacres.
            For nAux := 1 To Len(aLacres)

                If ! U_ADFAT38A(cCP, cRoteiro, cOrdem, cPlaca, aLacres[nAux], @cMsgError)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            Next nAux

            //Lança caixas.
            For nAux := 1 To Len(aCaixas)

                If ! U_ADFAT39A(cCP, cRoteiro, cOrdem, cPlaca, aCaixas[nAux], @cMsgError)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            Next nAux

            //Lança silos.
            For nAux := 1 To Len(aSilos)

                If ! U_ADFAT40A(cCP, cRoteiro, cOrdem, cPlaca, aSilos[nAux], @cMsgError)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            Next nAux

            //Processa finaliza carregamento.
            If ! U_ADFAT35G(cCP, cRoteiro, cOrdem)
                DisarmTransaction()
                Break

            EndIf

        End Transaction    
            
        Aadd(aRecAtu, {D_GUEMBA->REC, lRet, cMsgError})

        D_GUEMBA->(DbSkip())

    End
    D_GUEMBA->(DbCloseArea())

    If Len(aRecAtu) > 0
        atuPeGue(aRecAtu)

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} atuPeGue
    Atualiza registros de carregamento vindos do Guemba.
    @type  Static Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
Static Function atuPeGue(aRecAtu)

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local lRet      := .F.
    Local oModel    := Nil
    Local cMsgError := ""
    Local cEmilErr  := GetMv("MV_#FAT291",,"everson.silva@adoro.com.br;wagner.moro@adoro.com.br")

    For nAux := 1 To Len(aRecAtu)
    
        DbSelectArea(cTbMast)
        (cTbMast)->(DbGoTo(aRecAtu[nAux][1]))

        oModel := FwLoadModel("ADFAT050P")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        If aRecAtu[nAux][2]
            oModel:SetValue("MD_MASTER", "ZHQ_PROCES", "1")

        Else
            oModel:SetValue("MD_MASTER", "ZHQ_ERRO", aRecAtu[nAux][3])
            
        EndIf

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

        If ! aRecAtu[nAux][2]
            U_EnviaEmail(GetMv("MV_RELFROM"), cEmilErr, aRecAtu[nAux][3], "Erro Comunicação Guemba - Retorno de carregamento","")
            
        EndIf

        If ! Empty(cMsgError)
            Help(Nil, Nil, "Função atuPeGue(ADFAT050P)", Nil, "Erro na atualização de registro de carregamento Guemba." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT24G
    Salva registros de pesagem vindos do barramento json.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50C(aRet, cMsgError)

    //Variáveis.
    Local aArea       := GetArea()
    Local lRet        := .F.
    Local nAux        := 1
    Local oModel      := Nil
    Local cPlaca      := ""
    Local nPeso       := 0
    Local cAgrupador  := ""
    Local cOrdem      := ""
    Local cIntegrado  := ""
    Local cGranjada   := ""
    Local cLacres     := ""
    Local cProduto    := ""
    Local cSilos      := ""
    Local cCaixas     := ""
    
    Default cMsgError := ""

    For nAux := 1 To Len(aRet)

        cAgrupador  := aRet[nAux][1]
        cOrdem      := aRet[nAux][2]
        cPlaca      := aRet[nAux][3]
        cIntegrado  := aRet[nAux][4]
        cGranjada   := aRet[nAux][5]
        cLacres     := aRet[nAux][6]
        cProduto    := aRet[nAux][7]
        nPeso       := aRet[nAux][8]
        cSilos      := aRet[nAux][9]
        cCaixas     := aRet[nAux][10]
        
        oModel := FwLoadModel("ADFAT050P")

        DbSelectArea(cTbMast)
        (cTbMast)->(DbSetOrder(1))
        If (cTbMast)->(DbSeek( FWxFilial(cTbMast) + cOrdem ))
            oModel:SetOperation(MODEL_OPERATION_UPDATE)

        Else
            oModel:SetOperation(MODEL_OPERATION_INSERT)

        EndIf

        oModel:Activate() 

        oModel:SetValue("MD_MASTER", "ZHQ_AGRUP" , cAgrupador)
        oModel:SetValue("MD_MASTER", "ZHQ_ORDEM" , cOrdem)
        oModel:SetValue("MD_MASTER", "ZHQ_PLACA" , cPlaca)
        oModel:SetValue("MD_MASTER", "ZHQ_INTEGR", cIntegrado)
        oModel:SetValue("MD_MASTER", "ZHQ_GRJADA", cGranjada)
        oModel:SetValue("MD_MASTER", "ZHQ_SILOS" , cSilos)
        oModel:SetValue("MD_MASTER", "ZHQ_LACRES", cLacres)
        oModel:SetValue("MD_MASTER", "ZHQ_PRODUT", cProduto)
        oModel:SetValue("MD_MASTER", "ZHQ_PESO"  , nPeso)
        oModel:SetValue("MD_MASTER", "ZHQ_CAIXAS", cCaixas)

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
            Help(Nil, Nil, "Função ADFAT50C(ADFAT050P)", Nil, "Erro: " + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    Next nAux

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT50D
    Obtém registros de carregamento do WS Guemba.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50D()

Return Nil
