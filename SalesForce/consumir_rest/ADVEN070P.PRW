#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADVEN070P
	Função para envio de condições de pagamento ao SalesForce.
	Chamado 037261.
	@type  Function
	@author Everson
	@since 22/12/2017
	@version 01
	@history Everson, 24/04/2020, Tratamento para flegar se a condição de pagamento gera boleto para pagamento antecipado.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	/*/
User Function ADVEN070P(cDe,cAte,lAut,cExpSql) // U_ADVEN070P()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea   	:= GetArea()
	
	Default cDe := ""
	Default cAte := ""
	Default lAut	  := .F.
	Default cExpSql	  := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para envio de condições de pagamento ao SalesForce')
	
	//
	If ! lAut
		MsAguarde({|| Processar(cDe,cAte,lAut,cExpSql) },"Aguarde","Processando cadastro cond.pag.(SF)...")
	
	Else
		Processar(cDe,cAte,lAut,cExpSql)
		
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} Processar
	Processamento dos envios. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 22/12/2017
	@version 01
	/*/
Static Function Processar(cDe,cAte,lAut,cExpSql)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aParametros := {}
	Local aResponse	  := {}
	Local cMsg		  := ""
	Local lLogin	  := .F.
	Local cQuery	  := ""
	Local cServTab	  := "/services/data/v41.0/sobjects/Condicao_de_Pagamento__c/"
	Local cCmpChv	  := "CHVSF"
	Local cObjeto	  := "condição de pagamento"
	Local cChvExt	  := "Codigo__c/"

	//Efetura login no SalesForce.
	//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obtém a query.
	cQuery := scriptSql(cDe,cAte,cExpSql)

	//Adiciona parâmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN070P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{}) },"Aguarde","Processando cadastro cond.pag.(SF)...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,.F.,"PATCH",{}) },"Aguarde","Processando cadastro cond.pag.(SF)...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"PATCH",{})
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,.F.,"PATCH",{} )

	EndIf

Return Nil
/*/{Protheus.doc} nomeStaticFunction
	Monta json. Chamado 037261. 
	@type  Static Function
	@author Everson
	@since 19/12/2017
	@version 01
	/*/
Static Function montJson(cMetodo,cChvExt,cNmAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cJson	 	:= ""
	
	//
	//
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Condicao_de_Pagamento__c"', '"v41.0/sobjects/Condicao_de_Pagamento__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'

		//
		If cMetodo == "POST"
	
			cJson += '"Codigo__c":"' + Alltrim(cValToChar((cNmAlias)->E4_CODIGO)) + '", '
	
		EndIf
		
		cJson += '"Bloqueado__c":"'  + Iif( Alltrim(cValToChar((cNmAlias)->E4_USADO)) == "N","true","false") + '",'

		cJson += '"Boleto_Pag_Antecipado__c":"'  + Iif( Alltrim(cValToChar((cNmAlias)->E4_CTRADT)) == "1","true","false") + '",' //Everson - 24/04/2020. Chamado 056247.
		
		cJson += '"Name":"'          + Alltrim(cValToChar((cNmAlias)->E4_CODIGO)) + ' - ' + Alltrim(cValToChar((cNmAlias)->E4_DESCRI))   + '",'
		
		cJson += '"Descricao__c":"'  + Alltrim(cValToChar((cNmAlias)->E4_COND))   + '"'


		cJson += '}'

	cJson += '},'
	
	//

Return cJson
/*/{Protheus.doc} scriptSql
	Script sql para consulta. Chamado 037261.
	@type  Static Function
	@author user
	@since 18/12/2017
	@version 01
	/*/
Static Function scriptSql(cDe,cAte,cExpSql)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cQuery := ""	

	//
	cDe := Alltrim(cValToChar(cDe))
	cExpSql	  := Alltrim(cValToChar(cExpSql))

	//
	cQuery := ""
	cQuery += " SELECT E4_CODIGO AS CHVSF, E4_CODIGO, E4_COND, E4_DESCRI, E4_MSBLQL, E4_USADO, E4_CTRADT " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE4") + " (NOLOCK) AS SE4 " 
	cQuery += " WHERE " 
	cQuery += " SE4.D_E_L_E_T_ = '' " 
	cQuery += " AND E4_XSALES = '2' "

	//
	If ! Empty(cAte)
		cQuery += " AND E4_CODIGO >= '" + cDe + "' " 
		cQuery += " AND E4_CODIGO <= '" + cAte + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
	
	EndIf

	cQuery += " ORDER BY E4_CODIGO " 

Return cQuery
