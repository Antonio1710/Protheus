#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"       
#Include "AP5MAIL.ch"   
#Include "Tbiconn.ch" 

/*/{Protheus.doc} User Function M460FIM
	M460FIM   ³ PE - No OK do documento de saida (MATA460) - Apos gravacao dados
	1 - Executa rotina RESPM001 para exportacao de dados mantendo atualizado 10/2013 banco de dados de Inteface Protheus X SAG
	2 - Executara transferencia de ovos para armazem conforme parametros
	@type  Function
	@author user
	@since 10/2013
	@version 01
	@history Ch:037647 - Ricardo Lima 	 - 17/10/2018 - Gera Pré-Nota de entrada de ração na empresa RNX2 
	@history Ch:037647 - Ricardo Lima 	 - 10/01/2019 - ajuste no cnpj do emitente da nota                
	@history Ch:044314 - Ricardo Lima 	 - 19/11/2018 - Controle de Frete, Gera frete na emissao da nota
	@history Ch:044314 - Everson		 - 22/02/2019 - Incluído log na chamada de geraçaõ de frete.          
	@history Ch:044314 - Everson		 - 01/03/2019 - removido StartJob, pois estava duplicando a geraçaõ de lançamento de frete.
	@history Ch:047935 - Fernando Sigoli - 21/03/2019 - removido Gera Pré-Nota de entrada de ração na empresa RNX2. devido implantação da central XML
	@history Ch:044314 - Everson		 - 09/04/2019 - Incluído log antes da chamada de geraçaõ de frete.
	@history Ch:044314 - Everson		 - 15/04/2019 - Incluído log antes da chamada de geraçaõ de frete. 
	@history Ch:044314 - Everson		 - 15/04/2019 - Alterada posição da sequência de execuação do frete.
	@history Ch:048580 - FWNM	         - 13/05/2019 - FISCAL || DEJAIME || 8921 || REL. WOKFLOW
	@history Ch:Interno- TI				 - 04/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Ch:044314 - Everson		 - 30/05/2019 - Removido o ponto de geração de frete.                   
	@history Ch:044314 - Everson		 - 03/06/2019 - Adicionada verificação se o faturamento foi iniciado pela função CCSP_002 para geração de frete.
	@history Ch:044314 - Everson		 - 11/06/2019 - Alterado log de geração de frete.                       
	@history Ch:044314 - Everson		 - 12/06/2019 - Removida validação para geração de frete.               
	@history Ch:044314 - Everson		 - 06/08/2019 - Acrescentado validação de empresa para geração de frete.
	@history Ch:053926 - Everson		 - 26/02/2020 - Tratamento para correção da gravação da nota fiscal no banco intermediário.
	@history Ch:055979 - Abel Babini	 - 28/02/2020 - COMPLEMENTO FRANGO VIVO - Retirada da TES para não gerar erro nos filtros das outras rotinas do processo (INTNFEB)
	@history Ch:056404 - William Costa	 - 15/04/2020 - Salvar campo de Co-Participação SF2->F2_XVLCOPA
	@history Ch:056247 - FWNM 			 - 22/05/2020 - Compensação automática para PV Bradesco WS
	@history Ch:059415 - FWNM 			 - 13/08/2020 - Contabilizar pela data do RA a Compensação automática para PV Bradesco WS
	@history Ch: 744   - Everson         - 03/09/2020 - Tratamento para considerar apenas os valores de produtos acabados no desconto de co-participação no seguro de carga.
	@history Tick 1208 – FWNM - 09/09/20 - Queda no sistema
	@history tick  745 - FWNM - 21/09/20 - Implementação título PR
	@history Ch: 422   - Everson         - 03/11/2020 - Tratamento para cálculo de AB-, considerando o desconto por produto.
	@history Ch: 10055 - Andre Mendes    - 24/02/2021 - Diferença entre SD2 e SD3 na data de emissao
	@history Ch: 10055 - Denis Guedes    - 24/02/2021 - Diferença entre SD2 (utiliza Date()) e SD3 (utiliza ddatabase) na data de emissao
    @history tic 15299 - Fer Macieira    - 09/06/2021 - Compensação Errada PR
	@history tic 17937 - Jonathan        - 02/09/2021 - Gravar data de emissao da nota no retorno para o SAG
	@history Ch: 13526 - Everson         - 18/10/2021 - Tratamento para apuração de descontos por NCC.
	@history ticket 69652 - Fer Macieira - 15/03/2022 - COMPENSAÇÃO DE RA - MADRUGADA
	@history ticket 69724 - Fer Macieira - 15/03/2022 - Exceção CFOP 5451 - 384743 PINTOS DE 1 DIA MATRIZ - FEMEA
	@history Everson, 22/03/2022, Chamado 18465. Envio de informações ao barramento. 
	@history ticket TI - Fernan Macieira - 22/03/2022 - Forçar publicação
	@history Everson, 24/03/2022, Chamado 18465. Envio de informações ao barramento..
	@history Everson, 24/03/2022, Chamado 18465. Envio de informações ao barramento.
	@history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	@history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF
	@history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
	@history ticket 72339 - Fernando Macieira - 04/05/2022 - workflow - ACOMPANHAMENTO DAS NOTAS FISCAIS DE FRANGO VIVO
/*/
User Function M460FIM()

	Local Area		:= GetArea()
	Local cFilGranjas    := GetMV("MV_#GRANJA",,"03|0A") // GetMV("MV_#LFVFIL",,"03") // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A // @history ticket 72339 - Fernando Macieira - 04/05/2022 - workflow - ACOMPANHAMENTO DAS NOTAS FISCAIS DE FRANGO VIVO
	Local _aCabec 	:= {}
	Local _aItens 	:= {}
	Local cCliCod 	:= GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj 	:= GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV 	:= GetMV("MV_#LFVPRD",,"300042")  	//  publicar este em producao
	Local cTESPV  	:= GetMV("MV_#LFVTES",,"701")       
	Local cFilGFrt	:= Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) // Ricardo Lima-CH:044314-19/11/18
	Local cEmpFrt	:= Alltrim(SuperGetMv( "MV_#M46F6" , .F. , '' ,  )) //Everson-CH:044314-06/08/19.
	Local nVlr 		:= 0 //Everson - 03/09/2020. Chamado 744.
	
	Private cMostraErro     

	//Everson - 15/04/19. Chamado 044314.
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With "1-Checagem da geração de frete"
		Replace ZBE_PARAME 	    With "Empresa/Filial/Parâmetro/Pedido: " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt) + "/" + cValToChar(cFilGFrt) + "/" + cValToChar(SC5->C5_NUM)
		Replace ZBE_MODULO	    With "FATURAMENTO"
		Replace ZBE_ROTINA	    With "M460FIM" 
	MsUnlock()

	//Ricardo Lima-CH:044314-19/11/18
	//Everson-CH:044314-30/05/19.
	//Everson-CH:044314-06/08/19.
	If Alltrim(cEmpAnt) $cEmpFrt .And. Alltrim(cFilAnt) $cFilGFrt //.And. ! ISINCALLSTACK("U_CCSP_002") //Everson-CH:044314-03/06/19. //Everson-CH:044314-12/06/19.
	
		//Everson-CH:044314-15/04/19.
		//Everson - 09/04/2019. Chamado 044314.
		DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	With xFilial("ZBE")
			Replace ZBE_DATA 	   	With dDataBase
			Replace ZBE_HORA 	   	With Time()
			Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
			Replace ZBE_LOG	        With "2-Checagem da geração de frete"
			Replace ZBE_PARAME      With "Empresa/Filial/Parâmetro/Pedido/U_CCSP_002: " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt) + "/" + cValToChar(cFilGFrt) + "/" + cValToChar(SC5->C5_NUM) + "/" + cValToChar(ISINCALLSTACK("U_CCSP_002")) //Everson-CH:044314-11/06/19.
			Replace ZBE_MODULO	    With "FATURAMENTO"
			Replace ZBE_ROTINA	    With "M460FIM" 
		MsUnlock()

		//Everson - 22/02/2019. Chamado 044314.
		DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	With xFilial("ZBE")
			Replace ZBE_DATA 	   	With dDataBase
			Replace ZBE_HORA 	   	With Time()
			Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
			Replace ZBE_LOG	        With "3-In´cio StartJob para geração de frete"
			Replace ZBE_PARAME      With "Empresa/Filial/Pedido: " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt) + "/" + cValToChar(SC5->C5_NUM)
			Replace ZBE_MODULO	    With "FATURAMENTO"
			Replace ZBE_ROTINA	    With "M460FIM" 
		MsUnlock()
		//

		//Everson - 01/03/2019. Chamado 044314. Removido o StartJob.
		U_ADLOG042P(cEmpAnt , cFilAnt , SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_CLIENTE , SF2->F2_LOJA , SC5->C5_NUM , '1' , SC5->C5_DTENTR )
		//StartJob( "U_ADLOG042P" , GetEnvServer() , .F. , cEmpAnt , cFilAnt , SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_CLIENTE , SF2->F2_LOJA , SC5->C5_NUM , '1' , SC5->C5_DTENTR )

	Endif
	//Fim-Everson-CH:044314-15/04/19.

	//
	If Alltrim(cEmpAnt) == "01"

		grvBarr("I", SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA, SF2->F2_DOC,SF2->F2_SERIE) //Everson, 22/03/2022, Chamado 18465. //Everson, 24/03/2022, Chamado 18465.
	
		fGrvVend2()  //19/10/16 - preenche campo vendedor 2 

		cM460F1() // user function da interface

		cM460F2() // Executara transferencia de ovos para armazem incubatorio conforme parametros

		TituloAb() //Executa verificacao no cliente para ver se ele tem desconto se sim cria um titulo de ab- no financeiro William Costa cham. 020230 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se é um pedido criado a partir da tabela SGPED010 e se for atualiza o valor do campo STATUS_PRC ³ 
		//³ como 'S' da tabela SGPED010 intermediária entre Protheus X Edata.										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ValPED010()

		//Everson - 23/10/2017. Chamado 037331.
		//Atualiza campos referente a pedidos de devolução no Edata.
		updEdata(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA) //Everson-CH:044314-26/02/2020.

		//Everson - 11/12/2017. Chamado 038133.
		//Atualiza o banco integração (DBINTERFACE) com os dados da nota fiscal de saída.
		updSAG(SF2->F2_DOC,SF2->F2_SERIE) //Everson-CH:053926-26/02/2020.

		// Chamado: 037757
		// - FWNM - 24/04/2018
		// - Gerar pre-nota de entrada automaticamente na filial 02 a partir da geracao da NF de Complemento FRANGO VIVO da filial 03
		If SC5->(FieldPos("C5_XLFVCMP")) > 0

			// If AllTrim(SC6->C6_FILIAL) == cFilGranjas .and. AllTrim(SC6->C6_CLI) == AllTrim(cCliCod) .and. AllTrim(SC6->C6_LOJA) == AllTrim(cCliLoj) .and. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProdPV) .and. AllTrim(SC6->C6_TES) == AllTrim(cTESPV) .and. AllTrim(SC5->C5_XLFVCMP) == "S" // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A // @history ticket 72339 - Fernando Macieira - 04/05/2022 - workflow - ACOMPANHAMENTO DAS NOTAS FISCAIS DE FRANGO VIVO
			If AllTrim(SC6->C6_FILIAL) $ cFilGranjas .and. AllTrim(SC6->C6_CLI) == AllTrim(cCliCod) .and. AllTrim(SC6->C6_LOJA) == AllTrim(cCliLoj) .and. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProdPV) .and. AllTrim(SC6->C6_TES) == AllTrim(cTESPV) .and. AllTrim(SC5->C5_XLFVCMP) == "S"
				msAguarde( { || GeraPreNFE() }, "Gerando Pré-Nota Entrada Complemento Frango Vivo (M460FIM)" )
			EndIf

		Else 

			//If AllTrim(SC6->C6_FILIAL) == cFilGranjas .and. AllTrim(SC6->C6_CLI) == AllTrim(cCliCod) .and. AllTrim(SC6->C6_LOJA) == AllTrim(cCliLoj) .and. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProdPV) .and. AllTrim(SC6->C6_TES) == AllTrim(cTESPV) // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A // @history ticket 72339 - Fernando Macieira - 04/05/2022 - workflow - ACOMPANHAMENTO DAS NOTAS FISCAIS DE FRANGO VIVO
			If AllTrim(SC6->C6_FILIAL) $ cFilGranjas .and. AllTrim(SC6->C6_CLI) == AllTrim(cCliCod) .and. AllTrim(SC6->C6_LOJA) == AllTrim(cCliLoj) .and. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProdPV) .and. AllTrim(SC6->C6_TES) == AllTrim(cTESPV)
				msAguarde( { || GeraPreNFE() }, "Gerando Pré-Nota Entrada Complemento Frango Vivo (M460FIM)" )
			EndIf

		EndIf
		// 

		// Chamado: 036729 - Estoque em trânsito - sempre 1 item
		// - FWNM - 21/05/2018

		cFilOrig  := GetMV("MV_#TRAFIL",,"08")

		If SC6->C6_FILIAL == cFilOrig

			// - Gerar entrada no almoxarifado 95 (Estoque em Trânsito) 
			cCliTran  := GetMV("MV_#TRACLI",,"014999")        
			cLojTran  := GetMV("MV_#TRALO1",,"00")        
			cProdTra  := GetMV("MV_#TRAPRD",,"383369")        

			If AllTrim(SC6->C6_CLI) == AllTrim(cCliTran) .and. AllTrim(SC6->C6_LOJA) == AllTrim(cLojTran) .and. AllTrim(SC6->C6_PRODUTO) == AllTrim(cProdTra)

				aAreaSF4 := SF4->( GetArea() )

				SF4->( dbSetOrder(1) ) 
				If SF4->( dbSeek(xFilial("SF4")+AllTrim(SC6->C6_TES)) )
					If AllTrim(SF4->F4_TRANSIT) == "S" //.and. AllTrim(SF4->F4_ESTOQUE) == "S" 
						msAguarde( { || GeraEstTran() }, "Gerando estoque em trânsito (M460FIM)" )
					EndIf
				EndIf

				RestArea( aAreaSF4 )

			EndIf

		EndIf

		IF ALLTRIM(SF2->F2_TPFRETE) = 'C'

			//Everson - 03/09/2020. Chamado 744.
			nVlr := coParSeg(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE)

			Reclock("SF2",.F.)

				SF2->F2_XVLCOPA := nVlr * GetMv("MV_#COPARTC",.F.,0.0004)//SF2->F2_VALBRUT * GetMv("MV_#COPARTC",.F.,0.0004) //Everson - 03/09/2020. Chamado 744.
				
			SF2->(MsUnlock())

		ENDIF
		


	Endif	

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 22/05/2020
    // Checo se o pedido de venda possui adiantamento
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
	If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
		If AllTrim(FIE->FIE_TIPO) == "RA" // Apenas quando substituído para RA // ticket 745 - FWNM - 21/09/2020 - Implementação título PR
			msAguarde( { || CompCRAuto() }, "Gerando compensação automática PV n. " + SC5->C5_NUM )
		EndIf
	EndIf
	//

	RestArea(Area)

