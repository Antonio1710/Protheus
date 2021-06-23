#Include "Protheus.CH"
#Include "Chamado.CH"     
#include "topconn.ch" 
#include 'shell.ch'  

#Define CRLF  Chr( 13 ) + Chr( 10 )

/*/{Protheus.doc} User Function ADCH004
	Manutencao de Chamados - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	@history Chamado TI - Fernando Sigoli - 11/04/2019 - Remover envio de email 
	@history Chamado TI - William Costa   - 28/01/2020 - Adicionado espaço no email de Ciencia de Chamado
	@history Chamado TI - ADRIANO SAVOINE - 28/08/2020 - Adicionado a mensagem para o usuario utilizar o novo sistema de chamado e e seguida o novo acesso apartir da mesma tela clicando em sim é direcionado para a URL ou em nao permanece na tela antiga.
/*/

User Function ADCH004()

	Private cCadastro	:= OemToAnsi( STR0024 )

	Private _aCores	:=	{	{ "Empty( PA9_OS ) .And. PA9_DTLIM >= dDataBase .And. PA9_DTPREV >= dDataBase .And. Empty( PA9_DTFIM )"	, "BR_VERDE"	},;
							{ "!Empty( PA9_OS ) .And. Empty( PA9_DTFIM ) .And. Empty( PA9_TPENCE )"									, "BR_AZUL"		},;
							{ "!Empty( PA9_TPENCE ) .And. Empty( PA9_DTFIM ) .And. PA9_TPENCE == '5'"								, "BR_PINK"		},;								
							{ "!Empty( PA9_DTFIM ) .And. !Empty( PA9_OS )"															, "BR_VERMELHO"	},;
							{ "Empty( PA9_OS ) .And. !Empty( PA9_DTFIM )"															, "BR_PRETO"	},;
							{ "!Empty( PA9_TPENCE ) .And. Empty( PA9_DTFIM ) .And. PA9_TPENCE != '5'"								, "BR_BRANCO"	},;
							{ "Empty( PA9_OS ) .And. PA9_DTLIM >= dDataBase .And. PA9_DTPREV < dDataBase .And. Empty( PA9_DTFIM )"	, "BR_LARANJA"	} }

	Private aRotina	:= {	{ OemToAnsi( STR0002 ), "AxPesqui"		, 00, 01 },;
									{ OemToAnsi( STR0003 ), "AxVisual"		, 00, 02 }}
									/*{ OemToAnsi( STR0004 ), "U_MntChm"		, 00, 03 },;
									{ OemToAnsi( STR0005 ), "U_AltChm"		, 00, 04 },;
									{ OemToAnsi( STR0034 ), "U_CancChm"		, 00, 05 },;
									{ OemToAnsi( STR0027 ), "U_VisualOS"	, 00, 06 },;
									{ OemToAnsi( STR0054 ), "U_AltPrior"	, 00, 07 },;
									{ OemToAnsi( STR0099 ), "U_AlteOS"		, 00, 08 },;
									{ OemToAnsi( STR0007 ), "U_LegChm"		, 00, 09 },;
									{ OemToAnsi( STR0136 ), "U_ADCHHist"	, 00, 10 },;
									{ OemToAnsi( STR0146 ), "U_ADCHStat"	, 00, 11 } }*/

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	dbSelectArea( "PA9" )
	dbSetOrder( 01 )

	MsgInfo("Apartir de 31/08/2020 todos os chamados deverão ser abertos pelo novo sistema de chamados via Browser pelo link abaixo:<br /><br /> https://atendimento.adoro.com.br","Atenção !!!")

	IF MsgYesNo("Deseja ir para pagina de Chamado Nova agora?", "Ajuda?")
			u_Movi()
			Else
			mBrowse( 06, 01, 22, 75, "PA9",,,, "Empty( PA9->PA9_DTFIM )",, _aCores )
	EndIf
	

	

Return ( Nil )

/*/{Protheus.doc} User Function MntChm
	Manutencao de Chamados - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
/*/

User Function MntChm()

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	AxInclui( "PA9", PA9->( Recno() ), 03,,,, "U_ADCHOK()",, "U_AtuServico()" )

Return ( Nil )

/*/{Protheus.doc} User Function AltChm
	Manutencao de Chamados - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
/*/

User Function AltChm()

	Local cQuery:= ""
	Local _lTec := .f.

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	//a.Incluido para permitir que os tecnicos possam alterar a classificacao do chamado por Adriana em 22/06/2016
	cQuery := "SELECT AA1_CODTEC "
	cQuery += "FROM "+RetSqlName("AA1")+ " "
	cQuery += "WHERE AA1_CODUSR = '"+__cUserID+"' "
	cQuery += "AND D_E_L_E_T_ = ''  "

	TCQUERY cQuery new alias "TRB01"

	DBSELECTAREA("TRB01")
	DBGOTOP()

	If !TRB01->(EOF())
		_lTec := .T.
	Endif

	DBCLOSEAREA()
	//a.Fim

	If !Empty( PA9->PA9_DTFIM )
		U_OSMsg( STR0013, STR0035 )        
		Return ( Nil )
	ElseIf !Empty( PA9->PA9_OS )
		U_OSMsg( STR0013, STR0037 + AllTrim( PA9->PA9_OS ) )
		Return ( Nil )                                                                   
	ElseIf AllTrim( Upper( PA9->PA9_USUARI ) ) != AllTrim( Upper( SubStr( U_ADCHUsr( 04 ), 01, len( PA9->PA9_USUARI ) ) ) ) .and. !(_lTec) 
	//ElseIf AllTrim( Upper( PA9->PA9_USUARI ) ) != AllTrim( Upper( SubStr( U_ADCHUsr( 04 ), 01, len( PA9->PA9_USUARI ) ) ) )
		//incluida verificacao tecnico por Adriana em 22/06/2016
		U_OSMsg( STR0013, STR0038 + AllTrim( Upper( U_ADCHUsr( 04 ) ) ) + " " + STR0039 + PA9->PA9_CODIGO )
		Return ( Nil )
	EndIf

	AxAltera( "PA9", PA9->( Recno() ), 04,,,,, "U_CHAltOK()" )

Return ( Nil )

/*/{Protheus.doc} User Function ADCHLeg
	Manutencao de Chamados - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
/*/

User Function ADCHUsr( _nTipo )

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

Return ( PswRet( 01 )[ 01 ][ _nTipo ] )

