#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#Define STR_PULA        Chr(13)+ Chr(10)

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA116BUT     ºAutor  ³Fernando Sigoli   ºData ³  25/09/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 															   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Compras. Chamado: 034249                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     

*/
User Function MA116BUT()

Local nOpcX    := PARAMIXB[1]
Local aBut     := PARAMIXB[2]    

AAdd(aBut,{ '* PEDIDO' ,{|| ATUPEDC() }, 'Pedido Compras','Pedido' } ) 

Return aBut


//vincula o pedido de compra, assim como os itens no documento de entrada CTE  
Static Function ATUPEDC()

Local nCont := 0

Private cCTEPed   := space(6)
Private cCTEItem  := space(4) 


	Define Font oBold12 Name 'Arial' Size 12, 12 Bold  
	Define Msdialog oDlg2 Title "  CTE  " from 00,00 TO 180,320 pixel
	
		@ 022,010 Say "Pedido de Compra..: " Size 50,17 FONT oBold12  Of oDlg2 Pixel
		@ 022,070 Msget cCTEPed F3("SC7CTE") Size 20,07 FONT oBold12  of oDlg2 Pixel 
	
	Define SBUTTON from 045,050 type 1 Action GrPedFrete() Enable OF oDlg2 
	Define SBUTTON from 045,080 type 2 Action ( oDlg2:End()) Enable OF oDlg2 PIXEL
	
	Activate Msdialog oDlg2 center
                                                                                                                 
Return


Static Function GrPedFrete()

Local nCdPed   	 := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_PEDIDO" } )
Local nProdu 	 := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_COD" 	  } )
Local nItPed 	 := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEMPC" } ) 
Local nPdLoc     := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"  } ) 
Local nVlTot     := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_TOTAL"  } ) 
Local lAchou     := .F.
Local nVlrTotPED := 0 
Local nVlrTotCTE := 0
	
DbSelectArea("SC7")
SC7->(dbgotop())
SC7->(dbSetOrder(1)) 
If DbSeek(xFilial("SC7") + cCTEPed)
		
	
	If SC7->C7_CONAPRO == "B"
	
		MsgAlert("PC Bloqueado. Favor verificar!")
		Return .T. 
	
	ElseIf SC7->C7_QUJE >= SC7->C7_TOTAL 
		
		MsgAlert("Pedido Encerrado, Verifique!")
		Return .T. 
	
	EndIf
    
    CCONDICAO := Alltrim(SC7->C7_COND)
    
   	While SC7->(!EOF()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == cCTEPed
		
		lAchou := .F.	        
		
		For nCont := 1 to Len(aCols) 
			        
			If aCols[nCont][nProdu] == SC7->C7_PRODUTO
			 		
		 		acols[nCont][nCdPed] := SC7->C7_NUM
		   		acols[nCont][nItPed] := SC7->C7_ITEM
		   		acols[nCont][nPdLoc] := SC7->C7_LOCAL
				
				nVlrTotCTE 	:= nVlrTotCTE + acols[nCont][nVlTot] //valor total do CTE
				lAchou 		:= .T.
				
			EndIF
		
		Next nCont 
		
		If lAchou
			nVlrTotPED :=  nVlrTotPED + SC7->C7_TOTAL //valor total do pedido selecionado
		Else
			Exit
		EndIf	
		
	SC7->(DbSkip())	
	EndDo
	
	If !lAchou
	
		MsgAlert("Atenção!! Existe divergencia dos produtos CTE X Pedido Aprovado/selecionado. Processo Cancelado")	
		Return .F.
	
	EndIf
	
	If nVlrTotCTE <> nVlrTotPED                   
	
		MsgAlert("Atenção!! Valor do CTE divergente do Pedido Aprovado/selecionado '" +Alltrim(cCTEPed)+ "'. Verificar")
		Return .F. 
	
	Else
	
		oDlg2:END()//encerra a janela
	
	EndIf 
	
	
Else
	
	MsgAlert("Pedido nao Encontrado!") 
	
EndIf

Return 