Return Nil

/*/{Protheus.doc} cM460F1
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function cM460F1()

	Local _nOpcX    := 3   
	Local _aArea    := GetArea()                
	Local _lExporta := .F.                                              
	Local _lRet     := .T.

	If Empty(SF2->F2_MSEXP)
		Processa({|_lExporta|  U_RESPM001("SF2",_nOpcX, SF2->(Recno()), .F. ), "Aguarde, Integrando dados SAG..."})
	EndIf

	RestArea(_aArea)

Return(_lRet)

/*/{Protheus.doc} cM460F2
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
/*/
Static Function cM460F2()

	Local aArea		:= GetArea()
	Local aAreaSA2  := SA2->(GetARea())
	Local aAreaSA1  := SA1->(GetARea())
	Local cTesRem	:= SuperGetMV("FS_TESREMI" ,,"702|705|735")  // KF 30/11/15
	Local cAlDes	:= cAlOri := ""
	Local lContinua :=.F.
	Local cNumseq   := ""
	Local cDoc		:= GetSXENum("SD3","D3_DOC")
	Local aItens	:= {}

	// @history ticket 69724 - Fer Macieira - 15/03/2022 - Exceção CFOP 5451 - 384743 PINTOS DE 1 DIA MATRIZ - FEMEA
	Local cCFOP3    := GetMV("MV_#F45451",,"5451")
	Local cProd3    := GetMV("MV_#B15451",,"384743")

	Private lMsErroAuto := .F.  

	// Ch: 10055   - Denis Guedes (Obify)         - 28/04/2021 - Diferença entre SD2 e SD3 na data de emissao
	If ddatabase <> date()
		FwDateUpd(.F.,.T.) //Atualiza a database do sistema de acordo com a data do servidor
	EndIf

	If SF2->F2_TIPO == "N"
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		If SA1->(!EOF())
			If !Empty(SA1->A1_LOCAL)
				cAlDes := SA1->A1_LOCAL
				lContinua:=.T.
			EndIf
		EndIf
	ElseIf SF2->F2_TIPO == "B"
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		If SA2->(!EOF())
			If !Empty(SA2->A2_LOCAL)
				cAlDes := SA2->A2_LOCAL
				lContinua:=.T.
			EndIf
		EndIf
	EndIf

	If lContinua

		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		While SD2->(!EOF()) .and. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

			If Alltrim(SD2->D2_TES) $ cTesRem // KF 30/11/15

				//@history ticket 69724 - Fer Macieira - 15/03/2022 - Exceção CFOP 5451 - 384743 PINTOS DE 1 DIA MATRIZ - FEMEA
				If Alltrim(SD2->D2_CF) $ cCFOP3 .and. Alltrim(SD2->D2_COD) $ cProd3
					SD2->( dbSkip() )
					Loop
				EndIf
				//

				Begin Transaction

					cDoc:= GetSXENum("SD3","D3_DOC")

					cNumseq := ProxNum()
					// Ch: 10055   - Andre Mendes (Obify)         - 24/02/2021 - Diferença entre SD2 e SD3 na data de emissao
					//aadd (aItens,{cDoc	 ,ddatabase})
					aadd (aItens,{cDoc	 ,SD2->D2_EMISSAO})
					aadd (aItens,{})

					SB1->(DbSetOrder(1))
					SB1->(DbSeek( xFilial("SB1") + SD2->(D2_COD) ))

					//tratamento para criar armazem no SB2 - destino

					cAlDes:=IIF(Empty(SD2->D2_XLOCAL),cAlDes,SD2->D2_XLOCAL) // ccsKF 30/11/15

					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek( xFilial("SB2") + SD2->(D2_COD) + cAlDes ))
						CriaSB2(SD2->(D2_COD),cAlDes)
					EndIf

					aItens[2] :=  {{"D3_COD" 		, SB1->B1_COD			,NIL}}// 01.Produto Origem
					aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 02.Descricao
					aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 03.Unidade de Medida
					aAdd(aItens[2],{"D3_LOCAL"  	, SD2->D2_LOCAL			,NIL})// 04.Local Origem
					aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 05.Endereco Origem
					aAdd(aItens[2],{"D3_COD"    	, SB1->B1_COD			,NIL})// 06.Produto Destino
					aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 07.Descricao
					aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 08.Unidade de Medida
					aAdd(aItens[2],{"D3_LOCAL"  	, cAlDes				,NIL})// 09.Armazem Destino
					aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 10.Endereco Destino
					aAdd(aItens[2],{"D3_NUMSERI"	, CriaVar("D3_NUMSERI")	,NIL})// 11.Numero de Serie
					aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 12.Lote Origem
					aAdd(aItens[2],{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")	,NIL})// 13.Sub-Lote
					aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 14.Data de Validade
					aAdd(aItens[2],{"D3_POTENCI"	, CriaVar("D3_POTENCI")	,NIL})// 15.Potencia do Lote
					aAdd(aItens[2],{"D3_QUANT"  	, SD2->(D2_QUANT)		,NIL})// 16.Quantidade
					aAdd(aItens[2],{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")	,NIL})// 17.Quantidade na 2 UM
					aAdd(aItens[2],{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")	,NIL})// 18.Estorno
					aAdd(aItens[2],{"D3_NUMSEQ" 	, cNumseq				,NIL})// 19.NumSeq
					aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 20.Lote Destino
					aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 21.Data de Validade Destino

					lMsErroAuto := .F.

					MsExecAuto({|x| MATA261(x)},aItens)

					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
					EndIf

				End Transaction
			EndIf
			SD2->(DbSkip())
		EndDo
	Endif

	SA2->(RestArea(aAreaSA2))
	SA1->(RestArea(aAreaSA1))

	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} TituloAb
	Desenvolvimento dessa funcao para fazer um titulo de descon
	to tipo ab- para clientes que tem desconto na nota fiscal
	chamado numero 020230 
	@type  Static Function
	@author William Costa
	@since 20/10/2014
	@version 01
	/*/*
