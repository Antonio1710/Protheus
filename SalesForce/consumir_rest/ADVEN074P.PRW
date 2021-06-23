#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN074P      บAutor  ณEverson      บ Data ณ  12/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de notas fiscais ao SalesForce.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN074P(cEmp,cFili,cParamBsc,lAut,cExpSql,lCancelada) // U_ADVEN074P("01","02","",.F.," AND F2_DOC = '000487015' ") // U_ADVEN074P("01","02","001200752SF1",.F.,"",.T.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea   	:= GetArea()
	
	Default cEmp	   := "01"
	Default cFili	   := "02"
	Default cParamBsc  := ""
	Default lAut	   := .F.
	Default cExpSql	   := ""
	Default lCancelada := .F.
	
	Private cEmpC	  := cEmp
	Private cFiliC    := cFili
	Private lCanc	  := lCancelada
	Private lMrkCanc  := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de notas fiscais ao SalesForce')
	
	//
	If ! lAut
		MsAguarde({|| Processar(cParamBsc,lAut,cExpSql,cEmp,cFili,lCancelada,1) },"Aguarde","Enviando registros(SF)...")
	
	Else
		Processar(cParamBsc,lAut,cExpSql,cEmp,cFili,lCancelada,1)
		Conout("ADVEN074P - Inํcio envio de notas de saํda canceladas.")
		lMrkCanc := .T.
		Processar("",lAut,cExpSql,cEmp,cFili,.T.,2)
		Conout("ADVEN074P - Fim envio de notas de saํda canceladas.")
		              
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
Static Function Processar(cParamBsc,lAut,cExpSql,cEmp,cFili,lCancelada,nOpc)

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
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf

	//Obt้m a query.
	cQuery := scriptSql(nOpc,cParamBsc,cExpSql,cEmp,cFili,lCancelada)

	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN074P")
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
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,Iif(lCanc,.F.,.T.),.T.,"",.T.,.F.) },"Aguarde","Processando cabe็alho NF saํda(SF)...",.T.)
		//Processa({|| itemNEnv(lAut,aResponse) },"Aguarde","Processando item NF saํda(SF) nใo processado...",.T.)
		
	Else
		StaticCall(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,Iif(lCanc,.F.,.T.),.T.,"",.T.,.F.,lMrkCanc)
		If nOpc == 1
			itemNEnv(lAut,aResponse)
		
		EndIf
		
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
	Local cPedido	:= Alltrim(cValToChar(Posicione("SD2",3,xFilial("SD2") + (cNmAlias)->F2_DOC + (cNmAlias)->F2_SERIE ,"D2_PEDIDO")))
	Local cPedSF	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + cPedido   ,"C5_XPEDSAL")))

	//
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Faturamento__c"', '"v41.0/sobjects/Faturamento__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
			
			//
			If lCanc //Envio de data de cancelamento de nota fiscal.
				
				cData := Alltrim(cValToChar(((cNmAlias)->F3_DTCANC)))
				cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
				cJson += '"Data_Cancelamento__c":"' + cData + '"'
			
			Else
			
				//
				If cMetodo == "POST"
					
					cJson += '"Chave_Externa__c" : "'  + Alltrim(cValToChar((cNmAlias)->CHVSF))    + '",'
					
				EndIf
				
				cJson += '"Cliente__r" : {'
					cJson += '"Chave_Externa__c" : "'   + Alltrim(cValToChar((cNmAlias)->F2_CLIENTE)) + Alltrim(cValToChar((cNmAlias)->F2_LOJA)) + '"'
				cJson += '},'
				
				//
				If ! Empty(cPedSF)
					cJson += '"Pedido__r" : {'
						cJson += '"Codigo_Protheus__c" : "' + cPedido + '"'
					cJson += '},'
				
				EndIf
				
				//
				If ! Empty(Alltrim(cValToChar(((cNmAlias)->F3_DTCANC))))
					cData := Alltrim(cValToChar(((cNmAlias)->F3_DTCANC)))
					cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
					cJson += '"Data_Cancelamento__c":"' + cData + '",'	
				
				EndIf	
				
				//
				cJson += '"Numero_Nota__c" : "'    + Alltrim(cValToChar((cNmAlias)->F2_DOC))   + '",'
				cJson += '"Numero_Serie__c" : "'   + Alltrim(cValToChar((cNmAlias)->F2_SERIE)) + '",'
				cJson += '"Filial__c" : "'    + Alltrim(cValToChar((cNmAlias)->F2_FILIAL))   + '",'
				cJson += '"Empresa__c" : "'   + cEmpC + '",'			
				cJson += '"Valor_Total__c" : "'           + cValToChar((cNmAlias)->F2_VALBRUT) + '",'
				cJson += '"Peso_Total_Bruto_Kg__c" : "'   + cValToChar((cNmAlias)->F2_PBRUTO) + '",'
				cJson += '"Peso_Total_Liquido_Kg__c" : "' + cValToChar((cNmAlias)->F2_PLIQUI) + '",'
				cJson += '"Tipo_Nota__c" : "S",'
				cData := Alltrim(cValToChar(((cNmAlias)->F2_EMISSAO)))
				cData := Substr(cData,1,4) + "-" + Substr(cData,5,2) + "-" + Substr(cData,7,2)
				cJson += '"Data_Emissao__c" : "'      + cData + '"'		
			
			EndIf
		
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
Static Function scriptSql(nOpc,cParamBsc,cExpSql,cEmp,cFili,lCancelada)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""	
	Local cDt	 := Alltrim( cValToChar( GetMv("MV_#SFDTPD" ) ))
	
	Default nOpc := 1

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " DISTINCT 'SF2' AS TAB, 'S' + '" + cEmp + "' + RTRIM(LTRIM(F2_FILIAL)) + RTRIM(LTRIM(F2_CLIENTE)) + RTRIM(LTRIM(F2_LOJA)) + RTRIM(LTRIM(F2_DOC)) +  RTRIM(LTRIM(F2_SERIE)) AS CHVSF, " 
	cQuery += " F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_VALBRUT, F2_PBRUTO, F2_PLIQUI, F2_EMISSAO, F2_XSALES AS IDSALES, F3_DTCANC " 
	cQuery += " FROM " 
	cQuery += " SF2" + cEmp + "0 (NOLOCK) AS SF2 " 
	
	//
	If nOpc == 1
		cQuery += " LEFT OUTER JOIN "
	
	ElseIf nOpc == 2
		cQuery += " INNER JOIN "
		
	EndIf

	cQuery += " (SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_CLIENT, F3_LOJA, F3_DTCANC FROM SF3" + cEmp + "0 (NOLOCK) WHERE F3_FILIAL = '" + cFili + "' AND F3_DTCANC <> '' AND D_E_L_E_T_ = '') AS SF3 "
	cQuery += " ON "
	cQuery += " F2_DOC = F3_NFISCAL "
	cQuery += " AND F2_SERIE = F3_SERIE "
	cQuery += " AND F2_CLIENTE = F3_CLIENT "
	cQuery += " AND F2_LOJA = F3_LOJA "
	
	//
	If cFili == "02" .And. nOpc == 1
	
		 cQuery += " INNER JOIN " 
		 cQuery += " ( " 
			 cQuery += " SELECT " 
			 cQuery += " C5_FILIAL, C5_NOTA, C5_SERIE, C5_CLIENTE, C5_LOJACLI " 
			 cQuery += " FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
			 cQuery += " WHERE " 
			 cQuery += " C5_FILIAL = '" + cFili + "' "
			 
			 If IsInCallStack("U_ADVEN083P")
				 cQuery += " AND C5_NOTA NOT IN ('','XXXXXXXXX') " 
				 cQuery += " AND C5_SERIE <> '' " 
				 cQuery += " AND C5_EMISSAO >= '" + cDt + "' " 
			 
			 EndIf
			 
			 cQuery += " AND C5_XPEDSAL <> '' " 
			 cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		 cQuery += " ) AS PEDIDO " 
		 cQuery += " ON F2_FILIAL = PEDIDO.C5_FILIAL " 
		 cQuery += " AND F2_DOC = PEDIDO.C5_NOTA " 
		 cQuery += " AND F2_SERIE = PEDIDO.C5_SERIE " 
		 cQuery += " AND F2_CLIENTE = PEDIDO.C5_CLIENTE " 
		 cQuery += " AND F2_LOJA = PEDIDO.C5_LOJACLI " 

	EndIf
	
	cQuery += " WHERE " 
	cQuery += " F2_FILIAL = '" + cFili + "' "
	
	//
	If nOpc == 2
		cQuery += " AND F2_XSFENVC <> '2' "
		cQuery += " AND F2_XSALES <> '' "
		
	EndIf

	//
	If ! Empty(cParamBsc)
		cQuery += " AND RTRIM(LTRIM(F2_DOC)) + RTRIM(LTRIM(F2_SERIE)) = '" + cParamBsc + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql + Iif(nOpc == 1," AND F2_XSALES = '' ","")
	
	EndIf
	
	//
	If !lCancelada
		cQuery += " AND SF2.D_E_L_E_T_ = '' " 
		
		//
		If IsInCallStack("ADVEN083P") .And. nOpc == 1
			cQuery += " AND F2_XSALES = '' "
		
		EndIf
	
	EndIf

	cQuery += " ORDER BY F2_DOC, F2_SERIE " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณitemNEnv     บAutor  ณEverson        บ Data ณ  11/06/2018   บฑฑ
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
	Conout("Inํcio ADVEN074P - Corre็ใo envio de itens notas fiscais de saํda.")
	
	//
	envItens("",lAut,"",aResponse)
	
	//
	Conout("Fim ADVEN074P - Corre็ใo envio de itens notas fiscais de saํda.")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvItens     บAutor  ณEverson        บ Data ณ  05/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para enviar os itens da nota fiscal de saํda.        บฑฑ
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
	Local cObjeto	:= "item nota fiscal saํda"
	Local cChvExt	:= "Chave_Externa__c/"
	Local aRetOk	:= {}
	
	//
	cQuery := iscriptsql(cParamBsc)
	
	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN074P")
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
		//Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,,,@aRetOk) },"Aguarde","Processando registro(s) ...",.T.)
		Processa({|| StaticCall(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) ...",.T.)
		
	Else
					 StaticCall(ADVEN075P,ProcessarB,@aParametros,,"",@aRetOk,.F.,.T.,"",.T.,.F.)
		
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
	Local cPedSF	:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + (cNmAlias)->D2_PEDIDO   ,"C5_XPEDSAL")))
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
		
