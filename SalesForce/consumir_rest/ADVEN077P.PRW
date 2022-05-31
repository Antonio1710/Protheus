#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN077P      บAutor  ณEverson      บ Data ณ  12/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de notas fiscais devolu็a๕ ao SalesForce. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN077P(cEmp,cFili,cParamBsc,lAut,cExpSql,lItem) // U_ADVEN077P("0200735300000000001111",.F.,"",.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea   	:= GetArea()
	
    Default cEmp	  := "01"
	Default cFili	  := "02"
	Default cParamBsc := ""
	Default lAut	  := .F.
	Default cExpSql	  := ""
	Default lItem	  := .F.
	
	Private cEmpC	  := cEmp
	Private cFiliC    := cFili

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de notas fiscais devolu็a๕ ao SalesForce')

	//
	If lItem
		
		MsAguarde({|| envItens(cParamBsc,lAut,"",{}) },"Aguarde","Enviando registros(SF)...")
		
	Else
	
		If ! lAut
			MsAguarde({|| Processar(cParamBsc,lAut,cExpSql) },"Aguarde","Enviando registros(SF)...")
		
		Else
			Processar(cParamBsc,lAut,cExpSql)
			
		EndIf
	
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar      บAutor  ณEverson      บ Data ณ  12/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(cParamBsc,lAut,cExpSql)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	Local aParametros := {}
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Faturamento__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "cabe็alho nota fiscal"
	Local cChvExt	:= "Chave_Externa__c/"
	Local aRetOk	:= {}

	//Efetura login no SalesForce.
	//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obt้m a query.
	cQuery := scriptSql(cParamBsc,cExpSql)

	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN077P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.T.,.T.,"",.T.,.F.) },"Aguarde","Processando cabe็alho NF entrada(SF)...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,,"",@aRetOk,.T.,.T.,"",.T.,.F.) },"Aguarde","Processando cabe็alho NF entrada(SF)...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.T.,.T.,"",.T.,.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,,"",@aRetOk,.T.,.T.,"",.T.,.F. )
		itemNEnv(lAut,aResponse)
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontJson     บAutor  ณEverson     บ Data ณ  19/12/2017      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta json.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function montJson(cMetodo,cChvExt,cNmAlias)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cJson	 	:= ""
	Local cData		:= ""
	Local cPedido	:= Alltrim(cValToChar((cNmAlias)->D2_PEDIDO))
	Local cPedSF	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + cPedido ,"C5_XPEDSAL")))

	//
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Faturamento__c"', '"v41.0/sobjects/Faturamento__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
			
		//
		If cMetodo == "POST"
			
			cJson += '"Chave_Externa__c" : "'  + Alltrim(cValToChar((cNmAlias)->CHVSF))    + '",'
				
		EndIf
		
		cJson += '"Cliente__r" : {'
			cJson += '"Chave_Externa__c" : "'   + Alltrim(cValToChar((cNmAlias)->F1_FORNECE)) + Alltrim(cValToChar((cNmAlias)->F1_LOJA)) + '"'
		cJson += '},'
		
		//
		If ! Empty(cPedSF)
			cJson += '"Pedido__r" : {'
				cJson += '"Codigo_Protheus__c" : "' + cPedido + '"'
			cJson += '},'
		
		EndIf
		
		cJson += '"Numero_Nota__c" : "'    + Alltrim(cValToChar((cNmAlias)->F1_DOC))   + '",'
		cJson += '"Numero_Serie__c" : "'   + Alltrim(cValToChar((cNmAlias)->F1_SERIE)) + '",'
		
		cJson += '"Filial__c" : "'    + Alltrim(cValToChar((cNmAlias)->F1_FILIAL))   + '",'
		cJson += '"Empresa__c" : "'    + cEmpC + '",'
		
		cJson += '"Valor_Total__c" : "'           + cValToChar((cNmAlias)->F1_VALBRUT) + '",'
		cJson += '"Peso_Total_Bruto_Kg__c" : "'   + cValToChar((cNmAlias)->F1_PBRUTO) + '",'
		cJson += '"Peso_Total_Liquido_Kg__c" : "' + cValToChar((cNmAlias)->F1_PLIQUI) + '",'
		cJson += '"Tipo_Nota__c" : "E",'
		
		cData := Alltrim(cValToChar(((cNmAlias)->F1_EMISSAO)))
		cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
		cJson += '"Data_Emissao__c" : "' + cData + '",'
		
		cData := Alltrim(cValToChar(((cNmAlias)->F1_EMISSAO)))
		cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)			
		cJson += '"Data_Devolucao__c":"' + cData + '"'
		
		cJson += '}'

	cJson += '},'
	
Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptSql     บAutor  ณEverson      บ Data ณ  18/12/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para consulta.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptSql(cParamBsc,cExpSql)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""	

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " DISTINCT 'SF1' AS TAB, 'E' + '" + cEmpC +  "' + RTRIM(LTRIM(F1_FILIAL)) + RTRIM(LTRIM(F1_FORNECE)) + RTRIM(LTRIM(F1_LOJA)) + RTRIM(LTRIM(F1_DOC)) +  RTRIM(LTRIM(F1_SERIE)) + RTRIM(LTRIM(D2_PEDIDO)) AS CHVSF,   " 
	cQuery += " F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_VALBRUT, F1_PBRUTO, F1_PLIQUI, F1_EMISSAO, F1_DTDIGIT, D2_PEDIDO, F1_XSALES AS IDSALES " 
	cQuery += " FROM   " 
	cQuery += " SF1" + cEmpC + "0  (NOLOCK) AS SF1   " 
	cQuery += " INNER JOIN " 
	cQuery += " SD1" + cEmpC + "0 (NOLOCK) AS SD1 " 
	cQuery += " ON F1_FILIAL = D1_FILIAL " 
	cQuery += " AND F1_DOC = D1_DOC " 
	cQuery += " AND F1_FORNECE = D1_FORNECE " 
	cQuery += " AND F1_LOJA = D1_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 " 
	cQuery += " ON D1_FILIAL = D2_FILIAL " 
	cQuery += " AND D1_NFORI = D2_DOC " 
	cQuery += " AND D1_SERIORI = D2_SERIE " 
	cQuery += " AND D1_FORNECE = D2_CLIENTE " 
	cQuery += " AND D1_LOJA = D2_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += " SF2" + cEmpC + "0 (NOLOCK) AS SF2 " 
	cQuery += " ON D2_FILIAL = F2_FILIAL " 
	cQuery += " AND D2_DOC = F2_DOC " 
	cQuery += " AND D2_CLIENTE = F2_CLIENTE " 
	cQuery += " AND D2_LOJA = F2_LOJA " 
	cQuery += " WHERE   " 
	cQuery += " SF1.D_E_L_E_T_ = ''  " 
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = ''  " 
	cQuery += " AND SF2.D_E_L_E_T_ = '' " 
	cQuery += " AND SF2.F2_XSALES <> '' " 
	cQuery += " AND F1_TIPO = 'D' " 
	cQuery += " AND F1_FILIAL = '" + cFiliC + "' " 

	//
	If ! Empty(cParamBsc)
		cQuery += " AND RTRIM(LTRIM(F1_FILIAL)) + RTRIM(LTRIM(F1_FORNECE)) + RTRIM(LTRIM(F1_LOJA)) + RTRIM(LTRIM(F1_DOC)) +  RTRIM(LTRIM(F1_SERIE))  = '" + cParamBsc + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
	
	EndIf

	cQuery += " ORDER BY F1_DOC, F1_SERIE " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณitemNEnv     บAutor  ณEverson        บ Data ณ  13/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para enviar os itens nใo processados para SalesForce.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function itemNEnv(lAut,aResponse)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()
	
	//
	Conout("Inํcio ADVEN077P - Corre็ใo envio de itens notas fiscais de entrada.")
	
	//
	envItens("",lAut,"",aResponse)
	
	//
	Conout("Fim ADVEN077P - Corre็ใo envio de itens notas fiscais de entrada.")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvItens     บAutor  ณEverson        บ Data ณ  05/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para vincular o produto a tabela de pre็o padrใo.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envItens(cParamBsc,lAut,cChvTab,aResponse)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aParametros := {}
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Item_do_Faturamento__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "item nota fiscal entr."
	Local cChvExt	:= "Chave_Externa__c/"
	Local cMsg		:= ""
	Local aRetOk	:= {}
	
	Default aResponse := {}
	
	//
	If Len(aResponse) <= 0

		//Efetura login no SalesForce.
		//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    	lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)
		
		//
		If ! lLogin
			Return Nil
	
		EndIf	
	
	EndIf

	//
	cQuery := iscriptsql(cParamBsc)
	
	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN077P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4( @aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) ...",.T.)
		
	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F. )
					 
	EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimontJson     บAutor  ณEverson     บ Data ณ  15/01/2018     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta json.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function imontJson(cMetodo,cChvExt,cNmAlias)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cJson	 	:= ""
	Local cNfOri	:= (cNmAlias)->D1_NFORI
	Local cSeOri	:= (cNmAlias)->D1_SERIORI
	Local cPedido	:= Alltrim(cValToChar((cNmAlias)->D2_PEDIDO))
	Local cPedSF	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + cPedido   ,"C5_XPEDSAL")))
	Local cVend		:= ""
	Local cDtEmiPed	:= ""
	Local cUsr		:= ""
	Local cEnvMet	:= Upper(Alltrim(cValToChar(GetMv("MV_#SFEVFT"))))
	
	//		
	cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Item_do_Faturamento__c"', '"v41.0/sobjects/Item_do_Faturamento__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
	
		//
		If cMetodo == "POST"
		
			cJson += '"Chave_Externa__c":"' + Alltrim(cValToChar((cNmAlias)->CHVSF)) + '",'
			
			cJson += '"Faturamento__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->CHFAT)) + '"'
			cJson += '},'

		EndIf
		
		//
		If ! Empty(cPedSF)
			cJson += '"Pedido__r" : {'
				cJson += '"Codigo_Protheus__c" : "' + cPedido + '"'
			cJson += '},'
		
			cJson += '"Produto_do_pedido__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar(cPedido)) + Alltrim(cValToChar((cNmAlias)->D1_COD)) + '"'
			cJson += '},'
		
		Else
			
			cJson += '"Produto__r": {"Codigo__c": "'  + Alltrim(cValToChar((cNmAlias)->D1_COD)) + '"},'
		
		EndIf
		
					
		//
		If ! Empty(cPedSF) .And. cEnvMet == "S"
				
			cVend		:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + cPedido   ,"C5_VEND1")))
			cVend		:= Alltrim(cValToChar(Posicione("SA3",1, xFilial("SA3") + cVend, "A3_XAGRSF" )))
			If Empty(cVend)
				cVend		:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + (cNmAlias)->D2_PEDIDO   ,"C5_VEND1")))
				
			EndIf
			
			cDtEmiPed	:= Alltrim(DToS(Posicione("SC5",1,xFilial("SC5") + cPedido   ,"C5_EMISSAO")))
			cDtEmiPed	:= Substr(cDtEmiPed,1,4) + "-" + Substr(cDtEmiPed,5,2) + "-" + Substr(cDtEmiPed,7,2)
			cUsr		:= Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + cVend  ,"A3_CODUSR")))
			
			cJson += '"Meta_Vendedor__r" : {'
				cJson += '"Chave_Externa__c" : "' + cVend + Alltrim(cValToChar((cNmAlias)->D1_COD)) + cDtEmiPed +  '"'
			cJson += '},'
		
		EndIf
		
		//cJson += '"ICMS__c" : "'           + Alltrim(cValToChar((cNmAlias)->D1_VALICM)) + '",
		cJson += '"ICMS__c" : "'           + Alltrim(cValToChar((cNmAlias)->D1_PICM))  + '",
		cJson += '"Quantidade__c" : "'     + Alltrim(cValToChar((cNmAlias)->D1_QUANT)) + '",'
		cJson += '"Preco_Unitario__c" : "' + Alltrim(cValToChar((cNmAlias)->D1_VUNIT)) + '",'
		cJson += '"Valor_Total__c" : "'    + Alltrim(cValToChar((cNmAlias)->D1_TOTAL)) + '"'
		
		cJson += '}'
		
	cJson += '},'
		
Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณiscriptSql     บAutor  ณEverson      บ Data ณ  15/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para consulta itens.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function iscriptSql(cParamBsc,cAliasTab,cCampo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""	

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))
	
	//
	If ! Empty(cParamBsc)
	
		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " 'SD1' AS TAB, 'E' + '" + cEmpC + "' + RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_COD)) + RTRIM(LTRIM(D1_ITEM))+ RTRIM(LTRIM(D2_PEDIDO)) AS CHVSF, "
		cQuery += " 'E' + '" + cEmpC + "' + RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D2_PEDIDO)) AS CHFAT, "
		cQuery += " D1_FILIAL, D1_PEDIDO, D1_FORNECE, D1_LOJA, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_DOC, D1_SERIE, D1_NFORI, D1_SERIORI, D1_ITEM, D1_VALICM, D1_PICM, D2_PEDIDO, '' AS IDSALES " 
		cQuery += " FROM " 
		cQuery += " SD1" + cEmpC + "0 (NOLOCK) AS SD1 " 
		
		cQuery += " INNER JOIN "
		cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 ON "
		cQuery += " D1_FILIAL = D2_FILIAL "
		cQuery += " AND D1_NFORI = D2_DOC "
		cQuery += " AND D1_SERIORI = D2_SERIE "
		cQuery += " AND D1_FORNECE = D2_CLIENTE "
		cQuery += " AND D1_LOJA = D2_LOJA "
		cQuery += " AND D1_COD = D2_COD "
		
		cQuery += " WHERE " 
		cQuery += " SD1.D_E_L_E_T_ = '' " 
		cQuery += " AND SD2.D_E_L_E_T_ = '' "
		cQuery += " AND D1_FILIAL = '" + cFiliC + "' " 
		cQuery += " AND RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D2_PEDIDO)) = '" + Alltrim(cValToChar(Substr(cParamBsc,4,Len(cParamBsc)))) + "' " 
		
	Else

		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " 'SD1' AS TAB, 'E' + '" + cEmpC + "' + RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_COD)) + RTRIM(LTRIM(D1_ITEM))+ RTRIM(LTRIM(D2_PEDIDO)) AS CHVSF, "
		cQuery += " 'E' + '" + cEmpC + "' + RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D2_PEDIDO)) AS CHFAT, "
		cQuery += " D1_FILIAL, D1_PEDIDO, D1_FORNECE, D1_LOJA, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_DOC, D1_SERIE, D1_NFORI, D1_SERIORI, D1_ITEM, D1_VALICM, D1_PICM, D2_PEDIDO, '' AS IDSALES " 
		cQuery += " FROM " 
		cQuery += " SD1" + cEmpC + "0 (NOLOCK) AS SD1 " 
		
		cQuery += " INNER JOIN "
		cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 ON "
		cQuery += " D1_FILIAL = D2_FILIAL "
		cQuery += " AND D1_NFORI = D2_DOC "
		cQuery += " AND D1_SERIORI = D2_SERIE "
		cQuery += " AND D1_FORNECE = D2_CLIENTE "
		cQuery += " AND D1_LOJA = D2_LOJA "
		cQuery += " AND D1_COD = D2_COD "
		
		cQuery += " INNER JOIN "
		cQuery += " SF1" + cEmpC + "0 (NOLOCK) AS SF1 ON "
		cQuery += " D1_FILIAL = F1_FILIAL "
		cQuery += " AND D1_DOC = F1_DOC "
		cQuery += " AND D1_SERIE = F1_SERIE "
		cQuery += " AND D1_FORNECE = F1_FORNECE "
		cQuery += " AND D1_LOJA = F1_LOJA "
		
		cQuery += " WHERE " 
		cQuery += " SD1.D_E_L_E_T_ = '' " 
		cQuery += " AND SD2.D_E_L_E_T_ = '' "
		cQuery += " AND SF1.D_E_L_E_T_ = '' "
		cQuery += " AND F1_XSALES <> '' "
		cQuery += " AND D1_XIDSF = '' "
		cQuery += " AND DATEDIFF(DAY,F1_DTDIGIT,GETDATE()) <= 2 "
		cQuery += " AND D1_FILIAL = '" + cFiliC + "' " 
	
	EndIf
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmrkReg         บAutor  ณEverson      บ Data ณ  25/05/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para marcar o registro como jแ enviado ao SalesForce.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function mrkReg(cChave,lAut,cId,cMetodo,aResponse,cAliasS)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cUpdate := ""
	Local cMsg	  := ""
	
	//Remove Marca de nota de saํda e c๓digo da empresa.
	cChave := Alltrim(cValToChar(cChave))
	cId    := Alltrim(cValToChar(cId))
	conout("Tabela >>>>> " + Alltrim(cValToChar((cAliasS)->TAB)))
	conout("cId >>>>> " + Alltrim(cValToChar(cId)))
	//
	If Empty(cId)
		Return Nil
	
	EndIf
	
	//
	If Alltrim(cValToChar((cAliasS)->TAB)) == "SF1"
		cChave := Substr(cChave,1,Len(cChave)-6)
		conout("Chave SF1 >>>> " + cChave)
		
		//
		If chkNF(cChave) <= 1
			cUpdate := "UPDATE SF1" + cEmpC + "0 SET F1_XSALES = '" + cId + "' WHERE D_E_L_E_T_ = '' AND ( 'E' + '" + cEmpC +  "' + '" + cFiliC + "' + RTRIM(LTRIM(F1_FORNECE)) + RTRIM(LTRIM(F1_LOJA)) + RTRIM(LTRIM(F1_DOC)) +  RTRIM(LTRIM(F1_SERIE)) ) = '" + cChave + "' "
			Conout("ADVEN077P NF possui APENAS UM pedido de venda vinculado " + cChave)
			
		Else
			Conout("ADVEN077P NF possui MAIS QUE um pedido de venda vinculado " + cChave)
			
		EndIf
		
	ElseIf Alltrim(cValToChar((cAliasS)->TAB)) == "SD1"
		cChave := Substr(cChave,1,Len(cChave)-6)
		conout("Chave SD1 >>>> " + cChave)
		
		//
		cUpdate := "UPDATE SD1" + cEmpC + "0 SET D1_XIDSF = '" + cId + "' WHERE D_E_L_E_T_ = '' AND ( 'E' + '" + cEmpC + "' + RTRIM(LTRIM(D1_FILIAL)) + RTRIM(LTRIM(D1_DOC)) +  RTRIM(LTRIM(D1_SERIE)) + RTRIM(LTRIM(D1_FORNECE)) + RTRIM(LTRIM(D1_LOJA)) + RTRIM(LTRIM(D1_COD)) + RTRIM(LTRIM(D1_ITEM)) ) = '" + cChave + "' "
				
	EndIf
	
	//Atualiza o registro na SF2.
	If TCSqlExec(cUpdate) < 0
		
		cMsg := "Nใo foi possํvel atualizar o registro SF2 " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
		If !lAut
			MsgAlert(cMsg,"Fun็ใo mrkReg (ADVEN074P)")
			
		Else
			//Static Call(ADVEN075P,envErros,cMsg + "Fun็ใo mrkReg (ADVEN074P)")
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A2( cMsg + "Fun็ใo mrkReg (ADVEN074P)" )
			
		EndIf
	
	EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkNF          บAutor  ณEverson      บ Data ณ  22/10/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo checa nota fiscal de entrada para atualizar.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkNF(cChave)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 := GetArea()
	Local cQuery := ""	
	Local nQtd	 := 0
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " COUNT ( DISTINCT RTRIM(LTRIM(F1_FILIAL)) + RTRIM(LTRIM(F1_FORNECE)) + RTRIM(LTRIM(F1_LOJA)) + RTRIM(LTRIM(F1_DOC)) +  RTRIM(LTRIM(F1_SERIE)) + RTRIM(LTRIM(D2_PEDIDO)) ) AS QTD_REG "
	cQuery += " FROM   " 
	cQuery += " SF1" + cEmpC + "0  (NOLOCK) AS SF1   " 
	cQuery += " INNER JOIN " 
	cQuery += " SD1" + cEmpC + "0 (NOLOCK) AS SD1 " 
	cQuery += " ON F1_FILIAL = D1_FILIAL " 
	cQuery += " AND F1_DOC = D1_DOC " 
	cQuery += " AND F1_FORNECE = D1_FORNECE " 
	cQuery += " AND F1_LOJA = D1_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 " 
	cQuery += " ON D1_FILIAL = D2_FILIAL " 
	cQuery += " AND D1_NFORI = D2_DOC " 
	cQuery += " AND D1_SERIORI = D2_SERIE " 
	cQuery += " AND D1_FORNECE = D2_CLIENTE " 
	cQuery += " AND D1_LOJA = D2_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += " SF2" + cEmpC + "0 (NOLOCK) AS SF2 " 
	cQuery += " ON D2_FILIAL = F2_FILIAL " 
	cQuery += " AND D2_DOC = F2_DOC " 
	cQuery += " AND D2_CLIENTE = F2_CLIENTE " 
	cQuery += " AND D2_LOJA = F2_LOJA " 
	cQuery += " WHERE   " 
	cQuery += " SF1.D_E_L_E_T_ = ''  " 
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = ''  " 
	cQuery += " AND SF2.D_E_L_E_T_ = '' " 
	cQuery += " AND SF2.F2_XSALES <> '' " 
	cQuery += " AND F1_TIPO = 'D' " 
	cQuery += " AND F1_FILIAL = '" + cFiliC + "' " 	
	cQuery += " AND D1_XIDSF = '' "
	cQuery += " AND ( 'E' + '" + cEmpC +  "' + '" + cFiliC + "' + RTRIM(LTRIM(F1_FORNECE)) + RTRIM(LTRIM(F1_LOJA)) + RTRIM(LTRIM(F1_DOC)) +  RTRIM(LTRIM(F1_SERIE)) ) = '" + cChave + "' "
	
	//
	If Select("QTD_SF1") > 0
		QTD_SF1->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "QTD_SF1"
	DbSelectArea("QTD_SF1")
		nQtd := Val(cValToChar(QTD_SF1->QTD_REG))
	QTD_SF1->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return nQtd
