#INCLUDE "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADGPE044P
	Integracao com o sistema DIMEP de catracas Gerar Perfil de Acesso Especificos para funcionario que tem particularidades por exemplo acessos em cancelas e portas
	@type  Function
	@author William Costa
	@since 20/03/2019
	@version 01
	@history Chamado 053161 - William Costa - 05/11/2019 - Retirado do Select pessoas demitidas
	@history Chamado 055540 - William Costa - 04/02/2020 - Colocado trava para não abrir duas pessoas ao mesmo tempo essa rotina
	@history Chamado T.I    - William Costa - 05/02/2020 - Identificado que o UPDPESSOA estava com where a mais que não precisava após a troca para o CPF, foi retirado para verificar o correto funcionamento.
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
/*/
USER FUNCTION ADGPE044P()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	Private cLinked := "" 
	Private cSGBD   := "" 
	//

	Private oDlg               := NIL
	Private oMainWnd           := NIL
	Private oEmpresa           := Array(01)                                                                           
	Private oBtnConf           := Array(02)
	Private oBtnEst            := Array(03)
	Private oFilial            := Array(04)
	Private oCpf               := Array(05)
	Private oNome              := Array(06)
	Private oBtnCanc           := Array(07)
	Private cEmpresa           := SPACE(02)
	Private cFilAtu            := SPACE(02)
	Private cCPF               := SPACE(11)
	Private cNomeFunc          := SPACE(60)
	Private nEstOrgEmpresa     := 0
	Private nEstOrganizacional := 0
	Private nEstRelacionada    := 0
	Private cCcFunc            := ''
	Private lCargFaixa         := .F.
	Private nFlagAusente       := 0
	Private cJornada           := ''
	Private nCont              := 0  
	Private nCont1             := 0
	Private cIntregou          := ''     
	Private cTexto             := ''
	Private nQtdAcesso         := 0
	Private cQuery             := ''
	Private cKeyBloq           := "ADGPE044P" // Carregar Matricula para o Dimep
	
	cEmpresa := cEmpAnt
	cFilAtu  := FWXFILIAL("SRA")
	
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	cLinked := GetMV("MV_#RMLINK",,"RM") 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")
	//

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Gerar Perfil de Acesso Especificos para funcionario que tem particularidades por exemplo acessos em cancelas e portas')

	IF !(__cUserId $ GetMv("MV_#USUDIM",,"001439"))
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Você não tem permissão de Utilizar essa Rotina", "ADGPE044P-01")
		RETURN(NIL)
	
	ENDIF

	// Garanto uma unica thread sendo executada por empresa
	IF !LOCKBYNAME(cKeyBloq, .T., .F.)

		MSGALERT("[ADGPE044P] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo Administrador...")

		RETURN(NIL)

	ENDIF
	
	DEFINE MSDIALOG oDlg TITLE "Criar Perfil de Acesso por CPF" FROM 0,0 TO 185,450 OF oMainWnd PIXEL
		
		@ 003, 003 TO 090,225 PIXEL OF oDlg
		
		@ 010,005 Say "Empresa:" of oDlg PIXEL 
		@ 008,030 MsGet oEmpresa Var cEmpresa SIZE 30,10 of oDlg PIXEL Picture "@!" WHEN .F. 
		
		@ 030,005 Say "Filial:" of oDlg PIXEL 
		@ 028,030 MsGet oFilial Var cFilAtu SIZE 30,10 of oDlg PIXEL Picture "@!" WHEN .F. 
		
		@ 050,005 Say "CPF:" of oDlg PIXEL
		@ 048,030 MsGet oCPF Var cCPF SIZE 60,10 of oDlg PIXEL Picture "@!" VALID VALCPF(cFilAtu,cCPF)
		
		@ 048,095 MsGet oNome Var cNomeFunc SIZE 100,10 of oDlg PIXEL Picture "@!" WHEN .F.
		
		@ 070,005 BUTTON oBtnConf [01] PROMPT "Criar Perfil"    OF oDlg SIZE 60,12 PIXEL ACTION (MsAguarde({|| CARREGAPERFIL(cFilAtu,cCPF) },"Aguarde","Carregando Perfil Especifico(Dimep)..."), oDlg:End())
		@ 070,080 BUTTON oBtnEst  [01] PROMPT "Estornar Perfil" OF oDlg SIZE 60,12 PIXEL ACTION (MsAguarde({|| ESTORNOPERFIL(cFilAtu,cCPF) },"Aguarde","Estornando Perfil Especifico(Dimep)..."), oDlg:End())
		@ 070,160 BUTTON oBtnCanc [01] PROMPT "Cancelar"        OF oDlg SIZE 60,12 PIXEL ACTION (oDlg:End())
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
RETURN(NIL)

STATIC FUNCTION CARREGAPERFIL(cFilAtu,cCPF)

	Local nUlTurno   := 0
	Local lRetTurno  := .F.
	Local lRetPerfil := .F.
	Local aAllUser   := FWSFALLUSERS()
	Local lRet       := .T.
	
	lRet := VALIDENVIO(cFilAtu,cCPF) //Valida os campos de Funcionario
	
	// Se a Validacao retornar falso nao cria o perfil
	IF lRet == .F.
	
		RETURN(NIL)
	
	ENDIF

	cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
    VEmpresaDimep(cFilAtu,cNu_Estrutura)
    SqlPerfilEspecifico(cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	
	While TSD->(!EOF())
	
		IF ALLTRIM(TSD->TX_CAMPO08) == ''
		 
			nUlTurno := 990001
		
		ELSE
		
			nUlTurno := VAL(TSD->TX_CAMPO08) + 1
			
		ENDIF
		
		
		TSD->(dbSkip())
											
    ENDDO
    TSD->(dbCloseArea())
	
		// *** INICIO INTEGRACAO REGRA DE ACESSO *** //
	
	SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
	
	While TRB->(!EOF())

		SqlTurno(CVALTOCHAR(VAL(CEMPANT)),TRB->CODHORARIO)
		
		// *** INICIO BUSCA TURNO NO RM *** //
		
		While TRL->(!EOF())       

			lCargFaixa   := .F.    
			nFlagAusente := 0
			cJornada     := ''
			nCont        := 0
			cIntregou    := ''
			cTexto       := ''

			// *** INICIO VERIFICA TURNO SE JA ESTA CADASTRADO NO DIMEP *** //
		
			SqlVTurnoDimep(nUlTurno)
			
			IF TRH->(EOF()) 

				CargaTurnoDimep(nUlTurno,'Perfil CPF: ' + TRB->CPF)

			ENDIF	
			TRH->(dbCloseArea())

			// *** INICIO Pega o codigo do turno que gerou no DIMEP *** //
			SqlVTurnoDimep(nUlTurno)
			
			IF TRH->(!EOF()) 

				lRetTurno  := .T.

				INTUSUSISTURNO(TRH->CD_TURNO)	

				// *** INICIO VERIFICACAO JORNADA *** //
				SqlJorRM(CVALTOCHAR(VAL(CEMPANT)),TRL->CODIGO)
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
						
						INTJORNADA(CVALTOCHAR(nUlTurno))
						
						SqlJORNADA(CVALTOCHAR(nUlTurno))
						While TRO->(!EOF())       
				
							INTUSUSISJORNADA(TRO->CD_JORNADA)
							
							TRO->(dbSkip())
									
						ENDDO
						TRO->(dbCloseArea())
						
						lCargFaixa := .T. 
						
					ENDIF
					// *** FINAL DIREITO A TODAS AS FAIXAS  *** //
					
					SqlJORNADA(CVALTOCHAR(nUlTurno))
					While TRO->(!EOF())       

						nDiaSemana := AcharDiaSemana(CEMPANT,TRM->CODHORARIO,TRM->INDINICIO)     
			
						SqlJorDia(TRO->CD_JORNADA,nDiaSemana,TRH->CD_TURNO) // verifica se ja existe uma jornada dia
						
						IF TRV->(EOF())  

							INTJORDIA(TRO->CD_JORNADA,nDiaSemana,TRH->CD_TURNO)
							
						ENDIF
						TRV->(dbCloseArea())	
						
						TRO->(dbSkip())
								
					ENDDO
					TRO->(dbCloseArea())	
					
					TRM->(dbSkip())
								
				ENDDO
				TRM->(dbCloseArea()) 
				// *** FINAL VERIFICACAO JORNADA *** //

				// *** Final Pega o codigo do turno que gerou no DIMEP *** //

				// *** INICIO ADICIONA SABADO DOMINGO OU FERIADO NO TURNO CASO NECESSARIO *** //
				SqlJORNADA(CVALTOCHAR(nUlTurno))
				While TRO->(!EOF())       

					SqlJorDia(TRO->CD_JORNADA,7,TRH->CD_TURNO) // adiciona o sábado para todos os turnos
				
					IF TRV->(EOF())  

						INTJORDIA(TRO->CD_JORNADA,7,TRH->CD_TURNO)

					ENDIF
					TRV->(dbCloseArea())	

					TRO->(dbSkip())

				ENDDO
				TRO->(dbCloseArea())

				IF TRL->HORARIOJOR == 1

					// *** INICIO FERIADO *** //
					SqlJORNADA(CVALTOCHAR(nUlTurno))
					While TRO->(!EOF())       

						SqlJorDia(TRO->CD_JORNADA,1,TRH->CD_TURNO) // adiciona o sábado para todos os turnos

						IF TRV->(EOF())  

							INTJORDIA(TRO->CD_JORNADA,1,TRH->CD_TURNO)
						
						ENDIF
						TRV->(dbCloseArea())	

						TRO->(dbSkip())

					ENDDO
					TRO->(dbCloseArea())
					// *** FINAL FERIADO *** //

					// *** INICIO DOMINGO *** //
					SqlJORNADA(CVALTOCHAR(nUlTurno))
					While TRO->(!EOF())       

						SqlJorDia(TRO->CD_JORNADA,0,TRH->CD_TURNO) // adiciona o sábado para todos os turnos
						
						IF TRV->(EOF())  

							INTJORDIA(TRO->CD_JORNADA,0,TRH->CD_TURNO)

						ENDIF
						TRV->(dbCloseArea())	

						TRO->(dbSkip())

					ENDDO
					TRO->(dbCloseArea())
					// *** FINAL DOMINGO *** //

				ENDIF

				// *** FINAL ADICIONA SABADO DOMINGO OU FERIADO NO TURNO CASO NECESSARIO *** //

			ENDIF
			TRH->(dbCloseArea())
            
			// *** FINAL CARREGA TURNO E JORNADA *** //

			// *** INICIO CARREGA PERFIL DE ACESSO *** //
			SqlPerAc(CVALTOCHAR(nUlTurno)) 
			
			IF TRP->(EOF())
			
				INTPERAC(CVALTOCHAR(nUlTurno)) // Integra Perfil de Acesso

				TRP->(dbCloseArea()) 
			
				SqlPerAc(CVALTOCHAR(nUlTurno))
				IF TRP->(!EOF())

					lRetPerfil := .T.

					INTSISPERFILACESSO(TRP->CD_PERFIL_ACESSO) // Integra Usuario Perfil de Acesso

					// *** INICIO LIBERA PERFIL DE ACESSO PARA OUTROS USUARIOS *** // 
					SqlUsuProtheus()
					While TSG->(!EOF())
					
						For nCont1 :=1 to Len(aAllUser)
					
							IF aAllUser[nCont1][2] == TSG->ZFG_CODUSR
								
								SqlUsuDimep(aAllUser[nCont1][3])
								While TSH->(!EOF())
								
									INTPERUSUARIO(TRP->CD_PERFIL_ACESSO,TSH->CD_USUARIO)    // Integra Usuario Perfil de Acesso
									TSH->(dbSkip())
														
								ENDDO
								TSH->(dbCloseArea())
							ENDIF
						NEXT nCont1
					
						TSG->(dbSkip())
											
					ENDDO
					TSG->(dbCloseArea())
					// *** FINAL LIBERA PERFIL DE ACESSO PARA OUTROS USUARIOS *** //
					
					// *** INICIO CARREGA GRUPO REFEITORIO PARA O PERFIL DE ACESSO *** // 	      	 	  
					SqlGrupoArea(1)
					While TRQ->(!EOF())
						
						SqlVTurnoDimep(nUlTurno)
			
						IF TRH->(!EOF())  
						
							SqlTurnoFaixa(TRH->CD_TURNO)
							nCont:=0
							While TRR->(!EOF())
								
								SqlJORNADA(CVALTOCHAR(nUlTurno))
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
					While TSI->(!EOF())
						
						SqlVTurnoDimep(CVALTOCHAR(nUlTurno))
			
						IF TRH->(!EOF())  
						
							nQtdAcesso := 999
							INTPERACREGRA(TRP->CD_PERFIL_ACESSO,TSI->CD_GRUPO,TSI->CD_AREA,'NULL','NULL','0','NULL',nQtdAcesso) // Integra Perfil de Regra
							INTPERRESTRICAO(TRP->CD_PERFIL_ACESSO,TSI->CD_GRUPO,TSI->CD_AREA) // Integra PERFIL_ACESSO_RESTRICAO	
							
						ENDIF
						TRH->(dbCloseArea())                  
						
						TSI->(dbSkip())
								
					ENDDO
					TSI->(dbCloseArea()) 

					// *** FINAL INTEGRA GRUPO CATRACA PORTARIA *** //
				
				ENDIF            
				TRP->(dbCloseArea()) 

			ELSE
		
				TRP->(dbCloseArea()) 
		
			ENDIF 

			// *** FINAL CARREGA PERFIL DE ACESSO *** //
			
			TRL->(dbSkip())

		ENDDO
		
		TRL->(dbCloseArea())
		TRB->(dbSkip())
		
	ENDDO
	TRB->(dbCloseArea()) 
	
	IF lRetTurno == .T. .AND. lRetPerfil == .T.
	
		// *** INICIO SALVA CAMPO DE TURNO NA PESSOA *** //
		cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
	    VEmpresaDimep(cFilAtu,cNu_Estrutura)
	    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	    
	    IF TRC->(!EOF())
			
	    	UPDPESSOA('TX_CAMPO08',CVALTOCHAR(nUlTurno),VAL(cCPF),TRC->CD_ESTRORG,nEstOrgEmpresa)
				
		ENDIF
		TRC->(dbCloseArea())
		// *** FINAL SALVA CAMPO DE TURNO NA PESSOA *** //
		
		// *** INICIO SALVA NO PERFIL DE ACESSO NA PESSOA *** //
		SqlPerAc(CVALTOCHAR(nUlTurno))
		IF TRP->(!EOF())
		
			cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
		    VEmpresaDimep(cFilAtu,cNu_Estrutura)
		    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
		    
		    IF TRC->(!EOF())
				
		    	UPDPESS2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,TRC->CD_PESSOA)
					
			ENDIF
			TRC->(dbCloseArea())
		
		ENDIF
		
		// *** FINAL SALVA NO PERFIL DE ACESSO NA PESSOA *** //
	
		MSGINFO("OLÁ " + Alltrim(cUserName) + ", perfil Criado com Sucesso nº " + CVALTOCHAR(nUlTurno),"ADGPE044P-02")
		
		// *** INICIO GERA LOG *** //              
		cTexto := '1-) Botão Confirmar ' + cCPF + ' Log Turno:' + 'Cod Turno: ' + CVALTOCHAR(nUlTurno)
    	GERALOG(FWFILIAL("SRA"),cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
    	// *** FINAL GERA LOG *** // 
		
	ELSE
	
		MSGINFO("OLÁ " + Alltrim(cUserName) + ", perfil não Criado, entre em contato com a T.I","ADGPE044P-03")
	
	ENDIF
    
    // *** FINAL BUSCA TURNO NO RM *** //
    // *** FINAL INTEGRACAO REGRA DE ACESSO *** //

RETURN(NIL)

STATIC FUNCTION VALIDENVIO(cFilAtu,cCPF)

	Local lRet := .T.
	
	IF ALLTRIM(cCPF) == '' .OR. LEN(ALLTRIM(cCPF)) < 11
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não pode ser branco ou Menor que 11 digitos, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-04")
		lRet := .F.
	
	ENDIF
	
	// *** INICIO BUSCA FUNCIONARIOS NO RM *** //
	IF lRet == .T.
	
		SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
		IF TRB->(EOF())
		
			MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não encontrada no RM, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-05")
			lRet := .F.
		
		ENDIF
		
		While TRB->(!EOF())
		
			IF ALLTRIM(TRB->CODSITUACAO) == 'D'
			
				MsgStop("OLÁ " + Alltrim(cUserName) + ", Funcionário Demitido, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-06")
				lRet := .F.
			
			ELSE 
			
				cCcFunc := ALLTRIM(TRB->NROCENCUSTOCONT)
			ENDIF
		
			TRB->(dbSkip())
				
		ENDDO
		TRB->(dbCloseArea())
	
	ENDIF
	// *** FINAL BUSCA FUNCIONARIOS NO RM *** //
	
	// *** INICIO BUSCA FUNCIONARIOS NO DIMEP *** //
	IF lRet == .T.
	
		cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
	    VEmpresaDimep(cFilAtu,cNu_Estrutura)
	    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	    IF TRC->(EOF())
			
	    	MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não encontrada no Dimep, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-07")
			lRet := .F.
				
		ENDIF
		TRC->(dbCloseArea())
		
    ENDIF    
    // *** FINAL BUSCA FUNCIONARIOS NO DIMEP *** //
    
    // *** INICIO VERIFICA SE O FUNCIONARIO ESTA COM O TURNO DO RM OU JA ESTA COM OUTO SO DEIXA TROCAR SE O TURNO FOR IGUAL DO RM *** //
	IF lRet == .T.
	
		cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
	    VEmpresaDimep(cFilAtu,cNu_Estrutura)
	    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	    IF TRC->(!EOF())
	    
	    	SqlPerAc2(TRC->CD_PERFIL_ACESSO)
	    	IF TSE->(!EOF())
	    	
	    		SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
				IF TRB->(!EOF())
				
					IF VAL(TSE->NM_PERFIL_ACESSO) <> VAL(CEMPANT+TRB->CODHORARIO)
				
					MsgStop("OLÁ " + Alltrim(cUserName) + ", Perfil de Acesso já alterado para o colaborador, não podemos continuar com a criação de Perfil de Acesso" + CHR(13) + CHR(10) + "Perfil Dimep = " + ALLTRIM(TSE->NM_PERFIL_ACESSO) + CHR(13) + CHR(10) + "Turno RM = " + CVALTOCHAR(VAL(CEMPANT+TRB->CODHORARIO)), "ADGPE044P-08")
					lRet := .F.
					
					ENDIF
				ENDIF
				TRB->(dbCloseArea())
	    	ENDIF
	    	TSE->(dbCloseArea())
	    ENDIF
		TRC->(dbCloseArea())
		
    ENDIF    
    // *** FINAL VERIFICA SE O FUNCIONARIO ESTA COM O TURNO DO RM OU JA ESTA COM OUTO SO DEIXA TROCAR SE O TURNO FOR IGUAL DO RM *** //
    
    IF lRet == .T.
    
    	SqlVTur(CVALTOCHAR(VAL(cCPF)))
    	WHILE TSF->(!EOF())
    	
    		MsgStop("OLÁ " + Alltrim(cUserName) + ", Perfil de Acesso já existe para o colaborador, não podemos continuar com a criação de Perfil de Acesso" + CHR(13) + CHR(10) + "Perfil Dimep = " + ALLTRIM(CVALTOCHAR(TSF->NU_TURNO)) + ' - ' + ALLTRIM(TSF->DS_TURNO) , "ADGPE044P-09")
			lRet := .F.
    	
    		TSF->(dbSkip())
				
		ENDDO
		TSF->(dbCloseArea())
    	
    ENDIF
    
RETURN(lRet)

STATIC FUNCTION AcharDiaSemana(cEmpresa,cTurno,nIndiceTurno)

	Local nDia := 0

	SqlDiaSemanaRM(cEmpresa,cTurno)
	While TSJ->(!EOF())    

		IF nIndiceTurno == VAL(SUBSTR(TSJ->COLUNA,4,1))

			DO CASE
				CASE ALLTRIM(TSJ->VALOR) == "Segunda-Feira" .OR.  ALLTRIM(TSJ->VALOR) == "Monday"  
					nDia := 2
				CASE ALLTRIM(TSJ->VALOR) == "Terça-Feira"   .OR.  ALLTRIM(TSJ->VALOR) == "Tuesday"    
					nDia := 3
				CASE ALLTRIM(TSJ->VALOR) == "Quarta-Feira"  .OR.  ALLTRIM(TSJ->VALOR) == "Wednesday"  
					nDia := 4
				CASE ALLTRIM(TSJ->VALOR) == "Quinta-Feira"  .OR.  ALLTRIM(TSJ->VALOR) == "Thursday"  
					nDia := 5
				CASE ALLTRIM(TSJ->VALOR) == "Sexta-Feira"   .OR.  ALLTRIM(TSJ->VALOR) == "Friday"    
					nDia := 6
				CASE ALLTRIM(TSJ->VALOR) == "Sábado"        .OR.  ALLTRIM(TSJ->VALOR) == "Saturday"  
					nDia := 7
				CASE ALLTRIM(TSJ->VALOR) == "Domingo"       .OR.  ALLTRIM(TSJ->VALOR) == " Sunday"    
					nDia := 1				
				OTHERWISE
					nDia := 6
			ENDCASE   

	    ENDIF

		TSJ->(dbSkip())
				
	ENDDO
	TSJ->(dbCloseArea())	

Return(nDia)

Static Function BuscaEstrutura(cFilFunc,nCPF)

	Local cRet:= ''
	
	SqlVEmpresaDimep(CEMPANT)
    		
    IF TRI->(!EOF()) 
    			
    	nEstOrgEmpresa := TRI->ESTRUTURA   
    				
    ENDIF
    TRI->(dbCloseArea())
    		 
    IF nEstOrgEmpresa > 0   
    
    	SqlVFilialDimep(nEstOrgEmpresa, cFilFunc)
    		
    	IF TRZ->(!EOF()) 
    	
    		SqlVEstrutura(TRZ->ESTRUTURA,nCPF)
	
			While TSC->(!EOF())
			                  
		        cRet := TSC->NU_ESTRUTURA
		        
		    	TSC->(dbSkip())
			ENDDO
			TSC->(dbCloseArea())
			
			// *** INICIO CHAMADO WILLIAM 03/12/2018 045548 || OS 046717 || RECURSOS || DANIELA || 8436 || INTEGRACAO DIMEP FUN *** //
			IF ALLTRIM(cREt) == ''
			
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

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE044P"
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL)

STATIC FUNCTION VALCPF(cFilAtu,cCPF)

	Local lRet := .T.

	SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
	IF TRB->(!EOF())
	
		cNomeFunc := TRB->NOME
			
	ENDIF
	TRB->(dbCloseArea())
	
	oDlg:REFRESH()
	oCPF:REFRESH()
	oDlg:SetFocus()
    
RETURN(lRet)

STATIC FUNCTION ESTORNOPERFIL(cFilAtu,cCPF)

	Local nUlTurno    := 0
	Local lRetTurno   := .F.
	Local lRetPerfil  := .F.
	Local lRetJornada := .F.
	Local cDescPerfil := ''
	
	Local lRet        := .T.
	
	lRet := VALIDESTORNO(cFilAtu,cCPF) //Valida os campos de Funcionario
	
	// Se a Validacao retornar falso nao cria o perfil
	IF lRet == .F.
	
		RETURN(NIL)
	
	ENDIF
	
	cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
    VEmpresaDimep(cFilAtu,cNu_Estrutura)
    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
    IF TRC->(!EOF())
    
    	IF TRC->CD_PERFIL_ACESSO > 0
		
    		cDescPerfil := ALLTRIM(TRC->TX_CAMPO08)
    	    // *** INICIO DELETAR PERFIL DE ACESSO ESPECIFICO *** //
    	    
    		DELPERACREGRA(TRC->CD_PERFIL_ACESSO)
    		DELPERRESTRICAO(TRC->CD_PERFIL_ACESSO)
    		DELPERUSSIS(TRC->CD_PERFIL_ACESSO)
    		UPDPESSOA('TX_CAMPO08','',VAL(cCPF),TRC->CD_ESTRORG,nEstOrgEmpresa)
    		
    		SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
			IF TRB->(!EOF())
			
				SqlPerAc(CVALTOCHAR(VAL(CEMPANT+TRB->CODHORARIO))) 
	    	
				IF TRP->(!EOF())
	    	    
					UPDPESS2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,TRC->CD_PESSOA)
	    		    cTexto := '2-) Botão Estorno ' + cCPF + ' Log Turno:' + 'Cod Turno: ' + CVALTOCHAR(VAL(CEMPANT+TRB->CODHORARIO))
					GERALOG(FWFILIAL("SRA"),cTexto, 'Integrou: ' + IIF(ALLTRIM(cIntregou)== '', 'OK',cIntregou))
					
	    		    
	    		TRP->(dbCloseArea()) 
				ENDIF
			ENDIF
			TRB->(dbCloseArea())
    		
    		DELUSSISPER(TRC->CD_PERFIL_ACESSO)
    		DELPERFIL(TRC->CD_PERFIL_ACESSO)
    		
    		// *** FINAL DELETAR PERFIL DE ACESSO ESPECIFICO *** //
    		
    		// *** INICIO DELETAR JORNADA ESPECIFICO *** //
    		SqlJORNADA(cDescPerfil)
		    IF TRO->(!EOF())  
		    
		    	IF TRO->CD_JORNADA > 0
		    	
		    		DELUSSIJOR(TRO->CD_JORNADA)
		    		DELJORDIA(TRO->CD_JORNADA)
		    		DELJORNADA(TRO->CD_JORNADA)
		    		
    	   		ENDIF
    	   				
		    ENDIF
		    TRO->(dbCloseArea())
    	    
    		// *** FINAL DELETAR JORNADA ESPECIFICO *** //
    		
    		// *** INICIO DELETAR TURNO ESPECIFICO *** //
    		SqlVTurnoDimep(cDescPerfil)
			
	    	IF TRH->(!EOF()) 
		    		 
		    	IF TRH->CD_TURNO > 0
		    	
		    		DELTURFAIXA(TRH->CD_TURNO)
		    		DELUSSITURNO(TRH->CD_TURNO)
		    		DELTURNO(TRH->CD_TURNO)
		    		
    	   		ENDIF
		    	
		    ENDIF
	    	TRH->(dbCloseArea())
	    	
	    	// *** FINAL DELETAR TURNO ESPECIFICO *** //
    	
		ENDIF	
	ENDIF
	TRC->(dbCloseArea())
	
	MSGINFO("OLÁ " + Alltrim(cUserName) + ", perfil do CPF estornado com Sucesso nº " + cCPF,"ADGPE044P-10")
	
RETURN(NIL)

STATIC FUNCTION VALIDESTORNO(cFilAtu,cCPF)

	Local lRet := .T.
	
	IF ALLTRIM(cCPF) == '' .OR. LEN(ALLTRIM(cCPF)) < 6
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não pode ser branco ou Menor que 6 digitos, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-11")
		lRet := .F.
	
	ENDIF
	
	// *** INICIO BUSCA FUNCIONARIOS NO RM *** //
	IF lRet == .T.
	
		SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
		IF TRB->(EOF())
		
			MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não encontrada no RM, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-12")
			lRet := .F.
		
		ENDIF
		
		While TRB->(!EOF())
		
			IF ALLTRIM(TRB->CODSITUACAO) == 'D'
			
				MsgStop("OLÁ " + Alltrim(cUserName) + ", Funcionário Demitido, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-13")
				lRet := .F.
			
			ELSE 
			
				cCcFunc := ALLTRIM(TRB->NROCENCUSTOCONT)
			ENDIF
		
			TRB->(dbSkip())
				
		ENDDO
		TRB->(dbCloseArea())
	
	ENDIF
	// *** FINAL BUSCA FUNCIONARIOS NO RM *** //
	
	// *** INICIO BUSCA FUNCIONARIOS NO DIMEP *** //
	IF lRet == .T.
	
		cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
	    VEmpresaDimep(cFilAtu,cNu_Estrutura)
	    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	    IF TRC->(EOF())
			
	    	MsgStop("OLÁ " + Alltrim(cUserName) + ", CPF não encontrada no Dimep, não podemos continuar com a criação de Perfil de Acesso", "ADGPE044P-14")
			lRet := .F.
				
		ENDIF
		TRC->(dbCloseArea())
		
    ENDIF    
    // *** FINAL BUSCA FUNCIONARIOS NO DIMEP *** //
    
    // *** INICIO VERIFICA SE O FUNCIONARIO ESTA COM O TURNO DO RM OU JA ESTA COM OUTO SO DEIXA TROCAR SE O TURNO FOR IGUAL DO RM *** //
	IF lRet == .T.
	
		cNu_Estrutura := BuscaEstrutura(cFilAtu,VAL(cCPF))
	    VEmpresaDimep(cFilAtu,cNu_Estrutura)
	    SqlVFuncDimep(VAL(cCPF),cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada))
	    IF TRC->(!EOF())
	    
	    	SqlPerAc2(TRC->CD_PERFIL_ACESSO)
	    	IF TSE->(!EOF())
	    	
	    		SqlFuncRM(CVALTOCHAR(VAL(CEMPANT)),cCPF)
		
				IF TRB->(!EOF())
				
					IF VAL(TSE->NM_PERFIL_ACESSO) == VAL(CEMPANT+TRB->CODHORARIO)
				
					MsgStop("OLÁ " + Alltrim(cUserName) + ", Perfil de Acesso não pode ser estornado para o colaborador, já está igual o RM" + CHR(13) + CHR(10) + "Perfil Dimep = " + ALLTRIM(TSE->NM_PERFIL_ACESSO) + CHR(13) + CHR(10) + "Turno RM = " + CVALTOCHAR(VAL(CEMPANT+TRB->CODHORARIO)), "ADGPE044P-15")
					lRet := .F.
					
					ENDIF
				ENDIF
				TRB->(dbCloseArea())
	    	ENDIF
	    	TSE->(dbCloseArea())
	    ENDIF
		TRC->(dbCloseArea())
		
    ENDIF    
    // *** FINAL VERIFICA SE O FUNCIONARIO ESTA COM O TURNO DO RM OU JA ESTA COM OUTO SO DEIXA TROCAR SE O TURNO FOR IGUAL DO RM *** //
    
RETURN(lRet)

Static Function SqlFuncRM(cEmpresa,cCPF)

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	BeginSQL Alias "TRB"
			%NoPARSER%  
			 SELECT PFUNC.CODCOLIGADA,
					PFUNC.CODFILIAL,
					PFUNC.CODSITUACAO,
					PFUNC.CHAPA,
					PFUNC.NOME,
					PFUNC.DATAADMISSAO,
					PPESSOA.DTNASCIMENTO,
					PPESSOA.SEXO,
					PPESSOA.CPF,
					PPESSOA.CARTIDENTIDADE,
					PFUNC.PISPASEP,
					PFUNC.CODHORARIO,
					PFUNC.DATADEMISSAO,
					PSECAO.NROCENCUSTOCONT,
				 	CONVERT(NUMERIC,ISNULL(PFCOMPL.PTOCREDENCIAL,'0')) AS PTOCREDENCIAL
				FROM [VPSRV16].[CORPORERM].[DBO].[PFUNC] WITH (NOLOCK)
				INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PPESSOA] WITH (NOLOCK)
						ON PPESSOA.CODIGO                                   = PFUNC.CODPESSOA
				INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PSECAO] WITH (NOLOCK)
						ON PSECAO.CODCOLIGADA                               = PFUNC.CODCOLIGADA
					   AND PSECAO.CODIGO                                    = PFUNC.CODSECAO
				INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PFCOMPL] WITH (NOLOCK)
					 ON PFCOMPL.CODCOLIGADA                                 = PFUNC.CODCOLIGADA
					AND PFCOMPL.CHAPA                                       = PFUNC.CHAPA
					AND CONVERT(NUMERIC,ISNULL(PFCOMPL.PTOCREDENCIAL,'0'))  > 0
				  WHERE PFUNC.CODCOLIGADA                                   = %EXP:cEmpresa%
				    AND CODTIPO                                            <> 'A'
					AND (PFUNC.DATADEMISSAO                                >= GETDATE() - 7
					OR  PFUNC.DATADEMISSAO                                 IS NULL)
					AND PFUNC.PISPASEP                                     NOT IN (SELECT TOP(1) PFUNC2.PISPASEP FROM [VPSRV16].[CORPORERM].[DBO].[PFUNC] PFUNC2 WHERE PFUNC2.PISPASEP = PFUNC.PISPASEP AND PFUNC2.CODCOLIGADA <> PFUNC.CODCOLIGADA AND PFUNC2.CODSITUACAO <> 'D')
					AND PPESSOA.CPF                                         = %EXP:cCPF% //retirar will
				ORDER BY PPESSOA.CPF

	EndSQl 			
	
	*/

	TRB := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		 SELECT PFUNC.CODCOLIGADA,
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
	cQuery += "			 	CONVERT(NUMERIC,ISNULL(PFCOMPL.PTOCREDENCIAL,''0'')) AS PTOCREDENCIAL
	cQuery += "			FROM [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK)
	cQuery += "			INNER JOIN [" + cSGBD + "].[DBO].[PPESSOA] AS PPESSOA WITH (NOLOCK)
	cQuery += "					ON PPESSOA.CODIGO                                   = PFUNC.CODPESSOA
	cQuery += "			INNER JOIN [" + cSGBD + "].[DBO].[PSECAO] AS PSECAO WITH (NOLOCK)
	cQuery += "					ON PSECAO.CODCOLIGADA                               = PFUNC.CODCOLIGADA
	cQuery += "				   AND PSECAO.CODIGO                                    = PFUNC.CODSECAO
	cQuery += "			INNER JOIN [" + cSGBD + "].[DBO].[PFCOMPL] AS PFCOMPL WITH (NOLOCK)
	cQuery += "				 ON PFCOMPL.CODCOLIGADA                                 = PFUNC.CODCOLIGADA
	cQuery += "				AND PFCOMPL.CHAPA                                       = PFUNC.CHAPA
	cQuery += "				AND CONVERT(NUMERIC,ISNULL(PFCOMPL.PTOCREDENCIAL,''0''))  > 0
	cQuery += "			  WHERE PFUNC.CODCOLIGADA                                   = ''"+cEmpresa+"''
	cQuery += "			    AND CODTIPO                                            <> ''A''
	cQuery += "				AND (PFUNC.DATADEMISSAO                                >= GETDATE() - 7
	cQuery += "				OR  PFUNC.DATADEMISSAO                                 IS NULL)
	cQuery += "				AND PFUNC.PISPASEP                                     NOT IN (SELECT TOP(1) PFUNC2.PISPASEP FROM [" + cSGBD + "].[DBO].[PFUNC] PFUNC2 WHERE PFUNC2.PISPASEP = PFUNC.PISPASEP AND PFUNC2.CODCOLIGADA <> PFUNC.CODCOLIGADA AND PFUNC2.CODSITUACAO <> ''D'')
	cQuery += "				AND PPESSOA.CPF                                         = ''"+cCPF+"'' " //retirar will
	cQuery += "			ORDER BY PPESSOA.CPF

	cQuery += " ')

	tcQuery cQuery New Alias TRB
	//

