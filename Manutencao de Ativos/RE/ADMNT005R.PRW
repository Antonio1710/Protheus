#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMNT005R ºAutor  ³Adriana Oliveira    º Data ³  11/01/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Ordens de Servico                             º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAMNT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function ADMNT005R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relação de Ordens de Serviço"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= "ADMNT005R"
	Private cObserva 	:= ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Ordens de Servico')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relação de Ordens de Serviço" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdMNT005R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdMNT005R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'C:\TEMP\'
	Public cArquivo    := 'REL_ADMNT005R.XML'
	Public oMsExcel
	Public cPlanilha   := "ORDEM DE SERVIÇO"
    Public cTitulo     := "Ordem de Serviço"
	Public aLinhas     := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		//CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

	Local nLinha      := 0
	Local nExcel      := 0
	
	SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		        
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
		   	               "", ; // 14 N  
		   	               "", ; // 15 O  
		   	               "", ; // 16 P   
		   	               "", ; // 17 Q  
		   	               "", ; // 18 R  
		   	               "", ; // 19 S  
		   	               "", ; // 20 T   
		   	               "", ; // 21 U  
		   	               "", ; // 22 V  
		   	               "", ; // 23 X  
		   	               ""  ; // 24 Y   
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			
			cObserva := Left(TRB->TJ_OBSERVA,254)
			aLinhas[nLinha][01] := TRB->TJ_FILIAL           //A
			aLinhas[nLinha][02] := TRB->TJ_ORDEM            //B
			aLinhas[nLinha][03] := TRB->TJ_PLANO   			//C
			aLinhas[nLinha][04] := TRB->TJ_CODBEM           //D
			aLinhas[nLinha][05] := cObserva					//E
			aLinhas[nLinha][06] := TRB->TJ_SERVICO 			//F
			aLinhas[nLinha][07] := TRB->DTORIGI             //G
			aLinhas[nLinha][08] := TRB->TJ_CCUSTO           //H
			aLinhas[nLinha][09] := TRB->DTULTMA             //I
			aLinhas[nLinha][10] := TRB->DTPPINI   			//J
			aLinhas[nLinha][11] := TRB->TJ_HOPPINI          //K
			aLinhas[nLinha][12] := TRB->DTPPFIM             //L
			aLinhas[nLinha][13] := TRB->TJ_HOPPFIM          //M
			aLinhas[nLinha][14] := TRB->DTPRINI   			//N
			aLinhas[nLinha][15] := TRB->TJ_HOPRINI          //O
			aLinhas[nLinha][16] := TRB->DTPRFIM             //P
			aLinhas[nLinha][17] := TRB->TJ_HOPRFIM          //Q
			aLinhas[nLinha][18] := TRB->TJ_TERMINO   		//R
			aLinhas[nLinha][19] := TRB->TJ_USUARIO          //S
			aLinhas[nLinha][20] := TRB->TJ_PRIORID 			//T
			aLinhas[nLinha][21] := TRB->TJ_SITUACA          //U
			aLinhas[nLinha][22] := TRB->TJ_TIPOOS 			//V
			aLinhas[nLinha][23] := TRB->TJ_SOLICI           //X
			aLinhas[nLinha][24] := TRB->TJ_XNUMFOR          //Y
			                                  
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
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
		                                 aLinhas[nExcel][09],; // 02 I  
		                                 aLinhas[nExcel][10],; // 03 J  
		                                 aLinhas[nExcel][11],; // 04 K  
		                                 aLinhas[nExcel][12],; // 05 L  
		                                 aLinhas[nExcel][13],; // 06 M  
		                                 aLinhas[nExcel][14],; // 07 N  
		                                 aLinhas[nExcel][15],; // 08 O  
		                                 aLinhas[nExcel][16],; // 02 P  
		                                 aLinhas[nExcel][17],; // 03 Q  
		                                 aLinhas[nExcel][18],; // 04 R  
		                                 aLinhas[nExcel][19],; // 05 S  
		                                 aLinhas[nExcel][20],; // 06 T  
		                                 aLinhas[nExcel][21],; // 07 U  
		                                 aLinhas[nExcel][22],; // 08 V  
		                                 aLinhas[nExcel][23],; // 02 X  
		                                 aLinhas[nExcel][24] ; // 02 Y  
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT 	TJ_FILIAL, 
			       	TJ_ORDEM,    
					TJ_PLANO,
					TJ_CODBEM,   
					ISNULL(CONVERT(VARCHAR(8000),REPLACE(CONVERT(VARBINARY(8000),TJ_OBSERVA),char(13)+char(10),' ')),' ') AS TJ_OBSERVA,
					TJ_SERVICO,
					SUBSTRING(TJ_DTORIGI,7,2)+'/'+SUBSTRING(TJ_DTORIGI,5,2)+'/'+SUBSTRING(TJ_DTORIGI,1,4) DTORIGI,
					TJ_CCUSTO ,
					SUBSTRING(TJ_DTULTMA,7,2)+'/'+SUBSTRING(TJ_DTULTMA,5,2)+'/'+SUBSTRING(TJ_DTULTMA,1,4) DTULTMA,
					SUBSTRING(TJ_DTPPINI,7,2)+'/'+SUBSTRING(TJ_DTPPINI,5,2)+'/'+SUBSTRING(TJ_DTPPINI,1,4) DTPPINI,
					TJ_HOPPINI ,
					SUBSTRING(TJ_DTPPFIM,7,2)+'/'+SUBSTRING(TJ_DTPPFIM,5,2)+'/'+SUBSTRING(TJ_DTPPFIM,1,4) DTPPFIM,
					TJ_HOPPFIM ,   
					SUBSTRING(TJ_DTPRINI,7,2)+'/'+SUBSTRING(TJ_DTPRINI,5,2)+'/'+SUBSTRING(TJ_DTPRINI,1,4) DTPRINI,   
					TJ_HOPRINI ,
					SUBSTRING(TJ_DTPRFIM,7,2)+'/'+SUBSTRING(TJ_DTPRFIM,5,2)+'/'+SUBSTRING(TJ_DTPRFIM,1,4) DTPRFIM,  
					TJ_HOPRFIM ,   
					TJ_TERMINO ,
					TJ_USUARIO ,
					TJ_PRIORID ,     
					TJ_SITUACA ,       
					TJ_TIPOOS ,  
					TJ_SOLICI ,
					TJ_XNUMFOR 			       
			  FROM 	%Table:STJ% 
			 WHERE TJ_FILIAL  BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
			   AND TJ_DTORIGI  BETWEEN %exp:cDataIni% AND %exp:cDataFin% 
			   AND D_E_L_E_T_ = ''
			ORDER BY TJ_FILIAL, TJ_ORDEM			
			
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_ADMNT005R.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_ADMNT005R.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De   ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate  ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data De     ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Ate    ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "            ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"ORDEM SERVIÇO "     ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"PLANO MANUT. "      ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"BEM "          		,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"DESCRIÇÃO "   		,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"SERVIÇO "    		,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA ORIGIN. "    	,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"CENTRO CUSTO "      ,1,1) // 08 H 			
	oExcel:AddColumn(cPlanilha,cTitulo,"ÚLT. MANUT. "       ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. P. IN. MAN. "   ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. P. IN. MAN. "   ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. P. FIM MAN. "   ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. P. FIM MAN. "   ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. R. IN. MAN. "   ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. R. IN. MAN. "   ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. R. FIM MAN. "   ,1,1) // 16 P 			
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. R. FIM MAN. "   ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"TÉRMINO "   		,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"USUÁRIO ALT. "   	,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"PRIORIDADE " 		,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"SITUAÇÃO "          ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO OS "    		,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"SOL. SERVIÇO "  	,1,1) // 23 X
	oExcel:AddColumn(cPlanilha,cTitulo,"SOL. SERV. ADORO "  ,1,1) // 24 Y
		
RETURN(NIL)