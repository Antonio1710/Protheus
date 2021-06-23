#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEST039R ºAutor  ³William COSTA       º Data ³  05/12/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio que mostra todos os saldos do produto e cadastro º±±
±±ºDesc.     ³na SBZ localizacoes e saldos de enderecamento               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEST                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracao ³ 046431 || OS 047658 || CONTROLADORIA || DANIELLE_MEIRA     º±±
±±º          ³ 8459 || DIF. SB2 X SBF.SIGAEST - Erro Local 03 acertado    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlteracao ³ 048038 WILLIAM COSTA 26/03/2019 - Adicionado campo de saldoº±±
±±º          ³ de ponto de pedido para verificar valor correto B2_SALPEDI º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADEST039R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio que mostra todos os saldos do produto e cadastro na SBZ localizacoes e saldos de enderecamento')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Saldos de Produto e Enderecos"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEST039R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Saldos de Produto e Enderecos" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADEST039R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         
Static Function LogADEST039R()  
  
	PRIVATE oExcel      := FWMSEXCEL():New()
	PRIVATE cPath       := ''
	PRIVATE cArquivo    := 'REL_SALDOS_PRODUTOS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Contr. Saldos"
    PRIVATE cTitulo     := "Contr. Saldos"
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
	
	// *** INICIO WILLIAM COSTA 14/01/2019 CHAMADO - 046431 || OS 047658 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || DIF. SB2 X SBF. *** //     
	IF ALLTRIM(MV_PAR04) == '03'
	
		SqlGeral2()
		
	ELSE
	
		SqlGeral1()
		
	ENDIF
	
	// *** FINAL WILLIAM COSTA 14/01/2019 CHAMADO - 046431 || OS 047658 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || DIF. SB2 X SBF. *** //	 
	
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
		   	               ""  ; // 17 Q
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->B1_COD                                                  //A
			aLinhas[nLinha][02] := TRB->B1_DESC                                                 //B
			aLinhas[nLinha][03] := TRB->B1_LOCALIZ                                              //C
			aLinhas[nLinha][04] := TRB->BZ_LOCALIZ                                              //D
			aLinhas[nLinha][05] := TRB->BZ_COD                                                  //E
			aLinhas[nLinha][06] := TRB->B1_CODBAR                                               //F
			aLinhas[nLinha][07] := TRB->B2_QATU                                                 //G
			aLinhas[nLinha][08] := TRB->B2_QACLASS                                              //H
			aLinhas[nLinha][09] := TRB->B2_QEMPSA                                               //I
			aLinhas[nLinha][10] := TRB->B2_RESERVA                                              //J
			aLinhas[nLinha][11] := TRB->B2_QEMP                                                 //K
			aLinhas[nLinha][12] := IIF(ALLTRIM(TRB->B2_DINVENT) == '','',STOD(TRB->B2_DINVENT)) //L
			aLinhas[nLinha][13] := TRB->BE_LOCALIZ                                              //M
			aLinhas[nLinha][14] := IIF(ALLTRIM(TRB->BE_DTINV) == '','',STOD(TRB->BE_DTINV))     //N
			aLinhas[nLinha][15] := TRB->BF_LOCALIZ                                              //O
			aLinhas[nLinha][16] := TRB->BF_QUANT                                                //P
			aLinhas[nLinha][17] := TRB->B2_SALPEDI                                              //Q //048038 WILLIAM COSTA 26/03/2019
			
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
		                                 aLinhas[nExcel][17] ; // 17 Q
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral1()

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT B1_COD,
			       B1_DESC,
			       B1_LOCALIZ,
			       BZ_LOCALIZ,
			       BZ_COD,
			       B1_CODBAR,
			       B2_QATU,
			       B2_QACLASS,
			       B2_QEMPSA,
			       B2_RESERVA,
			       B2_QEMP,
			       B2_DINVENT,
			       B2_SALPEDI, 
			       BE_LOCALIZ,
			       BE_DTINV, 
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %TABLE:SB2% WITH(NOLOCK),%TABLE:SB1% WITH(NOLOCK)
			 LEFT JOIN %TABLE:SBE% WITH(NOLOCK)
			         ON BE_FILIAL               = %EXP:MV_PAR01%           
			        AND BE_CODPRO               = B1_COD
					AND BE_LOCAL                = %EXP:MV_PAR04%
			        AND %TABLE:SBE%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBF% WITH(NOLOCK)
			         ON BF_FILIAL               = %EXP:MV_PAR01% 
			        AND BF_LOCALIZ              = BE_LOCALIZ 
			        AND %TABLE:SBF%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBZ% WITH(NOLOCK)
			         ON BZ_FILIAL               = %EXP:MV_PAR01%
					AND BZ_COD                  = B1_COD
			        AND %TABLE:SBZ%.D_E_L_E_T_ <> '*' 
			     WHERE B2_FILIAL                = %EXP:MV_PAR01%
			       AND B2_COD                  >= %EXP:MV_PAR02%
			       AND B2_COD                  <= %EXP:MV_PAR03%
			       AND B2_LOCAL                 = %EXP:MV_PAR04%
			       AND %TABLE:SB2%.D_E_L_E_T_  <> '*'
			       AND B1_COD                   = B2_COD
			       AND B1_MSBLQL                = '2'
			       AND %TABLE:SB1%.D_E_L_E_T_  <> '*'
			
			ORDER BY SB1010.B1_COD
						  
	EndSQl