STATIC FUNCTION TituloAb()

	//Inicio AB- Sigoli 21/09/2016

	Local aArea    	  := GetArea()
	Local cPrefixo    := ""
	Local cDoc        := ""
	Local cCliente    := ""
	Local cLoja       := ""
	Local cQuery      := ""
	Local cCusto   	  := ''
	Local nPerc		  := 0
	Local cBanco      := ""
	Local cMostraErro := ""  

	//Everson - 03/11/2020. Chamado 422.
	Local nPercP	  := 0
	Local cComp		  := ""
	//

	//Everson - 18/10/2021. Chamado 13526.
	Local cGrNCC	  := ""
	Local nVlrNCC	  := 0
	Local aDdProd	  := {}
	//

	Private lMsErroAuto := .F.

	If AllTrim(GETMV("MV_ABMENOS")) == 'S'

		cPrefixo    := SF2->F2_PREFIXO
		cDoc        := SF2->F2_DOC
		cCliente    := SF2->F2_CLIENTE
		cLoja       := SF2->F2_LOJA
		cCusto		:= Posicione("SD2",3,xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,"D2_CCUSTO")
		cBanco      := Posicione("SA1", 1, xFilial("SA1") + cCliente+cLOja, "A1_BCO1")

		//Everson - 03/11/2020. Chamado 422.
		If getDesc(cPrefixo, cDoc, cCliente, cLoja, @nPercP, @cComp, @aDdProd) //Everson - 03/11/2020. Chamado 422.
			nPerc := nPercP

		Else 
			nPerc := POSICIONE("SA1", 1, xFilial("SA1") + cCliente+cLOja, "A1_ZZDESCB")

		EndIf
		//

		//If !Empty(cBanco) .and. SF2->F2_TIPO = "N" .and.((POSICIONE("SA1", 1, xFilial("SA1") + cCliente+cLOja, "A1_ZZDESCB")) > 0) 
		If SF2->F2_TIPO = "N" .And. nPerc > 0   // chamado 032950 - Fernando Sigoli //Everson - 03/11/2020. Chamado 422.
			
			//Everson - 18/10/2021. Chamado 13526.
			cGrNCC := Posicione("SA1", 1, FWxFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_SERIE, "A1_XTPDESC")
			nVlrNCC:= 0
			
			//
			If Select("QRY") <> 0
				QRY->(dbCloseArea())

			Endif

			cQuery := "SELECT * FROM "+RetSqlName('SE1')+" "
			cQuery += "WHERE "
			cQuery += "   E1_FILIAL = '" +xFilial('SE1')+"' AND "
			cQuery += "   E1_PREFIXO = '"+cPrefixo      +"' AND "
			cQuery += "   E1_NUM = '"    +cDoc          +"' AND "
			cQuery += "   E1_CLIENTE = '"+cCliente      +"' AND "
			cQuery += "   E1_LOJA = '"   +cLoja         +"' AND "
			cQuery += "   E1_TIPO = 'NF ' AND "
			cQuery += "   D_E_L_E_T_ = ' '"

			TcQuery cQuery NEW Alias "QRY"

			TcSetField( "QRY","E1_EMISSAO"  ,"D")
			TcSetField( "QRY","E1_VENCTO"   ,"D")
			TcSetField( "QRY","E1_VENCREA"  ,"D")

			dbSelectArea("QRY")
			QRY->(dbGotop())

			If ! QRY->(Eof())
				//nPerc   :=  (SA1->A1_ZZDESCB)
				While ! QRY->(Eof())

					//
					nValor  := Round(QRY->E1_VALOR * nPerc / 100,2)
					
					//Everson - 18/10/2021. Chamado 13526.
					If Upper(cValToChar(cGrNCC)) == "S" //NCC
						nVlrNCC += nValor //Everson - 18/10/2021. Chamado 13526.

					Else //AB-

						aSE1 := {;
						{"E1_PREFIXO" 	, QRY->E1_PREFIXO      	                             ,Nil},;
						{"E1_NUM"   	, QRY->E1_NUM         	                             ,Nil},;
						{"E1_PARCELA" 	, QRY->E1_PARCELA      	                             ,Nil},;
						{"E1_TIPO"   	, "AB-"               	                             ,Nil},;
						{"E1_NATUREZ"	, "10196"  		                                     ,Nil},;
						{"E1_CLIENTE" 	, QRY->E1_CLIENTE     	                             ,Nil},;
						{"E1_LOJA"   	, QRY->E1_LOJA        	                             ,Nil},;
						{"E1_EMISSAO" 	, QRY->E1_EMISSAO      	                             ,Nil},;
						{"E1_VENCTO"  	, QRY->E1_VENCTO     	                             ,Nil},;
						{"E1_VENCREA" 	, QRY->E1_VENCREA      	                             ,Nil},;
						{"E1_CCD" 	    , cCusto      	                                     ,Nil},;
						{"E1_HIST" 	    , "Desconto Contratual " + CVALTOCHAR(nPerc) + " %"  ,Nil},;
						{"E1_VALOR"   	, nValor		                                     ,Nil},;
						{"E1_XCPDESC"   , cComp		                                     	 ,Nil}} //Everson - 03/11/2020. Chamado 422.
						QRY->(dbSkip())

						MSExecAuto({|x,y| FINA040(x,y)},aSE1,3)
						If lMsErroAuto
							MostraErro()
							cMostraErro := MostraErro("\SYSTEM\M460FIM.log")
							EnviaWF(cMostraErro,cPrefixo,cDoc,cCliente,cLoja)
							
						Endif

					EndIf

				Enddo
				
				//Everson - 18/10/2021. Chamado 13526.
				If Upper(cValToChar(cGrNCC)) == "S"

					//
					RecLock("SF2",.F.)
						SF2->F2_XVLRNCC := nVlrNCC 
						SF2->F2_XPERNCC	:= nPerc
					SF2->(MsUnlock())

					//Salva os percentuais e valores nos itens da nota fiscal.
					// If Len(aDdProd) > 0
					// 	slvDesSD2(SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC , SF2->F2_SERIE , aDdProd) 

					// EndIf

				EndIf
				//

			Endif
			
			//
			QRY->(dbCloseArea())

		Endif

	EndIF
	//Final AB- Sigoli 21/09/2016    

	RestArea(aArea)

