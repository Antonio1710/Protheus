#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN057R ºAutor  ³William COSTA       º Data ³  06/06/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Titulos baixados com tarifas                  º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADFIN057R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Titulos baixados com tarifas')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Tarifas"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADFIN057R'
	Private cColunas    := ''
	Private oExcel      := FWMSEXCEL():New()
	Private cArquivo    := 'REL_TARIFAS.XML'
	Private oMsExcel
	Private cPlanilha   := "Tarifas"
    Private cTitulo     := "Tarifas"
    Private aLinha      := {}
	Private aLinhas     := {}
	Private aBanco      := {}
	Private aBancos     := {}
	Private nExcel      := 0 
	Private nLinha      := 0
	Private cNomeRegiao := ''
	Private nTotReg	     := 0
	Private cTarifa     := ''
	Private nCont       := 0  
	Private nCont2      := 0
	Private nColunas    := 0
	Private nTotLinha   := 0
	Private nTotColuna  := 0
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Tarifas" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdFIN057R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         
Static Function LogAdFIN057R()
    
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
        
        IF MV_PAR07 = 1 //Analitico
		
        	Cabec()             
        	GeraExcel()
        	
        ELSE // Sintetico	
        
        	CabecSint()             
        	GeraLinhas()
		
	    ENDIF      
	    
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local cNomeRegiao := ''
	Local nTotReg	  := 0
	Local cTarifa     := ''
	
	SqlGeral()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
			cTarifa := Alltrim(cValToChar(TRB->ZC2_TARIFA ))
	        IncProc("Processando Tarifa. " + cTarifa)  
		
        	nLinha  := nLinha + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinhas,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C  
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               "", ; // 06 F   
		   	               "", ; // 07 G  
		   	               "", ; // 08 H  
		   	               "", ; // 09 I   
		   	               "", ; // 10 J  
		   	               "", ; // 11 K  
		   	               "", ; // 12 L  
		   	               "", ; // 13 M   
		   	               ""  ; // 14 N  
		   	                  })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->E5_FILIAL                                          //A
			aLinhas[nLinha][02] := TRB->E5_XTARIFA                                         //B
			aLinhas[nLinha][03] := TRB->ZC2_TARIFA                                         //C
			aLinhas[nLinha][04] := TRB->ZC2_BANCO                                          //D
			aLinhas[nLinha][05] := TRB->ZC2_AGENCI                                         //E
			aLinhas[nLinha][06] := TRB->ZC2_CONTA                                          //F
			aLinhas[nLinha][07] := IIF(ALLTRIM(TRB->E5_DATA) <> '',STOD(TRB->E5_DATA), '') //G
			aLinhas[nLinha][08] := TRB->E5_NATUREZ                                         //H
			aLinhas[nLinha][09] := TRB->E5_VALOR                                           //I
			aLinhas[nLinha][10] := TRB->E5_XQTDTAR                                         //J
			aLinhas[nLinha][11] := TRB->VLR_UNIT                                           //K
			aLinhas[nLinha][12] := TRB->ZC2_VALOR                                          //L
			aLinhas[nLinha][13] := TRB->DIF                                                //M
			aLinhas[nLinha][14] := TRB->DIFT                                               //N
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
		                                 aLinhas[nExcel][02],; // 02 B  
		                                 aLinhas[nExcel][03],; // 03 C  
		                                 aLinhas[nExcel][04],; // 04 D  
		                                 aLinhas[nExcel][05],; // 05 E  
		                                 aLinhas[nExcel][06],; // 06 F  
		                                 aLinhas[nExcel][07],; // 07 G  
		                                 aLinhas[nExcel][08],; // 08 H  
		                                 aLinhas[nExcel][09],; // 09 I  
		                                 aLinhas[nExcel][10],; // 10 J  
		                                 aLinhas[nExcel][11],; // 11 K  
		                                 aLinhas[nExcel][12],; // 12 L  
		                                 aLinhas[nExcel][13],; // 13 M  
		                                 aLinhas[nExcel][14] ; // 14 N  
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function GeraLinhas()

	Local nBanco      := 0
	Local nTotGeral   := 0

	nTotGeral := 0

    SqlTarifas()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRD","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRD")
		TRD->(DBGOTOP())
		WHILE TRD->(!EOF())
		
			cTarifa := Alltrim(cValToChar(TRD->ZC2_TARIFA ))
	        IncProc("Processando Títulos. " + cTarifa)  
		
        	nLinha  := nLinha + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA
            aLinha := {}
            
            AADD(aLinha,"")
             
            FOR nCont := 1 TO LEN(aBancos)
            
            	AADD(aLinha,"")
               	
		   	NEXT
		   	
		   	AADD(aLinha,"")
		   	AADD(aLinhas,aLinha)
		   	
		   	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRD->ZC2_TARIFA                                          //A
			
			SqlVlBancos(TRD->ZC2_TARIFA)
			
			WHILE TRE->(!EOF())
			
				nTotLinha := 0
	
				FOR nCont2 := 1 TO LEN(aBancos)
            
					nBanco                    := aScan(aBancos,{|x| x[1] == TRE->ZC2_BANCO}) 
	            	aLinhas[nLinha][nCont2+1] := IIF(aBancos[nBanco][2] == nCont2,TRE->ZC2_VALOR,IIF(EMPTY(aLinhas[nLinha][nCont2+1]),0,aLinhas[nLinha][nCont2+1]))                                        
	            	nTotLinha                 := nTotLinha + IIF(aBancos[nBanco][2] == nCont2,TRE->ZC2_VALOR,IIF(EMPTY(aLinhas[nLinha][nCont2+1]),0,aLinhas[nLinha][nCont2+1]))                                         
	               	 
			   	NEXT
					
				TRE->(dbSkip())    
				
			ENDDO //end do while TRB
			TRE->( DBCLOSEAREA() )   
			
			aLinhas[nLinha][nCont2+1] := nTotLinha
			nTotGeral   := nTotGeral + nTotLinha
						                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRD->(dbSkip())    
		
		ENDDO //end do while TRB
	TRD->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
            		
            cColunas := 'aLinhas[nExcel][01],'
            nColunas := 0
            		
			FOR nColunas := 1 TO LEN(aBancos) 
			
				cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nColunas+1,2) + '],'
				
			NEXT
			
			cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nColunas+1,2) + ']'
		   	&("oExcel:AddRow(cPlanilha,cTitulo,{" + cColunas + "})")
		   	
			/*                                                    
		    oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
		   	                                 aLinhas[nExcel][02],; // 02 B  
			                                 aLinhas[nExcel][03],; // 03 C
			                                 aLinhas[nExcel][04],; // 03 C 
			                                 aLinhas[nExcel][05],; // 03 C 
			                                 aLinhas[nExcel][06],; // 03 C 
			                                 aLinhas[nExcel][07] ; // 03 C 
			                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
		   */                                               
	    NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
	 	
	 	// *** Inicio Total Geral *** //
	 	
	 	aLinha := {}
            
        AADD(aLinha,"")
         
        FOR nCont := 1 TO LEN(aBancos)
        
        	AADD(aLinha,"")
           	
	   	NEXT
	   	
	   	AADD(aLinha,"")
	   	AADD(aLinhas,aLinha)
	   	
	   	nLinha   := nLinha + 1
	   	aLinhas[nLinha][01] := 'Total Geral'
	   	
	   	FOR nCont2 := 1 TO LEN(aBancos)
	   	
	   		SqlTotBancos(aBancos[nCont2][1])
	   	
	   		WHILE TRF->(!EOF())
			
	   			aLinhas[nLinha][nCont2+1] := TRF->ZC2_VALOR                                        
	                                                     
	            TRF->(dbSkip())    
				
			ENDDO //end do while TRB
			TRF->( DBCLOSEAREA() ) 
            
		NEXT
	   	
	   	aLinhas[nLinha][nCont2+1] := nTotGeral
	   	
	   	cColunas := 'aLinhas[nLinha][01],'
	   	nColunas := 0		
		FOR nColunas := 1 TO LEN(aBancos) 
		
			cColunas := cColunas + 'aLinhas[nLinha][' + STRZERO(nColunas+1,2) + '],'
			
		NEXT
		
		cColunas := cColunas + 'aLinhas[nLinha][' + STRZERO(nColunas+1,2) + ']'
	   	&("oExcel:AddRow(cPlanilha,cTitulo,{" + cColunas + "})")
		   	
	   // *** Final Total Geral *** //
	 	
