#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch" 

//Posicoes do array aSaldos
#DEFINE _LIMCREDM 1,1
#DEFINE _LIMCRED  1,2
#DEFINE _SALDUPM  2,1
#DEFINE _SALDUP   2,2
#DEFINE _SALPEDLM 3,1
#DEFINE _SALPEDL  3,2
#DEFINE _MCOMPRAM 4,1
#DEFINE _MCOMPRA  4,2
#DEFINE _SALDOLCM 5,1
#DEFINE _SALDOLC  5,2
#DEFINE _MAIDUPLM 6,1
#DEFINE _MAIDUPL  6,2
#DEFINE _ITATUM   7,1
#DEFINE _ITATU    7,2
#DEFINE _PEDATUM  8,1
#DEFINE _PEDATU   8,2
#DEFINE _SALPEDM  9,1
#DEFINE _SALPED   9,2
#DEFINE _VALATRM  10,1
#DEFINE _VALATR   10,2
#DEFINE _LCFINM   11,1
#DEFINE _LCFIN    11,2
#DEFINE _SALFINM  12,1
#DEFINE _SALFIN   12,2

#DEFINE _STRASALDOS 12,2

/*/{Protheus.doc} User Function ADFIN023P
	Pré Liberação Varejo
	@type  Function
	@author Maurício 
	@since 01/11/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 102    - FWNM     - 17/08/2020 - WS BRADESCO - Pedidos Vendas com Adiantamento que não foram autorizados pelo retorno do CNAB 
	@history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
	@history ticket 12098 - FWNM - 07/04/2020 - Correção emergencial na rotina de aprovação dos clientes do varejo. A rotina entra em loop infinto.
	@history Ticket  8      - Abel Babini   - 01/02/2022 - Ajuste de variáveis
  @history Ticket 69699   - Abel Babini   - 14/03/2022 - Correção ErrorLog 
/*/
User Function ADFIN023P()

	Local aArea		:= GetArea()
	Local aAreaSC5  := SC5->(GetArea())
	Local aRegSC6   := {}
	Local lContinua	:= .T.
	Local lQuery    := .F.
	Local nOpcA     := 0

	Local cPedido	:= ""
	Local cAliasSC5 := "SC5"
	Local cAliasSC6 := "SC6"
	Local dLimLib   := dDataBase
	Local lProcessa := .T.	
	Local _cQry     := ""
	local _nOpc := 0
	Local _dDTENTR1 := MV_PAR02
	Local _dDTENTR2 := MV_PAR03

	Local cMotivo  := "Pedido de Venda com Adiantamento não recebido (C5_XWSPAGO)"
	Local cNomeVen := ""

	//Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.
	Local cPerfPgt := ''
	Local nMedAtr	:= 0
	Local aPerPgt	:= {}

	Private _aMot := {}
	Private oCabD4 
	//Private _aExclui := {}   //Armazena pedidos de venda para realizar a exclusão destes a posterior.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PRE LIBERACAO VAREJO')

	DbselectArea("SC5")
	Eval(bFiltrabrw)        //ratifico o filtro padrão da rotina principal.
	dbgotop()

	//busco por query os mesmos dados apresentados em tela pelo filtro padrão acima.
	If Select("TSC5") > 0
	DbSelectArea("TSC5")
	DbCloseArea("TSC5")
	Endif

	_cQuery := "SELECT C5_NUM, C5_FILIAL, C5_XPREAPR, C5_CLIENTE, C5_LOJACLI, C5_DTENTR FROM "+RetSqlName("SC5")+" C5 , "+RetSqlName("SA1")+" A1 "
	_cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
	If mv_par01 == 1
	_cQuery += "C5.C5_XPREAPR='B' AND "
	Else 
	_cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
	Endif
	_cQuery += "C5.C5_NOTA = '' AND "
	_cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
	_cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
	_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "        //so varejo
	_cQuery += "ORDER BY C5.C5_CLIENTE, C5.C5_LOJACLI, C5.C5_NUM "

	TCQuery _cQuery NEW ALIAS "TSC5"
													
	DbSelectArea("TSC5")
	DbGotop()                   

	IF TSC5->(Eof())
		Msginfo("Não foram encontrados pedidos relativos a varejo para pre aprovacao do credito","Atenção")
		Return()
	Endif

	//Apuro valor em aberto de pedidos no periodo/parametro especificado
	_lRdPri := .T.
	While TSC5->(!Eof())

		//mostrar a tela para analise da rede para o usuario Aprovar ou Rejeitar a Rede.....
		IF _lRdPri

			_nOpc := 0
			_nTotRede   := 0
			_nTotSdRede := 0
			_nTotVenci  := 0
			_nTotAVenc  := 0
			_nVlLmCad   := 0
			_nSldTit    := 0
			
			dbSelectArea("SA1")
			dbSetOrder(1)		
			dbSeek(xFilial("SA1")+TSC5->C5_CLIENTE+TSC5->C5_LOJACLI)
			
			_cCLI := SA1->A1_COD
			_cLoj := SA1->A1_LOJA
			_cNMC := SA1->A1_NOME
			//_cCnpj := SZF->ZF_CGCMAT
			
			//Chamado 032992 - 01/02/17 - Dados relativos ao cadastro SA1 aonde conforme informações todos os clientes da rede
			//tem esses campos igualmente preenchidos.
			_cRisco   := SA1->A1_XRISCO
			_dDTUATU  := SA1->A1_XDTRISC //Campo incluido em 13/02/2017 por Adriana //Este campo segundo Alberto esta pendente de criação/tratamento pelo William
			_dDTUCOM  := SA1->A1_DTULTRE
			_dDTMACU  := SA1->A1_DTACUMU
			_nVLMACU  := SA1->A1_VLACUMU
					
			//Portador Especial
			cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_PORTAD FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
			cQuery+= " WHERE ZAD_TABELA = 'E' "
			cQuery+= " AND D_E_L_E_T_ <> '*' "
			cQuery+= " ORDER BY ZAD_DATA DESC "

			TCQUERY cQuery new alias "TMPF0"
			TMPF0->(dbgotop())

			cPortador:=TMPF0->ZAD_PORTAD
			DbCloseArea("TMPF0")
			
			//+ Soma dos limites do cliente do pedido em analise
		
			cQuery:= " SELECT SUM(A1_LC) AS A1_LC,A1_COD FROM " + RetSqlName("SA1") + " WITH(NOLOCK) "
			cQuery+= " WHERE A1_COD = '" +_cCLI + "' "
			cQuery+= " AND D_E_L_E_T_ <> '*' "
			cQuery+= " GROUP BY A1_COD "
			cQuery+= " ORDER BY A1_COD "
		
			TCQUERY cQuery new alias "TMPF0"
			TMPF0->(dbgotop())
		
			//_nValLim  += TMPF0->A1_LC
			_nVlLmCad += TMPF0->A1_LC
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
											
			//atrasados        
			//_dDT  := (Date() - _nDiasAtras)    //Mauricio - 09/11/16 incluido _nDiasAtras para manter coerencia com o bloqueio                                                
			_dDT  := Date()    //Mauricio - 09/11/16 - Alberto preferiu manter como estava, nao bloqueia(gera motivo) mas apresenta o valor.
			cQuery:= " SELECT SUM(E1_SALDO) AS E1_SALDO,E1_CLIENTE,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
			cQuery+= " WHERE E1_CLIENTE = '" + _cCLI + "' "
			cQuery+= " AND D_E_L_E_T_ <> '*' AND (E1_VENCREA < '"+DTOS(_dDT)+"') "
			cQuery+= " AND E1_SALDO > 0 "
			cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') " 
			cQuery+= " AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') "
			cQuery+= " GROUP BY E1_CLIENTE,E1_PORTADO "
			cQuery+= " ORDER BY E1_CLIENTE,E1_PORTADO "
		
			TCQUERY cQuery new alias "TMPF0"
			TMPF0->(dbgotop())
		
			DbSelectArea ("TMPF0")
			Do While !EOF()
					
				_nTotVenci += TMPF0->E1_SALDO
				
				//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD (poe de volta saldo para portadores especiais, porque não pode ser abatido do limite)
				
				//If TMPF0->E1_PORTADO $ Alltrim(cPortador)			  
				//	  _nTotVenci -= TMPF0->E1_SALDO
				//Endif
				
				DbSelectArea ("TMPF0")
				dbSkip()
			Enddo
		
			DbCloseArea("TMPF0")
			
			//- Soma do saldo dos titulos em aberto
		
			cQuery:= " SELECT SUM(E1_SALDO) AS E1_SALDO,SUM(E1_VALOR) AS E1_VALOR,E1_CLIENTE,E1_PORTADO FROM " + RetSqlName("SE1") + " WITH(NOLOCK) "
			cQuery+= " WHERE E1_CLIENTE = '" + _cCli + "' "
			cQuery+= " AND D_E_L_E_T_ <> '*' "
			cQuery+= " AND E1_SALDO > 0 "
			cQuery+= " AND E1_TIPO NOT IN ('NCC','RA') "
			cQuery+= " AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') "
			cQuery+= " GROUP BY E1_CLIENTE,E1_PORTADO "
			cQuery+= " ORDER BY E1_CLIENTE,E1_PORTADO "
		
			TCQUERY cQuery new alias "TMPF0"
			TMPF0->(dbgotop())
		
			DbSelectArea ("TMPF0")
			Do While !EOF()
			
					//_nValLim -= TMPF0->E1_SALDO
				_nSldTit += TMPF0->E1_SALDO
				
				//+ Soma do saldo dos titulos com portadores especiais - ZAD_PORTAD (poe de volta saldo para portadores especiais, porque não pode ser abatido do limite)
				
				//If TMPF0->E1_PORTADO $ Alltrim(cPortador)
					//_nValLim  += TMPF0->E1_SALDO
					//_nSldTPor += TMPF0->E1_SALDO
				//Endif
				
				DbSelectArea ("TMPF0")
				dbSkip()
			Enddo
		
			DbCloseArea("TMPF0")
					
			//U_ConsLimFin(_cCLI,"Con")    //nao utilizado esta função porque trouxe as querys de varejo que ela utilizava para este fonte
						
			_nTotRede   += _nVlLmCad //_nValLim
			_nTotSdRede += _nSldTit
						
			//Apuro agora valor de todos os pedidos em aberto para esta loja no periodo parametrizado...
			_nPedPer := 0
			If Select("TPA6") > 0
				DbSelectArea("TPA6")
				DbCloseArea("TPA6")
			Endif
			
			_cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SA1")+" A1 "
			_cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
			_cQuery += "(C6.C6_ENTREG >= '" + Dtos(_dDtEntr1) + "' AND C6.C6_ENTREG <= '" + Dtos(_dDtEntr2)  + "') AND "				
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND "
			_cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) AND "    //somente em aberto
			_cQuery += "A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' "
			
			TCQuery _cQuery NEW ALIAS "TPA6"
			
			DbSelectArea("TPA6")
			DbGotop()
			
			_nPedPer += TPA6->TOTAL
			
			//Apuro agora valor de todos os pedidos em aberto para esta loja no periodo posterior ao parametrizado...
			_nPedPos := 0
			If Select("TPA6") > 0
				DbSelectArea("TPA6")
				DbCloseArea("TPA6")
			Endif
			
			_cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SA1")+" A1 "
			_cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
			_cQuery += "(C6.C6_ENTREG > '" + Dtos(_dDtEntr2)  + "') AND "				
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND "
			_cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) AND "    //somente em aberto
			_cQuery += "A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' "
			
			TCQuery _cQuery NEW ALIAS "TPA6"
			
			DbSelectArea("TPA6")
			DbGotop()
			
			_nPedPos += TPA6->TOTAL
			
			DbSelectArea("TPA6")
			dbCloseArea("TPA6")
			
			//Contagem de quantidade de pedidos da loja
			_nQtdPed := 0
			If Select("TPA5") > 0
				DbSelectArea("TPA5")
				DbCloseArea("TPA5")
			Endif
			
			_cQuery := "SELECT COUNT(C5_NUM) AS TOTPED FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SA1")+" A1 "
			_cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
			If mv_par01 == 1
			_cQuery += "C5.C5_XPREAPR='B' AND "
			Else 
			_cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
			Endif
			_cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
			_cQuery += "A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "        
									
			TCQuery _cQuery NEW ALIAS "TPA5"
			
			DbSelectArea("TPA5")
			DbGotop()
			
			_nQtdPed += TPA5->TOTPED
			
			//Mauricio - 28/09/16 - tratamento para buscar pedidos de venda bloqueados e seus motivos...
			If Select("TPA5") > 0
				DbSelectArea("TPA5")
				DbCloseArea("TPA5")
			Endif
			
			_cQuery := "SELECT C5_FILIAL, C5_NUM, C5_CONDPAG FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SA1")+" A1 "
			_cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND "
			If mv_par01 == 1
			_cQuery += "C5.C5_XPREAPR='B' AND "
			Else 
			_cQuery += "(C5.C5_XPREAPR = 'L' OR C5.C5_XPREAPR = 'B') AND "    
			Endif
			_cQuery += "(C5.C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND "
			_cQuery += "A1.D_E_L_E_T_='' AND C5.D_E_L_E_T_='' "        
			_cQuery += "ORDER BY C5.C5_NUM "
			
			TCQuery _cQuery NEW ALIAS "TPA5"
			
			DbSelectArea("TPA5")
			DbGotop()
					
			_aMot := {}
			While TPA5->(!Eof())
				DbSelectArea("ZBH")
				DbSetOrder(1)
				If dbseek(TPA5->C5_FILIAL+TPA5->C5_NUM)
					While ZBH->(!Eof()) .And. ZBH->ZBH_PEDIDO == TPA5->C5_NUM .And. TPA5->C5_FILIAL == ZBH->ZBH_FILIAL
						
						// chamado 102    - FWNM     - 17/08/2020 - WS BRADESCO - Pedidos Vendas com Adiantamento que não foram autorizados pelo retorno do CNAB 
						/*
						AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO),ZBH->ZBH_CODVEN,Alltrim(ZBH->ZBH_NOMVEN)})
						ZBH->(dbSkip())
						*/

						/*
						SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
						If SC5->( msSeek(FWxFilial("SC5")+TPA5->C5_NUM) )
						*/

						FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
						//@history ticket 12098 - FWNM - 07/04/2020 - Correção emergencial na rotina de aprovação dos clientes do varejo. A rotina entra em loop infinto.
						//If FIE->( msSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) ) .or. AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM 
						If !(FIE->( msSeek(FWxFilial("FIE")+"R"+TPA5->C5_NUM) ) .or. AllTrim(Posicione("SE4",1,FWxFilial("SE4")+TPA5->C5_CONDPAG,"E4_CTRADT")) == "1")
							AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO),ZBH->ZBH_CODVEN,Alltrim(ZBH->ZBH_NOMVEN)})
						EndIf
						
						ZBH->(dbSkip())
					Enddo		
				Endif
				TPA5->(dbSkip())
			Enddo
			
			// chamado 102    - FWNM     - 17/08/2020 - WS BRADESCO - Pedidos Vendas com Adiantamento que não foram autorizados pelo retorno do CNAB 
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf

			cQuery := " SELECT C5_FILIAL, C5_NUM, C5_XWSPAGO, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_NOMECLI
			cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)
			cQuery += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT='1' AND SE4.D_E_L_E_T_=''
			cQuery += " WHERE C5_XWSPAGO=''
			cQuery += " AND (C5_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C5_DTENTR <= '" + Dtos(_dDtEntr2)  + "') 
			cQuery += " AND C5_CLIENTE = '"+_cCli+"' AND C5_LOJACLI = '"+_cLoj+"'
			cQuery += " AND SC5.D_E_L_E_T_=''
			cQuery += " ORDER BY 1,2

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				cMotivo  := "Pedido de Venda com Adiantamento não recebido (C5_XWSPAGO)"
				cNomeVen := Posicione("SA3",1,FWxFilial("SA3")+Work->C5_VEND1,"A3_NOME")

				aAdd( _aMot, { Work->C5_FILIAL,Work->C5_NUM,Work->C5_CLIENTE,Work->C5_LOJACLI,Work->C5_NOMECLI,cMotivo,Work->C5_VEND1,cNomeVen } )

				// Apago ZBH existente para prevalecer a do PV com adiantamento
				ZBH->( dbSetOrder(1) )
				If ZBH->( msSeek(FWxFilial("ZBH")+Work->C5_NUM) )
				
					Do While ZBH->( !EOF() ) .and. ZBH->ZBH_FILIAL==FWxFilial("ZBH") .and. ZBH->ZBH_PEDIDO==Work->C5_NUM
						RecLock("ZBH", .f.)
							ZBH->( dbDelete() )
						ZBH->( msUnLock() )

						ZBH->( dbSkip() )
					EndDo
				
				EndIf

				// Gravo ZBH com motivo de pedido de venda de adiantamento
				Reclock("ZBH", .T.)
					ZBH->ZBH_FILIAL  := FWxFilial("ZBH")
					ZBH->ZBH_PEDIDO  := Work->C5_NUM
					ZBH->ZBH_CLIENT  := Work->C5_CLIENTE
					ZBH->ZBH_LOJA    := Work->C5_LOJACLI
					ZBH->ZBH_NOME    := Work->C5_NOMECLI
					ZBH->ZBH_MOTIVO  := cMotivo
					ZBH->ZBH_CODVEN  := SC5->C5_VEND1
					ZBH->ZBH_NOMVEN  := cNomeVen
				ZBH->( msUnlock() ) 

				Work->( dbSkip() )

			EndDo

			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			//

			_aMtv := {}
			
			If len(_aMot) > 0
				For _xx := 1 to len(_aMot)
					//Mauricio - 01/02/17 - chamado 033003 
					//AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][6],.F.})
					AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][7],_aMot[_xx][8],_aMot[_xx][6],.F.})
				Next _xx
			Endif
			
			DbSelectArea("TPA5")
			dbCloseArea("TPA5")
			
			@ 200,051 TO 900,700 DIALOG oDlg1 TITLE "PRE LIBERACAO CREDITO VAREJO"        //200,051     900,800
			@ 001,007 SAY "Pedidos/Motivo Bloqueio: " of oDlg1 PIXEL
			
			//Borda Interna 01/02/17 - chamado 032992 - e mais linhas de informacoes incluidos na tela, intercalados abaixo
			@ 080, 170 GROUP oGroup1 TO 140, 320 PROMPT "" OF oDlg1 COLOR 0, 16777215 PIXEL
			
			aHeaderT := {}
			
			AAdd(aHeaderT,{"FILIAL"                   ,"_cfill"    ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
			AAdd(aHeaderT,{"PEDIDO"                   ,"_cPdd"     ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
			//Mauricio - 01/02/17 - chamado 033003
			AAdd(aHeaderT,{"VENDEDOR"                 ,"_cVdd"     ,"",008,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
			AAdd(aHeaderT,{"NOME"                     ,"_cNdd"     ,"",020,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
			
			AAdd(aHeaderT,{"MOTIVO    "               ,"_cMott"    ,"",200,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
			
			IF len(_aMtv) <= 0
				AADD(_aMtv,{"","","","","",.F.})
			Endif
		
		
			//003,007,060,340
			oCabD4 :=MsNewGetDados():New( 008,007,065,320,,"AllwaysTrue",,"",,,5,,,"AllwaysTrue",oDlg1,aHeaderT,@_aMtv)
			oCabD4:oBrowse:Refresh()
			oCabD4:GoBottom()
			oCabD4:GoTop()
			oCabD4:Refresh(.T.)
			oDlg1:Refresh()
			GetdRefresh()
			SysRefresh()
			
			@ 060,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			//@ 070,010 SAY "Matriz CNPJ (8 digitos): "+AllTrim(_cCnpj) of oDlg1 PIXEL
			@ 070,010 SAY "Cliente: "+AllTrim(_cCLI)+"-"+_cLoj+"  "+Alltrim(_cNMC) of oDlg1 PIXEL
			@ 090,180 SAY "RISCO: " of oDlg1 PIXEL
			@ 090,250 SAY _cRisco of oDlg1 PIXEL
			
			
			@ 090,010 SAY "Qtdade. Pedidos: " of oDlg1 PIXEL
			@ 090,130 SAY Transform(_nQtdPed  ,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 100,180 SAY "Data Ultima Atualiz.:" of oDlg1 PIXEL
			@ 100,250 SAY DTOC(_dDTUATU) of oDlg1 PIXEL
			
			@ 100,010 SAY "Limite de Credito do Cliente: " of oDlg1 PIXEL
			@ 100,130 SAY Transform(_nTotRede  ,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 110,180 SAY "Data Ultima Compra:" of oDlg1 PIXEL
			@ 110,250 SAY DTOC(_dDTUCOM) of oDlg1 PIXEL
			
			@ 110,010 SAY "Utilizado deste Cliente:" of oDlg1 PIXEL
			@ 110,130 SAY Transform(_nTotSdRede,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 120,180 SAY "Data Maior Acumulo:" of oDlg1 PIXEL
			@ 120,250 SAY DTOC(_dDTMACU) of oDlg1 PIXEL
			
			//05/10/16 - Incluido na tela, mas a informação ira vir somente quando for implementada a pre-aprovacao dos pedidos de venda....
			@ 120,010 SAY "Valor pedidos ja liberados(pre aprovação):" of oDlg1 PIXEL
			@ 120,130 SAY " - "
			@ 130,180 SAY "Valor Maior Acumulo:" of oDlg1 PIXEL
			@ 130,250 SAY Transform(_nVLMACU,"@E 999,999,999.99") of oDlg1 PIXEL
			
			_cPer := "Valor Pedidos entre("+DTOC(_dDtEntr1)+" e "+DTOC(_dDtEntr2)+"): "
			@ 130,010 SAY _cPer of oDlg1 PIXEL
			@ 130,130 SAY Transform(_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 140,010 SAY "Total utilizado: " of oDlg1 PIXEL
			@ 140,130 SAY Transform((_nTotSdRede)+_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 150,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			@ 160,010 SAY "PERCENTUAL" of oDlg1 PIXEL
			@ 160,130 SAY Transform(((_nTotSdRede+_nPedPer)/_nTotRede)*100,"@E 999999.99 %") of oDlg1 PIXEL
			@ 170,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			@ 180,010 SAY "Valor Total Vencidos: " of oDlg1 PIXEL
			@ 180,130 SAY Transform(_nTotVenci,"@E 999,999,999.99") of oDlg1 PIXEL
			//@ 190,010 SAY "Valor Total A Vencer: " of oDlg1 PIXEL
			//@ 190,130 SAY Transform(_nTotAvenc,"@E 999,999,999.99") of oDlg1 PIXEL
			_cPos := "Valor Pedidos após "+DTOC(_dDtEntr2)+": "
			@ 200,010 SAY _cPos  of oDlg1 PIXEL
			@ 200,130 SAY Transform(_nPedPos,"@E 999,999,999.99") of oDlg1 PIXEL
			//@ 130,012 BUTTON OemToAnsi("SAIR") SIZE 34,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 220,012 BUTTON OemToAnsi("PRE APROVA TODOS") SIZE 60,11 ACTION(_nOpc := 4,oDlg1:End() ) of oDlg1 PIXEL      //libera todos
			@ 220,140 BUTTON OemToAnsi("PRE BLOQUEIA TODOS") SIZE 60,11 ACTION(_nOpc := 3,oDlg1:End() ) of oDlg1 PIXEL     //rejeita
			
			@ 240,012 BUTTON OemToAnsi("SAIR DO CLIENTE") SIZE 50,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 240,140 BUTTON OemToAnsi("SAIR DA ROTINA") SIZE 50,11 ACTION(_nOpc := 5,oDlg1:End() ) of oDlg1 PIXEL
			
			//@ 240,250 BUTTON OemToAnsi("CONSULTA POSICAO") SIZE 55,15 ACTION(U_F023TELA(.T.,.T.,.F.,dDatabase,_cCLi,_cLoj,TSC5->C5_NUM) ) of oDlg1 PIXEL							
			
			ACTIVATE DIALOG oDlg1 CENTERED
			
			//dbSelectArea("TMP")
			//dbCloseArea()
		Endif
		
		//Mauricio - 23/03/16 - sai da rotina
		If _nOpc == 5
			exit
		Endif
		
		If _nOpc == 4 .Or. _nOpc == 3
			
			While TSC5->(!Eof()) .And. _cCLI+_cLoj == TSC5->(C5_CLIENTE + C5_LOJACLI)
				
				DbSelectArea("TSC5")
				_cPD := TSC5->C5_NUM
				
				//While TSC5->(!Eof()) .And. _cCLI+_cLoj == TSC5->(C5_CLIENTE + C5_LOJACLI)
									
					DbSelectArea("SC5")
					DbSetOrder(1)
					If Dbseek(xFilial("SC5")+_cPD)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Rejeicao do Pedido pre aprovado ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If _nOpc == 3

							If RecLock("SC5",.F.)
								SC5->C5_XPREAPR := "B"
								SC5->(MsUnlock())
							EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Liberacao do pedido pre aprovado³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf _nOpc == 4

							RecLock("SC5", .F.)
								SC5->C5_XPREAPR := "L"
							SC5->(MsUnlock())

							//INICIO Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.
							cPerfPgt := ''
							nMedAtr	:= 0
							aPerPgt	:= {}
							
							//Carrega Perfil de Pagamento
							aPerPgt 	:= StaticCall(ADFIN103P,fMedPgt,SC5->C5_CLIENTE, SC5->C5_LOJACLI) //01/02/2022 - Ajuste de Variáveis
							IF ValType(aPerPgt) = 'A' 
								cPerfPgt	:= IIF(Empty(Alltrim(aPerPgt[2])) .OR. ValType(aPerPgt) != 'A','NDA', aPerPgt[2])
								nMedAtr		:= IIF(ValType(aPerPgt) != 'A',0, aPerPgt[1])
							ELSE
								cPerfPgt	:= 'NDA'
							ENDIF

							//GRAVA REGISTRO DA LIBERAÇÃO DE CRÉDITO
							If RecLock("ZEJ",.T.)
								ZEJ->ZEJ_FILIAL	:= SC5->C5_FILIAL					//
								ZEJ->ZEJ_NUM		:= SC5->C5_NUM						//
								ZEJ->ZEJ_DTLIB	:= MsDate()								//
								ZEJ->ZEJ_HRLIB	:= TIME()									//
								ZEJ->ZEJ_USRLIB	:= cUserName							//
								ZEJ->ZEJ_VLLIB	:= SC5->C5_XTOTPED				//
								ZEJ->ZEJ_MOTLIB	:= ''											//
								ZEJ->ZEJ_PARECE	:= ''											//
								ZEJ->ZEJ_PERFPG	:= cPerfPgt								//	
								ZEJ->ZEJ_RATCIS	:= _cRisco								//
								ZEJ->ZEJ_MEDATR	:= nMedAtr								//
								ZEJ->ZEJ_VLPED	:= _nPedPer								//
								ZEJ->ZEJ_VLAVEN	:= Round(_nSldTit - _nTotVenci,2)	//
								ZEJ->ZEJ_VLVENC	:= _nTotVenci							//
								ZEJ->ZEJ_VLPESP	:= 0											//
								ZEJ->ZEJ_TTACUM	:= _nTotVenci+_nTotAVenc+_nPedPer
								ZEJ->ZEJ_LIMCRD	:= _nTotRede							//
								ZEJ->ZEJ_PERCEN := iif(((_nTotSdRede+(cTbClie)->TOTAL)/_nTotRede)*100 > 999, 999, ((_nTotSdRede+(cTbClie)->TOTAL)/_nTotRede)*100) //Ticket 69699   - Abel Babini   - 14/03/2022 - Correção ErrorLog 
								ZEJ->ZEJ_VLUTIL := _nTotSdRede
								ZEJ->ZEJ_QTDPED := _nQtdPed
								ZEJ->ZEJ_TTUTIL := (_nTotSdRede+SC5->C5_XTOTPED)
								ZEJ->(MsUnlock())
							Endif
							//FIM Ticket  8      - Abel Babini   - 31/01/2022 - Gravação da liberação na tabela de pedidos liberados.

						EndIf

						//Mauricio - 15/02/17 - log de registro		  
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL WITH xFilial("ZBE")
							Replace ZBE_DATA   WITH dDataBase
							Replace ZBE_HORA   WITH TIME()
							Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG    WITH "PEDIDO " + SC5->C5_NUM + " C5_FLAGFIN: "+SC5->C5_FLAGFIN + " C5_XPREAPR: "+SC5->C5_XPREAPR
							Replace ZBE_MODULO WITH "SC5"
							Replace ZBE_ROTINA WITH "ADFIN023P"
						ZBE->(MsUnlock())

						// chamado 102    - FWNM     - 17/08/2020 - WS BRADESCO - Pedidos Vendas com Adiantamento que não foram autorizados pelo retorno do CNAB 
						FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
						If FIE->( msSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) ) .or. AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM 

							// ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
							/*
							RecLock("SC5", .f.)
								SC5->C5_XWSPAGO := "S"
							SC5->( msUnLock() )
							*/

							dbSelectArea("ZBE")
							RecLock("ZBE", .T.)
								Replace ZBE_FILIAL WITH FWxFilial("ZBE")
								Replace ZBE_DATA   WITH msDate()
								Replace ZBE_HORA   WITH TIME()
								Replace ZBE_USUARI WITH UPPER(Alltrim(cUserName))
								Replace ZBE_LOG    WITH "PV ADIANT N " + SC5->C5_NUM + " C5_XWSPAGO: " + SC5->C5_XWSPAGO + " LIBERADO FATURAMENTO MANUALMENTE"
								Replace ZBE_MODULO WITH "SC5"
								Replace ZBE_ROTINA WITH "ADFIN023P"
							ZBE->( msUnLock() )

						EndIf	
						//

					Endif

					DbSelectArea("TSC5")
					TSC5->(DbSkip())
				//Enddo
				
			Enddo

		Else
			DbSelectArea("TSC5")
			TSC5->(DbSkip())
			If TSC5->(C5_CLIENTE + C5_LOJACLI)== _cCLI+_cLoj
				_lRDPRI := .F.
			Else
				_lRDPRI := .T.
			Endif
		Endif

	Enddo
	
	MsUnLockAll()

	RestArea(aAreaSC5)
	Eval(bFiltrabrw)
	dbgotop()
	SYSREFRESH() 
	RestArea(aArea)

Return() 
