#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLDPRECO  º Autor ³ Mauricio da Silva  º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ programa chamado por gatilho (C6_PRCVEN) conforme solicita-º±±
±±º          ³ do por Vagner/Marcus coemrcial(preco maximo e minimo)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VLDPRECO()            

	Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> INICIAL PE" )

	_cArea := GetArea()

	_nRet  := M->C6_PRCVEN
	_nRetOri := M->C6_PRCVEN
	_cTpFrt := M->C5_TPFRETE
	//Local _nPrcMax := GETMV("MV_PRCMAX")
	_cTbPrMx   := GETMV("MV_TBPRMX")  // ALEX BORGES 01/03/12 ACRESCENTADO PARA VALIDAR O PRECO MAXIMO IGUAL A REGRA DO PREÇO MINIMO
	_cTbPrMnV  := GETMV("MV_TBPRMN")  &&Tabela preco minimo vendedor - Mauricio - MDS TEC - 11/12/2013
	_cTbPrMnS  := GETMV("MV_TBPRMNS") &&Tabela preco minimo supervisor - Mauricio - MDS TEC - 11/12/2013
	_cCliente := M->C5_CLIENTE
	_cLoja    := M->C5_LOJACLI
	_cVend    := M->C5_VEND1
	_nMoeda   := M->C5_MOEDA
	_dEmissao := M->C5_EMISSAO

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'programa chamado por gatilho (C6_PRCVEN) conforme solicita do por Vagner/Marcus coemrcial(preco maximo e minimo)')

	If cEmpAnt <> "01"   &&somente executa para empresa Adoro.
		Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
		return(_nret)

	Endif    

	If IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')
		Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
		return(_nret)

	EndIF

	dbSelectArea("SA3")
	dbSetOrder(7)

	_lVd := .F.
	_lSp := .F.              

	if Empty(_cCliente) .or. Empty(_cLoja) //incluido por Adriana em 19/08/16 - chamado 030218
		IF IsInCallStack('U_ADVEN002P')  == .T.
			Aadd(aPedidos,{cchave, ;
			''    , ;
			''    , ;
			''    , ;
			"INFORME CODIGO E LOJA DO CLIENTE!" ,;
			cVendedor}) 

		ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
			Aadd(aPedidos,{"INFORME CODIGO E LOJA DO CLIENTE!"})

		ELSE

			MsgInfo("INFORME CODIGO E LOJA DO CLIENTE!","Atenção")                

		ENDIF
		_nRet := 0.00
		RestArea(_cArea)

		Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )

		return(_nRet)
	endif

	If dbSeek(xFilial("SA3")+__cUserID)  				   // Só executa se usuario incluindo pedido for vendedor (primeira condição)
		&&Mauricio - MDS Tecnologia - 11/12/2013 - Validação de preço minimo sera diferenciado por supervisor e vendedor
		_lVd := .T.    &&é vendedor e não supervisor
		_lSp := .F.

		dbSelectArea("SA1")
		dbSetOrder(1)

		If SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja)) 

			_cVendedor  := SA1->A1_VEND  &&confirmado com Vagner, vendedor vem do cadastro de cliente e não do pedido
			_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_CODSUP")
			&&Mauricio - 06/08/14 - modificado forma de trazer supervisor conforme teste/validacao da rotina pelo Vagner.
			_cSupUsu    := Posicione("SZR",1,xFilial("SZR")+_cSuperv,"ZR_USER")

			If Alltrim(__cUserID) == Alltrim(_cSupUsu)
				_lSp := .T.        &&é supervisor e não vendedor
				_lVd := .F.
			Endif

			&&busco frete e contrato
			_nDesconto := SA1->A1_DESC   &&conforme M410STTS, mesmo rede o desconto vem do cliente do pedido.				   
			_cEst	  := SA1->A1_EST
			_cMunic    := SA1->A1_COD_MUN

			IF _cTpFrt == "C"
				If !Empty(_cMunic)
					_cRegiao:= Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA")  // Localizo a regiao do cliente
				EndIf

				If !Empty(_cRegiao)
					_nFrete := Posicione('ZZI',1,xFilial("ZZI")+_cRegiao,"ZZI_VALOR")         // Valor do frete para a regiao
				Else
					dbSelectArea("ZZI")                                                      // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
					dbSetOrder(3)
					dbSeek(_cEst)

					While ZZI->(!Eof()) .And. ZZI->ZZI_ESTADO == _cEst

						If _nFrete < ZZI->ZZI_VALOR
							_nFrete := ZZI->ZZI_VALOR
						EndIf

						ZZI->(dbSkip())

					EndDo
				EndIf
			Else
				_nFrete := 0.00
			Endif

			&&Valido o valor maximo
			/*if _nRet > _nPrcMax
			MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 
			_nRet := 0.00
			RestArea(_cArea)
			return(_nRet)
			endif */

			&&Mauricio - 17/12/14 - alteracao para incluir preco em dolar devido erro na alteracao no modulo de exportacao
			If _nMoeda == 1
				&&Validacao preco maximo permanece o mesmo  
				_NPOSPROD := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
				_cProd := ACOLS[N,_NPOSPROD]
				dbSelectArea("DA1")
				dbSetOrder(1) 	   
				If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMx)+_cProd)
					_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
					if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) > _nPrcTab
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'PREÇO NÃO PERMITIDO!' ,;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})

						ELSE

							MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

						ENDIF
						_nRet := 0.00
						RestArea(_cArea)
						Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
						return(_nRet)
					Endif
				Endif

				&&Valido o valor minimo
				&&Mauricio - MDS Tecnologia - 11/12/2013 - valido por vendedor e por supervisor em tabelas diferentes
				If _lVd	 &&vendedor
					If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMnV)+_cProd)
						_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
						if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) < _nPrcTab
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'PREÇO NÃO PERMITIDO!' ,;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})

							ELSE

								MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

							ENDIF
							_nRet := 0.00
							RestArea(_cArea)
							Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
							return(_nRet)
						Endif
					Endif
				Endif
				If _lSp	 &&supervisor
					If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMnS)+_cProd)
						_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
						if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) < _nPrcTab 
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'PREÇO NÃO PERMITIDO!' ,;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})

							ELSE

								MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

							ENDIF
							_nRet := 0.00
							RestArea(_cArea)
							Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
							return(_nRet)
						Endif
					Endif
				Endif
			Else  &&Se não tiver data cadastrada ou o valor for zero assume o valor de 1(para não dar erro na rotina).
				_nCota := 0
				DbSelectArea("SM2")
				DbSetOrder(1)
				if DbSeek(Dtos(_dEmissao))
					//Alterado por Adriana em 30/01/2018 para tratar outras moedas					   
					//				_nCota := M2_MOEDA2     //Pode ser EURO
					_nCota := &("M2_MOEDA"+STR(_nMoeda,1))
				Else
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						"Não ha moeda "+STR(_nMoeda,1)+" cadastrada na data de emissão do pedido: "+DTOC(_dEmissao) ,;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{"Não ha moeda "+STR(_nMoeda,1)+" cadastrada na data de emissão do pedido: "+DTOC(_dEmissao)})

					ELSE

						MsgInfo("Não ha moeda "+STR(_nMoeda,1)+" cadastrada na data de emissão do pedido: "+DTOC(_dEmissao))

					ENDIF       
					_nCota := 1
				Endif

				If _nCota == 0
					IF IsInCallStack('U_ADVEN002P')  == .T.
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						"O valor da moeda "+STR(_nMoeda,1)+" esta como zero no cadastro de moedas dia: "+DTOC(_dEmissao),;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{"O valor da moeda "+STR(_nMoeda,1)+" esta como zero no cadastro de moedas dia: "+DTOC(_dEmissao)})

					ELSE

						MsgInfo("O valor da moeda "+STR(_nMoeda,1)+" esta como zero no cadastro de moedas dia: "+DTOC(_dEmissao))

					ENDIF       
					_nCota := 1
				Endif   

				_nRet := _nRet * _nCota  &&transformo valor em dolar do pedido para real.

				&&Validacao preco maximo permanece o mesmo  
				_NPOSPROD := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
				_cProd := ACOLS[N,_NPOSPROD]
				dbSelectArea("DA1")
				dbSetOrder(1) 	   
				If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMx)+_cProd)
					_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
					if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) > _nPrcTab
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							'PREÇO NÃO PERMITIDO!' ,;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})

						ELSE

							MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

						ENDIF
						_nRet := 0.00
						RestArea(_cArea)
						Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
						return(_nRet)
					Endif                   
				Endif

				&&Valido o valor minimo
				&&Mauricio - MDS Tecnologia - 11/12/2013 - valido por vendedor e por supervisor em tabelas diferentes
				If _lVd	 &&vendedor
					If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMnV)+_cProd)
						_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
						if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) < _nPrcTab
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'PREÇO NÃO PERMITIDO!' ,;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})

							ELSE

								MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

							ENDIF
							_nRet := 0.00
							RestArea(_cArea)
							Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
							return(_nRet)                   
						Endif
					Endif
				Endif
				If _lSp	 &&supervisor
					If dbSeek(xFilial("DA1")+ALLTRIM(_cTbPrMnS)+_cProd)
						_nPrcTab := DA1->DA1_XPRLIQ				// Preco da tabela de precos
						if (_nRet - _nFrete - ((_nRet * _nDesconto)/100)  ) < _nPrcTab
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								'PREÇO NÃO PERMITIDO!' ,;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{'PREÇO NÃO PERMITIDO!'})	

							ELSE

								MsgInfo("PREÇO NÃO PERMITIDO!","Atenção")                 

							ENDIF
							_nRet := 0.00
							RestArea(_cArea)
							Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
							return(_nRet)                                       
						Endif
					Endif                                   
				Endif                  			 			 					   
			Endif                                
		Endif

		&&Mauricio - MDS TEC - 12/12/12 - Tratamento para validar inclusão de produto por Supervisor....
		DbSelectArea("SA3")
		DbSetOrder(1)
		if dbseek(xFilial("SA3")+_cVend)
			_cCodSup := SA3->A3_CODSUP
			_lGeral  := .F.
			&&Mauricio 26/12/12 - Validação para todos os produtos do supervisor - Inicio
			DbSelectArea("DA1")
			If dbseek(xFilial("DA1")+"Y00"+"999999") &&produto generico 999999(precisa existir)
				If DA1->DA1_000000 == "B"
					IF IsInCallStack('U_ADVEN002P')  == .T. 
						Aadd(aPedidos,{cchave, ;
						''    , ;
						''    , ;
						''    , ;
						"Venda de todos os produtos foi bloqueada pelo Comercial!",;
						cVendedor}) 

					ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
						Aadd(aPedidos,{"Venda de todos os produtos foi bloqueada pelo Comercial!"})

					ELSE

						MsgInfo("Venda de todos os produtos foi bloqueada pelo Comercial!","Atenção")

					ENDIF       
					_lGeral := .T. 
					_nRet := 0.00
				Else   
					_cCampo := "'DA1_"+_cCodSup+"'"
					_cCpo2  := "DA1->DA1_"+_cCodSup
					IF FieldPos(&_cCampo) > 0
						If &_cCpo2 == "B" 
							IF IsInCallStack('U_ADVEN002P')  == .T.
								Aadd(aPedidos,{cchave, ;
								''    , ;
								''    , ;
								''    , ;
								"Venda de todos os produtos foi bloqueada pelo Comercial!",;
								cVendedor}) 

							ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
								Aadd(aPedidos,{"Venda de todos os produtos foi bloqueada pelo Comercial!"})

							ELSE

								MsgInfo("Venda de todos os produtos foi bloqueada pelo Comercial!","Atenção")

							ENDIF	
							_lGeral := .T. 
							_nRet := 0.00
						Endif
					Endif                             
				Endif
			Endif         
			&&fim
			If !_lgeral            &&se não é "geral" valida bloqueio por produto.
				DbSelectArea("DA1")
				If dbseek(xFilial("DA1")+"Y00"+_cProd)
					If DA1->DA1_000000 == "B"
						IF IsInCallStack('U_ADVEN002P')  == .T.
							Aadd(aPedidos,{cchave, ;
							''    , ;
							''    , ;
							''    , ;
							"Produto bloqueado para venda pelo Comercial!",;
							cVendedor}) 

						ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
							Aadd(aPedidos,{"Produto bloqueado para venda pelo Comercial!"})

						ELSE

							MsgInfo("Produto bloqueado para venda pelo Comercial!","Atenção") 

						ENDIF	
						_nRet := 0.00
					Else   
						_cCampo := "'DA1_"+_cCodSup+"'"
						_cCpo2  := "DA1->DA1_"+_cCodSup
						IF FieldPos(&_cCampo) > 0
							If &_cCpo2 == "B"
								IF IsInCallStack('U_ADVEN002P')  == .T.
									Aadd(aPedidos,{cchave, ;
									''    , ;
									''    , ;
									''    , ;
									"Produto bloqueado para venda pelo Comercial!",;
									cVendedor}) 

								ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
									Aadd(aPedidos,{"Produto bloqueado para venda pelo Comercial!"})

								ELSE

									MsgInfo("Produto bloqueado para venda pelo Comercial!","Atenção") 

								ENDIF	
								_nRet := 0.00
							Endif
						Endif                             
					Endif
				endif
			Endif         
		Endif                   
	endif

	/*
	DbSelectarea("SC5")
	_cInclui := Substr(Embaralha(SC5->C5_USERLGI,1),1,15)

	_NPOSPROD := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
	_NPOSITEM := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_ITEM" } )

	_cItem := ACOLS[N,_NPOSITEM]
	_cProd := ACOLS[N,_NPOSPROD]

	DbSelectarea("SC6")
	DbSetOrder(1)
	IF dbseek(xfilial("SC6")+_cPed+_cITEM+_cProd)
	_nPrc := SC6->C6_PRCVEN
	IF _nPrc <> _nVlr         
	If ALLTRIM(_cUsu) <> ALLTRIM(_cInclui)
	MsgInfo("O preco so pode ser alterado pelo usuario que incluiu o pedido de venda!","Atenção")                 
	_nRet := _nPrc
	Endif
	Endif   
	Endif            
	*/

	//Alterado por Adriana em 30/01/2018 para tratar outras moedas					   
	//If _nMoeda = 2
	If _nMoeda <> 1 
		&&Se passou na validacao do preco em moeda 2 retorno o valor original ao campo.
		_nRet := _nRetOri  
	Endif    

	RestArea(_cArea)
	
	Conout( DToC(Date()) + " " + Time() + " VLDPRECO >>> FINAL PE" )
Return(_nRet)
