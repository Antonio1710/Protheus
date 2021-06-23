
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM003R ºAutor  ³William COSTA       º Data ³  04/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para acompanhamento de Compras por Grupo de      º±±
±±º          ³ Produtos em EXCEL.                                         º±±
±±º          ³ Relatorio Compras X Grupo de Produtos                      º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

User Function ADCOM003R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio Compras X Grupo de Produtos"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADCOM003R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Compras X Grupo de Produtos" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||COMADCOM003R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function COMADCOM003R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_COMPRAS_GRUPOSPRODUTOS.XML'
	Public oMsExcel
	Public cPlanilha   := "Pedido de Compras X Grupo de Produtos"
    Public cTitulo     := "Pedido de Compras X Grupo de Produtos"
    Public cCodProdSql := ''
    Public aLinhas    := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local nLinha      := 0
	Local nExcel      := 0
    Local cGrupOld    := '' 
    Local lPrimeira   := .F.
    Local nVlTotGrup  := 0 
    Local nTotGrup    := 0 
    Local nVlTotGeral := 0 
    


    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		cGrupOld := '' 
		WHILE TRB->(!EOF()) 
		                    
		        IF UPPER(ALLTRIM(cGrupOld)) ==  UPPER(ALLTRIM(TRB->B1_GRUPO))
		            nLinha  := nLinha + 1                                       
				
	                //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
				   	AADD(aLinhas,{ "", ; // 01 A  
				   	               "", ; // 02 B   
				   	               "", ; // 03 C  
				   	               "", ; // 04 D  
				   	               "", ; // 05 E  
				   	               "", ; // 06 F   
				   	                0  ; // 07 G  
				   	                   })
					//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := TRB->C7_NUM           //A
					aLinhas[nLinha][02] := STOD(TRB->C7_EMISSAO) //B
					aLinhas[nLinha][03] := TRB->C7_PRODUTO       //C
					aLinhas[nLinha][04] := TRB->C7_DESCRI        //D
					aLinhas[nLinha][05] := TRB->C7_QUANT         //E
					aLinhas[nLinha][06] := TRB->C7_PRECO         //F
					aLinhas[nLinha][07] := TRB->C7_TOTAL         //G
   	                nVlTotGrup           := nVlTotGrup  + TRB->C7_TOTAL
   	                nTotGrup             := nVlTotGrup
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				ELSE // GERA CABECALHO DO GRUPO DE PRODUTOS
				
					nLinha  := nLinha + 1                                       
				
	                //======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
					IF lPrimeira == .F.
					
						//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
					   	AADD(aLinhas,{ "", ; // 01 A  
					   	               "", ; // 02 B   
					   	               "", ; // 03 C  
					   	               "", ; // 04 D  
					   	               "", ; // 05 E  
					   	               "", ; // 06 F   
					   	                0  ; // 07 G  
					   	                   })
						//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					
						aLinhas[nLinha][01] := '' //A
						aLinhas[nLinha][02] := '' //B
						aLinhas[nLinha][03] := '' //C
						aLinhas[nLinha][04] := '' //D
						aLinhas[nLinha][05] := '' //E
						aLinhas[nLinha][06] := '' //F
						aLinhas[nLinha][07] := '' //G
						lPrimeira            := .T.
						
					ELSE  // lPrimeira
					
						//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
					   	AADD(aLinhas,{ "", ; // 01 A  
					   	               "", ; // 02 B   
					   	               "", ; // 03 C  
					   	               "", ; // 04 D  
					   	               "", ; // 05 E  
					   	               "", ; // 06 F   
					   	                0  ; // 07 G  
					   	                   })
						//===================== FINAL CRIA VETOR COM POSICAO VAZIA                          
					
						aLinhas[nLinha][01] := '' //A
						aLinhas[nLinha][02] := '' //B
						aLinhas[nLinha][03] := '' //C
						aLinhas[nLinha][04] := '' //D
						aLinhas[nLinha][05] := '' //E
						aLinhas[nLinha][06] := 'TOTAL GRUPO' //F
						aLinhas[nLinha][07] := nVlTotGrup //G 
						nTotGrup             := nVlTotGrup
                        nVlTotGeral          := nVlTotGeral + nVlTotGrup 
					    nVlTotGrup           := 0
					ENDIF //fecha if lPrimeira
	
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
					nLinha  := nLinha + 1                                       
				
	                //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
				   	AADD(aLinhas,{ "", ; // 01 A  
				   	               "", ; // 02 B   
				   	               "", ; // 03 C  
				   	               "", ; // 04 D  
				   	               "", ; // 05 E  
				   	               "", ; // 06 F   
				   	                0  ; // 07 G  
				   	                   })
					//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := "GRUPO"       //A
					aLinhas[nLinha][02] := ''            //B
					aLinhas[nLinha][03] := TRB->B1_GRUPO //C
					aLinhas[nLinha][04] := TRB->BM_DESC  //D
					aLinhas[nLinha][05] := ''            //E
					aLinhas[nLinha][06] := ''            //F
					aLinhas[nLinha][07] := ''            //G
	
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
					
					nLinha  := nLinha + 1                                       
				
	                //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
				   	AADD(aLinhas,{ "", ; // 01 A  
				   	               "", ; // 02 B   
				   	               "", ; // 03 C  
				   	               "", ; // 04 D  
				   	               "", ; // 05 E  
				   	               "", ; // 06 F   
				   	                0  ; // 07 G  
				   	                   })
					//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := '' //A
					aLinhas[nLinha][02] := '' //B
					aLinhas[nLinha][03] := '' //C
					aLinhas[nLinha][04] := '' //D
					aLinhas[nLinha][05] := '' //E
					aLinhas[nLinha][06] := '' //F
					aLinhas[nLinha][07] := '' //G
	
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
					
					//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
				   	AADD(aLinhas,{ "", ; // 01 A  
				   	               "", ; // 02 B   
				   	               "", ; // 03 C  
				   	               "", ; // 04 D  
				   	               "", ; // 05 E  
				   	               "", ; // 06 F   
				   	                0  ; // 07 G  
				   	                   })
					//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := TRB->C7_NUM           //A
					aLinhas[nLinha][02] := STOD(TRB->C7_EMISSAO) //B
					aLinhas[nLinha][03] := TRB->C7_PRODUTO       //C
					aLinhas[nLinha][04] := TRB->C7_DESCRI        //D
					aLinhas[nLinha][05] := TRB->C7_QUANT         //E
					aLinhas[nLinha][06] := TRB->C7_PRECO         //F
					aLinhas[nLinha][07] := TRB->C7_TOTAL         //G
                	nVlTotGrup           := nVlTotGrup  + TRB->C7_TOTAL
                	nTotGrup             := nVlTotGrup
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
					
					
				
			     	cGrupOld := TRB->B1_GRUPO
				
				ENDIF	
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )
		
        //********************************************INICIO GERA ULTIMOS TOTAIS    ************************************
        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
        nLinha  := nLinha + 1
        
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	                0  ; // 07 G  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := '' //A
		aLinhas[nLinha][02] := '' //B
		aLinhas[nLinha][03] := '' //C
		aLinhas[nLinha][04] := '' //D
		aLinhas[nLinha][05] := '' //E
		aLinhas[nLinha][06] := '' //F
		aLinhas[nLinha][07] := '' //G

		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
        
		//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		nLinha  := nLinha + 1
		
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	                0  ; // 07 G  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA                          
	
		aLinhas[nLinha][01] := '' //A
		aLinhas[nLinha][02] := '' //B
		aLinhas[nLinha][03] := '' //C
		aLinhas[nLinha][04] := '' //D
		aLinhas[nLinha][05] := '' //E
		aLinhas[nLinha][06] := 'TOTAL GRUPO' //F
		aLinhas[nLinha][07] := nTotGrup //G 
		
        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
        nLinha  := nLinha + 1
        
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	                0  ; // 07 G  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := '' //A
		aLinhas[nLinha][02] := '' //B
		aLinhas[nLinha][03] := '' //C
		aLinhas[nLinha][04] := '' //D
		aLinhas[nLinha][05] := '' //E
		aLinhas[nLinha][06] := '' //F
		aLinhas[nLinha][07] := '' //G

		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================					
	    
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	    nLinha  := nLinha + 1
	    
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	                0  ; // 07 G  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA                          
	
		aLinhas[nLinha][01] := '' //A
		aLinhas[nLinha][02] := '' //B
		aLinhas[nLinha][03] := '' //C
		aLinhas[nLinha][04] := '' //D
		aLinhas[nLinha][05] := '' //E
		aLinhas[nLinha][06] := 'TOTAL GERAL' //F
		aLinhas[nLinha][07] := nVlTotGeral //G 
		
		//********************************************FINAL GERA ULTIMOS TOTAIS    ************************************
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
            	                             aLinhas[nExcel][02],;  // 02 B  
	   	        	                         aLinhas[nExcel][03],;  // 03 C  
	   	            	                     aLinhas[nExcel][04],;  // 04 D  
	   	                	                 aLinhas[nExcel][05],;  // 05 E  
	   	                    	             aLinhas[nExcel][06],;  // 06 F  
	   	                        	         aLinhas[nExcel][07] ;  // 07 G  
                                    	                          }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
       NEXT 
	   //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

     Local cDataIni := DTOS(MV_PAR05)
     Local cDataFin := DTOS(MV_PAR06) 
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT SC7.C7_NUM,
			       SC7.C7_EMISSAO,
			       SC7.C7_PRODUTO,
			       SC7.C7_DESCRI,
			       SB1.B1_GRUPO,
			       SBM.BM_DESC,
			       SC7.C7_QUANT,
			       SC7.C7_PRECO,
			       SC7.C7_TOTAL
			  FROM %Table:SC7% SC7, %Table:SB1% SB1, %Table:SBM% SBM
			 WHERE SC7.C7_FILIAL  >= %exp:MV_PAR01%
			   AND SC7.C7_FILIAL  <= %exp:MV_PAR02%
			   AND SC7.C7_EMISSAO >= %exp:cDataIni%
			   AND SC7.C7_EMISSAO <= %exp:cDataFin%
			   AND SB1.B1_COD      = SC7.C7_PRODUTO
			   AND SBM.BM_GRUPO   >= %exp:MV_PAR03%
			   AND SBM.BM_GRUPO   <= %exp:MV_PAR04%
			   AND SBM.BM_GRUPO    = SB1.B1_GRUPO
			   AND SC7.%notDel%
			   AND SB1.%notDel%
			   AND SBM.%notDel%
			   
			   //Everson - 19/06/2017. Chamado 035749.
			   AND SC7.C7_CC >= %exp:MV_PAR07%
			   AND SC7.C7_CC <= %exp:MV_PAR08%
			   
			   
			   ORDER BY SB1.B1_GRUPO, SC7.C7_PRODUTO
    EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_COMPRAS_GRUPOSPRODUTOS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_COMPRAS_GRUPOSPRODUTOS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De               ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate              ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Grupo Produtos de       ?','','','mv_ch3','C',04,0,0,'G',bValid,"SBM"  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Grupo Produtos Ate      ?','','','mv_ch4','C',04,0,0,'G',bValid,"SBM"  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Data Emissao Pedido De  ?','','','mv_ch5','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Data Emissao Pedido Ate ?','','','mv_ch6','D',08,0,0,'G',bValid,cF3    ,cSXG,cPyme,'MV_PAR06')
	
	//Everson - 19/06/2017. Chamado 035749.
	PutSx1(cPerg,'07','Centro Custo De  ?','','','mv_ch7','C',08,0,0,'G',bValid,"CTT" ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Centro Custo Ate ?','','','mv_ch8','C',08,0,0,'G',bValid,"CTT" ,cSXG,cPyme,'MV_PAR08')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Numero Pedido "  ,1,1) // 01 A
  	oExcel:AddColumn(cPlanilha,cTitulo,"Data Emissao "   ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Produto "        ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao "      ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Quantidade "     ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Valor Unitário " ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Total "          ,1,1) // 07 G

	
RETURN(NIL)