#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADGPE024P
	Integracao com o sistema DIMEP de catracas Integração de Funcionarios e Caminhoneiros a partir de sql Usando o linked Server para DIMEP
	@type  Function
	@author William Costa
	@since 06/11/2019
	@version 01
	@history Chamado 045548 - William Costa   - 03/12/2018 - Ajustado Regra para pegar a empresa e filial dimep para func novos
	@history Chamado 050189 - William Costa   - 03/07/2019 - Ajuste regra de integracao de ferias onde nao estava gravando na tabela de situacao pessoa multipla, ajustado uma verificacao se o funcionario esta de ferias verificar se esta na tabela se não tiver inclui novamente.
	@history Chamado 053196 - William Costa   - 06/11/2019 - Identificado que após UPDPESSas alterações de Matricula para CPF, quando o funcionário é transferido entre empresa estava gerando erro pois as matriculas são diferentes e o CPF os mesmos então o Status do funcionário ficava demitido em uma empresa e trabalhando em outra gerando erro no Dimep.
	@history Chamado 053196 - William Costa   - 06/11/2019 - Identificado que no momento de bloquear o terceiro estava entrando errado no if quando a data é igual a vazio, bloqueando o terceiro indevidamente.
	@history Chamado 053384 - William Costa   - 14/11/2019 - Identificado que após alterar as matriculas para CPF, o update de pessoa não precisa mais ter a empresa e filial no Where pq o CPF é unico, então foi retirado para entrar corretamente.
	@history Chamado 055578 - William Costa   - 05/02/2020 - Identificado que após as alterações de Matricula para CPF, quando o funcionário é transferido entre filial estava gerando erro pois as matriculas são diferentes e o CPF os mesmos então o Status do funcionário ficava demitido em uma filial e trabalhando em outra gerando erro no Dimep.
	@history Chamado 056610 - William Costa   - 13/03/2020 - Pular quando a situacao da pessoa for 21 //Quarentena, é usado o fonte ADGPE055P para ajustar essas pessoas.
	@history Chamado 056563 - William Costa   - 19/03/2020 - Desenvolvido regra para alteração correta das alterações de centro de custo entre o Protheus e o Dimep
	@history Chamado 054962 - William Costa   - 02/04/2020 - Desenvolvido regra para bloquear o caminhoneiro quando a data da carteira de motorista tiver vencida.
	@history Chamado 054962 - William Costa   - 02/04/2020 - Foi retirado devido falha de comunicação com a Logistica e portaria e travou diversos caminhoneiros.
	@history Chamado 057980 - William Costa   - 07/05/2020 - Adicionado a catraca da portaria quando tiver novo turno, para não ocorrer problema da pessoa não conseguir passar na catracata
	@history Chamado 057940 - William Costa   - 09/06/2020 - Adicionado regra para quando o funcionario está com a empresa errada, ajustado para a empresa e o centro de custo correto.
	@history TICKET  2692 	- ADRIANO SAVOINE - 01/10/2020 - Retirado a Filial 02 fixa do codigo pois a tabela é compartilhada agora e o campo como vaziu.
	@history TICKET  2692 	- ADRIANO SAVOINE - 02/10/2020 - fixado filial 02 para conseguir inserir na estrutura DIMEP.
	@history TICKET  224    - William Costa   - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	@history ticket  39     - Fernando Macieir- 10/02/2021 - de/para no campo CODSITUACAO
	@history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history ticket  14991  - Fernando Macieir- 15/06/2021 - Dimep - Contrato de Trabalho Suspenso
	@history Ticket  15680  - Everson         - 16/06/2021 - Removido lockbyname.
	@history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
	@history Ticket  16699  - Fernando Macieir- 28/07/2021 - DIVERGENCIA NO CC NO DIMEP - CAMINHONEIROS
	@history TI             - Adriano Savoine - 21/09/2021 - Desabilitando os Caminhoneiros desse Schedule deixando somente no ADGPE067P.
	@history Ticket  55228  - Adriano Savoine - 04/10/2021 - Filtrado para vir do RM somente novos colaboradores ou Alterações efetuadas em colaboradores já cadastrados no DIMEP.
	@history Ticket  TI     - Adriano Savoine - 13/10/2021 - Tratado o Campo PIS para ficar sem nenhum espaço tanto na atualização quanto na Insersão de novos dados.
	@history Ticket  62721  - Everson         - 27/10/2021 - Melhorar o desempenho do relatório.Everson.
	@history Ticket  TI     - Everson         - 08/11/2021 - Correção de apontamento de campo da consulta sql.
	@history Ticket  66111  - Everson         - 03/01/2022 - Tratamento para filial 0A.
	@history Ticket: TI     - Adriano Savoine - 03/02/2022 - Ajustado para o Dimep verificar o demitido ao inves de 7 dias passamos para verificar 1 dia apena apos a data de demissão.
	@history Ticket: 66952  - Adriano Savoine - 15/02/2022 - Ajustado a query funcionario para atualizar os status apos a sua efetivação e ajustado novos status no dimep 24 e 25 como multiplos e ajustada a integração dos mesmos
	@history Ticket: 66952  - Fernando Macieir- 23/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar 
	@history Ticket: 66952  - Fernando Macieir- 28/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar - novo parâmetro para buscar 7 dias atrás.
	@history Ticket: 69427  - Fernando Macieir- 14/03/2022 - Nome duplicado no DIMEP
    @history TICKET: 69748  - ADRIANO SAVOINE - 16/03/2022 - Ajustado o campo credencial para ajustar igual ao RM no DIMEP com 8 caracteres no leitor de codigo de barra mas deixando que no relogio somente considere 6.
/*/
User Function ADGPE024P(aParam) // U_ADGPE024P()

	Local cHrIniAux     := Time()
	
	// @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
	Default aParam    	:= Array(2)
	Default aParam[1] 	:= "01"
	Default aParam[2] 	:= "02"
	
	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	Private cLinked 		   := "" 
	Private cSGBD   		   := "" 

	Private lFuncIntegrar      := .F. 
	Private lFuncSitFolha      := .F. 
	Private lFuncCredencial    := .F.
	Private lCamIntegrar       := .F. 
    Private	lCamSitFolha       := .F. 
	Private	lCamCredencial     := .F.     
	Private lCargFaixa         := .F. 
	Private nSitFol            := 0
	Private nSitFolMult        := 0
	Private nCdPessoa          := 0 
	Private cDataIni           := ''
	Private cDataFin           := ''                        
	Private dDtIniDimep        := CToD("  /  /  ")                       
	Private dDtFinDimep        := CToD("  /  /  ")                       
	Private nCredencial        := 0
	Private nCredMat           := 0
    Private nRep               := 0 
    Private cQuery             := '' 
    Private CcodTurno          := ''      
    Private nEstOrganizacional := 0 
    Private nEstRelacionada    := 0
    Private nEstOrgEmpresa     := 0
    Private nFlagAusente       := 0
    Private cJornada           := ''
    Private nCont              := 0  
    Private nCont1             := 0  
	Private nCont2             := 0  
    Private cBloqMot           := ''
    Private cCpfMot            := '' 
    Private cNomeMot           := '' 
    Private cRgMot             := '' 
    Private cFilMot            := ''
    Private cCcMot             := ''
    Private cFilFunc           := ''
    Private cCcFunc            := ''
	Private cCcFuncDimep       := ''
    Private nCredMot           := ''
    Private nPerfilAcesso      := 0
    Private cNomecPerfil       := ''
    Private nCredFunc          := 0   
    Private cIntregou          := ''     
    Private cTexto             := ''
    Private cNu_Estrutura      := ''
    Private nQtdAcesso         := 0
	Private nMatProth          := 0 //chamado 049598
	Private cDtVlCNH           := ''
	Private cEmpDimep          := ''
	Private nDiaSemana         := 0
	Private nHoraIni           := 0

	//Everson - 27/10/2021. Chamado 62721.
	Private oCdNXC1 		   := Nil
	Private oCdNXC2 		   := Nil
	Private oEstEmp 		   := Nil
	Private oPerfil   		   := Nil
	Private oTurno    		   := Nil
	Private oCrXPes1     	   := Nil
	Private oCrXPes2 		   := Nil
	Private oCrXPes3 		   := Nil
	Private oCdAmrCh		   := Nil
	Private oCdAmr2Ch		   := Nil
	Private oFerias 		   := Nil
	Private oAfast			   := Nil
	Private oPesXEst		   := Nil

	Private oEstOrg 		   := Nil //Estrutura por organização.
	Private oEstFil 		   := Nil //Estrutura por filial.
	Private oEstDep 		   := Nil //Estrutura por departamento.
	Private oEstFun 		   := Nil //Estrutura por funcionário.
	Private oFuDimep 		   := Nil //Funcionários.
	//
	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv(aParam[1],aParam[2],,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas	
		
		// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
		cLinked := GetMV("MV_#RMLINK",,"RM") 
		cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")

		PtInternal(1,Alltrim(PROCNAME()))
		ConOut("ADGPE024P - INICIO DO SCHEDULE ADGPE024P" + '||' + DToC(Date()) + '||' + Time() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])       

		U_ADINF009P(SUBSTRING(Alltrim(PROCNAME()),3,Len(Alltrim(PROCNAME()))) + '.PRW',SUBSTRING(Alltrim(PROCNAME()),3,Len(Alltrim(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Integração de Funcionarios e Caminhoneiros a partir de sql Usando o linked Server para DIMEP')
		
		logZBN("1") //Log início.

		// @history ticket  39     - Fernando Macieir- 10/02/2021 - de/para no campo CODSITUACAO
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
				carDados()
				DimepFuncionario()
			Else
				LS->( DbCloseArea())
			EndIf

			DimepBloqTerceiro()

		RECOVER
			
			//-> Recupera e apresenta o erro.
			ErrorBlock( bError )
			MsgStop( cError )
			
		END SEQUENCE
		
		If ValType(oEstEmp) <> "U"
			oEstEmp:Delete()
		EndIf

		If ValType(oFuDimep) <> "U"
			oFuDimep:Delete()
		EndIf
		
		If ValType(oCrXPes2) <> "U"
			oCrXPes2:Delete()
		EndIf

		logZBN("2") //Log fim.

		ConOut("ADGPE024P - FINAL DO SCHEDULE ADGPE024P" + '||' + DToC(Date()) + '||' + Time() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2] +  " Tempo Total: " + ElapTime( cHrIniAux, Time() ))
				
	RpcClearEnv() 

Return Nil

/*/{Protheus.doc} Static Function carDados
	(long_description)
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function carDados()

	Local cHrIniAux := ""

	Conout("ADGPE024P - ADGPE024P - Início carregamento oFuDimep") //Cadastro de funcionários Dimep.
		cHrIniAux := Time()
		carFuncD(.F.)
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oFuDimep - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oCdNXC1") //Credenciais Dimep.
		cHrIniAux := Time()
		carCreden()
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oCdNXC1 - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oEstOrg") //Estrutura Organizacional Dimep.
		cHrIniAux := Time()
		oEstOrg := carEstEmp()
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oEstOrg - Tempo " + ElapTime( cHrIniAux, Time() ))
	
	Conout("ADGPE024P - ADGPE024P - Início carregamento oEstFil") //Estrutura filial Dimep.
		cHrIniAux := Time()
		oEstFil := carEstFil()
	Conout("ADGPE024P - ADGPE024P - Início carregamento oEstFil - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oEstDep") //Estrutura departamento Dimep.
		cHrIniAux := Time()
		oEstDep := carEstDpt()
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oEstDep - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oPerfil") //Perfil de acesso Dimep.
		cHrIniAux := Time()
		oPerfil := carPerfil()
	Conout("ADGPE024P - ADGPE024P - Início carregamento oPerfil - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oTurno") //Turno RM.
		cHrIniAux := Time()
		oTurno := carTurno(cEmpAnt)
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oTurno - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oCrXPes1") //Credencial x Pessoa Dimep.
		cHrIniAux := Time()
		carCredXPes()
	Conout("ADGPE024P - Fim carregamento oCrXPes1 - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oCrXPes2") //Credencial x Pessoa Dimep em tabela.
		cHrIniAux := Time()
		carCredTec(.F.)
	Conout("ADGPE024P - Fim carregamento oCrXPes2 - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oCdAmrCh") //Credencial x Pessoa Dimep amarração.
		cHrIniAux := Time()
		oCdAmrCh := carChkDpCr()
	Conout("ADGPE024P - Fim carregamento oCdAmrCh - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oCdAmr2Ch") //Credencial x Pessoa Dimep amarração - tecnologia.
		cHrIniAux := Time()
		oCdAmr2Ch := carChk2DpCr()
	Conout("ADGPE024P - Fim carregamento oCdAmr2Ch - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oPesXEst") //Pessoa x Estrutura Organizacional Dimep.
		cHrIniAux := Time()
		oPesXEst := carPesXEst(cEmpAnt)
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oPesXEst - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oFerias") //Férias RM.
		cHrIniAux := Time()
		oFerias := carFerias(cEmpAnt)
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oFerias - Tempo " + ElapTime( cHrIniAux, Time() ))

	Conout("ADGPE024P - ADGPE024P - Início carregamento oAfast") //Afastamento RM.
		cHrIniAux := Time()
		oAfast := carAfast(cEmpAnt)
	Conout("ADGPE024P - ADGPE024P - Fim carregamento oAfast - Tempo " + ElapTime( cHrIniAux, Time() ))

