#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'Topconn.ch'   
#Include "AP5MAIL.ch"

/*/{Protheus.doc} User Function ADLOG022P
	Programa de WebService - desenvolvido para Fazer a leitura
	do Webservice CTAPLUS e gravar na tabela ZBB do protheus
	@type  Function
	@author WILLIAM COSTA 
	@since 20/06/2016
	@version 01
	@history Chamado T.I    - Fernando Sigoli 05/06/2019. Alteracao da condição de pediodo De/Ate na importação Abast
	@history Chamado T.I    - Fernando Sigoli 11/06/2019 Alteracao da condição de pediodo De/Ate na importação Abast
	@history Chamado 053926 - Everson 26/02/2020. Tratamento para considerar o sistema de origem do lançamento.
	@history Chamado 058732 - Everson 09/06/2020. Realizar baixa automática no estoque de consumo de óleo diesel. 
	@history Chamado 058824 - Everson 09/06/2020. Tratamento para o error log em situações em que a tag _ABASTECIMENTO não exista no xml de retorno.
	@history Chamado 058732 - Everson 11/06/2020. Alterada a validação de registro já baixado do estoque.
	@history Chamado 058732 - Everson 17/06/2020. Tratamento para vincular o centro de custo ao registro de abastecimento.
	@history Chamado 058732 - Everson 18/06/2020. Tratamento para númeração da solicitação ao armazém.
	@history Chamdo T.I.    - Everson 02/07/2020. Voltando função para obter o número da solicitação ao armazém.
	@history Chamado 059564 - Everson 09/07/2020. Adicionado log no retorno do web service.
	@history Chamado 059245 - Everson 13/07/2020. Adicionado tratamento para obter centro de custo na montagem de carga.
	@history Chamado T.I.   - Everson 23/07/2020. Tratamento para rotina baixar abastecimentos do dia anterior.
	@history Chamado 060424 - Everson 10/08/2020. Tratamento para vincular código de projeto na requisição ao armazém. 
	@history Chamado 060424 - Everson 11/08/2020. Tratamento para obter o sequencial da solicitação ao armazém pela função U_SXESXF. 
	@history Ticket 70142 	- Rodrigo Mello / Flek Solutions 22/03/2022. Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history ticket  69813  - Fernando Macieira - 22/03/2022 - Requisições Filial 02 948478 e 948479 - Produto 581459
	@history ticket  69813  - Fernando Macieira - 22/03/2022 - Requisições Filial 02 948478 e 948479 - Produto 581459
	@history ticket  69813  - Fernando Macieira - 22/03/2022 - Requisições Filial 02 948478 e 948479 - Produto 581459
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history ticket 70750 - Everson - 07/04/2022 - Adaptação do fonte para nova filial.
/*/
User Function ADLOG022P() // U_ADLOG022P()

	//Variáveis.
	Local dDataIni      := Nil
	Local dDataFin      := Nil
  
	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{}) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADLOG022P", .T., .F.)
		ConOut("[ADLOG022P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	ConOut( DToC(Date()) + " " + Time() + " INÍCIO DO SCHEDULE ADLOG022P")  

	U_ADINF009P(SUBSTRING(Alltrim(PROCNAME()),3,Len(Alltrim(PROCNAME()))) + '.PRW',SUBSTRING(Alltrim(PROCNAME()),3,Len(Alltrim(PROCNAME()))),"")
	
	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	//Everson - 09/06/2020. Chamado 058732.
	//Importa os dados do CTA-plus.
	//Inicio: Chamado T.I - Fernando Sigoli 11/06/2019 
	dDataIni	:= Date() - 30
	dDataFin	:= Date() - 1//Everson - 23/07/2020. Chamado T.I.
	//Fim: Chamado T.I - Fernando Sigoli 11/06/2019 
	impDados(dDataIni,dDataFin)

	//Gera solicitação ao armazém.
	gerSolic()

	//Gera pré-requisição ao armazém.
	gerPreReq()

	//Baixa solicitação ao armazém.
	baxSolic() 
	//

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("2") //Log fim.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	ConOut( DToC(Date()) + " " + Time() + " FINAL DO SCHEDULE ADLOG022P")

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	RpcClearEnv() 
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	 	    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADLOG022P")

Return Nil

/*/{Protheus.doc} impDados
	Realiza a importação dos dados de
	abastecimento dos sistema CTA-Plus.
	@type  Static Function
	@author Everson
	@since 09/06/2020
	@version 01
	/*/
Static Function impDados(dDataIni,dDataFin)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aMsgs			:= {}
	Local cHtmlPage		:= ""
	Local oXML          := Nil
	Local cErro	        := ""
	Local cAviso	    := ""
	Local oAbastecimento:= Nil  
	Local nCont         := 0         
	Local cDataini      := ""
	Local cDataFin      := ""
	Local cBomba        := Space(4)   
	Local nTraco        := 0
	Local cHtmlPage1    := ""
	Local lTerminaInt   := .F.
	
	//Everson - 09/06/2020. Chamado 058824.
	Local oCTaPlus		:= Nil
	Local oAbast		:= Nil
	//

	Local cCC 			:= "" //Everson - 17/06/2020. Chamado 058732.

	//
	Conout( DToC(Date()) + Time() + " ADLOG022P - impDados - Início importação de dados.")

	//
	While ! lTerminaInt  

		//
		Conout( DToC(Date()) + Time() + " ADLOG022P - impDados - importando dados de abastecimento (óleo diesel) de " + DToC(dDataIni) + " até " + DToC(dDataFin))	

		//
		cDataini := StrZero(Day(dDataIni),2) + '/' + StrZero(Month(dDataIni),2) + '/' + cValToChar(Year(dDataIni))
	  	cDataFin := StrZero(Day(dDataFin),2) + '/' + StrZero(Month(dDataFin),2) + '/' + cValToChar(Year(dDataFin))
	  	
		//
		cHtmlPage := Httpget('http://ctaplus.com.br:8080/SvWebSincronizaAbastecimentos?token=S2L8sh2kjQ&data_inicio=' + cDataini + '&data_fim=' + cDataFin)
		
		//Everson - 09/07/2020. Chamado 059564.
		logZBE("Início dados cHtmlPage",Alltrim(cValToChar(cHtmlPage)))

		//
		If cHtmlPage == Nil
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - Erro 0 - Erro no WebService: Ele está fora do ar." )
	    	lTerminaInt := .T.
			Aadd(aMsgs,"ADLOG022P - Erro 0 - Erro no WebService: Ele está fora do ar. ") 
			EnviaWF(aMsgs)
			Loop
	
		EndIf
		
		//
		oXML := XmlParser( cHtmlPage, "_", @cErro, @cAviso )  
		//Everson - 09/06/2020. Chamado 058824.
		If oXml == Nil
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - Erro 1 - Falha ao gerar Objeto XML : " + cError + " / " + cWarning )
	    	lTerminaInt := .T.
			Aadd(aMsgs,"ADLOG022P - Erro 1 - impDados - Falha ao gerar Objeto XML : " + cError + " / " + cWarning) 
			EnviaWF(aMsgs)
			Loop

		EndIf

		//Não localizou a tag _CTAPLUS. //Everson - 09/06/2020. Chamado 058824.
		oCTaPlus :=  XmlChildEx(oXML, "_CTAPLUS")
		If ValType(oCTaPlus) == 'U' // significa que acabou os abastecimentos
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - Erro 2 - Falha ao obter a tag _CTAPLUS.")
	    	lTerminaInt := .T.
			Aadd(aMsgs,"ADLOG022P - Erro 2 - impDados - Falha: não localizou a tag _CTAPLUS.") 
			EnviaWF(aMsgs)
			Loop
		
		EndIf

		//
		If Alltrim(oXml:_CTAPLUS:_STATUS:_CODIGO:TEXT) == '002'
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - código de status igual a 002.")
	    	lTerminaInt := .T.
			Aadd(aMsgs,"ADLOG022P - Erro 3 - impDados - Falha: código de status igual a 002.") 
			EnviaWF(aMsgs)
			Loop
			
		EndIf

		//Não localizou a tag _ABASTECIMENTOS. //Everson - 09/06/2020. Chamado 058824.
		oAbast   := XmlChildEx(oCTaPlus, "_ABASTECIMENTOS")
		If ValType(oAbast) == "U"
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - não localizou a tag _ABASTECIMENTOS.")                                   
	    	lTerminaInt := .T.
			Aadd(aMsgs,"ADLOG022P - Erro 4 - impDados - Falha: não localizou a tag _ABASTECIMENTOS.") 
			EnviaWF(aMsgs)
			Loop
		
		EndIf

		//	
		oAbastecimento := XmlChildEx(oAbast, "_ABASTECIMENTO")
		If ValType(oAbastecimento) == "U" // significa que acabou os abastecimentos
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - não há abastecimentos a serem importados.")                                  
			lTerminaInt := .T.
	  		Loop
		
		EndIf
		
		//
		If ValType(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO) == "O" 

			//
			Begin Transaction

				//
				cCC := getCCCrg(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VEICULO:_PLACA:TEXT), Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_DATA_INICIO:TEXT )) //Everson - 17/06/2020. Chamado 058732. //Everson - 13/07/2020. Chamado 059245.

				//
				DbSelectArea("ZBB")
				ZBB->(DbSetOrder(3)) //Chamado 053926 - Everson 26/02/2020.
				If ZBB->(DbSeek(FWxFilial("ZBB")+"A"+oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT , .T.))	//Chamado 053926 - Everson 26/02/2020.

					//
					If Alltrim(cValToChar(ZBB->ZBB_ESTOQU)) == "F" //Chamado 058732 - Everson 11/06/2020.

						Reclock("ZBB",.F.)
						
							ZBB->ZBB_IDABAS := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT 
							ZBB->ZBB_DTINI  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_DATA_INICIO:TEXT )
							ZBB->ZBB_HRINI  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_HORA_INICIO:TEXT 
							ZBB->ZBB_DTFIM  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_DATA_FIM:TEXT) 
							ZBB->ZBB_HRFIM  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_HORA_FIM:TEXT 
							ZBB->ZBB_VOLUME := Val(StrTran(StrTran(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VOLUME:TEXT),'.',""), ',', '.'))
							ZBB->ZBB_PLACA  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VEICULO:_PLACA:TEXT 
							ZBB->ZBB_PLAORI := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VEICULO:_PLACA:TEXT 
							nTraco          := At('-', oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_BOMBA:_NOME:TEXT)
							cBomba          := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_BOMBA:_NOME:TEXT
							ZBB->ZBB_BOMBA  := Alltrim(SUBSTR(cBomba,nTraco + 1,Len(cBomba)))
							ZBB->ZBB_SISTEM := "A" //Chamado 053926 - Everson 26/02/2020.
							ZBB->ZBB_CC		:= cCC //Everson - 17/06/2020. Chamado 058732.

						ZBB->(MsUnlock())
						
					Else 
						Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - registro não pode ser atualizado, pois já foi baixado do estoque " + cValToChar(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT) )
						logZBE(" ADLOG022P - impDados - registro não pode ser atualizado, pois já foi baixado do estoque " + cValToChar(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT))

					EndIf 

				Else                                           
				
					Reclock("ZBB",.T.)
					
						ZBB->ZBB_IDABAS := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT 
						ZBB->ZBB_DTINI  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_DATA_INICIO:TEXT )
						ZBB->ZBB_HRINI  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_HORA_INICIO:TEXT 
						ZBB->ZBB_DTFIM  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_DATA_FIM:TEXT) 
						ZBB->ZBB_HRFIM  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_HORA_FIM:TEXT 
						ZBB->ZBB_VOLUME := Val(StrTran(StrTran(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VOLUME:TEXT),'.',""), ',', '.'))
						ZBB->ZBB_PLACA  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VEICULO:_PLACA:TEXT 
						ZBB->ZBB_PLAORI := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_VEICULO:_PLACA:TEXT 
						nTraco          := At('-', oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_BOMBA:_NOME:TEXT)
						cBomba          := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_BOMBA:_NOME:TEXT
						ZBB->ZBB_BOMBA  := Alltrim(SUBSTR(cBomba,nTraco + 1,Len(cBomba)))
						ZBB->ZBB_ESTOQU := .F.
						ZBB->ZBB_LOGIST := .F.
						ZBB->ZBB_CTAPLU := .T.
						ZBB->ZBB_SISTEM := "A" //Chamado 053926 - Everson 26/02/202
						ZBB->ZBB_CC		:= cCC //Everson - 17/06/2020. Chamado 058732.
											
					ZBB->(MsUnlock()) 
					
				EndIf 

			End Transaction

			//
			cHtmlPage1 := Httpget('http://ctaplus.com.br:8080/SvWebInformaSincronismo?token=S2L8sh2kjQ&xml=<ABASTECIMENTOS><ABASTECIMENTO><ID>'+ oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO:_ID:TEXT +'</ID><STATUS>Sucesso</STATUS></ABASTECIMENTO></ABASTECIMENTOS>')
		    
			//
		    nCont := 1
		
		ElseIf ValType(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO) == "A" 
		
			//
			For nCont := 1 to Len(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO)

				//
				Begin Transaction

					//
					cCC := getCCCrg(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VEICULO:_PLACA:TEXT), Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_DATA_INICIO:TEXT )) //Everson - 17/06/2020. Chamado 058732. //Everson - 13/07/2020. Chamado 059245.
			
					DbSelectArea("ZBB")
					ZBB->(DbSetOrder(3)) //Chamado 053926 - Everson 26/02/2020.
					If ZBB->(DbSeek(FWxFilial("ZBB")+"A"+oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT , .T.)) //Chamado 053926 - Everson 26/02/2020.	
					
						//
						If Alltrim(cValToChar(ZBB->ZBB_ESTOQU)) == "F" //Chamado 058732 - Everson 11/06/2020.
							Reclock("ZBB",.F.)
							
								ZBB->ZBB_IDABAS := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT 
								ZBB->ZBB_DTINI  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_DATA_INICIO:TEXT )
								ZBB->ZBB_HRINI  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_HORA_INICIO:TEXT 
								ZBB->ZBB_DTFIM  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_DATA_FIM:TEXT) 
								ZBB->ZBB_HRFIM  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_HORA_FIM:TEXT 
								ZBB->ZBB_VOLUME := Val(StrTran(StrTran(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VOLUME:TEXT),'.',""), ',', '.'))
								ZBB->ZBB_PLACA  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VEICULO:_PLACA:TEXT 
								ZBB->ZBB_PLAORI := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VEICULO:_PLACA:TEXT 
								nTraco          := At('-', oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_BOMBA:_NOME:TEXT)
								cBomba          := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_BOMBA:_NOME:TEXT
								ZBB->ZBB_BOMBA  := Alltrim(SUBSTR(cBomba,nTraco + 1,Len(cBomba)))
								ZBB->ZBB_SISTEM := "A" //Chamado 053926 - Everson 26/02/202
								ZBB->ZBB_CC		:= cCC //Everson - 17/06/2020. Chamado 058732.
								
							ZBB->(MsUnlock())
						
						Else 
							Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - registro não pode ser atualizado, pois já foi baixado do estoque " + cValToChar(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT ) )
							logZBE(" ADLOG022P - impDados - registro não pode ser atualizado, pois já foi baixado do estoque " + cValToChar(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT ))

						EndIf 

					Else                                           
					
						Reclock("ZBB",.T.)
						
							ZBB->ZBB_IDABAS := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT 
							ZBB->ZBB_DTINI  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_DATA_INICIO:TEXT )
							ZBB->ZBB_HRINI  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_HORA_INICIO:TEXT 
							ZBB->ZBB_DTFIM  := CToD(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_DATA_FIM:TEXT) 
							ZBB->ZBB_HRFIM  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_HORA_FIM:TEXT 
							ZBB->ZBB_VOLUME := Val(StrTran(StrTran(Alltrim(oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VOLUME:TEXT),'.',""), ',', '.'))
							ZBB->ZBB_PLACA  := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VEICULO:_PLACA:TEXT 
							ZBB->ZBB_PLAORI := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_VEICULO:_PLACA:TEXT 
							nTraco          := At('-', oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_BOMBA:_NOME:TEXT)
							cBomba          := oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_BOMBA:_NOME:TEXT
							ZBB->ZBB_BOMBA  := Alltrim(SUBSTR(cBomba,nTraco + 1,Len(cBomba)))
							ZBB->ZBB_ESTOQU := .F.
							ZBB->ZBB_LOGIST := .F.
							ZBB->ZBB_CTAPLU := .T.
							ZBB->ZBB_SISTEM := "A" //Chamado 053926 - Everson 26/02/202
							ZBB->ZBB_CC		:= cCC //Everson - 17/06/2020. Chamado 058732.
												
						ZBB->(MsUnlock()) 

					EndIf

				End Transaction

				//
			    cHtmlPage1 := Httpget('http://ctaplus.com.br:8080/SvWebInformaSincronismo?token=S2L8sh2kjQ&xml=<ABASTECIMENTOS><ABASTECIMENTO><ID>'+ oXml:_CTAPLUS:_ABASTECIMENTOS:_ABASTECIMENTO[nCont]:_ID:TEXT +'</ID><STATUS>Sucesso</STATUS></ABASTECIMENTO></ABASTECIMENTOS>')
			
			Next nCont   
		
		EndIf

		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG022P - impDados - nCont " + cValToChar(nCont) )

		//
		FreeObj(oXml)
		oXml := Nil
		DelClassIntF()
		Aadd(aMsgs,"Importacao Realizade de Qtd: " + cValtochar(nCont) + ' - na data de: ' + Alltrim(cDataFin))
	 	
	End
 	
	//
 	If Len(aMsgs) > 0
	 	EnviaWF(aMsgs)
	 	
 	EndIf

	//
	Conout( DToC(Date()) + Time() + " ADLOG022P - impDados - Fim importação de dados.")

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} EnviaWF
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function EnviaWF(aMsgs,cSubject)

	//Variáveis.
	Local lOk           := .T.
	Local cBody         := RetHTML2(aMsgs)
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_INTSERV"))
	Local cAccount      := AllTrim(GetMv("MV_INTACNT"))
	Local cPassword     := AllTrim(GetMv("MV_INTPSW"))
	Local cFrom         := AllTrim(GetMv("MV_INTACNT"))
	Local cTo           := AllTrim(GetMv("MV_#EMACTA")) 
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""   

	//
	Default cSubject    := "Leitura Webservice CTAPLUS"  

	//
	Conout( DToC(Date()) + Time() + " ADLOG022P - EnviaWF - Envio de e-mail.")     

	//	
	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk
	
	If !lAutOk
	   If ( lSmtpAuth )
	      lAutOk := MailAuth(cAccount,cPassword)

	   Else
	      lAutOk := .T.

	   EndIf

	EndIf
	
	If lOk .And. lAutOk                
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk              
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

	EndIf
	
