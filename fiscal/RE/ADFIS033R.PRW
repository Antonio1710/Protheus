/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIS033R      ºAutor  ³Abel Babini         ºData  ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de XML CTe Pendentes de escrituração                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Ch.049468 - Abel Babini - Valida Recusa Adoro - 22/07/2019      º±±
±±º          ³ Ch.050792 - Abel Babini - Valida CTe cancelado - 22/07/2019     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Relatório de CTe Pendentes de 

User Function ADFIS033R()

	Local aArea		:= GetArea()
	Local cDir		:= cGetFile("Arquivo xml.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Local cArq		:= "DADOSCTEXML"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl		:= 0
	Local cEof		:= Chr(13) + Chr(10)
	Local aPergs	:= {}
	Local _lPerg	:= .F.
	
	Private _cWhereBlq	:= ""
	Private aRet	:= {}
	Private _cAlias	:= ""
	Private _cCNPJ	:= SM0->M0_CGC //'60037058000301'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de XML CTe Pendentes de escrituração')


	aAdd( aPergs ,{1,"Data De "     ,Ctod("01/"+Substr(dtos(dDatabase),5,2)+"/"+Substr(dtos(dDatabase),1,4)),"" ,'.T.',,'.T.',40,.T.})
    aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',40,.T.})
    aAdd( aPergs ,{2,"Imprime:"   	,"Não Recusados", {"Não Recusados", "Recusados", "Todos"} , 100  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
    //Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
    If ParamBox(aPergs ,"Parametros ",aRet,,,,,,,,.T.,.T.) //Abel Babini-25/02/19-CH:045978
    	_lPerg	:= .T.
    Else
    	Alert('Parâmetros não informados. Relatório não será gerado!')
    Endif
    
    If Empty(Alltrim(cValToChar(cDir)))
    	cDir	:= "C:\TEMP\"
    Endif
    
	If _lPerg 
		
		//Cria o arquivo no disco.
		nHdl := FCreate(cDir + cArq,0)

		//Verifica se foi possível criar o arquivo.
		If nHdl == -1
			MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função gerarCSV")
			Return Nil
		EndIf

		If Alltrim(aRet[3]) == "Não Recusados"
			_cWhereBlq	:= "% AND ZCW_OBSERV IS NULL %" 
		Elseif Alltrim(aRet[3]) == "Recusados"
			_cWhereBlq	:= "% AND ZCW_OBSERV IS NOT NULL %"
		ELse //TODOS
			_cWhereBlq	:= "% %"
		Endif

		MsgRun( "Carregando dados dos XML´s, aguarde...",,{ || xProcSQL() } )

		//Preenche o arquivo.
		DbSelectArea(_cAlias)
		(_cAlias)->(DbGoTop())

		cLin := "NUMERO DA NF;SERIE;VLT. TOTAL;CNPJ;FORNECEDOR;LOJA;RAZÃO SOCIAL;DT.EMISSÃO;RECEBIDO EM;CHAVE CTE;TIPO NF;ESCRITURADO;MOTIVO RECUSA;" + cEof 

		dbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		
		dbSelectArea("SD1")
		SD1->(DbSetOrder(10))

		While ! (_cAlias)->(Eof())

			cLin += Alltrim(cValToChar((_cAlias)->TM_NOTA))  + ";"
			cLin += Alltrim(cValToChar((_cAlias)->TM_SERIE)) + ";"
			cLin += Transform(Val(cValToChar((_cAlias)->TM_TOTAL)),"@E 999,999,999.99") + ";"

			cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_CNPJ))  + ";"
			cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_COD))  + ";"
			cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_LOJA))  + ";"
			cLin += Alltrim(cValToChar((_cAlias)->TM_NOME))  + ";"
			cLin += DToC(SToD(Alltrim(cValToChar((_cAlias)->TM_DT)))) + ";"
			cLin += DToC(SToD(Alltrim(cValToChar((_cAlias)->TM_RECEB)))) + ";"
			cLin += "'"+Alltrim(cValToChar((_cAlias)->TM_CHAVE)) + ";"
			cLin += Alltrim(cValToChar((_cAlias)->TM_TIPO))  + ";"
			cLin += Alltrim(cValToChar((_cAlias)->TM_ESCRIT))  + ";"
			cLin += cValToChar((_cAlias)->MOTIVO)  +";" + cEof

			FWrite(nHdl,cLin,Len(cLin))
			cLin := ""
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
			MsgStop("Não foi possível abrir o arquivo " +cDirP+cNomeArqP+ ".","RFISR02 - ERRO DE ARQUIVO")
		EndIf
	
	Endif
	
	RestArea(aArea)	
	oDlgAdr:End()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xProcSQL       ºAutor  ³Abel Babini         ºData  ³  22/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona registro para relatório                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Adoro S/A                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xProcSQL ()
	_cAlias	:= GetNextAlias()
	BeginSQL  Alias _cAlias
		//Ch.050792 - Abel Babini - Valida CTe cancelado - 22/07/2019 - Ajustado a clausula WHERE, adicionando o filtro de CTEs cancelados.
		SELECT 
			RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) AS TM_NOTA,
			LEFT(CAB.XML_NUMNF,3) AS TM_SERIE,
			CAB.XML_TOTCTE	AS TM_TOTAL,
			CAB.XML_EMIT	AS TM_CNPJ,
			SA2.A2_COD		AS TM_COD,
			SA2.A2_LOJA		AS TM_LOJA,
			CAB.XML_NOMEMT  AS TM_NOME,
			CAB.XML_EMISSA	AS TM_DT,
			CAB.XML_RECEB	AS TM_RECEB,
			CAB.XML_CHAVE	AS TM_CHAVE,
			IIF(CAB.XML_TPFRET='F','FRETE DE SAÍDA','FRETE DE COMPRAS')	AS TM_TIPO,
			IIF(CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = '','PRÉ NOTA',IIF(CAB.XML_KEYF1 = '','NÃO','DOC. ENTRADA')) AS TM_ESCRIT,
			ISNULL(ZCW_OBSERV,'') AS MOTIVO
			FROM RECNFCTE (NOLOCK) AS CAB
			LEFT JOIN %TABLE:SA2% SA2 ON
				SA2.A2_CGC = CAB.XML_EMIT
			AND SA2.%notDel%
			LEFT JOIN %TABLE:ZCW% ZCW ON
			    ZCW.ZCW_CHVNFE = CAB.XML_CHAVE
			AND ZCW.%notDel%
			WHERE 
				(CAB.XML_KEYF1 = '' OR
				 (CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = ''))				
				AND CAB.XML_DEST = %Exp:_cCNPJ% 
				AND CAB.XML_EMISSA >= %Exp:DToS(aRet[1])% AND XML_EMISSA <= %Exp:DToS(aRet[2])%
				AND CAB.XML_CANCEL = ''  
				AND CAB.%notDel% 
				%Exp:_cWhereBlq%

			ORDER BY  
				TM_NOME,
				TM_CHAVE
	EndSQL	
Return _cAlias