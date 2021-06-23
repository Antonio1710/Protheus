#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"   
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

Static _lCopia := .F.  
Static _nopc   := 1

// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 20/04/2020
Static cPCOri := ""
Static cPCMot := ""
//

/*/{Protheus.doc} User Function MT120F
	Ponto de Entrada MT120CPE a fim de verificar se esta sendo utilizada opção copia
	@type  Function
	@author Almir Bandina
	@since 25/03/2008
	@version 01
	@history Chamado TI     - FWNM          - 23/01/2019 - Alcada de Aprovacao - Encontrado PC sem alcada Exemplo: PC n. 343766, filial 02 - Sem registro na SRC
	@history Chamado 046783 - Everson       - 29/01/2019 - Adicionado log.
	@history Chamado 046783 - Everson       - 31/01/2019 - Adicionado log e variável do ponto de entrada no if inicial
	@history Chamado 046783 - Everson       - 19/02/2019 - Removido o if da rotina, pois há pedidos em que não ocorre o bloqueio. O ponto de entrada é chamado apenas quando ocorre a gravação do pedido (inclusão, alteração, cópia e exclusao)
	@history Chamado 047526 - Ricardo Lima  - 26/02/2019 - limpa condição de pagamento na copia de pedido
	@history Chamado TI     - Adriana       - 24/05/2019 - Devido a substituicao email p/sharedRelay, substituido MV_RELACNT p/MV_RELFROM
	@history Chamado TI     - Adriana       - 24/05/2019 - Devido a substituicao email p/sharedRelay, substituido MV_RELACNT p/MV_RELFROM
	@history Chamado 044314 - Everson       - 16/07/2019 - Vincular pedido de compra na tabela ZFK (CT-e e MDF-e).
	@history Chamado 044314 - Everson       - 06/08/2019 - Adicionado validação de empresa e filial para vincular pedido de compra a registro de frete.
	@history Chamado TI     - Everson       - 08/08/2019 - Vincular pedido de compra ao registro de reembolso
	@history Chamado 044314 - Everson       - 26/08/2019 - Desvincular pedido de compra de CT-e quando o pedido for cópia.
	@history Chamado 044314 - Everson       - 29/08/2019 - Tratamento de filial para Desvincular pedido de compra de CT-e quando o pedido for cópia.
	@history Chamado 056521 - William Costa - 12/03/2020 - Verificado que quando a cotação tem prazo de Dias, não alterar a data de entrega do pedido de compra C7_DATPRF
	@history Chamado 057440 - FWNM          - 17/04/2020 - || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO
	@history Chamado 057827 - FWNM          - 30/04/2020 - || OS 059306 || SUPRIMENTOS || IARA_MOURA || 8415 || ERRO LOG
	@history ticket   10588 - Fernando Maci - 08/03/2021 - Liberação de pedidos - Intercompany (novas regras)
/*/
User Function MT120CPE
	
	Local aArea	   := GetArea() //Everson - 19/02/2019.    
	
	Public lSubsPC := .F. // Utilizada nos PEs MT120TEL, MT120FOL, MT120FIM

	_nopc 	:= paramixb[1]	// 2- Visualizar; 3-Incluir; 4-Alterar; 5-Excluir; 6-Copia
	_lCopia	:= paramixb[2]	// .T. - Opção de Cópia ativa, .F. - Não é opção de cópia

	// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 17/04/2020
	If _lCopia

		lSubsPC := .F.

		If msgYesNo("Copiando para substituir um PC?")

			If AllTrim(SC7->C7_RESIDUO) == "S" .and. AllTrim(SC7->C7_CONAPRO) == "L"

				lOKPC   := .F.
				lSair   := .F.
				oCmpPC  := Array(01)
				oBtnPC  := Array(02)
				cPCOri  := SC7->C7_NUM
				cPCMot  := Space(254)
			
				Do While .T.
				
					DEFINE MSDIALOG oDlgPC TITLE "Substituição PC - Motivo" FROM 0,0 TO 170,850  OF oMainWnd PIXEL
					
						@ 003, 003 TO 080,420 PIXEL OF oDlgPC
						
						@ 010,020 Say "PC Original:" of oDlgPC PIXEL
						@ 005,060 MsGet oCmpPC Var cPCOri SIZE 70,12 of oDlgPC  WHEN .F. PIXEL Valid ( Iif(!Empty(cPCOri),ExistCpo("SC7",cPCOri),.T.) ) //F3 'SC7' 

						@ 030,020 Say "Motivo:" of oDlgPC PIXEL
						@ 025,060 MsGet oCmpPC Var cPCMot SIZE 350,12 of oDlgPC PIXEL Picture "@!" Valid (!Empty(AllTrim(cPCMot)))

						@ 060,130 BUTTON oBtnPC[01] PROMPT "Confirma" of oDlgPC SIZE 68,12 PIXEL ACTION (lOKPC := .T., oDlgPC:End()) 
						@ 060,230 BUTTON oBtnPC[02] PROMPT "Cancela"  of oDlgPC SIZE 68,12 PIXEL ACTION (lSair := .T., oDlgPC:End()) 
						
					ACTIVATE MSDIALOG oDlgPC CENTERED

					If lSair
						If msgYesNo("Você informou que fará uma substituição, porém, não clicou no botão Confirma! Gestores não conseguirão visualizar o motivo e o PC original... Certeza de que deseja cancelar?")
							Exit
						EndIf
					EndIf

					If lOKPC .and. !lSair
						If Empty(cPCOri) .and. Empty(AllTrim(cPCMot))
							msgAlert("Obrigatório informar o PC original e o motivo na substituição! Informe um PC válido e seu motivo...")
						Else
							lSubsPC := .T.
							Exit
						EndIf
					EndIf

					lOKPC   := .F.
					lSair   := .F.

				EndDo

			Else
				msgAlert("Para substituir o PC n. " + SC7->C7_NUM + ", o mesmo precisa estar eliminado por resíduo e já ter sido aprovado! Se continuar, será realizada uma inclusão normal sem amarração com o PC Original e os gestores não conseguirão visualizar...")

			EndIf

		EndIf

	EndIf
	//
	
	If !lSubsPC
		// Ricardo Lima-26/02/2019-047526
		if paramixb[2]
			CCONDICAO := Space(03)
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} User Function MT120F
	(long_description)
	@type  Function
	@author Almir Bandina
	@since 25/03/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function MT120F(_cParam) //cParam somente vai ter conteudo quando pedido de compra gerado por analise de cotacao (chamado por AVALCOPC)
	
	Local aAreaAtu	:= GetArea()
	Local lBlqPed	:= .F.
	Local aAprov	:= {}
	Local aTamSX3	:= {}
	Local nTotPed	:= 0
	Local nLoop1	:= 0
	Local cChave	:= iif(ValType(_cParam)=="C" .and. !Empty(_cParam), _cParam, PARAMIXB)				// FILIAL+NUM
	Local cFilSC7	:= ""
	Local cPedido	:= ""
	Local cQry		:= "" 
	
	Local cLogParam := "" //Everson - 29/01/2019. Chamado 046783.
	
	Local cFilGFrt	:= Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019.
	Local cEmpFrt	:= Alltrim(SuperGetMv( "MV_#M46F6" , .F. , '' ,  )) //Everson-CH:044314-06/08/2019. 
	
	// RICARDO LIMA - 13/11/17
	/*
	Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
	Local nPosProd := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
	*/        
	//Local cParam    := iif(ValType(cParam)=="C",cParam,PARAMIXB)				// FILIAL+NUM//Alterado em 03/08/2015 após atualização rotina de cópia cria pedido liberado
	
	//Somente se for Inclusão ou Alteração                                                    
	
	//Everson - 31/01/2019.
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH dDataBase
		Replace ZBE_HORA 	   	WITH TIME()
		Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
		Replace ZBE_LOG	        WITH ("MT120F-5 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + cChave  )  
		Replace ZBE->ZBE_PARAME WITH "INCLUI/ALTERA/_lcopia/FUNNAME/_nopc: " + cValToChar(INCLUI) + "/" + cValToChar(ALTERA) + "/" + cValToChar(_lcopia) + "/" + Alltrim(FUNNAME()) + "/" + Alltrim(cValToChar(_nopc))
		Replace ZBE_MODULO	    WITH "COMPRAS"
		Replace ZBE_ROTINA	    WITH "MT120F" 
	MsUnlock() 
	//  
	
	//Everson - 19/02/2019. Chamado 046783.
	If Alltrim(cValToChar(_nopc)) == "5"
		Conout("MT120F - Exclusão de pedido de compra " + cChave)
		RestArea(aAreaAtu)
		Return Nil
		
	EndIf
	//
		
	//If INCLUI .or. ALTERA .or. _lcopia
	
	//Everson - 19/02/2019. Chamado 046783.
	//Comentado o if da rotina, pois o bloqueio do pedido não está sendo efetuado sempre.
	//If Alltrim(cValToChar(_nopc)) $("3/4") .Or. INCLUI .Or. ALTERA .Or. _lcopia //Everson - 31/01/2019. Chamado 046783. 

		//Extrai a filial e o número do pedido de compra da chave                             

		cFilSC7	:= Left( cChave,	TAMSX3("C7_FILIAL")[1] )
		cPedido	:= Right( cChave,	TAMSX3("C7_NUM")[1] )
		
		//Não encontrou o pedido na base                                                          
		
		dbSelectArea( "SC7" )
		dbSetOrder( 1 )
		If !( MsSeek( cFilSC7 + cPedido ) )
			Aviso(	"Pedido de Compra",;
					"Pedido não localizado no cadastro." + Chr(13) + Chr(10) +;
					"Controle de Aprovação não será realizdo.",;
					{ "&Retorna" },,;
					"Filial/Pedido: " + cFilSC7 + "/" + cChave )
		
		//Inicia o processo de controle de alçada                                                 
		
		Else
		
			//Everson-Ch:044314-26/08/2019.
			If _lCopia
				apgCTE(cFilSC7, cPedido)
			
			EndIf
			//
		
			//Totaliza o pedido de venda para utilizar na definição dos aprovadores            
			
			cQry	:= " SELECT ISNULL(SUM(SC7.C7_TOTAL-SC7.C7_VLDESC),0) AS TOTAL
			cQry	+= " FROM " + RetSqlName( "SC7" ) + " SC7(NOLOCK)"
			cQry	+= " WHERE SC7.C7_FILIAL = '" + cFilSC7 + "'"
			cQry	+= " AND SC7.C7_NUM = '" + cPedido + "'"
			cQry	+= " AND SC7.D_E_L_E_T_ = ' '"
			
			//Verifica se o alias esta em uso e fecha se necessário                               

			If Select( "TMPSC7" ) > 0
				dbSelectArea( "TMPSC7" )
				dbCloseArea()
			EndIf
			
			//Executa a query para obter o valor total do pedido                                 
			
			TCQUERY cQry NEW ALIAS "TMPSC7"
			
			//Compatibiliza o campo de total com a TopField                                       
			
			aTamSX3	:= TAMSX3( "C7_TOTAL" )
			TCSETFIELD( "TMPSC7", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2] )
			
			//Seleciona o arquivo da query e guarda o valor total do pedido                       
			
			dbSelectArea( "TMPSC7" )
			dbGoTop()
			nTotPed	:= TMPSC7->TOTAL
			
			//Fecha o arquivo da query e seleciona o pedido de compra                             
			
			dbCloseArea()
			dbSelectArea( "SC7" )
			
			//Obtem os aprovadores para os centros de custo                                       
			
			aAprov	:= U_GetAprov( SC7->C7_CC, SC7->C7_ITEMCTA, nTotPed )
			
			//Se não encontra aprovadores, avisa usuário                                          
			
			If Len( aAprov ) == 0
				
				// FWNM - 23/01/2019 - TI - Forco pedido nascer bloqueado mesmo qdo nao gerar alcada por qq motivo nao reproduzido				
				lBlqPed	:= .T. 
				
				//dbSelectArea("ZBE")
				RecLock("ZBE",.T.)
					ZBE->ZBE_FILIAL 	:= xFilial("ZBE")
					ZBE->ZBE_DATA 	   	:= dDataBase
					ZBE->ZBE_HORA 	   	:= TIME()
					ZBE->ZBE_USUARI	    := UPPER(Alltrim(cUserName))
					ZBE->ZBE_LOG	    := ("MT120F-3 - PEDIDO DE COMPRA SEM ALCADA")  
					ZBE->ZBE_MODULO	    := "COMPRAS"
					ZBE->ZBE_ROTINA	    := "MT120F" 
				ZBE->( MsUnlock() )                             
				
				EnviaWF(nTotPed)

				Alert("MT120F - PEDIDO COMPRA NAO SERA LIBERADO POIS NAO POSSUI CONTROLE DE ALCADA - EXCLUA O PEDIDO E ENTRE EM CONTATO COM TI")
				Alert("MT120F - PEDIDO COMPRA NAO SERA LIBERADO POIS NAO POSSUI CONTROLE DE ALCADA - EXCLUA O PEDIDO E ENTRE EM CONTATO COM TI")
				Alert("MT120F - PEDIDO COMPRA NAO SERA LIBERADO POIS NAO POSSUI CONTROLE DE ALCADA - EXCLUA O PEDIDO E ENTRE EM CONTATO COM TI")
				
				Aviso(	"Pedido de Compra",;
						"Não foi localizado controle de alçada para o centro de custo.",;
						{ "&Retorna" },,;
						"Filial/Pedido: " + cFilSC7 + "/" + cPedido )
	
			
			//Encontrou aprovadores, soma os itens do pedido para totalizar                       
			
			Else

				//Verifica se precisa bloquear o pedido de compra em função do valor mínimo       
				
				For nLoop1 := 1 To Len( aAprov )
					
					//Everson - 29/01/2019. Chamado 046783.
					cLogParam := "Chave " + cValToChar(cChave) + " nTotPed " + cValToChar(nTotPed) + ;
					" codgrp/aprovador/nivel/tplib/mínimo/blq : " +  cValToChar(aAprov[nLoop1,01]) + "/" + ;
					cValToChar(aAprov[nLoop1,02]) + "/" + cValToChar(aAprov[nLoop1,03]) + "/" + cValToChar(aAprov[nLoop1,04]) + ;
					"/" + cValToChar(aAprov[nLoop1,05]) + "/" + cValToChar(nTotPed >= aAprov[nLoop1,05])
					Conout("MT120F - cLogParam " + cLogParam)
					RecLock("ZBE",.T.)
						ZBE->ZBE_FILIAL 	:= xFilial("ZBE")
						ZBE->ZBE_DATA 	   	:= dDataBase
						ZBE->ZBE_HORA 	   	:= TIME()
						ZBE->ZBE_USUARI	    := UPPER(Alltrim(cUserName))
						ZBE->ZBE_LOG	    := ("MT120F-4 -Check valor do pedido x mínimo alçada") 
						ZBE->ZBE_PARAME		:= cLogParam
						ZBE->ZBE_MODULO	    := "COMPRAS"
						ZBE->ZBE_ROTINA	    := "MT120F" 
					ZBE->( MsUnlock() ) 
					
					If nTotPed >= aAprov[nLoop1,05]
						lBlqPed	:= .T.
					EndIf
				Next nLoop1
				
				//Se deve bloquear o pedido, grava o arquivo de aprovações                        
				
				If lBlqPed
					
					//Varre o array com todos os aprovadores                                      
					
					For nLoop1 := 1 To Len( aAprov )
						
						//Grava o arquivo de documentos para aprovação                            
						
						U_FGrvSCR(	"PC",;								// Tipo de Documento (fixo)
									cPedido,;				  			// Número do Pedido de Compra
									aAprov[nLoop1,03],;					// Nível
									aAprov[nLoop1,02],;					// Id do Usuário Aprovador
									aAprov[nLoop1,01],;					// Grupo de Aprovacao
									nTotPed,;							// Total do Pedido
									SC7->C7_EMISSAO,;					// Data de Emissão do Pedido
									SC7->C7_MOEDA,;						// Moeda do Pedido
									SC7->C7_TXMOEDA,;					// Taxa da Moeda do Pedido
									If( nLoop1 <> 1, "01", "02" ),;	// Status do Bloqueio
									aAprov[nLoop1,04] ;					// Tipo de Liberação
									)
					Next

					ChkInterCo() // @history ticket   10588 - Fernando Maci - 08/03/2021 - Liberação de pedidos - Intercompany (novas regras)

				EndIf
			
			EndIf
		
		EndIf
		
		// INICIO ALTERACAO WILLIAM COSTA - CHAMADO 033423
		IF ALLTRIM(FUNNAME()) == 'MATA121'
		// RICARDO LIMA - 13/11/17
		//LEN(aCols) >= 1 .AND. ALLTRIM(FUNNAME()) == 'MATA121'
		
			DbSelectArea("SC7")
			SC7->(dbgotop())
		    SC7->(dbSetOrder(1)) 
		    IF SC7->(DbSeek(cFilSC7 + cPedido)) // Busca exata
		    
			    While SC7->(!EOF()) .AND. SC7->C7_FILIAL == cFilSC7 .AND. SC7->C7_NUM == cPedido
			        
			        //FOR nCont := 1 TO LEN(aCols) // RICARDO LIMA - 13/11/17		        
			        	//IF aCols[nCont][nPosItem] == SC7->C7_ITEM // RICARDO LIMA - 13/11/17
			        
			        		// *** INICIO CHAMADO WILLIAM 30/10/2018 - 044837 || OS 045989 || FISCAL || VALERIA || 8389 || NF DE IMPORTACAO *** //
			        		IF ALLTRIM(SC7->C7_TES) == ''
			        		
				        		RecLock( "SC7", .F. ) // chamado 042931
				        		
				        			SC7->C7_TES := Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO , "B1_TE")
				        			//SC7->C7_TES := Posicione("SB1",1,xFilial("SB1") + aCols[nCont][nPosProd], "B1_TE") // RICARDO LIMA - 13/11/17
				        			
						        MsUnlock() // chamado 042931
						        
					        ENDIF
					        // *** FINAL CHAMADO WILLIAM 30/10/2018 - 044837 || OS 045989 || FISCAL || VALERIA || 8389 || NF DE IMPORTACAO *** //
					         
					        // INICIO CHAMADO 033665 - WILLIAM COSTA - 24/02/2017 - ALMOXARIFADO ERRADO NA COPIA
	
							IF _lCopia == .T.
							 
								RecLock( "SC7", .F. ) // chamado 042931
								
									SC7->C7_LOCAL := IIF(!RetArqProd(SC7->C7_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC7->C7_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_LOCPAD"))
								 
								MsUnlock() // chamado 042931 
							ENDIF
							
							// FINAL CHAMADO 033665 - WILLIAM COSTA - 24/02/2017 - ALMOXARIFADO ERRADO NA COPIA
					        
				        //ENDIF // RICARDO LIMA - 13/11/17			        
					//NEXT nCont  // RICARDO LIMA - 13/11/17
					
					SC7->(dbSkip())
					
				ENDDO
			ENDIF
		ENDIF
		SC7->(dbCloseArea())
		
		// FINAL ALTERACAO WILLIAM COSTA - CHAMADO 033423
		
	//EndIf
	
	//Restaura as áreas originais dos arquivos                                                
	
	&&Mauricio 23/11/10 - alterado parte do programa abaixo pois na versao atual do sistema nao estava funcionando(anteriormente funcionava).
	&&Chamado 008395
	_cBL    := IIF(lBlqPed, "B", "L" )
	_cWF    := CriaVar( 'C7_XWF' , .F. ) // RICARDO LIMA - 13/11/17
	_cWFID  := CriaVar( 'C7_XWFID' , .F. ) // RICARDO LIMA - 13/11/17
	dbSelectArea( "SC7" )
	SC7->( dbSetOrder( 1 ) )
	//SC7->( MsSeek( cChave ) )
	if dbseek(cChave)
	  While SC7->( !Eof() ) .And. SC7->( C7_FILIAL + C7_NUM ) == cChave 
	    
	    //INICIO CHAMADO 033773 - WILLIAM COSTA
	  	dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH dDataBase
			Replace ZBE_HORA 	   	WITH TIME()
			Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("MT120F-1 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + cChave + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + _cBL)  
			Replace ZBE_MODULO	    WITH "COMPRAS"
			Replace ZBE_ROTINA	    WITH "MT120F" 
		MsUnlock()       
		
		dbSelectArea( "SC7" )
		//FINAL CHAMADO 033773 - WILLIAM COSTA 
	  
	  	RecLock( "SC7", .F. )
			REPLACE SC7->C7_CONAPRO	WITH _cBL
			REPLACE SC7->C7_XWF     WITH _cWF     // RICARDO LIMA - 13/11/17
			REPLACE SC7->C7_XWFID   WITH _cWFID // RICARDO LIMA - 13/11/17
			REPLACE SC7->C7_FILENT  WITH SC7->C7_FILIAL
			REPLACE SC7->C7_DATPRF  WITH IIF(ALTERA == .T. .AND. FUNNAME() <> 'MATA161', SC7->C7_DATPRF,IIF(EMPTY(SC7->C7_NUMSC),SC7->C7_DATPRF,IIF(SC8->C8_PRAZO > 0,SC7->C7_DATPRF,Posicione("SC1",1,xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,"C1_DATPRF")))) // WILLIAM COSTA 039307 26/01/2018 // William Costa 056521 12/03/2020

			// Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 20/04/2020
			If IsInCallStack("A120Copia") // Chamado n. 057827 || OS 059306 || SUPRIMENTOS || IARA_MOURA || 8415 || ERRO LOG - FWNM - 30/04/2020
				If lSubsPC
					REPLACE SC7->C7_XPEDORI WITH cPCOri
					REPLACE SC7->C7_XOBSINT WITH "MOTIVO SUBSTITUICAO: " + AllTrim(cPCMot) + " | " + SC7->C7_XOBSINT
				EndIf
			EndIf
			//
		MsUnlock()
		
		//INICIO CHAMADO 033773 - WILLIAM COSTA
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH dDataBase
			Replace ZBE_HORA 	   	WITH TIME()
			Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("MT120F-2 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + cChave + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + _cBL)  
			Replace ZBE_MODULO	    WITH "COMPRAS"
			Replace ZBE_ROTINA	    WITH "MT120F" 
		MsUnlock()    
		
		//Everson - 06/08/2019. Chamado 044314.
		//Everson - 16/07/2019. Chamado 044314.
		If cEmpAnt $cEmpFrt .And. cFilAnt $cFilGFrt
			
			//
			If ! Empty(SC7->C7_XNUMCTE) .And. ! Empty(SC7->C7_XNUSCTE)
				
				//
				grvPedZFK(SC7->C7_FILIAL,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_XNUMCTE,SC7->C7_XNUSCTE,SC7->C7_NUM)
			
			EndIf
		
		EndIf 
		
		//Everson - 08/08/2019. Chamado TI.
		If cEmpAnt == "01"
			
			If ! Empty( Alltrim(SC7->C7_XREEMBO) )
				
				grvPedRee(SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_XREEMBO)
			
			EndIf
		
		EndIf 
		
		dbSelectArea( "SC7" )
		//FINAL CHAMADO 033773 - WILLIAM COSTA 
		
		SC7->(DbSkip())	 
	  EndDo
	endif
	
	//Restaura dados de entrada                                                               
	
	//If ValType( cParam ) == "C"
	//	INCLUI	:= .F.
	//EndIf
	
	
	//Restaura as áreas originais dos arquivos                                                
	
	RestArea( aAreaAtu )

Return( Nil )

/*{Protheus.doc} Static Function grvPedZFK
	Grava pedido de compra na tabela ZFK (CT-e e MDF-e)
	@type  Function
	@author Everson
	@since 16/07/2019
	@version 01
	
*/

Static Function grvPedZFK(cFiPed,cFornece,cLoja,cNumCTe,cSerCTe,cPedido)

	Local aArea	 	:= GetArea()
	Local cUpdt		:= ""
	
	//
	cNumCTe := Padl(cNumCTe,9,"0")
	cSerCTe := Padl(cSerCTe,3,"0")
	
	//
	cUpdt := ""
	cUpdt += " UPDATE " + RetSqlName("ZFK") + " SET ZFK_PEDCOM = '" + cPedido + "'  " 
	cUpdt += " WHERE  " 
	cUpdt += " ZFK_FILIAL = '" + cFiPed + "'  " 
	cUpdt += " AND ZFK_TRANSP = '" + cFornece + "'  " 
	cUpdt += " AND ZFK_LOJA = '" + cLoja + "'  " 
	cUpdt += " AND RIGHT('000000000' + RTRIM(LTRIM(ZFK_NUMDOC)),9) = '" + cNumCTe + "' " 
	cUpdt += " AND RIGHT('000' + RTRIM(LTRIM(ZFK_SERDOC)),3)       = '" + cSerCTe + "' " 
	cUpdt += " AND ZFK_TPDOC = '1' " 
	cUpdt += " AND ZFK_STATUS = '1' " 
	cUpdt += " AND D_E_L_E_T_ = '' " 
	
	//
	TCSqlExec(cUpdt)

	//
	RestArea(aArea)
	
Return Nil

/*{Protheus.doc} Static Function grvPedRee
	Grava pedido de compra na tabela ZFI (Reembolso). 
	@type  Function
	@author Everson
	@since 08/08/2019
	@version 01
	
*/

Static Function grvPedRee(cFiPed,cPed,cReemb)

	Local aArea	 	:= GetArea()
	Local cUpdt		:= ""
	
	cUpdt := " UPDATE " + RetSqlName("ZFI") + " SET ZFI_PEDCOM = '" + cPed + "', ZFI_STATUS = '2' WHERE ZFI_FILIAL = '" + cFiPed + "' AND ZFI_COD = '" + cReemb + "' AND D_E_L_E_T_ = '' "
	
	TCSqlExec(cUpdt)

	RestArea(aArea)
	
Return Nil

/*{Protheus.doc} User Function FGrvSCR
	Função de atualização do arquivo de documentos por alçada
	@type  Function
	@author Almir Bandina
	@since 25/03/2008
	@version 01
	
*/

User Function FGrvSCR( cTipo, cDocto, cNivel, cCodUsr, cCodApr, nTotPed, dEmissao, nMoeda, nTxMoed, cStatus, cTpLib )

	Local aAreaAtu	:= GetArea()
	Local aAreaSCR	:= SCR->( GetArea() )

	cDocto	:= PadR( cDocto, TAMSX3("CR_NUM")[1] )
	
	//Procura se existe o movimento no arquivo                                                
	
	dbSelectArea( "SCR" )
	dbSetorder( 1 )				// FILIAL+TIPO+NUM+NIVEL
	If !( MsSeek( xFilial ( "SCR" ) + cTipo + cDocto + cNivel ) ) 
		RecLock( "SCR", .T. )
	Else
		RecLock( "SCR", .F. )
	EndIf
	SCR->CR_FILIAL	:= xFilial( "SCR" )
	SCR->CR_NUM		:= cDocto
	SCR->CR_TIPO	:= cTipo
	SCR->CR_USER	:= cCodUsr
	SCR->CR_APROV	:= cCodApr
	SCR->CR_NIVEL	:= cNivel
	SCR->CR_STATUS	:= cStatus
	SCR->CR_TOTAL	:= nTotPed
	SCR->CR_EMISSAO	:= dEmissao
	SCR->CR_MOEDA	:= nMoeda
	SCR->CR_TXMOEDA	:= ntxMoed
	SCR->CR_XTPLIB	:= cTpLib
	//SCR->CR_DATALIB
	//SCR->CR_OBS
	//SCR->CR_USERLIB
	//SCR->CR_LIBAPRO
	//SCR->CR_VALLIB
	//SCR->CR_TIPOLIM
	//SCR->CR_WF
	
	MsUnLock()
	
	RestArea( aAreaSCR )
	RestArea( aAreaAtu )
	
Return( Nil )

Static Function EnviaWF(nTotPed)

	Local aArea		:= GetArea()
	Local aAreaSM0  := SM0->( GetArea() )
	Local cAssunto	:= "ZBE - PC SEM ALCADA (SCR)"
	Local cMensagem	:= ""
	Local lAuto     := .f.
	Local cMails    := "sistemas@adoro.com.br;fernando.sigoli@adoro.com.br;eduardo.santamaria@adoro.com.br"
	
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Empresa</td>'
	cMensagem += '<td>Filial</td>'
	cMensagem += '<td>Pedido Compras</td>'
	cMensagem += '<td>Total</td>'
	cMensagem += '<td>Data</td>'
	cMensagem += '<td>Hora</td>'
	cMensagem += '<td>Computador</td>'
	cMensagem += '<td>Login</td>'
	cMensagem += '</tr>'
	
	cMensagem += '<tr>'
	cMensagem += '<td>' + cValToChar(cEmpAnt) + '</td>'
	cMensagem += '<td>' + cValToChar(SC7->C7_FILIAL) + '</td>'
	cMensagem += '<td>' + cValToChar(SC7->C7_NUM) + '</td>'
	cMensagem += '<td>' + cValToChar(nTotPed)   + '</td>'
	cMensagem += '<td>' + cValToChar(DtoC(SC7->C7_EMISSAO))   + '</td>'
	cMensagem += '<td>' + cValToChar(Time()) + '</td>'
	cMensagem += '<td>' + cValToChar(ComputerName()) + '</td>'
	cMensagem += '<td>' + cValToChar(cUserName)  + '</td>'
		
	cMensagem += '</tr>'
		
	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	ProcEmail(cAssunto,cMensagem,cMails,lAuto)
	
	RestArea(aArea)
	RestArea(aAreaSM0)

Return Nil

Static Function ProcEmail(cAssunto,cMensagem,email,lAuto)

	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""
	Local cSubject      := ""
	
	//Assunto do e-mail.
	cSubject := cAssunto
	
	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
			
		Else
			lAutOk := .T.
			
		EndIf
		
	EndIf
	
	If lOk .And. lAutOk
		
		//Envia o e-mail.
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		
		Else
	
			// Aviso ao usuario
			If lAuto
				ApMsgStop( cRotina + " - JOB - Email enviado com sucesso!"  + cMails )
				ConOut(	cRotina + " - JOB - Email enviado com sucesso!"  + cMails )
			EndIf
		
		EndIf
		
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
		
	EndIf
	
	If lOk
		Disconnect Smtp Server
		
	EndIf
	
	RestArea(aArea)

Return Nil

Static Function apgCTE(cFilSC7, cPedido)
	
	//Define as variáveis utilizadas na rotina                                                
	
	Local aArea		:= GetArea() //Everson - 19/02/2019. 
	Local cUpd		:= " UPDATE " + RetSqlName("SC7") + " SET C7_XNUMCTE = '', C7_XNUSCTE = '' WHERE C7_FILIAL = '" + cFilSC7 + "' AND C7_NUM = '" + cPedido + "' AND D_E_L_E_T_ = '' "
	Local cFilGFrt	:= Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ))

	//Everson-29/08/2019.Chamado 044314.
	If  Alltrim(cFilAnt) $cFilGFrt
		TCSqlExec(cUpd)
	EndIf
	
	RestArea(aArea)
		
Return Nil

/*/{Protheus.doc} Static Function ChkInterCo()
	Usuário(comprador) faz a abertura do pedido de compra (procedimento padrão protheus)
	Após digitação do pedido de compra, sistema deverá verificar se as regras de Intercompany foram preenchidas,
	caso positivo, grava flag como Intercompany = S, caso negativo, grava flag como Intercompany = N
	Pedido irá ficar pendente de aprovação para aprovadores amarrado na estrutura de centro de custos (processo atual)
	Quando visitador (1 nível) liberar o pedido, o sistema irá verificar se Intercompany = S e irá concluir liberação sem alçadas superiores independente de valor do pedido.
	@type  Static Function
	@author FWNM
	@since 08/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	ticket   10588 - Fernando Maci - 08/03/2021 - Liberação de pedidos - Intercompany (novas regras)
/*/
Static Function ChkInterCo()

	Local i
	Local lInterCo := .f.
	Local cSql     := ""
	Local cSA2CNPJ := Posicione("SA2",1,FWxFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_CGC")
	Local aDadEmp  := FWLoadSM0()

	For i:=1 to Len(aDadEmp)

		If ( AllTrim(cSA2CNPJ) == AllTrim(aDadEmp[i,18]) ) .or. ( Left(AllTrim(cSA2CNPJ),8) == Left(AllTrim(aDadEmp[i,18]),8) )
			lInterCo := .t.
			Exit
		EndIf

	Next i

	If lInterCo

		cSql := " DELETE 
		cSql += " FROM " + RetSqlName("SCR")
 		cSql += " WHERE CR_FILIAL='"+SC7->C7_FILIAL+"' 
 		cSql += " AND CR_NUM='"+SC7->C7_NUM+"'
 		cSql += " AND CR_NIVEL<>'01'
 		cSql += " AND CR_STATUS<>'02'

		nStatus := tcSqlExec(cSql)
	
		If nStatus < 0

			SCR->( dbSetOrder(4) ) // CR_FILIAL, CR_NUM, R_E_C_N_O_, D_E_L_E_T_
			If SCR->( dbSeek(SC7->C7_FILIAL+SC7->C7_NUM) )
		
				Do While SCR->( !EOF() ) .and. SCR->CR_FILIAL==SC7->C7_FILIAL .and. SCR->CR_NUM==SC7->C7_NUM
				
					If AllTrim(SCR->CR_NIVEL)<>"01" .and. AllTrim(SCR->CR_STATUS<>"02")

						RecLock("SCR", .F.)
							SCR->( dbDelete() )
						SCR->( msUnLock() )

					EndIf

					SCR->( dbSkip() )

				EndDo
				
			EndIf
		
		EndIf

		// Mudo o SCR->CR_XTPLIB == "A" para que as lógicas contidas nas demais rotinas (como o ADOA040) não sofram impactos, pois neste caso o Vistador vira Aprovador
		SCR->( dbSetOrder(4) ) // CR_FILIAL, CR_NUM, R_E_C_N_O_, D_E_L_E_T_
		If SCR->( dbSeek(SC7->C7_FILIAL+SC7->C7_NUM) )

			RecLock("SCR", .F.)
				SCR->CR_XTPLIB := "A"
			SCR->( msUnLock() )

		EndIf

	EndIf

Return
