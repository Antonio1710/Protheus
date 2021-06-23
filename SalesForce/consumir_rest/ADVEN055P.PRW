#Include "Protheus.ch"
#Include 'Fileio.ch'
#Include 'TopConn.ch'  
#Include "Rwmake.ch"    
#Include "Tbiconn.ch"
#Include 'AP5mail.ch'
#Include "Restful.ch"

/*/{Protheus.doc} User Function ADVEN055P
    Rotina para função para envio de contrato comercial ao SalesForce.037261
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @Chamado 12139 - Fernando Sigoli - 14/04/2021 - tratamento para enviar A1_XIDSF (PRODUTO EXCEÇÃO CONTRATO)
/*/

User Function ADVEN055P(cParamBsc,lAut,cExpSql) // U_ADVEN055P("","",.F.," AND (RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA))) IN () ")  

	Local aArea   := GetArea()

	Default  cParamBsc 	:= ""
	Default  lAut	    := .F.
	Default  cExpSql	:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de contrato comercial ao SalesForce. ')

	//
	If ! lAut
		MsAguarde({|| Processar(cParamBsc,lAut,cExpSql) },"Aguarde","Processando cadastro contratos(SF)...")

	Else
		Processar(cParamBsc,lAut,cExpSql)

	EndIf

	//
	RestArea(aArea)

Return Nil


/*/{Protheus.doc} User Function Processar
    Rotina para função para Processamento dos envios 
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function Processar(cParamBsc,lAut,cExpSql)

	Local aParametros := {}
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Contract/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "contrato"
	Local cChvExt	:= "Codigo__c/"

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obtém a query.
	cQuery := cQuery	:= scriptSql(cParamBsc,aResponse,cExpSql)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN055P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"montJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)
	
	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	
	//
	If ! lLogin
		Return Nil

	EndIf
	
	//
	If ! lAut
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{},.T.) },"Aguarde","Processando cadastro contratos(SF)...",.T.)
		
	Else
		             StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{},.T.)
		
	EndIf


Return Nil


/*/{Protheus.doc} User Function montJson 
    Rotina para função para Processamento dos envios 
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function montJson(cMetodo,cChvExt,cNmAlias)

	Local aArea		:= GetArea()
	Local cJson	 	:= ""
	Local cDados1	:= ""
	Local aDados1	:= {}
	Local aDados2	:= {}
	Local i			:= 1
	Local aPercent	:= {}

	//
	cJson += '{'
	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Contract"', '"v41.0/sobjects/Contract/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
		
		cJson += '"Account" : {
			cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->CHVSF)) + '"
		cJson += '},''
		
		cJson += '"Pricebook2": {'
			cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->A1_TABELA)) + '"'
		cJson += '},'
		
		//Obtém composição de desconto comercial do cliente.
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek( xFilial("SA1") + Alltrim(cValToChar((cNmAlias)->CHVSF)) ))
		cDados1 := SA1->A1_XCCUSTC
		
		//Verifica se há composição cadastrada.
		If ! Empty(cDados1)
		
			aDados1 := StrToKarr(cDados1,"%")
		
			//
			For i := 1 To Len(aDados1)
				
				If ! Empty(Alltrim(cValToChar(aDados1[i])))
					aDados2 := StrToKarr(Alltrim(aDados1[i]),":")
					If Len(aDados2) = 2
						Aadd(aPercent,aDados2[2])
					
					EndIf
				
				EndIf
					
			Next i
			
			cJson += '"Fornecimento__c":"' + cValToChar(aPercent[3])   + '",'
			cJson += '"Crescimento__c":"' + cValToChar(aPercent[8])    + '",'
			cJson += '"	Aniversario__c":"' + cValToChar(aPercent[1])   + '",'
			cJson += '"Inauguracao__c":"' + cValToChar(aPercent[2])    + '",'
			cJson += '"Re_Inauguracao__c":"' + cValToChar(aPercent[5]) + '",'		
			cJson += '"Logistica__c":"' + cValToChar(aPercent[4])      + '",'			
			cJson += '"Quebra_Troca__c":"' + cValToChar(aPercent[6])   + '",'
			cJson += '"Verba_de_investimento_coorporativo__c":"' + cValToChar(aPercent[9]) + '",'
			cJson += '"Web__c":"' + cValToChar(aPercent[10])       + '",'
			cJson += '"Associacao__c":"' + cValToChar(aPercent[7]) + '"'
			
		Else
			
			cJson += '"Fornecimento__c":"0",'
			cJson += '"Crescimento__c":"0",'
			cJson += '"	Aniversario__c":"0",'
			cJson += '"Inauguracao__c":"0",'
			cJson += '"Re_Inauguracao__c":"0",'
			cJson += '"Logistica__c":"0",'			
			cJson += '"Quebra_Troca__c":"0",'
			cJson += '"Verba_de_investimento_coorporativo__c":"0",'
			cJson += '"Web__c":"0",'
			cJson += '"Associacao__c":"0"'	

		EndIf
		
		cJson += '}'

	cJson += '},'
	
	//
	SA1->(DbCloseArea())
	RestArea(aArea)

