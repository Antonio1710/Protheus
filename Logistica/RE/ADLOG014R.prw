#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG014R ºAutor  ³William COSTA       º Data ³  12/02/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Faturamento Mensal Analitico, Nota por Nota   º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG014R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Faturamento Mensal Analitico, Nota por Nota')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Faturamento Mensal Analitico"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG014R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Controle de Fretes Analiticos" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog014R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog014R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_FAT_MEN_ANALITICO.XML'
	Public oMsExcel
	Public cPlanilha   := "Contr. Faturamento Analitico"
    Public cTitulo     := "Contr. Faturamento Analitico"
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

    Local nLinha      := 0
	Local nExcel      := 0  
	
	IF MV_PAR05  == 1
	
		SqlGeral() 
	
	ELSE    
	
		SqlGeral2()
	
	ENDIF	
	
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
		   	               ""  ; // 08 H   
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->D2_DOC           //A
			aLinhas[nLinha][02] := TRB->D2_QUANT         //B
			aLinhas[nLinha][03] := TRB->D2_QTDEDEV       //C
			aLinhas[nLinha][04] := TRB->D2_EST           //D
			aLinhas[nLinha][05] := TRB->C5_TPFRETE       //E
			aLinhas[nLinha][06] := STOD(TRB->D2_EMISSAO) //F
			aLinhas[nLinha][07] := STOD(TRB->C5_DTENTR)  //G 
			aLinhas[nLinha][08] := TRB->C5_EST           //H
			
			
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
		                                 aLinhas[nExcel][08] ; // 08 H
		                                                     }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT D2_DOC,
			       D2_QUANT,
				   D2_QTDEDEV,
				   D2_EST,
				   CASE WHEN C5_TPFRETE = 'C' THEN 'CIF' ELSE 'FOB' END AS C5_TPFRETE,
	               D2_EMISSAO,
	               C5_DTENTR,
	               C5_EST
			  FROM %Table:SD2% D2, %Table:SC5% C5 
			 WHERE D2.D2_EMISSAO BETWEEN %EXP:cDataIni% AND %EXP:cDataFin%
			   AND D2.D2_EST NOT IN ('EX')
			   AND D2.D2_TIPO     = 'N' 
			   AND D2.D2_GRUPO BETWEEN '0110' AND '0899'                 
			   AND D2.D2_COD NOT IN ('100096','100097','100098','391129')
			   AND (D2.D2_CF      = '6101'   
			    OR  D2.D2_CF      = '6105'   
			    OR  D2.D2_CF      = '6922'
			    OR  D2.D2_CF      = '6118'   
			    OR  D2.D2_CF      = '6122'   
			    OR  D2.D2_CF      = '6401' 
			    OR  D2.D2_CF      = '5101'   
			    OR  D2.D2_CF      = '5105'   
			    OR  D2.D2_CF      = '5922' 
			    OR  D2.D2_CF      = '5118'   
			    OR  D2.D2_CF      = '5122'   
			    OR  D2.D2_CF      = '5401') 
			   AND D2.D_E_L_E_T_ <> '*' 
			   AND D2.D2_FILIAL  >= %EXP:MV_PAR01%
			   AND C5.C5_FILIAL  <= %EXP:MV_PAR02%
			   AND C5.C5_NUM      = D2.D2_PEDIDO
			   
			  
			   ORDER BY C5_TPFRETE,D2_DOC
			 
	EndSQl
RETURN()    

Static Function SqlGeral2()

	Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04) 
     
    BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT D2_DOC,
			       D2_QUANT,
				   D2_QTDEDEV,
				   D2_EST,
				   CASE WHEN C5_TPFRETE = 'C' THEN 'CIF' ELSE 'FOB' END AS C5_TPFRETE,
	               D2_EMISSAO,
	               C5_DTENTR,
	               C5_EST
			  FROM %Table:SD2% D2, %Table:SC5% C5 
			 WHERE C5.C5_DTENTR BETWEEN %EXP:cDataIni% AND %EXP:cDataFin%
			   AND D2.D2_EST NOT IN ('EX')
			   AND D2.D2_TIPO     = 'N' 
			   AND D2.D2_GRUPO BETWEEN '0110' AND '0899'                 
			   AND D2.D2_COD NOT IN ('100096','100097','100098','391129')
			   AND (D2.D2_CF      = '6101'    
			    OR  D2.D2_CF      = '6105'   
			    OR  D2.D2_CF      = '6922'
			    OR  D2.D2_CF      = '6118'   
			    OR  D2.D2_CF      = '6122'   
			    OR  D2.D2_CF      = '6401' 
			    OR  D2.D2_CF      = '5101'   
			    OR  D2.D2_CF      = '5105'   
			    OR  D2.D2_CF      = '5922' 
			    OR  D2.D2_CF      = '5118'   
			    OR  D2.D2_CF      = '5122'   
			    OR  D2.D2_CF      = '5401') 
			   AND D2.D_E_L_E_T_ <> '*' 
			   AND D2.D2_FILIAL  >= %EXP:MV_PAR01%
			   AND C5.C5_FILIAL  <= %EXP:MV_PAR02%
			   AND C5.C5_NUM      = D2.D2_PEDIDO
			   
			  
			   ORDER BY C5_TPFRETE,D2_DOC
			 
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_FAT_MEN_ANALITICO.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_FAT_MEN_ANALITICO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De      ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate     ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR02')
    PutSx1(cPerg,'03','Data De        ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Ate       ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR04')
	PutSX1(cPerg,'05','Qual Tipo Data ?','','','mv_ch5','N',01,0,1,'C','','','','','MV_PAR05' ,'Emissao','','','','Entrega','Nao','Nao','','','','','','','','',' ')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"NR NOTA FISCAL " ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD "            ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD. DEVOLV. "   ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"EST-NF "         ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"TP FRETE "       ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"DT EMISSAO "     ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DT ENTREGA "     ,1,1) // 07 G 
	oExcel:AddColumn(cPlanilha,cTitulo,"EST-P.V "        ,1,1) // 08 H    //FOI NECESSARIO ESSE CAMPO, POIS EXISTE CLIENTE (NF) COM A RAZAO COM ESTADO  DIFERENTE DO ESTADO DA ENTREGA
	
	

RETURN(NIL)