Return Nil

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function DimepRegraDeAcesso()	

	Local cHrIni	:= Time()
	Local nCont2

	Conout("ADGPE024P - ADGPE024P - Início DimepRegraDeAcesso")

	// *** INICIO INTEGRACAO REGRA DE ACESSO *** //
	SqlTurno(cValToChar(Val(cEmpAnt)))
	
	// *** INICIO BUSCA TURNO NO PROTHEUS *** //
	TRL->( DbGoTop() )
	While TRL->(!EOF())       
	    
		lCargFaixa   := .F.    
		nFlagAusente := 0
        cJornada     := ''
        nCont        := 0
        cIntregou    := ''
        cTexto       := ''
		
		// *** INICIO VERIFICA TURNO SE JA ESTA CADASTRADO NO DIMEP *** //
		SqlVTurnoDimep(Val(cEmpAnt + TRL->CODIGO))
		
    	If TRH->(EOF()) 
	    		 
	    	CargaTurnoDimep(Val(cEmpAnt + TRL->CODIGO),Substr(TRL->DESCRICAO,1,30))
	    	
	    	TRH->(DbCloseArea())
	    	
	    	// *** INICIO Pega o codigo do turno que gerou no DIMEP *** //
	    	SqlVTurnoDimep(Val(cEmpAnt + TRL->CODIGO))
		    
	    	If TRH->(!EOF()) 
	    	
	    		INTUSUSISTURNO(TRH->CD_TURNO)	
	    		
	    		// *** INICIO VERIFICACAO JORNADA *** //
	    		SqlJorRM(cEmpAnt,TRL->CODIGO)
	    		While TRM->(!EOF())

	    			nDiaSemana := 0
                    nHoraIni   := IIF(AT('.',cValToChar(TRM->HR_INI)) == 0,TRM->HR_INI,Val(SUBSTRING(cValToChar(TRM->HR_INI),1,AT('.',cValToChar(TRM->HR_INI)) - 1) + '.' + cValToChar(Val( '0.' + SUBSTRING(cValToChar(TRM->HR_INI),AT('.',cValToChar(TRM->HR_INI)) + 1,Len(cValToChar(TRM->HR_INI)))) * 60)))
					If lCargFaixa == .F. // CARREGA TURNO FAIXA SO NA PRIMEIRA VEZ
					
						If Alltrim(TRM->CODHORARIO) = '0156' // turno gerencia
                           
							SqlFxHor('1','2')
							While TRS->(!EOF())       
				
								INTTURNOFAIXA(TRH->CD_TURNO,TRS->CD_FAIXA_HORARIA)
								
								TRS->(dbSkip())
										
							End
							TRS->(DbCloseArea())

							SqlFxHor('3','4')

						ELSEIF nHoraIni >= 12 .AND. nHoraIni <= 19.59 // turno tarde 

							SqlFxHor('3','4')

						ELSEIF nHoraIni >= 20 .AND. nHoraIni <= 23.59 //Turno Noturno 

							SqlFxHor('1','4')
                         
						ELSE	  

							SqlFxHor('1','2')

						EndIf

						While TRS->(!EOF())       
				
							INTTURNOFAIXA(TRH->CD_TURNO,TRS->CD_FAIXA_HORARIA)
							
							TRS->(dbSkip())
									
						End
						TRS->(DbCloseArea())
						
						INTJORNADA(cValToChar(Val(cEmpAnt + TRM->CODHORARIO)))
						
						SqlJORNADA(cValToChar(Val(cEmpAnt + TRM->CODHORARIO)))
						While TRO->(!EOF())       
				
							INTUSUSISJORNADA(TRO->CD_JORNADA)
							
							TRO->(dbSkip())
									
						End
						TRO->(DbCloseArea())
						
						lCargFaixa := .T. 
						
					EndIf
					// *** FINAL DIREITO A TODAS AS FAIXAS  *** //
					
		            TRM->(dbSkip())
							
				End
			    TRM->(DbCloseArea()) 
			    // *** FINAL VERIFICACAO JORNADA *** //
	    	
	    	EndIf	
			
	    	// *** Final Pega o codigo do turno que gerou no DIMEP *** //

			// *** INICIO ADICIONA O DIA DE SEMANA NA JORNADA

			SqlJORNADA(cValToChar(Val(cEmpAnt + TRL->CODIGO)))
			If TRO->(!EOF())       

				FOR nCont2 := 0 TO 7

					SqlJorDia(TRO->CD_JORNADA,nCont2,TRH->CD_TURNO) // verifica se ja existe uma jornada dia
					
					If TRV->(EOF())  

						INTJORDIA(TRO->CD_JORNADA,nCont2,TRH->CD_TURNO)
						
					EndIf
					TRV->(DbCloseArea())	

				NEXT		
			EndIf
			TRO->(DbCloseArea())	

			// *** FINAL ADICIONA O DIA DE SEMANA NA JORNADA

    	EndIf
    	TRH->(DbCloseArea())
    	
    	// *** FINAL CARREGA TURNO E JORNADA *** //
    	
    	// *** INICIO CARREGA PERFIL DE ACESSO *** //
    	SqlPerAc(cValToChar(Val(cEmpAnt + TRL->CODIGO))) 
    	
    	If TRP->(EOF())
    	
    		INTPERAC(cValToChar(Val(cEmpAnt + TRL->CODIGO))) // Integra Perfil de Acesso
    		
    		// *** INICIO GERA LOG *** //              
    		cTexto := '1 Log Turno:' + 'Cod Turno: ' + cValToChar(Val(cEmpAnt + TRL->CODIGO))
	    	GeraLog('',cTexto, 'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou))
	    	
			// *** FINAL GERA LOG *** // 
    		
    		TRP->(DbCloseArea()) 
    		
    		SqlPerAc(cValToChar(Val(cEmpAnt + TRL->CODIGO)))
    		If TRP->(!EOF())        
    		
    			INTSISPERFILACESSO(TRP->CD_PERFIL_ACESSO) // Integra Usuario Perfil de Acesso

				// *** INICIO INTEGRA GRUPO REFEITORIO *** //  	      	 	  
    			SqlGrupoArea(1)
    			While TRQ->(!EOF())
    				
    				SqlVTurnoDimep(Val(cEmpAnt + TRL->CODIGO))
		
			    	If TRH->(!EOF())  
			    	
			    		SqlTurnoFaixa(TRH->CD_TURNO)
			    		nCont := 0
			    		While TRR->(!EOF())
			    			
			    			SqlJORNADA(cValToChar(Val(cEmpAnt + TRL->CODIGO)))
			    			While TRO->(!EOF())  
			    			
			    				nCont := nCont + 1
						    
						    	If nCont == 1
						    		nFlagAusente := 1
						    		cJornada     := cValToChar(TRO->CD_JORNADA)
						    	
						    	ELSE
						    	
						    		nFlagAusente := 0
						    		cJornada     := cValToChar(TRO->CD_JORNADA)
						    	
						    	EndIf    
						    
						    	nQtdAcesso := 1
						        INTPERACREGRA(TRP->CD_PERFIL_ACESSO,TRQ->CD_GRUPO,TRQ->CD_AREA,TRH->CD_TURNO,TRR->CD_FAIXA_HORARIA,nFlagAusente,cJornada,nQtdAcesso) // Integra Perfil de Regra
						                
						        If nCont == 1
						        	INTPERRESTRICAO(TRP->CD_PERFIL_ACESSO,TRQ->CD_GRUPO,TRQ->CD_AREA) // Integra PERFIL_ACESSO_RESTRICAO	
						        EndIf						        
				    	   		
				    	   		TRO->(dbSkip())
										
						    End
						    TRO->(DbCloseArea())	
			    		    TRR->(dbSkip())
							
						End
					    TRR->(DbCloseArea()) 
			    		
			    	EndIf
    			    TRH->(DbCloseArea())                  
    			    
			    	TRQ->(dbSkip())
							
				End
			    TRQ->(DbCloseArea()) 

				// *** FINAL INTEGRA GRUPO REFEITORIO *** //

				// *** INICIO INTEGRA GRUPO CATRACA PORTARIA *** //  	      	 	  
    			SqlCatracaPortaria()
    			While TSE->(!EOF())
    				
    				SqlVTurnoDimep(Val(cEmpAnt + TRL->CODIGO))
		
			    	If TRH->(!EOF())  
						nQtdAcesso := 999
						INTPERACREGRA(TRP->CD_PERFIL_ACESSO,TSE->CD_GRUPO,TSE->CD_AREA,'NULL','NULL','0','NULL',nQtdAcesso) // Integra Perfil de Regra
						INTPERRESTRICAO(TRP->CD_PERFIL_ACESSO,TSE->CD_GRUPO,TSE->CD_AREA) // Integra PERFIL_ACESSO_RESTRICAO	
			    	EndIf
    			    TRH->(DbCloseArea())                  
    			    
			    	TSE->(dbSkip())
							
				End
			    TSE->(DbCloseArea()) 

    		EndIf            
    		TRP->(DbCloseArea()) 
    		
    	ELSE                     
    		TRP->(DbCloseArea()) 
    	EndIf 
    	
    	TRL->(dbSkip())
				
	End
	
	TRL->(DbCloseArea()) 

	//
	Conout("ADGPE024P - ADGPE024P - Fim DimepRegraDeAcesso - Tempo " + ElapTime( cHrIni, Time() ))
    
Return Nil
        
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function DimepFuncionario()	

	Local cHrIni	:= Time()
	Local cDdFCr    := ""
	Local lFerAfast	:= .F.
	Local aCredPe	:= {}
	Local nTotR		:= 0
	Local nCountR	:= 0

	Conout("ADGPE024P - ADGPE024P - Início DimepFuncionario")

	// *** INICIO BUSCA FUNCIONARIOS NO PROTHEUS *** //
	Sqlfuncionario(cValToChar(Val(cEmpAnt)))
	
	TRB->( DbGoTop() )
	nTotR := Contar("TRB","!Eof()")
	
	TRB->( DbGoTop() )
	While !TRB->(Eof())

		nCountR++

		Conout("ADGPE024P - ADGPE024P - DimepFuncionario - processando " + cValToChar(TRB->CPF) + " " + cValToChar(nCountR) + "/" + cValToChar(nTotR))      
	
		lFuncIntegrar      := .F.     
		lFuncSitFolha      := .F. 
		lFuncCredencial    := .F.
		nSitFol            := 0
		nSitFolMult        := 0
		nCdPessoa          := 0
		cDataIni           := ''
	    cDataFin           := ''  
	    dDtIniDimep        := CToD("  /  /  ")                       
	    dDtFinDimep        := CToD("  /  /  ")
	    nCredencial        := 0
	    nCredMat           := 0
        nRep               := 0     
        CcodTurno          := ''        
        nEstOrganizacional := 0
        nEstRelacionada    := 0
        nEstOrgEmpresa     := 0    
        nPerfilAcesso      := 0
        cNomecPerfil       := ''
		cFilFunc           := Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2)) //Everson - 03/01/2022. Chamado 66111.
        cCcFunc            := Alltrim(TRB->NROCENCUSTOCONT)
        nMatProth          := Val(TRB->CPF) // chamado 049598
		cEmpDimep          := ''
        //nCredFunc          := TRB->PTOCREDENCIAL  // chamado 049598
		nCredFunc          := Val(TRB->PTOCREDENCIAL)  // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
        cIntregou          := ''
        cTexto             := ''     
        nCont1             := 0 

		//Everson - 27/10/2021. Chamado 62721.
		oPesXEst:Get(Alltrim(cValToChar(nMatProth)),cCcFuncDimep)
        
		//
        cNu_Estrutura := BuscaEstrutura(cFilFunc, .F.) //Everson - 27/10/2021. Chamado 62721.
        
		//
		VEmpresaDimep(cFilFunc, cNu_Estrutura, .F.) //Everson - 27/10/2021. Chamado 62721.
		
		/////////////////////////////////////////////////////////////
		// *** INICIO VERIFICA SITUACAO DO FUNCIONARIO *** //
		/////////////////////////////////////////////////////////////
		nSitFol := 11 // trabalhando
		
		If Alltrim(TRB->CODSITUACAO) $ 'A/V/X/Z'
			nSitFol := 11 // trabalhando

		// @history Ticket: 66952  - Fernando Macieir- 22/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar 
		/*
		ElseIf Alltrim(TRB->CODSITUACAO) == 'D'	// @history ticket   39 - Fernando Macieira - 10/02/2021 - de/para no campo CODSITUACAO
			nSitFol := 12 // demitido

		ElseIf Alltrim(TRB->CODSITUACAO) == 'F'	// @history ticket   39 - Fernando Macieira - 10/02/2021 - de/para no campo CODSITUACAO
			nSitFol     := 13 // Ausencia		
			nSitFolMult := 14 // Ferias 
		*/

		ElseIf !(Alltrim(TRB->CODSITUACAO) $ 'A/V/X/D/F/Z')
			nSitFol     := 13 // Ausencia
			nSitFolMult := 15 // Afastamento

		EndIf	

		// Ticket: 66952  - Adriano Savoine - 15/02/2022
		If Alltrim(TRB->CODSITUACAO) == 'C'
			nSitFol       := 23 // C - Contrato de Trabalho Suspenso
			lFuncSitFolha := .T. 
		EndIf

		// Ticket: 66952  - Adriano Savoine - 15/02/2022
		If Alltrim(TRB->CODSITUACAO) == 'E'
			nSitFol       := 24 // E - LICENÇA MATERNIDADE
			lFuncSitFolha := .T. 
		EndIf

		// *** INICIO VERIFICA AFASTAMENTO *** //
		// Ticket: 66952  - Adriano Savoine - 15/02/2022

		// 	@history Ticket: 66952  - Fernando Macieir- 22/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar 
		If !Empty(TRB->DATADEMISSAO)
			If TRB->DATADEMISSAO < DtoS(msDate())
				nSitFol := 12 // demitido
				lFuncSitFolha := .T. 
			EndIf
		EndIf
		//

		//If Alltrim(TRB->CODSITUACAO) <> 'D'
		If nSitFol <> 12 // @history Ticket: 66952  - Fernando Macieir- 22/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar
			
			//Everson - 27/10/2021. Chamado 62721.
			lFerAfast := .F.
			aDFerAfst := {}

			// férias
			If oFerias:Get(Alltrim(cValToChar(TRB->CHAPA)), aDFerAfst) //Everson - 27/10/2021. Chamado 62721.
				lFerAfast := .T.
				lFuncSitFolha := .T. 
				nSitFol     := 13 // Ausencia		
				nSitFolMult := 14 // Ferias
			EndIf

			// afastados
			If oAfast:Get(Alltrim(cValToChar(TRB->CHAPA)),aDFerAfst) //Everson - 27/10/2021. Chamado 62721.
				lFerAfast := .T.
				lFuncSitFolha := .T. 
			EndIf

			//
			If lFerAfast //Everson - 27/10/2021. Chamado 62721.

				//nSitFol     := 13 // GERAL Ticket: 66952  - Adriano Savoine - 15/02/2022
				nSitFolMult := IIF(nSitFolMult==11,15,nSitFolMult) // Afastamento   
				cDataIni    := Substr(DToC(STOD(DTOS(aDFerAfst[2]))),1,6) + cValToChar(YEAR(aDFerAfst[2]))
				cDataIni    := IIF(Alltrim(cDataIni) <> '',cValToChar(YEAR(aDFerAfst[2])) + '-' + Substr(cDataIni,4,2)+ '-' + Substr(cDataIni,1,2) +  "T" + '00:00:00', cDataIni)
				cDataFin    := IIF(!EMPTY(aDFerAfst[3]),Substr(DToC(STOD(DTOS(aDFerAfst[3]))),1,6) + cValToChar(YEAR(aDFerAfst[3])),'')
				cDataFin    := IIF(Alltrim(cDataFin) <> '',cValToChar(YEAR(aDFerAfst[3]))+ '-' + Substr(cDataFin,4,2)+ '-' + Substr(cDataFin,1,2) +  "T" + '23:59:59', '9999-12-31')

				//
				If nSitFolMult == 0
					If Empty(aDFerAfst[3])
						nSitFolMult := 15
					ElseIf ! Empty(aDFerAfst[3]) 
						If Date() <= aDFerAfst[3]
							nSitFolMult := 15
						EndIf
					Else	
						nSitFolMult := nSitFolMult
					EndIf
				EndIf

			EndIf
			
		EndIf
		//

    	//verifica o turno do funcionario no cadastro de alteração de turno do ponto eletronico
    	CcodTurno := cValToChar(Val(cEmpAnt + TRB->CODHORARIO))
		If oTurno:Get(Alltrim(cValToChar(TRB->CHAPA)), CcodTurno) //Everson - 27/10/2021. Chamado 62721.
			CcodTurno :=  Alltrim(cValToChar(Val(cEmpAnt))) + Alltrim(cValToChar(CcodTurno))
		EndIf

		// *** INICIO VERIFICA PESSOA SE JA ESTA CADASTRADO NO DIMEP *** // // <<<<<<<<<<<<<<<<<<<<<<<<
		SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada)) // chamado 049598

		While !TRC->(Eof())
		
			nCdPessoa := TRC->CD_PESSOA
			cEmpDimep := ""
			oEstOrg:Get(TRC->CD_ESTRUTURA_ORG_EMPRESA,cEmpDimep) //Everson - 27/10/2021. Chamado 62721.

			// *** INICIO CHAMADO 056610 WILLIAM COSTA 13/03/2020
			//Pular quando a situacao da pessoa for 21 //Quarentena, é usado o fonte ADGPE055P para ajustar essas pessoas.
			If TRC->CD_SITUACAO_PESSOA == 21
				lFuncIntegrar := .F.
				TRC->(DbSkip())
				Loop
			EndIf

			// Pega o Perfil de Acesso Correto
			cNomecPerfil := ""
			oPerfil:Get(TRC->CD_PERFIL_ACESSO, cNomecPerfil) //Everson - 27/10/2021. Chamado 62721.
			
			// *** INICIO VERIFICA PESSOA *** //
			If Substr(Alltrim(TRC->NM_PESSOA),1,120) <> Substr(Alltrim(TRB->NOME),1,120)       .OR. ;
			   Val(TRC->NU_CPF)             <> Val(TRB->CPF)                 .OR. ;
			   Val(TRC->NU_RG)              <> Val(TRB->CARTIDENTIDADE)      .OR. ;
			   Val(TRC->NU_PIS)             <> Val(TRB->PISPASEP)            .OR. ;
			   Alltrim(cNomecPerfil)        <> Alltrim(CcodTurno)            .OR. ;
			   Alltrim(cNu_Estrutura)       <> Alltrim(TRB->NROCENCUSTOCONT) .OR. ;
			   Alltrim(cEmpDimep)           <> Alltrim(cEmpAnt)
			   
				lFuncIntegrar := .T.
			EndIf
			   
			// *** INICIO VERIFICA SITUACAO PESSOA AFASTAMENTO OU FERIAS *** //
			If nSitFol < 23 // Ticket: 66952  - Adriano Savoine - 15/02/2022

				If TRC->CD_SITUACAO_PESSOA <> nSitFol
					lFuncSitFolha := .T.
				EndIf  

				SqlVSitPessoaDimep(nCdPessoa)
				If nSitFol == 13 .AND. (nSitFolMult == 14 .OR. nSitFolMult == 15) .AND. TRD->(EOF()) 
					lFuncSitFolha := .T.
				EndIf
				
				While TRD->(!EOF()) 

					dDtIniDimep        := IIF(DToC(TRD->DT_INI) == '01/01/00' .AND. Alltrim(cDataIni) == '',CToD("  /  /  "),TRD->DT_INI)                      
					dDtFinDimep        := IIF(DToC(TRD->DT_FIN) == '01/01/00',CToD("  /  /  "),TRD->DT_FIN)

					If TRD->CD_SITUACAO_PESSOA <> nSitFolMult                                    .OR. ;
						dDtIniDimep             <> STOD(STRTRAN(SUBSTRING(cDataIni,1,10),'-','')) .OR. ;
						dDtFinDimep             <> STOD(STRTRAN(SUBSTRING(cDataFin,1,10),'-','')) 
					
						lFuncSitFolha := .T. 
					EndIf  
					
					TRD->(DbSkip())

				End

				TRD->(DbCloseArea()) 

			EndIf
			
			// *** INICIO VERIFICA SITUACAO PESSOA CONTRATO SUSPENSO COM AFASTAMENTO, LICENÇA MATERNIDADE *** //
			If nSitFol == 23 .OR. nSitFol == 24 //Ticket: 66952  - Adriano Savoine - 15/02/2022

				SqlVSitPessoaDimep(nCdPessoa)
				
				While TRD->(!EOF()) 

					dDtIniDimep        := IIF(DToC(TRD->DT_INI) == '01/01/00' .AND. Alltrim(cDataIni) == '',CToD("  /  /  "),TRD->DT_INI)                      
					dDtFinDimep        := IIF(DToC(TRD->DT_FIN) == '01/01/00',CToD("  /  /  "),TRD->DT_FIN)

					If TRD->CD_SITUACAO_PESSOA <> nSitFolMult                                    .OR. ;
						dDtIniDimep             <> STOD(STRTRAN(SUBSTRING(cDataIni,1,10),'-','')) .OR. ;
						dDtFinDimep             <> STOD(STRTRAN(SUBSTRING(cDataFin,1,10),'-','')) 
					
						lFuncSitFolha := .T. 
					EndIf  
					
					TRD->(DbSkip())

				End

				TRD->(DbCloseArea()) 

			EndIf


			// *** INICIO VERIFICA SITUACAO CREDENCIAL *** //

			//Everson - 27/10/2021. Chamado 62721.
	    	//Verifica se a credencial está vinculada a pessoa correta.
			cDdFCr := Nil
	    	If oCdNXC1:Get(nCredFunc, cDdFCr) //Verifica a situação credencial.

				aCredPe := {}
				If ! oCrXPes1:Get( Alltrim(cValtoChar(cDdFCr)) + Alltrim(cValtoChar(nCdPessoa)), aCredPe)
					lFuncCredencial := .T.
				Else

					If aCredPe[4] <> CToD("  /  /  ") 	//so entra se a data fim tiver valor  //Everson - 27/10/2021. Chamado 62721.

						// *** Inicio Credencial igual a Matricula *** //
						If aCredPe[4]        < Date()    .AND. ; //Everson - 27/10/2021. Chamado 62721.
							nSitFol          == 11 //trabalhando
					
							lFuncCredencial := .T. 
						EndIf

					EndIf

					TRT->(DbSkip())

				EndIf

		    EndIf	                            		
			// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE 
			// FWNM - 22/070/2021 - TICKET 17021 - Checo se o tipo de tecnologia está diferente entre CREDENCIAL e CREDENCIAL_PESSOA
			UpdTecno( TRC->CD_PESSOA, Val(TRB->CHAPA), Val(TRB->PTOCREDENCIAL) ) 
			// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
			// FWNM - 22/07/2021 - AQUI - ticket 17021 - Checo se existem 2 credenciais iguais com tecnologias diferentes
			If !lFuncCredencial
				lTpTecno13 := ChkAllCred( TRC->CD_PESSOA, Val(TRB->CHAPA), Val(TRB->PTOCREDENCIAL) )
				If lTpTecno13
					lFuncCredencial := .t.
				EndIf
			EndIf

			// FWNM - 19/07/2021 - AQUI - ticket 17021
			If !lFuncCredencial
				
				// Checo se existe amarração Credencial x Pessoa - Tecnologia 3 = Aproximação = FACE
				lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, Val(TRB->PTOCREDENCIAL))
				If lTpTecno3
					lFuncCredencial := .t.
				EndIf
				// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
				// Checo se existe amarração Credencial x Pessoa - Tecnologia 1 = Codigo Barra = REP
				lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, Val(TRB->CHAPA))
				If lTpTecno1
					lFuncCredencial := .t.
				EndIf

			EndIf

			TRC->(DbSkip())
		
		End

    	TRC->(DbCloseArea()) 
    	
    	/////////////////////////////////////////
		// *** INICIO INTEGRACAO COM DIMEP *** //
		/////////////////////////////////////////
    	If lFuncIntegrar == .F. .AND. lFuncSitFolha == .F. .AND. lFuncCredencial == .F. // Quando não existe o funcionario na DIMEP
    	    
			Conout("Criar " + cValToChar(nCountR))
    	    CargaFuncDimep()
    	    
    	Else // Quando existe o funcionario na DIMEP e houve alteracao 
			
			Conout("Alterar " + cValToChar(nCountR))
    		AlterFuncDimep() 
	    			    		
    	EndIf // fecha lFuncIntegrar == .F. .AND. lFuncSitFolha == .F.
    	// *** FINAL INSERT NO DIMEP *** //
    	
    	TRB->(DbSkip())
				
	End

	TRB->(DbCloseArea()) 

	Conout("ADGPE024P - Fim DimepFuncionario - Tempo " + ElapTime( cHrIni, Time() ))
    
    // *** FINAL BUSCA FUNCIONARIOS NO PROTHEUS *** //  
    // *****************************FINAL INTEGRACAO FUNCIONARIOS PROTHEUS x DIMEP**************************************** //	    
    
