#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG029R ºAutor  ³William COSTA       º Data ³  30/08/2016 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ Relatorio de Cortes de Pedidos de Venda ou Deletados       º±±
//±±ºDesc.     ³ pelo Deletado pelo Financeiro ou Cortado pela Expedicao    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAFAT                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ADLOG029R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Cortes de Pedidos de Venda ou Deletados pelo Deletado pelo Financeiro ou Cortado pela Expedicao')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Cortes ou Deletados dos pedidos de Venda"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG029R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Cortes ou Deletados dos pedidos de Venda" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog029R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog029R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_CORTES_PEDIDOS.XML'
	Public oMsExcel
	Public cPlanilha   := "Cortes Pedidos"
    Public cTitulo     := "Relatorio de Cortes ou Deletados dos pedidos de Venda"
	Public aLinhas     := {}
   
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

    Local cNomeRegiao := ''
	Local nLinha      := 0
	Local nExcel      := 0
	
	SqlPedCortado() 
	
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
		   	               ""  ; // 20 T  
		   	                })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->C6_FILIAL                                    //A
			aLinhas[nLinha][02] := TRB->C6_NUM                                       //B
			aLinhas[nLinha][03] := TRB->C6_CLI                                       //C
			aLinhas[nLinha][04] := TRB->A1_NOME                                      //D
			aLinhas[nLinha][05] := STOD(TRB->C6_ENTREG)                              //E
			aLinhas[nLinha][06] := TRB->C6_NOTA                                      //F
			aLinhas[nLinha][07] := TRB->C6_PRODUTO                                   //G
			aLinhas[nLinha][08] := TRB->B1_DESC                                      //H
			aLinhas[nLinha][09] := TRB->C6_QTDORI                                    //I
			aLinhas[nLinha][10] := TRB->C6_QTDVEN                                    //J
			aLinhas[nLinha][11] := TRB->QTD_CORTE                                    //K
			aLinhas[nLinha][12] := TRB->C5_ROTEIRO                                   //L
			aLinhas[nLinha][13] := TRB->C5_SEQUENC                                   //M
			aLinhas[nLinha][14] := TRB->C5_PLACA                                     //N
			aLinhas[nLinha][15] := TRB->ZD_RESPNOM                                   //O
			aLinhas[nLinha][16] := TRB->ZD_DESCMOT                                   //P
		    aLinhas[nLinha][17] := TRB->ZD_AUTNOME                                   //Q
			aLinhas[nLinha][18] := STOD(STRTRAN(SUBSTR(TRB->DTHRCORTE,1,10),'-','')) //R
			aLinhas[nLinha][19] := SUBSTR(TRB->DTHRCORTE,12,8)                       //S
			aLinhas[nLinha][20] := TRB->C6_STATUS                                    //T
			
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
	SqlPedExcluido() 
	
	DBSELECTAREA("TRC")
		TRC->(DBGOTOP())
		WHILE TRC->(!EOF())
		
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
		   	               ""  ; // 20 T  
		   	                })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRC->C6_FILIAL                                                                      //A
			aLinhas[nLinha][02] := TRC->C6_NUM                                                                         //B
			aLinhas[nLinha][03] := TRC->C6_CLI                                                                         //C
			aLinhas[nLinha][04] := TRC->A1_NOME                                                                        //D
			aLinhas[nLinha][05] := STOD(TRC->C6_ENTREG)                                                                //E
			aLinhas[nLinha][06] := TRC->C6_NOTA                                                                        //F
			aLinhas[nLinha][07] := TRC->C6_PRODUTO                                                                     //G
			aLinhas[nLinha][08] := TRC->B1_DESC                                                                        //H
			aLinhas[nLinha][09] := TRC->C6_QTDORI                                                                      //I
			aLinhas[nLinha][10] := TRC->C6_QTDVEN                                                                      //J
			aLinhas[nLinha][11] := TRC->QTD_CORTE                                                                      //K
			aLinhas[nLinha][12] := TRC->C5_ROTEIRO                                                                     //L
			aLinhas[nLinha][13] := TRC->C5_SEQUENC                                                                     //M
			aLinhas[nLinha][14] := TRC->C5_PLACA                                                                       //N
			aLinhas[nLinha][15] := TRC->ZD_RESPNOM                                                                     //O
			aLinhas[nLinha][16] := TRC->ZD_DESCMOT                                                                     //P
			aLinhas[nLinha][17] := TRC->ZD_AUTNOME                                                                     //Q
			aLinhas[nLinha][18] := IIF(ALLTRIM(SUBSTR(TRC->DTHRCORTE,1,8)) <> '',STOD(SUBSTR(TRC->DTHRCORTE,1,8)), '') //R
			aLinhas[nLinha][19] := SUBSTR(TRC->DTHRCORTE,9,9)                                                          //S
			aLinhas[nLinha][20] := TRC->C6_STATUS                                                                      //T
			
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRC->(dbSkip())    
		
		END //end do while TRB
		TRC->( DBCLOSEAREA() )		
		
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
		                                 aLinhas[nExcel][14],; // 14 N  
		                                 aLinhas[nExcel][15],; // 15 O  
		                                 aLinhas[nExcel][16],; // 16 P  
		                                 aLinhas[nExcel][17],; // 17 Q  
		                                 aLinhas[nExcel][18],; // 18 R  
		                                 aLinhas[nExcel][19],; // 19 S  
		                                 aLinhas[nExcel][20] ; // 20 T  
		                                                   }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlPedCortado()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT C6_FILIAL,
			       C6_NUM,
				   C6_CLI,
				   A1_NOME,
				   C6_ENTREG,
				   C6_NOTA,
				   C6_PRODUTO,
				   B1_DESC,
				   C6_QTDORI,
				   C6_QTDVEN,
				   (C6_QTDORI - C6_QTDVEN) AS QTD_CORTE,
				   C5_ROTEIRO,
				   C5_SEQUENC,
				   C5_PLACA,
				   ZD_RESPNOM,
				   ZD_DESCMOT,
				   ZD_AUTNOME,
				   (SELECT TOP(1) CONVERT(VARCHAR,DT_CARGEXPEHORAFINA,121) FROM [LNKMIMS].[SMART].[dbo].[EXPEDICAO_CARGA_HORARIO] WHERE ID_CARGEXPE =  RIGHT(C5_X_SQED,6) ORDER BY DT_CARGEXPEHORAFINA DESC) AS DTHRCORTE,
			       CASE WHEN %Table:SC6%.D_E_L_E_T_ <> '*' THEN 'PEDIDO CORTADO' ELSE 'PEDIDO EXCLUIDO' END AS C6_STATUS
			  FROM %Table:SC6%, %Table:SB1%, %Table:SC5%
			  LEFT JOIN %Table:SA1%
			         ON C5_CLIENTE = A1_COD
			        AND C5_LOJACLI = A1_LOJA
			  LEFT JOIN %Table:SZD%
			         ON C5_FILIAL = ZD_FILIAL
			        AND C5_NUM    = ZD_PEDIDO
			WHERE C6_FILIAL      >= %exp:MV_PAR01%
			   AND C6_FILIAL     <= %exp:MV_PAR02%
			   AND C6_ENTREG     >= %exp:cDataIni%
			   AND C6_ENTREG     <= %exp:cDataFin%
			   AND C6_NUM        >= %exp:MV_PAR05%
			   AND C6_NUM        <= %exp:MV_PAR06%
			   AND C6_QTDORI      > 0
			   AND C6_QTDORI     <> C6_QTDVEN
			   AND C6_FILIAL      = C5_FILIAL
			   AND C6_NUM         = C5_NUM
			   AND C6_CLI         = C5_CLIENTE
			   AND C6_LOJA        = C5_LOJACLI
			   AND C5_X_SQED     <> ''
			   AND C6_PRODUTO     = B1_COD
			   AND B1_TIPO        = 'PA'
			   and B1_LOCPAD      = '10'
			   
			  ORDER BY %Table:SC6%.C6_FILIAL,%Table:SC6%.C6_NUM
			
	EndSQl