Return Nil
/*/{Protheus.doc} RetHTML2
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function RetHTML2(aMsgs)

	//Variáveis.
	Local cRet   := ""
	Local nCont  := 1

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>"
	
	For nCont := 1 To Len(aMsgs)
	
		cRet += aMsgs[nCont] + ;
		        "<br>"                                  
				            
	Next nCont
       		
    cRet += "<br>"
	cRet += "<br><br>É de extrema importância que seja feita a conferência."          
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> Depto de Tecnologia da Informacao <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'

Return(cRet)    
/*/{Protheus.doc} gerSolic
    Processa registros.
    @type  Static processa
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function gerSolic(cCC)

	//Variáveis.
    Local aArea     := GetArea()
    Local aAreaMS   := {}
    Local cNumReg   := ""
    Local cDS10     := GetMv("MV_#DIES10") //Chamado 058732 - Everson 17/06/2020.
	Local cDs500	:= GetMv("MV_#DIE500") //Chamado 058732 - Everson 17/06/2020.
	Local cProd 	:= ""
    Local nQtd      := 0
    Local cObs      := ""
    Local aCab      := {}
    Local aItens    := {}
    Local cNumero   := ""
    Local cQuery    := ""
    Local nRecZBB   := 0
    Local cErro     := ""
    Local aErroLog  := {}
	Local aMsgs 	:= {}
	Local cConPrj 	:= "" //Everson - 10/08/2020. Chamado 060424.
	Local cCodPrj	:= "" //Everson - 10/08/2020. Chamado 060424.

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	Default cCC 	:= ""

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic - Início geração de solicitação ao armazém." )
    logZBE("ADLOG022P - gerSolic - Início geração de solicitação ao armazém.")

    //
    cQuery := scriptSolic()

    //
    If Select("D_DADOS") > 0
        D_DADOS->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_DADOS"
    DbSelectArea("D_DADOS")
    D_DADOS->(DbGoTop())

    //
    While ! D_DADOS->(Eof())

        //
		cCC := Alltrim(cValToChar(D_DADOS->ZBB_CC))

		//
		If Empty(cCC)

			//
			If Empty(cCC)
				Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic - Placa " + Alltrim(cValToChar(D_DADOS->ZBB_PLACA)) + " não possui centro de custo vinculado. Id " + Alltrim(cValToChar(D_DADOS->ZBB_IDABAS)) )
				Aadd(aMsgs,"Não foi possível determinar o centro de custo para baixa do abastecimento com id " + Alltrim(cValToChar(D_DADOS->ZBB_IDABAS)) + ", placa " + Alltrim(cValToChar(D_DADOS->ZBB_PLACA)) + " data " + Alltrim(D_DADOS->ZBB_DTFIM) ) 
				D_DADOS->(DbSkip())
				Loop 

			EndIf

		EndIf

		//Chamado 058732 - Everson 17/06/2020.
		cProd := ""
		If Alltrim(cValToChar(D_DADOS->ZBB_BOMBA)) == "S10"
			cProd := cDS10

		ElseIf Alltrim(cValToChar(D_DADOS->ZBB_BOMBA)) == "S500"
			cProd := cDs500

		EndIf

		//
		If Empty(cProd)

			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic - Placa " + Alltrim(cValToChar(D_DADOS->ZBB_PLACA)) + " não possui tipo de combustível definido " + Alltrim(cValToChar(D_DADOS->ZBB_IDABAS)) )
			Aadd(aMsgs,"Não foi possível determinar o tipo de combustível para baixa do abastecimento com id " + Alltrim(cValToChar(D_DADOS->ZBB_IDABAS)) + ", placa " + Alltrim(cValToChar(D_DADOS->ZBB_PLACA)) + " data " + Alltrim(D_DADOS->ZBB_DTFIM) ) 
			D_DADOS->(DbSkip())
			Loop 

		EndIf

		//
        nRecZBB := Val(cValToChar(D_DADOS->REC))
        cNumReg := Alltrim(cValToChar(D_DADOS->ZBB_IDABAS))
        nQtd    := Val(cValToChar(D_DADOS->ZBB_VOLUME))
        cObs    := cNumReg + " " + Alltrim(cValToChar(D_DADOS->ZBB_PLACA)) + " " + Alltrim(D_DADOS->ZBB_DTFIM) + " " + Alltrim(cValToChar(D_DADOS->ZBB_HRFIM))
		cConPrj := Alltrim(cValToChar(D_DADOS->ZBB_CONPRJ)) //Everson - 10/08/2020. Chamado 060424.
		cCodPrj := Alltrim(cValToChar(D_DADOS->ZBB_CCCTA))  //Everson - 10/08/2020. Chamado 060424.

        //
        Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic - cCC " + cCC )
        Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic " + cObs )

        //
        DbSelectArea( "SB1" )
        SB1->( DbSetOrder( 1 ) )
        ddatabase := SToD(Alltrim(D_DADOS->ZBB_DTFIM))
		
        //
        aCab := {}
		cNumero := U_SXESXF("SCP") //GETSXENUM("SCP","CP_NUM") //Chamado 058732 - Everson 18/06/2020. //Everson - 11/08/2020. Chamado 060424.
		Aadd( aCab, { "CP_NUM" ,cNumero, Nil }) //Chamado 058732 - Everson 18/06/2020.
        Aadd( aCab, { "CP_EMISSAO" ,SToD(Alltrim(D_DADOS->ZBB_DTFIM)), Nil })

        //
        aItens := {}
        Aadd( aItens, {} )
        Aadd( aItens[ Len( aItens ) ],{"CP_ITEM"    ,"01"     , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_PRODUTO" ,cProd    , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_CC"      ,cCC      , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_QUANT"   ,nQtd     , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_OBS"     ,cObs     , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_XCOMBUS" ,cNumReg  , Nil } )
        Aadd( aItens[ Len( aItens ) ],{"CP_XSISCOM" ,"A"      , Nil } )
		Aadd( aItens[ Len( aItens ) ],{"CP_CONPRJ"  ,cConPrj  , Nil } ) //Everson - 10/08/2020. Chamado 060424. 
		Aadd( aItens[ Len( aItens ) ],{"CP_CODPROJ" ,cCodPrj  , Nil } ) //Everson - 10/08/2020. Chamado 060424. 

        //
        SB1->( DbSetOrder( 1 ) )
        SCP->( DbSetOrder( 1 ) )

        //
        //VarInfo("aCab"  ,aCab)
        //VarInfo("aItens",aItens)

        //
        lMsErroAuto := .F.
        //lMsHelpAuto	:= .T.
		//lAutoErrNoFile := .T.

		//Chamado 058732 - Everson 18/06/2020.
		aCab   := FWVetByDic(aCab,"SCP",.F.)
		aItens := FWVetByDic(aItens,"SCP",.T.)

        //
        Private n := 1
        aAreaMS := GetArea()
        MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , 3 )
        RestArea(aAreaMS)

        //
        cErro    := ""
        aErroLog := {}
        If lMsErroAuto

			//
			//RollBackSX8() //Chamado 058732 - Everson 18/06/2020.

			MOSTRAERRO()
            
            //
            aErroLog := GetAutoGrLog()

            //
            If Len(aErroLog) > 0

                //
                cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[1])),Chr(13),""),Chr(10),""))

            EndIf

            //
			Aadd(aMsgs,"gerSolic - Erro geração solicitação " + cValToChar(cNumReg) + " " + cErro)
            logZBE("gerSolic - Erro geração solicitação " + cValToChar(cNumReg) + " " + cErro)

        Else

			//
			//ConfirmSX8() //Chamado 058732 - Everson 18/06/2020.

            //
            cNumero := getNumSA(cNumReg) //Everson - 05/03/2020. Chamado 053926. //Everson 02/07/2020. Chamado T.I.

            //
            If ! Empty(cNumero) //Everson - 05/03/2020. Chamado 053926.
                DbSelectArea("ZBB")
                ZBB->(DbGoTo(nRecZBB))
                RecLock("ZBB",.F.)
                    ZBB->ZBB_ESTOQU := .T.
                    ZBB->ZBB_NUMSA  := cNumero
                ZBB->(MsUnlock())

                //
                logZBE("Incluiu SCP / ID ABAST" + cNumero + " / " + cNumReg)

            EndIf

        EndIf

        //
        D_DADOS->(DbSkip())

    End

    //
    ddatabase := Date()

	//
	If Len(aMsgs) > 0
		EnviaWF(aMsgs,"Erro Baixa de Abastecimento")

	EndIf

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - gerSolic - Fim geração de solicitação ao armazém.")
    logZBE("ADLOG022P - gerSolic - Fim geração de solicitação ao armazém.")

    //
    RestArea(aArea)

