#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"   

/*{Protheus.doc} User Function ADGPE036R
	Relatorio para acompanhamento de tempo de permanencia do dimep de terceiro. Relatorio em Excel.
	@type  Function
	@author William Costa
	@since 17/07/2018
	@version 01
	@history Chamado 047019 - William Costa - 19/02/2019 - Retirado regra para descontar horario de almo�o somente se tiver passagem no Refeitorio foi descontado de todos os Terceiros 
	@history Chamado 050095 - William Costa - 01/07/2019 - Adicionado regra para c�lculo de terceiros que trabalham no noturno, adicionado a aba batida por batida indiferente se concluido ou n�o concluido
	@history TICKET  224    - William Costa - 11/11/2020 - Altera��o do Fonte na parte de Funcion�rios, trocar a integra��o do Protheus para a Integra��o do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket  77205  - Adriano Savoine  - 28/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
*/

User Function ADGPE036R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para acompanhamento de tempo de permanencia do dimep de terceiro.Relatorio em Excel.')
	
	//Define Variaveis                                             
	
	PRIVATE aSays		:={}
	PRIVATE aButtons	:={}   
	PRIVATE cCadastro	:= "Relatorio Tempo de Perman�ncia de terceiros Dimep"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	PRIVATE nOpca		:= 0
	PRIVATE cPerg		:= 'ADGPE036R'
	
	//Cria grupo de Perguntas                         
	
	MontaPerg()
		
	//Monta Form Batch - Interface com o Usuario     
	
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Tempo de Perman�ncia de Terceiros Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPEADGPE036R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPEADGPE036R()    

	PRIVATE oExcel     := FWMSEXCEL():New()
	PRIVATE cPath      := ''
	PRIVATE cArquivo   := 'REL_TEMPO_TERC_DIMEP' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := 'Terceiros ' 
    PRIVATE cTitulo    := "Relatorio Tempo de Perman�ncia de TERCEIROS - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cPlan2     := 'Fun��es_Dia ' 
    PRIVATE cTitulo2   := "Relatorio Fun��es Dia - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cPlan3     := 'Fun��es ' 
    PRIVATE cTitulo3   := "Relatorio Fun��es - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cPlan4     := 'Empresas ' 
    PRIVATE cTitulo4   := "Relatorio Empresas - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE cPlan5     := 'Batida por Batida ' 
    PRIVATE cTitulo5   := "Relatorio Batida por Batida - " + DTOC(MV_PAR03) + ' ate ' + DTOC(MV_PAR04)
    PRIVATE aLinhas    := {}
    PRIVATE aLin2      := {}
    PRIVATE aLin3      := {}
    PRIVATE aLin4      := {}
    PRIVATE aLin5      := {}
      
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("N�o Existe Excel Instalado")
            BREAK
        EndIF
        
        // *** INICIO VERIFICACAO DAS PERGUNTAS NAO PODEM VIR COM EM BRANCO E NEM LETRAS *** //
        
        DO CASE 
        	CASE ISALPHA(MV_PAR01) == .T. .OR. ALLTRIM(MV_PAR01) == ''
        	 	ALERT("Ol� " + Alltrim(cUserName) + ", par�metro Terceiro de n�o pode ser branco ou ter letras, favor usar somente n�meros!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR02) == .T. .OR. ALLTRIM(MV_PAR02) == ''
        	 	ALERT("Ol� " + Alltrim(cUserName) + ", par�metro Terceiro at� n�o pode ser branco ou ter letras, favor usar somente n�meros!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR05) == .T. .OR. ALLTRIM(MV_PAR05) == ''
        	 	ALERT("Ol� " + Alltrim(cUserName) + ", par�metro Cod Estrutura Organiz. de n�o pode ser branco ou ter letras, favor usar somente n�meros!!!")
        	 	BREAK
        	CASE ISALPHA(MV_PAR06) == .T. .OR. ALLTRIM(MV_PAR06) == ''
        	 	ALERT("Ol� " + Alltrim(cUserName) + ", par�metro Cod Estrutura Organiz. at� n�o pode ser branco ou ter letras, favor usar somente n�meros!!!")
        	 	BREAK 	 	 	
        ENDCASE
                
        // *** FINAL VERIFICACAO DAS PERGUNTAS NAO PODEM VIR COM EM BRANCO E NEM LETRAS *** //
        
		u_GrLogZBE (Date(),TIME(),cUserName," Relatorio de Terceiros","PORTARIA/DIMEP","ADGPE036R",;
					"Gerou o Relatorio",ComputerName(),LogUserName())
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

	Local   nCont          := 0
	Local   nCont1         := 0
	Local   nExcel         := 0
	Local   nCont2         := 0
	Local   nContDias      := 0
	Local   nCont3         := 0
	Local   nCont4         := 0
	Local   nContTerceiro  := 0
	Local   nContMAt       := 0
	Local   nExcel5        := 0
    Private nLinha         := 0
	Private dData          := ''
	Private cData          := ''
	Private aMatri         := {}
	Private aMatriculas    := {}
	Private nTotReg        := 0
	Private cHora          := ''
	Private cHoraEntrada   := ''
	Private lNoturno       := .F.
	Private aDifHora       := {}
	Private aDifHoras      := {}
	Private cErro          := ''
	Private cTotHora       := ''
	Private nTotMin        := 0
	Private afuncao        := {}
	Private afuncoes       := {}
	Private aEmp           := {}
	Private aEmpresas      := {}
	Private cDataIniOld    := ''
	Private cDataIni       := ''
	Private cDataFinOld    := ''
	Private cDataFin       := ''
	Private nCodEmpOld     := 0
	Private nCodEmp        := 0
	Private cCodTercOld    := ''
	Private cCodTerc       := ''
	Private nExcel2        := 0
	Private nExcel3        := 0
	Private nExcel4        := 0
	Private nQtdFunc       := 0
	Private nTempoFunc     := 0
	Private nTempoRefeicao := 0
	Private nQtdTerceiro   := 0
	Private nQtdDia        := 0
	Private nMat           := 0
	Private nMatOld        := 0
	Private aDia           := {}
	Private aDias          := {}
	Private lExistTRC      := .F.
	Private lExisTRG       := .F.
	Private nContRef       := 0
	Private aTerceiros     := {}
	Private cMat           := ''
	
	dData := MV_PAR03
	
	// *** INCIO PLANILHA 1 *** //
	
	SqlMatriculas() 
			
	DBSELECTAREA("TRA")
	TRA->(DBGOTOP())
	WHILE TRA->(!EOF()) 
	
		Aadd(aMatri,TRA->NU_MATRICULA) 
		Aadd(aMatriculas,aMatri)
		aMatri := {}
	
		TRA->(dbSkip())    
		
	ENDDO //end do while TRB
	TRA->( DBCLOSEAREA() )
	
	nTotReg := LEN(aMatriculas) * (DateDiffDay( MV_PAR03 , MV_PAR04 ))
	
	PROCREGUA(nTotReg)	
	FOR nCont := 1 To LEN(aMatriculas)
	
		IncProc("Matriculas:" + Cvaltochar(nCont) + " at� " + CvalToChar(LEN(aMatriculas)) + "Verificando a Matricula " + CVALTOCHAR(aMatriculas[nCont][1])) 
	
		WHILE dData >= MV_PAR03 .AND. ;
	          dData <= MV_PAR04
	          
	        IncProc(Cvaltochar(nCont) + "/" + CvalToChar(LEN(aMatriculas)) + " Mat: " + CVALTOCHAR(aMatriculas[nCont][1]) + ' data: ' + DTOC(dData))   
	        SqlEntrada(aMatriculas[nCont][1],DTOS(dData)) 
			lNoturno   := .F.  
			
			DBSELECTAREA("TRB")
			TRB->(DBGOTOP())
			WHILE TRB->(!EOF()) 
			
				nLinha     := nLinha + 1
				lNoturno   := .F.                                       
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
			   	               "", ; // 31 AE
			   	               "", ; // 32 AF
			   	               "", ; // 33 AG
			   	               "", ; // 34 AH
			   	               "", ; // 35 AI
			   	               "", ; // 36 AJ
			   	               ""  ; // 37 AK
			   	                   })
				//===================== FINAL CRIA VETOR COM POSICAO VAZIA
				
				//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
				aLinhas[nLinha][01] := TRB->CD_LOG_ACESSO_ENTRADA                  //A
				aLinhas[nLinha][02] := TRB->NU_CREDENCIAL                          //B
				aLinhas[nLinha][03] := TRB->TP_AUTENTICACAO                        //C
				aLinhas[nLinha][04] := TRB->NU_MATRICULA                           //D
				aLinhas[nLinha][05] := TRB->NM_PESSOA                              //E
				aLinhas[nLinha][06] := TRB->NM_ESTRUTURA                           //F
				aLinhas[nLinha][07] := TRB->DS_GRUPO                               //G
				aLinhas[nLinha][08] := TRB->DS_EQUIPAMENTO                         //H
				aLinhas[nLinha][09] := TRB->TP_SENTIDO_CONSULTA                    //I
				aLinhas[nLinha][10] := TRB->DT_REQUISICAO                          //J
				aLinhas[nLinha][11] := STOD(CVALTOCHAR(TRB->NU_DATA_REQUISICAO))   //K
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
				aLinhas[nLinha][34] := ''                                          //AH
				aLinhas[nLinha][35] := ''                                          //AI
				aLinhas[nLinha][36] := ''                                          //AJ
				aLinhas[nLinha][37] := ''                                          //AK
				
				//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
		
				SqlSaida(aMatriculas[nCont][1],DTOS(dData)) 
				lExistTRC    := .F.
				DBSELECTAREA("TRC")
				TRC->(DBGOTOP())
				WHILE TRC->(!EOF()) 
				
					//INICIO SE A DATA DA ENTRADA FOR IGUAL A DATA DA SAIDA E O HORARIO DE ENTRADA FOR MAIOR QUE O HORARIO DA SAIDA 
					//SIGNIFICA QUE A PESSOA ENTROU A NOITE NAO ENTRA NESSE SELECT ENTRA NO PROXIMO DE NOITE
					
					IF STOD(CVALTOCHAR(TRB->NU_DATA_REQUISICAO)) == STOD(CVALTOCHAR(TRB->NU_DATA_REQUISICAO)) .AND. ;
					   SUBSTRING(ALLTRIM(TRB->DT_REQUISICAO),12,8) > SUBSTRING(ALLTRIM(TRC->DT_REQUISICAO),12,8)
					   
					   EXIT //SAI DESSE LACO PORQUE A PESSOA ENTRA A NOITE
					   
					ENDIF   
					
					//FINAL SE A DATA DA ENTRADA FOR IGUAL A DATA DA SAIDA E O HORARIO DE ENTRADA FOR MAIOR QUE O HORARIO DA SAIDA 
					//SIGNIFICA QUE A PESSOA ENTROU A NOITE NAO ENTRA NESSE SELECT ENTRA NO PROXIMO DE NOITE
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
					aLinhas[nLinha][01] := aLinhas[nLinha][01]                                                                                //A
					aLinhas[nLinha][02] := aLinhas[nLinha][02]                                                                                //B
					aLinhas[nLinha][03] := aLinhas[nLinha][03]                                                                                //C
					aLinhas[nLinha][04] := aLinhas[nLinha][04]                                                                                //D
					aLinhas[nLinha][05] := aLinhas[nLinha][05]                                                                                //E
					aLinhas[nLinha][06] := aLinhas[nLinha][06]                                                                                //F
					aLinhas[nLinha][07] := aLinhas[nLinha][07]                                                                                //G
					aLinhas[nLinha][08] := aLinhas[nLinha][08]                                                                                //H
					aLinhas[nLinha][09] := aLinhas[nLinha][09]                                                                                //I
					aLinhas[nLinha][10] := aLinhas[nLinha][10]                                                                                //J
					aLinhas[nLinha][11] := aLinhas[nLinha][11]                                                                                //K
					aLinhas[nLinha][12] := aLinhas[nLinha][12]                                                                                //L
					aLinhas[nLinha][13] := aLinhas[nLinha][13]                                                                                //M
					aLinhas[nLinha][14] := aLinhas[nLinha][14]                                                                                //N
					aLinhas[nLinha][15] := aLinhas[nLinha][15]                                                                                //O
					aLinhas[nLinha][16] := aLinhas[nLinha][16]                                                                                //P
					aLinhas[nLinha][17] := TRC->CD_LOG_ACESSO_SAIDA                                                                           //Q
					aLinhas[nLinha][18] := TRC->NU_CREDENCIAL                                                                                 //R
					aLinhas[nLinha][19] := TRC->TP_AUTENTICACAO                                                                               //S
					aLinhas[nLinha][20] := TRC->NU_MATRICULA                                                                                  //T
					aLinhas[nLinha][21] := TRC->NM_PESSOA                                                                                     //U
					aLinhas[nLinha][22] := TRC->NM_ESTRUTURA                                                                                  //V
					aLinhas[nLinha][23] := TRC->DS_GRUPO                                                                                      //W
					aLinhas[nLinha][24] := TRC->DS_EQUIPAMENTO                                                                                //X
					aLinhas[nLinha][25] := TRC->TP_SENTIDO_CONSULTA                                                                           //Y
					aLinhas[nLinha][26] := TRC->DT_REQUISICAO                                                                                 //Z
					aLinhas[nLinha][27] := STOD(CVALTOCHAR(TRB->NU_DATA_REQUISICAO))                                                          //AA
					aLinhas[nLinha][28] := SUBSTRING(ALLTRIM(TRC->DT_REQUISICAO),12,8)                                                        //AB
					aLinhas[nLinha][29] := TRC->CD_TIPO_CREDENCIAL                                                                            //AC
					aLinhas[nLinha][30] := TRC->DS_TIPO_CREDENCIAL                                                                            //AD
					aLinhas[nLinha][31] := TRC->CD_ESTRUTURA                                                                                  //AE
					aLinhas[nLinha][32] := TRC->NM_ESTRUTURA                                                                                  //AF
					aLinhas[nLinha][33] := TRC->TX_CAMPO06                                                                                    //AG
					aLinhas[nLinha][34] := IIF(ALLTRIM(TRC->TX_CAMPO06) == '','',Posicione("SRJ",1,xFilial("SRJ")+TRC->TX_CAMPO06,"RJ_DESC")) //AH
					aLinhas[nLinha][35] := ''                                                                                                 //AI
					aLinhas[nLinha][36] := ''                                                                                                 //AJ
					aLinhas[nLinha][37] := ''                                                                                                 //AK
					Aadd(afuncao,DTOS(aLinhas[nLinha][11]))                                                                                  //Data Inicial
					Aadd(afuncao,DTOS(aLinhas[nLinha][27]))                                                                                  //Data Final
					Aadd(afuncao,aLinhas[nLinha][31])                                                                                        //Cod. Empresa
					Aadd(afuncao,aLinhas[nLinha][32])                                                                                        //Nome Empresa
					Aadd(afuncao,aLinhas[nLinha][33])                                                                                        //Fun��o
					Aadd(afuncao,aLinhas[nLinha][34])                                                                                        //Nome Funcao 
					Aadd(afuncao,'')                                                                                                         //Quantidade
					Aadd(afuncao,aLinhas[nLinha][20])  
					lExistTRC := .T.                                                                                      //Num Credencial
					//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
					TRC->(dbSkip())    
				
				ENDDO //end do while TRB
				TRC->( DBCLOSEAREA() )
				
				// INICIO IF PARA PESSOAS QUE S�O DE NOITE E SAIDA DA EMPRESA NO OUTRO DIA
				IF ALLTRIM(aLinhas[nLinha][28]) == '' .AND. ;
				   lExistTRC                    == .F.        //garantir que n�o tenha gravado a saida final pela TRC
				
					SqlSaida2(aMatriculas[nCont][1],DTOS(dData+1))
					DBSELECTAREA("TRD")
					TRD->(DBGOTOP())
					WHILE TRD->(!EOF())
					
						lExisTRG := .F.
					    // *** INICIO PROCURA  SE A HORA DA SAIDA DO PROXIMO EXISTE UMA ENTRADA AI NAO DEIXA CARREGAR *** //
					    SqlEnt2(aMatriculas[nCont][1],DTOS(dData+1)) //verifica entrada 
						
						DBSELECTAREA("TRG")
						TRG->(DBGOTOP())
						WHILE TRG->(!EOF())
						
							IF SUBSTRING(ALLTRIM(TRG->DT_REQUISICAO),12,8) < SUBSTRING(ALLTRIM(TRD->DT_REQUISICAO),12,8)
							
								lExisTRG := .T.
							
							ENDIF
						
							
							TRG->(dbSkip())    
						
						ENDDO //end do while TRG
						TRG->( DBCLOSEAREA() )
					    
					 	//SUBSTRING(ALLTRIM(TRD->DT_REQUISICAO),12,8) //HORA SAIDA 2
					 	//SUBSTRING(ALLTRIM(TRB->DT_REQUISICAO),12,8) //HORA ENTRADA
					 	
						// *** FINAL PROCURA  SE A HORA DA SAIDA DO PROXIMO EXISTE UMA ENTRADA AI NAO DEIXA CARREGAR *** //
						
						IF lExisTRG == .F.
						
							lNoturno   := .T.
							//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
							aLinhas[nLinha][01] := aLinhas[nLinha][01]                                                                                //A
							aLinhas[nLinha][02] := aLinhas[nLinha][02]                                                                                //B
							aLinhas[nLinha][03] := aLinhas[nLinha][03]                                                                                //C
							aLinhas[nLinha][04] := aLinhas[nLinha][04]                                                                                //D
							aLinhas[nLinha][05] := aLinhas[nLinha][05]                                                                                //E
							aLinhas[nLinha][06] := aLinhas[nLinha][06]                                                                                //F
							aLinhas[nLinha][07] := aLinhas[nLinha][07]                                                                                //G
							aLinhas[nLinha][08] := aLinhas[nLinha][08]                                                                                //H
							aLinhas[nLinha][09] := aLinhas[nLinha][09]                                                                                //I
							aLinhas[nLinha][10] := aLinhas[nLinha][10]                                                                                //J
							aLinhas[nLinha][11] := aLinhas[nLinha][11]                                                                                //K
							aLinhas[nLinha][12] := aLinhas[nLinha][12]                                                                                //L
							aLinhas[nLinha][13] := aLinhas[nLinha][13]                                                                                //M
							aLinhas[nLinha][14] := aLinhas[nLinha][14]                                                                                //N
							aLinhas[nLinha][15] := aLinhas[nLinha][15]                                                                                //O
							aLinhas[nLinha][16] := aLinhas[nLinha][16]                                                                                //P
							aLinhas[nLinha][17] := TRD->CD_LOG_ACESSO_SAIDA                                                                           //Q
							aLinhas[nLinha][18] := TRD->NU_CREDENCIAL                                                                                 //R
							aLinhas[nLinha][19] := TRD->TP_AUTENTICACAO                                                                               //S
							aLinhas[nLinha][20] := TRD->NU_MATRICULA                                                                                  //T
							aLinhas[nLinha][21] := TRD->NM_PESSOA                                                                                     //U
							aLinhas[nLinha][22] := TRD->NM_ESTRUTURA                                                                                  //V
							aLinhas[nLinha][23] := TRD->DS_GRUPO                                                                                      //W
							aLinhas[nLinha][24] := TRD->DS_EQUIPAMENTO                                                                                //X
							aLinhas[nLinha][25] := TRD->TP_SENTIDO_CONSULTA                                                                           //Y
							aLinhas[nLinha][26] := TRD->DT_REQUISICAO                                                                                 //Z
							aLinhas[nLinha][27] := STOD(CVALTOCHAR(TRD->NU_DATA_REQUISICAO))                                                          //AA
							aLinhas[nLinha][28] := SUBSTRING(ALLTRIM(TRD->DT_REQUISICAO),12,8)                                                        //AB
							aLinhas[nLinha][29] := TRD->CD_TIPO_CREDENCIAL                                                                            //AC
							aLinhas[nLinha][30] := TRD->DS_TIPO_CREDENCIAL                                                                            //AD
							aLinhas[nLinha][31] := TRD->CD_ESTRUTURA                                                                                  //AE
							aLinhas[nLinha][32] := TRD->NM_ESTRUTURA                                                                                  //AF
							aLinhas[nLinha][33] := TRD->TX_CAMPO06                                                                                    //AG
							aLinhas[nLinha][34] := IIF(ALLTRIM(TRD->TX_CAMPO06) == '','',Posicione("SRJ",1,xFilial("SRJ")+TRD->TX_CAMPO06,"RJ_DESC")) //AH
							aLinhas[nLinha][35] := ''                                                                                                 //AI
							aLinhas[nLinha][36] := ''                                                                                                 //AJ
							aLinhas[nLinha][37] := ''                                                                                                 //AK
							Aadd(afuncao,DTOS(aLinhas[nLinha][11]))                                                                                  //Data Inicial
							Aadd(afuncao,DTOS(aLinhas[nLinha][27]))                                                                                  //Data Final
							Aadd(afuncao,aLinhas[nLinha][31])                                                                                        //Cod. Empresa
							Aadd(afuncao,aLinhas[nLinha][32])                                                                                        //Nome Empresa
						    Aadd(afuncao,aLinhas[nLinha][33])                                                                                        //Fun��o
						    Aadd(afuncao,aLinhas[nLinha][34])                                                                                        //Nome Funcao
						    Aadd(afuncao,'')                                                                                                         //Quantidade       
						    Aadd(afuncao,aLinhas[nLinha][20])                                                                                        //Num Credencial                                                                  
							//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
									
						ENDIF
						TRD->(dbSkip())    
					
					ENDDO //end do while TRB
					TRD->( DBCLOSEAREA() )
				
				ENDIF
				// FINAL IF PARA PESSOAS QUE S�O DE NOITE E SAIDA DA EMPRESA NO OUTRO DIA
				
				// INICIO CALCULA TEMPO DE PERMANENCIA
				IF !EMPTY(aLinhas[nLinha][11])        .AND. ;
				   ALLTRIM(aLinhas[nLinha][12]) <> '' .AND. ;
				   !EMPTY(aLinhas[nLinha][27])        .AND. ;
				   ALLTRIM(aLinhas[nLinha][28]) <> '' 
				   
				   IF ALLTRIM(aLinhas[nLinha][06]) == 'PORTARIA E SEGURANCA PATRIMONIAL'
				   
				   		aLinhas[nLinha][35] := ElapTime(aLinhas[nLinha][12],aLinhas[nLinha][28]) + ' (FUNCIONARIO DA PORTARIA N�O CONSEGUE CALCULAR TEMPO DE PERMAN�NCIA DEVIDO A PASSAR VARIAS VEZES NOS EQUIPAMENTOS)'              //AG
				   
				   ELSE
					
				   		aLinhas[nLinha][35] := ElapTime(aLinhas[nLinha][12],aLinhas[nLinha][28])              //AG
					
				   ENDIF	
					
				ENDIF
				// FINAL CALCULA TEMPO DE PERMANENCIA
				
				// *** INICIO CALCULA TEMPO REAL *** //
				IF !EMPTY(aLinhas[nLinha][11])        .AND. ;
				   ALLTRIM(aLinhas[nLinha][12]) <> '' .AND. ;
				   !EMPTY(aLinhas[nLinha][27])        .AND. ;
				   ALLTRIM(aLinhas[nLinha][28]) <> '' 
				   
				     IF lNoturno == .F. //SIGNIFICA QUE TRABALHA DE DIA
				     	
				     	// *** INICIO CALCULO DE TERCEIRO DE DIA *** // 
				     	
				     	SqlAcessoDia(aMatriculas[nCont][1],DTOS(dData)) 
				
						DBSELECTAREA("TRE")
						TRE->(DBGOTOP())
						aDifHoras    := {}
						cErro        := ''
						cHoraEntrada := ''
						cTotHora     := ''
						nTotMin      := 0
						WHILE TRE->(!EOF())
						 
							IF ALLTRIM(TRE->TP_SENTIDO_CONSULTA) == 'ENTRADA'
							
								cHoraEntrada := SUBSTRING(ALLTRIM(TRE->DT_REQUISICAO),12,8)
							
							ELSE
							
								IF ALLTRIM(cHoraEntrada) <> '' .AND. ALLTRIM(TRE->TP_SENTIDO_CONSULTA) == 'SAIDA'
								
									cHora := ''
									cHora := ElapTime(cHoraEntrada,SUBSTRING(ALLTRIM(TRE->DT_REQUISICAO),12,8))
									Aadd(aDifHora,cHora)
									Aadd(aDifHora,Hrs2Min(cHora)) 
									Aadd(aDifHoras,aDifHora)
									aDifHora     := {}
									cHoraEntrada := ''
									
								ELSE
								
									cErro := 'Acessos errados para esse Terceiro nesse dia, favor verificar' 
									EXIT
									
								ENDIF	
								
					   		ENDIF
					   		
					   		TRE->(dbSkip())    
				
						ENDDO //end do while TRB
						TRE->( DBCLOSEAREA() )
						
						IF ALLTRIM(cErro) == '' .AND. LEN(aDifHoras) >= 1
						
							cTotHora := ''
							nTotMin  := 0
							
							IF LEN(aDifHoras) >= 2
							
								FOR nCont1:=1 TO LEN(aDifHoras)
									
									nTotMin := nTotMin + aDifHoras[nCont1][2]
								
								NEXT
								
							ELSE //quando for uma hora so traz o valor direto
							
								cTotHora := aDifHoras[1][1]
								
							ENDIF
							
							//retorna a hora
							aLinhas[nLinha][36] := IIF(!EMPTY(nTotMin),CVALTOCHAR(Min2Hrs(nTotMin)),StrTran( cTotHora, ".", ":"  )) //AG
							
							// *** INICIO PICTURE TEMPO REAL *** //
			
							IF AT(':',aLinhas[nLinha][36]) == 0 // So entra se n�o tiver dois pontos no vetor, significa que a hora ainda n�o esta no formato de hora e sim com , ou .
							
								IF AT('.',aLinhas[nLinha][36]) == 0 //para quando for hora cravada exemplo 10 horas
								
									aLinhas[nLinha][36] := IIF(LEN(aLinhas[nLinha][36]) == 1,'0' + aLinhas[nLinha][36],aLinhas[nLinha][36]) + ':00:00'
								
								ELSEIF VAL(aLinhas[nLinha][36]) > 0 .AND. VAL(aLinhas[nLinha][36]) < 1
								
									aLinhas[nLinha][36] := '00:' +  IIF(LEN(SUBSTR(aLinhas[nLinha][36],3,2)) == 1,SUBSTR(aLinhas[nLinha][36],3,2) + '0', SUBSTR(aLinhas[nLinha][36],3,2))  + ':00' 
												
								ELSEIF VAL(aLinhas[nLinha][36]) >= 1 .AND. VAL(aLinhas[nLinha][36]) < 10
								
									aLinhas[nLinha][36] := '0' + SUBSTR(aLinhas[nLinha][36],1,1) + ':' + IIF(LEN(SUBSTR(aLinhas[nLinha][36],3,2)) == 1,SUBSTR(aLinhas[nLinha][36],3,2) + '0', SUBSTR(aLinhas[nLinha][36],3,2)) + ':00'
								
								ELSE //maior que dez
								
									aLinhas[nLinha][36] := SUBSTR(aLinhas[nLinha][36],1,2) + ':' + IIF(LEN(SUBSTR(aLinhas[nLinha][36],4,2)) == 1,SUBSTR(aLinhas[nLinha][36],4,2) + '0', SUBSTR(aLinhas[nLinha][36],4,2)) + ':00'
								
								ENDIF
								
							ENDIF
							
							// *** FINAL PICTURE TEMPO REAL *** //
							 
						    Aadd(afuncao,IIF(!EMPTY(nTotMin),nTotMin,Hrs2Min(cTotHora))) //Tempo Real
						    
						ELSE
						
							//retornar o erro se tiver
							aLinhas[nLinha][36] := cErro  //AG
						    Aadd(afuncao,cErro) //Tempo Real
							
						ENDIF
						// *** FINAL CALCULO DE TERCEIRO DE DIA *** //
				   		
					 ELSE //SIGNIFICA QUE TRABALHA DE NOITE
					 
					 
					 	//INICIO CALCULO DE NOITE
					 	SqlAcessoNoite(aMatriculas[nCont][1],DTOS(dData),DTOS(dData+1)) //verifica entrada 
						
						DBSELECTAREA("TRH")
						TRH->(DBGOTOP())
						aDifHoras    := {}
						cErro        := ''
						cHoraEntrada := ''
						cTotHora     := ''
						nTotMin      := 0
						WHILE TRH->(!EOF())
						
							IF ALLTRIM(TRH->TP_SENTIDO_CONSULTA) == 'ENTRADA'
							
								cHoraEntrada := SUBSTRING(ALLTRIM(TRH->DT_REQUISICAO),12,8)
							
							ELSE
							
								IF ALLTRIM(cHoraEntrada) <> '' .AND. ALLTRIM(TRH->TP_SENTIDO_CONSULTA) == 'SAIDA'
								
									cHora := ''
									cHora := ElapTime(cHoraEntrada,SUBSTRING(ALLTRIM(TRH->DT_REQUISICAO),12,8))
									Aadd(aDifHora,cHora)
									Aadd(aDifHora,Hrs2Min(cHora)) 
									Aadd(aDifHoras,aDifHora)
									aDifHora     := {}
									cHoraEntrada := ''
									
								ENDIF	
								
					   		ENDIF
						
							
							TRH->(dbSkip())    
						
						ENDDO //end do while TRH
						TRH->( DBCLOSEAREA() )
						
						IF ALLTRIM(cErro) == '' .AND. LEN(aDifHoras) >= 1
						
							cTotHora := ''
							nTotMin  := 0
							
							IF LEN(aDifHoras) >= 2
							
								FOR nCont1:=1 TO LEN(aDifHoras)
									
									nTotMin := nTotMin + aDifHoras[nCont1][2]
								
								NEXT
								
							ELSE //quando for uma hora so traz o valor direto
							
								cTotHora := aDifHoras[1][1]
								
							ENDIF
							
							//retorna a hora
							aLinhas[nLinha][36] := IIF(!EMPTY(nTotMin),CVALTOCHAR(Min2Hrs(nTotMin)),StrTran( cTotHora, ".", ":"  )) //AG
							
							// *** INICIO PICTURE TEMPO REAL *** //
			
							IF AT(':',aLinhas[nLinha][36]) == 0 // So entra se n�o tiver dois pontos no vetor, significa que a hora ainda n�o esta no formato de hora e sim com , ou .
							
								IF AT('.',aLinhas[nLinha][36]) == 0 //para quando for hora cravada exemplo 10 horas
								
									aLinhas[nLinha][36] := IIF(LEN(aLinhas[nLinha][36]) == 1,'0' + aLinhas[nLinha][36],aLinhas[nLinha][36]) + ':00:00'
								
								ELSEIF VAL(aLinhas[nLinha][36]) > 0 .AND. VAL(aLinhas[nLinha][36]) < 1
								
									aLinhas[nLinha][36] := '00:' +  IIF(LEN(SUBSTR(aLinhas[nLinha][36],3,2)) == 1,SUBSTR(aLinhas[nLinha][36],3,2) + '0', SUBSTR(aLinhas[nLinha][36],3,2))  + ':00' 
												
								ELSEIF VAL(aLinhas[nLinha][36]) >= 1 .AND. VAL(aLinhas[nLinha][36]) < 10
								
									aLinhas[nLinha][36] := '0' + SUBSTR(aLinhas[nLinha][36],1,1) + ':' + IIF(LEN(SUBSTR(aLinhas[nLinha][36],3,2)) == 1,SUBSTR(aLinhas[nLinha][36],3,2) + '0', SUBSTR(aLinhas[nLinha][36],3,2)) + ':00'
								
								ELSE //maior que dez
								
									aLinhas[nLinha][36] := SUBSTR(aLinhas[nLinha][36],1,2) + ':' + IIF(LEN(SUBSTR(aLinhas[nLinha][36],4,2)) == 1,SUBSTR(aLinhas[nLinha][36],4,2) + '0', SUBSTR(aLinhas[nLinha][36],4,2)) + ':00'
								
								ENDIF
								
							ENDIF
							
							// *** FINAL PICTURE TEMPO REAL *** //
							 
						    Aadd(afuncao,IIF(!EMPTY(nTotMin),nTotMin,Hrs2Min(cTotHora))) //Tempo Real
						    
						ELSE
						
							//retornar o erro se tiver
							aLinhas[nLinha][36] := cErro  //AG
						    Aadd(afuncao,cErro) //Tempo Real
							
						ENDIF
					 	//FINAL CALCULO DE NOITE
					 
					 	//aLinhas[nLinha][36] := 'Terceiro Noturno, precisa fazer o c�lculo correto'          //AG
					 	//Aadd(afuncao,'Terceiro Noturno, precisa fazer o c�lculo correto') //Tempo Real
					 
					 ENDIF
				ENDIF
				
				// FINAL CALCULA TEMPO REAL
				
				// *** INICIO GRAVACAO DO VETOR PARA OUTRAS PLANILHAS *** //
				IF LEN(afuncao) > 0
				
					// *** INICIO CHAMADO 19/02/2019 - William - chamado 047019
					IF VALTYPE(aFuncao[9]) == 'N' //GARANTIR QUE SO VAI PARA O FECHAMENTO QUANDO TIVER NUMERO DE TEMPO REAL

						aLinhas[nLinha][37] := PICTUREHORA(Min2Hrs(Hrs2Min(aLinhas[nLinha][36]) - 60)) // desconto almoco
						Aadd(afuncao,Hrs2Min(aLinhas[nLinha][37]))
						Aadd(afuncoes,afuncao)
						aLinhas[nLinha][36] := StrTran(aLinhas[nLinha][36], ".", ":"  ) //AG //Ajuste de erro de picuture de hora
						aLinhas[nLinha][37] := StrTran(aLinhas[nLinha][37], ".", ":"  ) //AG //Ajuste de erro de picuture de hora
					
					ENDIF
					// *** FINAL CHAMADO 19/02/2019 - William - chamado 047019
				ENDIF
				
				afuncao := {}
			    
			    // *** FINAL GRAVACAO DO VETOR PARA OUTRAS PLANILHAS *** //
				
				TRB->(dbSkip())
				
			ENDDO //end do while TRB
			TRB->( DBCLOSEAREA() )
			
			dData := dData + 1
			
		ENDDO // WHILE DE DATA
		
		dData := MV_PAR03
		
	NEXT // WHILE DE MATRICULA
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
		
		IncProc("Levando dados para a Planilha1: " + Cvaltochar(nExcel) + "/" + Cvaltochar(nLinha))
		
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
   	        	                         aLinhas[nExcel][36],; // 36 AJ
   	        	                         aLinhas[nExcel][37] ; // 37 AK
   	            	                                         }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** FINAL PLANILHA 1 *** //
   
   // *** INCIO PLANILHA 2 *** //
   
   aSort(afuncoes,,,{ |X, Y| (X[1] + X[2] + CVALTOCHAR(X[3]) + X[5]) < (Y[1] + Y[2] + CVALTOCHAR(Y[3]) + Y[5])})
      
	cDataIniOld    := ''
	cDataIni       := ''
	cDataFinOld    := ''
	cDataFin       := ''
	cCodTercOld    := ''
	cCodTerc       := ''
	nCodEmpOld     := 0
	nCodEmp        := 0 
	nQtdFunc       := 0
	nTempoFunc     := 0
	nTempoRefeicao := 0
	aDia           := {}
	aDias          := {}
	nContDias      := 0
	
    IF LEN(afuncoes) >= 2
	
	    For nCont2 := 1 To LEN(afuncoes)
	   
	   		IncProc("Carregando Dados para a Planilha2 de: " + cValtochar(nCont2) + ' at�: ' + cValtochar(LEN(afuncoes)))
	   		
	   		// *** inicio se o contador for igual a um carrega tamb�m as variaveis de old *** //
	   		
	   		IF nCont2 == 1
	   		
	   			cDataIniOld        := afuncoes[nCont2][01]
				cDataFinOld        := afuncoes[nCont2][02]
				nCodEmpOld         := afuncoes[nCont2][03]
				cCodTercOld        := afuncoes[nCont2][05]
	   		
	   		ENDIF
	   		// *** finalse o contador for igual a um carrega tamb�m as variaveis de old *** //
	   		
	   		
	   		cDataIni    := afuncoes[nCont2][01]
			cDataFin    := afuncoes[nCont2][02]
			nCodEmp     := afuncoes[nCont2][03]
			cCodTerc    := afuncoes[nCont2][05]
			
			
			IF cDataIni <> cDataIniOld .OR. ;
			   cDataFin <> cDataFinOld .OR. ;
			   nCodEmp  <> nCodEmpOld  .OR. ;
			   cCodTerc <> cCodTercOld 	
			   
			   	nExcel2 := nExcel2 + 1
			   
				AADD(aLin2,{ "", ; // 01 A  
			   	             "", ; // 02 B   
			   	             "", ; // 03 C   
			   	             "", ; // 04 D  
			   	             "", ; // 05 E
			   	             "", ; // 06 F  
			   	             "", ; // 07 G
			   	             "", ; // 08 H    
			   	             ""  ; // 09 I
				                })
				                
				aLin2[nExcel2][01] := STOD(afuncoes[nCont2-1][01])         // DATA INICIAL
				aLin2[nExcel2][02] := STOD(afuncoes[nCont2-1][02])         // DATA FINAL
				aLin2[nExcel2][03] := afuncoes[nCont2-1][03]               // COD EMPRESA
				aLin2[nExcel2][04] := afuncoes[nCont2-1][04]               // NOME EMPRESA
				aLin2[nExcel2][05] := afuncoes[nCont2-1][05]               // COD FUNCAO
				aLin2[nExcel2][06] := afuncoes[nCont2-1][06]               // NOME FUNCAO
				aLin2[nExcel2][07] := nQtdFunc                             // QUANTIDADE
				aLin2[nExcel2][08] := PICTUREHORA(Min2Hrs(nTempoFunc))     // TEMPO REAL
				aLin2[nExcel2][09] := PICTUREHORA(Min2Hrs(nTempoRefeicao)) // TEMPO DESCONTO ALMOCO
				
				cDataIniOld        := cDataIni
				cDataFinOld        := cDataFin
				nCodEmpOld         := nCodEmp
				cCodTercOld        := cCodTerc 
				nQtdFunc           := 1
				nTempoFunc         := afuncoes[nCont2][09]
				nTempoRefeicao     := afuncoes[nCont2][10]
			
			ELSE
			
				nQtdFunc        := nQtdFunc + 1
				nTempoFunc      := nTempoFunc + afuncoes[nCont2][09]
				nTempoRefeicao  := nTempoRefeicao + afuncoes[nCont2][10]
			
			ENDIF	
			
	   	Next nCont2
   	
    ELSE
    
    	For nCont2 := 1 To LEN(afuncoes)
    
    		nExcel2 := 1
	    	AADD(aLin2,{ "", ; // 01 A  
		   	             "", ; // 02 B   
		   	             "", ; // 03 C   
		   	             "", ; // 04 D  
		   	             "", ; // 05 E
		   	             "", ; // 06 F  
		   	             "", ; // 07 G
		   	             "", ; // 08 H    
		   	             ""  ; // 09 I
			                })
			                
			aLin2[nExcel2][01] := STOD(afuncoes[nCont2][01])                 // DATA INICIAL
			aLin2[nExcel2][02] := STOD(afuncoes[nCont2][02])                 // DATA FINAL
			aLin2[nExcel2][03] := afuncoes[nCont2][03]                       // COD EMPRESA
			aLin2[nExcel2][04] := afuncoes[nCont2][04]                       // NOME EMPRESA
			aLin2[nExcel2][05] := afuncoes[nCont2][05]                       // COD FUNCAO
			aLin2[nExcel2][06] := afuncoes[nCont2][06]                       // NOME FUNCAO
			aLin2[nExcel2][07] := 1                                          // QUANTIDADE
			aLin2[nExcel2][08] := PICTUREHORA(Min2Hrs(afuncoes[nCont2][09])) // TEMPO REAL
			aLin2[nExcel2][09] := PICTUREHORA(Min2Hrs(afuncoes[nCont2][10])) // TEMPO DESCONTO ALMOCO
			                
	   Next nCont2
   
    ENDIF	
    
    // *** INICIO IMPRIMIR A ULTIMA LINHA *** //
    IF Len(afuncoes) > 0
    
	    AADD(aLin2,{ "", ; // 01 A  
	   	             "", ; // 02 B   
	   	             "", ; // 03 C   
	   	             "", ; // 04 D  
	   	             "", ; // 05 E
	   	             "", ; // 06 F  
	   	             "", ; // 07 G
	   	             "", ; // 08 H    
	   	             ""  ; // 09 I
		                })
		      
		nExcel2 := nExcel2 + 1
	
		aLin2[nExcel2][01] := STOD(afuncoes[Len(afuncoes)][01])         // DATA INICIAL
		aLin2[nExcel2][02] := STOD(afuncoes[Len(afuncoes)][02])         // DATA FINAL
		aLin2[nExcel2][03] := afuncoes[Len(afuncoes)][03]               // COD EMPRESA
		aLin2[nExcel2][04] := afuncoes[Len(afuncoes)][04]               // NOME EMPRESA
		aLin2[nExcel2][05] := afuncoes[Len(afuncoes)][05]               // COD FUNCAO
		aLin2[nExcel2][06] := afuncoes[Len(afuncoes)][06]               // NOME FUNCAO
		aLin2[nExcel2][07] := nQtdFunc                             // QUANTIDADE
		aLin2[nExcel2][08] := PICTUREHORA(Min2Hrs(nTempoFunc))     // TEMPO REAL
		aLin2[nExcel2][09] := PICTUREHORA(Min2Hrs(nTempoRefeicao)) // TEMPO DESCONTO ALMOCO
    
    ENDIF
    
    // *** FINAL IMPRIMIR A ULTIMA LINHA *** //
    
    For nCont2 := 1 To LEN(aLin2)
    
    	IncProc("Levando dados para a Planilha2: " + Cvaltochar(nCont2) + "/" + Cvaltochar(LEN(aLin2)))
    
	    oExcel:AddRow(cPlan2,cTitulo2,{aLin2[nCont2][01],;  // 01 A  
									   aLin2[nCont2][02],;  // 02 B  
									   aLin2[nCont2][03],;  // 03 C  
									   aLin2[nCont2][04],;  // 04 D  
									   aLin2[nCont2][05],;  // 05 E
									   aLin2[nCont2][06],;  // 06 F   
									   aLin2[nCont2][07],;  // 07 G
									   aLin2[nCont2][08],;  // 08 H
									   aLin2[nCont2][09] ;  // 09 I
									                    }) 	
    Next nCont2
    
   // *** FINAL PLANILHA 2 *** //
   
   // *** INCIO PLANILHA 3 *** //
   
   aSort(afuncoes,,,{ |X, Y| (CVALTOCHAR(X[3]) + X[5]) < (CVALTOCHAR(Y[3]) + Y[5])})
      
	cDataIniOld    := ''
	cDataIni       := ''
	cDataFinOld    := ''
	cDataFin       := ''
	cCodTercOld    := ''
	cCodTerc       := ''
	nCodEmpOld     := 0
	nCodEmp        := 0 
	nQtdFunc       := 0
	nTempoFunc     := 0
	nTempoRefeicao := 0
	nQtdTerceiro   := 0
	nQtdDia        := 0
	nMat           := 0
	nMatOld        := 0
	aDia           := {}
	aDias          := {}
	nContDias      := 0
	
   For nCont3 := 1 To LEN(afuncoes)
   
   		IncProc("Carregando Dados para a Planilha3 de: " + cValtochar(nCont3) + ' at�: ' + cValtochar(LEN(afuncoes)))
   		
   		// *** inicio se o contador for igual a um carrega tamb�m as variaveis de old *** //
   		
   		IF nCont3 == 1
   		
   			nCodEmpOld   := afuncoes[nCont3][03]
			cCodTercOld  := afuncoes[nCont3][05]
   		    nMatOld      := afuncoes[nCont3][08]
   		    nQtdTerceiro := 1
   		    
   		ENDIF
   		// *** final se o contador for igual a um carrega tamb�m as variaveis de old *** //
   		
   		nCodEmp     := afuncoes[nCont3][03]
		cCodTerc    := afuncoes[nCont3][05]
		Aadd(aDia,afuncoes[nCont3][01])
	    Aadd(aDias,aDia)
		aDia := {}
		
		IF nCodEmp  <> nCodEmpOld  .OR. ;
		   cCodTerc <> cCodTercOld 	
		   
		   	nExcel3 := nExcel3 + 1
		   
		
			AADD(aLin3,{ "", ; // 01 A  
		   	             "", ; // 02 B   
		   	             "", ; // 03 C   
		   	             "", ; // 04 D  
		   	             "", ; // 05 E
		   	             "", ; // 06 F
		   	             "", ; // 07 G
		   	             ""  ; // 08 H
		   	                })
			                
			aLin3[nExcel3][01] := afuncoes[nCont3-1][03] //COD EMPRESA
			aLin3[nExcel3][02] := afuncoes[nCont3-1][04] //NOME EMPRESA
			aLin3[nExcel3][03] := afuncoes[nCont3-1][05] //COD FUNCAO
			aLin3[nExcel3][04] := afuncoes[nCont3-1][06] //NOME FUNCAO
			aLin3[nExcel3][05] := nQtdTerceiro           //QTD FUNC
			
			// *** INICIO DIAS *** //
			IF LEN(aDias) >= 2 .AND. nCont3 <> LEN(afuncoes)
			
				ASIZE(aDias, LEN(aDias) - 1)   
			
			ENDIF
			
			aSort(aDias,,,{ |X, Y| (X[1]) < (Y[1])})
			
			cDataIniOld := aDias[1][1]
			cDataIni    := ''
			nQtdDia     := 1
			
			FOR nContDias:=1 TO Len(aDias)
			
				cDataIni := aDias[nContDias][1]
			
				IF cDataIni <> cDataIniOld
				
					nQtdDia     := nQtdDia + 1
				    cDataIniOld := cDataIni
				    
				ENDIF
			NEXT 
			
			aLin3[nExcel3][06] := nQtdDia                //QTD DIA
			cDataIniOld        := ''
			cDataIni           := ''
			nQtdDia            := 0
			aDia               := {}
			aDias              := {}
			Aadd(aDia,afuncoes[nCont3][01])
			Aadd(aDias,aDia)
			aDia := {}
			// *** FINAL DIAS *** //
			
			aLin3[nExcel3][07] := PICTUREHORA(Min2Hrs(nTempoFunc))     //TEMPO REAL
			aLin3[nExcel3][08] := PICTUREHORA(Min2Hrs(nTempoRefeicao)) //TEMPO DESCONTO ALMOCO
			
			nCodEmpOld         := nCodEmp
			cCodTercOld        := cCodTerc 
			nTempoFunc         := afuncoes[nCont3][09]
			nTempoRefeicao     := afuncoes[nCont3][10]
			nQtdTerceiro       := 0
		    nQtdDia            := 0
		    
		ELSE
		
			nTempoFunc     := nTempoFunc + afuncoes[nCont3][09]
			nTempoRefeicao := nTempoRefeicao + afuncoes[nCont3][10]
		
		ENDIF	
		
		// *** INICIO VARIAVEL DE MATRICULA *** //
   		nMat := afuncoes[nCont3][08]
   		
   		IF nMat <> nMatOld
   		
   			nQtdTerceiro := nQtdTerceiro + 1
   			nMatOld      := nMat
   			
   		ENDIF
   		// *** FINAL VARIAVEL DE MATRICULA *** //
   		
   	Next nCont3
   	
   	IF LEN(aLin3)    == 0 .AND. ; //Significa que so tem uma funcao tem que imprimir.
   	   LEN(afuncoes)  > 0
   	
   	    nExcel3 := 1
   		AADD(aLin3,{ "", ; // 01 A  
	   	             "", ; // 02 B   
	   	             "", ; // 03 C   
	   	             "", ; // 04 D  
	   	             "", ; // 05 E
	   	             "", ; // 06 F
	   	             "", ; // 07 G  
	   	             ""  ; // 08 H
	   	                })
	   	                
	   	aLin3[nExcel3][01] := afuncoes[1][03]                      //COD EMPRESA
		aLin3[nExcel3][02] := afuncoes[1][04]                      //NOME EMPRESA
		aLin3[nExcel3][03] := afuncoes[1][05]                      //COD FUNCAO
		aLin3[nExcel3][04] := afuncoes[1][06]                      //NOME FUNCAO
		
		// *** INICIO Qtd Terceiros *** //
		aTerceiros := ACLONE(afuncoes)
		aSort(aTerceiros,,,{ |X, Y| (X[8]) < (Y[8])})
		
		nMatOld      := aTerceiros[1][8]
		nMat         := ''
		nQtdTerceiro := 1
		
		FOR nContTerceiro:=1 TO Len(aTerceiros)
		
			nMat := aTerceiros[nContTerceiro][8]
		
			IF nMat <> nMatOld
			
				nQtdTerceiro := nQtdTerceiro + 1
			    nMatOld      := nMat
			    
			ENDIF
		NEXT 
		
		aLin3[nExcel3][05] := nQtdTerceiro                         //QTD FUNC
		nMatOld        := ''
		nMat           := ''
		nQtdTerceiro   := 0
		aTerceiros     := {}
		// *** FINAL Qtd Terceiros *** //
	   	                
	   	// *** INICIO DIAS *** //
		aSort(aDias,,,{ |X, Y| (X[1]) < (Y[1])})
		
		cDataIniOld := aDias[1][1]
		cDataIni    := ''
		nQtdDia     := 1
		
		FOR nContDias:=1 TO Len(aDias)
		
			cDataIni := aDias[nContDias][1]
		
			IF cDataIni <> cDataIniOld
			
				nQtdDia     := nQtdDia + 1
			    cDataIniOld := cDataIni
			    
			ENDIF
		NEXT 
		
		aLin3[nExcel3][06] := nQtdDia                //QTD DIA
		cDataIniOld        := ''
		cDataIni           := ''
		nQtdDia            := 0
		aDia               := {}
		aDias              := {}
		// *** FINAL DIAS *** //                
	   	                
		aLin3[nExcel3][07] := PICTUREHORA(Min2Hrs(nTempoFunc))     //TEMPO REAL
		aLin3[nExcel3][08] := PICTUREHORA(Min2Hrs(nTempoRefeicao)) //TEMPO DESCONTO ALMOCO
		
   	ENDIF
    
    For nCont3 := 1 To LEN(aLin3)
    
    	IncProc("Levando dados para a Planilha3: " + Cvaltochar(nCont3) + "/" + Cvaltochar(LEN(aLin3)))
    
	    oExcel:AddRow(cPlan3,cTitulo3,{aLin3[nCont3][01],; // 01 A  
									   aLin3[nCont3][02],; // 02 B  
									   aLin3[nCont3][03],; // 03 C
									   aLin3[nCont3][04],; // 04 D   
									   aLin3[nCont3][05],; // 05 E
									   aLin3[nCont3][06],; // 06 F
									   aLin3[nCont3][07],; // 07 G
									   aLin3[nCont3][08] ; // 07 H
									                    }) 	
    Next nCont3
   
    // *** FINAL PLANILHA 3 *** //
   
    // *** INCIO PLANILHA 4 *** //
   
    aSort(afuncoes,,,{ |X, Y| (CVALTOCHAR(X[3]) + CVALTOCHAR(X[8])) < (CVALTOCHAR(Y[3]) + CVALTOCHAR(Y[8]))})
      
	cDataIniOld    := ''
	cDataIni       := ''
	cDataFinOld    := ''
	cDataFin       := ''
	cCodTercOld    := ''
	cCodTerc       := ''
	nCodEmpOld     := 0
	nCodEmp        := 0 
	nQtdFunc       := 0
	nTempoFunc     := 0
	nTempoRefeicao := 0
	nQtdTerceiro   := 0
	nQtdDia        := 0
	nMat           := 0
	nMatOld        := 0
	aDia           := {}
	aDias          := {}
	nContDias      := 0
	
    IF LEN(afuncoes) >= 2 	
	
	   For nCont4 := 1 To LEN(afuncoes)
	   
	   		IncProc("Carregando Dados para a Planilha4 de: " + cValtochar(nCont4) + ' at�: ' + cValtochar(LEN(afuncoes)))
	   		
	   		// *** inicio se o contador for igual a um carrega tamb�m as variaveis de old *** //
	   		
	   		IF nCont4 == 1
	   		
	   			nCodEmpOld   := afuncoes[nCont4][03]
				cCodTercOld  := afuncoes[nCont4][05]
	   		    nMatOld      := afuncoes[nCont4][08]
	   		    nQtdTerceiro := 1
	   		    
	   		ENDIF
	   		// *** final se o contador for igual a um carrega tamb�m as variaveis de old *** //
	   		
	   		IF nCont4 == LEN(afuncoes) //ultima linha
	   		
	   			nCodEmpOld      := 0 //forcar imprimir a ultima linha
	   			nQtdFunc        := nQtdFunc + 1
				nTempoFunc      := nTempoFunc + afuncoes[nCont4][09]
				nTempoRefeicao  := nTempoRefeicao + afuncoes[nCont4][10]
				
	   		ENDIF
	   		
	   		nCodEmp     := afuncoes[nCont4][03]
	   		Aadd(aDia,afuncoes[nCont4][01])
		    Aadd(aDias,aDia)
			aDia := {}
			
			IF nCodEmp  <> nCodEmpOld   	
			   
			   	nExcel4 := nExcel4 + 1
			   
			
				AADD(aLin4,{ "", ; // 01 A  
			   	             "", ; // 02 B   
			   	             "", ; // 03 C   
			   	             "", ; // 04 D  
			   	             "", ; // 05 E
			   	             ""  ; // 06 F
			   	                })
				                
				aLin4[nExcel4][01] := afuncoes[nCont4-1][03] //COD EMPRESA
				aLin4[nExcel4][02] := afuncoes[nCont4-1][04] //NOME EMPRESA
				aLin4[nExcel4][03] := nQtdTerceiro           //QTD FUNC
				
				// *** INICIO DIAS *** //
				IF LEN(aDias) >= 2 .AND. nCont4 <> LEN(afuncoes)
				
					ASIZE(aDias, LEN(aDias) - 1)   
				
				ENDIF
				
				aSort(aDias,,,{ |X, Y| (X[1]) < (Y[1])})
				
				cDataIniOld := aDias[1][1]
				cDataIni    := ''
				nQtdDia     := 1
				
				FOR nContDias:=1 TO Len(aDias)
				
				cDataIni := aDias[nContDias][1]
				
					IF cDataIni <> cDataIniOld
					
						nQtdDia     := nQtdDia + 1
					    cDataIniOld := cDataIni
					    
					ENDIF
				NEXT 
				
				aLin4[nExcel4][04] := nQtdDia                //QTD DIA
				cDataIniOld        := ''
				cDataIni           := ''
				nQtdDia            := 0
				aDia               := {}
				aDias              := {}
				Aadd(aDia,afuncoes[nCont4][01])
				Aadd(aDias,aDia)
				aDia := {}
				// *** FINAL DIAS *** //
				
				aLin4[nExcel4][05] := PICTUREHORA(Min2Hrs(nTempoFunc)) //TEMPO REAL
				aLin4[nExcel4][06] := PICTUREHORA(Min2Hrs(nTempoRefeicao)) //TEMPO DESCONTO ALMOCO
							
				nCodEmpOld         := nCodEmp
				cCodTercOld        := cCodTerc 
				nTempoFunc         := afuncoes[nCont4][09]
				nTempoRefeicao     := afuncoes[nCont4][10]
				nQtdTerceiro       := 0
			    
			ELSE
			
				nTempoFunc     := nTempoFunc + afuncoes[nCont4][09]
				nTempoRefeicao := nTempoRefeicao + afuncoes[nCont4][10]
			
			ENDIF	
			
			// *** INICIO VARIAVEL DE MATRICULA *** //
	   		nMat := afuncoes[nCont4][08]
	   		
	   		IF nMat <> nMatOld
	   		
	   			nQtdTerceiro := nQtdTerceiro + 1
	   			nMatOld      := nMat
	   			
	   		ENDIF
	   		// *** FINAL VARIAVEL DE MATRICULA *** //
	   		
	   	Next nCont4
	   	
	ELSE //para quando so tem um registro
	
		For nCont4 := 1 To LEN(afuncoes)
		
			nExcel4 := 1
			AADD(aLin4,{ "", ; // 01 A  
		   	             "", ; // 02 B   
		   	             "", ; // 03 C   
		   	             "", ; // 04 D  
		   	             "", ; // 05 E
		   	             ""  ; // 06 F
		   	                })
		   	                
		   	aLin4[nExcel4][01] := afuncoes[nCont4][03]                       // COD EMPRESA
			aLin4[nExcel4][02] := afuncoes[nCont4][04]                       // NOME EMPRESA
			aLin4[nExcel4][03] := 1                                          // QTD FUNC                
		   	aLin4[nExcel4][04] := 1                                          // QTD DIA 
		   	aLin4[nExcel4][05] := PICTUREHORA(Min2Hrs(afuncoes[nCont4][09])) // TEMPO REAL
			aLin4[nExcel4][06] := PICTUREHORA(Min2Hrs(afuncoes[nCont4][10])) // TEMPO DESCONTO ALMOCO           
					
	   	Next nCont4
   	
   	ENDIF
    
    For nCont4 := 1 To LEN(aLin4)
    
    	IncProc("Levando dados para a Planilha4: " + Cvaltochar(nCont4) + "/" + Cvaltochar(LEN(aLin4)))
    
	    oExcel:AddRow(cPlan4,cTitulo4,{aLin4[nCont4][01],; // 01 A  
									   aLin4[nCont4][02],; // 02 B  
									   aLin4[nCont4][03],; // 03 C
									   aLin4[nCont4][04],; // 04 D   
									   aLin4[nCont4][05],; // 05 E
									   aLin4[nCont4][06] ; // 06 F
									                    }) 	
    Next nCont4
   
   // *** FINAL PLANILHA 4 *** //
   
   // *** INICIO PLANILHA 5 *** //
   cMat           := ''
   nContMAt       := 0
   
   FOR nContMAt:= 1 TO LEN(aMatriculas)
   
   		IF nContMat == 1
   		
   			cMat := CVALTOCHAR(aMatriculas[nContMAt][1])
   		
   		ELSE
   		
   			cMat := cMat + ',' + CVALTOCHAR(aMatriculas[nContMAt][1])
   		
   		ENDIF
   
   NEXT nContMat
   
   nExcel5 := 0
   SqlPassagens(cMat)
	
   DBSELECTAREA("TRI")
   TRI->(DBGOTOP())
   WHILE TRI->(!EOF()) 
		
		IncProc("Gerando Planilha 5 " + DTOC(STOD(CVALTOCHAR(TRI->NU_DATA_REQUISICAO))) + '-' + TRI->NM_PESSOA)                                    
		nExcel5 := nExcel5 + 1
        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLin5,{ "", ; // 01 A  
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
		
		aLin5[nExcel5][01] := TRI->CD_LOG_ACESSO                                                                                      //A
		aLin5[nExcel5][02] := TRI->NU_CREDENCIAL                                                                                      //B
		aLin5[nExcel5][03] := IIF(TRI->NU_MATRICULA == 0 .AND. TRI->CD_VISITANTE > 0,TRI->NU_DOCUMENTO,TRI->NU_MATRICULA)             //C
		aLin5[nExcel5][04] := TRI->NM_PESSOA                                                                                          //D
		aLin5[nExcel5][05] := STOD(CVALTOCHAR(TRI->NU_DATA_REQUISICAO))                                                               //E
		aLin5[nExcel5][06] := SUBSTR(STRZERO(TRI->NU_HORA_REQUISICAO,4),1,2) + ':' +  SUBSTR(STRZERO(TRI->NU_HORA_REQUISICAO,4),3,2) //F
		aLin5[nExcel5][07] := TRI->NM_ESTRUTURA                                                                                       //G
		aLin5[nExcel5][08] := TRI->CD_EQUIPAMENTO                                                                                     //H
		aLin5[nExcel5][09] := TRI->DS_EQUIPAMENTO                                                                                     //I
		aLin5[nExcel5][10] := TRI->TP_EVENTO                                                                                          //J
		aLin5[nExcel5][11] := TRI->TP_SENTIDO_CONSULTA                                                                                //K
		aLin5[nExcel5][12] := TRI->CD_TIPO_CREDENCIAL                                                                                 //L
		aLin5[nExcel5][13] := TRI->DS_TIPO_CREDENCIAL                                                                                 //M
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
				
		TRI->(dbSkip())    
	
	ENDDO //end do while TRB
	TRI->( DBCLOSEAREA() )
			
	//============================== INICIO IMPRIME LINHA NO EXCEL
	nExcel5 := 0 
	FOR nExcel5 := 1 TO Len(aLin5)
	
		IncProc("Carregando Planilha 5 " + CVALTOCHAR(nExcel5) + '/' + CVALTOCHAR(Len(aLin5)))
		
   		oExcel:AddRow(cPlan5,cTitulo5,{aLin5[nExcel5][01],; // 01 A  
        	                           aLin5[nExcel5][02],; // 02 B  
        	                           aLin5[nExcel5][03],; // 03 C  
   	        	                       aLin5[nExcel5][04],; // 04 D  
   	            	                   aLin5[nExcel5][05],; // 05 E  
   	                	               aLin5[nExcel5][06],; // 06 F  
   	                	               aLin5[nExcel5][07],; // 07 G  
   	                	               aLin5[nExcel5][08],; // 08 H
   	                	               aLin5[nExcel5][09],; // 09 I
   	                	               aLin5[nExcel5][10],; // 10 J
   	                	               aLin5[nExcel5][11],; // 11 K
   	                	               aLin5[nExcel5][12],; // 12 L
   	                	               aLin5[nExcel5][13] ; // 13 M
   	                	                                }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** FINAL PLANILHA 5 *** //
   
Return()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\" + cArquivo)

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\" + cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg() 
                                 
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    U_xPutSx1(cPerg,'01','Terceiro de                ?','','','mv_ch1','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Terceiro Ate               ?','','','mv_ch2','C',11,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Data De                    ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Data Ate                   ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Cod Estrutura Organiz. De  ?','','','mv_ch5','C',10,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Cod Estrutura Organiz. Ate ?','','','mv_ch6','C',10,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR06')
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Acesso Entrada "          ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial"               ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Tp Autentica��o "             ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Matricula "               ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Pessoa "                 ,1,1) // 05 E
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Descric�o Grupo Equipamento " ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Descric�o Equipamento "       ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "                     ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Data com Hora "               ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "                        ,1,1) // 11 K
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora"                         ,1,1) // 12 L
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Credencial "             ,1,1) // 13 M    
    oExcel:AddColumn(cPlanilha,cTitulo,"Desc Tipo Credencial "        ,1,1) // 14 N
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Estrutura "               ,1,1) // 15 O
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 16 P
  	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Acesso Saida "            ,1,1) // 17 Q
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial"               ,1,1) // 18 R
    oExcel:AddColumn(cPlanilha,cTitulo,"Tp Autentica��o "             ,1,1) // 19 S    
    oExcel:AddColumn(cPlanilha,cTitulo,"Num Matricula "               ,1,1) // 20 T
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Pessoa "                 ,1,1) // 21 U
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"Descric�o Grupo Equipamento " ,1,1) // 23 W
	oExcel:AddColumn(cPlanilha,cTitulo,"Descric�o Equipamento "       ,1,1) // 24 X
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "                     ,1,1) // 25 Y
	oExcel:AddColumn(cPlanilha,cTitulo,"Data com Hora "               ,1,1) // 26 Z
	oExcel:AddColumn(cPlanilha,cTitulo,"Data "                        ,1,1) // 27 AA
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora"                         ,1,1) // 28 AB
    oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Credencial "             ,1,1) // 29 AC    
    oExcel:AddColumn(cPlanilha,cTitulo,"Desc Tipo Credencial "        ,1,1) // 30 AD
    oExcel:AddColumn(cPlanilha,cTitulo,"Cod Estrutura "               ,1,1) // 31 AE
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "              ,1,1) // 32 AF
  	oExcel:AddColumn(cPlanilha,cTitulo,"Cod Fun��o "                  ,1,1) // 33 AG
  	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Fun��o "                 ,1,1) // 34 AH
  	oExcel:AddColumn(cPlanilha,cTitulo,"Tempo de Perman�ncia "        ,1,1) // 35 AI
  	oExcel:AddColumn(cPlanilha,cTitulo,"Tempo Real "                  ,1,1) // 36 AJ
  	oExcel:AddColumn(cPlanilha,cTitulo,"Tempo Descontado  Refei��o  " ,1,1) // 37 AK
  	
  	oExcel:AddworkSheet(cPlan2)
	oExcel:AddTable (cPlan2,cTitulo2)                                    
	oExcel:AddColumn(cPlan2,cTitulo2,"Data Inicial"                ,1,1) // 01 A
	oExcel:AddColumn(cPlan2,cTitulo2,"Data Final"                  ,1,1) // 02 B
	oExcel:AddColumn(cPlan2,cTitulo2,"Cod. Empresa"                ,1,1) // 03 C
	oExcel:AddColumn(cPlan2,cTitulo2,"Nome Empresa"                ,1,1) // 04 D
    oExcel:AddColumn(cPlan2,cTitulo2,"Cod. Fun��o"                 ,1,1) // 05 E
    oExcel:AddColumn(cPlan2,cTitulo2,"Nome Fun��o"                 ,1,1) // 06 F
    oExcel:AddColumn(cPlan2,cTitulo2,"Qtd Terceiros "              ,1,1) // 07 G    
    oExcel:AddColumn(cPlan2,cTitulo2,"Tempo Real "                 ,1,1) // 08 H
    oExcel:AddColumn(cPlan2,cTitulo2,"Tempo Descontado  Refei��o " ,1,1) // 09 I
    
    oExcel:AddworkSheet(cPlan3)
	oExcel:AddTable (cPlan3,cTitulo3)                                    
	oExcel:AddColumn(cPlan3,cTitulo3,"Cod. Empresa"               ,1,1) // 01 A
	oExcel:AddColumn(cPlan3,cTitulo3,"Nome Empresa"               ,1,1) // 02 B
    oExcel:AddColumn(cPlan3,cTitulo3,"Cod. Fun��o"                ,1,1) // 03 C
    oExcel:AddColumn(cPlan3,cTitulo3,"Nome Fun��o"                ,1,1) // 04 D
    oExcel:AddColumn(cPlan3,cTitulo3,"Qtd Terceiros "             ,1,1) // 05 E    
    oExcel:AddColumn(cPlan3,cTitulo3,"Qtd Dias   "                ,1,1) // 06 F
    oExcel:AddColumn(cPlan3,cTitulo3,"Tempo Real "                ,1,1) // 07 G
    oExcel:AddColumn(cPlan3,cTitulo3,"Tempo Descontado Refei��o " ,1,1) // 07 G
    
    oExcel:AddworkSheet(cPlan4)
	oExcel:AddTable (cPlan4,cTitulo4)                                    
	oExcel:AddColumn(cPlan4,cTitulo4,"Cod. Empresa"               ,1,1) // 01 A
	oExcel:AddColumn(cPlan4,cTitulo4,"Nome Empresa"               ,1,1) // 02 B
    oExcel:AddColumn(cPlan4,cTitulo4,"Qtd Terceiros "             ,1,1) // 03 C
    oExcel:AddColumn(cPlan4,cTitulo4,"Qtd Dias   "                ,1,1) // 04 D    
    oExcel:AddColumn(cPlan4,cTitulo4,"Tempo Real "                ,1,1) // 05 E
    oExcel:AddColumn(cPlan4,cTitulo4,"Tempo Descontado Refei��o " ,1,1) // 07 G
    
    oExcel:AddworkSheet(cPlan5)
    oExcel:AddTable (cPlan5,cTitulo5)
    oExcel:AddColumn(cPlan5,cTitulo5,"Cod Acesso"                 ,1,1) // 01 A
	oExcel:AddColumn(cPlan5,cTitulo5,"Num Credencial "            ,1,1) // 02 B
    oExcel:AddColumn(cPlan5,cTitulo5,"Matricula"                  ,1,1) // 03 C
    oExcel:AddColumn(cPlan5,cTitulo5,"Nome "                      ,1,1) // 04 D    
    oExcel:AddColumn(cPlan5,cTitulo5,"Data "                      ,1,1) // 05 E
    oExcel:AddColumn(cPlan5,cTitulo5,"Hora "                      ,1,1) // 06 F
    oExcel:AddColumn(cPlan5,cTitulo5,"Nome Estrutura "            ,1,1) // 07 G
  	oExcel:AddColumn(cPlan5,cTitulo5,"Codigo Equipamento "        ,1,1) // 08 H
	oExcel:AddColumn(cPlan5,cTitulo5,"Descric�o Equipamento "     ,1,1) // 09 I
	oExcel:AddColumn(cPlan5,cTitulo5,"Tipo Evento "               ,1,1) // 10 J
	oExcel:AddColumn(cPlan5,cTitulo5,"Sentido "                   ,1,1) // 11 K
	oExcel:AddColumn(cPlan5,cTitulo5,"Codigo Credencial "         ,1,1) // 12 L
	oExcel:AddColumn(cPlan5,cTitulo5,"Tipo Credencial "           ,1,1) // 13 M
    	
RETURN(NIL)

STATIC FUNCTION PICTUREHORA(nHora)

	Local cHoraConvert := ''

	IF AT('.',CVALTOCHAR(nHora)) == 0 //QUANDO E HORA CRAVADA EXEMPO 10 HORAS O FORMAT TEM QUE SER DIFERENTE.
	
		cHoraConvert := IIF(LEN(CVALTOCHAR(nHora)) == 1,'0' + CVALTOCHAR(nHora),CVALTOCHAR(nHora)) + ':00:00'
	
	ELSEIF nHora < 0 .AND. nHora > -10
	
		cHoraConvert := '-0' + SUBSTR(CVALTOCHAR(nHora),2,1) + ':' +  IIF(LEN(SUBSTR(CVALTOCHAR(nHora),4,2)) == 1,SUBSTR(CVALTOCHAR(nHora),4,2) + '0', SUBSTR(CVALTOCHAR(nHora),4,2))  + ':00' 
	
	ELSEIF nHora > 0 .AND. nHora < 1
	
		cHoraConvert := '00:' +  SUBSTR(CVALTOCHAR(nHora),3,2)  + ':00' 
					
	ELSEIF nHora >= 1 .AND. nHora < 10
	
		cHoraConvert := '0' + SUBSTR(CVALTOCHAR(nHora),1,1) + ':' + IIF(LEN(SUBSTR(CVALTOCHAR(nHora),3,2)) == 1,SUBSTR(CVALTOCHAR(nHora),3,2) + '0', SUBSTR(CVALTOCHAR(nHora),3,2)) + ':00'
	
	ELSEIF nHora >= 10 .AND. nHora < 99

		cHoraConvert := SUBSTR(CVALTOCHAR(nHora),1,2) + ':' + IIF(LEN(SUBSTR(CVALTOCHAR(nHora),4,2)) == 1,SUBSTR(CVALTOCHAR(nHora),4,2) + '0', SUBSTR(CVALTOCHAR(nHora),4,2)) + ':00'	
		
	ELSEIF nHora >= 100 .AND. nHora < 999

		cHoraConvert := SUBSTR(CVALTOCHAR(nHora),1,3) + ':' + IIF(LEN(SUBSTR(CVALTOCHAR(nHora),5,2)) == 1,SUBSTR(CVALTOCHAR(nHora),5,2) + '0', SUBSTR(CVALTOCHAR(nHora),5,2)) + ':00'	
	
	ELSE //maior que 1000
	
		cHoraConvert := SUBSTR(CVALTOCHAR(nHora),1,4) + ':' + IIF(LEN(SUBSTR(CVALTOCHAR(nHora),6,2)) == 1,SUBSTR(CVALTOCHAR(nHora),6,2) + '0', SUBSTR(CVALTOCHAR(nHora),6,2)) + ':00'
		
	ENDIF
			
RETURN(cHoraConvert)	

Static Function SqlMatriculas()

	BeginSQL Alias "TRA"
			%NoPARSER%
			SELECT NU_MATRICULA,
			       NM_PESSOA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA 
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
			  INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			     ON PESSOA.CD_ESTRUTURA_ORGANIZACIONAL  = ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL
			     AND NU_MATRICULA                      >= %EXP:MV_PAR01%
			     AND NU_MATRICULA                      <= %EXP:MV_PAR02%
			     //AND LEN(NU_MATRICULA)                 >= 10 // Para trazer s� os terceiros
			WHERE NU_ESTRUTURA                         >= %EXP:MV_PAR05%
			  AND NU_ESTRUTURA                         <= %EXP:MV_PAR06%
			  AND CD_ESTRUTURA_RELACIONADA              = 1223
			  
			  ORDER BY NU_MATRICULA
						
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
					        LOG_ACESSO.NU_MATRICULA,
					        LOG_ACESSO.NM_PESSOA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        LOG_ACESSO.NM_ESTRUTURA
					   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					           ON ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA >= %EXP:MV_PAR05%
							  AND ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA <= %EXP:MV_PAR06%
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
				               ON PESSOA.NU_MATRICULA = LOG_ACESSO.NU_MATRICULA 
					   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND LOG_ACESSO.NU_MATRICULA                                       = %EXP:cMat%
						AND CD_VISITANTE                                                 IS NULL
						AND LEN(LOG_ACESSO.NU_MATRICULA)                                 >= 10 // Para trazer s� os terceiros
						AND TP_SENTIDO_CONSULTA                                           = 1 //ENTRADA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 5 //Cancela Entrada Portaria
						 OR CD_EQUIPAMENTO                                                = 20) // 20-Balan�a de Entrada
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
						 
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
					        LOG_ACESSO.NU_MATRICULA,
					        LOG_ACESSO.NM_PESSOA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        ISNULL(PESSOA.TX_CAMPO06,'') AS TX_CAMPO06
					   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					           ON ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA >= %EXP:MV_PAR05%
							  AND ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA <= %EXP:MV_PAR06%
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
				               ON PESSOA.NU_MATRICULA = LOG_ACESSO.NU_MATRICULA	   
					   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND LOG_ACESSO.NU_MATRICULA                                       = %EXP:cMat%
						AND CD_VISITANTE                                                 IS NULL
						AND LEN(LOG_ACESSO.NU_MATRICULA)                                 >= 10 // Para trazer s� os terceiros
						AND TP_SENTIDO_CONSULTA                                           = 2 //SAIDA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
						 OR CD_EQUIPAMENTO                                                = 21) // 21-Balan�a de Sa�da
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
						 
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
					        LOG_ACESSO.NU_MATRICULA,
					        LOG_ACESSO.NM_PESSOA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        ISNULL(PESSOA.TX_CAMPO06,'') AS TX_CAMPO06
					   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					          ON ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA >= %EXP:MV_PAR05%
							 AND ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA <= %EXP:MV_PAR06%
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
				               ON PESSOA.NU_MATRICULA = LOG_ACESSO.NU_MATRICULA	   	   
					   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND LOG_ACESSO.NU_MATRICULA                                       = %EXP:cMat%
						AND CD_VISITANTE                                                 IS NULL
						AND LEN(LOG_ACESSO.NU_MATRICULA)                                 >= 10 // Para trazer s� os terceiros
						AND TP_SENTIDO_CONSULTA                                           = 2 //SAIDA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
						 OR CD_EQUIPAMENTO                                                = 21) // 21-Balan�a de Sa�da
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
						 
						 ORDER BY NU_HORA_REQUISICAO 
						
	EndSQl             
    
