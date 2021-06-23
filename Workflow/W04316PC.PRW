#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณW04316PC  บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 1 - ENVIO DE EMAIL PARA APROVADORES                        บฑฑ
ฑฑบ          ณ 2 - RETORNO DE EMAIL COM RESPOSTA DE APROVADORES           บฑฑ
ฑฑบ          ณ 3 - ENVIA RESPOSTA DE PEDIDO BLOQUEADO PARA O COMPRADOR	  บฑฑ
ฑฑบ          ณ 4 - PROCESSA O RETORNO DO EMAIL DE PC REPROVADO			  บฑฑ
ฑฑบ          ณ 5 - ENVIA RESPOSTA DE PEDIDO APROVADO PARA O COMPRADOR	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function W04316PC(_nOpc, oProcess)

Local _cIndex, _cFiltro, _cOrdem, _lProcesso := .F.
Local _cFilial, _cOpcao, _cObs

Local nSaldo 		:= 0 , 	nSalDif 	:= 0  ,	cTipoLim  	:= ""
Local aRetSaldo 	:={} ,	cAprov    	:= "" , cObs 		:= ""
Local nTotal    	:= 0 , 	cGrupo	 	:= "" , lLiberou	:= .F.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'1 - ENVIO DE EMAIL PARA APROVADORES,2 - RETORNO DE EMAIL COM RESPOSTA DE APROVADORES,3 - ENVIA RESPOSTA DE PEDIDO BLOQUEADO PARA O COMPRADOR,4 - PROCESSA O RETORNO DO EMAIL DE PC REPROVADO,5 - ENVIA RESPOSTA DE PEDIDO APROVADO PARA O COMPRADOR')

DO 	CASE 

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ1 - Prepara os pedidos a serem enviados para aprovacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

	CASE _nOpc == 1

			CONOUT("	 **** ")
			CONOUT("	***** ")
			CONOUT("	 **** ")
			CONOUT("	 **** ")
			CONOUT("	 **** ")
			CONOUT("	 **** ")
			CONOUT("	******")
			CONOUT("	******")

			U_CONSOLE("1 - Prepara os pedidos a serem enviados para aprovacao")
			U_CONSOLE("1 - EmpFil:" + cEmpAnt + cFilAnt)
			
			CHKfile("SC7")	// Pedido de Compras
			CHKFile("SCR")  // Documentos com al็adas
//			CHKFile("SCR",.F.,"TMP")
						
  			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Seleciona os registros do SCR - DBF / INDREGUA                         ณ
			//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*			
			_cIndex := CriaTrab(,.F.)

			_cFiltro := ""
			_cFiltro += " CR_FILIAL=='" + cFilAnt + "' 	.AND."  // Filial
			_cFiltro += " CR_TIPO=='PC'   .AND. "				// Pedido de compra
			_cFiltro += " CR_STATUS=='02' .AND. "				// Em aprova็ใo
			_cFiltro += " CR_WF$' |3'           "				// ' '-Nao Enviado / 3-rejeitado por saldo insuficiente no retorno
			
			_cOrdem	 := "CR_FILIAL+CR_NUM+CR_NIVEL+CR_USER"
			
			dbSelectArea("TMP")
			
			IndRegua("TMP",_cIndex,_cOrdem,,_cFiltro,"") //"Selecionando Registros..."
*/			
			
			cQuery:="SELECT * "+;
					"FROM "+retsqlname("SCR")+" "+;
					"WHERE CR_FILIAL='"+cFilAnt+"' AND "+;
					"D_E_L_E_T_ <> '*' AND "+;
					"CR_TIPO= 'PC' AND "+;
					"CR_STATUS='02'AND "+;
					"(CR_WF = '' OR CR_WF = '3')"+;
					"ORDER BY CR_FILIAL,CR_NUM,CR_NIVEL,CR_USER"

			TCQUERY cQuery new alias "TMP1"			

			dbSelectArea("TMP1")			
