#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function ADFIN006P
	Adiciona rotina no menu de analise de credito 
	@type  Function
	@author Mauricio - MDS TEC
	@since 17/02/2016
	@version 01
	@history Chamado TI     - SEM NOME      - 01/09/2017 - Adicionamos WITH (NOLOCK) em todas as Consultas 
	@history Chamado TI     - Ricardo Lima  - 22/02/2018 - Faz o upload do status de aprovacao para o sales force
	@history Chamado 048296 - William Costa - 05/04/2019 - Adicionado Ab- na query de consulta as redes
	@history Chamado TI     - William Costa - 24/05/2019 - Substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado 056381 - William Costa - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
	@history Chamado 056247 - FWNM          - 24/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Chamado 059415 - FWNM          - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consistências por indefinições de implantação
	@history ticket 102 - FWNM - 26/08/2020 - WS BRADESCO 
	@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
/*/	
User Function ADFIN006P()

	Local aArea		:= GetArea()
	Local aAreaSC9  := SC9->(GetArea())
	Local aRegSC6   := {}
	Local lContinua	:= .T.
	Local lQuery    := .F.
	Local nOpcA     := 0
	Local cQuery    := ""
	Local cPedido	:= ""
	Local cAliasSC5 := "SC5"
	Local cAliasSC6 := "SC6"
	Local cAliasSC9 := "SC9"
	Local dLimLib   := dDataBase
	Local lProcessa := .T.	
	Local _cQry     := ""
	local _nOpc := 0
	Local cPedidos := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Adiciona rotina no menu de analise de credito')

	Pergunte("MTA451",.F.)

	_dDTENTR1 := MV_PAR03
	_dDTENTR2 := MV_PAR04

	//Mauricio - 28/09/16 - adicionado novo conteudo a tela de liberação de rede(solicitado Alberto)
	Private _aMot := {}
	Private oCabD4 
	Private _aExclui := {}   //Mauricio - 05/10/16 - Armazena pedidos de venda para realizar a exclusão destes a posterior.

	//Mauricio 16/03/16 - incluida chamada de função, com parte do fonte ADLCRED2.prw hoje utilizado, a qual foi solicitado pelo Reginaldo/Alberto incluir nesta nova rotina aqui
	bBloco := {|lEnd| ProcSql()}  
	MsAguarde(bBloco,"Aguarde, Atualizando o credito das redes","Atualizando...",.F.)

	//DbselectArea("SC9")
	//Eval(bFiltrabrw)        //ratifico o filtro padrão da rotina MATA450 padrao.
	//dbgotop()

	//busco por query os mesmos dados apresentados em tela pelo filtro padrão acima.
	If Select("TSC9") > 0
		DbSelectArea("TSC9")
		DbCloseArea("TSC9")
	Endif

	_cQuery := "SELECT C9_PEDIDO, C9_ITEM, C9_FILIAL,C9_BLCRED, C9_CLIENTE, C9_LOJA, ZF_REDE FROM "+RetSqlName("SC9")+" C9 WITH (NOLOCK), "+RetSqlName("SZF")+" ZF WITH (NOLOCK), "+RetSqlName("SA1")+" A1 WITH (NOLOCK) "
	_cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "

	If mv_par01 == 1

		_cQuery += "(C9.C9_BLCRED = '01' OR C9.C9_BLCRED = '04') AND "

	ElseIf (mv_par01 == 3)

		_cQuery += "(C9_BLCRED = '01' OR C9_BLCRED = '04' OR C9_BLCRED = '09' ) AND " 

	Endif

	//filtro vindo do ponto de entrada M450FIL em uso
	IF ALLTRIM(CEMPANT)=="01"    

		If MV_PAR05 == 1  //estadual 

			_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 >= '000001' AND C9_VEND1 <= '000135') AND "

		elseif MV_PAR05 == 2 //interestadual

			_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 < '000001' OR C9_VEND1 > '000135') AND "
			//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "') .And. (SC9->C9_VEND1 < '000001' .OR. SC9->C9_VEND1 > '000135') "

		Else  //todos

			_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
			//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "')

		Endif   
	ENDIF 

	_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
	_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
	_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "
	_cQuery += "ORDER BY ZF.ZF_REDE, C9.C9_PEDIDO, C9.C9_ITEM "

	TCQuery _cQuery NEW ALIAS "TSC9"

	DbSelectArea("TSC9")
	DbGotop()

	IF TSC9->(Eof())

		Msginfo("Não foram encontrados pedidos relativos a REDE para liberação de credito","Atenção")
		Return()

	Endif

	//Apuro valor em aberto de pedidos no periodo/parametro especificado

	_lRdPri := .T.
	While TSC9->(!Eof())

		_cRD := TSC9->ZF_REDE
		//mostrar a tela para analise da rede para o usuario Aprovar ou Rejeitar a Rede.....
		If Select("TMP") > 0

			DbSelectArea("TMP")
			DbCloseArea("TMP")

		Endif

		IF _lRdPri

			_nOpc := 0
			_nTotRede   := 0
			_nTotSdRede := 0
			_nTotVenci  := 0
			_nTotAVenc  := 0

			dbSelectArea("SZF")
			dbSetOrder(1)

			dbSeek(xFilial("SZF")+SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1")+TSC9->C9_CLIENTE+TSC9->C9_LOJA,"A1_CGC")),1,8))

			//Chamado 032992 - 01/02/17 - Dados relativos ao cadastro SA1 aonde conforme informações todos os clientes da rede
			//tem esses campos igualmente preenchidos.
			_cRisco   := Posicione("SA1",1,xFilial("SA1")+TSC9->C9_CLIENTE+TSC9->C9_LOJA,"A1_XRISCO")
			_dDTUATU  := ""
			_dDTUCOM  := Posicione("SA1",1,xFilial("SA1")+TSC9->C9_CLIENTE+TSC9->C9_LOJA,"A1_DTULTRE")

			// INICIO CHAMADO 033752 - WILLIAM COSTA 03/03/2017

			//_dDTMACU  := SZF->ZF_DTACUMU
			//_nVLMACU  := SZF->ZF_VLACUMU

			// FINAL CHAMADO 033752 - WILLIAM COSTA 03/03/2017

			_cRede := SZF->ZF_REDE
			_cCnpj := SZF->ZF_CGCMAT

			//Mauricio - 02/05/17 - chamado 034919 - mudança na forma de trazer este valor(_nVLMACU) para a rede.      
			_nVLMACU  := fBscAcum(_cRede,TSC9->C9_CLIENTE,TSC9->C9_LOJA)
			_dDTMACU  := fBscDtAc(_cRede,TSC9->C9_CLIENTE,TSC9->C9_LOJA)

			_cQrFlt := "SELECT ZF_REDE,SUM(ZF_LCREDE) AS LCREDE,SUM(ZF_SLDREDE) AS SLDREDE, SUM(ZF_VENCIDO) AS VENCIDO, SUM(ZF_AVENCER) AS AVENCER  "
			_cQrFlt += "FROM "+RetSqlName("SZF")+" WITH (NOLOCK) "
			_cQrFlt += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
			_cQrFlt += "GROUP BY ZF_REDE "
			_cQrFlt += "ORDER BY ZF_REDE" 

			TCQUERY _cQrFlt New Alias "TMP"

			dbSelectArea("TMP")
			dbGoTop()
			While TMP->(!Eof())

				_nTotRede   += TMP->LCREDE
				_nTotSdRede += TMP->SLDREDE
				_nTotVenci  += TMP->VENCIDO
				_nTotAVenc  += TMP->AVENCER
				TMP->(dbSkip())

			EndDo

			//Apuro agora valor de todos os pedidos em aberto para esta rede no periodo parametrizado..
			_nPedPer := 0
			If Select("TPA9") > 0

				DbSelectArea("TPA9")
				DbCloseArea("TPA9")

			Endif

			_cQuery := "SELECT SUM(C9_QTDLIB * C9_PRCVEN) AS TOTAL FROM "+RetSqlName("SC9")+" C9 WITH (NOLOCK), "+RetSqlName("SZF")+" ZF WITH (NOLOCK), "+RetSqlName("SA1")+" A1 WITH (NOLOCK) "
			_cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "

			If mv_par01 == 1

				_cQuery += "(C9.C9_BLCRED = '01' OR C9.C9_BLCRED = '04') AND "

			ElseIf (mv_par01 == 3)

				_cQuery += "(C9_BLCRED = '01' OR C9_BLCRED = '04' OR C9_BLCRED = '09' ) AND " 

			Endif

			//filtro vindo do ponto de entrada M450FIL em uso
			IF ALLTRIM(CEMPANT)=="01"    

				If MV_PAR05 == 1  //estadual 

					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 >= '000001' AND C9_VEND1 <= '000135') AND "
				
				elseif MV_PAR05 == 2 //interestadual
					
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 < '000001' OR C9_VEND1 > '000135') AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "') .And. (SC9->C9_VEND1 < '000001' .OR. SC9->C9_VEND1 > '000135') "
				
				Else  //todos
					
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "')
				
				Endif   
			ENDIF 

			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_nPedPer += TPA9->TOTAL

			//Apuro agora valor de todos os pedidos em aberto para esta rede no periodo posterior ao parametrizado...
			_nPedPos := 0
			If Select("TPA9") > 0
				
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			
			Endif

			_cQuery := "SELECT SUM(C9_QTDLIB * C9_PRCVEN) AS TOTAL FROM "+RetSqlName("SC9")+" C9 WITH (NOLOCK), "+RetSqlName("SZF")+" ZF WITH (NOLOCK), "+RetSqlName("SA1")+" A1 WITH (NOLOCK) "
			_cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
			
			If mv_par01 == 1
				
				_cQuery += "(C9.C9_BLCRED = '01' OR C9.C9_BLCRED = '04') AND "
			
			ElseIf (mv_par01 == 3)
				
				_cQuery += "(C9_BLCRED = '01' OR C9_BLCRED = '04' OR C9_BLCRED = '09' ) AND " 
			
			Endif  

			//filtro vindo do ponto de entrada M450FIL em uso
			IF ALLTRIM(CEMPANT)=="01"    
				
				If MV_PAR05 == 1  //estadual 
					
					_cQuery += "C9_DTENTR > '" + Dtos(_dDtEntr2)  + "' AND (C9_VEND1 >= '000001' AND C9_VEND1 <= '000135') AND "
				
				elseif MV_PAR05 == 2 //interestadual
					
					_cQuery += "C9_DTENTR > '" + Dtos(_dDtEntr2)  + "' AND (C9_VEND1 < '000001' OR C9_VEND1 > '000135') AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "') .And. (SC9->C9_VEND1 < '000001' .OR. SC9->C9_VEND1 > '000135') "
				
				Else  //todos
					
					_cQuery += "C9_DTENTR > '" + Dtos(_dDtEntr2)  + "' AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "')
				
				Endif   
			ENDIF 

			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_nPedPos += TPA9->TOTAL  

			DbSelectArea("TPA9")
			dbCloseArea("TPA9")

			//Mauricio - 16/11/2016 - tratamento para apurar valores dos pedidos pre aprovados até o momento....
			//Conforme verificado com aberto apenas considerar os "L".
			_nPreApr := 0
			If Select("TPA6") > 0

				DbSelectArea("TPA6")
				DbCloseArea("TPA6")

			Endif

			//_cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1, "+RetSqlName("SC5")+" C5 "
			//_cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
			//_cQuery += "(C6.C6_ENTREG >= '" + Dtos(_dDtEntr1) + "' AND C6.C6_ENTREG <= '" + Dtos(_dDtEntr2)  + "') AND "					
			//_cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND (C6.C6_NUM = C5.C5_NUM) AND "
			//_cQuery += "C5.C5_XPREAPR = 'L' AND "
			//_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' AND "
			//_cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) "    //somente em aberto
			//

			//fernando sigoli 01/09/2017 - Incidente na liberação de rede 31/08/2017 Chamado: 036984	
			_cQuery := " SELECT "
			_cQuery += " 	ISNULL(SUM((DADOS.C6_QTDVEN - DADOS.C6_QTDENT) * DADOS.C6_PRCVEN),0) AS TOTAL  "
			_cQuery += " FROM " 
			_cQuery += " (SELECT  "
			_cQuery += "       C5_FILIAL,C6_QTDVEN,C6_QTDENT,C6_ENTREG,C5_XPREAPR, "
			_cQuery += "       C6_PRCVEN,SUBSTRING(A1_CGC,1,8) AS CGC "
			_cQuery += " FROM " 
			_cQuery += " "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) INNER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) " 
			_cQuery += " ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE =  SC6.C6_CLI AND SC5.C5_LOJACLI = SC6.C6_LOJA "
			_cQuery += " AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' "
			_cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK)  ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "
			_cQuery += " ) AS DADOS "
			_cQuery += " INNER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK)  ON  DADOS.CGC = SZF.ZF_CGCMAT AND SZF.D_E_L_E_T_ = '' "
			_cQuery += " WHERE " 
			_cQuery += " DADOS.C5_FILIAL = '"+xFilial("SC5")+"' "
			_cQuery += " AND DADOS.C5_XPREAPR = 'L'  "
			_cQuery += " AND DADOS.C6_ENTREG >= '" + Dtos(_dDtEntr1) + "' AND DADOS.C6_ENTREG <= '" + Dtos(_dDtEntr2)  + "'  "
			_cQuery += " AND SZF.ZF_REDE = '"+_cRD+"' "
			_cQuery += " AND ((DADOS.C6_QTDVEN - DADOS.C6_QTDENT) > 0)  "

			TCQuery _cQuery NEW ALIAS "TPA6"

			DbSelectArea("TPA6")
			DbGotop()

			_nPreApr += TPA6->TOTAL

			//Contagem de quantidade de pedidos por Rede...
			_nQtdPed := 0
			If Select("TPA9") > 0

				DbSelectArea("TPA9")
				DbCloseArea("TPA9")

			Endif

			_cQuery := "SELECT COUNT(DISTINCT C9_PEDIDO) AS TOTPED FROM "+RetSqlName("SC9")+" C9 WITH (NOLOCK), "+RetSqlName("SZF")+" ZF WITH (NOLOCK), "+RetSqlName("SA1")+" A1 WITH (NOLOCK) "
			_cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
			
			If mv_par01 == 1
			
				_cQuery += "(C9.C9_BLCRED = '01' OR C9.C9_BLCRED = '04') AND "
			
			ElseIf (mv_par01 == 3)
			
				_cQuery += "(C9_BLCRED = '01' OR C9_BLCRED = '04' OR C9_BLCRED = '09' ) AND " 
			
			Endif                                                                                      
			//filtro vindo do ponto de entrada M450FIL em uso
			IF ALLTRIM(CEMPANT)=="01"    
				
				If MV_PAR05 == 1  //estadual 
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 >= '000001' AND C9_VEND1 <= '000135') AND "
				
				elseif MV_PAR05 == 2 //interestadual
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 < '000001' OR C9_VEND1 > '000135') AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "') .And. (SC9->C9_VEND1 < '000001' .OR. SC9->C9_VEND1 > '000135') "
				
				Else  //todos
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "
					//_cQuery := " (DTOS(SC9->C9_DTENTR) >= '" + Dtos(_dDtEntr1) + "' .and. DTOS(SC9->C9_DTENTR) <= '" + Dtos(_dDtEntr2)  + "')
				
				Endif   
			ENDIF

			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_nQtdPed += TPA9->TOTPED

			//Mauricio - 28/09/16 - tratamento para buscar pedidos de venda bloqueados e seus motivos...
			If Select("TPA9") > 0
				
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			
			Endif

			_cQuery := "SELECT DISTINCT C9_PEDIDO, C9_FILIAL FROM "+RetSqlName("SC9")+" C9 WITH (NOLOCK), "+RetSqlName("SZF")+" ZF WITH (NOLOCK), "+RetSqlName("SA1")+" A1 WITH (NOLOCK) "
			_cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
			
			If mv_par01 == 1
			
				_cQuery += "(C9.C9_BLCRED = '01' OR C9.C9_BLCRED = '04') AND "
			
			ElseIf (mv_par01 == 3)
			
				_cQuery += "(C9_BLCRED = '01' OR C9_BLCRED = '04' OR C9_BLCRED = '09' ) AND " 
			
			Endif

			//filtro vindo do ponto de entrada M450FIL em uso
			IF ALLTRIM(CEMPANT)=="01"    

				If MV_PAR05 == 1  //estadual 
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 >= '000001' AND C9_VEND1 <= '000135') AND "
				
				elseif MV_PAR05 == 2 //interestadual
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND (C9_VEND1 < '000001' OR C9_VEND1 > '000135') AND "      
				
				Else  //todos
				
					_cQuery += "(C9_DTENTR >= '" + Dtos(_dDtEntr1) + "' AND C9_DTENTR <= '" + Dtos(_dDtEntr2)  + "') AND "      
				
				Endif   
			ENDIF 

			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.ZF_REDE = '"+_cRD+"' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "
			_cQuery += "ORDER BY C9.C9_PEDIDO "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_aMot := {}
			While TPA9->(!Eof())

				DbSelectArea("ZBH")
				DbSetOrder(1)
				If dbseek(TPA9->C9_FILIAL+TPA9->C9_PEDIDO)
				
					While ZBH->(!Eof()) .And. ZBH->ZBH_PEDIDO == TPA9->C9_PEDIDO .And. TPA9->C9_FILIAL == ZBH->ZBH_FILIAL
						
						//Mauricio - 01/02/17 - chamado 033003
						//AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO)})
						AADD(_aMot,{ZBH->ZBH_FILIAL,ZBH->ZBH_PEDIDO,ZBH->ZBH_CLIENT,ZBH->ZBH_LOJA,ZBH->ZBH_NOME,Alltrim(ZBH->ZBH_MOTIVO),ZBH->ZBH_CODVEN,Alltrim(ZBH->ZBH_NOMVEN)})
						ZBH->(dbSkip())              
					
					Enddo
				Endif             
				TPA9->(dbSkip())
			Enddo

			_aMtv := {}

			If len(_aMot) > 0

				For _xx := 1 to len(_aMot)

					//Mauricio - 01/02/17 - chamado 033003
					//AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][6],.F.})
					AADD(_aMtv,{_aMot[_xx][1],_aMot[_xx][2],_aMot[_xx][7],_aMot[_xx][8],_aMot[_xx][6],.F.})     

				Next _xx

			Endif

			DbSelectArea("TPA9")
			dbCloseArea("TPA9") 

			@ 200,051 TO 900,700 DIALOG oDlg1 TITLE "LIBERA CREDITO POR REDE"        //200,051     900,800
			@ 001,007 SAY "Pedidos/Motivo Bloqueio: " of oDlg1 PIXEL 

			//Borda Interna 01/02/17 - chamado 032992 - e mais linhas de informacoes incluidos na tela, intercalados abaixo
			@ 075, 170 GROUP oGroup1 TO 140, 320 PROMPT "" OF oDlg1 COLOR 0, 16777215 PIXEL     

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
			@ 070,010 SAY "Matriz CNPJ (8 digitos): "+AllTrim(_cCnpj) of oDlg1 PIXEL
			@ 080,010 SAY "Rede: "+AllTrim(_cRede) of oDlg1 PIXEL
			@ 080,180 SAY "RISCO: " of oDlg1 PIXEL
			@ 080,250 SAY _cRisco of oDlg1 PIXEL

			@ 090,010 SAY "Qtdade. Pedidos: " of oDlg1 PIXEL      
			@ 090,130 SAY Transform(_nQtdPed  ,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 090,180 SAY "Data Ultima Atualiz.:" of oDlg1 PIXEL
			@ 090,250 SAY _dDTUATU of oDlg1 PIXEL


			@ 100,010 SAY "Limite de Credito desta Rede de Lojas: " of oDlg1 PIXEL      
			@ 100,130 SAY Transform(_nTotRede  ,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 100,180 SAY "Data Ultima Compra:" of oDlg1 PIXEL
			@ 100,250 SAY DTOC(_dDTUCOM) of oDlg1 PIXEL

			@ 110,010 SAY "Utilizado desta Rede de Lojas:" of oDlg1 PIXEL 
			@ 110,130 SAY Transform(_nTotSdRede,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 110,180 SAY "Data Maior Acumulo:" of oDlg1 PIXEL
			@ 110,250 SAY DTOC(_dDTMACU) of oDlg1 PIXEL


			//05/10/16 - Incluido na tela, mas a informação ira vir somente quando for implementada a pre-aprovacao dos pedidos de venda....      
			_cPer := "Valor Pedidos entre("+DTOC(_dDtEntr1)+" e "+DTOC(_dDtEntr2)+"): "
			@ 120,010 SAY _cPer of oDlg1 PIXEL 
			@ 120,130 SAY Transform(_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 120,180 SAY "Valor Maior Acumulo:" of oDlg1 PIXEL
			@ 120,250 SAY Transform(_nVLMACU,"@E 999,999,999.99") of oDlg1 PIXEL

			@ 130,010 SAY "Total utilizado: " of oDlg1 PIXEL        
			@ 130,130 SAY Transform((_nTotSdRede)+_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 140,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL      
			@ 150,010 SAY "PERCENTUAL" of oDlg1 PIXEL
			@ 150,130 SAY Transform(((_nTotSdRede+_nPedPer)/_nTotRede)*100,"@E 999999.99 %") of oDlg1 PIXEL
			@ 160,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			@ 170,010 SAY "Valor Total Vencidos: " of oDlg1 PIXEL        
			@ 170,130 SAY Transform(_nTotVenci,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 180,010 SAY "Valor Total A Vencer: " of oDlg1 PIXEL        
			@ 180,130 SAY Transform(_nTotAvenc,"@E 999,999,999.99") of oDlg1 PIXEL                  
			@ 190,010 SAY "Valor pedidos ja liberados(pre aprovação):" of oDlg1 PIXEL
			@ 190,130 SAY Transform(_nPreApr,"@E 999,999,999.99") of oDlg1 PIXEL
			_cPos := "Valor Pedidos após "+DTOC(_dDtEntr2)+": "
			@ 200,010 SAY _cPos  of oDlg1 PIXEL                                          
			@ 200,130 SAY Transform(_nPedPos,"@E 999,999,999.99") of oDlg1 PIXEL
			//@ 130,012 BUTTON OemToAnsi("SAIR") SIZE 34,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 220,012 BUTTON OemToAnsi("APROVA TODOS") SIZE 44,11 ACTION(_nOpc := 4,oDlg1:End() ) of oDlg1 PIXEL      //libera todos
			@ 220,190 BUTTON OemToAnsi("REJEITA TODOS") SIZE 44,11 ACTION(_nOpc := 3,oDlg1:End() ) of oDlg1 PIXEL     //rejeita

			@ 240,012 BUTTON OemToAnsi("SAIR DA REDE") SIZE 44,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 240,190 BUTTON OemToAnsi("SAIR DA ROTINA") SIZE 44,11 ACTION(_nOpc := 5,oDlg1:End() ) of oDlg1 PIXEL       

			ACTIVATE DIALOG oDlg1 CENTERED

			dbSelectArea("TMP")
			dbCloseArea()               
		Endif

		//Mauricio - 23/03/16 - sai da rotina      
		If _nOpc == 5

			exit      
		Endif


		If _nOpc == 4 .Or. _nOpc == 3

			If _nOpc == 3   //Mauricio - 11/01/2017 - Se houver rejeição abro tela para digitar motivo da rejeição para esta rede e todos os seus pedidos..(tela vindado PE MA410DEL ja em uso pelo cliente)
				
				cMotivo := Space(115)
				nOpt 	:= 0
				lRet	:= .f.
				_lMail	:= .f.

				DEFINE MSDIALOG oDlg2 FROM	18,1 TO 80,550 TITLE "ADORO S/A Crédito-Motivo Rejeiçao Pedidos do Cliente" PIXEL

				@  1, 3 	TO 28, 242 OF oDlg2  PIXEL
				
				If File("adoro.bmp")

					@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg2 NOBORDER SIZE 25,25 PIXEL
					oBmp:lStretch:=.T.
				
				EndIf

				@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg2 PIXEL
				@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg2 PIXEL Valid !Empty(cMotivo)
				DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION (nOpt := 1,oDlg2:End()) ENABLE OF oDlg2
				DEFINE SBUTTON FROM 16,246 TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2

				ACTIVATE MSDIALOG oDlg2 CENTERED

				If nOpt == 1
					
					_lMail	:= .T.
					lRet 		:= .T.
				
				Else
					
					Return(lRet)
				
				Endif   
			Endif          

			//_aExclui := {}	

			//While TSC9->(!Eof()) .And. _cRD == TSC9->ZF_REDE

			DbSelectArea("TSC9")                    
			//_cPD := TSC9->C9_PEDIDO

			While TSC9->(!Eof()) .And. _cRD == TSC9->ZF_REDE //.And. _cPD == TSC9->C9_PEDIDO            

				_cPD := TSC9->C9_PEDIDO

				DbSelectArea("SC9")
				DbSetOrder(1)
				If Dbseek(xFilial("SC9")+_cPD)  

					//
					//Rejeicao do Credito para o item da liberacao do Pedido de Venda ( SC9 )
					//

					If _nOpc == 3

						_nPos  := Ascan(_aExclui,{|x| (x[1]) == _cPD } )   //verifico se ja existe o pedido gravado no array de exclusão
						
						If _nPos = 0
							
							AADD(_aExclui,{_cPD,cMotivo})
						Endif
						
						/* //Mauricio - 25/01/2017 - transferido para o momento da exclusão do pedido(fexcped())
						While SC9->(!Eof()) .And. SC9->C9_PEDIDO == _cPD
						//If !(SC9->C9_BLCRED $ "10/ZZ")          //Mauricio - 09/03/16 - mesmo se por acaso houvesse um unico item não bloqueado por credito eu bloqueio todo o pedido por conta do bloqueio a REDE, menos ja faturado.
						//   a450Grava(2,.T.,.F.)
						//ENDIF
						If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLCRED <> "ZZ" )
						Begin Transaction
						a460Estorna(.T.)
						End Transaction
						EndIf		                            
						SC9->(dbSkip())
						Enddo
						*/   

					ElseIf _nOpc == 4

						//
						//Liberacao para todos os itens do SC9
						//

						cPedido := SC9->C9_PEDIDO
						dbSelectArea("SC9")
						dbSetOrder(1)

						lQuery := .T.
						cAliasSC9 := "A450LIBMAN"
						cAliasSC5 := "A450LIBMAN"
						cAliasSC6 := "A450LIBMAN"

						cQuery := "	SELECT "
						cQuery += "		C9_FILIAL, C9_PEDIDO, C9_BLCRED, C9_ITEM, SC9.R_E_C_N_O_ AS SC9RECNO, "
						cQuery += " 	SC5.C5_TIPLIB, SC5.R_E_C_N_O_ AS SC5RECNO, SC6.R_E_C_N_O_ AS SC6RECNO "
						cQuery += " FROM " 
						cQuery += " "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) , "
						cQuery += " "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) , "
						cQuery += " "+RetSqlName("SC6")+" SC6 WITH (NOLOCK)   "
						cQuery += " WHERE "
						cQuery += " SC9.C9_FILIAL = '"+xFilial("SC9")+"' " 
						cQuery += " AND SC9.C9_PEDIDO = '"+cPedido+"' "
						cQuery += " AND SC9.C9_BLCRED <> '"+Space(Len(SC9->C9_BLCRED))+"' " 

						If mv_par01 == 1	

							cQuery += " AND SC9.C9_BLCRED <> '09' "

						EndIf

						cQuery += " AND SC9.C9_BLCRED <> '10' "
						cQuery += " AND SC9.C9_BLCRED <> 'ZZ' "
						cQuery += " AND SC9.D_E_L_E_T_ = ' ' "
						cQuery += " AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
						cQuery += " AND SC5.C5_NUM = SC9.C9_PEDIDO "
						cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
						cQuery += " AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
						cQuery += " AND SC6.C6_NUM=SC5.C5_NUM "
						cQuery += " AND SC6.C6_ITEM=SC9.C9_ITEM "
						cQuery += " AND SC6.C6_PRODUTO=SC9.C9_PRODUTO "
						cQuery += " AND SC6.D_E_L_E_T_ = ' ' " 

						/*//fernando sigoli 01/09/2017 - Incidente na liberação de rede 31/08/2017 - Chamado: 036984				               
						cQuery := "SELECT C9_FILIAL, C9_PEDIDO, C9_BLCRED, C9_ITEM, SC9.R_E_C_N_O_ AS SC9RECNO, SC5.C5_TIPLIB,"
						cQuery += "SC5.R_E_C_N_O_ AS SC5RECNO, SC6.R_E_C_N_O_ AS SC6RECNO "
						cQuery += "FROM "+RetSqlName("SC9")+" AS SC9 WITH (NOLOCK) ,"
						cQuery += RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) ,"
						cQuery += RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "			
						cQuery += "WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
						cQuery += "SC9.C9_PEDIDO = '"+cPedido+"' AND "
						cQuery += "SC9.C9_BLCRED <> '"+Space(Len(SC9->C9_BLCRED))+"' AND "
						If mv_par01 == 1						
						cQuery += "SC9.C9_BLCRED <> '09' AND "				
						Endif	
						cQuery += "SC9.C9_BLCRED <> '10' AND "
						cQuery += "SC9.C9_BLCRED <> 'ZZ' AND "
						cQuery += "SC9.D_E_L_E_T_ = ' ' AND "
						cQuery += "SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
						cQuery += "SC5.C5_NUM=SC9.C9_PEDIDO AND "
						cQuery += "SC5.D_E_L_E_T_ = ' ' AND "
						cQuery += "SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
						cQuery += "SC6.C6_NUM=SC5.C5_NUM AND "
						cQuery += "SC6.C6_ITEM=SC9.C9_ITEM AND "
						cQuery += "SC6.C6_PRODUTO=SC9.C9_PRODUTO AND "
						cQuery += "SC6.D_E_L_E_T_ = ' ' "
						*/

						//cQuery := ChangeQuery(cQuery)//cometei, pois a funcao ChangeQuery remove With (noLock) - fernando sigoli 01/09/2017 Chamado: 036984	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

						While ( !Eof() .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And.;
						      (cAliasSC9)->C9_PEDIDO == cPedido )

							// @history Chamado 059415 - FWNM          - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consistências por indefinições de implantação
							/*
							// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 07/05/2020
							FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
							If FIE->( dbSeek((cAliasSC9)->C9_FILIAL+"R"+(cAliasSC9)->C9_PEDIDO) )

								If AllTrim(Posicione("SC5",1,FWxFilial("SC5")+(cAliasSC9)->C9_PEDIDO,"C5_XWSPAGO")) <> "S"

									lProcessa := .F.

									ApMsgInfo(OemToAnsi("Este pedido("+(cAliasSC9)->C9_PEDIDO+") nao pode ser liberado pois não foi pago." + Chr(13) + ;
									"",;
									"[ADFIN006P-01] - Boleto de Adiantamento não Pago" ))
		
									(cAliasSC9)->( dbSkip() )
									Loop

								EndIf

							EndIf
							*/
							//

							lProcessa := .T.				

							If ( !Empty((cAliasSC9)->C9_BLCRED) .And. (cAliasSC9)->C9_BLCRED <> "10" .And. (cAliasSC9)->C9_BLCRED <> "ZZ")

								If mv_par01 == 1

									If (cAliasSC9)->C9_BLCRED == "09"

										lProcessa := .F.

									Endif	
								Endif

								If lProcessa                        

									//MsgInfo(cPedido)

									SC5->(MsGoto((cAliasSC5)->SC5RECNO))

									If (cAliasSC5)->C5_TIPLIB == "2"

										aadd(aRegSC6,(cAliasSC6)->SC6RECNO)													

									Else

										SC9->(MsGoto((cAliasSC9)->SC9RECNO))							
										a450Grava(1,.T.,.F.)

									EndIf

								EndIf

								//
								//Pontos de Entrada
								//

								If (ExistTemplate("MTA450I"))

									ExecTemplate("MTA450I",.f.,.f.,{_nOpc,dLimLib})										

								EndIf

								If (Existblock("MTA450I"))

									ExecBlock("MTA450I",.f.,.f.,{_nOpc,dLimLib})										

								EndIf

							Endif		

							dbSelectArea(cAliasSC9)
							(cAliasSC9)->(dbSkip())

						EndDo

						dbSelectArea(cAliasSC9)
						dbCloseArea()
						dbSelectArea("SC9")

						If Len(aRegSC6) > 0

							dbSelectArea("SC9")
							DbClearFilter()
							dbSetOrder(1)

							Begin Transaction

								MaAvalSC5("SC5",3,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.)
								aRegSC6 := {}

							End Transaction
						EndIf	
						
						cPedidos += "'" + Alltrim(cValToChar(TSC9->C9_PEDIDO)) +  "'," 	               		                                        	                      
	
					EndIf	                    
				Endif

				DbSelectArea("TSC9")
				TSC9->(DbSkip()) 

			Enddo

			/*                       
			IF len(_aExclui) > 0

			For _zz := 1 to len(_aExclui)
			lMsErroAuto := .F.
			fExcPed(_aExclui[_zz][1],_aExclui[_zz][2])         
			Next _zz

			Endif
			*/

			DbSelectArea("TSC9")                                                                                                         
			
			//Everson - 02/03/2018. Chamado 037261. SalesForce.
			If cEmpAnt == "01" .And. cFilAnt == "02" .And. ! Empty(cPedidos) .And. Findfunction("U_ADVEN050P") .And. _nOpc == 4
				
				If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
				
					cPedidos := Substr(cPedidos,1,Len(cPedidos) -1)
					U_ADVEN050P(,.F.,.T., " AND C5_NUM IN (" + cPedidos + ") AND C5_XPEDSAL <> '' " ,.T.)
				
				EndIf
				
				cPedidos := ""
				
			EndIf
			
		Else               

			DbSelectArea("TSC9")
			TSC9->(DbSkip())

			If TSC9->ZF_REDE == _cRD
			
				_lRDPRI := .F.
			
			Else
			
				_lRDPRI := .T.
			
			Endif
			
			DbSelectArea("TSC9")
		
		Endif     
	Enddo 

	MsUnLockAll()
	//RestArea(aAreaSC9)
	//Eval(bFiltrabrw)
	//dbgotop()
	//SYSREFRESH() 
	//RestArea(aArea)
	//Mauricio - 18/01/2017 - tratamento para exclusão dos pedidos de venda rejeitados do cliente.

	bBloco:={|| fEXCTODOS()}
	MsAguarde(bBloco,"Aguarde...","Excluindo os pedidos de venda rejeitados...",.F.)

	//RestArea(aAreaSC9)
	//Eval(bFiltrabrw)
	//dbgotop()

	SYSREFRESH() 
	RestArea(aArea)