/*/{Protheus.doc} User Function DCHDtPrev
	Retorna data prevista para resposta do chamado 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function ADCHDtPrev()

	Local _aArea		:= GetArea()

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	// Incluido em 13/04/2011 por Alex Borges        
	M->PA9_DTPREV := dDataBase + 7

	SysRefresh()

	RestArea( _aArea )

Return ( .T. )

/*/{Protheus.doc} User Function ADCHOK
	TudoOK - Manutencao de Chamados
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function ADCHOK()

	Local _lRet		:= .T.

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	If INCLUI
		M->PA9_VERSAO	:= "01"
	EndIf

Return ( _lRet )

/*/{Protheus.doc} User Function AtuServico
	Atualizacoes de ordens de servico
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function AtuServico()

	Local _aArea		:= GetArea()
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cAssunto	:= ""
	Local _cBody		:= ""
	Local _cTo			:= ""
	Local _cData		:= SubStr( DtoS( M->PA9_DTPREV ), 07, 02 ) + "/" + SubStr( DtoS( M->PA9_DTPREV ), 05, 02 ) + "/" + SubStr( DtoS( M->PA9_DTPREV ), 01, 04 )
	Local _cCC			:= AllTrim( Lower( M->PA9_CCOPIA ) )
	Local _cResp		:= ""
	Local _cTecnico	:= ""
	Local _ceMResp		:= ""

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	If !INCLUI
		Return ( Nil )
	EndIf

	// Email - CHAMADO INCLUIDO (destino usuario)                   ?

	_cAssunto	:= Upper( OemToAnsi( STR0044 ) ) + " " + M->PA9_CODIGO
	_cBody		:= "<Htm><br>" + CRLF
	_cBody		+= OemToAnsi( STR0113 ) + AllTrim( M->PA9_CODIGO ) + OemToAnsi( STR0114 ) + ". <br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0150 ) + " " + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME) ) + "<br>" + CRLF 
	_cBody		+= OemToAnsi( STR0167 ) + " " + AllTrim( M->PA9_CCDESC )+ "<br>" + CRLF 
	_cBody		+= OemToAnsi( STR0168 ) + " " + AllTrim( M->PA9_RAMAL ) + "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0153 ) + " " + AllTrim( M->PA9_DGRUPO ) + "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0154 ) + " " + AllTrim( M->PA9_DSGRUP ) + "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0155 ) + " " + AllTrim( M->PA9_DSERVI ) + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0162 ) + "<br>" + CRLF
	nLinhasMemo := MLCOUNT(M->PA9_ESCOPO,80)
	For LinhaCorrente := 1 To nLinhasMemo       
		_cBody	+= MemoLine(M->PA9_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF	
	Next

	_cBody		+= "<br>" + CRLF
	_cBody		+= "</Htm>"

	If !Empty( M->PA9_MAILUS )
		MsAguarde({|| U_CHEnviaMail( _cFrom, AllTrim( M->PA9_MAILUS ), _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0070 ), .F. )
	EndIf

	//Email - CHAMADO INCLUIDO (destino especialista)

	dbSelectArea( "PA6" )
	dbSetOrder( 01 )

	If dbSeek( xFilial( "PA6" ) + M->PA9_GRUPO + M->PA9_SGRUPO + M->PA9_SERVIC )

		dbSelectArea( "AA1" )
		dbSetOrder( 01 )

		If dbSeek( xFilial( "AA1" ) + PA6->PA6_RESP )
			_cTo		+= Iif( !Empty( _cTo ), ";", "" ) + AllTrim( Lower( AA1->AA1_EMAIL ) )
			_cResp	:= AA1->AA1_NOMTEC
			_ceMResp	:= AllTrim( Lower( AA1->AA1_EMAIL ) )
		EndIf

		If dbSeek( xFilial( "AA1" ) + PA6->PA6_ESPE )
			_cTo			+= Iif( !Empty( _cTo ), ";", "" ) + AllTrim( Lower( AllTrim( AA1->AA1_EMAIL ) ) )
			_cTecnico	:= AA1->AA1_NOMTEC
		EndIf

		_cAssunto	:= Upper( OemToAnsi( STR0044 ) ) + " INCLUIDO " + AllTrim( M->PA9_CODIGO )
		_cBody		:= "<Htm><br>" + CRLF
		_cBody		+= OemToAnsi( STR0113 ) + AllTrim( M->PA9_CODIGO ) + OemToAnsi( STR0114 ) + ". <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0150 ) + " " + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME) ) + "<br>" + CRLF
		// INCLUIDO EM 13/04/2011 POR ALEX BORGES
		_cBody		+= OemToAnsi( STR0167 ) + " " + AllTrim( M->PA9_CCDESC )+ "<br>" + CRLF 
		_cBody		+= OemToAnsi( STR0168 ) + " " + AllTrim( M->PA9_RAMAL ) + "<br>" + CRLF
		//
		_cBody		+= OemToAnsi( STR0153 ) + " " + AllTrim( M->PA9_DGRUPO ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0154 ) + " " + AllTrim( M->PA9_DSGRUP ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0155 ) + " " + AllTrim( M->PA9_DSERVI ) + "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0162 ) + "<br>" + CRLF

		nLinhasMemo := MLCOUNT(M->PA9_ESCOPO,80)
		For LinhaCorrente := 1 To nLinhasMemo       
			_cBody	+= MemoLine(M->PA9_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF	
		Next
		_cBody		+= "<br>" + CRLF
		_cBody		+= "</Htm>"

		If !Empty( _cTo )
		MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo,, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ), .F. )
		EndIf

		If !Empty( _cCC )

			_cAssunto	:= AllTrim( Upper( OemToAnsi( STR0163 ) ) ) + " " + M->PA9_CODIGO //TI - William Costa 28/01/2020, espaco em branco na ciencia de chamado
			_cBody		:= "<Htm><br>" + CRLF
			_cBody		:= OemToAnsi( STR0156 ) + "<br>" + CRLF
			_cBody		:= OemToAnsi( STR0113 ) + AllTrim( M->PA9_CODIGO ) + OemToAnsi( STR0157 ) + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME)) + OemToAnsi( STR0158 ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		:= OemToAnsi( STR0159 ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0150 ) + " " + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME)) + "<br>" + CRLF 
			// INCLUIDO EM 13/04/2011 POR ALEX BORGES
			_cBody		+= OemToAnsi( STR0167 ) + " " + AllTrim( M->PA9_CCDESC )+ "<br>" + CRLF 
			_cBody		+= OemToAnsi( STR0168 ) + " " + AllTrim( M->PA9_RAMAL ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0153 ) + " " + AllTrim( M->PA9_DGRUPO ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0154 ) + " " + AllTrim( M->PA9_DSGRUP ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0155 ) + " " + AllTrim( M->PA9_DSERVI ) + "<br>" + CRLF
			_cBOdy		+= OemToAnsi( STR0089 ) + " " + AllTrim( _cTecnico ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0162 ) + "<br>" + CRLF

			nLinhasMemo := MLCOUNT(M->PA9_ESCOPO,80)
			For LinhaCorrente := 1 To nLinhasMemo       
				_cBody	+= MemoLine(M->PA9_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF	
			Next
			_cBody		+= "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0160 ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0161 ) + AllTrim( _cResp ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= "</Htm>"

		MsAguarde({|| U_CHEnviaMail( _cFrom, _cCC, _ceMResp, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ), .F. )

		EndIf

	EndIf

	RestArea( _aArea )

Return ( Nil )

/*/{Protheus.doc} User Function CHEnviaMail
	Envio de email
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function CHEnviaMail( _cFrom, _cTo, _cCc, _cAssunto, _cAttach, _cBody )

	Local _cAttach			:= Iif( _cAttach == Nil, "", AllTrim( _cAttach ) )
	Local _cFrom			:= Iif( _cFrom == Nil, GetMv( "MV_RELFROM" ), _cFrom )
	Local _aTo				:= { _cTo }
	Local _aCC				:= Iif( _cCc == Nil, {}, { _cCC } )
	Local _aBcc				:= {}
	Local _cSubject		:= _cAssunto
	Local _aAttach			:= {}
	Local _cMailServer	:= GetMv( "MV_RELSERV" )
	Local _cMailConta		:= GetMv( "MV_RELACNT" )
	Local _cMailSenha		:= GetMv( "MV_RELPSW" )

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	//Envia email

	If !Empty( _cAttach ) .And. !File( _cAttach )
		U_OSMsg( STR0013, STR0042 + _cAttach + STR0043 )
		Return ( Nil )
	EndIf

	aAdd( _aAttach, _cAttach )

	If MailSmtpOn( _cMailServer, _cMailConta, _cMailSenha )
		
		If !MailAuth( _cMailConta, _cMailSenha )
			U_OSMsg( STR0013, STR0040 )
			Return ( Nil )
		EndIf
		
		If !MailSend( _cFrom, _aTo, _aCc, _aBcc, _cSubject, _cBody, _aAttach, .T. )
			U_OSMsg( STR0013, STR0041 + MailGetErr() )
		EndIf
		
		lDiscSmtp := MailSmtpOff()

	EndIf

	FErase( _cAttach )