Return Nil	            
	
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function CargaFuncDimep()  
	
	cNu_Estrutura := BuscaEstrutura(cFilFunc, .F.) // chamado 049598 //Everson - 27/10/2021. Chamado 62721.
	VEmpresaDimep(cFilFunc, cNu_Estrutura, .F.) //Everson - 27/10/2021. Chamado 62721.

	// *** Inicio Verifica se existe o funcionario na tabela *** //
    SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada), .F.) // chamado 049598 //Everson - 27/10/2021. Chamado 62721.
    		
    If TRC->(EOF()) == .T. 
    
    	cNu_Estrutura := BuscaEstrutura(cFilFunc, .F.) // chamado 049598
    	VEmpresaDimep(cFilFunc, cNu_Estrutura, .F.) //Everson - 27/10/2021. Chamado 62721.
    		
    	// *** Inicio Verifica se existe a credencial na tabela *** //
    	SqlVCredencialDimep(nCredFunc)
   		If TRF->(EOF()) 
			If Val(TRB->PTOCREDENCIAL) > 0 // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
				IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
   			EndIf
			// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
   			If Alltrim(TRB->CHAPA) <> ''
	    		IntCredencial(TRB->CHAPA,nEstOrgEmpresa,'1')
	    	EndIf	
   		ELSE
   			nCredencial := TRF->CD_CREDENCIAL   
   			nRep        := TRF->CD_CREDENCIAL   
   		EndIf
    	TRF->(DbCloseArea())
    		
    	// *** INICIO CARREGA CODIGO CREDENCIAL *** //
    	If nCredencial == 0 .AND. nRep == 0
    		SqlVCredencialDimep(nCredFunc)
    			If TRF->(!EOF()) 
    				nCredencial := TRF->CD_CREDENCIAL   
    				nRep        := TRF->CD_CREDENCIAL   
    			EndIf
    		TRF->(DbCloseArea())
    	EndIf
		// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
    	// *** INICIO CARREGA CODIGO CREDENCIAL DA MATRICULA*** //
    	If nCredMat == 0 
    		SqlVCredencialDimep(Val(TRB->CHAPA))
			If TRF->(!EOF()) 
				nCredMat    := TRF->CD_CREDENCIAL   
				nRep        := TRF->CD_CREDENCIAL   
			EndIf
    		TRF->(DbCloseArea())
    	EndIf

    	TRC->(DbCloseArea())
    	
    	// Pega o Perfil de Acesso Correto
    	SqlPerAc(cCodTurno)
    	If TRP->(!EOF()) 
    		nPerfilAcesso := TRP->CD_PERFIL_ACESSO   
    	EndIf
    	TRP->(DbCloseArea())
    	
    	// Integra USuario Sistema Credencial
    	IntUsuSisCredencial(nCredencial) 
    	// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
    	If TRB->CHAPA <> ''
    		IntUsuSisCredencial(nCredMat)
    	EndIf	
    	
    	// Integra Pessoa
		//Ticket: TI - 13/10/2021 - Adriano Savoine
    	//INTPESSOA(nMatProth,TRB->NOME,nSitFol,nEstOrganizacional,nEstOrgEmpres,TRB->CPF,TRB->CARTIDENTIDADE,TRB->PISPASEP,nPerfilAcesso,nRep,nCredencial)
		INTPESSOA(nMatProth,TRB->NOME,nSitFol,nEstOrganizacional,nEstOrgEmpres,TRB->CPF,Left(AllTrim(TRB->CARTIDENTIDADE),9),Alltrim(TRB->PISPASEP),nPerfilAcesso,nRep,nCredencial) // fwnm - 19/07/2021  ticket 17021
    		                                     
    	// Verifica o numero do Funcionario
    	SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada), .T.) // chamado 049598 //Everson - 27/10/2021. Chamado 62721.
    	
		If TRC->(EOF()) 
			// *** INICIO GERA LOG *** // 
			//Everson - 03/01/2022. Chamado 66111.             
			cTexto := '6 Log Func:'                                                                                                         + ';' + ;
						' Fil: '             + Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2))                                                                                + ';' + ;
						' Mat: '             + TRB->CHAPA                                                                                    + ';' + ;
						' Nome: '            + TRB->NOME                                                                                   + ';' + ;
						' Folha: '           + cValToChar(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
						' Credencial: '      + cValToChar(nCredFunc)                                                                    + ';' + ;
						' Sit Mult: '        + IIF(nSitFolMult = 13,cValToChar(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
						' Turno:'            + CcodTurno                                                                                      + ';' + ;
						' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                  + ';' + ;
						' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                  + ';' + ;
						' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
				
			GeraLog(Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2)),cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou)) //Everson - 03/01/2022. Chamado 66111.
			// *** FINAL GERA LOG *** // 
		EndIf	
    		
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
			TRF->(DbCloseArea())
			// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
			SqlVCredencialDimep(Val(TRB->CHAPA)) // Chapa = 7 digitos = REP = Tecnologia 1 = Código Barras
			If TRF->( EOF() )
				IntCredencial(Val(TRB->CHAPA),nEstOrgEmpresa,'1')
			Else
				nRep        := TRF->CD_CREDENCIAL   
			EndIf	
			TRF->(DbCloseArea())

			//Integra Credencial e Credencial X Pessoa
			lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, nCredencial)
			If lTpTecno3
				IntCrePessoa(TRC->CD_PESSOA,nCredencial,"","") // enviar 3 = tipo tecnologia // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UpdPess1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf

			lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, nRep)
			If lTpTecno1
				IntCrePessoa(TRC->CD_PESSOA,nRep,"","") // enviar 1 = tipo tecnologia  // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UpdPess1('CD_CREDENCIAL_REP',nRep,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			// 

			/////////////////////
			/////////////////
			
			If nSitFol == 13
				//Integrar situação de pessoa multipla
				INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,nSitFolMult,cDataIni,cDataFin)	
			EndIf
	
			//Integra Historico da Pessoa
			INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin)
	
			// Integra USuario Sistema PESSOA
			INTUSUSISPESSOA(TRC->CD_PESSOA)   
					
			
			// *** INICIO GERA LOG *** // 
			//Everson - 03/01/2022. Chamado 66111.            
			cTexto := '2 Log Func:'                                                                                                         + ';' + ;
						' Fil: '             + Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2))                                                                                 + ';' + ;
						' Mat: '             + TRB->CHAPA                                                                                    + ';' + ;
						' Nome: '            + TRB->NOME                                                                                   + ';' + ;
						' Folha: '           + cValToChar(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Ause'))        + ';' + ;
						' Credencial: '      + cValToChar(nCredFunc)                                                                    + ';' + ;
						' Sit Mult: '        + IIF(nSitFolMult = 13,cValToChar(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Feri','Afas'), '') + ';' + ;
						' Turno:'            + CcodTurno                                                                                      + ';' + ;
						' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                  + ';' + ;
						' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                  + ';' + ;
						' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
					
			GeraLog(Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2)),cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou)) //Everson - 03/01/2022. Chamado 66111.
			// *** FINAL GERA LOG *** // 
		
			TRC->(dbSkip())

		End
		
		TRC->(DbCloseArea())
    		
    ELSE //caso a tabela não esteja vazia
    	TRC->(DbCloseArea())
    EndIf
    		
Return Nil

