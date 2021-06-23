#include 'rwmake.ch'
#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PegaTES   ºAutor  ³MICROSIGA           º Data ³  11/05/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da TES                                  s        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracao ³ WILLIAM COSTA 03/09/2019 - CHAMADO 051449 - Melhoria na    º±±
±±º          ³ na mensagem de validação da TES para saber qual o produto  º±±
±±º          ³ está sendo reclamado                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PegaTES()

	Local _LTes		:=.T.  
	Local _aArea    :=GetArea() 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	_TPTES    := aScan( aHeader, {|x| x[2] = "D1_TES" 		} )                             
	_TPPROD   := aScan( aHeader, {|x| x[2] = "D1_COD" 		} )                             
	_TRATEIO  := aScan( aHeader, {|x| x[2] = "D1_RATEIO" 	} )                             
	_TPCONTA  := aScan( aHeader, {|x| x[2] = "D1_CONTA" 	} )                                                                                                                       								
	_TPITCTA  := aScan( aHeader, {|x| x[2] = "D1_ITEMCTA" 	} )                                                                                                                                                           
	
	If !Empty(Alltrim(M->D1_TES)) .Or. !Empty(aCols[n][_TPTES])
	
		
		DbSelectAreA('SB1')
		DbSetOrder(1)
		DbSeek( XFilial() + aCols[n][_TPPROD] )
		      
		DbSelectAreA('SF4')
		DbSetOrder(1)
		DbSeek( XFilial() + M->D1_TES )
	    
	  	If _TPCONTA > 0  //valida se o campo existe  - fernando sigoli 15/02/2017
		
			If SF4->F4_ESTOQUE = 'S'
			
				aCols[n][_TPConta] := SB1->B1_CONTA		
			
			ElseIf SF4->F4_ESTOQUE = 'N'
			
				aCols[n][_TPConta] := SB1->B1_CONTAR
			
			EndIf
	    
	    EndIf
	    
		//---
	    
	  	If _TPConta > 0 //valida se o campo existe  - fernando sigoli 15/02/2017
	
			If SF4->F4_ESTOQUE = 'S' .And.  aCols[n][_TPConta] = SB1->B1_CONTA  .And. !Empty(Alltrim(aCols[n][_TPConta])) 
			
					//--- Do Nothing
			Elseif SF4->F4_ESTOQUE = 'N' .And.  aCols[n][_TPConta] = SB1->B1_CONTAR  .And. !Empty(Alltrim(aCols[n][_TPConta])) 
			
					//--- Do Nothing	
			
			Else
			
			    DbSelectAreA('SF4')
			    DbSetOrder(1)
			    DbSeek( XFilial() + aCols[n][_TPTES])
			    
			    If SF4->F4_ESTOQUE = 'S'
			    
			    	aCols[n][_TPConta] := SB1->B1_CONTA
			    
			    ElseIf SF4->F4_ESTOQUE = 'N'
				
				    aCols[n][_TPConta] := SB1->B1_CONTAR
			    
			    Endif
			
			Endif	
	    
	    EndIf
	    
	    If FUNNAME() $   "MATA910" .Or. Alltrim(Funname())="MATA910" .Or. Alltrim( Substr ( Funname() ,1 , 7 ) )="MATA910"
	    	  //-- Do Nothing
	    Else
	                                                                                 
			If Substr(FunName(),1,7)<>"MATA140"	 .and. Alltrim(Funname()) <> "CENTNFEXM" //fernando sigoli 15/02/2017               
				
				If Empty(aCols[n][_TRATEIO])  .Or. aCols[n][_TRATEIO]="" .Or. aCols[n][_TRATEIO]=Space(1)
					aCols[n][_TRATEIO]:="2"   	   
				Endif
			
			Endif
	        
			IF _TPITCTA > 0 //valida se o campo existe  - fernando sigoli 15/02/2017
			
			    IF !Empty(aCols[n][_TPITCTA])       
			
		 			xItemFil  := GetMV("MV_ITEMFIL")   
			                                       
			   		If Alltrim(Funname()) <> "CENTNFEXM"  //fernando sigoli 15/02/2017  
			   
			   	 		IF !Empty(Alltrim(xItemFil)) .And.  aCols[n][_TRATEIO]=="2" .AND. !('LEXML' $ ALLTRIM(FUNNAME())) 
			   
				   			If .Not. Alltrim(aCols[n][_TPITCTA]) $ xItemFil
				   			  	
				   			  	//*** INICIO WILLIAM COSTA 03/09/2019 - CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO   		   
				   				HELP( " ",1,"Erro FILIAL X ITEM CONTABIL: " + Alltrim(aCols[n][_TPITCTA]) + " || Codigo Produto: " + Alltrim(aCols[n][_TPPROD]) ) 
				   				//*** FINAL WILLIAM COSTA 03/09/2019 - CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
				   				
				   			Endif
						Endif
					
					Else  //fernando sigoli 15/02/2017  
						
						IF !Empty(Alltrim(xItemFil)) .And. !('LEXML' $ ALLTRIM(FUNNAME())) 
			   
				   			If .Not. Alltrim(aCols[n][_TPITCTA]) $ xItemFil
				   			
				   			  	//*** INICIO WILLIAM COSTA 03/09/2019 - CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO	   		   
				   				HELP( " ",1,"Erro FILIAL X ITEM CONTABIL: " + Alltrim(xItemFil) + " || Codigo Produto: " + Alltrim(aCols[n][_TPPROD]) )
				   				//*** FINAL WILLIAM COSTA 03/09/2019 - CHAMADO 051417 || OS 052739 || FISCAL || SIMONE || 8463 || NF IMPORTACAO
				   				
				   			Endif
						Endif
					EndIf
				Endif	
			EndIf
		EndIF
	   RestArea(_aArea)
	Endif

Return(_LTes)