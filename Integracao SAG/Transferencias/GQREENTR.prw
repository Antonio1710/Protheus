#Include 'Protheus.ch'
#Include 'Topconn.ch' 

/*/{Protheus.doc} User Function GQREENTR
	Ponto de Entrada executado após a gravação de todos os registros de uma nota fiscal Projeto SAG II
	Regra de negócio criada para após a classificação da nota e no final do processo atualizar o valor do campo STATUS_INT como 'S' da tabela SGNFE010 intermediária entre Protheus X Edata utilizando como chave o campo F1_CODIGEN do SF1(Nota) com o CODIGENE(SGNFE010)
	@type  	Function
	@author Leonardo Rios
	@since 	13/04/16
	@version 1
	@history chamado 037341 - Everson			- 25/09/2017 - ?
	@history chamado 030282 - Everson			- 10/11/2017 - Grava código do projeto no ativo fixo
	@history chamado 036729 - FWNM       		- 21/05/2018 - Gerar baixa da ORIGEM do almoxarifado 95 (Estoque em Trânsito)
	@history chamado 042552 - Fernando Sigoli	- 25/07/2018 - ?
	@history chamado 048119 - Everson			- 26/03/2019 - Correção no lançamentos nos dados de projeto
	@history chamado TI 	- Everson			- 14/07/2020 - Ajustes na chamada da função para versão 12.1.27
	@history Ticket  34		- Glauco/ Adriana	- 02/10/2020 - Gera dados de importação para tabela CDA
/*/

