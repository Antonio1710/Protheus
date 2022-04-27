#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} User Function ADVEN051P
	Função para envio de cadastro de clientes ao SalesForce. 
	@type  Function
	@author Everson
	@since 04/01/2018
	@version 01
	@history 26/11/2019, Everson, Chamado 053617 Adicionadas checagem e mensagem de retorno ao Salesforce, quando o CEP informado 
	no pré-cadastro (Lead) do Salesforce não estiver cadastrado no Protheus.
	@history 27/11/2019, Everson, Chamado T.I. correção da checagem de CEP de entrega.
	@history 27/04/2022, Everson, Chamado T.I. não validar crédio sugerido quando a condição de pagamento for antecipada.
	/*/

User Function ADVEN051P(cParamBsc,lAut) // U_ADVEN051P("15178100")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea   	:= GetArea()

	Default cParamBsc := ""
	Default lAut	  := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de cadastro de clientes ao SalesForce.')

	//
	If Empty(cParamBsc)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If ! lAut
		MsAguarde({|| Processar(cParamBsc,lAut) },"Aguarde","Enviando pré-cadastro(SF)...")

	Else
		Processar(cParamBsc,lAut)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} Static Function Processar
	Processamento dos envios. Chamado 037261. 
	@type  Function
	@author Everson
	@since 04/01/2018
	@version 01
	/*/
Static Function Processar(cParamBsc,lAut)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aParametros	:= {}
	Local aRetOk		:= {}
	//Local i				:= 1
	Local aResponse		:= {}
	Local cMsg			:= ""
	Local lLogin		:= .F.

	Local cFuncao	:= "ADVEN051P"
	Local cAliasTab := "PB3"
	Local cCampo	:= "CHVSF"
	Local cQuery	:= scriptSql(cParamBsc)
	Local cFunJson	:= "montJson"
	Local cMsgFunc	:= "lead"
	Local cServico	:= "/services/data/v41.0/sobjects/Lead/"
	Local cChvExt	:= ""
	Local cMsgParam	:= "Função ADVEN051P"
	Local nIndAlias	:= 14

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//
	Aadd(aParametros,cFuncao)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cQuery)
	Aadd(aParametros,cCampo)
	Aadd(aParametros,cFunJson)
	Aadd(aParametros,cMsgFunc)
	Aadd(aParametros,cServico)
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,cMsgParam)
	Aadd(aParametros,cParamBsc)
	Aadd(aParametros,cAliasTab)
	Aadd(aParametros,nIndAlias)
	Aadd(aParametros,.F.)

	//
	If ! aParametros[2]
		Processa({|| StaticCall(ADVEN075P,Processar,aParametros,@aRetOk,"",aResponse,.F.,"PATCH") },"Aguarde","Processando registro(s) ...",.T.)

	Else
		StaticCall(ADVEN075P,Processar,aParametros,@aRetOk,"",aResponse,.F.,"PATCH")

	EndIf

Return Nil
/*/{Protheus.doc} Static Function montJson
	Monta json. Chamado 037261.  
	@type  Function
	@author Everson
	@since 04/01/2018
	@version 01
	/*/
