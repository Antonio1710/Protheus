#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"
#Include "Apwebsrv.ch"

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
    Processa registros de carregamento Gemba.
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
            
        Aadd(aRecAtu, {D_GEMBA->REC, lRet, cMsgError})

        D_GEMBA->(DbSkip())

    End
    D_GEMBA->(DbCloseArea())

    If Len(aRecAtu) > 0
        atuPeGue(aRecAtu)

    EndIf

    RestArea(aArea)

Return Nil
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
User Function ADFAT50D()

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .F.


    RestArea(aArea)

Return lRet
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
        cMsgError := "WS Gemba não retornou dados do método Exists(Placa)."
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
Return rmvAcento(Substr(Iif(Empty(cMotorista), "MOTORISTA", Alltrim(cMotorista)),1,45))
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
        cMsgError := "Ordem de pesagem " + cNmOrdem + " não localizada."
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
    If ZIG->ZIG_INICIA <> "2"
        cMsgError := "Ticket de pesagem " + ZIG->ZIG_NUMERO + " sem pesagem inicial."
        RestArea(aArea)
        Return .F.

    EndIf

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
    //oWsdl:CNR_BILL_REQUEST          := cAgrupador
    oWsdl:CNR_BILL_REQUEST          := cNmOrdem //Passando a ordem como agrupador, pois o SAG já está utilizando desta forma.
    oWsdl:CDS_CODE_ORDER_LOADING    := cNmOrdem
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
    oWsdl:CNR_BILL_REQUEST   := cNmOrdem

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

    If cCodRet == "0"
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

        cNome := rmvAcento(Substr(Alltrim(cValToChar(SA1->A1_NOME)),1,45))

    ElseIf cTpCliFor == "F"

        DbSelectArea("SA2")
        SA2->(Dbsetorder(1))
        SA2->(DbGoTop())
        If ! SA2->(DbSeek( FWxFilial("SA2") + cCodigo + cLoja ))
            cMsgError := "Fornecedor " + cCodigo + "-" + cLoja + " não localizado."
            RestArea(aArea)
            Return .F.

        EndIf

        cNome := rmvAcento(Substr(Alltrim(cValToChar(SA2->A2_NOME)),1,45))

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

    cTpCliFor := Alltrim(cValToChar(ZIS->ZIS_TIPO))
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

        cEnd    := rmvAcento(Substr(Alltrim(cValToChar(SA1->A1_END)) + ", " + Alltrim(cValToChar(SA1->A1_BAIRRO)),1,45))
        cCidade := rmvAcento(Alltrim(cValToChar(SA1->A1_MUN)))
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

        cEnd    := rmvAcento(Substr(Alltrim(cValToChar(SA2->A2_END)) + ", " + Alltrim(cValToChar(SA2->A2_BAIRRO)),1,45))
        cCidade := rmvAcento(Alltrim(cValToChar(SA2->A2_MUN)))
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
/*/{Protheus.doc} rmvAcento
	Remove caracteres especiais da string.
	@type  Static Function
	@author Everson
	@since 13/02/2022
	@version 01
	/*/
Static Function rmvAcento(cString)
	
	cString := Alltrim(cValToChar(cString))
	cString := StrTran(cString,"\" ," ")
	cString := StrTran(cString,Chr(34) ," ")
	cString := StrTran(cString,Chr(39) ," ")
	cString := StrTran(cString,Chr(40) ," ")
	cString := StrTran(cString,Chr(41) ," ")
	cString := StrTran(cString,Chr(47) ," ")
	cString := StrTran(cString,Chr(91) ," ")
	cString := StrTran(cString,Chr(92) ," ")
	cString := StrTran(cString,Chr(93) ," ")
	cString := StrTran(cString,Chr(96) ," ")
	cString := StrTran(cString,Chr(125)," ")
	cString := StrTran(cString,Chr(123)," ")
	cString := StrTran(cString,Chr(145)," ")
	cString := StrTran(cString,Chr(146)," ")
	cString := StrTran(cString,Chr(147)," ")
	cString := StrTran(cString,Chr(148)," ")	
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
