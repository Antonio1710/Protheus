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
    Processa o envio.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function processa(lAut)

    //Variáveis.
    Local aArea     := GetArea()
    Local cUrl      := Alltrim(cValToChar(GetMV("MV_#URLABM",,"https://rhxpdfeosf.execute-api.us-east-2.amazonaws.com/prod")))
    Local cChave    := Alltrim(cValToChar(GetMV("MV_#CHVABM",,"t4p5gn7rdF5AB3BPuOZmA74hYoaDVZXw4rI0fatw")))
    Local cServico  := "/funcionarios"
    Local cQuery    := scptSql()
    Local cAlias    := ""
    Local cBody     := ""
    Local cMsg      := ""

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

        cBody := geraJson(cAlias)

        cMsg    := ""
        lRetEnv := envReq(cUrl, cServico, cChave, cBody, @cMsg)

        If ! lRetEnv
            envErros(cMsg)
            (cAlias)->(DbSkip())
            Loop

        EndIf

        (cAlias)->(DbSkip())

    End

    (cAlias)->(DbCloseArea())

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

    cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ",
    
        cQuery += " 'SELECT PFUNC.CODCOLIGADA, " 
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
            cQuery += " WHEN PPESSOA.CANDIDATO = 1 AND PFUNC.CHAPA IS NULL " 
            cQuery += " THEN ''Sim'' " 
            cQuery += " ELSE ''Não'' " 
            cQuery += " END                                             AS CANDIDATO, " 
            cQuery += " PFUNC.CODSITUACAO, " 
            cQuery += " PCODSITUACAO.DESCRICAO                          AS SITUACAO, " 
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
            cQuery += " VPCOMPL.FRETSAI                                 AS LINHA_SAIDA " 
        cQuery += " FROM [" + cSGBD + "].[DBO].[PPESSOA] " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFUNC] " 
            cQuery += " ON PFUNC.CODPESSOA = PPESSOA.CODIGO " 
            cQuery += " AND PFUNC.REGATUAL = 1 " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[GCOLIGADA] " 
            cQuery += " ON PFUNC.CODCOLIGADA = GCOLIGADA.CODCOLIGADA " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[GFILIAL] " 
            cQuery += " ON PFUNC.CODCOLIGADA = GFILIAL.CODCOLIGADA " 
            cQuery += " AND PFUNC.CODFILIAL = GFILIAL.CODFILIAL " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PSECAO] " 
            cQuery += " ON PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA " 
            cQuery += " AND PFUNC.CODSECAO = PSECAO.CODIGO     " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFUNCAO] " 
            cQuery += " ON PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA " 
            cQuery += " AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PCODSITUACAO] " 
            cQuery += " ON PFUNC.CODSITUACAO = PCODSITUACAO.CODCLIENTE  " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[DTIPORUA] " 
            cQuery += " ON PPESSOA.CODTIPORUA = DTIPORUA.CODIGO " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[DTIPOBAIRRO] " 
            cQuery += " ON PPESSOA.CODTIPOBAIRRO = DTIPOBAIRRO.CODIGO " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[VPCOMPL] " 
            cQuery += " ON VPCOMPL.CODPESSOA = PPESSOA.CODIGO " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[AHORARIO] " 
            cQuery += " ON PFUNC.CODCOLIGADA = AHORARIO.CODCOLIGADA " 
            cQuery += " AND PFUNC.CODHORARIO = AHORARIO.CODIGO " 
            cQuery += " LEFT JOIN [" + cSGBD + "].[DBO].[PFCOMPL] "
            cQuery += " ON PFUNC.CODCOLIGADA = PFCOMPL.CODCOLIGADA "
            cQuery += " AND PFUNC.CHAPA = PFCOMPL.CHAPA "

        cQuery += " WHERE (PPESSOA.CANDIDATO = ''1'' AND PFUNC.CHAPA IS NULL) OR (PFUNC.CODSITUACAO <> ''D'') "
        cQuery += " AND GFILIAL.NOMEFANTASIA IN (''VARZEA PAULISTA'', ''CERES'', NULL) " 
        cQuery += " ORDER BY PPESSOA.CODIGO "   

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
Static Function geraJson(cAlias)

    //Variáveis.
    Local aArea := GetArea()
    Local oJson := Nil
    Local cJson := ""

    oJson := JsonObject():new()
    oJson['codpessoa']          := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODPESSOA)))
    oJson['credDimep']          := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CREDENCIAL_DIMEP)))
    oJson['codcoligada']        := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODCOLIGADA)))
    oJson['empresa']            := U_ADFAT50O(Alltrim(cValToChar((cAlias)->EMPRESA)))
    oJson['codfilial']          := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODFILIAL)))
    oJson['filial']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->FILIAL)))
    oJson['codsecao']           := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODSECAO)))
    oJson['secao']              := Alltrim(cValToChar((cAlias)->SECAO))
    oJson['codfuncao']          := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODFUNCAO)))
    oJson['funcao']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->FUNCAO)))
    oJson['regatual']           := U_ADFAT50O(Alltrim(cValToChar((cAlias)->REGATUAL)))
    oJson['chapa']              := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CHAPA)))
    oJson['nome']               := U_ADFAT50O(Alltrim(cValToChar((cAlias)->NOME)))
    oJson['codhorario']         := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODHORARIO)))
    oJson['horario']            := U_ADFAT50O(Alltrim(cValToChar((cAlias)->HORARIO)))
    oJson['candidato']          := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CANDIDATO)))
    oJson['codsituacao']        := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODSITUACAO)))
    oJson['situacao']           := U_ADFAT50O(Alltrim(cValToChar((cAlias)->SITUACAO)))
    oJson['dataAdmissao']       := Alltrim(cValToChar((cAlias)->DATAADMISSAO))
    oJson['dataDemissao']       := Alltrim(cValToChar((cAlias)->DATADEMISSAO))
    oJson['linhaEntrada']       := U_ADFAT50O(Alltrim(cValToChar((cAlias)->LINHA_ENTRADA)))
    oJson['linhaSaida']         := U_ADFAT50O(Alltrim(cValToChar((cAlias)->LINHA_SAIDA)))
    oJson['tipoRua']            := U_ADFAT50O(Alltrim(cValToChar((cAlias)->TIPORUA)))
    oJson['rua']                := U_ADFAT50O(Alltrim(cValToChar((cAlias)->RUA)))
    oJson['numero']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->NUMERO)))
    oJson['tipoBairro']         := U_ADFAT50O(Alltrim(cValToChar((cAlias)->TIPOBAIRRO)))
    oJson['cidade']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CIDADE)))
    oJson['estado']             := U_ADFAT50O(Alltrim(cValToChar((cAlias)->ESTADO)))
    oJson['cep']                := U_ADFAT50O(Alltrim(cValToChar((cAlias)->CEP)))
    oJson['chave']              := Padl(U_ADFAT50O(Alltrim(cValToChar((cAlias)->CODPESSOA))),10,"0")

    cJson := oJson:toJSON()

    Conout( DToC(Date()) + " " + Time() + " ADGPE090P - geraJson - cJson " + cJson )

    FreeObj(oJson)
    oJson := Nil
    RestArea(aArea)

Return cJson
/*/{Protheus.doc} envReq
    Envia requisição.
    @type  Static Function
    @author Everson
    @since 24/06/2022
    @version 01
/*/
Static Function envReq(cUrl, cServico, cChave, cBodyRq, cMsg)

    //Variáveis.
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local oRestClient 	:= Nil
	Local lRest			:= .F.

    Private aHeader	:= {}
    Private cBody       := cBodyRq

	Default cServico	:= ""
	Default cMetodo		:= ""
	Default cBody		:= ""
	Default cMsg		:= ""
	Default aResponse	:= {}

    Aadd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "x-api-key: " + cChave)

	oRestClient := FWRest():New(cUrl)
	oRestClient:setPath(cServico)
    oRestClient:SetPostParams(cBody)
    lRest := oRestClient:Post(aHeader)

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
	U_enviarEmail(cPara,"Erro Integração AWS (ABM)", "ADGPE090P - envErros" + Chr(13) + Chr(10) + cMsg)

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