Return(Nil)       

/*/{Protheus.doc} EnviaWF
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function EnviaWF(cMostraErro,cPrefixo,cDoc,cCliente,cLoja)

	Local lOk           := .T.
	Local cBody         := RetHTML2(cMostraErro,cPrefixo,cDoc,cCliente,cLoja)
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := "william.costa@adoro.com.br"              
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""   
	Local cSubject      := ""          

	cSubject := "ERRO NA INCLUSAO DE TITULO AB-"

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
	Endif

Return

/*/{Protheus.doc} RetHTML2
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function RetHTML2(cMostraErro,cPrefixo,cDoc,cCliente,cLoja)

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>"

	cRet += "<b>Prefixo.: </b> " + cPrefixo    + ; 
	"<br>"                             + ;  
	"<b> Titulo.: </b> " + cDoc        + ; 
	"<br>"                             + ;  
	"<b>Cliente: </b>  " + cCliente    + ;  
	"<br>"                             + ;  
	"<b>Loja: </b>     " + cLoja       + ;  
	"<br>"                             + ;  
	"<b>Erro: </b>     " + cMostraErro + ;  
	"<br>"                         

	cRet += "<br>"
	cRet += "<br><br>ATT, <br> Depto de Tecnologia da Informacao <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'

Return(cRet)

/*/{Protheus.doc} fGrvVend2
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static function fGrvVend2()

	Local _cArea       := GetArea()
	Local _cAreaSF2 := SF2->(GetArea())
	Local _cAreaSD2 := SD2->(GetArea())
	Local _cAreaSC5 := SC5->(GetArea())
	Local _cAreaSA1 := SA1->(GetARea())	//Incluido para manter ponteiro no SA1 em 10/11/16 por Adriana - chamado 031170
	Local nRecnoSc5 := 0  //chamado : 036627 - Fernando Sigoli  10/08/2017
	Local cErro     := "" //chamado : 036627 - Fernando Sigoli  10/08/2017

	_cNOTA    	:=	SF2->F2_DOC
	_cSERIE   	:=	SF2->F2_SERIE
	_cCliente	:=	SF2->F2_CLIENTE
	_cLoja		:=	SF2->F2_LOJA
	_dDataEmiss :=  SF2->F2_EMISSAO

	DbSelectArea("SD2")
	DbSetOrder(3)
	if dbseek(xfilial("SD2")+_cNota+_cSerie+_cCliente+_cLoja)	  
		While SD2->(!Eof()) .And. _cNota+_cSerie+_cCliente+_cLoja == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			If !Empty(SD2->D2_PEDIDO)
				//Conforme informações da Adriana é sempre um pedido de venda por Nota...
				DbSelectArea("SC5")
				DbSetOrder(1)
				If dbseek(xFilial("SC5")+SD2->D2_PEDIDO)

					If !Empty(SC5->C5_X_SQED)  //chamado : 036627 - Fernando Sigoli  10/08/2017
						nRecnoSc5 := SC5->(Recno())     		
					EndIf

					If !Empty(SC5->C5_XVEND2)
						Reclock("SF2",.F.)
						SF2->F2_XVEND2 := SC5->C5_XVEND2  //atualizo campo vendedor 2 da nf gerada.                  
						SF2->(MsUnlock())
						Exit  //sai do while pois é um pedido por nota.
					Endif

				Endif            
			Endif
			SD2->(dbSkip())
		Enddo
	Endif

	//chamado : 036627 - Fernando Sigoli  10/08/2017
	If Alltrim(cEmpAnt) == "01" .And. Alltrim(cFilAnt) $ "02"

		If nRecnoSc5 > 0 

			BeginTran()

			//Executa a Stored Procedure
			TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FU_PEDIDO_FATURA] ' +Str(nRecnoSc5)+","+"'"+cEmpAnt+"'" )

			EndTran()	

		EndIf

	EndIf    

	SF2->(RestArea(_cAreaSF2))
	SD2->(RestArea(_cAreaSD2))
	SC5->(RestArea(_cAreaSC5))
	SA1->(RestArea(_cAreaSA1))	//Incluido para manter ponteiro no SA1 em 10/11/16 por Adriana - chamado 031170
	RestArea(_cArea)

Return(.T.) 

/*/{Protheus.doc} ValPED010
	Descrição ³ Regra de negócio criada para após a geração da NF de Saída de um
	pedido de venda irá atualizar o valor do campo STATUS_PRC como 'S' 
	da tabela SGPED010 intermediária entre Protheus X Edata utilizando   
	como chave o campo C5_CODIGEN do SC5(Cabeçalho do Pedido de Venda) 
	com o CODIGENE(SGPED010) 
	SIGAFAT								     				      
	MATA410 / MATA460 - Pedido de Venda	     				      
	Ponto de Entrada executado após a gravação da NF de Saída de um
	pedido de venda												
	Projeto SAG II																			
	@type  Static Function
	@author Leonardo Rios
	@since 13/042016
	@version 01
	/*/
Static Function ValPED010()

	If SC5->C5_CODIGEN > 0

		TcSqlExec("UPDATE SGPED010 SET STATUS_PRC = 'P', C5_MSEXP ='" +DTOS(DDATABASE)+ "'  WHERE CODIGENE= '" + ALLTRIM(STR(SC5->C5_CODIGEN)) + "' " )		

	EndIf

Return Nil

/*/{Protheus.doc} updEdata
	Atualiza registros no campo do Edata. Chamado  037331. 
	@type  Static Function
	@author Everson
	@since 23/10/2017
	@version 01
	/*/
Static Function updEdata(cNF,cSerie,cCliente,cLoja)

	Local aArea	    := GetArea()
	Local cQuery	:= ""

	If Alltrim(cEmpAnt) == "01" .And. Alltrim(cFilAnt) $ "02"

		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " DISTINCT SF1.R_E_C_N_O_ AS REC" 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC6") + " AS SC6 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SD1") + "  AS SD1 ON " 
		cQuery += " SD1.R_E_C_N_O_ = C6_XRECSD1 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SF1") + "  AS SF1 ON " 
		cQuery += " D1_FILIAL = F1_FILIAL " 
		cQuery += " AND D1_DOC = F1_DOC " 
		cQuery += " AND D1_SERIE = F1_SERIE " 
		cQuery += " AND D1_FORNECE = F1_FORNECE " 
		cQuery += " AND D1_LOJA = F1_LOJA " 
		cQuery += " WHERE " 
		cQuery += " SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND SD1.D_E_L_E_T_ = '' " 
		cQuery += " AND SF1.D_E_L_E_T_ = '' " 
		cQuery += " AND C6_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND C6_NOTA = '"   + cValToChar(cNF) + "' " 
		cQuery += " AND C6_SERIE = '"  + cValToChar(cSerie) + "' "
		cQuery += " AND C6_CLI = '"        + cValToChar(cCliente) + "' "
		cQuery += " AND C6_LOJA = '"       + cValToChar(cLoja) + "' " 
		cQuery += " AND C6_XRECSD1 <> '' " 

		//
		If Select("CHK_NF") > 0
			CHK_NF->(DbCloseArea())

		EndIf

		//
		TcQuery cQuery New Alias "CHK_NF"

		DbSelectArea("CHK_NF")
		CHK_NF->(DbGoTop())
		While ! CHK_NF->(Eof())

			If Val(cValToChar(CHK_NF->REC)) > 0 

				//
				TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FU_PEDIDEVOVEND_AJUSTE_TRANSPORTADOR] ' + cValToChar(CHK_NF->REC) + "," + "'" + cEmpAnt + "'" )

			EndIf

			CHK_NF->(DbSkip())

		EndDo

		CHK_NF->(DbCloseArea())

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} updSAG
	Atualiza registros no banco integração SAG. Chamado  038133.
	@type  Static Function
	@author Everson
	@since 11/12/2017
	@version 01
	/*/
