#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADLOG006P
	Programa consumir de webservice ravex para baixa de devolucoes de notas fiscais 
	@author William Costa
	@since 11/06/2015
	@version 01
	@history chamado 052861 William Costa 23/10/2019 - Retirado todas as divisões por 1000 nas quantidades de devoluções
	@history chamado 052977 William Costa 30/10/2019 - Identificado erro para encontrar o produto o fator de conversão e tipo de conversão e alterado os campos de quantidade na devolução total e parcial
	@history ticket 68820 - Fernando Macieira - 09/03/2022 - Migração de quebra de peso entre ravex e protheus
	@history ticket 68820 - Fernando Macieira - 11/03/2022 - Function DelDupSZX (Exclui registros duplicados) + Function ChkDupSZX (via query pois já existe seek) + Inclusão PadR
	@history ticket 68820 - Fernando Macieira - 16/03/2022 - Novo campo ZD_BLQRAVE que será utilizado no job ADLOG006P (integrador RAVEX)
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history ticket TI    - Fernando Macieira - 23/03/2022 - Aumento tempo consulta retroativa e inibição da variável nCont3
	@history ticket 73148 - Everson           - 31/05/2022 - Adicionar demais códigos como quebra de peso.
/*/
User Function ADLOG006P()

	//Local nCont3 // @history ticket TI    - Fernando Macieira - 23/03/2022 - Aumento tempo consulta retroativa e inibição da variável nCont3

	Private nCont3 := 0

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADLOG006P", .T., .F.)
		ConOut("[ADLOG006P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut("INICIO DO SCHEDULE ADLOG006P")

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumir de webservice ravex para baixa de devolucoes de notas fiscais ')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	FOR nCont3 := 1 TO 2
		CRIAWEBSERVICE(nCont3)
	NEXT nCont3
	
	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
    logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	ConOut("FINAL DO SCHEDULE ADLOG006P")

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADLOG006P")

RETURN(NIL)	

STATIC FUNCTION CRIAWEBSERVICE(nCont3)

	oWs := WSSiviraFullWebService():New()

	oWs:cLogin := 'adoro_user_ws'
	oWs:cSenha := 'SdUdWSdA'
	 
   	If oWs:Autenticar()
	    // autenticação ok
	    oResp   := oWs:oWSAutenticarResult 
	    cMetodo := 'Autenticar' 
	    
	    IF oResp:NID == 2
	    
	    	RETORNAVIAGEM(nCont3)
	    
	    ENDIF
	    
	ENDIF

RETURN(NIL)     	  

STATIC FUNCTION RETORNAVIAGEM(nCont3)

	oWs:CCNPJEMISSOR       := '60037058000301'
	oWs:LVIAGEMFECHADAS    := IIF(nCont3 == 1,.F.,.T.) 
	oWs:LVIAGENSCANCELADAS := .F.
	oWs:NPERIODOHORAS      := 72 // 24 // debug - voltar! // @history ticket TI    - Fernando Macieira - 23/03/2022 - Aumento tempo consulta retroativa e inibição da variável nCont3

	If oWs:RetornarAnomalias()
	    // autenticação ok
	    oResp   := oWs:oWSRetornarAnomaliasResult
	    
	    IMPORTAXML()
	    
	Endif

RETURN(NIL)     	

STATIC FUNCTION IMPORTAXML()

	Local lExistSZX     := .f. // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Function ChkDupSZX (via query pois já existe seek)

	Local cCodQuebra    := AllTrim(cValToChar(GetMv("MV_#CODQDV",,"39/91"))) //Everson - 31/0/2022. Chamado 73148.

	Private nCont       := 0
	Private nCont2      := 0
	Private cTeste      := ''
	Private cRoteiro    := ''
	Private cMetodo     := ''
    Private nId         := 0
    Private	cNomMot     := ''
	Private cTelMot     := ''
	Private cEmlMot     := ''         
	Private cCPFM       := ''
	Private cCodCTRL    := ''
	Private cRespNome   := ''
	Private cDescMotiv  := '' 
	Private cCliente    := ''
	Private cLojaCli    := ''
	Private cNota       := ''
	Private cSerie      := ''
	Private cCodRespon  := ''
	Private nCodMotItem := ''
	Private nConversao  := 0
	Private cTipoConv   := ''
	Private aDev        := {}
	Private aDevolucoes := {}
	
	/////// ************INICIO CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
	IF LEN(oResp:OWSANOMALIA) > 0 
		IF oResp:OWSANOMALIA[1]:NIDVIAGEM <> -1 // VERIFICA SE EXISTE ERRO
	
			For nCont:= 1 To Len(oResp:OWSANOMALIA)  

				// @history ticket 68820 - Fernando Macieira - 09/03/2022 - Migração de quebra de peso entre ravex e protheus
				// debug - inibir
				/*
				If AllTrim(oResp:OWSANOMALIA[nCont]:CNUMERONF) == "2510865" .OR.;
				   AllTrim(oResp:OWSANOMALIA[nCont]:CNUMERONF) == "2510451"
					lDebug := .t.
				Else
					Loop
				EndIf
				*/
				// debug - inibir

                // ** INICIO VERIFICA SE A VIAGEM JA FOI ALTERADA ** //
				// CONFORME NOVA REGRA DA LOGISTICA SE A VIAGEM JA FOI ALTERADA
				// O WEBSERVICE NAO PODE ALTERAR MAIS NADA
				// CHAMADO 032731 WILLIAM COSTA

				//Conforme chamado 052861 na data de 23/10/2019, foi conversado com o Marcel e retirado a trava que
				//não deixa sobrepor dados de ocorrencia depois que a letra é trocado de O

				DBSELECTAREA("SZD")
				DbSetOrder(1) // ZD_FILIAL, ZD_NUMNF, ZD_SERIE, R_E_C_N_O_, D_E_L_E_T_
				IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
						  STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
						  
					//@history ticket 68820 - Fernando Macieira - 16/03/2022 - Novo campo ZD_BLQRAVE que será utilizado no job ADLOG006P (integrador RAVEX)
					If SZD->(FieldPos("ZD_BLQRAVE")) > 0
						If SZD->ZD_BLQRAVE == "S"
							Loop
						EndIf
					EndIf
					//

						  // @history ticket 68820 - Fernando Macieira - 09/03/2022 - Migração de quebra de peso entre ravex e protheus
						  /*
						  IF SZD->ZD_DEVTOT == 'P'
						  	LOOP // NAO DEIXA CONTINUAR O PROGRAMA
						  ENDIF	

						  IF SZD->ZD_DEVTOT == 'Q'
						  	LOOP // NAO DEIXA CONTINUAR O PROGRAMA // DEBUG - VOLTAR - NF 002499061
						  ENDIF	

						  IF SZD->ZD_DEVTOT == 'T'
						  	LOOP // NAO DEIXA CONTINUAR O PROGRAMA
						  ENDIF	
						  */
						  //

				ENDIF		  
				SZD->(dbCloseArea())		  
				
				// ** FINAL SE A VIAGEM JA FOI ALTERADA ** //
			
				Begin Transaction // @history ticket 68820 - Fernando Macieira - 09/03/2022 - Migração de quebra de peso entre ravex e protheus

					DBSELECTAREA("SC5")
					DbOrderNickName("SC5_F") 
					//achou a nota no sc5          
					IF DBSEEK(FWFILIAL("SC5")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),.T.) 

						//inicio criar uma ocorrencia 
						// ******* ALTERA VALORES DA TABELAS PARA ENTREGUE 
						DO CASE

							////////////////////////////////////////////////////////////////////////
							// ************************ INICIO DEVOLUCAO TOTAL ****************** //
							////////////////////////////////////////////////////////////////////////
							CASE oResp:OWSANOMALIA[nCont]:NTIPORETORNO == 1

								IF	RecLock("SC5",.F.)
										SC5->C5_MOK := '03'
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
										IF DBSEEK(FWFILIAL("ZVC")+cCPFM)
											cNomMot := ZVC->ZVC_MOTORI
											cTelMot := ZVC->ZVC_TELPRI
											cEmlMot := ZVC->ZVC_EMLMOT
										ENDIF  
									ENDIF  
								ENDIF     
								
								// NOME DO RESPONSAVEL E DESCRICAO DO MOTIVO
								//Buscar Nome do Responsavel
								DBSELECTAREA("SZU")
								DBSETORDER(2)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CSETOR))
									cRespNome  := SZU->ZU_DESCRI
									cCodRespon := SZU->ZU_COD
								ENDIF
								
								//Buscar Motivo
								DBSELECTAREA("SZS")
								DBSETORDER(1)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO))
									cDescMotiv := SZS->ZS_DESCRI
								ENDIF
								
								cCodCTRL := SUBSTR(FWFILIAL("SC5"),2,1) + ;
											SUBSTR(SC5->C5_NUM,6,1)     + ;
											SUBSTR(SC5->C5_NUM,5,1)     + ;
											SUBSTR(SC5->C5_NUM,4,1)     + ;
											SUBSTR(SC5->C5_NUM,3,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
									
								DBSELECTAREA("SZD")
								DBSETORDER(1)
								DBGOTOP()
								IF !DBSEEK(FWFILIAL("SZD") + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2))  
											
									RecLock("SZD",.T.)
										SZD->ZD_FILIAL	:= FWFILIAL("SZD")
										SZD->ZD_NUMNF	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
										SZD->ZD_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)
										SZD->ZD_CODCLI	:= SC5->C5_CLIENTE
										SZD->ZD_LOJA   	:= SC5->C5_LOJACLI
										SZD->ZD_NOMECLI	:= SC5->C5_NOMECLI   
										SZD->ZD_DTDEV	:= DATE()    
										SZD->ZD_RESPONS	:= cCodRespon
										SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
										SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
										SZD->ZD_RESPNOM	:= cRespNome
										SZD->ZD_DESCMOT	:= cDescMotiv
										SZD->ZD_PEDIDO	:= SC5->C5_NUM
										SZD->ZD_ROTEIRO	:= SC5->C5_ROTEIRO
										SZD->ZD_PLACA	:= SC5->C5_PLACA
										SZD->ZD_SEQUENC	:= SC5->C5_SEQUENC
										SZD->ZD_DEVTOT  := 'T'
										SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
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
										SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
										
									MsUnLock()
								ENDIF
								SZD->(dbCloseArea())
								
								// *********** FINAL PARA CARREGAR O SZD  ***********************  //
								DBSELECTAREA("SZD")
								DbSetOrder(1) 
								IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
											
									IF RecLock("SZD",.F.)      
											
											
											SZD->ZD_RESPONS	:= cCodRespon
											SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
											SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
											SZD->ZD_RESPNOM	:= cRespNome
											SZD->ZD_DESCMOT	:= cDescMotiv
											SZD->ZD_DEVTOT  := 'T'
											SZD->ZD_CONTROL := cCodCTRL
											SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
											SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
											
										MsUnlock()
										
									ENDIF	
												
								ENDIF	
								SZD->(dbCloseArea()) 
								
								For nCont2:= 1 To Len(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA)
								
									SQLITEM(FWFILIAL("SC5"),                                                ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),  ;
											SC5->C5_CLIENTE,                                     ;
											SC5->C5_LOJACLI,                                     ;
											oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											
									While TRB->(!EOF())
						
										DBSELECTAREA("SZX")
										DBSETORDER(2)
										IF !DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1]) + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.) // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
											
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											// @history ticket 68820 - Fernando Macieira - 11/03/2022 - Function ChkDupSZX (via query pois já existe seek)
											lExistSZX := ChkDupSZX(FWFILIAL("SZX"), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2), oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)

											If !lExistSZX

												RecLock("SZX",.T.)
													SZX->ZX_FILIAL	:= FWFILIAL("SZX")
													SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
													SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
													SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
													SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
													SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
													SZX->ZX_QTDE	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA
													SZX->ZX_QTDEV2U	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao)
													SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
													SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
													SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
													SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
													SZX->ZX_OBSER	:= ''  // Observacao
													SZX->ZX_TOTAL	:= TRB->D2_TOTAL        // Valor total da devolução
													SZX->ZX_QUEBRA  := 0  // QUEBRA
													SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												MsUnLock()
											
											EndIf

										ENDIF	
										SZX->(dbCloseArea())
														
										DBSELECTAREA("SZX")
										DBSETORDER(2)
										IF DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1]) + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.) // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
										
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											RecLock("SZX",.F.)
											
												SZX->ZX_FILIAL	:= FWFILIAL("SZX")
												SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
												SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
												SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
												SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
												SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
												SZX->ZX_QTDE	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA // Quantidade Devolvida
												SZX->ZX_QTDEV2U	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao)  // Quantidade Devolvida
												SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
												SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
												SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
												SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
												SZX->ZX_OBSER	:= ''  // Observacao
												SZX->ZX_TOTAL	:= TRB->D2_TOTAL        // Valor total da devolução
												SZX->ZX_QUEBRA  := 0  // QUEBRA
												SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												
											MsUnLock()                                  
										ENDIF	
										SZX->(dbCloseArea())
											
										TRB->(dbSkip())
									ENDDO
									TRB->(dbCloseArea())

								NEXT
								
								// **************** INICIO VERIFICA APROVACAO ******************** //		
						
								VerificaAprovacao(FWFILIAL("SC5"),STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),;
													STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2))
						
								// **************** FINAL VERIFICA APROVACAO ******************** //
								
								cMetodo := 'Devolver'
								nId     := 1
								aDev  := {}
								Aadd(aDev,STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9))
								Aadd(aDevolucoes,aDev)
								
							// **************** FINAL DEVOLUCAO TOTAL    ******************* //
							
							///////////////////////////////////////////////////////////////////
							// **************** INICIO DEVOLUCAO PARCIAL ******************* //
							///////////////////////////////////////////////////////////////////
							CASE oResp:OWSANOMALIA[nCont]:NTIPORETORNO  == 2  .AND. ;
								!(Alltrim(cValToChar(oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO)) $cCodQuebra) //Everson - 31/05/2021. Chamado 73505.
								
								IF	RecLock("SC5",.F.)
										SC5->C5_MOK := '03'
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
										IF DBSEEK(FWFILIAL("ZVC")+cCPFM)
											cNomMot := ZVC->ZVC_MOTORI
											cTelMot := ZVC->ZVC_TELPRI
											cEmlMot := ZVC->ZVC_EMLMOT
										ENDIF  
									ENDIF  
								ENDIF     
								
								// NOME DO RESPONSAVEL E DESCRICAO DO MOTIVO
								//Buscar Nome do Responsavel
								DBSELECTAREA("SZU")
								DBSETORDER(2)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CSETOR))
									cRespNome  := SZU->ZU_DESCRI
									cCodRespon := SZU->ZU_COD
								ENDIF
								
								//Buscar Motivo
								DBSELECTAREA("SZS")
								DBSETORDER(1)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO))
									cDescMotiv := SZS->ZS_DESCRI
								ENDIF
								
								cCodCTRL := SUBSTR(FWFILIAL("SC5"),2,1) + ;
											SUBSTR(SC5->C5_NUM,6,1)     + ;
											SUBSTR(SC5->C5_NUM,5,1)     + ;
											SUBSTR(SC5->C5_NUM,4,1)     + ;
											SUBSTR(SC5->C5_NUM,3,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
									
								DBSELECTAREA("SZD")
								DBSETORDER(1)
								DBGOTOP()
								IF !DBSEEK(FWFILIAL("SZD") + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2))  
											
									RecLock("SZD",.T.)
										SZD->ZD_FILIAL	:= FWFILIAL("SZD")
										SZD->ZD_NUMNF	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
										SZD->ZD_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)
										SZD->ZD_CODCLI	:= SC5->C5_CLIENTE
										SZD->ZD_LOJA   	:= SC5->C5_LOJACLI
										SZD->ZD_NOMECLI	:= SC5->C5_NOMECLI   
										SZD->ZD_DTDEV	:= DATE()    
										SZD->ZD_RESPONS	:= cCodRespon
										SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
										SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
										SZD->ZD_RESPNOM	:= cRespNome
										SZD->ZD_DESCMOT	:= cDescMotiv
										SZD->ZD_PEDIDO	:= SC5->C5_NUM
										SZD->ZD_ROTEIRO	:= SC5->C5_ROTEIRO
										SZD->ZD_PLACA	:= SC5->C5_PLACA
										SZD->ZD_SEQUENC	:= SC5->C5_SEQUENC
										SZD->ZD_DEVTOT  := 'P'
										SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
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
										SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
										
									MsUnLock()
								ENDIF
								SZD->(dbCloseArea())
								
								// *********** FINAL PARA CARREGAR O SZD  ***********************  //
								DBSELECTAREA("SZD")
								DbSetOrder(1) 
								IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
											
									IF RecLock("SZD",.F.)      
											
											
											SZD->ZD_RESPONS	:= cCodRespon
											SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
											SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
											SZD->ZD_RESPNOM	:= cRespNome
											SZD->ZD_DESCMOT	:= cDescMotiv
											SZD->ZD_DEVTOT  := 'P'
											SZD->ZD_CONTROL := cCodCTRL
											SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
											SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
											
										MsUnlock()
										
									ENDIF	
												
								ENDIF	
								SZD->(dbCloseArea()) 
								
								For nCont2:= 1 To Len(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA)
								
									SQLITEM(FWFILIAL("SC5"),                                                ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),  ;
											SC5->C5_CLIENTE,                                     ;
											SC5->C5_LOJACLI,                                     ;
											oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											
									While TRB->(!EOF())
						
										DBSELECTAREA("SZX")
										DBSETORDER(2)
										IF !DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1]) + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.) // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
										
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											// @history ticket 68820 - Fernando Macieira - 11/03/2022 - Function ChkDupSZX (via query pois já existe seek)
											lExistSZX := ChkDupSZX(FWFILIAL("SZX"), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2), oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)

											If !lExistSZX

												RecLock("SZX",.T.)
													nCodMotItem     := VAL(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGOMOTIVOITEM)
													SZX->ZX_FILIAL	:= FWFILIAL("SZX")
													SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
													SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
													SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
													SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
													SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
													SZX->ZX_QTDE	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA
													SZX->ZX_QTDEV2U	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao)
													SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
													SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
													SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
													SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
													SZX->ZX_OBSER	:= ''  // Observacao
													SZX->ZX_TOTAL	:= TRB->D2_PRCVEN * ( oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA)         // Valor total da devolução
													SZX->ZX_QUEBRA  := IIF(nCodMotItem <> 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NPESOBRUTODEVOLVIDO))  // QUEBRA
													SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												MsUnLock()

											EndIf

										ENDIF	
										SZX->(dbCloseArea())
										
										DBSELECTAREA("SZX")
										DBSETORDER(2)
										IF DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1]) + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.)  // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
										
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											RecLock("SZX",.F.)
												
												nCodMotItem     := VAL(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGOMOTIVOITEM)
												SZX->ZX_FILIAL	:= FWFILIAL("SZX")
												SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
												SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
												SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
												SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
												SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
												SZX->ZX_QTDE	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA
												SZX->ZX_QTDEV2U	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao)
												SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
												SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
												SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
												SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
												SZX->ZX_OBSER	:= ''  // Observacao
												SZX->ZX_TOTAL	:= TRB->D2_PRCVEN * ( oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA)       // Valor total da devolução
												SZX->ZX_QUEBRA  := IIF(nCodMotItem <> 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NPESOBRUTODEVOLVIDO))  // QUEBRA  // QUEBRA
												SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												
											MsUnLock()                                  
										ENDIF	
										SZX->(dbCloseArea())
											
										TRB->(dbSkip())
									ENDDO
									TRB->(dbCloseArea())

								NEXT
								
								cMetodo := 'Devolver'
								nId     := 1
								aDev  := {}
								Aadd(aDev,STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9))
								Aadd(aDevolucoes,aDev)
								
							// **************** FINAL DEVOLUCAO PARCIAL ******************** //
														
							//////////////////////////////////////////////////////////////////
							// **************** INICIO DEVOLUCAO QUEBRA ******************* //
							//////////////////////////////////////////////////////////////////
							CASE oResp:OWSANOMALIA[nCont]:NTIPORETORNO  == 2  .AND. ;
								 (Alltrim(cValToChar(oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO)) $cCodQuebra)  //Everson - 31/05/2021. Chamado 73505.
								
								IF	RecLock("SC5",.F.)
										SC5->C5_MOK := '06'
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
										IF DBSEEK(FWFILIAL("ZVC")+cCPFM)
											cNomMot := ZVC->ZVC_MOTORI
											cTelMot := ZVC->ZVC_TELPRI
											cEmlMot := ZVC->ZVC_EMLMOT
										ENDIF  
									ENDIF  
								ENDIF     
								
								// NOME DO RESPONSAVEL E DESCRICAO DO MOTIVO
								//Buscar Nome do Responsavel
								DBSELECTAREA("SZU")
								DBSETORDER(2)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CSETOR))
									cRespNome  := SZU->ZU_DESCRI
									cCodRespon := SZU->ZU_COD
								ENDIF
								
								//Buscar Motivo
								DBSELECTAREA("SZS")
								DBSETORDER(1)
								IF DBSEEK(xfilial()+alltrim(oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO))
									cDescMotiv := SZS->ZS_DESCRI
								ENDIF
								
								cCodCTRL := SUBSTR(FWFILIAL("SC5"),2,1) + ;
											SUBSTR(SC5->C5_NUM,6,1)     + ;
											SUBSTR(SC5->C5_NUM,5,1)     + ;
											SUBSTR(SC5->C5_NUM,4,1)     + ;
											SUBSTR(SC5->C5_NUM,3,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											SUBSTR(SC5->C5_NUM,2,1)     + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
									
								DBSELECTAREA("SZD")
								DBSETORDER(1)
								DBGOTOP()
								IF !DBSEEK(FWFILIAL("SZD") + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2))  
											
									RecLock("SZD",.T.)
										SZD->ZD_FILIAL	:= FWFILIAL("SZD")
										SZD->ZD_NUMNF	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
										SZD->ZD_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)
										SZD->ZD_CODCLI	:= SC5->C5_CLIENTE
										SZD->ZD_LOJA   	:= SC5->C5_LOJACLI
										SZD->ZD_NOMECLI	:= SC5->C5_NOMECLI   
										SZD->ZD_DTDEV	:= DATE()    
										SZD->ZD_RESPONS	:= cCodRespon
										SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
										SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
										SZD->ZD_RESPNOM	:= cRespNome
										SZD->ZD_DESCMOT	:= cDescMotiv
										SZD->ZD_PEDIDO	:= SC5->C5_NUM
										SZD->ZD_ROTEIRO	:= SC5->C5_ROTEIRO
										SZD->ZD_PLACA	:= SC5->C5_PLACA
										SZD->ZD_SEQUENC	:= SC5->C5_SEQUENC
										SZD->ZD_DEVTOT  := 'Q'
										SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
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
										SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
										
									MsUnLock()
								ENDIF
								SZD->(dbCloseArea())
								
								// *********** FINAL PARA CARREGAR O SZD  ***********************  //
								DBSELECTAREA("SZD")
								DbSetOrder(1) 
								IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
											
									IF RecLock("SZD",.F.)      
											
											
											SZD->ZD_RESPONS	:= cCodRespon
											SZD->ZD_MOTIVO	:= oResp:OWSANOMALIA[nCont]:CCODIGOMOTIVO
											SZD->ZD_AUTNOME	:= oResp:OWSANOMALIA[nCont]:COPERADOR
											SZD->ZD_RESPNOM	:= cRespNome
											SZD->ZD_DESCMOT	:= cDescMotiv
											SZD->ZD_DEVTOT  := 'Q'
											SZD->ZD_CONTROL := cCodCTRL
											SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
											SZD->ZD_SENHA   := oResp:OWSANOMALIA[nCont]:CSENHACONTROLE
											
										MsUnlock()
										
									ENDIF	
												
								ENDIF	
								SZD->(dbCloseArea()) 
								
								For nCont2:= 1 To Len(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA)
								
									SQLITEM(FWFILIAL("SC5"),                                                ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), ;
											STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),  ;
											SC5->C5_CLIENTE,                                     ;
											SC5->C5_LOJACLI,                                     ;
											oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											
									While TRB->(!EOF())
						
										DBSELECTAREA("SZX")
										DBSETORDER(2) // ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, R_E_C_N_O_, D_E_L_E_T_
										IF !DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1]) + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.) // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
										
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)

											// @history ticket 68820 - Fernando Macieira - 11/03/2022 - Function ChkDupSZX (via query pois já existe seek)
											lExistSZX := ChkDupSZX(FWFILIAL("SZX"), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9), STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2), oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)

											If !lExistSZX

												RecLock("SZX",.T.)
													nCodMotItem     := VAL(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGOMOTIVOITEM)
													SZX->ZX_FILIAL	:= FWFILIAL("SZX")
													SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
													SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
													SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
													SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
													SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
													SZX->ZX_QTDE	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao) // Quantidade Devolvida
													SZX->ZX_QTDEV2U	:= IIF(nCodMotItem == 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA))  // Quantidade Devolvida
													SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
													SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
													SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
													SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
													SZX->ZX_OBSER	:= ''  // Observacao
													SZX->ZX_TOTAL	:= TRB->D2_PRCVEN * ( oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA)        // Valor total da devolução
													SZX->ZX_QUEBRA  := IIF(nCodMotItem <> 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NPESOBRUTODEVOLVIDO ))  // QUEBRA  // WILLIAM COSTA 22/10/2019
													SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												MsUnLock()

											EndIf
											
											// ** INICIO SE TIVER ALGUM ITEM DIFERENTE DE QUEBRA O SZD VIRA P **//		
											IF nCodMotItem <> 39
											
												IF	RecLock("SC5",.F.)
								
													SC5->C5_MOK := '03'
							
													MsUnlock()            
											
												ENDIF
													
												DBSELECTAREA("SZD")
												DbSetOrder(1) 
												IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
														STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
														
													IF RecLock("SZD",.F.)      
															
															SZD->ZD_DEVTOT  := 'P'
															SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
															
														MsUnlock()
													ENDIF	
												ENDIF	
												SZD->(dbCloseArea())	
											ENDIF
												
											// ** FINAL SE TIVER ALGUM ITEM DIFERENTE DE QUEBRA O SZD VIRA P ** //		
										ENDIF	
										SZX->(dbCloseArea())
										
										DBSELECTAREA("SZX")
										DBSETORDER(2)
										IF DBSEEK(FWFILIAL("SZX") + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),TamSX3("ZX_NF")[1])            + ;
													PadR(STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),TamSX3("ZX_SERIE")[1]) + ;
													PadR(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO,TamSX3("ZX_CODPROD")[1]), .T.) // @history ticket 68820 - Fernando Macieira - 11/03/2022 - Inclusão PadR
										
											nConversao := 1
											nConversao := FatorConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											cTipoConv  := ''
											cTipoConv  := TipoConversao(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO)
											
											RecLock("SZX",.F.)
											
												nCodMotItem     := VAL(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGOMOTIVOITEM)
												SZX->ZX_FILIAL	:= FWFILIAL("SZX")
												SZX->ZX_NF		:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9)
												SZX->ZX_SERIE	:= STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2)  // Serie
												SZX->ZX_UNIDADE	:= TRB->D2_UM  // Primeira unidade de medida
												SZX->ZX_QTSEGUM	:= TRB->D2_QTSEGUM  // Quantidade Devolvida Segunda Unidade
												SZX->ZX_SEGUM	:= TRB->D2_SEGUM   // Segunda Unidade de medida
												SZX->ZX_QTDE	:= IIF(cTipoConv == 'D',(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) * nConversao, (oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA) / nConversao) // Quantidade Devolvida
												SZX->ZX_QTDEV2U	:= IIF(nCodMotItem == 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA))  // Quantidade Devolvida
												SZX->ZX_QTDEV1U	:= 0  // Quantidade Devolvida
												SZX->ZX_CODPROD	:= oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO  // Codigo do Produto
												SZX->ZX_DESCRIC	:= Posicione("SB1",1,xFilial("SB1") + oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:CCODIGO, "B1_DESC")  // Descricao do Produto
												SZX->ZX_MOTIVO	:= ''  // Motivo da Ocorrencia
												SZX->ZX_OBSER	:= ''  // Observacao
												SZX->ZX_TOTAL	:= TRB->D2_PRCVEN * ( oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NQTDEDEVOLVIDA)       // Valor total da devolução
												SZX->ZX_QUEBRA  := IIF(nCodMotItem <> 39,0,(oResp:OWSANOMALIA[nCont]:OWSITENSDEVOLVIDOS:OWSITEMANOMALIA[nCont2]:NPESOBRUTODEVOLVIDO))  // QUEBRA  // WILLIAM COSTA 22/10/2019
												SZX->ZX_ITEMNF  := TRB->D2_ITEM  // ITEM NF
												
											MsUnLock()                                  
											// ** INICIO SE TIVER ALGUM ITEM DIFERENTE DE QUEBRA O SZD VIRA P **//		
											IF nCodMotItem <> 39
											
												IF	RecLock("SC5",.F.)
								
													SC5->C5_MOK := '03'
							
													MsUnlock()            
											
												ENDIF
													
												DBSELECTAREA("SZD")
												DbSetOrder(1) 
												IF DBSEEK(FWFILIAL("SZD")+STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9) + ;
														STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2),.T.) 
														
													IF RecLock("SZD",.F.)      
															
															SZD->ZD_DEVTOT  := 'P'
															SZD->ZD_OBSER	:= oResp:OWSANOMALIA[nCont]:COBSERVACAO
															
														MsUnlock()
													ENDIF	
												ENDIF	
												SZD->(dbCloseArea())	
											ENDIF
												
											// ** FINAL SE TIVER ALGUM ITEM DIFERENTE DE QUEBRA O SZD VIRA P ** //		
										ENDIF	
										SZX->(dbCloseArea())
											
										TRB->(dbSkip())
									ENDDO
									TRB->(dbCloseArea())

								NEXT
								
								// **************** INICIO VERIFICA APROVACAO ******************** //		
						
								VerificaAprovacao(FWFILIAL("SC5"),STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9),;
													STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CSERIENF),2))
						
								// **************** FINAL VERIFICA APROVACAO ******************** //
								
								cMetodo := 'Devolver'
								nId     := 1
								aDev    := {}
								Aadd(aDev,STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9))
								Aadd(aDevolucoes,aDev)
							
							// **************** FINAL DEVOLUCAO QUEBRA ******************** //
							
							OTHERWISE
								cMetodo := 'Devolver'
								nId     := -1
								EmailViagem(cMetodo,nId,'000000000 - 1-) ERRO WEBSERVICE NÃO É DEVOLUÇÃO')	

						ENDCASE

					ELSE
					
						cMetodo := 'Devolver'
						nId     := -1
						EmailViagem(cMetodo,nId,STRZERO(VAL(oResp:OWSANOMALIA[nCont]:CNUMERONF),9))
						
					ENDIF 
					SC5->(dbCloseArea())

				End Transaction // @history ticket 68820 - Fernando Macieira - 09/03/2022 - Migração de quebra de peso entre ravex e protheus
		
			NEXT  
		
		ELSE
		
			cMetodo := 'Devolver'
		    nId     := -1
		    EmailViagem(cMetodo,nId,'000000000 - 1-) Erro WEBSERVICE VAZIO - SEM VIAGENS')
			
		ENDIF

	ELSE 
	
		//cMetodo := 'Devolver'
	    //nId     := -1
	    //EmailViagem(cMetodo,nId,'000000000 - 2-) Erro WEBSERVICE VAZIO - SEM VIAGENS')
	    
    ENDIF
    
	/////// ************FINAL CRIA VETOR E VARIAVEIS DE ENTREGA****************************************** //
	
	IF LEN(aDevolucoes) > 0
    
    	EmailViagem(cMetodo,nId,'Devolucao')
    
    ENDIF   

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
	   cSubject := "WEBSERVICE DEVOLUÇÃO"          
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
	cRet += "'><b>WEBSERVICE DEVOLUÇÃO............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
	IF _cStatEml == 'Devolver' .AND. nId == 1 // viagem ok
 	
	   cRet += " WEBSERVICE DEVOLUÇÃO COM SUCESSO"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   FOR nContEmail:=1 TO LEN(aDevolucoes)
	   
	   		cRet += 'Nota Fiscal: ' + aDevolucoes[nContEmail][1] + ' Devolvida.' + "<br>"
	
	   NEXT
		
	ENDIF	
	
	IF (_cStatEml == 'Devolver' .AND. nId == -1) .OR. ;
	   (_cStatEml == 'Devolver' .AND. nId == 0 )      // Viagem com erro
 	
	   cRet += " WEBSERVICE DEVOLUÇÃO COM ERRO, favor verificar"
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