User Function GQREENTR()

	Local aArea		:= GetArea() //Everson - 25/09/2017 - 037341.
	Local aRecnoNFE := {}
	Local cLocPad	:= ""
	Local cQuery 	:= ""
	Local nRecno 	:= 0
	Local aCampos	:={}
	Local cChave	:= SF1->(F1_FILIAL+F1_DOC+ALLTRIM(F1_SERIE)+F1_FORNECE+F1_LOJA)
	// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	// Local _nTcConn1 := advConnection()
	// Local _nTcConn2 := 0
	Local lRural	:= .F.
	Local cEMLMOV	:= ""
	Local cEMLFIN	:= ""
	Local cMensag	:= ""

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

		// Chamado: 036729 - Estoque em trânsito
		// - FWNM - 21/05/2018
		// - Gerar baixa da ORIGEM do almoxarifado 95 (Estoque em Trânsito)

        // Nota Entrada Normal
		cFilEntr  := GetMV("MV_#TRAFIE",,"03")                       
		If SF1->F1_FILIAL == cFilEntr .and. AllTrim(SF1->F1_TIPO) == "N"
		
			cTES      := GetMV("MV_#TRATES",,"02T")
			cForn     := GetMV("MV_#TRAFOR",,"022503")
			cLoja     := GetMV("MV_#TRALOJ",,"21")
			
			If AllTrim(SD1->D1_TES) == cTES .and. AllTrim(SD1->D1_FORNECE) == cForn .and. AllTrim(SD1->D1_LOJA) == cLoja
				msAguarde( { || GeraBxTran("N") }, "Baixando estoque em trânsito na origem (GQREENTR)" )
			EndIf
			
		EndIf
        
		// Gerar saída quando devolução - almoxarifado 95 (Estoque em Trânsito) 
		cFilOrig  := GetMV("MV_#TRAFIL",,"08")
		If SF1->F1_FILIAL == cFilOrig .and. AllTrim(SF1->F1_TIPO) == "D" .and. AllTrim(SF1->F1_FORMUL) == "S"

			cTESDev   := GetMV("MV_#TRADEV",,"02M")
			cCliTran  := GetMV("MV_#TRACLI",,"014999")        
			cLojTran  := GetMV("MV_#TRALO1",,"00")        
			cProdTra  := GetMV("MV_#TRAPRD",,"383369")        
			
			//If AllTrim(SF1->F1_FORNECE) == AllTrim(cCliTran) .and. AllTrim(SF1->F1_LOJA) == AllTrim(cLojTran) .and. AllTrim(SD1->D1_COD) == AllTrim(cProdTra) .and. AllTrim(SD1->D1_TES) == AllTrim(cTESDev) 
			If AllTrim(SF1->F1_FORNECE) == AllTrim(cCliTran) .and. AllTrim(SF1->F1_LOJA) == AllTrim(cLojTran) .and. AllTrim(SD1->D1_COD) == AllTrim(cProdTra) .and. AllTrim(SD1->D1_TES) $ AllTrim(cTESDev)	 //chamado: 042552 25/07/2018 - FERNANDO SIGOLI		
				msAguarde( { || GeraBxTran("D") }, "Gerando devolução do estoque em trânsito (GQREENTR)" )
			EndIf
					
		EndIf

		//
	
	
	If Alltrim(cEmpAnt) == "01"

		cEMLMOV	:= SuperGetMv("MV_XMOVWF",.F.,"")
		cEMLFIN	:= SuperGetMv("MV_XFINWF",.F.,"")

		If SF1->F1_CODIGEN > 0

			// TcConType("TCPIP")
			// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
			// 	_lRet     := .F.
			// 	cMsgError := "Não foi possível  conectar ao banco integração"
			// 	MsgInfo("Não foi possível  conectar ao banco integração para ajustar a tabela SGNFE010, verifique com administrador","ERROR")

			// EndIf

			cQuery := " SELECT * "
			cQuery += " FROM SGNFE010 "
			cQuery += " WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA = '" +cChave + "' "
			cQuery += " AND OPERACAO_INT<>'E' "

			If Select("NFE") <> 0
				NFE->(dbCloseArea())
			Endif

			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "NFE", .F., .T.)
			While !NFE->(Eof())
				AADD(aRecnoNFE, { NFE->R_E_C_N_O_, NFE->D1_MSEXP, NFE->STATUS_INT, NFE->TABEGENE, NFE->F1_FORMUL })
				NFE->(DbSkip())
			EndDo
			NFE->(dbCloseArea())


			// Analisa se existe uma movimentação referente ao nota fiscal para ser criado ³
			cMensag	:= ""
			For x:=1 To Len(aRecnoNFE)
				cQuery := " SELECT * "
				cQuery += " FROM SGMOV010 "
				cQuery += " WHERE RECORIGEM = '" + ALLTRIM(STR(aRecnoNFE[x, 1])) + "' "
				cQuery += 	" AND OPERACAO_INT <> 'E' AND D3_MSEXP='' "

				If Select("MOV") <> 0
					MOV->(dbCloseArea())
				Endif

				DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "MOV", .F., .T.)

				While !MOV->(Eof())
					aCampos	:={}

					nRecMOV := MOV->R_E_C_N_O_
					cRecMov := StrZero(MOV->R_E_C_N_O_,10) // foi setado como caracter pois indices numericos dao problema no protheus

					AADD(aCampos, {"D3_FILIAL"	,MOV->D3_FILIAL			, Nil})
					AADD(aCampos, {"D3_TM"		,MOV->D3_TM		 		, Nil})
					AADD(aCampos, {"D3_COD"		,MOV->D3_COD	 		, Nil})
					AADD(aCampos, {"D3_QUANT"	,MOV->D3_QUANT			, Nil})
					AADD(aCampos, {"D3_LOCAL"	,MOV->D3_LOCAL	   		, Nil})
					AADD(aCampos, {"D3_CC"		,'1201'					, Nil}) // ESTÁ FIXO MAIS PRECISARÁ SER REVISTO...VERIFICAR
					AADD(aCampos, {"D3_RECORI"  ,cRecMov				, Nil}) // setado como caracter pois indices numericos sao problematicos no banco

					cMOVCodAux := MOV->D3_COD
					nMOVQbrAux := MOV->D3_QUANT

					//TcSetConn(_nTcConn1)


					cMensag	+= "<ul>"
					cMensag	+= "<li>Cod. Produto: " + cMOVCodAux + "</li>"

					SB1->(DbSetOrder(1))
					If SB1->(DbSeek( xFilial("SB1") + cMOVCodAux ))
						cMensag	+= "<li>Desc. Produto: " + SB1->B1_DESC + "</li>"
					Else
						cMensag	+= "<li>Desc. Produto:</li>"
					EndIf

					cMensag += "<li>Quebra: " + ALLTRIM(STR(nMOVQbrAux)) + "</li>"
					cMensag += "<li>Nota - Série: " + SF1->F1_DOC + " - " + SF1->F1_SERIE + "</li>"
					cMensag += "<li>Fornecedor - Loja: " + SF1->F1_FORNECE + " - " + SF1->F1_LOJA + "</li>"

					cMensag += "</ul>"
					cMensag += "<hr>"

					lMsErroAuto:=.F.
					Begin Transaction

						MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 3)

						If lMsErroAuto
							DisarmTransaction()
							aErroLog:=GetAutoGrLog()
							cErro := Alltrim(aErrolog[1])
							For k := 1 to Len(aErroLog)
								If "INVALIDO" $ UPPER (aErroLog[k])
									cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
								EndIf
							Next

							cErro := Replace(cErro,Chr(13)+Chr(10)," ")

							U_ExTelaMen("Error!"														,;
							"Foi necessário criar uma movimentação devido a nota " + SF1->F1_DOC  +	;
							" possuir uma divergência no seu peso, mas ocorreu um erro ao efetuar"+ ;
							" o ExecAuto Mata240 aparecendo o seguinte erro : " + CRLF + cErro		,;
							"Arial"																	,;
							12																		,;
							,;
							.F.																		,;
							.T. )

						Else
							//TcSetConn(_nTcConn2)
							TcSqlExec("UPDATE SGMOV010 SET STATUS_INT = '', STATUS_PRC = 'P', D3_MSEXP='" +DTOS(DDATABASE) + "'  WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
						EndIf

					End Transaction

					MOV->(DbSkip())
				EndDo

				MOV->(dbCloseArea())

				If Len(aCampos) > 0
					cAvisoAux := "Quebra da Nota Fiscal SAG X Protheus" + Chr(13) + Chr(10)
					cAvisoAux += Replace(cMensag	,"<ul>"	,""										)
					cAvisoAux := Replace(cAvisoAux	,"</ul>",""										)
					cAvisoAux := Replace(cAvisoAux	,"<li>"	,""										)
					cAvisoAux := Replace(cAvisoAux	,"</li>",Chr(13) + Chr(10)						)
					cAvisoAux := Replace(cAvisoAux	,"<hr>" ,Chr(13) + Chr(10) + Chr(13) + Chr(10) 	)

					U_ExTelaMen("Aviso!"	,;
					cAvisoAux	,;
					"Arial"		,;
					12			,;
					,;
					.F.			,;
					.T. 		  )

					cAssunto	:= "Quebra da Nota Fiscal SAG X Protheus"

					//			  M001MAIL(cPara	, cCopia	, cCpOcul	, cAssunto, cDe						, cMensag, lHtml, cAnexo, _lJob	)
					U_M001MAIL(cEMLMOV	, ""		, ""		, cAssunto, "workflow@adoro.com.br"	, cMensag, .T.	, ""	, .F.	)

				EndIf

			Next x

			// Analisa se existe um título referente ao nota fiscal para ser criado ³

			nRecno := 0

			// Busca primeiro a informação do valor total do título somando(aglutinando) todos os itens do mesmo título ³
			//TcSetConn(_nTcConn2)
			cQuery := " SELECT SUM(E2_VALOR) AS E2_VALOR "
			cQuery += " FROM SGFIN010 "
			cQuery += " WHERE OPERACAO_INT <> 'E' AND E2_MSEXP='' "
			cQuery += " AND E2_FILIAL ='" +SF1->(F1_FILIAL) + "' "
			cQuery += " AND E2_NUM ='" +SF1->(F1_DOC) + "' "
			cQuery += " AND E2_PREFIXO ='MAN'
			cQuery += " AND E2_FORNECE ='" +SF1->(F1_FORNECE) + "' "
			cQuery += " AND E2_LOJA ='" +SF1->(F1_LOJA) + "' "
			cQuery := ChangeQuery(cQuery)

			If Select("FIN") <> 0
				FIN->(dbCloseArea())
			Endif

			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "FIN", .F., .T.)

			nValor := 0
			If !FIN->(Eof())
				nValor := FIN->E2_VALOR
			EndIf

			// Busca as informações padrão(iguais) do título para usar no array para o Execauto ³
			cQuery := " SELECT * "
			cQuery += " FROM SGFIN010 "
			cQuery += " WHERE OPERACAO_INT <> 'E' AND E2_MSEXP='' "
			cQuery += " AND E2_FILIAL ='" +SF1->(F1_FILIAL) + "' "
			cQuery += " AND E2_NUM ='" +SF1->(F1_DOC) + "' "
			cQuery += " AND E2_PREFIXO ='MAN'
			cQuery += " AND E2_FORNECE ='" +SF1->(F1_FORNECE) + "' "
			cQuery += " AND E2_LOJA ='" +SF1->(F1_LOJA) + "' "

			cQuery := ChangeQuery(cQuery)

			If Select("FIN") <> 0
				FIN->(dbCloseArea())
			Endif

			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "FIN", .F., .T.)
			TcSetField( "FIN", "E2_EMISSAO", "D", 8, 0 )
			TcSetField( "FIN", "E2_VENCTO", "D", 8, 0 )

			nRecFIN := FIN->R_E_C_N_O_
			cRecFIN := StrZero(FIN->R_E_C_N_O_,10) // foi setado como caracter pois indices numericos dao problema no protheus

			aCampos	:={}
			cMensag	:= ""
			If !FIN->(Eof())
				AADD(aCampos, {"E2_FILIAL"	,cFilAnt		, Nil})
				AADD(aCampos, {"E2_PREFIXO"	,"MAN"			, Nil})
				AADD(aCampos, {"E2_NUM"		,FIN->E2_NUM	, Nil})
				AADD(aCampos, {"E2_PARCELA"	,"1"			, Nil})
				AADD(aCampos, {"E2_TIPO"	,FIN->E2_TIPO	, Nil})
				AADD(aCampos, {"E2_NATUREZ"	,FIN->E2_NATUREZ, Nil})
				AADD(aCampos, {"E2_FORNECE"	,FIN->E2_FORNECE, Nil})
				AADD(aCampos, {"E2_LOJA"	,FIN->E2_LOJA	, Nil})
				AADD(aCampos, {"E2_EMISSAO"	,DDATABASE		, Nil})
				AADD(aCampos, {"E2_VENCTO"	,DDATABASE		, Nil})
				AADD(aCampos, {"E2_VALOR"	,nValor			, Nil})
				AADD(aCampos, {"E2_HIST"	,FIN->E2_HIST   , Nil})
				AADD(aCampos, {"E2_XRECORI" ,cRecFIN		, Nil}) // setado como caracter pois indices numericos sao problematicos no banco

				//TcSetConn(_nTcConn1)


				cMensag	+= "<ul>"
				cMensag += "<li>R$ " + ALLTRIM(TRANSFORM(nValor, "@E 999,999,999,999.999")) + "</li>"
				cMensag += "<li>Título - Prefixo: " + SE2->E2_NUM + " - MAN</li>"
				cMensag += "<li>Fornecedor - Loja: " + SE2->E2_FORNECE + " - " + SE2->E2_LOJA + "</li>"
				cMensag += "<li>Nota - Série: " + SF1->F1_DOC + " - " + SF1->F1_SERIE + "</li>"

				cMensag += "</ul>"
				cMensag += "<hr>"

				lMsErroAuto:=.F.
				Begin Transaction

					MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos, 3)

					If lMsErroAuto
						DisarmTransaction()
						aErroLog:=GetAutoGrLog()
						cErro := Alltrim(aErrolog[1])
						For k := 1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
							EndIf
						Next

						cErro := Replace(cErro,Chr(13)+Chr(10)," ")

						U_ExTelaMen("Error!"														,;
						"Foi necessário criar um título devido a nota " + SF1->F1_DOC +			;
						" possuir uma divergência no seu peso, mas ocorreu um erro ao efetuar"+ ;
						" o ExecAuto Fina340 aparecendo o seguinte erro : " + CRLF + cErro		,;
						"Arial"																	,;
						12																		,;
						,;
						.F.																		,;
						.T. )
					Else
						//TcSetConn(_nTcConn2)
						cUpd:="UPDATE SGFIN010 SET STATUS_INT = '', STATUS_PRC = 'P', E2_MSEXP='" +DTOS(DDATABASE) + "'"
						cUpd += " WHERE E2_FILIAL ='" +SF1->(F1_FILIAL) + "' "
						cUpd += " AND E2_NUM ='" +SF1->(F1_DOC) + "' "
						cUpd += " AND E2_PREFIXO ='MAN'
						cUpd += " AND E2_FORNECE ='" +SF1->(F1_FORNECE) + "' "
						cUpd += " AND E2_LOJA ='" +SF1->(F1_LOJA) + "' "
						TcSqlExec(cUpd)
					EndIf

				End Transaction
				FIN->(dbCloseArea())

				If Len(aCampos) > 0
					cAvisoAux := "Quebra Financeira da Nota Fiscal SAG X Protheus" + Chr(13) + Chr(10)
					cAvisoAux += Replace(cMensag	,"<ul>"	,""										)
					cAvisoAux := Replace(cAvisoAux	,"</ul>",""										)
					cAvisoAux := Replace(cAvisoAux	,"<li>"	,""										)
					cAvisoAux := Replace(cAvisoAux	,"</li>",Chr(13) + Chr(10)						)
					cAvisoAux := Replace(cAvisoAux	,"<hr>" ,Chr(13) + Chr(10) + Chr(13) + Chr(10) 	)

					U_ExTelaMen("Aviso!"	,;
					cAvisoAux	,;
					"Arial"		,;
					12			,;
					,;
					.F.			,;
					.T. 		  )

					cAssunto	:= "Quebra Financeira da Nota Fiscal SAG X Protheus"

					//			  M001MAIL(cPara	, cCopia	, cCpOcul	, cAssunto, cDe						, cMensag, lHtml, cAnexo, _lJob	)
					U_M001MAIL(cEMLFIN	, ""		, ""		, cAssunto, "workflow@adoro.com.br"	, cMensag, .T.	, ""	, .F.	)

				EndIf

			EndIf

			// Executa o update da tabela SGNFE010 devido a classificação da nota ter sido feita ³

			//TcSetConn(_nTcConn2)
			TcSqlExec("UPDATE SGNFE010 SET STATUS_INT = '' , STATUS_PRC = 'P', D1_MSEXP ='" +DTOS(DDATABASE)+ "' WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA = '" +cChave + "' " )

			//TcUnLink(_nTcConn2)
			//TcSetConn(_nTcConn1)
			DbSelectArea("ZBE")
			RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH Date()
			Replace ZBE_HORA 	   	WITH TIME()
			Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("Nota classificada " + cValToChar(SF1->(F1_DOC)) + " Fornecedor: " + cValToChar(SF1->(F1_FORNECE)) )  
			Replace ZBE_MODULO	    WITH "FISCAL"
			Replace ZBE_ROTINA	    WITH "GQREENTR" 
			MsUnLock()

		EndIf

		//Everson - 10/11/2017. Chamado 030282.
		grvCodPrj()

	Endif

	// Inicio: Glauco Oliveira - Eleva - 02/10/2020 - Ticket 34
	If SF1->F1_FORMUL == "S" .And. SF1->F1_EST == "EX"
		getInfImport()
	EndIf
	// Fim: Glauco Oliveira - Eleva - 02/10/2020 - Ticket 34 

	RestArea(aArea)

