#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 

/*{Protheus.doc} User Function ADLOG003P
	Programa consumir de webservice ravex para Viagens faturadas de notas fiscais
	@type  Function
	@author WILLIAM COSTA
	@since 23/03/2015
	@version 01
	@history Chamado 051399 - WILLIAM COSTA - 30/08/2019 - Alterado a quantidade e peso unitario no item para adeguar com novas informacoes para a diretoria visualizar numero de devolucao
	@history Chamado 058549 - WILLIAM COSTA - 29/05/2020 - Alterado as tabelas de Frete de SZK para ZFA, conforme nova tabela de fretes da logistica, também coloca um sleep de 30 segundos para cada envio de viagem ao Ravex
	@history Chamado 058631 - WILLIAM COSTA - 01/06/2020 - Retirado o campo C5_XNIDROT  do select TRB e feito um select para ele isolado, estava duplicando as viagens, devido esse campo ser zero quando é feito uma roteiro manual.
	@history Chamado 059327 - WILLIAM COSTA - 01/07/2020 - Alterado o roteiro inicial de 201 para 300 para enviar ao ravex
	@history Chamado 1237   - WILLIAM COSTA - 09/09/2020 - Adicionado order by no select do SQLINTNOTA, pois estava gerando varias erros por falta de ordenação.
	@history Chamado 13494  - LEONARDO P. MONTEIRO - 04/05/2021 - Tratativa no fonte para gerar o fechamento do frete quando não foi gerado no momento do faturamento da NFe.
	@history Chamado 13494  - LEONARDO P. MONTEIRO - 05/05/2021 - Correção do error.log na emissão do log (ZBE).
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
*/
 
