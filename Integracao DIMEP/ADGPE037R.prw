#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"   

/*{Protheus.doc} User Function ADGPE037R
	Relatorio para acompanhamento de tempo de permanencia do dimep de Visitante. Relatorio em Excel.
	@type  Function
	@author William Costa
	@since 17/07/2018
	@version 01	
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
*/

User Function ADGPE037R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para acompanhamento de tempo de permanencia do dimep de Visitante.Relatorio em Excel.')
	
	PRIVATE aSays		:={}
	PRIVATE aButtons	:={}   
	PRIVATE cCadastro	:= "Relatorio Tempo de Permanência de Visitante Dimep"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	PRIVATE nOpca		:= 0
	PRIVATE cPerg		:= 'ADGPE037R'
	
	//Cria grupo de Perguntas                         
	
	MontaPerg()
	 
	//Monta Form Batch - Interface com o Usuario     
	
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Tempo de Permanência de Visitante Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPEADGPE037R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPEADGPE037R()    

	PRIVATE oExcel     := FWMSEXCEL():New()
	PRIVATE cPath      := ''
	PRIVATE cArquivo   := 'REL_TEMPO_PERMANENCIA_VISITANTE_DIMEP.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cTitulo    := "Relatorio Tempo de Permanência de Visitante - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE aLinhas    := {}
   
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

    Private nLinha      := 0
	Private nExcel      := 0
	Private dData       := ''
	Private cData       := ''
	Private nMatricula  := ''
	Private aMatri      := {}
	Private aMatriculas := {}
	Private nTotReg     := 0
	
	SqlMatriculas() 
			
	DBSELECTAREA("TRA")
	TRA->(DBGOTOP())
	WHILE TRA->(!EOF()) 
	
		Aadd(aMatri,TRA->NU_DOCUMENTO) 
		Aadd(aMatriculas,aMatri)
		aMatri := {}
	
		TRA->(dbSkip())    
		
	ENDDO //end do while TRB
	TRA->( DBCLOSEAREA() )
	
	nTotReg := LEN(aMatriculas) * IIF(DateDiffDay(MV_PAR03,MV_PAR04) == 0,1,DateDiffDay(MV_PAR03,MV_PAR04))
	
	PROCREGUA(nTotReg)	
	dData     := MV_PAR03
	FOR nCont := 1 To LEN(aMatriculas)
	
		IncProc("Matriculas:" + Cvaltochar(nCont) + " até " + CvalToChar(LEN(aMatriculas)) + " Matricula " + CVALTOCHAR(aMatriculas[nCont][1])) 
	
		WHILE dData >= MV_PAR03 .AND. ;
	          dData <= MV_PAR04
	          
	        SqlEntrada(aMatriculas[nCont][1],DTOS(dData)) 
			
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
			   	               "", ; // 23 W  
			   	               "", ; // 24 X  
			   	               "", ; // 25 Y  
			   	               "", ; // 26 Z  
			   	               "", ; // 27 AA
			   	               "", ; // 28 AB 
			   	               "", ; // 29 AC  
			   	               "", ; // 30 AD  
			   	               "", ; // 30 AE
			   	               "", ; // 31 AF
			   	               ""  ; // 32 AG
			   	                   })
				//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
				//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
				aLinhas[nLinha][01] := TRB->CD_LOG_ACESSO_ENTRADA                  //A
				aLinhas[nLinha][02] := TRB->NU_CREDENCIAL                          //B
				aLinhas[nLinha][03] := TRB->TP_AUTENTICACAO                        //C
				aLinhas[nLinha][04] := TRB->NU_DOCUMENTO                           //D
				aLinhas[nLinha][05] := TRB->NM_PESSOA                              //E
				aLinhas[nLinha][06] := TRB->NM_ESTRUTURA                           //F
				aLinhas[nLinha][07] := TRB->DS_GRUPO                               //G
				aLinhas[nLinha][08] := TRB->DS_EQUIPAMENTO                         //H
				aLinhas[nLinha][09] := TRB->TP_SENTIDO_CONSULTA                    //I
				aLinhas[nLinha][10] := TRB->DT_REQUISICAO                          //J
				aLinhas[nLinha][11] := CVALTOCHAR(TRB->NU_DATA_REQUISICAO)         //K
				aLinhas[nLinha][12] := SUBSTRING(ALLTRIM(TRB->DT_REQUISICAO),12,8) //L
				aLinhas[nLinha][13] := TRB->CD_TIPO_CREDENCIAL                     //M
				aLinhas[nLinha][14] := TRB->DS_TIPO_CREDENCIAL                     //N
				aLinhas[nLinha][15] := TRB->CD_ESTRUTURA                           //O
				aLinhas[nLinha][16] := TRB->NM_ESTRUTURA                           //P
				aLinhas[nLinha][17] := ''                                          //Q
				aLinhas[nLinha][18] := ''                                          //R
				aLinhas[nLinha][19] := ''                                          //S
				aLinhas[nLinha][20] := ''                                          //T
				aLinhas[nLinha][21] := ''                                          //U
				aLinhas[nLinha][22] := ''                                          //V
				aLinhas[nLinha][23] := ''                                          //W
				aLinhas[nLinha][24] := ''                                          //X
				aLinhas[nLinha][25] := ''                                          //Y
				aLinhas[nLinha][26] := ''                                          //Z
				aLinhas[nLinha][27] := ''                                          //AA
				aLinhas[nLinha][28] := ''                                          //AB
				aLinhas[nLinha][29] := ''                                          //AC
				aLinhas[nLinha][30] := ''                                          //AD
				aLinhas[nLinha][31] := ''                                          //AE
				aLinhas[nLinha][32] := ''                                          //AF
				aLinhas[nLinha][33] := ''                                          //AG
				
				//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
		
				SqlSaida(aMatriculas[nCont][1],DTOS(dData)) 
				
				DBSELECTAREA("TRC")
				TRC->(DBGOTOP())
				WHILE TRC->(!EOF()) 
				
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := aLinhas[nLinha][01]                         //A
					aLinhas[nLinha][02] := aLinhas[nLinha][02]                         //B
					aLinhas[nLinha][03] := aLinhas[nLinha][03]                         //C
					aLinhas[nLinha][04] := aLinhas[nLinha][04]                         //D
					aLinhas[nLinha][05] := aLinhas[nLinha][05]                         //E
					aLinhas[nLinha][06] := aLinhas[nLinha][06]                         //F
					aLinhas[nLinha][07] := aLinhas[nLinha][07]                         //G
					aLinhas[nLinha][08] := aLinhas[nLinha][08]                         //H
					aLinhas[nLinha][09] := aLinhas[nLinha][09]                         //I
					aLinhas[nLinha][10] := aLinhas[nLinha][10]                         //J
					aLinhas[nLinha][11] := aLinhas[nLinha][11]                         //K
					aLinhas[nLinha][12] := aLinhas[nLinha][12]                         //L
					aLinhas[nLinha][13] := aLinhas[nLinha][13]                         //M
					aLinhas[nLinha][14] := aLinhas[nLinha][14]                         //N
					aLinhas[nLinha][15] := aLinhas[nLinha][15]                         //O
					aLinhas[nLinha][16] := aLinhas[nLinha][16]                         //P
					aLinhas[nLinha][17] := TRC->CD_LOG_ACESSO_SAIDA                    //Q
					aLinhas[nLinha][18] := TRC->NU_CREDENCIAL                          //R
					aLinhas[nLinha][19] := TRC->TP_AUTENTICACAO                        //S
					aLinhas[nLinha][20] := TRC->NU_DOCUMENTO                           //T
					aLinhas[nLinha][21] := TRC->NM_PESSOA                              //U
					aLinhas[nLinha][22] := TRC->NM_ESTRUTURA                           //V
					aLinhas[nLinha][23] := TRC->DS_GRUPO                               //W
					aLinhas[nLinha][24] := TRC->DS_EQUIPAMENTO                         //X
					aLinhas[nLinha][25] := TRC->TP_SENTIDO_CONSULTA                    //Y
					aLinhas[nLinha][26] := TRC->DT_REQUISICAO                          //Z
					aLinhas[nLinha][27] := CVALTOCHAR(TRC->NU_DATA_REQUISICAO)         //AA
					aLinhas[nLinha][28] := SUBSTRING(ALLTRIM(TRC->DT_REQUISICAO),12,8) //AB
					aLinhas[nLinha][29] := TRC->CD_TIPO_CREDENCIAL                     //AC
					aLinhas[nLinha][30] := TRC->DS_TIPO_CREDENCIAL                     //AD
					aLinhas[nLinha][31] := TRC->CD_ESTRUTURA                           //AE
					aLinhas[nLinha][32] := TRC->NM_ESTRUTURA                           //AF
					aLinhas[nLinha][33] := ''                                          //AG
					
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
					TRC->(dbSkip())    
				
				ENDDO //end do while TRB
				TRC->( DBCLOSEAREA() )
				
				// INICIO IF PARA PESSOAS QUE SÃO DE NOITE E SAIDA DA EMPRESA NO OUTRO DIA
				IF aLinhas[nLinha][28] < aLinhas[nLinha][12]
				
					SqlSaida2(aMatriculas[nCont][1],DTOS(dData+1)) 
				
					DBSELECTAREA("TRD")
					TRD->(DBGOTOP())
					WHILE TRD->(!EOF()) 
					
						//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
						aLinhas[nLinha][01] := aLinhas[nLinha][01]                         //A
						aLinhas[nLinha][02] := aLinhas[nLinha][02]                         //B
						aLinhas[nLinha][03] := aLinhas[nLinha][03]                         //C
						aLinhas[nLinha][04] := aLinhas[nLinha][04]                         //D
						aLinhas[nLinha][05] := aLinhas[nLinha][05]                         //E
						aLinhas[nLinha][06] := aLinhas[nLinha][06]                         //F
						aLinhas[nLinha][07] := aLinhas[nLinha][07]                         //G
						aLinhas[nLinha][08] := aLinhas[nLinha][08]                         //H
						aLinhas[nLinha][09] := aLinhas[nLinha][09]                         //I
						aLinhas[nLinha][10] := aLinhas[nLinha][10]                         //J
						aLinhas[nLinha][11] := aLinhas[nLinha][11]                         //K
						aLinhas[nLinha][12] := aLinhas[nLinha][12]                         //L
						aLinhas[nLinha][13] := aLinhas[nLinha][13]                         //M
						aLinhas[nLinha][14] := aLinhas[nLinha][14]                         //N
						aLinhas[nLinha][15] := aLinhas[nLinha][15]                         //O
						aLinhas[nLinha][16] := aLinhas[nLinha][16]                         //P
						aLinhas[nLinha][17] := TRD->CD_LOG_ACESSO_SAIDA                    //Q
						aLinhas[nLinha][18] := TRD->NU_CREDENCIAL                          //R
						aLinhas[nLinha][19] := TRD->TP_AUTENTICACAO                        //S
						aLinhas[nLinha][20] := TRD->NU_DOCUMENTO                           //T
						aLinhas[nLinha][21] := TRD->NM_PESSOA                              //U
						aLinhas[nLinha][22] := TRD->NM_ESTRUTURA                           //V
						aLinhas[nLinha][23] := TRD->DS_GRUPO                               //W
						aLinhas[nLinha][24] := TRD->DS_EQUIPAMENTO                         //X
						aLinhas[nLinha][25] := TRD->TP_SENTIDO_CONSULTA                    //Y
						aLinhas[nLinha][26] := TRD->DT_REQUISICAO                          //Z
						aLinhas[nLinha][27] := CVALTOCHAR(TRD->NU_DATA_REQUISICAO)         //AA
						aLinhas[nLinha][28] := SUBSTRING(ALLTRIM(TRD->DT_REQUISICAO),12,8) //AB
						aLinhas[nLinha][29] := TRD->CD_TIPO_CREDENCIAL                     //AC
						aLinhas[nLinha][30] := TRD->DS_TIPO_CREDENCIAL                     //AD
						aLinhas[nLinha][31] := TRD->CD_ESTRUTURA                           //AE
						aLinhas[nLinha][32] := TRD->NM_ESTRUTURA                           //AF
						aLinhas[nLinha][33] := ''                                          //AG
						
						//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
						TRD->(dbSkip())    
					
					ENDDO //end do while TRB
					TRD->( DBCLOSEAREA() )
				
				ENDIF
				// FINAL IF PARA PESSOAS QUE SÃO DE NOITE E SAIDA DA EMPRESA NO OUTRO DIA
				
				// INICIO CALCULA TEMPO DE PERMANENCIA
				IF ALLTRIM(aLinhas[nLinha][11]) <> '' .AND. ;
				   ALLTRIM(aLinhas[nLinha][12]) <> '' .AND. ;
				   ALLTRIM(aLinhas[nLinha][27]) <> '' .AND. ;
				   ALLTRIM(aLinhas[nLinha][28]) <> '' 
				   
				   IF ALLTRIM(aLinhas[nLinha][06]) == 'PORTARIA E SEGURANCA PATRIMONIAL'
				   
				   		aLinhas[nLinha][33] := ElapTime(aLinhas[nLinha][12],aLinhas[nLinha][28]) + ' (FUNCIONARIO DA PORTARIA NÃO CONSEGUE CALCULAR TEMPO DE PERMANÊNCIA DEVIDO A PASSAR VARIAS VEZES NOS EQUIPAMENTOS)'              //AG
				   
				   ELSE
					
				   		aLinhas[nLinha][33] := ElapTime(aLinhas[nLinha][12],aLinhas[nLinha][28])              //AG
					
				   ENDIF	
					
				ENDIF
				// FINAL CALCULA TEMPO DE PERMANENCIA
				
				TRB->(dbSkip())    
			
			ENDDO //end do while TRB
			TRB->( DBCLOSEAREA() )
			
			dData := dData + 1
			
		ENDDO // WHILE DE DATA
		
		dData      := MV_PAR03

	NEXT
	
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
   	        	                         aLinhas[nExcel][33] ; // 33 AG
   	            	                                          }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_TEMPO_PERMANENCIA_VISITANTE_DIMEP.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_TEMPO_PERMANENCIA_VISITANTE_DIMEP.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg() 
                                 
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    U_xPutSx1(cPerg,'01','Visitante de  ?','','','mv_ch1','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Visitante Ate ?','','','mv_ch2','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Data De       ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Data Ate      ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Acesso Entrada "          ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial"               ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tp Autenticação "             ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Matricula "               ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Pessoa "                 ,1,1) // 05 E
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Grupo Equipamento " ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Equipamento "       ,1,1) // 08 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "                     ,1,1) // 09 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Data com Hora "               ,1,1) // 10 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "                        ,1,1) // 11 J
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora"                         ,1,1) // 12 K
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Credencial "             ,1,1) // 13 L    
    oExcel:AddColumn(cPlanilha,cTitulo,"Desc Tipo Credencial "        ,1,1) // 14 M
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Estrutura "               ,1,1) // 15 N
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 16 O
  	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Acesso Saida "            ,1,1) // 17 P
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial"               ,1,1) // 18 Q
    oExcel:AddColumn(cPlanilha,cTitulo,"Tp Autenticação "             ,1,1) // 19 R    
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Matricula "               ,1,1) // 20 S
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Pessoa "                 ,1,1) // 21 T
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 22 U
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Grupo Equipamento " ,1,1) // 23 V
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Equipamento "       ,1,1) // 24 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "                     ,1,1) // 25 W
	oExcel:AddColumn(cPlanilha,cTitulo,"Data com Hora "               ,1,1) // 26 X
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "                        ,1,1) // 27 Y
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora"                         ,1,1) // 28 Z
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Credencial "             ,1,1) // 29 AA    
    oExcel:AddColumn(cPlanilha,cTitulo,"Desc Tipo Credencial "        ,1,1) // 30 AB
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Estrutura "               ,1,1) // 31 AC
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 32 AD
  	oExcel:AddColumn(cPlanilha,cTitulo,"Tempo de Permanência "        ,1,1) // 33 AE
		
