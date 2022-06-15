#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'Topconn.ch'

/*/{Protheus.doc} User Function ADVEN086P
	Serviço Rest para manipulação de pedidos de venda. Chamado 037261.
	@type  Function
	@author Everson
	@since 04/01/2018
	@version 01
	@history 08/07/2019, Everson, Chamado T.I. Adiconado validação para pedidos sem itens.
	@history 01/08/2019, Everson, Chamado T.I. Verifica se há caractere especial na 
	mensagem da nota fiscal e valida item do pedido de compra.                                                  
	@history 06/08/2019, Everson, Chamado T.I. Adicionada função Alltrim na função transform.
	@history 30/10/2019, Everson, Chamado 052760. Validação Sintegra.
	@history 01/11/2019, Everson, Chamado 052760. Alterada função de validação Sintegra.
	@history 27/01/2020, Everson, Chamado T.I. Validação do número sequencial do pedido de venda.
	@history 08/09/2021, Macieir, Chamado T.I. Reforça na Validação do número sequencial do pedido de venda após golive cloud
	@history 15/09/2021, Everson, Chamado T.I. Removido log quando o pedido já existe. É necessária esta alteração para incluir constraint no BD.
	@history 07/10/2021, Everson, Chamado T.I. Corrigido nome do campo.
	@history 17/03/2022, Leonardo P. Monteiro, Chamado 69520 - Adicionado o campo de data de entrega.
	@history 17/03/2022 - Leonardo P. Monteiro, Chamado 69520 -  Ajuste na ordenação do processamento para priorizar os PVs por data de entrega e condições de pagamento que geram boletos ou PIX.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 69520 - Leonardo P. Monteiro   - 17/03/2022 - Preparação da rotina para integrações de diferentes Empresas/Filiais com a entrada da nova filial de Itupeva.
	@history Ticket 69520 - Everson   - 13/04/2022 - Preparação da rotina para integrações de diferentes Empresas/Filiais com a entrada da nova filial de Itupeva.
/*/

User Function ADVEN086P()

// Declaracao de Variaveis                                             

Return Nil

WsRestFul pedidosdevenda Description "Serviço REST para manipulação de pedidos de venda."

	WsMethod Post    Description "Inclusão de pedido de venda."  WsSyntax "/pedidosdevenda"
	WsMethod Put     Description "Alteração de pedido de venda." WsSyntax "/pedidosdevenda/{pedido}"
	WsMethod Delete  Description "Exclusão de pedido de venda."  WsSyntax "/pedidosdevenda/{pedido}"

End WsRestFul
/*/{Protheus.doc} User Function Post
	Método POST. Chamado 037261.
	@type  Function
	@author Everson
	@since 11/09/2017
	@version 01
	/*/
