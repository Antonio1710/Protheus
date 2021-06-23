#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"        

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADVEN023P ºAutor  ³WILLIAM COSTA       º Data ³  15/07/2016 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ Programa de Inclusao ou exclusão da tabela ZB7 controle de º±±
//±±º          ³ codigos EDI.                                               º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAEST                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ADVEN023P()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "ADVEN023P - INCLUSÃO OU EXCLUSÃO DE CODIGOS DE BARRAS EDI"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADVEN023P'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Inclusao ou exclusão da tabela ZB7 controle de codigos EDI')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Efetua inclusão ou exclusão da tabela ZB7 - Codigos de Barras EDI. " )
	
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ProcFile()},"Carregando EDI","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	  
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)

Static Function ProcFile() 

	Private cMensagem := '' 
	Private cCodBar   := ''
	Private cCodRede  := ''
	Private cCodCli   := ''
	
	IF MV_PAR09 == 1 // Verifica Integridade ? 1 = não  2 = sim

		IF MV_PAR01 == 1 .AND. MV_PAR02 == 1 // Inclusao por Rede
	    
		    SqlIncRede()  
		                        
		    While TRB->(!EOF()) 
		    
		    	SqlIncProduto()
		    	While TRE->(!EOF())   
		    	
		    		DbSelectArea("ZB7")  
		    		dbSetOrder(3) 
					IF !DbSeek(xFilial("ZB7") + TRB->A1_CODRED + TRE->B1_CODBAR,.T.)
		    			
		    			RecLock("ZB7",.T.)
						
							ZB7->ZB7_FILIAL := xFilial("ZB7")
							ZB7->ZB7_REDE   := TRB->A1_CODRED
							ZB7->ZB7_CODCLI := ''
							ZB7->ZB7_CODDE  := TRE->B1_CODBAR    
							ZB7->ZB7_CODPAR := TRE->B1_CODBAR    
						  
						ZB7->( MsUnLock() ) // Confirma e finaliza a operação
						
						cMensagem += "Produto: "                     + ALLTRIM(TRE->B1_COD) + " - " + TRE->B1_DESC + CHR(13) + CHR(10) + ;
					                 "Rede: "                        + TRB->A1_CODRED                               + CHR(13) + CHR(10) + ;
					                 "Cod Bar Adoro: "               + TRE->B1_CODBAR                               + CHR(13) + CHR(10) + ;
					                 "Cod Bar Cliente: "             + TRE->B1_CODBAR                               + CHR(13) + CHR(10) + ;
					                 "Motivo: Incluido com Sucesso "                                                + CHR(13) + CHR(10) + ;
					                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
					                 CHR(13) + CHR(10) 
				    ENDIF
					ZB7->( DBCLOSEAREA() )
		            TRE->(dbSkip())
				ENDDO
				TRE->(dbCloseArea())	
		    	TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
			
		ELSEIF MV_PAR01 == 1 .AND. MV_PAR02 == 2 // Inclusao por Codigo de Cliente
	    
		    SqlIncCodCli()  
		                        
		    While TRD->(!EOF())    
		                
		    	SqlIncProduto()
		    	While TRE->(!EOF())   
		    	
		    		DbSelectArea("ZB7")  
		    		dbSetOrder(4) 
					IF !DbSeek(xFilial("ZB7") + TRD->A1_COD + TRE->B1_CODBAR,.T.)
		    			
		    			RecLock("ZB7",.T.)
						
							ZB7->ZB7_FILIAL := xFilial("ZB7")
							ZB7->ZB7_REDE   := ''
							ZB7->ZB7_CODCLI := TRD->A1_COD
							ZB7->ZB7_CODDE  := TRE->B1_CODBAR    
							ZB7->ZB7_CODPAR := TRE->B1_CODBAR    
						  
						ZB7->( MsUnLock() ) // Confirma e finaliza a operação
						
						cMensagem += "Produto: "                     + ALLTRIM(TRE->B1_COD) + " - " + TRE->B1_DESC + CHR(13) + CHR(10) + ;
					                 "Cliente: "                     + TRD->A1_COD          + " - " + TRD->A1_NOME + CHR(13) + CHR(10) + ;
					                 "Cod Bar Adoro: "               + TRE->B1_CODBAR                              + CHR(13) + CHR(10) + ;
					                 "Cod Bar Cliente: "             + TRE->B1_CODBAR                              + CHR(13) + CHR(10) + ;
					                 "Motivo: Incluido com Sucesso "                                               + CHR(13) + CHR(10) + ;
					                 "---------------------------- "                                               + CHR(13) + CHR(10) + ;
					                 CHR(13) + CHR(10) 
				    ENDIF
					ZB7->( DBCLOSEAREA() )
		            TRE->(dbSkip())
				ENDDO
				TRE->(dbCloseArea())	
		        TRD->(dbSkip())
			ENDDO
			TRD->(dbCloseArea())	
			
		ELSEIF MV_PAR01 == 2 .AND. MV_PAR02 == 1 // Exclusão por Rede
	    
		    SqlIncRede()  
		                        
		    While TRB->(!EOF()) 
		    
		    	SqlIncProduto()
		    	While TRE->(!EOF())   
		    	
		    		DbSelectArea("ZB7")  
		    		dbSetOrder(3) 
					IF DbSeek(xFilial("ZB7") + TRB->A1_CODRED + TRE->B1_CODBAR,.T.)
		    			
		    			RecLock("ZB7",.F.)
						
							DBDELETE()    
						  
						ZB7->( MsUnLock() ) // Confirma e finaliza a operação
						
						cMensagem += "Produto: "                     + ALLTRIM(TRE->B1_COD) + " - " + TRE->B1_DESC + CHR(13) + CHR(10) + ;
					                 "Rede: "                        + TRB->A1_CODRED                               + CHR(13) + CHR(10) + ;
					                 "Cod Bar Adoro: "               + TRE->B1_CODBAR                               + CHR(13) + CHR(10) + ;
					                 "Cod Bar Cliente: "             + TRE->B1_CODBAR                               + CHR(13) + CHR(10) + ;
					                 "Motivo: Deletado com Sucesso "                                                + CHR(13) + CHR(10) + ;
					                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
					                 CHR(13) + CHR(10) 
				    ENDIF
					ZB7->( DBCLOSEAREA() )
		            TRE->(dbSkip())
				ENDDO
				TRE->(dbCloseArea())	
		    	TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
			
		ELSEIF MV_PAR01 == 2 .AND. MV_PAR02 == 2 // Exclusão por Codigo de Cliente
	    
		    SqlIncCodCli()  
		                        
		    While TRD->(!EOF())    
		                
		    	SqlIncProduto()
		    	While TRE->(!EOF())   
		    	
		    		DbSelectArea("ZB7")  
		    		dbSetOrder(4) 
					IF DbSeek(xFilial("ZB7") + TRD->A1_COD + TRE->B1_CODBAR,.T.)
		    			
		    			RecLock("ZB7",.F.)
						
							DBDELETE()    
						  
						ZB7->( MsUnLock() ) // Confirma e finaliza a operação
						
						cMensagem += "Produto: "                     + ALLTRIM(TRE->B1_COD) + " - " + TRE->B1_DESC + CHR(13) + CHR(10) + ;
					                 "Cliente: "                     + TRD->A1_COD          + " - " + TRD->A1_NOME + CHR(13) + CHR(10) + ;
					                 "Cod Bar Adoro: "               + TRE->B1_CODBAR                              + CHR(13) + CHR(10) + ;
					                 "Cod Bar Cliente: "             + TRE->B1_CODBAR                              + CHR(13) + CHR(10) + ;
					                 "Motivo: Deletado com Sucesso "                                               + CHR(13) + CHR(10) + ;
					                 "---------------------------- "                                               + CHR(13) + CHR(10) + ;
					                 CHR(13) + CHR(10) 
				    ENDIF
					ZB7->( DBCLOSEAREA() )
		            TRE->(dbSkip())
				ENDDO
				TRE->(dbCloseArea())	
		        TRD->(dbSkip())
			ENDDO
			TRD->(dbCloseArea())			
	    
	    ELSE 
	    
	    	ALERT("Faltando informações nas Perguntas, favor verificar!!!")
	    
	    ENDIF
	
	ELSE //verificação de integridade
	
		SqlVerEdi()     
		       
		IF TRC->(!EOF()) == .F.
		
			cMensagem += "Motivo: Tabela Vazia"          + CHR(13) + CHR(10) + ;
				         "---------------------------- " + CHR(13) + CHR(10) + ;
						 CHR(13) + CHR(10)  
						 
			
		ELSE  
		    
		    While TRC->(!EOF())            
		    
			    IF MV_PAR01 == 1
				    // *** INICIO INCLUSAO ****** //
				    // *** INICIO POR REDE  ***** //
					SqlVerRede()
					While TRF->(!EOF())            
					
						SqlVerProduto()
						While TRH->(!EOF())
						
							DbSelectArea("ZB7")  
				    		dbSetOrder(3) 
							IF !DbSeek(xFilial("ZB7") + TRF->A1_CODRED + TRH->B1_CODBAR,.T.)
				    			
				    			RecLock("ZB7",.T.)
								
									ZB7->ZB7_FILIAL := xFilial("ZB7")
									ZB7->ZB7_REDE   := TRF->A1_CODRED
									ZB7->ZB7_CODCLI := ''
									ZB7->ZB7_CODDE  := TRH->B1_CODBAR    
									ZB7->ZB7_CODPAR := TRH->B1_CODBAR    
								  
								ZB7->( MsUnLock() ) // Confirma e finaliza a operação
								
								cMensagem += "Produto: "                     + ALLTRIM(TRH->B1_COD) + " - " + TRH->B1_DESC + CHR(13) + CHR(10) + ;
							                 "Rede: "                        + TRF->A1_CODRED                               + CHR(13) + CHR(10) + ;
							                 "Cod Bar Adoro: "               + TRH->B1_CODBAR                               + CHR(13) + CHR(10) + ;
							                 "Cod Bar Cliente: "             + TRH->B1_CODBAR                               + CHR(13) + CHR(10) + ;
							                 "Motivo: Incluido com Sucesso "                                                + CHR(13) + CHR(10) + ;
							                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
							                 CHR(13) + CHR(10) 
						    ENDIF
							ZB7->( DBCLOSEAREA() )    
						    TRH->(dbSkip())
						ENDDO
						TRH->(dbCloseArea())			
					    TRF->(dbSkip())
					ENDDO
					TRF->(dbCloseArea())			
					// *** FINAL POR REDE  ***** //
					
					// *** INICIO POR COD CLIENTE  ***** //
					SqlVerCodCli()
					While TRG->(!EOF())            
					
						SqlVerProduto()
						While TRH->(!EOF())
						
							DbSelectArea("ZB7")  
				    		dbSetOrder(4) 
							IF !DbSeek(xFilial("ZB7") + TRG->A1_COD + TRH->B1_CODBAR,.T.)
				    			
				    			RecLock("ZB7",.T.)
								
									ZB7->ZB7_FILIAL := xFilial("ZB7")
									ZB7->ZB7_REDE   := ''
									ZB7->ZB7_CODCLI := TRG->A1_COD
									ZB7->ZB7_CODDE  := TRH->B1_CODBAR    
									ZB7->ZB7_CODPAR := TRH->B1_CODBAR    
								  
								ZB7->( MsUnLock() ) // Confirma e finaliza a operação
								
								cMensagem += "Produto: "                     + ALLTRIM(TRH->B1_COD) + " - " + TRH->B1_DESC + CHR(13) + CHR(10) + ;
							                 "Codigo Cliente: "              + TRG->A1_COD                                  + CHR(13) + CHR(10) + ;
							                 "Cod Bar Adoro: "               + TRH->B1_CODBAR                               + CHR(13) + CHR(10) + ;
							                 "Cod Bar Cliente: "             + TRH->B1_CODBAR                               + CHR(13) + CHR(10) + ;
							                 "Motivo: Incluido com Sucesso "                                                + CHR(13) + CHR(10) + ;
							                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
							                 CHR(13) + CHR(10) 
						    ENDIF
							ZB7->( DBCLOSEAREA() )    
						    TRH->(dbSkip())
						ENDDO
						TRH->(dbCloseArea())			
					    TRG->(dbSkip())
					ENDDO
					TRG->(dbCloseArea())			
					// *** FINAL POR COD CLIENTE  ***** //
					// *** FINAL INCLUSAO ****** //  
				
				ELSE
				
					// *** INICIO EXCLUSAO ****** //
				    // *** INICIO POR REDE  ***** //
				    SqlExcDePara()
					While TRI->(!EOF())
						            
						cCodBar   := TRI->ZB7_CODDE
						cCodRede  := TRI->ZB7_REDE
						SqlExcProduto()
						While TRJ->(!EOF()) 
						
							IF TRJ->B1_XEDI == 'F' 
						
								DbSelectArea("ZB7")  
					    		dbSetOrder(5) 
								IF DbSeek(xFilial("ZB7") + TRJ->B1_CODBAR,.T.)
					    			
					    			RecLock("ZB7",.F.)
									
										DBDELETE()    
									  
									ZB7->( MsUnLock() ) // Confirma e finaliza a operação
									
									cMensagem += "Produto: "                     + ALLTRIM(TRJ->B1_COD) + " - " + TRJ->B1_DESC + CHR(13) + CHR(10) + ;
								                 "Rede: "                        + TRI->ZB7_REDE                               + CHR(13) + CHR(10) + ;
								                 "Cod Bar Adoro: "               + TRI->ZB7_CODDE                               + CHR(13) + CHR(10) + ;
								                 "Cod Bar Cliente: "             + TRI->ZB7_CODPAR                                + CHR(13) + CHR(10) + ;
								                 "Motivo: Excluido com Sucesso "                                                + CHR(13) + CHR(10) + ;
								                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
								                 CHR(13) + CHR(10) 
								                 
								    ZB7->( DBCLOSEAREA() )                 
							    ENDIF
							ENDIF    
						    TRJ->(dbSkip())
						ENDDO
						TRJ->(dbCloseArea())
						
						SqlExcRede()
						While TRK->(!EOF()) 
						
							IF TRK->A1_XEDI == 'F'
						
								DbSelectArea("ZB7")  
					    		dbSetOrder(1) 
								IF DbSeek(xFilial("ZB7") + TRK->A1_CODRED,.T.)
					    			
					    			RecLock("ZB7",.F.)
									
										DBDELETE()    
									  
									ZB7->( MsUnLock() ) // Confirma e finaliza a operação
									
									cMensagem += "Produto: "                     + ''              + CHR(13) + CHR(10) + ;
								                 "Rede: "                        + TRI->ZB7_REDE   + CHR(13) + CHR(10) + ;
								                 "Cod Bar Adoro: "               + TRI->ZB7_CODDE  + CHR(13) + CHR(10) + ;
								                 "Cod Bar Cliente: "             + TRI->ZB7_CODPAR + CHR(13) + CHR(10) + ;
								                 "Motivo: Excluido com Sucesso "                   + CHR(13) + CHR(10) + ;
								                 "---------------------------- "                   + CHR(13) + CHR(10) + ;
								                 CHR(13) + CHR(10) 
								                 
								    ZB7->( DBCLOSEAREA() )                 
							    ENDIF
							ENDIF    
						    TRK->(dbSkip())
						ENDDO
						TRK->(dbCloseArea())
						TRI->(dbSkip())
					ENDDO
					TRI->(dbCloseArea())			
				    
					// *** FINAL POR REDE  ***** //
					
					// *** INICIO POR COD CLIENTE  ***** //
					
					SqlExcCodCli()
					While TRL->(!EOF())
						            
						cCodBar  := TRL->ZB7_CODDE
						cCodCli  := TRL->ZB7_CODCLI
						SqlExcProduto()
						While TRJ->(!EOF()) 
						
							IF TRJ->B1_XEDI == 'F'
						
								DbSelectArea("ZB7")  
					    		dbSetOrder(5) 
								IF DbSeek(xFilial("ZB7") + TRJ->B1_CODBAR,.T.)
					    			
					    			RecLock("ZB7",.F.)
									
										DBDELETE()    
									  
									ZB7->( MsUnLock() ) // Confirma e finaliza a operação
									
									cMensagem += "Produto: "                     + ALLTRIM(TRJ->B1_COD) + " - " + TRJ->B1_DESC + CHR(13) + CHR(10) + ;
								                 "Cod Cliente: "                 + TRL->ZB7_CODCLI                              + CHR(13) + CHR(10) + ;
								                 "Cod Bar Adoro: "               + TRL->ZB7_CODDE                               + CHR(13) + CHR(10) + ;
								                 "Cod Bar Cliente: "             + TRL->ZB7_CODPAR                              + CHR(13) + CHR(10) + ;
								                 "Motivo: Excluido com Sucesso "                                                + CHR(13) + CHR(10) + ;
								                 "---------------------------- "                                                + CHR(13) + CHR(10) + ;
								                 CHR(13) + CHR(10) 
								                 
								    ZB7->( DBCLOSEAREA() )                 
							    ENDIF
							ENDIF    
						    TRJ->(dbSkip())
						ENDDO
						TRJ->(dbCloseArea())
						
						SqlExCliente()
						While TRM->(!EOF()) 
						
							IF TRM->A1_XEDI == 'F'
						
								DbSelectArea("ZB7")  
					    		dbSetOrder(2) 
								IF DbSeek(xFilial("ZB7") + TRM->A1_COD,.T.)
					    			
					    			RecLock("ZB7",.F.)
									
										DBDELETE()    
									  
									ZB7->( MsUnLock() ) // Confirma e finaliza a operação
									
									cMensagem += "Produto: "                     + ''              + CHR(13) + CHR(10) + ;
								                 "Cod Cli: "                     + TRL->ZB7_CODCLI + CHR(13) + CHR(10) + ;
								                 "Cod Bar Adoro: "               + TRL->ZB7_CODDE  + CHR(13) + CHR(10) + ;
								                 "Cod Bar Cliente: "             + TRL->ZB7_CODPAR + CHR(13) + CHR(10) + ;
								                 "Motivo: Excluido com Sucesso "                   + CHR(13) + CHR(10) + ;
								                 "---------------------------- "                   + CHR(13) + CHR(10) + ;
								                 CHR(13) + CHR(10) 
								                 
								    ZB7->( DBCLOSEAREA() )                 
							    ENDIF
							ENDIF    
						    TRM->(dbSkip())
						ENDDO
						TRM->(dbCloseArea())
						TRL->(dbSkip())
					ENDDO
					TRL->(dbCloseArea())			
				    
					// *** FINAL POR COD CLIENTE  ***** //
					// *** FINAL EXCLUSAO ****** //
				ENDIF
				TRC->(dbSkip())
			ENDDO	
		ENDIF
		TRC->(dbCloseArea())    
	ENDIF    
	
    IF ALLTRIM(cMensagem) <> ''
    
    	U_ExTelaMen("ADVEN020P - Tela de Inclusão ou Exclusão EDI!!!", cMensagem, "Arial", 10, , .F., .T.)
    
    ELSEIF MV_PAR09 == 2 .AND. ALLTRIM(cMensagem) == ''
    
    	cMensagem += "Motivo: Integridade verificada com Êxito, sem alterações!!!" + CHR(13) + CHR(10) + ;
				         "------------------------------------------------------ " + CHR(13) + CHR(10) + ;
						 CHR(13) + CHR(10)  
    	
	    U_ExTelaMen("ADVEN020P - Tela de Inclusão ou Exclusão EDI!!!", cMensagem, "Arial", 10, , .F., .T.)
	    		
	ENDIF
	
	Msginfo('Processamento concluido com sucesso !!!')
	
