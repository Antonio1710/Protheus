#INCLUDE "PROTHEUS.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP640001  ³ Autor ³WILLIAM COSTA       º Data ³  19/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excblock utilizado para retornar a conta contabil debito   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ N. 051146 || OS 052499 || CONTROLADORIA || THIAGO || 8439  º±±
±±º          ³ || LP 640 - fwnm - 19/08/2019                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LP640001(cParam)

	Local cConta       := ''
	Local cCentroCusto := ''
	Local cRetorno     := ''
	Local aArea        := SD1->(GetArea()) 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF cParam == 'CONTA'

		IF SF4->F4_XCTB         == "S"       .AND. ;
		   SF4->F4_XTM           $ "E18/E08" .AND. ;
		   SD1->D1_TIPO         == "D"       .AND. ;
		   !(SA1->A1_EST        == "EX")     .AND. ;
		   ALLTRIM(SD1->D1_TES) == "218"
		
			cConta   := '311220004'
			
		// inicio chamado 034919		
		ELSEIF SF4->F4_XCTB         == "S"       .AND. ;
		       SF4->F4_XTM           $ "E18/E08" .AND. ;
		       SD1->D1_TIPO         == "D"       .AND. ;
		       !(SA1->A1_EST        == "EX")     .AND. ;
		       ALLTRIM(SD1->D1_TES) == "02D"
		
			cConta   := '311220004'					
			
		ELSEIF SF4->F4_XCTB         == "S"       .AND. ;
		       SF4->F4_XTM           $ "E18/E08" .AND. ;
		       SD1->D1_TIPO         == "D"       .AND. ;
		       !(SA1->A1_EST        == "EX")     .AND. ;
		       !ALLTRIM(SD1->D1_CF) == "2503"    
		
			cConta   := TABELA("Z@","R75",.F.)	  
		
		// inicio chamado 034809	
		ELSEIF SF4->F4_XCTB         == "S"   .AND. ;
		       SF4->F4_XTM           $ "E19" .AND. ;
		       SD1->D1_TIPO         == "D"   .AND. ;
		       !(SA1->A1_EST        == "EX") .AND. ;
		       ALLTRIM(SD1->D1_TES)  $ "148/03J" //WILLIAM COSTA - CHAMADO 041393 02/05/2018
		
			cConta   := '411120003'	  
			
		ELSE	
		
			cConta   := TABELA("Z@","R76",.F.)
			
		ENDIF	
		
		cRetorno := cConta
		
	ELSE
	
		IF SD1->D1_GRUPO$"0921/0922/0923/0924/0925/0926/0927"
		
			cCentroCusto:= "6180"  
			
		ELSEIF SD1->D1_GRUPO$"0542/0511/0541" .AND. ALLTRIM(SD1->D1_CF)$"1410/1210/1910" //adicionado cfop 1910 - fernando sigoli 18/12/2017 Chamado: 038715
		 
			cCentroCusto:= "6120"
			
		ELSEIF SD1->D1_GRUPO$"0542/0511/0541" .AND. ALLTRIM(SD1->D1_CF)$"2410/2201/2910" //adicionado cfop 2910 - fernando sigoli 18/12/2017 Chamado: 038715	
		
			cCentroCusto:= "6220" 
			
		ELSEIF SD1->D1_GRUPO$"0911/0912/0913" .AND. SUBSTR(ALLTRIM(SD1->D1_CF),1,1) == '1'	
		
			cCentroCusto:= "6130"
			
		ELSEIF SD1->D1_GRUPO$"0911/0912/0913" .AND. SUBSTR(ALLTRIM(SD1->D1_CF),1,1) == '2'	
		
			cCentroCusto:= "6230"
			
		ELSEIF SD1->D1_GRUPO$"9041" .AND. ALLTRIM(SD1->D1_TES) == '148' .AND. ALLTRIM(SD1->D1_FILIAL) == '02'	
		
			cCentroCusto:= "5201"		
			
		ELSEIF SD1->D1_GRUPO$"9041" .AND. ALLTRIM(SD1->D1_TES) == '148' .AND. ALLTRIM(SD1->D1_FILIAL) == '03'	
		
			cCentroCusto:= "5141"			
			
		ELSEIF SD1->D1_GRUPO$"9041" .AND. ALLTRIM(SD1->D1_TES) == '148' .AND. ALLTRIM(SD1->D1_FILIAL) == '04'	
		
			cCentroCusto:= "5121"				
			
		ELSEIF SUBSTR(ALLTRIM(SD1->D1_CF),1,1) == '2'
		
			cCentroCusto:= "6210"
		
		ElseIf AllTrim(SD1->D1_GRUPO) $ "0543" // Chamado n. 051146 || OS 052499 || CONTROLADORIA || THIAGO || 8439 || LP 640 - FWNM - 19/08/2019
		
			cCentroCusto:= "6190"  

		ELSE	  
		
			cCentroCusto:= "6110"
			
		ENDIF
		
		cRetorno     := cCentroCusto
	
    ENDIF
   
	RestArea(aArea) 
    
RETURN(cRetorno)                                           