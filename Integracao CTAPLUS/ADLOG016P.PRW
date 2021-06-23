#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"  
#INCLUDE "AP5MAIL.CH"   

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG016P ºAutor  ³WILLIAM COSTA       º Data ³  20/06/2016 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Programa de WebService - desenvolvido para cadastrar os     º±±
//±±º          ³consumo de oleo na logistica carregando na tabela SZI -     º±±
//±±º          ³Acrescimo e descrecimo para cobrar o oleo das transportadoraº±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAFAT                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±ºAdriana     ³24/05/2019³TI-Devido a substituicao email para shared     º±±
//±±º            ³          ³relay, substituido MV_RELACNT p/ MV_RELFROM    º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

USER FUNCTION ADLOG016P() 
	
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "ADLOG016P - Consumo de Valorização de Óleo CTAPLUS para Acrescimo e Decrescimo"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG016P'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de WebService - desenvolvido para cadastrar os consumo de oleo na logistica carregando na tabela SZI - Acrescimo e descrecimo para cobrar o oleo das transportadora')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Consumo de Valorização de Óleo CTAPLUS para Acrescimo e Decrescimo. " )
	
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||CarregaLogistica()},"Consumindo Óleo CTAPLUS","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	  
	FormBatch( cCadastro, aSays, aButtons )  
                        
RETURN(NIL)