STATIC FUNCTION VerificaAprovacao(cFil,cNota,cSerie)

	//TRECHO DO FONTE PEGADO DO PROGRAMA AD0019 e sera ajustado para o RAVEX
    
    Local _nValTDV    := 0   //valor total da devolução...
    Local _nQTTot     := 0   //quantidade total pedido
    Local _nQBTot     := 0   //quantidade total quebra 
    Local _lQuebra    := .F. //valida se ha quebra ou não...
    Local _cPrcVen    := 0 
    Local _nQtd1Unid  := 0 
    Local _cTotal     := 0  
    Local _nValDesc   := 0 
    Local _nValNF     := 0 
    Local _cRepresent := '' 
    Local _cSuperv    := '' 
    Local _cSupervi   := ''
    Local _cNomResp   := ''   
    
    SQLAPROV2(cFil,cNota,cSerie)
    
    While TRD->(!EOF())
    				
    	_cPrcVen   := TRD->D2_PRCVEN 
    	_nQtd1Unid := (TRD->ZX_QTDEV1U/TRD->ZX_QTSEGUM) * TRD->ZX_QTDE
		_cTotal    :=_cPrcVen*_nQtd1Unid
		
		IF TRD->ZX_QUEBRA > 0     //houve quebra!!!
			_nValTDV += _cPrcVen * TRD->ZX_QUEBRA   // !!!!!! Mauricio - preciso verificar aqui unidade de medida se esta correta !!!!!!!!
			_nQTTot  += TRD->D2_QUANT //IIF(TRD->ZX_QTDEV1U > 0,TRD->ZX_QTDEV1U,TRD->ZX_QTDE)
			_nQBTot  += TRD->ZX_QUEBRA
		ENDIF
	       	
        TRD->(dbSkip())
	ENDDO
	TRD->(dbCloseArea()) 
	
	
	SQLAPROV1(cFil,cNota,cSerie)
    
    While TRC->(!EOF())
    	
    	BEGIN TRANSACTION
	    	IF _nValTDV                 == 0    .AND. ;
	    	   TRC->ZD_DEVTOT           == 'T'  .AND. ;
	    	   ALLTRIM(TRC->ZD_RESPONS) == '08' //Devolução Total sem quebra, responsavel transportadora = 3% NF
				//3% NF somente para transportador
				//Busco valor total da NF para aplicar 3%
				DBSELECTAREA("SF2")
				DBSETORDER(1)
				IF DBSEEK(xFilial("SF2")+TRC->ZD_NUMNF+TRC->ZD_SERIE+TRC->ZD_CODCLI+TRC->ZD_LOJA)
					_nValDesc := (SF2->F2_VALBRUT * 0.03)
					_nValNF   := SF2->F2_VALBRUT
				ELSE
					_nValDesc := 0
				ENDIF
				
				//gravo na tabela para aprovação
				//12/06/13 - em virtude de mais um processo de aprovacao e controle( do vendedor) foi quebrado controle de aprovação para
				//transportador, cliente, vendedor em um registro para cada processo. E criado indice para os campos APVTPT,APVNCC e APVVDD.
				//tambem implementado consistencia para não gerar registro de um processo ja gerado anteriormente(Alteração nas ocorrencias).
				//se ja existir registro na ZZE não grava um novo.
				IF _nValDesc > 0
					DBSELECTAREA("ZZE")
					DBSETORDER(3)
					DBGOTOP()
					IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //transportador ordem 3
						RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
							ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
							ZZE->ZZE_LOJA   := TRC->ZD_LOJA
							ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
							ZZE->ZZE_SERIE  := TRC->ZD_SERIE
							ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
							ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
							//ZZE->ZZE_OCORR  :=
							ZZE->ZZE_OBS    := TRC->ZD_OBSER
							ZZE->ZZE_APVTPT := "S"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "N"
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValDesc
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							
						ZZE->(MSunlock())
					ELSE
					   //MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto transportador","ATenção")
					ENDIF
				ENDIF
			ELSEIF _nValTDV                 == 0   .AND.;
			       TRC->ZD_DEVTOT           == 'T' .AND.;
			       ALLTRIM(TRC->ZD_RESPONS) == '06' //Sem quebra e com responsabilidade comercial(desconto vendedor somente R$40)
			       
				_cRepresent := TRC->ZD_VEND
				_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_CODSUP")        // supervisor para aprovação
				_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")          //codigo de usuario do supervisor
				
				DBSELECTAREA("SF2")
				DBSETORDER(1)
				IF DBSEEK(xFilial("SF2")+TRC->ZD_NUMNF+TRC->ZD_SERIE+TRC->ZD_CODCLI+TRC->ZD_LOJA)				
					_nValNF := SF2->F2_VALBRUT
				ELSE
					_nValNF := 0
				ENDIF
				DBSELECTAREA("ZZE")
				DBSETORDER(5)
				DBGOTOP()
				IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //vendedor ordem 5
					RecLock("ZZE",.T.)
						ZZE->ZZE_Filial := xFilial("ZZE")
						ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
						ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
						ZZE->ZZE_LOJA   := TRC->ZD_LOJA
						ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
						ZZE->ZZE_SERIE  := TRC->ZD_SERIE
						ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
						ZZE->ZZE_QUANT  := _nQTTot
						ZZE->ZZE_VLRNF  := _nValNF
						ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
						ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
						ZZE->ZZE_OBS    := TRC->ZD_OBSER
						ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
						ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
						ZZE->ZZE_APVVDD := "S"   //Flag para desconto do vendedor...
						ZZE->ZZE_QTQBRA := _nQBTot
						ZZE->ZZE_VLDESC := 40
						ZZE->ZZE_DTDISP := Date()
						ZZE->ZZE_HRDISP := time()
						ZZE->ZZE_VEND   := TRC->ZD_VEND
						ZZE->ZZE_USSUPE := _cSupervi
						
					ZZE->(MSunlock())
				ELSE
					//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto vendedor","ATenção")
				ENDIF
			ELSEIF _nValTDV                 > 0 .AND. ;
			      ALLTRIM(TRC->ZD_RESPONS) == '08'  //Quebra com responsabilidade do transportador = 100 % quebra.
				//100 % da quebra para transportador e NCC 100% da quebra para cliente
				//Busco valor total da NF para aplicar 3%
				DBSELECTAREA("SF2")
				DBSETORDER(1)
				IF DBSEEK(xFilial("SF2")+TRC->ZD_NUMNF+TRC->ZD_SERIE+TRC->ZD_CODCLI+TRC->ZD_LOJA)
					_nValNF   := SF2->F2_VALBRUT
				ELSE
					_nValNF := 0
				ENDIF
				
				//gravo na tabela para aprovação
				DBSELECTAREA("ZZE")
				DBSETORDER(3)
				DBGOTOP()
				IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //transportador ordem 3
					RecLock("ZZE",.T.)
						ZZE->ZZE_Filial := xFilial("ZZE")
						ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
						ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
						ZZE->ZZE_LOJA   := TRC->ZD_LOJA
						ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
						ZZE->ZZE_SERIE  := TRC->ZD_SERIE
						ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
						ZZE->ZZE_QUANT  := _nQTTot
						ZZE->ZZE_VLRNF  := _nValNF
						ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
						ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
						ZZE->ZZE_OBS    := TRC->ZD_OBSER
						ZZE->ZZE_APVTPT := "S"   //flag para aprovação de desconto para transportador
						ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
						ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
						ZZE->ZZE_QTQBRA := _nQBTot
						ZZE->ZZE_VLDESC := _nValTDV
						ZZE->ZZE_DTDISP := Date()
						ZZE->ZZE_HRDISP := time()
						
					ZZE->(MSunlock())
				ELSE
					//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto transportador","ATenção")
				ENDIF
				DBSELECTAREA("ZZE")
				DBSETORDER(4)
				DBGOTOP()
				IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //cliente ordem 4
					RecLock("ZZE",.T.)
						ZZE->ZZE_Filial := xFilial("ZZE")
						ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
						ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
						ZZE->ZZE_LOJA   := TRC->ZD_LOJA
						ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
						ZZE->ZZE_SERIE  := TRC->ZD_SERIE
						ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
						ZZE->ZZE_QUANT  := _nQTTot
						ZZE->ZZE_VLRNF  := _nValNF
						ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
						ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
						ZZE->ZZE_OBS    := TRC->ZD_OBSER
						ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
						ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
						ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
						ZZE->ZZE_QTQBRA := _nQBTot
						ZZE->ZZE_VLDESC := _nValTDV
						ZZE->ZZE_DTDISP := Date()
						ZZE->ZZE_HRDISP := time()
						
					ZZE->(MSunlock())
				ELSE
					//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","ATenção")
				ENDIF
			ELSEIF _nValTDV                   > 0 .AND.; 
			       !ALLTRIM(TRC->ZD_RESPONS) == '08' //Quebra sem responsabilidade do transportador
				IF ALLTRIM(TRC->ZD_RESPONS) == '06' //Responsabilidade comercial  desconto para vendedor
				
					//NCC 100 % da quebra para cliente.
					DBSELECTAREA("SF2")
					DBSETORDER(1)
					
					IF DBSEEK(xFilial("SF2")+TRC->ZD_NUMNF+TRC->ZD_SERIE+TRC->ZD_CODCLI+TRC->ZD_LOJA)
						_nValNF   := SF2->F2_VALBRUT
					ELSE
						_nValNF := 0
					ENDIF
					
					_cRepresent := TRC->ZD_VEND
					_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_CODSUP")        // supervisor para aprovação
					_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")          //codigo de usuario do supervisor
					
					//gravo na tabela para aprovação
					DBSELECTAREA("ZZE")
					DBSETORDER(5)
					DBGOTOP()
					IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //vendedor ordem 5
						RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
							ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
							ZZE->ZZE_LOJA   := TRC->ZD_LOJA
							ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
							ZZE->ZZE_SERIE  := TRC->ZD_SERIE
							ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
							ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
							ZZE->ZZE_OBS    := TRC->ZD_OBSER
							ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "N"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "S"   //flag para aprovacao desconto ao vendedor
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValTDV
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							ZZE->ZZE_VEND   := TRC->ZD_VEND
							ZZE->ZZE_USSUPE := _cSupervi
							
						ZZE->(MSunlock())
					ELSE
						//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto vendedor","ATenção")
					ENDIF
					
					DBSELECTAREA("ZZE")
					DBSETORDER(4)
					DBGOTOP()
					IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //cliente ordem 4
						RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
							ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
							ZZE->ZZE_LOJA   := TRC->ZD_LOJA
							ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
							ZZE->ZZE_SERIE  := TRC->ZD_SERIE
							ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
							ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
							ZZE->ZZE_OBS    := TRC->ZD_OBSER
							ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValTDV
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							ZZE->ZZE_VEND   := TRC->ZD_VEND
							ZZE->ZZE_USSUPE := _cSupervi
							
						ZZE->(MSunlock())
					ELSE
						//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","ATenção")
					ENDIF
				ELSE
					//NCC 100 % da quebra para cliente.
					DBSELECTAREA("SF2")
					DBSETORDER(1)
					IF DBSEEK(xFilial("SF2")+TRC->ZD_NUMNF+TRC->ZD_SERIE+TRC->ZD_CODCLI+TRC->ZD_LOJA)
						_nValNF   := SF2->F2_VALBRUT
					ELSE
						_nValNF := 0
					ENDIF
					
					//gravo na tabela para aprovação
					DBSELECTAREA("ZZE")
					DBSETORDER(4)
					DBGOTOP()
					IF !(DBSEEK(xFilial("ZZE")+TRC->ZD_NUMNF+TRC->ZD_SERIE+"S"))  //Cliente ordem 4
						RecLock("ZZE",.T.)
							ZZE->ZZE_Filial := xFilial("ZZE")
							ZZE->ZZE_PEDIDO := TRC->ZD_PEDIDO
							ZZE->ZZE_CODCLI := TRC->ZD_CODCLI
							ZZE->ZZE_LOJA   := TRC->ZD_LOJA
							ZZE->ZZE_NUMNF  := TRC->ZD_NUMNF
							ZZE->ZZE_SERIE  := TRC->ZD_SERIE
							ZZE->ZZE_NOME   := TRC->ZD_NOMECLI
							ZZE->ZZE_QUANT  := _nQTTot
							ZZE->ZZE_VLRNF  := _nValNF
							ZZE->ZZE_DTDEV  := STOD(TRC->ZD_DTDEV)
							ZZE->ZZE_MOTIVO := TRC->ZD_DESCMOT
							ZZE->ZZE_OBS    := TRC->ZD_OBSER
							ZZE->ZZE_APVTPT := "N"   //flag para aprovação de desconto para transportador
							ZZE->ZZE_APVNCC := "S"   //flag para aprovação de NCC para o cliente
							ZZE->ZZE_APVVDD := "N"   //flag para aprovacao desconto ao vendedor
							ZZE->ZZE_QTQBRA := _nQBTot
							ZZE->ZZE_VLDESC := _nValTDV
							ZZE->ZZE_DTDISP := Date()
							ZZE->ZZE_HRDISP := time()
							
						ZZE->(MSunlock())
					Else
						//MsgInfo("Ja existe processo de aprovação para esta NF/Serie/desconto cliente","ATenção")
					Endif
				ENDIF
			ENDIF
		END Transaction
	    TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea()) 