//			#IFNDEF TOP
  //				dbSetIndex(_cIndex+OrdBagExt())
	//		#ENDIF
		
			dbGotop()                                           
			While !TMP1->(Eof())           

				_cWFId 		:= EnviaPc(TMP1->CR_FILIAL, TMP1->CR_NUM, TMP1->CR_USER , TMP1->CR_APROV, TMP1->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), TMP1->CR_TOTAL, TMP1->CR_WF)
				_lProcesso 	:= .T.
					
				DBSelectarea("SCR")
				DBSetOrder(2)
				IF DBSeek(TMP1->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
					Reclock("SCR",.F.)
					SCR->CR_WF		:= "1"			// Status 1 - envio para aprovadores
	  				SCR->CR_WFID	:= _cWFId		// Rastreabilidade
					MSUnlock()     
				ENDIF
				TMP1->(DBSkip())           
			End
			
			dbSelectArea("TMP1")
//			dbClearFilter()
			dbCloseArea()
//			Ferase(_cIndex+OrdBagExt())

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ2 - Processa O RETORNO DO EMAIL                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
	CASE _nOPC	== 2

			CONOUT("      *****")
			CONOUT("     *******")
			CONOUT("     ** ****")
			CONOUT("       ****")
			CONOUT("      ****")
			CONOUT("     ****")
			CONOUT("     *******")
			CONOUT("     *******")
			CONOUT("+---------------------------------+")
			CONOUT("| 2 - Processa O RETORNO DO EMAIL |")
			_ctext		:= "2 - EmpFil:" + cEmpAnt + cFilAnt
			_nSpace		:=	ESPACO(_ctext)
			CONOUT("| " + space(16-_nSpace) + _ctext+ " |")
			CONOUT("|     2 - Semaforo Vermelho       |" )
			CONOUT("+---------------------------------+")
			
			nWFPC2 := U_Semaforo("WFPC2")

			ChkFile("SCR")
			ChkFile("SAL")
			ChkFile("SC7")
			ChkFile("SCS")                    
			ChkFile("SAK")                    
			ChkFile("SM2")                    
        
			IF oProcess <> NIL
				cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
				cChaveSCR	:= alltrim(oProcess:oHtml:RetByName("CHAVE"))
				cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
				cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
				cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))
				cWF       	:= alltrim(oProcess:oHtml:RetByName("WF")) //cWF -> ' '-Nao Enviado / 3-rejeitado por saldo insuficiente no retorno

				oProcess:Finish() // FINALIZA O PROCESSO
				
				CONOUT("+---------------------------------+")
				_ctext		:= "2 - Chave :" + cChaveSCR
				_nSpace		:=	ESPACO(_ctext)
				CONOUT("| "+space(16-_nSpace)+_ctext+" |")
				U_CONSOLE("2 - Opc   :" + cOpc)
				_ctext		:= "2 - Opc   :" + cOpc
				_nSpace		:=	ESPACO(_ctext)
				CONOUT("| "+space(16-_nSpace)+_ctext+" |")
				CONOUT("+---------------------------------+")
				CONOUT("2****************>>>>>>>>>>OBSERVACAO: "+ cObs)

				IF cWF == "3" .AND. cOpc == "S"
					cObs	:= "Aprovado por insuficiencia de saldo"
				ENDIF
			ENDIF

			IF cOpc	$ "S|N"  // Aprovacao S-Sim N-Nao

				// Posiciona na tabela de Alcadas 
				DBSelectArea("SCR")
				DBSetOrder(2)
				DBSeek(cChaveSCR)
				
				IF !FOUND() .OR. TRIM(SCR->CR_WFID) <> TRIM(cWFID)
					//"Este processo nao foi encontrado e portanto deve ser descartado
					// abre uma notificacao a pessoa que respondeu
					
					U_CONSOLE("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + SCR->CR_WFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					Return .T.
				ENDIF
				
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "2"			// Status 2 - respondido
				MSUnlock()

				If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
					U_CONSOLE("2 - Processo ja respondido via sistema :" + cWFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					Return .T.
				EndIf

				// Verifica se o pedido de compra esta aprovado
				// Se estiver, finaliza o processo
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial()+Alltrim(SCR->CR_NUM))

				IF SC7->C7_CONAPRO <> "B"  // NAO ESTIVER BLOQUEADO
					U_CONSOLE("2 - Processo ja respondido via sistema :" + cWFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					Return .T.
				ENDIF

				// REPosiciona na tabela de Alcadas 
				DBSelectArea("SCR")
				DBSetOrder(2)
				DBSeek(cChaveSCR)
				
				// verifica quanto a saldo de al็ada para aprova็ใo				
				// Se valor do pedido estiver dentro do limite Maximo e minimo 
				// Do aprovador , utiliza o controle de saldos, caso contrแrio nao
				// faz o tratamento como vistador.

				nTotal := SCR->CR_TOTAL
				
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial()+SC7->C7_APROV+SCR->CR_APROV)
				
				If SAL->AL_LIBAPR == "A" .AND. MaAlcLim(SCR->CR_APROV,SCR->CR_TOTAL,SCR->CR_MOEDA,SCR->CR_TXMOEDA) .AND. EMPTY(cWF)
					aRetSaldo 	:= MaSalAlc(SCR->CR_APROV,dDataBase)  // Funcao do protheus
					nSaldo 	 	:= aRetSaldo[1]
					CRoeda 	 	:= A097Moeda(aRetSaldo[2])// Funcao do protheus
					nTotal   	:= xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
					      
					nSalDif := nSaldo - nTotal
					If (nSalDif) < 0
					        
						Reclock("SCR",.F.)
						SCR->CR_WF		:= "3" // Status 3 - rejeitado por saldo
						MSUnlock()
						
						U_CONSOLE("2 - Status 3 - rejeitado por saldo" )
						U_CONSOLE("2 - Semaforo Verde" )
						U_Semaforo(nWFPC2)
//						EXIT
					EndIf
				EndIf

				lLiberou := U_MaAlcDoc({SCR->CR_NUM,"PC",nTotal,SCR->CR_APROV,,SC7->C7_APROV,,,,,cObs},dDataBase,If(cOpc=="S",4,6), cWF)
			//			Numero	,tipo,valor total,cod aprova,cod user,grupo aprov,aprov superior,moeda,tx moeda,dt emissao, grp compras

				_lProcesso := .T.
				
				If lLiberou
					dbSelectArea("SC7")
					dbSetOrder(1)
					dbSeek(xFilial()+Alltrim(SCR->CR_NUM))
			        While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == SCR->CR_FILIAL+TRIM(SCR->CR_NUM)
			            
			            //INICIO CHAMADO 033773 - WILLIAM COSTA
			            dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("W04316PC-1 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + SCR->CR_FILIAL+TRIM(SCR->CR_NUM) + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + "L")  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "W04316PC" 
						MsUnlock()  
						ZBE->(dbCloseArea())
						dbSelectArea("SC7")
						//FINAL CHAMADO 033773 - WILLIAM COSTA 
			        
		                Reclock("SC7",.F.)
		                SC7->C7_CONAPRO := "L"
		                MsUnlock()
		                
		                //INICIO CHAMADO 033773 - WILLIAM COSTA
			            dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("W04316PC-2 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + SCR->CR_FILIAL+TRIM(SCR->CR_NUM) + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + "L")  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "W04316PC" 
						MsUnlock()  
						ZBE->(dbCloseArea())
						dbSelectArea("SC7")
						//FINAL CHAMADO 033773 - WILLIAM COSTA
		                
		                dbSkip()
			        EndDo
				EndIf
			EndIf				

			U_CONSOLE("2 - Semaforo Verde" )
			U_Semaforo(nWFPC2)

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ3 - Envia resposta de pedido bloqueado para o compradorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
	CASE _nOpc == 3

			CONOUT("	******")
			CONOUT("	******")
			CONOUT("	  ***")
			CONOUT("	 *** ")
			CONOUT("	 *****")
			CONOUT("	  *** ")		
			CONOUT("	 ***")		
			CONOUT("	***	")		
			U_CONSOLE("3 - Envia resposta de pedido bloqueado para o comprador")
			U_CONSOLE("3 - EmpFil:" + cEmpAnt + cFilAnt)
			
			CHKfile("SC7")	// Pedido de Compras
			CHKFile("SCR")  // Documentos com al็adas
			CHKFile("SCR",.F.,"TMP")
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Seleciona os registros do SCR - DBF / INDREGUA                         ณ
			//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			_cIndex := CriaTrab(,.F.)
			
			_cFiltro := ""
			_cFiltro += " CR_FILIAL=='" + cFilAnt + "' 	.AND."  // Filial
			_cFiltro += " CR_TIPO=='PC'   .AND. "				// Pedido de compra
			_cFiltro += " CR_STATUS=='04' .AND. "				// Reprovado 
			_cFiltro += " !EMPTY(CR_LIBAPRO) .AND. "			// Seleciona o Aprovador que reprovou
			_cFiltro += " CR_WF$' |2'           "				// ' '-Reprovado manualmente / 2-reprovado via workflow
			
			_cOrdem	 := "CR_FILIAL+CR_NUM"
			
			dbSelectArea("TMP")
			
			IndRegua("TMP",_cIndex,_cOrdem,,_cFiltro,"") //"Selecionando Registros..."
			
			#IFNDEF TOP
				dbSetIndex(_cIndex+OrdBagExt())
			#ENDIF
			                            
			dbGotop()
			While !TMP->(Eof())
				_cWFId 	:= EnviaPc(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER, TMP->CR_APROV, TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), TMP->CR_TOTAL, "4")

				DBSelectarea("SCR")
				DBSetOrder(2)
				IF DBSeek(TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
					Reclock("SCR",.F.)
					SCR->CR_WF		:= "1"			// Status 1 - envio email
	  				SCR->CR_WFID	:= _cWFId		// Rastreabilidade
					MSUnlock()
				ENDIF
					
				_lProcesso := .T.
							
				dbSelectArea("TMP")
				DBSkip()
			End
			
			dbSelectArea("TMP")
			dbClearFilter()
			dbCloseArea()
			Ferase(_cIndex+OrdBagExt())

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ4 - Processa O RETORNO DO EMAIL DE PC REPROVADO       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
	CASE _nOPC	== 4

			CONOUT("	  ****")
			CONOUT("	 ** **")
			CONOUT("	**  **")
			CONOUT("	**  **")
			CONOUT("	******")
			CONOUT("	******")
			CONOUT("	   ***")
			CONOUT("	   ***")
	    
			U_CONSOLE("4 - Processa O RETORNO DO EMAIL DE PC REPROVADO")
			U_CONSOLE("4 - EmpFil:" + cEmpAnt + cFilAnt)

			U_CONSOLE("4 - Semaforo Vermelho" )
			nWFPC4 := U_Semaforo("WFPC4")
			
			ChkFile("SCR")
			ChkFile("SAL")
			ChkFile("SC7")
			ChkFile("SCS")                    
			ChkFile("SAK")                    
			ChkFile("SM2")                    

			if oprocess <> nil
				cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
				cChaveSCR	:= alltrim(oProcess:oHtml:RetByName("CHAVE"))
				cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
				cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))
//				cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
				
				U_CONSOLE("4 - Chave :" + cChaveSCR)
				U_CONSOLE("4 - Opc   :" + cOpc)
				CONOUT("4***>>>>>>>>>>OBSERVACAO: "+ cObs)
				oProcess:Finish() // FINALIZA O PROCESSO
			ENDIF

			// Posiciona na tabela de Alcadas 
			DBSelectArea("SCR")
			DBSetOrder(2)
			DBSeek(cChaveSCR)
			
			IF !FOUND() .OR. TRIM(SCR->CR_WFID) <> TRIM(cWFID)
				U_CONSOLE("4 - Processo nao encontrado : " + cWFID + " Processo Atual : " + SCR->CR_WFID)
				U_CONSOLE("4 - Semaforo Verde" )
				U_Semaforo(nWFPC4)
				Return .T.
			ENDIF
			
			Reclock("SCR",.F.)
			SCR->CR_WF		:= "2"	// Status 2 - respondido
			MSUnlock()

			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(xFilial()+Alltrim(SCR->CR_NUM))

			IF !FOUND() 
				U_CONSOLE("4 - Pedido nao encontrado" + SCR->CR_NUM)
				U_CONSOLE("4 - Semaforo Verde" )
				U_Semaforo(nWFPC4)
				Return .T.
			ENDIF
/*			
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณParametrosณ ExpA1 = Array com informacoes do documento                 ณฑฑ
ฑฑณ          ณ       [1] Numero do documento                              ณฑฑ
ฑฑณ          ณ       [2] Tipo de Documento                                ณฑฑ
ฑฑณ          ณ       [3] Valor do Documento                               ณฑฑ
ฑฑณ          ณ       [4] Codigo do Aprovador                              ณฑฑ
ฑฑณ          ณ       [5] Codigo do Usuario                                ณฑฑ
ฑฑณ          ณ       [6] Grupo do Aprovador                               ณฑฑ
ฑฑณ          ณ       [7] Aprovador Superior                               ณฑฑ
ฑฑณ          ณ       [8] Moeda do Documento                               ณฑฑ
ฑฑณ          ณ       [9] Taxa da Moeda                                    ณฑฑ
ฑฑณ          ณ      [10] Data de Emissao do Documento                     ณฑฑ
ฑฑณ          ณ      [11] Grupo de Compras                                 ณฑฑ
ฑฑณ          ณ ExpD1 = Data de referencia para o saldo                    ณฑฑ
ฑฑณ          ณ ExpN1 = Operacao a ser executada                           ณฑฑ
ฑฑณ          ณ       1 = Inclusao do documento                            ณฑฑ
ฑฑณ          ณ       2 = Estorno do documento                             ณฑฑ
ฑฑณ          ณ       3 = Exclusao do documento                            ณฑฑ
ฑฑณ          ณ       4 = Aprovacao do documento                           ณฑฑ
ฑฑณ          ณ       5 = Estorno da Aprovacao                             ณฑฑ
ฑฑณ          ณ       6 = Bloqueio Manual da Aprovacao                     ณฑฑ
ฑฑณ          ณ ExpC1 = Respondido a 1 Vez ou a 2						        ณฑฑ
ฑฑณ          ณ ExpB1 = Chamado via Menu do Sistema .T. or .F.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

			IF cOpc	== "S"  // Submete o pedido de compra a nova aprova็ใo ?
				lEstorna := U_MaAlcDoc({SCR->CR_NUM,"PC",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,SC7->C7_APROV},SC7->C7_EMISSAO,5)
			//			Numero,tipo,valor total,cod aprova,cod user,grupo aprov,aprov superior,moeda,tx moeda,dt emissao, grp compras
				_lProcesso := .T.

				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial()+Alltrim(SCR->CR_NUM))

				// NUMERO DE VEZES EM QUE ESSE PC ESTA SENDO SUBMETIDO A UMA NOVA APROVACAO				    
				
		        While !SC7->(Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == SCR->CR_FILIAL+TRIM(SCR->CR_NUM)
		        
		         	//INICIO CHAMADO 033773 - WILLIAM COSTA
		            dbSelectArea("ZBE")
					RecLock("ZBE",.T.)
						Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
						Replace ZBE_DATA 	   	WITH dDataBase
						Replace ZBE_HORA 	   	WITH TIME()
						Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
						Replace ZBE_LOG	        WITH ("W04316PC-3 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + SCR->CR_FILIAL+TRIM(SCR->CR_NUM) + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + "B")  
						Replace ZBE_MODULO	    WITH "COMPRAS"
						Replace ZBE_ROTINA	    WITH "W04316PC" 
					MsUnlock()  
					ZBE->(dbCloseArea())
					dbSelectArea("SC7")
					//FINAL CHAMADO 033773 - WILLIAM COSTA
		         	
	                Reclock("SC7",.F.)
	                SC7->C7_CONAPRO := "B"
		            SC7->C7_WFNAPR  :=  SC7->C7_WFNAPR + 1  
	                MsUnlock()                            
	                
	                //INICIO CHAMADO 033773 - WILLIAM COSTA
		            dbSelectArea("ZBE")
					RecLock("ZBE",.T.)
						Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
						Replace ZBE_DATA 	   	WITH dDataBase
						Replace ZBE_HORA 	   	WITH TIME()
						Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
						Replace ZBE_LOG	        WITH ("W04316PC-4 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " CHAVE : " + SCR->CR_FILIAL+TRIM(SCR->CR_NUM) + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " Variavel: " + "B")  
						Replace ZBE_MODULO	    WITH "COMPRAS"
						Replace ZBE_ROTINA	    WITH "W04316PC" 
					MsUnlock()  
					ZBE->(dbCloseArea())
					dbSelectArea("SC7")
					//FINAL CHAMADO 033773 - WILLIAM COSTA
	                
	                dbSkip()
		        EndDo
			EndIf				
			
			U_CONSOLE("4 - Semaforo Verde" )
			U_Semaforo(nWFPC4)

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ5 - Envia resposta de pedido aprovado para o compradorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

	CASE _nOpc == 5
                                
			CONOUT("	******")
			CONOUT("	******")
			CONOUT("	**    ")
			CONOUT("	*****")
			CONOUT("	  ****")
			CONOUT("	   ***")
			CONOUT("	   ***")
			CONOUT("	 ****")
			U_CONSOLE("5 - Envia resposta de pedido APROVADO para o comprador")
			U_CONSOLE("5 - EmpFil:" + cEmpAnt + cFilAnt)

//			CHKfile("SC7", .F., "TMP")	// Pedido de Compras
			CHKFile("SCR")              // Documentos com al็adas
			CHKFile("SC7")
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Seleciona os registros do SCR - DBF / INDREGUA                         ณ
			//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
/*			_cIndex := CriaTrab(,.F.)
			
			_cFiltro := ""
			_cFiltro += " C7_FILIAL=='" + cFilAnt + "' 	.AND."  // Filial
			_cFiltro += " C7_TIPO== 1     .AND. "				// Pedido de compra
			_cFiltro += " C7_CONAPRO=='L' .AND. "				// Aprovado
			_cFiltro += " EMPTY(C7_XWF)"							// ' ' - Nao enviado
			
			_cOrdem	 := "C7_FILIAL+C7_NUM+C7_ITEM"
*/
// RICARDO LIMA - 13/11/17
			cQuery:="SELECT * "+;
					"FROM "+retsqlname("SC7")+" "+;
					"WHERE C7_FILIAL='"+cFilAnt+"' AND "+;
					"C7_TIPO= '1' AND "+;
					"C7_CONAPRO='L' AND C7_XWF='' AND D_E_L_E_T_= '' "+;
					"ORDER BY C7_FILIAL,C7_NUM,C7_ITEM"

			TCQUERY cQuery new alias "TMP"			
			dbSelectArea("TMP")
			
//			IndRegua("TMP",_cIndex,_cOrdem,,_cFiltro,"") //"Selecionando Registros..."
			
/*			#IFNDEF TOP
				dbSetIndex(_cIndex+OrdBagExt())
			#ENDIF
*/			
			dbGotop()
			While !TMP->(Eof())
			                              
				_cNum	:= TMP->C7_NUM                       
				_cWFID   := ""
				
				DBSelectarea("SCR")
				DBSetOrder(1)
				IF DBSeek(TMP->(C7_FILIAL+"PC"+C7_NUM),.F.)
					
	    			IF TMP->C7_FILIAL 	== SCR->CR_FILIAL 	.AND. ;
	            		SCR->CR_TIPO 	== "PC" 			.AND. ;
		    	       	TRIM(TMP->C7_NUM) 	== TRIM(SCR->CR_NUM)
						CONOUT(">>>>>>>>> ENVIANDO O E-MAIL DO PC" +_cNum )
						_cWFId 	:= EnviaPc(TMP->C7_FILIAL, TMP->C7_NUM, TMP->C7_USER,SCR->CR_USERLIB,SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "5")
						_lProcesso := .T.
					ENDIF
						           
					While !TMP->(EOF()) .AND. _cNum == TMP->C7_NUM .AND. !EMPTY(_cWFID)
						_cNum	:= TMP->C7_NUM	
						DBSelectarea("SC7")
						DBSetOrder(1)
						IF DBSeek(TMP->(C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN))
							Reclock("SC7",.F.)
							SC7->C7_XWF		:= "1"			// Status 1 - envio email // RICARDO LIMA - 13/11/17
				  			SC7->C7_XWFID	:= _cWFId		// Rastreabilidade        // RICARDO LIMA - 13/11/17
							MSUnlock()
						ENDIF
					
						TMP->(DBSkip())
					END
				Else
					TMP->(DBSkip())
				Endif
			End
			
			dbSelectArea("TMP")
//			dbClearFilter()
			dbCloseArea()
//			Ferase(_cIndex+OrdBagExt())
		CASE _nOpc == 6

			CONOUT("| 6 - Processa TIMEOUT|")
/*			
//			nWFPC2 := U_Semaforo("WFPC2")

			ChkFile("SCR")
			ChkFile("SAL")
			ChkFile("SC7")
			ChkFile("SCS")                    
			ChkFile("SAK")                    
			ChkFile("SM2")                    
        
			cChaveSCR	:= oProcess:aParams[1]
			cWFID		:= oProcess:aParams[2]
			_cFilial	:= Substr(cChaveSCR,1,2)
			_cNum		:= Substr(cChaveSCR,5,6)

				// Posiciona na tabela de Alcadas 
			DBSelectArea("SCR")
			DBSetOrder(2)
			DBSeek(cChaveSCR)
				
				IF !FOUND() 	//"Este processo nao foi encontrado e portanto deve ser descartado
					// abre uma notificacao a pessoa que respondeu
					
					U_CONSOLE("6 - Processo nao encontrado :" + cWFID + " Processo atual :" + SCR->CR_WFID)
					Return .T.
				ENDIF
				
				If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
					U_CONSOLE("6 - Processo ja respondido via sistema :" + cWFID)
//					U_Semaforo(nWFPC2)
					Return .T.
				EndIf

				// Verifica se o pedido de compra esta aprovado
				// Se estiver, finaliza o processo
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(xFilial()+Alltrim(SCR->CR_NUM))

				IF SC7->C7_CONAPRO <> "B"  // NAO ESTIVER BLOQUEADO
					U_CONSOLE("6 - Processo ja respondido via sistema :" + cWFID)
//					U_Semaforo(nWFPC2)
					Return .T.
				ENDIF

				// POSICIONA no arquivo de alcadas para manda para o proximo aprovador
				DBSelectArea("SCR")
				DBSKIP(1)
				If (SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM) <> SUBSTR(cChaveSCR,1,10)

					// fecha o scr com o SCR->CR_STATUS = 05
					U_CONSOLE("6 - Processo sem aprovador superior :" + cWFID)
					Return
				Endif

				dbSelectArea("SAK")
				dbSetOrder(1)
				dbSeek(xFilial("SAK")+SCR->CR_APROV)
				oProcess  	:NewTask( "REEnvio PC : "+_cFilial + _cNum, "\workflow\HTML\PCAPROV.HTM",.t.)
					
				oProcess:cSubject 	:= "ReAprovacao PC " + _cFilial + "/" +  _cNum
				oProcess:bReturn  	:= "U_W04316PC(2)" 
		//		_aPeriodo	:=  u_ConsisteData(SAK->AK_TIMEOUT)
		//		AaDd(oProcess:btimeout, {"U_W04316PC(6)" , _aPeriodo[1],_aPeriodo[2],_aPeriodo[3]})
				AaDd(oProcess:btimeout, {"U_W04316PC(6)" , 00,00,01})
				oProcess:cTo      	:= UsrRetMail(SAK->AK_USER)
//				oProcess:cTo      	:= "heraldo@adoro.com.br"
				oProcess:cBcc		:=	"heraldo@adoro.com.br"
				oProcess:aParams[1]	:= SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_USER
		//		oProcess:UserSiga	:= SC7->C7_USER
				oProcess:NewVersion(.T.)
//				oProcess:attachfile(cAttachFile)	
				oProcess:Start()
				conout("REENVIO REALIZADO!!!!")
*/
ENDCASE			

IF 	_lProcesso 
	U_CONSOLE(" Mensagem processada " )
ELSE
	U_CONSOLE(" Nao houve processamento")
ENDIF	
			
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnviaPC   บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ _cWF ' ' - Envia email para aprovador                      บฑฑ
ฑฑบ          ณ _cWF '3' - Reenvia email para aprovador, foi rejeitado     บฑฑ
ฑฑบ          ณ            por insuficiencia de saldo				           บฑฑ
ฑฑบ          ณ _cWF '4' - Envia email para o comprador informando que o PCบฑฑ
ฑฑบ          ณ            estแ reprovado								           บฑฑ
ฑฑบ          ณ _cWF '5' - Envia email para o comprador informando que o PCบฑฑ
ฑฑบ          ณ            estแ aprovado								      	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EnviaPC(_cFilial,_cNum, _cUser, _cAprov, _cChave, _nTotal, _cWF)
	lDetalhe := .F.	
	lObs		:= .F.	

	cAttachFile := TRIM("\WORKFLOW\html\temp\detalhes do pedido "+ALLTRIM(cEmpAnt)+ALLTRIM(_cFilial)+ALLTRIM(_cNum)+".htm")
	
	_cNum := TRIM(_cNum)

	ChkFile("SE4")
	ChkFile("SC1")
	ChkFile("SC8")
	ChkFile("SA2")
	ChkFile("SB1")
	ChkFile("SBM")
	ChkFile("SAK")

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+cFilAnt)
	
	DBSelectArea("SC7")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum)

	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+SC7->C7_COND)

	DBSelectArea("SAK")		// APROVADOR
	DBSetOrder(1)
	DBSeek(xFilial("SAK")+_cAprov)
	
	

	//--------------------------- 1 ENVIO DE EMAIL PARA APROVACAO
	IF EMPTY(TRIM(_cWF))    
		oProcess          	:= TWFProcess():New( "000001", "Envio Aprovacao Pedido de Compra :" + _cFilial + "/" +  TRIM(_cNum) )
		oProcess          	:NewTask( "Envio Pedido de Compra : "+_cFilial + _cNum, "\workflow\HTML\PCAPROV.HTM" )
		oProcess:cSubject 	:= "Aprovacao Pedido de Compra " + _cFilial + "/" +  _cNum
		oProcess:bReturn  	:= "U_W04316PC(2)" 
