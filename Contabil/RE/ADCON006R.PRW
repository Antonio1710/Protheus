/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCON006R ºAutor  ³William COSTA       º Data ³  17/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de contabilidade CFOP X  Lançamento Contabil     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACON                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

User Function ADCON006R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatório de CFOP X  Lançamento Contabil"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADCON006R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este Programa de Ajustes de Cargas e enviar para o excel as alteracoes " )
	AADD(aSays,"Programa de Ajustes de Cargas" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||CONADCON006R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function CONADCON006R()    
  
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'CFOP_LANCAMENTO_CONTABIL.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'CFOP X  Lançamento Contabil'
    Public cTitulo     := 'CFOP X  Lançamento Contabil'
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
	   	               ""  ; // 13 M  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := TRB->FT_FILIAL                                              //A
		aLinhas[nLinha][02] := STOD(TRB->FT_EMISSAO)                                       //B
		aLinhas[nLinha][03] := STOD(TRB->FT_ENTRADA)                                       //C
		aLinhas[nLinha][04] := TRB->FT_CFOP                                                //D
		aLinhas[nLinha][05] := TRB->FT_CLIEFOR                                             //E
		aLinhas[nLinha][06] := TRB->FT_LOJA                                                //F
		aLinhas[nLinha][07] := TRB->FT_NFISCAL                                             //G
		aLinhas[nLinha][08] := TRB->FT_SERIE                                               //H
		aLinhas[nLinha][09] := TRB->FT_TOTAL                                               //I
		aLinhas[nLinha][10] := TRB->CT2_VALOR                                              //J
		aLinhas[nLinha][11] := TRB->CT2_DEBITO                                             //K
		aLinhas[nLinha][12] := TRB->CT2_CREDIT                                             //L
		aLinhas[nLinha][13] := IIF(ALLTRIM(TRB->CT2_DATA) == '', '',STOD(TRB->CT2_DATA))   //M
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
   	                	                 aLinhas[nExcel][13] ; // 13 M
                                                                  }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
    NEXT 
    //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

    Local cDataIni := DTOS(MV_PAR10)
    Local cDataFin := DTOS(MV_PAR11)    
    Local cTpMov   := IIF(MV_PAR03 == 1,'E','S')
    
    BeginSQL Alias "TRB"
			%NoPARSER%       
			SELECT SFT.FT_FILIAL,
			       SFT.FT_EMISSAO,
			       SFT.FT_ENTRADA,
			       SFT.FT_CFOP,
			       SFT.FT_CLIEFOR,
				   SFT.FT_LOJA,
				   SFT.FT_NFISCAL, 
				   SFT.FT_SERIE,
				   SFT.FT_TOTAL,
				   CT2.CT2_VALOR,
				   CT2.CT2_DEBITO,
			       CT2.CT2_CREDIT,
	   			   CT2.CT2_DATA
			 FROM %Table:SFT% SFT WITH(NOLOCK) 
			 LEFT JOIN %Table:CT2% CT2 WITH(NOLOCK) 
			        ON CT2.CT2_KEY = (SFT.FT_FILIAL+SFT.FT_NFISCAL+SFT.FT_SERIE+SFT.FT_CLIEFOR+SFT.FT_LOJA+SFT.FT_PRODUTO+SFT.FT_ITEM)
	               AND CT2.CT2_TIPODC = 'NF'
	               AND CT2.CT2_VALOR  = SFT.FT_TOTAL
	               AND CT2.D_E_L_E_T_ <> '*'
		      	 WHERE SFT.FT_FILIAL  >= %EXP:MV_PAR01%
			       AND SFT.FT_FILIAL  <= %EXP:MV_PAR02%
			       AND SFT.FT_TIPOMOV  = %EXP:cTpMov%
			       AND SFT.FT_CFOP    >= %EXP:MV_PAR04%
			       AND SFT.FT_CFOP    <= %EXP:MV_PAR05%
			       AND SFT.FT_SERIE   >= %EXP:MV_PAR06%
			       AND SFT.FT_SERIE   <= %EXP:MV_PAR07%
			       AND SFT.FT_NFISCAL >= %EXP:MV_PAR08%
			       AND SFT.FT_NFISCAL <= %EXP:MV_PAR09%
			       AND SFT.FT_EMISSAO >= %EXP:cDataIni%
			       AND SFT.FT_EMISSAO <= %EXP:cDataFin%
			       AND SFT.D_E_L_E_T_ <> '*'
			
			ORDER BY SFT.FT_CFOP,SFT.FT_NFISCAL
			
	EndSQl         
   

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\CFOP_LANCAMENTO_CONTABIL.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\CFOP_LANCAMENTO_CONTABIL.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial de           ?',                   '',                   '','MV_PAR01','C',02,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
    PutSx1(cPerg,'02','Filial Ate          ?',                   '',                   '','MV_PAR02','C',02,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Tipo Movimentação   ?','Tipo Movimentação ?','Tipo Movimentação ?','MV_PAR03','N',02,0,1,'C',    '', '',  '',  'S','MV_PAR03','ENTRADA','ENTRADA','ENTRADA','','SAIDA','SAIDA','SAIDA','','','','','','','','','','','','')    
	PutSx1(cPerg,'04','CFOP De             ?',                   '',                   '','MV_PAR04','C',04,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','CFOP Ate            ?',                   '',                   '','MV_PAR05','C',04,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Serie De            ?',                   '',                   '','MV_PAR06','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Serie Ate           ?',                   '',                   '','MV_PAR07','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Nota Fiscal De      ?',                   '',                   '','MV_PAR08','C',09,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR08')
	PutSx1(cPerg,'09','Nota Fiscal Ate     ?',                   '',                   '','MV_PAR09','C',09,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR09')
	PutSx1(cPerg,'10','Data Emissao NF De  ?',                   '',                   '','MV_PAR10','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR10')
	PutSx1(cPerg,'11','Data Emissao NF Ate ?',                   '',                   '','MV_PAR11','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR11')
	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "         ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"DT EMISSAO "     ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"DT ENTRADA "     ,1,1) // 03 C
    oExcel:AddColumn(cPlanilha,cTitulo,"CFOP "           ,1,1) // 04 D
  	oExcel:AddColumn(cPlanilha,cTitulo,"CLIENTE "        ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"LOJA "           ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"NOTA FISCAL "    ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"SERIE "          ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"TOTAL NOTA "     ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. LANCAMENTO " ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"CONTA DEBITO "   ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"CONTA CREDITO "  ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA CONTABIL "  ,1,1) // 13 M

	
RETURN(NIL)