WsMethod Post WsService pedidosdevenda

	// Declaracao de Variaveis                                             
	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cErro			:= ""
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cPath			:= ""
	Local cNumPed		:= ""
	Local oParseJSON
	Local cJsonResp		:= ""
	Local cErroPE		:= ""
	Local i				:= 1
	Local cNumChkPedsal	:= ""
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	//Local cJobAux		:= ""
	Local cUrlServ		:= Self:GetPath()
	Local cIdSFBkp		:= ""
	Local cNumSF		:= ""
	Local cSintegra		:= "" //Everson - 30/10/2019,. Chamado 052760. 
	Local cDtEntreg		:= ""
	Local cCondPag		:= ""
	Local cTagFil		:= ""
	Local cEmpJson		:= cEmpAnt
	Local cFilJson		:= cFilAnt

	Private aPedidos	:= {}

	//U_ADINF009P('ADVEN086P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Serviço Rest para manipulação de pedidos de venda')

	//
	Self:SetContentType(cFormatAceito)

	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"POST",,cNumSF )

		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf

	//*******************************************************//
	// Define a filial de inclusão da requisição.
	//*******************************************************//
	//conout("tYPE: "+ Type("oParseJSON:cabecalho:C5_EXPEDITION"))
	// Ativar, caso necessário.
	if "C5_EXPEDITION"$cBody
        if valtype(oParseJSON:cabecalho:C5_EXPEDITION) !='U'

			cTagFil := Alltrim(cValtochar(oParseJSON:cabecalho:C5_EXPEDITION))
			
			if Len(cTagFil) >=4
				cEmpJson := left(cTagFil,2)
				cFilJson := Substring(cTagFil,3,2)
			endif
		endif	
	endif
	
	if cEmpAnt <> cEmpJson .OR. cFilAnt <> cFilJson
		RpcClearEnv() 
		RPCSetType(3) 
		RpcSetEnv(cEmpJson,cFilJson,,,,GetEnvServer(),{ })
		conout("cEmpAnt  cFilAnt: "+ cEmpAnt+"/"+cFilAnt)
	endif

	cPath	:= Alltrim(cValToChar(GetMv("MV_#URLRES"))) + Self:GetPath()

	//
	cIdSFBkp 	:= oParseJSON:cabecalho:C5_XPEDSAL
	cNumSF   	:= oParseJSON:cabecalho:C5_XSFPED
	cDtEntreg   := oParseJSON:cabecalho:C5_DTENTR
	cCondPag    := oParseJSON:cabecalho:C5_CONDPAG

	//
	If Empty(cCodUsuario)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"POST",,cNumSF )


		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf

	//
	//nRecno := Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"POST",,cNumSF)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	nRecno := u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"POST",,cNumSF )

	//Atribui usuário.
	__cUserId := cCodUsuario

	//
	If cFormato <> cFormatAceito

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"POST",,cNumSF )

		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))
		RestArea(aArea)
		Return .F.

	ElseIf cContentType <> cFormatAceito

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"POST",,cNumSF)

		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado."))
		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	ElseIf Empty(cBody)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"POST",,cNumSF )

		SetRestFault(400,EncodeUtf8("Json não encontrado no corpo da requisição."))
		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf

	//
	If ValType(oParseJSON) == "O" //Inclui apenas um pedido.

		//Checa se foi informado o sequencial do SalesForce.
		If Empty(Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDSAL)))

			//
			//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Número do pedido do SalesForce não informado.",cUrlServ,"POST",,cNumSF)
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A0( cCodUsuario,cIdSFBkp,cNumPed,cBody,"Número do pedido do SalesForce não informado.",cUrlServ,"POST",,cNumSF )

			SetRestFault(400, EncodeUtf8("Número do pedido do SalesForce não informado." ) )

			FreeObj(oParseJSON)
			oParseJSON := Nil
			RestArea(aArea)

			//
			MSUnlockAll()

			Return .F.

		EndIf

		//Valida se o número sequencial informado já foi utilizado.
		cNumChkPedsal := ""
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " ZCI_NUMP "
		cQuery += " FROM "
		cQuery += " " + RetSqlName("ZCI") + " (NOLOCK) AS ZCI "
		cQuery += " WHERE "
		cQuery += " ZCI.D_E_L_E_T_ = '' "
		cQuery += " AND ZCI_NUMP <> '' "
		cQuery += " AND ZCI_METD = 'POST' "
		cQuery += " AND ZCI_IDSF = '" +  Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDSAL)) + "' "
		
		If Select("NUM_SC5") > 0
			NUM_SC5->(DbCloseArea())
			
		EndIf
		
		TcQuery cQuery New Alias "NUM_SC5"
		DbSelectArea("NUM_SC5")
		NUM_SC5->(DbGoTop())
			cNumChkPedsal := Alltrim(cValToChar(NUM_SC5->ZCI_NUMP))
		NUM_SC5->(DbCloseArea())
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - Post - cNumChkPedsal >>>>>>> " + cNumChkPedsal )
		If ! Empty(cNumChkPedsal)

			cJsonResp := '{"msg":"Sequencial ' + Alltrim(cValToChar(oParseJSON:cabecalho:C5_XPEDSAL)) + ' já utilizado.","C5_NUM":"'+ Alltrim(cValToChar(cNumChkPedsal)) + '"}'

			//Everson - 15/09/2021. Chamado T.I.
			//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,cJsonResp,cUrlServ,"POST",,cNumSF)

			Self:SetHeader("location",cValToChar(cPath) + "/" + cNumChkPedsal)

			SetRestFault(400,EncodeUtf8(cJsonResp))

			FreeObj(oParseJSON)
			oParseJSON := Nil
			RestArea(aArea)

			//
			MSUnlockAll()

			Return .F.

		EndIf

		//Processa a requisição.
		aPedidos := {}
		If geraRegistro(oParseJSON,@cErro,@cNumPed,,nRecno,3,@cSintegra) .And. Len(aPedidos) == 0 //Gerou pedido de venda.

			cJsonResp := '{"cabecalho":{"C5_NUM":"'+ Alltrim(cValToChar(cNumPed)) + '"}}'

			SC5->(DbCloseArea())

			Self:SetResponse(cJsonResp)
			Self:SetHeader("location",cValToChar(cPath) + "/" + cNumPed)

			FreeObj(oParseJSON)
			oParseJSON := Nil

			RestArea(aArea)

			//
			MSUnlockAll()

			Return .T.

		Else

			cErroPE := ""
			For i := 1 To Len(aPedidos)

				cErroPE += aPedidos[i][1] + " / "

			Next i

			//Everson - 15/09/2021. Chamado T.I.
				Conout("ADVEN086P " + "Erro na inclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE))
				DbSelectArea("ZCI")
				DbGoTo( Val(cValToChar(nRecno)) )
				RecLock("ZCI",.F.)
					ZCI->ZCI_ERRO := "Erro na inclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) //Everson - 07/10/2021.
				ZCI->(MsUnlock())

				//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Erro na inclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE),cUrlServ,"POST",,cNumSF)
			//
			
			SetRestFault(400,EncodeUtf8("Erro na inclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) ))

			FreeObj(oParseJSON)
			oParseJSON := Nil

			RestArea(aArea)

			//
			MSUnlockAll()

			Return .F.	

		EndIf

		//
		If ValType(oParseJSON) == "O"
			FreeObj(oParseJSON)

		EndIf
		oParseJSON := Nil

	Else

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"","",cBody,"Json inválido.",cUrlServ,"POST",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"","",cBody,"Json inválido.",cUrlServ,"POST",,cNumSF)

		SetRestFault(400, EncodeUtf8("Json inválido.") )
		oParseJSON := Nil

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.			

	EndIf

	//
	RestArea(aArea)

	//
	MSUnlockAll()

	//RpcClearEnv()

Return .T.
/*/{Protheus.doc} User Function Put
	Método PUT. Chamado 037261.
	@type  Function
	@author Everson
	@since 11/09/2017
	@version 01
	/*/
WsMethod Put WsService pedidosdevenda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Self:GetContent()
	Local cErro			:= ""
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	//Local aProp			:= {}
	Local cContentType	:= Self:GetHeader("Content-Type")
	Local cPath			:= ""
	Local cNumPed		:= ""
	Local oParseJSON
	Local aParametros	:= Self:aURLParms
	Local cErroPE		:= ""
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	//Local cJsonResp		:= ""
	Local i				:= 1
	Local cFlagApr		:= ""
	Local cUrlServ		:= Self:GetPath()
	Local cIdSFBkp		:= ""
	Local nRecno		:= 0
	Local cQuery		:= ""
	Local cNumSF		:= ""
	Local cDtEntreg		:= ""
	Local cCondPag		:= ""
	Local cTagFil		:= ""
	Local cEmpJson		:= cEmpAnt
	Local cFilJson		:= cFilAnt

	Private aPedidos	:= {}
	Private cHoraExec	:= Time()

	//U_ADINF009P('ADVEN086P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Serviço Rest para manipulação de pedidos de venda')

	//
	If Len(aParametros) == 0

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Obrigatório informar o número do pedido de venda na URL.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Obrigatório informar o número do pedido de venda na URL.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(400,EncodeUtf8("Obrigatório informar o número do pedido de venda na URL."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf
	
	//
	If Empty(cCodUsuario)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Código de usuário não informado (UsrVend).",cUrlServ,"PUT",,cNumSF)

		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf
	
	//
	cNumPed := Alltrim(cValToChar(aParametros[1]))

	//
	If ! FWJsonDeserialize(cBody, @oParseJSON)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf

	//*******************************************************//
	// Define a filial de inclusão da requisição.
	//*******************************************************//
	// Ativar, caso necessário.
	if "C5_EXPEDITION"$cBody
        if valtype(oParseJSON:cabecalho:C5_EXPEDITION) !='U'
			
			cTagFil := Alltrim(cValtochar(oParseJSON:cabecalho:C5_EXPEDITION))
			
			if Len(cTagFil) >=4
				cEmpJson := left(cTagFil,2)
				cFilJson := Substring(cTagFil,3,2)
			endif
		endif
	endif

	if cEmpAnt <> cEmpJson .OR. cFilAnt <> cFilJson
		RpcClearEnv() 
		RPCSetType(3) 
		RpcSetEnv(cEmpJson,cFilJson,,,,GetEnvServer(),{ })
	endif

	cPath	:= Alltrim(cValToChar(GetMv("MV_#URLRES"))) + Self:GetPath()

	//
	cIdSFBkp 	:= oParseJSON:cabecalho:C5_XPEDSAL
	cNumSF   	:= oParseJSON:cabecalho:C5_XSFPED
	cDtEntreg   := oParseJSON:cabecalho:C5_DTENTR
	cCondPag    := oParseJSON:cabecalho:C5_CONDPAG

	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If SC5->(DbSeek(xFilial("SC5") + cNumPed))

		//
		If ! Empty(Alltrim(cValToChar(SC5->C5_PLACA)))
	
			//
			//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido de venda número " + cNumPed + " já está com veículo associado (placa).",cUrlServ,"PUT",,cNumSF)
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido de venda número " + cNumPed + " já está com veículo associado (placa).",cUrlServ,"PUT",,cNumSF)
	
			SetRestFault(400,EncodeUtf8("Pedido de venda número " + cNumPed + " já está com veículo associado (placa)."))
			SC5->(DbCloseArea())
	
			RestArea(aArea)
	
			//
			MSUnlockAll()
	
			Return .F.
	
		EndIf
		
		//
		If ! Empty(Alltrim(cValToChar(SC5->C5_NOTA)))
	
			//
			//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido de venda número " + cNumPed + " já está com nota fiscal.",cUrlServ,"PUT",,cNumSF)
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido de venda número " + cNumPed + " já está com nota fiscal.",cUrlServ,"PUT",,cNumSF)
	
			SetRestFault(400,EncodeUtf8("Pedido de venda número " + cNumPed + " já está com nota fiscal."))
			SC5->(DbCloseArea())
	
			RestArea(aArea)
	
			//
			MSUnlockAll()
	
			Return .F.
	
		EndIf

	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " DISTINCT ZCI.ZCI_NUMP AS ZCIPOST, DEL.ZCI_NUMP AS ZCIDEL " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZCI") + " AS ZCI " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZCI_NUMP FROM " + RetSqlName("ZCI") + " AS ZCI WHERE ZCI.D_E_L_E_T_ = '' AND ZCI_METD = 'DELETE' AND ZCI_NUMP = '" + cNumPed + "') AS DEL " 
	cQuery += " ON ZCI.ZCI_NUMP = DEL.ZCI_NUMP " 
	cQuery += " WHERE " 
	cQuery += " ZCI.D_E_L_E_T_ = '' " 
	cQuery += " AND ZCI.ZCI_METD = 'POST' " 
	cQuery += " AND ZCI.ZCI_NUMP = '" + cNumPed + "' " 
	
	//
	If Select("CHK_ZCI") > 0
		CHK_ZCI->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CHK_ZCI"
	DbSelectArea("CHK_ZCI")
	CHK_ZCI->(DbGoTop())
	
	If CHK_ZCI->(Eof())

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido " + cNumPed + " não encontrado.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido " + cNumPed + " não encontrado.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(404,EncodeUtf8("Pedido " + cNumPed + " não encontrado."))
		CHK_ZCI->(DbCloseArea())

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.
			
	EndIf
	
	//
	If Empty(Alltrim(cValToChar(CHK_ZCI->ZCIPOST)))
	
		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido " + cNumPed + " não encontrado.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido " + cNumPed + " não encontrado.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(404,EncodeUtf8("Pedido " + cNumPed + " não encontrado."))
		CHK_ZCI->(DbCloseArea())

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.		
		
	EndIf
	
	//
	If ! Empty(Alltrim(cValToChar(CHK_ZCI->ZCIDEL)))
	
		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido não encontrado (excluído).",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Pedido não encontrado (excluído).",cUrlServ,"PUT",,cNumSF)

		SetRestFault(404,EncodeUtf8("Pedido " + cNumPed + " não encontrado (requisição de exclusão)."))
		CHK_ZCI->(DbCloseArea())

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.		
		
	EndIf
	
	CHK_ZCI->(DbCloseArea())

	//
	//nRecno := Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"PUT",,cNumSF)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	nRecno := u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"PUT",,cNumSF)

	//
	Self:SetContentType(cFormatAceito)

	//Atribui usuário.
	__cUserId := cCodUsuario

	//
	If cFormato <> cFormatAceito

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	ElseIf cContentType <> cFormatAceito

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(400,EncodeUtf8("Formato de dados " + cContentType + ", no Content-Type do cabeçalho da requisição, não suportado."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	ElseIf Empty(cBody)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"PUT",,cNumSF)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Json não encontrado no corpo da requisição.",cUrlServ,"PUT",,cNumSF)

		SetRestFault(400,EncodeUtf8("Json não encontrado no corpo da requisição."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf
	
	//
	If ValType(oParseJSON) == "O"

		//
		cQuery := ""
		cQuery += " SELECT TOP 1  " 
		cQuery += " R_E_C_N_O_ AS REC " 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZCI") + "  " 
		cQuery += " WHERE  " 
		cQuery += " ZCI_FILIAL = '" + cFilAnt + "'  " 
		cQuery += " AND ZCI_NUMP = '" + cNumPed + "'  " 
		cQuery += " AND ZCI_DATA = '" + DToS(Date()) + "'  " 
		cQuery += " AND ZCI_METD = 'PUT'  " 
		//cQuery += " AND ZCI_TMPR <> '' "
		cQuery += " AND R_E_C_N_O_ < '" + cValToChar(nRecno) + "'  " 
		cQuery += " AND D_E_L_E_T_ = ''   " 
		cQuery += " ORDER BY R_E_C_N_O_ DESC "

		//
		If Select("CHK_REG") > 0
			CHK_REG->(DbCloseArea())

		EndIf 

		//
		TcQuery cQuery New Alias "CHK_REG"
		DbSelectArea("CHK_REG")
		CHK_REG->(DbGoTop())
		If ! CHK_REG->(Eof())

			DbSelectArea("ZCI")
			ZCI->( DbGoTo(Val(cValToChar(CHK_REG->REC))) )

			If Alltrim(cValToChar(ZCI->ZCI_JSON)) == Alltrim(cValToChar(cBody))

				//
				cHoraExec := ELAPTIME(cHoraExec, Time())
				//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Alteração enviada em duplicidade, pedido " + cNumPed,cUrlServ,"PUT",cHoraExec,,cNumSF)
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Alteração enviada em duplicidade, pedido " + cNumPed,cUrlServ,"PUT",cHoraExec,,cNumSF)

				Self:SetResponse("")

				//
				CHK_REG->(DbCloseArea())
				ZCI->(DbCloseArea())
				SC5->(DbCloseArea())

				RestArea(aArea)

				//
				MSUnlockAll()

				Return .T.

			EndIf

		EndIf

		CHK_REG->(DbCloseArea())

		//
		cFlagApr := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ))

		If cFlagApr <> "R" //Se for diferente de rejeitado pelo comercial.
			
			If geraRegistro(oParseJSON,@cErro,@cNumPed,"",nRecno,4) .And. Len(aPedidos) == 0

				Self:SetResponse("")

			Else

				cErroPE := ""
				For i := 1 To Len(aPedidos)

					cErroPE += aPedidos[i][1] + " / "

				Next i

				//
				//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) ,cUrlServ,"PUT",,cNumSF)
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) ,cUrlServ,"PUT",,cNumSF)

				SetRestFault(400,EncodeUtf8("Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE)) )

				//
				If ValType(oParseJSON) == "O"
					FreeObj(oParseJSON)

				Else
					oParseJSON := Nil

				EndIf

				RestArea(aArea)

				//
				MSUnlockAll()

				Return .F.

			EndIf

		Else

			//
			cErro := ""
			If exclPedVend(@cErro,@cNumPed,0,cCodUsuario,cUrlServ)

				//
				//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"PUT",,cNumSF)
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"",cUrlServ,"PUT",,cNumSF)

				Self:SetResponse("")

			Else

				cErroPE := ""
				For i := 1 To Len(aPedidos)

					cErroPE += aPedidos[i][1] + " / "

				Next i

				//
				//Static Call(ADVEN075P,grvLog,cCodUsuario,cIdSFBkp,cNumPed,cBody,"Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) ,cUrlServ,"PUT",,cNumSF)
				//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
				u_VEN075A0(cCodUsuario,cIdSFBkp,cNumPed,cBody,"Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE) ,cUrlServ,"PUT",,cNumSF)

				SetRestFault(400,EncodeUtf8("Erro na alteração do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE)) )

				//
				If ValType(oParseJSON) == "O"
					FreeObj(oParseJSON)

				Else
					oParseJSON := Nil

				EndIf

				RestArea(aArea)

				//
				MSUnlockAll()

				Return .F.

			EndIf

		EndIf

		//
		If ValType(oParseJSON) == "O"
			FreeObj(oParseJSON)

		EndIf
		oParseJSON := Nil

	Else

		SetRestFault(400,EncodeUtf8("Verificar se o json da requisição está condizente com a operação (alteração ou corte)."))

		RestArea(aArea)

		//
		MSUnlockAll()

		Return .F.

	EndIf

	//
	RestArea(aArea)

	//
	MSUnlockAll()

	//RpcClearEnv()

Return .T.
/*/{Protheus.doc} User Function Delete
	Método DELETE. Chamado 037261.
	@type  Function
	@author Everson
	@since 11/09/2017
	@version 01
	/*/
WsMethod Delete WsService pedidosdevenda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cBody 		:= Alltrim(cValToChar(Self:GetContent()))
	Local cErro			:= ""
	Local oParseJSON
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	//Local aProp			:= {}
	Local cNumPed		:= ""
	Local aParametros	:= Self:aURLParms
	Local cErroPE		:= ""
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	Local cPedBkp		:= ""
	Local cUrlServ		:= Self:GetPath()
	Local nRecno		:= 0
	Local i				:= 1

	Local cTagFil		:= ""
	Local cEmpJson		:= cEmpAnt
	Local cFilJson		:= cFilAnt
	Local cIdSFBkp		:= ""
	
	Private aPedidos	:= {}

	Self:SetContentType(cFormatAceito)

	If Len(aParametros) == 0

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","Obrigatório informar o número do pedido de venda.",cUrlServ,"DELETE")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cNumPed,"","Obrigatório informar o número do pedido de venda.",cUrlServ,"DELETE")

		SetRestFault(400,EncodeUtf8("Obrigatório informar o número do pedido de venda."))

		RestArea(aArea)

		MSUnlockAll()

		Return .F.

	EndIf

	cNumPed := cValToChar(aParametros[1])
	cPedBkp := cValToChar(aParametros[1])

	If Empty(cCodUsuario)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","Código de usuário não informado (UsrVend).",cUrlServ,"DELETE")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cNumPed,"","Código de usuário não informado (UsrVend).",cUrlServ,"DELETE")

		SetRestFault(403,EncodeUtf8("Código de usuário não informado (UsrVend)."))

		RestArea(aArea)

		MSUnlockAll()

		Return .F.

	EndIf

	//*******************************************************//
	// Define a filial de inclusão da requisição.
	//*******************************************************//
	// Ativar, caso necessário.
	if "C5_EXPEDITION"$cBody

		//*******************************************************//
		// Define a filial de inclusão da requisição.
		//*******************************************************//
		If ! FWJsonDeserialize(cBody, @oParseJSON) //Everson - 13/04/2022. Chamado 69520.

			//
			//CONOUT("ADVEN075P,grvLog 13"+cBody)
			//StaticCall(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"DELETE")
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_VEN075A0(cCodUsuario,"",cNumPed,cBody,"Ocorreu erro na desserialização do Json.",cUrlServ,"DELETE")

			SetRestFault(400,EncodeUtf8("Ocorreu erro na desserialização do Json."))

			RestArea(aArea)

			MSUnlockAll()

			Return .F.

		EndIf

		if valtype(oParseJSON:cabecalho:C5_EXPEDITION) !='U'
			
			cTagFil := Alltrim(cValtochar(oParseJSON:cabecalho:C5_EXPEDITION))
			
			if Len(cTagFil) >=4
				cEmpJson := left(cTagFil,2)
				cFilJson := Substring(cTagFil,3,2)
			endif
		endif

		cIdSFBkp 	:= oParseJSON:cabecalho:C5_XPEDSAL

	endif


	if cEmpAnt <> cEmpJson .OR. cFilAnt <> cFilJson
		RpcClearEnv() 
		RPCSetType(3) 
		RpcSetEnv(cEmpJson,cFilJson,,,,GetEnvServer(),{ })
	endif

	//
	//nRecno := Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","",cUrlServ,"DELETE")
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	nRecno := u_VEN075A0(cCodUsuario,"",cNumPed,"","",cUrlServ,"DELETE")
	//Atribui usuário.
	__cUserId := cCodUsuario

	//
	If cFormato <> cFormatAceito

		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"DELETE")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cNumPed,"","Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado.",cUrlServ,"DELETE")

		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabeçalho da requisição, não suportado."))

		RestArea(aArea)

		MSUnlockAll()

		Return .F.

	EndIf
	
	If Empty(cNumPed)
	
		Self:SetResponse("")

		RestArea(aArea)

		MSUnlockAll()
		
		Return .T.
			
	EndIf

	If exclPedVend(@cErro,@cNumPed,nRecno,cCodUsuario,cUrlServ) .And. Len(aPedidos) == 0

		Self:SetResponse("")

	Else

		cErroPE := ""
		For i := 1 To Len(aPedidos)

			cErroPE += aPedidos[i][1] + " / "

		Next i

		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","Erro na exclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE),cUrlServ,"DELETE")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cNumPed,"","Erro na exclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE),cUrlServ,"DELETE")

		SetRestFault(400,EncodeUtf8("Erro na exclusão do pedido: " + Iif(Empty(cErroPE),cErro,cErroPE)) )

		RestArea(aArea)

		MSUnlockAll()

		Return .F.

	EndIf

	RestArea(aArea)

	MSUnlockAll()

	//RpcClearEnv()

Return .T.

/*/{Protheus.doc} geraRegistro
	MsExecauto pedido de venda (criação). Chamado 037261.
	@type  Static Function
	@author Everson
	@since 11/09/2017
	@version 01
	/*/
Static Function geraRegistro(oParseJSON,cErro,cNumPed,cJobAux,nRecno,nOPc,cSintegra)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lRet			:= .F.	
	//Local cQuery		:= ""
	//Local cDoc			:= ""
	//Local aCabec		:= {}
	//Local aItens		:= {}
	//Local aItem			:= {}
	//Local aErroLog		:= {}
	//Local k				:= 1
	Local i				:= 1
	//Local cPulaLinha	:= Chr(13) + Chr(10)
	//Local nAuxInvalido	:= 0
	Local cProduto		:= ""

	//Local cErroPE		:= ""
	//Local cNumChkPedsal	:= ""
	Local cVendCdCli	:= ""

	Local cObrPdCp		:= ""
	Local cPedidoPC		:= ""
	Local cRedeOP		:= GetMV("MV_#REDEOP")
	Local lRedeOp		:= .F.
	Local cCliente		:= ""
	Local cNumProth	    := ""
	Local nAuxTot		:= 0 //Everson - 08/07/2019. Chamado T.I.
	Local cMsgNF		:= ""
	Local cRetCons		:= "" //Everson - 30/10/2019,. Chamado 052760.
	Local lChkSint		:= GetMv("MV_#CHKSIN",,.F.) //Everson - 30/10/2019,. Chamado 052760.
	Local cNmUltPed		:= GetMv("MV_#VLDPSF") //Everson - 27/01/2020. Chamado T.I.

	Default cErro		:= ""
	Default cNumPed		:= ""
	Default cJobAux		:= ""
	Default nOPc        := 4
	Default cSintegra	:= ""

	//
	cErro    := ""
	cNumPed  := ""
	
	//Valida o tipo do pedido de venda.
	If ! ( Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) $("VE|BO|VO|RO|EF") )
		cErro := "Tipo de saída inválido " + Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) + "."
		RestArea(aArea)
		Return lRet	

	EndIF
	
	//
	If Empty(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_BLQ)))
		cErro := "Tag C5_BLQ não está preenchida."
		lRet  := .F.
		RestArea(aArea)
		Return lRet

	EndIf
	
	//
	cCliente := Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI))

	//Everson - 30/10/2019,. Chamado 052760.
	If lChkSint

		//
		If nOPc == 3
			
			//
			cUF := Alltrim(Posicione("SA1",1,xFilial("SA1") + cCliente,"A1_EST" ))
			cIE := StrTran(StrTran(StrTran(Alltrim(Posicione("SA1",1,xFilial("SA1") + cCliente,"A1_INSCR" )),".",""),"-",""),"/","")
			cRetCons := ConsIE(cIE,cUF)
			If cRetCons = "0"
				cSintegra := "Bloqueado Sintegra " + DToC(Date()) + " " + Time()
				cErro := "Cliente " + cCliente + " bloqueado Sintegra. " + DToC(Date()) + " " + Time()
				lRet  := .F.
				RestArea(aArea)
				Return lRet	
				
			ElseIf cRetCons = "1"
				cSintegra := "Liberado Sintegra " + DToC(Date()) + " " + Time()

			ElseIf cRetCons = "X"
				cSintegra := "Erro consuta Sintegra " + DToC(Date()) + " " + Time()

			ElseIf cRetCons = "Y"
				cSintegra := "Isento ou Exportação " + DToC(Date()) + " " + Time()

			EndIf 

		EndIf

	EndIf

	//Everson - 30/10/2019,. Chamado 052760.
	Conout(DToc(Date()) + " " + Time() + " ADVEN086P - geraRegistro - Sintegra - cRetCons/cSintegra " + cValToChar(cRetCons) + " " + cValToChar(cSintegra) )
	
	//Valida se cliente existe.
	If Empty(Alltrim(cValToChar(Posicione("SA1",1,xFilial("SA1") + cCliente,"A1_MSBLQL" ))))
		cErro := "Cliente " + cCliente + " inexistente."
		lRet  := .F.
		RestArea(aArea)
		Return lRet	

	EndIf 
	
	//Valida se cliente está bloqueado.
	If Alltrim(cValToChar(Posicione("SA1",1,xFilial("SA1") + cCliente,"A1_MSBLQL" ))) == "1"
		cErro := "Cliente " + cCliente + " bloqueado."
		lRet  := .F.
		RestArea(aArea)
		Return lRet	

	EndIf 

	//Valida pedido de remessa de venda a ordem.
	If Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) == "RO" .And. Empty(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XPEDORD)))
		cErro := "Para remessa de venda a ordem é necessário informar o pedido de origem (C5_XPEDORD)."
		lRet  := .F.
		RestArea(aArea)
		Return lRet	

	Endif
	
	//Valida se o pedido de origem está preenchido sem necessidade.
	If Alltrim(cValToChar(oParseJSON:CABECALHO:tpSaida )) <> "RO" .And. ! Empty(Alltrim(cValToChar(oParseJSON:CABECALHO:C5_XPEDORD)))
		cErro := "Pedidos que não sejam de remessa à ordem não podem ter a tag C5_XPEDORD preenchida."
		lRet := .F.
		RestArea(aArea)
		Return lRet	
	
	EndIf
	
	//Everson-01/08/2019.Chamado T.I.
	cMsgNF := ""
	cMsgNF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOTA))
	cMsgNF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT2))
	cMsgNF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT3))
	cMsgNF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT4))
	cMsgNF += Alltrim(cValToChar(oParseJSON:CABECALHO:C5_MENNOT5))
	
	//
	If ! Empty(cMsgNF)
		cMsgNF := DecodeUTF8(cMsgNF)

		//Valida conversão de texto.
		If Empty(cMsgNF)
			cErro := "Mensagem para nota fiscal possui caractere especial."
			RestArea(aArea)
			Return lRet
					
		EndIf
		
	EndIf

	
	//
	cVendCdCli := Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_VEND")

	cObrPdCp   := Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_XOBRPC")

	lRedeOp    := Iif( Posicione("SA1",1, xFilial("SA1") + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_CLIENTE)) + Alltrim(cValToChar(oParseJSON:CABECALHO:C5_LOJACLI)),"A1_REDE") $ cRedeOp,.T.,.F.)
	
	//Valida o operador logístico.
	If lRedeOp .And. Empty( Alltrim(cValToChar(oParseJSON:CABECALHO:C5_OPLOG )) )
		cErro := "Necessário informar o operador logístico."
		RestArea(aArea)
		Return lRet
				
	EndIf
	
	//Everson - 08/07/2019. Chamado T.I.
	If Len(oParseJSON:ITENS) <= 0
		cErro := "Pedido sem itens."
		RestArea(aArea)
		Return lRet		
		
	EndIf

	//
	For i := 1 To Len(oParseJSON:ITENS)

		//Registros excluídos no SalesForce são desconsiderados.
		If Upper(Alltrim(cValToChar(oParseJSON:ITENS[i]:excluir))) == "S" .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_UNSVEN)) <= 0 .Or. Val(cValToChar(oParseJSON:ITENS[i]:C6_QTDVEN)) <= 0 .And.!Empty(cValToChar(oParseJSON:ITENS[i]:C6_ITEM))
			Loop

		EndIf 
		
		//
		cProduto := Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PRODUTO ))
		
		//Valida se o produto existe.
		If Empty(Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_MSBLQL" ))))
			cErro := "Produto " + cProduto + " inexistente."
			RestArea(aArea)
			Return lRet	

		EndIf 
		
		//Valida se o produto está bloqueado.
		If Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_MSBLQL" ))) == "1"
			cErro := "Produto " + cProduto + " bloqueado."
			RestArea(aArea)
			Return lRet	

		EndIf 
		
		//
		cPedidoPC := Iif( Empty(Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI ))), Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_NUMPCOM )) ,Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_PEDCLI )) )
		
		//
		If lRedeOp .And. Empty(cPedidoPC)
			cErro := "Necessário informar o número do pedido de compra do cliente."
			RestArea(aArea)
			Return lRet
			
		End
		
		//
		If cObrPdCp == "1" .And. ( Empty(cPedidoPC) .Or. Empty(Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))) )
			cErro := "Necessário informar o número do pedido de compra do cliente e o item."
			RestArea(aArea)
			Return lRet

		EndIf
		
		//Everson-01/08/2019.Chamado T.I.
		//Everson-06/08/2019.Chamado T.I.
		If Alltrim(Transform(Val(Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC))),"9999999999")) <> Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC)) .And. ! Empty(Alltrim(cValToChar(oParseJSON:ITENS[i]:C6_ITEMPC)))
			cErro := "Campo ITEM PED.COM só pode ser preenchido com números 0-9, no item do Pedido !!! C6_ITEMPC."
			RestArea(aArea)
			Return lRet
					
		EndIf
		
		nAuxTot++
		
	Next i
	
	//Everson - 08/07/2019. Chamado T.I.
	If nAuxTot <= 0
		cErro := "Pedido sem itens."
		lRet := .F.
		RestArea(aArea)
		Return lRet		
		
	EndIf
	
	//Coloca pedido como pendente de processamento.
	If nOPc == 3

		//Everson - 27/01/2020. Chamado T.I.
		cNumProth := getSC5()
		If cNumProth <= cNmUltPed
			cErro := "Sequêncial do pedido está incorreto. Retorno: " + cNumProth
			lRet := .F.
			RestArea(aArea)
			Return lRet	

		EndIf
		//

		//
		Begin Transaction
		
			DbSelectArea("ZCI")
			DbGoTo( Val(cValToChar(nRecno)) )
			If RecLock("ZCI",.F.)
					ZCI->ZCI_NUMP   := cNumProth
					ZCI->ZCI_TMPR   := "PENDPROC"
					ZCI->ZCI_CONSIN := cSintegra //Everson - 30/10/2019,. Chamado 052760. 
				ZCI->(MsUnlock())
	
			Else
				RollBackSx8()
				DisarmTransaction()
				cErro += EncodeUtf8("Erro reclock ZCI.")
				lRet := .F.
				Break
				Return lRet	
		
			EndIf
			
			//
			cNumPed := cNumProth
			
			//
			ConfirmSX8()
		
		End Transaction 
		
		//
		Conout(DToC(Date()) + " " + Time() + " ADVEN086P -  geraRegistro - Requisição de inclusão " +  cNumPed)
	
	Else
		
		//
		DbSelectArea("ZCI")
		DbGoTo( Val(cValToChar(nRecno)) )
		RecLock("ZCI",.F.)
			ZCI->ZCI_TMPR := "PENDPROC"
		ZCI->(MsUnlock())	
	
	EndIf
	
	//
	lRet := .T.
	
