#Include "Protheus.CH"
#Include "TbiConn.ch"
#Include "TOPCONN.CH"
#Include "AP5MAIL.CH"      
#Include "Rwmake.ch" 

// BIBLIOTECAS NECESS�RIAS
#Include "TOTVS.ch"
#INCLUDE "XMLXFUN.CH"

// BARRA DE SEPARA��O DE DIRET�RIOS
//#Define BAR IIf(IsSrvUnix(), "/", "\")

/*/{Protheus.doc} User Function M410STTS
	Ponto de Entrada para gravar campos C5_PBRUTO,C5_PLIQUI
	Campos que sao calculado no adoro
	@type  Function
	@author Heraldo C Hebling
	@since 08/10/2003
	@version 01
	@history 08/10/2003, Heraldo C Hebling, Ponto de entrada que acontece apos a confirmacao do pedido
	de vendas e faz-se necessario para calculo do peso bruto e
	peso liquido do pedido. Principalmente que ha um filtro no
	pedidos de vendas (set filter) que inibe  o indice.
	@history                - Ricardo L- 12/05/2011 - Recria��o dos calculos para desconto, pois, o desconto � em PERCENTUAL. 
	@history chamdo 047506  - Ricardo L- 28/02/2019 - Informa novo Roteiro.
	@history Chamado TI     - Adriana  - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM  
	@history Chamado 051044 - Adriana  - 27/08/2019 - SAFEGG.                       
	@history Chamado 052170 - Adriana  - 04/10/2019 - NF EXPORTACAO SAFEGG.
	@history Chamado 052898 - Everson  - 29/10/2019 - Adicionado log.
	@history                - Everson  - 11/11/2019 - Adicionado c�lculo de valor de frete para toda inclus�o e altera��o de pedido de venda.
	@history                - Everson  - 10/02/2020 - Adicionado tratamento para obter o peso liquido e bruto do cadastro de produto, quando preenchido.
	@history Chamado 057312 - Abel     - 13/04/2020 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
	@history chamado 056247 - FWNM     - 04/03/2020 - OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Chamado 059127 - Everson  - 26/06/2020 - Tratamento para defini��o do n�mero do roteiro por faixa.
	@history chamado 059655 - FWNM     - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	@history chamado 059655 - FWNM     - 23/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	@history chamado 059415 - FWNM     - 29/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	@history chamado 059415 - FWNM     - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Garantir a gera��o de tabela SC9 com bloqueio de cr�dito
	@history chamado TI     - FWNM     - 14/08/2020 - Desativa��o devido impactos de block no SF
	@history ticket 102     - FWNM     - 26/08/2020 - WS BRADESCO 
	@history ticket 102     - FWNM     - 27/08/2020 - WS BRADESCO 
	@history ticket 102     - FWNM     - 31/08/2020 - WS BRADESCO - contemplar altera��es de pedidos de vendas com emiss�es anteriores ao do dia atual e de condi��es de pagamento normais para antecipado, cen�rio este n�o contemplado pelo job
	@history ticket 745     - FWNM     - 18/09/2020 - Implementa��o t�tulo PR
	@history Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.
	@history Ticket  8      - Abel B.  - 15/02/2021 - Altera��o na regra de pr� libera��o de cr�dito para considerar pedidos com data de entrega futura
	@history Ticket  8      - Abel B.  - 01/03/2021 - Altera��o na regra de pr� libera��o de cr�dito para desconsiderar o pedido que ser� exclu�do durante a avalia��o na exclus�o do mesmo
	@history Ticket  8      - Abel B.  - 02/03/2021 - Limpar bloqueios anteriores do Pedido.
	@history Ticket  8      - Abel B.  - 03/03/2021 - Ajustes na rotina de libera��o de cr�dito.
	@history Ticket  10915  - Abel B.  - 12/03/2021 - Ajustes na rotina de libera��o de cr�dito.
	@history Ticket  10775  - LPM  	   - 15/03/2021 - Corre��o no ponto de entrada para refazer a al�ada dos processos de exporta��o quando os itens foram alterados ap�s todo o processo ter sido aprovado.
	@history Ticket   8465  - LPM  	   - 23/03/2021 - Corre��o na al�ada de aprova��o dos pedidos de venda de exporta��o na condi��o espec�fica em que ele � aprovado, alterado e ajustado os valores ficando abaixo do IPTAB. Quando ocorre isso, os registros SC9 n�o s�o recriados.
	@history Ticket   11277 - F.Maciei - 13/04/2021 - DEMORA AO IMPORTAR PEDIDO DE RA��O
	@history Ticket  13155  - Everson  - 04/05/2021 - Tratamento para libera��o de pedido de venda por integra��o SAG (movimento de sa�da).
	@history Ticket  8      - Abel B.  - 15/06/2021 - Considerar hist�rico de libera��o
	@history Ticket  TI     - F.Maciei - 02/09/2021 - Par�metro liga/desliga nova fun��o an�lise cr�dito
	@history Ticket  62453  - Everson  - 14/10/2021 - Tratamento errorlog : Error : 102 (37000) (RC=-1) - [Microsoft][ODBC Driver 13 for SQL Server][SQL Server]Incorrect syntax near '%
	@history Ticket  63537  - Leonardo P. Monteiro  - 10/11/2021 - Corre��o na grava��o dos roteiros na SC5, SC6 e SC9.
	@history Ticket  65403  - Leonardo P. Monteiro  - 16/11/2021 - Corre��o de error.log na grava��o de PVs na filial 07.
	@history Ticket  TI  	- Leonardo P. Monteiro  - 02/02/2022 - Inclus�o de Conouts.
	@history Ticket  TI  	- Leonardo P. Monteiro  - 02/02/2022 - Transfer�ncia do P.E. MTA410I para o fonte atual M410STTS. Transferimos a grava��o da data de entrega nos itens do PV.
	@history Ticket  69520  - Leonardo P. Monteiro - 26/02/2022 - Inclus�o de conouts no fonte. 
	@history Everson, 18/03/2022, Chamado 18465. Envio de informa��es ao barramento. 
	@history Everson, 24/03/2022, Chamado 18465. Envio de informa��es ao barramento.
/*/
User Function M410STTS()

	Local aArea		:= GetArea() //Everson - 10/02/2020. Chamado 054941.
	Local lLocUsr	:= .F. //Everson - 29/10/2019. Chamado 052898.
	Local _lEECFat	:= GetMv("MV_EECFAT") //por Adriana em 04/10/2019-chamado 052170
	Local _nOper 	:= PARAMIXB[1]
	Local cRotSA1   := "" //26/06/2020, Everson, Chamado 059127.

	Local lWSBradOn := GetMV("MV_#WSRAON",,.T.) // @history chamado 059415 - FWNM - 13/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO

	Private lSfInt	:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	If Alltrim(cEmpAnt) <> "01"  ;  //Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804
		.and. Alltrim(cEmpAnt) <> "09"; //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG
		.And. Alltrim(cEmpAnt) <> "07" //Everson - 10/02/2020. Chamado 054941.
		RestArea(aArea) //Everson - 10/02/2020. Chamado 054941.
		Return     
	Endif

	//
	SetPrvt("_CALIAS,_CORDER,_CRECNO,_CNUMPED,_CCLIENTE,_CLOJA")
	SetPrvt("_NTOTALPEDI,_NTOTALCX,_NTOTALKG,_NTOTALBR,")
	SetPrvt("_SC6cAliasSC6,_SC6cOrderSC6,_SC6cRecnoSC6,_SC5cAliasSC5,_SC5cOrderSC5,_SC5cRecnoSC5")

	Private _nTotalPedi := 0,_nTotalCx := 0,_nTotalKg := 0,_nTotalBr := 0, _nTIteKg := 0, _nTIteBr := 0

	// VARIAVEIS INCLUIDAS PARA DESENVOLVIMENTO DA TABELA DE PRECOS MATRIZ
	Private _nFrete  	:= 0,_nPrcDig := 0,_nPrDigL := 0,_nPrcTab := 0
	Private _nPrTabL 	:= 0,_nPrPerT := 0,_nPrDigT := 0,_nValMax := 0
	Private _nPrPerTV 	:= 0,_nPrPerTS := 0,_nPrPerTG := 0,_nPrPerTD := 0
	Private _nPreTabS 	:= 0,_nPreLiqS := 0,_nValorNF := 0,_nPrTabT := 0
	Private _nIpProd 	:= 0,_nIpTot  := 0,_nDesconto := 0
	Private _cRede 		:= "",_cQry := "",_TpFrete := ""
	Private _lLoja	 	:= .T. 
	Private _bloqueia 	:= .F.
	Private _cRegiao 	:= ""
	Private _nVlrItem 	:= 0
	Private _cTesDoa  	:= Alltrim(GetMv("MV_XTESDOA"))
	Private _lDoa     	:= .F. 
	Private _cTesBon  	:= Alltrim(GetMv("MV_XTESBON")) // Incluido por Adriana para tratamento de bonificacao qualidade em 20/05/2015
	Private _cTesBoQ  	:= Alltrim(GetMv("MV_XTESBOQ")) // Incluido por Adriana em 20/07/16 - chamado 029611
	Private _lBon     	:= .F.  						// Incluido por Adriana para tratamento de bonificacao qualidade
	Private _cUsuBon  	:= Alltrim(GetMv("MV_#USUBON")) // Incluido por Adriana para tratamento de bonificacao qualidade
	Private _cAprBon  	:= Alltrim(GetMv("MV_#APRBON")) // Incluido por Adriana para tratamento de bonificacao qualidade
	Private _cAprDoa  	:= Alltrim(GetMv("MV_#APRDOA")) // Incluido por Adriana para tratamento de aprovador doacao (diretoria)

	// *** INICIO 040917 || FISCAL || VALERIA || APROV DOACAO 12/04/2018 WILLIAM COSTA *** //
	Private lAprov2  	:= .F. 
	Private _cProdDoa  	:= Alltrim(GetMv("MV_#PRDDOA")) 
	Private _cAprDoa2  	:= Alltrim(GetMv("MV_#AP2DOA")) 
	// *** FINAL 040917 || FISCAL || VALERIA || APROV DOACAO 12/04/2018 WILLIAM COSTA *** //

	Private _cUsuExcPV	:= Alltrim(GetMv("MV_#USUEPV")) // Incluido por Adriana para validacao exclusao de Pedido de Venda Liberado

	Private	_cRepresent := ""
	Private	_cSuperv    := ""
	Private	_cSupervi   := ""
	Private	_cGerent    := ""
	Private	_cGerente   := ""
	Private	_cDireto    := ""
	Private	_cDiretor   := ""

	Private cBlCred		:= ""

	Private lCfop 		:= .F.  								//fernando chamado 036388 - fernando 20/07/2017 
	Private cMVCfop     := strtran(GETMV("MV_#CFOPRD"),",","/") //fernando chamado 036388 - fernando 20/07/2017 

	//�������������������������������������������������Ŀ
	//� Posicionamento original dos arquivos envolvidos �
	//���������������������������������������������������

	//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> INICIO PE" )

	_cAlias := Alias()
	_cOrder := IndexOrd()
	_cRecno := Recno()

	dbSelectArea("SC6")
	_SC6cAliasSC6 := Alias()
	_SC6cOrderSC6 := IndexOrd()
	_SC6cRecnoSC6 := Recno()
	dbSetOrder(1)

	//�������������������������������������������������������������Ŀ
	//� Guarda o Pedido Posicionado (imediatamente apos a gravacao) �
	//���������������������������������������������������������������
	dbSelectArea("SC5")
	_cNumPed  := M->C5_NUM
	_cCliente := M->C5_CLIENTE
	_cLoja    := M->C5_LOJACLI 
	_Tipo     := M->C5_TIPO
	_Estado   := M->C5_EST
	_cTpFret  := M->C5_TPFRETE
	_nMoeda   := M->C5_MOEDA
	_dEmissao := M->C5_EMISSAO
	_cFilSC5	:= M->C5_FILIAL

	_SC5cAliasSC5 := Alias()
	_SC5cOrderSC5 := IndexOrd()
	_SC5cRecnoSC5 := Recno()

	// FWNM - 18/04/2018 - CHAMADO 037729
	If IsInCallStack("A410Deleta")
		DelZC1PV(_cNumPed)
		DelRAFIE(_cNumPed) // Chamado 059655 - FWNM - 21/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	EndIf
	//

	//Everson - 11/11/2019. Chamado 052898.
	If (INCLUI .Or. ALTERA) .And. !lSfInt

		//
		_nFrete := obtFrt(_cCliente,_cLoja,_cTpFret)

		//
		RecLock("SC5",.F.)
			SC5->C5_FRETAPV := _nFrete
		SC5->(MsUnLock())

	EndIf

	// Separado em duas partes: uma para INCLUS�O e outra para ALTERA��O - Paulo - TDS - 23/05/2011
	If INCLUI
		//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> INICIO INCLUI 1" )
		// Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.
		// Fun��o comentada para n�o fazer mais a chamada � rotina
		// IF ALLTRIM(cEmpAnt) == '01' .AND. ALLTRIM(xFilial("SC5")) == '02' // chamado 031739 William Costa, adicionado esse if pois causava lentid�o devido ao alta quantidade de pedidos referente ao cliente 60037058
			//21/10/16 Novo tratamento para pre aprovacao do credito
		// 	fPreAprv(xFilial("SC5"),_cNumped,_cCliente,_cLoja)  //funcao pra limpeza de flag de pre aprovacao de pedidos de venda.    	
		// ENDIF

		//Mauricio - Chamado 037330 - 
		IF !lSfInt .And. !Empty(M->C5_XREFATD) .And. Alltrim(cEmpAnt) $ "01/02"
			DbSelectArea("SC5")
			if dbseek(xFilial("SC5")+M->C5_XREFATD)
				If Empty(SC5->C5_XPEDGER)
					Reclock("SC5",.F.)
					SC5->C5_XPEDGER := M->C5_NUM  
					SC5->(MsUnlock())
				Else
					If !(M->C5_NUM $ SC5->C5_XPEDGER)             
						Reclock("SC5",.F.)
						SC5->C5_XPEDGER := Alltrim(SC5->C5_XPEDGER)+"/"+M->C5_NUM   
						SC5->(MsUnlock())
					Endif
				Endif   
				//restauro a area original salva acima
				dbSelectArea(_SC5cAliasSC5)
				dbSetOrder(_SC5cOrderSC5)
				dbGoto(_SC5cRecnoSC5)
			Endif   
		ENDIF 
		
		//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> INICIO AVALIA CREDITO" )
		_nLimCred 	:= 0
		_nLimCred 	:= Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_LC")
		_lBloq 		:= .F. 
		_nSldAb 	:= fBscSld(_cCliente,_cLoja)   //busca saldo em aberto para o cliente

		dbSelectArea("SC6")

		If SC6->(dbSeek(xFilial("SC6")+_cNumPed ))

			//Mauricio 25/09/13 - verifico aqui se existe TES de Doacao/Bonificacao..
			_lDoa := .F.

			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))

			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))

			//Everson - 10/02/2020. Chamado 054941.
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())

			//
			While SC6->(!Eof()) .And. SC6->C6_NUM == _cNumPed

				//Everson - 10/02/2020. Chamado 054941.
				SB1->( DbSeek( FWxFilial("SB1") + SC6->C6_PRODUTO ) )
				

				_nTotalPedi += SC6->C6_VALOR
				_nTotalCx   += SC6->C6_UNSVEN   // Soma qtd caixas (2a. UM)
				//_nTotalKg   += SC6->C6_QTDVEN   // Soma qtd peso   (1a. UM)

				//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
				_nTIteKg := 0
				_nTIteBr := 0

				//Everson - 10/02/2020. Chamado 054941.
				If Alltrim(cValToChar(SB1->B1_COD)) == Alltrim(cValToChar(SC6->C6_PRODUTO)) .And. SB1->B1_PESO > 0
					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteKg := SC6->C6_UNSVEN * SB1->B1_PESO
					_nTotalKg += _nTIteKg
					//_nTotalKg += SC6->C6_UNSVEN * SB1->B1_PESO

				Else
					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteKg := iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   (1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso
					_nTotalKg += _nTIteKg
					//_nTotalKg += iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   (1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso

				EndIf

				//Everson - 10/02/2020. Chamado 054941.
				If Alltrim(cValToChar(SB1->B1_COD)) == Alltrim(cValToChar(SC6->C6_PRODUTO)) .And. SB1->B1_PESBRU > 0
					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteBr := SC6->C6_UNSVEN * SB1->B1_PESBRU
					_nTotalBr += _nTIteBr - _nTIteKg
					//_nTotalBr += SC6->C6_UNSVEN * SB1->B1_PESBRU
					//_nTotalBr := _nTotalBr - _nTotalKg

				Else

					//����������������������������Ŀ
					//� Posiciona Cadastro de Tara �
					//������������������������������
					dbSelectArea("SZC")
					dbSetOrder(1)
					If dbSeek(xFilial("SZC") + SC6->C6_SEGUM)
						//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
						_nTIteBr := (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
						_nTotalBr += _nTIteBr
						//_nTotalBr += (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
					
					Else
						//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
						_nTIteBr := 0 //(SC6->C6_UNSVEN  * 1) // PESO BRUTO //WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO
						_nTotalBr += _nTIteBr
						//_nTotalBr += 0 //(SC6->C6_UNSVEN  * 1) // PESO BRUTO //WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO
					
					EndIf

				EndIf

				//Mauricio 25/09/13 - verifico aqui se existe TES de Doacao/Bonificacao..
				If Alltrim(SC6->C6_TES) $ _cTESDOA  //"803/805/545/581/625/665/541/"    //Tes levantadas juntas ao Raul Faturamento.
					_lDoa := .T.			
				Endif

				//			If Alltrim(SC6->C6_TES) $ _cTESBON  // Incluido por Adriana para tratar bonificacao qualidade
				If Alltrim(SC6->C6_TES) $ _cTESBOQ // Modificado por Adriana em 20/07/16 - chamado 029611
					_lBon := .T.			// Incluido por Adriana para tratar bonificacao qualidade
				Endif

				dbSelectArea("SC6")
				SC6->(dbSkip())

			EndDo

		EndIf

		//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL AVALIA CREDITO" )

		//��������������������������Ŀ
		//� Grava Informacoes em SC5 �
		//����������������������������

		dbSelectArea("SC5")

		If SC5->C5_EST <> "EX" .or. (SC5->C5_EST = "EX" .and. _lEECFat) //por Adriana em 04/10/2019-chamado 052170(Mantem peso digitado, se exporta��o e m�dulo SIGAEEC desabilitado) 

			RecLock("SC5",.F.)
			
			// *** INICIO WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO *** // 
			SC5->C5_PBRUTO  := IIF(M->C5_PBRUTO  <> _nTotalBr + _nTotalKg,_nTotalBr + _nTotalKg,M->C5_PBRUTO )
			SC5->C5_PESOL   := IIF(M->C5_PESOL   <> _nTotalKg,_nTotalKg, M->C5_PESOL)
			SC5->C5_VOLUME1 := IIF(M->C5_VOLUME1 <> _nTotalCx,_nTotalCx, M->C5_VOLUME1)
			// *** FINAL WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO *** // 
		
		Endif
		
		IF ALLTRIM(FUNNAME()) == "TELEATD"  //Mauricio 19/02/14 para atender customiza��o do teleatendimento
			SC5->C5_TELEATD := ZUA_NUM     
		Endif

		SC5->(MsUnlock())

		If !lSfInt .And. _lDoa      //Mauricio Doacao

			lAprov2 := VerifAprovDoacao() //Inicio William TI chamado 040917 

			RecLock("SC5",.F.)
			SC5->C5_BLQ     := "1"        //for�o bloqueio padr�o do pedido de venda.... 
			SC5->C5_STATDOA := "B"
			SC5->C5_APRVDOA := IIF(lAprov2 == .F.,_cAprDoa,_cAprDoa2)   //"000559"  Alterado por Adriana para alterar o aprovador //"001002"  //"000559"   //Conforme email do Sr. Evandro usuario � CAIO	   
			SC5->(MsUnlock())	   
			femailf(_cNumPed,cFilAnt,M->C5_EMISSAO,_nTotalPedi,"1") //Incluir aqui fun��o para envio de email ao Caio	   		
		Endif
				// *** INICIO CHAMADO WILLIAM 11/06/2018 036887 || TECNOLOGIA || MARCEL_BIANCHI || 8451 || VALID.ROT.REPROGR. ***  //
		
		If SC5->C5_DTENTR == DATE()
			
			IF SC5->C5_XTIPO <> '2'
				fAtuRot("197")
			endif

			
		// *** FINAL CHAMADO WILLIAM 11/06/2018 036887 || TECNOLOGIA || MARCEL_BIANCHI || 8451 || VALID.ROT.REPROGR. ***  //
		//Inclusao	
		//Mauricio 06/01/16 alterar roteiro para "099" para frete FOB...conforme definicao MARCEL em reuniao.	
		//Inicio
		ElseIF SC5->C5_TPFRETE == "F"    //fob

			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif
			
					
		Elseif SC5->C5_TPFRETE == "C"  //CIF precisa estar roteirizado....
			//IF !EMPTY(SC5->C5_ROTEIRO)
			dbSelectArea("SA1")         //Seguindo linha dos gatilhos atuais que preenchem os campos no pedido de venda.
			SA1->(dbSetOrder(1))		
			If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))   
				IF !EMPTY(SA1->A1_ROTEIRO)

					//Everson, 26/06/2020. Chamado 059127.
					cRotSA1 := getRot(Alltrim(cValToChar(SA1->A1_ROTEIRO)))

					IF SC5->C5_XTIPO <> '2'
						// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
						// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
						fAtuRot(cRotSA1)
					endif
				Else

					IF SC5->C5_XTIPO <> '2'
						// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
						// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
						fAtuRot("200")
					endif

				Endif
			Endif   
			//ENDIF
		Endif
		//Fim

		If !lSfInt .And. _lBon .and. __cuserid$_cUsuBon  // Incluido por Adriana para tratar bonificacao qualidade em 20/05/2015
			
			if RecLock("SC5",.F.)
				SC5->C5_APRVDOA := _cAprBon   // Aprovador bonificacao qualidade

				SC5->(MsUnlock())
			endif	   
			//	   		femailf(_cNumPed,cFilAnt,M->C5_EMISSAO,_nTotalPedi,"1") //Incluir aqui fun��o para envio de email ao Caio	
			
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif

		ElseIf 	lSfInt .And. _lBon
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif
			
			/* LPM - Trecho descontinuado.
			RecLock("SC5",.F.)
			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'
				SC5->C5_ROTEIRO := "099"
			ENDIF
			SC5->(MsUnlock())
			*/
		Endif

		dbSelectArea("SA3")
		SA3->(dbSetOrder(7))

		//Everson - 29/10/2019. Chamado 052898.
		lLocUsr := SA3->(dbSeek(xFilial("SA3")+__cUserID))

		//Everson - 29/10/2019. Chamado 052898.
		/* Tempor�rio
		u_GrLogZBE (Date(), Time(), cUserName, "PEDIDO DE VENDA", "COMERCIAL", "M410STTS",;
		"Pedido/!Rest/SA3/!Doa��o " + cValToChar(SC5->C5_NUM) + " " +;
		cValToChar(! IsInCallStack('U_RESTEXECUTE') .And. ! IsInCallStack('RESTEXECUTE')) + " " +;
		cValToChar( lLocUsr )+ " " +;
		cValToChar( !_lDoa )+ " ",;
		ComputerName(), LogUserName())
		*/

		If !lSfInt .And. lLocUsr .And. !(_lDoa) // S� executa se usuario incluindo pedido for vendedor (primeira condi��o) e n�o for doa��o.

			dbSelectArea("SA1")
			dbSetOrder(1)

			If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))

				_cRepresent := SA1->A1_VEND
				_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprova��o
				_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
				_cGerent    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_GEREN")        // gerente para aprova��o
				_cGerente   := Posicione("SA3",1,xFilial("SA3")+_cGerent,"A3_CODUSR")
				_cDireto    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_XDIRET")       // diretor para aprova��o
				_cDiretor   := Posicione("SA3",1,xFilial("SA3")+_cDireto,"A3_CODUSR")

				DbSelectArea("SA3")
				dbSetOrder(1)
				dbseek(xFilial("SA3")+_cRepresent)   //preciso posicionar no representante do cliente nao no usuario que esta incluindo.

				If Empty(SA1->A1_REDE)
					_lLoja := .T.

					RecLock("SC5",.F.)
					SC5->C5_XREDE := "N"
					SC5->(MsUnLock())

				Else
					_lLoja := .F.
					_cRede := SA1->A1_REDE

					RecLock("SC5",.F.)
					SC5->C5_XREDE := "S"
					SC5->C5_BLQ   := "1"
					SC5->C5_LIBEROK := " "                 // Quando o pedido for de cliente rede, entra j� bloqueado
					SC5->C5_CODRED  := _cRede          // Grava codigo da rede utilizado na rotina ANALISPED.
					SC5->(MsUnLock())

				EndIf
			EndIf

			If _lLoja
				// Busco desconto para Cliente. O desconto aqui informado � em PERCENTUAL - PAULO - TDS - 12/05/2011
				_nDesconto := SA1->A1_DESC

				// Busco frete para Cliente
				_cEst	:= SA1->A1_EST
				_cMunic := SA1->A1_COD_MUN
				_ctabela := ""  // M->C5_TABELA  - Mauricio 07/12/11 - tabela vira por faixa de peso e n�o mais do pedido.
				// Localizo o municipio do cliente, se este for loja

				//Mauricio 07/12/11 - Retirado tratamento para tabela vinda do pedido. Tabela sera assumida pela faixa de Qtd. caixas que o pedido se
				//encaixa (Usando tabela ZZP criada).
				//If Empty(M->C5_TABELA)

				dbSelectArea("ZZP")
				dbSetOrder(1)
				dbGoTop()

				While !Eof()
					If _nTotalCx >= ZZP->ZZP_PESOI .And. _nTotalCx <= ZZP->ZZP_PESOF
						//pega a tabela que se encaixa na faixa
						_cTabela := ZZP->ZZP_TABELA
						Exit
					EndIf
					dbSkip()
				EndDo

				//EndIf

				//Mauricio - 07/12/11 - tratamento para caso n�o haver tabela cadastrada ou faixa de peso
				//precisa ser analisado a posterior, para encontrar melhor alternativa de a��o a ser tomada.
				If Empty(_cTabela)
					//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL PE" )
					return()
				Else
					//atualizo campo tabela no SC5
					reclock("SC5",.F.)
					SC5->C5_TABELA := _cTabela
					Msunlock()      
				Endif

				dbSelectArea("DA0")
				dbSetOrder(1)

				If dbSeek(xFilial("DA0")+_cTabela)

					// Condi��o para achar percentual baseado em um unico usuario(ou vendedor ou supervisor ou gerente ou diretor)
					If     SA3->A3_NIVETAB == "2" // supervisor
						_nValMax := 1-(DA0->DA0_XSUPER/100)         // percentual supervisor
					ElseIf SA3->A3_NIVETAB == "3" // Gerente
						_nValMax := 1-(DA0->DA0_XGEREN/100)         // percentual gerente
					ElseIf SA3->A3_NIVETAB == "4"
						_nValMax := 1-(DA0->DA0_XDIRET/100)         // percentual diretor
					Else
						_nValMax := 1-(DA0->DA0_XVENDE/100)		 // percentual vendedor
					EndIf

					// Condi��o para achar um percentual para cada usuario sempre(vendedor,supervisor,gerente, diretor)
					// Destinado a geracao de al�ada separadamente.(Mauricio 11/05/11.)

					_nValMaxV := 1-(DA0->DA0_XVENDE/100)
					_nValMaxS := 1-(DA0->DA0_XSUPER/100)
					_nValMaxG := 1-(DA0->DA0_XGEREN/100)
					_nValMaxD := 1-(DA0->DA0_XDIRET/100)

				EndIf

				//Mauricio - MDS TEC - 21/05/14 - Inclus�o de tratamento para pedido com moeda 2 e calculo dos indices pelo valor convertido pela
				//cota��o do dia.

				dbSelectArea("SC6")
				dbSetOrder(1)

				If dbSeek(xFilial("SC6")+_cNumPed)				

					While !Eof() .And. SC6->C6_NUM == _cNumped

						If _nMoeda == 1   

							_nPrcDig := SC6->C6_PRCVEN * (_nDesconto / 100) // Pre�o digitado no produto, inclu�do o desconto
							_nPrDigL := SC6->C6_PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
							_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

							dbSelectArea("DA1")
							dbSetOrder(1)

							If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
								_nPrcTab := DA1->DA1_XPRLIQ									// Preco da tabela de precos
								_nPrPerm := _nPrcTab * _nValMax 	                        // Preco minimo permitido para o usuario

								// Preco minimo permitido para todas as al�adas.(tera de verificar todas as al�adas de uma unica vez conforme Alex - 11/05/11.)
								_nPrPermV := _nPrcTab * _nValMaxV
								_nPrPermS := _nPrcTab * _nValMaxS
								_nPrPermG := _nPrcTab * _nValMaxG
								_nPrPermD := _nPrcTab * _nValMaxD

								_nVlTotT  := SC6->C6_QTDVEN * _nPrPerm
								_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab  //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

								_nVlTotTV := SC6->C6_QTDVEN * _nPrPermV
								_nVlTotTS := SC6->C6_QTDVEN * _nPrPermS
								_nVlTotTG := SC6->C6_QTDVEN * _nPrPermG
								_nVlTotTD := SC6->C6_QTDVEN * _nPrPermD

								//Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								//_nIpProd := _nVlTotD/_nVlTotT
								_nIpProd := _nVlTotD/_nVlTotT2

								//Mauricio 10/08/11 - implementando sistematica de altera�oes solicitadas em 10/08/11 - email Sr. Alex.

								_nPBTTV  := SC6->C6_PRCVEN    //preco digitado
								_nPLTTV  := _nPrDigL          //preco liquido
								_nPLTVD  := _nPrPermV         //preco minimo vendedor
								_nPLTSV  := _nPrPermS  //preco minimo supervisor

								dbSelectArea("SC6")
								RecLock("SC6",.F.)
								SC6->C6_XIPTAB := Round(_nIpProd,3)
								SC6->C6_TOTDIG := _nVlTotD
								SC6->C6_TOTTAB := _nVlTotT2     //_nVlTotT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								SC6->C6_PRTABV := _nPrPerm + _nFrete // Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
								SC6->C6_PBTTV  := _nPBTTV
								SC6->C6_PLTTV  := _nPLTTV
								SC6->C6_PLTVD  := _nPLTVD
								SC6->C6_PLTSP  := _nPLTSV 
								SC6->C6_PLTAB  := _nPrcTab
								MsUnLock()

								_nPrDigT  += _nVlTotD	 // Soma dos pre�os l�quidos digitados
								_nPrPerT  += _nVlTotT    // Soma dos pre�os das tabelas
								_nPrTabT  += _nVlTotT2     //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								_nPrPerTV += _nVltotTV   // Soma pre�o das tabelas para al�ada
								_nPrPerTS += _nVltotTS
								_nPrPerTG += _nVltotTG
								_nPrPerTD += _nVltotTD

								_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   //Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e n�o unitario conf. Sr. Alex
								_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   //Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e n�o unitario conf. Sr. Alex
								_nValorNF += SC6->C6_VALOR
							EndIf
						Else   
							//Se n�o tiver data cadastrada ou o valor for zero assume o valor de 1(para n�o dar erro na rotina).
							_nCota := 0
							DbSelectArea("SM2")
							DbSetOrder(1)
							if DbSeek(Dtos(_dEmissao))
								//Alterado por Adriana em 30/01/2018 para tratar outras moedas					   
								// _nCota := M2_MOEDA2 
								_nCota := &("M2_MOEDA"+STR(_nMoeda,1))
							Else
								_nCota := 1
							Endif

							If _nCota == 0
								_nCota := 1
							Endif   

							_nC6PRCVEN := SC6->C6_PRCVEN * _nCota  //transformo valor em dolar do pedido para real.


							_nPrcDig := _nC6PRCVEN * (_nDesconto / 100) // Pre�o digitado no produto, inclu�do o desconto
							_nPrDigL := _nC6PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
							_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

							dbSelectArea("DA1")
							dbSetOrder(1)

							If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
								_nPrcTab := DA1->DA1_XPRLIQ									// Preco da tabela de precos
								_nPrPerm := _nPrcTab * _nValMax 	                        // Preco minimo permitido para o usuario

								// Preco minimo permitido para todas as al�adas.(tera de verificar todas as al�adas de uma unica vez conforme Alex - 11/05/11.)
								_nPrPermV := _nPrcTab * _nValMaxV
								_nPrPermS := _nPrcTab * _nValMaxS
								_nPrPermG := _nPrcTab * _nValMaxG
								_nPrPermD := _nPrcTab * _nValMaxD

								_nVlTotT  := SC6->C6_QTDVEN * _nPrPerm
								_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab  //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

								_nVlTotTV := SC6->C6_QTDVEN * _nPrPermV
								_nVlTotTS := SC6->C6_QTDVEN * _nPrPermS
								_nVlTotTG := SC6->C6_QTDVEN * _nPrPermG
								_nVlTotTD := SC6->C6_QTDVEN * _nPrPermD

								//Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								//_nIpProd := _nVlTotD/_nVlTotT
								_nIpProd := _nVlTotD/_nVlTotT2

								//Mauricio 10/08/11 - implementando sistematica de altera�oes solicitadas em 10/08/11 - email Sr. Alex.

								_nPBTTV  := _nC6PRCVEN    ///SC6->C6_PRCVEN    //preco digitado em dolar convertido
								_nPLTTV  := _nPrDigL          //preco liquido
								_nPLTVD  := _nPrPermV         //preco minimo vendedor
								_nPLTSV  := _nPrPermS  //preco minimo supervisor

								dbSelectArea("SC6")
								RecLock("SC6",.F.)
								SC6->C6_XIPTAB := Round(_nIpProd,3)
								SC6->C6_TOTDIG := _nVlTotD
								SC6->C6_TOTTAB := _nVlTotT2     //_nVlTotT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								SC6->C6_PRTABV := _nPrPerm + _nFrete // Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
								SC6->C6_PBTTV  := _nPBTTV
								SC6->C6_PLTTV  := _nPLTTV
								SC6->C6_PLTVD  := _nPLTVD
								SC6->C6_PLTSP  := _nPLTSV 
								SC6->C6_PLTAB  := _nPrcTab
								MsUnLock()

								_nPrDigT  += _nVlTotD	 // Soma dos pre�os l�quidos digitados
								_nPrPerT  += _nVlTotT    // Soma dos pre�os das tabelas
								_nPrTabT  += _nVlTotT2     //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
								_nPrPerTV += _nVltotTV   // Soma pre�o das tabelas para al�ada
								_nPrPerTS += _nVltotTS
								_nPrPerTG += _nVltotTG
								_nPrPerTD += _nVltotTD

								_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   //Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e n�o unitario conf. Sr. Alex
								_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   //Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e n�o unitario conf. Sr. Alex
								_nValorNF += (SC6->C6_VALOR * _nCota)
							EndIf										
						Endif

						dbSelectArea("SC6")
						dbSkip()
					EndDo

					_nVlIP := _nPrDigT/_nPrTabT     //_nPrPerT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
					_nVlIP := noRound(_nVlIP,3)

					if _nVlIP < 1	
						RecLock("SC5",.F.)
						_bloqueia := .F.
						// Antiga forma de al�ada ja substituida Mauricio 11/05/11.

						//_cSupervi   := Posicione("SA3",1,xFilial("SA3")+SA3->A3_SUPER,"A3_CODUSR")
						//_cGerente   := Posicione("SA3",1,xFilial("SA3")+SA3->A3_GEREN,"A3_CODUSR")
						//_cDiretor   := Posicione("SA3",1,xFilial("SA3")+SA3->A3_XDIRET,"A3_CODUSR")

						If    SA3->A3_NIVETAB == "1"                  // Se for um vendedor
							//Verifico a al�ada do vendedor - Alex Borges 30/09/11
							If _nPrDigT < _nPrPerTV   
								SC5->C5_APROV1 := _cSupervi
								_bloqueia := .T.
							EndIF
							If _nPrDigT < _nPrPerTS                   // verifico al�ada supervisor para o vendedor
								SC5->C5_APROV2 := _cGerente
								_bloqueia := .T.
							EndIf

							If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente para o vendedor
								SC5->C5_APROV3 := _cDiretor
								_bloqueia := .T.
							EndIf


						ElseIf SA3->A3_NIVETAB == "2"				     // Se for um supervisor
							If _nPrDigT < _nPrPerTS                   // verifico al�ada supervisor para o vendedor
								SC5->C5_APROV2 := _cGerente
								_bloqueia := .T.
							EndIf

							If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente para o vendedor
								SC5->C5_APROV3 := _cDiretor
								_bloqueia := .T.
							EndIf

						ElseIf SA3->A3_NIVETAB == "3"					// Se for um gerente

							If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente para o vendedor
								SC5->C5_APROV3 := _cDiretor
								_bloqueia := .T.
							EndIf
						EndIf
						SC5->(MsUnLock())
					EndIf

					RecLock("SC5",.F.)
					If _bloqueia
						SC5->C5_BLQ    := "1"
						SC5->C5_DTBLOQ := dDataBase
						SC5->C5_HRBLOQ := Time()
					EndIf
					SC5->C5_FRETAPV := _nFrete   //Mauricio 16/11/11.
					SC5->C5_XIPTAB  := _nVlIP  
					SC5->C5_TOTDIG  := _nPrDigT
					SC5->C5_TOTTAB  := _nPrTabT   //_nPrPerT  //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
					SC5->C5_DESCTBP := _nPreTabS - _nPreLiqS
					SC5->C5_VALORNF := _nValorNF
					SC5->(MsUnLock())
				EndIf
			Else     //Mauricio - 19/05/17 - Chamado 035118 - tratamento de valor de frete tambem para rede.
				// Busco frete para Cliente
				_cEst	:= SA1->A1_EST
				_cMunic := SA1->A1_COD_MUN

				RecLock("SC5",.F.)
				SC5->C5_FRETAPV := _nFrete
				SC5->(MsUnLock())

			EndIf 

			If AllTrim(SC5->C5_BLQ) == "1"
				RecLock("SC5",.F.)
				SC5->C5_LIBEROK := " "
				MsUnlock()

				dbSelectArea("SC9")   // Mauricio 25/03/11 Projeto tabela de pre�o: como � customizado verifico se gerou libera��o e havendo deleto todos os registros.
				dbSetOrder(1)

				If dbSeek(xFilial("SC9")+_cNumPed)
					While !Eof() .And. SC9->C9_PEDIDO == _cNumPed				    
						Reclock("SC9",.F.)
						dbDelete()
						MsUnlock()
						SC9->(dbSkip())
					EndDo
				EndIf
				dbSelectArea("SC6")   
				dbSetOrder(1)	
				If dbSeek(xFilial("SC6")+_cNumPed)
					While !Eof() .And. SC6->C6_NUM == _cNumPed
						Reclock("SC6",.F.)				
						SC6->C6_QTDEMP  := 0.00
						SC6->C6_QTDEMP2 := 0.00
						MsUnlock()
						SC6->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		If !lSfInt .And. _lDoa .or. __cuserid$_cUsuBon   //Se foi pedido de doa��o preciso verificar se gerou SC9 e deletaer registros para n�o liberar para faturamento
			//Incluida verificacao para usuario de bonificacao qualidade
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := " "
			MsUnlock()

			dbSelectArea("SC9")   
			dbSetOrder(1)			
			If dbSeek(xFilial("SC9")+_cNumPed)
				While !Eof() .And. SC9->C9_PEDIDO == _cNumPed		
					Reclock("SC9",.F.)
					dbDelete()
					MsUnlock()
					SC9->(dbSkip())
				EndDo
			EndIf
			dbSelectArea("SC6")   
			dbSetOrder(1)	
			If dbSeek(xFilial("SC6")+_cNumPed)
				While !Eof() .And. SC6->C6_NUM == _cNumPed
					Reclock("SC6",.F.)				
					SC6->C6_QTDEMP  := 0.00
					SC6->C6_QTDEMP2 := 0.00
					MsUnlock()
					SC6->(dbSkip())
				EndDo
			EndIf				
		Endif	

		//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL INLCUI" )
		// Logica para altera��o
	ElseIf ALTERA

		// Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.
		// Fun��o comentada para n�o fazer mais a chamada � rotina
		// IF ALLTRIM(cEmpAnt) == '01' .AND. ALLTRIM(xFilial("SC5")) == '02' // chamado 031739 William Costa, adicionado esse if pois causava lentid�o devido ao alta quantidade de pedidos referente ao cliente 60037058
			// 21/10/16 Novo tratamento para pre aprovacao do credito
		// 	fPreAprv(xFilial("SC5"),_cNumped,_cCliente,_cLoja)  //funcao pra limpeza de flag de pre aprovacao de pedidos de venda.
		// ENDIF

		//Mauricio - Chamado 037330 - 
		IF !lSfInt .And. !Empty(M->C5_XREFATD) .And. Alltrim(cEmpAnt) $ "01/02" 
			DbSelectArea("SC5")
			if dbseek(xFilial("SC5")+M->C5_XREFATD)
				If Empty(SC5->C5_XPEDGER)
					Reclock("SC5",.F.)
					SC5->C5_XPEDGER := M->C5_NUM   
					SC5->(MsUnlock())
				Else
					If !(M->C5_NUM $ SC5->C5_XPEDGER)           
						Reclock("SC5",.F.)
						SC5->C5_XPEDGER := Alltrim(SC5->C5_XPEDGER)+"/"+M->C5_NUM  
						SC5->(MsUnlock())
					Endif   
				Endif   
				//restauro a area original salva acima(inicio)
				dbSelectArea(_SC5cAliasSC5)
				dbSetOrder(_SC5cOrderSC5)
				dbGoto(_SC5cRecnoSC5)
			Endif   
		ENDIF

		//Mauricio 09/08/11 - Incluido tratamento para recalculo do peso liquido e bruto tambem na altera��o.
		dbSelectArea("SC6")	
		If dbSeek(xFilial("SC6")+_cNumPed )

			//Mauricio 25/09/13 - verifico aqui se existe TES de Doacao/Bonificacao..
			_lDoa := .F.       
			_lBon := .F. //Incluido por Adriana para tratar bonificacao qualidade

			//Everson - 10/02/2020. Chamado 054941.
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())

			While !Eof() .And. SC6->C6_NUM == _cNumPed

				//Everson - 10/02/2020. Chamado 054941.
				SB1->( DbSeek( FWxFilial("SB1") + SC6->C6_PRODUTO ) )

				_nTotalPedi += SC6->C6_VALOR
				_nTotalCx   += SC6->C6_UNSVEN   // Soma qtd caixas (2a. UM)
				//			_nTotalKg   += SC6->C6_QTDVEN   // Soma qtd peso   (1a. UM)
				
				//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
				_nTIteKg := 0
				_nTIteBr := 0

				//Everson - 10/02/2020. Chamado 054941.
				If Alltrim(cValToChar(SB1->B1_COD)) == Alltrim(cValToChar(SC6->C6_PRODUTO)) .And. SB1->B1_PESO > 0

					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteKg := SC6->C6_UNSVEN * SB1->B1_PESO
					_nTotalKg += _nTIteKg
					//_nTotalKg += SC6->C6_UNSVEN * SB1->B1_PESO

				Else
					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteKg := iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   (1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso
					_nTotalKg += _nTIteKg
					//_nTotalKg += iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   (1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso

				EndIf

				//Everson - 10/02/2020. Chamado 054941.
				If Alltrim(cValToChar(SB1->B1_COD)) == Alltrim(cValToChar(SC6->C6_PRODUTO)) .And. SB1->B1_PESBRU > 0
					//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
					_nTIteBr := SC6->C6_UNSVEN * SB1->B1_PESBRU
					_nTotalBr += _nTIteBr - _nTIteKg
					//_nTotalBr += SC6->C6_UNSVEN * SB1->B1_PESBRU
					//_nTotalBr := _nTotalBr - _nTotalKg

				Else

					//����������������������������Ŀ
					//� Posiciona Cadastro de Tara �
					//������������������������������
					dbSelectArea("SZC")
					dbSetOrder(1)
					If dbSeek(xFilial("SZC") + SC6->C6_SEGUM)
						//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
						_nTIteBr := (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
						_nTotalBr += _nTIteBr
						//_nTotalBr += (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
					
					Else
						//13/04/2020, Abel   , Chamado 057312 - Corre��o no c�lculo de Peso Bruto no Pedido de Venda quando mais de um item
						_nTIteBr := 0 //(SC6->C6_UNSVEN  * 1) // PESO BRUTO //WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO
						_nTotalBr += _nTIteBr
						//_nTotalBr += 0 //(SC6->C6_UNSVEN  * 1) // PESO BRUTO //WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO
					
					EndIf

				EndIf

				//Mauricio 25/09/13 - verifico aqui se existe TES de Doacao/Bonificacao..
				If Alltrim(SC6->C6_TES) $ _cTesDoa  //"803/805/545/581/625/665/541/"    //Tes levantadas juntas ao Raul Faturamento.
					_lDoa := .T.			
				Endif

				//			If Alltrim(SC6->C6_TES) $ _cTESBON  // Incluido por Adriana para tratar bonificacao qualidade
				If Alltrim(SC6->C6_TES) $ _cTESBOQ // Modificado por Adriana em 20/07/16 - chamado 029611
					_lBon := .T.			// Incluido por Adriana para tratar bonificacao qualidade
				Endif

				dbSelectArea("SC6")
				dbSkip()

			EndDo

		EndIf

		//��������������������������Ŀ
		//� Grava Informacoes em SC5 �
		//����������������������������	
		dbSelectArea("SC5")

		If SC5->C5_EST <> "EX" .or. (SC5->C5_EST = "EX" .and. _lEECFat) //por Adriana em 04/10/2019-chamado 052170(Mantem peso digitado, se exporta��o e m�dulo SIGAEEC desabilitado) 

			RecLock("SC5",.F.)
			
			// *** INICIO WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO *** // 
			SC5->C5_PBRUTO  := IIF(M->C5_PBRUTO  <> _nTotalBr + _nTotalKg,_nTotalBr + _nTotalKg,M->C5_PBRUTO )
			SC5->C5_PESOL   := IIF(M->C5_PESOL   <> _nTotalKg,_nTotalKg, M->C5_PESOL)
			SC5->C5_VOLUME1 := IIF(M->C5_VOLUME1 <> _nTotalCx,_nTotalCx, M->C5_VOLUME1)
			// *** FINAL WILLIAM COSTA 06/12/2018 CHAMADO 045531 || OS 046701 || PCP || KAREN || 8466 || COPIA DE PEDIDO *** // 
			
			MsUnlock()

		Endif
		
		If !lSfInt .And. _lDoa      //Mauricio Doacao

			lAprov2 := VerifAprovDoacao() //Inicio William TI chamado 040917

			RecLock("SC5",.F.)
			SC5->C5_BLQ     := "1"        //for�o bloqueio padr�o do pedido de venda....
			SC5->C5_STATDOA := "B"
			SC5->C5_APRVDOA := IIF(lAprov2 == .F.,_cAprDoa,_cAprDoa2)   //"000559"  Alterado por Adriana para alterar o aprovador    
			SC5->(MsUnlock())

			femailf(_cNumPed,cFilAnt,M->C5_EMISSAO,_nTotalPedi,"2") //Incluir aqui fun��o para envio de email ao Caio

		Endif

		//Na Alteracao	
		//Mauricio 06/01/16 alterar roteiro para "099" para frete FOB...conforme definicao MARCEL em reuniao.	
		//Inicio
		//Inicio: fernando Sigoli 18/06/2018
		IF SC5->C5_DTENTR == DATE()

			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("197")
			endif

			/* LPM - Trecho descontinuado.
			RecLock("SC5",.F.)	      
			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'
				SC5->C5_ROTEIRO := "197"      
			ENDIF
			SC5->(MsUnlock())
			*/

			//Atualizo tabela SC6 com novo roteiro
			/* LPM - Trecho descontinuado.
			dbSelectArea("SC6")
			dbSetOrder(1)			
			If dbSeek(xFilial("SC6")+_cNumPed)								
				While !Eof() .And. SC6->C6_NUM == _cNumped
					RecLock("SC6",.F.)	      
					SC6->C6_ROTEIRO := "197"      
					SC6->(MsUnlock())
					SC6->(dbSkip())
				Enddo
			Endif
			*/
			//Atualizo tabela SC9 com novo roteiro
			/* LPM - Trecho descontinuado.
			dbSelectArea("SC9")
			dbSetOrder(1)			
			If dbSeek(xFilial("SC9")+_cNumPed)								
				While !Eof() .And. SC9->C9_PEDIDO == _cNumped
					RecLock("SC9",.F.)	      
					SC9->C9_ROTEIRO := "197"      
					SC9->(MsUnlock())
					SC9->(dbSkip())
				Enddo
			Endif
			*/
		//Fim : fernando Sigoli 18/06/2018
		ElseIf SC5->C5_TPFRETE == "F"    //fob

			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif

			//IF !EMPTY(SC5->C5_ROTEIRO)
			/* LPM - Trecho descontinuado.
			RecLock("SC5",.F.)	    
			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'  
				SC5->C5_ROTEIRO := "099"      
			ENDIF
			SC5->(MsUnlock())
			*/
			//Atualizo tabela SC6 com roteiro
			/* LPM - Trecho descontinuado.
			dbSelectArea("SC6")
			dbSetOrder(1)			
			If dbSeek(xFilial("SC6")+_cNumPed)								
				While !Eof() .And. SC6->C6_NUM == _cNumped
					RecLock("SC6",.F.)	      
					SC6->C6_ROTEIRO := "099"      
					SC6->(MsUnlock())
					SC6->(dbSkip())
				Enddo
			Endif
			*/
			//Atualizo tabela SC9 com roteiro
			/* LPM - Trecho descontinuado.
			dbSelectArea("SC9")
			dbSetOrder(1)			
			If dbSeek(xFilial("SC9")+_cNumPed)								
				While !Eof() .And. SC9->C9_PEDIDO == _cNumped
					RecLock("SC9",.F.)	      
					SC9->C9_ROTEIRO := "099"      
					SC9->(MsUnlock())
					SC9->(dbSkip())
				Enddo
			Endif
			*/
			//Endif	  	 	   
		
		Elseif SC5->C5_TPFRETE == "C"  //CIF precisa estar roteirizado....
			//IF !EMPTY(SC5->C5_ROTEIRO)
			dbSelectArea("SA1")         //Seguindo linha dos gatilhos atuais que preenchem os campos no pedido de venda.
			SA1->(dbSetOrder(1))

			If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))   
				IF !EMPTY(SA1->A1_ROTEIRO)

					//Everson, 26/06/2020. Chamado 059127.
					cRotSA1 := getRot(Alltrim(cValToChar(SA1->A1_ROTEIRO)))
					
					IF SC5->C5_XTIPO <> '2'
						// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
						// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
						fAtuRot(cRotSA1)
					endif
					
					/* LPM - Trecho descontinuado.
					RecLock("SC5",.F.)	      
					// Ricardo Lima-28/02/2019
					IF SC5->C5_XTIPO <> '2'
						SC5->C5_ROTEIRO := cRotSA1 //Everson, 26/06/2020. Chamado 059127.
					ENDIF
					SC5->(MsUnlock())
					*/   	        
					//Atualizo tabela SC6 com novo roteiro
					/* LPM - Trecho descontinuado.
					dbSelectArea("SC6")
					dbSetOrder(1)			
					If dbSeek(xFilial("SC6")+_cNumPed)								
						While !Eof() .And. SC6->C6_NUM == _cNumped
							RecLock("SC6",.F.)	      
							SC6->C6_ROTEIRO := cRotSA1 //Everson, 26/06/2020. Chamado 059127.    
							SC6->(MsUnlock())
							SC6->(dbSkip())
						Enddo
					Endif
					*/
					//Atualizo tabela SC9 com novo roteiro
					/* LPM - Trecho descontinuado.
					dbSelectArea("SC9")
					dbSetOrder(1)			
					If dbSeek(xFilial("SC9")+_cNumPed)								
						While !Eof() .And. SC9->C9_PEDIDO == _cNumped
							RecLock("SC9",.F.)	      
							SC9->C9_ROTEIRO := cRotSA1 //Everson, 26/06/2020. Chamado 059127.  
							SC9->(MsUnlock())
							SC9->(dbSkip())
						Enddo
					Endif
					*/
				Else

					IF SC5->C5_XTIPO <> '2'
						// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
						// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
						fAtuRot("200")
					endif

					/* LPM - Trecho descontinuado.
					RecLock("SC5",.F.)	      
					// Ricardo Lima-28/02/2019
					IF SC5->C5_XTIPO <> '2'
						SC5->C5_ROTEIRO := "200"
					ENDIF
					SC5->(MsUnlock())
					*/
					//Atualizo tabela SC6 com novo roteiro
					/* LPM - Trecho descontinuado.
					dbSelectArea("SC6")
					dbSetOrder(1)			
					If dbSeek(xFilial("SC6")+_cNumPed)								
						While !Eof() .And. SC6->C6_NUM == _cNumped
							RecLock("SC6",.F.)	      
							SC6->C6_ROTEIRO := "200"    
							SC6->(MsUnlock())
							SC6->(dbSkip())
						Enddo
					Endif
					*/
					//Atualizo tabela SC9 com novo roteiro
					/* LPM - Trecho descontinuado.
					dbSelectArea("SC9")
					dbSetOrder(1)			
					If dbSeek(xFilial("SC9")+_cNumPed)								
						While !Eof() .And. SC9->C9_PEDIDO == _cNumped
							RecLock("SC9",.F.)	      
							SC9->C9_ROTEIRO := "200"     
							SC9->(MsUnlock())
							SC9->(dbSkip())
						Enddo
					Endif
					*/
				Endif
			Endif   
			//ENDIF
		Endif
		//Fim

		If !lSfInt .And. _lBon .and. __cuserid$_cUsuBon  // Incluido por Adriana para tratar bonificacao qualidade
			
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif
			
			/* LPM - Trecho descontinuado.
			RecLock("SC5",.F.)
			SC5->C5_APRVDOA := _cAprBon   // Aprovador bonificacao qualidade
			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'
				SC5->C5_ROTEIRO := "099"      // Roteiro n�o utilizado pela logistica - incluido por Adriana em 20/07/2016
			ENDIF
			SC5->(MsUnlock())
			*/	   
			//	   		femailf(_cNumPed,cFilAnt,M->C5_EMISSAO,_nTotalPedi,"1") //Incluir aqui fun��o para envio de email ao Caio	   		
		Endif

		If !lSfInt .And. _lBon 
			
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("099")
			endif
			
			/* LPM - Trecho descontinuado.
			RecLock("SC5",.F.)
			// Ricardo Lima-28/02/2019
			IF SC5->C5_XTIPO <> '2'
				SC5->C5_ROTEIRO := "099"
			ENDIF
			SC5->(MsUnlock())
			*/	   	   		
		Endif

		if !lSfInt .And. !(__cUserID $ _cUsuExcPV) .And. !(_lDoa) .And. !(__cuserid $ _cUsuBon)      //Adriana em 05/11/2015 - incluido parametro para validar exclusao de pedido de venda liberado
			//Mauricio 05/01/12 - retirado usuario Vagner pois ele n�o pode ter acesso a exclus�o
			//por essa rotina - Criado rotina EXCPEDCOM.prw
			////Mauricio Doacao 25/09/13 - adicionado somente para pedido diferente de doacao.	 
			// Incluido por Adriana para tratar bonificacao qualidade  !(__cuserid$_cUsuBon)                                                             		
			dbSelectArea("SA3")
			SA3->(dbSetOrder(7))

			//Everson - 29/10/2019. Chamado 052898.
			lLocUsr := dbSeek(xFilial("SA3")+__cUserID)

			//Everson - 29/10/2019. Chamado 052898.
			u_GrLogZBE (Date(), Time(), cUserName, "PEDIDO DE VENDA", "COMERCIAL", "M410STTS",;
			"Pedido/!Rest/SA3/!Doa��o " + cValToChar(SC5->C5_NUM) + " " +;
			cValToChar(!lSfInt) + " " +;
			cValToChar( lLocUsr )+ " " +;
			cValToChar( ! _lDoa )+ " ",;
			ComputerName(), LogUserName())

			If lLocUsr  // S� executa se usuario incluindo pedido for vendedor (primeira condi��o) e pedido diferente de doa�ao //Everson - 29/10/2019. Chamado 052898.

				dbSelectArea("SA1")
				dbSetOrder(1)

				If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))

					_cRepresent := SA1->A1_VEND
					_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprova��o
					_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
					_cGerent    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_GEREN")        // gerente para aprova��o
					_cGerente   := Posicione("SA3",1,xFilial("SA3")+_cGerent,"A3_CODUSR")
					_cDireto    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_XDIRET")       // diretor para aprova��o
					_cDiretor   := Posicione("SA3",1,xFilial("SA3")+_cDireto,"A3_CODUSR")

					DbSelectArea("SA3")
					dbSetOrder(1)
					dbSeek(xFilial("SA3")+_cRepresent)   //preciso posicionar no representante do cliente nao no usuario que esta incluindo.

					If Empty(SA1->A1_REDE)
						_lLoja := .T.

						RecLock("SC5",.F.)
						SC5->C5_CODRED := "      "
						SC5->C5_XREDE  := "N"
						SC5->(MsUnLock())
					Else
						_lLoja := .F.
						_cRede := SA1->A1_REDE

						RecLock("SC5",.F.)
						SC5->C5_XREDE := "S"
						SC5->C5_BLQ   := "1"                 // Quando o pedido for de cliente rede, entra j� bloqueado
						SC5->C5_CODRED  := _cRede          // Grava codigo da rede utilizado na rotina ANALISPED.
						SC5->C5_LIBEROK := " "
						SC5->(MsUnLock())

					EndIf

				EndIf

				If _lLoja
					// Busco desconto para Cliente. O desconto aqui informado � em PERCENTUAL - PAULO - TDS - 12/05/2011
					_nDesconto := SA1->A1_DESC

					// Busco frete para Cliente
					_cEst	:= SA1->A1_EST
					_cMunic := SA1->A1_COD_MUN
					_cRegiao := ""
					_cTabela := ""   //M->C5_TABELA

					// Se n�o contiver a tabela cadastrada no cliente, o c�digo da tabela ser� de acordo com o peso, inserido na tabela por faixa de pesos
					// Paulo - TDS - 18/05/2011
					//Mauricio 07/12/11 - Retirado tratamento para tabela vinda do pedido. Tabela sera assumida pela faixa de Qtd. caixas que o pedido se
					//encaixa (Usando tabela ZZP criada).
					//If Empty(M->C5_TABELA)

					dbSelectArea("ZZP")
					dbSetOrder(1)
					dbGoTop()

					While !Eof()
						If _nTotalCx >= ZZP->ZZP_PESOI .And. _nTotalCx <= ZZP->ZZP_PESOF
							//pega a tabela que se encaixa na faixa
							_cTabela := ZZP->ZZP_TABELA
							Exit
						EndIf
						dbSkip()
					EndDo

					//EndIf

					//Mauricio - 07/12/11 - tratamento para caso n�o haver tabela cadastrada ou faixa de peso
					//precisa ser analisado a posterior, para encontrar melhor alternativa de a��o a ser tomada.
					If Empty(_cTabela)
						//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL PE" )
						return()
					Else
						//atualizo campo tabela no SC5
						reclock("SC5",.F.)
						SC5->C5_TABELA := _cTabela
						Msunlock()      
					Endif

					dbSelectArea("DA0")
					dbSetOrder(1)

					If dbSeek(xFilial("DA0")+_cTabela)

						// Condi��o para achar percentual baseado em um unico usuario(ou vendedor ou supervisor ou gerente ou diretor)
						If     SA3->A3_NIVETAB == "2" // supervisor
							_nValMax := 1-(DA0->DA0_XSUPER/100)         // percentual supervisor
						ElseIf SA3->A3_NIVETAB == "3" // Gerente
							_nValMax := 1-(DA0->DA0_XGEREN/100)         // percentual gerente
						ElseIf SA3->A3_NIVETAB == "4"
							_nValMax := 1-(DA0->DA0_XDIRET/100)         // percentual diretor
						Else
							_nValMax := 1-(DA0->DA0_XVENDE/100)		 // percentual vendedor
						EndIf

						// Condi��o para achar um percentual para cada usuario sempre(vendedor,supervisor,gerente, diretor)
						// Destinado a geracao de al�ada separadamente.(Mauricio 11/05/11.)
						_nValMaxV := 1-(DA0->DA0_XVENDE/100)
						_nValMaxS := 1-(DA0->DA0_XSUPER/100)
						_nValMaxG := 1-(DA0->DA0_XGEREN/100)
						_nValMaxD := 1-(DA0->DA0_XDIRET/100)

					EndIf

					dbSelectArea("SC6")
					dbSetOrder(1)

					If dbSeek(xFilial("SC6")+_cNumPed)
						// A vari�vel _nDesconto, oriunda de A1_DESC � PERCENTUAL.
						// Ent�o, � necess�rio efetuar o calculo do desconto no pre�o de venda, para atualizar o pre�o liquido digitado
						// As instru��es abaixo efetuam este processo 

						While !Eof() .And. SC6->C6_NUM == _cNumped

							If _nMoeda == 1

								_nPrcDig := SC6->C6_PRCVEN * (_nDesconto / 100) // Pre�o digitado no produto, inclu�do o desconto
								_nPrDigL := SC6->C6_PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
								_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

								dbSelectArea("DA1")
								dbSetOrder(1)

								If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
									_nPrcTab := DA1->DA1_XPRLIQ									// Preco da tabela de precos
									_nPrPerm := _nPrcTab * _nValMax 	                        // Preco minimo permitido para o usuario

									// Preco minimo permitido para todas as al�adas.(tera de verificar todas as al�adas de uma unica vez conforme Alex - 11/05/11.)
									_nPrPermV := _nPrcTab * _nValMaxV
									_nPrPermS := _nPrcTab * _nValMaxS
									_nPrPermG := _nPrcTab * _nValMaxG
									_nPrPermD := _nPrcTab * _nValMaxD

									_nVlTotT  := SC6->C6_QTDVEN * _nPrPerm
									_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab  //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

									_nVlTotTV := SC6->C6_QTDVEN * _nPrPermV
									_nVlTotTS := SC6->C6_QTDVEN * _nPrPermS
									_nVlTotTG := SC6->C6_QTDVEN * _nPrPermG
									_nVlTotTD := SC6->C6_QTDVEN * _nPrPermD

									//_nIpProd := _nVlTotD/_nVlTotT
									_nIpProd := _nVlTotD/_nVlTotT2      //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

									//Mauricio 10/08/11 - implementando sistematica de altera�oes solicitadas em 10/08/11 - email Sr. Alex.												
									_nPBTTV  := SC6->C6_PRCVEN    //preco digitado
									_nPLTTV  := _nPrDigL          //preco liquido
									_nPLTVD  := _nPrPermV         //preco minimo vendedor
									_nPLTSV  := _nPrPermS  //preco minimo supervisor

									dbSelectArea("SC6")
									RecLock("SC6",.F.)
									SC6->C6_XIPTAB := Round(_nIpProd,3)
									SC6->C6_TOTDIG := _nVlTotD
									SC6->C6_TOTTAB := _nVlTotT2 //_nVlTotT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
									SC6->C6_PRTABV := _nPrPerm + _nFrete // Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
									SC6->C6_PBTTV  := _nPBTTV
									SC6->C6_PLTTV  := _nPLTTV
									SC6->C6_PLTVD  := _nPLTVD
									SC6->C6_PLTSP  := _nPLTSV
									SC6->C6_PLTAB  := _nPrcTab
									MsUnLock()

									_nPrDigT  += _nVlTotD	 // Soma dos pre�os l�quidos digitados
									_nPrPerT  += _nVlTotT    // Soma dos pre�os das tabelas
									_nPrTabT  += _nVlTotT2   //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
									_nPrPerTV += _nVltotTV   // Soma pre�o das tabelas para al�ada
									_nPrPerTS += _nVltotTS
									_nPrPerTG += _nVltotTG
									_nPrPerTD += _nVltotTD

									_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   //Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e n�o unitario conf. Sr. Alex
									_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   //Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e n�o unitario conf. Sr. Alex
									_nValorNf += SC6->C6_VALOR
								EndIf
							Else
								//Se n�o tiver data cadastrada ou o valor for zero assume o valor de 1(para n�o dar erro na rotina).
								_nCota := 0
								DbSelectArea("SM2")
								DbSetOrder(1)
								if DbSeek(Dtos(_dEmissao))
									//Alterado por Adriana em 30/01/2018 para tratar outras moedas					   
									// _nCota := M2_MOEDA2
									_nCota := &("M2_MOEDA"+STR(_nMoeda,1))
								Else
									_nCota := 1
								Endif

								If _nCota == 0
									_nCota := 1
								Endif   

								_nC6PRCVEN := SC6->C6_PRCVEN * _nCota  //transformo valor em dolar do pedido para real.

								_nPrcDig := _nC6PRCVEN * (_nDesconto / 100) // Pre�o digitado no produto, inclu�do o desconto
								_nPrDigL := _nC6PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
								_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

								dbSelectArea("DA1")
								dbSetOrder(1)

								If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
									_nPrcTab := DA1->DA1_XPRLIQ									// Preco da tabela de precos
									_nPrPerm := _nPrcTab * _nValMax 	                        // Preco minimo permitido para o usuario

									// Preco minimo permitido para todas as al�adas.(tera de verificar todas as al�adas de uma unica vez conforme Alex - 11/05/11.)
									_nPrPermV := _nPrcTab * _nValMaxV
									_nPrPermS := _nPrcTab * _nValMaxS
									_nPrPermG := _nPrcTab * _nValMaxG
									_nPrPermD := _nPrcTab * _nValMaxD

									_nVlTotT  := SC6->C6_QTDVEN * _nPrPerm
									_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab  //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

									_nVlTotTV := SC6->C6_QTDVEN * _nPrPermV
									_nVlTotTS := SC6->C6_QTDVEN * _nPrPermS
									_nVlTotTG := SC6->C6_QTDVEN * _nPrPermG
									_nVlTotTD := SC6->C6_QTDVEN * _nPrPermD

									//_nIpProd := _nVlTotD/_nVlTotT
									_nIpProd := _nVlTotD/_nVlTotT2      //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.

									//Mauricio 10/08/11 - implementando sistematica de altera�oes solicitadas em 10/08/11 - email Sr. Alex.												
									_nPBTTV  := _nC6PRCVEN    //SC6->C6_PRCVEN    //preco digitado convertido de dolar para real...
									_nPLTTV  := _nPrDigL          //preco liquido
									_nPLTVD  := _nPrPermV         //preco minimo vendedor
									_nPLTSV  := _nPrPermS  //preco minimo supervisor

									dbSelectArea("SC6")
									RecLock("SC6",.F.)
									SC6->C6_XIPTAB := Round(_nIpProd,3)
									SC6->C6_TOTDIG := _nVlTotD
									SC6->C6_TOTTAB := _nVlTotT2 //_nVlTotT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
									SC6->C6_PRTABV := _nPrPerm + _nFrete // Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
									SC6->C6_PBTTV  := _nPBTTV
									SC6->C6_PLTTV  := _nPLTTV
									SC6->C6_PLTVD  := _nPLTVD
									SC6->C6_PLTSP  := _nPLTSV
									SC6->C6_PLTAB  := _nPrcTab
									MsUnLock()

									_nPrDigT  += _nVlTotD	 // Soma dos pre�os l�quidos digitados
									_nPrPerT  += _nVlTotT    // Soma dos pre�os das tabelas
									_nPrTabT  += _nVlTotT2   //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
									_nPrPerTV += _nVltotTV   // Soma pre�o das tabelas para al�ada
									_nPrPerTS += _nVltotTS
									_nPrPerTG += _nVltotTG
									_nPrPerTD += _nVltotTD

									_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   //Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e n�o unitario conf. Sr. Alex
									_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   //Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e n�o unitario conf. Sr. Alex
									_nValorNf += (SC6->C6_VALOR * _nCota)
								EndIf
							Endif
							dbSelectArea("SC6")
							dbSkip()						
						EndDo

						//_nVlIP := _nPrDigT/_nPrPerT
						_nVlIP := _nPrDigT/_nPrTabT    //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
						_nVlIP := NoRound(_nVlIP,3)

						//If _nPrDigT < _nPrPerT
						if _nVlIP < 1

							RecLock("SC5",.F.)											
							SC5->C5_APROV1 := SPACE(06)
							SC5->C5_APROV2 := SPACE(06)
							SC5->C5_APROV3 := SPACE(06)
							_bloqueia := .F.

							If    SA3->A3_NIVETAB == "1"                  // Se for um vendedor
								// Verifio al�ada do vendedor 30/09/11 - Alex Borges
								If _nPrDigT < _nPrPerTV
									SC5->C5_APROV1 := _cSupervi
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER1 := ""
										SC5->C5_DTLIB1 := Stod("")
										SC5->C5_HRLIB1 := ""
									ENDIF
									_bloqueia := .T.
								End IF	

								IF _nPrDigT < _nPrPerTS                   // verifico al�ada supervisor 
									SC5->C5_APROV2 := _cGerente  
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER2 := ""
										SC5->C5_DTLIB2 := Stod("")
										SC5->C5_HRLIB2 := ""
									ENDIF
									_bloqueia := .T.
								EndIf

								If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente
									SC5->C5_APROV3 := _cDiretor
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER3 := ""
										SC5->C5_DTLIB3 := Stod("")
										SC5->C5_HRLIB3 := ""
									Endif
									_bloqueia := .T.
								EndIf

							ElseIf SA3->A3_NIVETAB == "2"				     // Se for um supervisor
								IF _nPrDigT < _nPrPerTS                   // verifico al�ada supervisor 
									SC5->C5_APROV2 := _cGerente
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER2 := ""
										SC5->C5_DTLIB2 := Stod("")
										SC5->C5_HRLIB2 := ""
									ENDIF
									_bloqueia := .T.
								EndIf

								If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente para o supervisor
									SC5->C5_APROV3 := _cDiretor
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER3 := ""
										SC5->C5_DTLIB3 := Stod("")
										SC5->C5_HRLIB3 := ""
									ENDIF
									_bloqueia := .T.
								EndIf

							ElseIf SA3->A3_NIVETAB == "3"					// Se for um gerente
								If _nPrDigT < _nPrPerTG                   // verifico al�ada gerente para o supervisor
									SC5->C5_APROV3 := _cDiretor
									IF SC5->C5_EST == "EX"
										SC5->C5_LIBER3 := ""
										SC5->C5_DTLIB3 := Stod("")
										SC5->C5_HRLIB3 := ""
									ENDIF
									_bloqueia := .T.
								EndIf
							EndIf
							SC5->(MsUnLock())

						EndIf

						If _bloqueia         // Adicionado Alex Borges - 30/09/11
							RecLock("SC5",.F.)
							SC5->C5_BLQ    := "1"
							SC5->C5_DTBLOQ := dDataBase
							SC5->C5_HRBLOQ := Time()	
						ELSEif SC5->C5_EST=='EX'
							fAtuExp(_cNumPed)
						EndIf

						//_nIpTot := _nPrDigT/_nPrPerT					

						RecLock("SC5",.F.)
						SC5->C5_FRETAPV := _nFrete   //Mauricio 16/11/11.
						SC5->C5_XIPTAB  := _nVlIP
						SC5->C5_TOTDIG  := _nPrDigT
						SC5->C5_TOTTAB  := _nPrTabT   //_nPrPerT //Alterado em 28/09/11 conforme informa��es Sr. Alex no que se refere ao valor do IPTAB.
						SC5->C5_DESCTBP := _nPreTabS - _nPreLiqS
						SC5->C5_VALORNF := _nValorNF
						SC5->(MsUnLock())
					EndIf
				Else    //Mauricio - 19/05/2017 - Incluido tratamento para rede para o frete - Chamado 035118
					// Busco frete para Cliente
					_cEst	:= SA1->A1_EST
					_cMunic := SA1->A1_COD_MUN

					//
					RecLock("SC5",.F.)
					SC5->C5_FRETAPV := _nFrete
					SC5->(MsUnLock())

				EndIf

				If AllTrim(SC5->C5_BLQ) == "1"
					RecLock("SC5",.F.)
					//Msgalert(SC5->C5_LIBEROK)
					SC5->C5_LIBEROK := " "
					//Msgalert(SC5->C5_LIBEROK)
					MsUnlock()

					dbSelectArea("SC9")   // Mauricio 25/03/11 Projeto tabela de pre�o: como � customizado verifico se gerou libera��o e havendo deleto todos os registros.
					dbSetOrder(1)

					If dbSeek(xFilial("SC9")+_cNumPed)
						While !Eof() .And. SC9->C9_PEDIDO == _cNumPed
							//MsgAlert("Deleta SC9 "+SC9->C9_PEDIDO)
							Reclock("SC9",.F.)
							dbDelete()
							MsUnlock()
							dbSkip()
						EndDo
					EndIf
					dbSelectArea("SC6")   
					dbSetOrder(1)	
					If dbSeek(xFilial("SC6")+_cNumPed)
						While !Eof() .And. SC6->C6_NUM == _cNumPed
							//MsgAlert("Deleta SC6 "+SC6->C6_NUM)
							Reclock("SC6",.F.)
							SC6->C6_QTDEMP  := 0.00
							SC6->C6_QTDEMP2 := 0.00
							MsUnlock()
							dbSkip()
						EndDo
					EndIf			
				EndIf
			EndIf
		Else

			If !lSfInt

				dbSelectArea("SC5")
				dbSetOrder(1)				
				If dbSeek(xFilial("SC5")+_cNumPed) 
					Reclock("SC5",.F.)
					SC5->C5_LIBEROK := " "
					MsUnlock()
				Endif
				dbSelectArea("SC9")   
				dbSetOrder(1)	
				If dbSeek(xFilial("SC9")+_cNumPed)
					While !Eof() .And. SC9->C9_PEDIDO == _cNumPed
						Reclock("SC9",.F.)
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
				EndIf
				dbSelectArea("SC6")   
				dbSetOrder(1)	
				If dbSeek(xFilial("SC6")+_cNumPed)
					While !Eof() .And. SC6->C6_NUM == _cNumPed
						Reclock("SC6",.F.)
						SC6->C6_QTDEMP  := 0.00
						SC6->C6_QTDEMP2 := 0.00
						MsUnlock()
						dbSkip()
					EndDo
				EndIf

			EndIf
		Endif
		// N�o elimina o SC9 caso seja um pedido de exporta��o acima do �ndice IPTAB.
		IF !(SC5->C5_EST='EX' .AND. Empty(SC5->C5_BLQ))
			If !lSfInt .And. _lDoa .or. !(__cuserid$_cUsuBon)   //Mauricio 25/09/13 Se foi pedido de doa��o preciso verificar se gerou SC9 e deletaer registros para n�o liberar para faturamento
				DbSelectArea("SC5")
				RecLock("SC5",.F.)
				SC5->C5_LIBEROK := " "
				MsUnlock()

				dbSelectArea("SC9")   
				dbSetOrder(1)			
				If dbSeek(xFilial("SC9")+_cNumPed)
					While !Eof() .And. SC9->C9_PEDIDO == _cNumPed		
						Reclock("SC9",.F.)
						dbDelete()
						MsUnlock()
						SC9->(dbSkip())
					EndDo
				EndIf
				dbSelectArea("SC6")   
				dbSetOrder(1)	
				If dbSeek(xFilial("SC6")+_cNumPed)
					While !Eof() .And. SC6->C6_NUM == _cNumPed
						Reclock("SC6",.F.)				
						SC6->C6_QTDEMP  := 0.00
						SC6->C6_QTDEMP2 := 0.00
						MsUnlock()
						SC6->(dbSkip())
					EndDo
				EndIf				
			Endif
		endif

	EndIf


	//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> INICIO BSCSLD" )
	//Mauricio 16/11/11 - Tratamento para for�ar bloqueio por limite de credito(Padrao Protheus estava falhando)
	_nLimCred := 0
	_nLimCred := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_LC")
	_lBloq := .F. 
	_nSldAb := fBscSld(_cCliente,_cLoja)   //busca saldo em aberto para o cliente

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+_cNumPed))
		While SC6->(!Eof()) .And. SC6->C6_NUM == _cNumPed
			
			//@history Ticket  TI  	- Leonardo P. Monteiro  - 02/02/2022 - Transfer�ncia do P.E. MTA410I para o fonte atual M410STTS. Transferimos a grava��o da data de entrega nos itens do PV.
			if Reclock("SC6",.F.)
				SC6->C6_ENTREG := SC5->C5_DTENTR
				SC6->(MsUnlock())
			ENDIF

			if SC6->C6_QTDENT < SC6->C6_QTDVEN  //qtd total pendente
				_nVlrItem := ((SC6->C6_QTDVEN - SC6->C6_QTDENT) * SC6->C6_PRCVEN)   //valor pendente no pedido (inclusive parcial)
			endif

			//fernando chamado 036388 - fernando 20/07/2017 
			If Alltrim(SC6->C6_CF) $ Alltrim(cMVCfop) .and. lCfop == .F. 
				lCfop := .T.
			EndIf 

			// Alex Borges - 28/11/11 - If para tratar a TES
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			if SF4->(dbseek(xFilial("SF4")+SC6->C6_TES))
				
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				if SC9->(dbseek(xFilial("SC9")+_cNumPed+SC6->C6_ITEM))
					cBlCred := SC9->C9_BLCRED

					// If (ALLTRIM(SF4->F4_DUPLIC) = 'S') // Alex Borges 01/12/11
					If ((ALLTRIM(SF4->F4_DUPLIC) = 'S') .and. (ALLTRIM(_Tipo) $ "N/C") .and. (ALLTRIM(_estado)<> "EX"))
						if (_nVlrItem + _nSldAb) > _nLimCred   //limite excedido deve bloquear
							
								If empty(SC9->C9_BLCRED)    //somente se ja n�o houver bloqueio
									If !(SC9->C9_FILIAL == "05" .AND. Alltrim(SC9->C9_CLIENTE) $ '031017/030545')
											cBlCred 	:= "01"  //bloqueio por limite de valor
									Endif
								Else
									If (SC9->C9_FILIAL == "05" .AND. Alltrim(SC9->C9_CLIENTE) $ '031017/030545')
											cBlCred := ""  //bloqueio por limite de valor
									Endif		                  		
								Endif
						Endif
					
					// N�o ajuste as libera��es de cr�dito para pedidos de exporta��o.
					ElseIF ALLTRIM(_estado)<> "EX"
						cBlCred := ""  // libera cr�dito
					End If

					if Reclock("SC9",.F.)
						SC9->C9_BLCRED 	:= cBlCred
						SC9->C9_ROTEIRO := SC6->C6_ROTEIRO
						SC9->C9_DTENTR  := SC6->C6_ENTREG
						SC9->C9_VEND1   := SC5->C5_VEND1
						SC9->(MsUnlock())
					endif
				ENDIF
			EndIf

			_nLimCred -= _nVlrItem  //deduzo o valor do item ja validado do limite utilizado.
			SC6->(dbSkip())
		Enddo
	Endif            

	//Incio - fernando chamado 036388 - fernando 20/07/2017 
	If lCfop
		If SC5->(dbseek(xFilial("SC5")+Alltrim(_cNumPed)))
			IF SC5->C5_XTIPO <> '2'
				// LPM - Reformula��o na regrava��o/Altera��o dos roteiros.
				// Fun��o respons�vel pela atualiza��o dos roteiros na SC5, SC6 e SC9.
				fAtuRot("189")
			endif
		endif
	EndIf

	//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL BSCSLD" )
	//Fim - fernando chamado 036388 - fernando 20/07/2017

	// Chamado 008402 - Mauricio - Corre��o de problema com programa AD0078.
	// Limpa a variavel criada no ponto MT410CPY.

	If Type("VAR_IXB") <> "A"
		VAR_IXB := {"","",""}   //Limpa variavel publica    
	else
		VAR_IXB[1] := ""
		VAR_IXB[2] := ""
	Endif

	dbSelectArea(_SC6cAliasSC6)
	dbSetOrder(_SC6cOrderSC6)
	dbGoto(_SC6cRecnoSC6)

	dbSelectArea(_SC5cAliasSC5)
	dbSetOrder(_SC5cOrderSC5)
	dbGoto(_SC5cRecnoSC5)

	dbSelectArea(_cAlias)
	dbSetOrder(_cOrder)
	dbGoto(_cRecno)

	// *********** INICIO CHAMADO 025859 - POR WILLIAM COSTA **************** //
	DBSELECTAREA("SC6")

	IF !lSfInt .And. DBSEEK(xFilial("SC6")+_cNumPed, .T. )

		WHILE SC6->(!EOF()) .And. SC6->C6_NUM == _cNumPed

			IF ALLTRIM(__cUserId) $ GETMV("MV_#USUPET") .AND. ; 
			ALLTRIM(SC5->C5_NOTA) == ""              .AND. ;
			(ALLTRIM(SC6->C6_TES) == '739'            .OR. ;
			ALLTRIM(SC6->C6_TES)  == '744'            .OR. ;
			ALLTRIM(SC6->C6_TES)  == '747')

				M->C5_REFATUR := 'S'         

				DBSELECTAREA("SC5")

				IF DBSEEK(xFilial("SC5")+_cNumPed, .T. )

					RecLock("SC5",.F.)
					SC5->C5_REFATUR := 'S'
					SC5->( MsUnLock() ) 

				ENDIF

				SC5->(dbCloseArea()) 

				memowrite("\LOGREFAT\"+_cNumPed+STRTRAN(Dtoc(date()),"/","")+SUBSTR(STRTRAN(time(),":",""),1,4)+".LOG",alltrim(__cUserId)+" - "+_cNumPed)
				femailRefatur(_cNumPed,cFilAnt,M->C5_EMISSAO,_nTotalPedi,"1") //Incluir aqui fun��o para envio de email ao Caio			   
			ENDIF

			SC6->(dbSkip()) 

		ENDDO
	ENDIF
	SC6->(dbCloseArea())

	// *********** FINAL CHAMADO 025859 - POR WILLIAM COSTA **************** //

	//Everson - 08/03/2018. Chamado 037261. SalesForce.
	//Envio de pedido gerado no Protheus para o SalesForce.
	//If FindFunction("U_ADVEN050P")
	//envSF(_lBon,_lDoa)

	//EndIf

	// @history ticket 102 - FWNM - 31/08/2020 - WS BRADESCO - contemplar altera��es de pedidos de vendas com emiss�es anteriores ao do dia atual e de condi��es de pagamento normais para antecipado, cen�rio este n�o contemplado pelo job
	// @history chamado TI     - FWNM - 14/08/2020 - Desativa��o devido impactos de block no SF
	// chamado 059415 - FWNM - 29/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	If INCLUI .or. ALTERA .or. IsInCallStack("A410Inclui") // Copia tb usa vari�vel INCLUI

		If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM

			//u_GeraSC9() // @history chamado TI     - FWNM - 14/08/2020 - Desativa��o devido impactos de block no SF

			If lWSBradOn // @history chamado 059415 - FWNM - 13/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
				IF SuperGetMV("MV_#THRRAP",,.F.)
					
					StartJob("U_THRGEPV",getenvserver(),.F., cEmpAnt, SC5->C5_FILIAL, SC5->C5_NUM)
				else
					// @history ticket 102 - FWNM - 31/08/2020 - WS BRADESCO - contemplar altera��es de pedidos de vendas com emiss�es anteriores ao do dia atual e de condi��es de pagamento normais para antecipado, cen�rio este n�o contemplado pelo job
					//Conout( DToC(Date()) + " " + Time() + " M410STTS - u_GeraRAPV - INICIO" )
					msAguarde( { || u_GeraRAPV() }, "Gerando boleto de adiantamento PV " + _cNumPed )
					//Conout( DToC(Date()) + " " + Time() + " M410STTS - u_GeraRAPV - FINAL" )
				ENDIF

			EndIf

			//U_ADFIN021P(SC5->C5_FILIAL+SC5->C5_NUM) // Gera ZBH // @history chamado TI     - FWNM - 14/08/2020 - Desativa��o devido impactos de block no SF
			
		EndIf

		//Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.
		//Executa Pre libera��o Financeira do Pedido
		//fPreLibF()
		
		//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - INICIO 1" )
        If !u_fInterCo("C", SC5->C5_CLIENTE, SC5->C5_LOJACLI) // @history Ticket   11277 - F.Maciei - 13/04/2021 - DEMORA AO IMPORTAR PEDIDO DE RA��O

			If GetMV("MV_#LIBCRE",,.T.) // @history Ticket  TI     - F.Maciei - 02/09/2021 - Par�metro liga/desliga nova fun��o an�lise cr�dito
				
				IF SuperGetMV("MV_#THRCRE",,.T.)
					StartJob("U_AVLCRED",getenvserver(),.F., cEmpAnt, SC5->C5_FILIAL, SC5->C5_NUM)
				else
					//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVrLbAnt - INICIO 1" )
					aVrLbAnt := fVrLbAnt(SC5->C5_FILIAL, SC5->C5_NUM)
					//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVrLbAnt - FINAL 1" )
					IF aVrLbAnt[1] == .F. .or. (aVrLbAnt[1] == .T. .AND. aVrLbAnt[2] < SC5->C5_XTOTPED)
						//INICIO Ticket  8      - Abel B.  - 22/02/2021 - Nova rotina de Pr�-libera��o de cr�dito levando-se em considera��o a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
						//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - INICIO 2" )
						fLibCred(SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR)
						//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - FINAL 2" )
					ENDIF
				endif

			EndIf
        Else

            // @history Ticket   11277 - F.Maciei - 13/04/2021 - DEMORA AO IMPORTAR PEDIDO DE RA��O
        	IF RecLock("SC5",.F.)
                SC5->C5_XPREAPR := 'L'
			    SC5->( MsUnLock() ) 
		    ENDIF

        EndIf
		//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - FINAL 1" )

	EndIf
	//

	//Everson - 04/05/2021. Chamado 
	If (INCLUI .Or. ALTERA) .And. !lSfInt
		libPedSAG()
	EndIf
	//

	if _nOper == 5
		fFunDel()
	endif

	//Everson - 18/03/2022. Chamado 18465. //Everson - 24/03/2022. Chamado 18465.
	If ! Empty(Alltrim(cValToChar(SC5->C5_XORDPES))) .Or. chkOrdSC6(_nOper, SC5->C5_NUM)
		grvBarr(_nOper, SC5->C5_NUM)

	EndIf
	//

	//Everson - 10/02/2020. Chamado 054941.
	RestArea(aArea)
	
	//Conout( DToC(Date()) + " " + Time() + " M410STTS >>> FINAL PE" )

Return 

User Function THRGEPV(cEmpP,cFilP,cPedido)
	/* Declara��o de Vari�veis */
	Local nCurrent := 0

	//Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv(cEmpP,cFilP,,,,GetEnvServer(),{ })

		nCurrent	:= ThreadId()

		ConOut("Processo Iniciado - THRGEPV - Thread: "+AllTrim(cValToChar(nCurrent)))

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))

		if SC5->(DbSeek(cFilP+cPedido))
			ConOut("Pedido encontrado "+cPedido+" - THRGEPV - Thread: "+AllTrim(cValToChar(nCurrent)))
			u_GeraRAPV()
		else
			/* Encerro o processo */
			ConOut("Pedido n�o encontrado - THRGEPV - Thread: "+AllTrim(cValToChar(nCurrent)))		
		endif
    
		/* Encerro o processo */
		ConOut("Processo Encerrado - THRGEPV: "+AllTrim(cValToChar(nCurrent)))
	//
    RpcClearEnv()

	