Return( NIL )                              

Static Function MontaPerg()  
                                
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSX1(cPerg,'01','Executar na Tabela   ?','','','mv_ch01','N',01,0,1,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR01' ,'Inclusão','','','','Exclusão','','','','','','','','','','','')
    PutSX1(cPerg,'02','Buscar por           ?','','','mv_ch02','N',01,0,1,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR02' ,'Rede','','','','Codigo Cliente','','','','','','','','','','','')
    PutSx1(cPerg,'03','Produto De           ?','','','mv_ch03','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR03')
    PutSx1(cPerg,'04','Produto Ate          ?','','','mv_ch04','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Cliente De           ?','','','mv_ch05','C',06,0,0,'G',bValid,"SA1",cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Cliente Ate          ?','','','mv_ch06','C',06,0,0,'G',bValid,"SA1",cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Rede De              ?','','','mv_ch07','C',06,0,0,'G',bValid,"SZF",cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Rede Ate             ?','','','mv_ch08','C',06,0,0,'G',bValid,"SZF",cSXG,cPyme,'MV_PAR08')
	PutSX1(cPerg,'09','Verifica Integridade ?','','','mv_ch01','N',01,0,1,'C',bValid,cF3  ,cSXG,cPyme,'MV_PAR01' ,'Não','','','','Sim','','','','','','','','','','','')
	
	Pergunte(cPerg,.F.) 
	
Return (Nil)  

Static Function SqlIncRede()                   

	BeginSQL Alias "TRB"
			%NoPARSER%     
			SELECT A1_CODRED 
			  FROM %Table:SA1% 
			WHERE A1_CODRED  >= %exp:MV_PAR07%
			  AND A1_CODRED  <= %exp:MV_PAR08%
			  AND A1_MSBLQL   = '2'
			  AND A1_XEDI     = 'T'
			  AND A1_CODRED  <> ''
			  AND D_E_L_E_T_ <> '*'
			
			GROUP BY A1_CODRED 
    EndSQl             
RETURN(NIL)             

Static Function SqlVerEdi()                   

	BeginSQL Alias "TRC"
			%NoPARSER%     
			SELECT ZB7_REDE,
			       ZB7_CODCLI,
				   ZB7_CODDE,
				   ZB7_CODPAR
			  FROM %Table:ZB7% 
			  WHERE D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)

Static Function SqlIncCodCli()          

	BeginSQL Alias "TRD"
			%NoPARSER%     
			SELECT A1_COD, 
			       A1_LOJA,
	               A1_NOME 
			  FROM %Table:SA1% 
			WHERE A1_COD     >= %exp:MV_PAR05%
			  AND A1_COD     <= %exp:MV_PAR06%
			  AND A1_CODRED   = ''
			  AND A1_MSBLQL   = '2'
			  AND A1_XEDI     = 'T'
			  AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)                

Static Function SqlIncProduto()

	BeginSQL Alias "TRE"
			%NoPARSER%     
		SELECT B1_COD, 
		       B1_DESC,
	           B1_CODBAR
		  FROM %Table:SB1% 
		WHERE B1_COD     >= %exp:MV_PAR03%
		  AND B1_COD     <= %exp:MV_PAR04%
		  AND B1_MSBLQL   = '2'
		  AND B1_XEDI     = 'T' 
	      AND B1_TIPO     = 'PA'
		  AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)

