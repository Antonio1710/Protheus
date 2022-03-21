#INCLUDE "rwmake.ch"
#Include "PROTHEUS.CH"
#Include "topconn.CH"               

/*/{Protheus.doc} User Function TELACORTE
	Tela para corte em varios pedidos de vendas de uma vez por produto e data de entrega.Solicitado Sr. Vagner/comercial
	@type  Function
	@author Mauricio-MDS TEC 
	@since 07/08/2013
	@version version
	@history chamado 056247 - FWNM        - 24/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history ticket  8      - Abel Babini - 19/02/2021 - Processar a pré liberação no momento do corte
	@history Ticket  8      - Abel B.     - 01/03/2021 - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
	@history Ticket  8      - Abel B.     - 03/03/2021 - Nova Versao - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
/*/
User Function TELACORTE()

	PUBLIC O_DIALOG       := NIL

	Private _nTotalPedi := 0,_nTotalCx := 0,_nTotalKg := 0,_nTotalBr := 0
	Private _nOpca			:= 00
	Private _cProduto   := SPACE(15)
	Private _cDescri    := ""
	Private _dVcD   := CTOD("  /  /  ")
	Private _dVcA   := CTOD("  /  /  ")
	Private _cSupD  := "      "
	Private _cSupA  := "ZZZZZZ"
	Private _nOrd   := 000
	Private _cCli   := Space(06)
	Private _cSupv  := Space(06)
	Private _cLoj   := Space(02)
	Private _cRaz   := Space(20)
	Private _cPed   := Space(06)
	Private _cIte   := Space(02)
	Private _dDT   := CTOD("  /  /  ")
	Private _nQtPO   := 0
	Private _nQtdA   := 0
	Private _nPrc   := 0.00
	Private _nTCxA   := 0
	Private _nTRsA   := 0.00
	Private _nTRsO   := 0.00
	Private _aPedido	:= {}
	Private _nTTtotPd   := 0
	Private _nTTCxOri   := 0
	Private _nTTCxFim   := 0
	Private _nTTCxAju   := 0
	Private oCabD4
	Private lLiber	 := .F.
	Private	lTrans	 := .F.
	Private	lCredito := .F.
	Private	lEstoque := .F.
	Private	lAvCred	 := .T.
	Private	lAvEst	 := .F.
	Private _lUsuADMV := .F.
	Private _cSupVends := ""
	Static oDgl

	&&Mauricio - 15/07/14 - incluido tratamento para rotina ser utilizada por supervisores e neste caso eles só podem ver os dados/pedidos relativos a eles proprios.
	&&Neste caso nem vou disponibilizar na dialog abaixo os parametros para escoha do supervisor De/Até.
	&&Aqui sera preciso ver se o usuario é ADM VENDAS ou Supervisor(unicos que poderão utilizar a tela).

	Private _cCodUs := __cUserID
	_lRoda  := .F.

	If _cCodUs $ GETMV("MV_#USUTPR")   &&usuarios cadastrados como  ADM VENDAS(rotinas liberadas
		_lUsuADMV := .T.
		_lRoda := .T.
	Endif

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para corte em varios pedidos de vendas de uma vez por produto e data de entrega.Solicitado Sr. Vagner/comercial')

	If !_lUsuADMV
		dbSelectArea("SA3")
		dbSetOrder(7)
		If dbSeek( xFilial("SA3")+_cCodUs )
			If SA3->A3_NIVETAB == "2"  &&Eh Supervisor
				_aCodSup := {}
				While SA3->(!Eof()) .And. SA3->A3_CODUSR == _cCodUs
					AADD(_aCodSup,{SA3->A3_SUPER})
					SA3->(dbSkip())
				Enddo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena em _cSupVends todos os Vendedores do Supervisor     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cSupVends  := ""
				For _ni := 1 to len(_aCodSup)
					dbSelectArea("SA3")
					dbSetOrder(5)        // A3_FILIAL+A3_SUPER
					If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
						Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
						_aCodSup[_ni][1]       == SA3->A3_SUPER
							_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"',"
							SA3->(dbSkip())
						Enddo
						_cSupVends := Substr(_cSupVends,1,Len(_cSupVends)-1)
					Endif
				Next _ni
				_lRoda := .T.
				If Empty(_cSupVends)
					MsgInfo("Não foram encontrados vendedores para este supervisor!", "Atenção")
					Return()
				Endif

			Elseif SA3->A3_NIVETAB $ "3/4"
				_lUsuADMV := .T.
				_lRoda := .T.
			Endif
		Endif
	Endif

	IF !_lRoda
		MsgInfo("Usuario sem acesso a rotina!", "Atenção")
		Return()
	Endif

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Tela para CORTE de Pedidos de Vendas") FROM 115,085  TO 850,1300 COLORS 0, 16777215 PIXEL   // 115,085  TO 650,1350

	&&Borda Interna da Dialog
	@ 002, 002 GROUP oGroup1 TO 335, 610 PROMPT "" OF oDlg COLOR 0, 16777215 PIXEL     //002, 002 TO 265, 632

	&&vinculo objeto a uma variavel
	O_DIALOG := oDlg

	@ 010,008 Say OemToAnsi('Produto: ')   OF oDlg COLORS 0, 16777215 PIXEL
	If _lUsuADMV
		@ 010,220 Say OemToAnsi('Supervisor De: ')   OF oDlg COLORS 0, 16777215 PIXEL
		@ 010,350 Say OemToAnsi('Supervisor Ate: ')   OF oDlg COLORS 0, 16777215 PIXEL
	Endif
	@ 025,008 Say OemToAnsi('DT.Entrega De: ') OF oDlg COLORS 0, 16777215 PIXEL
	@ 025,110 Say OemToAnsi('DT.Entrega Ate: ') OF oDlg COLORS 0, 16777215 PIXEL

	@ 010,060 MsGet _cProduto          				PICTURE "@!" F3 "SB1" SIZE 045,10 OF oDlg  PIXEL
	@ 010,130 Say   fDesc(_cProduto) OF oDlg PIXEL                 //OF oDlg PIXEL
	If _lUsuADMV
		@ 010,282 MsGet _cSupD          				PICTURE "@!" F3 "A06" SIZE 045,10 OF oDlg  PIXEL
		@ 010,402 MsGet _cSupA          				PICTURE "@!" F3 "A06" SIZE 045,10 OF oDlg  PIXEL
	Endif
	@ 025,060 MsGet _dVcD      			            SIZE 045,10 OF oDlg PIXEL
	@ 025,150 MsGet _dVcA      			            SIZE 045,10 OF oDlg PIXEL

	@ 045,008 Say OemToAnsi('Qtd Pedidos: ')   OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,050 Say _nTTtotPd  SIZE 30,10 OF oDlg PIXEL
	@ 045,170 Say OemToAnsi('TOT CXS ORIG: ') OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,230 Say _nTTCxOri  SIZE 35,10 OF oDlg PIXEL
	@ 045,290 Say OemToAnsi('TOT CXS APOS AJUST: ') OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,370 Say _nTTCxFim  SIZE 35,10 OF oDlg PIXEL
	@ 045,420 Say OemToAnsi('Ajuste Feito CXS: ') OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,480 Say _nTTCxAju  SIZE 30,10 OF oDlg PIXEL

	@ 025,290 BUTTON "Busca Pedidos" SIZE 040,010 ACTION(AtulistBox(@_aPedido,2)) OF oDlg PIXEL
	@ 025,370 BUTTON "Simular" SIZE 050,010 ACTION(fCalc()) OF oDlg PIXEL
	@ 025,440 BUTTON "Efetua CORTE" SIZE 050,010 ACTION(fCorte()) OF oDlg PIXEL

	aHeaderT := {}

	AAdd(aHeaderT,{"Ordem"                   ,"_nOrd"    ,"",003,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Supervisor"              ,"_cSupv"   ,"",006,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Cliente"                 ,"_cCli"    ,"",006,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Loja"                    ,"_cLoj"    ,"",002,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Razao Social"            ,"_cRaz"    ,"",020,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Pedido "                  ,"_cPed"    ,"",006,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Item"                     ,"_cIte"    ,"",002,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Data Entrega"            ,"_dDT"     ,"",010,0 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Cxs Orig"   ,"_nQtPO"   ,"",12,4 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Cxs Ajust"      ,"_nQtdA"   ,"",12,4 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Preço"                    ,"_nPrc"    ,"",17,2 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Total Cxs Ajust"  ,"_nTCxA"   ,"",12,4 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Total R$ Orig"   ,"_nTRsO"   ,"",17,2 ,"" ,"û" ,"C",""," ","",,,"A",,,})
	AAdd(aHeaderT,{"Total R$ Ajust"   ,"_nTRsA"   ,"",17,2 ,"" ,"û" ,"C",""," ","",,,"A",,,})

	//aAlter := {'C6_UNSVEN'}  &&array para campos que podem ser alterados na getdados/ Mauricio nao esta funcionando no Protheus...retirado.

	MsAguarde( {|| AtuListBox( @_aPedido,1) }, OemToAnsi( "Aguarde...." ) )

	oCabD4 :=MsNewGetDados():New( 060,007,350,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,300,600
	oCabD4:oBrowse:Refresh()
	//MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)

	@ 025,550 BUTTON "Sair" SIZE 030,010 ACTION(RECBCD()) OF oDlg PIXEL

	ACTIVATE DIALOG ODLG CENTERED

RETURN()

STATIC FUNCTION RECBCD()
	CLOSE(O_DIALOG)
RETURN (.T.)

Static Function AtuListBox( _aPedido,_nOp)

	If (Empty(_cProduto) .Or. Empty(_dVcA) .Or. Empty(_dVcD)) .Or. _nOp == 1
		_aPedido := {}
		If Len(_aPedido) <= 00
			AADD(_aPedido,{Transform(0,"","@E 999"),"",,,,,DTOC(CTOD("  /  /  ")),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})
		EndIf
		oDlg:Refresh()
		//GetdRefresh()
		//SysRefresh()
		//oPedido:Refresh()
	Else
		_nTTCxFim   := 0
		_nTTCxAju   := 0

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif

		//&&Contagem de quantidade de pedidos
		_cQuery  := "SELECT COUNT(DISTINCT C5_NUM) AS TOTPED "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SA3")+" A3 "

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " , " + RetSqlName("SE4") + " E4 (NOLOCK) 
		//

		_cQuery  += "WHERE C5.D_E_L_E_T_ <> '*'  AND C6.D_E_L_E_T_ <> '*' AND A3.D_E_L_E_T_ <> '*' AND C6.C6_PRODUTO = '"+_cProduto+"' "
		_cQuery  += "AND C6.C6_ENTREG >= '"+DTOS(_dVcD)+"' AND C6.C6_ENTREG <= '"+DTOS(_dVcA)+"' "
		_cQuery  += "AND C6.C6_NUM = C5.C5_NUM AND C6.C6_FILIAL = '"+cfilAnt+"' AND C5.C5_FILIAL = '"+cFilAnt+"' AND C6.C6_NOTA = '         ' AND C5.C5_PLACA = '       '  AND C5.C5_XGERSF <> '2' "

		//&&Mauricio - 23/07/14 - tratamento para garantir integridade na escolha dos codigos dos supervisores no relatorio.
		If _lUsuADMV
			If (Empty(_cSupD) .Or. Empty(_cSupA))
				_cSupD := "      "
				_cSupA := "ZZZZZZ"
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_CODSUP >= '"+_cSupD+"' AND A3.A3_CODSUP <= '"+_cSupA+"') "
			Elseif _cSupD <> _cSupA
				MsgInfo("Permitido apenas filtrar por um supervisor ou por Branco a ZZZZZZ(todos)","Atenção")
				_aPedido := {}
				If Len(_aPedido) <= 00
					AADD(_aPedido,{Transform(0,"","@E 999"),,,,,,DTOC(CTOD("  /  /  ")),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})
				EndIf
				oCabD4 :=MsNewGetDados():New( 060,007,350,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,300,600
				oCabD4:oBrowse:Refresh()
				oCabD4:GoBottom()
				oCabD4:GoTop()
				oCabD4:Refresh(.T.)
				oDlg:Refresh()
				GetdRefresh()
				SysRefresh()
				Return(Nil)
			Else
				_aUserCod := {}
				_cSupVends  := ""
				DbSelectArea("SZR")
				DbSetOrder(1)
				if Dbseek(xFilial("SZR")+_cSupD)
					While SZR->(!Eof()) .And. SZR->ZR_CODIGO <= _cSupA
						if Ascan(_aUserCod,SZR->ZR_USER) == 0
							AADD(_aUserCod,{SZR->ZR_USER})
						Endif
						SZR->(dbSkip())
					Enddo
					For _nU := 1 To len(_aUserCod)
						dbSelectArea("SA3")
						dbSetOrder(7)
						If dbSeek( xFilial("SA3")+_aUserCod[_nU][1] )
							_aCodSup := {}
							While SA3->(!Eof()) .And. SA3->A3_CODUSR == _aUserCod[_nU][1]
								if Ascan(_aCodSup,SA3->A3_SUPER) == 0
									AADD(_aCodSup,{SA3->A3_SUPER})
								Endif
								SA3->(dbSkip())
							Enddo
							For _ni := 1 to len(_aCodSup)
								dbSelectArea("SA3")
								dbSetOrder(5)        // A3_FILIAL+A3_SUPER
								If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
									Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
									_aCodSup[_ni][1]       == SA3->A3_SUPER
										_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"',"
										SA3->(dbSkip())
									Enddo
									_cSupVends := Substr(_cSupVends,1,Len(_cSupVends)-1)
								Endif
							Next _ni
						Endif
					Next _nU
				Endif
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
			Endif
		Else
			_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
		Endif

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " AND E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT<>'1' AND E4.D_E_L_E_T_=''
		// 

		TCQUERY _cQuery NEW ALIAS "TSC6"

		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		_nTTtotPd := TSC6->TOTPED

		DbCloseArea("TSC6")

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif

		&&Soma quantidade de caixas originais
		_cQuery  := "SELECT SUM(C6_UNSVEN) AS TOTCXS "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SA3")+" A3 "

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " , " + RetSqlName("SE4") + " E4 (NOLOCK) 
		//

		_cQuery  += "WHERE C5.D_E_L_E_T_ <> '*'  AND C6.D_E_L_E_T_ <> '*' AND A3.D_E_L_E_T_ <> '*' AND C6.C6_PRODUTO = '"+_cProduto+"' "
		_cQuery  += "AND C6.C6_ENTREG >= '"+DTOS(_dVcD)+"' AND C6.C6_ENTREG <= '"+DTOS(_dVcA)+"' "
		_cQuery  += "AND C6.C6_NUM = C5.C5_NUM AND C6.C6_FILIAL = '"+cfilAnt+"' AND C5.C5_FILIAL = '"+cFilAnt+"' AND C6.C6_NOTA = '         ' AND C5.C5_PLACA = '       '  AND C5.C5_XGERSF <> '2' "
		If _lUsuADMV
			If (Empty(_cSupD) .Or. Empty(_cSupA))
				_cSupD := "      "
				_cSupA := "ZZZZZZ"
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_CODSUP >= '"+_cSupD+"' AND A3.A3_CODSUP <= '"+_cSupA+"') "
			Else
				_aUserCod := {}
				_cSupVends  := ""
				DbSelectArea("SZR")
				DbSetOrder(1)
				if Dbseek(xFilial("SZR")+_cSupD)
					While SZR->(!Eof()) .And. SZR->ZR_CODIGO <= _cSupA
						if Ascan(_aUserCod,SZR->ZR_USER) == 0
							AADD(_aUserCod,{SZR->ZR_USER})
						Endif
						SZR->(dbSkip())
					Enddo
					For _nU := 1 To len(_aUserCod)
						dbSelectArea("SA3")
						dbSetOrder(7)
						If dbSeek( xFilial("SA3")+_aUserCod[_nU][1] )
							_aCodSup := {}
							While SA3->(!Eof()) .And. SA3->A3_CODUSR == _aUserCod[_nU][1]
								if Ascan(_aCodSup,SA3->A3_SUPER) == 0
									AADD(_aCodSup,{SA3->A3_SUPER})
								Endif
								SA3->(dbSkip())
							Enddo
							For _ni := 1 to len(_aCodSup)
								dbSelectArea("SA3")
								dbSetOrder(5)        // A3_FILIAL+A3_SUPER
								If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
									Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
									_aCodSup[_ni][1]       == SA3->A3_SUPER
										_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"',"
										SA3->(dbSkip())
									Enddo
									_cSupVends := Substr(_cSupVends,1,Len(_cSupVends)-1)
								Endif
							Next _ni
						Endif
					Next _nU
				Endif
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
			Endif
		Else
			_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
		Endif

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " AND E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT<>'1' AND E4.D_E_L_E_T_=''
		// 

		TCQUERY _cQuery NEW ALIAS "TSC6"

		DbSelectArea("TSC6")
		TSC6->(dbgotop())
		_nTTCxOri := TSC6->TOTCXS

		DbCloseArea("TSC6")

		If Select("TSC6") > 0
			DbSelectArea("TSC6")
			DbCloseArea("TSC6")
		Endif

		_cQuery  := "SELECT * "
		_cQuery  += "FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SA3")+" A3 "

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " , " + RetSqlName("SE4") + " E4 (NOLOCK) 
		//

		_cQuery  += "WHERE C5.D_E_L_E_T_ <> '*'  AND C6.D_E_L_E_T_ <> '*' AND A3.D_E_L_E_T_ <> '*' AND C6.C6_PRODUTO = '"+_cProduto+"' "
		_cQuery  += "AND C6.C6_ENTREG >= '"+DTOS(_dVcD)+"' AND C6.C6_ENTREG <= '"+DTOS(_dVcA)+"' "
		_cQuery  += "AND C6.C6_NUM = C5.C5_NUM AND C6.C6_FILIAL = '"+cfilAnt+"' AND C5.C5_FILIAL = '"+cFilAnt+"' AND C6.C6_NOTA = '         ' AND C5.C5_PLACA = '       ' AND C5.C5_XGERSF <> '2' "
		If _lUsuADMV
			If (Empty(_cSupD) .Or. Empty(_cSupA))
				_cSupD := "      "
				_cSupA := "ZZZZZZ"
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_CODSUP >= '"+_cSupD+"' AND A3.A3_CODSUP <= '"+_cSupA+"') "
			Else
				_aUserCod := {}
				_cSupVends  := ""
				DbSelectArea("SZR")
				DbSetOrder(1)
				if Dbseek(xFilial("SZR")+_cSupD)
					While SZR->(!Eof()) .And. SZR->ZR_CODIGO <= _cSupA
						if Ascan(_aUserCod,SZR->ZR_USER) == 0
							AADD(_aUserCod,{SZR->ZR_USER})
						Endif
						SZR->(dbSkip())
					Enddo
					For _nU := 1 To len(_aUserCod)
						dbSelectArea("SA3")
						dbSetOrder(7)
						If dbSeek( xFilial("SA3")+_aUserCod[_nU][1] )
							_aCodSup := {}
							While SA3->(!Eof()) .And. SA3->A3_CODUSR == _aUserCod[_nU][1]
								if Ascan(_aCodSup,SA3->A3_SUPER) == 0
									AADD(_aCodSup,{SA3->A3_SUPER})
								Endif
								SA3->(dbSkip())
							Enddo
							For _ni := 1 to len(_aCodSup)
								dbSelectArea("SA3")
								dbSetOrder(5)        // A3_FILIAL+A3_SUPER
								If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
									Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
									_aCodSup[_ni][1]       == SA3->A3_SUPER
										_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"',"
										SA3->(dbSkip())
									Enddo
									_cSupVends := Substr(_cSupVends,1,Len(_cSupVends)-1)
								Endif
							Next _ni
						Endif
					Next _nU
				Endif
				_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
			Endif
		Else
			_cQuery  += "AND C5.C5_VEND1 = A3.A3_COD AND (A3.A3_COD IN ("+_cSupVends+")) "
		Endif

		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
		_cQuery  += " AND E4_FILIAL='"+FWxFilial("SE4")+"' AND E4_CODIGO=C5_CONDPAG AND E4_CTRADT<>'1' AND E4.D_E_L_E_T_=''
		// 

		//_cQuery  += "ORDER BY C6.C6_CLI, C6.C6_LOJA,C6.C6_NUM,C6.C6_ITEM "
		If _lUsuADMV
			_cQuery  += "ORDER BY A3.A3_SUPER, C6.C6_PRCVEN ASC "
		else
			_cQuery  += "ORDER BY C6.C6_PRCVEN ASC "
		Endif

		TCQUERY _cQuery NEW ALIAS "TSC6"

		_aPedido := {}
		_nOrdem  := 1
		DbSelectArea("TSC6")
		DbGoTop()
		While TSC6->(!Eof())
			//&&Para cada item, preciso apurar o valor total do pedido original para trazer em tela...
			_nTpedvl  := 0
			DbSelectArea("SC6")
			DbSetOrder(1)
			Dbgotop()
			if dbseek(xFilial("SC6")+TSC6->C6_NUM)
				While SC6->(!Eof()) .And. SC6->C6_NUM == TSC6->C6_NUM
					_nTpedvl += SC6->C6_VALOR
					SC6->(dbskip())
				Enddo
			Endif

			//AADD(_aPedido,{Transform(_nOrdem,"@E 999"),TSC6->C6_CLI,TSC6->C6_LOJA,TSC6->C5_NOMECLI,TSC6->C6_NUM,TSC6->C6_ITEM,DTOC(STOD(TSC6->C6_ENTREG)),Transform(TSC6->C6_UNSVEN,"@E 999,999.9999"),Transform(TSC6->C6_UNSVEN,"@E 999,999.9999"),Transform(TSC6->C6_PRCVEN,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})
			AADD(_aPedido,{Transform(_nOrdem,"@E 999"),TSC6->A3_SUPER,TSC6->C6_CLI,TSC6->C6_LOJA,TSC6->C5_NOMECLI,TSC6->C6_NUM,TSC6->C6_ITEM,DTOC(STOD(TSC6->C6_ENTREG)),TSC6->C6_UNSVEN,TSC6->C6_UNSVEN,Transform(TSC6->C6_PRCVEN,"@E 999,999,999.9999"),0,Transform(_nTpedvl,"@E 999,999,999.99"),0,.F.})
			_nOrdem += 1
			If _nOrdem == 1000      && Mauricio limita a apresentação de 999 itens somente
				exit
			Endif
			TSC6->(dbSkip())
		Enddo

		If Len(_aPedido) <= 00
			AADD(_aPedido,{Transform(0,"@E 999"),,,,,,,DTOC(CTOD("  /  /  ")),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})
		EndIf

		//aAlter := {'C6_UNSVEN'}  &&array para campos que podem ser alterados na getdados
		oCabD4 :=MsNewGetDados():New( 060,007,350,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,300,600
		oCabD4:oBrowse:Refresh()
		oCabD4:GoBottom()
		oCabD4:GoTop()
		oCabD4:Refresh(.T.)
		oDlg:Refresh()
		GetdRefresh()
		SysRefresh()
	Endif

Return(Nil)

Static function fCorte()

	If MsgYesNo(OemToAnsi("Confirma corte dos produtos para os itens/pedidos ajustados?"),OemToAnsi("A T E N Ç Ã O"))
		//	Begin transaction
		nPosOrd  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Ordem"})
		nPosSup  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Supervisor"})
		nPosCli  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cliente"})
		nPosLoj  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Loja"})
		nPosRaz  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Razao Social"})
		nPosPed  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Pedido"})
		nPosIte  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Item"})
		nPosDta  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Data Entrega"})
		nPCxOri  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cxs Orig"})
		nPCxAju  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cxs Ajust"})
		nPosPru  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Preço"})
		nPTCxAj  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total Cxs Ajust"})
		nPTRsOr  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total R$ Orig"})
		nPTRsAj  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total R$ Ajust"})

		_aP1      := oCabD4:aCols
		_nTTCxFim := _nTTCxOri
		_nTTCxAju := 0000
		_aPedido := {}
		AADD(_aPedido,{Transform(0,"@E 999"),,"",,,,,DTOC(CTOD("  /  /  ")),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})
		For _n1 := 1 To len(_aP1)
			If _aP1[_n1][nPCxAju] > _aP1[_n1][nPCxOri]
				MsgInfo("Permitido apenas ajuste de corte(a menor). Item(ordem) "+_aP1[_n1][nPosOrd]+" ajuste a maior.ITEM DESCONSIDERADO","Atenção")
				//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
			Endif
			&&valido a quantidade original, preço, pedido e item pedido com o pedido de venda original para ter certeza que somente a coluna de ajuste
			&&tenha sido alterada.
			DbSelectArea("SC6")
			DbSetOrder(1)
			if dbseek(xfilial("SC6")+_aP1[_n1][nPosPed]+_aP1[_n1][nPosIte]+_cProduto)
				&&valido data de entrega, qtd original e preco (original do pedido) se permanecem inalterados
				If (SC6->C6_ENTREG <> CTOD(_aP1[_n1][nPosDta])) .Or. (VAL(STRTRAN(_aP1[_n1][nPosPru],",",".")) <> SC6->C6_PRCVEN) .Or. (_aP1[_n1][nPCxOri] <> SC6->C6_UNSVEN)
					MsgInfo("Inconsistencia nos dados dos campos item/ordem "+_aP1[_n1][nPosOrd]+".Entrega/preco/caixas orig. diferentes do PV!ITEM DESCONSIDERADO","Atenção")
					//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
					loop
				Endif
			Else &&inconsistencia
				MsgInfo("Inconsistencia nos dados dos campos item/ordem "+_aP1[_n1][nPosOrd]+".Pedido/item/produto não encontrado!ITEM DESCONSIDERADO","Atenção")
				//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
			Endif
			//Begin transaction
			If _aP1[_n1][nPCxOri] <> _aP1[_n1][nPCxAju]  &&sendo diferente houve ajuste e inicia-se processo de corte...
				_nTTCxFim -= (_aP1[_n1][nPCxOri] - _aP1[_n1][nPCxAju])
				_nTTCxAju += (_aP1[_n1][nPCxOri] - _aP1[_n1][nPCxAju])
				_nTpedcx  := 0
				_nTpedvl  := 0

				&&Chamado 032142 - Alterado todo o tratamento de pedido minimo para enxergar valor minimo por supervisor somente
				&&Demais usuarios não sera necessaria validação segundo sr. Vagner(vendedores nao acessam rotina e gerentes podem alterar).

				&&Valido novo valor ajustado de total de pedido com parametro de valor minimo ZZ_LIMITPV
				DbSelectArea("SC6")
				DbSetOrder(1)
				Dbgotop()
				if dbseek(xFilial("SC6")+_aP1[_n1][nPosPed])
					While SC6->(!Eof()) .And. SC6->C6_NUM == _aP1[_n1][nPosPed]
						If SC6->C6_ITEM == _aP1[_n1][nPosIte] .And. SC6->C6_PRODUTO == _cProduto
							//_nTpedcx +=_aP1[_n1][nPCxAju]
							_nPesoCx := SC6->C6_QTDVEN / SC6->C6_UNSVEN
							_nTpedvl += SC6->C6_PRCVEN * (_aP1[_n1][nPCxAju] * _nPesoCx) &&recalculo do valor total do item ajustado
						Else
							//_nTpedcx += SC6->C6_UNSVEN
							_nTpedvl += SC6->C6_VALOR
						Endif
						SC6->(dbskip())
					Enddo
				Endif
				/*
				_nVLMIN := GETMV("ZZ_LIMITPV")
				_cLogMin := ""
				if _nTpedvl < _nVLMIN			
				MsgInfo("Pedido de venda "+_aP1[_n1][nPosPed]+" com Valor ajustado abaixo do minimo!!!!","Atenção")
				If !MsgYesNo(OemToAnsi("Confirma assim mesmo?Sem valor minimo atingido?"),OemToAnsi("A T E N Ç Ã O"))
				_cLogMin := "ABAIXOMINIMO"
				AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
				Endif
				//Begin transaction				
				Endif
				&&Mauricio - 22/04/15 - novo tratamento relativo ao valor minimo do pedido por faixa/vendedor. O tratamento acima não ira mais funcionar(mas foi mantido) pois no parametro foi colocado ZERO como valor minimo.
				dbSelectArea("SC5")
				dbSetOrder(1)
				If dbSeek(xFilial("SC5")+_aP1[_n1][nPosPed])
				_cVDPED := SC5->C5_VEND1				
				DbSelectArea("SA3")
				DbSetOrder(1)
				if dbseek(xFilial("SA3")+_cVDPED) 
				_cFaixa := SA3->A3_FXPDMIN
				IF empty(_cFaixa)
				ApMsgInfo(OemToAnsi("Atencao !! Vendedor no pedido "+_aP1[_n1][nPosPed]+", sem faixa alocada em seu cadastro. O pedido não pode ser validado! !!"))
				If !MsgYesNo(OemToAnsi("Confirma assim mesmo? Sem faixa no cadastro e sem valor minimo?"),OemToAnsi("A T E N Ç Ã O"))
				AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop    
				Endif
				Else
				_nValmin := VAL(Posicione("SX5",1,"02"+"A#"+_cFaixa,"X5_DESCRI"))
				If _nTpedvl < _nValmin
				MsgInfo("Pedido de venda "+_aP1[_n1][nPosPed]+" com Valor ajustado abaixo do minimo!!!!","Atenção")
				//ApMsgInfo(OemToAnsi("Atencao !! O Valor Minimo para os Pedidos de Vendas é de R$ " + Alltrim(Transform(_nValmin,"@E 999,999,999.99") ) + ". Verifique!!"))
				If !MsgYesNo(OemToAnsi("Confirma assim mesmo?Sem valor minimo atingido?"),OemToAnsi("A T E N Ç Ã O"))
				AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
				Endif
				EndIf				   
				Endif  
				endif
				Endif
				*/
				&&Chamado 032142 - Alterado todo o tratamento de pedido minimo para enxergar valor minimo por supervisor somente
				&&Demais usuarios não sera necessaria validação segundo sr. Vagner(vendedores nao acessam rotina e gerentes podem alterar).
				_cLogMin := ""
				dbSelectArea("SA3")
				dbSetOrder(7)
				If dbSeek( xFilial("SA3")+_cCodUs )
					&&conforme informação do Sr. Vagner somente supervisor sofre validacao, ja que vendedor nao acessa a rotina e gerente/diretor nao tem restrição de corte de valor
					If SA3->A3_NIVETAB == "2"  &&Eh supervisor
						_nValmin := SA3->A3_VLPDMIN
						If _nTpedvl < _nValmin
							_cLogMin := "ABAIXOMINIMO"
							MsgInfo("O Pedido de venda "+_aP1[_n1][nPosPed]+" ficou com valor abaixo de R$ "+Transform(_nValmin,"@E 9,999,999.99")+" e o mesmo não sofrera alteração/corte!!!!","Atenção")					     					     
							//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
							loop				         
						EndIf			   
					Endif
				Else
					MsgInfo("Seu usuario nao tem cadastro na tabela de vendedores, assim o pedido "+_aP1[_n1][nPosPed]+" não sofrera alteração/corte!!!!","Atenção")					     					     
					//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
					loop			 
				Endif

				&&inicio tratamento de corte...analise para recalculo IPTAB se possivel
				&&premissa informada pelo Sr. Vagner..nunca em um mesmo pedido de venda eu vou ter dois itens com mesmo produto.....
				&&caso esteja liberado, retiro a liberação para novo processo com as quantidades alteradas no corte.
				_lDelSC9 := .F.  &&controlo se vou precisar gerar SC9 ao final ou não do processo.....

				&&21/10/16 Novo tratamento para pre aprovacao do credito
				//           fPreAprv(xFilial("SC5"),_cNumped,_cCliente,_cLoja)  &&funcao pra limpeza de flag de pre aprovacao de pedidos de venda.

				Begin transaction
					dbSelectArea("SC5")
					dbSetOrder(1)
					If dbSeek(xFilial("SC5")+_aP1[_n1][nPosPed])			   			
						Reclock("SC5",.F.)
						SC5->C5_LIBEROK := " "
						SC5->C5_XTOTPED := _nTpedvl   &&gravo novo valor total do pedido
						MsUnlock()

						//ticket  8      - Abel Babini - 19/02/2021 - Processar a pré liberação no momento do corte
						//Comentada a chamada à função que limpa o status de pré liberação e executadoa a chamada à nova função de pré liberação
						&&21/10/16 Novo tratamento para pre aprovacao do credito
						//fPreAprv(xFilial("SC5"),SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI)  &&funcao pra limpeza de flag de pre aprovacao de pedidos de venda.
						
					Endif
					dbSelectArea("SC9")
					dbSetOrder(1)
					If dbSeek(xFilial("SC9")+_aP1[_n1][nPosPed])
						_lDelSC9 := .T.
						While !Eof() .And. SC9->C9_PEDIDO == _aP1[_n1][nPosPed]
							Reclock("SC9",.F.)
							dbDelete()
							MsUnlock()
							SC9->(dbSkip())
						EndDo
					EndIf
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbgotop()
					If dbSeek(xFilial("SC6")+_aP1[_n1][nPosPed])
						While !Eof() .And. SC6->C6_NUM == _aP1[_n1][nPosPed]
							Reclock("SC6",.F.)
							SC6->C6_QTDEMP  := 0.00
							SC6->C6_QTDEMP2 := 0.00
							MsUnlock()
							dbSkip()
						EndDo
					EndIf

					&&ajusto item no SC6 conforme corte efetuado....
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbgotop()
					If dbSeek(xFilial("SC6")+_aP1[_n1][nPosPed]+_aP1[_n1][nPosIte]+_cProduto)
						&&quantidade de caixa original é do campo C6_UNSVEN...
						if _aP1[_n1][nPCxAju] == 0     &&se a quantidade foi ajustada para zero....
							Reclock("SC6",.F.)
							DbDelete()
							SC6->(Msunlock())
						ELSE
							_nPes := SC6->C6_QTDVEN / SC6->C6_UNSVEN  &&encontro peso por caixa
							Reclock("SC6",.F.)
							SC6->C6_QTDORI  := C6_QTDVEN
							SC6->C6_QTDORI2 := C6_UNSVEN
							SC6->C6_QT1ORIC := C6_QTDVEN
							SC6->C6_QT2ORIC := C6_UNSVEN
							SC6->C6_QTDVEN  := _aP1[_n1][nPCxAju] * _nPes
							SC6->C6_UNSVEN  := _aP1[_n1][nPCxAju]
							SC6->C6_QTDLIB  := 0
							SC6->C6_QTDLIB2 := 0
							SC6->C6_VALOR   := (_aP1[_n1][nPCxAju] * _nPes) * C6_PRCVEN
							SC6->C6_QTDEMP  := 0
							SC6->C6_QTDEMP2 := 0
							SC6->C6_LOGCORT := UPPER(Alltrim(cUserName))+DTOC(date())+TIME()+_cLogmin 
							SC6->(Msunlock())

							//grava log na tabela szb dos itens cortados
							u_GrLogZBE (Date(),TIME(),cUserName,"CORTE DE PEDIDO ","COMERCIAL","TELACORTE",;
							"PEDIDO+PRODUTO: "+_aP1[_n1][nPosPed]+" "+_cProduto,ComputerName(),LogUserName())  

							//INICIO ticket  8      - Abel Babini - 19/02/2021 - Processar a pré liberação no momento do corte
							dbSelectArea("SA1")
							SA1->(dbSetOrder(1))
							SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJACLI))

							DbSelectArea("SA3")
							SA3->(DbSetOrder(1))
							SA3->(DbSeek(FWxFilial("SA3")+SC5->C5_VEND1))

							//StaticCall(M410STTS,fPreLibF)
							//Ticket  8      - Abel B.  - 01/03/2021 - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
							StaticCall(M410STTS,fLibCred, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR)
							
							//FIM ticket  8      - Abel Babini - 19/02/2021 - Processar a pré liberação no momento do corte

						ENDIF

						IF _lDelSC9   &&gero novamente SC9(liberação), com novos valores da SC6, caso este tenha sido deletado acima(somente se ja existia)
							dbSelectArea("SC5")
							dbSetOrder(1)
							dbgotop()
							dbSeek(xFilial("SC5")+_aP1[_n1][nPosPed])
							/* função MALIBDOFAT abaixo ja deve fazer isso...
							RecLock("SC5",.F.)
							SC5->C5_LIBEROK := "S"
							SC5->(MsUnlock())
							*/

							dbSelectArea("SC6")
							dbSetOrder(1)
							dbGotop()
							If dbSeek(xFilial("SC6")+_aP1[_n1][nPosPed])
								While SC6->(!Eof()) .And. _aP1[_n1][nPosPed] == SC6->C6_NUM
									_nQtdLiber := SC6->C6_QTDVEN
									RecLock("SC6")
									// Efetua a liberação item a item de cada pedido
									//Begin transaction
									MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
									//End transaction
									SC6->(MsUnLock())

									Begin Transaction
										SC6->(MaLiberOk({_aP1[_n1][nPosPed]},.F.))
									End Transaction
									SC6->(dbSkip())
								EndDo
							EndIf

							DbSelectArea("SC9") &&gravo a data de entrega e vendedor(carteira) para os pedidos liberados
							dbSetOrder(1)
							if dbseek(xFilial("SC9")+_aP1[_n1][nPosPed])
								While SC9->(!Eof()) .And. _aP1[_n1][nPosPed] == SC9->C9_PEDIDO
									RecLock("SC9",.F.)
									SC9->C9_DTENTR := SC5->C5_DTENTR
									SC9->C9_VEND1  := SC5->C5_VEND1
									SC9->(MsUnlock())
									SC9->(dbSkip())
								EndDo
							Endif
						Endif

						&&Alias só vou poder recalcular IPTAB para varejo(recalculo, não avalio mais bloqueio) pois REDE os calculos vem do ANALISPED e quando este
						&&eh rodado não posso mais mexer....

						AJSPESOS(_aP1[_n1][nPosPed])    &&rotina vinda da função ADCORTE original para corte manuais....

						&&Somente recalculo IPTAB de varejo ja que REDE os calculos são feitos na analise e se ja analisado não pode ser recalculado...
						_lVar    := .F.
						_lRede   := .F.
						_lRecalc := .F.
						DbSelectArea("SC5")
						DbSetOrder(1)
						Dbgotop()
						if dbseek(xFilial("SC5")+_aP1[_n1][nPosPed])
							&&Verifico se trata-se de pedido REDE ou Varejo
							&&para pedidos de Rede não ha o que fazer, pois os calculos de IPTAB sã feitos na analise(ANALISPED) e se ja foi feita não posso alterar...
							&&Para pedidos Varejo, só mudo os valores, não efetuo novamente BLOQUEIO ou Não do pedido....
							IF SC5->C5_XREDE == 'S' .And. !Empty(SC5->C5_CODRED)    &&Pedido Rede
								_lRede := .T.
							Elseif SC5->C5_XREDE == 'N'
								_lVar  := .T.
							Endif

							&&Havendo aptidão para recalculo, refaço estes com os novos dados dos pedidos cortados.....Não estar apto não é impedimento ao corte,
							&&apenas impede recalculo de iptabs...

							If _lVar    &&recalculo permitido eh somente para varejo
								_lLoja := .T.
								&&daqui para baixo tratamento vindo do M410STTS...
								&&Mauricio 09/08/11 - Incluido tratamento para recalculo do peso liquido e bruto tambem na alteração.

								&&Mauricio - 14/12/16 - tratamento redundante com relação ao ajuste de peso ja contemplado na funcao
								&&chamada acima AJSPESOS()
								/*
								dbSelectArea("SC6")
								dbSetorder(1)
								DbGotop()
								If dbSeek(xFilial("SC6")+_aP1[_n1][nPosPed] )

								While SC6->(!Eof()) .And. SC6->C6_NUM == _aP1[_n1][nPosPed]

								_nTotalPedi += SC6->C6_VALOR
								_nTotalCx   += SC6->C6_UNSVEN   // Soma qtd caixas (2a. UM)
								//								_nTotalKg   += SC6->C6_QTDVEN   // Soma qtd peso   (1a. UM)  
								_nTotalKg   += iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   (1a. UM)  //alterado por Adriana, se bolsa nao soma 1a unidade como peso

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona Cadastro de Tara ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SZC")
								dbSetOrder(1)
								If dbSeek(xFilial("SZC") + SC6->C6_SEGUM)
								_nTotalBr += (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
								Else
								_nTotalBr += (SC6->C6_UNSVEN  * 1) // PESO BRUTO
								EndIf

								dbSelectArea("SC6")
								SC6->(dbSkip())

								EndDo

								EndIf
								*/
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava Informacoes em SC5 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SC5")
								DbSetOrder(1)
								DbGotop()
								if dbseek(xFilial("SC5")+_aP1[_n1][nPosPed])
									_cTpFret  := SC5->C5_TPFRETE
									/*  Mauricio - 14/12/16
									RecLock("SC5",.F.)
									// Mauricio 26/04/10 - incluido tratamento para peso duplicado fiiais 03/04/05.
									SC5->C5_PBRUTO  := If(SC5->C5_PBRUTO  == 0,_nTotalBr + If(!(xFilial("SC5")$'03/04/05'),_nTotalKg, 0),SC5->C5_PBRUTO)   //Incluida condicao em 24/06/2008 pois em SC estava duplicando o peso
									SC5->C5_PESOL   := If(SC5->C5_PESOL   == 0,_nTotalKg,SC5->C5_PESOL)
									SC5->C5_VOLUME1 := If(SC5->C5_VOLUME1 == 0,_nTotalCx,SC5->C5_VOLUME1)
									SC5->(MsUnlock())
									*/
									dbSelectArea("SA1")
									dbSetOrder(1)
									If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

										_cRepresent := SA1->A1_VEND
										_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprovação
										_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
										_cGerent    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_GEREN")        // gerente para aprovação
										_cGerente   := Posicione("SA3",1,xFilial("SA3")+_cGerent,"A3_CODUSR")
										_cDireto    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_XDIRET")       // diretor para aprovação
										_cDiretor   := Posicione("SA3",1,xFilial("SA3")+_cDireto,"A3_CODUSR")

										DbSelectArea("SA3")
										dbSetOrder(1)
										dbSeek(xFilial("SA3")+_cRepresent)   &&preciso posicionar no representante do cliente nao no usuario que esta incluindo.

									EndIf

									If _lLoja
										// Busco desconto para Cliente. O desconto aqui informado é em PERCENTUAL - PAULO - TDS - 12/05/2011
										_nDesconto := SA1->A1_DESC

										// Busco frete para Cliente
										_cEst	:= SA1->A1_EST
										_cMunic  := SA1->A1_COD_MUN
										_cRegiao := ""
										_cTabela := ""   //M->C5_TABELA
										IF _cTpFret == "C"    &&Mauricio 21/12/11 - tratamento para valor de frete CIF ou outro.
											// Localizo o municipio do cliente, se este for loja
											If !Empty(_cMunic)
												_cRegiao:= Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA") // Localizo a regiao do cliente
											EndIf

											If !Empty(_cRegiao)
												_nFrete := Posicione('ZZI',1,xFilial("ZZI")+_cRegiao,"ZZI_VALOR")         // Valor do frete para a região
											Else
												dbSelectArea("ZZI")                                                       // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
												dbSetOrder(3)
												dbSeek(xFilial("ZZI")+_cEst)

												While ZZI->(!Eof()) .And. ZZI->ZZI_ESTADO == _cEst

													If _nFrete < ZZI->ZZI_VALOR
														_nFrete := ZZI->ZZI_VALOR
													EndIf

													ZZI->(dbSkip())

												EndDo
											EndIf
										Else
											_nFrete := 0
										Endif

										dbSelectArea("ZZP")
										dbSetOrder(1)
										dbGoTop()

										While ZZP->(!Eof())
											If _nTotalCx >= ZZP->ZZP_PESOI .And. _nTotalCx <= ZZP->ZZP_PESOF
												&&pega a tabela que se encaixa na faixa
												_cTabela := ZZP->ZZP_TABELA
												Exit
											EndIf
											ZZP->(dbSkip())
										EndDo

										&&Mauricio - 07/12/11 - tratamento para caso não haver tabela cadastrada ou faixa de peso

										If Empty(_cTabela)
											return()
										Else
											&&atualizo campo tabela no SC5
											reclock("SC5",.F.)
											SC5->C5_TABELA := _cTabela
											SC5->(Msunlock())
										Endif

										dbSelectArea("DA0")
										dbSetOrder(1)

										If dbSeek(xFilial("DA0")+_cTabela)

											// Condição para achar percentual baseado em um unico usuario(ou vendedor ou supervisor ou gerente ou diretor)
											If     SA3->A3_NIVETAB == "2" // supervisor
												_nValMax := 1-(DA0->DA0_XSUPER/100)         // percentual supervisor
											ElseIf SA3->A3_NIVETAB == "3" // Gerente
												_nValMax := 1-(DA0->DA0_XGEREN/100)         // percentual gerente
											ElseIf SA3->A3_NIVETAB == "4"
												_nValMax := 1-(DA0->DA0_XDIRET/100)         // percentual diretor
											Else
												_nValMax := 1-(DA0->DA0_XVENDE/100)		 // percentual vendedor
											EndIf

											// Condição para achar um percentual para cada usuario sempre(vendedor,supervisor,gerente, diretor)
											// Destinado a geracao de alçada separadamente.(Mauricio 11/05/11.)
											_nValMaxV := 1-(DA0->DA0_XVENDE/100)
											_nValMaxS := 1-(DA0->DA0_XSUPER/100)
											_nValMaxG := 1-(DA0->DA0_XGEREN/100)
											_nValMaxD := 1-(DA0->DA0_XDIRET/100)

										EndIf

										_nPrDigT  := 0
										_nPrPerT  := 0
										_nPrTabT  := 0
										_nPrPerTV := 0
										_nPrPerTS := 0
										_nPrPerTG := 0
										_nPrPerTD := 0
										_nPreTabS := 0
										_nPreLiqS := 0
										_nValorNf := 0

										dbSelectArea("SC6")
										dbSetOrder(1)
										dbGotop()
										If dbSeek(xFilial("SC6")+_aP1[_n1][nPosPed])

											While SC6->(!Eof()) .And. SC6->C6_NUM == _aP1[_n1][nPosPed]

												_nPrcDig := SC6->C6_PRCVEN * (_nDesconto / 100) // Preço digitado no produto, incluído o desconto
												_nPrDigL := SC6->C6_PRCVEN - _nPrcDig - _nFrete // Preco digitado no pedido menos o desconto e frete
												_nVlTotD := SC6->C6_QTDVEN * _nPrDigL

												dbSelectArea("DA1")
												dbSetOrder(1)
												If dbSeek(xFilial("DA1")+_cTabela+SC6->C6_PRODUTO)
													_nPrcTab := DA1->DA1_XPRLIQ									// Preco da tabela de precos
													_nPrPerm := _nPrcTab * _nValMax 	                        // Preco minimo permitido para o usuario

													// Preco minimo permitido para todas as alçadas.(tera de verificar todas as alçadas de uma unica vez conforme Alex - 11/05/11.)
													_nPrPermV := _nPrcTab * _nValMaxV
													_nPrPermS := _nPrcTab * _nValMaxS
													_nPrPermG := _nPrcTab * _nValMaxG
													_nPrPermD := _nPrcTab * _nValMaxD

													_nVlTotT  := SC6->C6_QTDVEN * _nPrPerm
													_nVlTotT2 := SC6->C6_QTDVEN * _nPrcTab  &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.

													_nVlTotTV := SC6->C6_QTDVEN * _nPrPermV
													_nVlTotTS := SC6->C6_QTDVEN * _nPrPermS
													_nVlTotTG := SC6->C6_QTDVEN * _nPrPermG
													_nVlTotTD := SC6->C6_QTDVEN * _nPrPermD

													//_nIpProd := _nVlTotD/_nVlTotT
													_nIpProd := _nVlTotD/_nVlTotT2      &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.

													&&Mauricio 10/08/11 - implementando sistematica de alteraçoes solicitadas em 10/08/11 - email Sr. Alex.
													_nPBTTV  := SC6->C6_PRCVEN    &&preco digitado
													_nPLTTV  := _nPrDigL          &&preco liquido
													_nPLTVD  := _nPrPermV         &&preco minimo vendedor
													_nPLTSV  := _nPrPermS  &&preco minimo supervisor

													dbSelectArea("SC6")
													RecLock("SC6",.F.)
													SC6->C6_XIPTAB := Round(_nIpProd,3)
													SC6->C6_TOTDIG := _nVlTotD
													SC6->C6_TOTTAB := _nVlTotT2 //_nVlTotT &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.
													SC6->C6_PRTABV := _nPrPerm + _nFrete && Mauricio 26/07/11 - Solicitacao Vagner incluir preco tabela vendedor(tabela - Margem + frete)
													SC6->C6_PBTTV  := _nPBTTV
													SC6->C6_PLTTV  := _nPLTTV
													SC6->C6_PLTVD  := _nPLTVD
													SC6->C6_PLTSP  := _nPLTSV
													SC6->C6_PLTAB  := _nPrcTab
													MsUnLock()

													_nPrDigT  += _nVlTotD	 // Soma dos preços líquidos digitados
													_nPrPerT  += _nVlTotT    // Soma dos preços das tabelas
													_nPrTabT  += _nVlTotT2   &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.
													_nPrPerTV += _nVltotTV   // Soma preço das tabelas para alçada
													_nPrPerTS += _nVltotTS
													_nPrPerTG += _nVltotTG
													_nPrPerTD += _nVltotTD

													_nPreTabS += (_nPrcTab * SC6->C6_QTDVEN)   &&Soma dos precos de tabela para gravar no SC5 Valor Desconto. Pelo total e não unitario conf. Sr. Alex
													_nPreLiqS += (_nPrDigL * SC6->C6_QTDVEN)   &&Soma dos precos liquidos para gravar no SC5 Valor Desconto.  Pelo total e não unitario conf. Sr. Alex
													_nValorNf += SC6->C6_VALOR
												EndIf

												dbSelectArea("SC6")
												SC6->(dbSkip())
											EndDo

											//_nVlIP := _nPrDigT/_nPrPerT
											_nVlIP := _nPrDigT/_nPrTabT    &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.
											_nVlIP := NoRound(_nVlIP,3)

											//_nIpTot := _nPrDigT/_nPrPerT

											RecLock("SC5",.F.)
											SC5->C5_FRETAPV := _nFrete   &&Mauricio 16/11/11.
											SC5->C5_XIPTAB := _nVlIP
											SC5->C5_TOTDIG := _nPrDigT
											SC5->C5_TOTTAB := _nPrTabT   //_nPrPerT &&Alterado em 28/09/11 conforme informações Sr. Alex no que se refere ao valor do IPTAB.
											SC5->C5_DESCTBP := _nPreTabS - _nPreLiqS
											SC5->C5_VALORNF := _nValorNF
											SC5->(MsUnLock())
										EndIf

									EndIf
								Endif
							Endif
						ENDIF
					Endif
				End Transaction
				//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(_nTpedcx,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(_nTpedvl,"@E 999,999,999.99"),.F.})
			Else
				//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
			Endif
			//End Transaction
		Next _n1


		oCabD4 :=MsNewGetDados():New( 060,007,350,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,300,600
		oCabD4:oBrowse:Refresh()
		oCabD4:GoBottom()
		oCabD4:GoTop()
		oCabD4:Refresh(.T.)
		oDlg:Refresh()
		GetdRefresh()
		SysRefresh()
		MsgInfo("Corte concluido")
		CLOSE(O_DIALOG)
	Endif

Return()

Static function fCalc()
	nPosOrd  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Ordem"})
	nPosSup  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Supervisor"})
	nPosCli  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cliente"})
	nPosLoj  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Loja"})
	nPosRaz  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Razao Social"})
	nPosPed  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Pedido"})
	nPosIte  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Item"})
	nPosDta  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Data Entrega"})
	nPCxOri  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cxs Orig"})
	nPCxAju  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Cxs Ajust"})
	nPosPru  := Ascan(aHeaderT,{|x| Trim(x[1]) == "Preço"})
	nPTCxAj  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total Cxs Ajust"})
	nPTRsOr  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total R$ Orig"})
	nPTRsAj  :=	Ascan(aHeaderT,{|x| Trim(x[1]) == "Total R$ Ajust"})

	_aP1      := oCabD4:aCols
	_nTTCxFim := _nTTCxOri
	_nTTCxAju := 0000
	_aPedido := {}
	For _n1 := 1 To len(_aP1)
		If _aP1[_n1][nPCxAju] > _aP1[_n1][nPCxOri]
			MsgInfo("Permitido apenas ajuste de corte(a menor). Item(ordem) "+_aP1[_n1][nPosOrd]+" ajuste a maior!","Atenção")
			AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
			loop
		Endif
		&&verificado com Vagner e corte para quantidade Zero é procedimento comum..retirado 04/09/13
		/*
		If _aP1[_n1][nPCxAju] == 0
		MsgInfo("Não é permitido corte de ZERO em quantidade de ajuste. Item(ordem) "+_aP1[_n1][nPosOrd]+" .","Atenção")
		AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
		loop
		Endif
		*/
		&&valido a quantidade original, preço, pedido e item pedido com o pedido de venda original para ter certeza que somente a coluna de ajuste
		&&tenha sido alterada.
		DbSelectArea("SC6")
		DbSetOrder(1)
		if dbseek(xfilial("SC6")+_aP1[_n1][nPosPed]+_aP1[_n1][nPosIte]+_cProduto)
			&&valido data de entrega, qtd original e preco (original do pedido) se permanecem inalterados
			If (SC6->C6_ENTREG <> CTOD(_aP1[_n1][nPosDta])) .Or. (VAL(STRTRAN(_aP1[_n1][nPosPru],",",".")) <> SC6->C6_PRCVEN) .Or. (_aP1[_n1][nPCxOri] <> SC6->C6_UNSVEN)
				MsgInfo("Inconsistencia nos dados dos campos item/ordem "+_aP1[_n1][nPosOrd]+".Entrega/preco/caixas orig. diferentes do PV!!!!","Atenção")
				AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
			Endif
		Else &&inconsistencia
			MsgInfo("Inconsistencia nos dados dos campos item/ordem "+_aP1[_n1][nPosOrd]+".Pedido/item/produto não encontrado!!!!","Atenção")
			AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
			loop
		Endif
		If _aP1[_n1][nPCxOri] <> _aP1[_n1][nPCxAju]  &&sendo diferente houve ajuste e é necessário recalculo......
			_nTTCxFim -= (_aP1[_n1][nPCxOri] - _aP1[_n1][nPCxAju])
			_nTTCxAju += (_aP1[_n1][nPCxOri] - _aP1[_n1][nPCxAju])
			_nTpedcx  := 0
			_nTpedvl  := 0
			&&preciso apurar total em caixas e valor do pedido ajustado para mostrar em tela...
			DbSelectArea("SC6")
			DbSetOrder(1)
			Dbgotop()
			if dbseek(xFilial("SC6")+_aP1[_n1][nPosPed])
				While SC6->(!Eof()) .And. SC6->C6_NUM == _aP1[_n1][nPosPed]
					If SC6->C6_ITEM == _aP1[_n1][nPosIte] .And. SC6->C6_PRODUTO == _cProduto
						_nTpedcx +=_aP1[_n1][nPCxAju]
						_nPesoCx := SC6->C6_QTDVEN / SC6->C6_UNSVEN
						_nTpedvl += SC6->C6_PRCVEN * (_aP1[_n1][nPCxAju] * _nPesoCx) &&recalculo do valor total do item ajustado
					Else
						_nTpedcx += SC6->C6_UNSVEN
						_nTpedvl += SC6->C6_VALOR
					Endif
					SC6->(dbskip())
				Enddo
			Else  &&teoricamente esta parte abaixo nunca deve ocorrer, mas.....
				MsgInfo("Pedido de venda "+_aP1[_n1][nPosPed]+" não encontrado.!!!!","Atenção")
				AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
				loop
			Endif
			&&Valido novo valor ajustado de total de pedido com parametro de valor minimo ZZ_LIMITPV
			/*
			_nVLMIN := GETMV("ZZ_LIMITPV")
			if _nTpedvl < _nVLMIN
			MsgInfo("Pedido de venda "+_aP1[_n1][nPosPed]+" com Valor ajustado abaixo do minimo!!!!","Atenção")
			Endif
			&&Mauricio - 22/04/15 - novo tratamento relativo ao valor minimo do pedido por faixa/vendedor. O tratamento acima não ira mais funcionar(mas foi mantido) pois no parametro foi colocado ZERO como valor minimo.
			dbSelectArea("SC5")
			dbSetOrder(1)
			If dbSeek(xFilial("SC5")+_aP1[_n1][nPosPed])
			_cVDPED := SC5->C5_VEND1

			DbSelectArea("SA3")
			DbSetOrder(1)
			if dbseek(xFilial("SA3")+_cVDPED)
			_cFaixa := SA3->A3_FXPDMIN
			IF empty(_cFaixa)
			ApMsgInfo(OemToAnsi("Atencao !! Vendedor no pedido "+_aP1[_n1][nPosPed]+", sem faixa valor minimo alocada em seu cadastro.!"))					  
			Else
			_nValmin := VAL(Posicione("SX5",1,"02"+"A#"+_cFaixa,"X5_DESCRI"))
			If _nTpedvl < _nValmin
			MsgInfo("Pedido de venda "+_aP1[_n1][nPosPed]+" com Valor ajustado abaixo do minimo!!!!","Atenção")					     
			EndIf				   
			Endif  
			endif
			Endif
			*/
			&&Chamado 032142 - Alterado todo o tratamento de pedido minimo para enxergar valor minimo por supervisor somente
			&&Demais usuarios não sera necessaria validação segundo sr. Vagner(vendedores nao acessam rotina e gerentes podem alterar).
			dbSelectArea("SA3")
			dbSetOrder(7)
			If dbSeek( xFilial("SA3")+_cCodUs )
				&&conforme informação do Sr. Vagner somente supervisor sofre validacao, ja que vendedor nao acessa a rotina e gerente/diretor nao tem restrição de corte de valor
				If SA3->A3_NIVETAB == "2"  &&Eh supervisor
					_nValmin := SA3->A3_VLPDMIN
					If _nTpedvl < _nValmin		        
						MsgInfo("O Pedido de venda "+_aP1[_n1][nPosPed]+" ficou com valor abaixo de R$ "+Transform(_nValmin,"@E 9,999,999.99")+" e o mesmo não sofrera alteração/corte!!!!","Atenção")					 				         
					EndIf			   
				Endif
			Else
				MsgInfo("Seu usuario nao tem cadastro na tabela de vendedores, assim o pedido "+_aP1[_n1][nPosPed]+" não sofrera alteração/corte!!!!","Atenção")					     					     			   			 
			Endif	

			&&alimento novo array recalculado para ser apresentado...
			&&mauricio..preciso utilizar STRZERO com tamanho de len(_aP1[_n1][nPCxOri]), ou seja se caixa origina tem 2 digitos, caixa ajustada deve ter dois (08 por exemplo).Efetuado, testar.
			&&Mauricio - corrigir - STRZERO nao serve pois converte para caracter..vou deixar assim e no final preciso ver o que melhor de ser feito para o problema....
			_nLen := Len(Alltrim(STR(_aP1[_n1][nPCxOri])))
			//AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(_nTpedcx,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(_nTpedvl,"@E 999,999,999.99"),.F.})
			AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform((_aP1[_n1][nPCxOri] - _aP1[_n1][nPCxAju]) ,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(_nTpedvl,"@E 999,999,999.99"),.F.})
		Else
			AADD(_aPedido,{_aP1[_n1][nPosOrd],_aP1[_n1][nPosSup],_aP1[_n1][nPosCli],_aP1[_n1][nPosLoj],_aP1[_n1][nPosRaz],_aP1[_n1][nPosPed],_aP1[_n1][nPosIte],_aP1[_n1][nPosDta],_aP1[_n1][nPCxOri],_aP1[_n1][nPCxAju],_aP1[_n1][nPosPru],Transform(0,"@E 999,999.9999"),_aP1[_n1][nPTRsOr],Transform(0,"@E 999,999.9999"),.F.})
		Endif
	Next _n1
	oCabD4 :=MsNewGetDados():New( 060,007,350,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,300,600
	oCabD4:oBrowse:Refresh()
	oCabD4:GoBottom()
	oCabD4:GoTop()
	oCabD4:Refresh(.T.)
	oDlg:Refresh()
	GetdRefresh()
	SysRefresh()

Return()


static function fDesc(_cPD)

	_cDescri := Posicione("SB1",1,xFilial("SB1")+_cPD,"B1_DESC")

	oDlg:Refresh()

Return(Alltrim(_cDescri))

Static Function AJSPESOS(_cPedi)
	&&rotina vinda da user function ADCORTE() utilizada no corte manual praticado anteriormente....

	Local _nVlCA 	:= 0
	Local _nVlTK 	:= 0
	Local _nVlTC 	:= 0

	Local _cTipVei	:= ""
	Local _cCodCid := ""
	Local _cCidade := ""
	Local _cTipoFrt:= ""
	Local _cAtuaSC5:= ""

	//_nTotalCx:= 0
	//_nTotalKg:= 0
	//_nTotalBr:= 0

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + _cPedi)

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9") + _cPedi)

	_nTotalCx:= 0
	_nTotalKg:= 0
	_nTotalBr:= 0

	if SC9->( !eof() ) .and. SC9->C9_PEDIDO == _cPedi .and. !Empty(_cPedi) //Incluida esta condicao para nao zerar o peso de pedidos que nao tem SC9
		_nTotalCx:= 0
		_nTotalKg:= 0
		_nTotalBr:= 0

		//Do while .not. eof() .and. SC9->C9_PEDIDO == SC5->C5_NUM
		While SC9->( !eof() ) .and. xFilial("SC9")==SC9->C9_FILIAL .And. SC9->C9_PEDIDO == _cPedi  // Marcelo Vicente - 20100619

			IF  EMPTY(SC9->C9_BLCRED)

				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1") + SC9->C9_PRODUTO)

				_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2         // Soma qtd caixas (2a. UM)
				//			_nTotalKg   := _nTotalKg   + SC9->C9_QTDLIB          // Soma qtd peso   <1a. UM)
				_nTotalKg   := _nTotalKg   + iif(SB1->B1_SEGUM="BS",0,SC9->C9_QTDLIB)          // Soma qtd peso   <1a. UM)  //alterado por Adriana, se bolsa nao soma 1a unidade como peso
				dbSelectAreA('SZC')
				dbSetOrder(1)
				dbSeek( xFilial('SZC') + SB1->B1_SEGUM)

				If Found()
					_nTotalBr   := _nTotalBr + ( SC9->C9_QTDLIB2  * SZC->ZC_TARA )  // PESO BRUTO
				Else
					If Alltrim(SB1->B1_SEGUM) <> ""                                 //Incluido 13/07/11 - Ana. Tratamento para peso duplicado
						_nTotalBr   := _nTotalBr + ( SC9->C9_QTDLIB   * 1 )         // PESO BRUTO
					Else
						_nTotalBr   := _nTotalBr                                    // PESO BRUTO
					Endif
				EndIf

				dbSelectArea("SC9")
				//dbSetOrder(1)
				Reclock("SC9",.F.)
				Replace C9_ROTEIRO With SC5->C5_ROTEIRO
				Replace C9_DTENTR  with SC5->C5_DTENTR
				Replace C9_VEND1   with SC5->C5_VEND1
				Msunlock()

			endif

			SC9->( dbskip() )

		Enddo
	Endif

	if _nTotalkg = 0 //se o peso estiver zerado recalcula - Incluido por Adriana em 30/12/2014
		_cQuery  := "SELECT SUM(C6_UNSVEN*ZC_TARA) PBRUTO, SUM(C6_QTDVEN) PLIQUI, SUM(C6_UNSVEN) CX "
		_cQuery  += "FROM "+RetSqlName("SC6") +" "
		_cQuery  += "INNER JOIN "+RetSqlName("SZC")+ " ON ZC_UNIDADE = C6_SEGUM AND "+RetSqlName("SZC")+ ".D_E_L_E_T_ = '' "
		_cQuery  += "WHERE C6_FILIAL = '"+cfilAnt+"' AND C6_NUM = '"+_cPedi+"' AND "+RetSqlName("SC6")+ ".D_E_L_E_T_ = '' "
		_cQuery  += "GROUP BY C6_FILIAL, C6_NUM "

		TCQUERY _cQuery NEW ALIAS "_PESO"

		DbSelectArea("_PESO")
		DbGoTop()

		_nTotalBr   := _PESO->PBRUTO
		_nTotalkg   := _PESO->PLIQUI
		_nTotalCx   := _PESO->CX     

		DbClosearea()
	Endif

	RecLock("SC5",.F.)  
	If cEmpAnt == "02"
		SC5->C5_PBRUTO  := _nTotalBr
	Else
		SC5->C5_PBRUTO  := _nTotalBr + _nTotalkg
	Endif
	SC5->C5_PESOL   := _nTotalKg
	SC5->C5_VOLUME1 := _nTotalCx
	//SC5->C5_LIBEROK := "S"
	MsUnlock()

	// GRAVA ARQUIVO DE CONTROLE DE FRETE (SZK)

	dbSelectArea("SZK")
	dbSetOrder(4)

	if dbSeek(xFilial("SZK") + dtos(SC5->C5_DTENTR) + SC5->C5_PLACA + SC5->C5_ROTEIRO)

		dbSelectArea("ZV4")
		dbSetOrder(1) // Indice Placa
		if dBseek(xfilial("ZV4")+ SC5->C5_PLACA)
			_cTipVei := ZV4_TIPVEI
		ENDIF

		dbSelectArea("ZV8")
		dbSetOrder(2) // Indice Destino
		if dBseek(xfilial("ZV8")+ SZK->ZK_DESTINO)
			_cCodCid := ZV8_COD
			_cCidade := ZV8_CIDADE
		Endif

		dbSelectArea("ZV9")
		dbSetOrder(2) // Indice Codigo EX: SP01
		If dBseek(xfilial("ZV9")+ _cCodCid)
			//Do While !EOF() .and. ZV9_REGIAO = _cCodCid     // Marcelo Vicente - 20100619
			Do While ZV9->( !EOF() ) .and. ZV9_REGIAO = _cCodCid
				If ZV9_DTVAL <= DDATABASE
					_nVlCA := ZV9_VLTON
					_nVlTK := ZV9_VLTK
					_nVlTC := ZV9_VLTC
				Endif
				ZV9->( DbSkip() )
			Enddo
		Endif

		//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
		u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","TELACORTE",;
		"Filial: "+xFilial("SZK")+" Data: "+DTOS(SC5->C5_DTENTR)+" Placa: "+SC5->C5_PLACA+" Roteiro: "+SC5->C5_ROTEIRO,ComputerName(),LogUserName())

		Reclock("SZK",.F.)
		SZK->ZK_PESOL 		:= SC5->C5_PESOL
		SZK->ZK_PESFATL 	:= SC5->C5_PESOL
		SZK->ZK_PBRUTO		:= SC5->C5_PBRUTO
		SZK->ZK_PESFATB     := SC5->C5_PBRUTO

		If _cTipoFrt $ GETMV('MV_FRTLGN') //'A7' .OR. _cTipoFrt = 'A4' // Verifica se for L.Percurso A7 ou Tranferencia A4
			If _cTipVei = 'CA' // Se for CARRETA
				ZK_VALFRET:= 		 (_nVlCA/1000)* SC5->C5_PBRUTO
			Else
				If _cTipVei = 'TK' // Se for TRUCK
					ZK_VALFRET := 		 (_nVlTK/1000)* SC5->C5_PBRUTO
				Else
					If _cTipVei = 'TC' // Se for TOCO
						ZK_VALFRET:= (_nVlTC/1000)* SC5->C5_PBRUTO
					Endif
				Endif
			Endif
		Endif

		MsUnlock()

		dbSelectArea("ZV2")
		dbSetOrder(5)   // ZV2_DTENTR + ZV2_ROTEIR + ZV2_PLACA
		if dbSeek(xFilial("ZV2") + dtos(SC5->C5_DTENTR) + SC5->C5_PLACA + SC5->C5_ROTEIRO)
			Reclock("ZV2")
			//ZV2->ZV2_PFATU := SC5_C5_PESOL   // Marcelo Vicente - 20100619
			ZV2->ZV2_PFATU := SC5->C5_PESOL
			MsUnlock()
		endif

	ELSE

		//grava log chamado 041202 - WILLIAM COSTA 23/04/2018	
		u_GrLogZBE (Date(),TIME(),cUserName," ELSE RecLock(SZK,.F.)","LOGISTICA","TELACORTE",;
		"Filial: "+xFilial("SZK")+" Data: "+DTOS(SC5->C5_DTENTR)+" Placa: "+SC5->C5_PLACA+" Roteiro: "+SC5->C5_ROTEIRO,ComputerName(),LogUserName())

	endif