STATIC FUNCTION CarregaLogistica()

	Private cHtmlPage   := ''                                   
	Private cHtmlPage1  := ''
	Private oXML        := NIL
	Private _cErro	    := ''
	Private _cAviso	    := ''
	Private nCont       := 0
	Private nCont1      := 0
	Private nCont2      := 0
	Private nCont3      := 0
	Private aOleo       := {}
	Private aOleos      := {}
	Private cDataini    := DTOC(MV_PAR01) //'25/08/2015'
	Private cDataFin    := DTOC(MV_PAR03) //'25/08/2015' //'26/09/2015'
	Private cHriniPar   := MV_PAR02
	Private cHrFinPar   := MV_PAR04
	Private cHrini      := ''
	Private cHrFin      := ''       
	Private cDtini      := ''
	Private cDtFin      := ''
	Private nStatus     := 0   
	Private nLitros     := 0
	Private nLitrosS500 := 0
	Private nLitrosS10  := 0
	Private cBomba      := ''      
	Private lSegue      := .F.
	Private cCod        := ''
	Private nVal        := 0
	Private nSeq        := 0
	Private cPlaca      := ''
	Private aOk         := {}
	Private aOks        := {} 
	Private nRateio     := 0   
	Private cOLS500     := ''
	Private cMETA       := ''
	Private cRAS500     := ''
	Private cOLS10      := ''
	Private cRAS10      := ''
	
	nLitros     := 0
	nLitrosS500 := 0
	nLitrosS10  := 0
	cBomba      := ''
	aOleo       := {}
	aOleos      := {}  
	cPlaca      := ''
	cHrini      := ''
	cHrFin      := ''
	
	SqlBuscaCTAPLUS()
	WHILE TRA->(!EOF())  
	
		DbSelectArea("ZBF")
	    dbSetOrder(2) 
	    IF DbSeek(xFilial("ZBF") + TRA->ZBB_PLACA,.T.) // Busca exata
	    
	    	ALERT("Existe Placa Generica no Fechamento " +TRA->ZBB_PLACA    + ;
	    	      " não é possivel continuar, favor ajustar o cadastro de "	+ ;
	    	      "Integração Cta Plus!!!")  
	    	                
	    	ZBF->(dbCloseArea())
	    	TRA->(dbCloseArea())      
	    	RETURN(NIL)
	        
		ENDIF 
		ZBF->(dbCloseArea())
		
		TRA->(DBSKIP())							
    ENDDO
	TRA->(dbCloseArea())
	
	SqlBuscaCTAPLUS()
	WHILE TRA->(!EOF())
	
		cBomba      := ALLTRIM(TRA->ZBB_BOMBA)
		cPlaca      := TRA->ZBB_PLACA
		cDtini      := TRA->ZBB_DTINI
		cDtFin      := TRA->ZBB_DTFIM
		cHrini      := TRA->ZBB_HRINI
		cHrFin      := TRA->ZBB_HRFIM
		nLitrosS500 := 0        
		nLitrosS10  := 0
		nVal        := 0
		nRateio     := 0
		
		SqlBuscaFrete()
		
		// ********** INICIO DE VALIDACAO   *********** //
		IF TRB->(!EOF()) == .F. 
		
			TRB->(dbCloseArea()) 
			SqlFreteTransp() // busca pelo transportador
			
			IF TRB->(!EOF()) == .F. 
			    
				aOleo := {}
				Aadd(aOleo,"Erro 1 - O Frete não foi encontrado hora: " +;
			         TRA->ZBB_HRINI + " até: " + TRA->ZBB_HRFIM +;
			         " Data: " + DTOC(STOD(TRA->ZBB_DTINI)) + " até: " + DTOC(STOD(TRA->ZBB_DTFIM)) +;
			         " Codigo CTAPLUS: " + TRA->ZBB_IDABAS + " -  Placa:" + TRA->ZBB_PLACA + " não lançado.")
				Aadd(aOleos,aOleo)   
				
			ENDIF		
		ENDIF
		
		// ********** FINAL DE VALIDACAO   *********** //
		  
		WHILE TRB->(!EOF())
		
			nLitrosS500 := 0        
			nLitrosS10  := 0
			nVal        := 0
			nRateio     := 0  
			
			// ********** INICIO DE VALIDACAO   *********** //
			IF (STOD(TRA->ZBB_DTINI)                      <= CTOD(cDataini)                          .AND. ;
			   SUBSTR(STRTRAN(TRA->ZBB_HRINI,':',''),1,6) <= SUBSTR(STRTRAN(cHriniPar,':',''),1,6)) .OR.  ;
			   (STOD(TRA->ZBB_DTINI)                      <   CTOD(cDataini)                         .OR.  ;
			   STOD(TRA->ZBB_DTFIM)                       >   CTOD(cDataFin))
			           
			   
				aOleo := {}
			    Aadd(aOleo,"Erro 2 - O Abastecimento está fora da Data e horario Inicial: " +;
			         TRA->ZBB_HRINI                                                  +;
			         " Data: " + DTOC(STOD(TRA->ZBB_DTINI))                          +;
			         " Codigo CTAPLUS: " + TRA->ZBB_IDABAS                           +; 
			         " -  Placa:" + TRA->ZBB_PLACA + " não lançado.")
			    Aadd(aOleos,aOleo)
			    
			    TRB->(DBSKIP())						
			    LOOP
			    
			ENDIF       
			
			IF (STOD(TRA->ZBB_DTFIM)                       >= CTOD(cDataFin)                         .AND. ;
			    SUBSTR(STRTRAN(TRA->ZBB_HRFIM,':',''),1,6) >= SUBSTR(STRTRAN(cHrFinPar,':',''),1,6)) .OR. ;
			    (STOD(TRA->ZBB_DTINI)                      <   CTOD(cDataini)                         .OR. ;
			    STOD(TRA->ZBB_DTFIM)                       >   CTOD(cDataFin))
			   
				aOleo := {}
			    Aadd(aOleo,"Erro 3 - O Abastecimento está fora da Data e horario Final: " +;
			         TRA->ZBB_HRFIM                                                +;
			         " Data: " + DTOC(STOD(TRA->ZBB_DTFIM))                        +;
			         " Codigo CTAPLUS: " + TRA->ZBB_IDABAS                         +;
			         " -  Placa:" + TRA->ZBB_PLACA + " não lançado.")
			    Aadd(aOleos,aOleo)
			    
			    TRB->(DBSKIP())						
			    LOOP
			    
			ENDIF       
			// ********** FINAL DE VALIDACAO   *********** //
			    
		    // ************ INICIO ENCONTRAR VALOR DO OLEO ****** //			              
		    IF TRA->ZBB_PLACA == TRA->ZBB_PLAORI //PLACA IGUAL NO ZBB
		    
			    IF ALLTRIM(cBomba) == 'S500'
			
					nLitrosS500 := TRA->ZBB_VOLUME
					
					SqlTabOleo(TRB->ZV4_OLS500)
					WHILE TRC->(!EOF())
					
						IF TRB->ZV4_META >= TRC->ZB9_META 
						       
							nRateio := TRB->ZV4_RAS500
							nVal    := ROUND(((nLitrosS500+ nRateio) * TRC->ZB9_VLS500),2)
					    
						ELSE                                     
						   
							SqlTabMulta(TRC->ZB9_CODMUL)
							WHILE TRD->(!EOF())
							        
								nRateio := TRB->ZV4_RAS500
								nVal    := ROUND(((nLitrosS500 + nRateio) * TRD->ZB9_VLS500),2)
								
								TRD->(DBSKIP())							
						    ENDDO
						    TRD->(dbCloseArea())	
						
						ENDIF
						TRC->(DBSKIP())							
				    ENDDO
				    TRC->(dbCloseArea())
					
				ELSE
				
					nLitrosS10  := TRA->ZBB_VOLUME
					
					SqlTabOleo(TRB->ZV4_OLS10)
					WHILE TRC->(!EOF())
					
						IF TRB->ZV4_META >= TRC->ZB9_META 
						    
							nRateio := TRB->ZV4_RAS10
							nVal    := ROUND(((nLitrosS10 + nRateio) * TRC->ZB9_VLS10 ),2)
					    
						ELSE                                     
						   
							SqlTabMulta(TRC->ZB9_CODMUL)
							WHILE TRD->(!EOF())
							    
								nRateio := TRB->ZV4_RAS10
								nVal    := ROUND(((nLitrosS10 + nRateio) * TRD->ZB9_VLS10 ),2)
								
								TRD->(DBSKIP())							
						    ENDDO
						    TRD->(dbCloseArea())	
						
						ENDIF
						TRC->(DBSKIP())							
				    ENDDO
				    TRC->(dbCloseArea())
				
			    ENDIF                                                   
			
			ELSE //PLACA DIFERENTE NO ZBB                               
			
				cOLS500     := POSICIONE("ZV4",1,xfilial("ZV4")+TRA->ZBB_PLAORI,"ZV4_OLS500")
				cMETA       := POSICIONE("ZV4",1,xfilial("ZV4")+TRA->ZBB_PLAORI,"ZV4_META")
				cRAS500     := POSICIONE("ZV4",1,xfilial("ZV4")+TRA->ZBB_PLAORI,"ZV4_RAS500")
				cOLS10      := POSICIONE("ZV4",1,xfilial("ZV4")+TRA->ZBB_PLAORI,"ZV4_OLS10")
				cRAS10      := POSICIONE("ZV4",1,xfilial("ZV4")+TRA->ZBB_PLAORI,"ZV4_RAS10")
				
				IF ALLTRIM(cBomba) == 'S500'
			
					nLitrosS500 := TRA->ZBB_VOLUME
					
					SqlTabOleo(cOLS500)
					WHILE TRC->(!EOF())
					
						IF cMETA >= TRC->ZB9_META 
						       
							nRateio := cRAS500
							nVal    := ROUND(((nLitrosS500+ nRateio) * TRC->ZB9_VLS500),2)
					    
						ELSE                                     
						   
							SqlTabMulta(TRC->ZB9_CODMUL)
							WHILE TRD->(!EOF())
							        
								nRateio := cRAS500
								nVal    := ROUND(((nLitrosS500 + nRateio) * TRD->ZB9_VLS500),2)
								
								TRD->(DBSKIP())							
						    ENDDO
						    TRD->(dbCloseArea())	
						
						ENDIF
						TRC->(DBSKIP())							
				    ENDDO
				    TRC->(dbCloseArea())
					
				ELSE
				
					nLitrosS10  := TRA->ZBB_VOLUME
					
					SqlTabOleo(cOLS10)
					WHILE TRC->(!EOF())
					
						IF cMETA >= TRC->ZB9_META 
						    
							nRateio := cRAS10
							nVal    := ROUND(((nLitrosS10 + nRateio) * TRC->ZB9_VLS10 ),2)
					    
						ELSE                                     
						   
							SqlTabMulta(TRC->ZB9_CODMUL)
							WHILE TRD->(!EOF())
							    
								nRateio := cRAS10
								nVal    := ROUND(((nLitrosS10 + nRateio) * TRD->ZB9_VLS10 ),2)
								
								TRD->(DBSKIP())							
						    ENDDO
						    TRD->(dbCloseArea())	
						
						ENDIF
						TRC->(DBSKIP())							
				    ENDDO
				    TRC->(dbCloseArea())
				
			    ENDIF                                                   
			ENDIF
		    // ************ FINAL ENCONTRAR VALOR DO OLEO ****** //
		    
		    // ************ INICIO GRAVAR O DESCONTO DO VALOR DO OLEO ****** //
		    
		    SqlTabSZI(TRB->ZK_PLACAPG,TRB->ZK_DTENTR,TRB->ZK_ROTEIRO)
		    
		    IF TRE->(!EOF()) == .F. .OR. ALLTRIM(TRE->ZI_SEQ) == ''
			    
				DBSELECTAREA("SZI")
	            Reclock("SZI",.T.)	
			    	SZI->ZI_DOC      := GetSX8NUM("SZI","ZI_DOC")
				    SZI->ZI_SEQ      := STRZERO(1,2)
			     	SZI->ZI_DATALAN  := STOD(TRB->ZK_DTENTR)   
				    SZI->ZI_PLACA    := TRA->ZBB_PLACA
			    	SZI->ZI_FORNEC   := TRB->ZK_FORNEC
				    SZI->ZI_LOJA     := TRB->ZK_LOJA
				    SZI->ZI_NOMFOR   := TRB->ZK_NOMFOR
				    SZI->ZI_ROTEIRO  := TRB->ZK_ROTEIRO  
				    SZI->ZI_GUIA     := TRB->ZK_GUIA 
				    SZI->ZI_DATAROT  := STOD(TRB->ZK_DTENTR)    
			        SZI->ZI_CODIGO   := IIF(ALLTRIM(TRB->ZK_CIDDEST) == '','55',IIF(SUBSTR(ALLTRIM(TRB->ZK_CIDDEST),1,2) == 'SP','55','58'))
	                SZI->ZI_TIPO     := 'D'
	                SZI->ZI_DESCRIC  := 'DIESEL'
	                SZI->ZI_OBS      :=  ALLTRIM(TRA->ZBB_BOMBA) + ': ' + ;
	                                     DTOC(STOD(TRA->ZBB_DTINI))               + ;
	                                     ' Lt: '                                  + ; 
	                                     CVALTOCHAR(TRA->ZBB_VOLUME + nRateio)
	                SZI->ZI_VALOR    := nVal  		     
	                SZI->ZI_IDABAS   := TRA->ZBB_IDABAS
	          	SZI->(MsUnlock())		    			
		      	ConfirmSX8()             
		      	SZI->(dbCloseArea())	  
		      	
		      	aOk := {}
		      	Aadd(aOk,"Sucesso 2 - O Roteiro/Data/Placa/Codigo/Valor("+TRB->ZK_ROTEIRO+"/"+TRB->ZK_DTENTR+"/"+TRB->ZK_PLACAPG+"/"+'55'+"/"+alltrim(STR(nVal))+") lançado com sucesso.")
			    Aadd(aOks,aOk) 
			    
			    CarregaZBB(TRA->ZBB_IDABAS,STOD(TRB->ZK_DTENTR),TRB->ZK_ROTEIRO)
		      
	        ENDIF               
		    
			WHILE TRE->(!EOF())
			    
				nSeq := VAL(TRE->ZI_SEQ)
				
				nSeq := nSeq + 1
	          	
	          	DBSELECTAREA("SZI")
	            Reclock("SZI",.T.)	
	            	SZI->ZI_DOC      := GetSX8NUM("SZI","ZI_DOC")
		      		SZI->ZI_SEQ      := STRZERO(nSeq,2)
		      		SZI->ZI_DATALAN  := STOD(TRB->ZK_DTENTR)    
		      		SZI->ZI_PLACA    := TRA->ZBB_PLACA
	    	  		SZI->ZI_FORNEC   := TRB->ZK_FORNEC
		      		SZI->ZI_LOJA     := TRB->ZK_LOJA
		      		SZI->ZI_NOMFOR   := TRB->ZK_NOMFOR
		      		SZI->ZI_ROTEIRO  := TRB->ZK_ROTEIRO  
		      		SZI->ZI_GUIA     := TRB->ZK_GUIA 
		      		SZI->ZI_DATAROT  := STOD(TRB->ZK_DTENTR)
	          		SZI->ZI_CODIGO   := IIF(ALLTRIM(TRB->ZK_CIDDEST) == '','55',IIF(SUBSTR(ALLTRIM(TRB->ZK_CIDDEST),1,2) == 'SP','55','58'))
	                SZI->ZI_TIPO     := 'D'
	                SZI->ZI_DESCRIC  := 'DIESEL'
	                SZI->ZI_OBS      :=  ALLTRIM(TRA->ZBB_BOMBA) + ': ' + ;
	                                     DTOC(STOD(TRA->ZBB_DTINI))               + ;
	                                     ' Lt: '                                  + ; 
	                                     CVALTOCHAR(TRA->ZBB_VOLUME + nRateio)
	                SZI->ZI_VALOR    := nVal  		                
	                SZI->ZI_IDABAS   := TRA->ZBB_IDABAS
	          	SZI->(MsUnlock())		    			
		      	ConfirmSX8()   
		      	SZI->(dbCloseArea())	  
		      	     
		      	aOk := {}
		      	Aadd(aOk,"Sucesso 1 - O Roteiro/Data/Placa/Codigo/Valor("+TRB->ZK_ROTEIRO+"/"+TRB->ZK_DTENTR+"/"+TRB->ZK_PLACAPG+"/"+'55'+"/"+alltrim(STR(nVal))+") lançado com sucesso.")
			    Aadd(aOks,aOk) 
			  
			    CarregaZBB(TRA->ZBB_IDABAS,STOD(TRB->ZK_DTENTR),TRB->ZK_ROTEIRO)
				
				TRE->(DBSKIP())							
		    ENDDO
		    TRE->(dbCloseArea())	
		    
		    // ************ FINAL GRAVAR O DESCONTO DO VALOR DO OLEO ****** //   
			
			TRB->(DBSKIP())							
	    ENDDO
	    TRB->(dbCloseArea()) 
		TRA->(DBSKIP())							
    ENDDO
	TRA->(dbCloseArea())     
    
    EnviaWF(aOleos,aOKs)
	
