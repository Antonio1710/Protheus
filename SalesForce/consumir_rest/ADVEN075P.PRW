#Include 'Totvs.ch'
#Include 'Topconn.ch'
#Include "ParmType.ch"
#Include 'AP5mail.ch'

//Estrutura de arquivo
#DEFINE POS_CMP		1
#DEFINE POS_TIP		2
#DEFINE POS_TAM		3
#DEFINE POS_DEC		4

#DEFINE nTAMSX1H		35	//Tamanho da descricao help SX1

Static nEsqCont			:= 001
Static nAltCont			:= 009
Static nDistPad			:= 002
Static nAltBot			:= 013
Static nDistAPad		:= 004
Static nDistEtq			:= 001
Static nAltEtq			:= 007
Static nLargEtq			:= 035 
Static nLargBot			:= 040
Static cHK				:= "&"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN075P      บAutor  ณEverson      บ Data ณ  28/12/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para enviar requisi็๕es ao SalesForce.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN075P(cServico,cMetodo,cBody,cMsg,aResponse) // U_ADVEN075P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local aCabecalho	:= {}
	Local cUrl			:= ""
	Local oRestClient 	:= Nil
	Local oParseJSON	:= Nil
	Local lRest			:= .F.
	Local lLogin		:= .F.

	Default cServico	:= ""
	Default cMetodo		:= ""
	Default cBody		:= ""
	Default cMsg		:= ""
	Default aResponse	:= {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para enviar requisi็๕es ao SalesForce')

	//Efetura login no SalesForce.
	If Len(aResponse) == 0
		lLogin := loginSF(@aResponse,@cMsg,.F.)

		//
		If ! lLogin
			Return Nil

		EndIf

		cMsg := ""

	EndIf

	//Obt้m cabecalho para envio de requisi็๕es.
	aCabecalho := aResponse[1][1]

	//Obt้m url.
	cUrl := aResponse[1][2]

	//Adiciona o end-point ao cliente Rest.
	oRestClient := FWRest():New(cUrl)

	//Adiciona o caminho ao cliente Rest.
	If cMetodo == "PATCH"
		cServico += "?_HttpMethod=PATCH"
		cMetodo  := "POST"

	EndIf
	
	oRestClient:setPath(cServico)
	
	//Adiciona parโmetros ao corpo da requisi็ใo.
	cBody := StrTran(cBody,Chr(129),"")
	cBody := StrTran(cBody,Chr(141),"")
	cBody := StrTran(cBody,Chr(143),"")
	cBody := StrTran(cBody,Chr(144),"")
	cBody := StrTran(cBody,Chr(157),"")
	
	cBody := FwCutOff(cBody,.F.)
	cBody := EncodeUtf8(cBody)
	oRestClient:SetPostParams(cBody)
	
	//Realiza requisi็ใo ao servi็o.
	lRest := &("oRestClient:" + cMetodo + "(aCabecalho)")

	//
	cMsg := ""
	If ! lRest

		If Substr(Alltrim(cValToChar(oRestClient:GetLastError())),1,1) <> "2" //.And.;
			//(cMetodo == "GET" .And. Alltrim(cValToChar(oRestClient:GetLastError())) <> "300")

			cMsg := Alltrim(cValToChar(oRestClient:GetLastError())) + Chr(13) + Chr(10)
			cMsg += "Headers: " + Chr(13) + Chr(10) + "1 " + cValToChar(aCabecalho[1]) + Chr(13) + Chr(10) + "2 " + cValToChar(aCabecalho[2]) + Chr(13) + Chr(10)
			cMsg += "URL: " + cUrl + Chr(13) + Chr(10)
			cMsg += "EndPoint: " + cServico + Chr(13) + Chr(10)
			cMsg += "M้todo: " + cMetodo + Chr(13) + Chr(10)
			cMsg += "Body: " + Chr(13) + Chr(10) + cValToChar(cBody) + Chr(13) + Chr(10)
			cMsg += "Resp: " + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetResult())) + Chr(13) + Chr(10)

			lRet := .F.

		EndIf

	EndIf
	
	//Converte a string json em objeto.
	If lRet .And. ! Empty(Alltrim(cValToChar(oRestClient:GetResult())))
		If ! FWJsonDeserialize(oRestClient:GetResult(), @oParseJSON)
			cMsg := "Ocorreu erro na desserializa็ใo do json com os dados de inclusใo/altera็ใo do recurso (ADVEN075P ADVEN075P)." + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetResult()))
			lRet := .F.

		Else

			cMsg := Alltrim(cValToChar(oRestClient:GetResult()))

		EndIf

	EndIf

	//
	FreeObj(oRestClient)
	oRestClient := Nil
	FreeObj(oParseJSON)
	oParseJSON	:= Nil
	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณloginSF        บAutor  ณEverson      บ Data ณ  28/12/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para efetuar login no sistema SalesForce.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function loginSF(aResponse,cMsg,lAut)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea			:= GetArea()
	Local cUrl			:= ""
	Local cClientId		:= ""
	Local cClientSec	:= ""
	Local cUsuario		:= ""
	Local cToken		:= ""
	Local cPassword		:= ""
	Local cPath			:= ""
	Local aHeadStr	  	:= {}
	Local oRestClient 	:= ""
	Local cBody			:= ""
	Local oParseJSON	:= ""
	Local cContentType	:= ""
	Local cUrlDest		:= ""
	Local cExcInt		:= ""
	
	//
	If cEmpAnt <> "01"
		
		RestArea(aArea)
		Return .F.
		
	EndIf

	//
	cUrl			:= Alltrim(cValToChar( GetMv("MV_#SFURL") ))
	cClientId		:= Alltrim(cValToChar( GetMv("MV_#SFCID") ))
	cClientSec		:= Alltrim(cValToChar( GetMv("MV_#SFCSE") ))
	cUsuario		:= Alltrim(cValToChar( GetMv("MV_#SFUSR") ))
	cToken			:= Alltrim(cValToChar( GetMv("MV_#SFTKN") ))
	cPassword		:= Alltrim(cValToChar( GetMv("MV_#SFSHN") )) + cToken
	cPath			:= "/services/oauth2/token?grant_type=password&client_id=" + cClientId + "&client_secret=" + cClientSec + "&username=" + cUsuario + "&password=" + cPassword
	aHeadStr	  	:= {}
	oRestClient 	:= Nil
	cBody			:= ""
	oParseJSON		:= Nil
	cContentType	:= 'application/json'
	cUrlDest		:= ""
	cExcInt			:= Upper(Alltrim(cValToChar( GetMv("MV_#SFEXIN") )))
	
	//
	If cExcInt <> "S"
		
		RestArea(aArea)
		Return .F.
			
	EndIf

	//Adiciona o end-point ao cliente Rest.
	oRestClient := FWRest():New(cUrl)

	//Adiciona o caminho ao cliente Rest.
	oRestClient:setPath(cPath)

	//Realiza a chamada post e verifica se houve erro.
	If ! oRestClient:Post({})

		cMsg := "Ocorre um erro ao tentar efetuar login no SalesForce (loginSF ADVEN075P)." + Chr(13) + Chr(10) + Alltrim(cValToChar(oRestClient:GetLastError()))
		If ! lAut
			MsgStop(cMsg,"Fun็ใo loginSF")
			envErros(cMsg)

		Else
			envErros(cMsg)

		EndIf

		FreeObj(oRestClient)
		oRestClient := Nil
		RestArea(aArea)
		Return .F.

	EndIf

	//Obt้m a string json.
	cBody := Alltrim(cValToChar(oRestClient:GetResult()))

	//Converte a string json em objeto.
	If ! FWJsonDeserialize(cBody, @oParseJSON)

		cMsg := "Ocorreu erro na desserializa็ใo do json com os dados de login (loginSF ADVEN075P)."
		If ! lAut
			MsgStop(cMsg,"Fun็ใo loginSF")
			envErros(cMsg)

		Else
			envErros(cMsg)

		EndIf

		FreeObj(oRestClient)
		oRestClient := Nil
		RestArea(aArea)
		Return .F.

	EndIf

	//Monta cabe็alho para envio de requisi็๕es.
	Aadd(aHeadStr,'Authorization:' + Alltrim(cValToChar(oParseJSON:token_type)) + ' ' + Alltrim(cValToChar(oParseJSON:access_token)) )
	Aadd(aHeadStr,'Content-Type:' + cContentType )

	//Obt้m url.
	cUrlDest := Alltrim(cValToChar(oParseJSON:instance_url))

	//Preenche vetor de resposta da fun็ใo.
	Aadd(aResponse,{;
	aHeadStr ,; //Cabe็alho para efetuar requisi็๕es no servi็o.
	cUrlDest  ;
	})

	//
	FreeObj(oRestClient)
	oRestClient := Nil
	FreeObj(oParseJSON)
	oParseJSON	:= Nil