Return lRet
/*/{Protheus.doc} getSC5
	Obtém número do Protheus. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 05/06/2018
	@version 01
/*/
Static Function getSC5()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local cPedido 	:= ""
	//Local cQuery	:= ""  

	// @history 08/09/2021, Macieir, Chamado T.I. Reforça na Validação do número sequencial do pedido de venda após golive cloud
	Do While .t.

		cPedido 	:= GetSxeNum("SC5","C5_NUM") 
		//CONOUT("cPedido"+ cPedido)
		//CONOUT("cEmpAnt,cFilAnt"+ cEmpAnt +"-"+cFilAnt)
		// SC5
		DbSelectArea("SC5")
		SC5->( DbSetOrder( 01 ) )
		While SC5->( dbSeek( xFilial( "SC5" ) + cPedido ) )
			ConfirmSX8()
			cPedido := GetSxeNum( "SC5", "C5_NUM" )
		EndDo
		ConfirmSX8() 

		// ZCI
		DbSelectArea("ZCI")
		ZCI->( DbSetOrder( 2 ) )
		While ZCI->( dbSeek( xFilial( "ZCI" ) + cPedido ) )
			ConfirmSX8()
			cPedido := GetSxeNum( "SC5", "C5_NUM" )
		EndDo
		ConfirmSX8() 

		// Checo após ZCI
		SC5->( dbSetOrder(1) )
		If SC5->( !dbSeek(FWxFilial("SC5")+cPedido) )
			Exit
		EndIf

	EndDo

	DbSelectArea("SC5")
	ConfirmSX8()

	//CONOUT("cRet "+ cPedido)
	//
	RestArea(aArea)
                         