Return ( Nil )

/*/{Protheus.doc} User Function LegChm
	Legendas 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function LegChm()

	Local _nVerde, _nAzul, _nPink, _nVermelho, _nPreto, _nBranco, _nLaranja, _nTotal, _nSubt1, _nSubt2, _aLegenda

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	_cCaery := "SELECT " 
	_cCaery += "Verde    = COUNT(CASE WHEN (PA9_OS = '' OR PA9_OS IS NULL) AND PA9_DTLIM >= '" + DtoS(dDataBase) + "' AND PA9_DTPREV >= '" + DtoS(dDataBase) + "' AND (PA9_DTFIM = '' OR PA9_DTFIM IS NULL) THEN 0 END), "
	_cCaery += "Azul     = COUNT(CASE WHEN PA9_OS <> '' AND PA9_OS IS NOT NULL AND  (PA9_DTFIM = '' OR PA9_DTFIM IS NULL) AND (PA9_TPENCE = '' OR PA9_TPENCE IS NULL) THEN 0 END), "
	_cCaery += "Pink     = COUNT(CASE WHEN PA9_OS <> '' AND PA9_OS IS NOT NULL AND  (PA9_DTFIM = '' OR PA9_DTFIM IS NULL) AND (PA9_TPENCE = '5') THEN 0 END), "
	_cCaery += "Vermelho = COUNT(CASE WHEN PA9_OS <> '' AND PA9_OS IS NOT NULL AND PA9_DTFIM <> '' AND PA9_DTFIM IS NOT NULL THEN 0 END), "
	_cCaery += "Preto    = COUNT(CASE WHEN (PA9_OS = '' OR PA9_OS IS NULL) AND PA9_DTFIM <> '' AND PA9_DTFIM IS NOT NULL THEN 0 END), "
	_cCaery += "Branco   = COUNT(CASE WHEN PA9_TPENCE <> '' AND PA9_TPENCE IS NOT NULL AND (PA9_DTFIM = '' OR PA9_DTFIM IS NULL) AND PA9_TPENCE <> '5' THEN 0 END), "
	_cCaery += "Laranja  = COUNT(CASE WHEN (PA9_OS = '' OR PA9_OS IS NULL) AND PA9_DTLIM >= '" + DtoS(dDataBase) + "' AND PA9_DTPREV < '" + DtoS(dDataBase) + "' AND (PA9_DTFIM = '' OR PA9_DTFIM IS NULL) THEN 0 END) "
	_cCaery += "FROM "+RetSqlName("PA9")+ " WITH(NOLOCK) WHERE D_E_L_E_T_ <> '*' "
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cCaery ), "CRYTIE", .F., .T. )
	dbSelectArea( "CRYTIE" )
	While CRYTIE->( !Eof() )
		_nVerde    := CRYTIE->Verde
		_nAzul     := CRYTIE->Azul
		_nPink     := CRYTIE->Pink
		_nVermelho := CRYTIE->Vermelho
		_nPreto    := CRYTIE->Preto
		_nBranco   := CRYTIE->Branco
		_nLaranja  := CRYTIE->Laranja
		CRYTIE->( dbSkip() )
	EndDo
	CRYTIE->( dbCloseArea() )

	_nSubt1 := _nVerde + _nAzul + _nPink + _nBranco + _nLaranja
	_nSubt2 := _nVermelho + _nPreto
	_nTotal := _nVerde + _nAzul + _nPink + _nVermelho + _nPreto + _nBranco + _nLaranja

	_aLegenda	:= {	{ "BR_VERDE"		, OemToAnsi( STR0028 ) + Space(16) + Transform(_nVerde, "@E ##9,999") },;
						{ "BR_AZUL"			, OemToAnsi( STR0029 ) + Space(07) + Transform(_nAzul , "@E ##9,999") },;
						{ "BR_PRETO"		, OemToAnsi( STR0031 ) + Space(15) + Transform(_nPreto, "@E ##9,999") },;
						{ "BR_VERMELHO"		, OemToAnsi( STR0032 ) + Space(14) + Transform(_nVermelho, "@E ##9,999") },;
						{ "BR_PINK"			, OemToAnsi( STR0115 ) + Space(16) + Transform(_nPink,  "@E ##9,999") },;
						{ "BR_BRANCO"		, OemToAnsi( STR0111 ) + Space(04) + Transform(_nBranco, "@E ##9,999") },;
						{ "BR_LARANJA"		, OemToAnsi( STR0169 ) + Space(05) + Transform(_nLaranja, "@E ##9,999") },;
						{ ""				, "___________________________________________________" },;
						{ ""				, "Total em Aberto   " + Space(06) + Transform(_nSubt1, "@E ##9,999") },;
						{ ""				, "Total Encerrados                                   " },;
						{ ""				, "       Cancelados " + Space(06) + Transform(_nSubt2, "@E ##9,999") },;
						{ ""				, "______________________________________________" },;
						{ ""				, Space(19) + "Total " + Space(6) + Transform(_nTotal, "@E ##9,999") } }


	//Legenda                                                      

	BrwLegenda( OemToAnsi( STR0007 ), OemToAnsi( STR0023 ), _aLegenda )

Return ( Nil )

/*/{Protheus.doc} User Function CancChm
	Cancelamento de chamados 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function CancChm()

	Local _aArea	:= GetArea()

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	If !Empty( PA9->PA9_DTFIM )
		U_OSMsg( STR0013, STR0035 )
		Return ( Nil )
	EndIf

	If !Empty( PA9->PA9_OS )
		U_OSMsg( STR0013,"Cancelamento n? permitido, j?existe OS para este chamado." )
		Return ( Nil )
	EndIf

	If AxVisual( "PA9", PA9->( Recno() ), 02 ) == 01
		
		If !Empty( PA9->PA9_OS )

			dbSelectArea( "PAA" )
			dbSetOrder( 01 )
			
			If dbSeek( xFilial( "PAA" ) +  PA9->PA9_OS )

				RecLock( "PAA", .F. )	
				PAA->PAA_FIM		:= Date()
				PAA->PAA_HRFIM		:= Time()         
				PAA->PAA_TPENCE	:= "4"
				PAA->PAA_ACEITE	:= "1"
				PAA->PAA_USRACT	:= U_ADCHUsr( 04 )
				PAA->PAA_DTACT		:= Date()
				PAA->PAA_HRACT		:= Time()     
				PAA->( MsUnLock() )

		EndIf
		
		EndIf
		
		RecLock( "PA9", .F. )	
		PA9->PA9_DTFIM		:= Date()
		PA9->PA9_TPENCE	:= "4"
		PA9->( MsUnLock() )
		
	EndIf