Return

/*/{Protheus.doc} CleanStr
Função para limpar a string retornada de um erro no ExecAuto 
@type		Static Function
@author  	Microsiga
@since		01/21/16
@version	01
@history 	Adoro 
/*/

Static Function CleanStr(cErro)

	Default cErro := ""

	cErro := StrTran(cErro, Chr(13)+Chr(10), "")
	For nCnt:=9 To 2 STEP -1
		cErro := StrTran(cErro, SPACE(nCnt), " ")
	Next nCnt

Return cErro


/*/{Protheus.doc} grvCodPrj()
Grava código do projeto no ativo fixo
@type  		Static Function
@author  	Everson
@since   	10/11/17
@version 	01
@history 	Adoro - chamado 030282
/*/
Static Function grvCodPrj()

	Local aArea		:= GetArea()
	Local cEspecie 	:= SF1->F1_ESPECIE
	Local cFilSD1  	:= SF1->F1_FILIAL
	Local cNf	    := SF1->F1_DOC
	Local cSerie   	:= SF1->F1_SERIE
	Local cForn    	:= SF1->F1_FORNECE
	Local cLoja    	:= SF1->F1_LOJA
	Local cTESAtlz 	:= ""

	//Everson-26/03/2019. Chamado 048119.
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbGoTop())
	If SD1->(DbSeek( FWxFilial("SD1") + cNf + cSerie + cForn +  cLoja ))
	
		While ! SD1->(Eof()) .And. cFilSD1 == SD1->D1_FILIAL .And. cNf == SD1->D1_DOC .And.;
		cSerie == SD1->D1_SERIE .And. cForn == SD1->D1_FORNECE .And.;
		cLoja == SD1->D1_LOJA
			
			cTESAtlz := Posicione("SF4",1, xFilial("SF4") + Alltrim(cValToChar(SD1->D1_TES)) ,"F4_ATUATF")
			
			If cTESAtlz == "S" .And. ! Empty( Alltrim(cValToChar(SD1->D1_TES))) .And. ! Empty( Alltrim(cValToChar(SD1->D1_PROJETO)))
				Conout( DToC(Date()) +" "+ Time() + " GQREENTR - grvCodPrj (ENTORU IF) " + cFilSD1 + " " + cNf + " " + cSerie + " " + cForn + " " + cLoja + " " + Alltrim(cValToChar(SD1->D1_COD)) )
				atlzSN1( cFilSD1,cForn,cLoja,cEspecie,cNf,cSerie,Alltrim(cValToChar(SD1->D1_COD)),Alltrim(cValToChar(SD1->D1_PROJETO)),Alltrim(cValToChar(SD1->D1_ITEM)) ) //Everson-26/03/2019. Chamado 048119.
	
			EndIf

			SD1->(DbSkip())
	
		EndDo
	
	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} atlzSN1()