Return Nil 
/*/{Protheus.doc} scriptSolic
    (long_description)
    @type  Static Function
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function scriptSolic()

	//Variáveis.
	Local aArea	 := GetArea()
    Local cQuery := ""
	Local cData  := Alltrim(GetMv("MV_#DTBXES"))

    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " ZBB_IDABAS, " 
    cQuery += " ZBB_PLACA, " 
    cQuery += " ZBB_DTFIM, " 
    cQuery += " ZBB_HRFIM, " 
    cQuery += " ZBB_VOLUME, " 
	cQuery += " ZBB_BOMBA, "//Everson - 17/06/2020. Chamado 058732.
	cQuery += " ZBB_CC, " //Everson - 17/06/2020. Chamado 058732.
    cQuery += " ZBB.R_E_C_N_O_ AS REC, ZBB_CONPRJ, ZBB_CCCTA " //Everson - 10/08/2020. Chamado 060424.
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZBB") + " (NOLOCK) AS ZBB " 
    cQuery += " WHERE " 
    cQuery += " ZBB_FILIAL = '" + FWxFilial("ZBB") + "' " //ticket 70750 - Everson - 07/04/2022.
    cQuery += " AND ZBB_ESTOQU = 'F' " 
    cQuery += " AND ZBB_SISTEM IN ('A','M') " 
    cQuery += " AND ZBB_APRMOV  = '' " 
    cQuery += " AND LEN(ZBB_PLACA) > 6 "
	cQuery += " AND ZBB_DTFIM >= '" + cData + "' " //Everson - 17/06/2020. Chamado 058732.
    cQuery += " AND ZBB.D_E_L_E_T_ = '' "
	//cQuery += " AND ZBB.ZBB_IDABAS = '26650058' "
    cQuery += " ORDER BY  " 
    cQuery += " ZBB_IDABAS " 

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - scriptSolic - cQuery " + cQuery )

    //
    RestArea(aArea)
    
Return cQuery
/*/{Protheus.doc} getNumSA
    Obtém o número da solicitação ao armazém.
    @type  Static Function
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function getNumSA(cNumAba)

	//Variáveis.
	Local aArea	 := GetArea()
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " CP_NUM  " 
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("SCP") + " (NOLOCK) AS SCP " 
    cQuery += " WHERE " 
    cQuery += " CP_FILIAL = '" + FWxFilial("SCP") +  "' " 
    cQuery += " AND CP_XCOMBUS = '" + cNumAba + "' " 
    cQuery += " AND SCP.D_E_L_E_T_ = '' " 

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - getNumSA - cQuery " + cQuery )

    //
    If Select("D_NUMSA") > 0
        D_NUMSA->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_NUMSA"
    DbSelectArea("D_NUMSA")
    D_NUMSA->(DbGoTop())
    If ! D_NUMSA->(Eof())
        cNum := D_NUMSA->CP_NUM

    EndIf
    D_NUMSA->(DbCloseArea())

    //
    RestArea(aArea)

