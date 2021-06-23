#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.CH'  
#INCLUDE "rwmake.ch"    
#INCLUDE "TBICONN.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADFIN052P ºAutor  ³WILLIAM COSTA       º Data ³  02/02/2018 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Funcao para gerar a data de acumulo e o valor do maior acumuº±±
//±±º          ³lo do envio para a Tabela SZF para o fincanceiro liberar    º±±
//±±º          ³corretamente pedidos de venda. Fonte chamado de ADLCRED2.PRWº±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAFIN                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
              
USER FUNCTION ADFIN052P(cRedePrincipal)
    
    Private cCliente    := ''
    Private cLoja       := ''
	Private cData       := ''
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
	Private cDtUltComp  := ''
	Private lAcumulo    := .F.
	Private cDataIni    := '' 
	Private cDtAcum     := ''
	Private nVlAcum     := 0   
	Private nVlSaldo    := 0
	Private cCodRedOld  := ''
	Private cCodRed     := ''
	Private cArq        := ''
	Private nHdl        := ''
	Private cLinha      := ''
	Private cValor      := 0
	Private cData       := '' 
	Private cMetodo     := ''
	Private nId         := 0 
	Private cMensagem   := ''
	
	ConOut("INICIO DO SCHEDULE ADFIN052P" + '||' + DTOC(DATE()) + '||' + TIME()) 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao para gerar a data de acumulo e o valor do maior acumulo do envio para a Tabela SZF para o fincanceiro liberar corretamente pedidos de venda. Fonte chamado de ADLCRED2.PRW')
	
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	
	cMetodo   := 'INICIANDO MAIOR ACUMULO SZF...'
	nId       := 1
	cmensagem := 'Iniciando o calculo do maior acumulo SZF...'
	 
	cMetodo   := ''
	nId       := 0
	cmensagem := ''
			        
    GeraAcumPrimeiraVez(cRedePrincipal)
    	                  
	//depois que rodou todos roda pela ultima vez
	GravarAcumulo()
    aCloneAcum := {}
	aAcumulo   := {} 
	aRecAux    := {}
	cCodRedOld := cCodRed
	    				    
	cMetodo   := 'FINAL DO CALCULO DO MAIOR ACUMULO SZF...'
	nId       := 2
	cmensagem := 'Terminou o calculo do maior acumulo.'
	 
	cMetodo   := ''
	nId       := 0
	cmensagem := ''
		
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	
	ConOut("FINAL DO SCHEDULE ADFIN052P" + '||' + DTOC(DATE()) + '||' + TIME())
	
RETURN(NIL) 	  
	
STATIC FUNCTION GeraAcumPrimeiraVez(cRedePrincipal)	
		
	//informacoes will
	// posicoes a aAcumulo
    // 1-)data do titulo
    // 2-)valor do titulo 
    // 3-)Campo verificador pode ser SE1 OU SE5  se for SE1 e o titulo a receber 
    //    SE5 e o titulo baixado
    // 4-)valores de saldos 
    // 5-)Tipo de Documento
    
    // **************************** inicio carrega vetor aAcumulo **************************** //
	SqlCliente(cRedePrincipal)
	
	cCodRedOld := TRB->A1_CODRED
	
	While TRB->(!EOF())     
	
		CalculaMaiorAcumulo(TRB->A1_COD,TRB->A1_LOJA,TRB->A1_CODRED)

		TRB->(dbSkip()) 
    	
	ENDDO
	TRB->(dbCloseArea()) 
	// **************************** final carrega vetor aAcumulo **************************** //
	
RETURN(NIL) 

Static Function CalculaMaiorAcumulo(cCli,cLoj,cRede)  

	cCliente    := cCli
    cLoja       := cLoj
    cCodRed     := cRede
    cData       := '00010101' 
  	aReceber    := {}
  	aTitBaixado := {}
  	
  	IF cCodRed <>  cCodRedOld
    
	    GravarAcumulo()
	    aCloneAcum := {}
    	aAcumulo   := {}
    	aRecAux    := {}
    	cCodRedOld := cCodRed  
    	
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
	
RETURN(NIL)