RETURN(NIL)  

Static Function EnviaWF(aOleos,aOKs)

	Local lOk           := .T.
	Local cBody         := RetHTML2(aOleos,aOKs)
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := AllTrim(GetMv("MV_#EMACTA"))
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""   
	Local cSubject      := ""          
	
	cSubject := "Carregamento de Oleo Logistica"
	
	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk
	
	If !lAutOk
	   If ( lSmtpAuth )
	      lAutOk := MailAuth(cAccount,cPassword)
	   Else
	      lAutOk := .T.
	   EndIf
	EndIf
	
	If lOk .And. lAutOk                
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk              
	   If !lOk
	      Get Mail Error cErrorMsg
	      ConOut("3 - " + cErrorMsg)
	   EndIf
	Else
	   Get Mail Error cErrorMsg
	   ConOut("4 - " + cErrorMsg)
	EndIf
	
	If lOk
	   Disconnect Smtp Server
	Endif
	
Return

Static Function RetHTML2(aOleos,aOKs)

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>"    
	
	cRet += "<b>Parâmetros.: </b>    " +;
	        "<br>" +;
			"<b>Data Inicial Fechamento ?.: </b>    " + DTOC(MV_PAR01) +;
			"<br>" +;
			"<b>Hora Inicial Fechamento ?.: </b>    " + MV_PAR02 +;
			"<br>" +;
			"<b>Data Final Fechamento   ?.: </b>    " + DTOC(MV_PAR03)+;
			"<br>" +;
			"<b>Hora Final Fechamento   ?.: </b>    " + MV_PAR04 +;
			"<br>" + "<br>"              
			
	cRet += "<b>Viagens com Sucesso: </b>    " + "<br>" + "<br>"              		
			
	FOR nCont2 := 1 TO LEN(aOKs)
                                                                                      
		cRet += "<b>Mensagem.: </b>    " + aOKs[nCont2][1] + ;
	            "<br>" + "<br>"                                  
	            
	NEXT    
	
	cRet += "<b>Viagens com Erro: </b>    " + "<br>" + "<br>"              		

	FOR nCont3 := 1 TO LEN(aOleos)
                                                                                      
		cRet += "<b>Mensagem.: </b>    " + aOleos[nCont3][1] + ;
	            "<br>" + "<br>"                                  
	            
	NEXT
	
	cRet += "<br>"
	cRet += "<br><br>É de extrema importância que seja feita a conferência."          
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> Depto de Tecnologia da Informacao <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'

