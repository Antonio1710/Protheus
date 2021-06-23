#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG009R ºAutor  ³William COSTA       º Data ³  01/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Valores de Fretes para a Logistica            º±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG009R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Valores de Fretes para a Logistica')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio de Valores de Fretes"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG009R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Valores de Fretes" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogAdLog004R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LogAdLog004R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_VAL_FRETE.XML'
	Public oMsExcel
	Public cPlanilha   := "Valores Frete"
    Public cTitulo     := "Valores Frete"
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
		   	               ""  ; // 08 H  
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->C5_FILIAL                                              //A
			aLinhas[nLinha][02] := IIF(ALLTRIM(TRB->C5_DTENTR) <> '',STOD(TRB->C5_DTENTR), '') //B
			aLinhas[nLinha][03] := TRB->C5_ROTEIRO                                             //C
			aLinhas[nLinha][04] := TRB->C5_SEQUENC                                             //D
			aLinhas[nLinha][05] := TRB->C5_NUM                                                 //E
			aLinhas[nLinha][06] := TRB->C5_PLACA                                               //F
			aLinhas[nLinha][07] := TRB->C5_XTOTPED                                             //G
			aLinhas[nLinha][08] := TRB->ZK_VALFRET                                             //H
			
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
			SELECT SC5.C5_FILIAL,
			       SC5.C5_DTENTR,
			       SC5.C5_ROTEIRO,
			       SC5.C5_SEQUENC,
			       SC5.C5_NUM,
			       SC5.C5_PLACA,
			       SC5.C5_XTOTPED,
			       SZK.ZK_VALFRET
			  FROM %Table:SC5% SC5, %Table:SZK% SZK
			  WHERE SC5.C5_FILIAL  >= %EXP:MV_PAR01%
			    AND SC5.C5_FILIAL  <= %EXP:MV_PAR02%
			    AND SC5.C5_DTENTR  >= %EXP:cDataIni%
			    AND SC5.C5_DTENTR  <= %EXP:cDataFin%
			    AND SC5.C5_PLACA   >= ''
			    AND SC5.C5_ROTEIRO >= %EXP:MV_PAR05%
			    AND SC5.C5_ROTEIRO <= %EXP:MV_PAR06%
			    AND SC5.C5_SEQUENC >= %EXP:MV_PAR07%
			    AND SC5.C5_SEQUENC <= %EXP:MV_PAR08%
			    AND SC5.C5_NOTA    <> '' 
			    AND SC5.C5_SERIE   <> ''
			    AND SZK.ZK_PLACA    = SC5.C5_PLACA
			    AND SZK.ZK_DTENTR   = SC5.C5_DTENTR
			    AND SZK.ZK_ROTEIRO  = SC5.C5_ROTEIRO
			    AND SZK.D_E_L_E_T_ <> '*'
			    AND SC5.D_E_L_E_T_ <> '*'
			    
			ORDER BY SC5.C5_FILIAL, SC5.C5_DTENTR,SC5.C5_ROTEIRO, SC5.C5_SEQUENC 
			
	EndSQl
RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_VAL_FRETE.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_VAL_FRETE.XML")
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
	PutSx1(cPerg,'05','Roteiro Ini      ?','','','mv_ch5','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Roteiro Fin      ?','','','mv_ch6','C',03,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Seq Ini          ?','','','mv_ch7','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Seq Fin          ?','','','mv_ch8','C',02,0,0,'G',bValid,cF3 ,cSXG,cPyme,'MV_PAR08')

	
	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"FILIAL "           ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"DATA ENTREGA "     ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"ROTEIRO "          ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"SEQUENCIA "        ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM. PEDIDO "      ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PLACA "            ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. TOTAL PEDIDO " ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"VL. TOTAL FRETE "  ,1,1) // 08 H 			
RETURN(NIL)