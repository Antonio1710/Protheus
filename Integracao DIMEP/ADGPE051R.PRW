#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADGPE051R
	(WORKFLOW DE ENVIO DE OCORRENCIAS DE TERCEIROS QUE IRAM VENCER ASO, INTEGRACAO OU CONTRATO)
	@type  WORKFLOW DIMEP - SCHEDULE
	@author William Costa
	@since 13/06/2019
	@version 01
	@history Chamado: 057108 - Adriano Savoine - 06/04/2020 - Alteração da Ordenação do relatorio Ordenando a Estrutura e o nome da pessoa dentro da estrutura ordenada.
	@history TICKET  224     - William Costa   - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Ticket  77205  - Adriano Savoine  - 28/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
/*/
USER FUNCTION ADGPE051R()  

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
    RpcClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE051R", .T., .F.)
		ConOut("[ADGPE051R] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut("INICIO DO SCHEDULE ADGPE050R")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'WORKFLOW DE ENVIO DE OCORRENCIAS DE TERCEIROS QUE IRAM VENCER ASO, INTEGRACAO OU CONTRATO')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

    cMetodo := 'DIMEP'
    
    SqlDimep()

	IF TRB->(!EOF())  
	
		TRB->(dbCloseArea())
		EmailInformatica(cMetodo)
		
	ENDIF
	
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule    

    ConOut("FINAL DO SCHEDULE ADGPE050R")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADGPE051R")

    // ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

RETURN()

STATIC FUNCTION EmailInformatica(cMetodo)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#EMADIM"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    
	// ********************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
         
    _cStatEml    := cMetodo 
    cBody        := RetHTML(_cStatEml)
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
	   cSubject := "Workflow Dimep Terceiros Vencimento Aso, Integracao ou Contrato"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL) 

Static Function RetHTML(_cStatEml)

	Local cRet       := "" 
	Local nCont      := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>Workflow Dimep Período de: " + DTOC(DATE()) + " até: " + DTOC(DATE() + GetMv("MV_#DIATER",,60)) + "</b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'DIMEP' 
 	
	    cRet += " Ocorrências de terceiros que irão vencer o Aso, Integracao ou Contrato nos próximos " + CVALTOCHAR(GetMv("MV_#DIATER",,60)) + " dias, Favor verificar!!!"
	    cRet += "<br>"
	    cRet += "<br>" 
	   
	    cRet += "<table border='1'>" 
	    
	    cRet += "<tr>"
	    cRet += "<td>CONTADOR                    </td>"
		cRet += "<td>NOME TERCEIRO               </td>"
		cRet += "<td>MATRICULA                   </td>"
		cRet += "<td>DATA VENCIMENTO ASO         </td>"
		cRet += "<td>DATA VENCIMENTO INTEGRACAO  </td>"
		cRet += "<td>DATA VENCIMENTO CONTRATO    </td>"
		cRet += "<td>DATA ULTIMA PASSSAGEM DIMEP </td>"
		cRet += "<td>NOME ESTRUTURA              </td>"
		cRet += "<td>RAZAO SOCIAL                </td>"
		cRet += "<td>CNPJ                        </td>"
		cRet += "</tr>"
	
		SqlDimep()
		While TRB->(!EOF())  
		
			// *** INICIO VALIDACOES *** //
			IF DTOC(CTOD(TRB->VENC_ASO))        == 	"  /  /  " .AND. ;
			   DTOC(CTOD(TRB->VENC_INTEGRACAO)) == 	"  /  /  " .AND. ;
			   DTOC(CTOD(TRB->VENC_CONTRATO))   == 	"  /  /  "
			   
			   TRB->(dbSkip())
			   LOOP
			
			ENDIF
			
			// Validacao Data Aso
			IF DTOC(CTOD(TRB->VENC_ASO)) <> 	"  /  /  " 
			
				IF (CTOD(TRB->VENC_ASO)       < DATE()        .OR. ;
			        CTOD(TRB->VENC_ASO)       > (DATE() + GetMv("MV_#DIATER",,60)))
			     
				   TRB->(dbSkip())
				   LOOP
				   
				ENDIF
			ENDIF
			
			// Validacao Data Integracao
			IF DTOC(CTOD(TRB->VENC_INTEGRACAO)) <> 	"  /  /  " 
			
				IF (CTOD(TRB->VENC_INTEGRACAO)       < DATE()        .OR. ;
			        CTOD(TRB->VENC_INTEGRACAO)       > (DATE() + GetMv("MV_#DIATER",,60)))
			    
				   TRB->(dbSkip())
				   LOOP
				   
				ENDIF
			ENDIF
			
			// Validacao Data Contrato
			IF DTOC(CTOD(TRB->VENC_CONTRATO)) <> 	"  /  /  "
			
				IF (CTOD(TRB->VENC_CONTRATO)       < DATE()        .OR. ;
			        CTOD(TRB->VENC_CONTRATO)       > (DATE() + GetMv("MV_#DIATER",,60)))
			    
				   TRB->(dbSkip())
				   LOOP
				   
			   ENDIF
			ENDIF
			
			// *** FINAL VALIDACOES *** // 
			nCont := nCont + 1
			
			cRet += "<tr>"
			cRet += "<td>" + CVALTOCHAR(nCont)                                                                                     + "</td>"
			cRet += "<td>" + TRB->NM_PESSOA                                                                                        + "</td>"
			cRet += "<td>" + ALLTRIM(STR(TRB->NU_MATRICULA))                                                                       + "</td>"
			cRet += "<td>" + TRB->VENC_ASO                                                                                         + "</td>"
			cRet += "<td>" + TRB->VENC_INTEGRACAO                                                                                  + "</td>"
			cRet += "<td>" + TRB->VENC_CONTRATO                                                                                    + "</td>"
			cRet += "<td>" + IIF(TRB->DATA_ULTIMA_PASSAGEM_DIMEP <> 0,DTOC(STOD(CVALTOCHAR(TRB->DATA_ULTIMA_PASSAGEM_DIMEP))),'')  + "</td>"
			cRet += "<td>" + TRB->NM_ESTRUTURA                                                                                     + "</td>"
			cRet += "<td>" + TRB->DS_RAZAO_SOCIAL                                                                                  + "</td>"
			cRet += "<td>" + CVALTOCHAR(TRB->NU_CNPJ)                                                                              + "</td>"
			cRet += "</tr>"
			
	        TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())  
		
	   	cRet += "</table>"   

	ENDIF	
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet) 

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG013R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE051R'
			ZBN_DESCRI  := 'Workflow para Dimep Pessoa de Ferias ou Afastamento'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE051R'
			ZBN_DESCRI  := 'Workflow para Dimep Pessoa de Ferias ou Afastamento'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
 
Static Function SqlDimep()

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT NM_PESSOA,
			       NU_MATRICULA,
			       CASE WHEN TX_CAMPO01 <> '' THEN SUBSTRING(TX_CAMPO01,9,2) + '/' + SUBSTRING(TX_CAMPO01,6,2) + '/' + SUBSTRING(TX_CAMPO01,1,4) ELSE '' END AS VENC_ASO,
			       CASE WHEN TX_CAMPO02 <> '' THEN SUBSTRING(TX_CAMPO02,9,2) + '/' + SUBSTRING(TX_CAMPO02,6,2) + '/' + SUBSTRING(TX_CAMPO02,1,4) ELSE '' END AS VENC_INTEGRACAO,
			       CASE WHEN TX_CAMPO03 <> '' THEN SUBSTRING(TX_CAMPO03,9,2) + '/' + SUBSTRING(TX_CAMPO03,6,2) + '/' + SUBSTRING(TX_CAMPO03,1,4) ELSE '' END VENC_CONTRATO, 
			       ISNULL((SELECT TOP(1) NU_DATA_REQUISICAO FROM [DMPACESSO].[DMPACESSOII].[DBO].[LOG_ACESSO] WHERE LOG_ACESSO.NU_MATRICULA = PESSOA.NU_MATRICULA ORDER BY LOG_ACESSO.NU_DATA_REQUISICAO DESC),0) AS DATA_ULTIMA_PASSAGEM_DIMEP,
			       NM_ESTRUTURA,
			       DS_RAZAO_SOCIAL,
			       NU_CNPJ
			  FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA]
			  INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL]
			          ON PESSOA.CD_ESTRUTURA_ORGANIZACIONAL = ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL
			  WHERE NU_MATRICULA >= 0
			    AND NU_MATRICULA <= 9999999999999
			    AND (TX_CAMPO01 <> ''
			     OR TX_CAMPO02 <> ''
			     OR TX_CAMPO03 <> '') 
			     
			ORDER BY LTRIM(NM_ESTRUTURA),LTRIM(NM_PESSOA) // CHAMADO: 057108 - ADRIANO SAVOINE 06/04/2020
			  
	EndSQl 

RETURN(NIL)
