#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG026R ºAutor  ³William COSTA       º Data ³  16/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório para acompanhamento dos abastecimentos de        º±±
±±º          ³ oleo que vem do CTAPLUS de acordo informacoes carregadas naº±±
±±º          ³ tabela ZBB                                                 º±±
±±º          ³ em EXCEL.                                                  º±±
±±º          ³ Relatorio Abastecimento de Oleo CTAPLUS Sintetico          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG026R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatorio Abastecimento de Oleo CTAPLUS Sintetico"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADLOG026R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório para acompanhamento dos abastecimentos de oleo que vem do CTAPLUS de acordo informacoes carregadas na tabela ZBB em EXCEL. Relatorio Abastecimento de Oleo CTAPLUS Sintetico')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Abastecimento de Oleo CTAPLUS analitico" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LOGADLOG026R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function LOGADLOG026R()    
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_CTAPLUS_SINTETICO.XML'
	Public oMsExcel
	Public cPlanilha   := "CTAPLUS SINTETICO"
    Public cTitulo     := "CTAPLUS SINTETICO"
    Public cCodProdSql := ''
    Public aLinhas    := {}
   
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

    Local nLinha    := 0
	Local nExcel    := 0
	Local nVolS10   := 0
	Local nVolS500  := 0
	Local dDataini  := MV_PAR01
	Local dDataFin  := MV_PAR03
	Local cHriniPar := MV_PAR02
	Local cHrFinPar := MV_PAR04

    SqlGeral() 
	
	WHILE TRB->(!EOF()) 
		
		// ********** INICIO DE VALIDACAO   *********** //
		IF STOD(TRB->ZBB_DTINI)                        = dDataini                       .AND. ;
		   SUBSTR(STRTRAN(TRB->ZBB_HRINI,':',''),1,6) <= SUBSTR(STRTRAN(cHriniPar,':',''),1,6) 
		   
			TRB->(DBSKIP())						
		    LOOP
		    
		ENDIF       
		
		IF STOD(TRB->ZBB_DTFIM)                        = dDataFin                       .AND. ;
		   SUBSTR(STRTRAN(TRB->ZBB_HRFIM,':',''),1,6) >= SUBSTR(STRTRAN(cHrFinPar,':',''),1,6)
		   
			TRB->(DBSKIP())						
		    LOOP
		    
		ENDIF       
		// ********** FINAL DE VALIDACAO   *********** // 
		
		IF ALLTRIM(TRB->ZBB_BOMBA) = 'S10'
		
			nVolS10  := nVolS10 + TRB->ZBB_VOLUME

		ENDIF
		
		IF ALLTRIM(TRB->ZBB_BOMBA) = 'S500'
		
			nVolS500 := nVolS500 + TRB->ZBB_VOLUME 
		
		ENDIF
	      
    	
			
		TRB->(dbSkip())    
	
	END //end do while TRB
	TRB->( DBCLOSEAREA() )   
	
	IF nVolS10 > 0
	
		nLinha  := nLinha + 1                                       
			
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		AADD(aLinhas,{ "", ; // 01 A  
		               "", ; // 02 B   
		               "", ; // 03 C  
		               "", ; // 04 D  
		               "", ; // 05 E  
		               ""  ; // 06 F   
		               })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
		//===================== INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===============
		aLinhas[nLinha][01] := MV_PAR01 //A
		aLinhas[nLinha][02] := MV_PAR02 //B
		aLinhas[nLinha][03] := MV_PAR03 //C
		aLinhas[nLinha][04] := MV_PAR04 //D
		aLinhas[nLinha][05] := 'S10'    //E
		aLinhas[nLinha][06] := nVolS10  //F
		
			                                  
		//====================== FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===============			
		
	ENDIF
	
	IF nVolS500 > 0
	
		nLinha  := nLinha + 1                                       
			
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		AADD(aLinhas,{ "", ; // 01 A  
		               "", ; // 02 B   
		               "", ; // 03 C  
		               "", ; // 04 D  
		               "", ; // 05 E  
		               ""  ; // 06 F   
		               })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
		//===================== INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===============
		aLinhas[nLinha][01] := MV_PAR01 //A
		aLinhas[nLinha][02] := MV_PAR02 //B
		aLinhas[nLinha][03] := MV_PAR03 //C
		aLinhas[nLinha][04] := MV_PAR04 //D
		aLinhas[nLinha][05] := 'S500'   //E
		aLinhas[nLinha][06] := nVolS500 //F
		
			                                  
		//====================== FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===============			
		
	ENDIF
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
                                     aLinhas[nExcel][02],;  // 02 B  
   	                                 aLinhas[nExcel][03],;  // 03 C  
   	                                 aLinhas[nExcel][04],;  // 04 D  
   	                                 aLinhas[nExcel][05],;  // 05 E  
   	                                 aLinhas[nExcel][06] ;  // 06 F  
   	                                                     }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
    NEXT 
	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

	Local cSqlDtini    := DTOS(MV_PAR01)
	Local cSqlDtFin    := DTOS(MV_PAR03)

	BeginSQL Alias "TRB"
			%NoPARSER%   
	     SELECT ZBB_IDABAS,
				ZBB_DTINI,
				ZBB_HRINI,
				ZBB_DTFIM,
				ZBB_HRFIM,
				ZBB_VOLUME,
				ZBB_PLACA,	
				ZBB_BOMBA
		   FROM %Table:ZBB%
		  WHERE ZBB_DTINI  >= %EXP:cSqlDtini%
			AND ZBB_DTINI  <= %EXP:cSqlDtFin%
			AND ZBB_CTAPLU  = 'T'
			AND D_E_L_E_T_ <> '*'
						   		
		ORDER BY ZBB_IDABAS
			
	EndSQl
RETURN(NIL)  

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_CTAPLUS_SINTETICO.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_CTAPLUS_SINTETICO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg() 
                                 
	Private bValid	:=Nil                                                                                                                    
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Data Inicial Fechamento ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Hora Inicial Fechamento ?','','','mv_ch02','C',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Final Fechamento   ?','','','mv_ch03','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Hora Final Fechamento   ?','','','mv_ch04','C',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.F.)
	
Return (Nil)            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Inicial "     ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Hora Inicial "     ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Data Final "       ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Hora Final "       ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Bomba "            ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Volume "           ,1,1) // 06 F
	
	
RETURN(NIL)