User Function ADLOG003P(aXEmpFil)

	PRIVATE cRot           := ''    
	PRIVATE cPlaca         := ''
	PRIVATE cDtEntrega     := ''
	PRIVATE oWs            := NIL
	PRIVATE oWsEntrega     := NIL
	PRIVATE oResp          := ''  
    Private oWsNotaFiscal  := NIL
	Private oWsItem        := NIL 
	Private oWSTabelaFrete := NIL
	Private cMetodo        := ''
	Private nId            := ''
	Private cRotIni        := ''
	Private cRotFin        := ''
	Private nContNota      := 0
	Private nContChvNfe    := 0
	Private nCont          := 0       
	Private nContVetor     := 0
	Private cMens          := ''
    Private cFilini        := ''
    Private cFilfin        := ''
    Private dDtEntrini     := ''
    Private dDtEntrfin     := ''
    Private cPlacaIni      := ''
    Private cPlacaFin      := ''
    Private cRoteiroIni    := ''
    Private cRoteiroFin    := ''
    Private aNota          := {} 
    Private aNotaRavex     := {}
    Private lRet           := .T.     
    Private cFil           := ''            
    Private cSeq           := ''
    Private aEnt           := {}
	Private aEnts          := {}
	Private lJob           := .F.
	Default aXEmpFil :={ "01", "02" } //Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
	IF SELECT("SX6") == 0

		lJob := .T.

	ENDIF
	
	IF lJob == .T.

		// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
		RPCClearEnv()
		RPCSetType(3)  //Nao consome licensas
		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
		RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
		// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //	

		// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
		If !LockByName("ADLOG003P", .T., .F.)
			ConOut("[ADLOG003P] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		EndIf

	ENDIF

	ConOut("INICIO DO SCHEDULE ADLOG003P " + ALLTRIM(FUNNAME()) + ' ' + TIME())

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	  
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumir de webservice ravex para Viagens faturadas de notas fiscais')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	cFilini       := '02'
    cFilfin       := '02'

    ConOut("ADLOG003P - Carregamento das variaveis Filial Inicio: " + cFilini + "Filial Fim: "+ cFilfin)  

	SqlIntNota() //Integração das notas  
	
	ConOut("ADLOG003P - Carregamento do Roteiro Tabela TRA: " + TRA->C5_ROTEIRO)
	
	cRotIni    := TRA->C5_ROTEIRO
	cRotFin    := TRA->C5_ROTEIRO
	dDtEntrini := TRA->C5_DTENTR
    dDtEntrfin := TRA->C5_DTENTR
    cPlacaIni  := TRA->C5_PLACA
    cPlacaFin  := TRA->C5_PLACA
    cFilini    := TRA->C5_FILIAL
    cFilfin    := TRA->C5_FILIAL
    	
	While TRA->(!EOF())   

		If TRA->ZFA_CONT == 0
			//@history Chamado 13494  - LEONARDO P. MONTEIRO - 04/05/2021 - Tratativa no fonte para gerar o fechamento do frete quando não foi gerado no momento do faturamento da NFe.
			if fPosiciona(TRA->C5_FILIAL, TRA->C5_ROTEIRO, TRA->C5_DTENTR,TRA->C5_PLACA)
				U_ADLOG042P(cEmpAnt , cFilAnt , SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_CLIENTE , SF2->F2_LOJA , SC5->C5_NUM , '1' , SC5->C5_DTENTR )
			ELSE
				msgalert("Não foi possível gerar o fechamento de frete para essa carga!")
				TRA->(dbSkip())
				Loop
			endif
		ENDIF
		    
	    cRotFin    := TRA->C5_ROTEIRO
	    dDtEntrfin := TRA->C5_DTENTR
	    cPlacaFin  := TRA->C5_PLACA
	    cFilfin    := TRA->C5_FILIAL
	    nCont      := nCont + 1   
	                                        
		IF cRotIni == cRotFin    
		
			nContNota   := nContNota   + TRA->F2_CONTDOC
	        nContChvNfe := nContChvNfe + TRA->F2_CONTCHVNFE
	        cRot        := TRA->C5_ROTEIRO    
	        cPlaca      := TRA->C5_PLACA
	        cDtEntrega  := TRA->C5_DTENTR
	        cFil        := TRA->C5_FILIAL
	        
	        TRA->(dbSkip())
	    ELSE
	    
	    	IF nContNota == nContChvNfe       
	    	    cRot        := cRotIni
	    	    cPlaca      := cPlacaIni
	            cDtEntrega  := dDtEntrini
	            cFil        := cFilini
	    		CRIAWEBSERVICE()  
	    		
	    		IF lRet == .F.
	    		
	    			RETURN() //erro de autenticacao para o programa de schedule
	    		
	    		ENDIF
	    		
	    		nContNota   := TRA->F2_CONTDOC
	    		nContChvNfe := TRA->F2_CONTCHVNFE
	    		cRotIni     := TRA->C5_ROTEIRO
	    		cRotFin     := TRA->C5_ROTEIRO
	    		dDtEntrini  := TRA->C5_DTENTR
			    dDtEntrfin  := TRA->C5_DTENTR
			    cPlacaIni   := TRA->C5_PLACA
			    cPlacaFin   := TRA->C5_PLACA
			    cFilini     := TRA->C5_FILIAL
                cFilfin     := TRA->C5_FILIAL
	    		TRA->(dbSkip())
	    	ELSE
	    	    nContNota   := TRA->F2_CONTDOC
	    		nContChvNfe := TRA->F2_CONTCHVNFE
	    		cRotIni     := TRA->C5_ROTEIRO
	    		cRotFin     := TRA->C5_ROTEIRO
	    		dDtEntrini  := TRA->C5_DTENTR
			    dDtEntrfin  := TRA->C5_DTENTR
			    cPlacaIni   := TRA->C5_PLACA
			    cPlacaFin   := TRA->C5_PLACA 
			    cFilini     := TRA->C5_FILIAL
                cFilfin     := TRA->C5_FILIAL
	    		cMetodo     := 'Roteiro'
	    		nId         := 2
	    		cMens       := 'ROTEIRO:        ' + cRot       + "<br>" + ;
	    	                   'PLACA:          ' + cPlaca     + "<br>" + ;
	    	                   'DATA DE ENTREGA:' + cDtEntrega + "<br>" + ;
	    	                   'NAO ENVIADO PARA O SEFAZ' 

	    		EmailViagem(cMetodo,nId,cMens) 	   

	    	    TRA->(dbSkip())
	    	
		    ENDIF

		ENDIF

	ENDDO //FECHA WHILE DO TRA
    	
	TRA->(dbCloseArea())
		
	///////////// INICIO  ULTIMA LINHA //////////////
	
	IF nContNota == nContChvNfe .AND. nContNota > 0 //so envia email se tiver nota
	    cRot        := cRotIni 
	    cPlaca      := cPlacaIni
        cDtEntrega  := dDtEntrini     
        cFil        := cFilini		
    	CRIAWEBSERVICE()
    	
    	IF lRet == .F.
	    		
    		RETURN() //erro de autenticacao para o programa de schedule
    		
    	ENDIF
	    		
    	nContNota   := 0
    	nCont       := 0
    	nContChvNfe := 0
    	cRotIni     := ''
    	cRotFin     := '' 
    	dDtEntrini  := ''
		dDtEntrfin  := ''
		cPlacaIni   := ''
		cPlacaFin   := ''
    	cRot        := ''       
    	cPlaca      := ''
    	cDtEntrega  := ''     
    	cFil        := ''
    	cFilini     := ''
        cFilfin     := ''
    ELSE
	  	cMetodo     := 'ROTEIRO'
	    nId         := 2
	    cMens       := 'ROTEIRO:        ' + cRot       + "<br>" + ;
	    	           'PLACA:          ' + cPlaca     + "<br>" + ;
	    	           'DATA DE ENTREGA:' + cDtEntrega + "<br>" + ;
	    	           'NAO ENVIADO PARA O SEFAZ'    
	    	           
	    IF nContNota > 0 //so envia email se tiver nota	           
	    	            
		    EmailViagem(cMetodo,nId,cMens) 	   
	    
	    ENDIF	       
	    
	    nContNota   := 0
    	nContChvNfe := 0
    	nCont       := 0
    	cRotIni     := ''
    	cRotFin     := ''
    	cRot        := ''       
    	cPlaca      := ''
    	cDtEntrega  := ''
    	dDtEntrini  := ''
	    dDtEntrfin  := ''
	    cPlacaIni   := ''
	    cPlacaFin   := ''
	    cFil        := ''
    	cFilini     := ''
        cFilfin     := ''
	    
    ENDIF
    
    IF LEN(aEnts) > 0
    
    	EmailViagem(cMetodo,nId,'Faturada')
    
    ENDIF 
		    
	///////////// FINAL ULTIMA LINHA //////////////	  

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	ConOut("FINAL DO SCHEDULE ADLOG003P " + ALLTRIM(FUNNAME()) + ' ' + TIME())
	
	IF lJob == .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Destrava a rotina para o usuário	    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		UnLockByName("ADLOG003P")

		// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
		RpcClearEnv() 
		// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

	ENDIF

Return(NIL)

Static function fPosiciona( cFil, cRoteir, cDtEntr, cPlaca)
	Local lRet 		:= .F.
	Local cQuery	:= ""

	DbSelectArea("SC5")
	DbSelectArea("SF2")
		BeginSQL Alias "QSC5"
			%NoPARSER%
				SELECT TOP 1 SF2.R_E_C_N_O_ SF2REG, SC5.R_E_C_N_O_ SC5REG
				FROM %Table:SC5% SC5 WITH(NOLOCK) INNER JOIN %Table:SF2% SF2 WITH(NOLOCK) ON 
							    SC5.%notDel%
							AND SF2.%notDel%
							AND SC5.C5_FILIAL  	= SF2.F2_FILIAL 
							AND SC5.C5_NOTA 	= SF2.F2_DOC 
							AND SC5.C5_SERIE 	= SF2.F2_SERIE 
							AND SC5.C5_CLIENTE  = SF2.F2_CLIENTE 
							AND SC5.C5_LOJACLI  = SF2.F2_LOJA
				WHERE SC5.C5_FILIAL   	= %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntr%
				    AND SC5.C5_ROTEIRO  = %exp:cRoteir%
					AND SC5.C5_PLACA    = %exp:cPlaca%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''	    
				    
	EndSQl 
	
	If QSC5->(!EOF())
		SF2->(DBGOTO(QSC5->SF2REG))
		SC5->(DBGOTO(QSC5->SC5REG))
		lRet := .T.

	EndIf

	QSC5->(DbCloseArea())

return lRet

STATIC FUNCTION CRIAWEBSERVICE()

	DelClassIntF() // COMANDO PARA LIMPAR A MEMORIA WILLIAM COSTA CHAMADO 041161 || ADM.LOG || DIEGO || INTEGRACAO RAVEX 02/05/2018
	
	oWs := WSsivirafullWebService():New()

	oWs:cLogin := 'adoro_user_ws'
	oWs:cSenha := 'SdUdWSdA'
	 
	ExportaXML()  
	
RETURN(NIL)

Static Function ExportaXML()
                                                                                                          
    Local   nLTRC            := 0
	Local   nLTRD            := 0
	Local   nLTRE            := 0
	Local   nTotL            := 0
	Private cRotCab          := ''  
	Private cRotCabOld       := ''  	
	Private cRotRod          := ''  
	Private cRotRodOld       := ''
	Private cTipoFrete       := '' 
	Private cHoraSai         := ''
	Private cHoraRet         := '' 
	Private cDtEntr          := '' 
	Private cCliente         := ''
    Private cLojaCli         := ''
    Private cNota            := ''
    Private cSerie           := ''               
    Private cPriori          := ''  
    Private nEntrega         := 0 
    Private cRoteiro         := ''
    Private cEndereco        := ''
	Private cBairro          := ''
	Private cCidade          := '' 
	Private cCep             := ''
	Private cNomeGerente     := ''
	Private cNomePromotor    := ''
	Private cNomeSupervisor  := ''
	Private cEmailGerente    := ''
	Private cEmailPromotor   := ''
	Private cEmailSupervisor := ''
	Private cEmailVendedor   := ''
	Private cUltEntrega      := ''
	
	dDtEntrini  := STOD(cDtEntrega)
    dDtEntrfin  := STOD(cDtEntrega)
    cPlacaIni   := cPlaca
    cPlacaFin   := cPlaca
    cRoteiroIni := cRot
    cRoteiroFin := cRot  
    cFilini     := cFil
    cFilfin     := cFil
	
	//se o sql nao funcionar essas variaveis vem vazias e retorna para a funcao que a chamou
	IF ALLTRIM(cDtEntrega) == '' .AND. ;
	   ALLTRIM(cPlaca)     == '' .AND. ;
       ALLTRIM(cRot)       == '' .AND. ;
       ALLTRIM(cFil)       == ''       
       
    	cMetodo     := 'ERRO_SQL'
	    nId         := 2
	    cMens       := 'Atenção erro na sintaxe do sql provavelmente GETDATE do sistema errado'
	    EmailViagem(cMetodo,nId,cMens) 
	    RETURN(NIL)   
       
    ENDIF           
    
    SqlRot()
	cRotCabOld := ''
	cRotRodOld := TRB->C5_ROTEIRO
	
	While TRB->(!EOF())  
	
		cRotCab := TRB->C5_ROTEIRO //Valor do Cabeçalho para  criar o xml
	    cRotRod := TRB->C5_ROTEIRO //Valor do Rodapé para jogar os valores do xml no arquivo
	    //Primeira vez que entra no Roteiro 
	    
		IF cRotCab <> cRotCabOld
	 
			cRotCabOld := cRotCab   
			cRotRodOld := cRotRod                                  
			
			// *************************** INICIO VERIFICACAO DO TIPO FRETE ********************************************************* //
			cTipoFrete := 'DIS'	//TIPO FRETE DISTRIBUICAO
			
			// *************************** FINAL VERIFICACAO DO TIPO FRETE ********************************************************* //
			
			// *************************** INICIO VERIFICACAO DA HORA INICIAL ********************************************************* //
			IF ALLTRIM(TRB->ZFA_HORA) == '' 
			
				cHoraSai := Substr( TRB->C5_DTENTR,1,4)+ '-' + Substr( TRB->C5_DTENTR,5,2)+ '-' + Substr( TRB->C5_DTENTR,7,2) +  "T" + '00:00:00'
			
			ELSE              
			
				cHoraSai := Substr( TRB->C5_DTENTR,1,4)+ '-' + Substr( TRB->C5_DTENTR,5,2)+ '-' + Substr( TRB->C5_DTENTR,7,2) +  "T" + TRB->ZFA_HORA
				
			ENDIF
			// *************************** FINAL VERIFICACAO DA HORA INICIAL ********************************************************* //
			
			// *************************** INICIO VERIFICACAO DA HORA INICIAL ********************************************************* //
			IF ALLTRIM(TRB->ZFA_DTAPRO) == '' 
			
				cHoraRet := Substr( TRB->C5_DTENTR,1,4)+ '-' + Substr( TRB->C5_DTENTR,5,2)+ '-' + Substr( TRB->C5_DTENTR,7,2) + "T" + '23:59:59'
			
			ELSE              
			
				cHoraRet := Substr( TRB->ZFA_DTAPRO,1,4)+ '-' + Substr( TRB->ZFA_DTAPRO,5,2)+ '-' + Substr( TRB->ZFA_DTAPRO,7,2) + "T" + '23:59:59'
				
			ENDIF
			// *************************** FINAL VERIFICACAO DA HORA INICIAL ********************************************************* //
		ENDIF //fecha if cRotCab <> cRotCabOld
		
			// ************************************ Inicio Carrega XML do no de viagem *******************************
			oWs:OWSVIAGEM:CCNPJUNIDADE             := ALLTRIM(RetField('SM0',1,cEmpAnt+cFil,'M0_CGC'))
	      	oWs:OWSVIAGEM:CCODIGODESTINO           := ALLTRIM(TRB->C5_ROTEIRO)
	      	oWs:OWSVIAGEM:CCODIGOORIGEM            := ALLTRIM(RetField('SM0',1,cEmpAnt+cFil,'M0_CODFIL'))
	      	oWs:OWSVIAGEM:CDESTINO                 := '' //NOACENTO2(ALLTRIM(TRB->C5_CIDADE))
	      	oWs:OWSVIAGEM:CESTIMATIVAFIM           := ALLTRIM(cHoraRet)
	      	oWs:OWSVIAGEM:CESTIMATIVAINICIO        := ALLTRIM(cHoraSai)
	      	oWs:OWSVIAGEM:CFONEMOTORISTA           := ''
	      	oWs:OWSVIAGEM:CIDENTIFICADOR           := ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
	      	oWs:OWSVIAGEM:CMOTORISTA               := ''
	      	oWs:OWSVIAGEM:COBSERVACOES             := SPACE(01)
	        oWs:OWSVIAGEM:CORIGEM                  := ALLTRIM(RetField('SM0',1,cEmpAnt+cFil,'M0_NOMECOM'))
	        oWs:OWSVIAGEM:CPLACA                   := ALLTRIM(TRB->C5_PLACA)
	        oWs:OWSVIAGEM:CPRODUTO                 := ALLTRIM('FRANGO')
	      	oWs:OWSVIAGEM:CTIPO                    := ALLTRIM(cTipoFrete)
	      	oWs:OWSVIAGEM:NCUBAGEM                 := 0
			oWs:OWSVIAGEM:NDIASEMROTA              := 0
            oWs:OWSVIAGEM:NIDCLIENTE               := 0
            oWs:OWSVIAGEM:NIDCOOPERATIVA           := 0 
            oWs:OWSVIAGEM:NIDEMBARCADOR            := 0
            oWs:OWSVIAGEM:NIDROTEIRIZADOR          := ACHARIDROTEIRZADOR(TRB->C5_DTENTR,TRB->C5_ROTEIRO) 
            oWs:OWSVIAGEM:NIDTRANSPORTADORA        := 0 //VAL(TRB->C5_TRANSP)
            oWs:OWSVIAGEM:NIDUNIDADE               := 0
	      	oWs:OWSVIAGEM:NPESO                    := TRB->ZFA_KGBT 
	      	oWs:OWSVIAGEM:NTEMPERATURAMAXIMA       := 0
	      	oWs:OWSVIAGEM:NTEMPERATURAMINIMA       := 0
	      	oWs:OWSVIAGEM:NVALOR                   := TRB->ZFA_VALOR
	      	oWs:OWSVIAGEM:NVIAGEMPRIORITARIA       := 0
	      	oWs:OWSVIAGEM:NQTDCAIXAS               := 0 
	      	oWs:OWSVIAGEM:CNUMEROORDEMCARREGAMENTO := TRB->C5_X_SQED
	      	oWs:OWSVIAGEM:LPOSSUIORDEMESPECIAL     := .F. 
	      	oWs:OWSVIAGEM:NKMESTIMADO              := 0 
	      	oWs:OWSVIAGEM:NDIVISAOEMPRESARIAL      := 0
			oWs:OWSVIAGEM:NIDPROJETO               := 0

			//Carrega informacoes de data e horario do carregamento inicial e final
	      	SqlHrCarga(STR(VAL(TRB->C5_X_SQED)))
	      	While TRG->(!EOF())
	      	    
	      		oWs:OWSVIAGEM:CINICIOPREFRIO       := Substr( TRG->DT_PREFRIO,7,4)   + '-' + Substr( TRG->DT_PREFRIO,4,2)   + '-' + Substr( TRG->DT_PREFRIO,1,2)   +  "T" + ALLTRIM(TRG->HR_PREFRIO)
	      		oWs:OWSVIAGEM:CINICIOCARREGAMENTO  := Substr( TRG->DT_ABERTCARG,7,4) + '-' + Substr( TRG->DT_ABERTCARG,4,2) + '-' + Substr( TRG->DT_ABERTCARG,1,2) +  "T" + ALLTRIM(TRG->HR_ABERTCARG)
	      		oWs:OWSVIAGEM:CFIMCARREGAMENTO     := Substr( TRG->DT_FECHCARG,7,4)  + '-' + Substr( TRG->DT_FECHCARG,4,2)  + '-' + Substr( TRG->DT_FECHCARG,1,2)  +  "T" + ALLTRIM(TRG->HR_FECHCARG)
	      		
		      	TRG->(dbSkip())
					
			ENDDO //FECHA WHILE DO TRG
			    	    
			TRG->(dbCloseArea()) 
	      	
	      	//************************************ final Carrega XML do no de viagem *******************************
		      	
	      	//************************************ Inicio Carrega XML do no de entrega *******************************   
	      	
	      	cFil    := TRB->C5_FILIAL  
	      	cDtEntr := TRB->C5_DTENTR
	      	SqlEntregas()            
	      	cFil    := ''
	      	cDtEntr := ''
	      	
	      	/////// ************INICIO CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
	      	oWs:OWSVIAGEM:OWSENTREGAS := sivirafullWebService_ArrayOfEntrega():New() 
			/////// ************FINAL CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
	      	
      		While TRC->(!EOF())
      		    
      			nLTRC := nLTRC + 1 //soma linha do ní
      			
      			cEndereco  := ''
				cBairro    := ''
				cCidade    := '' 
				cCep       := ''
								
      			If Alltrim(TRC->A1_SATIV1)="50" .and. Alltrim(TRC->A1_SATIV2)$"51,52,53"
			    	cEndereco  := TRC->A1_ENDENT
					cBairro    := NOACENTO2(TRC->A1_BAIRROE)
					cCidade    := TRC->A1_MUNE
					cCep       := TRC->A1_CEPE
				ElseIf TRC->A1_IMPENT = "S" //Adoro  para endereço de entrega diferente e cozinha industrial    
				    cEndereco  := TRC->A1_ENDENT
					cBairro    := NOACENTO2(TRC->A1_BAIRROE)
					cCidade    := TRC->A1_MUNE
					cCep       := TRC->A1_CEPE
				Else 
					cEndereco  := TRC->A1_END
					cBairro    := TRC->A1_BAIRRO
					cCidade    := TRC->A1_MUN 
					cCep       := TRC->A1_CEP
				Endif	
				
			    oWsEntrega                   := sivirafullWebService_Entrega():New() 
	            OWSENTREGA:CBAIRRO           := ALLTRIM(cBairro)
	    		OWSENTREGA:CCIDADE           := ALLTRIM(cCidade)
	    		OWSENTREGA:CCODIGO           := ALLTRIM(TRC->C5_CLIENTE+TRC->C5_LOJACLI)
	    		OWSENTREGA:CENDERECO         := ALLTRIM(cEndereco)  
	    		OWSENTREGA:CESTIMATIVAFIM    := ALLTRIM(cHoraRet)
		      	OWSENTREGA:CESTIMATIVAINICIO := ALLTRIM(cHoraSai)
		      	OWSENTREGA:CREFERENCIA       := NoAcento2(ALLTRIM(POSICIONE('SA1',1,xFilial("SA1")+TRC->C5_CLIENTE+TRC->C5_LOJACLI,'A1_NOME')))
		      	OWSENTREGA:NCUBAGEM          := 0
		      	OWSENTREGA:NLATITUDE         := VAL(STRTRAN(TRC->A1_XLATITU,',','.'))
		      	OWSENTREGA:NLONGITUDE        := VAL(STRTRAN(TRC->A1_XLONGIT,',','.'))
		      	OWSENTREGA:NPESO             := TRC->C5_PBRUTO
		      	OWSENTREGA:NSEQUENCIA        := nLTRC
		      	OWSENTREGA:NVALOR            := TRC->C6_VALOR  
		      	OWSENTREGA:CTIPOCLIENTE      := Posicione("SX5",1,TRC->C5_FILIAL+"_S"+TRC->A1_SATIV1,"X5_DESCRI")
		      	OWSENTREGA:NQTDCAIXAS        := 0 
		      	OWSENTREGA:NTEMPOENTREGA     := 0
		      	OWSENTREGA:cIniRecebManha    := TRC->A1_HRINIM
				OWSENTREGA:cFimRecebManha    := TRC->A1_HRFINM
				OWSENTREGA:cIniRecebTarde    := TRC->A1_HRINIT
				OWSENTREGA:cFimRecebTarde    := TRC->A1_HRFINT
				OWSENTREGA:lColeta           := .F.
		      
		      	AAdd(oWs:OWSVIAGEM:OWSENTREGAS:OWSENTREGA, OWSENTREGA)
		      	// ************************************ Final Carrega XML do no de entrega *******************************
		      	// ************************************ Inicio Carrega XML do no de notas fiscais *******************************      
		      	
		      	cFil       := TRB->C5_FILIAL  
		      	cCliente   := TRC->C5_CLIENTE
                cLojaCli   := TRC->C5_LOJACLI
                cDtEntr    := TRB->C5_DTENTR
                cPlaca     := TRB->C5_PLACA
				cRoteiro   := TRB->C5_ROTEIRO   
				cSeq       := TRC->C5_SEQUENC
				SqlNotas()      
                cFil       := ''
		      	cCliente   := ''
                cLojaCli   := ''
                cDtEntr    := ''
                cPlaca     := ''
                cRoteiro   := ''
                cSeq       := ''
                
                /////// ************INICIO CRIA VETOR E VARIAVEIS DE Notas Fiscais******************************************
			    oWs:OWSVIAGEM:OWSENTREGAS:OWSENTREGA[nLTRC]:OWSNOTASFISCAIS := sivirafullWebService_ArrayOfNotaFiscal():New() 
				/////// ************FINAL CRIA VETOR E VARIAVEIS DE Notas Fiscais******************************************
                
	      		While TRD->(!EOF())
	      		
	      			nLTRD := nLTRD + 1 //soma linha do ní
	      		
	      			IF ALLTRIM(TRD->C5_PRIOR) = ''
	      			
	      				cPriori := 'E'
	      			ELSE              
	      			
	      				cPriori := 'R'
	      				
	      			ENDIF   
	      			
	      			cNomeGerente     := ''
	      			cNomePromotor    := ''
	      			cNomeSupervisor  := ''
	      			cEmailGerente    := ''
					cEmailPromotor   := ''
					cEmailSupervisor := ''
					cEmailVendedor   := ''
	      			cNomeGerente     := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_NOMSUP'))                
					cNomePromotor    := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_NOMSUP'))                
	      			cNomeSupervisor  := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_NOMSUP'))                
	      			cEmailGerente    := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_EMAIL'))                 
					cEmailPromotor   := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_EMAIL'))                 
					cEmailSupervisor := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_EMAIL'))                 
					cEmailVendedor   := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->F2_VEND1,'A3_EMAIL'))                 
	      			cNomeGerente     := StrTran(cNomeGerente, "-", '') 
	      			cNomePromotor    := StrTran(cNomePromotor, "-", '') 
	      			cNomeSupervisor  := StrTran(cNomeSupervisor, "-", '') 	                  
	      			cNomeGerente     := StrTran(cNomeGerente, "/", '') 
	      			cNomePromotor    := StrTran(cNomePromotor, "/", '') 
	      			cNomeSupervisor  := StrTran(cNomeSupervisor, "/", '') 	                  
	      			cEmailGerente    := SUBSTR(cEmailGerente,   1,IIF(AT(';',cEmailGerente)    > 0, AT(';',cEmailGerente)    - 1, LEN(cEmailGerente)))
					cEmailPromotor   := SUBSTR(cEmailPromotor,  1,IIF(AT(';',cEmailPromotor)   > 0, AT(';',cEmailPromotor)   - 1, LEN(cEmailPromotor)))
					cEmailSupervisor := SUBSTR(cEmailSupervisor,1,IIF(AT(';',cEmailSupervisor) > 0, AT(';',cEmailSupervisor) - 1, LEN(cEmailSupervisor)))
					cEmailVendedor   := SUBSTR(cEmailVendedor,  1,IIF(AT(';',cEmailVendedor)   > 0, AT(';',cEmailVendedor)   - 1, LEN(cEmailVendedor)))
	      			
	      			OWSNOTAFISCAL                      := sivirafullWebService_NotaFiscal():New()    
	      		    OWSNOTAFISCAL:CCODIGOGERENTE       := ALLTRIM(TRD->A3_SUPER)                                                              
					OWSNOTAFISCAL:CCODIGOPROMOTOR      := ALLTRIM(TRD->A3_SUPER)                                                              
					OWSNOTAFISCAL:CCODIGOSUPERVISOR    := ALLTRIM(TRD->A3_SUPER)                                                              
					OWSNOTAFISCAL:CCODIGOVENDEDOR      := ALLTRIM(TRD->F2_VEND1)                                                              
					OWSNOTAFISCAL:CEMAILGERENTE        := cEmailGerente
					OWSNOTAFISCAL:CEMAILPROMOTOR       := cEmailPromotor
					OWSNOTAFISCAL:CEMAILSUPERVISOR     := cEmailSupervisor
					OWSNOTAFISCAL:CEMAILVENDEDOR       := cEmailVendedor 
					OWSNOTAFISCAL:CESTIMATIVAFIM       := ALLTRIM(cHoraRet)                                                                   
					OWSNOTAFISCAL:CESTIMATIVAINICIO    := ALLTRIM(cHoraSai)                                                                   
					OWSNOTAFISCAL:CFONEGERENTE         := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL'))                   
					OWSNOTAFISCAL:CFONEPROMOTOR        := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL'))                   
					OWSNOTAFISCAL:CFONESUPERVISOR      := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL'))                 
					OWSNOTAFISCAL:CFONEVENDEDOR        := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL'))
					OWSNOTAFISCAL:CIDENTIFICADORPEDIDO := TRD->C5_NUM                 
					OWSNOTAFISCAL:CNOMEGERENTE         := cNomeGerente 
					OWSNOTAFISCAL:CNOMEPROMOTOR        := cNomePromotor 
					OWSNOTAFISCAL:CNOMESUPERVISOR      := cNomeSupervisor
					OWSNOTAFISCAL:CNOMEVENDEDOR        := ALLTRIM(POSICIONE('SA3',1,xFilial("SA3")+TRD->F2_VEND1,'A3_NOME'))                  
					OWSNOTAFISCAL:CNUMERO              := ALLTRIM(CVALTOCHAR(VAL(TRD->F2_DOC)))                                               
					OWSNOTAFISCAL:COBSERVACOES         := ''                                                                         
					OWSNOTAFISCAL:CREFERENCIA          := NoAcento2(ALLTRIM(POSICIONE('SA1',1,xFilial("SA1")+TRC->C5_CLIENTE+TRC->C5_LOJACLI,'A1_NOME')))
					OWSNOTAFISCAL:CTIPOOPERACAO        := ALLTRIM(cPriori)                                                                    
					OWSNOTAFISCAL:NCUBAGEM             := 0                                                                          
					OWSNOTAFISCAL:NDIVISAOEMPRESARIAL  := 0
					OWSNOTAFISCAL:NPESO                := TRD->F2_PBRUTO                                                             
					OWSNOTAFISCAL:NPESOLIQUIDO         := TRD->F2_PLIQUI                                                             
					OWSNOTAFISCAL:NSEQUENCIA           := nLTRD //VAL(TRD->C5_SEQUENC)                                                            
					OWSNOTAFISCAL:NSERIE               := VAL(TRD->F2_SERIE)
					OWSNOTAFISCAL:NVALOR               := TRD->F2_VALBRUT   
					OWSNOTAFISCAL:NQTDCAIXAS           := 0
					OWSNOTAFISCAL:LORDEMESPECIAL       := .F.
					OWSNOTAFISCAL:NDIVISAOEMPRESARIAL  := 0
					OWSNOTAFISCAL:NNUMEROPEDIDO        := 0
					OWSNOTAFISCAL:NREMETENTE           := 0
					OWSNOTAFISCAL:CCNPJREMETENTE       := NIL
					OWSNOTAFISCAL:CNUMEROCTE           := ''
					OWSNOTAFISCAL:NVALORCTE            := 0
					OWSNOTAFISCAL:CDATAEMISSAOCTE      := cHoraSai
					OWSNOTAFISCAL:NIDPROJETO           := 0
					OWSNOTAFISCAL:NPRIORIDADE          := nLTRD
					
					//enviando notas da viagem para o vetor
					//para se der confirmacao no envio do webservice
					//atualizar o campo do ravex no SF2
					aNota := {}            
					AAdd(aNota,TRD->F2_FILIAL)
					AAdd(aNota,TRD->F2_DOC)
					AAdd(aNota,TRD->F2_SERIE)
                    AAdd(aNotaRavex,aNota)
										
					AAdd(oWs:OWSVIAGEM:OWSENTREGAS:OWSENTREGA[nLTRC]:OWSNOTASFISCAIS:OWSNOTAFISCAL, OWSNOTAFISCAL)
					// ************************************ Inicio Carrega XML do no de ITENS *******************************
			      	
			      	cFil       := TRB->C5_FILIAL  
			      	cCliente   := TRC->C5_CLIENTE
	                cLojaCli   := TRC->C5_LOJACLI
	                cNota      := TRD->F2_DOC
	                cSerie     := TRD->F2_SERIE
	                SqlItens()      
	                cFil       := ''
			      	cCliente   := ''
	                cLojaCli   := ''
	                cNota      := ''
	                cSerie     := ''
	                
	                /////// ************INICIO CRIA VETOR E VARIAVEIS DE ITENS******************************************
		      		oWs:OWSVIAGEM:OWSENTREGAS:OWSENTREGA[nLTRC]:OWSNOTASFISCAIS:OWSNOTAFISCAL[nLTRD]:OWSITENS := sivirafullWebService_ArrayOfItem():New() 
					/////// ************FINAL CRIA VETOR E VARIAVEIS DE ITENS******************************************
	                
		      		While TRE->(!EOF())   
		      		    
		      		    OWSITEM                      := sivirafullWebService_Item():New()    
		      			OWSITEM:CCODIGO              := ALLTRIM(TRE->D2_COD)
						OWSITEM:CDESCRICAO           := ALLTRIM(TRE->B1_DESC)
						OWSITEM:CFABRICADOEM         := ALLTRIM(cHoraSai)
						OWSITEM:CLOTE                := SPACE(01)
						OWSITEM:CUNIDADE             := ALLTRIM(TRE->D2_UM)
						OWSITEM:CVALIDOATE           := ALLTRIM(cHoraRet)
						OWSITEM:NCUBAGEMUNITARIA     := 0
						OWSITEM:NDIASVALIDADE        := 0
						OWSITEM:NPESOLIQUIDOUNITARIO := 0
						OWSITEM:NPESOTOTALBRUTO      := 0
						OWSITEM:NPESOTOTALLIQUIDO    := 0
						OWSITEM:NPESOUNITARIO        := IIF(ALLTRIM(TRE->D2_UM) == 'KG',1,TRE->PESOUNIT) //WILLIAM COSTA 30/08/2019 CHAMADO 051399 || OS 052723 || ADM || HELDER || 7351 || WEBSERVICE RAVEX
						OWSITEM:NQUANTIDADE          := TRE->D2_QUANT //WILLIAM COSTA 30/08/2019 CHAMADO 051399 || OS 052723 || ADM || HELDER || 7351 || WEBSERVICE RAVEX 
						OWSITEM:NSEQUENCIA           := VAL(TRE->D2_ITEM)
						OWSITEM:NVALORUNITARIO       := TRE->D2_PRCVEN 
						OWSITEM:NPRIORIDADE          := 0
						
						AAdd(oWs:OWSVIAGEM:OWSENTREGAS:OWSENTREGA[nLTRC]:OWSNOTASFISCAIS:OWSNOTAFISCAL[nLTRD]:OWSITENS:OWSITEM, OWSITEM)
				      	
				      	TRE->(dbSkip())
                    ENDDO //FECHA WHILE DO TRE
			    	
					TRE->(dbCloseArea()) 
		      		// ************************************ Final Carrega XML do no de Itens *******************************
			      	
			      	TRD->(dbSkip())
		
				ENDDO //FECHA WHILE DO TRD
				nLTRD := 0 // Zera o contador de linha do SQL TRD 
		    	TRD->(dbCloseArea()) 
	      		// ************************************ Final Carrega XML do no de notas fiscais *******************************
	      		
	      		SqlTabFrete(TRB->ZFA_TABFRT)
	      		While TRH->(!EOF())
	      		
					oWs:OWSVIAGEM:oWSTabelaFrete                        := sivirafullWebService_Frete():New()    
	      			oWs:OWSVIAGEM:oWSTabelaFrete:cCodigo                := TRH->ZF5_TABCOD
					oWs:OWSVIAGEM:oWSTabelaFrete:cNome                  := TRH->ZF5_TABDES
					oWs:OWSVIAGEM:oWSTabelaFrete:cTipoVeiculo           := ''
					oWs:OWSVIAGEM:oWSTabelaFrete:cPerfil                := ''
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorPernoite         := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorDiaria           := TRH->ZF5_TABSAI
					oWs:OWSVIAGEM:oWSTabelaFrete:nQtdeDiaria            := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorDescarga         := 0   
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorAdicionalEntrega := TRH->ZF5_VLRENT 
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorPedagio          := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorAjudante         := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorChapa            := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorKm               := BUSCAVALORKM(TRH->ZF5_TABCOD)
					oWs:OWSVIAGEM:oWSTabelaFrete:nFranquiaKm            := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorKmExcedente      := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValorCombustivel      := 0
					oWs:OWSVIAGEM:oWSTabelaFrete:nValor                 := 0
					TRH->(dbSkip())
			
				ENDDO //FECHA WHILE DO TRH
				TRH->(dbCloseArea()) 	
				
		      	TRC->(dbSkip())
			
			ENDDO //FECHA WHILE DO TRC
			nLTRC := 0 // Zera o contador de linha do SQL TRC  
	    	TRC->(dbCloseArea()) 

			SLEEP(30000)
	    	
	    	If oWs:ImportarViagemFaturada()
	
			   oResp   := oWs:oWSImportarViagemFaturadaResult  
			   cMetodo := 'Viagem'
			   nId     := oResp:NID  
			   
			   IF nId >= 0
			   		IF nId > 0
			        	nId :=1   
			   		ENDIF
			   		AddCampoRavex()
			   ENDIF
			   
			   aEnt  := {}
		       Aadd(aEnt,oResp:cmensagem)
		       Aadd(aEnts,aEnt)
			   
			Else
			 
				cMetodo := 'Viagem'
			    nId     := -1
			    EmailViagem(cMetodo,nId,GetWSCError())
			 
			Endif
			
			//zera vetores de nota
			aNota      := {}
			aNotaRavex := {}  
			
			TRB->(dbSkip())
			
	ENDDO //FECHA WHILE DO TRB
	    	    
	TRB->(dbCloseArea())  
	
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
	   cSubject := "WEBSERVICE VIAGEM LOGISTICA"          
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
	   
	   FOR nContEmail:=1 TO LEN(aEnts)
	   
	   		cRet += aEnts[nContEmail][1] + "<br>"
	
	   NEXT
	   	
	ENDIF	
	
	IF LEN(aEnts) > 0        .AND. ; 
	   _cStatEml == 'Viagem' .AND. ;
	   (nId      == -1        .OR. ;
	   nId       == 0) 
 	
	   cRet += " WEBSERVICE Viagem já existe"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	   cRet += "<br>"
	   //cRet += "Identificador: " + ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
	   
	    FOR nContEmail:=1 TO LEN(aEnts)
	   
	   		cRet += aEnts[nContEmail][1] + "<br>"
	
	   NEXT

	ENDIF  
	
	IF LEN(aEnts) == 0        .AND. ;
	   _cStatEml  == 'Viagem' .AND. ; 
	   (nId      == -1        .OR. ;
	   nId       == 0) 
	   
 	
	   cRet += " WEBSERVICE Viagem COM ERRO"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	   cRet += "<br>"
	   cRet += "Identificador: " + ALLTRIM(TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO)
	   
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

	FOR nCont := 1 TO LEN(aNotaRavex)

		DbSelectArea("SF2")
							
			SF2->(dbsetorder(1))
			IF SF2->(dbseek(aNotaRavex[nCont][1] + aNotaRavex[nCont][2] + aNotaRavex[nCont][3], .T.)) //filial+nota+serie
			
				RecLock("SF2",.F.)
		
					SF2->F2_XRAVEX := .T. // Atualiza o campo de integracao com o ravex
					                         //afirmando que a nota foi integrada com o ravex
				SF2->( MsUnLock() ) 
			ENDIF                    
		
		SF2->(dbCloseArea())         
		
	NEXT	
					