Static Function updSAG(cDoc,cSerie) //Everson - 26/02/2020. Chamado 057529.

	Local aArea	    := GetArea()
	Local nTcConn2  := 0
	Local cPedido	:= Posicione("SD2",3,FWxFilial("SD2") + cDoc + cSerie,"D2_PEDIDO") //Everson - 26/02/2020. Chamado 057529.
	Local cPedSAG   := Posicione("SC5",1,FWxFilial("SC5") + cPedido,"C5_PEDSAG") //Everson - 26/02/2020. Chamado 057529.
	Local cTabegene	:= Posicione("SC5",1,FWxFilial("SC5") + cPedido,"C5_TABEGEN") //Everson - 26/02/2020. Chamado 057529.
	Local dDtEmiss  := Posicione("SF2",1,xFilial("SF2") + cDoc + cSerie, "F2_EMISSAO") // Jonathan  -  02/09/21 - Tkt 17937 
	
	cPedSAG	 := Alltrim(cValToChar(cPedSAG))
	cTabegene:= Alltrim(cValToChar(cTabegene))

	////Everson-CH:053926-26/02/2020.
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With "Update SAG Nota Fiscal"
		Replace ZBE_PARAME 	    With "Empresa/Filial/Parâmetro/Pedido: " + cValToChar(cEmpAnt) + "/" + cValToChar(cFilAnt) + "/" + cDoc + " " + cSerie + "/" + cValToChar(cPedido)
		Replace ZBE_MODULO	    With "FATURAMENTO"
		Replace ZBE_ROTINA	    With "M460FIM" 
	MsUnlock()

	//Everson - 26/02/2020. Chamado 057529.
	If Empty(cPedSAG) .Or. Empty(cTabegene)
		RestArea(aArea)
		Return Nil

	EndIf

	If 0 > TcSqlExec("UPDATE SGPED010 SET C5_NOTA='" + cDoc + "' , C5_SERIE = '" + cSerie + "', STATUS_INT = '', OPERACAO_INT = 'A', C6_EMISSAO ='"+DToS(dDtEmiss)+"'  WHERE C5_FILIAL = '" + cFilAnt + "' AND C5_NUM='" + cPedSAG + "' AND TABEGENE = '" + cTabegene + "' ") //Everson-CH:053926-26/02/2020.
		MsgInfo("Não foi possível atualizar o registro no banco interface: " + Chr(13) + Chr(10) + TCSQLError(),"updSAG (M460FIM)")

	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GeraPreNFE
	Gera Pre Nota - Complemento Frango Vivo. Chamado 037757.
	@type  Static Function
	@author Fernando Macieira
	@since 24/04/2018
	@version 01
	/*/
Static Function GeraPreNFE()

	Local cNReduz  := ""
	Local cFornCod := ""
	Local cLojaCod := ""
	Local cF1DOC   := ""

	Local aAreaAtu := GetArea()
	Local aAreaSD2 := SD2->( GetArea() )
	Local aAreaSA1 := SA1->( GetArea() )
	Local aAreaSA2 := SA2->( GetArea() )

	// Dados da Pre-Nota
	Local cFilPre   := GetMV("MV_#LFVPRE",,"02")
	Local cFornCod  := GetMV("MV_#LFVFOR",,"000217")
	Local cLojaCod  := GetMV("MV_#LFVLOJ",,"01")
	Local cCC       := GetMV("MV_#LFVCC" ,,"9999")
	Local cCtaCtb   := GetMV("MV_#LFVCTA",,"111520005")
	Local cItemCtb  := GetMV("MV_#LFVITC",,"121")
	Local cLocal    := GetMV("MV_#LFVALM",,"16")
	Local cEspLFV   := GetMV("MV_#LFVESP",,"SPED")
	Local cProduto  := GetMV("MV_#LFVPRD",,"300042")  //  publicar este em producao
	Local cTESPre   := ''//GetMV("MV_#LFVTEE",,"031") //Ch:055979 - Abel Babini			- 28/02/20 - COMPLEMENTO FRANGO VIVO - Retirada da TES para não gerar erro nos filtros das outras rotinas do processo (INTNFEB)

	Local cF1Origem := GetMV("MV_#LFVSF1",,"FRANGOVI") // Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 13/05/2019

	// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
	If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "0B"
		cItemCtb := AllTrim(GetMV("MV_#ITACTD",,"125"))
	EndIf
	//

	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

		// Posiciono CLIENTE
		SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

		SA2->( dbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
		If SA2->( dbSeek(xFilial("SA2")+cFornCod+cLojaCod) )
			//			cFornCod := SA2->A2_COD
			//			cLojaCod := SA2->A2_LOJA
			cNReduz  := SA2->A2_NREDUZ
		EndIf

		// Num DOC entrada
		cF1DOC  := StrZero(Val(SF2->F2_DOC),TamSx3("F1_DOC")[1])
		cSerAvs := SF2->F2_SERIE

		_aCabec := 	{ {'F1_FILIAL'	,cFilPre	,NIL},;
		{'F1_DOC'		,cF1DOC 	    ,NIL},;
		{'F1_SERIE' 	,cSerAvs    	,NIL},;
		{'F1_FORNECE'	,cFornCod		,NIL},;
		{'F1_LOJA'		,cLojaCod		,NIL},;
		{'F1_EMISSAO'	,dDataBase		,NIL},;
		{'F1_TIPO'		,'N'			,NIL},;
		{'F1_DTDIGIT'	,msDate()		,NIL},;
		{'F1_ESPECIE'	,cEspLFV 		,NIL},;
		{'F1_ORIGEM'	,cF1Origem      ,NIL},;  		
		{'F1_STATUS'	,"" 		    ,NIL}}

		nItem   := 0
		_aItens := {}
		Do While !EOF() .and. SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
			nItem++
			AAdd(_aItens,{{'D1_FILIAL'		,cFilPre		,NIL},;
			{'D1_COD'		,SD2->D2_COD	,NIL},;
			{'D1_UM'		,SD2->D2_UM		,NIL},;
			{'D1_LOCAL'		,cLocal     	,NIL},;
			{'D1_QUANT'	    ,SD2->D2_QUANT	,NIL},;
			{'D1_VUNIT'	    ,SD2->D2_PRCVEN	,NIL},;
			{'D1_TOTAL'	    ,SD2->D2_TOTAL 	,NIL},;
			{'D1_FORNECE'	,cFornCod		,NIL},;
			{'D1_LOJA'		,cLojaCod		,NIL},;
			{'D1_DOC'		,cF1DOC		    ,NIL},;
			{'D1_EMISSAO'	,dDataBase		,NIL},;
			{'D1_DTDIGIT'	,msDate()		,NIL},;
			{'D1_SERIE' 	,cSerAvs    	,NIL},;
			{'D1_TIPO'		,'N'			,NIL},;
			{'D1_CC' 		,cCC            ,NIL},;
			{'D1_CONTA' 	,cCtaCtb        ,NIL},;
			{'D1_ITEMCTA'	,cItemCtb       ,NIL},;
			{'D1_TES'   	,cTESPre        ,NIL},;
			{'D1_ITEM'		,AllTrim(StrZero(nItem,4)) ,Nil}})

			SD2->( dbSkip() )

		EndDo

	Endif

	// Bkp filial setada
	cFilBkp := cFilAnt

	Begin Transaction

		// Mudo filial para codigo onde NF de entrada se encontra
		cFilAnt  := cFilPre

		lMsErroAuto := .f. 

		//Ordena os campos conforme dicionário de dados.
		_aCabec := FWVetByDic(_aCabec,"SF1")
		_aItens := FWVetByDic(_aItens,"SD1",.T.)

		dbSelectArea("SF1")
		msExecAuto({|x,y,z| MATA140(x,y,z)}, _aCabec, _aItens, 3)    // Pre-Nota
		//msExecAuto({|x,y,z| MATA103(x,y,z)}, _aCabec, _aItens, 3) // Documento Entrada

		If lMsErroAuto

			Aviso("M460FIM-01", "Será necessário lançar manualmente a Pré-Nota de Complemento de Frango Vivo..." + chr(10) + chr(13) +;
			"Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
			"Abaixo, dados da Pré-Nota que NÃO foi gerada: " + chr(10) + chr(13) +;
			"Filial: " + cFilAnt + chr(10) + chr(13) +;
			"Número: " + cF1DOC  + chr(10) + chr(13) +;
			"Série: " + cSerAvs + chr(10) + chr(13) +;
			"Fornecedor: " + cFornCod + "/" + cLojaCod + chr(10) + chr(13) +;
			"Fantasia: " + cNReduz, {"&Ok"}, 3, "Pré-Nota de Entrada NÃO foi Gerada! Cadastros inconsistentes!")

			MostraErro()

		Else

			// Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 13/05/2019
			RecLock("SF1", .f.)
			SF1->F1_ORIGEM := cF1Origem 
			SF1->( msUnLock() )
			//

		EndIf

		// Restauro filial corrente
		cFilAnt := cFilBkp

	End Transaction

	RestArea(aAreaAtu)
	RestArea(aAreaSD2)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)

Return

/*/{Protheus.doc} GeraEstTran
	Gera estoque em transito na filial de origem.
	@type  Static Function
	@author Fernando Macieira
	@since 05/21/18
	@version 01
	/*/
Static Function GeraEstTran()


	Local aItens       := {}

	Local cLocTran     := GetMV("MV_LOCTRAN",,"95")
	Local cTMPadrao    := GetMV("MV_#TRATME",,"201")    

	Local cDescProd    := ""
	Local cUMProd      := ""
	Local cDescDestino := ""
	Local cUMProdDes   := ""
	Local aAreaSD2     := SD2->( GetArea() )


	// Posiciono no Produto
	SB1->( dbSetOrder(1) ) 
	If SB1->( dbSeek(xFilial("SB1")+SD2->D2_COD) )
		cDescProd       := SB1->B1_DESC
		cUMProd         := SB1->B1_UM
		cDescDestino    := SB1->B1_DESC
		cUMProdDes      := SB1->B1_UM
	EndIf

	// Itens 
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

	Do While SD2->( !EOF() ) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)


		//tratamento para criar armazem 
		SB2->( dbSetOrder(1) )
		If SB2->( !dbSeek(xFilial("SB2")+SD2->D2_COD+cLocTran) )
			CriaSB2( SD2->D2_COD, cLocTran )
		EndIf		

		NNR->( dbSetOrder(1) ) // NNR_FILIAL+NNR_CODIGO                                                                                                                                           
		If NNR->( !dbSeek(xFilial("NNR")+cLocTran ) )
			RecLock("NNR", .t.)
			NNR->NNR_CODIGO := cLocTran
			NNR->NNR_DESCRI := "ESTOQUE EM TRANSITO"
			NNR->( msUnLock() )
		EndIf

		/*
		// Transferência
		aAdd (aItens,{SD2->D2_DOC	 ,dDataBase})
		aAdd (aItens,{})

		aItens[2] :=  {{"D3_COD" 	, SD2->D2_COD	       ,NIL}} // 01.Produto Origem
		aAdd(aItens[2],{"D3_DESCRI" , cDescProd	 		   ,NIL}) // 02.Descricao
		aAdd(aItens[2],{"D3_UM"     , cUMProd   		   ,NIL}) // 03.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  , cAlmOri       	   ,NIL}) // 04.Local Origem
		aAdd(aItens[2],{"D3_LOCALIZ", CriaVar("D3_LOCALIZ"),NIL}) // 05.Endereco Origem
		aAdd(aItens[2],{"D3_COD"    , SD2->D2_COD          ,NIL}) // 06.Produto Destino
		aAdd(aItens[2],{"D3_DESCRI" , cDescDestino	       ,NIL}) // 07.Descricao
		aAdd(aItens[2],{"D3_UM"     , cUMProdDes	       ,NIL}) // 08.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  , cAlmDes	           ,NIL}) // 09.Armazem Destino
		aAdd(aItens[2],{"D3_LOCALIZ", CriaVar("D3_LOCALIZ"),NIL}) // 10.Endereco Destino
		aAdd(aItens[2],{"D3_NUMSERI", CriaVar("D3_NUMSERI"),NIL}) // 11.Numero de Serie
		aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 12.Lote Origem
		aAdd(aItens[2],{"D3_NUMLOTE", CriaVar("D3_NUMLOTE"),NIL}) // 13.Sub-Lote
		aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 14.Data de Validade
		aAdd(aItens[2],{"D3_POTENCI", CriaVar("D3_POTENCI"),NIL}) // 15.Potencia do Lote
		aAdd(aItens[2],{"D3_QUANT"  , SD2->D2_QUANT		   ,NIL}) // 16.Quantidade
		aAdd(aItens[2],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM"),NIL}) // 17.Quantidade na 2 UM
		aAdd(aItens[2],{"D3_ESTORNO", CriaVar("D3_ESTORNO"),NIL}) // 18.Estorno
		aAdd(aItens[2],{"D3_NUMSEQ" , CriaVar("D3_NUMSEQ") ,NIL}) // 19.NumSeq
		aAdd(aItens[2],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL}) // 20.Lote Destino
		aAdd(aItens[2],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL}) // 21.Data de Validade Destino			
		*/

		// Movimento Interno - Entrada Almoxarifado em Transito
		AADD(aItens, {"D3_FILIAL"	,SD2->D2_FILIAL  , Nil})
		AADD(aItens, {"D3_DOC"		,SD2->D2_DOC     , Nil})
		AADD(aItens, {"D3_TM"		,cTMPadrao   	 , Nil})
		AADD(aItens, {"D3_COD"		,SD2->D2_COD     , Nil})
		AADD(aItens, {"D3_UM"       ,SD2->D2_UM      , Nil})
		AADD(aItens, {"D3_QUANT"	,SD2->D2_QUANT   , Nil}) 
		AADD(aItens, {"D3_CUSTO1"	,SD2->D2_CUSTO1  , Nil})
		AADD(aItens, {"D3_LOCAL"	,cLocTran        , Nil})
		AADD(aItens, {"D3_EMISSAO"	,dDatabase	     , Nil})
		aAdd(aItens, {"D3_NUMSEQ"   ,SD2->D2_NUMSEQ  , Nil})

		Begin Transaction

			lMsErroAuto := .F.

			//msExecAuto({|x| MATA261(x)},aItens,3) // Transferência
			msExecAuto({|x,y| MATA240(x,y)}, aItens, 3) // Movimento Interno

			If lMsErroAuto

				DisarmTransaction()

				Aviso("M460FIM-03", "Será necessário lançar manualmente o estoque em trânsito..." + chr(10) + chr(13) +;
				"Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
				"Abaixo, dados da Nota que NÃO gerou estoque em trânsito: " + chr(10) + chr(13) +;
				"Filial: " + SD2->D2_FILIAL + chr(10) + chr(13) +;
				"Documento: " + SD2->D2_DOC  + chr(10) + chr(13) +;
				"Produto: " + SD2->D2_COD + chr(10) + chr(13) +;
				"Almoxarifado Saída: " + SD2->D2_LOCAL + chr(10) + chr(13) +;
				"Almoxarifado Trânsito: " + cLocTran + chr(10) + chr(13) +;
				"", {"&Ok"}, 3, "Estoque em Trânsito NÃO foi Gerada! Cadastros inconsistentes!")

				MostraErro()

			EndIf

		End Transaction		

		aItens    := {}

		SD2->( dbSkip() )

	EndDo

	RestArea( aAreaSD2 )

