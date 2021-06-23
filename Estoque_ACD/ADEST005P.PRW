#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEST005P ºAutor  ³William Costa       º Data ³  09/03/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Programa para criar as prioridades de endereco na tabela SBEº±±
±±º          ³e SBF                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ADEST005P()     

	Local nPriori := 10
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para criar as prioridades de endereco na tabela SBE e SBF')
		
	SqlSBE()    
	
	While TRA->(!EOF())
	    
	    SqlSBF(TRA->BE_FILIAL,TRA->BE_LOCAL,TRA->BE_LOCALIZ,TRA->BE_CODPRO)	
	    
	    While TRB->(!EOF()) 
	    
	    	DBSELECTAREA("SBE")
			DBSETORDER(1)
			IF DBSEEK(TRA->BE_FILIAL+TRA->BE_LOCAL+TRA->BE_LOCALIZ,.T.)
				
				Reclock("SBE",.F.)
					SBE->BE_PRIOR  := STRZERO(nPriori,8)
					
				MsUnlock()
			
			ENDIF // fecha if dbseek
			DBCLOSEAREA("SBE")
			
			
			DBSELECTAREA("SBF")
			DBSETORDER(1)
			IF DBSEEK(TRA->BE_FILIAL+TRA->BE_LOCAL+TRA->BE_LOCALIZ+TRA->BE_CODPRO,.T.)
				
				Reclock("SBF",.F.)
					SBF->BF_PRIOR  := STRZERO(nPriori,8)
					
				MsUnlock()
			
			ENDIF // fecha if dbseek
			DBCLOSEAREA("SBF")
	    
		    
			nPriori := nPriori + 10                    
	    	TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())
	       
	    TRA->(dbSkip())
	ENDDO
	TRA->(dbCloseArea())
    
RETURN()    

STATIC FUNCTION SqlSBE()        

	BeginSQL Alias "TRA"
			%NoPARSER%  
			SELECT BE_FILIAL,
			       BE_LOCAL,
				   BE_LOCALIZ,
				   BE_CODPRO,
				   BE_PRIOR  
			 FROM %Table:SBE%
			 WHERE D_E_L_E_T_ <> '*'
			
			  ORDER BY BE_LOCALIZ
			
	EndSQl             


RETURN()
              

STATIC FUNCTION SqlSBF(cFILIAL,cLOCAL,cLOCALIZ,cCODPRO)        

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT BF_FILIAL,
			       BF_LOCAL,
			       BF_LOCALIZ,
			       BF_PRODUTO
			  FROM %Table:SBF%
			WHERE BF_FILIAL  = %EXP:cFILIAL%
			  AND BF_LOCAL   = %EXP:cLOCAL%
			  AND BF_LOCALIZ = %EXP:cLOCALIZ%
			  AND BF_PRODUTO = %EXP:cCODPRO%
			  AND D_E_L_E_T_ <> '*'
			
	EndSQl             


RETURN()
