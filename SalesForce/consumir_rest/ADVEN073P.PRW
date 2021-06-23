#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADVEN073P
	Função para envio de custos ao SalesForce. Chamado 037261.
	@type  Function
	@author Everson
	@since 10/01/2018
	@version 01
	@history Everson, 19/05/2020. Chamado 056977. Adicionado preço mínimo do supervisor.
	/*/
User Function ADVEN073P(cDe,cAte,lAut,cExpSql,lAltTabPrc) // U_ADVEN073P("20200519","20200519",.T.)

	//Variáveis.	
	Local aArea   := GetArea()

	//
	Default cDe 		:= ""
	Default cAte		:= ""
	Default lAut		:= .F.
	Default cExpSql 	:= ""
	Default lAltTabPrc	:= .F.
	
	Private lAltTab		:= lAltTabPrc

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de custos ao SalesForce')

	//
	If ! lAut
		MsAguarde({|| Processar(cDe,cAte,lAut,cExpSql) },"Aguarde","Processando registros(SF)...")

	Else
		Processar(cDe,cAte,lAut,cExpSql)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} Processar
	Processamento dos envios. 
	@type  Static Function
	@author Everson 
	@since 10/01/2018
	@version 01
	/*/
Static Function Processar(cDe,cAte,lAut,cExpSql)

	//Variáveis.
	Local aParametros 	:= {}
	Local aResponse		:= {}
	Local lLogin		:= .F.
	Local cQuery		:= ""
	Local cServTab		:= "/services/data/v41.0/sobjects/Custo__c/"
	Local cCmpChv		:= "CHVSF"
	Local cObjeto		:= "custo"
	Local cChvExt		:= "Chave_Externa__c/"
	Local aRetOk		:= {}
	Local cMsg			:= ""

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf
	
	//Obtém a query.
	cQuery := scriptSql(cDe,cAte,cExpSql)
	
	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN073P")
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
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk) },"Aguarde","Processando registro(s) ...",.T.)
		
	Else
					 StaticCall(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",@aRetOk)
		
	EndIf

Return Nil
/*/{Protheus.doc} montJson
	Monta json. 
	@type  Static Function
	@author Everson 
	@since 19/12/2017
	@version 01
	/*/
Static Function montJson(cMetodo,cChvExt,cNmAlias)

	//Variáveis.
	Local cJson	    := ""
	
	//
	cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
        cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Custo__c"', '"v41.0/sobjects/Custo__c/' + cChvExt + Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
			
			//Valida se é necessário enviar código e data. Envio apenas para operação de inserção.
			If cMetodo == "POST"
				cJson += '"Produto__r" : {'
					cJson += '"Codigo__c" : "' + Alltrim(cValtoChar((cNmAlias)->B1_COD)) + '"'
				cJson += '},'
				cJson += '"Data__c" : "' + Alltrim(cValtoChar((cNmAlias)->DT_SF)) + '",'
			
			EndIf

			cJson += '"Produto__r" : {'
				cJson += '"Codigo__c" : "' + Alltrim(cValtoChar((cNmAlias)->B1_COD)) + '"'
			cJson += '},'
			cJson += '"Data__c" : "' + Alltrim(cValtoChar((cNmAlias)->DT_SF)) + '",'			
			cJson += '"Preco_Maximo__c": "' + Alltrim(cValtoChar((cNmAlias)->VL_MAX)) + '",'
			cJson += '"Preco_Minimo__c": "' + Alltrim(cValtoChar((cNmAlias)->VL_MIN)) + '",'
			cJson += '"Preco_Meta__c"  : "' + Alltrim(cValtoChar((cNmAlias)->VL_MET)) + '",'
			cJson += '"Preco_Min_Supervisor__c" : "' + Alltrim(cValtoChar((cNmAlias)->VL_SUP)) + '",' //Everson - 19/05/2020. Chamado 056977.
			cJson += '"Preco_Custo__c" : "' + Alltrim(cValtoChar((cNmAlias)->VL_CUS)) + '"'
			
		cJson += '}'
	cJson += '},'
	
Return cJson
/*/{Protheus.doc} scriptSql
	Script sql para consulta de produtos.
	@type  Static Function
	@author Everson 
	@since 26/12/2017
	@version 01
	/*/
Static Function scriptSql(cDe,cAte,cExpSql)

	//Variáveis.
	Local cQuery := ""

	//
	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(B1_COD)) + SUBSTRING(ZZS_DATA,1,4) + '-' + SUBSTRING(ZZS_DATA,5,2) + '-' + SUBSTRING(ZZS_DATA,7,2) AS CHVSF,  " 
	cQuery += " SUBSTRING(ZZS_DATA,1,4) + '-' + SUBSTRING(ZZS_DATA,5,2) + '-' + SUBSTRING(ZZS_DATA,7,2) AS DT_SF,  " 
	cQuery += " ZZS_DATA, B1_COD, ZZS_VALOR AS VL_CUS, ZZS_PRMETA AS VL_MET, MAXI.DA1_XPRLIQ AS VL_MAX, MINI.DA1_XPRLIQ AS VL_MIN, SUPER.DA1_XPRLIQ AS VL_SUP " //Everson - 19/05/2020. Chamado 056977.
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("ZZS") + "  (NOLOCK) AS ZZS   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " " + RetSqlName("SB1") + "  (NOLOCK) AS SB1   " 
	cQuery += " ON ZZS_GRUPO = B1_GRUPO   " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " (NOLOCK) AS DA1 WHERE DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB IN ('Y00') AND DA1.D_E_L_E_T_ = '') AS MAXI " 
	cQuery += " ON B1_COD = MAXI.DA1_CODPRO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " (NOLOCK) AS DA1 WHERE DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB IN ('Z01') AND DA1.D_E_L_E_T_ = '') AS MINI " 
	cQuery += " ON B1_COD = MINI.DA1_CODPRO " 

	//Everson - 19/05/2020. Chamado 056977.
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT DA1_CODPRO, DA1_XPRLIQ FROM " + RetSqlName("DA1") + " (NOLOCK) AS DA1 WHERE DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB IN ('Z00') AND DA1.D_E_L_E_T_ = '') AS SUPER " 
	cQuery += " ON B1_COD = SUPER.DA1_CODPRO " 
	//

	cQuery += " WHERE   " 
	cQuery += " ZZS.D_E_L_E_T_ = ''   " 
	cQuery += " AND SB1.D_E_L_E_T_ = ''   " 
	cQuery += " AND B1_XSALES = '2' " 
	
	//
	If ! Empty(cAte)
		cQuery += " AND ZZS_DATA >= '" + cDe + "'   " 
		cQuery += " AND ZZS_DATA <= '" + cAte + "'  " 
	
	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
	
	EndIf
	
	cQuery += " ORDER BY ZZS_DATA, B1_GRUPO, B1_COD " 
	
Return cQuery