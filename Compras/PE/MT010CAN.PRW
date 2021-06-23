#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function MT010CAN
	Ponto de entrada adiciona avalia bloqueio de cadastro. Chamado T.I.
	@type  Function
	@author Everson
	@since 02/12/2019
	@version 01
	/*/
User Function MT010CAN()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea 	:= GetArea()
    Local lAtzEdt	:= GetMv("MV_#ATLEDT",,.F.) //Everson - 28/11/2019 - Chamado T.I.
	Local nOpc  	:= ParamIxb[1] //Everson - 28/11/2019 - Chamado T.I.
	Local nAux		:= 1 //Everson - 02/12/2019 - Chamado T.I.
	Local nAux2		:= 0 //Everson - 02/12/2019 - Chamado T.I.
	Local cEmlLib	:= GetMv("MV_#EMLBP",,"") //Everson - 02/12/2019 - Chamado T.I.
    
    //
	If lAtzEdt .And. Type("aInClApv") <> "U" .And. nOpc = 1
		Conout( DToC(Date()) + " " + Time() +  " MT010CAN - aInClApv - 1 " + cValToChar(Type("aInClApv")))
		Conout( DToC(Date()) + " " + Time() +  " MT010CAN - aInClApv - 2")
		varinfo("aInClApv",aInClApv)

		//
        If Len(aInClApv) > 0
			
			//
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))

			//
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
						Replace ZBE_ROTINA	    With "MT010CAN"
						Replace ZBE_PARAME	    With aInClApv[nAux][2]
					ZBE->(MsUnlock())

					//
					If ! Empty(cEmlLib)
						MsAguarde({||	U_enviaremail(allTrim(cEmlLib), "Bloqueio de Produto", "O produto " + cValToChar(aInClApv[nAux][2])+ " está pendente de aprovação.",,)},"Aguarde","Enviando Email...")

					EndIf
					
					//
					Help(Nil, Nil, "Função MT010CAN", Nil, "O produto " + aInClApv[nAux][2] + " foi submetido à aprovação.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					
					//
					Conout( DToC(Date()) + " " + Time() +  " MT010CAN - aInClApv - 3 " + cValToChar(aInClApv[nAux][2]))

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
    RestArea(aArea)

Return Nil