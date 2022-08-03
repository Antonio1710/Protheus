#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "Apwebsrv.ch"
#Include "FWMVCDef.ch"

Static xPula   := Chr(13) + Chr(10)
Static cTbMast := "ZHQ"
Static cTitulo := "Carregamento Gemba"
Static cTiMast := "Dados do carregamento Gemba"
Static cCodCop := "310"

/*/{Protheus.doc} User Function ADFAT050P
    Carregamento Gemba.
    Cad Carr Gemba
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
	// ADD OPTION aRotina TITLE "Importar Dados"   ACTION "U_ADFAT50A()"       OPERATION 10  ACCESS 0

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

    // MsAguarde({|| U_ADFAT50D() }, "Aguarde", "Processando...")
    
Return Nil
/*/{Protheus.doc} ADFAT50B
    Processa registros de carregamento Gemba.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50B(cNmOrdem)

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
    Local aDSeqP      := {}
    Local cTktNv      := ""
    Local cSeqNV      := ""
    Local cLacre      := ""
    Local cCaixa      := ""
    Local cSilo       := ""

    Default cNmOrdem  := ""

    cQuery := ""
    cQuery += " SELECT " 
        cQuery += " ZHQ_ORDEM, ZHQ_PLACA, ZHQ_INTEGR, ZHQ_GRJADA, ZHQ_SILOS, ZHQ_LACRES, ZHQ_PRODUT, ZHQ_PESO, ZHQ_CAIXAS, " 
        cQuery += " ZHQ_PROCES, ZHQ_ERRO, ZHQ.R_E_C_N_O_ AS REC, " 
        cQuery += " ZIF_NUMERO, ZIF_CTPATI, ZIF_PLACA, ZIF_ROTEIR, ZIF_PRDSAG " 
    cQuery += " FROM  " 
        cQuery += " " + RetSqlName("ZHQ") + " (NOLOCK) AS ZHQ " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF ON " 
        cQuery += " ZHQ_FILIAL = ZIF_FILIAL " 
        cQuery += " AND ZHQ_ORDEM = ZIF_NUMERO " 
    cQuery += " WHERE " 
        cQuery += " ZHQ_FILIAL = '" + FWxFilial("ZHQ") + "' " 

        If Empty(cNmOrdem)
            cQuery += " AND ZHQ_PROCES = '2' " 

        Else
            cQuery += " AND ZHQ_ORDEM = '" + cNmOrdem + "' " 

        EndIf

        cQuery += " AND ZHQ.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY REC " 

    If Select("D_GEMBA")
        D_GEMBA->(DbCloseArea())
        
    EndIf

    TcQuery cQuery New Alias "D_GEMBA"
    DbSelectArea("D_GEMBA")
    While ! D_GEMBA->(Eof())

        cMsgError   := ""

        cCP         := D_GEMBA->ZIF_CTPATI
        cRoteiro    := D_GEMBA->ZIF_ROTEIR
        cOrdem      := D_GEMBA->ZIF_NUMERO
        cPlaca      := D_GEMBA->ZIF_PLACA
        aLacres     := Separa(Alltrim(cValToChar(D_GEMBA->ZHQ_LACRES)),"#", .F.)
        aCaixas     := Separa(Alltrim(cValToChar(D_GEMBA->ZHQ_CAIXAS)),"#", .F.)
        aSilos      := Separa(Alltrim(cValToChar(D_GEMBA->ZHQ_SILOS)) ,"#", .F.)

        Begin Transaction

            //Ajusta a sequência do ticket de pesagem.
            aDSeqP := U_ADFAT355(cCP, cRoteiro)

            If Len(aDSeqP) <= 0
                cMsgError := "Não foi possível obter dados para verificação de troca de sequência do ticket"
                DisarmTransaction()
                Break

            EndIf

            cTktNv := aDSeqP[1]
            cSeqNV := aDSeqP[2]

            //Ajusta sequência de pesagem.
            If ! U_ADFAT192(cCP, cOrdem, cTktNv, cSeqNV, @cMsgError)
                DisarmTransaction()
                Break

            EndIf

            If ! U_ADFAT16A(cOrdem)
                cMsgError := "Ordem de pesagem " + cOrdem + " não localizado(ZIF)(ADFAT50B)."
                RestArea(aArea)
                Return .F.

            EndIf

            //Valida se o produto retornado do Gemba é o mesmo da ordem de pesagem.
            If Alltrim(cValToChar(D_GEMBA->ZHQ_PRODUT)) <> Alltrim(cValToChar(D_GEMBA->ZIF_PRDSAG))
                
                If ! ajustProd( D_GEMBA->ZHQ_ORDEM, Alltrim(cValToChar(D_GEMBA->ZHQ_PRODUT)) , Alltrim(cValToChar(D_GEMBA->ZIF_PRDSAG)), @cMsgError )
                     lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf               

            EndIf

            //Lança lacres.
            For nAux := 1 To Len(aLacres)

                cLacre := Substr(Alltrim(cValToChar(aLacres[nAux])),1,10)

                If ! U_ADFAT38A(cCP, cRoteiro, cOrdem, cPlaca, cLacre, @cMsgError)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            Next nAux

            //Lança caixas.
            For nAux := 1 To Len(aCaixas)

                cCaixa := Substr(Alltrim(cValToChar(aCaixas[nAux])),1,2)

                If ! U_ADFAT39A(cCP, cRoteiro, cOrdem, cPlaca, cCaixa, @cMsgError)
                    lRet := .F.
                    DisarmTransaction()
                    Break

                EndIf

            Next nAux

            //Lança silos.
            For nAux := 1 To Len(aSilos)

                cSilo := Substr(Alltrim(cValToChar(aSilos[nAux])),1,6)

                If ! U_ADFAT40A(cCP, cRoteiro, cOrdem, cPlaca, cSilo, @cMsgError)
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

        If ! Empty(cMsgError)
            U_ADFAT173("Erro carregamento : " + cMsgError, cOrdem, "", "GEMBA")

        EndIf
            
        Aadd(aRecAtu, {D_GEMBA->REC, lRet, cMsgError})

        D_GEMBA->(DbSkip())

    End
    D_GEMBA->(DbCloseArea())

    If Len(aRecAtu) > 0
        atuPeGue(aRecAtu)

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ajustProd
    Ajusta o produto na ordem de pesagem e ordem de carregamento de ração.
    @type  Static Function
    @author Everson
    @since 16/05/2022
    @version 01
