//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicoes e Includes                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#Include "Protheus.CH"
#Include "TopConn.CH"
#Include "Chamado.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ADCHHist   ³ Autor ³ Celso Costa          ³ Data ³19/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Tree - CHAMADOS                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_ADCHHist()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADCHHist()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oTree
Local oDlg
Local oFont
Local oPanel
Local aEnch[ 03 ]
Local nTop		:= oMainWnd:nTop + 23
Local nLeft		:= oMainWnd:nLeft + 05
Local nBottom	:= oMainWnd:nBottom - 60
Local nRight	:= oMainWnd:nRight - 10
Local nOldEnch	:= 01
Local bChange	:= {|| Nil }
Local aTotais	:= {}
Local aSVAlias	:= {}
Local aButtons	:= { { "PMSDOC", {|| U_LegOS() }, OemToAnsi( STR0007 ) } } // AUTOM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:= OemToAnsi( STR0137 )
Private aTela		:= {}
Private aGets		:= {}
Private _nOrdens	:= 00
Private _cHoras	:= ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Tree - CHAMADOS')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as variaveis de memoria do SB1               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aSVAlias, "PA9" )
RegToMemory( "PA9", .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define FONT oFont NAME "Arial" Size 00, -10

Define MsDialog oDlg Title cCadastro Of oMainWnd Pixel From nTop, nLeft To nBottom, nRight 

oFolder	:= TFolder():New( 12, 00,{ OemToAnsi( STR0136 ) }, {}, oDlg,,,, .T., .F., nRight - nLeft, nBottom - nTop - 12, )
oFolder:aDialogs[ 01 ]:oFont	:= oDlg:oFont

oTree	:= dbTree():New( 02, 02, ( ( nBottom - nTop ) / 02 ) - 24, 159, oFolder:aDialogs[ 01 ],,, .T. )
oTree:bChange := {|| MTConsDlgV( @oTree, aSValias, @aEnch,{ 00, 00, ( ( nBottom - nTop ) / 02 ) - 24, ( nRight - nLeft ) / 02 - 160 }, @nOldEnch, @oPanel, aTotais ), Eval( bChange ) }
oTree:SetFont( oFont )

oPanel := TPanel():New( 02, 160, "", oFolder:aDialogs[ 01 ], oDlg:oFont, .T., .T.,,, ( nRight - nLeft ) / 02 - 160, ( ( nBottom - nTop ) / 02 ) - 25, .T., .T. )

U_MTConsTree( @oTree, aTotais, "", .F. )

lOneColumn := Iif( ( nRight - nLeft ) / 02 - 178 > 312, .F., .T. )

aTela	:= {}
aGets	:= {}

aEnch[ 01 ]	:= MsMGet():New( "PA9", PA9->( Recno() ), 02,,,,, { 00, 00, ( ( nBottom - nTop ) / 02 ) - 25, ( nRight - nLeft ) / 02 - 160 },, 03,,,, oPanel,,, lOneColumn )

Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {||oDlg:End()}, {||oDlg:End()},, aButtons )

Release Object oTree

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MtConsDlgV ³ Autor ³ Celso Costa          ³ Data ³19/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta consulta                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MtConsDlgV()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MtConsDlgV( oTree, aSVAlias, aEnch, aPos, nOldEnch, oPanel, aTotais )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aDados		:= {}
Local aArea			:= GetArea()
Local cAlias		:= SubStr( oTree:GetCargo(), 01, 03 )
Local nRecView		:= Val( SubStr( oTree:GetCargo(), 04, 12 ) )
Local nPosAlias	:= aScan( aSVAlias, cAlias )
Local nPostotais	:= Ascan( aTotais, {|x| x[ 01 ] == SubStr( oTree:GetCargo(), 01, 03 ) } )
Local lOneColumn	:= Iif( aPos[ 04 ] - aPos[ 02 ] > 312, .F., .T. )
Local oScroll

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta consulta                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecView != 00

	dbSelectArea( cAlias )
	MsGoto( nRecView )
	aEnch[ nOldEnch ]:Hide()
	RegToMemory( cAlias, .F. )

	If nPosAlias > 00

		Do Case
		
			Case cAlias == "PA9"
				aEnch[ 01 ]:EnchRefreshAll()
				aEnch[ 01 ]:Show()
				nOldEnch := 01     
				
			Case cAlias == "PAA"
				aEnch[ 02 ]:EnchRefreshAll()
				aEnch[ 02 ]:Show()
				nOldEnch := 02     
		
		EndCase

	Else

		aTela	:= {}
		aGets	:= {}

		oPanel:Hide()

		Do Case

			Case cAlias == "PA9"
				aAdd( aSVAlias, "PA9" )
				aEnch[ 01 ]	:= MsMGet():New( "PA9", PA9->( Recno() ), 02,,,,, aPos,, 03,,,, oPanel,,, lOneColumn )
				aEnch[ 01 ]:EnchRefreshAll()
				nOldEnch	:= 01

			Case cAlias == "PAA"
				aAdd( aSVAlias, "PAA" )
				aEnch[ 02 ]	:= MsMGet():New( "PAA", PAA->(Recno() ), 02,,,,, aPos,, 03,,,, oPanel,,, lOneColumn )
				aEnch[ 02 ]:EnchRefreshAll()
				nOldEnch	:= 02

		EndCase

		oPanel:Show()

	EndIf