Atualiza o código do projeto no cadastro de ativo fixo
@type  		Static Function
@author  	Everson
@since   	10/11/17
@version 	01
@history 	Adoro - chamado 030282
/*/

Static Function atlzSN1(cFilSD1,cForn,cLoja,cEspecie,cNf,cSerie,cProduto,cProjeto,cItemNf)

	Local aArea	 := GetArea()
	Local cQuery := ""

	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " SN1.R_E_C_N_O_ AS REC  " 
	cQuery += " FROM " + RetSqlName("SN1") + " AS SN1  " 
	cQuery += " WHERE " 
	cQuery += " SN1.D_E_L_E_T_ = '' " 
	cQuery += " AND N1_FILIAL = '"  + cFilSD1 + "'  " 
	cQuery += " AND N1_NFISCAL = '" + cNf + "'  " 
	cQuery += " AND N1_NSERIE = '"  + cSerie + "' " 
	cQuery += " AND N1_FORNEC = '"  + cForn + "' " 
	cQuery += " AND N1_LOJA = '"    + cLoja + "' " 
	cQuery += " AND N1_PRODUTO = '" + cProduto + "' " 
	cQuery += " AND N1_NFESPEC = '" + cEspecie + "' "
	cQuery += " AND N1_NFITEM  = '" + cItemNf + "' "

	//
	If Select("D_SN1") > 0
		D_SN1->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_SN1"
	DbSelectArea("D_SN1")
	D_SN1->(DbGoTop())

	//
	While ! D_SN1->(Eof())

		//
		If Val(cValToChar(D_SN1->REC)) <= 0
			D_SN1->(DbSkip())
			Loop
			
		EndIf
		
		//
		DbSelectArea("SN1")
		SN1->(DbGoTo(Val(cValToChar(D_SN1->REC))))
		
		//
		If ! SN1->(Eof()) //Everson-26/03/2019. Chamado 048119.
		
			RecLock("SN1",.F.)
				Replace SN1->N1_PROJETO With cProjeto
			MsUnlock()
	
			DbSelectArea("ZBE")
			RecLock("ZBE",.T.)
				Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
				Replace ZBE_DATA 	   	WITH Date()
				Replace ZBE_HORA 	   	WITH TIME()
				Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
				Replace ZBE_LOG	        WITH ("Número do projeto atualizado no ativo fixo " + cValToChar(cProjeto) + " Recno SN1 " + cValToChar(SN1->( Recno())) )  
				Replace ZBE_MODULO	    WITH "FISCAL"
				Replace ZBE_ROTINA	    WITH "GQREENTR-atlzSN1" 
			MsUnLock()
		
		EndIf

		D_SN1->(DbSkip())

	EndDo
	
	D_SN1->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GeraBxTran()
Baixa estoque em transito da filial de origem
@type  		Static Function
@author  	Fernando Macieira
@since   	05/21/18
@version 	01
@history 	Adoro  
/*/