Return(cRet)


Static Function MontaPerg() 
                                 
	Private bValid	:=Nil                                                                                                                    
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Data Inicial Fechamento ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Hora Inicial Fechamento ?','','','mv_ch02','C',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data Final Fechamento   ?','','','mv_ch03','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Hora Final Fechamento   ?','','','mv_ch04','C',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	Pergunte(cPerg,.T.)
	
Return (Nil) 


Static Function CarregaZBB(cId,dDtEntrAux,cRotAux) 

	IF cId <> ''
	
		DBSELECTAREA("ZBB")
	    DBSETORDER(1) 
	    IF DBSEEK(xFilial("ZBB")+cId, .T.)
	    
	    	Reclock("ZBB",.F.)	
	    	
				ZBB->ZBB_LOGIST := .T. 
				ZBB->ZBB_DTENTR := dDtEntrAux
				ZBB->ZBB_ROTEIR := cRotAux
				    
	        ZBB->(MsUnlock())		    			
	          	
		ENDIF        
	    
	    ZBB->(dbCloseArea())    
	    
	ENDIF
                                 
Return (Nil)          
                         

Static Function SqlBuscaCTAPLUS() 

	Local cSqlDtini    := DTOS(MV_PAR01)
	Local cSqlDtFin    := DTOS(MV_PAR03)

	BeginSQL Alias "TRA"
			%NoPARSER%   
	     SELECT ZBB_IDABAS,
				ZBB_DTINI,
				ZBB_HRINI,
				ZBB_DTFIM,
				ZBB_HRFIM,
				ZBB_VOLUME,
				ZBB_PLACA,	
				ZBB_PLAORI,	
				ZBB_BOMBA
			FROM %Table:ZBB% , %Table:ZV4%
			WHERE ZBB_DTINI         >= %EXP:cSqlDtini%
			  AND ZBB_DTINI         <= %EXP:cSqlDtFin%
			  AND ZBB_LOGIST         = 'F'
			  AND ZBB_CTAPLU         = 'T'       
			  AND ZBB_PLACA          = ZV4_PLACA         
			  AND ZV4_CTAPLU         = 'T'  
			  AND ZV4_PLACA          = ZBB_PLACA
              AND %Table:ZV4%.D_E_L_E_T_ <> '*'
			  AND %Table:ZBB%.D_E_L_E_T_ <> '*'
				   		
			ORDER BY ZBB_IDABAS
			
	EndSQl
