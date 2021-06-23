#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM031R ºAutor  ³William COSTA       º Data ³  09/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Comparacao de Preco de Atualizacao de Cotacao º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADCOM031R()
	
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Comparativo de Preços"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg       := 'ADCOM031R'
	Private cColunas    := ''
	Private oExcel      := FWMSEXCEL():New()
	Private cArquivo    := 'REL_COMPARATIVO_PRECO.XML'
	Private oMsExcel
	Private cPlanilha   := "Comparativo Preco"
    Private cTitulo     := "Comparativo Preco"
    Private aLinha      := {}
	Private aLinhas     := {}
	Private aFornece    := {}
	Private aForneces   := {}
	Private nExcel      := 0 
	Private nLinha      := 0
	Private cNomeRegiao := ''
	Private nTotReg	     := 0
	Private nCont       := 0  
	Private nCont2      := 0
	Private nCont3      := 0
	Private nColunas    := 0
	Private nTotLinha   := 0
	Private nTotColuna  := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Comparativo Preço de Comparação" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADCOM031R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         
Static Function LogADCOM031R()
    
	BEGIN SEQUENCE
	
		IF MV_PAR02 == 2
		
			IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
			    Alert("Não Existe Excel Instalado")
	            BREAK
	        ENDIF
	        
        ENDIF		
        	
    	Cabec()             
    	GeraExcel()
        SalvaXml()
		CriaExcel()
		
		IF MV_PAR02 == 2
		
			MsgInfo("Arquivo Excel gerado!")
	        
	    ENDIF
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

	Local nFornece    := 0
	Local nTotGeral   := 0

	nTotGeral := 0

    SqlCotacao()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRC","!Eof()")
	nLinha  := 0
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRC")
		TRC->(DBGOTOP())
		WHILE TRC->(!EOF())
		
			IncProc("Processando nº Cotacao. " + TRC->C8_NUM + ' Produto: ' + TRC->C8_PRODUTO)  
		
        	nLinha  := nLinha + 1                                       
		
            //===================== INICIO CRIA VETOR COM POSICAO VAZIA
            aLinha := {}
            
            AADD(aLinha, "") 
            AADD(aLinha, "")
            AADD(aLinha, "")
            AADD(aLinha, "")
            AADD(aLinha, "")
            AADD(aLinha, "")
            
            FOR nCont := 1 TO LEN(aForneces)
            	
            	AADD(aLinha, "")
            	AADD(aLinha, "")
            	
		   	NEXT
		   	
		   	AADD(aLinhas,aLinha)
		   	
		   	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRC->C8_NUM     //A
			aLinhas[nLinha][02] := TRC->C8_ITEM    //B
			aLinhas[nLinha][03] := TRC->C8_PRODUTO //C
			aLinhas[nLinha][04] := TRC->B1_DESC    //D
			aLinhas[nLinha][05] := TRC->C8_UM      //E
			aLinhas[nLinha][06] := TRC->C8_QUANT   //F
			nCont3              := 6
			
			FOR nCont2 := 1 TO LEN(aForneces)
			
				nCont3 := nCont3 + 1
				SqlVlFornece(TRC->C8_NUM,TRC->C8_ITEM,aForneces[nCont2][1],aForneces[nCont2][2])
				
				WHILE TRD->(!EOF())
					
				    aLinhas[nLinha][nCont3] := TRD->C8_PRECO
				    nCont3 := nCont3 + 1              
				    aLinhas[nLinha][nCont3] := TRD->C8_TOTAL                          
		               	 
				   	TRD->(dbSkip())    
					
				ENDDO //end do while TRB
				TRD->( DBCLOSEAREA() )  
				 
			NEXT
						                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
			TRC->(dbSkip())    
		
		ENDDO //end do while TRB
	TRC->( DBCLOSEAREA() )   
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
            		
            cColunas := 'aLinhas[nExcel][01],aLinhas[nExcel][02],aLinhas[nExcel][03],aLinhas[nExcel][04],aLinhas[nExcel][05],aLinhas[nExcel][06],'
            nCont3   := 6		
			FOR nColunas := 1 TO LEN(aForneces) 
			
				nCont3   := nCont3 + 1
				cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nCont3,2) + '],'
				nCont3   := nCont3 + 1
				cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nCont3,2) + '],'
				
			NEXT
			cColunas := SUBSTR(cColunas,1,LEN(cColunas)-1) //Retira a ultima virgula
			&("oExcel:AddRow(cPlanilha,cTitulo,{" + cColunas + "})")
		   	
			                               
	    NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
	 	
	 	// *** Inicio Total Geral *** //
	 	
	 	aLinha := {}
            
        AADD(aLinha, "") 
        AADD(aLinha, "")
        AADD(aLinha, "")
        AADD(aLinha, "")
        AADD(aLinha, "")
        AADD(aLinha, "")
        
        FOR nCont := 1 TO LEN(aForneces)
        	
        	AADD(aLinha, "")
        	AADD(aLinha, "")
        	
	   	NEXT
	   	
	   	AADD(aLinhas,aLinha)
	   	
	   	nLinha              := nLinha + 1
	   	aLinhas[nLinha][01] := 'Total Geral'
	   	nCont3              := 6
	   	FOR nCont2 := 1 TO LEN(aForneces)
	   	
	   		SqlTotFornece(MV_PAR01,aForneces[nCont2][1],aForneces[nCont2][2])
	   	
	   		WHILE TRE->(!EOF())
			    nCont3                  := nCont3 + 2
	   			aLinhas[nLinha][nCont3] := TRE->C8_TOTAL                                        
	                                                     
	            TRE->(dbSkip())    
				
			ENDDO //end do while TRB
			TRE->( DBCLOSEAREA() ) 
            
		NEXT
	   	
	   	//============================== INICIO IMPRIME LINHA NO EXCEL
		    		
        cColunas := 'aLinhas[nExcel][01],aLinhas[nExcel][02],aLinhas[nExcel][03],aLinhas[nExcel][04],aLinhas[nExcel][05],aLinhas[nExcel][06],'
        nCont3   := 6		
		FOR nColunas := 1 TO LEN(aForneces) 
		
			nCont3   := nCont3 + 1
			cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nCont3,2) + '],'
			nCont3   := nCont3 + 1
			cColunas := cColunas + 'aLinhas[nExcel][' + STRZERO(nCont3,2) + '],'
			
		NEXT
		cColunas := SUBSTR(cColunas,1,LEN(cColunas)-1) //Retira a ultima virgula
		&("oExcel:AddRow(cPlanilha,cTitulo,{" + cColunas + "})")
		 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
		  	
	   // *** Final Total Geral *** //
	 	