//		_aPeriodo	:=  u_ConsisteData(SAK->AK_TIMEOUT)
//		AaDd(oProcess:btimeout, {"U_W04316PC(6)" , _aPeriodo[1],_aPeriodo[2],_aPeriodo[3]})
		AaDd(oProcess:btimeout, {"U_W04316PC(6)" , 00,00,01})
		oProcess:cTo      	:= UsrRetMail(_cUser)
//		oProcess:cTo      	:= "heraldo@adoro.com.br"
//		oProcess:cBcc		:=	"heraldo@adoro.com.br"
		oProcess:UserSiga	:= SC7->C7_USER
		oProcess:NewVersion(.T.)
		oProcess:attachfile(cAttachFile)
		lDetalhe := .T.	
		lObs	:= .T.	
		AADD(oProcess:aParams, _cChave)
		AADD(oProcess:aParams, oProcess:fProcessId)
	
	   	oHtml     			:= oProcess:oHTML
	
		// Hidden Fields
		oHtml:ValByName( "CHAVE"	    , _cChave)
		oHtml:ValByName( "CFILANT"	    , cFilAnt)
		oHtml:ValByName( "WF"   		, TRIM(_cWF))
		oHtml:ValByName( "WFID"			, oProcess:fProcessId)

		//Cabe็alho
		oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL + ' [ ' + SM0->M0_NOME + '/' + SM0->M0_FILIAL + ' ]' )
		oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
		oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
		oHtml:ValByName( "CR_TOTAL"		, TRANSFORM(_nTotal,'@E 999,999.99'))
		oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
		oHtml:ValByName( "CR_USER"		, UsrFullName(_cUser))
		oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
		oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)
		
		oHtml:ValByName( "OBS"		    , "" )
	ENDIF
	
	//--------------------------- 3 REAPROVAวรO - RESPOSTA REJEITADA POR SALDO
	IF TRIM(_cWF) == "3"	
		oProcess          	:= TWFProcess():New( "000002", "Reenvio Aprovacao Pedido de Compra :" + _cFilial + "/" +  TRIM(_cNum) )
		oProcess          	:NewTask( "Reenvio Pedido de Compra : "+_cFilial + _cNum, "\workflow\HTML\PCAPROV2.HTM" )
		oProcess:cSubject 	:= "Reaprovacao Pedido de Compra " + _cFilial + "/" + _cNum
		oProcess:bReturn  	:= "U_W04316PC(2)" 
		oProcess:cTo      	:= UsrRetMail(_cUser)