Static Function GravarAcumulo()
    
	IF LEN(aAcumulo) > 0
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
		FOR nCont := 1 TO LEN(aAcumulo)
		
			IF aAcumulo[nCont][3] == 'SE1'
			
				nSaldo := nSaldo + aAcumulo[nCont][2]
				
			ELSEIF aAcumulo[nCont][3]  == 'SE5' .AND. ;
			       (aAcumulo[nCont][5] == 'ES' .OR.  ;
			        aAcumulo[nCont][5] == 'E2')//CANCELAMENTO SOMA DINOVO
			
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
		SqlRedeSZF()
	    While TRG->(!EOF())
	    
	    	DBSELECTAREA("SZF")
	    	SZF->(DBORDERNICKNAME("SZF_3"))   
			
			IF SZF->(DbSeek(xFilial("SZF")+TRG->ZF_REDE, .T.))
			
				While SZF->(!EOF()) .AND. SZF->ZF_REDE == TRG->ZF_REDE
			
					IF EMPTY(SZF->ZF_DTACUMU) .AND. SZF->ZF_VLACUMU  <= 0 .AND. nVlAcum <= 0
					
						RecLock("SZF",.F.)              
						
							SZF->ZF_DTACUMU	:= IIF(STOD(cDtAcum) < SZF->ZF_DTACUMU,SZF->ZF_DTACUMU, STOD(cDtAcum))
							SZF->ZF_VLACUMU	:= 0
			
						MsUnlock()
					   
				    ELSEIF !EMPTY(SZF->ZF_DTACUMU) .AND. ;
				            SZF->ZF_DTACUMU   < STOD(cDtAcum) .AND. ; 
				            (SZF->ZF_VLACUMU  < nVlAcum .OR. ;
				            SZF->ZF_DTACUMU   < CTOD(STRZERO(DAY(DATE()),02) + '/' + IIF(LEN(CVALTOCHAR(MONTH(DATE()))) == 1, '0' + CVALTOCHAR(MONTH(DATE())),CVALTOCHAR(MONTH(DATE())))+'/' + CVALTOCHAR(YEAR(DATE())- 1)))
			                                 
			            RecLock("SZF",.F.)              
						
							SZF->ZF_DTACUMU	:= IIF(STOD(cDtAcum) < SZF->ZF_DTACUMU,SZF->ZF_DTACUMU, STOD(cDtAcum))
							SZF->ZF_VLACUMU	:= nVlAcum 
			
						MsUnlock() 
						
				    ELSEIF SZF->ZF_VLACUMU <= 0 .AND. ;
				           nVlAcum         >= 0 .AND. ;
				           SZF->ZF_DTACUMU >= STOD(cDtAcum)
				           
				        RecLock("SZF",.F.)              
						
							SZF->ZF_DTACUMU	:= IIF(STOD(cDtAcum) < SZF->ZF_DTACUMU,SZF->ZF_DTACUMU, STOD(cDtAcum))
							SZF->ZF_VLACUMU	:= IIF(nVlAcum < SZF->ZF_VLACUMU,SZF->ZF_VLACUMU, nVlAcum)
			
						MsUnlock()		
						
					ELSEIF !EMPTY(SZF->ZF_DTACUMU) .AND. ;
				           !EMPTY(SZF->ZF_VLACUMU)     .AND. ;
					       SZF->ZF_DTACUMU < STOD(cDtAcum) .AND. ;
				           nVlAcum         > 0
				           
				        //verifica a soma do saldo e a soma do valor do titulo
				        nVlSaldo   := 0   
				        cDtUltComp := ''
				        SqlVerifSaldo(SZF->ZF_REDE)   
				        While TRJ->(!EOF())
				        
				            nVlSaldo   := nVlSaldo + TRJ->E1_SALDO
				            
				            IF ALLTRIM(cDtUltComp) = ''
				            
				            	cDtUltComp := TRJ->A1_DTULTRE
				            	
				            ELSE 
				            
				            	cDtUltComp := IIF(STOD(cDtUltComp) < STOD(TRJ->A1_DTULTRE),TRJ->A1_DTULTRE, cDtUltComp)
				            	
				            ENDIF	
				            			
						TRJ->(DBSKIP())
						ENDDO
						TRJ->(dbCloseArea())
						
						IF ROUND(nVlSaldo,0) >= ROUND(nVlAcum,0)
				            
					   		RecLock("SZF",.F.)              
							
								SZF->ZF_DTACUMU	:= STOD(cDtUltComp)					
								SZF->ZF_VLACUMU	:= nVlSaldo
				
							MsUnlock()
							 
						ENDIF
						
				    ELSEIF EMPTY(SZF->ZF_DTACUMU) .AND. ;
				           EMPTY(SZF->ZF_VLACUMU) .AND. ;
				           !EMPTY(cDtAcum)        .AND. ;
				           nVlAcum > 0
				         
				        RecLock("SZF",.F.)              
						
						    SZF->ZF_DTACUMU	:= STOD(cDtAcum)
							SZF->ZF_VLACUMU	:= nVlAcum
			
						MsUnlock()  
				               
				    ELSE   		
				   
				    	RecLock("SZF",.F.)              
						
						    SZF->ZF_DTACUMU	:= SZF->ZF_DTACUMU
							SZF->ZF_VLACUMU	:= SZF->ZF_VLACUMU
			
						MsUnlock()
						
				    ENDIF
			    	SZF->(dbSkip())
				ENDDO
				SZF->(dbCloseArea())
				 
	        ENDIF
		    
			TRG->(DBSKIP())
		ENDDO
		TRG->(dbCloseArea())
    ENDIF
    
