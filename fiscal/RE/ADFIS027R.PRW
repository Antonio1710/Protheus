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
	@history CH:047564    - Abel Babini - 08/02/19 | Inclusão de colunas e novas funcionalidades de recusa Adoro automática na conciliacao de XML´s ja devolvidos e/ou cancelados
	@history CH:049259    - Abel Babini - 20/05/19 | Ajuste no envio de email e NF´s recusadas 
	@history CH: TI       - Adriana     - 24/05/2019 Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history CH:060869    - Abel Babini - 25/08/20 | Ajustar Regra para considerar tambémItens que estão como Pré Nota e acrescentar coluna Status no relatório
	@history Ticket 11526 - Abel Babini - 26/03/2021 - Ajustar error.log na variavel cDirP
	@history Ticket 11225 - Abel Babini - 29/03/2021 - Criar novas validação e cruzamentos entre XML, SF1, SD1, SF3, SFT, SE1, SE2
	@history Ticket 13048 - Abel Babini - 26/04/2021 - Criação de parâmetros para tornar opcional a geração do relatório de conferencia cruzada de tabelas
	@history Ticket 15290 - Abel Babini - 08/06/2021 - Cria validação se o array possui conteúdo e se o arquivo existe para prevenir error.log
	/*/
User Function ADFIS027R()

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
	Local _aCFOP	:= {}
	Local _i			:= 0
	Local _j			:= 0
	Local _nArea	:= 0
	Local _aDepto	:= {}
	Local _cDCusto	:= ""

	Local aPergs	:= {}
	Local _lPerg	:= .F.
	Local _lDir		:= .F.
	Local cMsgMl	:= ""
	// Local cXMLml	:= ""
	Local cRelXML	:= ""
	Local aMsgMl	:= {}
	Local nHandle
	Local aAnexos	:= {}
	Local aArqXML	:= {}
	
	Private aRet	:= {}
	Private _cCFOP	:= ""
	Private cQuery	:= ""
	Private _cOrder	:= ""
	Private _cWhereBlq	:= ""
	Private _cAlias	:= ""
	Private _cCNPJ	:= SM0->M0_CGC //'60037058000301'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera planilha com XMLs Pendentes de escrituração por Area')
	
	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data De "     ,Ctod("01/"+Substr(dtos(dDatabase),5,2)+"/"+Substr(dtos(dDatabase),1,4)),"" ,'.T.',,'.T.',40,.T.})
	aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',40,.T.})
	aAdd( aPergs ,{2,"Quebra por"   ,"Não Quebra", {"Não Quebra", "Área"} , 50  ,'.T.',.F.})
	aAdd( aPergs ,{1,"Desconsiderar CFOP " ,"5202,6202,5411,6411"+Space(100),"@!" ,'.T.',,'.T.',100,.F.})
	aAdd( aPergs ,{1,"E-mail " 		,Space(250),"@!" ,'.T.',,'.T.',100,.F.})
	aAdd( aPergs ,{2,"Imprime:"   	,"Não Recusados", {"Não Recusados", "Recusados", "Todos"} , 100  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
	aAdd( aPergs ,{2,"Imprime NF ADORO"   ,"Sim", {"Sim", "Não"} , 50  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
	aAdd( aPergs ,{2,"Gera Rel Validação Cruzada"   ,"Não", {"Sim", "Não"} , 50  ,'.T.',.F.}) //Abel Babini-25/02/19-CH:045978
    
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
	If _lPerg
		If Alltrim(aRet[3]) == "Área" .AND. Alltrim(aRet[5]) == ""
			_lPerg := .F.
			Alert('É necessário informar um endereço de email para receber as informações quando o parâmetro Quebra por = Área!')
		Endif
	Endif
	If _lPerg .And. _lDir
		
		//Cria o arquivo no disco.
		nHdl := FCreate(cDir + cArq,0)

		//Verifica se foi possível criar o arquivo.
		If nHdl == -1
			MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função gerarCSV")
			Return Nil
		EndIf
		
		_aCFOP	:= STRTOKARR( Alltrim(aRet[4]) , ',' ) //Separa(Alltrim(aRet[4]),',')
	 
		For _i:=1 to len(_aCFOP)
			_cCFOP	:=  _cCFOP +_aCFOP[_i]
			If !(_i == len(_aCFOP))
				_cCFOP	+=  + "','"
			Endif
		Next _i
		// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		/*If  aRet[3] == "Área"
			_cOrder	:= '%TM_AREA,CAB.XML_EMISSA,CAB.XML_EMIT,RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)%'
		Else
			_cOrder	:= '%CAB.XML_EMISSA,TM_AREA,CAB.XML_EMIT,RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)%'			
		Endif*/

		If  Alltrim(aRet[3]) == "Área"
			_cOrder	:= '%TM_AREA,TM_NOME,TM_DT,TM_TIPO,TM_NOTA%'
		Else
			_cOrder	:= '%TM_NOME,TM_DT,TM_TIPO,TM_NOTA%'			
		Endif
			
		// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		
		//INÍCIO Abel Babini-25/02/19-CH:045978
		If Alltrim(aRet[6]) == "Não Recusados"
			_cWhereBlq	:= "% AND ZCW_OBSERV IS NULL %" 
		Elseif Alltrim(aRet[6]) == "Recusados"
			_cWhereBlq	:= "% AND ZCW_OBSERV IS NOT NULL %"
		ELse //TODOS
			_cWhereBlq	:= "% %"
		Endif
		
		If Alltrim(aRet[7]) == "Não"
			If Len(_cWhereBlq) == 3
				_cWhereBlq	:= "% AND CAB.XML_NOMEMT NOT LIKE 'ADORO%' %"
			Else
				_cWhereBlq	:= Substr(_cWhereBlq,1,Len(_cWhereBlq)-1) + " AND CAB.XML_NOMEMT NOT LIKE 'ADORO%' %"
			Endif
		Endif
		//FIM Abel Babini-25/02/19-CH:045978
		
		MsgRun( "Carregando dados dos XML´s, aguarde...",,{ || xProcSQL() } )

		//Preenche o arquivo.
		DbSelectArea(_cAlias)
		(_cAlias)->(DbGoTop())
	
		//INICIO Abel Babini-25/02/19-CH:045978
		If Alltrim(aRet[6]) == "Recusados" .OR. Alltrim(aRet[6]) == "Todos"
			cLin := "EMISSAO;CHAVE;TIPO DOC;CNPJ;DOC;SERIE;NOME;CFOP;TIPO MOV.;VALOR;ESCRITURADO;CANCELADO;AREA;STATUS;MOTIVO;" + cEof // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		Else
			cLin := "EMISSAO;CHAVE;TIPO DOC;CNPJ;DOC;SERIE;NOME;CFOP;TIPO MOV.;VALOR;ESCRITURADO;CANCELADO;AREA;STATUS;" + cEof // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
		Endif
		//FIM Abel Babini-25/02/19-CH:045978
	
		dbSelectArea("SA1")
		SA1->(DbSetOrder(3))

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
			If (_cAlias)->VALIDA_DEV = 'DEV'
				If Len(Alltrim((_cAlias)->TM_CHVREF))>0 .AND. !(Alltrim((_cAlias)->TM_CHVREF)==Alltrim((_cAlias)->TM_NOTA))
					_cMotivo	:= 'Entrada efetuada através da NF '+Substr((_cAlias)->TM_DEV2,26,9)+' emitida em '+DtoC(StoD(Right(Alltrim((_cAlias)->TM_DEV2),8)))
					If Substr((_cAlias)->TM_DEV2,45,1) = 'C' //nf cliente
						cCodigo := Posicione("SA1",3,xFilial("SA1")+Substr((_cAlias)->TM_DEV2,7,14),"A1_COD")
					    cLoja   := Posicione("SA1",3,xFilial("SA1")+Substr((_cAlias)->TM_DEV2,7,14),"A1_LOJA")
					Else					
						cCodigo := Posicione("SA2",3,xFilial("SA2")+Substr((_cAlias)->TM_DEV2,7,14),"A2_COD")
					    cLoja   := Posicione("SA2",3,xFilial("SA2")+Substr((_cAlias)->TM_DEV2,7,14),"A2_LOJA")
					EndIf					
				Else				
					_cMotivo	:= 'Entrada referente a NF '+Substr((_cAlias)->TM_DEV1,26,9)+' emitida em '+DtoC(StoD(Right(Alltrim((_cAlias)->TM_DEV1),8)))
					If Substr((_cAlias)->TM_DEV1,45,1) = 'C' //nf cliente
						cCodigo := Posicione("SA1",3,xFilial("SA1")+Substr((_cAlias)->TM_DEV1,7,14),"A1_COD")
					    cLoja   := Posicione("SA1",3,xFilial("SA1")+Substr((_cAlias)->TM_DEV1,7,14),"A1_LOJA")
					Else					
						cCodigo := Posicione("SA2",3,xFilial("SA2")+Substr((_cAlias)->TM_DEV1,7,14),"A2_COD")
					    cLoja   := Posicione("SA2",3,xFilial("SA2")+Substr((_cAlias)->TM_DEV1,7,14),"A2_LOJA")
					EndIf
				Endif
				//RECUSA AUTOMATICA DE DOCUMENTO DEVOLVIDOS
				ZCW->(DbSetOrder(2))
				If !ZCW->(dbSeek(xFilial('ZCW')+Alltrim((_cAlias)->TM_CHAVE)))
					Reclock("ZCW",.T.)
					ZCW->ZCW_FILIAL	:= xFilial('ZCW')	
					ZCW->ZCW_DATA	:= dDatabase
					ZCW->ZCW_NFISCA	:= Substr((_cAlias)->TM_CHAVE,26,9)
					ZCW->ZCW_SERIE	:= Substr((_cAlias)->TM_CHAVE,23,3)
					ZCW->ZCW_CLIFOR	:= cCodigo
					ZCW->ZCW_LOJA	:= cLoja
					ZCW->ZCW_CHVNFE	:= (_cAlias)->TM_CHAVE
					ZCW->ZCW_OBSERV	:= _cMotivo
					ZCW->(MsUnlock())
					
					u_GrLogZBE (Date(),;
								TIME(),;
								cUserName,;
								"INCLUSAO RECUSA DE XML","FISCAL","CEXMBTNFE",;
			                    "NF: "+Substr((_cAlias)->TM_CHAVE,26,9)+" Serie: " +Str(Val(Substr((_cAlias)->TM_CHAVE,23,3)))+" Motivo: "+ Alltrim(_cMotivo) +" User: " +__cUserId,;
			                    ComputerName(),;
			                    LogUserName())
		        Endif						
				//
			Else
			// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
			
				cStatus := "N"
				//INICIO *** ABEL BABINI 20/05/2019 CHAMADO 049259 || FISCAL || DEJAIME || Ajuste Relatório de XML Pendentes
				//SF1->(DbSetOrder(8)) 
				If ((!ZCW->(dbSeek(xFilial('SF1')+Alltrim((_cAlias)->TM_CHAVE)))) .AND. (Alltrim(aRet[6]) == "Não Recusados" .OR. Alltrim(aRet[6]) == "Todos"));
					.OR. (ZCW->(dbSeek(xFilial('SF1')+Alltrim((_cAlias)->TM_CHAVE)))) .AND. (Alltrim(aRet[6]) == "Recusados" .OR. Alltrim(aRet[6]) == "Todos")
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
						cLin += Alltrim(cValToChar((_cAlias)->TM_TIPO))  + ";" // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
						cLin += Transform(Val(cValToChar((_cAlias)->TM_TOTAL)),"@E 999,999,999.99") + ";"
						cLin += "N"      + ";"//ESCRITURADO
						cLin += cStatus  +";" //CANCELADO
						cLin += (_cAlias)->TM_AREA  +";"
						//CH:060869 - Abel Babini - 25/08/20 | Ajustar Regra para considerar tambémItens que estão como Pré Nota e acrescentar coluna Status no relatório
						cLin += (_cAlias)->TM_STATUS +";"

						//INICIO Abel Babini-25/02/19-CH:045978
						If Alltrim(aRet[6]) == "Recusados" .OR. Alltrim(aRet[6]) == "Todos"
							cLin += cValToChar((_cAlias)->MOTIVO)  +";" + cEof
						Else
							cLin += cEof
						Endif
						//FIM Abel Babini-25/02/19-CH:045978
						
						IF Alltrim(aRet[3]) == "Área"
							cMsgMl += '<tr>'
							cMsgMl += '<td>' + cValToChar(DToC(SToD(Alltrim(cValToChar((_cAlias)->TM_DT)))))    								 + '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_CHAVE)       								+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_TPDOC)   									+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_CNPJ)   									+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_NOTA)   							     	+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_SERIE)  									+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_NOME)     									+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_CFOP)    									+ '</td>' //Chamado:043187 - Fernnado sigoli 20/08/2018
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_TIPO)    									+ '</td>' // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
							cMsgMl += '<td>' + cValToChar(Transform(Val(cValToChar((_cAlias)->TM_TOTAL)),"@E 999,999,999.99"))		+ '</td>'
							cMsgMl += '<td>' + cValToChar("N")       								 				+ '</td>'
							cMsgMl += '<td>' + cValToChar(cStatus)       											+ '</td>'
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_AREA)       								+ '</td>'
							//CH:060869 - Abel Babini - 25/08/20 | Ajustar Regra para considerar tambémItens que estão como Pré Nota e acrescentar coluna Status no relatório
							cMsgMl += '<td>' + cValToChar((_cAlias)->TM_STATUS)       								+ '</td>'


							//INICIO *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
							//cRelXML	:= (_cAlias)->TM_CHAVE +'|' 
							cRelXML	:= Alltrim((_cAlias)->TM_CHAVE)
							// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
							//cWhrXML	:= '%'+FormatIn(cRelXML,"|")+'%'
							cWhrXML	:= "%'"+cRelXML+"'%"
							
							cAlsXML:=GetNextAlias()
							BeginSQL  Alias cAlsXML
							
								SELECT 
									CAB.XML_CHAVE as CHAVE,
									ISNULL(CONVERT(VARCHAR(8000),REPLACE(CONVERT(VARBINARY(8000),XML_ARQ),char(13)+char(10),' ')),' ') AS CONTEUDO
								FROM RECNFXML CAB 
								WHERE CAB.%notDel% AND
									XML_CHAVE = %Exp:cWhrXML% 
							EndSQL
							
							//INICIO *** ABEL BABINI 20/05/2019 CHAMADO 049259 || FISCAL || DEJAIME || Ajuste Relatório de XML Pendentes
							IF !ExistDir("\XMLML")
								MakeDir("\XMLML")
							ENDIF
							//FIM *** ABEL BABINI 20/05/2019 CHAMADO 049259 || FISCAL || DEJAIME || Ajuste Relatório de XML Pendentes
							
							While !(cAlsXML)->(Eof())
								cNomArq	:= "\XMLML\"+cRelXML+".XML"
							    nHandle := FCREATE(cNomArq)
							    if !nHandle = -1
							        FWrite(nHandle, (cAlsXML)->CONTEUDO)
							        FClose(nHandle)
							        aAdd(aArqXML,cNomArq)
							    endif					
								(cAlsXML)->(dbSkip())
							EndDo
							(cAlsXML)->(dbCloseArea())
							// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes							
							//FIM *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes

							//INICIO Abel Babini-25/02/19-CH:045978
							If Alltrim(aRet[6]) == "Recusados" .OR. Alltrim(aRet[6]) == "Todos"
								cMsgMl += '<td>' + cValToChar((_cAlias)->MOTIVO) + '</td>'
							Endif
							//FIM Abel Babini-25/02/19-CH:045978
		
							cMsgMl += '</tr>'
						
						Endif
						FWrite(nHdl,cLin,Len(cLin))
						cLin := ""
					Endif
				Endif
			Endif	// *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
			(_cAlias)->(DbSkip())
			If Alltrim(aRet[3]) == "Área" .AND. !(_cAlias)->TM_AREA == _cDCusto //.AND. !cStatus == "S"//Se Quebra por Área, gera 1 XML para cada área 
				//Fecha o arquivo.
				//FClose(nHdl)
				If !cStatus == "S" .or. len(cMsgMl) > 0
					_nArea := _nArea + 1
					Aadd (_aDepto, {_cDCusto})
					Aadd (aMsgMl, {cMsgMl})
					aAdd (aAnexos, {aArqXML})
					cMsgMl := ""
					aArqXML:={}
				Endif
			Endif
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

		If Alltrim(aRet[3]) == "Área"
			cDestina	:= Alltrim(aRet[5])

			For _i := 1 to _nArea
				cTitulo		:= "Relação de XML´s Pendentes de Escrituração - "+Alltrim(_aDepto[_i][1])
				cMens		:= ""
				cMens+= '<html>'+CRLF 
				cMens+= '<body>'+CRLF
				cMens+= '<p>Prezado(a) </p>'+CRLF
				// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				cMens+= '    <p>Até o momento não identificamos a escrituração das notas presentes na relação em anexo. Favor verificar se a nota fiscal já foi enviada ao setor de recebimento e/ou o motivo da não escrituração da mesma. Para notas fiscais fora de competência, favor solicitar aprovação à diretoria e encaminhar o quanto antes para lançamento. <br>'+CRLF
				cMens+= '    Caso alguma das notas não seja de responsabilidade de seu setor, favor nos avisar para que possamos direcioná-la ao setor responsável.</p> '+CRLF
				// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				cMens+= '  <table border=1>'
				cMens += '<tr>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("EMISSAO")		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("CHAVE")			+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("TIPO DOC")   	+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("CNPJ")   		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("DOC")   		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("SERIE")  		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("NOME")     		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("CFOP")    		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("TIPO MOV")    		+ '</b></td>' // *** ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("VALOR")			+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("ESCRITURADO")	+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("CANCELADO")		+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("AREA")			+ '</b></td>'
				cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("STATUS")			+ '</b></td>'
				
				//INICIO Abel Babini-25/02/19-CH:045978
				If Alltrim(aRet[6]) == "Recusados" .OR. Alltrim(aRet[6]) == "Todos"
					cMens += '<td bgcolor="lightblue" align="center"><b>' + cValToChar("MOTIVO")	+ '</b></td>'
				Endif
				//FIM Abel Babini-25/02/19-CH:045978

				cMens += '</tr>'
	
				cMens+= aMsgMl[_i][1]
				cMens += '</table>'
				cMens+= '    <br>'+CRLF
				cMens+= '    Atenciosamente,  <br>'+CRLF
				// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				cMens+= '         Equipe Fiscal/Recebimento'+CRLF	
				//cMens+= '    Telefone: (11) XXXX-XXXX '+CRLF
				// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				cMens+= '</body>'+CRLF
				cMens+= '</html>'+CRLF
				 
				ProcessarEmail(cTitulo,cMens,cDestina,aAnexos[_i])
				
				// *** INICIO ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
				For _j = 1 to Len(aAnexos[_i])
					//Ticket 15290 - Abel Babini - 08/06/2021 - Cria validação se o array possui conteúdo e se o arquivo existe para prevenir error.log
					IF Len(aAnexos[_i,_j]) > 0
						IF File(aAnexos[_i,_j,1])
							FErase( aAnexos[_i,_j,1] )
						ENDIF
					ENDIF
				Next _j
				// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
			Next _i
			
		Endif

		//Ticket 13048 - Abel Babini - 26/04/2021 - Criação de parâmetros para tornar opcional a geração do relatório de conferencia cruzada de tabelas
		If Alltrim(aRet[8]) == "Sim"
			MsgRun( "Gerando relatório de validação cruzada de tabelas, aguarde...",,{ || xVrfTbls(cDir) } )
		Endif
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
			TM_XML,
			TM_CHAVE,
			TM_AREA,
			MOTIVO,
			VALIDA_DEV,
			TM_CHVREF,
			TM_DEV1,
			TM_DEV2,
			TM_TOTAL,
			TM_STATUS
		FROM (
			SELECT DISTINCT
				CASE WHEN CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = '' THEN 'PRÉ NOTA' ELSE 'PENDENTE' END AS TM_STATUS,
				CAB.XML_EMISSA AS TM_DT,
				CAB.XML_KEYF1 AS TM_KEYF1,
				CAB.XML_STATF1 AS TM_STATF1,
				'NF-E' AS TM_TPDOC,
				CAB.XML_EMIT AS TM_CNPJ,
				RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) AS TM_NOTA,
				LEFT(CAB.XML_NUMNF,3) AS TM_SERIE,
				CAB.XML_NOMEMT AS TM_NOME,
				ITEM.XIT_CFNFE AS TM_CFOP,
				( IIF(ITEM.XIT_CFNFE > '5000','SAÍDA','ENTRADA') ) AS TM_TIPO,			
				( IIF(CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') ) > 0,
					SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' '),
						CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') )+33,9)
				,RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)) ) AS TM_XML,
				( IIF(CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') ) > 0,
					SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' '),
						CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') )+8,44)
				,RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)) ) AS TM_CHVREF,
				ITEM.XIT_CHAVE AS TM_CHAVE,
				(	SELECT TOP 1 IIF(SD1.D1_CC >= '9000' AND SD1.D1_CC <= '9998','PROJETOS',CTT.CTT_DESC01) 
					FROM %TABLE:SD1% SD1  (NOLOCK) 
					LEFT JOIN %TABLE:CTT% CTT  (NOLOCK) ON 
						CTT.%notDel% AND 
						CTT.CTT_CUSTO = SD1.D1_CC 
					WHERE  SD1.%notDel% AND 
						SD1.D1_FORNECE = IIF(SA2.A2_COD IS NULL,IIF(SA1.A1_COD IS NULL,' ',SA1.A1_COD),SA2.A2_COD) AND 
						SD1.D1_LOJA = IIF(SA2.A2_COD IS NULL,IIF(SA1.A1_COD IS NULL,' ',SA1.A1_LOJA),SA2.A2_LOJA)  
					ORDER BY  SD1.D1_DTDIGIT DESC 
				)  AS TM_AREA,
				ISNULL(ZCW_OBSERV,'') AS MOTIVO,
				SUM(ITEM.XIT_TOTNFE) AS TM_TOTAL,
				( IIF(ITEM.XIT_CFNFE > '5000',
					(IIF( ( SUM(ITEM.XIT_TOTNFE) - ISNULL((
						SELECT SUM(ITEM2.XIT_TOTNFE)
						FROM RECNFXML  AS CAB2 (NOLOCK) 
						INNER JOIN RECNFXMLITENS  AS ITEM2  (NOLOCK) ON 
							CAB2.XML_CHAVE = ITEM2.XIT_CHAVE 
						WHERE  
							CAB2.XML_EMISSA >= %Exp:DToS(aRet[1])% AND CAB2.XML_EMISSA <= %Exp:DToS(aRet[2])% AND
							CAB2.XML_EMIT = CAB.XML_EMIT AND
							RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)=SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB2.XML_ARQ)),' '),
							CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB2.XML_ARQ)),' ') )+33,9) AND
							ITEM2.XIT_CFNFE NOT IN (%Exp:_cCFOP%) AND 
							CAB2.%notDel% AND 
							ITEM2.%notDel%
						),0) -ISNULL((
						SELECT SUM(ITEM2.XIT_TOTNFE)
						FROM RECNFXML  AS CAB2 (NOLOCK) 
						INNER JOIN RECNFXMLITENS  AS ITEM2  (NOLOCK) ON 
							CAB2.XML_CHAVE = ITEM2.XIT_CHAVE 
						WHERE  
							CAB2.XML_EMIT = CAB.XML_EMIT AND
							RIGHT(RTRIM(LTRIM(CAB2.XML_NUMNF)),9)=SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' '),
							CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') )+33,9) AND
							ITEM2.XIT_CFNFE NOT IN (%Exp:_cCFOP%) AND 
							CAB2.%notDel% AND 
							ITEM2.%notDel%
						),0) )=0,'DEV','OK') ),
					(IIF(SUM(ITEM.XIT_TOTNFE)-ISNULL((
						SELECT SUM(ITEM2.XIT_TOTNFE)
						FROM RECNFXML  AS CAB2  (NOLOCK) 
						INNER JOIN RECNFXMLITENS  AS ITEM2 ON 
							CAB2.XML_CHAVE = ITEM2.XIT_CHAVE 
						WHERE  
							CAB2.XML_EMIT = CAB.XML_EMIT AND
							RIGHT(RTRIM(LTRIM(CAB2.XML_NUMNF)),9)=SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' '),
							CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') )+33,9) AND
							ITEM2.XIT_CFNFE NOT IN (%Exp:_cCFOP%) AND 
							CAB2.%notDel% AND 
							ITEM2.%notDel%
				),0)=0,'DEV','OK')) ) ) AS VALIDA_DEV,
				ISNULL((
						SELECT TOP 1 SUBSTRING(CAB2.XML_CHAVE,1,44)+CAB2.XML_CLIFOR+CAB2.XML_EMISSA
						FROM RECNFXML  AS CAB2  (NOLOCK) 
						WHERE  
							CAB2.XML_EMIT = CAB.XML_EMIT AND
							RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9)=SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB2.XML_ARQ)),' '),
							CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB2.XML_ARQ)),' ') )+33,9) AND 
							CAB2.%notDel%
						),'') AS TM_DEV1,
				ISNULL((
						SELECT TOP 1 SUBSTRING(CAB2.XML_CHAVE,1,44)+CAB2.XML_CLIFOR+CAB2.XML_EMISSA
						FROM RECNFXML  AS CAB2  (NOLOCK) 
						INNER JOIN RECNFXMLITENS  AS ITEM2 ON 
							CAB2.XML_CHAVE = ITEM2.XIT_CHAVE 
						WHERE  
							CAB2.XML_EMIT = CAB.XML_EMIT AND
							RIGHT(RTRIM(LTRIM(CAB2.XML_NUMNF)),9)=SUBSTRING(ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' '),
							CHARINDEX('<refNFe>',ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),CAB.XML_ARQ)),' ') )+33,9) AND
							CAB2.%notDel%
						),'') AS TM_DEV2
			FROM RECNFXML  AS CAB  (NOLOCK) 
			INNER JOIN RECNFXMLITENS  AS ITEM ON 
				CAB.XML_CHAVE = ITEM.XIT_CHAVE 
			LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON 
				SA2.%notDel% AND 
				SA2.A2_CGC = CAB.XML_EMIT 
			LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON 
				SA1.%notDel% AND 
				SA1.A1_CGC = CAB.XML_EMIT 
			LEFT JOIN %TABLE:ZCW% ZCW (NOLOCK) ON 
				ZCW.%notDel% AND 
				ZCW.ZCW_CHVNFE = CAB.XML_CHAVE 
			WHERE  
				(CAB.XML_KEYF1 = '' OR (CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = '')) AND 
				CAB.XML_KEYRUR = '' AND 
				CAB.XML_DEST = %Exp:_cCNPJ%  AND 
				CAB.XML_EMISSA >= %Exp:DToS(aRet[1])% AND CAB.XML_EMISSA <= %Exp:DToS(aRet[2])% AND
				ITEM.XIT_CFNFE NOT IN (%Exp:_cCFOP%) AND 
				CAB.%notDel%  AND 
				ITEM.%notDel% 
				%Exp:_cWhereBlq%
			GROUP BY 
				CAB.XML_EMISSA, 
				CAB.XML_EMIT, 
				SA2.A2_COD, 
				SA2.A2_LOJA, 
				SA1.A1_COD, 
				SA1.A1_LOJA, 
				RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9), 
				LEFT(CAB.XML_NUMNF,3), 
				CAB.XML_NOMEMT, 
				ITEM.XIT_CFNFE, 
				ITEM.XIT_CHAVE, 
				CAB.XML_ARQ,
				CAB.XML_KEYF1,
				CAB.XML_STATF1,
				ZCW_OBSERV  
			) AS RESULTADO

			ORDER BY
				%Exp:_cOrder%

	EndSQL	
	//INICIO CH:060869 - Abel Babini - 25/08/20 | Ajustar Regra para considerar tambémItens que estão como Pré Nota.
	//(CAB.XML_KEYF1 = '' OR (CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = '')) AND 
	//FIM CH:060869 - Abel Babini - 25/08/20 | Ajustar Regra para considerar tambémItens que estão como Pré Nota.
	
	// *** FINAL ABEL BABINI 08/04/2019 CHAMADO 047564 || FISCAL || ALLAN SANTOS || Ajuste Relatório de XML Pendentes