RETURN()    

Static Function SqlPedExcluido()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT C6_FILIAL,
			       C6_NUM,
				   C6_CLI,
				   A1_NOME,
				   C6_ENTREG,
				   C6_NOTA,
				   C6_PRODUTO,
				   B1_DESC,
				   C6_QTDORI,
				   C6_QTDVEN,
				   (C6_QTDVEN - C6_QTDORI) AS QTD_CORTE,
				   C5_ROTEIRO,
				   C5_SEQUENC,
				   C5_PLACA,
				   ZD_RESPNOM,
				   ZD_DESCMOT,
				   ZD_AUTNOME,
				   (SELECT TOP(1) C9_DATALIB + ' ' + C9_XHRAPRO FROM %Table:SC9% WHERE C9_FILIAL  = C6_FILIAL AND C9_PEDIDO  = C6_NUM AND C9_CLIENTE = C6_CLI AND C9_LOJA    = C6_LOJA AND C9_PRODUTO = C6_PRODUTO AND C9_ITEM    =  C6_ITEM) AS DTHRCORTE,  
				   CASE WHEN %Table:SC6%.D_E_L_E_T_ <> '*' THEN 'PEDIDO CORTADO' ELSE 'PEDIDO EXCLUIDO' END AS C6_STATUS
			  FROM %Table:SC6%, %Table:SB1%, %Table:SC5%
			  INNER JOIN %Table:SZD%
			         ON C5_FILIAL         = ZD_FILIAL
			        AND C5_NUM            = ZD_PEDIDO
					AND ZD_RESPONS       <> '09'  
			  LEFT JOIN %Table:SA1% 
			         ON C5_CLIENTE   = A1_COD
			        AND C5_LOJACLI   = A1_LOJA
			 WHERE C6_FILIAL        >= %exp:MV_PAR01%
			   AND C6_FILIAL        <= %exp:MV_PAR02%
			   AND C6_ENTREG        >= %exp:cDataIni%
			   AND C6_ENTREG        <= %exp:cDataFin%
			   AND C6_NUM           >= %exp:MV_PAR05%
			   AND C6_NUM           <= %exp:MV_PAR06%
			   AND C6_QTDORI        <> C6_QTDVEN
			   AND C6_FILIAL         = C5_FILIAL
			   AND C6_NUM            = C5_NUM
			   AND C6_CLI            = C5_CLIENTE
			   AND C6_LOJA           = C5_LOJACLI
			   AND C6_PRODUTO        = B1_COD
			   AND B1_TIPO           = 'PA'
			   and B1_LOCPAD         = '10'
			   AND %Table:SC6%.D_E_L_E_T_ = '*'   
			   AND %Table:SC5%.D_E_L_E_T_ = '*'
			   
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_CORTES_PEDIDOS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_CORTES_PEDIDOS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De        ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate       ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Entrega De  ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Entrega Ate ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Num Pedido de    ?','','','mv_ch5','C',06,0,0,'G',bValid,'SC5',cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Num Pedido Ate   ?','','','mv_ch6','C',06,0,0,'G',bValid,'SC5',cSXG,cPyme,'MV_PAR06')

	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "       ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM. PEDIDO "  ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"CLIENTE "      ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME "         ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA ENTREGA " ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"NOTA "         ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"PRODUTO "      ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"DESC PROD "    ,1,1) // 08 H 			
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD ORIG "     ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD VEN "      ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD CORTE "    ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"ROTEIRO "      ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"SEQ "          ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"PLACA "        ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"SETOR RESP "   ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"DESC MOTIVO "  ,1,1) // 16 P 			
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME RESP "    ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. CORTE."    ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. CORTE."    ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"STATUS"        ,1,1) // 20 T
		
RETURN(NIL)