/*		cJson += '"Faturamento__r" : {'
			cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->CHFAT)) + '"'
		cJson += '},'*/
		
		//
		If ! Empty(cPedSF)
			cJson += '"Pedido__r" : {'
				cJson += '"Codigo_Protheus__c" : "' + Alltrim(cValToChar((cNmAlias)->D2_PEDIDO)) + '"'
			cJson += '},'
		
			cJson += '"Produto_do_pedido__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->D2_PEDIDO)) + Alltrim(cValToChar((cNmAlias)->D2_COD)) + '"'
			cJson += '},'
		
		Else
			
			cJson += '"Produto__r": {"Codigo__c": "' + Alltrim(cValToChar((cNmAlias)->D2_COD)) + '"},'
		
		EndIf
		
		//
		If ! Empty(cPedSF) .And. cEnvMet == "S"
			
			cVend		:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + (cNmAlias)->D2_PEDIDO   ,"C5_VEND1")))
			cVend		:= Alltrim(cValToChar(Posicione("SA3",1, xFilial("SA3") + cVend, "A3_XAGRSF" )))
			If Empty(cVend)
				cVend		:= Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + (cNmAlias)->D2_PEDIDO   ,"C5_VEND1")))
				
			EndIF
			
			cDtEmiPed	:= Alltrim(DToS(Posicione("SC5",1,xFilial("SC5") + (cNmAlias)->D2_PEDIDO   ,"C5_EMISSAO")))
			cDtEmiPed	:= Substr(cDtEmiPed,1,4) + "-" + Substr(cDtEmiPed,5,2) + "-" + Substr(cDtEmiPed,7,2)
			cUsr		:= Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + cVend  ,"A3_CODUSR")))
		
			cJson += '"Meta_Vendedor__r" : {'
				cJson += '"Chave_Externa__c" : "' + cVend + Alltrim(cValToChar((cNmAlias)->D2_COD)) + cDtEmiPed +  '"'
			cJson += '},'
		
		EndIf
		
		//cJson += '"ICMS__c" : "'           + Alltrim(cValToChar((cNmAlias)->D2_VALICM)) + '",
		cJson += '"ICMS__c" : "'           + Alltrim(cValToChar((cNmAlias)->D2_PICM))   + '",
		cJson += '"Quantidade__c" : "'     + Alltrim(cValToChar((cNmAlias)->D2_QUANT))  + '",'
		cJson += '"Preco_Unitario__c" : "' + Alltrim(cValToChar((cNmAlias)->D2_PRCVEN)) + '",'
		cJson += '"Valor_Total__c" : "'    + Alltrim(cValToChar((cNmAlias)->D2_TOTAL))  + '"'
		
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
Static Function iscriptSql(cParamBsc)

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
		cQuery += " 'SD2' AS TAB,'S' + '" + cEmpC + "' + RTRIM(LTRIM(D2_FILIAL)) + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_COD)) + RTRIM(LTRIM(D2_ITEM)) AS CHVSF, "
		cQuery += " 'S' + '" + cEmpC + "' + RTRIM(LTRIM(D2_FILIAL)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) AS CHFAT, "
		cQuery += " D2_FILIAL, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_DOC, D2_SERIE, D2_ITEM, D2_VALICM, D2_BASEICM, D2_PICM, D2_XIDSF AS IDSALES " 
		cQuery += " FROM " 
		cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 " 
		cQuery += " WHERE " 
		cQuery += " SD2.D_E_L_E_T_ = '' " 
		cQuery += " AND D2_FILIAL = '" + cFiliC + "' " 
		cQuery += " AND ( 'S' + '" + cEmpC + "' + RTRIM(LTRIM(D2_FILIAL)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) ) = '" + Alltrim(cValToChar(cParamBsc)) + "' " 
		
	Else
		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " 'SD2' AS TAB,'S' + '" + cEmpC + "' + RTRIM(LTRIM(D2_FILIAL)) + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_COD)) + RTRIM(LTRIM(D2_ITEM)) AS CHVSF, "
		cQuery += " 'S' + '" + cEmpC + "' + RTRIM(LTRIM(D2_FILIAL)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) AS CHFAT, "
		cQuery += " D2_FILIAL, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_DOC, D2_SERIE, D2_ITEM, D2_VALICM, D2_BASEICM, D2_PICM, D2_XIDSF AS IDSALES " 
		cQuery += " FROM " 
		cQuery += " SD2" + cEmpC + "0 (NOLOCK) AS SD2 " 
		cQuery += " INNER JOIN " 
		cQuery += " SF2" + cEmpC + "0 (NOLOCK) AS SF2 " 
		cQuery += " ON F2_FILIAL = D2_FILIAL " 
		cQuery += " AND F2_DOC = D2_DOC " 
		cQuery += " AND F2_SERIE = D2_SERIE " 
		cQuery += " WHERE " 
		cQuery += " SD2.D_E_L_E_T_ = '' " 
		cQuery += " AND SF2.D_E_L_E_T_ = '' " 
		cQuery += " AND F2_XSALES <> '' " 
		cQuery += " AND D2_XIDSF = '' " 
		cQuery += " AND DATEDIFF(DAY,F2_EMISSAO,GETDATE()) <= 2 " 
		cQuery += " AND D2_FILIAL = '" + cFiliC + "' " 	
		cQuery += " ORDER BY D2_DOC "
		
	EndIf
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmrkReg         บAutor  ณEverson      บ Data ณ  13/02/2018   บฑฑ
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
	
	//
	If Empty(cId) .And. ! lMrkCanc
		Return Nil
	
	EndIf
	
	//
	If lMrkCanc
		cUpdate := "UPDATE SF2" + cEmpC + "0 SET F2_XSFENVC = '2' WHERE ( 'S' + '" + cEmpC + "' + '" + cFiliC + "' + RTRIM(LTRIM(F2_CLIENTE)) + RTRIM(LTRIM(F2_LOJA)) + RTRIM(LTRIM(F2_DOC)) +  RTRIM(LTRIM(F2_SERIE)) ) = '" + cChave + "' "
		Conout("Envio de cancelamento NF saํda " + cChave )
		
	ElseIf Alltrim(cValToChar((cAliasS)->TAB)) == "SF2"
		cUpdate := "UPDATE SF2" + cEmpC + "0 SET F2_XSALES = '" + cId + "' WHERE D_E_L_E_T_ = '' AND ( 'S' + '" + cEmpC + "' + '" + cFiliC + "' + RTRIM(LTRIM(F2_CLIENTE)) + RTRIM(LTRIM(F2_LOJA)) + RTRIM(LTRIM(F2_DOC)) +  RTRIM(LTRIM(F2_SERIE)) ) = '" + cChave + "' "
	
	ElseIf Alltrim(cValToChar((cAliasS)->TAB)) == "SD2"
		cUpdate := "UPDATE SD2" + cEmpC + "0 SET D2_XIDSF = '" + cId + "' WHERE D_E_L_E_T_ = '' AND  ( 'S' + '" + cEmpC + "' + '" + cFiliC + "' + RTRIM(LTRIM(D2_DOC)) +  RTRIM(LTRIM(D2_SERIE)) + RTRIM(LTRIM(D2_CLIENTE)) + RTRIM(LTRIM(D2_LOJA)) + RTRIM(LTRIM(D2_COD)) + RTRIM(LTRIM(D2_ITEM))) = '" + cChave + "' "
		
	EndIf
	
	//Atualiza o registro na SF2.
	If ! Empty(cUpdate)
		If TCSqlExec(cUpdate) < 0
			
			cMsg := "Nใo foi possํvel atualizar o registro SF2 " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
			If !lAut
				MsgAlert(cMsg,"Fun็ใo mrkReg (ADVEN074P)")
				
			Else
				StaticCall(ADVEN075P,envErros,cMsg + "Fun็ใo mrkReg (ADVEN074P)")
				
			EndIf
		
		EndIf
	
	Else
		Conout("String de update em branco mrkReg ADVEN074P.")		
		
	EndIF
	
Return Nil