Return _cAlias

/*/{Protheus.doc} User Function processarEmail
	Configurações de e-mail.
	@type  Function
	@author Fernando Sigoli
	@since 29/03/2018
	/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email,aAnexos)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	//Local aFiles        := {}
	Local cAnexos		:= ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local _nx						:= 0
	// Local cAtach        := ""
	//Local cAtach        := "\LFV\WFLFV.XLS"
	Local cSubject      := ""
	//ANEXOS
	
	cAnexos	:= ""
	For _nx := 1 To Len(aAnexos[1])
		//Aadd(aFiles,aAnexos[1,_nx])
		If Alltrim(aAnexos[1,_nx]) != ''
			cAnexos += aAnexos[1,_nx]+";"
		Endif
	Next 	
	//Assunto do e-mail.
	cSubject := cAssunto
	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)			
		Else
			lAutOk := .T.
		EndIf
	EndIf
	If lOk .And. lAutOk
		//Envia o e-mail.
		Send Mail FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAnexos RESULT lOk
		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ALERT("ERRO NO ENVIO")
		Else
			// Aviso ao usuario
			//ALERT("ENVIADO")
		EndIf
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
	EndIf
	If lOk
		Disconnect Smtp Server		
	EndIf
	RestArea(aArea)
Return Nil

//INICIO Ticket 11225 - Abel Babini - 29/03/2021 - Criar novas validação e cruzamentos entre XML, SF1, SD1, SF3, SFT, SE1, SE2
/*/{Protheus.doc} Static Function SalvaXml  
	Salva Arquivo XML - Excel
	@author Abel Babini Filho
	@since 01/04/2019
	@version 01
	/*/
Static Function SalvaXml()
	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
Return()

/*/{Protheus.doc} Static Function CriaExcel  
	Cria Arquivo XML - Excel
	@author Abel Babini Filho
	@since 01/04/2019
	@version 01
	/*/
Static Function CriaExcel()
	
		IF ( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
			oMsExcel := MsExcel():New()
			oMsExcel:WorkBooks:Open(cArquivo)
			oMsExcel:SetVisible( .T. )
			oMsExcel:Destroy()
		ELSE
			Alert("Nao Existe Excel Instalado ou não foi possível localizá-lo. Tente novamente!")
		ENDIF
	
Return() 

/*/{Protheus.doc} User Function xVrfTbls
	Realiza cruzamente entre SF1, SD1, SF3, SFT, SE1/SE2 E XML
	@type  Function
	@author Abel babini
	@since 29/03/2021
	/*/
Static Function xVrfTbls(cDir)
	Local cQrXML := ''
	// Local cQrSF1 := ''
	// Local cQrSD1 := ''
	// Local cQrSFT := ''
	// Local cQrSF3 := ''

	Local cStsXml := ''
	Local cStsCan := ''
	Local cStsRec := ''
	Local cSheet 	:= 'Cruzamento entre tabelas (Central XML x SF1 x SF3)'

	Private oExcel
	Private oMsExcel
	Private cArquivo
 
	cQrXML := GetNextAlias()
	BeginSQL alias cQrXML
		SELECT
			CASE WHEN SF1.F1_DOC IS NULL THEN 'FALTA SF1' ELSE 'SF1 OK' END AS VALIDASF1,
			CASE WHEN SF1.F1_DOC IS NULL THEN '' ELSE SF1.F1_STATUS END AS STATUSSF1,
			CASE WHEN SF3.F3_NFISCAL IS NULL THEN 'FALTA SF3' ELSE 'SF3 OK' END AS VALIDASF3,
			CASE 
				WHEN CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = '' THEN 'PRÉ NOTA' 
				WHEN CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = 'A' THEN 'NOTA' 
				WHEN CAB.XML_KEYF1 <> '' AND CAB.XML_STATF1 = 'B' THEN 'BLOQUEADO' 
				WHEN CAB.XML_KEYRUR <> '' THEN 'NOTA' 
			ELSE 'PENDENTE' END AS TM_STATUS,
			CAB.XML_EMISSA AS EMISSAO,
			CAB.XML_LANCAD AS LANCAD,
			CAB.XML_KEYF1 AS TM_KEYF1,
			CAB.XML_STATF1 AS TM_STATF1,
			CAB.XML_EMIT AS CNPJ,
			RIGHT(RTRIM(LTRIM(CAB.XML_NUMNF)),9) AS NOTA,
			LEFT(CAB.XML_NUMNF,3) AS SERIE,
			CAB.XML_NOMEMT AS NOME,
			CAB.XML_CHAVE AS CHAVEXML,
			ISNULL(ZCW_OBSERV,'') AS MOTIVO,
			SUM(ITEM.XIT_TOTNFE) AS TOTAL
		FROM RECNFXML  AS CAB  (NOLOCK) 
			INNER JOIN RECNFXMLITENS  AS ITEM ON 
				CAB.XML_CHAVE = ITEM.XIT_CHAVE 
				AND ITEM.%notDel%
			LEFT JOIN %TABLE:ZCW% ZCW (NOLOCK) ON 
				ZCW.ZCW_FILIAL = %xFilial:ZCW% AND
				ZCW.%notDel% AND 
				ZCW.ZCW_CHVNFE = CAB.XML_CHAVE 
			LEFT JOIN %TABLE:SF1% SF1  (NOLOCK) 
				ON SF1.%notDel%
				AND SF1.F1_FILIAL = %xFilial:SF1%
				AND (SF1.F1_CHVNFE = CAB.XML_CHAVE
					OR (SF1.F1_FILIAL = SUBSTRING(CAB.XML_KEYRUR,1,2)
						AND SF1.F1_DOC = SUBSTRING(CAB.XML_KEYRUR,3,9) 
						AND SF1.F1_SERIE = SUBSTRING(CAB.XML_KEYRUR,12,3)
						AND SF1.F1_FORNECE = SUBSTRING(CAB.XML_KEYRUR,15,6)
						AND SF1.F1_LOJA = SUBSTRING(CAB.XML_KEYRUR,21,2)
						)
				)
			LEFT JOIN %TABLE:SF3% SF3 (NOLOCK) 
				ON SF3.%notDel%
				AND F3_FILIAL = %xFilial:SF3%
				AND (SF3.F3_CHVNFE = CAB.XML_CHAVE
				OR (SF3.F3_FILIAL = SUBSTRING(CAB.XML_KEYRUR,1,2)
					AND SF3.F3_NFISCAL = SUBSTRING(CAB.XML_KEYRUR,3,9) 
					AND SF3.F3_SERIE = SUBSTRING(CAB.XML_KEYRUR,12,3)
					AND SF3.F3_CLIEFOR = SUBSTRING(CAB.XML_KEYRUR,15,6)
					AND SF3.F3_LOJA = SUBSTRING(CAB.XML_KEYRUR,21,2)
					)
				)
		WHERE
				CAB.XML_DEST = %Exp:_cCNPJ%  AND 
				CAB.XML_EMISSA >= %Exp:DToS(aRet[1])% AND CAB.XML_EMISSA <= %Exp:DToS(aRet[2])% AND
				CAB.%notDel%
				%Exp:_cWhereBlq%
		GROUP BY 
			SF1.F1_DOC,
			SF1.F1_STATUS,
			SF3.F3_NFISCAL,
			CAB.XML_CLIFOR,
			CAB.XML_NUMNF,
			CAB.XML_KEYF1,
			CAB.XML_STATF1,
			CAB.XML_EMISSA,
			CAB.XML_LANCAD,
			CAB.XML_EMIT,
			CAB.XML_NOMEMT,
			CAB.XML_CHAVE,
			CAB.XML_KEYRUR,
			ZCW_OBSERV
	EndSQL

/*ITEM.XIT_CFNFE NOT IN (%Exp:_cCFOP%) AND*/

	oExcel     := FWMSEXCELEX():New()
	oMsExcel   := NIL
	cArquivo := cDir +  'RCROSSTBLS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	oExcel:AddworkSheet('ORIGEM_XML')
	oExcel:AddTable('ORIGEM_XML',cSheet)
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Filial'			,1,1) // 01 FILIAL
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Série'			,1,1) // 02 SERIE
	oExcel:AddColumn('ORIGEM_XML',cSheet,'N.Fiscal'		,1,1) // 03 DOC
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Cod. Forn.'	,1,1) // 04 FORNECEDOR
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Loja'				,1,1) // 05 LOJA
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Nome'				,1,1) // 06 NOME
	oExcel:AddColumn('ORIGEM_XML',cSheet,'CNPJ'				,1,1) // 07 CNPJ
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Dt. Emissão',1,1) // 08 DATA EMISSAO
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Dt. Digit.'	,1,1) // 09 DATA LANÇAMENTO
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Status Doc.',1,1) // 10 OBSERVAÇÃO
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Recusa'			,1,1) // 11 RECUSA
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Total XML'	,2,3) // 12 TOTAL XML
	oExcel:AddColumn('ORIGEM_XML',cSheet,'Chave XML'	,1,1) // 13 CHAVE XML

	While !(cQrXML)->(eof())
		cStsXml := ''
		cStsCan := ''
		cStsRec := ''
		IF !xConfCan(Alltrim(cValToChar(Alltrim((cQrXML)->CHAVEXML))),.F.)
			cStsCan := 'XML CANCELADO OU DESCONHECIMENTO DA OPERAÇÃO'
		ENDIF

		IF !Empty(Alltrim((cQrXML)->MOTIVO))
			cStsRec := 'XML RECUSA ADORO'
		ENDIF

		IF 	Alltrim((cQrXML)->VALIDASF1) == 'FALTA SF1' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'FALTA SF3' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'PENDENTE'
			cStsXml := 'XML PENDENTE'

		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'SF1 OK' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'SF3 OK' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'PENDENTE'
			cStsXml := 'ERRO DE STATUS NA CENTRAL XML'

		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'FALTA SF1' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'FALTA SF3' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'PRÉ NOTA'
			cStsXml := 'ERRO DE STATUS NA CENTRAL XML'

		ELSEIF (Alltrim((cQrXML)->STATUSSF1) == 'A' .OR. ;
				Alltrim((cQrXML)->STATUSSF1) == 'B') .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'PRÉ NOTA'
			cStsXml := 'ERRO DE STATUS NA CENTRAL XML'

		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'SF1 OK' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'FALTA SF3' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'PRÉ NOTA'
			cStsXml := 'PRÉ NOTA'

		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'FALTA SF1' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'SF3 OK'
			cStsXml := 'ERRO SF1 X SF3'
		ELSEIF Alltrim((cQrXML)->VALIDASF3) == 'FALTA SF3' .AND. ;
				Alltrim((cQrXML)->VALIDASF1) == 'SF1 OK'
			cStsXml := 'ERRO SF3 X SF1'
		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'SF1 OK' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'SF3 OK' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'NOTA'
			(cQrXML)->(dbSkip())
			LOOP
		ELSEIF Alltrim((cQrXML)->VALIDASF1) == 'FALTA SF1' .AND. ;
				Alltrim((cQrXML)->VALIDASF3) == 'FALTA SF3' .AND. ;
				Alltrim((cQrXML)->TM_STATUS) == 'NOTA'
			cStsXml := 'XML PENDENTE | ERRO DE STATUS NA CENTRAL XML'
		ENDIF

		cCodigo := Posicione("SA2",3,xFilial("SA2")+Substr((cQrXML)->CNPJ,1,14),"A2_COD")
		cLoja   := Posicione("SA2",3,xFilial("SA2")+Substr((cQrXML)->CNPJ,1,14),"A2_LOJA")

		oExcel:AddRow('ORIGEM_XML',cSheet,{	cFilAnt,;
																							(cQrXML)->SERIE,;
																							(cQrXML)->NOTA,;
																							cCodigo,;
																							cLoja,;
																							(cQrXML)->NOME,;
																							(cQrXML)->CNPJ,;
																							DToC(SToD(Alltrim(cValToChar((cQrXML)->EMISSAO)))),;
																							DToC(SToD(Alltrim(cValToChar((cQrXML)->LANCAD)))),;
																							cStsXml + IIF(!Empty(Alltrim(cStsXml)) .AND. !Empty(Alltrim(cStsCan)),' | ' + cStsCan, Alltrim(cStsCan)) + IIF((!Empty(Alltrim(cStsXml)) .or. !Empty(Alltrim(cStsCan))) .AND. !Empty(Alltrim(cStsRec)),' | ' + Alltrim(cStsRec),Alltrim(cStsRec))  ,;
																							(cQrXML)->MOTIVO,;
																							(cQrXML)->TOTAL,;
																							(cQrXML)->CHAVEXML } )

		(cQrXML)->(dbSkip())
	EndDo
	(cQrXML)->(dbCloseArea())
	oExcel:AddRow('ORIGEM_XML',cSheet,{	"","","","","","","","","","","","",""})

	SalvaXml()
	CriaExcel()	
Return
//FIM Ticket 11225 - Abel Babini - 29/03/2021 - Criar novas validação e cruzamentos entre XML, SF1, SD1, SF3, SFT, SE1, SE2