RETURN(NIL)

Static Function SqlVFuncDimep(cCPF,cEstOrganizacional,cEstOrgEmpresa,cEstRelacionada)

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
				          TX_CAMPO08 
				     FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA WITH (NOLOCK)
			 	    WHERE NU_MATRICULA                          = %EXP:cCPF%
				      	
	EndSQl             
RETURN(NIL)

Static Function SqlVTurnoDimep(nTurno)                          

	BeginSQL Alias "TRH"
			%NoPARSER%   
			SELECT CD_TURNO,NU_TURNO,DS_TURNO,HR_ZERA_QTD_ACESSO
			  FROM [DIMEP].[DMPACESSOII].[DBO].[TURNO]  WITH (NOLOCK)
             WHERE NU_TURNO = %EXP:nTurno%
			
	EndSQl             
RETURN(NIL)   

Static Function SqlVEmpresaDimep(cEmpresa)                          

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
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE NU_ESTRUTURA = %EXP:cEmpresa%
			    AND TP_ESTRUTURA = '0'
			    AND NU_CNPJ <> 0
     
	EndSQl             
RETURN(NIL)	

Static Function SqlVDepartamentoDimep(nEstOrganizacional, cFil)

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
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nEstOrganizacional%
			    AND NU_ESTRUTURA             = %EXP:cFil%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)

