#Include 'Topconn.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Totvs.ch

/*/{Protheus.doc} User Function ADGPE090P
    Job para envio de informações de funcionários.
    para o AWS (ABM). Chamado 16834.
    @type  Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
User Function ADGPE090P() // U_ADGPE090P()

    //Variáveis.
    Private cLinked  := ""
    Private cSGBD    := ""

    RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })
        
        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de informações de funcionários')

        cLinked  := GetMV("MV_#RMLINK",,"RM") 
        cSGBD    := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")

        logZBN("1")

            processa(.T.)

        logZBN("2")

	RpcClearEnv()

Return Nil
/*/{Protheus.doc} processa
    Processa o obtenção/envio.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function processa(lAut)

    //Variáveis.
    Local cUrl      := Alltrim(cValToChar(GetMV("MV_#URLABM",,"https://abmbus.com.br:8181/api")))
    Local cChave    := Alltrim(cValToChar(GetMV("MV_#CHVABM",,"eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG9yb19hcGlAYWJtcHJvdGVnZS5jb20uYnIiLCJleHAiOjE3NTY5NTkxMTJ9.vH0awO8mbiyWeqbzjVEClDePtC95qeOX8T-2w6LiNA_HJt1I-DCLEX1EPjRRMxZyKB68qb8ZhuT8eUQa3J1wzA")))
    Local nCodEmp   := GetMV("MV_#EMPABM",,3528804)
    Local cUsrPai   := GetMV("MV_#USRABM",,95)

    //obtDados(cUrl, cChave)

    envDados(nCodEmp, cUsrPai, cUrl, cChave)

