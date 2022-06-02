#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "AP5MAIL.CH"
/*/{Protheus.doc} User Function ConsLimFin
	Esta rotina calcula o limite disponivel do cliente para    
	exibição na consulta de posicao de clientes e liberacao / bloqueio dos
	pedidos de venda.                                                     
	Calcula o limite de crédito disponivel do cliente
	@type  Function
	@author Ana Helena
	@since 21/11/2012
	@version 01
	@history Everson, 22/04/2020, Chamado 057436 - Tratamento para bloqueio de pedidos de clientes com crédito expirado.
	@history Everson, 07/07/2020, Chamado T.I. - Tratamento para não bloquear pedido com flag Bradesco.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
	/*/ 
User Function ConsLimFin(cCodCli,_cTpCons,cRotina,_dDTE1,_dDTE2)

	//Local cPortador := ""
	//Local nPercen   := 0

	Public _cCliente:=cCodCli,_cNomeCli:="",_cTipoCli:="",_nValLim:=0,_nVlLmCad:=0,_nVlPed:=0,_nSldTit:=0,_nSldTPor:=0,_nSldTPerc:=0
	Public _nVlMnPed:=0,_nVlMnPSC:=0,_nVlMnParc:=0,_nDiasAtras:=0,_lDiasAtras:=.F.,_cRede:="",_eMailVend:="",_eMailSup:="",_cRotina:=cRotina,_cNmRede:=""
	Public _aAtrRede := {},nPercen:=0,cPortador := 0
	Public _cDtEntr := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina calcula o limite disponivel do cliente para exibição na consulta de posicao de clientes e liberacao / bloqueio dos pedidos de venda.')

	_aArea:=GetArea()

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+Alltrim(cCodCli))
		_cNomeCli := SA1->A1_NOME
	Endif

	//Valor Minimo do Pedido
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_VALOR FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'A' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	_nVlMnPed:=TMPF0->ZAD_VALOR
	DbCloseArea("TMPF0")

	//Valor Minimo do Pedido Sao Carlos
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_VALOR FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'B' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	_nVlMnPSC:=TMPF0->ZAD_VALOR
	DbCloseArea("TMPF0")

	//Valor Minimo da Parcela
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_VALOR FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'C' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	_nVlMnParc:=TMPF0->ZAD_VALOR
	DbCloseArea("TMPF0")

	//Dias de Atraso
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_DIAS FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'D' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	_nDiasAtras:=TMPF0->ZAD_DIAS
	DbCloseArea("TMPF0")

	//Portador Especial
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_PORTAD FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'E' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	cPortador:=TMPF0->ZAD_PORTAD
	DbCloseArea("TMPF0")

	//% Saldo de Titulo
	cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_PERCEN FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
	cQuery+= " WHERE ZAD_TABELA = 'F' "
	cQuery+= " AND D_E_L_E_T_ <> '*' "
	cQuery+= " ORDER BY ZAD_DATA DESC "

	TCQUERY cQuery new alias "TMPF0"
	TMPF0->(dbgotop())

	nPercen:=TMPF0->ZAD_PERCEN / 100
	DbCloseArea("TMPF0")

	//Calculo
	dbSelectArea("SZF")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))
		
		//CLIENTE INDIVIDUAL
		
		_cTipoCli := "Individual"
		
		//+ Soma dos limites do cliente do pedido em analise
		
		cQuery:= " SELECT SUM(A1_LC) AS A1_LC,A1_COD FROM " + RetSqlName("SA1") + " WITH(NOLOCK) "
		cQuery+= " WHERE A1_COD = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " GROUP BY A1_COD "
		cQuery+= " ORDER BY A1_COD "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		_nValLim  += TMPF0->A1_LC
		_nVlLmCad += TMPF0->A1_LC
		DbCloseArea("TMPF0")
		
		//- Soma dos pedidos a faturar do cliente (pedidos com data entrega >= data atual e liberados por cred/est)
		
		&&Mauricio - 06/04/16 - ALTERADO....estava abatendo do limite apenas o valor unitario da SC9 e não o total
				&&adicionado na query multiplicação pela quantidade....
		/*
		cQuery:= " SELECT SUM(C9_PRCVEN) AS C9_PRCVEN,C9_CLIENTE FROM " + RetSqlName("SC9") + " WITH(NOLOCK) "
		cQuery+= " WHERE C9_CLIENTE = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
		cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "
		cQuery+= " GROUP BY C9_CLIENTE "
		cQuery+= " ORDER BY C9_CLIENTE " 
		*/
		
		&&Mauricio - 23/11/16 - Conforme informação do Sr. Alberto, na analise do credito não devem ser considerados pedidos futuros
		&&ou seja, pedidos com data de entrega fora do periodo selecionado.. Anteriormente na query estava assim:
		&&cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
			
		cQuery:= " SELECT SUM(C9_PRCVEN * C9_QTDLIB) AS C9_PRCTOT,C9_CLIENTE FROM " + RetSqlName("SC9") + " WITH(NOLOCK) "
		cQuery+= " WHERE C9_CLIENTE = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' AND C9_NFISCAL = '' "
		//cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
		IF _cTpCons == "Out"   &&Mauricio - 30/11/16 - tratamento conforme definição Adriana.
		cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
		Else
		cQuery+= " AND C9_DTENTR BETWEEN '" + DTOS(_dDTE1) + "' AND '" + DTOS(_dDTE2) + "' " 
		Endif   
		//cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "     &&Mauricio - 15/02/17 - retirada condicao
		cQuery+= " GROUP BY C9_CLIENTE "
		cQuery+= " ORDER BY C9_CLIENTE "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		_nValLim -= TMPF0->C9_PRCTOT
		_nVlPed  += TMPF0->C9_PRCTOT
		DbCloseArea("TMPF0")
		
		//- Soma do saldo dos titulos em aberto
		
		cQuery:= " SELECT SUM(E1_SALDO) AS E1_SALDO,SUM(E1_VALOR) AS E1_VALOR,E1_CLIENTE,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+= " WHERE E1_CLIENTE = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND E1_SALDO > 0 "
		cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
		cQuery+= " GROUP BY E1_CLIENTE,E1_PORTADO "
		cQuery+= " ORDER BY E1_CLIENTE,E1_PORTADO "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		DbSelectArea ("TMPF0")
		Do While !EOF()
			
			_nValLim -= TMPF0->E1_SALDO
			_nSldTit += TMPF0->E1_SALDO
			
			//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD (poe de volta saldo para portadores especiais, porque não pode ser abatido do limite)
			
			If TMPF0->E1_PORTADO $ Alltrim(cPortador)
				_nValLim  += TMPF0->E1_SALDO
				_nSldTPor += TMPF0->E1_SALDO
			Endif
			
			DbSelectArea ("TMPF0")
			dbSkip()
		Enddo
		
		DbCloseArea("TMPF0")
			
		&&Mauricio - 13/04/16 - Conforme informações do Alberto a forma de avaliar o saldo percentual para bloqueio esta todo incorreto.
		&&Segundo ele, é para considerar somente titulos em aberto e em ATRASO e se tiver um unico titulo nesta condição com saldo maior que o
		&&percentual, ai é para bloquear. Assim vou levar o tratamento abaixo para um outro momento na avaliação.
		//+ Soma do saldo dos titulos com saldo menor que parametro - ZAD_PERCEN
		/*
		cQuery:= " SELECT E1_SALDO,E1_VALOR,E1_CLIENTE FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+= " WHERE E1_CLIENTE = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND E1_SALDO > 0 "
		cQuery+= " AND E1_SALDO <= (E1_VALOR * " + Alltrim(Str(nPercen)) + ")"
		cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
		cQuery+= " ORDER BY E1_CLIENTE "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		DbSelectArea ("TMPF0")
		Do While !EOF()
			
			_nValLim   += TMPF0->E1_SALDO
			_nSldTPerc += TMPF0->E1_SALDO
			
			DbSelectArea ("TMPF0")
			dbSkip()
		Enddo	
		
		DbCloseArea("TMPF0")
		*/
		
		//Verificando os titulos atrasados
		
		cQuery:= " SELECT E1_VENCREA,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+= " WHERE E1_SALDO > 0 "
		cQuery+= " AND E1_CLIENTE = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
		cQuery+= " AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA "
		cQuery+= " ORDER BY E1_CLIENTE "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		While !Eof() .And. !_lDiasAtras
			If (dDatabase - STOD(TMPF0->E1_VENCREA)) > _nDiasAtras
				If !(TMPF0->E1_PORTADO $ Alltrim(cPortador))
					_lDiasAtras := .T.
				Endif
			Endif
			DbSelectArea ("TMPF0")
			dbSkip()
		Enddo
		
		DbCloseArea("TMPF0")
		
	Else
		
		//CLIENTE REDE
		
		_cRede    := SZF->ZF_REDE
		_cNmRede  := SZF->ZF_NOMERED
		_cTipoCli := "Rede"
		
		cQuery:= " SELECT ZF_REDE,ZF_CGCMAT,SUM(ZF_LCREDE) AS ZF_LCREDE  FROM " + RetSqlName("SZF") + " WITH(NOLOCK) "
		cQuery+= " WHERE ZF_REDE = '" + Alltrim(_cRede) + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " GROUP BY ZF_REDE,ZF_CGCMAT "
		cQuery+= " ORDER BY ZF_REDE,ZF_CGCMAT "
		
		TCQUERY cQuery new alias "TMPFZ"
		TMPFZ->(dbgotop())
		
		DbSelectArea ("TMPFZ")
		Do While !EOF()
			
			//+ Soma dos limites da rede
			
			_nValLim  += TMPFZ->ZF_LCREDE
			_nVlLmCad += TMPFZ->ZF_LCREDE
			
			//+ Soma dos limites do cliente do pedido em analise
			
			cQuery:= " SELECT A1_COD FROM " + RetSqlName("SA1") + " WITH(NOLOCK) "
			cQuery+= " WHERE SUBSTRING(A1_CGC,1,8) = '" + Alltrim(TMPFZ->ZF_CGCMAT) + "' "
			cQuery+= " AND D_E_L_E_T_ <> '*' "
			cQuery+= " GROUP BY A1_COD "
			cQuery+= " ORDER BY A1_COD "
			
			TCQUERY cQuery new alias "TMPFSA1"
			TMPFSA1->(dbgotop())
			
			DbSelectArea ("TMPFSA1")
			Do While !EOF()
				
				cCodCli := TMPFSA1->A1_COD
				
				//- Soma dos pedidos a faturar do cliente (pedidos com data entrega >= data atual e liberados por cred/est)
				
				&&Mauricio - 06/04/16 - ALTERADO....estava abatendo do limite apenas o valor unitario da SC9 e não o total
				&&adicionado na query multiplicado pela quantidade....
				
				/*   original
				cQuery:= " SELECT SUM(C9_PRCVEN) AS C9_PRCVEN,C9_CLIENTE FROM " + RetSqlName("SC9") + " WITH(NOLOCK) "
				cQuery+= " WHERE C9_CLIENTE = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' "
				cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
				cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "
				cQuery+= " GROUP BY C9_CLIENTE "
				cQuery+= " ORDER BY C9_CLIENTE "
				*/
				
				&&Mauricio - 23/11/16 - Conforme informação do Sr. Alberto, na analise do credito não devem ser considerados pedidos futuros
				&&ou seja, pedidos com data de entrega fora do periodo selecionado..
				
				cQuery:= " SELECT SUM(C9_PRCVEN * C9_QTDLIB) AS C9_PRCTOT,C9_CLIENTE FROM " + RetSqlName("SC9") + " WITH(NOLOCK) "
				cQuery+= " WHERE C9_CLIENTE = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' AND C9_NFISCAL = '' "
				//cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "			
				IF _cTpCons == "Out"   &&Mauricio - 30/11/16 - tratamento conforme definição Adriana.
				cQuery+= " AND C9_DTENTR >= '" + DTOS(dDataBase) + "' "
				Else
				cQuery+= " AND C9_DTENTR BETWEEN '" + DTOS(_dDTE1) + "' AND '" + DTOS(_dDTE2) + "' " 
				Endif
				//cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "   &&Mauricio - 15/02/17 - 
				cQuery+= " GROUP BY C9_CLIENTE "
				cQuery+= " ORDER BY C9_CLIENTE "
				
				TCQUERY cQuery new alias "TMPF0"
				TMPF0->(dbgotop())
				
				_nValLim -= TMPF0->C9_PRCTOT
				_nVlPed  += TMPF0->C9_PRCTOT
				DbCloseArea("TMPF0")
				
				//- Soma do saldo dos titulos em aberto
				
				cQuery:= " SELECT SUM(E1_SALDO) AS E1_SALDO,SUM(E1_VALOR) AS E1_VALOR,E1_CLIENTE,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
				cQuery+= " WHERE E1_CLIENTE = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' "
				cQuery+= " AND E1_SALDO > 0 "
				cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
				cQuery+= " GROUP BY E1_CLIENTE,E1_PORTADO "
				cQuery+= " ORDER BY E1_CLIENTE,E1_PORTADO "
				
				TCQUERY cQuery new alias "TMPF0"
				TMPF0->(dbgotop())
				
				DbSelectArea ("TMPF0")
				Do While !EOF()
					
					_nValLim -= TMPF0->E1_SALDO
					_nSldTit += TMPF0->E1_SALDO
					
					//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD
					&&portador especial é retornado o saldo, pois não deve abater...
					
					If TMPF0->E1_PORTADO $ Alltrim(cPortador)
						_nValLim  += TMPF0->E1_SALDO
						_nSldTPor += TMPF0->E1_SALDO
					Endif
					
					DbSelectArea ("TMPF0")
					dbSkip()
				Enddo
				
				DbCloseArea("TMPF0")
				
				&&Mauricio - 13/04/16 - Conforme informações do Alberto a forma de avaliar o saldo percentual para bloqueio esta todo incorreto.
				&&Segundo ele, é para considerar somente titulos em aberto e em ATRASO e se tiver um unico titulo nesta condição com saldo maior que o
				&&percentual, ai é para bloquear. Assim vou levar o tratamento abaixo para um outro momento na avaliação.
				//+ Soma do saldo dos titulos com saldo menor que parametro - ZAD_PERCEN  e devolve ao limite o que estiver abaixo do percentual.
				/*
				cQuery:= " SELECT E1_SALDO,E1_VALOR,E1_CLIENTE FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
				cQuery+= " WHERE E1_CLIENTE = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' "
				cQuery+= " AND E1_SALDO > 0 "
				cQuery+= " AND E1_SALDO <= (E1_VALOR * " + Alltrim(Str(nPercen)) + ")"
				cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
				cQuery+= " ORDER BY E1_CLIENTE "
				
				TCQUERY cQuery new alias "TMPF0"
				TMPF0->(dbgotop())
				
				DbSelectArea ("TMPF0")
				Do While !EOF()
					
					_nValLim   += TMPF0->E1_SALDO
					_nSldTPerc += TMPF0->E1_SALDO
					
					DbSelectArea ("TMPF0")
					dbSkip()
				Enddo
				
				DbCloseArea("TMPF0")
				*/
				
				
				//Verificando os titulos atrasados
				
				cQuery:= " SELECT E1_VENCREA,E1_PORTADO,E1_CLIENTE,E1_LOJA,E1_NOMCLI FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
				cQuery+= " WHERE E1_SALDO > 0 "
				cQuery+= " AND E1_CLIENTE = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' "
				cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
				cQuery+= " AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA "
				cQuery+= " ORDER BY E1_CLIENTE "
				
				TCQUERY cQuery new alias "TMPF0"
				TMPF0->(dbgotop())
				
				While !Eof()
					If (dDatabase - STOD(TMPF0->E1_VENCREA)) > _nDiasAtras
						If !(TMPF0->E1_PORTADO $ Alltrim(cPortador))
							_lDiasAtras := .T.
							AADD(_aAtrRede,{TMPF0->E1_CLIENTE+" "+TMPF0->E1_LOJA+" - "+TMPF0->E1_NOMCLI})
						Endif
					Endif
					DbSelectArea ("TMPF0")
					dbSkip()
				Enddo
				
				DbCloseArea("TMPF0")
				
				dbSelectArea("TMPFSA1")
				dbSkip()
			Enddo
			
			DbCloseArea("TMPFSA1")
			
			dbSelectArea("TMPFZ")
			dbSkip()
		Enddo
		
	Endif

	DbCloseArea("TMPFZ")

	RestArea(_aArea)

