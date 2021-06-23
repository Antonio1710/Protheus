#include "rwmake.ch"
 
/*/{Protheus.doc} User Function F200VAR
	executado apos carregar os dados do arquivo de recepcao bancaria e sera utilizado para alterar os dados recebidos.
	@type  Function
	@author FERNANDO SIGOLI
	@since 03/02/2017
	@version 01
/*/

// varivaies para uso
//cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, 
//nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer

USER FUNCTION F200VAR()

	LOCAL aArea	 := GetArea()
	
	IF cBanco = '104' .and. cOcorr = '21'
	 
		cOcorr := '06'+SPACE(1)
		
		// *** INICIO CHAMADO 040653 WILLIAM COSTA 01/05/2018 *** //
		
		IF nJuros > 0
		
			SqlBuscaTitIDCNAB(cNumTit)
			While TRC->(!EOF())
			
				IF nValRec == TRC->E1_SALDO
				
					nJuros := 0
			
				ENDIF
	    
		    	TRC->(dbSkip())
			ENDDO
			TRC->(dbCloseArea())
			
		ENDIF 
		
		// *** FINAL CHAMADO 040653 WILLIAM COSTA 01/05/2018 *** //
		
	ENDIF 
		
	RestArea(aArea)

RETURN(NIL)

Static Function SqlBuscaTitIDCNAB(cNumTit)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT TOP(1) E1_SALDO 
			  FROM %Table:SE1% WITH (NOLOCK)
			WHERE E1_IDCNAB   = %EXP:cNumTit%
			  AND D_E_L_E_T_  <> '*'
			
	EndSQl             
RETURN(NIL)