Static Function SqlTurno(cEmpresa,cTurno)     

	Local cTeste:= ''

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	BeginSQL Alias "TRL"
			%NoPARSER%  
			SELECT CODIGO,
				   DESCRICAO,
				   HORARIOJOR
			  FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO] WITH(NOLOCK)
			 WHERE CODCOLIGADA = %EXP:cEmpresa%
			   AND INATIVO     = 0
			   AND CODIGO      = %EXP:cTurno%
			ORDER BY CODIGO
 			 
 	EndSQl   

	*/

	TRL := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		SELECT CODIGO,
	cQuery += "			   DESCRICAO,
	cQuery += "			   HORARIOJOR
	cQuery += "		  FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO WITH (NOLOCK)
	cQuery += "		 WHERE CODCOLIGADA = ''"+cEmpresa+"''
	cQuery += "		   AND INATIVO     = 0
	cQuery += "		   AND CODIGO      = ''"+cTurno+"''
	cQuery += "		ORDER BY CODIGO

	cQuery += " ')

	tcQuery cQuery New Alias TRL
	//

          
RETURN(NIL)   

Static Function SqlJorRM(cEmpresa,cTurno)    

	Local cTeste:= ''

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	BeginSQL Alias "TRM"
			%NoPARSER% 
			 SELECT CODHORARIO,
					INDINICIO,
					BATINICIO,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
					INDFIM,
					BATFIM,
					CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN
				FROM [VPSRV16].[CORPORERM].[DBO].[AJORHOR] WITH (NOLOCK)
				WHERE CODCOLIGADA = %EXP:cEmpresa%
				AND CODHORARIO    = %EXP:cTurno%
	 
 	EndSQl             

	*/

	TRM := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += " SELECT CODHORARIO,
	cQuery += " 	INDINICIO,
	cQuery += " 	BATINICIO,
	cQuery += " 	CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATINICIO) / 60) AS HR_INI,
	cQuery += " 	INDFIM,
	cQuery += " 	BATFIM,
	cQuery += " 	CONVERT(DECIMAL(10,2),CONVERT(NUMERIC,BATFIM) / 60) AS HR_FIN
	cQuery += " FROM [" + cSGBD + "].[DBO].[AJORHOR] AS AJORHOR WITH (NOLOCK)
	cQuery += " WHERE CODCOLIGADA = ''"+cEmpresa+"''
	cQuery += " AND CODHORARIO    = ''"+cTurno+"''

	cQuery += " ')

	tcQuery cQuery New Alias TRM
	//


