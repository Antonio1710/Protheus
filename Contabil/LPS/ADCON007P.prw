#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADCON007P ºAutor  ³WILLIAM COSTA       º Data ³  16/03/2015 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     |Desenvolvimento de um fonte para na hora do lancamento      º±±
//±±º          ³padrao da baixa do titulo do contas a receber que tiver um  º±±
//±±º          ³titulo AB- mandar o valor do titulo para a contabilidade    º±±
//±±º          ³codigo do lancamento padrao 596-007                         º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGACTB - LANCAMENTO PADRAO                                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ADCON007P()

	Local nValor 	:= 0
	Local nValTit   := 0
	Local NValPag   := 0
	
	Private nMaxSeq  := 0
	Private cPrefixo := SUBSTR(SE5->E5_DOCUMEN,1,2)
    Private cNum     := SUBSTR(SE5->E5_DOCUMEN,4,9)
    Private cParcela := SUBSTR(SE5->E5_DOCUMEN,13,3)
    Private cFornec  := SE5->E5_FORNADT
    Private cLoja    := SE5->E5_LOJAADT
         
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	nMaxSeq := SqlMAXE5()  //Chamado 037304 - Sigoli 25/09/2017
		
	nValTit	:= SqlNCSE1()  //chamado 036377 - Sigoli 24/07/2017
	NValPag := SqlNCSE5()  //chamado 036377 - Sigoli 24/07/2017

	If NValPag >= nValTit
	
		//verifica se tem ab- no titulo
		SqlGeral()
		
		While TRB->(!EOF())   
		
			nValor := TRB->E1_VALOR
			      		    
	      	TRB->(dbSkip())
	    EndDo //FECHA WHILE DO TRB
	    	
		TRB->(dbCloseArea()) 
	
	EndIf
	    
Return(nValor)  

Static Function	SqlGeral() 
    
    BeginSQL Alias "TRB"
	
			%NoPARSER%
				SELECT E1_VALOR 
				FROM %Table:SE5% SE5  with (nolock) 
					INNER JOIN %Table:SE1% SE1 with (nolock) 
					ON SE5.E5_NUMERO    = SE1.E1_NUM
					AND SE5.E5_CLIFOR   = SE1.E1_CLIENTE
					AND SE5.E5_LOJA     = SE1.E1_LOJA
					AND SE5.E5_PARCELA  = SE1.E1_PARCELA
					AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO
					WHERE 
					SE1.E1_FILIAL       = %exp:xFilial("SE5")%
				   	AND SE1.E1_PREFIXO  = %exp:cPrefixo%
				   	AND SE1.E1_PARCELA  = %exp:cParcela%
				   	AND SE1.E1_NUM      = %exp:cNum%
					AND SE1.E1_CLIENTE  = %exp:cFornec%
					AND SE1.E1_LOJA     = %exp:cLoja%
					AND SE1.E1_TIPO 	= 'AB-'
					AND SE1.D_E_L_E_T_  = ''
					AND SE5.E5_MOTBX 	= 'CMP'
					AND SE5.D_E_L_E_T_  = ''
				   
    EndSQl          				   
					
	
Return(NIL)

//pega o valor da se1 do valor total do titulo
//chamado 036377 - Sigoli 24/07/2017
Static Function SqlNCSE1()
    
	Local nValSE1 := 0

	BeginSQL Alias "NCCE1"
		%NoPARSER%
			
			SELECT SUM(FONTES.CONTA) AS 'VALOR_TITULO' FROM 
			(SELECT  
				CASE 
					WHEN E1_TIPO = 'AB-' THEN E1_VALOR * -1 ELSE E1_VALOR END AS CONTA FROM %Table:SE1% WITH (NOLOCK) 
	 				WHERE E1_FILIAL = %exp:xFilial("SE5")%
					AND E1_PREFIXO  = %exp:cPrefixo%
					AND E1_NUM      = %exp:cNum%
					AND E1_PARCELA  = %exp:cParcela%
					AND E1_CLIENTE  = %exp:cFornec%
					AND E1_LOJA     = %exp:cLoja%
					AND D_E_L_E_T_ <> '*' ) AS FONTES
			   		
    EndSQl
    
    While NCCE1->(!EOF())   
	
		nValSE1 := NCCE1->VALOR_TITULO
  	
  	NCCE1->(dbSkip())
    EndDo //FECHA WHILE DO NCCE1
    	
	NCCE1->(dbCloseArea()) 
              				   
Return(nValSE1)
                                                                                                                

//pega o valor da se5 que foi baixado
//chamado 036377 - Sigoli 24/07/2017
Static Function SqlNCSE5()
    
	Local nValSE5 := 0

	BeginSQL Alias "NCCE5"
		%NoPARSER%

		SELECT SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR * -1 ELSE E5_VALOR END) AS 'VALOR_PAGO' FROM %Table:SE5% WITH (NOLOCK) //chamado 042693 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP 521-007 - WILLIAM COSTA 25/07/2018
			WHERE E5_FILIAL   = %exp:xFilial("SE5")%
			AND E5_PREFIXO    = %exp:cPrefixo%
			AND E5_NUMERO     = %exp:cNum%
			AND E5_PARCELA    = %exp:cParcela%
			AND E5_CLIFOR  	  = %exp:cFornec%
			AND E5_LOJA       = %exp:cLoja%
			AND E5_SEQ       <= %exp:nMaxSeq%
			AND D_E_L_E_T_   <> '*' 

    EndSQl          				   

   	While NCCE5->(!EOF())   
	
		nValSE5 := NCCE5->VALOR_PAGO
  	
  	NCCE5->(dbSkip())
    EndDo //FECHA WHILE DO NCCE5
    	
	NCCE5->(dbCloseArea()) 
              				   
Return(nValSE5)   



//pega o maior sequencial pago dos movimento do SE5
//Chamado: 037304 25/09/2017 - Fernando Sigoli
Static Function SqlMAXE5()
    
	Local nMaxSe5 := 0

	BeginSQL Alias "MAXSE5"
		%NoPARSER%

		SELECT MAX(E5_SEQ) AS 'MAX_SQSE5' FROM %Table:SE5% WITH (NOLOCK)
			WHERE E5_FILIAL   = %exp:xFilial("SE5")%
			AND E5_PREFIXO    = %exp:cPrefixo%
			AND E5_NUMERO     = %exp:cNum%
			AND E5_PARCELA    = %exp:cParcela%
			AND E5_CLIFOR  	  = %exp:cFornec%
			AND E5_LOJA       = %exp:cLoja%
			AND D_E_L_E_T_   <> '*' 

    EndSQl          				   

   	While MAXSE5->(!EOF())   
	
		nMaxSe5 := MAXSE5->MAX_SQSE5
  	
  	MAXSE5->(dbSkip())
    EndDo //FECHA WHILE DO MAXSE5
    	
	MAXSE5->(dbCloseArea()) 
              				   
Return(nMaxSe5)   

