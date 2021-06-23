
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA040TOK  ºAutor  ³Alexandre Circenis  º Data ³  11/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a troca do Usuario da Cateira e faz o ajuste na PB3  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION MA040TOK()

TrocaUser()

return .T.

Static Function TrocaUser()
Local cUserOld
Local cUserNew
Local cCodVen
Local cQuery 
Local aArea := GetArea()

if !SA3->(Eof()) .and. !Empty(SA3->A3_CODUSR) .and. SA3->A3_CODUSR <> M->A3_CODUSR 
   
	// Trocou o Usuario da Carteira
	cUserOld := SA3->A3_CODUSR
	cUserNew := M->A3_CODUSR
    cCodVen  := M->A3_COD
    
	cQuery := "SELECT R_E_C_N_O_ REC"
	cQuery += " FROM "+RetSqlName("PB3")+" PB3"
	cQuery += " WHERE PB3_FILIAL ='"+xFilial("PB3")+"'"

	cQuery += " AND (PB3_CODVEN = '"+cCodVen+"'"
	cQuery += " OR PB3_VENENC ='"+cUserOld+"' )"

	cQuery += " AND PB3.D_E_L_E_T_ = ' '"

	DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "TRB", .F., .T. )
	dbSelectArea( "TRB" )

	while !TRB->(Eof())

		dbSelectArea("PB3")
		dbGoto(TRB->REC)
		RecLock("PB3",.F.)
		
		if PB3->PB3_CODVEN = cCodVen
			PB3->PB3_VEND := cUserNew
		endif	                      

		if PB3->PB3_VENENC = cUserOld
			PB3->PB3_VENENC := cUserNew
		endif	                      
		
		msUnlock()
		TRB->(dbSkip())
	
	enddo

	TRB->(dbCloseArea())
	RestArea(aArea)

endif
		
Return

User Function GCodVenP()

dbSelectArea("PB3")
dbSetOrder(10) 
dbGotop()

while !Eof()

	RecLock("PB3",.F.)
	if Empty(PB3->PB3_VEND)
		if !Empty(PB3->PB3_CODSA1)
			PB3->PB3_CODVEN := Posicione("SA1",1,xFilial("SA1")+PB3->PB3_CODSA1,"A1_VEND")
		else
			PB3->PB3_CODVEN := ' '	
		endif	
	else
		PB3->PB3_CODVEN := Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD")
	endif	
	msUnlock()
	dbSkip()
	
enddo

Return