#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADCON003P ºAutor  ³WILLIAM COSTA       º Data ³  16/03/2015 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     |Desenvolvimento de um fonte para na hora do lancamento      º±±
//±±º          ³padrao da baixa do titulo do contas a receber que tiver um  º±±
//±±º          ³titulo AB- mandar o valor do titulo para a contabilidade    º±±
//±±º          ³codigo do lancamento padrao 521-007 (Incl) e 527 109 Excl   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGACTB - LANCAMENTO PADRAO                                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ADCON003P()

	LOCAL nValor 	:= 0
	LOCAL nValTit   := 0
	LOCAL NValPag   := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	nValTit := SqlSE1() //chamado 036377 - Sigoli 24/07/2017
	NValPag := SqlSE5() //chamado 036377 - Sigoli 24/07/2017
	
	If NValPag >= nValTit
	
		//verifica se tem ab- no titulo
		SqlGeral()
	
		While TRB->(!EOF())   
	
			nValor := TRB->E1_VALOR
		      		    
      		TRB->(dbSkip())
    	ENDDO //FECHA WHILE DO TRB
    	
		TRB->(dbCloseArea()) 
	EndIf
	    
Return(nValor)  


STATIC FUNCTION SqlGeral() 
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			
				SELECT E1_VALOR 
				  FROM %Table:SE1%
				 WHERE E1_FILIAL   = %exp:xFilial("SE5")%
				   AND E1_PREFIXO  = %exp:SE5->E5_PREFIXO%
				   AND E1_NUM      = %exp:SE5->E5_NUMERO%
				   AND E1_PARCELA  = %exp:SE5->E5_PARCELA%
				   AND E1_CLIENTE  = %exp:SE5->E5_CLIFOR%
				   AND E1_LOJA     = %exp:SE5->E5_LOJA%
				   AND E1_TIPO     = 'AB-'
				   AND D_E_L_E_T_ <> '*'
    EndSQl          				   
RETURN(NIL)


//pega o valor da se1 do valor total do titulo
//chamado 036377 - Sigoli 24/07/2017
Static Function SqlSE1()
    
	LOCAL nValSE1 := 0

	BeginSQL Alias "TRE1"
		%NoPARSER%
			
			SELECT SUM(FONTES.CONTA) AS 'VALOR_TITULO' 
			  FROM (SELECT CASE WHEN E1_TIPO = 'AB-' THEN E1_VALOR * -1 ELSE E1_VALOR END AS CONTA 
			                FROM %Table:SE1% WITH (NOLOCK) 
	 		               WHERE E1_FILIAL   = %exp:xFilial("SE5")%
				             AND E1_PREFIXO  = %exp:SE5->E5_PREFIXO%
				             AND E1_NUM      = %exp:SE5->E5_NUMERO%
				             AND E1_PARCELA  = %exp:SE5->E5_PARCELA%
				             AND E1_CLIENTE  = %exp:SE5->E5_CLIFOR%
				             AND E1_LOJA     = %exp:SE5->E5_LOJA%
				             AND D_E_L_E_T_ <> '*' ) AS FONTES
			   		
    EndSQl
    
    While TRE1->(!EOF())   
	
		nValSE1 := TRE1->VALOR_TITULO
  	
  	TRE1->(dbSkip())
    EndDo //FECHA WHILE DO TRE1
    	
	TRE1->(dbCloseArea()) 
              				   
Return(nValSE1)
                                                                                                                

//pega o valor da se5 que foi baixado
//chamado 036377 - Sigoli 24/07/2017
Static Function SqlSE5()
    
	LOCAL nValSE5 := 0

	BeginSQL Alias "TRE5"
		%NoPARSER%

		SELECT SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR * -1 ELSE E5_VALOR END) AS 'VALOR_PAGO' 
		  FROM %Table:SE5% WITH (NOLOCK)
		 WHERE E5_FILIAL     = %exp:xFilial("SE5")%
		   AND E5_PREFIXO    = %exp:SE5->E5_PREFIXO%
		   AND E5_NUMERO     = %exp:SE5->E5_NUMERO%
		   AND E5_PARCELA    = %exp:SE5->E5_PARCELA%
		   AND E5_CLIFOR  	 = %exp:SE5->E5_CLIFOR%
		   AND E5_LOJA       = %exp:SE5->E5_LOJA%
		   AND E5_SEQ       <= %exp:SE5->E5_SEQ%
		   AND D_E_L_E_T_   <> '*' 

    EndSQl          				   

   	While TRE5->(!EOF())   
	
		nValSE5 := TRE5->VALOR_PAGO
  	
  	TRE5->(dbSkip())
    EndDo //FECHA WHILE DO TRE5
    	
	TRE5->(dbCloseArea()) 
              				   
Return(nValSE5)   

 
