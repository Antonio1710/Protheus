#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*/{Protheus.doc} User Function ADLOG008R
	(Relatorio de Horários de Aprovações por alçcada dos pedidos de Venda)
	@type  Function
	@author William COSTA
	@since 08/03/2015
	@version 01
	@history Chamado: 054367 - Adriano Savoine - 06/01/2020 - Alterada a query da consulta para aumentar o desempenho na geração do relatorio.
	/*/

User Function ADLOG008R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Horários de Aprovações por alçcada dos pedidos de Venda')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Horários de Aprovações por alçada dos pedidos de Venda"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG008R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Horários de Aprovações por alçada dos pedidos de Venda" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog004R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog004R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_HORA_ALCADAS.XML'
	Public oMsExcel
	Public cPlanilha   := "Aprovação Alçadas"
    Public cTitulo     := "Horário Aprovação Alçadas"
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
	Local nTotReg	  := 0
	Local cNumPV      := ''
	
	SqlGeral()
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
    DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		WHILE TRB->(!EOF())
		
			cNumPV := Alltrim(cValToChar(TRB->C5_NUM ))
	        IncProc("Processando Ped. Venda. " + cNumPV)  
		
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
		   	               "", ; // 23 W   
		   	               "", ; // 24 X   
		   	               "", ; // 25 Y   
		   	               "", ; // 26 Z   
		   	               "", ; // 27 AA   
		   	               "", ; // 28 AB   
		   	               "", ; // 29 AC   
		   	               "", ; // 30 AD   
		   	               "", ; // 31 AE   
		   	               "", ; // 32 AF   
		   	               ""  ; // 33 AG  
		   	                  })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->C5_FILIAL                                                //A
			aLinhas[nLinha][02] := TRB->C5_NUM                                                   //B
			aLinhas[nLinha][03] := TRB->C5_ROTEIRO                                               //C
			aLinhas[nLinha][04] := TRB->C5_PLACA                                                 //D
			aLinhas[nLinha][05] := IIF(ALLTRIM(TRB->C5_DTENTR) <> '',STOD(TRB->C5_DTENTR), '')   //E
			aLinhas[nLinha][06] := TRB->C5_PRIOR                                                 //F
			aLinhas[nLinha][07] := IIF(ALLTRIM(TRB->C5_EMISSAO) <> '',STOD(TRB->C5_EMISSAO), '') //G
			aLinhas[nLinha][08] := TRB->C5_HRINCLU                                               //H
			aLinhas[nLinha][09] := TRB->ANALISTAREDE                                             //I
			aLinhas[nLinha][10] := TRB->C5_HRBLOQ                                                //J
			aLinhas[nLinha][11] := TRB->C5_APROV1                                                //K
			aLinhas[nLinha][12] := UsrRetName(TRB->C5_APROV1)                                    //L
			aLinhas[nLinha][13] := IIF(ALLTRIM(TRB->C5_DTLIB1) <> '',STOD(TRB->C5_DTLIB1), '')   //M
			aLinhas[nLinha][14] := TRB->C5_HRLIB1                                                //N
			aLinhas[nLinha][15] := TRB->C5_APROV2                                                //O
			aLinhas[nLinha][16] := UsrRetName(TRB->C5_APROV2)                                    //P
			aLinhas[nLinha][17] := IIF(ALLTRIM(TRB->C5_DTLIB2) <> '',STOD(TRB->C5_DTLIB2), '')   //Q
			aLinhas[nLinha][18] := TRB->C5_HRLIB2                                                //R
			aLinhas[nLinha][19] := TRB->C5_APROV3                                                //S
			aLinhas[nLinha][20] := UsrRetName(TRB->C5_APROV3)                                    //T
			aLinhas[nLinha][21] := IIF(ALLTRIM(TRB->C5_DTLIB3) <> '',STOD(TRB->C5_DTLIB3), '')   //U
			aLinhas[nLinha][22] := TRB->C5_HRLIB3                                                //V
			aLinhas[nLinha][23] := TRB->C6_LOGCORT                                               //W
			aLinhas[nLinha][24] := TRB->ZBE_USUARI                                               //X
			aLinhas[nLinha][25] := IIF(ALLTRIM(TRB->ZBE_DATA) <> '',STOD(TRB->ZBE_DATA), '')     //Y
			aLinhas[nLinha][26] := TRB->ZBE_HORA                                                 //Z
			aLinhas[nLinha][27] := TRB->ZBE_LOG                                                  //AA
			aLinhas[nLinha][28] := TRB->ZBE_USER1                                                 //AB
			aLinhas[nLinha][29] := IIF(ALLTRIM(TRB->ZBE_DATA1) <> '',STOD(TRB->ZBE_DATA1), '')     //AC
			aLinhas[nLinha][30] := TRB->ZBE_HORA1                                                //AD
			aLinhas[nLinha][31] := TRB->F2_DOC                                                   //AE
			aLinhas[nLinha][32] := IIF(ALLTRIM(TRB->F2_EMISSAO) <> '',STOD(TRB->F2_EMISSAO), '') //AF
			aLinhas[nLinha][33] := TRB->F2_HORA                                                  //AG
			                                  
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
		                                 aLinhas[nExcel][23],; // 23 W 
		                                 aLinhas[nExcel][24],; // 24 X  
		                                 aLinhas[nExcel][25],; // 25 Y  
		                                 aLinhas[nExcel][26],; // 26 Z  
		                                 aLinhas[nExcel][27],; // 27 AA  
		                                 aLinhas[nExcel][28],; // 28 AB  
		                                 aLinhas[nExcel][29],; // 29 AC  
		                                 aLinhas[nExcel][30],; // 30 AC  
		                                 aLinhas[nExcel][31],; // 31 AD  
		                                 aLinhas[nExcel][32],; // 32 AE  
		                                 aLinhas[nExcel][33] ; // 33 AF 
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER%
			 SELECT SC5.C5_FILIAL, 
					SC5.C5_NUM,
					SC5.C5_ROTEIRO,
					SC5.C5_PLACA,
					SC5.C5_DTENTR,
					SC5.C5_PRIOR,
					SC5.C5_EMISSAO,
					SC5.C5_HRINCLU,
					'VAGNER/ THAINA' AS ANALISTAREDE,
					SC5.C5_HRBLOQ,
					SC5.C5_APROV1,
					SC5.C5_DTLIB1,
					SC5.C5_HRLIB1,
					SC5.C5_APROV2,
					SC5.C5_DTLIB2,
					SC5.C5_HRLIB2,
					SC5.C5_APROV3,
					SC5.C5_DTLIB3,
					SC5.C5_HRLIB3,
					(SELECT TOP(1) RTRIM(C6_PRODUTO) + ' / ' + RTRIM(C6_LOGCORT) FROM %Table:SC6% WITH(NOLOCK) WHERE C6_FILIAL   = SC5.C5_FILIAL AND C6_NUM      = SC5.C5_NUM  AND C6_LOGCORT <> ''  AND D_E_L_E_T_ <> '*') AS C6_LOGCORT,
					(SELECT TOP(1) ZBE_USUARI FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'SC5' AND SUBSTRING(ZBE_LOG,8,6) = SC5.C5_NUM  AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS ZBE_USUARI, //CHAMADO:054367 ADRIANO SAVOINE 06/01/2020
					(SELECT TOP(1) ZBE_DATA   FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'SC5' AND SUBSTRING(ZBE_LOG,8,6) = SC5.C5_NUM  AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS ZBE_DATA,  //CHAMADO:054367 ADRIANO SAVOINE  06/01/2020
					(SELECT TOP(1) ZBE_HORA   FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'SC5' AND SUBSTRING(ZBE_LOG,8,6) = SC5.C5_NUM  AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS ZBE_HORA,  //CHAMADO:054367 ADRIANO SAVOINE  06/01/2020
					(SELECT TOP(1) ZBE_LOG    FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'SC5' AND SUBSTRING(ZBE_LOG,8,6) = SC5.C5_NUM  AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS ZBE_LOG,   //CHAMADO:054367 ADRIANO SAVOINE  06/01/2020
					// INICIO CARREGA VALOR ERRADO DE LOG PARA O RELATORIO SEM VERIFICAR O PEDIDO SOMENTE O DATA DE ENTREGA E PLACA -- CHAMADO 039617 WILLIAM COSTA
					//(SELECT TOP(1) ZZ6_USER FROM %Table:ZZ6%  WITH(NOLOCK) WHERE ZZ6_FILIAL = SC5.C5_FILIAL AND ZZ6_CHAVE = SC5.C5_DTENTR + SC5.C5_ROTEIRO + SC5.C5_PLACA AND ZZ6_OPER = '3' AND D_E_L_E_T_ <> '*' ORDER BY ZZ6_DATA DESC,ZZ6_HORA DESC) AS ZZ6_USER,
					//(SELECT TOP(1) ZZ6_DATA FROM %Table:ZZ6%  WITH(NOLOCK) WHERE ZZ6_FILIAL = SC5.C5_FILIAL AND ZZ6_CHAVE = SC5.C5_DTENTR + SC5.C5_ROTEIRO + SC5.C5_PLACA AND ZZ6_OPER = '3' AND D_E_L_E_T_ <> '*' ORDER BY ZZ6_DATA DESC,ZZ6_HORA DESC) AS ZZ6_DATA,
					//(SELECT TOP(1) ZZ6_HORA FROM %Table:ZZ6%  WITH(NOLOCK) WHERE ZZ6_FILIAL = SC5.C5_FILIAL AND ZZ6_CHAVE = SC5.C5_DTENTR + SC5.C5_ROTEIRO + SC5.C5_PLACA AND ZZ6_OPER = '3' AND D_E_L_E_T_ <> '*' ORDER BY ZZ6_DATA DESC,ZZ6_HORA DESC) AS ZZ6_HORA,
					(SELECT TOP(1) ZBE_USUARI FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'LOGISTICA' AND ZBE_LOG = 'INTEGRACAO CARGA EDATA' AND ZBE_ROTINA = 'CCS_001P' AND ZBE_PARAME LIKE '%' + SC5.C5_NUM + '%' AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS  ZBE_USER1,
					(SELECT TOP(1) ZBE_DATA   FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'LOGISTICA' AND ZBE_LOG = 'INTEGRACAO CARGA EDATA' AND ZBE_ROTINA = 'CCS_001P' AND ZBE_PARAME LIKE '%' + SC5.C5_NUM + '%' AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS  ZBE_DATA1,
					(SELECT TOP(1) ZBE_HORA   FROM %Table:ZBE% WITH(NOLOCK) WHERE ZBE_FILIAL = SC5.C5_FILIAL AND ZBE_MODULO = 'LOGISTICA' AND ZBE_LOG = 'INTEGRACAO CARGA EDATA' AND ZBE_ROTINA = 'CCS_001P' AND ZBE_PARAME LIKE '%' + SC5.C5_NUM + '%' AND D_E_L_E_T_ <> '*' AND ZBE_DATA >= SC5.C5_X_DATA ORDER BY ZBE_DATA DESC,ZBE_HORA DESC) AS  ZBE_HORA1,
					// FINAL CARREGA VALOR ERRADO DE LOG PARA O RELATORIO SEM VERIFICAR O PEDIDO SOMENTE O DATA DE ENTREGA E PLACA -- CHAMADO 039617 WILLIAM COSTA
					SF2.F2_DOC,
					SF2.F2_EMISSAO,
					SF2.F2_HORA
				FROM %Table:SC5% SC5 WITH(NOLOCK)
				LEFT JOIN %Table:SC9% SC9 WITH(NOLOCK)
				ON SC9.C9_FILIAL      = SC5.C5_FILIAL
				AND SC9.C9_PEDIDO     = SC5.C5_NUM
				AND SC9.D_E_L_E_T_   <> '*'
				LEFT JOIN %Table:SF2% SF2 WITH(NOLOCK)
				ON SF2.F2_DOC         = SC5.C5_NOTA
				AND SF2.F2_SERIE      = SC5.C5_SERIE
				AND SF2.D_E_L_E_T_   <> '*' 
				WHERE SC5.C5_FILIAL  >= %exp:MV_PAR01%
				  AND SC5.C5_FILIAL  <= %exp:MV_PAR02%
			      AND SC5.C5_DTENTR  >= %exp:cDataIni%
			      AND SC5.C5_DTENTR  <= %exp:cDataFin%
			      AND SC5.C5_NUM     >= %exp:MV_PAR05%
			      AND SC5.C5_NUM     <= %exp:MV_PAR06%
			      AND SC5.D_E_L_E_T_ <> '*'
						   
			   GROUP BY SC5.C5_FILIAL, 
						SC5.C5_NUM,
						SC5.C5_ROTEIRO,
					    SC5.C5_PLACA,
						SC5.C5_DTENTR,
						SC5.C5_PRIOR,
						SC5.C5_EMISSAO,
						SC5.C5_HRINCLU,
						SC5.C5_HRBLOQ,
						SC5.C5_APROV1,
						SC5.C5_DTLIB1,
						SC5.C5_HRLIB1,
						SC5.C5_APROV2,
						SC5.C5_DTLIB2,
						SC5.C5_HRLIB2,
						SC5.C5_APROV3,
						SC5.C5_DTLIB3,
						SC5.C5_HRLIB3,
						SC5.C5_X_DATA,
						SC9.C9_XNOMAPR,
						SC9.C9_DATALIB,
						SC9.C9_XHRAPRO,
						SF2.F2_DOC,
						SF2.F2_EMISSAO,
						SF2.F2_HORA
												
				ORDER BY SC5.C5_NUM			
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_HORA_ALCADAS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_HORA_ALCADAS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De        ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate       ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Entrega De  ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Entrega Ate ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Num Pedido de    ?','','','mv_ch5','C',06,0,0,'G',bValid,'SC5' ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Num Pedido Ate   ?','','','mv_ch6','C',06,0,0,'G',bValid,'SC5' ,cSXG,cPyme,'MV_PAR06')

	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "               ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM. PEDIDO "          ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"ROTEIRO "              ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"PLACA "                ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA ENTREGA "         ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PRIORIDADE "           ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA EMISSAO "         ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"HORA INCLUSÃO PED "    ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"ANALISTA DE REDE "     ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"HORARIO BLOQUEIO "     ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"COD. APROV. 1 "        ,1,1) // 11 K 			
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME APROV. 1 "        ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. LIB. APROV. 1 "    ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. LIB. APROV. 1 "    ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"COD. APROV. 2 "        ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME APROV. 2 "        ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. LIB. APROV. 2 "    ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. LIB. APROV. 2 "    ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"COD. APROV. 3 "        ,1,1) // 19 S 			
	oExcel:AddColumn(cPlanilha,cTitulo,"NOME APROV. 3 "        ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. LIB. APROV. 3 "    ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. LIB. APROV. 3 "    ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"LOG CORTE PEDIDO "     ,1,1) // 23 W
	oExcel:AddColumn(cPlanilha,cTitulo,"APROVADOR FINANCEIRO " ,1,1) // 24 X
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. LIB. FINANCEIRO "  ,1,1) // 25 Y
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. LIB. FINANCEIRO "  ,1,1) // 26 Z
	oExcel:AddColumn(cPlanilha,cTitulo,"LOG FINANCEIRO "       ,1,1) // 27 AA
	oExcel:AddColumn(cPlanilha,cTitulo,"USUARIO ENVIO EDATA "  ,1,1) // 28 AB
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. ENVIO EDATA "      ,1,1) // 29 AC
	oExcel:AddColumn(cPlanilha,cTitulo,"HR. ENVIO EDATA "      ,1,1) // 30 AD
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM. NOTA "            ,1,1) // 31 AE
	oExcel:AddColumn(cPlanilha,cTitulo,"DT. EMISSAO NOTA "     ,1,1) // 32 AF
	oExcel:AddColumn(cPlanilha,cTitulo,"HORA EMISSAO NOTA "    ,1,1) // 33 AG
		
RETURN(NIL)