Return ( Nil )

/*/{Protheus.doc} User Function AltPrior
	Altera prioridade dos chamados 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function AltPrior()

	Local oDlg
	Local oCombo
	Local _nOpca		:= 00
	Local _aCombo		:= {}
	Local _cPrior		:= PA9->PA9_PRIOR
	Local _cPriorAux	:= PA9->PA9_PRIOR

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	If !Empty( PA9->PA9_DTFIM )
		U_OSMsg( STR0013, STR0044 + " " + AllTrim( PA9->PA9_CODIGO ) + Iif( Val( PA9->PA9_TPENCE ) <= 02, " concluido", " cancelado" ) + STR0045 )
		Return ( Nil )
	EndIf

	aAdd( _aCombo, "1 = Alta Prioridade - Sistema Parado" )
	aAdd( _aCombo, "2 = Media Necessidade - Sistema em Funcionamento" )
	aAdd( _aCombo, "3 = Baixa - Necessidade Eventual" )
	
	Define MsDialog oDlg Title OemToAnsi( STR0046 ) From 05, 00 To 20, 70

	@ 020, 05 Say OemToAnsi( STR0047 )	Size 280, 10 Pixel Of oDlg
	@ 030, 05 Say OemToAnsi( STR0048 )	Size 280, 10 Pixel Of oDlg
	@ 040, 05 Say OemToAnsi( STR0049 ) + StrZero( Day( dDataBase ) * Val( SubStr( Time(), 04, 02 ) ) + Val( SubStr( Time(), 01, 02 ) ) + Val( SubStr( Time(), 07, 02 ) ), 06 ) + OemToAnsi( STR0051 ) + AllTrim( U_ADCHUsr( 04 ) ) Size 180, 10 Pixel Of oDlg
	@ 060, 05 Say OemToAnsi( STR0050 ) + _aCombo[ Val( PA9->PA9_PRIOR ) ] Size 180,10 Pixel Of oDlg
	@ 070, 05 Say RetTitle( "PA9_PRIOR" ) + ":" Size 080, 10 Pixel Of oDlg

	@ 070, 50 ComboBox oCombo Var _cPrior Items _aCombo Size 180, 10 Pixel Of oDlg

	@ 080, 05 Say RetTitle( "PA9_CODIGO" ) + ": " + AllTrim( PA9->PA9_CODIGO )											Size 090, 10 Pixel Of oDlg
	@ 090, 05 Say OemToAnsi( STR0052 ) + AllTrim( PA9->PA9_UNIDAD ) + " - " + AllTrim( PA9->PA9_DUNID )	Size 150, 10 Pixel Of oDlg
	@ 100, 05 Say OemToAnsi( STR0053 ) + AllTrim( PA9->PA9_CC ) + " - " + AllTrim( PA9->PA9_CCDESC )		Size 150, 10 Pixel Of oDlg

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {||_nOpca := 01, oDlg:End() },{||_nOpca := 00, oDlg:End()} ) Centered

	If ( _nOpcA == 01 )             
		RecLock( "PA9", .F. )
		PA9->PA9_PRIOR		:= _cPrior
		PA9->PA9_LIERAD	:= AllTrim( U_ADCHUsr( 04 ) )
		PA9->PA9_DTALTE	:= Date()
		PA9->PA9_HSALTE	:= Time()
		PA9->( MsUnLock() )

		If _cPriorAux != _cPrior
			MailPrior( _aCombo[ Val( _cPriorAux ) ], _aCombo[ Val( _cPrior ) ] )
		EndIf
		
	EndIf           

Return( Nil )

/*/{Protheus.doc} Static Function MailPrior
	Envia email comunicando alteracao de prioridade
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