Return

/*/{Protheus.doc} INTNFENT
	Gera Pré-Nota de entrada de ração na empresa RNX2.
	@type  Static Function
	@author Ricardo Lima
	@since 17/10/18
	@version 01
	/*/
Static Function INTNFENT(F2DOC,F2SERIE,F2CLIENTE,F2LOJA)

	Private lExec  := .F.
	Private cQuery := ""
	Private aAreaSM0 := {}
	Private cEmpBkp := ""
	Private cFilBkp := ""

	Private aCabec := {}
	Private aItens := {}
	Private cCnpj := ""
	Private EmpEntNF := SuperGetMv( "MV_#M46F3" , .F. , '' ,  )
	Private FilEntNF := SuperGetMv( "MV_#M46F4" , .F. , '' ,  )
	Private cCodFor  := ""
	Private cLojFor  := ""
	Private cNewEmp  := EmpEntNF
	Private cOldEmp  := cEmpAnt

	dbSelectArea("SF2")
	dbSetOrder(1)
	if dbseek( FWxFilial("SF2") + F2DOC + F2SERIE + F2CLIENTE + F2LOJA )

		cCnpj := SM0->M0_CGC // Ricardo Lima-CH:037647-10/01/2019|ajuste no cnpj do emitente da nota

		If EmpChangeTable("SA2",cNewEmp,cOldEmp,3) 
			dbSelectArea("SA2")
			dbSetOrder(3)
			If DbSeek( xFilial( "SA2" ) + cCnpj )
				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA
			EndIf
			EmpChangeTable("SA2",cOldEmp,cNewEmp,1 )
		EndIF

		aadd(aCabec,{"F1_FORNECE" , cCodFor         , Nil})
		aadd(aCabec,{"F1_LOJA"    , cLojFor         , Nil})
		aadd(aCabec,{"F1_EST"     , SF2->F2_EST     , Nil})
		aadd(aCabec,{"F1_FILIAL"  , FilEntNF        , Nil})
		aadd(aCabec,{"F1_TIPO"    , SF2->F2_TIPO    , Nil})
		aadd(aCabec,{"F1_FORMUL"  , "N"             , Nil})
		aadd(aCabec,{"F1_DOC"     , SF2->F2_DOC     , Nil})
		aadd(aCabec,{"F1_SERIE"   , SF2->F2_SERIE   , Nil})
		aadd(aCabec,{"F1_EMISSAO" , SF2->F2_EMISSAO , Nil})
		aadd(aCabec,{"F1_ESPECIE" , SF2->F2_ESPECIE , Nil})

		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 "
		cQuery += " WHERE D2_FILIAL = '"+SF2->F2_FILIAL+"' "
		cQuery += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND D2_LOJA = '"+SF2->F2_LOJA+"' "
		cQuery += " AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' "
		cQuery += " AND D2.D_E_L_E_T_ = ' ' "

		If Select("INTNFENT") > 0
			INTNFENT->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "INTNFENT"

		While INTNFENT->(!Eof())

			aadd(aItens,{"D1_ITEM"   , INTNFENT->D2_ITEM   , Nil})
			aadd(aItens,{"D1_COD"    , INTNFENT->D2_COD    , Nil})
			aadd(aItens,{"D1_UM"     , INTNFENT->D2_UM     , Nil})
			aadd(aItens,{"D1_QUANT"  , INTNFENT->D2_QUANT  , Nil})
			aadd(aItens,{"D1_VUNIT"  , INTNFENT->D2_PRCVEN , Nil})
			aadd(aItens,{"D1_TOTAL"  , INTNFENT->D2_TOTAL  , Nil})

			lExec  := .T.
			INTNFENT->(dbSkip())
		End

		If lExec
			StartJob("U_INTNFEN1",GetEnvServer(), .F. ,EmpEntNF, FilEntNF,aCabec,aItens)
		Endif
	EndIf
