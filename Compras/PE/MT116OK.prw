#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function MT116OK
	Ponto de Entrada - Confirma a exclusão da Nota de Conhecimento de Frete- CTE
	@type User Function
	@author Fernando Sigoli
	@since 30/09/2017
	@history Chamado 034249 - Fernando Sigoli - 30/09/2017 - Confirma a Exclusão da Nota de Conhecimento de Frete - CTE
	@history Chamado 059025 - Abel Babini     - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS
	@history Chamado 3886   - Everson  - 23/10/2020 - Declaração de variável devido a error log.
	@history Chamado 62250  - Leonardo P. Monteiro  - 23/11/2020 - Gravação da data de entrega da Nfe.

	/*/
User Function MT116OK()
	Local aArea	:= GetArea()
	Local ExpL1 := PARAMIXB[1]
	Local ExpL2 := .T.// Validações do usuário 
	Local cPedC := ""

	Local dDtLEmis := GetMV('MV_#DTEMIS') //Everson - 23/10/2020. Chamado 3886.

	If ExpL1 //exclusao
	
		//INICIO Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS
		IF SF1->F1_EMISSAO <= dDtLEmis .AND. ALLTRIM(SF1->F1_STATUS) <> '' //Apenas para Documentos já classificados.
			MsgStop("Nota fiscal não pode ser excluída, pois a data de emissão está bloqueada, Consulte o Depto. Fiscal (MV_#DTEMIS).","Função A100DEL-1")
			ExpL2 := .F.
		ENDIF
		//FIM Chamado 059025 - Abel    - 30/06/2020 - Valida se a Emissão da NF está  dentro do parâmetro MV_#DTEMIS

		IF ExpL2
			Dbselectarea("SD1")
			Dbsetorder(1)	
			If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T. ))	
				While !Eof() .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				
					cPedC := Alltrim(SD1->D1_PEDIDO)					
					Exit						                        
				
					DbSelectArea("SD1")
					SD1->(dbSkip())			
				EndDo
			
			EndIf
			
			If !Empty(cPedC)
				DbSelectArea("SC7")
				SC7->(dbgotop())
				SC7->(dbSetOrder(1)) 
				If DbSeek(xFilial("SC7") + cPedC )
					While SC7->(!EOF()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == cPedC
						RecLock("SC7",.F.)
							SC7->C7_QUJE 	:= 0
							//@history Chamado 62250  - Leonardo P. Monteiro  - 23/11/2020 - Gravação da data de entrega da Nfe.
							SC7->C7_XDTENTR := Stod("")
						MsunLock()  
						SC7->(DbSkip())	
					EndDo
					
				EndIf  
			
			EndIf
		ENDIF
	EndIf

	RestArea(aArea)

Return ExpL2
