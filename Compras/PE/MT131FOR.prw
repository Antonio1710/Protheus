#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

USER FUNCTION MT131FOR()

	aFornecPEntrada := PARAMIXB[1]
	nCont           := 1
	
	FOR nCont:=1 TO LEN(aFornecPEntrada)
	
		IF nCont == 1
		
			IF aFornecPEntrada[nCont][4] == 'SA5'
			
				SqlUltFor(aFornecPEntrada[nCont][5]) 
				While TRC->(!EOF())
	                  
			            aFornecPEntrada[nCont][1] := TRC->D1_FORNECE
			            aFornecPEntrada[nCont][2] := TRC->D1_LOJA
		            	TRC->(dbSkip())
				ENDDO
				TRC->(dbCloseArea())
		
			ENDIF
		ENDIF
	
	NEXT 
		
RETURN(aFornecPEntrada)

Static Function SqlUltFor(nRecno)

	Local cRecno := cValToChar(nRecno)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT TOP(1) D1_TIPO,
			              D1_DTDIGIT,
						  D1_FORNECE,
						  D1_LOJA
					 FROM SA5010 WITH(NOLOCK), SD1010 WITH(NOLOCK)
					WHERE SA5010.R_E_C_N_O_  = %EXP:cRecno%
					  AND SA5010.D_E_L_E_T_ <> '*'
					  AND D1_FILIAL          = A5_FILIAL
					  AND D1_COD             = A5_PRODUTO
					  AND D1_TES            <> ''
					  AND D1_TIPO            = 'N'
					  AND SD1010.D_E_L_E_T_ <> '*'
					
					   ORDER BY SD1010.D1_DTDIGIT DESC
	EndSQl             
RETURN(NIL)