Return

/*/{Protheus.doc} INTNFEN1
	Gera Pré-Nota de entrada de ração na empresa RNX2.
	@type  Static Function
	@author Ricardo Lima
	@since 17/10/18
	@version 01
	/*/
User Function INTNFEN1(EmpEntNF,FilEntNF,aCabec,aItens)

	Local nOpc := 3 
	Private aLinha      := {}
	Private lMsErroAuto := .F.

	RpcSetType( 3 )
	RpcSetEnv( EmpEntNF, FilEntNF,,,"COM")

	aAdd(aLinha,aItens)

	MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)

	If lMsErroAuto   
		MostraErro()
		ConOut(MostraErro())
	Endif
	RpcClearEnv()

Return(.T.)

/*/{Protheus.doc} Static Function CompCRAuto
    Compensação automática RA e NF dos pedidos de adiantamento do Bradesco WS
    @type  Function
    @author FWNM
    @since 21/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
Static Function COMPCRAUTO()

    Local lRetOK     := .T.
    Local nTaxaCM    := 0
    Local aTxMoeda   := {}
    Local nSaldoComp := 0
	Local aAreaSE1   := SE1->( GetArea() )
	Local dBkpDtBs   := dDataBase // @history Ch:059415 - FWNM 			 - 13/08/2020 - Contabilizar pela data do RA a Compensação automática para PV Bradesco WS
	Local dDtNF      := CtoD("//") // @history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF
	Local dDtRA      := CtoD("//") // @history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF

    // @history Ticket 1208 – FWNM - 09/09/2020 - Queda no sistema
    Private nRecnoE1  := 0
    Private nRecnoRA  := 0
	//

    // Checo se o pedido de venda possui adiantamento
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
	If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )

    	If FIE->FIE_SALDO > 0 // ticket 745 - FWNM - 21/09/2020 - Implementação título PR

			logZBE(SC5->C5_NUM + " INICIOU COMPENSACAO AUTOMATICA FUNCAO COMPCRAUTO CONTIDA NO PE M460FIM")
			
			dbSelectArea("SE1")
			SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

			// Busco recno do título da NF
			If SE1->( dbSeek(FWxFilial("SE1")+SF2->(F2_SERIE+F2_DOC)+PadR("",Len(SE1->E1_PARCELA))+PadR("NF",Len(SE1->E1_TIPO))) )
				nRecnoE1 := SE1->( RECNO() )
				dDtNF := SE1->E1_EMISSAO // @history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF
			EndIf

			// Busco recno e valor a compensar do adiantamento do PV
			If SE1->( dbSeek(FWxFilial("SE1")+FIE->(FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )
		
				nRecnoRA   := SE1->( RECNO() )
				nSaldoComp := SE1->E1_SALDO
				dDtRA      := SE1->E1_EMISSAO // @history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF

				PERGUNTE(PadR("AFI340",Len(SX1->X1_GRUPO)),.F.) // Commpensação Contas Pagar
				MV_PAR11 := 2 // Contabiliza On Line ? = NÃO

				// @history ticket 69652 - Fer Macieira - 15/03/2022 - COMPENSAÇÃO DE RA - MADRUGADA
				PERGUNTE(PadR("FIN330",Len(SX1->X1_GRUPO)),.F.) // Commpensação Contas Receber
				MV_PAR09 := 2 // Contabiliza On Line ? = NÃO

				lContabiliza := .F.
				lAglutina    := .F.
				lDigita      := .F.
				//

				nTaxaCM := RecMoeda(dDataBase,SE1->E1_MOEDA)

				aAdd(aTxMoeda, {1, 1} )
				aAdd(aTxMoeda, {2, nTaxaCM} )

				aRecRA  := { nRecnoRA }
				aRecSE1 := { nRecnoE1 }
		
				// Efetuo compensação automática (POSICIONADO NO ADIANTAMENTO)
				
				// @history ticket 71738 - Fernando Macieira - 25/04/2022 - As compensações automáticas deverão ser realizadas na data da emissão da NF
				dDataBase := SE1->E1_EMISSAO // @history Ch:059415 - FWNM 			 - 13/08/2020 - Contabilizar pela data do RA a Compensação automática para PV Bradesco WS
				If !Empty(dDtNF) .and. !Empty(dDtRA)
					If dDtNF >= dDtRA
						dDataBase := dDtNF
					Else
						dDataBase := dDtRA
					EndIf
				EndIf
				//
				
				If !(SE1->E1_TIPO $ MVPROVIS) // @history tic 15299 - Fer Macieira    - 09/06/2021 - Compensação Errada PR

                    If !MaIntBxCR(3,aRecSE1,,aRecRA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}, , , , , nSaldoComp)
                        lRetOk := .F.
                        logZBE(SC5->C5_NUM + " NÃO EFETUOU COMPENSACAO AUTOMATICA, TITULO NF " + SF2->F2_DOC + ", RA DO PV " + SC5->C5_NUM)
                    Else
                        logZBE(SC5->C5_NUM + " EFETUOU COMPENSACAO AUTOMATICA COM SUCESSO, TITULO NF " + SF2->F2_DOC + ", RA DO PV " + SC5->C5_NUM)	
                    EndIf

                EndIf

				dDataBase := dBkpDtBs // @history Ch:059415 - FWNM 			 - 13/08/2020 - Contabilizar pela data do RA a Compensação automática para PV Bradesco WS
				//
		
			EndIf
		
		EndIf

	EndIf

	RestArea( aAreaSE1 )

Return lRetOK

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "ADFIN087P" 
	ZBE->( msUnlock() )

Return
/*/{Protheus.doc} coParSeg
	Obtém os valores brutos do produto acaba da nota fiscal.
	Chamado 744.
	@type  Static Function
	@author Everson
	@since 03/09/2020
	@version 01
	/*/
Static Function coParSeg(cFilN,cDoc,cSer)

	//Variáveis.
	Local aArea  := GetArea()
	Local nVlr   := 0
	Local cQuery := ""

	//
	cQuery += " SELECT  " 
	cQuery += " ISNULL(SUM(D2_VALBRUT),0) AS D2_VALBRUT " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SB1") + " (NOLOCK) AS SB1 ON " 
	cQuery += " D2_COD = B1_COD " 
	cQuery += " WHERE " 
	cQuery += " D2_FILIAL = '" + cFilN + "' " 
	cQuery += " AND D2_DOC = '" + cDoc + "' " 
	cQuery += " AND D2_SERIE = '" + cSer + "' " 
	cQuery += " AND B1_TIPO = 'PA' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' " 
	cQuery += " AND SB1.D_E_L_E_T_ = '' " 

	//
	If Select("D_DADOS") > 0
		D_DADOS->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_DADOS"
	DbSelectArea("D_DADOS")
	D_DADOS->(DbGoTop())

	nVlr := Val(cValToChar(D_DADOS->D2_VALBRUT))

	D_DADOS->(DbCloseArea())

	//
	RestArea(aArea)

Return nVlr
/*/{Protheus.doc} getDesc
	Função retorna valor para geração do AB-.
	@type  Static Function
	@author Everson
	@since 03/11/2020
	@version 01
	/*/
Static Function getDesc(cPrefixo, cDoc, cCliente, cLoja, nPercP, cComp, aDdProd)

	//Variáveis.
	Local aArea := GetArea()
	Local lRet  := .F.
	Local cQuery:= ""
	Local nTotF := 0
	Local nTotD := 0

	//
	cQuery := ""
	cQuery += " SELECT "

		cQuery += " ZC5_PRODUT, "
		cQuery += " D2_TOTAL, "
		cQuery += " D2_ITEM, " //Everson - 18/10/2021. Chamado 13526.
		cQuery += " CASE WHEN FONTE.ZC5_PRODUT IS NULL OR FONTE.ZC5_PRODUT = '' THEN ISNULL(FONTE.A1_ZZDESCB,0) ELSE FONTE.TOT_DESC/100 END PER_DESC, "
		cQuery += " D2_TOTAL * CASE WHEN FONTE.ZC5_PRODUT IS NULL OR FONTE.ZC5_PRODUT = '' THEN ISNULL(FONTE.A1_ZZDESCB,0)/100 ELSE FONTE.TOT_DESC/100/100 END AS VLR_DESC "

	cQuery += " FROM  "
	cQuery += " ( " 

		cQuery += " SELECT  " 
		cQuery += " D2_CLIENTE,D2_LOJA, " 
		cQuery += " D2_TOTAL, " 
		cQuery += " D2_ITEM, " //Everson - 18/10/2021. Chamado 13526.
		cQuery += " ZC5_PRODUT, " 
		cQuery += " SA1.A1_ZZDESCB, " 
		cQuery += " ZC5_ANIVER + ZC5_INAUGU + ZC5_FORNEC + ZC5_LOGIST + ZC5_REINAU + ZC5_QBRTRC + ZC5_ASSOCI + ZC5_CRESCI + ZC5_INVCOO + ZC5_WEB TOT_DESC " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
		cQuery += " INNER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " A1_COD, A1_LOJA, A1_ZZDESCB  " 
		cQuery += " FROM   " 
		cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1  " 
		cQuery += " WHERE  " 
		cQuery += " A1_COD = '" + cCliente + "' " 
		cQuery += " AND A1_LOJA = '" + cLoja + "' " 
		cQuery += " AND SA1.D_E_L_E_T_ = '' " 
		cQuery += " ) AS SA1 ON " 
		cQuery += " D2_CLIENTE = A1_COD " 
		cQuery += " AND D2_LOJA = A1_LOJA " 
		cQuery += " LEFT OUTER JOIN " 
		cQuery += " " + RetSqlName("ZC5") + " (NOLOCK) AS ZC5 ON " 
		cQuery += " D2_FILIAL = ZC5_FILIAL " 
		cQuery += " AND D2_CLIENTE = ZC5_CODCLI " 
		cQuery += " AND D2_LOJA = ZC5_LOJA " 
		cQuery += " AND D2_COD = ZC5_PRODUT " 
		cQuery += " WHERE " 
		cQuery += " D2_FILIAL = '" + FWxFilial("SD2") + "' " 
		cQuery += " AND D2_DOC = '" + cDoc + "' " 
		cQuery += " AND D2_SERIE = '" + cPrefixo + "' " 
		cQuery += " AND D2_CLIENTE = '" + cCliente + "' " 
		cQuery += " AND D2_LOJA = '" + cLoja + "' " 
		cQuery += " AND SD2.D_E_L_E_T_ = '' " 
		cQuery += " AND ZC5.D_E_L_E_T_ = '' "
	
	cQuery += " ) AS FONTE " 

	//
	If Select("D_PORC") > 0
		D_PORC->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_PORC"
	DbSelectArea("D_PORC")
	If !D_PORC->(Eof())

		//
		While ! D_PORC->(Eof())

			//
			cComp+= "Prod.: "  + Alltrim(D_PORC->ZC5_PRODUT) + Chr(13) + Chr(10) 
			cComp+= "%Desc.: " + Alltrim(cValToChar(D_PORC->PER_DESC)) + "%" + Chr(13) + Chr(10) 
			cComp+= "--------------------------" + Chr(13) + Chr(10)

			Aadd(aDdProd,{D_PORC->ZC5_PRODUT, D_PORC->D2_ITEM, D_PORC->PER_DESC, D_PORC->VLR_DESC}) //Everson - 18/10/2021. Chamado 13526.

			//
			nTotF+= Val(cValToChar(D_PORC->D2_TOTAL))
			nTotD+= Val(cValToChar(D_PORC->VLR_DESC))

			//
			D_PORC->(DbSkip())

		End

		//
		lRet   := .T.
		nPercP := (nTotD/nTotF)*100

	End

	//
	D_PORC->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} slvDesSD2
	Função grava percetual e valor do desconto financeiro no item da
	nota fiscal.
	Chamado 13526.
	@type  Static Function
	@author Everson
	@since 18/10/2021
	@version 01
/*/
Static Function slvDesSD2(cCliente, cLoja, cDoc, cSerie, aDdProd)

	//Variáveis.
	Local aArea := GetArea()
	Local nAux  := 1

	//
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3))

	//
	For nAux := 1 To Len(aDdProd)

		If SD2->(DbSeek( FWxFilial("SD2") + cCliente + cLoja + cDoc + cSerie + aDdProd[nAux][1] + aDdProd[nAux][2] ))

			RecLock("SD2", .F.)
				SD2->D2_XPERNCC := aDdProd[nAux][3]
				SD2->D2_XVLRNCC := aDdProd[nAux][4]
			SD2->(MsUnlock())

		EndIf

	Next nAux

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
	Chamado 18465.
    @type  User Function
    @author Everson
    @since 22/03/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero, cNF, cSerie)

    //Variáveis.
    Local aArea     := GetArea()
	Local cFilter	:= ""

	If ! chkOrd(cNF, cSerie)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	cFilter := " D2_FILIAL ='" + FWxFilial("SD2") + "' .And. D2_DOC = '" + SF2->F2_DOC + "' .And. D2_SERIE = '" + SF2->F2_SERIE + "' .And. D2_CLIENTE = '" + SF2->F2_CLIENTE + "' .And. D2_LOJA = '" + SF2->F2_LOJA  + "' "
	
	U_ADFAT27D(;
			   "SF2", 1, FWxFilial("SF2") + cNumero,;
			   "SD2", 3, FWxFilial("SD2") + cNumero, "D2_COD+D2_ITEM",cFilter,;
			   "documentos_de_saida_protheus", cOperacao,;
			   .T., .T.,.T., Nil)

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} chkOrd
    Valida se há ordem de pesagem vinculada.
	Chamado 18465.
    @type  User Function
    @author Everson
    @since 24/03/2022
    @version 01
