#include "protheus.ch"
#include "FIVEWIN.CH"
#include "topconn.ch"

/*/{Protheus.doc} User Function AD0055
	Informar placa do caminhao para o roteiro do dia
	APlaca Sub-Funcao de AltRote  
	Logistica
	@type  Function
	@author Werner e Gustavo
	@since 31/07/2003
	@version 01
	@history Corrigido a tela de lancamento Feita pesquisa pelo tipo de frete no parametro.
	@history Everson - 31/05/2019. Chamado 044314.Tratamento para recálculo de frete na tabela ZFD.
	@history RICARDO LIMA - 23/10/18. NAO ALTERA C5_PESOL, C5_PBRUTO, C5_VOLUME1 PARA EXPORTACAO.
	@history Everson - 31/05/2019. Chamado 044314.Tratamento para recálculo de frete na tabela ZFD.
	@history Everson - 19/06/2019. Chamado 044314. Correção do tratamento para recálculo de frete na tabela ZFD.
	@history Everson - 10/07/2019. Chamado 044314. Tratamento para informar a placa do cavalo mecânico para geração do MDF-e.
	@history Everson - 01/07/2020. Chamado 059245. Tratamento para informar o centro de custo para baixa de abastecimento no estoque.
	@history Everson - 12/11/2021. Chamado 63536.  Tratamento para zera km na tabela ZFD.
	@history Fernando Macieira - 22/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE
/*/
User Function AD0055()

	// FUNCAO APLACA ( Funcao que associa o roteiro ao veiculo )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ambiente inicial                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Everson - 12/09/2016, chamado 029242. Alterado o escopo das variáveis para Local.
	
	Local _aArea     := GetArea()
	Local _cRote     := SC5->C5_ROTEIRO
	//Local _cPlac     := SC5->C5_PLACA
	Local _cPlacPe   := space(7)
	Local _cTipoFrt  := space(2)
	//Local _cCodCid   := space(4)
	Local _cDescFrt  := space(30)
	Local _cGuia     := space(6)
	Local _cCod      := space(4)
	Local _CDesti    := space(30)
	Local _DtEntr    := SC5->C5_DTENTR
	Local _dDataTela := DTOC(SC5->C5_DTENTR)
	Local cCCDiesel := Space(TamSX3("CTT_CUSTO")[1]) //Everson - 01/07/2020. Chamado 059245.
	
	Local cPlcCvMec	  := Space(7) //Everson - 10/07/2019.
	Local oPlcCvMec	  := Nil      //Everson - 10/07/2019.

	//Everson - 12/11/2021. Chamado 63536.
	Local lRegGrv     := .F.
	Local bBlock 	  := Nil
	//

	SetPrvt("_CALIAS,_NINDEX,_NRECNO")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Informar placa do caminhao para o roteiro do dia')

	If Alltrim(SC5->C5_XINT) == "3"
		Alert("Roteiro já enviado para o Edata, para altera-lo é necessario o Estorno")

	Else
		DEFINE MSDIALOG _oDlg TITLE "Associar Roteiro ao Veículo" FROM (235),(480) TO (489),(919) PIXEL
		// Cria as Groups do Sistema
		@ (000),(001) TO (115),(218) LABEL "Dados do roteiro" PIXEL OF _oDlg
		@ (010),(004) Say "ROTEIRO             ENTREGA                                                            " Size (193),(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (020),(005) Say _cRote 																												Size (018),(008) COLOR CLR_RED PIXEL OF _oDlg
		@ (020),(045) Say _dDataTela													  														Size (032),(008) COLOR CLR_RED PIXEL OF _oDlg
		@ (040),(005) Say "Placa:" 																											Size (017),(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (040),(095) MsGet o_cPlacPe 	Var _cPlacPe Valid U_UfPlaca(_cPlacPe) F3 "ZV4"								  		Size (030),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (040),(130) MsGet o_cCod 		Var _cCod Valid ExistCpo("ZV8",_cCod) F3 "ZV8"										Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (040),(171) MsGet o_cDesti 	Var _cDesti Valid _cDesti <> ' '																Size (040),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		
		//Everson - 10/07/2019.
		@ (055),(005) Say "Placa cavalo mecânico:" Size (065),(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (055),(095) MsGet oPlcCvMec 	Var cPlcCvMec Valid U_UfPlaca(cPlcCvMec) F3 "ZV4"	Size (030),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		//
		
		@ (070),(005) Say "Tipo de Frete:"																					Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (070),(095) MsGet o_cTipoFrt Var _cTipoFrt Valid ExistCpo("SZH" ,_cTipoFrt) F3 "SZH"  							Size (030),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (070),(130) MsGet o_cDescFrt Var _cDescFrt Valid _cDescFrt <> ' '													Size (082),(009) COLOR CLR_BLACK PIXEL OF _oDlg
		
		//Everson - 01/07/2020. Chamado 059245.
		@ (085),(005) Say "CC Baixa diesel:" 																				Size (060),(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ (085),(095) MsGet o_cCCDiesel Var cCCDiesel Valid (Empty(Alltrim(cCCDiesel)) .Or. ExistCpo("CTT" ,cCCDiesel)) F3 "CTT"  							Size (050),(009) COLOR CLR_BLACK PIXEL OF _oDlg	
		//
		
		bBlock := {|| lRegGrv := GravaPLACA(_cPlacPe,_cCod,_cDesti,_cTipoFrt,_cRote,_cGuia,_DtEntr,_cDescFrt,.T.,.F.,cPlcCvMec,cCCDiesel), Iif(lRegGrv, zeraKm(SC5->C5_NUM), Nil) } ////Everson - 12/11/2021. Chamado 63536.
		DEFINE SBUTTON FROM (100),(150) TYPE 1 ENABLE OF _oDlg ACTION (Eval(bBlock)) //Everson - 10/07/2019. //Everson - 01/07/2020. Chamado 059245. //Everson - 12/11/2021. Chamado 63536.
		DEFINE SBUTTON FROM (100),(185) TYPE 2 ENABLE OF _oDlg ACTION ( _oDlg:END())
		ACTIVATE MSDIALOG _oDlg CENTERED

	EndIf	

	RestArea(_aArea)

Return Nil
/*/{Protheus.doc} GravaPLACA
	Alteracao Roteiro/caminhao.
	Everson - 12/09/2016, chamado 029242.
	Alterado os argumentos da função GravaPlaca para reaproveitamento da função no fonte IMPRDNET.
	Ao executar a importação do arquivo de retorno do RoadNet, é executada a função GravaPLACA.
	@type  Static Function
	@author  Advanced Protheus
	@since 22/05/2002
	@version 01
	StaticCall(AD0055,GravaPLACA,cPlaca,cCodigo,cDestino,cTipoFrt,cRoteiro,cGuia,dDataEntrega,cDescFrt,.F.,.T.)
/*/
Static Function GravaPLACA(_cPlacPe,_cCod,_cDesti,_cTipoFrt,_cRote,_cGuia,_DtEntr,_cDescFrt,lShowTransp,lAut,cPlcCvMec,cCCDiesel) //Everson - 10/07/2019. //Everson - 01/07/2020. Chamado 059245.

	Local aAreaSC5      := {} // @history Fernando Macieira - 22/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE
	Local   aArea		:= GetArea() // Everson - 12/09/2016, chamado 029242.
	Local   cDescProd   := "" 
	Local cPedSF		:= "" //Everson - 02/04/2018, chamado 037261.  
	
	Local cFilGFrt 		 := Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  )) //Everson - 31/05/2019. Chamado 044314.
	Local cTpVeiCavM 	 := Alltrim(cValToChar( GetMv("MV_#TPVCVM",,"") )) //Everson - 10/07/2019.
	                                     
	Private _ctipfrt        // Everson - 12/09/2016, chamado 029242.
	Private _nTotalCx   := 0
	Private _nTotalPedi := 0
	Private _nTotalKg   := 0
	Private _cNomeTra   := ''
	Private _cVeiLoj    := ''
	Private _cVeiFor    := ''
	Private	_cTpFrete   := ' '
	Default lAut        := .F.
	
	Default cPlcCvMec	:= "" //Everson - 10/07/2019.
	Default cCCDiesel	:= "" //Everson - 01/07/2020. Chamado 059245.

	// Consistir Placa digitada
	_cNomeTra := space(20)
	_cTransp  := space(1)
	_cTraCod  := space(1)
	_cPlac    := _cPlacPe
	_cTipVei  := space(2)
	_cCidade  := space(30)
	_cCodCid  := space(4)
	_cRegiao  := space(4)
	_nVlCA    := space(9)
	_nVlTK    := space(9)
	_nVlTC    := space(9)
	_dDtVal   := space(8)
	_nrecsc5  := 0

	//Verifica se há o cadastro da placa informada.	
	DbSelectArea("ZV4")
	ZV4->(DbSetOrder(1)) //Indice placa
	ZV4->(DbGoTop())
	If ! ZV4->(MsSeek(xfilial("ZV4")+ _cPlac))
		MsgStop("Não há cadastro para o veículo " + Alltrim(cValToChar(_cPlac)) + " (ZV4).","Função GravaPLACA(AD0055)")
		RestArea(aArea)
		Return .F.

	Else

		If Empty(ZV4->ZV4_EST) //Verifica se o campo de UF está preenchido.
			MsgStop("O veículo " + Alltrim(cValToChar(_cPlac)) + " está com o cadastro incompleto. Preencha o estado (UF) da Placa deste Veículo!",;
			"Função GravaPLACA(AD0055)")
			RestArea(aArea)
			Return .F.

		EndIf

	EndIf

	_cTipVei := ZV4_TIPVEI
	_cVeiLoj := ZV4_LOJFOR
	_cVeiFor := ZV4_FORNEC
	_cUfPlaca:= ZV4_EST
	
	//Everson - 10/07/2019.
	If  cEmpAnt == "01" .And. cFilAnt $ cFilGFrt 
		
		//
		If Alltrim(cValToChar(_cTipVei)) $(cTpVeiCavM) .And. ! Empty(_cPlac)
			
			//
			If ! IsInCallStack("U_IMPRDNET") .And. IsInCallStack("U_ALTEROTE") 
				If Empty(cPlcCvMec)
					MsgStop("Para o veículo " + cValToChar(_cPlac) + " (" + cValToChar(_cTipVei) + ") é necessário informar a placa do cavalo mecânico.",;
					"Função GravaPLACA(AD0055)")
					RestArea(aArea)
					Return .F.		
						
				EndIf
			
			ElseIf IsInCallStack("U_IMPRDNET")
				MsgAlert("Após a importação do arquivo, é necessário informar a placa do cavalo mecânico para o veículo " + cValToChar(_cPlac) + " no emplacamento manual, para geração do MDF-e.","Função GravaPLACA(AD0055)")
			
			EndIf
		
		Else
			
			//
			If ! Empty(cPlcCvMec) .And. ! IsInCallStack("U_IMPRDNET") .And. IsInCallStack("U_ALTEROTE")
				MsgStop("Para o veículo " + cValToChar(_cPlac) + " (" + cValToChar(_cTipVei) + ") não é necessário informar a placa do cavalo mecânico.",;
				"Função GravaPLACA(AD0055)")
				RestArea(aArea)
				Return .F.	
				
			ElseIf IsInCallStack("U_IMPRDNET")
				cPlcCvMec := ""
				
			EndIf
		
		EndIf
	
	EndIf

	//Obtém dados da tabela de frete.
	DbSelectArea("ZV8")
	ZV8->(DbSetOrder(2)) // Indice Destino
	ZV8->(DbGoTop())
	If ZV8->(MsSeek(xfilial("ZV8")+ _cDesti))
		_cCodCid := ZV8->ZV8_COD
		_cCidade := ZV8->ZV8_CIDADE

	Else
		MsgStop("Não foi possível obter dados da tabela de frete referente ao destino " + cValToChar(_cDesti) + ".",;
		"Função GravaPLACA(AD0055)")
		RestArea(aArea)
		Return .F.

	EndIf

	DbSelectArea("ZV9")
	ZV9->(DbSetOrder(2)) // Indice Codigo EX: SP01
	ZV9->(DbGoTop())
	If ZV9->(MsSeek(xfilial("ZV9")+ _cCodCid))
		Do While ! ZV9->(Eof()) .and. ZV9->ZV9_REGIAO = _cCodCid
			If ZV9->ZV9_DTVAL <= DDATABASE
				_nVlCA := ZV9->ZV9_VLTON
				_nVlTK := ZV9->ZV9_VLTK
				_nVlTC := ZV9->ZV9_VLTC

			EndIf

			ZV9->(DbSkip())

		Enddo

	EndIf

	//Seleciona o código de fornecedor da transportadora.
	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(DbGoTop())
	If SA2->(MsSeek(xfilial("SA2")+ _cVeiFor + _cVeiLoj))
		_cTraCod  := SA2->A2_COD
		_cTraLoja := SA2->A2_LOJA
		_cNomeTra := SA2->A2_NOME
		// Consulto Tipo de Frete para saber se considera transportadora

	Else
		MsgAlert("O veículo " + Alltrim(cValToChar(_cPlac)) + " (" + Alltrim(cValToChar(_cVeiFor)) + "/" + Alltrim(cValToChar(_cVeiLoj)) +;
		" ) não possui transportadora cadastrada (fornecedor SA2). Roteiro " + Alltrim(cValToChar(_cRote)) + ".","Função GravaPLACA(AD0055)")
		_cTraCod  := "ERRO"
		_cTraLoja := "ER"
		_cNomeTra := "ERRO"

	EndIf

	//Daniel - faco a busca fora do seek anterior
	//19/01/07
	DbSelectArea("SZH")
	SZH->(DbSetOrder(1))
	SZH->(DbGoTop())
	If SZH->(MsSeek(xfilial("SZH") + _cTipoFrt))
		_cTransp :=  SZH->ZH_TRANSP
		_cTipFrt :=  SZH->ZH_TIPFRT

		If _cTransp == 'S'
			// Caso For Longo Percurso
			_cNomeTrans := "Transportadora: "+ _cNomeTra
			//				@ 80,155 SAY _cTransp

			If lShowTransp // Everson - 12/09/2016, chamado 029242.
				MSGINFO(_cNomeTrans)

			EndIf

		EndIf
	EndIf

	_PBruTot := 0
	_PLiqTot := 0
	_NumEntr := 0

	DbSelectArea("SC5")
	SC5->(DbGoTop())

	If lAut //Utilizado o índice 9 para rotina automática. Everson - 27/09/2016. Chamado 030681.

		DBORDERNICKNAME("SC5_9") //C5_FILIAL+DTOS(C5_DTENTR)+C5_ROTEIRO+C5_PLACA
		If SC5->( !dbSeek( FWxFilial("SC5")+ DToS(_dtEntr) + _cRote ) )
			MsgStop("Não encontrado roteiro (" + Alltrim(cValToChar(_cRote)) + ") x data de entrega nos pedidos de venda (SC5).Contate a Informática sobre o problema.",;
			"Função GravaPLACA(AD0055)")
			RestArea(aArea)
			Return .F.
		EndIf

	Else	
		
		DBORDERNICKNAME("SC5_6") // C5_FILIAL+C5_ROTEIRO+C5_SEQUENC
		If SC5->( !dbSeek( FWxFilial("SC5")+ _cRote ) ) 
			MsgStop("Não encontrado roteiro (" + Alltrim(cValToChar(_cRote)) + ") x data de entrega nos pedidos de venda (SC5).Contate a Informática sobre o problema.",;
			"Função GravaPLACA(AD0055)")
			RestArea(aArea)
			Return .F.
		EndIf

	EndIf
	
	aAreaSC5 := SC5->( GetArea() ) // @history Fernando Macieira - 22/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE
	If !IsInCallStack("U_IMPRDNET") .And. IsInCallStack("U_ALTEROTE") .And. !Empty(_cRote) .And. cEmpAnt == "01" .And. cFilAnt $ cFilGFrt
		MsAguarde({|| StaticCall(ADLOG049P,recalFrt,_cPlac,_dtEntr,_cRote,cPlcCvMec) },"Aguarde","Verificando frete...")
	EndIf
	RestArea( aAreaSC5 ) // @history Fernando Macieira - 22/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE
	
	// Laco para comitar a troca das placas
	Do While !SC5->(Eof()) .and. SC5->C5_ROTEIRO == _cRote .And. SC5->C5_FILIAL == cFilAnt

		IF SC5->C5_DTENTR <> _dtEntr
			SC5->(DbSkip())
			Loop
		ENDIF  

		If !Empty(SC5->C5_NOTA) //chamado 036462 - Fernando 03/08/2017
			SC5->(DbSkip())
			Loop
		EndIf

		// Forço somar a peso bruto e unidades
		_cNumPed  := SC5->C5_NUM
		_nTotalBr := 0
		_nTotalKg := 0
		_nTotalCx := 0

		//&& inicio - Fernando Sigoli 13/02/2017
		If SC5->C5_XTIPO = '2'

			cDescProd := PesqProd(SC5->C5_NUM) 

			// INICIO - WILLIAM COSTA 23/02/2017 CHAMADO 033295
			SQLVerifPedFaturado(SC5->C5_ROTEIRO,SC5->C5_DTENTR) 

			While TRB->(!EOF())

				MsgStop("Olá " + UPPER(AllTrim(UsrRetName(__cUserID))) + CHR(13) + CHR(10) +;
				"favor alterar o Roteiro " + SC5->C5_ROTEIRO + CHR(13) + CHR(10) +;
				" Já existe esse Roteiro Faturado, "           + CHR(13) + CHR(10) +;
				" Troque o numero Roteiro ou Data de Entrega para continuar!!! ",   ;
				"Já existe Roteiro " + SC5->C5_ROTEIRO + " Faturado")
				TRB->(dbCloseArea())      
				RestArea(aArea)
				Return .F.

				TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())


			// FINAL - WILLIAM COSTA 23/02/2017 CHAMADO 033295


		EndIF
		//&& Final - Fernando Sigoli                                         D

		Soma_Itens(_cPlac,_crote,_DtEntr) //&&Grava dados no SC9. // Everson - 12/09/2016, chamado 029242. Adicionado argumentos na função.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Informacoes em SC5                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Itens   ajustado para permitir o lançamento de pedidos da tela padrão  Werner - 13/09/2006
		DbSelectArea("SC5")
		RecLock("SC5",.F.)
			Replace C5_PLACA		With _cPlac
			Replace C5_UFPLACA	With _cUFPlaca
		  
			If !Empty(cDescProd)    //&& Fernando Sigoli 13/02/2017
				Replace C5_OBS        With _cPlac+' - '+cDescProd 
			EndIf
			// Ricardo Lima - 23/10/18	  
			If SC5->C5_EST <> 'EX'
				If cEmpAnt == "02"			  
					Replace C5_PBRUTO	With _nTotalKg
				Else
					Replace C5_PBRUTO	With _nTotalBr + _nTotalKg				  
				EndIf	
			EndIf
			// Ricardo Lima - 23/10/18
			If SC5->C5_EST <> 'EX'  
				Replace C5_PESOL   With _nTotalKg
				Replace C5_VOLUME1 With _nTotalCx
			EndIF
		
			// Se for longo percuso grava o codigo da transportadora no Pedido
			If _cTransp == 'S'
				Replace C5_TRANSP  With _cTraCod
			Else
				Replace C5_TRANSP  With space(6)
			EndIf
		SC5->( MsUnlock() )

		// SOMA PESO BRUTO
		// Tipo de Frete
		_cTpFrete := C5_TPFRETE
		_PBruTot := _PBruTot + SC5->C5_PBruto
		_PLiqTot := _PLiqTot + SC5->C5_PesoL
		_NumEntr := _NumEntr + 1

		//
		dbSelectArea("SA1")
		// GRAVA NO CLIENTE PARA PROXIMA REFERENCIA
		//If !SC5->C5_TIPO $ "B/D"  //comentei e adicionei a regra abaixo
		If !SC5->C5_TIPO $ "B/D" .and. SC5->C5_TPFRETE = "C" // Chamado 030747- Sigoli  [adicionei SC5->C5_TPFRETE para NAO atualizar Roteiro do Cliente qunado o pedido for fob
			If SA1->(MsSeek( xFilial("SA1")+ SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.))

				IF ALLTRIM(_cRote) <> '197' //chamado 036887 - William Costa - 12/06/2018 - 036887 || TECNOLOGIA || MARCEL_BIANCHI || 8451 || VALID.ROT.REPROGR.
				
					RecLock("SA1",.F.)
					
						Replace A1_ROTEIRO With _cRote
	
					MsUnlock()
					
				ENDIF
			EndIf

		EndIf
		//
		//grava log/alteracao de bairro	
		u_GrLogZBE (Date(),TIME(),cUserName," INFORMA PLACA DO VEICULO PARA O ROTEIRO","LOGISTICA","AD0055",;
		"PEDIDO: "+SC5->C5_NUM+" PLACA: "+_cPlac+" ROTEIRO: "+_cRote,ComputerName(),LogUserName()) 
		
		//Everson - 02/04/2018. Chamado 037261.
		If ! Empty(Alltrim(cValToChar(SC5->C5_NUM)))
			cPedSF += "'" + Alltrim(cValToChar(SC5->C5_NUM)) + "',"
		
		EndIf
		
		dbSelectArea("SC5")
		SC5->(dbSkip())

	EndDo

	// @history Fernando Macieira - 22/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE
	PutPlaca(_cRote, _dtEntr, _cPlac, _cUFPlaca)

	//Set Softseek off
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Fretes                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZK")
	SZK->(dbSetOrder(2))     // ZK_FILIAL + ZK_GUIA  + DTOS(ZK_DTENTR + ZK_PLACA )
	SZK->(DbGoTop())
	// Grava o controle de Frete
	If !empty(_cGuia) /// GUIA

		If SZK->(MsSeek( xFilial("SZK")+_cGuia +DTOS(_DtEntr) + _cPlac))
		
			_oK := "F"
			RecLock("SZK",.F.)
			
				Replace ZK_FILIAL  		With xFilial("SZK")
				Replace ZK_PLACA  		With _cPlac
				Replace ZK_PLACAPG	 	With _cPlac
				Replace ZK_DTENTR 	 	With _DtEntr
				Replace ZK_ENTREGA 		With _NumEntr
				Replace ZK_GUIA   		With _cGuia
				Replace ZK_TPFRETE  	With _cTipoFrt
				Replace ZK_DESCRI 		With _cDescFrt
				Replace ZK_ROTEIRO   	With _cRote
				Replace ZK_DESTINO   	With _cDesti
				Replace ZK_PESOL        With _PLiqTot
				Replace ZK_PBRUTO     	With _PBruTot
				Replace ZK_TABELA      	With ZV4->ZV4_TABELA
				Replace ZK_NOMFOR    	With _cNomeTra
				Replace ZK_FORNEC     	With _cTraCod
				Replace ZK_LOJA         With _cTraLoja
				Replace ZK_PESFATL    	With _PLiqTot
				Replace ZK_PESFATB   	With _PBruTot
				Replace ZK_CIFOB        With _cTpFrete
				Replace ZK_TIPFRT       With _cTipFrt
				Replace ZK_CIDDEST    	With _cCodCid
				
				Replace ZK_PLCCAV		With cPlcCvMec  //Everson - 10/07/2019.
				Replace ZK_CCDIESE		With cCCDiesel //Everson - 01/07/2020. Chamado 059245.
			
				If _cTipoFrt $ GETMV('MV_FRTLGN') //'A7' .OR. _cTipoFrt = 'A4' // Verifica se for L.Percurso A7 ou Tranferencia A4
					If _cTipVei = 'CA' // Se for CARRETA
						Replace	ZK_VALFRET With (_nVlCA/1000)*_PBruTot
					Else
						If _cTipVei = 'TK' // Se for TRUCK
							Replace	ZK_VALFRET With (_nVlTK/1000)*_PBruTot
						Else
							If _cTipVei = 'TC' // Se for TOCO
								Replace	ZK_VALFRET With (_nVlTC/1000)*_PBruTot
							EndIf
						EndIf
					EndIf
				EndIf
				
			MsUnlock()
			
			//grava log	
			u_GrLogZBE (Date(),TIME(),cUserName,"1 RecLock(SZK,.F.)","LOGISTICA","AD0055",;
			"Filial: "+xFilial("SZK")+" Guia: "+_cGuia+" Data: "+DTOS(_DtEntr)+" Placa: "+_cPlac+" ZK_ENTREGA: "+ cvaltochar(_NumEntr),ComputerName(),LogUserName())
			
		Else
		
			_oK := "T"
			RecLock("SZK",.T.)
			
				Replace ZK_FILIAL  		With xFilial("SZK")
				Replace ZK_PLACA  		With _cPlac
				Replace ZK_PLACAPG	 	With _cPlac
				Replace ZK_DTENTR 	 	With _DtEntr
				Replace ZK_ENTREGA 		With _NumEntr
				Replace ZK_GUIA   		With _cGuia
				Replace ZK_TPFRETE  	With _cTipoFrt
				Replace ZK_DESCRI 		With _cDescFrt
				Replace ZK_ROTEIRO   	With _cRote
				Replace ZK_DESTINO   	With _cDesti
				Replace ZK_PESOL        With _PLiqTot
				Replace ZK_PBRUTO     	With _PBruTot
				Replace ZK_TABELA      	With ZV4->ZV4_TABELA
				Replace ZK_NOMFOR    	With _cNomeTra
				Replace ZK_FORNEC     	With _cTraCod
				Replace ZK_LOJA         With _cTraLoja
				Replace ZK_PESFATL    	With _PLiqTot
				Replace ZK_PESFATB   	With _PBruTot
				Replace ZK_CIFOB        With _cTpFrete
				Replace ZK_TIPFRT       With _cTipFrt
				Replace ZK_CIDDEST    	With _cCodCid
				
				Replace ZK_PLCCAV		With cPlcCvMec  //Everson - 10/07/2019.
				Replace ZK_CCDIESE		With cCCDiesel //Everson - 01/07/2020. Chamado 059245.
			
				If _cTipoFrt $ GETMV('MV_FRTLGN') //'A7' .OR. _cTipoFrt = 'A4' // Verifica se for L.Percurso A7 ou Tranferencia A4
					If _cTipVei = 'CA' // Se for CARRETA
						Replace	ZK_VALFRET With (_nVlCA/1000)*_PBruTot
					Else
						If _cTipVei = 'TK' // Se for TRUCK
							Replace	ZK_VALFRET With (_nVlTK/1000)*_PBruTot
						Else
							If _cTipVei = 'TC' // Se for TOCO
								Replace	ZK_VALFRET With (_nVlTC/1000)*_PBruTot
							EndIf
						EndIf
					EndIf
				EndIf
				
			MsUnlock()
			
			//grava log	
			u_GrLogZBE (Date(),TIME(),cUserName,"2 RecLock(SZK,.T.)","LOGISTICA","AD0055",;
			"Filial: "+xFilial("SZK")+" Guia: "+_cGuia+" Data: "+DTOS(_DtEntr)+" Placa: "+_cPlac+" ZK_ENTREGA: "+ cvaltochar(_NumEntr),ComputerName(),LogUserName())
			
		EndIf

	Else
	
		//Altero a ordem para roteiro
		dbSelectArea("SZK")
		SZK->(dbSetOrder(4))    // ZK_FILIAL + ZK_DTENTR  + ZK_PLACA + ZK_ROTEIRO )
		SZK->(DbGoTop())
		If SZK->(MsSeek( xFilial("SZK")+ DTOS(_DtEntr) + _cPlac + _cRote ))
		
			_oK := "F"
			RecLock("SZK",.F.)
			
				Replace ZK_FILIAL  		With xFilial("SZK")
				Replace ZK_PLACA   		With _cPlac
				Replace ZK_PLACAPG 		With _cPlac
				Replace ZK_DTENTR   	With _DtEntr
				Replace ZK_ENTREGA 		With _NumEntr
				Replace ZK_GUIA         With _cGuia
				Replace ZK_TPFRETE  	With _cTipoFrt
				Replace ZK_DESCRI      	With _cDescFrt
				Replace ZK_ROTEIRO  	With _cRote
				Replace ZK_DESTINO  	With _cDesti
				Replace ZK_PESOL       	With _PLiqTot
				Replace ZK_PBRUTO  		With _PBruTot
				Replace ZK_TABELA    	With ZV4->ZV4_TABELA
				Replace ZK_NOMFOR  		With _cNomeTra
				Replace ZK_FORNEC  		With _cTraCod
				Replace ZK_LOJA         With _cTraLoja
				Replace ZK_PESFATL 		With _PLiqTot
				Replace ZK_PESFATB 		With _PBruTot
				Replace ZK_CIFOB        With _cTpFrete
				Replace ZK_TIPFRT       With _cTipFrt
				Replace ZK_CIDDEST  	With _cCodCid
				
				Replace ZK_PLCCAV		With cPlcCvMec  //Everson - 10/07/2019.
				Replace ZK_CCDIESE		With cCCDiesel //Everson - 01/07/2020. Chamado 059245.
		
				If _cTipoFrt $ GETMV('MV_FRTLGN')// 'A7' .OR. _cTipoFrt = 'A4' // Verifica se for L.Percurso A7 ou Tranferencia A4
					If _cTipVei = 'CA' // Se for CARRETA
						Replace	ZK_VALFRET With (_nVlCA/1000)*_PBruTot
					Else
						If _cTipVei = 'TK' // Se for TRUCK
							Replace	ZK_VALFRET With (_nVlTK/1000)*_PBruTot
						Else
							If _cTipVei = 'TC' // Se for TOCO
								Replace	ZK_VALFRET With (_nVlTC/1000)*_PBruTot
							EndIf
						EndIf
					EndIf
				EndIf
				
			MsUnlock()

			//grava log	
			u_GrLogZBE (Date(),TIME(),cUserName,"3 RecLock(SZK,.F.)","LOGISTICA","AD0055",;
			"Filial: "+xFilial("SZK")+" Data: "+DTOS(_DtEntr)+" Placa: "+_cPlac+" Roteiro: "+_cRote+" ZK_ENTREGA: "+ cvaltochar(_NumEntr),ComputerName(),LogUserName())

		Else
		
			_oK := "T"
			RecLock("SZK",.T.)
			
				Replace ZK_FILIAL  		With xFilial("SZK")
				Replace ZK_PLACA   		With _cPlac
				Replace ZK_PLACAPG 		With _cPlac
				Replace ZK_DTENTR   	With _DtEntr
				Replace ZK_ENTREGA 		With _NumEntr
				Replace ZK_GUIA         With _cGuia
				Replace ZK_TPFRETE  	With _cTipoFrt
				Replace ZK_DESCRI      	With _cDescFrt
				Replace ZK_ROTEIRO  	With _cRote
				Replace ZK_DESTINO  	With _cDesti
				Replace ZK_PESOL       	With _PLiqTot
				Replace ZK_PBRUTO  		With _PBruTot
				Replace ZK_TABELA    	With ZV4->ZV4_TABELA
				Replace ZK_NOMFOR  		With _cNomeTra
				Replace ZK_FORNEC  		With _cTraCod
				Replace ZK_LOJA         With _cTraLoja
				Replace ZK_PESFATL 		With _PLiqTot
				Replace ZK_PESFATB 		With _PBruTot
				Replace ZK_CIFOB        With _cTpFrete
				Replace ZK_TIPFRT       With _cTipFrt
				Replace ZK_CIDDEST  	With _cCodCid
				
				Replace ZK_PLCCAV		With cPlcCvMec  //Everson - 10/07/2019.
				Replace ZK_CCDIESE		With cCCDiesel //Everson - 01/07/2020. Chamado 059245.
		
				If _cTipoFrt $ GETMV('MV_FRTLGN')// 'A7' .OR. _cTipoFrt = 'A4' // Verifica se for L.Percurso A7 ou Tranferencia A4
					If _cTipVei = 'CA' // Se for CARRETA
						Replace	ZK_VALFRET With (_nVlCA/1000)*_PBruTot
					Else
						If _cTipVei = 'TK' // Se for TRUCK
							Replace	ZK_VALFRET With (_nVlTK/1000)*_PBruTot
						Else
							If _cTipVei = 'TC' // Se for TOCO
								Replace	ZK_VALFRET With (_nVlTC/1000)*_PBruTot
							EndIf
						EndIf
					EndIf
				EndIf
				
			MsUnlock()
			
			//grava log	
			u_GrLogZBE (Date(),TIME(),cUserName,"4 RecLock(SZK,.T.)","LOGISTICA","AD0055",;
			"Filial: "+xFilial("SZK")+" Data: "+DTOS(_DtEntr)+" Placa: "+_cPlac+" Roteiro: "+_cRote+" ZK_ENTREGA: "+ cvaltochar(_NumEntr),ComputerName(),LogUserName())

		EndIf

	EndIf //Fecha da guia.

	
	// Zerando as variaveis
	_nVlCA := 0
	_nVlTK := 0
	_nVlTC := 0
	// Vou na Guia Registar a Data de Entrega
	DbSelectArea("ZV2")
	ZV2->(DbSetOrder(1))    // ZV2_GUIA]
	ZV2->(DbGoTop())
	If ZV2->(MsSeek( xFilial("ZV2")+_cGuia))
		RecLock("ZV2",.F.)
		Replace ZV2_DTENTR  With _DtEntr
		Replace ZV2_ROTEIRO With _cRote
		Replace ZV2_PFATU   With _PLiqTot
		// Altero para nao permitir a primeira pesagem novamente
		Replace ZV2_STATUS  With "2"

		MsUnlock()

	EndIf


	If Type("_oDlg") == "O" // Everson - 12/09/2016, chamado 029242.
		_oDlg:END()      //encerra a janela

	EndIf
	
	//Everson - 02/04/2018. Chamado 037261.
	If cEmpAnt == "01" .And. cFilAnt == "02" .And. FindFunction("U_ADVEN050P") .And. ! Empty(cPedSF)
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUL")))) == "S"
			cPedSF := Substr(cPedSF,1,Len(cPedSF) -1)
			U_ADVEN050P("",,," AND C5_NUM IN (" + cPedSF + ") AND C5_XPEDSAL <> '' ",,,,,,.T.)
		
		EndIf
		
	EndIf

	RestArea(aArea) // Everson - 12/09/2016, chamado 029242.

Return .T.
/*/{Protheus.doc} Soma_Itens
	(long_description)
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
// Everson - 12/09/2016, chamado 029242.
Static Function Soma_Itens(_cPlac,_crote,_DtEntr)

	Local aArea	:= GetArea() // Everson - 12/09/2016, chamado 029242.

	DbSelectArea("SC9")
	SC9->(DBSETORDER(1))
	SC9->(DbGoTop())
	IF SC9->(MsSeek( xFilial("SC9") + _cNumPed ))
		Do While ! SC9->(Eof()) .And. SC9->C9_PEDIDO == _cNumPed .And. xFilial("SC9") == SC9->C9_FILIAL

			DbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(DbGoTop())
			SB1->(MsSeek(xFilial("SB1") + SC9->C9_PRODUTO))

			//		_nTotalPedi := _nTotalPedi + SC9->C9_VALOR
			_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2   // Soma qtd caixas (2a. UM)
			_nTotalKg   := _nTotalKg   + Iif(SB1->B1_SEGUM="BS",0,SC9->C9_QTDLIB)   // Soma qtd peso   <1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			SB1->(MsSeek(xFilial("SB1") + SC9->C9_PRODUTO))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Cadastro de Tara                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SZC")
			SZC->(DbSetOrder(1))
			SZC->(DbGoTop())
			If SZC->(MsSeek( xFilial("SZC") + SB1->B1_SEGUM ))

				_nTotalBr   := _nTotalBr + (SC9->C9_QTDLIB2 * SZC->ZC_TARA) // PESO BRUTO

			Else
				If Alltrim(SB1->B1_SEGUM) <> ""                             //Incluido 12/07/11 - Ana. Tratamento para peso duplicado
					_nTotalBr   := _nTotalBr + (SC9->C9_QTDLIB  * 1)        // PESO BRUTO

				Else
					_nTotalBr   := _nTotalBr                                // PESO BRUTO	

				EndIf	

			EndIf

			// ALTERADO POR HCCONSYS FORCAR POSICONAMENTO NO CAB DO PEDIDO para gravar roteiro e data .
			// CHAMADO 003736

			//		dbSelectArea("SC5")
			//		dbSetOrder(1)
			//		If MsSeek(xFilial("SC5")+SC9->C9_PEDIDO)

			DbSelectArea("SC9")  
			//dbSetOrder(1)
			Reclock("SC9",.F.)

			SC9->C9_PLACA 			:= _cPlac 
			SC9->C9_ROTEIRO 			:= _crote
			SC9->C9_DTENTR 			:= _DtEntr 

			MsUnlock()

			//	EndIf

			//		dbSelectArea("SC9")
			//		dbSetOrder(1)
			DbSelectArea("SC9")
			SC9->(dbSkip())

		Enddo

	ENDIF

	RestArea(aArea) // Everson - 12/09/2016, chamado 029242.

Return Nil
/*/{Protheus.doc} User Function UfPlaca
	Verifica se Placa está cadastrada e se tem estado preenchido
	@type  Function
	@author user
	@since 
	@version 01
	/*/
User Function UfPlaca(_Placa)

	Local _area := GetArea()
	Local _lUf  := .T.

	U_ADINF009P('AD0055' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Informar placa do caminhao para o roteiro do dia')

	If ! Empty(_Placa)
		DbSelectArea("ZV4")
		ZV4->(DbSetOrder(1))
		ZV4->(DbGoTop())
		If ! ZV4->(MsSeek(xFilial("ZV4")+_Placa))
			MsgStop("Placa " + Alltrim(cValToChar(_Placa)) + " não cadastrada!","Função UfPlaca(AD0055)")
			_lUf := .F.

		else
			If EMPTY(ZV4->ZV4_EST)
				MsgStop("O veículo " + Alltrim(cValToChar(_Placa)) + " está com o cadastro incompleto. Informe o estado (UF) da placa deste Veículo!",;
				"Função UfPlaca(AD0055)")
				_lUf := .F.

			EndIf

		EndIf

	EndIf

	Restarea(_area)

Return _lUf    
/*/{Protheus.doc} PesqProd
	Rotina para buscar a descrição dos produtos e carregar no campo C5_OBS.
	@type  Static Function
	@author Fernando Sigoli
	@since 13/02/2017  
	@version 01
	/*/
Static Function PesqProd(cPedido)

	Local aArea := GetArea()
	Local cDesc := ""

	DbSelectArea("SC6")
	DbSetOrder(1)
	Dbgotop()
	If dbseek(xFilial("SC6")+cPedido)	
		cDesc := substR(SC6->C6_DESCRI,1,55)
	EndIf

	Restarea(aArea)

Return cDesc   
/*/{Protheus.doc} SQLVerifPedFaturado
	(long_description)
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function SQLVerifPedFaturado(cRoteiro,cDtEntr) 

	BeginSQL Alias "TRB"
		%NoPARSER%  
		SELECT C5_NUM,
		C5_ROTEIRO,
		C5_DTENTR
		FROM %Table:SC5%
		WHERE C5_FILIAL   = %xFilial:SC5%
		AND C5_ROTEIRO  = %EXP:cRoteiro%
		AND C5_DTENTR   = %EXP:cDtEntr%
		AND C5_NOTA    <> ''
		AND D_E_L_E_T_ <> '*'
	EndSQl             

Return Nil
/*/{Protheus.doc} zeraKm
	Função zera o km da tabela ZFD.
	Chamado 63536.
	@type  Static Function
	@author Everson
	@since 12/11/2021
	@version 01
/*/
Static Function zeraKm(cPedido)

	//Variáveis.
	Local aArea    := GetArea()
	Local cSqlScprt:= ""

	Default cPedido:= ""

	//
	If Empty(cPedido)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cSqlScprt := ""
	cSqlScprt += " UPDATE " + RetSqlName("ZFD") + "  SET ZFD_KMGER = 0  " 
	cSqlScprt += " WHERE  " 
	cSqlScprt += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
	cSqlScprt += " AND ZFD_COD IN( " 
	cSqlScprt += " SELECT  " 
	cSqlScprt += " ZFD_COD " 
	cSqlScprt += " FROM " 
	cSqlScprt += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD " 
	cSqlScprt += " WHERE " 
	cSqlScprt += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
	cSqlScprt += " AND ZFD_PEDIDO = '" + cPedido + "' " 
	cSqlScprt += " AND ZFD.D_E_L_E_T_ = '' " 
	cSqlScprt += " ) AND D_E_L_E_T_ = '' " 

	//
	Conout("AD0055 - zeraKm - cSqlScprt " + cSqlScprt)
	If TCSqlExec(cSqlScprt) < 0
		Conout("AD0055 - zeraKm - TCSQLError " + TCSQLError())
		MsgAlert("Ocorreu erro na atualização da tabela ZFD " + TCSQLError())

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author FWNM
	@since 23/11/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Fernando Macieira - 23/11/2021 - Ticket 64172 - ADLOG056 - Ajustar troca de placa no SC5 EM LOTE	
/*/
Static Function PutPlaca(_cRote, _dtEntr, _cPlac, _cUFPlaca)

	Local aArea     := GetArea()
	Local aAreaSC5  := SC5->( GetArea() )
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT C5_FILIAL, C5_NUM
	cQuery += " FROM " + RetSqlName("SC5") + " (NOLOCK)
	cQuery += " WHERE C5_FILIAL='"+FWxFilial("SC5")+"' 
	cQuery += " AND C5_ROTEIRO='"+_cRote+"' 
	cQuery += " AND C5_DTENTR='"+DtoS(_dtEntr)+"' 
	cQuery += " AND C5_NOTA=''
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )
	Do While Work->( !EOF() )

		SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
		If SC5->( dbSeek(Work->(C5_FILIAL+C5_NUM)) )
			RecLock("SC5", .F.)
				SC5->C5_PLACA   := _cPlac
				SC5->C5_UFPLACA := _cUFPlaca
			SC5->( msUnLock() )
		EndIf

		//grava log
		u_GrLogZBE( msDate(), TIME(), cUserName," ALTEROU PLACA DO VEICULO", "PUTPLACA", "AD0055",;
		"PEDIDO: "+SC5->C5_NUM+" PLACA: "+_cPlac+" ROTEIRO: "+_cRote, ComputerName(), LogUserName() ) 

		Work->( dbSkip() )

	EndDo

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aArea )
	RestArea( aAreaSC5 )

Return