Return Nil
/*/{Protheus.doc} obtDados
    Processa a obtenção de dados.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static function obtDados(cUrl, cChave)

    //Variáveis.
    Local aArea     := GetArea()
    Local cServico  := "/passageiro/novo/all/95"
    Local cMetodo   := "Get"
    Local cMsg      := ""
    Local oJson     := Nil
    Local nAux      := 1
    Local oObj      := Nil
    Local cMat      := ""

    If envReq(cUrl, cServico, cMetodo, cChave, "", @cMsg)

        oJson := JsonObject():new()
        oJson:fromJson(cMsg)

        For nAux := 1 To Len(oJson)

            oObj := oJson[nAux]
            cMat := Alltrim(cValToChar(oObj['matricula']))

            If ! Empty(cMat)
                tratSucess(oObj, cMat)

            EndIf

        Next nAux

        FreeObj(oJson)
        oJson := Nil

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} envDados
    Processa o envio.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static function envDados(nCodEmp, cUsrPai, cUrl, cChave)

    //Variáveis.
    Local aArea     := GetArea()
    Local cServico  := "/passageiro"
    Local cMetodo   := "Post"
    Local cQuery    := scptSql()
    Local cAlias    := ""
    Local cBody     := ""
    Local cMsg      := ""
    Local cHash     := ""

    cAlias := GetNextAlias()
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    If (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
        RestArea(aArea)
        Return Nil
    EndIf 

    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - processa - qtd registros " + cValToChar( Contar(cAlias,"!Eof()") ) )

    (cAlias)->(DbGoTop())
    While ! (cAlias)->(Eof())

        If Empty((cAlias)->ID_ABM)
            cMetodo := "Post"
        Else
            cMetodo := "Put"

        EndIf

        cBody := geraJson(cAlias, cMetodo, nCodEmp, cUsrPai)

        cHash := Alltrim(cValToChar(SHA1(cBody)))

        If cHash == Alltrim(cValToChar((cAlias)->XHASH))
            (cAlias)->(DbSkip())
            Loop

        EndIf

        cMsg    := ""
        lRetEnv := envReq(cUrl, cServico, cMetodo, cChave, cBody, @cMsg)

        If ! lRetEnv
            envErros(cMsg)
            (cAlias)->(DbSkip())
            Loop

        ElseIf lRetEnv .And. (cMetodo == "Post" .Or. cMetodo == "Put") 
            tratSucess(cMsg, Alltrim(cValToChar((cAlias)->CODPESSOA)), cHash)

        EndIf

        (cAlias)->(DbSkip())

    End

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} tratSucess
    Grava id da api no cadastro do funcionário.
    @type  Static Function
    @author Everson
    @since 05/07/2022
    @version 01
/*/
Static Function tratSucess(xMsg, cMat, cHash)
    
    //Variáveis.
    Local aArea := GetArea()
    Local oJson := JsonObject():new()
    Local cId   := ""
    Local cUpt  := ""

    Default cHash := ""

    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - tratSucess")

    If ValType(xMsg) == "J"
        cId := cValToChar(xMsg['id'])

    Else
        oJson := JsonObject():new()
        oJson:fromJson(xMsg)

        cId := cValToChar(oJson['id'])
 
        FreeObj(oJson)
        oJson := Nil
    
    EndIf

    cUpt := " UPDATE OPENQUERY ( " + cLinked + ", "
    cUpt += " ' SELECT RA_XIDABM, RA_XHASH "
    cUpt += " FROM [" + cSGBD + "].[DBO].[VPCOMPL] "
    cUpt += " WHERE CODPESSOA = ''" + cMat + "'' "
    cUpt += " ' ) "      
    cUpt += " SET "
    
    cUpt += " RA_XIDABM = " + Iif(!Empty(cId),"'" + cId + "'", "RA_XIDABM ") + " "

    If ! Empty(cHash)
        cUpt += " , RA_XHASH = '" + cHash + "' "

    EndIf

    If TCSqlExec(cUpt) < 0
        envErros("Erro ao fazer update na tabela PFCOMPL do sistema RM " + TCSQLError())
        Conout( DToC(Date()) + " " + Time() + " ADGPE090P - tratSucess " + TCSQLError() )

    EndIf

    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - tratSucess - cUpt " + cUpt )

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scptSql
    Retorna o script Sql.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function scptSql()

    //Variáveis.
    Local cQuery := ""

    cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '"
    
        cQuery += " SELECT "

            cQuery += " PFUNC.CODCOLIGADA, "
            cQuery += " GCOLIGADA.NOME                                  AS EMPRESA, "
            cQuery += " PFUNC.CODFILIAL, "
            cQuery += " GFILIAL.NOMEFANTASIA                            AS FILIAL, "
            cQuery += " PFUNC.CODSECAO, "
            cQuery += " PSECAO.DESCRICAO                                AS SECAO, "
            cQuery += " PFUNC.CODFUNCAO, "
            cQuery += " PFUNCAO.NOME                                    AS FUNCAO, "
            cQuery += " PFUNC.REGATUAL, "
            cQuery += " PFUNC.CHAPA, "
            cQuery += " PPESSOA.CODIGO                                  AS CODPESSOA, "
            cQuery += " PPESSOA.NOME, "
            cQuery += " PFUNC.CODHORARIO, "
            cQuery += " AHORARIO.DESCRICAO                              AS HORARIO, "
            cQuery += " PFCOMPL.PTOCREDENCIAL                           AS CREDENCIAL_DIMEP, "
            cQuery += " CASE "
            cQuery += " WHEN PPESSOA.CANDIDATO = 1  "
            cQuery += " AND PFUNC.CHAPA IS NULL "
            cQuery += " THEN ''Sim'' "
            cQuery += " ELSE ''Não'' "
            cQuery += " END                                             AS CANDIDATO, "
            cQuery += " PFUNC.DATAADMISSAO, "
            cQuery += " PFUNC.DATADEMISSAO, "
            cQuery += " DTIPORUA.DESCRICAO                              AS TIPORUA, "
            cQuery += " PPESSOA.RUA, "
            cQuery += " PPESSOA.NUMERO, "
            cQuery += " DTIPOBAIRRO.DESCRICAO                           AS TIPOBAIRRO, "
            cQuery += " PPESSOA.BAIRRO, "
            cQuery += " PPESSOA.CIDADE, "
            cQuery += " PPESSOA.ESTADO, "
            cQuery += " PPESSOA.CEP, "
            cQuery += " VPCOMPL.FRETENTR                                AS LINHA_ENTRADA, "
            cQuery += " VPCOMPL.FRETSAI                                 AS LINHA_SAIDA, "
            cQuery += " VPCOMPL.RA_XIDABM                               AS ID_ABM, "
            cQuery += " VPCOMPL.RA_XHASH                                AS XHASH, "
            cQuery += " VPCOMPL.RECCREATEDON                            AS CRIACAO_CPO_COMPL_PESSOA, "
            cQuery += " VPCOMPL.RECMODIFIEDON                           AS MODIF_CPO_COMPL_PESSOA, "
            cQuery += " PFUNC.RECCREATEDON                              AS CRIACAO_FUNC, "
            cQuery += " PFUNC.RECMODIFIEDON                             AS MODIF_FUNC, "
            cQuery += " PPESSOA.RECCREATEDON                            AS CRIACAO_PESSOA, "
            cQuery += " PPESSOA.RECMODIFIEDON                           AS MODIF_PESSOA, "
            cQuery += " FERIAS.DATAINICIO                               AS INICIO_FERIAS, "
            cQuery += " FERIAS.DATAFIM                                  AS FINAL_FERIAS, "
            cQuery += " AFAST.DTINICIO                                  AS INICIO_AFAST, "
            cQuery += " AFAST.DTFINAL                                   AS FINAL_AFAST, "
            cQuery += " CASE "
            cQuery += " WHEN AFAST.DTINICIO IS NOT NULL "
            cQuery += " THEN ''Afastado'' "
            cQuery += " WHEN CONVERT(VARCHAR(10),GETDATE(),102) BETWEEN CONVERT(VARCHAR(10),FERIAS.DATAINICIO,102) AND CONVERT(VARCHAR(10),FERIAS.DATAFIM,102) "
            cQuery += " THEN ''Férias'' "
            cQuery += " WHEN CONVERT(VARCHAR(10),PFUNC.DATADEMISSAO,102) <= CONVERT(VARCHAR(10),GETDATE(),102) "
            cQuery += " THEN ''Demitido'' "
            cQuery += " ELSE ''Ativo'' "
            cQuery += " END                                             AS SITUACAO "
        
        cQuery += " FROM 
        
            cQuery += " [" + cSGBD + "].[DBO].[PPESSOA] "
        
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFUNC] "
            cQuery += " ON PFUNC.CODPESSOA = PPESSOA.CODIGO    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[GCOLIGADA] "
            cQuery += " ON PFUNC.CODCOLIGADA = GCOLIGADA.CODCOLIGADA    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[GFILIAL] "
            cQuery += " ON PFUNC.CODCOLIGADA = GFILIAL.CODCOLIGADA
            cQuery += " AND PFUNC.CODFILIAL = GFILIAL.CODFILIAL    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PSECAO] "
            cQuery += " ON PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA "
            cQuery += " AND PFUNC.CODSECAO = PSECAO.CODIGO    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFUNCAO] "
            cQuery += " ON PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA "
            cQuery += " AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PCODSITUACAO] "
            cQuery += " ON PFUNC.CODSITUACAO = PCODSITUACAO.CODCLIENTE    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[DTIPORUA] "
            cQuery += " ON PPESSOA.CODTIPORUA = DTIPORUA.CODIGO    " 

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[DTIPOBAIRRO] "
            cQuery += " ON PPESSOA.CODTIPOBAIRRO = DTIPOBAIRRO.CODIGO    " 

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[VPCOMPL] "
            cQuery += " ON VPCOMPL.CODPESSOA = PPESSOA.CODIGO    "

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[AHORARIO] "
            cQuery += " ON PFUNC.CODCOLIGADA = AHORARIO.CODCOLIGADA  "
            cQuery += " AND PFUNC.CODHORARIO = AHORARIO.CODIGO     " 

            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFCOMPL]  "
            cQuery += " ON PFUNC.CODCOLIGADA = PFCOMPL.CODCOLIGADA  "
            cQuery += " AND PFUNC.CHAPA = PFCOMPL.CHAPA     "

            cQuery += " LEFT JOIN ( "

                cQuery += " SELECT "
                    cQuery += " PFUFERIASPER.CODCOLIGADA,  "
                    cQuery += " PFUFERIASPER.CHAPA,  "
                    cQuery += " PFUFERIASPER.DATAINICIO,  "
                    cQuery += " PFUFERIASPER.DATAFIM,  "
                    cQuery += " CONVERT(VARCHAR(10),GETDATE(),102)  HOJE,  "
                    cQuery += " CONVERT(VARCHAR(10),PFUFERIASPER.DATAINICIO,102) DATAINI,  "
                    cQuery += " CONVERT(VARCHAR(10),PFUFERIASPER.DATAFIM,102) DATAFINAL     "
                cQuery += " FROM "
                    cQuery += " [" + cSGBD + "].[DBO].[PFUFERIASPER]     "
                cQuery += " WHERE 
                    cQuery += " CONVERT(VARCHAR(10),PFUFERIASPER.DATAINICIO,102) = CONVERT(VARCHAR(10),GETDATE(),102))  AS FERIAS	  "			
                    cQuery += " ON PFUNC.CODCOLIGADA = FERIAS.CODCOLIGADA  "
                    cQuery += " AND PFUNC.CHAPA = FERIAS.CHAPA     "
                cQuery += " LEFT JOIN "
                cQuery += " ( "
                cQuery += " SELECT "
                    cQuery += " PFHSTAFT.CODCOLIGADA,  "
                    cQuery += " PFHSTAFT.CHAPA,  "
                    cQuery += " PFHSTAFT.DTINICIO,  "
                    cQuery += " PFHSTAFT.DTFINAL     "
                cQuery += " FROM "
                    cQuery += " [" + cSGBD + "].[DBO].[PFHSTAFT]     "
                cQuery += " WHERE "
                    cQuery += " GETDATE() BETWEEN PFHSTAFT.DTINICIO AND ISNULL(PFHSTAFT.DTFINAL,''2999-12-31 23:59:59'')

            cQuery += " )  AS AFAST  "
            cQuery += " ON AFAST.CODCOLIGADA = PFUNC.CODCOLIGADA  "
            cQuery += " AND AFAST.CHAPA = PFUNC.CHAPA     "

            // cQuery += " WHERE  "  
            // cQuery += " ((PFUNC.CODSITUACAO <> ''D'' OR CONVERT(VARCHAR(10),PFUNC.DATADEMISSAO,102) BETWEEN CONVERT(VARCHAR(10),GETDATE()-7,102) AND CONVERT(VARCHAR(10),GETDATE(),102)))   "
            // cQuery += " AND  PFCOMPL.FRETADO IS NOT NULL    ORDER BY PFUNC.CODPESSOA "

            cQuery += " WHERE   "
                cQuery += " ((PFUNC.CODSITUACAO <> ''D'' OR CONVERT(VARCHAR(10),PFUNC.DATADEMISSAO,102) BETWEEN CONVERT(VARCHAR(10),GETDATE()-7,102) AND CONVERT(VARCHAR(10),GETDATE(),102)) AND (CONVERT(VARCHAR(10),PPESSOA.RECMODIFIEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102) OR CONVERT(VARCHAR(10),PPESSOA.RECCREATEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102) OR CONVERT(VARCHAR(10),PFUNC.RECMODIFIEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102) OR CONVERT(VARCHAR(10),PFUNC.RECCREATEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102) OR CONVERT(VARCHAR(10),VPCOMPL.RECMODIFIEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102) OR CONVERT(VARCHAR(10),VPCOMPL.RECCREATEDON,102) = CONVERT(VARCHAR(10),GETDATE(),102)))  "
                cQuery += " AND  PFCOMPL.FRETADO IS NOT NULL   "
            cQuery += " ORDER BY PFUNC.CHAPA   "

    cQuery += "') "
    
    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - scptSql - cQuery " + cValToChar(cQuery) )
    