RETURN(NIL) 

Static Function logZBN(cStatus)

	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := '08:25:00'
	Local cHoraSegunda := '08:55:00'
	Local nTotVezes    := 22   
	Local cTempo       := '30'
	Local cHoraProx    := '' 
	Local dDtProx      := dDataBase
	                          
	IF cStatus == '1' //se status igual a 1 inicio
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG006P')) //procura o registro
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
		IF ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG006P'))
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
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG006P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG006P'
			ZBN_DESCRI  := 'Integraçao Prothex X Ravex - Importaçao Viagens Devolvidas'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 22 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:25:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG006P'
			ZBN_DESCRI  := 'Integraçao Prothex X Ravex - Importaçao Viagens Devolvidas'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '30 MIN - 22 VEZES'
			ZBN_PERDES  := 'MINUTO'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:25:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return(Nil)

STATIC FUNCTION FatorConversao(cProd)
	
	LOCAL nConv := 1

	SQLCodProduto(cProd)
	
	WHILE TRE->(!EOF()) 
	
		nConv := TRE->B1_CONV
		
		TRE->(dbSkip())							
    ENDDO   
	TRE->(dbCloseArea())


RETURN(nConv)


STATIC FUNCTION TipoConversao(cProd)

	Local cTipoConv := ''

	SQLCodProduto(cProd)
	
	WHILE TRE->(!EOF()) 
	
		cTipoConv := TRE->B1_TIPCONV
		
		TRE->(dbSkip())							
    ENDDO   
	TRE->(dbCloseArea())
								      										          