/*/
Static Function ajustProd(cNmOrdem, cProdGemba, cProduto, cMsgError)

    //Variáveis.
    Local aArea    := GetArea()
    Local lRet     := .F.
    Local cOrdemC  := ""
    Local cQuery   := ""
    Local cCodAb   := ""
    Local cCodUso  := ""
    Local cCodMax  := ""
    Local cDesc    := ""
    Local oModel   := Nil
    Local aError   := {}
    Local nRecMax  := 0
    Local cCodRet  := ""
    Local aDados   := {}
    Local cProProth:= ""
    Local cDescPro := ""

    Default cMsgError := ""

    //Posiciona na ordem de pesagem.
    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizado(ZIF)(ajuste de lote)."
        RestArea(aArea)
        Return .F.

    EndIf

    cOrdemC := ZIF->ZIF_ORDRAC

    cProdGemba := Alltrim(cValToChar(cProdGemba))

    //Posiciona no produto (ZIM).
    If ! U_ADFAT20B(cProdGemba)
        cMsgError := "Produto " + cProdGemba + " não localizado(ZIM)."
        RestArea(aArea)
        Return .F.

    EndIf

    cQuery += " SELECT  " 
    cQuery += " ZI8_STATUS, ZI8_CDLOTE, ZI8_DESLOT, R_E_C_N_O_ AS REC " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZI8") + " (NOLOCK) AS ZI8 " 
    cQuery += " WHERE " 
    cQuery += " ZI8_FILIAL = '" + FWxFilial("ZI8") + "' " 
    cQuery += " AND ZI8_PRDSAG = '" + cProdGemba + "' " 
    cQuery += " AND ZI8.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY CASE ZI8_STATUS " 
    cQuery += " When '2' Then 1 " 
    cQuery += " When '1' Then 2 " 
    cQuery += " When '3' Then 3 " 
    cQuery += " ELSE 4 END, ZI8_DTINIC DESC " 

    If Select("D_LOTES") > 0
        D_LOTES->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_LOTES"
    DbSelectArea("D_LOTES")
    D_LOTES->(DbGoTop())
    While ! D_LOTES->(Eof())

        If D_LOTES->ZI8_STATUS == "2"
            cCodUso  := Alltrim(cValToChar(D_LOTES->ZI8_CDLOTE))
            cDesc    := Alltrim(cValToChar(D_LOTES->ZI8_DESLOT))
            Exit
        
        ElseIf D_LOTES->ZI8_STATUS == "1"
            cCodAb    := Alltrim(cValToChar(D_LOTES->ZI8_CDLOTE))
            cDesc     := Alltrim(cValToChar(D_LOTES->ZI8_DESLOT))
            Exit

        Else
            cCodMax := Alltrim(cValToChar(D_LOTES->ZI8_CDLOTE))
            cDesc   := Alltrim(cValToChar(D_LOTES->ZI8_DESLOT))
            nRecMax := Val(cValToChar(D_LOTES->REC))
            Exit

        EndIf

         D_LOTES->(DbSkip())

    End

    cCodRet := Alltrim(cValToChar(Iif(Empty(cCodUso), cCodAb, cCodUso)))

    Begin Transaction

        If Empty(cCodRet) .And. ! Empty(cCodMax)

            DbSelectArea("ZI8")
            ZI8->(DbGoTo( nRecMax ))

            oModel := FwLoadModel("ADFAT018P")
            oModel:SetOperation(MODEL_OPERATION_UPDATE)

            oModel:Activate()

            oModel:SetValue("MD_MASTER", "ZI8_STATUS", "2")

            If oModel:VldData()
                oModel:CommitData()
                cCodRet := Alltrim(cValToChar(cCodMax))

            Else
                aError := oModel:GetErrorMessage()
                cMsgError := "Não foi possível abrir o lote " + cCodMax + " para o produto " + cProdGemba + " " + Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))
                DisarmTransaction()
                Break

            EndIf

        ElseIf Empty(cCodRet) .And. Empty(cCodMax)
            cMsgError := "Produto " + cProdGemba + " não possui lote.(ZI8)"
            DisarmTransaction()
            Break

        EndIf

        //Gera log.
        U_ADFAT173("Alteração produto ant/post: " + cValToChar(ZIF->ZIF_PRDSAG) + " / " + cValToChar(cProdGemba), ZIF->ZIF_NUMERO, "", "GEMBA")

        U_ADFAT173("Alteração lote ant/post: " + cValToChar(ZIF->ZIF_LOTE) + " / " + cValToChar(cCodRet), ZIF->ZIF_NUMERO, "", "GEMBA")

        cProProth := Alltrim(cValToChar(Posicione("ZIM", 1, FwxFilial("ZIM") + cProdGemba, "ZIM_PRDPRO")))
        cDescPro  := Alltrim(cValToChar(Posicione("ZIM", 1, FwxFilial("ZIM") + cProdGemba, "ZIM_DESSAG")))

        //Altera produto, descrição e lote na ordem de carregamento de ração.
        aDados := {}
        Aadd(aDados,{"ZIR_PRDSAG", cProdGemba})
        Aadd(aDados,{"ZIR_PRDPRO", cProProth})
        Aadd(aDados,{"ZIR_DESC"  , cDescPro})
        Aadd(aDados,{"ZIR_LOTPRD", cCodRet})
        Aadd(aDados,{"ZIR_DESLOT", cDesc})
        If ! U_ADFAT32D(cOrdemC, aDados, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera produto sag da ordem de pesagem.
        If ! U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_PRDSAG", cProdGemba, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera produto protheus da ordem de pesagem.
        If ! U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_PRDPRO", cProProth, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        //Altera lote na ordem de pesagem.
        If ! U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_LOTE", cCodRet, @cMsgError)
            DisarmTransaction()
            Break

        EndIf

        lRet := .T.

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} atuPeGue
    Atualiza registros de carregamento vindos do Gemba.
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
            oModel:SetValue("MD_MASTER", "ZHQ_PROCES", "1") //Everson - 24/05/2022. Chamado 18465.
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
            U_EnviaEmail(GetMv("MV_RELFROM"), cEmilErr, aRecAtu[nAux][3], "Erro Comunicação Gemba - Retorno de carregamento","")
            
        EndIf

        If ! Empty(cMsgError)
            Help(Nil, Nil, "Função atuPeGue(ADFAT050P)", Nil, "Erro na atualização de registro de carregamento Gemba." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT50C
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
    Obtém registros de carregamento do WS Gemba.
    @type  User Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT50D(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Loading.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSLoading():New()
    Local cAgrupador:= ""
    Local nAux      := 1
    Local nAux2     := 1
    Local cPlaca    := ""
    Local cIntegrado:= ""
    Local cGranjada := ""
    Local cLacres   := ""
    Local cSilos    := ""
    Local cProduto  := ""
    Local nPeso     := 0
    Local cCaixas   := ""
    Local oDetalhe  := Nil
    Local aDados    := {}
    Local cEmilErr  := GetMv("MV_#FAT291",,"everson.silva@adoro.com.br;wagner.moro@adoro.com.br")
    Local cObserv   := "Ocorreu erro salvar o registro de carregamento do Gemba na tabela ZHQ."

    Default cNmOrdem    := ""
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem não localizada(ZIF)(Get - dados de carregamento do Gemba)."
        RestArea(aArea)
        Return .F.

    EndIf

    cAgrupador := Alltrim(cValToChar(ZIF->ZIF_ROTEIR))

    oWsdl:_URL                      := cUrl
    oWsdl:CCD_COMPANY_UNIT          := cCodCop
    oWsdl:CDS_CODE_ORDER_LOADING    := cNmOrdem //Passando a ordem como agrupador, pois o SAG já está utilizando desta forma.
    //oWsdl:CDS_CODE_ORDER_LOADING  := cAgrupador
    oWsdl:CNR_BILL_REQUEST          := cNmOrdem 

    oWsdl:Get()

    If ValType(oWsdl:OWSGETRESULT:OWSLOADING) <> "A" .Or. Len(oWsdl:OWSGETRESULT:OWSLOADING) < 1
        cMsgError := "WS Gemba não retornou dados do método Get(Ordem de Pesagem). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    For nAux := 1 To Len(oWsdl:OWSGETRESULT:OWSLOADING)

        aDados     := {}
        cSilos     := ""
        nPeso      := 0

        cPlaca     := Alltrim(cValToChar(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:CNR_PLATE))
        cIntegrado := Alltrim(cValToChar(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:CDS_CODE_CUSTOMER))
        cGranjada  := Alltrim(cValToChar(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:CDS_CODE_SHED))
        cLacres    := StrTran(Alltrim(cValToChar(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:CDS_SEAL)), ",", "#")
        
        If ValType(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:OWSDETAILS:OWSLOADINGDETAIL) == "A" .And. Len(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:OWSDETAILS:OWSLOADINGDETAIL) > 0

            For nAux2 := 1 To Len(oWsdl:OWSGETRESULT:OWSLOADING[nAux]:OWSDETAILS:OWSLOADINGDETAIL)

                oDetalhe := oWsdl:OWSGETRESULT:OWSLOADING[nAux]:OWSDETAILS:OWSLOADINGDETAIL[nAux2]

                cProduto := oDetalhe:CDS_CODE_PRODUCT
                
                nPeso    += Val(cValToChar(oDetalhe:CPS_SLIDE))
                
                cSilos   += Iif(Empty(cSilos), "", "#") + Right(Alltrim(cValToChar(oDetalhe:CNM_SILO)), 2)

                cCaixas  += carCaixasGe(cCaixas, oDetalhe:CDS_BOX)

            Next nAux2

        EndIf

        Aadd(aDados,{cAgrupador, cNmOrdem, cPlaca, cIntegrado, cGranjada, cLacres, cProduto, nPeso, cSilos, cCaixas})

        If ! U_ADFAT50C(aDados, @cMsgError)
            U_EnviaEmail(GetMv("MV_RELFROM"), cEmilErr, cObserv + xPula + cMsgError, "Erro Processamento de Registros Gemba", "")

        EndIf

    Next nAux

    FreeObj(oWsdl)
    FreeObj(oDetalhe)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} Function carCaixasGe
    Carrega caixas carregadas.
    @type  Static Function
    @author Everson
    @since 16/05/2022
    @version 01
    /*/