Static Function GeraBxTran(cTipoNF)

Local aArea	    := GetArea() 
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local aItens    := {}

Local cTMPadrao := GetMV("MV_#TRATMS",,"701")
Local cLocTran  := GetMV("MV_LOCTRAN",,"95")
Local cFilOrig  := GetMV("MV_#TRAFIL",,"08")

Local cCliTran  := GetMV("MV_#TRACLI",,"014999")        
Local cLojTran  := GetMV("MV_#TRALO1",,"00")        
Local cProdTra  := GetMV("MV_#TRAPRD",,"383369")        

// Backup da filial corrente
cFilBkp := cFilAnt

// Seto filial origem
cFilAnt := cFilOrig


// Itens 
dbSelectArea("SD1")
dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

Do While SD1->( !EOF() ) .and. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If cTipoNF == "N"
		cDoc := SD1->D1_DOC
		cSer := SD1->D1_SERIE
		
	ElseIf cTipoNF == "D"
		cDoc := SD1->D1_NFORI
		cSer := SD1->D1_SERIORI
	
	EndIf
	
	nCustoNFS := Posicione("SD2",3,cFilOrig+cDoc+cSer+cCliTran+cLojTran+PadR(cProdTra,TamSX3("B1_COD")[1]),"D2_CUSTO1")
	
	AADD(aItens, {"D3_FILIAL"	,cFilAnt         , Nil})
	AADD(aItens, {"D3_DOC"		,SD1->D1_DOC     , Nil})
	AADD(aItens, {"D3_TM"		,cTMPadrao   	 , Nil})
	AADD(aItens, {"D3_COD"		,SD1->D1_COD     , Nil})
	AADD(aItens, {"D3_UM"       ,SD1->D1_UM      , Nil})
	AADD(aItens, {"D3_QUANT"	,SD1->D1_QUANT   , Nil}) 
	AADD(aItens, {"D3_CUSTO1"	,nCustoNFS       , Nil})
	AADD(aItens, {"D3_LOCAL"	,cLocTran        , Nil})
	AADD(aItens, {"D3_EMISSAO"	,dDatabase	     , Nil})
	AADD(aItens, {"D3_NUMSEQ"	,SD1->D1_NUMSEQ  , Nil})
	
	Begin Transaction                            
					
		lMsErroAuto := .F.
						
		msExecAuto({|x,y| MATA240(x,y)}, aItens, 3) 
				
		If lMsErroAuto

			DisarmTransaction()
	
			Aviso("GQREENTR-01", "Será necessário lançar manualmente a baixa do estoque em trânsito na filial ORIGEM..." + chr(10) + chr(13) +;
			"Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
			"Abaixo, dados da baixa que NÃO gerou no estoque em trânsito de ORIGEM: " + chr(10) + chr(13) +;
			"Filial: " + cFilAnt + chr(10) + chr(13) +;
			"Documento: " + SD1->D1_DOC  + chr(10) + chr(13) +;
			"Produto: " + SD1->D1_COD + chr(10) + chr(13) +;
			"Almoxarifado Trânsito: " + cLocTran + chr(10) + chr(13) +;
			"", {"&Ok"}, 3, "Estoque em Trânsito NÃO foi BAIXADO! Cadastros inconsistentes!")

		    MostraErro()


		EndIf
		
	End Transaction
	
	aItens    := {}
	
	SD1->( dbSkip() )
	