Static Function SqlVerRede()                   

	BeginSQL Alias "TRF"
			%NoPARSER%     
			SELECT A1_CODRED 
			  FROM %Table:SA1% 
			WHERE A1_CODRED  >= ''
			  AND A1_CODRED  <= 'ZZZZZZ'
			  AND A1_MSBLQL   = '2'
			  AND A1_XEDI     = 'T'
			  AND A1_CODRED  <> ''
			  AND D_E_L_E_T_ <> '*'
			
			GROUP BY A1_CODRED 
    EndSQl             
RETURN(NIL)             
                           

Static Function SqlVerCodCli()          

	BeginSQL Alias "TRG"
			%NoPARSER%     
			SELECT A1_COD, 
			       A1_LOJA,
	               A1_NOME 
			  FROM %Table:SA1% 
			WHERE A1_COD     >= ''
			  AND A1_COD     <= 'ZZZZZZ'
			  AND A1_CODRED   = ''
			  AND A1_MSBLQL   = '2'
			  AND A1_XEDI     = 'T'
			  AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)

Static Function SqlVerProduto()

	BeginSQL Alias "TRH"
			%NoPARSER%     
		SELECT B1_COD, 
		       B1_DESC,
	           B1_CODBAR
		  FROM %Table:SB1% 
		WHERE B1_COD     >= ''
		  AND B1_COD     <= 'ZZZZZZZZZZZZZZZ'
		  AND B1_MSBLQL   = '2'
		  AND B1_XEDI     = 'T' 
	      AND B1_TIPO     = 'PA'
		  AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)                