return Nil


User Function AVLCRED(cEmpP,cFilP,cPedido)
    
	/* Declara��o de Vari�veis */
	Local aVrLbAnt	:= {}
	Local nCurrent := 0
	
	//Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv(cEmpP,cFilP,,,,GetEnvServer(),{ })

		nCurrent	:= ThreadId()
		
		ConOut("Processo Iniciado - AVLCRED - Thread: "+AllTrim(cValToChar(nCurrent)))

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))

		if SC5->(DbSeek(cFilP+cPedido))
			ConOut("Pedido encontrado "+cPedido+" - AVLCRED - Thread: "+AllTrim(cValToChar(nCurrent)))
			//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVrLbAnt - INICIO 1" )
			aVrLbAnt := fVrLbAnt(SC5->C5_FILIAL, SC5->C5_NUM)
			//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVrLbAnt - FINAL 1" )
			IF aVrLbAnt[1] == .F. .or. (aVrLbAnt[1] == .T. .AND. aVrLbAnt[2] < SC5->C5_XTOTPED)
				//INICIO Ticket  8      - Abel B.  - 22/02/2021 - Nova rotina de Pr�-libera��o de cr�dito levando-se em considera��o a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
				//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - INICIO 2" )
				fLibCred(SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR)
				//Conout( DToC(Date()) + " " + Time() + " M410STTS - fLibCred - FINAL 2" )
			ENDIF
		else
			/* Encerro o processo */
			ConOut("Pedido n�o encontrado - AVLCRED - Thread: "+AllTrim(cValToChar(nCurrent)))		
		endif
    
		/* Encerro o processo */
		ConOut("Processo Encerrado - AVLCRED - Thread: "+AllTrim(cValToChar(nCurrent)))
	
	//
    RpcClearEnv()

	

