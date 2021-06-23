#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG005R ºAutor  ³William COSTA       º Data ³  20/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO LOGISTICA - Controle de Devolucoes               º±±
±±º          ³ Relatorio em Excel.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG005R()
	
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
	Private cPerg		:= 'ADLOG005R'
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
	Public cArquivo    := 'Controle_Devolucao.XML'
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
			aLinhas[nLinha][23] := TRB->ZD_OBSERV          //W

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
			SELECT SZD.ZD_NUMNF,
			       SZD.ZD_SERIE,
			       SZD.ZD_CODCLI,
			       SZD.ZD_LOJA,
			       SZD.ZD_NOMECLI,
			       SZD.ZD_DEVTOT,
			       SZD.ZD_DTDEV,
			       SZD.ZD_AUTNOME,
			       SZD.ZD_RESPONS,
			       SZD.ZD_RESPNOM,
			       SZD.ZD_MOTIVO,
			       SZD.ZD_DESCMOT,
			       SZD.ZD_PEDIDO,
			       SZD.ZD_PLACA,
			       SZD.ZD_ROTEIRO,
			       SZD.ZD_SEQUENC,
			       SZD.ZD_VEND,
			       SA3.A3_NOME,
			       SA3.A3_EMAIL,
			       CASE WHEN SZD.ZD_DEVTOT = 'Q' THEN SUM(SZX.ZX_QUEBRA) ELSE CASE WHEN SZD.ZD_DEVTOT = 'P' THEN SUM((CASE WHEN SZX.ZX_QTDE = 0 THEN 1 ELSE SZX.ZX_QTDE END / CASE WHEN SZX.ZX_QTDEV2U = 0 THEN 1 ELSE SZX.ZX_QTDEV2U END) * ZX_QTDEV2U) ELSE SUM(SZX.ZX_QTDE)  END END AS QUANTIDADE,
			       SZX.ZX_UNIDADE,
			       CASE WHEN SZD.ZD_DEVTOT = 'P' THEN SUM(SZX.ZX_QTDEV2U) ELSE SUM(SZX.ZX_QTSEGUM) END AS SEGUNDA_QUANTIDADE,
			       CAST(CAST(ZD_OBSER AS VARBINARY(MAX)) AS VARCHAR(200)) AS ZD_OBSERV
			  FROM %Table:SZX% SZX, %Table:SZD% SZD
			  LEFT JOIN %Table:SA3% SA3
					ON SA3.A3_COD  = SZD.ZD_VEND 
				   AND SA3.D_E_L_E_T_ <> '*'
			 WHERE SZD.ZD_FILIAL   = %exp:xfilial("SZD")%
			   AND SZD.ZD_DTDEV   >= %exp:cDataIni%
			   AND SZD.ZD_DTDEV   <= %exp:cDataFin%
			   AND SZX.ZX_NF       = SZD.ZD_NUMNF
			   AND SZX.ZX_SERIE    = SZD.ZD_SERIE
			   AND SZX.D_E_L_E_T_ <> '*' 
			   AND SZD.D_E_L_E_T_ <> '*'
			   
			  GROUP BY SZD.ZD_NUMNF,
					   SZD.ZD_SERIE,
					   SZD.ZD_CODCLI,
					   SZD.ZD_LOJA,
					   SZD.ZD_NOMECLI,
					   SZD.ZD_DEVTOT,
					   SZD.ZD_DTDEV,
					   SZD.ZD_AUTNOME,
					   SZD.ZD_RESPONS,
					   SZD.ZD_RESPNOM,
					   SZD.ZD_MOTIVO,
					   SZD.ZD_DESCMOT,
					   SZD.ZD_PEDIDO,
					   SZD.ZD_PLACA,
					   SZD.ZD_ROTEIRO,
					   SZD.ZD_SEQUENC,
					   SZD.ZD_VEND,
					   SA3.A3_NOME,
					   SA3.A3_EMAIL,
					   SZX.ZX_UNIDADE,
					   CAST(CAST(ZD_OBSER AS VARBINARY(MAX)) AS VARCHAR(200))
					   
			ORDER BY SZD.ZD_NUMNF, SZD.ZD_SERIE		  
    EndSQl
   

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
	
    PutSx1(cPerg,'01','Data De  ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Data Ate ?','','','mv_ch2','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
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
    oExcel:AddColumn(cPlanilha,cTitulo,"Quantidade "      ,1,1) // 20 T
    oExcel:AddColumn(cPlanilha,cTitulo,"Unidade  "        ,1,1) // 21 U
  	oExcel:AddColumn(cPlanilha,cTitulo,"Seg Quantidade "  ,1,1) // 22 V
    oExcel:AddColumn(cPlanilha,cTitulo,"Observacao "      ,1,1) // 23 W
	
RETURN(NIL)