#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADGPE050R
	WORKFLOW DE ENVIO DE OCORRENCIAS DE PESSOAS DE FERIAS OU AFASTADAS PELO PROTHEUS QUE NAO ESTA CORRETO NA DIMEP.
	@type  Function
	@author William Costa
	@since 13/06/2019
	@version 01
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/
               
USER FUNCTION ADGPE050R()  

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RpcClearEnv()
    RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADGPE050R", .T., .F.)
		ConOut("[ADGPE050R] - Existe outro processamento sendo executado! Verifique...")
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
	UnLockByName("ADGPE050R")

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

RETURN()

STATIC FUNCTION EmailInformatica(cMetodo)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#EMADI2"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
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
	   cSubject := "Workflow Dimep Ferias ou Afastamento"          
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
	cRet += "'><b>Workflow Dimep............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'DIMEP' 
 	
	    cRet += " Ocorrências de pessoas de Ferias ou Afastameto sem trava de Bloqueio por Periodo, Favor verificar!!!"
	    cRet += "<br>"
	    cRet += "<br>" 
	   
	    cRet += "<table border='1'>" 
	    
	    cRet += "<tr>"
		cRet += "<td>CD_PESSOA</td>"
		cRet += "<td>NU_MATRICULA</td>"
		cRet += "<td>NM_PESSOA</td>"
		cRet += "</tr>"
		
		SqlDimep()
		While TRB->(!EOF())  
		
			cRet += "<tr>"
			cRet += "<td>" + CVALTOCHAR(TRB->CD_PESSOA)    + "</td>"
			cRet += "<td>" + CVALTOCHAR(TRB->NU_MATRICULA) + "</td>"
			cRet += "<td>" + TRB->NM_PESSOA                + "</td>"
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

	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG013R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADGPE050R'
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
			ZBN_ROTINA	:= 'ADGPE050R'
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
			SELECT CD_PESSOA,NU_MATRICULA,NM_PESSOA 
			  FROM [DIMEP].[DMPACESSOII].[DBO].[PESSOA]
			  WHERE CD_SITUACAO_PESSOA = 13
			    AND CD_PESSOA NOT IN (SELECT CD_PESSOA 
			                            FROM [DIMEP].[DMPACESSOII].[DBO].[SITUACAO_PESSOA_MULTIPLA] 
			                           WHERE SITUACAO_PESSOA_MULTIPLA.CD_PESSOA = PESSOA.CD_PESSOA)
			  
	EndSQl             
RETURN(NIL)
