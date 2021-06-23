#Include 'Protheus.ch'
/*/{Protheus.doc} User Function MT010INC
	Ponto de entrada após inclusão do produto. Chamado: 038814.
	@type  Function
	@author Fernando Sigoli
	@since 26/12/2017
	@version 01
	@history 29/11/2019, Everson, Chamado T.I. Incluído tratamento para efetuar bloqueio de cadastro de produto,
	sendo a avaliação feita no fonte A010TOK.
	/*/
User Function MT010INC()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local cEmail	:= Alltrim(GetMv("MV_#CRTEMA"))
	Local cTitulo   := "Cadastro de produto: "+ Alltrim(SB1->B1_COD) +'-'+ Alltrim(SB1->B1_DESC)
	Local lAtzEdt	:= GetMv("MV_#ATLEDT",,.F.) //Everson - 29/11/2019 - Chamado T.I.
	Local nAux		:= 1 //Everson - 29/11/2019 - Chamado T.I.
	Local nAux2		:= 0
	Local cEmlLib	:= GetMv("MV_#EMLBP",,"") //Everson - 29/11/2019 - Chamado T.I.

	If SB1->B1_TIPO  = 'PA'
	
		cBuffer := "<html>"
		cBuffer += "<head>Cadastro de produto</title><head>"
		cBuffer += "<body style='font-family: Tahoma;'>"
		cBuffer += "<p>Usuário: "+ Alltrim(cUserName)+' Data: '+Dtoc(date()) + " - " + time()+"</p>"
		cBuffer += "<p>Produto: "+Alltrim(SB1->B1_COD)+'-'+Alltrim(SB1->B1_DESC) +"</p>"
		cBuffer += "<p>Grupo: " + SB1->B1_GRUPO+'-'+Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")+ "</p>"
		cBuffer += "</body>"
		cBuffer += "</html>"
		
	
		MsAguarde({||	U_enviaremail(allTrim(cEmail), cTitulo, cBuffer,,)},"Relatório","Aguarde. Enviando Email...",.T.)
	
	EndIf	
	
	// Ricardo Lima - 02/03/18 | Atualiza cadastro de produto no SalesForce
	IF FindFunction("U_ADVEN069P") .And. M->B1_XSALES = '2'
		U_ADVEN069P( Alltrim(M->B1_COD),.F.)
	ENDIF

	//Everson - 29/11/2019 - Chamado T.I.
	Conout( DToC(Date()) + " " + Time() +  " MT010INC - aInClApv - 1 " + cValToChar(Type("aInClApv")))
	If lAtzEdt .And. Type("aInClApv") <> "U"
		Conout( DToC(Date()) + " " + Time() +  " MT010INC - aInClApv - 2")
		varinfo("aInClApv",aInClApv)

		//
        If Len(aInClApv) > 0
			
			//
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			For nAux := 1 To Len(aInClApv)
				SB1->(DbGoTop())
				If aInClApv[nAux] == Nil
					nAux2++
					
				ElseIf Alltrim(aInClApv[nAux][1]) = Alltrim(__cUserId) .And. SB1->( DbSeek(FWxFilial("SB1") + aInClApv[nAux][2] ) )
					
					//
					RecLock("SB1",.F.)
						SB1->B1_XAPROV := "S" //Submete o cadastro do produto para aprovação.
						SB1->B1_MSBLQL := "1" //Bloqueia o cadastro do produto.	
					SB1->(MsUnlock())

					//
					DbSelectArea("ZBE")
						RecLock("ZBE",.T.)
						Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
						Replace ZBE_DATA 	   	With Date()
						Replace ZBE_HORA 	   	With Time()
						Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
						Replace ZBE_LOG	        With "Produto bloqueado " + aInClApv[nAux][2]
						Replace ZBE_MODULO	    With "CONTROLADORIA"
						Replace ZBE_ROTINA	    With "MT010INC"
						Replace ZBE_PARAME	    With aInClApv[nAux][2]
					ZBE->(MsUnlock())
					
					//
					If ! Empty(cEmlLib)
						MsAguarde({||	U_enviaremail(allTrim(cEmlLib), "Bloqueio de Produto", "O produto " + cValToChar(aInClApv[nAux][2])+ " está pendente de aprovação.",,)},"Aguarde","Enviando Email...")

					EndIf

					//
					Help(Nil, Nil, "Função MT010INC", Nil, "O produto " + aInClApv[nAux][2] + " foi submetido à aprovação.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					
					//
					Conout( DToC(Date()) + " " + Time() +  " MT010INC - aInClApv - 3 " + cValToChar(aInClApv[nAux][2]))

					//
					Adel(aInClApv,nAux)
					nAux2++
				
				EndIf

			Next nAux

			//
			If Len(aInClApv) <= nAux2
				aInClApv := Nil

			EndIf
			
		EndIf

	EndIf
	//

	//
	RestArea(aArea)
    
Return Nil