Static Function carCaixasGe(cRet, cCaixas)

    //Variáveis.
    Local nAux      := 1
    Local nAux2     := 1
    Local aCxAux    := {}
    Local aCaixas   := {}
    Local cCxaux    := ""
    Local cCxaux2   := ""
    Local nCount    := 0

    Default cCaixas := ""

    aCxAux := Separa(Alltrim(cValToChar(cCaixas)), ",", .F.) 

    For nAux := 1 To Len(aCxAux)
        
        cCxaux  := Alltrim(cValToChar(aCxAux[nAux]))

        If Len(cCxaux) == 1
            Aadd(aCaixas, Padl(cCxaux, 2, "0"))

        Else
            
            For nAux2 := 1 To Len(cCxaux)

                nCount++

                cCxaux2 := Substr(cCxaux, nCount, 1)

                Aadd(aCaixas, Padl(cCxaux2, 2, "0"))

            Next nAux2

            nCount  := 0

        EndIf

    Next nAux

    For nAux := 1 To Len(aCaixas)

        cRet += Iif(Empty(cRet), "", "#") + aCaixas[nAux]

    Next nAux

Return cRet
/*/{Protheus.doc} User Function ADFAT50E
    Envio de cadastro de veículo para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50E(cPlaca, lUpdate, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Truck.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSTruck():New()
    Local oTruck    := Nil
    Local oBox      := Nil
    Local cMetodo   := ""
    Local cMotorista:= ""
    Local cCodRet   := ""
    Local cErro     := ""
    Local cPlacaFor := ""

    Default cPlaca      := ""
    Default cMsgError   := ""
    Default lUpdate     := .T.

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cPlaca)
        cMsgError := "Placa não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZV4")
    ZV4->(DbSetOrder(1))
    If ! ZV4->(DbSeek( FWxFilial("ZV4") + cPlaca ))
        cMsgError := "Placa " + cPlaca + " não localizada(ZV4)."
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZIX")
    ZIX->(DbSetOrder(1))
    If ! ZIX->( DbSeek( FWxFilial("ZIX") + cPlaca ) )
        cMsgError := "Não há caixas cadastradas para a " + cPlaca + "(ZIX)."
        RestArea(aArea)
        Return .F.

    EndIf

    cMotorista  := formMotorista(ZV4->ZV4_MOTORI)
    cPlacaFor   := formPlaca(cPlaca) //Necessário adicionar o traço, pois o SAG já estava enviando desta forma.

    oWsdl:_URL           := cUrl
    oWsdl:CDS_CODE_TRUCK := cPlacaFor
    oWsdl:CNR_PLATE      := cPlacaFor
    oWsdl:CNM_DRIVER     := cMotorista

    oWsdl:Exists()

    If ValType(oWsdl:OWSEXISTSRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSEXISTSRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Exists(Placa). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para placa " + cPlaca + " (método Exists). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    oTruck := Truck_truck():New()
    oTruck:CDS_CODE_TRUCK     := cPlacaFor
    oTruck:CNR_PLATE          := cPlacaFor
    oTruck:CNM_DRIVER         := cMotorista
    oTruck:CCD_COMPANY_UNIT   := cCodCop
    oTruck:OWSBOXES           := Truck_ArrayOfBox():New()

    While ! ZIX->(Eof()) .And. ZIX->ZIX_FILIAL == FWxFilial("ZIX") .And. Alltrim(cValToChar(ZIX->ZIX_PLACA)) == Alltrim(cValToChar(cPlaca))

        oBox := Truck_box():New()
        oBox:CNR_BOX      := cValToChar(ZIX->ZIX_NUMERO)
        oBox:CVL_CAPACITY := cValToChar(ZIX->ZIX_CAPACI)
        oBox:CVL_DENSITY  := "0" 

        Aadd(oTruck:OWSBOXES:OWSBOX , oBox)

        ZIX->(DbSkip())

    End

    Aadd(oWsdl:OWSTRUCKS:OWSTRUCK , oTruck)

    If cCodRet == "1" //Atualiza registro.

        If ! lUpdate
            RestArea(aArea)
            Return .T.

        EndIf

        cMetodo := "Update"
        oWsdl:Update()  

        If ValType(oWsdl:OWSUPDATERESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSUPDATERESULT:OWSSTATUS) < 1
            cMsgError := "WS Gemba não retornou dados do método Update(Placa). " + GetWSCError()
            RestArea(aArea)
            Return .F.

        EndIf

        cCodRet := oWsdl:OWSUPDATERESULT:OWSSTATUS[1]:CSTATUSCODE
        cErro   := oWsdl:OWSUPDATERESULT:OWSSTATUS[1]:CDESCRIPTION

    ElseIf  cCodRet == "0" // Inclui registro.
        cMetodo := "Insert"
        oWsdl:Insert()  

        If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
            cMsgError := "WS Gemba não retornou dados do método Insert(Placa). " + GetWSCError()
            RestArea(aArea)
            Return .F.

        EndIf

        cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
        cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    EndIf

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para placa " + cPlaca + " (método " + cMetodo + "). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método " + cMetodo + " para placa " + cPlaca + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    cMetodo := "Activate"
    oWsdl:Activate()

    If ValType(oWsdl:OWSACTIVATERESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSACTIVATERESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Activate(Placa)."
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSACTIVATERESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSACTIVATERESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para placa " + cPlaca + " (método " + cMetodo + "). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método " + cMetodo + " para placa " + cPlaca + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oBox)
    FreeObj(oTruck)
    FreeObj(oWsdl)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} formPlaca
    Formata placa.
    @type  Static Function
    @author Everson
    @since 13/05/2022
    @version 01
/*/
Static Function formPlaca(cPlaca)
Return Iif(At("-", cPlaca) == 0, Left(cPlaca, 3) + "-" + Right(cPlaca, 4), cPlaca)
/*/{Protheus.doc} formMotorista
    Formata motorista.
    @type  Static Function
    @author Everson
    @since 13/05/2022
    @version 01
/*/
Static Function formMotorista(cMotorista)
Return U_ADFAT50O(Substr(Iif(Empty(cMotorista), "MOTORISTA", Alltrim(cMotorista)),1,45))
/*/{Protheus.doc} User Function ADFAT50E
    Envio de ordem de pesagem para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50F(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea       := GetArea()
    Local cASMX       := "OrderLoading.asmx"
    Local cUrl        := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl       := WSOrderLoading():New()
    Local cAgrupador  := ""
    Local cPlaca      := ""
    Local oOrdem      := Nil
    Local oOrdemD     := Nil
    Local cProduto    := ""
    Local cGranjada   := ""
    Local cPeso       := ""
    Local cCodRet     := ""
    Local cErro       := ""
    Local cPlacaFor   := ""
    Local cDtCarreg   := ""

    Default cNmOrdem    := ""
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona na ordem de pesagem.
    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizada.(ZIF)(OrderLoading - envio de ordem para o Gemba)"
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(ZIF->ZIF_ROTEIR)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " sem roteiro definido."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(ZIF->ZIF_ORDRAC)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não possui ordem de carregamento de ração vinculada."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona na ordem de carregamento de ração.
    If ! U_ADFAT32G(ZIF->ZIF_ORDRAC)
        cMsgError := "Ordem de carregamento de ração " + ZIF->ZIF_ORDRAC + " não localizada(ZIR)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona o registro de granjada.
    If ! U_ADLFV22B(ZIR->ZIR_CODGRJ)
        cMsgError := "Granjada " + ZIR->ZIR_CODGRJ + " não localizada(ZIS)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no ticket de pesagem pelo número da ordem de pesagem.
    If ! U_ADFAT196(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " sem ticket de pesagem vinculado(ZIG)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida se o ticket possui pesagem inicial.
    // If ZIG->ZIG_INICIA <> "2"
    //     cMsgError := "Ticket de pesagem " + ZIG->ZIG_NUMERO + " sem pesagem inicial."
    //     RestArea(aArea)
    //     Return .F.

    // EndIf

    cPlaca     := ZIF->ZIF_PLACA

    //Valida placa no Gemba.
    If ! U_ADFAT50E(cPlaca, .F., @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    cProduto   := Alltrim(cValToChar(ZIF->ZIF_PRDSAG)) //Utilizando código do SAG, pois já está desta forma no Gemba.
    
    //Valida produto no Gemba.
    If ! U_ADFAT50K(cProduto, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida integrado no Gemba.
    If ! U_ADFAT50L(ZIF->ZIF_FORNEC, ZIF->ZIF_LJFORN, ZIF->ZIF_CLIFOR, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    cGranjada  := Alltrim(cValToChar(ZIS->ZIS_NUMERO)) //Utilizando código do SAG, pois já está desta forma no Gemba.
    
    //Valida granjada no Gemba.
    If ! U_ADFAT50M(cGranjada, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    cAgrupador := Alltrim(cValToChar(ZIF->ZIF_ROTEIR))
    cIntegrado := Alltrim(cValToChar(ZIF->ZIF_FORNEC)) + "-" + Alltrim(cValToChar(ZIF->ZIF_LJFORN)) //Formatado conforme SAG.
    cPeso      := Alltrim(cValToChar(ZIF->ZIF_QUANT))
    cPlacaFor  := formPlaca(cPlaca)
    cDtCarreg  := Month2Str(Date()) + "/" + Day2Str(Date()) + "/" + Year2Str(Date())

    oWsdl:_URL                      := cUrl
    //oWsdl:CDS_CODE_ORDER_LOADING         := cAgrupador
    oWsdl:CDS_CODE_ORDER_LOADING    := cNmOrdem //Passando a ordem como agrupador, pois o SAG já está utilizando desta forma.
    oWsdl:CNR_BILL_REQUEST          := cNmOrdem
    oWsdl:CNR_PLATE                 := cPlacaFor

    oOrdem := OrderLoading_orderLoading():New()
    oOrdem:CDS_CODE_ORDER_LOADING := cNmOrdem
    oOrdem:CDT_ORDER_LOADING      := cDtCarreg
    oOrdem:CNM_DRIVER             := formMotorista(ZV4->ZV4_MOTORI)
    oOrdem:CNR_PLATE              := cPlacaFor
    oOrdem:OWSDETails             := OrderLoading_ArrayOfOrderLoadingDetail():New()

    oOrdemD := OrderLoading_orderLoadingDetail():New()
    oOrdemD:CNR_BILL_REQUEST      := cNmOrdem
    oOrdemD:CDS_CODE_PRODUCT      := cProduto
    oOrdemD:CDS_CODE_CUSTOMER     := cIntegrado
    oOrdemD:CDS_CODE_SHED         := cGranjada
    oOrdemD:CPS_SLIDE             := cPeso

    Aadd(oOrdem:OWSDETAILS:OWSORDERLOADINGDETAIL, oOrdemD)

    Aadd(oWsdl:OWSORDERSLOADING:OWSORDERLOADING, oOrdem)

    oWsdl:Insert()  

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Ordem de Pesagem). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para ordem de pesagem " + cNmOrdem + " (método Insert). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método Insert para ordem de pesagem " + cNmOrdem + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)
    FreeObj(oOrdem)
    FreeObj(oOrdemD)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50E
    Envio de cancelamento de ordem de pesagem para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50G(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea       := GetArea()
    Local cASMX       := "OrderLoading.asmx"
    Local cUrl        := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl       := WSOrderLoading():New()

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    oWsdl:_URL             := cUrl
    oWsdl:CNR_BILL_REQUEST := cNmOrdem

    oWsdl:Delete()  

    If ValType(oWsdl:OWSDELETERESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSDELETERESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Delete(Ordem de Pesagem). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSDELETERESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSDELETERESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para ordem de pesagem " + cNmOrdem + " (método Delete). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0" .And. ! ("não existe nenhuma viagem vinculada ou já excluído" $cErro)
        cMsgError := "Erro na execução do método Delete para ordem de pesagem " + cNmOrdem + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50E
    Envio de atualização de ordem de pesagem para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50H()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.


    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT50E
    Obter dados ordem de carregamento para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50I()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.


    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT50E
    Enviar peso para o Gemba.
    @type  Function
    @author Everson
    @since 12/05/2022
    @version 01
    /*/