Static Function montJson(cParamBsc,nOPc,cAliasTab,nIndAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	 := GetArea()
	Local cJson	 := ""

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	DbSelectArea(cAliasTab)
	(cAliasTab)->(DbSetOrder(nIndAlias))
	(cAliasTab)->(DbGoTop())
	If (cAliasTab)->(DbSeek(xFilial(cAliasTab) + cParamBsc))

		cJson += '{'
		/*	
		cJson += '"Name":"' + Alltrim(cValToChar((cAliasTab)->PB3_NOME)) + '",'
		cJson += '"Nome_Fantasia__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_NREDUZ)) + '",'
		cJson += '"Tipo_de_Pessoa__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_PESSOA)) + '",'
		cJson += '"CNPJ_CPF__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_CGC)) + '",'
		cJson += '"Inscricao_Estadual__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_INSCR)) + '",'
		cJson += '"Status":"' + Alltrim(cValToChar((cAliasTab)->PB3_SITUAC)) + '",'
		//cJson += '"Motivo_de_Bloqueio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"LeadSource":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"OwnerID":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Website":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Email":"' + Alltrim(cValToChar((cAliasTab)->PB3_EMAIL)) + '",'
		cJson += '"Telefone_principal__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_TEL)) + '",'
		cJson += '"Grupo_Vendas__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_GRPVEN)) + '",'
		cJson += '"Credito_Sugerido__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_CREDSU)) + '",'
		cJson += '"Categoria__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_SUBSEG)) + '",'
		cJson += '"Contribuinte__c":"' + Alltrim(cValToChar((cAliasTab)->PB3_CONTRI)) + '",'
		//cJson += '"Numero_de_Filiais__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Principal_Fornecedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Principais_Fornecedores__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Quantidade_de_Refeicoes__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janelas_de_Compras__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Compras_1_De__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Compras_1_Ate__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Periodicidade_de_Compras__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Ticket_Medio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		//cJson += '"Cortes__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Volume_de_Compras_Kg__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Compras_2_De__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Compras_2_Ate__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janelas_de_Recebimento__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Recebimento_1_De__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_de_Recebimento_1_Ate__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_2_De__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Janela_2_Ate__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CEP__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Numero__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Bairro__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Codigo_Municipio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Municipio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Endereco__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Estado__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Codigo_Pais__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Pais__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Razao_Social_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CEP_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CNPJ_CPF_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Numero_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Bairro_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Codigo_Municipio_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Municipio_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Inscricao_Estadual_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Endereco_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Estado_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Imprime_Endereco_Entrega__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CEP_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Numero_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Bairro_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Codigo_Municipio_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Municipio_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Email_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Endereco_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Estado__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Telefone_Cobranca__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Frequencia_Visita_Vendedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Dias_da_Semana_Visita_Vendedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Semana_Visita_Vendedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Horario_Visita_Vendedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Frequencia_Visita_Promotor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Dias_da_Semana_Visita_Promotor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Semana_Visita_Promotor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Horario_Ligacao_Vendedor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Score_de_Rentabilidade__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Score_de_Risco__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Densidade_Populacional__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Km__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Renda_Media_Familiar_Atual__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_A__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_B__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_AB__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_C__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_D__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Domicilios_Classe_E__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Grau_de_Verticalizacao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Grau_de_Comercializacao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Total_de_Trabalhadores_Diurnos_Atuais__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Renda_Media_dos_Trabalhadores__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Massa_Salarial_Trabalhadores_da_Regiao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Indice_de_Potencial_de_Consumo_Domicilio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Indice_Potencial_Consumo_com_Alimentacao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Total_Despesas_com_Carnes_peixes_aves__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Ticket_Medio_com_Carnes_Aves_Peixes__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Total_de_Empresas__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Total_de_Empresas_do_Comercio__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Total_de_Empresas_de_Servico__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Telefone_Logistica__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Email_comercial__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Pais_Bacen__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Canal_Origem_Lead__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Clientes__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Data_de_solicitacao_da_conversao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Parecer_financeiro__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Facebook__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Data_da_ultima_visita__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Resultado_da_ultima_visita__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Detalhe_do_resultado_da_ltima_visita__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Quantidade_de_funcionarios__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Cod_Cliente__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Cod_Grupo__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_Associacao__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Rede__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Condicao_de_Pagamento_Solicitada__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Latitude__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Longitude__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Performace_de_pagamento__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Preco_Pedido_Minimo_Cliente__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Promotor__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Cliente__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Valor_Frete__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Vendedor_1__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Vendedor_2__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_1__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_2__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_3__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_4__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_5__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_6__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_7__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_8__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_9__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Complemento_Socio_10__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_1__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_2__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_3__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_4__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_5__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_6__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_7__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_8__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_9__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"CPF_CNPJ_Socio_10__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_1__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_2__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_3__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_4__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_5__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_6__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_7__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_8__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_9__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Nome_do_Socio_10__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_1__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_2__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_3__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_4__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_5__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_6__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_7__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_8__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_9__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '",'
		cJson += '"Tipo_de_Socio_10__c":"' + Alltrim(cValToChar((cAliasTab)->)) + '"'
		*/
		cJson += '}

	EndIf

	//
	(cAliasTab)->(DbCloseArea())	

	//
	RestArea(aArea)

Return cJson
/*/{Protheus.doc} Static Function scriptSql
	Script sql para consulta. Chamado 037261. 
	@type  Function
	@author Everson
	@since 04/01/2018
	@version 01
	/*/
Static Function scriptSql(cParamBsc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cQuery := ""	

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	cQuery := ""
	cQuery += " SELECT PB3_XSALES AS CHVSF, PB3_XSALES " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS PB3 " 
	cQuery += " WHERE " 
	cQuery += " PB3.D_E_L_E_T_ = '' "
	cQuery += " AND PB3_XSALES <> '' "

	//
	If ! Empty(cParamBsc)
		cQuery += " AND RTRIM(LTRIM(PB3_COD)) + RTRIM(LTRIM(PB3_LOJA)) = '" + cParamBsc + "' " 

	EndIf

	cQuery += " ORDER BY PB3_XSALES " 

Return cQuery
/*/{Protheus.doc} precadastros
	Serviço Rest para manipulação de pré-cadastros. Chamado 037261.
	@type  Function
	@author Everson
	@since 18/09/2017
	@version 01
	/*/
WsRestFul precadastros Description "Serviço REST para manipulação de pré-cadastros."

	WsMethod Post Description "Inclusão de pré-cadastro de clientes."  WsSyntax "/precadastros"
	WsMethod Put  Description "Alteração de pré-cadastro de clientes." WsSyntax "/precadastros"

End WsRestFul
/*/{Protheus.doc} POST
	Métod POST. Chamado 037261.
	@type  Function
	@author Everson
	@since 18/09/2017
	@version 01
	/*/
WsMethod Post WsService precadastros

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	Local cPath			:= Alltrim(cValToChar(GetMv("MV_#URLRES"))) + Self:GetPath()
	//Local cNumPed		:= ""
	Local oParseJSON
	Local cJsonResp		:= ""
	Local nNivelCred	:= 0
	Local cNumChkPre	:= ""
	Local cNumChkLoj	:= ""
	Local cUrlServ		:= Self:GetPath()
	Local cIdSFBkp		:= ""

	//Variáveis privadas para chamada da rotina GravaCli.
	Private INCLUI		:= .T.
	Private ALTERA		:= .F.
	Private aRestErro	:= {}
	Private cPreCad		:= ""
	Private cMsg		:= ""
	Private nOpc		:= 3
	Private cRestParecer:= ""
	Private cHoraExec	:= Time()
	
	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)
		
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,"","",cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"POST")
	
		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	cIdSFBkp := FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_XSALES)))
	
	//
	If Empty(cCodUsuario)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"POST")
		
		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cPreCad,cBody,"",cUrlServ,"POST")

	//Atribui usuário.
	__cUserId := cCodUsuario
	
	//
	Self:SetContentType(cFormatAceito)

	//
	nNivelCred := Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )

	//
	If cFormato <> cFormatAceito
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf cContentType <> cFormatAceito
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cBody)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Json não encontrado no corpo da requisição."))
		RestArea(aArea)
		Return .F.

	EndIf

	//Valida se o número sequencial informado já foi utilizado.
	cNumChkPre := Alltrim(cValToChar(Posicione("PB3",14,xFilial("PB3") + cIdSFBkp, "PB3_COD")))

	If ! Empty(cNumChkPre)

		cNumChkLoj := Alltrim(cValToChar(Posicione("PB3",14,xFilial("PB3") + cIdSFBkp, "PB3_LOJA")))

		cJsonResp := '{"msg":"Sequencial ' + Alltrim(cValToChar(oParseJSON:PB3_XSALES)) + ' já utilizado.","PB3_COD":"' + cNumChkPre + '","PB3_LOJA":"' + cNumChkLoj + '"}'

		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cJsonResp,cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8(cJsonResp))

		FreeObj(oParseJSON)
		oParseJSON := Nil
		RestArea(aArea)
		Return .F.

	EndIf

	//
	If ! CGC(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))),Nil,.F.)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,"CNPJ/CPF inválido " + Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))) + ".",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("CNPJ/CPF inválido " + Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))) + "."))
		RestArea(aArea)
		Return .F.

	EndIf

	//
	/*	DbSelectArea("PB3")
	PB3->(DbSetOrder(3))
	PB3->(DbGoTop())
	If PB3->(DbSeek(xFilial("PB3") + Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))) ))

	SetRestFault(400,EncodeUtf8("CNPJ/CPF já cadastrado " + Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))) + "."))
	FreeObj(oParseJSON)
	oParseJSON := Nil
	PB3->(DbCloseArea())
	RestArea(aArea)
	Return .F.

	EndIf*/

	//
	DbSelectArea('PB1')
	PB1->( DbSetOrder( 1 ) )
	If PB1->( DbSeek( xFilial( 'PB1' ) + __cUserId ))

		If Val( PB1->PB1_NIVEL ) >= nNivelCred
			cMsg := 'As Rotinas de Pré-Cliente não estão liberadas para seu Nivel.'

			//
			StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cMsg,cUrlServ,"POST")

			u_FSGrvLog( cMsg + CRLF )
			u_FSClsLog()

			SetRestFault(403,EncodeUtf8(cMsg))
			FreeObj(oParseJSON)
			oParseJSON := Nil
			PB1->(DbCloseArea())
			RestArea(aArea)
			Return .F.

		Endif
	Else
		cMsg := 'Você não está autorizado a utilizar essa rotina. Solicite permissão ao seu superior.'
		
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cMsg,cUrlServ,"POST")
		
		u_FSGrvLog( cMsg + CRLF)
		u_FSClsLog()

		SetRestFault(403,EncodeUtf8(cMsg))
		FreeObj(oParseJSON)
		oParseJSON := Nil
		PB1->(DbCloseArea())
		RestArea(aArea)
		Return .F.

	EndIf

	//Carrega campos da tabela PB3 em memória.
	RegToMemory('PB3', .T. )

	//
	//RegToMemory('ZCG',.T.)

	//Atribui valores as variáveis de memória.
	cMsg := ""
	If ! atribVlr(@oParseJSON,@cMsg)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cMsg,cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8(cMsg))
		FreeObj(oParseJSON)
		oParseJSON := Nil
		RestArea(aArea)
		Return .F.	

	EndIf

	//Valida os campos preenchidos.
	U_ValInf1()
	If Len(aRestErro) > 0
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cValToChar(aRestErro[1][2]),cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8(aRestErro[1][2]))
		FreeObj(oParseJSON)
		oParseJSON := Nil
		RestArea(aArea)
		Return .F.

	EndIf

	//Gera log inicial.
	grLogIni()

	//Executa a rotina para salvar o pré-cadastro.
	Begin Transaction

		StaticCall(ADOA002,GravaCli)
		DbSelectArea("PB3")
		cPreCad := Alltrim(cValToChar(PB3->PB3_COD )) + Alltrim(cValToChar(PB3->PB3_LOJA))

		//Valida se houve erro na inclusão do pré-cadastro.
		If Len(aRestErro) > 0

			DisarmTransaction()

			//
			StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,"",cBody,cValToChar(aRestErro[1][2]),cUrlServ,"POST")
		
		
			SetRestFault(400,EncodeUtf8(aRestErro[1][2]))
			FreeObj(oParseJSON)
			oParseJSON := Nil
			RestArea(aArea)
			Return .F.

		EndIf

		//Processa solicitação.
		process(oParseJSON)

		//Processa agendamentos.
		//processAgnd(cPreCad)
		
		//Complemento de cadastro.
		//svlZGC(cPreCad)

	End Transaction 

	//
	cJsonResp := '{"PB3_COD":"' + Substr(cPreCad,1,6) + '","PB3_LOJA":"' + Substr(cPreCad,7,2) + '"}'
	Self:SetHeader("location",cValToChar(cPath) + "/" + cPreCad)
	
	//
	cHoraExec := ELAPTIME(cHoraExec, Time())
	StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cPreCad,cBody,"",cUrlServ,"POST",cHoraExec)	
		
	Self:SetResponse(cJsonResp)

	//
	If Select("PB3") > 0
		PB3->(DbCloseArea())

	EndIf

	//
	FreeObj(oParseJSON)
	oParseJSON := Nil

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} PUT
	Métod PUT. Chamado 037261.
	@type  Function
	@author Everson
	@since 18/09/2017
	@version 01
	/*/
WsMethod Put WsService precadastros

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	//Local cPath			:= Alltrim(cValToChar(GetMv("MV_#URLRES"))) + Self:GetPath()
	//Local cNumPed		:= ""
	Local oParseJSON
	//Local cJsonResp		:= ""
	Local cErro			:= ""
	Local nErro			:= 400
	Local cMotivo		:= ""
	//Local cCodPB3		:= ""
	//Local cLojaPB3		:= ""
	Local nNivelCred
	Local aParametros	:= Self:aURLParms
	Local cCodLoja		:= ""
	Local cUrlServ		:= Self:GetPath()
	Local cIdSFBkp		:= ""

	//Variáveis privadas para chamada da rotina GravaCli.
	Private INCLUI		:= .F.
	Private ALTERA		:= .T.
	Private aRestErro	:= {}
	Private cPreCad		:= ""
	Private cMsg		:= ""
	Private nOpc		:= 4 
	Private cRestParecer:= ""
	Private cHoraExec	:= Time()
	
	
	//
	If Len(aParametros) == 0
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,"","",cBody,"Obrigatório informar o código e loja do pré-cadastro.",cUrlServ,"PUT")
		
		SetRestFault(400,EncodeUtf8("Obrigatório informar o código e loja do pré-cadastro."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//Obtém o número do pedido de venda.
	cCodLoja := Alltrim(cValToChar(aParametros[1]))
		
	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"PUT")
		
		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	cIdSFBkp := FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_XSALES)))

	//
	StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"",cUrlServ,"PUT")
	
	//
	If Empty(cCodUsuario)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"PUT")
		
		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))
		RestArea(aArea)
		Return .F.

	EndIf

	//
	Self:SetContentType(cFormatAceito)

	//Atribui usuário.
	__cUserId := cCodUsuario

	//
	nNivelCred  	:= Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )

	//
	If cFormato <> cFormatAceito

		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"PUT")
	
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf cContentType <> cFormatAceito

		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"PUT")

		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cBody)

		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"PUT")

		SetRestFault(400,EncodeUtf8("Json não encontrado no corpo da requisição."))
		RestArea(aArea)
		Return .F.

	EndIf

	//
	DbSelectArea('PB1')
	PB1->( DbSetOrder( 1 ) )
	If PB1->( DbSeek( xFilial( 'PB1' ) + __cUserId ))

		If Val( PB1->PB1_NIVEL ) >= nNivelCred
			cMsg := 'As Rotinas de Pré-Cliente não estão liberadas para seu Nivel.'
			
			//
			StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,cMsg,cUrlServ,"PUT")

			u_FSGrvLog( cMsg + CRLF )
			u_FSClsLog()

			SetRestFault(403,EncodeUtf8(cMsg))
			FreeObj(oParseJSON)
			oParseJSON := Nil
			PB1->(DbCloseArea())
			RestArea(aArea)
			Return .F.

		Endif

	Else
		cMsg := 'Você não está autorizado a utilizar essa rotina. Solicite permissão ao seu superior.'

		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,cMsg,cUrlServ,"PUT")

		u_FSGrvLog( cMsg + CRLF)
		u_FSClsLog()

		SetRestFault(403,EncodeUtf8(cMsg))
		FreeObj(oParseJSON)
		oParseJSON := Nil
		PB1->(DbCloseArea())
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cMotivo	:= Upper(Alltrim(cValToChar(oParseJSON:PB3_MOTACE)))

	//Localiza pré-cadastro.
	DbSelectArea("PB3")
	PB3->(DbSetOrder(1))
	If ! PB3->(DbSeek( xFilial("PB3") + Alltrim(cValToChar(cCodLoja)) ))
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"Pré-cadastro " + Alltrim(cValToChar(cCodLoja)) + " não encontrado.",cUrlServ,"PUT")
	
		SetRestFault(404,EncodeUtf8("Pré-cadastro " + Alltrim(cValToChar(cCodLoja)) + " não encontrado."))
		FreeObj(oParseJSON)
		oParseJSON := Nil		
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cPreCad := Alltrim(cValToChar(PB3->PB3_COD)) + Alltrim(cValToChar(PB3->PB3_LOJA))

	//Opções de alteração.
	If ! processAlt(cMotivo,@cErro,@nErro,oParseJSON)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,cErro,cUrlServ,"PUT")
	
		SetRestFault(nErro,EncodeUtf8(cErro))
		FreeObj(oParseJSON)
		oParseJSON := Nil		
		RestArea(aArea)
		Return .F.

	Else
		
		//Processa agendamentos.
		//processAgnd(cPreCad)
		
		//Complemento de cadastro.
		//svlZGC(cPreCad)
		//
		//
		cHoraExec := ELAPTIME(cHoraExec, Time())
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cCodLoja,cBody,"",cUrlServ,"PUT",cHoraExec)
	
		Self:SetResponse('')

	EndIf

	//
	If Select("PB3") > 0
		PB3->(DbCloseArea())

	EndIf

	//
	FreeObj(oParseJSON)
	oParseJSON := Nil	

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} processAlt
	Reativação de cliente. Chamado 037261.
	@type  Function
	@author Everson
	@since 10/10/2017
	@version 01
	/*/
