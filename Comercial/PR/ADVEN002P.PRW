#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                    
#include "AP5MAIL.CH"   

/*{Protheus.doc} User Function ADVEN002P
	Programa importador do txt EDI para todos os clientes usando schedules 
	@type  Function
	@author WILLIAM COSTA
	@since 02/06/2016
	@version 01
	@history Chamado TI     - William Costa - Sem Data - Alterado para o Sql da Tes inteligente trazer somente 1 registro devido a produtos com codigo EAN iguais 
	@history Chamado 050848 - William Costa - 06/08/2019 - Identificado que quando tem mais de um vendedor o email para o segundo vendedor em diante ia com um monte de espaços em branco identificado no For que gera email que o if para pular linha estava fora da regra de identificar o vendedor
	@history Chamado 052429 - William Costa - 16/12/2020 - Adicionado um .OR. na unidade de medida  'EA' para entrar também quando for caixa, para fazer o cálculo corretamente.
	@history Ticket  5055   - William Costa - 10/12/2020 - Identificado que tem alguns produtos que não tem TES INTELIGENTE, mas se o cliente é de São Paulo, pode usar como cadastro a TES padrão do Produto, então foi feito uma tratativa para quando o cliente é de São Paulo não usar a TES inteligente se ela retornar em branco e ir buscar no cadastro de produto a TES.
	@history Ticket  9117   - Leonardo P. Monteiro - 05/02/2021 - Criação de parâmetro para limitação da quantidade de arquivos processados por execução de agendamento.
	@history Ticket  9117   - Leonardo P. Monteiro - 10/02/2021 - Inclusão do meu email para monitoramento.
	@history Ticket 12379   - Leonardo P. Monteiro - 14/04/2021 - Correção no preenchimento dos emails dos vendedores quando há erros na integração do EDI.
	@history Ticket 12379   - Leonardo P. Monteiro - 15/04/2021 - Tratamento do EDI para evitar a inclusão de pedidos em duplicidade. Isso evita erros na importação de arquivos.
	@history Ticket 12379   - Leonardo P. Monteiro - 19/04/2021 - Correção nas mensagens de erros quando não há produto cadastrado.
	@history Ticket 18915   - Leonardo P. Monteiro - 26/08/2021 - Tratamento na conversão dos itens com valor 0.
*/