EndDo
			
cFilAnt := cFilBkp
 	
RestArea(aArea)  
RestArea(aAreaSF1)
RestArea(aAreaSD1)

Return
        
/*/{Protheus.doc} infcompl()
Atualiza CD5 Nota de Importacao com formulario proprio
@type  		Static Function
@author  	Glauco Oliveira - Eleva Consult
@since   	02/10/2020
@version 	01
@history 	Adoro - Ticket 34
/*/
 
Static Function InfCompl()   

	Local _aArea		:= GetArea()
	Local _cDoc			:= SF1->F1_DOC
	Local _cSerie		:= SF1->F1_SERIE
	Local _cEspecie		:= Space(TamSX3("F1_ESPECI1")[1])
	Local _nVolume		:= 0
	Local _nPBruto		:= 0
	Local _nPLiqui		:= 0
	Local _nOpca		:= 0

	DEFINE MSDIALOG JANELANF STYLE 128 FROM 095,080 TO 330,465 TITLE "Complemetacao de Dados da Nota Fiscal de Entrada" PIXEL OF oMainWnd
	
	JANELANF:lEscClose := .F.
	
	@ 021,010 Say "Volumes"										SIZE 73, 8	OF JANELANF PIXEL
	@ 021,090 Say "Especie"										SIZE 73, 8	OF JANELANF PIXEL
	@ 061,010 Say "P. Bruto"								   	SIZE 73, 8	OF JANELANF PIXEL
	@ 061,090 Say "P. Liquido"									SIZE 73, 8	OF JANELANF PIXEL

	@ 020,040 MsGet _nVolume		Picture "99999"				SIZE 20,10	OF JANELANF PIXEL
	@ 020,120 MsGet _cEspecie		Picture "@!"				SIZE 40,10	OF JANELANF PIXEL
	@ 060,040 MsGet _nPBruto		Picture "@E 999,999.999"	SIZE 40,10	OF JANELANF PIXEL
	@ 060,120 MsGet _nPLiqui		Picture "@E 999,999.999"	SIZE 40,10	OF JANELANF PIXEL

	Define sButton From 100, 130 When .T. Type 1 Action ( _nOpca := 1, JANELANF:End() ) Enable Of JANELANF
	Define sButton From 100, 160 When .T. Type 2 Action ( _nOpca := 2, JANELANF:End() ) Enable Of JANELANF

	Activate Dialog JANELANF CENTERED

	If _nOpca == 1
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		SF1->(dbSeek(xFilial("SF1") + _cDoc + _cSerie))

		RecLock("SF1", .F.)
		SF1->F1_ESPECI1		:= _cEspecie
		SF1->F1_PBRUTO		:= _nPBruto
		SF1->F1_PLIQUI		:= _nPLiqui
		SF1->F1_VOLUME1		:= _nVolume
		MsUnlock()
	EndIf

	RestArea (_aArea)
	