Return Nil

/*/{Protheus.doc} fAtuExp
	Recria o registro de libera��o na SC9.
	@type  Static Function
	@author Leonardo P. Monteiro
	@since 23/03/2021
	@version 01
	/*/
Static function fAtuExp(_cNumPed)
	Local lLiber   	:= .F.
	Local lTrans   	:= .F.
	Local lCredito 	:= .F.
	Local lEstoque 	:= .F.
	Local lAvCred  	:= .T.
	Local lAvEst   	:= .F.
	Local _cDtEn	:= ""
	Local _cVend	:= ""
	Local _cRote	:= ""

	cMensagem := "FATUEXP - Refazendo os arquivos de libera��o SC9 para pedidos de exporta��o "+_cNumPed+"."
	logZBE(cMensagem)
	RecLock("SC5",.F.)
		SC5->C5_APROV1	:= ""
		SC5->C5_LIBER1 	:= ""
		SC5->C5_DTLIB1 	:= Stod("")
		SC5->C5_HRLIB1 	:= ""

		SC5->C5_APROV2	:= ""
		SC5->C5_LIBER2 	:= ""
		SC5->C5_DTLIB2 	:= Stod("")
		SC5->C5_HRLIB2 	:= ""

		SC5->C5_APROV3	:= ""
		SC5->C5_LIBER3 	:= ""
		SC5->C5_DTLIB3 	:= Stod("")
		SC5->C5_HRLIB3 	:= ""

		SC5->C5_DTBLOQ	:= Stod("")
		SC5->C5_HRBLOQ	:= ""
		SC5->C5_LIBEROK := ""
	SC5->(Msunlock())
	
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	
	If  SC6->(dbSeek(xFilial("SC6")+_cNumPed))
		_cDtEn := SC5->C5_DTENTR
		_cVend := SC5->C5_VEND1
		_cRote := SC6->C6_ROTEIRO
		
		While sc6->(!Eof()) .And. _cNumPed == SC6->C6_NUM
			if SC6->C6_QTDLIB == 0
				
				_nQtdLiber := SC6->C6_QTDVEN
				
				RecLock("SC6")
				// Efetua a libera��o item a item de cada pedido
				Begin transaction
					MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
				End transaction
				SC6->(MsUnLock())

				Begin Transaction
					SC6->(MaLiberOk({_cNumPed},.F.))
				End Transaction
			ENDIF
			SC6->(dbSkip())
		EndDo
		
		DbSelectArea("SC9")
		SC9->(dbSetOrder(1))
		if SC9->(dbseek(xFilial("SC9")+_cNumPed))
			While !Eof() .And. _cNumPed == SC9->C9_PEDIDO
				RecLock("SC9",.F.)
				SC9->C9_DTENTR 	:= _cDtEn
				SC9->C9_VEND1  	:= _cVend
				SC9->C9_ROTEIRO := _cRote
				SC9->(MsUnlock())
				SC9->(dbSkip())
			EndDo
		Endif
	EndIf

