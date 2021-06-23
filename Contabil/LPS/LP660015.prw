// Rotina para tratar o retorno da ISS no LP 660-015.
//*******************************************************************
User Function LP660015()
//*******************************************************************

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define Variaveis                                                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Local _nSE2ISS :=0
Local _aArea := GetArea()
Local _aAreaSE2 := SE2->(GetArea())
Local _aAreaSF1 := SF1->(GetArea())
Local _cEspecie := IF(EMPTY(SF1->F1_ESPECIE),"NF",SF1->F1_ESPECIE)  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Posiciona Todos os Indices Necessarios                       ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

If SF4->F4_XCTB == "S" .AND. SF4->F4_XTM $ "E01/E04" .AND. SD1->D1_TIPO <> "D"

	// ***************** INICIO ALTERACAO CHAMADO 024322 ********************************************** //
    SqlTitPag(Xfilial("SE2"),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_SERIE,SF1->F1_DOC)
    	
	While TRB->(!EOF())
    				
    	_nSE2ISS:= TRB->E2_ISS
		       	
        TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea()) 
	
Endif

RestArea(_aAreaSE2)
RestArea(_aAreaSF1)
RestArea(_aArea)

Return(_nSE2ISS) 

Static Function SqlTitPag(cFil,cFornece,cLoja,cPrefixo,cDoc)                        

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT TOP(1) SE2.E2_ISS
					 FROM %Table:SE2% SE2 WITH(NOLOCK) 
				   WHERE SE2.E2_FILIAL      = %EXP:cFil%
					 AND SE2.E2_FORNECE     = %EXP:cFornece%
					 AND SE2.E2_LOJA        = %EXP:cLoja%
					 AND SE2.E2_PREFIXO     = %EXP:cPrefixo%
					 AND SE2.E2_NUM         = %EXP:cDoc%
					    
					  ORDER BY SE2.R_E_C_N_O_ DESC
    EndSQl             
RETURN(NIL) 