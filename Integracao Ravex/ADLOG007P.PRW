#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH"  

/*/{Protheus.doc} User Function ADLOG007P
	Programa consumir de webservice ravex para baixa de entrega de notas fiscais 
	@author William Costa
	@since 02/06/2015
	@version 01
	@history chamado 052861 William Costa 23/10/2019 - Retirado regra para não alterar a ocorrencia quando for diferente de O
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
/*/

User Function ADLOG007P()

	Local nCont2 := 0

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
    RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	
	
	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADLOG007P", .T., .F.)
		ConOut("[ADLOG007P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut("INICIO DO SCHEDULE ADLOG007P")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumir de webservice ravex para baixa de entrega de notas fiscais')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	FOR nCont2 := 1 TO 2

		CRIAWEBSERVICE(nCont2)

	NEXT nCont2                 

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	ConOut("FINAL DO SCHEDULE ADLOG007P")

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADLOG007P")

RETURN(NIL)	

STATIC FUNCTION CRIAWEBSERVICE(nCont2)

	oWs := WSSiviraFullWebService():New()

	oWs:cLogin := 'adoro_user_ws'
	oWs:cSenha := 'SdUdWSdA'
	 
   	If oWs:Autenticar()
	    // autenticação ok
	    oResp   := oWs:oWSAutenticarResult 
	    cMetodo := 'Autenticar' 
	    
	    IF oResp:NID == 2
	    
	    	ENTREGAVIAGEM(nCont2)
	    
	    ENDIF
	    
	Endif

RETURN(NIL)     	  

STATIC FUNCTION ENTREGAVIAGEM(nCont2)

	oWs:CCNPJEMISSOR       := '60037058000301'
	oWs:LVIAGEMFECHADAS    := IIF(nCont2 == 1,.F.,.T.) 
	oWs:LVIAGENSCANCELADAS := .T.
	oWs:NPERIODOHORAS      := 03

	If oWs:RetornarNFsEntregues()
	    // autenticação ok
	    oResp   := oWs:oWSRetornarNFsEntreguesResult  
	    
	    IMPORTAXML()
	    
	Endif

RETURN(NIL)     	
                      
STATIC FUNCTION IMPORTAXML()

	Private nCont      := 0
	Private cTeste     := ''
	Private cFil       := ''
	Private cRoteiro   := ''
	Private cMetodo    := ''
    Private nId        := 0
    Private	cNomMot    := ''
	Private cTelMot    := ''
	Private cEmlMot    := ''         
	Private cCPFM      := ''
	Private cCodCTRL   := ''
	Private cRespNome  := ''
	Private cDescMotiv := '' 
	Private cCliente   := ''
	Private cLojaCli   := ''
	Private cNota      := ''
	Private cSerie     := ''
	Private aEntrega   := {}
	Private aEntregas  := {}
	

	/////// ************INICIO CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
	IF LEN(oResp:oWSNOTAENTREGUE) > 0 
		IF oResp:oWSNOTAENTREGUE[1]:NIDVIAGEM <> -1 // VERIFICA SE EXISTE ERRO
		
			aEntregas  := {}
	
			For nCont:= 1 To Len(oResp:oWSNOTAENTREGUE)  
			
				// ******************** inicio pegar qual a filial correta da viagem *************************** //
				cRoteiro:= 	Substring(oResp:oWSNOTAENTREGUE[nCont]:CIDENTIFICADOR, ;
				                     (LEN(oResp:oWSNOTAENTREGUE[nCont]:CIDENTIFICADOR) -2),;
					                  LEN(oResp:oWSNOTAENTREGUE[nCont]:CIDENTIFICADOR))  
					                                                       
				IF cRoteiro >= '901'
				
					cFil     := '02'
				
				ELSE               
				
					cFil     := '02'
				
				ENDIF
						
				// ******************** final pegar qual a filial correta da viagem *************************** //
				
				// ** INICIO VERIFICA SE A VIAGEM JA FOI ALTERADA ** //
				// CONFORME NOVA REGRA DA LOGISTICA SE A VIAGEM JA FOI ALTERADA
				// O WEBSERVICE NAO PODE ALTERAR MAIS NADA
				// CHAMADO 032731 WILLIAM COSTA

				//Conforme chamado 052861 na data de 23/10/2019, foi conversado com o Marcel e retirado a trava que
				//não deixa sobrepor dados de ocorrencia depois que a letra é trocado de O no caso de Entregue estou 
			    //pulando tudo que já está entregue por que é muita nota.

				DBSELECTAREA("SZD")
				DbSetOrder(1) 
				IF DBSEEK(cFil+STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9) + ;
							          STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2),.T.) 
						  
						  IF SZD->ZD_DEVTOT == 'E'
						  
						  	LOOP // NAO DEIXA CONTINUAR O PROGRAMA POR QUE JÁ ENTREGOU
						  
						  ENDIF	
				ENDIF		  
				SZD->(dbCloseArea())		  
				
				// ** FINAL SE A VIAGEM JA FOI ALTERADA ** //
			
				DBSELECTAREA("SC5")
					DbOrderNickName("SC5_F") 
					//achou a nota no sc5          
					IF DBSEEK(cFil+STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9),.T.) 
						//inicio criar uma ocorrencia 
						// ******* ALTERA VALORES DA TABELAS PARA ENTREGUE
						IF	RecLock("SC5",.F.)
						
								SC5->C5_MOK := '02'
					
							MsUnlock()            
							
						ENDIF
						
						// *********** INICIO PARA CARREGAR O SZD *********************** // 
						
						DBSELECTAREA("ZV4")
						ZV4->(DBSETORDER(1))
						IF DBSEEK(xFilial("ZV4")+Alltrim(SC5->C5_PLACA))
							cCPFM := ZV4_CPF
							IF !EMPTY(cCPFM)
								DBSELECTAREA("ZVC")
								DBSETORDER(1)
								IF DBSEEK(cFil+cCPFM)
									cNomMot := ZVC->ZVC_MOTORI
									cTelMot := ZVC->ZVC_TELPRI
									cEmlMot := ZVC->ZVC_EMLMOT
								ENDIF  
							ENDIF  
						ENDIF     
						
						// NOME DO RESPONSAVEL E DESCRICAO DO MOTIVO
						//Buscar Nome do Responsavel
						DBSELECTAREA("SZU")
						DBSETORDER(1)
						IF DBSEEK(xfilial()+alltrim('09'))
							cRespNome := SZU->ZU_DESCRI
						ENDIF
						
						//Buscar Motivo
						DBSELECTAREA("SZS")
						DBSETORDER(1)
						IF DBSEEK(xfilial()+alltrim('35'))
							cDescMotiv := SZS->ZS_DESCRI
						ENDIF
						
						cCodCTRL := SUBSTR(cFil,2,1)        + ;
									SUBSTR(SC5->C5_NUM,6,1) + ;
									SUBSTR(SC5->C5_NUM,5,1) + ;
									SUBSTR(SC5->C5_NUM,4,1) + ;
									SUBSTR(SC5->C5_NUM,3,1) + ;
									SUBSTR(SC5->C5_NUM,2,1) + ;
									SUBSTR(SC5->C5_NUM,2,1) + ;
									STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9)
							
						DBSELECTAREA("SZD")
						DBSETORDER(1)
						DBGOTOP()
						IF !DBSEEK(cFil + ;
									STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9) + ;
									STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2))  
									
							RecLock("SZD",.T.)
								SZD->ZD_FILIAL	:= cFil
								SZD->ZD_NUMNF	:= STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9)
								SZD->ZD_SERIE	:= STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2)
								SZD->ZD_CODCLI	:= SC5->C5_CLIENTE
								SZD->ZD_LOJA   	:= SC5->C5_LOJACLI
								SZD->ZD_NOMECLI	:= SC5->C5_NOMECLI   
								SZD->ZD_DTDEV	:= DATE()    
								SZD->ZD_RESPONS	:= '09'
								SZD->ZD_MOTIVO	:= '35'
								SZD->ZD_AUTNOME	:= oResp:oWSNOTAENTREGUE[nCont]:COPERADOR
								SZD->ZD_RESPNOM	:= cRespNome
								SZD->ZD_DESCMOT	:= cDescMotiv
								SZD->ZD_PEDIDO	:= SC5->C5_NUM
								SZD->ZD_ROTEIRO	:= SC5->C5_ROTEIRO
								SZD->ZD_PLACA	:= SC5->C5_PLACA
								SZD->ZD_SEQUENC	:= SC5->C5_SEQUENC
								SZD->ZD_DEVTOT  := 'E'
								SZD->ZD_OBSER	:= ''
								SZD->ZD_VEND	:= SC5->C5_VEND1
								SZD->ZD_MOTORI  := cNomMot
								SZD->ZD_TELEFON := cTelMot
								SZD->ZD_EMLMOT  := cEmlMot
								SZD->ZD_RESP1   := ''
								SZD->ZD_PEDPERN := ''
								SZD->ZD_PERNOIT := .F.
								SZD->ZD_CODMOTP := ''
								SZD->ZD_MTVPERN := ''
								SZD->ZD_XPLACAS	:= SC5->C5_XPLACAS				
								SZD->ZD_CONTROL := cCodCTRL
								SZD->ZD_NRDEVOL := '00'
								
							MsUnLock()
						ENDIF
						SZD->(dbCloseArea())
						
						// *********** FINAL PARA CARREGAR O SZD  ***********************  //
						DBSELECTAREA("SZD")
						DbSetOrder(1) 
						IF DBSEEK(cFil+STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9) + ;
									STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2),.T.) 
									
							IF RecLock("SZD",.F.)      
									
									
									SZD->ZD_RESPONS	:= '09'
									SZD->ZD_MOTIVO	:= '35'
									SZD->ZD_AUTNOME	:= oResp:oWSNOTAENTREGUE[nCont]:COPERADOR
									SZD->ZD_RESPNOM	:= cRespNome
									SZD->ZD_DESCMOT	:= cDescMotiv
									SZD->ZD_DEVTOT  := 'E'
									SZD->ZD_CONTROL := cCodCTRL
									
								MsUnlock()
								
							ENDIF	
										
						ENDIF	
						SZD->(dbCloseArea())

						DBSELECTAREA("SZX")
						DBSETORDER(2)
						IF DBSEEK(FWFILIAL("SZX") + ;
								  STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9) + ;
								  STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2), .T.)

							WHILE SZX->(!EOF()) .AND. SZX->ZX_NF ==STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9) .AND. ALLTRIM(SZX->ZX_SERIE) == STRZERO(oResp:oWSNOTAENTREGUE[nCont]:NSERIE,2)
						
								CONOUT("ENTREI AQUI WILL")
								
								RECLOCK("SZX",.F.)

									DBDELETE()

								MSUNLOCK()
                                
								SZX->(DBSKIP())
							ENDDO	
						
						ENDIF	
						SZX->(dbCloseArea())			
						
						cMetodo := 'Entrega'
						nId     := 1
						aEntrega  := {}
						Aadd(aEntrega,STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9))
						Aadd(aEntregas,aEntrega)
							
						//EmailViagem(cMetodo,nId,STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9))
							
					ELSE
					
						cMetodo := 'Entrega'
				    	nId     := -1
		    			EmailViagem(cMetodo,nId,STRZERO(VAL(oResp:oWSNOTAENTREGUE[nCont]:CNOTAFISCAL),9))
					
						
					ENDIF 
				SC5->(dbCloseArea())
		
			Next  
		ELSE
		
			cMetodo := 'Entrega'
		    nId     := -1
		    EmailViagem(cMetodo,nId,'000000000 - 1-) Erro WEBSERVICE VAZIO - SEM VIAGENS')
		
			
		ENDIF
	ELSE 
	
		cMetodo := 'Entrega'
	    nId     := -1
	    EmailViagem(cMetodo,nId,'000000000 - 2-) Erro WEBSERVICE VAZIO - SEM VIAGENS')
	    
    ENDIF
    
    IF LEN(aEntregas) > 0
    
    	EmailViagem(cMetodo,nId,'NOTAENTREGUE')
    
    ENDIF 
    
	/////// ************FINAL CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //  
	
