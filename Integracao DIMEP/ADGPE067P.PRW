#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADGPE067P
	Integracao com o sistema DIMEP de catracas Integração de Caminhoneiros a partir de sql Usando o linked Server para DIMEP
	@type  Function
	@author ADRIANO SAVOINE
	@since 21/09/2021
	@version 01
	@history TI - ADRIANO SAVOINE - Dismembrando o Schedule ADGPE024P para rodar somente Motoristas neste.
	@history Chamado 66187 - Leonardo P. Monteiro  - 10/01/2022 - Implementa��o da integra��o de motoristas estrangeiros que utilizam passaporte ao inv�s do CPF como identifica��o.
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Ticket  77205 - Adriano Savoine  - 27/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
/*/

USER FUNCTION ADGPE067P(aParam)

	
	Default aParam    := Array(2)
	Default aParam[1] := "01"
	Default aParam[2] := "02"
	
	Private cLinked := "" 
	Private cSGBD   := "" 

	PRIVATE lFuncIntegrar      := .F. 
	PRIVATE lFuncSitFolha      := .F. 
	PRIVATE lFuncCredencial    := .F.
	PRIVATE lCamIntegrar       := .F. 
    PRIVATE	lCamSitFolha       := .F. 
	PRIVATE	lCamCredencial     := .F.     
	PRIVATE lCargFaixa         := .F. 
	PRIVATE nSitFol            := 0
	PRIVATE nSitFolMult        := 0
	PRIVATE nCdPessoa          := 0 
	PRIVATE cDataIni           := ''
	PRIVATE cDataFin           := ''                        
	PRIVATE dDtIniDimep        := CTOD("  /  /  ")                       
	PRIVATE dDtFinDimep        := CTOD("  /  /  ")                       
	PRIVATE nCredencial        := 0
	PRIVATE nCredMat           := 0
    PRIVATE nRep               := 0 
    PRIVATE cQuery             := '' 
    PRIVATE CcodTurno          := ''      
    PRIVATE nEstOrganizacional := 0 
    PRIVATE nEstRelacionada    := 0
    PRIVATE nEstOrgEmpresa     := 0
    PRIVATE nFlagAusente       := 0
    PRIVATE cJornada           := ''
    PRIVATE nCont              := 0  
    PRIVATE nCont1             := 0  
	PRIVATE nCont2             := 0  
    PRIVATE cBloqMot           := ''
    PRIVATE nMatMot            := 0 
    PRIVATE cCpfMot            := '' 
    PRIVATE cPasPorMot         := '' 
    PRIVATE cNomeMot           := '' 
    PRIVATE cRgMot             := '' 
    PRIVATE cFilMot            := ''
    PRIVATE cCcMot             := ''
    PRIVATE cFilFunc           := ''
    PRIVATE cCcFunc            := ''
	PRIVATE cCcFuncDimep       := ''
    PRIVATE nCredMot           := ''
    PRIVATE nPerfilAcesso      := 0
    PRIVATE cNomecPerfil       := ''
    Private nCredFunc          := 0   
    Private cIntregou          := ''     
    Private cTexto             := ''
    Private cNu_Estrutura      := ''
    Private nQtdAcesso         := 0
	Private nMatProth          := 0 
	Private cDtVlCNH           := ''
	Private cEmpDimep          := ''
	Private nDiaSemana         := 0
	Private nHoraIni           := 0

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv(aParam[1],aParam[2],,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	cLinked := GetMV("MV_#RMLINK",,"RM") 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	ConOut("INICIO DO SCHEDULE ADGPE067P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])       

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Integração de Funcionarios e Caminhoneiros a partir de sql Usando o linked Server para DIMEP')
	
    logZBN("1") //Log início.

	IF CEMPANT == '01' 
		DimepCaminhoneiro() 
	ENDIF
	
	//-> Recupera e/ou define um bloco de código para ser avaliado quando ocorrer um erro em tempo de execução.
	bError := ErrorBlock( {|e| cError := e:Description } ) //, Break(e) } )

	//-> Inicia sequencia.
	BEGIN SEQUENCE

		// Checo se LINKED SERVER está no ar!
		LS := GetNextAlias()
		
		cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '
		cQuery += "				SELECT TOP 1 *
		cQuery += "				FROM [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK)
		cQuery += " ')

		tcQuery cQuery New Alias LS

		If Select("LS") > 0
			DimepRegraDeAcesso() 
		Else
			LS->( dbCloseArea() )
		EndIf

	RECOVER
		
		//-> Recupera e apresenta o erro.
		ErrorBlock( bError )
		MsgStop( cError )
		
	END SEQUENCE

	
	logZBN("2") //Log fim.

	ConOut("FINAL DO SCHEDULE ADGPE067P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])
	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	


RETURN(NIL)  	
	
STATIC FUNCTION DimepRegraDeAcesso()	

	Local nCont2

	// *** INICIO INTEGRACAO REGRA DE ACESSO *** //
	
	SqlTurno(CVALTOCHAR(VAL(CEMPANT)))
	
	// *** INICIO BUSCA TURNO NO PROTHEUS *** //
	TRL->( dbGoTop() )
	While TRL->(!EOF())       
	    
		lCargFaixa   := .F.    
		nFlagAusente := 0
        cJornada     := ''
        nCont        := 0
        cIntregou    := ''
        cTexto       := ''
		
		// *** INICIO VERIFICA TURNO SE JA ESTA CADASTRADO NO DIMEP *** //
	
		SqlVTurnoDimep(VAL(CEMPANT + TRL->CODIGO))
		
    	IF TRH->(EOF()) 
	    		 
	    	CargaTurnoDimep(VAL(CEMPANT + TRL->CODIGO),SUBSTR(TRL->DESCRICAO,1,30))
	    	
	    	TRH->(dbCloseArea())
	    	
	    	// *** INICIO Pega o codigo do turno que gerou no DIMEP *** //
	    	SqlVTurnoDimep(VAL(CEMPANT + TRL->CODIGO))
		    
	    	IF TRH->(!EOF()) 
	    	
	    		INTUSUSISTURNO(TRH->CD_TURNO)	
	    		
	    		// *** INICIO VERIFICACAO JORNADA *** //
	    		SqlJorRM(CEMPANT,TRL->CODIGO)
	    		While TRM->(!EOF())

	    			nDiaSemana := 0
                    nHoraIni   := IIF(AT('.',CVALTOCHAR(TRM->HR_INI)) == 0,TRM->HR_INI,VAL(SUBSTRING(CVALTOCHAR(TRM->HR_INI),1,AT('.',CVALTOCHAR(TRM->HR_INI)) - 1) + '.' + CVALTOCHAR(VAL( '0.' + SUBSTRING(CVALTOCHAR(TRM->HR_INI),AT('.',CVALTOCHAR(TRM->HR_INI)) + 1,LEN(CVALTOCHAR(TRM->HR_INI)))) * 60)))
					IF lCargFaixa == .F. // CARREGA TURNO FAIXA SO NA PRIMEIRA VEZ
					
						IF ALLTRIM(TRM->CODHORARIO) = '0156' // turno gerencia
                           
							SqlFxHor('1','2',)
							While TRS->(!EOF())       
				
								INTTURNOFAIXA(TRH->CD_TURNO,TRS->CD_FAIXA_HORARIA)
								
								TRS->(dbSkip())
										
							ENDDO
							TRS->(dbCloseArea())

							SqlFxHor('3','4',)

						ELSEIF nHoraIni >= 12 .AND. nHoraIni <= 19.59 // turno tarde 

							SqlFxHor('3','4')

						ELSEIF nHoraIni >= 20 .AND. nHoraIni <= 23.59 //Turno Noturno 

							SqlFxHor('1','4')
                         
						ELSE	  

							SqlFxHor('1','2')

						ENDIF

						While TRS->(!EOF())       
				
							INTTURNOFAIXA(TRH->CD_TURNO,TRS->CD_FAIXA_HORARIA)
							
							TRS->(dbSkip())
									
						ENDDO
						TRS->(dbCloseArea())
						
						INTJORNADA(CVALTOCHAR(VAL(CEMPANT + TRM->CODHORARIO)))
						
						SqlJORNADA(CVALTOCHAR(VAL(CEMPANT + TRM->CODHORARIO)))
						While TRO->(!EOF())       
				
							INTUSUSISJORNADA(TRO->CD_JORNADA)
							
							TRO->(dbSkip())
									
						ENDDO
						TRO->(dbCloseArea())
						
						lCargFaixa := .T. 
						
					ENDIF
					// *** FINAL DIREITO A TODAS AS FAIXAS  *** //
					
		            TRM->(dbSkip())
							
				ENDDO
			    TRM->(dbCloseArea()) 
			    // *** FINAL VERIFICACAO JORNADA *** //
	    	
	    	ENDIF	
			
	    	// *** Final Pega o codigo do turno que gerou no DIMEP *** //

			// *** INICIO ADICIONA O DIA DE SEMANA NA JORNADA

			SqlJORNADA(CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO)))
			IF TRO->(!EOF())       

				FOR nCont2 := 0 TO 7

					SqlJorDia(TRO->CD_JORNADA,nCont2,TRH->CD_TURNO) // verifica se ja existe uma jornada dia
					
					IF TRV->(EOF())  

						INTJORDIA(TRO->CD_JORNADA,nCont2,TRH->CD_TURNO)
						
					ENDIF
					TRV->(dbCloseArea())	

				NEXT		
			ENDIF
			TRO->(dbCloseArea())	

			// *** FINAL ADICIONA O DIA DE SEMANA NA JORNADA

    	ENDIF
    	TRH->(dbCloseArea())
    	
    	// *** FINAL CARREGA TURNO E JORNADA *** //
    	
    	// *** INICIO CARREGA PERFIL DE ACESSO *** //
    	SqlPerAc(CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO))) 
    	
    	IF TRP->(EOF())
    	
    		INTPERAC(CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO))) // Integra Perfil de Acesso
    		
    		// *** INICIO GERA LOG *** //              
    		cTexto := '1 Log Turno:' + 'Cod Turno: ' + CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO))
	    	GERALOG('',cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
	    	
			// *** FINAL GERA LOG *** // 
    		
    		TRP->(dbCloseArea()) 
    		
    		SqlPerAc(CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO)))
    		IF TRP->(!EOF())        
    		
    			INTSISPERFILACESSO(TRP->CD_PERFIL_ACESSO) // Integra Usuario Perfil de Acesso

				// *** INICIO INTEGRA GRUPO REFEITORIO *** //  	      	 	  
    			SqlGrupoArea(1)
    			While TRQ->(!EOF())
    				
    				SqlVTurnoDimep(VAL(CEMPANT + TRL->CODIGO))
		
			    	IF TRH->(!EOF())  
			    	
			    		SqlTurnoFaixa(TRH->CD_TURNO)
			    		nCont := 0
			    		While TRR->(!EOF())
			    			
			    			SqlJORNADA(CVALTOCHAR(VAL(CEMPANT + TRL->CODIGO)))
			    			While TRO->(!EOF())  
			    			
			    				nCont := nCont + 1
						    
						    	IF nCont == 1
						    		nFlagAusente := 1
						    		cJornada     := CVALTOCHAR(TRO->CD_JORNADA)
						    	
						    	ELSE
						    	
						    		nFlagAusente := 0
						    		cJornada     := CVALTOCHAR(TRO->CD_JORNADA)
						    	
						    	ENDIF    
						    
						    	nQtdAcesso := 1
						        INTPERACREGRA(TRP->CD_PERFIL_ACESSO,TRQ->CD_GRUPO,TRQ->CD_AREA,TRH->CD_TURNO,TRR->CD_FAIXA_HORARIA,nFlagAusente,cJornada,nQtdAcesso) // Integra Perfil de Regra
						                
						        IF nCont == 1
						        	INTPERRESTRICAO(TRP->CD_PERFIL_ACESSO,TRQ->CD_GRUPO,TRQ->CD_AREA) // Integra PERFIL_ACESSO_RESTRICAO	
						        ENDIF						        
				    	   		
				    	   		TRO->(dbSkip())
										
						    ENDDO
						    TRO->(dbCloseArea())	
			    		    TRR->(dbSkip())
							
						ENDDO
					    TRR->(dbCloseArea()) 
			    		
			    	ENDIF
    			    TRH->(dbCloseArea())                  
    			    
			    	TRQ->(dbSkip())
							
				ENDDO
			    TRQ->(dbCloseArea()) 

				// *** FINAL INTEGRA GRUPO REFEITORIO *** //

				// *** INICIO INTEGRA GRUPO CATRACA PORTARIA *** //  	      	 	  
    			SqlCatracaPortaria()
    			While TSE->(!EOF())
    				
    				SqlVTurnoDimep(VAL(CEMPANT + TRL->CODIGO))
		
			    	IF TRH->(!EOF())  
						nQtdAcesso := 999
						INTPERACREGRA(TRP->CD_PERFIL_ACESSO,TSE->CD_GRUPO,TSE->CD_AREA,'NULL','NULL','0','NULL',nQtdAcesso) // Integra Perfil de Regra
						INTPERRESTRICAO(TRP->CD_PERFIL_ACESSO,TSE->CD_GRUPO,TSE->CD_AREA) // Integra PERFIL_ACESSO_RESTRICAO	
			    	ENDIF
    			    TRH->(dbCloseArea())                  
    			    
			    	TSE->(dbSkip())
							
				ENDDO
			    TSE->(dbCloseArea()) 

    		ENDIF            
    		TRP->(dbCloseArea()) 
    		
    	ELSE                     
    		TRP->(dbCloseArea()) 
    	ENDIF 
    	
    	TRL->(dbSkip())
				
	ENDDO
	
	TRL->(dbCloseArea()) 
    
RETURN(NIL)    
        
STATIC FUNCTION DimepFuncionario()	

	Local cCodSit := "" 
	
	Sqlfuncionario(CVALTOCHAR(VAL(CEMPANT)))
	
	// *** INICIO BUSCA FUNCIONARIOS NO PROTHEUS *** //
	
	TRB->( dbGoTop() )
	While TRB->(!EOF())       
	
		lFuncIntegrar      := .F.     
		lFuncSitFolha      := .F. 
		lFuncCredencial    := .F.
		nSitFol            := 0
		nSitFolMult        := 0
		nCdPessoa          := 0
		cDataIni           := ''
	    cDataFin           := ''  
	    dDtIniDimep        := CTOD("  /  /  ")                       
	    dDtFinDimep        := CTOD("  /  /  ")
	    nCredencial        := 0
	    nCredMat           := 0
        nRep               := 0     
        CcodTurno          := ''        
        nEstOrganizacional := 0
        nEstRelacionada    := 0
        nEstOrgEmpresa     := 0    
        nPerfilAcesso      := 0
        cNomecPerfil       := ''
		cFilFunc           := STRZERO(TRB->CODFILIAL,2)
        cCcFunc            := ALLTRIM(TRB->NROCENCUSTOCONT)
        nMatProth          := VAL(TRB->CPF) // chamado 049598
		cCcFuncDimep       := BUSCACCDIMEP(nMatProth)
		cEmpDimep          := ''
        //nCredFunc          := TRB->PTOCREDENCIAL  // chamado 049598
		nCredFunc          := Val(TRB->PTOCREDENCIAL)  // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
        cIntregou          := ''
        cTexto             := ''     
        nCont1             := 0  
        
        cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth)
        VEmpresaDimep(cFilFunc,cNu_Estrutura)
		
		// *** INICIO VERIFICA SITUACAO DO FUNCIONARIO *** //
		IF ALLTRIM(TRB->CODSITUACAO) $ 'A/V/X/Z'
			nSitFol := 11 // trabalhando
		ELSEIF ALLTRIM(TRB->CODSITUACAO) == 'D'	// @history ticket   39 - Fernando Macieira - 10/02/2021 - de/para no campo CODSITUACAO
			IF DATE() >= STOD(DTOS(TRB->DATADEMISSAO)) + 1
				nSitFol := 12 // demitido
			ELSE                         
				nSitFol := 11 // trabalhando   
			ENDIF	
		ELSEIF ALLTRIM(TRB->CODSITUACAO) == 'F'	// @history ticket   39 - Fernando Macieira - 10/02/2021 - de/para no campo CODSITUACAO
			nSitFol     := 13 // Ausencia		
			nSitFolMult := 14 // Ferias 
		ELSEIF !(ALLTRIM(TRB->CODSITUACAO) $ 'A/V/X/D/F/Z')
			nSitFol     := 13 // Ausencia
			nSitFolMult := 15 // Afastamento 
		ENDIF	

		// @history ticket  14991  - Fernando Macieir- 15/06/2021 - Dimep - Contrato de Trabalho Suspenso
		IF ALLTRIM(TRB->CODSITUACAO) == 'C'
			nSitFol       := 23 // C - Contrato de Trabalho Suspenso
			lFuncSitFolha := .T. 
		EndIf
		
		// *** INICIO VERIFICA AFASTAMENTO *** //
		IF ALLTRIM(TRB->CODSITUACAO) <> 'D' .AND. ALLTRIM(TRB->CODSITUACAO) <> 'C'	// @history ticket  14991  - Fernando Macieir- 15/06/2021 - Dimep - Contrato de Trabalho Suspenso
			SqlFERIAS(CVALTOCHAR(VAL(CEMPANT)),TRB->CHAPA)
			TRE->( dbGoTop() )
			IF TRE->( EOF() )
				nSitFol     := 11 // trabalhando   
				nSitFolMult := 0
				TRE->(dbCloseArea())
				SqlAfastamento(CVALTOCHAR(VAL(CEMPANT)),TRB->CHAPA)
			ENDIF

			IF TRE->( EOF() )
				nSitFol     := 11 // trabalhando   
				nSitFolMult := 0
			ENDIF
			
			While TRE->( !EOF() )
				nSitFol     := 13 // GERAL
				nSitFolMult := IIF(nSitFolMult==11,15,nSitFolMult) // Afastamento   
				cDataIni    := SUBSTR(DTOC(STOD(DTOS(TRE->DATAINICIO))),1,6) + CVALTOCHAR(YEAR(TRE->DATAINICIO))
				cDataIni    := IIF(ALLTRIM(cDataIni) <> '',CVALTOCHAR(YEAR(TRE->DATAINICIO)) + '-' + Substr(cDataIni,4,2)+ '-' + Substr(cDataIni,1,2) +  "T" + '00:00:00', cDataIni)
				cDataFin    := IIF(!EMPTY(TRE->DATAFIM),SUBSTR(DTOC(STOD(DTOS(TRE->DATAFIM))),1,6) + CVALTOCHAR(YEAR(TRE->DATAFIM)),'')
				cDataFin    := IIF(ALLTRIM(cDataFin) <> '',CVALTOCHAR(YEAR(TRE->DATAFIM))+ '-' + Substr(cDataFin,4,2)+ '-' + Substr(cDataFin,1,2) +  "T" + '23:59:59', '9999-12-31')
					
				IF nSitFolMult == 0
					IF EMPTY(TRE->DATAFIM)
						nSitFolMult := 15
					ELSEIF !EMPTY(TRE->DATAFIM) 
						IF DATE() <= TRE->DATAFIM
							nSitFolMult := 15
						ENDIF
					ELSE	
						nSitFolMult := nSitFolMult
					ENDIF
				ENDIF

				TRE->( dbSkip() )
			ENDDO

			TRE->( dbCloseArea() )

		ENDIF	

    	//verifica o turno do funcionario no cadastro de alteração de turno do ponto eletronico
		SqlVTurno(CEMPANT,TRB->CHAPA)
    	CcodTurno := CVALTOCHAR(VAL(CEMPANT + TRB->CODHORARIO))
		TRG->( dbGoTop() )
    	While TRG->(!EOF())
    		CcodTurno := CVALTOCHAR(VAL(CEMPANT + TRG->CODHORARIO))
            TRG->(dbSkip())
		ENDDO
		TRG->(dbCloseArea()) 
		
		// *** INICIO VERIFICA PESSOA SE JA ESTA CADASTRADO NO DIMEP *** //
		SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada)) // chamado 049598
		While TRC->(!EOF())
		
			nCdPessoa := TRC->CD_PESSOA  
			cEmpDimep := BUSCAEMPDIMEP(TRC->CD_ESTRUTURA_ORG_EMPRESA) 

			// *** INICIO CHAMADO 056610 WILLIAM COSTA 13/03/2020
			//Pular quando a situacao da pessoa for 21 //Quarentena, é usado o fonte ADGPE055P para ajustar essas pessoas.
			IF TRC->CD_SITUACAO_PESSOA == 21
				lFuncIntegrar := .F.
				TRC->(dbSkip())
				LOOP
			ENDIF

			// Pega o Perfil de Acesso Correto
			SqlNomePerAc(TRC->CD_PERFIL_ACESSO)
	    	
	    	IF TRX->(!EOF()) 
	    		cNomecPerfil := TRX->NM_PERFIL_ACESSO  
	    	ENDIF
	    	TRX->(dbCloseArea())
			
			// *** INICIO VERIFICA PESSOA *** //
			IF SUBSTR(TRC->NM_PESSOA,1,120) <> SUBSTR(TRB->NOME,1,120)       .OR. ;
			   VAL(TRC->NU_CPF)             <> VAL(TRB->CPF)                 .OR. ;
			   VAL(TRC->NU_RG)              <> VAL(TRB->CARTIDENTIDADE)      .OR. ;
			   VAL(TRC->NU_PIS)             <> VAL(TRB->PISPASEP)            .OR. ;
			   ALLTRIM(cNomecPerfil)        <> ALLTRIM(CcodTurno)            .OR. ;
			   ALLTRIM(cNu_Estrutura)       <> ALLTRIM(TRB->NROCENCUSTOCONT) .OR. ;
			   ALLTRIM(cEmpDimep)           <> ALLTRIM(cEmpAnt)
			   
				lFuncIntegrar := .T.
			ENDIF
			   
			// *** INICIO VERIFICA SITUACAO PESSOA AFASTAMENTO OU FERIAS *** //
			If nSitFol <> 23 // @history ticket  14991  - Fernando Macieir- 15/06/2021 - Dimep - Contrato de Trabalho Suspenso
				IF TRC->CD_SITUACAO_PESSOA <> nSitFol
					lFuncSitFolha := .T. 
				ENDIF  

				SqlVSitPessoaDimep(nCdPessoa)
				IF nSitFol == 13 .AND. (nSitFolMult == 14 .OR. nSitFolMult == 15) .AND. TRD->(EOF()) 
					lFuncSitFolha := .T. 
				ENDIF
				
				While TRD->(!EOF()) 
					dDtIniDimep        := IIF(DTOC(TRD->DT_INI) == '01/01/00' .AND. ALLTRIM(cDataIni) == '',CTOD("  /  /  "),TRD->DT_INI)                      
					dDtFinDimep        := IIF(DTOC(TRD->DT_FIN) == '01/01/00',CTOD("  /  /  "),TRD->DT_FIN)
					IF TRD->CD_SITUACAO_PESSOA <> nSitFolMult                                    .OR. ;
						dDtIniDimep             <> STOD(STRTRAN(SUBSTRING(cDataIni,1,10),'-','')) .OR. ;
						dDtFinDimep             <> STOD(STRTRAN(SUBSTRING(cDataFin,1,10),'-','')) 
					
						lFuncSitFolha := .T. 
					ENDIF  
					
					TRD->(dbSkip())
				ENDDO
				TRD->(dbCloseArea())       
			EndIf
			
			// *** INICIO VERIFICA SITUACAO CREDENCIAL *** //
	    	SqlVCredencialDimep(nCredFunc)
	   		IF TRF->(EOF()) 
		   		lFuncCredencial := .T. 
			ENDIF
			TRF->(dbCloseArea()) 
			
	    	// *** Inicio Verifica se a credencial e a Pessoa esta correta *** //
	    	IF lFuncCredencial == .F. 
		    	SqlVCredencialDimep(nCredFunc)
		   		IF TRF->(!EOF()) 
		   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
			   		IF TRT->(EOF()) 
			   			lFuncCredencial := .T. 
					ENDIF            
					TRT->(dbCloseArea()) 
		   		ENDIF
		    	TRF->(dbCloseArea()) 
		    ENDIF	
	    	
	    	// *** Inicio Verifica se existe a credencial na tabela para o campo credencial*** //
	    	IF lFuncCredencial == .F.
		    	SqlVCredencialDimep(nCredFunc)
		   		IF TRF->(EOF()) 
			   		lFuncCredencial := .T. 
				ENDIF
				TRF->(dbCloseArea()) 
				
		    	// *** Inicio Verifica se a credencial e a Pessoa esta correta *** //
		    	IF lFuncCredencial == .F. 
			    	SqlVCredencialDimep(nCredFunc)
			   		IF TRF->(!EOF()) 
			   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
				   		IF TRT->(EOF()) 
				   			lFuncCredencial := .T. 
						ENDIF            
						TRT->(dbCloseArea()) 
			   		ENDIF
			    	TRF->(dbCloseArea()) 
			    ENDIF	
		    ENDIF                            
		    
		    // *** Inicio Credencial Codigo de Barras igual Matricula Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** //
		    IF lFuncCredencial == .F. 
		    	SqlVCredencialDimep(nMatProth)
		   		IF TRF->(!EOF()) 
		   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
		   			While TRT->(!EOF()) 
		   				IF TRT->DT_FIM <> CTOD("  /  /  ") 	//so entra se a data fim tiver valor  
		   					// *** Inicio Credencial igual a Matricula *** //
						    IF TRF->NU_CREDENCIAL == nMatProth .AND. ;
			   				   TRT->DT_FIM         < DATE()    .AND. ;
			   				   nSitFol            == 11 //trabalhando
				   		
					   			lFuncCredencial := .T. 
						    ENDIF          
						ENDIF
					    TRT->(dbSkip())
					ENDDO
					TRT->(dbCloseArea()) 
		   		ENDIF
		    	TRF->(dbCloseArea()) 
		    ENDIF	

		    // *** Inicio Credencial Proximidade diferente da MAtricula Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** //
		    IF lFuncCredencial == .F. 
		    	SqlVCredencialDimep(nCredFunc)
		   		IF TRF->(!EOF()) 
		   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
		   			While TRT->(!EOF()) 
		   				IF TRT->DT_FIM <> CTOD("  /  /  ") 	//so entra se a data fim tiver valor  
		   					// *** Inicio Credencial diferente a Matricula *** //
			   				IF TRF->NU_CREDENCIAL <> nMatProth .AND. ;
			   				   TRT->DT_FIM         < DATE()    .AND. ;
			   				   nSitFol            == 11 //trabalhando
				   		
					   			lFuncCredencial := .T. 
						    ENDIF          
						    // *** Final Credencial diferente a Matricula *** //
						ENDIF
					    TRT->(dbSkip())
					ENDDO
					TRT->(dbCloseArea()) 
		   		ENDIF
		    	TRF->(dbCloseArea()) 
		    ENDIF	

			// FWNM - 22/070/2021 - TICKET 17021 - Checo se o tipo de tecnologia está diferente entre CREDENCIAL e CREDENCIAL_PESSOA
			UpdTecno( TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)), Val(TRB->PTOCREDENCIAL) )

			// FWNM - 22/07/2021 - AQUI - ticket 17021 - Checo se existem 2 credenciais iguais com tecnologias diferentes
			If !lFuncCredencial
				lTpTecno13 := ChkAllCred( TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)), Val(TRB->PTOCREDENCIAL) )
				If lTpTecno13
					lFuncCredencial := .t.
				EndIf
			EndIf
			//

			// FWNM - 19/07/2021 - AQUI - ticket 17021
			If !lFuncCredencial
				
				// Checo se existe amarração Credencial x Pessoa - Tecnologia 3 = Aproximação = FACE
				lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, Val(TRB->PTOCREDENCIAL))
				If lTpTecno3
					lFuncCredencial := .t.
				EndIf

				// Checo se existe amarração Credencial x Pessoa - Tecnologia 1 = Codigo Barra = REP
				lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)))
				If lTpTecno1
					lFuncCredencial := .t.
				EndIf

			EndIf
			// 

			TRC->(dbSkip())
		
		ENDDO

    	TRC->(dbCloseArea()) 
    	
    	// *** INICIO INSERT NO DIMEP *** //
    	IF lFuncIntegrar == .F. .AND. lFuncSitFolha == .F. .AND. lFuncCredencial == .F. // Quando não existe o funcionario na DIMEP
    	    
    	    CargaFuncDimep()
    	    
    	ELSE // Quando existe o funcionario na DIMEP e houve alteracao 
    	
    		ALTERFUNCDIMEP() 
	    			    		
    	ENDIF // fecha lFuncIntegrar == .F. .AND. lFuncSitFolha == .F.
    	// *** FINAL INSERT NO DIMEP *** //
    	
    	TRB->(dbSkip())
				
	ENDDO
	TRB->(dbCloseArea()) 
    
    // *** FINAL BUSCA FUNCIONARIOS NO PROTHEUS *** //  
    // *****************************FINAL INTEGRACAO FUNCIONARIOS PROTHEUS x DIMEP**************************************** //	    
    
RETURN(NIL)

STATIC FUNCTION DimepCaminhoneiro()
	
	// *****************************INICIO INTEGRACAO CAMINHONEIRO PROTHEUS x DIMEP*************************************** //	 
	cDtVlCNH := '99991231'

	SqlCaminhoneiro(cDtVlCNH)
		
	// *** INICIO BUSCA CAMINHONEIRO NO PROTHEUS *** //
	While TRK->(!EOF())       
	
		lCamIntegrar       := .F.
		lCamSitFolha       := .F. 
		lCamCredencial     := .F.     
        nSitFol            := 0
		nSitFolMult        := 0
		nCdPessoa          := 0
		cDataIni           := ''
	    cDataFin           := ''  
	    nCredencial        := 0
	    nCredMat           := 0
        nRep               := 0 
		cQuery             := ''    
        CcodTurno          := ''        
        nEstOrganizacional := 0
        nEstRelacionada    := 0 
        nEstOrgEmpresa     := 0
        cBloqMot           := TRK->ZVC_MOTBLQ
        nMatMot      	   := 0
		cCpfMot			   := ""
		cPasPorMot 	   	   := ""
		cNomeMot           := IIF(ALLTRIM(TRK->DA4_NOME)   == '',TRK->ZVC_MOTORI,TRK->DA4_NOME)
        cRgMot             := ""
        cFilMot            := '02' 
        cCcMot             := IIF(ALLTRIM(TRK->DA4_XCC) == '',TRK->ZVC_CC,TRK->DA4_XCC)
        nCredMot           := IIF(TRK->DA4_XCREDE == 0          ,TRK->ZVC_XCREDE,TRK->DA4_XCREDE)
        nPerfilAcesso      := 0
        cNomecPerfil       := ''
        cIntregou          := ''
        cTexto             := ''
        
		//@history 66187 - LEONARDO P. MONTEIRO - Implementa��o da integra��o de motoristas estrangeiros que utilizam passaporte ao inv�s do CPF como identifica��o.
		if Empty(TRK->ZVC_CPF)
			nMatMot		:= Val(TRK->ZVC_PASPOR)
			cCpfMot		:= ""
			cPasPorMot	:= Alltrim(TRK->ZVC_PASPOR)
			cRgMot		:= ""
		ELSE
			cCpfMot		:= IIF(ALLTRIM(TRK->DA4_CGC)    == '',TRK->ZVC_CPF   ,TRK->DA4_CGC)
			nMatMot 	:= Val(cCpfMot)
			cPasPorMot	:= ""
			cRgMot      := IIF(ALLTRIM(TRK->DA4_RG)     == '',TRK->ZVC_RG    ,TRK->DA4_RG)
		endif

        VEmpresaDimep(cFilMot,cCcMot) // aqui checa código organização/organograma/centro custo

		// *** INICIO VERIFICA SITUACAO DO CAMINHONEIRO *** //
		IF ALLTRIM(cBloqMot) = 'F'
			nSitFol := 11 // trabalhando   
		ELSE
			nSitFol := 12 // demitido
		ENDIF	
		
		// *** INICIO VERIFICA PESSOA SE JA ESTA CADASTRADO NO DIMEP *** //
		SqlVFuncDimep(nMatMot,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
		While TRC->(!EOF())
		
			nCdPessoa := TRC->CD_PESSOA    
			
			// *** INICIO VERIFICA PESSOA *** //
			// @history 66187 - LEONARDO P. MONTEIRO - Implementa��o da integra��o de motoristas estrangeiros que utilizam passaporte ao inv�s do CPF como identifica��o.
			IF  TRC->NM_PESSOA           <> cNomeMot     .OR. ;
			   (!Empty(cCpfMot) .AND. Alltrim(TRC->NU_CPF) 	  <> Alltrim(cCpfMot)    ) .OR.; 
			   ( Empty(cCpfMot) .AND. Alltrim(TRC->TX_CAMPO05) <> Alltrim(cPasPorMot) ) .OR. ;
			    TRC->NU_RG               <> cRgMot       .OR. ;
			    TRC->CD_ESTRORG          <> nEstOrganizacional // @history Ticket  16699  - Fernando Macieir- 28/07/2021 - DIVERGENCIA NO CC NO DIMEP - CAMINHONEIROS
			   
			   lCamIntegrar := .T. 
		
			ENDIF  
			
			// *** INICIO VERIFICA SITUACAO PESSOA TRABALHANDO OU DEMITIDA *** //
			IF TRC->CD_SITUACAO_PESSOA <> nSitFol
				lCamSitFolha := .T. 
			ENDIF  
				
			// *** INICIO VERIFICA SITUACAO CREDENCIAL *** //
	    	SqlVCredencialDimep(nCredMot)
	   		IF TRF->(EOF()) 
		   		lCamCredencial := .T. 
			ENDIF
			TRF->(dbCloseArea()) 
			
	    	// *** Inicio Verifica se a credencial e a Pessoa esta correta *** //
	    	IF lCamCredencial == .F. 
	    	
		    	SqlVCredencialDimep(nCredMot)

		   		IF TRF->(!EOF()) 
		   		
		   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)

			   		IF TRT->(EOF()) 
			   		
			   			lCamCredencial := .T. 
					
					ENDIF            

					TRT->(dbCloseArea()) 

		   		ENDIF

		    	TRF->(dbCloseArea()) 

		    ENDIF	

			TRC->(dbSkip())
		
		ENDDO

    	TRC->(dbCloseArea()) 
    	
    	// *** INICIO INSERT NO DIMEP *** //
    	IF lCamIntegrar == .F. .AND. lCamSitFolha == .F. .AND. lCamCredencial == .F. // Quando não existe o CAMINHONEIRO na DIMEP
    	    
    	    CargaMotDimep()
    	    
    	ELSE // Quando existe o CAMINHONEIRO na DIMEP e houve alteracao 
    	
    	    AlterCamDimep()
	    	
    	ENDIF
    	// *** FINAL INSERT NO DIMEP *** //
    	
    	TRK->(dbSkip())
				
	ENDDO
	
	TRK->(dbCloseArea()) 
	
	// *****************************FINAL INTEGRACAO CAMINHONEIRO PROTHEUS x DIMEP*************************************** //	 
	
RETURN(NIL)	            
	
Static Function CargaFuncDimep()  
	
	cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth) // chamado 049598
	VEmpresaDimep(cFilFunc,cNu_Estrutura)

	// *** Inicio Verifica se existe o funcionario na tabela *** //
    SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada)) // chamado 049598
    		
    IF TRC->(EOF()) == .T. 
    
    	cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth) // chamado 049598
    	VEmpresaDimep(cFilFunc,cNu_Estrutura)
    		
    	// *** Inicio Verifica se existe a credencial na tabela *** //
    	SqlVCredencialDimep(nCredFunc)
   		IF TRF->(EOF()) 
			IF Val(TRB->PTOCREDENCIAL) > 0 // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
				INTCREDENCIAL(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
   			ENDIF
   			IF ALLTRIM(TRB->CHAPA) <> ''
	    		INTCREDENCIAL(SUBSTR(TRB->CHAPA,3,6),nEstOrgEmpresa,'1')
	    	ENDIF	
   		ELSE
   			nCredencial := TRF->CD_CREDENCIAL   
   			nRep        := TRF->CD_CREDENCIAL   
   		ENDIF
    	TRF->(dbCloseArea())
    		
    	// *** INICIO CARREGA CODIGO CREDENCIAL *** //
    	IF nCredencial == 0 .AND. nRep == 0
    		SqlVCredencialDimep(nCredFunc)
    			IF TRF->(!EOF()) 
    				nCredencial := TRF->CD_CREDENCIAL   
    				nRep        := TRF->CD_CREDENCIAL   
    			ENDIF
    		TRF->(dbCloseArea())
    	ENDIF

    	// *** INICIO CARREGA CODIGO CREDENCIAL DA MATRICULA*** //
    	IF nCredMat == 0 
    		SqlVCredencialDimep(VAL(SUBSTR(TRB->CHAPA,3,6)))
			IF TRF->(!EOF()) 
				nCredMat    := TRF->CD_CREDENCIAL   
				nRep        := TRF->CD_CREDENCIAL   
			ENDIF
    		TRF->(dbCloseArea())
    	ENDIF

    	TRC->(dbCloseArea())
    	
    	// Pega o Perfil de Acesso Correto
    	SqlPerAc(cCodTurno)
    	IF TRP->(!EOF()) 
    		nPerfilAcesso := TRP->CD_PERFIL_ACESSO   
    	ENDIF
    	TRP->(dbCloseArea())
    	
    	// Integra USuario Sistema Credencial
    	INTUSUSISCREDENCIAL(nCredencial) 
    	
    	IF SUBSTR(TRB->CHAPA,3,6) <> ''
    		INTUSUSISCREDENCIAL(nCredMat)
    	ENDIF	
    	
    	// Integra Pessoa
    	//INTPESSOA(nMatProth,TRB->NOME,nSitFol,nEstOrganizacional,nEstOrgEmpres,TRB->CPF,TRB->CARTIDENTIDADE,TRB->PISPASEP,nPerfilAcesso,nRep,nCredencial)
		INTPESSOA(nMatProth,TRB->NOME,nSitFol,nEstOrganizacional,nEstOrgEmpres,TRB->CPF,Left(AllTrim(TRB->CARTIDENTIDADE),9),TRB->PISPASEP,nPerfilAcesso,nRep,nCredencial,"") // fwnm - 19/07/2021  ticket 17021
    		                                     
    	// Verifica o numero do Funcionario
    	SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
    	
		IF TRC->(EOF()) 
			// *** INICIO GERA LOG *** //              
			cTexto := '6 Log Func:'                                                                                                         + ';' + ;
						' Fil: '             + STRZERO(TRB->CODFILIAL,2)                                                                                 + ';' + ;
						' Mat: '             + TRB->CHAPA                                                                                    + ';' + ;
						' Nome: '            + TRB->NOME                                                                                   + ';' + ;
						' Folha: '           + CVALTOCHAR(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
						' Credencial: '      + CVALTOCHAR(nCredFunc)                                                                    + ';' + ;
						' Sit Mult: '        + IIF(nSitFolMult = 13,CVALTOCHAR(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
						' Turno:'            + CcodTurno                                                                                      + ';' + ;
						' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                  + ';' + ;
						' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                  + ';' + ;
						' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
				
			GERALOG(STRZERO(TRB->CODFILIAL,2),cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 
		ENDIF	
    		
		While TRC->(!EOF()) 
			
			//Integra Credencial 
			nCredencial := 0
			nRep        := 0
			SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // Credencial = 10 digitos = PTOCREDENCIAL = Tecnologia 3 = Proximidade
			If TRF->( EOF() )
				IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') 
			Else
				nCredencial := TRF->CD_CREDENCIAL   
			EndIf
			TRF->(dbCloseArea())

			SqlVCredencialDimep(Val(SUBSTR(TRB->CHAPA,3,6))) // Chapa = 5 digitos = REP = Tecnologia 1 = Código Barras
			If TRF->( EOF() )
				IntCredencial(Val(SUBSTR(TRB->CHAPA,3,6)),nEstOrgEmpresa,'1')
			Else
				nRep        := TRF->CD_CREDENCIAL   
			EndIf	
			TRF->(dbCloseArea())

			//Integra Credencial e Credencial X Pessoa
			lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, nCredencial)
			If lTpTecno3
				INTCREPESSOA(TRC->CD_PESSOA,nCredencial,"","","3") // enviar 3 = tipo tecnologia // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf

			lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, nRep)
			If lTpTecno1
				INTCREPESSOA(TRC->CD_PESSOA,nRep,"","","1") // enviar 1 = tipo tecnologia  // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UPDPESS1('CD_CREDENCIAL_REP',nRep,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			// 

			/////////////////////
			/////////////////
			
			IF nSitFol == 13
				//Integrar situação de pessoa multipla
				INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,nSitFolMult,cDataIni,cDataFin)	
			ENDIF
	
			//Integra Historico da Pessoa
			INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
	
			// Integra USuario Sistema PESSOA
			INTUSUSISPESSOA(TRC->CD_PESSOA)   
					
			
			// *** INICIO GERA LOG *** //              
			cTexto := '2 Log Func:'                                                                                                         + ';' + ;
						' Fil: '             + STRZERO(TRB->CODFILIAL,2)                                                                                 + ';' + ;
						' Mat: '             + TRB->CHAPA                                                                                    + ';' + ;
						' Nome: '            + TRB->NOME                                                                                   + ';' + ;
						' Folha: '           + CVALTOCHAR(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
						' Credencial: '      + CVALTOCHAR(nCredFunc)                                                                    + ';' + ;
						' Sit Mult: '        + IIF(nSitFolMult = 13,CVALTOCHAR(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
						' Turno:'            + CcodTurno                                                                                      + ';' + ;
						' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                  + ';' + ;
						' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                  + ';' + ;
						' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
					
			GERALOG(STRZERO(TRB->CODFILIAL,2),cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 
		
			TRC->(dbSkip())

		ENDDO
		
		TRC->(dbCloseArea())
    		
    ELSE //caso a tabela não esteja vazia
    	TRC->(dbCloseArea())
    ENDIF
    		
Return(NIL)

Static Function CargaMotDimep()

	VEmpresaDimep(cFilMot,cCcMot)

	// *** Inicio Verifica se existe o CAMINHONEIRO na tabela *** //
    SqlVFuncDimep(nMatMot,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
    		
    IF TRC->(EOF()) == .T. 
    		
    	VEmpresaDimep(cFilMot,cCcMot)
    		
    	// *** Inicio Verifica se existe a credencial na tabela *** //
    	SqlVCredencialDimep(nCredMot)
    	IF TRF->(EOF()) 
    		INTCREDMOTORISTA(nCredMot,nEstOrgEmpresa,'3')
   		ELSE
			nCredencial := TRF->CD_CREDENCIAL   
			nRep        := TRF->CD_CREDENCIAL   
   		ENDIF
    	TRF->(dbCloseArea())
    		
    	// *** INICIO CARREGA CODIGO CREDENCIAL *** //
    	IF nCredencial == 0 .AND. nRep == 0
    		SqlVCredencialDimep(nCredMot)
    		IF TRF->(!EOF()) 
				nCredencial := TRF->CD_CREDENCIAL   
				nRep        := TRF->CD_CREDENCIAL   
   			ENDIF
    		TRF->(dbCloseArea())
    	ENDIF
    	TRC->(dbCloseArea())
    	
    	// Pega o Perfil de Acesso Correto
    	SqlPerAc('102999')
    	IF TRP->(!EOF()) 
    		nPerfilAcesso := TRP->CD_PERFIL_ACESSO   
    	ENDIF
    	TRP->(dbCloseArea())
    	
    	// Integra USuario Sistema Credencial
    	INTUSUSISCREDENCIAL(nCredencial) 
    	
    	// Integra PESSOA
    	INTPESSOA(nMatMot,cNomeMot,nSitFol,nEstOrganizacional,nEstOrgEmpres,cCpfMot,cRgMot,'0',nPerfilAcesso,'NULL',nCredencial, cPasPorMot)
    		                                     
    	// Verifica o numero do CAMINHONEIRO
    	SqlVFuncDimep(nMatMot,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))

		While TRC->(!EOF()) 
					
			//Integra Credencial X Pessoa
			INTCREPESSOA(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin)
	
			//Integra Historico da Pessoa
			INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
	
			// Integra USuario Sistema PESSOA
			INTUSUSISPESSOA(TRC->CD_PESSOA)   
			
			// *** INICIO GERA LOG *** //              
			cTexto := '3 Log Cam'                                                                                                            + ';' + ;
						' Fil: '            + '02'                                                                                           + ';' + ;
						' Mat: '            + cValtochar(nMatMot)                                                                                  + ';' + ;
						' Nome: '           + cNomeMot                                                                                       + ';' + ;
						' Folha: '          + CVALTOCHAR(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
						' Credencial: '     + CVALTOCHAR(nCredMot)                                                                           + ';' + ;
						' Sit Mult: '       + IIF(nSitFolMult = 13,CVALTOCHAR(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
						' Turno:'           + '102999'                                                                                       + ';' + ;
						' lCamIntegrar: '   + TRANSFORM(lCamIntegrar,"@!")                                                                   + ';' + ;
						' lCamSitFolha: '   + TRANSFORM(lCamSitFolha,"@!")                                                                   + ';' + ;
						' lCamCredencial: ' + TRANSFORM(lCamCredencial,"@!")
						
			GERALOG(cFilMot,cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
		
			TRC->(dbSkip())

		ENDDO

    	TRC->(dbCloseArea())
    		
    ELSE //caso a tabela não esteja vazia
    	
    	TRC->(dbCloseArea())
    			
    ENDIF
    		
Return(NIL)

STATIC FUNCTION ALTERFUNCDIMEP() 

	// *** INICIO ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //
	cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth)
	VEmpresaDimep(cFilFunc,cNu_Estrutura)
	
	SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
    IF TRC->(!EOF()) 
        
        // *** INICIO ALTERACAO CADASTRAL *** //
		IF lFuncIntegrar == .T. 
		
			IF ALLTRIM(cCcFuncDimep) <> ALLTRIM(TRB->NROCENCUSTOCONT)
			
				VEmpresaDimep(cFilFunc,cCcFunc)
				UPDPESSOA('CD_ESTRUTURA_ORG_EMPRESA',CVALTOCHAR(nEstOrgEmpresa),nMatProth,TRC->CD_ESTRUTURA_ORG_EMPRESA,nEstOrgEmpresa)
				UPDPESSOA('CD_ESTRUTURA_ORGANIZACIONAL',CVALTOCHAR(nEstOrganizacional),nMatProth,TRC->CD_ESTRORG,nEstOrgEmpresa)
				cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth)
			    VEmpresaDimep(cFilFunc,cNu_Estrutura)
			    
			ENDIF
			
			IF SUBSTR(TRC->NM_PESSOA,1,30) <> SUBSTR(TRB->NOME,1,30)
				UPDPESSOA('NM_PESSOA',TRB->NOME,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			
			IF VAL(TRC->NU_CPF) <> VAL(TRB->CPF)
				UPDPESSOA('NU_CPF',TRB->CPF,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			
			IF VAL(TRC->NU_RG) <> VAL(TRB->CARTIDENTIDADE)
				UPDPESSOA('NU_RG',TRB->CARTIDENTIDADE,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			
			IF VAL(TRC->NU_PIS) <> VAL(TRB->PISPASEP)
				UPDPESSOA('NU_PIS',TRB->PISPASEP,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			
			IF ALLTRIM(cNomecPerfil) <> ALLTRIM(CcodTurno)

				IF ALLTRIM(cNomecPerfil) == ALLTRIM(TRC->TX_CAMPO08)

					//NÃO FAZ NADA FOI ALTERADO PARA O PERFIL ESPECIFICO

				ELSE
			
					// Pega o Perfil de Acesso Correto
					SqlPerAc(cCodTurno)
					IF TRP->(!EOF())
						UPDPESS2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,nCdPessoa) 
						UPDPESS2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,nCdPessoa)
					ENDIF
					TRP->(dbCloseArea())

				ENDIF	

			ENDIF

			IF cEmpDimep <> cEmpAnt

				//Ajusta Centro de Custo do Funcionario
				VEmpresaDimep(cFilFunc,cCcFunc)
				UPDPESSOA('CD_ESTRUTURA_ORG_EMPRESA',CVALTOCHAR(nEstOrgEmpresa),nMatProth,TRC->CD_ESTRUTURA_ORG_EMPRESA,nEstOrgEmpresa)
				UPDPESSOA('CD_ESTRUTURA_ORGANIZACIONAL',CVALTOCHAR(nEstOrganizacional),nMatProth,TRC->CD_ESTRORG,nEstOrgEmpresa)
				cNu_Estrutura := BuscaEstrutura(cFilFunc,nMatProth)
			    VEmpresaDimep(cFilFunc,cNu_Estrutura)

			ENDIF
			
		ENDIF // lFuncIntegrar == .T. 
		
		// *** FINAL ALTERACAO CADASTRAL *** //
		
		// *** INICIO SITUACAO FOLHA *** //
		IF lFuncSitFolha == .T.
		
		    // *** Inicio Quando Status Trabalhando *** //
			IF TRC->CD_SITUACAO_PESSOA ==  11  //trabalhando
		                         
		        // *** Inicio TrabalhandoXDemitido *** //
				IF nSitFol == 12 
				    
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF
				
				// *** Inicio TrabalhandoXAfastado ou TrabalhandoXFerias *** //
				IF nSitFol == 13  
				    
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integrar situação de pessoa multipla
					INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,nSitFolMult,cDataIni,cDataFin)	
				    
					//Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF

			ENDIF
			
			// *** Inicio Quando Status Ausencia *** //
			IF TRC->CD_SITUACAO_PESSOA ==  13  //Ausencia
		                         
		        // *** Inicio AusenciaXTrabalhando *** //
				IF nSitFol == 11 
				                                                     
				    //Deleta Pessoa Multipla
					DELSITPESSOAMULTIPLA(CVALTOCHAR(TRC->CD_PESSOA)) 
					
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF

				// *** Inicio AusenciaXDemitido *** //
				IF nSitFol == 12 .or. nSitFol == 23 // @history ticket  14991  - Fernando Macieir- 15/06/2021 - Dimep - Contrato de Trabalho Suspenso
                                    
				    //Deleta Pessoa Multipla
					DELSITPESSOAMULTIPLA(CVALTOCHAR(TRC->CD_PESSOA)) 
					
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF
				
				// *** Inicio AusenciaXAAfastado ou AusenciaXFerias *** //
				IF nSitFol == 13 
				
					//Deleta Pessoa Multipla
					DELSITPESSOAMULTIPLA(CVALTOCHAR(TRC->CD_PESSOA)) 
				    
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integrar situação de pessoa multipla
					INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,nSitFolMult,cDataIni,cDataFin)	
				    
					//Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF

			ENDIF

		ENDIF
		
		// *** INICIO CREDENCIAL *** //
		IF lFuncCredencial == .T.

			nCont1 := 0		     
			SqlTodaCredencial(TRC->CD_PESSOA)
			While TSA->(!EOF())
				
				SqlBuscaCredencialDimep(TSA->CD_CREDENCIAL)
		   		IF TRU->(!EOF()) 

					IF VAL(TRB->CHAPA)    <> TRU->NU_CREDENCIAL .OR. ;
						Val(TRB->PTOCREDENCIAL) <> TRU->NU_CREDENCIAL // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
		   		             
		   		        // QUANDO O CRACHA TA DIFERENTE DA CREDENCIAL
		   				IF VAL(TRB->CHAPA) <> TRU->NU_CREDENCIAL .AND. ;
		   				   LEN(TRB->CHAPA) == LEN(ALLTRIM(CVALTOCHAR(TRU->NU_CREDENCIAL)))
		   				    
		   					DELCREDPESSOA(CVALTOCHAR(TRU->CD_CREDENCIAL))
					   		DELUSUSISCREDENCIAL(CVALTOCHAR(TRU->CD_CREDENCIAL))
					   		
					   		INTCREDENCIAL(TRB->CHAPA,nEstOrgEmpresa,'1')
					    
						    SqlVCredencialDimep(TRB->CHAPA)
					   		IF TRF->(!EOF()) 
					    				
					   			nCredencial := TRF->CD_CREDENCIAL   
					   			nRep        := TRF->CD_CREDENCIAL   
					   			
					   		ENDIF
					    	TRF->(dbCloseArea())
						    
						    INTUSUSISCREDENCIAL(nCredencial)
							INTCREPESSOA(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
							//ALTERA SITUACAO DA FOLHA
						    //UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
						    UPDPESS1('CD_CREDENCIAL_REP',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							DELCREDENCIAL(CVALTOCHAR(TRU->CD_CREDENCIAL))	
							
						ENDIF   
		   		             
						// QUANDO A CREDENCIAL DO FUNCIONARIO TA DIFERENTE DA CREDENCIAL DIMEP
						IF Val(TRB->PTOCREDENCIAL)      <> TRU->NU_CREDENCIAL .AND. ;
							VAL(SUBSTR(TRB->CHAPA,3,6)) <> TRU->NU_CREDENCIAL

							DELCREDPESSOA(CVALTOCHAR(TRU->CD_CREDENCIAL))
							DELUSUSISCREDENCIAL(CVALTOCHAR(TRU->CD_CREDENCIAL))
							
							//INTCREDENCIAL(TRB->PTOCREDENCIAL,nEstOrgEmpresa,'3')
							INTCREDENCIAL(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
						
							//SqlVCredencialDimep(TRB->PTOCREDENCIAL)
							SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
							IF TRF->(!EOF()) 
										
								nCredencial := TRF->CD_CREDENCIAL   
								nRep        := TRF->CD_CREDENCIAL   
								
							ENDIF
							TRF->(dbCloseArea())
							
							INTUSUSISCREDENCIAL(nCredencial)
							INTCREPESSOA(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
							//ALTERA SITUACAO DA FOLHA
							UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
						
						ENDIF
					ENDIF

					// *** Inicio Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** //
					IF nMatProth == TRU->NU_CREDENCIAL

						SqlVCredencialDimep(nMatProth)
				   		IF TRF->(!EOF()) 
				   		
				   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
				   			While TRT->(!EOF()) 
				   				
				   				IF TRT->DT_FIM <> CTOD("  /  /  ") 	//so entra se a data fim tiver valor  
				   				
					   				IF TRF->NU_CREDENCIAL == nMatProth .AND. ;
					   				   TRT->DT_FIM         < DATE()    .AND. ;
					   				   nSitFol            == 11 //trabalhando
						   		
							   			UPDCREDPES("DT_FIM",TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
							   			UPDPESS1('CD_CREDENCIAL_REP',TRF->CD_CREDENCIAL,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							   			
								    ENDIF          
							    ENDIF
							    TRT->(dbSkip())
							ENDDO
							TRT->(dbCloseArea()) 
				   		ENDIF
				    	TRF->(dbCloseArea()) 
				    ENDIF	
					
				    //IF TRB->PTOCREDENCIAL == TRU->NU_CREDENCIAL
					IF Val(TRB->PTOCREDENCIAL) == TRU->NU_CREDENCIAL // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
				    	
				    	SqlVCredencialDimep(nCredFunc)
				   		IF TRF->(!EOF()) 
				   		
				   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
				   			While TRT->(!EOF()) 
				   				
				   				IF TRT->DT_FIM <> CTOD("  /  /  ") 	//so entra se a data fim tiver valor  
				   				
					   				IF TRF->NU_CREDENCIAL <> nMatProth .AND. ;
					   				   TRT->DT_FIM         < DATE()    .AND. ;
					   				   nSitFol            == 11 //trabalhando
						   		
							   			UPDCREDPES("DT_FIM",TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
							   			UPDPESS1('CD_CREDENCIAL_FACE',TRF->CD_CREDENCIAL,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							   			
								    ENDIF          
							    ENDIF
							    TRT->(dbSkip())
							ENDDO
							TRT->(dbCloseArea()) 
				   		ENDIF
				    	TRF->(dbCloseArea()) 
				    ENDIF	
				    // *** Final Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** // 
				ENDIF
		    	TRU->(dbCloseArea()) 
		    	nCont1 := nCont1 + 1 
		    	TSA->(dbSkip())	
			ENDDO
	    	TSA->(dbCloseArea()) 
	    	    
	    	// *** INICIO QUANDO VAI ADICIONAR O SEGUNDO CARTAO QUE SO TEM O DA MATRICULA *** //
	    	IF (nCont1 == 0 .OR.; 
			   nCont1  == 1) .AND. ;
			   LEN(ALLTRIM(CVALTOCHAR(Val(TRB->PTOCREDENCIAL)))) > 6
	    	
	    	    //SIGNIFICA QUE SO TEM A CREDENCIAL DE MATRICULA
	    	    //ADICIONANDO A CREDENCIAL DE NUMERO DE FABRICACAO
	    	    
	    		//INTCREDENCIAL(TRB->PTOCREDENCIAL,nEstOrgEmpresa,'3')
				INTCREDENCIAL(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // ticket 13791 - FWNM - 11/05/2021
					    
			    //SqlVCredencialDimep(TRB->PTOCREDENCIAL)
				SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // ticket 13791 - FWNM - 11/05/2021
		   		IF TRF->(!EOF()) 
		    				
		   			nCredencial := TRF->CD_CREDENCIAL   
		   			nRep        := TRF->CD_CREDENCIAL   
		   			
		   		ENDIF
		    	TRF->(dbCloseArea())
			    
			    INTUSUSISCREDENCIAL(nCredencial)
				INTCREPESSOA(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
				UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			    
			ENDIF 
		
		ENDIF //lFuncCredencial == .T.

		// fwnm - ticket 17021 - 19/07/2021

		//Integra Credencial 
    	nCredencial := 0
		nRep        := 0
		SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // Credencial = 10 digitos = PTOCREDENCIAL = Tecnologia 3 = Proximidade
   		If TRF->( EOF() )
			IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') 
			// apos inclusao
			TRF->(dbCloseArea())
			SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // Credencial = 10 digitos = PTOCREDENCIAL = Tecnologia 3 = Proximidade
			If TRF->( !EOF() )
				nCredencial := TRF->CD_CREDENCIAL   
			EndIf
		Else
   			nCredencial := TRF->CD_CREDENCIAL   
		EndIf
		TRF->(dbCloseArea())

		SqlVCredencialDimep(Val(SUBSTR(TRB->CHAPA,3,6))) // Chapa = 5 digitos = REP = Tecnologia 1 = Código Barras
   		If TRF->( EOF() )
	    	IntCredencial(Val(SUBSTR(TRB->CHAPA,3,6)),nEstOrgEmpresa,'1')
			// Após inclusão
			TRF->(dbCloseArea())
			SqlVCredencialDimep(Val(SUBSTR(TRB->CHAPA,3,6))) // Chapa = 5 digitos = REP = Tecnologia 1 = Código Barras
			If TRF->( !EOF() )
				nRep        := TRF->CD_CREDENCIAL   
			EndIf
		Else
   			nRep        := TRF->CD_CREDENCIAL   
	    EndIf	
    	TRF->(dbCloseArea())

		//Integra Credencial e Credencial X Pessoa
		If nRep <> nCredencial
			lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, Val(TRB->PTOCREDENCIAL))
			If lTpTecno3
				INTCREPESSOA(TRC->CD_PESSOA,nCredencial,"","","3") // enviar 3 = tipo tecnologia // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf

			lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)))
			If lTpTecno1
				INTCREPESSOA(TRC->CD_PESSOA,nRep,"","","1") // enviar 1 = tipo tecnologia  // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UPDPESS1('CD_CREDENCIAL_REP',nRep,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
		EndIf
		// 

		///////
		
		// *** INICIO GERA LOG *** //
		cTexto := '4 Log Func:'                                                                                                        + ';' + ;
			      ' Fil: '             + STRZERO(TRB->CODFILIAL,2)                                                                                + ';' + ;
				  ' Mat: '             + TRB->CHAPA                                                                                   + ';' + ;
				  ' Nome: '            + TRB->NOME                                                                                  + ';' + ;
				  ' Folha: '           + CVALTOCHAR(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Aus'))        + ';' + ;
				  ' Credencial: '      + CVALTOCHAR(nCredFunc)                                                                       + ';' + ;
				  ' Sit Mult: '        + IIF(nSitFolMult = 13,CVALTOCHAR(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Fer','Afas'), '') + ';' + ;
				  ' Turno:'            + CcodTurno                                                                                     + ';' + ;
				  ' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                 + ';' + ;
				  ' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                 + ';' + ;
				  ' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
		
		GERALOG(STRZERO(TRB->CODFILIAL,2), cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
		// *** FINAL GERA LOG *** // 
		
		// *** FINAL CREDENCIAL *** //
	ENDIF
    TRC->(dbCloseArea())     
    	    
    // *** FINAL ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //    	     
RETURN(NIL)

STATIC FUNCTION AlterCamDimep()

	// *** INICIO ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //
	VEmpresaDimep(cFilMot,cCcMot)
	
	SqlVFuncDimep(nMatMot,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
    IF TRC->(!EOF()) 
        
        // *** INICIO ALTERACAO CADASTRAL *** //
		IF lCamIntegrar == .T. 
			
			IF !(ALLTRIM(TRC->NM_PESSOA) == ALLTRIM(cNomeMot))
				UPDPESSOA('NM_PESSOA',cNomeMot,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			//@history 66187 - LEONARDO P. MONTEIRO - Implementa��o da integra��o de motoristas estrangeiros que utilizam passaporte ao inv�s do CPF como identifica��o.
			IF !(ALLTRIM(TRC->TX_CAMPO05)  == ALLTRIM(cPasPorMot))
				UPDPESSOA('TX_CAMPO05',cPasPorMot,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF

			IF ALLTRIM(TRC->NU_CPF)    <> ALLTRIM(cCPFMot)
				UPDPESSOA('NU_CPF',cCpfMot,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			
			IF ALLTRIM(TRC->NU_RG)     <> ALLTRIM(cRgMot)
				UPDPESSOA('NU_RG',cRgMot,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF

			// @history Ticket 16699 - Fernando Macieir- 28/07/2021 - DIVERGENCIA NO CC NO DIMEP - CAMINHONEIROS
			IF TRC->CD_ESTRORG <> nEstOrganizacional
				UPDPESSOA('CD_ESTRUTURA_ORGANIZACIONAL',AllTrim(Str(nEstOrganizacional)),nMatMot,nEstOrganizacional,nEstOrgEmpresa)
			ENDIF
			//

		ENDIF 
		
		// *** INICIO SITUACAO FOLHA *** //
		IF lCamSitFolha == .T.
		
		    // *** Inicio Quando Status Trabalhando *** //
			IF TRC->CD_SITUACAO_PESSOA ==  11  //trabalhando
		                         
		        // *** Inicio TrabalhandoXDemitido *** //
				IF nSitFol == 12 
				    
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF
				// *** Final TrabalhandoXDemitido *** //
			ENDIF
			// *** Final Quando Status Trabalhando *** //
			
			// *** Inicio Quando Status Demitido *** //
			IF TRC->CD_SITUACAO_PESSOA ==  12  //Demitido
		                         
		        // *** Inicio DemitidoXTrabalhando *** //
				IF nSitFol == 11 
				    
				    //ALTERA SITUACAO DA FOLHA
				    UPDPESS1('CD_SITUACAO_PESSOA',nSitFol,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
				    
				    //Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
				
				ENDIF

			ENDIF

		ENDIF 
		
		// *** INICIO CREDENCIAL *** //
		IF lCamCredencial == .T. 
		
			SqlBuscaCredencialDimep(TRC->CD_CREDENCIAL_FACE)
	   		IF TRU->(!EOF()) 
	   		
	   			SqlCredPessoa(TRU->CD_CREDENCIAL,TRC->CD_PESSOA)
		   		IF TRT->(!EOF()) 
		   		
		   		DELCREDPESSOA(CVALTOCHAR(TRC->CD_CREDENCIAL_FACE))
		   		DELUSUSISCREDENCIAL(CVALTOCHAR(TRC->CD_CREDENCIAL_FACE))
				
				
				ENDIF            
				TRT->(dbCloseArea()) 
	   		ENDIF
	    	TRU->(dbCloseArea()) 
	    	
		    INTCREDMOTORISTA(nCredMot,nEstOrgEmpresa,'3')
		    
		    SqlVCredencialDimep(nCredMot)
	   		IF TRF->(!EOF()) 
	    				
	   			nCredencial := TRF->CD_CREDENCIAL   
	   			nRep        := TRF->CD_CREDENCIAL   
	   			
	   		ENDIF
	    	TRF->(dbCloseArea())
		    
		    INTUSUSISCREDENCIAL(nCredencial)
			INTCREPESSOA(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
			//ALTERA SITUACAO DA FOLHA
			UPDPESS1('CD_CREDENCIAL_FACE',nCredencial,nMatMot,nEstOrganizacional,nEstOrgEmpresa)
		    
		ENDIF //lCamCredencial == .T.
		
		// *** FINAL CREDENCIAL *** //
		
		// *** INICIO GERA LOG *** //              
		cTexto := '5 Log Cam'                                                                                                          + ';' + ;
	              ' Fil: '            + '02'                                                                                           + ';' + ;
	              ' Mat: '            + cValtochar(nMatMot)                                                                                        + ';' + ;
	              ' Nome: '           + cNomeMot                                                                                       + ';' + ;
	              ' Folha: '          + CVALTOCHAR(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
			      ' Credencial: '     + CVALTOCHAR(nCredMot)                                                                           + ';' + ;
			      ' Sit Mult: '       + IIF(nSitFolMult = 13,CVALTOCHAR(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
			      ' Turno:'           + '102999'                                                                                          + ';' + ;
			      ' lCamIntegrar: '   + TRANSFORM(lCamIntegrar,"@!")                                                                   + ';' + ;
			      ' lCamSitFolha: '   + TRANSFORM(lCamSitFolha,"@!")                                                                   + ';' + ;
			      ' lCamCredencial: ' + TRANSFORM(lCamCredencial,"@!")
			    
	    GERALOG(cFilMot,cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
		// *** FINAL GERA LOG *** // 	
		
		
	ENDIF
    TRC->(dbCloseArea())     
    	    
    // *** FINAL ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //    	     
RETURN(NIL)  

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE067P" 
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL)
     
STATIC FUNCTION VEmpresaDimep(cFil,cCC)

// *** INICIO VERIFICA ESTRUTURA ORGANZACIONAL DO DIMEP *** //
    SqlVEmpresaDimep(CEMPANT)
    		
    IF TRI->(!EOF()) 
    			
    	nEstOrgEmpresa := TRI->ESTRUTURA
    				
    ENDIF
    TRI->(dbCloseArea())
    		 
    IF nEstOrgEmpresa > 0   
    
    	SqlVFilialDimep(nEstOrgEmpresa, cFil)
    		
    	IF TRZ->(!EOF()) 
    			
    		SqlVDepartamentoDimep(TRZ->ESTRUTURA, cCc)
    		
	    	IF TRJ->(!EOF()) 
	    			
	    		nEstOrganizacional := TRJ->ESTRUTURA
	    		nEstRelacionada    := TRJ->CD_ESTRUTURA_RELACIONADA
	    		
	    			
	    	ENDIF
	    	TRJ->(dbCloseArea())
    				
    	ENDIF
    	TRZ->(dbCloseArea())
    		
    ENDIF
    		
    // *** FINAL VERIFICA ESTRUTURA ORGANZACIONAL DO DIMEP *** //  
    
RETURN(NIL)            

STATIC FUNCTION DimepBloqTerceiro()

	Local dVenccAso       := NIL
	Local dVencIntegracao := NIL
	Local dVencContrato   := NIL
	
	SqlBloqTerceiro()           
	While TSB->(!EOF())
	
		dVenccAso       := STOD(STRTRAN(SUBSTR(TSB->TX_CAMPO01,1,10),'-',''))
		dVencIntegracao := STOD(STRTRAN(SUBSTR(TSB->TX_CAMPO02,1,10),'-',''))
		dVencContrato   := STOD(STRTRAN(SUBSTR(TSB->TX_CAMPO03,1,10),'-',''))
	    
	    IF DTOC(dVenccAso) <> "  /  /  " .AND. dVenccAso < DATE()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UPDPESS1('CD_SITUACAO_PESSOA',16,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		                                                       
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,16,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '7 Log DimepBloqTerceiro Aso:'                       + ';' + ;
		              ' Mat: '             + CVALTOCHAR(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + ALLTRIM(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DTOC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DTOC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DTOC(dVencContrato)           + ';' 
				      
			GERALOG('02',cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    ENDIF
	    
	    IF DTOC(dVencIntegracao) <> "  /  /  " .AND. dVencIntegracao < DATE()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UPDPESS1('CD_SITUACAO_PESSOA',17,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		    
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,17,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '8 Log DimepBloqTerceiro Integracao:'                + ';' + ;
		              ' Mat: '             + CVALTOCHAR(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + ALLTRIM(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DTOC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DTOC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DTOC(dVencContrato)           + ';' 
				      
			GERALOG('02',cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    ENDIF
	    
	    IF DTOC(dVencContrato) <> "  /  /  " .AND. dVencContrato < DATE()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UPDPESS1('CD_SITUACAO_PESSOA',18,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		    
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,18,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '9 Log DimepBloqTerceiro Contrato:'                  + ';' + ;
		              ' Mat: '             + CVALTOCHAR(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + ALLTRIM(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DTOC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DTOC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DTOC(dVencContrato)           + ';' 
				      
			GERALOG('02',cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    ENDIF
	    	    
	    TSB->(dbSkip())	
	ENDDO
	TSB->(dbCloseArea())

RETURN(NIL)

STATIC FUNCTION DimepBloqCaminhoneiro()

	Local dDtVlCNH 		:= ''
	Local nMatMot		:= 0

	cDtVlCNH := DTOS(DATE() - 1)
	SqlCaminhoneiro(cDtVlCNH)           
	While TRK->(!EOF())

		if Empty(TRK->ZVC_CPF)
			nMatMot	:= VAL(TRK->ZVC_PASPOR)
		ELSE
			nMatMot	:= VAL(TRK->ZVC_CPF)
		ENDIF

		SqlVFuncDimep(nMatMot,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
		While TRC->(!EOF())
	
			dDtVlCNH := STOD(TRK->ZVC_CNHVCT)
			
			IF DTOC(dDtVlCNH) <> "  /  /  " .AND. dDtVlCNH < DATE()
			
				IF TRC->CD_SITUACAO_PESSOA <> 22

					//ALTERA SITUACAO DA FOLHA
					UPDPESS1('CD_SITUACAO_PESSOA',22,VAL(TRK->ZVC_CPF),nEstOrganizacional,nEstOrgEmpresa)
																	
					//Integra Historico da Pessoa
					INTHISTSITPESSOA(TRC->CD_PESSOA,22,cDataIni,cDataFin)
					
					// *** INICIO GERA LOG *** //              
					cTexto := '10 Log DimepBloqCaminhoneiro Vencimento Carteira:' + ';' + ;
							' Mat: '             + CValToChar(nMatMot)                 + ';' + ;
							' Nome: '            + ALLTRIM(TRK->ZVC_MOTORI)     + ';' + ;
							' dDtVlCNH: '       + DTOC(dDtVlCNH)                
							
					GERALOG('02',cTexto,'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
					// *** FINAL GERA LOG *** // 

				ENDIF
			ENDIF
			TRC->(dbSkip())	
		ENDDO
		TRC->(dbCloseArea())
	    	    
	    TRK->(dbSkip())	
	ENDDO
	TRK->(dbCloseArea())

RETURN(NIL)

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := '08:15:00'
	Local cHoraSegunda := '08:45:00'
	Local nTotVezes    := 22   
	Local cTempo       := '30'
	Local cHoraProx    := '' 
	Local dDtProx      := dDataBase
	                          
	IF cStatus == '1' //se status igual a 1 inicio
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE067P')) //procura o registro
	        // se achou faz o calculo
			nQuantAtual := ZBN->ZBN_QTDVEZ + 1
			
			IF nQuantAtual <> nTotVezes // verifica as quantidades de tempo
			    // se for diferente faz uma conta
				dDtProx     := dDataBase
				
				IF nQuantAtual == 1
				    //se for a primeira vez ve pela hora inicial
					cHoraProx   := cHoraSegunda
				
				ELSE
					//se for a segunda em diante vez ve pela hora proxima
					cHoraProx   := CVALTOCHAR(SomaHoras( ZBN->ZBN_HORAPR , '00:' + cTempo))
					cHoraProx   := IIF(LEN(SUBSTR(cHoraProx, At(".", cHoraProx) + 1, LEN(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
					cHoraProx   := STRTRAN(cHoraProx,'.',':') + ':00'
				
				ENDIF
				IF At(":", cHoraProx) == 2 //significa que a hora e menor que meio dia vamos acrescentar um zero a esquerda
				
					cHoraProx   := '0' + cHoraProx
									
				ENDIF
			
			ELSE                               
			    // se for igual grava o proximo dia
			    nQuantAtual := 1
				dDtProx     := dDataBase + 1
				cHoraProx   := cHoraIni
			
			ENDIF
			
	    ELSE 
	                 
	        // se nao achou e pq e a primeira vez do dia que esta rodando
	    	nQuantAtual := 1         
	    	dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
	    
	    ENDIF                       
	    ZBN->(dbCloseArea())
	    
	ELSE // se o status for igual a 2          
	    
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE067P'))
		    // se achou grava o que ja esta calculado
			nQuantAtual := ZBN->ZBN_QTDVEZ
			dDtProx     := ZBN->ZBN_DATAPR
			cHoraProx   := ZBN->ZBN_HORAPR
			
		ELSE
		    // se nao achou grava a segunda vez
			nQuantAtual := 1
			dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
			
		ENDIF                       
	    ZBN->(dbCloseArea())	
	
	ENDIF
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE067P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE067P'
			ZBN_DESCRI  := 'Integração PROTHEUS X DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 22 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:15:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE067P'
			ZBN_DESCRI  := 'Integração PROTHEUS X DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 22 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:15:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

Static Function BuscaEstrutura(cFilFunc,nMatricula)

	Local cRet := ''
	
	SqlVEmpresaDimep(CEMPANT)
    		
    IF TRI->(!EOF()) 
    			
    	nEstOrgEmpresa := TRI->ESTRUTURA   
    				
    ENDIF
    TRI->(dbCloseArea())
    		 
    IF nEstOrgEmpresa > 0   
    
    	SqlVFilialDimep(nEstOrgEmpresa, cFilFunc)
    		
    	IF TRZ->(!EOF()) 
    	
    		SqlVEstrutura(TRZ->ESTRUTURA,nMatricula)
	
			While TSC->(!EOF())
			                  
		        cRet := TSC->NU_ESTRUTURA
		        
		    	TSC->(dbSkip())
			ENDDO
			TSC->(dbCloseArea())
			
			// *** INICIO CHAMADO WILLIAM 03/12/2018 045548 || OS 046717 || RECURSOS || DANIELA || 8436 || INTEGRACAO DIMEP FUN *** //
			IF ALLTRIM(cRet) == ''
			
				SqlVDepartamentoDimep(TRZ->ESTRUTURA, cCcFunc)
    		
		    	IF TRJ->(!EOF()) 
		    			
		    		nEstOrganizacional := TRJ->ESTRUTURA
		    		nEstRelacionada    := TRJ->CD_ESTRUTURA_RELACIONADA
		    		cRet               := TRJ->NU_ESTRUTURA
		    				
		    	ENDIF
		    	TRJ->(dbCloseArea())
			
			ENDIF
			
    			
    	ENDIF
    	TRZ->(dbCloseArea())
    		
    ENDIF
	
RETURN(cRet)

STATIC FUNCTION BUSCACCDIMEP(nMatricula)

	Local cRet := ''

	SqlCCDIMEP(nMatricula)
		
	While TSI->(!EOF())
						
		cRet := TSI->NU_ESTRUTURA
		
		TSI->(dbSkip())
	ENDDO
	TSI->(dbCloseArea())

RETURN(cRet)

STATIC FUNCTION BUSCAEMPDIMEP(cEmpDimep)

	Local cEmpresa   := ''

	SqlEMP1(cEmpDimep)
		
	While TSF->(!EOF())
						
		cEmpresa := ALLTRIM(TSF->NU_ESTRUTURA)
		
		TSF->(dbSkip())
	ENDDO
	TSF->(dbCloseArea())

RETURN(cEmpresa)

Static Function Sqlfuncionario(cEmpresa) 

	TRB := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "				SELECT PFUNC.CODCOLIGADA,
	cQuery += "				PFUNC.CODFILIAL,
	cQuery += "				PFUNC.CODSITUACAO,
	cQuery += "				PFUNC.CHAPA,
	cQuery += "				PFUNC.NOME,
	cQuery += "				PFUNC.DATAADMISSAO,
	cQuery += "				PPESSOA.DTNASCIMENTO,
	cQuery += "				PPESSOA.SEXO,
	cQuery += "				PPESSOA.CPF,
	cQuery += "				PPESSOA.CARTIDENTIDADE,
	cQuery += "				PFUNC.PISPASEP,
	cQuery += "				PFUNC.CODHORARIO,
	cQuery += "				PFUNC.DATADEMISSAO,
	cQuery += "				PSECAO.NROCENCUSTOCONT,
	cQuery += "			 	ISNULL(PFCOMPL.PTOCREDENCIAL,''0'') AS PTOCREDENCIAL " // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.

	cQuery += "				FROM [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK)

	cQuery += "				INNER JOIN [" + cSGBD + "].[DBO].[PPESSOA] AS PPESSOA WITH (NOLOCK)
	cQuery += "				ON PPESSOA.CODIGO                                   = PFUNC.CODPESSOA

	cQuery += "			    INNER JOIN [" + cSGBD + "].[DBO].[PSECAO] AS PSECAO WITH (NOLOCK)
	cQuery += "				ON PSECAO.CODCOLIGADA                               = PFUNC.CODCOLIGADA
	cQuery += "				AND PSECAO.CODIGO                                   = PFUNC.CODSECAO

	cQuery += "				INNER JOIN [" + cSGBD + "].[DBO].[PFCOMPL] AS PFCOMPL WITH (NOLOCK)
	cQuery += "				ON PFCOMPL.CODCOLIGADA                              = PFUNC.CODCOLIGADA
	cQuery += "				AND PFCOMPL.CHAPA                                   = PFUNC.CHAPA
	cQuery += "				AND ISNULL(PFCOMPL.PTOCREDENCIAL,''0'') <> ''0'' "  // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
	
	cQuery += "			    WHERE PFUNC.CODCOLIGADA                             = ''"+cEmpresa+"''
	cQuery += "			    AND PFUNC.CODTIPO                                   <> ''A''
	//cQuery += "				AND PFUNC.CODSITUACAO                               <> ''Z'' // @history ticket   39 - Fernando Macieira - 10/02/2021 - de/para no campo CODSITUACAO
	cQuery += "				AND PFUNC.CODHORARIO                                <> ''A001''
	cQuery += "				AND (PFUNC.DATADEMISSAO                             >= GETDATE() - 7
	cQuery += "				OR  PFUNC.DATADEMISSAO                              IS NULL)
	cQuery += "				AND PFUNC.PISPASEP                                  NOT IN (SELECT TOP(1) PFUNC2.PISPASEP FROM [" + cSGBD + "].[DBO].[PFUNC] PFUNC2 WHERE PFUNC2.PISPASEP = PFUNC.PISPASEP AND PFUNC2.CODCOLIGADA <> PFUNC.CODCOLIGADA AND PFUNC2.CODSITUACAO <> ''D'')

	// => DEBUG inibir
	//cQuery += " AND PPESSOA.CPF IN (''40999310801'',''32016494816'',''31451999860'')
	//cQuery += " AND PPESSOA.CPF=''26642025881''
	// => DEBUG inibir

	cQuery += "			ORDER BY PPESSOA.CPF

	cQuery += " ')

	tcQuery cQuery New Alias TRB
	//

RETURN(NIL)   	  

Static Function SqlVFuncDimep(nMat,cEstOrganizacional,cEstOrgEmpresa,cEstRelacionada)

	BeginSQL Alias "TRC"

			%NoPARSER%

			SELECT TOP(1) CD_PESSOA,
				          NU_MATRICULA,
				          NM_PESSOA,
				          CD_SITUACAO_PESSOA,
				          PESSOA.CD_ESTRUTURA_ORGANIZACIONAL AS CD_ESTRORG,
				          CD_ESTRUTURA_ORG_EMPRESA,
				          NU_CPF,
				          NU_RG,
				          NU_PIS,
				          DS_EMAIL,
				          CD_PERFIL_ACESSO,
				          CD_CREDENCIAL_FACE,
				          CD_CREDENCIAL_REP,
				          TX_CAMPO08,
						  TX_CAMPO05 
				     FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA WITH (NOLOCK)
			       WHERE NU_MATRICULA                          = %EXP:nMat%
						
	EndSQl

RETURN(NIL)   	  

Static Function SqlVSitPessoaDimep(nCdPessoa)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			 SELECT CD_SITUACAO_PESSOA_MULTIPLA,
			        CD_PESSOA,
			        CD_SITUACAO_PESSOA,
			        DT_PERIODO_INICIAL AS DT_INI,
			        DT_PERIODO_FINAL   AS DT_FIN
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[SITUACAO_PESSOA_MULTIPLA]  WITH (NOLOCK)
			  WHERE CD_PESSOA = %EXP:nCdPessoa%
			    AND GETDATE() BETWEEN DT_PERIODO_INICIAL AND DT_PERIODO_FINAL
	EndSQl             
RETURN(NIL)  

Static Function SqlAfastamento(cEmp,cMat)

	TRE := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += " 		SELECT TOP(1) CHAPA,
	cQuery += " 					  TIPO,
	cQuery += " 					  DTINICIO AS DATAINICIO,
	cQuery += " 					  DTFINAL AS DATAFIM
	cQuery += " 				  FROM [" + cSGBD + "].[DBO].[PFHSTAFT] AS PFHSTAFT WITH (NOLOCK)
	cQuery += " 				 WHERE CODCOLIGADA = ''"+cEmp+"'' 
	cQuery += " 				   AND CHAPA       = ''"+cMat+"''
	cQuery += " 				   AND ( CONVERT(VARCHAR(8), GETDATE(), 112) BETWEEN CONVERT(VARCHAR(8), DTINICIO, 112) AND CONVERT(VARCHAR(8), DTFINAL, 112) 
	cQuery += " 				         OR CONVERT(VARCHAR(8), DTFINAL, 112) IS NULL )
	cQuery += " 			  ORDER BY PFHSTAFT.DTINICIO DESC

	cQuery += " ')

	tcQuery cQuery New Alias TRE

RETURN

Static Function SqlFERIAS(cEmp,cMat)

	TRE := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		  SELECT TOP(1) PFUFERIASPER.CHAPA,
	cQuery += "						SITUACAOFERIAS,
	cQuery += "						DATAINICIO,
	cQuery += "						DATAFIM
	cQuery += "					FROM [" + cSGBD + "].[DBO].[PFUFERIASPER] AS PFUFERIASPER WITH (NOLOCK)
	cQuery += "					INNER JOIN [" + cSGBD + "].[DBO].[PFUFERIASRECIBO] AS PFUFERIASRECIBO WITH (NOLOCK)
	cQuery += "							ON PFUFERIASRECIBO.CODCOLIGADA = PFUFERIASPER.CODCOLIGADA
	cQuery += "						   AND PFUFERIASRECIBO.CHAPA       = PFUFERIASPER.CHAPA
	cQuery += "						   AND PFUFERIASRECIBO.DATAPAGTO   = PFUFERIASPER.DATAPAGTO
	cQuery += "					     WHERE PFUFERIASPER.CODCOLIGADA    = ''"+cEmp+"''
	cQuery += "					       AND PFUFERIASPER.CHAPA          = ''"+cMat+"''
	cQuery += "					       AND CONVERT(VARCHAR(8), GETDATE(), 112) BETWEEN CONVERT(VARCHAR(8), DATAINICIO, 112) AND CONVERT(VARCHAR(8), DATAFIM, 112) 
	cQuery += "				ORDER BY PFUFERIASPER.DATAINICIO DESC

	cQuery += " ')

	tcQuery cQuery New Alias TRE

RETURN

Static Function SqlVCredencialDimep(cCredencial)

	BeginSQL Alias "TRF"

			%NoPARSER% 

			 SELECT CD_CREDENCIAL,NU_CREDENCIAL 
			   FROM [DMPACESSO].[DMPACESSOII].[DBO].[CREDENCIAL] WITH (NOLOCK)
			  WHERE NU_CREDENCIAL = %EXP:cCredencial%
			  
	EndSQl             

RETURN(NIL)   

Static Function SqlVTurno(cEmpresa,cMat) 

	TRG := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += " 		SELECT TOP(1) CODCOLIGADA,
	cQuery += " 		  			  CHAPA,
	cQuery += " 					  DTMUDANCA,
	cQuery += " 					  CODHORARIO
	cQuery += " 				 FROM [" + cSGBD + "].[DBO].[PFHSTHOR] AS PFHSTHOR WITH (NOLOCK)
	cQuery += " 				WHERE CODCOLIGADA = ''"+cEmpresa+"''
	cQuery += " 				  AND CHAPA       = ''"+cMat+"''
	cQuery += " 				  AND CODHORARIO <> ''A001''
	cQuery += " 				  ORDER BY DTMUDANCA DESC

	cQuery += " ')

	tcQuery cQuery New Alias TRG

RETURN(NIL) 
            
Static Function SqlVTurnoDimep(nTurno)                          

	BeginSQL Alias "TRH"
			%NoPARSER%   
			SELECT CD_TURNO,NU_TURNO,DS_TURNO,HR_ZERA_QTD_ACESSO
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[TURNO]  WITH (NOLOCK)
             WHERE NU_TURNO = %EXP:nTurno%
			
	EndSQl             
RETURN(NIL) 

Static Function SqlVEmpresaDimep(cEmpresa)  

	//Local cTeste := ''

	BeginSQL Alias "TRI"

			%NoPARSER%  

			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			WHERE NU_ESTRUTURA = %EXP:cEmpresa%
				AND TP_ESTRUTURA = '0'
			    AND NU_CNPJ <> 0
     
	EndSQl             

RETURN(NIL)            

Static Function SqlVDepartamentoDimep(nEstOrganizacional, cFil)

	//Local cTeste:= ''

	BeginSQL Alias "TRJ"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nEstOrganizacional%
			    AND NU_ESTRUTURA             = %EXP:cFil%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)

Static Function SqlCaminhoneiro(cDtVlCNH)                          

	BeginSQL Alias "TRK"
			%NoPARSER%   
			 SELECT   ZVC.ZVC_FILIAL,
			          DA4.DA4_FILIAL,
			          ZVC.ZVC_MOTORI,
					  DA4.DA4_NOME,
				      ZVC.ZVC_RG, 
					  DA4.DA4_RG,
				      ZVC.ZVC_DTNASC,
					  DA4.DA4_DATNAS,
				      ZVC.ZVC_CPF,
					  DA4.DA4_CGC,
				      ZVC.ZVC_MOTBLQ,
					  ZVC.ZVC_XCREDE,
					  DA4.DA4_XCREDE,
					  ZVC.ZVC_CC,
					  DA4.DA4_XCC,
					  ZVC.ZVC_CNHVCT,
					  ZVC.ZVC_PASPOR
			     FROM %Table:ZVC% ZVC WITH (NOLOCK)
			LEFT JOIN %Table:DA4% DA4 WITH (NOLOCK)
			       ON ZVC.ZVC_FILIAL        = DA4.DA4_FILIAL
				  AND ( (ZVC.ZVC_CPF != '' AND ZVC.ZVC_CPF           = DA4.DA4_CGC) )
				  AND DA4.D_E_L_E_T_       <> '*'
			   WHERE  ZVC.ZVC_FILIAL        = ''             // TICKET 2692 - 01/10/2020 - ADRIANO SAVOINE
				  AND ZVC.D_E_L_E_T_       <> '*' 
				  AND (ZVC.ZVC_XCREDE       > 0 
			       OR DA4.DA4_XCREDE        > 0) 
				  AND (LEN(ZVC.ZVC_XCREDE) >= 7 
				   OR LEN(DA4.DA4_XCREDE)  >= 7) 
				  AND (LEN(ZVC.ZVC_CC)      = 4 
				   OR LEN(DA4.DA4_XCC)      = 4)  
				  AND ZVC.ZVC_CNHVCT       <= %EXP:cDtVlCNH%
				  // Degugar motoristas estrangeiros.
				  //AND ZVC.ZVC_CPF =''
				  //and ZVC.ZVC_CPF='38489231818' // debug

			ORDER BY ZVC.ZVC_MOTORI
			
	EndSQl             
RETURN(NIL)             

Static Function SqlTurno(cEmpresa)     

	TRL := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		SELECT CODIGO,
	cQuery += "			   DESCRICAO,
	cQuery += "			   HORARIOJOR
	cQuery += "		  FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO WITH (NOLOCK)
	cQuery += "		 WHERE CODCOLIGADA = ''"+cEmpresa+"''
	cQuery += "		   AND INATIVO     = 0
			   
	cQuery += "			ORDER BY CODIGO

	cQuery += " ')

	tcQuery cQuery New Alias TRL

RETURN(NIL)  

Static Function SqlJorRM(cEmpresa,cTurno)    

	TRM := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		 SELECT CODHORARIO,
	cQuery += "				INDINICIO,
	cQuery += "				BATINICIO,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
	cQuery += "				INDFIM,
	cQuery += "				BATFIM,
	cQuery += "				CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN
	cQuery += "			FROM [" + cSGBD + "].[DBO].[AJORHOR] AS AJORHOR WITH (NOLOCK)
	cQuery += "			WHERE CODCOLIGADA = ''"+cEmpresa+"''
	cQuery += "			AND CODHORARIO    = ''"+cTurno+"''

	cQuery += " ')

	tcQuery cQuery New Alias TRM

RETURN(NIL) 

Static Function SqlJORNADA(cTurno)

	BeginSQL Alias "TRO"
			%NoPARSER%  
			SELECT CD_JORNADA,
			       DS_JORNADA,
			       TP_JORNADA,
			       QT_DIAS_PERIODO
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[JORNADA] WITH (NOLOCK) 
		     WHERE DS_JORNADA = %EXP:cTurno%
 			 
 	EndSQl             
RETURN(NIL) 

Static Function SqlPerAc(nTurno)

	BeginSQL Alias "TRP"
			%NoPARSER%  
			SELECT CD_PERFIL_ACESSO,
			       NM_PERFIL_ACESSO,
			       TP_PERFIL_ACESSO,
			       FL_PUBLICO
			 FROM [DMPACESSO].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) 
		    WHERE NM_PERFIL_ACESSO = %EXP:nTurno%
		
 	EndSQl             
RETURN(NIL) 

Static Function SqlGrupoArea(nGrupo)

	Local cWhere := ''
	
	cWhere := '%' + CVALTOCHAR(nGrupo) + '%'

	BeginSQL Alias "TRQ"
			%NoPARSER%  
			SELECT CD_GRUPO,
			       CD_AREA,
			       FL_AREA_ORIGEM
			 FROM [DMPACESSO].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = %EXP:cWhere%
		
 	EndSQl             
RETURN(NIL) 

Static Function SqlTurnoFaixa(nTurno)

	BeginSQL Alias "TRR"
			%NoPARSER%  
			SELECT CD_TURNO,
			       CD_FAIXA_HORARIA
			 FROM [DMPACESSO].[DMPACESSOII].[DBO].[TURNO_FAIXA] WITH (NOLOCK) 
		    WHERE CD_TURNO = %EXP:nTurno%
		
 	EndSQl             
RETURN(NIL) 

Static Function SqlFxHor(cFaixa1,cFaixa2)                          

	BeginSQL Alias "TRS"
			%NoPARSER%  
			SELECT CD_FAIXA_HORARIA,
			       NU_FAIXA_HORARIA,
				   HR_FAIXA_DE,
				   HR_FAIXA_ATE
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[FAIXA_HORARIA] WITH (NOLOCK)
			 WHERE CD_FAIXA_HORARIA = %EXP:cFaixa1%
			   OR  CD_FAIXA_HORARIA = %EXP:cFaixa2%
 			 
 	EndSQl             
RETURN(NIL) 

Static Function SqlCredPessoa(cCredencia,cPessoa)                          

	BeginSQL Alias "TRT"
			%NoPARSER%  
			SELECT CD_CREDENCIAL,
			       CD_PESSOA,
			       DT_INICIO,
			       DT_FIM,
			       FL_PERMANENTE,
			       TP_TECNOLOGIA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[CREDENCIAL_PESSOA] WITH (NOLOCK)
			 WHERE CD_CREDENCIAL = %EXP:cCredencia%
			   AND CD_PESSOA     = %EXP:cPessoa%
 			 
 	EndSQl             
RETURN(NIL)   

Static Function SqlBuscaCredencialDimep(cCredencial)

	BeginSQL Alias "TRU"
			%NoPARSER% 
			 SELECT CD_CREDENCIAL,NU_CREDENCIAL 
			   FROM [DMPACESSO].[DMPACESSOII].[DBO].[CREDENCIAL] WITH (NOLOCK)
			  WHERE CD_CREDENCIAL = %EXP:cCredencial%
			  
	EndSQl             
RETURN(NIL)   

Static Function SqlJorDia(cJornada,cDia,cTurno)

	BeginSQL Alias "TRV"
			%NoPARSER% 
			 SELECT CD_JORNADA_DIA,
			        CD_JORNADA,
				    NU_DIA,
				    CD_TURNO 
			   FROM [DMPACESSO].[DMPACESSOII].[DBO].[JORNADA_DIA] WITH (NOLOCK) 
		      WHERE CD_JORNADA = %EXP:cJornada%
                AND NU_DIA     = %EXP:cDia%
                AND CD_TURNO   = %EXP:cTurno%
			  
			  
	EndSQl             
RETURN(NIL) 

Static Function SqlNomePerAc(nTurno)

	BeginSQL Alias "TRX"
			%NoPARSER%  
			SELECT CD_PERFIL_ACESSO,
			       NM_PERFIL_ACESSO,
			       TP_PERFIL_ACESSO,
			       FL_PUBLICO
			 FROM [DMPACESSO].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) 
		    WHERE CD_PERFIL_ACESSO = %EXP:nTurno%
		
 	EndSQl             
RETURN(NIL)   

Static Function SqlVFilialDimep(nEstOrganizacional, cFil)

	//Local cTeste := ''

	BeginSQL Alias "TRZ"
			%NoPARSER%  
			SELECT CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			       NU_ESTRUTURA,
			       NM_ESTRUTURA,
			       NU_CNPJ,
			       DS_RAZAO_SOCIAL,
			       DS_CEI,
			       CD_ESTRUTURA_RELACIONADA,
			       TP_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nEstOrganizacional%
			    AND NU_ESTRUTURA             = %EXP:cFil%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)

Static Function SqlTodaCredencial(cPessoa)                          

	BeginSQL Alias "TSA"
			%NoPARSER%  
			SELECT CD_CREDENCIAL,
			       CD_PESSOA,
			       DT_INICIO,
			       DT_FIM,
			       FL_PERMANENTE,
			       TP_TECNOLOGIA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[CREDENCIAL_PESSOA] WITH (NOLOCK)
			 WHERE CD_PESSOA     = %EXP:cPessoa%
 			 
 	EndSQl             
RETURN(NIL)   

Static Function SqlBloqTerceiro()

	BeginSQL Alias "TSB"
			%NoPARSER% 
			 SELECT CD_PESSOA,
					NU_MATRICULA,
					NM_PESSOA,
					CD_SITUACAO_PESSOA,
					CD_ESTRUTURA_ORGANIZACIONAL,
					CD_ESTRUTURA_ORG_EMPRESA,
					NU_CPF,
					NU_RG,
					NU_PIS,
					DS_EMAIL,
					CD_PERFIL_ACESSO,
					CD_CREDENCIAL_FACE,
					CD_CREDENCIAL_REP,
					TX_CAMPO01, 
					TX_CAMPO02,
					TX_CAMPO03
			FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] WITH (NOLOCK)
			WHERE CD_SITUACAO_PESSOA  = 11 
			  AND (TX_CAMPO01        <> '' 
			   OR TX_CAMPO02         <> ''
			   OR TX_CAMPO03         <> '')
			  
			  
	EndSQl             
RETURN(NIL)

Static Function SqlVEstrutura(cFilFunc,nMatricula)

	//Local cTeste:= ''

	BeginSQL Alias "TSC"
			%NoPARSER% 
			SELECT ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
			        ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
			WHERE PESSOA.NU_MATRICULA = %EXP:nMatricula%
			  
	EndSQl             
RETURN(NIL) 

Static Function SqlDiaSemanaRM(cEmpresa,cTurno)

	TSD := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery+= " SELECT [COLUNA], [VALOR] "
	cQuery+= "   FROM (SELECT CODIGO, "
	cQuery+= "	   	  (SELECT DATENAME(weekday, DATABASEHOR)    FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA1, "
	cQuery+= "	      (SELECT DATENAME(weekday, DATABASEHOR +1) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA2, "
	cQuery+= "	 	  (SELECT DATENAME(weekday, DATABASEHOR +2) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA3, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +3) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA4, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +4) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA5, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +5) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA6, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +6) FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) WHERE CODCOLIGADA = ''" + cEmpresa + "'' AND CODIGO = ''" + cTurno + "'') AS DIA7 "
	cQuery+= "   FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO (NOLOCK) "
	cQuery+= "  WHERE CODCOLIGADA = ''" + cEmpresa + "'' "
	cQuery+= "	  AND CODIGO      = ''" + cTurno + "'' "
	cQuery+= "		  ) C "
	cQuery+= "	UNPIVOT ([VALOR] FOR [COLUNA] IN ( [DIA1], "
	cQuery+= "		                               [DIA2], "
	cQuery+= "				                       [DIA3], "
	cQuery+= "				                       [DIA4], "
	cQuery+= "				                       [DIA5], "
	cQuery+= "				                       [DIA6], "
	cQuery+= "				                       [DIA7] "
	cQuery+= "			) "
	cQuery+= " ) AS U " 

	cQuery += " ')

	TCQUERY cQuery new alias TSD 

RETURN(NIL) 

Static Function SqlCatracaPortaria()

	BeginSQL Alias "TSE"
			%NoPARSER%  
			SELECT CD_GRUPO,
			       CD_AREA,
			       FL_AREA_ORIGEM
			 FROM [DMPACESSO].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = 8
     	       		
 	EndSQl        

RETURN(NIL)

Static Function SqlEMP1(cEstLoc)

	BeginSQL Alias "TSF"

			%NoPARSER% 
			SELECT NU_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%
			  
	EndSQl             
RETURN(NIL) 

Static Function SqlEMP2(cEstLoc)

	BeginSQL Alias "TSG"

			%NoPARSER% 
			SELECT CD_ESTRUTURA_RELACIONADA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%			
			  
	EndSQl             
RETURN(NIL) 

Static Function SqlEMP3(cEstLoc)

	BeginSQL Alias "TSH"

			%NoPARSER% 
			SELECT NU_ESTRUTURA
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%			
			  
	EndSQl             
RETURN(NIL) 

Static Function SqlCCDIMEP(nMatricula)

	BeginSQL Alias "TSI"

			%NoPARSER% 
			SELECT NU_ESTRUTURA 
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			  INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					  ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
			  WHERE NU_MATRICULA = %EXP:nMatricula%
			  
	EndSQl             
RETURN(NIL) 

Static Function INTPESSOA(nMat,cNome,nSitFol,nGrupo,nEmpresa,cCic,cRg,cPis,nPerfilAcesso,nRep,nCredencial, cPasPor)   
	Default cPasPor	:= ""

    cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += "(NU_MATRICULA, " 
	cQuery += "NM_PESSOA, " 
	cQuery += "CD_SITUACAO_PESSOA, " 
	cQuery += "CD_ESTRUTURA_ORGANIZACIONAL, " 
	cQuery += "CD_ESTRUTURA_ORG_EMPRESA, " 
	cQuery += "NU_CPF, " 
	cQuery += "TX_CAMPO05, " 
	cQuery += "NU_RG, " 
	cQuery += "NU_PIS, "
	cQuery += "CD_PERFIL_ACESSO, "
	cQuery += "CD_CREDENCIAL_REP, " 
	cQuery += "CD_CREDENCIAL_FACE " 
	cQuery += ") "
	cQuery += "VALUES (" + CVALTOCHAR(nMat)          + ","  // Matricula
	cQuery += "'"        + cNome                     + "',"  // Nome Funcionario
	cQuery += ""         + CVALTOCHAR(nSitFol)       + ","  // Situacao da Folha
	cQuery += "'"        + CVALTOCHAR(nGrupo)        + "'," // Grupo Empresa
	cQuery += "'"        + CVALTOCHAR(nEmpresa)      + "'," // Empresa
	
	if Empty(cCic)
		cQuery += "''," 										// Cpf
		cQuery += "'"        + cPasPor                   + "'," // Pasporte
		cQuery += "''," 										// Rg  
		cQuery += "''," 										// Pis  
	else
		cQuery += "'"        + cCic                      + "'," // Cpf
		cQuery += "''," 										// Pasporte
		cQuery += "'"        + cRg                       + "'," // Rg  
		cQuery += "'"        + cPis                      + "'," // Pis  
	endif

	cQuery += "'"        + CVALTOCHAR(nPerfilAcesso) + "'," // Perfil de Acesso 
	cQuery += ""         + CVALTOCHAR(nRep)          + ","  // Cod Rep 
	cQuery += ""         + CVALTOCHAR(nCredencial)   + " "  // Cod Face
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTFUNCIONARIO: "
	EndIf        
	
RETURN(NIL)   	      	 	  

Static Function INTCREDENCIAL(nCred,nEstrutura,cTipo)   

    cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] " 
	cQuery += "(CD_TIPO_CREDENCIAL, " 
	cQuery += "CD_ESTRUTURA_ORGANIZACIONAL, " 
	cQuery += "TP_TECNOLOGIA, " 
	cQuery += "NU_CREDENCIAL, " 
	cQuery += "FL_PERMANENTE, " 
	cQuery += "FL_BLOQUEADA, " 
	cQuery += "TP_MASTER, " 
	cQuery += "FL_REENTRADA, " 
	cQuery += "FL_DISPONIVEL_USO, " 
	cQuery += "FL_DISPENSA_SENHA, " 
	cQuery += "FL_SUPERVISOR_EQUIPAMENTO, " 
	cQuery += "FL_CREDENCIAL_PUBLICA "                                     	
    cQuery += ") "
	cQuery += "VALUES (" + '1'                    + "," // Tipo Credencial
	cQuery += ""         + CVALTOCHAR(nEstrutura) + "," // Estrutura Organizacional
	cQuery += "'"        + cTipo                  + "'," // Tipo Tecnologia
	cQuery += ""         + CVALTOCHAR(nCred)      + "," // Credencial
	cQuery += ""         + '1'                    + "," // Permanente
	cQuery += ""         + '0'                    + "," // Bloqueada	
	cQuery += ""         + '0'                    + "," // Tipo Master
	cQuery += ""         + '0'                    + "," // Reentrada
	cQuery += ""         + '1'                    + "," // Disponivel Uso
	cQuery += ""         + '0'                    + "," // Dispensa Senha
	cQuery += ""         + '0'                    + "," // Supervisor Equipamento
	cQuery += ""         + '0'                    + ""  // Credencial Publica
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() INTCREDENCIAL:"
	EndIf        
	
RETURN(NIL)   	      	 	  

Static Function INTCREDMOTORISTA(nCred,nEstrutura,cTipo)   

    cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] " 
	cQuery += "(CD_TIPO_CREDENCIAL, " 
	cQuery += "CD_ESTRUTURA_ORGANIZACIONAL, " 
	cQuery += "TP_TECNOLOGIA, " 
	cQuery += "NU_CREDENCIAL, " 
	cQuery += "FL_PERMANENTE, " 
	cQuery += "FL_BLOQUEADA, " 
	cQuery += "TP_MASTER, " 
	cQuery += "FL_REENTRADA, " 
	cQuery += "FL_DISPONIVEL_USO, " 
	cQuery += "FL_DISPENSA_SENHA, " 
	cQuery += "FL_SUPERVISOR_EQUIPAMENTO, " 
	cQuery += "FL_CREDENCIAL_PUBLICA "                                     	
    cQuery += ") "
	cQuery += "VALUES (" + '6'                    + "," // Tipo Credencial
	cQuery += ""         + CVALTOCHAR(nEstrutura) + "," // Estrutura Organizacional
	cQuery += "'"        + cTipo                  + "'," // Tipo Tecnologia
	cQuery += ""         + CVALTOCHAR(nCred)      + "," // Credencial
	cQuery += ""         + '1'                    + "," // Permanente
	cQuery += ""         + '0'                    + "," // Bloqueada	
	cQuery += ""         + '0'                    + "," // Tipo Master
	cQuery += ""         + '0'                    + "," // Reentrada
	cQuery += ""         + '1'                    + "," // Disponivel Uso
	cQuery += ""         + '0'                    + "," // Dispensa Senha
	cQuery += ""         + '0'                    + "," // Supervisor Equipamento
	cQuery += ""         + '0'                    + ""  // Credencial Publica
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() INTCREDMOTORISTA:"
	EndIf        
	
RETURN(NIL)

Static Function INTCREPESSOA(nPessoa,nCredencial,cDataIni,cDataFin)

	Local cSql     := ""
	Local cQuery   := ""
	Local cCredenc := ""
	Local cChapa   := ""
	Local cPtoCred := ""

	IF ALLTRIM(cDataIni) == '' .AND. ALLTRIM(cDataFin) == '' 
	   cDataIni    := DTOC(DATE())
	   cDataIni    := IIF(ALLTRIM(cDataIni) <> '',CVALTOCHAR(YEAR(DATE()))+ '-' + Substr(cDataIni,4,2)+ '-' + Substr(cDataIni,1,2) +  "T" + '00:00:00', cDataFin)
 	ENDIF   

	// @history Ticket  17021 - Fernando Macieir- 19/07/2021 - Integração DImep
	If ISINCALLSTACK("DIMEPCAMINHONEIRO")

		cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
		cQuery += "(CD_CREDENCIAL, " 
		cQuery += "CD_PESSOA, " 
		cQuery += "DT_INICIO, " 
		cQuery += "DT_FIM, " 
		cQuery += "FL_PERMANENTE, " 
		cQuery += "TP_TECNOLOGIA " 
		cQuery += ") "
		cQuery += "VALUES (" + CVALTOCHAR(nCredencial)                                          + "," // Credencial
		cQuery += ""         + CVALTOCHAR(nPessoa)                                              + "," // Pessoa
		cQuery += "'"        + CVALTOCHAR(cDataIni)                                             + "'," // Data Inicial
		cQuery += ""        + IIF(ALLTRIM(cDataFin) == '', 'NULL',"'"+CVALTOCHAR(cDataFin)+"'") + "," // Data Fim
		cQuery += ""         + '1'                                                              + "," // Permanente
		cQuery += ""         + '3'                                                              + ""  // Tecnologia	
		cQuery += ") " 

		If (TCSQLExec(cQuery) < 0)
			cIntregou += " TCSQLError() - INTCREPESSOA: "
		EndIf        
	
	Else

		cChapa   := Val(SUBSTR(TRB->CHAPA,3,6)) // TIPO 1
		cPtoCred := Val(TRB->PTOCREDENCIAL)     // TIPO 3

		///////////////////////////////////////
		// SE NÃO EXISTIR NENHUMA AMARRAÇÃO 
		///////////////////////////////////////
		If Select("Work")
			Work->( dbCloseArea() )
		EndIf

		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nKey)+"'
	//	cQuery += " AND AMARRA.TP_TECNOLOGIA='"+CVALTOCHAR(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Codigo Barra
			cTpTecno := 1 

			cCredenc := GetCDCred(cChapa, 1)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + CVALTOCHAR(cCredenc)                                          + "," // Credencial
				cSql += ""         + CVALTOCHAR(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + CVALTOCHAR(cDataIni)                                             + "'," // Data Inicial
				cSql += ""        + IIF(ALLTRIM(cDataFin) == '', 'NULL',"'"+CVALTOCHAR(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + CVALTOCHAR(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSQLExec(cSql) < 0)
					cIntregou += " TCSQLError() - INTCREPESSOA: "
				EndIf

			EndIf
		
			// Proximidade
			cTpTecno := 3 

			cCredenc := GetCDCred(cPtoCred, 3)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + CVALTOCHAR(cCredenc)                                             + "," // Credencial
				cSql += ""         + CVALTOCHAR(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + CVALTOCHAR(cDataIni)                                             + "'," // Data Inicial
				cSql += ""        + IIF(ALLTRIM(cDataFin) == '', 'NULL',"'"+CVALTOCHAR(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + CVALTOCHAR(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSQLExec(cSql) < 0)
					cIntregou += " TCSQLError() - INTCREPESSOA: "
				EndIf

			EndIf

		EndIf

		////////////////////////////////////////////////////////
		// SE NAÕ EXISTIR AMARRAÇÃO TECNOLOGIA 1 = CODIGO BARRA 
		////////////////////////////////////////////////////////
		If Select("Work")
			Work->( dbCloseArea() )
		EndIf

		cTpTecno := 1 // Codigo Barra

		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nKey)+"'
		cQuery += " AND AMARRA.TP_TECNOLOGIA='"+CVALTOCHAR(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Codigo Barra
			cTpTecno := 1 

			cCredenc := GetCDCred(cChapa, 1)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + CVALTOCHAR(cCredenc)                                              + "," // Credencial
				cSql += ""         + CVALTOCHAR(nPessoa)                                               + "," // Pessoa
				cSql += "'"        + CVALTOCHAR(cDataIni)                                              + "'," // Data Inicial
				cSql += ""         + IIF(ALLTRIM(cDataFin) == '', 'NULL',"'"+CVALTOCHAR(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                               + "," // Permanente
				cSql += ""         + CVALTOCHAR(cTpTecno)                                              + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSQLExec(cSql) < 0)
					cIntregou += " TCSQLError() - INTCREPESSOA: "
				EndIf

			EndIf

		EndIf

		/////////////////////////////////////////////////////////
		// SE NAÕ EXISTIR AMARRAÇÃO TECNOLOGIA 3 = APROXIMAÇÃO 
		/////////////////////////////////////////////////////////
		If Select("Work")
			Work->( dbCloseArea() )
		EndIf

		cTpTecno := 3 // Proximidade
		
		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nKey)+"'
		cQuery += " AND AMARRA.TP_TECNOLOGIA='"+CVALTOCHAR(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Proximidade
			cTpTecno := 3

			cCredenc := GetCDCred(cPtoCred, 3)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + CVALTOCHAR(cCredenc)                                             + "," // Credencial
				cSql += ""         + CVALTOCHAR(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + CVALTOCHAR(cDataIni)                                             + "'," // Data Inicial
				cSql += ""         + IIF(ALLTRIM(cDataFin) == '', 'NULL',"'"+CVALTOCHAR(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + CVALTOCHAR(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSQLExec(cSql) < 0)
					cIntregou += " TCSQLError() - INTCREPESSOA: "
				EndIf

			EndIf

		EndIf

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

	EndIf
	
RETURN(NIL)

Static Function INTHISTSITPESSOA(nPessoa,nSitFol,cDataIni,cDataFin)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[HISTORICO_SITUACAO_PESSOA] " 
	cQuery += "(CD_PESSOA, " 
	cQuery += "CD_SITUACAO_PESSOA, " 
	cQuery += "DT_ATRIBUICAO, " 
	cQuery += "DT_SITUACAO_INICIAL, " 
	cQuery += "DT_SITUACAO_FINAL " 
    cQuery += ") "
	cQuery += "VALUES ( " + " '" + CVALTOCHAR(nPessoa)      + "'," // Pessoa
	cQuery += ""                 + CVALTOCHAR(nSitFol)   + "," // Situacao Folha
    cQuery += ""                 + 'GETDATE()'           + "," // Data Atribuicao
    cQuery += "'"                + CVALTOCHAR(cDataIni)  + "'," // Data Inicial
	cQuery += "'"                + CVALTOCHAR(cDataFin)  + "' " // Data Final
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTHISTSITPESSOA: "
	EndIf        
	
RETURN(NIL)   	      	 	  

Static Function INTSITPESSOAMULTIPLA(nPessoa,nSitFolMult,cDataIni,cDataFin)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[SITUACAO_PESSOA_MULTIPLA] " 
	cQuery += "(CD_PESSOA, " 
	cQuery += "CD_SITUACAO_PESSOA, " 
    cQuery += "DT_PERIODO_INICIAL, " 
	cQuery += "DT_PERIODO_FINAL " 
    cQuery += ") "
	cQuery += "VALUES (" + cvaltochar(nPessoa)     + "," // Pessoa
	cQuery += ""         + cvaltochar(nSitFolMult) + "," // Situacao Folha
	cQuery += "'"        + cDataIni                + "'," // Data Inicial
	cQuery += "'"        + cDataFin                + "'" // Data Final
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTSITPESSOAMULTIPLA: "
	EndIf        
	
RETURN(NIL)

Static Function INTUSUSISCREDENCIAL(nCredencial)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_CREDENCIAL] " 
	cQuery += "(CD_CREDENCIAL, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nCredencial) + "'," // Credencial
	cQuery += ""                + '1'                     + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'             + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISCREDENCIAL: " 
	EndIf        
	
RETURN(NIL)

Static Function INTUSUSISPESSOA(nPessoa)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_PESSOA] " 
	cQuery += "(CD_USUARIO, " 
	cQuery += "CD_PESSOA, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + '1'                 + "'," // Usuario Admin
	cQuery += ""                + CVALTOCHAR(nPessoa) + ","  // Pessoa
    cQuery += ""                + 'GETDATE()'         + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISPESSOA: " 
	EndIf        
	
RETURN(NIL) 

Static Function CargaTurnoDimep(nTurno,cDesc)   	      	 	  

	Local cHoraAcesso := "1904-01-01" +  "T" + '00:00:00'

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[TURNO] " 
	cQuery += "(NU_TURNO, " 
	cQuery += "DS_TURNO, " 
    cQuery += "HR_ZERA_QTD_ACESSO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTurno)  + "'," // Cod Turno
	cQuery += "'"               + cDesc               + "',"  // Descrição do Turno
    cQuery += "'"               + cHoraAcesso         + "' "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISPESSOA: "
	EndIf        
	
RETURN(NIL)

Static Function INTUSUSISTURNO(nTurno)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_TURNO] " 
	cQuery += "(CD_TURNO, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTurno)      + "'," // Turno
	cQuery += ""                + '1'                     + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'             + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISTURNO: "
	EndIf        
	
RETURN(NIL) 

Static Function INTTURNOFAIXA(nTurno,nFaixa)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[TURNO_FAIXA] " 
	cQuery += "(CD_TURNO, " 
	cQuery += "CD_FAIXA_HORARIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTurno)      + "'," // Turno
	cQuery += "'"               + CVALTOCHAR(nFaixa)      + "'"  // Faixa
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTTURNOFAIXA: "
	EndIf        
	
RETURN(NIL) 

Static Function INTJORNADA(nTurno)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[JORNADA] " 
	cQuery += "(DS_JORNADA, " 
	cQuery += "TP_JORNADA, " 
	cQuery += "QT_DIAS_PERIODO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTurno) + "'," // DS_JORNADA
	cQuery += "'"               + '1'                + "'," // TP_JORNADA
	cQuery += "'"               + '0'                + "'" // QT_DIAS_PERIODO
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTJORNADA: "
	EndIf        
	
RETURN(NIL) 

Static Function INTUSUSISJORNADA(nJornada)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_JORNADA] " 
	cQuery += "(CD_JORNADA, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nJornada) + "'," // Credencial
	cQuery += "'"                + '1'                 + "',"  // Usuario Admin
    cQuery += ""                + 'GETDATE()'          + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISJORNADA: "
	EndIf        
	
RETURN(NIL)                     

Static Function INTJORDIA(nJornada,nDia,nTurno)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[JORNADA_DIA] " 
	cQuery += "(CD_JORNADA, " 
	cQuery += "NU_DIA, " 
    cQuery += "CD_TURNO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nJornada) + "'," // CD_JORNADA
	cQuery += "'"               + CVALTOCHAR(nDia)     + "',"  // NU_DIA
    cQuery += "'"               + CVALTOCHAR(nTurno)   + "' "  // CD_TURNO
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTJORDIA: "
	EndIf        
	
RETURN(NIL)                        

Static Function INTPERAC(nTurno)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[PERFIL_ACESSO] " 
	cQuery += "(NM_PERFIL_ACESSO, " 
	cQuery += "TP_PERFIL_ACESSO, " 
    cQuery += "FL_PUBLICO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTurno) + "'," // NM_PERFIL_ACESSO
	cQuery += "'"               + '0'                + "'," // TP_PERFIL_ACESSO
    cQuery += "'"               + '0'                + "' " // FL_PUBLICO
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERAC: "
	EndIf        
	                        
RETURN(NIL)                        

Static Function INTPERACREGRA(nPerfilAcesso,nGRupo,nArea,nTurno,nFaixaHoraria,nFlagAusente,cJornada,nQtdAcesso)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[PERFIL_ACESSO_REGRA] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_GRUPO, " 
	cQuery += "CD_AREA, " 
	cQuery += "TP_ACESSO, " 
	cQuery += "CD_JORNADA, " 
	cQuery += "CD_TURNO, " 
	cQuery += "CD_FAIXA_HORARIA, " 
	cQuery += "QT_ACESSO_PERMITIDO, " 
	cQuery += "TP_AUTENTICACAO, " 
	cQuery += "FL_NOTIFICA_PRESENTE, " 
	cQuery += "FL_NOTIFICA_AUSENTE, " 
    cQuery += "CD_JORNADA_NOTIFICA_AUSENTE " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nPerfilAcesso)                                                                + "'," // CD_PERFIL_ACESSO
	cQuery += "'"               + CVALTOCHAR(nGrupo)                                                                       + "'," // CD_GRUPO
	cQuery += "'"               + CVALTOCHAR(nArea)                                                                        + "'," // CD_AREA
	cQuery += "'"               + IIF(ALLTRIM(cJornada)       <> 'NULL','2','0')                                           + "'," // TP_ACESSO
	cQuery += " "               + IIF(ALLTRIM(cJornada)       <> 'NULL',"'" + cJornada + "'" ,cJornada)                    + " ," // CD_JORNADA
    cQuery += " "               + IIF(VALTYPE(nTurno)        == 'N'   ,"'" + CVALTOCHAR(nTurno) + "'" ,nTurno)             + " ," // CD_TURNO
	cQuery += ""                + IIF(VALTYPE(nFaixaHoraria) == 'N'   ,"'" + CVALTOCHAR(nFaixaHoraria)+ "'",nFaixaHoraria) + " ," // CD_FAIXA_HORARIA
	cQuery += ""                + IIF(VALTYPE(nQtdAcesso)    == 'N'   ,"'" + CVALTOCHAR(nQtdAcesso) + "'",nQtdAcesso)      + " ," // QT_ACESSO_PERMITIDO
	cQuery += "'"               + '0'                                                                                       + "'," // TP_AUTENTICACAO
	cQuery += "'"               + '0'                                                                                       + "'," // FL_NOTIFICA_PRESENTE
	cQuery += "'"               + CVALTOCHAR(nFlagAusente)                                                                  + "'," // FL_NOTIFICA_AUSENTE
    cQuery += " "               + IIF(ALLTRIM(cJornada)       <> 'NULL',"'" + cJornada + "'" ,cJornada)                     + " " // CD_JORNADA_NOTIFICA_AUSENTE
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERACREGRA: "
	EndIf        
	                        
RETURN(NIL)                        

Static Function INTPERRESTRICAO(nPerfilAcesso,nGRupo,nArea)

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[PERFIL_ACESSO_RESTRICAO] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_GRUPO, " 
	cQuery += "CD_AREA, " 
	cQuery += "FL_CONTROLA_TEMPO, " 
	cQuery += "TP_CONTROLE_TEMPO, " 
	cQuery += "FL_CONTROLA_TEMPO_GRUPOS " 
	cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nPerfilAcesso) + "'," // CD_PERFIL_ACESSO
	cQuery += "'"               + CVALTOCHAR(nGrupo)        + "'," // CD_GRUPO
	cQuery += "'"               + CVALTOCHAR(nArea)         + "'," // CD_AREA
	cQuery += "'"               + '0'                       + "'," // FL_CONTROLA_TEMPO
	cQuery += "'"               + '0'                       + "'," // TP_CONTROLE_TEMPO
	cQuery += "'"               + '0'                       + "'"  // FL_CONTROLA_TEMPO_GRUPOS
	cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERRESTRICAO: "
	EndIf        
	                        
RETURN(NIL)                        

Static Function INTSISPERFILACESSO(nPerfilAcesso)   	      	 	  

	cQuery := "INSERT INTO [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SIST_PERFIL_ACESSO] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nPerfilAcesso) + "'," // Credencial
	cQuery += ""                + '1'                       + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'               + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTSISPERFILACESSO: "
	EndIf        
	
RETURN(NIL)  

STATIC FUNCTION UPDPESSOA(cCampo1,cCampo2,nMat,nEstOrganizacional,nEstOrgEmpresa)

	cQuery := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + "'"  + cCampo2 + "'"
	cQuery += " WHERE NU_MATRICULA  = " + "" + cvaltochar(nMat) + ""  // chamado 053384 - WILLIAM COSTA - 14/11/2019
   
    If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - UPDPESSOA: " 
	EndIf        
	
RETURN(NIL)  

STATIC FUNCTION UPDPESS1(cCampo1,cCampo2,nMat,nEstOrganizacional,nEstOrgEmpresa)

	cQuery := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE NU_MATRICULA  = " + "" + cvaltochar(nMat) + "" // chamado 053384 - WILLIAM COSTA - 14/11/2019
    
	If (TCSQLExec(cQuery) < 0) .OR. ALLTRIM(CVALTOCHAR(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UPDPESS1: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
RETURN(NIL)

STATIC FUNCTION UPDPESS2(cCampo1,cCampo2,cCdPessoa)

	cQuery := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE CD_PESSOA     = " + "" + cvaltochar(cCdPessoa)               + "" 

	If (TCSQLExec(cQuery) < 0) .OR. ALLTRIM(CVALTOCHAR(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UPDPESS2: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
RETURN(NIL)

STATIC FUNCTION UPDCREDPES(cCampo1,cCdCredencial,cCdPessoa)

	cQuery := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
	cQuery += " SET " + cCampo1 + " = NULL " 
	cQuery += " WHERE CD_CREDENCIAL = " + "" + cvaltochar(cCdCredencial) + " " 
	cQuery += "   AND CD_PESSOA     = " + "" + cvaltochar(cCdPessoa)     + " " 

	If (TCSQLExec(cQuery) < 0) 
    	cIntregou += " TCSQLError() - UPDCREDPES: " + 'cCampo1: ' + cCampo1 
	EndIf        
	
RETURN(NIL)

Static Function DELSITPESSOAMULTIPLA(cCdPessoa)

	cQuery := "DELETE FROM [DMPACESSO].[DMPACESSOII].[dbo].[SITUACAO_PESSOA_MULTIPLA] " 
	cQuery += "WHERE CD_PESSOA = '" + cCdPessoa + "'"

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELSITPESSOAMULTIPLA: "
	EndIf        
	
RETURN(NIL)    

Static Function DELCREDPESSOA(cCredencialFace)                

	cQuery := "DELETE FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
	cQuery += "WHERE CD_CREDENCIAL = '" + cCredencialFace + "'"

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELCREDPESSOA: "
	EndIf        
	
RETURN(NIL)                           

Static Function DELUSUSISCREDENCIAL(cCredencialFace)                

	cQuery := "DELETE FROM [DMPACESSO].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_CREDENCIAL] " 
	cQuery += "WHERE CD_CREDENCIAL = '" + cCredencialFace + "'"

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELUSUSISCREDENCIAL: "
	EndIf        
	
RETURN(NIL)                                                                                                                                  

/*/{Protheus.doc} nomeStaticFunction
	Checa Credencial
	@type  Static Function
	@author FWNM
	@since 19/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GetCredenc(cTpTecno, nPessoa, nKey)

	Local lRet   := .f.
	Local cQuery := ""
	Local cSql   := ""

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT TOP 1 AMARRA.CD_CREDENCIAL, AMARRA.CD_PESSOA, AMARRA.TP_TECNOLOGIA
	cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
	cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
	cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nPessoa)+"'
	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nKey)+"'
	cQuery += " AND AMARRA.TP_TECNOLOGIA='"+CVALTOCHAR(cTpTecno)+"'
	cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( EOF() )
		lRet := .t.
	EndIf

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