RETURN(NIL) 

Static Function SqlJORNADA(cTurno)

	BeginSQL Alias "TRO"
			%NoPARSER%  
			SELECT CD_JORNADA,
			       DS_JORNADA,
			       TP_JORNADA,
			       QT_DIAS_PERIODO
			  FROM [DIMEP].[DMPACESSOII].[DBO].[JORNADA] WITH (NOLOCK) 
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
			 FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) 
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
			 FROM [DIMEP].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = %EXP:cWhere%
     	       
		
 	EndSQl             
RETURN(NIL) 

Static Function SqlTurnoFaixa(nTurno)

	BeginSQL Alias "TRR"
			%NoPARSER%  
			SELECT CD_TURNO,
			       CD_FAIXA_HORARIA
			 FROM [DIMEP].[DMPACESSOII].[DBO].[TURNO_FAIXA] WITH (NOLOCK) 
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
			  FROM [DIMEP].[DMPACESSOII].[DBO].[FAIXA_HORARIA] WITH (NOLOCK)
			 WHERE CD_FAIXA_HORARIA = %EXP:cFaixa1%
			   OR  CD_FAIXA_HORARIA = %EXP:cFaixa2%
 			 
 	EndSQl             
RETURN(NIL)

Static Function SqlJorDia(cJornada,cDia,cTurno)

	BeginSQL Alias "TRV"
			%NoPARSER% 
			 SELECT CD_JORNADA_DIA,
			        CD_JORNADA,
				    NU_DIA,
				    CD_TURNO 
			   FROM [DIMEP].[DMPACESSOII].[DBO].[JORNADA_DIA] WITH (NOLOCK) 
		      WHERE CD_JORNADA = %EXP:cJornada%
                AND NU_DIA     = %EXP:cDia%
                AND CD_TURNO   = %EXP:cTurno%
			  
			  
	EndSQl             