Return()

Static Function SqlCab()

	BeginSQL Alias "TRB"
			%NoPARSER%
			   SELECT C8_FORNECE,C8_LOJA,A2_NOME 
			     FROM %TABLE:SC8% SC8 WITH(NOLOCK)
			LEFT JOIN %TABLE:SA2% SA2  WITH(NOLOCK)
			       ON A2_COD          = C8_FORNECE
				  AND A2_LOJA         = C8_LOJA
				  AND SA2.D_E_L_E_T_ <> '*'
			    WHERE C8_FILIAL       = %EXP:FWXFILIAL("SC8")%
			      AND C8_NUM          = %EXP:MV_PAR01%
				  AND SC8.D_E_L_E_T_ <> '*'
				
				GROUP BY C8_FORNECE,C8_LOJA,A2_NOME 
			
			ORDER BY C8_FORNECE,C8_LOJA
			
	EndSQl
RETURN()

Static Function SqlCotacao()

	BeginSQL Alias "TRC"
			%NoPARSER%
			   SELECT C8_NUM,C8_ITEM,C8_PRODUTO,B1_DESC,C8_QUANT,C8_UM
			     FROM %TABLE:SC8% SC8 WITH(NOLOCK)
			LEFT JOIN %TABLE:SB1% SB1 WITH(NOLOCK)
			       ON B1_COD          = C8_PRODUTO
			   	  AND SB1.D_E_L_E_T_ <> '*'
			    WHERE C8_FILIAL       = %EXP:FWXFILIAL("SC8")%
			      AND C8_NUM          = %EXP:MV_PAR01%
				  AND SC8.D_E_L_E_T_ <> '*'
			
			GROUP BY C8_NUM,C8_ITEM,C8_PRODUTO,B1_DESC,C8_QUANT,C8_UM
			
			ORDER BY SC8.C8_ITEM		
	EndSQl
