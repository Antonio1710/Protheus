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

/*/{Protheus.doc} User Function ADFIN018P
	Libera credito varejo
	@type  Function
	@author Maurício MDS TEC
	@since 17/02/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 056247 - FWNM          - 24/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Chamado 056247 - FWNM          - 05/06/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Chamado 059415 - FWNM          - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consistências por indefinições de implantação
	@history ticket 102     - FWNM          - 26/08/2020 - WS BRADESCO 
	@history ticket 102     - FWNM          - 27/08/2020 - WS BRADESCO 
	@history Ticket 69574   - Abel Babini   - 25/04/2022 - Projeto FAI
/*/
User Function ADFIN018P()

	Local aArea		:= GetArea()
	Local aAreaSC9  := SC9->(GetArea())
	Local aRegSC6   := {}
	Local lContinua	:= .T.
	Local lQuery    := .F.
	Local nOpcA     := 0
	Local cPedido	:= ""
	Local cAliasSC5 := "SC5"
	Local cAliasSC6 := "SC6"
	Local cAliasSC9 := "SC9"
	Local dLimLib   := dDataBase
	Local lProcessa := .T.	
	Local _cQry     := ""
	local _nOpc 	:= 0
	Local cPedidos	:= ""
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Libera credito varejo.')

	Pergunte("MTA451",.F.)

	_dDTENTR1 := MV_PAR03
	_dDTENTR2 := MV_PAR04

	Private _aMot := {}
	Private oCabD4 
	Private _aExclui := {}   //Armazena pedidos de venda para realizar a exclusão destes a posterior.

	//busco por query os mesmos dados apresentados em tela pelo filtro padrão acima.
	If Select("TSC9") > 0
		DbSelectArea("TSC9")
		DbCloseArea("TSC9")
	Endif

	_cQuery := "SELECT C9_PEDIDO, C9_ITEM, C9_FILIAL,C9_BLCRED, C9_CLIENTE, C9_LOJA FROM "+RetSqlName("SC9")+" C9, "+RetSqlName("SA1")+" A1 "
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

	//_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
	_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND C9_BLCRED <> '' AND " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 05/06/2020
	_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
	_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "        //so varejo
	_cQuery += "ORDER BY C9.C9_CLIENTE, C9.C9_LOJA, C9.C9_PEDIDO, C9.C9_ITEM "

	TCQuery _cQuery NEW ALIAS "TSC9"

	DbSelectArea("TSC9")
	DbGotop()

	IF TSC9->(Eof())
		Msginfo("Não foram encontrados pedidos relativos a varejo para liberação de credito","Atenção")
		Return()
	Endif

	//Apuro valor em aberto de pedidos no periodo/parametro especificado
	_lRdPri := .T.
	While TSC9->(!Eof())

		//mostrar a tela para analise do varejo totalizada por cliente+pedidos
		IF _lRdPri
			_nOpc := 0
			_nTotRede   := 0
			_nTotSdRede := 0
			_nTotVenci  := 0
			_nTotAVenc  := 0

			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+TSC9->C9_CLIENTE+TSC9->C9_LOJA)

			//Chamado 032992 - 01/02/17 - Dados relativos ao cadastro SA1 aonde conforme informações todos os clientes da rede
			//tem esses campos igualmente preenchidos.
			_cRisco   := SA1->A1_XRISCO
			_dDTUATU  := SA1->A1_XDTRISC //Campo incluido em 13/02/2017 por Adriana //Este campo segundo Alberto esta pendente de criação/tratamento pelo William
			_dDTUCOM  := SA1->A1_DTULTRE
			_dDTMACU  := SA1->A1_DTACUMU
			_nVLMACU  := SA1->A1_VLACUMU

			_cCLI     := SA1->A1_COD
			_cLoj     := SA1->A1_LOJA
			_cNomeCli := SA1->A1_NOME
			//_cCnpj := SZF->ZF_CGCMAT

			//Portador Especial
			cQuery:= " SELECT TOP 1 ZAD_DATA AS ZAD_DATA, ZAD_PORTAD FROM " + RetSqlName("ZAD") + " WITH(NOLOCK) "
			cQuery+= " WHERE ZAD_TABELA = 'E' "
			cQuery+= " AND D_E_L_E_T_ <> '*' "
			cQuery+= " ORDER BY ZAD_DATA DESC "

			TCQUERY cQuery new alias "TMPF0"
			TMPF0->(dbgotop())

			cPortador:=TMPF0->ZAD_PORTAD
			DbCloseArea("TMPF0")

			//atrasados
			_dDT  := Date()
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

				DbSelectArea ("TMPF0")
				dbSkip()
			Enddo

			DbCloseArea("TMPF0")

			U_ConsLimFin(_cCLI,"Con","",_dDTENTR1,_dDTENTR2)

			_nTotRede   += _nVlLmCad //_nValLim
			_nTotSdRede += _nSldTit - _nSldTPor

			//Apuro agora valor de todos os pedidos em aberto para esta loja no periodo parametrizado...
			_nPedPer := 0
			If Select("TPA9") > 0
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			Endif

			_cQuery := "SELECT SUM(C9_QTDLIB * C9_PRCVEN) AS TOTAL FROM "+RetSqlName("SC9")+" C9, "+RetSqlName("SA1")+" A1 "
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

			//_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND C9_BLCRED <> '' AND " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNNM - 05/06/2020

			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_nPedPer += TPA9->TOTAL

			//Apuro agora valor de todos os pedidos em aberto para esta loja no periodo posterior ao parametrizado...
			_nPedPos := 0
			If Select("TPA9") > 0
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			Endif

			_cQuery := "SELECT SUM(C9_QTDLIB * C9_PRCVEN) AS TOTAL FROM "+RetSqlName("SC9")+" C9,"+RetSqlName("SA1")+" A1 "
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
				Else  //todos
					_cQuery += "C9_DTENTR > '" + Dtos(_dDtEntr2)  + "' AND "
				Endif
			ENDIF

			//_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND C9_BLCRED <> '' AND " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 05/06/2020
			
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

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

			_cQuery := "SELECT SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS TOTAL FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SA1")+" A1,  "+RetSqlName("SC5")+" C5 "
			_cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND "
			_cQuery += "(C6.C6_ENTREG >= '" + Dtos(_dDtEntr1) + "' AND C6.C6_ENTREG <= '" + Dtos(_dDtEntr2)  + "') AND "
			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C6.C6_CLI = A1.A1_COD AND C6.C6_LOJA = A1.A1_LOJA AND (C6.C6_NUM = C5.C5_NUM) AND "
			_cQuery += "C5.C5_XPREAPR = 'L' AND "
			_cQuery += "((C6.C6_QTDVEN - C6.C6_QTDENT) > 0) AND "    //somente em aberto
			_cQuery += "A1.D_E_L_E_T_='' AND C6.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA6"

			DbSelectArea("TPA6")
			DbGotop()

			_nPreApr += TPA6->TOTAL

			//Contagem de quantidade de pedidos da loja
			_nQtdPed := 0
			If Select("TPA9") > 0
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			Endif

			_cQuery := "SELECT COUNT(DISTINCT C9_PEDIDO) AS TOTPED FROM "+RetSqlName("SC9")+" C9, "+RetSqlName("SA1")+" A1 "
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
			
			//_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND C9_BLCRED <> '' AND " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 05/06/2020

			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "

			TCQuery _cQuery NEW ALIAS "TPA9"

			DbSelectArea("TPA9")
			DbGotop()

			_nQtdPed += TPA9->TOTPED

			//Mauricio - 28/09/16 - tratamento para buscar pedidos de venda bloqueados e seus motivos...
			If Select("TPA9") > 0
				DbSelectArea("TPA9")
				DbCloseArea("TPA9")
			Endif

			_cQuery := "SELECT DISTINCT C9_PEDIDO, C9_FILIAL FROM "+RetSqlName("SC9")+" C9,"+RetSqlName("SA1")+" A1 "
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

			//_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND "
			_cQuery += "C9_BLCRED <> '10' AND C9_BLCRED <> 'ZZ' AND C9_BLCRED <> '' AND " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 05/06/2020

			_cQuery += "A1.A1_COD = '"+_cCli+"' AND A1.A1_LOJA = '"+_cLoj+"' AND "
			_cQuery += "C9.C9_CLIENTE = A1.A1_COD AND C9.C9_LOJA = A1.A1_LOJA AND "
			_cQuery += "A1_CODRED = '      ' AND A1.D_E_L_E_T_='' AND C9.D_E_L_E_T_='' "
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

			@ 200,051 TO 900,700 DIALOG oDlg1 TITLE "LIBERA CREDITO VAREJO"        //200,051     900,800
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
			@ 070,010 SAY "Cliente: "+AllTrim(_cCLI)+"-"+_cLoj +" - " + _cNomeCli  of oDlg1 PIXEL
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
			_cPer := "Valor Pedidos entre("+DTOC(_dDtEntr1)+" e "+DTOC(_dDtEntr2)+"): "
			@ 120,010 SAY _cPer of oDlg1 PIXEL
			@ 120,130 SAY Transform(_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 130,180 SAY "Valor Maior Acumulo:" of oDlg1 PIXEL
			@ 130,250 SAY Transform(_nVLMACU,"@E 999,999,999.99") of oDlg1 PIXEL

			@ 130,010 SAY "Total utilizado: " of oDlg1 PIXEL
			@ 130,130 SAY Transform((_nTotSdRede)+_nPedPer,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 140,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			@ 150,010 SAY "PERCENTUAL" of oDlg1 PIXEL
			@ 150,130 SAY Transform(((_nTotSdRede+_nPedPer)/_nTotRede)*100,"@E 999999.99 %") of oDlg1 PIXEL
			@ 160,010 SAY "_____________________________________________________________________________________________________" of oDlg1 PIXEL
			@ 170,010 SAY "Valor Total Vencidos: " of oDlg1 PIXEL
			@ 170,130 SAY Transform(_nTotVenci,"@E 999,999,999.99") of oDlg1 PIXEL
			@ 190,010 SAY "Valor pedidos ja liberados(pre aprovação):" of oDlg1 PIXEL
			@ 190,130 SAY Transform(_nPreApr,"@E 999,999,999.99") of oDlg1 PIXEL
			//@ 190,010 SAY "Valor Total A Vencer: " of oDlg1 PIXEL
			//@ 190,130 SAY Transform(_nTotAvenc,"@E 999,999,999.99") of oDlg1 PIXEL
			_cPos := "Valor Pedidos após "+DTOC(_dDtEntr2)+": "
			@ 200,010 SAY _cPos  of oDlg1 PIXEL
			@ 200,130 SAY Transform(_nPedPos,"@E 999,999,999.99") of oDlg1 PIXEL
			//@ 130,012 BUTTON OemToAnsi("SAIR") SIZE 34,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 220,012 BUTTON OemToAnsi("APROVA TODOS") SIZE 44,11 ACTION(_nOpc := 4,oDlg1:End() ) of oDlg1 PIXEL      //libera todos
			@ 220,140 BUTTON OemToAnsi("REJEITA TODOS") SIZE 44,11 ACTION(_nOpc := 3,oDlg1:End() ) of oDlg1 PIXEL     //rejeita

			@ 240,012 BUTTON OemToAnsi("SAIR DO CLIENTE") SIZE 44,11 ACTION(_nOpc := 1,oDlg1:End() ) of oDlg1 PIXEL
			@ 240,140 BUTTON OemToAnsi("SAIR DA ROTINA") SIZE 44,11 ACTION(_nOpc := 5,oDlg1:End() ) of oDlg1 PIXEL

			@ 240,250 BUTTON OemToAnsi("CONSULTA POSICAO") SIZE 55,15 ACTION(U_F018TELA(.T.,.T.,.F.,dDatabase,_cCLi,_cLoj,TSC9->C9_PEDIDO) ) of oDlg1 PIXEL

			ACTIVATE DIALOG oDlg1 CENTERED

			//dbSelectArea("TMP")
			//dbCloseArea()
		Endif

		//Mauricio - 23/03/16 - sai da rotina
		If _nOpc == 5
			exit
		Endif

		If _nOpc == 4 .Or. _nOpc == 3

			If _nOpc == 3   //Mauricio - 11/01/2017 - Se houver rejeição do cliente varejo, abro tela para digitar motivo da rejeição para este cliente e todos os seus pedidos..(tela vindado PE MA410DEL ja em uso pelo cliente)
				cMotivo 	:= Space(115)
				nOpt 		:= 0
				lRet		:= .f.
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

			DbSelectArea("TSC9")
			While TSC9->(!Eof()) .And. _cCLI+_cLoj == TSC9->(C9_CLIENTE + C9_LOJA)

				_cPD := TSC9->C9_PEDIDO

				DbSelectArea("SC9")
				DbSetOrder(1)
				If Dbseek(xFilial("SC9")+_cPD)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Rejeicao do Credito para o item da liberacao do Pedido de Venda ( SC9 ) ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If _nOpc == 3
						_nPos  := Ascan(_aExclui,{|x| (x[1]) == _cPD } )   //verifico se ja existe o pedido gravado no array de exclusão
						If _nPos = 0
							AADD(_aExclui,{_cPD,cMotivo})
						Endif

						// Mauricio - 18/01/17 - transferido para o momento da exclusao(fexcped())
						/*
						While SC9->(!Eof()) .And. SC9->C9_PEDIDO == _cPD
						If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLCRED <> "ZZ" )
						Begin Transaction
						a460Estorna(.T.)
						End Transaction
						EndIf
						SC9->(dbSkip())
						Enddo
						*/

					ElseIf _nOpc == 4
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Liberacao para todos os itens do SC9                                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cPedido := SC9->C9_PEDIDO
						dbSelectArea("SC9")
						dbSetOrder(1)

						lQuery := .T.
						cAliasSC9 := "A450LIBMAN"
						cAliasSC5 := "A450LIBMAN"
						cAliasSC6 := "A450LIBMAN"
						cQuery := "SELECT C9_FILIAL,C9_PEDIDO,C9_BLCRED,C9_ITEM,SC9.R_E_C_N_O_ SC9RECNO,SC5.C5_TIPLIB,"
						cQuery += "SC5.R_E_C_N_O_ SC5RECNO,SC6.R_E_C_N_O_ SC6RECNO "
						cQuery += "FROM "+RetSqlName("SC9")+" SC9,"
						cQuery += RetSqlName("SC5")+" SC5,"
						cQuery += RetSqlName("SC6")+" SC6 "
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

						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

						While ( !Eof() .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And.;
						(cAliasSC9)->C9_PEDIDO == cPedido )

							// @history Chamado 059415 - FWNM          - 11/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consistências por indefinições de implantação
							// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 07/05/2020
							/*
							FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
							If FIE->( dbSeek((cAliasSC9)->C9_FILIAL+"R"+(cAliasSC9)->C9_PEDIDO) )

								If AllTrim(Posicione("SC5",1,FWxFilial("SC5")+(cAliasSC9)->C9_PEDIDO,"C5_XWSPAGO")) <> "S"

									lProcessa := .F.

									ApMsgInfo(OemToAnsi("Este pedido("+(cAliasSC9)->C9_PEDIDO+") nao pode ser liberado pois não foi pago." + Chr(13) + ;
									"",;
									"[ADFIN018P-01] - Boleto de Adiantamento não Pago" ))
		
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

									SC5->(MsGoto((cAliasSC5)->SC5RECNO))

									If (cAliasSC5)->C5_TIPLIB == "2"
										aadd(aRegSC6,(cAliasSC6)->SC6RECNO)
									Else
										SC9->(MsGoto((cAliasSC9)->SC9RECNO))
										a450Grava(1,.T.,.F.)
									EndIf

								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Pontos de Entrada 					                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

			DbSelectArea("TSC9")
			
			//Everson - 02/03/2018. Chamado 037261. SalesForce.
			//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
			If Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF .And. ! Empty(cPedidos) .And. Findfunction("U_ADVEN050P") .And. _nOpc == 4
				If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
					cPedidos := Substr(cPedidos,1,Len(cPedidos) -1)
					U_ADVEN050P(,.F.,.T., " AND C5_NUM IN (" + cPedidos + ") AND C5_XPEDSAL <> '' " ,.T.)
				
				EndIf
				cPedidos := ""
				
			EndIf
			
		Else
			DbSelectArea("TSC9")
			TSC9->(DbSkip())
			If TSC9->(C9_CLIENTE + C9_LOJA)== _cCLI+_cLoj
				_lRDPRI := .F.
			Else
				_lRDPRI := .T.
			Endif
		Endif
		DbSelectArea("TSC9")
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

Static Function fExcPed(cNum,_cMTV,cPedidos)

	Local aCabec :={}
	Local aItens :={}
	Local aDadRA := {} // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020

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

		aAdd( aCabec, { "C5_NUM"	 , cNum		, Nil } )

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cNum)
		While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNum
			aLinha := {}

			aAdd( aLinha, { "C6_NUM"	 , cNum					, Nil } )
			aAdd( aLinha, { "C6_ITEM"	 , SC6->C6_ITEM					    , Nil } )
			aAdd( aLinha, { "C6_PRODUTO" , SC6->C6_PRODUTO				    , Nil } )

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

					LogZBE(cNum + " FIE - CHECANDO SE O PV EXCLUIDO POSSUI FIE - ADFIN018P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
	
					// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/04/2020
					// Checo amarração RA x PV para excluir após exclusão do PV no Sales Force
					FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
					If FIE->( dbSeek(_cTfilial+"R"+cNum) )

						If FIE->FIE_SALDO > 0

							LogZBE(cNum + " FIE - EXCLUSAO DO FIE APOS PV TER SIDO EXCLUIDO - ADFIN018P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 

							RecLock("FIE", .F.)
								FIE->( dbDelete() )
							FIE->( msUnLock() )

						EndIf

					EndIf

					// Checo adiantamento (RA) para excluir após exclusão do PV no Sales Force
					SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
					If SE1->( dbSeek(_cTfilial+PadR("RA",Len(SE1->E1_PREFIXO))+PadR(cNum,Len(SE1->E1_NUM))+PadR("",Len(SE1->E1_PARCELA))+PadR("RA",Len(SE1->E1_TIPO)) ) )

						LogZBE(cNum + " SE1/FIE - SERA EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - ADFIN018P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
						
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
							LogZBE(cNum + " SE1/FIE - EXCLUIDO RA APOS FIE E PV TEREM SIDO EXCLUIDOS - ADFIN018P") //@history ticket 102 - FWNM - 27/08/2020 - WS BRADESCO 
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

Return()

/*/{Protheus.doc} User Function F018TELA
	(long_description)
	@type  Function
	@author user
	@since 24/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function F018TELA(lContinua , lAvCred , lAvEst, dLimLib,_cCli,_cLoj,_cPD)

	Local nSaldoLC   := 0
	Local nValItem   := 0
	Local nValPed    := 0
	Local nLimCred   := 0
	Local nMoeda     := 0
	Local nQtdVen    := 0
	Local nSalPedL   := 0
	Local nSalPed    := 0
	Local nSalDup	 := 0
	Local nSalDupM	 := 0
	Local nValAtraso := 0
	Local nOpca 	 := 0
	Local nSalvEmp   := 0
	Local nCntFor    := 0
	Local cDescBloq  := ""
	Local cDescri    := ""
	Local cCondSC9   := ""
	Local oBtn
	Local oDlg
	Local bWhile     := Nil
	Local nMCusto    := 0
	Local nMCustoCli := 0  	
	Local nDecs		 := 0
	Local aSaldos
	Local lLiberado  := .F.
	Local nSalFin    := 0
	Local nSalFinM   := 0
	Local nLcFin     := 0
	Local nLcFinM    := 0
	Local aCols      :={}
	Local aHeader    :={}
	Local cMoeda     := ""
	Local aColsNew   := {}
	Local lMT450COLS := ExistBlock('MT450COLS')
	Local lGestao	 := Iif( FWSizeFilial() > 2, .T., .F.)	//-Indica se esta configurado como Gestao Corporativa na P11
	Local lPosicion  := .F.
	Local nTam		 := 0
	Local cEmpAtu	 := ""	

	Private cCadastro := "Consulta Posi‡„o Cliente"

	DEFAULT dLimLib := dDataBase

	U_ADINF009P('ADFIN018P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Libera credito varejo.')

	DbSelectArea("TSC9")
	_cPD := TSC9->C9_PEDIDO

	DbSelectArea("SC9")
	DbSetOrder(1)
	Dbseek(xFilial("SC9")+_cPD)

	cProduto   := SC9->C9_PRODUTO
	cLocal     := SC9->C9_LOCAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no SC5                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lContinua )
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC9->C9_PEDIDO)
			If !SoftLock("SC5")
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o Tipo de Analize                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SC5->C5_TIPLIB=="2" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando for por PV deve-se somar todos os SC9 gerados para o item        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(xFilial("SC9")+SC9->C9_PEDIDO)
		cCondSC9 := SC9->C9_PEDIDO
		bWhile := {||  xFilial("SC9") == SC9->C9_FILIAL .And.;
		cCondSC9 == SC9->C9_PEDIDO }
	Else
		cCondSC9 := SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
		bWhile   := {||   xFilial("SC9") == SC9->C9_FILIAL .And.;
		cCondSC9 == SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN }
	EndIf

	dbSelectArea("SA1")           // Posiciona cliente
	dbSetOrder(1)
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	nMCusto:= If (SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, VAL(SuperGetMv("MV_MCUSTO")))
	cMoeda           := " "+Pad(SuperGetMv("MV_SIMB"+AllTrim(STR(nMCusto))),4)
	nDecs            := MsDecimais(nMcusto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de analise a ser efetuado ( Filial ou Matriz )    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SuperGetMv("MV_CREDCLI") == "L" )
		nLimCred := SA1->A1_LC
		nSalPed  := SA1->A1_SALPED + SA1->A1_SALPEDB
		nSalPedL := SA1->A1_SALPEDL
		nSalDup  := SA1->A1_SALDUP
		nSalDupM := SA1->A1_SALDUPM
		nSalFin  := SA1->A1_SALFIN
		nLcFin   := SA1->A1_LCFIN
		nLcFinM  := SA1->A1_SALFINM
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma-se Todos os Limites de Credito do Cliente          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
		While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
		SC5->C5_CLIENTE ==  SA1->A1_COD )

			nMCustoCli := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(SuperGetMv("MV_MCUSTO")))
			nLimCred += xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
			nSalPed  += xMoeda(SA1->A1_SALPED+SA1->A1_SALPEDB,nMCustoCli,nMCusto,dDataBase)
			nSalPedL += xMoeda(SA1->A1_SALPEDL,nMCustoCli,nMCusto,dDataBase)
			nSalDup  += SA1->A1_SALDUP
			nSalDupM += xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
			nSalFin  += SA1->A1_SALFIN
			nLcFin   += xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
			nSalFinM += xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
			dbSelectArea("SA1")
			dbSkip()
		EndDo
	EndIf
	nSalvEmp := SM0->(Recno())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analisar o atraso de Todas as Filiais do Sistema                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+IIf(FWModeAccess("SA1",3)=="E",xFilial("SA1"),""))
	While !Eof() .and. M0_CODIGO == cEmpAnt
		If ( SuperGetMv("MV_CREDCLI")=="L" )
			nValAtraso += FtSomaAtr(FWGETCODFILIAL)
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
			While ( !Eof() .And. xFilial("SA1")  == SA1->A1_FILIAL .And.;
			SC5->C5_CLIENTE == SA1->A1_COD )
				nValAtraso += FtSomaAtr(FWGETCODFILIAL)
				dbSelectArea("SA1")
				dbSkip()
			EndDo
		EndIf
		If lGestao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se Filial esta compartilhada e força posicionar na prox filial³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FWModeAccess("SA1",3)=="C" .And. FWModeAccess("SE1",3)=="C" 
				nTam := At("F",M0_LEIAUTE)-1
				//posiciona na prox un de neg 
				cEmpAtu	:= SM0->M0_CODFIL  
				While !EOF() .And. SubStr(SM0->M0_CODFIL,1,nTam)$ cEmpAtu 
					lPosicion:= .T.
					SM0->(dbSkip()) 
				EndDo	
			EndIf	    
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Forca a saida quando o SE1 estiver compartilhado               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( FWModeAccess("SE1",3)=="C" .Or. FWModeAccess("SA1",3)=="E") 
				Exit
			EndIf
		EndIf
		dbSelectArea("SM0")
		If !lPosicion
			dbSkip()
		EndIf
	EndDo
	dbSelectArea("SM0")
	dbGoto(nSalvEmp)

	dbSelectArea("SA1")           // Posiciona cliente
	dbSetOrder(1)
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	dbSelectArea("SC9")
	While ( !Eof() .And. Eval(bWhile) .And. lContinua)
		If (  SC9->C9_BLCRED != "10" .And. SC9->C9_BLEST != "10" .And.;
		SC9->C9_BLCRED != "ZZ" .And. SC9->C9_BLEST != "ZZ" .And.;
		(If(lAvCred,!Empty(SC9->C9_BLCRED),.F.) .Or.;
		If(lAvEst,!Empty(SC9->C9_BLEST),.F.)) )
			lLiberado := .T.
			If !SoftLock("SC9")
				lContinua := .F.
			EndIf
			If ( lContinua )
				dbSelectArea("SC9")

				If ( SC5->C5_TIPO $ "DB" )
					Help(" ",1,"A450NCRED")
					lContinua := .F.
				EndIf
			EndIf
			If ( lContinua )
				dbSelectArea("SC6")           // Posiciona item do pedido
				dbSetOrder(1)
				dbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

				dbSelectArea("SM2")           // Posiciona moeda da data base
				dbSetOrder(1)
				dbSeek(dDataBase,.T.)

				dbSelectArea("SC9")
				nMoeda   := Iif(SC5->C5_MOEDA < 2,1,SC5->C5_MOEDA)
				nValItem := xMoeda((SC6->C6_PRCVEN * SC9->C9_QTDLIB),nMoeda,nMcusto,dDataBase)
				nValPed  += nValItem
				nSalPed  -= nValItem
				nSalPed  := IIf( nSalped < 0 , 0 , nSalPed )

			EndIf
		EndIf
		dbSelectArea("SC9")
		dbSkip()
	EndDo
	dbSelectArea("SC9")
	DbSelectArea("SC9")
	DbSetOrder(1)
	Dbseek(xFilial("SC9")+_cPD)
	//dbGoto(_aArSC9[3])
	If ( !lLiberado )
		Help(" ",1,"A450JALIB")
	Endif
	If ( lContinua .And. lLiberado )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona o SA1                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		If ( SC9->C9_BLCRED == "01" )
			cDescBloq := OemToAnsi("Cr‚dito")  //"Cr‚dito"
		ElseIf SC9->C9_BLCRED == "04"
			cDescBloq := OemToAnsi("Limite de Cr‚dito Vencido")  //"Limite de Cr‚dito Vencido"
		ElseIf SC9->C9_BLCRED == "09"
			cDescBloq := OemToAnsi("Rejeitado")  //"Rejeitado"
		ElseIf !Empty(SC9->C9_BLEST)
			cDescBloq := OemToAnsi("Estoque")  //"Estoque"
		EndIf
		cDescri := Substr(SA1->A1_NOME,1,35)

		aSaldos	        	:=	Array(_STRASALDOS)
		aSaldos[_LIMCREDM] 	:=	nLimCred
		aSaldos[_LIMCRED ] 	:=  xMoeda(nLimCred,nMCusto,1)
		aSaldos[_SALDUPM ] 	:=	nSalDupM
		aSaldos[_SALDUP  ] 	:=	nSalDup
		aSaldos[_SALPEDLM] 	:=	nSalPedL
		aSaldos[_SALPEDL ] 	:=	xMoeda(nSalPedL,nMCusto,1)
		aSaldos[_MCOMPRAM] 	:=	SA1->A1_MCOMPRA
		aSaldos[_MCOMPRA ] 	:=	xMoeda(SA1->A1_MCOMPRA,nMCusto,1)
		aSaldos[_SALDOLCM] 	:=  nLimCred-nSaldupM-nSalPedL
		aSaldos[_SALDOLC ] 	:=  xMoeda(nLimCred-nSaldupM-nSalPedL,nMCusto,1)
		aSaldos[_MAIDUPLM] 	:=	SA1->A1_MAIDUPL
		aSaldos[_MAIDUPL ] 	:=	xMoeda(SA1->A1_MAIDUPL,nMCusto,1)
		aSaldos[_ITATUM  ] 	:=	xMoeda((SC9->C9_PRCVEN * SC9->C9_QTDLIB),nMoeda,nMcusto)
		aSaldos[_ITATU   ] 	:=	xMoeda((SC9->C9_PRCVEN * SC9->C9_QTDLIB),nMoeda,1)
		aSaldos[_PEDATUM ] 	:=  nValPed
		aSaldos[_PEDATU  ]	:=  xMoeda(nValPed ,nMCusto,1)
		aSaldos[_SALPEDM ]	:=	nSalPed
		aSaldos[_SALPED  ]	:=  xMoeda(nSalPed ,nMCusto,1)
		aSaldos[_VALATRM ] 	:=	xMoeda(nValAtraso,1,nMCusto)
		aSaldos[_VALATR  ] 	:=	nValAtraso
		aSaldos[_LCFINM  ] 	:=	nLcFin
		aSaldos[_LCFIN   ] 	:=  xMoeda(nLCFin,nMcusto,1)
		aSaldos[_SALFINM ] 	:=	nSalFinM
		aSaldos[_SALFIN  ] 	:=	nSalFin

		aHeader  := {OemToAnsi("Descrição"),OemToAnsi("Valore"),OemToAnsi("Valores em")+AllTrim(cMoeda)," ",OemToAnsi("Descrição"),;
		OemToAnsi("Posição do Cliene")}

		//Limite de Credito/Tit.Protestados/DT.ULT TIT
		Aadd(aCols,{OemToAnsi("Limite de Credito"),TRansform(aSaldos[_LIMCRED],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LIMCREDM],PesqPict("SA1","A1_LC",17,nMcusto))," ",;
		OemToAnsi("Titulos Protestados"),Space(02)+STR(SA1->A1_TITPROT,3)+Space(05)+;
		OemToAnsi("Em")+Space(03)+DtoC(SA1->A1_DTULTIT)}) //Limite de Credito/Tit.Protestados/DT.ULT TIT

		// Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ	
		Aadd(aCols,{OemToAnsi("Saldo duplicatas"),TRansform(aSaldos[_SALDUP],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDUPM],PesqPict("SA1","A1_SALDUPM",17,nMcusto))," ",;
		OemToAnsi("Cheques devolvidos"),Space(02)+STR(SA1->A1_CHQDEVO,3)+Space(05)+;
		OemToAnsi("Em")+Space(03)+DtoC(SA1->A1_DTULCHQ)}) // Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ

		// Pedidos Aprovados/Maior Compra	
		Aadd(aCols,{OemToAnsi("Pedidos Liberados"),TRansform(aSaldos[_SALPEDL],PesqPict("SA1","A1_SALPEDL",17,1)),;
		TRansform(aSaldos[_SALPEDLM],PesqPict("SA1","A1_SALPEDL",17,nMcusto))," ",OemToAnsi("Maior compra"),;
		Transform(aSaldos[_MCOMPRAM],PesqPict("SA1","A1_MCOMPRA",17,nMCusto))}) // Pedidos Aprovados/Maior Compra

		// Saldo Lim Credito/Maior Duplicata	
		Aadd(aCols,{OemToAnsi("Saldo Lim Credito"),TRansform(aSaldos[_SALDOLC],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDOLCM],PesqPict("SA1","A1_SALDUPM",17,nMcusto))," ",;
		OemToAnsi("Maior Duplicata"),Transform(aSaldos[_MAIDUPLM],PesqPict("SA1","A1_MAIDUPL",17,nMCusto))}) // Saldo Lim Credito/Maior Duplicata

		// Item Pedido Atual/Media de Atraso	
		Aadd(aCols,{OemToAnsi("Item Pedido Atual"),TRansform(aSaldos[_ITATU],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_ITATUM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",;
		OemToAnsi("Media de Atraso"),Space(14)+Transform(SA1->A1_METR,PesqPict("SA1","A1_METR",7))+Space(04)+;
		OemToAnsi("dias")}) // Item Pedido Atual/Media de Atraso

		If SC5->C5_TIPLIB=="2"
			Aadd(aCols,{OemToAnsi("Pedido Atual"),TRansform(aSaldos[_PEDATU],PesqPict("SA1","A1_SALDUP",17,1)),;
			TRansform(aSaldos[_PEDATUM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",;
			OemToAnsi("Vencto.Lim.Credito"),Space(10)+DtoC(SA1->A1_VENCLC)}) //Pedido Atual/ Vencto.Lim.Credito
		Else
			Aadd(aCols,{"","","","",;
			OemToAnsi("Vencto.Lim.Credito"),Space(10)+DtoC(SA1->A1_VENCLC)}) //Pedido Atual/ Vencto.Lim.Credito
		EndIf

		// Saldo de Pedidos / Data Limite Liberação	
		Aadd(aCols,{OemToAnsi("Saldo de Pedidos"),TRansform(aSaldos[_SALPED],PesqPict("SA1","A1_SALPED",17,1)),;
		TRansform(aSaldos[_SALPEDM],PesqPict("SA1","A1_SALPED",17,nMcusto))," ",;
		OemToAnsi("Data Limite Liberação"),Space(10)+DtoC(dLimLib)}) // Saldo de Pedidos / Data Limite Liberação

		//Lim. de Cred. Secundario/Atraso Atual	
		Aadd(aCols,{OemToAnsi("Lim. de Cred. Secundario"),TRansform(aSaldos[_LCFIN],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LCFINM],PesqPict("SA1","A1_LC",17,nMcusto))," ",;
		OemToAnsi("Atraso Atual"),TRansform(aSaldos[_VALATR],PesqPict("SA1","A1_SALDUP",17,1))}) //Lim. de Cred. em Cheque/Atraso Atual

		Aadd(aCols,{OemToAnsi("Saldo LC Sec."),TRansform(aSaldos[_SALFIN],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALFINM],PesqPict("SA1","A1_SALDUP",17,nMcusto))," ",,,}) // Saldo em Cheques
		DEFINE MSDIALOG oDlg FROM  125,3 TO 430,608 TITLE OemToAnsi("Libera‡„o de Cr‚dito") PIXEL    //"Libera‡„o de Cr‚dito"

		//-- Ponto de Entrada permite alterar o conteudo dos campos do aCols		
		IF lMT450COLS
			aColsNew := ExecBlock('MT450COLS',.F.,.F.,{aHeader,aCols})
			IF VALTYPE(aColsNew) == "A"
				aCols := {}
				aCols := ACLONE(aColsNew)
			ENDIF
		ENDIF

		@ 003, 004  TO 033, 299 LABEL "" OF oDlg  PIXEL
		@ 130, 004  TO 150, 155 LABEL "" OF oDlg  PIXEL
		@ 130, 160  TO 150, 240 LABEL "" OF oDlg  PIXEL

		DEFINE SBUTTON FROM 134, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		@ 135, 010 BUTTON OemToAnsi("Posicao")   SIZE 34,11 FONT oDlg:oFont ACTION (a450F4con(),cCadastro:= OemToAnsi("Consulta") )           OF oDlg PIXEL     				//"Consulta"
		@ 135, 045 BUTTON OemToAnsi("Cliente")   SIZE 34,11 FONT oDlg:oFont ACTION (cCadastro:=OemToAnsi("Cliente"),A030Visual("SA1",SA1->(RecNo()),1),cCadastro:= OemToAnsi("Cliente") ) OF oDlg PIXEL   	//"Cliente"
		@ 135, 080 BUTTON OemToAnsi("Pedido")   SIZE 34,11 FONT oDlg:oFont ACTION (cCadastro:=OemToAnsi("Pedido"),a410Visual("SC5",SC5->(RecNo()),1),cCadastro:= OemToAnsi("Pedido") ) OF oDlg PIXEL 	//"Pedido"
		/*
		@ 135, 115 BUTTON OemToAnsi(STR0039)   SIZE 34, 11 FONT oDlg:oFont ACTION ( a450ConEst(cProduto,cLocal) )  OF oDlg PIXEL     					//"Estoque"

		@ 135, 165 BUTTON OemToAnsi(STR0011)   SIZE 34,11 FONT oDlg:oFont ACTION (nOpca := 4,oDlg:End() ) OF oDlg PIXEL     				//"Lib.Todos"
		@ 135, 200 BUTTON OemToAnsi(STR0012)   SIZE 34,11 FONT oDlg:oFont ACTION (nOpca := 3,oDlg:End() ) OF oDlg PIXEL     				//"Rejeita"
		*/
		@ 010, 008 SAY OemToAnsi("Pedido :")      SIZE 23, 7 OF oDlg PIXEL   //"Pedido :"
		@ 010, 032 SAY SC9->C9_PEDIDO          SIZE 26, 7 OF oDlg PIXEL
		@ 010, 060 SAY OemToAnsi("Cond.Pagto. :")      SIZE 35, 7 OF oDlg PIXEL   //"Cond.Pagto. :"
		@ 010, 095 SAY SC5->C5_CONDPAG         SIZE 09, 7 OF oDlg PIXEL
		@ 010, 115 SAY OemToAnsi("Risco :")      SIZE 21, 7 OF oDlg PIXEL   //"Risco :"
		@ 010, 138 SAY SA1->A1_RISCO           SIZE 11, 7 OF oDlg PIXEL
		@ 010, 153 SAY OemToAnsi("Valores em "+SuperGetMv("MV_SIMB"+Alltrim(STR(nMCusto))))  SIZE 50, 7 OF oDlg PIXEL //"Valores em "
		@ 010, 200 SAY OemToAnsi("Bloqueio :")      SIZE 27, 7 OF oDlg PIXEL   //"Bloqueio :"
		@ 010, 230 SAY cDescBloq               SIZE 83, 7 OF oDlg PIXEL

		@ 021, 008 SAY OemToAnsi("Cliente :")      SIZE 23, 7 OF oDlg PIXEL   //"Cliente :"
		@ 021, 032 SAY cDescri                 SIZE 96, 7 OF oDlg PIXEL
		@ 021, 153 SAY OemToAnsi("Data Limite Libera‡Æo :")      SIZE 64, 7 OF oDlg PIXEL   //"Data Limite Libera‡Æo :"
		@ 020.4, 230 MSGET dLimLib               SIZE 52, 7 OF oDlg PIXEL	HASBUTTON

		oLbx := RDListBox(2.48, .5, 295, 95, aCols, aHeader,{55,50,50,12,55,69})

		ACTIVATE MSDIALOG oDlg
	EndIf

	//RestArea(_aArSC9)
	//RestArea(_aAr)
Return()


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
	END

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
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI

	IF len(_aExclui) > 0

		For _zz := 1 to len(_aExclui)
			lMsErroAuto := .F.
			fExcPed(_aExclui[_zz][1],_aExclui[_zz][2],@cPedidos)
		Next _zz

	Endif

	//Everson - 02/03/2018. Chamado 037261. SalesForce.
	//Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
	If Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF .And. ! Empty(cPedidos) .And. Findfunction("U_ADVEN050P")
		If Upper(Alltrim(cValToChar(GetMv("MV_#SFATUF")))) == "S"
			cPedidos := Substr(cPedidos,1,Len(cPedidos) - 1)
			U_ADVEN050P(,.F.,.T., " AND C5_NUM IN (" + cPedidos + ") AND C5_XPEDSAL <> '' " , .F. )
		
		EndIf
		
		cPedidos := ""
		
	EndIf

Return()

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
		Replace ZBE_ROTINA	    With "ADFIN018P" 
	ZBE->( msUnlock() )

Return