User Function ADFAT50J()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.


    RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function ADFAT50K
    Cadastra produto no Gemba.
    @type  Function
    @author Everson
    @since 13/05/2022
    @version 01
    /*/
User Function ADFAT50K(cProduto, cMsgError) //Cadastrando o código do produto SAG, pois o Gemba já está utilizando.

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Product.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSProduct():New()
    Local oProd     := Nil
    Local cCodRet   := ""
    Local cErro     := ""
    Local cDesProd  := ""
    Local cTpProd   := ""

    Default cProduto    := ""
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cProduto)
        cMsgError := "Produto não informado."
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT20B(cProduto)
        cMsgError := "Produto " + cProduto + " não localizado(ZIM)."
        RestArea(aArea)
        Return .F.

    EndIf

    cDesProd := Substr(Alltrim(cValToChar(ZIM->ZIM_DESSAG)),1,45)

    If Alltrim(cValToChar(ZIM->ZIM_GRPSAG)) == "MATERIA PRIMA" .Or. Alltrim(cValToChar(ZIM->ZIM_GRPSAG)) == "PREMIX"
        cTpProd := "2"
    Else
        cTpProd := "3"

    EndIf

    oWsdl:_URL             := cUrl
    oWsdl:CDS_CODE_PRODUCT := Alltrim(cValToChar(cProduto))

    oWsdl:Exists()

    If ValType(oWsdl:OWSEXISTSRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSEXISTSRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Exists(Produto). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para o produto " + cProduto + " (método Exists). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "1" //Produto já cadastrado no Gemba.
        RestArea(aArea)
        Return .T.

    EndIf

    oProd := Product_product():New()
    oProd:CDS_CODE_PRODUCT := Alltrim(cValToChar(cProduto))
    oProd:CNM_PRODUCT      := cDesProd
    oProd:CTP_PRODUCT      := cTpProd
    oProd:CCD_COMPANY_UNIT := cCodCop

    Aadd(oWsdl:OWSPRODUCTS:OWSPRODUCT, oProd)

    oWsdl:Insert()  

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Produto). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para o produto " + cProduto + " (método Insert). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método Insert para o produto " + cProduto + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)
    FreeObj(oProd)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50L
    Cadastro de integrado no Gemba.
    @type  Function
    @author Everson
    @since 13/05/2022
    @version 01
    /*/
