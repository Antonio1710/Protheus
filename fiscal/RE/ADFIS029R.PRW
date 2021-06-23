#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIS029R º Autor ³ Abel Babini Filho  º Data ³07/05/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera planilha com NFs e Titulos de INSS pendentes de baixa  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 048910                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADFIS029R()

	Local aArea		:= GetArea()
	Local cDir		:= cGetFile("Arquivo xml.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cArq		:= cDir+"RelINSS"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".XML"
	Local oExcel     := FWMSEXCELEX():New()
	//Local nHdl		:= 0
	Local aPergs	:= {}
	Local aRet		:= {}
	Local _lPerg	:= .F.
	Local _lDir		:= .F.
	Local _cAlias	:= ""
	Local oMsExcel	:= NIL
	Local cWksTit	:= 'Rel_INSS'
	Local cTblNm	:= 'Relatório INSS Pendentes'
	Local nTotVlr	:= 0
	Local nTotINSS	:= 0
	Local nTotSld	:= 0
	Local cWhere	:= ""
	Local _cOrder	:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera planilha com NFs e Titulos de INSS pendentes de baixa')
	
	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data Emissão De "     ,Ctod("01/"+Substr(dtos(dDatabase),5,2)+"/"+Substr(dtos(dDatabase),1,4)),"" ,'.T.',,'.T.',40,.T.})
    aAdd( aPergs ,{1,"Data Emissao Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',40,.T.})
    aAdd( aPergs ,{2,"Ordena por "   		,"Data Digitacao", {"Data Digitacao", "Data Emissao"} , 50  ,'.T.',.F.})
    aAdd( aPergs ,{2,"Apenas com Saldo" 	,"Sim", {"Sim", "Não"} , 50  ,'.T.',.F.})
    
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
		

		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            Return Nil
        EndIF

		If  Alltrim(aRet[3]) == "Data Digitacao"
			_cOrder	:= '%'+'F1_FILIAL,F1_DTDIGIT'+'%'
		Else
			_cOrder	:= '%'+'F1_FILIAL,F1_EMISSAO'+'%'			
		Endif

		//Apenas NF´s com titulos de INSS com saldo
		cWhere := "% %"
		If  Alltrim(aRet[4]) == "Sim"
			cWhere := "% AND SE2.E2_SALDO > 0 %"
		Endif
		
		_cAlias	:= GetNextAlias()
		BeginSQL  Alias _cAlias
			column DTDIGIT as Date
			column EMISSAO as Date
			SELECT 
				SF1.F1_FILIAL	AS FILIAL,
				SF1.F1_TIPO		AS TIPO,
				SF1.F1_ESPECIE	AS ESPECIE,
				SF1.F1_DOC		AS NF,
				SF1.F1_SERIE	AS SERIE,
				SF1.F1_FORNECE	AS CODFOR,
				SF1.F1_LOJA		AS LOJAFOR,
				SA2.A2_NOME		AS FORNECE,
				SF1.F1_EMISSAO	AS EMISSAO,
				SF1.F1_DTDIGIT	AS DTDIGIT,
				SF1.F1_VALBRUT	AS VALOR,
				SF1.F1_INSS		AS INSS,
				SE2.E2_SALDO	AS SALDO
			FROM %TABLE:SF1% SF1
			LEFT JOIN %TABLE:SA2% SA2 ON
				SA2.%notDel%
			AND SA2.A2_COD = SF1.F1_FORNECE
			AND SA2.A2_LOJA = SF1.F1_LOJA
			LEFT JOIN %TABLE:SE2% SE2 ON
				SE2.%notDel%
			AND SE2.E2_FILIAL = SF1.F1_FILIAL
			AND SE2.E2_NUM = SF1.F1_DOC
			AND SE2.E2_PREFIXO = SF1.F1_SERIE
			AND SUBSTRING(SE2.E2_TITPAI,19,6) = SF1.F1_FORNECE
			AND SUBSTRING(SE2.E2_TITPAI,25,2) = SF1.F1_LOJA
			AND SE2.E2_EMISSAO = SF1.F1_EMISSAO
			AND SE2.E2_TIPO = 'INS'
			WHERE SF1.%notDel%
			AND SF1.F1_EMISSAO BETWEEN %Exp:DtoS(aRet[1])% AND %Exp:DtoS(aRet[2])%
			AND SF1.F1_INSS >= 10 
			%Exp:cWhere%
			ORDER BY
				%Exp:_cOrder%
		EndSQL


	    oExcel:AddworkSheet(cWksTit)
	    oExcel:AddTable (cWksTit,cTblNm)
		oExcel:AddColumn(cWksTit,cTblNm,"Filial"		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Tipo Doc."		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Espécie"		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"NF"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Série"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Cód.Forn."		,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Loja"			,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Fornecedor"	,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Dt.Emissão"	,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Dt.Digitação"	,1,1)
		oExcel:AddColumn(cWksTit,cTblNm,"Valor"			,2,2)
		oExcel:AddColumn(cWksTit,cTblNm,"Vl.INSS"		,2,2)
		oExcel:AddColumn(cWksTit,cTblNm,"Saldo.INSS"	,2,2)
	
		DbSelectArea(_cAlias)
		(_cAlias)->(DbGoTop())
		While !(_cAlias)->(Eof())
			oExcel:AddRow(cWksTit,cTblNm,{;
						(_cAlias)->FILIAL,;
						(_cAlias)->TIPO,;
						(_cAlias)->ESPECIE,;
						(_cAlias)->NF,;
						(_cAlias)->SERIE,;
						(_cAlias)->CODFOR,;
						(_cAlias)->LOJAFOR,;
						(_cAlias)->FORNECE,;
						(_cAlias)->EMISSAO,;
						(_cAlias)->DTDIGIT,;
						(_cAlias)->VALOR,;
						(_cAlias)->INSS,;
						(_cAlias)->SALDO;
						})
			nTotVlr	+=(_cAlias)->VALOR
			nTotINSS+=(_cAlias)->INSS
			nTotSld	+=(_cAlias)->SALDO
			(_cAlias)->(dbSkip())
		EndDo

		oExcel:AddRow(cWksTit,cTblNm,{;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"*** TOTAL ***",;
					"",;
					"",;
					nTotVlr,;
					nTotINSS,;
					nTotSld;
					})
		
		oExcel:Activate()
		oExcel:GetXMLFile(cArq)
		
		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(cArq)
		oMsExcel:SetVisible( .T. )
		oMsExcel:Destroy()
		
	Endif
	
	RestArea(aArea)	

Return Nil