Return

/*/{Protheus.doc} getInfImport()
Grava dados do SF1 Nota de Importacao com formulario proprio
@author		Glauco Oliveira - Eleva Consult
@type		Static Function
@since		02/10/2020
@version	01
@history 	Adoro - Ticket 34
/*/

Static function getInfImport()

	local cExportador	:= Space(60)
	local cFabricante	:= Space(60)
	local cDI			:= Space(20)
	local cLocal	   	:= Space(20)
	local cUF		   	:= Space(2)
	local dData			:= dDataBase
	local dDtDI			:= CToD(" ")
	Local nOpca			:= 0
	local cMenNota		:= ""  
	local nFrete		:= 0
	local nSeg		   	:= 0
	local nAFRMM		:= 0
	Local cCBInterm		:= ""
	Local cInterm		:= ""
	Local aInterm		:= {}
	Local cCBVTrans		:= ""
	Local cVTrans		:= cBoxVTrans()
	Local aVTrans		:= StrToArray(cVTrans, ";")

	Private cF1XNUMEDI	:= ""
	Private dF1XDATADI	:= dDataBase
	Private cF1XLOCDI	:= ""
	Private cF1XUFDI	:= ""
	Private cF1XVIATRA	:= ""
	Private cF1XINTERN	:= ""
	Private nF1AFRMM	:= 0
	
	DEFINE MSDIALOG oDialog STYLE 128 FROM 095,080 TO 500,600 TITLE alltrim(oemToAnsi("NF Importação")) PIXEL
	
		oDialog:lEscClose := .F.
		
		@ 020,010 SAY oemToAnsi("Via Transp:")										OF oDialog PIXEL
		
		@ 040,010 SAY oemToAnsi("Forma Import:")									OF oDialog PIXEL

		oComboVTran := TComboBox():New(020, 060, {|u|if(PCount()>0,cCBVTrans:=u,cCBVTrans)},aVTrans,150,14,oDialog,,,,,,.T.,,,,,,,,,'cCBVTrans')

		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("CD5_INTERM") 
			cInterm		:= AllTrim(X3Cbox())
			aInterm		:= StrToArray(cInterm, ";")
			oComboInter := TComboBox():New(040, 060, {|u|if(PCount()>0,cCBInterm:=u,cCBInterm)},aInterm,150,14,oDialog,,,,,,.T.,,,,,,,,,'cCBInterm')
		EndIf
		
		@ 060,010 SAY oemToAnsi("D.I.:")										OF oDialog PIXEL
		@ 060,060 MSGET cDI PICTURE "@!"						SIZE 70,10		OF oDialog PIXEL VALID !empty(cDI) && F3 "ZA1"
		@ 060,140 SAY oemToAnsi("Data DI:")										OF oDialog PIXEL
		@ 060,170 MSGET dDtDI 									SIZE 40,10		OF oDialog PIXEL  
		
		@ 080,010 SAY oemToAnsi("Local Desemb.:")								OF oDialog PIXEL
		@ 080,060 MSGET cLocal PICTURE "@!" 					SIZE 150,10		OF oDialog PIXEL
		
		@ 100,010 SAY oemToAnsi("UF:")					   			   			OF oDialog PIXEL
		@ 100,060 MSGET cUF PICTURE "@!" F3 "12" 				SIZE 20,10		OF oDialog PIXEL VALID existCpo("SX5","12"+cUF)
		@ 100,120 SAY oemToAnsi("Data Desemb.:")								OF oDialog PIXEL
		@ 100,170 MSGET dData 		SIZE 40,10			   						OF oDialog PIXEL
		 
		@ 120,010 SAY oemToAnsi("Vlr Frete:")									OF oDialog PIXEL
		@ 120,060 MSGET nFrete PICTURE "@E 999,999,999.99" 		SIZE 40,10	   	OF oDialog PIXEL
		  
		@ 120,120 SAY oemToAnsi("Vlr Seguro:")									OF oDialog PIXEL
		@ 120,170 MSGET nSeg PICTURE "@E 999,999,999,999.99"	SIZE 40,10		OF oDialog PIXEL

		@ 140,010 SAY oemToAnsi("Vlr AFRMM:")									OF oDialog PIXEL
		@ 140,060 MSGET nAFRMM PICTURE "@E 999,999,999.99" 		SIZE 40,10	   	OF oDialog PIXEL
		  
		Define sButton From 160, 130 When .T. Type 1 Action ( nOpca := 1, oDialog:End() ) Enable Of oDialog
		Define sButton From 160, 160 When .T. Type 2 Action ( nOpca := 2, oDialog:End() ) Enable Of oDialog
			
	ACTIVATE MSDIALOG oDialog CENTERED 

	If nOpca == 1
		cMenNota := AllTrim(SF1->F1_MENNOTA)
		cMenNota := if(!Empty(cMenNota), cMenNota + Space(1),"")

		cF1XNUMEDI	:= cDI
		dF1XDATADI	:= dDtDI
		cF1XLOCDI	:= cLocal
		cF1XUFDI	:= cUF
		cF1XVIATRA	:= cCBVTrans
		cF1XINTERN	:= cCBInterm
		nF1AFRMM	:= nAFRMM

		SF1->(RecLock("SF1", .F.))  
		SF1->F1_MENNOTA		:= cMenNota 
		SF1->F1_FRETE		:= nFrete   
		SF1->F1_SEGURO		:= nSeg 
		SF1->(MsUnLock())
		
		gravaCD5()

	EndIf