RETURN(NIL)

Static Function SqlVFilialDimep(nEstOrganizacional, cFil)

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
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
			  WHERE CD_ESTRUTURA_RELACIONADA = %EXP:nEstOrganizacional%
			    AND NU_ESTRUTURA             = %EXP:cFil%
                AND TP_ESTRUTURA             = '1'
                
	EndSQl             
RETURN(NIL)

Static Function SqlVEstrutura(cFilFunc,nMatricula)

	BeginSQL Alias "TSC"
			%NoPARSER% 
			SELECT ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
			        ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
			WHERE PESSOA.NU_MATRICULA = %EXP:nMatricula%
			  
	EndSQl             
RETURN(NIL)

Static Function SqlPerfilEspecifico(cEstOrganizacional,cEstOrgEmpresa,cEstRelacionada)

	BeginSQL Alias "TSD"
			%NoPARSER%
		   SELECT MAX(TX_CAMPO08) AS TX_CAMPO08
		     FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA WITH (NOLOCK)
	   	  
	EndSQl             
RETURN(NIL) 

Static Function SqlPerAc2(nPerAc)

	BeginSQL Alias "TSE"
			%NoPARSER%  
			SELECT CD_PERFIL_ACESSO,
			       NM_PERFIL_ACESSO,
			       TP_PERFIL_ACESSO,
			       FL_PUBLICO
			 FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) 
		    WHERE CD_PERFIL_ACESSO = %EXP:nPerAc%
		
 	EndSQl             