Return()

Static Function SqlGeral()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT E5_FILIAL,    
				   E5_XTARIFA,    
				   ZC2_TARIFA,    
				   ZC2_BANCO,    
				   ZC2_AGENCI,    
				   ZC2_CONTA,    
				   E5_DATA,    
				   E5_NATUREZ,    
				   E5_VALOR,    
				   E5_XQTDTAR,  
				   E5_VALOR/E5_XQTDTAR AS VLR_UNIT,    
				   ZC2_VALOR,    
				   ZC2_VALOR-(E5_VALOR/E5_XQTDTAR) AS DIF, 
				   ((ZC2_VALOR-(E5_VALOR/E5_XQTDTAR))*E5_XQTDTAR) AS DIFT 
			  FROM %Table:SE5% AS SE5 WITH (NOLOCK)   
			  LEFT OUTER JOIN %Table:ZC2% AS ZC2 WITH (NOLOCK)    
			               ON E5_FILIAL       = ZC2_FILIAL    
						  AND E5_XTARIFA      = ZC2_CODIGO   
						  AND ZC2.D_E_L_E_T_ <> '*'  
			            WHERE E5_FILIAL      >= %EXP:MV_PAR01% 
			              AND E5_FILIAL      <= %EXP:MV_PAR02% 
			              AND E5_DATA        >= %EXP:MV_PAR03% 
				          AND E5_DATA        <= %EXP:MV_PAR04%
				          AND E5_XTARIFA     <> '' 
						  AND E5_XTARIFA     >= %EXP:MV_PAR05% 
						  AND E5_XTARIFA     <= %EXP:MV_PAR06% 
			              AND SE5.D_E_L_E_T_ <> '*'  
			
			 ORDER BY E5_FILIAL, ZC2_BANCO,ZC2_AGENCI,ZC2_CONTA,E5_DATA			
	EndSQl
