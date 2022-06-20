#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 

/*{Protheus.doc} User Function ADGPE057P
	Programa de Integração entre Protheus X Dimep Marcação de Terceiros
	@type  Function
	@author WILLIAM COSTA
	@since 10/06/2016
	@version 01
    @history TICKET  224    - William Costa   - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
    @history TICKET  12207  - Adriano Savoine - 14/04/2021 - Inserido novo equipamento para gravar na tabela de terceiros e aparecer no relatorio.
    @history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
*/	

User Function ADGPE057P()

    // ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //
    RpcClearEnv()
    RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
    // ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE057P", .T., .F.)
		ConOut("[ADGPE057P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Integração entre Protheus X Dimep Marcação de Terceiros')
    
    // @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
    //FWMonitorMsg(ALLTRIM(PROCNAME()))

    ConOut("INICIANDO DO SCHEDULE ADGPE057P" + ' ' + TIME())
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule  

    SqlMarcacao()
    While TRB->(!EOF())

        DbSelectArea("ZG1") 
        ZG1->(DbSetOrder(2))
        ZG1->(DbGoTop()) 
        IF !DbSeek(FWxFilial("ZG1") + CVALTOCHAR(TRB->CD_LOG_ACESSO),.F.)

            RECLOCK("ZG1",.T.)

                ZG1->ZG1_FILIAL := FWxFilial("ZG1")
                ZG1->ZG1_PREFIX := 'AUT'
                ZG1->ZG1_IDPROT := BUSCAIDPROTHEUS()
                ZG1->ZG1_LOGACE := CVALTOCHAR(TRB->CD_LOG_ACESSO)
                ZG1->ZG1_CREDEN := TRB->NU_CREDENCIAL
                ZG1->ZG1_TPAUTE := TRB->TP_AUTENTICACAO
                ZG1->ZG1_MAT    := CVALTOCHAR(TRB->NU_MATRICULA)
                ZG1->ZG1_NOMEPE := TRB->NM_PESSOA
                ZG1->ZG1_CDESTR := TRB->CD_ESTRUTURA
                ZG1->ZG1_NUESTR := ALLTRIM(TRB->NU_ESTRUTURA)
                ZG1->ZG1_NMESTR := TRB->NM_ESTRUTURA
                ZG1->ZG1_CDGRUP := TRB->CD_GRUPO
                ZG1->ZG1_DSGRUP := TRB->DS_GRUPO
                ZG1->ZG1_AORIGE := TRB->CD_AREA_ORIGEM
                ZG1->ZG1_DAORIG := TRB->DS_AREA_ORIGEM
                ZG1->ZG1_ADESTI := TRB->CD_AREA_DESTINO
                ZG1->ZG1_DADEST := TRB->DS_AREA_DESTINO
                ZG1->ZG1_CDEQUI := TRB->CD_EQUIPAMENTO
                ZG1->ZG1_DEQUIP := TRB->DS_EQUIPAMENTO
                ZG1->ZG1_NUEQUI := TRB->NU_EQUIPAMENTO
                ZG1->ZG1_TPEVEN := TRB->TP_EVENTO
                ZG1->ZG1_DATA   := STOD(STRTRAN(SUBSTR(TRB->DT_REQUISICAO,1,10),'-',''))
                ZG1->ZG1_HORA   := SUBSTR(TRB->DT_REQUISICAO,12,08)
                ZG1->ZG1_SENTID := BUSCASENTIDO(CVALTOCHAR(TRB->NU_MATRICULA))

            MSUNLOCK()

            GRAVARLOG(Date(),TIME(),cUserName,"INTEGRAÇÃO DIMEP BATIDA MANUTENÇÃO","PORTARIA","ADGPE057P",;
                "Integrado Batida:" + CVALTOCHAR(TRB->CD_LOG_ACESSO) + " Data: " + STRTRAN(SUBSTR(TRB->DT_REQUISICAO,1,10),'-','') + " Hora: " + SUBSTR(TRB->DT_REQUISICAO,12,08),ComputerName(),LogUserName())

        ENDIF

        TRB->(dbSkip())
		
    ENDDO //FECHA WHILE DO TRC
    
    TRB->(dbCloseArea()) 

    //INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule  

	ConOut("FINAL DO SCHEDULE ADGPE057P" + ' ' + TIME())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADGPE057P")

    // ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
    RpcClearEnv() 
    // ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

RETURN(NIL)

STATIC FUNCTION BUSCAIDPROTHEUS()

    Local cId := '0000000000000001'

    SqlZG1()
    While TRC->(!EOF())

        cId := STRZERO(VAL(SUBSTR(TRC->ZG1_IDPROT,4,13)) + 1,16)

     TRC->(dbSkip())
		
    ENDDO //FECHA WHILE DO TRC
    
    TRC->(dbCloseArea()) 

RETURN(cId)

STATIC FUNCTION BUSCASENTIDO(cMat)

    Local cSentido := '1' //Entrada

    SqlSentido(cMat)
    While TRD->(!EOF())

        IF ALLTRIM(TRD->ZG1_SENTID) == '1' // Entrada

           cSentido := '2' //Proximo Sentido saida 2

        ELSE 

           cSentido := '1' //Proximo Sentido Entrada 1

        ENDIF    

     TRD->(dbSkip())
		
    ENDDO //FECHA WHILE DO TRD
    
    TRD->(dbCloseArea()) 

RETURN(cSentido)

Static Function logZBN(cStatus)

	Local aArea	:= GetArea()        
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE057P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := FWxFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE057P'
			ZBN_DESCRI  := 'Integração Marcação Terceiros Manutenção'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '08:00:00'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := FWxFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE057P'
			ZBN_DESCRI  := 'Integração Marcação Terceiros Manutenção'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '08:00:00'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

STATIC FUNCTION GRAVARLOG(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)

    Local aArea := GetArea()

    //log de alteração de data de entrega	
    DbSelectArea("ZG2")
    If RecLock("ZG2",.T.)//incluido if para certificar que o registro foi travado em 23/08/2017 por Adriana 
        Replace ZG2_FILIAL 	WITH xFilial("ZG2")
        Replace ZG2_DATA 	WITH dDate
        Replace ZG2_HORA 	WITH cTime
        Replace ZG2_USUARI	WITH UPPER(Alltrim(cUser))
        Replace ZG2_LOG	    WITH ALLTRIM(cLog)
        Replace ZG2_MODULO	WITH cModulo
        Replace ZG2_ROTINA	WITH cRotina
        Replace ZG2_PARAME  WITH ALLTRIM(cParamer)
        Replace ZG2_EQUIPA  WITH UPPER(Alltrim(cEquipam))
        Replace ZG2_USURED  WITH UPPER(Alltrim(cUserRed))
        ZG2->(MsUnlock())    
    endif	

    RestArea(aArea)


RETURN(NIL)

STATIC FUNCTION SqlMarcacao()

    BeginSQL Alias "TRB"
			%NoPARSER% 
				 SELECT CD_LOG_ACESSO,
                        NU_CREDENCIAL,
                        TP_AUTENTICACAO,
                        NU_MATRICULA,
                        NM_PESSOA,
                        CD_ESTRUTURA,
                        NU_ESTRUTURA,
                        ESTRUTURA_ORGANIZACIONAL.NM_ESTRUTURA,
                        CD_GRUPO,
                        DS_GRUPO,
                        CD_AREA_ORIGEM,
                        DS_AREA_ORIGEM,
                        CD_AREA_DESTINO,
                        DS_AREA_DESTINO,
                        CD_EQUIPAMENTO,
                        DS_EQUIPAMENTO,
                        NU_EQUIPAMENTO,
                        TP_EVENTO,
                        TP_SENTIDO_CONSULTA,
                        CONVERT(VARCHAR(23), DT_REQUISICAO, 121) AS DT_REQUISICAO
                    FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO
                    INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
			                ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = LOG_ACESSO.CD_ESTRUTURA
                    WHERE CD_EQUIPAMENTO IN ('19','22') // TICKET 12207 - ADRIANO SAVOINE - 14/04/2021
                        AND CD_VISITANTE IS NULL 
                        AND TP_AUTENTICACAO IS NOT NULL
	                    AND NU_DATA_REQUISICAO >= CONVERT(VARCHAR(8), (GETDATE() - 1), 112)
                        
                    ORDER BY LOG_ACESSO.CD_LOG_ACESSO 
	EndSQl          

RETURN(NIL)

STATIC FUNCTION SqlZG1()

    BeginSQL Alias "TRC"
			%NoPARSER% 
				 SELECT TOP(1) ZG1_IDPROT
                    FROM %TABLE:ZG1%
                        
                    ORDER BY ZG1_IDPROT DESC 
	EndSQl          

RETURN(NIL)

STATIC FUNCTION SqlSentido(cMat)

    Local cFilAtu:= FWXFILIAL("ZG1")

    BeginSQL Alias "TRD"
			%NoPARSER% 
			SELECT TOP(1) ZG1_SENTID
              FROM ZG1010
             WHERE ZG1_FILIAL = %EXP:cFilAtu%
               AND ZG1_MAT    = %EXP:cMat%
               AND D_E_L_E_T_ <> '*'

            ORDER BY ZG1_IDPROT DESC 
	EndSQl          

RETURN(NIL)