RETURN(NIL)  

Static Function SqlBuscaFrete()
    
   	Local cDtIni2    := DTOS(CTOD(cDataini)+ 1)
    Local cDtFin2    := DTOS(CTOD(cDataFin)) 
	
	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT TOP(1) ZK_PLACAPG,
				          ZK_CIDDEST,
			              ZK_DTENTR,
						  ZK_ROTEIRO,
						  ZK_FORNEC,
						  ZK_LOJA,
						  ZK_NOMFOR,
						  ZK_GUIA,
						  ZV4_OLS10,
						  ZV4_OLS500,
						  ZV4_META,
						  ZV4_RAS10,
						  ZV4_RAS500
					FROM %Table:SZK%, %Table:ZV4%
			        WHERE ZK_PLACAPG  = %EXP:cPlaca%
			          AND ZK_DTENTR  >= %EXP:cDtIni2%
			          AND ZK_DTENTR  <= %EXP:cDtFin2%
					  AND ZK_PLACAPG    = ZV4_PLACA 
					  AND ZK_GUIA     = ''
					  AND ZV4_CTAPLU  = 'T'
					  AND %Table:SZK%.D_E_L_E_T_ <> '*'
					  AND %Table:ZV4%.D_E_L_E_T_ <> '*'
	EndSQl