Return() 

Static Function logZBN(cStatus)

	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','20:00:00',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','11:20:00',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','00:05:00','')))
	Local cHoraSegunda := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','20:30:00',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','11:40:00',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','00:35:00','')))
	Local nTotVezes    := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00',8,IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00',7,IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00',16,0)))
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
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG003P')) //procura o registro
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
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG003P'))
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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG003P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG003P'
			ZBN_DESCRI  := 'Integração PROTHEUS X RAVEX'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','30 MIN - 08 VEZES',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','30 MIN - 07 VEZES',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','30 MIN - 16 VEZES','')))
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','20:00:00',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','11:20:00',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','00:05:00','')))
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG003P'
			ZBN_DESCRI  := 'Integração PROTHEUS X RAVEX'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','30 MIN - 08 VEZES',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','30 MIN - 07 VEZES',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','30 MIN - 16 VEZES','')))
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := IIF(TIME() >= '20:00:00' .AND. TIME() <= '23:59:00','20:00:00',IIF(TIME() >= '11:20:00' .AND. TIME() <= '15:00:00','11:20:00',IIF(TIME() >= '00:05:00' .AND. TIME() <= '08:40:00','00:05:00','')))
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

STATIC FUNCTION NoAcento2(cString)

	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
	Local cTio   := "ãõÃÕ"
	Local cCecid := "çÇ"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	
	If cMaior$ cString 
		cString := strTran( cString, cMaior, "" ) 
	EndIf
	If cMenor$ cString 
		cString := strTran( cString, cMenor, "" )
	EndIf
	
	cString := StrTran( cString, CRLF, " " )
	
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	//Especifico Adoro devido a erro XML não solucionado versao 3.10
	cString := StrTran(cString,"&","e")
	cString := StrTran(cString,"'","")
	