Return cNum
/*/{Protheus.doc} gerPreReq
    Gera pré-requisição ao armazém.
    @type  Static Function
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function gerPreReq()

	//Variáveis.
    Local aArea         := GetArea()
    Local cFiltraSCP    := " CP_XSISCOM = 'A' "

    //
    Pergunte("MTA106",.F.)

    //
    PARAMIXB1   := .F.
    PARAMIXB2   := MV_PAR01==1
    PARAMIXB3   := If(Empty(cFiltraSCP), {|| .T.}, {|| &cFiltraSCP})
    PARAMIXB4   := MV_PAR02==1
    PARAMIXB5   := MV_PAR03==1
    PARAMIXB6   := MV_PAR04==1
    PARAMIXB7   := MV_PAR05
    PARAMIXB8   := MV_PAR06
    PARAMIXB9   := MV_PAR07==1
    PARAMIXB10  := MV_PAR08==1
    PARAMIXB11  := MV_PAR09
    PARAMIXB12  := .T.
    MaSAPreReq(PARAMIXB1,PARAMIXB2,PARAMIXB3,PARAMIXB4,PARAMIXB5,PARAMIXB6,PARAMIXB7,PARAMIXB8,PARAMIXB9,PARAMIXB10,PARAMIXB11,PARAMIXB12)   

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} baxSolic
    Baixa solicitação ao armazém.
    @type  Static Function
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function baxSolic() 

	//Variáveis.
    Local aArea         := GetArea()
    Local aAreaMS       := {}
    Local cQuery        := scriptBaix()
    Local aCamposSCP    := {}
    Local aCamposSD3    := {}
    Local cTpMov        := Alltrim(cValToChar(GetMv("MV_#TPMVBX")))
    Local cErro         := ""

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - baxSolic - Início baixa geração de solicitação ao armazém." )
    logZBE("ADLOG022P - baxSolic - Início baixa de solicitação ao armazém.")

    //
    If Select("D_BAIXAS") > 0
        D_BAIXAS->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_BAIXAS"
    DbSelectArea("D_BAIXAS")
    D_BAIXAS->(DbGoTop())
    If D_BAIXAS->(Eof())
        D_BAIXAS->(DbCloseArea())
        RestArea(aArea)
        Return Nil 

    EndIf 

    //
    DbSelectArea("SCP")
    SCP->(DbSetOrder(1))

    //
    While ! D_BAIXAS->(Eof())

		//
		Conout( DToC(Date()) + " " + Time() + "ADLOG022P - baxSolic - num " + cValToChar(D_BAIXAS->CP_NUM) )

        //
        ddatabase := SToD(D_BAIXAS->CP_EMISSAO)

        //
        aCamposSCP := {{"CP_NUM"    ,D_BAIXAS->CP_NUM     ,Nil},;
                       {"CP_ITEM"   ,D_BAIXAS->CP_ITEM    ,Nil},;
                       {"CP_QUANT"  ,D_BAIXAS->CP_QUANT   ,Nil},;
					   {"CP_QUANT"  ,D_BAIXAS->CP_QUANT   ,Nil},;
					   {"CP_CODPROJ",D_BAIXAS->CP_CODPROJ ,Nil}} //Everson - 10/08/2020. Chamado 060424.

        //
        aCamposSD3 := {{"D3_TM"      ,cTpMov              ,Nil},; // Tipo do Mov.
                       {"D3_COD"     ,D_BAIXAS->CP_PRODUTO,Nil},;
                       {"D3_LOCAL"   ,D_BAIXAS->CP_LOCAL  ,Nil},;
                       {"D3_DOC"     ,D_BAIXAS->CP_NUM    ,Nil},; // No.do Docto.
                       {"D3_NUMSA"   ,D_BAIXAS->CP_NUM    ,Nil},; // No.do solicitação.
                       {"D3_EMISSAO" ,SToD(D_BAIXAS->CP_EMISSAO),Nil},;
					   {"D3_CODPROJ" ,D_BAIXAS->CP_CODPROJ,Nil},;//Everson - 10/08/2020. Chamado 060424.
					   {"D3_PROJETO" ,D_BAIXAS->CP_CONPRJ ,Nil}} //Everson - 10/08/2020. Chamado 060424.
        
        //
        lMsHelpAuto	:= .T.
        lMsErroAuto := .F.
		lAutoErrNoFile := .T.

        //
        //VarInfo("aCamposSCP",aCamposSCP)
        //VarInfo("aCamposSD3",aCamposSD3)

        //
        aAreaMS := GetArea()
        MSExecAuto({|v,x,y| MATA185(v,x,y)},aCamposSCP,aCamposSD3,1)
        RestArea(aAreaMS)

        //
        cErro    := ""
        aErroLog := {}
        If lMsErroAuto
        
            //
            aErroLog := GetAutoGrLog()

            //
            If Len(aErroLog) > 0

                //
                cErro += EncodeUtf8(StrTran(StrTran(Alltrim(cValToChar(aErroLog[1])),Chr(13),""),Chr(10),""))

            EndIf

            //
            logZBE("baxSolic - Erro baixa " + cValToChar(D_BAIXAS->CP_NUM ) + " " + cErro)

        Else

            //
            logZBE("baxSolic - baixa " + cValToChar(D_BAIXAS->CP_NUM ) )

        EndIf

        //
        D_BAIXAS->(DbSkip())

    End

    //
    D_BAIXAS->(DbCloseArea())

    //
    ddatabase := Date()

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - baxSolic - Fim baixa geração de solicitação ao armazém." )
    logZBE("ADLOG022P - gerSolic - Fim baixa de solicitação ao armazém.")

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptBaix
    Script sql com solicitações pendentes de baixa.
    @type  Static Function
    @author Everson
    @since 09/06/2020
    @version 01
    /*/
