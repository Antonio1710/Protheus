#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnalisPed ºAutor  ³Mauricio da Silva   º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±|Desc.     ³ Rotina desenvolvida para liberação dos pedidos de cliente  º±±
±±|          ³ tipo rede. (A ser efetuado no final do dia)                º±±
±±|ÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Paulo-TDS ³12/05/11 - Pequenos ajustes para testes iniciais            º±±
±±³Mauricio  ³21/06/11 - Alterado rotina para quebra por carteira confor- º±±
±±³          ³         - me solicitado por Vagner em 21/06/11(email)      º±±
±±|ÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Fernando  | 30/09/2019 Chamado:052215 Tratamento Query para nao trazer º±±
±±³          | Pedidos ja faturados ou que nao tenha codigo de rede no PV º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/********************************************************************************************************************************

Ao efetuar alterações neste fonte, checar o fonte ADVEN052P, pois o serviço Rest o utiliza para efetuar liberações de pedidos.

*********************************************************************************************************************************/

User Function AnalisPed()

	Local _cUsuHab  := GETMV("MV_VLPEDRD")  // Usuarios que podem utilizar a rotina de validação/analise de pedidos de rede.

	// Variáveis incluídas para pesquisa por data de entrega - Paulo - TDS - 11/05/2011
	Local lRet 	 := .F.
	Private dDtIni := CtoD(Space(08))
	Private dDtFim := CtoD(Space(08))
	Private oDtIni
	Private oDtFim
	Private oDlg01
	Private oFont1 
	Private aCombo1  := {}
	Private cCombo1  := Space(1)
	Private oCombo1  := Nil
	Private nCombo1  := 1
	Private _nFrete  := 0,_nPrcDig := 0,_nPrDigL := 0,_nPrcTab := 0
	Private _nPrTabL := 0,_nPrPerT := 0,_nPrDigT := 0,_nValMax := 0
	Private _nPrPerTV := 0,_nPrPerTS := 0,_nPrPerTG := 0,_nPrPerTD := 0
	Private _nPreTabS := 0,_nPreLiqS := 0,_nValorNF := 0
	Private _nIpProd := 0,_nIpTot  := 0,_nDesconto := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida para liberação dos pedidos de cliente tipo rede. (A ser efetuado no final do dia)')

	aAdd( aCombo1, "Estadual" )
	aAdd( aCombo1, "KA Estadual" )
	aAdd( aCombo1, "Interestadual RJ" )
	aAdd( aCombo1, "Interestadual Outros" )

	// Verifica se o usuário está habilitado a executar a rotina
	If !(__cUserID $ _cUsuHab)
		ApMsgInfo(OemToAnsi("Voce não tem permissão para executar esta rotina"),OemToAnsi(" A T E N Ç Ã O "))
		Return()
	EndIf

	// Inicio do processo da análise dos pedidos da rede informando o período de entrega
	Define msDialog oDlg01 From 00,00 To 220,370 Title "Análise de Pedidos da Rede" Pixel &&145
	Define Font oFont1 Name "Arial" Size 0,-14 Bold
	@005,005 To 045,180 of oDlg01 Pixel
	@010,020 Say "Este programa tem como objetivo fazer a" 	Font oFont1 of oDlg01 Pixel
	@020,020 Say "análise de pedidos da rede, conforme o " Font oFont1 of oDlg01 Pixel
	@030,020 Say "periodo e carteira especificados abaixo."		        Font oFont1 of oDlg01 Pixel
	@050,005 Say "Data Inicial"	 	                        Font oFont1 of oDlg01 Pixel
	@050,050 MsGet oDtIni Var dDtIni Valid(!Empty(dDtIni)) Size 40,10 Font oFont1 Of oDlg01 Pixel  &&25
	@070,005 Say "Data Final"	 	                        Font oFont1 of oDlg01 Pixel
	@070,050 MsGet oDtFim Var dDtFim Valid(!Empty(dDtFim)) Size 40,10 Font oFont1 Of oDlg01 Pixel  &&25

	@090,005 SAY "Considera: " Font oFont1 of oDlg01 Pixel
	@090,050 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 PIXEL OF oDlg01 on change nCombo1 := oCombo1:nAt

	@070,115 BmpButton Type 1 Action(lRet := .T.,Close(oDlg01))
	@070,150 BmpButton Type 2 Action(lRet := .F.,Close(oDlg01))
	Activate Dialog oDlg01 Centered

	If lRet

		If !Empty(dDtIni) .And. !Empty(dDtFim)
			If MsgYesNo(OemToAnsi("Confirma inicio da análise dos pedidos de Rede em aberto de " + DtoC(dDtIni) + " a "+DtoC(dDtFim) +" ?"),OemToAnsi("A T E N Ç Ã O"))
				Processa({|| AnPedRd()},OemToAnsi("Analisando os Pedidos da Rede"))
			EndIf
		Else
			MsgAlert(OemToAnsi("O preechimento da data é obrigatório!"),OemToAnsi("A T E N Ç Ã O"))
		EndIf

	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ANPEDRD   ºAutor  ³Mauricio da Silva   º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa a análise dos pedidos feitos para REDE             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico A'DORO                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AnPedRd()

	Local cQuery     := "",cQuery4 := "",cQuery6 := ""
	Local _cRede     := "",_cPedido := ""
	Local _nPrcTotD  := 0,_nPrcTotT := 0,_nValMaxG := 0,_nValMaxD := 0
	Local _cTabela 	 := "",_cRepresent := "",_cSupervi := "",_cGerente := "",_cDiretor := ""  
	Local cConsidera := ""

	Private _lGer    := .F.
	Private _lDir    := .F.
	Private _lSup    := .F.
	Private _lVen    := .F.
	Private _lZero   := .F.
	Private lLiber	 := .F.
	Private	lTrans	 := .F.
	Private	lCredito := .F.
	Private	lEstoque := .F.
	Private	lAvCred	 := .T.
	Private	lAvEst	 := .F.  //.T. Mauricio 26/07/11.

	ProcRegua(RecCount())

	/*
	Seleciona todos os pedidos REDE em aberto para analise de validação/bloqueio daquele dia.
	Já retorna a REDE por produto consolidado.
	Verificar se vai utilizar por filial ou nao.
	*/ 
	&&tratamento original antes alteração de 21/06/11...
	//cQuery := "SELECT C5_CODRED AS REDE, SUM(C5_PESOL) AS TOTPES, SUM(C5_TOTDIG) AS TOTDIG, "
	//cQuery += "       SUM(C5_TOTTAB) AS TOTTAB "
	//cQuery += "FROM "+RetSqlName("SC5")+" SC5 "
	//cQuery += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
	//cQuery += "      C5_XREDE = 'S' AND "
	//cQuery += "      SC5.C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_XLIBERA = ' ' AND "
	//cQuery += "      SC5.C5_EMISSAO > '"+Dtos(GetMv("MV_DTATR"))+"' AND SC5.D_E_L_E_T_ = ' ' "
	//cQuery += "GROUP BY C5_CODRED "
	//cQuery += "ORDER BY C5_CODRED "

	&&Mauricio 07/12/11 - alterado logica da rotina, para trabalhar com faixa de volume, e sendo assim primeiro preciso apurar todos os pedidos da rede, efetuar
	&&os calculos e gravações necessarias na SC5 e na SC6 e depois efetuar a analise como era feita anteriormente.
	&&IMPORTANTE **** TODAS AS QUERYS DAQUI PARA BAIXO DEVEM ESTAR COMPATIBILIZADAS PELA MESMA REGRA *****
	&&Primeiro busco o total de caixas e pedidos por rede
	IF SELECT("TOTR") > 0
		DbSelectArea("TOTR")
		DbCloseArea("TOTR")
	Endif  
	cQuery := "SELECT C5_CODRED AS REDE, COUNT(DISTINCT C5_NUM) AS TOTPED, SUM(C6_UNSVEN) AS TOTCXS "
	cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SC6")+" SC6 "
	cQuery += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
	cQuery += "      C5_XREDE  = 'S' AND "
	cQuery += "      C5_CODRED <> '' AND C5_NOTA = '' AND " //fernando sigoli 30/09/2019 - Chamado: 052215

	cQuery += "      C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

	cQuery += "      SC5.C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_XLIBERA = ' ' AND "
	cQuery += "      SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL AND"
	cQuery += "      SC5.C5_VEND1 = SA3.A3_COD AND "
	if nCombo1 == 1   &&estadual
		cQuery += " ((SA3.A3_COD BETWEEN '000001' AND '000120') OR (SA3.A3_COD BETWEEN '000130' AND '000135')) AND "
	elseif nCombo1 == 2
		cQuery += " SA3.A3_COD BETWEEN '000121' AND '000129' AND "               
	elseif nCombo1 == 3
		cQuery += " SA3.A3_COD BETWEEN '000136' AND '000165' AND "
	elseif nCombo1 == 4
		//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
		cQuery += " ((SA3.A3_COD BETWEEN '000166' AND '000380') OR (SA3.A3_COD = '000802')) AND "
	Endif    
	cQuery += "      SC5.C5_EMISSAO > '"+Dtos(GetMv("MV_DTATR"))+"' AND SC5.D_E_L_E_T_ = ' ' AND SA3 .D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' '"
	
	cQuery += "GROUP BY C5_CODRED "
	cQuery += "ORDER BY C5_CODRED "
	
	TCQUERY cQuery NEW ALIAS "TOTR"

	dbSelectArea("TOTR")
	dbGoTop()

	While TOTR->(!Eof())

		_nFrete  := 0
		_nPrcDig := 0
		_nPrDigL := 0
		_nPrcTab := 0
		_nPrTabL := 0
		_nPrPerT := 0
		_nPrDigT := 0
		_nValMax := 0
		_nPrPerTV := 0
		_nPrPerTS := 0
		_nPrPerTG := 0
		_nPrPerTD := 0
		_nPreTabS := 0
		_nPreLiqS := 0
		_nValorNF := 0
		_nIpProd := 0
		_nIpTot  := 0
		_nDesconto := 0


		_cRede    := TOTR->REDE    &&Rede
		_nQtdPed  := TOTR->TOTPED  &&Total de pedidos
		_nQTDCxs  := TOTR->TOTCXS  &&total de caixas
		_nTotalCx := _nQTDCxs/_nQtdPed  &&media para buscar tabela
		&&Agora vou buscar os pedidos de venda desta rede e efetuar os calculos necessários por pedido
		IF SELECT("TSC5") > 0
			DbSelectArea("TSC5")
			DbCloseArea("TSC5")
		Endif   
		cQuery := "SELECT C5_FILIAL, C5_NUM "
		cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA3")+" SA3 "
		cQuery += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
		cQuery += "      C5_XREDE = 'S' AND "  
		cQuery += "      C5_CODRED <> '' AND C5_NOTA = '' AND  " //fernando sigoli 30/09/2019 - Chamado: 052215

		cQuery += "      C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

		cQuery += "      SC5.C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_XLIBERA = ' ' AND "
		cQuery += "      SC5.C5_CODRED = '"+_cRede+"' AND"
		cQuery += "      SC5.C5_VEND1 = SA3.A3_COD AND "
		if nCombo1 == 1   &&estadual
			cQuery += " ((SA3.A3_COD BETWEEN '000001' AND '000120') OR (SA3.A3_COD BETWEEN '000130' AND '000135')) AND "
		elseif nCombo1 == 2
			cQuery += " SA3.A3_COD BETWEEN '000121' AND '000129' AND "               
		elseif nCombo1 == 3
			cQuery += " SA3.A3_COD BETWEEN '000136' AND '000165' AND "
		elseif nCombo1 == 4
			//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
			cQuery += " ((SA3.A3_COD BETWEEN '000166' AND '000380') OR (SA3.A3_COD = '000802')) AND "
		Endif    
		cQuery += "      SC5.C5_EMISSAO > '"+Dtos(GetMv("MV_DTATR"))+"' AND SC5.D_E_L_E_T_ = ' ' AND SA3 .D_E_L_E_T_ = ' ' "      
		cQuery += " ORDER BY C5_FILIAL, C5_NUM "
		
		TCQUERY cQuery NEW ALIAS "TSC5"

		DbSelectArea("TSC5")
		DbGotop()
		While TSC5->(!EOF())

			_nPrTabT  := 0
			_nPrDigT  := 0 
			_nPrPerT  := 0 
			_nPreTabS := 0
			_nPreLiqS := 0
			_nValorNF := 0

			_cNumPed := TSC5->C5_NUM &&compatibiliza parte vinda do M410STTS.
			&&aqui implemento tratamento(calculos) de rede vindo do M410STTS - Mauricio 07/12/11.            
			DbSelectArea("SC5")
			DbSetOrder(1)
			dbseek(TSC5->C5_FILIAL+TSC5->C5_NUM)
			_cTpFret := SC5->C5_TPFRETE    &&Mauricio 21/12/11 - Tratamento para valor do Frete CIF ou outros.

			&&vindo M410STTS - INICIO

			dbSelectArea("SA1")
			dbSetOrder(1)		
			If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

				_cEst	   := SA1->A1_EST      // estado do pedido
				_cMunic    := SA1->A1_COD_MUN  // Municipio do cliente do pedido
				_cRede     := SC5->C5_CODRED  // Rede a qual o cliente pertence
				_nDesconto := SA1->A1_DESC  &&Mauricio 08/06/11 - Conforme solic. Vagner durante processo validação mesmo a rede deve vir desconto
				&&do cadastro do cliente do pedido e nao mais da rede pai.			      

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+_cRede+"00")

				// Busco frete para Cliente
				_nFrete := 0
				_cRegiao := ""

				IF _cTpFret == "C"
					If !Empty(_cMunic)
						_cRegiao:= Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA") // Localizo a regiao do cliente
					EndIf

					If !Empty(_cRegiao)
						_nFrete := Posicione('ZZI',1,xFilial("ZZI")+_cRegiao,"ZZI_VALOR")       // Valor do frete para a regiao
					Else
						dbSelectArea("ZZI") // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
						dbSetOrder(3)
						dbSeek(_cEst)

						While !Eof() .And. ZZI->ZZI_ESTADO == _cEst					
							If _nFrete < ZZI->ZZI_VALOR
								_nFrete := ZZI->ZZI_VALOR
							EndIf					
							ZZI->(dbSkip())
						EndDo

					EndIf
				Else
					_nFrete := 0
				Endif   
				// Conforme Alex em 11/05/11(vagner) sera considerado sempre o representante amarrado ao SA1 da Rede.
				//_cRepresent := Posicione("SA1",1,xFilial("SA1")+_cRede,"A1_VEND")
				//_cTabela    := Posicione("SA1",1,xFilial("SA1")+_cRede,"A1_TABELA")
				If Select("TSA1") > 0
					DbSelectArea("TSA1")
					DbCloseArea("TSA1")
				Endif

				_cQueryZ := ""
				_cQueryZ += "SELECT A1_VEND, A1_TABELA FROM "+RetSqlName("SA1")+" SA1 "
				_cQueryZ += " WHERE SA1.A1_COD = '"+_cRede+"' AND SA1.A1_LOJA = '00' AND SA1.D_E_L_E_T_ = '' " 

				TCQUERY _cQueryZ NEW ALIAS "TSA1"
				dbSelectArea("TSA1")
				dbGoTop()
				if TSA1->(!Eof())
					_cRepresent := TSA1->A1_VEND
					_cTabela    := TSA1->A1_TABELA
				Else
					_cRepresent := "      "
					_cTabela    := "   "
				Endif   

				// Se não contiver a tabela cadastrada no cliente, o código da tabela será de acordo com o peso, inserido na tabela por faixa de pesos
				// Paulo - TDS - 18/05/2011
				&&Mauricio 07/12/11 - Retirado tratamento para tabela vinda do pedido. Tabela sera assumida pela faixa de Qtd. caixas que o pedido se
				&&encaixa (Usando tabela ZZP criada).
				//If Empty(M->C5_TABELA)

				dbSelectArea("ZZP")
				dbSetOrder(1)
				dbGoTop()

				While !Eof()
					//If _nTotalCx >= ZZP->ZZP_PESOI .And. _nTotalCx <= ZZP->ZZP_PESOF  ALEX BORGES - 05/03/12 - DEVERA BUSCAR A QUANTIDADE DE CAIXAS DA REDE.
					If _nQTDCxs >= ZZP->ZZP_PESOI .And. _nQTDCxs <= ZZP->ZZP_PESOF

						&&pega a tabela que se encaixa na faixa
						_cTabela := ZZP->ZZP_TABELA
						Exit
					EndIf
					ZZP->(dbSkip())
				EndDo

				//EndIf

				&&Mauricio - 07/12/11 - tratamento para caso não haver tabela cadastrada ou faixa de peso
				&&precisa ser analisado a posterior, para encontrar melhor alternativa de ação a ser tomada.
				If Empty(_cTabela)
					return()
				Else
					&&atualizo campo tabela no SC5
					reclock("SC5",.F.)
					SC5->C5_TABELA := _cTabela
					Msunlock()      
				Endif

				dbSelectArea("SA3")               // mudo posição no SA3 para trazer dados do representante da Rede e não do usuário que esta cadastrando.
				dbSetOrder(1)
				dbSeek(xfilial("SA3")+_cRepresent)

				dbSelectArea("DA0")
				dbSetOrder(1)
				dbSeek(xFilial("DA0")+_cTabela)

				// Mudar ou Não para pegar somente o representante/vendedor do cadastro SA1 da REDE principal

				If SA3->A3_NIVETAB == "2" 					  // supervisor
					_nValMax := 1-(DA0->DA0_XSUPER/100)        // percentual supervisor
				ElseIf SA3->A3_NIVETAB == "3" 					  // Gerente
					_nValMax := 1-(DA0->DA0_XGEREN/100)        // percentual gerente
				ElseIf SA3->A3_NIVETAB == "4"
					_nValMax := 1-(DA0->DA0_XDIRET/100)        // percentual diretor
				Else
					_nValMax := 1-(DA0->DA0_XVENDE/100)		  // percentual vendedor
				EndIf

				&&Mauricio 16/08/11 - incluido para nova solicitação Sr. Fernando 09/08/11.
				_nValMaxV := 1-(DA0->DA0_XVENDE/100)
				_nValMaxS := 1-(DA0->DA0_XSUPER/100)

				dbSelectArea("SC6")
				dbSetOrder(1)
				If dbSeek(xFilial("SC6")+_cNumPed)

					While SC6->C6_NUM == _cNumped .And. !Eof()

						_nPrcDig := SC6->C6_PRCVEN * (_nDesconto / 100) // Preço digitado no produto, incluído o desconto
						_nPrDigL := SC6->C6_PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
						_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

						dbSelectArea("DA1")
						dbSetOrder(1)

						If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
							_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
							_nPrPerm := _nPrcTab * _nValMax 		// Preco minimo permitido para o usuario
							_nVlTotT := SC6->C6_QTDVEN * _nPrPerm
							_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab   &&Mauricio 28/09/11 - Alterado para considerar o preco da tabela bruta no calculo
							_nIpProd := _nVlTotD/_nVlTotT2 //_nVlTotT&&do IPTAB conforme informações Sr. Alex.

							&&Mauricio 16/08/11 - implementando sistematica de alteraçoes solicitadas em 10/08/11 - email Sr. Alex.
							_nPrPermV := _nPrcTab * _nValMaxV
							_nPrPermS := _nPrcTab * _nValMaxS

							_nPBTTV  := SC6->C6_PRCVEN    &&preco digitado
							_nPLTTV  := _nPrDigL          &&preco liquido
							_nPLTVD  := _nPrPermV         &&preco minimo vendedor
							_nPLTSV  := _nPrPermS  &&preco minimo supervisor

							dbSelectArea("SC6")
							RecLock("SC6",.F.)
							SC6->C6_XIPTAB := Round(_nIpProd,3)
							SC6->C6_TOTDIG := _nVlTotD    
							SC6->C6_TOTTAB := _nVlTotT2 //_nVlTotT  &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.    
							SC6->C6_PRTABV := _nPrPerm + _nFrete && Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
							SC6->C6_PBTTV  := _nPBTTV
							SC6->C6_PLTTV  := _nPLTTV
							SC6->C6_PLTVD  := _nPLTVD
							SC6->C6_PLTSP  := _nPLTSV
							SC6->C6_PLTAB  := _nPrcTab
							MsUnLock()

							_nPrDigT += _nVlTotD  // Soma dos preços líquidos digitados
							_nPrPerT += _nVlTotT  // Soma dos preços das tabelas
							_nPrTabT += _nVlTotT2  &&Mauricio 28/09/11 - Alterado para considerar o preco da tabela bruta no calculo

							_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   &&Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e não unitario conf. Sr. Alex
							_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   &&Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e não unitario conf. Sr. Alex
							_nValorNF += SC6->C6_VALOR
						EndIf

						dbSelectArea("SC6")
						SC6->(dbSkip())

					EndDo

					//_nIpTot := _nPrDigT/_nPrPerT   &&Mauricio 28/09/11 - Alterado para considerar o preco da tabela no calculo				
					_nIpTot := _nPrDigT/_nPrTabT

					RecLock("SC5",.F.)
					SC5->C5_FRETAPV := _nFrete   &&Mauricio 16/11/11.
					SC5->C5_XIPTAB  := Round(_nIpTot,3)
					SC5->C5_CODRED  := _cRede          // Grava codigo da rede utilizado na rotina ANALISPED.
					SC5->C5_TOTTAB  := _nPrTabT        //_nPrPerT  &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.
					SC5->C5_TOTDIG  := _nPrDigT
					SC5->C5_DESCTBP := _nPreTabS - _nPreLiqS
					SC5->C5_VALORNF := _nValorNF
					SC5->(MsUnLock())
				Endif	
			EndIf
			&&Vindo M410STTS _ FIM
			TSC5->(dbskip())
		Enddo
		DbcloseArea("TSC5")
		TOTR->(dbSkip())
	Enddo      

	&&Mauricio 09/12/11 - daqui para a frente continua normalmente o processo anterior testado e validado.                                 
	&&novo tratamento conforme solicitado pelo Sr. Vagner em 21/06/11(email)
	cQuery := "SELECT C5_CODRED AS REDE, SUM(C5_PESOL) AS TOTPES, SUM(C5_TOTDIG) AS TOTDIG, "
	cQuery += "       SUM(C5_TOTTAB) AS TOTTAB "
	cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
	cQuery += "      C5_XREDE = 'S' AND "
	cQuery += "      C5_CODRED <> '' AND C5_NOTA = '' AND  " //fernando sigoli 30/09/2019 - Chamado: 052215
	
	cQuery += "      C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

	cQuery += "      SC5.C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_XLIBERA = ' ' AND "
	cQuery += "      SC5.C5_CODRED = SA1.A1_COD AND SA1.A1_LOJA = '00' AND "
	cQuery += "      SC5.C5_VEND1 = SA3.A3_COD AND "
	if nCombo1 == 1   &&estadual
		cQuery += " ((SA3.A3_COD BETWEEN '000001' AND '000120') OR (SA3.A3_COD BETWEEN '000130' AND '000135')) AND "
	elseif nCombo1 == 2
		cQuery += " SA3.A3_COD BETWEEN '000121' AND '000129' AND "               
	elseif nCombo1 == 3
		cQuery += " SA3.A3_COD BETWEEN '000136' AND '000165' AND "
	elseif nCombo1 == 4
		//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
		cQuery += " ((SA3.A3_COD BETWEEN '000166' AND '000380') OR (SA3.A3_COD = '000802')) AND "
	Endif   
	cQuery += "      SC5.C5_EMISSAO > '"+Dtos(GetMv("MV_DTATR"))+"' AND SC5.D_E_L_E_T_ = ' ' AND SA3 .D_E_L_E_T_ = ' ' AND SA1 .D_E_L_E_T_ = ' '"
	cQuery += "GROUP BY C5_CODRED "
	cQuery += "ORDER BY C5_CODRED "
	
	TCQUERY cQuery NEW ALIAS "TREDE"
	dbSelectArea("TREDE")
	dbGoTop()

	While !Eof() // Inicio do calculo do IPTAB por rede.

		IncProc(" Rede : "+TREDE->REDE )

		_cRede    := TREDE->REDE           // codigo da rede
		_nPrcTotD := _nPrcTotT := 0 
		_lVen     := .F.
		_lSup     := .F.
		_lGer     := .F.
		_lDir     := .F.

		While _cRede == TREDE->REDE .And. !Eof()
			_nPrcTotD += TREDE->TOTDIG           // total do preco liquido digitado no pedido de venda
			_nPrcTotT += TREDE->TOTTAB           // total do preco liquido pela tabela de preco
			TREDE->(dbSkip())
		EndDo
		//MSGALERT("passei a primeira query")
		// pego aqui o percentual permitido para a REDE/USUARIO, mas preciso de confirmação ja que rede podem ser varios usuarios e com "poderes"
		// diferentes(tipo um ser vendedor,outro Gerente, etc...).Conforme Vagner deve ser o vendedor do cadastro SA1 da REDE

		_cTabela    := Posicione("SA1",1,xFilial("SA1")+_cRede+"00","A1_TABELA")
		_cRepresent := Posicione("SA1",1,xFilial("SA1")+_cRede+"00","A1_VEND")
		_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprovação
		_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
		_cGerent    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_GEREN")        // gerente para aprovação
		_cGerente   := Posicione("SA3",1,xFilial("SA3")+_cGerent,"A3_CODUSR")
		_cDireto    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_XDIRET")       // diretor para aprovação
		_cDiretor   := Posicione("SA3",1,xFilial("SA3")+_cDireto,"A3_CODUSR")

		// Se não contiver a tabela cadastrada no cliente, o código da tabela será de acordo com o peso, inserido na tabela por faixa de pesos
		// Paulo - TDS - 18/05/2011
		If Empty(_cTabela)
			dbSelectArea("ZZP")
			dbSetOrder(1)
			dbGoTop()

			While !Eof()
				If TREDE->TOTPES >= ZZP->ZZP_PESOI .And. TREDE->TOTPES <= ZZP->ZZP_PESOF
					_cTabela := ZZP->ZZP_TABELA
					Exit
				EndIf
				ZZP->(dbSkip())
			EndDo
		EndIf        

		// Pega-se os percentuais de variação permitidas para gerente e diretor e supervisro.
		dbSelectArea("DA0")
		dbSetOrder(1)
		dbSeek(xFilial("DA0")+_cTabela)

		If DA0->DA0_XVENDE == 0
			If DA0->DA0_XSUPER == 0
				If DA0->DA0_XGEREN == 0
					If DA0->DA0_XDIRET == 0
						_lZero := .T.
					EndIf
				EndIf   
			EndIf      
		EndIf

		_nValMaxV := 1-(DA0->DA0_XVENDE/100)
		_nValMaxS := 1-(DA0->DA0_XSUPER/100)	
		_nValMaxG := 1-(DA0->DA0_XGEREN/100)
		_nValMaxD := 1-(DA0->DA0_XDIRET/100)

		If (_nPrcTotD/_nPrcTotT) < _nValMaxV
			_lVen := .T.
		EndIf

		If (_nPrcTotD/_nPrcTotT) < _nValMaxS
			_lSup := .T.
		EndIf

		If (_nPrcTotD/_nPrcTotT) < _nValMaxG
			_lGer := .T.
		EndIf

		If (_nPrcTotD/_nPrcTotT) < _nValMaxD
			_lDir := .T.
		EndIf

		_nValIp := (_nPrcTotD/_nPrcTotT)
		_nValIp := NoRound(_nValIp,3)

		//If _nPrcTotD < _nPrcTotT .And. _lZero == .F. .And. _lVen == .T.    // Se o preco total digitado for menor do que o preco total pela tabela, fica no bloqueio
		If _nValIp < 1 .And. _lZero == .F. .And. _lVen == .T.  	
			_cChave  := ALLTRIM(Soma1(GETMV("MV_REDESEQ"))) // Sequencial chave para amarracao campo da tabela ZZN e SC5.
			// Gravar o bloqueio e a alçada para os pedidos daquela rede(_cRede)
			_cQuery4 := ""

			if _lSup == .F. .And. _lGer == .F. .And. _lDir == .F.
				_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			Elseif _lSup == .T. .And. _lGer == .F. .And. _lDir == .F.
				_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_APROV2='"+_cGerente+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			Elseif _lSup == .T. .And. _lGer == .T. .And. _lDir == .F.
				_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_APROV2='"+_cGerente+"',C5_APROV3='"+_cDiretor+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			Else
				_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_APROV2='"+_cGerente+"',C5_APROV3='"+_cDiretor+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			endif						
			/*
			If     _lGer .AND. _lDir // Se o limite é abaixo do IPTAB, a liberação deverá ser feita pelo supervisor, gerente e diretor  
			_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_APROV2='"+_cGerente+"',C5_APROV3='"+_cDiretor+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			ElseIf _lGer // Se o limite é abaixo do IPTAB , a liberação deverá ser feita pelo supervisor e gerente
			_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_APROV2='"+_cGerente+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			Else // Se o limite é abaixo do IPTAB , a liberação deverá ser feita pelo supervisor
			_cQuery4 := " UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'N', C5_ANALISE = 'S', C5_APROV1='"+_cSupervi+"',C5_DTBLOQ = '"+DTOS(Date())+"',C5_HRBLOQ = '"+TIME()+"',C5_CHAVE='"+_cChave+"' "
			EndIf
			*/
			_cQuery4 += "FROM "+RetSqlName("SA3")+", "+RetSqlName("SA1")+" "		
			_cQuery4 += "WHERE C5_XREDE = 'S' AND "
			_cQuery4 += "      C5_CODRED <> '' AND C5_NOTA = '' AND  " //fernando sigoli 30/09/2019 - Chamado: 052215
			
			_cQuery4 += "      C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

			_cQuery4 += "      C5_CODRED = '"+_cRede+"' AND "
			_cQuery4 += "      C5_FILIAL = '"+cFilAnt+"' AND "
			_cQuery4 += "      C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND " // Alterado para a data de entrega - Paulo - TDS - 12/05/2011
			_cQuery4 += "      C5_XLIBERA = ' ' AND "
			_cQuery4 += "      C5_CODRED = A1_COD AND A1_LOJA = '00' AND "
			_cQuery4 += "      C5_VEND1 = A3_COD AND "
			if nCombo1 == 1   &&estadual
				cQuery += " ((SA3.A3_COD BETWEEN '000001' AND '000120') OR (SA3.A3_COD BETWEEN '000130' AND '000135')) AND "
			elseif nCombo1 == 2
				cQuery += " SA3.A3_COD BETWEEN '000121' AND '000129' AND "               
			elseif nCombo1 == 3
				cQuery += " SA3.A3_COD BETWEEN '000136' AND '000165' AND "
			elseif nCombo1 == 4
				//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
				cQuery += " ((SA3.A3_COD BETWEEN '000166' AND '000380') OR (SA3.A3_COD = '000802')) AND "
			Endif
			_cQuery4 += RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
			_cQuery4 += " AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "
			_cQuery4 += " AND "+RETSQLNAME("SA3")+".D_E_L_E_T_=' ' "
			TCSQLExec(_cQuery4)

			dbSelectArea("ZZN")   // Tabela agregador dos pedidos daquela rede
			RecLock("ZZN",.T.)

			ZZN->ZZN_FILIAL := cFilAnt
			ZZN->ZZN_REDE   := _cRede
			ZZN->ZZN_CHAVE  := _cChave
			ZZN->ZZN_NOME   := Posicione("SA1",1,xFilial("SA1")+_cRede+"00","A1_NOME")
			ZZN->ZZN_VALDIG := _nPrcTotD
			ZZN->ZZN_VALTAB := _nPrcTotT
			ZZN->ZZN_IPTAB  := _nPrcTotD/_nPrcTotT

			IF _lVen .And. _lSup == .F. .And. _lGer == .F. .And. _lDir == .F.
				ZZN->ZZN_APROV1 := _cSupervi
			Elseif _lVen .And. _lSup == .T. .And. _lGer == .F. .And. _lDir == .F.
				ZZN->ZZN_APROV1 := _cSupervi
				ZZN->ZZN_APROV2 := _cGerente
			Elseif _lVen .And. _lSup == .T. .And. _lGer == .T. .And. _lDir == .F.
				ZZN->ZZN_APROV1 := _cSupervi
				ZZN->ZZN_APROV2 := _cGerente
				ZZN->ZZN_APROV3 := _cDiretor
			Else
				ZZN->ZZN_APROV1 := _cSupervi
				ZZN->ZZN_APROV2 := _cGerente
				ZZN->ZZN_APROV3 := _cDiretor
			Endif        

			/*
			If     _lGer .AND. _lDir  // Se o limite é abaixo do IPTAB, a liberação deverá ser feita pelo supervisor, gerente e pelo diretor  
			ZZN->ZZN_APROV1 := _cSupervi
			ZZN->ZZN_APROV2 := _cGerente
			ZZN->ZZN_APROV3 := _cDiretor
			ElseIf _lGer              // Se o limite é abaixo do IPTAB, a liberação deverá ser feita pelo supervisor e pelo gerente  
			ZZN->ZZN_APROV1 := _cSupervi
			ZZN->ZZN_APROV2 := _cGerente
			Else                      // Se o limite é abaixo do IPTAB, a liberação deverá ser feita pelo supervisor
			ZZN->ZZN_APROV1 := _cSupervi
			EndIf
			*/

			MsUnlock()

			// Atualiza parametro da chave com conteudo atual
			dbSelectArea("SX6")
			dbSetOrder(1)
			If dbSeek(xFilial("SX6")+"MV_REDESEQ")
				RecLock("SX6",.F.)
				SX6->X6_CONTEUD := _cChave
				SX6->X6_CONTSPA := _cChave
				SX6->X6_CONTENG := _cChave
				MsUnlock()
			EndIf
		Else // Libera a rede
			_cQuery6 := ""
			_cQuery6 := "UPDATE "+RetSqlName("SC5")+" WITH(UPDLOCK) SET C5_XLIBERA = 'S' "
			_cQuery6 += "FROM "+RetSqlName("SA3")+", "+RetSqlName("SA1")+" "
			_cQuery6 += "WHERE C5_XREDE   = 'S' AND "
            _cQuery6 += "      C5_CODRED <> '' AND C5_NOTA = '' AND " //fernando sigoli 30/09/2019 - Chamado: 052215
 
			_cQuery6 += "      C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

			_cQuery6 += "      C5_CODRED  = '"+_cRede+"' AND "
			_cQuery6 += "      C5_FILIAL = '"+cFilAnt+"' AND "
			_cQuery6 += "      C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND " // Alterado para a data de entrega - Paulo - TDS - 12/05/2011
			_cQuery6 += "      C5_CODRED = A1_COD AND A1_LOJA = '00' AND C5_ANALISE <> 'S' AND "
			_cQuery6 += "      C5_VEND1 = A3_COD AND "
			if nCombo1 == 1   &&estadual
				cQuery += " ((SA3.A3_COD BETWEEN '000001' AND '000120') OR (SA3.A3_COD BETWEEN '000130' AND '000135')) AND "
			elseif nCombo1 == 2
				cQuery += " SA3.A3_COD BETWEEN '000121' AND '000129' AND "               
			elseif nCombo1 == 3
				cQuery += " SA3.A3_COD BETWEEN '000136' AND '000165' AND "
			elseif nCombo1 == 4
				//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
				cQuery += " ((SA3.A3_COD BETWEEN '000166' AND '000380') OR (SA3.A3_COD = '000802')) AND "
			Endif
			_cQuery6 += " C5_XLIBERA = ' ' "
			_cQuery6 += " AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
			_cQuery6 += " AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "
			_cQuery6 += " AND "+RETSQLNAME("SA3")+".D_E_L_E_T_=' ' "
			TCSQLExec(_cQuery6)

		EndIf

		dbSelectArea("TREDE")

	EndDo

	dbSelectArea("TREDE")
	dbCloseArea()

	// Libero os pedidos que não cairam no bloqueio. Mantem a instrução para liberar pela data de entrega (Paulo - TDS - 12/05/2011)
	cQuery := ""
	cQuery := "SELECT * FROM "+RetSqlName("SC5")+", "+RetSqlName("SA3")+", "+RetSqlName("SA1")+"  "
	cQuery += "WHERE C5_XREDE = 'S' AND "
    cQuery += "      C5_CODRED <> '' AND C5_NOTA = '' AND  " //fernando sigoli 30/09/2019 - Chamado: 052215

	cQuery += " C5_XGERSF <> '2' AND " // Everson - 19/07/2018. Chamado 037261.

	cQuery += "      C5_DTENTR BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND " // Alterado para a data de entrega - Paulo - TDS - 12/05/2011
	cQuery += "      C5_FILIAL = '"+cFilAnt+"' AND "
	cQuery += "      C5_XLIBERA = 'S' AND C5_ANALISE <> 'S' AND "    &&Incluido campo flag para nao liberar novamente pedidos ja liberados qdo a rotina é executada mais de uma vez no dia. Mauricio 07/07/11.
	cQuery += "      C5_CODRED = A1_COD AND A1_LOJA = '00' AND "
	cQuery += "      C5_VEND1 = A3_COD AND "
	if nCombo1 == 1   &&estadual
		cQuery += " ((A3_COD BETWEEN '000001' AND '000120') OR (A3_COD BETWEEN '000130' AND '000135')) AND "
	elseif nCombo1 == 2
		cQuery += " A3_COD BETWEEN '000121' AND '000129' AND "               
	elseif nCombo1 == 3
		cQuery += " A3_COD BETWEEN '000136' AND '000165' AND "
	elseif nCombo1 == 4
		//   cQuery += " SA3.A3_COD BETWEEN '000166' AND '000380' AND "  //Alterado conforme solicitado chamado 024706
		cQuery += " ((A3_COD BETWEEN '000166' AND '000380') OR (A3_COD = '000802')) AND "
	Endif
	cQuery += RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
	cQuery += " AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "
	cQuery += " AND "+RETSQLNAME("SA3")+".D_E_L_E_T_=' ' "
	cQuery += "ORDER BY C5_NUM"

	TCQUERY cQuery NEW ALIAS "TMP0"

	dbSelectArea("TMP0")
	dbGoTop()

	While !Eof()

		_cPedido := TMP0->C5_NUM

		dbSelectArea("SC5")                  &&mauricio 23/05/2011 - faltava liberar o campo C5_BLQ quando da liberação.
		dbSetOrder(1)
		If dbSeek(xfilial("SC5")+_cPedido)
			recLock("SC5",.F.)
			SC5->C5_BLQ := " "
			SC5->C5_LIBEROK := "S"
			SC5->C5_ANALISE := "S"            &&Mauricio 07/07/11 - campo flag para nao duplicar liberação.
			Msunlock()
		EndIf   

		dbSelectArea("SC6")
		dbSetOrder(1)

		If dbSeek(xFilial("SC6")+_cPedido)
			While !Eof() .And. _cPedido == SC6->C6_NUM
				_nQtdLiber := SC6->C6_QTDVEN
				RecLock("SC6")
				// Efetua a liberação item a item de cada pedido
				Begin transaction
					MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
				End transaction
				SC6->(MsUnLock())

				Begin Transaction
					SC6->(MaLiberOk({_cPedido},.F.))
				End Transaction
				SC6->(dbSkip())
			EndDo
		EndIf

		DbSelectArea("SC9") &&gravo a data de entrega e vendedor(carteira) para os pedidos liberados
		dbSetOrder(1)
		if dbseek(xFilial("SC9")+_cPedido)
			While !Eof() .And. _cPedido == SC9->C9_PEDIDO								
				RecLock("SC9",.F.)
				SC9->C9_DTENTR := SC5->C5_DTENTR
				SC9->C9_VEND1  := SC5->C5_VEND1
				MsUnlock()   
				SC9->(dbSkip())
			EndDo
		Endif
		dbSelectArea("TMP0")
		dbSkip()
	EndDo

	dbSelectArea("TMP0")
	dbCloseArea()


	//-----------------------|
	//log de registro        |
	//-----------------------|
	//inicio - sigoli 15/08/2016 
	If nCombo1 == 1
		cConsidera := "ESTADUAL"
	ElseIf nCombo1 == 2
		cConsidera := "KA ESTADUAL"
	ElseIf nCombo1 == 3
		cConsidera := "INTERESTADUAL RJ"
	Else
		cConsidera := "INTERESTADUAL OUTROS"
	EndiF

	// log de registro de alteração  
	u_GrLogZBE (Date(),TIME(),cUserName,"EXEC. ROTINA ANALISE DE REDE","COMERCIAL","ANALISPED",;
	("DATA INICIAL : "+DtoC(dDtIni)+ " ,DATA FINAL: " +DtoC(dDtFim)+ " , CONSIDERA : "+cConsidera),;
	ComputerName(),LogUserName())

Return()