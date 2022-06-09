#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} User Function ADGPE038P
	Programa que altera o campo TX_CAMPO1 do visitante para poder agendar o visitante diversos dias da semana
	@type  Function
	@author William COSTA 
	@since 17/07/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/
USER FUNCTION ADGPE038P()

	Local cNovadata := ''
	Local cData     := '' 
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
    RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE038P", .T., .F.)
		ConOut("[ADGPE038P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	ConOut("INICIO DO SCHEDULE ADGPE038P " + ALLTRIM(FUNNAME()) + ' ' + TIME())
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa que altera o campo TX_CAMPO1 do visitante para poder agendar o visitante diversos dias da semana')
	logZBN("1") //Log início.
	
	cData := CVALTOCHAR(DAY(DATE()))+"/"+STRZERO(MONTH(DATE()),2)+"/"+CVALTOCHAR(YEAR(DATE()))
	
	SqlVisita(cData)
	
	DBSELECTAREA("TRB")
	TRB->(DBGOTOP())
	WHILE TRB->(!EOF())
	
		IF !EMPTY(TRB->DT_VISITA)
		
		 	cNovadata := CVALTOCHAR(YEAR(TRB->DT_VISITA)) + '-' + SUBSTRING(DTOC(TRB->DT_VISITA),4,2) + '-' + SUBSTRING(DTOC(TRB->DT_VISITA),1,2) + 'T00:00'
		 	
		 	ConOut("ADGPE038P -" + ALLTRIM(TRB->NM_VISITANTE))
		 	
		 	UPDVISITANTE(cNovadata,TRB->CD_VISITANTE)
	 	
	    ENDIF
		TRB->(dbSkip())    
			
	ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )
	
	logZBN("2") //Log fim.
	
	ConOut("FINAL DO SCHEDULE ADGPE038P " + ALLTRIM(FUNNAME()) + ' ' + TIME())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADGPE038P")

   	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	
	
RETURN(NIL)

Static Function SqlVisita(cData)

	Local cFilAtu := ''

	BeginSQL Alias "TRB"
			%NoPARSER%
			    SELECT CD_VISITA,
				       VISITA.CD_VISITANTE,
				       NM_VISITANTE,
				       NU_DOCUMENTO,
				       DT_VISITA, 
				       TX_CAMPO1
				  FROM [DIMEP].[DMPACESSOII].[DBO].[VISITA] AS VISITA
				  INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[VISITANTE] AS VISITANTE
				          ON VISITANTE.CD_VISITANTE  = VISITA.CD_VISITANTE
				       WHERE DT_VISITA               = CONVERT(DATETIME,%EXP:cData%,103)
				         AND DT_BAIXA_CREDENCIAL     IS NULL
				         AND DT_VISITA              <> CONVERT(DATETIME,SUBSTRING(TX_CAMPO1, 9, 2) + '/' + SUBSTRING(TX_CAMPO1, 6, 2) + '/' + LEFT(TX_CAMPO1, 4),103)
										
	EndSQl             
    
RETURN()

STATIC FUNCTION UPDVISITANTE(cCampo1,cCodVisitante)

	cQuery := " UPDATE [DIMEP].[DMPACESSOII].[dbo].[VISITANTE] " 
	cQuery += " SET  TX_CAMPO1    = " + "'" + cCampo1 + "'"
	cQuery += " WHERE CD_VISITANTE = " + ""  + cvaltochar(cCodVisitante) + ""
	
    TCSQLExec(cQuery)
    	
RETURN(NIL) 

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE038P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE038P'
			ZBN_DESCRI  := 'altera o campo TX_CAMPO1 do visitante, DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '00:05:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '00:05:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE038P'
			ZBN_DESCRI  := 'altera o campo TX_CAMPO1 do visitante, DIMEP'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '00:05:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '00:05:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil 
