#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#define CRLF +chr(13)+chr(10)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG001R ºAutor  ³William Costa       º Data ³  28/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio Ravex, que gera xml por roteiros diarios a partir º±±
±±º          ³da informacao de um pasta nas perguntas                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logistica                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADLOG001R()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Ravex, que gera xml por roteiros diarios a partir da informacao de um pasta nas perguntas')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays	  :={}
	Private aButtons  :={}   
	Private cCadastro :="Exportação Ravex / Logistica"    
	PRIVATE oFontA06  := TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09  := TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b := TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07  := TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn	  :=TMSPrinter():New()
	Private nOpca	  :=0
	Private cPerg	  := 'ADLOG001R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo XML de Exportação " )
	AADD(aSays,"Ravex/Logistica" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ExportaXML()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return Nil           

 
Static Function ExportaXML()

	Local   cModelo    := ''
    Local   cXml       := '' 
	Local   oXml
	Local   nLTRC      := 0
	Local   nLTRD      := 0
	Local   nLTRE      := 0
	Local   nTotL      := 0
	Local   nHdl       := 0  
	Private cRotCab    := ''  
	Private cRotCabOld := ''  	
	Private cRotRod    := ''  
	Private cRotRodOld := ''
	Private cTipoFrete := '' 
	Private cHoraSai   := ''
	Private cHoraRet   := '' 
	Private cFil       := ''
	Private cDtEntr    := '' 
	Private cCliente   := ''
    Private cLojaCli   := ''
    Private cNota      := ''
    Private cSerie     := ''  
    Private cPlaca     := ''
	Private cRoteiro   := '' 
	Private cEndereco  := ''
	Private cBairro    := ''
	
    SqlRot()
	cRotCabOld := ''
	cRotRodOld := TRB->C5_ROTEIRO
	
	While TRB->(!EOF())  
	
		cRotCab := TRB->C5_ROTEIRO //Valor do Cabeçalho para  criar o xml
	    cRotRod := TRB->C5_ROTEIRO //Valor do Rodapé para jogar os valores do xml no arquivo
	    //Primeira vez que entra no Roteiro 
	    
		IF cRotCab <> cRotCabOld
	 
			//Nome do Arquivo
			cArqLocal :=  'ROT' + '_' + DTOS(DDATABASE) + '_' + cRotCab + ".XML"
			 
			//Cria uma arquivo vazio em disco
			nHdl := Fcreate(ALLTRIM(MV_PAR09)+cArqLocal)
			
			cRotCabOld := cRotCab   
			cRotRodOld := cRotRod                                  
			
			//*************************** INICIO VERIFICACAO DO TIPO FRETE *********************************************************//
			IF TRB->ZK_TPFRETE == 'A4' .OR. TRB->ZK_TPFRETE == 'A2' 
			
				cTipoFrete := 'TRF' // TIPO FRETE TRANSFERENCIA
			
			ELSE              
			
				cTipoFrete := 'DIS'	//TIPO FRETE DISTRIBUICAO
				
			ENDIF
			//*************************** FINAL VERIFICACAO DO TIPO FRETE *********************************************************//
			
			//*************************** INICIO VERIFICACAO DA HORA INICIAL *********************************************************//
			IF ALLTRIM(TRB->ZK_HORASAI) == '' 
			
				cHoraSai := TRB->C5_DTENTR + "_" + '00:00:00'
			
			ELSE              
			
				cHoraSai := TRB->C5_DTENTR + '_' + TRB->ZK_HORASAI
				
			ENDIF
			//*************************** FINAL VERIFICACAO DA HORA INICIAL *********************************************************//
			
			//*************************** INICIO VERIFICACAO DA HORA INICIAL *********************************************************//
			IF ALLTRIM(TRB->ZK_HORARET) == '' 
			
				cHoraRet := TRB->C5_DTENTR + '_' + '23:59:59'
			
			ELSE              
			
				cHoraRet := TRB->C5_DTENTR + '_' + TRB->ZK_HORARET
				
			ENDIF
			//*************************** FINAL VERIFICACAO DA HORA INICIAL *********************************************************//
		ENDIF //fecha if cRotCab <> cRotCabOld
		
		// Crio modelo ( apenas estrutura ) em String  
		cModelo := '<?xml version="1.0" encoding="UTF-8"?>' 
		cModelo += '<Viagem>'  //INICIA NO DE VIAGEM
		cModelo += 		'<CNPJUnidade></CNPJUnidade>'
		cModelo += 		'<Cubagem></Cubagem>' 
	 	cModelo += 		'<Destino></Destino>' 
		cModelo += 		'<EstimativaFim></EstimativaFim>' 
		cModelo += 		'<EstimativaInicio></EstimativaInicio>' 
		cModelo += 		'<Identificador></Identificador>' 
		cModelo += 		'<Observacoes></Observacoes>' 
		cModelo += 		'<Origem></Origem>'
		cModelo += 		'<Peso></Peso>' 
		cModelo += 		'<Placa></Placa>'
		cModelo += 		'<Tipo></Tipo>' 
		cModelo += 		'<Valor></Valor>'
		cModelo += 		'<ViagemPrioritaria></ViagemPrioritaria>' 
		cModelo +=   		'<Entregas>'  //INICIA NO DE ENTREGAS
		cModelo +=   			'<Entrega>' //INICIA NO DE ENTREGA
		cModelo += 					'<Bairro></Bairro>' 
		cModelo += 					'<Cliente></Cliente>'
		cModelo += 					'<Codigo></Codigo>' 
		cModelo += 					'<Cubagem></Cubagem>'
		cModelo += 					'<Endereco></Endereco>'
		cModelo += 	            	'<EstimativaFim></EstimativaFim>' 
		cModelo += 	           	 	'<EstimativaInicio></EstimativaInicio>' 
		cModelo += 	            	'<Latitude></Latitude>' 
		cModelo += 	            	'<Longitude></Longitude>' 
		cModelo += 	            	'<Peso></Peso>' 
		cModelo += 	            	'<Sequencia></Sequencia>' 
		cModelo += 	            	'<Valor></Valor>' 
		cModelo +=   					'<NotasFiscais>'  //INICIA NO DE NOTAS FISCAIS
		cModelo +=   				   		'<NotaFiscal>' //INICIA NO DE NOTA FISCAL
		cModelo += 	         			    	'<Sequencia></Sequencia>' 
		cModelo += 	         			    	'<Numero></Numero>' 
        cModelo += 	         			    	'<Cliente></Cliente>' 
		cModelo += 	                        	'<EstimativaInicio></EstimativaInicio>' 
		cModelo += 	                        	'<EstimativaFim></EstimativaFim>' 
		cModelo += 	                        	'<Peso></Peso>' 
		cModelo += 			                	'<Cubagem></Cubagem>' 
		cModelo += 	                        	'<Valor></Valor>' 
		cModelo += 	                        	'<NomeVendedor></NomeVendedor>' 
		cModelo += 	                        	'<FoneVendedor></FoneVendedor>' 
		cModelo += 	                        	'<EmailVendedor></EmailVendedor>' 
		cModelo += 	                        	'<NomeSupervisor></NomeSupervisor>' 
		cModelo += 	                        	'<FoneSupervisor></FoneSupervisor>' 
		cModelo += 	                        	'<EmailSupervisor></EmailSupervisor>' 
		cModelo += 	                        	'<FonePromotor></FonePromotor>' 
		cModelo += 				   	   	   			'<Itens>'  //INICIA NO DE ITENS  
		cModelo += 				   	   	   	   			'<Item>'  //INICIA NO DE ITEM
		cModelo += 	         			   					'<Sequencia></Sequencia>' 
		cModelo += 	         			   					'<Codigo></Codigo>' 
		cModelo += 	         			   					'<Descricao></Descricao>'
		cModelo += 	         			   					'<Quantidade></Quantidade>' 
		cModelo += 	         			   					'<ValorUnitario></ValorUnitario>' 
		cModelo += 	         			   		 			'<PesoUnitario></PesoUnitario>' 
		cModelo += 				   		   				'</Item>'  //FECHA NO DE ITEM
		cModelo += 				   		   			'</Itens>'  //FECHA NO DE ITENS  
		cModelo += 				   			'</NotaFiscal>'  //FECHA NO DE NOTA FISCAL
		cModelo += 						'</NotasFiscais>' //FECHA NO DE NOTAS FISCAIS
		cModelo += 				'</Entrega>'  //FECHA NO DE ENTREGA 
		cModelo += 			'</Entregas>'  //FECHA NO DE ENTREGAS
		cModelo += '</Viagem>'  //FECHA NO DE VIAGEM
		
		// Crio o Objeto XML , definindo o Livro como Array
	    CREATE oXML XMLSTRING cModelo;
		SETASARRAY _VIAGEM:_ENTREGAS:_ENTREGA,;
		           _VIAGEM:_ENTREGAS:_ENTREGA:_NOTASFISCAIS:_NOTAFISCAL,;
		           _VIAGEM:_ENTREGAS:_ENTREGA:_NOTASFISCAIS:_NOTAFISCAL:_ITENS:_ITEM
		
		nXmlStatus := XMLError()
		
		IF ( nXmlStatus == XERROR_SUCCESS )
		    
		    //************************************ Inicio Carrega XML do no de viagem *******************************
			oXml:_VIAGEM:_CNPJUNIDADE:TEXT       := RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CGC')
	      	oXml:_VIAGEM:_CUBAGEM:TEXT           := SPACE(01)
	      	oXml:_VIAGEM:_DESTINO:TEXT           := TRB->ZK_DESTINO
	      	oXml:_VIAGEM:_ESTIMATIVAFIM:TEXT     := cHoraRet
	      	oXml:_VIAGEM:_ESTIMATIVAINICIO:TEXT  := cHoraSai
	      	oXml:_VIAGEM:_IDENTIFICADOR:TEXT     := TRB->C5_DTENTR + '-' + TRB->C5_ROTEIRO
	      	oXml:_VIAGEM:_OBSERVACOES:TEXT       := SPACE(01)
	      	oXml:_VIAGEM:_ORIGEM:TEXT            := RetField('SM0',1,cEmpAnt+cFilAnt,'M0_NOMECOM')
	      	oXml:_VIAGEM:_PESO:TEXT              := cvaltochar(TRB->ZK_PBRUTO)
	      	oXml:_VIAGEM:_PLACA:TEXT             := TRB->C5_PLACA
	      	oXml:_VIAGEM:_TIPO:TEXT              := cTipoFrete
	      	oXml:_VIAGEM:_VALOR:TEXT             := cvaltochar(TRB->ZK_VALFRET)
	      	oXml:_VIAGEM:_VIAGEMPRIORITARIA:TEXT := "0" 
	      	//************************************ final Carrega XML do no de viagem *******************************
	      	
	      	//************************************ Inicio Carrega XML do no de entrega *******************************
	      	cFil    := TRB->C5_FILIAL  
	      	cDtEntr := TRB->C5_DTENTR
	      	SqlEntregas()            
	      	cFil    := ''
	      	cDtEntr := ''
	      	
      		While TRC->(!EOF()) 
	            
	    		nLTRC := nLTRC + 1 //soma linha do ní
	    		
	            
		      	IF nLTRC > 1
		           
			       ADDNODE oXml:_VIAGEM:_ENTREGAS:_ENTREGA NODE '_ENTREGA' ON oXml  //Adiciona um no nas entregas quando e mais que um
			       
			    ENDIF 
			    
			    If Alltrim(TRC->A1_SATIV1)="50" .and. Alltrim(TRC->A1_SATIV2)$"51,52,53"
			    	cEndereco  := TRC->A1_ENDENT
					cBairro    := TRC->A1_BAIRROE
				ElseIf TRC->A1_IMPENT = "S" //Adoro  para endereço de entrega diferente e cozinha industrial    
				    cEndereco  := TRC->A1_ENDENT
					cBairro    := TRC->A1_BAIRROE
				Else 
					cEndereco  := TRC->A1_END
					cBairro    := TRC->A1_BAIRRO
				Endif	
			    
			    oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_BAIRRO:TEXT           := cBairro
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_CLIENTE:TEXT          := POSICIONE('SA1',1,xFilial("SA1")+TRC->C5_CLIENTE+TRC->C5_LOJACLI,'A1_NOME')
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_CODIGO:TEXT           := TRC->C5_CLIENTE
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_CUBAGEM:TEXT          := SPACE(01)
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_ENDERECO:TEXT         := cEndereco
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_ESTIMATIVAFIM:TEXT    := cHoraRet
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_ESTIMATIVAINICIO:TEXT := cHoraSai
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_LATITUDE:TEXT         := TRC->A1_XLATITU
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_LONGITUDE:TEXT        := TRC->A1_XLONGIT
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_PESO:TEXT             := TRC->C5_PBRUTO
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_SEQUENCIA:TEXT        := STRZERO(nLTRC,2)
		      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_VALOR:TEXT            := TRC->C6_VALOR
		      	//************************************ Final Carrega XML do no de entrega *******************************
		      	//************************************ Inicio Carrega XML do no de notas fiscais *******************************
		      	cFil       := TRB->C5_FILIAL  
		      	cCliente   := TRC->C5_CLIENTE
                cLojaCli   := TRC->C5_LOJACLI
                cDtEntr    := TRB->C5_DTENTR
                cPlaca     := TRB->C5_PLACA
				cRoteiro   := TRB->C5_ROTEIRO   
				SqlNotas()      
                cFil       := ''
		      	cCliente   := ''
                cLojaCli   := ''
                cDtEntr    := ''
                cPlaca     := ''
                cRoteiro   := ''
                
	      		While TRD->(!EOF()) 
	      		
	      			nLTRD := nLTRD + 1 //soma linha do ní
    		
                    
			      	IF nLTRD > 1
			           
				       ADDNODE oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL NODE '_NOTAFISCAL' ON oXml  //Adiciona um no nas entregas quando e mais que um
				       
				    ENDIF
				     
				    oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_CLIENTE:TEXT          := TRD->F2_CLIENTE 
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_CUBAGEM:TEXT          := SPACE(01)
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_EMAILSUPERVISOR:TEXT  := POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_EMAIL')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_EMAILVENDEDOR:TEXT    := POSICIONE('SA3',1,xFilial("SA3")+TRD->F2_VEND1,'A3_EMAIL')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ESTIMATIVAFIM:TEXT    := cHoraRet
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ESTIMATIVAINICIO:TEXT := cHoraSai
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_FONEPROMOTOR:TEXT     := POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_FONESUPERVISOR:TEXT   := POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_TEL')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_FONEVENDEDOR:TEXT     := POSICIONE('SA3',1,xFilial("SA3")+TRD->F2_VEND1,'A3_TEL')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_NOMESUPERVISOR:TEXT   := POSICIONE('SA3',1,xFilial("SA3")+TRD->A3_SUPER,'A3_NOMSUP')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_NOMEVENDEDOR:TEXT     := POSICIONE('SA3',1,xFilial("SA3")+TRD->F2_VEND1,'A3_NOME')
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_NUMERO:TEXT           := VAL(TRD->F2_DOC)
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_PESO:TEXT             := TRD->F2_PBRUTO
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_SEQUENCIA:TEXT        := nLTRD
			      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_VALOR:TEXT            := TRD->F2_VALBRUT 
			      	
			      	//************************************ Inicio Carrega XML do no de ITENS *******************************
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
	                
		      		While TRE->(!EOF()) 
		      		
		      			nLTRE := nLTRE + 1 //soma linha do ní
	    		
	                    
				      	IF nLTRE > 1
				           
					       ADDNODE oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM NODE '_ITEM' ON oXml  //Adiciona um no nas entregas quando e mais que um
					       
					    ENDIF  
					    
					    oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_CODIGO:TEXT        := TRE->D2_COD
				      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_DESCRICAO:TEXT     := TRE->B1_DESC
				      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_PESOUNITARIO:TEXT  := TRE->PESOUNIT
				      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_QUANTIDADE:TEXT    := TRE->D2_QTSEGUM
				      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_SEQUENCIA:TEXT     := TRE->D2_ITEM
				      	oXml:_VIAGEM:_ENTREGAS:_ENTREGA[nLTRC]:_NOTASFISCAIS:_NOTAFISCAL[nLTRD]:_ITENS:_ITEM[nLTRE]:_VALORUNITARIO:TEXT := TRE->D2_PRCVEN 
				      	
				      	TRE->(dbSkip())
                    ENDDO //FECHA WHILE DO TRE
			    	nLTRE := 0 // Zera o contador de linha do SQL TRE
					TRE->(dbCloseArea()) 
		      		//************************************ Final Carrega XML do no de Itens *******************************
			      	
			      	TRD->(dbSkip())
		
				ENDDO //FECHA WHILE DO TRD
		    	nLTRD := 0 // Zera o contador de linha do SQL TRC    
				TRD->(dbCloseArea()) 
	      		//************************************ Final Carrega XML do no de notas fiscais *******************************
		      	
		      	TRC->(dbSkip())
			
			ENDDO //FECHA WHILE DO TRC
	    	nLTRC := 0 // Zera o contador de linha do SQL TRC    
			TRC->(dbCloseArea()) 
			
		    //Primeira vez que entra no Roteiro
			IF cRotRod == cRotRodOld
		 
				SAVE oXml XMLSTRING cXml // Ao fim do processo , gera a string XML correspondente ao Objeto
			   
				cXml := StrTran(cXml,'&quot;','') // forceps para tirar valores indesejados do xml
				
				FWRITE(nHdl,cXML) //Função escreve no arquivo TXT.
				
				FCLOSE(nHdl) //Fecha o arquivo em disco
				cXML     := ''
			ENDIF //fecha if cRotCab <> cRotCabOld
			
		ELSE
	   
	    	MsgStop("Erro ("+str(nXmlStatus,3)+") na criação do XML.")
	   
		ENDIF //FECHA IF ( nXmlStatus == XERROR_SUCCESS )
			 
		TRB->(dbSkip())
			
	ENDDO //FECHA WHILE DO TRB
	    	    
	TRB->(dbCloseArea())
	 
	

RETURN(NIL)       

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Filial De          ?','','','mv_ch1','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Filial Ate         ?','','','mv_ch2','C',02,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
    PutSx1(cPerg,'03','Data Entrega De    ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Entrega Ate   ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Placa de           ?','','','mv_ch5','C',07,0,0,'G',bValid,"ZV4",cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Placa Ate          ?','','','mv_ch6','C',07,0,0,'G',bValid,"ZV4",cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Roteiro de         ?','','','mv_ch7','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Roteiro Ate        ?','','','mv_ch8','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR08')
	PutSx1(cPerg,'09','Dir Geração do Arq ?','','','mv_ch9','C',50,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR09')
	Pergunte(cPerg,.F.)
Return(Nil)      

STATIC FUNCTION SqlRot()
     
    Local cDtEntrini := DTOS(MV_PAR03)
    Local cDtEntrfin := DTOS(MV_PAR04)
    
	BeginSQL Alias "TRB"
			%NoPARSER% 
				SELECT SC5.C5_FILIAL, 
				       SC5.C5_ROTEIRO, 
				       SC5.C5_PLACA, 
				       SZK.ZK_DESTINO,
				       SZK.ZK_TPFRETE,
				       SZK.ZK_VALFRET,
				       SC5.C5_DTENTR,
				       SZK.ZK_HORASAI,
				       SZK.ZK_HORARET,
				       SZK.ZK_PBRUTO
				  FROM %Table:SC5% SC5, %Table:SZK% SZK
				  WHERE SC5.C5_FILIAL  >= %exp:MV_PAR01%
				    AND SC5.C5_FILIAL  <= %exp:MV_PAR02%
				    AND SC5.C5_DTENTR  >= %exp:cDtEntrini%
				    AND SC5.C5_DTENTR  <= %exp:cDtEntrfin%
				    AND SC5.C5_PLACA   >= %exp:MV_PAR05%
				    AND SC5.C5_PLACA   <= %exp:MV_PAR06%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO >= %exp:MV_PAR07%
				    AND SC5.C5_ROTEIRO <= %exp:MV_PAR08%
				    AND SC5.C5_NOTA    <> '' 
				    AND SC5.C5_SERIE   <> ''
				    AND SZK.ZK_PLACA    = SC5.C5_PLACA
				    AND SZK.ZK_DTENTR   = SC5.C5_DTENTR
				    AND SZK.ZK_ROTEIRO  = SC5.C5_ROTEIRO
				    AND SZK.%notDel%
				    AND SC5.%notDel%
				    
				GROUP BY SC5.C5_FILIAL, 
				         SC5.C5_ROTEIRO,
				         SC5.C5_PLACA,
				         SZK.ZK_DESTINO,
				         SZK.ZK_TPFRETE,
				         SZK.ZK_VALFRET,
				         SC5.C5_DTENTR,
				         SZK.ZK_HORASAI,
				         SZK.ZK_HORARET,
						 SZK.ZK_PBRUTO
						 
				ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO 
    EndSQl          

RETURN(NIL)    

STATIC FUNCTION SqlEntregas()
     
    BeginSQL Alias "TRC"
			%NoPARSER%
				SELECT SC5.C5_FILIAL,
				       SA1.A1_BAIRROE,
				       SA1.A1_MUNE,
					   SC5.C5_CLIENTE,
					   SC5.C5_LOJACLI,
					   SA1.A1_ENDENT,
					   SC5.C5_ROTEIRO, 
					   SA1.A1_SATIV1,
                	   SA1.A1_SATIV2, 
                	   SA1.A1_IMPENT, 
                	   SA1.A1_END,
					   SA1.A1_BAIRRO,
					   SA1.A1_XLONGIT,
	                   SA1.A1_XLATITU,
					   SUM(SC5.C5_PBRUTO) AS C5_PBRUTO,
					   SUM(SC6.C6_VALOR) AS C6_VALOR	      	
				  FROM %Table:SC5% SC5, %Table:SC6% SC6, %Table:SA1% SA1
				  WHERE SC5.C5_FILIAL   = %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntr%
				    AND SC5.C5_PLACA   >= %exp:MV_PAR05%
				    AND SC5.C5_PLACA   <= %exp:MV_PAR06%
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
							 SC5.C5_CLIENTE,
							 SC5.C5_LOJACLI,
							 SA1.A1_ENDENT,
							 SC5.C5_ROTEIRO,
							 SA1.A1_SATIV1,
                 	         SA1.A1_SATIV2, 
	                         SA1.A1_IMPENT,
	                         SA1.A1_END,
						     SA1.A1_BAIRRO,
						     SA1.A1_XLONGIT,
  	                         SA1.A1_XLATITU
							 
			      	ORDER BY SC5.C5_FILIAL, SC5.C5_ROTEIRO
			      	
	EndSQl          

RETURN(NIL)    	  

STATIC FUNCTION SqlNotas()      
     
    BeginSQL Alias "TRD"
			%NoPARSER%
				SELECT SF2.F2_CLIENTE,
				       SF2.F2_LOJA,
				       SA3.A3_SUPER,
				       SF2.F2_VEND1,
				       SF2.F2_DOC,
				       SF2.F2_PBRUTO,
				       SF2.F2_VALBRUT,
				       SF2.F2_SERIE,
				       SC5.C5_PRIOR,
				       SF2.F2_PLIQUI,
				       SC5.C5_SEQUENC
				  FROM %Table:SC5% SC5, %Table:SF2% SF2 
				  LEFT JOIN %Table:SA3% SA3
						ON SF2.F2_VEND1    = SA3.A3_COD
				       AND SA3.%notDel% 
				  WHERE SC5.C5_FILIAL   = %exp:cFil%
				    AND SC5.C5_DTENTR   = %exp:cDtEntr%
				    AND SC5.C5_PLACA   >= %exp:cPlaca%
				    AND SC5.C5_PLACA   <= %exp:cPlaca%
				    AND SC5.C5_PLACA   <> ''
				    AND SC5.C5_ROTEIRO  = %exp:cRoteiro%
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
				       SD2.D2_QTSEGUM,
				       SD2.D2_ITEM,
				       SD2.D2_PRCVEN
				  FROM %Table:SD2% SD2, %Table:SB1% SB1
				WHERE SD2.D2_FILIAL   = %exp:cFil%
				  AND SD2.D2_CLIENTE  = %exp:cCliente%
				  AND SD2.D2_LOJA     = %exp:cLojaCli%
				  AND SD2.D2_DOC      = %exp:cNota%
				  AND SD2.D2_SERIE    = %exp:cSerie%
				  AND SB1.B1_COD      = SD2.D2_COD
				  AND SD2.%notDel%
				  AND SB1.%notDel%
    EndSQl          				   
RETURN(NIL)    	  