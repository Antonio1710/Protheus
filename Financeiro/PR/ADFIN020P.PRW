#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "AP5MAIL.CH"

/*/{Protheus.doc} User Function ADFIN020P
	Descricao ³Esta rotina libera / bloqueia o pedido por credito de acordo
	com o limite e regras financeiras (baseada ATULCPED).
	Libera / Bloqueia os pedidos de venda.
	@type  Function
	@author Mauricio - MDS TEC
	@since 21/11/2012
	@version 01
	@history Everson, 22/04/2020, Chamado 057436 - Tratamento para bloqueio de pedidos de clientes com crédito expirado.
	@history chamado 056247 - FWNM     - 08/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 059415 - FWNM     - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	@history chamado TI     - FWNM     - 14/08/2020 - Desativação devido impactos de block no SF
	@history chamado 060683 - Everson  - 20/08/2020 - Melhorar performance.
	@history Ticket  8      - Abel B.  - 29/01/2021 - Execução de forma automática na Inclusão e Alteração do Pedido de Venda
	@history Ticket  8913   - Abel B.  - 01/02/2021 - Correção de error.log - variable does not exist CFILPED
	@history Ticket  8      - Abel B.  - 02/02/2021 - Retirar mensagem de erro quando não localizar o pedido
	@history Ticket  8      - Abel B.  - 08/02/2021 - Retirar mensagem de erro quando não localizar o pedido e correções para atender ao novo processo de liberação de credito
	@history Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da função uptSC5
	@history Ticket  T.I.   - Abel B.  - 26/02/2021 - Correção de fontes e mensagem incorreta.
/*/
User Function ADFIN020P(cCodCli,_cTpCons,cRotina)

	//Variáveis.
	Local cTIni := Time() //Everson - 20/08/2020. Chamado 060683.

	Public _cCliente:=cCodCli,_cNomeCli:="",_cTipoCli:="",_nValLim:=0,_nVlLmCad:=0,_nVlPed:=0,_nSldTit:=0,_nSldTPor:=0,_nSldTPerc:=0
	Public _nVlMnPed:=0,_nVlMnPSC:=0,_nVlMnParc:=0,_nDiasAtras:=0,_lDiasAtras:=.F.,_cRede:="",_eMailVend:="",_eMailSup:="",_cRotina:=cRotina,_cNmRede:=""
	Public _aAtrRede := {},nPercen:=0,cPortador := 0
	Public _cDtEntr := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina libera / bloqueia o pedido por credito de acordo com o limite e regras financeiras (baseada ATULCPED)')

	//Ticket  8      - Abel B.  - 29/01/2021 - Execução de forma automática na Inclusão e Alteração do Pedido de Venda
	IF IsInCallStack("U_M410STTS") .or. IsInCallStack("U_TELACORTE")
		MV_PAR01 := SC5->C5_DTENTR
		MV_PAR02 := SC5->C5_DTENTR
	ENDIF


	_aArea:=GetArea()

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(FWxFilial("SA1")+Alltrim(cCodCli))
		_cNomeCli := SA1->A1_NOME
	EndIf

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
	If !dbSeek(FWxFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))
		
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
		
		//Conforme entendimento com TI da Adoro para pre aprovacao deve ser olhado C6 e não o C9.
		//Mauricio - 23/11/16 - Conforme informação do Sr. Alberto, na analise do credito não devem ser considerados pedidos futuros
		//ou seja, pedidos com data de entrega fora do periodo selecionado..
		cQuery:= " SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS C6_PRCTOT, C6_CLI FROM " + RetSqlName("SC6") + " WITH(NOLOCK) "
		cQuery+= " WHERE C6_CLI = '" + cCodCli + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "		
		//cQuery+= " AND C6_ENTREG >= '" + DTOS(dDataBase) + "' "
		cQuery+= " AND C6_ENTREG BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' " 
		cQuery+= " AND ((C6_QTDVEN - C6_QTDENT) > 0) "    //somente em aberto
		//cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "
		cQuery+= " GROUP BY C6_CLI "
		cQuery+= " ORDER BY C6_CLI "
		
		TCQUERY cQuery new alias "TMPF0"
		TMPF0->(dbgotop())
		
		_nValLim -= TMPF0->C6_PRCTOT
		_nVlPed  += TMPF0->C6_PRCTOT

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
			EndIf
			
			DbSelectArea ("TMPF0")
			dbSkip()

		Enddo
		
		DbCloseArea("TMPF0")
			
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
				EndIf
			EndIf
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
				
				//Mauricio - 23/11/16 - Conforme informação do Sr. Alberto, na analise do credito não devem ser considerados pedidos futuros
				//ou seja, pedidos com data de entrega fora do periodo selecionado..
				cQuery:= " SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS C6_PRCTOT,C6_CLI FROM " + RetSqlName("SC6") + " WITH(NOLOCK) "
				cQuery+= " WHERE C6_CLI = '" + cCodCli + "' "
				cQuery+= " AND D_E_L_E_T_ <> '*' "
				//cQuery+= " AND C6_ENTREG >= '" + DTOS(dDataBase) + "' "
				cQuery+= " AND C6_ENTREG BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
				cQuery += "AND ((C6_QTDVEN - C6_QTDENT) > 0)"    //somente em aberto
				//cQuery+= " AND C9_BLCRED = '' AND C9_BLEST = '' "
				cQuery+= " GROUP BY C6_CLI "
				cQuery+= " ORDER BY C6_CLI "
				
				TCQUERY cQuery new alias "TMPF0"
				TMPF0->(dbgotop())
				
				_nValLim -= TMPF0->C6_PRCTOT
				_nVlPed  += TMPF0->C6_PRCTOT
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
					//portador especial é retornado o saldo, pois não deve abater...
					
					If TMPF0->E1_PORTADO $ Alltrim(cPortador)
						_nValLim  += TMPF0->E1_SALDO
						_nSldTPor += TMPF0->E1_SALDO
					EndIf
					
					DbSelectArea ("TMPF0")
					dbSkip()

				Enddo
				
				DbCloseArea("TMPF0")
				
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
							Aadd(_aAtrRede,{TMPF0->E1_CLIENTE+" "+TMPF0->E1_LOJA+" - "+TMPF0->E1_NOMCLI})
						EndIf
					EndIf
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
		
	EndIf

	_cT1 := _nValLim
	_cT2 := _nVLPed
	_cT3 := _nSldTit

	Conout( DToC(Date()) + " " + Time() +  " ADFIN020P Time Total " + cCodCli + "   " + cValToChar(ElapTime( cTIni, Time() ))) //Everson - 20/08/2020. Chamado 060683.

	DbCloseArea("TMPFZ")

	RestArea(_aArea)