/*/{Protheus.doc} nomeStaticFunction
	// *** INTEGRACAO COM DIMEP - alteracao *** 
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AlterFuncDimep()

	// *** INICIO ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //
	cNu_Estrutura := BuscaEstrutura(cFilFunc, .F.)
	VEmpresaDimep(cFilFunc, cNu_Estrutura, .F.)
	
	SqlVFuncDimep(nMatProth,cValtoChar(nEstOrganizacional),cValtoChar(nEstOrgEmpresa),cValtoChar(nEstRelacionada), .F.)
    If TRC->(!EOF()) 
        
        // *** INICIO ALTERACAO CADASTRAL *** //
		If lFuncIntegrar == .T. 
		
			If Alltrim(cCcFuncDimep) <> Alltrim(TRB->NROCENCUSTOCONT)
			
				VEmpresaDimep(cFilFunc, cCcFunc, .T.)
				UpdPessoa('CD_ESTRUTURA_ORG_EMPRESA',cValToChar(nEstOrgEmpresa),nMatProth,TRC->CD_ESTRUTURA_ORG_EMPRESA,nEstOrgEmpresa)
				UpdPessoa('CD_ESTRUTURA_ORGANIZACIONAL',cValToChar(nEstOrganizacional),nMatProth,TRC->CD_ESTRORG,nEstOrgEmpresa)
				cNu_Estrutura := BuscaEstrutura(cFilFunc, .T.)
			    VEmpresaDimep(cFilFunc,cNu_Estrutura, .T.)
			    
			EndIf
			
			If Substr(TRC->NM_PESSOA,1,30) <> Substr(TRB->NOME,1,30)
				UpdPessoa('NM_PESSOA',TRB->NOME,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			
			If Val(TRC->NU_CPF) <> Val(TRB->CPF)
				UpdPessoa('NU_CPF',TRB->CPF,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			
			If Val(TRC->NU_RG) <> Val(TRB->CARTIDENTIDADE)
				UpdPessoa('NU_RG',TRB->CARTIDENTIDADE,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			
			// Ticket: TI - 13/10/2021 - ADRIANO SAVOINE
			If Val(TRC->NU_PIS) <> Val(TRB->PISPASEP)
				UpdPessoa('NU_PIS',Alltrim(TRB->PISPASEP),nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			
			If Alltrim(cNomecPerfil) <> Alltrim(CcodTurno)

				If Alltrim(cNomecPerfil) <> Alltrim(TRC->TX_CAMPO08)

					// Pega o Perfil de Acesso Correto
					SqlPerAc(cCodTurno)
					If TRP->(!EOF())
						UpdPess2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,nCdPessoa) 
						UpdPess2('CD_PERFIL_ACESSO',TRP->CD_PERFIL_ACESSO,nCdPessoa)
					EndIf
					TRP->(DbCloseArea())

				EndIf	

			EndIf

			If cEmpDimep <> cEmpAnt

				//Ajusta Centro de Custo do Funcionario
				VEmpresaDimep(cFilFunc, cCcFunc, .T.)
				UpdPessoa('CD_ESTRUTURA_ORG_EMPRESA',cValToChar(nEstOrgEmpresa),nMatProth,TRC->CD_ESTRUTURA_ORG_EMPRESA,nEstOrgEmpresa)
				UpdPessoa('CD_ESTRUTURA_ORGANIZACIONAL',cValToChar(nEstOrganizacional),nMatProth,TRC->CD_ESTRORG,nEstOrgEmpresa)
				cNu_Estrutura := BuscaEstrutura(cFilFunc, .T.)
			    VEmpresaDimep(cFilFunc, cNu_Estrutura, .T.)

			EndIf
			
		EndIf // lFuncIntegrar == .T. 
		
		// *** FINAL ALTERACAO CADASTRAL *** //
		

		///////////////////////////////////////////////////
		// *** INICIO SITUACAO FOLHA *** //
		///////////////////////////////////////////////////
		If lFuncSitFolha == .T.

			// @history Ticket: 66952  - Fernando Macieir- 23/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar 
			If TRC->CD_SITUACAO_PESSOA <> nSitFol

				DELSITPESSOAMULTIPLA(cValToChar(TRC->CD_PESSOA)) //Deleta Pessoa Multipla
				UpdPess1('CD_SITUACAO_PESSOA',nSitFol,nMatProth,nEstOrganizacional,nEstOrgEmpresa) //ALTERA SITUACAO DA FOLHA

				// Afastamentos e férias
				If oAfast:nStatus >= 1 .or. oFerias:nStatus >= 1
					INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,nSitFolMult,cDataIni,cDataFin) //Integrar situação de pessoa multipla
				EndIf

				INTHISTSITPESSOA(TRC->CD_PESSOA,nSitFol,cDataIni,cDataFin) //Integra Historico da Pessoa

			EndIf
			//

		EndIf
		
		// *** INICIO CREDENCIAL *** //
		If lFuncCredencial == .T.

			nCont1 := 0		     
			SqlTodaCredencial(TRC->CD_PESSOA)
			//cTSACrd := ""
			//oCrXPes3:Get(Alltrim(cValToChar(TRC->CD_PESSOA)), cTSACrd)
			While TSA->(!EOF())
				
				SqlBuscaCredencialDimep(TSA->CD_CREDENCIAL)
		   		If TRU->(!EOF()) 

					If Val(TRB->CHAPA)    <> TRU->NU_CREDENCIAL .OR. ;
						Val(TRB->PTOCREDENCIAL) <> TRU->NU_CREDENCIAL // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
		   		             
		   		        // QUANDO O CRACHA TA DIFERENTE DA CREDENCIAL
		   				If Val(TRB->CHAPA) <> TRU->NU_CREDENCIAL .AND. ;
		   				   Len(TRB->CHAPA) == Len(Alltrim(cValToChar(TRU->NU_CREDENCIAL)))
		   				    
		   					DelCredPessoa(cValToChar(TRU->CD_CREDENCIAL))
					   		DelUsuSisCredencial(cValToChar(TRU->CD_CREDENCIAL))
					   		
					   		IntCredencial(TRB->CHAPA,nEstOrgEmpresa,'1')
					    
						    SqlVCredencialDimep(TRB->CHAPA)
					   		If TRF->(!EOF()) 
					    				
					   			nCredencial := TRF->CD_CREDENCIAL   
					   			nRep        := TRF->CD_CREDENCIAL   
					   			
					   		EndIf
					    	TRF->(DbCloseArea())
						    
						    IntUsuSisCredencial(nCredencial)
							IntCrePessoa(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
							//ALTERA SITUACAO DA FOLHA
						    //UpdPess1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
						    UpdPess1('CD_CREDENCIAL_REP',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							DelCredencial(cValToChar(TRU->CD_CREDENCIAL))	
							
						EndIf   
		   		         // TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE    
						// QUANDO A CREDENCIAL DO FUNCIONARIO TA DIFERENTE DA CREDENCIAL DIMEP
						If Val(TRB->PTOCREDENCIAL)      <> TRU->NU_CREDENCIAL .AND. ;
							Val(TRB->CHAPA) <> TRU->NU_CREDENCIAL

							DelCredPessoa(cValToChar(TRU->CD_CREDENCIAL))
							DelUsuSisCredencial(cValToChar(TRU->CD_CREDENCIAL))
							
							//IntCredencial(TRB->PTOCREDENCIAL,nEstOrgEmpresa,'3')
							IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
						
							//SqlVCredencialDimep(TRB->PTOCREDENCIAL)
							SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
							If TRF->(!EOF()) 
										
								nCredencial := TRF->CD_CREDENCIAL   
								nRep        := TRF->CD_CREDENCIAL   
								
							EndIf
							TRF->(DbCloseArea())
							
							IntUsuSisCredencial(nCredencial)
							IntCrePessoa(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
							//ALTERA SITUACAO DA FOLHA
							UpdPess1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
						
						EndIf
					EndIf

					// *** Inicio Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** //
					If nMatProth == TRU->NU_CREDENCIAL

						SqlVCredencialDimep(nMatProth)
				   		If TRF->(!EOF()) 
				   		
				   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
				   			While TRT->(!EOF()) 
				   				
				   				If TRT->DT_FIM <> CToD("  /  /  ") 	//so entra se a data fim tiver valor  
				   				
					   				If TRF->NU_CREDENCIAL == nMatProth .AND. ;
					   				   TRT->DT_FIM         < Date()    .AND. ;
					   				   nSitFol            == 11 //trabalhando
						   		
							   			UpdCredPes("DT_FIM",TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
							   			UpdPess1('CD_CREDENCIAL_REP',TRF->CD_CREDENCIAL,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							   			
								    EndIf          
							    EndIf
							    TRT->(dbSkip())
							End
							TRT->(DbCloseArea()) 
				   		EndIf
				    	TRF->(DbCloseArea()) 
				    EndIf	
					
				    //If TRB->PTOCREDENCIAL == TRU->NU_CREDENCIAL
					If Val(TRB->PTOCREDENCIAL) == TRU->NU_CREDENCIAL // @history ticket  13791  - Fernando Macieir- 11/05/2021 - Migração informação Protheus e Dimep.
				    	
				    	SqlVCredencialDimep(nCredFunc)
				   		If TRF->(!EOF()) 
				   		
				   			SqlCredPessoa(TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
				   			While TRT->(!EOF()) 
				   				
				   				If TRT->DT_FIM <> CToD("  /  /  ") 	//so entra se a data fim tiver valor  
				   				
					   				If TRF->NU_CREDENCIAL <> nMatProth .AND. ;
					   				   TRT->DT_FIM         < Date()    .AND. ;
					   				   nSitFol            == 11 //trabalhando
						   		
							   			UpdCredPes("DT_FIM",TRF->CD_CREDENCIAL,TRC->CD_PESSOA)
							   			UpdPess1('CD_CREDENCIAL_FACE',TRF->CD_CREDENCIAL,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
							   			
								    EndIf          
							    EndIf
							    TRT->(dbSkip())
							End
							TRT->(DbCloseArea()) 
				   		EndIf
				    	TRF->(DbCloseArea()) 
				    EndIf	
				    // *** Final Se o funcionario estiver trabalho e a credencial tiver com data final libera a data da credencial *** // 
				EndIf
		    	TRU->(DbCloseArea()) 
		    	nCont1 := nCont1 + 1 
		    	TSA->(dbSkip())	
			End
	    	TSA->(DbCloseArea()) 
	    	// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE    
	    	// *** INICIO QUANDO VAI ADICIONAR O SEGUNDO CARTAO QUE SO TEM O DA MATRICULA *** //
	    	If (nCont1 == 0 .OR.; 
			   nCont1  == 1) .AND. ;
			   Len(Alltrim(cValToChar(Val(TRB->PTOCREDENCIAL)))) > 8
	    	
	    	    //SIGNIFICA QUE SO TEM A CREDENCIAL DE MATRICULA
	    	    //ADICIONANDO A CREDENCIAL DE NUMERO DE FABRICACAO
	    	    
	    		//IntCredencial(TRB->PTOCREDENCIAL,nEstOrgEmpresa,'3')
				IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') // ticket 13791 - FWNM - 11/05/2021
					    
			    //SqlVCredencialDimep(TRB->PTOCREDENCIAL)
				SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // ticket 13791 - FWNM - 11/05/2021
		   		If TRF->(!EOF()) 
		    				
		   			nCredencial := TRF->CD_CREDENCIAL   
		   			nRep        := TRF->CD_CREDENCIAL   
		   			
		   		EndIf
		    	TRF->(DbCloseArea())
			    
			    IntUsuSisCredencial(nCredencial)
				IntCrePessoa(TRC->CD_PESSOA,nCredencial,cDataIni,cDataFin) 
				UpdPess1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			    
			EndIf 
		
		EndIf //lFuncCredencial == .T.

		// fwnm - ticket 17021 - 19/07/2021

		//Integra Credencial 
    	nCredencial := 0
		nRep        := 0
		SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // Credencial = 10 digitos = PTOCREDENCIAL = Tecnologia 3 = Proximidade
   		If TRF->( EOF() )
			IntCredencial(Val(TRB->PTOCREDENCIAL),nEstOrgEmpresa,'3') 
			// apos inclusao
			TRF->(DbCloseArea())
			SqlVCredencialDimep(Val(TRB->PTOCREDENCIAL)) // Credencial = 10 digitos = PTOCREDENCIAL = Tecnologia 3 = Proximidade
			If TRF->( !EOF() )
				nCredencial := TRF->CD_CREDENCIAL   
			EndIf
		Else
   			nCredencial := TRF->CD_CREDENCIAL   
		EndIf
		TRF->(DbCloseArea())
		// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
		SqlVCredencialDimep(Val(TRB->CHAPA)) // Chapa = 7 digitos = REP = Tecnologia 1 = Código Barras
   		If TRF->( EOF() )
	    	IntCredencial(Val(TRB->CHAPA),nEstOrgEmpresa,'1')
			// Após inclusão
			TRF->(DbCloseArea())
			SqlVCredencialDimep(Val(TRB->CHAPA)) // Chapa = 7 digitos = REP = Tecnologia 1 = Código Barras
			If TRF->( !EOF() )
				nRep        := TRF->CD_CREDENCIAL   
			EndIf
		Else
   			nRep        := TRF->CD_CREDENCIAL   
	    EndIf	
    	TRF->(DbCloseArea())

		//Integra Credencial e Credencial X Pessoa
		If nRep <> nCredencial
			lTpTecno3 := GetCredenc("3", TRC->CD_PESSOA, Val(TRB->PTOCREDENCIAL))
			If lTpTecno3
				IntCrePessoa(TRC->CD_PESSOA,nCredencial,"","") // enviar 3 = tipo tecnologia // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UpdPess1('CD_CREDENCIAL_FACE',nCredencial,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
			// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
			lTpTecno1 := GetCredenc("1", TRC->CD_PESSOA, Val(TRB->CHAPA))
			If lTpTecno1
				IntCrePessoa(TRC->CD_PESSOA,nRep,"","") // enviar 1 = tipo tecnologia  // fwnm - 19/07/2021 - @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				UpdPess1('CD_CREDENCIAL_REP',nRep,nMatProth,nEstOrganizacional,nEstOrgEmpresa)
			EndIf
		EndIf
		// 

		///////
		
		// *** INICIO GERA LOG *** //
		//Everson - 03/01/2022. Chamado 66111.
		cTexto := '4 Log Func:'                                                                                                        + ';' + ;
			      ' Fil: '             + Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2))                                                                                + ';' + ;
				  ' Mat: '             + TRB->CHAPA                                                                                   + ';' + ;
				  ' Nome: '            + TRB->NOME                                                                                  + ';' + ;
				  ' Folha: '           + cValToChar(nSitFol) + ' ' + IIF(nSitFol == 11,'Traba',IIF(nSitFol == 12,'Demi','Aus'))        + ';' + ;
				  ' Credencial: '      + cValToChar(nCredFunc)                                                                       + ';' + ;
				  ' Sit Mult: '        + IIF(nSitFolMult = 13,cValToChar(nSitFolMult) + ' ' + IIF(nSitFolMult == 14,'Fer','Afas'), '') + ';' + ;
				  ' Turno:'            + CcodTurno                                                                                     + ';' + ;
				  ' lFuncIntegrar: '   + TRANSFORM(lFuncIntegrar,"@!")                                                                 + ';' + ;
				  ' lFuncSitFolha: '   + TRANSFORM(lFuncSitFolha,"@!")                                                                 + ';' + ;
				  ' lFuncCredencial: ' + TRANSFORM(lFuncCredencial,"@!") 
		
		GeraLog(Iif(STRZERO(TRB->CODFILIAL,2) == "10", "0A", STRZERO(TRB->CODFILIAL,2)), cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou)) //Everson - 03/01/2022. Chamado 66111.
		// *** FINAL GERA LOG *** // 
		
		// *** FINAL CREDENCIAL *** //
	EndIf

    TRC->(DbCloseArea())     
    	    
    // *** FINAL ALTERAR DADOS NO DIMEP PARA INCLUIR NOVOS *** //   

Return Nil

Static Function GeraLog(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE024P" 
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
Return Nil
     
Static Function VEmpresaDimep(cFil, cCC, lReload)

	//Variáveis.
	Local cEstFil:= ""
	Local aDados := {}

	// *** INICIO VERIFICA ESTRUTURA ORGANZACIONAL DO DIMEP *** //
    SqlVEmpresaDimep(cEmpAnt, lReload)	
    If ! TMPTRI->(Eof()) 
    	nEstOrgEmpresa := TMPTRI->ESTRUTURA
    				
    EndIf
    		 
    If nEstOrgEmpresa > 0 

		If lReload
			oEstFil := carEstFil()

		EndIf  

		If oEstFil:Get(Alltrim(cValToChar(nEstOrgEmpresa)) + Alltrim(cValToChar(cFil)), cEstFil) 

			If lReload
				oEstDep := carEstDpt()
				
			EndIf  

			If oEstDep:Get(Alltrim(cValToChar(cEstFil)) + Alltrim(cValToChar(cCc)), aDados)
	    		nEstOrganizacional := aDados[1]
	    		nEstRelacionada    := aDados[7]

			Else
	    		Conout("ADGPE024 - Erro - VEmpresaDimep - oEstDep")

	    	EndIf

		Else
    		Conout("ADGPE024 - Erro - VEmpresaDimep - oEstFil")

    	EndIf
    		
    EndIf
    		
    // *** FINAL VERIFICA ESTRUTURA ORGANZACIONAL DO DIMEP *** //  
    
Return Nil          

Static Function DimepBloqTerceiro()

	Local cHrIniAux		  := Time()
	Local dVenccAso       := NIL
	Local dVencIntegracao := NIL
	Local dVencContrato   := NIL
	Local nTotReg 		  := 0	
	Local nAux			  := 0

	Conout("ADGPE024P - ADGPE024P - Início DimepBloqTerceiro")
	
	SqlBloqTerceiro() 
	nTotReg := Contar("TSB","!Eof()")  
	TSB->( DbGoTop())        
	While TSB->(!EOF())

		nAux++
		Conout("ADGPE024P - ADGPE024P - DimepBloqTerceiro " + cValToChar(nAux) + "/" + cValToChar(nTotReg))
		Conout("ADGPE024P - ADGPE024P - DimepBloqTerceiro - processando " + cValToChar(TSB->NU_CPF))
	
		dVenccAso       := STOD(STRTRAN(Substr(TSB->TX_CAMPO01,1,10),'-',''))
		dVencIntegracao := STOD(STRTRAN(Substr(TSB->TX_CAMPO02,1,10),'-',''))
		dVencContrato   := STOD(STRTRAN(Substr(TSB->TX_CAMPO03,1,10),'-',''))
	    
	    If DToC(dVenccAso) <> "  /  /  " .AND. dVenccAso < Date()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UpdPess1('CD_SITUACAO_PESSOA',16,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		                                                       
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,16,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '7 Log DimepBloqTerceiro Aso:'                       + ';' + ;
		              ' Mat: '             + cValToChar(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + Alltrim(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DToC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DToC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DToC(dVencContrato)           + ';' 
				      
			GeraLog('02',cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    EndIf
	    
	    If DToC(dVencIntegracao) <> "  /  /  " .AND. dVencIntegracao < Date()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UpdPess1('CD_SITUACAO_PESSOA',17,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		    
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,17,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '8 Log DimepBloqTerceiro Integracao:'                + ';' + ;
		              ' Mat: '             + cValToChar(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + Alltrim(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DToC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DToC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DToC(dVencContrato)           + ';' 
				      
			GeraLog('02',cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    EndIf
	    
	    If DToC(dVencContrato) <> "  /  /  " .AND. dVencContrato < Date()
	    
	    	//ALTERA SITUACAO DA FOLHA
		    UpdPess1('CD_SITUACAO_PESSOA',18,TSB->NU_MATRICULA,TSB->CD_ESTRUTURA_ORGANIZACIONAL,TSB->CD_ESTRUTURA_ORG_EMPRESA )
		    
		    //Integra Historico da Pessoa
			INTHISTSITPESSOA(TSB->CD_PESSOA,18,cDataIni,cDataFin)
			
			// *** INICIO GERA LOG *** //              
			cTexto := '9 Log DimepBloqTerceiro Contrato:'                  + ';' + ;
		              ' Mat: '             + cValToChar(TSB->NU_MATRICULA) + ';' + ;
		              ' Nome: '            + Alltrim(TSB->NM_PESSOA)       + ';' + ;
		              ' dVenccAso: '       + DToC(dVenccAso)               + ';' + ;
				      ' dVencIntegracao: ' + DToC(dVencIntegracao)         + ';' + ;
				      ' dVencContrato: '   + DToC(dVencContrato)           + ';' 
				      
			GeraLog('02',cTexto,'Integrou: ' + IIF(Alltrim(cIntregou)== '', 'OK',cIntregou))
			// *** FINAL GERA LOG *** // 	
	    
	    EndIf
	    	    
	    TSB->(dbSkip())	
	End
	TSB->(DbCloseArea())

	Conout("ADGPE024P - ADGPE024P - Fim DimepBloqTerceiro - Tempo " + ElapTime( cHrIniAux, Time() ))

Return Nil

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
	                          
	If cStatus == '1' //se status igual a 1 inicio
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE024P')) //procura o registro
	        // se achou faz o calculo
			nQuantAtual := ZBN->ZBN_QTDVEZ + 1
			
			If nQuantAtual <> nTotVezes // verifica as quantidades de tempo
			    // se for diferente faz uma conta
				dDtProx     := dDataBase
				
				If nQuantAtual == 1
				    //se for a primeira vez ve pela hora inicial
					cHoraProx   := cHoraSegunda
				
				ELSE
					//se for a segunda em diante vez ve pela hora proxima
					cHoraProx   := cValToChar(SomaHoras( ZBN->ZBN_HORAPR , '00:' + cTempo))
					cHoraProx   := IIF(Len(Substr(cHoraProx, At(".", cHoraProx) + 1, Len(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
					cHoraProx   := STRTRAN(cHoraProx,'.',':') + ':00'
				
				EndIf
				If At(":", cHoraProx) == 2 //significa que a hora e menor que meio dia vamos acrescentar um zero a esquerda
				
					cHoraProx   := '0' + cHoraProx
									
				EndIf
			
			ELSE                               
			    // se for igual grava o proximo dia
			    nQuantAtual := 1
				dDtProx     := dDataBase + 1
				cHoraProx   := cHoraIni
			
			EndIf
			
	    ELSE 
	                 
	        // se nao achou e pq e a primeira vez do dia que esta rodando
	    	nQuantAtual := 1         
	    	dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
	    
	    EndIf                       
	    ZBN->(DbCloseArea())
	    
	ELSE // se o status for igual a 2          
	    
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE024P'))
		    // se achou grava o que ja esta calculado
			nQuantAtual := ZBN->ZBN_QTDVEZ
			dDtProx     := ZBN->ZBN_DATAPR
			cHoraProx   := ZBN->ZBN_HORAPR
			
		ELSE
		    // se nao achou grava a segunda vez
			nQuantAtual := 1
			dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
			
		EndIf                       
	    ZBN->(DbCloseArea())	
	
	EndIf
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE024P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE024P'
			ZBN_DESCRI  := 'Integração PROTHEUS X DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
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
			ZBN_ROTINA	:= 'ADGPE024P'
			ZBN_DESCRI  := 'Integração PROTHEUS X DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := Time()
			ZBN_PERIOD  := '30 MIN - 22 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:15:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(DbCloseArea())
		
	RestArea(aArea)

Return Nil

Static Function BuscaEstrutura(cFilFunc, lReload)  //Everson - 27/10/2021. Chamado 62721.

	Local cRet 		:= ""  //Everson - 27/10/2021. Chamado 62721.
	Local cEstFil	:= ""
	Local aDados	:= {}
	
	SqlVEmpresaDimep(cEmpAnt, lReload) //Busca empresa Protheus x Dimep.
    If ! TMPTRI->(Eof()) 	
    	nEstOrgEmpresa := TMPTRI->ESTRUTURA   
    				
    EndIf
    		 
    If nEstOrgEmpresa > 0 

		If lReload
			oEstFil := carEstFil()

		EndIf  
	
		If oEstFil:Get(Alltrim(cValToChar(nEstOrgEmpresa)) + Alltrim(cValToChar(cFilFunc)), cEstFil)

			If lReload
				oEstDep := carEstDpt()
				
			EndIf  

			If oEstDep:Get(Alltrim(cValToChar(cEstFil)) + Alltrim(cValToChar(cCcFunc)), aDados)
				nEstOrganizacional := aDados[1]
				nEstRelacionada    := aDados[7]
				cRet               := aDados[2]

			Else
				Conout("ADGPE024 - Erro - BuscaEstrutura - oEstDep")

			EndIf

		Else
			Conout("ADGPE024 - Erro - BuscaEstrutura - oEstFil")

    	EndIf
    		
    EndIf
	
Return cRet

Static Function BUSCACCDIMEP(nMatricula)

	Local cRet := ''

	SqlCCDIMEP(nMatricula)
		
	While TSI->(!EOF())
						
		cRet := TSI->NU_ESTRUTURA
		
		TSI->(dbSkip())
	End
	TSI->(DbCloseArea())

Return cRet

Static Function BUSCAEMPDIMEP(cEmpDimep)

	Local cEmpresa   := ''

	SqlEMP1(cEmpDimep)
		
	While TSF->(!EOF())
						
		cEmpresa := Alltrim(TSF->NU_ESTRUTURA)
		
		TSF->(dbSkip())
	End
	TSF->(DbCloseArea())

Return cEmpresa

/*/{Protheus.doc} Sqlfuncionario
	Query principal para processar as atualizações no DIMEP
	@type  Static Function
	@author user
	@since 28/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Sqlfuncionario(cEmpresa) 

	Local nDias := GetMV("MV_#RMDIAS",,30) // @history Ticket: 66952  - Fernando Macieir- 28/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar - novo parâmetro para buscar 7 dias atrás

	TRB := GetNextAlias()
	
	//@history Ticket: 66952  - Adriano Savoine - 15/02/2022 - Ajustado a query funcionario para atualizar os status apos a sua efetivação e ajustado novos status no dimep 24 e 25 como multiplos e ajustada a integração dos mesmos.
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
	cQuery += "				CONVERT(VARCHAR(8), DATADEMISSAO, 112) DATADEMISSAO,
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

	//Ticket: TI - 03/02/2022 - Adriano Savoine
	//cQuery += "				AND PFUNC.DATADEMISSAO                             <= GETDATE() " // debug - inibir 
	cQuery += "				AND (PFUNC.DATADEMISSAO                             >= GETDATE()-"+Str(nDias)+" " // debug - voltar 
	cQuery += "				OR  PFUNC.DATADEMISSAO                              IS NULL) " // debug - voltar 
	
	// @history Ticket: 66952  - Fernando Macieir- 21/02/2022 - Filtro da query não trazia funcionários para poder integrar/atualizar 
	//Ticket: 55228 - 04/10/2021 - Adriano Savoine INICIO
	/*
	cQuery += "				AND ((PFUNC.RECCREATEDON >= GETDATE()   
	cQuery += "				OR  PFUNC.RECMODIFIEDON >= GETDATE() )
	cQuery += "				OR (PPESSOA.RECMODIFIEDON >= GETDATE() - 1
	cQuery += "				OR PFCOMPL.RECMODIFIEDON >= GETDATE() - 1))
	*/
	// DEBUG - INIBIR
	//cQuery += " AND PPESSOA.CPF=''47189416870''
	//Ticket: 55228 - 04/10/2021 - Adriano Savoine FIM
	//

	cQuery += "				AND PFUNC.PISPASEP                                  NOT IN (SELECT TOP(1) PFUNC2.PISPASEP FROM [" + cSGBD + "].[DBO].[PFUNC] PFUNC2 WHERE PFUNC2.PISPASEP = PFUNC.PISPASEP AND PFUNC2.CODCOLIGADA <> PFUNC.CODCOLIGADA AND PFUNC2.CODSITUACAO <> ''D'')

	cQuery += "			ORDER BY PPESSOA.CPF

	cQuery += " ')

	tcQuery cQuery New Alias TRB
	//

