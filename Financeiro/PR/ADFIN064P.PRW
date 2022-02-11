#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'Topconn.ch'
#include "rwmake.ch"
#include "TbiConn.ch"

/*/{Protheus.doc} ADFIN064P
	Web service utilizado no app Central de aprovação. 
	@type  Function
	@author Ricardo Lima
	@since 14/11/2019
	@version 01
	@history Chamado TI     - Ricardo Lima      - 13/12/2018 - Inclusão da moeda do pedido         
	@history Chamado TI     - Ricardo Lima      - 22/01/2019 - Ajuste para Aprovação de Projetos
	@history Chamado TI     - Ricardo Lima      - 30/01/2019 - Ajuste string Json - Retirado 
	@history Chamado TI     - Ricardo Lima      - 04/02/2019 - Ajuste string Json em campos de texto livre 
	@history Chamado TI     - Ricardo Lima      - 11/02/2019 - tratativa para pedido eliminado por residuo 
	@history Chamado 047526 - Ricardo Lima      - 26/02/2019 - AJUSTE NO JSON DE PROJETOS
	@history Chamado 043065 - Ricardo Lima      - 07/08/2018 - WebService rest para central de aprovação mobile
	@history Chamado 043065 - Ricrado Lima      - 14/08/2018 - WebService Rest para Aprovação de Pedido de Compra Mobile 
	@history Chamado TI     - Ricardo Lima      - 12/11/2018 - Ajuste na quebra de pagina
	@history Chamado 045097 - Everson           - 22/11/2018 - Aprovação de pedidos de compra - SAG
	@history Chamado TI     - Ricardo Lima      - 03/12/2018 - comentado query, a mesma estava gerando lentidao no logon    |
	@history Chamado TI     - Everson           - 06/03/2019 - Tratamento para correção de erros em observação e desenvolvida funcinalidade para verificar pedidos pendentes de aprovação
	@history Chamado TI     - Everson           - 29/03/2019 - Adiciona rotina para exibir histórico de aprovação/rejeição
	@history Chamado 048432 - Everson           - 09/04/2019 - Adiciona rotina para remover caracteres especiais 
	@history Chamado 044314 - Everson           - 15/04/2019 - Tratamento para exibir observações dos registros de frete 
	@history Chamado 047440 - FWNM              - 30/04/2019 - Alcada aprovacao projetos investimentos (Aprov/Vistador) 
	@history Chamado 044314 - Everson           - 27/05/2019 - Incluída a observação do frete combinado 
	@history Chamado TI     - Everson           - 25/07/2019 - Incluída a empresa 03 para aprovação de pedido de compra 
	@history Chamado TI     - Everson           - 01/08/2019 - Incluída a empresa 03 para aprovação de pedido de compra 
	@history Chamado 051599 - Everson           - 06/09/2019 - Incluída a empresa 09 para aprovação de pedido de compra 
	@history Chamado 052008 - Abel Babini Filho - 27/09/2019 - Alteracao de Filtro no ZC7_NIVEL para filtrar apenas o proprio nivel e nao visualizar os itens dos niveis inferiores 
	@history Chamado TI     - Everson           - 14/11/2019 - Adicionada a empresa Safeeg na aprovação de projeto.
	@history Chamado 053347 - FWNM              - 09/12/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
	@history Chamado 053678 - FWNM              - 09/12/2019 - 053678 || OS 055067 || FINANCAS || BIANCA || 8408 || CENTRAL APROVACAO
	@history Chamado 029028 - Everson           - 12/12/2019 - Tratamento para aprovação de fretes de frango vivo.
	@history Chamado TI     - Everson           - 02/01/2020 - Tratamento para aprovador substituto.
	@history Chamado 055029 - Everson           - 17/01/2020 - Tratamento para carregar o campo de observações internas do pedido de compra.
	@history Chamado 055321 - FWNM              - 05/02/2020 - OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE
	@history Chamado TI     - Everson           - 19/02/2020 - Adicionada empresa 06 nas aprovações de pedidos de compra.
	@history Chamado 054941 - Everson           - 16/03/2020 - Adicionada a aprovação de ocorrências de frete na empresa 07. 
	@history Chamado TI     - Fernando          - 08/04/2020 - Adicionado a glausula E2.D_E_L_E_T_ = ' ' 
	@history Chamado 057440 - FWNM              - 22/04/2020 - OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO
	@history Chamado TI     - Everson           - 08/05/2020 - Liberar aprovações de pedidos de compra da empresa Simplify no app.
	@history Chamado 059326 - Everson           - 11/08/2020 - Aprovações de registros de frete na empresa Ceres (02).
	@history Chamado 2014   - Everson           - 21/09/2020 - Tratamento para aprovação de títulos pelo app.
	@history Chamado 4734   - Everson           - 09/11/2020 - Incluído novo campo de observação nas aprovações de projeto/título.
	@history Chamado 4734   - Everson           - 09/11/2020 - Incluído novo campo de observação nas aprovações de projeto/título.
	@history Ticket  5241   - William Costa     - 18/11/2020 - Adicionada a aprovação de projetos na empresa 07. 
	@history Ticket 10986   - Fernando Macieira - 15/03/2021 - App de aprovação - melhorias
	@history Ticket 44493   - Abel Babini       - 28/09/2021 - Adicionado empresa Simplify
	@history ticket 18141   - Fernando Macieira - 27/10/2021 - RM - Acordos - Integração Protheus
	@history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML
/*/
User Function ADFIN064P
// Função para compilar metodos webservice
Return Nil

/*/{Protheus.doc} nomeFunction
	Web Service CentralAprovacao. Chamado 043065.
	@type  Function
	@author user
	@since 07/08/2018
	@version 01
/*/
WsRestFul CentralAprovacao Description "Serviço REST para Aprovação de Titulos, Integrado com o Sistema Protheus"

	WsMethod Get  Description "Metodo para Confirmar LogIn de Usuario"  WsSyntax "/CentralAprovacao"
	WsMethod Post Description "Metodo para listar itens da Central de Aprovação"  WsSyntax "/CentralAprovacao"
	WsMethod Put  Description "Metodo para Aprovar ou Reprovacao de Item na Central de Aprovação" WsSyntax "/CentralAprovacao"

End WsRestFul

