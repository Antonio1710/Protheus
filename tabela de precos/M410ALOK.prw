#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function M410ALOK
	Ponto de entrada que verificar se o pedido de venda j� foi liberado, ap�s a execu��o do especifico ANALISPED, verificando pedidos de loja e de rede.
	Verifica tamb�m se o pedido j� foi roteirizado para o seu transporte.
	@type  Function
	@author Lt. Paulo - TDS
	@since 19/05/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 8786 - 05/02/2021 - Fernando Macieira - Alterar ou Excluir Pedido de Venda - Base de Dados Adoro
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
/*/
User Function M410ALOK()

	Local _aArea 		:= GetArea()
	Local _lRet  		:= .T.
	Local _LCOPIA 		:= If(ValType(VAR_IXB)=="A",If(VAR_IXB[1]=="COPIA_PV",.T.,.F.),.F.)
	Local _cUsuExcPV	:= Alltrim(GetMv("MV_#USUEPV")) // Incluido por Adriana para validacao exclusao de Pedido de Venda Liberado
	Local _cEmpRotOK    := GetMV("MV_#EMPROT",,"02#07#09#01") // @history ticket 8786 - 05/02/2021 - Fernando Macieira - Alterar ou Excluir Pedido de Venda - Base de Dados Adoro
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	//Everson - 01/03/2018. Chamado 037261.SalesForce.
	If IsInCallStack('RESTEXECUTE') .OR. IsInCallStack('U_RESTEXECUTE')
		RestArea(_aArea)
		Return _lRet

	EndIf
	If SC5->C5_EST = 'EX' // Ricardo Lima - 29/10/18
		RestArea(_aArea)
		Return _lRet
	Endif

	_cCliente   := SC5->C5_CLIENTE
	_cLoja 		:= SC5->C5_LOJACLI

	if !_lCopia //&&conforme email Vagner 15/06/11 permitir copia. Ana informou que perfil do usuario define se este pode copiar ou nao.

		if !(Alltrim(__cUserID) $ _cUsuExcPV)   //Adriana em 05/11/2015 - incluido parametro para validar exclusao de pedido de venda liberado
			// Verifica se o pedido est� bloqueado e j� liberado para as devidas aprova��es
			//&&Mauricio 01/06/11 - Corrigido pois em teste n�o estava funcionando.
			If  SC5->C5_XREDE == 'S' .And. !Empty(SC5->C5_CODRED) .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. !IsInCallStack("A410DELETA")
				If      SC5->C5_LIBEROK == "E" .AND. !Empty(SC5->C5_XLIBERA) .AND. SC5->C5_BLQ = " " 
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido j� sofreu avalia��o e foi rejeitado.Nao podendo ser mais utilizado A T E N � � O ' , ;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{"Cliente sem tabela de pre�o em seu cadastro.Contate Depto. Comercial.O pedido nao podera ser incluido!"})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido j� sofreu avalia��o e foi rejeitado.Nao podendo ser mais utilizado"),OemToAnsi(" A T E N � � O "))

					ENDIF

					Return(.F.)
			
				ElseIf !Empty(SC5->C5_XLIBERA) .AND. SC5->C5_BLQ == "1" .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. !IsInCallStack("A410DELETA")
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido j� sofreu avalia��o di�ria para REDE e n�o pode ser mais alterado. A T E N � � O ' , ;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Pedido j� sofreu avalia��o di�ria para REDE e n�o pode ser mais alterado. A T E N � � O '})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido j� sofreu avalia��o di�ria para REDE e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

					ENDIF

					Return(.F.)
			
				ElseIf SC5->C5_LIBEROK == "S" .AND. !Empty(SC5->C5_XLIBERA) .AND. SC5->C5_BLQ = " " .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. !IsInCallStack("A410DELETA")
					IF ALTERA     &&Conforme Vagner em 15/06/11 a exclusao deve ser permitida.
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Pedido j� sofreu processo de Aprova��o, n�o podendo ser mais alterado A T E N � � O ' , ;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Pedido j� sofreu processo de Aprova��o, n�o podendo ser mais alterado A T E N � � O '})

						ELSE

							ApMsgInfo(OemToAnsi("Pedido j� sofreu processo de Aprova��o, n�o podendo ser mais alterado"),OemToAnsi(" A T E N � � O "))

						ENDIF

						Return(.F.)
			
					Endif
			
				EndIf
			
			EndIf
			
			// No caso de loja, n�o � permitido altera��o pois j� feita sua aprova��o
			If     SC5->C5_XREDE == 'N' .AND. SC5->C5_BLQ == " " .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. !IsInCallStack("A410DELETA")
				IF ALTERA   //&&Conforme Vagner em 15/06/11 a exclusao deve ser permitida.
					IF !Empty(SC5->C5_APROV1) .AND. !Empty(SC5->C5_LIBER1)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

						ELSE

							ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

						ENDIF
						Return(.F.)
					Elseif  !Empty(SC5->C5_APROV2) .AND. !Empty(SC5->C5_LIBER2)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
							cVendedor}) 
						ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

						ELSE

							ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

						ENDIF
						Return(.F.)
					Elseif  !Empty(SC5->C5_APROV3) .AND. !Empty(SC5->C5_LIBER3)
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

						ELSE

							ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

						ENDIF
						Return(.F.)
					EndIf
				ENDIF
			Elseif SC5->C5_XREDE == "N" .AND. SC5->C5_BLQ == "1" .And. Alltrim(cValToChar(SC5->C5_XGERSF)) <> "2" .And. !IsInCallStack("A410DELETA")
				IF !Empty(SC5->C5_APROV1) .AND. !Empty(SC5->C5_LIBER1)
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
						cVendedor}) 


					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

					ENDIF
					Return(.F.)
				Elseif  !Empty(SC5->C5_APROV2) .AND. !Empty(SC5->C5_LIBER2)
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

					ENDIF
					Return(.F.)
				Elseif  !Empty(SC5->C5_APROV3) .AND. !Empty(SC5->C5_LIBER3)
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O ' , ;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado. A T E N � � O '})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido j� sofreu aprova��o para VAREJO e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

					ENDIF

					Return(.F.)
				EndIf
			EndIf
		Endif
		
		//&&Mauricio 25/09/13 MDS TECNOLOGIA - Valido se pode alterar ou n�o pedido de doa��o Aprovado ou Reprovado(ja sofreu processo).
		If cEmpAnt == "01" ;
			.or. cEmpAnt == "09" //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG
			IF ALTERA
				If SC5->C5_STATDOA == "A" .Or. SC5->C5_STATDOA == "R"  &&A aprovado / R reprovado	   
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						'Pedido de doacao/bonificacao ja sofreu aprova��o e n�o pode ser mais alterado. A T E N � � O ' ,;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{'Pedido de doacao/bonificacao ja sofreu aprova��o e n�o pode ser mais alterado. A T E N � � O '})

					ELSE

						ApMsgInfo(OemToAnsi("Pedido de doacao/bonificacao ja sofreu aprova��o e n�o pode ser mais alterado."),OemToAnsi(" A T E N � � O "))

					ENDIF
					Return(.F.)	   
				Endif
			Endif   
		Endif
	Endif

	// Verifica se o pedido de venda j� foi roteirizado
	
	// @history ticket 8786 - 05/02/2021 - Fernando Macieira - Alterar ou Excluir Pedido de Venda - Base de Dados Adoro
	/*
	If cEmpAnt != "02" .AND. cEmpAnt != "07" ; // Ricardo Lima-04/01/2019-CH:037647-permite altera��o para rnx2
		.AND. cEmpAnt != "09" //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG
	*/
	If !(cEmpAnt $ _cEmpRotOK) // @history ticket 8786 - 05/02/2021 - Fernando Macieira - Alterar ou Excluir Pedido de Venda - Base de Dados Adoro

		If !Empty(SC5->C5_PLACA) .AND. Empty(SC5->C5_NOTA)

			IF IsInCallStack('U_ADVEN002P')  == .T.
				Aadd(aPedidos,{cchave, ;
				''    , ;
				''    , ;
				''    , ;
				'Este pedido nao pode ser alterado pois j� foi roterizado. ' + ;
				'Roteiro: ' + AllTrim(SC5->C5_ROTEIRO) + ' - Placa: ' + AllTrim(SC5->C5_PLACA) ,;
				cVendedor}) 

			ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
				Aadd(aPedidos,{"Este pedido nao pode ser alterado pois j� foi roteirizado." + Chr(13) + ;
				"Roteiro: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA),;
				"Bloqueado por Roteiro" })

			ELSE

				ApMsgInfo(OemToAnsi("Este pedido nao pode ser alterado pois j� foi roterizado." + Chr(13) + ;
				"Roteiro: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA),;
				"Bloqueado por Roteiro" ))

			ENDIF

			Return(.F.)
		EndIf


		If ! IsInCallStack('U_RESTEXECUTE') .And. !IsInCallStack('RESTEXECUTE') .And. Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. !IsInCallStack("A410DELETA") .And. !_lCopia .And. !IsInCallStack("U_AD0163") .And. !IsInCallStack("A410COPIA")"
			ApMsgInfo(OemToAnsi("Este pedido n�o pode ser alterado pois foi gerado pela integra��o com o SalesForce." ))		
			Return(.F.)

		EndIf

	EndIf


	// Valida em qual vendedor est� o cliente
	If ! IsInCallStack('RESTEXECUTE') .And. ! IsInCallStack('U_RESTEXECUTE')
		_lRet := U_VLDCART()

	EndIf
	
	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	// Everson - 13/05/2018. Chamado 037261, SalesForce.
	If Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF
	
		If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. IsInCallStack("A410DELETA") // Everson - 13/05/2018.
		
			//Estorna SC9.
			If ! Empty( Alltrim( cValToChar( SC5->C5_NOTA ) ) )
				MsgStop("O campo nota fiscal do pedido est� preenchido.","Fun��o M410ALOK")
				_lRet := .F.
			
			ElseIf ! Empty( Alltrim( cValToChar( SC5->C5_PLACA ) ) )
				MsgStop("O campo placa do pedido est� preenchido.","Fun��o M410ALOK")
				_lRet := .F.
				
			Else
			
				If MsgYesNo("Se houver itens liberados no pedido " + Alltrim(cValToChar(SC5->C5_NUM)) + ", estes ser�o estornados, para que a exclus�o prossiga. Deseja prosseguir?","Fun��o M410ALOK")
					estSC9( Alltrim(cValToChar( SC5->C5_NUM )) )
				
				EndIf
				
			EndIf
		
		EndIf
	
	EndIf

	RestArea(_aArea)

