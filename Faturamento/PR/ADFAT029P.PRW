#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

Static xPula :=  Chr(13) + Chr(10) 

/*/{Protheus.doc} ADFAT029P
    Job para processamento de registros recebidos do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
User Function ADFAT029P() // U_ADFAT029P()

    //Variáveis.
    // Local cEmp := ""
    // Local cFil := ""

	RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })

        //U_StartJob("U_ADFAT29A",getenvserver(),.T.,cEmp, cFil)
        U_ADFAT29A()

    RpcClearEnv()

Return Nil
/*/{Protheus.doc} ADFAT29A
    Executa processamento pendente.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
User Function ADFAT29A(Emp, Fil)

    //Variáveis.

	//RPCSetType(3)
	//RpcSetEnv("01","02",,,,GetEnvServer(),{ })
    
        ADFAT29B()
        
    //RpcClearEnv()

Return Nil
/*/{Protheus.doc} ADFAT29B
    Processa registros do cadastro de produtos SAG.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
User Function ADFAT29B()

    //Variáveis.
    Local aArea     := GetArea()
    Local cAliasAux := GetNextAlias()
    Local cQuery    := ""
    Local aError    := {}
    Local cMsgError := ""
    Local cJson     := ""
    Local oJson     := Nil
    Local cId     := ""
    Local cProdSAG  := ""
    Local cDescSAG  := ""
    Local cProdProt := ""
    Local cDescProt := ""
    Local oModel    := Nil

    cQuery += " SELECT  " 
    cQuery += " ZIQ_UUID, "
    cQuery += " ZIQ_OPERAC, "
    cQuery += " R_E_C_N_O_ AS RECNO "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIQ") + " (NOLOCK) AS ZIQ  " 
    cQuery += " WHERE  " 
    cQuery += " ZIQ_FILIAL = '" + FWxFilial("ZIM") + "'  " 
    cQuery += " AND ZIQ_TIPO = 'E' " 
    cQuery += " AND ZIQ_TOPICO = 'cadastro_de_produtos_sag' " 
    cQuery += " AND ZIQ_SISGER = 'SAG' " 
    cQuery += " AND ZIQ_PROCES = '2' " 
    cQuery += " AND ZIQ.D_E_L_E_T_ = '' " 

    DbSelectArea("ZIM")
    ZIM->(DbSetOrder(1))
    ZIM->(DbGoTop())

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAux, .F., .T.)
    (cAliasAux)->(DbGoTop())

    While ! (cAliasAux)->(Eof())

        ZIQ->(DbGoto((cAliasAux)->RECNO))
        
        cJson := ZIQ->ZIQ_DADOS
        oJson := getJson(cJson)

        If ValType(oJson) == "U"
            cMsgError := "Não foi possível converter a string para objeto json."
            U_ADFAT29D(cId, "2", cMsgError)
            Help(Nil, Nil, "Função ADFAT29B(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            (cAliasAux)->(DbSkip())
            Loop

        EndIf

        cId       := Alltrim(cValToChar(ZIQ->ZIQ_UUID))
        cProdSAG  := Alltrim(cValToChar(oJson['dados']['codSAG']))
        cDescSAG  := Alltrim(cValToChar(oJson['dados']['descSAG']))
        cProdProt := Alltrim(cValToChar(oJson['dados']['prdProth']))
        cDescProt := Posicione("SB1", 1, FWxFilial("SB1") + cProdProt, "B1_DESC")

        
        If ! ZIM->(DbSeek( FWxFilial("ZIM") + cProdSAG ))

            If (cAliasAux)->ZIQ_OPERAC == "A" .Or. (cAliasAux)->ZIQ_OPERAC == "D"
                cMsgError := "Não foi possível localizar o produto " + cProdSAG + "."
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29B(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cAliasAux)->(DbSkip())
                Loop

            EndIf

        Else

            If (cAliasAux)->ZIQ_OPERAC == "I"
                cMsgError := "Produto já existe no protheus " + cProdSAG + "."
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29B(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cAliasAux)->(DbSkip())
                Loop

            EndIf

        EndIf

        Begin Transaction

            oModel := FwLoadModel("ADFAT020P")

            If (cAliasAux)->ZIQ_OPERAC == "I"
                oModel:SetOperation(MODEL_OPERATION_INSERT)

            ElseIf (cAliasAux)->ZIQ_OPERAC == "A"
                oModel:SetOperation(MODEL_OPERATION_UPDATE)

            ElseIf (cAliasAux)->ZIQ_OPERAC == "D"
                oModel:SetOperation(MODEL_OPERATION_DELETE)

            Else
                cMsgError := "Operação não definida"
                DisarmTransaction()
                Break

            EndIf

            oModel:Activate()

            If (cAliasAux)->ZIQ_OPERAC == "I" .Or. (cAliasAux)->ZIQ_OPERAC == "A"
                oModel:SetValue("MD_MASTER", "ZIM_PRDSAG", cProdSAG)
                oModel:SetValue("MD_MASTER", "ZIM_DESSAG", cDescSAG)
                oModel:SetValue("MD_MASTER", "ZIM_PRDPRO", cProdProt)
                oModel:SetValue("MD_MASTER", "ZIM_DESCPR", cDescProt)

            EndIf

            If oModel:VldData()
                oModel:CommitData()

            Else
                aError := oModel:GetErrorMessage()
                cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

            EndIf

            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

            If ! Empty(cMsgError)
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29B(ADFAT027P)", Nil, "Erro no processamento de registro de produto SAG x Protheus " + cId + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            Else
                U_ADFAT29D(cId, "1", "")

            EndIf

        End Transaction

        FreeObj(oJson)
        oJson := Nil

        (cAliasAux)->(DbSkip())

    End

    (cAliasAux)->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT29C
    Processa registros de lote de produtos SAG.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
User Function ADFAT29C()

    //Variáveis.
    Local aArea     := GetArea()
    Local cAliasAux := GetNextAlias()
    Local cQuery    := ""
    Local aError    := {}
    Local cMsgError := ""
    Local cJson     := ""
    Local oJson     := Nil
    Local cId       := ""
    Local cCdLote   := ""
    Local cDesLote  := ""
    Local cCodProt  := ""
    Local cProdSAG  := ""
    Local cStatus   := ""
    Local cDtIni    := ""
    Local cDtFim    := ""
    Local cAuto     := ""
    Local nSaldo    := 0
    Local nCusto    := 0
    Local oModel    := Nil
    //Local aEmpFil   := deParaSAG(cEmpAnt, cFilAnt)

    cQuery += " SELECT  " 
    cQuery += " ZIQ_UUID, "
    cQuery += " ZIQ_OPERAC, "
    cQuery += " R_E_C_N_O_ AS RECNO "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZIQ") + " (NOLOCK) AS ZIQ  " 
    cQuery += " WHERE  " 
    cQuery += " ZIQ_FILIAL = '" + FWxFilial("ZIM") + "'  " 
    cQuery += " AND ZIQ_TIPO = 'E' " 
    cQuery += " AND ZIQ_TOPICO = 'cadastro_de_lotes_de_produtos_sag' " 
    cQuery += " AND ZIQ_PROCES = '2' " 
    cQuery += " AND ZIQ_SISGER = 'SAG' " 
    cQuery += " AND ZIQ_EMPRES = '" + aEmpFil[1][1] + "' " 
    cQuery += " AND ZIQ_FILINT = '" + aEmpFil[1][2] + "' " 
    cQuery += " AND ZIQ.D_E_L_E_T_ = '' " 

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    ZI8->(DbGoTop())

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAux, .F., .T.)
    (cAliasAux)->(DbGoTop())

    While ! (cAliasAux)->(Eof())

        ZIQ->(DbGoto((cAliasAux)->RECNO))
        
        cJson := ZIQ->ZIQ_DADOS
        oJson := getJson(cJson)

        If ValType(oJson) == "U"
            cMsgError := "Não foi possível converter a string para objeto json."
            U_ADFAT29D(cId, "2", cMsgError)
            Help(Nil, Nil, "Função ADFAT29C(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            (cAliasAux)->(DbSkip())
            Loop

        EndIf

        cId      := Alltrim(cValToChar(ZIQ->ZIQ_UUID))
        cCdLote  := Alltrim(cValToChar(oJson['dados']['codigoLote']))
        cDesLote := Alltrim(cValToChar(oJson['dados']['nomeLote']))
        cProdSAG := Alltrim(cValToChar(oJson['dados']['codSAG']))
        cCodProt := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + cProdSAG, "ZIM_PRDPRO")))
        cStatus  := Alltrim(cValToChar(oJson['dados']['status']))
        cDtIni   := Alltrim(cValToChar(oJson['dados']['dataInicial']))
        cDtFim   := Alltrim(cValToChar(oJson['dados']['dataFinal']))
        cAuto    := Alltrim(cValToChar(oJson['dados']['automatico']))
        nSaldo   := Val(cValToChar(oJson['dados']['saldo']))
        nCusto   := Val(cValToChar(oJson['dados']['custo']))

        If ! ZI8->(DbSeek( FWxFilial("ZI8") + cCdLote ))

            If (cAliasAux)->ZIQ_OPERAC == "A" .Or. (cAliasAux)->ZIQ_OPERAC == "D"
                cMsgError := "Não foi possível localizar o lote " + cDesLote + "."
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29C(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cAliasAux)->(DbSkip())
                Loop

            EndIf

        Else

            If (cAliasAux)->ZIQ_OPERAC == "I"
                cMsgError := "Lote já existe no protheus " + cDesLote + "."
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29C(ADFAT027P)", Nil, cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cAliasAux)->(DbSkip())
                Loop

            EndIf

        EndIf

        Begin Transaction

            oModel := FwLoadModel("ADFAT018P")

            If (cAliasAux)->ZIQ_OPERAC == "I"
                oModel:SetOperation(MODEL_OPERATION_INSERT)

            ElseIf (cAliasAux)->ZIQ_OPERAC == "A"
                oModel:SetOperation(MODEL_OPERATION_UPDATE)

            ElseIf (cAliasAux)->ZIQ_OPERAC == "D"
                oModel:SetOperation(MODEL_OPERATION_DELETE)

            Else
                cMsgError := "Operação não definida"
                DisarmTransaction()
                Break

            EndIf

            oModel:Activate()

            If (cAliasAux)->ZIQ_OPERAC == "I" .Or. (cAliasAux)->ZIQ_OPERAC == "A"
                oModel:SetValue("MD_MASTER", "ZI8_FILIAL", FWxFilial("ZI8"))
                oModel:SetValue("MD_MASTER", "ZI8_CDLOTE", cCdLote)
                oModel:SetValue("MD_MASTER", "ZI8_DESLOT", cDesLote)
                oModel:SetValue("MD_MASTER", "ZI8_PRDPRT", cCodProt)
                oModel:SetValue("MD_MASTER", "ZI8_PRDSAG", cProdSAG)
                oModel:SetValue("MD_MASTER", "ZI8_STATUS", cStatus)
                oModel:SetValue("MD_MASTER", "ZI8_DTINIC", SToD(cDtIni))

                If ! Empty(cDtFim)
                    oModel:SetValue("MD_MASTER", "ZI8_DTFINA", SToD(cDtFim))

                EndIf

                oModel:SetValue("MD_MASTER", "ZI8_LAUTO", cAuto)
                oModel:SetValue("MD_MASTER", "ZI8_LTSALD", nSaldo)
                oModel:SetValue("MD_MASTER", "ZI8_LTCUST", nCusto)

            EndIf

            If oModel:VldData()
                oModel:CommitData()

            Else
                aError := oModel:GetErrorMessage()
                cMsgError := Alltrim(cValToChar(aError[MODEL_MSGERR_MESSAGE]))

            EndIf

            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

            If ! Empty(cMsgError)
                U_ADFAT29D(cId, "2", cMsgError)
                Help(Nil, Nil, "Função ADFAT29C(ADFAT027P)", Nil, "Erro no processamento de registro de lote de produto SAG " + cId + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            Else
                U_ADFAT29D(cId, "1", "")

            EndIf

        End Transaction

        (cAliasAux)->(DbSkip())

    End

    (cAliasAux)->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getJson
    Processa registros de lote de produtos SAG.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
Static Function getJson(cJson)

    //Variáveis.
    Local oJson := JsonObject():New()
    Local xRet  := oJson:FromJson(cJson)

    If ! ValType(xRet) == "U"
        Return Nil

    EndIf

Return oJson
/*/{Protheus.doc} ADFAT29D
    Salva resultado do processamento no registro do barramento.
    Chamado 18465.
    @type  User Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