//		oProcess:cTo      	:= "heraldo@adoro.com.br"
//		oProcess:cBcc		:=	"heraldo@adoro.com.br"
		oProcess:UserSiga	:= SC7->C7_USER
		oProcess:NewVersion(.T.)
		oProcess:attachfile(cAttachFile)
		lDetalhe := .T.	
		lObs		 := .T.	
	
	   	oHtml     			:= oProcess:oHTML
	
		// Hidden Fields
		oHtml:ValByName( "CHAVE"	    , _cChave)
		oHtml:ValByName( "CFILANT"	    , cFilAnt)
		oHtml:ValByName( "WFID"			, oProcess:fProcessId)
		oHtml:ValByName( "WF"           , _cWF)
	
		//Cabe็alho
		oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL  + ' [ ' + SM0->M0_NOME + '/' + SM0->M0_FILIAL + ' ]' )
		oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
		oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
		oHtml:ValByName( "CR_TOTAL"		, TRANSFORM(_nTotal,'@E 999,999.99'))
		oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
		oHtml:ValByName( "CR_USER"		, UsrFullName(_cUser))
		oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
		oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)
		oHtml:ValByName( "OBS"		    , "" )

		aRetSaldo 	:= MaSalAlc(_cAPROV,dDataBase)  // Funcao do protheus
		_nSaldo 	:= aRetSaldo[1]
		
		oHtml:ValByName( "APROVADOR"    , UsrFullName(_cUser))
		oHtml:ValByName( "SALDO"	    , TRANSFORM(_nSaldo,'@E 999,999.99'))
		oHtml:ValByName( "HOJE"	    	, DTOC(dDATABASE))
			
	ENDIF


	//--------------------------- 4 ENVIO DE EMAIL PARA COMPRADOR - INFORMANDO SOBRE O PEDIDO REPROVADO
	IF TRIM(_cWF) == "4"	
		oProcess          	:= TWFProcess():New( "000003", "Envio p/comprador Pedido de Compra reprovado : " + _cFilial + "/" +  TRIM(_cNum) )
		oProcess          	:NewTask( "Envio Pedido de Compra reprovado : "+_cFilial + _cNum, "\workflow\HTML\PCREPROV.HTM" )
		oProcess:cSubject 	:= "Reprovacao do Pedido de Compra " + _cFilial + "/" +  _cNum
		oProcess:bReturn  	:= "U_W04316PC(4)" 
		oProcess:cTo      	:= UsrRetMail(SC7->C7_USER)