Return lRet

/*/{Protheus.doc} nomeStaticFunction
	Checa Credencial
	@type  Static Function
	@author FWNM
	@since 20/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GetCDCred(nKey, nTpTecno)

	Local cRet   := ""
	Local cQuery := ""
	Local cSql   := ""

	Default nTpTecno := 0

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT CD_CREDENCIAL, TP_TECNOLOGIA
	cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK)
	cQuery += " WHERE CRED.NU_CREDENCIAL='"+CVALTOCHAR(nKey)+"'

	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		cRet := Work->CD_CREDENCIAL
	EndIf

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

Return cRet

/*/{Protheus.doc} Static Function ChkAllCred( TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)), Val(TRB->PTOCREDENCIAL) )
	Checa se existem 2 credenciais iguais com tipos de tecnologias difernetes
	@type  Static Function
	@author FWNM
	@since 22/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkAllCred(nCD_PESSOA, nCHAPA, nPTOCREDENCIAL)

	Local lRet := .f.
	Local cQuery := ""
	Local nTtCred := 0
	Local cSql := ""

	// Checo duplicidade pela Chapa

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT_CREDENCIAL
	cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK) 
	cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL 
	cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nCD_PESSOA)+"' 
	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nCHAPA)+"'
	cQuery += " AND AMARRA.TP_TECNOLOGIA IN ('1','3')
	cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		nTtCred := Work->TT_CREDENCIAL
	EndIf

	If nTtCred >= 2

		lRet := .t.

		cSql := " DELETE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
		cSql += " WHERE CD_PESSOA='"+CVALTOCHAR(nCD_PESSOA)+"' 

		TCSQLExec(cSql)
	
	EndIf

	// Checo duplicidade pela Credencial

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT_CREDENCIAL
	cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK) 
	cQuery += " INNER JOIN [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL 
	cQuery += " WHERE AMARRA.CD_PESSOA='"+CVALTOCHAR(nCD_PESSOA)+"' 
	cQuery += " AND CRED.NU_CREDENCIAL='"+CVALTOCHAR(nPTOCREDENCIAL)+"'
	cQuery += " AND AMARRA.TP_TECNOLOGIA IN ('1','3')
	cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		nTtCred := Work->TT_CREDENCIAL
	EndIf

	If nTtCred >= 2

		lRet := .t.

		cSql := " DELETE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
		cSql += " WHERE CD_PESSOA='"+CVALTOCHAR(nCD_PESSOA)+"' 

		TCSQLExec(cSql)
	
	EndIf

	If Select("Work")
		Work->( dbCloseArea() )
	EndIf