RETURN(NIL)

Static Function SqlMatriculas()

	BeginSQL Alias "TRA"
			%NoPARSER%
			  SELECT VISITANTE.NU_DOCUMENTO,NM_VISITANTE
				FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
				INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[VISITANTE] AS VISITANTE
						ON VISITANTE.CD_VISITANTE   = LOG_ACESSO.CD_VISITANTE
						AND VISITANTE.NU_DOCUMENTO >= %EXP:MV_PAR01%
						AND VISITANTE.NU_DOCUMENTO <= %EXP:MV_PAR02%
				WHERE NU_DATA_REQUISICAO           >= %EXP:MV_PAR03%
					AND NU_DATA_REQUISICAO         <= %EXP:MV_PAR04%
					AND LOG_ACESSO.CD_VISITANTE    IS NOT NULL
						
	EndSQl             
    
RETURN()

Static Function SqlEntrada(cMat,cData)

	Local nFil     := 0
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRB"
			%NoPARSER%
			 SELECT TOP(1) CD_LOG_ACESSO AS CD_LOG_ACESSO_ENTRADA,
					        NU_CREDENCIAL,
					        LOG_ACESSO.TP_AUTENTICACAO,
					        NU_DOCUMENTO,
					        NM_PESSOA,
					        NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        NM_ESTRUTURA
					   FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
					   LEFT JOIN [DIMEP].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND NU_DOCUMENTO                                                  = %EXP:cMat%
						AND LEN(NU_DOCUMENTO)                                            >= 7 // Para trazer só os visitantes
						AND TP_SENTIDO_CONSULTA                                           = 1 //ENTRADA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 5 //Cancela Entrada Portaria
						 OR CD_EQUIPAMENTO                                                = 20) //Balança Entrada
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autorização
						 
						 ORDER BY NU_HORA_REQUISICAO 
						
	EndSQl             
    
