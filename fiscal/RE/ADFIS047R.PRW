#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
#Include "Fileio.ch"

/*/{Protheus.doc} User Function ADFIS027R
	Gera planilha com XMLs Pendentes de escrituração por Area)
	@type  Function
	@author uAbel babini Filhoser
	@since 11/02/2019 
	@history CH:045978    - Abel Babini - 25/02/19 | Inclusão de Filtros
	/*/
User Function ADFIS047R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cDir		:= cGetFile("Arquivo xml.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cArq		:= "DADOSXML"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl		:= 0
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	Local nRet  	:= 0
	Local cStatus := ""
	Local _cDCusto	:= ""

	Local aPergs	:= {}
	Local _lPerg	:= .F.
	Local _lDir		:= .F.
	// Local cMsgMl	:= ""
	// Local cXMLml	:= ""
	// Local cRelXML	:= ""
	// Local aMsgMl	:= {}
	// Local nHandle
	// Local aAnexos	:= {}
	// Local aArqXML	:= {}
	
	Private aRet	:= {}
	Private cQuery	:= ""
	Private _cWhereBlq	:= ""
	Private _cAlias	:= ""
	Private _cCNPJ	:= SM0->M0_CGC //'60037058000301'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera planilha com CTE Pendentes de escrituração por Area')
	
	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data De "     ,Ctod("01/"+Substr(dtos(dDatabase),5,2)+"/"+Substr(dtos(dDatabase),1,4)),"" ,'.T.',,'.T.',40,.T.})
	aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',40,.T.})
	aAdd( aPergs ,{2,"Imprime:"   	,"Não Recusados", {"Não Recusados", "Recusados", "Todos"} , 100  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
	// aAdd( aPergs ,{2,"Quebra por"   ,"Não Quebra", {"Não Quebra", "Área"} , 50  ,'.T.',.F.})
	// aAdd( aPergs ,{1,"Desconsiderar CFOP " ,"5202,6202,5411,6411"+Space(100),"@!" ,'.T.',,'.T.',100,.F.})
	// aAdd( aPergs ,{1,"E-mail " 		,Space(250),"@!" ,'.T.',,'.T.',100,.F.})
	// aAdd( aPergs ,{2,"Imprime NF ADORO"   ,"Sim", {"Sim", "Não"} , 50  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
	// aAdd( aPergs ,{2,"Gera Rel Validação Cruzada"   ,"Não", {"Sim", "Não"} , 50  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
    
	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parametros ",aRet,,,,,,,,.T.,.T.) //Abel Babini-25/02/19-CH:045978
		_lPerg	:= .T.
	Else
		Alert('Parâmetros não informados. Relatório não será gerado!')
	Endif

	If !Empty(Alltrim(cValToChar(cDir)))
		_lDir	:= .T.
	Else
		Alert('É necessário selecionar o caminho para salvar o arquivo do relatório (.csv)!')
		cDir	:= cGetFile("Arquivo xml.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
		If !Empty(Alltrim(cValToChar(cDir)))
			_lDir	:= .T.
		Endif
	EndIf
	If _lPerg .And. _lDir
		
		//Cria o arquivo no disco.
		nHdl := FCreate(cDir + cArq,0)

		//Verifica se foi possível criar o arquivo.
		If nHdl == -1
			MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função gerarCSV")
			Return Nil
		EndIf
		
		If Alltrim(aRet[3]) == "Não Recusados"
			_cWhereBlq	:= "% AND TM_STATUS = 'PENDENTE' %" 
		Elseif Alltrim(aRet[3]) == "Recusados"
			_cWhereBlq	:= "% AND TM_STATUS <> 'PENDENTE' %"
		ELse //TODOS
			_cWhereBlq	:= "% %"
		Endif
		
		MsgRun( "Carregando dados dos CTE´s, aguarde...",,{ || xProcSQL() } )

		//Preenche o arquivo.
		DbSelectArea(_cAlias)
		(_cAlias)->(DbGoTop())
	
		If Alltrim(aRet[3]) == "Recusados" .OR. Alltrim(aRet[3]) == "Todos"
			cLin := "EMISSAO;CHAVE;TIPO DOC;CNPJ;DOC;SERIE;NOME;CFOP;TIPO MOV.;VALOR;ESCRITURADO;CANCELADO;AREA;STATUS;MOTIVO;" + cEof // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		Else
			cLin := "EMISSAO;CHAVE;TIPO DOC;CNPJ;DOC;SERIE;NOME;CFOP;TIPO MOV.;VALOR;ESCRITURADO;CANCELADO;AREA;STATUS;" + cEof // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		Endif
	
		dbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		
		dbSelectArea("SD1")
		SD1->(DbSetOrder(10))

		While ! (_cAlias)->(Eof())
			_cDCusto	:= (_cAlias)->TM_AREA			
			// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
			cCodigo		:= ""
			cLoja		:= ""
			_cMotivo	:= ""
			
			cStatus := "N"
			//INICIO *** ABEL BABINI 20/05/2019 CHAMADO 049259 || FISCAL || DEJAIME || Ajuste Relatório de XML Pendentes
			//SF1->(DbSetOrder(8)) 
			// If ((!ZCW->(dbSeek(xFilial('SF1')+Alltrim((_cAlias)->TM_CHAVE)))) .AND. (Alltrim(aRet[3]) == "Não Recusados" .OR. Alltrim(aRet[3]) == "Todos"));
			// 	.OR. (ZCW->(dbSeek(xFilial('SF1')+Alltrim((_cAlias)->TM_CHAVE)))) .AND. (Alltrim(aRet[3]) == "Recusados" .OR. Alltrim(aRet[3]) == "Todos")
			//FIM *** ABEL BABINI 20/05/2019 CHAMADO 049259 || FISCAL || DEJAIME || Ajuste Relatório de XML Pendentes
			
				If !xConfCan(Alltrim(cValToChar((_cAlias)->TM_CHAVE)),.F.)
					cStatus := "S"
				Else
					cLin += DToC(SToD(Alltrim(cValToChar((_cAlias)->TM_DT)))) + ";"
					cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_CHAVE)) + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_TPDOC)) + ";"
					cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_CNPJ))  + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_NOTA))  + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_SERIE)) + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_NOME))  + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_CFOP))  + ";"
					cLin += Alltrim(cValToChar((_cAlias)->TM_TIPO))  + ";" 
					cLin += Transform(Val(cValToChar((_cAlias)->TM_TOTAL)),"@E 999,999,999.99") + ";"
					cLin += "N"      + ";"//ESCRITURADO
					cLin += cStatus  +";" //CANCELADO
					cLin += Alltrim((_cAlias)->TM_AREA)  +";"
					IF Alltrim((_cAlias)->TM_STATUS) == 'PENDETE'
						cLin += 'PENDETE ' + Alltrim((_cAlias)->TM_KEYF1) +";"
					ELSE
						cLin += Alltrim((_cAlias)->TM_STATUS) +";"
					ENDIF
					
					If Alltrim(aRet[3]) == "Recusados" .OR. Alltrim(aRet[3]) == "Todos"
						cLin += cValToChar((_cAlias)->MOTIVO)  +";" + cEof
					Else
						cLin += cEof
					Endif
					
					FWrite(nHdl,cLin,Len(cLin))
					cLin := ""
				Endif
			// Endif

			(_cAlias)->(DbSkip())

		EndDo
	
		If Select(_cAlias) > 0
			(_cAlias)->(DbCloseArea())
		EndIf
		
		//Fecha o arquivo.
		FClose(nHdl)
		
		nRet := ShellExecute("open", cArq, "", cDir, 1)
		//Se houver algum erro.
		If nRet <= 32
			MsgStop("Não foi possível abrir o arquivo " +cDir+cNomeArqP+ ".","RFISR02 - ERRO DE ARQUIVO") //Ticket 11526 - Abel Babini - 26/03/2021 - Ajustar error.log na variavel cDirP para cDir
		EndIf

	Endif
	
	RestArea(aArea)
	
	// Alert('FIM')
