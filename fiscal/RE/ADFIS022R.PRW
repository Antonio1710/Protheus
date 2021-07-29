#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
/*/{Protheus.doc} User Function ADFIS022R
	Relatório de Entradas sem passar pela Central XML
	@type  Function
	@author Fernando Sigoli
	@since 29/03/2018
	@version 1
	@history Chamado 048580 - FWNM        - 13/05/2019 - OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW
	@history Chamado TI     - Adriana     - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Ticket  17013  - Abel Babini - 27/07/2021 - Criado filtro para não demonstrar Pré-Notas (F1_STATUS <> '')
	/*/

User Function ADFIS022R()   //U_ADFIS022R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cEmp 		:= "01"
	Local cFil 		:= "02"

	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADFIS022R", .T., .F.)
		ConOut("[ADFIS022R] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	logZBN("1")

	PtInternal(1,ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de Entradas sem passar pela Central XML')

	procRel()

	logZBN("2")

	//Fecha o ambiente.
	RpcClearEnv()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIS022R")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³procRel        ºAutor  ³Fernando Sigoli ºData ³  29/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera relatório.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function procRel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cAssunto	:= "Entradas sem passar pela Central XML"
	Local cMensagem	:= ""
	Local cEmail	:= GetMv("MV_#DIVXML")
	Local cQuery	:= ""

	//
	cQuery := scriptSql()

	//
	If Select("DADOS") > 0
		DADOS->(DbCloseArea())

	EndIf

	//
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">Seguem abaixo entradas sem passar pela Central XML.</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Filial</td>'
	cMensagem += '<td>Tipo</td>'
	cMensagem += '<td>Especie</td>'
	cMensagem += '<td>Doc.</td>'
	cMensagem += '<td>Série</td>'
	cMensagem += '<td>Cli/For</td>'
	cMensagem += '<td>Nome</td>'
	cMensagem += '<td>R$ Itens</td>'
	cMensagem += '<td>R$ Total</td>'
	cMensagem += '<td>Dt. Emissão</td>'
	cMensagem += '<td>Dt. Digitação</td>'
	cMensagem += '<td>Chave</td>'
	cMensagem += '</tr>'

	TcQuery cQuery New Alias "DADOS"
	DbSelectArea("DADOS")
	DADOS->(DbGoTop())

	While ! DADOS->(Eof())

		cMensagem += '<tr>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_FILIAL)    + '</td>'		
		cMensagem += '<td>' + cValToChar(DADOS->F1_TIPO)      + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_ESPECIE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_DOC)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_SERIE)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_FORNECE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->NOME)         + '</td>' 
		cMensagem += '<td>' + cValToChar(Transform(DADOS->F1_VALMERC,"@E 999,999,999.99"))   + '</td>' 
		cMensagem += '<td>' + cValToChar(Transform(DADOS->F1_VALBRUT,"@E 999,999,999.99"))   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_EMISSAO)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_DTDIGIT)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_CHVNFE)    + '</td>'

		cMensagem += '</tr>'

		DADOS->(DbSkip())

	EndDo
	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'

	DADOS->(DbCloseArea())

	//
	processarEmail(cAssunto,cMensagem,cEmail)

	//
	RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³scriptSql ºAutor  ³Fernando Sigoli     ºData  ³  29/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function scriptSql()

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cData		:= DToS(Date() - 3)
	
	Local cF1Origem := GetMV("MV_#LFVSF1",,"FRANGOVI") // Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 13/05/2019
	
	cQuery := " "
	cQuery += "  SELECT "
	cQuery += "  F1_FILIAL, F1_TIPO,F1_ESPECIE,F1_DOC,F1_SERIE,RTRIM(LTRIM(F1_FORNECE+'-'+F1_LOJA)) AS F1_FORNECE, "
	cQuery += "  CASE "
	cQuery += "  WHEN F1_TIPO = 'D' "  
	cQuery += "  THEN (SELECT A1_NOME FROM " + RetSqlName("SA1") + " with (nolock)  WHERE A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') " 
	cQuery += "  ELSE "
	cQuery += "  (SELECT A2_NOME FROM  " + RetSqlName("SA2") + "  with (nolock) WHERE A2_COD = F1_FORNECE AND A2_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') "
	cQuery += "  END NOME, " 
	cQuery += "  F1_VALMERC, F1_VALBRUT, " 
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) AS F1_EMISSAO, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) AS F1_DTDIGIT, " 
	cQuery += "  F1_CHVNFE ,NFXML.XML_CHAVE  "
	cQuery += "  FROM " + RetSqlName("SF1") + " SF1 with (nolock) left outer join RECNFXML (nolock) NFXML ON SF1.F1_CHVNFE = NFXML.XML_CHAVE AND NFXML.D_E_L_E_T_ = '' "
    cQuery += "  WHERE SF1.F1_DTDIGIT >= '" + cData + "'   "   
	cQuery += "  AND SF1.F1_FILIAL IN ('02','03','04','05','08','09')   "
	cQuery += "  AND SF1.F1_SERIE NOT IN ('VC')  "
	cQuery += "  AND SF1.F1_ESPECIE IN ('SPED')  "
	cQuery += "  AND SF1.D_E_L_E_T_ = ''  "   
	cQuery += "  AND SF1.F1_FORMUL  <> 'S'  "
	cQuery += "  AND SF1.F1_ORIGEM  <> '" + cF1Origem + "'  " // Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 13/05/2019
	cQuery += "  AND SF1.F1_STATUS  <> '' " //Ticket  17013  - Abel Babini - 27/07/2021 - Criado filtro para não demonstrar Pré-Notas (F1_STATUS <> '')
	cQuery += "  AND NFXML.XML_KEYF1 IS NULL  "
	
	cQuery += "  UNION ALL "
	
	cQuery += "  SELECT "
	cQuery += "  F1_FILIAL, F1_TIPO,F1_ESPECIE,F1_DOC,F1_SERIE,RTRIM(LTRIM(F1_FORNECE+'-'+F1_LOJA)) AS F1_FORNECE, " 
	cQuery += "  CASE " 
	cQuery += "  WHEN F1_TIPO = 'D' " 
	cQuery += "  THEN (SELECT A1_NOME FROM " + RetSqlName("SA1") + " with (nolock)  WHERE A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA AND D_E_L_E_T_ = '')  "
	cQuery += "  	ELSE  "
	cQuery += "  (SELECT A2_NOME FROM " + RetSqlName("SA2") + "  with (nolock) WHERE A2_COD = F1_FORNECE AND A2_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') "
	cQuery += "  	END NOME, " 
	cQuery += "  F1_VALMERC, F1_VALBRUT, " 
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) AS F1_EMISSAO, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) AS F1_DTDIGIT, " 
	cQuery += "  F1_CHVNFE,CTEXML.XML_CHAVE "
	cQuery += "  FROM " + RetSqlName("SF1") + " SF1 with (nolock) left outer join  RECNFCTE (nolock) CTEXML ON SF1.F1_CHVNFE = CTEXML.XML_CHAVE AND CTEXML.D_E_L_E_T_ = ''  "
	cQuery += "  WHERE SF1.F1_DTDIGIT >= '" + cData + "'   "     
	cQuery += "  AND SF1.F1_FILIAL IN ('02','03','04','05','08','09') "
	cQuery += "  AND SF1.F1_ESPECIE IN ('CTE','CTEOS') " 
	cQuery += "  AND SF1.D_E_L_E_T_ = '' "
	cQuery += "  AND SF1.F1_FORMUL  <> 'S'  "
	cQuery += "  AND SF1.F1_ORIGEM  <> '" + cF1Origem + "'  " // Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 13/05/2019
	cQuery += "  AND SF1.F1_STATUS  <> '' " //Ticket  17013  - Abel Babini - 27/07/2021 - Criado filtro para não demonstrar Pré-Notas (F1_STATUS <> '')
	cQuery += "  AND XML_KEYF1 IS NULL "
	cQuery += "  ORDER BY SF1.F1_FILIAL, SF1.F1_DOC  "
		
	/*
	cQuery := " "
	cQuery += "  SELECT  " 
	cQuery += "  F1_FILIAL, F1_TIPO,F1_ESPECIE,F1_DOC,F1_SERIE,RTRIM(LTRIM(F1_FORNECE+'-'+F1_LOJA)) AS F1_FORNECE,"
	cQuery += "  CASE "
	cQuery += "  WHEN F1_TIPO = 'D' " 
	cQuery += "  THEN (SELECT A1_NOME FROM " + RetSqlName("SA1") + " with (nolock)  WHERE A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') "
	cQuery += "  ELSE "
	cQuery += "  (SELECT A2_NOME FROM " + RetSqlName("SA2") + "  with (nolock) WHERE A2_COD = F1_FORNECE AND A2_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') "
	cQuery += "  END NOME, "
	cQuery += "  F1_VALMERC, F1_VALBRUT, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) AS F1_EMISSAO, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) AS F1_DTDIGIT, "
	cQuery += "  F1_CHVNFE "
	cQuery += "  FROM " + RetSqlName("SF1") + " SF1 with (nolock) left outer join  RECNFXML (nolock) NFXML ON SF1.F1_CHVNFE = NFXML.XML_CHAVE "
    cQuery += "  WHERE SF1.F1_DTDIGIT >= '" + cData + "'   " 
	cQuery += "  AND SF1.F1_FILIAL IN ('02','03','04','05','08','09') "
	cQuery += "  AND SF1.F1_SERIE NOT IN ('VC') "  
	cQuery += "  AND SF1.F1_ESPECIE IN ('SPED') "
	cQuery += "  AND SF1.D_E_L_E_T_ = '' "   
	cQuery += "  AND SF1.F1_FORMUL  <> 'S' "
	cQuery += "  AND (XML_KEYF1 IS NULL ) " 
	
	cQuery += "  UNION ALL "
	
	cQuery += "  SELECT "  
	cQuery += "  F1_FILIAL, F1_TIPO,F1_ESPECIE,F1_DOC,F1_SERIE,RTRIM(LTRIM(F1_FORNECE+'-'+F1_LOJA)) AS F1_FORNECE, "
	cQuery += "  CASE   "
	cQuery += "  WHEN F1_TIPO = 'D' "
	cQuery += "  THEN (SELECT A1_NOME FROM " + RetSqlName("SA1") + " with (nolock)  WHERE A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA AND D_E_L_E_T_ = '') "
	cQuery += "  	ELSE  "
	cQuery += "  (SELECT A2_NOME FROM " + RetSqlName("SA2") + "  with (nolock) WHERE A2_COD = F1_FORNECE AND A2_LOJA  = F1_LOJA AND D_E_L_E_T_ = '')" 
	cQuery += "  	END NOME, "
	cQuery += "  F1_VALMERC, F1_VALBRUT, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) AS F1_EMISSAO, "
	cQuery += "  CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) AS F1_DTDIGIT, "
	cQuery += "  F1_CHVNFE  "
	cQuery += "  FROM " + RetSqlName("SF1") + " SF1 with (nolock) left outer join  RECNFCTE (nolock) NFXML ON SF1.F1_CHVNFE = NFXML.XML_CHAVE "
	cQuery += "  WHERE SF1.F1_DTDIGIT >= '" + cData + "'   "    
	cQuery += "  AND SF1.F1_FILIAL IN ('02','03','04','05','08','09') "
	cQuery += "  AND SF1.F1_ESPECIE IN ('CTE','CTEOS') "
	cQuery += "  AND SF1.D_E_L_E_T_ = '' "
	cQuery += "  AND SF1.F1_FORMUL  <> 'S' "
	cQuery += "  AND (XML_KEYF1 IS NULL)  "
	cQuery += "  ORDER BY SF1.F1_FILIAL, SF1.F1_DOC "
	*/
	
	RestArea(aArea)

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³processarEmail ºAutor  ³Fernando Sigoli ºData ³  29/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configurações de e-mail.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function processarEmail(cAssunto,cMensagem,email)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""   
	Local cSubject      := ""

	//Assunto do e-mail.
	cSubject := cAssunto

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	//
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)

		Else
			lAutOk := .T.

		EndIf

	EndIf

	//
	If lOk .And. lAutOk   

		//Envia o e-mail.     
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  

		//Tratamento de erro no envio do e-mail.          
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)

		EndIf

	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server

	EndIf

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³logZBN       ºAutor  ³Fernando Sigoli ºData ³  29/03/2018   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera log na ZBN.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso: Adoro S/A                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIS022R'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADFIS022R'
		ZBN_DESCRI  := 'ENTRADAS SEM PASSAR PELA CENTRAL XML'
		ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADFIS022R'
		ZBN_DESCRI  := 'ENTRADAS SEM PASSAR PELA CENTRAL XML'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	//
	RestArea(aArea)

Return Nil