return

/*/{Protheus.doc} femailRefatur
	Monta e-mail.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
static function femailRefatur(_cP,_cFl,_cDt,_nVl,_cTp)   
	//Local _cP
	//Local _cDt
	// Local _cN
	//Local _nVl
	Private cHtml := ""
	Private _cMov := ""
	Private _cFilD := ""

	If _cTp =="1"
		_cMov := "Inclus�o"
	Elseif _cTp == "2"
		_cMov := "Altera��o"
	Endif

	If _cFl == "01"
		_cFilD := "Matriz"
	Elseif _cFl == "02"
		_cFilD := "Varzea"
	ElseIf _cFl == "03"
		_cFilD := "S�o Carlos"
	Elseif _cFl == "04"
		_cFilD := "Rio Claro"
	Elseif _cFl == "06"
		_cFilD := "Itupeva"
	Endif       


	//+-----------------------------------------------------------------------------+//
	//| Hmtl - Inicio
	//+-----------------------------------------------------------------------------+//
	cHtml := '<html>										' + CRLF +;
	'<head>										' + CRLF +;
	'<title>tables</title>						' + CRLF +;
	'  <style type="text/css">					' + CRLF +;
	'    #tabela { 						        ' + CRLF +;
	'      table-layout:fixed;                  ' + CRLF +;
	'      border: #4f93e3 1px solid;           ' + CRLF +;  
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'      width:100%;                          ' + CRLF +;    
	'      font-size: 10pt;						' + CRLF +;    
	'      font-family: tahoma, verdana, '+"microsoft sans serif"+';' + CRLF +;    
	'    }										' + CRLF +;
	'    #tabela tbody tr.odd  td {			    ' + CRLF +;
	'      background-color: #edf5ff;   		' + CRLF +;
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'    }										' + CRLF +;
	'    #tabela tbody th {						' + CRLF +;
	'      background-color: #ffbf6a;   		' + CRLF +;
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'      font-size: 10pt;						' + CRLF +;    
	'      font-family: tahoma, verdana, '+"microsoft sans serif"+';' + CRLF +; 
	'      font-style: bold;                    ' + CRLF +;    
	'    }										' + CRLF +;
	'  </style>									' + CRLF +;
	'</head>									' + CRLF +;
	'<body>										' + CRLF +;       
	'<h5 align="right">[ Mensagem autom�tica Sistema ]</h5>' + CRLF +;       
	'<table id="tabela">						' + CRLF +; 
	'  <tbody>									' 

	//+-----------------------------------------------------------------------------+// 
	//| PRINCIPAL
	//+-----------------------------------------------------------------------------+//
	cHtml+= '    <tr class="title">						' + CRLF +;
	'      <th colspan = 2>						' + CRLF +;
	'	      Principal		                    ' + CRLF +;
	'      </th>                         		' + CRLF +;
	'    </tr>									' 

	//PRECISO ARRUMAR AQUI>>TA DANDO ERRO		
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;
	'	  	<td width=10% >' + 'Pedido: ' + '</td>' + CRLF +;
	'      <td>' 			 + _Cp  + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	         
	'	  	<td width=10% >' + 'Filial: ' + '</td>' + CRLF +;
	'      <td>' 			 + _cFILD + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	           
	'	  	<td width=10% >' + 'Data: ' + '</td>' + CRLF +;
	'      <td>' 			 + DTOC(_cDt) + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	           
	'	  	<td width=10% >' + 'Valor: ' + '</td>' + CRLF +;
	'      <td>' 			 + Transform(_nVl,"@E 999,999,999.99") + '</td>' + CRLF +;
	'    </tr>'		

	//+-----------------------------------------------------------------------------+//
	//| Hmtl - Fim
	//+-----------------------------------------------------------------------------+//
	cHtml+= '  </tbody>									' + CRLF +;
	'</table>									' + CRLF +;
	'</body>									' + CRLF +;
	'</html>	                                '                             

	_cAssunto := " Pedido Venda Pet-food: Ped."+Alltrim(_cP)+" Filial: "+_cFILD
	_cCorpo   := " Realizado a Libera��o Automatica de Refaturamento Manual para Pedidos Pet-Food N� Ped."+Alltrim(_cP)+" Filial: "+_cFILD   
	_cEnv     := 'rosangela@adoro.com.br'

	MandaEmail( _cAssunto,_cEnv,_cCorpo)

return()
/*/{Protheus.doc} fBscSld
	Retorna saldo em aberto para o Cliente.
	@type  Static Function
	@author Mauricio 
	@since 16/11/2011
	@version 01
	/*/
static function fBscSld(_cCl,_cL)
	//Local _cCl
	//Local _cL
	Local _nSld := 0

	If Select("TSE1") > 0
		DbSelectArea("TSE1")
		TSE1->(DbCloseArea())
	Endif

	// RICARDO LIMA - 25/01/18 - AJUSTE DE WHILE
	//_cQuery := ""
	//_cQuery += "SELECT E1_SALDO FROM "+RetSqlName("SE1")+" SE1 "
	//_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' AND SE1.D_E_L_E_T_ = '' AND SE1.E1_SALDO > 0"

	_cQuery := " SELECT SUM(E1_SALDO)  E1_SALDO "
	_cQuery += " FROM "+RetSqlName("SE1")+" (NOLOCK) SE1 " 
	_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' " 
	_cQuery += " AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' "  

	_cQuery := ChangeQuery(_cQuery)

	TCQUERY _cQuery NEW ALIAS "TSE1"

	dbSelectArea("TSE1")
	IF TSE1->(!Eof())
		_nSld += TSE1->E1_SALDO
	EndIF 

	TSE1->(dbcloseArea())

return(_nSld)
/*/{Protheus.doc} femailF
	Monta e-mail.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