Static Function MailPrior( _cDe, _cPara )

	Local _aArea		:= GetArea()
	Local _cAssunto	:= OemToAnsi( STR0044 ) + AllTrim( PA9->PA9_CODIGO ) + OemToAnsi( STR0059 )
	Local _cBody		:= ""
	Local _cFrom		:= GetMv( "MV_RELFROM" )
	Local _cTo			:= AllTrim( PA9->PA9_MAILUS )
	Local _cCC			:= AllTrim( PA9->PA9_CCOPIA )
	Local _cData		:= SubStr( DtoS( Date() ), 07, 02 ) + "/" + SubStr( DtoS( Date() ), 05, 02 ) + "/" + SubStr( DtoS( Date() ), 01, 04 )

	_cBody	:= "<Htm><br>" + CRLF
	_cBody	+= OemToAnsi( STR0060 ) + AllTrim( IIF(EMPTY(PA9->PA9_SOLICI),PA9->PA9_USUARI, PA9->PA9_NOME) ) + ",<br>" + CRLF

	If !Empty( PA9->PA9_OS )
		_cBody	+= OemToAnsi( STR0061 ) + AllTrim( PA9->PA9_OS ) + OemToAnsi( STR0062 ) + AllTrim( PA9->PA9_CODIGO ) + OemToAnsi( STR0063 )	 + "<br>" + CRLF

		dbSelectArea( "PAA" )
		dbSetOrder( 01 )
		
		If dbSeek( xFilial( "PAA" ) + PA9->PA9_OS )

			_cBody += OemToAnsi( STR0065 ) + AllTrim( PAA->PAA_NOMTEC ) + " em " + _cData + ". <br>" + CRLF

			dbSelectArea( "AA1" )
			dbSetOrder( 01 )

			If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
				_cTo += Iif( !Empty( _cTo ), "; ", "" ) + Iif( !Empty( AA1->AA1_EMAIL ), AllTrim( AA1->AA1_EMAIL ), "" )
			EndIf
			
		EndIf
			
	Else
		_cBody	+= OemToAnsi( STR0064 ) + AllTrim( PA9->PA9_CODIGO ) + OemToAnsi( STR0063 ) + " em " + _cData + ". <br>" + CRLF
	EndIf

	_cBody	+= "<br>" + CRLF
	_cBody	+= OemToAnsi( STR0066 ) + "<br>" + CRLF
	_cBody	+= "de: " + _cDe + "<br>" + CRLF
	_cBody	+= "para: " + _cPara + "<br>" + CRLF
	_cBody	+= "<br>" + CRLF
	_cBody	+= "<br>" + CRLF
	_cBody	+= OemToAnsi( STR0067 )
	_cBody	+= "<br>" + CRLF
	_cBody	+= OemToAnsi( STR0068 )
	_cBody	+= "</Htm>"

	If !Empty( _cTo )
		MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo, _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ) + OemToAnsi( STR0072 ), .F. )
	EndIf

	RestArea( _aArea )'

Return ( Nil )

/*/{Protheus.doc} User Function CHAltOK
	Validacoes de alteracao 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function CHAltOK()

	Local _aArea		:= GetArea()
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cAssunto	:= ""
	Local _cBody		:= ""
	Local _cTo			:= ""
	Local _cData		:= SubStr( DtoS( M->PA9_DTPREV ), 07, 02 ) + "/" + SubStr( DtoS( M->PA9_DTPREV ), 05, 02 ) + "/" + SubStr( DtoS( M->PA9_DTPREV ), 01, 04 )

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')
		
	If ALTERA

		M->PA9_USRALT	:= AllTrim( Upper( U_ADCHUsr( 04 ) ) )
		M->PA9_DTALT	:= Date()
		M->PA9_HRALT	:= Time()
		M->PA9_VERSAO	:= Iif( !Empty( M->PA9_VERSAO ), RetAsc( ( Val( M->PA9_VERSAO ) + 01 ), 02, .T. ), "01"  )
		M->PA9_HIST		+= Iif( !Empty( M->PA9_HIST ), Chr( 10 ), "" ) + "O.S. Versao " + PA9->PA9_VERSAO + CRLF + AllTrim( PA9->PA9_ESCOPO )

		//Email - CHAMADO ALTERADO (destino usuario)                   
		
		_cAssunto	:= Upper( OemToAnsi( STR0044 ) ) + " " + M->PA9_CODIGO
		_cBody		:= "<Htm><br>" + CRLF
		_cBody		+= OemToAnsi( STR0113 ) + AllTrim( M->PA9_CODIGO ) + OemToAnsi( STR0144 ) + _cData + ". <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0150 ) + " " + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME) ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0153 ) + " " + AllTrim( M->PA9_DGRUPO ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0154 ) + " " + AllTrim( M->PA9_DSGRUP ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0155 ) + " " + AllTrim( M->PA9_DSERVI ) + "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0162 ) + "<br>" + CRLF

		nLinhasMemo := MLCOUNT(M->PA9_ESCOPO,80)
		For LinhaCorrente := 1 To nLinhasMemo       
			_cBody	+= MemoLine(M->PA9_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF	
		Next

		_cBody		+= "<br>" + CRLF
		_cBody		+= "</Htm>"

		If !Empty( M->PA9_MAILUS )
			MsAguarde({|| U_CHEnviaMail( _cFrom, AllTrim( M->PA9_MAILUS ), AllTrim( M->PA9_CCOPIA ), _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0070 ), .F. )
		EndIf

		//Email - CHAMADO INCLUIDO (destino especialista)              
		
		dbSelectArea( "PA6" )
		dbSetOrder( 01 )

		If dbSeek( xFilial( "PA6" ) + M->PA9_GRUPO + M->PA9_SGRUPO + M->PA9_SERVIC )

			dbSelectArea( "AA1" )
			dbSetOrder( 01 )

			If dbSeek( xFilial( "AA1" ) + PA6->PA6_RESP )
				_cTo += Iif( !Empty( _cTo ), ";", "" ) + AllTrim( AA1->AA1_EMAIL )
			EndIf

			If dbSeek( xFilial( "AA1" ) + PA6->PA6_ESPE )
				_cTo += Iif( !Empty( _cTo ), ";", "" ) + AllTrim( AA1->AA1_EMAIL )
			EndIf

			_cAssunto	:= Upper( OemToAnsi( STR0044 ) ) + " " + AllTrim( M->PA9_CODIGO )
			_cBody		:= "<Htm><br>" + CRLF
			_cBody		+= OemToAnsi( STR0113 ) + AllTrim( M->PA9_CODIGO ) + OemToAnsi( STR0144 ) + _cData + ". <br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0150 ) + " " + AllTrim( IIF(EMPTY(M->PA9_SOLICI),M->PA9_USUARI, M->PA9_NOME) ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0153 ) + " " + AllTrim( M->PA9_DGRUPO ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0154 ) + " " + AllTrim( M->PA9_DSGRUP ) + "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0155 ) + " " + AllTrim( M->PA9_DSERVI ) + "<br>" + CRLF
			_cBody		+= "<br>" + CRLF
			_cBody		+= OemToAnsi( STR0162 ) + "<br>" + CRLF
	//		_cBody		+= AllTrim( M->PA9_ESCOPO ) + "<br>" + CRLF
			nLinhasMemo := MLCOUNT(M->PA9_ESCOPO,80)
			For LinhaCorrente := 1 To nLinhasMemo       
				_cBody	+= MemoLine(M->PA9_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF	
			Next
			_cBody		+= "<br>" + CRLF
			_cBody		+= "</Htm>"

			If !Empty( _cTo )
		MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo,, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ), .F. )
			EndIf

		EndIf

	EndIf

	RestArea( _aArea )

Return ( .T. )

/*/{Protheus.doc} User Function VldAct
	Validacao do tipo de aceite do chamado 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function VldAct()

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	M->PAA_USRACT	:= AllTrim( Upper( U_ADCHUsr( 04 ) ) )
	M->PAA_DTACT	:= Date()
	M->PAA_HRACT	:= Time()

	SysRefresh()