Return() 

Static Function ProcSql()

	MsProcTxt("Selecionando Dados  .....")

	nTotCredRede := nTotSaldRede := nTotCred := nTotSld := 0
	nTotVencRd   := nTotAvenRD   := nTotVCD   := nTotAVC  := 0

	If Select("ZF1") > 0

		DbSelectArea("ZF1")
		DbCloseArea("ZF1")

	Endif

	/*
	cQuery := "SELECT ZF_REDE,ZF_NOMERED,SUBSTRING(A1_CGC,1,8) AS A1_CGC, "
	cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO "
	cQuery += "FROM "+RetSQLName("SZF")+" AS SZF, "+RetSQLName("SA1")+" AS SA1 LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 "
	cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' "
	cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
	cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED" 
	*/

	//Mauricio - 21/09/16 implementado apuracao e gravacao dos campos ZF_VENCIDO e ZF_AVENCER solicitado por Alberto.
	//e ajustado o relatorio com novos campos.

	_dDT  := Date()
	_dDTA := (Date() + 1)
	cQuery := "SELECT ZF_REDE,ZF_NOMERED,SUBSTRING(A1_CGC,1,8) AS A1_CGC, A1_MSBLQL, "
	cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS VENC1, "
	cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO ELSE 0  END) AS VENC2, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS AVENC1, "
	cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO ELSE 0  END) AS AVENC2 "
	cQuery += "FROM "+RetSQLName("SZF")+" AS SZF WITH (NOLOCK), "+RetSQLName("SA1")+" AS SA1 WITH (NOLOCK) LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 WITH (NOLOCK) "
	cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC','AB-') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' " // 05/04/2019 William Costa 048296 || OS 049620 || FINANCAS || ANDREA || 8351 || SALDO REDE           
	cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
	cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED"

	TCQUERY cQuery NEW ALIAS "ZF1"
	Processa( {|| RunRel()},"Aguarde ..." )