RETURN(NIL)

Static Function SqlVTur(cCPF)

    cQuery := " SELECT CD_TURNO,NU_TURNO,DS_TURNO,HR_ZERA_QTD_ACESSO  "
    cQuery += " FROM [DIMEP].[DMPACESSOII].[DBO].[TURNO]  WITH (NOLOCK) "
    cQuery += " WHERE DS_TURNO LIKE '%"+cCPF+"%' "

	TCQUERY cQuery new alias "TSF"
             
RETURN(NIL)

Static Function SqlUsuProtheus()

    BeginSQL Alias "TSG"
			%NoPARSER%  
			SELECT ZFG_CODUSR,
			       ZFG_PERFIL,
				   ZFG_EMPRES
			  FROM ZFG010 WITH (NOLOCK)
			 WHERE ZFG_PERFIL = 'T'
			   AND D_E_L_E_T_ <> '*'
		
 	EndSQl    
             
RETURN(NIL)  

Static Function SqlUsuDimep(cName)

    cQuery := " SELECT CD_USUARIO,DS_LOGIN,DS_NOME   "
    cQuery += " FROM [DIMEP].[DMPACESSOII].[DBO].[USUARIO_SISTEMA]  WITH (NOLOCK) "
    cQuery += " WHERE DS_LOGIN LIKE '%"+cName+"%' "

	TCQUERY cQuery new alias "TSH"
             