RETURN(NIL) 

Static Function SqlFreteTransp()
                                      
    Local cDtIni2    := DTOS(CTOD(cDataini)+ 1)
	Local cDtFin2    := DTOS(CTOD(cDataFin)) 
	
	BeginSQL Alias "TRB"
			%NoPARSER%   
			SELECT TOP(1) ZK_PLACAPG,
			              ZK_CIDDEST,
			              ZK_DTENTR,
						  ZK_ROTEIRO,
						  ZK_FORNEC,
						  ZK_LOJA,
						  ZK_NOMFOR,
						  ZK_GUIA,
						  ZV4_OLS10,
						  ZV4_OLS500,
						  ZV4_FORNEC,
						  ZV4_LOJFOR,
						  ZV4_META,
						  ZV4_RAS10,
						  ZV4_RAS500 
					 FROM %Table:ZV4%, %Table:SZK%
					WHERE ZV4_PLACA         = %EXP:cPlaca%
					  AND ZV4_CTAPLU        = 'T'
					  AND ZK_FORNEC         = ZV4_FORNEC
					  AND ZK_LOJA           = ZV4_LOJFOR
					  AND ZK_PLACAPG        = ZV4_PLACA
					  AND ZK_DTENTR        >= %EXP:cDtIni2%
					  AND ZK_DTENTR        <= %EXP:cDtFin2%
					  AND ZK_GUIA           = ''
					  AND %Table:SZK%.D_E_L_E_T_ <> '*'
					  AND %Table:ZV4%.D_E_L_E_T_ <> '*'
			
			ORDER BY ZK_DTENTR  DESC
			
	EndSQl