/*/{Protheus.doc} Get
	Método Get
	WebService rest para central de aprovação mobile
	Retorna itens em Json para aprovação com filtro no aprovador
	Logado no AppMobile. Chamado 043065.
	@type  Function
	@author Ricardo Lima
	@since 07/08/2018
	@version 01
/*/
WsMethod Get WsService CentralAprovacao

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local cJsonRet      := ""
	Local cCodUser      := ""
	Local nNumCA 		:= 0
	Local nNumPC 		:= 0
	Local nNumDB 		:= 0
	Local nNumRF 		:= 0
	Local lUserADM 		:= 'false'
	
	Local cUsrTst := Self:GetHeader("ChkAdm") //Everson - 06/03/2019. Chamado T.I.

	////U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CentralAprovacao')
	
	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	
	EndIf

	If EMPTY(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("Obrigatório informar o Nome do Usuario!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf
	
	If FwIsAdmin()
		lUserADM := 'true'
	EndIf

	cJsonRet := '{'
	cJsonRet += '"NumCA": "'+Alltrim(TRANSFORM(nNumCA , "@E 999,999,999" ))+'",'
	cJsonRet += '"NumPC": "'+Alltrim(TRANSFORM(nNumPC , "@E 999,999,999" ))+'",'
	cJsonRet += '"NumDB": "'+Alltrim(TRANSFORM(nNumDB , "@E 999,999,999" ))+'",'
	cJsonRet += '"NumRF": "'+Alltrim(TRANSFORM(nNumRF , "@E 999,999,999" ))+'",'
	cJsonRet += '"UserAdm": '+lUserADM+' '
	cJsonRet += '}'
	
	cJsonRet := StrTran(cJsonRet,Chr(129),"")
	cJsonRet := StrTran(cJsonRet,Chr(141),"")
	cJsonRet := StrTran(cJsonRet,Chr(143),"")
	cJsonRet := StrTran(cJsonRet,Chr(144),"")
	cJsonRet := StrTran(cJsonRet,Chr(157),"")
	cJsonRet := StrTran(cJsonRet,Chr(9),"")
	cJsonRet := StrTran(cJsonRet,Chr(10),"")
	cJsonRet := StrTran(cJsonRet,Chr(13),"")
	
	cJsonRet := FwCutOff(cJsonRet,.F.)

	Self:SetResponse( EncodeUtf8( cJsonRet ) )
	ConOut("GET - Login Efetuado com Sucesso!")

	RestArea(aArea)
	MSUnlockAll()

Return .T.	

/*/{Protheus.doc} Post
	Método Post.
	WebService rest para central de aprovação mobile 
	Retorna itens em Json para aprovação com filtro no aprovador
	Logado no AppMobile. Chamado 043065.
	@type  Function
	@author Ricardo Lima
	@since 07/08/2018
	@version 01
/*/
WsMethod Post WsService CentralAprovacao

	//Variáveis.
    Local aArea			:= GetArea()
	Local cFormatAceito	:= "application/json"
	Local cBody			:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cUrlServ		:= Self:GetPath()
	Local cJsonRet     	:= ""
	Local cCodUser     	:= ""
	Local sMsgObs      	:= ""
	Local Nome_Fil     	:= ""
	Local sNivApr      	:= "10"
	Local lAprProj		:= .F.
	Local sNmcliZc7		:= '' // Ricardo Lima-26/02/2019
	Local cTpOp			:= "" //15/04/19 | Everson - Chamado 044314.
	Local cUsrTst       := Self:GetHeader("ChkAdm") //Everson - 06/03/2019. Chamado T.I.
	Local lVistador     := .t. // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
	Local lOk           := .f. // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
	
	//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
	Local nAprAus	:= 0
	Local nNivMen	:= 0
	Local cNivMen	:= ""
	Local cNivMen2	:= ""
	Local cQry		:= ""
	Local cTpBlFr	:= GetMv("MV_#FRTTBL",,"!XXXX!") //Everson - 12/12/2019 - Chamado 029058.

	//
	////U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CentralAprovacao')
	
	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	EndIf
	
	//
	If EMPTY(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("POST Central Aprovação - Obrigatório informar o Nome do Usuario!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf
	
	//
	dbSelectArea("ZC3")
	dbSetOrder(1)
	if dbSeek( FWxFilial("ZC3") + __cUserID )
		dbSelectArea("ZCF")
		dbSetOrder(2) 
		IF dbSeek( FWxFilial("ZCF") + ZC3->ZC3_CODUSU )
			sNivApr := IIF(ZCF->ZCF_NIVEL='01', "",ZCF->ZCF_NIVEL)
		Endif

		If !EMPTY( ZC3->ZC3_TABPRJ )
			lAprProj := .T.
		Endif

		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		If Select("CALF064P") > 0
			(CALF064P)->(dbCloseArea())
		Endif

		nNivMen	:= Val(ZCF->ZCF_NIVEL)-1
		cNivMen := IIF(nNivMen = 1,"001",STRZERO(nNivMen,3))
		cNivMen2 := IIF(nNivMen = 1,"",STRZERO(nNivMen,2))
		
		cQry := " SELECT COUNT(*) AS QTD_APRO "	 
		cQry += " FROM " + RetSqlName("ZC3") + " ZC3 "
		cQry += " WHERE ZC3.D_E_L_E_T_ = '' "
		cQry += " AND ZC3.ZC3_CODUSU <> '" + ZC3->ZC3_CODUSU + "' " 
		cQry += " AND ZC3.ZC3_NIVSEG <> '' "   
		cQry += " AND ZC3.ZC3_NIVSEG = '" + cNivMen + "' "
		cQry += " AND ZC3.ZC3_APRATV <> '1' "

		TcQuery cQry New Alias "CALF064P"
		
		nAprAus := CALF064P->QTD_APRO
		conout(">>>>> "+strzero(nAprAus,3))
		CALF064P->(dbCloseArea())
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel

		u_ADFIN120P() // @history ticket 18141   - Fernando Macieira - 27/10/2021 - RM - Acordos - Integração Protheus

		// ADORO
		cQuery := " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'01' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7010 ZC7 "
		cQuery += " INNER JOIN SA2010 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2010 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF010 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' "  //Chamado TI - Fernando Sigoli 08/04/2020
		
		cQuery += " UNION ALL "
		
		// ADORO E SUAS FILIAIS
		cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'01' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7010 ZC7 "
		cQuery += " INNER JOIN SA1010 A1 ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF010 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		
		cQuery += " UNION ALL "
		
		// ADORO E SUAS FILIAIS
		cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'01' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A4.A4_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'FRETE' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7010 ZC7 "
		cQuery += " INNER JOIN SA4010 A4 ON A4_COD=ZC7_CLIFOR AND A4_LOJTRA=ZC7_LOJA AND A4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " 	SELECT ZC3_APRASC FROM ZC3010 ZC3 WHERE ZC3_CODUSU = '"+__cUserID+"' AND ZC3.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'F' "
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		
		cQuery += " UNION ALL "

		IF lAprProj  // Ricardo Lima - 16/04/18	

			// ADORO E SUAS FILIAIS
			cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'01' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
			cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
			cQuery += " FROM ZC7010 ZC7 (NOLOCK) "
			cQuery += " INNER JOIN AF8010 AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
			
			// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
			cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
			//cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_USRAPR = ' ' AND AF8_XCODAP = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "			

			cQuery += " UNION ALL "

		ENDIF

		// CERES
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'02' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7020 ZC7 "
		cQuery += " INNER JOIN SA2020 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2020 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF020 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' "   //Chamado TI - Fernando Sigoli 08/04/2020
		
		cQuery += " UNION ALL "
		
		// CERES
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'02' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7020 ZC7 "
		cQuery += " INNER JOIN SA1020 A1 ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF020 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		
		cQuery += " UNION ALL "

		//Everson - 11/08/2020. Chamado 059326.
		cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'02' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A4.A4_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'FRETE' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " 
		cQuery += " '' AS DESC_NSEG "
		cQuery += " FROM ZC7020 ZC7 "
		cQuery += " INNER JOIN SA4020 A4 ON A4_COD=ZC7_CLIFOR AND A4_LOJTRA=ZC7_LOJA AND A4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " 	SELECT ZC3_APRASC FROM ZC3020 ZC3 WHERE ZC3_CODUSU = '"+__cUserID+"' AND ZC3.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'F' "
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		
		cQuery += " UNION ALL "
		//
		
		// RNX2
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'07' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7070 ZC7 "
		cQuery += " INNER JOIN SA2070 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2070 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF070 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' " //Chamado TI - Fernando Sigoli 08/04/2020
		
		cQuery += " UNION ALL "
		
		// RNX2
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'07' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7070 ZC7 "
		cQuery += " INNER JOIN SA1070 A1 ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF070 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "

		IF lAprProj  // William Costa 18/11/2020 - 
			cQuery += " UNION ALL "

			// RNX2
			cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'07' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " '' AS DESC_NSEG " 
			cQuery += " FROM ZC7070 ZC7 (NOLOCK) "
			cQuery += " INNER JOIN AF8070 AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
			
		ENDIF

		//Everson, 14/11/2019. Chamado T.I. - Descomentado código da empresa Safeeg.
		//adicionado empresa SAFEEG em 27/09/2019
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " UNION ALL "

		//Everson - 16/03/2020. Chamado 054946.
		cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'07' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A4.A4_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'FRETE' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
		cQuery += " '' AS DESC_NSEG "
		cQuery += " FROM ZC7070 ZC7 "
		cQuery += " INNER JOIN SA4070 A4 ON A4_COD=ZC7_CLIFOR AND A4_LOJTRA=ZC7_LOJA AND A4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " 	SELECT ZC3_APRASC FROM ZC3070 ZC3 WHERE ZC3_CODUSU = '"+__cUserID+"' AND ZC3.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'F' "
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " UNION ALL "
		//
		
		// SAFEGG
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'09' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "//Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7090 ZC7 "
		cQuery += " INNER JOIN SA2090 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2090 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF090 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' " //Chamado TI - Fernando Sigoli 08/04/2020
		
		cQuery += " UNION ALL "
		
		// SAFEGG
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'09' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " FROM ZC7090 ZC7 "
		cQuery += " INNER JOIN SA1090 A1 ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF090 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		//INICIO Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		//cQuery += " AND ZC7_NIVEL <= '"+sNivApr+"' " 
		//IF nAprAus = 0 // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
		If nAprAus == 0 .and. !Empty(sNivApr) // Chamado n. 055321 || OS 056879 || FINANCAS || EDUARDO || 8352 || APROVADOR AUSENTE - FWNM - 05/02/2020
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		ENDIF
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		//FIM Ch. 052008 | 27/09/2019 - Abel Babini Filho | Filtro de Aprovações pendentes apenas para o proprio nivel

		IF lAprProj  // Everson - 14/11/2019	
			cQuery += " UNION ALL "

			// SAFEGG
			cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'09' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " '' AS DESC_NSEG " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
			cQuery += " FROM ZC7090 ZC7 (NOLOCK) "
			cQuery += " INNER JOIN AF8090 AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
			
			// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
			cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
			//cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_USRAPR = ' ' AND AF8_XCODAP = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "			

			
		ENDIF

		//Everson - 21/09/2020. Chamado 2014.

			//GMSBS
			cQuery += " UNION ALL "
			
			cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'06' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "
			cQuery += " FROM ZC7060 ZC7 "
			cQuery += " INNER JOIN SA2060 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
			cQuery += " LEFT JOIN SE2060 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO "
			cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
			cQuery += " SELECT ZCF_CODIGO FROM ZCF060 ZCF WHERE ZCF_APROVA = '" + __cUserID + "' AND ZCF.D_E_L_E_T_ = ' ') "
			cQuery += " AND ZC7_RECPAG = 'P' "
			If nAprAus == 0 .and. !Empty(sNivApr)
				cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' "

			ELSE
				cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' "

			ENDIF
			cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
			cQuery += " AND E2.D_E_L_E_T_ = ' ' "

			cQuery += " UNION ALL "

			cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'06' ZC7EMP, ZC7_FILIAL, "
			cQuery += " ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, "
			cQuery += " ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, "
			cQuery += " ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, "
			cQuery += " ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " '' AS DESC_NSEG "
			cQuery += " FROM "
			cQuery += " ZC7060 ZC7 "
			cQuery += " INNER JOIN "
			cQuery += " SA1060 A1 ON "
			cQuery += " A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE "
			cQuery += " ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
			cQuery += " SELECT ZCF_CODIGO FROM ZCF060 ZCF WHERE ZCF_APROVA = '" + __cUserID + "' AND ZCF.D_E_L_E_T_ = ' ') "
			cQuery += " AND ZC7_RECPAG = 'R' "

			//
			If nAprAus == 0 .and. !Empty(sNivApr)
				cQuery += " AND ZC7_NIVEL >= '" + cNivMen2 + "' AND ZC7_NIVEL <= '" + sNivApr + "' "

			ELSE
				cQuery += " AND ZC7_NIVEL = '" + sNivApr + "' "

			ENDIF

			cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "

			//
			IF lAprProj
				cQuery += " UNION ALL "
				cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'06' ZC7EMP, ZC7_FILIAL, "
				cQuery += " ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, "
				cQuery += " ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, "
				cQuery += " ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, "
				cQuery += " ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
				cQuery += " '' AS DESC_NSEG "
				cQuery += " FROM "
				cQuery += " ZC7060 ZC7 (NOLOCK) "
				cQuery += " INNER JOIN "
				cQuery += " AF8060 AF8 ON "
				cQuery += " AF8_PROJET=ZC7_PROJET "
				cQuery += " AND AF8_REVISA=ZC7_REVPRJ "
				cQuery += " AND AF8.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE "
				cQuery += " ZC7_TPBLQ = '000003' "
				cQuery += " AND ZC7_DTAPR = ' ' "
				cQuery += " AND ZC7_REPROV = ' ' "
				cQuery += " AND ZC7_USRAPR = '"+ __cUserID +"' "
				cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
				
			ENDIF
		//
		//*************************************************************************************
		//INICIO Ticket 44493   - Abel Babini       - 28/09/2021 - Adicionado empresa Simplify
		//*************************************************************************************
		cQuery += " UNION ALL "
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " 
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "
		cQuery += " FROM ZC7100 ZC7 "
		cQuery += " INNER JOIN SA2100 A2 ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2100 E2 ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO " //Ch. 052008 | 27/09/2019 - Abel Babini Filho | Descricao do Bloqueio por Nivel de Seguranca
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF100 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		If nAprAus == 0 .and. !Empty(sNivApr) 
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " 
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " 
		ENDIF
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' " 
		
		cQuery += " UNION ALL "
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " //15/04/19 | Everson - Chamado 044314.
		cQuery += " '' AS DESC_NSEG " 
		cQuery += " FROM ZC7100 ZC7 "
		cQuery += " INNER JOIN SA1100 A1 ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO FROM ZCF100 ZCF WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		If nAprAus == 0 .and. !Empty(sNivApr)
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' "
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " 
		ENDIF
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "

		IF lAprProj  
			cQuery += " UNION ALL "
			cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " '' AS DESC_NSEG " 
			cQuery += " FROM ZC7100 ZC7 (NOLOCK) "
			cQuery += " INNER JOIN AF8100 AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
		ENDIF
		//FIM Ticket 44493   - Abel Babini       - 28/09/2021 - Adicionado empresa Simplify

		//*************************************************************************************************
		/* INICIO - @history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML - EMPRESA 03 (CLML)*/
		cQuery += " UNION ALL "
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A2.A2_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_PAGAR' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, " 
		cQuery += " CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),1,1) = 'S' THEN '1 - Bloqueio por estar fora da Média de Valor | ' ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),2,1) = 'S' THEN '2 - Bloqueio por Lançamento de Nf-e sem XML | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),3,1) = 'S' THEN '3 - Bloqueio por Entrada de Nf-e sem Pedido de Compras | '  ELSE '' END  +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),4,1) = 'S' THEN '4 - Bloqueio por Não receber Vistoria Fisica no Recebimento | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),5,1) = 'S' THEN '5 - Bloqueio Aprovação Tecnica do Serviço | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),6,1) = 'S' THEN '6 - Bloqueio Integração por Modulo ou subsistema | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),7,1) = 'S' THEN '7 - Bloqueio Validação de Chave Primaria | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),8,1) = 'S' THEN '8 - Bloqueio por Duplicidade(Fornecedor+Valor+Emissão) | '  ELSE '' END +CASE WHEN SUBSTRING(ISNULL(E2_XPTCRTA,''),9,1) = 'S' THEN '9 - Bloqueio Pagamento Posterior a Entrega | '  ELSE '' END AS DESC_NSEG "
		cQuery += " FROM ZC7030 ZC7 (NOLOCK) "
		cQuery += " INNER JOIN SA2030 A2 (NOLOCK) ON A2_COD=ZC7_CLIFOR AND A2_LOJA=ZC7_LOJA AND A2.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN SE2030 E2 (NOLOCK) ON E2_FILIAL = ZC7_FILIAL AND E2_PREFIXO = ZC7_PREFIX AND E2_NUM = ZC7_NUM AND E2_PARCELA = ZC7_PARCEL AND E2_FORNECE = ZC7_CLIFOR AND E2_LOJA = ZC7_LOJA AND E2_TIPO = ZC7_TIPO "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO "
		cQuery += " FROM ZCF030 ZCF (NOLOCK) WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'P' "
		If nAprAus == 0 .and. !Empty(sNivApr) 
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' " 
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " 
		ENDIF
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND E2.D_E_L_E_T_ = ' ' " 
		
		cQuery += " UNION ALL "
		cQuery += " SELECT '' AS ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, A1.A1_NOME AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'CONTAS_RECEBER' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
		cQuery += " '' AS DESC_NSEG " 
		cQuery += " FROM ZC7030 ZC7 (NOLOCK) "
		cQuery += " INNER JOIN SA1030 A1 (NOLOCK) ON A1_COD=ZC7_CLIFOR AND A1_LOJA=ZC7_LOJA AND A1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ IN ( "
		cQuery += " SELECT ZCF_CODIGO "
		cQuery += " FROM ZCF030 ZCF (NOLOCK) WHERE ZCF_APROVA = '"+__cUserID+"' AND ZCF.D_E_L_E_T_ = ' ') "
		cQuery += " AND ZC7_RECPAG = 'R' "
		If nAprAus == 0 .and. !Empty(sNivApr)
			cQuery += " AND ZC7_NIVEL >= '"+cNivMen2+"' AND ZC7_NIVEL <= '"+sNivApr+"' "
		ELSE
			cQuery += " AND ZC7_NIVEL = '"+sNivApr+"' " 
		ENDIF
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "

		IF lAprProj  
			cQuery += " UNION ALL "
			cQuery += " SELECT ZC7_ORIGEM, ZC7_DATA, ZC7_TPBLQ,'10' ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, AF8_DESCRI AS NOME, ZC7_DSCBLQ, ZC7_VLRBLQ, ZC7_VLRJUR, ZC7_ACRESC, ZC7_DECRES, ZC7_CNABDE, ZC7_NDTVEN, ZC7_NDTVCR, ZC7_ODTVEN, ZC7_ODTVCR, 'PROJETO' AS TIPO, ZC7_CUSFIN, ZC7_PERCUS, ZC7_NUMCAL, ZC7_OBS, ZC7_NIVEL, ZC7_PROJET, ZC7_REVPRJ, ZC7_TIPO, ZC7.R_E_C_N_O_ RECNO, "
			cQuery += " '' AS DESC_NSEG " 
			cQuery += " FROM ZC7030 ZC7 (NOLOCK) "
			cQuery += " INNER JOIN AF8030 AF8 ON AF8_PROJET=ZC7_PROJET AND AF8_REVISA=ZC7_REVPRJ AND AF8.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE ZC7_TPBLQ = '000003' AND ZC7_DTAPR = ' ' AND ZC7_REPROV = ' ' AND ZC7_USRAPR = '"+ __cUserID +"' AND ZC7.D_E_L_E_T_ = ' ' "
		ENDIF
		/* FIM - @history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML - EMPRESA 03 (CLML) */
		//***********************************************************************************************

		cQuery += " ORDER BY ZC7EMP, ZC7_FILIAL "
		Conout("Query Central de Aprovação " + cValToChar(cQuery) )
		
		If Select("JSNZC7") > 0
			JSNZC7->(DbCloseArea())
		EndIf

		TcQuery cQuery New Alias "JSNZC7"

			cJsonRet := '{'
			cJsonRet += '	"Itens" : [ '
			
			lJson := .f.
			//conout("ljson = .f.")
			
			While JSNZC7->(!EOF())
			
				// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
				// Define Aprovador / Vistador
				If AllTrim(JSNZC7->ZC7_TPBLQ) == "000003"
				
					lVistador := .t.
					ZCX->( dbSetOrder(1) ) // ZCX_FILIAL + ZCX_USER + ZCX_CODIGO
					If ZCX->( dbSeek( FWxFilial("ZCX")+__cUserID ) )
						lVistador := .f.
					EndIf

					Conout( DToC(Date()) + " " + Time() + " ADFIN064P - lVistador - " + cValToChar(lVistador) )
	
					If !lVistador
						lOk := .f.
					
						If Select("Work") > 0
							Work->( dbCloseArea() )
						EndIf
						
						cQuery := " SELECT ZC7_REPROV, ZC7_DTAPR, ZC7_HRAPR "

						// Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 09/12/2019
						cQuery += " FROM ZC7"+AllTrim(JSNZC7->ZC7EMP)+"0 ZC7 (NOLOCK) "
						//

						cQuery += " WHERE ZC7_FILIAL BETWEEN '' AND 'z' "
						cQuery += " AND ZC7_PROJET='"+JSNZC7->ZC7_PROJET+"' "
						cQuery += " AND ZC7_REVPRJ='"+JSNZC7->ZC7_REVPRJ+"' "
						cQuery += " AND ZC7_USRAPR<>'"+__cUserID+"' "
						cQuery += " AND D_E_L_E_T_='' "

						cQuery += " ORDER BY 1 DESC "

						Conout( DToC(Date()) + " " + Time() + " ADFIN064P - lVistador - cQuery - " + cQuery )
						
						tcQuery cQuery new alias "Work"
					
						Work->( dbGoTop() )
						Do While Work->( !EOF() )
							If !Empty(Work->ZC7_DTAPR) .and. !Empty(Work->ZC7_HRAPR)
								If Empty(Work->ZC7_REPROV)
									lOk := .t.
								Else
									lOk := .f.
									Exit
								EndIf
							EndIf
							
							Work->( dbSkip() )
						EndDo
						
						If !lOk
							JSNZC7->( dbSkip() )
							Loop
						EndIf
						
						If Select("Work") > 0
							Work->( dbCloseArea() )
						EndIf
		
					EndIf
				
				EndIf
				//
				
				Nome_Fil := Posicione("SM0",1,JSNZC7->ZC7EMP+JSNZC7->ZC7_FILIAL,"M0_FILIAL") 		
				Nome_Fil := STRTRAN(Nome_Fil,"ADORO/","")

				lJson := .t.
				//conout("ljson = .t.")

				cJsonRet += '{ '
				cJsonRet += '	"Empresa" : "'+JSNZC7->ZC7EMP+'", '
				cJsonRet += '	"Nome_Empresa" : "'+iif(JSNZC7->ZC7EMP='07','RNX2', iif(JSNZC7->ZC7EMP='02','Ceres',Iif(JSNZC7->ZC7EMP='09',"Safegg",Iif(JSNZC7->ZC7EMP='06',"GMSBS",'Adoro'))) ) +'", ' //Everson - 21/09/2020. Chamado 2014.
				cJsonRet += '	"Filial" : "'+JSNZC7->ZC7_FILIAL+'", '
				cJsonRet += '	"Nome_Filial" : "'+Alltrim(Nome_Fil)+'", '
				cJsonRet += '	"Prefixo": "'+JSNZC7->ZC7_PREFIX+'", '
				cJsonRet += '	"Titulo" : "'+JSNZC7->ZC7_NUM+'", '
				cJsonRet += '	"Parcela" : "'+JSNZC7->ZC7_PARCEL+'", '
				cJsonRet += '	"Codigo" : "'+JSNZC7->ZC7_CLIFOR+'", '
				cJsonRet += '	"Loja": "'+JSNZC7->ZC7_LOJA+'", '
					sNmcliZc7 := rmvAcento(JSNZC7->NOME)
				cJsonRet += '	"Nome" : "'+Alltrim(sNmcliZc7)+'", '
				cJsonRet += '	"Tipo_Bloq" : "'+Alltrim(JSNZC7->ZC7_DSCBLQ)+' | '+Alltrim(JSNZC7->DESC_NSEG)+'", '
				cJsonRet += '	"Valor" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_VLRBLQ , "@E 9,999,999,999.99" ))+'", '
				cJsonRet += '	"Tipo_Titulo" : "'+Alltrim(JSNZC7->TIPO)+'", '
				cJsonRet += '	"Juros" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_VLRJUR , "@E 9,999,999,999.99" ))+'", '
				cJsonRet += '	"Acrescimo" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_ACRESC , "@E 9,999,999,999.99" ))+'", '
				cJsonRet += '	"Decrescimo" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_DECRES , "@E 9,999,999,999.99" ))+'", '
				cJsonRet += '	"Desconto" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_CNABDE , "@E 9,999,999,999.99" ))+'", '
				
				//
				If Alltrim(cValToChar(JSNZC7->ZC7_TPBLQ)) $cTpBlFr //15/04/19 | Everson - Chamado 044314. //Everson - 12/12/2019 - Chamado 029058.
					cJsonRet += '	"Novo_Vencimento" : "'    + DToC(SToD(JSNZC7->ZC7_DATA)) + '", '
					cJsonRet += '	"Vencimento_Original" : "'+ DToC(SToD(JSNZC7->ZC7_DATA)) + '", '
				Else
					cJsonRet += '	"Novo_Vencimento" : "'+iif(Empty(JSNZC7->ZC7_ODTVCR),'', dtoc(stod(JSNZC7->ZC7_NDTVCR)) )+'", '
					cJsonRet += '	"Vencimento_Original" : "'+ iif(Empty(JSNZC7->ZC7_ODTVCR) , '' , dtoc(stod(JSNZC7->ZC7_ODTVCR)) )+'", '
				EndIf
				
				cJsonRet += '	"custo_financeiro" : "'+Alltrim(TRANSFORM(JSNZC7->ZC7_CUSFIN , "@E 999,999.99" ))+'", '
				cJsonRet += '	"percentual_calculo" : "'+Alltrim(JSNZC7->ZC7_PERCUS)+'", '
				cJsonRet += '	"dias_calculo" : "'+Alltrim(JSNZC7->ZC7_NUMCAL)+'", '

				cJsonRet += '	"Projeto" : "'+Alltrim(JSNZC7->ZC7_PROJET)+'", '

				cJsonRet += '	"nivel" : "'+Alltrim(JSNZC7->ZC7_NIVEL)+'", '
				
				cTpOp := "" //15/04/19 | Everson - Chamado 044314.
				If !EMPTY(JSNZC7->ZC7_NIVEL) .Or. ( Alltrim(cValToChar(JSNZC7->ZC7_TPBLQ)) $cTpBlFr ) //Everson - 12/12/2019 - Chamado 029058.
				
					sMsgObs := BuscaObs( JSNZC7->ZC7EMP, JSNZC7->ZC7_FILIAL, JSNZC7->ZC7_PREFIX, JSNZC7->ZC7_NUM, JSNZC7->ZC7_CLIFOR, JSNZC7->ZC7_LOJA, JSNZC7->ZC7_PARCEL, JSNZC7->ZC7_TIPO, JSNZC7->ZC7_ORIGEM, @cTpOp ) //15/04/19 | Everson - Chamado 044314.
					//Everson - 06/03/2019. Chamdo T.I. Comentado bloco que remove caracteres especiais, pois já estão sendo removidos na função BuscaObs.
					//Ricardo Lima-04/02/2019
	/*					sMsgObs := StrTran(sMsgObs,Chr(40),"")
					sMsgObs := StrTran(sMsgObs,Chr(41),"")
					sMsgObs := StrTran(sMsgObs,Chr(47),"")
					sMsgObs := StrTran(sMsgObs,Chr(91),"")
					sMsgObs := StrTran(sMsgObs,Chr(92),"")
					sMsgObs := StrTran(sMsgObs,Chr(93),"")
					sMsgObs := StrTran(sMsgObs,Chr(96),"")
					sMsgObs := StrTran(sMsgObs,Chr(125),"")
					sMsgObs := StrTran(sMsgObs,Chr(123),"")
					sMsgObs := StrTran(sMsgObs,Chr(145),"")
					sMsgObs := StrTran(sMsgObs,Chr(146),"")
					sMsgObs := StrTran(sMsgObs,Chr(147),"")
					sMsgObs := StrTran(sMsgObs,Chr(148),"")*/
				EndIf
				
				//
				cJsonRet += '	"Operacao" : "' + cValToChar(cTpOp) + '", ' //15/04/19 | Everson - Chamado 044314.
				cJsonRet += '	"Observacao" : '+iif(empty(sMsgObs),'""',Alltrim(sMsgObs))+', '
				
				cJsonRet += '	"RECNO" : "'+Alltrim(Str(JSNZC7->RECNO))+'" '
				cJsonRet += '},'
				
				JSNZC7->(DBSKIP())
			End 
			
			If lJson
				//conout("ljson = .t. = substring")
				cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
			EndIf

			cJsonRet += '	]'
			cJsonRet += '}'
			
		dbSelectArea("JSNZC7")
		//If Contar("JSNZC7","!Eof()") = 0
		If Contar("JSNZC7","!Eof()") = 0 .or. !lJson
			SetRestFault(400,EncodeUtf8( "Não Existe Itens para Aprovação!" ))
			ConOut("Não Existe Itens para Aprovação!")
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		
		Else
		
			//
			cJsonRet := StrTran(cJsonRet,Chr(129),"")
			cJsonRet := StrTran(cJsonRet,Chr(141),"")
			cJsonRet := StrTran(cJsonRet,Chr(143),"")
			cJsonRet := StrTran(cJsonRet,Chr(144),"")
			cJsonRet := StrTran(cJsonRet,Chr(157),"")
			cJsonRet := StrTran(cJsonRet,Chr(9),"")
			cJsonRet := StrTran(cJsonRet,Chr(10),"")
			cJsonRet := StrTran(cJsonRet,Chr(13),"")
			
			cJsonRet := FwCutOff(cJsonRet,.F.)
		
			//retorno dos itens a aprovar em Json
			Self:SetResponse( EncodeUtf8(cJsonRet) )
			ConOut("Solicitação de Itens para Aprovação do Aprovador: "+Alltrim(cValToChar(__cUserID)))
			Conout("Json " + EncodeUtf8(cJsonRet) )
		EndIf	
		
	Else
		SetRestFault(400,EncodeUtf8( "Usuario Não Cadastrado como Aprovador!" ))
		ConOut("Central de Aprovação - Usuario Não Cadastrado como Aprovador! "+Alltrim(cValToChar(__cUserID)) + " " + DToC(Date()) + " " + Time() )
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf
	
	RestArea(aArea)
	MSUnlockAll()                 
	
Return .T.

/*/{Protheus.doc} Put
	Método Put.
	WebService rest para central de aprovação mobile 
	Metodo para realizar a aprovação ou reprovação, conforme 
	Retorno do AppMobile . Chamado 043065.
	@type  Function
	@author Ricardo Lima
	@since 07/08/2018
	@version 01
/*/
WsMethod Put WsService CentralAprovacao

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local oParseJSON
	Local j

	Private lRetAcaoAR  := .F.
	Private cMsgWBs     := ""
	PRIVATE sTpApr   := ""
	PRIVATE cFilZC7  := ""
	PRIVATE cCodigo  := ""
	PRIVATE nNumTit	 := ""
	PRIVATE nParctit := ""
	PRIVATE nTipTit  := ""
	PRIVATE cCodCli	 := ""
	PRIVATE cLojCli  := ""
	PRIVATE cNomCli	 := ""
	PRIVATE cDscSet  := ""
	PRIVATE cDscObs	 := ""
	PRIVATE nPerCus  := ""
	PRIVATE nNumCal  := ""
	PRIVATE nCusEfet := ""
	PRIVATE cMesRef	 := ""
	PRIVATE dApuDe	 := ""
	PRIVATE dApuAte	 := ""
	Private TpRecPag := ""
	Private cTpAprPA
	Private cPAvcALTSAG 
	Private cTpAprCF
	Private MsgCrtPt  := ""
	Private cDscTpBlq := ""
	Private nLimMin := 0
	Private nLimMax := 0
	Private nDiasAnt := 0
	Private nDiasPos := 0
	Private nPercJur := 0
	Private nPercAcs := 0
	Private nPercDes := 0
	Private nPercDcs := 0
	private nNivelA  := ""
	Private cTpLimite := ""
	Private cTpLimal := ""
	PRIVATE aRotina
	Private nValApr  := 0
	Private nLimGer  := 0
	Private cAprVcPa := ""
	Private nValALApr := 0
	Private nLimAL := 0
	Private nValNSApr := 0
	Private nLimNS := 0
	Private cTpLimNS := "M"
	Private nLiMinNS := 0
	Private nLiMaxNS := 0
	Private nNVLimNS := "00"
	Private lEnvWFCA := .F.
	Private sObsApr  := ""
	Private cCodPrj  := ""
	Private cRevPrj  := ""
	Private cNomPrj  := Space( 90 )
	Private cRecnoZC := ''  // Ricardo Lima-22/01/2019

    If Empty(__cUserID)
		SetRestFault(400,EncodeUtf8("Obrigatório informar o Nome do Usuario."))
		ConOut("PUT Central Aprovação - Obrigatório informar o Nome do Usuario.")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf

	ConOut("ADFIN064P CBODY " + cBody)

	if !FWJsonDeserialize(cBody, @oParseJSON)
		SetRestFault(400,EncodeUtf8("Json invalido."))
		ConOut("PUT Central Aprovação - Json invalido")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf
	
	dbSelectArea("ZC7")
	dbGoto(val(oParseJSON:RECNO ))  

	//ConOut("ADFIN064P PROJETO " + ZC7->ZC7_PROJET)
	//ConOut("ADFIN064P oParseJSON:RECNO " + oParseJSON:RECNO)

	cFilAnt := ZC7->ZC7_FILIAL
	
	RpcSetType(3)
    RpcSetEnv( cEmpAnt , cFilAnt )

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CentralAprovacao')

	DbSelectArea("ZC3")
	DbSetorder(1)
	if DbSeek( FwxFilial("ZC3") + __cUserID )
		nLimMin := ZC3->ZC3_LIMMIN
		nLimMax := ZC3->ZC3_LIMMAX
		nLimGer := ZC3->ZC3_OPERLI
		nDiasAnt := ZC3->ZC3_NUMDTA
		nDiasPos := ZC3->ZC3_NUMDTP
		nPercJur := ZC3->ZC3_PERJUR
		nPercAcs := ZC3->ZC3_PERACR
		nPercDes := ZC3->ZC3_PERDES
		nPercDcs := ZC3->ZC3_PERDEC
		cAprVcPa := ZC3->ZC3_APALVC
		nLimAL := ZC3->ZC3_LIMALC
		IF !Empty(ZC3->ZC3_NIVSEG)
			dbSelectArea("ZCK")
			dbSetOrder(1)
			if dbSeek( FWxFilial("ZCK") + ZC3->ZC3_NIVSEG )
				nLimNS   := ZCK->ZCK_LIMAPR
				nLiMinNS := ZCK->ZCK_LIMMIN
				nLiMaxNS := ZCK->ZCK_LIMMAX
				nNVLimNS := ZCK->ZCK_NIVSEG
			endif
		endif
	endif
	
    if Empty(oParseJSON:RECNO)
		SetRestFault(400,EncodeUtf8("Obrigatório Enviar Dados da Operação, Aprovação ou Reprovação."))
		ConOut("Obrigatório Enviar Dados da Operação, Aprovação ou Reprovação.")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	
	Else
		ConOut('Numero do Recno da Tabela ZC7 recebido para ação: '+oParseJSON:RECNO) 
		ConOut('Ação recebida, '+ iif(oParseJSON:sAcaoPed,'Aprovação','Reprovação') )
		
		dbSelectArea("ZC7")
		dbGoto(val(oParseJSON:RECNO))  
		cRecnoZC := oParseJSON:RECNO // Ricardo Lima-22/01/2019

		// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 30/04/2019
		If Empty(ZC7->ZC7_PROJET)
		
			If !Empty(ZC7->ZC7_USRAPR)
				SetRestFault(400,EncodeUtf8("Titulo Já Aprovado!"))
				ConOut("Erro - Titulo Já Aprovado!")
				RestArea(aArea)
				MSUnlockAll()
				Return .F.
			EndIf
		
		Else
		
			If !Empty(ZC7->ZC7_DTAPR) .OR. !Empty(ZC7->ZC7_HRAPR)
				SetRestFault(400,EncodeUtf8("Projeto já aprovado!"))
				ConOut("Erro - Projeto já aprovado!")
				RestArea(aArea)
				MSUnlockAll()
				Return .F.
			EndIf
		
			If !Empty(ZC7->ZC7_REPROV)
				SetRestFault(400,EncodeUtf8("Projeto possui recusa!"))
				ConOut("Erro - Projeto possui recusa!")
				RestArea(aArea)
				MSUnlockAll()
				Return .F.
			EndIf

		EndIf
	    //
	    
		for j:=1 to len(oParseJSON:obs)
			sObsApr += oParseJSON:obs[j]:obs + ', '
		next
			sObsApr := StrTran( Alltrim(sObsApr) , '"' , '' )
			sObsApr := EncodeUTF8(sObsApr, "cp1252")

		sTpApr   := ZC7->ZC7_TPBLQ
		cFilZC7  := ZC7->ZC7_FILIAL
		cCodigo  := ZC7->ZC7_PREFIX
		nNumTit	 := ZC7->ZC7_NUM
		nParctit := ZC7->ZC7_PARCEL
		nTipTit  := ZC7->ZC7_TIPO
		cCodCli	 := ZC7->ZC7_CLIFOR
		cLojCli  := ZC7->ZC7_LOJA
		cNomCli	 := SPACE( 50 )
		cDscSet  := ZC7->ZC7_VLRBLQ
		cDscObs	 := sObsApr
		nPerCus  := ALLTRIM(ZC7->ZC7_PERCUS) + '%'
		nNumCal  := ZC7->ZC7_NUMCAL
		nCusEfet := ZC7->ZC7_CUSFIN
		cMesRef	 := SPACE( 30 )
		dApuDe	 := dDataBase
		dApuAte	 := dDataBase

		TpRecPag    := ZC7->ZC7_RECPAG
		cTpAprPA    := IIF('Integração SAG' $ Alltrim(ZC7->ZC7_DSCBLQ),.T.,.F.) 
		cPAvcALTSAG := IIF( EMPTY(ZC7->ZC7_ODTVEN) , .F. , .T. ) 
		cTpAprCF    := IIF('Vencimento' $ Alltrim(ZC7->ZC7_DSCBLQ),.T.,.F.) 
		MsgCrtPt    := ""
		cDscTpBlq   := ZC7->ZC7_DSCBLQ
		lEnvWFCA := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )
		cCodPrj  := ZC7->ZC7_PROJET
		cRevPrj  := ZC7->ZC7_REVPRJ

		ConOut("ADFIN064P APROVA/REPROVA " + ZC7->ZC7_PROJET)
			
		if oParseJSON:sAcaoPed
			U_ADFINL46( cDscObs , TpRecPag , '2' )  // Aprova
			ConOut("ADFIN064P APROVOU !!!" + ZC7->ZC7_PROJET)
			if lRetAcaoAR
				Self:SetResponse( EncodeUtf8('{"Mensagem": "'+cMsgWBs+'"}') )
				ConOut("Titulo Aprovado com Sucesso!")
				RestArea(aArea)
				MSUnlockAll()
				Return .T.
			Else
				Self:SetResponse( EncodeUtf8('{"Mensagem": "'+cMsgWBs+'"}') )
				ConOut("Alçada insuficiente para Aprovação do Titulo!")
				RestArea(aArea)
				MSUnlockAll()
				Return .T.
			EndIf
		Else
			U_ADFINR46( cDscObs , TpRecPag , '2' )  // Reprova			
			ConOut("ADFIN064P REPROVOU !!! " + ZC7->ZC7_PROJET)
			if lRetAcaoAR
				Self:SetResponse( EncodeUtf8('{"Mensagem": "Titulo Reprovado com Sucesso!"}') )
				ConOut("Titulo Reprovado com Sucesso!")
				RestArea(aArea)
				MSUnlockAll()
				Return .T.
			Else
				Self:SetResponse( EncodeUtf8('{"Mensagem": "Erro na Reprovação do Titulo!"}') )
				ConOut("Erro na Reprovação do Titulo!")
				RestArea(aArea)
				MSUnlockAll()
				Return .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	MSUnlockAll()
	RpcClearEnv()

Return .T.

/*/{Protheus.doc} BuscaObs
	Busca observações.
	@type  Static Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
	/*/
Static Function BuscaObs( ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_CLIFOR, ZC7_LOJA, ZC7_PARCEL, ZC7_TIPO, ZC7_ORIGEM, cTpOp)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local sMsgRet 	:= ""
	Local cQuery  	:= ""
	Local IsMsgRet 	:=' ['
	Local sObsAjst 	:= ""
	Local cObsZFA	:= "" //15/04/19 | Everson - Chamado 044314.
	Local sObsSol   := "" //Everson - 09/11/2020. Chamado 4734.
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN064P - BuscaObs " )
	
	//
	cQuery := " SELECT ZC7_NOMAPR, ZC7_NIVEL, ZC7_OBS, ZC7_TPBLQ, ZC7_MSGSOL " //Everson - 09/11/2020. Chamado 4734.
	cQuery += " FROM ZC7"+ZC7EMP+"0 ZC7 "
	cQuery += " WHERE ZC7_FILIAL = '"+ZC7_FILIAL+"' "
	cQuery += " AND ZC7_PREFIX = '"+ZC7_PREFIX+"' AND ZC7_NUM = '"+ZC7_NUM+"' AND ZC7_PARCEL = '"+ZC7_PARCEL+"' AND ZC7_CLIFOR = '"+ZC7_CLIFOR+"' AND ZC7_LOJA = '"+ZC7_LOJA+"' AND ZC7_TIPO = '"+ZC7_TIPO+"' "
	cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZC7_NIVEL "
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN064P - BuscaObs - cQuery " + cValToChar(cQuery) )

	If Select("OBSZC7") > 0
		OBSZC7->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "OBSZC7"

	While OBSZC7->(!Eof())
		IF !Empty(Alltrim(OBSZC7->ZC7_OBS)) .Or. Alltrim(cValToChar(OBSZC7->ZC7_TPBLQ)) = Alltrim(cTpOp) .Or. !Empty(Alltrim(OBSZC7->ZC7_MSGSOL)) //Everson - 12/12/2019 - Chamado 029058. //Everson - 09/11/2020. Chamado 4734.
			
			////15/04/19 | Everson - Chamado 044314.
			cObsZFA := ""
			If Alltrim(cValToChar(OBSZC7->ZC7_TPBLQ)) = Alltrim(cTpOp) //Everson - 12/12/2019 - Chamado 029058.
				
				cObsZFA := obsZFA(ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_CLIFOR, ZC7_LOJA, ZC7_ORIGEM,@cTpOp)
				
			EndIf
			
			sObsAjst := rmvAcento( Iif(! Empty(cObsZFA), cObsZFA + " ", "") +; //StrTran( Alltrim(OBSZC7->ZC7_OBS) , '"' , '' ) // 09/04/19 | Everson 048432.
						Alltrim(cValToChar(OBSZC7->ZC7_OBS)) )

			sObsSol  := rmvAcento(Alltrim(cValToChar(OBSZC7->ZC7_MSGSOL)))  //Everson - 09/11/2020. Chamado 4734.
			
			If ! Empty(sObsAjst)
				//Ricardo Lima-26/02/2019
				/*sObsAjst := StrTran(sObsAjst,Chr(40),"")
				sObsAjst := StrTran(sObsAjst,Chr(41),"")
				sObsAjst := StrTran(sObsAjst,Chr(47),"")
				sObsAjst := StrTran(sObsAjst,Chr(91),"")
				sObsAjst := StrTran(sObsAjst,Chr(92),"")
				sObsAjst := StrTran(sObsAjst,Chr(93),"")
				sObsAjst := StrTran(sObsAjst,Chr(96),"")
				sObsAjst := StrTran(sObsAjst,Chr(125),"")
				sObsAjst := StrTran(sObsAjst,Chr(123),"")
				sObsAjst := StrTran(sObsAjst,Chr(145),"")
				sObsAjst := StrTran(sObsAjst,Chr(146),"")
				sObsAjst := StrTran(sObsAjst,Chr(147),"")
				sObsAjst := StrTran(sObsAjst,Chr(148),"")*/
	
				sMsgRet += '{"obs": " '+Alltrim(sObsAjst)+'","aprovador": "'+Alltrim(OBSZC7->ZC7_NOMAPR)+'"},'
			
			EndIf

			//Everson - 09/11/2020. Chamado 4734.
			If !Empty(sObsSol)
				sMsgRet += '{"obs": " '+Alltrim(sObsSol)+'","aprovador": "'+Alltrim(OBSZC7->ZC7_NOMAPR)+'"},'

			EndIf
			//
			
		EndIf
		
		OBSZC7->(DBSKIP())

	End
	
	//
	If !Empty(sMsgRet)
		sMsgRet := IsMsgRet + substr( Alltrim(sMsgRet) , 1 , len(Alltrim(sMsgRet)) -1 )
		sMsgRet +=']'
		
	EndIf

Return(sMsgRet)

/*/{Protheus.doc} obsZFA
	Retorna observações do registro de frete. Chamado 044314.
	@type  Static Function
	@author Ricardo Lima 
	@since 15/04/2019
	@version 01
	/*/
Static Function obsZFA(ZC7EMP, ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_CLIFOR, ZC7_LOJA, ZC7_ORIGEM,cTpOp)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cObs		:= ""
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN064P - obsZFA " )
	
	//
	If Alltrim(cValToChar(ZC7_ORIGEM)) == "ADLOG040P"
		cQuery	:= " SELECT CASE WHEN ZFA_DC = 'C' THEN 'Credito' ELSE 'Debito' END AS OP, RTRIM(LTRIM(ZFA_OBSERV)) + ' ' + RTRIM(LTRIM(ZFA_OBS)) AS OBS, ZFA_DC " 
		cQuery	+= " FROM ZFA" + ZC7EMP + "0 AS ZFA "
		cQuery	+= " WHERE ZFA_FILIAL = '" + ZC7_FILIAL + "' AND ZFA_COD = '" + ZC7_NUM + "' AND "
		cQuery	+= " ZFA_TRANPA = '" + ZC7_CLIFOR + "' AND ZFA_LJPPAG = '" + ZC7_LOJA + "' AND ZFA.D_E_L_E_T_ = ''  "

		//
		Conout( DToC(Date()) + " " + Time() + " ADFIN064P - obsZFA - cQuery " + cValToChar(cQuery) )
		
		//
		TcQuery cQuery New Alias "D_ZFA"
		DbSelectArea("D_ZFA")
		
			cObs  := Alltrim(cValToChar(D_ZFA->OBS))
			cTpOp := Alltrim(cValToChar(D_ZFA->OP))
		
		D_ZFA->(DbCloseArea())
		
	Else
	
		//Everson - 27/05/2019- Chamado 044314. Incluída a observação do frete combinado.
		DbSelectArea("ZFF")
		ZFF->(DbSetOrder(3))
		If ZFF->( DbSeek( ZC7_FILIAL +  Alltrim(cValToChar(ZC7_NUM)) ) )
			cObs	:= " Frete combinado " + Alltrim(cValToChar(ZFF->ZFF_OBS))
			cTpOp	:= "Credito"
			
		EndIf

	EndIf
	
	//
	RestArea(aArea)

Return cObs

/*/{Protheus.doc} PedidoCompra
	Web Service de pedido de compra. Chamado 043065.
	Lista de Metodos Implementado
	@type  Function
	@author user
	@since 14/11/2019
	@version 01
/*/
WsRestFul PedidoCompra Description "Serviço REST para Aprovação de Pedido de Compras, Integrado com o Sistema Protheus"

	WsMethod Post Description "Metodo para listar Pedidos de Compras para Aprovação"  WsSyntax "/PedidoCompra"
	WsMethod Put  Description "Metodo para Aprovar ou Reprovar Pedidos de Compras"  WsSyntax "/PedidoCompra"

End WsRestFul

/*/{Protheus.doc} Post
	Web Service de pedido de compra. Chamado 043065.
	WebService rest para aprovação mobile dos pedidos de Compras
	Retorna itens em Json para aprovação com filtro no aprovador
	Logado no AppMobile 
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
WsMethod Post WsService PedidoCompra

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local cJsonRet      := ""
	Local cCodUser      := ""
	Local jDetPed       := ""
	Local Nome_Fil      := ""
	Local jObsApr       := ""
	
	Local jHistPed		:= ""
	
	Local cUsrTst := Alltrim(cValToChar(Self:GetHeader("ChkAdm"))) //Everson - 06/03/2019. Chamado T.I.

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PedidoCompra')

	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	
	EndIf

	If EMPTY(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("Obrigatório informar o Nome do Usuario!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf

	//
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("PAG")+" PAG "
	cQuery += " WHERE PAG_IDUSER = '"+__cUserID+"' "
	cQuery += " AND PAG.D_E_L_E_T_ = ' ' "
	If Select("PEDAP") > 0
		PEDAP->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "PEDAP"
	If Contar("PEDAP","!Eof()") = 0

		//
		PEDAP->(DbCloseArea())

		//Everson - 02/01/2020 - Chamado 054596.
		cQuery := " SELECT  " 
		cQuery += " TOP 1 PAH_NUMSEQ " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("PAH") + " (NOLOCK) AS PAH " 
		cQuery += " WHERE " 
		cQuery += " PAH_FILIAL = '" + FWxFilial("PAH") + "' " 
		cQuery += " AND PAH_APRSUB = '"+__cUserID+"' " 
		cQuery += " AND CAST(PAH_DATINI AS DATE) <= CAST(GETDATE() AS DATE) " 
		cQuery += " AND CAST(PAH_DATFIM AS DATE) >= CAST(GETDATE() AS DATE) " 
		cQuery += " AND PAH.D_E_L_E_T_ = '' " 
		If Select("PEDAPS") > 0
			PEDAPS->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "PEDAPS"

		If Contar("PEDAPS","!Eof()") = 0

			//
			PEDAPS->(DbCloseArea())

			//
			SetRestFault(400,EncodeUtf8( "Usuario não cadastrado como Aprovador!" ))
			ConOut("Pedidos de Compra - Usuario Não Cadastrado como Aprovador! "+Alltrim(cValToChar(__cUserID)) + " " + DToC(Date()) + " " + Time() )
			RestArea(aArea)
			MSUnlockAll()
			Return .F.

		EndIf

	EndIf
	
	// Ricardo Lima-13/12/2018
	// ADORO
	cQuery := " SELECT '01' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR010 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR010 SCR "
	cQuery += " INNER JOIN SC7010 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "  //Ricardo Lima-11/02/2019
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION ALL "
	
	// CERES
	cQuery += " SELECT '02' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR020 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR020 SCR "
	cQuery += " INNER JOIN SC7020 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' " //Ricardo Lima-11/02/2019
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION ALL "
	
	// RNX2
	cQuery += " SELECT '07' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR070 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR070 SCR "
	cQuery += " INNER JOIN SC7070 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' " //Ricardo Lima-11/02/2019
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "
	
	//Everson - 01/08/19. Chamado TI.
	cQuery += " UNION ALL "
	
	//Everson - 25/07/19. Chamado TI.
	cQuery += " SELECT '03' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR030 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR030 SCR "
	cQuery += " INNER JOIN SC7030 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

	//Everson - 06/09/19. Chamado 051599.
	// SAFEGG
	cQuery += " UNION ALL "
	cQuery += " SELECT '09' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR090 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR090 SCR "
	cQuery += " INNER JOIN SC7090 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

	//Everson - 19/02/2020. Chamado T.I.
	//GMSBS
	cQuery += " UNION ALL "
	cQuery += " SELECT '06' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR060 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR060 SCR "
	cQuery += " INNER JOIN SC7060 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

	//Everson - 08/05/2020. Chamado T.I.
	//Simplify.
	cQuery += " UNION ALL "
	cQuery += " SELECT '10' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR100 SCR "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR100 SCR "
	cQuery += " INNER JOIN SC7100 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "
	//

	//**********************************************************************************************
	// INICIO - @history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML - EMPRESA 03 (CLML)
	cQuery += " UNION ALL "
	cQuery += " SELECT '03' CREMP, CR_FILIAL, CR_NUM, CR_TOTAL, CR_MOEDA, CR_EMISSAO, R_E_C_N_O_ RECNO, CR_USER "
	cQuery += " FROM SCR030 SCR (NOLOCK) "
	cQuery += " WHERE CR_NUM IN (SELECT DISTINCT C7_NUM "
	cQuery += " FROM SCR030 SCR (NOLOCK) "
	cQuery += " INNER JOIN SC7030 C7 ON C7_FILIAL=CR_FILIAL AND C7_NUM=CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CR_USER = '"+__cUserID+"' "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND C7_RESIDUO <> 'S' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ') "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND SCR.D_E_L_E_T_ = ' ' "
	// FIM - @history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML - EMPRESA 03 (CLML)
	//**********************************************************************************************
		
	cQuery += " ORDER BY CREMP, CR_FILIAL, CR_NUM "

	Conout(cQuery)

	If Select("PEDCR") > 0
		PEDCR->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "PEDCR"

	if Contar("PEDCR","!Eof()") = 0
	
		SetRestFault(400,EncodeUtf8( "Não Existe Itens para Aprovação!" ))
		ConOut("Não Existe Itens para Aprovação!")
		RestArea(aArea)
		MSUnlockAll()
	
		Return .F.
	
	Else		
	
		dbSelectArea("PEDCR")
		dbGoTop()
	
		cJsonRet := '{'
		cJsonRet += '	"Itens" : [ '
	
		While PEDCR->(!Eof())  
	
			Nome_Fil := Posicione("SM0",1,PEDCR->CREMP+PEDCR->CR_FILIAL,"M0_FILIAL") 		
			Nome_Fil := STRTRAN(Nome_Fil,"ADORO/","")
	
			cJsonRet += '{"Empresa": "'+Alltrim(PEDCR->CREMP)+'",'
			cJsonRet += '"Nome_Empresa": "'+ Alltrim(iif(PEDCR->CREMP='07','RNX2',iif(PEDCR->CREMP='02','CERES',Iif(PEDCR->CREMP='03','CLML',Iif(PEDCR->CREMP='06','GMSBS',Iif(PEDCR->CREMP='09','SAFEEG',Iif(PEDCR->CREMP='10',"SIMPLIFY",'ADORO'))))) )) +'",' //Everson - 19/02/2020. Chamado T.I. //Everson - 08/05/2020. Chamado T.I.
			cJsonRet += '"Filial": "'+Alltrim(PEDCR->CR_FILIAL)+'",'
			cJsonRet += '"Nome_Filial": "'+Alltrim(Nome_Fil)+'",'
			cJsonRet += '"Pedido": "'+Alltrim(PEDCR->CR_NUM)+'",'
			cJsonRet += '"Moeda": "'+Alltrim( Str(PEDCR->CR_MOEDA) )+'",' // Ricardo Lima-13/12/2018
			cJsonRet += '"Total": "'+Alltrim(TRANSFORM(PEDCR->CR_TOTAL , "@E 999,999,999,999.99" ))+'",'
			cJsonRet += '"Emissao": "'+dtoc(stod(PEDCR->CR_EMISSAO))+'",'
			cJsonRet += '"RECNO": "'+Alltrim(Str(PEDCR->RECNO))+'",'

			// @history Ticket 10986   - Fernando Macieira - 15/03/2021 - App de aprovação - melhorias
			cJsonRet += '"Comprador": "'+Alltrim( UsrRetName(PEDCR->CR_USER) )+'",'
			cJsonRet += '"Gerente": "'+Alltrim( UsrRetName(UpVistador(PEDCR->CREMP, PEDCR->CR_FILIAL, PEDCR->CR_NUM)) )+'",'
			//
    
			jDetPed := DestPedC( Alltrim(PEDCR->CR_FILIAL) , Alltrim(PEDCR->CR_NUM) , Alltrim(PEDCR->CREMP) )
			cJsonRet += '"Detalhe_Pedido": '+iif(empty(jDetPed),'""',Alltrim(jDetPed))+','
		
			// 29/03/19 | Everson - Chamado TI.
			jHistPed := HistPedC( Alltrim(PEDCR->CR_FILIAL) , Alltrim(PEDCR->CR_NUM) , Alltrim(PEDCR->CREMP) )
			cJsonRet += '"historico_pedido": '+iif(empty(jDetPed),'""',Alltrim(jHistPed))+','			
			
			jObsApr := ObsAprPD( Alltrim(PEDCR->CR_FILIAL) , Alltrim(PEDCR->CR_NUM) , Alltrim(PEDCR->CREMP) )
			cJsonRet += '"Obs_Aprovacao": '+iif(empty(jObsApr),'""',Alltrim(jObsApr))+' },'
			dbSelectArea("PEDCR")
			PEDCR->(DBSKIP())
		
		End
		
		cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
		cJsonRet += '	]'
		cJsonRet += '}'
		
		//
		cJsonRet := StrTran(cJsonRet,Chr(129),"")
		cJsonRet := StrTran(cJsonRet,Chr(141),"")
		cJsonRet := StrTran(cJsonRet,Chr(143),"")
		cJsonRet := StrTran(cJsonRet,Chr(144),"")
		cJsonRet := StrTran(cJsonRet,Chr(157),"")
		cJsonRet := StrTran(cJsonRet,Chr(9),"")
		cJsonRet := StrTran(cJsonRet,Chr(10),"")
		cJsonRet := StrTran(cJsonRet,Chr(13),"")
		
		conout("ADFIN064P - " + cJsonRet)
		cJsonRet := FwCutOff(cJsonRet,.F.)

		Self:SetResponse( EncodeUtf8( cJsonRet ) )
	Endif
	ConOut("Post Pedido Compras - Seleção dos pedidos do usuario - "+__cUserID+"")

	RestArea(aArea)
	MSUnlockAll()

Return .T.	

/*/{Protheus.doc} Put
	Web Service de pedido de compra. Chamado 043065.
	WebService rest para aprovação mobile dos pedidos de Compras
	Retorna itens em Json para aprovação com filtro no aprovador
	Logado no AppMobile 
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
WsMethod Put WsService PedidoCompra

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local cJsonRet      := ""
	Local cCodUser      := ""
	Local lRetPed       := .T.
	Local nOpcPed       := 0
	Local oParseJSON, j
	Private cRecno      := 0
	Private sObsSCR     := ""

	If EMPTY(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("Obrigatório informar o Nome do Usuario!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	EndIf
		ConOut(cBody)
	If !FWJsonDeserialize(cBody, @oParseJSON)
		SetRestFault(400,EncodeUtf8( "Dados de Aprovação Incompleto!" ))
		ConOut("Dados de Aprovação Incompleto!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	Else	
		if oParseJSON:sAcaoPed
			nOpcPed := 6
			cRecno := oParseJSON:RECNO
			dbSelectArea("SCR")
			dbGoto(Val(cRecno))
		Else
			nOpcPed := 8
			cRecno := oParseJSON:RECNO
			dbSelectArea("SCR")
			dbGoto(Val(cRecno))
		EndIf
		cFilAnt := SCR->CR_FILIAL
		RpcSetEnv( cEmpAnt , cFilAnt )

		//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PedidoCompra')

		for j:=1 to len(oParseJSON:obs)
			sObsSCR += EncodeUtf8(oParseJSON:obs[j]:obs) + ', '
		next
			sObsSCR := StrTran( Alltrim(sObsSCR) , '"' , '' )
			sObsSCR := EncodeUTF8(sObsSCR, "cp1252")
		
		// Chama a rotina atual de aprovação de Pedido de Compras
		lRetPed := U_Ado04LIB( 'SCR' , cRecno , nOpcPed , 'M')
		IF lRetPed
			if oParseJSON:sAcaoPed
				Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido Aprovado com Sucesso!"}' ) )
				ConOut("Put Pedido Compras - Pedido do Recno: "+oParseJSON:RECNO+", Aprovador pelo usuario - "+__cUserID+"")
			Else
				Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido Reprovado com Sucesso!"}' ) )
				ConOut("Put Pedido Compras - Pedido do Recno: "+oParseJSON:RECNO+", Reprovador pelo usuario - "+__cUserID+"")
			endif
		Else
			Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido, Já Processado."}' ) )
			ConOut("Put Pedido Compras - Pedido do Recno: "+oParseJSON:RECNO+", Já Processado.")
		EndIf
	
	EndIf

	RestArea(aArea)
	MSUnlockAll()

Return .T.

/*/{Protheus.doc} HistPedC
	WebService rest para aprovação mobile dos pedidos de Compras. Chamado T.I.
	@type  Static Function
	@author Everson
	@since 29/03/2019
	@version 01
/*/
Static Function HistPedC (CRFILIAL , CRNUM , CREMP)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local sMsgRet 		:= ""
	Local cQuery  		:= ""
	Local sDescriPrd 	:= ""
	Local sObsPed 		:= ""
	Local cSituaca		:= ""
	Local cTipoDoc		:= ""
	Local nAux			:= 0
	
	//Tipo PC.
	cTipoDoc  := "PC"
	
	cQuery    := " SELECT ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), CR_OBS)),'') AS M_OBS, 
	cQuery    += " CR_NIVEL, CR_USER, CR_STATUS, CR_XTPLIB, CR_DATALIB, CR_DATREJ, CR_OBS "
	cQuery    += " FROM "
	cQuery    += " SCR"+CREMP+"0 AS SCR "
	cQuery    += " WHERE SCR.CR_FILIAL='"+ Alltrim(CRFILIAL) +"' AND "
	cQuery    += " SCR.CR_NUM = '"+Padr(CRNUM,Len(SCR->CR_NUM))+"' AND "
	cQuery    += " SCR.CR_TIPO = 'PC' AND "
	cQuery    += " ( SCR.CR_DATALIB<>' ' OR SCR.CR_DATREJ<>'') AND "
	cQuery    += " SCR.CR_USER='"+ Alltrim(__cUserID) +"' AND "
	cQuery    += " SCR.D_E_L_E_T_='*' "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN064P - HistPedC - 1 cQuery " + cQuery  )
		
	//
	If Select("D_HDADOS") > 0
		D_HDADOS->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_HDADOS"
	DbSelectArea("D_HDADOS")
	D_HDADOS->(DbGoTop())
	
	//Tipo AE			
	If D_HDADOS->(Eof())
		cTipoDoc := "AE"
		D_HDADOS->(DbCloseArea())
		
		cQuery    := " SELECT ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), CR_OBS)),'') AS M_OBS, 
		cQuery    += " CR_NIVEL, CR_USER, CR_STATUS, CR_XTPLIB, CR_DATALIB, CR_DATREJ, CR_OBS "
		cQuery    += " FROM "
		cQuery 	  += " SCR"+CREMP+"0 AS SCR "
		cQuery    += " WHERE SCR.CR_FILIAL='"+ Alltrim(CRFILIAL) + "' AND "
		cQuery    += " SCR.CR_NUM = '"+Padr(CRNUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += " SCR.CR_TIPO = 'AE' AND "
		cQuery    += " ( SCR.CR_DATALIB<>' ' OR SCR.CR_DATREJ<>'') AND "
		cQuery    += " SCR.CR_USER='"+ Alltrim(__cUserID) +"' AND "
		cQuery    += " SCR.D_E_L_E_T_='*' "

		//
		If Select("D_HDADOS") > 0
			D_HDADOS->(DbCloseArea())
			
		EndIf
		
		TcQuery cQuery New Alias "D_HDADOS"
		DbSelectArea("D_HDADOS")
		D_HDADOS->(DbGoTop())
		
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN064P - HistPedC - 2 cQuery " + cQuery  )

	//
	sMsgRet +=' ['
	While D_HDADOS->(!Eof())
		
		//
		Do Case
			
			Case D_HDADOS->CR_STATUS == "01"
				cSituaca := OemToAnsi("Aguardando")
			
			Case D_HDADOS->CR_STATUS == "02"
				cSituaca := OemToAnsi("Em Aprovacao")
			
			Case D_HDADOS->CR_STATUS == "03"
				cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Aprovado"),IIF(cTipoDoc == "CP",OemToAnsi("Aprovado"),OemToAnsi("Aprovado")))
			
			Case D_HDADOS->CR_STATUS == "04"
				cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Rejeitado"),IIF(cTipoDoc == "CP",OemToAnsi("Rejeitado"),OemToAnsi("Rejeitado")))
			
			Case D_HDADOS->CR_STATUS == "05"			
				cSituaca := OemToAnsi("Nivel Liberado ")
				
		EndCase
		
		//
		sMsgRet += '{' 
		sMsgRet += '"nivel": "'     + Alltrim(D_HDADOS->CR_NIVEL ) + '", '
		sMsgRet += '"aprovador": "' + Alltrim( UsrRetName(D_HDADOS->CR_USER)  ) + '", '
		sMsgRet += '"situacao": "'  + Alltrim(cSituaca) + '", '
		sMsgRet += '"tipo": "'      + Alltrim( If( D_HDADOS->CR_XTPLIB == "V", "Vistador", "Aprovador" ) ) + '", '
		sMsgRet += '"liberacao": "' + Iif( ! Empty(D_HDADOS->CR_DATALIB), DToC(stod(D_HDADOS->CR_DATALIB )) , "") + '", '
		sMsgRet += '"rejeicao": "'  + Iif( ! Empty(D_HDADOS->CR_DATREJ), DToC(stod(D_HDADOS->CR_DATREJ  )) , "")  + '" '
		sMsgRet += '},'
		nAux++
		
		D_HDADOS->(DBSKIP())
		
	End
	
	//
	If nAux > 0
		sMsgRet := substr( Alltrim(sMsgRet) , 1 , len(Alltrim(sMsgRet)) -1 )
	
	EndIf
	
	sMsgRet +=']'

Return(sMsgRet)

/*/{Protheus.doc} DestPedC
	WebService rest para central de aprovação mobile. Chamado 043065.
	@type  Static Function
	@author Everson
	@since 07/08/2018
	@version 01
/*/
Static Function DestPedC( CRFILIAL , CRNUM , CREMP )

	Local sMsgRet := ""
	Local cQuery  := ""
	Local sDescriPrd := ""
	Local sObsPed := ""
	Local cLegAPP := ""

	// RICARDO LIMA-26/02/2019
	cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NOME, C7_PRODUTO, C7_DESCRI, C7_QUANT, "
	cQuery += " C7_UM, C7_PRECO, C7_TOTAL, C7_NUMSC, C7_ITEMSC, C7_CC, CTT_DESC01, C7_CONTA, C7_ITEMCTA, ISNULL(E4_DESCRI,'') C7_COND, "
	cQuery += " C7_OBS, C7_PROJETO, C7_VLDESC, C7_XOBSINT, " //Everson - 17/01/2020. Chamado 055029.
	cQuery += " C7_XQTDAPR, C7_XPEDORI, C7_XLEGAPP, " // Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 22/04/2020
	cQuery += " substring(C7_USERLGI, 11, 1) + substring(C7_USERLGI, 15, 1) + substring(C7_USERLGI, 2, 1) + substring(C7_USERLGI, 6, 1) + substring(C7_USERLGI, 10, 1) + substring(C7_USERLGI, 14, 1) + substring(C7_USERLGI, 1, 1) + substring(C7_USERLGI, 5, 1) + substring(C7_USERLGI, 9, 1) + substring(C7_USERLGI, 13, 1) + substring(C7_USERLGI, 17, 1) + substring(C7_USERLGI, 4, 1) + substring(C7_USERLGI, 8, 1) Usuario, C7_DATPRF "
	cQuery += " FROM SC7"+CREMP+"0 C7 "
	IF CREMP = '07'
		cQuery += " INNER JOIN CTT"+CREMP+"0 CTT ON CTT_CUSTO=C7_CC AND CTT.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " INNER JOIN CTT010 CTT ON CTT_CUSTO=C7_CC AND CTT.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += " INNER JOIN SA2"+CREMP+"0 A2 ON A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_ = ' ' "
	//IF CREMP = '02' .Or. CREMP = '03' .Or. CREMP = '09' // @history ticket 67983   - Fernando Macieira - 10/02/2022 - PA CLML - EMPRESA 03 (CLML)
	IF CREMP = '02' .Or. CREMP = '03' .Or. CREMP = '09' .OR. CREMP = '03'
		cQuery += " LEFT OUTER JOIN SE4010 E4 ON E4_CODIGO=C7_COND AND E4.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " LEFT OUTER JOIN SE4"+CREMP+"0 E4 ON E4_CODIGO=C7_COND AND E4.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += " WHERE C7_FILIAL = '"+CRFILIAL+"' "
	cQuery += " AND C7_NUM = '"+CRNUM+"' "
	cQuery += " AND C7.D_E_L_E_T_ = ' ' "

	//
	If Select("DETC7") > 0
		DETC7->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "DETC7"

	sMsgRet +=' ['
	While DETC7->(!Eof())
		
		// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FNWM - 22/04/2020
		If AllTrim(DETC7->C7_XLEGAPP) == "1"
			cLegAPP := "1 - Primeira aprovação"
		
		ElseIf AllTrim(DETC7->C7_XLEGAPP) == "2"
			cLegAPP := "2 - Alteração sem mudanca de valor"

		ElseIf AllTrim(DETC7->C7_XLEGAPP) == "3"
			cLegAPP := "3 - Alteração com mudanca de valor"

		ElseIf AllTrim(DETC7->C7_XLEGAPP) == "4"
			cLegAPP := "4 - Substituição PC ( PC original n. " + AllTrim(DETC7->C7_XPEDORI) + " )"

		EndIf
		//
		
		sMsgRet += '{' 
		sMsgRet += '"Filial": "'+Alltrim(DETC7->C7_FILIAL )+'", '
		sMsgRet += '"Numero_Pedido": "'+Alltrim(DETC7->C7_NUM )+'", '
		sMsgRet += '"Item_Pedido": "'+Alltrim(DETC7->C7_ITEM )+'", '
		sMsgRet += '"Emissao": "'+dtoc(stod(DETC7->C7_EMISSAO) )+'", '
		sMsgRet += '"Dt_Entrega": "'+dtoc(stod(DETC7->C7_DATPRF) )+'", ' // @history Ticket 10986   - Fernando Macieira - 15/03/2021 - App de aprovação - melhorias
		sMsgRet += '"Cod_Fornec": "'+Alltrim(DETC7->C7_FORNECE )+'", '
		sMsgRet += '"Loja_Fornec": "'+Alltrim(DETC7->C7_LOJA )+'", '
		sMsgRet += '"Nome_Fornec": "'+Alltrim(DETC7->A2_NOME )+'", '
		sMsgRet += '"Produto": "'+Alltrim(DETC7->C7_PRODUTO )+'", '
		
		sDescriPrd := STRTRAN(DETC7->C7_DESCRI , '"', '' )
		sMsgRet += '"Descricao_Prod": "'+Alltrim( sDescriPrd )+'", '
		
		sMsgRet += '"Quantidade": "'+Alltrim(TRANSFORM(DETC7->C7_QUANT , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Unidade_Medida": "'+Alltrim(DETC7->C7_UM )+'", '
		sMsgRet += '"Preco_Unit": "'+Alltrim(TRANSFORM(DETC7->C7_PRECO , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Total_Pedido": "'+Alltrim(TRANSFORM(DETC7->C7_TOTAL , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Num_Solicitacao": "'+Alltrim(DETC7->C7_NUMSC )+'", '
		sMsgRet += '"Item_Solicitacao": "'+Alltrim(DETC7->C7_ITEMSC )+'", '
		sMsgRet += '"Centro_Custo": "'+Alltrim(DETC7->C7_CC )+'", '
		sMsgRet += '"Descr_Centro_Custo": "'+Alltrim(DETC7->CTT_DESC01 )+'", '
		sMsgRet += '"Conta_Contabil": "'+Alltrim(DETC7->C7_CONTA )+'", '
		sMsgRet += '"Item_Conta_Contabil": "'+Alltrim(DETC7->C7_ITEMCTA )+'", '
		sMsgRet += '"Cod_Condicao_Pag": "'+Alltrim(DETC7->C7_COND )+'", '
		sMsgRet += '"Cod_Projeto": "'+Alltrim(DETC7->C7_PROJETO )+'", '
		sMsgRet += '"Usuario_Inclusao": "'+Alltrim( UsrRetName(DETC7->Usuario) )+'",'
		sMsgRet += '"Desconto": "'+Alltrim(TRANSFORM(DETC7->C7_VLDESC, "@E 999,999,999.99" ) )+'", '
		
		sObsPed := rmvAcento(DETC7->C7_OBS) + " / " + Chr(13) + Chr(10) + rmvAcento(DETC7->C7_XOBSINT) //STRTRAN(DETC7->C7_OBS , '"', '' ) // 09/04/19 | Everson 048432. //Everson - 17/01/2020. Chamado 055029.
		sMsgRet += '"Obs_ped": "'+Alltrim(sObsPed)+'", '

		// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FNWM - 22/04/2020
		sMsgRet += '"Legenda": "'+Alltrim(cLegAPP)+'", '
		sMsgRet += '"Qtd_Aprovacoes": "'+Alltrim(Transform(DETC7->C7_XQTDAPR, "@E 99"))+'" '
		//

		sMsgRet += '},'

	 DETC7->(DBSKIP())

	End

	sMsgRet := substr( Alltrim(sMsgRet) , 1 , len(Alltrim(sMsgRet)) -1 )
	sMsgRet +=']'

Return(sMsgRet)

/*/{Protheus.doc} ObsAprPD
	Retorna observações da tabela SCR. Chamado 043065.
	@type  Static Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
Static Function ObsAprPD( CRFILIAL , CRNUM , CREMP )

	Local sObsAprPD := ""
	Local sObsAprCA := "["
	Local cQueryJ  := ""
	Local sScrObs  := ""

	cQueryJ := " SELECT R_E_C_N_O_ RECNO "
	cQueryJ += " FROM SCR"+CREMP+"0 CR "
	cQueryJ += " WHERE CR_FILIAL = '"+CRFILIAL+"' "
	cQueryJ += " AND CR_NUM = '"+CRNUM+"' "
	cQueryJ += " AND CR_STATUS = '03' "
	cQueryJ += " AND CR.D_E_L_E_T_ = ' ' "

	If Select("TOBSCR") > 0
		TOBSCR->(DbCloseArea())
	EndIf
	TcQuery cQueryJ New Alias "TOBSCR"

	While TOBSCR->(!eof())

		dbSelectArea("SCR")
		dbGoto(TOBSCR->RECNO)
		sScrObs := rmvAcento(SCR->CR_OBS)//STRTRAN(SCR->CR_OBS , '"', '' ) // 09/04/19 | Everson 048432.

		//Ricardo Lima-04/02/2019
	/*		sScrObs := StrTran(sScrObs,Chr(40),"")
		sScrObs := StrTran(sScrObs,Chr(41),"")
		sScrObs := StrTran(sScrObs,Chr(47),"")
		sScrObs := StrTran(sScrObs,Chr(91),"")
		sScrObs := StrTran(sScrObs,Chr(92),"")
		sScrObs := StrTran(sScrObs,Chr(93),"")
		sScrObs := StrTran(sScrObs,Chr(96),"")
		sScrObs := StrTran(sScrObs,Chr(125),"")
		sScrObs := StrTran(sScrObs,Chr(123),"")
		sScrObs := StrTran(sScrObs,Chr(145),"")
		sScrObs := StrTran(sScrObs,Chr(146),"")
		sScrObs := StrTran(sScrObs,Chr(147),"")
		sScrObs := StrTran(sScrObs,Chr(148),"")*/

		sObsAprPD += '{"aprovador": "'+ UsrRetName(SCR->CR_USER)+'","obs": "' + EncodeUTF8(sScrObs, "cp1252") +'"},'
	
		TOBSCR->(dbSkip())
	
	End
	
	IF !Empty(sObsAprPD)
		sObsAprPD := substr( Alltrim(sObsAprPD) , 1 , len(Alltrim(sObsAprPD)) -1 )
		sObsAprPD := sObsAprCA + sObsAprPD
		sObsAprPD += ']'
	EndIf

Return(sObsAprPD)	

/*/{Protheus.doc} DoacaoBonificacao
	Web Service DoacaoBonificacao. Chamado 043065.
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
WsRestFul DoacaoBonificacao Description "Serviço REST para Aprovação de Pedido de Doacao e Bonificacao, Integrado com o Sistema Protheus"

	WsMethod Post Description "Metodo para Listar Pedidos de Doacao e Bonificacao"  WsSyntax "/DoacaoBonificacao"
	WsMethod Put  Description "Metodo para Aprovar Pedidos de Doacao e Bonificacao"  WsSyntax "/DoacaoBonificacao"

End WsRestFul

/*/{Protheus.doc} Post
	WebService rest para aprovação mobile dos pedidos de Vendas
	para Doacão ou Bonificação, 
	Retorna itens para aprovação do Usuario Logado no AppMobile. Chamado 043065.
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
WsMethod Post WsService DoacaoBonificacao

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	
	Local cUsrTst := Self:GetHeader("ChkAdm") //Everson - 06/03/2019. Chamado T.I.

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'DoacaoBonificacao')
	
	Private nTotPed     := 0
	Private sNomeCli    := ""
	
	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	
	EndIf
	

		If EMPTY(__cUserID)
			SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
			ConOut("Obrigatório informar o Nome do Usuario!")
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		EndIf

		if !__cUserID $ Alltrim(GetMv("MV_#APRDOA")) .AND. !__cUserID $ Alltrim(GetMv("MV_#APRBON"))
			SetRestFault(400,EncodeUtf8( "Usuario não cadastrado como Aprovador!" ))
			ConOut("Doação e Bonificação - Usuario Não Cadastrado como Aprovador! "+Alltrim(cValToChar(__cUserID)) + " " + DToC(Date()) + " " + Time() )
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		EndIf

		cQuery := " SELECT '01' C5EMP, C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_EST, C5_PBRUTO, C5_EMISSAO, C5_DTENTR, C5_XTOTPED, C5_APRVDOA, C5_STATDOA, C5_DTAPDOA, C5_HRAPDOA, C5_OBS, R_E_C_N_O_ RECNO, substring(C5_USERLGI, 11, 1) + substring(C5_USERLGI, 15, 1) + substring(C5_USERLGI, 2, 1) + substring(C5_USERLGI, 6, 1) + substring(C5_USERLGI, 10, 1) + substring(C5_USERLGI, 14, 1) + substring(C5_USERLGI, 1, 1) + substring(C5_USERLGI, 5, 1) + substring(C5_USERLGI, 9, 1) + substring(C5_USERLGI, 13, 1) + substring(C5_USERLGI, 17, 1) + substring(C5_USERLGI, 4, 1) + substring(C5_USERLGI, 8, 1) Usuario "
		cQuery += " FROM SC5010 C5 "
		cQuery += " WHERE C5_STATDOA = 'B' "
		cQuery += " AND C5_APRVDOA = '"+__cUserID+"' "
		cQuery += " AND C5_NOTA = ' ' "
		cQuery += " AND C5.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY C5EMP, C5_FILIAL, C5_NUM "

		If Select("ITC5") > 0
			ITC5->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "ITC5"

		IF Contar("ITC5","!Eof()") = 0
			SetRestFault(400,EncodeUtf8( "Não Existe Itens para Aprovação!" ))
			ConOut("Não Existe Itens para Aprovação!")
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		Else
			dbSelectArea("ITC5")
			dbGoTop()
			cJsonRet := '{'
			cJsonRet += '	"Itens" : [ '
			While ITC5->(!Eof())  
				Nome_Fil := Posicione("SM0",1,ITC5->C5EMP+ITC5->C5_FILIAL,"M0_FILIAL") 		
				Nome_Fil := STRTRAN(Nome_Fil,"ADORO/","")
				cJsonRet += '{"Empresa": "'+Alltrim(ITC5->C5EMP)+'",'
				cJsonRet += '"Nome_Empresa": "'+Alltrim(iif(ITC5->C5EMP='07','RNX2',iif(ITC5->C5EMP='02','CERES','ADORO') ))+'",'
				cJsonRet += '"Filial": "'+Alltrim(ITC5->C5_FILIAL)+'",'
				cJsonRet += '"Nome_Filial": "'+Alltrim(Nome_Fil)+'",'
				cJsonRet += '"Pedido": "'+Alltrim(ITC5->C5_NUM)+'",'
				cJsonRet += '"Cliente": "'+Alltrim(ITC5->C5_CLIENTE)+'",'
				cJsonRet += '"Loja_Cliente": "'+Alltrim(ITC5->C5_LOJACLI)+'",'
				cJsonRet += '"Nome_Cliente": "'+Alltrim(ITC5->C5_NOMECLI)+'",'
				cJsonRet += '"Estado": "'+Alltrim(ITC5->C5_EST)+'",'
				cJsonRet += '"Peso": "'+Alltrim(TRANSFORM(ITC5->C5_PBRUTO, "@E 999,999,999.99" ))+'",'
				cJsonRet += '"Emissao": "'+Alltrim(dtoc(stod(ITC5->C5_EMISSAO)))+'",'
				cJsonRet += '"Data_Entrega": "'+Alltrim(dtoc(stod(ITC5->C5_DTENTR)))+'",'
				cJsonRet += '"Obs": "'+Alltrim(ITC5->C5_OBS)+'",'
				cJsonRet += '"Usuario_Inclusao": "'+Alltrim( UsrRetName(ITC5->Usuario) )+'",'
				cJsonRet += '"RECNO": "'+Alltrim(Str(ITC5->RECNO))+'",'
					sNomeCli := rmvAcento(ITC5->C5_NOMECLI) //Alltrim(ITC5->C5_NOMECLI) // 09/04/19 | Everson 048432.
					jDetPed := DetPedDB( Alltrim(ITC5->C5_FILIAL) , Alltrim(ITC5->C5_NUM) , Alltrim(ITC5->C5EMP) )
				cJsonRet += '"Total_Pedido": "'+Alltrim(TRANSFORM(nTotPed , "@E 999,999,999.99" ) )+'",'	
				cJsonRet += '"Detalhe_Pedido": '+iif(empty(jDetPed),'""',Alltrim(jDetPed))+'}, '
				dbSelectArea("ITC5")
				ITC5->(DBSKIP())
				nTotPed := 0
			End
			cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
			cJsonRet += '	]'
			cJsonRet += '}'
			
			cJsonRet := StrTran(cJsonRet,Chr(129),"")
			cJsonRet := StrTran(cJsonRet,Chr(141),"")
			cJsonRet := StrTran(cJsonRet,Chr(143),"")
			cJsonRet := StrTran(cJsonRet,Chr(144),"")
			cJsonRet := StrTran(cJsonRet,Chr(157),"")
			cJsonRet := StrTran(cJsonRet,Chr(9),"")
			cJsonRet := StrTran(cJsonRet,Chr(10),"")
			cJsonRet := StrTran(cJsonRet,Chr(13),"")
			
			cJsonRet := FwCutOff(cJsonRet,.F.)

			Self:SetResponse( EncodeUtf8( cJsonRet ) )
		EndIf
		ConOut("Post Pedido Venda - Seleção dos pedidos do usuario - "+__cUserID+"")

		RestArea(aArea)
		MSUnlockAll()

Return .T.

/*/{Protheus.doc} Put
	Método Put. WebService rest para aprovação mobile dos pedidos de Vendas
	para Doacão ou Bonificação, 
	Retorna itens para aprovação do Usuario Logado no AppMobile. Chamado 043065.
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
/*/
WsMethod Put WsService DoacaoBonificacao

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local oParseJSON
	Private cRecno

	ConOut(cBody)
	If !FWJsonDeserialize(cBody, @oParseJSON)
		SetRestFault(400,EncodeUtf8( "Dados de Aprovação Incompleto!" ))
		ConOut("Dados de Aprovação Incompleto!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	Else	
		If oParseJSON:sAcaoPed
			cRecno := oParseJSON:RECNO
			dbSelectArea("SC5")
			dbGoto(Val(cRecno))
			ConOut("Aprova")
					cFilAnt := SC5->C5_FILIAL
					RpcSetType(3)
    				RpcSetEnv( cEmpAnt , cFilAnt )
				U_AprvPed(SC5->C5_NUM)
			Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido Aprovado com Sucesso!"}' ) )
		Else
			cRecno := oParseJSON:RECNO
			dbSelectArea("SC5")
			dbGoto(Val(cRecno))
			ConOut("Reprova")
				cFilAnt := SC5->C5_FILIAL
				RpcSetType(3)
    			RpcSetEnv( cEmpAnt , cFilAnt )
				U_RejPed(SC5->C5_NUM)
			Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido Reprovado com Sucesso!"}' ) )	
		Endif	
	EndIf

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'DoacaoBonificacao')

	RestArea(aArea)
	MSUnlockAll()

Return .T.
/*/{Protheus.doc} DetPedDB
	Obtém itens do pedido de saída. Chamado 043065.
	@type  Static Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
	/*/
Static Function DetPedDB( C7FILIAL , C7NUM , C7EMP )

	Local sMsgRet := ""
	Local cQuery  := ""
	Local sDescriPrd := ""
	Local sObsPed := ""

	cQuery := " SELECT C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_SEGUM, C6_UNSVEN, C6_UM,C6_QTDVEN, C6_PRCVEN, C6_VALOR "
	cQuery += "FROM SC6"+C7EMP+"0 C6 "
	cQuery += "WHERE C6_FILIAL = '"+C7FILIAL+"' AND C6_NUM = '"+C7NUM+"' "
	cQuery += "AND C6.D_E_L_E_T_ = ' ' "
	
	If Select("DETC6") > 0
		DETC6->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "DETC6"

	sMsgRet +=' ['
	While DETC6->(!Eof())
		sMsgRet += '{' 
		sMsgRet += '"Item_Pedido": "'+Alltrim(DETC6->C6_ITEM)+'", '
		sMsgRet += '"Produto": "'+Alltrim(DETC6->C6_PRODUTO)+'", '
		sDescriPrd := rmvAcento(DETC6->C6_DESCRI)//STRTRAN(DETC6->C6_DESCRI , '"', '' ) // 09/04/19 | Everson 048432. 
		//Ricardo Lima-04/02/2019
	/*		sDescriPrd := StrTran(sDescriPrd,Chr(40),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(41),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(47),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(91),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(92),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(93),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(96),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(125),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(123),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(145),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(146),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(147),"")
		sDescriPrd := StrTran(sDescriPrd,Chr(148),"")*/

		sMsgRet += '"Descricao_Prod": "'+Alltrim( sDescriPrd )+'", '
		sMsgRet += '"Nome_Fornec": "'+Alltrim( sNomeCli )+'", '
		sMsgRet += '"Segunda_UM": "'+Alltrim(DETC6->C6_SEGUM)+'", '
		sMsgRet += '"Primeira_UM": "'+Alltrim(DETC6->C6_UM)+'", '
		sMsgRet += '"Valor_Unitario": "'+Alltrim(TRANSFORM(DETC6->C6_PRCVEN , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Quantidade_Seg_Um": "'+Alltrim(TRANSFORM(DETC6->C6_UNSVEN , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Quantidade_Pri_Um": "'+Alltrim(TRANSFORM(DETC6->C6_QTDVEN , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Total_Item": "'+Alltrim(TRANSFORM(DETC6->C6_VALOR, "@E 999,999,999.99" ) )+'" '
		sMsgRet += '},'
		nTotPed += DETC6->C6_VALOR
	 DETC6->(DBSKIP())
	End
	sMsgRet := substr( Alltrim(sMsgRet) , 1 , len(Alltrim(sMsgRet)) -1 )
	sMsgRet +=']'

Return(sMsgRet)

/*/{Protheus.doc} AprvPed
	Aprova pedido de saída. Chamado 043065.
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
	/*/
User Function AprvPed(_cPed1)

	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F.  
	Local _cDtEn
	Local _cVend
	Private _nQtdLiber

			
		dbSelectArea("SC5")
		dbSetOrder(1)
		If  dbSeek(xfilial("SC5")+_cPed1)
			_cDtEn := SC5->C5_DTENTR
			_cVend := SC5->C5_VEND1
			
			Reclock("SC5",.F.)
			SC5->C5_BLQ := " "
			SC5->C5_LIBEROK := "S"
			SC5->C5_STATDOA := "A"
			SC5->C5_DTAPDOA := Date()
			SC5->C5_HRAPDOA := Time()
			MSUNLOCK()
				
			dbSelectArea("SC6")
			dbSetOrder(1)
			If  dbSeek(xFilial("SC6")+_cPed1)
				While !Eof() .And. _cPed1 == SC6->C6_NUM
						_nQtdLiber := SC6->C6_QTDVEN
						RecLock("SC6")
						// Efetua a liberação item a item de cada pedido
						Begin transaction
							MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
						End transaction
						SC6->(MsUnLock())    
						Begin Transaction
							SC6->(MaLiberOk({_cPed1},.F.))
						End Transaction
						SC6->(dbSkip())
				EndDo
				DbSelectArea("SC9")
				dbSetOrder(1)
				if dbseek(xFilial("SC9")+_cPed1)
					While !Eof() .And. _cPed1 == SC9->C9_PEDIDO								
							RecLock("SC9",.F.)
							SC9->C9_DTENTR := _cDtEn
							SC9->C9_VEND1  := _cVend
							MsUnlock()   
							SC9->(dbSkip())
					EndDo
				Endif
			EndIf		
		Endif

Return()
/*/{Protheus.doc} AprvPed
	Rejeita pedido de saída. Chamado 043065.
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
	/*/
User Function RejPed(_cPed1)

	Local _cVend1 := ""
	Local _aASC6 := {}			

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xfilial("SC5")+_cPed1)
		RecLock("SC5",.F.)			     
			SC5->C5_DTAPDOA  := DATE()
			SC5->C5_HRAPDOA  := TIME()
			SC5->C5_STATDOA := "R"
			SC5->C5_BLQ     := " "
			SC5->C5_LIBEROK := 'E'
		MsUnLock()
	Endif
		
	RecLock("SC5",.F.)
		dbdelete()
	MsUnlock()
	
	dbSelectArea("SC6")
	dbSetOrder(1)		
	If dbSeek(xfilial("SC6")+_cPed1)
		While !Eof() .And. SC6->C6_NUM == _cPed1		     
			AADD(_aASC6,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_TES,SC6->C6_UM,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR})
			Reclock("SC6",.F.)
				dbdelete()
			Msunlock()
			SC6->(dbskip())
		Enddo
	Endif   		    
	dbSelectArea("SC9")
	dbSetOrder(1)		
	If dbSeek(xfilial("SC9")+_cPed1)
		While !Eof() .And. SC9->C9_PEDIDO == _cPed1
			Reclock("SC9",.F.)
				dbdelete()
			Msunlock()
			SC9->(dbskip())
		Enddo
	Endif
		
	_cVend1 := SC5->C5_VEND1		  
	U_EMAILPEDRJ(_cPed1,_cVend1,_aASC6,"3")		   	   
    
Return()

//************************** REFATURAMENTO **************************************//
/*/{Protheus.doc} AprvPed
	Lista de Metodos Implementado. Chamado 044082.
	@type  Function
	@author Ricardo Lima 
	@since 25/09/2018
	@version 01
	/*/
WsRestFul Refaturamento Description "Serviço REST para Aprovação de Pedido de Vendas para Refaturamento, Integrado com o Sistema Protheus"

	WsMethod Post Description "Metodo para Listar Pedidos de Refaturamento"  WsSyntax "/Refaturamento"
	WsMethod Put  Description "Metodo para Aprovar Pedidos de Refaturamento"  WsSyntax "/Refaturamento"

End WsRestFul

/*/{Protheus.doc} Post
	Método Post. Chamado 043065.
	WebService rest para aprovação mobile dos pedidos de Vendas
	para Doacão ou Bonificação,
	Retorna itens para aprovação do Usuario Logado no AppMobile
	@type  Function
	@author Ricardo Lima 
	@since 07/08/2018
	@version 01
	/*/
WsMethod Post WsService Refaturamento

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cUrlServ		:= Self:GetPath()
	Local jDetPed       := ""
	
	Local cObsRefat		:= ""
	Local cObsRefat1	:= ""
	
	Local cUsrTst := Self:GetHeader("ChkAdm") //Everson - 06/03/2019. Chamado T.I.
	
	Private nTotPed     := 0

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'REFATURAMENTO')
	
	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	
	EndIf
	

		If EMPTY(__cUserID)
			SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
			ConOut("Obrigatório informar o Nome do Usuario!")
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		EndIf

		if !__cUserID $ Alltrim(GetMv("MV_IDREFAT"))
			SetRestFault(400,EncodeUtf8( "Usuario não cadastrado como Aprovador!" ))
			ConOut("Refaturamento - Usuario Não Cadastrado como Aprovador! "+Alltrim(cValToChar(__cUserID)) + " " + DToC(Date()) + " " + Time() )
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
		Else
			cQuery := " SELECT '01' C5EMP, R_E_C_N_O_ RECNO, * "
			cQuery += " FROM SC5010 C5 "
			cQuery += " WHERE C5_XREFATD <> ' ' AND C5_REFATUR <> 'S' "
			cQuery += " AND C5_NOTA = ' ' AND C5.D_E_L_E_T_ = ' ' "
			cQuery += " UNION ALL "
			cQuery += " SELECT '01' C5EMP, R_E_C_N_O_ RECNO, * "
			cQuery += " FROM SC5010 C5 "
			cQuery += " WHERE C5_NOTA = ' ' AND C5_XAPREFA = 'S'"
			cQuery += " AND C5_FILIAL+C5_NUM NOT IN ( "
			cQuery += " SELECT C5_FILIAL+C5_NUM "
			cQuery += " FROM SC5010 C5 "
			cQuery += " WHERE C5_XREFATD <> ' ' AND C5_REFATUR <> 'S' "
			cQuery += " AND C5_NOTA = ' ' AND C5.D_E_L_E_T_ = ' ' ) "
			cQuery += " AND C5.D_E_L_E_T_ = ' ' "

			If Select("ITC5") > 0
				ITC5->(DbCloseArea())
			EndIf
			TcQuery cQuery New Alias "ITC5"

			IF Contar("ITC5","!Eof()") = 0
				SetRestFault(400,EncodeUtf8( "Não Existe Itens para Aprovação!" ))
				ConOut("Não Existe Itens para Aprovação!")
				RestArea(aArea)
				MSUnlockAll()
				Return .F.
			Else
				dbSelectArea("ITC5")
				dbGoTop()
				cJsonRet := '{'
				cJsonRet += '	"Itens" : [ '
				While ITC5->(!Eof())  
					Nome_Fil := Posicione("SM0",1,ITC5->C5EMP+ITC5->C5_FILIAL,"M0_FILIAL") 		
					Nome_Fil := STRTRAN(Nome_Fil,"ADORO/","")
					cJsonRet += '{"Empresa": "'+Alltrim(ITC5->C5EMP)+'",'
					cJsonRet += '"Nome_Empresa": "'+Alltrim(iif(ITC5->C5EMP='07','RNX2',iif(ITC5->C5EMP='02','CERES','ADORO') ))+'",'
					cJsonRet += '"Filial": "'+Alltrim(ITC5->C5_FILIAL)+'",'
					cJsonRet += '"Nome_Filial": "'+Alltrim(Nome_Fil)+'",'
					cJsonRet += '"Pedido": "'+Alltrim(ITC5->C5_NUM)+'",'
					cJsonRet += '"Cliente": "'+Alltrim(ITC5->C5_CLIENTE)+'",'
					cJsonRet += '"Loja_Cliente": "'+Alltrim(ITC5->C5_LOJACLI)+'",'
					cJsonRet += '"Nome_Cliente": "'+Alltrim(ITC5->C5_NOMECLI)+'",'
					cJsonRet += '"Estado": "'+Alltrim(ITC5->C5_EST)+'",'
					cJsonRet += '"Peso": "'+Alltrim(TRANSFORM(ITC5->C5_PBRUTO, "@E 999,999,999.99" ))+'",'
					cJsonRet += '"Emissao": "'+Alltrim(dtoc(stod(ITC5->C5_EMISSAO)))+'",'
					cJsonRet += '"Data_Entrega": "'+Alltrim(dtoc(stod(ITC5->C5_DTENTR)))+'",'
					
					// 29/03/19 | Everson - Chamado TI.
					cObsRefat1 := rmvAcento(ITC5->C5_OBS)//STRTRAN(Alltrim(ITC5->C5_OBS),chr(13)+chr(10),' ') // 09/04/19 | Everson 048432.
	/*					cObsRefat1 := StrTran(cObsRefat1,Chr(40),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(41),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(47),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(91),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(92),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(93),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(96),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(125),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(123),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(145),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(146),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(147),"")
					cObsRefat1 := StrTran(cObsRefat1,Chr(148),"")	
					cObsRefat1 := StrTran(cObsRefat1,'"',"")*/									
					cJsonRet += '"Obs": "'+ cObsRefat1 +'",'  // Ricardo Lima - 12/11/18|ajuste na quebra de pagina
					
					// 29/03/19 | Everson - Chamado TI.
					cObsRefat := rmvAcento(ITC5->C5_XOBSRFA)//STRTRAN(Alltrim(ITC5->C5_XOBSRFA),chr(13)+chr(10),' ') // 09/04/19 | Everson 048432. 
	/*					cObsRefat := StrTran(cObsRefat,Chr(40),"")
					cObsRefat := StrTran(cObsRefat,Chr(41),"")
					cObsRefat := StrTran(cObsRefat,Chr(47),"")
					cObsRefat := StrTran(cObsRefat,Chr(91),"")
					cObsRefat := StrTran(cObsRefat,Chr(92),"")
					cObsRefat := StrTran(cObsRefat,Chr(93),"")
					cObsRefat := StrTran(cObsRefat,Chr(96),"")
					cObsRefat := StrTran(cObsRefat,Chr(125),"")
					cObsRefat := StrTran(cObsRefat,Chr(123),"")
					cObsRefat := StrTran(cObsRefat,Chr(145),"")
					cObsRefat := StrTran(cObsRefat,Chr(146),"")
					cObsRefat := StrTran(cObsRefat,Chr(147),"")
					cObsRefat := StrTran(cObsRefat,Chr(148),"")	
					cObsRefat := StrTran(cObsRefat,'"',"")	*/			
					cJsonRet += '"Obs_Refaturamento": "'+ cObsRefat +'",'
					
					cJsonRet += '"Pedido_Original": "'+Alltrim(ITC5->C5_XREFATD)+'",'
					
					cJsonRet += '"RECNO": "'+Alltrim(Str(ITC5->RECNO))+'",'
					
					sNomeCli := Alltrim(ITC5->C5_NOMECLI)
					jDetPed := DetPedDB( Alltrim(ITC5->C5_FILIAL) , Alltrim(ITC5->C5_NUM) , Alltrim(ITC5->C5EMP) )
						
					cJsonRet += '"Total_Pedido": "'+Alltrim(TRANSFORM(nTotPed , "@E 999,999,999.99" ) )+'",'	
					cJsonRet += '"Detalhe_Pedido": '+iif(empty(jDetPed),'""',Alltrim(jDetPed))+'}, '
					dbSelectArea("ITC5")
					ITC5->(DBSKIP())
					nTotPed := 0
					
				End
				cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
				cJsonRet += '	]'
				cJsonRet += '}'

				cJsonRet := StrTran(cJsonRet,Chr(129),"")
				cJsonRet := StrTran(cJsonRet,Chr(141),"")
				cJsonRet := StrTran(cJsonRet,Chr(143),"")
				cJsonRet := StrTran(cJsonRet,Chr(144),"")
				cJsonRet := StrTran(cJsonRet,Chr(157),"")
				cJsonRet := StrTran(cJsonRet,Chr(9),"")
				cJsonRet := StrTran(cJsonRet,Chr(10),"")
				cJsonRet := StrTran(cJsonRet,Chr(13),"")
				
				cJsonRet := FwCutOff(cJsonRet,.F.)
		
				Self:SetResponse( EncodeUtf8( cJsonRet ) )
			EndIf
			ConOut("Post Pedido Venda - Seleção dos pedidos do usuario - "+__cUserID+"")

		EndIf

		RestArea(aArea)
	MSUnlockAll()

Return .T.

/*/{Protheus.doc} Post
	Método Post. Chamado 043065.
	WebService rest para aprovação mobile dos pedidos de Vendas
	para Doacão ou Bonificação,
	Retorna itens para aprovação do Usuario Logado no AppMobile
	@type  Function
	@author Ricardo Lima 
	@since 25/09/2018
	@version 01
	/*/
WsMethod Put WsService Refaturamento

    Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cCodUsuario	:= Self:GetHeader("UsrApr")
	Local cUrlServ		:= Self:GetPath()
	Local oParseJSON
	Private cRecno
	Private sMsgpRet 	:= ""
	Private nOpc 
	Private sObsJS  	:= ""
	Private lDecisao 	:= .F. //Everson. 28/11/2018. Chamado 044815.

	ConOut(cBody)
	If !FWJsonDeserialize(cBody, @oParseJSON)
		SetRestFault(400,EncodeUtf8( "Dados de Aprovação Incompleto!" ))
		ConOut("Dados de Aprovação Incompleto!")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
	Else
		Conout("ADFIN064P Refaturamento cBody " + cBody)
		If oParseJSON:sAcaoPed
			lDecisao := oParseJSON:DECISAO //Everson. 28/11/2018. Chamado 044815.
			cRecno := oParseJSON:RECNO
			nOpc   := oParseJSON:rOpcao
			for j:=1 to len(oParseJSON:obs)
				if !Empty(oParseJSON:obs[j]:obs)
					sObsJS += EncodeUTF8(oParseJSON:obs[j]:obs,"cp1252") + ', '
				Endif
			next
			dbSelectArea("SC5")
			dbGoto(Val(cRecno))
			ConOut("Aprova")
					cFilAnt := SC5->C5_FILIAL
					RpcSetType(3)
    				RpcSetEnv( cEmpAnt , cFilAnt )
				if U_ALTPEDREF('M',nOpc,sObsJS) 
					Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido Aprovado com Sucesso!"}' ) )
				Else
					Self:SetResponse( EncodeUtf8( '{"Mensagem": "'+sMsgpRet+'"}' ) )
				Endif
		Else
			cRecno := oParseJSON:RECNO
			dbSelectArea("SC5")
			dbGoto(Val(cRecno))
			ConOut("Reprova")
				cFilAnt := SC5->C5_FILIAL
				RpcSetType(3)
    			RpcSetEnv( cEmpAnt , cFilAnt )
				//U_RejPed(SC5->C5_NUM)
			Self:SetResponse( EncodeUtf8( '{"Mensagem": "Ação cancelada com Sucesso!"}' ) )	
		Endif	
	EndIf

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'REFATURAMENTO')
	RestArea(aArea)
	MSUnlockAll()

Return .T.

//************************** PEDIDOS SAG **************************************//
/*/{Protheus.doc} ³Get
	Web Service para aprovação de pedidos de compra - SAG . Chamado 045097.
	Implementação do método Get para o recurso pedidossag
	@type  Function
	@author Everson
	@since 22/11/2018
	@version 01
	/*/
WsRestFul pedidossag Description "Serviço REST para aprovação de pedidos de compra SAG"

	WsMethod Get  Description "Método get para retornar pedidos de compra SAG"  WsSyntax "/pedidossag"
	WsMethod Put  Description "Método put para realizar a aprovação ou reprovação de pedido de compra SAG" WsSyntax "/pedidossag"

End WsRestFul

/*/{Protheus.doc} ³Get
	Método Get para pedidos SAG. Chamado 045097.
	Implementação do método Get para o recurso pedidossag
	@type  Function
	@author Everson
	@since 22/11/2018
	@version 01
	/*/
WsMethod Get WsService pedidossag
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cUrlServ		:= Self:GetPath()
	Local cJsonRet      := ""
	Local cQuery		:= ""
	Local jDetPed		:= ""
	Local oParseJSON	:= Nil
	
	Local cUsrTst := Self:GetHeader("ChkAdm") //Everson - 06/03/2019. Chamado T.I.
	
	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pedido Sag')
	
	//Everson - 06/03/2019. Chamado T.I.
	If ! Empty(__cUserID) .And. __cUserID $(Alltrim(cValToChar(GetMv("MV_#ADMAPP",,"")))) .And. ! Empty(cUsrTst)
		__cUserID := cUsrTst
	
	EndIf

	//
	If Empty(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("ADFIN064P Pedidos SAG GET " + DToC(Date()) + " " + Time() + " - Obrigatório informar o nome do usuário.")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
		
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZCQ_CODEMP, ZCQ_NMEMPR, ZCQ_CODFIL, ZCQ_NMFILI, ZCQ_PEDIDO, ZCQ_EMISSA, SUM(ZCQ_VLTOT) AS ZCQ_VLTOT " 
	cQuery += " FROM  " 
	cQuery += " ZCQ010 (NOLOCK) AS ZCQ " //Não é possível usar RetSqlName, pois o cliente define a empresa e usuário.
	cQuery += " WHERE " 
	cQuery += " ZCQ_FILIAL = '02' " 
	cQuery += " AND ZCQ_USUARI = '" + Alltrim(cValToChar(__cUserID)) + "' " 
	cQuery += " AND ZCQ_DTAPRO = '' " 
	cQuery += " AND ZCQ.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY "
	cQuery += " ZCQ_CODEMP, ZCQ_NMEMPR, ZCQ_CODFIL, ZCQ_NMFILI, ZCQ_PEDIDO, ZCQ_EMISSA "
	
	//
	If Select("PEDCR") > 0
		PEDCR->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "PEDCR"

	If Contar("PEDCR","!Eof()") = 0
		SetRestFault(400,EncodeUtf8( "Não Existe Itens para Aprovação!" ))
		ConOut("ADFIN064P Pedidos SAG GET " + DToC(Date()) + " " + Time() + " - Não Existe Itens para Aprovação usuário: " + Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID)))  )
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
		
	Else		
		DbSelectArea("PEDCR")
		PEDCR->(DbGoTop())
		cJsonRet := '{'
		cJsonRet += '	"Itens" : [ '
		While ! PEDCR->(Eof()) 
		 
			cJsonRet += '{"Empresa": "'+StrTran(StrTran(StrTran(Alltrim(PEDCR->ZCQ_CODEMP),'"',""),"/"," "),"\"," ")+'",'
			cJsonRet += '"Nome_Empresa": "'+StrTran(StrTran(StrTran(Alltrim(PEDCR->ZCQ_NMEMPR),'"',""),"/"," "),"\"," ")+'",'
			cJsonRet += '"Filial": "'+StrTran(StrTran(StrTran(Alltrim(PEDCR->ZCQ_CODFIL),'"',""),"/"," "),"\"," ")+'",'
			cJsonRet += '"Nome_Filial": "'+StrTran(StrTran(StrTran(Alltrim(PEDCR->ZCQ_NMFILI),'"',""),"/"," "),"\"," ")+'",'
			cJsonRet += '"Pedido": "'+Alltrim(PEDCR->ZCQ_PEDIDO)+'",'
			cJsonRet += '"Total": "'+Alltrim(TRANSFORM(Val(cValToChar(PEDCR->ZCQ_VLTOT)) , "@E 999,999,999,999.99" ))+'",'
			cJsonRet += '"Emissao": "'+dtoc(stod(PEDCR->ZCQ_EMISSA))+'",'			
			jDetPed := DetSAG(Alltrim(PEDCR->ZCQ_CODEMP),Alltrim(PEDCR->ZCQ_CODFIL),Alltrim(PEDCR->ZCQ_PEDIDO),Alltrim(cValToChar(__cUserID)))
			cJsonRet += '"Detalhe_Pedido": '+iif(empty(jDetPed),'""',Alltrim(jDetPed))+'},'
			DbSelectArea("PEDCR")
			
			PEDCR->(DBSKIP())
			
		End
		cJsonRet := substr( Alltrim(cJsonRet) , 1 , len(Alltrim(cJsonRet)) -1 )
		cJsonRet += '	]'
		cJsonRet += '}'
		
		//
		cJsonRet := StrTran(cJsonRet,Chr(129),"")
		cJsonRet := StrTran(cJsonRet,Chr(141),"")
		cJsonRet := StrTran(cJsonRet,Chr(143),"")
		cJsonRet := StrTran(cJsonRet,Chr(144),"")
		cJsonRet := StrTran(cJsonRet,Chr(157),"")
		cJsonRet := StrTran(cJsonRet,Chr(9),"")
		cJsonRet := StrTran(cJsonRet,Chr(10),"")
		cJsonRet := StrTran(cJsonRet,Chr(13),"")
		
		cJsonRet := FwCutOff(cJsonRet,.F.)
		cJsonRet := EncodeUtf8(cJsonRet)
		
		//Checa montagem do Json.
		If ! FWJsonDeserialize(cJsonRet, @oParseJSON)
			SetRestFault(500,EncodeUtf8("Ocorreu erro na serialização do Json."))
			ConOut("ADFIN064P Pedidos SAG GET " + DToC(Date()) + " " + Time() + " - Ocorreu erro na serialização do Json." + Chr(13) + Chr(10) + " cJsonRet: " + cJsonRet)
			RestArea(aArea)
			MSUnlockAll()
			Return .F.
	
		EndIf
		oParseJSON := Nil		
		
		Self:SetResponse(cJsonRet)
		cJsonRet := ""
		
	Endif
	
	//
	ConOut("ADFIN064P Pedidos SAG GET " + DToC(Date()) + " " + Time() + " - Seleção dos pedidos usuário: " + Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))) + " cJsonRet: " + cJsonRet )
	RestArea(aArea)
	MSUnlockAll()
	
Return .T.

/*/{Protheus.doc} Put
	Método Put para pedidos SAG. Chamado 045097.
	Implementação do método Put para o recurso pedidossag
	@type  Function
	@author Everson
	@since 22/11/2018
	@version 01
	/*/
WsMethod Put WsService pedidossag

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Alltrim(cValToChar(Self:GetContent()))
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
    Local aParametros	:= Self:aURLParms
	Local cUrlServ		:= Self:GetPath()
	Local oParseJSON	:= Nil
	Local cCodEmp		:= ""
	Local cCodFil		:= ""
	Local cPedido		:= ""
	Local cAprov		:= .F.
	Local cUpdate		:= ""
	Local cQuery		:= ""

	//U_ADINF009P('ADFIN064P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pedido Sag')
	
	//
	If Empty(__cUserID)
		SetRestFault(400,EncodeUtf8( "Obrigatório informar o Nome do Usuario!" ))
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Obrigatório informar o nome do usuário.")
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
		
	EndIf
	
	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)
		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Ocorreu erro na desserialização do Json." + Chr(13) + Chr(10) + " cBody: " + cBody)
		RestArea(aArea)
		MSUnlockAll()
		Return .F.

	EndIf
	
	//
	cCodEmp := Alltrim(cValToChar(oParseJSON:Empresa))
	cCodFil	:= Alltrim(cValToChar(oParseJSON:Filial))
	cPedido	:= Alltrim(cValToChar(oParseJSON:Pedido))
	cAprov	:= Iif(oParseJSON:sAcaoPed,'1','2')
	
	//
	cQuery := " SELECT ZCQ_APROVA FROM ZCQ010 WHERE ZCQ_FILIAL = '02' AND ZCQ_CODEMP = '" + cCodEmp + "' AND ZCQ_CODFIL = '" + cCodFil + "' AND ZCQ_PEDIDO = '" + cPedido + "' AND ZCQ_USUARI = '" + Alltrim(cValToChar(__cUserID)) + "' "
	If Select("CHK_PED") > 0
		CHK_PED0>(DbCloseArea())
		
	EndIf
	TcQuery cQuery New Alias "CHK_PED"
	DbSelectArea("CHK_PED")
	CHK_PED->(DbGoTop())
	If CHK_PED->(Eof())
		SetRestFault(404,EncodeUtf8("Pedido não encontrado " + cPedido + "."))
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Pedido não encontrado. Pedido: " + cPedido + ", usuário - " + Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))) )
		CHK_PED->(DbCloseArea())
		RestArea(aArea)
		MSUnlockAll()
		Return .F.	
		
	ElseIf Alltrim(cValToChar(CHK_PED->ZCQ_APROVA)) <> ""
		SetRestFault(400,EncodeUtf8("Pedido já sofreu interação " + cPedido + "."))
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Pedido já sofreu interação. Pedido: " + cPedido + ", usuário - " + Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))) )
		CHK_PED->(DbCloseArea())
		RestArea(aArea)
		MSUnlockAll()
		Return .F.			
	
	EndIf
	
	CHK_PED->(DbCloseArea())
	
	//Não é possível usar RetSqlName, pois o cliente define a empresa e usuário.
	cUpdate := " UPDATE ZCQ010 SET ZCQ_APROVA = '" + cAprov + "', ZCQ_DTAPRO='" + DToS(Date()) + "', ZCQ_HRAPRO='" + Time() + "' WHERE ZCQ_FILIAL = '02' AND ZCQ_CODEMP = '" + cCodEmp + "' AND ZCQ_CODFIL = '" + cCodFil + "' AND ZCQ_PEDIDO = '" + cPedido + "' AND ZCQ_USUARI = '" + Alltrim(cValToChar(__cUserID)) + "' "
	Conout("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - script sql " + cUpdate)
	
	//
	If (TCSqlExec(cUpdate)) < 0
		SetRestFault(400,EncodeUtf8("Ocorreu erro na atualização de status do pedido " + cPedido + "."))
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Ocorreu erro na atualização do status do pedido. Pedido: " + cPedido + ", usuário - " + Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))) + Chr(13) + Chr(10) + " script sql: " + cUpdate + Chr(13) + Chr(10) + "TCSQLError(): " + TCSQLError() )
		RestArea(aArea)
		MSUnlockAll()
		Return .F.
			
	EndIf
	
	//
	If cAprov == "1"
		Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido ' + cPedido + ' Aprovado com Sucesso!"}' ) )
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Pedido: "+cPedido+", Aprovado pelo usuario - "+Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))))
		
	Else
		Self:SetResponse( EncodeUtf8( '{"Mensagem": "Pedido ' + cPedido + ' Reprovado com Sucesso!"}' ) )
		ConOut("ADFIN064P Pedidos SAG PUT " + DToC(Date()) + " " + Time() + " - Pedido: "+cPedido+", Reprovado pelo usuario - "+Alltrim(cValToChar(__cUserID)) + "/" + UsrRetName(Alltrim(cValToChar(__cUserID))))
		
	EndIf
	
	//
	RestArea(aArea)
	
Return .T.

/*/{Protheus.doc} ³DetSAG
	Retorna detalhe dos pedidos de venda do SAG. Chamado 045097.
	@type  Static Function
	@author Everson
	@since 13/11/2018
	@version 01
	/*/
Static Function DetSAG(cCodEmp,cCodFilial,cNumPed,cUsuario)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	  := GetArea()
	Local sMsgRet := ""
	Local cQuery  := ""
	Local sDescriPrd := ""
	Local sObsPed := ""
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " * " 
	cQuery += " FROM  " 
	cQuery += " ZCQ010 (NOLOCK) AS ZCQ " //Não é possível usar RetSqlName, pois o cliente define a empresa e usuário.
	cQuery += " WHERE " 
	cQuery += " ZCQ_FILIAL = '02' " 
	cQuery += " AND ZCQ_CODEMP = '" + cCodEmp + "' " 
	cQuery += " AND ZCQ_CODFIL = '" + cCodFilial + "' " 
	cQuery += " AND ZCQ_USUARI = '" + cUsuario + "' " 
	cQuery += " AND ZCQ_PEDIDO = '" + cNumPed + "' " 
	cQuery += " AND ZCQ.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY " 
	cQuery += " ZCQ_ITEMPE " 

	//
	If Select("DETC7") > 0
		DETC7->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "DETC7"

	sMsgRet +=' ['
	While DETC7->(!Eof())
		
		sMsgRet += '{' 
		sMsgRet += '"Filial": "'+Alltrim(DETC7->ZCQ_CODFIL)+'", '
		sMsgRet += '"Numero_Pedido": "'+Alltrim(DETC7->ZCQ_PEDIDO )+'", '
		sMsgRet += '"Item_Pedido": "'+Alltrim(DETC7->ZCQ_ITEMPE )+'", '
		sMsgRet += '"Emissao": "'+dtoc(stod(DETC7->ZCQ_EMISSA) )+'", '
		sMsgRet += '"Cod_Fornec": "'+Alltrim(DETC7->ZCQ_CODFOR)+'", '
		sMsgRet += '"Loja_Fornec": "'+Alltrim(DETC7->ZCQ_LJFORN)+'", '
		sMsgRet += '"Nome_Fornec": "'+StrTran(StrTran(StrTran(Alltrim(cValtoChar(DETC7->ZCQ_NMFORN)),'"',""),"/"," "),"\"," ")+'", ' 
		sMsgRet += '"Produto": "'+Alltrim(DETC7->ZCQ_CODPRO )+'", ' 
		sMsgRet += '"Descricao_Prod": "'+StrTran(StrTran(StrTran(Alltrim(cValtoChar(DETC7->ZCQ_DESCPR)),'"',""),"/"," "),"\"," ")+'", ' 
		sMsgRet += '"Quantidade": "'+Alltrim(TRANSFORM(Val(cValToChar(DETC7->ZCQ_QUANTI)) , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Unidade_Medida": "'+Alltrim(DETC7->ZCQ_UM )+'", '
		sMsgRet += '"Preco_Unit": "'+Alltrim(TRANSFORM(Val(cValToChar(DETC7->ZCQ_UNIT)) , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Total_Pedido": "'+Alltrim(TRANSFORM(DETC7->ZCQ_VLTOT , "@E 999,999,999.99" ))+'", '
		sMsgRet += '"Centro_Custo": "'+Alltrim(DETC7->ZCQ_CODCC )+'", '
		sMsgRet += '"Descr_Centro_Custo": "'+StrTran(StrTran(StrTran(Alltrim(cValtoChar(DETC7->ZCQ_DESCCC)),'"',""),"/"," "),"\"," ")+'", ' 
		sMsgRet += '"Cod_Condicao_Pag": "'+StrTran(StrTran(StrTran(Alltrim(DETC7->ZCQ_DESC ),'"',""),"/"," "),"\"," ")+'", '
		sMsgRet += '"Usuario_Inclusao": "'+StrTran(StrTran(StrTran(Alltrim(cValtoChar(DETC7->ZCQ_DEMAND)),'"',""),"/"," "),"\"," ")+'",'
		sMsgRet += '"Desconto": "'+Alltrim(TRANSFORM(Val(cValToChar(DETC7->ZCQ_DESC)), "@E 999,999,999.99" ) )+'", '
		sObsPed := rmvAcento(DETC7->ZCQ_OBS) //STRTRAN(DETC7->ZCQ_OBS , '"', '' ) // 09/04/19 | Everson 048432.  
		sMsgRet += '"Obs_ped": "'+StrTran(StrTran(StrTran(Alltrim(cValtoChar(sObsPed)),'"',""),"/"," "),"\"," ")+'" '
		sMsgRet += '},'

	 DETC7->(DBSKIP())
	 
	End
	
	//
	sMsgRet := substr( Alltrim(sMsgRet) , 1 , len(Alltrim(sMsgRet)) -1 )
	sMsgRet +=']'
	
	//
	RestArea(aArea)

Return(sMsgRet)

/*/{Protheus.doc} rmvAcento
	Remove caracteres especiais da string. Chamado 048432.
	@type  Static Function
	@author Everson
	@since 09/04/2019
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

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 15/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@Ticket 10986   - Fernando Macieira - 15/03/2021 - App de aprovação - melhorias
/*/
Static Function UpVistador(cCREMP, cCR_FILIAL, cCR_NUM)

	Local cQuery := ""
	Local aArea  := GetArea()
	Local cAlias := GetNextAlias()
	Local cGerente := ""

	cQuery := " SELECT CR_USER
	cQuery += " FROM SCR" + AllTrim(cCREMP) + "0"
	cQuery += " WHERE CR_FILIAL='"+cCR_FILIAL+"' 
	cQuery += " AND CR_NUM='"+AllTrim(cCR_NUM)+"' 
	cQuery += " AND CR_NIVEL='01'
	cQuery += " AND CR_XTPLIB='V'
	cQuery += " AND D_E_L_E_T_=''

	//Conout("UpVistador " + cValToChar(cQuery) )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

	(cAlias)->( dbGoTop() )
	If (cAlias)->( !EOF() )
		cGerente := (cAlias)->CR_USER
	EndIf

	//Conout("UpVistador - cGerente " + cValToChar(cGerente) )

	(cAlias)->( dbCloseArea() )
	
	RestArea( aArea )

Return cGerente
