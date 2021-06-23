#Include "Totvs.ch"
#Include "Restful.ch"

User Function ADVEN056P()
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³emailxml     ºAutor  ³Everson      º Data ³  09/10/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Serviço REST para atualização de e-mail de receb. XML.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 037261.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WsRestFul emailxml Description "Serviço REST para atualização de receb. XML de clientes."

	WsMethod Put Description "Atualiza e-mail de receb. XML de clientes. "   WsSyntax "/emailxml"

End WsRestFul

WsMethod Put WsService emailxml

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cCRLF			:= Chr(13) + Chr(10)
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	Local cNumPed		:= ""
	Local oParseJSON
	Local cJsonResp		:= ""
	Local cCodCli		:= ""
	Local cLojaCli		:= ""
	Local cEmail		:= ""
	Local aParametros	:= Self:aURLParms
	Local cCodLoja		:= ""
	Local cUrlServ		:= Self:GetPath()
	Private cHoraExec	:= Time()

	U_ADINF009P('ADVEN056P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Serviço REST para atualização de e-mail de receb. XML')
	
	//
	Self:SetContentType(cFormatAceito)
	
	//
	If Len(aParametros) == 0
	
	   //
	   StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Obrigatório informar o código e loja do cliente.",cUrlServ,"PUT")
	
	   SetRestFault(400,EncodeUtf8("Obrigatório informar o código e loja do cliente."))
	   RestArea(aArea)
	   Return .F.
	   
	EndIf
	
	//Obtém o número do pedido de venda.
	cCodLoja := Alltrim(cValToChar(aParametros[1]))
	
	//
	If Empty(cCodUsuario)

	   //
	   StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"PUT")
	
	   SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))
	   RestArea(aArea)
	   Return .F.
	   
	EndIf
	
	//Atribui usuário.
	__cUserId := cCodUsuario
	
	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)
	
		//
	    StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"PUT")
	
		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//
	If cFormato <> cFormatAceito
	
	    //
	    StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"PUT")
	
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.
		
	ElseIf cContentType <> cFormatAceito
	
		//
	    StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"PUT")
	
		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.
	
	ElseIf Empty(cBody)
	
		//
	    StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"PUT")
	
		SetRestFault(400,EncodeUtf8("Json não encontrado no corpo da requisição."))
		RestArea(aArea)
		Return .F.
						
	EndIf
	
	//Atribui usuário.
	cCodCli		:= Alltrim(cValToChar(Substr(cCodLoja,1,6)))
	cLojaCli	:= Alltrim(cValToChar(Substr(cCodLoja,7,2)))
	cEmail		:= FwNoAccent(Alltrim(cValToChar(oParseJSON:A1_EMAIL)))
	
	FreeObj(oParseJSON)
	oParseJSON := Nil
	
	//Valida e-mail.
/*	If ! IsEmail(cEmail)
		SetRestFault(400,EncodeUtf8("E-mail " + cEmail +  " inválido."))
		RestArea(aArea)
		Return .F.
		
	EndIf*/
	
	//Localiza o cliente.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If ! SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojaCli))
	
		//
	    StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"Cliente não encontrado " + cCodCli + "/" + cLojaCli + ".",cUrlServ,"PUT")
	
		SetRestFault(404,EncodeUtf8("Cliente não encontrado " + cCodCli + "/" + cLojaCli + "."))
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Atualiza o e-mail para recebimento de xml.
	RecLock("SA1",.F.)
		Replace SA1->A1_EMAIL With cEmail
	MsUnlock()
	
	SA1->(DbCloseArea())
	
	//
	Self:SetResponse('')
	
	//
	cHoraExec := ELAPTIME(cHoraExec, Time())
	StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,cBody,"",cUrlServ,"PUT",cHoraExec)
	
	RestArea(aArea)
	
Return .T.