Static Function processAlt(cMotivo,cErro,nErro,oParseJSON)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

	//Verifica se o registro está bloqueado.
	If cMotivo == "01 - NOVO CADASTRO"
		cErro := "Para novo cadastro utilizar o método POST."
		nErro := 403
		RestArea(aArea)
		Return .F.

	EndIf

	/*	//Verifica se o registro está bloqueado.
	If cMotivo == "02 - REATIVACAO" .And. Alltrim(cValtoChar(PB3->PB3_BLOQUE)) <> "1"
	cErro := "O registro " + Alltrim(cValToChar(oParseJSON:PB3_CGC)) + " não está bloqueado, a reativação não se aplica."
	nErro := 403
	RestArea(aArea)
	Return .F.

	EndIf

	//Verifica se o registro está bloqueado.
	If cMotivo <> "02 - REATIVACAO" .And. Alltrim(cValtoChar(PB3->PB3_BLOQUE)) == "1"
	cErro := "O registro " + Alltrim(cValToChar(oParseJSON:PB3_CGC)) + " está bloqueado, necessário reativá-lo."
	nErro := 403
	RestArea(aArea)
	Return .F.

	EndIf*/

	//Carrega campos da tabela PB3 em memória.
	RegToMemory('PB3', .F. )

	//
	//RegToMemory('ZCG',.F.)

	//Atribui valores as variáveis de memória.
	atribVlr(@oParseJSON)

	//Valida os campos preenchidos.
	U_ValInf1()
	If Len(aRestErro) > 0
		cErro := aRestErro[1][2]
		nErro := 400
		RestArea(aArea)
		Return .F.

	EndIf

	//Gera log inicial.
	grLogIni()

	//Executa a rotina para salvar o pré-cadastro.
	StaticCall(ADOA002,GravaCli)

	//Valida se houve erro na inclusão do pré-cadastro.
	If Len(aRestErro) > 0
		cErro := aRestErro[1][2]
		nErro := 400
		RestArea(aArea)
		Return .F.

	EndIf

	//Processa solicitação.
	process(oParseJSON)

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} atribVlr
	Atribui valores a variáveis. Chamado 037261.  
	@type  Function
	@author Everson
	@since 10/10/2017
	@version 01
	/*/
Static Function atribVlr(oParseJSON,cMsg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local lErrCmp	:= .F.
	Local xPula		:= Chr(13) + Chr(10)

	//Endereço do cliente.
	Local cCepCli 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEP))))
	Local cEndCli	:= ""
	Local cCodMuCli	:= ""
	Local cEstCli	:= ""
	Local cMunCli	:= ""
	Local cBarCli	:= ""

	//Endereço de cobrança.
	Local cCepCliC 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPCOB))))
	Local cEndCliC	:= ""
	Local cCodMuCliC:= ""
	Local cEstCliC	:= ""
	Local cMunCliC	:= ""
	Local cBarCliC	:= ""

	//Endereço de entrega.
	Local cCepCliE 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPENT))))
	Local cEndCliE	:= ""
	Local cCodMuCliE:= ""
	Local cEstCliE	:= ""
	Local cMunCliE	:= ""
	Local cBarCliE	:= ""
	Local cChkCFP1	:= "" //Everson - 26/11/2019. Chamado 053617.
	Local cChkCFP2	:= "" //Everson - 26/11/2019. Chamado 053617.
	Local cChkCFP3	:= "" //Everson - 26/11/2019. Chamado 053617.

	//Everson - 27/04/2022. Chamado TI.
	Local cCondP	:= ""
	Local lCondAnt	:= .F.
	//
	
	//Valida CEP do endereço.
	If Empty(cCepCli)
		cMsg += "CEP do endereço do cliente não localizado." + xPula
		lErrCmp := .T.

	EndIf
	
	//
	cChkCFP1  := Alltrim(Posicione("JC2",1,xFilial("JC2") + cCepCli ,"JC2_CEP")) //Everson - 26/11/2019. Chamado 053617.
	cChkCFP2  := Alltrim(Posicione("JC2",1,xFilial("JC2") + cCepCliC,"JC2_CEP")) //Everson - 26/11/2019. Chamado 053617.
	cChkCFP3  := Alltrim(Posicione("JC2",1,xFilial("JC2") + cCepCliE,"JC2_CEP")) //Everson - 26/11/2019. Chamado 053617. Everson - 27/11/2019. Chamado T.I.

	cEndCli	  := Posicione("JC2",1,xFilial("JC2") + cCepCli,"JC2_LOGRAD")
	cCodMuCli := Posicione("JC2",1,xFilial("JC2") + cCepCli,"JC2_CODCID")
	cEstCli	  := Posicione("JC2",1,xFilial("JC2") + cCepCli,"JC2_ESTADO")
	cMunCli	  := Posicione("CC2",1,xFilial("CC2") + cEstCli + cCodMuCli ,"CC2_MUN" )
	cBarCli	  := Posicione("JC2",1,xFilial("JC2") + cCepCli,"JC2_BAIRRO")

	//Everson - 26/11/2019. Chamado 053617.
	If Empty(cChkCFP1) 
		cMsg += "CEP " + cValToChar(cChkCFP1) + " não localizado na base do sistema Protheus (contate o departamento financeiro)." + xPula
		lErrCmp := .T.

	EndIf
			
	If ! Empty(cCepCli) .And. ( (Empty(cEndCli) .Or. Empty(cBarCli)) ) //Everson - 27/11/2019. Chamado T.I.
		
		If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_END))))) .Or. Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIRRO)))))
			cMsg += "Necessário informar o logradouro e bairro do cliente (contate o departamento financeiro)." + xPula
			lErrCmp := .T.
						
		Else
			cEndCli	  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_END))))
			cBarCli	  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIRRO))))
		
		EndIf
	
	Endif	
	//
	
	//Valida CEP de cobrança.
	If Empty(cCepCliC)
		cMsg += "CEP de cobrança do cliente não localizado." + xPula
		lErrCmp := .T.	

	EndIf

	//Everson - 26/11/2019. Chamado 053617.
	If Empty(cChkCFP2) 
		cMsg += "CEP (cobrança) " + cValToChar(cChkCFP2) + " não localizado na base do sistema Protheus (contate o departamento financeiro)." + xPula
		lErrCmp := .T.

	EndIf

	cEndCliC	:= Posicione("JC2",1,xFilial("JC2") + cCepCliC,"JC2_LOGRAD")
	cCodMuCliC  := Posicione("JC2",1,xFilial("JC2") + cCepCliC,"JC2_CODCID")
	cEstCliC	:= Posicione("JC2",1,xFilial("JC2") + cCepCliC,"JC2_ESTADO")
	cMunCliC	:= Posicione("CC2",1,xFilial("CC2") + cEstCliC + cCodMuCliC ,"CC2_MUN" )
	cBarCliC	:= Posicione("JC2",1,xFilial("JC2") + cCepCliC,"JC2_BAIRRO")
			
	If ! Empty(cCepCliC) .And. ( (Empty(cEndCliC) .Or. Empty(cBarCliC)) ) //Everson - 27/11/2019. Chamado T.I.
		
		If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_ENDCOB))))) .Or. Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIRCB)))))
			cMsg += "Necessário informar o logradouro e bairro de cobrança." + xPula
			lErrCmp := .T.
						
		Else
			cEndCliC := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_ENDCOB))))
			cBarCliC := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIRCB))))
		
		EndIf
	
	Endif	
	//

	//Valida CEP de entrega.
	If Empty(cCepCliE)
		cMsg += "CEP de entrega do cliente não localizado." + xPula
		lErrCmp := .T.

	EndIf

	//Everson - 26/11/2019. Chamado 053617.
	If Empty(cChkCFP3) 
		cMsg += "CEP (entrega) " + cValToChar(cChkCFP3) + " não localizado na base do sistema Protheus (contate o departamento financeiro)." + xPula
		lErrCmp := .T.

	EndIf

	//
	cEndCliE	:= Posicione("JC2",1,xFilial("JC2") + cCepCliE,"JC2_LOGRAD")
	cCodMuCliE  := Posicione("JC2",1,xFilial("JC2") + cCepCliE,"JC2_CODCID")
	cEstCliE	:= Posicione("JC2",1,xFilial("JC2") + cCepCliE,"JC2_ESTADO")
	cMunCliE	:= Posicione("CC2",1,xFilial("CC2") + cEstCliE + cCodMuCliE ,"CC2_MUN" )
	cBarCliE	:= Posicione("JC2",1,xFilial("JC2") + cCepCliE,"JC2_BAIRRO")
			
	If ! Empty(cCepCliE) .And. ( (Empty(cEndCliE) .Or. Empty(cBarCliE)) ) //Everson - 27/11/2019. Chamado T.I.
		
		If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_ENDENT))))) .Or. Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIREN)))))
			cMsg += "Necessário informar o logradouro e bairro de entrega (contate o departamento financeiro)." + xPula
			lErrCmp := .T.
						
		Else
			cEndCliE := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_ENDENT))))
			cBarCliE := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_BAIREN))))
		
		EndIf
	
	Endif
	//

	//Validação de campos obrigatórios.
	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_MOTACE)))))
		cMsg += "Operação a ser realizada não informada." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEP)))))
		cMsg += "CEP do endereço do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPCOB)))))
		cMsg += "CEP do endereço de cobrança do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPENT)))))
		cMsg += "CEP do endereço de entrega do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC)))))
		cMsg += "CNPJ/CPF do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA)))))
		cMsg += "Tipo de pessoa do cliente (Jurídica/Física) não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NOME)))))
		cMsg += "Nome do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NREDUZ)))))
		cMsg += "Nome reduzido do cliente não informado." + xPula
		lErrCmp := .T.

	Endif

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CONTAT)))))
		cMsg += "Nome do contato não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMAIL)))))
		cMsg += "E-mail do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf							

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMCSF)))))
		cMsg += "E-mail comercial do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMAICO)))))
		cMsg += "E-mail de cobrança não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGCSOC)))))
		cMsg += "CNPJ/CPF do sócio 1 não informado." + xPula
		lErrCmp := .T.

	Endif

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESS1)))))
		cMsg += "Tipo de pessoa do sócio 1 não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NOMSO1)))))
		cMsg += "Nome do sócio 1 não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Val(cValToChar(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_COMSC1))))) <= 0
		cMsg += "Participação do sócio 1 na empresa não informada." + xPula
		lErrCmp := .T.

	EndIf

	cCondP := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CONDSO)))) //Everson - 27/04/2022. Chamado TI.

	If Empty(cCondP) //Everson - 27/04/2022. Chamado TI.
		cMsg += "Condição de pagamento solicitada não informada." + xPula
		lErrCmp := .T.

	EndIf

	lCondAnt := Alltrim(cValToChar(Posicione("SE4", 1, FwxFilial("SE4") + cCondP, "E4_CTRADT"))) == "1" //Everson - 27/04/2022. Chamado TI.

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_GRPVEN)))))
		cMsg += "Grupo de vendas não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_SUBSEG)))))
		cMsg += "Subsegmento não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Val(cValToChar(cValToChar(oParseJSON:PB3_CREDSU))) <= 0 .And. ! lCondAnt //Everson - 27/04/2022. Chamado TI.
		cMsg += "Crédito sugerido não informado." + xPula
		lErrCmp := .T.
	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMERO)))))
		cMsg += "Número do endereço do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMCOB)))))
		cMsg += "Número do endereço de cobrança do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMENT)))))
		cMsg += "Número do endereço de entrega do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TEL)))))
		cMsg += "Telefone do cliente não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NOMEEN)))))
		cMsg += "Nome do endereço de entrega não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CPFENT)))))
		cMsg += "CNPJ/CPF do endereço de entrega não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_INSCEN)))))
		cMsg += "Inscrição estadual do endereço de entrega não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_IMPEND)))))
		cMsg += "Não foi informado se o endereço de entrega será impresso ou não." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TEL5)))))
		cMsg += "Telefone de cobrança não informado." + xPula
		lErrCmp := .T.

	EndIf

	If Empty(Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CONTRI)))))
		cMsg += "Não informado se o cliente é contribuinte ou não." + xPula
		lErrCmp := .T.

	EndIf

	//Valida se há erro no preenchimento de campos obrigatórios.
	If lErrCmp == .T.
		RestArea(aArea)
		Return .F.

	EndIf

	//
	M->PB3_VEND		:= __cUserId
	M->PB3_MOTACE   := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_MOTACE))))
	M->PB3_XSALES   := FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_XSALES)))
	M->PB3_XCASO    := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_XCASO))))
	M->PB3_PESSOA	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA))))

	M->PB3_CGC		:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGC))))
	M->PB3_INSCR	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_INSCR))))
	M->PB3_NOME 	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_NOME)))))
	M->PB3_NREDUZ 	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_NREDUZ)))))

	//Endereço do cliente.
	M->PB3_CEP	 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEP))))
	M->PB3_END	 	:= cEndCli
	M->PB3_EST	 	:= cEstCli
	M->PB3_COD_MU 	:= cCodMuCli
	M->PB3_MUN		:= cMunCli
	M->PB3_NUMERO 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMERO))))
	M->PB3_COMPLE 	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_COMPLE)))))
	M->PB3_BAIRRO 	:= cBarCli

	M->PB3_TEL	 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TEL))))
	M->PB3_FAX	 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_FAX))))
	M->PB3_PAIS		:= "105"//Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PAIS))))
	M->PB3_CONTAT 	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_CONTAT)))))
	M->PB3_CXPOST 	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CXPOST))))
	M->PB3_RG 		:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_RG))))
	M->PB3_EMAIL	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMAIL))))
	M->PB3_EMCSF	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMCSF))))
	M->PB3_CEL 		:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEL))))
	//M->PB3_CODRD2	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CODRD2))))

	//Dados de cobrança.
	M->PB3_CEPCOB	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPCOB))))
	M->PB3_ENDCOB	:= cEndCliC
	M->PB3_NUMCOB	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMCOB))))
	M->PB3_BAIRCB	:= cBarCliC
	M->PB3_COMPCO	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_COMPCO)))))
	M->PB3_CODMUC	:= cCodMuCliC
	M->PB3_CIDACO	:= cMunCliC
	M->PB3_UFCOB	:= cEstCliC
	M->PB3_TEL5		:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TEL5))))
	M->PB3_EMAICO	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_EMAICO))))

	//Dados de entrega.
	M->PB3_NOMEEN	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_NOMEEN)))))
	M->PB3_CPFENT	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CPFENT))))
	M->PB3_CEPENT	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CEPENT))))
	M->PB3_ENDENT	:= cEndCliE
	M->PB3_NUMENT	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_NUMENT))))
	M->PB3_COMPEN	:= Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_COMPEN)))))
	M->PB3_BAIREN	:= cBarCliE
	M->PB3_CODMUE	:= cCodMuCliE
	M->PB3_CIDENT	:= cMunCliE
	M->PB3_UFENT	:= cEstCliE


	M->PB3_REGESP	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_REGESP))))
	M->PB3_IMPEND	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_IMPEND))))
	M->PB3_INSCEN	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_INSCEN))))

	//Potencial de compra.
	M->PB3_GRPVEN	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_GRPVEN))))
	M->PB3_SUBSEG	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_SUBSEG))))
	M->PB3_SEGTO	:= Substr(M->PB3_SUBSEG,1,1)+'0'
	M->PB3_CREDSU	:= Val(cValToChar(oParseJSON:PB3_CREDSU))
	M->PB3_CONDSO	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CONDSO))))
	M->PB3_DCONSO	:= Posicione("SE4",1,xFilial("SE4") + Alltrim(cValToChar(oParseJSON:PB3_CONDSO)) ,"E4_DESCRI" )
	M->PB3_PRAZOS	:= Posicione("SE4",1,xFilial("SE4") + Alltrim(cValToChar(oParseJSON:PB3_CONDSO)) ,"E4_DMEDI" )

	If Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA)))) == "F"
		M->PB3_TIPO := "F"

	EndIf

	If Alltrim(M->PB3_SEGTO) == "50" .And. Alltrim(M->PB3_SUBSEG) == "51" .and. Substr(M->PB3_INSCR,1,5) <> 'ISENT' .And. Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA)))) <> "F"
		M->PB3_TIPO := "R"

	EndIf

	If Alltrim(M->PB3_SEGTO) == "50" .And. (Alltrim(M->PB3_SUBSEG) $ "52/53") .And. Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA)))) == "F"
		M->PB3_TIPO := "F"

	EndIf

	If Alltrim(M->PB3_SEGTO) == "50" .And. (Alltrim(M->PB3_SUBSEG) $ "52/53") .And. Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESSOA)))) <> "F"	
		M->PB3_TIPO := "R"

	EndIf

	CONOUT("PB3_TIPO>>>>>>>>>> " + cValToChar(M->PB3_TIPO) )
	If M->PB3_TIPO == "F"
		M->PB3_GRPTRIB := "005"

	EndIf
	CONOUT("PB3_GRPTRIB>>>>>>>>>> " + cValToChar(M->PB3_GRPTRIB) )

	//Crédito.
	M->PB3_CONTRI	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CONTRI))))

	//Sócios.
	M->PB3_PESSOC  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESS1))))
	M->PB3_PESS1   := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PESS1))))
	M->PB3_NOMSO1  := Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:PB3_NOMSO1)))))
	M->PB3_CGCSOC  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_CGCSOC))))
	M->PB3_COMSC1  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_COMSC1))))
	
	/*
	//Agenda de ligações.
	M->PB3_LIGFRQ	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_LIGFRQ))))
	M->PB3_LIGSEM	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_LIGSEM))))
	M->PB3_TELSEG	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TELSEG))))
	M->PB3_TELTER	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TELTER))))
	M->PB3_TELQUA	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TELQUA))))
	M->PB3_TELQUI	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TELQUI))))
	M->PB3_TELSEX	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_TELSEX))))
	
	//Agenda visita vendedor.
	M->PB3_VEDFRQ	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDFRQ))))
	M->PB3_VRDSEM	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VRDSEM))))
	M->PB3_VEDSEG	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDSEG))))
	M->PB3_VEDTER	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDTER))))
	M->PB3_VEDQUA	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDQUA))))
	M->PB3_VEDQUI	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDQUI))))
	M->PB3_VEDSEX	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_VEDSEX))))
	
	//Agenda visita promotor.
	M->PB3_PRMFRQ	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMFRQ))))
	M->PB3_PRMSEM	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMSEM))))
	M->PB3_PRMSEG	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMSEG))))
	M->PB3_PRMTER	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMTER))))
	M->PB3_PRMQUA	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMQUA))))
	M->PB3_PRMQUI	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMQUI))))
	M->PB3_PRMSEX	:= Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:PB3_PRMSEX))))
	
	//Preenchimento da ZCG.
	M->ZCG_JNLREC  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNLREC ))))
	M->ZCG_JNLRE1  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNLRE1))))
	M->ZCG_JNRE1A  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNRE1A))))
	M->ZCG_JNLRE2  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNLRE2))))
	M->ZCG_JNRE2A  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNRE2A))))
	
	M->ZCG_JNCMP1  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNCMP1))))
	M->ZCG_JNCP1A  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNCP1A ))))
	M->ZCG_JNCMP2  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNCMP2 ))))
	M->ZCG_JNCP2A  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_JNCP2A))))
	
	M->ZCG_XTELLO  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_XTELLO))))
	M->ZCG_XTELFI  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_XTELFI))))
	M->ZCG_XORILE  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_XORILE))))
	M->ZCG_XCNLOR  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_XCNLOR))))
	M->ZCG_XCNLOR  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_XCNLOR))))
	M->ZCG_XRENFA  := Val(Alltrim(cValToChar(oParseJSON:ZCG_XRENFA)))
	M->ZCG_XPOPTO  := Val(Alltrim(cValToChar(oParseJSON:ZCG_XPOPTO)))
	M->ZCG_TFUNC   := Val(Alltrim(cValToChar(oParseJSON:ZCG_TFUNC)))
	M->ZCG_PERFPG  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_PERFPG))))
	M->ZCG_PRFORN  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_PRFORN))))
	M->ZCG_PRSFOR  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_PRSFOR))))
	M->ZCG_CORTES  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_CORTES))))
	M->ZCG_TCKMED  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_TCKMED))))
	M->ZCG_PERCMP  := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_PERCMP))))
	M->ZCG_VOLCMP  := Val(Alltrim(cValToChar(oParseJSON:ZCG_VOLCMP)))
	M->ZCG_QTDREF  := Val(Alltrim(cValToChar(oParseJSON:ZCG_QTDREF )))
	M->ZCG_TFUNC   := Upper(FwNoAccent(Alltrim(cValToChar(oParseJSON:ZCG_TFUNC))))
	*/
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} process
	processa solicitação. Chamado 037261. 
	@type  Function
	@author Everson
	@since 11/10/2017
	@version 01
	/*/
Static Function process(oParseJSON)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	Local cCli	:= Alltrim(Substr(cPreCad,1,6))
	Local cLoja	:= Alltrim(Substr(cPreCad,7,2))

	//Registra parecer do vendedor.
	cRestParecer := Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:parecerVnd)))))
	StaticCall(ADOA005,Adoa5Parec,cCli,cLoja)

	//Obtém o código de usuário do superior.
	DbSelectArea("PB3")
	__cUserId := PB3->PB3_VENENC

	//Registra parecer do supervisor.
	cRestParecer := Upper(FwNoAccent(DecodeUTF8(Alltrim(cValToChar(oParseJSON:parecerSup)))))
	StaticCall(ADOA005,Adoa5Parec,cCli,cLoja)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grLogIni
	Gera log inicial. Chamado 037261.
	@type  Function
	@author Everson
	@since 11/10/2017
	@version 01
	/*/