Return

/*/{Protheus.doc} gravaCD5
Grava novo registro na tabela CD5 a partir dos campos personalizados
@type		Static Function
@author		Glauco Oliveira - Eleva Consult
@since		02/10/2020
@version	01
@history 	Adoro - Ticket 34
@version MP12
/*/

Static Function gravaCD5()
	
	Local aAreaSD1	:= SD1->(GetArea())
	Local cCnpjEmp	:= ""
	Local aSM0		:= FWLoadSM0()
	Local nIx		:= 0

	For nIx := 1 To Len(aSM0)
		If aSM0[nIx][01] == FWCodEmp() .And. aSM0[nIx][02] == FWCodFil()
			cCnpjEmp	:= aSM0[nIx][18]
			Exit
		EndIf
	Next nIx

	CD5->(dbSetorder(1))
	CD5->(dbSeek(xFilial("CD5") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) ,.f.))

	While CD5->(!Eof()) .and. CD5->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA) == xFilial("CD5") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			RecLock("CD5", .F., .T.)
			CD5->(dbDelete())
			MsUnlock("CD5")
			CD5->(dbSkip())
	EndDo

	dbSelectArea("SD1")
	SD1->(dbSetOrder(1)) //D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM
	If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	
		While SD1->(!EOF()) .And. xFilial("SD1")+SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA

			If RecLock("CD5", .T.)
				CD5->CD5_FILIAL 	:= xFilial("CD5")
				CD5->CD5_DOC    	:= SF1->F1_DOC
				CD5->CD5_SERIE  	:= SF1->F1_SERIE
				CD5->CD5_DOCIMP 	:= cF1XNUMEDI
				CD5->CD5_TPIMP  	:= "0"  
				CD5->CD5_ESPEC  	:= SF1->F1_ESPECIE
				CD5->CD5_FORNEC 	:= SF1->F1_FORNECE
				CD5->CD5_LOJA   	:= SF1->F1_LOJA
				CD5->CD5_DTPPIS 	:= dF1XDATADI
				CD5->CD5_DTPCOF 	:= dF1XDATADI
				CD5->CD5_DTDI   	:= dF1XDATADI
				CD5->CD5_DTDES   	:= dF1XDATADI
				CD5->CD5_NDI    	:= cF1XNUMEDI
				CD5->CD5_UFDES  	:= cF1XUFDI
				CD5->CD5_LOCDES 	:= cF1XLOCDI
				CD5->CD5_CODFAB 	:= SF1->F1_FORNECE 
				CD5->CD5_LOJFAB 	:= SF1->F1_LOJA
				CD5->CD5_LOCAL  	:= "0"
				CD5->CD5_BSPIS  	:= SD1->D1_BASIMP6
				CD5->CD5_ALPIS  	:= SD1->D1_ALQIMP6
				CD5->CD5_VLPIS  	:= SD1->D1_VALIMP6
				CD5->CD5_BSCOF  	:= SD1->D1_BASIMP5
				CD5->CD5_ALCOF  	:= SD1->D1_ALQIMP5
				CD5->CD5_VLCOF  	:= SD1->D1_VALIMP5
				CD5->CD5_CODEXP		:= SF1->F1_FORNECE
				CD5->CD5_LOJEXP		:= SF1->F1_LOJA
				CD5->CD5_NADIC		:= "001" //SD1->D1_XADICAO
				CD5->CD5_SQADIC		:= STRZERO(VAL(SD1->D1_ITEM),3) //SD1->D1_XSEQADI
				CD5->CD5_BCIMP		:= (SF1->F1_VALMERC - SF1->F1_VALIPI - SF1->F1_VALICM)
				CD5->CD5_VLRII		:= SD1->D1_II
				CD5->CD5_DSPAD		:= 0
				CD5->CD5_VLRIOF		:= 0
				CD5->CD5_ITEM		:= SD1->D1_ITEM
				CD5->CD5_VAFRMM		:= nF1AFRMM

				CD5->CD5_VTRANS		:= cF1XVIATRA
				CD5->CD5_INTERM		:= cF1XINTERN
				CD5->CD5_CNPJAE		:= cCnpjEmp
				CD5->CD5_UFTERC		:= "SP"
				CD5->(msUnlock("CD5"))
			EndIf
			
			SD1->(dbSkip())
		EndDo		
	EndIf
		
	RestArea(aAreaSD1)
		
Return
