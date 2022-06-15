#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN069P บAutor  ณEverson             บ Data ณ  03/01/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de cadastro de produtos ao SalesForce.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//U_ADVEN069P("",.F.," AND B1_TS IN ('501') ")
User Function ADVEN069P(cParamBsc,lAut,cExpSql,cAltTes) // U_ADVEN069P("",.F.)  U_ADVEN069P("",.F.," AND B1_COD IN ('124346','192959') ")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea   	:= GetArea()
	
	Default cParamBsc := ""
	Default lAut	  := .F.
	Default cExpSql	  := ""
	Default cAltTes	  := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para envio de cadastro de produtos ao SalesForce')
	
	//
	If ! lAut
		MsAguarde({|| Processar(cParamBsc,lAut,cExpSql,cAltTes) },"Aguarde","Enviando registros(SF)...")
	
	Else
		Processar(cParamBsc,lAut,cExpSql,cAltTes)
		
	EndIf

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar      บAutor  ณEverson      บ Data ณ  05/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(cParamBsc,lAut,cExpSql,cAltTes)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aParametros := {}
	Local aResponse	  := {}
	Local lLogin	  := .F.
	Local cQuery	  := ""
	Local cServTab	  := "/services/data/v41.0/sobjects/Product2/"
	Local cCmpChv	  := "CHVSF"
	Local cObjeto	  := "produto"
	Local cChvExt	  := "Codigo__c/"
	Local aRetOk	  := {}
	Local i			  := ""
	Local cChvTab	  := ""
	Local cMsgParam	  := "Fun็ใo ADVEN069P"
	Local cErroItem	  := ""
	Local cMsg		  := ""

	//Efetura login no SalesForce.
	//lLogin := Static Call(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    lLogin := u_VEN075A1(@aResponse,@cMsg,lAut)

	//
	If ! lLogin
		Return Nil

	EndIf
	
	//Obt้m Id da tabela de pre็o padrใo.
	If ! chkTabPrd(aResponse,@cChvTab,cMsgParam)
		Return Nil
		
	EndIf

	//Obt้m a query.
	cQuery := scriptSql(cParamBsc,cExpSql,cAltTes)

	//Adiciona parโmetros ao vetor.
	Aadd(aParametros,aResponse)
	Aadd(aParametros,"ADVEN069P")
	Aadd(aParametros,cQuery)
	Aadd(aParametros,lAut)
	Aadd(aParametros,cServTab)
	Aadd(aParametros,cCmpChv)
	Aadd(aParametros,cObjeto)
	Aadd(aParametros,"montJson")
	Aadd(aParametros,cChvExt)
	Aadd(aParametros,.T.)

	//Processa os registros.
	If  ! lAut
		//Processa({|| Static Call(ADVEN075P,ProcessarB,@aParametros,.T.,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) ...",.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		Processa({|| u_VEN075A4( @aParametros,.T.,"",@aRetOk,.F.,.T.,"",.T.,.F.) },"Aguarde","Processando registro(s) ...",.T.)

	Else
		//Static Call(ADVEN075P,ProcessarB,@aParametros,.T.,"",@aRetOk,.F.,.T.,"",.T.,.F.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A4( @aParametros,.T.,"",@aRetOk,.F.,.T.,"",.T.,.F. )

	EndIf
	
	//Processa o envio do cadastro do produto na tabela de pre็o padrใo.
	For i := 1 To Len(aRetOk)
		
		// *** INICIO WILLIAM COSTA 12/09/2019 - CHAMADO 051422 || OS 052752 || ADM. || VAGNER || 8469 || CARGA PRODUTOS - RETIRADO IF POIS ESTAVA GERANDO ERRO NO ENVIO DE PRODUTOS EM LOTE PARA O SALES FORCE
		//If Alltrim(cValToChar(aRetOk[i][3])) == "OK" //.And. Alltrim(cValToChar(aRetOk[i][1])) == "POST"
			
			MsAguarde({|| envItens( Alltrim(cValToChar(aRetOk[i][2])) ,lAut,cChvTab,aResponse,Alltrim(cValToChar(aRetOk[i][1])), @cErroItem ) },"Aguarde ","Tabela padrใo Prd " + Alltrim(cValToChar(aRetOk[i][2])))
		
		//EndIf
		// *** FINAL WILLIAM COSTA 12/09/2019 - CHAMADO 051422 || OS 052752 || ADM. || VAGNER || 8469 || CARGA PRODUTOS - RETIRADO IF POIS ESTAVA GERANDO ERRO NO ENVIO DE PRODUTOS EM LOTE PARA O SALES FORCE
	Next i
	
	//
	If !Empty(cErroItem) .And. !lAut
		
		//Static Call(ADVEN075P,TelErro,"Envio SalesForce - ADVEN069P ",cErroItem,"Arial",10,,.F.,.T.)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A5("Envio SalesForce - ADVEN069P ",cErroItem,"Arial",10,,.F.,.T.)

	ElseIf !Empty(cErroItem) .And. lAut
		//Static Call(ADVEN075P,envErros,cErroItem)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A2( cErroItem )

	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkTabPrd     บAutor  ณEverson    บ Data ณ  09/01/2018      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObt้m o Id da tabela de pre็o padrใo.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkTabPrd(aResponse,cChvTab,cMsgParam)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cSrvTabPdr := "/services/data/v41.0/query?q=SELECT+Id+from+Pricebook2+where+isstandard=true+limit+1"
	Local cMsg	     := ""
	Local oParseJSON :=  Nil
	
	//
	If ! U_ADVEN075P(cSrvTabPdr,"GET","",@cMsg,aResponse)
		MsgStop("Ocorreu erro na consulta tabela de pre็o padrใo no SalesForce." + Chr(13) + Chr(10) + cMsg,cMsgParam)
		Return .F.
	
	EndIf
	
	//Converte a string json em objeto.
	If ! FWJsonDeserialize(cMsg, @oParseJSON)
		MsgStop("Ocorreu erro na desserializa็ใo do json (tabela de pre็o padrใo).",cMsgParam)
		Return .F.

	EndIf

	//Obt้m o Id da tabela de pre็o padrใo.
	cChvTab := Alltrim(cValToChar(oParseJSON:records[1]:Id))
	
	//
	FreeObj(oParseJSON)
	oParseJSON := Nil
	
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmontJson     บAutor  ณEverson     บ Data ณ  05/01/2018      บฑฑ
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
	
	cJson += '{'

	cJson += '"method" : "' + cMetodo + '",'
	cJson += '"url" : ' + Iif(cMetodo == "POST",'"v41.0/sobjects/Product2"', '"v41.0/sobjects/Product2/' + cChvExt +  Alltrim(cValtoChar((cNmAlias)->CHVSF)) + '"') + ','
		cJson += '"richInput":{'
	
			If cMetodo == "POST"
				cJson += '"Codigo__c" : "' + StrTran(StrTran(Alltrim(cValToChar((cNmAlias)->B1_COD)),'"',""),"'","") + '",' 
			
			EndIf
			
			//	
			cJson += '"StockKeepingUnit":"' + Alltrim(cValToChar((cNmAlias)->B1_COD)) + '",'			
			cJson += '"ProductCode":"' + Alltrim(cValToChar((cNmAlias)->B1_COD)) + '",'
			cJson += '"Name":"' + StrTran(Alltrim(cValToChar((cNmAlias)->B1_DESC)),'"'," ") + '",'
			cJson += '"Description":"' + StrTran(Alltrim(cValToChar((cNmAlias)->B1_DESC)),'"'," ") + '",'
			cJson += '"Codigo_Barras__c":"' + Alltrim(cValToChar((cNmAlias)->B1_CODBAR)) + '",'
			cJson += '"Classificacao_NCM__c":"' + Alltrim(cValToChar((cNmAlias)->B1_POSIPI)) + '",'
			cJson += '"ICMS__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PICM)) + '",'
			cJson += '"Possui_ST__c":"' + Iif(Val(cValToChar((cNmAlias)->B1_PICMRET)) > 0,"S","N") + '",'
			cJson += '"ST__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PICMRET)) + '",'
			cJson += '"PIS_PCT__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PPIS)) + '",'
			cJson += '"CONFINS_PCT__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PCOFINS)) + '",'
			cJson += '"IPI_Nota__c":"' + Iif(Val(cValToChar((cNmAlias)->B1_IPI)) > 0,"S","N") + '",'
			cJson += '"IPI__c":"' + Alltrim(cValToChar((cNmAlias)->B1_IPI)) + '",'
			cJson += '"Possui_Reducao_Calculo__c":"' + Iif(Val(cValToChar((cNmAlias)->F4_BASEICM)) > 0,"S","N") + '",'
			cJson += '"Reducao_Calculo_PCT__c":"' + Alltrim(cValToChar((cNmAlias)->F4_BASEICM)) + '",'
			cJson += '"ST_Nota__c":"' + Iif( Val(cValToChar((cNmAlias)->B1_PICMRET)) > 0,"S","N") + '",'
			cJson += '"Fator_Conversao__c":"' + Alltrim(cValToChar((cNmAlias)->B1_CONV)) + '",'
			cJson += '"Unidade__c":"' + Alltrim(cValToChar((cNmAlias)->B1_UM)) + '",'
			cJson += '"Tipo_Conversao__c":"' + Alltrim(cValToChar((cNmAlias)->B1_TIPCONV)) + '",'
			cJson += '"Segunda_Unidade__c":"' + Alltrim(cValToChar((cNmAlias)->B1_SEGUM)) + '",'
			cJson += '"IsActive": ' + Iif( Alltrim(cValToChar((cNmAlias)->B1_MSBLQL)) == "2",'true','false') +  ','	
			
			cJson += '"Peso_Bruto__c":"' + cValToChar(Val(cValToChar((cNmAlias)->B1_CONV)) + Val(cValToChar((cNmAlias)->ZC_TARA))) + '",'
			cJson += '"Peso_Liquido__c":"' + Alltrim(cValToChar((cNmAlias)->B1_CONV)) + '",'
			cJson += '"Peso_Embalagem__c":"' + Alltrim(cValToChar((cNmAlias)->ZC_TARA)) + '",'
			
			cJson += '"Paletizacao_Lastro__c":"' + Alltrim(cValToChar((cNmAlias)->B1_XALTLAS))   + '",'
			cJson += '"Paletizacao_Altura__c":"' + Alltrim(cValToChar((cNmAlias)->B1_XALTUR))   + '",'
			cJson += '"Dias_de_validade__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PRVALID))   + '",'
			
			cJson += '"Codigo_Grupo__c":"' + Alltrim(cValToChar((cNmAlias)->BM_GRUPO)) + '",'
			cJson += '"Grupo__c":"' + Alltrim(cValToChar((cNmAlias)->BM_DESC)) + '",'
			cJson += '"Grupo_Relacionado__c":"' + Alltrim(cValToChar((cNmAlias)->BM_GRUREL)) + '",'
			
			cJson += '"Quebra_de_Nivel__c":"' + Alltrim(cValToChar((cNmAlias)->BM_QBRNVL)) + '",'
			cJson += '"IPI_Pauta__c":"' + Alltrim(cValToChar((cNmAlias)->B1_VLR_IPI)) + '",'
			cJson += '"IVA_ST__c":"' + Alltrim(cValToChar((cNmAlias)->B1_PICMRET)) + '"'
			
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
Static Function scriptSql(cParamBsc,cExpSql,cAltTes)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery := ""	

	//
	cParamBsc := Alltrim(cValToChar(cParamBsc))
	cExpSql	  := Alltrim(cValToChar(cExpSql))
	
	//
	cQuery := ""
	cQuery += " SELECT   " 
	cQuery += " RTRIM(LTRIM(B1_COD)) AS CHVSF, RTRIM(LTRIM(B1_COD)) AS B1_COD, B1_DESC, B1_CODBAR, B1_POSIPI, B1_PICM,  " 
	cQuery += " B1_PICMRET, B1_PPIS, B1_PCOFINS, B1_VLR_IPI, B1_IPI, F4_BASEICM, B1_CONV, " 
	cQuery += " B1_XALTLAS, B1_XALTUR, B1_UM, B1_TIPCONV, B1_SEGUM, B1_MSBLQL, BM_GRUPO, BM_DESC, BM_GRUREL, ZC_TARA, BM_QBRNVL, B1_PRVALID, B1_XIDSF AS IDSALES " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("SB1") + "  (NOLOCK) AS SB1   " 
	cQuery += " LEFT OUTER JOIN  " 
	cQuery += " " + RetSqlName("SBM") + "  (NOLOCK) AS SBM  " 
	cQuery += " ON B1_GRUPO = BM_GRUPO  " 
	cQuery += " AND SBM.D_E_L_E_T_ = ''   " 
	cQuery += " LEFT OUTER JOIN  " 
	cQuery += " " + RetSqlName("SF4") + " (NOLOCK) AS SF4  " 
	cQuery += " ON B1_TS = F4_CODIGO  " 
	cQuery += " AND SF4.D_E_L_E_T_ = ''   " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " " + RetSqlName("SZC") + " (NOLOCK) AS SZC " 
	cQuery += " ON B1_SEGUM = ZC_UNIDADE " 
	cQuery += " WHERE   " 
	cQuery += " SB1.D_E_L_E_T_ = ''   " 
	cQuery += " AND SUBSTRING(B1_COD,1,1) <> '' " 
	cQuery += " AND B1_XSALES = '2' "

	//
	If ! Empty(cParamBsc)
		cQuery += " AND B1_COD = '" + cParamBsc + "' " 

	EndIf
	
	//
	If ! Empty(cExpSql)
		cQuery += cExpSql
	
	Endif
	
	//
	If ! Empty(cAltTes)
		cQuery += "AND B1_TS = '" + cAltTes + "' "
	
	Endif

	//
	cQuery += " ORDER BY B1_GRUPO, B1_COD "
	
