#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT461VCT  ºAutor  ³WILLIAM COSTA       º Data ³  17/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³O ponto de entrada MT461VCT permite alterar o valor e o     º±±
±±º          ³vencimento título gerado no momento geração da nota fiscal  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT461VCT()
       
	Local nCont     := 0
	Local aVenctos  := ParamIxb[1]
	Local aTitulos  := ParamIxb[2]
	Local aArea     := GetArea()
	
	// *** INICIO CHAMADO 044433 || OS 045622 || FINANCAS || ALBERTO || 8480 || COND. PAGAMENTO ATENDIMENTO: WILLIAM COSTA 17/10/2018 ***//
	
	IF  (SF2->F2_COND == '999')
	
		// *** Atualiza as Parcelas para depois verificar se houve diferenca *** //
		dData := CTOD("  /  /    ")
		FOR nCont := 1 TO LEN(aVenctos)
		
			// *** INICIO SE O VENCIMENTO DA PRIMEIRA PARCELA FOR O DIA 01 NAO PRECISA FAZER NADA PORQUE TA CERTO *** // 
			IF nCont                                == 1   .AND. ;
			   SUBSTR(DTOC(aVenctos[nCont][1]),1,2) == '01'  
			
				EXIT
			
			ENDIF
			// *** FINAL SE O VENCIMENTO DA PRIMEIRA PARCELA FOR O DIA 01 NAO PRECISA FAZER NADA PORQUE TA CERTO *** //
			
			// *** INICIO CONTINUA O PROGRAMA ALTERACAO DE DATAS *** //
			
			IF nCont == 1
				
				aVenctos[nCont][1] := FirstDay(MonthSum(DDATABASE, 1)) 
			    
		    ENDIF
		    
		    IF nCont == 2
		    
		        aVenctos[nCont][1] := CTOD("15"+SUBSTRING(DTOC(MonthSum(DDATABASE, 1)),3,8))
			
		    ENDIF
		    
		    // *** FINAL CONTINUA O PROGRAMA ALTERACAO DE DATAS *** // 
		    
		NEXT nCont
				
	ENDIF
	
	// *** FINAL CHAMADO 044433 || OS 045622 || FINANCAS || ALBERTO || 8480 || COND. PAGAMENTO ATENDIMENTO: WILLIAM COSTA 17/10/2018 ***//
	
	RestArea( aArea )
         
Return(aVenctos)