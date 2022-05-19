#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.CH'  
#INCLUDE "rwmake.ch"    
#INCLUDE "TBICONN.CH"                               
#INCLUDE "VKEY.ch"

/*/{Protheus.doc} User Function ADFIN003
	PROGRAMA QUE IMPORTA O TXT QUE GERA O ARQUIVO DA CISP PARA PODER TER COMPARATIVOS DE VALORES.
	@type  Function
	@author WILLIAM COSTA
	@since 15/10/2015
	@history Ticket 3205 - William Costa - 08/10/2020 - Adicionado regra para o erro 25, onde foi feito um ajuste para o proprio fonte do Cisp arrumar o erro 25
	@history Ticket 3205 - Leonardo P. Monteiro - 08/10/2020 - Alterada a regra 19 para alerta e não erro na geração do arquivo para CISP. Após consulta a CISP os mesmos informam que não é um impeditivo para o envio do arquivo.
	@history Chamado TI  - Leonardo P. Monteiro - 22/02/2022 - Adição de históricos na gravação do valor acumulados.
	@history Ticket 73019 - 17/05/2022 - Adriano Savoine - Foi removido a Validação -3 pois nao existe no arquivo de validação CISP anexo no Ticket.
/*/

User Function ADFIN003P() 

    //Local cArqDest            := ''
    Local cArqDest1           := ''
   	Local cFileCopy           := ''
	Local nContVetor          := 0   
	//Local cFileCopy1          := ''
	Private cArq              := ''
	Private nHdl              := ''
	Private cLinha            := ''
	Private cValor            := 0
	Private cData             := '' 
	Private cMetodo           := ''
	Private nId               := 0 
	Private cMensagem         := '' 
	Private larqCisp          := .T.
	Private aInconsis         := {} 
	Private aErro             := {}
	Private aAlert            := {}
	Private nTentativa        := 0
	Private lErroArqOldArqNew := .F.                           
	Private cDtUltRe          := ''
	Private cDtAcuMu          := ''
	Private nVlAcumu          := ''
	Private lerroM2     	  := .F.
	Private lerroM4     	  := .F.
	Private lerro10     	  := .F.
    Private lerro13     	  := .F.
    Private lerro14     	  := .F.
    Private lerro18     	  := .F.
    Private lerro23     	  := .F.
	Private lerro25     	  := .F.
    Private lerro32     	  := .F.
    Private lerro43     	  := .F.
    Private lerro54     	  := .F.
	Private lerro56     	  := .F.
	Private nCErro      	  := 0
	Private nCErroOld   	  := 0 
	Private nTotErro    	  := 0
	Private cDtCorte		  := dtos(Date()-1)
	Private cArqOrig          := ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP.txt')
    Private cArqDest3         := ('SYSTEM\' + 'cisp\' + DTOS(DATE()+ 2)  + '_CISP.txt')
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	//RPCSetType(3)  //Nao consome licensas    
    //RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //  
	
	//ConOut("INICIO DO SCHEDULE ADFIN003P" + '||' + DTOC(DATE()) + '||' + TIME())
	ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Início da rotina.")  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PROGRAMA QUE IMPORTA O TXT QUE GERA O ARQUIVO DA CISP PARA PODER TER COMPARATIVOS DE VALORES.')
	
	IF GetMV("MV_#DTGACU") == DTOS(DATE()) .AND. ;
	   GetMV("MV_#GARQAC") == .F.
	   
	    cMetodo   := 'INCONSISTENCIA...'
		nId       := 4
		cmensagem := "Iniciando geracao do arquivo da cisp..."
		
		ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método EmailMaiorAcum.")  
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método EmailMaiorAcum.")

		cMetodo   := ''
		nId       := 0
		cmensagem := ''
	    
		ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método GERAARQCISP.")
	    GERAARQCISP()
		ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método GERAARQCISP.") 
		//BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt'p¿
		//³se gerou o arquivo da cisp corretamente na pasta                         ³
		//³                                                                         ³
		//³\\vpsrv01\d$\\totvs\Protheus11\Protheus_Data\SYSTEM\cisp                ³
		//³                                                                         ³
		//³então a variavel lArqCisp estará igual a TRUE e será feito o programa de ³
		//³validação do txt enviado.                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄt'pÙ
		//ENDDOC
		
		// ************* INICIO 1 VERIFICACAO ******************** //
		
	   	IF larqCisp  == .T.
		  ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método VerErro1.")
		  VerErro1()
		  ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método VerErro1.")
		ENDIF
		
		IF LEN(aInconsis) == 0
		                                   
		ELSE    
		
			lErroArqOldArqNew := .F.      
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método TRATARERROS.")
			TRATARERROS()
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método TRATARERROS.")

			aInconsis := {}
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método GERAARQCISP.")
			GERAARQCISP() 
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método GERAARQCISP.")
			
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método VerErro1.")
			VerErro1()
			ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método VerErro1.")

			IF LEN(aInconsis) > 0
			    lErroArqOldArqNew := .F.
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método TRATARERROS.")      
				TRATARERROS()  
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método TRATARERROS.")
				aInconsis := {}
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método GERAARQCISP.")
				GERAARQCISP()
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método GERAARQCISP.")
				
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método VerErro1.")
				VerErro1()           
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método VerErro1.")
			ENDIF
			                     
			IF LEN(aInconsis) > 0       
			    lErroArqOldArqNew := .F.
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método TRATARERROS.")
				TRATARERROS()  
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método TRATARERROS.")

				aInconsis := {}
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método GERAARQCISP.")
				GERAARQCISP()
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método GERAARQCISP.")
				
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Antes do método VerErro1.")
				VerErro1()
				ConOut("[ADFIN003P] "+ Dtoc(date())+"-"+ Time() +" - Após do método VerErro1.")
			ENDIF	    
		ENDIF //IF LEN(aInconsis) == 0                            
		
		// ************* FINAL 1 VERIFICACAO ******************** /      
		
		// ************* INICIO 2 VERIFICACAO ******************** /
		
		IF LEN(aInconsis) > 0 //para mandar email somente se tiver funcionarios a ser integrados.
	    	cMetodo   := 'INCONSISTENCIA...'
			nId       := 2
			cmensagem := "Verifique..."
			 
			EmailMaiorAcum(cMetodo,nId,cmensagem)
			
			cMetodo   := ''
			nId       := 0
			cmensagem := ''
			RETURN(NIL)
		ENDIF	
 	    
		IF larqCisp  == .T. .AND. LEN(aInconsis) == 0
		
		  VerErro2()
		  
		ENDIF
		
		//IF LEN(aInconsis) == 0
		//                                   
		//ELSE    
		//
		//	lErroArqOldArqNew := .T.
		//	    
		//    //TRATARERROS() 
		//	aInconsis := {}
		//	VerErro2()  
		//	
		//	IF LEN(aInconsis) > 0   
		//	    lErroArqOldArqNew := .T.
		//		//TRATARERROS()  
		//		aInconsis := {}
		//		VerErro2()    
		//	ENDIF	
		//		
		//ENDIF //IF LEN(aInconsis) == 0                            
		
		// ************* FINAL 2 VERIFICACAO ******************** //
		
		// ************* INICIO ULTIMA VERIFICACAO ******************** //
		
		IF LEN(aInconsis) == 0
		
		    aAlert := {} // esvazia o vetor de alerta pois estava duplicando registros 54 no vetor
			VerErro1()
			VerErro2()
		
		ENDIF
		
		IF LEN(aInconsis) > 0 //para mandar email somente se tiver funcionarios a ser integrados.
	    	cMetodo   := 'INCONSISTENCIA...'
			nId       := 2
			cmensagem := "Verifique..."
			 
			EmailMaiorAcum(cMetodo,nId,cmensagem)
			
			cMetodo   := ''
			nId       := 0
			cmensagem := ''
			
		ELSE    
		    
		    // INICIO MANDA EMAIL SE O ERRO FOR 54 SOMENTE ALERTA, ELSE DO ARQUIVO GERADO COM SUCESSO  //
			FOR nContVetor := 1 TO LEN(aAlert)
		    
			    cMetodo   := 'INCONSISTENCIA...'
				nId       := 2
				cmensagem := "Verifique..."
				 
				EmailMaiorAcum(cMetodo,nId,cmensagem)
				
				cMetodo   := ''
				nId       := 0
				cmensagem := ''
				EXIT
			
			NEXT	             
		    // FINAL MANDA EMAIL SE O ERRO FOR 54 SOMENTE ALERTA, ELSE DO ARQUIVO GERADO COM SUCESSO  //
		    
		    // INICIO MANDA EMAIL  DO ARQUIVO GERADO COM SUCESSO  //
			cMetodo    := 'INCONSISTENCIA...'
			nId        := 3
			cmensagem  := "Arquivo gerado com sucesso enviar para cisp..."
			cFileCopy  := ('SYSTEM\' + 'cisp\' + DTOS(DATE()) + '_cisp.txt')
			cArqDest1  := ('SYSTEM\' + 'cisp\' + 'arq_cisp_atual\' + 'PFJ_0138' + '.txt')
			
			IF FILE(cFileCopy)
				Copy File (cFileCopy) To  (cArqDest1) 
				//FRename(cFileCopy , cFileCopy1) 
			ENDIF
					 
			EmailMaiorAcum(cMetodo,nId,cmensagem)
			
			// *** INICIO quando o arquivo for na sexta ira fazer uma copia do arquivo *** //
		    // *** no domingo para quando chegar na segunda o programa ter o arquivo *** //
		    // *** de comparacao do dia anterior *** //
		    IF ALLTRIM(CDOW(DATE())) == 'Friday'  
		   
		   		Copy File (cArqOrig) To  (cArqDest3) 
		   		
		    ENDIF
		    // *** FINAL quando o arquivo for na sexta ira fazer uma copia do arquivo *** //
		    // *** no domingo para quando chegar na segunda o programa ter o arquivo *** //
		    // *** de comparacao do dia anterior *** //
		    
			cMetodo   := ''
			nId       := 0
			cmensagem := ''
			BACKUPCSVSA1(1)
	        IMPORTNOVOMAIORACUMULO()
	   		BACKUPCSVSA1(2)            
	   		PutMv("MV_#GARQAC",	.T.)
			//FINAL MANDA EMAIL  DO ARQUIVO GERADO COM SUCESSO  //
	    ENDIF
	    
	    // ************* FINAL ULTIMA VERIFICACAO ******************** //	
		  
	ENDIF //GETMV
	
	ConOut("FINAL DO SCHEDULE ADFIN003P" + '||' + DTOC(DATE()) + '||' + TIME())
	
	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	//RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	        
	
	
RETURN(NIL) 	  
	
Static Function GERAARQCISP()

	Local nTamLin
	Local cLin
	Local cCPO
	Local TempCampos	:= '' 
	Local _nCountStr	:= 00
	Local ValCampo		:= ""
	Local _cEOL 	    := Chr( 13 ) + Chr( 10 ) 
	
	SqlGeraCisp()   
	
	//dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "TMPCISP", .F., .T. )
	
	TempCampos	:= TMPCISP->( dbStruct() )
	dbSelectArea( "TMPCISP" )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArq := ''
	cArq := ('SYSTEM\' + 'cisp\' + DTOS(DATE()) + '_cisp.txt')
	nHdl := ''
	nHdl := FCreate( AllTrim(cArq))
	
	If nHdl == -1  
		cMetodo   := 'Não gerou o arquivo da cisp...ERRO(1)'
		nId       := 1
		cmensagem := "O Arquivo de nome " + AllTrim(cArq ) + " nao pode ser gerado Verifique...ERRO(1)"
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		larqCisp  := .F.
		cMetodo   := ''
		nId       := 0
		cmensagem := ''
		Return ( Nil )
	EndIf
	
	While TMPCISP->( !Eof() )
	
		cLin := ""
		
		For _nCountStr := 01 To Len( TempCampos )
	
			ValCampo := TempCampos[ _nCountStr, 01 ]
	
			cLin += &ValCampo
	
		Next
	
		cLin += _cEOL
	
		If FWrite( nHdl, cLin, Len( cLin ) ) != Len( cLin )
	
			If !MsgAlert( "Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao" )
				cMetodo   := 'Ocorreu um erro na gravacao do arquivo. Continua ERRO(2)'
				nId       := 1
				cmensagem := "O Arquivo de nome " + AllTrim(cArq ) + " nao pode ser gerado Verifique...ERRO(2)"
				 
				EmailMaiorAcum(cMetodo,nId,cmensagem)
				
				larqCisp  := .F.
				cMetodo   := ''
				nId       := 0
				cmensagem := ''
			
				Exit
			EndIf
			
		EndIf
	
		TMPCISP->( dbSkip() )
	
	EndDo
	
	TMPCISP->( dbCloseArea() )
	
	FClose( nHdl )

Return()

Static Function VerErro1() 

	Local _cFile      :=  ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP.txt')
	Local lArqOldLido := .F.
	Local nHdl1
	Local nTamArq1
	Local nTamLin1
	Local nByteLid1
	Local cLinha1
	Local cTexto1
	Local cEOL1
	Local cCnpj1       := ''                     
	Local cDtMaiorAcum := ''
	Local cVlMaiorAcum := ''
	Local nCont        := 0 
	Local lCont        := .F. 
	Local AA           := ''
	Local AB           := ''
	Local AC           := ''
	Local AD           := ''
	Local AE           := ''
	Local AF           := ''
	Local AG           := ''
	Local AH           := ''
	Local AI           := ''
	Local AJ           := ''
	Local AK           := ''
	Local AL           := ''
	Local AM           := ''
	Local AN           := ''
	Local AO           := ''
	Local AP           := ''
	Local AQ           := ''
	Local AR           := ''
	Local AT           := ''
	Local AU           := ''
	Local AV           := ''
	Local AX           := ''
	Local AZ           := ''
	Local BA           := ''
	Local BB           := ''
	Local BC           := ''
	Local BD           := ''
	Local BE           := ''
	Local BF           := ''
	Local BG           := ''
	Local BH           := ''


	//BEGINDOC
	// segue o apelido de cada campo
	// foi necessario colocar apelido pois devido a ter varias variaveis com nome parecido
	// o advpl nao identifica corretamente cada variavel por isso segue abaix a lista
	// de apelidos para cada variavel - WILLIAM COSTA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄias >¿
	//³APELIDO SEQ	CAMPO 	TIPO	TAM	POSIÇ.	    FORMATO	             DESCRIÇÃO	                                                      ³
	//³AA      01	PCTIPO	   N	01	 001 / 001	9	                 Identif. (1-CNPJ / 2-CPF)	                                      ³
	//³AB      02	PCCASS	   N	04	 002 / 005	9999	             Código do Associado	                                          ³
	//³AC      03	PCCCLI	   N	20	 006 / 025	99999999999999999999 Identificação. (CNPJ / CPF)	JURÍDICA  / FÍSICA                ³
	//³AD      04	PCDDAT	   N	08	 026 / 033	99999999(AAAAMMDD)	 Data da Informação	                                              ³
	//³AE      05	PCDCDD	   N	08	 034 / 041	99999999(AAAAMMDD)	 Data  Cadastramento do Cliente	                                  ³
	//³AF      06	PCDUCM	   N	08	 042 / 049	99999999(AAAAMMDD)	 Data da Última Compra	                                          ³
	//³AG      07	PCVULC	   N	13,2 050 / 064	999999999999999	     Valor da Última Compra	                                          ³
	//³AH      08	PCDMAC	   N	08	 065 / 072	99999999(AAAAMMDD)	 Data  do Maior Acúmulo	                                          ³
	//³AI      09	PCVMAC	   N	13,2 073 / 087	999999999999999	     Valor Maior Acúmulo	                                          ³
	//³AJ      10	PCVSAT	   N	13,2 088 / 102	999999999999999	     Valor Débito Atual Total	                                      ³
	//³AK      11	PCVLCR	   N	13,2 103 / 117	999999999999999	     Valor Limite de Crédito	                                      ³
	//³AL      12	PCQPAG	   N	04,2 118 / 123	999999	             Média Ponderada de Atraso nos Pagamentos (Títulos Pagos)	      ³
	//³AM      13	PCQDAP	   N	04,2 124 / 129	999999	             Média Aritm.Dias de Atraso Pagamento	                          ³
	//³AN      14	PCVDAV	   N	13,2 130 / 144	999999999999999	     Valor Débito Atual a Vencer	                                  ³
	//³AO      15	PCMDAV	   N	04,2 145 / 150	999999	             Média Ponderada de Títulos a Vencer	                          ³
	//³AP      16	PCMPMV	   N	04,2 151 / 156	999999	             Prazo Médio de Vendas 	                                          ³
	//³AQ      17	PCDATV	   N	13,2 157 / 171	999999999999999	     Valor Débito Atual Vencido + 5 Dias	                          ³
	//³AR      18	PCMPTV	   N	04	 172 / 175	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 5 Dias  ³
	//³AT      19	PCV+15D	   N	13,2 176 / 190	999999999999999	     Valor Débito Atual Vencido + 15 Dias	                          ³
	//³AU      20	PCM+15D	   N	04	 191 / 194	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 15 Dias ³
	//³AV      21	PCV+30D	   N	13,2 195 / 209	999999999999999	     Valor Débito Atual Vencido + 30 Dias	                          ³
	//³AX      22	PCM+30D	   N	04	 210 / 213	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 30 Dias ³
	//³AZ      23	PCDTPC	   N	08	 214 / 221	99999999(AAAAMMDD)	 Data da Penúltima Compra	                                      ³
	//³BA      24	PCVPCO	   N	13,2 222 / 236	999999999999999	     Valor da Penúltima Compra	                                      ³
	//³BB      25	PCVSIT	   N	01	 237 / 237	9	                 Situação do Cálculo Limite de Crédito	                          ³
	//³BC      26	PCTIPG	   N	01	 238 / 238	9 	                 Tipo de Garantia	                                              ³
	//³BD      27	PCGGA	   N	02	 239 / 240	99	                 Grau da Garantia - Hipoteca	                                  ³
	//³BE      28	PCDTG	   N	08	 241 / 248	99999999(AAAAMMDD)	 Data Validade da Garantia	                                      ³
	//³BF      29	PCVLG	   N	13,2 249 / 263	999999999999999	     Valor da Garantia	                                              ³
	//³BG      30	PCVPA	   N	13,2 264 / 278	999999999999999	     Valor da Venda Pagamento Antecipado	                          ³
	//³BH      31	PCSVV	   C	02	 279 / 280	"VV"   ou  "BRANCO"  Venda sem Crédito (ANTECIPADO)	                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄias >Ù
	//ENDDOC
	
	  
	//BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiccoes vetor aErro:                   ³
	//³1-) Codigo mais descricao do erro        ³
	//³2-) CNPJ do Cliente                      ³
	//³3-) valor do arquivo original 1          ³
	//³4-) valor da tabela ou arquivo anterior 1³
	//³5-) valor do arquivo original 2          ³
	//³6-) valor da tabela ou arquivo anterior 2³
	//³                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENDDOC
	
	// Se for especificado o drive no caminha do arquivo, sera procurado no
	// Client, caso contrario sera procurado no Server, no diretorio RooPath.
	
	// ****** INICIO VERIFICACAO 1  ******************************** //
	
	// Veja no arquivo FILEIO.CH os codigos de acesso e compartilhamento.
	nHdl1 := FOpen(_cFile, 64)
	
	// Caracteres de final de linha.
	cEOL1 := Chr(13)+Chr(10)
	
	If nHdl1 == -1
	    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(3)'
		nId       := 1
		cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(3)"
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		larqCisp  := .F.
		cMetodo   := ''
		nId       := 0
		cmensagem := ''
		Return(Nil)
	   
	EndIf
	
	nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
	FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
	nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
	cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
	nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
	cTexto1   := ""
	
	While nByteLid1 > 1
	    
		AA := Substr(cLinha1, 001, 001)
		AB := Substr(cLinha1, 002, 004)
		AC := Substr(cLinha1, 006, 020)
		AD := Substr(cLinha1, 026, 008)
		AE := Substr(cLinha1, 034, 008)
		AF := Substr(cLinha1, 042, 008)
		AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
		AH := Substr(cLinha1, 065, 008)
		AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
		AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
		AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
		AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
		AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
		AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
		AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
		AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
		AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
		AR := Substr(cLinha1, 172, 004) 
		AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
		AU := Substr(cLinha1, 191, 004) 
		AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
		AX := Substr(cLinha1, 210, 004)
		AZ := Substr(cLinha1, 214, 008)
		BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
		BB := Substr(cLinha1, 237, 001)
		BC := Substr(cLinha1, 238, 001)
		BD := Substr(cLinha1, 239, 002)
		BE := Substr(cLinha1, 241, 008)
		BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
		BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
		BH := Substr(cLinha1, 279, 002) 
		
		// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
		IF AA == '1' //entra porque e uma empresa   
		
			cCnpj1 := Substr(cLinha1, 18, 08)    
			
			SqlProcCgc(cCnpj1)                                               
			
			// ****** INICIO VERIFICACAO NA TABELA SA1  ********************* //
			While TRB->(!EOF())
	            
	            // ******************** INICIO ERRO -1 ***************** // 
		        IF (ALLTRIM(AH) <> ALLTRIM(TRB->A1_DTACUMU)  .OR. ;
		            AI <> TRB->A1_VLACUMU) .AND. ; 
		           (ALLTRIM(AH)  == ''     .OR. ; 
		            AI           <= 0           )
		           
		        	AADD(aErro, "-1 - data do maior acumulo e Valor do Maior Acumulo diferente da tabela SA1 - William Costa") 
					AADD(aErro, 'CNPJ:' + cCnpj1)
					AADD(aErro, 'Dt. Maior Acum Arq:' + AH)
					AADD(aErro, 'Dt. Maior Acum TAB:' + TRB->A1_DTACUMU) 
					AADD(aErro, 'Vl. Maior Acum Arq:' + cvaltochar(AI))
					AADD(aErro, 'Vl. Maior Acum TAB:' + cvaltochar(TRB->A1_VLACUMU) ) 
					AADD(aInconsis, aErro) 
					aErro := {} 
		           
		        ENDIF                                                       
		        // ******************** FINAL ERRO -1 ***************** //   
		        
		        // ******************** INICIO ERRO -2 ***************** // 
		        IF AF <> ALLTRIM(TRB->A1_DTULTRE)  .OR. ;
		           ALLTRIM(AF)  == ''    
		           
		            AADD(aErro, "-2 - data da ultima compra do arquivo diferente da tabela SA1 - William Costa") 
					AADD(aErro, 'CNPJ:' + cCnpj1)
					AADD(aErro, 'Dt. ULT COMPRA Arq:' + AF)
					AADD(aErro, 'Dt. ULT COMPRA:' + TRB->A1_DTULTRE) 
					AADD(aErro, '')
					AADD(aErro, '') 
					AADD(aInconsis, aErro) 
					aErro := {} 
		           
		        ENDIF                                                       
		        // ******************** FINAL ERRO -2 ***************** //
		        
		        TRB->(DBSKIP())
			ENDDO
			TRB->(dbCloseArea())  
			// ****** FINAL VERIFICACAO NA TABELA SA1  ********************* //
			
			//Ticket 73019 - 17/05/2022 - Adriano Savoine
			// ******************** INICIO ERRO -3 ***************** // 
	       /* IF (AI == AJ * 100) .OR. (AI == AG * 100)
	           	           
	            AADD(aErro, "-3 - Valor do Maior Acumulo * 100 William Costa") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Valor do Maior Acumulo Arq:' + CVALTOCHAR(AI))
				AADD(aErro, 'Valor Debito Atual Arq :' + CVALTOCHAR(AJ)) 
				AADD(aErro, 'Valor Ultima Compra Arq :' + CVALTOCHAR(AG))
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF    */                                                   
	        // ******************** FINAL ERRO -3 ***************** //
			
			// ******************** INICIO ERRO 3 ***************** // 
	        IF AD > DTOS(DATE())
	           	           
	            AADD(aErro, "03 - Data Informação > Data do dia") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. da Informacao Arq:' + AD)
				AADD(aErro, 'Dt. data do dia Arq :' + DTOS(DATE())) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 3 ***************** //
	        
	        // ******************** INICIO ERRO 4 ***************** // 
	        IF AE > AD
	           	           
	            AADD(aErro, "04 - Data Cliente Desde > Data da Informação") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. da Informacao Arq:' + AD)
				AADD(aErro, 'Dt. data DESDE do Arq:' + AE) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 4 ***************** //
			
			// ******************** INICIO ERRO 5 ***************** // 
	        IF AF < AE
	           	           
	            AADD(aErro, "05 - Data da ultima compra menor que data cleinte desde") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. ULT COMPRA Arq:' + AF)
				AADD(aErro, 'Dt. CLIENTE DESDE :' + AE) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 5 ***************** //
	        
	        // ******************** INICIO ERRO 6 ***************** // 
	        IF AF > AD
	           	           
	            AADD(aErro, "06 - Data da ultima Compra > Data da Informacao") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. ULT COMPRA Arq:' + AF)
				AADD(aErro, 'Dt. INFORMACAO :' + AD) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 6 ***************** //
	        
	        // ******************** INICIO ERRO 8 ***************** // 
	        IF AH > AD
	           	           
	            AADD(aErro, "08 - Data do Maior Acumulo > Data da Informacao") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. Maior Acum Arq:' + AH)
				AADD(aErro, 'Dt. INFORMACAO :' + AD) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 8 ***************** //
	        
	        // ******************** INICIO ERRO 9 ***************** // 
	        IF AH < AE
	           	           
	            AADD(aErro, "09 - Data do Maior Acum < Data Cliente Desde") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. Maior Acum Arq:' + AH)
				AADD(aErro, 'Dt. Cliente Desde Arq :' + AE) 
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 9 ***************** //
	        
	        // ******************** INICIO ERRO 10 ***************** // 
	        IF AH > AF
	           	           
	            AADD(aErro, "10 - Data do Maior Acumulo maior que data da ultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt. MAIOR ACUM Arq:' + AH)
				AADD(aErro, 'Dt. ULT COMPRA Arq:' + AF)
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 10 ***************** //
	        
   	        // ******************** INICIO ERRO 11 ***************** // 
	        IF AI < AJ
	           	           
	            AADD(aErro, "11 - Valor do Maior Ac´´umulo Menor que Débito Atual") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Vl. MAIOR ACUM Arq:' + cvaltochar(AI))
				AADD(aErro, 'Debito Atual   Arq:' + cvaltochar(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 11 ***************** //
	        
	        // ******************** INICIO ERRO 12 ***************** // 
	        IF AI < AG
	           	           
	            AADD(aErro, "12 - Valor do Maior Acumulo < Valor Ultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Vl. MAIOR ACUM Arq:' + cvaltochar(AI))
				AADD(aErro, 'Vl Ult Compra  Arq:' + cvaltochar(AG))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 12 ***************** //
	        
	        // ******************** INICIO ERRO 13 ***************** // 
	        IF (AZ == '00000000' .AND. BA > 0)  .OR. ;
	           (AZ <> '00000000' .AND. BA == 0) .OR. ;
	           (AF == '00000000' .AND. AG > 0)  .OR. ;
	           (AF <> '00000000' .AND. AG == 0) 
	           	           
	            AADD(aErro, "13 - Informacao Incompleta") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt Penultima Compra Arq:' + AZ)
				AADD(aErro, 'Vl Penultima Compra Arq:' + cvaltochar(BA))
				AADD(aErro, 'Dt ultima Compra Arq:'    + AF)
				AADD(aErro, 'Vl ultima Compra Arq:'    + cvaltochar(AG)) 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 13 ***************** //
	        
	        // ******************** INICIO ERRO 15 ***************** // 
	        IF  VAL(AR) > 0 .AND. AQ == 0 
	           	           
	            AADD(aErro, "15 - Media atraso vencidos a + 5 dias sem debito vencido a + 5 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Vencimento 5 dias Arq:' + AR)
				AADD(aErro, 'Valor Debito 5 dias Arq:' + cvaltochar(AQ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 15 ***************** //
	        
	        // ******************** INICIO ERRO 18 ***************** // 
	        IF  AF <= AZ 
	           	           
	            AADD(aErro, "18 - Data da Ultima Compra <= Data Penultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Ultima Compra Arq:' + AF)
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 18 ***************** //
	        
			// ******************** INICIO ERRO 21 ***************** // 
	        IF  AQ > AJ
	           	           
	            AADD(aErro, "21 - Debito Vencido a + 5 dias > Debito Atual") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual + 5 Arq:' + CVALTOCHAR(AQ))
				AADD(aErro, 'Debito Atual:' + CVALTOCHAR(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 21 ***************** //
			
			// ******************** INICIO ERRO 25 ***************** // 
	        IF  AJ < AN
	           	           
	            AADD(aErro, "25 - Debito atual Total < Debito Atual a Vencer") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual a Vencer Arq:' + CVALTOCHAR(AN))
				AADD(aErro, 'Debito Atual:' + CVALTOCHAR(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 25 ***************** //			
	        
	        // ******************** INICIO ERRO 26 ***************** // 
	        IF  AJ < AT
	           	           
	            AADD(aErro, "26 - Debito atual Total < Debito Atual Vencido a + 15 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual Vencido a + 15 dias Arq:' + CVALTOCHAR(AT))
				AADD(aErro, 'Debito Atual:' + CVALTOCHAR(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 26 ***************** //			
	        
	        // ******************** INICIO ERRO 27 ***************** // 
	        IF  AJ < AV
	           	           
	            AADD(aErro, "27 - Debito atual Total < Debito Atual Vencido a + 30 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual Vencido a + 30 dias Arq:' + CVALTOCHAR(AV))
				AADD(aErro, 'Debito Atual:' + CVALTOCHAR(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 27 ***************** //			
	        
	        // ******************** INICIO ERRO 28 ***************** // 
	        IF  AM > 0 .AND. AL == 0
	           	           
	            AADD(aErro, "28 - Media Aritmetica Dias Atraso Pagamento Sem media Pondera Atraso Pagamento") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Atraso Pagamento Arq:' + CVALTOCHAR(AL))
				AADD(aErro, 'Media Aritmetica Dias Atraso Pagamento:' + CVALTOCHAR(AM))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 28 ***************** //			
	        
	        // ******************** INICIO ERRO 29 ***************** // 
	        IF  AL > 0 .AND. AM == 0
	           	           
	            AADD(aErro, "29 - Media Ponderada Atraso Pagamento Sem Media Aritmética Dias Atraso Pagamento") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Atraso Pagamento Arq:' + CVALTOCHAR(AL))
				AADD(aErro, 'Media Aritmetica Dias Atraso Pagamento:' + CVALTOCHAR(AM))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 29 ***************** //			
	        
	        // ******************** INICIO ERRO 30 ***************** // 
	        IF  AN > AJ 
	           	           
	            AADD(aErro, "30 - Debito atual a Vencer > Debito Atual Total") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito atual a Vencer Arq:' + CVALTOCHAR(AN))
				AADD(aErro, 'Debito Atual Total Arq:' + CVALTOCHAR(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 30 ***************** //			
	        
	        // ******************** INICIO ERRO 31 ***************** // 
	        IF   AN == 0 .AND. (AO > 0 .OR. AP > 0) 
	           	           
	            AADD(aErro, "31 - Media Ponderada Titulo a Vencer ou Prazo Medio Vendas Sem Debito Atual a Vencer") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Titulo a Vencer Arq:' + CVALTOCHAR(AO))
				AADD(aErro, 'Prazo Medio Vendas Arq:' + CVALTOCHAR(AP))
				AADD(aErro, 'Debito Atual a Vencer Arq:' + CVALTOCHAR(AN))
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 31 ***************** //			
	        
	        // ******************** INICIO ERRO 33 ***************** // 
	        IF   AN > 0 .AND. AO > 0 .AND. AP == 0
	           	           
	            AADD(aErro, "33 - Debito Atual a Vencer e Media Ponderada Titulo a Vencer sem Prazo Medio Venda") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Titulo a Vencer Arq:' + CVALTOCHAR(AO))
				AADD(aErro, 'Prazo Medio Vendas Arq:' + CVALTOCHAR(AP))
				AADD(aErro, 'Debito Atual a Vencer Arq:' + CVALTOCHAR(AN))
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 33 ***************** //			
			
			// ******************** INICIO ERRO 34 ***************** // 
	        IF   AT > AQ 
	           	           
	            AADD(aErro, "34 - Debito Atual Vencido a + 15 dias > Debito Atual Vencido a + 5 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual Vencido a + 15 dias Arq:' + CVALTOCHAR(AT))
				AADD(aErro, 'Debito Atual Vencido a + 5 dias Arq:' + CVALTOCHAR(AQ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 34 ***************** //
	        
	        // ******************** INICIO ERRO 35 ***************** // 
	        IF   VAL(AU) > 0 .AND. AT == 0
	           	           
	            AADD(aErro, "35 - Media POnderada Titulo Vencido a 15 dias sem debito atual vencido a + 15 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media POnderada Titulo Vencido a 15 dias Arq:' + AU)
				AADD(aErro, 'debito atual vencido a + 15 dias Arq:' + CVALTOCHAR(AT))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 35 ***************** //
	        
	        // ******************** INICIO ERRO 36 ***************** // 
	        IF   VAL(AU) > 0 .AND. VAL(AU) < 15
	           	           
	            AADD(aErro, "36 - Media Ponderada titulo vencido a + 15 dias < 15 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media POnderada Titulo Vencido a 15 dias Arq:' + AU)
				AADD(aErro, '')
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 36 ***************** //
	        
	        // ******************** INICIO ERRO 37 ***************** // 
	        IF   AT > 0 .AND. VAL(AU) == 0
	           	           
	            AADD(aErro, "37 - Debito Atual Vencido a 15 dias sem media ponderada titulo vencido a 15 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media POnderada Titulo Vencido a 15 dias Arq:' + AU)
				AADD(aErro, 'debito atual vencido a + 15 dias Arq:' + CVALTOCHAR(AT))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 37 ***************** //
	        
	        // ******************** INICIO ERRO 38 ***************** // 
	        IF   AV > AT
	           	           
	            AADD(aErro, "38 - Debito Atual Vencido a + 30 dias > Debito Atual Vencido a + 15 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito Atual Vencido a + 30 dias Arq:' + CVALTOCHAR(AV))
				AADD(aErro, 'Debito Atual Vencido a + 15 dias Arq:' + CVALTOCHAR(AT))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 38 ***************** //
	        
	        // ******************** INICIO ERRO 39 ***************** // 
	        IF   VAL(AX) > 0 .AND. AV == 0
	           	           
	            AADD(aErro, "39 - Media Ponderada Titulo Vencido + 30 dias sem debito atual Vencido + 30 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Titulo Vencido + 30 dias Arq:' + AX)
				AADD(aErro, 'debito atual Vencido + 30 dias Arq:' + CVALTOCHAR(AV))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 39 ***************** //	        
	        
	        // ******************** INICIO ERRO 40 ***************** // 
	        IF   VAL(AX) > 0 .AND. VAL(AX) < 30
	           	           
	            AADD(aErro, "40 - Media Ponderada Titulo Vencido + 30 dias < 30 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Titulo Vencido + 30 dias Arq:' + AX)
				AADD(aErro, '')
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 40 ***************** //	        
	        
	        // ******************** INICIO ERRO 41 ***************** // 
	        IF   AV > 0 .AND. VAL(AX) == 0
	           	           
	            AADD(aErro, "41 - Debito Atual Vencido a + 30 dias sem media Ponderada Titulo Vencido 30 dias") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Ponderada Titulo Vencido + 30 dias Arq:' + AX)
				AADD(aErro, 'debito atual Vencido + 30 dias Arq:' + CVALTOCHAR(AV))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 41 ***************** //	        
	        
	        // ******************** INICIO ERRO 42 ***************** // 
	        IF   AZ > AF
	           	           
	            AADD(aErro, "42 - Data Penultima Compra > Data Ultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, 'Data Ultima Compra Arq:' + AF)
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 42 ***************** //	        
	        
	        // ******************** INICIO ERRO 44 ***************** // 
	        IF   BA > 0 .AND. AZ == '00000000'
	           	           
	            AADD(aErro, "44 - Valor Penultima Compra Sem Data Penultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Valor Penultima Compra Arq:' + cvaltochar(BA))
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 44 ***************** //
	        
	        
	        // ******************** INICIO ERRO 45 ***************** // 
	        //IF   AK > 7
	           	           
	            //AADD(aErro, "45 - Situacao Calculo Limite Credito = 0 ou > 7") 
				//AADD(aErro, 'CNPJ:' + cCnpj1)
				//AADD(aErro, 'Valor Penultima Compra Arq:' + BA)
				//AADD(aErro, '')
				//AADD(aErro, '')
				//AADD(aErro, '') 
				//AADD(aInconsis, aErro) 
				//aErro := {} 
	           
	        //ENDIF                                                       
	        // ******************** FINAL ERRO 45 ***************** //
			                                                        
			// ******************** INICIO ERRO 46 ***************** // 
	        IF   AF > DTOS(DATE()) .AND. AJ == 0
	           	           
	            AADD(aErro, "46 - Data Ultima Compra > 12 Meses sem Debito Atual Total") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Ultima Compra Arq:' + AF)
				AADD(aErro, 'Debito Atual Total Arq:' + cvaltochar(AJ))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 46 ***************** //
	        
	        // ******************** INICIO ERRO 47 ***************** // 
	        IF   (AH > DTOS(DATE()) .AND. AF <= DTOS(DATE())) .OR.;
	             (AH < CVALTOCHAR(YEAR(DATE())-1 ) + STRZERO(MONTH(DATE()),2) + STRZERO(DAY(DATE()),2) .AND. AF >= CVALTOCHAR(YEAR(DATE())-1 ) + STRZERO(MONTH(DATE()),2) + STRZERO(DAY(DATE()),2)) 
	           	           
	            AADD(aErro, "47 - Data Maior Acumulo > 12 Meses com data ultima compra nos 12 meses") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
				AADD(aErro, 'data ultima compra nos 12 meses Arq:' + AF)
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 47 ***************** //
	        
	        // ******************** INICIO ERRO 49 ***************** // 
	        IF   AZ == '00000000' .AND. AH <> AF
	           	           
	            AADD(aErro, "49 - Sem data Penultima Compra com Data Maior Acumulo <> Data Ultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
				AADD(aErro, 'Data Ultima Compra Arq:' + AF)
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 49 ***************** //
					
			// ******************** INICIO ERRO 51 ***************** // 
	        IF   (AN + AQ) > AJ
	           	           
	            AADD(aErro, "51 - Debito a Vencer + Debito Vencido a + 5 Dias > Debito Atual Total") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Debito a Vencer Arq:' + CVALTOCHAR(AN))
				AADD(aErro, 'Debito Vencido a + 5 Dias Arq:' + CVALTOCHAR(AQ))
				AADD(aErro, 'Debito Atual Total Arq:' + CVALTOCHAR(AJ))
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 51 ***************** //
	        
	        // ******************** INICIO ERRO 55 ***************** // 
	        IF   (AO > 0 .AND. AO < 1) .OR. (AP > 0 .AND. AP < 1)
	           	           
	            AADD(aErro, "55 - Media Pond. Tit. A Vencer ou Prazo Medio Venda Menor que 1 e Maior que 0") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Media Pond. Tit. A Vencer Arq:' + CVALTOCHAR(AO))
				AADD(aErro, 'Prazo Medio Venda Arq:'         + CVALTOCHAR(AP))
				AADD(aErro, '')
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 55 ***************** //
	        
	        // ******************** INICIO ERRO 56 ***************** // 
	        IF   AI == AJ .AND. AH <> AF
	           	           
	            AADD(aErro, "56 - Vl Maior Acum igual Debito Atual e Dt Maior Acum Diferente Dt Ult Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Vl Maior Acum Arq:' + CVALTOCHAR(AI))
				AADD(aErro, 'Debito Atual Arq:' + CVALTOCHAR(AJ))
				AADD(aErro, 'Dt Maior Acum Diferente Arq:' + AH)
				AADD(aErro, 'Diferente Dt Ult Compra Arq:' + AF) 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 56 ***************** //
	        
	        // ******************** INICIO ERRO 61 ***************** // 
	        IF   (STOD(AD) - VAL(AR)) < STOD(AE)
	           	           
	            AADD(aErro, "61 - Dt Informada menos dias media Tit Venc + 5 Dias Menor data Cliente Desde") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Dt Informada Arq:' + AD)
				AADD(aErro, 'dias media Tit Venc + 5 Dias Arq:' + AR)
				AADD(aErro, 'data Cliente Desde Arq:' + AE) 
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 61 ***************** //
	        
	        // ******************** INICIO ERRO 62 ***************** // 
	        IF AZ <> '00000000' .AND. BA = 0
	           	           
	            AADD(aErro, "62 - Data Penultima Compra Sem Valor Penultima Compra") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, 'Valor Penultima Compra Arq:' + CVALTOCHAR(BA))
				AADD(aErro, '') 
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 62 ***************** //
	        
	        // ******************** INICIO ERRO 63 ***************** // 
	        IF AZ <> '00000000' .AND. AZ < AE
	           	           
	            AADD(aErro, "63 - Data Penultima Compra menor data cliente desde") 
				AADD(aErro, 'CNPJ:' + cCnpj1)
				AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
				AADD(aErro, 'Data cliente desde Arq:' + AE)
				AADD(aErro, '') 
				AADD(aErro, '') 
				AADD(aInconsis, aErro) 
				aErro := {} 
	           
	        ENDIF                                                       
	        // ******************** FINAL ERRO 63 ***************** //
	        
	        // *** FINAL DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
	        
	    ENDIF //IF AA == 1
		
		AA := ''
		AB := ''
		AC := ''
		AD := ''
		AE := ''
		AF := ''
		AG := ''
		AH := ''
		AI := ''
		AJ := ''
		AK := ''
		AL := ''
		AM := ''
		AN := ''
		AO := ''
		AP := ''
		AQ := ''
		AR := ''
		AT := ''
		AU := ''
		AV := ''
		AX := ''
		AZ := ''
		BA := ''
		BB := ''
		BC := ''
		BD := ''
		BE := ''
		BF := ''
		BG := ''
		BH := '' 
		
	    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
	
	EndDo
	
	FCLOSE(nHdl1)
	
	// ****** FINAL VERIFICACAO 1  ******************************** //
	
RETURN(NIL)           

Static Function VerErro2() 

	Local _cFile      := ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP.txt')
	Local _cFileOld   := ('SYSTEM\' + 'cisp\' + DTOS(DATE() - 1) + '_CISP.txt')
	Local lArqOldLido := .F.
	Local nHdl1
	Local nHdl2
	Local nTamArq1
	Local nTamArq2
	Local nTamLin1
	Local nTamLin2
	Local nByteLid1
	Local nByteLid2
	Local cLinha1
	Local cLinha2
	Local cTexto1
	Local cEOL1
	Local cEOL2
	Local cCnpj1       := ''                     
	Local cCnpj2       := ''                     
	Local cDtMaiorAcum := ''
	Local cVlMaiorAcum := ''
	Local nCont        := 0 
	Local lCont        := .F. 
	Local AA           := ''
	Local AB           := ''
	Local AC           := ''
	Local AD           := ''
	Local AE           := ''
	Local AF           := ''
	Local AG           := ''
	Local AH           := ''
	Local AI           := ''
	Local AJ           := ''
	Local AK           := ''
	Local AL           := ''
	Local AM           := ''
	Local AN           := ''
	Local AO           := ''
	Local AP           := ''
	Local AQ           := ''
	Local AR           := ''
	Local AT           := ''
	Local AU           := ''
	Local AV           := ''
	Local AX           := ''
	Local AZ           := ''
	Local BA           := ''
	Local BB           := ''
	Local BC           := ''
	Local BD           := ''
	Local BE           := ''
	Local BF           := ''
	Local BG           := ''
	Local BH           := ''
	Local AAOld        := ''
	Local ABOld        := ''
	Local ACOld        := ''
	Local ADOld        := ''
	Local AEOld        := ''
	Local AFOld        := ''
	Local AGOld        := ''
	Local AHOld        := ''
	Local AIOld        := ''
	Local AJOld        := ''
	Local AKOld        := ''
	Local ALOld        := ''
	Local AMOld        := ''
	Local ANOld        := ''
	Local AOOld        := ''
	Local APOld        := ''
	Local AQOld        := ''
	Local AROld        := ''
	Local ATOld        := ''
	Local AUOld        := ''
	Local AVOld        := ''
	Local AXOld        := ''
	Local AZOld        := ''
	Local BAOld        := ''
	Local BBOld        := ''
	Local BCOld        := ''
	Local BDOld        := ''
	Local BEOld        := ''
	Local BFOld        := ''
	Local BGOld        := ''
	Local BHOld        := ''

	//BEGINDOC
	// segue o apelido de cada campo
	// foi necessario colocar apelido pois devido a ter varias variaveis com nome parecido
	// o advpl nao identifica corretamente cada variavel por isso segue abaix a lista
	// de apelidos para cada variavel - WILLIAM COSTA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄias >¿
	//³APELIDO SEQ	CAMPO 	TIPO	TAM	POSIÇ.	    FORMATO	             DESCRIÇÃO	                                                      ³
	//³AA      01	PCTIPO	   N	01	 001 / 001	9	                 Identif. (1-CNPJ / 2-CPF)	                                      ³
	//³AB      02	PCCASS	   N	04	 002 / 005	9999	             Código do Associado	                                          ³
	//³AC      03	PCCCLI	   N	20	 006 / 025	99999999999999999999 Identificação. (CNPJ / CPF)	JURÍDICA  / FÍSICA                ³
	//³AD      04	PCDDAT	   N	08	 026 / 033	99999999(AAAAMMDD)	 Data da Informação	                                              ³
	//³AE      05	PCDCDD	   N	08	 034 / 041	99999999(AAAAMMDD)	 Data  Cadastramento do Cliente	                                  ³
	//³AF      06	PCDUCM	   N	08	 042 / 049	99999999(AAAAMMDD)	 Data da Última Compra	                                          ³
	//³AG      07	PCVULC	   N	13,2 050 / 064	999999999999999	     Valor da Última Compra	                                          ³
	//³AH      08	PCDMAC	   N	08	 065 / 072	99999999(AAAAMMDD)	 Data  do Maior Acúmulo	                                          ³
	//³AI      09	PCVMAC	   N	13,2 073 / 087	999999999999999	     Valor Maior Acúmulo	                                          ³
	//³AJ      10	PCVSAT	   N	13,2 088 / 102	999999999999999	     Valor Débito Atual Total	                                      ³
	//³AK      11	PCVLCR	   N	13,2 103 / 117	999999999999999	     Valor Limite de Crédito	                                      ³
	//³AL      12	PCQPAG	   N	04,2 118 / 123	999999	             Média Ponderada de Atraso nos Pagamentos (Títulos Pagos)	      ³
	//³AM      13	PCQDAP	   N	04,2 124 / 129	999999	             Média Aritm.Dias de Atraso Pagamento	                          ³
	//³AN      14	PCVDAV	   N	13,2 130 / 144	999999999999999	     Valor Débito Atual a Vencer	                                  ³
	//³AO      15	PCMDAV	   N	04,2 145 / 150	999999	             Média Ponderada de Títulos a Vencer	                          ³
	//³AP      16	PCMPMV	   N	04,2 151 / 156	999999	             Prazo Médio de Vendas 	                                          ³
	//³AQ      17	PCDATV	   N	13,2 157 / 171	999999999999999	     Valor Débito Atual Vencido + 5 Dias	                          ³
	//³AR      18	PCMPTV	   N	04	 172 / 175	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 5 Dias  ³
	//³AT      19	PCV+15D	   N	13,2 176 / 190	999999999999999	     Valor Débito Atual Vencido + 15 Dias	                          ³
	//³AU      20	PCM+15D	   N	04	 191 / 194	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 15 Dias ³
	//³AV      21	PCV+30D	   N	13,2 195 / 209	999999999999999	     Valor Débito Atual Vencido + 30 Dias	                          ³
	//³AX      22	PCM+30D	   N	04	 210 / 213	9999	             Média Ponderada de Atraso Títulos Vencidos e não Pagos + 30 Dias ³
	//³AZ      23	PCDTPC	   N	08	 214 / 221	99999999(AAAAMMDD)	 Data da Penúltima Compra	                                      ³
	//³BA      24	PCVPCO	   N	13,2 222 / 236	999999999999999	     Valor da Penúltima Compra	                                      ³
	//³BB      25	PCVSIT	   N	01	 237 / 237	9	                 Situação do Cálculo Limite de Crédito	                          ³
	//³BC      26	PCTIPG	   N	01	 238 / 238	9 	                 Tipo de Garantia	                                              ³
	//³BD      27	PCGGA	   N	02	 239 / 240	99	                 Grau da Garantia - Hipoteca	                                  ³
	//³BE      28	PCDTG	   N	08	 241 / 248	99999999(AAAAMMDD)	 Data Validade da Garantia	                                      ³
	//³BF      29	PCVLG	   N	13,2 249 / 263	999999999999999	     Valor da Garantia	                                              ³
	//³BG      30	PCVPA	   N	13,2 264 / 278	999999999999999	     Valor da Venda Pagamento Antecipado	                          ³
	//³BH      31	PCSVV	   C	02	 279 / 280	"VV"   ou  "BRANCO"  Venda sem Crédito (ANTECIPADO)	                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄias >Ù
	//ENDDOC
	
	  
	//BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiccoes vetor aErro:                   ³
	//³1-) Codigo mais descricao do erro        ³
	//³2-) CNPJ do Cliente                      ³
	//³3-) valor do arquivo original 1          ³
	//³4-) valor da tabela ou arquivo anterior 1³
	//³5-) valor do arquivo original 2          ³
	//³6-) valor da tabela ou arquivo anterior 2³
	//³                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENDDOC
	
	// Se for especificado o drive no caminha do arquivo, sera procurado no
	// Client, caso contrario sera procurado no Server, no diretorio RooPath.
	
	
	// ****** INICIO VERIFICACAO 2  ******************************** //
		
	// Veja no arquivo FILEIO.CH os codigos de acesso e compartilhamento.
	nHdl1 := FOpen(_cFile, 64)
	
	// Caracteres de final de linha.
	cEOL1 := Chr(13)+Chr(10)
	
	If nHdl1 == -1
	    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(3)'
		nId       := 1
		cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(3)"
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		larqCisp  := .F.
		cMetodo   := ''
		nId       := 0
		cmensagem := ''
		Return(Nil)
	   
	EndIf
	
	nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
	FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
	nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
	cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
	nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
	cTexto1   := ""
	
	While nByteLid1 > 1
	    
		AA := Substr(cLinha1, 001, 001)
		AB := Substr(cLinha1, 002, 004)
		AC := Substr(cLinha1, 006, 020)
		AD := Substr(cLinha1, 026, 008)
		AE := Substr(cLinha1, 034, 008)
		AF := Substr(cLinha1, 042, 008)
		AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
		AH := Substr(cLinha1, 065, 008)
		AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
		AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
		AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
		AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
		AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
		AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
		AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
		AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
		AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
		AR := Substr(cLinha1, 172, 004) 
		AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
		AU := Substr(cLinha1, 191, 004) 
		AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
		AX := Substr(cLinha1, 210, 004)
		AZ := Substr(cLinha1, 214, 008)
		BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
		BB := Substr(cLinha1, 237, 001)
		BC := Substr(cLinha1, 238, 001)
		BD := Substr(cLinha1, 239, 002)
		BE := Substr(cLinha1, 241, 008)
		BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
		BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
		BH := Substr(cLinha1, 279, 002) 
		
		// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
		IF AA == '1' //entra porque e uma empresa   
		
			cCnpj1 := Substr(cLinha1, 18, 08)    
			
			// *** INICIO DA VERIFICACAO DE INCONSISTENCIA COM O ARQUIVO ANTERIOR****** //
	        
	        nHdl2 := FOpen(_cFileOld, 64)
	
			// Caracteres de final de linha.
			cEOL2 := Chr(13)+Chr(10)
			
			If nHdl2 == -1
			    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(6)'
				nId       := 1
				cmensagem := "O Arquivo de nome " + AllTrim(_cFileOld ) + " nao pode ser aberto verifique se ele existe...ERRO(6)"
				 
				EmailMaiorAcum(cMetodo,nId,cmensagem)
				
				larqCisp  := .F.
				cMetodo   := ''
				nId       := 0
				cmensagem := ''
				Return(Nil)
			   
			EndIf
			
			nTamArq2 := FSeek(nHdl2, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
			FSeek(nHdl2, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
			nTamLin2  := 280 + Len(cEOL2)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
			cLinha2   := Space(nTamLin2)                 // Variavel que contera a linha lida.
			nByteLid2 := FRead(nHdl2, @cLinha2, nTamLin2)  // Le uma linha.
			cTexto2   := ""
			
			While nByteLid2 > 1    
			
				AAOld  := Substr(cLinha2, 001, 001)
				ABOld  := Substr(cLinha2, 002, 004)
				ACOld  := Substr(cLinha2, 006, 020)
				ADOld  := Substr(cLinha2, 026, 008)
				AEOld  := Substr(cLinha2, 034, 008)
				AFOld  := Substr(cLinha2, 042, 008)
				AGOld  := VAL(Substr(cLinha2, 050, 013) + '.' + Substr(cLinha2, 063, 002))
				AHOld  := Substr(cLinha2, 065, 008)
				AIOld  := VAL(Substr(cLinha2, 073, 013) + '.' + Substr(cLinha2, 086, 002))
				AJOld  := VAL(Substr(cLinha2, 088, 013) + '.' + Substr(cLinha2, 101, 002))
				AKOld  := VAL(Substr(cLinha2, 103, 013) + '.' + Substr(cLinha2, 116, 002))
				ALOld  := VAL(Substr(cLinha2, 118, 004) + '.' + Substr(cLinha2, 122, 002))
				AMOld  := VAL(Substr(cLinha2, 124, 004) + '.' + Substr(cLinha2, 128, 002))
				ANOld  := VAL(Substr(cLinha2, 130, 013) + '.' + Substr(cLinha2, 143, 002))
				AOOld  := VAL(Substr(cLinha2, 145, 004) + '.' + Substr(cLinha2, 149, 002))
				APOld  := VAL(Substr(cLinha2, 151, 004) + '.' + Substr(cLinha2, 155, 002))
				AQOld  := VAL(Substr(cLinha2, 157, 013) + '.' + Substr(cLinha2, 170, 002))
				AROld  := Substr(cLinha2, 172, 004) 
				ATOld  := VAL(Substr(cLinha2, 176, 013) + '.' + Substr(cLinha2, 189, 002))
				AUOld  := Substr(cLinha2, 191, 004) 
				AVOld  := VAL(Substr(cLinha2, 195, 013) + '.' + Substr(cLinha2, 208, 002))
				AXOld  := Substr(cLinha2, 210, 004)
				AZOld  := Substr(cLinha2, 214, 008)
				BAOld  := VAL(Substr(cLinha2, 222, 013) + '.' + Substr(cLinha2, 235, 002))
				BBOld  := Substr(cLinha2, 237, 001)
				BCOld  := Substr(cLinha2, 238, 001)
				BDOld  := Substr(cLinha2, 239, 002)
				BEOld  := Substr(cLinha2, 241, 008)
				BFOld  := VAL(Substr(cLinha2, 249, 013) + '.' + Substr(cLinha2, 262, 002))
				BGOld  := VAL(Substr(cLinha2, 264, 013) + '.' + Substr(cLinha2, 279, 002))
				BHOld  := Substr(cLinha2, 279, 002) 
				cCnpj2 := Substr(cLinha2, 18, 08)    
				
				IF cCnpj1 == cCnpj2 //acha o cnpj no arquivo anterior 
				
					// ******************** INICIO ERRO -4 ***************** // 
					
					 //Esse erro e igual ao 56 mais sera alterado no arquivo
			        IF   AI == AJ .AND. AH <> AF
			           	           
			            AADD(aErro, "-4 - Vl Maior Acum igual Debito Atual e Dt Maior Acum Diferente Dt Ult Compra") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Vl Maior Acum Arq:' + CVALTOCHAR(AI))
						AADD(aErro, 'Debito Atual Arq:' + CVALTOCHAR(AJ))
						AADD(aErro, 'Dt Maior Acum Diferente Arq:' + AH)
						AADD(aErro, 'Diferente Dt Ult Compra Arq:' + AF) 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO -4 ***************** //    
				
					// ******************** INICIO ERRO 07 ***************** // 
			        IF AF < AFOld
			           	           
			            AADD(aErro, "07 - Data da Ultima Compra < Data Ultima Compra Informada Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Ultima Compra Arq:' + AF)
						AADD(aErro, 'Data Ultima Compra ArqOld:' + AFOld)
						AADD(aErro, '') 
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 07 ***************** //
			        
			        // ******************** INICIO ERRO 14 ***************** // 
			        IF  AQ > 0 .AND. VAL(AR) < 5
			           	           
			            AADD(aErro, "14 - Media Vencidos a 5 dias < 5 Dias") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Media Vencimento Arq:' + AR)
						AADD(aErro, '')
						AADD(aErro, '')
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 14 ***************** //
		
					// ******************** INICIO ERRO 16 ***************** // 
			        IF  AQ > 0 .AND. VAL(AR) == 0   
			           	           
			            AADD(aErro, "16 - Debito Vencido a + 5 dias sem media atraso vencido a + 5 dias") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Media Vencimento 5 dias Arq:' + AR)
						AADD(aErro, 'Valor Debito 5 dias Arq:' + cvaltochar(AQ))
						AADD(aErro, '')
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 16 ***************** //			
			        
					// @history Ticket 3205 - Leonardo P. Monteiro - 08/10/2020 - Alterada a regra 19 para alerta e não erro na geração do arquivo para CISP. Após consulta a CISP os mesmos informam que não é um impeditivo para o envio do arquivo.
					// ******************** INICIO ERRO 19 ***************** // 
					IF  AI >= 10000000 .OR. AJ >= 10000000
								
						AADD(aErro, "19 - Valor Excessio - Valor Maior ou igual a 10000000 (Informacao de validacao)") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Vl Maior Acum Arq:' + CVALTOCHAR(AI))
						AADD(aErro, 'Debito Atual:' + CVALTOCHAR(AJ))
						AADD(aErro, '')
						AADD(aErro, '') 
						AADD(aAlert, aErro) 
						aErro := {} 

					ENDIF                                                       
					// ******************** FINAL ERRO 19 ***************** //

			        // ******************** INICIO ERRO 22 ***************** // 
			        IF AH < AHOld
			           	           
			            AADD(aErro, "22 - Data do Maior Acumulo < Data do Maior Acumulo Informado Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
						AADD(aErro, 'Data Maior Acumulo ArqOld:' + AHOld)
						AADD(aErro, '') 
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 22 ***************** //
			        
			        // ******************** INICIO ERRO 23 ***************** // 
			        IF AI < AIOld .AND. AHOLD > CVALTOCHAR(YEAR(DATE())-1 ) + STRZERO(MONTH(DATE()),2) + STRZERO(DAY(DATE()),2)
			           	           
			            AADD(aErro, "23 - Valor do Maior Acumulo < Valor do Maior Acumulo Informado Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Valor Maior Acumulo Arq:' + CVALTOCHAR(AI))
						AADD(aErro, 'Valor Maior Acumulo ArqOld:' + CVALTOCHAR(AIOld))
						AADD(aErro, '') 
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 23 ***************** //
			        
			        // ******************** INICIO ERRO 24 ***************** // 
			        IF AE <> AEOld
			           	           
			            AADD(aErro, "24 - Data Cliente desde <> Data Cliente Desde Informado Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Cliente desde Arq:' + AE)
						AADD(aErro, 'Data Cliente desde ArqOld:' + AEOld)
						AADD(aErro, '') 
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 24 ***************** //
			        
			        // ******************** INICIO ERRO 32 ***************** // 
			        IF   AN > 0 .AND. (AP == 0 .OR. AO == 0)
			           	           
			            AADD(aErro, "32 - Debito Atual a Vencer E Prazo Medio Vendas sem Media Ponderada Titulo a Vencer") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Media Ponderada Titulo a Vencer Arq:' + CVALTOCHAR(AO))
						AADD(aErro, 'Prazo Medio Vendas Arq:' + CVALTOCHAR(AP))
						AADD(aErro, 'Debito Atual a Vencer Arq:' + CVALTOCHAR(AN))
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 32 ***************** //
			        
			        // ******************** INICIO ERRO 43 ***************** // 
			        IF AZ < AZOld
			           	           
			            AADD(aErro, "43 - Data Penultima Compra < Data Penultima Compra Informado Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
						AADD(aErro, 'Data Penultima Compra ArqOld:' + AZOld)
						AADD(aErro, '') 
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 43 ***************** //
			        
			        // ******************** INICIO ERRO 48 ***************** // 
			        IF AZ == '00000000' .AND.  AF <> AFOld
			           	           
			            AADD(aErro, "48 - Sem Data Penultima Compra, Com data Ultima Compra <> Data Ultima Compra Informado Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Penultima Compra Arq:' + AZ)
						AADD(aErro, 'Data ultima Compra Arq:' + AF)
						AADD(aErro, 'Data ultima Compra ArqOld:' + AFOld)
						AADD(aErro, '') 
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 48 ***************** //
			        
			        // ******************** INICIO ERRO 54 ***************** // 
			        IF AH == AHOld .AND. AI <> AIOld
			           	           
			            AADD(aErro, "54 - Dt Maior Acumulo Igual a Dta Maior Acumulo Anterior e Vl Maior Acum Diferente Vl Maior Acumulo Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
						AADD(aErro, 'Data Maior Acumulo ArqOld:' + AHOld)
						AADD(aErro, 'Valor Maior Acumulo Arq:' + cvaltochar(AI))
						AADD(aErro, 'Valor Maior Acumulo ArqOld:' + cvaltochar(AIOld))
						AADD(aAlert, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 54 ***************** //
			        
			        // ******************** INICIO ERRO 59 ***************** // 
			        IF AI > AIOld .AND. AH < AHOld
			           	           
			            AADD(aErro, "59 - Vl Maior Acumulo Maior Vl Maior Acumulo Anterior e Dt Maior Acumulo menor Dt Maior Acumulo Anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Valor Maior Acumulo Arq:' + cvaltochar(AI))
						AADD(aErro, 'Valor Maior Acumulo ArqOld:' + cvaltochar(AIOld))
						AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
						AADD(aErro, 'Data Maior Acumulo ArqOld:' + AHOld)
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 59 ***************** //
			        
			        // ******************** INICIO ERRO 60 ***************** // 
			        IF AH <> AHOld .AND. AH < AHOld
			           	           
			            AADD(aErro, "60 - Dt Maior Acumulo Diferente Dt Maior Acumulo Anterior e Dt Maior Acumulo Menor que Data MAior Acumulo anterior") 
						AADD(aErro, 'CNPJ:' + cCnpj1)
						AADD(aErro, 'Data Maior Acumulo Arq:' + AH)
						AADD(aErro, 'Data Maior Acumulo ArqOld:' + AHOld)
						AADD(aErro, 'Valor Maior Acumulo Arq:' + cvaltochar(AI))
						AADD(aErro, 'Valor Maior Acumulo ArqOld:' + cvaltochar(AIOld))
						AADD(aInconsis, aErro) 
						aErro := {} 
			           
			        ENDIF                                                       
			        // ******************** FINAL ERRO 60 ***************** //
				     
				    lArqOldLido := .T.
					
				ENDIF //IF cCnpj1 == cCnpj2
				
				IF lArqOldLido == .T. //JA LI A LINHA DO ARQUIVO ANTERIOR E SEUS ERROS JOGUEI PARA O VETOR 
					lArqOldLido := .F.
					EXIT
				ENDIF	
				nByteLid2  := FRead(nHdl2, @cLinha2, nTamLin2)
	
			EndDo
			
			AAOld := ''
			ABOld := ''
			ACOld := ''
			ADOld := ''
			AEOld := ''
			AFOld := ''
			AGOld := ''
			AHOld := ''
			AIOld := ''
			AJOld := ''
			AKOld := ''
			ALOld := ''
			AMOld := ''
			ANOld := ''
			AOOld := ''
			APOld := ''
			AQOld := ''
			AROld := ''
			ATOld := ''
			AUOld := ''
			AVOld := ''
			AXOld := ''
			AZOld := ''
			BAOld := ''
			BBOld := ''
			BCOld := ''
			BDOld := ''
			BEOld := ''
			BFOld := ''
			BGOld := ''
			BHOld := '' 
			    
		    FCLOSE(nHdl2)                                                       
		    
		
		    // *** FINAL DA VERIFICACAO DE INCONSISTENCIA COM O ARQUIVO ANTERIOR******** //
	    ENDIF //IF AA == 1
		
		AA := ''
		AB := ''
		AC := ''
		AD := ''
		AE := ''
		AF := ''
		AG := ''
		AH := ''
		AI := ''
		AJ := ''
		AK := ''
		AL := ''
		AM := ''
		AN := ''
		AO := ''
		AP := ''
		AQ := ''
		AR := ''
		AT := ''
		AU := ''
		AV := ''
		AX := ''
		AZ := ''
		BA := ''
		BB := ''
		BC := ''
		BD := ''
		BE := ''
		BF := ''
		BG := ''
		BH := '' 
		
	    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
	
	EndDo
	
	FCLOSE(nHdl1)  
	
	// ****** FINAL VERIFICACAO 2  ******************************** //
	
RETURN(NIL)           

STATIC FUNCTION BACKUPCSVSA1(nValor)

	Local Arq   := ''
	Local cVar  := ''
	Local nHdl3 := ''
	
	
	IF nValor = 1 //FAZ BACKUP ANTES DE ALTERACAO DAS DATAS E VALORES DE ULTIMA COMPRA E MAIOR ACUMULO 
	    Arq   := ('SYSTEM\' + 'cisp\backupSA1\' + DTOS(DATE())     + '_bkp_antes.csv')     
		nHdl3 := fCreate(Arq) //Cria Arquivo para gravação das etiquetas
	ELSE	                                                                  
		Arq   := ('SYSTEM\' + 'cisp\backupSA1\' + DTOS(DATE())     + '_bkp_depois.csv')     
		nHdl3 := fCreate(Arq) //Cria Arquivo para gravação das etiquetas
	ENDIF	
	
	//cVar := "C.C;COD USER; NOME USER" + chr(13) + chr(10)
	
	SqlBkpSa1Csv()
    While TRC->(!EOF())
             
    	cVar += TRC->A1_CGC     + ';'
    	cVar += TRC->A1_DTACUMU + ';'
    	cVar += cvaltochar(TRC->A1_VLACUMU) + ';' 
    	cVar += TRC->A1_DTULTRE + ';'
        cVar += TRC->A1_XDTPENU + chr(13) + chr(10)
    	
      	TRC->(dbSkip())
    ENDDO //FECHA WHILE DO TRE
    	
	TRC->(dbCloseArea())

    Set Century OFF
    If fWrite(nHdl3,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
    	If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
    	
        	cMetodo   := 'Não gerou o arquivo da cisp (BACKUPSA1)...ERRO(4)'
			nId       := 1
			cmensagem := "O Arquivo de nome " + AllTrim(Arq) + " nao pode ser aberto verifique se ele existe...ERRO(4)"
			 
			EmailMaiorAcum(cMetodo,nId,cmensagem)
			
			cMetodo   := ''
			nId       := 0
			cmensagem := ''
			
			fClose(nHdl3)
			
			Return(Nil)
        Endif
    Endif
	fClose(nHdl3) 


RETURN(NIL)

STATIC FUNCTION IMPORTNOVOMAIORACUMULO() 

	Local cArq
	Local nHdl4
	Local nTamArq
	Local nTamLin
	Local nBytesLidos
	Local cLinha
	Local cTexto
	Local cEOL   
	Local cIdentific   := ''
	Local cCnpj        := ''
	Local cDtMaiorAcum := ''
	Local cDtPenulCom  := '' 
	Local cDtUltCom    := ''
	Local nVlMaiorAcum := ''
	Local nCont        := 0 
	Local lCont        := .F.
	
	// Se for especificado o drive no caminha do arquivo, sera procurado no
	// Client, caso contrario sera procurado no Server, no diretorio RooPath.
	cArq := ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP.txt')
	
	// Veja no arquivo FILEIO.CH os codigos de acesso e compartilhamento.
	nHdl4 := FOpen(cArq, 64)
	
	// Caracteres de final de linha.
	cEOL := Chr(13)+Chr(10)
	
	If nHdl4 == -1
		cMetodo   := 'Não gerou o arquivo da cisp (IMPORTNOVOMAIORACUMULO)...ERRO(5)'
		nId       := 1
		cmensagem := "O Arquivo de nome " + AllTrim(cArq) + " nao pode ser aberto verifique se ele existe...ERRO(5)"
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		cMetodo   := ''
		nId       := 0
		cmensagem := ''
		
		fClose(nHdl4)
		
		Return(Nil)
	EndIf
	
	nTamArq := FSeek(nHdl4, 0, 2)                 // Posiciona o ponteiro no final do arquivo.
	FSeek(nHdl4, 0, 0)                            // Volta o ponteiro para o inicio do arquivo.
	nTamLin     := 280 + Len(cEOL)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
	cLinha      := Space(nTamLin)                 // Variavel que contera a linha lida.
	nBytesLidos := FRead(nHdl4, @cLinha, nTamLin) // Le uma linha.
	cTexto      := ""
	
	While nBytesLidos > 1
	      
	    cIdentific   := Substr(cLinha, 001, 001)
	    cCnpj        := Substr(cLinha, 018, 008)
	    cDtMaiorAcum := Substr(cLinha, 065, 008)
	    cDtUltCom    := Substr(cLinha, 042, 008)
	    cDtPenulCom  := Substr(cLinha, 214, 008)
	    nVlMaiorAcum := VAL(Substr(cLinha, 073, 013))
	    
	    IF cIdentific == '1'
	    
		    SqlCliCgc(cCnpj)
		    lCont := .F.
		    
		    While TRD->(!EOF())
		    
		        IF ALLTRIM(cDtMaiorAcum) <> ALLTRIM(TRD->A1_DTACUMU) .OR. ;
		           nVlMaiorAcum          <> TRD->A1_VLACUMU .OR. ;
		           ALLTRIM(cDtUltCom)    <> ALLTRIM(TRD->A1_DTULTRE) .OR. ;
		           ALLTRIM(cDtPenulCom)  <> ALLTRIM(TRD->A1_XDTPENU)
		            
		            DBSELECTAREA("SA1")
					DbSetOrder(1)
					
					IF SA1->(DbSeek(xFilial("SA1")+TRD->A1_COD+TRD->A1_LOJA, .T.))
					
						RecLock("SA1",.F.)              
						
							SA1->A1_DTACUMU	:= IIF(SA1->A1_DTACUMU == STOD(cDtMaiorAcum),SA1->A1_DTACUMU,STOD(cDtMaiorAcum))					
							SA1->A1_VLACUMU	:= nVlMaiorAcum
			                SA1->A1_DTULTRE := IIF(SA1->A1_DTULTRE == STOD(cDtUltCom),SA1->A1_DTULTRE,STOD(cDtUltCom))  
			                SA1->A1_XDTPENU := IIF(SA1->A1_XDTPENU == STOD(cDtPenulCom),SA1->A1_XDTPENU,STOD(cDtPenulCom)) 
			                
						MsUnlock() 
						   
					    
						DBCLOSEAREA("SA1")
			        ENDIF
				ENDIF
				TRD->(DBSKIP())
			ENDDO
			TRD->(dbCloseArea())
		ENDIF //CIDENTIFIC == '1'	
	
	   
	   cIdentific   := ''
	   cCnpj        := ''
	   cDtMaiorAcum := '' 
	   cDtPenulCom  := ''
	   cDtUltCom    := ''
	   nVlMaiorAcum := 0
	   nBytesLidos  := FRead(nHdl4, @cLinha, nTamLin)
	
	EndDO
    //MSGINFO("Total de CNPJ " + cvaltochar(nCont), "Arquivo importado com sucesso")
	FClose(nHdl4)


RETURN(NIL)  

STATIC FUNCTION TRATARERROS()

	Local _cFile      := ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP.txt')
	Local _cFileOld   := ('SYSTEM\' + 'cisp\' + DTOS(DATE() - 1) + '_CISP.txt')
	Local _cFile3     := ('SYSTEM\' + 'cisp\' + DTOS(DATE())     + '_CISP_temp.txt')
	Local cQuery      := ''
	Local lArqLido    := .F.
	Local lArqOldLido := .F.
	Local nHdl1
	Local nHdl2
	Local nHdl3
	Local nTamArq1
	Local nTamArq2
	Local nTamArq3
	Local nTamLin1
	Local nTamLin2
	Local nTamLin3
	Local nByteLid1
	Local nByteLid2
	Local nByteLid3
	Local cLinha1
	Local cLinha2
	Local cLinha3
	Local cTexto1
	Local cEOL1
	Local cEOL2
	Local cEOL3
	Local cCnpj1       := ''                     
	Local cCnpj2       := ''                     
	Local cDtMaiorAcum := ''
	Local cVlMaiorAcum := ''
	Local nCont        := 0 
	Local lCont        := .F. 
	Local cTExto4      := ''
	Local cTExto5      := ''
	Local AA           := ''
	Local AB           := ''
	Local AC           := ''
	Local AD           := ''
	Local AE           := ''
	Local AF           := ''
	Local AG           := ''
	Local AH           := ''
	Local AI           := ''
	Local AJ           := ''
	Local AK           := ''
	Local AL           := ''
	Local AM           := ''
	Local AN           := ''
	Local AO           := ''
	Local AP           := ''
	Local AQ           := ''
	Local AR           := ''
	Local AT           := ''
	Local AU           := ''
	Local AV           := ''
	Local AX           := ''
	Local AZ           := ''
	Local BA           := ''
	Local BB           := ''
	Local BC           := ''
	Local BD           := ''
	Local BE           := ''
	Local BF           := ''
	Local BG           := ''
	Local BH           := ''
	Local AAOld        := ''
	Local ABOld        := ''
	Local ACOld        := ''
	Local ADOld        := ''
	Local AEOld        := ''
	Local AFOld        := ''
	Local AGOld        := ''
	Local AHOld        := ''
	Local AIOld        := ''
	Local AJOld        := ''
	Local AKOld        := ''
	Local ALOld        := ''
	Local AMOld        := ''
	Local ANOld        := ''
	Local AOOld        := ''
	Local APOld        := ''
	Local AQOld        := ''
	Local AROld        := ''
	Local ATOld        := ''
	Local AUOld        := ''
	Local AVOld        := ''
	Local AXOld        := ''
	Local AZOld        := ''
	Local BAOld        := ''
	Local BBOld        := ''
	Local BCOld        := ''
	Local BDOld        := ''
	Local BEOld        := ''
	Local BFOld        := ''
	Local BGOld        := ''
	Local BHOld        := ''
	Local nContVetor   := 0

    IF lErroArqOldArqNew == .T.
       /*
    	// ****************** INICIO ERRO -4 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '-4'
			
				lerroM4 := .T.
				nHdl3   := fCreate(_cFile3)
				fClose(nHdl3)
				nHdl3   := FOpen(_cFile3, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL3 := Chr(13)+Chr(10)
				
				If nHdl3 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(10)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile3 ) + " nao pode ser aberto verifique se ele existe...ERRO(10)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq3 := FSeek(nHdl3, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl3, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin3  := 280 + Len(cEOL3)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha3   := Space(nTamLin3)                 // Variavel que contera a linha lida.
				nByteLid3 := FRead(nHdl3, @cLinha3, nTamLin3)  // Le uma linha.
				cTexto3   := ""
				
				nHdl1 := FOpen(_cFile, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL1 := Chr(13)+Chr(10)
				
				If nHdl1 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(10)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(10)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
				nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
				cTexto1   := ""
				
				While nByteLid1 > 1
				    
					AA := Substr(cLinha1, 001, 001)
					AB := Substr(cLinha1, 002, 004)
					AC := Substr(cLinha1, 006, 020)
					AD := Substr(cLinha1, 026, 008)
					AE := Substr(cLinha1, 034, 008)
					AF := Substr(cLinha1, 042, 008)
					AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
					AH := Substr(cLinha1, 065, 008)
					AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
					AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
					AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
					AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
					AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
					AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
					AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
					AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
					AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
					AR := Substr(cLinha1, 172, 004) 
					AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
					AU := Substr(cLinha1, 191, 004) 
					AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
					AX := Substr(cLinha1, 210, 004)
					AZ := Substr(cLinha1, 214, 008)
					BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
					BB := Substr(cLinha1, 237, 001)
					BC := Substr(cLinha1, 238, 001)
					BD := Substr(cLinha1, 239, 002)
					BE := Substr(cLinha1, 241, 008)
					BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
					BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
					BH := Substr(cLinha1, 279, 002) 
					
					// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
					IF AA == '1' //entra porque e uma empresa   
					
						cCnpj1 := Substr(cLinha1, 18, 08)  
						
						IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1
						
					        cTExto4 := SUBSTR(cLinha1,1,64)
						    cTExto5 := SUBSTR(cLinha1,73,(280 - 73))                        
						    cLinha3 := ''
						    cLinha3 := cLinha1 //STUFF(cLinha3,1,64,cTExto4) + STUFF(cLinha3,65,72,AFOld) + STUFF(cLinha3,73,207,cTExto5) + ' ' + cEOL1
						   
						    If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						       If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						          Exit
						       EndIf
						    EndIf  
						//  ****** FINAL ESCREVENDO A LINHA ANTIGA   *********** //	
						
						ELSE
					        cLinha3 := ''
					        cLinha3 := cLinha1
					    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						         Exit
						      EndIf
						   EndIf 
					    ENDIF //IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1 	
					    
					ELSE         
					
						cLinha3 := ''
				        cLinha3 := cLinha1
				    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
					      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
					         Exit
					      EndIf
					   EndIf 
					    
					ENDIF //IF AA == 1
				
					AA := ''
					AB := ''
					AC := ''
					AD := ''
					AE := ''
					AF := ''
					AG := ''
					AH := ''
					AI := ''
					AJ := ''
					AK := ''
					AL := ''
					AM := ''
					AN := ''
					AO := ''
					AP := ''
					AQ := ''
					AR := ''
					AT := ''
					AU := ''
					AV := ''
					AX := ''
					AZ := ''
					BA := ''
					BB := ''
					BC := ''
					BD := ''
					BE := ''
					BF := ''
					BG := ''
					BH := '' 
					
				    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
				
				EndDo
				
				FCLOSE(nHdl1)	   
				FCLOSE(nHdl3)	   	
				
				IF lerroM4 == .T.
				    //apaga o arquivo temporario e renomeia ele para o nome oficial
				    lerroM4 := .F.
					If File(_cFile)
						FErase(_cFile)
						FRename(_cFile3 , _cFile) //StrTran(_cFile, '.txt', '')
					EndIf
				END     	 
				
			ENDIF // SUBSTR(aInconsis[nContVetor][1],1,2) == '23'
		NEXT
	
	    // ****************** FINAL ERRO -4 ******************** // 
        
    	// ****************** INICIO ERRO 14 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '14'
			
				lerro14 := .T.
				nHdl3   := fCreate(_cFile3)
				fClose(nHdl3)
				nHdl3   := FOpen(_cFile3, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL3 := Chr(13)+Chr(10)
				
				If nHdl3 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(9)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile3 ) + " nao pode ser aberto verifique se ele existe...ERRO(9)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq3 := FSeek(nHdl3, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl3, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin3  := 280 + Len(cEOL3)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha3   := Space(nTamLin3)                 // Variavel que contera a linha lida.
				nByteLid3 := FRead(nHdl3, @cLinha3, nTamLin3)  // Le uma linha.
				cTexto3   := ""
				
				nHdl1 := FOpen(_cFile, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL1 := Chr(13)+Chr(10)
				
				If nHdl1 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(10)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(10)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
				nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
				cTexto1   := ""
				
				While nByteLid1 > 1
				    
					AA := Substr(cLinha1, 001, 001)
					AB := Substr(cLinha1, 002, 004)
					AC := Substr(cLinha1, 006, 020)
					AD := Substr(cLinha1, 026, 008)
					AE := Substr(cLinha1, 034, 008)
					AF := Substr(cLinha1, 042, 008)
					AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
					AH := Substr(cLinha1, 065, 008)
					AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
					AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
					AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
					AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
					AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
					AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
					AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
					AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
					AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
					AR := Substr(cLinha1, 172, 004) 
					AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
					AU := Substr(cLinha1, 191, 004) 
					AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
					AX := Substr(cLinha1, 210, 004)
					AZ := Substr(cLinha1, 214, 008)
					BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
					BB := Substr(cLinha1, 237, 001)
					BC := Substr(cLinha1, 238, 001)
					BD := Substr(cLinha1, 239, 002)
					BE := Substr(cLinha1, 241, 008)
					BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
					BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
					BH := Substr(cLinha1, 279, 002) 
					
					// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
					IF AA == '1' //entra porque e uma empresa   
					
						cCnpj1 := Substr(cLinha1, 18, 08)  
						
						IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1
						
					        cTExto4 := SUBSTR(cLinha1,1,174)
						    cTExto5 := SUBSTR(cLinha1,176,(280 - 176))                        
						    cLinha3 := ''
						    cLinha3 := cLinha1 //STUFF(cLinha3,1,174,cTExto4) + STUFF(cLinha3,175,1,'5') + STUFF(cLinha3,176,104,cTExto5) + ' ' + cEOL1
						   
						    If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						       If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						          Exit
						       EndIf
						    EndIf  
						//  ****** FINAL ESCREVENDO A LINHA ANTIGA   *********** //	
						
						ELSE
					        cLinha3 := ''
					        cLinha3 := cLinha1
					    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						         Exit
						      EndIf
						   EndIf 
					    ENDIF //IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1 	
					    
					ELSE         
					
						cLinha3 := ''
				        cLinha3 := cLinha1
				    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
					      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
					         Exit
					      EndIf
					   EndIf 
					    
					ENDIF //IF AA == 1
				
					AA := ''
					AB := ''
					AC := ''
					AD := ''
					AE := ''
					AF := ''
					AG := ''
					AH := ''
					AI := ''
					AJ := ''
					AK := ''
					AL := ''
					AM := ''
					AN := ''
					AO := ''
					AP := ''
					AQ := ''
					AR := ''
					AT := ''
					AU := ''
					AV := ''
					AX := ''
					AZ := ''
					BA := ''
					BB := ''
					BC := ''
					BD := ''
					BE := ''
					BF := ''
					BG := ''
					BH := '' 
					
				    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
				
				EndDo
				
				FCLOSE(nHdl1)	   
				FCLOSE(nHdl3)	   	
				
				IF lerro14 == .T.
				    //apaga o arquivo temporario e renomeia ele para o nome oficial
				    lerro14 := .F.
					If File(_cFile)
						FErase(_cFile)
						FRename(_cFile3 , _cFile) //StrTran(_cFile, '.txt', '')
					EndIf
				END     	 
				
			ENDIF // SUBSTR(aInconsis[nContVetor][1],1,2) == '23'
		NEXT
	
	    // ****************** FINAL ERRO 14 ******************** //
        
    	// ****************** INICIO ERRO 23 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '23'
			
				lerro23 := .T.
				nHdl3   := fCreate(_cFile3)
				fClose(nHdl3)
				nHdl3   := FOpen(_cFile3, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL3 := Chr(13)+Chr(10)
				
				If nHdl3 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile3 ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq3 := FSeek(nHdl3, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl3, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin3  := 280 + Len(cEOL3)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha3   := Space(nTamLin3)                 // Variavel que contera a linha lida.
				nByteLid3 := FRead(nHdl3, @cLinha3, nTamLin3)  // Le uma linha.
				cTexto3   := ""
				
				nHdl1 := FOpen(_cFile, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL1 := Chr(13)+Chr(10)
				
				If nHdl1 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(7)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(7)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
				nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
				cTexto1   := ""
				
				While nByteLid1 > 1
				    
					AA := Substr(cLinha1, 001, 001)
					AB := Substr(cLinha1, 002, 004)
					AC := Substr(cLinha1, 006, 020)
					AD := Substr(cLinha1, 026, 008)
					AE := Substr(cLinha1, 034, 008)
					AF := Substr(cLinha1, 042, 008)
					AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
					AH := Substr(cLinha1, 065, 008)
					AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
					AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
					AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
					AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
					AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
					AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
					AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
					AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
					AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
					AR := Substr(cLinha1, 172, 004) 
					AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
					AU := Substr(cLinha1, 191, 004) 
					AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
					AX := Substr(cLinha1, 210, 004)
					AZ := Substr(cLinha1, 214, 008)
					BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
					BB := Substr(cLinha1, 237, 001)
					BC := Substr(cLinha1, 238, 001)
					BD := Substr(cLinha1, 239, 002)
					BE := Substr(cLinha1, 241, 008)
					BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
					BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
					BH := Substr(cLinha1, 279, 002) 
					
					// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
					IF AA == '1' //entra porque e uma empresa   
					
						cCnpj1 := Substr(cLinha1, 18, 08)  
						
						IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1
						
							nHdl2 := FOpen(_cFileOld, 64)
			
							// Caracteres de final de linha.
							cEOL2 := Chr(13)+Chr(10)
							
							If nHdl2 == -1
							    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
								nId       := 1
								cmensagem := "O Arquivo de nome " + AllTrim(_cFileOld ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
								 
								EmailMaiorAcum(cMetodo,nId,cmensagem)
								
								larqCisp  := .F.
								cMetodo   := ''
								nId       := 0
								cmensagem := ''
								Return(Nil)
							   
							EndIf
							
							nTamArq2 := FSeek(nHdl2, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
							FSeek(nHdl2, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
							nTamLin2  := 280 + Len(cEOL2)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
							cLinha2   := Space(nTamLin2)                 // Variavel que contera a linha lida.
							nByteLid2 := FRead(nHdl2, @cLinha2, nTamLin2)  // Le uma linha.
							cTexto2   := ""
							
							While nByteLid2 > 1    
							
								AAOld  := Substr(cLinha2, 001, 001)
								ABOld  := Substr(cLinha2, 002, 004)
								ACOld  := Substr(cLinha2, 006, 020)
								ADOld  := Substr(cLinha2, 026, 008)
								AEOld  := Substr(cLinha2, 034, 008)
								AFOld  := Substr(cLinha2, 042, 008)
								AGOld  := VAL(Substr(cLinha2, 050, 013) + '.' + Substr(cLinha2, 063, 002))
								AHOld  := Substr(cLinha2, 065, 008)
								AIOld  := VAL(Substr(cLinha2, 073, 013) + '.' + Substr(cLinha2, 086, 002))
								AJOld  := VAL(Substr(cLinha2, 088, 013) + '.' + Substr(cLinha2, 101, 002))
								AKOld  := VAL(Substr(cLinha2, 103, 013) + '.' + Substr(cLinha2, 116, 002))
								ALOld  := VAL(Substr(cLinha2, 118, 004) + '.' + Substr(cLinha2, 122, 002))
								AMOld  := VAL(Substr(cLinha2, 124, 004) + '.' + Substr(cLinha2, 128, 002))
								ANOld  := VAL(Substr(cLinha2, 130, 013) + '.' + Substr(cLinha2, 143, 002))
								AOOld  := VAL(Substr(cLinha2, 145, 004) + '.' + Substr(cLinha2, 149, 002))
								APOld  := VAL(Substr(cLinha2, 151, 004) + '.' + Substr(cLinha2, 155, 002))
								AQOld  := VAL(Substr(cLinha2, 157, 013) + '.' + Substr(cLinha2, 170, 002))
								AROld  := Substr(cLinha2, 172, 004) 
								ATOld  := VAL(Substr(cLinha2, 176, 013) + '.' + Substr(cLinha2, 189, 002))
								AUOld  := Substr(cLinha2, 191, 004) 
								AVOld  := VAL(Substr(cLinha2, 195, 013) + '.' + Substr(cLinha2, 208, 002))
								AXOld  := Substr(cLinha2, 210, 004)
								AZOld  := Substr(cLinha2, 214, 008)
								BAOld  := VAL(Substr(cLinha2, 222, 013) + '.' + Substr(cLinha2, 235, 002))
								BBOld  := Substr(cLinha2, 237, 001)
								BCOld  := Substr(cLinha2, 238, 001)
								BDOld  := Substr(cLinha2, 239, 002)
								BEOld  := Substr(cLinha2, 241, 008)
								BFOld  := VAL(Substr(cLinha2, 249, 013) + '.' + Substr(cLinha2, 262, 002))
								BGOld  := VAL(Substr(cLinha2, 264, 013) + '.' + Substr(cLinha2, 279, 002))
								BHOld  := Substr(cLinha2, 279, 002) 
								cCnpj2 := Substr(cLinha2, 18, 08)    
								
								//  ****** INICIO ESCREVENDO A LINHA ANTIGA   *********** //
								IF cCnpj1 == cCnpj2 //acha o cnpj no arquivo anterior
								    
									lArqOldLido := .T.
									cTExto4 := SUBSTR(cLinha1,1,64)
								    cTExto5 := SUBSTR(cLinha2,103,(280 - 103))                        
								    cLinha3 := ''
								    cLinha3 := cLinha1 //STUFF(cLinha3,1,64,cTExto4) + STUFF(cLinha3,65,72,AHOld) + STUFF(cLinha3,73,87,STRZERO(AIOld,13) + '00') + STUFF(cLinha3,88,102,STRZERO(AJOld,13) + '00') + STUFF(cLinha3,103,177,cTExto5) + ' ' + cEOL1
								   
								    If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
								       If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
								          Exit
								       EndIf
								    EndIf  
								//  ****** FINAL ESCREVENDO A LINHA ANTIGA   *********** //	
								ENDIF //IF cCnpj1 == cCnpj2
								
								IF lArqOldLido == .T. //JA LI A LINHA DO ARQUIVO ANTERIOR E SEUS ERROS JOGUEI PARA O VETOR 
									lArqOldLido := .F.
									EXIT
								ENDIF		
								nByteLid2  := FRead(nHdl2, @cLinha2, nTamLin2)
					
							EndDo
							
							AAOld := ''
							ABOld := ''
							ACOld := ''
							ADOld := ''
							AEOld := ''
							AFOld := ''
							AGOld := ''
							AHOld := ''
							AIOld := ''
							AJOld := ''
							AKOld := ''
							ALOld := ''
							AMOld := ''
							ANOld := ''
							AOOld := ''
							APOld := ''
							AQOld := ''
							AROld := ''
							ATOld := ''
							AUOld := ''
							AVOld := ''
							AXOld := ''
							AZOld := ''
							BAOld := ''
							BBOld := ''
							BCOld := ''
							BDOld := ''
							BEOld := ''
							BFOld := ''
							BGOld := ''
							BHOld := '' 
							    
						    FCLOSE(nHdl2)                                                       
						
						    // *** FINAL DA VERIFICACAO DE INCONSISTENCIA COM O ARQUIVO ANTERIOR******** //
					        
					    ELSE
					        cLinha3 := ''
					        cLinha3 := cLinha1
					    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						         Exit
						      EndIf
						   EndIf 
					    ENDIF //IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1 	
					ELSE         
					
						cLinha3 := ''
				        cLinha3 := cLinha1
				    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
					      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
					         Exit
					      EndIf
					   EndIf 
					    
					ENDIF //IF AA == 1
				
					AA := ''
					AB := ''
					AC := ''
					AD := ''
					AE := ''
					AF := ''
					AG := ''
					AH := ''
					AI := ''
					AJ := ''
					AK := ''
					AL := ''
					AM := ''
					AN := ''
					AO := ''
					AP := ''
					AQ := ''
					AR := ''
					AT := ''
					AU := ''
					AV := ''
					AX := ''
					AZ := ''
					BA := ''
					BB := ''
					BC := ''
					BD := ''
					BE := ''
					BF := ''
					BG := ''
					BH := '' 
					
				    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
				
				EndDo
				
				FCLOSE(nHdl1)	   
				FCLOSE(nHdl3)
				
				IF lerro23 == .T.
				    //apaga o arquivo temporario e renomeia ele para o nome oficial
				    lerro23 := .F.
					If File(_cFile)
						FErase(_cFile)
						FRename(_cFile3 , _cFile) //StrTran(_cFile, '.txt', '')
					EndIf
				END   	   	
				
			ENDIF // SUBSTR(aInconsis[nContVetor][1],1,2) == '23'
		NEXT
	
		// ****************** FINAL ERRO 23 ******************** //
	    
	    // ****************** INICIO ERRO 32 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '32'
				lerro32 := .T.
			ENDIF
			
			
		NEXT
	
		IF lerro32 == .T.
	        lerro32 := .F.
	 		
		END     	 
	    // ****************** FINAL ERRO 32 ******************** //
	    
	    // ****************** INICIO ERRO 43 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '43'
			
				lerro43 := .T.
				nHdl3   := fCreate(_cFile3)
				fClose(nHdl3)
				nHdl3   := FOpen(_cFile3, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL3 := Chr(13)+Chr(10)
				
				If nHdl3 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile3 ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq3 := FSeek(nHdl3, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl3, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin3  := 280 + Len(cEOL3)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha3   := Space(nTamLin3)                 // Variavel que contera a linha lida.
				nByteLid3 := FRead(nHdl3, @cLinha3, nTamLin3)  // Le uma linha.
				cTexto3   := ""
				
				nHdl1 := FOpen(_cFile, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL1 := Chr(13)+Chr(10)
				
				If nHdl1 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(7)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(7)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
				nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
				cTexto1   := ""
				
				While nByteLid1 > 1
				    
					AA := Substr(cLinha1, 001, 001)
					AB := Substr(cLinha1, 002, 004)
					AC := Substr(cLinha1, 006, 020)
					AD := Substr(cLinha1, 026, 008)
					AE := Substr(cLinha1, 034, 008)
					AF := Substr(cLinha1, 042, 008)
					AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
					AH := Substr(cLinha1, 065, 008)
					AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
					AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
					AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
					AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
					AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
					AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
					AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
					AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
					AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
					AR := Substr(cLinha1, 172, 004) 
					AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
					AU := Substr(cLinha1, 191, 004) 
					AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
					AX := Substr(cLinha1, 210, 004)
					AZ := Substr(cLinha1, 214, 008)
					BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
					BB := Substr(cLinha1, 237, 001)
					BC := Substr(cLinha1, 238, 001)
					BD := Substr(cLinha1, 239, 002)
					BE := Substr(cLinha1, 241, 008)
					BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
					BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
					BH := Substr(cLinha1, 279, 002) 
					
					// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
					IF AA == '1' //entra porque e uma empresa   
					
						cCnpj1 := Substr(cLinha1, 18, 08)  
						
						IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1
						
							nHdl2 := FOpen(_cFileOld, 64)
			
							// Caracteres de final de linha.
							cEOL2 := Chr(13)+Chr(10)
							
							If nHdl2 == -1
							    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
								nId       := 1
								cmensagem := "O Arquivo de nome " + AllTrim(_cFileOld ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
								 
								EmailMaiorAcum(cMetodo,nId,cmensagem)
								
								larqCisp  := .F.
								cMetodo   := ''
								nId       := 0
								cmensagem := ''
								Return(Nil)
							   
							EndIf
							
							nTamArq2 := FSeek(nHdl2, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
							FSeek(nHdl2, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
							nTamLin2  := 280 + Len(cEOL2)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
							cLinha2   := Space(nTamLin2)                 // Variavel que contera a linha lida.
							nByteLid2 := FRead(nHdl2, @cLinha2, nTamLin2)  // Le uma linha.
							cTexto2   := ""
							
							While nByteLid2 > 1    
							
								AAOld  := Substr(cLinha2, 001, 001)
								ABOld  := Substr(cLinha2, 002, 004)
								ACOld  := Substr(cLinha2, 006, 020)
								ADOld  := Substr(cLinha2, 026, 008)
								AEOld  := Substr(cLinha2, 034, 008)
								AFOld  := Substr(cLinha2, 042, 008)
								AGOld  := VAL(Substr(cLinha2, 050, 013) + '.' + Substr(cLinha2, 063, 002))
								AHOld  := Substr(cLinha2, 065, 008)
								AIOld  := VAL(Substr(cLinha2, 073, 013) + '.' + Substr(cLinha2, 086, 002))
								AJOld  := VAL(Substr(cLinha2, 088, 013) + '.' + Substr(cLinha2, 101, 002))
								AKOld  := VAL(Substr(cLinha2, 103, 013) + '.' + Substr(cLinha2, 116, 002))
								ALOld  := VAL(Substr(cLinha2, 118, 004) + '.' + Substr(cLinha2, 122, 002))
								AMOld  := VAL(Substr(cLinha2, 124, 004) + '.' + Substr(cLinha2, 128, 002))
								ANOld  := VAL(Substr(cLinha2, 130, 013) + '.' + Substr(cLinha2, 143, 002))
								AOOld  := VAL(Substr(cLinha2, 145, 004) + '.' + Substr(cLinha2, 149, 002))
								APOld  := VAL(Substr(cLinha2, 151, 004) + '.' + Substr(cLinha2, 155, 002))
								AQOld  := VAL(Substr(cLinha2, 157, 013) + '.' + Substr(cLinha2, 170, 002))
								AROld  := Substr(cLinha2, 172, 004) 
								ATOld  := VAL(Substr(cLinha2, 176, 013) + '.' + Substr(cLinha2, 189, 002))
								AUOld  := Substr(cLinha2, 191, 004) 
								AVOld  := VAL(Substr(cLinha2, 195, 013) + '.' + Substr(cLinha2, 208, 002))
								AXOld  := Substr(cLinha2, 210, 004)
								AZOld  := Substr(cLinha2, 214, 008)
								BAOld  := VAL(Substr(cLinha2, 222, 013) + '.' + Substr(cLinha2, 235, 002))
								BBOld  := Substr(cLinha2, 237, 001)
								BCOld  := Substr(cLinha2, 238, 001)
								BDOld  := Substr(cLinha2, 239, 002)
								BEOld  := Substr(cLinha2, 241, 008)
								BFOld  := VAL(Substr(cLinha2, 249, 013) + '.' + Substr(cLinha2, 262, 002))
								BGOld  := VAL(Substr(cLinha2, 264, 013) + '.' + Substr(cLinha2, 279, 002))
								BHOld  := Substr(cLinha2, 279, 002) 
								cCnpj2 := Substr(cLinha2, 18, 08)    
								
								//  ****** INICIO ESCREVENDO A LINHA ANTIGA   *********** //
								IF cCnpj1 == cCnpj2 //acha o cnpj no arquivo anterior
								    
									lArqOldLido := .T.
									cTExto4 := SUBSTR(cLinha1,1,213)
								    cTExto5 := SUBSTR(cLinha2,237,(280 - 237))                        
								    cLinha3 := ''
								    cLinha3 := cLinha1 //STUFF(cLinha3,1,213,cTExto4) + STUFF(cLinha3,214,221,AZOld) + STUFF(cLinha3,222,236,STRZERO(VAL(Substr(cLinha2, 222, 013)),13) + Substr(cLinha2, 235, 002)) + STUFF(cLinha3,237,43,cTExto5) + ' ' + cEOL1
								   
								    If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
								       If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
								          Exit
								       EndIf
								    EndIf  
								//  ****** FINAL ESCREVENDO A LINHA ANTIGA   *********** //	
								ENDIF //IF cCnpj1 == cCnpj2
								
								IF lArqOldLido == .T. //JA LI A LINHA DO ARQUIVO ANTERIOR E SEUS ERROS JOGUEI PARA O VETOR 
									lArqOldLido := .F.
									EXIT
								ENDIF		
								nByteLid2  := FRead(nHdl2, @cLinha2, nTamLin2)
					
							EndDo
							
							AAOld := ''
							ABOld := ''
							ACOld := ''
							ADOld := ''
							AEOld := ''
							AFOld := ''
							AGOld := ''
							AHOld := ''
							AIOld := ''
							AJOld := ''
							AKOld := ''
							ALOld := ''
							AMOld := ''
							ANOld := ''
							AOOld := ''
							APOld := ''
							AQOld := ''
							AROld := ''
							ATOld := ''
							AUOld := ''
							AVOld := ''
							AXOld := ''
							AZOld := ''
							BAOld := ''
							BBOld := ''
							BCOld := ''
							BDOld := ''
							BEOld := ''
							BFOld := ''
							BGOld := ''
							BHOld := '' 
							    
						    FCLOSE(nHdl2)                                                       
						
						    // *** FINAL DA VERIFICACAO DE INCONSISTENCIA COM O ARQUIVO ANTERIOR******** //
					        
					    ELSE
					        cLinha3 := ''
					        cLinha3 := cLinha1
					    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						         Exit
						      EndIf
						   EndIf 
					    ENDIF //IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1 	
					ELSE         
					
						cLinha3 := ''
				        cLinha3 := cLinha1
				    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
					      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
					         Exit
					      EndIf
					   EndIf 
					    
					ENDIF //IF AA == 1
				
					AA := ''
					AB := ''
					AC := ''
					AD := ''
					AE := ''
					AF := ''
					AG := ''
					AH := ''
					AI := ''
					AJ := ''
					AK := ''
					AL := ''
					AM := ''
					AN := ''
					AO := ''
					AP := ''
					AQ := ''
					AR := ''
					AT := ''
					AU := ''
					AV := ''
					AX := ''
					AZ := ''
					BA := ''
					BB := ''
					BC := ''
					BD := ''
					BE := ''
					BF := ''
					BG := ''
					BH := '' 
					
				    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
				
				EndDo
				
				FCLOSE(nHdl1)	   
				FCLOSE(nHdl3)
				
				IF lerro43 == .T.
				    //apaga o arquivo temporario e renomeia ele para o nome oficial
				    lerro43 := .F.
					If File(_cFile)
						FErase(_cFile)
						FRename(_cFile3 , _cFile) //StrTran(_cFile, '.txt', '')
					EndIf
				END   	   	
				
			ENDIF // SUBSTR(aInconsis[nContVetor][1],1,2) == '43'
		NEXT
	
		// ****************** FINAL ERRO 43 ******************** //
	    */
	    // ****************** INICIO ERRO 54 ******************** //
		FOR nContVetor := 1 TO LEN(aInconsis)                         
		
			
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '54'
			
				lerro54 := .T.
				nHdl3   := fCreate(_cFile3)
				fClose(nHdl3)
				nHdl3   := FOpen(_cFile3, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL3 := Chr(13)+Chr(10)
				
				If nHdl3 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile3 ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq3 := FSeek(nHdl3, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl3, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin3  := 280 + Len(cEOL3)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha3   := Space(nTamLin3)                 // Variavel que contera a linha lida.
				nByteLid3 := FRead(nHdl3, @cLinha3, nTamLin3)  // Le uma linha.
				cTexto3   := ""
				
				nHdl1 := FOpen(_cFile, FO_READWRITE + FO_SHARED)
	
				// Caracteres de final de linha.
				cEOL1 := Chr(13)+Chr(10)
				
				If nHdl1 == -1
				    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(7)'
					nId       := 1
					cmensagem := "O Arquivo de nome " + AllTrim(_cFile ) + " nao pode ser aberto verifique se ele existe...ERRO(7)"
					 
					EmailMaiorAcum(cMetodo,nId,cmensagem)
					
					larqCisp  := .F.
					cMetodo   := ''
					nId       := 0
					cmensagem := ''
					Return(Nil)
				   
				EndIf
				
				nTamArq1 := FSeek(nHdl1, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
				FSeek(nHdl1, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
				nTamLin1  := 280 + Len(cEOL1)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
				cLinha1   := Space(nTamLin1)                 // Variavel que contera a linha lida.
				nByteLid1 := FRead(nHdl1, @cLinha1, nTamLin1)  // Le uma linha.
				cTexto1   := ""
				
				While nByteLid1 > 1
				    
					AA := Substr(cLinha1, 001, 001)
					AB := Substr(cLinha1, 002, 004)
					AC := Substr(cLinha1, 006, 020)
					AD := Substr(cLinha1, 026, 008)
					AE := Substr(cLinha1, 034, 008)
					AF := Substr(cLinha1, 042, 008)
					AG := VAL(Substr(cLinha1, 050, 013) + '.' + Substr(cLinha1, 063, 002))
					AH := Substr(cLinha1, 065, 008)
					AI := VAL(Substr(cLinha1, 073, 013) + '.' + Substr(cLinha1, 086, 002))
					AJ := VAL(Substr(cLinha1, 088, 013) + '.' + Substr(cLinha1, 101, 002))
					AK := VAL(Substr(cLinha1, 103, 013) + '.' + Substr(cLinha1, 116, 002))
					AL := VAL(Substr(cLinha1, 118, 004) + '.' + Substr(cLinha1, 122, 002))
					AM := VAL(Substr(cLinha1, 124, 004) + '.' + Substr(cLinha1, 128, 002))
					AN := VAL(Substr(cLinha1, 130, 013) + '.' + Substr(cLinha1, 143, 002))
					AO := VAL(Substr(cLinha1, 145, 004) + '.' + Substr(cLinha1, 149, 002))
					AP := VAL(Substr(cLinha1, 151, 004) + '.' + Substr(cLinha1, 155, 002))
					AQ := VAL(Substr(cLinha1, 157, 013) + '.' + Substr(cLinha1, 170, 002))
					AR := Substr(cLinha1, 172, 004) 
					AT := VAL(Substr(cLinha1, 176, 013) + '.' + Substr(cLinha1, 189, 002))
					AU := Substr(cLinha1, 191, 004) 
					AV := VAL(Substr(cLinha1, 195, 013) + '.' + Substr(cLinha1, 208, 002))
					AX := Substr(cLinha1, 210, 004)
					AZ := Substr(cLinha1, 214, 008)
					BA := VAL(Substr(cLinha1, 222, 013) + '.' + Substr(cLinha1, 235, 002))
					BB := Substr(cLinha1, 237, 001)
					BC := Substr(cLinha1, 238, 001)
					BD := Substr(cLinha1, 239, 002)
					BE := Substr(cLinha1, 241, 008)
					BF := VAL(Substr(cLinha1, 249, 013) + '.' + Substr(cLinha1, 262, 002))
					BG := VAL(Substr(cLinha1, 264, 013) + '.' + Substr(cLinha1, 279, 002))
					BH := Substr(cLinha1, 279, 002) 
					
					// *** INICIO DA VERIFICACAO DE INCONSISTENCIA SEM SER COM O ARQUIVO ANTERIOR*** //
					IF AA == '1' //entra porque e uma empresa   
					
						cCnpj1 := Substr(cLinha1, 18, 08)  
						
						IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1
						
							nHdl2 := FOpen(_cFileOld, 64)
			
							// Caracteres de final de linha.
							cEOL2 := Chr(13)+Chr(10)
							
							If nHdl2 == -1
							    cMetodo   := 'Não gerou o arquivo da cisp (VerErro1)...ERRO(8)'
								nId       := 1
								cmensagem := "O Arquivo de nome " + AllTrim(_cFileOld ) + " nao pode ser aberto verifique se ele existe...ERRO(8)"
								 
								EmailMaiorAcum(cMetodo,nId,cmensagem)
								
								larqCisp  := .F.
								cMetodo   := ''
								nId       := 0
								cmensagem := ''
								Return(Nil)
							   
							EndIf
							
							nTamArq2 := FSeek(nHdl2, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
							FSeek(nHdl2, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
							nTamLin2  := 280 + Len(cEOL2)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
							cLinha2   := Space(nTamLin2)                 // Variavel que contera a linha lida.
							nByteLid2 := FRead(nHdl2, @cLinha2, nTamLin2)  // Le uma linha.
							cTexto2   := ""
							
							While nByteLid2 > 1    
							
								AAOld  := Substr(cLinha2, 001, 001)
								ABOld  := Substr(cLinha2, 002, 004)
								ACOld  := Substr(cLinha2, 006, 020)
								ADOld  := Substr(cLinha2, 026, 008)
								AEOld  := Substr(cLinha2, 034, 008)
								AFOld  := Substr(cLinha2, 042, 008)
								AGOld  := VAL(Substr(cLinha2, 050, 013) + '.' + Substr(cLinha2, 063, 002))
								AHOld  := Substr(cLinha2, 065, 008)
								AIOld  := VAL(Substr(cLinha2, 073, 013) + '.' + Substr(cLinha2, 086, 002))
								AJOld  := VAL(Substr(cLinha2, 088, 013) + '.' + Substr(cLinha2, 101, 002))
								AKOld  := VAL(Substr(cLinha2, 103, 013) + '.' + Substr(cLinha2, 116, 002))
								ALOld  := VAL(Substr(cLinha2, 118, 004) + '.' + Substr(cLinha2, 122, 002))
								AMOld  := VAL(Substr(cLinha2, 124, 004) + '.' + Substr(cLinha2, 128, 002))
								ANOld  := VAL(Substr(cLinha2, 130, 013) + '.' + Substr(cLinha2, 143, 002))
								AOOld  := VAL(Substr(cLinha2, 145, 004) + '.' + Substr(cLinha2, 149, 002))
								APOld  := VAL(Substr(cLinha2, 151, 004) + '.' + Substr(cLinha2, 155, 002))
								AQOld  := VAL(Substr(cLinha2, 157, 013) + '.' + Substr(cLinha2, 170, 002))
								AROld  := Substr(cLinha2, 172, 004) 
								ATOld  := VAL(Substr(cLinha2, 176, 013) + '.' + Substr(cLinha2, 189, 002))
								AUOld  := Substr(cLinha2, 191, 004) 
								AVOld  := VAL(Substr(cLinha2, 195, 013) + '.' + Substr(cLinha2, 208, 002))
								AXOld  := Substr(cLinha2, 210, 004)
								AZOld  := Substr(cLinha2, 214, 008)
								BAOld  := VAL(Substr(cLinha2, 222, 013) + '.' + Substr(cLinha2, 235, 002))
								BBOld  := Substr(cLinha2, 237, 001)
								BCOld  := Substr(cLinha2, 238, 001)
								BDOld  := Substr(cLinha2, 239, 002)
								BEOld  := Substr(cLinha2, 241, 008)
								BFOld  := VAL(Substr(cLinha2, 249, 013) + '.' + Substr(cLinha2, 262, 002))
								BGOld  := VAL(Substr(cLinha2, 264, 013) + '.' + Substr(cLinha2, 279, 002))
								BHOld  := Substr(cLinha2, 279, 002) 
								cCnpj2 := Substr(cLinha2, 18, 08)    
								
								//  ****** INICIO ESCREVENDO A LINHA ANTIGA   *********** //
								IF cCnpj1 == cCnpj2 //acha o cnpj no arquivo anterior
								    
									lArqOldLido := .T.
									cTExto4 := SUBSTR(cLinha1,1,64)
								    cTExto5 := SUBSTR(cLinha2,103,(280 - 103))                        
								    cLinha3 := ''
								    cLinha3 := STUFF(cLinha3,1,64,cTExto4) + STUFF(cLinha3,65,72,AHOld) + STUFF(cLinha3,73,87,STRZERO(AIOld,13) + '00') + STUFF(cLinha3,88,102,STRZERO(AJOld,13) + '00') + STUFF(cLinha3,103,177,cTExto5) + ' ' + cEOL1
								   
								    If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
								       If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
								          Exit
								       EndIf
								    EndIf  
								//  ****** FINAL ESCREVENDO A LINHA ANTIGA   *********** //	
								ENDIF //IF cCnpj1 == cCnpj2
								
								IF lArqOldLido == .T. //JA LI A LINHA DO ARQUIVO ANTERIOR E SEUS ERROS JOGUEI PARA O VETOR 
									lArqOldLido := .F.
									EXIT
								ENDIF		
								nByteLid2  := FRead(nHdl2, @cLinha2, nTamLin2)
					
							EndDo
							
							AAOld := ''
							ABOld := ''
							ACOld := ''
							ADOld := ''
							AEOld := ''
							AFOld := ''
							AGOld := ''
							AHOld := ''
							AIOld := ''
							AJOld := ''
							AKOld := ''
							ALOld := ''
							AMOld := ''
							ANOld := ''
							AOOld := ''
							APOld := ''
							AQOld := ''
							AROld := ''
							ATOld := ''
							AUOld := ''
							AVOld := ''
							AXOld := ''
							AZOld := ''
							BAOld := ''
							BBOld := ''
							BCOld := ''
							BDOld := ''
							BEOld := ''
							BFOld := ''
							BGOld := ''
							BHOld := '' 
							    
						    FCLOSE(nHdl2)                                                       
						
						    // *** FINAL DA VERIFICACAO DE INCONSISTENCIA COM O ARQUIVO ANTERIOR******** //
					        
					    ELSE
					        cLinha3 := ''
					        cLinha3 := cLinha1
					    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
						      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
						         Exit
						      EndIf
						   EndIf 
					    ENDIF //IF SUBSTR(aInconsis[nContVetor][2],6,8) == cCnpj1 	
					ELSE         
					
						cLinha3 := ''
				        cLinha3 := cLinha1
				    	If FWrite(nHdl3, cLinha3, Len(cLinha3)) <> Len(cLinha3)
					      If !MsgAlert("Ocorreu um erro na gravacao do arquivo.", "Atencao!")
					         Exit
					      EndIf
					   EndIf 
					    
					ENDIF //IF AA == 1
				
					AA := ''
					AB := ''
					AC := ''
					AD := ''
					AE := ''
					AF := ''
					AG := ''
					AH := ''
					AI := ''
					AJ := ''
					AK := ''
					AL := ''
					AM := ''
					AN := ''
					AO := ''
					AP := ''
					AQ := ''
					AR := ''
					AT := ''
					AU := ''
					AV := ''
					AX := ''
					AZ := ''
					BA := ''
					BB := ''
					BC := ''
					BD := ''
					BE := ''
					BF := ''
					BG := ''
					BH := '' 
					
				    nByteLid1  := FRead(nHdl1, @cLinha1, nTamLin1)
				
				EndDo
				
				FCLOSE(nHdl1)	   
				FCLOSE(nHdl3)
				
				IF lerro54 == .T.
				    //apaga o arquivo temporario e renomeia ele para o nome oficial
				    lerro54 := .F.
					If File(_cFile)
						FErase(_cFile)
						FRename(_cFile3 , _cFile) //StrTran(_cFile, '.txt', '')
					EndIf
				END   	   	
				
			ENDIF // SUBSTR(aInconsis[nContVetor][1],1,2) == '54'
		NEXT
	
		// ****************** FINAL ERRO 54 ******************** //
	    
    ELSE   //lErroArqOldArqNew == .F.
		
		FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO -2 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '-2'
			    
			    lerroM2  := .T.
			    cDtUltRe := ''
			    cDtAcuMu := ''
				nVlAcumu := ''
				
				SqlMaxCgc(SUBSTR(aInconsis[nContVetor][2],6,8))	  
				
				While TRF->(!EOF())    
				
					SqlCliCgc(SUBSTR(aInconsis[nContVetor][2],6,8))
				    While TRD->(!EOF()) 
				                
				    	IF cDtUltRe == ''
				    	
				    		cDtUltRe := TRD->A1_DTULTRE
				    		cDtAcuMu := TRD->A1_DTACUMU
							nVlAcumu := TRD->A1_VLACUMU
				        
				    	ENDIF
				    	
				    	TRD->(DBSKIP())
					ENDDO
					TRD->(dbCloseArea())
				
					SqlCliCgc(SUBSTR(aInconsis[nContVetor][2],6,8))
				    While TRD->(!EOF())
				    
				    	IF ALLTRIM(TRD->A1_DTULTRE) == ''
				            
				            DBSELECTAREA("SA1")
							DbSetOrder(1)
							
								IF SA1->(DbSeek(xFilial("SA1")+TRD->A1_COD+TRD->A1_LOJA, .T.))
								    
									RecLock("SA1",.F.)              
									
										SA1->A1_DTACUMU	:= STOD(cDtAcuMu)
										SA1->A1_VLACUMU	:= nVlAcumu
						                SA1->A1_DTULTRE := STOD(cDtUltRe)
									MsUnlock()

									u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN003P",;
									"1- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- SA1->A1_DTACUMU ="+dTOC(SA1->A1_DTACUMU)+" SA1->A1_VLACUMU= "+cValtochar(SA1->A1_VLACUMU),;
									ComputerName(),LogUserName())
									   
								ENDIF
					        DBCLOSEAREA("SA1")
						ENDIF
				        TRD->(DBSKIP())
					ENDDO
					TRD->(dbCloseArea())
				TRF->(DBSKIP())
				ENDDO
				TRF->(dbCloseArea())
			ENDIF
			
		NEXT
		
		IF lerroM2 == .T.
	        lerroM2 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF     	 
		
		// ****************** FINAL ERRO -2 ******************** //
	    
		/*FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO 13 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '13'
			    
			    lerro13 := .T.
				SqlUltimaDataEmissao(SUBSTR(aInconsis[nContVetor][2],6,8))	  
				
				While TRE->(!EOF()) 
				
					IF TRE->E1_EMISSAO <> TRE->A1_DTULTRE
					
						SqlCliCgc(SUBSTR(aInconsis[nContVetor][2],6,8))
					    While TRD->(!EOF())
					    
					        DBSELECTAREA("SA1")
							DbSetOrder(1)
							
							IF SA1->(DbSeek(xFilial("SA1")+TRD->A1_COD+TRD->A1_LOJA, .T.))
							                                               
							    
								RecLock("SA1",.F.)              
								
									SA1->A1_DTULTRE := STOD(TRE->E1_EMISSAO)
								MsUnlock() 
								   
							    DBCLOSEAREA("SA1")
					        ENDIF
							TRD->(DBSKIP())
						ENDDO
						TRD->(dbCloseArea())
					ENDIF
				    TRE->(DBSKIP())
				ENDDO
				TRE->(dbCloseArea())
			ENDIF
			// ****************** FINAL ERRO 13 ******************** //
		NEXT
		
		IF lerro13 == .T.
	        lerro13 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF     
		
		FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO 18 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '18'
			    
			    lerro18 := .T.
				// **************************** inicio gravar informacao da ultima compra da rede ************ //
				SqlTOTCGC(SUBSTR(aInconsis[nContVetor][2],6,8)) //CARREGA TODOS OS CNPJ
			    While TRG->(!EOF())        
			    
			        //CARREGA TODOS OS COD E LOJA DO CNPJ INFORMADO
		    		SqlCGCCODCLI(TRG->A1_CGC)
			    	While TRH->(!EOF())    
			    	
			    	    DBSELECTAREA("SA1")
						DbSetOrder(1)
						
						IF SA1->(DbSeek(xFilial("SA1")+TRH->A1_COD+TRH->A1_LOJA, .T.))
						
						    IF EMPTY(SA1->A1_DTULTRE)
						          
						    	RecLock("SA1",.F.)              
								
									SA1->A1_DTULTRE	:= STOD(TRG->E1_EMISSAO)	//GRAVA DT ULT COMPRA DA REDE				
									
								MsUnlock() 
		                          
		                    ELSEIF SA1->A1_DTULTRE < STOD(TRG->E1_EMISSAO)
		                        
						   		RecLock("SA1",.F.)              
								
									SA1->A1_DTULTRE	:= STOD(TRG->E1_EMISSAO)	//GRAVA DT ULT COMPRA DA REDE				
									
								MsUnlock()
						
							ELSE
							    
								RecLock("SA1",.F.)              
								
									SA1->A1_DTULTRE	:= SA1->A1_DTULTRE	
									
								MsUnlock()
							    
						    ENDIF
							DBCLOSEAREA("SA1")
				        ENDIF           
					    
				        TRH->(DBSKIP())
					ENDDO
					TRH->(dbCloseArea())    
				
					TRG->(DBSKIP())
				ENDDO
				TRG->(dbCloseArea())
			ENDIF	
			// ****************** FINAL ERRO 18 ******************** //
		NEXT
		
		IF lerro18 == .T.
	        lerro18 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF     	 
		
		FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO 56 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '56'
			    
			    lerro56 := .T.
				SqlMaxCgc(SUBSTR(aInconsis[nContVetor][2],6,8))	  
				
				While TRF->(!EOF()) 
				
					SqlCliCgc(SUBSTR(aInconsis[nContVetor][2],6,8))
				    While TRD->(!EOF())
				    
				    	IF ALLTRIM(TRD->A1_DTACUMU) < ALLTRIM(TRF->A1_DTULTRE)
				            
				            DBSELECTAREA("SA1")
							DbSetOrder(1)
							
								IF SA1->(DbSeek(xFilial("SA1")+TRD->A1_COD+TRD->A1_LOJA, .T.))
								    
								   	RecLock("SA1",.F.)              
									
										SA1->A1_DTACUMU	:= STOD(TRF->A1_DTULTRE)
										
									MsUnlock() 
									   
								ENDIF
					        DBCLOSEAREA("SA1")
						ENDIF
				        TRD->(DBSKIP())
					ENDDO
					TRD->(dbCloseArea())
				TRF->(DBSKIP())
				ENDDO
				TRF->(dbCloseArea())
			ENDIF
			// ****************** FINAL ERRO 56 ******************** //
		NEXT
		
		IF lerro56 == .T.
	        lerro56 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF     	 
		*/
		FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO 10 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '10'
			    
			    lerro10 := .T. 
			       //DT MAIOR ACUMULO                    >   DT ULTIMA COMPRA
			    IF SUBSTR(aInconsis[nContVetor][3],20,8) >  SUBSTR(aInconsis[nContVetor][4],20,8) 
			    
			    	SqlMaxCgc(SUBSTR(aInconsis[nContVetor][2],6,8))	  
				
					While TRF->(!EOF()) 
					
						IF TRF->A1_ULTCOM == TRF->A1_DTACUMU
						
							cQuery := " UPDATE "+RetSqlName("SA1")+ " "
							cQuery += " SET A1_XDTPENU = '" + TRF->A1_DTULTRE + "'" + ", " 	
							cQuery += "     A1_DTULTRE = A1_ULTCOM "			
							cQuery += " WHERE A1_XCGC = '" + TRF->A1_CGC + "' "		
						   
				            TCSQLExec(cQuery) 
						
						ENDIF 
						
						IF ALLTRIM(TRF->A1_DTULTRE) <> ''                       .AND. ;
						   ALLTRIM(TRF->A1_XDTPENU) == ''                       .AND. ;
						   ALLTRIM(TRF->A1_DTULTRE)  < ALLTRIM(TRF->A1_DTACUMU) 
						
							cQuery := " UPDATE "+RetSqlName("SA1")+ " "
							cQuery += " SET A1_DTACUMU = '" + TRF->A1_DTULTRE + "'" + " " 	
			                cQuery += " WHERE A1_XCGC = '" + TRF->A1_CGC + "' "		
						   
				            TCSQLExec(cQuery) 
						
						ENDIF 
						
						IF ALLTRIM(TRF->A1_DTULTRE)  < ALLTRIM(TRF->A1_DTACUMU) .AND. ;
						   ALLTRIM(TRF->A1_DTULTRE) <> ''                       .AND. ;
						   ALLTRIM(TRF->A1_DTACUMU) <> ''  
						
							cQuery := " UPDATE "+RetSqlName("SA1")+ " "
							cQuery += " SET A1_DTACUMU = '" + TRF->A1_DTULTRE + "'" + " " 	
			                cQuery += " WHERE A1_XCGC = '" + TRF->A1_CGC + "' "		
						   
				            TCSQLExec(cQuery) 
						
						ENDIF 
					
					TRF->(DBSKIP())
					ENDDO
					TRF->(dbCloseArea())
				    
				    
						    
			    ENDIF
				
			ENDIF
			// ****************** FINAL ERRO 10 ******************** //
		NEXT
		
		IF lerro10 == .T.
	        lerro10 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF

		FOR nContVetor := 1 TO LEN(aInconsis)
	                                                               
	        // ****************** INICIO ERRO 25 ******************** //
			IF SUBSTR(aInconsis[nContVetor][1],1,2) == '25' 
			    
			    lerro25  := .T.
			    
				SqlMaxCgc(SUBSTR(aInconsis[nContVetor][2],6,8))	  
				
				While TRF->(!EOF())    
				
					SqlCliCgc(SUBSTR(aInconsis[nContVetor][2],6,8))
				    While TRD->(!EOF())
				    
				    	IF ALLTRIM(TRD->A1_DTACUMU) == ''
				            
				            DBSELECTAREA("SA1")
							DbSetOrder(1)
							
								IF SA1->(DbSeek(xFilial("SA1")+TRD->A1_COD+TRD->A1_LOJA, .T.))

								    RecLock("SA1",.F.)              
									
										SA1->A1_DTACUMU	:= STOD(TRF->A1_DTACUMU)
										SA1->A1_VLACUMU	:= TRF->A1_VLACUMU
						                
									MsUnlock()

									u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN003P",;
									"2- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- SA1->A1_DTACUMU ="+dTOC(SA1->A1_DTACUMU)+" SA1->A1_VLACUMU= "+cValtochar(SA1->A1_VLACUMU),;
									ComputerName(),LogUserName())
									
								ENDIF
					        DBCLOSEAREA("SA1")
						ENDIF
				        TRD->(DBSKIP())
					ENDDO
					TRD->(dbCloseArea())
				TRF->(DBSKIP())
				ENDDO
				TRF->(dbCloseArea())
			ENDIF
			
		NEXT
		
		IF lerro25 == .T.
	        lerro25 := .F.
	 		RETURN(NIL) //PARA CADA ERRO CONCERTADO, RETORNA PARA VER OS PROXIMOS ERROS, 
	    		        //pois um erro pode arrumar o outro, dando problema no arquivo
		ENDIF     	 
		
		// ****************** FINAL ERRO 25 ******************** //
		
	ENDIF  //lErroArqOldArqNew
	
RETURN(NIL)


STATIC FUNCTION EmailMaiorAcum(cMetodo,nId,cmensagem)

    Local   cServer   := Alltrim(GetMv("MV_INTSERV"))  
    Local   cAccount  := AllTrim(GetMv("MV_INTACNT"))
    Local   cPassword := AllTrim(GetMv("MV_INTPSW"))
    Local   cFrom     := AllTrim(GetMv("MV_INTACNT"))
    Local   cTo       := IIF(nId <> 3,AllTrim(GetMv("MV_#USUMAI")),AllTrim(GetMv("MV_#USUMA2"))) 
    Local   lOk       := .T.  
    Local   lAutOk    := .F. 
    Local   lSmtpAuth := GetMv("MV_RELAUTH",,.F.) 
    Local   cSubject  := ""  
    Local   cBody     := ""             
    Local   _cFile    := ('SYSTEM\' + 'cisp\' + 'arq_cisp_atual\' + 'PFJ_0138' + '.txt')
    Local   cAtach    := IIF(nId <> 3,"",_cFile)               
    Local   _cStatEml := ""
    Local   _cPedido  := ""
    Local   _cStatEml := ""    
    
    
	_cStatEml    := cMetodo 
    cBody        := RetHTML(_cStatEml,nId,cmensagem)
    lOk          := .T.  
    lAutOk       := .F. 
    Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
	                        
	IF lAutOk == .F.
		IF ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
	    ELSE
	        lAutOk := .T.
	    ENDIF
	ENDIF

	IF lOk .And. lAutOk     
	   cSubject := "POSITIVAS - PRODUCAO - 0138"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    // ********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA ************** //

RETURN(NIL)   


Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0
	Local nCont      := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>ARQUIVO CISP............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF nId == 1      // Geracao de arquivo com erro
 	
	   cRet += " Arquivo txt da cisp nao foi gerada"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF   
	
	IF nId == 2      // Erro Inconsistencia
 	
	   cRet += " Erro Inconsistencia"
	   cRet += "<br>"
	   cRet += "<br>"  
	   
	   FOR nCont := 1 TO LEN(aInconsis)
		    
		    cRet += 'Inconsistencia: ' + CVALTOCHAR(nCont)  + "<br>"
			cRet += aInconsis[nCont][1]  + "<br>"
			cRet += aInconsis[nCont][2]  + "<br>"
			cRet += aInconsis[nCont][3]  + "<br>"
			cRet += aInconsis[nCont][4]  + "<br>"
			cRet += aInconsis[nCont][5]  + "<br>"
			cRet += aInconsis[nCont][6] + "<br>" + "<br>"
	
		NEXT	
		
		FOR nCont := 1 TO LEN(aAlert)
		    
		    cRet += 'Inconsistencia: ' + CVALTOCHAR(nCont)  + "<br>"
			cRet += aAlert[nCont][1]  + "<br>"
			cRet += aAlert[nCont][2]  + "<br>"
			cRet += aAlert[nCont][3]  + "<br>"
			cRet += aAlert[nCont][4]  + "<br>"
			cRet += aAlert[nCont][5]  + "<br>"
			cRet += aAlert[nCont][6] + "<br>" + "<br>"
	
		NEXT	
			
		cRet += cmensagem

	ENDIF   
	
	
	IF nId == 3      // Geracao de arquivo com erro
 	
	   cRet += " Arquivo txt da cisp enviado corretamente, favor adicionar o txt em base de produção. "
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	   
	ENDIF    
	
	IF nId == 4      // Geracao de arquivo com erro
 	
	   cRet += " Iniciando geracao do arquivo da cisp"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF    
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)  

Static Function SqlGeraCisp()

    BeginSQL Alias "TMPCISP"
			%NoPARSER%   
			SELECT * FROM VW_CISP
			
	EndSQl

RETURN()  

Static Function SqlProcCgc(cCnpj1)

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT A1_DTACUMU, 
				   A1_VLACUMU,
				   MAX(A1_DTULTRE) AS A1_DTULTRE, 
				   RTRIM((LEFT(A1_XCGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_XCGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_XCGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_XCGC,8))) = %EXP:cCnpj1%
			   AND D_E_L_E_T_ <> '*' 
			   
			   GROUP BY A1_DTACUMU,A1_VLACUMU,LEFT(A1_XCGC,8)

			 //ORDER BY A1_XCGC
			    
	EndSQl             
RETURN(NIL)       

Static Function SqlBkpSa1Csv()    

	BeginSQL Alias "TRC"
			%NoPARSER% 
			SELECT LEFT(A1_CGC,8) AS A1_CGC,
			       A1_DTACUMU,
				   A1_VLACUMU,
				   A1_DTULTRE,
	               A1_XDTPENU
			  FROM %Table:SA1% WITH(NOLOCK)
			 WHERE D_E_L_E_T_  <> '*'
			   AND (A1_VLACUMU  > 0 
			    OR  A1_DTACUMU <> ''
			    OR  A1_DTULTRE <> ''
	            OR  A1_XDTPENU <> '')
			
			GROUP BY LEFT(A1_CGC,8), A1_DTACUMU, A1_VLACUMU, A1_DTULTRE, A1_XDTPENU
			
			ORDER BY LEFT(A1_CGC,8) 
			
	EndSQl             
RETURN(NIL)    

Static Function SqlCliCgc(cCnpj)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT A1_COD,
			       A1_LOJA,
			       A1_NOME, 
			       A1_DTACUMU, 
			       A1_VLACUMU, 
			       A1_DTULTRE,
			       A1_XDTPENU,
			       A1_ULTCOM, 
			       RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpj%
			   AND D_E_L_E_T_ <> '*' 

			 ORDER BY A1_CGC
			    
	EndSQl             
RETURN(NIL) 

Static Function SqlUltimaDataEmissao(cCnpj2)

	BeginSQL Alias "TRE"
			%NoPARSER% 
			SELECT TOP(1) %Table:SE1%.D_E_L_E_T_,
			              %Table:SE1%.E1_EMISSAO,
						  A1_DTULTRE,
			              LEFT(A1_CGC,8) AS A1_CGC  
			         FROM %Table:SA1% WITH(NOLOCK), %Table:SE1% WITH(NOLOCK)
			        WHERE LEFT(A1_CGC,8)     = %EXP:cCnpj2%
			          AND E1_CLIENTE         = A1_COD
			          AND E1_LOJA            = A1_LOJA
			          AND E1_TIPO            = 'NF'
			          AND %Table:SE1%.D_E_L_E_T_ <> '*'
					  //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
					  AND E1_EMISSAO 			  <= %EXP:cDtCorte%
				  	  AND LEFT(E1_PORTADO,1)  	  != 'P'
			     ORDER BY %Table:SE1%.E1_EMISSAO DESC
	 EndSQl             
RETURN(NIL) 

Static Function SqlMaxCgc(cCnpj3)

	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT MAX(A1_DTACUMU) AS A1_DTACUMU, 
			       MAX(A1_VLACUMU) AS A1_VLACUMU,
				   MAX(A1_DTULTRE) AS A1_DTULTRE,
				   MAX(A1_ULTCOM)  AS A1_ULTCOM, 
				   MAX(A1_XDTPENU) AS A1_XDTPENU,
				   RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpj3%
			   AND D_E_L_E_T_ <> '*' 
			   
			   GROUP BY LEFT(A1_CGC,8)

			 ORDER BY A1_CGC
			    
	EndSQl             
RETURN(NIL)              

Static Function SqlTOTCGC(cCnpj4)

	BeginSQL Alias "TRG"
			%NoPARSER% 
			SELECT  A1_DTACUMU, 
					A1_VLACUMU,
					MAX(A1_DTULTRE) AS A1_DTULTRE, 
					MAX(A1_ULTCOM)  AS A1_ULTCOM,
					MAX(E1_EMISSAO) AS E1_EMISSAO, 
					RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
				FROM %Table:SA1% WITH(NOLOCK),%Table:SE1% WITH(NOLOCK) 
				WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
				  AND RTRIM((LEFT(A1_CGC,8))) <> '' 
				  AND A1_ULTCOM               <> ''
				  AND %Table:SA1%.D_E_L_E_T_       <> '*' 
				  AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpj4%
				  AND A1_XCGC                  = E1_XCGC
				  AND E1_TIPO                  = 'NF'
				  AND E1_EMISSAO 			  <= %EXP:cDtCorte%
				  AND LEFT(E1_PORTADO,1)  	  != 'P'
				  //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
				  //AND SE1010.D_E_L_E_T_       <> '*'     
				  
				  
				GROUP BY A1_DTACUMU,A1_VLACUMU,LEFT(A1_CGC,8)
			
				ORDER BY A1_CGC
	 
	EndSQl             
RETURN(NIL)               		

STATIC FUNCTION SqlCGCCODCLI(cCnpj5)

	BeginSQL Alias "TRH"
			%NoPARSER% 
			SELECT A1_COD,
			       A1_LOJA,
			       A1_NOME, 
			       A1_DTACUMU, 
			       A1_VLACUMU, 
			       RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpj5%
			   AND D_E_L_E_T_ <> '*'                  
			   
             ORDER BY A1_CGC
	 
	EndSQl             
RETURN(NIL)     