Static Function grLogIni()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

	//Gera Log.
	cMsg := REPLICATE("-", 128) + CRLF
	cMsg += "Situação antes da " + Iif(nOpc==2,"Visualização",Iif(nOpc==3,"Inclusão","Alteração")) + CRLF
	cMsg += 'Codigo do Cliente : ' + M->PB3_CODSA1 + CRLF
	cMsg += 'Loja do Cliente : ' + M->PB3_LOJSA1 + CRLF
	cMsg += 'Codigo interno PB3 : ' + M->PB3_COD + CRLF
	cMsg += 'Loja interna PB3 : ' + M->PB3_LOJA + CRLF
	cMsg += REPLICATE("-", 128) + CRLF
	cMsg += ' ' + CRLF

	//Grava Log.
	u_FSGrvLog( cMsg )

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} processAgnd
	Gera agendamentos. Chamado 037261. 
	@type  Function
	@author Everson
	@since 05/03/2018
	@version 01
	/*/
Static Function processAgnd(cPreCad)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	conout("cPreCad >>>>>>> " + cPreCad)
	DbSelectArea("ZC6")

		//Grava agendamento de vendedor.
		U_ADVEN057P(xFilial("SA1"),Substr(cPreCad,1,6),Substr(cPreCad,7,2),3,"V",3,.T.) 
	
		//Grava agendamento de promotor.
		U_ADVEN057P(xFilial("SA1"),Substr(cPreCad,1,6),Substr(cPreCad,7,2),3,"P",3,.T.)

	ZC6->(DbCloseArea())
	
	//Grava agendamento de ligação.
	DbSelectArea("ZBC")

		U_ADVEN029P(xFilial("ZBC"),Substr(cPreCad,1,6),Substr(cPreCad,7,2),3,2,.T.) 

	ZBC->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} svlZGC
	Grava dados na ZCG. Chamado 037261.
	@type  Function
	@author Everson
	@since 05/03/2018
	@version 01
	/*/