Return .T.
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
Static Function Processar(aParametros,aRetOk,cChvTab,aResponse,lChkGet,cOperEx,lMrcReg)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea   	:= GetArea()
	Local cMsg		:= ""	
	Local nTotReg	:= 0
	Local nAux		:= 0
	Local cOper		:= ""
	Local cResJson	:= ""
	Local cNovaQry1 := ""

	Local cFuncao	:= aParametros[1]
	Local lAut		:= aParametros[2]
	Local cQuery	:= aParametros[3]
	//Local cCampo	:= aParametros[4]
	Local cFunJson	:= aParametros[5]
	Local cMsgFunc	:= aParametros[6]
	Local cServico	:= aParametros[7]
	Local cChvExt	:= aParametros[8]
	//Local cMsgParam	:= aParametros[9]
	Local cParamBsc	:= aParametros[10]
	Local cAliasTab	:= aParametros[11]
	Local nIndAlias	:= aParametros[12]
	Local lEnvItem	:= aParametros[13]

	Default aRetOk	:= {}
	Default cChvTab	:= ""
	Default lChkGet	:= .T.
	Default cOperEx	:= "PATCH"
	Default lMrcReg	:= .F.

	//
	cNovaQry1 := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNovaQry1,.T.,.T.)
	DbSelectArea(cNovaQry1)
	(cNovaQry1)->(DbGoTop())

	//
	If ! lAut
		nTotReg := Contar(cNovaQry1,"!Eof()")
		ProcRegua(nTotReg)
		(cNovaQry1)->(DbGoTop())

	EndIf

	//
	While ! (cNovaQry1)->(Eof())

		//
		cParamBsc := (cNovaQry1)->CHVSF

		//
		If ! lAut
			nAux++
			IncProc(cMsgFunc + " " + cParamBsc + " | " + cValToChar(nAux) + "/" + cValToChar(nTotReg) ) 

		EndIf

		//
		If lChkGet

			If ! U_ADVEN075P(cServico + cChvExt + cParamBsc,"GET",cResJson,@cMsg,aResponse)

				//
				cMsg :=  Alltrim(cValToChar(cMsg))
				If "NOT_FOUND" $cMsg .Or. "404 NotFound" $cMsg  //Registro nใo encontrado no SalesForce.
					cOper := "POST"

				Else

					If ! lAut
						MsgStop("Ocorreu erro na consulta "  + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg,"Processar (ADVEN075P)")
						envErros("Ocorreu erro na consulta " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)
						
					Else
						envErros("Ocorreu erro na consulta " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)

					EndIf

					(cNovaQry1)->(DbSkip())
					Loop			

				EndIf

			Else

				Aadd(aRetOk,{"C",cParamBsc})
				cOper := "PATCH" // Registro encontrado no SalesForce.

			EndIf

		Else

			cOper := cOperEx

		EndIf

		//
		If cOper == "POST" //Inser็ใo de registro no SalesForce.

			cResJson :=  &("StaticCall(" + cFuncao + "," + cFunJson + ",'" + cParamBsc + "',1,'" + cAliasTab + "'," + cValToChar(nIndAlias) + ",'" + cNovaQry1 + "',aResponse)")
			If ! U_ADVEN075P(cServico,"POST",cResJson,@cMsg,aResponse)

				If ! lAut
					MsgStop("Ocorreu erro na inser็ใo " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg,"Processar (ADVEN075P)")
					envErros("Ocorreu erro na inser็ใo " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)
					
				Else
					envErros("Ocorreu erro na inser็ใo " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)

				EndIf

				(cNovaQry1)->(DbSkip())
				Loop

			Else

				//
				If lEnvItem 
					cResJson :=  &("StaticCall(" + cFuncao + ",envItens,'" + cParamBsc + "'," + cValToChar(lAut) + ",'" + cChvTab + "',aResponse,'POST')")

				EndIf

				Aadd(aRetOk,{"I",cParamBsc})

				//Marca registro no Protheus como jแ enviado.
				If lMrcReg
					cResJson :=   &( "StaticCall(" + cFuncao + ",mrkReg,'" + cParamBsc + "," + cValToChar(lAut) + ")" )

				EndIf

			EndIf

		ElseIf cOper == "PATCH" //Altera็ใo de registro no SalesForce.

			cResJson := &("StaticCall(" + cFuncao + "," + cFunJson + ",'" + cParamBsc + "',2,'" + cAliasTab + "'," + cValToChar(nIndAlias) + ",'" + cNovaQry1 + "',aResponse)")

			If ! U_ADVEN075P(cServico + cChvExt + cParamBsc,"PATCH",cResJson,@cMsg,aResponse)

				If ! lAut
					MsgStop("Ocorreu erro na altera็ใo "  + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg, "Processar (ADVEN075P)" )
					envErros("Ocorreu erro na altera็ใo " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)
					
				Else
					envErros("Ocorreu erro na altera็ใo " + cMsgFunc + " " + cValToChar(cParamBsc) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)

				EndIf

				(cNovaQry1)->(DbSkip())
				Loop	

			Else

				//Envia itens.
				If lEnvItem

					cResJson :=  &("StaticCall(" + cFuncao + ",envItens,'" + cParamBsc + "'," + cValToChar(lAut) + ",'" + cChvTab + "',aResponse,'PATCH')")

				EndIf

				Aadd(aRetOk,{"A",cParamBsc})

				//Marca registro no Protheus como jแ enviado.
				If lMrcReg
					cResJson :=   &( "StaticCall(" + cFuncao + ",mrkReg,'" + cParamBsc + "'," + cValToChar(lAut) + ")" )

				EndIf

			EndIf

		Else

			If ! lAut
				MsgStop("Erro na opera็ใo (" + cOper + ").","Processar (ADVEN075P)")
				envErros("Erro na opera็ใo (" + cOper + ")." + "Processar (ADVEN075P)")
				
			Else
				envErros("Erro na opera็ใo (" + cOper + ")." + "Processar (ADVEN075P)")

			EndIf

			(cNovaQry1)->(DbSkip())
			Loop	

		EndIf

		//
		(cNovaQry1)->(DbSkip())

	EndDo
	
	//
	(cNovaQry1)->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessarB     บAutor  ณEverson      บ Data ณ  13/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios em lote.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcessarB(aParametros,lChkGet,cOperEx,aRetOk,lItem,lMrcReg,cChvTab,lChkId,lItemLot,lAtuPed)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cFuncao	 := aParametros[2]
	Local cQuery	 := Alltrim(cValToChar(aParametros[3]))
	Local lAut	     := aParametros[4]
	Local cServTab   := aParametros[5]
	local cCmpChv	 := aParametros[6]
	Local cObjeto	 := aParametros[7]
	Local cFunJson	 := aParametros[8]
	Local cChvExt	 := aParametros[9]
	Local lObtRet	 := aParametros[10]
	Local cUrl  	 := "/services/data/v41.0/composite/batch/"
	Local cChavePar	 := ""
	Local nAux		 := 0
	Local nTotReg	 := 0
	Local cMsg		 := ""
	Local lRet		 := .T.
	Local cMetodo	 := ""
	Local cErros	 := ""
	Local cResJson	 := ""
	Local nCount	 := 0
	Local xPula		 := Chr(13) + Chr(10) + "-------------------------------------------------------------" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	Local nRegErro	 := 0
	Local cJsonRet	 := ""
	Local oParseJSON := Nil
	Local cNovaQuery := ""
	Local nTamVariav := Val(GetPvProfString("GENERAL","MAXSTRINGSIZE","1",GetADV97()))
	Local nWP		 := ""
	Local cGrpCli	 := ""
	Local nAuxTot	 := 0
	Local nTamLotEnv := 25

	Private aResponse  := aParametros[1]

	//
	Default lChkGet	 := .T.
	Default cOperEx	 := "POST"
	Default	lItem	 := .F.
	Default lMrcReg	 := .F.
	Default cChvTab	 := ""
	Default lChkId	 := .F.
	Default lItemLot := .F.
	Default lAtuPed  := .F.
	
	//