Return cJson


/*/{Protheus.doc} User Function scriptSql  
    Rotina para função de Script sql para consulta
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function scriptSql(cParamBsc,aResponse,cExpSql)

	Local cQuery 	:= ""	
	Local cCodVend	:= ""

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))
	cExpSql	  := Alltrim(cValToChar(cExpSql))

	//
	cQuery += " SELECT RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) AS CHVSF, A1_DESC, A1_TABELA, CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX), A1_XCCUSTC)) AS A1_XCCUSTC " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += " WHERE " 
	cQuery += " SA1.D_E_L_E_T_ = '' " 
	cQuery += " AND A1_VEND <> '' "
	//cQuery += " AND A1_DESC > 0 "
	cQuery += " AND A1_XCCUSTC IS NOT NULL "

	//
	If ! Empty(cParamBsc)
		cQuery += " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) = '" + cParamBsc + "' " 
	
	EndIf
	
	//
	If ! Empty(cExpSql)
	
		cQuery += cExpSql 
	
	EndIf
		
	cQuery += " ORDER BY A1_VEND,A1_COD " 
	
Return cQuery


/*/{Protheus.doc} User Function envItens  
    Função para enviar itens
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function envItens(cCodLoja,lAut,cChvTab,aResponse,cPrd_Method,cAliasS,cGrupoCli)

	Local aParametros := {}
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Produtos_Excecao_Contrato__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "item exceção contrato"
	Local cChvExt	:= "Chave_Externa__c/"
	Local cMsg		:= ""
	
	Default aResponse := {}
	Default cPrd_Method  := ""
	
	//
	If Len(aResponse) <= 0
		
		//Efetura login no SalesForce.
		lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
		
		//
		If ! lLogin
			Return Nil
	
		EndIf
	
	EndIf
	
	//
	//If IsInCallStack('U_exDCSfExp')
		//cQuery := iscriptSql(cCodLoja,cPrd_Method)
	//Else
		cQuery := iscriptSql(cCodLoja,"")
	
	//EndIf
	
	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN055P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"imontJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.F.)
	
	//Processa os registros.
	If  ! lAut
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{}) },"Aguarde","Processando cadastro contratos exc.(SF)...",.T.)
		
	Else
					 StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{})
		
	EndIf
		
Return Nil