RETURN()

Static Function SqlSaida(cMat,cData)

	Local nFil     := 0                                       
	
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRC"
			%NoPARSER%
			 SELECT TOP(1) CD_LOG_ACESSO AS CD_LOG_ACESSO_SAIDA,
					        NU_CREDENCIAL,
					        LOG_ACESSO.TP_AUTENTICACAO,
					        NU_DOCUMENTO,
					        NM_PESSOA,
					        NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        NM_ESTRUTURA
					   FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
					   LEFT JOIN [DIMEP].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND NU_DOCUMENTO                                                  = %EXP:cMat%
						AND LEN(NU_DOCUMENTO)                                            >= 7 // Para trazer só os visitantes
						AND TP_SENTIDO_CONSULTA                                           = 2 //SAIDA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
						 OR CD_EQUIPAMENTO                                                = 21) //Balança Saida
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autorização
						 
						 ORDER BY NU_HORA_REQUISICAO DESC
						
	EndSQl             
    
RETURN()

Static Function SqlSaida2(cMat,cData)

	Local nFil     := 0                                       
	
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRD"
			%NoPARSER%
			 SELECT TOP(1) CD_LOG_ACESSO AS CD_LOG_ACESSO_SAIDA,
					        NU_CREDENCIAL,
					        LOG_ACESSO.TP_AUTENTICACAO,
					        NU_DOCUMENTO,
					        NM_PESSOA,
					        NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        NM_ESTRUTURA
					   FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
					   LEFT JOIN [DIMEP].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND NU_DOCUMENTO                                                  = %EXP:cMat%
						AND LEN(NU_DOCUMENTO)                                            >= 7 // Para trazer só os visitantes
						AND TP_SENTIDO_CONSULTA                                           = 2 //SAIDA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
						 OR CD_EQUIPAMENTO                                                = 21) //Balança Saída
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autorização
						 
						 ORDER BY NU_HORA_REQUISICAO DESC
						
	EndSQl             
    
RETURN()
