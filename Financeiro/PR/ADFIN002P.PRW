#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.CH'  
#INCLUDE "rwmake.ch"    
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} User Function U_ADFIN002P()
    Funcao para gerar a data de acumulo e o valor do maior acumulo do envio de arquivo da cisp do financeiro.
    @type  Function
    @author WILLIAM COSTA
    @since 27/05/2015
    @version XX
    @history Chamado 66834 - Leonardo P. Monteiro - 14/01/2022 - Correção dos valores acumulados da CISP com a inclusão e tratamento dos títulos com AB-.
	@history Chamado 66834 - Leonardo P. Monteiro - 17/01/2022 - Correção de error.log.
/*/


USER FUNCTION ADFIN002P() // U_ADFIN002P()
    
	Private aAcumulo    := {}
	Private aReceber    := {}
	Private aRecAux     := {}
	Private aTitBaixado := {} 
	Private aCloneAcum  := {}
	Private cFil        := ''
	Private cPrefixo    := ''
	Private cNum        := ''
	Private cParcela    := ''
	Private cTipo       := ''
	Private cCliente    := ''
	Private cLoja       := ''
	Private nCont       := 0
	Private nSaldo      := 0                   
	Private nSaldoAux   := 0                   
	Private dDtUltimo   := ''
	Private cDtUltimo   := ''
	Private lAcumulo    := .F.
	Private cDataIni    := '' 
	Private cDtAcum     := ''
	Private nVlAcum     := 0   
	Private cCgcOld     := ''
	Private cCgc        := ''
	Private cArq        := ''
	Private nHdl        := ''
	Private cLinha      := ''
	Private cValor      := 0
	Private cData       := '' 
	Private cMetodo     := ''
	Private nId         := 0 
	Private cMensagem   := ''
	
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //  

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	
	If !LockByName("ADFIN002P", .T., .F.)
		ConOut("[ADFIN002P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf
	
	ConOut("INICIO DO SCHEDULE ADFIN002P" + '||' + DTOC(DATE()) + '||' + TIME()) 

	PtInternal(1,ALLTRIM(PROCNAME()))
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para gerar a data de acumulo e o valor do maior acumulo do envio de arquivo da cisp do financeiro.')
	
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	
	cMetodo   := 'INICIANDO MAIOR ACUMULO...'
	nId       := 1
	cmensagem := 'Iniciando o calculo do maior acumulo...'
	 
	EmailMaiorAcum(cMetodo,nId,cmensagem)
	
	cMetodo   := ''
	nId       := 0
	cmensagem := ''
	
	CalcXCGC() // calcula os oito digitos do cgc na SA1 e SE1
	
	CalcDtUltComp() // calcula data da ultima compra da rede 
    
	CalcDtPenComp() // calcula data da penultima compra da rede 	

	IF nId <> 3

		SqlContaCliente() // Verifica se existem clientes sem o cálculo do acúmulo feito ao menos uma vez.
		
		While TRA->(!EOF()) 

			// Caso exista algum cliente que nunca tenha feito o cálculo de acúmulo.        
		    IF TRA->CONT == 0
		    	
				// Gera o acúmulo para o cliente pela primeira vez.
		    	GeraAcumPrimeiraVez() 
		    	                  
		    	//depois que rodou todos roda pela ultima vez.
		    	GravarAcumulo()
			    aCloneAcum := {}
	    		aAcumulo   := {} 
	    		aRecAux    := {}
	    		cCgcOld    := cCgc
		    
		    ELSE
		    	// Reprocessa o acúmulo para os demais clientes que já tiveram um cálculo pela primeira vez.
		    	GeraAcumSegundaVez() 
		    	
		    	//depois que rodou todos roda pela ultima vez
		    	GravarAcumulo()
			    aCloneAcum := {}
	    		aAcumulo   := {}
	    		aRecAux    := {}
	    		cCgcOld    := cCgc
		    
		    ENDIF
							    
		 	TRA->(dbSkip())
		ENDDO
		TRA->(dbCloseArea())                 
		
		cMetodo   := 'FINAL DO CALCULO DO MAIOR ACUMULO...'
		nId       := 2
		cmensagem := 'Terminou o calculo do maior acumulo. Liberado para gerar o arquivo da cisp.'
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		cMetodo   := ''
		nId       := 0
		cmensagem := ''
		
		PutMv("MV_#DTGACU",	DTOS(DATE()))
		PutMv("MV_#GARQAC",	.F.)
		
		U_ADFIN003P() //Programa que gera o txt da cisp na pasta SYSTEM/cisp
		
	ENDIF	
	
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	
	//ConOut("FINAL DO SCHEDULE ADFIN002P" + '||' + DTOC(DATE()) + '||' + TIME())
	
	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADFIN002P")

RETURN(NIL) 	  
	
STATIC FUNCTION GeraAcumPrimeiraVez()	
		
	//informacoes will
	// posicoes a aAcumulo
    // 1-)data do titulo
    // 2-)valor do titulo 
    // 3-)Campo verificador pode ser SE1 OU SE5  se for SE1 e o titulo a receber 
    //    SE5 e o titulo baixado
    // 4-)valores de saldos 
    // 5-)Tipo de Documento
    
    // **************************** inicio carrega vetor aAcumulo **************************** //
	SqlCliente()
	
	cCgcOld := TRB->A1_CGC
	
	While TRB->(!EOF())     
	
		CalculaMaiorAcumulo(TRB->A1_COD,TRB->A1_LOJA,TRB->A1_CGC)

		TRB->(dbSkip()) 
    	
	ENDDO
	TRB->(dbCloseArea()) 
	// **************************** final carrega vetor aAcumulo **************************** //
	
RETURN(NIL) 

STATIC FUNCTION GeraAcumSegundaVez()	
		
	//informacoes will
	// posicoes a aAcumulo
    // 1-)data do titulo
    // 2-)valor do titulo 
    // 3-)Campo verificador pode ser SE1 OU SE5  se for SE1 e o titulo a receber 
    //    SE5 e o titulo baixado
    // 4-)valores de saldos 
    // 5-)Tipo de Documento
    
    // **************************** inicio carrega vetor aAcumulo **************************** //
    //ConOut("ADFIN002P - GeraAcumSegundaVez - ENTREI NA STATIC FUNCTION GeraAcumSegundaVez" + '||' + DTOC(DATE()) + '||' + TIME())
	SqlCliAnoAtual() 
	
	cCgcOld := TRE->A1_CGC
	
	While TRE->(!EOF())
		
		u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
					"CLIENTE: "+TRE->E1_CLIENTE+" LOJA: " +TRE->E1_LOJA+ " CGC: " +TRE->A1_CGC,;
					ComputerName(),LogUserName())
					
		//ConOut("ADFIN002P - GeraAcumSegundaVez - Dentro do While TRE" + TRE->E1_CLIENTE+TRE->E1_LOJA + '||' + DTOC(DATE()) + '||' + TIME())
	
		CalculaMaiorAcumulo(TRE->E1_CLIENTE,TRE->E1_LOJA,TRE->A1_CGC )

	    TRE->(dbSkip()) 
    	
	ENDDO
	TRE->(dbCloseArea()) 
	// **************************** final carrega vetor aAcumulo **************************** //
	
	//ConOut("ADFIN002P - GeraAcumSegundaVez - SAI NA STATIC FUNCTION GeraAcumSegundaVez" + '||' + DTOC(DATE()) + '||' + TIME())
	
RETURN(NIL)  

Static Function CalculaMaiorAcumulo(cCli,cLoj,cCnpj)  

	cCliente    := cCli
    cLoja       := cLoj
    cCgc        := cCnpj
    cData       := '00010101' 
  	aReceber    := {}
  	aTitBaixado := {}
  	
  	//ConOut("ADFIN002P - CalculaMaiorAcumulo - ENTREI NA STATIC FUNCTION CalculaMaiorAcumulo" + cCli+cLoj+cCnpj + '||' + DTOC(DATE()) + '||' + TIME())
    
    IF cCgc <>  cCgcOld
    
	    GravarAcumulo()
	    aCloneAcum := {}
    	aAcumulo   := {}
    	aRecAux    := {}
    	cCgcOld    := cCgc  
    	
    ENDIF
    
	SqlReceber()
	
	While TRC->(!EOF()) 
	
		AADD(aReceber, TRC->E1_EMISSAO) 
		AADD(aReceber, TRC->E1_VALOR)
		AADD(aReceber, 'SE1')
		AADD(aReceber, 0) 
		AADD(aReceber, TRC->E1_TIPO)

		AADD(aAcumulo, aReceber) 
		AADD(aRecAux, aReceber)
	    aReceber := {} 
	    
	    //ConOut("ADFIN002P - CalculaMaiorAcumulo - DENTRO DO WHILE TRC" + TRC->E1_CLIENTE+TRC->E1_LOJA  + '||' + DTOC(DATE()) + '||' + TIME())
	    
	    cFil        := TRC->E1_FILIAL
        cPrefixo    := TRC->E1_PREFIXO
        cNum        := TRC->E1_NUM
        cParcela    := TRC->E1_PARCELA
        cTipo       := TRC->E1_TIPO
        cCliente    := TRC->E1_CLIENTE 
	    cLoja       := TRC->E1_LOJA
	    
	    SqlPagar()  
	    
	    cFil        := ''
        cPrefixo    := ''
        cNum        := ''
        cParcela    := ''
        cTipo       := ''
        cCliente    := ''
	    cLoja       := ''
	    
	    While TRD->(!EOF()) 
	        
			
			AADD(aTitBaixado, TRD->E5_DATA)
			AADD(aTitBaixado, TRD->E5_VLMOED2) 
			AADD(aTitBaixado, 'SE5') 
			AADD(aTitBaixado, 0) 
			AADD(aTitBaixado, TRD->E5_TIPODOC) 
            AADD(aAcumulo, aTitBaixado)
		    aTitBaixado := {}
		    
		    TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
	                           
	    cFil        := TRC->E1_FILIAL
        cPrefixo    := TRC->E1_PREFIXO
        cNum        := TRC->E1_NUM
        cParcela    := TRC->E1_PARCELA
        cTipo       := TRC->E1_TIPO 
        cCliente    := TRC->E1_CLIENTE 
	    cLoja       := TRC->E1_LOJA
	    
	    SqlEstorno()        
	    
	    cFil        := ''
        cPrefixo    := ''
        cNum        := ''
        cParcela    := ''
        cTipo       := '' 
        cCliente    := ''
	    cLoja       := ''
	    
	    While TRF->(!EOF()) 
	        
			AADD(aTitBaixado, TRF->E5_DATA)
			AADD(aTitBaixado, TRF->E5_VLMOED2) 
			AADD(aTitBaixado, 'SE5') 
			AADD(aTitBaixado, 0) 
			AADD(aTitBaixado, TRF->E5_TIPODOC) 
            AADD(aAcumulo, aTitBaixado)
		    aTitBaixado := {}
		    
		    TRF->(dbSkip())
		ENDDO
		TRF->(dbCloseArea())
	    
	 	TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())
	
	// **************************** final carrega vetor aAcumulo **************************************** //
	
	//ConOut("ADFIN002P - CalculaMaiorAcumulo - SAI NA STATIC FUNCTION CalculaMaiorAcumulo" + '||' + DTOC(DATE()) + '||' + TIME())
	
RETURN(NIL)

Static Function GravarAcumulo()
    
	//Local CCliSA1  	:= ''
	//Local ClojaSA1 	:= ''
	Local nCont			:= 1 
	Local nAcumulo		:= Len(aAcumulo)
	
	//ConOut("ADFIN002P - GravarAcumulo - ENTREI NA STATIC FUNCTION GravarAcumulo" + '||' + DTOC(DATE()) + '||' + TIME())
	

	IF nAcumulo > 0
		// **************************** inicio organiza vetor aAcumulo por data ************** //
		
		aSort(aAcumulo,,,{ |X, Y| X[1] + cvaltochar(X[2]) + X[5] < Y[1] + cvaltochar(Y[2]) + Y[5]})
		
		
		
		// **************************** final organiza vetor aAcumulo por data *************** // 
			
		// **************************** inicio calcula os saldo acumulado ******************** //
		
		// posicoes a aAcumulo
		// 1-)data do titulo
	    // 2-)valor do titulo 
		// 3-)Campo verificador pode ser SE1 OU SE5  se for SE1 e o titulo a receber 
		//    SE5 e o titulo baixado
		// 4-)valores de saldos 
		// 5-)Tipo de Documento
		// Se for SE1 soma o valor para ter o saldo
		// Se não ele e SE5 e subtrai o valor do saldo
		// depois a posicao 4 recebe o valor de saldo correto
		
		nSaldo := 0
		FOR nCont := 1 TO nAcumulo
		
			IF aAcumulo[nCont][3] == 'SE1'
			
				nSaldo := nSaldo + aAcumulo[nCont][2]
				
			ELSEIF aAcumulo[nCont][3]  == 'SE5' .AND. ;
			       (aAcumulo[nCont][5] == 'ES' .OR.  ;
			        aAcumulo[nCont][5] == 'E2')//CANCELAMENTO SOMA DE NOVO
			
				nSaldo := nSaldo + aAcumulo[nCont][2]	
				
			ELSE
			
				nSaldo := nSaldo - aAcumulo[nCont][2]
				
			ENDIF	                                
			
			aAcumulo[nCont][4] := nSaldo  
			
		NEXT 
		
		// **************************** final calcula os saldo acumulado ********************* //
		
		// **************************** inicio achar o maior acumulo ************************* //
		// reoordena o vetor para trazer o maior valor e a data deste maior valor
		aSort(aAcumulo,,,{ |X, Y| X[4] > Y[4] }) 
		cDtAcum     := aAcumulo[1][1]
		nVlAcum     := ROUND(aAcumulo[1][4],0)
		
		
		// **************************** final achar o maior acumulo ************************** //
		
		// **************************** inicio verifica datas de maior acumulo *************** //
		
	
 	    nCont      := 1                                      
 	    aCloneAcum := aClone(aAcumulo)
		dDtUltimo  := CTOD(CVALTOCHAR(STRZERO(DAY(DATE()),02) + '/' + ;
		                              IIF(LEN(CVALTOCHAR(MONTH(DATE()))) == 1, '0' + ;
		                              CVALTOCHAR(MONTH(DATE())),CVALTOCHAR(MONTH(DATE()))) + '/' + ;
		                              CVALTOCHAR((YEAR(DATE()) - nCont))))
		            
		IF aCloneAcum[1][1] < DTOS(dDtUltimo)
		
			// **************************** inicio organiza vetor aAcumulo por data ********** //
	
			aSort(aCloneAcum,,,{ |X, Y| X[1] < Y[1] })
	
			// **************************** final organiza vetor aAcumulo por data *********** //
			
			// **************************** inicio organiza vetor aRecAux por data ********** //
		
			aSort(aRecAux,,,{ |X, Y| X[1] + cvaltochar(X[2]) < Y[1] + cvaltochar(Y[2])})
			
			// **************************** final organiza vetor aRecAux por data *********** // 
		    cDtUltimo := aRecAux[LEN(aRecAux)][1] 
		    cDataIni  := DTOS(CTOD(CVALTOCHAR(STRZERO(DAY(DATE()),02) + '/' + ;
		                 IIF(LEN(CVALTOCHAR(MONTH(DATE()))) == 1, '0' + ;
		                 CVALTOCHAR(MONTH(DATE())),CVALTOCHAR(MONTH(DATE())))+'/'+;
		                 CVALTOCHAR((YEAR(DATE()) - nCont)))))
		                 
		    // reoordena o vetor para trazer o maior valor e a data deste maior valor
			aSort(aCloneAcum,,,{ |X, Y| X[4] > Y[4] }) 
			
			FOR nCont := 1 TO LEN(aCloneAcum)
			
				IF aCloneAcum[nCont][1] >= cDataIni .AND. ;
  					   aCloneAcum[nCont][1] <= cDtUltimo  
  					   
  					   IF cDtAcum <= aCloneAcum[nCont][1]  
  					   
  					   		cDtAcum     := aCloneAcum[nCont][1]
		           		    nVlAcum     := ROUND(aCloneAcum[nCont][4],0)
  				 	
  				 	   ENDIF	
  					   EXIT
				ENDIF   
			NEXT	             
		ENDIF
	
		// **************************** final verifica datas de maior acumulo ***************** //
		
		// **************************** inicio gravar informacao do maior acumulo ************ //
		SqlCliCgc()
	    While TRG->(!EOF())
	    
	    	DBSELECTAREA("SA1")
			SA1->(DbSetOrder(1))
			
			IF SA1->(DbSeek(xFilial("SA1")+TRG->A1_COD+TRG->A1_LOJA, .T.))
			
				//ConOut("ADFIN002P - GravarAcumulo - Dentro do While"+TRG->A1_COD+TRG->A1_LOJA+ '||' + DTOC(DATE()) + '||' + TIME())
			
				IF EMPTY(SA1->A1_DTACUMU) .AND. SA1->A1_VLACUMU  <= 0 .AND. nVlAcum <= 0
			   		IF RecLock("SA1",.F.)              
					
						SA1->A1_DTACUMU	:= IIF(STOD(cDtAcum) < SA1->A1_DTACUMU,SA1->A1_DTACUMU, STOD(cDtAcum))
						SA1->A1_VLACUMU	:= 0
		
						MsUnlock()
					ELSE
						u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
									"1- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
									ComputerName(),LogUserName())
					ENDIF
				   
			    ELSEIF !EMPTY(SA1->A1_DTACUMU) .AND. ;
			          SA1->A1_DTACUMU  < STOD(cDtAcum) .AND. ; 
			          (SA1->A1_VLACUMU  < nVlAcum .OR. ;
			          SA1->A1_DTACUMU  < STOD(DTOS(CTOD(CVALTOCHAR(STRZERO(DAY(DATE()),02) + '/' + ;
		                                 IIF(LEN(CVALTOCHAR(MONTH(DATE()))) == 1, '0' + ;
		                                 CVALTOCHAR(MONTH(DATE())),CVALTOCHAR(MONTH(DATE())))+'/'+;
		                                 CVALTOCHAR((YEAR(DATE()) - 1)))))))  
			          
			   		if RecLock("SA1",.F.)              
					
						SA1->A1_DTACUMU	:= IIF(STOD(cDtAcum) < SA1->A1_DTACUMU,SA1->A1_DTACUMU, STOD(cDtAcum))
						SA1->A1_VLACUMU	:= nVlAcum //IIF(nVlAcum < SA1->A1_VLACUMU,SA1->A1_VLACUMU, nVlAcum)
		
						MsUnlock() 
					ELSE
						u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
									"2- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
									ComputerName(),LogUserName())
					endif
			    ELSEIF SA1->A1_VLACUMU <= 0 .AND. ;
			           nVlAcum         >= 0 .AND. ;
			           SA1->A1_DTULTRE >= STOD(cDtAcum)        
			   
			   		if RecLock("SA1",.F.)              
					
						SA1->A1_DTACUMU	:= IIF(STOD(cDtAcum) < SA1->A1_DTACUMU,SA1->A1_DTACUMU, STOD(cDtAcum))
						SA1->A1_VLACUMU	:= IIF(nVlAcum < SA1->A1_VLACUMU,SA1->A1_VLACUMU, nVlAcum)
		
						MsUnlock()		
					ELSE
						u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
									"3- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
									ComputerName(),LogUserName())
					endif
					
				ELSEIF SA1->A1_DTULTRE < STOD(cDtAcum) .AND. ;
			           nVlAcum         > 0   
			        
			        //verifica a soma do saldo e a soma do valor do titulo   
			        SqlVerifSaldo(LEFT(SA1->A1_CGC,8))   
			        While TRJ->(!EOF())
			            
			            IF ROUND(TRJ->E1_VALOR,0) >= nVlAcum
					   		if RecLock("SA1",.F.)              
							
								SA1->A1_DTACUMU	:= SA1->A1_DTULTRE						
								SA1->A1_VLACUMU	:= IIF(nVlAcum < SA1->A1_VLACUMU,SA1->A1_VLACUMU, nVlAcum)
				
								MsUnlock() 
							ELSE
								u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
											"4- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
											ComputerName(),LogUserName())
							endif
						ENDIF			
					TRJ->(DBSKIP())
					ENDDO
					TRJ->(dbCloseArea())
			   
			    ELSE   		
			   
			   		IF RecLock("SA1",.F.)              
					
					    SA1->A1_DTACUMU	:= SA1->A1_DTACUMU
						SA1->A1_VLACUMU	:= SA1->A1_VLACUMU
		
						MsUnlock()
					ELSE
						u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
									"5- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
									ComputerName(),LogUserName())
					ENDIF
			    
			    ENDIF

				SA1->(DBCLOSEAREA())
	        ENDIF
		
			TRG->(DBSKIP())
		ENDDO
		TRG->(dbCloseArea())
    ENDIF
    
    //ConOut("ADFIN002P - GravarAcumulo - SAI NA STATIC FUNCTION GravarAcumulo" + '||' + DTOC(DATE()) + '||' + TIME())    
    
RETURN(NIL) 

STATIC FUNCTION CalcDtUltComp()

	// **************************** inicio gravar informacao da ultima compra da rede ************ //
		//ConOut("ADFIN002P - CalcDtUltComp - ENTREI NA STATIC FUNCTION CalcDtUltComp" + '||' + DTOC(DATE()) + '||' + TIME())
		SqlTOTCGC() //CARREGA TODOS OS CNPJ
	    While TRH->(!EOF())        
	    
	        //CARREGA TODOS OS COD E LOJA DO CNPJ INFORMADO
    		SqlCGCCODCLI(TRH->A1_CGC)
	    	While TRI->(!EOF())    
	    	
	    	    DBSELECTAREA("SA1")
	    	    SA1->(DBGOTOP())
				SA1->(DbSetOrder(1))
				
				IF SA1->(DbSeek(xFilial("SA1")+TRI->A1_COD+TRI->A1_LOJA, .T.))
				
					//ConOut("ADFIN002P - CalcDtUltComp - ENTREI NO IF  ||"+ TRI->A1_COD+TRI->A1_LOJA + '||' + DTOC(DATE()) + '||' + TIME())
					
				
				    IF EMPTY(SA1->A1_DTULTRE)
				    
				    	if RecLock("SA1",.F.)              
						
							SA1->A1_DTULTRE	:= STOD(TRH->E1_EMISSAO)	//GRAVA DT ULT COMPRA DA REDE				
							
							MsUnlock() 
						ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"5- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
                    
                    ELSEIF SA1->A1_DTULTRE < STOD(TRH->E1_EMISSAO)
				   		if RecLock("SA1",.F.)              
						
							SA1->A1_DTULTRE	:= STOD(TRH->E1_EMISSAO)	//GRAVA DT ULT COMPRA DA REDE				
							
							MsUnlock()
						ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"6- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
					ELSE	      
					
						if RecLock("SA1",.F.)              
						
							SA1->A1_DTULTRE	:= SA1->A1_DTULTRE	
							
							MsUnlock()
					   	ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"7- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
				    ENDIF
				ENDIF           
			    
		        TRI->(DBSKIP())
			ENDDO
			TRI->(dbCloseArea())    
		
			TRH->(DBSKIP())
		ENDDO
		TRH->(dbCloseArea())
		
		//ConOut("ADFIN002P - CalcDtUltComp - SAI NA STATIC FUNCTION CalcDtUltComp" + '||' + DTOC(DATE()) + '||' + TIME())
		
RETURN(NIL)                  

STATIC FUNCTION CalcDtPenComp()

	Local cArq
	Local nHdl4
	Local nTamArq
	Local nTamLin
	Local nBytesLidos
	Local cLinha
	Local cTexto
	Local cEOL   
	Local cIdentific   := ''
	Local cCnpj        := ''
	Local cDtMaiorAcum := ''
	Local cDtPenulCom  := '' 
	Local cDtUltCom    := ''
	Local nVlMaiorAcum := ''
	//Local nCont        := 0 
	//Local lCont        := .F.
	
	//ConOut("ADFIN002P - CalcDtPenComp - ENTREI NA STATIC FUNCTION CalcDtPenComp ||" + '||' + DTOC(DATE()) + '||' + TIME())
	
	// Se for especificado o drive no caminha do arquivo, sera procurado no
	// Client, caso contrario sera procurado no Server, no diretorio RooPath.
	cArq := ('SYSTEM\' + 'cisp\' + DTOS(DATE()-1)     + '_CISP.txt')
	
	// Veja no arquivo FILEIO.CH os codigos de acesso e compartilhamento.
	nHdl4 := FOpen(cArq, 64)
	
	// Caracteres de final de linha.
	cEOL := Chr(13)+Chr(10)
	
	If nHdl4 == -1
		cMetodo   := 'Não gerou a validacao da penultima compra'
		nId       := 3
		cmensagem := "O Arquivo de nome " + AllTrim(cArq) + " nao pode ser aberto verifique se ele existe...ERRO(5)"
		 
		EmailMaiorAcum(cMetodo,nId,cmensagem)
		
		cMetodo   := ''
		cmensagem := ''
		
		fClose(nHdl4)
		
		Return(Nil)
	EndIf
	
	nTamArq := FSeek(nHdl4, 0, 2)                 // Posiciona o ponteiro no final do arquivo.
	FSeek(nHdl4, 0, 0)                            // Volta o ponteiro para o inicio do arquivo.
	nTamLin     := 280 + Len(cEOL)                // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
	cLinha      := Space(nTamLin)                 // Variavel que contera a linha lida.
	nBytesLidos := FRead(nHdl4, @cLinha, nTamLin) // Le uma linha.
	cTexto      := ""
	
	While nBytesLidos > 1
	      
	    cIdentific   := Substr(cLinha, 001, 001)
	    cCnpj        := Substr(cLinha, 018, 008)
	    cDtMaiorAcum := Substr(cLinha, 065, 008)
	    cDtUltCom    := Substr(cLinha, 042, 008)
	    cDtPenulCom  := Substr(cLinha, 214, 008)
	    nVlMaiorAcum := VAL(Substr(cLinha, 073, 013))
	    
	    IF cIdentific == '1'        
	    
	    	//CARREGA TODOS OS COD E LOJA DO CNPJ INFORMADO
    		SqlCGCCODCLI(cCnpj)
	    	While TRI->(!EOF())    
	    	
	    	    DBSELECTAREA("SA1")
	    	    SA1->(DBGOTOP())
				SA1->(DbSetOrder(1))
				
				IF SA1->(DbSeek(xFilial("SA1")+TRI->A1_COD+TRI->A1_LOJA, .T.))
				
					//ConOut("ADFIN002P - CalcDtPenComp - Dentro do WHILE TRI ||" + TRI->A1_COD+TRI->A1_LOJA + '||' + DTOC(DATE()) + '||' + TIME())
				
				    IF EMPTY(SA1->A1_XDTPENU)             .AND. ;
				       cDtPenulCom     <> '00000000'      .AND. ;
				       STOD(cDtUltCom) == SA1->A1_DTULTRE .AND. ;
				       STOD(cDtUltCom)  > STOD(cDtPenulCom)
				    
				    	if RecLock("SA1",.F.)              
						
							SA1->A1_XDTPENU	:= STOD(cDtPenulCom)	//GRAVA DT ULT COMPRA DA REDE				
							
							MsUnlock() 
						ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"7- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
                    
                    ELSEIF SA1->A1_DTULTRE > STOD(cDtUltCom) .AND. !EMPTY(SA1->A1_XDTPENU)                // se a data da ultima compra salva no banco de dados for maior do que a ultima data da ultima compra do arquivo então
				   		if RecLock("SA1",.F.)              
						
							SA1->A1_XDTPENU	:= STOD(cDtUltCom)	//GRAVA DT PENULTIMA COMPRA DA REDE COMO SENDO A EX ULTIMA DATA, ASSUMINDO ASSIM A ULTIMA COMPRA ANTERIOR				
							
							MsUnlock()
						ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"8- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
						
					ELSE	      
					
						if RecLock("SA1",.F.)              
						
							SA1->A1_XDTPENU	:= SA1->A1_XDTPENU
							
							MsUnlock()
					   	ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"9- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
				    ENDIF
				ENDIF           
			    
		        TRI->(DBSKIP())
			ENDDO
			TRI->(dbCloseArea())    
	    ENDIF //CIDENTIFIC == '1'	
	
	   
	   cIdentific   := ''
	   cCnpj        := ''
	   cDtMaiorAcum := '' 
	   cDtPenulCom  := ''
	   cDtUltCom    := ''
	   nVlMaiorAcum := 0
	   nBytesLidos  := FRead(nHdl4, @cLinha, nTamLin)
	
	EndDO
    //MSGINFO("Total de CNPJ " + cvaltochar(nCont), "Arquivo importado com sucesso")
	FClose(nHdl4)           
	// Em casos que o cliente não tiver penúltima compra a última compra é gravada no campo.
	// ** inicio gravar informacao da penultima compra da rede que estiver em branco** //
	SqlTotPenultim() //CARREGA TODOS OS CNPJ
    While TRK->(!EOF())        
    
        //CARREGA TODOS OS COD E LOJA DO CNPJ INFORMADO
    	SqlAchaPenultima(TRK->A1_XCGC)
    	While TRL->(!EOF())    
    	
    	    DBSELECTAREA("SA1")
			DbSetOrder(1)
			
			IF SA1->(DbSeek(xFilial("SA1")+TRL->A1_COD+TRL->A1_LOJA, .T.))
			
				//ConOut("ADFIN002P - CalcDtPenComp - Dentro do WHILE TRL ||" + TRL->A1_COD+TRL->A1_LOJA + '||' + DTOC(DATE()) + '||' + TIME())
			
			    IF EMPTY(SA1->A1_XDTPENU)
			    
			    	if RecLock("SA1",.F.)              
					
						SA1->A1_XDTPENU	:= STOD(TRK->E1_DTPENULTIMA)	//GRAVA DT ULT COMPRA DA REDE				
						
						MsUnlock() 
                    ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"10- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
						endif
                ELSE	      
				
					if RecLock("SA1",.F.)              
					
						SA1->A1_XDTPENU	:= SA1->A1_XDTPENU	
						
						MsUnlock()
				    ELSE
							u_GrLogZBE (Date(),TIME(),cUserName," CISP ","FINANCEIRO","ADFIN002P",;
										"11- CLIENTE: "+SA1->A1_COD+" LOJA: " +SA1->A1_LOJA+ " CGC: " +SA1->A1_CGC+ "- Não foi possível executar o reclock no cadastro do cliente.",;
										ComputerName(),LogUserName())
					endif
			    ENDIF

				SA1->(DBCLOSEAREA())
	        ENDIF           
		    
	        TRL->(DBSKIP())
		ENDDO
		TRL->(dbCloseArea())    
	
		TRK->(DBSKIP())
	ENDDO
	TRK->(dbCloseArea())
	// ** final gravar informacao da penultima compra da rede que estiver em branco** //
	
	//ConOut("ADFIN002P - CalcDtPenComp - SAI NA STATIC FUNCTION CalcDtPenComp" + '||' + DTOC(DATE()) + '||' + TIME())
    
RETURN(NIL)    

STATIC FUNCTION CalcXCGC()

	Local cQuery  := ''
	Local cQuery1 := ''
	
	//ConOut("ADFIN002P - CalcXCGC - ENTREI NA STATIC FUNCTION CalcXCGC" + '||' + DTOC(DATE()) + '||' + TIME())

	// ******************** inicio gravar informacao do cgc da rede no cliente ************ //
	
	cQuery := " UPDATE "+RetSqlName("SA1")+ " "
	cQuery += " SET A1_XCGC = LEFT(A1_CGC,8) "		
	cQuery += " WHERE A1_XCGC     = '' "
    cQuery += "   AND A1_EST     <> 'EX' "
    cQuery += "   AND  A1_PESSOA  = 'J' "
    
	TCSQLExec(cQuery)
	
	//ConOut("ADFIN002P - CalcXCGC - PASSEI PELO UPDATE DA SA1 ||" + cQuery + '||' + DTOC(DATE()) + '||' + TIME())   
	
	// ********************* final gravar informacao do cgc da rede no cliente ************ //
	
	// ********************* inicio gravar informacao do cgc da rede no contas a receber  ************ //
	
	cQuery1 := " UPDATE "+RetSqlName("SE1")+ " "
	cQuery1 += " SET E1_XCGC = LEFT(A1_CGC,8) FROM "+RetSqlName("SE1")+ " "		
	cQuery1 += " INNER JOIN "+RetSqlName("SA1")+ " "
    cQuery1 += "   ON  E1_CLIENTE  = A1_COD "
    cQuery1 += "   AND  E1_LOJA    = A1_LOJA "    
    cQuery1 += "   AND  A1_EST    <> 'EX' "
    cQuery1 += "   AND  A1_PESSOA  = 'J' "    
    cQuery1 += "   WHERE E1_XCGC   = '' "
    
	TCSQLExec(cQuery1)
	
	//ConOut("ADFIN002P - CalcXCGC - PASSEI PELO UPDATE DA SE1 ||"+ cQuery1 + '||' + DTOC(DATE()) + '||' + TIME())
	//ConOut("ADFIN002P - CalcXCGC - SAI NA STATIC FUNCTION CalcXCGC" + '||' + DTOC(DATE()) + '||' + TIME())   
	
	// ********************* final gravar informacao do cgc da rede no contas a receber ************ //

		
RETURN(NIL)

STATIC FUNCTION EmailMaiorAcum(cMetodo,nId,cmensagem)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#USUMAI"))
	//Local cTo		   := "leonardo.monteiro@adoro.com.br"
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    //Local _cPedido     := ""
    //Local _cStatEml    := ""
    
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
	   cSubject := "EMAIL GERACAO MAIOR ACUMULO"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    // ********************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL)   


Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	//Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>MAIOR ACUMULO............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
 	IF  nId == 1 // Autenticacao ok
 	
	   cRet += " Inicio da Geracao do Maior Acumulo"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem
	
		
	ENDIF	
	
	IF nId == 2      // Autenticacao com erro
 	
	   cRet += " Final da Geracao do Maior Acumulo"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += cmensagem

	ENDIF     
	
	IF nId == 3      // Autenticacao com erro
 	
	   cRet += " Erro na validação da data da penultima compra"
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

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	//ConOut("ADFIN002P - logZBN - ENTREI NA STATIC FUNCTION logZBN" + '||' + DTOC(DATE()) + '||' + TIME())
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN002P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN002P'
			ZBN_DESCRI  := 'Gerar Data de Maior e Valor do Acumulo'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '13:30:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '13:30:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN002P'
			ZBN_DESCRI  := 'Gerar Data de Maior e Valor do Acumulo'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '13:30:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '13:30:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
	
	//ConOut("ADFIN002P - logZBN - SAI NA STATIC FUNCTION logZBN" + '||' + DTOC(DATE()) + '||' + TIME())
		
	RestArea(aArea)

Return Nil

Static Function SqlContaCliente()

	BeginSQL Alias "TRA"
			%NoPARSER%  
			SELECT   COUNT(SA1.A1_COD) AS CONT 
			   FROM  %Table:SA1% SA1 WITH(NOLOCK)
			   WHERE A1_DTACUMU <> ''
			     AND D_E_L_E_T_ <> '*' 
			   
	EndSQl             
RETURN(NIL)

Static Function SqlCliente()

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT A1_COD,
			       A1_LOJA,
			       A1_NOME, 
			       A1_DTACUMU, 
			       A1_VLACUMU, 
			       RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND D_E_L_E_T_ <> '*'                 
			   			   
			 ORDER BY A1_CGC
			    
	EndSQl             
RETURN(NIL) 

Static Function SqlReceber()

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT (CASE WHEN SE1.E1_TIPO = 'AB-' THEN (SE1.E1_VALOR*-1) ELSE (SE1.E1_VALOR*1) END) AS E1_VALOR,
				   //SE1.E1_VALOR,
			       SE1.E1_EMISSAO,
			       SE1.E1_FILIAL,
			       SE1.E1_PREFIXO,
			       SE1.E1_NUM,
			       SE1.E1_PARCELA,
			       SE1.E1_TIPO,
			       SE1.E1_CLIENTE,
			       SE1.E1_LOJA,
				   SE1.R_E_C_N_O_ REGISTRO
			FROM %Table:SE1% SE1 WITH(NOLOCK)
			WHERE SE1.E1_CLIENTE  = %EXP:cCliente%
			   AND SE1.E1_LOJA    = %EXP:cLoja%
			   AND SE1.E1_EMISSAO > %EXP:cData%
			   AND SE1.E1_TIPO IN ('NF','AB-') 
			   AND SE1.D_E_L_E_T_ <> '*'
			   //AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND LEFT(SE1.E1_PORTADO,1) != 'P'
			ORDER BY E1_EMISSAO,E1_VALOR
	EndSQl             
RETURN(NIL)

Static Function SqlPagar()

	BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT E5_VLMOED2,
			       E5_DATA,
			       E5_TIPODOC,
			       E5_HISTOR,
			       E5_CLIENTE, 
			       E5_LOJA
			  FROM %Table:SE5% SE5 WITH(NOLOCK), %Table:SE1% SE1 WITH(NOLOCK)
			 WHERE SE5.E5_FILIAL   = %EXP:cFil%
			   AND SE5.E5_PREFIXO  = %EXP:cPrefixo%
			   AND SE5.E5_NUMERO   = %EXP:cNum%
			   AND SE5.E5_PARCELA  = %EXP:cParcela%
			   AND SE5.E5_TIPO     = %EXP:cTipo%
			   AND SE5.E5_CLIFOR   = %EXP:cCliente%
			   AND SE5.E5_LOJA     = %EXP:cLoja%
			   AND SE5.D_E_L_E_T_ <> '*'
			   AND SE5.E5_RECPAG   = 'R'
			   AND SE5.E5_FILIAL   = SE1.E1_FILIAL
			   AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO
			   AND SE5.E5_NUMERO   = SE1.E1_NUM
			   AND SE5.E5_PARCELA  = SE1.E1_PARCELA
			   AND SE5.E5_TIPO     = SE1.E1_TIPO
			   //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND LEFT(SE1.E1_PORTADO,1) != 'P'
			   AND SE1.D_E_L_E_T_ <> '*' 
			   
	EndSQl             
	
RETURN(NIL)	

Static Function SqlCliAnoAtual()

	BeginSQL Alias "TRE"
			%NoPARSER%  
			SELECT SE1.E1_CLIENTE, 
			       SE1.E1_LOJA, 
			       RTRIM((LEFT(SA1.A1_CGC,8))) AS A1_CGC 
			  FROM %Table:SE1% SE1 WITH(NOLOCK), %Table:SA1% SA1 WITH(NOLOCK)
			 WHERE SE1.E1_EMISSAO >= CONVERT(VARCHAR(4),(YEAR(GETDATE()) -1)) + CASE WHEN LEN(MONTH(GETDATE())) = 1 then '0' + CONVERT(VARCHAR(2),(MONTH(GETDATE())))  else CONVERT(VARCHAR(2),(MONTH(GETDATE()))) END + '01'
			   AND SE1.E1_TIPO     = 'NF' 
			   AND SE1.D_E_L_E_T_ <> '*' 
               //AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND LEFT(SE1.E1_PORTADO,1) != 'P'
			   AND SE1.E1_CLIENTE  = SA1.A1_COD
			   AND SE1.E1_LOJA     = SA1.A1_LOJA
			   AND RTRIM((LEFT(SA1.A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(SA1.A1_CGC,8))) <> '' 
			   AND SA1.D_E_L_E_T_ <> '*'           
			   //Debugar a rotina.
			   //AND A1_XCGC='47508411'
			 GROUP BY E1_CLIENTE, E1_LOJA, SA1.A1_CGC 
			 
			 ORDER BY SA1.A1_CGC 
			   
	EndSQl             
	
RETURN(NIL)	

Static Function SqlEstorno()

	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT E5_VLMOED2,
			       E5_DATA,
			       E5_TIPODOC,
			       E5_HISTOR,
			       E5_CLIENTE,
			       E5_LOJA
			  FROM %Table:SE5% SE5 WITH(NOLOCK), %Table:SE1% SE1 WITH(NOLOCK)
			 WHERE SE5.E5_FILIAL   = %EXP:cFil%
			   AND SE5.E5_PREFIXO  = %EXP:cPrefixo%
			   AND SE5.E5_NUMERO   = %EXP:cNum%
			   AND SE5.E5_PARCELA  = %EXP:cParcela%
			   AND SE5.E5_TIPO     = %EXP:cTipo% 
			   AND SE5.E5_CLIFOR   = %EXP:cCliente%
			   AND SE5.E5_LOJA     = %EXP:cLoja%
			   AND SE5.D_E_L_E_T_ <> '*'
			   AND SE5.E5_RECPAG   = 'P'  
			   AND (SE5.E5_TIPODOC = 'E2'  
			    OR  SE5.E5_TIPODOC = 'ES')
			   AND SE5.E5_FILIAL   = SE1.E1_FILIAL
			   AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO
			   AND SE5.E5_NUMERO   = SE1.E1_NUM
			   AND SE5.E5_PARCELA  = SE1.E1_PARCELA
			   AND SE5.E5_TIPO     = SE1.E1_TIPO
			   //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND LEFT(SE1.E1_PORTADO,1) != 'P'
			   AND SE1.D_E_L_E_T_ <> '*'     
			   
	EndSQl             
	
RETURN(NIL)	

Static Function SqlCliCgc()

	BeginSQL Alias "TRG"
			%NoPARSER%  
			SELECT A1_COD,
			       A1_LOJA,
			       A1_NOME, 
			       A1_DTACUMU, 
			       A1_VLACUMU, 
			       A1_XDTPENU,
			       RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCgcOld%
			   AND D_E_L_E_T_ <> '*'          

             ORDER BY A1_CGC
			    
	EndSQl             
RETURN(NIL)  


Static Function SqlTOTCGC()

	BeginSQL Alias "TRH"
			%NoPARSER% 
			SELECT  A1_DTACUMU, 
					A1_VLACUMU,
					MAX(A1_DTULTRE) AS A1_DTULTRE, 
					MAX(A1_ULTCOM)  AS A1_ULTCOM,
					MAX(E1_EMISSAO) AS E1_EMISSAO, 
					RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
				FROM %Table:SA1% WITH(NOLOCK),%Table:SE1% WITH(NOLOCK) 
				WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
				  AND RTRIM((LEFT(A1_CGC,8))) <> '' 
				  AND A1_ULTCOM               <> ''
				  AND %Table:SA1%.D_E_L_E_T_       <> '*' 
				  AND A1_XCGC                  = E1_XCGC 
				  AND E1_TIPO                  = 'NF'  
				  //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
				  //AND SE1010.D_E_L_E_T_       <> '*'  
				  //Debugar a rotina.
				  //AND A1_XCGC='47508411'
				GROUP BY A1_DTACUMU,A1_VLACUMU,LEFT(A1_CGC,8)
			
				ORDER BY A1_CGC
	 
	EndSQl             
RETURN(NIL)               	

STATIC FUNCTION SqlCGCCODCLI(cCnpjnew)

	BeginSQL Alias "TRI"
			%NoPARSER% 
			SELECT A1_COD,
			       A1_LOJA,
			       A1_NOME, 
			       A1_DTACUMU, 
			       A1_VLACUMU,
			       A1_XDTPENU, 
			       RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			  FROM %Table:SA1% WITH(NOLOCK)  
			 WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
			   AND RTRIM((LEFT(A1_CGC,8))) <> '' 
			   AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpjnew%
			   AND D_E_L_E_T_ <> '*'                  
			   
             ORDER BY A1_CGC
	 
	EndSQl             
RETURN(NIL)     

STATIC FUNCTION SqlVerifSaldo(cCnpjnew2)

	BeginSQL Alias "TRJ"
			%NoPARSER% 
			SELECT A1_DTACUMU,
			       A1_VLACUMU,
			       A1_DTULTRE,
				   A1_ULTCOM,  
				   SUM(E1_SALDO) AS E1_SALDO, 
				   SUM(E1_VALOR) AS E1_VALOR, 
				   MAX(E1_NUM) AS E1_NUM
			  FROM %Table:SA1% WITH(NOLOCK), %Table:SE1% WITH(NOLOCK)
			WHERE LEFT(A1_CGC,8)          = %EXP:cCnpjnew2%
			  AND A1_COD                  = E1_CLIENTE
			  AND A1_LOJA                 = E1_LOJA
			  AND %Table:SA1%.D_E_L_E_T_ <> '*'
			  AND %Table:SE1%.D_E_L_E_T_ <> '*' 
			  //AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			  AND LEFT(%Table:SE1%.E1_PORTADO,1) != 'P'
			  AND E1_TIPO = 'NF' 
			
			GROUP BY A1_DTACUMU,A1_DTULTRE,A1_ULTCOM, A1_VLACUMU
			
	EndSQl             
RETURN(NIL)     

STATIC FUNCTION SqlTotPenultim()

	BeginSQL Alias "TRK"
			%NoPARSER% 
			SELECT A1_XCGC,
			       A1_XDTPENU,
				   MAX(E1B.E1_EMISSAO) AS E1_DTPENULTIMA 
			FROM %Table:SA1% WITH(NOLOCK),%Table:SE1% E1B WITH(NOLOCK) 
			WHERE A1_XDTPENU         = ''
			  AND A1_DTULTRE        <> ''
			  AND A1_DTULTRE        >= GETDATE()-365
			  AND A1_XCGC           <> ''
			  AND %Table:SA1%.D_E_L_E_T_ <> '*'
			  AND E1B.E1_TIPO        = 'NF' 
			  AND E1B.E1_XCGC        = A1_XCGC 
			  AND E1B.E1_EMISSAO    <> A1_DTULTRE
			  AND A1_VEND           <> '000442'
			
			  GROUP BY A1_XCGC,A1_XDTPENU
			  ORDER BY A1_XCGC
			
	EndSQl             
RETURN(NIL)     

STATIC FUNCTION SqlAchaPenultima(cCnpjnew3)

	BeginSQL Alias "TRL"
			%NoPARSER%
			SELECT A1_XCGC,
			       A1_COD, 
				   A1_LOJA,
				   A1_DTULTRE, 
				   A1_XDTPENU
			FROM %Table:SA1% WITH(NOLOCK)
			WHERE A1_XDTPENU         = ''
			  AND A1_DTULTRE        <> ''
			  AND A1_DTULTRE        >= GETDATE()-365
			  AND A1_XCGC           <> ''
			  AND %Table:SA1%.D_E_L_E_T_ <> '*'
			  AND A1_VEND           <> '000442'
			  AND A1_XCGC            = %EXP:cCnpjnew3%
			
			  GROUP BY A1_XCGC, A1_COD, A1_LOJA, A1_DTULTRE, A1_XDTPENU
			  ORDER BY A1_XCGC
    EndSQl             
RETURN(NIL)     