Return cString 

STATIC FUNCTION BUSCAVALORKM(cTabela)

	Local nValorKm := 0

	SqlTabITem(cTabela)
	While TRI->(!EOF())

		nValorKm := TRI->ZF6_TABPRC
			
		TRI->(dbSkip())

	ENDDO //FECHA WHILE DO TRH
	TRI->(dbCloseArea())

RETURN(nValorKm)

STATIC FUNCTION ACHARIDROTEIRZADOR(cDtEnt,cRot)

	Local nIdRot := 0

	SqlIDROT(cDtEnt,cRot)
	While TRJ->(!EOF())
	
		IF TRJ->C5_XNIDROT > 0

			nIdRot := TRJ->C5_XNIDROT

		ENDIF
			
		TRJ->(dbSkip())

	ENDDO //FECHA WHILE DO TRH
	TRJ->(dbCloseArea())

RETURN(nIdRot)

STATIC FUNCTION SqlIntNota()

    //LPM 
    BeginSQL Alias "TRA"
			%NoPARSER% 
				SELECT SC5.C5_FILIAL, 
				       SC5.C5_ROTEIRO, 
				       SC5.C5_PLACA, 
				       SC5.C5_DTENTR,
				       COUNT(SF2.F2_DOC) AS F2_CONTDOC,
				       SF2.F2_EMISSAO, 
				       CASE WHEN SF2.F2_CHVNFE = '' then 0  else COUNT(SF2.F2_CHVNFE) END AS F2_CONTCHVNFE,
					   CASE WHEN ISNULL(ZFA.ZFA_VEICPG,'') = '' then 0  else COUNT(ZFA.ZFA_VEICPG) END AS ZFA_CONT
				FROM %Table:SC5% SC5 WITH(NOLOCK) INNER JOIN %Table:SF2% SF2 WITH(NOLOCK) ON 
															SF2.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*'
														AND SC5.C5_FILIAL   = SF2.F2_FILIAL
														AND SC5.C5_NOTA     = SF2.F2_DOC
														AND SC5.C5_SERIE    = SF2.F2_SERIE
														AND SC5.C5_CLIENT   = SF2.F2_CLIENT
														AND SC5.C5_LOJACLI  = SF2.F2_LOJA
												  LEFT  JOIN %Table:ZFA% ZFA WITH(NOLOCK) ON 
															ZFA.D_E_L_E_T_ <> '*'
														AND ZFA.ZFA_VEICPG  = SC5.C5_PLACA
														AND ZFA.ZFA_DTENTR  = SC5.C5_DTENTR
														AND ZFA.ZFA_ROTEIR  = SC5.C5_ROTEIRO
				WHERE SC5.C5_FILIAL  >= %exp:cFilini%
				  AND SC5.C5_FILIAL  <= %exp:cFilfin% 
				  AND SC5.C5_DTENTR  >= CONVERT(VARCHAR(8), GETDATE(), 112)
				  AND SC5.C5_NOTA    <> ''
				  AND SC5.C5_PLACA   <> '' 
				  AND SC5.C5_ROTEIRO >= '300'
                  AND SC5.C5_ROTEIRO <= '999'
				  AND SC5.C5_XRAVEX   = 'T'
				  AND SF2.F2_XRAVEX   = 'F'
				  GROUP BY SC5.C5_FILIAL,SC5.C5_ROTEIRO, SC5.C5_PLACA, SC5.C5_DTENTR,SF2.F2_EMISSAO,SF2.F2_CHVNFE, ZFA_VEICPG
				  ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO

    EndSQl          