Return(_lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � VLDCART  �Autor  � RAFAEL H SILVEIRA  � Data �  19/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a carteira a qual o cliente faz parte, de acordo    ���
���          � com o definido no cadastro de vendedores.                  ��� 
���          � Rotina reajustada por Paulo, o Vulcano - TDS - 20/05/2011  ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico A'DORO                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
OBS.: ESTA FUN��O � UTILIZADA EM OUTROS PONTOS DO SISTEMA (APARENTEMENTE)
*/

User Function VLDCART()

	Local _lRet     := .T.
	Local _cVendor  := "",_cCarteira := "",_cSuper := "",_cGeren := ""
	Local _cVendCli := "1",_cSupCli := "1",_cGerCli := "1" 

	//Everson - 01/03/2018. Chamado 037261.SalesForce.
	If IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')
		Return _lRet

	EndIf

	dbSelectArea("SA3")
	dbSetOrder(7)

	IF dbSeek(xFilial("SA3")+__cUserId)

		_cVendor   := SA3->A3_COD
		_cCarteira := SA3->A3_CARTEIR // 1 = Propria; 2 = Supervisor; 3 = Gerente; 4 = Todas
		_cSuper    := SA3->A3_SUPER
		_cGeren    := SA3->A3_GEREN

		dbSelectArea("SA1")
		dbSetOrder(1)
		//if dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		If DBSEEK(XFILIAL("SA1")+_cCliente+_cLoja)

			dbSelectArea("SA3")
			dbSetOrder(1)
			if dbSeek(xFilial("SA3")+SA1->A1_VEND)

				_cVendCli := SA3->A3_COD
				_cSupCli  := SA3->A3_SUPER
				_cGerCli  := SA3->A3_GEREN

				IF _cCarteira != '4'
					IF     _cCarteira == '1'        // ACESSA APENAS CARTEIRA PROPRIA?
						IF _cVendor == _cVendCli // VENDEDOR DO CLIENTE � IGUAL � CARTEIRA?
							_lRet := .T.
						Else
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'CLIENTE N�O PERTENCE � CARTEIRA ' ,;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'CLIENTE N�O PERTENCE � CARTEIRA '})

							ELSE

								ApMsgAlert(OemToAnsi('CLIENTE N�O PERTENCE � CARTEIRA '+_cVendor))

							ENDIF

							_lRet := .F.
						EndIf
					ElseIf _cCarteira == '2'       // ACESSA TODA A CARTEIRA DO SUPERVISOR?
						IF _cSuper == _cSupCli  // SUPERVISOR DO VENDEDOR DO CLIENTE � IGUAL AO SUPERVISOR DA CARTEIRA?
							_lRet := .T.
						Else
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'CLIENTE N�O PERTENCE A UMA CARTEIRA DO SUPERVISOR '+_cSuper , ;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'CLIENTE N�O PERTENCE A UMA CARTEIRA DO SUPERVISOR '+_cSuper})

							ELSE

								ApMsgAlert(OemToAnsi('CLIENTE N�O PERTENCE A UMA CARTEIRA DO SUPERVISOR '+_cSuper))

							ENDIF

							_lRet := .F.
						EndIf
					ElseIf _cCarteira == '3'       // ACESSA TODA A CARTEIRA DO GERENTE?
						IF _cGeren == _cGerCli  // GERENTE DO VENDEDOR DO CLIENTE � IGUAL AO GERENTE DA CARTEIRA?
							_lRet := .T.
						Else  
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'CLIENTE N�O PERTENCE A UMA CARTEIRA DO GERENTE '+_cGeren , ;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'CLIENTE N�O PERTENCE A UMA CARTEIRA DO GERENTE '+_cGeren})

							ELSE

								ApMsgAlert(OemToAnsi('CLIENTE N�O PERTENCE A UMA CARTEIRA DO GERENTE '+_cGeren))

							ENDIF

							_lRet := .F.
						EndIf
					Else
						_lRet := .F.
					EndIf
				Else
					_lRet := .T.
				EndIf
			Endif
		Endif
	EndIf

