#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*/{Protheus.doc} User Function ADLOG074R
    Relatório derivado do ADLOG005R para adição de custo na devolução.
    Chamado 11355
    @type  Function
    @author Leonardo P. Monteiro
    @since 01/04/2021
    @version 01
    @history Chamado 11355 - Leonardo P. Monteiro - 01/04/2021 - Desenvolvimento e adição do campo de custo.
	@history Chamado 11355 - Leonardo P. Monteiro - 09/04/2021 - a pedido da solicitante nós eliminamos a pergunta pernoite.
	@hhitory Ticket 73040 - Jonathan Carvalho - 03/06/2022 - Inclusão de descrição de Cod Prod e Desc Prod.
/*/

User Function ADLOG074R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO LOGISTICA - Controle de Devolucoes')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Controle de Devolucoes"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG074R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este Relatorio controle de devolucoes " )
	AADD(aSays,"Programa de Ajustes de Cargas" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERA_ADLOG005R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function GERA_ADLOG005R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11\protheus_data\system\'
	Public cArquivo    := 'Controle_Devolucao_valorizado.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Controle de Devoluções'
    Public cTitulo     := 'Controle de Devoluções'
    Public cCodProdSql := ''
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

    Private nLinha := 0
	Private nExcel := 0

    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		WHILE TRB->(!EOF()) 
		
			nLinha  := nLinha + 1                                       

            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho
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
							"" ;  // 26 Z
								})
			else
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
                           ""  ; // 24 X						  
                               })

			EndIf
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		    aLinhas[nLinha][01] := TRB->ZD_NUMNF           //A
			aLinhas[nLinha][02] := TRB->ZD_SERIE           //B
			aLinhas[nLinha][03] := TRB->ZD_CODCLI          //C
			aLinhas[nLinha][04] := TRB->ZD_LOJA            //D
			aLinhas[nLinha][05] := TRB->ZD_NOMECLI         //E
			aLinhas[nLinha][06] := TRB->ZD_DEVTOT          //F
			aLinhas[nLinha][07] := STOD(TRB->ZD_DTDEV)     //G
			aLinhas[nLinha][08] := TRB->ZD_AUTNOME         //H
			aLinhas[nLinha][09] := TRB->ZD_RESPONS         //I
			aLinhas[nLinha][10] := TRB->ZD_RESPNOM         //J
			aLinhas[nLinha][11] := TRB->ZD_MOTIVO          //K
			aLinhas[nLinha][12] := TRB->ZD_DESCMOT         //L
			aLinhas[nLinha][13] := TRB->ZD_PEDIDO          //M
			aLinhas[nLinha][14] := TRB->ZD_PLACA           //N
			aLinhas[nLinha][15] := TRB->ZD_ROTEIRO         //O
			aLinhas[nLinha][16] := TRB->ZD_SEQUENC         //P
			aLinhas[nLinha][17] := TRB->ZD_VEND            //Q
			aLinhas[nLinha][18] := TRB->A3_NOME            //R
			aLinhas[nLinha][19] := TRB->A3_EMAIL           //S
			aLinhas[nLinha][20] := TRB->QUANTIDADE         //T
			aLinhas[nLinha][21] := TRB->ZX_UNIDADE         //U
			aLinhas[nLinha][22] := TRB->SEGUNDA_QUANTIDADE //V
            aLinhas[nLinha][23] := TRB->ZX_TOTAL           //W
			aLinhas[nLinha][24] := TRB->ZD_OBSERV          //X

			If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho

				aLinhas[nLinha][25] := TRB->ZX_CODPROD //Y
				aLinhas[nLinha][26] := TRB->ZX_DESCRIC //Z

			EndIf
											

            //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha

			If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho
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
												aLinhas[nExcel][26];  // 26 Z 
																		})
			else
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
												aLinhas[nExcel][24]; // 24 X 
																	}) 
			EndIf	//GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
        NEXT 
	    //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

    Local cDataIni  := DTOS(MV_PAR01)
    Local cDataFin  := DTOS(MV_PAR02)
    Local cTipOcor  := ""
    //Local cPernoit  := ""
    Local cEOL      := Chr(13)+chr(10)
    
    if MV_PAR03 == 1
        cTipOcor := "('T')"
    elseif MV_PAR03 == 2
        cTipOcor := "('P')"
    elseif MV_PAR03 == 3
        cTipOcor := "('T','P')"
    endif
	/*
    if MV_PAR04 == 1
        cPernoit := "('T')"
    elseif MV_PAR04 == 2
        cPernoit := "('F')"
    elseif MV_PAR04 == 3
        cPernoit := "('F','T')"
    endif
	*/

	cQuery := " SELECT SZD.ZD_NUMNF, "+cEOL
	cQuery += "		       SZD.ZD_SERIE, "+cEOL
	cQuery += "			   SZD.ZD_CODCLI, "+cEOL
    cQuery += "				       SZD.ZD_LOJA, "+cEOL
	cQuery += "			       SZD.ZD_NOMECLI, "+cEOL
	cQuery += "			       SZD.ZD_DEVTOT, "+cEOL
	cQuery += "			       SZD.ZD_DTDEV, "+cEOL
	cQuery += "			       SZD.ZD_AUTNOME, "+cEOL
	cQuery += "			       SZD.ZD_RESPONS, "+cEOL
	cQuery += "			       SZD.ZD_RESPNOM, "+cEOL
	cQuery += "			       SZD.ZD_MOTIVO, "+cEOL
	cQuery += "			       SZD.ZD_DESCMOT, "+cEOL
	cQuery += "			       SZD.ZD_PEDIDO, "+cEOL
	cQuery += "			       SZD.ZD_PLACA, "+cEOL
	cQuery += "			       SZD.ZD_ROTEIRO, "+cEOL
	cQuery += "			       SZD.ZD_SEQUENC, "+cEOL
	cQuery += "			       SZD.ZD_VEND, "+cEOL
	cQuery += "			       SA3.A3_NOME, "+cEOL
	cQuery += "			       SA3.A3_EMAIL, "+cEOL
	cQuery += "			       CASE WHEN SZD.ZD_DEVTOT = 'Q' THEN SUM(SZX.ZX_QUEBRA) ELSE CASE WHEN SZD.ZD_DEVTOT = 'P' THEN SUM((CASE WHEN SZX.ZX_QTDE = 0 THEN 1 ELSE SZX.ZX_QTDE END / CASE WHEN SZX.ZX_QTDEV2U = 0 THEN 1 ELSE SZX.ZX_QTDEV2U END) * ZX_QTDEV2U) ELSE SUM(SZX.ZX_QTDE)  END END AS QUANTIDADE, "+cEOL
	cQuery += "			       SZX.ZX_UNIDADE, "+cEOL
	cQuery += "			       CASE WHEN SZD.ZD_DEVTOT = 'P' THEN SUM(SZX.ZX_QTDEV2U) ELSE SUM(SZX.ZX_QTSEGUM) END AS SEGUNDA_QUANTIDADE, "+cEOL
	cQuery += "			       CAST(CAST(ZD_OBSER AS VARBINARY(MAX)) AS VARCHAR(200)) AS ZD_OBSERV, "+cEOL
    cQuery += "	               SUM(CASE WHEN SZX.ZX_TOTAL = 0 THEN ROUND(SD2.D2_TOTAL/SZX.ZX_QTDEV1U,2) ELSE SZX.ZX_TOTAL END) ZX_TOTAL "+cEOL
	
	If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho

		cQuery += ",SZX.ZX_CODPROD, SZX.ZX_DESCRIC "+cEOL

	ENDIF

	cQuery += "			  FROM "+ RetSqlName("SZX") +" (NOLOCK) SZX "+cEOL
    cQuery += "			    INNER JOIN "+ RetSqlName("SZD") +" (NOLOCK) SZD ON SZX.ZX_FILIAL=SZD.ZD_FILIAL AND SZX.ZX_NF=SZD.ZD_NUMNF AND SZX.ZX_SERIE    = SZD.ZD_SERIE "+cEOL
    cQuery += "			    LEFT  JOIN "+ RetSqlName("SA3") +" (NOLOCK) SA3 ON SA3.A3_COD  = SZD.ZD_VEND AND SA3.D_E_L_E_T_ <> '*' "+cEOL
    cQuery += "	            LEFT  JOIN "+ RetSqlName("SD2") +" (NOLOCK) SD2 ON SD2.D2_FILIAL=SZX.ZX_FILIAL AND SD2.D2_DOC=SZX.ZX_NF AND SD2.D2_SERIE=SZX.ZX_SERIE AND SD2.D2_ITEM=SZX.ZX_ITEMNF AND SD2.D_E_L_E_T_ <> '*' "+cEOL
	cQuery += "			 WHERE SZD.ZD_FILIAL   = '"+xfilial("SZD")+"' "+cEOL
	cQuery += "			   AND SZD.ZD_DTDEV   >= '"+cDataIni+"'"+cEOL
	cQuery += "			   AND SZD.ZD_DTDEV   <= '"+cDataFin+"' "+cEOL
    cQuery += "	           AND SZD.ZD_DEVTOT  IN  "+cTipOcor+" "+cEOL
	//cQuery += "			   AND SZD.ZD_PERNOIT IN  "+cPernoit+" "+cEOL
	cQuery += "			   AND SZX.ZX_NF       = SZD.ZD_NUMNF "+cEOL
	cQuery += "			   AND SZX.ZX_SERIE    = SZD.ZD_SERIE "+cEOL
	cQuery += "			   AND SZX.D_E_L_E_T_ <> '*'  "+cEOL
	cQuery += "			   AND SZD.D_E_L_E_T_ <> '*' "+cEOL
	cQuery += "			  GROUP BY SZD.ZD_NUMNF, "+cEOL
	cQuery += "					   SZD.ZD_SERIE, "+cEOL
	cQuery += "					   SZD.ZD_CODCLI, "+cEOL
	cQuery += "					   SZD.ZD_LOJA, "+cEOL
	cQuery += "					   SZD.ZD_NOMECLI, "+cEOL
	cQuery += "					   SZD.ZD_DEVTOT, "+cEOL
	cQuery += "					   SZD.ZD_DTDEV, "+cEOL
	cQuery += "					   SZD.ZD_AUTNOME, "+cEOL
	cQuery += "					   SZD.ZD_RESPONS, "+cEOL
	cQuery += "					   SZD.ZD_RESPNOM, "+cEOL
	cQuery += "					   SZD.ZD_MOTIVO, "+cEOL
	cQuery += "					   SZD.ZD_DESCMOT, "+cEOL
	cQuery += "					   SZD.ZD_PEDIDO, "+cEOL
	cQuery += "					   SZD.ZD_PLACA, "+cEOL
	cQuery += "					   SZD.ZD_ROTEIRO, "+cEOL
	cQuery += "					   SZD.ZD_SEQUENC, "+cEOL
	cQuery += "					   SZD.ZD_VEND, "+cEOL
	cQuery += "					   SA3.A3_NOME, "+cEOL
	cQuery += "					   SA3.A3_EMAIL, "+cEOL
	cQuery += "					   SZX.ZX_UNIDADE, "+cEOL
	cQuery += "					   CAST(CAST(ZD_OBSER AS VARBINARY(MAX)) AS VARCHAR(200)) "+cEOL
	
	If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho

		cQuery += "			       ,SZX.ZX_CODPROD, SZX.ZX_DESCRIC  "+cEOL

	ENDIF

	cQuery += "			ORDER BY SZD.ZD_NUMNF, SZD.ZD_SERIE		   "
    
    TcQuery cQuery ALIAS "TRB" NEW

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\Controle_Devolucao.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\Controle_Devolucao.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Data De  ?'          ,'','','mv_ch1','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Data Ate ?'          ,'','','mv_ch2','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
    PutSX1(cPerg,"03","Tp. Ocorrência?"     ,"","","mv_ch3","N",01,0,1,"C",bValid,cF3,cSXG,cPyme,"mv_par03", "Total","","","","Parcial","","","Todos","","","","","","","","",,,)
    PutSX1(cPerg,"04","Pernoite?"           ,"","","mv_ch4","N",01,0,1,"C",bValid,cF3,cSXG,cPyme,"MV_par04", "Sim","","","","Não","","","Todos","","","","","","","","",,,)
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Numero NF "       ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Serie NF "        ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Cli  "        ,1,1) // 03 C
  	oExcel:AddColumn(cPlanilha,cTitulo,"Loja "            ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome do Cliente " ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Ocorr "      ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Data Devolucao "  ,1,1) // 07 G
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Autoriz "    ,1,1) // 08 H
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Resp  "       ,1,1) // 09 I
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Resp "       ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Motivo "      ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc Motivo "     ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Pedido "      ,1,1) // 13 M
    oExcel:AddColumn(cPlanilha,cTitulo,"Placa "           ,1,1) // 14 N
    oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro  "        ,1,1) // 15 O
  	oExcel:AddColumn(cPlanilha,cTitulo,"Sequencia "       ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Vendedor "    ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Vendedor "   ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"Email Vendedor "  ,1,1) // 19 S
    oExcel:AddColumn(cPlanilha,cTitulo,"Quantidade "      ,3,2) // 20 T
    oExcel:AddColumn(cPlanilha,cTitulo,"Unidade  "        ,1,1) // 21 U
  	oExcel:AddColumn(cPlanilha,cTitulo,"Seg Quantidade "  ,3,3) // 22 V
    oExcel:AddColumn(cPlanilha,cTitulo,"Vlr Total (R$) "  ,3,3) // 23 W
    oExcel:AddColumn(cPlanilha,cTitulo,"Observacao "      ,1,1) // 24 X

	If MV_PAR04 == 1 //Tkt 73040 - Jonathan.Carvalho

		oExcel:AddColumn(cPlanilha,cTitulo,"Cod Prod "      ,1,1) //25 Y
		oExcel:AddColumn(cPlanilha,cTitulo,"Desc Prod "     ,1,1) //26 Z
	
	EndIf
	
RETURN(NIL)
