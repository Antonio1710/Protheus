#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'AP5mail.ch'
#Include 'Topconn.ch'

#Include 'RPTDEF.ch'
#Include 'FWPrintSetup.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN065P      บAutor  ณEverson      บ Data ณ  21/12/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณServi็o Rest para gera็ใo de relat๓rios em html.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN065P(cEmp,cFili,cVend,cCodigoSF,cJobAux) // U_ADVEN065P("01","02","000005","001W000000dH2gV")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery 	:= ""
	Local cEmailVd	:= ""
	Local cUser 	:= ""
	Local cEmailSp	:= ""
	Local nHandle	:= 0
	Local nTamFile	:= 0
	Local cString	:= ""
	Local cHoraExec := Time()

	Private cNmRelRest := ""

	//Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv(cEmp,cFili,,,,GetEnvServer(),{ })	
	Conout("Inicializado processo ADVEN065P")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Servi็o Rest para gera็ใo de relat๓rios em html')
	
	StaticCall(ADVEN075P,grvLog,"",cCodigoSF,cVend,"","","ADVEN065P","POST")

	//PutGlbValue(cJobAux,"1")
	//GlbUnlock()

	//Executa rotina para cria็ใo do relat๓rio.
	StaticCall(ADFIN031R,gerarRelatorio,cVend,"","","",@cNmRelRest)

	//			
	nHandle  := fopen(cNmRelRest, FO_READWRITE + FO_SHARED )
	nTamFile := fSeek(nHandle,0,2)
	fSeek(nHandle,0,0)
	nQtd    := FRead( nHandle, @cString, nTamFile)
	cString := Encode64(cString)

	//Envia relat๓rio.
	Processar(cString,cCodigoSF,cVend)

	//
	FClose(nHandle)

	//Apaga relat๓rio.
	FErase(cNmRelRest)
	
	//
	cHoraExec := ELAPTIME(cHoraExec, Time())
	StaticCall(ADVEN075P,grvLog,"",cCodigoSF,cVend,"","","ADVEN065P","POST",cHoraExec)
	
	//Fecha o ambiente.
	RpcClearEnv()	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcessar      บAutor  ณEverson      บ Data ณ  03/01/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento dos envios.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(cString,cCodigoSF,cVend)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cServico	:= "/services/data/v41.0/sobjects/ContentVersion/" //Trocar por MV ou tabela gen้rica.
	Local cResJson	:= ""
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local cHoraExec	:= Time()

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,.F.)

	//
	If ! lLogin
		Return Nil

	EndIf

	//
	cResJson += '{'

		cResJson += '"Title" : "Relat๓rio de faturamento ' + cVend + ' ",'
		cResJson += '"FirstPublishLocationId" : "' + cCodigoSF + '",'
		cResJson += '"PathOnClient" : "Faturamento_' + cVend + '_.html",'
		cResJson += '"VersionData" :"' + cString + '"'

	cResJson += '}'

	//Envia o relat๓rio so servi็o do SalesForce.
	If ! U_ADVEN075P(cServico,"POST",cResJson,@cMsg,aResponse)
		Conout("Ocorreu erro no envio do relat๓rio financeiro " + cValToChar(cVend) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)
		
		StaticCall(ADVEN075P,grvLog,"",cCodigoSF,cVend,cResJson,"Ocorreu erro no envio do relat๓rio financeiro " + cValToChar(cVend) + " no SalesForce." + Chr(13) + Chr(10) + cMsg,"ADVEN065P","POST")
		
		StaticCall(envErros,envErros,"Ocorreu erro no envio do relat๓rio financeiro " + cValToChar(cVend) + " no SalesForce." + Chr(13) + Chr(10) + cMsg)
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelatorios     บAutor  ณEverson      บ Data ณ  29/11/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณServi็o Rest para gera็ใo de relat๓rios em pdf.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WsRestFul relatorios Description "Servi็o REST para gera็ใo de relat๓rios."

	WsMethod Post Description "Retorno de relat๓rio."   WsSyntax "/relatorios"

