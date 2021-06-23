#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADGPE046
	Integracao com o sistema DIMEP de catracas Gerar Tipo de Autorizacao Excepcional por matricula e Filial e Deletar Autorizacao Excepcional de Funcionarios Deletados.
	@type  Function
	@author William Costa
	@since 20/03/2019
	@version 01
	@history Chamado TI     - William Costa   - 27/05/2019 - Chamado TI, para correcao error.log type mismatch on +  on DELAUTORI(ADGPE046P.PRW)
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
/*/

USER FUNCTION ADGPE046P(aParam)

	Local nTipoAut     	:= 0
	
	aParam := {'01','02'} // Voltar WILL
	cIntregou			:= "" // Incluido por Adriana em 27/05/2019 - CHAMADO TI
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RpcClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv(aParam[1],aParam[2],,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	
	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE046P", .T., .F.)
		ConOut("[ADGPE046P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //

	PtInternal(1,ALLTRIM(PROCNAME()))
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao com o sistema DIMEP de catracas Gerar Tipo de Autorizacao Excepcional por matricula e Filial e Deletar Autorizacao Excepcional de Funcionarios Deletados.')

	ConOut("INICIO DO SCHEDULE ADGPE046P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])       
	
	logZBN("1") //Log início.	
	
	// *** INICIO INCLUSAO DE TIPO DE AUTORIZACAO *** //
	
	SqlPessoa()
	While TRB->(!EOF()) 

		SqlTPAUT(ALLTRIM(TRB->NU_CPF) + '-' + TRB->TIPO_PESSOA)
		
		IF TRC->(EOF())

			INTTIPOAUTORIZACAO(ALLTRIM(TRB->NU_CPF) + '-' + TRB->TIPO_PESSOA)

			TRC->(dbCloseArea())

			SqlTPAUT(ALLTRIM(TRB->NU_CPF) + '-' + TRB->TIPO_PESSOA)
			
			IF TRC->(!EOF())

				INTUSUSISTPAUT(TRC->CD_TIPO_AUTORIZACAO)

			ENDIF	

	    ENDIF
		TRC->(dbCloseArea())

		TRB->(dbSkip())
    ENDDO
    TRB->(dbCloseArea())
    
    // *** FINAL INCLUSAO DE TIPO DE AUTORIZACAO  *** //
   
    
    logZBN("2") //Log fim.

	ConOut("FINAL DO SCHEDULE ADGPE046P" + '||' + DTOC(DATE()) + '||' + TIME() + '|| Empresa:' + aParam[1] + '|| Filial:' + aParam[2])

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADGPE046P")

	RpcClearEnv() 

	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	

RETURN(NIL)

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Local aArea	       := GetArea()        
	Local cHoraProx    := '' 
	Local dDtProx      := dDataBase + 1
	                          
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADGPE046P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE046P'
			ZBN_DESCRI  := 'Integração Tipo Autorizacao'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := ''
			ZBN_PERDES  := ''
			ZBN_QTDVEZ  := 0
			ZBN_HORAIN  := '00:30:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE046P'
			ZBN_DESCRI  := 'Integração Tipo Autorizacao'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := ''
			ZBN_PERDES  := ''
			ZBN_QTDVEZ  := 0
			ZBN_HORAIN  := '00:30:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

Static Function SqlPessoa()

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT NU_CPF,CASE WHEN CD_ESTRUTURA_RELACIONADA = 1223 THEN 'TERCEIRO' ELSE 'FUNCIONARIO' END AS TIPO_PESSOA
			  FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA]
		INNER JOIN [DIMEP].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] AS ESTRUTURA_ORGANIZACIONAL
				ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
			 WHERE CD_SITUACAO_PESSOA <> '12'
			   AND NU_MATRICULA       <> 22
			   AND NU_MATRICULA       <> 23
			   AND NU_MATRICULA       <> 14233
			   AND NU_MATRICULA       <> 3104
			   AND NU_MATRICULA       <> 2109
			   AND NU_MATRICULA       <> 15693
			   AND NU_MATRICULA       <> 14986
			   AND NU_MATRICULA       < 999999999999999900
			   AND NU_CPF             IS NOT NULL
			   AND NU_CPF             <> ''

			   ORDER BY NU_CPF

			
			
	EndSQl             
RETURN(NIL)

Static Function SqlTPAUT(cMat)

    cQuery := " SELECT CD_TIPO_AUTORIZACAO,DS_TIPO_AUTORIZACAO "
    cQuery += " FROM [DIMEP].[DMPACESSOII].[DBO].[TIPO_AUTORIZACAO]  WITH (NOLOCK) "
    cQuery += " WHERE DS_TIPO_AUTORIZACAO LIKE '%"+cMat+"%' "

	TCQUERY cQuery new alias "TRC"
             
RETURN(NIL)

Static Function INTUSUSISTPAUT(nTipoAut)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[USU_SIS_TIPO_AUTORIZACAO] " 
	cQuery += "(CD_TIPO_AUTORIZACAO, " 
	cQuery += "CD_USUARIO, " 
    cQuery += "DT_PERSISTENCIA " 
    cQuery += ") "
	cQuery += "VALUES (" + " '" + CVALTOCHAR(nTipoAut) + "'," // Tipo Autorizacao
	cQuery += ""                + '1'                  + ","  // Usuario Admin
    cQuery += ""                + 'GETDATE()'          + " "  // DT_PERSISTENCIA
    cQuery += ") " 

	If (TCSQLExec(cQuery) < 0)
    	cIntregou += " TCSQLError() - INTUSUSISTPAUT: " 
	EndIf        
	
RETURN(NIL)

Static Function INTTIPOAUTORIZACAO(cDesc)   	      	 	  

	cQuery := "INSERT INTO [DIMEP].[DMPACESSOII].[dbo].[TIPO_AUTORIZACAO] " 
	cQuery += "(DS_TIPO_AUTORIZACAO) " 
	cQuery += "VALUES ('"  + cDesc + "')" 
	
	IF (TCSQLExec(cQuery) < 0)

		cIntregou += " TCSQLError() - INTTIPOAUTORIZACAO: " 
		
	ENDIF
	
RETURN(NIL)