RETURN(NIL) 

Static Function SqlTabOleo(cCodOleo)
   
	Local cFil      := xFilial("ZB9")
	
	BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT ZB9_CODTAB,
			       ZB9_TABOLE,
				   ZB9_VLS10,
				   ZB9_VLS500,
				   ZB9_CODMUL,
				   ZB9_TABMUL,
				   ZB9_META
			  FROM %Table:ZB9%
			 WHERE ZB9_FILIAL = %EXP:cFil%
			   AND ZB9_CODTAB = %EXP:cCodOleo%
			   AND D_E_L_E_T_ <> '*'
	EndSQl
RETURN(NIL) 

Static Function SqlTabMulta(cCodOleo)
   
	Local cFil      := xFilial("ZB9")
	
	BeginSQL Alias "TRD"
			%NoPARSER%
			SELECT ZB9_CODTAB,
			       ZB9_TABOLE,
				   ZB9_VLS10,
				   ZB9_VLS500,
				   ZB9_CODMUL,
				   ZB9_TABMUL,
				   ZB9_META
			  FROM %Table:ZB9%
			 WHERE ZB9_FILIAL = %EXP:cFil%
			   AND ZB9_CODTAB = %EXP:cCodOleo%
			   AND D_E_L_E_T_ <> '*'
	EndSQl
RETURN(NIL)             

Static Function SqlTabSZI(cPlaca,cDtEntrega,cRoteiro)
   
	BeginSQL Alias "TRE"
			%NoPARSER%
			SELECT TOP(1) ZI_SEQ 
			  FROM %Table:SZI%
			WHERE ZI_PLACA    = %EXP:cPlaca%
			  AND ZI_DATALAN  = %EXP:cDtEntrega%
			  AND (ZI_CODIGO   = '55'
			   OR  ZI_CODIGO   = '58')
			  AND ZI_ROTEIRO  = %EXP:cRoteiro%
			  AND D_E_L_E_T_ <> '*'
			
			  ORDER BY ZI_SEQ DESC
	EndSQl
RETURN(NIL)             