//		oProcess:cBcc		:=	"heraldo@adoro.com.br"
		oProcess:UserSiga	:= SC7->C7_USER
		oProcess:NewVersion(.T.)
	
	   	oHtml     			:= oProcess:oHTML
	
		// Hidden Fields
		oHtml:ValByName( "CHAVE"	    , _cChave)
		oHtml:ValByName( "CFILANT"	    , cFilAnt)
	
		//Cabe็alho
		oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL  + ' [ ' + SM0->M0_NOME + '/' + SM0->M0_FILIAL + ' ]' )
		oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
		oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
		oHtml:ValByName( "CR_TOTAL"		, TRANSFORM(_nTotal,'@E 999,999.99'))
		oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
		oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)
		oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
		oHtml:ValByName( "CR_USER"		, UsrFullName(_cUser))
		oHtml:ValByName( "WFID"			, oProcess:fProcessId)
	ENDIF


	//--------------------------- 5 ENVIO DE EMAIL PARA COMPRADOR - INFORMANDO SOBRE O PEDIDO APROVADO
	IF TRIM(_cWF) == "5"	
		oProcess          	:= TWFProcess():New( "000004", "Envio p/comprador Pedido de Compra aprovado : " + _cFilial + "/" +  TRIM(_cNum) )
		oProcess          	:NewTask( "Envio Pedido de Compra aprovado : "+_cFilial + _cNum, "\workflow\HTML\PCAPROV3.HTM" )
		oProcess:cSubject 	:= "Aprovacao do Pedido de Compra " + _cFilial + "/" +  _cNum
		oProcess:bReturn  	:= "" 
		oProcess:cTo      	:= UsrRetMail(SC7->C7_USER)
		If   _cUser == "000127" .or.  _cUser == "000317"
			oProcess:cCC      	:= "fabio@adoro.com.br"
		Endif
