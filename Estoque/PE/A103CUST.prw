#INCLUDE 'RWMAKE.CH'

User Function A103CUST()

	Local aRet := PARAMIXB[1]
	
	// Conteudo do aRet
	// aRet[1,1] -> Custo de entrada na Moeda 1
	// aRet[1,2] -> Custo de entrada na Moeda 2
	// aRet[1,3] -> Custo de entrada na Moeda 3
	// aRet[1,4] -> Custo de entrada na Moeda 4
	// aRet[1,5] -> Custo de entrada na Moeda 5
	
	// Customizacoes do Cliente   
	IF CEMPANT              == '01'               .AND. ;
	   ALLTRIM (SD1->D1_CF)  $ GETMV("MV_#CFRORD")
	 
		//busca nota compra ordem
        SQLVerNotaCompraOrdem(SD1->D1_FILNFOR,SD1->D1_NFORDEM,SD1->D1_SERIORD,SD1->D1_ITEMORD,SD1->D1_FORORDE,SD1->D1_LOJAORD)  
         	   
        //nota encontrada
	    While TRB->(!EOF())
       	                                    
       		aRet[1,1] := TRB->D1_CUSTO
            TRB->(dbSkip())
            
		ENDDO
		TRB->(dbCloseArea())
	ENDIF
	
Return(aRet)        

Static Function SQLVerNotaCompraOrdem(cFil,cDocOrdem,cSerieOrdem,cItemOrdem,cFornece,cLoja)  
     
    BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT D1_DOC,
			       D1_CF,
				   D1_TES,
				   D1_LOJA,
				   D1_CUSTO 
			  FROM SD1010
			  WHERE D1_FILIAL               = %EXP:cFil%
			    AND D1_DOC                  = %EXP:cDocOrdem%
			    AND D1_SERIE                = %EXP:cSerieOrdem%
			    AND D1_FORNECE              = %EXP:cFornece%
				AND D1_LOJA                 = %EXP:cLoja%   
				AND D1_ITEM                 = %EXP:cItemOrdem%
			    AND %Table:SD1%.D_E_L_E_T_ <> '*'
			    
	EndSQl             
RETURN(NIL)