Static Function scriptBaix()

	//Variáveis.
    Local aArea := GetArea()
    Local cQuery:= ""
    
    //
    cQuery := " SELECT CP_NUM, CP_ITEM, CP_QUANT, CP_PRODUTO, CP_LOCAL, CP_EMISSAO, CP_CONPRJ, CP_CODPROJ " //Everson - 10/08/2020. Chamado 060424.
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SCP") + " "
    cQuery += " (NOLOCK) AS SCP "
    cQuery += " WHERE CP_FILIAL = '" + FWxFilial("SCP") + "' "
    cQuery += " AND CP_STATUS = '' " 
    cQuery += " AND CP_XSISCOM = 'A' "
    cQuery += " AND SCP.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY CP_NUM "

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG022P - scriptBaix - cQuery " + cQuery )

    //
    RestArea(aArea)

Return cQuery
/*/{Protheus.doc} logZBN
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function logZBN(cStatus)

	//Variáveis.
	Local aArea	       := GetArea()        
	Local nQuantAtual  := 0 
	Local cHoraIni     := '07:45:00'
	Local cHoraSegunda := '08:45:00'
	Local nTotVezes    := 2   
	Local cTempo       := '01'
	Local cHoraProx    := "" 
	Local dDtProx      := dDataBase
	                          
	If cStatus == '1' //se status igual a 1 inicio
	
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG022P')) //procura o registro
	        // se achou faz o calculo
			nQuantAtual := ZBN->ZBN_QTDVEZ + 1
			
			If nQuantAtual <> nTotVezes // verifica as quantidades de tempo
			    // se for diferente faz uma conta
				dDtProx     := dDataBase
				
				If nQuantAtual == 1
				    //se for a primeira vez ve pela hora inicial
					cHoraProx   := cHoraSegunda
				
				Else
					//se for a segunda em diante vez ve pela hora proxima
					cHoraProx   := cValToChar(SomaHoras( ZBN->ZBN_HORAPR , cTempo + ':00' ))
					cHoraProx   := IIF(Len(SUBSTR(cHoraProx, At(".", cHoraProx) + 1, Len(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
					cHoraProx   := STRTRAN(cHoraProx,'.',':') + ':00'
					
				EndIf
				If At(":", cHoraProx) == 2 //significa que a hora e menor que meio dia vamos acrescentar um zero a esquerda
				
					cHoraProx   := '0' + cHoraProx
									
				EndIf
			
			Else                               
			    // se for igual grava o proximo dia
			    nQuantAtual := 1
				dDtProx     := dDataBase + 1
				cHoraProx   := cHoraIni
			
			EndIf
			
	    Else 
	                 
	        // se nao achou e pq e a primeira vez do dia que esta rodando
	    	nQuantAtual := 1         
	    	dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
	    
	    EndIf                       
	    ZBN->(dbCloseArea())
	    
	Else // se o status for igual a 2          
	    
		DbSelectArea("ZBN") 
		ZBN->(DbSetOrder(1))
		ZBN->(DbGoTop()) 
		If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG022P'))
		    // se achou grava o que ja esta calculado
			nQuantAtual := ZBN->ZBN_QTDVEZ
			dDtProx     := ZBN->ZBN_DATAPR
			cHoraProx   := ZBN->ZBN_HORAPR
			
		Else
		    // se nao achou grava a segunda vez
			nQuantAtual := 1
			dDtProx     := dDataBase
			cHoraProx   := cHoraSegunda
			
		EndIf                       
	    ZBN->(dbCloseArea())	
	
	EndIf
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADLOG022P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG022P'
			ZBN_DESCRI  := 'Integração CTAPLUS, leitura do webservice'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1 HR - 2 VEZES'
			ZBN_PERDES  := 'HORA'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:45:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADLOG022P'
			ZBN_DESCRI  := 'Integração CTAPLUS, leitura do webservice'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1 HR - 2 VEZES'
			ZBN_PERDES  := 'HORA'
			ZBN_QTDVEZ  := nQuantAtual
			ZBN_HORAIN  := '08:45:00'
			ZBN_DATAPR  := dDtProx
			ZBN_HORAPR  := cHoraProx
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	//
	ZBN->(dbCloseArea())
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCCCrg
    Obtém o centro de custo pelo tipo de carga (estadual ou interestadual).
    @type  Static Function
    @author Everson
    @since 17/06/2020
    @version 01
    /*/
