#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADINF014P ºAutor  ³William COSTA       º Data ³  08/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa que irá gerar a diferenca de campos entre empresasº±±
±±ºDesc.     ³ no Protheus e deixar editar caso necessario                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACFG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlteracao ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADINF014P()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa que irá gerar a diferenca de campos entre empresas no Protheus e deixar editar caso necessario')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Programa Diferença entre SX3 para Empresas"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADINF014P'
	Private oTempTable := NIL
	Private aCampos    := {}
	Private cAlias1    := ''
	PRIVATE oExcel     := FWMSEXCEL():New()
	PRIVATE cPath      := ''
	PRIVATE cArquivo   := 'SX3_DIF.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := "Diferença entre SX3"
    PRIVATE cTitulo    := "Diferença entre SX3"
	PRIVATE aLinhas    := {}
	Private nLinha     := 0
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel e processar os dados " )
	AADD(aSays,"Programa Diferença entre SX3 para Empresas"     )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 6,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||INF014P()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=4, o:oWnd:End(), Processa({||INF014F()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
	//---------------------------------
	//Exclui a tabela Temporária
	//---------------------------------
	oTempTable:Delete()
	
Return (Nil)

Static Function INF014F()

	ALERT("Função não implementada clique no botão imprimir")
	
	/*
	GeraTempTable()
	SqlGeral() 
	ProcRegua(Contar("TRB","!Eof()") * 2)
	DBSELECTAREA("TRB")
	TRB->(DBGOTOP())
	WHILE TRB->(!EOF())
	
		DO CASE
			CASE TRB->DIFTIPO == 'NOK'
				cSTATUS := "I"
			CASE TRB->DIFTAMANH == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFDECIMA == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFPICTUR == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFVALID == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFUSADO == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFF3 == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFNIVEL == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFVISUAL == 'NOK'
				cSTATUS := "S"
			CASE TRB->DIFCONTEX == 'NOK'
				cSTATUS := "S"								
			OTHERWISE //Quando não tem campo
				cSTATUS := "E"
		ENDCASE
		     
        TRB->(dbSkip())    
	
	ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )
	*/ 
	
RETURN(NIL)  
    
Static Function INF014P()  
  
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
        
		GeraTempTable()
		Cabec()             
		GeraExcel()
	    SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local   nExcel := 0
	
	SqlGeral() 
	ProcRegua(Contar("TRB","!Eof()") * 2)
	DBSELECTAREA("TRB")
	TRB->(DBGOTOP())
	WHILE TRB->(!EOF())
	
		IncProc("Criando Excel - Tabela: " + TRB->TABELA1 + " Campo: " + TRB->CAMPO1)
		
		nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLinhas,{ "", ; // 01 A  
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
	                   "", ; // 33 AG
	                   "", ; // 34 AH
	                   "", ; // 35 AI
	                   ""  ; // 36 AJ  
	   	                  })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		aLinhas[nLinha][01] := TRB->TABELA1   //A
		aLinhas[nLinha][02] := TRB->CAMPO1    //B
		aLinhas[nLinha][03] := TRB->TIPO1     //C
		aLinhas[nLinha][04] := TRB->TAMANHO1  //D
		aLinhas[nLinha][05] := TRB->DECIMAL1  //E
		aLinhas[nLinha][06] := TRB->PICTURE1  //F
		aLinhas[nLinha][07] := TRB->VALID1    //G
		aLinhas[nLinha][08] := TRB->USADO1    //H
		aLinhas[nLinha][09] := TRB->F31       //I
		aLinhas[nLinha][10] := TRB->NIVEL1    //J
		aLinhas[nLinha][11] := TRB->VISUAL1   //K
		aLinhas[nLinha][12] := TRB->CONTEXT1  //L
		aLinhas[nLinha][13] := TRB->TABELA2   //M
		aLinhas[nLinha][14] := TRB->CAMPO2    //N
		aLinhas[nLinha][15] := TRB->TIPO2     //O
		aLinhas[nLinha][16] := TRB->TAMANHO2  //P
		aLinhas[nLinha][17] := TRB->DECIMAL2  //Q
		aLinhas[nLinha][18] := TRB->PICTURE2  //R
		aLinhas[nLinha][19] := TRB->VALID2    //S  
        aLinhas[nLinha][20] := TRB->USADO2    //T  
        aLinhas[nLinha][21] := TRB->F32       //U  
        aLinhas[nLinha][22] := TRB->NIVEL2    //V  
        aLinhas[nLinha][23] := TRB->VISUAL2   //W  
        aLinhas[nLinha][24] := TRB->CONTEXT2  //X  
        aLinhas[nLinha][25] := TRB->DIFTABELA //Y 
        aLinhas[nLinha][26] := TRB->DIFCAMPO  //Z  
        aLinhas[nLinha][27] := TRB->DIFTIPO   //AA  
        aLinhas[nLinha][28] := TRB->DIFTAMANH //AB
        aLinhas[nLinha][29] := TRB->DIFDECIMA //AC
        aLinhas[nLinha][30] := TRB->DIFPICTUR //AD
        aLinhas[nLinha][31] := TRB->DIFVALID  //AE
        aLinhas[nLinha][32] := TRB->DIFUSADO  //AF
        aLinhas[nLinha][33] := TRB->DIFF3     //AG
        aLinhas[nLinha][34] := TRB->DIFNIVEL  //AH
        aLinhas[nLinha][35] := TRB->DIFVISUAL //AI
        aLinhas[nLinha][36] := TRB->DIFCONTEX //AJ
		                                 	
		TRB->(dbSkip())    
	
	ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )   
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
	
		IncProc("Imprindo Excel: " + CVALTOCHAR(nExcel) + '/' + CVALTOCHAR(nLinha))
		
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
		                                 aLinhas[nExcel][30],; // 30 AD
		                                 aLinhas[nExcel][31],; // 31 AE
		                                 aLinhas[nExcel][32],; // 32 AF
		                                 aLinhas[nExcel][33],; // 33 AG
		                                 aLinhas[nExcel][34],; // 34 AH
		                                 aLinhas[nExcel][35],; // 35 AI
		                                 aLinhas[nExcel][36] ; // 36 AJ
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	                           
    NEXT 
    //============================== FINAL IMPRIME LINHA NO EXCEL
    
