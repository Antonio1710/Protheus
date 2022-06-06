#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN084P บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de ocorr๊ncias de logํstica ao SalesForce.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบversionamento:                                                         บฑฑ
ฑฑบEverson - 18/12/2018. Chamado 045435. Comentado c๓diog para nใo enviar บฑฑ
ฑฑบas ocorr๊ncias de logดsitica para o Salesforce.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN084P(cNota,cSerie,lAut,cExpSql) // U_ADVEN084P("001257748","01",.F.,"")     

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea   		:= GetArea()
	
	Default cNota    	:= ""
	Default cSerie		:= ""
	Default lAut		:= .F.
	Default cExpSql		:= ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de ocorr๊ncias de logํstica ao SalesForce.')
	
	//
	//Everson - 18/12/2018. Chamado 045435.
	/*If ! lAut
		MsAguarde({|| Processar(cNota,cSerie,lAut,cExpSql) },"Aguarde","Enviando cabelho de caso(SF)...")
	
	Else
		              Processar(cNota,cSerie,lAut,cExpSql)
		
	EndIf*/
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(cNota,cSerie,lAut,cExpSql)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	Local aParametros := {}
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Case/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "cabe็alho caso"
	Local cChvExt	:= ""
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
	cQuery := scriptSql(cNota,cSerie,lAut,cExpSql)

	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN084P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,,@aRetOk,.T.,.T.) },"Aguarde","Processando cabe็alho caso(SF)...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4( @aParametros,,,@aRetOk,.T.,.T.) },"Aguarde","Processando cabe็alho caso(SF)...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,,@aRetOk,.T.,.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,,,@aRetOk,.T.,.T. )

	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontJson  บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
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
	Local cDescri	:= ""
	
	//
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Case"', '"v41.0/sobjects/Case/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
			
			//
			If cMetodo == "POST"
			
			EndIf
	
			cJson += '"Account":{"Chave_Externa__c": "' + Alltrim(cValToChar((cNmAlias)->ZD_CODCLI)) + Alltrim(cValToChar((cNmAlias)->ZD_LOJA)) + '"},'
			cJson += '"Assunto__c":"Devolu็ใo",'
			cJson += '"ContactId":null,'
			
			//
			DbSelectArea("SZD")
			SZD->(DbSetOrder(1))
			SZD->(DbSeek( Alltrim(cValToChar((cNmAlias)->CHVSF)) ))
			cDescri := StrTran(StrTran(Alltrim(cValToChar(FwNoAccent(FwCutOff(Alltrim(cValToChar(SZD->ZD_OBSER)),.T.)))),"/",""),'"','')
		
			//cJson += '"Description":"' + cDescri + '",'
			cJson += '"Description":"",'
			cJson += '"Motivo_da_Devolucao__c":"' + Alltrim(cValToChar((cNmAlias)->ZD_DESCMOT)) + '",'
			cJson += '"Nota_Fiscal__r":{"Chave_Externa__c":"S' + cEmpAnt + Alltrim(cValToChar((cNmAlias)->ZD_FILIAL)) + Alltrim(cValToChar((cNmAlias)->ZD_CODCLI)) + Alltrim(cValToChar((cNmAlias)->ZD_LOJA)) + Alltrim(cValToChar((cNmAlias)->ZD_NUMNF)) + Alltrim(cValToChar((cNmAlias)->ZD_SERIE)) + '"},'
			cJson += '"N_Pedido__r": {"Codigo_Protheus__c":"' + Alltrim(cValToChar((cNmAlias)->ZD_PEDIDO)) + '"},'
			//cJson += '"Prazo_resposta_logistica__c":null,'
			//cJson += '"Prazo_resposta_supervisor__c":null,'
			cJson += '"RecordType":{"Name":"Layout 16"},'
			
			cJson += '"Qtde_caixa_devolvida__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_QTDEV2U)) + '",'
			cJson += '"Peso_devolvido__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_QTDE)) + '",'
			cJson += '"Volume_Total_KG__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_QTDE)) + '",'
			
			cJson += '"Tipo_de_Devolucao__c":"' + Iif( Alltrim(cValToChar((cNmAlias)->ZD_DEVTOT)) == "P","Parcial","Total") + '"'
			
		cJson += '}'

	cJson += '},'
	
Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptSql บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para consulta.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptSql(cNota,cSerie,lAut,cExpSql)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""

	//
	cQuery += " SELECT  "
	cQuery += " 'SZD' AS TABELA, " 
	cQuery += " CASE WHEN ZD_IDSF = '' OR ZD_IDSF IS NULL THEN RTRIM(LTRIM(ZD_FILIAL)) + RTRIM(LTRIM(ZD_NUMNF)) + RTRIM(LTRIM(ZD_SERIE)) ELSE ZD_IDSF END AS CHVSF, " 
	cQuery += " ZD_FILIAL, " 
	cQuery += " ZD_NUMNF, " 
	cQuery += " ZD_SERIE, " 
	cQuery += " ZD_CODCLI, " 
	cQuery += " ZD_LOJA, " 
	cQuery += " ZD_DEVTOT, " 
	cQuery += " ZD_DESCMOT, " 
	cQuery += " ZD_PEDIDO, " 
	cQuery += " ZD_OBSER, " 
	cQuery += " SZX.ZX_QTDEV2U, " 
	cQuery += " SZX.ZX_QTDE " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SZD") + " (NOLOCK) AS SZD " 
	cQuery += " INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT ZX_FILIAL, ZX_NF, ZX_SERIE, SUM(ZX_QTDE) AS ZX_QTDE, SUM(ZX_QTDEV2U) AS ZX_QTDEV2U  " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SZX") + " (NOLOCK) AS SZX  " 
	cQuery += " WHERE   " 
	cQuery += " ZX_QUEBRA = 0 " 
	cQuery += " AND SZX.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY " 
	cQuery += " ZX_FILIAL, ZX_NF, ZX_SERIE " 
	cQuery += " ) AS SZX ON " 
	cQuery += " ZD_FILIAL = SZX.ZX_FILIAL " 
	cQuery += " AND ZD_NUMNF = SZX.ZX_NF " 
	cQuery += " AND ZD_SERIE = SZX.ZX_SERIE " 
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " AS SF2 ON "
	cQuery += " ZD_FILIAL = F2_FILIAL "
	cQuery += " AND ZD_NUMNF = F2_DOC "
	cQuery += " AND ZD_SERIE = F2_SERIE "
	cQuery += " AND ZD_CODCLI = F2_CLIENTE "
	cQuery += " AND ZD_LOJA = F2_LOJA "
	cQuery += " WHERE  " 
	cQuery += " ZD_FILIAL = '" + cFilAnt + "' " 
	
	//
	If ! Empty(cNota) .And. ! Empty(cSerie)
		cQuery += " AND ZD_NUMNF = '" + cNota + "' " 
		cQuery += " AND ZD_SERIE = '" + cSerie + "' " 
	
	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
	
	EndIf
	
	cQuery += " AND ZD_DEVTOT IN ('P','T')  " 
	cQuery += " AND SZD.D_E_L_E_T_ = '' " 
	cQuery += " AND SF2.D_E_L_E_T_ = '' "
	cQuery += " AND F2_XSALES <> '' "
	cQuery += " ORDER BY  " 
	cQuery += " ZD_NUMNF, ZD_SERIE, ZD_CODCLI, ZD_LOJA " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvItens  บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
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
	Local cServTab	:= "/services/data/v41.0/sobjects/Produto_do_Caso__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "item do caso"
	Local cChvExt	:= ""
	Local aRetOk	:= {}
	
	//
	cQuery := iscriptsql(cParamBsc)
	
	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN084P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,,,@aRetOk,.F.,.T.) },"Aguarde","Processando registro(s) ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,,,@aRetOk,.F.,.T.) },"Aguarde","Processando registro(s) ...",.T.)
	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,,,@aRetOk,.F.,.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,,,@aRetOk,.F.,.T. )
		
	EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimontJson บAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
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

	//		
	cJson += '{'
		cJson += '"method" : "' + cMetodo + '",'
		cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Produto_do_Caso__c"', '"v41.0/sobjects/Produto_do_Caso__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
	
			//
			If cMetodo == "POST"
				cJson += '"Caso__c":"' + Alltrim(cValToChar((cNmAlias)->ZD_IDSF)) + '",'
				
			EndIf
			
			//cJson += '"Produto__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_CODPROD)) + '",'
			
			cJson += '"Produto__r":{"Codigo__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_CODPROD)) + '"},'
			
			cJson += '"Lote__c":null,'
			cJson += '"Data_Producao__c":null,'
			cJson += '"Validade__c":null,'
			cJson += '"Quantidade_do_Pedido__c":"' + Alltrim(cValToChar((cNmAlias)->D2_QUANT)) + '",'
			cJson += '"Quantidade_da_Reclamacao__c":"' + Alltrim(cValToChar((cNmAlias)->ZX_QTDE)) + '",'
			cJson += '"Quantidade_Bonificada__c":null,'
			cJson += '"Quantidade_da_quebra__c":null,'
			cJson += '"Unidade__c":"' + Alltrim(cValToChar((cNmAlias)->D2_UM)) + '"''

		cJson += '}'
		
	cJson += '},'
		
Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณiscriptSqlบAutor  ณEverson             บ Data ณ  02/04/2018 บฑฑ
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
	cQuery += " SELECT " 
	cQuery += " 'SZX' AS TABELA, " 
	cQuery += " CASE WHEN ZX_IDSF = '' OR ZX_IDSF IS NULL THEN RTRIM(LTRIM(ZX_FILIAL)) + RTRIM(LTRIM(ZX_NF)) + RTRIM(LTRIM(ZD_SERIE)) + RTRIM(LTRIM(ZX_CODPROD)) ELSE ZX_IDSF END AS CHVSF, "  
	cQuery += " ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, ZX_QTDE, ZX_QTDEV2U, D2_QTSEGUM, D2_QUANT, D2_QTSEGUM, D2_UM, D2_SEGUM, ZD_IDSF " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SZX") + " (NOLOCK) AS SZX  " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " ON ZX_FILIAL = D2_FILIAL " 
	cQuery += " AND ZX_NF = D2_DOC " 
	cQuery += " AND ZX_SERIE = D2_SERIE " 
	cQuery += " AND ZX_CODPROD = D2_COD "
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SZD") + " AS SZD ON "
	cQuery += " ZD_FILIAL = SZX.ZX_FILIAL " 
	cQuery += " AND ZD_NUMNF = SZX.ZX_NF " 
	cQuery += " AND ZD_SERIE = SZX.ZX_SERIE " 	 
	cQuery += " WHERE   "
	
	If Len(cParamBsc) == 18
	 
		cQuery += " ZD_IDSF = '" + cParamBsc + "' "
	
	Else
		cQuery += " RTRIM(LTRIM(ZD_FILIAL)) + RTRIM(LTRIM(ZD_NUMNF)) + RTRIM(LTRIM(ZD_SERIE)) = '" + cParamBsc + "' "
	
	EndIf
	
	cQuery += " AND ZX_QUEBRA = 0 " 
	cQuery += " AND SZX.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY " 
	cQuery += " ZX_CODPROD " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmrkReg    บAutor  ณEverson             บ Data ณ  25/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca registro.                                             บฑฑ
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
	
	//
	cId   := Alltrim(cValToChar(cId))
	cChave:= Alltrim(cValToChar(cChave))
	If Empty(cId) .Or. cMetodo <> "POST"
		Return Nil
		
	EndIf
	
	If Alltrim(cValToChar( (cAliasS)->TABELA )) == "SZD"
		
		cUpdate := " UPDATE " + RetSqlName("SZD") + " SET ZD_IDSF = '" + cId + "' WHERE RTRIM(LTRIM(ZD_FILIAL)) + RTRIM(LTRIM(ZD_NUMNF)) + RTRIM(LTRIM(ZD_SERIE)) = '" + cChave + "' AND D_E_L_E_T_ = '' "
		
		If TCSqlExec(cUpdate) < 0
		
			cMsg := "Nใo foi possํvel atualizar o registro SZD " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
			If !lAut
				MsgAlert(cMsg,"Fun็ใo mrkReg (ADVEN084P)")
				
			Else
				//Static Call(ADVEN075P,envErros,cMsg + "Fun็ใo mrkReg (ADVEN084P)")
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A2(cMsg + "Fun็ใo mrkReg (ADVEN084P)")
				
			EndIf
	
		EndIf
	
	Else

		cUpdate := " UPDATE " + RetSqlName("SZX") + " SET ZX_IDSF = '" + cId + "' WHERE RTRIM(LTRIM(ZX_FILIAL)) + RTRIM(LTRIM(ZX_NF)) + RTRIM(LTRIM(ZX_SERIE)) + RTRIM(LTRIM(ZX_CODPROD)) = '" + cChave + "' AND D_E_L_E_T_ = '' "
		
		If TCSqlExec(cUpdate) < 0
		
			cMsg := "Nใo foi possํvel atualizar o registro SZD " + cChave + Chr(13) + Chr(10) + "TCSQLError() " + TCSQLError()
			If !lAut
				MsgAlert(cMsg,"Fun็ใo mrkReg (ADVEN084P)")
				
			Else
				//Static Call(ADVEN075P,envErros,cMsg + "Fun็ใo mrkReg (ADVEN084P)")
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A2( cMsg + "Fun็ใo mrkReg (ADVEN084P)" )
				
			EndIf
	
		EndIf		
		
	EndIf
	
Return Nil