RETURN()

Static Function SqlVlFornece(cNum,cItem,cFornece,cLojaFor)

	BeginSQL Alias "TRD"
			%NoPARSER%
			   SELECT C8_NUM,C8_ITEM,C8_PRODUTO,B1_DESC,C8_FORNECE,C8_LOJA,C8_QUANT,C8_PRECO,C8_TOTAL
			     FROM %TABLE:SC8% SC8 WITH(NOLOCK)
			LEFT JOIN %TABLE:SB1% SB1 WITH(NOLOCK)
			       ON B1_COD = C8_PRODUTO
			   	  AND SB1.D_E_L_E_T_ <> '*'
			    WHERE C8_FILIAL       = %EXP:FWXFILIAL("SC8")%
			      AND C8_NUM          = %EXP:cNum%
				  AND C8_ITEM         = %EXP:cItem%
				  AND C8_FORNECE      = %EXP:cFornece%
				  AND C8_LOJA         = %EXP:cLojaFor%
				  AND SC8.D_E_L_E_T_ <> '*'
			
			ORDER BY SC8.C8_ITEM
				
	EndSQl
RETURN()

Static Function SqlTotFornece(cNum,cFornece,cLojaFor)

	Local cTeste := ''
	BeginSQL Alias "TRE"
			%NoPARSER%
			SELECT SUM(C8_TOTAL) AS C8_TOTAL
		     FROM %TABLE:SC8% SC8 WITH(NOLOCK)
		    WHERE C8_FILIAL       = %EXP:FWXFILIAL("SC8")%
		      AND C8_NUM          = %EXP:cNum%
			  AND C8_FORNECE      = %EXP:cFornece%
			  AND C8_LOJA         = %EXP:cLojaFor%
			  AND SC8.D_E_L_E_T_ <> '*'
			
	EndSQl
RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_COMPARATIVO_PRECO.XML")

Return()

Static Function CriaExcel()              

	IF MV_PAR02 == 2
	
	    oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open("C:\temp\REL_COMPARATIVO_PRECO.XML")
		oMsExcel:SetVisible( .T. )
		oMsExcel := oMsExcel:Destroy()
		
	ELSE
	
		MsgAlert("OLÁ " + Alltrim(cUserName) + ", Você não tem excel, vá até o seguinte caminho: C:\temp\REL_COMPARATIVO_PRECO.XML, Clique com o Botão Direito Abrir com (LibreOffice ou WPS) " , "ADCOM031R-01")
		shellExecute("Open", "C:\Windows\explorer.exe", "C:\temp", "C:\temp", 1 )
		
	ENDIF	

Return() 

Static Function MontaPerg()
                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(cPerg,'01','Numero Cotacao ?','','','mv_ch1','C',06,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
    U_xPutSX1(cPerg,"02",'Tenho Excel    ?','','',"mv_ch2","N",01,0,01,"C","","","","","MV_PAR02" ,"Não","Não","Não","","Sim","Sim","Sim","","","","","","","",""," ")
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec()

	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Cotacao " ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Item "        ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Prod "    ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao "   ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Unid Med "    ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Qtd "         ,1,1) // 05 E
	
	SqlCab()
	
	WHILE TRB->(!EOF())
	
		nCont := nCont+1
	
		oExcel:AddColumn(cPlanilha,cTitulo,SUBSTR(TRB->A2_NOME,1,AT(' ',TRB->A2_NOME) - 1) + " ",1,1)
		oExcel:AddColumn(cPlanilha,cTitulo," ",1,1)
		 
		aFornece :={}
		AADD(aFornece,TRB->C8_FORNECE)
		AADD(aFornece,TRB->C8_LOJA)
		AADD(aFornece,nCont)
		AADD(aForneces,aFornece)
			
		TRB->(dbSkip())    
		
	ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )   
	
RETURN(NIL)