Return()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\SX3_DIF.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\SX3_DIF.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg() 
                                 
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    u_xPutSx1(cPerg,'01','Empresa SX3 Comparada       ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
		
	Pergunte(cPerg,.F.)
	
Return Nil
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"TABELA1"   ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"CAMPO1"    ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO1"     ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"TAMANHO1"  ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"DECIMAL1"  ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PICTURE1"  ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"VALID1"    ,1,1) // 07 G
    oExcel:AddColumn(cPlanilha,cTitulo,"USADO1"    ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"F31"       ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"NIVEL1"    ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"VISUAL1"   ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"CONTEXT1"  ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"TABELA2"   ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"CAMPO2"    ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO2"     ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"TAMANHO2"  ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"DECIMAL2"  ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"PICTURE2"  ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"VALID2"    ,1,1) // 19 S
    oExcel:AddColumn(cPlanilha,cTitulo,"USADO2"    ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"F32"       ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"NIVEL2"    ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"VISUAL2"   ,1,1) // 23 W
	oExcel:AddColumn(cPlanilha,cTitulo,"CONTEXT2"  ,1,1) // 24 X
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFTABELA" ,1,1) // 25 Y
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFCAMPO"  ,1,1) // 26 Z
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFTIPO"   ,1,1) // 27 AA
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFTAMANH" ,1,1) // 28 AB
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFDECIMA" ,1,1) // 29 AC
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFPICTUR" ,1,1) // 30 AD
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFVALID"  ,1,1) // 31 AE
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFUSADO"  ,1,1) // 32 AF
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFF3"     ,1,1) // 33 AG
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFNIVEL"  ,1,1) // 34 AH
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFVISUAL" ,1,1) // 35 AI
	oExcel:AddColumn(cPlanilha,cTitulo,"DIFCONTEX" ,1,1) // 36 AJ
	
RETURN(NIL) 

STATIC FUNCTION GeraTempTable()

	Local cStartPath   := GetSrvProfString("Startpath","")
	//Local nCont        := 0
	// *** INICIO CRIA TABELA TEMPORARIA *** //
	IncProc("Criando Tabela Temporária")  
	oTempTable := FWTemporaryTable():New("TRC")
	
	// INICIO Monta os campos da tabela
	aadd(aCampos,{"TABELA1"  ,"C",03,0})
    aadd(aCampos,{"CAMPO1"   ,"C",20,0})
    aadd(aCampos,{"TIPO1"    ,"C",01,0})
    aadd(aCampos,{"TAMANHO1" ,"N",10,0})
    aadd(aCampos,{"DECIMAL1" ,"N",02,0})
    aadd(aCampos,{"PICTURE1" ,"C",40,0})
    aadd(aCampos,{"VALID1"   ,"C",80,0})
    aadd(aCampos,{"USADO1"   ,"C",40,0})
    aadd(aCampos,{"F31"      ,"C",10,0})
    aadd(aCampos,{"NIVEL1"   ,"N",01,0})
    aadd(aCampos,{"VISUAL1"  ,"C",01,0})
    aadd(aCampos,{"CONTEXT1" ,"C",01,0})
    aadd(aCampos,{"TABELA2"  ,"C",03,0})
    aadd(aCampos,{"CAMPO2"   ,"C",20,0})
    aadd(aCampos,{"TIPO2"    ,"C",01,0})
    aadd(aCampos,{"TAMANHO2" ,"N",10,0})
    aadd(aCampos,{"DECIMAL2" ,"N",02,0})
    aadd(aCampos,{"PICTURE2" ,"C",40,0})
    aadd(aCampos,{"VALID2"   ,"C",80,0})
    aadd(aCampos,{"USADO2"   ,"C",40,0})
    aadd(aCampos,{"F32"      ,"C",10,0})
    aadd(aCampos,{"NIVEL2"   ,"N",01,0})
    aadd(aCampos,{"VISUAL2"  ,"C",01,0})
    aadd(aCampos,{"CONTEXT2" ,"C",01,0})
    aadd(aCampos,{"DIFTABELA","C",03,0})
    aadd(aCampos,{"DIFCAMPO" ,"C",03,0})
    aadd(aCampos,{"DIFTIPO"  ,"C",03,0})
    aadd(aCampos,{"DIFTAMANH","C",03,0})
    aadd(aCampos,{"DIFDECIMA","C",03,0})
    aadd(aCampos,{"DIFPICTUR","C",03,0})
    aadd(aCampos,{"DIFVALID" ,"C",03,0})
    aadd(aCampos,{"DIFUSADO" ,"C",03,0})
    aadd(aCampos,{"DIFF3"    ,"C",03,0})
    aadd(aCampos,{"DIFNIVEL" ,"C",03,0})
    aadd(aCampos,{"DIFVISUAL","C",03,0})
    aadd(aCampos,{"DIFCONTEX","C",03,0})
    
    // FINAL Monta os campos da tabela
    
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"CAMPO1"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()
    
	// *** FINAL CRIA TABELA TEMPORARIA *** //
	cAlias1   := 'SX3'+ ALLTRIM(MV_PAR01) + '0'
	
	DBSELECTAREA("SX3")
	SX3->(DBGOTOP())
	SX3->(DBSETORDER(1))
	
	ProcRegua(Contar("SX3","!Eof()") * 2)
	DBSELECTAREA("SX3")
	SX3->(DBGOTOP())
	SX3->(DBSETORDER(1))
	
	WHILE SX3->(!EOF()) //.AND. nCont <= 10
	
		IncProc("Carregando SX3" + ALLTRIM(CEMPANT) + '0: ' + SX3->X3_CAMPO)
		
		dbUseArea(.T., __LocalDriver, cStartPath+cAlias1+GetDbExtension(), "SX3_EMP", .T., .F.)
		
		DBSELECTAREA("SX3_EMP")
		SX3_EMP->(DBGOTOP())
		SX3_EMP->(DBSETORDER(2))
		IF DBSEEK(SX3->X3_CAMPO, .T.)
		
			IF SX3->X3_ARQUIVO <> SX3_EMP->X3_ARQUIVO .OR. ;
			   SX3->X3_CAMPO   <> SX3_EMP->X3_CAMPO   .OR. ;
			   SX3->X3_TIPO    <> SX3_EMP->X3_TIPO    .OR. ;
			   SX3->X3_TAMANHO <> SX3_EMP->X3_TAMANHO .OR. ;
			   SX3->X3_DECIMAL <> SX3_EMP->X3_DECIMAL .OR. ;
			   SX3->X3_PICTURE <> SX3_EMP->X3_PICTURE .OR. ;
			   SX3->X3_VALID   <> SX3_EMP->X3_VALID   .OR. ;
			   SX3->X3_USADO   <> SX3_EMP->X3_USADO   .OR. ;
			   SX3->X3_F3      <> SX3_EMP->X3_F3      .OR. ;
			   SX3->X3_NIVEL   <> SX3_EMP->X3_NIVEL   .OR. ;
			   SX3->X3_VISUAL  <> SX3_EMP->X3_VISUAL  .OR. ;
			   SX3->X3_CONTEXT <> SX3_EMP->X3_CONTEXT 
		
				IncProc("Carregando Temp Table IF: " + SX3->X3_CAMPO)
			
				Reclock("TRC",.T.)
			
					TRC->TABELA1   := SX3->X3_ARQUIVO
					TRC->CAMPO1    := SX3->X3_CAMPO
					TRC->TIPO1     := SX3->X3_TIPO
					TRC->TAMANHO1  := SX3->X3_TAMANHO
					TRC->DECIMAL1  := SX3->X3_DECIMAL
					TRC->PICTURE1  := SX3->X3_PICTURE
					TRC->VALID1    := SX3->X3_VALID
				    TRC->USADO1    := SX3->X3_USADO
				    TRC->F31       := SX3->X3_F3
				    TRC->NIVEL1    := SX3->X3_NIVEL
				    TRC->VISUAL1   := SX3->X3_VISUAL
				    TRC->CONTEXT1  := SX3->X3_CONTEXT
					TRC->TABELA2   := SX3_EMP->X3_ARQUIVO
					TRC->CAMPO2    := SX3_EMP->X3_CAMPO
					TRC->TIPO2     := SX3_EMP->X3_TIPO
					TRC->TAMANHO2  := SX3_EMP->X3_TAMANHO
					TRC->DECIMAL2  := SX3_EMP->X3_DECIMAL
					TRC->PICTURE2  := SX3_EMP->X3_PICTURE
					TRC->VALID2    := SX3_EMP->X3_VALID
				    TRC->USADO2    := SX3_EMP->X3_USADO
				    TRC->F32       := SX3_EMP->X3_F3
				    TRC->NIVEL2    := SX3_EMP->X3_NIVEL
				    TRC->VISUAL2   := SX3_EMP->X3_VISUAL
				    TRC->CONTEXT2  := SX3_EMP->X3_CONTEXT
					TRC->DIFTABELA := IIF(SX3->X3_ARQUIVO <> SX3_EMP->X3_ARQUIVO, 'NOK','OK')
				    TRC->DIFCAMPO  := IIF(SX3->X3_CAMPO   <> SX3_EMP->X3_CAMPO,   'NOK','OK')
				    TRC->DIFTIPO   := IIF(SX3->X3_TIPO    <> SX3_EMP->X3_TIPO,    'NOK','OK')
				    TRC->DIFTAMANH := IIF(SX3->X3_TAMANHO <> SX3_EMP->X3_TAMANHO, 'NOK','OK')
				    TRC->DIFDECIMA := IIF(SX3->X3_DECIMAL <> SX3_EMP->X3_DECIMAL, 'NOK','OK')
				    TRC->DIFPICTUR := IIF(SX3->X3_PICTURE <> SX3_EMP->X3_PICTURE, 'NOK','OK')
				    TRC->DIFVALID  := IIF(SX3->X3_VALID   <> SX3_EMP->X3_VALID,   'NOK','OK')
				    TRC->DIFUSADO  := IIF(SX3->X3_USADO   <> SX3_EMP->X3_USADO,   'NOK','OK')
				    TRC->DIFF3     := IIF(SX3->X3_F3      <> SX3_EMP->X3_F3,      'NOK','OK')
				    TRC->DIFNIVEL  := IIF(SX3->X3_NIVEL   <> SX3_EMP->X3_NIVEL,   'NOK','OK')
				    TRC->DIFVISUAL := IIF(SX3->X3_VISUAL  <> SX3_EMP->X3_VISUAL,  'NOK','OK')
				    TRC->DIFCONTEX := IIF(SX3->X3_CONTEXT <> SX3_EMP->X3_CONTEXT, 'NOK','OK')
				
				TRC->(MSUNLOCK())
			    //nCont := nCont + 1
			ENDIF
			
		ELSE
		
			IncProc("Carregando Temp Table ELSE: " + SX3->X3_CAMPO)
		
			Reclock("TRC",.T.)
		
				TRC->TABELA1   := SX3->X3_ARQUIVO
				TRC->CAMPO1    := SX3->X3_CAMPO
				TRC->TIPO1     := SX3->X3_TIPO
				TRC->TAMANHO1  := SX3->X3_TAMANHO
				TRC->DECIMAL1  := SX3->X3_DECIMAL
				TRC->PICTURE1  := SX3->X3_PICTURE
				TRC->VALID1    := SX3->X3_VALID
			    TRC->USADO1    := SX3->X3_USADO
			    TRC->F31       := SX3->X3_F3
			    TRC->NIVEL1    := SX3->X3_NIVEL
			    TRC->VISUAL1   := SX3->X3_VISUAL
			    TRC->CONTEXT1  := SX3->X3_CONTEXT
				TRC->TABELA2   := ''
				TRC->CAMPO2    := ''
				TRC->TIPO2     := ''
				TRC->TAMANHO2  := 0
				TRC->DECIMAL2  := 0
				TRC->PICTURE2  := ''
				TRC->VALID2    := ''
			    TRC->USADO2    := ''
			    TRC->F32       := ''
			    TRC->NIVEL2    := 0
			    TRC->VISUAL2   := ''
			    TRC->CONTEXT2  := ''
				TRC->DIFTABELA := 'NAO'
			    TRC->DIFCAMPO  := 'NAO'
			    TRC->DIFTIPO   := 'NAO'
			    TRC->DIFTAMANH := 'NAO'
			    TRC->DIFDECIMA := 'NAO'
			    TRC->DIFPICTUR := 'NAO'
			    TRC->DIFVALID  := 'NAO'
			    TRC->DIFUSADO  := 'NAO'
			    TRC->DIFF3     := 'NAO'
			    TRC->DIFNIVEL  := 'NAO'
			    TRC->DIFVISUAL := 'NAO'
			    TRC->DIFCONTEX := 'NAO'
			
			TRC->(MSUNLOCK())
			//nCont := nCont + 1
		ENDIF
		SX3_EMP->(DBCLOSEAREA())
		
		SX3->(DBSKIP())
				
	ENDDO
	
RETURN(NIL)

Static Function SqlGeral()

	Local cQuery1 := ''
	
	cQuery1 := " SELECT * "
	cQuery1 += "   FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += " ORDER BY  TABELA1,CAMPO1"
			 
	MPSysOpenQuery( cQuery1, 'TRB' )
	
RETURN()