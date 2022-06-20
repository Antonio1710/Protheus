#Include "Protheus.CH"
#Include "Colors.CH"
#Include "vKey.CH"
#Include "HCCONSYS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MANUBAL   ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao dos dados lidos da balanca                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MANUBAL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MANUBAL()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cDelFunc		:= ".T."
Private cCadastro		:= "Manutencao Leitura Balanca"
Private nRegEmpenho	:= 0
Private cCusMed		:= GetMv( "MV_CUSMED" )
Private cTMProd		:= GetMv( "MV_XXPROD", .F., "100" )
Private aRegSD3		:= {}
Private cFilSB1		:= xFilial( "SB1" )
Private cFilSD3		:= xFilial( "SD3" )
Private cFilSZW		:= xFilial( "SZW" )
Private dDtAnt			:= dDataBase
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private oProcess
Private aRotina

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao dos dados lidos da balanca')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca mBrowse                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bAltLeit	:= {|| fAltLeit()		}
bLegenda	:= {|| fLegenda()		}
bReproc	:= {|| fReprocesso()	}
bDigMan	:= {|| fDigManual()	}

aRotina	:=	{	{ "Pesquisar"	, "AxPesqui"			, 00 , 01 },;
					{ "Manutencao"	, "Eval( bAltLeit )"	, 00 , 04 },;
					{ "Dig.Manual"	, "Eval( bDigMan )"	, 00 , 02 },;
					{ "Reprocesso"	, "Eval( bReproc )"	, 00 , 03 },;
					{ "Relatorio"	, "U_RelBal01"			, 00 , 05 },;
					{ "Legenda"		, "Eval( bLegenda )"	, 00 , 04 } }

Private aCores	:=	{	{ "!Empty(ZW_OP) .And. ZW_OPERAC != 'X'"	, "BR_VERMELHO"	},;
							{ "Empty(ZW_OP) .And. ZW_OPERAC != 'X'"	, "BR_VERDE"		},;
							{ "ZW_OPERAC == 'X'"								, "BR_PRETO"		} }

SZW->(DbSetOrder(1))
SZW->(DbGoTop())

mBrowse( ,,,, "SZW",,,,,, aCores )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fLegenda  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLegenda()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLegenda()

BrwLegenda( cCadastro, "Legenda", { { "BR_VERMELHO", "OPs Geradas" }, { "BR_VERDE", "OPs em Aberto" }, { "BR_PRETO", "Reprocesso" } } )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fAltLeit  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fAltLeit()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAltLeit()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lDelLinha	:= .F.
Private lRefresh	:= .T.
Private cArquivo	:= SZW->ZW_ARQUIVO
Private cBalanca	:= SZW->ZW_BALAN
Private dDtCria	:= SZW->ZW_DTARQ
Private cHrCria	:= SZW->ZW_HRARQ
Private cAliasTrb	:= GetNextAlias()
Private cAliasTmp	:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o registro foi produzido                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( SZW->ZW_OP )
	ApMsgInfo( "Op ja Produzida!!!" )
	Return ( Nil )
EndIf

If SZW->ZW_OPERAC == "X"
	ApMsgInfo( "OP nao pode ser gerada (reprocesso) !!!" )
	Return ( Nil )
EndIf