Return cPedido

/*/{Protheus.doc} exclPedVend
	MsExecauto pedido de venda (exclusão). Chamado 037261.
	@type  Static Function
	@author Everson
	@since 13/09/2017
	@version 01
	/*/
Static Function exclPedVend(cErro,cNumPed,nRecno,cCodUsuario,cUrlServ)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lRet			:= .F.	
	//Local cDoc			:= ""
	//Local aCabec		:= {}
	//Local aItens		:= {}
	//Local aItem			:= {}
	//Local aErroLog		:= {}
	//Local k				:= 1
	//Local i				:= 1
	//Local cPulaLinha	:= Chr(13) + Chr(10)
	//Local nAuxInvalido	:= 0
	//Local cProduto		:= ""

	Default cErro		:= ""
	Default nRecno		:= 0
	
	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If SC5->(DbSeek(xFilial("SC5") + cNumPed))

		//
		If ! Empty(Alltrim(cValToChar(SC5->C5_PLACA)))
	
			//
			cErro += EncodeUtf8("Pedido de venda número " + cNumPed + " já associado a veículo.")
			SC5->(DbCloseArea())
	
			RestArea(aArea)
	
			Return .F.
	
		EndIF
		
		//
		If ! Empty(Alltrim(cValToChar(SC5->C5_NOTA)))
	
			//
			cErro +=  EncodeUtf8("Pedido de venda número " + cNumPed + " já possui nota fiscal.")
			SC5->(DbCloseArea())
	
			RestArea(aArea)
	
			Return .F.
	
		EndIF

	EndIf

	SC5->(DbCloseArea())
	
	If nRecno == 0
	
		//nRecno := Static Call(ADVEN075P,grvLog,cCodUsuario,"",cNumPed,"","",cUrlServ,"DELETE")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		nRecno := u_VEN075A0(cCodUsuario,"",cNumPed,"","",cUrlServ,"DELETE")
	
	EndIf
	
	//Coloca pedido como pendente de processamento.
	Begin Transaction
		
		//
		DbSelectArea("ZCI")
		DbGoTo( Val(cValToChar(nRecno)) )
		If RecLock("ZCI",.F.)
				ZCI->ZCI_TMPR := "PENDPROC"
			ZCI->(MsUnlock())
			
		Else
			DisarmTransaction()
			cErro += EncodeUtf8("Erro reclock ZCI.")
			Break
			RestArea(aArea)
			Return lRet	
	
		EndIf
	
	End Transaction 

	//
	lRet := .T.