Static Function getCCCrg(cPlaca,cDtIni)

	//Variáveis.	
	Local aArea	:= GetArea()
	Local cCC   := ""
	Local cCCE  := ""
	Local cQuery:= ""

	//
	cCCE := Alltrim(Posicione("ZV4",1, FWxFilial("ZV4") + cPlaca,"ZV4_CCABAS")) //CC estadual.
	cCCI := Alltrim(Posicione("ZV4",1, FWxFilial("ZV4") + cPlaca,"ZV4_CCABAI")) //CC interestadual.

	//
	If ! Empty(cCCE) .And. Empty(cCCI) //Há apenas centro de custo para carga estadual.
		cCC := cCCE

	ElseIf Empty(cCCE) .And. ! Empty(cCCI) //Há apenas centro de custo para carga interestadual.
		cCC := cCCI

	ElseIf (! Empty(cCCE) .And. ! Empty(cCCI)) .Or. (Empty(cCCE) .And. Empty(cCCI))

		//
		cCC := getTpCrg(cPlaca,cDtIni) //Everson - 13/07/2020. Chamado 059245.

	EndIf

	//
	RestArea(aArea)

Return cCC
/*/{Protheus.doc} getTpCrg
	Retorna o centro de custo pela carga.
	@type  Static Function
	@author Everson
	@since 13/07/2020
	@version 01
	/*/