User Function ADVEN002P()

	Private aDirectory    := {} 
	Private nCont         := 0   
	Private nCont1        := 0  
	Private cArq          := ''
	Private cPath         := ''
	Private cChave        := ''
	Private nHdl          := NIL  
	Private cTxt          := ''
	Private nTam          := 0 
	Private nLinha        := 1
	Private aCabPv        := {}                                                                                                       
    Private aItemPv       := {}    
    Private cCnpjComp     := ''
    Private cCodCli       := ''
	Private cLojCli       := ''
	Private cVend         := ''    
	Private dEntrega      := DATE()
	Private cDiaSemana    := '' 
	Private cPedComprador := '' 
	Private cCodBar       := ''
	Private aItem         := {} 
	Private aItens        := {}
	Private nQtd          := 0
	Private nQtdConv      := 0	
	Private nQtdConv2     := 0	
	Private nVlUnit       := 0
	Private nVlTotal      := 0       
	Private cEstCli       := ''
	Private cPedido       := ''
	Private aPedidos      := {}  
    Private cMostraErro   := ''
    Private nRetValPreco  := 0 
	Private cFaixa        := ''
	Private _cSegto       := ''   &&Mauricio - 11/04/17 - preco minimo por segmento.
    Private nVlTotPed     := 0
    Private _nValmin      := 0
    Private aVend         := {}
    Private aVendedores   := {}
    Private cVendedor     := ''
    Private cSuperv       := ''
    Private nCont4        := 0
    Private cSupUsu       := ''
    Private cStatus       := '' 
    Private cUnidade      := ''
    Private cSeqPedCli    := ''  
    Private cTipoCli      := ''
    Private cCodRed       := ''
	Private lEdi          := .F.
	Private _cTipoCli     := ''
	Private EmailErro	  := ""
	//Ticket  9117   - Leonardo P. Monteiro - 05/02/2021 - Criação de parâmetro para limitação da quantidade de arquivos processados por execução de agendamento.
	Private nQtdLim		  := 0
    Private nQtdArq		  := 0
	
	//Default cEmpAnt       := '01'
	//Default cFilAnt       := '02'


	//BEGINDOC
	//01-) aItem == cCodBar         
	//02-) aItem == TRB->B1_COD     
	//03-) aItem == TRB->B1_DESC    
	//04-) aItem == nQtd            
	//05-) aItem == nQtdConv        
	//06-) aItem == nVlUnit         
	//07-) aItem == nVlTotal        
	//08-) aItem == TRB->B1_SEGUM   
	//09-) aItem == TRB->B1_UM      
	//10-) aItem == TRB->FM_TS      
	//ENDDOC  
		
	//BEGINDOC
	//01-) aPedidos == Cod Edi   
	//02-) aPedidos == Pedido Num
	//03-) aPedidos == Cliente   
	//04-) aPedidos == Dt Entrega
	//05-) aPedidos == Mensagem  
	//06-) aPedidos == Cod Vend  
	//ENDDOC

	// *************INICIO PARA RODAR COM SCHEDULE************************************* //	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// **************FINAL PARA RODAR COM SCHEDULE************************************** //	
	
	nQtdLim		  := Supergetmv("MV_#EDI001",,999999)
	EmailErro	  := Alltrim(SuperGetMv("MV_#EDI003",,"silvia@adoro.com.br;vagner.correia@adoro.com.br"))
	
	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADVEN002P", .T., .F.)
		ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	PtInternal(1,ALLTRIM(PROCNAME()))
	//ConOut("INICIO DO SCHEDULE ADVEN002P " + ALLTRIM(FUNNAME()) + ' ' + TIME())  
	ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - INICIO DO SCHEDULE ADVEN002P " + ALLTRIM(FUNNAME()) +"")
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa importador do txt EDI para todos os clientes usando schedules ')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	aDirectory 	:= DIRECTORY("\SYSTEM\edi\pedidos\*.txt")
	//Ticket  9117   - Leonardo P. Monteiro - 05/02/2021 - Criação de parâmetro para limitação da quantidade de arquivos processados por execução de agendamento.
	nQtdArq		:= len(aDirectory)
	// **************Iniciando leitura dos arquivos TXT ************************ //
	nCont:= 1
	
	//Ticket  9117   - Leonardo P. Monteiro - 05/02/2021 - Criação de parâmetro para limitação da quantidade de arquivos processados por execução de agendamento.
	//FOR nCont := 1 TO LEN(aDirectory)
	While nCont <= nQtdArq .and. nCont <=	nQtdLim

		FT_FUse( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] )   
		nTam += FT_FlastRec()
		nTam ++
		cChave := Substr(aDirectory[nCont][1],1,LEN(aDirectory[nCont][1]) - 4)
		ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Processando a chave/arquivo " + cChave +"")
		
		FT_FGoTop()   
		aItens := {}
		
		While ! ( FT_FEof() )
			cTxt :=  FT_FReadLN()    
			
			IF SUBSTR(cTxt,001,002) == "01"  
			    
				cPedComprador := Substr(cTxt,009,020)
				dEntrega      := STOD(Substr(cTxt,061,008))
				cCnpjComp     := Substr(cTxt,181,014)
				
				DbSelectArea("SA1")
				SA1->(DbSetOrder(3))
				
				IF DbSeek(xFilial("SA1")+cCnpjComp, .T.)
				
					cCodCli    := SA1->A1_COD                             
					cLojCli    := SA1->A1_LOJA 
					cVend      := SA1->A1_VEND
					cEstCli    := SA1->A1_EST
					cCodRed    := SA1->A1_CODRED
					lEdi       := SA1->A1_XEDI 
					cVendedor  := SA1->A1_VEND
					_cTipoCli  := IIF(SA1->A1_TIPO="F".and. Alltrim(SA1->A1_EST)="SP" ,"F"," ")
				
				// *** INICIO CHAMADO 037768 - William Costa - quando o cliente nao existe no protheus tem que sair do EDI *** //
				ELSE 
					
					//@history Ticket 12379   - Leonardo P. Monteiro - 14/04/2021 - Correção no preenchimento dos emails dos vendedores quando há erros na integração do EDI.
					cVendedor := ""

					if !Empty(cVendedor)	
						Aadd(aVend,{cVendedor, ;
						Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_EMAIL"), ;
						Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL")})
					elseif !Empty(EmailErro) 
						Aadd(aVend,{cVendedor, ;
						EmailErro, ;
						""})
					endif

					Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									'Cliente:' + cCnpjComp + ' Não cadastrado no Protheus, verifique !!! ' , ;
									cVendedor}) 
					


					EXIT  	    
				
				// *** FINAL CHAMADO 037768 - William Costa - quando o cliente nao existe no protheus tem que sair do EDI *** //
					
				ENDIF	
				
	    		DbCloseArea("SA1")    
				
				IF lEdi == .F. 
				
					Aadd(aVend,{cVendedor, ;
			            EmailErro,;
			            ""})
				
					Aadd(aPedidos,{cchave, ;
			                           ''    , ;
			                           ''    , ;
			                           ''    , ;
			                           'Cliente:' +cCodCli + '-' + cLojCli + ' Não Liberado para EDI, verifique o campo A1_XEDI: ' + Cvaltochar(lEdi) , ;
			                           cVendedor}) 
				
					EXIT  
						  
				ENDIF		  
	    		
	    		// *** Inicio nova regra de Data de Entrega chamado 035700 William Costa 10/07/2017 *** //
	    		
	    		SqlDtEntrega()
	    						
				IF TRE->(!EOF())
					  
					IF ALLTRIM(TRE->ZB7_DTENTR) <> ''
					
						dEntrega := STOD(TRE->ZB7_DTENTR)   //ALTERA PARA O CODIGO DO DE PARA DO CLIENTE
						
					ENDIF
				ENDIF
				TRE->(dbCloseArea())                   
	    		
	    		IF dEntrega <= DATE() 
	    		
	    			dEntrega := (DATE() + 1)
	    		
	    		ENDIF
	    		
	    		// *** Final nova regra de Data de Entrega chamado 035700 William Costa 10/07/2017 *** //
	    		
	    	ENDIF 
			
			IF SUBSTR(cTxt,001,002) == "04"
			
				cSeqPedCli := ALLTRIM(Substr(cTxt,003,004)) // Numero de Sequencia Ped Cliente
				cCodBar    := ALLTRIM(Substr(cTxt,018,014)) // Codigo do EAN 
				nQtd       := VAL(Substr(cTxt,100,015)) //VAL(Substr(cTxt,100,013) + '.' + Substr(cTxt,114,002)) // Quantidade Pedida 
				nVlUnit    := VAL(Substr(cTxt,183,015)) //VAL(Substr(cTxt,198,013) + '.' + Substr(cTxt,211,002)) // Valor Líquido Unitário
				cUnidade   := ALLTRIM(Substr(cTxt,092,002)) // Unidade de Medida
				
				// ******** INICIO VERIFICACAO DO DE PARA COD BAR  ****** //
				
				if !right(cCodBar,1)$"0123456789"
					cCodBar := left(cCodBar,LEN(cCodBar)-1)
				endif

				IF ALLTRIM(cCodRed) <> '' //Busca por rede
				
					 
					SqlBuscaRede()					
					
					While TRC->(!EOF())
					
						cCodBar := ALLTRIM(TRC->ZB7_CODPAR)   //ALTERA PARA O CODIGO DO DE PARA DO CLIENTE
					
					    TRC->(dbSkip())							
	                EndDo   
					TRC->(dbCloseArea())                   
				    
				ELSE // Busca por Codigo de Cliente        
				    
					SqlBuscaCodCli()					
					
					While TRD->(!EOF())
					
						cCodBar := ALLTRIM(TRD->ZB7_CODPAR)   //ALTERA PARA O CODIGO DO DE PARA DO CLIENTE
					
					    TRD->(dbSkip())							
	                EndDo   
					TRD->(dbCloseArea())                   
				    
				ENDIF	
				
				// ******** FINAL VERIFICACAO DO DE PARA COD BAR  ****** //
				
				SqlBuscaItem_e_TES()

				IF TRB->(EOF()) 

					IF ALLTRIM(cEstCli) == 'SP' .AND. ;
					   cEmpAnt          == '01' .AND. ;
					   cFilAnt          == '02'

						TRB->(dbCloseArea())	 
						SqlItem()
						
					ENDIF	

				ENDIF
			 
                While TRB->(!EOF()) 	                
                	
                	nVlUnit  := (nVlUnit/100)        
                	nQtd     := INT((nQtd / 100))   
                	
					

                	IF UPPER(ALLTRIM(cUnidade)) == 'KG' .OR. UPPER(ALLTRIM(cUnidade)) == '' //William Costa adicionado igual a branco para poder resolver pedidos do GPA que vem sem unidade de medida 11/01/2018
                	
	                	IF UPPER(ALLTRIM(TRB->B1_TIPCONV)) == 'D' //Divisor
	                	
	                		nQtdConv := INT(nQtd / IIF(TRB->B1_CONV == 0,1,TRB->B1_CONV))
							//Tkt 18915 - Tratamento na conversão dos itens com valor 0.
							if nQtdConv == 0
								nQtdConv 	:= 1
								nQtd		:= TRB->B1_CONV
							endif
							nVlTotal := nVlUnit * nQtd
	                		
	                	ELSE //MULTIPLICADOR
	                	                                                    
	                		nQtdConv := INT(nQtd * IIF(TRB->B1_CONV == 0,1,TRB->B1_CONV))
							nVlTotal := nVlUnit * nQtd
							
	                	ENDIF
                	
                	ELSEIF UPPER(ALLTRIM(cUnidade)) == 'EA' .OR. UPPER(ALLTRIM(cUnidade)) == 'CX'
                	
                		IF UPPER(ALLTRIM(TRB->B1_TIPCONV)) == 'D' //Divisor
	                	
	                		nQtdConv  := nQtd
	                		nQtdConv2 := INT(nQtd * IIF(TRB->B1_CONV == 0,1,TRB->B1_CONV))
	                		nQtdConv2 := iif(nQtdConv==0,1,nQtdConv)
							nVlUnit   := nVlUnit / IIF(TRB->B1_CONV == 0,1,TRB->B1_CONV)
	                		nVlTotal  := nVlUnit * nQtdConv2
	                			                		
	                	ENDIF
                	
                	ELSE
                	
                		Aadd(aPedidos,{cchave, ;
			                           ''    , ;
			                           ''    , ;
			                           ''    , ;
			                           'Produto:' +TRB->B1_COD + '-' + TRB->B1_DESC +' Unidade de Medida não esta em Kg e sim: ' + UPPER(ALLTRIM(cUnidade)) , ;
			                           cVendedor}) 
                	
                	END
                	
                	IF UPPER(ALLTRIM(TRB->FM_EST)) == 'SP'        .AND. ;
                	   UPPER(ALLTRIM(TRB->F4_CF))   $ '5401/5910' .AND. ;
                	   TRB->B1_PICMRET              > 0 
                	   
                		cTipoCli:= 'S'
                		
                	ELSE
                		        
                		IF UPPER(ALLTRIM(cTipoCli)) <> 'S'
                		
                			cTipoCli:= 'R'
                		
                	    ENDIF
                	ENDIF	
                	
                	aItem := {}
                    AADD(aItem,cCodBar)
                    AADD(aItem,TRB->B1_COD)
                    AADD(aItem,TRB->B1_DESC)
                    AADD(aItem,nQtd)
                    AADD(aItem,nQtdConv) 
                    AADD(aItem,nVlUnit)  
                    AADD(aItem,nVlTotal)    
                    AADD(aItem,TRB->B1_SEGUM)
                    AADD(aItem,TRB->B1_UM)
                    AADD(aItem,TRB->FM_TS)
                    AADD(aItem,cSeqPedCli)
                    AADD(aItens,aItem)
                    
                    TRB->(dbSkip())							
                EndDo   
				TRB->(dbCloseArea())
				
			ENDIF
			
	   		nLinha ++   
	    	FT_FSkip()
		ENDDO
		
		IF LEN(aItens) > 0
		
			CriaPed()
			
		ELSE
		
			cStatus := 'NOK'  	
		
		ENDIF	
			   
		FT_FUse()
		
		// ** INICIO COPIANDO E DELETANDO O ARQUIVO PARA A PASTA DE LIDOS OK OU ERRO ** //
		IF cStatus == 'OK'
			ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Processado como OK " + ALLTRIM(aDirectory[nCont][1])+"")
	        IF !FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\OK\" + aDirectory[nCont][1] )
	        	COPY FILE &( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) TO &( '\SYSTEM\edi\pedidos\' + "LIDOS\OK\" + aDirectory[nCont][1] )                
	        ENDIF                              
	            
	        IF FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\OK\" + aDirectory[nCont][1])                                                                                               
	        	IF FERASE( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) <> -1
	                
	            ENDIF     
	        ENDIF
	     
	    ELSEIF cStatus == 'NOK'  
	    	ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Processado como ERRO " + ALLTRIM(aDirectory[nCont][1])+"")
	    	IF !FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\ERRO\" + aDirectory[nCont][1] )
	        	COPY FILE &( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) TO &( '\SYSTEM\edi\pedidos\' + "LIDOS\ERRO\" + aDirectory[nCont][1] )                
	        ENDIF                              
	            
	        IF FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\ERRO\" + aDirectory[nCont][1])                                                                                               
	        	IF FERASE( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) <> -1
	                
	            ENDIF     
	        ENDIF                                                                     
	    
		ELSEIF cStatus == 'MENOR'  
	    	ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Processado como MENOR " + ALLTRIM(aDirectory[nCont][1])+"")
	    	IF !FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\MENOR\" + aDirectory[nCont][1] )
	        	COPY FILE &( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) TO &( '\SYSTEM\edi\pedidos\' + "LIDOS\MENOR\" + aDirectory[nCont][1] )                
	        ENDIF                              
	            
	        IF FILE( '\SYSTEM\edi\pedidos\' + "LIDOS\MENOR\" + aDirectory[nCont][1])                                                                                               
	        	IF FERASE( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] ) <> -1
	                
	            ENDIF     
	        ENDIF                                                                     
	    
	    ENDIF    
        // ** Final COPIANDO E DELETANDO O ARQUIVO PARA A PASTA DE LIDOS OK OU ERRO ** //
		
		//Ticket  9117   - Leonardo P. Monteiro - 05/02/2021 - Criação de parâmetro para limitação da quantidade de arquivos processados por execução de agendamento.
		nCont += 1       
	enddo
	//NEXT                                                                                 
	
	IF LEN(aVend) > 0
	
		RetiraDuplicidadeVetor()
		
		FOR nCont4:=1 TO LEN(aVendedores)
			ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - Enviando email...")
			EnviaWF(aPedidos,aVendedores)
			
	   	NEXT
	   	
	ENDIF   	
	// **************Final leitura dos arquivos TXT ************************ //

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	//ConOut("FINAL DO SCHEDULE ADVEN002P " + ALLTRIM(FUNNAME()) + ' ' + TIME())  
	ConOut("[ADVEN002P] "+ Dtoc(date())+"-"+ Time() +" - FINAL DO SCHEDULE ADVEN002P " + ALLTRIM(FUNNAME())+"")
	
	// ***INICIO Limpa o ambiente, liberando a licença e fechando as conexões************ //
	RpcClearEnv() 
	// ***FINAL Limpa o ambiente, liberando a licença e fechando as conexões************* //

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADVEN002P")

RETURN(NIL)  

Static Function CriaPed() 

	aCabPV  := {} 
	aItemPV := {}
	cStatus := ''
	//@history Ticket 12379   - Leonardo P. Monteiro - 15/04/2021 - Tratamento do EDI para evitar a inclusão de pedidos em duplicidade. Isso evita erros na importação de arquivos.
	DBSELECTAREA("SC5")
	SC5->(DBSETORDER(19))
	SC5->(DBGOTOP())
	IF DBSEEK(Xfilial("SC5")+cCodCli+DTOS(dEntrega)+cChave, .T.)
		cPedido := SC5->C5_NUM
							
		Aadd(aVend,{cVendedor, ;
					Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_EMAIL"), ;
					Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL")})

		Aadd(aPedidos,{cchave        , ;
					cPedido       , ;
					cCodCli       , ;
					DTOC(dEntrega), ;
					'Pedido de venda já incluso.', ; 
					cVendedor})
		
		cStatus := 'NOK'

	else
		aCabPV :={{"C5_FILIAL" ,"02"          ,Nil},; //XFILIAL("SC5")
				{"C5_TIPO"   ,"N"           ,Nil},; // Tipo de pedido
				{"C5_EDI"    ,cChave        ,Nil},; // Identifica que o pedido foi incluido pelo EDI
				{"C5_CLIENTE",cCodCli       ,Nil},; // Codigo do cliente  //_cCliente
				{"C5_LOJACLI",cLojCli       ,Nil},; // Loja do cliente
				{"C5_EMISSAO",DATE()        ,Nil},; // Data de emissao
				{"C5_DTENTR" ,dEntrega      ,Nil},; // Data de entrega
				{"C5_MENNOTA",cPedComprador ,Nil},; // Pedido de Compra do Comprador
				{"C5_PBRUTO" ,0             ,Nil},; //
				{"C5_PESOL"  ,0             ,Nil},; //
				{"C5_TIPOCLI",cTipoCli      ,Nil},; //
				{"C5_DESC1"  ,0             ,Nil}}  //
				
		nVlTotPed := 0
		nCont1    := 0
		
		&&Mauricio - 11/04/17 - validacao preco minimo pedido por segmento
		_cSegto := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_SATIV1")				
			
		FOR nCont1 := 1 TO LEN(aItens)	               
			
			nRetValPreco := VALPRECO(aItens[nCont1][2],aItens[nCont1][6]) 
			
			IF nRetValPreco == 0
					
				Aadd(aVend,{cVendedor, ;
							Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_EMAIL"), ;
							Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL")})
				
				Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Produto:' +aLLTRIM(aItens[nCont1][2]) + '-' + ALLTRIM(aItens[nCont1][3]) +' Pedido Edi Preço: R$ '+ cvaltochar(aItens[nCont1][6]) + ' não permitido ou bloqueio pelo Comercial', ;
							cVendedor})  
				LOOP  // valor de tabela menor do que o correto então não sera realizado
					// a importacao                       
			ENDIF    
		
			RegToMemory("SC6")
			Aadd(aItemPV,{{"C6_FILIAL" , "02"        	      , Nil },; // Filial 
						{"C6_ITEM"   , StrZero(nCont1,2)    , Nil },; // Número do item
						{"C6_PRODUTO", aItens[nCont1][2]    , Nil },; // Codigo do Produto
						{"C6_DESCRI" , aItens[nCont1][3]    , Nil },; // Descrição do Produto
						{"C6_UNSVEN" , aItens[nCont1][5] ,0 , Nil },; // Quantidade Pedida
						{"C6_PRCVEN" , aItens[nCont1][6] ,0 , Nil },;
						{"C6_VALOR"  , aItens[nCont1][7] ,0 , Nil },; // Preco de Lista
						{"C6_SEGUM"  , aItens[nCont1][8]    , Nil },; // Unidade de Medida de venda
						{"C6_QTDVEN" , aItens[nCont1][4] ,0 , Nil },;
						{"C6_UM"     , aItens[nCont1][9]    , Nil },; // Unidade de Medida Primar
						{"C6_TES"    , aItens[nCont1][10]   , Nil },; // TES
						{"C6_CLI"    , cCodCli              , Nil },; // Cliente
						{"C6_DESCONT", 0	                , Nil },;
						{"C6_VALDESC", 0	                , Nil },;
						{"C6_ENTREG" , dEntrega	          	, Nil },;
						{"C6_NFORI"  , ""	           		, Nil },;
						{"C6_SERIORI", ""	                , Nil },;
						{"C6_ITEMORI", ""				    , Nil },;
						{"C6_LOJA"   , cLojCli              , Nil },; // Loja do Cliente
						{"C6_PRUNIT" , aItens[nCont1][6] ,0 , Nil },;
						{"C6_OP"	   , "02"        	    , Nil },;
						{"C6_NUMPCOM", cPedComprador 	    , Nil },;
						{"C6_ITEMPC" , aItens[nCont1][11]   , Nil },;
						{"C6_TPOP"   , "F"				   	, Nil } })
			
			nVlTotPed := nVlTotPed + aItens[nCont1][7] 			  
							
		NEXT         
		
		//Everson - 19/10/2017. Chamado 037287.    
		IF LEN(aCabPV) >= 1 .AND. LEN(aItemPV) >= 1
			
			BEGIN TRANSACTION 
			
				lMsHelpAuto := .F.                      
				lMsErroAuto := .F.      
				
				MSExecAuto({|x,y,z| Mata410(x,y,z) }, aCabPV, aItemPV, 3)                                                        
																			
				IF !lMsErroAuto
					
					DBSELECTAREA("SC5")
						DBSETORDER(19)                                                                             
						DBGOTOP()
						IF DBSEEK(Xfilial("SC5")+cCodCli+DTOS(dEntrega)+cChave, .T.)
							cPedido := SC5->C5_NUM
							
							Aadd(aVend,{cVendedor, ;
										Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_EMAIL"), ;
										Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL")})
				
							Aadd(aPedidos,{cchave        , ;
										cPedido       , ;
										cCodCli       , ;
										DTOC(dEntrega), ;
										'Incluido com sucesso.', ; 
										cVendedor})  
						ENDIF                                                
					DBCLOSEAREA("SC5")      
					
					cStatus := 'OK'
					
				ELSE         
													
					DisarmTransaction()               
					
					Aadd(aVend,{cVendedor, ;
								Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_EMAIL"), ;
								Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL")})
				
					Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'Pedido não incluso no sistema, todos os itens foram rejeitados', ;
								cVendedor})  
					cMostraErro := mostraerro("\SYSTEM\edi\pedidos\edi.log")
					cStatus     := 'NOK'
					
				ENDIF      
			END TRANSACTION	
		ELSE
			cStatus     := 'NOK'
		ENDIF
    
	endif

Return(NIL)     

Static Function VALPRECO(cProd,nPrecoUnit)

	Local cArea     := GetArea()
	Local nRet      := 0 //M->C6_PRCVEN
	Local cTpFrt    := "C" // M->C5_TPFRETE
	Local cTbPrMx   := GETMV("MV_TBPRMX")  // ALEX BORGES 01/03/12 ACRESCENTADO PARA VALIDAR O PRECO MAXIMO IGUAL A REGRA DO PREÇO MINIMO
	Local cTbPrMnV  := GETMV("MV_TBPRMN")  &&Tabela preco minimo vendedor - Mauricio - MDS TEC - 11/12/2013
	Local cTbPrMnS  := GETMV("MV_TBPRMNS") &&Tabela preco minimo supervisor - Mauricio - MDS TEC - 11/12/2013
	Local AHEADER   := {}  
	Local ACOLS     := {}  
	Local cCodSuper := ''
	Local cVend     := ''
	
	If cEmpAnt <> "01"   &&somente executa para empresa Adoro.
	   return(nPrecoUnit)
	Endif                
	 
	//  *** INICIO CHAMADO - 030831 ALTERACAO DO VENDEDOR PARA O SUPERVISOR PARA APROVACAO DO PREÇO UNITARIO *** //
	
	cCodSuper := Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_SUPER")
	cVend     := Posicione("SA3",1,xFilial("SA3")+cCodSuper,"A3_COD")
	
	//  *** FINAL CHAMADO - 030831 ALTERACAO DO VENDEDOR PARA O SUPERVISOR PARA APROVACAO DO PREÇO UNITARIO *** //
	    
	dbSelectArea("SA3")
	dbSetOrder(1)                                                   
	
	lVd := .F.
	lSp := .F.
		
	If dbSeek(xFilial("SA3")+cVend)  				   // Só executa se usuario incluindo pedido for vendedor (primeira condição)
	    &&Mauricio - MDS Tecnologia - 11/12/2013 - Validação de preço minimo sera diferenciado por supervisor e vendedor
	    lVd := .T.    &&é vendedor e não supervisor
	    lSp := .F.
	    
	    dbSelectArea("SA1")
		dbSetOrder(1)
			
		If SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli)) 
		
		   cVendedor  := SA1->A1_VEND  &&confirmado com Vagner, vendedor vem do cadastro de cliente e não do pedido
		   cSuperv    := Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_CODSUP") 
		   __cUserID  :=  Posicione("SA3",1,xFilial("SA3")+cCodSuper,"A3_CODUSR")
		   cFaixa     := Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_FXPDMIN") 
		   &&Mauricio - 06/08/14 - modificado forma de trazer supervisor conforme teste/validacao da rotina pelo Vagner.
		   cSupUsu    := Posicione("SZR",1,xFilial("SZR")+cSuperv,"ZR_USER")
		   
		   
		   If Alltrim(__cUserID) == Alltrim(cSupUsu)
		      lSp := .T.        &&é supervisor e não vendedor
		      lVd := .F.
		   Endif
	    
	       &&busco frete e contrato
	       nDesconto := SA1->A1_DESC   &&conforme M410STTS, mesmo rede o desconto vem do cliente do pedido.				   
		   cEst	     := SA1->A1_EST
		   cMunic    := SA1->A1_COD_MUN
			    
		   IF cTpFrt == "C"
				   If !Empty(cMunic)
					  cRegiao:= Posicione('CC2',1,xFilial("CC2")+cEst+cMunic,"CC2_XREGIA")  // Localizo a regiao do cliente
				   EndIf
				
				   If !Empty(cRegiao)
					  nFrete := Posicione('ZZI',1,xFilial("ZZI")+cRegiao,"ZZI_VALOR")         // Valor do frete para a regiao
				   Else
					  dbSelectArea("ZZI")                                                      // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
					  dbSetOrder(3)
					  dbSeek(cEst)
					
					  While ZZI->(!Eof()) .And. ZZI->ZZI_ESTADO == cEst
						
						  If nFrete < ZZI->ZZI_VALOR
							nFrete := ZZI->ZZI_VALOR
						  EndIf
						
						  ZZI->(dbSkip())
						
					  EndDo
				   EndIf
		   Else
				   nFrete := 0.00
		   Endif       
	       
	       &&Validacao preco maximo permanece o mesmo  
	//       NPOSPROD := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
	//       cProd := ACOLS[N,_NPOSPROD]
	       dbSelectArea("DA1")
		   dbSetOrder(1) 	   
	       If dbSeek(xFilial("DA1")+ALLTRIM(cTbPrMx)+cProd)
			  nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
	          if (nPrecoUnit - nFrete - ((nPrecoUnit * nDesconto)/100)  ) > nPrcTab
	//             MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 
	             nPrecoUnit := 0.00
	             RestArea(cArea)
	             return(nPrecoUnit)
	          Endif
	       Endif
	               
	       &&Valido o valor minimo
		   &&Mauricio - MDS Tecnologia - 11/12/2013 - valido por vendedor e por supervisor em tabelas diferentes
		   If lVd	 &&vendedor
		      If dbSeek(xFilial("DA1")+ALLTRIM(cTbPrMnV)+cProd)
			     nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
	             if (nPrecoUnit - nFrete - ((nPrecoUnit * nDesconto)/100)  ) < nPrcTab
	//                MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 
	                nPrecoUnit := 0.00
	                RestArea(cArea)
	                return(nPrecoUnit)
	             Endif
	          Endif
	       Endif
	       If lSp	 &&supervisor
		      If dbSeek(xFilial("DA1")+ALLTRIM(cTbPrMnS)+cProd)
			     nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
	             if (nPrecoUnit - nFrete - ((nPrecoUnit * nDesconto)/100)  ) < nPrcTab
	//                MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 
	                nPrecoUnit := 0.00
	                RestArea(cArea)
	                return(nPrecoUnit)
	             Endif
	          Endif
	       Endif                 
	    Endif
	       
	    &&Mauricio - MDS TEC - 12/12/12 - Tratamento para validar inclusão de produto por Supervisor....
	    DbSelectArea("SA3")
	    DbSetOrder(1)
	    if dbseek(xFilial("SA3")+cVend)
	       cCodSup := SA3->A3_CODSUP
	       lGeral  := .F.
	       &&Mauricio 26/12/12 - Validação para todos os produtos do supervisor - Inicio
	       DbSelectArea("DA1")
	       If dbseek(xFilial("DA1")+"Y00"+"999999") &&produto generico 999999(precisa existir)
	          If DA1->DA1_000000 == "B"
	//             MsgInfo("Venda de todos os produtos foi bloqueada pelo Comercial!","Atenção")
	             lGeral := .T. 
	             nPrecoUnit := 0.00
	          Else   
	             cCampo := "'DA1_"+cCodSup+"'"
	             cCpo2  := "DA1->DA1_"+cCodSup
	             IF FieldPos(&cCampo) > 0
	                If &cCpo2 == "B"
	//                   MsgInfo("Venda de todos os produtos foi bloqueada pelo Comercial!","Atenção")
	                   lGeral := .T. 
	                   nPrecoUnit := 0.00
	                Endif
	             Endif                             
	          Endif
	       Endif         
	       &&fim
	       If !lgeral            &&se não é "geral" valida bloqueio por produto.
	          DbSelectArea("DA1")
	          If dbseek(xFilial("DA1")+"Y00"+cProd)
	             If DA1->DA1_000000 == "B"
	//                MsgInfo("Produto bloqueado para venda pelo Comercial!","Atenção") 
	                nPrecoUnit := 0.00
	             Else   
	                cCampo := "'DA1_"+cCodSup+"'"
	                cCpo2  := "DA1->DA1_"+cCodSup
	                IF FieldPos(&cCampo) > 0
	                   If &cCpo2 == "B"
	//                      MsgInfo("Produto bloqueado para venda pelo Comercial!","Atenção") 
	                      nPrecoUnit := 0.00
	                   Endif
	                Endif                             
	             Endif
	          endif
	       Endif         
	    Endif                   
	endif        
	
	RestArea(cArea)
Return(nPrecoUnit)   

Static Function EnviaWF(aPedidos,aVendedores)

	Local lOk          := .T.
	Local cBody        := RetHTML2(aPedidos,aVendedores)
	Local cErrorMsg    := ""
	Local aFiles       := {}
	Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
	// TMP
	//Local cTo          := "monitor.sistemas.vp@adoro.com.br" + IIF(aVendedores[nCont4][2] <> '', ';' + aVendedores[nCont4][2], '') + IIF(aVendedores[nCont4][3] <> '', ';' + aVendedores[nCont4][3], '')              
	Local cTo          := Alltrim(aVendedores[nCont4][2]) + IIF(aVendedores[nCont4][3] <> '', ';' + aVendedores[nCont4][3], '')              
	Local cCc		   := Alltrim(Supergetmv("MV_#EDI002",,"monitor.sistemas.vp@adoro.com.br;leonardo.monteiro@adoro.com.br"))
	Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk       := .F.
	Local cAtach       := ""   
	Local cSubject     := ""          
	
	cSubject := "INCLUSAO DE PEDIDOS EDI - Registro das Inclusoes"
	
	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk
	
	If !lAutOk
	   If ( lSmtpAuth )
	      lAutOk := MailAuth(cAccount,cPassword)
	   Else
	      lAutOk := .T.
	   EndIf
	EndIf
	
	If lOk .And. lAutOk                
	   Send Mail From cFrom To cTo CC cCc Subject cSubject Body cBody ATTACHMENT cAtach Result lOk              
	   If !lOk
	      Get Mail Error cErrorMsg
	      ConOut("3 - " + cErrorMsg)
	   EndIf
	Else
	   Get Mail Error cErrorMsg
	   ConOut("4 - " + cErrorMsg)
	EndIf
	
	If lOk
	   Disconnect Smtp Server
	Endif
	
Return

Static Function RetHTML2(aPedidos,aVendedores)

	Local cRet := ''
	
	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>"
                                                                                      
	For n:=1 to len(aPedidos) 
	
		IF aPedidos[n][6] == aVendedores[nCont4][1]
		
			// *** INICIO WILLIAM COSTA 06/08/2019 CHAMADO 050848 || OS 052150 || ADM. || AS_002 || 979699037 || PAINEL P.V EDI
			
			IF n <> 1
			
		    	cRet += "<br><br>"
		    	
	    	ENDIF   
	    	// *** FINAL WILLIAM COSTA 06/08/2019 CHAMADO 050848 || OS 052150 || ADM. || AS_002 || 979699037 || PAINEL P.V EDI
	    
		    cRet += "<b>Cod Edi.: </b>    " + aPedidos[n,1] + ;
		            "<br>"                                  
		            
            IF ALLTRIM (aPedidos[n,2]) <> ''
            
	    		cRet += "<b>Pedido Nº.: </b>  " + aPedidos[n,2] + ; 
	    				"<br>"                                  + ;  
	            		"<b> Cliente.: </b>   " + aPedidos[n,3] + ; 
	            		"<br>"                                  + ;  
	            		"<b>Dt Entrega.: </b> " + aPedidos[n,4] + ;  
	            		"<br>"                                  
	            
            ENDIF
		            
		    cRet += "<b>Mensagem.: </b>   " + aPedidos[n,5] 
		    
		ENDIF            
	NEXT   
	
	cRet += "<br>"
	cRet += "<br><br>É de extrema importância que seja feita a conferência dos pedidos incluídos"          
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> Depto de Tecnologia da Informacao <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'

Return(cRet) 

Static Function RetiraDuplicidadeVetor()

	Local nCont2      := 0  
	Local nCont3      := 0
	Local lAchou      := .F.
	Local cVendV1     := ''
	Local cVendV2     := ''
	
	FOR nCont2:=1 TO LEN(aVend)
		
		cVendV1 := aVend[nCont2][1]
		
		IF nCont2 == 1 
		
			Aadd(aVendedores,aVend[nCont2])
	
		ELSE
		
			FOR nCont3:=1 TO LEN(aVendedores)
			
				cVendV2 := aVendedores[nCont3][1]
			
				IF cVendV1 == cVendV2
				
					lAchou := .T.
				
				ENDIF
			
			NEXT
			
			IF lAchou == .T.     
			
				lAchou := .F.
			
			ELSE
		
				Aadd(aVendedores,aVend[nCont2])  
			
			ENDIF
		ENDIF     
	NEXT      
	
RETURN(NIL)	  

Static Function logZBN(cStatus)

	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADVEN002P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADVEN002P' 
			ZBN_DESCRI  := 'Programa EDI para o comercial'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '15:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '15:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADVEN002P' 
			ZBN_DESCRI  := 'Programa EDI para o comercial'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '15:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '15:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

Static Function SqlBuscaItem_e_TES()
        
    BeginSQL Alias "TRB"
			%NoPARSER%   
			 SELECT TOP(1)B1_COD,
					B1_DESC,
					B1_MSBLQL,
					B1_CONV,
					B1_SEGUM,
					B1_UM,
					SFM.FM_TS,
					SB1.B1_ORIGEM,
					SF4.F4_CF,
			       	SF4.F4_SITTRIB, 
					SB1.B1_TIPCONV,
					SB1.B1_PICMRET,
					SFM.FM_EST       
			   FROM %Table:SB1% SB1,%Table:SFM% SFM,%Table:SF4% SF4
			  WHERE B1_CODBAR       = %exp:cCodBar%
			    AND B1_MSBLQL       = 2
			    AND SFM.FM_TIPO     = '02'  //Alterado de 01 para 02, devido a alteração da tributacao em 01/04/2017 - chamado 034134 por Adriana em 06/04/17
				AND SFM.FM_PRODUTO  = SB1.B1_COD
				AND SFM.FM_EST      = %exp:cEstCli%
				AND SFM.FM_TIPOCLI  = %exp:_cTipoCli% 
				AND SFM.FM_PRODUTO  = SB1.B1_COD
				AND SF4.F4_CODIGO   = SFM.FM_TS
				AND SFM.D_E_L_E_T_ <> '*'
				AND SB1.D_E_L_E_T_ <> '*'
				AND SF4.D_E_L_E_T_ <> '*'
				
				ORDER BY B1_COD
			
	EndSQl
RETURN(NIL)                         

Static Function SqlItem()
        
    BeginSQL Alias "TRB"
			%NoPARSER%   
			 SELECT TOP(1)B1_COD,
					B1_DESC,
					B1_MSBLQL,
					B1_CONV,
					B1_SEGUM,
					B1_UM,
					B1_TS AS FM_TS,
					SB1.B1_ORIGEM,
					SF4.F4_CF,
			       	SF4.F4_SITTRIB, 
					SB1.B1_TIPCONV,
					SB1.B1_PICMRET,
					'SP' AS FM_EST   
			   FROM %Table:SB1% SB1,%Table:SF4% SF4
			  WHERE B1_CODBAR       = %exp:cCodBar%
			    AND B1_MSBLQL       = 2
			    AND SF4.F4_CODIGO   = B1_TS
				AND SB1.D_E_L_E_T_ <> '*'
				AND SF4.D_E_L_E_T_ <> '*'
				
				ORDER BY B1_COD
			
	EndSQl
RETURN(NIL)                         

Static Function SqlBuscaRede()
        
    BeginSQL Alias "TRC"
			%NoPARSER%   
			SELECT ZB7_REDE,
				   ZB7_CODPAR 
			  FROM %Table:ZB7% 
			  WHERE ZB7_REDE   <> ''
			    AND ZB7_REDE    = %exp:cCodRed% 
			    AND ZB7_CODDE   = %exp:cCodBar%
				AND D_E_L_E_T_ <> '*'
			
	EndSQl
RETURN(NIL)

Static Function SqlBuscaCodCli()
        
    BeginSQL Alias "TRD"
			%NoPARSER%   
			 SELECT ZB7_REDE,
					ZB7_CODDE,
				    ZB7_CODPAR 
			   FROM %Table:ZB7% 
			  WHERE ZB7_CODCLI <> ''
			    AND ZB7_CODCLI  = %exp:cCodCli% 
				AND ZB7_CODDE   = %exp:cCodBar%
				AND D_E_L_E_T_ <> '*'
			
	EndSQl
RETURN(NIL)                         

Static Function SqlDtEntrega()
        
    BeginSQL Alias "TRE"
			%NoPARSER%   
			SELECT MAX(ZB7_DTENTR) AS ZB7_DTENTR
			  FROM %Table:ZB7% 
			  WHERE ZB7_REDE   <> ''
			    AND ZB7_REDE    = %exp:cCodRed% 
			    AND D_E_L_E_T_ <> '*'
			
	EndSQl
RETURN(NIL)
