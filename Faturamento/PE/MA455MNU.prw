#Include "Protheus.CH"

/*/{Protheus.doc} User Function MA455MNU
	(long_description)
	@type  Function
	@author ????
	@since ????
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado TI - Fernando Sigoli - 06/07/2017
	@historico chamado 056247 - FWNM     - 24/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@historico chamado 056247 - FWNM     - 21/07/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@historico chamado 18465  - Everson  - 28/03/2022 - Validação de pesagem.
/*/
User Function MA455MNU()

	If __cUserID $ GETMV("MV_#USUCOT") //Fernando Sigoli 06/07/2017

		aADD(aRotina,{"Corte Exp","U_Adcorte()"	, 0 , 0,0,NIL})		// "Legenda"

	EndIf

Return ( Nil )

/*/{Protheus.doc} User Function AdCorte
	Retorna de liberacao manual de estoque com alteracao da quantidade
	@type  Function
	@author Henry Fila
	@since 01/09/2003
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function AdCorte(cAlias,nReg,nOpcx)

	Local aArea     := GetArea()
	Local aSaldos   := {}
	Local aLib      := {.T.,.T.,.T.,.T.}
	Local dLimLib   := dDataBase
	Local cDescBloq := ""
	Local cMCusto   := ""
	Local nX        := 0
	Local nOpcA     := 0
	Local nQtdVen   := 0
	Local nCntFor   := 0
	Local nVlrCred  := 0
	Local nTpLiber  := 1
	Local nQtdAnt   := 0
	Local nQtdAnt2   := 0
	Local lContinua := .T.
	Local lSelLote  := GetNewPar("MV_SELLOTE","2") == "1"
	Local lHelp     := .T.
	Local nOptLib   := SuperGetMv("MV_OPLBEST",.F.,0)
	Local oDlg
	Local oRadio
	Local oBtn
	Local _nTotSC6  := 0  
	Local cTktStat	:= ""

	//- Status dos Bloqueios do pedido de venda. Se .T. DCF gerado, tem que estornar.
	Private lbloqDCF := !Empty(SC9->C9_BLCRED)

	Private nQtdNew1 := 00
	Private nQtdNew	 := 00
	Private oQtdNew1
	Private oQtdNew

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
	//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
	//| cliente, assim verificando a necessidade de uma atualizacao     |
	//| nestes fontes. NAO REMOVER !!!							              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V()   >= 20050512)
		Final("Atualizar SIGACUS.PRW !!!")
	Endif
	IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
		Final("Atualizar SIGACUSA.PRX !!!")
	Endif
	IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
		Final("Atualizar SIGACUSB.PRX !!!")
	Endif

	If SC9->C9_BLCRED == "10"
		HELP(" ",1,"A450NFISCA")
		lContinua:= .F.
	EndIf
	If !Empty(SC9->C9_BLCRED)
		If SC9->C9_BLCRED == "09"
			HELP(" ",1,"A455REJEIT")
		Else
			HELP(" ",1,"A455BLCRED")
		EndIf
		lContinua:= .F.
	EndIf
	If !Empty(SC9->C9_BLCRED)
		Help(" ",1,"A455CREDIT")
		lContinua:= .F.
	EndIf
	/*
	If !SoftLock(xfilial("SC9"))
	lContinua:= .F.
	EndIf
	*/

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
		/*If !SoftLock("SC5")
		lContinua:= .F.
		EndIf
		*/
	EndIf

	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) )
        lContinua := .f.
        msgAlert("Pedido possui adiantamento/boleto... Corte não permitido!", "[MA455MNU-01]")
    EndIf

	// chamado 056247 - FWNM     - 21/07/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	/*
	If lContinua
		If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM
			lContinua := .f.
			msgAlert("Pedido possui condição de pagamento de adiantamento... Corte não permitido!", "[MA455MNU-02]")
		EndIf
	EndIf
	*/
	//

	//Everson - 28/03/2022. Chamado 18465.
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
	If cEmpAnt = "01" .And. ! Empty(SC6->C6_XORDPES)
		cTktStat := Alltrim(cValToChar(Posicione("ZIG", 2, FWxFilial("ZIG") + SC6->C6_XORDPES, "ZIG_INICIA")))
		If cTktStat <> "3"
			lContinua := .f.
			MsgAlert("Pesagem pendente.", "[MA455MNU-02]")
		EndIf

	EndIf
	//

	If ( lContinua )
		dbSelectArea(cAlias)
		cMCusto := GetMV("mv_mcusto")

		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(cFilial+SC9->C9_PEDIDO)

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

		If SC5->C5_TIPO $ "DB"
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(cFilial+SC9->C9_PRODUTO)

		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(cFilial+SC6->C6_PRODUTO+SC6->C6_LOCAL)

		dbSelectArea("SM2")
		dbSetOrder(1)
		dbSeek(dDataBase,.T.)

		dbSelectArea(cAlias)
		If SC9->C9_BLEST == "02"
			cDescBloq := OemToAnsi("Estoque")
		EndIf
		DEFINE MSDIALOG oDlg FROM  177,001 TO 450,600 TITLE OemToAnsi("Corte Qtde Carregamento") PIXEL			//"Libera‡„o de Estoque"
		@ 005,011 TO 45, 295 LABEL "" OF oDlg  PIXEL
		@ 048,144 TO 90, 295 LABEL "" OF oDlg  PIXEL
		@ 048,011 TO 90, 138 LABEL "" OF oDlg  PIXEL
		//	@ 093,011 TO 133, 138 LABEL "" OF oDlg  PIXEL

		@ 122,146 BUTTON oBtn PROMPT OemToAnsi("Lote e Endereço") SIZE 64,11 ACTION (A455SelLote(@aSaldos,nQtdNew)) OF oDlg PIXEL WHEN (Rastro(SC9->C9_PRODUTO) .and. lSelLote) //"Lote e Enderecos"
		oBtn:cTooltip := OemToAnsi("Selecione os Lote e Endereçamento") //"Selecione os Lote e Endereçamento"

		//	DEFINE SBUTTON FROM 122,230 TYPE 1 ACTION ( Iif( U_Ad455Ok( oRadio:nOption, nQtdNew1, 00 ),Eval({||nOpca := 2,oDlg:End()}),)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 122,230 TYPE 1 ACTION ( Iif( U_Ad455Ok( 03, nQtdNew1, 00 ),Eval({||nOpca := 2,oDlg:End()}),)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 122,263 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		@ 012,015 SAY OemToAnsi("Pedido")                      SIZE 23, 7 OF oDlg PIXEL		//"Pedido"
		@ 012,044 SAY SC9->C9_PEDIDO                           SIZE 26, 7 OF oDlg PIXEL
		@ 012,108 SAY OemToAnsi("Cond.Pagto.")                 SIZE 38, 7 OF oDlg PIXEL		//"Cond.Pagto."
		@ 012,145 SAY SC5->C5_CONDPAG                          SIZE 17, 7 OF oDlg PIXEL
		@ 012,171 SAY OemToAnsi("Bloqueio")                    SIZE 27, 7 OF oDlg PIXEL		//"Bloqueio"
		@ 012,199 SAY SC9->C9_BLEST + " - " + cDescBloq        SIZE 87, 7 OF oDlg PIXEL
		@ 023,015 SAY OemToAnsi("Cliente")                     SIZE 23, 7 OF oDlg PIXEL		//"Cliente"
		@ 023,044 SAY IIf(SC5->C5_TIPO$"BD",Substr(SA2->A2_NOME,1,35),Substr(SA1->A1_NOME,1,35))	SIZE 114,7 OF oDlg PIXEL
		@ 023,171 SAY OemToAnsi("Risco")                       SIZE 21, 7 OF oDlg PIXEL		//"Risco"
		@ 023,199 SAY IIF(SC5->C5_TIPO$"BD",SA2->A2_RISCO,SA1->A1_RISCO) SIZE 7, 7 OF oDlg PIXEL
		@ 034,015 SAY OemToAnsi("Produto")                     SIZE 25, 7 OF oDlg PIXEL		//"Produto"
		@ 034,044 SAY Substr(SB1->B1_DESC,1,30)                SIZE 58, 7 OF oDlg PIXEL
		@ 034,171 SAY OemToAnsi("Saldo")                       SIZE 18, 7 OF oDlg PIXEL		//"Saldo"
		@ 034,146 SAY SC6->C6_Local                            SIZE 11, 7 OF oDlg PIXEL
		@ 034,109 SAY OemToAnsi("Almox.")                      SIZE 27, 7 OF oDlg PIXEL		//"Almox."
		@ 034,199 SAY SaldoSB2() Picture PesqPict("SB2","B2_QATU",14) SIZE 43, 7 OF oDlg PIXEL
		@ 056,016 SAY OemToAnsi("Numero Lote")                 SIZE 37, 7 OF oDlg PIXEL		//"N£mero Lote"
		@ 056,072 SAY SC6->C6_NUMLOTE                          SIZE 23, 7 OF oDlg PIXEL
		@ 056,151 SAY OemToAnsi("Localizacao")                 SIZE 38, 7 OF oDlg PIXEL		//"LOCALIZA‡„o"
		@ 056,203 SAY  SB2->B2_LOCALIZA                        SIZE 27, 7 OF oDlg PIXEL
		@ 067,016 SAY OemToAnsi("Qtd.Total Pedido")            SIZE 53, 7 OF oDlg PIXEL		//"Qtd.Total Pedido"
		@ 067,072 SAY SC6->C6_QTDVEN Picture PesqPictQt("C6_QTDVEN",10) SIZE 42, 7 OF oDlg PIXEL
		@ 067,110 SAY SB1->B1_UM           		       SIZE 27, 7 OF oDlg PIXEL
		// @ 067,151 SAY OemToAnsi("Data Ult.Saida")           SIZE 46, 7 OF oDlg PIXEL		//"Data Ult.Sa¡da"
		@ 067,151 SAY OemToAnsi("Qtd.na 1a.UM")                SIZE 46, 7 OF oDlg PIXEL		//"Qtd.neste Ötem"
		// @ 067,202 SAY RetFldProd(SB1->B1_COD,"B1_UCOM")     SIZE 33, 7 OF oDlg PIXEL
		@ 078,016 SAY OemToAnsi("Qtd.Total 2a.UM")             SIZE 50, 7 OF oDlg PIXEL		//"Qtd.Total 2a.UM"
		@ 078,072 SAY SC6->C6_UNSVEN Picture PesqPictQt("C6_UNSVEN",10)  SIZE 42, 7 OF oDlg PIXEL
		@ 078,110 SAY SB1->B1_SEGUM   			       SIZE 27, 7 OF oDlg PIXEL
		@ 078,151 SAY OemToAnsi("Qtd.na 2a.UM")                SIZE 46, 7 OF oDlg PIXEL	        //"Qtd.neste Ötem"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Get da nova quantidade                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdNew	 := SC9->C9_QTDLIB2
		nQtdNew1 := SC9->C9_QTDLIB

		//	@ 067, 199 MsGet oQtdNew1	Var nQtdNew1	Picture PesqPictQt( "C9_QTDLIB"	,10 )	Valid U_AD455Qtdl( nQtdNew1, 01 )	Size 53, 07 Of oDlg Pixel
		@ 067, 199 Say oQtdNew1     Var nQtdNew1    Picture PesqPictQt( "C9_QTDLIB"     ,10) 	size 53, 07 Of oDlg Pixel
		@ 067, 280 Say SB1->B1_UM		Size 27, 07 Of oDlg Pixel
		@ 076, 199 MsGet oQtdNew	Var nQtdNew		Picture PesqPictQt( "C9_QTDLIB2"	,10 )	Valid U_AD455Qtdl( nQtdNew, 02 )		Size 53, 07 Of oDlg Pixel
		@ 076, 280 Say SB1->B1_SEGUM	Size 27, 07 Of oDlg Pixel

		ACTIVATE MSDIALOG oDlg CENTERED
		If nOpcA == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa somente se a quantidade nova for diferente da original   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If (SC9->C9_QTDLIB <> nQtdNew1) .Or. lSelLote
				_CPED := SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO
				//ALERT("PEDIDO "+_CPED)
				iF NQTDNEW == 0
					Reclock("SC9",.F.)
					dbdelete()
					Msunlock()
				Else
					Reclock("SC9",.F.)
					//		         ALERT("ATUALIZA C9")
					Replace C9_QTDLIB    With nQtdNew1
					//		         ALERT("ATUALIZA UM")
					Replace C9_QTDLIB2   With nQtdNew
					//		         ALERT("ATUALIZA 2UM")
					Msunlock()
				Endif

				Begin Transaction
					nVlrCred := 0
					nQtdAnt  := SC9->C9_QTDLIB  - nQtdNew1
					nQtdAnt2 := SC9->C9_QTDLIB2 - nQtdNew

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna a liberacao atual                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//			SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Libera novamente de acordo com a opcao do radio selecionada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					*** ATUALIZA SC6 COM QTDADE IGUAL A LIBERADA NO CORTE
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbSeek(xfilial("SC6")+_CPED)

					iF Found()
						//ALERT("ACHOU CCHAVE")

						//iF NQTDNEW == 0
						//	
						//	Reclock("SC6",.F.)
						//	Replace C6_QTDORI   With C6_QTDVEN
						//	Replace C6_QTDORI2  With C6_UNSVEN
						//	Replace C6_UNSVEN   With 0
						//	Replace C6_QTDVEN   With 0
						//	Replace C6_UNSVEN   With 0
						//	Replace C6_QTDLIB   With 0
						//	Replace C6_QTDLIB2  With 0
						//	Replace C6_VALOR    With 0
						//	Replace C6_QTDEMP   With 0
						//	Replace C6_QTDEMP2  With 0
						//	Msunlock()
						If NQTDNEW == 0      //14/06/2017 Chamado: 036208 - Fernando Sigoli

							Reclock("SC6",.F.)
							dbdelete()
							Msunlock()

						ELSE 

							Reclock("SC6",.F.)
							Replace C6_QTDORI  With C6_QTDVEN
							Replace C6_QTDORI2 With C6_UNSVEN
							Replace C6_QTDVEN  With nQtdNew1
							Replace C6_UNSVEN  With nQtdNew
							Replace C6_QTDLIB  With nQtdNew1
							Replace C6_QTDLIB2 With nQtdNew
							Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
							Replace C6_QTDEMP   With nQtdNew1
							Replace C6_QTDEMP2  With nQtdNew
							Msunlock()
						ENDIF
					Endif

					//log _CPED
					//log da sc5
					u_GrLogZBE (Date(),TIME(),cUserName,"CORTE PEDIDO-EXPEDICAO (DESCONTINUADA)","COMERCIAL","MA455MNU",;
					"PEDIDO/PRODUTO: "+_CPED,ComputerName(),LogUserName()) 

					//------------------------------------------------------------------------------------------------------------------
