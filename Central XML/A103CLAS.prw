#Include "Totvs.ch"

/*/{Protheus.doc} User Function A103CLAS
	Ponto de entrada na Classificacao da NF-e
	@type  Function
	@author Fabritech
	@since 01/03/2018
	@version version
	@history Chamado 048558  - ABEL BABINI - 23/04/2019 - AJUSTE NO TES DE DEVOLUÇÃO CONFORME TES
	@history Ticket  71736   - Abel Babini - 14/06/2022 - Trazer o Armazem da CentralXML
	/*/

User Function A103CLAS()
	Local cCondAT	:= CCONDICAO	//Variavel Private da Rotina MATA103
	Local i := 0
	Local nPosLoc	:= Ascan( aHeader, { |x| Alltrim( x[2] ) == "D1_LOCAL" 	} )
	
	// *** Específico ADORO - INICIO ABEL BABINI 23/04/2019 CHAMADO 048558 || FISCAL || RENATA || CORRIGIR A TES DE DEVOLUÇÃO CONFORME TES DO DOC. DE SAÍDA
	Local cAliasSD1 := PARAMIXB[1] //ABEL BABINI
	
	IF (cAliasSD1)->D1_TIPO == 'D' .AND. ALLTRIM((cAliasSD1)->D1_NFORI)!=''
		nPos:=Len(aCols)
		aCols[nPos,10]	:= Posicione('SF4',1,xFilial('SF4')+Posicione('SD2',3,xFilial('SD2')+(cAliasSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI),"D2_TES"),'F4_TESDV')
	ENDIF
	// *** Específico ADORO - FIM ABEL BABINI 23/04/2019 CHAMADO 048558 || FISCAL || RENATA || CORRIGIR A TES DE DEVOLUÇÃO CONFORME TES DO DOC. DE SAÍDA
	
	//Caso venha da Central XML, verifica se a condicao de pagamento foi alterada
	If IsInCallStack( "U_CENTNFEXM" )
		If Alltrim( SF1->F1_COND ) <> Alltrim( cCondAT )
			CCONDICAO	:= SF1->F1_COND
		EndIf

		//INICIO Ticket  71736   - Abel Babini - 14/06/2022 - Trazer o Armazem da CentralXML
		IF (cAliasSD1)->D1_TIPO == 'D' .AND. !Empty(Alltrim(RECNFXMLITENS->XIT_LOCAL))
			For i:=1 to Len(aCols)
				aCols[i, nPosLoc] := Alltrim(RECNFXMLITENS->XIT_LOCAL)
			Next i
		ENDIF
		//FIM Ticket  71736   - Abel Babini - 14/06/2022 - Trazer o Armazem da CentralXML
	EndIf
	
Return Nil
