#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG011R ºAutor  ³William COSTA       º Data ³  30/10/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Controle de Fretes Sintetico,agrupa placas    º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history ticket 70750 - Everson - 07/04/2022 - Adaptação do fonte para nova filial.
*/

User Function ADLOG011R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Controle de Fretes Sintetico,agrupa placas')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Controle de Fretes Sintetico"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG011R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Controle de Fretes Sintetico" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog011R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog011R()  
  
	PRIVATE oExcel      := FWMSEXCEL():New()
	PRIVATE cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	PRIVATE cArquivo    := 'REL_CON_FRETE_SINTETICO.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Contr. Frete Sintetico"
    PRIVATE cTitulo     := "Contr. Frete Sintetico"
	PRIVATE aLinhas     := {}
	
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
	Local nTotLiq     := 0
	Local nTotPesol   := 0
	
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
		   	               ""  ; // 23 W
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->ZK_PLACA                                              //A
			aLinhas[nLinha][02] := TRB->ZV4_ANO                                               //B
			aLinhas[nLinha][03] := TRB->ZV4_TIPVEI                                            //C
			aLinhas[nLinha][04] := TRB->ZK_TPFRETE                                            //D
			aLinhas[nLinha][05] := TRB->ZV4_TABELA                                            //E
			aLinhas[nLinha][06] := TRB->ZG_DESCRI                                             //F
			aLinhas[nLinha][07] := TRB->ZV4_CAPACI                                            //G
			aLinhas[nLinha][08] := TRB->ZV4_NOMFOR                                            //H
			aLinhas[nLinha][09] := TRB->ZK_VALFRET                                            //I
			aLinhas[nLinha][10] := TRB->VARIAVEL                                              //J
			aLinhas[nLinha][11] := TRB->DEBITO_ICMS                                           //K
			aLinhas[nLinha][12] := TRB->CREDITO_PIS_COFINS                                    //L
			aLinhas[nLinha][13] := TRB->ZCM_VLPEDA                                            //M
			aLinhas[nLinha][14] := TRB->ZK_ACRESCIMO                                          //N
			aLinhas[nLinha][15] := TRB->ZK_DECRESCIMO                                         //O
	        aLinhas[nLinha][16] := TRB->ZK_TOTALLIQ                                           //P
		    nTotLiq             := nTotLiq + TRB->ZK_TOTALLIQ
	        aLinhas[nLinha][17] := TRB->ZK_PESOL                                              //Q
			nTotPesol           := nTotPesol + TRB->ZK_PESOL
			aLinhas[nLinha][18] := CVALTOCHAR(TRB->CAPAC_LIQ) + '%'                           //R
			aLinhas[nLinha][19] := TRB->REAIS_TONELADA                                        //S
			aLinhas[nLinha][20] := TRB->ZK_PBRUTO                                             //T
			aLinhas[nLinha][21] := CVALTOCHAR(TRB->CAPAC_BRUTA) + '%'                         //U
			aLinhas[nLinha][22] := TRB->ZK_KMENT                                              //V
			aLinhas[nLinha][23] := TRB->ZK_ENTREGA                                            //W
			
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )   
		
		// *** INICIO MOSTRA TOTAL *** //
		
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
	   	               ""  ; // 23 W
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := 'TOTAL GERAL'          //A
		aLinhas[nLinha][02] := ''                     //B
		aLinhas[nLinha][03] := ''                     //C
		aLinhas[nLinha][04] := ''                     //D
		aLinhas[nLinha][05] := ''                     //E
		aLinhas[nLinha][06] := ''                     //F
		aLinhas[nLinha][07] := ''                     //G
		aLinhas[nLinha][08] := ''                     //H
		aLinhas[nLinha][09] := ''                     //I
		aLinhas[nLinha][10] := ''                     //J
		aLinhas[nLinha][11] := ''                     //K
		aLinhas[nLinha][12] := ''                     //L
		aLinhas[nLinha][13] := ''                     //M
		aLinhas[nLinha][14] := ''                     //N
		aLinhas[nLinha][15] := ''                     //O
		aLinhas[nLinha][16] := ''                     //P
	    aLinhas[nLinha][17] := nTotLiq                //Q
		aLinhas[nLinha][18] := nTotPesol              //R
		aLinhas[nLinha][19] := nTotLiq/nTotPesol*1000 //S
		aLinhas[nLinha][20] := ''                     //T
		aLinhas[nLinha][21] := ''                     //U
		aLinhas[nLinha][22] := ''                     //V
		aLinhas[nLinha][23] := ''                     //W
		
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		// *** FINAL MOSTRA TOTAL *** //
		
		
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
		                                 aLinhas[nExcel][20],; // 20 T
		                                 aLinhas[nExcel][21],; // 21 U 
		                                 aLinhas[nExcel][22],; // 22 V  
		                                 aLinhas[nExcel][23] ; // 23 W
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cDataIni := DTOS(MV_PAR01)  
    Local cDataFin := DTOS(MV_PAR02) 
     
    BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT  FONTES.ZK_PLACA,
					FONTES.ZV4_ANO,
					FONTES.ZV4_TIPVEI,
					FONTES.ZV4_TABELA,
					FONTES.ZG_DESCRI,
					FONTES.ZK_TPFRETE,
					FONTES.ZV4_CAPACI,
					FONTES.ZV4_NOMFOR,
					SUM(FONTES.ZK_VALFRET) AS ZK_VALFRET,
					SUM(FONTES.VARIAVEL) AS VARIAVEL,
					SUM(FONTES.DEBITO_ICMS) AS DEBITO_ICMS,
					SUM(FONTES.CREDITO_PIS_COFINS) AS CREDITO_PIS_COFINS,
					SUM(ISNULL(ZCM_VLPEDA,0)) AS ZCM_VLPEDA,
					SUM(FONTES.ZK_ACRESCIMO) AS ZK_ACRESCIMO,
					SUM(FONTES.ZK_DECRESCIMO) AS ZK_DECRESCIMO,
					SUM((FONTES.ZK_VALFRET+FONTES.VARIAVEL+FONTES.DEBITO_ICMS+ISNULL(ZCM_VLPEDA,0)+FONTES.ZK_ACRESCIMO)-(FONTES.CREDITO_PIS_COFINS+FONTES.ZK_DECRESCIMO)) AS ZK_TOTALLIQ,
					SUM(FONTES.ZK_PESOL) AS ZK_PESOL,
					CONVERT(NUMERIC(15,2),(CASE WHEN SUM(FONTES.ZK_PESOL) = 0 THEN 1 ELSE SUM(FONTES.ZK_PESOL) END / FONTES.ZV4_CAPACI) * 100)  AS CAPAC_LIQ,
					SUM((((FONTES.ZK_VALFRET+FONTES.VARIAVEL+FONTES.DEBITO_ICMS+ISNULL(ZCM_VLPEDA,0)+FONTES.ZK_ACRESCIMO)-(FONTES.CREDITO_PIS_COFINS+FONTES.ZK_DECRESCIMO)) /  CASE WHEN FONTES.ZK_PESOL = 0 THEN 1 ELSE FONTES.ZK_PESOL END) * 1000) AS REAIS_TONELADA,
					SUM(FONTES.ZK_PBRUTO) AS ZK_PBRUTO,
					CONVERT(NUMERIC(15,2),(CASE WHEN SUM(FONTES.ZK_PBRUTO) = 0 THEN 1 ELSE SUM(FONTES.ZK_PBRUTO) END  / FONTES.ZV4_CAPACI) * 100)  AS CAPAC_BRUTA,
					SUM(FONTES.ZK_KMENT) AS ZK_KMENT,
					SUM(FONTES.ZK_ENTREGA) AS ZK_ENTREGA
			  FROM (SELECT SZK.ZK_DTENTR,
							SZK.ZK_ROTEIRO,
							SZK.ZK_PLACA,
							ZV4.ZV4_ANO,
							ZV4.ZV4_TIPVEI,
							ZV4.ZV4_TABELA,
							SZG.ZG_DESCRI,
							SZK.ZK_TPFRETE,
							ZV4.ZV4_CAPACI,
							ZV4.ZV4_NOMFOR,
							SZK.ZK_VALFRET,
							ISNULL((SZK.ZK_VALFRET *(SZG.ZG_VARIAVE / 100)),0) AS VARIAVEL,
							ISNULL(((ZK_VALFRET+(SZK.ZK_VALFRET *(SZG.ZG_VARIAVE / 100)))/0.88)-(ZK_VALFRET+(SZK.ZK_VALFRET *(SZG.ZG_VARIAVE / 100))),0) AS DEBITO_ICMS,
							ISNULL(((ZK_VALFRET+(SZK.ZK_VALFRET *(SZG.ZG_VARIAVE / 100)))/0.9075)-(ZK_VALFRET+(SZK.ZK_VALFRET *(SZG.ZG_VARIAVE / 100))),0) AS CREDITO_PIS_COFINS,
							(SELECT CASE WHEN SUM(SZI.ZI_VALOR) IS NULL THEN 0 ELSE SUM(SZI.ZI_VALOR) END FROM %Table:SZI%  SZI WHERE SZI.ZI_FILIAL = %EXP:FWFILIAL('SZI')% AND SZK.ZK_PLACA = SZI.ZI_PLACA AND SZI.ZI_TIPO = 'A' AND SZK.ZK_DTENTR = SZI.ZI_DATAROT AND SZK.ZK_ROTEIRO = SZI.ZI_ROTEIRO AND SZI.D_E_L_E_T_ <> '*') AS ZK_ACRESCIMO,  //ticket 70750 - Everson - 07/04/2022.
							(SELECT CASE WHEN SUM(SZI.ZI_VALOR) IS NULL THEN 0 ELSE SUM(SZI.ZI_VALOR) END FROM %Table:SZI%  SZI WHERE SZI.ZI_FILIAL = %EXP:FWFILIAL('SZI')% AND SZK.ZK_PLACA = SZI.ZI_PLACA AND SZI.ZI_TIPO = 'D' AND SZK.ZK_DTENTR = SZI.ZI_DATAROT AND SZK.ZK_ROTEIRO = SZI.ZI_ROTEIRO AND SZI.D_E_L_E_T_ <> '*') AS ZK_DECRESCIMO, //ticket 70750 - Everson - 07/04/2022.
							SZK.ZK_PESOL,
							SZK.ZK_PBRUTO,
							SZK.ZK_KMENT,
							SZK.ZK_ENTREGA
						FROM %Table:ZV4% ZV4, %Table:SZK% SZK
						LEFT JOIN %Table:SZG% SZG
								ON ZG_FILIAL = %EXP:FWFILIAL('SZG')%
								AND ZG_CODIGO = ZK_TABELA
								AND SZG.D_E_L_E_T_ <> '*'
					WHERE 
					   SZK.ZK_FILIAL = %EXP:FWFILIAL('SZK')% //ticket 70750 - Everson - 07/04/2022.
					   AND ZV4.ZV4_FILIAL = %EXP:FWFILIAL('ZV4')% //ticket 70750 - Everson - 07/04/2022.
					   AND SZK.ZK_DTENTR   >= %EXP:cDataIni%
					   AND SZK.ZK_DTENTR  <= %EXP:cDataFin%
					   AND SZK.ZK_ROTEIRO >= %EXP:MV_PAR03%
					   AND SZK.ZK_ROTEIRO <= %EXP:MV_PAR04%
					   AND SZK.ZK_PLACA   >= %EXP:MV_PAR05%
					   AND SZK.ZK_PLACA   <= %EXP:MV_PAR06%
					   AND SZK.ZK_TPFRETE >= %EXP:MV_PAR07%
					   AND SZK.ZK_TPFRETE <= %EXP:MV_PAR08%
					   AND SZK.D_E_L_E_T_ <> '*'
					   AND SZK.ZK_PLACA    = ZV4.ZV4_PLACA
					   AND ZV4.D_E_L_E_T_ <> '*'
						   
						GROUP BY SZK.ZK_DTENTR,
								SZK.ZK_ROTEIRO,
								SZK.ZK_PLACA,
								ZV4.ZV4_ANO,
								ZV4.ZV4_TIPVEI,
								ZV4.ZV4_TABELA,
								SZG.ZG_DESCRI,
								SZK.ZK_TPFRETE,
								ZV4.ZV4_CAPACI,
								ZV4.ZV4_NOMFOR,
								SZK.ZK_VALFRET,
								SZG.ZG_VARIAVE,
								SZK.ZK_PESOL,
								SZK.ZK_PBRUTO,
								SZK.ZK_KMENT,
								SZK.ZK_ENTREGA
						
				      ) AS FONTES
			            LEFT JOIN %Table:ZCM% ZCM
						       ON ZCM_FILIAL      = %EXP:FWFILIAL('ZCM')%
			                  AND FONTES.ZK_DTENTR  BETWEEN ZCM_DTINI  AND ZCM_DTFIN
			                  AND FONTES.ZK_ROTEIRO BETWEEN ZCM_ROTINI AND ZCM_ROTFIN
			                  AND ZCM_TIPVEI      = FONTES.ZV4_TIPVEI
			                  AND ZCM.D_E_L_E_T_ <> '*'
			
						      GROUP BY FONTES.ZK_PLACA,
						               FONTES.ZV4_ANO,
							           FONTES.ZV4_TIPVEI,
							           FONTES.ZV4_TABELA,
								       FONTES.ZG_DESCRI,
									   FONTES.ZK_TPFRETE,
									   FONTES.ZV4_CAPACI,
									   FONTES.ZV4_NOMFOR
				
				              ORDER BY ZK_PLACA
						  						  
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_CON_FRETE_SINTETICO.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_CON_FRETE_SINTETICO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Data Entrega De  ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Data Entrega Ate ?','','','mv_ch2','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Roteiro Ini      ?','','','mv_ch3','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Roteiro Fin      ?','','','mv_ch4','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Placa Ini        ?','','','mv_ch5','C',07,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Placa Fin        ?','','','mv_ch6','C',07,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Tipo Frete Ini   ?','','','mv_ch7','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Tipo Frete Fin   ?','','','mv_ch8','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR08')

	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"PLACA "              ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"ANO "                ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"TP VEICULO "         ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"TP FRETE "           ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"TABELA FRETE "       ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"DESC. TABELA FRETE " ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"CAPACIDADE "         ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"TRANSPORTADORA "     ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. TOTAL FRETE "    ,1,1) // 09 I 			
	oExcel:AddColumn(cPlanilha,cTitulo,"Variável "           ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Debito ICMS "        ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Credito PIS/Cofins " ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Pedagio "            ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. ACRESCIMO "      ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. DECRESCIMO "     ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. TOTAL LIQ "      ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"PESO LIQUIDO "       ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"OCUP. LIQ. "         ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"R$/Ton (Liq) "       ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"PESO BRUTO "         ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"OCUP. BRUTO "        ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"KM ENT "             ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"ENTREGA "            ,1,1) // 23 W

RETURN(NIL)
