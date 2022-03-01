#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MTA410I  º Autor ³ Rogerio Nutti      º Data ³  26/01/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Ponto de Entrada para gravar campo  C6_ENTREGA             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Ticket  TI  	- Leonardo P. Monteiro  - 02/02/2022 - Transferência do P.E. MTA410I para o fonte atual M410STTS. Transferimos a gravação da data de entrega nos itens do PV.
/*/
       
User Function MTA410I()
	/*
	Local nX       := ParamIXB
	Local aArea    := Getarea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local nProd    := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_PRODUTO" })
	Local nItemPV  := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_ITEM" })

	Conout( DToC(Date()) + " " + Time() + " MTA410I >>> INICIO PE" )

	IF ACOLS[nX,Len(aHeader)+1] == .F.
	
		DBSELECTAREA("SC6")
		DBSETORDER(1)
		IF DBSEEK(FWXFilial("SC6")+SC5->C5_NUM+ACOLS[nX,nItemPV]+ACOLS[nX,nProd])
		
			RecLock("SC6",.F.)
			
				SC6->C6_ENTREG := SC5->C5_DTENTR
				
			MsUnlock()
		
		ENDIF
	ENDIF
	
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)

	Conout( DToC(Date()) + " " + Time() + " MTA410I >>> FINAL PE" )
	*/
Return(NIL)
