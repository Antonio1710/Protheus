#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"


/*/{Protheus.doc} User Function ³ADCON009R
	Relatorio Divergências de local padrão..
	Chamado 037729
	@type  Function
	@author Everson Silva 
	@since 13/11/17
	@version 01
	@history Ticket: T.I   - 24/05/2019 - Adriana Oliveira - Devido a substituicao email para shared-relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Ticket: 63022 - 28/10/2021 - Fernando Sigoli  - parametrizar o email anexo para listar em ordem decrescente pela data de digitação? (o mais recente primeiro)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33

/*/

User Function ADCON009R()

	Local cEmp 		:= "01"
	Local cFil 		:= "02"

	//Inicia o ambiente.
	RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADCON009R", .T., .F.)
		ConOut("[ADCON009R] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	logZBN("1")

	//	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	procRel()

	logZBN("2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADCON009R")

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³procRel        ºAutor  ³Everson         ºData ³  13/11/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera relatório.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado  037973.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function procRel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cAssunto	:= "Divergências de local padrão."
	Local cMensagem	:= ""
	Local cEmail	:= GetMv("MV_#DIVCON")
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
	cMensagem += '<p style="color:red">Seguem abaixo divergências de local padrão.</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Tipo</td>'
	cMensagem += '<td>Filial</td>'
	cMensagem += '<td>Dt. Emissão</td>'
	cMensagem += '<td>Dt. Digitação</td>'
	cMensagem += '<td>Doc.</td>'
	cMensagem += '<td>Série</td>'
	cMensagem += '<td>Tipo</td>'
	cMensagem += '<td>Cli/For</td>'
	cMensagem += '<td>Loja</td>'
	cMensagem += '<td>Nome</td>'
	cMensagem += '<td>Conta_Doc</td>'
	cMensagem += '<td>Conta_Cad</td>'
	cMensagem += '<td>Produto</td>'
	cMensagem += '<td>Desc</td>'
	cMensagem += '<td>Local Doc.</td>'
	cMensagem += '<td>Local Padrão</td>'
	cMensagem += '</tr>'

	TcQuery cQuery New Alias "DADOS"
	DbSelectArea("DADOS")
	DADOS->(DbGoTop())

	While ! DADOS->(Eof())

		cMensagem += '<tr>'

		cMensagem += '<td>' + cValToChar(DADOS->TIPO)      + '</td>'		
		cMensagem += '<td>' + cValToChar(DADOS->FILIAL)    + '</td>'
		
		cMensagem += '<td>' + cValToChar(DADOS->DT_EMISSAO)  + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->DT_DIGIT)    + '</td>'
		
		cMensagem += '<td>' + cValToChar(DADOS->DOC)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->SERIE)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->TIPO_DOC)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->CODFORCLI) + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->LOJA)      + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->NOME)      + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->CONTA_DOC) + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->CONTA_CAD) + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->PRODUTO)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->DESCPRD)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->LOCAL_DOC) + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->LOCAL_PRD) + '</td>'

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
±±ºPrograma  ³scriptSql      ºAutor  ³Everson         ºData ³  13/11/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado  037973.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function scriptSql()

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cData		:= DToS(Date() - 45)

	//
	/*
	cQuery := ""
	cQuery += " SELECT     " 
	cQuery += " FONTE.TIPO,     " 
	cQuery += " FONTE.D1_FILIAL AS FILIAL,    " 
	cQuery += " FONTE.TIPODOC,    " 
	cQuery += " FONTE.DT_EMISSAO,   " 
	cQuery += " FONTE.DT_DIGIT,   " 
	cQuery += " FONTE.D1_DOC AS DOC,     " 
	cQuery += " FONTE.D1_SERIE AS SERIE,     " 
	cQuery += " FONTE.D1_FORNECE AS CODFORCLI,     " 
	cQuery += " FONTE.D1_LOJA AS LOJA,     " 
	cQuery += " FONTE.A2_NOME AS NOME,     " 
	cQuery += " FONTE.D1_CONTA AS CONTA_DOC,     " 
	cQuery += " FONTE.B1_CONTA AS CONTA_CAD,     " 
	cQuery += " FONTE.D1_COD AS PRODUTO,  " 
	cQuery += " FONTE.B1_DESC AS DESCPRD,    " 
	cQuery += " FONTE.D1_LOCAL AS LOCAL_DOC,     " 
	cQuery += " FONTE.LOCPAD AS LOCAL_PRD, FONTE.D1_TIPO AS TIPO_DOC     " 
	cQuery += " FROM     " 
	cQuery += " (    " 
	cQuery += " SELECT      " 
	cQuery += " 'ENTRADA' AS TIPO,*     " 
	cQuery += " FROM     " 
	cQuery += " (   " 
	cQuery += " SELECT     " 
	cQuery += " D1_FILIAL, D1_DOC, D1_SERIE,      " 
	cQuery += " D1_FORNECE, D1_LOJA, A2_NOME,     " 
	cQuery += " D1_CONTA, B1_CONTA, D1_COD, D1_LOCAL ,   " 
	cQuery += " CASE WHEN    " 
	cQuery += " (SELECT BZ_LOCPAD FROM  " + RetSqlName("SBZ") + "  AS SBZ (NOLOCK) WHERE SBZ.D_E_L_E_T_ = '' AND SBZ.BZ_FILIAL = D1_FILIAL AND SBZ.BZ_COD = D1_COD) IS NULL   " 
	cQuery += " THEN   " 
	cQuery += " B1_LOCPAD   " 
	cQuery += " ELSE   " 
	cQuery += " (SELECT BZ_LOCPAD FROM  " + RetSqlName("SBZ") + "  AS SBZ (NOLOCK) WHERE SBZ.D_E_L_E_T_ = '' AND SBZ.BZ_FILIAL = D1_FILIAL AND SBZ.BZ_COD = D1_COD)   " 
	cQuery += " END AS LOCPAD,   " 
	cQuery += " D1_TIPO AS TIPODOC,   " 
	cQuery += " CONVERT(VARCHAR(10),CAST(D1_EMISSAO AS DATE),103) AS DT_EMISSAO,   " 
	cQuery += " CONVERT(VARCHAR(10),CAST(D1_DTDIGIT AS DATE),103) AS DT_DIGIT, " 
	cQuery += " B1_DESC, D1_TIPO  " 
	cQuery += " FROM     " 
	cQuery += " " + RetSqlName("SD1") + "   AS SD1 (NOLOCK)     " 
	cQuery += " INNER JOIN     " 
	cQuery += " " + RetSqlName("SB1") + "  AS SB1 (NOLOCK)     " 
	cQuery += " ON D1_COD = B1_COD      " 
	cQuery += " INNER JOIN     " 
	cQuery += " " + RetSqlName("SA2") + "   AS SA2 (NOLOCK)     " 
	cQuery += " ON D1_FORNECE = A2_COD     " 
	cQuery += " AND D1_LOJA = A2_LOJA  " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SF4") + " AS SF4 (NOLOCK) " 
	cQuery += " ON D1_TES = F4_CODIGO    " 
	cQuery += " WHERE     " 
	cQuery += " SD1.D_E_L_E_T_ = ''     " 
	cQuery += " AND SB1.D_E_L_E_T_ = ''       " 
	cQuery += " AND SA2.D_E_L_E_T_ = ''     " 
	cQuery += " AND SD1.D1_DTDIGIT >= '" + cData + "'  " 
	cQuery += " AND SF4.D_E_L_E_T_ = '' " 
	cQuery += " AND F4_ESTOQUE = 'S'  " 
	cQuery += " ) AS ENTRADA    " 
	cQuery += " WHERE     " 
	cQuery += " ENTRADA.D1_LOCAL <> ENTRADA.LOCPAD    " 
	cQuery += "     " 
	cQuery += " ) AS FONTE     " 
	cQuery += " ORDER BY FONTE.TIPO, FONTE.DT_DIGIT DESC " //FONTE.DT_EMISSAO 
	*/

	cQuery := ""
	cQuery += " SELECT     "    
	cQuery += " FONTE.TIPO,      "    
	cQuery += " FONTE.D1_FILIAL AS FILIAL,     "     
	cQuery += " FONTE.TIPODOC,      "
	cQuery += " CONVERT(VARCHAR(10),CAST(FONTE.D1_EMISSAO AS DATE),103) AS DT_EMISSAO,     "  
	cQuery += " CONVERT(VARCHAR(10),CAST(FONTE.D1_DTDIGIT AS DATE),103) AS DT_DIGIT,       "
	cQuery += " FONTE.D1_DOC AS DOC,      "
	cQuery += " FONTE.D1_SERIE AS SERIE,  " 
	cQuery += " FONTE.D1_FORNECE AS CODFORCLI,  "   
	cQuery += " FONTE.D1_LOJA AS LOJA,  "     
	cQuery += " FONTE.A2_NOME AS NOME,  "      
	cQuery += " FONTE.D1_CONTA AS CONTA_DOC,  "      
	cQuery += " FONTE.B1_CONTA AS CONTA_CAD,  "      
	cQuery += " FONTE.D1_COD AS PRODUTO,  "  
	cQuery += " FONTE.B1_DESC AS DESCPRD,  "     
	cQuery += " FONTE.D1_LOCAL AS LOCAL_DOC,  "     
	cQuery += " FONTE.LOCPAD AS LOCAL_PRD, FONTE.D1_TIPO AS TIPO_DOC  "
	cQuery += " FROM     " 
	cQuery += " (   " 
	cQuery += " SELECT  "    
	cQuery += " 'ENTRADA' AS TIPO,*  "     
	cQuery += " FROM     " 
	cQuery += " (   " 
	cQuery += " SELECT  "     
	cQuery += " D1_FILIAL, D1_DOC, D1_SERIE, "     
	cQuery += " D1_FORNECE, D1_LOJA, A2_NOME,  "   
	cQuery += " D1_CONTA, B1_CONTA, D1_COD, D1_LOCAL , "   
	cQuery += " CASE WHEN  "  
	cQuery += " (SELECT BZ_LOCPAD FROM   " + RetSqlName("SBZ") + "   AS SBZ (NOLOCK) WHERE SBZ.D_E_L_E_T_ = '' AND SBZ.BZ_FILIAL = D1_FILIAL AND SBZ.BZ_COD = D1_COD) IS NULL " 
	cQuery += " THEN "  
	cQuery += " B1_LOCPAD "  
	cQuery += " ELSE   "
	cQuery += " (SELECT BZ_LOCPAD FROM   " + RetSqlName("SBZ") + "   AS SBZ (NOLOCK) WHERE SBZ.D_E_L_E_T_ = '' AND SBZ.BZ_FILIAL = D1_FILIAL AND SBZ.BZ_COD = D1_COD) "  
	cQuery += " END AS LOCPAD, "  
	cQuery += " D1_TIPO AS TIPODOC,  "
	cQuery += " D1_EMISSAO, "
	cQuery += " D1_DTDIGIT, "
	cQuery += " B1_DESC, D1_TIPO "
	cQuery += " FROM   "  
	cQuery += " " + RetSqlName("SD1") + "   AS SD1 (NOLOCK)     "   
	cQuery += " INNER JOIN  "    
	cQuery += " " + RetSqlName("SB1") + "  AS SB1 (NOLOCK)     " 
	cQuery += " ON D1_COD = B1_COD  "    
	cQuery += " INNER JOIN  "   
	cQuery += " " + RetSqlName("SA2") + "   AS SA2 (NOLOCK)     "  
	cQuery += " ON D1_FORNECE = A2_COD  "    
	cQuery += " AND D1_LOJA = A2_LOJA "  
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SF4") + " AS SF4 (NOLOCK) " 
	cQuery += " ON D1_TES = F4_CODIGO   "
	cQuery += " WHERE "    
	cQuery += " SD1.D_E_L_E_T_ = '' "   
	cQuery += " AND SB1.D_E_L_E_T_ = '' "     
	cQuery += " AND SA2.D_E_L_E_T_ = '' "    
	cQuery += " AND SD1.D1_DTDIGIT >= '" + cData + "'  " 
	cQuery += " AND SF4.D_E_L_E_T_ = '' " 
	cQuery += " AND F4_ESTOQUE = 'S' "
	cQuery += " ) AS ENTRADA WHERE  "  
	cQuery += " ENTRADA.D1_LOCAL <> ENTRADA.LOCPAD "
	cQuery += " ) AS FONTE "
	cQuery += " ORDER BY FONTE.TIPO,FONTE.D1_DTDIGIT DESC "

	RestArea(aArea)

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³processarEmail ºAutor  ³Everson         ºData ³  13/11/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configurações de e-mail.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado  037973.                                            º±±
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
±±ºPrograma  ³logZBN            º Autor ³ Everson º Data ³  13/11/2017    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera log na ZBN.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 037973.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function logZBN(cStatus)

	Local aArea	:= GetArea()

	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADCON009R'))

		RecLock("ZBN",.F.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADCON009R'
		ZBN_STATUS	:= cStatus

		MsUnlock() 

	Else

		RecLock("ZBN",.T.)

		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= 'ADCON009R'
		ZBN_STATUS	:= cStatus

		MsUnlock() 	

	EndIf

	ZBN->(dbCloseArea())

	//
	RestArea(aArea)

Return Nil