User Function ADFAT29D(cId, cResult, cObserv, cMsgError)

    //Variáveis.
    Local aArea     := GetArea()
    Local oModel    := Nil
    Local lRet      := .F.
    Local aError    := {}
    
    Default cMsgError := ""

    DbSelectArea("ZIQ")
    ZIQ->(DbSetOrder(1))
    If ! ZIQ->(DbSeek( FWxFilial("ZIQ") + cId ))
        cMsgError := "ADFAT29D - Id não encontrado " + cId
        U_GrLogZBE (;
            Date(),;
            Time(),;
            cUserName,;
            "ADFAT29D - Id não encontrado " + cId,;
            "FATURAMENTO",;
            "ADFAT029P",;
            cId,;
            ComputerName(),;
            LogUserName();
        )

        RestArea(aArea)
        Return Nil

    EndIf

    oModel := FwLoadModel("ADFAT027P")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)

    oModel:Activate()

    oModel:SetValue("MD_MASTER", "ZIQ_PROCES", "1")
    oModel:SetValue("MD_MASTER", "ZIQ_DTPROC", Date())
    oModel:SetValue("MD_MASTER", "ZIQ_HRPROC", Time())
    oModel:SetValue("MD_MASTER", "ZIQ_STATPR", cResult)
    oModel:SetValue("MD_MASTER", "ZIQ_OBS", cObserv)

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
        Help(Nil, Nil, "Função ADFAT29D(ADFAT029P)", Nil, "Erro na atualização de registro de barramento " + cId + "." + xPula + cMsgError, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} deParaSAG
    Executa de para de empresa filial SAG x Protheus.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 08/02/2022
    @version 01
    /*/
Static Function deParaSAG(cEmp, cFil)

    //Variáveis.
    Local aRet := {}

    //Empresa Ad'oro.
    If cEmp == "01" .And. cFil == "03"
        Aadd(aRet,{"E01", "E01"})

    ElseIf cEmp == "01" .And. cFil == "05"
        Aadd(aRet,{"E02", "E02"})

    EndIf

Return aRet
