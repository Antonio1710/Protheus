#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ADVEN076P
	(Chamado 037261 - Função para envio de cadastro de clientes ao Salesforce)
	@type  Function
	@author Everson
	@since 03/01/2018
	@version 01
	@history Everson 10/12/2018. Chamado 045718. Comentado código para não enviar os agendamentos de visita promotor e vendedor.
	@history Everson 15/05/2019. Chamado 049064. Alterado o campo para envio de pedido mínimo do cliente.
	@history Leon	 24/03/2020. Chamado 055535. Data ultima compra não estava atualizando corretamente.
	@history Everson 18/01/2021. Chamado TI. Adiconada marcação de clientes optantes pelo Simples Nacional.
	@history Everson 19/01/2021. Chamado TI. Alterado campo do simples nacional.
	@history Everson 21/01/2021. Chamado TI. Adicionado tratamento para envio de marcação de Simples Nacional para as demais opções de envio.
	/*/
User Function ADVEN076P(cDe,cAte,lAut,cExpSql,cTpAlt,lParecer,cTexto) // U_ADVEN076("","",.T.) U_ADVEN076("","",.F.," AND A1_VEND = '000028' ","",.T.,"")
	Local aArea      := GetArea()

	Default cDe 	 := ""
	Default cAte	 := ""
	Default lAut	 := .F.
	Default cExpSql  := ""
	Default cTpAlt	 := ""
	Default lParecer := .F.
	Default cTexto	 := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de cadastro de clientes ao SalesForce')

	//
	If ! lAut
		MsAguarde({|| Processar(cDe,cAte,lAut,cExpSql,cTpAlt,lParecer) },"Aguarde","Processando cadastro cliente(SF)...")
	Else
		Processar(cDe,cAte,lAut,cExpSql,cTpAlt,lParecer)
	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Processar
	(Processamento dos envios)
	@type  Function
	@author Everson
	@since 22/12/2017
	@version 01
	@history Chamado 037261
	/*/
Static Function Processar(cDe,cAte,lAut,cExpSql,cTpAlt,lParecer)
	
	Local aParametros := {}
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Account/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "cliente"
	Local cChvExt	:= "Chave_Externa__c/"
	Local aRetOk	:= {}

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil
	EndIf

	//Obtem a query.
	cQuery := scriptSql(cDe,cAte,aResponse,cExpSql,cTpAlt,lParecer)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN076P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"montJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)

	//Processa os registros.
	If  ! lAut
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{},.F.,.T.,"",.T.,.T.) },"Aguarde","Processando cadastro cliente(SF)...",.T.)
		//Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{}) },"Aguarde","Processando cadastro cliente(SF)...",.T.)
	Else
		StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{},.F.,.T.,"",.T.,.T.)
		//StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{})
	EndIf

Return Nil

/*/{Protheus.doc} montJson
	(Monta json)
	@type  Function
	@author Everson
	@since 24/03/2020
	@version 01
	@history Chamado 037261
	/*/