Return()
/*/{Protheus.doc} User Function AtuLCPed
	Descricao ³Esta rotina libera / bloqueia o pedido por credito de acordo
	com o limite e regras financeiras.                                    
	Libera / Bloqueia os pedidos de venda  
	@type  Function
	@author Ana Helena
	@since 21/11/2012
	@version 01
	/*/ 
User Function AtuLCPed(_cPedido)

	Local lAvDtLm := GetMv("MV_#AVDTLM",,.F.) //Everson - 22/04/2020. Chamado 057436.

	lBCEntrou := .F.
	_aTipoBloq := {}
	nValPed := 0
	_Tipo := ""
	_estado := ""
	_cStAntPed := ""

	U_ADINF009P('CONSLIMFIN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina calcula o limite disponivel do cliente para exibição na consulta de posicao de clientes e liberacao / bloqueio dos pedidos de venda.')

	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(_cPedido)
		While !Eof() .And. SC6->C6_NUM == Substr(_cPedido,3,6)
			
			DbSelectArea("SC5")
			DbSetOrder(1)
			If DbSeek(_cPedido)
				_Tipo     := SC5->C5_TIPO
				_Estado   := SC5->C5_EST
				DbSelectArea("SF4")
				DbSetOrder(1)
				If dbseek(xFilial("SF4")+SC6->C6_TES)
					If !((ALLTRIM(SF4->F4_DUPLIC) == "S") .and. (ALLTRIM(_Tipo) $ "N/C") .and. (ALLTRIM(_estado)<> "EX"))         
						Reclock("SC5",.F.)
						SC5->C5_FLAGFIN := "L"
						MsUnlock()
						&&Mauricio - 15/02/17 - log de registro		  
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
						Replace ZBE_FILIAL WITH xFilial("ZBE")
						Replace ZBE_DATA   WITH dDataBase
						Replace ZBE_HORA   WITH TIME()
						Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
						Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM +" STATUS: "+SC5->C5_FLAGFIN
						Replace ZBE_MODULO WITH "SC5"
						Replace ZBE_ROTINA WITH "CONSLIMFIN"
						ZBE->(MsUnlock())
						
						Return
						
						
						
						
					Endif
				Else
					Return
				Endif
			Else
				Return
			Endif
			
			nValPed += SC6->C6_VALOR
			
			dbSelectArea("SC6")
			dbSkip()
		Enddo
	Else
		Return
	Endif

	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(_cPedido)
			
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		
		//Bloqueio - Condição de pagamento
		&&Mauricio - 13/04/16 - alterado forma de bloqueio para a condição de pagamento considerando agora o campo E4_DMEDI conforme Reginaldo/Alberto.
		//If !(Alltrim(SC5->C5_CONDPAG) == Alltrim(SA1->A1_COND))
		//	lBCEntrou := .T.
		//	AADD(_aTipoBloq,{"COND PGTO PED DIF COND PGTO CLIENTE"})
		//Endif
				
		_nMedPGPd := Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DMEDI")
		
		_nMedPGA1 := Posicione("SE4",1,xFilial("SE4")+SA1->A1_COND,"E4_DMEDI")
		
		IF _nMedPGPd == 0 .AND. SC5->C5_XPREAPR <> 'L' //chamado  031976 WILLIAM COSTA PEDIDO SENDO LIBERADO ERRADO POR FALTA DESSE IF 
		
			lBCEntrou := .T.
		
		ENDIF

		//Valida se o crédito do cliente expirou. Everson - 22/04/2020. Chamado 057436.
		If lAvDtLm .And. SA1->A1_VENCLC < Date()
			lBCEntrou := .T.
			AADD(_aTipoBloq,{"Limite de crédito do cliente está expirado (" + DToC(SA1->A1_VENCLC) + ")"})

		EndIf
		//

		If _nMedPGPd > _nMedPGA1  &&media da condição de pagto do pedido é maior do que media do cliente, bloqueia, só passa se for igual ou menor.
			lBCEntrou := .T.
			If Alltrim(_cTipoCli) == "Rede"
			AADD(_aTipoBloq,{"Prazo medio da condição de pagamento do pedido maior que o prazo medio na condição do Cliente - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
			AADD(_aTipoBloq,{"Prazo medio da condição de pagamento do pedido maior que o prazo medio na condição do Cliente"})
			Endif   
		Endif
			
		//Bloqueio - Valor Minimo do Pedido
		If Alltrim(SC5->C5_FILIAL) == "03"
			If nValPed < _nVlMnPSC
				lBCEntrou := .T.
				If Alltrim(_cTipoCli) == "Rede"
				AADD(_aTipoBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
				Else
				AADD(_aTipoBloq,{"VLR PEDIDO INF MINIMO"})
				Endif   
			Endif
		Else
			If nValPed < _nVlMnPed
				lBCEntrou := .T.
				If Alltrim(_cTipoCli) == "Rede"			
				AADD(_aTipoBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
				Else
				AADD(_aTipoBloq,{"VLR PEDIDO INF MINIMO"})
				Endif   
			Endif
		Endif
		
		//Se o pedido com valor 0 apresenta erro, no caso de pedidos cortados                                 
		If nValPed <> 0
			//Bloqueio - Valor Minimo da Parcela
			aCondPgto    := {}
		
			aCondPgto := CONDICAO(nValPed,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
		
			nValParc := aCondPgto[1,2]
		
			If nValParc < _nVlMnParc
				If nValParc <> nValPed
					lBCEntrou := .T.
					If Alltrim(_cTipoCli) == "Rede"	
						AADD(_aTipoBloq,{"VLR PARC INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
					Else
						AADD(_aTipoBloq,{"VLR PARC INF MINIMO"})
					Endif	
				Endif
			Endif
		Endif
		
		&&Bloqueio por saldo maior que percentual para titulos em atraso
		&&Mauricio - 13/04/16 - Conforme informações do Alberto a forma de avaliar o saldo percentual para bloqueio esta todo incorreto.
		&&Segundo ele, é para considerar somente titulos em aberto e em ATRASO e se tiver um unico titulo nesta condição com saldo maior que o
		&&percentual, ai é para bloquear. 
		
		//Bloqueio - Titulos em Atraso
		If _lDiasAtras
		&&Inclusão de tratamento para avaliar percentual para saldo de titulos(somente atrasados)	
		cQuery:= " SELECT E1_SALDO,E1_VALOR,E1_CLIENTE , E1_PREFIXO, E1_NUM, E1_PARCELA,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+= " WHERE E1_CLIENTE = '" + SC5->C5_CLIENTE + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND E1_SALDO > 0 "
		cQuery+= " AND E1_SALDO > (E1_VALOR * " + Alltrim(Str(nPercen)) + ")"
		cQuery+= " AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA "
		cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
		cQuery+= " ORDER BY E1_CLIENTE "
				
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
						
		DbSelectArea ("TMPF0")
		Do While !EOF()				
			&&Se encontrou um registro é porque achou titulo atrasado com percentual de saldo maior que parametro
			If !(TMPF0->E1_PORTADO $ Alltrim(cPortador))
				lBCEntrou := .T.
				&&Mauricio - 02/06/17 - Solicitado pelo Sr. Reginaldo que se desmembre a mensagem de atraso - Chamado 035526
				&&Titulo com saldo todo em aberto apenas vai mensagem TITULO EM ATRASO, se não, vai a mensagem anterior...		     
				If Alltrim(_cTipoCli) == "Rede"		        
					IF TMPF0->E1_SALDO == TMPF0->E1_VALOR  &&Saldo em aberto integral
					AADD(_aTipoBloq,{"TITULO EM ATRASO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					Else   
					AADD(_aTipoBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					Endif   
				Else
					IF TMPF0->E1_SALDO == TMPF0->E1_VALOR  &&Saldo em aberto integral
					AADD(_aTipoBloq,{"TITULO EM ATRASO. Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					ELSE
					AADD(_aTipoBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					ENDIF   
				Endif               
			Endif   
			DbSelectArea ("TMPF0")
			dbSkip()
		Enddo
				
		DbCloseArea("TMPF0")
		
		Endif
		
		&&Mauricio - 13/04/16 - retirado e jogado para cima pois segundo alberto tem vinculo com o saldo e seu percentual..
		/*		
		//Bloqueio - Titulos em Atraso
		If _lDiasAtras			 	
			lBCEntrou := .T.
			If Alltrim(_cTipoCli) == "Rede"
				AADD(_aTipoBloq,{"TITULO EM ATRASO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				AADD(_aTipoBloq,{"TITULO EM ATRASO"})
			Endif
		Endif
		*/
		
		//Bloqueio - Valor do Pedido Maior que o Limite Disponivel
		//If nValPed > _nValLim
		//IF nValPed > (  _nValLim + _nVlPed)
		
		If nValPed > (  _nValLim + nValPed )     &&Mauricio - 16/11/16 - tratamento adicionando o valor do pedido porque este ja foi abatido do limite de credito na variavel _nVLPED bem acima(todos os pedidos).
			lBCEntrou := .T.
			If Alltrim(_cTipoCli) == "Rede"
				AADD(_aTipoBloq,{"LIMITE EXCEDIDO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
			Else
				AADD(_aTipoBloq,{"LIMITE EXCEDIDO"})
			Endif
		Endif
		
	Endif
		
	//Liberacao / Bloqueio
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(_cPedido)

		//Everson - 07/07/2020. Chamado T.I.
		//If Alltrim(cValToChar(SC5->C5_XWSPAGO)) == "S"
		If !Empty(Alltrim(cValToChar(SC5->C5_XWSPAGO))) // @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
			lBCEntrou := .F.
			_aTipoBloq := {}
			//Static Call(F200AVL,limpZBH,cValToChar(SC5->C5_NUM))
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
			u_200AVLA0(cValToChar(SC5->C5_NUM))
		EndIf
		//

		_cDtEntr := DTOC(SC5->C5_DTENTR)
		_cStAntPed := SC5->C5_FLAGFIN
		Reclock("SC5",.F.)
		If lBCEntrou
			SC5->C5_FLAGFIN := "B"
		Else
			SC5->C5_FLAGFIN := "L"
		Endif
		MsUnLock()
		&&Mauricio - 15/02/17 - log de registro		  
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
		Replace ZBE_FILIAL WITH xFilial("ZBE")
		Replace ZBE_DATA   WITH dDataBase
		Replace ZBE_HORA   WITH TIME()
		Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
		Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM +" STATUS: "+SC5->C5_FLAGFIN
		Replace ZBE_MODULO WITH "SC5"
		Replace ZBE_ROTINA WITH "CONSLIMFIN"
		ZBE->(MsUnlock())
		
	Endif       

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(_cPedido)
		
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
	_eMailVend := SA3->A3_EMAIL
		
	DbSelectArea("SZR")
	DbSetOrder(1)
	DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
	_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))

	//Envio de Email com Descrição dos Bloqueios
	If lBCEntrou

		&&Mauricio - 28/09/16 - tratamento para gravaçao dos pedidos de venda bloqueados e seus motivos...
		&&inicio
		DbSelectArea("ZBH")
		DbSetOrder(1)
		If DbSeek(_cPedido)    && Como posso rodar a rotina diversas vezes em um dia se ja existe bloqueio eu deleto para gravar novo(ultimos) motivos..
		While ZBH->(!Eof()) .And. ZBH->ZBH_FILIAL  == Substr(_cPedido,1,2) .And. ZBH->ZBH_PEDIDO  == Substr(_cPedido,3,6)
				Reclock("ZBH",.F.)
				DbDelete()
				ZBH->(MsUnlock())
				ZBH->(dbSkip())
		Enddo
		Endif
		
		For _xx := 1 to len(_aTipoBloq)
			Reclock("ZBH",.T.)
			ZBH->ZBH_FILIAL  := Substr(_cPedido,1,2)
			ZBH->ZBH_PEDIDO  := Substr(_cPedido,3,6)
			ZBH->ZBH_CLIENT  := SC5->C5_CLIENTE
			ZBH->ZBH_LOJA    := SC5->C5_LOJACLI
			ZBH->ZBH_NOME    := SC5->C5_NOMECLI
			ZBH->ZBH_MOTIVO  := _aTipoBloq[_xx][1]
			&&Mauricio - 01/02/17 - chamado 033003
			ZBH->ZBH_CODVEN  := SC5->C5_VEND1
			ZBH->ZBH_NOMVEN  := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
			ZBH->(MsUnlock()) 
		Next _xx
		&&fim
							
		//Para nao enviar varias vezes email dos pedidos bloqueados
		If AlLtrim(_cStAntPed) <> "B" 
			U_SendMlLC(Substr(_cPedido,3,6),"BLQ",_cRotina,_eMailVend,_eMailSup)
		Endif
			
	Else
		U_SendMlLC(Substr(_cPedido,3,6),"LIB",_cRotina,_eMailVend,_eMailSup)
	Endif

	DbCloseArea("TMPFZ")

	//RestArea(_aArea)

Return()
/*/{Protheus.doc} User Function SendMlLC

	@type  Function
	@author Ana Helena
	@since 21/11/2012
	@version 01
	/*/
User Function SendMlLC(_cPedido,_cStatEml,_cRotina,_eMailVend,_eMailSup)

	Local lOk       	:= .T.
	Local cBody			:= RetHTML(_cPedido,_cStatEml)
	Local cErrorMsg		:=	""
	Local aFiles 		:= {} 
	Local cServer      := Alltrim(GetMv("MV_INTSERV")) 

	Local cAccount     := AllTrim(GetMv("MV_INTACNT"))

	Local cPassword    := AllTrim(GetMv("MV_INTPSW"))

	Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
	//Local cServer     	:=	Alltrim(GetMv("MV_RELSERV"))
	//Local cAccount    	:=	AllTrim(GetMv("MV_RELACNT"))
	//Local cPassword   	:=	AllTrim(GetMv("MV_RELPSW"))
	//Local cFrom       	:=	AllTrim(GetMv("MV_RELACNT"))
	//Local cTo         	:=	"alberto@adoro.com.br;calderan@adoro.com.br" //;reginaldo@adoro.com.br"      
	//Local cTo         	:=	AllTrim(GetMv("ZZ_CISPCC")) + ";"+ Alltrim(_eMailVend)+";"+Alltrim(_eMailSup)
	Local cTo         	:=  AllTrim(GetMv("MV_#MAILLC")) //Incluido email por parametro - por Adriana Oliveira - chamado 026691
	Local lSmtpAuth  	:= GetMv("MV_RELAUTH",,.F.)
	Local lAutOk     	:= .F.
	Local cAtach 		:= ""
	Local cSubject := ""

	//If Alltrim(_cRotina) == "VEN"
	//	cTo := cTo + ";" + _eMailVend + ";" + _eMailSup
	//Endif

	U_ADINF009P('CONSLIMFIN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina calcula o limite disponivel do cliente para exibição na consulta de posicao de clientes e liberacao / bloqueio dos pedidos de venda.')

	If _cStatEml == "BLQ"
		cSubject := "PEDIDO Nº " + _cPedido + " BLOQUEADO POR CREDITO"
	Else
		cSubject := "PEDIDO Nº " + _cPedido + " LIBERADO POR CREDITO"
	Endif

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

	Static Function RetHTML(_cPedido,_cStatEml)
	Local cRet	:=	""

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>PEDIDO............: </b>" + _cPedido
	cRet += "<br>"

	cRet += "<b>DT ENTREGA....: </b>" + _cDtEntr
	cRet += "<br>"

	cRet += "<b>CLIENTE............: </b>" + _cCliente + " - " + _cNomeCli
	cRet += "<br>"
											
	cRet += "<b>STATUS.............: </b>"
	If _cStatEml == "BLQ"
		cRet += " PEDIDO BLOQUEADO PARA ANALISE"
	Else                                  
		cRet += " PEDIDO LIBERADO POR CREDITO"
	Endif
	cRet += "<br>"

	If _cStatEml == "BLQ"
		cRet += "<b>MOTIVO BLOQ.:</b><ul>"

		For i:=1 to len(_aTipoBloq)
			If i <> 1
				cRet += "<br><br>"
			Endif
			cRet += "<li type=disc>" + _aTipoBloq[i,1]
		
			If Alltrim(_aTipoBloq[i,1]) == "TITULO EM ATRASO - REDE "+Alltrim(_cRede)+" - "+_cNmRede
				For j:=1 to len(_aAtrRede)
					If j==1
						cRet += "<li type=circle>" +_aAtrRede[j,1]
					Else
						If _aAtrRede[j,1] != _aAtrRede[j-1,1]
							cRet += "<li type=circle>" +_aAtrRede[j,1]
						Endif
					Endif
				Next
			Endif
		Next
		cRet += "</ul>"
		cRet += "<br><b>OBSERVAÇÃO: </b>O PEDIDO ESTA RETIDO PARA VERIFICAÇÃO DO SETOR DE CREDITO.<br>"	
	Else	
		cRet += "<br><b>OBSERVAÇÃO: </b>O PEDIDO ESTA LIBERADO PELOS CRITERIOS DE CREDITO.<br>"
	Endif	

	cRet += "<br><br>ATT, <br> CREDITO <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"

	cRet		+=	'</span>'
	cRet		+=	'</body>'
	cRet		+=	'</html>'

Return(cRet)