Return cQuery

/*/{Protheus.doc} geraJson
    Gera json.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function geraJson(cAlias, cMetodo, nCodEmp, cUsrPai)

    //Variáveis.
    Local aArea     := GetArea()
    Local oJson     := JsonObject():new()
    Local oEmp      := JsonObject():new()
    Local oUsrPai   := JsonObject():new()
    Local cJson     := ""

    oEmp['id']      := nCodEmp
    oUsrPai['id']   := cUsrPai

    If cMetodo == "Put"
        oJson['id']        := Val(cValToChar((cAlias)->ID_ABM))

    EndIf

    oJson['nome']               := U_ADFAT50O(Alltrim(cValToChar((cAlias)->NOME)))
    oJson['endereco']           := U_ADFAT50O(Alltrim(cValToChar((cAlias)->RUA))) + ", " + U_ADFAT50O(Alltrim(cValToChar((cAlias)->NUMERO))) + ", " + U_ADFAT50O(Alltrim(cValToChar((cAlias)->BAIRRO))) + ", " +  U_ADFAT50O(Alltrim(cValToChar((cAlias)->CIDADE))) + ", " + U_ADFAT50O(Alltrim(cValToChar((cAlias)->ESTADO))) + ", " + U_ADFAT50O(Alltrim(cValToChar((cAlias)->CEP)))
    oJson['matricula']          := Alltrim(cValToChar((cAlias)->CODPESSOA))
    oJson['cargo']              := U_ADFAT50O(Alltrim(cValToChar((cAlias)->FUNCAO)))
    oJson['empresa']            := oEmp
    oJson['usuarioPai']         := oUsrPai
    oJson['status']             := iif(Alltrim(cValToChar((cAlias)->SITUACAO)) == "Ativo", 1, Iif(Alltrim(cValToChar((cAlias)->SITUACAO)) == "Demitido", 2, 3))
    oJson['rfid']               := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CREDENCIAL_DIMEP)))
    oJson['cidade']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CIDADE)))
    oJson['bairro']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->BAIRRO)))
    oJson['estado']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->ESTADO)))
    oJson['entrada']            := U_ADFAT50O(Alltrim(cValToChar((cAlias)->HORARIO)))
    oJson['saida']              := U_ADFAT50O(Alltrim(cValToChar((cAlias)->HORARIO)))

    cJson := oJson:toJSON()

    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - geraJson - cJson " + cJson )

    FreeObj(oJson)
    oJson := Nil

    FreeObj(oEmp)
    oEmp := Nil

    FreeObj(oUsrPai)
    oUsrPai := Nil

    RestArea(aArea)

Return cJson
/*/{Protheus.doc} envReq
    Envia requisição.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function envReq(cUrl, cServico, cMetodo, cChave, cBodyRq, cMsg)

    //Variáveis.
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local oRestClient 	:= Nil
	Local lRest			:= .F.

    Private aHeader	:= {}
    Private cBody       := cBodyRq

	Default cServico	:= ""
	Default cBody		:= ""
	Default cMsg		:= ""
	Default aResponse	:= {}

    Aadd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "Authorization: " + cChave)

	oRestClient := FWRest():New(cUrl)
	oRestClient:setPath(cServico)

    If cMetodo == "Post"
        oRestClient:SetPostParams(cBody)
        lRest := oRestClient:Post(aHeader)

    ElseIf cMetodo == "Put"
        lRest := oRestClient:Put(aHeader, cBody)

    Endif

	cMsg := ""

	If ! lRest

		If Substr(Alltrim(cValToChar(oRestClient:GetLastError())),1,1) <> "2" 

			cMsg := Alltrim(cValToChar(oRestClient:GetLastError())) + Chr(13) + Chr(10)
			cMsg += "URL: "      + cUrl + Chr(13) + Chr(10)
			cMsg += "EndPoint: " + cServico + Chr(13) + Chr(10)
			cMsg += "Método: "   + cMetodo + Chr(13) + Chr(10)
			cMsg += "Body: "     + Chr(13) + Chr(10) + cValToChar(cBody) + Chr(13) + Chr(10)
			cMsg += "Resp: "     + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetResult())) + Chr(13) + Chr(10)
			lRet := .F.

		EndIf

	EndIf
	
	If lRet 
        cMsg := Alltrim(cValToChar(oRestClient:GetResult()))

	EndIf

	FreeObj(oRestClient)
	oRestClient := Nil
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} envErros
    Gera log de erro.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function envErros(cMsg)

    //Variáveis.
    Local aArea := GetArea()
    Local cPara := GetMv("MV_#EAWS",,"")//"everson.silva@adoro.com.br"

	Conout( DToC(Date()) + " " + Time() + " ADGPE090P - envErros - cMsg " + cMsg)
	U_enviarEmail(cPara,"Erro Integração - ABM", "ADGPE090P - envErros" + Chr(13) + Chr(10) + cMsg)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} logZBN
    Gera log do Job na tabela ZBN.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function logZBN(cStatus)

    //Variáveis.
	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE090P'))

		RecLock("ZBN",.F.)

            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= 'ADGPE090P'
            ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= 'ADGPE090P'
            ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	RestArea(aArea)

Return Nil