Return

Static Function RunRel()

	dbSelectArea("ZF1")
	dbGoTop()
	ProcRegua(RecCount())

	While ZF1->(!Eof())

		nSld := 0
		_nVenc   := 0
		_nAvenc  := 0

		IncProc(OemToAnsi("Atualizando limites : "+AllTrim(ZF1->ZF_REDE)+" - "+AllTrim(ZF1->ZF_NOMERED)))   	     

		cRede     := ZF1->ZF_REDE   
		cNomeRede := ZF1->ZF_NOMERED
		cCGC      := ZF1->A1_CGC
		nLC       := ZF1->LC

		While ZF1->ZF_REDE+ZF1->A1_CGC == cRede+cCGC

			nSld += ZF1->SALDO
			_nVenc  += (ZF1->VENC1 + ZF1->VENC2) 
			_nAVenc += (ZF1->AVENC1 + ZF1->AVENC2)

			ZF1->(dbSkip())

		EndDo

		GravaSZF()

	Enddo    

Return()   

Static Function GravaSZF()

	dbSelectArea("SZF")
	dbSetOrder(1)
	If dbSeek( xFilial() + cCGC )

		u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE","FINANCEIRO","ADFIN006P",;
    		        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(nLC),ComputerName(),LogUserName())

		RecLock("SZF",.F.)
		SZF->ZF_LCREDE  := nLC
		SZF->ZF_SLDREDE := nSld
		SZF->ZF_VENCIDO := _nVenc
		SZF->ZF_AVENCER := _nAVENC     
		MsUnlock()

	EndIf

	dbSelectArea("ZF1")