/*					// Ricardo Lima - 23/02/18
					If FindFunction("U_ADVEN050P") 
						If !Empty( Alltrim( SC5->C5_XPEDSAL ) )
							U_ADVEN050P( _CPED , .F. , .F. ,, .F. , .T. )
						EndIf
					EndIf*/
					//
					DBSelectArea("SC5")
					DBSetOrder(1)
					DbSeek(XFilial("SC5")+SC6->C6_NUM)

					_cMens2 := " "
					_cMens1 := '<html>'
					_cMens1 += '<head>'
					_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
					_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
					_cMens1 += '<title>Pedido Cortado</title>'
					_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
					_cMens1 += '</head>'
					_cMens1 += '<body bgcolor="#C0C0C0">'
					_cMens1 += '<center>'
					_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
					_cMens1 += '<tr height="80">'
					//			_cMens1 += '<td width="100%" height="80" background="http://www.adoro.com.br/microsiga/pedido_bloq.jpg">&nbsp;</td>'
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
					_cMens1 += '</table></center>'
					_cMens1 += '<table border="1" cellpadding="0" cellspacing="2" width="982">'
					_cMens1 += '<tr>'
					_cMens1 += '<td align="center" bgcolor="#FAA21B" width="1468" colspan="9">'
					_cMens1 += '<p align="center"><font face="Arial" size="1">Itens com corte no Pedido</font></td>'
					_cMens1 += '</tr></center>'
					_cMens1 += '<tr>'
					_cMens1 += '<td width="14" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Item</b></font></td>'
					_cMens1 += '<td width="50" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Produto</b></font></td>'
					_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descrição</b></font></td>'
					_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
					_cMens1 += '<td width="192" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Operação</b></font></p></td>'
					_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
					_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Qtde orig </b></font></td>'
					_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
					_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unitário</b></font></td>'
					_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
					_cMens1 += '</tr>'


					DBSelectArea("SC6")
					DBSetOrder(1)
					DbSeek(XFilial("SC6")+SC5->C5_NUM)
					If found()
					Endif

					//WHILE SC6->C6_NUM == SC5->C5_NUM - Marcelo Vicente - 20100619
					WHILE SC6->(!Eof()) .And. xFilial("SC6")==SC6->C6_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
						iF SC6->C6_QTDORI == SC6->C6_QTDVEN
							DBSKIP()
							LOOP
						Endif
						_cMens2  += '<tr>'
						_cMens2  += '<td width="14"  bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC6->C6_ITEM+'</font></td>'
						_cMens2  += '<td width="50"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_PRODUTO+'</font></td>'
						_cMens2  += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_DESCRI+'</font></td>'
						_cMens2  += '<td width="57"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_TES+'</font></p></td>'
						_cMens2  += '<td width="192" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+SC6->C6_TES,"F4_TEXTO")+'</font></td>'
						_cMens2  += '<td width="42"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_UM+'</font></p></td>'
						_cMens2  += '<td width="91"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDORI,"@!")+'</font></p></td>'
						_cMens2  += '<td width="91"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDVEN,"@!")+'</font></p></td>'
						_cMens2  += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</font></p></td>'
						_cMens2  += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_VALOR,"@E 999,999,999.99")+'</font></p></td>'
						_cMens2  += '</tr>'
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


					_cMens    := _cMens1+_cMens2+_cMens3
					_cData    := transform(MsDate(),"@!")
					_cHora    := transform(Time(),"@!")
					_cPedMail := SC5->C5_NUM


					&&Mauricio 18/06/10 - movido para baixo.
					/*
					lRet := U_ENVIAEMAIL(GetMv("MV_RELACNT"),cEmail,_cMens,"PEDIDO No."+SC5->C5_NUM+" ,PEDIDO CORTADO - "+_cData+" - "+_cHora,"")

					//+-----------------------------------------+
					//|Nao consegui enviar o e-mail vou exibir  |
					//|o resultado em tela                      |
					//+-----------------------------------------+
					If !lRet
					ApMsgInfo("Nao foi possível o Envio do E-mail.O E-mail será impresso em "+;
					"Tela e o registro será processado. "+;
					"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
					"ou  no servico interno de E-mail da empresa.","Erro de Envio")
					//+---------------------------------+
					//|Montando arquivo de Trabalho     |
					//+---------------------------------+
					_aFile:={}
					AADD(_aFile,{"LINHA","C",1000,0})
					_cNom := CriaTrab(_aFile)
					dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)
					DbSelectArea("TRB")

					//+----------------------------------+
					//|Montando o Texto em TRB           |
					//+----------------------------------+

					TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"ª"))+"ª"
					TEXTO :=''
					For I:=0 to LEN(TxtNew)
					// Pego o proximo bloco
					TEXTO+=SUBSTR(TxtNew,1,1)
					// Exclui o caracter posicionado
					TxtNew:=STUFF(TxtNew,1,1,"")
					If 	LEN(TEXTO)>=200 	//txt=="ª" .or. _nTamLin > limite
					TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
					RecLock("TRB",.t.)
					Replace TRB->LINHA With TEXTO
					MsUnlock()
					TEXTO:=""
					Endif
					Next

					//+-------------------------+
					//|Copiando para Arquivo    |
					//+-------------------------+

					DbSelectArea("TRB")
					COPY to &"c:\"+_cNom+".html" SDF

					DbCloseArea("TRB")

					ShellExecute('open',"c:\"+_cNom+".html",'','',1) - Linha comentada para tentar resolver problema causado pela indisponibilidade do workflow

					Endif
					*/
					//-------------------------------------------------------------------------------------------------------------------

					If Len(aSaldos)>0
						For nX := 1 To Len(aSaldos)
							If nQtdNew > 0
								RecLock("SC6")
								SC6->C6_LOTECTL := aSaldos[nX][1]
								SC6->C6_NUMLOTE := aSaldos[nX][2]
								SC6->C6_LOCALIZ := aSaldos[nX][3]
								SC6->C6_NUMSERI := aSaldos[nX][4]
								SC6->C6_DTVALID := aSaldos[nX][7]
								SC6->C6_POTENCI := aSaldos[nX][6]
								MaLibDoFat(SC6->(RecNo()),Min(aSaldos[nX][5],nQtdNew1),aLib[1],aLib[2],aLib[3],aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)
								nQtdNew -= aSaldos[nX][5]
								SC6->C6_LOTECTL := ''//aSaldos[nX][1]
								SC6->C6_NUMLOTE := ''//aSaldos[nX][2]
								SC6->C6_LOCALIZ := ''//aSaldos[nX][3]
								SC6->C6_NUMSERI := ''//aSaldos[nX][4]
								SC6->C6_DTVALID := Ctod('')//aSaldos[nX][7]
								SC6->C6_POTENCI := 0//aSaldos[nX][6]
								Msunlock()
							EndIf
						Next nX
					Else
						//  Retirado pois o C6 ainda nao esta atualizado e gera a liberaçao total do item novamente- Marcvs Natel "NDM"
						//			  MaLibDoFat(SC6->(RecNo()),@nQtdNew1,aLib[1],aLib[2],aLib[3],aLib[4],.F.,.F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,@nVlrCred,/*nQtdalib2*/)

						//*** ATUALIZA SC6 COM QTDADE IGUAL A LIBERADA NO CORTE
						//				dbSelectArea("SC6")
						//				dbSetOrder(1)
						//				dbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
						//				Reclock("SC6",.F.)
						//					Replace C6_QTDVEN  With SC9->C9_QTDLIB
						//					Replace C6_UNSVEN  With SC9->C9_QTDLIB2
						//					Replace C6_QTDLIB  With SC9->C9_QTDLIB
						//					Replace C6_QTDLIB2 With SC9->C9_QTDLIB2
						//				Msunlock()
						//
					EndIf

					//           		SC6->(MaLiberOk({SC9->C9_PEDIDO},.F.))

					// Recalcula peso do pedido

					_cAreaSC9 := SC9->(GetArea())
					_cAreaSC5 := SC5->(GetArea())
					_cAreaSB1 := SB1->(GetArea())

					U_ADPeso()  // GRAVA PESO SC5,SZK,ZV2

					RestArea(_cAreaSC9)
					RestArea(_cAreaSC5)
					RestArea(_cAreaSB1)

					&&Chamada do email colocada aqui pois apos troca do provedor de email estamos com problemas no envio destes onde esta rotina
					&&nao roda ate o final de todo o processamento(Da forma que estava anteriormente) - Mauricio.

					lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+_cPedMail+" ,PEDIDO CORTADO - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM

					//+-----------------------------------------+
					//|Nao consegui enviar o e-mail vou exibir  |
					//|o resultado em tela                      |
					//+-----------------------------------------+
					If lRet == .F.
						ApMsgInfo("Nao foi possível o Envio do E-mail."+;
						"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
						"ou  no servico interno de E-mail da empresa.","Erro de Envio")
						//ApMsgInfo("Nao foi possível o Envio do E-mail.O E-mail será impresso em "+;
						//"Tela e o registro será processado. "+;
						//"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
						//"ou  no servico interno de E-mail da empresa.","Erro de Envio")
						//+---------------------------------+
						//|Montando arquivo de Trabalho     |
						//+---------------------------------+
						/*
						_aFile:={}
						AADD(_aFile,{"LINHA","C",1000,0})
						_cNom := CriaTrab(_aFile)
						dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)
						DbSelectArea("TRB")

						//+----------------------------------+
						//|Montando o Texto em TRB           |
						//+----------------------------------+

						TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"ª"))+"ª"
						TEXTO :=''
						For I:=0 to LEN(TxtNew)
						// Pego o proximo bloco
						TEXTO+=SUBSTR(TxtNew,1,1)
						// Exclui o caracter posicionado
						TxtNew:=STUFF(TxtNew,1,1,"")
						If 	LEN(TEXTO)>=200 	//txt=="ª" .or. _nTamLin > limite
						TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
						RecLock("TRB",.t.)
						Replace TRB->LINHA With TEXTO
						MsUnlock()
						TEXTO:=""
						Endif
						Next

						//+-------------------------+
						//|Copiando para Arquivo    |
						//+-------------------------+

						DbSelectArea("TRB")
						COPY to &"c:\"+_cNom+".html" SDF

						DbCloseArea("TRB")

						ShellExecute('open',"c:\"+_cNom+".html",'','',1) // Linha comentada para tentar resolver problema causado pela indisponibilidade do workflow
						*/
					Endif
				End Transaction
			Endif
		EndIf
	EndIf

	MsUnLockAll()
	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} User Function AD455Qtdl
	Consistencia da quantidade liberada
	@type  Function
	@author Henry Fila
	@since 01/09/2003
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function AD455Qtdl( nQuant, _nGetAux )

	Local aTam      := TamSX3("C6_QTDVEN")
	//Local nquant2	:= ConvUM(SC9->C9_PRODUTO,0,nquant,1)
	Local cProduto  := ""
	Local cAlias    := Alias()
	Local cGrade    := ""

	Local nQtdEnt   := 0
	Local nQtdLib   := 0
	Local nQtdVen   := 0
	Local nQtdOri   := SC9->C9_QTDLIB

	Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)
	Local lBloq     := .F.
	Local lGrade    := MaGrade()
	Local lRet      := .T.

	nQtdLib  := Iif(_nGetAux == 2, ConvUm( SC6->C6_PRODUTO, 00, nQuant, 01 ), nQuant) // converte a segunda em primeira

	&&Mauricio - 04/05/16 - validação para não realizar corte de produto sem segunda unidade de medida e fator de conversão.
	DbselectArea("SB1")
	DbSetOrder(1)
	if dbseek(xFilial("SB1")+SC6->C6_PRODUTO)
		If Empty(SB1->B1_SEGUM) .OR. SB1->B1_CONV == 0.00
			MsgInfo("A rotina de corte do pedido só é executada para produtos que usem a segunda unidade de medida no cadastro e tenham fator de conversao","Atençao")
			lRet := .F.
		Endif
	Endif

	if nquant == 0
		If MsgYesNo("Produto será excluido do carregamento, Confirma (S/N) ?")
			lret := .T.
		else
			lRet := .F.
		endif
	Endif

	if nquant > SC6->C6_QTDVEN //SC6->C6_QTDLIB
		Alert("Quantidade: " + Transform(nquant, "@E 9,999,999.99") + Chr(13) + Chr(13) + ;
		"Maior que a quantidade original" + Chr(13) + Chr(13) + ;
		"Do Pedido: " + Transform(SC6->C6_QTDLIB, "@E 9,999,999.99") + Chr(13) )
		lRet := .F.
	Endif

	if lRet

		If (nQtdOri <> nQtdLib)

			If Empty(SC9->C9_RESERVA)

				SC6->(dbsetOrder(1))

				If SC6->(MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))

					cProduto  := SC6->C6_PRODUTO
					lBloq     := (AllTrim(SC6->C6_BLQ) $ "RS" )
					nQtdVen   := SC6->C6_QTDVEN
					nQtdEnt   := SC6->C6_QTDENT
					cGrade    := SC6->C6_GRADE

					If lGrade
						MatGrdPrrf(@cProduto)
					Endif


					If ( lBloq .And. lRsDoFat .and. nQtdLib > 0  )
						Help(" ",1,"A410ELIM")
						lRet := .F.
					Endif

					If lRet
						If SuperGetMv("MV_LIBACIM")
							If !lGrade  .Or. cGrade <> "S"
								If Round(nQtdLib,aTam[2]) > Round(SC6->C6_QTDVEN - (SC6->C6_QTDEMP+SC6->C6_QTDENT)+nQtdOri,aTam[2])
									Help(" ",1,"A440QTDL")
									lRet := .F.
								Endif
							EndIf
						Endif
					Endif
				Endif
			Else
				Help(" ",1,"A455RESERV")//"Alteracao nao permitida pois a liberacao possui reserva."
				lRet := .f.
			Endif
		Endif
	Endif
	If lRet

		Do Case
			Case _nGetAux == 01
			nQtdNew	:= ConvUm( SC6->C6_PRODUTO, nQtdNew1, 00, 02 )
			oQtdNew:Refresh()
			Case _nGetAux == 02
			nQtdNew1	:= ConvUm( SC6->C6_PRODUTO, 00, nQtdNew, 01 )
			oQtdNew1:Refresh()
		EndCase

	EndIf

	dbSelectArea( cAlias )