Return cQuery
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
Static Function envItens(cParamBsc,lAut,cChvTab,aResponse,cMtdCab,cErroItem)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cResJson	:= ""
	Local cServTab  := "/services/data/v41.0/sobjects/PricebookEntry/"
	Local cMsg		:= ""
	
	//Obt้m o c๓digo do produto.
	cParamBsc := Alltrim(cValToChar(cParamBsc))

	//
	cResJson += '{'
		cResJson += '"Product2" : {'
		cResJson += '	"Codigo__c" : "' + cParamBsc + '"'
		cResJson += '},'
		cResJson += '"Pricebook2Id" : "' + cChvTab + '",'
		cResJson += '"IsActive" : true,'
		cResJson += '"UnitPrice" : "0"'
	cResJson += '}'
	
	//Executa a inclusใo do produto na tabela de pre็o padrใo.
	If ! U_ADVEN075P(cServTab,"POST",cResJson,@cMsg,aResponse)
		
		If !("DUPLICATE_VALUE" $cMsg) .And. !("DUPLICATE VALUE" $cMsg)//Se nใo for erro de valor duplicado. Tabela padrใo ้ necessแria apenas para o SalesForce. Nใo ้ utilizada.
			cErroItem += "Ocorreu erro na inser็ใo produto tabela de pre็o padrใo produto " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg + Chr(13) + Chr(10) + "------------------------"
		
		EndIf
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmrkReg        บAutor  ณEverson      บ Data ณ  20/03/2018    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca registro.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function mrkReg(cProduto,lAut,cId,cMetodo,aResponse,cAliasS)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	     := GetArea()
	
	//
	cId := Alltrim(cValToChar(cId))

	//
	If Empty(cId)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Grava o c๓digo do SalesForce.
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If SB1->(DbSeek(xFilial("SB1") + cProduto))
		
		//
		If Empty(Alltrim(cValToChar(SB1->B1_XIDSF)))
		
			RecLock("SB1",.F.)
				SB1->B1_XIDSF := Alltrim(cValToChar(cId))
			MsUnlock()
			
		EndIf
		
	EndIf
	SB1->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return Nil
