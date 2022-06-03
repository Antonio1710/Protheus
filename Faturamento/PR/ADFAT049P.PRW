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

    Default cNmOrdem   := ""
    Default cMsgError  := ""

    cNmOrdem := Alltrim(cValToChar(cNmOrdem))
    
    If lBarramento
        U_ADFAT29J()
    
    Else

        cQuery += " SELECT  "
        cQuery += " DISTINCT ZIF_NUMERO "
        cQuery += " FROM "
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF "
        cQuery += " INNER JOIN "
        cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON "
        cQuery += " ZIF_FILIAL = ZIG_FILIAL "
        cQuery += " AND ZIF_NUMERO = ZIG_ORDEM "
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
        cQuery += " AND ZIG_TPMOV = 'R' "
        cQuery += " AND ZIG_INICIA IN ('1','2','4') "
        cQuery += " AND ZIB_STATUS NOT IN ('5','6') "
        cQuery += " AND (ZIT_ORDEM IS NULL OR ZIT_ORDEM = '') "

        If ! Empty(cNmOrdem)
            cQuery += " AND ZIF_NUMERO = '" + cNmOrdem + "' "

        EndIf

        cQuery += " AND ZIF.D_E_L_E_T_ = '' "
        cQuery += " AND ZIG.D_E_L_E_T_ = '' "
        cQuery += " AND ZIB.D_E_L_E_T_ = '' "
        cQuery += " ORDER BY  ZIF_NUMERO "

        If Select("D_DADOS") > 0
            D_DADOS->(DbCloseArea())

        EndIf

        TcQuery cQuery New Alias "D_DADOS"
        DbSelectArea("D_DADOS")
        D_DADOS->(DbGoTop())

        While ! D_DADOS->(Eof())

            If ! U_ADFAT50D(D_DADOS->ZIF_NUMERO, @cMsgError)
                
                If Alltrim(cValToChar(cMsgError)) <> "WS Gemba não retornou dados do método Get(Ordem de Pesagem)."
                    U_ADFAT173("Obter lacres : " + cMsgError, D_DADOS->ZIF_NUMERO, "", "GEMBA")

                EndIf

            Else
                U_ADFAT173("Obter lacres : sucesso " , D_DADOS->ZIF_NUMERO, "", "GEMBA")

            EndIf

            D_DADOS->(DbSkip())

        End

    EndIf

    U_ADFAT50B()

    RestArea(aArea)

Return Nil