Return()

Static Function fExcPed(cNum,_cMTV,cPedidos)

	Local aCabec :={}
	Local aItens :={}
	Local aDadRA   := {} // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020

	_cMens1 := ""
	_cMens2 := ""
	_cMens3 := ""
	_eMailVend := ""
	_eMailSup  := ""
	cEmail     := ""
	_cMens     := ""
	_cData     := ""
	_cHora     := ""

	DbSelectArea("SC5")
	DbSetOrder(1)
	If dbSeek(xFilial("SC5")+cNum)

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020
		If !Empty(SC5->C5_XWSPAGO)
			ApMsgInfo(OemToAnsi("Este pedido("+SC5->C5_NUM+") nao pode ser excluído pois possui boleto de adiantamento e já foi pago." + Chr(13) + ;
			"",;
			"Boleto de Adiantamento Pago" ))
			
			Return
		EndIf
		//
	
		If !Empty(SC5->C5_PLACA) .AND. Empty(SC5->C5_NOTA)    //Mauricio - 01/02/17 - chamado 32918
			
			//If !Empty(SC5->C5_PLACA) .OR. !Empty(SC5->C5_ROTEIRO)
			ApMsgInfo(OemToAnsi("Este pedido("+SC5->C5_NUM+") nao pode ser excluido pois já foi roterizado." + Chr(13) + ;
			"Roteiro: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA),;
			"Bloqueado por Roteiro" ))
			Return()

		EndIf

		DbSelectArea("SC9")
		DbSetOrder(1)
		If Dbseek(xFilial("SC9")+cNum)

			While SC9->(!Eof()) .And. SC9->C9_PEDIDO == cNum
				If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLCRED <> "ZZ" )

					Begin Transaction

						a460Estorna(.T.)

					End Transaction

				EndIf

				SC9->(dbSkip())

			Enddo
		Endif

		DbSelectArea("SC5")

		RecLock("SC5",.F.)                                                                                               
		SC5->C5_PLACA   := " "
		SC5->C5_ROTEIRO := "   "
		SC5->C5_UFPLACA := "99"     //12/10/16 - Como o pedido sera excluido uso esse campo como flag
		MsUnlock()

		_cTfilial   := SC5->C5_FILIAL
		_cTCODCLI   := SC5->C5_CLIENTE
		_cTNOMECLI  := SC5->C5_NOMECLI
		_cTAUTNOME  := UPPER(SUBSTR(CUSUARIO,7,15))
		_cTRESPONS  := "33"
		_cTRESPNOM  := "CREDITO"
		_cTPedido   := SC5->C5_NUM
		_cTROTEIRO  := SC5->C5_ROTEIRO
		_cTSEQUENC  := SC5->C5_SEQUENC
		_cTOBS1     := UPPER(_cMTV)
		_cTVEND     := SC5->C5_VEND1
		_cTLOJA     := SC5->C5_LOJACLI
		_cTDEVTOT   := 'O'
		_cTDTDEV    := ddatabase

		fdadosEml(_cMTV)

		//cNum	:= SC5->C5_NUM
		//aAdd( aCabec, { "C5_FILIAL"	 , SC5->C5_FILIAL	, Nil } )
		aAdd( aCabec, { "C5_NUM"	 , cNum		, Nil } )
		//aAdd( aCabec, { "C5_TIPO"	 , SC5->C5_TIPO		, Nil } )
		//	aAdd( aCabec, { "C5_CLIENTE" , SC5->C5_CLIENTE	, Nil } )
		//aAdd( aCabec, { "C5_LOJACLI" , SC5->C5_LOJACLI	, Nil } )
		//aAdd( aCabec, { "C5_LOJAENT" , SC5->C5_LOJAENT	, Nil } )
		//aAdd( aCabec, { "C5_CONDPAG" , SC5->C5_CONDPAG	, Nil } )
		//	aAdd( aCabec, { "C5_ENDERE"  , SC5->C5_ENDERE	, Nil } )
		//aAdd( aCabec, { "C5_EST"     , SC5->C5_EST		, Nil } )
		//aAdd( aCabec, { "C5_BAIRRO"  , SC5->C5_BAIRRO	, Nil } )
		//	aAdd( aCabec, { "C5_CIDADE"  , SC5->C5_CIDADE   , Nil } )

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cNum)

		While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNum

			aLinha := {}
			aAdd( aLinha, { "C6_NUM"	 , cNum					, Nil } )
			aAdd( aLinha, { "C6_ITEM"	 , SC6->C6_ITEM					    , Nil } )
			aAdd( aLinha, { "C6_PRODUTO" , SC6->C6_PRODUTO				    , Nil } )
			//aAdd( aLinha, { "C6_QTDVEN"	 , SC6->C6_QTDVEN					, Nil } )
			//aAdd( aLinha, { "C6_PRCVEN"	 , SC6->C6_PRCVEN		            , Nil } )
			//aAdd( aLinha, { "C6_VALOR"	 , SC6->C6_VALOR				    , Nil } )
			//aAdd( aLinha, { "C6_TES"	 , SC6->C6_TES					    , Nil } )
			//aAdd( aLinha, { "C6_DESCRI"	 , SC6->C6_DESCRI					, Nil } )
			//aAdd( aLinha, { "C6_UM"	 	 , SC6->C6_UM					    , Nil } )
			//aAdd( aLinha, { "C6_LOCAL"	 , SC6->C6_LOCAL					, Nil } )
			//aAdd( aLinha, { "C6_QTDEMP"	 , SC6->C6_QTDEMP					, Nil } )
			//aAdd( aLinha, { "C6_CF"	 	 , SC6->C6_CF					    , Nil } )
			//aAdd( aLinha, { "C6_CLI"	 , SC6->C6_CLI					    , Nil } )
			//aAdd( aLinha, { "C6_ENTREG"	 , SC6->C6_ENTREG					, Nil } )
			//aAdd( aLinha, { "C6_LOJA"	 , SC6->C6_LOJA					    , Nil } )
			//aAdd( aLinha, { "C6_PRUNIT"	 , SC6->C6_PRUNIT					, Nil } )

			Aadd(aItens, aLinha)
			SC6->(dbSkip())

		Enddo

		Begin Transaction

			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,5)  

			If lMsErroAuto

				MostraErro()
				DisarmTransaction()

			Else

				//@history ticket 102 - FWNM - 26/08/2020 - WS BRADESCO 
				SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
				If SC5->( !dbSeek(_cTfilial+cNum) )

					LogZBE(cNum + " FIE - CHECANDO SE O PV EXCLUIDO POSSUI FIE - ADFIN006P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

					// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020
					// Checo amarração RA x PV para excluir após exclusão do PV no Sales Force
					FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
					If FIE->( dbSeek(_cTfilial+"R"+cNum) )

						If FIE->FIE_SALDO > 0

							LogZBE(cNum + " FIE - EXCLUSAO DO FIE APOS PV TER SIDO EXCLUIDO - ADFIN006P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

							RecLock("FIE", .F.)
								FIE->( dbDelete() )
							FIE->( msUnLock() )
						EndIf

					EndIf

					// Checo adiantamento (RA) para excluir após exclusão do PV no Sales Force
					SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
					If SE1->( dbSeek(_cTfilial+PadR("RA",Len(SE1->E1_PREFIXO))+PadR(cNum,Len(SE1->E1_NUM))+PadR("",Len(SE1->E1_PARCELA))+PadR("RA",Len(SE1->E1_TIPO)) ) )

						LogZBE(cNum + " SE1/FIE - SERA EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - ADFIN006P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
						
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
						msExecAuto( { |x,y| FINA040(x,y) }, aDadRA, 5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
						Else
							LogZBE(cNum + " SE1/FIE - EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - ADFIN006P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
						EndIf

					EndIf
				
				EndIf
				//

				//Mauricio - 11/01/17 - novo tratamento para envio do email de exclusao do pedido de venda(não mais pelo MA410DEL)
				DBSelectAreA("SZD")
				RecLock("SZD",.t.)
				ZD_FILIAL := _cTFILIAL
				ZD_CODCLI := _cTCODCLI
				ZD_NOMECLI := _cTNOMECLI
				ZD_AUTNOME := _cTAUTNOME
				ZD_RESPONS := _cTRESPONS
				ZD_RESPNOM := _cTRESPNOM
				ZD_PEDIDO  := _cTPEDIDO
				ZD_ROTEIRO := _cTROTEIRO
				ZD_SEQUENC := _cTSEQUENC
				ZD_OBS1    := _cTOBS1
				ZD_VEND    := _cTVEND
				ZD_LOJA    := _cTLOJA
				ZD_DEVTOT  := _cTDEVTOT
				ZD_DTDEV   := _cTDTDEV
				MsUnlock()

				U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+cNum+" ,PEDIDO EXCLUÍDO - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
				
				cPedidos += "'" + cNum + "',"//Everson - 02/03/2018. Chamado 037261. SalesForce. 

			EndIF

		End Transaction

	Endif

RETURN(NIL)

//Mauricio - 11/01/17 - tratamento para compor corpo do email na exclusão.
Static function fdadosEml(_cMTV)

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
	_cMens1 += '<td width="8%" bgcolor="#FAA21B"><font face="Arial" size="1">Endereço:</font></td>'
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
	_cMens1 += '<td width="7%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Sequência:</font></td>'
	_cMens1 += '<td width="43%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_SEQUENC+'</font></td>'
	_cMens1 += '</tr>'
	_cMens1 += '</table>'
	_cMens1 += '<table border="1" width="982">'
	_cMens1 += '<tr>'
	_cMens1 += '<td width="170" bgcolor="#FAA21B"><font face="Arial" size="1">Condição de Pagamento:</font></td>'
	_cMens1 += '<td width="81" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CONDPAG+'</font></td>'
	_cMens1 += '<td width="84" bgcolor="#FAA21B"><font face="Arial" size="1">Vencimento:</font></td>'
	_cMens1 += '<td width="168" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DATA1)+'</font></td>'
	_cMens1 += '<td width="46" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Emissão:</font></td>'
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
	_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+_cMTV+'</font></b></p>
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
	_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descrição</b></font></td>'
	_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
	_cMens1 += '<td width="283" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Operação</b></font></p></td>'
	_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
	_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
	_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unitário</b></font></td>'
	_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
	_cMens1 += '</tr>'

	_nTotSC6 := 0
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

	ENDDO

	/*
	If Len(aCols) > 0

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
	*/

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
	_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Informática</b></font>'
	_cMens3	+= '</p>'
	_cMens3	+= '</td>'
	_cMens3	+= '</tr>'
	_cMens3	+= '</table>'
	_cMens3	+= '</center>'
	_cMens3	+= '</body>'
	_cMens3	+= '</html>'

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
	
		cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))+';'+Alltrim(GetMv("mv_emails2"))	// Em 23/02/2016 incluido o parâmetro MV_EMAILS2 - CHAMADO 026668 - WILLIAM COSTA
	
	ENDIF

	_cMens := _cMens1+_cMens2+_cMens3
	_cData := transform(MsDate(),"@!")
	_cHora := transform(Time(),"@!")  

Return()

Static function fexctodos()

	Local cPedidos := "" //Everson - 02/03/2018. Chamado 037261. SalesForce.

	IF len(_aExclui) > 0

		For _zz := 1 to len(_aExclui)

			lMsErroAuto := .F.
			fExcPed(_aExclui[_zz][1],_aExclui[_zz][2],@cPedidos)

		Next _zz
		
		//Everson - 02/03/2018. Chamado 037261. SalesForce.
		If cEmpAnt == "01" .And. cFilAnt == "02" .And. ! Empty(cPedidos) .And. Findfunction("U_ADVEN050P")
			
			If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
				
				cPedidos := Substr(cPedidos,1,Len(cPedidos) - 1)
				U_ADVEN050P(,.F.,.T., " AND C5_NUM IN (" + cPedidos + ") AND C5_XPEDSAL <> '' " , .F. )
			
			EndIf
			
			cPedidos := ""
			
		EndIf
		
	Endif

Return()

Static Function fBscAcum(_cRede,c_Cli,c_Loj)

	_nMaior := Posicione("SA1",1,xFilial("SA1")+c_Cli+c_Loj,"A1_VLACUMU")

	If Select("ACUM") > 0
		DbSelectArea("ACUM")
		DbCloseArea("ACUM")
	Endif

	_cQryM := "SELECT ZF_REDE,ZF_VLACUMU  "
	_cQryM += "FROM "+RetSqlName("SZF")+" WITH (NOLOCK) "
	_cQryM += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
	_cQryM += "ORDER BY ZF_REDE" 

	TCQUERY _cQryM New Alias "ACUM"

	_nCt := 0
	_nValAcu := 0
	DbSelectarea("ACUM")
	Dbgotop()
	While ACUM->(!EOf())

		_nCt ++
		_nValAcu := ACUM->ZF_VLACUMU

		ACUM->(dbskip())

	Enddo

	If _nCt > 1

		_nMaior := _nValAcu

	Endif

	DbCLoseArea("ACUM")

Return(_nMaior)

Static Function fBscDtAc(_cRede,c_Cli,c_Loj)

	_dDTM := CTOD("  /  /  ")
	_dDTM := Posicione("SA1",1,xFilial("SA1")+c_Cli+c_Loj,"A1_DTACUMU")

	If Select("ACUM") > 0

		DbSelectArea("ACUM")
		DbCloseArea("ACUM")

	Endif

	_cQryM := "SELECT ZF_REDE,ZF_DTACUMU  "
	_cQryM += "FROM "+RetSqlName("SZF")+" WITH (NOLOCK) "
	_cQryM += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
	_cQryM += "ORDER BY ZF_REDE" 

	TCQUERY _cQryM New Alias "ACUM"

	_nCt := 0
	_sDTM := "        "
	DbSelectarea("ACUM")
	Dbgotop()
	While ACUM->(!EOf())

		_nCt ++
		_sDTM := ACUM->ZF_DTACUMU 

		ACUM->(dbskip())

	Enddo

	If _nCt > 1
	
		_dDTM := STOD(_sDTM)
	
	Endif

	DbCLoseArea("ACUM")

Return(_dDTM)

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
/*/
Static Function logZBE(cMensagem)

	Local aArea	:= GetArea()

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "ADFIN006P" 
	ZBE->( msUnlock() )

Return