static function femailF(_cP,_cFl,_cDt,_nVl,_cTp)   
	//Local _cP
	//Local _cDt
	// Local _cN
	//Local _nVl
	Private cHtml := ""
	Private _cMov := ""
	Private _cFilD := ""

	If _cTp =="1"
		_cMov := "Inclus�o"
	Elseif _cTp == "2"
		_cMov := "Altera��o"
	Endif

	If _cFl == "01"
		_cFilD := "Matriz"
	Elseif _cFl == "02"
		_cFilD := "Varzea"
	ElseIf _cFl == "03"
		_cFilD := "S�o Carlos"
	Elseif _cFl == "04"
		_cFilD := "Rio Claro"
	Elseif _cFl == "06"
		_cFilD := "Itupeva"
	Endif       


	//+-----------------------------------------------------------------------------+//
	//| Hmtl - Inicio
	//+-----------------------------------------------------------------------------+//
	cHtml := '<html>										' + CRLF +;
	'<head>										' + CRLF +;
	'<title>tables</title>						' + CRLF +;
	'  <style type="text/css">					' + CRLF +;
	'    #tabela { 						        ' + CRLF +;
	'      table-layout:fixed;                  ' + CRLF +;
	'      border: #4f93e3 1px solid;           ' + CRLF +;  
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'      width:100%;                          ' + CRLF +;    
	'      font-size: 10pt;						' + CRLF +;    
	'      font-family: tahoma, verdana, '+"microsoft sans serif"+';' + CRLF +;    
	'    }										' + CRLF +;
	'    #tabela tbody tr.odd  td {			    ' + CRLF +;
	'      background-color: #edf5ff;   		' + CRLF +;
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'    }										' + CRLF +;
	'    #tabela tbody th {						' + CRLF +;
	'      background-color: #ffbf6a;   		' + CRLF +;
	'      cellpadding:0px;                     ' + CRLF +;  
	'      cellspacing:0px;                     ' + CRLF +;
	'      font-size: 10pt;						' + CRLF +;    
	'      font-family: tahoma, verdana, '+"microsoft sans serif"+';' + CRLF +; 
	'      font-style: bold;                    ' + CRLF +;    
	'    }										' + CRLF +;
	'  </style>									' + CRLF +;
	'</head>									' + CRLF +;
	'<body>										' + CRLF +;       
	'<h5 align="right">[ Mensagem autom�tica Sistema ]</h5>' + CRLF +;       
	'<table id="tabela">						' + CRLF +; 
	'  <tbody>									' 

	//+-----------------------------------------------------------------------------+// 
	//| PRINCIPAL
	//+-----------------------------------------------------------------------------+//
	cHtml+= '    <tr class="title">						' + CRLF +;
	'      <th colspan = 2>						' + CRLF +;
	'	      Principal		                    ' + CRLF +;
	'      </th>                         		' + CRLF +;
	'    </tr>									' 

	//PRECISO ARRUMAR AQUI>>TA DANDO ERRO		
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;
	'	  	<td width=10% >' + 'Pedido: ' + '</td>' + CRLF +;
	'      <td>' 			 + _Cp  + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	         
	'	  	<td width=10% >' + 'Filial: ' + '</td>' + CRLF +;
	'      <td>' 			 + _cFILD + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	           
	'	  	<td width=10% >' + 'Data: ' + '</td>' + CRLF +;
	'      <td>' 			 + DTOC(_cDt) + '</td>' + CRLF +;
	'    </tr>'
	cHtml += '    <tr' + ' class="odd"'+ '>' + CRLF +;	           
	'	  	<td width=10% >' + 'Valor: ' + '</td>' + CRLF +;
	'      <td>' 			 + Transform(_nVl,"@E 999,999,999.99") + '</td>' + CRLF +;
	'    </tr>'		

	//+-----------------------------------------------------------------------------+//
	//| Hmtl - Fim
	//+-----------------------------------------------------------------------------+//
	cHtml+= '  </tbody>									' + CRLF +;
	'</table>									' + CRLF +;
	'</body>									' + CRLF +;
	'</html>	                                '                             

	_cAssunto := _cMov+" pedido Doa��o aguardando sua Aprova��o: Ped."+Alltrim(_cP)+" Filial: "+_cFILD
	_cCorpo   := _cMov+" de pedido de Doa��o, o qual aguarda sua aprova��o: Ped."+Alltrim(_cP)+" Filial: "+_cFILD   
	_cEnv     := IIF(lAprov2 == .F.,alltrim(UsrRetMail(_cAprDoa)),alltrim(UsrRetMail(_cAprDoa2))) // Alterado William 07/05/2018 chamado 041490 || FISCAL || ROSANGELA || WORKFLOW //"000559"  Alterado por Adriana para alterar o aprovador    

	MandaEmail( _cAssunto,_cEnv,_cCorpo)

return()
/*/{Protheus.doc} MandaEmail
	Processa envio de e-mail.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function MandaEmail( _cAssunto,_cEnv,_cCorpo)
	Local lOk           := .T.
	Local cBody			:= _cCorpo
	// Local cErrorMsg		:=	""
	// Local aFiles 		:= {}
	Local cServer     	:=	Alltrim(GetMv("MV_RELSERV"))
	Local cAccount    	:=	AllTrim(GetMv("MV_RELACNT"))
	Local cPassword   	:=	AllTrim(GetMv("MV_RELPSW"))
	Local cFrom       	:=	AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local _cTo			:= _cEnv     
	Local cCC         	:=	""
	Local lSmtpAuth  	:= GetMv("MV_RELAUTH",,.F.)
	Local lAutOk     	:= .F.
	Local cAtach        := ""
	Local cSubject      := _cAssunto

	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk

		If !Empty(cCC)
			Send Mail From cFrom To _cTo CC cCC Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		Else
			Send Mail From cFrom To _cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		EndIf

	EndIf

	If lOk
		Disconnect Smtp Server
	Endif

return()

/*/{Protheus.doc} fPreAprv
	Fun��o para pr�-aprovacao.
	@type  Static Function
	@author 21/10/2016
	@since 
	@version 01
	/*/
/*
Static function fPreAprv(_cFilial,cPedido,_cCliente,_cLoja) 
	
	DbSelectArea("SC5")
	_cASC5 := Alias()
	_cOSC5 := IndexOrd()
	_cRSC5 := Recno()

	//Everson - 08/05/2018. J� libera o pedido posicionado.
	RecLock("SC5",.F.)
		SC5->C5_XPREAPR := " "
	SC5->(MsUnlock())

	//Verifico se eh rede ou varejo...
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+_cCliente+_cLoja)
		dbSelectArea("SZF")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))  //REDE
			//Limpo flag de pedidos relativos a Rede....aonde no caso n�o ha como filtrar data de entrega, cliente e pedidos utilizados...limpo todos.

			If Select("LSC5") > 0
				DbSelectArea("LSC5")
				LSC5->(DbCloseArea())
			Endif

			// Inicio Solicitacao Eduardo SantaMaria refeito esse select acima - William Costa 15/01/2018 //

			_cQuery := " SELECT C5.C5_FILIAL, C5.C5_NUM "
			_cQuery += " FROM "+RetSqlName("SC5")+" C5 WITH(NOLOCK), "+RetSqlName("SZF")+" ZF WITH(NOLOCK), "+RetSqlName("SA1")+" A1 WITH(NOLOCK) "
			_cQuery += " WHERE  C5_FILIAL       = '"+xFilial("SC5")+"' "
			_cQuery += " AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' "
			_cQuery += " AND C5.C5_CLIENTE = A1.A1_COD "
			_cQuery += " AND C5.C5_LOJACLI = A1.A1_LOJA "
			_cQuery += " AND LEFT(A1_CGC,8) = ZF_CGCMAT "
			_cQuery += " AND C5_NOTA = ''  "
			_cQuery += " AND C5_CLIENTE NOT IN ('031017','030545') "  
			_cQuery += " AND LEFT(A1_CGC,8) <> '60037058' " // Sigoli Chamado 031909 Adicionado os clientes adoro, para nao entrar nessa regra 10/01/2016
			_cQuery += " AND C5_XPREAPR <> '' " //Everson - 08/05/2018. Pega os pedidos apenas que est�o com o flag.
			_cQuery += " AND C5.D_E_L_E_T_='' "
			_cQuery += " AND ZF.D_E_L_E_T_='' "
			_cQuery += " AND A1.D_E_L_E_T_='' "

			// Final Solicitacao Eduardo SantaMaria refeito esse select acima - William Costa 15/01/2018 //
			TCQUERY _cQuery new alias "LSC5"	

			DbSelectArea ("LSC5")
			LSC5->(dbgotop())
			Do While LSC5->(!EOF())
				DbSelectArea("SC5")
				DbSetOrder(1)
				If dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM)
				
					If Alltrim(cValToChar(SC5->C5_XPREAPR)) <> ""

						if Reclock("SC5",.F.)
							SC5->C5_XPREAPR := " "
							SC5->(Msunlock())
						endif

					EndIf

				Endif	         
				LSC5->(DbSkip())
			Enddo

			LSC5->(DbcloseArea())

		Else  //eh varejo

			If Alltrim(cValToChar(SC5->C5_XPREAPR)) <> ""

				if Reclock("SC5",.F.)
					SC5->C5_XPREAPR := " "
					SC5->(Msunlock())
				endif  

			EndIf
			
		Endif
	Endif

	dbSelectArea(_cASC5)
	dbSetOrder(_cOSC5)
	dbGoto(_cRSC5)
Return()
*/

/*/{Protheus.doc} �envSF
	Envio de pedido para o SalesForce. Chamado 037261.
	@type  Static Function
	@author Everson
	@since 08/03/2018
	@version 01
	/*/
/*
Static Function envSF(_lBon,_lDoa,cExpSql)

	//���������������������������������������������������������������������������Ŀ
	//�Declara��o de vari�veis.                                                   �
	//�����������������������������������������������������������������������������	
	Local aArea		:= GetArea()
	Default _lBon	:= .F.
	Default _lDoa	:= .F.
	Default cExpSql	:= ""

	//Somente para empresa 01 e filial 02.
	If lSfInt .Or. Alltrim(cEmpAnt) <> "01" .Or.;
	Alltrim(cFilAnt) <> "02"
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If Empty(cExpSql)
		U_ADVEN050P( Alltrim(cValToChar(SC5->C5_NUM)) ,.F.,.F.,"",.F.,.F.,.F.,_lBon,_lDoa)

	Else
		U_ADVEN050P(,,,cExpSql)

	EndIf

	//
	RestArea(aArea)

Return Nil
*/

/*/{Protheus.doc} VerifAprovDoacao
	Verifica aprova��o de doa��o.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
STATIC FUNCTION VerifAprovDoacao()

	Local lRet := .F.

	SqlITEMPED(M->C5_NUM)

	While TRC->(!EOF())

		IF ALLTRIM(TRC->C6_PRODUTO) $ GETMV("MV_#PRDDOA") //PRODUTOS DO SEGUNDO APROVADOR 1-)LODO 297878 2-)FRANGO MORTO 223643 3-)PENA 302213 

			lRet := .T. //TROCAR APROVADOR DE DOACAO PARA O SEGUNDO APROVADOR

		ENDIF

		TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())


RETURN(lRet)
/*/{Protheus.doc} SqlITEMPED
	Retorna produto do item do pedido.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function SqlITEMPED(cNum)

	Local cFil := FWFILIAL('SC6')

	BeginSQL Alias "TRC"
		%NoPARSER%
		SELECT C6_PRODUTO 
		FROM %Table:SC6%
		WHERE C6_FILIAL   = %EXP:cFil%
		AND C6_NUM      = %EXP:cNum%
		AND D_E_L_E_T_ <> '*'

	EndSQl             
RETURN(NIL)   	
/*/{Protheus.doc} DelZC1PV
	Deleta conteudo do campo ZV1_FLAGPV .
	@type  Static Function
	@author Fernando Macieira
	@since 04/18/2018
	@version 01
/*/
Static Function DelZC1PV(_cNumPed)

	Local cSql    := ""

	cSql := " UPDATE " + RetSqlName("ZV1") + " SET ZV1_FLAGPV = '' "
	cSql += " WHERE ZV1_FILIAL='" + xFilial("ZV1") + "' "
	cSql += " AND ZV1_FLAGPV='"+_cNumPed+"' "
	cSql += " AND D_E_L_E_T_='' "

	TCSQLEXEC(cSql)     

Return

/*/{Protheus.doc} obtFrt
	Retorna o valor do frete por regi�o. Chamado 052898.
	@type  Static Function
	@author Everson
	@since 11/11/2019
	@version 01
	/*/
Static Function obtFrt(cCliente,cLoja,cTpFret)

    //���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������	
	Local aArea 	:= GetArea()
	Local cEst		:= ""
	Local cMunic	:= ""
	Local cRegiao	:= ""
	Local VlrFrt	:= 0

	//
	//Conout( DToC(Date()) + " " + Time() + " M410STTS - obtFrt - cCliente/cLoja/cTpFret " + cValToChar(cCliente) + "/" + cValToChar(cLoja) + "/" + cValToChar(cTpFret) )

	//
	IF cTpFret == "C" .And. ! Empty(cCliente) .And. ! Empty(cLoja)

		//
		cEst  := Posicione("SA1",1, FWxFilial("SA1") + cCliente + cLoja,"A1_EST")
		cMunic:= Posicione("SA1",1, FWxFilial("SA1") + cCliente + cLoja,"A1_COD_MUN")

		//
		//Conout( DToC(Date()) + " " + Time() + " M410STTS - obtFrt - cEst/cMunic " + cValToChar(cEst) + "/" + cValToChar(cMunic) )

		//
		If ! Empty(cEst) .And. ! Empty(cMunic)

			//
			cRegiao:= Posicione('CC2',1, FWxFilial("CC2") + cEst + cMunic ,"CC2_XREGIA")

			//
			If ! Empty(cRegiao)
				VlrFrt := Posicione('ZZI',1, FWxFilial("ZZI") + cRegiao ,"ZZI_VALOR")

			Else
				DbSelectArea("ZZI")
				ZZI->(DbSetOrder(3))
				ZZI->(DbSeek( FWxFilial("ZZI") + cEst))

				While ZZI->(!Eof()) .And. ZZI->ZZI_ESTADO == cEst

					If VlrFrt < ZZI->ZZI_VALOR
						VlrFrt := ZZI->ZZI_VALOR

					EndIf
					
					//
					ZZI->(dbSkip())

				EndDo

			EndIf

		EndIf

	EndIf

	//
	//Conout( DToC(Date()) + " " + Time() + " M410STTS - obtFrt - VlrFrt " + cValToChar(VlrFrt) )

	//
	RestArea(aArea)
	
Return VlrFrt

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
/*/
Static Function logZBE(cMensagem)

	// Local aArea	:= GetArea()

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "M410STTS" 
	ZBE->( msUnlock() )

Return

/*/{Protheus.doc} getRot
	(long_description)
	@type  Static Function
	@author Everson
	@since 26/06/2020
	@version 01
	/*/
Static Function getRot(cRotSA1)

	//Vari�veis.
	Local aArea := GetArea()

	//
	If cRotSA1 >= "350" .And. cRotSA1 <= "598"
		cRotSA1 := "599"

	ElseIf cRotSA1 >= "600" .And. cRotSA1 <= "898"
		cRotSA1 := "899"

	ElseIf cRotSA1 >= "900" .And. cRotSA1 <= "998"
		cRotSA1 := "999"

	EndIf

	//
	RestArea(aArea)

Return cRotSA1

/*/{Protheus.doc} Static Function DelRAFIE(_cNumPed)
	Apaga adiantamento e amarra��es, referente boletos bradesco WS
	@type  Function
	@author FWNM
	@since 21/07/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 059655 || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
/*/
Static Function DelRAFIE(cNum)

	Local aDadRA := {}
	Local dDtBaseBkp := dDataBase // chamado 059655 - FWNM - 23/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
	Local cTipoE1 := GetMV("MV_#WSTIPO",,"PR") // ticket 745 - FWNM - Implementa��o t�tulo PR - 18/09/2020

	//@history ticket 102 - FWNM - 26/08/2020 - WS BRADESCO 
	SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
	If SC5->( !dbSeek(FWxFilial("SC5")+cNum) )

		LogZBE(cNum + " FIE - CHECANDO SE O PV EXCLUIDO POSSUI FIE - M410STTS") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

		// Checo amarra��o RA x PV para excluir ap�s exclus�o do PV no Protheus
		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+cNum) )
			
			If FIE->FIE_SALDO > 0

				LogZBE(cNum + " FIE - EXCLUSAO DO FIE APOS PV TER SIDO EXCLUIDO - M410STTS") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

				RecLock("FIE", .F.)
					FIE->( dbDelete() )
				FIE->( msUnLock() )
		
			EndIf
		
		EndIf

		// Checo adiantamento (RA) para excluir ap�s exclus�o do PV no Sales Force
		SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If SE1->( dbSeek(FWxFilial("SE1")+PadR(cTipoE1,Len(SE1->E1_PREFIXO))+PadR(cNum,Len(SE1->E1_NUM))+PadR("",Len(SE1->E1_PARCELA))+PadR(cTipoE1,Len(SE1->E1_TIPO)) ) )

			LogZBE(cNum + " SE1/FIE - SERA EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - M410STTS") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

			dDataBase := SE1->E1_EMISSAO // chamado 059655 - FWNM - 23/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA
			
			aDadRA := {}
			aDadRA := { { "E1_PREFIXO", SE1->E1_PREFIXO  , NIL },;
						{ "E1_NUM"    , SE1->E1_NUM		 , NIL },;
						{ "E1_TIPO"   , SE1->E1_TIPO     , NIL },;
						{ "E1_NATUREZ", SE1->E1_NATUREZ  , NIL },;
						{ "E1_CLIENTE", SE1->E1_CLIENTE  , NIL },;
						{ "E1_LOJA"   , SE1->E1_LOJA	 , NIL },;
						{ "E1_EMISSAO", SE1->E1_EMISSAO  , NIL },;
						{ "E1_VENCTO" , SE1->E1_VENCTO   , NIL },;
						{ "E1_VENCREA", SE1->E1_VENCREA  , NIL },;
						{ "CBCOAUTO"  , SE1->E1_PORTADO  , NIL },;
						{ "CAGEAUTO"  , SE1->E1_AGEDEP   , NIL },;
						{ "CCTAAUTO"  , SE1->E1_CONTA    , NIL },;
						{ "E1_VALOR"  , SE1->E1_VALOR    , NIL }}

			lMsErroAuto := .f.
			msExecAuto( { |x,y| FINA040(x,y) }, aDadRA, 5 )  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o

			If lMsErroAuto
				MostraErro()
			Else
				LogZBE(cNum + " SE1/FIE - EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - M410STTS") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
			EndIf

			// Restauro database
			dDataBase := dDtBaseBkp // chamado 059655 - FWNM - 23/07/2020 - || OS 061193 || FINANCAS || MARILIA || 8353 || CANCELAMENTO RA

		EndIf
	
	EndIf
	//
	
Return

/*/{Protheus.doc} Static Function GeraSC9()
	Processa libera��o do PV para gerar SC9 via rotina padr�o - Padr�o n�o gera quando C5_BLQ = 1
	@type  Function
	@author FWNM
	@since 10/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function GeraSC9()

	Local aAreaSC6 := SC6->( GetArea() )
	Local aAreaSC9 := SC9->( GetArea() )
	Local nQtdLib  := 0

	SC6->( dbGoTop() )
	SC6->( dbSetOrder(1) ) // C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
	If SC6->( msSeek(SC5->(C5_FILIAL+C5_NUM)) )

		Do While SC6->( !EOF() ) .and. SC6->C6_FILIAL==SC5->C5_FILIAL .and. SC6->C6_NUM==SC5->C5_NUM
	
			nQtdLib := 0
			nQtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )

			If nQtdLib > 0
				Begin Transaction
					MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.T.,.T.,.T.,.T.)
				End Transaction
			EndIf

			SC6->( dbSkip() )

		EndDo

	EndIf

	SC9->( dbGoTop() )
	SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
	If SC9->( msSeek(SC5->(C5_FILIAL+C5_NUM)) )
		
		Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM

			RecLock("SC9", .F.)
				SC9->C9_BLCRED := "01"
				If Empty(SC9->C9_DTENTR)
					SC9->C9_DTENTR 	:= SC5->C5_DTENTR
					SC9->C9_VEND1   := SC5->C5_VEND1
					SC9->C9_ROTEIRO := SC5->C5_ROTEIRO
				EndIf
			SC9->( msUnLock() )

			SC9->( dbSkip() )

		EndDo

	EndIf

	RestArea(aAreaSC6)
	RestArea(aAreaSC9)

Return

//INICIO Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.
/*/{Protheus.doc} Static Function fPreLibF
	Efetua a pr� libera��o financeira
	@type  Function
	@author Abel Babini
	@since 09/02/2021
	/*/