/*/{Protheus.doc} User Function imontJson   
    Monta json. 
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function imontJson(cMetodo,cChvExt,cNmAlias)

	Local cJson	 	:= ""
	Local _XIDSF    := POSICIONE("SA1",1,xFilial("SA1")+(cNmAlias)->ZC5CLIE + (cNmAlias)->ZC5LOJ,"A1_XIDSF")

	cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Produtos_Excecao_Contrato__c"', '"v41.0/sobjects/Produtos_Excecao_Contrato__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'

			
			cJson += '"Contrato__r": {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"'
			cJson += '},'
			cJson += '"Produto__r" : {'
					cJson += '"Codigo__c" : "' + Alltrim(cValToChar((cNmAlias)->ZC5_PRODUT)) + '"'
			cJson += '},'
			
			cJson += '"Nome_Cliente__c" : "' 					 + Alltrim(cValtoChar(_XIDSF))                 + '",'
			cJson += '"Aniversario__c":"'                        + Alltrim(cValToChar((cNmAlias)->ZC5_ANIVER)) + '",'	
			cJson += '"Inauguracao__c":"'                        + Alltrim(cValToChar((cNmAlias)->ZC5_INAUGU)) + '",'	
			cJson += '"Fornecimento__c":"'                       + Alltrim(cValToChar((cNmAlias)->ZC5_FORNEC)) + '",'	
			cJson += '"Logistica__c":"'                          + Alltrim(cValToChar((cNmAlias)->ZC5_LOGIST)) + '",'
			cJson += '"Re_Inauguracao__c":"'                     + Alltrim(cValToChar((cNmAlias)->ZC5_REINAU)) + '",'
			cJson += '"Quebra_Troca__c":"'                       + Alltrim(cValToChar((cNmAlias)->ZC5_QBRTRC)) + '",'	
			cJson += '"Associacao__c":"'                         + Alltrim(cValToChar((cNmAlias)->ZC5_ASSOCI)) + '",'	
			cJson += '"Crescimento__c":"'                        + Alltrim(cValToChar((cNmAlias)->ZC5_CRESCI)) + '",'	
			cJson += '"Verba_de_Investimento_Coorporativo__c":"' + Alltrim(cValToChar((cNmAlias)->ZC5_INVCOO)) + '",'	
			cJson += '"Web__c":"'                                + Alltrim(cValToChar((cNmAlias)->ZC5_WEB))    + '"'	
			
		cJson += '}'
		
	cJson += '},'
	
Return cJson

/*/{Protheus.doc} User Function iscriptSql   
    Script sql dos itens com execeção de desconto contratual.
    @type  Function
    @author Everson
    @since 14/01/2018
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function iscriptSql(cCodLoja,cProduto)

	Local cQuery 	:= ""
	
	Default cProduto := ""

	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(ZC5_CODCLI)) + RTRIM(LTRIM(ZC5_LOJA)) AS CHVSF, ZC5_PRODUT, ZC5_ANIVER/100 AS ZC5_ANIVER, ZC5_INAUGU/100 AS ZC5_INAUGU, "
	cQuery += " ZC5_FORNEC/100 AS ZC5_FORNEC, ZC5_LOGIST/100 AS ZC5_LOGIST, ZC5_REINAU/100 AS ZC5_REINAU, ZC5_QBRTRC/100 AS ZC5_QBRTRC, ZC5_ASSOCI/100 AS ZC5_ASSOCI, " 
	cQuery += " ZC5_CRESCI/100 AS ZC5_CRESCI, ZC5_INVCOO/100 AS ZC5_INVCOO, ZC5_WEB/100 AS ZC5_WEB, RTRIM(LTRIM(ZC5_CODCLI)) AS ZC5CLIE ,RTRIM(LTRIM(ZC5_LOJA)) AS ZC5LOJ "
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZC5") + " AS ZC5 " 
	cQuery += " WHERE " 
	cQuery += " ZC5.D_E_L_E_T_ = '' " 
	cQuery += " AND RTRIM(LTRIM(ZC5_CODCLI)) + RTRIM(LTRIM(ZC5_LOJA)) = '" + cCodLoja + "' " 
	
	If ! Empty(cProduto)
		cQuery += " AND ZC5_PRODUT = '" + cProduto + "' "
		
	EndIf
	
Return cQuery