RETURN(cTipoConv)

STATIC FUNCTION SQLITEM(cFili,cNota,cSerie,cCliente,cLoja,cCodigo)  

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT D2_UM,
			       D2_ITEM,
                   D2_SEGUM,
                   D2_QTSEGUM,
                   D2_TOTAL,
                   D2_PRCVEN
			  FROM %Table:SD2%
			 WHERE D2_FILIAL  = %EXP:cFili%
			   AND D2_DOC     = %EXP:cNota%
			   AND D2_SERIE   = %EXP:cSerie%
			   AND D2_CLIENTE = %EXP:cCliente%
			   AND D2_LOJA    = %EXP:cLoja%
			   AND D2_COD     = %EXP:cCodigo%
			     
	EndSQl 	  
RETURN(NIL)

STATIC FUNCTION SQLAPROV1(cFil,cNota,cSerie)
  

	BeginSQL Alias "TRC"
			%NoPARSER%
			  
			SELECT SZD.ZD_NUMNF,
			       SZD.ZD_SERIE,
			       SZD.ZD_DEVTOT,
			       SZD.ZD_RESPONS,
			       SZD.ZD_CODCLI,
			       SZD.ZD_LOJA,
			       SZD.ZD_PEDIDO,
			       SZD.ZD_NOMECLI,
			       SZD.ZD_DTDEV,
			       SZD.ZD_DESCMOT,
			       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), SZD.ZD_OBSER)) AS ZD_OBSER,
                   SZD.ZD_VEND
			  FROM %Table:SZD% SZD 
			 WHERE SZD.ZD_FILIAL   = %EXP:cFil%
			   AND SZD.ZD_NUMNF    = %EXP:cNota%
			   AND SZD.ZD_SERIE    = %EXP:cSerie%
               AND SZD.D_E_L_E_T_ <> '*'
			   
	EndSQl             