User Function ADFAT50L(cCodigo, cLoja, cTpCliFor, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Customer.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSCustomer():New()
    Local cCodRet   := ""
    Local cErro     := ""
    Local cCodCad   := ""
    Local cNome     := ""

    Default cCodigo     := ""
    Default cLoja       := ""
    Default cTpCliFor   := ""
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cCodigo) .Or. Empty(cLoja) .Or. Empty(cTpCliFor)
        cMsgError := "Código e/ou loja e/ou tipo (cliente ou fornecedor) não informado(s)."
        RestArea(aArea)
        Return .F.

    EndIf

    If cTpCliFor == "C"

        DbSelectArea("SA1")
        SA1->(Dbsetorder(1))
        SA1->(DbGoTop())
        If ! SA1->(DbSeek( FWxFilial("SA1") + cCodigo + cLoja ))
            cMsgError := "Cliente " + cCodigo + "-" + cLoja + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        cNome := U_ADFAT50O(Substr(Alltrim(cValToChar(SA1->A1_NOME)),1,45))

    ElseIf cTpCliFor == "F"

        DbSelectArea("SA2")
        SA2->(Dbsetorder(1))
        SA2->(DbGoTop())
        If ! SA2->(DbSeek( FWxFilial("SA2") + cCodigo + cLoja ))
            cMsgError := "Fornecedor " + cCodigo + "-" + cLoja + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        cNome := U_ADFAT50O(Substr(Alltrim(cValToChar(SA2->A2_NOME)),1,45))

    EndIf

    cCodCad := cCodigo + "-" + cLoja

    oWsdl:_URL              := cUrl
    oWsdl:CDS_CODE_CUSTOMER := cCodCad

    oWsdl:Exists()

    If ValType(oWsdl:OWSEXISTSRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSEXISTSRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Exists(Customer). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para o customer " + cCodigo + "-" + cLoja + " (método Exists). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "1" //Customer já cadastrado no Gemba.
        RestArea(aArea)
        Return .T.

    EndIf

    oCustomer := Customer_customer():New()
    oCustomer:CDS_CODE_CUSTOMER := cCodCad
    oCustomer:CNM_CUSTOMER      := cNome + " - " + cCodCad
    oCustomer:CDS_EMAIL         := "N/C"
    oCustomer:CNR_PHONE         := "00000000"
    oCustomer:CCD_COMPANY_UNIT  := cCodCop

    Aadd(oWsdl:OWSCUSTOMERS:OWSCUSTOMER, oCustomer)

    oWsdl:Insert()  

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Customer). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para o customer " + cCodigo + "-" + cLoja + " (método Insert). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método Insert para o customer " + cCodigo + "-" + cLoja + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)
    FreeObj(oCustomer)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50L
    Cadastro de granjada no Gemba.
    @type  Function
    @author Everson
    @since 13/05/2022
    @version 01
    /*/
User Function ADFAT50M(cGranjada, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Shed.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSShed():New()
    Local oGranjada := Nil
    Local cCodRet   := ""
    Local cErro     := ""
    Local cCodCad   := ""
    Local cDesc     := ""
    Local cTpCliFor := ""
    Local cEnd      := ""
    Local cCidade   := ""
    Local cCodigo   := ""
    Local cLoja     := ""
    Local cUF       := ""    

    Default cGranjada   := ""
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cGranjada)
        cMsgError := "Granjada não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADLFV22B(cGranjada)
        cMsgError := "Granjada " + cGranjada + " não localizada."
        RestArea(aArea)
        Return .F.

    EndIf

    cTpCliFor := Alltrim(cValToChar(ZIS->ZIS_CLIFOR))
    cCodigo   := Alltrim(cValToChar(ZIS->ZIS_FORNEC))
    cLoja     := Alltrim(cValToChar(ZIS->ZIS_LOJA))

    If cTpCliFor == "C"

        DbSelectArea("SA1")
        SA1->(Dbsetorder(1))
        SA1->(DbGoTop())
        If ! SA1->(DbSeek( FWxFilial("SA1") + cCodigo + cLoja ))
            cMsgError := "Cliente " + cCodigo + "-" + cLoja + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        cEnd    := U_ADFAT50O(Substr(Alltrim(cValToChar(SA1->A1_END)) + ", " + Alltrim(cValToChar(SA1->A1_BAIRRO)),1,45))
        cCidade := U_ADFAT50O(Alltrim(cValToChar(SA1->A1_MUN)))
        cUF     := Alltrim(cValToChar(SA1->A1_EST))

    ElseIf cTpCliFor == "F"

        DbSelectArea("SA2")
        SA2->(Dbsetorder(1))
        SA2->(DbGoTop())
        If ! SA2->(DbSeek( FWxFilial("SA2") + cCodigo + cLoja ))
            cMsgError := "Fornecedor " + cCodigo + "-" + cLoja + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        cEnd    := U_ADFAT50O(Substr(Alltrim(cValToChar(SA2->A2_END)) + ", " + Alltrim(cValToChar(SA2->A2_BAIRRO)),1,45))
        cCidade := U_ADFAT50O(Alltrim(cValToChar(SA2->A2_MUN)))
        cUF     := Alltrim(cValToChar(SA2->A2_EST))

    EndIf

    cCodCad := cCodigo + "-" + cLoja
    cDesc   := Alltrim(cValToChar(ZIS->ZIS_DESC)) + " * "

    oWsdl:_URL := cUrl

    oGranjada := Shed_shed():New()
    oGranjada:CCD_COMPANY_UNIT  := cCodCop
    oGranjada:CDS_CODE_SHED     := cGranjada
    oGranjada:CNM_SHED          := cDesc
    oGranjada:CDS_ADDRESS       := cEnd
    oGranjada:CDS_CODE_CUSTOMER := cCodCad
    oGranjada:CNM_CITY          := cCidade
    oGranjada:CNM_COUNTRY       := "BRASIL"
    oGranjada:CSG_STATE         := "SP"

    Aadd(oWsdl:OWSSHEDS:OWSSHED, oGranjada)

    oWsdl:Insert()  

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Granjada). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := Alltrim(cValToChar(oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION))

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para a granjada " + cGranjada + " (método Insert). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0" .And. cErro <> "O valor ds_code_shed não pode repetir."
        cMsgError := "Erro na execução do método Insert para a granjada " + cGranjada + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)
    FreeObj(oGranjada)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50N
    Envia 
    @type  Function
    @author Everson
    @since 16/05/2022
    @version 01
    /*/
