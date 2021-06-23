#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCON012R บAutor  ณWilliam Costa       บ Data ณ  27/06/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de Inventimento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465       บฑฑ
ฑฑบ          ณ || REL_INVESTIMENTOS - FWNM - 26/08/2019                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 ||    บฑฑ
ฑฑบ          ณ AF8_XGRUPO - WILLIAM COSTA - 13/09/2019 - Adicionado o     บฑฑ
ฑฑบ          ณ Grupo de Projetos - AF8_XGRUPO - nas abas do relat๓rio     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADCON012R()

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relat๓rio Investimento"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADCON012R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuแrio.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio de Investimento" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERAADCON012R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function GERAADCON012R() 

 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := '\protheus_data\system\'
	Private cArquivo    := 'REL_INVESTIMENTO.XML'
	Private oMsExcel
	Private cPlanilha   := "IMOBILIZADO-AQUISIวรO"
	Private cTitulo     := "IMOBILIZADO-AQUISIวรO"
	Private cPlan2      := "CT2_Replica"
	Private cTit2       := "CT2_Replica"
	Private cPlan3      := "Base"
	Private cTit3       := "Base"
	Private cPlan4      := "CT2_Replica_COM_DUPLICIDADE"
	Private cTit4       := "CT2_Replica_COM_DUPLICIDADE"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
	Private aLin2       := {}
	Private aLin3       := {}
	Private nLin3       := 0
	Private aLin4       := {}
	Private nLin4       := 0
	Private cCodProd    := ''
	Private cDescProd   := ''
	Private cDocReq     := ''
	Private cProjeto    := ''
	Private cProjeto2   := ''
	Private cCusto      := ''
	Private cItemContab := ''
	Private cFilAtu     := ''
	Private cItem2      := ''
	Private cConta2     := ''
	Private cCusto2     := ''
	Private nValor2     := ''
	Private cNomeFilial := ''
	Private nValCredit  := 0
	Private nValDebito  := 0
	Private nRecno      := 0
	Private lChavedupla := .F.
	Private aCampos     := {}
	Private oTempTable  := NIL
	Private oTable2     := NIL
	Private nCont       := 0
	Private cQuery      := ''
	Private lEnviaNota  := .T.
	
	Begin Sequence
		
		//Verifica se hแ o excel instalado na mแquina do usuแrio.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Nใo Existe Excel Instalado","Fun็ใo GERAADCON012R(ADCON012R)")   
		    Break
		    
		EndIF
		
		//Gera o cabe็alho.
		Cabec()  
		          
		If ! GeraExcel()
			Break
			
		EndIf
		
		SalvaXml()
		
		CriaExcel()
		
		MsgInfo("Arquivo Excel gerado!","Fun็ใo GERAADCON012R(ADCON012R)")    
	    
	End Sequence

Return Nil 

