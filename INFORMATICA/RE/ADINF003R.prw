
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADINF003R ºAutor  ³William Costa       º Data ³  03/02/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Backlog da Sprint                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATEC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

User Function ADINF003R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio Backlog da Sprint"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADINF003R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |            
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Backlog da Sprint" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADINF003R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function ComADINF003R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_Backlog_Sprint.XML'
	Public oMsExcel
	Public cPlanilha   := "Backlog Sprint"
    Public cTitulo     := "Backlog Sprint"
    Public cCodProdSql := '' 
    Public cFilSql     := ''
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
	Local cDesc       := ''
	
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
				
				cDesc               := LEFT(TRB->PAA_ESCOPO,203)
				aLinhas[nLinha][01] := TRB->PAA_SPRINT //A
				aLinhas[nLinha][02] := TRB->PAA_CHAMAD //B
				aLinhas[nLinha][03] := TRB->PAA_CODIGO //C
				aLinhas[nLinha][04] := cDesc           //D
				aLinhas[nLinha][05] := TRB->PAA_PRISCR //E
				aLinhas[nLinha][06] := TRB->PAA_COMSCR //F
				aLinhas[nLinha][07] := TRB->PAA_GRACT  //G
				aLinhas[nLinha][08] := TRB->PAA_DGRACT //H 
			    aLinhas[nLinha][09] := TRB->PAA_SGRACT //I
			    aLinhas[nLinha][10] := TRB->PAA_DSGRAC //J
			    aLinhas[nLinha][11] := TRB->PAA_CCDESC //K
			    aLinhas[nLinha][12] := TRB->PAA_USUARI //L
			    aLinhas[nLinha][13] := TRB->PAA_NOMTEC //M
				
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
                                              aLinhas[nExcel][02],;  // 02 B  
	   	                                      aLinhas[nExcel][03],;  // 03 C  
	   	                                      aLinhas[nExcel][04],;  // 04 D  
        	   	                              aLinhas[nExcel][05],;  // 05 E  
	   	                                      aLinhas[nExcel][06],;  // 06 F  
	   	                                      aLinhas[nExcel][07],;  // 07 G  
	   	                                      aLinhas[nExcel][08],;  // 08 H  
	   	                                      aLinhas[nExcel][09],;  // 09 I  
	   	                                      aLinhas[nExcel][10],;  // 10 J 
	   	                                      aLinhas[nExcel][11],;  // 11 K  
	   	                                      aLinhas[nExcel][12],;  // 12 L  
	   	                                      aLinhas[nExcel][13] ;  // 13 M 
   	     	                                                      }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
	   NEXT 
	 	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()                        

Static Function SqlGeral()

    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT PAA_SPRINT,
			       PAA_CHAMAD, 
				   PAA_CODIGO, 
				   ISNULL(CONVERT(VARCHAR(8000),REPLACE(CONVERT(VARBINARY(8000),PAA_ESCOPO),char(13)+char(10),' ')),' ') AS PAA_ESCOPO,
				   PAA_PRISCR, 
			       PAA_COMSCR,
				   PAA_GRACT,
				   PAA_DGRACT,
				   PAA_SGRACT,
				   PAA_DSGRAC,
				   PAA_CCDESC,
				   PAA_USUARI,
				   PAA_NOMTEC
			  FROM %Table:PAA%
			 WHERE PAA_FIM     = ''
			   AND PAA_GRACT  >= %EXP:MV_PAR01%
			   AND PAA_GRACT  <= %EXP:MV_PAR02%
			   AND PAA_SGRACT >= %EXP:MV_PAR03%
			   AND PAA_SGRACT <= %EXP:MV_PAR04%
			   AND PAA_SPRINT >= %EXP:MV_PAR05%
			   AND PAA_SPRINT <= %EXP:MV_PAR06%
			   AND D_E_L_E_T_ <> '*'
			   
			
			  ORDER BY PAA_SPRINT,PAA_PRISCR
    EndSQl 

RETURN(NIL)



Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_Backlog_Sprint.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_Backlog_Sprint.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Grupo De      ?','','','mv_ch1','C',02,0,0,'G',bValid,"PA7",cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Grupo Ate     ?','','','mv_ch2','C',02,0,0,'G',bValid,"PA7",cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Sub-Grupo de  ?','','','mv_ch3','C',02,0,0,'G',bValid,"PA8",cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Sub-Grupo Ate ?','','','mv_ch4','C',02,0,0,'G',bValid,"PA8",cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Sprint de     ?','','','mv_ch5','C',09,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Sprint Ate    ?','','','mv_ch6','C',09,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
	
    Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                   
	oExcel:AddColumn(cPlanilha,cTitulo,"Sprint "             ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Chamado "            ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Os "                 ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc_Chamado "       ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Prioridade Scrum "   ,1,1) // 05 E
  	oExcel:AddColumn(cPlanilha,cTitulo,"Complexidade Scrum " ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod.Grupo "          ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc. Grupo "        ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod. Sub-Grupo "     ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc. Sub-Grupo "    ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Desc. Centro Custo " ,1,1) // 11 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Usuario "            ,1,1) // 12 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Tecnico "       ,1,1) // 13 J

	
RETURN(NIL)