//		oProcess:cBcc		:=	"heraldo@adoro.com.br"
		oProcess:UserSiga	:= SC7->C7_USER
		oProcess:NewVersion(.T.)
	
	   	oHtml     			:= oProcess:oHTML
	
		//Cabe็alho
		oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL  + ' [ ' + SM0->M0_NOME + '/' + SM0->M0_FILIAL + ' ]' )
		oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
		oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
		oHtml:ValByName( "CR_TOTAL"		, TRANSFORM(_nTotal,'@E 999,999.99'))
		oHtml:ValByName( "A2_NOME"		, SA2->A2_NOME + " " + SA2->A2_COD)
		oHtml:ValByName( "E4_DESCRI"    , SE4->E4_DESCRI)
		oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER))
		oHtml:ValByName( "CR_USERLIB"	, UsrFullName(_cAprov))
	ENDIF

	IF lDetalhe
		// Cria o pedido de detalhe
		oHtmlDet := TWFHtml():New("\workflow\HTML\PCDetalhe.htm")
	  	oHtmlDet:ValByName("c7_num",_cNum)
	  	oHtmlDet:ValByName("c7_filial",_cFilial  + ' [ ' + SM0->M0_NOME + '/' + SM0->M0_FILIAL + ' ]' )
	ENDIF
	
	//-------------------------------------------------------------
	// ALIMENTA A TELA DE ITENS DO PEDIDO DE COMPRA
	//-------------------------------------------------------------
	While !SC7->(EOF()) .AND. SC7->C7_FILIAL == _cFilial .AND. SC7->C7_NUM == _cNum
                                              
		DBSELECTAREA("SB1")
		DBSetOrder(1)
		DBSeek(xFilial()+SC7->C7_PRODUTO)

		DBSELECTAREA("SBM")
		DBSetOrder(1)
		DBSeek(xFilial()+SB1->B1_GRUPO)
                                                        
		AAdd( (oHtml:ValByName( "t1.1"    )), SC7->C7_ITEM)
		AAdd( (oHtml:ValByName( "t1.2"    )), SC7->C7_PRODUTO)
		AAdd( (oHtml:ValByName( "t1.3"    )), SB1->B1_DESC)
		AAdd( (oHtml:ValByName( "t1.4"    )), SB1->B1_UM)
		AAdd( (oHtml:ValByName( "t1.5"    )), TRANSFORM(SC7->C7_QUANT,'@E 999,999.999'))
		AAdd( (oHtml:ValByName( "t1.6"    )), TRANSFORM(SC7->C7_PRECO,'@E 999,999.9999'))
		AAdd( (oHtml:ValByName( "t1.7"    )), TRANSFORM(SC7->C7_IPI,'@E 99.99'))
		AAdd( (oHtml:ValByName( "t1.8"    )), TRANSFORM(SC7->C7_TOTAL,'@E 99,999,999.99'))
		AAdd( (oHtml:ValByName( "t1.9"    )), SC7->C7_DATPRF)
		AAdd( (oHtml:ValByName( "t1.10"    )), SC7->C7_CC)
		AAdd( (oHtml:ValByName( "t1.11"    )), SC7->C7_CONTA)

		IF lDetalhe
			PCDetalhe(SC7->C7_PRODUTO,SC7->C7_PRECO,SB1->B1_DESC, SC7->C7_NUMCOT, oHtmlDet,SC7->C7_NUM)
		ENDIF
		         	                                 
		SC7->(dbSkip())
	Enddo

	//-------------------------------------------------------------
	// ALIMENTA A TELA DE PROCESSO DE APROVAวรO DE PEDIDO DE COMPRA
	//-------------------------------------------------------------
	
	_cCHAVESCR := SUBS(_cCHAVE, 1, 24)
	
	DBSelectarea("SCR")
	DBSetOrder(1)
	DBSeek(_cCHAVESCR,.T.)
	
	WHILE !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == _cCHAVESCR
		cSituaca := ""
		Do Case
             Case SCR->CR_STATUS == "01"
                     cSituaca := "Aguardando"
             Case SCR->CR_STATUS == "02"
                     cSituaca := "Em Aprovacao"
             Case SCR->CR_STATUS == "03"
                     cSituaca := "Aprovado"
             Case SCR->CR_STATUS == "04"
                     cSituaca := "Bloqueado"
                     lBloq := .T.
             Case SCR->CR_STATUS == "05"
                     cSituaca := "Nivel Liberado"
        EndCase	
                                             
		_cT4 := UsrRetName(SCR->CR_USERLIB)
		_cT6 := SCR->CR_OBS
		
		AAdd( (oHtml:ValByName( "t.1"    )), SCR->CR_NIVEL)
		AAdd( (oHtml:ValByName( "t.2"    )), UsrFullName(SCR->CR_USER))
		AAdd( (oHtml:ValByName( "t.3"    )), cSituaca    )
		AAdd( (oHtml:ValByName( "t.4"    )), IIF(EMPTY(_cT4),"", _cT4))
		AAdd( (oHtml:ValByName( "t.5"    )), DTOC(SCR->CR_DATALIB))
		AAdd( (oHtml:ValByName( "t.6"    )), IIF(EMPTY(_cT6),"", _cT6))
		
		SCR->(DBSkip())
    ENDDO

	//-------------------------------------------------------------
	// OBSERVACAO - SOLICITACAO DE COMPRAS
	//-------------------------------------------------------------

	IF lOBS    
		aViewSC1 := MontaSC(_cNum)

		if Len(aViewSC1) > 0 		
			For nLin := 1 TO LEN(aViewSC1)		
				AAdd( (oHtml:ValByName( "t2.1"    )), aViewSC1[nLin])
			Next
		Else
			AAdd( (oHtml:ValByName( "t2.1"    )), "Nao ha observacoes")
		EndIf
	ENDIF

	_cWFID := oProcess:fProcessId

	IF lDetalhe           
		oHtmlDet:savefile(cAttachFile)
	Endif
	
	oProcess:Start()

	return _cWFId

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCDetalhe บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCDetalhe(cCod, nPreco,cDesc, cNumCot, oHtmlDet, _fcNum)
//Local aViewSC7 := {};aViewSC8 := {}
aViewSC7 := {}
aViewSC8 := {}
cHtml	:= ""

IF cCod == Nil
	RETURN
ENDIF

IF cDesc == Nil .or. Empty(trim(cDesc))
	cDesc := "PRODUTO NAO ENCONTRADO"
ENDIF

nLimC7	 := GetNewPar("MV_WFMAXC7",3)
nLimC8	 := GetNewPar("MV_WFMAXC8",3)

aViewSC7 := MontaPC(cCod,_fCNum)
aViewSC8 := MontaCT(cCod,cNumCot)
                                
nLenSC7	 := IIF(LEN(aViewSC7) > nLimC7, nLimC7, LEN(aViewSC7))
nLenSC8  := IIF(LEN(aViewSC8) > nLimC8, nLimC8, LEN(aViewSC8))

cHtml := ''
cHtml += cCOD + ' - ' + RTRIM(cDesc) + ' &nbsp;' +"$ ATUAL:"+TRANSFORM(SC7->C7_PRECO,'@E 999,999.99')+ ' &nbsp;<br> '

IF LEN(aViewSC7) > 0 
	cHtml += '<table border="0" cellspacing="1" width="100%" bgcolor="#FFFFFF">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="100%" align="left"><b><font color="#000080" face="Tahoma" size="2">ฺltimos'
	cHtml += '	      Pedidos de Compras</font></b></td>'
	cHtml += '	  </tr>'
	cHtml += '	</table>'
	 
	cHtml += '	<table border="0" cellspacing="1" width="100%">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="10%"  align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Pedido</font></b></td>'
	cHtml += '	    <td width="2%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Item</font></b></td>'
	cHtml += '	    <td width="37%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Fornecedor</font></b></td>'
	cHtml += '	    <td width="6%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Qtde</font></b></td>'
	cHtml += '	    <td width="9%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Pre็o</font></b></td>'
	cHtml += '	    <td width="11%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Qtde'
	cHtml += '	      Entregue</font></b></td>'
	cHtml += '	    <td width="11%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Cond.Pgto</font></b></td>'
	cHtml += '	    <td width="10%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Dt.Entrega</font></b></td>'
	cHtml += '	  </tr>'
	 
	For nInd := 1 to nLenSC7
		cHtml += '	  <tr>'
		cHtml += '	    <td width="10%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][1] +'</font></td>'
		cHtml += '	    <td width="2%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">'   + aViewSC7[nInd][2] +'</font></td>'
		cHtml += '	    <td width="37%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][3] +'</font></td>'
		cHtml += '	    <td width="6%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][4] +'</font></td>'
		cHtml += '	    <td width="9%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][5] +'</font></td>'
		cHtml += '	    <td width="11%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][6] +'</font></td>'
		cHtml += '	    <td width="11%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][7] +'</font></td>'
		cHtml += '	    <td width="10%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC7[nInd][8] +'</font></td>'
		cHtml += '	  </tr>'
	Next
	cHtml += '	</table> &nbsp;<br> '
ELSE
	cHtml += '	<table border="0" cellspacing="1" width="100%" bgcolor="#FFFFFF">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="100%" align="left"><b><font color="#000080" face="Tahoma" size="2">Nใo hแ '
	cHtml += '	      Pedido de Compras</font></b></td>'
	cHtml += '	  </tr>'
	cHtml += '	</table>'
ENDIF

IF Len(aViewSC8) > 0 
	cHtml += '	<table border="0" cellspacing="1" width="100%" bgcolor="#FFFFFF">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="100%" align="left"><b><font color="#000080" face="Tahoma" size="2">'
	cHtml += '	      Cota็๕es</font></b></td>'
	cHtml += '	  </tr>'
	cHtml += '	</table>'
	
	cHtml += '	<table border="0" cellspacing="1" width="100%">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="10%"  align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Cota็ใo</font></b></td>'
	cHtml += '	    <td width="2%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Item</font></b></td>'
	cHtml += '	    <td width="39%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Fornecedor</font></b></td>'
	cHtml += '	    <td width="6%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Qtde</font></b></td>'
	cHtml += '	    <td width="10%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Pre็o</font></b></td>'
	cHtml += '	    <td width="22%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Cond.Pgto</font></b></td>'
	cHtml += '	    <td width="11%" align="center" bgcolor="#dfefff"><b><font face="Tahoma" size="1">Dt.Entrega</font></b></td>'
	cHtml += '	  </tr>'
	 
	For nInd := 1 to nLenSC8
		cHtml += '	  <tr>'
		cHtml += '	    <td width="10%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][1] +'</font></td>'
		cHtml += '	    <td width="2%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][2] +'</font></td>'
		cHtml += '	    <td width="39%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][3] +'</font></td>'
		cHtml += '	    <td width="6%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][4] +'</font></td>'
		cHtml += '	    <td width="10%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][5] +'</font></td>'
		cHtml += '	    <td width="22%" bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][6] +'</font></td>'
		cHtml += '	    <td width="11%"  bgcolor="#FFFFFF"><font size="1" face="Tahoma">' + aViewSC8[nInd][7] +'</font></td>'
		cHtml += '	  </tr>'
	Next
	cHtml += '	</table> &nbsp;<br> '