Else

	aEnch[nOldEnch]:Hide()
	
	If nPosTotais > 00

		Do Case

			Case cAlias == "PA9"
				Aadd( aDados, { "", "" } )
				Aadd( aDados, { OemToAnsi( STR0138 ), StrZero( _nOrdens, 02 ) } )
				Aadd( aDados, { OemToAnsi( STR0139 ), _cHoras } )
				ADScrDCons( aDados, @oScroll, @oPanel, aPos, { { 01, CLR_BLUE } } )
		
		EndCase
		
		aEnch[ 03 ] := oScroll
		aEnch[ 03 ]:Show()

		nOldEnch := 03				

	Else

		If _nOrdens > 00
			Aadd( aDados, { "", "" } )
				Aadd( aDados, { OemToAnsi( STR0138 ), StrZero( _nOrdens, 02 ) } )
				Aadd( aDados, { OemToAnsi( STR0139 ), _cHoras } )
		Else
			Aadd( aDados, { OemToAnsi( STR0140 ) } )
			Aadd( aDados, { "" } )
		EndIf
				
		ADScrDCons( aDados, @oScroll, @oPanel, aPos, { { 01, CLR_BLUE } } )

		aEnch[03] := oScroll
		aEnch[03]:Show()

		nOldEnch := 03				

	EndIf

EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ADScrDCons ³ Autor ³ Celso Costa          ³ Data ³19/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta consulta - SCROLL                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ADScrDCons()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ADScrDCons( aInfo, oScroll, oPanel, aPos, aCoresCols )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nX
Local ny
Local nAchou
Local cCor
Local oBmp
Local nCols			:= 01
Local nSomaCols	:= 00
Local nLinAtu		:= 05
Local nColAtu		:= 30
Local cCorDefault	:= CLR_BLACK

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default aCoresCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define FONT oFont NAME "Arial" Size 00, -11 BOLD

If Len( aInfo ) > 00

	oScroll	:= TScrollBox():New( oPanel, aPos[ 01 ], aPos[ 02 ], aPos[ 03 ], aPos[ 04 ] )

	@ 00, 00 BitMap oBmp RESNAME "LOGIN" Of oScroll Size 45, aPos[ 03 ] ADJUST NOBORDER When .F. Pixel

	nCols	:= Len( aInfo[ 01 ] )

	For nx := 01 To Len( aInfo )

		For ny := 01 To nCols

			If CalcFieldSize( "C", Len( aInfo[ nx, ny ] ), 00 ) > nSomaCols
				nSomaCols := CalcFieldSize( "C", Len( aInfo[ nx, ny ] ), 00 )
			EndIf	

		Next ny

	Next

	For nx := 01 To Len( aInfo )

		For ny := 01 To nCols

			nAchou	:= Ascan( aCoresCols, {|x| x[ 01 ] == ny} )
			cCor		:= Iif( nAchou > 00, aCoresCols[ nAchou, 02 ], cCorDefault )
			cTextSay	:= "{||' " + StrTran( aInfo[ nx ][ ny ], "'", '"' ) + " '}"
			oSay		:= TSay():New( nLinAtu, nColAtu, MontaBlock( cTextSay ), oScroll,, oFont,,,, .T., cCor,,,,,,,, )
			nColAtu	+= nSomaCols

		Next ny

		nLinAtu	+= 09
		nColAtu	:= 30

	Next

EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MTConsTree ³ Autor ³ Celso Costa          ³ Data ³19/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Tree de consulta                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MtConsTree()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MTConsTree( oTree, aTotais, cAlias, lTodos )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea		:= GetArea()
Local _cOldCargo	:= oTree:GetCargo()
Local _cQuery		:= ""
Local _cCor			:= ""
Local _nHrAux		:= 00
Local _nMnAux		:= 00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Default                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cAlias		:= ""
Default lTodos		:= .F.

U_ADINF009P('ADCHHIST' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Tree - CHAMADOS')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tree - primeira passagem                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nOrdens := 00
_cHoras	:= ""

If Empty( cAlias ) .And. !lTodos
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
Else
	Return ( Nil )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tree - Chamado                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree:BeginUpdate()

oTree:TreeSeek( "" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona ordens de servico                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT PAA.*, R_E_C_N_O_ AS RECNO "
_cQuery += "FROM " + RetSqlName( "PAA" ) + " PAA "
_cQuery += "WHERE PAA_CHAMAD = '" + PA9->PA9_CODIGO + "' "
_cQuery += "AND PAA_FILIAL = '" + xFilial( "PAA" ) + "' "
_cQuery += "AND D_E_L_E_T_ = '' "
_cQuery += "ORDER BY PAA_CODIGO, PAA_DTINI, PAA_HRINI"

_cQuery := ChangeQuery( _cQuery )

dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "OS", .F., .T. )

TcSetField( "OS", "PAA_DTINI"		, "D", 08, 00 )
TcSetField( "OS", "PAA_FIM"		, "D", 08, 00 )
TcSetField( "OS", "PAA_DTPREV"	, "D", 08, 00 )

dbSelectArea( "OS" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tree - Primeiro Nivel                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree:AddItem( OemToAnsi( STR0044 ) + " " + PA9->PA9_CODIGO + Space( 24 ), "PA9" + StrZero( PA9->( Recno() ), 12 ), "FOLDER5", "FOLDER6",,, 01 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tree - Segundo Nivel                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree:TreeSeek( "CH" + PA9->PA9_CODIGO )
oTree:AddItem( OemToAnsi( STR0025 ) + Space( 30 ), "PA9OS" + PA9->PA9_CODIGO, "FOLDER5", "FOLDER6",,, 02 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tree - Terceiro Nivel                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree:TreeSeek( "PA9OS" + PA9->PA9_CODIGO )

While OS->( !Eof() )

	Do Case
		Case OS->PAA_DTINI > Date() .And. Empty( OS->PAA_FIM )
			_cCor := "BR_VERDE"
		Case !Empty( OS->PAA_DTINI ) .And. Empty( OS->PAA_FIM ) .And. OS->PAA_DTINI <= OS->PAA_DTPREV
			_cCor := "BR_AZUL"
		Case !Empty( OS->PAA_DTINI ) .And. Empty( OS->PAA_FIM ) .And. OS->PAA_DTINI > OS->PAA_DTPREV
			_cCor := "BR_AMARELO"
		Case !Empty( OS->PAA_FIM ) .And. Empty( OS->PAA_ACEITE )
			_cCor := "BR_PRETO"
		Case !Empty( OS->PAA_FIM ) .And. !Empty( OS->PAA_ACEITE )
			_cCor := "BR_VERMELHO"
	EndCase
	
	If OS->PAA_CHAMAD == PA9->PA9_CODIGO
		oTree:AddItem( OS->PAA_CODIGO + " - " + OS->PAA_DSTIPO, "PAA" + StrZero( OS->RECNO, 12 ), _cCor, _cCor,,, 02 )
	EndIf
		
	_nOrdens += 01
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula horas consumidas                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nHrAux := Val( SubStr( OS->PAA_HRSUTL, 01, 02 ) ) + Val( SubStr( _cHoras, 01, 02 ) )
	_nMnAux := Val( SubStr( _cHoras, 04, 02 ) ) + Val( SubStr( OS->PAA_HRSUTL, 04, 02 ) )
	
	While _nMnAux > 60

		If _nMnAux >= 60
			_nMnAux -= 60
			_nHrAux += 01
		EndIf
		
	EndDo
	
	_cHoras := StrZero( _nHrAux, 02 ) + ":" + StrZero( _nMnAux, 02 )
	
	OS->( dbSkip() )
	
EndDo

OS->( dbCloseArea() )

oTree:TreeSeek( "" )
oTree:EndUpdate()
oTree:Refresh()

If lTodos
	oTree:TreeSeek( _cOldCargo )
EndIf

RestArea( _aArea )

Return ( Nil )