RETURN(NIL)

STATIC FUNCTION SQLAPROV2(cFil,cNota,cSerie)

   BeginSQL Alias "TRD"
			%NoPARSER%   
			SELECT SZX.ZX_NF,
			       SZX.ZX_SERIE,
			       SD2.D2_PRCVEN,
			       SZX.ZX_QTDEV1U,
			       SZX.ZX_QTSEGUM,
			       SZX.ZX_QTDE,
			       SZX.ZX_QUEBRA,
			       SD2.D2_QUANT  
			  FROM %Table:SZX% SZX, %Table:SD2% SD2
			 WHERE SZX.ZX_FILIAL   = %EXP:cFil%
			   AND SZX.ZX_NF       = %EXP:cNota%
			   AND SZX.ZX_SERIE    = %EXP:cSerie%
			   AND SZX.ZX_NF       = SD2.D2_DOC
			   AND SZX.ZX_SERIE    = SD2.D2_SERIE
			   AND SZX.ZX_ITEMNF   = SD2.D2_ITEM
			   AND SZX.D_E_L_E_T_ <> '*'
			   AND SD2.D_E_L_E_T_ <> '*'
			
   EndSQl             

RETURN(NIL)		


STATIC FUNCTION SQLCodProduto(cCodigo)  

	BeginSQL Alias "TRE"
			%NoPARSER%  
			 SELECT B1_COD,
					B1_DESC,
					B1_MSBLQL,
					B1_CONV,
					B1_TIPCONV
				FROM %Table:SB1% SB1
			  WHERE B1_COD          = %EXP:cCodigo%
			    AND SB1.D_E_L_E_T_ <> '*'
				 
	EndSQl 	  