Return(_lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �estSC9         �Autor  �Everson      � Data �  13/05/2018   ���
�������������������������������������������������������������������������͹��
���Desc.     �Estorna SC9 para exclus�o.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �Chamado 037261.                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function estSC9(cNumPed)

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	Local aArea	   := GetArea()
	Local nVlrCred := 0

	//Localiza o pedido na tabela SC9 e faz o estorno dos itens.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	If SC9->(DbSeek(xFilial("SC9") + cNumPed))

		//Faz o estorno dos itens liberados.
		While Alltrim(cValToChar(SC9->C9_FILIAL)) == xFilial("SC9") .And.;
		Alltrim(cValToChar(SC9->C9_PEDIDO)) == cNumPed

			nVlrCred := 0
			SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

			SC9->(DbSkip())

		EndDo

	EndIf	
	
	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If SC6->(DbSeek(xFilial("SC6") + cNumPed ))
		
		//Zera quantidade liberada.
		While Alltrim(cValToChar(SC6->C6_FILIAL)) == xFilial("SC6") .And.;
		Alltrim(cValToChar(SC6->C6_NUM)) == cNumPed
			
			RecLock("SC6",.F.)
				SC6->C6_QTDLIB	:= 0			
				SC6->C6_QTDEMP	:= 0	
				SC6->C6_QTDLIB2	:= 0
				SC6->C6_QTDEMP2	:= 0     
			SC6->(MsUnlock())
			
			SC6->(DbSkip())
			
		EndDo
		
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