End WsRestFul
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelatorios     บAutor  ณEverson      บ Data ณ  25/01/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณServi็o Rest para gera็ใo de relat๓rios em pdf.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WsMethod Post WsService relatorios

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cNomeArq		:= ""
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	Local cCodRel		:= ""
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cBody 		:= Self:GetContent()
	Local oParseJSON	:= Nil
	Local cCodigoSF		:= ""
	Local cCodVendedor	:= ""
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local lRetP			:= .T.
	Local cJobAux		:= ""
	Local cUrlServ		:= Self:GetPath()
	Private cHoraExec	:= Time()
		
	//Desserializa a string Json (converte em objeto json).
	If ! FWJsonDeserialize(cBody, @oParseJSON)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"Ocorreu erro na desserializa็ใo do Json.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserializa็ใo do Json."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"",cUrlServ,"POST")
	
	//Obt้m o c๓digo da requisi็ใo do SalesForce e c๓digo do vendedor.
	cCodigoSF := Alltrim(cValToChar(oParseJSON:codigoSF))
	cCodVendedor := Alltrim(cValToChar(oParseJSON:A3_COD))

	//Verifica se foi possํvel obter o c๓digo de usuแrio do vendedor.
	If Empty(cCodUsuario)
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"C๓digo de usuแrio nใo informado (UsrVend).",cUrlServ,"POST")
		
		SetRestFault(403,EncodeUtf8("C๓digo de usuแrio nใo informado (UsrVend)."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//Atribui usuแrio.
	__cUserId := cCodUsuario

	//Verifica o formato de dados aceito na resposta.
	If cFormato <> cFormatAceito
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"Formato de dados " + cFormato + ", no Accept do cabe็alho da requisi็ใo, nใo suportado.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabe็alho da requisi็ใo, nใo suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf cContentType <> cFormatAceito //Verifica o formato no corpo da requisi็ใo.
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabe็alho da requisi็ใo, nใo suportado.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabe็alho da requisi็ใo, nใo suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cBody) //Verifica se o corpo da requisi็ใo nใo estแ vazio.
	
		//
		StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"Json nใo encontrado no corpo da requisi็ใo.",cUrlServ,"POST")
		
		SetRestFault(400,EncodeUtf8("Json nใo encontrado no corpo da requisi็ใo."))
		RestArea(aArea)
		Return .F.

	EndIf

	//Cria variแvel global para controle da thread.
	//cJobAux := Upper(cCodVendedor + cValToChar( Randomize(0,9000)) )
	//PutGlbValue(cJobAux,"0")
	//GlbUnlock()
	
	//conout("cCodigoSF >>>>>>>>>>>> " + cCodigoSF)
	//conout("cCodVendedor >>>>>>>>>> " + cCodVendedor)
	
	//Inicia o Job na requisi็ใo.
	StartJob("U_ADVEN065P",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cCodVendedor,cCodigoSF,cJobAux)
	
	//Checa se o job foi inicializado.
/*	Sleep(1000)
	While lRetP
		
		If cValToChar(GetGlbValue(cJobAux)) == "0"// Job nใo inicializou.
			SetRestFault(500,EncodeUtf8("Nใo foi possํvel inicializar o Job."))
			RestArea(aArea)
			Return .F.
				
		ElseIf cValToChar(GetGlbValue(cJobAux)) == "1" //Job inicializou.
			lRetP := .F.
			
		EndIf
		
	EndDo*/
	
	//Limpa variแvel global.
	//ClearGlbValue(cJobAux)
	
	//Atribui o formato no cabe็alho da reposta.
	Self:SetContentType(cFormatAceito)
	Self:SetResponse(EncodeUtf8('{"mensagem":"Requisi็ใo aceita."}'))
	
	//
	//Sleep(1500)
	
	//
	cHoraExec := ELAPTIME(cHoraExec, Time())
	StaticCall(ADVEN075P,grvLog,cCodUsuario,cCodigoSF,cCodVendedor,cBody,"",cUrlServ,"POST",cHoraExec)

	//
	RestArea(aArea)

Return .T.