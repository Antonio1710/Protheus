#Include "Totvs.ch"
       

/*/{Protheus.doc} User Function CEXMITCTE
  P.E Central XML para ajustar TES do pedido conforme parametro   
  @type  Function
  @author Richard Branco
  @since 28/09/19
  @history Chamado 057474  - Richard Branco - 27/04/2020 - ajuste no Return da função, adicionado lRetorno, cMensagem 
	@history Ticket  067715  - Abel Babini    - 28/02/2022 - Local Padrão para Frete
  /*/

User Function CEXMITCTE()
	
Local aItens	:= PARAMIXB
Local cArea     := GetArea()
Local lRetorno	:= .T.
Local cMensagem	:= ""
// Ticket  067715  - Abel Babini    - 28/02/2022 - Local Padrão para Frete
Local nG	:= 0
Local cLcPdr := ''
Local nPsProd := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E para ajustar TES do pedido conforme parametro ')
	
	
//Atualiza dados da NF (Itens)
If Len( aItens ) > 0

	For nG := 1 To Len( aItens )
	
		nPosTes := Ascan( aItens[nG],{ |x| Alltrim( x[1] ) == "D1_TES"		} )
		nPosPed := Ascan( aItens[nG],{ |x| Alltrim( x[1] ) == "D1_PEDIDO" 	} )
		nPsItem := Ascan( aItens[nG],{ |x| Alltrim( x[1] ) == "D1_ITEMPC" 	} )
		// INICIO Ticket  067715  - Abel Babini    - 28/02/2022 - Local Padrão para Frete
		nPsLoca := Ascan( aItens[nG],{ |x| Alltrim( x[1] ) == "D1_LOCAL" 	} )
		nPsProd := Ascan( aItens[nG],{ |x| Alltrim( x[1] ) == "D1_COD" 	} )
		If nPsProd != 0
			cLcPdr	:= Alltrim(POSICIONE("SBZ",1,xFilial("SBZ")+aItens[nG][nPsProd][2],"BZ_LOCPAD"))
		Endif
		IF xFilial() == '03' .And. cLcPdr != ''
	    aItens[nG][nPsLoca][2] := cLcPdr
		ENDIF
		// FIM Ticket  067715  - Abel Babini    - 28/02/2022 - Local Padrão para Frete

		If nPosTes > 0 .And. nPosPed > 0 .And. nPsItem > 0

			cTes		:= aItens[ nG ][ nPosTes ][ 2 ]
			cPedido		:= aItens[ nG ][ nPosPed ][ 2 ]
			cItem		:= aItens[ nG ][ nPsItem ][ 2 ]
			
			DbSelectArea("SC7")
			DbSetOrder(1)
	
			If SC7->( DbSeek( xFilial("SC7") + cPedido + cItem) ) .AND. !Empty(cPedido) .AND. !Empty(cTes)
						
				RecLock( "SC7", .F.)
					SC7->C7_TES	:= cTes
				MsUnlock()
			EndIf
	
		EndIf

	Next nG
	
EndIf

RestArea(cArea)


Return { aItens , lRetorno, cMensagem } //Richard Branco - 27/04/2020 -ajuste no Return da função, adicionado lRetorno, cMensagem 

