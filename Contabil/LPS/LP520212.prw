#INCLUDE "PROTHEUS.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP520212  ³ Autor ³WILLIAM COSTA       º Data ³  19/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excblock utilizado para retornar o Valor Contabil debito   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LP520212()

	Local nValor := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	SqlBuscaTit(SE1->E1_FILIAL,  ;
	            SE1->E1_PREFIXO, ;
	            SE1->E1_NUM,     ;
	            SE1->E1_PARCELA, ;
	            SE1->E1_TIPO,    ;
	            SE1->E1_CLIENTE, ;
	            SE1->E1_LOJA)
    
    While TRB->(!EOF())
                  
    	nValor:= TRB->E5_VALOR
            
        TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea()) 

RETURN(nValor) 

Static Function SqlBuscaTit(cFil,cPref,cNum,cPar,cTipo,cCliente,cLoja)

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT CASE WHEN SUM(E5_VALOR) > 0 THEN 0 ELSE SUM(E5_VALOR) * (-1) END AS E5_VALOR //chamado william 035231
			  FROM %Table:SE5% 
			 WHERE E5_FILIAL   = %EXP:cFil%
			   AND E5_PREFIXO  = %EXP:cPref%
			   AND E5_NUMERO   = %EXP:cNum%
			   AND E5_PARCELA  = %EXP:cPar%
			   AND E5_TIPO     = %EXP:cTipo%
			   AND E5_CLIFOR   = %EXP:cCliente%
			   AND E5_LOJA     = %EXP:cLoja%
			   AND E5_TIPODOC  = 'VM'
               AND E5_MOTBX    = 'VM' //fernando sigoli 07/02/2018 Chamado: 039696
			   //AND E5_MOTBX  = ''
			   AND D_E_L_E_T_ <> '*'
	EndSQl             
RETURN(NIL)                                          