Static Function svlZGC(cPreCad)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local lInclui	:= .T.
	conout("ZCG >>>>>>> " + cPreCad)
	//
	DbSelectArea("ZCG")
	ZCG->(DbSetOrder(2))
	If ZCG->(DbSeek(xFilial("ZCG") + cPreCad))
		lInclui:= .F.
		
	EndIf
	conout("lInclui >>>>>>>>>>> " + cValToChar(lInclui) )
	//
	RecLock("ZCG",lInclui)
		ZCG->ZCG_PB3COD := 	Substr(cPreCad,1,6)
		ZCG->ZCG_PB3LOJ := 	Substr(cPreCad,7,2)
		ZCG->ZCG_JNLREC := 	M->ZCG_JNLREC
		ZCG->ZCG_JNLRE1 := 	M->ZCG_JNLRE1
		ZCG->ZCG_JNRE1A := 	M->ZCG_JNRE1A
		ZCG->ZCG_JNLRE2 := 	M->ZCG_JNLRE2
		ZCG->ZCG_JNRE2A := 	M->ZCG_JNRE2A
			
		ZCG->ZCG_JNCMP1 := 	M->ZCG_JNCMP1
		ZCG->ZCG_JNCP1A := 	M->ZCG_JNCP1A
		ZCG->ZCG_JNCMP2 := 	M->ZCG_JNCMP2
		ZCG->ZCG_JNCP2A := 	M->ZCG_JNCP2A
			
		ZCG->ZCG_XTELLO := 	M->ZCG_XTELLO
		ZCG->ZCG_XTELFI := 	M->ZCG_XTELFI
		ZCG->ZCG_XORILE := 	M->ZCG_XORILE
		ZCG->ZCG_XCNLOR := 	M->ZCG_XCNLOR
		ZCG->ZCG_XCNLOR := 	M->ZCG_XCNLOR
		ZCG->ZCG_XRENFA := 	M->ZCG_XRENFA
		ZCG->ZCG_XPOPTO := 	M->ZCG_XPOPTO
		ZCG->ZCG_TFUNC  := 	M->ZCG_TFUNC
		ZCG->ZCG_PERFPG := 	M->ZCG_PERFPG 
		ZCG->ZCG_PRFORN := 	M->ZCG_PRFORN
		ZCG->ZCG_PRSFOR := 	M->ZCG_PRSFOR
		ZCG->ZCG_CORTES :=	M->ZCG_CORTES
		ZCG->ZCG_TCKMED := 	M->ZCG_TCKMED
		ZCG->ZCG_PERCMP := 	M->ZCG_PERCMP
		ZCG->ZCG_VOLCMP := 	M->ZCG_VOLCMP
		ZCG->ZCG_QTDREF := 	M->ZCG_QTDREF
		ZCG->ZCG_TFUNC  := 	M->ZCG_TFUNC
		//ZCG->ZCG_CODCLIN:=	M->ZCG_CODCLIN
	ZCG->(MsUnlock())
	ZCG->(DbCloseArea())
		
	//
	RestArea(aArea)
	
Return Nil