Return lRet
/*/{Protheus.doc} ConsIE
	Consulta situação do cliente no Sintegra. Chamado 052760. 
	@type  Static Function
	@author user
	@since 30/10/2019
	@version 01
	/*/
Static Function ConsIE(cIE,cUF,oObjt) //01/11/2019, Everson, Chamado 052760.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()	
	Local cRet		:= "X"
	Local oWsdl		:= Nil
	Local xRet		:= Nil
	Local aOps 		:= {}
	Local aSimple 	:= {}
	Local cId   	:= Alltrim(GetMv("MV_#IDCIE",,"000001"))
	Local cUrlW		:= Alltrim(GetMv("MV_#URLCIE",,"http://10.5.1.1:8080/NFeSBRA.apw?WSDL"))
	Local nTimeOut	:= GetMv("MV_#TMPCIE",,4)
	Local cRest		:= ""
	Local cError	:= ""	
	Local cWarning	:= ""

	//
	Default oObjt	:= Nil

	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN086P - Início - ConsIE " )

	//
	If Empty(cIE) .Or. "ISENT" $ cIE .Or. cUF == 'EX'
		RestArea(aArea)
		cRet := "Y"
		Return cRet
		
	EndIf 

	//Cria o objeto da classe TWsdlManager.
	oWsdl := TWsdlManager():New()

	//Seta timeout.
	oWsdl:nTimeout := nTimeOut

	//Faz o parse de uma URL.
	xRet := oWsdl:ParseURL( cUrlW )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - cUrlW: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf
	
	//Pega as operações disponíveis.
	aOps := oWsdl:ListOperations()
	
	//Valida as operações.
	If Len( aOps ) == 0
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - aOps: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf

	//Define a operação.
	xRet := oWsdl:SetOperation( "CONSULTACONTRIBUINTE" )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - SetOperation: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf

	// Define o valor de cada parâmeto necessário
	aSimple := oWsdl:SimpleInput()
	
	//Token
	xRet := oWsdl:SetValue(0, "TOTVS" )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - Token: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf
	
	//Id
	xRet := oWsdl:SetValue(1, cId )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - cId: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf

	//Id
	xRet := oWsdl:SetValue(2, cUF )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - UF: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf

	//IE
	xRet := oWsdl:SetValue(5, cIE )
	If xRet == .F.
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - IE: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf	

	// Envia a mensagem SOAP ao servidor
	xRet := oWsdl:SendSoapMsg()
	If xRet == .F.
		conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - SendSoapMsg: " + oWsdl:cError )
		RestArea(aArea)
		Return cRet

	EndIf

	// Pega a mensagem de resposta
	cRest := oWsdl:GetSoapResponse()

	//
	oXml := XmlParser(cRest, "_", @cError, @cWarning )
	If (oXml == Nil )
		Conout(DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Erro - Falha ao gerar Objeto XML : " + cError + " / " + cWarning)
		RestArea(aArea)
		Return cRet

	EndIf

	//
	oObjt := oXml

	//
	If Type('oXml:_SOAP_ENVELOPE:_SOAP_BODY:_CONSULTACONTRIBUINTERESPONSE:_CONSULTACONTRIBUINTERESULT:_NFECONSULTACONTRIBUINTE:_SITUACAO') <> "U"
		cRet := Alltrim(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_CONSULTACONTRIBUINTERESPONSE:_CONSULTACONTRIBUINTERESULT:_NFECONSULTACONTRIBUINTE:_SITUACAO:TEXT)
		
	Else 
		Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE- Erro - Não retornou situação a tag de situação do contribuinte." )

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADVEN086P - ConsIE - Situação - cRet - " + cRet )

	//
	RestArea(aArea)

Return cRet

/*/{Protheus.doc} u_VEN086A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_VEN086A0( uPar1, uPar2 )
Return( ConsIE( uPar1, uPar2 ) )


/*/{Protheus.doc} u_VEN086A1
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_VEN086A1( uPar1, uPar2, uPar3, uPar4, uPar5 )
Return( exclPedVend( uPar1, uPar2, uPar3, uPar4, uPar5 ) )