RETURN(NIL)

Static Function SqlCatracaPortaria()

	BeginSQL Alias "TSI"
			%NoPARSER%  
			SELECT CD_GRUPO,
			       CD_AREA,
			       FL_AREA_ORIGEM
			 FROM [DIMEP].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = 8
     	       		
 	EndSQl             
RETURN(NIL)

Static Function SqlDiaSemanaRM(cEmpresa,cTurno)

	Local cTeste:= ''

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	cQuery:= " SELECT [COLUNA], [VALOR] "
	cQuery+= "   FROM (SELECT CODIGO, "
	cQuery+= "	   	  (SELECT DATENAME(weekday, DATABASEHOR)    FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA1, "
	cQuery+= "	      (SELECT DATENAME(weekday, DATABASEHOR +1) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA2, "
	cQuery+= "	 	  (SELECT DATENAME(weekday, DATABASEHOR +2) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA3, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +3) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA4, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +4) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA5, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +5) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA6, "
	cQuery+= "		  (SELECT DATENAME(weekday, DATABASEHOR +6) FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO]  WHERE CODCOLIGADA = '" + cEmpresa + "' AND CODIGO = '" + cTurno + "') AS DIA7 "
	cQuery+= "   FROM [VPSRV16].[CORPORERM].[DBO].[AHORARIO] "
	cQuery+= "  WHERE CODCOLIGADA = '" + cEmpresa + "' "
	cQuery+= "	  AND CODIGO      = '" + cTurno + "' "
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

	*/

	TSJ := GetNextAlias()

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
	cQuery+= "   FROM [" + cSGBD + "].[DBO].[AHORARIO] AS AHORARIO "
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

	TCQUERY cQuery new alias TSJ 

