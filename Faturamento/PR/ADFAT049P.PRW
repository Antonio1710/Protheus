#INCLUDE "protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADFAT049P
    Job para obter os registros de carregamento do Gemba.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT049P() // U_ADFAT049P()


    RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })

        U_ADFAT491()

	RpcClearEnv()

Return Nil
/*/{Protheus.doc} User Function ADFAT491
    Processa obtenção dos registros de carregamento do Gemba.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT491(cNmOrdem, cMsgError)

    //Variáveis.
    Local aArea       := GetArea()
    Local lBarramento := GetMv("MV_#ADF491",,.T.) //Registros de pesagem vindos do barramento.
    Local cQuery      := ""
    Local cPreFx      := "Envio OP: "
    Local nPeso       := 0

    Default cNmOrdem   := ""
    Default cMsgError  := ""

    cNmOrdem := Alltrim(cValToChar(cNmOrdem))
    
    If lBarramento
        U_ADFAT29J()
    
    Else

        cQuery += " SELECT  "
            cQuery += " DISTINCT ZIF_NUMERO, ZIG_INICIA, ZIF_GEMBA, "
            cQuery += " CASE WHEN (ZIT_ORDEM IS NULL OR ZIT_ORDEM = '') THEN '1' ELSE '0' END AS LACRE, "
            cQuery += " ZIG_TPMOV, ZIG_PESINI, ZIG_PESFIM, ZIF_AGRUPA, ZIG_NUMERO "
        cQuery += " FROM "

            cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF "
            cQuery += " INNER JOIN "
            cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON "
            cQuery += " ZIF_FILIAL = ZIG_FILIAL "
            cQuery += " AND ( ZIF_NUMERO = ZIG_ORDEM OR ZIF_AGRUPA = ZIG_ORDEM )"
            cQuery += " AND ZIG_ORDEM <> '' "
            cQuery += " INNER JOIN "
            cQuery += " " + RetSqlName("ZIB") + " (NOLOCK) AS ZIB ON "
            cQuery += " ZIF_FILIAL = ZIB_FILIAL "
            cQuery += " AND ZIF_CTPATI = ZIB_NUMERO "
            cQuery += " LEFT OUTER JOIN "
            cQuery += " " + RetSqlName("ZIT") + " (NOLOCK) AS ZIT ON "
            cQuery += " ZIF_FILIAL = ZIT_FILIAL "
            cQuery += " AND ZIF_NUMERO = ZIT_ORDEM "
            cQuery += " AND ZIT.D_E_L_E_T_ = '' "

        cQuery += " WHERE "
            cQuery += " ZIF_FILIAL = '" + FwxFilial("ZIF") + "' "
            cQuery += " AND ZIG_TPMOV IN ('R','E') " //Ordem de ração e entrada.
            cQuery += " AND ( (ZIG_INICIA IN ('1','2','4') OR (ZIG_INICIA = '5' AND ZIG_TPMOV = 'E') ) OR (ZIG_INICIA = '3' AND ZIF_GEMBA = '1' ) ) "
            cQuery += " AND ZIB_STATUS NOT IN ('6') "

            If ! Empty(cNmOrdem)
                cQuery += " AND ZIF_NUMERO = '" + cNmOrdem + "' "

            EndIf

            cQuery += " AND ZIF.D_E_L_E_T_ = '' "
            cQuery += " AND ZIG.D_E_L_E_T_ = '' "
            cQuery += " AND ZIB.D_E_L_E_T_ = '' "

        cQuery += " ORDER BY  ZIG_TPMOV, ZIF_NUMERO "

        If Select("D_DADOS") > 0
            D_DADOS->(DbCloseArea())

        EndIf

        TcQuery cQuery New Alias "D_DADOS"
        DbSelectArea("D_DADOS")
        D_DADOS->(DbGoTop())

        While ! D_DADOS->(Eof())

            nPeso     := 0
            cMsgError := ""

            If D_DADOS->ZIG_TPMOV == "R" //Processamento de ordem de ração.

                If D_DADOS->ZIF_GEMBA == "1" .And. D_DADOS->ZIG_INICIA <> "3" .And. D_DADOS->LACRE == "1" //Ordem enviada, peso não fechado e lacre não lançado.

                    If ! U_ADFAT50D(D_DADOS->ZIF_NUMERO, @cMsgError)
                        
                        // If Alltrim(cValToChar(cMsgError)) <> "WS Gemba não retornou dados do método Get(Ordem de Pesagem)."
                            U_ADFAT173("Obter lacres : " + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA")

                        // EndIf

                    Else
                        U_ADFAT173("Obter lacres : sucesso " , D_DADOS->ZIF_NUMERO, "", "GEMBA")

                    EndIf

                ElseIf D_DADOS->ZIF_GEMBA == "1" .And. D_DADOS->ZIG_INICIA == "3" .And. D_DADOS->LACRE == "0" //Ordem enviada, peso fechado e lacre lançado.

                    //Envia a pesagem final para o Gemba.
                    If ! U_ADFAT50N(D_DADOS->ZIF_NUMERO, @cMsgError) 
                        U_ADFAT173("Envio de pesagem final: " + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA")

                    Else

                        U_ADFAT165(D_DADOS->ZIF_NUMERO, "ZIF_GEMBA", "3") //Marca ordem como enviada.

                        U_ADFAT173("Envio de pesagem final: sucesso ", D_DADOS->ZIF_NUMERO, "", "GEMBA")

                    EndIf

                ElseIf D_DADOS->ZIF_GEMBA == "2" //Ordem não enviada.

                    If ! U_ADFAT50F(D_DADOS->ZIF_NUMERO, @cMsgError) //Envio de ordem para o Gemba.

                        U_ADFAT173(cPreFx + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de erro.

                    Else

                        U_ADFAT165(D_DADOS->ZIF_NUMERO, "ZIF_GEMBA", "1") //Marca ordem como enviada.
            
                        U_ADFAT173(cPreFx + "enviada com sucesso.", D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de sucesso.

                    EndIf

                EndIf

            ElseIf D_DADOS->ZIG_TPMOV == "E" //Processamento de ordem de entrada.

                If D_DADOS->ZIF_GEMBA == "2" .And. D_DADOS->ZIG_INICIA == "2" //Ordem não enviada com pesagem inicial.

                    If Empty(D_DADOS->ZIF_AGRUPA)
                        nPeso := D_DADOS->ZIG_PESINI

                    Else

                        //Obtém peso proportional para ordens agrupadas.
                        If ! U_ADFAT492(D_DADOS->ZIF_AGRUPA, D_DADOS->ZIF_NUMERO, 1, @nPeso, @cMsgError)
                            U_ADFAT173(cPreFx + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de erro.
                            D_DADOS->(DbSkip())
                            Loop

                        EndIf

                    EndIf

                    If ! U_ADFAT50P(D_DADOS->ZIF_NUMERO, nPeso, @cMsgError) //Envio de ordem para o Gemba com peso inicial de balança.

                        U_ADFAT173(cPreFx + " Peso " + cValToChar(nPeso) + " " + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de erro.

                    Else

                        U_ADFAT165(D_DADOS->ZIF_NUMERO, "ZIF_GEMBA", "1") //Marca ordem como enviada.
            
                        U_ADFAT173(cPreFx + "enviada com sucesso. Peso " + cValToChar(nPeso), D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de sucesso.

                    EndIf

                ElseIf D_DADOS->ZIF_GEMBA == "1" .And. D_DADOS->ZIG_INICIA $"3/4/5" //Ordem enviada, peso fechado. Encerrada/Sequestrada/Sequestro liberado.

                    If Empty(D_DADOS->ZIF_AGRUPA)
                        nPeso := D_DADOS->ZIG_PESFIM

                    Else

                        //Obtém peso proportional para ordens agrupadas.
                        If ! U_ADFAT492(D_DADOS->ZIF_AGRUPA, D_DADOS->ZIF_NUMERO, 2, @nPeso, @cMsgError)
                            U_ADFAT173(cPreFx + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA") //Gera log de erro.
                            D_DADOS->(DbSkip())
                            Loop

                        EndIf

                    EndIf

                    //Envia a pesagem final para o Gemba.
                    If ! U_ADFAT50R(D_DADOS->ZIF_NUMERO, nPeso, @cMsgError) //Envio de peso final de balança para o Gemba.

                        U_ADFAT173("Envio de pesagem final: " + " Peso " + cValToChar(nPeso) + " " + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA")

                    Else

                        U_ADFAT165(D_DADOS->ZIF_NUMERO, "ZIF_GEMBA", "3") //Marca ordem como enviada.

                        U_ADFAT173("Envio de pesagem final: sucesso. Peso " + cValToChar(nPeso), D_DADOS->ZIF_NUMERO, "", "GEMBA")

                    EndIf

                EndIf

            EndIf

            D_DADOS->(DbSkip())

        End

    EndIf

    U_ADFAT50B()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFAT492
    Retorna peso proporcional de balança para ordens agrupadas.
    @type  Function
    @author Everson
    @since 20/07/2022
    @version 01
/*/
User Function ADFAT492(cAgrupador, cNmOrdem, nOpcPes, nPeso, cMsgError)

    //Variáveis
    Local aArea     := GetArea()
    Local cAliasAux := ""
    Local cQuery    := ""
    Local nTotRot   := 0
    Local aOrdens   := {}
    Local nAux      := 1
    Local nPerc     := 0
    Local nTotRat   := 0
    Local nPesRat   := 0
    Local nPercTot  := 0 
    Local oHashOrd  := tHashMap():New()

    Default cMsgError := ""

    If ! U_ADFAT16F(cAgrupador)
        cMsgError := "Agrupador" + cValToChar(cAgrupador) + " não localizado."
        RestArea(aArea)
        Return .F.

    EndIf

    cQuery := ""
    cQuery += " SELECT  " 
     cQuery += " ZIF_NUMERO, ROUND(ZIG_PESORD,2) AS ZIG_PESORD, ROUND(ZIF_QUANT,0) AS ZIF_QUANT, ZIG_PESINI, ZIG_PESFIM " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON  " 
        cQuery += " ZIF_FILIAL = ZIG_FILIAL " 
        cQuery += " AND ZIF_AGRUPA = ZIG_ORDEM " 
    cQuery += " WHERE " 
        cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
        cQuery += " AND ZIF_AGRUPA = '" + cAgrupador + "' " 
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIF_NUMERO " 

    cAliasAux := GetNextAlias()

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAux, .F., .T.)
    (cAliasAux)->(DbGoTop())

    nTotRot := Contar(cAliasAux, "!Eof()")

    (cAliasAux)->(DbGoTop())

    While ! (cAliasAux)->(Eof())

        nPerc   := 0
        nPesRat := 0

        If nAux < nTotRot

            If nOpcPes == 1
                nPerc := Round((cAliasAux)->ZIF_QUANT/(cAliasAux)->ZIG_PESORD, 4)

                nPesRat := Round(nPerc * (cAliasAux)->ZIG_PESINI,0)

            Else
                nPerc := Round((cAliasAux)->ZIF_QUANT/(cAliasAux)->ZIG_PESORD, 4)

                nPesRat := Round(nPerc * (cAliasAux)->ZIG_PESFIM,0)

            EndIf

            nTotRat  += nPesRat
            nPercTot += nPerc 

        Else

            If nOpcPes == 1
                nPesRat := (cAliasAux)->ZIG_PESINI - nTotRat

            Else
                nPesRat := (cAliasAux)->ZIG_PESFIM - nTotRat

            EndIf

            nPerc := 1 - nPercTot

        EndIF

        oHashOrd:Set((cAliasAux)->ZIF_NUMERO, nPesRat)

        Aadd(aOrdens,{ (cAliasAux)->ZIF_NUMERO, nPesRat, nPerc })

        nAux++

        (cAliasAux)->(DbSkip())

    End

    (cAliasAux)->(DbCloseArea())

    oHashOrd:Get(cNmOrdem, @nPeso)

    FreeObj(oHashOrd)
    oHashOrd := Nil

    If nPeso <= 0
        cMsgError := "Peso inválido para ordem de pesagem " + cValToChar(cNmOrdem) + "."
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return .T.