RETURN(NIL)


/*/{Protheus.doc} User Function DelDupSZX
    Exclui registros duplicados
    @type  Function
    @author FWNM
    @since 11/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
	@history ticket 68820 - Fernando Macieira - 11/03/2022 - Function DelDupSZX (Exclui registros duplicados)
/*/
User Function DelDupSZX()

    Local cQuery  := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_ITEMNF, ZX_CODPROD, COUNT(1) TT_DUPLICADOS
    cQuery += " FROM SZX010 SZX (NOLOCK) 
    cQuery += " INNER JOIN SZD010 SZD (NOLOCK) ON ZD_FILIAL=ZX_FILIAL AND ZD_NUMNF=ZX_NF AND ZD_SERIE=ZX_SERIE AND SZD.D_E_L_E_T_=''
    cQuery += " WHERE ZD_DTDEV>='20220309'
    cQuery += " AND ZD_NUMNF<>''
    cQuery += " AND SZX.D_E_L_E_T_=''

    //cQuery += " AND ZX_NF='002498885'
    //cQuery += " AND ZX_NF='002498883'

    cQuery += " GROUP BY ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_ITEMNF, ZX_CODPROD
    cQuery += " HAVING COUNT(1) >= 2
    cQuery += " ORDER BY 1,2,3,4,5

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    Do While Work->( !EOF() )

        // Exclui duplicados
        SZX->( dbSetOrder(2) ) // ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, R_E_C_N_O_, D_E_L_E_T_
        If SZX->( dbSeek(FWxFilial("SZX")+Work->(ZX_NF+ZX_SERIE+ZX_CODPROD)) )
            
            SZX->( dbSkip() ) // Pulo o registro que permanecerá

            Do While SZX->( !EOF() ) .and. SZX->ZX_FILIAL == Work->ZX_FILIAL .and. SZX->ZX_NF == Work->ZX_NF .and. SZX->ZX_SERIE == Work->ZX_SERIE .and. SZX->ZX_ITEMNF == Work->ZX_ITEMNF .and. SZX->ZX_CODPROD == Work->ZX_CODPROD

                RecLock("SZX", .F.)
                    SZX->( dbDelete() )
                SZX->( msUnLock() )

                SZX->( dbSkip() )

            EndDo
        
        EndIf

        Work->( dbSkip() )

    EndDo

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} ChkDupSZX
	Checa se o produto devolvido já existe pois mesmo com seek houveram casos da rotina entender que deveria ser incluído
	@type  Static Function
	@author FWNM
	@since 11/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 68820 - Fernando Macieira - 11/03/2022 - Function ChkDupSZX (via query pois já existe seek)
/*/
Static Function ChkDupSZX(cFilSZX, cNFSZX, cSerieSZX, cProdSZX)

	Local lRet   := .f.
	Local cQuery := ""
	Local aArea  := GetArea()

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	// ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, R_E_C_N_O_, D_E_L_E_T_
	cQuery := " SELECT ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD
	cQuery += " FROM " + RetSqlName("SZX") + " (NOLOCK)
	cQuery += " WHERE ZX_FILIAL='"+cFilSZX+"'
	cQuery += " AND ZX_NF='"+cNFSZX+"'
	cQuery += " AND ZX_SERIE='"+cSerieSZX+"'
	cQuery += " AND ZX_CODPROD='"+cProdSZX+"'
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )
	If Work->( !EOF() )
		lRet := .t.
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aArea )

Return lRet
