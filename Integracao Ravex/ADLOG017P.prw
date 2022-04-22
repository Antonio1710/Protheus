#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 

/*{Protheus.doc} User Function ADLOG017P
	Programa consumidor do Webservice da Ravex para viagens planejadas
	@type  Function
	@author WILLIAM COSTA
	@since 08/06/2016
	@version 01
	@history Chamado 046860 - WILLIAM COSTA - 13/02/2019 - ALTERA PARA NAO TER MAIS ENTREGA  
	@history Chamado 046860 - WILLIAM COSTA - 19/05/2020 - Adicionado valor de Roteiro Final
	@history Chamado 059327 - WILLIAM COSTA - 01/07/2020 - Alterado o roteiro inicial de 201 para 300 para enviar ao ravex

*/	

User Function ADLOG017P()

	Private oWs          := NIL
	Private oResp        := ''  
    Private cFil         := ''
    Private cFilini      := ''
    Private cFilfin      := ''
    Private aPedido      := {}
	Private	aPedidoRavex := {}  
	Private aEntrega     := {}
	Private aEntregas    := {}
	Private aClientes    := {}
	Private lJob         := .F.

	//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
	IF SELECT("SX6") == 0

		lJob := .T.

	ENDIF

	IF lJob == .T.
    
		RpcClearEnv()
		
		// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //
		RPCSetType(3)  //Nao consome licensas
		RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
		// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		If !LockByName("ADLOG017P", .T., .F.)
			ConOut("[ADLOG017P] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		EndIf

	ENDIF

	ConOut("INICIO DO SCHEDULE ADLOG017P" + ALLTRIM(FUNNAME()) + ' ' + TIME())

	PtInternal(1,ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumidor do Webservice da Ravex para viagens planejadas ')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule  

	CRIAWEBSERVICE()  

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule  

	ConOut("FINAL DO SCHEDULE ADLOG017P" + ALLTRIM(FUNNAME()) + ' ' + TIME())

	IF lJob == .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Destrava a rotina para o usuário	    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		UnLockByName("ADLOG017P")

		// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
		RpcClearEnv() 
		// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

	ENDIF

Return(NIL)

STATIC FUNCTION CRIAWEBSERVICE()

	DelClassIntF() // COMANDO PARA LIMPAR A MEMORIA WILLIAM COSTA CHAMADO 041161 || ADM.LOG || DIEGO || INTEGRACAO RAVEX 02/05/2018
	
	oWs := WSsivirafullWebService():New()

	oWs:cLogin := 'adoro_user_ws'
	oWs:cSenha := 'SdUdWSdA'
	 
	ExportaXML()  
	
RETURN(NIL)

Static Function ExportaXML()
                                                                                                          
    Local   nLTRC           := 0
	Private cRotCabOld      := ''  	
	Private cRotRodOld      := ''
	Private cDtEntr         := '' 
	
    cFilini   := '02'
    cFilfin   := '02'
    aEntregas := {}
    
	SqIntPedido()
	cRotCabOld := ''
	cRotRodOld := TRB->C5_ROTEIRO
	
	While TRB->(!EOF())  
	
		cRotCab := TRB->C5_ROTEIRO //Valor do Cabeçalho para  criar o xml
	    cRotRod := TRB->C5_ROTEIRO //Valor do Rodapé para jogar os valores do xml no arquivo
	    //Primeira vez que entra no Roteiro 
	    
		// ************************************ Inicio Carrega XML do no de viagem *******************************
		oWs:OWSVIAGEMPLANEJADA:CCNPJUNIDADE      := '60037058000301'
		oWs:OWSVIAGEMPLANEJADA:CCODIGOROTA       := ALLTRIM(TRB->C5_ROTEIRO)
      	oWs:OWSVIAGEMPLANEJADA:CDATACONFIRMACAO  := Substr( TRB->C5_DTENTR,1,4)+ '-' + Substr( TRB->C5_DTENTR,5,2)+ '-' + Substr( TRB->C5_DTENTR,7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)
      	oWs:OWSVIAGEMPLANEJADA:CDATACRIACAO      := Substr( DTOS(Ddatabase),1,4)+ '-' + Substr( DTOS(Ddatabase),5,2)+ '-' + Substr( DTOS(Ddatabase),7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)//DTOC(Ddatabase)
      	oWs:OWSVIAGEMPLANEJADA:CDATAESTIMADA     := Substr( TRB->C5_DTENTR,1,4)+ '-' + Substr( TRB->C5_DTENTR,5,2)+ '-' + Substr( TRB->C5_DTENTR,7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)
      	oWs:OWSVIAGEMPLANEJADA:CDOCA             := ''
      	oWs:OWSVIAGEMPLANEJADA:CIDENTIFICADOR    := ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
      	oWs:OWSVIAGEMPLANEJADA:COBSERVACOES      := ''
      	oWs:OWSVIAGEMPLANEJADA:CORDEMEMBARQUE    := TRB->C5_X_SQED
      	oWs:OWSVIAGEMPLANEJADA:CPLACA            := TRB->C5_PLACA
      	oWs:OWSVIAGEMPLANEJADA:NCUBAGEMTOTAL     := 0
      	oWs:OWSVIAGEMPLANEJADA:NID               := 0 //ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
      	oWs:OWSVIAGEMPLANEJADA:NIDCOOPERATIVA    := 0
      	oWs:OWSVIAGEMPLANEJADA:NIDEMBARCADOR     := 0
      	oWs:OWSVIAGEMPLANEJADA:NIDTRANSPORTADORA := VAL(ALLTRIM(TRB->C5_TRANSP))
        oWs:OWSVIAGEMPLANEJADA:NIDUNIDADE        := 0
        oWs:OWSVIAGEMPLANEJADA:NIDVEICULO        := 0
        oWs:OWSVIAGEMPLANEJADA:NKMESTIMADO       := TRB->ZK_KMPAG
      	oWs:OWSVIAGEMPLANEJADA:NPESOLIQUIDOTOTAL := TRB->ZK_PESOL
      	oWs:OWSVIAGEMPLANEJADA:NPESOTOTAL        := TRB->ZK_PBRUTO
        oWs:OWSVIAGEMPLANEJADA:NQTDCAIXAS        := 0
        oWs:OWSVIAGEMPLANEJADA:NQTDENTREGAS      := TRB->QTDENTREGAS 
        oWs:OWSVIAGEMPLANEJADA:NSTATUS           := 0
        oWs:OWSVIAGEMPLANEJADA:NVALORTOTAL       := TRB->C5_XTOTPED
            
      	// ************************************ final Carrega XML do no de viagem *******************************
	    	
      	// ************************************ Inicio Carrega XML do no de entrega *******************************   
      	
      	cFil    := TRB->C5_FILIAL  
      	cDtEntr := TRB->C5_DTENTR
      	
      	SqlEntregas()            
      	cFil    := ''
      	cDtEntr := ''
      	
      	/////// ************INICIO CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
      	oWs:OWSVIAGEMPLANEJADA:OWSENTREGAS := sivirafullWebService_ArrayOfEntregaPlanejada():New() 
		/////// ************FINAL CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
      	
      	While TRC->(!EOF())
      	
      		Aadd(aClientes,u_ADLOG043P(TRC->C5_CLIENTE,TRC->C5_LOJACLI)) //Enviar o Cliente para o Ravex
      		    
      		nLTRC := nLTRC + 1 //soma linha do ní
      		
      		OWSENTREGAPLANEJADA                    := sivirafullWebService_EntregaPlanejada():NEW()
		    OWSENTREGAPLANEJADA:CCODIGOCLIENTE     := ALLTRIM(TRC->C5_CLIENTE+TRC->C5_LOJACLI)  
		    OWSENTREGAPLANEJADA:CDATACRIACAO       := Substr( DTOS(Ddatabase),1,4)+ '-' + Substr( DTOS(Ddatabase),5,2)+ '-' + Substr( DTOS(Ddatabase),7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)//DTOC(Ddatabase)
		    OWSENTREGAPLANEJADA:CESTIMATIVAFIM     := Substr( DTOS(Ddatabase),1,4)+ '-' + Substr( DTOS(Ddatabase),5,2)+ '-' + Substr( DTOS(Ddatabase),7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)//DTOC(Ddatabase)
		    OWSENTREGAPLANEJADA:CESTIMATIVAINICIO  := Substr( DTOS(Ddatabase),1,4)+ '-' + Substr( DTOS(Ddatabase),5,2)+ '-' + Substr( DTOS(Ddatabase),7,2) +  "T" + '00:00:00' //ALLTRIM(TRB->C5_DTENTR)//DTOC(Ddatabase)
		    OWSENTREGAPLANEJADA:COBSERVACOES       := ''
		    OWSENTREGAPLANEJADA:NCUBAGEMTOTAL      := 0
		    OWSENTREGAPLANEJADA:NID                := 0 //ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
    		OWSENTREGAPLANEJADA:NIDREFERENCIA      := VAL(TRC->C5_SEQUENC)
    		//OWSENTREGAPLANEJADA:NIDVIAGEMPLANEJADA := 0
    		OWSENTREGAPLANEJADA:NPESOLIQUIDOTOTAL  := TRC->C5_PESOL
    		OWSENTREGAPLANEJADA:NPESOTOTAL         := TRC->C5_PBRUTO
	      	OWSENTREGAPLANEJADA:NQTDCAIXAS         := 0
	      	OWSENTREGAPLANEJADA:NSEQUENCIA         := VAL(TRC->C5_SEQUENC)
	      	OWSENTREGAPLANEJADA:NSTATUS            := 0
	      	OWSENTREGAPLANEJADA:NVALORTOTAL        := TRC->C5_XTOTPED  
	      	
	      	aPedido:= {}
	      	AADD(aPedido,TRC->C5_FILIAL)
	      	AADD(aPedido,TRC->C5_NUM)
	      	AADD(aPedidoRavex,aPedido)
	   				  
	      	AAdd(oWs:OWSVIAGEMPLANEJADA:OWSENTREGAS:OWSENTREGAPLANEJADA, OWSENTREGAPLANEJADA)
	      	// ************************************ Final Carrega XML do no de entrega *******************************
	      	// ************************************ Inicio Carrega XML do no de notas fiscais *******************************      
	      	
	      	TRC->(dbSkip())
		
		ENDDO //FECHA WHILE DO TRC
		nLTRC := 0 // Zera o contador de linha do SQL TRC  
    	TRC->(dbCloseArea()) 
    	
    	// *** INICIO WILLIAM COSTA 13/02/2019 CHAMADO 046860 || OS 048115 || ADM.LOG || MARCEL || 8492 || ROTEIRO X RAVEX *** //
    	IF LEN(aPedidoRavex) > 0
    	
	    	IF oWs:ImportarViagemPlanejada()
	
			   oResp   := oWs:oWSImportarViagemPlanejadaResult
			   cMetodo := 'Viagem'
			   nId     := oResp:NID  
			   
			   IF nId > 0
			   		nId :=1 
			   		AddCampoRavex()
			   ENDIF
			   aEntrega  := {}
			   Aadd(aEntrega,oResp:cmensagem)
			   Aadd(aEntregas,aEntrega)
			   	   
			ELSE
			 
				cMetodo := 'Viagem'
			    nId     := -1
			    EmailViagem(cMetodo,nId,GetWSCError())
			 
			ENDIF
		ENDIF
		
		// *** FINAL WILLIAM COSTA 13/02/2019 CHAMADO 046860 || OS 048115 || ADM.LOG || MARCEL || 8492 || ROTEIRO X RAVEX *** //
		
		//zera vetores de nota
		aPedido      := {}
		aPedidoRavex := {}  
		
		TRB->(dbSkip())
			
	ENDDO //FECHA WHILE DO TRB
	    	    
	TRB->(dbCloseArea())  
	
	IF LEN(aEntregas) > 0
    
    	EmailViagem(cMetodo,nId,'NOTAENTREGUE')
    
    ENDIF 
	
RETURN(NIL)

STATIC FUNCTION EmailViagem(cMetodo,nId,cmensagem)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_EMAILRA"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
    Local _cStatEml    := ""
    
	//********************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
                            
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
	   cSubject := "WEBSERVICE VIAGEM LOGISTICA - PLANEJADA"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL)   

Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>WEBSERVICE VIAGEM............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF _cStatEml == 'Autenticar' .AND. nId == 2 // Autenticacao ok
 	
	   cRet += " WEBSERVICE Autenticado com Sucesso"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	
		
	ENDIF	
	
	IF _cStatEml == 'Autenticar' .AND. nId == -1      // Autenticacao com erro
 	
	   cRet += " WEBSERVICE COM ERRO AUTENTICAR"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF    
	
	IF _cStatEml == 'Viagem' .AND. nId == 1 // viagem ok
 	
	   cRet += " WEBSERVICE Viagem com Sucesso"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	    IF LEN(aEntregas) > 0
	   
		   FOR nContEmail:=1 TO LEN(aEntregas)
		   
		   		cRet += aEntregas[nContEmail][1] + "<br>"
		
		   NEXT
		   
		ELSE 
	   	
	   		cRet += cmensagem
	   	   
	   ENDIF
	   
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   IF LEN(aClientes) > 0
	   
	   		FOR nContEmail:=1 TO LEN(aClientes)
	   
	   			cRet += aClientes[nContEmail][1] + "<br>"
		
		   	NEXT
	   
	   ENDIF
	   	
	ENDIF	
	
	IF (_cStatEml == 'Viagem' .AND. nId == -1) .OR. ;
	   (_cStatEml == 'Viagem' .AND. nId == 0 )      // Viagem com erro
 	
	   cRet += " WEBSERVICE Viagem COM ERRO ou já existe"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   IF LEN(aEntregas) > 0
	   
		   FOR nContEmail:=1 TO LEN(aEntregas)
		   
		   		cRet += aEntregas[nContEmail][1] + "<br>"
		
		   NEXT
		   
		ELSE 
	   	
	   		cRet += cmensagem
	   	   
	   ENDIF
	   
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   IF LEN(aClientes) > 0
	   
	   		FOR nContEmail:=1 TO LEN(aClientes)
	   
	   			cRet += aClientes[nContEmail][1] + "<br>"
		
		   	NEXT
	   
	   ENDIF

	ENDIF  
	
	IF _cStatEml == 'Roteiro' .AND. nId == 2 // Roteiro com erro
 	
	   cRet += " WEBSERVICE ROTEIRO COM ERRO NÃO ENVIADO PARA O SEFAZ"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF
	
	IF _cStatEml == 'ERRO_SQL' .AND. nId == 2 // Roteiro com erro
 	
	   cRet += " WEBSERVICE SQL COM ERRO"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)    	