/*
Static Function fPreLibF()
	Local aArea := GetArea()

	Local lAvDtLm  		:= GetMv("MV_#AVDTLM",,.F.) //Habilita a avalia��o de data de limite de cr�dito do cliente

	Local cAls000 := GetNextAlias()
	Local cAls001 := GetNextAlias()
	Local cAls002 := GetNextAlias()
	Local cAls003 := GetNextAlias()
	Local cAls004 := GetNextAlias()
	Local cAls005 := GetNextAlias()
	Local cAls006 := GetNextAlias()
	Local cAls007 := GetNextAlias()
	Local cAls008 := GetNextAlias()
	Local cAls009 := GetNextAlias()
	Local nValPed := 0
	Local lBlqPed := .F.
	Local aTpBloq	:= {}
	
	Local _cTipoCli := ""
	Local _cRede    := ""
	Local _cNmRede  := ""

	Local _nVlMnPed := 0
	Local _nVlMnPSC := 0
	Local _nVlPed := 0
	Local _nSldTit := 0
	Local _lTabA	:= .F.
	Local _lTabB	:= .F.
	Local _lTabC	:= .F.
	Local _lTabD	:= .F.
	Local _lTabE	:= .F.
	Local _lTabF	:= .F.
	Local _nVlMnParc := 0
	Local _nDiasAtras := 0
	Local cPortador := ''
	Local nPercen := 0

	Local _nValLim := 0
	Local _nVlLmCad := 0
	Local _nSldTPor := 0
	Local _lDiasAtras := .F.

	//Ticket  8      - Abel B.  - 15/02/2021 - Altera��o na regra de pr� libera��o de cr�dito para considerar pedidos com data de entrega futura
	Local _dDtEntr := DTOS(MsDate())

	Local _cCdClRd := ""
	Local nAux := 0


	BeginSQL Alias cAls001
		SELECT 
			ZAD_TABELA,
			ZAD_DATA, 
			ZAD_VALOR,
			ZAD_DIAS,
			ZAD_PORTAD,
			ZAD_PERCEN
		FROM %TABLE:ZAD% ZAD (NOLOCK) 
		WHERE ZAD.%notDel%
		ORDER BY ZAD_TABELA ASC, ZAD_DATA DESC
	ENDSQL

	(cAls001)->(dbGoTop())
	WHILE !(cAls001)->(eof())
		IF ZAD_TABELA == 'A' .and. !_lTabA
			_lTabA	:= .T.
			_nVlMnPed := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'B' .and. !_lTabB
			_lTabB	:= .T.
			_nVlMnPSC := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'C' .and. !_lTabC
			_lTabC	:= .T.
			_nVlMnParc := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'D' .and. !_lTabD
			_lTabD	:= .T.
			_nDiasAtras := (cAls001)->ZAD_DIAS
		ENDIF

		IF ZAD_TABELA == 'E' .and. !_lTabE
			_lTabE	:= .T.
			cPortador := (cAls001)->ZAD_PORTAD
		ENDIF

		IF ZAD_TABELA == 'F' .and. !_lTabF
			_lTabF	:= .T.
			nPercen := (cAls001)->ZAD_PERCEN / 100
		ENDIF

		(cAls001)->(dbSkip())
	ENDDO
	(cAls001)->(dbCloseArea())

	//Verifica se � Rede ou Varejo
	dbSelectArea("SZF")
	dbSetOrder(1)
	dbGoTop()
	If !SZF->(dbSeek(FWxFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))) //CLIENTE VAREJO
		_cTipoCli := "Varejo"
		
		//+ Soma dos limites do cliente do pedido em analise
		BeginSQL alias cAls000
			SELECT 
				SUM(A1_LC) AS A1_LC,
				A1_COD 
			FROM %TABLE:SA1% SA1 (NOLOCK)
			WHERE 
				A1_COD = %Exp:SC5->C5_CLIENTE%
				AND SA1.%notDel%
			GROUP BY A1_COD
			ORDER BY A1_COD
		EndSQL

		_nValLim  := (cAls000)->A1_LC
		_nVlLmCad := (cAls000)->A1_LC

		(cAls000)->(dbCloseArea())
		
		//Ticket  8      - Abel B.  - 15/02/2021 - Altera��o na regra de pr� libera��o de cr�dito para considerar pedidos com data de entrega futura
		BeginSQL Alias cAls002
			SELECT 
				SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS C6_PRCTOT, 
				C6_CLI
			FROM %TABLE:SC6% SC6 (NOLOCK)
			WHERE SC6.%notDel%
				AND C6_CLI = %Exp:SC5->C5_CLIENTE%
				AND C6_ENTREG >= %Exp:_dDtEntr%
				AND ((C6_QTDVEN - C6_QTDENT) > 0)
			GROUP BY C6_CLI
			ORDER BY C6_CLI
		ENDSQL
		
		(cAls002)->(dbGoTop())
		WHILE !(cAls002)->(eof())

			_nValLim -= (cAls002)->C6_PRCTOT
			_nVlPed  += (cAls002)->C6_PRCTOT

			(cAls002)->(dbSkip())
		ENDDO
		(cAls002)->(dbCloseArea())
		
		//- Soma do saldo dos titulos em aberto
		BeginSQL Alias cAls003
			SELECT 
				SUM(E1_SALDO) AS E1_SALDO,
				SUM(E1_VALOR) AS E1_VALOR,
				E1_CLIENTE,
				E1_PORTADO
			FROM %TABLE:SE1% SE1 (NOLOCK) 
			WHERE SE1.%notDel%
				AND E1_CLIENTE = %Exp:SC5->C5_CLIENTE%
				AND E1_SALDO > 0
				AND E1_TIPO NOT IN ('NCC','RA')
			GROUP BY E1_CLIENTE,E1_PORTADO
			ORDER BY E1_CLIENTE,E1_PORTADO
		ENDSQL

		(cAls003)->(dbGoTop())
		WHILE !(cAls003)->(eof())

			_nValLim -= (cAls003)->E1_SALDO
			_nSldTit += (cAls003)->E1_SALDO
			
			//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD (poe de volta saldo para portadores especiais, porque n�o pode ser abatido do limite)
			If (cAls003)->E1_PORTADO $ Alltrim(cPortador)
				_nValLim  += (cAls003)->E1_SALDO
				_nSldTPor += (cAls003)->E1_SALDO
			EndIf

			(cAls003)->(dbSkip())
		ENDDO
		(cAls003)->(dbCloseArea())
		
		//Verificando os titulos atrasados
		BeginSQL Alias cAls004
			SELECT 
				E1_VENCREA,
				E1_PORTADO
			FROM %TABLE:SE1% SE1 (NOLOCK) 
			WHERE SE1.%notDel%
				AND E1_CLIENTE = %Exp:SC5->C5_CLIENTE%
				AND E1_SALDO > 0
				AND E1_TIPO NOT IN ('NCC','RA')
				AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA
			ORDER BY E1_CLIENTE
		ENDSQL

		(cAls004)->(dbGoTop())
		WHILE !(cAls004)->(eof()) .And. !_lDiasAtras

			If ((dDatabase - STOD((cAls004)->E1_VENCREA)) > _nDiasAtras) .AND. !((cAls004)->E1_PORTADO $ Alltrim(cPortador))
				_lDiasAtras := .T.
			EndIf

			(cAls004)->(dbSkip())
		ENDDO
		(cAls004)->(dbCloseArea())
		
	Else //CLIENTE REDE
		_cRede    := SZF->ZF_REDE
		_cNmRede  := SZF->ZF_NOMERED
		_cTipoCli := "Rede"

		BeginSQL alias cAls007
			SELECT 
				ZF_REDE,
				ZF_CGCMAT,
				SUM(ZF_LCREDE) AS ZF_LCREDE  
			FROM %TABLE:SZF% SZF (NOLOCK)
			WHERE
				ZF_REDE = %Exp:Alltrim(_cRede)%
				AND SZF.%notDel%
			GROUP BY ZF_REDE,ZF_CGCMAT
			ORDER BY ZF_REDE,ZF_CGCMAT
		EndSQL

		(cAls007)->(dbgotop())
		
		Do While !(cAls007)->(EOF())
			
			//+ Soma dos limites da rede
			_nValLim  += (cAls007)->ZF_LCREDE
			_nVlLmCad += (cAls007)->ZF_LCREDE
			
			//+ Soma dos limites do cliente do pedido em analise
			BeginSQL alias cAls008
				SELECT 
					A1_COD 
				FROM %TABLE:SA1% SA1 (NOLOCK)
				WHERE 
					SUBSTRING(A1_CGC,1,8) = %Exp:Alltrim((cAls007)->ZF_CGCMAT)%
					AND SA1.%notDel%
				GROUP BY A1_COD
				ORDER BY A1_COD
			EndSQL
						
			(cAls008)->(dbgotop())
			Do While !(cAls008)->(EOF())
				
				_cCdClRd := (cAls008)->A1_COD

				//Ticket  8      - Abel B.  - 15/02/2021 - Altera��o na regra de pr� libera��o de cr�dito para considerar pedidos com data de entrega futura				
				BeginSQL alias cAls009
					SELECT 
						SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS C6_PRCTOT,
						C6_CLI 
					FROM %TABLE:SC6% SC6 (NOLOCK)
					WHERE
						C6_CLI = %Exp:_cCdClRd%
						AND C6_ENTREG >= %Exp:_dDtEntr%
						AND ((C6_QTDVEN - C6_QTDENT) > 0)
						AND SC6.%notDel%
					GROUP BY C6_CLI
					ORDER BY C6_CLI
				EndSQL
				(cAls009)->(dbgotop())
				
				_nValLim -= (cAls009)->C6_PRCTOT
				_nVlPed  += (cAls009)->C6_PRCTOT
				(cAls009)->(DbCloseArea())
				
				//- Soma do saldo dos titulos em aberto
				BeginSQL alias cAls009
					SELECT 
						SUM(E1_SALDO) AS E1_SALDO,
						SUM(E1_VALOR) AS E1_VALOR,
						E1_CLIENTE,
						E1_PORTADO 
					FROM %TABLE:SE1% SE1 (NOLOCK)
					WHERE 
						E1_CLIENTE = %Exp:_cCdClRd%
						AND E1_SALDO > 0
						AND E1_TIPO NOT IN ('NCC','RA')
						AND SE1.%notDel%
					GROUP BY E1_CLIENTE,E1_PORTADO
					ORDER BY E1_CLIENTE,E1_PORTADO
				EndSQL
				
				(cAls009)->(dbgotop())
				Do While !(cAls009)->(EOF())
					_nValLim -= (cAls009)->E1_SALDO
					_nSldTit += (cAls009)->E1_SALDO
					//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD
					//portador especial � retornado o saldo, pois n�o deve abater...
					If (cAls009)->E1_PORTADO $ Alltrim(cPortador)
						_nValLim  += (cAls009)->E1_SALDO
						_nSldTPor += (cAls009)->E1_SALDO
					EndIf
					(cAls009)->(dbSkip())
				Enddo
				(cAls009)->(DbCloseArea())
				
				//Verificando os titulos atrasados
				BeginSQL alias cAls009
					SELECT 
						E1_VENCREA,
						E1_PORTADO,
						E1_CLIENTE,
						E1_LOJA,
						E1_NOMCLI 
					FROM %TABLE:SE1% SE1 (NOLOCK)
					WHERE
						E1_SALDO > 0
						AND E1_CLIENTE = %Exp:_cCdClRd%
						AND E1_TIPO NOT IN ('NCC','RA')
						AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA
						AND SE1.%notDel%
					ORDER BY E1_CLIENTE
				EndSQL

				(cAls009)->(dbgotop())
				
				While !Eof()
					If (dDatabase - STOD((cAls009)->E1_VENCREA)) > _nDiasAtras
						If !((cAls009)->E1_PORTADO $ Alltrim(cPortador))
							_lDiasAtras := .T.
							// Aadd(_aAtrRede,{(cAls009)->E1_CLIENTE+" "+(cAls009)->E1_LOJA+" - "+(cAls009)->E1_NOMCLI})
						EndIf
					EndIf
					(cAls009)->(dbSkip())
				Enddo
				
				(cAls009)->(DbCloseArea())
				
				(cAls008)->(dbSkip())
			Enddo
			(cAls008)->(DbCloseArea())
			(cAls007)->(dbSkip())
		Enddo
		(cAls007)->(DbCloseArea())
	Endif
	

	//Verifica se o saldo do pedido e se os itens possuem cobran�a
	BeginSQL Alias cAls005
		SELECT 
			C5_NUM, 
			SUM(((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN)) AS C6_VALOR, 
			COUNT(SC6.C6_ITEM) AS NUM_ITEM,
			SUM(CASE WHEN NOT(SF4.F4_DUPLIC = 'S' AND SC5.C5_TIPO IN ('N','C') AND SC5.C5_EST <> 'EX') THEN 1 ELSE 0 END) AS FLAG 
		FROM %TABLE:SC5% SC5 (NOLOCK) 
		INNER JOIN %TABLE:SC6% SC6 (NOLOCK) ON
			SC5.C5_FILIAL = SC6.C6_FILIAL
			AND SC5.C5_NUM = SC6.C6_NUM
		INNER JOIN %TABLE:SF4% SF4 (NOLOCK) ON
			SF4.F4_CODIGO = SC6.C6_TES
		WHERE SC5.C5_FILIAL = %Exp:SC5->C5_FILIAL%
			AND SC5.C5_NUM = %Exp:SC5->C5_NUM%
			AND SC5.%notDel%
			AND SC6.%notDel%
			AND SF4.%notDel%
		GROUP BY C5_FILIAL,C5_NUM

	ENDSQL

	(cAls005)->(dbGoTop())
	IF (cAls005)->(eof()) .or. (cAls005)->C6_VALOR == 0
		RestArea(aArea)
		Return nil
	ELSE
		nValPed := (cAls005)->C6_VALOR
	ENDIF
	(cAls005)->(dbCloseArea())

	//M�dia da condi��o de pagto do pedido � maior do que media do cliente, bloqueia, s� passa se for igual ou menor.
	_nMedPGPd := Posicione("SE4",1,FWxFilial("SE4") + SC5->C5_CONDPAG,"E4_DMEDI")
	_nMedPGA1 := Posicione("SE4",1,FWxFilial("SE4") + POSICIONE("SA1",1,FWxFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_COND") ,"E4_DMEDI")
	If _nMedPGPd > _nMedPGA1
		lBlqPed := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTpBloq,{"Prazo medio da condi��o de pagamento do pedido maior que o prazo medio na condi��o do Cliente - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		
		Else
			Aadd(aTpBloq,{"Prazo medio da condi��o de pagamento do pedido maior que o prazo medio na condi��o do Cliente"})
		
		EndIf 

	EndIf

	//Valida se o cr�dito do cliente expirou. Everson - 22/04/2020. Chamado 057436.
	If lAvDtLm .And. SA1->A1_VENCLC < Date()
		lBlqPed := .T.
		Aadd(aTpBloq,{"Limite de cr�dito do cliente est� expirado (" + DToC(SA1->A1_VENCLC) + ")"})
	EndIf
	//

	//Bloqueio - Valor Minimo do Pedido
	If Alltrim(SC5->C5_FILIAL) == "03"
		If nValPed < _nVlMnPSC
			lBlqPed := .T.
			If Alltrim(_cTipoCli) == "Rede"
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO"})
			EndIf  
		EndIf

	Else
		If nValPed < _nVlMnPed
			lBlqPed := .T.
			If Alltrim(_cTipoCli) == "Rede"			
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO"})
			EndIf 
		EndIf
	EndIf


	//Se o pedido com valor 0 apresenta erro, no caso de pedidos cortados                          
	If nValPed <> 0
		//Bloqueio - Valor Minimo da Parcela
		aCondPgto := {}
		aCondPgto := CONDICAO(nValPed,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
		nValParc  := aCondPgto[1,2]

		//
		If nValParc < _nVlMnParc
			If nValParc <> nValPed
				lBlqPed := .T.
				If Alltrim(_cTipoCli) == "Rede"	
					Aadd(aTpBloq,{"VLR PARC INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
				Else
					Aadd(aTpBloq,{"VLR PARC INF MINIMO"})
				EndIf
			EndIf
		EndIf
	EndIf

	//Bloqueio por saldo maior que percentual para titulos em atraso
	//Bloqueio - Titulos em Atraso
	If _lDiasAtras
		BeginSQL alias cAls006
			SELECT 
				E1_SALDO,
				E1_VALOR,
				E1_CLIENTE,
				E1_PREFIXO, 
				E1_NUM, 
				E1_PARCELA,
				E1_PORTADO 
			FROM %TABLE:SE1% SE1 (NOLOCK)
			WHERE
				E1_CLIENTE = %Exp:SC5->C5_CLIENTE%
				AND E1_SALDO > 0
				AND E1_SALDO > (E1_VALOR * %Exp:Alltrim(Str(nPercen))%)
				AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA
				AND E1_TIPO NOT IN ('NCC','RA')
				AND SE1.%notDel%
			ORDER BY E1_CLIENTE
		EndSQL
		//Inclus�o de tratamento para avaliar percentual para saldo de titulos(somente atrasados)
		(cAls006)->(dbgotop())
		While ! (cAls006)->(eof())
			If !((cAls006)->E1_PORTADO $ Alltrim(cPortador))
				lBlqPed := .T.
				If Alltrim(_cTipoCli) == "Rede"
					If (cAls006)->E1_SALDO == (cAls006)->E1_VALOR  //Saldo em aberto integral
						Aadd(aTpBloq,{"TITULO EM ATRASO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					Else
						Aadd(aTpBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					EndIf   
				Else
					If (cAls006)->E1_SALDO == (cAls006)->E1_VALOR  //Saldo em aberto integral
						Aadd(aTpBloq,{"TITULO EM ATRASO. Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					Else
						Aadd(aTpBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					EndIf  
				EndIf 
			EndIf   
			(cAls006)->(DbSkip())
		End
		(cAls006)->(DbCloseArea())
	EndIf

	//Bloqueio - Valor do Pedido Maior que o Limite Disponivel
	If nValPed > (  _nValLim + nValPed )
		lBlqPed := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTpBloq,{"LIMITE EXCEDIDO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		Else
			Aadd(aTpBloq,{"LIMITE EXCEDIDO"})
		EndIf
	EndIf

	// DbSelectArea("SA3")
	// SA3->(DbSetOrder(1))
	// SA3->(DbSeek(FWxFilial("SA3")+SC5->C5_VEND1))
	// _eMailVend := SA3->A3_EMAIL
	
	//
	// DbSelectArea("SZR")
	// SZR->(DbSetOrder(1))
	// SZR->(DbSeek(FWxFilial("SZR")+SA3->A3_CODSUP))
	// _eMailSup := Alltrim(UsrRetMail(SZR->ZR_USER))

	IF lBlqPed
		IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da fun��o uptSC5
			SC5->C5_XPREAPR := 'B'
			SC5->( MsUnLock() ) 
		ENDIF
	ELSE
		IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da fun��o uptSC5
			SC5->C5_XPREAPR := 'L'
			SC5->( MsUnLock() ) 
		ENDIF
	ENDIF

	For nAux := 1 to len(aTpBloq)
		Reclock("ZBH",.T.)
			ZBH->ZBH_FILIAL  := SC5->C5_FILIAL
			ZBH->ZBH_PEDIDO  := SC5->C5_NUM
			ZBH->ZBH_CLIENT  := SC5->C5_CLIENTE
			ZBH->ZBH_LOJA    := SC5->C5_LOJACLI
			ZBH->ZBH_NOME    := SC5->C5_NOMECLI
			ZBH->ZBH_MOTIVO  := aTpBloq[nAux][1]
			ZBH->ZBH_CODVEN  := SC5->C5_VEND1
			ZBH->ZBH_NOMVEN  := Posicione("SA3",1,FWxFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
		ZBH->(MsUnlock()) 

	Next nAux

	RestArea(aArea)
Return 
*/
//fim Ticket  8      - Abel B.  - 15/02/2021 - Pr�-libera��o de cr�dito para inclus�o e altera��o de pedidos.