Return()

/*/{Protheus.doc} User Function ADFIN021P
	(long_description)
	@type  Function
	@author 
	@since 
	@version 01
/*/
User Function ADFIN021P(_cPedido)

	//Variáveis.
	Local aArea 		:= GetArea()
	Local lAvDtLm  		:= GetMv("MV_#AVDTLM",,.F.) //Everson - 22/04/2020. Chamado 057436.
	Local lBCEntrou 	:= .F.
	Local aTipoBloq 	:= {}
	Local nValPed 		:= 0
	Local cStAntPed 	:= ""

	//Everson - 20/08/2020. Chamado 060683.
	Local cUpt     := "" 
	Local nAux	   := 1
	Local cQuery   := ""	
	//
	Local cTIni := Time()
	Local cTime := Time()

	//
	U_ADINF009P('ADFIN020P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina libera / bloqueia o pedido por credito de acordo com o limite e regras financeiras (baseada ATULCPED)')

	// @history chamado TI     - FWNM - 14/08/2020 - Desativação devido impactos de block no SF

	//Everson - 20/08/2020. Chamado 060683.
	cQuery := ""
	cQuery += " SELECT " 
		cQuery += " C5_NUM, " 
		cQuery += " SUM(C6_VALOR) AS C6_VALOR, " 
		cQuery += " SUM(CASE WHEN NOT(F4_DUPLIC = 'S' AND C5_TIPO IN ('N','C') AND C5_EST <> 'EX') THEN 1 ELSE 0 END) AS FLAG " 
	cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
		cQuery += " C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SF4") + " (NOLOCK) AS SF4 ON " 
		cQuery += " C6_TES = F4_CODIGO " 
	cQuery += " WHERE " 
		cQuery += " RTRIM(LTRIM(C5_FILIAL)) + RTRIM(LTRIM(C5_NUM)) = '" + _cPedido + "' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND SF4.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY " 
		cQuery += " C5_NUM " 

	//
	If Select("D_CHLIB") > 0
		D_CHLIB->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CHLIB"
	DbSelectArea("D_CHLIB")
	D_CHLIB->(DbGoTop())
	If D_CHLIB->(Eof())
		D_CHLIB->(DbCloseArea())
		// MsgAlert("Pedido " + _cPedido + " não localizado.","Função ADFIN021P(ADFIN020P)") //Ticket  8      - Abel B.  - 08/02/2021 - Retirar mensagem de erro quando não localizar o pedido e correções para atender ao novo processo de liberação de credito

		//Registra Pedido não encontrado
		DbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL WITH FWxFilial("ZBE")
			Replace ZBE_DATA   WITH dDataBase
			Replace ZBE_HORA   WITH Time()
			Replace ZBE_USUARI WITH Upper(Alltrim(cUserName))
			Replace ZBE_LOG    WITH "FILIAL+PEDIDO " + _cPedido + " NAO LOCALIZADO"
			Replace ZBE_MODULO WITH "SC5"
			Replace ZBE_ROTINA WITH "ADFIN021P"
		ZBE->(MsUnlock())

		RestArea(aArea)
		Return Nil

	Else 

		//
		If Val(cValToChar(D_CHLIB->FLAG)) > 0
			// uptSC5(_cPedido,"L") //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da função uptSC5
			If SC5->(MsSeek(_cPedido))
				IF RecLock("SC5",.F.)
					SC5->C5_XPREAPR := 'L'
					SC5->( MsUnLock() ) 
				ENDIF
			ENDIF

			D_CHLIB->(DbCloseArea())  
			RestArea(aArea)
			Return Nil

		Else

			//
			nValPed := D_CHLIB->C6_VALOR

		EndIf

	EndIf

	//
	D_CHLIB->(DbCloseArea())  

	Conout("Time 1 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()

	//
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If ! SC5->(DbSeek(_cPedido))
		//MsgAlert("Pedido " + _cPedido + " não localizado.","Função ADFIN021P(ADFIN020P)") //Ticket  8      - Abel B.  - 08/02/2021 - Retirar mensagem de erro quando não localizar o pedido e correções para atender ao novo processo de liberação de credito
		RestArea(aArea)
		Return Nil 

	EndIf

	//		
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If ! SA1->(DbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
		//MsgAlert("Cliente " + SC5->C5_CLIENTE+SC5->C5_LOJACLI + " não localizado.","Função ADFIN021P(ADFIN020P)") //Ticket  8      - Abel B.  - 08/02/2021 - Retirar mensagem de erro quando não localizar o pedido e correções para atender ao novo processo de liberação de credito
		RestArea(aArea)
		Return Nil 

	EndIf
	
	//
	_nMedPGPd := Posicione("SE4",1,FWxFilial("SE4") + SC5->C5_CONDPAG,"E4_DMEDI")
	_nMedPGA1 := Posicione("SE4",1,FWxFilial("SE4") + SA1->A1_COND   ,"E4_DMEDI")
	
	//Média da condição de pagto do pedido é maior do que media do cliente, bloqueia, só passa se for igual ou menor.
	If _nMedPGPd > _nMedPGA1
		lBCEntrou := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTipoBloq,{"Prazo medio da condição de pagamento do pedido maior que o prazo medio na condição do Cliente - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		
		Else
			Aadd(aTipoBloq,{"Prazo medio da condição de pagamento do pedido maior que o prazo medio na condição do Cliente"})
		
		EndIf 

	EndIf

	//Valida se o crédito do cliente expirou. Everson - 22/04/2020. Chamado 057436.
	If lAvDtLm .And. SA1->A1_VENCLC < Date()
		lBCEntrou := .T.
		Aadd(aTipoBloq,{"Limite de crédito do cliente está expirado (" + DToC(SA1->A1_VENCLC) + ")"})

	EndIf
	//

	Conout("Time 2 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()

	//Bloqueio - Valor Minimo do Pedido
	If Alltrim(SC5->C5_FILIAL) == "03"
		If nValPed < _nVlMnPSC
			lBCEntrou := .T.
			If Alltrim(_cTipoCli) == "Rede"
				Aadd(aTipoBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})

			Else
				Aadd(aTipoBloq,{"VLR PEDIDO INF MINIMO"})

			EndIf  

		EndIf

	Else
		If nValPed < _nVlMnPed
			lBCEntrou := .T.
			If Alltrim(_cTipoCli) == "Rede"			
				Aadd(aTipoBloq,{"VLR PEDIDO INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})

			Else
				Aadd(aTipoBloq,{"VLR PEDIDO INF MINIMO"})

			EndIf 

		EndIf

	EndIf

	Conout("Time 3 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()
	
	//Se o pedido com valor 0 apresenta erro, no caso de pedidos cortados                          
	If nValPed <> 0
		//Bloqueio - Valor Minimo da Parcela
		aCondPgto := {}
		aCondPgto := CONDICAO(nValPed,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
		nValParc  := aCondPgto[1,2]

		//
		If nValParc < _nVlMnParc
			If nValParc <> nValPed
				lBCEntrou := .T.
				If Alltrim(_cTipoCli) == "Rede"	
					Aadd(aTipoBloq,{"VLR PARC INF MINIMO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})

				Else
					Aadd(aTipoBloq,{"VLR PARC INF MINIMO"})

				EndIf

			EndIf

		EndIf

	EndIf

	Conout("Time 4 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()
	
	//Bloqueio por saldo maior que percentual para titulos em atraso
	//Mauricio - 13/04/16 - Conforme informações do Alberto a forma de avaliar o saldo percentual para bloqueio esta todo incorreto.
	//Segundo ele, é para considerar somente titulos em aberto e em ATRASO e se tiver um unico titulo nesta condição com saldo maior que o
	//percentual, ai é para bloquear. 
	
	//Bloqueio - Titulos em Atraso
	If _lDiasAtras

		//Inclusão de tratamento para avaliar percentual para saldo de titulos(somente atrasados)
		cQuery:= " SELECT E1_SALDO,E1_VALOR,E1_CLIENTE , E1_PREFIXO, E1_NUM, E1_PARCELA,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
		cQuery+= " WHERE E1_CLIENTE = '" + SC5->C5_CLIENTE + "' "
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		cQuery+= " AND E1_SALDO > 0 "
		cQuery+= " AND E1_SALDO > (E1_VALOR * " + Alltrim(Str(nPercen)) + ")"
		cQuery+= " AND CONVERT(CHAR(10), GETDATE(),112) > E1_VENCREA "
		cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
		cQuery+= " ORDER BY E1_CLIENTE "

		//
		MsAguarde({|| DbUseArea(.F., "TOPCONN", TcGenQry(,,cQuery), "TMPF0", .F., .T.) },"Função ADFIN021P(ADFIN020P)","Consultando SE1...")	
		TMPF0->(dbgotop())
						
		//
		While ! TMPF0->(EOF())

			//Se encontrou um registro é porque achou titulo atrasado com percentual de saldo maior que parametro
			If !(TMPF0->E1_PORTADO $ Alltrim(cPortador))
				lBCEntrou := .T.
				//Mauricio - 02/06/17 - Solicitado pelo Sr. Reginaldo que se desmembre a mensagem de atraso - Chamado 035526
				//Titulo com saldo todo em aberto apenas vai mensagem TITULO EM ATRASO, se não, vai a mensagem anterior...
				If Alltrim(_cTipoCli) == "Rede"
					If TMPF0->E1_SALDO == TMPF0->E1_VALOR  //Saldo em aberto integral
						Aadd(aTipoBloq,{"TITULO EM ATRASO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					
					Else
						Aadd(aTipoBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. REDE "+Alltrim(_cRede)+" - "+_cNmRede+" Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					
					EndIf   
				Else
					If TMPF0->E1_SALDO == TMPF0->E1_VALOR  //Saldo em aberto integral
						Aadd(aTipoBloq,{"TITULO EM ATRASO. Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					
					Else
						Aadd(aTipoBloq,{"TITULO ATRASO - PERCENTUAL DE SALDO MAIOR QUE PARAMETRO. Titulo: "+TMPF0->E1_PREFIXO+"-"+TMPF0->E1_NUM+"-"+TMPF0->E1_PARCELA})
					
					EndIf  

				EndIf 

			EndIf   

			//
			TMPF0->(DbSkip())

		End

		//		
		TMPF0->(DbCloseArea())
	
	EndIf

	Conout("Time 5 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()
	
	//Bloqueio - Valor do Pedido Maior que o Limite Disponivel
	If nValPed > (  _nValLim + nValPed )     //Mauricio - 09/11/16 - tratamento adicionando o valor do pedido porque este ja foi abatido do limite de credito na variavel _nVLPED bem acima(todos os pedidos).
		
		//
		lBCEntrou := .T.
		If Alltrim(_cTipoCli) == "Rede"
			Aadd(aTipoBloq,{"LIMITE EXCEDIDO - REDE "+Alltrim(_cRede)+" - "+_cNmRede})
		Else
			Aadd(aTipoBloq,{"LIMITE EXCEDIDO"})

		EndIf

	EndIf

	//
	_cDtEntr := DTOC(SC5->C5_DTENTR)
	cStAntPed := SC5->C5_FLAGFIN

	Conout("Time 6 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()

	//Ticket  8      - Abel B.  - 08/02/2021 - Retirar mensagem de erro quando não localizar o pedido e correções para atender ao novo processo de liberação de credito
	IF lBCEntrou
		If SC5->(MsSeek(_cPedido))
			IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da função uptSC5
				SC5->C5_XPREAPR := 'B'
				SC5->( MsUnLock() ) 
			ENDIF
		ENDIF
	ELSE
		If SC5->(MsSeek(_cPedido))
			IF RecLock("SC5",.F.) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da função uptSC5
				SC5->C5_XPREAPR := 'L'
				SC5->( MsUnLock() ) 
			ENDIF
		ENDIF
	ENDIF
	
	// If ! uptSC5(_cPedido,Iif(lBCEntrou,"B","L")) //Ticket  8      - Abel B.  - 09/02/2021 - Retirar chamadas da função uptSC5
		// MsgAlert("Ocorreu erro na gravação de status do pedido " + _cPedido + ".","Função ADFIN021P(ADFIN020P)")  //Ticket  8913   - Abel B.  - 01/02/2021 - Correção de error.log - variable does not exist CFILPED
		// RestArea(aArea)
		// Return Nil
	// EndIf

	Conout("Time 7 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()

	//
	logZBE(SC5->C5_NUM,SC5->C5_XPREAPR)

	Conout("Time 8 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	cTime := Time()

	//
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	SA3->(DbSeek(FWxFilial("SA3")+SC5->C5_VEND1))
	_eMailVend := SA3->A3_EMAIL
	
	//
	DbSelectArea("SZR")
	SZR->(DbSetOrder(1))
	SZR->(DbSeek(FWxFilial("SZR")+SA3->A3_CODSUP))
	_eMailSup := Alltrim(UsrRetMail(SZR->ZR_USER))

	//21/10/16 - retirado pois na rotina de pre aprovação não sei ainda se sera preciso ou necessario gravar motivos de bloqueios na tabela ZBH...
	//Em 27/10/16 - verificado que vai ser preciso gravar os motivos dos bloqueios da pre aprovacao...
	//Envio de Email com Descrição dos Bloqueios
	If lBCEntrou

		//
		cUpt := " UPDATE " + RetSqlName("ZBH") + " SET D_E_L_E_T_ = '*' WHERE RTRIM(LTRIM(ZBH_FILIAL)) + RTRIM(LTRIM(ZBH_PEDIDO)) = '" + _cPedido + "' AND D_E_L_E_T_ = '' "
		If TcSqlExec(cUpt) < 0
			MsgAlert("Ocorreu erro na gravação de bloqueio do pedido " + _cPedido + ".","Função ADFIN021P(ADFIN020P)")
			
		Else 

			//
			For nAux := 1 to len(aTipoBloq)
				Reclock("ZBH",.T.)
					ZBH->ZBH_FILIAL  := Substr(_cPedido,1,2)
					ZBH->ZBH_PEDIDO  := Substr(_cPedido,3,6)
					ZBH->ZBH_CLIENT  := SC5->C5_CLIENTE
					ZBH->ZBH_LOJA    := SC5->C5_LOJACLI
					ZBH->ZBH_NOME    := SC5->C5_NOMECLI
					ZBH->ZBH_MOTIVO  := aTipoBloq[nAux][1]
					//Mauricio - 01/02/17 - chamado 033003
					ZBH->ZBH_CODVEN  := SC5->C5_VEND1
					ZBH->ZBH_NOMVEN  := Posicione("SA3",1,FWxFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
				ZBH->(MsUnlock()) 

			Next nAux

		EndIf

	EndIf   

	Conout("Time 9 " + _cPedido + "   " + cValToChar(ElapTime( cTime, Time() )))
	Conout("Time Total " + _cPedido + "   " + cValToChar(ElapTime( cTIni, Time() )))
	Conout("-------------------------------------------------------------------------------------------------------------------------")
	cTime := Time()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} uptSC5
	(long_description)
	@type  Static Function
	@author Everson
	@since 20/08/2020
	@version 01
	/*/
Static Function uptSC5(cFilPed,cStatus)

	//Variáveis.
	Local aArea := GetArea()
	Local cUpt  := ""
	Local lRet  := .T.

	//
	cUpt := " UPDATE " + RetSqlName("SC5") + " SET C5_XPREAPR = '" + cStatus + "' WHERE RTRIM(LTRIM(C5_FILIAL)) + RTRIM(LTRIM(C5_NUM)) = '" + cFilPed + "' AND D_E_L_E_T_ = '' "

	//
	If TcSqlExec(cUpt) < 0
		lRet := .F.
		Conout( DToC(Date()) + " " + Time() + " ADFIN020P - uptSC5 - Erro - " + TcSqlError() )

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} logZBE
	Função gera log na tabela ZBE.
	@type  Static Function
	@author Everson
	@since 20/08/2020
	@version 01
	/*/
Static Function logZBE(cPedido,cStatus)

	//Variáveis.
	Local aArea := GetArea()
	
	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL WITH FWxFilial("ZBE")
		Replace ZBE_DATA   WITH dDataBase
		Replace ZBE_HORA   WITH Time()
		Replace ZBE_USUARI WITH Upper(Alltrim(cUserName))
		Replace ZBE_LOG    WITH "PEDIDO " + cPedido + " STATUS: " + cStatus
		Replace ZBE_MODULO WITH "SC5"
		Replace ZBE_ROTINA WITH "ADFIN020P"
	ZBE->(MsUnlock())

	//
	RestArea(aArea)

Return Nil