Static Function SqlExcDePara()

	BeginSQL Alias "TRI"
			%NoPARSER%     
			SELECT ZB7_REDE,
			       ZB7_CODDE,
				   ZB7_CODPAR 
			  FROM %Table:ZB7% 
			 WHERE ZB7_REDE <> ''
			   AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)    

Static Function SqlExcProduto()

	BeginSQL Alias "TRJ"
			%NoPARSER%     
			SELECT B1_COD,
			       B1_DESC,
				   B1_CODBAR,
				   B1_XEDI 
			  FROM %Table:SB1% 
			  WHERE B1_CODBAR = %exp:cCodBar%
			    AND B1_MSBLQL = '2'
				AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)     

Static Function SqlExcRede()

	BeginSQL Alias "TRK"
			%NoPARSER%     
			SELECT A1_CODRED,
			       A1_XEDI
			  FROM %Table:SA1% 
			WHERE A1_CODRED   = %exp:cCodRede%
			  AND A1_MSBLQL   = '2'
			  AND D_E_L_E_T_ <> '*'
			
			  GROUP BY A1_CODRED, A1_XEDI
    EndSQl             
RETURN(NIL)     
                             

Static Function SqlExcCodCli()

	BeginSQL Alias "TRL"
			%NoPARSER%     
			SELECT ZB7_CODCLI,
			       ZB7_CODDE,
				   ZB7_CODPAR 
			  FROM %Table:ZB7%
			 WHERE ZB7_CODCLI <> ''
			   AND D_E_L_E_T_ <> '*'
    EndSQl             
RETURN(NIL)    

Static Function SqlExCliente()

	BeginSQL Alias "TRM"
			%NoPARSER%     
			SELECT A1_COD,
			       A1_XEDI
			  FROM %Table:SA1%
			WHERE A1_COD      = %exp:cCodCli%
			  AND A1_MSBLQL   = '2'
			  AND D_E_L_E_T_ <> '*'
			
			  GROUP BY A1_COD, A1_XEDI
    EndSQl             
RETURN(NIL)     