RETURN()       

Static Function SqlAcessoDia(cMat,cData)

	Local nFil     := 0                                       
		
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRE"
			%NoPARSER%
			 SELECT CD_LOG_ACESSO AS CD_LOG_ACESSO_SAIDA,
			        NU_CREDENCIAL,
			        LOG_ACESSO.TP_AUTENTICACAO,
			        NU_MATRICULA,
			        NM_PESSOA,
			        LOG_ACESSO.NM_ESTRUTURA,
			        DS_GRUPO,
			        DS_EQUIPAMENTO,
			        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA' END AS TP_SENTIDO_CONSULTA,
			        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
			        NU_DATA_REQUISICAO,
			        LOG_ACESSO.CD_TIPO_CREDENCIAL,
			        DS_TIPO_CREDENCIAL,
			        CD_ESTRUTURA,
			        LOG_ACESSO.NM_ESTRUTURA
			   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
			   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
				       ON CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA
				      AND CD_ESTRUTURA_RELACIONADA = 1223
			   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
			          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
			  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
				AND NU_MATRICULA                                                  = %EXP:cMat%
				AND CD_VISITANTE                                                 IS NULL
				//AND LEN(NU_MATRICULA)                                            >= 10 // Para trazer s� os terceiros
				AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
				 OR CD_EQUIPAMENTO                                                = 5 //Cancela Entrada Portaria
				 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
				 OR CD_EQUIPAMENTO                                                = 20 //Balan�a Entrada
				 OR CD_EQUIPAMENTO                                                = 21) //Balan�a Saida
				AND (TP_EVENTO                                                    = '27' // Acesso Master
				 OR TP_EVENTO                                                     = '10' // Acesso Concluido
				 OR TP_EVENTO                                                     = '12' // Acesso Batch
				 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
				 
				 ORDER BY DT_REQUISICAO
						
	EndSQl             
    
RETURN()

Static Function SqlRefeitorio(cMat,cData)

	Local nFil     := 0                                       
		
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRF"
			%NoPARSER%
			SELECT CD_LOG_ACESSO
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO 
			 INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
				     ON CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA
				    AND CD_ESTRUTURA_RELACIONADA = 1223 
		     WHERE NU_DATA_REQUISICAO   = %EXP:cData%
			   AND NU_MATRICULA         = %EXP:cMat%
			   AND CD_VISITANTE        IS NULL
			   //AND LEN(NU_MATRICULA)   >= 10      // Para trazer s� os terceiros
			   AND (CD_EQUIPAMENTO      = 1      // Restaurante 1
			    OR CD_EQUIPAMENTO       = 2)     // Restaurante 2
			   AND (TP_EVENTO           = '27'   // Acesso Master
			    OR TP_EVENTO            = '10'   // Acesso Concluido
				OR TP_EVENTO            = '12'   // Acesso Batch
				OR TP_EVENTO            = '23')  // Acesso por autoriza��o
			   AND TP_SENTIDO_CONSULTA  = 1
			   AND (NU_HORA_REQUISICAO BETWEEN '945' AND '1331'
				OR  NU_HORA_REQUISICAO BETWEEN '1800' AND '2345')
				  
				 ORDER BY DT_REQUISICAO
						
	EndSQl             
    
RETURN()

Static Function SqlEnt2(cMat,cData)

	Local nFil     := 0                                       
		
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRG"
			%NoPARSER%
			 SELECT TOP(1) CD_LOG_ACESSO AS CD_LOG_ACESSO_ENTRADA,
					        NU_CREDENCIAL,
					        LOG_ACESSO.TP_AUTENTICACAO,
					        LOG_ACESSO.NU_MATRICULA,
					        LOG_ACESSO.NM_PESSOA,
					        LOG_ACESSO.NM_ESTRUTURA,
					        DS_GRUPO,
					        DS_EQUIPAMENTO,
					        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA'END AS TP_SENTIDO_CONSULTA,
					        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
					        NU_DATA_REQUISICAO,
					        LOG_ACESSO.CD_TIPO_CREDENCIAL,
					        DS_TIPO_CREDENCIAL,
					        CD_ESTRUTURA,
					        LOG_ACESSO.NM_ESTRUTURA
					   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					           ON ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA >= %EXP:MV_PAR05%
							  AND ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA <= %EXP:MV_PAR06%
					   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
				               ON PESSOA.NU_MATRICULA = LOG_ACESSO.NU_MATRICULA 
					   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
					          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
					  WHERE NU_DATA_REQUISICAO                                            = %EXP:cData%
						AND LOG_ACESSO.NU_MATRICULA                                       = %EXP:cMat%
						AND CD_VISITANTE                                                 IS NULL
						AND LEN(LOG_ACESSO.NU_MATRICULA)                                 >= 10 // Para trazer s� os terceiros
						AND TP_SENTIDO_CONSULTA                                           = 1 //ENTRADA
						AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
						 OR CD_EQUIPAMENTO                                                = 5 //Cancela Entrada Portaria
						 OR CD_EQUIPAMENTO                                                = 20) //Balan�a Entrada
						AND (TP_EVENTO                                                    = '27' // Acesso Master
						 OR TP_EVENTO                                                     = '10' // Acesso Concluido
						 OR TP_EVENTO                                                     = '12' // Acesso Batch
						 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
						 
						 ORDER BY NU_HORA_REQUISICAO 
						
	EndSQl             
    
RETURN() 

Static Function SqlAcessoNoite(cMat,cDataIni,cDataFin)

	Local nFil     := 0                                       
		
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

    BeginSQL Alias "TRH"
			%NoPARSER%
			 SELECT CD_LOG_ACESSO AS CD_LOG_ACESSO_SAIDA,
			        NU_CREDENCIAL,
			        LOG_ACESSO.TP_AUTENTICACAO,
			        NU_MATRICULA,
			        NM_PESSOA,
			        LOG_ACESSO.NM_ESTRUTURA,
			        DS_GRUPO,
			        DS_EQUIPAMENTO,
			        CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA' END AS TP_SENTIDO_CONSULTA,
			        CONVERT(VARCHAR,DT_REQUISICAO, 120) AS DT_REQUISICAO,
			        NU_DATA_REQUISICAO,
			        LOG_ACESSO.CD_TIPO_CREDENCIAL,
			        DS_TIPO_CREDENCIAL,
			        CD_ESTRUTURA,
			        LOG_ACESSO.NM_ESTRUTURA
			   FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
			   INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
				       ON CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA
				      AND CD_ESTRUTURA_RELACIONADA    = 1223 
			   LEFT JOIN [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL
			          ON TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL
			  WHERE NU_DATA_REQUISICAO                                            >= %EXP:cDataIni%
			    AND NU_DATA_REQUISICAO                                            <= %EXP:cDataFin%
				AND NU_MATRICULA                                                  = %EXP:cMat%
				AND CD_VISITANTE                                                 IS NULL
				//AND LEN(NU_MATRICULA)                                            >= 10 // Para trazer s� os terceiros
				AND (CD_EQUIPAMENTO                                               = 4 //Catraca Portaria
				 OR CD_EQUIPAMENTO                                                = 5 //Cancela Entrada Portaria
				 OR CD_EQUIPAMENTO                                                = 6 //Cancela Saida Portaria
				 OR CD_EQUIPAMENTO                                                = 20 //Balan�a Entrada
				 OR CD_EQUIPAMENTO                                                = 21) //Balan�a Sa�da
				AND (TP_EVENTO                                                    = '27' // Acesso Master
				 OR TP_EVENTO                                                     = '10' // Acesso Concluido
				 OR TP_EVENTO                                                     = '12' // Acesso Batch
				 OR TP_EVENTO                                                     = '23')  // Acesso por autoriza��o
				 
				 ORDER BY DT_REQUISICAO
						
	EndSQl             
    
RETURN()

Static Function SqlPassagens(cMat,cDataIni,cDataFin)

	Local nFil     := 0   
	Local cDtIni   := ''
	Local cDtFin   := ''                                    
	Local cQuery   := ''
	Local cEquip   := ''
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

	cEquip   := '4,5,6,20,21'
	cDtIni   := DTOS(MV_PAR03)
	cDtFin   := DTOS(MV_PAR04)
	
	cQuery := "SELECT CD_LOG_ACESSO, "
	cQuery += "       NU_CREDENCIAL, "
	cQuery += "       NU_MATRICULA,  "
	cQuery += "       CD_VISITANTE,  "
	cQuery += "       NU_DOCUMENTO,  "
	cQuery += "       NM_PESSOA,  "
	cQuery += "       NU_DATA_REQUISICAO,  "
	cQuery += "       NU_HORA_REQUISICAO,  "
	cQuery += "       LOG_ACESSO.NM_ESTRUTURA,  "
	cQuery += "       CD_EQUIPAMENTO, " 
	cQuery += "       DS_EQUIPAMENTO,  "
	cQuery += "       CASE WHEN TP_EVENTO = 27 THEN 'ACESSO MASTER' ELSE CASE WHEN TP_EVENTO = 10 THEN 'ACESSO CONCLUIDO' ELSE CASE WHEN TP_EVENTO = 12 THEN 'ACESSO BATCH' ELSE CASE WHEN TP_EVENTO = 23 THEN 'ACESSO AUTORIZACAO EXCEPCIONAL' ELSE 'NAO PASSOU' END END END END AS TP_EVENTO,  "
	cQuery += "       CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA' END AS  TP_SENTIDO_CONSULTA,  "
	cQuery += "       LOG_ACESSO.CD_TIPO_CREDENCIAL, "
	cQuery += "       (SELECT DS_TIPO_CREDENCIAL FROM [DMPACESSO].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL WHERE TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL)  AS DS_TIPO_CREDENCIAL "
	cQuery += "       FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO "
	cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] "
	cQuery += "		    ON CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA "
    cQuery += "		   AND CD_ESTRUTURA_RELACIONADA    = 1223 "
	cQuery += " WHERE NU_DATA_REQUISICAO >= '" + cDtIni   + "' "
	cQuery += "   AND NU_DATA_REQUISICAO <= '" + cDtFin   + "' "
	cQuery += "   AND CD_EQUIPAMENTO     IN (" + cEquip + ") " 
	cQuery += "   AND NU_MATRICULA       IN (" + cMat + ") "
	//cQuery += "   AND LEN(NU_MATRICULA)  >= 10 " + " "
	cQuery += "   AND NU_MATRICULA       <> '999999999999999999' " + " "
	cQuery += "   ORDER BY LOG_ACESSO.CD_LOG_ACESSO " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRI",.F.,.T.)             
    
RETURN()