RETURN(NIL) 

STATIC FUNCTION EmailViagem(cMetodo,nId,cmensagem)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#USUENT"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
    Local _cStatEml    := ""
    
	//***************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
                            
    _cStatEml    := cMetodo 
    cBody        := RetHTML(_cStatEml,nId,cmensagem)
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
	   cSubject := "WEBSERVICE ENTREGA"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //****************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL)   


Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>WEBSERVICE ENTREGA............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
	IF _cStatEml == 'Entrega' .AND. nId == 1 // viagem ok
 	
	   cRet += " WEBSERVICE ENTREGA COM SUCESSO"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   FOR nContEmail:=1 TO LEN(aEntregas)
	   
	   		cRet += 'Nota Fiscal: ' + aEntregas[nContEmail][1] + ' entregue.' + "<br>"
	
	   NEXT
	   
	ENDIF	
	
	IF (_cStatEml == 'Entrega' .AND. nId == -1) .OR. ;
	   (_cStatEml == 'Entrega' .AND. nId == 0 )      // Viagem com erro
 	
	   cRet += " WEBSERVICE ENTREGA COM ERRO, favor verificar"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += 'Nota Fiscal: ' + cmensagem  + ' não encontrada no protheus'

	ENDIF  
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)     

Static Function logZBN(cStatus)

	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := '08:20:00'
	Local cHoraSegunda := '08:50:00'
	Local nTotVezes    := 23   
	Local cTempo       := '30'
	Local cHoraProx    := '' 
	Local dDtProx      := dDataBase
	                          
	IF cStatus == '1' //se status igual a 1 inicio
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG007P')) //procura o registro
	        // se achou faz o calculo
			nQuantAtual := ZBN->ZBN_QTDVEZ + 1
			
			IF nQuantAtual <> nTotVezes // verifica as quantidades de tempo
			    // se for diferente faz uma conta
				dDtProx     := dDataBase
				
				IF nQuantAtual == 1
				    //se for a primeira vez ve pela hora inicial
					cHoraProx   := cHoraSegunda
				
				ELSE
					//se for a segunda em diante vez ve pela hora proxima
					cHoraProx   := CVALTOCHAR(SomaHoras( ZBN->ZBN_HORAPR , '00:' + cTempo))
					cHoraProx   := IIF(LEN(SUBSTR(cHoraProx, At(".", cHoraProx) + 1, LEN(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
					cHoraProx   := STRTRAN(cHoraProx,'.',':') + ':00'
					
				ENDIF
				IF At(":", cHoraProx) == 2 //significa que a hora e menor que meio dia vamos acrescentar um zero a esquerda
				
					cHoraProx   := '0' + cHoraProx
									
				ENDIF
			
			ELSE                               
			    // se for igual grava o proximo dia
			    nQuantAtual := 1				
				dDtProx     := dDataBase + 1
				cHoraProx   := cHoraIni
			
			ENDIF
			
	    ELSE 
	                 
	        // se nao achou e pq e a primeira vez do dia que esta rodando
	    	nQuantAtual := 1         
	    	dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
	    
	    ENDIF                       
	    ZBN->(dbCloseArea())
	    
	ELSE // se o status for igual a 2          
	    
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG007P'))
		    // se achou grava o que ja esta calculado
			nQuantAtual := ZBN->ZBN_QTDVEZ
			dDtProx     := ZBN->ZBN_DATAPR
			cHoraProx   := ZBN->ZBN_HORAPR
			
		ELSE
		    // se nao achou grava a segunda vez
			nQuantAtual := 1
			dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
			
		ENDIF                       
	    ZBN->(dbCloseArea())	
	
	ENDIF
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG007P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG007P'
			ZBN_DESCRI  := 'Integração do Protheus X Ravex - Importaçao Viagens Entregues'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 23 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:20:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG007P'
			ZBN_DESCRI  := 'Integração do Protheus X Ravex - Importaçao Viagens Entregues'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 23 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:20:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)