Return ( .T. )

/*/{Protheus.doc} User Function VisualOS
	Visualiza Ordem de Servico 
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function VisualOS()

	Local _aArea	:= GetArea()

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	If Empty( PA9->PA9_OS )
		U_OSMsg( STR0013, STR0106 )
		Return ( Nil )
	EndIf
		
	dbSelectArea( "PAA" )
	dbSetOrder( 01 )

	If dbSeek( xFilial( "PAA" ) + PA9->PA9_OS )

		//Visualiza a ordem de servico
		
		AxVisual( "PAA", PAA->( Recno() ), 02 )

	Else
		U_OSMsg( STR0013, STR0107 )
	EndIf

	RestArea( _aArea )

Return ( Nil )

/*/{Protheus.doc} User Function EncCHAuto
	Encerra automaticamente os chamados aguardando aceite a mais de 5 dias  
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function EncCHAuto()

	Local _aArea		:= GetArea()
	Local _cQuery 		:= ""
	Local _cData		:= ""
	Local _cDataFim	:= ""
	Local _cHoraFim	:= ""
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cTo			:= ""
	Local _cCC			:= ""

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	//Seleciona registros para encerramento automatico             

	_cQuery := "SELECT PAA.R_E_C_N_O_ AS PAAREC, PA9.R_E_C_N_O_ AS PA9REC "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "PA9" ) + " PA9, "
	_cQuery += RetSqlName( "PAA" ) + " PAA "
	_cQuery += "WHERE PA9.PA9_TPENCE <> '' "
	_cQuery += "AND PA9.PA9_DTFIM = '' "
	_cQuery += "AND PA9.PA9_TPENCE <> '5' "
	_cQuery += "AND PA9.D_E_L_E_T_ = '' "
	_cQuery += "AND PAA.PAA_CODIGO = PA9.PA9_OS "
	_cQuery += "AND PAA_FIM <> '' "
	_cQuery += "AND PAA_FIM < '" + DtoS( ( Date() - 02 ) ) + "' "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "ACEITE", .F., .T. )

	While ACEITE->( !Eof() )

		PA9->( dbGoTo( ACEITE->PA9REC ) )

		PAA->( dbGoTo( ACEITE->PAAREC ) )

		//Efetua aceite                                                
		RecLock( "PAA", .F. )
		PAA->PAA_DTACT		:= Iif( Empty( PAA->PAA_DTACT		), Date()											, PAA->PAA_DTACT	)
		PAA->PAA_AVLACT	:= Iif( Empty( PAA->PAA_AVLACT	), "2"												, PAA->PAA_AVLACT	)
		PAA->PAA_USRACT	:= "AUTOMATICO"
		PAA->PAA_HRACT		:= Iif( Empty( PAA->PAA_HRACT		), Time()											, PAA->PAA_HRACT	)
		PAA->PAA_OBS		:= "ACEITE AUTOMATICO"
		PAA->PAA_ACEITE	:= "1"
		PAA->( MsUnLock() )
		
		RecLock( "PA9", .F. )
		PA9->PA9_DTFIM		:= Date()
		PA9->PA9_TPENCE	:= PAA->PAA_TPENCE
		PA9->PA9_HIST		:= Iif( !Empty( PA9->PA9_HIST ), PA9->PA9_HIST + CRLF + CRLF, "" ) + "ACEITE AUTOMATICO"
		PA9->( MsUnLock() )

		_cData		:= SubStr( DtoS( PAA->PAA_DTINI ), 07, 02 ) + "/" + SubStr( DtoS( PAA->PAA_DTINI ), 05, 02 ) + "/" + SubStr( DtoS( PAA->PAA_DTINI ), 01, 04 )
		_cDataFim	:= SubStr( DtoS( PAA->PAA_FIM ), 07, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 05, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 01, 04 ) 
		_cHoraFim	:= TransForm( PAA->PAA_HRFIM, "@E 99:99" )

		//Envia email de confirmacao do Aceite
		
		_cTo := Lower( AllTrim( PA9->PA9_MAILUS ) )
		_cCC := Lower( AllTrim( PA9->PA9_CCOPIA ) )

		dbSelectArea( "AA1" )
		dbSetOrder( 01 )

		If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC ) 
			_cTo += Iif( !Empty( _cTo ), ";", "" ) + Lower( AllTrim( AA1->AA1_EMAIL ) )
		EndIf
		
		_cAssunto	:= OemToAnsi( STR0102 ) + AllTrim( PA9->PA9_CODIGO ) + " " + OemToAnsi( STR0103 ) + AllTrim( PA9->PA9_OS )

		_cBody		:= OemToAnsi( STR0060 ) + AllTrim( PAA->PAA_USUARI ) + ", <br>" + CRLF
		_cBody		+= "<br>" + CRLF                                                       
		_cBody		+= "Em " + _cData + " as " + TransForm( Time(), "@E 99:99" ) + OemToAnsi( STR0128 ) + AllTrim( PA9->PA9_CODIGO ) + OemToAnsi( STR0129 ) + AllTrim( PAA->PAA_CODIGO ) + OemToAnsi( STR0134 ) + _cDataFim + " as " + _cHoraFim + " hrs. com o status CONCLUIDA. <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0130 ) + "POSITIVO <br>" + CRLF
		_cBody		+= OemToAnsi( STR0131 ) + "SEM AVALIACAO <br>" + CRLF
		_cBody		+= "<br>" + CRLF                                                       
		_cBody		+= OemToAnsi( STR0108 ) + "<br>" + CRLF                                                       
		_cBody		+= "ACEITE AUTOMATICO <br>" + CRLF                                                       
		_cBody		+= "<br>" + CRLF                                                       
		_cBody		+= "<br>" + CRLF                                                       
		_cBody		+= OemToAnsi( STR0067 ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0068 ) + "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= "</Htm>"

		//Chamado : TI - Fernando Sigoli 11/04/2019	
		//If !Empty( _cTo )
		//	MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo, _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ) + OemToAnsi( STR0105 ), .F. )
		//EndIf

		ACEITE->( dbSkip() )
		
	EndDo

	ACEITE->( dbCloseArea() )	

	RestArea( _aArea )