//INICIO Ticket  8      - Abel B.  - 22/02/2021 - Nova rotina de Pr�-libera��o de cr�dito levando-se em considera��o a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
/*/{Protheus.doc} Static Function fLibCred
	Efetua a pr� libera��o financeira
	@type  Function
	@author Abel Babini
	@since 09/02/2021
/*/
Static Function fLibCred(cCliente, cLojaCli, dDtEntr, lExcPedV, cNumPVEx, cNumPVIn)
	
	Local aArea   := GetArea()
	Local cAls001 := GetNextAlias()
	Local cAls002 := GetNextAlias()
	Local cAls003 := GetNextAlias()
	Local cAls006 := GetNextAlias()

	Local _cTipoCli := ""
	Local _cRede    := ""
	Local _cNmRede  := ""

	Local _nVlMnPed := 0
	Local _nVlMnPSC := 0
	Local _nVlPed := 0
	Local _lTabA	:= .F.
	Local _lTabB	:= .F.
	Local _lTabC	:= .F.
	Local _lTabD	:= .F.
	Local _lTabE	:= .F.
	Local _lTabF	:= .F.
	Local _nVlMnParc := 0
	Local _nDiasAtras := 0
	Local cPortador := ''
	//@Ticket  65403  - Leonardo P. Monteiro  - 16/11/2021 - Corre��o de error.log na grava��o de PVs na filial 07.
	Local cPortadIn := "%('')%"
	Local nPercen := 0

	Local _nValLim := 0
	Local _nVlLmCad := 0
	Local _nSldTPor := 0
	Local _lDiasAtras := .F.

	Local _nRecSA1 := SA1->(RECNO())
	Local _nRecSZF := SZF->(RECNO())
	Local _nRecSE4 := SE4->(RECNO())
	Local _nRecSC5 := SC5->(RECNO())
	Local _nRecSZR := SZR->(RECNO())
	Local cFilPVEx	 := '%'+''+'%'

	Local lBlqAtr	:= .F.
	Local aTpBlqAt 	:= {}
	Local cQryNPV	:= ''

	Local cParam	:= "" //Everson - 14/10/2021. Chamado 62453.

	Default lExcPedV 	:= .F.
	Default cNumPVEx 	:= ''
	Default cNumPVIn 	:= ''

	//Utiliza sempre a menor data entre a data de entrega e a data do servidor para avalia��o de cr�dito.
	If dDtEntr > MsDate()
		dDtEntr := MsDate()
	Endif
	
	//Ticket  8      - Abel B.  - 01/03/2021 - Altera��o na regra de pr� libera��o de cr�dito para desconsiderar o pedido que ser� exclu�do durante a avalia��o na exclus�o do mesmo
	If lExcPedV .AND. !Empty(Alltrim(cNumPVEx))
		cFilPVEx :=  '%'+" AND SC5.C5_FILIAL+SC5.C5_NUM <> '"+cNumPVEx+"' "+'%'
	Endif

	//CARREGA DEFINI��ES DE REGRAS DE TABELAS E VALORES DE PEDIDOS
	BeginSQL Alias cAls001
		SELECT 
			ZAD_TABELA,
			ZAD_DATA, 
			ZAD_VALOR,
			ZAD_DIAS,
			ZAD_PORTAD,
			ZAD_PERCEN
		FROM %TABLE:ZAD% (NOLOCK) ZAD 
		WHERE ZAD.%notDel%
		ORDER BY ZAD_TABELA ASC, ZAD_DATA DESC
	ENDSQL

	(cAls001)->(dbGoTop())
	WHILE !(cAls001)->(eof())
		IF ZAD_TABELA == 'A' .and. !_lTabA
			_lTabA	:= .T.
			_nVlMnPed := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'B' .and. !_lTabB
			_lTabB	:= .T.
			_nVlMnPSC := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'C' .and. !_lTabC
			_lTabC	:= .T.
			_nVlMnParc := (cAls001)->ZAD_VALOR
		ENDIF

		IF ZAD_TABELA == 'D' .and. !_lTabD
			_lTabD	:= .T.
			_nDiasAtras := (cAls001)->ZAD_DIAS
		ENDIF

		IF ZAD_TABELA == 'E' .and. !_lTabE
			_lTabE	:= .T.
			cPortador := (cAls001)->ZAD_PORTAD
			cPortadIn := '%'+FormatIn(cPortador,';')+'%'
		ENDIF

		IF ZAD_TABELA == 'F' .and. !_lTabF
			_lTabF	:= .T.
			nPercen := (cAls001)->ZAD_PERCEN / 100
		ENDIF

		(cAls001)->(dbSkip())
	ENDDO
	(cAls001)->(dbCloseArea())

	aRetRede := fRetClRd(cCliente,cLojaCli)
	_cRede    := aRetRede[4]
	_cNmRede  := aRetRede[5]
	_cTipoCli := aRetRede[6]
	_nValLim  := aRetRede[2]
	_nVlLmCad := aRetRede[2]
	_dValidLC	:= aRetRede[3]
	_cCdClIn	:= '%'+FormatIn(aRetRede[1],",")+'%'
	
	IF Empty(cPortadIn)
		cPortadIn := "%('')%"
	endif
	
	//
	BeginSQL Alias cAls003
		SELECT 
			CASE WHEN SE1.E1_PORTADO IN %Exp:cPortadIn% THEN SUM(SE1.E1_SALDO) ELSE 0 END AS PORT_ESP,
			CASE WHEN SE1.E1_PORTADO NOT IN %Exp:cPortadIn% THEN SUM(SE1.E1_SALDO) ELSE 0 END AS E1_SALDO,
			CASE WHEN CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA THEN SUM(SE1.E1_SALDO) ELSE 0 END AS TIT_VENCIDO
		FROM %TABLE:SE1% (NOLOCK) SE1
		WHERE 
			SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
			AND SE1.E1_SALDO > 0
			AND SE1.E1_TIPO NOT IN ('NCC','RA')
			AND SE1.%notDel%
		GROUP BY E1_PORTADO, E1_VENCREA
	EndSQL
	(cAls003)->(dbGoTop())

	////Ticket  8      - Abel B.  - 03/03/2021 - Ajustes na rotina de libera��o de cr�dito - acrescentado loop WHILE
	WHILE ! (cAls003)->(eof())
		_nValLim -= (cAls003)->E1_SALDO
		// _nSldTit += (cAls003)->E1_SALDO+(cAls003)->PORT_ESP
		_nSldTPor += (cAls003)->PORT_ESP

		IF (cAls003)->TIT_VENCIDO > 0
			_lDiasAtras := .T.
		ENDIF

		(cAls003)->(dbSkip())
	ENDDO

	(cAls003)->(dbCloseArea())
	
	//@history Ticket  8      - Abel B.  - 12/03/2021 - Ajustes na rotina de libera��o de cr�dito
	IF _lDiasAtras
		BeginSQL alias cAls006
			SELECT 
				SE1.E1_PREFIXO, 
				SE1.E1_NUM, 
				SE1.E1_SALDO,
				SE1.E1_VALOR,
				SE1.E1_CLIENTE,
				SE1.E1_PARCELA,
				SE1.E1_PORTADO 
			FROM %TABLE:SE1% (NOLOCK) SE1
			WHERE
				SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
				AND SE1.E1_SALDO > 0
				AND SE1.E1_SALDO > (E1_VALOR * %Exp:Alltrim(Str(nPercen))%)
				AND CONVERT(CHAR(10), GETDATE(),112) > SE1.E1_VENCREA
				AND SE1.E1_TIPO NOT IN ('NCC','RA')
				AND SE1.%notDel%
			ORDER BY E1_CLIENTE
		EndSQL
		//Inclus�o de tratamento para avaliar percentual para saldo de titulos(somente atrasados)
		(cAls006)->(dbgotop())

		While ! (cAls006)->(eof())
			If !((cAls006)->E1_PORTADO $ Alltrim(cPortador))
				lBlqAtr := .T.
				If Alltrim(_cTipoCli) == "Rede"
					If (cAls006)->E1_SALDO == (cAls006)->E1_VALOR  //Saldo em aberto integral
						Aadd(aTpBlqAt,{"TITULO EM ATRASO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					Else
						Aadd(aTpBlqAt,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					EndIf   
				Else
					If (cAls006)->E1_SALDO == (cAls006)->E1_VALOR  //Saldo em aberto integral
						Aadd(aTpBlqAt,{"TITULO EM ATRASO. Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					Else
						Aadd(aTpBlqAt,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. Titulo: "+(cAls006)->E1_PREFIXO+"-"+(cAls006)->E1_NUM+"-"+(cAls006)->E1_PARCELA})
					EndIf  
				EndIf 
			EndIf   
			(cAls006)->(DbSkip())
		End
		(cAls006)->(DbCloseArea())

	ENDIF

	//PEDIDOS QUE PRECISAM DE AN�LISE DE CR�DITO

	if !Empty(Alltrim(cNumPVIn))
		cParam := StrTran(cNumPVIn,"%","")
		cQryNPV:= '%'+" AND SC5.C5_NUM = '" + cParam + "' "+'%' //Everson - 14/10/2021. Chamado 62453. 

	else
		cParam := StrTran(_cCdClIn,"%","")
		cQryNPV:= '%'+" AND SC5.C5_CLIENTE+SC5.C5_LOJACLI IN " + cParam + " " +'%' //Everson - 14/10/2021. Chamado 62453.

	endif

	BeginSQL alias cAls002
		column C5_EMISSAO as Date
		SELECT
			SC5.C5_FILIAL, 
			SC5.C5_NUM, 
			SC5.C5_TIPO, 
			SC5.C5_CLIENTE, 
			SC5.C5_LOJACLI, 
			SC5.C5_DTENTR, 
			SC5.C5_CONDPAG, 
			SC5.C5_VEND1,
			SC5.C5_EMISSAO,
			SC5.C5_XTOTPED,
			CASE WHEN (SF4.F4_DUPLIC = 'S' AND SC5.C5_TIPO IN ('N','C') AND SC5.C5_EST <> 'EX') THEN SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) ELSE 0 END AS C6_PRCTOT
		FROM %TABLE:SC5% (NOLOCK) SC5
		INNER JOIN %TABLE:SC6% (NOLOCK) SC6 ON
			SC6.C6_FILIAL = SC5.C5_FILIAL
			AND SC6.C6_NUM = SC5.C5_NUM
			AND SC6.C6_CLI = SC5.C5_CLIENTE
			AND SC6.C6_LOJA = SC5.C5_LOJACLI
			AND SC6.%notDel%
		INNER JOIN %TABLE:SF4% (NOLOCK) SF4 ON
			SF4.F4_FILIAL = %xFilial:SF4%
			AND SF4.F4_CODIGO = SC6.C6_TES
			AND SF4.%notDel%
		WHERE 
			SC5.C5_FILIAL = %xFilial:SC5%
			%Exp:cQryNPV% 
			AND SC5.C5_NOTA = '' %Exp:cFilPVEx% 
			AND SC5.C5_DTENTR >= %Exp:DTOS(dDtEntr)%
			AND SC5.%notDel%
		GROUP BY 
			SC5.C5_FILIAL, 
			SC5.C5_NUM, 
			SC5.C5_TIPO, 
			SC5.C5_CLIENTE, 
			SC5.C5_LOJACLI, 
			SC5.C5_DTENTR, 
			SC5.C5_CONDPAG, 
			SC5.C5_VEND1,
			SC5.C5_EMISSAO,
			SC5.C5_XTOTPED,
			SF4.F4_DUPLIC,
			SC5.C5_EST
		ORDER BY SC5.C5_FILIAL ASC, SC5.C5_DTENTR ASC, SC5.C5_NUM ASC
	EndSQL

	(cAls002)->(dbgotop())
	WHILE ! (cAls002)->(eof())
	
		_nValLim -= (cAls002)->C6_PRCTOT
		_nVlPed  += (cAls002)->C6_PRCTOT

		//INICIO Ticket  8      - Abel B.  - 05/07/2021 - Adiciona valida��o para apenas refazer a libera��o caso o pedido n�o tenha sido liberado ainda.
		aVrLbAnt := fVrLbAnt((cAls002)->C5_FILIAL, (cAls002)->C5_NUM)
		IF aVrLbAnt[1] == .F. .or. (aVrLbAnt[1] == .T. .AND. aVrLbAnt[2] < (cAls002)->C5_XTOTPED)
			
			//VALIDA CR�DITO DO PEDIDO
			//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVldCrd - INICIO 1" )
				fVldCrd(_cTipoCli, (cAls002)->C5_CLIENTE, (cAls002)->C5_LOJACLI, _cCdClIn, (cAls002)->C5_FILIAL, (cAls002)->C5_NUM, _dValidLC, _cRede, _cNmRede, _nVlMnPed, _nVlMnPSC, _nVlMnParc, _nDiasAtras, cPortadIn, cPortador, nPercen, (cAls002)->C6_PRCTOT, (cAls002)->C5_CONDPAG, (cAls002)->C5_EMISSAO, _lDiasAtras, _nValLim, (cAls002)->C5_VEND1, lBlqAtr, aTpBlqAt)
			//Conout( DToC(Date()) + " " + Time() + " M410STTS - fVldCrd - FINAL 2" )

		ENDIF

		(cAls002)->(dbSkip())
	
	ENDDO
	
	(cAls002)->(DbCloseArea())

	SA1->(DBGOTO(_nRecSA1))
	SZF->(DBGOTO(_nRecSZF))
	SE4->(DBGOTO(_nRecSE4))
	SC5->(DBGOTO(_nRecSC5))
	SZR->(DBGOTO(_nRecSZR))

	RestArea(aArea)
Return

/*/{Protheus.doc} Static Function fVldCrd
	Fun��o que valida cr�dito do pedido
	@type  Function
	@author Abel Babini
	@since 09/02/2021
	/*/
Static Function fVldCrd(_cTipoCli, cCliente, cLojaCli, _cCdClIn, cFilPedV, cNumPedV, _dValidLC, _cRede, _cNmRede, _nVlMnPed, _nVlMnPSC, _nVlMnParc, _nDiasAtras, cPortadIn, cPortador, nPercen, nValPed, cSC5CPag, dSC5Emis, _lDiasAtras, _nValLim, cSC5Vend, lBlqAtr, aTpBlqAt)

	Local lBlqPed := .F.
	Local aTpBloq := {}
	Local lAvDtLm  		:= GetMv("MV_#AVDTLM",,.F.) //Habilita a avalia��o de data de limite de cr�dito do cliente
	Local aCondPgto := {}
	Local nValParc := 0
	Local nAux := 0

	//M�dia da condi��o de pagto do pedido � maior do que media do cliente, bloqueia, s� passa se for igual ou menor.
	_nMedPGPd := Posicione("SE4",1,FWxFilial("SE4") + cNumPedV,"E4_DMEDI")
	_nMedPGA1 := Posicione("SE4",1,FWxFilial("SE4") + POSICIONE("SA1",1,FWxFilial("SA1")+cCliente+cLojaCli,"A1_COND") ,"E4_DMEDI")
	If _nMedPGPd > _nMedPGA1
		lBlqPed := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTpBloq,{"Prazo medio da condi��o de pagamento do pedido maior que o prazo medio na condi��o do Cliente - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		Else
			Aadd(aTpBloq,{"Prazo medio da condi��o de pagamento do pedido maior que o prazo medio na condi��o do Cliente"})
		EndIf 
	EndIf

	//Valida se o cr�dito do cliente expirou. Everson - 22/04/2020. Chamado 057436.
	If lAvDtLm .And. _dValidLC < Date()
		lBlqPed := .T.
		Aadd(aTpBloq,{"Limite de cr�dito do cliente est� expirado (" + DToC(_dValidLC) + ")"})
	EndIf
	//

	//Bloqueio - Valor Minimo do Pedido
	If Alltrim(cFilPedV) == "03"
		If nValPed < _nVlMnPSC
			lBlqPed := .T.
			If Alltrim(_cTipoCli) == "Rede"
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO"})
			EndIf  
		EndIf

	Else
		If nValPed < _nVlMnPed
			lBlqPed := .T.
			If Alltrim(_cTipoCli) == "Rede"			
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				Aadd(aTpBloq,{"VLR PEDIDO INF MINIMO"})
			EndIf 
		EndIf
	EndIf


	//Se o pedido com valor 0 apresenta erro, no caso de pedidos cortados                          
	If nValPed <> 0
		//Bloqueio - Valor Minimo da Parcela 
		aCondPgto := CONDICAO(nValPed,cSC5CPag,,dSC5Emis)
		nValParc  := aCondPgto[1,2]

		//
		If nValParc < _nVlMnParc
			If nValParc <> nValPed
				lBlqPed := .T.
				If Alltrim(_cTipoCli) == "Rede"	
					Aadd(aTpBloq,{"VLR PARC INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
				Else
					Aadd(aTpBloq,{"VLR PARC INF MINIMO"})
				EndIf
			EndIf
		EndIf
	EndIf

	//Ticket  8      - Abel B.  - 03/03/2021 - Ajustes na rotina de libera��o de cr�dito - Ajustada query acrescentado E1_LOJA na clausula WHERE
	//Bloqueio por saldo maior que percentual para titulos em atraso
	//Bloqueio - Titulos em Atraso
	If _lDiasAtras
		IF !lBlqPed .AND. lBlqAtr
			lBlqPed := lBlqAtr
		ENDIF
		IF Len(aTpBlqAt) > 0 .AND. lBlqAtr
			For nAux := 1 to len(aTpBlqAt)
				Aadd(aTpBloq,aTpBlqAt[nAux])
			NEXT nAux
		ENDIF
	EndIf

	//Bloqueio - Valor do Pedido Maior que o Limite Disponivel
	If nValPed > (  _nValLim + nValPed )
		lBlqPed := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTpBloq,{"LIMITE EXCEDIDO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		Else
			Aadd(aTpBloq,{"LIMITE EXCEDIDO"})
		EndIf
	EndIf

	// DbSelectArea("SA3")
	// SA3->(DbSetOrder(1))
	// SA3->(DbSeek(FWxFilial("SA3")+cSC5Vend))
	// _eMailVend := SA3->A3_EMAIL
	
	//
	// DbSelectArea("SZR")
	// SZR->(DbSetOrder(1))
	// SZR->(DbSeek(FWxFilial("SZR")+SA3->A3_CODSUP))
	// _eMailSup := Alltrim(UsrRetMail(SZR->ZR_USER))

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	IF SC5->(dbSeek(cFilPedV+cNumPedV))

		IF lBlqPed
			IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da fun��o uptSC5
				SC5->C5_XPREAPR := 'B'
				SC5->( MsUnLock() ) 
			ENDIF
		ELSE
			IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da fun��o uptSC5
				SC5->C5_XPREAPR := 'L'
				SC5->( MsUnLock() ) 
			ENDIF
		ENDIF

		//INICIO Ticket  8      - Abel B.  - 02/03/2021 - Limpar bloqueios anteriores do Pedido.		dbSelectArea("ZBH")
		ZBH->(dbSetOrder(1))
		IF ZBH->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
			WHILE ! ZBH->(eof()) .AND. ZBH->ZBH_FILIAL == SC5->C5_FILIAL .AND. ZBH->ZBH_PEDIDO == SC5->C5_NUM
				Reclock("ZBH",.F.)
				ZBH->(dbDelete())
				ZBH->(MsUnlock())

				ZBH->(dbSkip())
			ENDDO
		ENDIF
		//FIM Ticket  8      - Abel B.  - 02/03/2021 - Limpar bloqueios anteriores do Pedido.

		For nAux := 1 to len(aTpBloq)
			Reclock("ZBH",.T.)
				ZBH->ZBH_FILIAL  := SC5->C5_FILIAL
				ZBH->ZBH_PEDIDO  := SC5->C5_NUM
				ZBH->ZBH_CLIENT  := SC5->C5_CLIENTE
				ZBH->ZBH_LOJA    := SC5->C5_LOJACLI
				ZBH->ZBH_NOME    := SC5->C5_NOMECLI
				ZBH->ZBH_MOTIVO  := aTpBloq[nAux][1]
				ZBH->ZBH_CODVEN  := SC5->C5_VEND1
				ZBH->ZBH_NOMVEN  := Posicione("SA3",1,FWxFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
			ZBH->(MsUnlock()) 
		Next nAux
	ENDIF

Return

/*/{Protheus.doc} Static Function fRetClRd
	Retorna rela��o de c�digos de cliente e loja de uma rede, Limite de Cr�dito, Vencimento do Limite de Cr�dito, Nome da Rede e o Tipo do Cliente (Rede / Varejo)
	Fun��o Utilizada tamb�m no c�lculo da m�dia de atraso e perfil de pagamento dos clientes (ADFIN103P)
	@type  Function
	@author Abel Babini
	@since 09/02/2021
	/*/
Static Function fRetClRd(cCliente,cLojaCli)
	Local aRet := {}
	Local cAlsRtCl := GetNextAlias()
	Local _aLCRede := {}
	Local nLimCred := 0
	Local dDtLimCr := nil
	Local cCodCli := ''
	Local cNomeRede := ''
	Local cRede := ''
	Local cTpCli := ''

	//Ticket  8      - Abel B.  - 03/03/2021 - Ajustes na rotina de libera��o de cr�dito - Retirado filtro AND SA1.A1_MSBLQL <> '1'
	BeginSQL Alias cAlsRtCl
		column A1_VENCLC as Date
		SELECT 
			SA1.A1_COD, 
			SA1.A1_LOJA, 
			SA1.A1_CGC, 
			SA1.A1_LC, 
			SA1.A1_VENCLC, 
			SA1.A1_MSBLQL,
			ISNULL(SZF2.ZF_CGCMAT,'') AS ZF_CGCMAT, 
			ISNULL(SZF2.ZF_LCREDE,'') AS ZF_LCREDE, 
			ISNULL(SZF2.ZF_REDE,'') AS ZF_REDE, 
			ISNULL(SZF2.ZF_NOMERED,'') AS ZF_NOMERED, 
			CASE WHEN SZF2.ZF_REDE IS NULL THEN 'Varejo' ELSE 'Rede' END AS TIPO_CLI
		FROM %TABLE:SA1% (NOLOCK) SA1 
		LEFT JOIN %TABLE:SZF% (NOLOCK) SZF2 ON
			SZF2.ZF_CGCMAT = SUBSTRING(SA1.A1_CGC,1,8) 
					AND SZF2.%notDel%
		WHERE
			SA1.%notDel%
			AND ( SZF2.ZF_REDE IN (
						SELECT SZF.ZF_REDE
						FROM %TABLE:SZF% (NOLOCK) SZF
						WHERE SZF.%notDel%
						AND SZF.ZF_CGCMAT = ( SELECT SUBSTRING(SA12.A1_CGC,1,8) 
											  FROM %TABLE:SA1% (NOLOCK) SA12 
											  WHERE 
													SA12.A1_COD = %Exp:cCliente% 
												AND SA12.A1_LOJA = %Exp:cLojaCli% 
												AND SA12.%notDel%)
						)
						OR SA1.A1_COD = %Exp:cCliente%  AND SA1.A1_LOJA = %Exp:cLojaCli% 
					)
		ORDER BY SA1.A1_COD ASC, SA1.A1_LOJA ASC
	EndSQL
	(cAlsRtCl)->(dbGoTop())

	While ! (cAlsRtCl)->(eof())

		IF ASCAN(_aLCRede,{ |X| X[1] = Alltrim((cAlsRtCl)->ZF_CGCMAT)}) == 0 .AND. !Empty(Alltrim((cAlsRtCl)->ZF_CGCMAT))
			AADD(_aLCRede,{Alltrim((cAlsRtCl)->ZF_CGCMAT), (cAlsRtCl)->ZF_LCREDE})
			nLimCred += (cAlsRtCl)->ZF_LCREDE
		ELSEIF Empty(Alltrim((cAlsRtCl)->ZF_CGCMAT))
			nLimCred += (cAlsRtCl)->A1_LC
		ENDIF
		
		//Ticket  8      - Abel B.  - 03/03/2021 - Ajustes na rotina de libera��o de cr�dito
		IF !Empty(Alltrim(DTOS((cAlsRtCl)->A1_VENCLC))) .and. (cAlsRtCl)->A1_VENCLC < dDtLimCr .AND. (cAlsRtCl)->A1_MSBLQL <> '1'
			dDtLimCr := (cAlsRtCl)->A1_VENCLC
		ENDIF

		IF ! (cAlsRtCl)->A1_COD+(cAlsRtCl)->A1_LOJA $ cCodCli
			cCodCli += (cAlsRtCl)->A1_COD+(cAlsRtCl)->A1_LOJA+','
		ENDIF
		cNomeRede := (cAlsRtCl)->ZF_NOMERED
		cRede := (cAlsRtCl)->ZF_REDE
		cTpCli := (cAlsRtCl)->TIPO_CLI
		(cAlsRtCl)->(dbSkip())
	EndDO
	(cAlsRtCl)->(dbCloseArea())

	IF dDtLimCr == nil
		dDtLimCr := msDate()-1
	ENDIF

	aRet := {cCodCli, nLimCred, dDtLimCr, cRede, cNomeRede, cTpCli}
Return aRet

/*/{Protheus.doc} User Function fInterCo
	Fun��o para determinar se a opera��o � intercompany
	@type  Static Function
	@author Fernando Macieira
	@since 13/04/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@Ticket   11277 - F.Maciei - 13/04/2021 - DEMORA AO IMPORTAR PEDIDO DE RA��O
/*/
User Function fInterCo(cEntidade, cCod, cLoj)

	Local i
	Local lInterCo := .f.
	Local aDadEmp  := FWLoadSM0()
    LOCAL cKeyCNPJ := ""

    Default cEntidade := ""
    Default cCod      := ""
    Default cLoj      := ""

    If cEntidade == "C"
        cKeyCNPJ := Posicione("SA1",1,FWxFilial("SA1")+cCod+cLoj,"A1_CGC")
    Else
        cKeyCNPJ := Posicione("SA2",1,FWxFilial("SA2")+cCod+cLoj,"A2_CGC")
    EndIf

	For i:=1 to Len(aDadEmp)
		If ( AllTrim(cKeyCNPJ) == AllTrim(aDadEmp[i,18]) ) .or. ( Left(AllTrim(cKeyCNPJ),8) == Left(AllTrim(aDadEmp[i,18]),8) )
			lInterCo := .t.
			Exit
		EndIf
	Next i

Return lInterCo
/*/{Protheus.doc} libPedSAG
	Fun��o realiza a libera��o de pedido de venda por movimento de sa�da no SAG.
	@type  Static Function
	@author Everson
	@since 04/05/2021
	@version 01
	/*/
Static Function libPedSAG()
	
	//Vari�veis.
	Local aArea := GetArea()

	If ! Empty(Alltrim(cValToChar(SC5->C5_PEDSAG)))
		StaticCall(INTEPEDB,enviStComp)

	EndIf

	//
	RestArea(aArea)

Return Nil

//INICIO Ticket  8      - Abel B.  - 15/06/2021 - Considerar hist�rico de libera��o
/*/{Protheus.doc} Static Function fVrLbAnt
	Verifica se pedido j� foi liberado pelo cr�dito e se � necess�rio nova libera��o.
	@type  Function
	@author Abel Babini
	@since 15/06/2021
	/*/
Static Function fVrLbAnt(cSC5Fil, cSC5Num)

	Local aRet := {.F.,0}
	Local cQryZEJ := GetNextAlias()

	BeginSQL alias cQryZEJ
		SELECT TOP 1
			ZEJ_VLLIB AS VALOR
		FROM %TABLE:ZEJ% (NOLOCK) ZEJ
		WHERE 
			ZEJ.ZEJ_FILIAL = %Exp:cSC5Fil%
			AND ZEJ.ZEJ_NUM = %Exp:cSC5Num%
			AND ZEJ.%notDel%
		ORDER BY ZEJ_DTLIB DESC, ZEJ_HRLIB DESC
	ENDSQL

	IF !(cQryZEJ)->(EOF())
		aRet[1] := .T.
		aRet[2] := (cQryZEJ)->VALOR
	ENDIF
	(cQryZEJ)->(dbCloseArea())

Return aRet

/*/{Protheus.doc} fAtuRot
Fun��o respons�vel pela atualiza��o dos roteiro no Pedido de Venda.
@type  Function
@author Leonardo P. Monteiro
@since 10/11/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtuRot(cRotPar)
	Local cPedVend	:= SC5->C5_NUM
	Local lRet		:= .T.

	if RecLock("SC5",.F.)	      
		SC5->C5_ROTEIRO := cRotPar
		SC5->(MsUnlock())

		//Atualizo tabela SC6 com novo roteiro.
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+cPedVend))
			While SC6->(!Eof()) .And. SC6->C6_NUM == cPedVend
				if RecLock("SC6",.F.)	      
					SC6->C6_ROTEIRO := cRotPar      
					SC6->(MsUnlock())
					SC6->(dbSkip())
				else
					lRet := .F.
				endif
			Enddo
		Endif

		//Atualizo tabela SC9 com novo roteiro.
		dbSelectArea("SC9")
		SC9->(dbSetOrder(1))
		If SC9->(dbSeek(xFilial("SC9")+cPedVend))
			While SC9->(!Eof()) .And. SC9->C9_PEDIDO == cPedVend
				if RecLock("SC9",.F.)	      
					SC9->C9_ROTEIRO := cRotPar      
					SC9->(MsUnlock())
					SC9->(dbSkip())
				else
					lRet := .F.
				endif
			Enddo
		Endif

	else
		lRet := .F.
	endif
		
Return lRet


/*/{Protheus.doc} User Function MA410DEL
	Ponto de Entrada que envia email para os responsaveis pelo Pedido de Venda 
	informando o motivo do bloqueio PE refedinido em subst. ao PE A410EXC por
	HCCONSYS 16/01/09
	@type  Function
	@author HCCONSYS
	@since 16/01/09
	@history chamato TI    -              - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history ticket 8      - Abel Babini  - 01/03/2021 - N�o limpar flag dos registros e chamar a rotina de libera��o de cr�dtio.
	@history ticket 8      - Abel Babini  - 03/03/2021 - Nova versao - N�o limpar flag dos registros e chamar a rotina de libera��o de cr�dtio.
	@history 17537         - Everson      - 14/09/2021 - Tratamento para exclus�o de pedido pela rotina de importa��o Protheus x SAG.
	@history TI            - Leonardo P. Monteiro      - 01/02/2022 - Desativa��o do ponto de entrada e transfer�ncia para o M410STTS.
	/*/
Static Function fFunDel()
	
	Local aArea		:= GetArea()
	Local cMotivo 	:= Space(115)
	Local nOpt 		:= 0
	Local lRet		:= .f.
	Local _lMail	:= .f.
	Local _nTotSC6	:= 0
	Local _cMens	:= " "
	Local _cMens1	:= " "
	Local _cMens2	:= " "
	Local _cMens3	:= " "   
	Local cAliasSD1	:= GetNextAlias()
	Local cQuery    := ""
	//Local _cFilial  := SC5->C5_FILIAL
	Local cPedido	:= SC5->C5_NUM
	//Local _cCliente := SC5->C5_CLIENTE
	//Local _cLoja    := SC5->C5_LOJACLI
	Local _cPedAnt  := SC5->C5_XREFATD
	Local n1    	:= 1 //Everson - 14/09/2021. Chamado 17537. 	
	Local I			:= 1 //Everson - 14/09/2021. Chamado 17537. 	

	if !Supergetmv("MV_X410DEL",,.F.)

		If cEmpAnt <> "01" .Or. IsInCallStack("U_PED001B") //Alterado por Adriana devido ao error.log quando empresa <> 01 - chamado 032804 //Everson - 14/09/2021. Chamado 17537.
			RestArea(aArea) //Everson - 14/09/2021. Chamado 17537.
			Return(.t.)

		EndIf     

		//ticket 8      - Abel Babini  - 01/03/2021 - N�o limpar flag dos registros e chamar a rotina de libera��o de cr�dtio.
		//fPreAprv(_cFilial,cPedido,_cCliente,_cLoja)  //&&funcao pra limpeza de flag de pre aprovacao de pedidos de venda.
		//StaticCall(M410STTS,fLibCred, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR, .T., SC5->C5_FILIAL+SC5->C5_NUM)
		fLibCred(SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR, .T., SC5->C5_FILIAL+SC5->C5_NUM)
		//&&Mauricio - Chamado 037330 - 07/10/17 - limpo nr pedido na exclus�o de um pedido
		IF !Empty(_cPedAnt)
			AltPedOr(_cPedAnt,cPedido)
		Endif   

		If !lSfInt .And. SC5->C5_UFPLACA <> "99" //&&12/10/16 - Flag para pedido excluido por rotina ADFIN006P/ADFIN018P

			DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A Cr�dito -  Motivo do Bloqueio" PIXEL
			@  1, 3 	TO 28, 242 OF oDlg  PIXEL
			If File("adoro.bmp")
				@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL
				oBmp:lStretch:=.T.
			EndIf
			@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg PIXEL
			@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg PIXEL Valid !Empty(cMotivo)
			DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg
			//DEFINE SBUTTON FROM 16,246 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg //fernando sigoli 28/04/2017

			ACTIVATE MSDIALOG oDlg CENTERED

			If nOpt == 1                                                                            
				_lMail	:= .T.
				lRet 		:= .T.
			Else
				return(lRet)
			Endif

		Else
			lRet := .T.	
		Endif

		If _lMail .Or. lSfInt

			_cMens1 := '<html>'
			_cMens1 += '<head>'
			_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
			_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
			_cMens1 += '<title>Pedido Bloqueado</title>'
			_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
			_cMens1 += '</head>'
			_cMens1 += '<body bgcolor="#C0C0C0">'
			_cMens1 += '<center>'
			_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
			_cMens1 += '<tr height="80">'
			_cMens1 += '<td width="100%" height="80" background="http://www.adoro.com.br/microsiga/pedido_bloq.jpg">&nbsp;</td>'
			_cMens1 += '</tr>'
			_cMens1 += '</center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%" bgcolor="#386079">'
			_cMens1 += '<div align="left">'
			_cMens1 += '<table border="1" width="100%">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
			_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+SC5->C5_NUM+'</font></b>'
			_cMens1 += '</td></tr>'
			_cMens1 += '</table>'
			_cMens1 += '</div>'
			_cMens1 += '</td>'
			_cMens1 += '</tr>' 
			_cMens1 += '<center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%">'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">Cod.Cliente:</font></td>'
			_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CLIENTE+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="25" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Loja:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_LOJACLI+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="36" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Nome:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_NOMECLI+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="8%" bgcolor="#FAA21B"><font face="Arial" size="1">Endere�o:</font></td>'
			_cMens1 += '<td width="41%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ENDERE+'</font></td>'
			_cMens1 += '<td width="4%" bgcolor="#FAA21B"><font face="Arial" size="1">Bairro:</font></td>'
			_cMens1 += '<td width="17%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_BAIRRO+'</font></td>'
			_cMens1 += '<td width="5%" bgcolor="#FAA21B"><font face="Arial" size="1">Cidade:</font></td>'
			_cMens1 += '<td width="40%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CIDADE+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<center><table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="6%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Roteiro:</font></td>'
			_cMens1 += '<td width="44%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ROTEIRO+'</font></td>'
			_cMens1 += '<td width="7%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Sequ�ncia:</font></td>'
			_cMens1 += '<td width="43%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_SEQUENC+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="170" bgcolor="#FAA21B"><font face="Arial" size="1">Condi��o de Pagamento:</font></td>'
			_cMens1 += '<td width="81" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CONDPAG+'</font></td>'
			_cMens1 += '<td width="84" bgcolor="#FAA21B"><font face="Arial" size="1">Vencimento:</font></td>'
			_cMens1 += '<td width="168" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DATA1)+'</font></td>'
			_cMens1 += '<td width="46" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Emiss�o:</font></td>'
			_cMens1 += '<td width="393" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DTENTR)+'</font></td>'
			_cMens1 += '</tr>'
			_cMens1 += '</table>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="7%" bgcolor="#FAA21B">'
			_cMens1 += '<p align="center"><font size="1" face="Arial">Vendedor:</font></p>'
			_cMens1 += '</td>'
			_cMens1 += '<td width="12%" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_VEND1+'</font></p>'
			_cMens1 += '</td>'
			_cMens1 += '<td width="15%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Carteira:</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="66%" bgcolor="#FFFFFF">'
			DBSelectArea("SA3")
			DBSetOrder(1)
			DBSeek(XFilial("SA3")+SC5->C5_VEND1)
			_cMens1 += '<p align="left"><font face="Arial" size="1">'+UPPER(ALLTRIM(SA3->A3_NOME))+'</font></p>'
			_cMens1 += '</td></tr></table><center>'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="982%" bgcolor="#FAA21B">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">Motivo</font></td>'
			_cMens1 += '</tr><tr>'
			_cMens1 += '<td width="982" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+cMotivo+'</font></b></p>'
			_cMens1 += '</tr>'
			_cMens1 += '</table></center>'
			_cMens1 += '<table border="1" cellpadding="0" cellspacing="2" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td align="center" bgcolor="#FAA21B" width="1468" colspan="9">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">Itens do Pedido</font></td>'
			_cMens1 += '</tr></center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="14" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Item</b></font></td>'
			_cMens1 += '<td width="50" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Produto</b></font></td>'
			_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descri��o</b></font></td>'
			_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
			_cMens1 += '<td width="283" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Opera��o</b></font></p></td>'
			_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
			_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
			_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unit�rio</b></font></td>'
			_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
			_cMens1 += '</tr>'

			/*
			DBSelectArea("SC6")
			DBSetOrder(1)
			DbSeek(XFilial("SC6")+SC5->C5_NUM)
			WHILE SC6->C6_NUM == SC5->C5_NUM
			_cMens2 += '<tr>'
			_cMens2 += '<td width="14" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC6->C6_ITEM+'</font></td>'
			_cMens2 += '<td width="50" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_PRODUTO+'</font></td>'
			_cMens2 += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_DESCRI+'</font></td>'
			_cMens2 += '<td width="57" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_TES+'</font></p></td>'
			_cMens2 += '<td width="283" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+SC6->C6_TES,"F4_TEXTO")+'</font></td>'
			_cMens2 += '<td width="42" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_UM+'</font></p></td>'
			_cMens2 += '<td width="91" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDVEN,"@!")+'</font></p></td>'
			_cMens2 += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</font></p></td>'
			_cMens2 += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_VALOR,"@E 999,999,999.99")+'</font></p></td>'
			_cMens2 += '</tr>'
			_nTotSC6 += SC6->C6_VALOR
			DBSKIP()
			END
			*/
			If Len(aCols) > 0 .And. !lSfInt

				nItem 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_ITEM" } )
				nProduto := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
				nDescri 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_DESCRI" } )
				nTes 		:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_TES" } )
				nUM 		:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_UM" } )
				nQTDVEN 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_QTDVEN" } )
				nPRCVEN 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRCVEN" } )
				nVALOR 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_VALOR" } )

				For n1 := 1 to Len(aCols)
					_cMens2 += '<tr>'
					_cMens2 += '<td width="14" bgcolor="#FFFFFF"><font face="Arial" size="1">'+aCols[n1,nITEM]+'</font></td>'
					_cMens2 += '<td width="50" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nPRODUTO]+'</font></td>'
					_cMens2 += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nDESCRI]+'</font></td>'
					_cMens2 += '<td width="57" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nTES]+'</font></p></td>'
					_cMens2 += '<td width="283" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+aCols[n1,nTES],"F4_TEXTO")+'</font></td>'
					_cMens2 += '<td width="42" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nUM]+'</font></p></td>'
					_cMens2 += '<td width="91" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nQTDVEN],"@!")+'</font></p></td>'
					_cMens2 += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nPRCVEN],"@E 999,999,999.99")+'</font></p></td>'
					_cMens2 += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nVALOR],"@E 999,999,999.99")+'</font></p></td>'
					_cMens2 += '</tr>'
					_nTotSC6 += aCols[n1,nVALOR]
				Next n1 
			Endif

			_cMens3 := '<tr>'
			_cMens3 += '<td width="1325" bgcolor="#386079" colspan="8">'
			_cMens3	+= '<p align="right"><font face="Arial" size="1" color="#FFFFFF"><b>TOTAL DO PEDIDO</b></font></td>'
			_cMens3	+= '<td width="263" bgcolor="#FFFFFF"><font face="Arial" size="1">'+TRANSFORM(_nTotSC6,"@E 999,999,999.99")+'</font></td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '</table>'
			_cMens3	+= '</td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '<center>'
			_cMens3	+= '<tr>'
			_cMens3	+= '<td width="100%" bgcolor="#386079" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
			_cMens3	+= '<p align="center">'
			_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Inform�tica</b></font>'
			_cMens3	+= '</p>'
			_cMens3	+= '</td>'
			_cMens3	+= '</tr>'
			_cMens3	+= '</table>'
			_cMens3	+= '</center>'
			_cMens3	+= '</body>'
			_cMens3	+= '</html>'
			DBSelectAreA("SZD")
			RecLock("SZD",.t.)
			ZD_FILIAL := SC5->C5_FILIAL
			ZD_CODCLI := SC5->C5_CLIENTE
			ZD_NOMECLI := SC5->C5_NOMECLI
			ZD_AUTNOME := UPPER(SUBSTR(CUSUARIO,7,15))
			ZD_RESPONS := "33"
			ZD_RESPNOM := "CREDITO"
			ZD_PEDIDO  := SC5->C5_NUM
			ZD_ROTEIRO := SC5->C5_ROTEIRO
			ZD_SEQUENC := SC5->C5_SEQUENC
			ZD_OBS1    := UPPER(cMotivo)
			ZD_VEND    := SC5->C5_VEND1
			ZD_LOJA    := SC5->C5_LOJACLI
			ZD_DEVTOT  := 'O'
			ZD_DTDEV   := ddatabase
			MsUnlock()
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
			_eMailVend := SA3->A3_EMAIL

			DbSelectArea("SZR")
			DbSetOrder(1)
			DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
			_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))

			IF !Empty(Getmv("mv_mailtst"))
				cEmail := Alltrim(Getmv("mv_mailtst"))
			ELSE
				cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))+';'+Alltrim(GetMv("mv_emails2"))	// Em 23/02/2016 incluido o par�metro MV_EMAILS2 - CHAMADO 026668 - WILLIAM COSTA
			ENDIF


			_cMens := _cMens1+_cMens2+_cMens3
			_cData := transform(MsDate(),"@!")
			_cHora := transform(Time(),"@!")  
			
			If !lSfInt
				lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+SC5->C5_NUM+" ,PEDIDO EXCLU�DO - "+_cData+" - "+_cHora,"")	//Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM		
			
				If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> ""
					U_ADVEN050P("",.F.,.T., " AND C5_NUM IN ('" + Alltrim(cValToChar(SC5->C5_NUM)) + "') AND C5_XPEDSAL <> '' " , .F. )
			
				EndIf
				
			Else
				
				lRet := .T.
			
			EndIf
			
		Endif


		//+-----------------------------------------+
		//|Nao consegui enviar o e-mail vou exibir  |
		//|o resultado em tela                      |
		//+-----------------------------------------+                                                                                                          
		If !lRet 
			ApMsgInfo("Nao foi poss�vel o Envio do E-mail.O E-mail ser� impresso em "+;
			"Tela e o registro ser� processado. "+;
			"Poss�veis causas podem ser:  Problemas com E-mail do destinat�rio "+;
			"ou  no servi�o interno de E-mail da empresa.","Erro de Envio")
			//+---------------------------------+
			//|Montando arquivo de Trabalho     |
			//+---------------------------------+	
			_aFile:={}
			AADD(_aFile,{"LINHA","C",1000,0})    
			_cNom := CriaTrab(_aFile)
			dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)		
			DbSelectArea("TRB")

			//+----------------------------------+
			//|Montando o Texto em TRB           |
			//+----------------------------------+	

			TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"�"))+"�"  
			TEXTO :=''
			For I:=0 to LEN(TxtNew)
				// Pego o proximo bloco
				TEXTO+=SUBSTR(TxtNew,1,1)	
				// Exclui o caracter posicionado
				TxtNew:=STUFF(TxtNew,1,1,"")	
				If 	LEN(TEXTO)>=200 	//txt=="�" .or. _nTamLin > limite			
					TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
					RecLock("TRB",.t.)
					Replace TRB->LINHA With TEXTO 
					MsUnlock()
					TEXTO:=""							
				Endif
			Next

			//+-------------------------+
			//|Copiando para Arquivo    |
			//+-------------------------+

			DbSelectArea("TRB")    	
			//COPY to &"c:\"+_cNom+".html" SDF  
			cPath := GetSrvProfString("StartPath","")+"PED_EXC\"
			COPY to &cPath+_cNom+".html" SDF	

			TRB->(DbCloseArea())

			//ShellExecute('open',"c:\"+_cNom+".html",'','',1)
			ShellExecute('open',cPath+_cNom+".html",'','',1)

		Endif


		//���������������������������������������������A�
		//�INICIO TRATAMENTO PEDIDO TRANSPORTADOR CCSKF�
		//���������������������������������������������A�

		//cQuery := " SELECT SD1.R_E_C_N_O_ AS REC "
		//cQuery += " FROM "+ RetSqlName("SD1") +" SD1, "+ RetSqlName("SC6") +" SC6 " 
		//cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' AND SC6.C6_NUM = '" + cPedido + "' AND SC6.D_E_L_E_T_ = '*' "
		//cQuery += " AND SD1.R_E_C_N_O_ = SC6.C6_XRECSD1 AND SC6.C6_XRECSD1<> 0 AND SD1.D_E_L_E_T_ = ' ' "
		// RICARDO LIMA - 16/01/18
		cQuery := " SELECT SD1.R_E_C_N_O_ AS REC " 
		cQuery += " FROM "+ RetSqlName("SD1") +" (NOLOCK) SD1 "
		cQuery += " INNER JOIN "+ RetSqlName("SC6") +" (NOLOCK) SC6 ON SD1.R_E_C_N_O_ = SC6.C6_XRECSD1 AND SC6.C6_XRECSD1<> 0 AND SC6.D_E_L_E_T_ = '*' "
		cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' "
		cQuery += " AND SC6.C6_NUM = '" + cPedido + "' "
		cQuery += " AND SD1.D_E_L_E_T_ = ' ' "

		If Select(cAliasSD1) > 0
			(cAliasSD1)->(dbCloseArea())
		EndIf

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
		dbSelectArea(cAliasSD1)

		(cAliasSD1)->(dbGoTop())

		While (cAliasSD1)->(!Eof())

			SD1->(DbSetOrder(1))
			SD1->(DbGoTo((cAliasSD1)->(REC)))
			RecLock("SD1",.F.)		        
			Replace SD1->D1_XPVDEV With ' '
			MsUnLock("SD1")
			(cAliasSD1)->(dbSkip())
		Enddo

		(cAliasSD1)->(dbCloseArea())     

		//���������������������������������������������A�
		//�FIM TRATAMENTO PEDIDO TRANSPORTADOR - CCSKF�
		//���������������������������������������������A�
		RestArea(aArea) //Everson - 14/09/2021. Chamado 17537. 
	ENDIF