RETURN()    

Static Function SqlGeral2()

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT B1_COD,
			       B1_DESC,
			       B1_LOCALIZ,
			       BZ_LOCALIZ,
			       BZ_COD,
			       B1_CODBAR,
			       B2_QATU,
			       B2_QACLASS,
			       B2_QEMPSA,
			       B2_RESERVA,
			       B2_QEMP,
			       B2_DINVENT,
			       B2_SALPEDI, 
			       BE_LOCALIZ,
			       BE_DTINV, 
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %TABLE:SB2% WITH(NOLOCK),%TABLE:SB1% WITH(NOLOCK)
			 LEFT JOIN %TABLE:SBE% WITH(NOLOCK)
			         ON BE_FILIAL               = %EXP:MV_PAR01%           
			        AND BE_LOCALIZ              = 'PROD'
					AND BE_LOCAL                = %EXP:MV_PAR04%
			        AND %TABLE:SBE%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBF% WITH(NOLOCK)
			         ON BF_FILIAL               = %EXP:MV_PAR01% 
			        AND BF_LOCALIZ              = BE_LOCALIZ 
			        AND BF_PRODUTO              = B1_COD
			        AND %TABLE:SBF%.D_E_L_E_T_ <> '*' 
			   LEFT JOIN %TABLE:SBZ% WITH(NOLOCK)
			         ON BZ_FILIAL               = %EXP:MV_PAR01%
					AND BZ_COD                  = B1_COD
			        AND %TABLE:SBZ%.D_E_L_E_T_ <> '*' 
			     WHERE B2_FILIAL                = %EXP:MV_PAR01%
			       AND B2_COD                  >= %EXP:MV_PAR02%
			       AND B2_COD                  <= %EXP:MV_PAR03%
			       AND B2_LOCAL                 = %EXP:MV_PAR04%
			       AND %TABLE:SB2%.D_E_L_E_T_  <> '*'
			       AND B1_COD                   = B2_COD
			       AND B1_MSBLQL                = '2'
			       AND %TABLE:SB1%.D_E_L_E_T_  <> '*'
			
			ORDER BY SB1010.B1_COD
						  
	EndSQl
RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile('C:\temp\' + cArquivo)

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open('C:\temp\' + cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()
                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    u_xPutSx1(cPerg,'01','Filial Prod  ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	u_xPutSx1(cPerg,'02','Cod Prod Ini ?','','','mv_ch2','C',15,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
	u_xPutSx1(cPerg,'03','Cod Prod Fin ?','','','mv_ch3','C',15,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	u_xPutSx1(cPerg,'04','Local        ?','','','mv_ch4','C',06,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"B1_COD "     ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"B1_DESC "    ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"B1_LOCALIZ " ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"BZ_LOCALIZ " ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"BZ_COD "     ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"B1_CODBAR "  ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_QATU "    ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_QACLASS " ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_QEMPSA "  ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_RESERVA " ,1,1) // 10 J			
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_QEMP "    ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_DINVENT " ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"BE_LOCALIZ " ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"BE_DINVENT " ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"BF_LOCALIZ " ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"BF_QUANT "   ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"B2_SALPEDI"  ,1,1) // 17 Q //048038 WILLIAM COSTA 26/03/2019
	
RETURN(NIL)