RETURN(NIL)    

STATIC FUNCTION SqlRot()
     
    Local cDtEntrini := DTOS(dDtEntrini)
    Local cDtEntrfin := DTOS(dDtEntrfin)
    
	BeginSQL Alias "TRB"
			%NoPARSER% 
				SELECT SC5.C5_FILIAL, 
				       SC5.C5_ROTEIRO, 
				       SC5.C5_PLACA, 
				       SC5.C5_DTENTR,
				       SC5.C5_X_SQED,
				       ZFA.ZFA_HORA,
					   ZFA.ZFA_DTAPRO,
					   ZFA.ZFA_KGBT,
					   ZFA.ZFA_VALOR,
					   ZFA.ZFA_TABFRT,
					   ZFA.ZFA_VEICPG
				  FROM %Table:SC5% SC5 WITH(NOLOCK), %Table:ZFA% ZFA WITH(NOLOCK)
				  WHERE SC5.C5_FILIAL  >= %exp:cFilini%
				    AND SC5.C5_FILIAL  <= %exp:cFilfin%
				    AND SC5.C5_DTENTR  >= %exp:cDtEntrini%
				    AND SC5.C5_DTENTR  <= %exp:cDtEntrfin%
				    AND SC5.C5_PLACA   >= %exp:cPlacaIni%
				    AND SC5.C5_PLACA   <= %exp:cPlacaFin%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO >= %exp:cRoteiroIni%
				    AND SC5.C5_ROTEIRO <= %exp:cRoteiroFin%
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''
				    AND ZFA.ZFA_VEICPG  = SC5.C5_PLACA
				    AND ZFA.ZFA_DTENTR  = SC5.C5_DTENTR
				    AND ZFA.ZFA_ROTEIR  = SC5.C5_ROTEIRO
				    AND ZFA.%notDel%
				    AND SC5.%notDel%
				    
			   GROUP BY SC5.C5_FILIAL, 
						SC5.C5_ROTEIRO, 
						SC5.C5_PLACA, 
						SC5.C5_DTENTR,
						SC5.C5_X_SQED,
						ZFA.ZFA_HORA,
						ZFA.ZFA_DTAPRO,
						ZFA.ZFA_KGBT,
						ZFA.ZFA_VALOR,
						ZFA.ZFA_TABFRT,
						ZFA.ZFA_VEICPG
						 
				ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO 
    EndSQl          