Return Nil   	  

Static Function SqlVFuncDimep(cMat,cEstOrganizacional,cEstOrgEmpresa,cEstRelacionada, lReload)
	
	Local cQuery  := ""
	Local cTabela := oFuDimep:GetRealName()

	//
	If Select("TRC") > 0
		TRC->(DbCloseArea())

	EndIf

	//
	cQuery := " SELECT TOP(1) "
	cQuery += " CD_PESSOA, "
	cQuery += " NUMATRICUL AS NU_MATRICULA, "
	cQuery += " NM_PESSOA, "
	cQuery += " CDSITPESSO   AS CD_SITUACAO_PESSOA, "
	cQuery += " CD_ESTRORG, "
	cQuery += " CDESTORGEM   AS CD_ESTRUTURA_ORG_EMPRESA, "
	cQuery += " NU_CPF, "
	cQuery += " NU_RG, "
	cQuery += " NU_PIS, "
	cQuery += " CDPERACESS   AS CD_PERFIL_ACESSO, "
	cQuery += " CDCREDFACE   AS CD_CREDENCIAL_FACE, "
	cQuery += " CDCREDREP    AS CD_CREDENCIAL_REP, "
	cQuery += " TXCAMPO      AS TX_CAMPO08 "	
	cQuery += " FROM " + cTabela + " WHERE NUMATRICUL = " + Alltrim(cValtoChar(cMat)) + " "		

	TcQuery cQuery New Alias "TRC"
	TRC->(DbGoTop())

Return Nil

Static Function carFuncD(lReload)

	Local aStru  := {}

	//Everson - 27/10/2021. Chamado 62721.
	If ValType(oFuDimep) <> "U" .And. lReload
		oFuDimep:Delete()

	ElseIf ValType(oFuDimep) <> "U" .And. ! lReload
		DbSelectArea("TMPTRC")
		TMPTRC->(DbGoTop())
		Return Nil

	EndIf

	//Everson - 27/10/2021. Chamado 62721.
	aAdd(aStru,{"CD_PESSOA"   , "N",20,0})
	aAdd(aStru,{"NUMATRICUL"  , "N",20,0})
	aAdd(aStru,{"NM_PESSOA"   , "C",100,0})
	aAdd(aStru,{"CDSITPESSO"  , "N",20,0})
	aAdd(aStru,{"CD_ESTRORG"  , "N",20,0})
	aAdd(aStru,{"CDESTORGEM"  , "N",20,3})
	aAdd(aStru,{"NU_CPF"      , "C",15,0})
	aAdd(aStru,{"NU_RG"       , "C",20,2})
	aAdd(aStru,{"NU_PIS"      , "C",15,0})
	aAdd(aStru,{"CDPERACESS"  , "N",20,0})
	aAdd(aStru,{"CDCREDFACE"  , "N",20,0})
	aAdd(aStru,{"CDCREDREP"   , "N",20,0})
	aAdd(aStru,{"TXCAMPO"     , "C",20,0})

	//Everson - 27/10/2021. Chamado 62721.
	oFuDimep := FWTemporaryTable():New("TMPTRC")
	oFuDimep:SetFields(aStru)
	oFuDimep:AddIndex("01", {"NUMATRICUL"})

	//
	oFuDimep:Create()
	DbSelectArea("TMPTRC")

	//Everson - 27/10/2021. Chamado 62721.
	If Select("DADOS_FUNC") > 0
		DADOS_FUNC->(DbCloseArea())

	EndIf

	BeginSQL Alias "DADOS_FUNC"
		%NoPARSER%
		SELECT
			CD_PESSOA,
			NU_MATRICULA,
			NM_PESSOA,
			CD_SITUACAO_PESSOA,
			PESSOA.CD_ESTRUTURA_ORGANIZACIONAL AS CD_ESTRORG,
			CD_ESTRUTURA_ORG_EMPRESA,
			NU_CPF,
			NU_RG,
			NU_PIS,
			CD_PERFIL_ACESSO,
			CD_CREDENCIAL_FACE,
			CD_CREDENCIAL_REP,
			TX_CAMPO08 
		FROM 
			[DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA WITH (NOLOCK)
		//WHERE NU_CPF='05452774696' // DEBUG - INIBIR
		ORDER BY
			NU_MATRICULA
	EndSQl

	DADOS_FUNC->(DbGoTop())
	While ! DADOS_FUNC->(Eof())

		//
		DbSelectArea("TMPTRC")
		RecLock("TMPTRC", .T.)
		    Replace TMPTRC->CD_PESSOA         With DADOS_FUNC->CD_PESSOA
			Replace TMPTRC->NUMATRICUL        With DADOS_FUNC->NU_MATRICULA
			Replace TMPTRC->NM_PESSOA	      With DADOS_FUNC->NM_PESSOA
			Replace TMPTRC->CDSITPESSO        With DADOS_FUNC->CD_SITUACAO_PESSOA
			Replace TMPTRC->CD_ESTRORG        With DADOS_FUNC->CD_ESTRORG
			Replace TMPTRC->CDESTORGEM        With DADOS_FUNC->CD_ESTRUTURA_ORG_EMPRESA
			Replace TMPTRC->NU_CPF            With DADOS_FUNC->NU_CPF
			Replace TMPTRC->NU_RG             With DADOS_FUNC->NU_RG
			Replace TMPTRC->NU_PIS            With DADOS_FUNC->NU_PIS
			Replace TMPTRC->CDPERACESS        With DADOS_FUNC->CD_PERFIL_ACESSO
			Replace TMPTRC->CDCREDFACE        With DADOS_FUNC->CD_CREDENCIAL_FACE
			Replace TMPTRC->CDCREDREP         With DADOS_FUNC->CD_CREDENCIAL_REP
			Replace TMPTRC->TXCAMPO           With Alltrim(cValToChar(DADOS_FUNC->TX_CAMPO08))
		TMPTRC->(MsUnlock())

		//
		DADOS_FUNC->(DbSkip())

	End

	//
	DADOS_FUNC->(DbCloseArea())

Return Nil   	  

Static Function SqlVSitPessoaDimep(nCdPessoa)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			 SELECT CD_SITUACAO_PESSOA_MULTIPLA,
			        CD_PESSOA,
			        CD_SITUACAO_PESSOA,
			        DT_PERIODO_INICIAL AS DT_INI,
			        DT_PERIODO_FINAL   AS DT_FIN
			  FROM [DIMEP].[DMPACESSOII].[DBO].[SITUACAO_PESSOA_MULTIPLA]  WITH (NOLOCK)
			  WHERE CD_PESSOA = %EXP:nCdPessoa%
			    AND GETDATE() BETWEEN DT_PERIODO_INICIAL AND DT_PERIODO_FINAL
	EndSQl             
Return Nil  

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

Return Nil

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

Return Nil

Static Function SqlVCredencialDimep(cCredencial)

	BeginSQL Alias "TRF"

			%NoPARSER% 

			 SELECT CD_CREDENCIAL,NU_CREDENCIAL 
			   FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL] WITH (NOLOCK)
			  WHERE NU_CREDENCIAL = %EXP:cCredencial%
			  
	EndSQl             

Return Nil   

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

Return Nil 
            
Static Function SqlVTurnoDimep(nTurno)                          

	BeginSQL Alias "TRH"
			%NoPARSER%   
			SELECT CD_TURNO,NU_TURNO,DS_TURNO,HR_ZERA_QTD_ACESSO
			  FROM [DIMEP].[DMPACESSOII].[DBO].[TURNO]  WITH (NOLOCK)
             WHERE NU_TURNO = %EXP:nTurno%
			
	EndSQl             
Return Nil 

Static Function SqlVEmpresaDimep(cEmpresa, lReload)  

	Local aStru 	:= {}

	//Everson - 27/10/2021. Chamado 62721.
	If ValType(oEstEmp) <> "U" .And. lReload
		oEstEmp:Delete()

	ElseIf ValType(oEstEmp) <> "U" .And. ! lReload
		DbSelectArea("TMPTRI")
		TMPTRI->(DbGoTop())
		Return Nil

	EndIf

	//Everson - 27/10/2021. Chamado 62721.
	aAdd(aStru,{"ESTRUTURA"   , "N",10,0})
	aAdd(aStru,{"NUESTRUTU"   , "C",10,0})
	aAdd(aStru,{"NMESTRUTU"   , "C",40,0})
	aAdd(aStru,{"NUCNPJ"   	  , "N",14,0})
	aAdd(aStru,{"DSRZSCL"     , "C",60,3})
	aAdd(aStru,{"DSCEI"       , "C",10,0})
	aAdd(aStru,{"CDESTRUTU"   , "N",10,2})
	aAdd(aStru,{"TPESTRUTU"   , "N",10,0})

	//Everson - 27/10/2021. Chamado 62721.
	oEstEmp := FWTemporaryTable():New("TMPTRI")
	oEstEmp:SetFields(aStru)
	oEstEmp:AddIndex("01", {"NUESTRUTU"})

	//
	oEstEmp:Create()
	DbSelectArea("TMPTRI")

	//Everson - 27/10/2021. Chamado 62721.
	If Select("DADOS_EMP") > 0
		DADOS_EMP->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "DADOS_EMP"
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

	//Everson - 27/10/2021. Chamado 62721.
	DbSelectArea("DADOS_EMP")
	DADOS_EMP->(DbGoTop())
	While ! DADOS_EMP->(Eof())

		//
		DbSelectArea("TMPTRI")
		RecLock("TMPTRI", .T.)
			Replace TMPTRI->ESTRUTURA  With DADOS_EMP->ESTRUTURA
			Replace TMPTRI->NUESTRUTU  With DADOS_EMP->NU_ESTRUTURA
			Replace TMPTRI->NMESTRUTU  With DADOS_EMP->NM_ESTRUTURA
			Replace TMPTRI->NUCNPJ	   With DADOS_EMP->NU_CNPJ
			Replace TMPTRI->DSRZSCL    With DADOS_EMP->DS_RAZAO_SOCIAL
			Replace TMPTRI->DSCEI	   With DADOS_EMP->DS_CEI
			Replace TMPTRI->CDESTRUTU  With DADOS_EMP->CD_ESTRUTURA_RELACIONADA
			Replace TMPTRI->TPESTRUTU  With DADOS_EMP->TP_ESTRUTURA
		TMPTRI->(MsUnlock())

		//
		DADOS_EMP->(DbSkip())

	End

	//
	DADOS_EMP->(DbCloseArea())

Return Nil           

Static Function carEstDpt() //nEstOrganizacional, cCC

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("DADOS_DEP") > 0
		DADOS_DEP->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "DADOS_DEP"
		%NoPARSER%  
		SELECT  CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
				NU_ESTRUTURA,
				NM_ESTRUTURA,
				NU_CNPJ,
				DS_RAZAO_SOCIAL,
				DS_CEI,
				CD_ESTRUTURA_RELACIONADA,
				TP_ESTRUTURA
		FROM 
			[DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
		WHERE 
			TP_ESTRUTURA = '1'     
		ORDER BY
			 CD_ESTRUTURA_RELACIONADA, NU_ESTRUTURA
	EndSQl

	//Everson - 27/10/2021. Chamado 62721.
	DbSelectArea("DADOS_DEP")
	DADOS_DEP->(DbGoTop())
	While ! DADOS_DEP->(Eof())

		oHash:Set(Alltrim(cValToChar(DADOS_DEP->CD_ESTRUTURA_RELACIONADA)) + Alltrim(cValToChar(DADOS_DEP->NU_ESTRUTURA)), {;
 				DADOS_DEP->ESTRUTURA,;
				DADOS_DEP->NU_ESTRUTURA,;
				DADOS_DEP->NM_ESTRUTURA,;
				DADOS_DEP->NU_CNPJ,;
				DADOS_DEP->DS_RAZAO_SOCIAL,;
				DADOS_DEP->DS_CEI,;
				DADOS_DEP->CD_ESTRUTURA_RELACIONADA,;
				DADOS_DEP->TP_ESTRUTURA;
		})

		//
		DADOS_DEP->(DbSkip())

	End

	//
	DADOS_DEP->(DbCloseArea())

Return oHash           

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

Return Nil  

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

Return Nil 

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
Return Nil 

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
Return Nil 

Static Function SqlGrupoArea(nGrupo)

	Local cWhere := ''
	
	cWhere := '%' + cValToChar(nGrupo) + '%'

	BeginSQL Alias "TRQ"
			%NoPARSER%  
			SELECT CD_GRUPO,
			       CD_AREA,
			       FL_AREA_ORIGEM
			 FROM [DIMEP].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = %EXP:cWhere%
		
 	EndSQl             
Return Nil 

Static Function SqlTurnoFaixa(nTurno)

	BeginSQL Alias "TRR"
			%NoPARSER%  
			SELECT CD_TURNO,
			       CD_FAIXA_HORARIA
			 FROM [DIMEP].[DMPACESSOII].[DBO].[TURNO_FAIXA] WITH (NOLOCK) 
		    WHERE CD_TURNO = %EXP:nTurno%
		
 	EndSQl             
Return Nil 

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
Return Nil 

Static Function SqlCredPessoa(cCredencia,cPessoa)                          

	BeginSQL Alias "TRT"
			%NoPARSER%  
			SELECT CD_CREDENCIAL,
			       CD_PESSOA,
			       DT_INICIO,
			       DT_FIM,
			       FL_PERMANENTE,
			       TP_TECNOLOGIA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL_PESSOA] WITH (NOLOCK)
			 WHERE CD_CREDENCIAL = %EXP:cCredencia%
			   AND CD_PESSOA     = %EXP:cPessoa%
 			 
 	EndSQl             
Return Nil   

Static Function SqlBuscaCredencialDimep(cCredencial)

	BeginSQL Alias "TRU"
			%NoPARSER% 
			 SELECT CD_CREDENCIAL,NU_CREDENCIAL 
			   FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL] WITH (NOLOCK)
			  WHERE CD_CREDENCIAL = %EXP:cCredencial%
			  
	EndSQl             
Return Nil   

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
Return Nil 

