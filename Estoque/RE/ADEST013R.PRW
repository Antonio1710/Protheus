#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"

USER FUNCTION ADEST013R()

	Local Arq           := "C:\temp\RelProdEstrutura.csv" //Nome do Arquivo a Gerar
	Local Path          :=  Arq  //Local de Geração do Arquivo
	Private cVar        := ''
	Private nHdl
	Private nH 
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Produto que não conte na Estrutura de Produtos"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEST013R' 
	Private cVerifica   := ''  
	Private aDirectory  := {}   
	Private nCont       := 0
	Private cTipoWin    := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Produto que não conte na Estrutura de Produtos')
	
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
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADCON008R(Path,nHdl)},"Gerando arquivo","Aguarde...")}})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  

RETURN(NIL)

STATIC FUNCTION LogADCON008R(Path,nHdl)	
	
	  
		nHdl := fCreate(Path) //Cria Arquivo para gravação das etiquetas
	    cVar := "Cod Prod;Qtd Atual; Descricao" + chr(13) + chr(10)
		
		SqlEstrutura()
	    While TRB->(!EOF())
	    
	    	cVar += TRB->B2_COD              + ';'
	    	cVar += cvaltochar(TRB->B2_QATU) + ';'
	        cVar += TRB->B1_DESC             + chr(13) + chr(10)
	    	
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
		
		
		MsAguarde({||shellExecute("Open", "C:\temp\RelProdEstrutura.csv", "NULL", "C:\",3)},"Aguarde","Abrindo relatório...")
		/*
		aDirectory := DIRECTORY("C:\Program Files\Microsoft Office\Office14\EXCEL.EXE")
		
		FOR nCont := 1 TO LEN(aDirectory)   
		
			cTipoWin := '64'
		
		
		NEXT(nCont)  
		
		IF cTipoWin == '64'
		
			shellExecute( "Open", "C:\Program Files\Microsoft Office\Office14\EXCEL.exe", Path, "C:\", 1 )	
			
		ELSE
		
			shellExecute( "Open", "%PROGRAMFILES%\Microsoft Office\Office14\EXCEL.exe", Path, "C:\", 1 )
		
		ENDIF
	    */
		
RETURN(NIL) 

Static Function MontaPerg()                                  

	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De  ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
    PutSx1(cPerg,'03','Local De   ?','','','mv_ch3','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Local Ate  ?','','','mv_ch4','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	
	
	Pergunte(cPerg,.F.)
	
RETURN(NIL)           

STATIC FUNCTION SqlEstrutura()
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT B2_COD, 
			       B2_QATU,
			       B1_DESC  
			  FROM SB1010, SB2010
		     WHERE B1_MSBLQL          = '2'
			   AND B2_FILIAL         >= %EXP:MV_PAR01%
			   AND B2_FILIAL         <= %EXP:MV_PAR02%
			   AND B2_COD             = B1_COD
			   AND B2_LOCAL          >= %EXP:MV_PAR03%
			   AND B2_LOCAL          <= %EXP:MV_PAR04%
			   AND B2_QATU           <> 0
			   AND SB1010.D_E_L_E_T_ <> '*'
			   AND SB2010.D_E_L_E_T_ <> '*'
			   AND B2_COD NOT IN(SELECT G1_COMP FROM SG1010 WHERE D_E_L_E_T_ <> '*')
			   
			   GROUP BY B2_COD,B2_QATU,B1_DESC
			
			   ORDER BY B2_COD
							      	
	EndSQl          

RETURN(NIL)    	  