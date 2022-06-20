#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADLOG013R บAutor  ณWilliam Costa       บ Data ณ  18/01/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWORKFLOW DE ENVIO DE OCORRENCIAS DA LOGISTICA NAO FECHADAS  บฑฑ
ฑฑบ          ณPELA LOGISTICA DESDE 01/01/2016                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WORKFLOW LOGISTICA -SCHEDULE                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION ADLOG013R()  

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
    RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automแticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

	// Garanto uma ๚nica thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADLOG013R", .T., .F.)
		ConOut("[ADLOG013R] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut("INICIO DO SCHEDULE ADLOG013R")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'WORKFLOW DE ENVIO DE OCORRENCIAS DA LOGISTICA NAO FECHADAS PELA LOGISTICA DESDE 01/01/2016')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log inํcio.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

    cMetodo := 'LOGISTICA'
    
    EmailInformatica(cMetodo)

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule    

    ConOut("FINAL DO SCHEDULE ADLOG013R")

    // ***********INICIO Limpa o ambiente, liberando a licen็a e fechando as conex๕es********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licen็a e fechando as conex๕es********************** //	 	    

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	//ณDestrava a rotina para o usuแrio	    ?
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
	UnLockByName("ADLOG013R")

RETURN()

STATIC FUNCTION EmailInformatica(cMetodo)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#USUSUR"))
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
	   cSubject := "Workflow LOGISTICA"          
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
	cRet += "'><b>Workflow LOGISTICA............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'LOGISTICA' 
 	
	    cRet += " Ocorr๊ncias sem fechar, Favor verificar!!!"
	    cRet += "<br>"
	    cRet += "<br>" 
	   
	    cRet += "<table border='1'>" 
	    
	    cRet += "<tr>"
		cRet += "<td>FILIAL</td>"
		cRet += "<td>NUMERO&nbsp;NOTA</td>"
		cRet += "<td>COD&nbsp;CLIENTE</td>"
		cRet += "<td>NOME&nbsp;CLIENTE</td>"
		cRet += "<td>TP&nbsp;OCOR</td>"
		cRet += "<td>DATA</td>"
		cRet += "<td>PEDIDO</td>"
		cRet += "<td>PLACA</td>"
		cRet += "<td>ROTEIRO</td>"
		cRet += "<td>SEQ</td>"
		cRet += "</tr>"
		
		SqlLogistica()
		While TRB->(!EOF())  
		
			cRet += "<tr>"
			cRet += "<td>" + TRB->ZD_FILIAL + "</td>"
			cRet += "<td>" + TRB->ZD_NUMNF + "</td>"
			cRet += "<td>" + TRB->ZD_CODCLI + "</td>"
			cRet += "<td>" + StrTran(TRB->ZD_NOMECLI,' ','&nbsp;') + "</td>"
			cRet += "<td>" + TRB->ZD_DEVTOT + "</td>"
			cRet += "<td>" + DTOC(STOD(TRB->ZD_DTDEV)) + "</td>"
			cRet += "<td>" + TRB->ZD_PEDIDO + "</td>"
			cRet += "<td>" + TRB->ZD_PLACA + "</td>"
			cRet += "<td>" + TRB->ZD_ROTEIRO + "</td>"
			cRet += "<td>" + TRB->ZD_SEQUENC + "</td>"
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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG013R'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG013R'
			ZBN_DESCRI  := 'Workflow para logistica de ocorr๊ncias pendentes'
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
			ZBN_ROTINA	:= 'ADLOG013R'
			ZBN_DESCRI  := 'Workflow para logistica de ocorr๊ncias pendentes'
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
 
Static Function SqlLogistica()

	BeginSQL Alias "TRB"
			%NoPARSER%
			 SELECT ZD_FILIAL,
					ZD_NUMNF,
					ZD_CODCLI,
					ZD_NOMECLI,
					ZD_DEVTOT,
					ZD_DTDEV,
					ZD_PEDIDO,
					ZD_PLACA,
					ZD_ROTEIRO,
					ZD_SEQUENC
				FROM %Table:SZD%, %Table:SC5%
				WHERE ZD_DEVTOT          = 'O'
				  AND ZD_ROTEIRO        >= '201'
				  AND ZD_ROTEIRO        <= '999'
				  AND ZD_PLACA          <> ''
				  AND ZD_DTDEV          >= CONVERT(VARCHAR(4),(YEAR(GETDATE())-1)) + '01' + '01'
				  AND ZD_DTDEV          <= CONVERT(VARCHAR(8), (GETDATE() -1 ), 112)
				  AND SZD010.D_E_L_E_T_ <> '*'
				  AND C5_FILIAL          = ZD_FILIAL
				  AND C5_NUM             = ZD_PEDIDO
				  AND C5_NOTA           <> 'XXXXXXXXX' 
				  AND C5_NOTA           <> ''
				  AND ZD_NUMNF           = C5_NOTA
				  AND SC5010.D_E_L_E_T_ <> '*'
						
			ORDER BY ZD_FILIAL,ZD_DTDEV,ZD_ROTEIRO,ZD_SEQUENC
			  
	EndSQl             
RETURN(NIL)