Static Function SqlNomePerAc(nTurno)

	BeginSQL Alias "TRX"
			%NoPARSER%  
			SELECT CD_PERFIL_ACESSO,
			       NM_PERFIL_ACESSO,
			       TP_PERFIL_ACESSO,
			       FL_PUBLICO
			 FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) 
		    WHERE CD_PERFIL_ACESSO = %EXP:nTurno%
		
 	EndSQl             
Return Nil   

Static Function carEstFil(nEstOrganizacional, cFil, lReload)

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("DADOS_FIL") > 0
		DADOS_FIL->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "DADOS_FIL"
		%NoPARSER%  
		SELECT 
			CD_ESTRUTURA_ORGANIZACIONAL AS ESTRUTURA,
			CD_ESTRUTURA_RELACIONADA,
			NU_ESTRUTURA
		FROM 
			[DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] WITH (NOLOCK)
		WHERE 
			TP_ESTRUTURA = '1'
	EndSQl 

	//Everson - 27/10/2021. Chamado 62721.
	DbSelectArea("DADOS_FIL")
	DADOS_FIL->(DbGoTop())
	While ! DADOS_FIL->(Eof())

		//
		oHash:Set(Alltrim(cValToChar(DADOS_FIL->CD_ESTRUTURA_RELACIONADA)) + Alltrim(cValToChar(DADOS_FIL->NU_ESTRUTURA)),;
				DADOS_FIL->ESTRUTURA)

		//
		DADOS_FIL->(DbSkip())

	End

	//
	DADOS_FIL->(DbCloseArea())

Return oHash

Static Function SqlTodaCredencial(cPessoa)                          

	BeginSQL Alias "TSA"
		%NoPARSER%  
		SELECT CD_CREDENCIAL,
				CD_PESSOA,
				DT_INICIO,
				DT_FIM,
				FL_PERMANENTE,
				TP_TECNOLOGIA
			FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL_PESSOA] WITH (NOLOCK)
			WHERE CD_PESSOA     = %EXP:cPessoa% 
 	EndSQl

Return Nil   

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
			FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] WITH (NOLOCK)
			WHERE CD_SITUACAO_PESSOA  = 11 
			  AND (TX_CAMPO01        <> '' 
			   OR TX_CAMPO02         <> ''
			   OR TX_CAMPO03         <> '')
			  
			  
	EndSQl

Return Nil

// Static Function SqlVEstrutura()

// 	//Variáveis.
// 	Local oHash := THashMap():New()

// 	//
// 	If Select("DADOS_EMP") > 0
// 		DADOS_EMP->(DbCloseArea())

// 	EndIf

// 	//
// 	BeginSQL Alias "DADOS_EMP"
// 			%NoPARSER% 
// 			SELECT 
// 				NU_MATRICULA,
// 				ESTRUTURA_ORGANIZACIONAL.NU_ESTRUTURA
// 			FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
// 				INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
// 			    ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
// 			ORDER BY 
// 				PESSOA.NU_MATRICULA
			  
// 	EndSQl  

// 	//Everson - 27/10/2021. Chamado 62721.
// 	DbSelectArea("DADOS_EMP")
// 	DADOS_EMP->(DbGoTop())
// 	While ! DADOS_EMP->(Eof())

// 		//
// 		oHash:Set(DADOS_EMP->NU_MATRICULA, DADOS_EMP->NU_ESTRUTURA)

// 	End

// 	//
// 	DADOS_EMP->(DbCloseArea())

// Return oHash 

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

Return Nil 

Static Function SqlCatracaPortaria()

	BeginSQL Alias "TSE"
			%NoPARSER%  
			SELECT CD_GRUPO,
			       CD_AREA,
			       FL_AREA_ORIGEM
			 FROM [DIMEP].[DMPACESSOII].[DBO].[GRUPO_AREA] WITH (NOLOCK) 
		    WHERE CD_GRUPO = 8
     	       		
 	EndSQl        

Return Nil

Static Function SqlEMP1(cEstLoc)

	BeginSQL Alias "TSF"

			%NoPARSER% 
			SELECT NU_ESTRUTURA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%
			  
	EndSQl             
Return Nil 

Static Function SqlEMP2(cEstLoc)

	BeginSQL Alias "TSG"

			%NoPARSER% 
			SELECT CD_ESTRUTURA_RELACIONADA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%			
			  
	EndSQl             
Return Nil 

Static Function SqlEMP3(cEstLoc)

	BeginSQL Alias "TSH"

			%NoPARSER% 
			SELECT NU_ESTRUTURA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			 WHERE CD_ESTRUTURA_ORGANIZACIONAL = %EXP:cEstLoc%			
			  
	EndSQl             
Return Nil 

Static Function SqlCCDIMEP(nMatricula)

	BeginSQL Alias "TSI"

			%NoPARSER% 
			SELECT NU_ESTRUTURA 
			  FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			  INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
					  ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
			  WHERE NU_MATRICULA = %EXP:nMatricula%
			  
	EndSQl             
Return Nil 

Static Function INTPESSOA(nMat,cNome,nSitFol,nGrupo,nEmpresa,cCic,cRg,cPis,nPerfilAcesso,nRep,nCredencial)

	Local cQuery := ""

	// @history Ticket: 69427  - Fernando Macieir- 14/03/2022 - Nome duplicado no DIMEP
	
	// Checo se o CPF já existe antes de permitir a inclusão
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT NU_CPF
	cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[PESSOA] WITH (NOLOCK)
	cQuery += " WHERE NU_CPF IS NOT NULL
	cQuery += " AND NU_CPF='"+cCic+"'

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )
	If Work->( EOF() )

		cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
		cQuery += "(NU_MATRICULA, " 
		cQuery += "NM_PESSOA, " 
		cQuery += "CD_SITUACAO_PESSOA, " 
		cQuery += "CD_ESTRUTURA_ORGANIZACIONAL, " 
		cQuery += "CD_ESTRUTURA_ORG_EMPRESA, " 
		cQuery += "NU_CPF, " 
		cQuery += "NU_RG, " 
		cQuery += "NU_PIS, "
		cQuery += "CD_PERFIL_ACESSO, "
		cQuery += "CD_CREDENCIAL_REP, " 
		cQuery += "CD_CREDENCIAL_FACE " 
		cQuery += ") "
		cQuery += "VALUES (" + cValToChar(nMat)          + ","  // Matricula
		cQuery += "'"        + cNome                     + "',"  // Nome Funcionario
		cQuery += ""         + cValToChar(nSitFol)       + ","  // Situacao da Folha
		cQuery += "'"        + cValToChar(nGrupo)        + "'," // Grupo Empresa
		cQuery += "'"        + cValToChar(nEmpresa)      + "'," // Empresa
		cQuery += "'"        + cCic                      + "'," // Cpf
		cQuery += "'"        + cRg                       + "'," // Rg  
		cQuery += "'"        + Alltrim(cPis)             + "'," // Pis  
		cQuery += "'"        + cValToChar(nPerfilAcesso) + "'," // Perfil de Acesso 
		cQuery += ""         + cValToChar(nRep)          + ","  // Cod Rep 
		cQuery += ""         + cValToChar(nCredencial)   + " "  // Cod Face
		cQuery += ") " 

		If (TCSqlExec(cQuery) < 0)
			cIntregou += " TCSQLError() - INTFUNCIONARIO: "
		EndIf
	
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return Nil   	      	 	  

Static Function IntCredencial(nCred,nEstrutura,cTipo)   

    cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] " 
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
	cQuery += ""         + cValToChar(nEstrutura) + "," // Estrutura Organizacional
	cQuery += "'"        + cTipo                  + "'," // Tipo Tecnologia
	cQuery += ""         + cValToChar(nCred)      + "," // Credencial
	cQuery += ""         + '1'                    + "," // Permanente
	cQuery += ""         + '0'                    + "," // Bloqueada	
	cQuery += ""         + '0'                    + "," // Tipo Master
	cQuery += ""         + '0'                    + "," // Reentrada
	cQuery += ""         + '1'                    + "," // Disponivel Uso
	cQuery += ""         + '0'                    + "," // Dispensa Senha
	cQuery += ""         + '0'                    + "," // Supervisor Equipamento
	cQuery += ""         + '0'                    + ""  // Credencial Publica
	cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() IntCredencial:"
	EndIf        
	
Return Nil   	      	 	  

Static Function INTCREDMOTORISTA(nCred,nEstrutura,cTipo)   

    cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] " 
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
	cQuery += ""         + cValToChar(nEstrutura) + "," // Estrutura Organizacional
	cQuery += "'"        + cTipo                  + "'," // Tipo Tecnologia
	cQuery += ""         + cValToChar(nCred)      + "," // Credencial
	cQuery += ""         + '1'                    + "," // Permanente
	cQuery += ""         + '0'                    + "," // Bloqueada	
	cQuery += ""         + '0'                    + "," // Tipo Master
	cQuery += ""         + '0'                    + "," // Reentrada
	cQuery += ""         + '1'                    + "," // Disponivel Uso
	cQuery += ""         + '0'                    + "," // Dispensa Senha
	cQuery += ""         + '0'                    + "," // Supervisor Equipamento
	cQuery += ""         + '0'                    + ""  // Credencial Publica
	cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() INTCREDMOTORISTA:"
	EndIf        
	
Return Nil

