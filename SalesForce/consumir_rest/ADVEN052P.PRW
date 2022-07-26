#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN052P      บAutor  ณEverson      บ Data ณ 22/01/2018    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de parecer ao SalesForce.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN052P(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql,aResponse) // U_ADVEN052P("190162","00",.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea   := GetArea()

	Default cCodPB3  := ""
	Default cLojaPB3 := ""
	Default lAut	 := .F.
	Default cTexto   := ""
	Default cTipo	 := ""
	Default cExpSql	 := ""
	Default aResponse:= {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de parecer ao SalesForce')
	
	//
	If ! lAut
		MsAguarde({|| Processar(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql,aResponse) },"Aguarde","Processando parecer(SF)...")

	Else
		              Processar(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql,aResponse)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar      บAutor  ณEverson      บ Data ณ  22/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql,aResponse)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aParametros := {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cServTab	:= "/services/data/v41.0/sobjects/Parecer__c/"
	Local cCmpChv	:= "CHVSF"
	Local cObjeto	:= "parecer"
	Local cChvExt	:= ""
	
	Default aResponse := {}

	//Efetura login no SalesForce.
	If Len(aResponse) <= 0
		//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    	lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)
	
		//
		If ! lLogin
			Return Nil
	
		EndIf
	
	EndIf

	//Obt้m a query.
	cQuery := scriptSql(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql)

	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN052P")
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
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{}) },"Aguarde","Processando cadastro cliente(SF)...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4(@aParametros,.F.,"POST",{}) },"Aguarde","Processando cadastro cliente(SF)...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,.F.,"POST",{})
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,.F.,"POST",{} )

	EndIf
					
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontJson     บAutor  ณEverson     บ Data ณ  22/01/2018      บฑฑ
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
	Local aArea	:= GetArea()
	Local cJson	:= ""

	cJson += '{'
	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Parecer__c"', '"v41.0/sobjects/Parecer__c/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
	cJson += '"richInput":{'
			
		//Solicita็ใo de documenta็ใo.
		If Alltrim(cValToChar((cNmAlias)->TIPO)) == "A"
	
			cJson += '"Parecer__c" : "Documenta็ใo - ' + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "' + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "P",'
			cJson += '"Lead__c" : "'    + Alltrim(cValToChar((cNmAlias)->PB3_XSALES)) + '"'	
			
		ElseIf Alltrim(cValToChar((cNmAlias)->TIPO)) == "B" //Atualiza็ใo SA1.
		
			cJson += '"Parecer__c" : " Atualiza็ใo - ' + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "' + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "A",'
			cJson += '"Conta__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
			cJson += '},'
			cJson += '"Codigo_PB3__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_COD))    + Alltrim(cValToChar((cNmAlias)->PB3_LOJA))   + '",'
			cJson += '"Codigo_SA1__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'		
				
		//Json para novo cliente rejeitado.
		ElseIf Alltrim(cValToChar((cNmAlias)->TIPO)) == "C" .And. !Empty(Alltrim(cValToChar((cNmAlias)->PB3_XSALES))) .And. Substr(Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)),1,2) $("01|06") .And.;
		Empty((cNmAlias)->PB3_CODSA1) .And.;
		Empty((cNmAlias)->PB3_LOJSA1)
	
			cJson += '"Parecer__c" : "Rejei็ใo de Pr้-cadastro - ' + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "' + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "R",'
			cJson += '"Lead__c" : "'    + Alltrim(cValToChar((cNmAlias)->PB3_XSALES)) + '"'	
	
		//Json para novo cliente aprovado (necessแrio primeiro enviar o cadastro do cliente - Account).
		ElseIf Alltrim(cValToChar((cNmAlias)->TIPO)) == "D" .And. !Empty(Alltrim(cValToChar((cNmAlias)->PB3_XSALES))) .And. Substr(Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)),1,2) $("01|06") .and.;
			Empty((cNmAlias)->PB3_CODSA1) .And.;
			Empty((cNmAlias)->PB3_LOJSA1)

	
			cJson += '"Parecer__c" : "Aprova็ใo de Pr้-cadastro - ' + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "'  + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "A",'
			cJson += '"Lead__c" : "'     + Alltrim(cValToChar((cNmAlias)->PB3_XSALES)) + '",'
			cJson += '"Conta__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
			cJson += '},'
			cJson += '"Codigo_PB3__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_COD))    + Alltrim(cValToChar((cNmAlias)->PB3_LOJA))   + '",'
			cJson += '"Codigo_SA1__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
	
		//Inser็ใo de parecer para solicita็ใo de atualiza็ใo reprovada.
		ElseIf Alltrim(cValToChar((cNmAlias)->TIPO)) == "C" .And. !(Substr(Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)),1,2) $("01|06")) .And. Alltrim(cValToChar((cNmAlias)->PB3_SITUAC)) == "3" .And.;
		!Empty((cNmAlias)->PB3_CODSA1) .And.;
		!Empty((cNmAlias)->PB3_LOJSA1)

			cJson += '"Parecer__c" : "Atualiza็ใo Rejeitada - ' + Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)) + " - " + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "' + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "R",'
			cJson += '"Conta__r" : {'
			cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
			cJson += '},'
			cJson += '"Codigo_PB3__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_COD))    + Alltrim(cValToChar((cNmAlias)->PB3_LOJA))   + '",'
			cJson += '"Codigo_SA1__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
	
		//Inser็ใo de parecer para solicita็ใo de atualiza็ใo de cliente aprovado.
		ElseIf Alltrim(cValToChar((cNmAlias)->TIPO)) == "D" .And. !(Substr(Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)),1,2) $("01|06")) .And. Alltrim(cValToChar((cNmAlias)->PB3_SITUAC)) == "".And.;
		!Empty((cNmAlias)->PB3_CODSA1) .And.;
		!Empty((cNmAlias)->PB3_LOJSA1)
	
			cJson += '"Parecer__c" : " Atualiza็ใo - ' + Alltrim(cValToChar((cNmAlias)->PB3_MOTACE)) + Alltrim(cValToChar((cNmAlias)->TEXTO)) + '",'
			cJson += '"Usuario__c" : "' + Upper(Alltrim(cUserName)) + '",'
			cJson += '"Status__c" : "A",'
			cJson += '"Conta__r" : {'
				cJson += '"Chave_Externa__c" : "' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
			cJson += '},'
			cJson += '"Codigo_PB3__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_COD))    + Alltrim(cValToChar((cNmAlias)->PB3_LOJA))   + '",'
			cJson += '"Codigo_SA1__c":"' + Alltrim(cValToChar((cNmAlias)->PB3_CODSA1)) + Alltrim(cValToChar((cNmAlias)->PB3_LOJSA1)) + '"'
			
		EndIf
	
		cJson += '}'
	cJson += '},'
	
	//
	RestArea(aArea)

Return cJson
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptSql       บAutor  ณEverson     บ Data ณ  22/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptSql(cCodPB3,cLojaPB3,lAut,cTexto,cTipo,cExpSql)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""

	//
	cQuery := ""
	cQuery += " SELECT PB3_XSALES AS CHVSF, '" + cTexto + "' AS TEXTO, '" + cTipo + "' AS TIPO, "
	cQuery += " PB3_COD, PB3_LOJA, PB3_SITUAC, PB3_SITUAC, PB3_CODSA1, PB3_LOJSA1, PB3_MOTACE, PB3_XSALES, PB3_XCASO "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS PB3 "
	cQuery += " WHERE "
	cQuery += " PB3.D_E_L_E_T_ = '' "
	
	If !Empty(cCodPB3) .And. !Empty(cLojaPB3)
		cQuery += " AND PB3_COD  = '" + cCodPB3 + "' "
		cQuery += " AND PB3_LOJA = '" + cLojaPB3 + "' "
	
	EndIf
	
	//
	If !Empty(cExpSql)
		cQuery += cExpSql
		
	EndIF

Return cQuery