aRotina	:= { { "", "", 00, 01 }, { "", "", 00, 02 }, { "", "", 00, 03 },{ "", "", 00, 04 } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da tabela de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrb	:=	{	{ "ZW_OPERAC"	, "C", 01, 00 },;
				{ "ZW_BALAN"	, "C", 02, 00 },;
				{ "ZW_SEQETQ"	, "C", 06, 00 },;
				{ "ZW_PRODUTO"	, "C", 15, 00 },;
				{ "ZW_DTLEITU"	, "D", 08, 00 },;
				{ "ZW_HRLEITU"	, "C", 05, 00 },;
				{ "ZW_PESOLIQ"	, "N", 07, 02 },;
				{ "ZW_TARA"		, "N", 07, 02 },;
				{ "ZW_VALID"	, "C", 03, 00 },;
				{ "ZW_OP"		, "C", 06, 00 },;
				{ "FLAG"			, "L", 01, 00 } }

cArqTrb	:= CriaTrab( aTrb, .T. )             

DbUseArea( .T.,, cArqTrb, cAliasTrb, .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query de selecao do registros lidos das balancas             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQry	:= "SELECT ZW_OPERAC, ZW_BALAN, ZW_SEQETQ, ZW_PRODUTO, ZW_DTLEITU, ZW_HRLEITU, ZW_PESOLIQ,ZW_TARA  ,ZW_VALID "
cQry	+= "FROM " + RetSqlName( "SZW" ) + " "
cQry	+= "WHERE D_E_L_E_T_ = '' "
cQry	+= "AND ZW_FILIAL = '" + cFilSZW + "' "
cQry	+= "AND ZW_BALAN = '" + cBalanca + "' "
cQry	+= "AND ZW_DTARQ = '" + DtoS( dDtCria ) + "' "
cQry	+= "AND ZW_HRARQ = '" + cHrCria + "' "
cQry	+= "AND ZW_OPERAC <> 'X' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manutencao                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQry ), cAliasTmp, .F., .T. )

aEval( SZW->( DbStruct() ), {|x| Iif( x[ 02 ] != "C" .And. ( cAliasTmp )->( FieldPos( x[ 01 ] ) ) > 00, TcSetField( cAliasTmp, x[ 01 ], x[ 02 ], x[ 03 ], x[ 04 ] ), Nil ) } )

( cAliasTmp )->( dbGotop() )

While !( cAliasTmp )->( Eof() )
	
	( cAliasTrb )->( RecLock( cAliasTrb, .T. ) )
	
	aEval( aTrb, {|x| Iif( ( cAliasTmp )->( FieldPos( AllTrim( x[ 01 ] ) ) ) > 00, ( cAliasTrb )->( FieldPut( ( cAliasTrb )->( FieldPos( AllTrim( x[ 01 ] ) ) ), ( cAliasTmp )->( FieldGet( FieldPos( AllTrim( x[ 01 ] ) ) ) ) ) ), Nil ) } )
	
	( cAliasTrb )->( MsUnLock() )
	
	( cAliasTmp )->( dbSkip() )

EndDo

( cAliasTmp )->( dbCloseArea() )

If ( cAliasTrb )->( RecCount() ) > 00

	Private bLinhaOk := {||fLinhaOk() }
	Private bTudoOk  := {||fTudoOk() }

	dbSelectArea( cAliasTrb )

	nOpc		:= 04
	aHeader	:= {}
	aF3		:= {}

	SX3->( dbSetOrder( 01 ) )
	SX3->( dbSeek( "SZW" ) )

	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SZW"

		If X3Uso( SX3->X3_USADO ) .And. 	SX3->X3_NIVEL <= cNivel .And. aScan( aTrb, {|x|x[ 01 ] == AllTrim( SX3->X3_CAMPO ) } ) > 00

			AAdd( aHeader,	{	AllTrim( X3Titulo() ),;
									SX3->X3_CAMPO   ,;
									SX3->X3_PICTURE ,;
									SX3->X3_TAMANHO ,;
									SX3->X3_DECIMAL ,;
									SX3->( X3_VALID + Iif( !Empty( X3_VLDUSER ), ".And.", "" ) + X3_VLDUSER ),;
									SX3->X3_USADO   ,;
									SX3->X3_TIPO    ,;
									cAliasTrb       ,;
									SX3->X3_CONTEXT } )
		
			AAdd( aF3, SX3->X3_F3 )

		EndIf
		
		SX3->( dbSkip() )

	EndDo

	nOpcao	:= 00
	bOk		:= {||oDlg:End(), nOpcao := 01 }
	bCancel	:= {||oDlg:End(), nOpcao := 00 }
	aButtons	:= {}
	nLinhas	:= ( cAliasTrb )->( RecCount() ) * 100

	( cAliasTrb )->( dbGoTop() )

	oDlg		:= MsDialog():New( oMainWnd:nTop + 15, oMainWnd:nLeft + 05, oMainWnd:nClientHeight - 30, oMainWnd:nClientWidth - 10, OemToAnsi( cCadastro ),,,,,,,, oMainWnd, .T. )
	oGetDb	:= MsGetDB():New( oDlg:nTop, oDlg:nLeft, 00, 00, nOpc, "Eval( bLinhaOk )", "Eval( bTudoOk )",, .T.,, 00, .T., nLinhas, cAliasTrb,,, .T., oDlg, .T. )

	oGetDb:oBrowse:nWidth	:= oDlg:nClientWidth  - 20
	oGetDb:oBrowse:nHeight	:= oDlg:nClientHeight - 60

	For nCol := 01 To Len( aHeader )
		cF3		:= "oGetDb:aInfo[" + StrZero( nCol, 03 ) + "][ 01 ]"
		&(cF3)	:= aF3[ nCol ]
	Next nCol

	oDlg:Activate(,,,.T.,bTudoOk,,{||(EnchoiceBar(oDlg,bOk,bCancel,,aButtons))})

	If nOpcao == 01
		
		lOpOk := .F.
		
		If ApMsgYesNo( "Deseja Gerar OPS" )
			Processa( {|| lOpOk:=cfGeraOP() }, "Geracao de OPS", "Aguarde" )
		EndIf

		cQry	:= "DELETE " + RetSqlName( "SZW" ) + " " 
		cQry	+= "WHERE D_E_L_E_T_ = ' ' "
		cQry	+= "AND ZW_FILIAL = '" + cFilSZW + "' "
		cQry	+= "AND ZW_BALAN = '" + cBalanca + "' "
		cQry	+= "AND ZW_DTARQ = '" + DtoS( dDtCria ) + "' "
		cQry	+= "AND ZW_HRARQ = '" + cHrCria + "' "

		If TcSqlExec( cQry ) < 00
			U_cf_SqlError( "Erro na delecao dos itens da SZW" )
		EndIf

		( cAliasTrb )->( dbGoTop() )

		While !( cAliasTrb )->( Eof() )

			SZW->( RecLock( "SZW", .T. ) )
			
			aEval( aTrb, {|x| Iif( SZW->( FieldPos( AllTrim( x[ 01 ] ) ) ) > 00, SZW->( FieldPut( SZW->( FieldPos( AllTrim( x[ 01 ] ) ) ), ( cAliasTrb )->( FieldGet( FieldPos( AllTrim( x[ 01 ] ) ) ) ) ) ), Nil ) } )

			SZW->ZW_FILIAL		:= cFilSZW
			SZW->ZW_OP			:= Iif( lOpOk, ( cAliasTrb )->ZW_OP + "01001", "" )
			SZW->ZW_BALAN		:= cBalanca
			SZW->ZW_ARQUIVO	:= cArquivo
			SZW->ZW_DTARQ		:= dDtCria
			SZW->ZW_HRARQ		:= cHrCria
			
			SZW->(MsUnLock())

			( cAliasTrb )->( dbSkip() )
		
		EndDo

	EndIf

EndIf

( cAliasTrb )->( dbCloseArea() )

FErase( cArqTrb + GetDbExtension() )
FErase( cArqTrb + IndexExt())

RestArea( aArea )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fLinhaOk  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLinhaOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLinhaOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o registro foi produzido                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->( GetArea() )
Local lRet		:= .T.
Local cErr		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cAliasTrb )->FLAG
	Return( lRet )
EndIf
SB1->( dbSetOrder( 01 ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define mensagens de erro                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( ( cAliasTrb )->ZW_PRODUTO ) .Or. !SB1->( dbSeek( cFilSB1 + ( cAliasTrb )->ZW_PRODUTO ) )
	cErr += "Informar o codigo do produto..." + CRLF
EndIf

If Empty( ( cAliasTrb )->ZW_OPERAC )
	cErr	+= "Informar a Operacao..." + CRLF
EndIf

If Empty( ( cAliasTrb )->ZW_SEQETQ )
	cErr	+= "Informar a Sequencia da Etiqueta..." + CRLF
EndIf

If Empty( ( cAliasTrb )->ZW_DTLEITU )
	cErr	+= "Informar a Data da Leitura..." + CRLF
EndIf

If Empty( ( cAliasTrb )->ZW_HRLEITU )
	cErr	+= "Informar a Hora da Leitura..." + CRLF
EndIf

If ( cAliasTrb )->ZW_PESOLIQ == 00
	cErr	+= "Informar o Peso Liquido..." + CRLF
EndIf

If ( cAliasTrb )->ZW_TARA == 00
	cErr	+= "Informar a Tara..." + CRLF
EndIf

If Empty( ( cAliasTrb )->ZW_VALID )
	cErr	+= "Informar o prazo de validade..." + CRLF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagens de erro                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cErr )
	AutoGrLog( cErr )
	MostraErro()
	lRet := .F.
EndIf

RestArea( aAreaSB1 )
RestArea( aArea )

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fTudoOk   ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos registros                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fTudoOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fTudoOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagens de erro                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->( GetArea() )
Local nRegTRB	:= ( cAliasTrb )->(Recno() )
Local cErr		:= ""
Local nLin		:= 00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos registros atualizados                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->( dbSetOrder( 01 ) )

( cAliasTrb )->( dbGoTop() )

While !( cAliasTrb )->( Eof() )
   
	nLin++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cAliasTrb )->FLAG
		(cAliasTrb )->( dbSkip() )
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta mensagem de erro                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( ( cAliasTrb )->ZW_PRODUTO ) .Or. !SB1->( dbSeek( cFilSB1 + ( cAliasTrb )->ZW_PRODUTO ) )
		cErr	+= "Informar o codigo do produto... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If Empty( ( cAliasTrb )->ZW_OPERAC )
		cErr	+= "Informar a Operacao... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If Empty( ( cAliasTrb )->ZW_SEQETQ )
		cErr	+= "Informar a Sequencia da Etiqueta... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If Empty( ( cAliasTrb )->ZW_DTLEITU )
		cErr	+= "Informar a Data da Leitura... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If Empty( ( cAliasTrb )->ZW_HRLEITU )
		cErr	+= "Informar a Hora da Leitura... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If ( cAliasTrb )->ZW_PESOLIQ == 00
		cErr	+= "Informar o Peso Liquido... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If ( cAliasTrb )->ZW_TARA == 00
		cErr	+= "Informar a Tara... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	If Empty( ( cAliasTrb )->ZW_VALID )
		cErr	+= "Informar o prazo de validade... Linha " + StrZero( nLin, 04 ) + CRLF
	EndIf

	( cAliasTrb )->( dbSkip() )

EndDo

( cAliasTrb )->( dbGoTo( nRegTRB ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem de erro                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cErr )
	AutoGrLog( cErr )
	MostraErro()
	lRet := .F.
EndIf

If !lRet
	nOpcao := 00
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetdb:oBrowse:Refresh()
oGetdb:oBrowse:SetFocus()

RestArea( aAreaSB1 )
RestArea( aArea )

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ cfGeraOP  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera ordens de producao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cfGeraOP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function cfGeraOP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea	:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove registros de movimentacao interna de estorno          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQry	:= "DELETE " + RetSqlName( "SD3" ) + " "
cQry	+= "WHERE D_E_L_E_T_ = '' "
cQry	+= "AND D3_ESTORNO = 'S' "

If TcSqlExec( cQry ) < 00
	U_cf_SqlError( "Erro na delecao dos estornos do SD3" )
EndIf

TCRefresh( RetSqlName( "SD3" ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria OPs atraves de ExecAuto                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
( cAliasTrb )->( dbCreateIndex( cArqTrb, "ZW_BALAN + ZW_PRODUTO" ) )
( cAliasTrb )->( dbSetIndex( cArqTrb ) )
( cAliasTrb )->( dbSetOrder( 01 ) )

SB1->( dbSetOrder( 01 ) )

ProcRegua( ( cAliasTrb )->( RecCount() ) )

lProdOk	:= .T.

Begin Transaction

	While !( cAliasTrb )->( Eof() ) .And. lProdOk

		If ( cAliasTrb )->FLAG
			IncProc()
			( cAliasTrb )->( dbSkip() )
			Loop
		EndIf

		SB1->( dbSeek( cFilSB1 + ( cAliasTrb )->ZW_PRODUTO ) )

		lMsErroAuto	:= .F.
		cNumOp		:= GetNumSC2( .T. )

		aDadOp := U_MntArraySX3( "SC2" )
		
		For _nCtaDadOp := 01 To Len( aDadOp )
			
			Do Case
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_FILIAL"
					aDadOp[ _nCtaDadOp, 02 ] := xFilial( "SC2" )
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_NUM"
					aDadOp[ _nCtaDadOp, 02 ] := cNumOp
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_ITEM"
					aDadOp[ _nCtaDadOp, 02 ] := "01"
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_SEQUEN"
					aDadOp[ _nCtaDadOp, 02 ] := "001"
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_PRODUTO"
					aDadOp[ _nCtaDadOp, 02 ] := ( cAliasTrb )->ZW_PRODUTO
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_LOCAL"
					aDadOp[ _nCtaDadOp, 02 ] := IIF(!RetArqProd(SB1->B1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+SB1->B1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_LOCPAD")) //LTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA 
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_QUANT"
					aDadOp[ _nCtaDadOp, 02 ] := 00
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_UM"
					aDadOp[ _nCtaDadOp, 02 ] := SB1->B1_UM
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_DATPRI"
					aDadOp[ _nCtaDadOp, 02 ] := ( cAliasTrb )->ZW_DTLEITU
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_DATPRF"
					aDadOp[ _nCtaDadOp, 02 ] := ( cAliasTrb )->ZW_DTLEITU
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_EMISSAO"
					aDadOp[ _nCtaDadOp, 02 ] := ( cAliasTrb )->ZW_DTLEITU
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_PRIOR"
					aDadOp[ _nCtaDadOp, 02 ] := "N"
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "C2_TPOP"
					aDadOp[ _nCtaDadOp, 02 ] := "F"
				Case AllTrim( aDadOp[ _nCtaDadOp, 01 ] ) == "AUTEXPLODE"
					aDadOp[ _nCtaDadOp, 02 ] := "S"
			EndCase
			
		Next

		aDadD3 := U_MntArraySX3( "SD3" )
		
		For _nCtaDadD3 := 01 To Len( aDadOp )
			
			Do Case
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_FILIAL"
					aDadD3[ _nCtaDadD3, 02 ] := cFilSD3
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_TM"
					aDadD3[ _nCtaDadD3, 02 ] := cTMProd
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_OP"
					aDadD3[ _nCtaDadD3, 02 ] := PadR( cNumOp + "01001", Len( SD3->D3_OP ) )
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_COD"
					aDadD3[ _nCtaDadD3, 02 ] := ( cAliasTrb )->ZW_PRODUTO
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_UM"
					aDadD3[ _nCtaDadD3, 02 ] := SB1->B1_UM
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_QUANT"
					aDadD3[ _nCtaDadD3, 02 ] := 00
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_PERDA"
					aDadD3[ _nCtaDadD3, 02 ] := 00
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_LOCAL"
					aDadD3[ _nCtaDadD3, 02 ] := IIF(!RetArqProd(SB1->B1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+SB1->B1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_LOCPAD")) //LTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA 
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_DOC"
					aDadD3[ _nCtaDadD3, 02 ] := cNumOp
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_EMISSAO"
					aDadD3[ _nCtaDadD3, 02 ] := ( cAliasTrb )->ZW_DTLEITU
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_PARCTOT"
					aDadD3[ _nCtaDadD3, 02 ] := "T"
				Case AllTrim( aDadD3[ _nCtaDadD3, 01 ] ) == "D3_SEGUM"
					aDadD3[ _nCtaDadD3, 02 ] := SB1->B1_SEGUM
			EndCase
			
		Next
			
		dDataBase	:= ( cAliasTrb )->ZW_DTLEITU
		cBalan		:= ( cAliasTrb )->ZW_BALAN
		cProduto		:= ( cAliasTrb )->ZW_PRODUTO
      
		While !( cAliasTrb)->( Eof() ) .And. ( cAliasTrb )->ZW_BALAN == cBalan .And. ( cAliasTrb )->ZW_PRODUTO == cProduto

			IncProc()

			If ( cAliasTrb )->FLAG
				( cAliasTrb )->( dbSkip() )
				Loop
			EndIf

			( cAliasTrb )->(RecLock( cAliasTrb, .F. ) )
			( cAliasTrb )->ZW_OP := cNumOp
			( cAliasTrb )->( MsUnLock() )

			aDadOp[ aScan( aDadOp, {|x| AllTrim( x[ 01 ] ) == "C2_QUANT"		} ) ][ 02 ]	+= ( cAliasTrb )->ZW_PESOLIQ
			aDadOp[ aScan( aDadOp, {|x| AllTrim( x[ 01 ] ) == "C2_QTSEGUM"	} ) ][ 02 ]	+= Int( ConvUm( ( cAliasTrb )->ZW_PRODUTO,( cAliasTrb )->ZW_PESOLIQ, 00, 02 ) )
			aDadD3[ aScan( aDadD3, {|x| AllTrim( x[ 01 ] ) == "D3_QUANT"		} ) ][ 02 ]	+= ( cAliasTrb )->ZW_PESOLIQ
			aDadD3[ aScan( aDadD3, {|x| AllTrim( x[ 01 ] ) == "D3_QTSEGUM"	} ) ][ 02 ]	+= Int( ConvUm( ( cAliasTrb )->ZW_PRODUTO,( cAliasTrb )->ZW_PESOLIQ, 00, 02 ) )

			( cAliasTrb )->( dbSkip() )

		EndDo

		If ( lProdOk := cfCriaOp( aDadOp ) )
			lProdOk := cfProduz( aDadD3 )
		EndIf

		dDataBase := dDtAnt

	EndDo

End Transaction

If !lProdOk
	MostraErro()
EndIf

RestArea( aArea )

Return( lProdOk )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ cfCriaOp  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera ordens de producao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cfCriaOp( aDados )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = dados para geracao das ordens de producao         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function cfCriaOp( aDados )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea	:= GetArea()
Local lRet	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Ordens de Producao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsExecAuto( {|x,y|Mata650( x, y ) }, aDados, 03 )

If lMsErroAuto
	DisarmTransaction()
	lRet := .F.
EndIf

RestArea( aArea )

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ cfCriaOp  ³ Autor ³ HCCONSYS             ³ Data ³24/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera ordens de producao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ cfCriaOp( aDados )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = dados para geracao das ordens de producao         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function cfProduz(aDados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea		:= GetArea()
Local aItens	:= {}
Local lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua apontamento automatico das ordens de producao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsExecAuto( {|x,y| Mata250( x, y ) }, aDados, 03 )

If lMsErroAuto
	DisarmTransaction()
	lRet := .F.
EndIf

RestArea( aArea )

Return( lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fReprocesso³ Autor ³ Celso Costa          ³ Data ³07/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reprocesso                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fReprocesso()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fReprocesso()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marca registro de reprocesso                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MsgYesNo( "Marca/Desmarca Reprocesso ?" )
	
	RecLock( "SZW", .F. )
	SZW->ZW_OPERAC := Iif( SZW->ZW_OPERAC == "X", "P", "X" )
	SZW->( MsUnLock() )
	
EndIf

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fDigManual ³ Autor ³ Celso Costa          ³ Data ³07/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Digitacao Manual                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fDigManual()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fDigManual()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _dDataGer	:= dDataBase
Local _cHoraGer	:= Time()
Local _dDataLei	:= dDataBase
Local _cHoraLei	:= Time()
Local _cBalanca	:= "MN"
Local _cSeqEtq		:= RetSeqEtq()
Local _cProduto	:= Space( 15 )
Local _nCaixas		:= 00
Local _cPrazo		:= Space( 04 )
Local _nTara		:= 00
Local _nOpca		:= 00
Local oDlg1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cDescPrd	:= Space( 30 )
Private _nPesoLiq	:= 00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define MsDialog oDlg1 Title OemToAnsi( "Digitacao Manual" ) From 05, 00 To 24, 62

@ 020.0, 005 Say OemToAnsi( "Data Geracao"	)	Size 080, 10 Pixel Of oDlg1
@ 020.0, 105 Say OemToAnsi( "Hora Geracao"	)	Size 080, 10 Pixel Of oDlg1

@ 035.0, 005 Say OemToAnsi( "Data Leitura"	)	Size 080, 10 Pixel Of oDlg1
@ 035.0, 105 Say OemToAnsi( "Hora Leitura"	)	Size 080, 10 Pixel Of oDlg1

@ 050.0, 005 Say OemToAnsi( "Balanca"			)	Size 080, 10 Pixel Of oDlg1
@ 050.0, 105 Say OemToAnsi( "Seq.Etiqueta"	)	Size 080, 10 Pixel Of oDlg1

@ 080.0, 005 Say OemToAnsi( "Produto"			)	Size 080, 10 Pixel Of oDlg1

@ 110.0, 005 Say OemToAnsi( "Qtde. Caixas"	)	Size 080, 10 Pixel Of oDlg1
@ 110.0, 105 Say OemToAnsi( "Peso Liquido"	)	Size 080, 10 Pixel Of oDlg1

@ 125.0, 005 Say OemToAnsi( "Tara"				)	Size 080, 10 Pixel Of oDlg1
@ 125.0, 105 Say OemToAnsi( "Prz validade"	)	Size 080, 10 Pixel Of oDlg1

@ 019.2, 050 MsGet _dDataGer	Size 030, 10 Pixel Of oDlg1									Valid !Empty( _dDataGer )
@ 019.2, 155 MsGet _cHoraGer	Size 005, 10 Pixel Of oDlg1	Picture "99:99"			Valid !Empty( _cHoraGer ) .And. ( _cHoraGer >= "00:00" .And. _cHoraGer <= "24:00" )

@ 034.2, 050 MsGet _dDataLei	Size 030, 10 Pixel Of oDlg1									Valid !Empty( _dDataLei )
@ 034.2, 155 MsGet _cHoraLei	Size 005, 10 Pixel Of oDlg1	Picture "99:99"			Valid !Empty( _cHoraLei ) .And. ( _cHoraLei >= "00:00" .And. _cHoraLei <= "24:00" )

@ 049.2, 050 MsGet _cBalanca	Size 003, 10 Pixel Of oDlg1									When .F.
@ 049.2, 155 MsGet _cSeqEtq	Size 008, 10 Pixel Of oDlg1	Picture "999999"			When .F.

@ 079.2, 050 MsGet _cProduto	Size 030, 10 Pixel Of oDlg1	Picture "999999"			Valid VldProd( _cProduto ) F3 "SB1"
@ 079.2, 090 MsGet _cDescPrd	Size 150, 10 Pixel Of oDlg1									When .F.

@ 109.2, 050 MsGet _nCaixas	Size 030, 10 Pixel Of oDlg1	Picture "@E 9,999.99"	Valid VldCaixas( _cProduto, _nCaixas )
@ 109.2, 155 MsGet _nPesoLiq	Size 030, 10 Pixel Of oDlg1	Picture "@E 9,999.99"	When .F.

@ 124.2, 050 MsGet _nTara		Size 030, 10 Pixel Of oDlg1	Picture "@E 9,999.99"	Valid _nTara > 00
@ 124.2, 155 MsGet _cPrazo		Size 005, 10 Pixel Of oDlg1	Picture "9999"				Valid !Empty( _cPrazo )

Activate MsDialog oDlg1 On Init EnchoiceBar( oDlg1, {||_nOpca := 01, oDlg1:End() }, {||_nOpca := 00, oDlg1:End()} ) Centered

If _nOpca == 01

	RecLock( "SZW", .T. )

	SZW->ZW_FILIAL		:= xFilial( "SZW" )
	SZW->ZW_SERVER		:= ""
	SZW->ZW_ARQUIVO		:= "DIGITACAO MANUAL"
	SZW->ZW_DTARQ		:= _dDataGer
	SZW->ZW_HRARQ		:= _cHoraGer
	SZW->ZW_BALAN		:= _cBalanca
	SZW->ZW_OPERAC		:= "P"
	SZW->ZW_SEQETQ		:= _cSeqEtq
	SZW->ZW_PRODUTO		:= _cProduto
	SZW->ZW_DTLEITU		:= _dDataLei
	SZW->ZW_HRLEITU		:= _cHoraLei
	SZW->ZW_PESOLIQ		:= _nPesoLiq
	SZW->ZW_TARA		:= _nTara
	SZW->ZW_VALID		:= _cPrazo

	SZW->( MsUnLock() )

EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetSeqEtq ³ Autor ³ Celso Costa          ³ Data ³07/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna sequencia de etiquetas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetSeqEtq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetSeqEtq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _cQuery	:= ""
Local _cSeqEtq	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registro                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT MAX( ZW_SEQETQ ) AS SEQETQ "
_cQuery += "FROM "
_cQuery += RetSqlName( "SZW" ) + " "
_cQuery += "WHERE ZW_BALAN = 'MN' "
_cQuery += "AND D_E_L_E_T_ = '' "

_cQuery := ChangeQuery( _cQuery )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna valores                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T., "TopConn", TCGenQry( ,, _cQuery ), "TMPQRY", .F., .F. )

_cSeqEtq := Iif( Empty( TMPQRY->SEQETQ ), "000001", RetAsc( ( Val( TMPQRY->SEQETQ ) + 01 ), 06, .T. ) )

TMPQRY->( dbCloseArea() )

RestArea( _aArea )

Return ( _cSeqEtq )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldProd   ³ Autor ³ Celso Costa          ³ Data ³07/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do codigo do produto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldProd()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldProd( _cProduto )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona cadastro de produto                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( _cProduto )
	Return ( .F. )
EndIf

dbSelectArea( "SB1" )
dbSetOrder( 01 )

If dbSeek( xFilial( "SB1" ) + _cProduto )
	_cDescPrd	:= SB1->B1_DESC
Else
	_cDescPrd	:= Space( 30 )
	_lRet			:= .F.
EndIf
		
RestArea( _aArea )

Return ( _lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldCaixas ³ Autor ³ Celso Costa          ³ Data ³07/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida quantidade de caixas digitada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GrvDgMan()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldCaixas( _cProduto, _nCaixas )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _lRet		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _nCaixas > 00
	
	dbSelectArea( "SB1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "SB1" ) + _cProduto )
		_nPesoLiq := Iif( SB1->B1_TIPCONV == "D", _nCaixas * SB1->B1_CONV, _nCaixas / SB1->B1_CONV )  
	Else
		_nPesoLiq := 00
	EndIf
		
Else
	_nPesoLiq	:= 00
	_lRet			:= .F.
EndIf

RestArea( _aArea )

Return ( _lRet )