User Function ADFAT50N(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "LoadingDelivered.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSLoadingDelivered():New()
    Local cPeso     := ""
    Local cCodRet   := ""
    Local cErro     := ""

    Default cNmOrdem  := ""
    Default cMsgError := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona na ordem de pesagem.
    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizada(ZIF)(ADFAT50N - SetDelivered)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Posiciona no ticket de pesagem pela ordem de pesagem.
    If ! U_ADFAT196(cNmOrdem)
        cMsgError := "Ticket de pesagem referente à ordem de pesagem " + cNmOrdem + " não localizado(ZIG)(ADFAT50N - SetDelivered)."
        RestArea(aArea)
        Return .F.

    EndIf

    cAgrupador := Alltrim(cValToChar(ZIF->ZIF_ROTEIR))
    cPeso      := cValToChar(Round(ZIG->ZIG_PESOLI,2))

    oWsdl:_URL                              := cUrl
    oWsdl:OWSLOADING:CCD_COMPANY_UNIT       := cCodCop
    // oWsdl:OWSLOADING:CDS_CODE_ORDER_LOADING := cAgrupador
    oWsdl:OWSLOADING:CDS_CODE_ORDER_LOADING := cNmOrdem ////Passando a ordem como agrupador, pois o SAG já está utilizando desta forma.
    oWsdl:OWSLOADING:CNR_BILL_REQUEST       := cNmOrdem
    oWsdl:OWSLOADING:CPS_DELIVERED          := cPeso
    oWsdl:OWSLOADING:CTP_STATUS             := "0"

    oWsdl:SetDelivered()

    If ValType(oWsdl:OWSSETDELIVEREDRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSSETDELIVEREDRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método SetDelivered(Ordem de Pesagem). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSSETDELIVEREDRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := Alltrim(cValToChar(oWsdl:OWSSETDELIVEREDRESULT:OWSSTATUS[1]:CDESCRIPTION))

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para a ordem de pesagem " + cNmOrdem + " (método SetDelivered). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método SetDelivered para a ordem de pesagem " + cNmOrdem + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADFAT50
    Ponto de entrada.
    @type  User Function
    @author Everson
    @since 17/05/2022
    @version 01
/*/
User Function ADFAT50()

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
    Local lBarramento := GetMv("MV_#ADF491",,.T.) //Registros de pesagem vindos do barramento.
    
	If aParam <> Nil

		oObj 	    := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]
        nOperation  := oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS" .And. ! lBarramento

            oModelx := FWModelActive()
            cNumero := oModelx:GetValue("MD_MASTER", "ZHQ_ORDEM")

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
    @since 17/05/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C(cTbMast, 1, "retornos_de_carregamento_gemba", cOperacao, FWxFilial(cTbMast) + cNumero)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT50O
	Remove caracteres especiais da string.
	@type  User Function
	@author Everson
	@since 13/02/2022
	@version 01
	/*/
User Function ADFAT50O(cString)
	
	cString := Alltrim(cValToChar(cString))
	// cString := StrTran(cString,"\" ," ")
	// cString := StrTran(cString,Chr(34) ," ")
	// cString := StrTran(cString,Chr(39) ," ")
	// cString := StrTran(cString,Chr(40) ," ")
	// cString := StrTran(cString,Chr(41) ," ")
	// cString := StrTran(cString,Chr(47) ," ")
	// cString := StrTran(cString,Chr(91) ," ")
	// cString := StrTran(cString,Chr(92) ," ")
	// cString := StrTran(cString,Chr(93) ," ")
	// cString := StrTran(cString,Chr(96) ," ")
	// cString := StrTran(cString,Chr(125)," ")
	// cString := StrTran(cString,Chr(123)," ")
	// cString := StrTran(cString,Chr(145)," ")
	// cString := StrTran(cString,Chr(146)," ")
	// cString := StrTran(cString,Chr(147)," ")
	// cString := StrTran(cString,Chr(148)," ")	
	cString	:= StrTran(cString,Chr(129)," ")
	cString	:= StrTran(cString,Chr(141)," ")
	cString	:= StrTran(cString,Chr(143)," ")
	cString	:= StrTran(cString,Chr(144)," ")
	cString	:= StrTran(cString,Chr(157)," ")
	cString	:= StrTran(cString,Chr(9)  ," ")
	cString	:= StrTran(cString,Chr(10) ," ")
	cString	:= StrTran(cString,Chr(13) ," ")
	
	cString := FwCutOff(cString,.T.)

Return cString
/*/{Protheus.doc} ADFAT50P
	Envio de ordem de pesagem para descarga.
	@type  User Function
	@author Everson
	@since 19/07/2022
	@version 01
/*/
User Function ADFAT50P(cNmOrdem, nPeso, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "OrderReceiving.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSOrderReceiving():New()
    Local cFornece  := "" 
    Local cLoja     := ""
    Local cPrdSAG   := ""
    Local cPlaca    := ""
    Local cNFSer    := ""
    Local cQtdOrd   := ""
    Local cTpEmb    := ""
    Local cMetodo   := "Insert"

    Default cNmOrdem    := ""
    Default nPeso       := 0
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    If nPeso <= 0
        cMsgError := "Peso da ordem não informado."
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem não localizada(ZIF)(Get - dados de carregamento do Gemba)."
        RestArea(aArea)
        Return .F.

    EndIf

    cFornece := ZIF->ZIF_FORNEC
    cLoja    := ZIF->ZIF_LJFORN
    cPrdSAG  := Alltrim(cValToChar(ZIF->ZIF_PRDSAG))
    cPlaca   := Alltrim(cValToChar(ZIF->ZIF_PLACA))
    cNFSer   := Alltrim(cValToChar(ZIF->ZIF_NF)) + Alltrim(cValToChar(ZIF->ZIF_SERIE))
    cQtdOrd  := cValToChar(Round(Val(cValToChar(ZIF->ZIF_QUANT)),0))

    //Posiciona no produto SAG.
    If ! U_ADFAT20B(cPrdSAG)
        cMsgError := "Produto " + cPrdSAG + " não localizado(ZIM)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida tipo de embalagem.
    cTpEmb := ZIM->ZIM_TPEMB

    If Empty(cTpEmb)
        cMsgError := "Produto " + cPrdSAG + " sem tipo de embalagem definido(ZIM_TPEMB-ZIM)."
        RestArea(aArea)
        Return .F.

    EndIf

    //Valida produto no Gemba.
    If ! U_ADFAT50K(cPrdSAG, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    ZI8->(DbGoTop())
    If ! ZI8->( DbSeek( FWxFilial("ZI8") + ZIF->ZIF_LOTE))
        cMsgError := "Lote " + ZIF->ZIF_LOTE + " não localizado(ZI8)."
        RestArea(aArea)
        Return .F.

    EndIf 

    cLote := Alltrim(cValToChar(ZI8->ZI8_DESLOT))

    //Cadastro de fornecedor.
    If ! U_ADFAT50Q(cFornece, cLoja, @cMsgError)
        RestArea(aArea)
        Return .F.

    EndIf

    oWsdl:_URL               := cUrl
    oWsdl:CCD_COMPANY_UNIT   := cCodCop
    oWsdl:CDS_CODE_RECEIVING := cNmOrdem

    oOrder := OrderReceiving_orderReceiving():New()
    oOrder:CCD_COMPANY_UNIT     := cCodCop
    oOrder:CDS_CODE_PRODUCT     := cPrdSAG
    oOrder:CDS_CODE_RECEIVING   := cNmOrdem
    oOrder:CDS_CODE_SUPPLIER    := cFornece+cLoja
    oOrder:CDS_OBSERVATION      := ""
    oOrder:CDT_MANUFACTURE      := Month2Str(Date()) + "/" + Day2Str(Date()) + "/" + Year2Str(Date())
    oOrder:CDT_VALIDITY         := Month2Str(Date()+30) + "/" + Day2Str(Date()+30) + "/" + Year2Str(Date()+30)
    oOrder:CNM_DRIVER           := "MOTORISTA"
    oOrder:CNR_LOT              := cLote
    oOrder:CNR_PLATE            := cPlaca
    oOrder:CPS_BRUTE_QUANTITY   := cValToChar(nPeso)
    oOrder:CPS_NOMINAL_QUANTITY := cQtdOrd
    oOrder:CTP_PRODUCT_RECEIVING:= cTpEmb
    oOrder:CVL_DOCUMENT_NUMBER  := cNFSer

    Aadd(oWsdl:OWSORDERSRECEIVING:OWSORDERRECEIVING , oOrder)

    oWsdl:Insert()

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Ordem de pesagem " + cNmOrdem + "). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para ordem de pesagem " + cNmOrdem + " (método " + cMetodo + "). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método " + cMetodo + " para ordem de pesagem " + cNmOrdem + ". " + cErro + " " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oOrder)
    FreeObj(oWsdl)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADFAT50P
	Envio de ordem de pesagem final de descarga.
	@type  User Function
	@author Everson
	@since 19/07/2022
	@version 01
/*/
User Function ADFAT50R(cNmOrdem, nPeso, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "OrderReceiving.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSOrderReceiving():New()
    Local cMetodo   := "SetTareWeight"

    Default cNmOrdem    := ""
    Default nPeso       := 0
    Default cMsgError   := ""

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cNmOrdem)
        cMsgError := "Ordem de pesagem não informada."
        RestArea(aArea)
        Return .F.

    EndIf

    If nPeso <= 0
        cMsgError := "Peso da ordem não informado."
        RestArea(aArea)
        Return .F.

    EndIf

    If ! U_ADFAT16A(cNmOrdem)
        cMsgError := "Ordem de pesagem não localizada(ZIF)(Get - dados de carregamento do Gemba)."
        RestArea(aArea)
        Return .F.

    EndIf

    oWsdl:_URL               := cUrl
    oWsdl:CCD_COMPANY_UNIT   := cCodCop
    oWsdl:CDS_CODE_RECEIVING := cNmOrdem
    oWsdl:CPS_TARE_QUANTITY  := cValToChar(nPeso)

    oWsdl:SetTareWeight()

    If ValType(oWsdl:OWSSETTAREWEIGHTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSSETTAREWEIGHTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método SetTareWeight(Ordem de pesagem " + cNmOrdem + "). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSSETTAREWEIGHTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSSETTAREWEIGHTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para ordem de pesagem " + cNmOrdem + " (método " + cMetodo + "). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método " + cMetodo + " para ordem de pesagem " + cNmOrdem + ". " + cErro + " " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oWsdl)

    RestArea(aArea)

Return .T.
/*/{Protheus.doc} User Function ADFAT50E
    Envio de cadastro de fornecedor para o Gemba.
    @type  Function
    @author Everson
    @since 19/07/2022
    @version 01
/*/
User Function ADFAT50Q(cFornece, cLoja, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local cASMX     := "Supplier.asmx"
    Local cUrl      := GetMv("MV_#GEMBA",,"http://186.224.100.105:48884/WsGemba/" + cASMX)
    Local oWsdl     := WSSupplier():New()
    Local oFornec   := Nil
    Local cMetodo   := "Insert"
    Local cCodRet   := ""
    Local cErro     := ""

    Local cEndereco := ""
    Local cCidade   := ""
    Local cCep      := ""
    Local cTelefone := ""
    Local cEst      := ""

    Default cFornece    := ""
    Default cLoja       := ""
    Default cMsgError   := ""
    Default lUpdate     := .T.

    If Empty(cUrl)
        cMsgError := "URL não definida."
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cFornece) .Or. Empty(cLoja)
        cMsgError := "Código de fornecedor e/ou loja não informados."
        RestArea(aArea)
        Return .F.

    EndIf

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    If ! SA2->(DbSeek( FWxFilial("SA2") + cFornece + cLoja ))
        cMsgError := "Fornecedor " + cFornece + cLoja + " não localizado(SA2)."
        RestArea(aArea)
        Return .F.

    EndIf

    oWsdl:_URL              := cUrl
    oWsdl:CDS_CODE_SUPPLIER := cFornece+cLoja

    oWsdl:Exists()

    If ValType(oWsdl:OWSEXISTSRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSEXISTSRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Exists(Fornecedor " + cFornece + cLoja + "). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSEXISTSRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para fornecedor " + cFornece + cLoja + " (método Exists). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "1"
        FreeObj(oWsdl)
        RestArea(aArea)
        Return .T.

    EndIf

    cEndereco := U_ADFAT50O(Substr(Alltrim(SA2->A2_END) + "," + Alltrim(SA2->A2_BAIRRO),1,50))
    cCidade   := U_ADFAT50O(Substr(Alltrim(SA2->A2_MUN),1,50))
    cCep      := U_ADFAT50O(Substr(Alltrim(cValToChar(SA2->A2_CEP)),1,10))
    cTelefone := U_ADFAT50O(Substr(Alltrim(cValToChar(SA2->A2_DDD)) + Alltrim(cValToChar(SA2->A2_TEL)) ,1,15))
    cEst      := U_ADFAT50O(Substr(Alltrim(cValToChar(SA2->A2_EST)),1,2))

    oFornec := Supplier_supplier():New()
    oFornec:CCD_COMPANY_UNIT  := cCodCop
    oFornec:CDS_ADDRESS       := Iif(Empty(cEndereco), "NC", cEndereco)
    oFornec:CDS_CODE_SUPPLIER := cFornece+cLoja
    
    If SA2->A2_TIPO == "J"
        oFornec:CDS_CNPJ := U_ADFAT50O(Alltrim(cValToChar(SA2->A2_CGC)))
        oFornec:CDS_CPF  := ""
    Else
        oFornec:CDS_CPF  := U_ADFAT50O(Alltrim(cValToChar(SA2->A2_CGC)))
        oFornec:CDS_CNPJ := ""

    EndIf
    
    oFornec:CDS_EMAIL    := Substr(Alltrim(cValToChar(SA2->A2_EMAIL)),1,50)
    oFornec:CNM_CITY     := Iif(Empty(cCidade),"NC", cCidade)
    oFornec:CNM_COUNTRY  := "BRASIL"
    oFornec:CNM_SUPPLIER := Substr(Alltrim(cValToChar(SA2->A2_NOME)),1,60) + " " + cFornece+cLoja
    oFornec:CNR_CEP      := Iif(Empty(cCep), "00000000" , cCep)
    oFornec:CNR_PHONE    := cTelefone
    oFornec:CSG_STATE    := Iif(Empty(cEst), "NC", cEst) 

    Aadd(oWsdl:OWSSUPPLIERS:OWSSUPPLIER , oFornec)

    oWsdl:Insert()  

    If ValType(oWsdl:OWSINSERTRESULT:OWSSTATUS) <> "A" .Or. Len(oWsdl:OWSINSERTRESULT:OWSSTATUS) < 1
        cMsgError := "WS Gemba não retornou dados do método Insert(Fornecedor " + cFornece + cLoja + "). " + GetWSCError()
        RestArea(aArea)
        Return .F.

    EndIf

    cCodRet := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CSTATUSCODE
    cErro   := oWsdl:OWSINSERTRESULT:OWSSTATUS[1]:CDESCRIPTION

    If ! (cCodRet $"0/1")
        cMsgError := "Gemba retornou código inexistente " + cCodRet + " para fornecedor " + cFornece + cLoja + " (método " + cMetodo + "). " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    If cCodRet == "0"
        cMsgError := "Erro na execução do método " + cMetodo + " para fornecedor " + cFornece + cLoja + ". " + cErro
        RestArea(aArea)
        Return .F.

    EndIf

    FreeObj(oFornec)
    FreeObj(oWsdl)

    RestArea(aArea)

Return .T.