Return ( Nil )

/*/{Protheus.doc} User Function ADCHStat
	Filtra registros por status da legenda
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

User Function ADCHStat()

	Local oDlg
	Local oStatus
	Local oResponsavel
	Local oEspecialista
	Local oUsuario
	Local oGrupo
	Local oSubGrupo
	Local oServico
	Local oLimpaFtr
	Local bFiltraBrw
	Local _cFiltra
	Local aIndexPA9		:= {}
	Local _aArea			:= GetArea()
	Local _cQuery			:= ""
	Local _nOpca			:= 00
	Local _cStatus			:= ""
	Local _cResponsavel	:= ""
	Local _cEspecialista	:= ""
	Local _cUsuario		:= ""
	Local _cGrupo			:= ""
	Local _cSubGrupo		:= ""
	Local _cServico		:= ""
	Local _lLimpaFtr		:= .F.
	Local _aStatus			:= {}
	Local _aFtrSts			:= {}
	Local _aUsuario		:= {}
	Local _aResponsavel	:= {}
	Local _aEspecialista	:= {}
	Local _aUsuario		:= {}
	Local _aGrupo			:= {}
	Local _aSubGrupo		:= {}
	Local _aServico		:= {}

	U_ADINF009P('ADCH004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Chamados - CHAMADOS')

	//Define listas de consulta - STATUS                           

	Aadd( _aStatus, OemToAnsi( STR0145 ) )
	Aadd( _aFtrSts, "" )

	If VldTecnico()
		Aadd( _aStatus, OemToAnsi( STR0152 ) )
		Aadd( _aFtrSts, "Empty( PA9_DTFIM )" )
	EndIf

	Aadd( _aStatus, OemToAnsi( STR0028 ) )
	Aadd( _aStatus, OemToAnsi( STR0029 ) )
	Aadd( _aStatus, OemToAnsi( STR0030 ) )
	Aadd( _aStatus, OemToAnsi( STR0031 ) )
	Aadd( _aStatus, OemToAnsi( STR0032 ) )
	Aadd( _aStatus, OemToAnsi( STR0115 ) )
	Aadd( _aStatus, OemToAnsi( STR0111 ) )

	Aadd( _aFtrSts, "Empty( PA9_OS ) .And. PA9_DTLIM >= dDataBase .And. PA9_DTPREV >= dDataBase .And. Empty( PA9_DTFIM )"	)
	Aadd( _aFtrSts, "!Empty( PA9_OS ) .And. Empty( PA9_DTFIM ) .And. Empty( PA9_TPENCE )"												)
	Aadd( _aFtrSts, "PA9_DTLIM <= dDataBase .And. Empty( PA9_OS ) .And. Empty( PA9_DTFIM )"											)
	Aadd( _aFtrSts, "PA9_DTPREV <= dDataBase .And. Empty( PA9_OS ) .And. Empty( PA9_DTFIM )"											)
	Aadd( _aFtrSts, "!Empty( PA9_DTFIM )"																												)
	Aadd( _aFtrSts, "!Empty( PA9_TPENCE ) .And. Empty( PA9_DTFIM ) .And. PA9_TPENCE == '5'"											)
	Aadd( _aFtrSts, "!Empty( PA9_TPENCE ) .And. Empty( PA9_DTFIM ) .And. PA9_TPENCE != '5'"											)

	//Define listas de consulta - RESPONSAVEIS                     

	Aadd( _aResponsavel, OemToAnsi( STR0145 ) )

	_cQuery := "SELECT DISTINCT PA6_DRESP "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "PA6" ) + " "
	_cQuery += "WHERE D_E_L_E_T_ = '' "
	_cQuery += "ORDER BY PA6_DRESP "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )

	dbSelectArea( "QRYTMP" )

	While QRYTMP->( !Eof() )

		Aadd( _aResponsavel, AllTrim( QRYTMP->PA6_DRESP ) )

		QRYTMP->( dbSkip() )

	EndDo

	QRYTMP->( dbCloseArea() )


	//Define listas de consulta - ESPECIALISTAS                    

	Aadd( _aEspecialista, OemToAnsi( STR0145 ) )

	_cQuery := "SELECT DISTINCT PA6_DESPE "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "PA6" ) + " "
	_cQuery += "WHERE D_E_L_E_T_ = '' "
	_cQuery += "ORDER BY PA6_DESPE "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )

	dbSelectArea( "QRYTMP" )

	While QRYTMP->( !Eof() )

		Aadd( _aEspecialista, AllTrim( QRYTMP->PA6_DESPE ) )

		QRYTMP->( dbSkip() )

	EndDo

	QRYTMP->( dbCloseArea() )

	//Define listas de consulta - USUARIOS                         

	Aadd( _aUsuario, OemToAnsi( STR0145 ) )

	_cQuery := "SELECT DISTINCT PA9_USUARI "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "PA9" ) + " "
	_cQuery += "WHERE D_E_L_E_T_ = '' "
	_cQuery += "ORDER BY PA9_USUARI"

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )

	dbSelectArea( "QRYTMP" )

	While QRYTMP->( !Eof() )

		Aadd( _aUsuario, AllTrim( QRYTMP->PA9_USUARI ) )

		QRYTMP->( dbSkip() )

	EndDo

	QRYTMP->( dbCloseArea() )


	//Define listas de consulta - GRUPOS                           

	Aadd( _aGrupo, "Todos" )

	dbSelectArea( "PA7" )
	dbSetOrder( 01 )

	PA7->( dbGoTop() )

	While PA7->( !Eof() )

		If Ascan( _aGrupo, PA7->PA7_DESCRI ) == 00
			Aadd( _aGrupo, PA7->PA7_DESCRI )
		EndIf
		
		PA7->( dbSkip() )	
		
	EndDo

	//Define listas de consulta - SUBGRUPOS                        

	Aadd( _aSubGrupo, "Todos" )

	dbSelectArea( "PA8" )
	dbSetOrder( 01 )

	PA8->( dbGoTop() )

	While PA8->( !Eof() )

		If Ascan( _aSubGrupo, PA8->PA8_DESCRI ) == 00
			Aadd( _aSubGrupo, PA8->PA8_DESCRI )
		EndIf
		
		PA8->( dbSkip() )	
		
	EndDo

	//Define listas de consulta - SERVICOS                         

	Aadd( _aServico, "Todos" )

	dbSelectArea( "PA6" )
	dbSetOrder( 01 )

	PA6->( dbGoTop() )

	While PA6->( !Eof() )

		If Ascan( _aServico, PA6->PA6_DESCRI ) == 00
			Aadd( _aServico, PA6->PA6_DESCRI )
		EndIf
			
		PA6->( dbSkip() )	
		
	EndDo

	//Tela de filtragem                                            

	Define MsDialog oDlg Title OemToAnsi( STR0147 ) From 05, 00 To 21.5, 59

	@ 020, 05 Say OemToAnsi( STR0023 )	Size 280, 10 Pixel Of oDlg
	@ 020, 50 ComboBox oStatus Var _cStatus Items _aStatus Size 180, 10 Pixel Of oDlg

	@ 033, 05 Say OemToAnsi( STR0148 )	Size 280, 10 Pixel Of oDlg
	@ 033, 50 ComboBox oResponsavel Var _cResponsavel Items _aResponsavel Size 180, 10 Pixel Of oDlg

	@ 046, 05 Say OemToAnsi( STR0149 ) Size 180, 10 Pixel Of oDlg
	@ 046, 50 ComboBox oEspecialista Var _cEspecialista Items _aEspecialista Size 180, 10 Pixel Of oDlg

	@ 059, 05 Say OemToAnsi( STR0150 ) Size 180, 10 Pixel Of oDlg
	@ 059, 50 ComboBox oUsuario Var _cUsuario Items _aUsuario Size 180, 10 Pixel Of oDlg

	@ 072, 05 Say OemToAnsi( STR0153 ) Size 180, 10 Pixel Of oDlg
	@ 072, 50 ComboBox oGrupo Var _cGrupo Items _aGrupo Size 180, 10 Pixel Of oDlg

	@ 085, 05 Say OemToAnsi( STR0154 ) Size 180, 10 Pixel Of oDlg
	@ 085, 50 ComboBox oSubGrupo Var _cSubGrupo Items _aSubGrupo Size 180, 10 Pixel Of oDlg

	@ 098, 05 Say OemToAnsi( STR0155 ) Size 180, 10 Pixel Of oDlg
	@ 098, 50 ComboBox oServico Var _cServico Items _aServico Size 180, 10 Pixel Of oDlg

	@ 111.5, 05 Say OemToAnsi( STR0151 ) SIze 180, 10 Pixel Of oDlg
	@ 111, 50 CheckBox oLimpaFtr Var _lLimpaFtr Prompt "" Size 11, 10 Pixel Of oDlg

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {||_nOpca := 01, oDlg:End() },{||_nOpca := 00, oDlg:End()} ) Centered

	dbSelectArea( "PA9" )

	If _nOpca == 01

		If !_lLimpaFtr

			//Executa o filtro utilizando a funcao FilBrowse    
			
			_cFiltra := Iif( AllTrim( Upper( _cStatus			) ) != "TODOS", _aFtrSts[ Ascan( _aStatus, _cStatus ) ]	, "" )
			_cFiltra += Iif( AllTrim( Upper( _cResponsavel	) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + RetServ( _cResponsavel, "R" ), "" )
			_cFiltra += Iif( AllTrim( Upper( _cEspecialista	) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + RetServ( _cEspecialista, "E" ), "" )
			_cFiltra += Iif( AllTrim( Upper( _cUsuario		) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + "PA9_USUARI = '" + _cUsuario + "'", "" )
			_cFiltra += Iif( AllTrim( Upper( _cGrupo			) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + "PA9_DGRUPO = '" + _cGrupo + "'", "" )
			_cFiltra += Iif( AllTrim( Upper( _cSubGrupo		) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + "PA9_DSGRUP = '" + _cSubGrupo + "'", "" )
			_cFiltra += Iif( AllTrim( Upper( _cServico		) ) != "TODOS", Iif( !Empty( _cFiltra ), " .And. ", "" ) + "PA9_DSERVI = '" + _cServico + "'", "" )

			bFiltraBrw	:= { || FilBrowse( "PA9", @aIndexPA9, @_cFiltra ) }

			dbSelectArea( "PA9" )
			dbSetOrder( 01 )
			Eval( bFiltraBrw )

		Else
		
			//Limpa o filtro utilizando a funcao EndFilBrw      
			
			EndFilBrw( "PA9", aIndexPA9 )
			PA9->( dbGoTop() )
		
		EndIf

	EndIf

Return ( Nil )

/*/{Protheus.doc} Static Function RetServ
	Retorna lista de servicos do tecnico
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