Return lRet

/*/{Protheus.doc} UpdTecno( TRC->CD_PESSOA, Val(SUBSTR(TRB->CHAPA,3,6)), Val(TRB->PTOCREDENCIAL) )
	Equalizo tipo tecnologia qdo estão divergentes entre as tabelas CREDENCIAL x CREDENCIAL_PESSOA
	@type  Static Function
	@author FWNM
	@since 22/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpdTecno( nCD_PESSOA, nCHAPA, nPTOCREDENCIAL )

	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT CD_CREDENCIAL, TP_TECNOLOGIA
	cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
	cQuery += " WHERE CD_PESSOA='"+cValToChar(nCD_PESSOA)+"' 

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		// Checo o TP de Tecnologia da credencial 
		If Select("WorkCRED") > 0
			WorkCRED->( dbCloseArea() )
		EndIf

		cQuery := " SELECT TP_TECNOLOGIA, NU_CREDENCIAL
		cQuery += " FROM [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL]
		cQuery += " WHERE CD_CREDENCIAL='"+cValToChar(Work->CD_CREDENCIAL)+"' 

		tcQuery cQuery New Alias "WorkCRED"

		WorkCRED->( dbGoTop() )
		If WorkCRED->( !EOF() )

			If Work->TP_TECNOLOGIA <> WorkCRED->TP_TECNOLOGIA

				// Codigo Barra
				If Len(cValToChar(WorkCRED->NU_CREDENCIAL)) == 5
				
					cTpTecno := "1"
				
					cSql := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL]
					cSql += " SET TP_TECNOLOGIA = '"+cTpTecno+"' "
					cSql += " WHERE CD_CREDENCIAL='"+cValToChar(Work->CD_CREDENCIAL)+"' 
					TCSQLEXEC(cSql)

					cSql := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
					cSql += " SET TP_TECNOLOGIA = '"+cTpTecno+"' "
					cSql += " WHERE CD_PESSOA='"+cValToChar(nCD_PESSOA)+"' 
					cSql += " AND CD_CREDENCIAL='"+cValToChar(Work->CD_CREDENCIAL)+"' 
					TCSQLEXEC(cSql)

				EndIf

				// Proximidade
				If Len(cValToChar(WorkCRED->NU_CREDENCIAL)) == 10
				
					cTpTecno := "3"
				
					cSql := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL]
					cSql += " SET TP_TECNOLOGIA = '"+cTpTecno+"' "
					cSql += " WHERE CD_CREDENCIAL='"+cValToChar(Work->CD_CREDENCIAL)+"' 
					TCSQLEXEC(cSql)

					cSql := " UPDATE [DMPACESSO].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
					cSql += " SET TP_TECNOLOGIA = '"+cTpTecno+"' "
					cSql += " WHERE CD_PESSOA='"+nCD_PESSOA+"' 
					cSql += " AND CD_CREDENCIAL='"+cValToChar(Work->CD_CREDENCIAL)+"' 
					TCSQLEXEC(cSql)

				EndIf

			EndIf

		EndIf

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	If Select("WorkCRED") > 0
		WorkCRED->( dbCloseArea() )
	EndIf

Return