RETURN()    


Static Function SqlCab()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT ZC2_BANCO
			  FROM %Table:SE5% AS SE5 WITH (NOLOCK)   
			  LEFT OUTER JOIN %Table:ZC2% AS ZC2 WITH (NOLOCK)    
			               ON E5_FILIAL       = ZC2_FILIAL    
						  AND E5_XTARIFA      = ZC2_CODIGO   
						  AND ZC2.D_E_L_E_T_ <> '*'  
			            WHERE E5_FILIAL      >= %EXP:MV_PAR01% 
			              AND E5_FILIAL      <= %EXP:MV_PAR02% 
			              AND E5_DATA        >= %EXP:MV_PAR03% 
				          AND E5_DATA        <= %EXP:MV_PAR04%
				          AND E5_XTARIFA     <> '' 
						  AND E5_XTARIFA     >= %EXP:MV_PAR05% 
						  AND E5_XTARIFA     <= %EXP:MV_PAR06% 
			              AND SE5.D_E_L_E_T_ <> '*'  
			
			 GROUP BY ZC2_BANCO
			
			 ORDER BY ZC2_BANCO		
	EndSQl
RETURN()

Static Function SqlTarifas()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRD"
			%NoPARSER%
			SELECT  ZC2_TARIFA
			  FROM %Table:SE5% AS SE5 WITH (NOLOCK)   
			  LEFT OUTER JOIN %Table:ZC2% AS ZC2 WITH (NOLOCK)    
			               ON E5_FILIAL       = ZC2_FILIAL    
						  AND E5_XTARIFA      = ZC2_CODIGO   
						  AND ZC2.D_E_L_E_T_ <> '*'  
			            WHERE E5_FILIAL      >= %EXP:MV_PAR01% 
			              AND E5_FILIAL      <= %EXP:MV_PAR02% 
			              AND E5_DATA        >= %EXP:MV_PAR03% 
				          AND E5_DATA        <= %EXP:MV_PAR04%
				          AND E5_XTARIFA     <> '' 
						  AND E5_XTARIFA     >= %EXP:MV_PAR05% 
						  AND E5_XTARIFA     <= %EXP:MV_PAR06% 
			              AND SE5.D_E_L_E_T_ <> '*'  
			
			 GROUP BY ZC2_TARIFA 

		 	ORDER BY ZC2_TARIFA		
	EndSQl
RETURN()