Static Function getTpCrg(cPlaca,cDtIni)

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cCC 		:= ""
	Local cQuery 	:= ""
	Local cDtFim	:= DToS(CToD(cDtIni) + 5)

	//
	cDtIni := DToS(CToD(cDtIni))

	//
	cQuery := ""
	cQuery += " SELECT TOP 1 " 
	cQuery += " ZK_DTENTR,ZK_ROTEIRO, " 
	cQuery += " ZK_PLACA, " 
	cQuery += " ZK_CCDIESE, SZK.R_E_C_N_O_ AS REC " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SZK") + " (NOLOCK) AS SZK " 
	cQuery += " WHERE " 
	cQuery += " ZK_FILIAL = '" + FWxFilial("SZK") + "' " 
	cQuery += " AND ZK_PLACA = '" + cPlaca + "' " 
	cQuery += " AND ZK_DTENTR BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' " 
	cQuery += " AND ZK_USOABAS = '' " 
	cQuery += " AND ZK_CCDIESE <> '' " 
	cQuery += " AND SZK.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY ZK_DTENTR, R_E_C_N_O_  "

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG022P - getTpCrg - cQuery " + cQuery )
	
	//
	If Select("D_CRG") > 0
		D_CRG->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CRG"
	DbSelectArea("D_CRG")
	D_CRG->(DbGoTop())
	If ! D_CRG->(Eof())

		//
		DbSelectArea("SZK")
		SZK->(DbGoTo(Val(cValToChar(D_CRG->REC))))

		//
		cCC := Alltrim(cValToChar(SZK->ZK_CCDIESE))
		RecLock("SZK",.F.)
			SZK->ZK_USOABAS := "2"
		SZK->(MsUnlock())

	EndIf
	D_CRG->(DbGoTop())

	//
	RestArea(aArea)

Return cCC
/*/{Protheus.doc} logZBE
    Gera log na tabela ZBE.
    @type  Static Function
    @author Everson
    @since 28/02/2020
    @version 01
    /*/
Static Function logZBE(cMensagem,cMemo)

	//Variáveis.	
	Local aArea	:= GetArea()

	//
	Default cMemo = ""

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate() //dDataBase // @history ticket  69813  - Fernando Macieira - 22/03/2022 - Requisições Filial 02 948478 e 948479 - Produto 581459
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG022P" 
		Replace ZBE_LOGMEM		With cMemo //Everson - 09/07/2020. Chamado 059564.
	MsUnlock()

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} u_LOG022A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG022A0( uPar1, uPar2 )
Return( impDados( uPar1, uPar2 ) )