RETURN(NIL)    

STATIC FUNCTION SqlEntregas()
     
    BeginSQL Alias "TRC"
			%NoPARSER%
				SELECT SC5.C5_FILIAL,
				       SA1.A1_BAIRROE,
				       SA1.A1_MUNE,
				       SA1.A1_CEP,
				       SA1.A1_CEPE,
				       SA1.A1_EMAIL,
				       SA1.A1_TEL,
				       SA1.A1_NOME,
				       SC5.C5_CLIENTE,
					   SC5.C5_LOJACLI,
					   SA1.A1_ENDENT,
					   SC5.C5_ROTEIRO,
					   SC5.C5_SEQUENC,
					   SA1.A1_SATIV1,
                	   SA1.A1_SATIV2, 
                	   SA1.A1_IMPENT, 
                	   SA1.A1_END,
					   SA1.A1_BAIRRO,
					   SA1.A1_MUN,
					   SA1.A1_XLONGIT,
	                   SA1.A1_XLATITU,
	                   SA1.A1_HRINIM,
	                   SA1.A1_HRFINM,
	                   SA1.A1_HRINIT,
	                   SA1.A1_HRFINT,
					   SUM(SC5.C5_PBRUTO) AS C5_PBRUTO,
					   SUM(SC6.C6_VALOR) AS C6_VALOR	      	
				  FROM %Table:SC5% SC5 WITH(NOLOCK), %Table:SC6% SC6 WITH(NOLOCK), %Table:SA1% SA1 WITH(NOLOCK)
				  WHERE SC5.C5_FILIAL   = %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntr%
				    AND SC5.C5_PLACA   >= %exp:cPlacaIni%
				    AND SC5.C5_PLACA   <= %exp:cPlacaFin%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO  = %exp:cRotCab%
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''
				    AND SC5.C5_FILIAL   = SC6.C6_FILIAL
				    AND SC5.C5_NUM      = SC6.C6_NUM
				    AND SC5.C5_CLIENTE  = SC6.C6_CLI
				    AND SC5.C5_LOJACLI  = SC6.C6_LOJA
				    AND SA1.A1_COD      = SC5.C5_CLIENTE
				    AND SA1.A1_LOJA     = SC5.C5_LOJACLI
				    AND SC5.%notDel%
				    AND SC6.%notDel%
				    AND SA1.%notDel%
				    
				    GROUP BY SC5.C5_FILIAL,
							 SA1.A1_BAIRROE,
				             SA1.A1_MUNE,
				             SA1.A1_CEP,
						     SA1.A1_CEPE,
						     SA1.A1_EMAIL,
						     SA1.A1_TEL,
						     SA1.A1_NOME,
							 SC5.C5_CLIENTE,
							 SC5.C5_LOJACLI,
							 SA1.A1_ENDENT,
							 SC5.C5_ROTEIRO,
							 SC5.C5_SEQUENC,
							 SA1.A1_SATIV1,
                 	         SA1.A1_SATIV2, 
	                         SA1.A1_IMPENT,
	                         SA1.A1_END,
						     SA1.A1_BAIRRO,
						     SA1.A1_MUN,
						     SA1.A1_XLONGIT,
  	                         SA1.A1_XLATITU,
  	                         SA1.A1_HRINIM,
		                     SA1.A1_HRFINM,
	     	                 SA1.A1_HRINIT,
	        	             SA1.A1_HRFINT
							 
			      	ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO,SC5.C5_SEQUENC
			      	
	EndSQl          