Static Function SqlVlBancos(cTarifa)

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRE"
			%NoPARSER%
			SELECT  ZC2_TARIFA,  
					ZC2_BANCO, 
					SUM(ZC2_VALOR) AS ZC2_VALOR
			  FROM %Table:SE5% AS SE5 WITH (NOLOCK)   
			       INNER JOIN %Table:ZC2% AS ZC2 WITH (NOLOCK)    
			               ON E5_FILIAL       = ZC2_FILIAL    
						  AND E5_XTARIFA      = ZC2_CODIGO   
						  AND ZC2_TARIFA      = %EXP:cTarifa% 
						  AND ZC2.D_E_L_E_T_ <> '*'  
			            WHERE E5_FILIAL      >= %EXP:MV_PAR01% 
			              AND E5_FILIAL      <= %EXP:MV_PAR02% 
			              AND E5_DATA        >= %EXP:MV_PAR03% 
				          AND E5_DATA        <= %EXP:MV_PAR04%
				          AND E5_XTARIFA     <> '' 
						  AND E5_XTARIFA     >= %EXP:MV_PAR05% 
						  AND E5_XTARIFA     <= %EXP:MV_PAR06% 
			              AND SE5.D_E_L_E_T_ <> '*'  
			
			 GROUP BY ZC2_BANCO,ZC2_TARIFA 

		 	ORDER BY ZC2_TARIFA		
	EndSQl
RETURN()


Static Function SqlTotBancos(cBanco)

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRF"
			%NoPARSER%
			SELECT  ZC2_BANCO, 
					SUM(ZC2_VALOR) AS ZC2_VALOR
			  FROM %Table:SE5% AS SE5 WITH (NOLOCK)   
			       INNER JOIN %Table:ZC2% AS ZC2 WITH (NOLOCK)    
			               ON E5_FILIAL       = ZC2_FILIAL    
						  AND E5_XTARIFA      = ZC2_CODIGO
						  AND ZC2.ZC2_BANCO   = %EXP:cBanco%     
						  AND ZC2.D_E_L_E_T_ <> '*'  
			            WHERE E5_FILIAL      >= %EXP:MV_PAR01% 
			              AND E5_FILIAL      <= %EXP:MV_PAR02% 
			              AND E5_DATA        >= %EXP:MV_PAR03% 
				          AND E5_DATA        <= %EXP:MV_PAR04%
				          AND E5_XTARIFA     <> '' 
						  AND E5_XTARIFA     >= %EXP:MV_PAR05% 
						  AND E5_XTARIFA     <= %EXP:MV_PAR06% 
			              AND SE5.D_E_L_E_T_ <> '*'  
			
			 GROUP BY ZC2_BANCO 

		 	ORDER BY ZC2_BANCO		
	EndSQl
RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_TARIFAS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_TARIFAS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()
                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(cPerg,'01','Filial De      ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Filial Ate     ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Data  De       ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Data  Ate      ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Tarifa de      ?','','','mv_ch5','C',06,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Tarifa Ate     ?','','','mv_ch6','C',06,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR06')	
	U_xPutSX1(cPerg,"07",'Tipo Relatorio ?','','',"mv_ch7","N",01,0,01,"C","","","","","MV_PAR07" ,"Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico","","","","","","","",""," ")
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "     ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"TARIFA "     ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME TARIFA ",1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"BANCO "      ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"AGENCIA "    ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"CONTA "      ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA "       ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"NATUREZA "   ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"VALOR TITULO",1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD. TARIFA ",1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"VLR_UNIT "   ,1,1) // 11 K 			
	oExcel:AddColumn(cPlanilha,cTitulo,"VALOR TARIFA",1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"DIF "        ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFT "       ,1,1) // 14 N
		
RETURN(NIL)

Static Function CabecSint()

	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Tarifas "     ,1,1) // 01 A
	
	SqlCab()
	
	WHILE TRC->(!EOF())
	
		nCont := nCont+1
	
		oExcel:AddColumn(cPlanilha,cTitulo,TRC->ZC2_BANCO + " ",1,1)
		 
		aBanco:={}
		AADD(aBanco,TRC->ZC2_BANCO)
		AADD(aBanco,nCont)
		AADD(aBancos,aBanco)
			
		TRC->(dbSkip())    
		
	ENDDO //end do while TRB
	TRC->( DBCLOSEAREA() )   
	
	oExcel:AddColumn(cPlanilha,cTitulo,"Total Geral "     ,1,1) // 01 A
	
RETURN(NIL)