#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADGPE055P
	Adicionado tratativa para colocar a pessoa em quarentena no DMPACESSII por causa do corona Virus, necessário ficar um dia bloqueada no dimep
	@type  Function
	@author William Costa
	@since 13/03/2020
	@version 01
	@history Chamado TI  - WILLIAM COSTA - 18/03/2020 - Ajuste error log na hora de desbloquear uma pessoa, após adiconar o log da ZBE
	@history TICKET  224 - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history TICKET  39  - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/
USER FUNCTION ADGPE055P(aParam)  

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	Private cLinked := "" 
	Private cSGBD   := "" 
	//

	Private cDataIni  := ''
	Private cDataFin  := ''
	Private cIntregou := ''
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RpcClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv(aParam[1],aParam[2],,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE055P"+aParam[1], .T., .F.)
		ConOut("[ADGPE055P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	// ****************************INICIO INTEGRACAO FUNCIONARIOS PROTHEUS x DIMEP**************************************** //	

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	cLinked := GetMV("MV_#RMLINK",,"RM") 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	
	ConOut("INICIO DO SCHEDULE ADGPE055P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])       
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Adicionado tratativa para colocar a pessoa em quarentena no DMPACESSII por causa do corona Virus, necessário ficar um dia bloqueada no dimep')
	
    logZBN("1") //Log início.

	BloqueioQuar()
	
    logZBN("2") //Log fim.

	ConOut("FINAL DO SCHEDULE ADGPE055P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])

	//Destrava a rotina para o usuário
	UnLockByName("ADGPE055P"+cEmpAnt)

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	

RETURN(NIL)

STATIC FUNCTION BloqueioQuar()

	Local nCont := 0

	FOR nCont := 1 TO 2 //afastamento e ferias

		IF nCont == 1

			SqlAfastamento()

		ELSE 

			SqlFERIAS()

		ENDIF 

		While TRB->(!EOF())

			SqlVFuncDimep(VAL(TRB->CPF))  
			While TRC->(!EOF()) 

				cDataIni := CVALTOCHAR(YEAR(DATE())) + '-' + STRZERO(MONTH(DATE()),2) + '-' + STRZERO(DAY(DATE()),2)

				IF DOW(DATE()) == 6 //Sexta Feira

					cDataFin := CVALTOCHAR(YEAR(DATE() + 3)) + '-' + STRZERO(MONTH(DATE() + 3),2) + '-' + STRZERO(DAY(DATE() + 3),2)

				ELSEIF DOW(DATE()) == 7 //Sabado

					cDataFin := CVALTOCHAR(YEAR(DATE() + 2)) + '-' + STRZERO(MONTH(DATE() + 2),2) + '-' + STRZERO(DAY(DATE() + 2),2)

				ELSE

					cDataFin := CVALTOCHAR(YEAR(DATE() + 1)) + '-' + STRZERO(MONTH(DATE() + 1),2) + '-' + STRZERO(DAY(DATE() + 1),2)

				ENDIF	

				//ALTERA SITUACAO DA FOLHA
				UPDPESS1('CD_SITUACAO_PESSOA',21,VAL(TRB->CPF))
							
				//Integrar situação de pessoa multipla
				INTSITPESSOAMULTIPLA(TRC->CD_PESSOA,20,cDataIni,cDataFin)	
				
				//Integra Historico da Pessoa
				INTHISTSITPESSOA(TRC->CD_PESSOA,11,cDataIni,cDataIni)

				cTexto := 'Bloq Quarentena:'            + ';' + ;
						' Mat: '           + TRB->CPF + ';' + ;
						' Data Ini: '      + cDataIni + ';' + ;
						' Data Final: '    + cDataFin               
						
						
				GERALOG('02',cTexto,'Bloqueio Quarentena')

				TRC->(dbSkip())
						
			ENDDO
			TRC->(dbCloseArea())    
			TRB->(dbSkip())
					
		ENDDO
		TRB->(dbCloseArea())
	NEXT

RETURN(NIL)

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

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTSITPESSOAMULTIPLA: "
	EndIf        
	
RETURN(NIL)

Static Function INTHISTSITPESSOA(nPessoa,nSitFol,cDataIni,cDataFin)

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[HISTORICO_SITUACAO_PESSOA] " 
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

Static Function logZBN(cStatus)

	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE055P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE055P' 
			ZBN_DESCRI  := 'Programa que coloca as pessoas de quarentena no Dimep'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '01:05:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '01:05:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE055P' 
			ZBN_DESCRI  := 'Programa que coloca as pessoas de quarentena no Dimep'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '01:05:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '01:05:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

STATIC FUNCTION GERALOG(cFil,cTexto,cParam)

	DbSelectArea("ZBE")
		Reclock("ZBE",.T.)
			ZBE->ZBE_FILIAL	:= cFil
			ZBE->ZBE_DATA 	:= Date()
			ZBE->ZBE_HORA 	:= cValToChar(Time())
			ZBE->ZBE_USUARI := cUserName
			ZBE->ZBE_LOG 	:= cTexto
			ZBE->ZBE_MODULO := "SIGAGPE"
			ZBE->ZBE_ROTINA := "ADGPE055P" 
			ZBE->ZBE_PARAME := cParam
		MsUnlock()
	ZBE->(DbCloseArea())
	
RETURN(NIL)

Static Function SqlAfastamento()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT PPESSOA.CPF,
				   PFUNC.NOME,
				   PFHSTAFT.CHAPA,
				   TIPO,
				   DTINICIO AS DATAINICIO,
				   DTFINAL AS DATAFIM
			  FROM [VPSRV16].[CORPORERM].[DBO].[PFHSTAFT] WITH (NOLOCK)
		INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PFUNC] WITH (NOLOCK)
				ON PFUNC.CODCOLIGADA = PFHSTAFT.CODCOLIGADA
			   AND PFUNC.CHAPA = PFHSTAFT.CHAPA
		INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PPESSOA] WITH (NOLOCK)
				ON PPESSOA.CODIGO                                   = PFUNC.CODPESSOA
		  	 WHERE DTFINAL     = GETDATE() - 1

			ORDER BY PFHSTAFT.DTINICIO DESC
					
	EndSQl             

	*/

	TRB := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		SELECT PPESSOA.CPF,
	cQuery += "			   PFUNC.NOME,
	cQuery += "			   PFHSTAFT.CHAPA,
	cQuery += "			   TIPO,
	cQuery += "			   DTINICIO AS DATAINICIO,
	cQuery += "			   DTFINAL AS DATAFIM
	cQuery += "		  FROM [" + cSGBD + "].[DBO].[PFHSTAFT] AS PFHSTAFT WITH (NOLOCK)
	cQuery += "	INNER JOIN [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK)
	cQuery += "			ON PFUNC.CODCOLIGADA = PFHSTAFT.CODCOLIGADA
	cQuery += "		   AND PFUNC.CHAPA = PFHSTAFT.CHAPA
	cQuery += "	INNER JOIN [" + cSGBD + "].[DBO].[PPESSOA] AS PPESSOA WITH (NOLOCK)
	cQuery += "			ON PPESSOA.CODIGO                                   = PFUNC.CODPESSOA
	cQuery += "	  	 WHERE DTFINAL     = GETDATE() - 1

	cQuery += "		ORDER BY PFHSTAFT.DTINICIO DESC

	cQuery += " ')

	tcQuery cQuery New Alias TRB
	//

RETURN(NIL)   

Static Function SqlFERIAS()

	// @history TICKET  39     - Fernando Macieir- 27/01/2021 - Projeto RM Cloud
	
	/*

	BeginSQL Alias "TRB"
			%NoPARSER%
			     SELECT PPESSOA.CPF,
						PFUNC.NOME,
						PFUFERIASPER.CHAPA,
						SITUACAOFERIAS,
						DATAINICIO,
						DATAFIM
				   FROM [VPSRV16].[CORPORERM].[DBO].[PFUFERIASPER] WITH (NOLOCK)
			 INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PFUFERIASRECIBO] WITH (NOLOCK)
					 ON PFUFERIASRECIBO.CODCOLIGADA = PFUFERIASPER.CODCOLIGADA
					AND PFUFERIASRECIBO.CHAPA       = PFUFERIASPER.CHAPA
					AND PFUFERIASRECIBO.DATAPAGTO   = PFUFERIASPER.DATAPAGTO
			 INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PFUNC] WITH (NOLOCK)
					 ON PFUNC.CODCOLIGADA           = PFUFERIASRECIBO.CODCOLIGADA
					AND PFUNC.CHAPA                 = PFUFERIASRECIBO.CHAPA
			 INNER JOIN [VPSRV16].[CORPORERM].[DBO].[PPESSOA] WITH (NOLOCK)
					 ON PPESSOA.CODIGO              = PFUNC.CODPESSOA
			 	  WHERE DATAFIM                     = GETDATE() - 1
				ORDER BY PFUFERIASPER.DATAINICIO DESC

	EndSQl             

	*/

	TRB := GetNextAlias()

	cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '

	cQuery += "		     SELECT PPESSOA.CPF,
	cQuery += "					PFUNC.NOME,
	cQuery += "					PFUFERIASPER.CHAPA,
	cQuery += "					SITUACAOFERIAS,
	cQuery += "					DATAINICIO,
	cQuery += "					DATAFIM
	cQuery += "			   FROM [" + cSGBD + "].[DBO].[PFUFERIASPER] AS PFUFERIASPER WITH (NOLOCK)
	cQuery += "		 INNER JOIN [" + cSGBD + "].[DBO].[PFUFERIASRECIBO] AS PFUFERIASRECIBO WITH (NOLOCK)
	cQuery += "				 ON PFUFERIASRECIBO.CODCOLIGADA = PFUFERIASPER.CODCOLIGADA
	cQuery += "				AND PFUFERIASRECIBO.CHAPA       = PFUFERIASPER.CHAPA
	cQuery += "				AND PFUFERIASRECIBO.DATAPAGTO   = PFUFERIASPER.DATAPAGTO
	cQuery += "		 INNER JOIN [" + cSGBD + "].[DBO].[PFUNC] AS PFUNC WITH (NOLOCK)
	cQuery += "				 ON PFUNC.CODCOLIGADA           = PFUFERIASRECIBO.CODCOLIGADA
	cQuery += "				AND PFUNC.CHAPA                 = PFUFERIASRECIBO.CHAPA
	cQuery += "		 INNER JOIN [" + cSGBD + "].[DBO].[PPESSOA] AS PPESSOA WITH (NOLOCK)
	cQuery += "				 ON PPESSOA.CODIGO              = PFUNC.CODPESSOA
	cQuery += "		 	  WHERE DATAFIM                     = GETDATE() - 1
	cQuery += "			ORDER BY PFUFERIASPER.DATAINICIO DESC

	cQuery += " ')

	tcQuery cQuery New Alias TRB
	//

RETURN(NIL)   

Static Function SqlVFuncDimep(cMat)

	BeginSQL Alias "TRC"
			%NoPARSER%
            SELECT * 
              FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA] AS PESSOA WITH (NOLOCK)
             WHERE NU_MATRICULA       = %EXP:cMat%
               		
	EndSQl

RETURN(NIL)   

STATIC FUNCTION UPDPESS1(cCampo1,cCampo2,nMat)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[PESSOA] " 
	cQuery += " SET " + cCampo1 + " = " + ""  + cvaltochar(cCampo2) + ""
	cQuery += " WHERE NU_MATRICULA  = " + "" + cvaltochar(nMat) + "" // chamado 053384 - WILLIAM COSTA - 14/11/2019
    
	If (TCSQLExec(cQuery) < 0) .OR. ALLTRIM(CVALTOCHAR(cCampo2)) == '0'
    	cIntregou += " TCSQLError() - UPDPESS1: " + 'cCampo1: ' + cCampo1 + 'cCampo2:' + cvaltochar(cCampo2)
	EndIf        
	
RETURN(NIL)