RETURN(NIL) 

Static Function CargaTurnoDimep(nTurno,cDesc)   	      	 	  

	Local cHoraAcesso := "1904-01-01" +  "T" + '00:00:00'

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[TURNO] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_TURNO] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[TURNO_FAIXA] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[JORNADA] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_JORNADA] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[JORNADA_DIA] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO] " 
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

Static Function INTSISPERFILACESSO(nPerfilAcesso)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SIST_PERFIL_ACESSO] " 
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

Static Function INTPERUSUARIO(nPerfilAcesso,nUser)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_USUARIO_SISTEMA] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_USUARIO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nPerfilAcesso) + "'," // Credencial
	cQuery += " '"              + CVALTOCHAR(nUser)         + "' "  // Usuario Admin
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERUSUARIO: "
	EndIf        
	
RETURN(NIL)

Static Function INTPERACREGRA(nPerfilAcesso,nGRupo,nArea,nTurno,nFaixaHoraria,nFlagAusente,cJornada,nQtdAcesso)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_REGRA] " 
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

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_RESTRICAO] " 
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

STATIC FUNCTION UPDPESSOA(cCampo1,cCampo2,nCPF,nEstOrganizacional,nEstOrgEmpresa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + "'"  + cCampo2 + "'"
	cQuery += " WHERE NU_MATRICULA              = " + "" + cvaltochar(nCPF)               + "" 
    
    If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - UPDPESSOA: " 
	EndIf        
	
RETURN(NIL)      

STATIC FUNCTION UPDPESS2(cCampo1,cCampo2,cCdPessoa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE CD_PESSOA     = " + "" + cvaltochar(cCdPessoa)               + "" 

	If (TCSQLExec(cQuery) < 0) .OR. ALLTRIM(CVALTOCHAR(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UPDPESS2: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
RETURN(NIL)     

Static Function DELPERACREGRA(nPerfilAcesso)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_REGRA] " 
	cQuery += "WHERE CD_PERFIL_ACESSO = " + " '" + CVALTOCHAR(nPerfilAcesso) + "' " // CD_PERFIL_ACESSO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELPERACREGRA: "
	EndIf        
	                        
RETURN(NIL) 

Static Function DELPERRESTRICAO(nPerfilAcesso)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_RESTRICAO] " 
	cQuery += "WHERE CD_PERFIL_ACESSO = " + " '" + CVALTOCHAR(nPerfilAcesso) + "' " // CD_PERFIL_ACESSO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELPERRESTRICAO: "
	EndIf        
	                        
RETURN(NIL)           

Static Function DELPERUSSIS(nPerfilAcesso)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_USUARIO_SISTEMA] " 
	cQuery += "WHERE CD_PERFIL_ACESSO = " + " '" + CVALTOCHAR(nPerfilAcesso) + "' " // CD_PERFIL_ACESSO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELPERUSSIS: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELUSSISPER(nPerfilAcesso)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SIST_PERFIL_ACESSO] " 
	cQuery += "WHERE CD_PERFIL_ACESSO = " + " '" + CVALTOCHAR(nPerfilAcesso) + "' " // CD_PERFIL_ACESSO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELUSSISPER: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELPERFIL(nPerfilAcesso)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO] " 
	cQuery += "WHERE CD_PERFIL_ACESSO = " + " '" + CVALTOCHAR(nPerfilAcesso) + "' " // CD_PERFIL_ACESSO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELPERFIL: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELUSSIJOR(nJornada)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_JORNADA] " 
	cQuery += "WHERE CD_JORNADA = " + " '" + CVALTOCHAR(nJornada) + "' " // CD_JORNADA
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELUSSIJOR: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELJORDIA(nJornada)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[JORNADA_DIA] " 
	cQuery += "WHERE CD_JORNADA = " + " '" + CVALTOCHAR(nJornada) + "' " // CD_JORNADA
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELJORDIA: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELJORNADA(nJornada)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[JORNADA] " 
	cQuery += "WHERE CD_JORNADA = " + " '" + CVALTOCHAR(nJornada) + "' " // CD_JORNADA
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELJORNADA: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELTURFAIXA(nTurno)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[TURNO_FAIXA] " 
	cQuery += "WHERE CD_TURNO= " + " '" + CVALTOCHAR(nTurno) + "' " // CD_TURNO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELTURFAIXA: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELUSSITURNO(nTurno)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_TURNO] " 
	cQuery += "WHERE CD_TURNO= " + " '" + CVALTOCHAR(nTurno) + "' " // CD_TURNO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELUSSITURNO: "
	EndIf        
	                        
RETURN(NIL)

Static Function DELTURNO(nTurno)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[TURNO] " 
	cQuery += "WHERE CD_TURNO= " + " '" + CVALTOCHAR(nTurno) + "' " // CD_TURNO
	
	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELTURNO: "
	EndIf        
	                        
RETURN(NIL)
