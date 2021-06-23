#Include "Totvs.ch"

/*{Protheus.doc} User Function CEXMITNFE
	Ponto de entrada apos carregar itens para lancar NF-e PARAMIXB -ExpA[1]	- Itens da NF, ExpA[2]	- Logico ExpA[3] - Mensagem caso retorno seja .F.
	@type  Function
	@author Amedeo D. Paoli
	@since 16/05/2017
	@version 01
	@history Fernando Sigoli - 29/04/2019 - chamado TI     - Tratamento error log  array out of bounds (17 of 16)
	@history William Costa   - 29/06/2020 - chamado 058988 - Identificado falha no carregamento do campo D1_LOCAL vindo pela central, feito regra da SBZ nesse ponto de entrada.
	@history Everson - 16/06/2021 - Chamado 15600 - Tratamento para carregar o centro de custo, lote e descriçaõ do lote do pedido de compra.
	@history Everson - 17/06/2021 - Chamado 15600 - Tratamento para carregar o centro de custo, lote e descriçaõ do lote do pedido de compra.
*/	

User Function CEXMITNFE()
	
	Local aRetorno	:= PARAMIXB
	Local aAreaAt	:= GetArea()
	Local lRetorno	:= .T.
	Local cMensagem	:= ""
	Local nX		:= 0
	Local nPosFil   := 0
	Local nPosNot   := 0
	Local nPosSer   := 0
	Local nPosUnd   := 0
	Local cNroOco   := ""
	Local nPosLocal := 0
	Local nProduto  := 0
	Local nCont     := 0

	//Everson - 16/06/2021. Chamado 15600
	Local nPosCC  := 0
	Local nPosPC  := 0
	Local nPosIPC := 0
	Local cPed   := ""
	Local cIPed  := ""
	//
              
	If cTipoNF == 'D' .AND. cfilant $ '02'

		For nX := 1 To Len( aRetorno )
		                                                                         
			nPosFil	:= Ascan( aRetorno[nX], { |x| Alltrim( x[1] ) == "D1_FILIAL"  } )
			nPosNot	:= Ascan( aRetorno[nX], { |x| Alltrim( x[1] ) == "D1_NFORI"   } )
			nPosSer	:= Ascan( aRetorno[nX], { |x| Alltrim( x[1] ) == "D1_SERIORI" } )  
			nPosUnd	:= Ascan( aRetorno[nX], { |x| Alltrim( x[1] ) == "D1_UM"      } )  
			
			//Inicio :Chamado: TI - Fernando Sigoli 29/04/2019
		    If nPosNot > 0 .and. nPosSer > 0  
		    
				cNroOco := Posicione("SZD",1,xFilial("SZD")+aRetorno[nPosFil][nPosNot][2]+aRetorno[nPosFil][nPosSer][2],"ZD_CONTROL")
			
			Else
			
				Aviso("CEXMITNFE","Nota/Serie de Origem não informada!",{"OK"},3)
				lRetorno := .F.  
				Exit
			
			EndIf
			//Fim: Chamado: TI - Fernando Sigoli 29/04/2019
			
			If !Empty(cNroOco)
			
				Aadd( aRetorno[ nX ],	{ "D1_CTRDEVO",  Alltrim(cNroOco)  ,Nil } )
			
			Else
			
				Aviso("CEXMITNFE","Ocorrência não informada!",{"OK"},3)
				lRetorno := .F.  
				Exit
			
			EndIf
			
			If Empty(aRetorno[nPosFil][nPosUnd][2]) 
			
				Aviso("CEXMITNFE","Unidade de Medida não informada!",{"OK"},3)
				lRetorno := .F.  
				Exit
			
			EndIf
		
		Next nX
	
	EndIf

	// *** INICIO CHAMADO WILL 058988 *** //
	IF cTipoNF == 'N'

		FOR nCont := 1 TO LEN(aRetorno)
		                                                                         
			nPosLocal := Ascan(aRetorno[nCont],{ |x| Alltrim( x[1] ) == "D1_LOCAL"})
			nProduto  := Ascan(aRetorno[nCont],{ |x| Alltrim( x[1] ) == "D1_COD"})

			aRetorno[nCont][nPosLocal][2] := IIF(!RetArqProd(aRetorno[nCont][nProduto][2]),POSICIONE("SBZ",1,FWxFilial("SBZ")+aRetorno[nCont][nProduto][2],"BZ_LOCPAD"),POSICIONE("SB1",1,FWxFilial("SB1")+aRetorno[nCont][nProduto][2],"B1_LOCPAD")) //ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA 

			//Everson - 16/06/2021. Chamado 15600.
			nPosCC 	 := Ascan(aRetorno[nCont],{ |x| Alltrim( x[1] ) == "D1_CC"})
			nPosPC   := Ascan(aRetorno[nCont],{ |x| Alltrim( x[1] ) == "D1_PEDIDO"})
			nPosIPC	 := Ascan(aRetorno[nCont],{ |x| Alltrim( x[1] ) == "D1_ITEMPC"})

			//
			If nPosCC > 0 .And. nPosPC > 0 .And. nPosIPC > 0
				cPed   := aRetorno[nCont][nPosPC][2]
				cIPed  := aRetorno[nCont][nPosIPC][2]

				//
				If ! Empty(cPed) .And. ! Empty(cIPed)
					DbSelectArea("SC7")
					SC7->(DbSetOrder(1))
					If SC7->(DbSeek( FWxFilial("SC7") + cPed + cIPed ))

						//
						If Empty(aRetorno[nCont][nPosCC][2])
							aRetorno[nCont][nPosCC][2] := SC7->C7_CC

						EndIf

						//
						If ! Empty(Alltrim(cValToChar(SC7->C7_XLOTECC))) //Everson - 17/06/2021 - Chamado 15600.
							Aadd(aRetorno[nCont],{"D1_XLOTECC", SC7->C7_XLOTECC, Nil})
							Aadd(aRetorno[nCont],{"D1_XDLOTCC", SC7->C7_XDLOTCC, Nil})

						EndIf

					EndIf

				EndIf
				//Fim - Everson - 16/06/2021. Chamado 15600.

			EndIf

		NEXT nCont	

	ENDIF 
	
	// *** FINAL CHAMADO WILL 058988 *** //
	RestArea( aAreaAt )

Return({aRetorno,lRetorno,cMensagem})