Static Function RetServ( _cTecnico, _cTipo )

	Local _aArea	:= GetArea()
	Local _cString	:= ""
	Local _cQuery	:= ""

	//Define listas de servicos do tecnico                         

	_cQuery := "SELECT DISTINCT PA6_CODIGO "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "PA6" ) + " "

	If _cTipo == "R"
		_cQuery += "WHERE PA6_DRESP = '" + _cTecnico + "' "
	Else
		_cQuery += "WHERE PA6_DESPE = '" + _cTecnico + "' "
	EndIf

	_cQuery += "AND D_E_L_E_T_ = '' "
	_cQuery += "ORDER BY PA6_CODIGO "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYSRV", .F., .T. )

	dbSelectArea( "QRYSRV" )

	While QRYSRV->( !Eof() )

		_cString += Iif( !Empty( _cString ), "|", "" ) + QRYSRV->PA6_CODIGO

		QRYSRV->( dbSkip() )

	EndDo

	QRYSRV->( dbCloseArea() )

	_cString := "PA9_SERVIC $ '" + _cString + "'"
 
Return ( _cString )

/*/{Protheus.doc} Static Function ldTecnico
	Valida existencia do usuario no cadastro de Tecnicos
	@type  Function
	@author Celso Costa
	@since 04/10/2007
	@version 01
/*/

Static Function VldTecnico()

	Local _aArea	:= GetArea()
	Local _lRet		:= .F.
	Local _cQuery	:= ""

	//Seleciona registro                                           

	_cQuery := "SELECT COUNT( R_E_C_N_O_ ) AS TOTREG "
	_cQuery += "FROM "
	_cQuery += RetSqlName( "AA1" ) + " "
	_cQuery += "WHERE AA1_USUARI = '" + U_ADCHUsr( 01 ) + "' "
	_cQuery += "AND D_E_L_E_T_ = '' "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTEC", .F., .T. )

	dbSelectArea( "QRYTEC" )

	_lRet := QRYTEC->TOTREG >= 01

	QRYTEC->( dbCloseArea() )

	RestArea( _aArea )

Return ( _lRet )

/*/{Protheus.doc} User Function Movi
	(Chama o browser padrão e abre a url)
	@type  Function
	@author ADRIANO SAVOINE
	@since 28/08/2020
	@version 01
	/*/

User Function Movi()

Local cUrl := "https://atendimento.adoro.com.br"


ShellExecute('open',cUrl,"","",SW_NORMAL)

Return