Static Function montJson(cMetodo,cChvExt,cNmAlias)

	Local cJson	 	:= ""
	Local cDiasLV	:= ""
	Local cDiasPrm	:= ""
	Local cTabIP	:= Alltrim(cValToChar( GetMv("MV_#SFTBIP") ))
	Local cCodPrmt	:= ""
	Local cDiasVnd	:= ""
	Local cDtCad	:= ""

	//
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Account"', '"v41.0/sobjects/Account/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'	
			
			//
			/*If cMetodo == "POST"
				cJson += '"Codigo_SA1__c": "' + Alltrim(cValtoChar((cNmAlias)->A1_COD)) + '",'
				cJson += '"Loja_SA1__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_LOJA)) + '",'
		
			EndIf*/

			cJson += '"Codigo_SA1__c": "' + Alltrim(cValtoChar((cNmAlias)->A1_COD)) + '",'
			cJson += '"Loja_SA1__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_LOJA)) + '",'
							
			//Verifica se é uma atualização específica.
			If Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "FRT"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Valor_Frete__c":"' + Alltrim(cValToChar((cNmAlias)->FRETE)) + '"'
			
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "VLRMIN"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				//cJson += '"Preco_Pedido_Minimo_Cliente__c":"' + Alltrim(cValToChar((cNmAlias)->ZBP_VALMIN)) + '"'
				cJson += '"Preco_Pedido_Minimo_Cliente__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XPEDMIN )) + '"' //Everson 15/05/2019. Chamado 049064.
			
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "TEL"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Phone":"' + Alltrim(cValToChar((cNmAlias)->A1_DDD))+Alltrim(cValToChar((cNmAlias)->A1_TEL)) + '"'
			
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "PRT"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cCodPrmt := Posicione("ZC4",1,xFilial("ZC4") + Alltrim(cValToChar((cNmAlias)->A1_XPROMOT)), "ZC4_CODUSR")
				cJson += '"Promotor__r": {"Code__c": "' + cCodPrmt + '"}'
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "GRPC"

				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Codigo_Grupo__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XGRPCOM)) + '"'
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "VND"
				
				//
				//If ! Empty(Alltrim(cValToChar((cNmAlias)->A1_XVEND2)))
					//cJson += '"Vendedor_2__r" : {'
						//cJson += '"Code__c" : "' + Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar((cNmAlias)->A1_XVEND2)),"A3_CODUSR") + '"'
					//cJson += '},'
					
				//Else
					cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
					cJson += '"Vendedor_2__c" : null,'
					
				//EndIf
				
				//Vendedores.
				cJson += '"Vendedor_1__r" : {'
					cJson += '"Code__c" : "' + Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar((cNmAlias)->A1_VEND)),"A3_CODUSR") + '"'
				cJson += '}'
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "BLQFN"
			
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Status__c":"' + Iif(Alltrim(cValToChar((cNmAlias)->A1_MSBLQL)) == "1","Bloqueado Financeiro","Aprovado") + '"'
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "LOGI"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Janelas_de_Recebimento__c":"'     + Alltrim(cValToChar((cNmAlias)->ZCG_JNLREC)) + '",'
				cJson += '"Janela_de_Recebimento_1_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLRE1)) + '",'
				cJson += '"Janela_de_Recebimento_1_Ate__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_JNRE1A)) + '",'
				cJson += '"Janela_de_Recebimento_2_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLRE2)) + '",'
				cJson += '"Janela_de_Recebimento_2_Ate__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_JNRE2A)) + '"'
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "REDECLI"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Rede__c":"' + Alltrim(cValToChar((cNmAlias)->A1_REDE)) + '",'
				If ! Empty(Alltrim(cValtoChar((cNmAlias)->A1_REDE))) .And. ( (Alltrim(cValtoChar((cNmAlias)->A1_REDE)) + "00") <> Alltrim(cValtoChar((cNmAlias)->A1_COD)) + Alltrim(cValtoChar((cNmAlias)->A1_LOJA)) )
						
					cJson += '"Parent":{"Chave_Externa__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_REDE)) + "00" + '"}'
				
				Else
					cJson += '"ParentId":null'
				
				EndIf
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "TABPRC"
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Tabela_IP__r":{"Codigo__c":"' + cTabIP + '"},' 
				cJson += '"Tabela__r":{"Codigo__c":"' + Alltrim(cValToChar((cNmAlias)->A1_TABELA)) + '"}' 
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "AGVEND"
				//Everson 10/12/2018. Chamado 045718.
				/*cDiasVnd := Iif( Alltrim(cValToChar((cNmAlias)->VEDSEG)) == "S" ,"2;","")
				cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDTER)) == "S" ,"3;","")
				cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDQUA)) == "S" ,"4;","")
				cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDQUI)) == "S" ,"5;","")
				cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDSEX)) == "S" ,"6;","")
				cJson += '"Frequencia_Visita_Vendedor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->VEDFRE))),"",Iif(Alltrim(cValToChar((cNmAlias)->VEDFRE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->VEDFRE)) == "Q","Quinzenal","Mensal"))) + '",'	
				cJson += '"Semana_Visita_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->VEDSEM)) + '",'
				Iif( !Empty(cDiasVnd) .And. Substr(cDiasVnd,Len(cDiasVnd),Len(cDiasVnd)) <> ";" ,Nil, cDiasVnd := Substr(cDiasVnd,1,Len(cDiasVnd) - 1) )
				cJson += '"Dias_da_Semana_Visita_Vendedor__c":"' + cDiasVnd + '",'
				cJson += '"Horario_Visita_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->VEDHORA)) + '"'*/
								
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "AGLIG"
				//Everson 10/12/2018. Chamado 045718.
				/*cDiasLV := Iif( Alltrim(cValToChar((cNmAlias)->ZBC_SEG)) == "S" ,"2;","")
				cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_TER)) == "S" ,"3;","")
				cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_QUA)) == "S" ,"4;","")
				cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_QUI)) == "S" ,"5;","")
				cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_SEX)) == "S" ,"6;","")
				Iif( !Empty(cDiasLV) .And. Substr(cDiasLV,Len(cDiasLV), Len(cDiasLV)) <> ";" ,Nil, cDiasLV := Substr(cDiasLV,1,Len(cDiasLV) - 1) )
				cJson += '"Dias_da_Semana_Ligacao_Vendedor__c":"' + cDiasLV + '",'
				cJson += '"Frequencia_Ligacao_Vendedor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE))),"",Iif(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE)) == "Q","Quinzenal","Mensal"))) + '",'	
				cJson += '"Semana_Ligacao_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->ZBC_SEMANA)) + '",'
				cJson += '"Horario_Ligacao_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->ZBC_HORARI)) + '"'*/
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "AGPRM"
				//Everson 10/12/2018. Chamado 045718.
				/*cDiasPrm := Iif( Alltrim(cValToChar((cNmAlias)->PRMSEG)) == "S" ,"2;","")
				cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMTER)) == "S" ,"3;","")
				cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMQUA)) == "S" ,"4;","")
				cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMQUI)) == "S" ,"5;","")
				cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMSEX)) == "S" ,"6;","")
				cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMSAB)) == "S" ,"7;","")
				Iif( !Empty(cDiasPrm) .And. Substr(cDiasPrm,Len(cDiasPrm),Len(cDiasPrm)) <> ";" ,Nil, cDiasPrm := Substr(cDiasPrm,1,Len(cDiasPrm) - 1) )
				cJson += '"Dias_da_Semana_Visita_Promotor__c":"' + cDiasPrm + '",'
				cJson += '"Frequencia_Visita_Promotor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PRMFRE))),"",Iif(Alltrim(cValToChar((cNmAlias)->PRMFRE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->PRMFRE)) == "Q","Quinzenal","Mensal"))) + '",'	
				cJson += '"Semana_Visita_Promotor__c":"' + Alltrim(cValToChar((cNmAlias)->PRMSEM)) + '",'
				cJson += '"Horario_Visita_Promotor__c":"' + Alltrim(cValToChar((cNmAlias)->PRMHORA)) + '"'*/
				
			ElseIf Alltrim(cValToChar((cNmAlias)->TP_ATU)) == "EMAIL"
				
				
				If IsEmail(Alltrim(cValToChar((cNmAlias)->A1_EMAICO)))
				
					cJson += '"Email_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_EMAICO)) + '",'
				
				EndIf
				
				If IsEmail(Alltrim(cValToChar((cNmAlias)->A1_XEMCSF)))
					cJson += '"Email_Comercial__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XEMCSF)) + '",'
				
				EndIf
				
				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				cJson += '"Email_XML__c":"' + Alltrim(cValToChar((cNmAlias)->A1_EMAIL)) + '",'
																				
			Else
				
				//cDtCad := Substr(Alltrim(cValToChar((cNmAlias)->A1_DTCAD)),1,4) + Substr(Alltrim(cValToChar((cNmAlias)->A1_DTCAD)),5,2) + Substr(Alltrim(cValToChar((cNmAlias)->A1_DTCAD)),7,2)
				//cJson += '"Data_Nascimento_Protheus__c":"' + Alltrim(cValToChar((cNmAlias)->A1_DTCAD)) + '",'
				cJson += '"Tabela_IP__r":{"Codigo__c":"' + cTabIP + '"},' 
				cJson += '"Tabela__r":{"Codigo__c":"' + Alltrim(cValToChar((cNmAlias)->A1_TABELA)) + '"},' 
				cJson += '"Status__c":"' + Iif(Alltrim(cValToChar((cNmAlias)->A1_MSBLQL)) == "1","Bloqueado Financeiro","Aprovado") + '",'
				cJson += '"Name": "' + FwNoAccent(StrTran(StrTran(Alltrim(cValToChar((cNmAlias)->A1_NOME)),'"',""),"/")) + '",'
				cJson += '"Tipo_de_Pessoa__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_PESSOA)) + '",'
				cJson += '"CNPJ_CPF__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_CGC)) + '",'
				cJson += '"Imprime_Endereco_entrega__c":"' + Iif(Alltrim(cValtoChar((cNmAlias)->A1_IMPENT)) == "S","S","N") + '",'
				cJson += '"Inscricao_Estadual__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_INSCR)) + '",'
				cJson += '"Nome_Fantasia__c":"' + FwNoAccent(StrTran(StrTran(Alltrim(cValtoChar((cNmAlias)->A1_NREDUZ)),'"',""),"/")) + '",'
			
				//Endereço de entrega do cliente.
				
				cJson += '"Regime_Especial__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_REGESP)) + '",'
				cJson += '"Razao_Social_Entrega__c":"' + Iif(! Empty(Alltrim(cValToChar((cNmAlias)->A1_RAZENT))),Alltrim(cValToChar((cNmAlias)->A1_RAZENT)), StrTran(Alltrim(cValToChar((cNmAlias)->A1_NOME)),'"',"") ) + '",'
				cJson += '"CNPJ_CPF_Entrega__c":"' + Iif(! Empty(Alltrim(cValToChar((cNmAlias)->A1_CGCENT))),Alltrim(cValToChar((cNmAlias)->A1_CGCENT)),Alltrim(cValtoChar((cNmAlias)->A1_CGC))) + '",'
				cJson += '"Inscricao_Estadual_Entrega__c":"' + Iif(! Empty(Alltrim(cValToChar((cNmAlias)->A1_INSENT))),Alltrim(cValToChar((cNmAlias)->A1_INSENT)),Alltrim(cValtoChar((cNmAlias)->A1_INSCR))) + '",'	
				cJson += '"CEP_Entrega__c":"' + Iif(! Empty(Alltrim(cValtoChar((cNmAlias)->A1_CEPE))),Alltrim(cValtoChar((cNmAlias)->A1_CEPE)),Alltrim(cValToChar((cNmAlias)->A1_CEP))) + '",'
				cJson += '"Endereco_Entrega__c":"' + Iif(At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDENT)),1) <= 0, Alltrim(cValToChar((cNmAlias)->A1_ENDENT)), Substr(Alltrim(cValToChar((cNmAlias)->A1_ENDENT)),1,At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDENT)),1)-1) ) + '",'	
				//cJson += '"Numero_Entrega__c":"' + Alltrim(Substr(Alltrim(cValToChar((cNmAlias)->A1_ENDENT)),At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDENT)),1) + 1,Len(Alltrim(cValToChar((cNmAlias)->A1_ENDENT))))) + '",'
				cJson += '"Numero_Entrega__c":"' + StrTran(StrTran(Alltrim(cValToChar((cNmAlias)->PB3_NUMENT)),"/",""),"\","") + '",'
				cJson += '"Bairro_Entrega__c":"' + Alltrim(cValToChar((cNmAlias)->A1_BAIRROE)) + '",'
				cJson += '"Codigo_Municipio_Entrega__c":"' + Alltrim(cValToChar((cNmAlias)->A1_CODMUNE)) + '",'
				cJson += '"Estado_Entrega__c":"' + Alltrim(cValToChar((cNmAlias)->A1_ESTE)) + '",'
				cJson += '"Pais_Entrega__c":"' + Alltrim(cValToChar((cNmAlias)->YA_DESCR)) + '",' 
				cJson += '"Municipio_Entrega__c":"' + Alltrim(cValToChar((cNmAlias)->A1_MUNE)) + '",' 
    			
				//Endereço de cobrança do cliente.
				cJson += '"CEP_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_CEPC)) + '",'
				cJson += '"Endereco_Cobranca__c":"' + Iif(At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)),1) <= 0, Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)), Substr(Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)),1,At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)),1)-1) ) + '",'
				//cJson += '"Numero_Cobranca__c":"' + Alltrim(Substr(Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)),At(",",Alltrim(cValToChar((cNmAlias)->A1_ENDCOB)),1) + 1,Len(Alltrim(cValToChar((cNmAlias)->A1_ENDCOB))))) + '",'
				cJson += '"Numero_Cobranca__c":"' + StrTran(StrTran(Alltrim(cValToChar((cNmAlias)->PB3_NUMCOB)),"/",""),"\","") + '",'
				cJson += '"Bairro_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_BAIRROC)) + '",'
				cJson += '"Codigo_Municipio_Cobranca__c":"' + Alltrim(cValToChar(Posicione("CC2",4,xFilial("CC2") + Alltrim(cValToChar((cNmAlias)->A1_ESTC)) + Alltrim(cValToChar((cNmAlias)->A1_MUNC)) ,"CC2_CODMUN"))) + '",'
				cJson += '"Estado_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_ESTC)) + '",'
				cJson += '"Pais_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->YA_DESCR)) + '",'
				cJson += '"Municipio_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_MUNC)) + '",' 
			
				//Endereço do cliente.
				cJson += '"CEP__c":"' + Alltrim(cValToChar((cNmAlias)->A1_CEP)) + '",'
				cJson += '"Endereco__c":"' + Iif(At(",",Alltrim(cValToChar((cNmAlias)->A1_END)),1) <= 0, Alltrim(cValToChar((cNmAlias)->A1_END)), Substr(Alltrim(cValToChar((cNmAlias)->A1_END)),1,At(",",Alltrim(cValToChar((cNmAlias)->A1_END)),1)-1) ) + '",'
				//cJson += '"Numero__c":"' + Alltrim(Substr(Alltrim(cValToChar((cNmAlias)->A1_END)),At(",",Alltrim(cValToChar((cNmAlias)->A1_END)),1) + 1,Len(Alltrim(cValToChar((cNmAlias)->A1_END))))) + '",'
				cJson += '"Numero__c":"' + StrTran(StrTran(Alltrim(cValToChar((cNmAlias)->PB3_NUMERO)),"/",""),"\","") + '",'
				cJson += '"Bairro__c":"' + Alltrim(cValToChar((cNmAlias)->A1_BAIRRO)) + '",'
				cJson += '"Codigo_Municipio__c":"' + Alltrim(cValToChar((cNmAlias)->A1_COD_MUN)) + '",'
				cJson += '"Estado__c":"' + Alltrim(cValToChar((cNmAlias)->A1_EST)) + '",'
				cJson += '"Pais__c":"' + Alltrim(cValToChar((cNmAlias)->YA_DESCR)) + '",'
				cJson += '"Municipio__c":"' + Alltrim(cValToChar((cNmAlias)->A1_MUN)) + '",' 
			
				//Telefone.
				cJson += '"Phone":"' + Alltrim(cValToChar((cNmAlias)->A1_DDD))+Alltrim(cValToChar((cNmAlias)->A1_TEL)) + '",'
			
				//E-mail.
				cJson += '"Email_XML__c":"' + Alltrim(cValToChar((cNmAlias)->A1_EMAIL)) + '",'

				If IsEmail(Alltrim(cValToChar((cNmAlias)->A1_EMAICO)))
				
					cJson += '"Email_Cobranca__c":"' + Alltrim(cValToChar((cNmAlias)->A1_EMAICO)) + '",'
				
				EndIf
				
				If IsEmail(Alltrim(cValToChar((cNmAlias)->A1_XEMCSF)))
					cJson += '"Email_Comercial__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XEMCSF)) + '",'
				
				EndIf
			
				cJson += '"Limite_Financeiro__c":"' + Alltrim(cValToChar((cNmAlias)->A1_LC)) + '",'
			
				//Condição de pagamento.
				cJson += '"Condicao_de_Pagamento__r" : {'
				cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->A1_COND)) + '"'
				cJson += '},'
			
				cJson += '"Pais_Bacen__c":"' + Alltrim(cValToChar((cNmAlias)->A1_CODPAIS)) + '",'
			
				cJson += '"Contribuinte__c":"' + Iif(Alltrim(cValToChar((cNmAlias)->A1_CONTRIB)) == "1","S","N") + '",'
				
				cJson += '"Rede__c":"' + Alltrim(cValToChar((cNmAlias)->A1_REDE)) + '",'
				
				//Vendedores.
				cJson += '"Vendedor_1__r" : {'
				cJson += '"Code__c" : "' + Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar((cNmAlias)->A1_VEND)),"A3_CODUSR") + '"'
				cJson += '},'
				
				//
				//If ! Empty(Alltrim(cValToChar((cNmAlias)->A1_XVEND2)))
					//cJson += '"Vendedor_2__r" : {'
						//cJson += '"Code__c" : "' + Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar((cNmAlias)->A1_XVEND2)),"A3_CODUSR") + '"'
					//cJson += '},'
			
				//Else
					cJson += '"Vendedor_2__c" : null,'
					
				//EndIf
				
				//
				If ! Empty(Alltrim(cValtoChar((cNmAlias)->A1_REDE))) .And. ( (Alltrim(cValtoChar((cNmAlias)->A1_REDE)) + "00") <> Alltrim(cValtoChar((cNmAlias)->A1_COD)) + Alltrim(cValtoChar((cNmAlias)->A1_LOJA)) )
						
					cJson += '"Parent":{"Chave_Externa__c":"' + Alltrim(cValtoChar((cNmAlias)->A1_REDE)) + "00" + '"},'
				
				Else
					cJson += '"ParentId":null,'
				
				EndIf
				
				//
				cJson += '"Score_de_Risco__c":"' + Alltrim(cValToChar((cNmAlias)->A1_RISCO)) + '",'	
				
				If ! Empty(Alltrim(cValToChar((cNmAlias)->A1_ULTCOM)))
					cJson += '"Data_Ultima_Compra__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->A1_ULTCOM))) ,"" ,Substr(Alltrim(cValToChar((cNmAlias)->A1_ULTCOM)),1,4) + "-" + Substr(Alltrim(cValToChar((cNmAlias)->A1_ULTCOM)),5,2) + "-" +  Substr(Alltrim(cValToChar((cNmAlias)->A1_ULTCOM)),7,2)) + '",'	//Chamado 055535 - Leon Toledo 24/03/2020
				Else
					cJson += '"Data_Ultima_Compra__c":null,'
				EndIf
				
				cJson += '"Nome_Associacao__c":"' + Alltrim(cValToChar((cNmAlias)->A1_NOMEASS)) + '",'	
				//cJson += '"Preco_Pedido_Minimo_Cliente__c":"' + Alltrim(cValToChar((cNmAlias)->ZBP_VALMIN)) + '",'
				cJson += '"Preco_Pedido_Minimo_Cliente__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XPEDMIN )) + '",'	
				cJson += '"Valor_Frete__c":"' + Alltrim(cValToChar((cNmAlias)->FRETE)) + '",'
				cJson += '"Grupo_Vendas__c":"' + Alltrim(cValToChar((cNmAlias)->A1_GRPVEN)) + '",'
				cJson += '"Categoria__c":"' + Alltrim(cValToChar((cNmAlias)->A1_SATIV2)) + '",'
				
				
				//Promotor.
					If ! Empty(Alltrim(cValToChar((cNmAlias)->A1_XPROMOT)))
						cCodPrmt := Posicione("ZC4",1,xFilial("ZC4") + Alltrim(cValToChar((cNmAlias)->A1_XPROMOT)), "ZC4_CODUSR")
						cJson += '"Promotor__r": {"Code__c": "' + cCodPrmt + '"},'
						
					Else
						cJson += '"Promotor__c":null,'
						
					EndIf
				//
				
					/*cDiasPrm := Iif( Alltrim(cValToChar((cNmAlias)->PRMSEG)) == "S" ,"2;","")
					cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMTER)) == "S" ,"3;","")
					cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMQUA)) == "S" ,"4;","")
					cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMQUI)) == "S" ,"5;","")
					cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMSEX)) == "S" ,"6;","")
					cDiasPrm += Iif( Alltrim(cValToChar((cNmAlias)->PRMSAB)) == "S" ,"7;","")
					Iif( !Empty(cDiasPrm) .And. Substr(cDiasPrm,Len(cDiasPrm),Len(cDiasPrm)) <> ";" ,Nil, cDiasPrm := Substr(cDiasPrm,1,Len(cDiasPrm) - 1) )
					cJson += '"Dias_da_Semana_Visita_Promotor__c":"' + cDiasPrm + '",'
					cJson += '"Frequencia_Visita_Promotor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PRMFRE))),"",Iif(Alltrim(cValToChar((cNmAlias)->PRMFRE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->PRMFRE)) == "Q","Quinzenal","Mensal"))) + '",'	
					cJson += '"Semana_Visita_Promotor__c":"' + Alltrim(cValToChar((cNmAlias)->PRMSEM)) + '",'
					cJson += '"Horario_Visita_Promotor__c":"' + Alltrim(cValToChar((cNmAlias)->PRMHORA)) + '",'*/
				//
				
				/*
				//Ligação vendedor.
					cDiasLV := Iif( Alltrim(cValToChar((cNmAlias)->ZBC_SEG)) == "S" ,"2;","")
					cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_TER)) == "S" ,"3;","")
					cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_QUA)) == "S" ,"4;","")
					cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_QUI)) == "S" ,"5;","")
					cDiasLV += Iif( Alltrim(cValToChar((cNmAlias)->ZBC_SEX)) == "S" ,"6;","")
					Iif( !Empty(cDiasLV) .And. Substr(cDiasLV,Len(cDiasLV), Len(cDiasLV)) <> ";" ,Nil, cDiasLV := Substr(cDiasLV,1,Len(cDiasLV) - 1) )
					cJson += '"Dias_da_Semana_Ligacao_Vendedor__c":"' + cDiasLV + '",'
					cJson += '"Frequencia_Ligacao_Vendedor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE))),"",Iif(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->ZBC_FREQUE)) == "Q","Quinzenal","Mensal"))) + '",'	
					cJson += '"Semana_Ligacao_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->ZBC_SEMANA)) + '",'
					cJson += '"Horario_Ligacao_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->ZBC_HORARI)) + '",'
				*/
				
				/*
				//Visita vendedor.
					cDiasVnd := Iif( Alltrim(cValToChar((cNmAlias)->VEDSEG)) == "S" ,"2;","")
					cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDTER)) == "S" ,"3;","")
					cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDQUA)) == "S" ,"4;","")
					cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDQUI)) == "S" ,"5;","")
					cDiasVnd += Iif( Alltrim(cValToChar((cNmAlias)->VEDSEX)) == "S" ,"6;","")
					cJson += '"Frequencia_Visita_Vendedor__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->VEDFRE))),"",Iif(Alltrim(cValToChar((cNmAlias)->VEDFRE)) == "S","Semanal",Iif(Alltrim(cValToChar((cNmAlias)->VEDFRE)) == "Q","Quinzenal","Mensal"))) + '",'	
					cJson += '"Semana_Visita_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->VEDSEM)) + '",'
					Iif( !Empty(cDiasVnd) .And. Substr(cDiasVnd,Len(cDiasVnd),Len(cDiasVnd)) <> ";" ,Nil, cDiasVnd := Substr(cDiasVnd,1,Len(cDiasVnd) - 1) )
					cJson += '"Dias_da_Semana_Visita_Vendedor__c":"' + cDiasVnd + '",'
					cJson += '"Horario_Visita_Vendedor__c":"' + Alltrim(cValToChar((cNmAlias)->VEDHORA)) + '",'*/
				//
				
				cJson += '"Nome_do_Socio_1__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO1)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_1__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSOC))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSOC)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_1__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSOC)) + '",'
				cJson += '"Complemento_Socio_1__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC1)) + '",'

				cJson += '"Simples_Nacional__c":"'     	  + Iif(Alltrim(cValToChar((cNmAlias)->A1_SIMPNAC)) == "1","true","false") + '",' //Everson - 18/01/2021 //Everson - 19/01/2021
				
				cJson += '"Nome_do_Socio_2__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO2)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_2__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO2))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO2)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_2__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO2)) + '",'
				cJson += '"Complemento_Socio_2__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC2)) + '",'
				
				cJson += '"Nome_do_Socio_3__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO3)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_3__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO3))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO3)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_3__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO3)) + '",'
				cJson += '"Complemento_Socio_3__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC3)) + '",'
				
				cJson += '"Nome_do_Socio_4__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO4)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_4__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO4))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO4)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_4__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO4)) + '",'
				cJson += '"Complemento_Socio_4__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC4)) + '",'
				
				cJson += '"Nome_do_Socio_5__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO5)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_5__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO5))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO5)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_5__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO5)) + '",'
				cJson += '"Complemento_Socio_5__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC5)) + '",'
				
				cJson += '"Nome_do_Socio_6__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO6)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_6__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO6))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO6)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_6__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO6)) + '",'
				cJson += '"Complemento_Socio_6__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC6)) + '",'
				
				cJson += '"Nome_do_Socio_7__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO7)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_7__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO7))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO7)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_7__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO7)) + '",'
				cJson += '"Complemento_Socio_7__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC7)) + '",'
				
				cJson += '"Nome_do_Socio_8__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO8)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_8__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO8))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO8)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_8__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO8)) + '",'
				cJson += '"Complemento_Socio_8__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC8)) + '",'
				
				cJson += '"Nome_do_Socio_9__c":"'         + Alltrim(cValToChar((cNmAlias)->PB3_NOMSO9)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_9__c":"'  + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESSO9))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESSO9)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_9__c":"' 		  + Alltrim(cValToChar((cNmAlias)->PB3_CGCSO9)) + '",'
				cJson += '"Complemento_Socio_9__c":"'     + Alltrim(cValToChar((cNmAlias)->PB3_COMSC9)) + '",'
				
				cJson += '"Nome_do_Socio_10__c":"'        + Alltrim(cValToChar((cNmAlias)->PB3_NOMS10)) + '",'
				cJson += '"Tipo_de_Pessoa_Socio_10__c":"' + Iif(Empty(Alltrim(cValToChar((cNmAlias)->PB3_PESS10))),"",Iif(Alltrim(cValToChar((cNmAlias)->PB3_PESS10)) == "F",'Física','Jurídica')) + '",'
				cJson += '"CPF_CNPJ_Socio_10__c":"'       + Alltrim(cValToChar((cNmAlias)->PB3_CGCS10)) + '",'
				cJson += '"Complemento_Socio_10__c":"'    + Alltrim(cValToChar((cNmAlias)->PB3_COMS10)) + '",'
				
				/*cJson += '"Janelas_de_Recebimento__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLREC)) + '",'
				cJson += '"Janela_de_Recebimento_1_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLRE1)) + '",'
				cJson += '"Janela_de_Recebimento_1_Ate__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNRE1A)) + '",'
				cJson += '"Janela_de_Recebimento_2_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLRE2)) + '",'
				cJson += '"Janela_de_Recebimento_2_Ate__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNRE2A)) + '",'*/
			
				/*//cJson += '"Janela_de_Compras__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNLCMP)) + '",'	
				cJson += '"Janela_de_Compras_1_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNCMP1)) + '",'	
				cJson += '"Janela_de_Compras_1_Ate__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNCP1A)) + '",'	
				cJson += '"Janela_de_Compras_2_De__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNCMP2)) + '",'	
				cJson += '"Janela_de_Compras_2_Ate__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_JNCP2A)) + '",'
			
				//Específico
				cJson += '"Telefone_Logistica__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XTELLO)) +'",'
				cJson += '"Telefone_Financeiro__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XTELFI)) +'",'
				cJson += '"Origem_Lead__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XORILE)) +'",'
				cJson += '"Canal_Origem_Lead__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XCNLOR)) +'",'
				cJson += '"Score_de_Rentabilidade__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XSCRRE)) +'",'
				cJson += '"Renda_Familiar__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XRENFA)) +'",'
				cJson += '"Populacao_Total__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_XPOPTO)) +'",'
				cJson += '"Quantidade_de_Trabalhadores__c":"'+ Alltrim(cValToChar((cNmAlias)->ZCG_TFUNC)) +'",'
				cJson += '"Performace_de_Pagamento__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_PERFPG)) + '",'
				cJson += '"Principal_Fornecedor__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_PRFORN)) + '",'
				cJson += '"Principais_Fornecedores__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_PRSFOR)) + '",'
				cJson += '"Cortes__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_CORTES)) + '",'
				cJson += '"Ticket_Medio__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_TCKMED)) + '",'
				cJson += '"Periodicidade_de_Compras__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_PERCMP)) + '",'
				cJson += '"Volume_de_Compras_Kg__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_VOLCMP)) + '",'
				cJson += '"Quantidade_de_Refeicoes__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_QTDREF)) + '",'	
				cJson += '"Quantidade_Funcionarios__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_TFUNC)) + '",'
				
				cJson += '"Codigo_Cliente__c":"' + Alltrim(cValToChar((cNmAlias)->ZCG_CODCLI)) + '"'*/
				
				cJson += '"Codigo_Grupo__c":"' + Alltrim(cValToChar((cNmAlias)->A1_XGRPCOM)) + '"'
			
			EndIf
	
		cJson += '}'

	cJson += '},'
	
Return cJson

/*/{Protheus.doc} scriptSql
	(Script sql para consulta)
	@type  Function
	@author Everson
	@since 18/12/2017
	@version 01
	@history Chamado 037261.
	/*/
Static Function scriptSql(cDe,cAte,aResponse,cExpSql,cTpAlt,lParecer)

	Local cQuery 	:= ""	
	Local cCodVend	:= ""

	//
	cDe 	:= Alltrim(cValToChar(cDe))
	cAte	:= Alltrim(cValToChar(cAte))
	cExpSql	:= Alltrim(cValToChar(cExpSql))
	cTpAlt	:= Alltrim(cValToChar(cTpAlt))
	
	//
/*	If ! StaticCall(ADVEN075P,chkVend,aResponse,@cCodVend)
		Return cQuery 

	EndIf*/

	//
	cQuery += " SELECT  "
	cQuery += " '" + cTpAlt + "' AS TP_ATU, '" + Iif(lParecer,"S","N") + "' AS PARECER, A1_XIDSF AS IDSALES,"
	cQuery += " RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) AS CHVSF, A1_COD, A1_LOJA,  "
	cQuery += " CASE WHEN (RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA))) = (RTRIM(LTRIM(A1_REDE)) + '00') THEN '1' ELSE '0' END AS MATRIZ, "
	
	If     cTpAlt == "BLQFN"
		cQuery += " A1_MSBLQL, ' Alt - status financeiro ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt ==  "FRT"
		cQuery += " ISNULL(CASE WHEN VLRFRT.FRTREG IS NULL THEN VLRFRT.FRTEST ELSE VLRFRT.FRTREG END,0) AS FRETE, ' Alt - Frete ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "VLRMIN"
		//cQuery += " ZBP_VALMIN, ' Alt - Valor mínimo ' AS DESALT "
		cQuery += " A1_XPEDMIN, ' Alt - Valor mínimo ' AS DESALT, A1_SIMPNAC " //Everson 15/05/2019. Chamado 049064. //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "TEL"
		cQuery += " A1_DDD, A1_TEL, ' Alt - Telefone ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "PRT"
		cQuery += " A1_XPROMOT, ' Alt - Promotor ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "GRPC"
		cQuery += " A1_XGRPCOM, ' Alt - Grupo de compra ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "VND"
		cQuery += " A1_XVEND2, CASE WHEN A3_XAGRSF = '' OR A3_XAGRSF IS NULL THEN A3_COD ELSE A3_XAGRSF END AS A1_VEND, ' Alt - Vendedores ' AS DESALT, A1_SIMPNAC  " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "LOGI"
		cQuery += " ZCG_JNLREC, ZCG_JNLRE1, ZCG_JNRE1A, ZCG_JNLRE2, ZCG_JNRE2A, ' Alt - Janela Logística ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "REDECLI"
		cQuery += " A1_REDE , ' Alt - Rede ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "TABPRC"
		cQuery += " A1_TABELA, ' Alt - Tabela do cliente ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "AGVEND"
		cQuery += " VEND.VEDSEG, VEND.VEDTER, VEND.VEDQUA, VEND.VEDQUI, VEND.VEDSEX, VEND.VEDFRE, VEND.VEDSEM, VEND.VEDHORA, ' Alt - Agenda vendedor ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
	
	ElseIf cTpAlt == "AGLIG"
		cQuery += " LIG.ZBC_SEG, LIG.ZBC_TER, LIG.ZBC_QUA, LIG.ZBC_QUI, LIG.ZBC_SEX, LIG.ZBC_FREQUE, LIG.ZBC_SEMANA, LIG.ZBC_HORARI, ' Alt - Agenda ligação ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
	
	ElseIf cTpAlt == "AGPRM"
		cQuery += " PRM.PRMSEG, PRM.PRMTER, PRM.PRMQUA, PRM.PRMQUI, PRM.PRMSEX, PRM.PRMSAB, PRM.PRMSEM, PRM.PRMFRE, PRM.PRMHORA, ' Alt - Agenda promotor ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	ElseIf cTpAlt == "EMAIL"
		cQuery += " A1_EMAIL, A1_XEMCSF, A1_EMAICO  ' Alt - E-mail ' AS DESALT, A1_SIMPNAC " //Everson - 21/01/2021 //Everson - 19/01/2021. Chamado TI.
		
	Else
	
		If cTpAlt == "LIBFIN"
			cQuery += " ' Alt - status financeiro ' AS DESALT, "
			
			
		Else
			cQuery += " ' Alt - cadastro ' AS DESALT, "
			
		EndIf

		cQuery += " A1_DTCAD, "
		cQuery += " A1_SIMPNAC, " //Everson - 18/01/2021 //Everson - 19/01/2021. Chamado 
		cQuery += " A1_CODRED, "
		cQuery += " A1_REDE, " 
		cQuery += " A1_SATIV2, ""
		cQuery += " A1_MSBLQL, " 
		cQuery += " A1_NOME AS A1_NOME, " 
		cQuery += " A1_PESSOA, " 
		cQuery += " A1_CGC, " 
		cQuery += " A1_TABELA, " 
		cQuery += " A1_IMPENT, " 
		cQuery += " A1_INSCR, " 
		cQuery += " A1_NREDUZ, " 
		cQuery += " A1_RAZENT, " 
		cQuery += " A1_CGCENT, " 
		cQuery += " A1_INSENT, " 
		cQuery += " A1_CEPE, " 
		cQuery += " A1_ENDENT, " 
		cQuery += " A1_BAIRROE, " 
		cQuery += " A1_CODMUNE, " 
		cQuery += " A1_ESTE, " 
		cQuery += " A1_PAIS, " 
		cQuery += " A1_CEPC, " 
		cQuery += " A1_ENDCOB, " 
		cQuery += " A1_BAIRROC, " 
		cQuery += " A1_MUNC, " 
		cQuery += " A1_ESTC, " 
		cQuery += " A1_PAIS, " 
		cQuery += " YA_DESCR, "
		cQuery += " A1_CEP, " 
		cQuery += " A1_END, " 
		cQuery += " A1_BAIRRO, " 
		cQuery += " A1_COD_MUN, " 
		cQuery += " A1_EST, " 
		cQuery += " A1_PAIS, " 
		cQuery += " A1_MUNE, "
		cQuery += " A1_MUNC, "
		cQuery += " A1_MUN, "
		cQuery += " A1_DDD, " 
		cQuery += " A1_TEL, " 
		cQuery += " A1_EMAIL, " 
		cQuery += " A1_EMAICO, "
		cQuery += " A1_XEMCSF, "
		cQuery += " A1_LC, " 
		cQuery += " A1_COND, " 
		cQuery += " A1_CODPAIS, " 
		cQuery += " A1_CONTRIB, " 
		cQuery += " CASE WHEN A3_XAGRSF = '' OR A3_XAGRSF IS NULL THEN A3_COD ELSE A3_XAGRSF END AS A1_VEND, " 
		cQuery += " A1_XVEND2, " 
		cQuery += " A1_RISCO, " 
		cQuery += " A1_XLONGIT, " 
		cQuery += " A1_XLATITU, " 
		cQuery += " A1_ULTCOM, " 
		cQuery += " A1_XGRPCOM, " 
		cQuery += " A1_NOMEASS, " 
		cQuery += " A1_CODRED, " 
		cQuery += " A1_XPROMOT, " 
		cQuery += " A1_GRPVEN, " 	
		cQuery += " ZCG_XTELLO, "
		cQuery += " ZCG_XTELFI, "
		cQuery += " ZCG_XORILE, "
		cQuery += " ZCG_XCNLOR, "
		cQuery += " ZCG_XSCRRE, "
		cQuery += " ZCG_XSCRRI, "
		cQuery += " ZCG_XRENFA, "
		cQuery += " ZCG_XPOPTO, "
		cQuery += " ZCG_TFUNC, "
		cQuery += " ZCG_PRFORN, "
		cQuery += " ZCG_PRSFOR, "
		cQuery += " ZCG_CORTES, "
		cQuery += " ZCG_TCKMED, "
		cQuery += " ZCG_PERCMP, "
		cQuery += " ZCG_VOLCMP, "
		cQuery += " ZCG_QTDREF, "
		cQuery += " ZCG_JNLREC, "
		cQuery += " ZCG_JNLRE1, "
		cQuery += " ZCG_JNRE1A, "
		cQuery += " ZCG_JNLRE2, "
		cQuery += " ZCG_JNRE2A, "
		cQuery += " ZCG_JNLCMP, "
		cQuery += " ZCG_JNCMP1, "
		cQuery += " ZCG_JNCP1A, "
		cQuery += " ZCG_JNCMP2, "
		cQuery += " ZCG_JNCP2A, "
		cQuery += " ZCG_CLIENT, "
		cQuery += " ZCG_DTCONV, "
		cQuery += " ZCG_PARFIN, "
		cQuery += " ZCG_FACEBO, "
		cQuery += " ZCG_DTVIS, "
		cQuery += " ZCG_RESVIS, "
		cQuery += " ZCG_DETVIS, "
		cQuery += " ZCG_TFUNC, "
		cQuery += " ZCG_CODCLI, "
		cQuery += " ZCG_PERFPG, "
		cQuery += " ZCG_PRCMIN, "
		cQuery += " ZCG_TPCLIE, "
		cQuery += " ZCG_DVISPR, "
		cQuery += " ZCG_FRQPRM, "
		cQuery += " ZCG_SEMVIS, "
		cQuery += " LIG.ZBC_SEG, LIG.ZBC_TER, LIG.ZBC_QUA, LIG.ZBC_QUI, LIG.ZBC_SEX, LIG.ZBC_FREQUE, LIG.ZBC_SEMANA, LIG.ZBC_HORARI, " 
		cQuery += " VEND.VEDSEG, VEND.VEDTER, VEND.VEDQUA, VEND.VEDQUI, VEND.VEDSEX, VEND.VEDFRE, VEND.VEDSEM, VEND.VEDHORA, " 
		cQuery += " PRM.PRMSEG, PRM.PRMTER, PRM.PRMQUA, PRM.PRMQUI, PRM.PRMSEX, PRM.PRMSAB, PRM.PRMSEM, PRM.PRMFRE, PRM.PRMHORA , " 
		cQuery += " ISNULL(CASE WHEN VLRFRT.FRTREG IS NULL THEN VLRFRT.FRTEST ELSE VLRFRT.FRTREG END,0) AS FRETE, " 
		cQuery += " ZBP_VALMIN, A1_XPEDMIN, PB3.*    " //Everson 15/05/2019. Chamado 049064.
	
	EndIf
	
	cQuery += " FROM     " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1    " 
	cQuery += " LEFT OUTER JOIN   " 
	
	cQuery += " ( "
	
		cQuery += " SELECT " 
		cQuery += " ZBC_CODCLI AS ZBC_CODCLI, " 
		cQuery += " ZBC_LOJA   AS ZBC_LOJA, " 
		cQuery += " ZBC_SEG    AS ZBC_SEG, " 
		cQuery += " ZBC_TER    AS ZBC_TER, " 
		cQuery += " ZBC_QUA    AS ZBC_QUA, " 
		cQuery += " ZBC_QUI    AS ZBC_QUI, " 
		cQuery += " ZBC_SEX    AS ZBC_SEX, " 
		cQuery += " ZBC_SEMANA AS ZBC_SEMANA, " 
		cQuery += " ZBC_FREQUE AS ZBC_FREQUE, " 
		cQuery += " ZBC_HORARI AS ZBC_HORARI " 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZBC") + " AS ZBC  " 
		cQuery += " WHERE " 
		cQuery += " ZBC_CODCLI <> '' " 
		cQuery += " AND ZBC_LOJA <> ''  " 
		cQuery += " AND ZBC.D_E_L_E_T_ = '' " 

	
	cQuery += " ) AS LIG   " 
	
	cQuery += " ON A1_COD = LIG.ZBC_CODCLI   " 
	cQuery += " AND A1_LOJA = LIG.ZBC_LOJA   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " ( "
	
		cQuery += " SELECT " 
		cQuery += " ZC6_CODCLI AS ZC6_CODCLI, " 
		cQuery += " ZC6_LOJA   AS ZC6_LOJA,  " 
		cQuery += " ZC6_SEG    AS PRMSEG, " 
		cQuery += " ZC6_TER    AS PRMTER, " 
		cQuery += " ZC6_QUA    AS PRMQUA, " 
		cQuery += " ZC6_QUI    AS PRMQUI, " 
		cQuery += " ZC6_SEX    AS PRMSEX, " 
		cQuery += " ZC6_SAB    AS PRMSAB, " 
		cQuery += " ZC6_SEMANA AS PRMSEM, " 
		cQuery += " ZC6_FREQUE AS PRMFRE, " 
		cQuery += " ZC6_HORARI AS PRMHORA " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZC6") + " AS ZC6 " 
		cQuery += " WHERE " 
		cQuery += " ZC6_FILIAL = '" + xFilial("ZC6") + "' " 
		cQuery += " AND ZC6_CODCLI <> '' " 
		cQuery += " AND ZC6_LOJA <> '' " 
		cQuery += " AND ZC6_TIPO = 'P' "
		cQuery += " AND ZC6.D_E_L_E_T_ = '' " 

	cQuery += " ) AS PRM   " 
	cQuery += " ON A1_COD = PRM.ZC6_CODCLI   " 
	cQuery += " AND A1_LOJA = PRM.ZC6_LOJA   " 
	cQuery += " LEFT OUTER JOIN   " 
	
	cQuery += " (   " 
		cQuery += " SELECT " 
		cQuery += " ZC6_CODCLI AS ZC6_CODCLI, " 
		cQuery += " ZC6_LOJA   AS ZC6_LOJA,  "  
		cQuery += " ZC6_SEG    AS VEDSEG, " 
		cQuery += " ZC6_TER    AS VEDTER, " 
		cQuery += " ZC6_QUA    AS VEDQUA, " 
		cQuery += " ZC6_QUI    AS VEDQUI, " 
		cQuery += " ZC6_SEX    AS VEDSEX, " 
		cQuery += " ZC6_SEMANA AS VEDSEM, " 
		cQuery += " ZC6_FREQUE AS VEDFRE, " 
		cQuery += " ZC6_HORARI AS VEDHORA " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZC6") + " AS ZC6 " 
		cQuery += " WHERE " 
		cQuery += " ZC6_FILIAL = '" + xFilial("ZC6") + "' " 
		cQuery += " AND ZC6_CODCLI <> '' " 
		cQuery += " AND ZC6_LOJA <> '' " 
		cQuery += " AND ZC6_TIPO = 'V' "
		cQuery += " AND ZC6.D_E_L_E_T_ = '' " 
		
	cQuery += " ) AS VEND   " 
	
	cQuery += " ON A1_COD = VEND.ZC6_CODCLI   " 
	cQuery += " AND A1_LOJA = VEND.ZC6_LOJA   " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT  " 
	cQuery += " CC2_EST, CC2_CODMUN, CC2_XREGIA, FRTREG.ZZI_VALOR AS FRTREG, FRTEST.ZZI_VALOR AS FRTEST " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("CC2") + " (NOLOCK) AS CC2  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZZI_REGIAO,ZZI_VALOR FROM " + RetSqlName("ZZI") + " (NOLOCK) AS ZZI WHERE ZZI.D_E_L_E_T_ = '') AS FRTREG " 
	cQuery += " ON CC2_XREGIA = FRTREG.ZZI_REGIAO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZZI_ESTADO, MAX(ZZI_VALOR) AS ZZI_VALOR FROM " + RetSqlName("ZZI") + " (NOLOCK) AS ZZI WHERE ZZI.D_E_L_E_T_ = '' GROUP BY ZZI_ESTADO) AS FRTEST " 
	cQuery += " ON CC2_EST = FRTEST.ZZI_ESTADO " 
	cQuery += " WHERE  " 
	cQuery += " CC2.D_E_L_E_T_ = '') AS VLRFRT " 
	cQuery += " ON A1_EST = VLRFRT.CC2_EST " 
	cQuery += " AND A1_COD_MUN = VLRFRT.CC2_CODMUN " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM "+ RetSqlName("ZBP") +" (NOLOCK) AS ZBP WHERE ZBP.D_E_L_E_T_ = '') AS ZBP " 
	cQuery += " ON A1_SATIV1 = ZBP.ZBP_CODSEG " 
	cQuery += " LEFT OUTER JOIN
	cQuery += " (SELECT * FROM "+ RetSqlName("SE4") +" (NOLOCK) AS SE4 WHERE SE4.D_E_L_E_T_ = '') AS SE4 "
	cQuery += " ON A1_COND = E4_CODIGO "	
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("SYA") +" (NOLOCK) YA ON A1_PAIS=YA_CODGI AND YA.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("ZCG") +" (NOLOCK) ZCG ON A1_FILIAL=ZCG_FILIAL AND  A1_COD=ZCG_SA1COD AND A1_LOJA=ZCG_SA1LOJ AND ZCG.D_E_L_E_T_ = ' ' "	
	cQuery += " LEFT OUTER JOIN "
	cQuery += " ( 
	
	cQuery += " SELECT "
	cQuery += " DISTINCT FONTE1.CODV AS A3_COD, A3_XAGRSF "
	cQuery += " FROM "
	cQuery += " (SELECT DISTINCT A3_COD AS CODV, CASE WHEN A3_XAGRSF = '' OR A3_XAGRSF IS NULL THEN A3_COD ELSE A3_XAGRSF END AS A3_COD, A3_XAGRSF FROM " + RetSqlName("SA3") + " AS SA3 WHERE SA3.D_E_L_E_T_ = '') AS FONTE1 "
	cQuery += " INNER JOIN "
	cQuery += " (SELECT A3_COD, A3_XIDSF FROM " + RetSqlName("SA3") + " AS SA3 WHERE SA3.D_E_L_E_T_ = '' AND A3_XSALES = '2') AS FONTE2 "
	cQuery += " ON FONTE1.A3_COD = FONTE2.A3_COD "
	
	cQuery += " ) AS SA3 ON "
	cQuery += " A1_VEND = A3_COD "
	
	cQuery += " LEFT OUTER JOIN "
	cQuery += " ( SELECT * FROM " + RetSqlName("PB3") + " AS PB3 WHERE PB3.D_E_L_E_T_ = ''  ) AS PB3 ON "
	cQuery += " A1_COD = PB3.PB3_CODSA1 "
	cQuery += " AND A1_LOJA = PB3.PB3_LOJSA1 "
	
	cQuery += " WHERE     " 
	cQuery += " SA1.D_E_L_E_T_ = ''   "  
	cQuery += " AND A1_VEND <> ''    "
	cQuery += " AND (CASE WHEN A3_XAGRSF = '' OR A3_XAGRSF IS NULL THEN A3_COD ELSE A3_XAGRSF END) IS NOT NULL "
	
	//
	If ! Empty(cCodVend)
		cQuery += " AND A1_VEND IN (" + cCodVend + ") "
		
		cQuery += " AND ( A1_XVEND2 = '' OR A1_XVEND2 IN (" + cCodVend + ") ) "

	EndIf

	//
	If ! Empty(cAte)
		cQuery += " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) >= '" + cDe + "' " 
		cQuery += " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) <= '" + cAte + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
		
	EndIf

	cQuery += " ORDER BY MATRIZ DESC, A1_REDE, A3_XAGRSF, A1_COD " 
	
Return cQuery

/*/{Protheus.doc} envItens
	(Envia parecer)
	@type  Function
	@author Everson
	@since 20/03/2018
	@version 01
	@history Chamado 037261
	/*/
Static Function envItens(cCodLj,lAut,cChvTab,aResponse,cMetodo,cAliasS,cGrupoCli)
	
	Local aArea	     := GetArea()	
	Default cGrupoCli:= ""
	
	//Envia parecer.
    If Alltrim(cValToChar((cAliasS)->PARECER)) == "S"
    
		//
		If !Empty(cGrupoCli)
			cGrupoCli := StrTran(cGrupoCli,"*","'")
			U_ADVEN052P("","",.F.,(cAliasS)->DESALT,"B"," AND (RTRIM(LTRIM(PB3_CODSA1)) + RTRIM(LTRIM(PB3_LOJSA1))) IN (" + cGrupoCli + ")  ",aResponse)
		
		EndIf
	
	EndIf

	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} mrkReg
	(Marca registro)
	@type  Function
	@author Everson
	@since 16/03/2018
	@version 01
	@history Chamado 037261
	/*/
Static Function mrkReg(cCodLj,lAut,cId,cMetodo,aResponse,cAliasS)

	Local aArea	     := GetArea()
	
	//
	cId := Alltrim(cValToChar(cId))

	//
	If Empty(cId)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Grava o código do SalesForce.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1") + cCodLj))
		
		//
		If Empty(Alltrim(cValToChar(SA1->A1_XIDSF)))
		
			RecLock("SA1",.F.)
				SA1->A1_XIDSF := Alltrim(cValToChar(cId))
			MsUnlock()
			
		EndIf
		
	EndIf
	SA1->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return Nil