RETURN(NIL) 

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN052P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN052P'
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
			ZBN_ROTINA	:= 'ADFIN052P'
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
	
	RestArea(aArea)

Return Nil

Static Function SqlCliente(cRedePrincipal)

	BeginSQL Alias "TRB"
			%NoPARSER% 
			 SELECT A1_CODRED,
			        A1_COD,
					A1_LOJA,
					A1_NOME, 
					RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
			   FROM %Table:SA1% WITH(NOLOCK)  
			  WHERE A1_CODRED  <> '' 
			    AND A1_CODRED = %EXP:cRedePrincipal%
			    AND D_E_L_E_T_ <> '*'                 
					   			   
			ORDER BY A1_CODRED
			    
	EndSQl             
RETURN(NIL) 

Static Function SqlReceber()

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT SE1.E1_VALOR,
			       SE1.E1_EMISSAO,
			       SE1.E1_FILIAL,
			       SE1.E1_PREFIXO,
			       SE1.E1_NUM,
			       SE1.E1_PARCELA,
			       SE1.E1_TIPO,
			       SE1.E1_CLIENTE,
			       SE1.E1_LOJA
			  FROM %Table:SE1% SE1 WITH(NOLOCK)
			 WHERE SE1.E1_CLIENTE  = %EXP:cCliente%
			   AND SE1.E1_LOJA     = %EXP:cLoja%
			   AND SE1.E1_EMISSAO  > %EXP:cData%
			   AND SE1.E1_TIPO     = 'NF' 
			   AND SE1.D_E_L_E_T_ <> '*'
			   AND SE1.E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
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
			   AND SE5.E5_TIPODOC <> 'JR'  
			   AND SE5.D_E_L_E_T_ <> '*'
			   AND SE5.E5_RECPAG   = 'R'
			   AND SE5.E5_FILIAL   = SE1.E1_FILIAL
			   AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO
			   AND SE5.E5_NUMERO   = SE1.E1_NUM
			   AND SE5.E5_PARCELA  = SE1.E1_PARCELA
			   AND SE5.E5_TIPO     = SE1.E1_TIPO
			   AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND SE1.D_E_L_E_T_ <> '*' 
			   
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
			   AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			   AND SE1.D_E_L_E_T_ <> '*'     
			   
	EndSQl             
	
RETURN(NIL)	

Static Function SqlRedeSZF()

	BeginSQL Alias "TRG"
			%NoPARSER%  
			 SELECT ZF_REDE,
					ZF_NOMERED, 
					ZF_DTACUMU, 
					ZF_VLACUMU 
				FROM %Table:SZF% WITH(NOLOCK)  
				WHERE ZF_REDE  <> '' 
				AND ZF_REDE     = %EXP:cCodRedOld%
				AND D_E_L_E_T_ <> '*'          
			
			    ORDER BY ZF_REDE
						    
	EndSQl             
RETURN(NIL)  

STATIC FUNCTION SqlVerifSaldo(cCodRede2)

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
			WHERE A1_CODRED               = %EXP:cCodRede2%
			  AND A1_COD                  = E1_CLIENTE
			  AND A1_LOJA                 = E1_LOJA
			  AND %Table:SA1%.D_E_L_E_T_ <> '*'
			  AND %Table:SE1%.D_E_L_E_T_ <> '*' 
			  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14')
			  AND E1_TIPO                 = 'NF' 
			
			GROUP BY A1_DTACUMU,A1_DTULTRE,A1_ULTCOM, A1_VLACUMU
			
	EndSQl             
RETURN(NIL)