ELSE
	cHtml += '	<table border="0" cellspacing="1" width="100%" bgcolor="#FFFFFF">'
	cHtml += '	  <tr>'
	cHtml += '	    <td width="100%" align="left"><b><font color="#000080" face="Tahoma" size="2">Nใo hแ '
	cHtml += '	      Cota็๕es</font></b></td>'
	cHtml += '	  </tr>'
	cHtml += '	</table>'
ENDIF

cHtml += '<hr><hr>'

aAdd( (oHtmlDet:ValByName("t.1")), cHtml )
return            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaPC   บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaPC(cProduto, _cNumPed)
//Local aViewSC7 := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o cadastro de produtos                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea('SB1')
dbSetOrder(1)
If MsSeek(xFilial()+cProduto)
//		aViewSC7 := {}
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				cCursor:= CriaTrab(,.F.)
				lQuery := .T.
				cQuery := ""
				cQuery += "SELECT * FROM "+RetSqlName("SC7")+" WHERE "
				cQuery += "C7_FILIAL='"+xFilial("SC7")+"' AND "
				cQuery += "C7_PRODUTO='"+alltrim(cProduto)+"' AND "
				cQuery += "D_E_L_E_T_ <> '*' AND "
				cQuery += "C7_NUM <> '"+ _cNumPed+"' "
				cQuery += "ORDER BY C7_DATPRF DESC"
				cQuery := ChangeQuery(cQuery)
				SC7->(dbCommit())
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
				aStruQuery	:= SC7->(dbStruct())
				For nLoop := 1 To Len( aStruQuery )
					If aStruQuery[nLoop,2] <> "C"
						TCSetField(cCursor,AllTrim(aStruQuery[nLoop,1]),aStruQuery[nLoop,2],aStruQuery[nLoop,3],aStruQuery[nLoop,4])
					EndIf 										
				Next nLoop
				_nContar	:=	0
				While ( !Eof() )
					dbSelectArea("SE4")
					MsSeek(xFilial()+(cCursor)->C7_COND)
					dbSetOrder(1)
					dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial()+(cCursor)->C7_FORNECE+(cCursor)->C7_LOJA)
					dbSelectArea(cCursor)		
					aAdd(aViewSC7,{C7_NUM,C7_ITEM,SA2->A2_NOME,TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")),TransForm(C7_PRECO,PesqPict("SC7","C7_PRECO")),TransForm(C7_QUJE,PesqPict("SC7","C7_QUJE")),C7_COND+" - "+SE4->E4_DESCRI,DTOC(C7_DATPRF)})
					dbSkip()					
					_nContar ++
					If _nContar > nLimC7
                       Exit
					Endif
				EndDo
				If len(aViewSC7) < 3
					MONTAPROD(cProduto, _cNumPed)				
				Endif
			Else
		#ENDIF
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Seleciona os registros do SC8 - DBF / INDREGUA                         ณ
			//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cIndex := CriaTrab(,.F.)
			ChkFile("SC7",.F.,"TMPSC7")
			dbSelectArea("TMPSC7")
			cFiltro := ""
			cFiltro += "C7_FILENT=='"+xFilial("SC7")+"'.AND."
			cFiltro += "C7_PRODUTO=='"+cProduto+"'"
			IndRegua("TMPSC7",cIndex,"C7_FILENT+DTOS(C7_DATPRF)",,cFiltro,"") //"Selecionando Registros..."
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			dbGoBottom()
			While !Bof().And.Len(aViewSC7)<200
				dbSelectArea("SE4")
				MsSeek(xFilial()+TMPSC7->C7_COND)
				dbSetOrder(1)
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial()+TMPSC7->C7_FORNECE+TMPSC7->C7_LOJA)
				dbSelectArea("TMPSC7")
				aAdd(aViewSC7,{C7_NUM,C7_ITEM,SA2->A2_NOME,TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")),TransForm(C7_PRECO,PesqPict("SC7","C7_PRECO")),TransForm(C7_QUJE,PesqPict("SC7","C7_QUJE")),C7_COND+" - "+SE4->E4_DESCRI,DTOC(C7_DATPRF)})
				dbSkip(-1)
			End
			dbSelectArea("TMPSC7")
			dbClearFilter()
			dbCloseArea()
			Ferase(cIndex+OrdBagExt())
			
		#IFDEF TOP
			EndIf
		#ENDIF
EndIf	
Return aViewSC7

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaCT   บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	
Static Function MontaCT(cProduto, cNumCot)
Local aViewSC8 := {}

dbSelectArea('SB1')
dbSetOrder(1)
If MsSeek(xFilial()+cProduto)
		aViewSC8 := {}
		
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				cCursor:= CriaTrab(,.F.)
				lQuery := .T.
				cQuery := ""
				cQuery += "SELECT * FROM "+RetSqlName("SC8")+" WHERE "
				cQuery += "C8_FILIAL='"+xFilial("SC8")+"' AND "
				cQuery += "C8_PRODUTO='"+cProduto+"' AND "
				cQuery += "C8_NUM='"+cNumCot+"' AND "
				cQuery += "C8_PRECO <> 0  AND "
				cQuery += "D_E_L_E_T_ <> '*' "
				cQuery += "ORDER BY C8_DATPRF DESC"
				cQuery := ChangeQuery(cQuery)
				SC8->(dbCommit())
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
				aStruQuery	:= SC8->(dbStruct())
				For nLoop := 1 To Len( aStruQuery )
					If aStruQuery[nLoop,2] <> "C"
						TCSetField(cCursor,AllTrim(aStruQuery[nLoop,1]),aStruQuery[nLoop,2],aStruQuery[nLoop,3],aStruQuery[nLoop,4])
					EndIf 										
				Next nLoop
				While ( !Eof() )
					dbSelectArea("SE4")
					MsSeek(xFilial()+(cCursor)->C8_COND)
					dbSetOrder(1)
					dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial()+(cCursor)->C8_FORNECE+(cCursor)->C8_LOJA)
					dbSelectArea(cCursor)		
					aAdd(aViewSC8,{C8_NUM,C8_ITEM,SA2->A2_NOME,TransForm(C8_QUANT,PesqPict("SC8","C8_QUANT")),TransForm(C8_PRECO,PesqPict("SC8","C8_PRECO")),C8_COND+" - "+SE4->E4_DESCRI,DTOC(C8_DATPRF)})
					dbSkip()					
				EndDo
			Else
		#ENDIF
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Seleciona os registros do SC8 - DBF / INDREGUA                         ณ
			//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cIndex := CriaTrab(,.F.)
			ChkFile("SC8",.F.,"TMPSC8")
			dbSelectArea("TMPSC8")
			cFiltro := ""
			cFiltro += "C8_FILIAL=='"+xFilial("SC8")+"'.AND."
			cFiltro += "C8_PRODUTO=='"+cProduto+"'.AND."
			cFiltro += "C8_NUM=='"+cNumCot+"'.AND."
			cFiltro += "C8_PRECO<>0"
			IndRegua("TMPSC8",cIndex,"C8_FILIAL+DTOS(C8_DATPRF)",,cFiltro,"") //"Selecionando Registros..."
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			dbGoBottom()
			While !Bof().And.Len(aViewSC8)<200
				dbSelectArea("SE4")
				MsSeek(xFilial()+TMPSC8->C8_COND)
				dbSetOrder(1)
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial()+TMPSC8->C8_FORNECE+TMPSC8->C8_LOJA)
				dbSelectArea("TMPSC8")
				aAdd(aViewSC8,{C8_NUM,C8_ITEM,SA2->A2_NOME,TransForm(C8_QUANT,PesqPict("SC8","C8_QUANT")),TransForm(C8_PRECO,PesqPict("SC8","C8_PRECO")),C8_COND+" - "+SE4->E4_DESCRI,DTOC(C8_DATPRF)})
				dbSkip(-1)
			End
			dbSelectArea("TMPSC8")        
			dbClearFilter()
			dbCloseArea()
			Ferase(cIndex+OrdBagExt())
			
		#IFDEF TOP
			EndIf
		#ENDIF
		
EndIf	
return aViewSC8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaSC   บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	
Static Function MontaSC(cNumSC7)
Local aViewSC1 := {}

dbSelectArea('SC1')
dbSetOrder(6)
DBSeek(xFilial()+cNumSC7)

While !EOF() .AND. xFilial() == SC1->C1_FILIAL .AND. SC1->C1_PEDIDO == cNumSC7
                             
	IF !EMPTY(ALLTRIM(SC1->C1_OBS))
		If Ascan(aViewSC1, SC1->C1_OBS)==0
			AADD(aViewSC1 ,SC1->C1_OBS)
		Endif
	ENDIF
		
	SC1->(DBSkip())
EndDo

return aViewSC1
STATIC FUNCTION ESPACO(_cTexto)         

	_nLenText		:= len(_cTexto)
	_nTamanho		:= _nLenText / 2

Return(_nTamanho)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMOnta novo array com os codigos dos produtos antigosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Static Function MONTAPROD(cProduto, _cNumPed)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciona o cadastro de produtos                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DO CASE
		CASE left(cProduto,2) =="30"
			cProduto := "VPMP"+ (substr(cProduto,3,(len(cProduto)-2)))
		CASE left(cProduto,2) =="40"
			cProduto := "VPMM"+ (substr(cProduto,3,(len(cProduto)-2)))
		CASE left(cProduto,2) =="50"
			cProduto := "VPMC"+ (substr(cProduto,3,(len(cProduto)-2)))
	ENDCASE
	dbSelectArea('SB1')
	dbSetOrder(1)
	If MsSeek(xFilial()+cProduto)
//		aViewSC7 := {}
		cCursor:= CriaTrab(,.F.)
		lQuery := .T.
		cQuery := ""
		cQuery += "SELECT * FROM "+RetSqlName("SC7")+" WHERE "
		cQuery += "C7_FILIAL='"+xFilial("SC7")+"' AND "
		cQuery += "C7_PRODUTO='"+alltrim(cProduto)+"' AND "
		cQuery += "D_E_L_E_T_ <> '*' AND "
		cQuery += "C7_NUM <> '"+ _cNumPed+"' "
		cQuery += "ORDER BY C7_DATPRF DESC"
		cQuery := ChangeQuery(cQuery)
		SC7->(dbCommit())
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
		aStruQuery	:= SC7->(dbStruct())
		For nLoop := 1 To Len( aStruQuery )
			If aStruQuery[nLoop,2] <> "C"
				TCSetField(cCursor,AllTrim(aStruQuery[nLoop,1]),aStruQuery[nLoop,2],aStruQuery[nLoop,3],aStruQuery[nLoop,4])
			EndIf 										
		Next nLoop
		_nContar := 0
		While ( !Eof() )
			dbSelectArea("SE4")
			MsSeek(xFilial()+(cCursor)->C7_COND)
			dbSetOrder(1)
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial()+(cCursor)->C7_FORNECE+(cCursor)->C7_LOJA)
			dbSelectArea(cCursor)		
			aAdd(aViewSC7,{C7_NUM,C7_ITEM,SA2->A2_NOME,TransForm(C7_QUANT,PesqPict("SC7","C7_QUANT")),TransForm(C7_PRECO,PesqPict("SC7","C7_PRECO")),TransForm(C7_QUJE,PesqPict("SC7","C7_QUJE")),C7_COND+" - "+SE4->E4_DESCRI,DTOC(C7_DATPRF)})
			CONOUT("%%%%%%%%% MONTAPROD %%%%%%%%%%"+cProduto)
			dbSkip()					
			_nContar++
			If _nContar > nLimC7
            	Exit
			Endif
		EndDo
	Endif