Static Function AddCampoRavex()

	Local nCont 

	FOR nCont := 1 TO LEN(aPedidoRavex)

		DbSelectArea("SC5")
							
			SC5->(dbsetorder(1))
			IF SC5->(dbseek(aPedidoRavex[nCont][1] + aPedidoRavex[nCont][2], .T.)) //filial+nota+serie
			
				RecLock("SC5",.F.)
		
					SC5->C5_XRAVEX := .T. // Atualiza o campo de integracao com o ravex
					                         //afirmando que a nota foi integrada com o ravex
				SC5->( MsUnLock() ) 
			ENDIF                    
		
		SC5->(dbCloseArea())         
		
	NEXT	
					
Return()  

Static Function logZBN(cStatus)

	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','20:15:00',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','11:10:00',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','00:30:00','')))
	Local cHoraSegunda := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','20:45:00',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','11:40:00',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','01:00:00','')))
	Local nTotVezes    := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00',8,IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00',7,IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00',15,0)))
	Local cTempo       := '30'
	Local cHoraProx    := '' 
	Local dDtProx      := dDataBase
	
	// QUANDO NAO CARREGAR AS VARIAVEIS DE CALCULO SAI FORA, PARA NAO DAR ERRO
	IF ALLTRIM(cHoraIni)     == '' .OR. ;
	   ALLTRIM(cHoraSegunda) == '' .OR. ;
	   nTotVezes             == 0
	   
        	RestArea(aArea)
	   		Return(Nil)
	  
	ENDIF   
	                          
	IF cStatus == '1' //se status igual a 1 inicio                                                           
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG017P')) //procura o registro
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
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG017P'))
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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG017P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG017P'
			ZBN_DESCRI  := 'Integração PROTHEUS X RAVEX PLANEJADA'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','30 MIN - 08 VEZES',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','30 MIN - 07 VEZES',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','30 MIN - 15 VEZES',''))) 
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','20:15:00',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','11:10:00',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','00:30:00','')))
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG017P'
			ZBN_DESCRI  := 'Integração PROTHEUS X RAVEX PLANEJADA'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','30 MIN - 08 VEZES',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','30 MIN - 07 VEZES',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','30 MIN - 15 VEZES',''))) 
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := IIF(TIME() >= '20:15:00' .AND. TIME() <= '23:59:00','20:15:00',IIF(TIME() >= '11:10:00' .AND. TIME() <= '15:00:00','11:10:00',IIF(TIME() >= '00:30:00' .AND. TIME() <= '08:40:00','00:30:00','')))
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus

	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

