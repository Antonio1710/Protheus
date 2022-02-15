#Include 'Topconn.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Totvs.ch

/*/{Protheus.doc} User Function ADGPE056P
    Job para envio de informações de funcionários.
    para o AWS (Auttran). Chamado 058290.
    @type  Function
    @author Everson
    @since 21/05/2020
    @version 02
    @history ticket 7791  - Fernando Macieira - 19/01/2021 - INTEGRAÇÃO RM X AUTTRAN
    @history ticket   39  - Fernando Macieira - 10/02/2021 - Padronização do parâmetro Linked Server RM, de/para no campo CODSITUACAO
    @history ticket   TI  - Fernando Macieira - 05/03/2021 - Tratativa nome banco CORPORERM
    @history Ticket 18425 - ADRIANO SAVOINE   - 23/08/2021 - Ajuste na query enviada pelo Marcos Cavalcante Consultor RM, para integrar no JOB os dados do RM.
    @history Ticket 62169 - Everson           - 13/10/2021 - Tratamento para retorno de erro employees_uddi_unique.
/*/
User Function ADGPE056P() // U_ADGPE056P()

    //Variáveis.
    Private cLinked  := "" // @history ticket 7791 - Fernando Macieira - 19/01/2021 - INTEGRAÇÃO RM X AUTTRAN
    Private cSGBD    := "" // @history ticket   TI - Fernando Macieira - 05/03/2021 - Tratativa nome banco CORPORERM

	//Inicia o ambiente.
    RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

    //cLinked  := GetMV("MV_#RMLS",,"RM") // @history ticket 7791 - Fernando Macieira - 19/01/2021 - INTEGRAÇÃO RM X AUTTRAN
    cLinked  := GetMV("MV_#RMLINK",,"RM") // //@history ticket TI   - Fernando Macieira - 10/02/2021 - Padronização do parâmetro Linked Server RM
    cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // @history ticket   TI - Fernando Macieira - 05/03/2021 - Tratativa nome banco CORPORERM

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE056P", .T., .F.)
		ConOut("[ADGPE056P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

    PtInternal(1,ALLTRIM(PROCNAME()))

    logZBN("1")

        //
        processa(.T.)

    //
    logZBN("2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADGPE056P")

    //Fecha o ambiente.
	RpcClearEnv()

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para envio de informações de funcionários')


Return Nil

/*/{Protheus.doc} processa
    Processa o envio.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function processa(lAut)

    //Variáveis.
    Local aArea     := GetArea()
    Local aResponse := {}
    Local cServico  := "/employees"
    Local cQuery    := scptSql()
    Local cAlias    := ""
    Local cBody     := ""
    Local cMetodo   := ""
    Local cChave    := ""
    Local cMsg      := ""

    //
    Default lAut    := .F.

    //
    If !loginAWS(lAut,@aResponse)
        RestArea(aArea)
        Return Nil
    EndIf

    //
    cAlias := GetNextAlias()
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    //
    If (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
        RestArea(aArea)
        Return Nil
    EndIf 

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - processa - qtd registros " + cValToChar( Contar(cAlias,"!Eof()") ) )

    //
    (cAlias)->(DbGoTop())
    While ! (cAlias)->(Eof())

        //
        cMetodo := Iif(Val(Alltrim(cValToChar((cAlias)->cod_AWS))) == 0,"POST","PUT")
        cChave  := Iif(Val(Alltrim(cValToChar((cAlias)->cod_AWS))) == 0,"", "/" + Alltrim(cValToChar((cAlias)->company)) + Alltrim(cValToChar((cAlias)->subsidiary)) + Alltrim(cValToChar((cAlias)->code)) ) //Everson -27/05/2020. Chamado T.I.

        //
        cBody := geraJson(cAlias)

        //
        cMsg    := ""
        lRetEnv := envReq(cServico + cChave, cMetodo, cBody, @cMsg, aResponse)

        //
        If ! lRetEnv

            //
            If (At("employees_key_unique",cMsg) > 0 .Or. At("employees_uddi_unique",cMsg) > 0) .And.; //Everson - 13/10/2021. Chamado 62169.or.
               cMetodo == "POST" //Registro já existe na base.

                Conout( DToC(Date()) + " " + Time() + " ADGPE056P - processa - Erro - employees_key_unique")

                //
                cMetodo := "PUT"
                cChave  := "/" + Alltrim(cValToChar((cAlias)->company)) + Alltrim(cValToChar((cAlias)->subsidiary)) + Alltrim(cValToChar((cAlias)->code)) //Everson -27/05/2020. Chamado T.I.

                //
                cMsg := ""
                lRetEnv := envReq(cServico + cChave, cMetodo, cBody, @cMsg, aResponse)

                //
                If ! lRetEnv
                    envErros(cMsg)
                    (cAlias)->(DbSkip())
                    Loop
                EndIf

            ElseIf At("Cannot read property 'merge' of null",cMsg) > 0 .And. cMetodo == "PUT"

                Conout( DToC(Date()) + " " + Time() + " ADGPE056P - processa - Erro - Cannot read property 'merge' of null")

                //
                cMetodo := "POST"
                cChave  := ""

                //
                cMsg := ""
                lRetEnv := envReq(cServico + cChave, cMetodo, cBody, @cMsg, aResponse)

                //
                If ! lRetEnv
                    envErros(cMsg)
                    (cAlias)->(DbSkip())
                    Loop
                EndIf

            Else

                envErros(cMsg)
                (cAlias)->(DbSkip())
                Loop

            EndIf

        EndIf

        //
        If lRetEnv .And. cMetodo == "POST"
            tratSucess( cMsg, Alltrim(cValToChar((cAlias)->company)), Alltrim(cValToChar((cAlias)->subsidiary)), Alltrim(cValToChar((cAlias)->code)) )
        
        EndIf

        //
        (cAlias)->(DbSkip())

    End

    //
    (cAlias)->(DbCloseArea())

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} login
    Efetua login.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function loginAWS(lAut,aResponse)

    //Variáveis.
    Local aArea         := GetArea()
    Local cContentType  := "application/json"
    Local cUrl          := Alltrim(GetMv("MV_#URLAWS",,"")) //http://3.129.248.228:3333
    Local cPath         := "/sessions"
    Local cUsuario      := GetMv("MV_#USRAWS",,"")//"sistemas@adoro.com.br"
    Local cSenha        := Alltrim(GetMv("MV_#SENAWS",,""))//"Bm^%nGUaeJ9GR=jw"
    Local cCreden       := ""
    Local oRestClient   := Nil
    Local cBody         := ""
    Local aHeadReq      := {}
    Local oJson         := Nil
    Local aHeadStr      := {}
    Local cType         := ""
    Local cToken        := ""

    //
    Default lAut        := .F.
    Default aResponse   := {}

    //
    Aadd(aHeadReq,"Content-Type: " + cContentType)

    //
    cCreden := '{ "email": "' + cUsuario + '", "password": "' + cSenha + '"}'

    //
    //Conout( DToC(Date()) + " " + Time() + " ADGPE056P - loginAWS - cCreden " + cCreden )

	//
	oRestClient := FWRest():New(cUrl)

	//
	oRestClient:setPath(cPath)

    //
	oRestClient:SetPostParams(cCreden)

	//
	If ! oRestClient:Post(aHeadReq)

        //
		cMsg := "Ocorre um erro ao tentar efetuar login (loginAWS ADGPE056P)." + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetLastError()))
		If ! lAut
            envErros(cMsg)
			MsgStop(cMsg,"Função loginAWS(ADGPE056P)")

		Else
			envErros(cMsg)

		EndIf

        //
        FreeObj(oRestClient)
        oRestClient := Nil
        FreeObj(oJson)
        oJson := Nil
		RestArea(aArea)
		Return .F.

	EndIf

	//Obtém a string json.
	cBody := Alltrim(cValToChar(oRestClient:GetResult()))

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - loginAWS - cBody " + cBody )

    //
    oJson := JsonObject():new()
    oJson:fromJson(cBody)

    //
    cType   := cValToChar(oJson['type'])
    cToken  := cValToChar(oJson['token'])

	//Monta cabeçalho para envio de requisições.
	Aadd(aHeadStr,'Authorization:' + cType + ' ' + cToken )
	Aadd(aHeadStr,'Content-Type:' + cContentType )

	//Preenche vetor de resposta da função.
	Aadd(aResponse,{;
        aHeadStr ,; //Cabeçalho para efetuar requisições no serviço.
        cUrl  ;
	})

	//
	FreeObj(oRestClient)
	oRestClient := Nil
  	FreeObj(oJson)
	oJson := Nil
      
    //
    RestArea(aArea)

Return .T.

/*/{Protheus.doc} scptSql
    Retorna o script Sql.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function scptSql()

    //Variáveis.
    Local cQuery := ""

     //As empresas e filiais estão hardcoded.
     // RM - CorporeRM - Linked Server
    // Adoro
    //Ticket 18425 - ADRIANO SAVOINE   - 23/08/2021

    cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ",
    
    cQuery += " 'SELECT SRA.CODCOLIGADA                        AS company,    
    cQuery += "        ''ADORO S.A.''                          AS name_company,      
    cQuery += "        LEFT(SRA.CHAPA,2)                        AS subsidiary, 
    cQuery += "        ''VARZEA''                              AS name_subsidiary,      
    cQuery += "        PFCOMPL.PTOCREDENCIAL                    AS key_code,      
    cQuery += "        SRA.NOME                                 AS name,      
    cQuery += "        SRA.CHAPA                                AS code,       
    cQuery += "        CASE
    cQuery += "           when ( CONVERT(VARCHAR(8), (GETDATE()), 112) BETWEEN CONVERT(VARCHAR(8), FERIAS.DATAINICIO, 112) AND CONVERT(VARCHAR(8), FERIAS.DATAFIM, 112) AND FERIAS.DATAFIM IS NOT NULL AND AFAST.MOTIVO IS NULL) 
    cQuery += "               THEN ''F''
    cQuery += "           when ( ( CONVERT(VARCHAR(8), (GETDATE()), 112) BETWEEN CONVERT(VARCHAR(8), AFAST.DTINICIO, 112) AND CONVERT(VARCHAR(8), AFAST.DTFINAL, 112) OR AFAST.DTFINAL IS NULL ) AND AFAST.MOTIVO IS NOT NULL ) 
    cQuery += "               THEN ''A''
    cQuery += "           when CODSITUACAO = ''D''
    cQuery += "               THEN CODSITUACAO
    cQuery += "           when CODSITUACAO = ''A''
    cQuery += "               THEN ''''
    cQuery += "           when CODSITUACAO = ''F''
    cQuery += "               THEN ''''
    cQuery += "           when CODSITUACAO IN (''C'',''E'',''G'',''I'',''K'',''L'',''M'',''N'',''O'',''P'',''Q'',''R'',''S'',''T'',''U'',''W'',''Y'') 
    cQuery += "               THEN ''A''
    cQuery += "           when CODSITUACAO IN (''V'',''X'',''Z'') 
    cQuery += "               THEN ''''
    cQuery += "                    else CODSITUACAO 
    cQuery += "        end as status,
    cQuery += "        SRA.CODSITUACAO,  
    cQuery += "        RIGHT(RTRIM(LTRIM(SRA.CODSECAO)),4)    AS code_cc,      
    cQuery += "        RTRIM(LTRIM(PSECAO.DESCRICAO))         AS desc_cc,    
    cQuery += "        PFCOMPL.RA_XIDAWS                      AS cod_AWS,
    cQuery += "        AFAST.MOTIVO,
    cQuery += "        AFAST.DTINICIO,
    cQuery += "        AFAST.DTFINAL,
    cQuery += "        FERIAS.DATAINICIO,
    cQuery += "        FERIAS.DATAFIM
    cQuery += " 
    cQuery += " FROM [" + cSGBD + "].[DBO].[PFUNC] (NOLOCK) AS SRA
    cQuery += "       INNER JOIN [" + cSGBD + "].[DBO].[PFCOMPL] (NOLOCK) AS PFCOMPL 
    cQuery += "    ON PFCOMPL.CODCOLIGADA=SRA.CODCOLIGADA 
    cQuery += "   AND PFCOMPL.CHAPA=SRA.CHAPA 
    cQuery += "   AND ((PFCOMPL.CODCOLIGADA = ''1'' AND SUBSTRING(PFCOMPL.CHAPA,1,2) = ''02'') OR (PFCOMPL.CODCOLIGADA = ''2''))
    cQuery += "   AND ( PFCOMPL.PTOCREDENCIAL IS NOT NULL 
    cQuery += "   AND PFCOMPL.PTOCREDENCIAL <> ''0'')
    cQuery += "       INNER JOIN [" + cSGBD + "].[DBO].[PSECAO] (NOLOCK) AS PSECAO  
    cQuery += "    ON PSECAO.CODCOLIGADA=SRA.CODCOLIGADA 
    cQuery += "   AND PSECAO.CODIGO=SRA.CODSECAO
    cQuery += "       LEFT OUTER JOIN  (  
    cQuery += "                         SELECT CODCOLIGADA, 
    cQuery += "                                CHAPA, 
    cQuery += "                                MOTIVO, 
    cQuery += "                                CONVERT(VARCHAR(8),DTINICIO,112) DTINICIO, 
    cQuery += "                                CONVERT(VARCHAR(8),DTFINAL,112) DTFINAL
    cQuery += "                         FROM [" + cSGBD + "].[DBO].[PFHSTAFT] (NOLOCK) AS SR8
    cQuery += "                         WHERE ((SR8.CODCOLIGADA = ''1'' AND SUBSTRING(SR8.CHAPA,1,2) = ''02'') OR (SR8.CODCOLIGADA = ''2''))
    cQuery += "                         AND ( CONVERT(VARCHAR(8), (GETDATE()), 112) BETWEEN CONVERT(VARCHAR(8), DTINICIO, 112) 
    cQuery += "                         AND CONVERT(VARCHAR(8), DTFINAL, 112) OR DTFINAL IS NULL )) AS AFAST 
    cQuery += "    ON SRA.CODCOLIGADA = AFAST.CODCOLIGADA 
    cQuery += "   AND SRA.CHAPA = AFAST.CHAPA
    cQuery += "       LEFT OUTER JOIN  (  
    cQuery += "                         SELECT CODCOLIGADA, 
    cQuery += "                                CHAPA, 
    cQuery += "                                CONVERT(VARCHAR(8), DATAINICIO, 112) DATAINICIO, 
    cQuery += "                                CONVERT(VARCHAR(8), DATAFIM, 112) DATAFIM
    cQuery += "                         FROM [" + cSGBD + "].[DBO].[PFUFERIASPER] (NOLOCK) AS SRF
    cQuery += "                         WHERE ((SRF.CODCOLIGADA = ''1'' AND SUBSTRING(SRF.CHAPA,1,2) = ''02'') OR (SRF.CODCOLIGADA = ''2''))
    cQuery += "                           AND ( CONVERT(VARCHAR(8), (GETDATE()), 112) BETWEEN CONVERT(VARCHAR(8), DATAINICIO, 112) AND CONVERT(VARCHAR(8), DATAFIM, 112) )) AS FERIAS
    cQuery += "    ON SRA.CODCOLIGADA = FERIAS.CODCOLIGADA 
    cQuery += "   AND SRA.CHAPA = FERIAS.CHAPA
    cQuery += " WHERE ((SRA.CODCOLIGADA = ''1'') OR (SRA.CODCOLIGADA = ''2''))


    cQuery += " ORDER BY company, subsidiary, key_code

    cQuery += " ')
    
    //Ticket 18425 - ADRIANO SAVOINE   - 23/08/2021 

    //  

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - scptSql - cQuery " + cValToChar(cQuery) )
    
Return cQuery

/*/{Protheus.doc} geraJson
    Gera json.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function geraJson(cAlias)

    //Variáveis.
    Local aArea := GetArea()
    Local oJson := Nil
    Local cJson := ""

    //
    oJson := JsonObject():new()
    oJson['key']                := Alltrim((cAlias)->key_code)
    oJson['name']               := Alltrim(cValToChar((cAlias)->name))
    oJson['registry']           := Alltrim(cValToChar((cAlias)->code))
    oJson['company']            := Alltrim(cValToChar((cAlias)->company))
    oJson['company_name']       := Alltrim(cValToChar((cAlias)->name_company))
    oJson['subsidiary']         := Alltrim(cValToChar((cAlias)->subsidiary))
    oJson['subsidiary_name']    := Alltrim(cValToChar((cAlias)->name_subsidiary))
    oJson['code_cc']            := Alltrim(cValToChar((cAlias)->code_cc))
    oJson['desc_cc']            := Alltrim(cValToChar((cAlias)->desc_cc))
    oJson['status']             := (cAlias)->status
    oJson['uddi']               := Alltrim(cValToChar((cAlias)->company)) + Alltrim(cValToChar((cAlias)->subsidiary)) + Alltrim(cValToChar((cAlias)->code))

    //
    cJson := oJson:toJSON()

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - geraJson - cJson " + cJson )

    //
    FreeObj(oJson)
    oJson := Nil
    RestArea(aArea)

Return cJson

/*/{Protheus.doc} envReq
    Envia requisição.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function envReq(cServico,cMetodo,cBodyRq,cMsg,aResponse) //Everson -27/05/2020. Chamado T.I.

    //Variáveis.
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local cUrl			:= ""
	Local oRestClient 	:= Nil
	Local lRest			:= .F.

    //
    Private aCabecalho	:= {} //Everson -27/05/2020. Chamado T.I.
    Private cBody       := cBodyRq //Everson -27/05/2020. Chamado T.I.

    //
	Default cServico	:= ""
	Default cMetodo		:= ""
	Default cBody		:= ""
	Default cMsg		:= ""
	Default aResponse	:= {}

	//Obtém cabecalho para envio de requisições.
	aCabecalho := aResponse[1][1]

	//Obtém url.
	cUrl := aResponse[1][2]

	//Adiciona o end-point ao cliente Rest.
	oRestClient := FWRest():New(cUrl)

    //Adiciona o caminho ao cliente Rest.
	If cMetodo == "PATCH"
		cServico += "?_HttpMethod=PATCH"
		cMetodo  := "POST"

	EndIf
	
    //
	oRestClient:setPath(cServico)

    //Everson -27/05/2020. Chamado T.I.
	//Realiza requisição ao serviço.
	if cMetodo  $"POST/PATCH"
		oRestClient:SetPostParams(cBody)
		lRest := &("oRestClient:" + cMetodo + "(aCabecalho)")

	ElseIf cMetodo  $"PUT/DELETE"
		lRest := &("oRestClient:" + cMetodo + "(aCabecalho, cBody)")

	EndIf

	//
	cMsg := ""
	If ! lRest

        //
		If Substr(Alltrim(cValToChar(oRestClient:GetLastError())),1,1) <> "2" 

            //
			cMsg := Alltrim(cValToChar(oRestClient:GetLastError())) + Chr(13) + Chr(10)
			cMsg += "Headers: "  + Chr(13) + Chr(10) + "1 " + cValToChar(aCabecalho[1]) + Chr(13) + Chr(10) + "2 " + cValToChar(aCabecalho[2]) + Chr(13) + Chr(10)
			cMsg += "URL: "      + cUrl + Chr(13) + Chr(10)
			cMsg += "EndPoint: " + cServico + Chr(13) + Chr(10)
			cMsg += "Método: "   + cMetodo + Chr(13) + Chr(10)
			cMsg += "Body: "     + Chr(13) + Chr(10) + cValToChar(cBody) + Chr(13) + Chr(10)
			cMsg += "Resp: "     + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetResult())) + Chr(13) + Chr(10)
			lRet := .F.

		EndIf

	EndIf
	
	//Converte a string json em objeto.
	If lRet 

        //
        cMsg := Alltrim(cValToChar(oRestClient:GetResult()))

	EndIf

	//
	FreeObj(oRestClient)
	oRestClient := Nil
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} tratSucess
    Grava id da api no cadastro do funcionário.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function tratSucess(cMsg,cEmp,cFil,cMat)
    
    //Variáveis.
    Local aArea := GetArea()
    Local oJson := JsonObject():new()
    Local cId   := ""

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - tratSucess - cMsg " + cMsg )

    //
    oJson:fromJson(cMsg)
    cId := cValToChar(oJson['id'])

    //
    FreeObj(oJson)
    oJson := Nil
    
    //
    // @history ticket 7791 - Fernando Macieira - 19/01/2021 - INTEGRAÇÃO RM X AUTTRAN
    

    cUpt := " UPDATE OPENQUERY ( " + cLinked + ",
    cUpt += " ' SELECT RA_XIDAWS
    cUpt += " FROM [" + cSGBD + "].[DBO].[PFCOMPL]
    cUpt += " WHERE CODCOLIGADA = ''"+cEmp+"''
    cUpt += " AND CHAPA = ''"+cMat+"'' ' )      
    cUpt += " SET RA_XIDAWS = '"+cID+"'
    //

    //
    If TCSqlExec(cUpt) < 0
        Conout( DToC(Date()) + " " + Time() + " ADGPE056P - tratSucess " + TCSQLError() )
    EndIf

    //
    Conout( DToC(Date()) + " " + Time() + " ADGPE056P - tratSucess - cUpt " + cUpt )

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} envErros
    Gera log de erro.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function envErros(cMsg)

    //Variáveis.
    Local aArea := GetArea()
    Local cPara := GetMv("MV_#EAWS",,"")//"everson.silva@adoro.com.br"

    //
	Conout( DToC(Date()) + " " + Time() + " ADGPE056P - envErros - cMsg " + cMsg)
	U_enviarEmail(cPara,"Erro Integração AWS (Auttran)", "ADGPE056P - envErros" + Chr(13) + Chr(10) + cMsg)

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} logZBN
    Gera log do Job na tabela ZBN.
    @type  Static Function
    @author Everson
    @since 21/05/2020
    @version 01
/*/
Static Function logZBN(cStatus)

	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE056P'))

		RecLock("ZBN",.F.)

            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= 'ADGPE056P'
            ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

            ZBN_FILIAL  := xFilial("ZBN")
            ZBN_DATA    := Date()
            ZBN_HORA    := cValToChar(Time())
            ZBN_ROTINA	:= 'ADGPE056P'
            ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

    //
	RestArea(aArea)

Return Nil
