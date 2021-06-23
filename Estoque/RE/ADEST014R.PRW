#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"

USER FUNCTION ADEST014R()

	Local Arq           := "C:\temp\ReldifProducaoeEstoque.csv" //Nome do Arquivo a Gerar
	Local Path          :=  Arq  //Local de Geração do Arquivo
	Private cVar        := ''
	Private nHdl
	Private nH 
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Diferença entre Produção e Estoque"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEST014R' 
	Private cVerifica   := ''  
	Private aDirectory  := {}   
	Private nCont       := 0
	Private cTipoWin    := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Diferença entre Produção e Estoque')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo CSV " )
	AADD(aSays,"Relatorio de Produto que não conte na Estrutura de Produtos" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADEST014R(Path,nHdl,Arq)},"Gerando arquivo","Aguarde...")}})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  

RETURN(NIL)

STATIC FUNCTION LogADEST014R(Path,nHdl,Arq)	
	
	  
		nHdl := fCreate(Path) //Cria Arquivo para gravação das etiquetas
	    cVar := "Componente;Desc;Qtd Produção; Qtd Estoque; Diferença" + chr(13) + chr(10)
		
		SqlGeral()
	    While TRB->(!EOF())   
	    
	    	cVar += TRB->G1_COMP                                   + ';'
	    	cVar += TRB->B1_DESC                                   + ';'
	    	cVar += STRTRAN(CVALTOCHAR(TRB->QTD_ORD_PROD),'.',',') + ';'
	    	cVar += STRTRAN(CVALTOCHAR(TRB->TOTAL_KARDEX),'.',',') + ';'
	    	cVar += STRTRAN(CVALTOCHAR(TRB->DIFERENCA),'.',',')    + chr(13) + chr(10)
	    	
	      	TRB->(dbSkip())
	    ENDDO //FECHA WHILE DO TRE
	    	
		TRB->(dbCloseArea())
	
	    Set Century OFF
	    If fWrite(nHdl,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
	    	If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
	        	fClose(nHdl)
	            Return
	        Endif
	    Endif
		fClose(nHdl)  
		
		
		MsAguarde({||shellExecute("Open", Arq, "NULL", "C:\",3)},"Aguarde","Abrindo relatório...")
		
RETURN(NIL) 

Static Function MontaPerg()                                  

	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De          ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate         ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
    PutSx1(cPerg,'03','Local De           ?','','','mv_ch3','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Local Ate          ?','','','mv_ch4','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Ordem Producao De  ?','','','mv_ch5','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Ordem Producao Ate ?','','','mv_ch6','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Data Emissao De    ?','','','mv_ch7','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Data Emissao Ate   ?','','','mv_ch8','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR08')
	
	Pergunte(cPerg,.F.)
	
RETURN(NIL)           

STATIC FUNCTION SqlGeral()
     
    BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT PRODUCAO.G1_COMP, 
			       PRODUCAO.B1_DESC,
			       PRODUCAO.QTD_ORD_PROD,
				   ESTOQUE.TOTAL_KARDEX, 
				   CONVERT(DECIMAL(30,6),PRODUCAO.QTD_ORD_PROD - ESTOQUE.TOTAL_KARDEX) AS DIFERENCA
			  FROM (SELECT G1_COMP,
			               B1_DESC,  
			               SUM(G1_QUANT * C2_QTSEGUM) AS QTD_ORD_PROD
			          FROM %Table:SC2% WITH(NOLOCK)
			        INNER JOIN %Table:SG1%
			                ON G1_COD                  = C2_PRODUTO
			               AND %Table:SG1%.D_E_L_E_T_ <> '*'
   			        INNER JOIN %Table:SB1%
			                ON B1_COD                  = G1_COMP
			               AND %Table:SB1%.D_E_L_E_T_ <> '*'
			               AND B1_TIPO                <> 'PA'
			             WHERE C2_FILIAL              >= %EXP:MV_PAR01%
					       AND C2_FILIAL              <= %EXP:MV_PAR02%
			               AND C2_NUM                 >= %EXP:MV_PAR05%
			               AND C2_NUM                 <= %EXP:MV_PAR06%
			               AND C2_EMISSAO             >= %EXP:MV_PAR07%
			               AND C2_EMISSAO             <= %EXP:MV_PAR08%
			               AND %Table:SC2%.D_E_L_E_T_ <> '*'
			               AND C2_QUJE                 > 0
			               AND C2_QUANT                = C2_QUJE
			
			          GROUP BY G1_COMP,B1_DESC) AS PRODUCAO
					
					LEFT JOIN ( 
					            SELECT D3_COD,
						               SUM(CASE WHEN D3_CF  = 'DE4' THEN D3_QUANT ELSE 0 END) TOTAL_KARDEX
					              FROM %Table:SD3% WITH(NOLOCK)
 					             WHERE D3_FILIAL              >= %EXP:MV_PAR01%
					               AND D3_FILIAL              <= %EXP:MV_PAR02%
					               AND D3_EMISSAO             >= %EXP:MV_PAR07%
					               AND D3_EMISSAO             <= %EXP:MV_PAR08%
					               AND D3_LOCAL               >= %EXP:MV_PAR03%
					               AND D3_LOCAL               <= %EXP:MV_PAR04%
					               AND %Table:SD3%.D_E_L_E_T_ <> '*'
			
			                  GROUP BY D3_COD) AS ESTOQUE
			
					          ON PRODUCAO.G1_COMP = ESTOQUE.D3_COD
		 
	EndSQl          

RETURN(NIL)    	  