STATIC FUNCTION SqIntPedido()

	Local cRotFin := GetMv("MV_#ROTPUL",.F.,"599")
     
	BeginSQL Alias "TRB"
			%NoPARSER% 
				 SELECT SC5.C5_FILIAL, 
						SC5.C5_ROTEIRO, 
						SC5.C5_PLACA, 
						SUM(SZK.ZK_VALFRET) AS ZK_VALFRET,
						SC5.C5_DTENTR,
						SUM(SZK.ZK_PBRUTO) AS ZK_PBRUTO,
					    SC5.C5_X_SQED,
						SC5.C5_XRAVEX,
						SC5.C5_TRANSP,
						SUM(SZK.ZK_KMPAG) AS ZK_KMPAG,
					    SUM(SZK.ZK_PESOL) AS ZK_PESOL,
						SUM(SC5.C5_XTOTPED) AS C5_XTOTPED,
						COUNT(SC5.C5_ROTEIRO) AS QTDENTREGAS
					FROM %Table:SC5% SC5, %Table:SZK% SZK
					WHERE SC5.C5_FILIAL >= '02'
					AND SC5.C5_FILIAL   <= '07'
					AND SC5.C5_DTENTR   >= CONVERT(VARCHAR(8), GETDATE(), 112)
					AND SC5.C5_PLACA    <> ''
					AND SC5.C5_ROTEIRO  >= '300'
					AND SC5.C5_ROTEIRO  <= %EXP:cRotFin%
					AND SC5.C5_XINT      = '3'
					AND SC5.C5_X_SQED   <> ''
					AND SC5.C5_XRAVEX    = 'F'
					AND SZK.ZK_PLACA     = SC5.C5_PLACA
					AND SZK.ZK_DTENTR    = SC5.C5_DTENTR
					AND SZK.ZK_ROTEIRO   = SC5.C5_ROTEIRO
					AND SZK.D_E_L_E_T_  <> '*'
					AND SC5.D_E_L_E_T_  <> '*'
								    
				GROUP BY SC5.C5_FILIAL, 
						SC5.C5_ROTEIRO, 
						SC5.C5_PLACA, 
						SC5.C5_DTENTR,
						SC5.C5_X_SQED,
						SC5.C5_XRAVEX,
						SC5.C5_TRANSP
						
										 
				ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO 
	EndSQl          

RETURN(NIL)    

STATIC FUNCTION SqlEntregas()
     
    BeginSQL Alias "TRC"
			%NoPARSER% 
			   SELECT SC5.C5_FILIAL,
			          SC5.C5_CLIENTE,
			          SC5.C5_LOJACLI,
				      SC5.C5_SEQUENC,
					  SC5.C5_PBRUTO,
					  SC5.C5_PESOL,
					  SC5.C5_XTOTPED,
	   				  SC5.C5_NUM   
     			 FROM %Table:SC5% SC5
				WHERE SC5.C5_FILIAL   = %EXP:cFil%
				  AND SC5.C5_DTENTR   = %EXP:cDtEntr%
				  AND SC5.C5_ROTEIRO  = %EXP:cRotCab%
				  AND SC5.C5_XINT     = '3'
				  AND SC5.C5_X_SQED  <> ''
				  AND SC5.C5_XRAVEX   = 'F'
				  AND SC5.D_E_L_E_T_ <> '*'
				
				  ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO,SC5.C5_SEQUENC
			
	EndSQl          

RETURN(NIL)    	  