/*/
Static Function chkOrd(cNF, cSerie)

	//Variáveis
	Local aArea 	:= GetArea()
	Local lRet  	:= .F.
	Local cQuery    := ""

	cQuery += " SELECT " 
	cQuery += " C5_XORDPES " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 ON " 
	cQuery += " F2_FILIAL = D2_FILIAL " 
	cQuery += " AND F2_DOC = D2_DOC " 
	cQuery += " AND F2_SERIE = D2_SERIE " 
	cQuery += " INNER JOIN  " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
	cQuery += " D2_FILIAL = C5_FILIAL " 
	cQuery += " AND D2_PEDIDO = C5_NUM " 
	cQuery += " WHERE " 
	cQuery += " F2_FILIAL = '" + FWxFilial("SF2") + "' " 
	cQuery += " AND F2_DOC = '" + cNF + "' " 
	cQuery += " AND F2_SERIE = '" + cSerie + "' " 
	cQuery += " AND C5_XORDPES <> '' " 
	cQuery += " AND SF2.D_E_L_E_T_ = '' " 
	cQuery += " AND SD2.D_E_L_E_T_ = '' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 

	If Select("D_VLDORD") > 0
		D_VLDORD->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_VLDORD"
	DbSelectArea("D_VLDORD")
	
	lRet := ! D_VLDORD->(Eof())
	
	D_VLDORD->(DbCloseArea())

	RestArea(aArea)

Return lRet