Return Nil

/*/{Protheus.doc} User Function xConfCan
	Verifica status dos registros para relatório
	@type  Function
	@author Abel Babini
	@since 25/02/2019
	/*/
Static Function xConfCan( cChave, lAlerta )
	Local aAreaAT	:= GetArea()
	Local aAreaC0	:= C00->( GetArea() )
	Local lRetorno	:= .T.
	Default lAlerta	:= .T.
	DbSelectarea("C00")
	C00->( DbSetorder(1) )
	If C00->( DbSeek( xFilial("C00") + cChave ) )
		If C00->C00_SITDOC == "3"
			lRetorno := .F.
		Else
			//Valida Manifestacao nao realizada / desconhecida
			If Alltrim( C00->C00_STATUS ) == "2"
				lRetorno := .F.
			ElseIf Alltrim( C00->C00_STATUS ) == "3"
				lRetorno := .F.
			EndIf			
		EndIf
	EndIf
	RestArea( aAreaC0 )
	RestArea( aAreaAT )
Return lRetorno

/*/{Protheus.doc} User Function xProcSQL
	Seleciona registro para relatório
	@type  Function
	@author Abel Babini
	@since 25/02/2019
	/*/
Static Function xProcSQL ()
	_cAlias	:= GetNextAlias()
	// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
	BeginSQL  Alias _cAlias
	
		SELECT 
			TM_DT,
			TM_TPDOC,
			TM_CNPJ,
			TM_NOTA,
			TM_SERIE,
			TM_NOME,
			TM_CFOP,
			TM_TIPO,
			TM_CHAVE,
			TM_AREA,
			MOTIVO,
			VALIDA_DEV,
			TM_CHVREF,
			TM_TOTAL,
			TM_STATUS,
			TM_KEYF1
		FROM (
			SELECT DISTINCT
			CASE
				WHEN ZCW_OBSERV IS NOT NULL AND SF1.F1_DOC IS NOT NULL AND SF1.F1_STATUS = '' THEN 'RECUSA ADORO E PRÉ NOTA LANÇADA '
				WHEN ZCW_OBSERV IS NOT NULL AND SF1.F1_DOC IS NOT NULL AND SF1.F1_STATUS <> '' THEN 'RECUSA ADORO E NF ESCRITURADA '
				WHEN ZCW_OBSERV IS NOT NULL AND SF1.F1_DOC IS NULL THEN 'RECUSA ADORO'
				WHEN SF1.F1_DOC IS NOT NULL AND SF1.F1_STATUS = '' THEN 'PRÉ NOTA'
				WHEN SF1.F1_DOC IS NOT NULL THEN 'NF LANÇADA'
				WHEN CAB.XML_REJEIT <> '' THEN 'MANIFESTO RECUSA'
				ELSE 'PENDENTE' END AS TM_STATUS,
				CAB.XML_EMISSA AS TM_DT,
				CAB.XML_KEYF1 AS TM_KEYF1,
				CAB.XML_STATF1 AS TM_STATF1,
				'CTE' AS TM_TPDOC,
				CAB.XML_EMIT AS TM_CNPJ,
				RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) AS TM_NOTA,
				LEFT(CAB.XML_NUMNF,3) AS TM_SERIE,
				CAB.XML_NOMEMT AS TM_NOME,
				ITEM.XIT_CF AS TM_CFOP,
				'ENTRADA' AS TM_TIPO,			
				'' AS TM_CHVREF,
				ITEM.XIT_CHAVE AS TM_CHAVE,
				(	SELECT TOP 1 IIF(SD1.D1_CC >= '9000' AND SD1.D1_CC <= '9998','PROJETOS',CTT.CTT_DESC01) 
					FROM %TABLE:SD1% SD1  (NOLOCK) 
					LEFT JOIN %TABLE:CTT% CTT  (NOLOCK) ON 
						CTT.%notDel% AND 
						CTT.CTT_CUSTO = SD1.D1_CC 
					WHERE  SD1.%notDel% AND 
						SD1.D1_FORNECE+SD1.D1_LOJA IN (SELECT A2_COD+A2_LOJA AS CODFORN FROM %TABLE:SA2% SA2 (NOLOCK) WHERE SA2.A2_CGC = CAB.XML_EMIT AND SA2.D_E_L_E_T_ = '')
					ORDER BY  SD1.D1_DTDIGIT DESC 
				)  AS TM_AREA,
				ISNULL(ZCW_OBSERV,'') AS MOTIVO,
				SUM(ITEM.XIT_TOTNFE) AS TM_TOTAL,
				'OK' AS VALIDA_DEV
			FROM RECNFCTE  AS CAB  (NOLOCK) 
			INNER JOIN RECNFCTEITENS  AS ITEM ON 
				CAB.XML_CHAVE = ITEM.XIT_CHAVE 
			LEFT JOIN %TABLE:ZCW% ZCW (NOLOCK) ON 
				ZCW.%notDel% AND 
				ZCW.ZCW_CHVNFE = CAB.XML_CHAVE 
			LEFT JOIN %TABLE:SF1% SF1 (NOLOCK) ON
				SF1.%notDel% AND 
				SF1.F1_FORNECE+SF1.F1_LOJA IN (SELECT A2_COD+A2_LOJA AS CODFORN FROM %TABLE:SA2% SA2 (NOLOCK) WHERE SA2.A2_CGC = CAB.XML_EMIT AND SA2.D_E_L_E_T_ = '') AND 
				SF1.F1_SERIE = LEFT(CAB.XML_NUMNF, 3) AND
				SF1.F1_DOC = RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)), 9)
			WHERE  
				CAB.XML_DEST = %Exp:_cCNPJ%  AND 
				CAB.XML_EMISSA >= %Exp:DToS(aRet[1])% AND CAB.XML_EMISSA <= %Exp:DToS(aRet[2])% AND
				CAB.XML_CANCEL = '' AND 
				CAB.%notDel%  AND 
				ITEM.%notDel% 
			GROUP BY 
				SF1.F1_DOC,
				SF1.F1_STATUS,
				CAB.XML_EMISSA, 
				CAB.XML_EMIT,
				CAB.XML_REJEIT,
				RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9), 
				LEFT(CAB.XML_NUMNF,3), 
				CAB.XML_NOMEMT, 
				ITEM.XIT_CF, 
				ITEM.XIT_CHAVE, 
				CAB.XML_ARQ,
				CAB.XML_KEYF1,
				CAB.XML_STATF1,
				ZCW_OBSERV  
			) AS RESULTADO
			WHERE 
				TM_STATUS <> 'NF LANÇADA'
				%Exp:_cWhereBlq%
			ORDER BY
				TM_NOME,
				TM_DT,
				TM_TIPO,
				TM_NOTA

	EndSQL	
	
	
Return _cAlias