Return() 

&&21/10/16 - funcao para pre aprovacao.
Static function fPreAprv(_cFilial,cPedido,_cCliente,_cLoja) 
	DbSelectArea("SC5")
	_cASC5 := Alias()
	_cOSC5 := IndexOrd()
	_cRSC5 := Recno()

	&&Verifico se eh rede ou varejo...
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+_cCliente+_cLoja)
		dbSelectArea("SZF")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))  //&&REDE
			//Limpo flag de pedidos relativos a Rede....aonde no caso não ha como filtrar data de entrega, cliente e pedidos utilizados...limpo todos.

			If Select("LSC5") > 0
				DbSelectArea("LSC5")
				DbCloseArea("LSC5")
			Endif

			_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
			_cQuery += " WHERE  C5_NOTA = ''  AND C5_CLIENTE NOT IN ('031017','030545') "
			_cQuery += " AND C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA"
			_cQuery += " AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' AND LEFT(A1_CGC,8) = ZF_CGCMAT "      
			_cQuery += " AND C5.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' "

			TCQUERY _cQuery new alias "LSC5"	

			DbSelectArea ("LSC5")
			LSC5->(dbgotop())
			Do While LSC5->(!EOF())
				DbSelectArea("SC5")
				DbSetOrder(1)
				If dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM)
					if Reclock("SC5",.F.)
						SC5->C5_XPREAPR := " "
						SC5->(Msunlock())
					endif
				Endif	         
				LSC5->(DbSkip())
			Enddo

			DbcloseArea("LSC5")

		Else  &&eh varejo
			if Reclock("SC5",.F.)
				SC5->C5_XPREAPR := " "
				SC5->(Msunlock())
			endif   
		Endif
	Endif

	dbSelectArea(_cASC5)
	dbSetOrder(_cOSC5)
	dbGoto(_cRSC5)

Return() 