Static Function IntCrePessoa(nPessoa,nCredencial,cDataIni,cDataFin)

	Local cSql     := ""
	Local cQuery   := ""
	Local cCredenc := ""
	Local cChapa   := ""
	Local cPtoCred := ""

	If Alltrim(cDataIni) == '' .AND. Alltrim(cDataFin) == '' 
	   cDataIni    := DToC(Date())
	   cDataIni    := IIF(Alltrim(cDataIni) <> '',cValToChar(YEAR(Date()))+ '-' + Substr(cDataIni,4,2)+ '-' + Substr(cDataIni,1,2) +  "T" + '00:00:00', cDataFin)
 	EndIf   

	// @history Ticket  17021 - Fernando Macieir- 19/07/2021 - Integração DImep
	If ISINCALLSTACK("DIMEPCAMINHONEIRO")

		cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
		cQuery += "(CD_CREDENCIAL, " 
		cQuery += "CD_PESSOA, " 
		cQuery += "DT_INICIO, " 
		cQuery += "DT_FIM, " 
		cQuery += "FL_PERMANENTE, " 
		cQuery += "TP_TECNOLOGIA " 
		cQuery += ") "
		cQuery += "VALUES (" + cValToChar(nCredencial)                                          + "," // Credencial
		cQuery += ""         + cValToChar(nPessoa)                                              + "," // Pessoa
		cQuery += "'"        + cValToChar(cDataIni)                                             + "'," // Data Inicial
		cQuery += ""        + IIF(Alltrim(cDataFin) == '', 'NULL',"'"+cValToChar(cDataFin)+"'") + "," // Data Fim
		cQuery += ""         + '1'                                                              + "," // Permanente
		cQuery += ""         + '3'                                                              + ""  // Tecnologia	
		cQuery += ") " 

		If (TCSqlExec(cQuery) < 0)
			cIntregou += " TCSQLError() - IntCrePessoa: "
		EndIf        
	
	Else

		cChapa   := Val(TRB->CHAPA) // TIPO 1
		cPtoCred := Val(TRB->PTOCREDENCIAL)     // TIPO 3

		///////////////////////////////////////
		// SE NÃO EXISTIR NENHUMA AMARRAÇÃO 
		///////////////////////////////////////
		If Select("Work")
			Work->( DbCloseArea() )
		EndIf

		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+cValToChar(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+cValToChar(nKey)+"'
	//	cQuery += " AND AMARRA.TP_TECNOLOGIA='"+cValToChar(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Codigo Barra
			cTpTecno := 1 

			cCredenc := GetCDCred(cChapa, 1)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + cValToChar(cCredenc)                                          + "," // Credencial
				cSql += ""         + cValToChar(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + cValToChar(cDataIni)                                             + "'," // Data Inicial
				cSql += ""        + IIF(Alltrim(cDataFin) == '', 'NULL',"'"+cValToChar(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + cValToChar(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSqlExec(cSql) < 0)
					cIntregou += " TCSQLError() - IntCrePessoa: "
				EndIf

			EndIf
		
			// Proximidade
			cTpTecno := 3 

			cCredenc := GetCDCred(cPtoCred, 3)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + cValToChar(cCredenc)                                             + "," // Credencial
				cSql += ""         + cValToChar(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + cValToChar(cDataIni)                                             + "'," // Data Inicial
				cSql += ""        + IIF(Alltrim(cDataFin) == '', 'NULL',"'"+cValToChar(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + cValToChar(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSqlExec(cSql) < 0)
					cIntregou += " TCSQLError() - IntCrePessoa: "
				EndIf

			EndIf

		EndIf

		////////////////////////////////////////////////////////
		// SE NAÕ EXISTIR AMARRAÇÃO TECNOLOGIA 1 = CODIGO BARRA 
		////////////////////////////////////////////////////////
		If Select("Work")
			Work->( DbCloseArea() )
		EndIf

		cTpTecno := 1 // Codigo Barra

		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+cValToChar(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+cValToChar(nKey)+"'
		cQuery += " AND AMARRA.TP_TECNOLOGIA='"+cValToChar(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Codigo Barra
			cTpTecno := 1 

			cCredenc := GetCDCred(cChapa, 1)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + cValToChar(cCredenc)                                              + "," // Credencial
				cSql += ""         + cValToChar(nPessoa)                                               + "," // Pessoa
				cSql += "'"        + cValToChar(cDataIni)                                              + "'," // Data Inicial
				cSql += ""         + IIF(Alltrim(cDataFin) == '', 'NULL',"'"+cValToChar(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                               + "," // Permanente
				cSql += ""         + cValToChar(cTpTecno)                                              + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSqlExec(cSql) < 0)
					cIntregou += " TCSQLError() - IntCrePessoa: "
				EndIf

			EndIf

		EndIf

		/////////////////////////////////////////////////////////
		// SE NAÕ EXISTIR AMARRAÇÃO TECNOLOGIA 3 = APROXIMAÇÃO 
		/////////////////////////////////////////////////////////
		If Select("Work")
			Work->( DbCloseArea() )
		EndIf

		cTpTecno := 3 // Proximidade
		
		cQuery := " SELECT AMARRA.CD_CREDENCIAL, AMARRA.TP_TECNOLOGIA
		cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)
		cQuery += " INNER JOIN [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL
		cQuery += " WHERE AMARRA.CD_PESSOA='"+cValToChar(nPessoa)+"'
	//	cQuery += " AND CRED.NU_CREDENCIAL='"+cValToChar(nKey)+"'
		cQuery += " AND AMARRA.TP_TECNOLOGIA='"+cValToChar(cTpTecno)+"'
		cQuery += " AND ( ISNULL(DT_FIM,'')='' OR ISNULL(DT_BAIXA_CREDENCIAL,'')='' )

		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		If Work->( EOF() )

			// Proximidade
			cTpTecno := 3

			cCredenc := GetCDCred(cPtoCred, 3)

			If !Empty(cCredenc)

				cSql := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
				cSql += "(CD_CREDENCIAL, " 
				cSql += "CD_PESSOA, " 
				cSql += "DT_INICIO, " 
				cSql += "DT_FIM, " 
				cSql += "FL_PERMANENTE, " 
				cSql += "TP_TECNOLOGIA " 
				cSql += ") "
				cSql += "VALUES (" + cValToChar(cCredenc)                                             + "," // Credencial
				cSql += ""         + cValToChar(nPessoa)                                              + "," // Pessoa
				cSql += "'"        + cValToChar(cDataIni)                                             + "'," // Data Inicial
				cSql += ""         + IIF(Alltrim(cDataFin) == '', 'NULL',"'"+cValToChar(cDataFin)+"'") + "," // Data Fim
				cSql += ""         + '1'                                                              + "," // Permanente
				cSql += ""         + cValToChar(cTpTecno)                                             + ""  // Tecnologia	 // // @history Ticket  17021  - Fernando Macieir- 19/07/2021 - Integração DImep
				cSql += ") " 

				cIntregou := ""
				If (TCSqlExec(cSql) < 0)
					cIntregou += " TCSQLError() - IntCrePessoa: "
				EndIf

			EndIf

		EndIf

		If Select("Work") > 0
			Work->( DbCloseArea() )
		EndIf

	EndIf
	
Return Nil

Static Function INTHISTSITPESSOA(nPessoa,nSitFol,cDataIni,cDataFin)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[HISTORICO_SITUACAO_PESSOA] " 
	cQuery += "(CD_PESSOA, " 
	cQuery += "CD_SITUACAO_PESSOA, " 
	cQuery += "DT_ATRIBUICAO, " 
	cQuery += "DT_SITUACAO_INICIAL, " 
	cQuery += "DT_SITUACAO_FINAL " 
    cQuery += ") "
	cQuery += "VALUES ( " + " '" + cValToChar(nPessoa)      + "'," // Pessoa
	cQuery += ""                 + cValToChar(nSitFol)   + "," // Situacao Folha
    cQuery += ""                 + 'GETDATE()'           + "," // Data Atribuicao
    cQuery += "'"                + cValToChar(cDataIni)  + "'," // Data Inicial
	cQuery += "'"                + cValToChar(cDataFin)  + "' " // Data Final
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTHISTSITPESSOA: "
	EndIf        
	
Return Nil   	      	 	  

Static Function INTSITPESSOAMULTIPLA(nPessoa,nSitFolMult,cDataIni,cDataFin)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[SITUACAO_PESSOA_MULTIPLA] " 
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

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTSITPESSOAMULTIPLA: "
	EndIf        
	
Return Nil

Static Function IntUsuSisCredencial(nCredencial)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_CREDENCIAL] " 
	cQuery += "(CD_CREDENCIAL, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nCredencial) + "'," // Credencial
	cQuery += ""                + '1'                     + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'             + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - IntUsuSisCredencial: " 
	EndIf        
	
Return Nil

Static Function INTUSUSISPESSOA(nPessoa)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_PESSOA] " 
	cQuery += "(CD_USUARIO, " 
	cQuery += "CD_PESSOA, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + '1'                 + "'," // Usuario Admin
	cQuery += ""                + cValToChar(nPessoa) + ","  // Pessoa
    cQuery += ""                + 'GETDATE()'         + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISPESSOA: " 
	EndIf        
	
Return Nil 

Static Function CargaTurnoDimep(nTurno,cDesc)   	      	 	  

	Local cHoraAcesso := "1904-01-01" +  "T" + '00:00:00'

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[TURNO] " 
	cQuery += "(NU_TURNO, " 
	cQuery += "DS_TURNO, " 
    cQuery += "HR_ZERA_QTD_ACESSO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nTurno)  + "'," // Cod Turno
	cQuery += "'"               + cDesc               + "',"  // Descrição do Turno
    cQuery += "'"               + cHoraAcesso         + "' "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISPESSOA: "
	EndIf        
	
Return Nil

Static Function INTUSUSISTURNO(nTurno)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_TURNO] " 
	cQuery += "(CD_TURNO, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nTurno)      + "'," // Turno
	cQuery += ""                + '1'                     + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'             + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISTURNO: "
	EndIf        
	
Return Nil 

Static Function INTTURNOFAIXA(nTurno,nFaixa)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[TURNO_FAIXA] " 
	cQuery += "(CD_TURNO, " 
	cQuery += "CD_FAIXA_HORARIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nTurno)      + "'," // Turno
	cQuery += "'"               + cValToChar(nFaixa)      + "'"  // Faixa
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTTURNOFAIXA: "
	EndIf        
	
Return Nil 

Static Function INTJORNADA(nTurno)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[JORNADA] " 
	cQuery += "(DS_JORNADA, " 
	cQuery += "TP_JORNADA, " 
	cQuery += "QT_DIAS_PERIODO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nTurno) + "'," // DS_JORNADA
	cQuery += "'"               + '1'                + "'," // TP_JORNADA
	cQuery += "'"               + '0'                + "'" // QT_DIAS_PERIODO
	cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTJORNADA: "
	EndIf        
	
Return Nil 

Static Function INTUSUSISJORNADA(nJornada)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_JORNADA] " 
	cQuery += "(CD_JORNADA, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nJornada) + "'," // Credencial
	cQuery += "'"                + '1'                 + "',"  // Usuario Admin
    cQuery += ""                + 'GETDATE()'          + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISJORNADA: "
	EndIf        
	
Return Nil                     

Static Function INTJORDIA(nJornada,nDia,nTurno)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[JORNADA_DIA] " 
	cQuery += "(CD_JORNADA, " 
	cQuery += "NU_DIA, " 
    cQuery += "CD_TURNO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nJornada) + "'," // CD_JORNADA
	cQuery += "'"               + cValToChar(nDia)     + "',"  // NU_DIA
    cQuery += "'"               + cValToChar(nTurno)   + "' "  // CD_TURNO
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTJORDIA: "
	EndIf        
	
Return Nil                        

Static Function INTPERAC(nTurno)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO] " 
	cQuery += "(NM_PERFIL_ACESSO, " 
	cQuery += "TP_PERFIL_ACESSO, " 
    cQuery += "FL_PUBLICO " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nTurno) + "'," // NM_PERFIL_ACESSO
	cQuery += "'"               + '0'                + "'," // TP_PERFIL_ACESSO
    cQuery += "'"               + '0'                + "' " // FL_PUBLICO
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERAC: "
	EndIf        
	                        
Return Nil                        

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
	cQuery += "VALUES (" + " '" + cValToChar(nPerfilAcesso)                                                                + "'," // CD_PERFIL_ACESSO
	cQuery += "'"               + cValToChar(nGrupo)                                                                       + "'," // CD_GRUPO
	cQuery += "'"               + cValToChar(nArea)                                                                        + "'," // CD_AREA
	cQuery += "'"               + IIF(Alltrim(cJornada)       <> 'NULL','2','0')                                           + "'," // TP_ACESSO
	cQuery += " "               + IIF(Alltrim(cJornada)       <> 'NULL',"'" + cJornada + "'" ,cJornada)                    + " ," // CD_JORNADA
    cQuery += " "               + IIF(VALTYPE(nTurno)        == 'N'   ,"'" + cValToChar(nTurno) + "'" ,nTurno)             + " ," // CD_TURNO
	cQuery += ""                + IIF(VALTYPE(nFaixaHoraria) == 'N'   ,"'" + cValToChar(nFaixaHoraria)+ "'",nFaixaHoraria) + " ," // CD_FAIXA_HORARIA
	cQuery += ""                + IIF(VALTYPE(nQtdAcesso)    == 'N'   ,"'" + cValToChar(nQtdAcesso) + "'",nQtdAcesso)      + " ," // QT_ACESSO_PERMITIDO
	cQuery += "'"               + '0'                                                                                       + "'," // TP_AUTENTICACAO
	cQuery += "'"               + '0'                                                                                       + "'," // FL_NOTIFICA_PRESENTE
	cQuery += "'"               + cValToChar(nFlagAusente)                                                                  + "'," // FL_NOTIFICA_AUSENTE
    cQuery += " "               + IIF(Alltrim(cJornada)       <> 'NULL',"'" + cJornada + "'" ,cJornada)                     + " " // CD_JORNADA_NOTIFICA_AUSENTE
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERACREGRA: "
	EndIf        
	                        
Return Nil                        

Static Function INTPERRESTRICAO(nPerfilAcesso,nGRupo,nArea)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[PERFIL_ACESSO_RESTRICAO] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_GRUPO, " 
	cQuery += "CD_AREA, " 
	cQuery += "FL_CONTROLA_TEMPO, " 
	cQuery += "TP_CONTROLE_TEMPO, " 
	cQuery += "FL_CONTROLA_TEMPO_GRUPOS " 
	cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nPerfilAcesso) + "'," // CD_PERFIL_ACESSO
	cQuery += "'"               + cValToChar(nGrupo)        + "'," // CD_GRUPO
	cQuery += "'"               + cValToChar(nArea)         + "'," // CD_AREA
	cQuery += "'"               + '0'                       + "'," // FL_CONTROLA_TEMPO
	cQuery += "'"               + '0'                       + "'," // TP_CONTROLE_TEMPO
	cQuery += "'"               + '0'                       + "'"  // FL_CONTROLA_TEMPO_GRUPOS
	cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTPERRESTRICAO: "
	EndIf        
	                        
Return Nil                        

Static Function INTSISPERFILACESSO(nPerfilAcesso)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SIST_PERFIL_ACESSO] " 
	cQuery += "(CD_PERFIL_ACESSO, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + cValToChar(nPerfilAcesso) + "'," // Credencial
	cQuery += ""                + '1'                       + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'               + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTSISPERFILACESSO: "
	EndIf        
	
Return Nil  

Static Function UpdPessoa(cCampo1,cCampo2,nMat,nEstOrganizacional,nEstOrgEmpresa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + "'"  + cCampo2 + "'"
	cQuery += " WHERE NU_MATRICULA  = " + "" + cvaltochar(nMat) + ""  // chamado 053384 - WILLIAM COSTA - 14/11/2019
   
    If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - UpdPessoa: " 
	EndIf        
	
Return Nil  

Static Function UpdPess1(cCampo1,cCampo2,nMat,nEstOrganizacional,nEstOrgEmpresa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE NU_MATRICULA  = " + "" + cvaltochar(nMat) + "" // chamado 053384 - WILLIAM COSTA - 14/11/2019
    
	If (TCSqlExec(cQuery) < 0) .OR. Alltrim(cValToChar(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UpdPess1: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
Return Nil

Static Function UpdPess2(cCampo1,cCampo2,cCdPessoa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE CD_PESSOA     = " + "" + cvaltochar(cCdPessoa)               + "" 

	If (TCSqlExec(cQuery) < 0) .OR. Alltrim(cValToChar(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UpdPess2: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
Return Nil

Static Function UpdCredPes(cCampo1,cCdCredencial,cCdPessoa)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
	cQuery += " SET " + cCampo1 + " = NULL " 
	cQuery += " WHERE CD_CREDENCIAL = " + "" + cvaltochar(cCdCredencial) + " " 
	cQuery += "   AND CD_PESSOA     = " + "" + cvaltochar(cCdPessoa)     + " " 

	If (TCSqlExec(cQuery) < 0) 
    	cIntregou += " TCSQLError() - UpdCredPes: " + 'cCampo1: ' + cCampo1 
	EndIf        
	
Return Nil

Static Function DELSITPESSOAMULTIPLA(cCdPessoa)

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[SITUACAO_PESSOA_MULTIPLA] " 
	cQuery += "WHERE CD_PESSOA = '" + cCdPessoa + "'"

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DELSITPESSOAMULTIPLA: "
	EndIf        
	
Return Nil    

Static Function DelCredPessoa(cCredencialFace)                

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] " 
	cQuery += "WHERE CD_CREDENCIAL = '" + cCredencialFace + "'"

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DelCredPessoa: "
	EndIf        
	
Return Nil                           

Static Function DelUsuSisCredencial(cCredencialFace)                

	cQuery := "DELETE FROM [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_CREDENCIAL] " 
	cQuery += "WHERE CD_CREDENCIAL = '" + cCredencialFace + "'"

	If (TCSqlExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - DelUsuSisCredencial: "
	EndIf        
	
Return Nil                                                                                                                                  

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

	//Everson - 27/10/2021. Chamado 62721.
	If ! oCdAmr2Ch:Get( Alltrim(cValToChar(nPessoa)) + Alltrim(cValToChar(nKey)) + Alltrim(cValToChar(cTpTecno)) )
		lRet := .t.

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
	//Local cSql   := ""

	Default nTpTecno := 0

	If Select("Work")
		Work->( DbCloseArea() )
	EndIf

	cQuery := " SELECT CD_CREDENCIAL, TP_TECNOLOGIA
	cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK)
	cQuery += " WHERE CRED.NU_CREDENCIAL='"+cValToChar(nKey)+"'

	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		cRet := Work->CD_CREDENCIAL
	EndIf

	If Select("Work")
		Work->( DbCloseArea() )
	EndIf

Return cRet

/*/{Protheus.doc} Static Function ChkAllCred( TRC->CD_PESSOA, Val(TRB->CHAPA), Val(TRB->PTOCREDENCIAL) )
	Checa se existem 2 credenciais iguais com tipos de tecnologias diferentes.
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
	Local cSql := ""

	// Checo duplicidade pela Chapa.
	If oCdAmrCh:Get(Alltrim(cValToChar(nCD_PESSOA)) + Alltrim(cValToChar(nCHAPA)))

		lRet := .t.

		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
		cSql += " WHERE CD_PESSOA='"+cValToChar(nCD_PESSOA)+"' 

		TCSqlExec(cSql)

	EndIf
	
	// Checo duplicidade pela Credencial.
	If oCdAmrCh:Get(Alltrim(cValToChar(nCD_PESSOA)) + Alltrim(cValToChar(nPTOCREDENCIAL)))
		
		lRet := .t.

		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
		cSql += " WHERE CD_PESSOA='"+cValToChar(nCD_PESSOA)+"' 

		TCSqlExec(cSql)

	EndIf

Return lRet

/*/{Protheus.doc} UpdTecno( TRC->CD_PESSOA, Val(TRB->CHAPA), Val(TRB->PTOCREDENCIAL) )
	Equalizo tipo tecnologia qdo estão divergentes entre as tabelas CREDENCIAL x CREDENCIAL_PESSOA
	@type  Static Function
	@author FWNM
	@since 22/07/2021
	@version 01
/*/
Static Function UpdTecno( nCD_PESSOA, nCHAPA, nPTOCREDENCIAL )

	Local cQuery  := ""
	Local aDdTec2 := {}

	If Select("Work") > 0
		Work->( DbCloseArea() )

	EndIf

	cQuery := " SELECT CDCRED AS CD_CREDENCIAL, TPTEC AS TP_TECNOLOGIA "
	cQuery += " FROM " + oCrXPes2:GetRealName() + " " //Everson - 27/10/2021. Chamado 62721.
	cQuery += " WHERE CDPESS = " + cValToChar(nCD_PESSOA) +" "

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		// Checo o TP de Tecnologia da credencial 
		//Everson - 27/10/2021. Chamado 62721.
		aDdTec2 := {}
		If oCdNXC2:Get(Alltrim(cValToChar(Work->CD_CREDENCIAL)), aDdTec2)

			If Alltrim(cValToChar(Work->TP_TECNOLOGIA)) <> Alltrim(cValToChar(aDdTec2[1]))
				// TICKET 69748 - 16/03/2022 - ADRIANO SAVOINE
				// Codigo Barra
				If Len(Alltrim(cValToChar(aDdTec2[2]))) == 7
				
					cTpTecno := "1"
				
					cSql := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL]
					cSql += " SET TP_TECNOLOGIA = '" + cTpTecno + "' "
					cSql += " WHERE CD_CREDENCIAL='" + cValToChar(Work->CD_CREDENCIAL) + "' 
					If TCSqlExec(cSql) < 0
						 Conout("ADGPE024P - UpdTecno - 1 - TCSQLError() " + TCSQLError())

					EndIf

					cSql := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
					cSql += " SET TP_TECNOLOGIA = '"+cTpTecno+"' "
					cSql += " WHERE CD_PESSOA='" + cValToChar(nCD_PESSOA) + "' 
					cSql += " AND CD_CREDENCIAL='" + cValToChar(Work->CD_CREDENCIAL) + "' 
					If TCSqlExec(cSql) < 0
						 Conout("ADGPE024P - UpdTecno - 2 - TCSQLError() " + TCSQLError())

					EndIf

				EndIf

				// Proximidade
				If Len(Alltrim(cValToChar(aDdTec2[2]))) == 10
				
					cTpTecno := "3"
				
					cSql := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL]
					cSql += " SET TP_TECNOLOGIA = '" + cTpTecno + "' "
					cSql += " WHERE CD_CREDENCIAL='" + cValToChar(Work->CD_CREDENCIAL) + "' 
					If TCSqlExec(cSql) < 0
						 Conout("ADGPE024P - UpdTecno - 3 - TCSQLError() " + TCSQLError())

					EndIf

					cSql := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
					cSql += " SET TP_TECNOLOGIA = '" + cTpTecno + "' "
					cSql += " WHERE CD_PESSOA='" + nCD_PESSOA + "' 
					cSql += " AND CD_CREDENCIAL='" + cValToChar(Work->CD_CREDENCIAL) + "' 
					If TCSqlExec(cSql) < 0
						 Conout("ADGPE024P - UpdTecno - 4 - TCSQLError() " + TCSQLError())

					EndIf

				EndIf

			EndIf

		Else
			Conout("ADGPE024 - Erro - UpdTecno - oCdNXC2")

		EndIf

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( DbCloseArea() )

	EndIf

Return Nil
/*/{Protheus.doc} carCreden
	Função carrega credenciais do Dimep.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carCreden()

	//
	oCdNXC1 := THashMap():New()
	oCdNXC2 := THashMap():New()

	//
	If Select("D_CRED") > 0
		D_CRED->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "D_CRED"
		%NoPARSER%
		SELECT CD_CREDENCIAL, NU_CREDENCIAL, TP_TECNOLOGIA 
		FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL] WITH (NOLOCK) ORDER BY CD_CREDENCIAL 
	EndSQl

	//
	DbSelectArea("D_CRED")
	D_CRED->(DbGoTop())
	While ! D_CRED->(Eof())

		//Chave NU_CREDENCIAL.
		oCdNXC1:Set(Val(cValToChar(D_CRED->NU_CREDENCIAL)), D_CRED->CD_CREDENCIAL)

		//Chave CD_CREDENCIAL.
		oCdNXC2:Set(Alltrim(cValToChar(D_CRED->CD_CREDENCIAL)), {;
					D_CRED->TP_TECNOLOGIA,;
					D_CRED->NU_CREDENCIAL;
		})

		//
		D_CRED->(DbSkip())

	End

	//
	D_CRED->(DbCloseArea())

Return Nil
/*/{Protheus.doc} carPerfil
	Função carrega perfil.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carPerfil()

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("D_PRFL") > 0
		D_PRFL->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "D_PRFL"
		%NoPARSER%  
		SELECT 
			CD_PERFIL_ACESSO,
			NM_PERFIL_ACESSO,
			TP_PERFIL_ACESSO,
			FL_PUBLICO
		FROM [DIMEP].[DMPACESSOII].[DBO].[PERFIL_ACESSO] WITH (NOLOCK) ORDER BY CD_PERFIL_ACESSO
	EndSQl

	//
	DbSelectArea("D_PRFL")
	D_PRFL->(DbGoTop())
	While ! D_PRFL->(Eof())

		//
		oHash:Set(D_PRFL->CD_PERFIL_ACESSO, D_PRFL->NM_PERFIL_ACESSO)

		//
		D_PRFL->(DbSkip())

	End

	//
	D_PRFL->(DbCloseArea())

Return oHash
/*/{Protheus.doc} carEstEmp
	Função carrega empresa.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carEstEmp()

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("D_EMPR") > 0
		D_EMPR->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "D_EMPR"
		%NoPARSER%  
		SELECT 
			CD_ESTRUTURA_ORGANIZACIONAL, NU_ESTRUTURA
		FROM [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] ORDER BY CD_ESTRUTURA_ORGANIZACIONAL
	EndSQl

	//
	DbSelectArea("D_EMPR")
	D_EMPR->(DbGoTop())
	While ! D_EMPR->(Eof())

		//
		oHash:Set(D_EMPR->CD_ESTRUTURA_ORGANIZACIONAL, D_EMPR->NU_ESTRUTURA)

		//
		D_EMPR->(DbSkip())

	End

	//
	D_EMPR->(DbCloseArea())

Return oHash
/*/{Protheus.doc} carTurno
	Função carrega turno.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carTurno(cEmpresa)

	//Variáveis.
	Local cQuery:= ""
	Local oHash := THashMap():New()

	//
	If Select("D_TURNO") > 0
		D_TURNO->(DbCloseArea())

	EndIf

	//
	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", ' "
	cQuery += " 		SELECT CODCOLIGADA, "
	cQuery += " 		  			  CHAPA, "
	cQuery += " 					  CODHORARIO "
	cQuery += " 				 FROM [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK) "
	cQuery += " 				WHERE CODCOLIGADA = ''" + cEmpresa + "'' "
	cQuery += " 				  AND CODHORARIO <> ''A001'' "
	cQuery += " 				  ORDER BY CHAPA "
	cQuery += " ') "

	TcQuery cQuery New Alias "D_TURNO"

	//
	DbSelectArea("D_TURNO")
	D_TURNO->(DbGoTop())
	While ! D_TURNO->(Eof())

		//
		oHash:Set(Alltrim(cValtoChar(D_TURNO->CHAPA)), D_TURNO->CODHORARIO)

		//
		D_TURNO->(DbSkip())

	End

	//
	D_TURNO->(DbCloseArea())

Return oHash
/*/{Protheus.doc} carCredXPes
	Função carrega credencial de pessoa.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carCredXPes()

	//Variáveis.
	oCrXPes1 := THashMap():New()
	oCrXPes3 := THashMap():New()

	//
	If Select("D_CREDP") > 0
		D_CREDP->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "D_CREDP"
		%NoPARSER%  
		SELECT  CD_CREDENCIAL,
				CD_PESSOA,
				DT_INICIO,
				DT_FIM,
				FL_PERMANENTE,
				TP_TECNOLOGIA
			FROM 
				[DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL_PESSOA] WITH (NOLOCK) 
			ORDER BY 
				CD_CREDENCIAL, DT_INICIO
 	EndSQl 

	//
	DbSelectArea("D_CREDP")
	D_CREDP->(DbGoTop())
	While ! D_CREDP->(Eof())

		//Chave CD_CREDENCIAL + CD_PESSOA.
		oCrXPes1:Set(Alltrim(cValToChar(D_CREDP->CD_CREDENCIAL)) + Alltrim(cValToChar(D_CREDP->CD_PESSOA)),; //TI  - Everson - 08/11/2021 
		         {D_CREDP->CD_CREDENCIAL, D_CREDP->CD_PESSOA, D_CREDP->DT_INICIO,;
				  D_CREDP->DT_FIM, D_CREDP->FL_PERMANENTE, D_CREDP->TP_TECNOLOGIA})

		//Chave CD_PESSOA.
		oCrXPes3:Set(Alltrim(cValToChar(D_CREDP->CD_PESSOA)), Alltrim(cValToChar(D_CREDP->CD_CREDENCIAL)))

		//
		D_CREDP->(DbSkip())

	End

	//
	D_CREDP->(DbCloseArea())

Return Nil

/*/{Protheus.doc} carCredXPes
	Função carrega férias.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carFerias(cEmp)

	//Variáveis.
	Local oHash := THashMap():New()
	Local cQuery:= ""

	//
	If Select("D_FERIAS") > 0
		D_FERIAS->(DbCloseArea())

	EndIf

	//
	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", ' "
	cQuery += "		  SELECT PFUFERIASPER.CHAPA, "
	cQuery += "						SITUACAOFERIAS, "
	cQuery += "						DATAINICIO, "
	cQuery += "						DATAFIM "
	cQuery += "					FROM [" + cSGBD + "].[DBO].[PFUFERIASPER] AS PFUFERIASPER WITH (NOLOCK) "
	cQuery += "					INNER JOIN [" + cSGBD + "].[DBO].[PFUFERIASRECIBO] AS PFUFERIASRECIBO WITH (NOLOCK) "
	cQuery += "							ON PFUFERIASRECIBO.CODCOLIGADA = PFUFERIASPER.CODCOLIGADA "
	cQuery += "						   AND PFUFERIASRECIBO.CHAPA       = PFUFERIASPER.CHAPA "
	cQuery += "						   AND PFUFERIASRECIBO.DATAPAGTO   = PFUFERIASPER.DATAPAGTO "
	cQuery += "					     WHERE PFUFERIASPER.CODCOLIGADA    = ''" + cEmp + "'' "
	cQuery += "					       AND CONVERT(VARCHAR(8), GETDATE(), 112) BETWEEN CONVERT(VARCHAR(8), DATAINICIO, 112) AND CONVERT(VARCHAR(8), DATAFIM, 112) "
	cQuery += " ') ORDER BY CHAPA, DATAINICIO "

	//
	TcQuery cQuery New Alias "D_FERIAS"

	//
	DbSelectArea("D_FERIAS")
	D_FERIAS->(DbGoTop())
	While ! D_FERIAS->(Eof())

		//
		oHash:Set(Alltrim(cValtoChar(D_FERIAS->CHAPA)),{D_FERIAS->SITUACAOFERIAS, D_FERIAS->DATAINICIO, D_FERIAS->DATAFIM})

		//
		D_FERIAS->(DbSkip())

	End

	//
	D_FERIAS->(DbCloseArea())

Return oHash

/*/{Protheus.doc} carAfast
	Função carrega afastamentos.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carAfast(cEmp)

	//Variáveis.
	Local oHash := THashMap():New()
	Local cQuery:= ""

	//
	If Select("D_AFAST") > 0
		D_AFAST->(DbCloseArea())

	EndIf

	//
	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", ' "
	cQuery += " 		SELECT        CHAPA, "
	cQuery += " 					  TIPO, "
	cQuery += " 					  DTINICIO AS DATAINICIO, "
	cQuery += " 					  DTFINAL AS DATAFIM "
	cQuery += " 				  FROM [" + cSGBD + "].[DBO].[PFHSTAFT] AS PFHSTAFT WITH (NOLOCK) "
	cQuery += " 				 WHERE CODCOLIGADA = ''" + cEmp + "'' " 
	cQuery += " 				   AND ( CONVERT(VARCHAR(8), GETDATE(), 112) BETWEEN CONVERT(VARCHAR(8), DTINICIO, 112) AND CONVERT(VARCHAR(8), DTFINAL, 112) " 
	cQuery += " 				         OR CONVERT(VARCHAR(8), DTFINAL, 112) IS NULL ) "
	cQuery += " ') ORDER BY CHAPA, DATAINICIO DESC "

	//
	TcQuery cQuery New Alias "D_AFAST"

	//
	DbSelectArea("D_AFAST")
	D_AFAST->(DbGoTop())
	While ! D_AFAST->(Eof())

		//
		oHash:Set(Alltrim(cValtoChar(D_AFAST->CHAPA)),{D_AFAST->TIPO, D_AFAST->DATAINICIO, D_AFAST->DATAFIM})

		//
		D_AFAST->(DbSkip())

	End

	//
	D_AFAST->(DbCloseArea())

Return oHash

/*/{Protheus.doc} carPesXEst
	Função carrega função dimep.
	Chamado 62721.
	@type  Static Function
	@author Everson
	@since 27/10/2021
	@version 01
/*/
Static Function carPesXEst(cEmp)

	//Variáveis.
	Local oHash := THashMap():New()

	//
	If Select("D_CCFDI") > 0
		D_CCFDI->(DbCloseArea())

	EndIf

	//
	BeginSQL Alias "D_CCFDI"
		%NoPARSER%  
		SELECT
			NU_MATRICULA,
			NU_ESTRUTURA
		FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA
			INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
			ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
		ORDER BY 
			NU_MATRICULA
 	EndSQl 

	//
	DbSelectArea("D_CCFDI")
	D_CCFDI->(DbGoTop())
	While ! D_CCFDI->(Eof())

		//
		oHash:Set(Alltrim(cValtoChar(D_CCFDI->NU_MATRICULA)), D_CCFDI->NU_ESTRUTURA) //TI  - Everson - 08/11/2021 

		//
		D_CCFDI->(DbSkip())

	End

	//
	D_CCFDI->(DbCloseArea())

Return oHash

Static Function carCredTec(lReload)

	Local aStru  := {}

	//Everson - 27/10/2021. Chamado 62721.
	If ValType(oCrXPes2) <> "U" .And. lReload
		oCrXPes2:Delete()

	ElseIf ValType(oCrXPes2) <> "U" .And. ! lReload
		DbSelectArea("TMPCRDP")
		TMPCRDP->(DbGoTop())
		Return Nil

	EndIf

	//Everson - 27/10/2021. Chamado 62721.
	aAdd(aStru,{"CDCRED" , "N",20,0})
	aAdd(aStru,{"TPTEC"  , "N",20,0})
	aAdd(aStru,{"CDPESS" , "N",20,0})

	//Everson - 27/10/2021. Chamado 62721.
	oCrXPes2 := FWTemporaryTable():New("TMPCRDP")
	oCrXPes2:SetFields(aStru)
	oCrXPes2:AddIndex("01", {"CDPESS"})

	//
	oCrXPes2:Create()
	DbSelectArea("TMPCRDP")

	//Everson - 27/10/2021. Chamado 62721.
	If Select("DADOS_CRP") > 0
		DADOS_CRP->(DbCloseArea())

	EndIf

	BeginSQL Alias "DADOS_CRP"
		%NoPARSER%
		SELECT
			CREDPESS.CD_CREDENCIAL, CREDPESS.TP_TECNOLOGIA, CREDPESS.CD_PESSOA 		
		FROM 
			[DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AS CREDPESS WITH (NOLOCK)
			INNER JOIN [DIMEP].[DMPACESSOII].[dbo].PESSOA AS PESSOA ON
			CREDPESS.CD_PESSOA =  PESSOA.CD_PESSOA
		WHERE 
			CREDPESS.DT_FIM IS NULL
		AND 
			PESSOA.CD_SITUACAO_PESSOA NOT IN ('12')
		ORDER BY
			CREDPESS.CD_PESSOA
	EndSQl

	DADOS_CRP->(DbGoTop())
	While ! DADOS_CRP->(Eof())

		//
		DbSelectArea("TMPCRDP")
		RecLock("TMPCRDP", .T.)
		    Replace TMPCRDP->CDCRED  With DADOS_CRP->CD_CREDENCIAL
			Replace TMPCRDP->TPTEC   With DADOS_CRP->TP_TECNOLOGIA
			Replace TMPCRDP->CDPESS  With DADOS_CRP->CD_PESSOA
		TMPCRDP->(MsUnlock())

		//
		DADOS_CRP->(DbSkip())

	End

	//
	DADOS_CRP->(DbCloseArea())

Return Nil

Static Function carChkDpCr()

	//Variáveis.
	Local oHash := THashMap():New()
	Local cQuery:= ""

	//Everson - 27/10/2021. Chamado 62721.
	If Select("DADOS_CKD") > 0
		DADOS_CKD->(DbCloseArea())

	EndIf

	cQuery := ""
	cQuery += " SELECT * FROM OPENQUERY(DIMEP,' " 
	cQuery += " SELECT  " 
	cQuery += " AMARRA.CD_PESSOA, CRED.NU_CREDENCIAL, COUNT(1) TT_CREDENCIAL " 
	cQuery += " FROM  " 
	cQuery += " [DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK)  " 
	cQuery += " INNER JOIN  " 
	cQuery += " [DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL  " 
	cQuery += " WHERE  " 
	cQuery += " AMARRA.TP_TECNOLOGIA IN (''1'',''3'') " 
	cQuery += " AND ( ISNULL(DT_FIM,'''')='''' OR ISNULL(DT_BAIXA_CREDENCIAL,'''')='''' ) " 
	cQuery += " GROUP BY AMARRA.CD_PESSOA, CRED.NU_CREDENCIAL " 
	cQuery += " HAVING  COUNT(1) >= 2  " 
	cQuery += " ') " 
	
	TcQuery cQuery New Alias "DADOS_CKD"

	DADOS_CKD->(DbGoTop())
	While ! DADOS_CKD->(Eof())

		//Chave CD_PESSOA + nCHAPA.
		oHash:Set( Alltrim(cValToChar(DADOS_CKD->CD_PESSOA)) + Alltrim(cValToChar(DADOS_CKD->NU_CREDENCIAL)), Val(cValToChar(DADOS_CKD->TT_CREDENCIAL))) //TI  - Everson - 08/11/2021 

		DADOS_CKD->(DbSkip())

	End

	//
	DADOS_CKD->(DbCloseArea())

Return oHash

Static Function carChk2DpCr()

	//Variáveis.
	Local oHash := THashMap():New()
	Local cQuery:= ""

	//Everson - 27/10/2021. Chamado 62721.
	If Select("DADOS_CK2") > 0
		DADOS_CK2->(DbCloseArea())

	EndIf

	cQuery := ""
	cQuery += " SELECT * FROM OPENQUERY(DIMEP,' " 
	cQuery += " SELECT AMARRA.CD_CREDENCIAL, AMARRA.CD_PESSOA, AMARRA.TP_TECNOLOGIA, CRED.NU_CREDENCIAL " 
	cQuery += " FROM [DMPACESSOII].[dbo].[CREDENCIAL_PESSOA] AMARRA (NOLOCK) " 
	cQuery += " INNER JOIN [DMPACESSOII].[dbo].[CREDENCIAL] CRED (NOLOCK) ON AMARRA.CD_CREDENCIAL=CRED.CD_CREDENCIAL " 
	cQuery += " WHERE  " 
	cQuery += " ( ISNULL(DT_FIM,'''')='''' OR ISNULL(DT_BAIXA_CREDENCIAL,'''')='''' ) " 
	cQuery += " ') "

	TcQuery cQuery New Alias "DADOS_CK2"

	DADOS_CK2->(DbGoTop())
	While ! DADOS_CK2->(Eof())

		//Chave CD_PESSOA + NU_CREDENCIAL + TP_TECNOLOGIA.
		oHash:Set( Alltrim(cValToChar(DADOS_CK2->CD_PESSOA)) + Alltrim(cValToChar(DADOS_CK2->NU_CREDENCIAL)) + Alltrim(cValToChar(DADOS_CK2->TP_TECNOLOGIA)),;
		           Alltrim(cValToChar(DADOS_CK2->CD_PESSOA))) //TI  - Everson - 08/11/2021 

		DADOS_CK2->(DbSkip())

	End

	//
	DADOS_CK2->(DbCloseArea())

Return oHash

/*/{Protheus.doc} ExcPessoa()
	Exclui nomes duplicados no DIMEP
	@type  Static Function
	@author user
	@since 14/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Ticket: 69427  - Fernando Macieir- 14/03/2022 - Nome duplicado no DIMEP
/*/
User Function ExcPessoa(cCPF)

	Local cQuery := ""

	Default cCPF := ""

	// Exclui todos os CPF duplicados, caso existam
	If !Empty(cCPF)
		RunExcPessoa(cCPF)
	Else

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf

		cQuery := " SELECT NU_CPF, COUNT(1) TT_DUPL
		cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[PESSOA] WITH (NOLOCK)
		cQuery += " WHERE NU_CPF IS NOT NULL
		cQuery += " GROUP BY NU_CPF
		cQuery += " HAVING COUNT(1) >= 2

		tcQuery cQuery New Alias "Work"

		Work->( dbGoTop() )
		Do While Work->( !EOF() )
			RunExcPessoa(Work->NU_CPF)
			Work->( dbSkip() )
		EndDo

	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 14/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RunExcPessoa(cCPF)

	Local cSql := ""
	Local cQuery := ""

	If Select("Work2") > 0
		Work2->( dbCloseArea() )
	EndIf

	cQuery := " SELECT TOP 1 MAX(CD_PESSOA) CD_PESSOA
	cQuery += " FROM [DIMEP].[DMPACESSOII].[dbo].[PESSOA] WITH (NOLOCK)
	cQuery += " WHERE NU_MATRICULA='"+cCPF+"'

	tcQuery cQuery New Alias "Work2"

	Work2->( dbGoTop() )
	If Work2->( !EOF() )

		// AUTORIZACAO EXCEP
		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[PESSOA_AUTORIZACAO_EXCEP]
		cSql += " WHERE CD_PESSOA='"+AllTrim(Str(Work2->CD_PESSOA))+"'
		tcSqlExec(cSql)

		// SISTEMA PESSOA
		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[USUARIO_SISTEMA_PESSOA]
		cSql += " WHERE CD_PESSOA='"+AllTrim(Str(Work2->CD_PESSOA))+"'
		tcSqlExec(cSql)

		// CREDENCIAL
		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[CREDENCIAL_PESSOA]
		cSql += " WHERE CD_PESSOA='"+AllTrim(Str(Work2->CD_PESSOA))+"'
		tcSqlExec(cSql)

		// HISTORICO
		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[HISTORICO_SITUACAO_PESSOA]
		cSql += " WHERE CD_PESSOA='"+AllTrim(Str(Work2->CD_PESSOA))+"'

		// PESSOA
		cSql := " DELETE [DIMEP].[DMPACESSOII].[dbo].[PESSOA]
		cSql += " WHERE CD_PESSOA='"+AllTrim(Str(Work2->CD_PESSOA))+"'
		tcSqlExec(cSql)

	EndIf

	If Select("Work2") > 0
		Work2->( dbCloseArea() )
	EndIf
	
Return