RETURN(NIL)    	  

STATIC FUNCTION SqlNotas()      
     
    BeginSQL Alias "TRD"
			%NoPARSER%
				SELECT SF2.F2_FILIAL,
				       SF2.F2_CLIENTE,
				       SF2.F2_LOJA,
				       SA3.A3_SUPER,
				       SF2.F2_VEND1,
				       SF2.F2_DOC,
				       SF2.F2_PBRUTO,
				       SF2.F2_VALBRUT,
				       SF2.F2_SERIE,
				       SC5.C5_PRIOR,
				       SF2.F2_PLIQUI,
				       SC5.C5_SEQUENC,
				       SC5.C5_NUM
				  FROM %Table:SC5% SC5 WITH(NOLOCK), %Table:SF2% SF2 WITH(NOLOCK)
				  LEFT JOIN %Table:SA3% SA3
						ON SF2.F2_VEND1 = SA3.A3_COD
				       AND SA3.%notDel% 
				  WHERE SC5.C5_FILIAL   = %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntr%
				    AND SC5.C5_PLACA   >= %exp:cPlaca%
				    AND SC5.C5_PLACA   <= %exp:cPlaca%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO  = %exp:cRoteiro%
				    AND SC5.C5_SEQUENC  = %exp:cSeq%
				    AND SC5.C5_CLIENTE  = %exp:cCliente%
				    AND SC5.C5_LOJACLI  = %exp:cLojaCli%
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''
				    AND SC5.C5_FILIAL   = SF2.F2_FILIAL
				    AND SC5.C5_NOTA     = SF2.F2_DOC
				    AND SC5.C5_SERIE    = SF2.F2_SERIE
				    AND SC5.C5_CLIENTE  = SF2.F2_CLIENTE
				    AND SC5.C5_LOJACLI  = SF2.F2_LOJA
				    AND SC5.%notDel%
				    AND SF2.%notDel% 
				    
	EndSQl          				   