Return


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o ณ ConsisteData ณ Autor ณ Business Ingelligence ณ Data ณ 01.01.00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤมฤฤยฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula o horario de Time-out, considerando hora util       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Modulo SIGAWF                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function CONSISTEDATA(periodo)

Local saldo := 0

U_ADINF009P('W04316PC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'1 - ENVIO DE EMAIL PARA APROVADORES,2 - RETORNO DE EMAIL COM RESPOSTA DE APROVADORES,3 - ENVIA RESPOSTA DE PEDIDO BLOQUEADO PARA O COMPRADOR,4 - PROCESSA O RETORNO DO EMAIL DE PC REPROVADO,5 - ENVIA RESPOSTA DE PEDIDO APROVADO PARA O COMPRADOR')

Nowdata := ddatabase
periodo := Val(Left(periodo,2)) + Val(Substr(periodo,4,2))/60
nowhora := Val(Left(Time(),2)) + Val(Substr(Time(),4,2))/60

pi := Val(Left(GetNewPar("MV_WFHINI", "00:00"),2)) + Val(Right(GetNewPar("MV_WFHINI", "00:00"),2))/60
pf := Val(Left(GetNewPar("MV_WFHFIM", "23:59"),2)) + Val(Right(GetNewPar("MV_WFHFIM", "23:59"),2))/60

horasuteis := pf - pi
horasinuteis :=   24 - (pf - pi)

_dDay   :=  DataValida(nowdata, .T.)
While _dDay  <>  nowdata
	nowdata := nowdata + 1
	_dDay   :=  DataValida(nowdata, .T.)
	if nowhora > pi
		saldo := saldo + (( 24 - nowhora ) + pi)
	elseif nowhora < pi
		saldo := saldo + (pi - nowhora) + 24
	else
		saldo := saldo + 24
	endif
	nowhora := pi
enddo

if nowhora <= Pf
	if nowhora < pi
		Saldo   := saldo + (pi - nowhora)
		nowhora := pi
	endif
else
	saldo   := saldo + (24 - nowhora) + pi
	nowhora := pi
	nowdata := nowdata + 1
	_dDay   := nowdata
	nowdata := DataValida(nowdata, .T.)
	if _dDay  <>  nowdata
		saldo := saldo + ( 24 * (nowdata-_dDay))
	endif
endif

horafinal := nowhora + periodo

if horafinal <= pf
	saldo   := saldo + periodo
else
	saldo   := saldo + (pf - nowhora)
	periodo := periodo - (pf -nowhora)
	saldo   := saldo + horasinuteis
	nowdata := nowdata + 1
	_dDay   :=  nowdata
	nowdata := DataValida(nowdata, .T.)
	if _dDay  <>  nowdata
		saldo    := saldo + ( 24 * (nowdata - _dDay) )
	endif
	
	while periodo > horasuteis
		saldo    := saldo + 24
		nowdata  := nowdata + 1
		_dDay   :=  nowdata
		nowdata := DataValida(nowdata, .T.)
		if _dDay  <>  nowdata
			saldo    := saldo + ( 24 * ( nowdata-_dDay))
		endif
		periodo := periodo - horasuteis
	enddo
	saldo := saldo + periodo
endif

_nDias    := Int(saldo  /24)
_nHoras   := mod(int(saldo),24)

_nsaldo   := int(saldo)
if _nSaldo > saldo
	_nSaldo := _nSaldo - 1
endif

_nMinutos := round((saldo-int(saldo))*60,0)

Return{_nDias, _nHoras, _nMinutos}