Return( lRet )

/*/{Protheus.doc} User Function AD455Ok
	(long description)
	@type  Function
	@author Henry Fila
	@since 01/09/2003
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function AD455Ok(nOpcao,nQtdNew1)

	Local _lRet := .T.

	If (Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO)) .And. (nQtdNew1 <> SC9->C9_QTDLIB) .And.;
	nOpcao == 3
		Help(" ",1,"A455LOCAL") //"Liberacao manual nao permitida pois o produto possui rastreabilidade ou localizacao fisica"
		_lRet := .F.
	Endif

Return(_lRet)

/*/{Protheus.doc} User Function ADPeso
	Calcula peso do pedido baseado nos itens liberados
	@type  Function
	@author Heverson HCConsys
	@since 23/10/2008
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function ADPeso()

	Local _nTotalCx:= 0
	Local _nTotalKg:= 0
	Local _nTotalBr:= 0
	Local _nVlCA 	:= 0
	Local _nVlTK 	:= 0
	Local _nVlTC 	:= 0

	Local _cTipVei	:= ""
	Local _cCodCid := ""
	Local _cCidade := ""
	Local _cTipoFrt:= ""
	Local _cAtuaSC5:= ""

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5") + SC9->C9_PEDIDO)

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9") + SC9->C9_PEDIDO)

	//Do while .not. eof() .and. SC9->C9_PEDIDO == SC5->C5_NUM
	While SC9->( !eof() ) .and. xFilial("SC9")==SC9->C9_FILIAL .And. SC9->C9_PEDIDO == SC5->C5_NUM  // Marcelo Vicente - 20100619

		IF  EMPTY(SC9->C9_BLCRED)

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1") + SC9->C9_PRODUTO)

			_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2          // Soma qtd caixas (2a. UM)
			//		_nTotalKg   := _nTotalKg   + SC9->C9_QTDLIB          // Soma qtd peso   <1a. UM)
			_nTotalKg   := _nTotalKg   + iif(SB1->B1_SEGUM="BS",0,SC9->C9_QTDLIB)          // Soma qtd peso   <1a. UM)	//alterado por Adriana, se bolsa nao soma 1a unidade como peso

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

	RecLock("SC5",.F.)

	//If cEmpAnt == "02"              //desabilitado pois estava zerando peso na Ceres - por Adriana em 10/02/17 - chamado 033288
	//	SC5->C5_PBRUTO  := _nTotalBr
	//Else
	SC5->C5_PBRUTO  := _nTotalBr + _nTotalkg
	//Endif	
	SC5->C5_PESOL   := _nTotalKg
	SC5->C5_VOLUME1 := _nTotalCx
	SC5->C5_LIBEROK := "S"

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

	endif

Return()
