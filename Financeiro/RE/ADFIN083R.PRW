#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#Include "topconn.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function ADFIN083R
	WORKFLOW DE ENVIO PARA QUANDO UMA REDE FICA DUPLICADA PARA AVALIAÇÃO DA T.I E FINANCEIRO
	@author William Costa
	@since 12/02/2020
	@version 01
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	
/*/
               
USER FUNCTION ADFIN083R()  

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
    RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADFIN083R", .T., .F.)
		ConOut("[ADFIN083R] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut("INICIO DO SCHEDULE ADLOG013R")

	//@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'WORKFLOW DE ENVIO PARA QUANDO UMA REDE FICA DUPLICADA PARA AVALIAÇÃO DA T.I E FINANCEIRO')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

    cMetodo := 'FINANCEIRO'
    
    EmailInformatica(cMetodo)

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule    

    ConOut("FINAL DO SCHEDULE ADLOG013R")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIN083R")

    // ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

RETURN()

STATIC FUNCTION EmailInformatica(cMetodo)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#USUMAI"))
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
	   cSubject := "WORKFLOW FINANCEIRO EXISTE REDE DUPLICADA"          
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
	cRet += "'><b>WORKFLOW FINANCEIRO............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'FINANCEIRO' 
 	
	    cRet += " Redes Duplicadas, Favor verificar!!!"
	    cRet += "<br>"
	    cRet += "<br>" 
	   
	    cRet += "<table border='1'>" 
	    
	    cRet += "<tr>"
		cRet += "<td>Nome Rede</td>"
		cRet += "<td>Qtd Duplicadas</td>"
		cRet += "<td>Valor</td>"
		cRet += "</tr>"
		
		SqlFinanceiro()
		While TRB->(!EOF())  
		
			cRet += "<tr>"
			cRet += "<td>" + TRB->ZF_REDE          + "</td>"
			cRet += "<td>" + ALLTRIM(TRANSFORM(TRB->QTDE,"@E 9,999")) + "</td>"

			SqlRede(TRB->ZF_REDE)
			While TRC->(!EOF())  
			
				cRet += "<td>" +  ALLTRIM(TRANSFORM(TRC->VALOR," @E 999,999,999.99")) + "</td>"

				TRC->(dbSkip())
			ENDDO
			TRC->(dbCloseArea())  

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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN083R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN083R'
			ZBN_DESCRI  := 'WORKFLOW DE ENVIO PARA QUANDO UMA REDE FICA DUPLICADA PARA AVALIAÇÃO DA T.I E FINANCEIRO'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '16:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '16:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN083R'
			ZBN_DESCRI  := 'WORKFLOW DE ENVIO PARA QUANDO UMA REDE FICA DUPLICADA PARA AVALIAÇÃO DA T.I E FINANCEIRO'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '16:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '16:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
 
Static Function SqlFinanceiro()

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT SZF.ZF_REDE, COUNT(*) QTDE
			  FROM (SELECT ZF_REDE, COUNT(*) QTDE
			   		  FROM %TABLE:SZF%
					 WHERE %TABLE:SZF%.D_E_L_E_T_ <> '*'
				     GROUP BY ZF_REDE
					 HAVING COUNT(*) > 1) AS REDE, %TABLE:SZF% SZF
			WHERE REDE.ZF_REDE = SZF.ZF_REDE
			  AND SZF.D_E_L_E_T_ <> '*'
			  AND ZF_LCREDE > 0
			GROUP BY SZF.ZF_REDE
			HAVING  COUNT(*) > 1
  
	EndSQl             
RETURN(NIL)

Static Function SqlREDE(cRede)

	BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT SUM(ZF_LCREDE) AS VALOR 
			  FROM %TABLE:SZF%
			 WHERE ZF_REDE = %EXP:cRede%
			   AND D_E_L_E_T_ <> '*'
			  
	EndSQl             
RETURN(NIL)