RETURN(NIL)    	  			

STATIC FUNCTION SqlItens() 
     
    BeginSQL Alias "TRE"
			%NoPARSER%  
			    SELECT SD2.D2_COD,
				       SB1.B1_DESC,
				       (SD2.D2_QUANT / SD2.D2_QTSEGUM) AS PESOUNIT,
				       SD2.D2_QUANT,
				       SD2.D2_QTSEGUM,
				       SD2.D2_ITEM,
				       SD2.D2_PRCVEN,
                       SD2.D2_UM
				  FROM %Table:SD2% SD2 WITH(NOLOCK), %Table:SB1% SB1 WITH(NOLOCK)
				WHERE SD2.D2_FILIAL   = %exp:cFil%
				  AND SD2.D2_CLIENTE  = %exp:cCliente%
				  AND SD2.D2_LOJA     = %exp:cLojaCli%
				  AND SD2.D2_DOC      = %exp:cNota%
				  AND SD2.D2_SERIE    = %exp:cSerie%
				  AND SB1.B1_COD      = SD2.D2_COD
				  AND SD2.%notDel%
				  AND SB1.%notDel%
				  
				  ORDER BY D2_ITEM
    EndSQl          				   
RETURN(NIL)      

STATIC FUNCTION SqlOrdEntregas()
     
    BeginSQL Alias "TRF"
			%NoPARSER%
				SELECT SC5.C5_FILIAL,
				       SC5.C5_CLIENTE,
					   SC5.C5_LOJACLI,
					   SC5.C5_DTENTR,
					   SC5.C5_ROTEIRO,
					   SC5.C5_SEQUENC	      	
				  FROM %Table:SC5% SC5 WITH(NOLOCK)
				  WHERE SC5.C5_FILIAL   = %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntrega%
				    AND SC5.C5_PLACA   >= %exp:cPlacaIni%
				    AND SC5.C5_PLACA   <= %exp:cPlacaFin%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO  = %exp:cRot%
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''
				    AND SC5.%notDel%
				    				    
				    GROUP BY SC5.C5_FILIAL,
					         SC5.C5_CLIENTE,
							 SC5.C5_LOJACLI,
							 SC5.C5_DTENTR,
							 SC5.C5_ROTEIRO,
							 SC5.C5_SEQUENC
							 
			      	ORDER BY SC5.C5_FILIAL,SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_SEQUENC
			      	
	EndSQl          

RETURN(NIL)    

STATIC FUNCTION SqlHrCarga(cNumCarga)
     
    BeginSQL Alias "TRG"
			%NoPARSER% 
			      SELECT TOP(1) ID_CARGEXPE,
								DT_TARAINIC,
								HR_TARAINIC,
								DT_PREFRIO,
								HR_PREFRIO,
								DT_ABERTCARG,
								HR_ABERTCARG,
								DT_FECHCARG,
								HR_FECHCARG
					FROM [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01] 
					WHERE ID_CARGEXPE = %EXP:cNumCarga%
					ORDER BY FILIAL+ID_PEDIVEND
					
	EndSQl          

RETURN(NIL)

STATIC FUNCTION SqlTabFrete(cTabelaFrete)

	Local cFilOrig := FWFILIAL("ZF5")
     
    BeginSQL Alias "TRH"
			%NoPARSER% 
			SELECT ZF5_TABCOD,ZF5_TABDES,ZF5_TABSAI,ZF5_VLRENT 
			  FROM ZF5010
			 WHERE ZF5_FILIAL              = %EXP:cFilOrig%
			   AND ZF5_TABCOD              = %EXP:cTabelaFrete%
			   AND %TABLE:ZF5%.D_E_L_E_T_ <> '*'
    EndSQl          

RETURN(NIL)  

STATIC FUNCTION SqlTabITem(cTabelaFrete)

	Local cFilOrig := FWFILIAL("ZF6")
     
    BeginSQL Alias "TRI"
			%NoPARSER% 
			SELECT ZF6_TABPRC 
			  FROM %TABLE:ZF6%
			 WHERE ZF6_FILIAL              = %EXP:cFilOrig%
			   AND ZF6_TABCOD              = %EXP:cTabelaFrete%
			   AND %TABLE:ZF6%.D_E_L_E_T_ <> '*'

    EndSQl          

RETURN(NIL) 

STATIC FUNCTION SqlIDROT(cDtEntr,cRot)

	Local cFilOrig := FWFILIAL("SC5")
     
    BeginSQL Alias "TRJ"
			%NoPARSER% 
			SELECT C5_XNIDROT 
			  FROM %TABLE:SC5%
			 WHERE C5_FILIAL               = %EXP:cFilOrig%
			   AND C5_DTENTR               = %EXP:cDtEntr%
			   AND C5_ROTEIRO              = %EXP:cRot%
			   AND %TABLE:SC5%.D_E_L_E_T_ <> '*'

    EndSQl          

RETURN(NIL) 