Return(.t.)

//&&21/10/16 - funcao para pre aprovacao.
// Static function fPreAprv(_cFilial,cPedido,_cCliente,_cLoja) 
// 	DbSelectArea("SC5")
// 	_cASC5 := Alias()
// 	_cOSC5 := IndexOrd()
// 	_cRSC5 := Recno()

// 	//&&Verifico se eh rede ou varejo...
// 	dbSelectArea("SA1")
// 	dbSetOrder(1)
// 	dbGoTop()
// 	If dbSeek(xFilial("SA1")+_cCliente+_cLoja)
// 		dbSelectArea("SZF")
// 		dbSetOrder(1)
// 		dbGoTop()
// 		If dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))  //&&REDE
// 			//Limpo flag de pedidos relativos a Rede....aonde no caso n�o ha como filtrar data de entrega, cliente e pedidos utilizados...limpo todos.

// 			If Select("LSC5") > 0
// 				DbSelectArea("LSC5")
// 				LSC5->(DbCloseArea())
// 			Endif

// 			/*_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
// 			_cQuery += " WHERE  C5_NOTA = ''  AND C5_CLIENTE NOT IN ('031017','030545') "
// 			_cQuery += " AND C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA"
// 			_cQuery += " AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' AND LEFT(A1_CGC,8) = ZF_CGCMAT "      
// 			_cQuery += " AND C5.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' " */

// 			_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM " 
// 			_cQuery += "FROM "+RetSqlName("SC5")+" C5 "
// 			_cQuery += "INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.A1_COD=C5.C5_CLIENTE AND A1.A1_LOJA=C5.C5_LOJACLI AND A1.D_E_L_E_T_= ' ' "
// 			_cQuery += "INNER JOIN "+RetSqlName("SZF")+" ZF ON LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.D_E_L_E_T_ = ' ' "
// 			_cQuery += "WHERE C5_CLIENTE NOT IN ('031017','030545') AND C5_NOTA = ' ' AND C5.D_E_L_E_T_ = ' ' "  
// 			_cQuery += "AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' "

// 			TCQUERY _cQuery new alias "LSC5"	

// 			DbSelectArea ("LSC5")
// 			LSC5->(dbgotop())
// 			Do While LSC5->(!EOF())
// 				DbSelectArea("SC5")
// 				DbSetOrder(1)
// 				If dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM)
// 					if Reclock("SC5",.F.)
// 						SC5->C5_XPREAPR := " "
// 						SC5->(Msunlock())
// 					endif
// 				Endif	         
// 				LSC5->(DbSkip())
// 			Enddo

// 			LSC5->(DbcloseArea())

// 		Else  //&&eh varejo
// 			if Reclock("SC5",.F.)
// 				SC5->C5_XPREAPR := " "
// 				SC5->(Msunlock())
// 			endif   
// 		Endif
// 	Endif

// 	dbSelectArea(_cASC5)
// 	dbSetOrder(_cOSC5)
// 	dbGoto(_cRSC5)
// Return()

Static function AltPedOr(_cPedAnt,_cNumPed)
	DbSelectArea("SC5")
	_SC5cAlias := Alias()
	_SC5cOrder := IndexOrd()
	_SC5cRecno := Recno()
	_cPeds := ""

	if dbseek(xFilial("SC5")+_cPedAnt)
		_cPedold := SC5->C5_XPEDGER
		If _cNumPed $ _cPedold
			_nPSUBS   := AT(_cNumPed,_cPedold)
			IF _nPSUBS == 1
				_cPedNew  := Substr(_cPedold,_nPSUBS + 7,Len(_cPedold))
			else   
				_cPedNew  := Substr(_cPedold,1,_nPSUBS - 2)+Substr(_cPedold,_nPSUBS + 6,Len(_cPedold))
			endif
			RecLock("SC5",.F.)
			SC5->C5_XPEDGER := _cPedNew  //&&somente limpo, nao gravo atual. Gravacao eh por outro ponto de entrada
			SC5->(MsUnlock())
		Endif
	endif

	dbSelectArea(_SC5cAlias)
	dbSetOrder(_SC5cOrder)
	dbGoto(_SC5cRecno)

Return()
/*/{Protheus.doc} chkOrdSC6
    Verifica se h� ordem de pesagem vinculada ao item do pedido de venda.
	Chamado 18465.
    @type  User Function
    @author Everson
    @since 24/03/2022
    @version 01
/*/
Static Function chkOrdSC6(_nOper, cNumPed)

	//Vari�veis.
	Local aArea := GetArea()
	Local lRet	:= .F.
	Local cQuery:= ""

	cQuery += " SELECT  " 
	cQuery += " C6_XORDPES " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 " 
	cQuery += " WHERE " 
	cQuery += " C6_FILIAL = '" + FWxFilial("SC6") + "' " 
	cQuery += " AND C6_NUM = '" + cNumPed + "' " 
	cQuery += " AND C6_XORDPES <> '' " 

	If _nOper <> 5
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 

	EndIf

	If Select("D_VLDORD") > 0
		D_VLDORD->(DbCloseArea())

	EndIf 

	TcQuery cQuery New Alias "D_VLDORD"
	DbSelectArea("D_VLDORD")
	D_VLDORD->(DbGoTop())

		lRet := ! D_VLDORD->(Eof())

	D_VLDORD->(DbCloseArea())

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
	Chamado 18465.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function grvBarr(nOper, cNumero)

    //Vari�veis.
    Local aArea     := GetArea()
	Local cOperacao	:= ""
	Local cFilter	:= ""

	If nOper == 3
		cOperacao := "I"

	ElseIf nOper == 4
		cOperacao := "A"

	ElseIf nOper == 5
		cOperacao := "D"

	Else
		RestArea(aArea)
		Return Nil

	EndIF

	cFilter := " C6_FILIAL ='" + FWxFilial("SC6") + "' .And. C6_NUM = '" + cNumero + "' "
	
    U_ADFAT27D("SC5", 1, FWxFilial("SC5") + cNumero,;
            "SC6", 1, FWxFilial("SC6") + cNumero, "C6_ITEM",cFilter,;
            "pedidos_de_saida_protheus", cOperacao,;
            .T., .T.,.T., Nil)

	RestArea(aArea)

Return Nil