Static Function Cabec() 

	//IMOBILIZADO-AQUISIวรO
	oExcel:AddworkSheet(cPlanilha)
		
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_FILIAL "	    ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_CBASE   "    ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_CHAPA   "    ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_FORNEC "	    ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_LOJA "	    ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"A2_NOME "       ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_NSERIE "     ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_NFISCAL "    ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_PRODUTO "    ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"N1_DESCRIC "    ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_CCONTAB "    ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_CUSTBEM "    ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_CCUSTO "     ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_VORIG1 "	    ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"R_E_C_N_O_ "    ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"R_E_C_N_O_2 "   ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_AQUISIC "    ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_DTBAIXA "    ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_ITEM "	    ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"FLAG "          ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"DT.MOVIM "	    ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"COD PROJETO "   ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"N3_SUBCTA   "   ,1,1) // 23 W // 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
	oExcel:AddColumn(cPlanilha,cTitulo,"Grupo Projeto " ,1,1) // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019

	//CT2_Replica
	oExcel:AddworkSheet(cPlan2)
		
	oExcel:AddTable (cPlan2,cTit2)
	oExcel:AddColumn(cPlan2,cTit2,"CT2_DATA2 "	   ,1,1) // 01 A
	oExcel:AddColumn(cPlan2,cTit2,"CT2_DATA   "    ,1,1) // 02 B
	oExcel:AddColumn(cPlan2,cTit2,"CT2_LOTE "	   ,1,1) // 03 C
	oExcel:AddColumn(cPlan2,cTit2,"CT2_DOC "	   ,1,1) // 04 D
	oExcel:AddColumn(cPlan2,cTit2,"CT2_LINHA "     ,1,1) // 05 E
	oExcel:AddColumn(cPlan2,cTit2,"CT2_DEBITO "    ,1,1) // 06 F
	oExcel:AddColumn(cPlan2,cTit2,"CT2_CREDIT "    ,1,1) // 07 G
	oExcel:AddColumn(cPlan2,cTit2,"CT2_VALOR "	   ,1,1) // 08 H
	oExcel:AddColumn(cPlan2,cTit2,"CT2_HIST "      ,1,1) // 09 I
	oExcel:AddColumn(cPlan2,cTit2,"CT2_CCD "       ,1,1) // 10 J
	oExcel:AddColumn(cPlan2,cTit2,"CT2_CCC "	   ,1,1) // 11 K
	oExcel:AddColumn(cPlan2,cTit2,"CT2_ITEMD "     ,1,1) // 12 L
	oExcel:AddColumn(cPlan2,cTit2,"CT2_ITEMC "	   ,1,1) // 13 M
	oExcel:AddColumn(cPlan2,cTit2,"R_E_C_N_O_ "    ,1,1) // 14 N
	oExcel:AddColumn(cPlan2,cTit2,"Coluna1 "	   ,1,1) // 15 O
	oExcel:AddColumn(cPlan2,cTit2,"Coluna2 "       ,1,1) // 16 P
	oExcel:AddColumn(cPlan2,cTit2,"Coluna3 "	   ,1,1) // 17 Q
	oExcel:AddColumn(cPlan2,cTit2,"Coluna4 "       ,1,1) // 18 R
	oExcel:AddColumn(cPlan2,cTit2,"Coluna5 "       ,1,1) // 19 S
	oExcel:AddColumn(cPlan2,cTit2,"Coluna6 "       ,1,1) // 20 T
	oExcel:AddColumn(cPlan2,cTit2,"Coluna7 "       ,1,1) // 21 U
	oExcel:AddColumn(cPlan2,cTit2,"Coluna8 "	   ,1,1) // 22 V
	oExcel:AddColumn(cPlan2,cTit2,"PROJETO "       ,1,1) // 23	W
	oExcel:AddColumn(cPlan2,cTit2,"Grupo Projeto " ,1,1) // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
	
	//BASE
	oExcel:AddworkSheet(cPlan3)
		
	oExcel:AddTable (cPlan3,cTit3)
	oExcel:AddColumn(cPlan3,cTit3,"FILIAL "	       ,1,1) // 01 A
	oExcel:AddColumn(cPlan3,cTit3,"ITEM   "        ,1,1) // 02 B
	oExcel:AddColumn(cPlan3,cTit3,"C_CUSTO "	   ,1,1) // 03 C
	oExcel:AddColumn(cPlan3,cTit3,"CTA_CONTมBIL "  ,1,1) // 04 D
	oExcel:AddColumn(cPlan3,cTit3,"FORNEC "        ,1,1) // 05 E
	oExcel:AddColumn(cPlan3,cTit3,"FORNEC "        ,1,1) // 06 F
	oExcel:AddColumn(cPlan3,cTit3,"VALOR "         ,1,1) // 07 G
	oExcel:AddColumn(cPlan3,cTit3,"DATA "	       ,1,1) // 08 H
	oExcel:AddColumn(cPlan3,cTit3,"HISTำRICO "     ,1,1) // 09 I
	oExcel:AddColumn(cPlan3,cTit3,"PROJETO "       ,1,1) // 10 J
	oExcel:AddColumn(cPlan3,cTit3,"Grupo Projeto " ,1,1) // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019        
	
	//CT2_Replica_SEM_DUPLICIDADE
	oExcel:AddworkSheet(cPlan4)
		
	oExcel:AddTable (cPlan4,cTit4)
	oExcel:AddColumn(cPlan4,cTit4,"CT2_DATA2 "	        ,1,1) // 01 A
	oExcel:AddColumn(cPlan4,cTit4,"CT2_DATA   "         ,1,1) // 02 B
	oExcel:AddColumn(cPlan4,cTit4,"CT2_LOTE "	        ,1,1) // 03 C
	oExcel:AddColumn(cPlan4,cTit4,"CT2_DOC "	        ,1,1) // 04 D
	oExcel:AddColumn(cPlan4,cTit4,"CT2_LINHA "          ,1,1) // 05 E
	oExcel:AddColumn(cPlan4,cTit4,"CT2_DEBITO "         ,1,1) // 06 F
	oExcel:AddColumn(cPlan4,cTit4,"CT2_CREDIT "         ,1,1) // 07 G
	oExcel:AddColumn(cPlan4,cTit4,"CT2_VALOR "	        ,1,1) // 08 H
	oExcel:AddColumn(cPlan4,cTit4,"CT2_HIST "           ,1,1) // 09 I
	oExcel:AddColumn(cPlan4,cTit4,"CT2_CCD "            ,1,1) // 10 J
	oExcel:AddColumn(cPlan4,cTit4,"CT2_CCC "	        ,1,1) // 11 K
	oExcel:AddColumn(cPlan4,cTit4,"CT2_ITEMD "          ,1,1) // 12 L
	oExcel:AddColumn(cPlan4,cTit4,"CT2_ITEMC "	        ,1,1) // 13 M
	oExcel:AddColumn(cPlan4,cTit4,"R_E_C_N_O_ "         ,1,1) // 14 N
	oExcel:AddColumn(cPlan4,cTit4,"Coluna1 "	        ,1,1) // 15 O
	oExcel:AddColumn(cPlan4,cTit4,"Coluna2   "          ,1,1) // 16 P
	oExcel:AddColumn(cPlan4,cTit4,"Coluna3 "	        ,1,1) // 17 Q
	oExcel:AddColumn(cPlan4,cTit4,"Coluna4 "            ,1,1) // 18 R
	oExcel:AddColumn(cPlan4,cTit4,"Coluna5 "            ,1,1) // 19 S
	oExcel:AddColumn(cPlan4,cTit4,"Coluna6 "            ,1,1) // 20 T
	oExcel:AddColumn(cPlan4,cTit4,"Coluna7 "            ,1,1) // 21 U
	oExcel:AddColumn(cPlan4,cTit4,"Coluna8 "	        ,1,1) // 22 V
	oExcel:AddColumn(cPlan4,cTit4,"Coluna9 "            ,1,1) // 23	W
	
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCON012R บAutor  ณMicrosiga           บ Data ณ  08/26/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cNumPC        := ''
		
	// INICIO PLANILHA 1	
	SqlAtivo()   //Sql TRB
	SqlCT2_SIG() // Sql TRC
	
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")
	nTotReg := (nTotReg + Contar("TRC","!Eof()")) * 6
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Nใo hแ registros para os parโmetros informados.","Fun็ใo GERAADCON012R(ADCON012R)")
		Return .F.
		
	EndIf
	
	nLinha := 0
	nLin3  := 0
	
	//Atribui a quantidade de registros เ r้gua de processamento.
	ProcRegua(nTotReg)
	TRB->(DbGoTop())
	While !TRB->(Eof()) 
	
		IncProc("IMOBILIZADO-AQUISIวรO " + TRB->N1_NFISCAL)     
					 
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
					   "", ; // 23 W // 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
					   ""  ; // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
	   	                  })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//DadosIMOBILIZADO-AQUISIวรO A
		aLinhas[nLinha][01] := TRB->N1_FILIAL                                                                        // 01 A	
		aLinhas[nLinha][02] := TRB->N1_CBASE                                                                         // 02 B
		aLinhas[nLinha][03] := TRB->N1_CHAPA                                                                         // 03 C
		aLinhas[nLinha][04] := TRB->N1_FORNEC                                                                        // 04 D
		aLinhas[nLinha][05] := TRB->N1_LOJA                                                                          // 05 E
		aLinhas[nLinha][06] := TRB->A2_NOME                                                                          // 06 F
		aLinhas[nLinha][07] := TRB->N1_NSERIE                                                                        // 07 G
		aLinhas[nLinha][08] := TRB->N1_NFISCAL                                                                       // 08 H
		aLinhas[nLinha][09] := TRB->N1_PRODUTO                                                                       // 09 I
		aLinhas[nLinha][10] := TRB->N1_DESCRIC                                                                       // 10 J
		aLinhas[nLinha][11] := TRB->N3_CCONTAB                                                                       // 11 K
		aLinhas[nLinha][12] := TRB->N3_CUSTBEM                                                                       // 12 L
		aLinhas[nLinha][13] := TRB->N3_CCUSTO                                                                        // 13 M
		aLinhas[nLinha][14] := TRB->N3_VORIG1                                                                        // 14 N
		aLinhas[nLinha][15] := TRB->R_E_C_1                                                                          // 15 O
		aLinhas[nLinha][16] := TRB->R_E_C_2                                                                          // 16 P
		aLinhas[nLinha][17] := STOD(TRB->N3_AQUISIC)                                                                 // 17 Q
		aLinhas[nLinha][18] := STOD(TRB->N3_DTBAIXA)                                                                 // 18 R
		aLinhas[nLinha][19] := TRB->N3_ITEM                                                                          // 19 S
		aLinhas[nLinha][20] := IIF(STOD(TRB->N3_AQUISIC) >= MV_PAR01 .AND. STOD(TRB->N3_AQUISIC) <= MV_PAR02,'A','') // 20 T
		aLinhas[nLinha][21] := IIF(ALLTRIM(aLinhas[nLinha][20]) == 'A',STOD(TRB->N3_AQUISIC),STOD(TRB->N3_DTBAIXA))  // 21 U
		
		SqlProj1(TRB->N1_FILIAL,TRB->N1_NFISCAL,TRB->N1_FORNEC,TRB->N1_LOJA,TRB->N3_VORIG1,TRB->N1_NSERIE)
		TRD->(DbGoTop())
		While !TRD->(Eof()) 
		                                                          
			aLinhas[nLinha][22] := IIF(EMPTY(TRD->C7_PROJETO),TRD->D1_PROJETO,TRD->C7_PROJETO) // 22 V
			// Chamado n. 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 27/08/2019
			If !Empty(aLinhas[nLinha][22])
				aLinhas[nLinha][22] := aLinhas[nLinha][22] + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+ALLTRIM(aLinhas[nLinha][22]),"AF8_DESCRI") // 22 V
			EndIf
		
			TRD->(DBSKIP())    
			
		ENDDO
		TRD->(DbCloseArea()) 
		
		IF ALLTRIM(aLinhas[nLinha][22]) == ''
		
			SqlProj2(TRB->N1_FILIAL,TRB->N1_NFISCAL,TRB->N1_FORNEC,TRB->N1_LOJA,TRB->N3_VORIG1,TRB->N1_NSERIE)
			TRE->(DbGoTop())
			While !TRE->(Eof()) 
			                                                          
				aLinhas[nLinha][22] := IIF(EMPTY(TRE->C7_PROJETO),TRE->D1_PROJETO,TRE->C7_PROJETO) // 22 V
				// Chamado n. 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 27/08/2019
				If !Empty(aLinhas[nLinha][22])
					aLinhas[nLinha][22] := aLinhas[nLinha][22] + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+ALLTRIM(aLinhas[nLinha][22]),"AF8_DESCRI") // 22 V
				EndIf

				TRE->(DBSKIP())    
				
			ENDDO
			TRE->(DbCloseArea())
		
		ENDIF  
		
		// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
		aLinhas[nLinha][22] := UpBase( "2", AllTrim(aLinhas[nLinha][13]), AllTrim(aLinhas[nLinha][22]) )                                            // 22V	
		//

		// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
		aLinhas[nLinha][23] := TRB->N3_SUBCTA  // 23 W                                                
		//
		
		aLinhas[nLinha][24] := Posicione("AF8",1,FWxFilial("AF8")+SUBSTR(aLinhas[nLinha][22],1,AT(' ',aLinhas[nLinha][22])-1),"AF8_XGRUPO")  // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019

		// *** INICIO CARREGA CAMPOS PARA A PLANILHA BASE QUANDO O PLANO E A *** //
		IF ALLTRIM(aLinhas[nLinha][20]) == 'A'
		
		   IncProc("Criando Dado para a Planilha3: " + aLinhas[nLinha][20])
					   
		   nLin3  := nLin3 + 1
		   
		   Aadd(aLin3,{ "", ; // 01 A  
	   	                "", ; // 02 B   
	   	                "", ; // 03 C  
	   	                "", ; // 04 D  
	   	                "", ; // 05 E  
	   	                "", ; // 06 F   
	   	                "", ; // 07 G  
	   	                "", ; // 08 H  
	   	                "", ; // 09 I  
						"", ; // 10 J   
						""  ; // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019  
	   	                  })
	   	                  
	   		// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
            /*
	   	    DO CASE
	        
				CASE aLinhas[nLinha][01]   == '01'
				    cNomeFilial := 'MT'
				CASE aLinhas[nLinha][01]   == '02'
				    cNomeFilial := 'VP'
				CASE aLinhas[nLinha][01]   == '03'
				    cNomeFilial := 'SC'
				CASE aLinhas[nLinha][01]   == '04'
				    cNomeFilial := 'RC'
				CASE aLinhas[nLinha][01]   == '05'
				    cNomeFilial := 'FR'
				CASE aLinhas[nLinha][01]   == '06'
				    cNomeFilial := 'IT'
				CASE aLinhas[nLinha][01]   == '07'
				    cNomeFilial := 'LO'
				CASE aLinhas[nLinha][01]   == '08'
				    cNomeFilial := 'GO'
				CASE aLinhas[nLinha][01]   == '09'
				    cNomeFilial := 'RC2'                            
				OTHERWISE
					cNomeFilial := ''
					
			ENDCASE              
		   	*/
		   	                  
		   	//Base

			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][01] := cNomeFilial                                                                 // 01 A	
			aLin3[nLin3][01] := UpBase( "1", AllTrim(aLinhas[nLinha][23]) )                                            // 01 A	
			//
			
			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][02] := ''                                                                          // 02 B
			aLin3[nLin3][02] := aLinhas[nLinha][23]                                                         // 02 B
			//
			
			aLin3[nLin3][03] := aLinhas[nLinha][13]                                                         // 03 C
			aLin3[nLin3][04] := aLinhas[nLinha][11]                                                         // 04 D
			aLin3[nLin3][05] := aLinhas[nLinha][04] + '-' + aLinhas[nLinha][05] + '-' + aLinhas[nLinha][06] // 05 E
			
			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][06] := aLinhas[nLinha][09] + '-' + aLinhas[nLinha][10]                             // 06 F
			//
			
			aLin3[nLin3][07] := aLinhas[nLinha][14]                                                         // 07 G
			aLin3[nLin3][08] := aLinhas[nLinha][21]                                                         // 08 H

			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019			
			//aLin3[nLin3][09] := ''                                                                          // 09 I
			aLin3[nLin3][09] := aLinhas[nLinha][09] + '-' + aLinhas[nLinha][10]                             // 09 I
			//
			
			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][10] := aLinhas[nLinha][22]                                                         // 10 J
			// Tipo, CC, Projeto
			aLin3[nLin3][10] := UpBase( "2", AllTrim(aLinhas[nLinha][13]), AllTrim(aLinhas[nLinha][22]) )                                            // 10 J
			aLin3[nLin3][11] := Posicione("AF8",1,FWxFilial("AF8")+SUBSTR(aLinhas[nLinha][22],1,AT(' ',aLinhas[nLinha][22])-1),"AF8_XGRUPO") // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
			//
		   
		ENDIF
		// *** FINAL CARREGA CAMPOS PARA A PLANILHA BASE QUANDO O PLANO E A *** //
		
		IF STOD(TRB->N3_DTBAIXA) >= MV_PAR01 .AND. ;
		   STOD(TRB->N3_DTBAIXA) <= MV_PAR02 
		   
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
						   "", ; // 23 W // 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
						   ""  ; // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
		   	                  })
		
			nLinha  := nLinha + 1
			
			//DadosIMOBILIZADO-AQUISIวรO B
			aLinhas[nLinha][01] := TRB->N1_FILIAL        // 01 A	
			aLinhas[nLinha][02] := TRB->N1_CBASE         // 02 B
			aLinhas[nLinha][03] := TRB->N1_CHAPA         // 03 C
			aLinhas[nLinha][04] := TRB->N1_FORNEC        // 04 D
			aLinhas[nLinha][05] := TRB->N1_LOJA          // 05 E
			aLinhas[nLinha][06] := TRB->A2_NOME          // 06 F
			aLinhas[nLinha][07] := TRB->N1_NSERIE        // 07 G
			aLinhas[nLinha][08] := TRB->N1_NFISCAL       // 08 H
			aLinhas[nLinha][09] := TRB->N1_PRODUTO       // 09 I
			aLinhas[nLinha][10] := TRB->N1_DESCRIC       // 10 J
			aLinhas[nLinha][11] := TRB->N3_CCONTAB       // 11 K
			aLinhas[nLinha][12] := TRB->N3_CUSTBEM       // 12 L
			aLinhas[nLinha][13] := TRB->N3_CCUSTO        // 13 M
			aLinhas[nLinha][14] := TRB->N3_VORIG1 * (-1) // 14 N
			aLinhas[nLinha][15] := TRB->R_E_C_1          // 15 O
			aLinhas[nLinha][16] := TRB->R_E_C_2          // 16 P
			aLinhas[nLinha][17] := STOD(TRB->N3_AQUISIC) // 17 Q
			aLinhas[nLinha][18] := STOD(TRB->N3_DTBAIXA) // 18 R
			aLinhas[nLinha][19] := TRB->N3_ITEM          // 19 S
			aLinhas[nLinha][20] := 'B'                   // 20 T
			aLinhas[nLinha][21] := STOD(TRB->N3_DTBAIXA) // 21 U
			
			SqlProj1(TRB->N1_FILIAL,TRB->N1_NFISCAL,TRB->N1_FORNEC,TRB->N1_LOJA,TRB->N3_VORIG1,TRB->N1_NSERIE)
			TRD->(DbGoTop())
			While !TRD->(Eof()) 
			                                                          
				aLinhas[nLinha][22] := IIF(EMPTY(TRD->C7_PROJETO),TRD->D1_PROJETO,TRD->C7_PROJETO) // 22 V
				// Chamado n. 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 27/08/2019
				If !Empty(aLinhas[nLinha][22])
					aLinhas[nLinha][22] := aLinhas[nLinha][22] + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+ALLTRIM(aLinhas[nLinha][22]),"AF8_DESCRI") // 22 V
				EndIf
			
				TRD->(DBSKIP())    
				
			ENDDO
			TRD->(DbCloseArea()) 
			
			IF ALLTRIM(aLinhas[nLinha][22]) == ''
			
				SqlProj2(TRB->N1_FILIAL,TRB->N1_NFISCAL,TRB->N1_FORNEC,TRB->N1_LOJA,TRB->N3_VORIG1,TRB->N1_NSERIE)
				TRE->(DbGoTop())
				While !TRE->(Eof()) 
				                                                          
					aLinhas[nLinha][22] := IIF(EMPTY(TRE->C7_PROJETO),TRE->D1_PROJETO,TRE->C7_PROJETO) // 22 V
					// Chamado n. 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 27/08/2019
					If !Empty(aLinhas[nLinha][22])
						aLinhas[nLinha][22] := aLinhas[nLinha][22] + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+ALLTRIM(aLinhas[nLinha][22]),"AF8_DESCRI") // 22 V
					EndIf
					TRE->(DBSKIP())    
					
				ENDDO
				TRE->(DbCloseArea())
			
			ENDIF
			
			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			aLinhas[nLinha][22] := UpBase( "2", AllTrim(aLinhas[nLinha][13]), AllTrim(aLinhas[nLinha][22]) )                                            // 22V	
			//

			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			aLinhas[nLinha][23] := TRB->N3_SUBCTA  // 23 W                                                
			//

			aLinhas[nLinha][24] := Posicione("AF8",1,FWxFilial("AF8")+SUBSTR(aLinhas[nLinha][22],1,AT(' ',aLinhas[nLinha][22])-1),"AF8_XGRUPO")  // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
	
			// *** INICIO CARREGA CAMPOS PARA A PLANILHA BASE QUANDO O PLANO E B *** //
			IF ALLTRIM(aLinhas[nLinha][20]) == 'B' 
			
			   IncProc("Criando Dado para a Planilha3: " + aLinhas[nLinha][20])
						   
			   nLin3  := nLin3 + 1
			   
			   Aadd(aLin3,{ "", ; // 01 A  
		   	                "", ; // 02 B   
		   	                "", ; // 03 C  
		   	                "", ; // 04 D  
		   	                "", ; // 05 E  
		   	                "", ; // 06 F   
		   	                "", ; // 07 G  
		   	                "", ; // 08 H  
		   	                "", ; // 09 I  
							"", ; // 10 J   
							""  ; // 11 K  // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019 
		   	                  })
		   	                  
	   		// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
            /*

		   	    DO CASE
		        
					CASE aLinhas[nLinha][01]   == '01'
					    cNomeFilial := 'MT'
					CASE aLinhas[nLinha][01]   == '02'
					    cNomeFilial := 'VP'
					CASE aLinhas[nLinha][01]   == '03'
					    cNomeFilial := 'SC'
					CASE aLinhas[nLinha][01]   == '04'
					    cNomeFilial := 'RC'
					CASE aLinhas[nLinha][01]   == '05'
					    cNomeFilial := 'FR'
					CASE aLinhas[nLinha][01]   == '06'
					    cNomeFilial := 'IT'
					CASE aLinhas[nLinha][01]   == '07'
					    cNomeFilial := 'LO'
					CASE aLinhas[nLinha][01]   == '08'
					    cNomeFilial := 'GO'
					CASE aLinhas[nLinha][01]   == '09'
					    cNomeFilial := 'RC2'                            
					OTHERWISE
						cNomeFilial := ''
						
				ENDCASE              
			*/
			   	                  
			   	//Base

				// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
				//aLin3[nLin3][01] := cNomeFilial                                                                 // 01 A	
				aLin3[nLin3][01] := UpBase( "1", AllTrim(aLinhas[nLinha][23]) )                                            // 01 A	
				//

				// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
				//aLin3[nLin3][02] := ''                                                                          // 02 B
				aLin3[nLin3][02] := aLinhas[nLinha][23]                                                         // 02 B
				//
	
				aLin3[nLin3][03] := aLinhas[nLinha][13]                                                         // 03 C
				aLin3[nLin3][04] := aLinhas[nLinha][11]                                                         // 04 D
				aLin3[nLin3][05] := aLinhas[nLinha][04] + '-' + aLinhas[nLinha][05] + '-' + aLinhas[nLinha][06] // 05 E

				// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
				//aLin3[nLin3][06] := aLinhas[nLinha][09] + '-' + aLinhas[nLinha][10]                             // 06 F
				//
	
				aLin3[nLin3][07] := aLinhas[nLinha][14]                                                         // 07 G
				aLin3[nLin3][08] := aLinhas[nLinha][21]                                                         // 08 H

				// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019			
				//aLin3[nLin3][09] := ''                                                                          // 09 I
				aLin3[nLin3][09] := aLinhas[nLinha][09] + '-' + aLinhas[nLinha][10]                             // 09 I
				//
	
				// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
				//aLin3[nLin3][10] := aLinhas[nLinha][22]                                                         // 10 J
				// Tipo, CC, Projeto
				aLin3[nLin3][10] := UpBase( "2", AllTrim(aLinhas[nLinha][13]), AllTrim(aLinhas[nLinha][22]) )                                            // 10 J
				//

				aLin3[nLin3][11] := Posicione("AF8",1,FWxFilial("AF8")+SUBSTR(aLinhas[nLinha][22],1,AT(' ',aLinhas[nLinha][22])-1),"AF8_XGRUPO") // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019

			ENDIF
			// *** FINAL CARREGA CAMPOS PARA A PLANILHA BASE QUANDO O PLANO E B *** //
		ENDIF
		
		TRB->(DBSKIP())    
		
	ENDDO
	
	TRB->(DbCloseArea())    
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
	
		IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' at้: ' + cValtochar(nLinha))
		
		
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
								         aLinhas[nExcel][13],;  // 13 M  
								         aLinhas[nExcel][14],;  // 14 N
								         aLinhas[nExcel][15],;  // 15 O  
									     aLinhas[nExcel][16],;  // 16 P  
									     aLinhas[nExcel][17],;  // 17 Q  
									     aLinhas[nExcel][18],;  // 18 R  
									     aLinhas[nExcel][19],;  // 19 S
									     aLinhas[nExcel][20],;  // 20 T  
									     aLinhas[nExcel][21],;  // 21 U
									     aLinhas[nExcel][22],;  // 22 V  
										 aLinhas[nExcel][23],;  // 23 W // 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
										 aLinhas[nExcel][24] ;  // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
								                             }) 	
													      	 			
    Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	//FINAL PLANILHA 1
 	
 	//INICIO PLANILHA 2
 	nExcel:= 0
 	nLinha:= 0
 	
 	// *** INICIO CRIA TABELA TEMPORARIA *** //
 	
 	//-------------------
	//Cria็ใo do objeto
	//-------------------
	
	oTempTable := FWTemporaryTable():New("TRU")
	
	// INICIO Monta os campos da tabela
	
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_FILIAL")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_DOC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_SERIE")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_FORNECE")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_LOJA")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_COD")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_CUSTO")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_PROJETO")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("C7_PROJETO")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("B1_DESC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("A2_NOME")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_CC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("FT_VALCONT")
        AADD(aCampos,{"VALFT1" , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("FT_VALCONT")
        AADD(aCampos,{"VALFT2" , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("FT_VALCONT")
        AADD(aCampos,{"VALFT3" , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("FT_VALCONT")
        AADD(aCampos,{"VALFT4" , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    aadd(aCampos,{"OK","C",1,0})
    aadd(aCampos,{"SD1RECNO","N",10,0})
    
    // FINAL Monta os campos da tabela
    
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"SD1RECNO"} )
	//oTempTable:AddIndex("02", {"CONTR", "ALIAS"} )
	
	//------------------
	//Cria็ใo da tabela
	//------------------
	oTempTable:Create()
	
	// *** INICIO TABELA 2
	aCampos := {}
	
	oTable2 := FWTemporaryTable():New("TSD")
	
	// INICIO Monta os campos da tabela
	
	DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_DATA")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_LOTE")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_SBLOTE")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_DOC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_LINHA")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_DEBITO")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_CREDIT")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_CCD")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_CCC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_ITEMD")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_ITEMC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_VALOR")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_HIST")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    aadd(aCampos,{"RECNO_CT2","N",10,0})
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_FILKEY")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_PREFIX")
        AADD(aCampos,{X3_CAMPO, X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_NUMDOC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_PARCEL")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_TIPODC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_CLIFOR")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_LOJACF")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_KEY")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_COD")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("B1_DESC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("A2_NOME")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("D1_CC")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("C7_PROJETO")
        AADD(aCampos,{"PROJETO" , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    DBSELECTAREA("SX3")
	DBSETORDER(2)
	IF DBSEEK("CT2_LP")
        AADD(aCampos,{X3_CAMPO , X3_TIPO , X3_TAMANHO , X3_DECIMAL , X3_TITULO , X3_PICTURE})
    ENDIF
    
    // FINAL Monta os campos da tabela
    
	oTable2:SetFields(aCampos)
	//oTable2:AddIndex("02", {"CT2_DATA"} )
	oTable2:AddIndex("01", {"CT2_DATA","CT2_LOTE","CT2_SBLOTE","CT2_DOC","CT2_LINHA"} )
	oTable2:AddIndex("02", {"RECNO_CT2"} )
	oTable2:AddIndex("03", {"CT2_FILKEY","CT2_PREFIX","CT2_NUMDOC","CT2_PARCEL","CT2_TIPODC","CT2_CLIFOR","CT2_LOJACF"} )
	
	//------------------
	//Cria็ใo da tabela
	//------------------
	oTable2:Create()
	// *** FINAL CRIA TABELA TEMPORARIA *** //
 	
	TRC->(DbGoTop())
	While !TRC->(Eof()) 
	
		IncProc("Carregando Tabela Temporaria " + TRC->CT2_HIST)  
		
		Reclock("TSD",.T.)
				    
			TSD->CT2_DATA   := STOD(TRC->CT2_DATA)    	
			TSD->CT2_LOTE   := TRC->CT2_LOTE 
			TSD->CT2_SBLOTE := TRC->CT2_SBLOTE   
			TSD->CT2_DOC    := TRC->CT2_DOC      
			TSD->CT2_LINHA  := TRC->CT2_LINHA  
			TSD->CT2_DEBITO := TRC->CT2_DEBITO
			TSD->CT2_CREDIT := TRC->CT2_CREDIT
			TSD->CT2_VALOR  := TRC->CT2_VALOR 
			TSD->CT2_HIST   := TRC->CT2_HIST            
			TSD->CT2_CCD    := TRC->CT2_CCD             
			TSD->CT2_CCC    := TRC->CT2_CCC             
			TSD->CT2_ITEMD  := TRC->CT2_ITEMD           
			TSD->CT2_ITEMC  := TRC->CT2_ITEMC           
			TSD->RECNO_CT2  := TRC->R_E_C_N_O_          
			TSD->CT2_FILKEY := TRC->CT2_FILKEY  
			TSD->CT2_PREFIX := TRC->CT2_PREFIX        	
			TSD->CT2_NUMDOC := TRC->CT2_NUMDOC
			TSD->CT2_PARCEL := TRC->CT2_PARCEL
			TSD->CT2_TIPODC := TRC->CT2_TIPODC          
			TSD->CT2_CLIFOR := TRC->CT2_CLIFOR          
			TSD->CT2_LOJACF := TRC->CT2_LOJACF
			TSD->CT2_KEY    := Posicione("CT2",1,xFilial("CT2")+TRC->CT2_DATA+TRC->CT2_LOTE+TRC->CT2_SBLOTE+TRC->CT2_DOC+TRC->CT2_LINHA,"CT2_KEY")
			TSD->CT2_LP     := Posicione("CT2",1,xFilial("CT2")+TRC->CT2_DATA+TRC->CT2_LOTE+TRC->CT2_SBLOTE+TRC->CT2_DOC+TRC->CT2_LINHA,"CT2_LP")
			
		TSD->(MSUNLOCK())   
	
	TRC->(DBSKIP())    
		
	ENDDO
	
	TRC->(DbCloseArea())
	
	// *** INICIO RETIRAR DUPLICIDADES *** //
	
	SqlTable2() // Sql TSE
	TSE->(DbGoTop())
	While !TSE->(Eof()) 
	
		IncProc("Retirando Duplicidades " + TSE->CT2_HIST)
		
		/*
		IF TSE->RECNO_CT2 == 91660306
		
			CONOUT("ENTREI AQUI WILL")
		
		ENDIF 
		*/
		
		IF (SUBSTR(TSE->CT2_HIST,1,11) == 'EST COMPRAS' .OR. ;
		    SUBSTR(TSE->CT2_HIST,1,11) == 'EST.COMPRAS' .OR. ; 
		    SUBSTR(TSE->CT2_HIST,1,10) == 'COMPRAS NF')
		    
		    nValDebito  := 0
		   	nValCredit  := 0
		   	nRecno      := 0
		   	
			SqlBuscaCt2(TSE->RECNO_CT2)
			TRL->(DbGoTop())
			While !TRL->(Eof()) 
			
				SqlDebito(TRL->CT2_FILKEY,TRL->CT2_PREFIX,TRL->CT2_NUMDOC,TRL->CT2_PARCEL,TRL->CT2_TIPODC,TRL->CT2_CLIFOR,TRL->CT2_LOJACF,TRL->CT2_VALOR,IIF(ALLTRIM(TRL->CT2_CCD) <> '',TRL->CT2_CCD,TRL->CT2_CCC))
				TRM->(DbGoTop())
				While !TRM->(Eof()) 
					
					nValDebito  := TRM->CT2_VALOR
					
					TRM->(DBSKIP())    
			
				ENDDO
				TRM->(DbCloseArea())
				
				SqlCredit(TRL->CT2_FILKEY,TRL->CT2_PREFIX,TRL->CT2_NUMDOC,TRL->CT2_PARCEL,TRL->CT2_TIPODC,TRL->CT2_CLIFOR,TRL->CT2_LOJACF,TRL->CT2_VALOR,IIF(ALLTRIM(TRL->CT2_CCD) <> '',TRL->CT2_CCD,TRL->CT2_CCC))
				TRN->(DbGoTop())
				While !TRN->(Eof()) 
					
					nValCredit  := TRN->CT2_VALOR
					
					TRN->(DBSKIP())    
			
				ENDDO
				TRN->(DbCloseArea())
				
				TRL->(DBSKIP())    
		
			ENDDO
			TRL->(DbCloseArea())	
			
			IF nValCredit == nValDebito .AND. ;
			   nValCredit  > 0          .AND. ; // 21/12/2018
			   nValDebito  > 0
			
				CONOUT('ADCON012R RECNO RETIRADO :' + CVALTOCHAR(TSE->RECNO_CT2))
				nValDebito  := 0
				nValCredit  := 0
				
				DBSELECTAREA("TSD")
				DBGOTOP()
				DBSETORDER(2)
				IF DBSEEK(TSE->RECNO_CT2, .T.)
				
					RECLOCK("TSD",.F.)
						DBDELETE()
					MSUNLOCK()
					
				ENDIF
				
				nRecno      := 0
			
			ENDIF
			
			nValDebito  := 0
		   	nValCredit  := 0
		   	nRecno      := 0
		   			   	
		    // *** INICIO BUSCA COM DELIMITADOR DE R_E_C_N_O PARA BATER O VALOR *** //			   	
		   	SqlBuscaCt2(TSE->RECNO_CT2)
			TRL->(DbGoTop())
			While !TRL->(Eof())
			
			 	SqlCred2(TRL->CT2_FILKEY,TRL->CT2_PREFIX,TRL->CT2_NUMDOC,TRL->CT2_PARCEL,TRL->CT2_TIPODC,TRL->CT2_CLIFOR,TRL->CT2_LOJACF,TRL->CT2_VALOR,IIF(ALLTRIM(TRL->CT2_CCD) <> '',TRL->CT2_CCD,TRL->CT2_CCC))
				TRR->(DbGoTop())
				While !TRR->(Eof()) 
					
					nValCredit  := TRR->CT2_VALOR
					
					TRR->(DBSKIP())    
			
				ENDDO
				TRR->(DbCloseArea())
				
				//achar o Recno do Ultimo Estorno
				SqlCred3(TRL->CT2_FILKEY,TRL->CT2_PREFIX,TRL->CT2_NUMDOC,TRL->CT2_PARCEL,TRL->CT2_TIPODC,TRL->CT2_CLIFOR,TRL->CT2_LOJACF,TRL->CT2_VALOR,IIF(ALLTRIM(TRL->CT2_CCD) <> '',TRL->CT2_CCD,TRL->CT2_CCC))
				TRP->(DbGoTop())
				While !TRP->(Eof()) 
					
					nRecno  := TRP->RECNO_CT2
					
					TRP->(DBSKIP())    
			
				ENDDO
				TRP->(DbCloseArea())
			
				SqlDeb2(TRL->CT2_FILKEY,TRL->CT2_PREFIX,TRL->CT2_NUMDOC,TRL->CT2_PARCEL,TRL->CT2_TIPODC,TRL->CT2_CLIFOR,TRL->CT2_LOJACF,TRL->CT2_VALOR,IIF(ALLTRIM(TRL->CT2_CCD) <> '',TRL->CT2_CCD,TRL->CT2_CCC),nRecno)
				TRQ->(DbGoTop())
				While !TRQ->(Eof()) 
					
					nValDebito  := TRQ->CT2_VALOR
					
					TRQ->(DBSKIP())    
			
				ENDDO
				TRQ->(DbCloseArea())
				
				TRL->(DBSKIP())    
		
			ENDDO
			TRL->(DbCloseArea())	
			
			IF nValCredit        == nValDebito .AND. ;
			   nValCredit         > 0          .AND. ; // 21/12/2018
			   nValDebito         > 0          .AND. ;
			   TSE->RECNO_CT2    <= nRecno     
			
//				CONOUT('ADCON012R RECNO RETIRADO :' + CVALTOCHAR(TSE->RECNO_CT2))
				nValDebito  := 0
				nValCredit  := 0
				
				DBSELECTAREA("TSD")
				DBGOTOP()
				DBSETORDER(2)
				IF DBSEEK(TSE->RECNO_CT2, .T.)
				
					RECLOCK("TSD",.F.)
						DBDELETE()
					MSUNLOCK()
					
				ENDIF
				
				nRecno      := 0
				
			ENDIF
			
			// *** FINAL BUSCA COM DELIMITADOR DE R_E_C_N_O PARA BATER O VALOR *** //
		   	
		   	nValDebito  := 0
		   	nValCredit  := 0
		   	nRecno      := 0
		   	
		ENDIF
		// *** FINAL PARA EXCECAO DE QUANDO NAO TEM PROJETO E TEM ESTORNO RETIRAR DA PLANILHA REGRA REGINALDO *** // 
		
		TSE->(DBSKIP())    
		
	ENDDO
	
	TSE->(DbCloseArea())
	
	// *** FINAL RETIRAR DUPLICIDADES *** //
	
	// *** INICIO CARREGAR O CAMPO DE PROJETO *** //
	
	SqlTable2() // Sql TRC
	TSE->(DbGoTop())
	While !TSE->(Eof()) 

		cProjeto2 := ''
		IncProc("Carregando Campo Projeto " + TSE->CT2_HIST)
		
		IF UPPER(ALLTRIM(TSE->CT2_TIPODC)) == 'NF'
		
			IF ALLTRIM(TSE->CT2_KEY) <> ''
				
				DBSELECTAREA("CTL")
				DBSETORDER(1)      
				DBGOTOP()			
				IF DBSEEK(FWxFILIAL("CT2")+TSE->CT2_LP, .T.)
				
					DBSELECTAREA(CTL->CTL_ALIAS)
					DBGOTOP()
					DBSETORDER(VAL(CTL->CTL_ORDER))
					
					IF DBSEEK(TSE->CT2_KEY, .T.)		
							
						DBSELECTAREA("TSD")
						DBGOTOP()
						DBSETORDER(2)
						IF DBSEEK(TSE->RECNO_CT2, .T.)
						
							RECLOCK("TSD",.F.)
							
								TSD->D1_COD  := SD1->D1_COD     
								TSD->B1_DESC := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")    
								TSD->A2_NOME := POSICIONE("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")    
								TSD->D1_CC   := SD1->D1_CC      
								TSD->PROJETO := SD1->D1_PROJETO 
								cProjeto2    := SD1->D1_PROJETO 
		
							MSUNLOCK()
							
						ENDIF
					ENDIF
				ENDIF
			 
			ELSE
				
				// *** INICIO PARA CARREGAR O CAMPO DE PROJETOS NA PLANILHA 2 *** //
				lChavedupla := .F.
				SqlChaveBusca(TSE->CT2_FILKEY ,TSE->CT2_NUMDOC,TSE->CT2_PREFIX,TSE->CT2_CLIFOR,TSE->CT2_LOJACF)  
				TRT->(DbGoTop())
				While !TRT->(Eof()) 
				                                                          
					IF lChavedupla == .F.
						
						IF TRT->DUPLICIDADE >= 2
						
							lChavedupla := .T.
							
						ENDIF
					
					ENDIF
					TRT->(DBSKIP())    
					
				ENDDO
				TRT->(DbCloseArea())
				
				// Se nใo tiver duplicidade na chave de produto entra no if se nใo entra no else
				IF lChavedupla == .F.
				
					SqlProd1(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
					TRF->(DbGoTop())
					While !TRF->(Eof()) 
					
						DBSELECTAREA("TSD")
						DBGOTOP()
						DBSETORDER(2)
						IF DBSEEK(TSE->RECNO_CT2, .T.)
						
							RECLOCK("TSD",.F.)
							
								TSD->D1_COD  := TRF->D1_COD     
								TSD->B1_DESC := TRF->B1_DESC    
								TSD->A2_NOME := TRF->A2_NOME    
								TSD->D1_CC   := TRF->D1_CC      
								TSD->PROJETO := TRF->C7_PROJETO 
								cProjeto2    := TRF->C7_PROJETO
		
							MSUNLOCK()
							
						ENDIF
					    
						TRF->(DBSKIP())    
						
					ENDDO
					TRF->(DbCloseArea())
					
					IF ALLTRIM(cProjeto2) == '' 
					
						SqlProd2(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						TRH->(DbGoTop())
						While !TRH->(Eof()) 
						
							DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRH->D1_COD     
									TSD->B1_DESC := TRH->B1_DESC    
									TSD->A2_NOME := TRH->A2_NOME    
									TSD->D1_CC   := TRH->D1_CC      
									TSD->PROJETO := TRH->C7_PROJETO
									cProjeto2    := TRH->C7_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
						                                                          
							TRH->(DBSKIP())    
							
						ENDDO
						TRH->(DbCloseArea())
					
					ENDIF
					
					IF ALLTRIM(cProjeto2) == '' 
					
						SqlProd3(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						TRJ->(DbGoTop())
						While !TRJ->(Eof())
						
						 	DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRJ->D1_COD     
									TSD->B1_DESC := TRJ->B1_DESC    
									TSD->A2_NOME := TRJ->A2_NOME    
									TSD->D1_CC   := TRJ->D1_CC      
									TSD->PROJETO := TRJ->C7_PROJETO
									cProjeto2    := TRJ->C7_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
						    
							TRJ->(DBSKIP())    
							
						ENDDO
						TRJ->(DbCloseArea())
					
					ENDIF
					
					IF ALLTRIM(cProjeto2) == '' 
					
						SqlProd4(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						TRK->(DbGoTop())
						While !TRK->(Eof()) 
						
							DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRK->D1_COD     
									TSD->B1_DESC := TRK->B1_DESC    
									TSD->A2_NOME := TRK->A2_NOME    
									TSD->D1_CC   := TRK->D1_CC      
									TSD->PROJETO := TRK->C7_PROJETO
									cProjeto2    := TRK->C7_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
						    
							TRK->(DBSKIP())    
							
						ENDDO
						TRK->(DbCloseArea())
					
					ENDIF
					
					IF ALLTRIM(cProjeto2) == '' 
					
						SqlProd5(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						TRS->(DbGoTop())
						While !TRS->(Eof()) 
						
							DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRS->D1_COD     
									TSD->B1_DESC := TRS->B1_DESC    
									TSD->A2_NOME := TRS->A2_NOME    
									TSD->D1_CC   := TRS->D1_CC      
									TSD->PROJETO := TRS->C7_PROJETO
									cProjeto2    := TRS->C7_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
						    
							TRS->(DBSKIP())    
							
						ENDDO
						TRS->(DbCloseArea())
					
					ENDIF
					
					// *** INICIO REGRA PARA NOTAS DE DEVOLUCOES *** //
					IF ALLTRIM(cProjeto2)         == ''        .AND. ;
						SUBSTR(TSE->CT2_HIST,1,7) == 'DEV NFE'
					
						SqlDevolucao(TSE->CT2_FILKEY,TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						TRO->(DbGoTop())
						While !TRO->(Eof())
						
							DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRO->D1_COD     
									TSD->B1_DESC := Posicione("SB1",1,xFilial("SB1")+TRO->D1_COD,"B1_DESC")   
									TSD->A2_NOME := ''    
									TSD->D1_CC   := TRO->D1_CC      
									TSD->PROJETO := TRO->D1_PROJETO
									cProjeto2    := TRO->D1_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
						    
							TRO->(DBSKIP())    
							
						ENDDO
						TRO->(DbCloseArea())
					
					ENDIF
					// *** FINAL REGRA PARA NOTAS DE DEVOLUCOES *** //
					
				ELSE //QUANDO A CHAVE DA NOTA E DUPLICADA ACERTAR
				
					lEnviaNota := .T.
					DBSELECTAREA("TRU")
					DBGOTOP()
					IF TRU->(EOF())
					
						lEnviaNota := .T.
					
					ELSE
					
						WHILE TRU->(!EOF())
						
							IF lEnviaNota == .T.
						
								IF TRU->D1_FILIAL  == TSE->CT2_FILKEY .AND. ;
							       TRU->D1_DOC     == TSE->CT2_NUMDOC .AND. ;
							       TRU->D1_SERIE   == TSE->CT2_PREFIX .AND. ;
							       TRU->D1_FORNECE == TSE->CT2_CLIFOR .AND. ;
							       TRU->D1_LOJA    == TSE->CT2_LOJACF 
							       
							       lEnviaNota := .F.
							    
							    ENDIF
							    
						    ENDIF
						    
						    TRU->(DBSKIP())
						    
						ENDDO
					
					ENDIF 
					
					IF lEnviaNota == .T.
						//------------------------------------
						//Executa query para carregar a tabela temporaria do banco
						//------------------------------------
						cQuery := " SELECT FISC.D1_COD, "
						cQuery += "        FISC.D1_FILIAL, "
						cQuery += "        FISC.D1_DOC, "
						cQuery += "        FISC.D1_SERIE, "
						cQuery += "        FISC.D1_FORNECE, "
						cQuery += "        FISC.D1_LOJA, "
						cQuery += "        FISC.R_E_C_N_O_ AS R_E_C_N_O_, "
						cQuery += "        FORN.A2_NOME, " 
						cQuery += "        PROD.B1_DESC, " 
						cQuery += "        FISC.D1_CC, " 
						cQuery += "        FISC.D1_PROJETO, "
						cQuery += "        PED.C7_PROJETO, "
						cQuery += "        FISC.D1_CUSTO, "
						cQuery += "        ROUND(FT_VALCONT-(FT_VALCONT * (FT_ALIQCOF  /100)) - (FT_VALCONT * (FT_ALIQPIS /100)),2,1) AS VALFT1, "
						cQuery += "        FT_VALCONT-FT_VALCOF-FT_VALPIS AS VALFT2, "
						cQuery += "        ROUND(FT_VALCONT-(FT_VALCONT * (FT_ALIQCOF  /100)) - (FT_VALCONT * (FT_ALIQPIS /100)),2) AS VALFT3,     "
						cQuery += "        CONVERT(NUMERIC(17,2),FORMAT(FT_VALCONT-(FT_VALCONT * (FT_ALIQCOF  /100)) - (FT_VALCONT * (FT_ALIQPIS /100)),'#.00')) AS VALFT4 "
						cQuery += " FROM "+ RetSqlName("SD1") + " FISC WITH (NOLOCK) " 
						cQuery += " LEFT JOIN "+ RetSqlName("SA2") + " FORN WITH (NOLOCK) " 
						cQuery += "        ON FORN.A2_FILIAL         = '" + FWFILIAL("SA2") + "' "
						cQuery += "	      AND FORN.A2_COD            = FISC.D1_FORNECE "  
						cQuery += "	      AND FORN.A2_LOJA           = FISC.D1_LOJA "
						cQuery += "	      AND FORN.D_E_L_E_T_       <> '*' "
						cQuery += "	LEFT JOIN "+ RetSqlName("SB1") + " PROD WITH (NOLOCK) " 
						cQuery += "	       ON PROD.B1_FILIAL         = '" + FWFILIAL("SB1") + "' "
						cQuery += "	      AND PROD.B1_COD            = FISC.D1_COD " 
						cQuery += "	      AND PROD.D_E_L_E_T_       <> '*' "
						cQuery += "	LEFT JOIN "+ RetSqlName("SC7") + " PED WITH (NOLOCK) " 
						cQuery += "	       ON PED.C7_FILIAL          = FISC.D1_FILIAL "
						cQuery += "	      AND PED.C7_NUM             = FISC.D1_PEDIDO "
						cQuery += "	      AND PED.C7_FORNECE         = FISC.D1_FORNECE "
						cQuery += "	      AND PED.C7_PRODUTO         = FISC.D1_COD "
						cQuery += "	      AND PED.C7_ITEM            = FISC.D1_ITEMPC "
						cQuery += "	      AND PED.D_E_L_E_T_        <> '*' "
						cQuery += "	LEFT JOIN "+ RetSqlName("SFT") + " SFT WITH (NOLOCK) "
						cQuery += "	       ON FT_FILIAL              = FISC.D1_FILIAL "
						cQuery += "	      AND FT_NFISCAL             = FISC.D1_DOC " 
						cQuery += "	      AND FT_SERIE               = FISC.D1_SERIE "
						cQuery += "	      AND FT_PRODUTO             = FISC.D1_COD "
						cQuery += "	      AND FT_ITEM                = FISC.D1_ITEM "
						cQuery += "	      AND SFT.D_E_L_E_T_        <> '*' "
						cQuery += "	    WHERE FISC.D1_FILIAL         = '" + TSE->CT2_FILKEY + "' " 
						cQuery += "	      AND FISC.D1_DOC            = '" + TSE->CT2_NUMDOC + "' "
						cQuery += "	      AND FISC.D1_SERIE          = '" + TSE->CT2_PREFIX + "' "
						cQuery += "	      AND FISC.D1_FORNECE        = '" + TSE->CT2_CLIFOR + "' "
						cQuery += "	      AND FISC.D1_LOJA           = '" + TSE->CT2_LOJACF + "' "
						cQuery += "	      AND FISC.D_E_L_E_T_       <> '*' " 
						
						//cQuery := "select * from "+ oTempTable:GetRealName()
						
						MPSysOpenQuery( cQuery, 'TRV' )
						
						DbSelectArea('TRV')
						
						WHILE TRV->(!EOF())
						
						    Reclock("TRU",.T.)
						    
						    	TRU->D1_FILIAL  := TRV->D1_FILIAL
						    	TRU->D1_DOC     := TRV->D1_DOC
						    	TRU->D1_SERIE   := TRV->D1_SERIE
						    	TRU->D1_FORNECE := TRV->D1_FORNECE
						    	TRU->D1_LOJA    := TRV->D1_LOJA
						    	TRU->D1_COD     := TRV->D1_COD
						    	TRU->D1_CUSTO   := TRV->D1_CUSTO
						    	TRU->C7_PROJETO := TRV->C7_PROJETO
						    	TRU->D1_PROJETO := TRV->D1_PROJETO
						    	TRU->B1_DESC    := TRV->B1_DESC
						    	TRU->A2_NOME    := TRV->A2_NOME
						    	TRU->D1_CC      := TRV->D1_CC
						    	TRU->VALFT1     := TRV->VALFT1
						    	TRU->VALFT2     := TRV->VALFT2
						    	TRU->VALFT3     := TRV->VALFT3
						    	TRU->VALFT4     := TRV->VALFT4
						    	TRU->SD1RECNO   := TRV->R_E_C_N_O_
						    	
						    TRU->(MSUNLOCK())
						    
						    TRV->(DBSKIP())
						    
						ENDDO
					ENDIF
					
					SqlNota1(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
					
					IF TRX->(!EOF())
					
					    IF ALLTRIM(cProjeto2) == '' 
					    
					    	DBSELECTAREA("TSD")
							DBGOTOP()
							DBSETORDER(2)
							IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRX->D1_COD     
									TSD->B1_DESC := TRX->B1_DESC    
									TSD->A2_NOME := TRX->A2_NOME    
									TSD->D1_CC   := TRX->D1_CC      
									TSD->PROJETO := TRX->C7_PROJETO
									cProjeto2    := TRX->C7_PROJETO 
			
								MSUNLOCK()
								
							ENDIF
							
						   DbSelectArea('TRU')
						   DBSETORDER(1)
						   IF DBSEEK(TRX->SD1RECNO, .T.)
							
						   		Reclock("TRU",.F.)
								
						   			TRU->OK = 'X'
									
							    TRU->(MSUNLOCK())
							    
						   ENDIF
						ENDIF
					ENDIF
					
					IF ALLTRIM(cProjeto2) == ''
					
						SqlNota2(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						
						IF TRZ->(!EOF())
						
						   DBSELECTAREA("TSD")
						   DBGOTOP()
						   DBSETORDER(2)
						   IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TRZ->D1_COD     
									TSD->B1_DESC := TRZ->B1_DESC    
									TSD->A2_NOME := TRZ->A2_NOME    
									TSD->D1_CC   := TRZ->D1_CC      
									TSD->PROJETO := TRZ->C7_PROJETO
									cProjeto2    := TRZ->C7_PROJETO 
			
								MSUNLOCK()
								
						   ENDIF
							
						   DbSelectArea('TRU')
						   DBSETORDER(1)
						   IF DBSEEK(TRZ->SD1RECNO, .T.)
							
						   		Reclock("TRU",.F.)
								
						   			TRU->OK = 'X'
									
							    TRU->(MSUNLOCK())
							    
						   ENDIF
						ENDIF
					ENDIF
					
					IF ALLTRIM(cProjeto2) == ''
					
						SqlNota3(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						
						IF TSA->(!EOF())
					
					       DBSELECTAREA("TSD")
						   DBGOTOP()
						   DBSETORDER(2)
						   IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TSA->D1_COD     
									TSD->B1_DESC := TSA->B1_DESC    
									TSD->A2_NOME := TSA->A2_NOME    
									TSD->D1_CC   := TSA->D1_CC      
									TSD->PROJETO := TSA->C7_PROJETO
									cProjeto2    := TSA->C7_PROJETO 
			
								MSUNLOCK()
								
						   ENDIF
							
						   DbSelectArea('TRU')
						   DBSETORDER(1)
						   IF DBSEEK(TSA->SD1RECNO, .T.)
							
						   		Reclock("TRU",.F.)
								
						   			TRU->OK = 'X'
									
							    TRU->(MSUNLOCK())
							    
						   ENDIF
						ENDIF
					ENDIF
					
					IF ALLTRIM(cProjeto2) == ''
					
						SqlNota4(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						
						IF TSB->(!EOF())
					
					       DBSELECTAREA("TSD")
						   DBGOTOP()
						   DBSETORDER(2)
						   IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TSB->D1_COD     
									TSD->B1_DESC := TSB->B1_DESC    
									TSD->A2_NOME := TSB->A2_NOME    
									TSD->D1_CC   := TSB->D1_CC      
									TSD->PROJETO := TSB->C7_PROJETO
									cProjeto2    := TSB->C7_PROJETO 
			
								MSUNLOCK()
								
						   ENDIF
							
						   DbSelectArea('TRU')
						   DBSETORDER(1)
						   IF DBSEEK(TSB->SD1RECNO, .T.)
							
						   		Reclock("TRU",.F.)
								
						   			TRU->OK = 'X'
									
							    TRU->(MSUNLOCK())
							    
						   ENDIF
						ENDIF
					ENDIF
					
					IF ALLTRIM(cProjeto2) == ''
					
						SqlNota5(TSE->CT2_FILKEY,IIF(ALLTRIM(TSE->CT2_CCD) <> '',TSE->CT2_CCD,TSE->CT2_CCC),TSE->CT2_NUMDOC,TSE->CT2_CLIFOR,TSE->CT2_LOJACF,TSE->CT2_VALOR,TSE->CT2_PREFIX)
						
						IF TSC->(!EOF())
					
					       DBSELECTAREA("TSD")
						   DBGOTOP()
						   DBSETORDER(2)
						   IF DBSEEK(TSE->RECNO_CT2, .T.)
							
								RECLOCK("TSD",.F.)
								
									TSD->D1_COD  := TSC->D1_COD     
									TSD->B1_DESC := TSC->B1_DESC    
									TSD->A2_NOME := TSC->A2_NOME    
									TSD->D1_CC   := TSC->D1_CC      
									TSD->PROJETO := TSC->C7_PROJETO
									cProjeto2    := TSC->C7_PROJETO 
			
								MSUNLOCK()
								
						   ENDIF
						   
						   DbSelectArea('TRU')
						   DBSETORDER(1)
						   IF DBSEEK(TSC->SD1RECNO, .T.)
							
						   		Reclock("TRU",.F.)
								
						   			TRU->OK = 'X'
									
							    TRU->(MSUNLOCK())
							    
						   ENDIF
						ENDIF
					ENDIF
					
				ENDIF
			ENDIF
			
		ELSE
		
			// Carregar o nome do fornecedor quando nใo encontrado nos selects acima
			DBSELECTAREA("TSD")
		    DBGOTOP()
		    DBSETORDER(2)
		    IF DBSEEK(TSE->RECNO_CT2, .T.)
		    
		    	IF ALLTRIM(TSD->A2_NOME) == '' 
			
					RECLOCK("TSD",.F.)
					
						TSD->A2_NOME := POSICIONE("SA2",1,xFilial("SA2")+TSE->CT2_CLIFOR+TSE->CT2_LOJACF,"A2_NOME")
		
					MSUNLOCK()
				
				ENDIF
			ENDIF
			
			IF ALLTRIM(TSE->CT2_LOTE) == '008860' .OR. ;
			   ALLTRIM(TSE->CT2_LOTE) == '008890' 
			   
			    DBSELECTAREA("TSD")
			    DBGOTOP()
			    DBSETORDER(2)
			    IF DBSEEK(TSE->RECNO_CT2, .T.)
				
					RECLOCK("TSD",.F.)
					
						TSD->CT2_FILKEY := TSE->CT2_FILKEY // 15 O	
						TSD->CT2_NUMDOC := '999999'        // 16 P
						TSD->CT2_CLIFOR := '002922'        // 17 Q
						TSD->CT2_LOJACF := '01'            // 18 R
						TSD->D1_COD     := '999999'        // 19 S
						TSD->B1_DESC    := 'M_OBRA'        // 20 T
						TSD->A2_NOME    := "AD'ORO S/A"    // 21 U
					
					MSUNLOCK()
					
			    ENDIF
			   					
			ENDIF
			
			IF ALLTRIM(TSE->CT2_LOTE) == '008840' .OR. ;
			   ALLTRIM(TSE->CT2_LOTE) == '999999' 
			   
			   	cCodProd    := ''
			   	cDescProd   := ''
			   	cDocReq     := ''
			   	cProjeto    := ''
			   	cCusto      := ''
			   	cItemContab := ''
		        cFilAtu     := ''
			   	cCodProd    := RIGHT(ALLTRIM(TSE->CT2_HIST),6)
			   	cDescProd   := Posicione("SB1",1,xFilial("SB1")+RIGHT(ALLTRIM(TSE->CT2_HIST),6),"B1_DESC")
			   	cDocReq     := ALLTRIM(SUBSTRING(RIGHT(ALLTRIM(TSE->CT2_HIST),16),1,AT('/',RIGHT(ALLTRIM(TSE->CT2_HIST),16))-1))
			   	cItemContab := ALLTRIM(IIF(ALLTRIM(TSE->CT2_ITEMD) <> '',TSE->CT2_ITEMD,TSE->CT2_ITEMC))
		        cFilAtu     := ''
		        
		        DO CASE
		        
					CASE cItemContab == '111'
					    cFilAtu := '03'
					CASE cItemContab == '112'
					    cFilAtu := '04'
					CASE cItemContab == '113'
					    cFilAtu := '03'
					CASE cItemContab == '114'
					    cFilAtu := '03'
					CASE cItemContab == '115'
					    cFilAtu := '02'
					CASE cItemContab == '121'
					    cFilAtu := '02'                
					OTHERWISE
						cFilAtu := ''
						
				ENDCASE
			   	
			   	SqlSD3(cFilAtu,cDocReq,cCodProd) 
			   	TRG->(DbGoTop())
				While !TRG->(Eof()) 
				                                                          
					cProjeto := IIF(EMPTY(TRG->D3_PROJETO),TRG->CP_CONPRJ,TRG->D3_PROJETO)
					cCusto   := TRG->D3_CC
					
					IF EMPTY(cProjeto)
					
						SqlSCP(cFilAtu,TRG->D3_NUMSEQ)
						TRI->(DbGoTop())
						While !TRI->(Eof()) 
							cProjeto := TRI->CP_CONPRJ
							
							TRI->(DBSKIP())    
					
						ENDDO
						TRI->(DbCloseArea())	
						
					ENDIF
					
					TRG->(DBSKIP())    
					
				ENDDO
				TRG->(DbCloseArea())
				
				DBSELECTAREA("TSD")
			    DBGOTOP()
			    DBSETORDER(2)
			    IF DBSEEK(TSE->RECNO_CT2, .T.)
				
					RECLOCK("TSD",.F.)
					
						TSD->CT2_FILKEY := cFilAtu      // 15 O	
						TSD->CT2_NUMDOC := "999999"     // 16 P
						TSD->CT2_CLIFOR := "002922"     // 17 Q
						TSD->CT2_LOJACF := "01"         // 18 R
						TSD->D1_COD     := cCodProd     // 19 S
						TSD->B1_DESC    := cDescProd    // 20 T
						TSD->A2_NOME    := "AD'ORO S/A" // 21 U
						TSD->D1_CC      := cCusto       // 22 V
						TSD->PROJETO    := cProjeto     // 23 X
						
					MSUNLOCK()
					
			    ENDIF
						
			ENDIF
			
			IF ALLTRIM(TSE->CT2_DEBITO) == '131210010' .OR. ;
			   ALLTRIM(TSE->CT2_CREDIT) == '131210010'
	
				IF ALLTRIM(TSE->CT2_CCD) <> ''
				
					DBSELECTAREA("TSD")
				    DBGOTOP()
				    DBSETORDER(2)
				    IF DBSEEK(TSE->RECNO_CT2, .T.)
					
						RECLOCK("TSD",.F.)
						
							TSD->D1_CC      := TSE->CT2_CCD    // 22 V
							
						MSUNLOCK()
						
				    ENDIF
				
				ELSE
			
					DBSELECTAREA("TSD")
				    DBGOTOP()
				    DBSETORDER(2)
				    IF DBSEEK(TSE->RECNO_CT2, .T.)
					
						RECLOCK("TSD",.F.)
						
							TSD->D1_CC      := TSE->CT2_CCC    // 22 V
							
						MSUNLOCK()
						
				    ENDIF
					
				ENDIF
			ENDIF
		ENDIF
		// *** FINAL PARA CARREGAR O CAMPO DE PROJETOS NA PLANILHA 2 *** //
		
		TSE->(DBSKIP())    
		
	ENDDO
	
	TSE->(DbCloseArea())
	
	// *** FINAL CARREGAR O CAMPO DE PROJETO *** //
	
	// *** INICIO ENVIA PARA O VETOR DO EXCEL *** //
	nLinha := 0
	SqlTable2() // Sql TSE
	TSE->(DbGoTop())
	While !TSE->(Eof())
	
		IncProc("CT2_Replica " + TSE->CT2_HIST)
		
		nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLin2,{ "", ; // 01 A  
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
					 "", ; // 23 X
					 ""  ; // 24 W // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
	   	                })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		//CT2_Replica
		aLin2[nLinha][01] := TSE->CT2_DATA                                                                           // 01 A	
		aLin2[nLinha][02] := STOD(TSE->CT2_DATA)                                                                     // 02 B
		aLin2[nLinha][03] := TSE->CT2_LOTE                                                                           // 03 C
		aLin2[nLinha][04] := TSE->CT2_DOC                                                                            // 04 D
		aLin2[nLinha][05] := TSE->CT2_LINHA                                                                          // 05 E
		aLin2[nLinha][06] := TSE->CT2_DEBITO                                                                         // 06 F
		aLin2[nLinha][07] := TSE->CT2_CREDIT                                                                         // 07 G
		aLin2[nLinha][08] := IIF(ALLTRIM(TSE->CT2_CREDIT) == '131210010',TSE->CT2_VALOR *(-1),TSE->CT2_VALOR)        // 08 H
		aLin2[nLinha][09] := TSE->CT2_HIST                                                                           // 09 I
		aLin2[nLinha][10] := TSE->CT2_CCD                                                                            // 10 J
		aLin2[nLinha][11] := TSE->CT2_CCC                                                                            // 11 K
		aLin2[nLinha][12] := TSE->CT2_ITEMD                                                                          // 12 L
		aLin2[nLinha][13] := TSE->CT2_ITEMC                                                                          // 13 M
		aLin2[nLinha][14] := TSE->RECNO_CT2                                                                          // 14 N
		aLin2[nLinha][15] := TSE->CT2_FILKEY                                                                         // 15 O	
		aLin2[nLinha][16] := TSE->CT2_NUMDOC                                                                         // 16 P
		aLin2[nLinha][17] := TSE->CT2_CLIFOR                                                                         // 17 Q
		aLin2[nLinha][18] := TSE->CT2_LOJACF                                                                         // 18 R
		aLin2[nLinha][19] := TSE->D1_COD                                                                             // 19 S
		aLin2[nLinha][20] := TSE->B1_DESC                                                                            // 20 T
		aLin2[nLinha][21] := TSE->A2_NOME                                                                            // 21 U
		aLin2[nLinha][22] := TSE->D1_CC                                                                              // 22 V
		aLin2[nLinha][23] := IIF(ALLTRIM(TSE->PROJETO) <> '',TSE->PROJETO,'Outros  (Engenharia + Lan็amento Manual)') + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+TSE->PROJETO,"AF8_DESCRI")    // 23 W
		aLin2[nLinha][24] := Posicione("AF8",1,FWxFilial("AF8")+TSE->PROJETO,"AF8_XGRUPO")    // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
		
		// *** INICIO CARREGA CAMPOS PARA A PLANILHA BASE *** //
		IF ALLTRIM(TSE->CT2_DATA) <> '' 
		
		   IncProc("Criando Dado para a Planilha3: " + TSE->CT2_HIST)
		   
		   cItem2  := ''
	       cConta2 := ''
	       cCusto2 := ''
	       nValor2 := ''
		   nLin3   := nLin3 + 1
		   
		   Aadd(aLin3,{ "", ; // 01 A  
	   	                "", ; // 02 B   
	   	                "", ; // 03 C  
	   	                "", ; // 04 D  
	   	                "", ; // 05 E  
	   	                "", ; // 06 F   
	   	                "", ; // 07 G  
	   	                "", ; // 08 H  
	   	                "", ; // 09 I  
						"", ; // 10 J   
						""  ; // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019 
	   	                  })
		   	                  
		   	IF TSE->CT2_CCD >= '9000' .AND. ;
		   	   TSE->CT2_CCD <= '9999'
		   	
			   	cItem2  := TSE->CT2_ITEMD
		        cConta2 := TSE->CT2_DEBITO
		        cCusto2 := TSE->CT2_CCD
		        nValor2 := IIF(ALLTRIM(TSE->CT2_CREDIT) == '131210010',TSE->CT2_VALOR *(-1),TSE->CT2_VALOR) * (1)
		    
		    ENDIF                 
		    
		    IF TSE->CT2_CCC >= '9000' .AND. ;
		   	   TSE->CT2_CCC <= '9999'
		   	
			   	cItem2  := TSE->CT2_ITEMC
		        cConta2 := TSE->CT2_CREDIT
		        cCusto2 := TSE->CT2_CCC
		        nValor2 := IIF(ALLTRIM(TSE->CT2_CREDIT) == '131210010',TSE->CT2_VALOR *(-1),TSE->CT2_VALOR)
		    
		    ENDIF
		    
	   		// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
            /*
		    DO CASE
	        
				CASE TSE->CT2_FILKEY   == '01'
				    cNomeFilial := 'MT'
				CASE TSE->CT2_FILKEY   == '02'
				    cNomeFilial := 'VP'
				CASE TSE->CT2_FILKEY   == '03'
				    cNomeFilial := 'SC'
				CASE TSE->CT2_FILKEY   == '04'
				    cNomeFilial := 'RC'
				CASE TSE->CT2_FILKEY   == '05'
				    cNomeFilial := 'FR'
				CASE TSE->CT2_FILKEY   == '06'
				    cNomeFilial := 'IT'
				CASE TSE->CT2_FILKEY   == '07'
				    cNomeFilial := 'LO'
				CASE TSE->CT2_FILKEY   == '08'
				    cNomeFilial := 'GO'
				CASE TSE->CT2_FILKEY   == '09'
				    cNomeFilial := 'RC2'                            
				OTHERWISE
					cNomeFilial := ''
					
			ENDCASE
			*/
		    
		    //Base

			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][01] := cNomeFilial                                                                 // 01 A	
			aLin3[nLin3][01] := UpBase( "1", AllTrim(cItem2) )                                            // 01 A	
			//

			aLin3[nLin3][02] := cItem2                                                                               // 02 B
			aLin3[nLin3][03] := cCusto2                                                                              // 03 C
			aLin3[nLin3][04] := cConta2                                                                              // 04 D
			aLin3[nLin3][05] := TSE->CT2_CLIFOR + '-' + TSE->CT2_LOJACF + '-' + TSE->A2_NOME                         // 05 E
			aLin3[nLin3][06] := TSE->D1_COD + '-' + TSE->B1_DESC                                                     // 06 F
			aLin3[nLin3][07] := nValor2                                                                              // 07 G
			aLin3[nLin3][08] := TSE->CT2_DATA                                                                        // 08 H
			aLin3[nLin3][09] := TSE->CT2_HIST                                                                        // 09 I

			// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
			//aLin3[nLin3][10] := TSE->PROJETO + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+TSE->PROJETO,"AF8_DESCRI") // 10 J
			// Tipo, CC, Projeto
			aLin3[nLin3][10] := UpBase( "2", AllTrim(cCusto2), AllTrim(TSE->PROJETO) )                                            // 10 J
			If AllTrim(aLin3[nLin3][10]) <> "ENGENHARIA" .and. AllTrim(aLin3[nLin3][10]) <> "IMOBILIZADO" 
				aLin3[nLin3][10] := aLin3[nLin3][10] + ' - ' + Posicione("AF8",1,FWxFilial("AF8")+aLin3[nLin3][10],"AF8_DESCRI")
			EndIf
			//

			aLin3[nLin3][11] := Posicione("AF8",1,FWxFilial("AF8")+SUBSTR(aLin3[nLin3][10],1,AT(' ',aLin3[nLin3][10])-1),"AF8_XGRUPO")  // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
		   
		ENDIF                                                                 
				
		TSE->(DBSKIP())    
		
	ENDDO
	
	TSE->(DbCloseArea())
	// *** FINAL ENVIA PARA O VETOR DO EXCEL *** //
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
	
		IncProc("Carregando Dados para a Planilha2 de: " + cValtochar(nExcel) + ' at้: ' + cValtochar(nLinha))
		
		
   		oExcel:AddRow(cPlan2,cTit2,{aLin2[nExcel][01],;  // 01 A  
								    aLin2[nExcel][02],;  // 02 B  
								    aLin2[nExcel][03],;  // 03 C  
								    aLin2[nExcel][04],;  // 04 D  
								    aLin2[nExcel][05],;  // 05 E  
								    aLin2[nExcel][06],;  // 06 F  
								    aLin2[nExcel][07],;  // 07 G  
								    aLin2[nExcel][08],;  // 08 H  
								    aLin2[nExcel][09],;  // 09 I  
								    aLin2[nExcel][10],;  // 10 J  
								    aLin2[nExcel][11],;  // 11 K  
								    aLin2[nExcel][12],;  // 12 L  
								    aLin2[nExcel][13],;  // 13 M  
								    aLin2[nExcel][14],;  // 14 N 
								    aLin2[nExcel][15],;  // 15 O  
								    aLin2[nExcel][16],;  // 16 P  
								    aLin2[nExcel][17],;  // 17 Q  
								    aLin2[nExcel][18],;  // 18 R  
								    aLin2[nExcel][19],;  // 19 S
								    aLin2[nExcel][20],;  // 20 T  
								    aLin2[nExcel][21],;  // 21 U  
								    aLin2[nExcel][22],;  // 22 V  
									aLin2[nExcel][23],;  // 23 W
									aLin2[nExcel][24] ;  // 24 X // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019
								                             }) 	
													      	 			
    Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	//FINAL PLANILHA 2
 	
 	// INICIO PLANILHA 3
 	
 	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLin3
	
		IncProc("Carregando Dados para a Planilha3 de: " + cValtochar(nExcel) + ' at้: ' + cValtochar(nLin3))
		
   		oExcel:AddRow(cPlan3,cTit3,{aLin3[nExcel][01],;  // 01 A  
								    aLin3[nExcel][02],;  // 02 B  
								    aLin3[nExcel][03],;  // 03 C  
								    aLin3[nExcel][04],;  // 04 D  
								    aLin3[nExcel][05],;  // 05 E  
								    aLin3[nExcel][06],;  // 06 F  
								    aLin3[nExcel][07],;  // 07 G  
								    aLin3[nExcel][08],;  // 08 H  
								    aLin3[nExcel][09],;  // 09 I  
									aLin3[nExcel][10],;  // 10 J  
									aLin3[nExcel][11] ;  // 11 K // 051771 || OS 053094 || CONTROLADORIA || LUIZ || 8465 || AF8_XGRUPO - WILLIAM COSTA - 13/09/2019 
                                                     }) 	
													      	 			
    Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	// FINAL PLANILHA 3
 	
 	// *** INICIO PLANILHA 4 *** //
 	nLinha := 0
	SqlTable4() // Sql TSE
	TSF->(DbGoTop())
	While !TSF->(Eof()) 
	
		IncProc("Planilha 4 " + TSF->CT2_HIST)     
					 
	    nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLin4,{ "", ; // 01 A  
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
	   	             ""  ; // 23 X
	   	                })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		//CT2_Replica_COM DUPLICIDADE
		aLin4[nLinha][01] := TSF->CT2_DATA                                                                    // 01 A	
		aLin4[nLinha][02] := STOD(TSF->CT2_DATA)                                                              // 02 B
		aLin4[nLinha][03] := TSF->CT2_LOTE                                                                    // 03 C
		aLin4[nLinha][04] := TSF->CT2_DOC                                                                     // 04 D
		aLin4[nLinha][05] := TSF->CT2_LINHA                                                                   // 05 E
		aLin4[nLinha][06] := TSF->CT2_DEBITO                                                                  // 06 F
		aLin4[nLinha][07] := TSF->CT2_CREDIT                                                                  // 07 G
		aLin4[nLinha][08] := IIF(ALLTRIM(TSF->CT2_CREDIT) == '131210010',TSF->CT2_VALOR *(-1),TSF->CT2_VALOR) // 08 H
		aLin4[nLinha][09] := TSF->CT2_HIST                                                                    // 09 I
		aLin4[nLinha][10] := TSF->CT2_CCD                                                                     // 10 J
		aLin4[nLinha][11] := TSF->CT2_CCC                                                                     // 11 K
		aLin4[nLinha][12] := TSF->CT2_ITEMD                                                                   // 12 L
		aLin4[nLinha][13] := TSF->CT2_ITEMC                                                                   // 13 M
		aLin4[nLinha][14] := TSF->RECNO_CT2                                                                   // 14 N
		aLin4[nLinha][15] := TSF->CT2_FILKEY                                                                  // 15 O	
		aLin4[nLinha][16] := TSF->CT2_NUMDOC                                                                  // 16 P
		aLin4[nLinha][17] := TSF->CT2_CLIFOR                                                                  // 17 Q
		aLin4[nLinha][18] := TSF->CT2_LOJACF                                                                  // 18 R
		aLin4[nLinha][19] := TSF->D1_COD                                                                      // 19 S
		aLin4[nLinha][20] := TSF->B1_DESC                                                                     // 20 T
		aLin4[nLinha][21] := TSF->A2_NOME                                                                     // 21 U
		aLin4[nLinha][22] := TSF->D1_CC                                                                       // 22 V
		aLin4[nLinha][23] := TSF->PROJETO    															      // 23 W
				
		TSF->(DBSKIP())    
		
	ENDDO
	
	TSF->(DbCloseArea())
	// *** FINAL ENVIA PARA O VETOR DO EXCEL *** //
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
	
		IncProc("Carregando Dados para a Planilha4 de: " + cValtochar(nExcel) + ' at้: ' + cValtochar(nLinha))
		
   		oExcel:AddRow(cPlan4,cTit4,{aLin4[nExcel][01],;  // 01 A  
								    aLin4[nExcel][02],;  // 02 B  
								    aLin4[nExcel][03],;  // 03 C  
								    aLin4[nExcel][04],;  // 04 D  
								    aLin4[nExcel][05],;  // 05 E  
								    aLin4[nExcel][06],;  // 06 F  
								    aLin4[nExcel][07],;  // 07 G  
								    aLin4[nExcel][08],;  // 08 H  
								    aLin4[nExcel][09],;  // 09 I  
								    aLin4[nExcel][10],;  // 10 J  
								    aLin4[nExcel][11],;  // 11 K  
								    aLin4[nExcel][12],;  // 12 L  
								    aLin4[nExcel][13],;  // 13 M  
								    aLin4[nExcel][14],;  // 14 N 
								    aLin4[nExcel][15],;  // 15 O  
								    aLin4[nExcel][16],;  // 16 P  
								    aLin4[nExcel][17],;  // 17 Q  
								    aLin4[nExcel][18],;  // 18 R  
								    aLin4[nExcel][19],;  // 19 S
								    aLin4[nExcel][20],;  // 20 T  
								    aLin4[nExcel][21],;  // 21 U  
								    aLin4[nExcel][22],;  // 22 V  
								    aLin4[nExcel][23] ;  // 23 W
								                             }) 	
													      	 			
    Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
 	//FINAL PLANILHA 4
 	
 	//---------------------------------
	//Exclui a tabela
	//---------------------------------
	oTempTable:Delete()
	oTable2:Delete()
 	
Return(.T.)  

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_INVESTIMENTO.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_INVESTIMENTO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	    := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data de  ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Ate ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	
    Pergunte(cPerg,.F.)
	
Return Nil                                 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCON012R บAutor  ณMicrosiga           บ Data ณ  08/26/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SqlAtivo()   

	Local cDtIni  := DTOS(MV_PAR01) 
	Local cDtFin  := DTOS(MV_PAR02)
	Local cFilSA2 := FWFILIAL("SA2")
	Local cWhere   := ''
	Local cContaAt := ''

	// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
//	cContaAt := GetMv("MV_#CTATIV" ,, '131270003')                                                                           
	cContaAt := GetMv("MV_#CTATIV" ,, "131270003|131210004|131210005|131210006|131210007|131210009|131240002")
	// 
	
	// 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
	//cWhere  := "%" + "DET.N3_CCONTAB  IN ('" + ALLTRIM(cContaAt) + "')" + "%"
	cWhere  := "%" + "DET.N3_CCONTAB IN " + FormatIn(cContaAt, "|") + "%"
	//  

	BeginSQL Alias "TRB"
		     %NoPARSER% 
		     	 SELECT CAB.N1_FILIAL, 
						CAB.N1_CBASE, 
						DET.N3_AQUISIC, 
						CAB.N1_CHAPA, 
						CAB.N1_FORNEC, 
						CAB.N1_LOJA,
						FORN.A2_NOME,
						CAB.N1_NSERIE, 
						CAB.N1_NFISCAL, 
						CAB.N1_DESCRIC,
						CAB.N1_PRODUTO,
						DET.N3_DTBAIXA,
						DET.N3_CCONTAB, 
						DET.N3_CUSTBEM, 
						DET.N3_CCUSTO, 
						DET.N3_VORIG1,
						CAB.R_E_C_N_O_ AS 'R_E_C_1',
						DET.R_E_C_N_O_ AS 'R_E_C_2',
						DET.N3_ITEM,
						DET.N3_SUBCTA // Chamado n. 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465 || REL_INVESTIMENTO - fwnm - 26/08/2019
				   FROM %Table:SN3% DET WITH (NOLOCK)
				LEFT JOIN %Table:SN1% CAB WITH (NOLOCK) 
				      ON CAB.N1_FILIAL    = DET.N3_FILIAL
					 AND CAB.N1_CBASE     = DET.N3_CBASE
					 AND CAB.N1_ITEM      = DET.N3_ITEM
					 //AND CAB.N1_AQUISIC   = DET.N3_AQUISIC
					 AND CAB.D_E_L_E_T_  <> '*'
				LEFT JOIN %Table:SA2% FORN WITH (NOLOCK) 
				      ON FORN.A2_FILIAL   = %EXP:cFilSA2%
				     AND FORN.A2_COD      = CAB.N1_FORNEC
					 AND FORN.A2_LOJA     = CAB.N1_LOJA
					 AND FORN.D_E_L_E_T_ <> '*'
				   WHERE (DET.N3_AQUISIC >= %EXP:cDtIni%
				     AND DET.N3_AQUISIC  <= %EXP:cDtFin%
					  OR DET.N3_DTBAIXA  >= %EXP:cDtIni% 
					 AND DET.N3_DTBAIXA  <= %EXP:cDtFin%)
					 //AND DET.N3_CCONTAB   = '131270003'
					 AND %EXP:cWhere%
					 AND DET.D_E_L_E_T_  <> '*'
		     
	EndSQl

Return (NIL)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADCON012R บAutor  ณMicrosiga           บ Data ณ  08/26/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SqlCT2_SIG()   

	Local cDtIni  := DTOS(MV_PAR01) 
	Local cDtFin  := DTOS(MV_PAR02)
	Local cFilCT2 := FWFILIAL("CT2")

	BeginSQL Alias "TRC"
		     %NoPARSER%
		     SELECT CT2_DATA,
					CT2_LOTE,
					CT2_SBLOTE,
					CT2_DOC,
					CT2_LINHA,
					CT2_DEBITO,
					CT2_CREDIT,
					CT2_CCD,
					CT2_CCC,
					CT2_ITEMD,
					CT2_ITEMC,
					CT2_VALOR,
					CT2_HIST,
					R_E_C_N_O_,
					CT2_FILKEY,
					CT2_PREFIX,
					CT2_NUMDOC,
					CT2_PARCEL,
					CT2_TIPODC,
					CT2_CLIFOR,
					CT2_LOJACF
			   FROM [VPSRV03].[SIG].[dbo].[CT2010] WITH (NOLOCK)
			  WHERE CT2_FILIAL   = %EXP:cFilCT2%
			    AND CT2_DATA    >= %EXP:cDtIni%
				AND CT2_DATA    <= %EXP:cDtFin%
				AND (CT2_DEBITO  = '131210010' 
				 OR CT2_CREDIT   = '131210010')
				AND (CT2_CCD BETWEEN '9000' AND '9999' 
				 OR CT2_CCC  BETWEEN '9000' AND '9999')
			    AND D_E_L_E_T_  <> '*' 
			    
			ORDER BY R_E_C_N_O_
		     		     
	EndSQl

Return (NIL)

// DEBUG - VOLTAR!

Static Function SqlProj1(cFilialAtual,cDoc,cFornec,cLoja,nValor,cSerie)   

	BeginSQL Alias "TRD"
		     %NoPARSER%
		   SELECT PED.C7_PROJETO, 
		           PED.C7_NUM,
				   FISC.D1_CUSTO, 
			       FISC.D1_LOJA,
			       FISC.D1_PROJETO
		      FROM %TABLE:SD1% FISC WITH (NOLOCK) 
		LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
		       ON PED.C7_FILIAL           = FISC.D1_FILIAL
			  AND PED.C7_NUM              = FISC.D1_PEDIDO
			  AND PED.C7_FORNECE          = FISC.D1_FORNECE
			  AND PED.C7_PRODUTO          = FISC.D1_COD
			  AND PED.C7_ITEM             = FISC.D1_ITEMPC
			  AND PED.D_E_L_E_T_         <> '*'
		    WHERE FISC.D1_FILIAL          = %EXP:cFilialAtual%
		      AND FISC.D1_DOC             = %EXP:cDoc%
		      AND FISC.D1_SERIE           = %EXP:cSerie%
			  AND FISC.D1_FORNECE         = %EXP:cFornec%
			  AND FISC.D1_LOJA            = %EXP:cLoja%
		      AND ROUND(FISC.D1_CUSTO,2)  = %EXP:nValor%
			  AND FISC.D_E_L_E_T_        <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlProj2(cFilialAtual,cDoc,cFornec,cLoja,nValor,cSerie)  

	BeginSQL Alias "TRE"
		     %NoPARSER%
		     SELECT TOP(1) PED.C7_PROJETO, 
				           PED.C7_NUM,
						   FISC.D1_CUSTO, 
					       FISC.D1_LOJA,
				           FISC.D1_PROJETO
				      FROM %TABLE:SD1% FISC WITH (NOLOCK) 
				LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
				       ON PED.C7_FILIAL     = FISC.D1_FILIAL
					  AND PED.C7_NUM        = FISC.D1_PEDIDO
					  AND PED.C7_FORNECE    = FISC.D1_FORNECE
					  AND PED.C7_PRODUTO    = FISC.D1_COD
					  AND PED.C7_ITEM       = FISC.D1_ITEMPC
					  AND PED.D_E_L_E_T_   <> '*'
				    WHERE FISC.D1_FILIAL    = %EXP:cFilialAtual%
				      AND FISC.D1_DOC       = %EXP:cDoc%
				      AND FISC.D1_SERIE     = %EXP:cSerie%
					  AND FISC.D1_FORNECE   = %EXP:cFornec%
					  AND FISC.D1_LOJA      = %EXP:cLoja%
				      AND FISC.D_E_L_E_T_  <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlProd1(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRF"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL         = %EXP:cFilSA2%
				  AND FORN.A2_COD            = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA           = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL         = %EXP:cFilSB1%
				 AND PROD.B1_COD            = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL          = FISC.D1_FILIAL
				 AND PED.C7_NUM             = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE         = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO         = FISC.D1_COD
				 AND PED.C7_ITEM            = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_        <> '*'
			   WHERE FISC.D1_FILIAL         = %EXP:cFilialAtual%
			     AND FISC.D1_CC             = %EXP:cCC%
				 AND FISC.D1_DOC            = %EXP:cDoc%
				 AND FISC.D1_SERIE          = %EXP:cSerie%
				 AND FISC.D1_FORNECE        = %EXP:cFornec%
				 AND FISC.D1_LOJA           = %EXP:cLoja%
			     AND FISC.D1_CUSTO          = %EXP:nValor%
				 AND FISC.D_E_L_E_T_       <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlRequisicao(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRF"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL        = %EXP:cFilSA2%
				  AND FORN.A2_COD           = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA          = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_      <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL         = %EXP:cFilSB1%
				 AND PROD.B1_COD            = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL          = FISC.D1_FILIAL
				 AND PED.C7_NUM             = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE         = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO         = FISC.D1_COD
				 AND PED.C7_ITEM            = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_        <> '*'
			   WHERE FISC.D1_FILIAL         = %EXP:cFilialAtual%
			     AND FISC.D1_CC             = %EXP:cCC%
				 AND FISC.D1_DOC            = %EXP:cDoc%
				 AND FISC.D1_FORNECE        = %EXP:cFornec%
				 AND FISC.D1_LOJA           = %EXP:cLoja%
			     AND FISC.D1_CUSTO          = %EXP:nValor%
				 AND FISC.D_E_L_E_T_       <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlSD3(cFilAtu,cReq,cProd)  

	BeginSQL Alias "TRG"
		     %NoPARSER%
		        SELECT REQ.D3_PROJETO, 
				       REQ.D3_CC,
				       REQ.D3_NUMSEQ,
		               SCP.CP_CONPRJ
				  FROM %TABLE:SD3% REQ WITH (NOLOCK)
				  LEFT JOIN SCP010 SCP WITH (NOLOCK)
	                     ON CP_FILIAL       = D3_FILIAL
		                AND (CP_NUM         = D3_DOC
		                 OR CP_XDOC         =  D3_DOC)
		                AND CP_PRODUTO      = D3_COD
		                AND SCP.D_E_L_E_T_ <> '*'
				      WHERE REQ.D3_FILIAL   = %EXP:cFilAtu% 
				        AND REQ.D3_DOC      = %EXP:cReq%
						AND REQ.D3_COD      = %EXP:cProd%
				        AND REQ.D_E_L_E_T_ <> '*'
		       
	EndSQl

Return (NIL)

Static Function SqlProd2(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRH"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL         = %EXP:cFilSA2%
				  AND FORN.A2_COD            = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA           = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL         = %EXP:cFilSB1%
				 AND PROD.B1_COD            = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL          = FISC.D1_FILIAL
				 AND PED.C7_NUM             = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE         = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO         = FISC.D1_COD
				 AND PED.C7_ITEM            = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_        <> '*'
			   WHERE FISC.D1_FILIAL         = %EXP:cFilialAtual%
			     AND FISC.D1_DOC            = %EXP:cDoc%
			     AND FISC.D1_SERIE          = %EXP:cSerie%
				 AND FISC.D1_FORNECE        = %EXP:cFornec%
				 AND FISC.D1_LOJA           = %EXP:cLoja%
			     AND FISC.D1_CUSTO          = %EXP:nValor%
				 AND FISC.D_E_L_E_T_       <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlSCP(cFilAtu,cNumSeq)  

	BeginSQL Alias "TRI"
		     %NoPARSER%
		        SELECT SCP.CP_CONPRJ 
				  FROM %TABLE:SCQ% SCQ
				LEFT JOIN %TABLE:SCP% SCP
					   ON CP_FILIAL       = CQ_FILIAL
					  AND CP_NUM          = CQ_NUM
					  AND CP_PRODUTO      = CQ_PRODUTO
					  AND SCP.D_E_L_E_T_ <> '*'
				    WHERE CQ_FILIAL       = %EXP:cFilAtu%
					  AND CQ_NUMREQ       = %EXP:cNumSeq%
					  AND SCQ.D_E_L_E_T_ <> '*'
	          
	EndSQl

Return (NIL)

Static Function SqlProd3(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRJ"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL         = %EXP:cFilSA2%
				  AND FORN.A2_COD            = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA           = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL         = %EXP:cFilSB1%
				 AND PROD.B1_COD            = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL          = FISC.D1_FILIAL
				 AND PED.C7_NUM             = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE         = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO         = FISC.D1_COD
				 AND PED.C7_ITEM            = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_        <> '*'
			   WHERE FISC.D1_FILIAL         = %EXP:cFilialAtual%
			     AND FISC.D1_CC             = %EXP:cCC%
				 AND FISC.D1_DOC            = %EXP:cDoc%
				 AND FISC.D1_SERIE          = %EXP:cSerie%
				 AND FISC.D1_FORNECE        = %EXP:cFornec%
				 AND FISC.D1_LOJA           = %EXP:cLoja%
			     AND FISC.D1_TOTAL          = %EXP:nValor%
				 AND FISC.D_E_L_E_T_       <> '*' 
		     		     
	EndSQl

Return (NIL)


Static Function SqlProd4(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRK"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL         = %EXP:cFilSA2%
				  AND FORN.A2_COD            = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA           = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL         = %EXP:cFilSB1%
				 AND PROD.B1_COD            = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_       <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL          = FISC.D1_FILIAL
				 AND PED.C7_NUM             = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE         = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO         = FISC.D1_COD
				 AND PED.C7_ITEM            = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_        <> '*'
			   WHERE FISC.D1_FILIAL         = %EXP:cFilialAtual%
			     AND FISC.D1_CC             = %EXP:cCC%
				 AND FISC.D1_DOC            = %EXP:cDoc%
				 AND FISC.D1_SERIE          = %EXP:cSerie%
				 AND FISC.D1_FORNECE        = %EXP:cFornec%
				 AND FISC.D1_LOJA           = %EXP:cLoja%
				 AND (FISC.D1_TOTAL + FISC.D1_DESPESA + FISC.D1_VALFRE)  = %EXP:nValor%
			     AND FISC.D_E_L_E_T_       <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlBuscaCt2(nRecno)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT CT2_FILKEY,  " 
	cQuery1 += "         CT2_PREFIX,  "
	cQuery1 += "         CT2_NUMDOC,  "
	cQuery1 += "         CT2_PARCEL,  "
	cQuery1 += "         CT2_TIPODC,  "
	cQuery1 += "         CT2_CLIFOR,  "
	cQuery1 += "         CT2_LOJACF,  "
	cQuery1 += "         D_E_L_E_T_,  "
	cQuery1 += "         CT2_VALOR,  "
	cQuery1 += "         CT2_CCC,  "
	cQuery1 += "         CT2_CCD  "
	cQuery1 += "    FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE RECNO_CT2 = " + CVALTOCHAR(nRecno)
			 
	MPSysOpenQuery( cQuery1, 'TRL' )  

Return (NIL)

Static Function SqlDebito(cFILKEY,cPREFIX,cNUMDOC,cPARCEL,cTIPODC,cCLIFOR,cLOJACF,nVALOR,cCC)

  	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := " SELECT ISNULL(SUM(CT2_VALOR),0) AS CT2_VALOR  "
	cQuery1 += " FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE CT2_FILKEY  = '" + cFILKEY + "' "
	cQuery1 += "     AND CT2_PREFIX  = '" + cPREFIX + "' "
	cQuery1 += "     AND CT2_NUMDOC  = '" + cNUMDOC + "' "
	cQuery1 += "     AND CT2_PARCEL  = '" + cPARCEL + "' "
	cQuery1 += "     AND CT2_TIPODC  = '" + cTIPODC + "' "
	cQuery1 += "     AND CT2_CLIFOR  = '" + cCLIFOR + "' "
	cQuery1 += "     AND CT2_LOJACF  = '" + cLOJACF + "' "
	cQuery1 += "     AND CT2_VALOR   = " + CVALTOCHAR(nVALOR)  + " "
	cQuery1 += "     AND CT2_DEBITO <> '' " 
	cQuery1 += "     AND CT2_CCD     = '" + cCC  + "' "
	
			 
	MPSysOpenQuery( cQuery1, 'TRM' )
	
Return (NIL)

Static Function SqlCredit(cFILKEY,cPREFIX,cNUMDOC,cPARCEL,cTIPODC,cCLIFOR,cLOJACF,nVALOR,cCC)

	Local cTeste  := ''
	Local cQuery1 := ''

  	cQuery1 := " SELECT ISNULL(SUM(CT2_VALOR),0) AS CT2_VALOR  "
	cQuery1 += " FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE CT2_FILKEY  = '" + cFILKEY + "' "
	cQuery1 += "     AND CT2_PREFIX  = '" + cPREFIX + "' "
	cQuery1 += "     AND CT2_NUMDOC  = '" + cNUMDOC + "' "
	cQuery1 += "     AND CT2_PARCEL  = '" + cPARCEL + "' "
	cQuery1 += "     AND CT2_TIPODC  = '" + cTIPODC + "' "
	cQuery1 += "     AND CT2_CLIFOR  = '" + cCLIFOR + "' "
	cQuery1 += "     AND CT2_LOJACF  = '" + cLOJACF + "' "
	cQuery1 += "     AND CT2_VALOR   = " + CVALTOCHAR(nVALOR)  + " "
	cQuery1 += "     AND CT2_CREDIT <> '' " 
	cQuery1 += "     AND CT2_CCC     = '" + cCC  + "' "
		 
	MPSysOpenQuery( cQuery1, 'TRN' )
	
Return (NIL)

Static Function SqlDevolucao(cFILKEY,cNUMDOC,cCLIFOR,cLOJACF,nVALOR,cSerie)  

	BeginSQL Alias "TRO"
		     %NoPARSER%
		     SELECT D1_COD,D1_PROJETO,D1_CC
			  FROM %TABLE:SD2% SD2 WITH(NOLOCK) 
			  INNER JOIN %TABLE:SD1% SD1 WITH (NOLOCK) 
			          ON D1_FILIAL       = D2_FILIAL
					 AND D1_DOC          = D2_NFORI
					 AND D1_SERIE        = D2_SERIORI
					 AND D1_FORNECE      = D2_CLIENTE
					 AND D1_LOJA         = D2_LOJA
					 AND D1_ITEM         = D2_ITEMORI
					 AND SD1.D_E_L_E_T_ <> '*'
			       WHERE D2_FILIAL       = %EXP:cFILKEY%
			        AND D2_DOC           = %EXP:cNUMDOC%
			        AND D2_SERIE         = %EXP:cSerie%
			        AND D2_CLIENTE       = %EXP:cCLIFOR%
					AND D2_LOJA          = %EXP:cLOJACF%
					AND D2_TOTAL         = %EXP:nVALOR%
					AND SD2.D_E_L_E_T_  <> '*'
		        		     
	EndSQl

Return (NIL)

Static Function SqlCred3(cFILKEY,cPREFIX,cNUMDOC,cPARCEL,cTIPODC,cCLIFOR,cLOJACF,nVALOR,cCC)

    Local cTEste:= ''
	Local cQuery1 := ''

  	cQuery1 := " SELECT RECNO_CT2  "
	cQuery1 += " FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE CT2_FILKEY  = '" + cFILKEY + "' "
	cQuery1 += "     AND CT2_PREFIX  = '" + cPREFIX + "' "
	cQuery1 += "     AND CT2_NUMDOC  = '" + cNUMDOC + "' "
	cQuery1 += "     AND CT2_PARCEL  = '" + cPARCEL + "' "
	cQuery1 += "     AND CT2_TIPODC  = '" + cTIPODC + "' "
	cQuery1 += "     AND CT2_CLIFOR  = '" + cCLIFOR + "' "
	cQuery1 += "     AND CT2_LOJACF  = '" + cLOJACF + "' "
	cQuery1 += "     AND CT2_CREDIT <> '' " 
	cQuery1 += "     AND CT2_CCC     = '" + cCC  + "' "
			 
	MPSysOpenQuery( cQuery1, 'TRP' )

Return (NIL)

Static Function SqlDeb2(cFILKEY,cPREFIX,cNUMDOC,cPARCEL,cTIPODC,cCLIFOR,cLOJACF,nVALOR,cCC,nR_E_C_N_O_)  

	Local cTeste := ''
	Local cQuery1 := ''
	
	cQuery1 := " SELECT ISNULL(SUM(CT2_VALOR),0) AS CT2_VALOR  "
	cQuery1 += " FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE CT2_FILKEY  = '" + cFILKEY + "' "
	cQuery1 += "     AND CT2_PREFIX  = '" + cPREFIX + "' "
	cQuery1 += "     AND CT2_NUMDOC  = '" + cNUMDOC + "' "
	cQuery1 += "     AND CT2_PARCEL  = '" + cPARCEL + "' "
	cQuery1 += "     AND CT2_TIPODC  = '" + cTIPODC + "' "
	cQuery1 += "     AND CT2_CLIFOR  = '" + cCLIFOR + "' "
	cQuery1 += "     AND CT2_LOJACF  = '" + cLOJACF + "' "
	cQuery1 += "     AND CT2_DEBITO <> '' " 
	cQuery1 += "     AND CT2_CCD     = '" + cCC  + "' "
	cQuery1 += "     AND RECNO_CT2  <= " + CVALTOCHAR(nR_E_C_N_O_)  + " "
	cQuery1 += "     AND CT2_VALOR   = " + CVALTOCHAR(nVALOR)  + " "
			 
	MPSysOpenQuery( cQuery1, 'TRQ' )

Return (NIL)

Static Function SqlCred2(cFILKEY,cPREFIX,cNUMDOC,cPARCEL,cTIPODC,cCLIFOR,cLOJACF,nVALOR,cCC)

  	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := " SELECT ISNULL(SUM(CT2_VALOR),0) AS CT2_VALOR  "
	cQuery1 += " FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE CT2_FILKEY  = '" + cFILKEY + "' "
	cQuery1 += "     AND CT2_PREFIX  = '" + cPREFIX + "' "
	cQuery1 += "     AND CT2_NUMDOC  = '" + cNUMDOC + "' "
	cQuery1 += "     AND CT2_PARCEL  = '" + cPARCEL + "' "
	cQuery1 += "     AND CT2_TIPODC  = '" + cTIPODC + "' "
	cQuery1 += "     AND CT2_CLIFOR  = '" + cCLIFOR + "' "
	cQuery1 += "     AND CT2_LOJACF  = '" + cLOJACF + "' "
	cQuery1 += "     AND CT2_CREDIT <> '' " 
	cQuery1 += "     AND CT2_CCC     = '" + cCC  + "' "
			 
	MPSysOpenQuery( cQuery1, 'TRR' )

Return (NIL)

Static Function SqlProd5(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)  

	Local cFilSA2 := FWFILIAL("SA2")
	Local cFilSB1 := FWFILIAL("SB1")

	BeginSQL Alias "TRS"
		     %NoPARSER%
		       SELECT FISC.D1_COD, 
			          FORN.A2_NOME, 
					  PROD.B1_DESC, 
					  FISC.D1_CC, 
			 		  PED.C7_PROJETO,
					  FISC.D1_CUSTO,
		              FT_VALCONT-FT_VALCOF-FT_VALPIS
			     FROM %TABLE:SD1% FISC WITH (NOLOCK) 
			INNER JOIN %TABLE:SFT% SFT WITH (NOLOCK)
			        ON FT_FILIAL                       = D1_FILIAL
				   AND FT_NFISCAL                      = D1_DOC
				   AND FT_SERIE                        = D1_SERIE
				   AND FT_PRODUTO                      = D1_COD
				   AND FT_ITEM                         = D1_ITEM
				   AND SFT.D_E_L_E_T_                 <> '*'      
			LEFT JOIN %TABLE:SA2% FORN WITH (NOLOCK) 
			       ON FORN.A2_FILIAL                   = %EXP:cFilSA2%
				  AND FORN.A2_COD                      = FISC.D1_FORNECE  
			      AND FORN.A2_LOJA                     = FISC.D1_LOJA
				  AND FORN.D_E_L_E_T_                 <> '*'
			LEFT JOIN %TABLE:SB1% PROD WITH (NOLOCK) 
			      ON PROD.B1_FILIAL                    = %EXP:cFilSB1%
				 AND PROD.B1_COD                       = FISC.D1_COD 
				 AND PROD.D_E_L_E_T_                  <> '*'
			LEFT JOIN %TABLE:SC7% PED WITH (NOLOCK) 
			      ON PED.C7_FILIAL                     = FISC.D1_FILIAL
				 AND PED.C7_NUM                        = FISC.D1_PEDIDO
				 AND PED.C7_FORNECE                    = FISC.D1_FORNECE
				 AND PED.C7_PRODUTO                    = FISC.D1_COD
				 AND PED.C7_ITEM                       = FISC.D1_ITEMPC
				 AND PED.D_E_L_E_T_                   <> '*'
			   WHERE FISC.D1_FILIAL                    = %EXP:cFilialAtual%
			     AND FISC.D1_CC                        = %EXP:cCC%
				 AND FISC.D1_DOC                       = %EXP:cDoc%
				 AND FISC.D1_SERIE                     = %EXP:cSerie%
				 AND FISC.D1_FORNECE                   = %EXP:cFornec%
				 AND FISC.D1_LOJA                      = %EXP:cLoja%
				 AND (ROUND(FT_VALCONT-(FT_VALCONT * (FT_ALIQCOF  /100)) - (FT_VALCONT * (FT_ALIQPIS /100)),2,1)  = %EXP:nValor%
				  OR FT_VALCONT-FT_VALCOF-FT_VALPIS = %EXP:nValor%
				  OR ROUND(FT_VALCONT-(FT_VALCONT * (FT_ALIQCOF  /100)) - (FT_VALCONT * (FT_ALIQPIS /100)),2) = %EXP:nValor%)
			     AND FISC.D_E_L_E_T_                  <> '*' 
		     		     
	EndSQl

Return (NIL)

Static Function SqlChaveBusca(cFilialAtual,cDoc,cSerie,cFornec,cLoja)  

	Local cTeste:= ''
	
	BeginSQL Alias "TRT"
		     %NoPARSER%
		       SELECT D1_COD+CONVERT(CHAR,D1_CUSTO)+D1_PROJETO,COUNT(*) AS DUPLICIDADE
				 FROM %TABLE:SD1% WITH (NOLOCK) 
				WHERE D1_FILIAL   = %EXP:cFilialAtual%
				  AND D1_DOC      = %EXP:cDoc%
				  AND D1_SERIE    = %EXP:cSerie%
				  AND D1_FORNECE  = %EXP:cFornec%
				  AND D1_LOJA     = %EXP:cLoja%
				  AND D_E_L_E_T_ <> '*'
				
				  GROUP BY D1_COD+CONVERT(CHAR,D1_CUSTO)+D1_PROJETO
		      		     
	EndSQl

Return (NIL)

Static Function SqlNota1(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT D1_FILIAL,  "
	cQuery1 += "         D1_DOC,     "
	cQuery1 += "         D1_SERIE,   "
	cQuery1 += "         D1_FORNECE, "
	cQuery1 += "         D1_LOJA,    "
	cQuery1 += "         D1_COD,     "
	cQuery1 += "         D1_CUSTO,   "
	cQuery1 += "         D1_PROJETO, "
	cQuery1 += "         C7_PROJETO, "
	cQuery1 += "         B1_DESC,    "
	cQuery1 += "         A2_NOME,    "
	cQuery1 += "         D1_CC,      "
	cQuery1 += "         OK,         "
	cQuery1 += "         SD1RECNO    " 
	cQuery1 += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D1_FILIAL   = '" + cFilialAtual       + "' "
	cQuery1 += "	 AND D1_DOC      = '" + cDoc               + "' "
	cQuery1 += "	 AND D1_SERIE    = '" + cSerie             + "' "
	cQuery1 += "	 AND D1_FORNECE  = '" + cFornec            + "' "
	cQuery1 += "	 AND D1_LOJA     = '" + cLoja              + "' "
	cQuery1 += "	 AND D1_CUSTO    =  " + CVALTOCHAR(nValor) + " "
	cQuery1 += "	 AND OK         = '' " 
	cQuery1 += "	 AND D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TRX' )
	
Return (NIL)

Static Function SqlNota2(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT D1_FILIAL,  "
	cQuery1 += "         D1_DOC,     "
	cQuery1 += "         D1_SERIE,   "
	cQuery1 += "         D1_FORNECE, "
	cQuery1 += "         D1_LOJA,    "
	cQuery1 += "         D1_COD,     "
	cQuery1 += "         D1_CUSTO,   "
	cQuery1 += "         D1_PROJETO, "
	cQuery1 += "         C7_PROJETO, "
	cQuery1 += "         B1_DESC,    "
	cQuery1 += "         A2_NOME,    "
	cQuery1 += "         D1_CC,      "
	cQuery1 += "         OK,         "
	cQuery1 += "         SD1RECNO    " 
	cQuery1 += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D1_FILIAL   = '" + cFilialAtual       + "' "
	cQuery1 += "	 AND D1_DOC      = '" + cDoc               + "' "
	cQuery1 += "	 AND D1_SERIE    = '" + cSerie             + "' "
	cQuery1 += "	 AND D1_FORNECE  = '" + cFornec            + "' "
	cQuery1 += "	 AND D1_LOJA     = '" + cLoja              + "' "
	cQuery1 += "	 AND VALFT1      =  " + CVALTOCHAR(nValor) + " "
	cQuery1 += "	 AND OK          = '' " 
	cQuery1 += "	 AND D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TRZ' )
	
Return (NIL)

Static Function SqlNota3(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT D1_FILIAL,  "
	cQuery1 += "         D1_DOC,     "
	cQuery1 += "         D1_SERIE,   "
	cQuery1 += "         D1_FORNECE, "
	cQuery1 += "         D1_LOJA,    "
	cQuery1 += "         D1_COD,     "
	cQuery1 += "         D1_CUSTO,   "
	cQuery1 += "         D1_PROJETO, "
	cQuery1 += "         C7_PROJETO, "
	cQuery1 += "         B1_DESC,    "
	cQuery1 += "         A2_NOME,    "
	cQuery1 += "         D1_CC,      "
	cQuery1 += "         OK,         "
	cQuery1 += "         SD1RECNO    " 
	cQuery1 += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D1_FILIAL   = '" + cFilialAtual       + "' "
	cQuery1 += "	 AND D1_DOC      = '" + cDoc               + "' "
	cQuery1 += "	 AND D1_SERIE    = '" + cSerie             + "' "
	cQuery1 += "	 AND D1_FORNECE  = '" + cFornec            + "' "
	cQuery1 += "	 AND D1_LOJA     = '" + cLoja              + "' "
	cQuery1 += "	 AND VALFT2      =  " + CVALTOCHAR(nValor) + " "
	cQuery1 += "	 AND OK          = '' " 
	cQuery1 += "	 AND D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TSA' )
	
Return (NIL)

Static Function SqlNota4(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT D1_FILIAL,  "
	cQuery1 += "         D1_DOC,     "
	cQuery1 += "         D1_SERIE,   "
	cQuery1 += "         D1_FORNECE, "
	cQuery1 += "         D1_LOJA,    "
	cQuery1 += "         D1_COD,     "
	cQuery1 += "         D1_CUSTO,   "
	cQuery1 += "         D1_PROJETO, "
	cQuery1 += "         C7_PROJETO, "
	cQuery1 += "         B1_DESC,    "
	cQuery1 += "         A2_NOME,    "
	cQuery1 += "         D1_CC,      "
	cQuery1 += "         OK,         "
	cQuery1 += "         SD1RECNO    " 
	cQuery1 += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D1_FILIAL   = '" + cFilialAtual       + "' "
	cQuery1 += "	 AND D1_DOC      = '" + cDoc               + "' "
	cQuery1 += "	 AND D1_SERIE    = '" + cSerie             + "' "
	cQuery1 += "	 AND D1_FORNECE  = '" + cFornec            + "' "
	cQuery1 += "	 AND D1_LOJA     = '" + cLoja              + "' "
	cQuery1 += "	 AND VALFT3      =  " + CVALTOCHAR(nValor) + " "
	cQuery1 += "	 AND OK          = '' " 
	cQuery1 += "	 AND D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TSB' )
	
Return (NIL)

Static Function SqlNota5(cFilialAtual,cCC,cDoc,cFornec,cLoja,nValor,cSerie)

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT D1_FILIAL,  "
	cQuery1 += "         D1_DOC,     "
	cQuery1 += "         D1_SERIE,   "
	cQuery1 += "         D1_FORNECE, "
	cQuery1 += "         D1_LOJA,    "
	cQuery1 += "         D1_COD,     "
	cQuery1 += "         D1_CUSTO,   "
	cQuery1 += "         D1_PROJETO, "
	cQuery1 += "         C7_PROJETO, "
	cQuery1 += "         B1_DESC,    "
	cQuery1 += "         A2_NOME,    "
	cQuery1 += "         D1_CC,      "
	cQuery1 += "         OK,         "
	cQuery1 += "         SD1RECNO    " 
	cQuery1 += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D1_FILIAL   = '" + cFilialAtual       + "' "
	cQuery1 += "	 AND D1_DOC      = '" + cDoc               + "' "
	cQuery1 += "	 AND D1_SERIE    = '" + cSerie             + "' "
	cQuery1 += "	 AND D1_FORNECE  = '" + cFornec            + "' "
	cQuery1 += "	 AND D1_LOJA     = '" + cLoja              + "' "
	cQuery1 += "	 AND VALFT4      =  " + CVALTOCHAR(nValor) + " "
	cQuery1 += "	 AND OK          = '' " 
	cQuery1 += "	 AND D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TSC' )
	
Return (NIL)

Static Function SqlTable2()

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT *  " 
	cQuery1 += "    FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += "   WHERE D_E_L_E_T_ <> '*' "
			 
	MPSysOpenQuery( cQuery1, 'TSE' )
	
Return (NIL)

Static Function SqlTable4()

	Local cTeste  := ''
	Local cQuery1 := ''
	
	cQuery1 := "  SELECT *  " 
	cQuery1 += "    FROM " + oTable2:GetRealName() + " WITH (NOLOCK) " 
	
	MPSysOpenQuery( cQuery1, 'TSF' )

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUpBase    บAutor  ณFernando Macieira   บ Data ณ  08/26/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบChamado   ณ 051270 || OS 052628 || CONTROLADORIA || LUIZ || 8465       บฑฑ
ฑฑบ          ณ || REL_INVESTIMENTOS - FWNM - 26/08/2019                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function UpBase(cTipo, cConteudo, cProj)

	Local cRet := ""
	
	// Tipo 1 = Item contabil x Filial
	If cTipo == "1"
		If cConteudo == "111"
			cRet := "RN"
		ElseIf cConteudo == "112"
			cRet := "RC"
		ElseIf cConteudo == "113"
			cRet := "RC2"
		ElseIf cConteudo == "114"
			cRet := "SC"
		ElseIf cConteudo == "115"
			cRet := "GO"
		ElseIf cConteudo == "121"
			cRet := "VP"
		Else
			cRet := "VERIFICAR!!!"
		EndIf
	EndIf
	
	// Tipo 2 = Centro Custo + Projeto
	If cTipo == "2" 
		If Empty(cProj)
			If cConteudo == "9998"
				cRet := "ENGENHARIA"
			Else
				cRet := "IMOBILIZADO"
			EndIf
		Else
			cRet := cProj
		EndIf
	EndIf

Return cRet