/*	If Alltrim(cValToChar(cFuncao)) == "ADVEN050P"
		nTamLotEnv := 1
		
	Else
		nTamLotEnv := 25
	
	EndIf*/
	
	//
	Conout(">>>>>>>>>>>>>> Tamanho do lote a ser processado " + cValToChar(nTamLotEnv))

	//
	If Empty(cQuery)
		cErros := " Fun็ใo ProcessarB(ADVEN075P) nใo recebeu a query de itens / " + cFuncao + " / " + cObjeto
		If ! lAut
			TelErro("Envio SalesForce - " + cFuncao,cErros,"Arial",10,,.F.,.T.)
			envErros(cErros)
			
		Else
			envErros(cErros)

		EndIf

		Return Nil

	EndIf

	//
	cNovaQuery := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNovaQuery,.T.,.T.)
	DbSelectArea(cNovaQuery)
	(cNovaQuery)->(DbGoTop())

	//
	nTotReg := Contar(cNovaQuery,"!Eof()")
	(cNovaQuery)->(DbGoTop())

	//
	If ! lAut
		ProcRegua(nTotReg)

	EndIf

	//
	While ! (cNovaQuery)->(Eof())
	
		nAuxTot++
		
		//Abre bloco do batch.
		If Empty(cResJson)
			cResJson := '{"batchRequests":['

		EndIf

		//Obt้m chave externa do SalesForce.
		cChavePar :=  (cNovaQuery)->CHVSF

		If ! lAut
			nAux++
			IncProc(cObjeto + " " + cChavePar + " | " + cValToChar(nAux) + "/" + cValToChar(nTotReg) ) 

		EndIf

		//Checa se faz o Get para o registro.
		If lChkId
			lChkGet := .T.
			cOperEx	:= "POST"
			If ! Empty(Alltrim(cValToChar((cNovaQuery)->IDSALES)))
				lChkGet := .F.
				cOperEx	:= "PATCH"

			EndIf

		EndIf

		//
		If lChkGet

			//Executa consulta do registro para saber se serแ uma atualiza็ใo ou uma inser็ใo.
			cMsg 	:= ""
			lRet := U_ADVEN075P(cServTab + cChvExt + cChavePar,"GET","",@cMsg,aResponse)

			//
			If lRet
				cMetodo	:= "PATCH"
				
				//Cria objeto json.
				If ! FWJsonDeserialize(cMsg, @oParseJSON)

					cMsg := "Ocorreu erro na desserializa็ใo do json com os dados de login (ProcessarB ADVEN075P)."

					If ! lAut
						TelErro("Envio SalesForce - " + cFuncao,cMsg,"Arial",10,,.F.,.T.)
						envErros( cMsg )
						
					Else
						envErros( cMsg )

					EndIf

					(cNovaQuery)->(DbSkip())
					Loop

				Else
					
					//Marca registro no Protheus como jแ enviado.
					If lMrcReg
						cJsonRet :=   &( "StaticCall(" + cFuncao + ",mrkReg,'" + cChavePar + "'," + cValToChar(lAut) + ",'" + cValToChar(oParseJSON:Id) + "','" + cMetodo + "',aResponse,'" + cNovaQuery + "')" )

					EndIf				

					FreeObj(oParseJSON)
					oParseJSON := Nil

				EndIf

			Else

				//
				cMsg :=  Alltrim(cValToChar(cMsg))
				If "NOT_FOUND" $cMsg .Or. "404 NotFound" $cMsg  //Registro nใo encontrado no SalesForce.
					cMetodo	:= "POST"		

				Else

					If ! lAut
						cErros += "ProcessarB (ADVEN075P) Ocorreu erro na consulta " + cObjeto + " " + cValToChar(cChavePar) + " no SalesForce." + Chr(13) + Chr(10)+ cMsg + xPula
						envErros(cErros)
						TelErro("Envio SalesForce - " + cFuncao,cErros,"Arial",10,,.F.,.T.)
						
					Else
						envErros("Ocorreu erro na consulta " + cObjeto + " " + cValToChar(cChavePar) + " no SalesForce (ADVEN075P)." + Chr(13) + Chr(10) + cMsg + " - ProcessarB (ADVEN075P)")

					EndIf	

					(cNovaQuery)->(DbSkip())
					Loop

				EndIf

			EndIf

		Else

			cMetodo := cOperEx

		EndIf
		
		//Monta json para o registro.
		cResJson +=  &( "StaticCall(" + cFuncao + "," + cFunJson + ",'" + cMetodo + "','" + cChvExt + "','" + cNovaQuery + "',aResponse)" )

		//Conta para quantos registros jแ foram criados o json.
		nCount++

		//
		If ValType(aRetOk) == "A"
			Aadd(aRetOk,{cMetodo,cChavePar,"NP","","",""})

		EndIf

		//Valida a quantidade de registros.
		If ! Empty(cResJson) .And. ((nCount == nTamLotEnv) .Or.;          // Se atingiu 25 registros.
		   (nCount == nTotReg) .Or.; // Se nใo atingiu 25, mas atingiu o tamanho da carga.
		   (nAuxTot == nTotReg))        // Se o loop chegou ao tamanho da carga.

			//Remove a ๚ltima vํrgula.
			cResJson := Substr(cResJson,1,Len(cResJson) -1)
	
			//Fecha bloco do batch.
			cResJson += ']}'
	
			//Envia requisi็ใo ao servi็o.
			cMsg := ""
			If ! U_ADVEN075P(cUrl,"POST",cResJson,@cMsg,aResponse)
	
				If ! lAut
					cErros += "Ocorreu erro " + cObjeto + " (" + cMetodo + ") " + cValToChar(cChavePar) + " no SalesForce." + Chr(13) + Chr(10) + cMsg + xPula
					envErros("Ocorreu erro " + cObjeto + " (" + cMetodo + ") " + cValToChar(cChavePar) + " no SalesForce." + Chr(13) + Chr(10) + cMsg + " - ProcessarB ADVEN075P")
					
				Else
					envErros("Ocorreu erro " + cObjeto + " (" + cMetodo + ") " + cValToChar(cChavePar) + " no SalesForce." + Chr(13) + Chr(10) + cMsg + " - ProcessarB ADVEN075P")
	
				EndIf
	
			Else
	
				//Checa se o retorno possui erro e processa o envio de itens.
				chkErro(@cMsg,@cErros,lAut,cUrl,cResJson,"POST",@aRetOk,lItem,lMrcReg,cChvTab,aResponse,cFuncao,@nRegErro,cNovaQuery,nTamVariav,cObjeto)
	
			EndIf
	
			//Envia o itens do pedido.
			If lItemLot
	
				cGrpCli := ""	
				For nWP :=  1 To Len(aRetOk)
	
					If Upper(Alltrim(cValToChar(aRetOk[nWP][3]))) == "OK" .And. Alltrim(cValToChar(aRetOk[nWP][5])) == ""
	
						//
						cGrpCli += "*" + cValToChar(aRetOk[nWP][2]) + "*,"
						aRetOk[nWP][5] := "X"
	
					EndIf
	
				Next i
	
				//
				If !Empty(cGrpCli)
					cGrpCli := Substr(cGrpCli,1,Len(cGrpCli)-1)
					cJsonRet :=   &("StaticCall(" + cFuncao + ",envItens,''," + cValToChar(lAut) + ",'" + cChvTab + "',aResponse,'','" + cNovaQuery + "','" + cGrpCli + "')")		
	
				EndIf
	
			EndIf
			
			//
			If ValType(aRetOk) == "A" 
				For nWP :=  1 To Len(aRetOk)
					
					//Marca registro com o Id do SalesForce.
					If (lMrcReg .And. cValToChar(aRetOk[nWP][1]) == "POST" .And. Alltrim(cValToChar(aRetOk[nWP][6])) == "") .Or. (lAtuPed .And. lMrcReg)
		
						cJsonRet :=   &( "StaticCall(" + cFuncao + ",mrkReg,'" + cValToChar(aRetOk[nWP][2]) + "'," + cValToChar(lAut) + ",'" + cValToChar(aRetOk[nWP][4]) + "','" + cValToChar(aRetOk[nWP][1]) + "',aResponse,'" + cNovaQuery + "')" )
						aRetOk[nWP][6] := "X"
		
					EndIf
		
					If lItem //Envia o itens do pedido.
		
						If Upper(Alltrim(cValToChar(aRetOk[nWP][3]))) == "OK" .And. Alltrim(cValToChar(aRetOk[nWP][5])) == ""
							cJsonRet :=   &("StaticCall(" + cFuncao + ",envItens,'" + cValToChar(aRetOk[nWP][2]) + "'," + cValToChar(lAut) + ",'" + cChvTab + "',aResponse,'" + cValToChar(aRetOk[nWP][1]) + "')")		
							aRetOk[nWP][5] := "X"
		
						EndIf
		
					EndIf
		
				Next nWP
			
			EndIf
	
			//Exibe erros de processamento.
			If ! Empty(cErros) .And. ! lAut
				TelErro("Envio SalesForce - " + cFuncao + "/" + cObjeto, "Num. Reg. Erro " + cValToChar(nRegErro) + Chr(13) + Chr(10) + cErros,"Arial",10,,.F.,.T.)
				envErros(cErros)
				
			ElseIf ! Empty(cErros) .And. lAut
				envErros(cErros)
	
			EndIf
	
			//
			If ValType(aRetOk) == "A" .And. ! lObtRet
				aRetOk  := {}
			
			EndIf
			
			cGrpCli := ""
			nRegErro:= 0 
			cErros  := ""
	
			//Zera variแveis com o json.
			cResJson := ""
			nCount := 0
		
		EndIf

		(cNovaQuery)->(DbSkip())

	EndDo
	
	//
	(cNovaQuery)->(DbCloseArea())

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsqlCusto        บAutor  ณEverson     บ Data ณ  13/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFecha se o retorno possui erro.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkErro(cMsg,cErros,lAut,cUrl,cResJson,cMetodo,aRetOk,lItem,lMrcReg,cChvTab,aResponse,cFuncao,nRegErro,cNovaQuery,nTamVariav,cObjeto)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local oParseJSON := Nil
	Local nI		 := 1
	Local nX		 := 1
	Local xPula		 := Chr(13) + Chr(10)
	Local lRetStatus := Iif(ValType(aRetOk) == "A" .Or. lItem,.T.,.F.)
	Local cJsonRet	 := ""
	Local cMsgErro	 := ""

	//Cria objeto json.
	If ! FWJsonDeserialize(cMsg, @oParseJSON)

		cMsgErro := "Ocorreu erro na desserializa็ใo do json com os dados de login (chkErro ADVEN075P)."

		If ! lAut
			MsgStop(cMsgErro,"Fun็ใo chkErro ADVEN075P")
			envErros( cMsgErro)

		Else
			envErros( cMsgErro )

		EndIf

		Return .F.

	EndIf

	//Verifica se hแ erros no processamento.
	If Alltrim(cValToChar(oParseJSON:hasErrors)) == ".F."

		//Preenche status de retorno dos registros em lote.
		If lRetStatus

			For nI := 1 To Len(oParseJSON:results)

				If ValType(aRetOk) == "A"

					aRetOk[nI][3] := "OK"

					//
					If Alltrim(cValToChar(aRetOk[nI][1])) == "POST"
						aRetOk[nI][4] := Alltrim(cValToChar(oParseJSON:results[nI]:result:ID))
					Else
						aRetOk[nI][4] := ""

					EndIf

				EndIf

			Next nI

		EndIf

		Return .T.
	
	Else
	
	//
	cErros += "Json "    + Alltrim(cValToChar(cResJson)) + xPula + xPula
	cErros += xPula + xPula

	EndIf

	//Busca por erros no json.
	For nI := 1 To Len(oParseJSON:results)

		//Verifica se hแ c๓digo diferente de 200.
		If Substr(Alltrim(cValToChar(oParseJSON:results[nI]:STATUSCODE)),1,1) <> "2"

			For nX := 1 To Len(oParseJSON:results[nI]:result)

				//
				If ValType(aRetOk) == "A"
					cErros += "M้todo Ind. " + Alltrim(cValToChar(aRetOk[nI][1])) + xPula
					cErros += "Cod. Protheus " + Alltrim(cValToChar(aRetOk[nI][2])) + xPula

				EndIf
				
				cErros += "Usuแrio " + Alltrim(cValToChar(cUserName)) + xPula
				cErros += "Fun็ใo " + Alltrim(cValToChar(cFuncao)) + " - " + Alltrim(cValToChar(cObjeto)) + xPula
				cErros += "Url " + Alltrim(cValToChar(cUrl)) + xPula
				cErros += "M้todo " + Alltrim(cValToChar(cMetodo)) + xPula
				cErros += "statusCode " +  DecodeUtf8(Alltrim(cValToChar(oParseJSON:results[nI]:STATUSCODE))) + xPula
				cErros += "errorCode "  +  DecodeUtf8(Alltrim(cValToChar(oParseJSON:results[nI]:result[nX]:ERRORCODE))) + xPula
				cErros += "message "    +  DecodeUtf8(Alltrim(cValToChar(oParseJSON:results[nI]:result[nX]:MESSAGE))) + xPula// + xPula
				cErros += "-------------------------------------------------------------"
				cErros += xPula + xPula

			Next nX

			//
			nRegErro++

			//Preenche status de retorno dos registros em lote.
			If ValType(aRetOk) == "A"

				aRetOk[nI][3] := "ER"
				aRetOk[nI][4] := ""

			EndIf

		Else

			//Preenche status de retorno dos registros em lote.
			If ValType(aRetOk) == "A"

				aRetOk[nI][3] := "OK"

				//
				If Alltrim(cValToChar(aRetOk[nI][1])) == "POST"
					aRetOk[nI][4] := Alltrim(cValToChar(oParseJSON:results[nI]:result:ID))

				Else
					aRetOk[nI][4] := ""

				EndIf

			EndIf


		EndIf

	Next nI

	//Limpa objeto da mem๓ria.
	FreeObj(oParseJSON)
	oParseJSON := Nil

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelErro         บAutor  ณEverson     บ Data ณ  13/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para exibi็ใo de erros.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TelErro(cTitulo,cTexto,cFonte,nTamFonte,lFocoFec,lFocoCanc,lOkCanc,cAcaoTimer)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local lRet				:= .T.
	Local aCoord			:= FWGetDialogSize(oMainWnd)
	Local aTamObj			:= Array(4)
	Local nCoefDif			:= 1
	Local cLOGArq			:= ""
	Local cTipoArq    		:= "Arquivos Texto (*.TXT) |*.txt|"
	Local cAcao				:= "oMemo:SetFocus()"
	Local cGET01	
	Local cGET02
	Local bAcao01			:= {|| }
	Local bAcao02			:= {|| }

	//Objetos graficos
	Local oDlg
	Local oEtq01
	Local oFont
	Local oTimerTE

	Private oMemo
	Private oBot01
	Private oBot02

	PARAMTYPE 0 VAR cTitulo		AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 1 VAR cTexto		AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 2 VAR cFonte		AS Character	OPTIONAL	DEFAULT "Mono AS"
	PARAMTYPE 3 VAR nTamFonte	AS Numeric		OPTIONAL	DEFAULT 0
	PARAMTYPE 4	VAR lFocoFec	AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 5	VAR lFocoCanc	AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 6	VAR lOkCanc		AS Logical		OPTIONAL	DEFAULT .F.
	PARAMTYPE 7	VAR cAcaoTimer	AS Character	OPTIONAL	DEFAULT ""

	If lFocoFec .OR. lFocoCanc
		cAcao := "oBot02:SetFocus()"
	Endif
	oFont := tFont():New(cFonte,,IIf(!Empty(nTamFonte),Abs(nTamFonte),5) * -1,.T.)
	If FindFunction("U_ApRedFWL") .AND. U_ApRedFWL(.F.)
		nCoefDif := 0.95
	Endif
	aCoord[3] := aCoord[3] * 0.6
	aCoord[4] := aCoord[4] * 0.4
	DEFINE MSDIALOG oTela TITLE cTitulo FROM aCoord[1],aCoord[2] To aCoord[3],aCoord[4] PIXEL 

	aTamObj[1] := 005
	aTamObj[2] := 005
	aTamObj[3] := (oTela:nWidth / 2) - aTamObj[2] * 2
	aTamObj[4] := ((oTela:nHeight * nCoefDif) / 2) - ((aTamObj[1] * 2) + nDistAPad + nAltBot + aTamObj[1])
	oMemo := tMultiGet():New(aTamObj[1],aTamObj[2],{|x| IIf(PCount() > 0,cTexto := x,cTexto)},oTela,aTamObj[3],aTamObj[4],oFont,.T.,,,,.T.,,,{|| .T.},,,.T.,/*bValid*/,,,.F.,.F.)
	oMemo:bRClicked := {|| AllwaysTrue()}
	If !lOkCanc
		bAcao01	:= {|| cArqLOG := cGetFile(cTipoArq,""),IIf(Empty(cArqLOG),.T.,MemoWrite(cArqLOG,cTexto))} 
		bAcao02	:= {|| oTela:End()}
		cTAG01	:= "Gravar"
		cTAG02	:= "Fechar"
	Else
		bAcao01	:= {|| lRet := .T.,oTela:End()}
		bAcao02	:= {|| lRet := .F.,oTela:End()}
		cTAG01	:= "Ok"
		cTAG02	:= "Fechar"
	Endif
	aTamObj[1] := ((oMemo:nTop + oMemo:nHeight) / 2) + nDistAPad
	aTamObj[2] := 005
	aTamObj[3] := ((oTela:nWidth / 2) - ((aTamObj[2] * 2) + nDistAPad)) / 2
	aTamObj[4] := nAltBot
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG01,oTela,bAcao01,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	aTamObj[2] := ((oBot01:nLeft + oBot01:nWidth) / 2) + nDistAPad
	oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG02,oTela,bAcao02,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	If !Empty(cAcaoTimer)
		oTimerTE := tTimer():New(3000,&("{|| " + cAcaoTimer + "}"),oTela)
		oTimerTE:Activate() 
	Endif
	oBot01:Hide()
	oTela:Activate(,,,.T.,/*valid*/,,&("{|| " + cAcao + "}"))

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcodVendedor   บAutor  ณEverson      บ Data ณ  10/01/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para consulta de vendedores cadastrados no SF.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkVend(aResponse,cCodVend,cVendPq,lAut)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cSrvVend   := ""
	Local cMsg	     := ""
	Local oParseJSON :=  Nil
	Local w			 := 1

	Default cVendPq	 := ""
	Default lAut     := .F.

	//
	If Empty(cVendPq)
		cSrvVend   := "/services/data/v41.0/query?q=SELECT+Codigo_Vendedor__c+FROM+User+WHERE+Codigo_Vendedor__c<>null"

	Else
		cSrvVend   := "/services/data/v41.0/query?q=SELECT+Id+FROM+User+WHERE+Codigo_Vendedor__c='" + cVendPq + "'"

	EndIf

	//
	If ! U_ADVEN075P(cSrvVend,"GET","",@cMsg,aResponse)

		If ! lAut
			MsgStop("Ocorreu erro na consulta de vendedores no SalesForce." + Chr(13) + Chr(10) + cMsg,"Fun็ใo chkVend ADVEN075P")

		Else
			envErros("Ocorreu erro na consulta de vendedores no SalesForce. ADVEN075P " + Chr(13) + Chr(10) + cMsg)

		EndIF

		Return .F.

	EndIf

	//Converte a string json em objeto.
	If ! FWJsonDeserialize(cMsg, @oParseJSON)

		If ! lAut
			MsgStop("Ocorreu erro na desserializa็ใo do json (vendedores).","Fun็ใo chkVend ADVEN075P")
			envErros("Ocorreu erro na desserializa็ใo do json (vendedores). ADVEN075P ")
			
		Else
			envErros("Ocorreu erro na desserializa็ใo do json (vendedores). ADVEN075P ")

		EndIF

		Return .F.

	EndIf

	//Obt้m o Id do vendedor.
	If Val(cValToChar(oParseJSON:totalSize)) > 0

		For w := 1 To Val(cValToChar(oParseJSON:totalSize))

			If Empty(cVendPq)
				cCodVend += "'" + Alltrim(cValToChar(oParseJSON:records[w]:Codigo_Vendedor__c)) + "',"

			Else
				cCodVend += "'" + Alltrim(cValToChar(oParseJSON:records[w]:Id)) + "',"

			EndIf

		Next w

		//
		cCodVend := Substr(cCodVend,1,Len(cCodVend) -1)

	EndIf

	//
	FreeObj(oParseJSON)
	oParseJSON := Nil

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchkCli        บAutor  ณEverson      บ Data ณ  16/03/2018    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql para consulta de clientes cadastrados no SF.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function chkCli(aResponse,cCodCliLj,cCodCliLjPq,lAut)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	     := GetArea()
	Local cSrvVend   := ""
	Local cMsg	     := ""
	Local oParseJSON :=  Nil
	Local x			 := 1

	Default cCodCliLjPq	:= ""
	Default lAut		:= .F.

	//
	If Empty(cCodCliLjPq)
		cSrvVend   := "/services/data/v41.0/query?q=SELECT+Id+,+Name+from+Account+WHERE+Chave_Externa__c<>null"

	Else
		cSrvVend   := "/services/data/v41.0/query?q=SELECT+Id+,+Name+from+Account+WHERE+Chave_Externa__c='" + cCodCliLjPq + "'"

	EndIf

	//
	If ! U_ADVEN075P(cSrvVend,"GET","",@cMsg,aResponse)

		If ! lAut
			MsgStop("Ocorreu erro na consulta de vendedores no SalesForce." + Chr(13) + Chr(10) + cMsg,"Fun็ใo chkVend ADVEN075P")
			envErros("Ocorreu erro na consulta de vendedores no SalesForce. ADVEN075P " + Chr(13) + Chr(10) + cMsg)
			
		Else
			envErros("Ocorreu erro na consulta de vendedores no SalesForce. ADVEN075P " + Chr(13) + Chr(10) + cMsg)

		EndIf

		RestArea(aArea)
		Return .F.

	EndIf

	//Converte a string json em objeto.
	If ! FWJsonDeserialize(cMsg, @oParseJSON)

		If ! lAut
			MsgStop("Ocorreu erro na desserializa็ใo do json (vendedores).","Fun็ใo chkVend ADVEN075P")
			envErros("Ocorreu erro na desserializa็ใo do json (vendedores).","Fun็ใo chkVend ADVEN075P")
			
		Else
			envErros("Ocorreu erro na desserializa็ใo do json (vendedores).","Fun็ใo chkVend ADVEN075P")

		EndIf

		RestArea(aArea)
		Return .F.

	EndIf

	//Obt้m o Id do vendedor.
	If Val(cValToChar(oParseJSON:totalSize)) > 0

		For x := 1 To Val(cValToChar(oParseJSON:totalSize))

			If Empty(cCodCliLjPq)
				cCodCliLj += "'" + Alltrim(cValToChar(oParseJSON:records[x]:Chave_Externa__c)) + "',"

			Else
				cCodCliLj += "'" + Alltrim(cValToChar(oParseJSON:records[x]:Id)) + "',"

			EndIf

		Next x

		//
		cCodCliLj := Substr(cCodCliLj,1,Len(cCodCliLj) -1)

	EndIf

	//
	FreeObj(oParseJSON)
	oParseJSON := Nil

	//
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvErros        บAutor  ณEverson     บ Data ณ  13/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de erros.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envErros(cMsg)

	conout(cMsg)
	envEmail(cMsg)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenviarEmail       บ Autor ณ Everson บ Data ณ  19/03/2018    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEnvia e-mail.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envEmail(cErroEmail)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := ""
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_#SFEMAI"))//AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_#SFEMSE"))//AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_#SFEMAI"))//AllTrim(GetMv("MV_RELACNT"))
	Local cTo           := GetMv("MV_#SFERRO",,.F.)//"everson.silva@adoro.com.br" // >>>>>>>>> Criar Mv.
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
	Local cSubject      := ""
	Local cAtach		:= ""

	//
	If Empty(cErroEmail)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	cBody := "Erro de integra็ใo com o SalesForce" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + cErroEmail
	
	//
	If Type("cUserName") == "C"
		cBody += "Usuแrio: " + cUserName + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + cBody
		
	EndIf

	//Assunto do e-mail.
	cSubject := "Integra็ใo SalesForce"

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)

		Else
			lAutOk := .T.

		EndIf

	EndIf

	If lOk .And. lAutOk   

		//Envia o e-mail.     
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  

		//Tratamento de erro no envio do e-mail.          
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 3 - " + cErrorMsg)

		EndIf

	Else
		Get Mail Error cErrorMsg
		ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server

	EndIf

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrvLog            บ Autor ณ Everson บ Data ณ  17/04/2018    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGrava requisi็๕es ao servi็o.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grvLog(cUsuario,cIdSF,cNumP,cJson,cErro,Url,cMetodo,cTmProc,cPedSF)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea := GetArea()
	Local nRecno:= 0
	
	//
	cUsuario := Alltrim(cValToChar(cUsuario))
	cIdSF	 := Alltrim(cValToChar(cIdSF))
	cNumP	 := Alltrim(cValToChar(cNumP))
	cJson    := Alltrim(cValToChar(cJson)) 
	cErro    := Alltrim(cValToChar(cErro)) 
	Url      := Alltrim(cValToChar(Url)) 
	cMetodo	 := Alltrim(cValToChar(cMetodo)) 
	cTmProc	 := Alltrim(cValToChar(cTmProc)) 
	cPedSF   := Alltrim(cValToChar(cPedSF)) 
	
	//
	DbSelectArea("ZCI")
	RecLock("ZCI",.T.)
		ZCI->ZCI_FILIAL:= xFilial("ZCI")
		ZCI->ZCI_DATA  := Date()
		ZCI->ZCI_HORA  := cValToChar(Time())
		ZCI->ZCI_USR   := cUsuario
		ZCI->ZCI_IDSF  := cIdSF
		ZCI->ZCI_NUMP  := cNumP
		ZCI->ZCI_JSON  := cJson
		ZCI->ZCI_ERRO  := cErro
		ZCI->ZCI_URL   := Url
		ZCI->ZCI_METD  := cMetodo
		ZCI->ZCI_TMPR  := cTmProc
		ZCI->ZCI_PEDSAL:= cPedSF
	MsUnlock()
	nRecno := ZCI->( Recno() )
	ZCI->(DbCloseArea())
	
	//
	RestArea(aArea)

Return nRecno