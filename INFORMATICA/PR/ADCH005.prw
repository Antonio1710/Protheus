#Include "Protheus.CH"
#Include "Chamado.CH"      
#include "topconn.ch"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FILEIO.CH"

#Define CRLF  Chr( 13 ) + Chr( 10 )
     
STATIC cHtmlPage    := ''   //Chamado: 049520 - Fernanado Sigoli 24/06/2019 
STATIC aHeadOut     := {}   //Chamado: 049520 - Fernanado Sigoli 24/06/2019 
STATIC cUrl         := ''   //Chamado: 049520 - Fernanado Sigoli 24/06/2019  
STATIC cHttpHeader  := ''  //Chamado: 049520 - Fernanado Sigoli 24/06/2019 
STATIC nIpSrvTrll   := SuperGetMv( "MV_#IPSRVT" , .F. , '10.5.7.3' ,  ) //Chamado: 049520 - Fernanado Sigoli 24/06/2019 
STATIC cDescResumid := '' //Chamado: 049520 - Fernanado Sigoli 24/06/2019 

/*{Protheus.doc} User Function ADCH005
	Manutencao de Ordens de Servicos
	@type  Function
	@author Celso Costa
	@since 08/10/2007
	@version 01
	@history chamado 049520 - Fernanado Sigoli - 24/06/2019 - Tratamento de erro log na Rotina de aceite de chamados
	@history chamado T.I    - William Costa    - 27/07/2020 - Ajustado localização para envio do cartão do trello na inclusão
*/

User Function ADCH005()

	Private _cEscopo	:= ""
	Private cCadastro	:= OemToAnsi( STR0025 )
	Private _aCores	:=	{{ "PAA_TPENCE='0'"						                                                    , "BR_LARANJA"	},;
	                     { "PAA_TPENCE='2'"						                                                    , "BR_BRANCO"	},;
	                     { "PAA_TPENCE='5'"											 	                            , "BR_PINK"		},;
	                     { "PAA_TPENCE=='6'"												                        , "BR_AMARELO"	},;
	                     { "PAA_TPENCE=='7'"												                        , "BR_AZUL"	    },;
	                     { "PAA_TPENCE=='8'"												                        , "BR_VERDE"	},;
	                     { "PAA_TPENCE=='9'"												                        , "BR_MARROM"	},;
	                     { "!Empty( PAA_FIM ) .And. PAA_TPENCE = '1' .And. PAA_ACEITE = '2'"                        , "BR_CINZA"	},;
	                     { "!Empty( PAA_FIM ) .And. PAA_TPENCE = '1' .And. PAA_ACEITE = ' '"                        , "BR_PRETO"	},;
	                     { "!Empty( PAA_FIM ) .And. (PAA_TPENCE = '1' .OR. PAA_TPENCE = '3') .And. PAA_ACEITE = '1'", "BR_VERMELHO"	} }
	                     
	Private aRotina	:= {	{ OemToAnsi( STR0002 ), "AxPesqui"		, 00, 01 },;
							{ OemToAnsi( STR0003 ), "AxVisual"		, 00, 02 },;
							{ OemToAnsi( STR0004 ), "U_InclOS"		, 00, 03 },;
							{ OemToAnsi( STR0005 ), "U_AlteOS" 		, 00, 04 },;
							{ OemToAnsi( STR0080 ), "U_EncerraOS"	, 00, 05 },;
							{"Acompanhamento",      "U_CALPOS"	    , 00, 06 },;
							{ OemToAnsi( STR0007 ), "U_LegOS"		, 00, 07 } }
	Private _nOPC		  := 4
	Private _aDadTrf	  := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	DbSelectArea( "PAA" )
	DbSetOrder( 03 )
	
	MBrowse( 06, 01, 22, 75, "PAA",,,,,, _aCores )

Return (Nil)

/*{Protheus.doc} User Function InclOS
	Inclusao de Ordens de Servicos - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
*/

User Function InclOS()

	Local _aArea		:= GetArea()
	Local _nOpca		:= 00
	Local _cData		:= ""
	Local _cTo			:= ""
	Local _cAssunto	    := ""
	Local _cBody		:= ""
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cCC			:= ""

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	_nOPC := 4
	
	//Valida inclusao, caso seja solicitada de um chamado
	
	dbSelectArea( "PAA" )
	dbSetOrder( 01 )
	
	If "ADCH004" $ AllTrim( Upper( FunName() ) )
		
		If !Empty( PA9->PA9_DTINI ) .And. Empty( PA9->PA9_DTFIM )
			dbSeek( xFilial( "PAA" ) + PA9->PA9_OS )
			U_OSMsg( STR0013, "O " + STR0044 + " " + AllTrim( PA9->PA9_CODIGO ) + STR0057 + AllTrim( PAA->PAA_NOMTEC ) + STR0058 + AllTrim( PA9->PA9_OS ) + STR0055 )
			Return ( Nil )
		ElseIf !Empty( PA9->PA9_DTFIM )
			U_OSMsg( STR0013, STR0044 + " " + AllTrim( PA9->PA9_CODIGO ) + Iif( !Empty( PA9->PA9_OS ), OemToAnsi( STR0056 ) + PA9->PA9_OS, "" ) + Iif( Val( PA9->PA9_TPENCE ) <= 02, " concluido(s) em ", " cancelado(s) em " ) + SubStr( DtoS( PA9->PA9_DTFIM ), 07, 02 ) + "/" + SubStr( DtoS( PA9->PA9_DTFIM ), 05, 02 ) + "/" + SubStr( DtoS( PA9->PA9_DTFIM ), 01, 04 ) + STR0055 )
			Return ( Nil )
		EndIf
		
	EndIf
	
	//Inclusao
	
	_nOpca := AxInclui( "PAA", PAA->( Recno() ), 03,,,, "U_OSOK()",, "U_AtuOS" )
	
	//Envia email de confirmacao da inclusao da Ordem de Servico
	
	/*
	If _nOpca == 01
	
	dbSelectArea( "PA9" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "PA9" ) + PAA->PAA_CHAMAD )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define destinatarios do email de confirmacao                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cTo := Lower( AllTrim( PA9->PA9_MAILUS ) )
	_cCC := Lower( AllTrim( PA9->PA9_CCOPIA ) )
	
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
	_cTo += Iif( !Empty( _cTo ), ";", "" ) + AllTrim( AA1->AA1_EMAIL )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura email de confirmacao para os usuarios              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cData		:= SubStr( DtoS( PAA->PAA_DTINI ), 07, 02 ) + "/" + SubStr( DtoS( PAA->PAA_DTINI ), 05, 02 ) + "/" + SubStr( DtoS( PAA->PAA_DTINI ), 01, 04 )
	
	_cAssunto	:= Upper( OemToAnsi( STR0122 ) ) + " " + AllTrim( PAA->PAA_CODIGO ) + " " + Upper( OemToAnsi( STR0123 ) )
	
	_cBody		:= OemToAnsi( STR0060 ) + AllTrim( PA9->PA9_USUARI ) + ", <br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0083 ) + AllTrim( PAA->PAA_CODIGO ) + OemToAnsi( STR0084 ) + AllTrim( PAA->PAA_CHAMAD ) + " " + OemToAnsi( STR0125 )  + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0126 ) + AllTrim( PAA->PAA_NOMTEC ) + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0067 ) + "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0068 ) + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= "</Htm>"
	
	If !Empty( _cTo )
	MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo, _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ) + OemToAnsi( STR0124 ), .F. )
	EndIf
	
	EndIf
	*/

	IF INCLUI
		
		// *** INICIO WILL TRELLO DISTRIBUICAO DE CHAMADO*** //
		dbSelectArea( "AA1" )
		dbSetOrder( 01 )
		
		IF dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
		
			IF AA1->AA1_TRELLO == .T.

				IF ALLTRIM(PAA->PAA_TRELLO) == ''
			
					cUrl := 'http://'+Alltrim(nIpSrvTrll)+'/api/call/' + ALLTRIM(PAA->PAA_CODIGO)    
					cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
					
					IF !EMPTY(SUBSTRING(cHtmlPage,1,24)) 
					
						RecLock( "PAA", .F. )
						PAA->PAA_TRELLO := SUBSTRING(cHtmlPage,1,24)
						PAA->( MsUnLock() )
					
					ENDIF
				ENDIF
			ENDIF
		ENDIF	
		// *** FINAL WILL TRELLO DISTRIBUICAO DE CHAMADO*** //
	ENDIF

	RestArea( _aArea )

Return ( Nil )

/*{Protheus.doc} User Function AlteOS
	Alteracao de Ordens de Servicos - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
*/

User Function AlteOS()

	Local _aAlter		:= {}
	Local _nOpca		:= 00
	Local _cAssunto	:= ""
	Local _cBody		:= ""
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cTo			:= ""
	Local _aAuto		:= {}
	Local _cData		:= SubStr( DtoS( Date() ), 07, 02 ) + "/" + SubStr( DtoS( Date() ), 05, 02 ) + "/" + SubStr( DtoS( Date() ), 01, 04 )
	Local _cCodigo		:= PAA->PAA_CODIGO
	Local _aObsAct		:= {}
	Local _cDataFim	:= ""
	Local _cHoraFim	:= ""
	Local _cStatus		:= ""
	Local _aEncerra	:= {}
	Local _aAvAceite	:= {}
	Local _nAceite		:= 00
	Local _nAvAceite	:= 00
	Local	_cTecnico	:= ""
	Local _cOrdem		:= ""
	Local _cCC			:= ""

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Tipos de encerramento de ordem de servico                    
	
	Aadd( _aEncerra, "CONCLUIDA"		)
	Aadd( _aEncerra, "IMPROCEDENTE"	)
	Aadd( _aEncerra, "TRANSFERIDA"	)
	Aadd( _aEncerra, "CANCELADA"		)
	Aadd( _aEncerra, "REABERTURA"		)
	Aadd( _aEncerra, "AGUARD. APROV.")
	
	//Tipos de avaliacao de aceite                                 
	
	Aadd( _aAvAceite, "RUIM"		)
	Aadd( _aAvAceite, "BOM"			)
	Aadd( _aAvAceite, "REGULAR"	)
	Aadd( _aAvAceite, "OTIMO"		)
	
	//Efetua Alteracao                                             
	
	_nOPC := 4
	
	If AllTrim( Upper( FunName() ) ) == "ADCH005"
		
		If !Empty( PAA->PAA_FIM )
			U_OSMsg( STR0013, STR0074 )
			Return ( Nil )
		EndIf
		
	EndIf
	
	//Seleciona campos que poderao ser alterados                   
	
	If ! ("ADCH004" $ AllTrim( Upper( FunName() ) ))
		
		dbSelectArea( "SX3" )
		dbSetOrder( 01 )
		dbSeek( "PAA" )
		
		While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "PAA"
			
			If	AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_FIM"		.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_HRFIM"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_ACEITE"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_DTACT"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_AVLACT"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_USRACT"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_HRACT"	.And. ;
				AllTrim( Upper( SX3->X3_CAMPO ) ) != "PAA_MAILUS"
				
				Aadd( _aAlter, SX3->X3_CAMPO )
				
			EndIf
			
			SX3->( dbSkip() )
			
		EndDo
		
	Else
		
		Aadd( _aAlter, "PAA_ACEITE"	)
		Aadd( _aAlter, "PAA_AVLACT"	)
		
		dbSelectArea( "PAA" )
		dbSetOrder( 01 )
		
		If !dbSeek( xFilial( "PAA" ) + PA9->PA9_OS )
			U_OSMsg( STR0013, STR0101 )
			Return ( Nil )
		ElseIf Empty( PAA->PAA_FIM )
			U_OSMsg( STR0013, STR0100 )
			Return ( Nil )
		ElseIf Empty( PAA->PAA_TPENCE )
			U_OSMsg( STR0013, STR0112 )
			Return ( Nil )
		ElseIf !Empty( PAA->PAA_ACEITE ) .And. PAA->PAA_TPENCE != "5"
			U_OSMsg( STR0013, STR0110 )
			Return ( Nil )
		EndIf
		
		_aObsAct := InfObsAct()
		
		If !_aObsAct[ 01 ]
			Return ( Nil )
		EndIf
		
	EndIf
	
	//Efetua alteracao                                             
	
	_aButtons := {{'NOTE',{ || U_HSOS()},'Apont.Horas'}}
	Aadd(_aButtons, {'NOTE',{ || U_EnviaTrello()},'Enviar Chamado para o Trello'})
	
	_nOpca := AxAltera( "PAA", PAA->( Recno() ), 04,, _aAlter ,,, "U_OSAltOK()",,,_aButtons )
	
	// Efetua aceite                                                
	
	If _nOpca == 01 .And. ( "ADCH004" $ AllTrim( Upper( FunName() ) ) )
		
		//Valida aceite                                                
		
		If Empty( PAA->PAA_ACEITE )
			U_OSMsg( STR0013, STR0135 )
			Return ( Nil )
		EndIf
		
		//Efetua aceite
		
		_cStatus := _aEncerra[ Val( PAA->PAA_TPENCE ) ]
		_cOrdem	:= PAA->PAA_CODIGO
		
		RecLock( "PAA", .F. )
		PAA->PAA_DTACT		:= Iif( Empty( PAA->PAA_DTACT		), Date()											, PAA->PAA_DTACT	)
		PAA->PAA_AVLACT	:= Iif( Empty( PAA->PAA_AVLACT	), "2"												, PAA->PAA_AVLACT	)
		PAA->PAA_USRACT	:= Iif( Empty( PAA->PAA_USRACT	), AllTrim( Upper( U_ADCHUsr( 04 ) ) )	, PAA->PAA_USRACT	)
		PAA->PAA_HRACT		:= Iif( Empty( PAA->PAA_HRACT		), Time()											, PAA->PAA_HRACT	)
		PAA->PAA_OBS		:= Iif( !Empty( PAA->PAA_OBS ), PAA->PAA_OBS + CRLF + CRLF + OemToAnsi( STR0108 ) + CRLF + _aObsAct[ 02 ], OemToAnsi( STR0108 ) + CRLF + _aObsAct[ 02 ] )
		PAA->PAA_TPENCE	:= Iif( PAA->PAA_ACEITE == "1", PAA->PAA_TPENCE, "1" )
		PAA->( MsUnLock() )
		
		RecLock( "PA9", .F. )
		PA9->PA9_DTFIM		:= Iif( PAA->PAA_ACEITE == "1", Date(), CtoD( "" ) )
		PA9->( MsUnLock() )
		
		_cDataFim	:= SubStr( DtoS( PAA->PAA_FIM ), 07, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 05, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 01, 04 )
		_cHoraFim	:= TransForm( PAA->PAA_HRFIM, "@E 99:99" )
		_nAceite		:= Val( PAA->PAA_ACEITE )
		_nAvAceite	:= Val( PAA->PAA_AVLACT )
		_cTecnico	:= PAA->PAA_TECNIC
		
		If PAA->PAA_ACEITE == "2"
			
			//Efetua aceite - NAO                                          
			
			RecLock( "PAA", .F. )
			PAA->PAA_DTTRAN	:= dDataBase
			PAA->PAA_HRTRAN	:= Time()
			PAA->(MsUnLock() )
			
			_aAuto	:= MntArraySX3( "PAA" )
			
			For _nCtAuto := 01 To Len( _aAuto )
				_aAuto[ _nCtAuto ][ 02 ] := PAA->&( _aAuto[ _nCtAuto ][ 01 ] )
			Next
			
			RecLock( "PAA", .T. )
			
			For _nCtAuto := 01 To Len( _aAuto )
				
				If	AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_FIM"		.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRFIM"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_TPENCE"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_ACEITE"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_DTACT"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_AVLACT"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_USRACT"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRACT"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_DTTRAN"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRTRAN"	.And. ;
					AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_CODIGO"
					
					PAA->&( _aAuto[ _nCtAuto ][ 01 ] )	:= _aAuto[ _nCtAuto ][ 02 ]
					
				ElseIf AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) == "PAA_CODIGO"
					PAA->PAA_CODIGO := GetSXENum( "PAA", "PAA_CODIGO" )
				EndIf
				
			Next
			
			PAA->PAA_OSORIG	:= _cCodigo
			PAA->PAA_TPENCE	:= "5"
			
			PAA->( MsUnLock() )
			
			ConfirmSX8()
			
			RecLock( "PA9", .F. )
			PA9->PA9_OS			:= PAA->PAA_CODIGO
			PA9->PA9_TPENCE	:= PAA->PAA_TPENCE
			PA9->( MsUnLock() )
			
		EndIf
		
		RecLock( "PA9", .F. )
		PA9->PA9_HIST	:= Iif( !Empty( PA9->PA9_HIST ), PA9->PA9_HIST + CRLF + CRLF + OemToAnsi( STR0108 ) + CRLF + _aObsAct[ 02 ], OemToAnsi( STR0108 ) + CRLF + _aObsAct[ 02 ] )
		PA9->( MsUnLock() )
		
		//Envia email de confirmacao do Aceite                         
		
		_cTo := Lower( AllTrim( PA9->PA9_MAILUS ) )
		_cCC := Lower( AllTrim( PA9->PA9_CCOPIA ) )
		
		dbSelectArea( "AA1" )
		dbSetOrder( 01 )
		
		If dbSeek( xFilial( "AA1" ) + _cTecnico )
			_cTo += Iif( !Empty( _cTo ), ";", "" ) + Lower( AllTrim( AA1->AA1_EMAIL ) )
		EndIf
		
		_cAssunto	:= OemToAnsi( STR0102 ) + AllTrim( PA9->PA9_CODIGO ) + " " + OemToAnsi( STR0103 ) + AllTrim( _cOrdem )
		
		_cBody		:= OemToAnsi( STR0060 ) + AllTrim( PAA->PAA_USUARI ) + ", <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= "Em " + _cData + " as " + TransForm( Time(), "@E 99:99" ) + OemToAnsi( STR0128 ) + AllTrim( PA9->PA9_CODIGO ) + OemToAnsi( STR0129 ) + _cOrdem + OemToAnsi( STR0134 ) + _cDataFim + " as " + _cHoraFim + " hrs. com o status " + _cStatus + ". <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0130 ) + IIf( _nAceite == 01, "POSITIVO", "NEGATIVO" ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0131 ) + Iif( _nAvAceite <= 00, "SEM AVALIACAO", _aAvAceite[ _nAvAceite ] ) + "<br>" + CRLF
		
		If _nAceite == 02
			_cBody	+= "<br>" + CRLF
			_cBody	+= OemToAnsi( STR0132 ) + AllTrim( PAA->PAA_CODIGO ) + OemToAnsi( STR0133 ) + "<br>" + CRLF
		EndIf
		
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0108 ) + "<br>" + CRLF
		//	_cBody		+= AllTrim( _aObsAct[ 02 ] ) + "<br>" + CRLF
		nLinhasMemo := MLCOUNT(_aObsAct[ 02 ],80)
		For LinhaCorrente := 1 To nLinhasMemo
			_cBody	+= MemoLine(_aObsAct[ 02 ],80,LinhaCorrente) + "<br>" + CRLF
		Next
		_cBody		+= "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0067 ) + "<br>" + CRLF
		_cBody		+= OemToAnsi( STR0068 ) + "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		_cBody		+= "</Htm>"
		
		If !Empty( _cTo )
			MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo, _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ) + OemToAnsi( STR0105 ), .F. )
		EndIf
		
	EndIf
	
	// *** INICIO WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
	
		IF AA1->AA1_TRELLO == .T.
		
			// *** INICIO WILLIAM COSTA 25/10/2018 044776 || OS 045924 || TECNOLOGIA || WILLIAM_COSTA || 8905 || TRELLO *** //
			IF cDescResumid             <> PAA->PAA_DRESUM .AND. ;
			   ALLTRIM(PAA->PAA_TRELLO) <> '' 
			                  
				cUrl        := 'http://'+Alltrim(nIpSrvTrll)+'/api/update/' + ALLTRIM(PAA->PAA_TRELLO)      
				cHtmlPage   := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
			
			ENDIF
			// *** FINAL WILLIAM COSTA 25/10/2018 044776 || OS 045924 || TECNOLOGIA || WILLIAM_COSTA || 8905 || TRELLO *** //
		ENDIF
	ENDIF		
	// *** FINAL WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //

Return ( Nil )

/*{Protheus.doc} User Function EncerraOS
	Encerramento de Ordens de Servicos - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function EncerraOS()

	Local _aArea		:= GetArea()
	Local _nOpca		:= 00
	Local _aAlter		:= {}
	Local _cFrom		:= AllTrim( GetMv( "MV_RELFROM" ) )
	Local _cTo			:= ""
	Local _cCC			:= ""
	Local _cAssunto	    := ""
	Local _cBody		:= ""
	Local _aEncerra	    := {}
	Local _aAuto		:= {}
	Local _nCtAuto		:= 00
	Local _cCodigo		:= PAA->PAA_CODIGO
	Local _cTpEnc		:= PAA->PAA_TPENCE
	Local _cData		:= ""
	Local _nTotHr       := 0
	Local _cQuery       := ""
	Local lPlanejado    := .F.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Verifica existencia de encerramento de aceites automaticos   
	
	MsAguarde({|| U_EncCHAuto() }, OemToAnsi( STR0069 ), OemToAnsi( STR0142 ), .F. )
	
	_nOPC := 5
	
	//Tipos de encerramentos                                       
	
	Aadd( _aEncerra, "CONCLUIDA"		)
	Aadd( _aEncerra, "IMPROCEDENTE"	)
	Aadd( _aEncerra, "TRANSFERIDA"	)
	Aadd( _aEncerra, "CANCELADA"		)
	Aadd( _aEncerra, "REABERTURA"		)
	
	//Campos que devem ser preenchidos no encerramento da OS       
	
	Aadd( _aAlter, "PAA_FIM"		)
	Aadd( _aAlter, "PAA_HRFIM"		)
	Aadd( _aAlter, "PAA_TPENCE"	)
	Aadd( _aAlter, "PAA_DESCRI"	)
	Aadd( _aAlter, "PAA_OBS"		)
	Aadd( _aAlter, "PAA_HRSUTL"	)
	Aadd( _aAlter, "PAA_GRACT"		)
	Aadd( _aAlter, "PAA_SGRACT"	)
	Aadd( _aAlter, "PAA_SRVACT"	)
	Aadd( _aAlter, "PAA_HREAL"		)
	Aadd( _aAlter, "PAA_MAILUS"	)
	
	//Encerramento da Ordem de Servico                 		     
	
	If !Empty( PAA->PAA_FIM )
		U_OSMsg( STR0013, STR0074 )
		Return ( Nil )
	EndIf
	
	//Verifica se foram apontadas horas na OS	    		         
	//Incluido por Adriana para validar apontamento de horas  - chamado 033023
	                        
	_cQuery:="SELECT SUM(PAI_HORAS) TOTHR FROM "+retsqlname("PAI")+" WHERE PAI_OS = '"+PAA->PAA_CODIGO+"' AND "+RetSqlName("PAI")+".D_E_L_E_T_= ''"
	
	TCQUERY _cQuery new alias "xPAI"
	
	xPAI->(dbgotop())
	
	_nTotHr :=xPAI->TOTHR
	DbCloseArea("xPAI")
	
	If ALLTRIM(PAA->PAA_DESCRI) == ''
		U_OSMsg( STR0013, "Necessário informar descritivo da OS para encerramento !!!" )
		Return ( Nil )
	EndIf   
	
	If _nTotHr <= 0.05
		U_OSMsg( STR0013, "Obrigatorio apontar horas antes de encerrar a OS !!!" )
		Return ( Nil )
	EndIf                       
		
	If PAA->PAA_TIPO = "003"
		U_OSMsg( STR0013, "Reclassificar Tipo de Solicitação. Não é permitido encerrar OS com TIPO DE SOLICITAÇÃO = ATENDIMENTO !!!" )
		Return ( Nil )
	EndIf
	
	If PAA->PAA_GRACT = '01'.and. Empty(PAA->PAA_SPRINT)
		U_OSMsg( STR0013, "Para encerrar é obrigatório informar número da Sprint !!!" )
		Return ( Nil )
	EndIf
	
	//Atualiza data de encerramento                  		         
	
	//RecLock( "PAA", .F. )
	//PAA->PAA_FIM	:= Date()
	//PAA->PAA_HRFIM	:= Time()
	//PAA->( MsUnLock() )
	
	//Efetua encerramento                              		        
	
	_nOpca := AxAltera( "PAA", PAA->( Recno() ), 04,, _aAlter,,,"U_OSAltOK()",,"U_INICPO()")
	
	If _nOpca == 01 .And. Empty( PAA->PAA_TPENCE )
		U_OSMsg( STR0013, STR0082 )
	EndIf
	
	If _nOpca == 01 .And. ( Empty( PAA->PAA_GRACT ) .Or. Empty( PAA->PAA_SGRACT ) .Or. Empty( PAA->PAA_SRVACT ) )
		U_OSMsg( STR0013, STR0143 )
	EndIf
	
	If _nOpca != 01 .Or. Empty( PAA->PAA_TPENCE ) .Or. Empty( PAA->PAA_GRACT ) .Or. Empty( PAA->PAA_SGRACT ) .Or. Empty( PAA->PAA_SRVACT )
		
		RecLock( "PAA", .F. )
		PAA->PAA_FIM	:= CtoD( "" )
		PAA->PAA_HRFIM	:= ""
		PAA->( MsUnLock() )
		
		Return ( Nil )
		
	EndIf
	
	If Empty( PAA->PAA_FIM ) .Or. Empty( PAA->PAA_HRFIM )
		
		RecLock( "PAA", .F. )
		PAA->PAA_TPENCE	:= _cTpEnc
		PAA->PAA_FIM		:= CtoD( "" )
		PAA->PAA_HRFIM		:= ""
		PAA->( MsUnLock() )
		
		U_OSMsg( STR0013, STR0117 )
		
		Return ( Nil )
		
	EndIf
	
	dbSelectArea( "PA9" )
	dbSetOrder( 01 )
	If !dbSeek( xFilial( "PA9" ) + PAA->PAA_CHAMAD )
		Return ( Nil )
	EndIf
	
	// *** INICIO CARREGA VARIAVEL lPlanejado  *** //
	
	IF MSGYESNO("A O.S. que está sendo fechada foi planejada'?")
	
		lPlanejado := .T.
		
	ELSE
	
		lPlanejado := .F.
		
	ENDIF
	
	// *** FINAL CARREGA VARIAVEL lPlanejado  *** //
	
	//Atualizacoes para Ordem de Servico - Transferencia           
	
	If PAA->PAA_TPENCE == "3"
		
		RecLock( "PAA", .F. )
		PAA->PAA_OBS		:= Iif( !Empty( PAA->PAA_OBS ), PAA->PAA_OBS + CRLF + CRLF + OemToAnsi( STR0098 ) + CRLF + _aDadTrf[ 05 ], OemToAnsi( STR0098 ) + CRLF + _aDadTrf[ 05 ] )
		PAA->PAA_DTTRAN	:= dDataBase
		PAA->PAA_HRTRAN	:= Time()
		PAA->PAA_ACEITE	:= "1"
		PAA->PAA_USRACT	:= U_ADCHUsr( 04 )
		PAA->PAA_DTACT		:= Date()
		PAA->PAA_HRACT		:= Time()
		PAA->PAA_PLANEJ     := lPlanejado
		PAA->(MsUnLock() )
		_aAuto	:= MntArraySX3( "PAA" )
		
		For _nCtAuto := 01 To Len( _aAuto )
			_aAuto[ _nCtAuto ][ 02 ] := PAA->&( _aAuto[ _nCtAuto ][ 01 ] )
		Next
		
		RecLock( "PAA", .T. )
		
		For _nCtAuto := 01 To Len( _aAuto )
			
			If	AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_FIM"		.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRFIM"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_TPENCE"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_ACEITE"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_DTACT"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_AVLACT"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_USRACT"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRACT"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_DTTRAN"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRTRAN"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_DTINI"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_HRINI"	.And. ;
				AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) != "PAA_CODIGO"
				
				PAA->&( _aAuto[ _nCtAuto ][ 01 ] )	:= _aAuto[ _nCtAuto ][ 02 ]
				
			ElseIf AllTrim( _aAuto[ _nCtAuto ][ 01 ] ) == "PAA_CODIGO"
				PAA->PAA_CODIGO := GetSXENum( "PAA", "PAA_CODIGO" )
			EndIf
			
		Next
		
		PAA->PAA_OSORIG	:= _cCodigo
		PAA->PAA_TECNIC	:= _aDadTrf[ 02 ]
		PAA->PAA_NOMTEC	:= _aDadTrf[ 03 ]
		PAA->PAA_DTPREV	:= _aDadTrf[ 04 ]
		PAA->PAA_OBS		:= OemToAnsi( STR0098 ) + CRLF + _aDadTrf[ 05 ]
		PAA->PAA_TPENCE	:= "0"
		PAA->PAA_DTINI		:= DATE()
		PAA->PAA_HRINI		:= TIME()
		
		PAA->( MsUnLock() )
		
		ConfirmSx8()
		
		RecLock( "PA9", .F. )
		PA9->PA9_OS := PAA->PAA_CODIGO
		PA9->( MsUnLock() )
		
		// *** INICIO WILL TRELLO TRANSFERENCIA*** //
		//FECHA CARTAO ANTIGO QUANDO FOR DE TRANSFERENCIA
		dbSelectArea( "AA1" )
		dbSetOrder( 01 )
		
		IF dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
		
			IF AA1->AA1_TRELLO == .T. 
			
				cUrl      := 'http://'+Alltrim(nIpSrvTrll)+'/api/closed/' + ALLTRIM(PAA->PAA_TRELLO)    
				cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
			
			ENDIF
		ENDIF
		
		//ABRE CARTAO NOVO
		dbSelectArea( "AA1" )
		dbSetOrder( 01 )
		
		IF dbSeek( xFilial( "AA1" ) + _aDadTrf[ 02 ] )
		
			IF AA1->AA1_TRELLO == .T.
			
				cUrl := 'http://'+Alltrim(nIpSrvTrll)+'/api/call/' + ALLTRIM(PAA->PAA_CODIGO)    
				cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
				
				IF !EMPTY(SUBSTRING(cHtmlPage,1,24))
				
					RecLock( "PAA", .F. )
					PAA->PAA_TRELLO := SUBSTRING(cHtmlPage,1,24)
					PAA->( MsUnLock() )
				
				ENDIF
				
			ENDIF	
		ENDIF	
		// *** FINAL WILL TRELLO TRANSFERENCIA*** //
		
	else
	
		RecLock( "PAA", .F. )
		PAA->PAA_FIM	:= Iif( !Empty( PAA->PAA_FIM ), PAA->PAA_FIM, Date() )
		PAA->PAA_HRFIM	:= Iif( !Empty( PAA->PAA_HRFIM ), PAA->PAA_HRFIM, Time() )
		PAA->PAA_PLANEJ := lPlanejado
		PAA->( MsUnLock() )
		
		RecLock( "PA9", .F. )
		PA9->PA9_TPENCE := PAA->PAA_TPENCE
		PA9->( MsUnLock() )
		
	EndIf
	
	RestArea( _aArea )
	
	//Define destinatarios do email de confirmacao                 
	
	_cTo := iif(PAA->PAA_TPENCE = "3","",Lower( AllTrim( PAA->PAA_MAILUS ) ))
	//_cTo := Lower( AllTrim( PA9->PA9_MAILUS ) )
	_cCC := iif(PAA->PAA_TPENCE = "3","",Lower( AllTrim( PA9->PA9_CCOPIA ) ))
	
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
		_cTo += Iif( !Empty( _cTo ), ";", "" ) + AllTrim( AA1->AA1_EMAIL )
	EndIf
	
	if PAA->PAA_TPENCE = "3"
		If dbSeek( xFilial( "AA1" ) + _aDadTrf[ 02 ] )
			_cTo += Iif( !Empty( _cTo ), ";", "" ) + AllTrim( AA1->AA1_EMAIL )
		EndIf
	endif
	
	//Configura email de confirmacao para os usuarios              
	
	_cData		:= SubStr( DtoS( PAA->PAA_FIM ), 07, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 05, 02 ) + "/" + SubStr( DtoS( PAA->PAA_FIM ), 01, 04 )
	
	_cAssunto	:= Upper( OemToAnsi( STR0044 ) ) + " " + AllTrim( PAA->PAA_CHAMAD ) + " " + Upper( OemToAnsi( STR0032 ) )
	
	if PAA->PAA_TPENCE <> "3"
		_cBody		:= OemToAnsi( STR0060 ) + AllTrim( PAA->PAA_USUARI ) + ", <br>" + CRLF
		_cBody		+= "<br>" + CRLF
		//_cBody		+= OemToAnsi( STR0083 ) + AllTrim( PAA->PAA_CODIGO ) + OemToAnsi( STR0084 ) + AllTrim( PAA->PAA_CHAMAD ) + OemToAnsi( STR0085 ) + " " + _aEncerra[ Val( PAA->PAA_TPENCE ) ] + " em " + _cData + " as " + TransForm( PAA->PAA_HRFIM, "@E 99:99" ) + "hrs. <br>" + CRLF
		_cBody		+= "O chamado " + AllTrim( PAA->PAA_CHAMAD ) + OemToAnsi( STR0085 ) + " " + _aEncerra[ Val( PAA->PAA_TPENCE ) ] + " em " + _cData + " as " + TransForm( PAA->PAA_HRFIM, "@E 99:99" ) + "hrs. <br>" + CRLF
		_cBody		+= "<br>" + CRLF
	else
		_cBody		:= OemToAnsi("A Ordem de Serviço ") + AllTrim( PAA->PAA_CODIGO ) + OemToAnsi( STR0085 ) + " " + _aEncerra[ Val( PAA->PAA_TPENCE ) ] + " em " + _cData + " as " + TransForm( PAA->PAA_HRFIM, "@E 99:99" ) + "hrs. <br>" + CRLF
		_cBody		+= "<br>" + CRLF
	endif
	
	If PAA->PAA_TPENCE $ "1/2"
		
		_cBody	+= "<br>" + CRLF
		_cBody	+= "--SOLUÇÃO--:<br>" + CRLF
		_cBody	+= "POR: "+ ALLTRIM(PAA->PAA_NOMTEC)+ " <br>" + CRLF //Incluido por Adriana em 22/05/14
		
		//
		//	_cBody	+= AllTrim( PAA->PAA_DESCRI ) + "<br>" + CRLF
		
		nLinhasMemo := MLCOUNT(PAA->PAA_DESCRI,80)
		For LinhaCorrente := 1 To nLinhasMemo
			_cBody	+= MemoLine(PAA->PAA_DESCRI,80,LinhaCorrente) + "<br>" + CRLF
		Next
		//
		_cBody	+= "<br>" + CRLF
		
		_cBody	+= "<br>" + CRLF
		_cBody	+= "--SOLICITAÇÃO--:<br>" + CRLF
		//	_cBody	+= AllTrim( PAA->PAA_ESCOPO ) + "<br>" + CRLF
		
		nLinhasMemo := MLCOUNT(PAA->PAA_ESCOPO,80)
		For LinhaCorrente := 1 To nLinhasMemo
			_cBody	+= MemoLine(PAA->PAA_ESCOPO,80,LinhaCorrente) + "<br>" + CRLF
		Next
		
		_cBody	+= "<br>" + CRLF
		
		_cBody	+= OemToAnsi( STR0086 ) + "<br>" + CRLF
		_cBody	+= OemToAnsi( STR0087 ) + "<br>" + CRLF
		_cBody		+= "<br>" + CRLF
		
	ElseIf PAA->PAA_TPENCE $ "3/5"
		
		_cBody	+= OemToAnsi( STR0120 ) + AllTrim( PA9->PA9_OS ) + " " + OemToAnsi( STR0121 ) + AllTrim( Iif( PAA->PAA_TPENCE == "3", _aDadTrf[ 03 ], PAA->PAA_NOMTEC ) ) + ". <br>" + CRLF
		_cBody	+= "<br>" + CRLF
		
	EndIf
	
	_cBody		+= "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0067 ) + "<br>" + CRLF
	_cBody		+= OemToAnsi( STR0068 ) + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	_cBody		+= "</Htm>"
	
	If !Empty( _cTo )
		MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo, _cCC, _cAssunto,, _cBody )}, OemToAnsi( STR0069 ), OemToAnsi( STR0071 ) + OemToAnsi( STR0088 ), .F. )
	EndIf
	
	RestArea( _aArea )
	
	// *** INICIO WILL TRELLO ENCERRAMENTO DE ORDEM DE SERVICO*** //
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	IF dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
	
		IF AA1->AA1_TRELLO == .T. .AND. PAA->PAA_TPENCE <> "3" // TRANSFERENCIA EU FECHO O CARTAO DE OUTRA MANEIRA ESTA NO IF DE TRANSFERENCIA
		
			cUrl      := 'http://'+Alltrim(nIpSrvTrll)+'/api/closed/' + ALLTRIM(PAA->PAA_TRELLO)    
			cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
		
		ENDIF
	ENDIF
	// *** FINAL WILL TRELLO ENCERRAMENTO DE ORDEM DE SERVICO*** //

Return ( Nil )

/*{Protheus.doc} User Function ADCH005
	Valida numero do chamado digitado - CHAMADOS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function RetChm( _cChamado )

	Local _aArea		:= GetArea()
	Local _cChamado	:= Iif( _cChamado != Nil, _cChamado, PA9->PA9_CODIGO )
	Local _lPesqChm	:= .F.
	Local _lRet			:= .F.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Valida Chamado                                               
	
	If AllTrim( Upper( FunName() ) ) == "ADCH005"
		
		dbSelectArea( "PA9" )
		dbSetOrder( 01 )
		
		If !Empty( M->PAA_CHAMAD )
			
			_lRet			:= .T.
			_lPesqChm	:= .T.
			
			If !dbSeek( xFilial( "PA9" ) + M->PAA_CHAMAD )
				Help( " ", 01, "REGNOIS" )
				RestArea( _aArea )
				Return ( .F. )
			EndIf
			
		EndIf
		
	Else
		_lPesqChm := .T.
	EndIf
	
	If _lPesqChm
		
		M->PAA_CHAMAD	:= PA9->PA9_CODIGO
		M->PAA_SOLICI	:= PA9->PA9_SOLIC
		M->PAA_PRIOR	:= PA9->PA9_PRIOR
		M->PAA_DGRUPO	:= PA9->PA9_DGRUPO
		M->PAA_DSGRUP	:= PA9->PA9_DSGRUP
		M->PAA_DSERVI	:= PA9->PA9_DSERVI
		M->PAA_ESCOPO	:= PA9->PA9_ESCOPO
		M->PAA_DUNID	:= PA9->PA9_DUNID
		M->PAA_CCDESC	:= PA9->PA9_CCDESC
		M->PAA_USUARI	:= PA9->PA9_USUARI
		M->PAA_RAMAL	:= PA9->PA9_RAMAL
		M->PAA_MAILUS	:= PA9->PA9_MAILUS
		M->PAA_VERSAO	:= "01"
		
		dbSelectArea( "PA6" )
		dbSetOrder( 01 )
		
		If dbSeek( xFilial( "PA6" ) + PA9->PA9_GRUPO + PA9->PA9_SGRUPO + PA9->PA9_SERVIC )
			M->PAA_RESP		:= PA6->PA6_DRESP
			M->PAA_ESPE		:= PA6->PA6_DESPE
		EndIf
		
	EndIf
	
	RestArea( _aArea )

Return ( _lRet )

/*{Protheus.doc} User Function OSOK
	Validacao do AxInclui - ORDEM DE SERVICO 
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function OSOK()

	Local _aArea	:= GetArea()
	Local lRet		:= .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')

	//Atualiza Chamado                                             
	
	dbSelectArea( "PA9" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "PA9" ) + M->PAA_CHAMAD )
		
		If INCLUI .Or. ( "ADCH004" $ AllTrim( Upper( FunName() ) ) )
			
			RecLock( "PA9", .F. )
			PA9->PA9_DTINI		:= M->PAA_DTINI
			PA9->PA9_OS			:= M->PAA_CODIGO
			PA9->PA9_PREVOS	:= M->PAA_DTPREV
			PA9->( MsUnLock() )
			
		EndIf
		
	EndIf
	
	RestArea( _aArea )

Return ( lRet )

/*{Protheus.doc} User Function AtuOS
	Funcao auxiliar do AxInclui - ORDEM DE SERVICO
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function AtuOS()

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')

	If INCLUI

		RecLock( "PAA", .F. )
		PAA->PAA_USRINC := AllTrim( Upper( U_ADCHUsr( 04 ) ) )
		PAA->( MsUnLock() )
		
		U__MAILDC()
		
	EndIf

Return ( Nil )

/*{Protheus.doc} User Function VlPrevOs
	Valida digitacao da data prevista para encerramento
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function VlPrevOs( _dDataVld )

	//Variaveis Locais                                             
	
	Local _lRet	:= .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Validacao                                                    
	
	If _dDataVld < M->PAA_DTINI
		U_OSMsg( STR0013, STR0033 )
		_lRet := .F.
	EndIf

Return ( _lRet )

/*{Protheus.doc} User Function ExclOS
	Exclusão de O.S
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function ExclOS()

	Local _aArea	:= GetArea()

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Validacao                                                    
	
	dbSelectArea( "PA9" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "PA9" ) + PAA->PAA_CHAMAD )
		
		RecLock( "PA9", .F. )
		PA9->PA9_DTINI		:= CtoD( "" )
		PA9->PA9_OS			:= ""
		PA9->PA9_PREVOS	:= CtoD( "" )
		PA9->( MsUnLock() )
		
	EndIf
	
	RestArea( _aArea )

Return ( .T. )

/*{Protheus.doc} User Function OSMsg
	Mensagens   
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function OSMsg( _cTitulo, _cAssunto )

	Local oDlg
	Local _cTitulo		:= Iif( _cTitulo  != Nil, OemToAnsi( _cTitulo  ), OemToAnsi( STR0013 ) )
	Local _cAssunto	:= Iif( _cAssunto != Nil, OemToAnsi( _cAssunto ), OemToAnsi( STR0036 ) )

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	Define MsDialog oDlg Title _cTitulo From 03, 00 To 340, 417 Pixel
	
	@ 05, 05 Get oMemo Var _cAssunto MEMO HScroll ReadOnly Size 200, 145 Of oDlg Pixel
	
	oMemo:bRClicked := {||AllwaysTrue()}
	
	Define SButton From 153, 175 Type 01 Action oDlg:End() Enable Of oDlg Pixel
	
	Activate MsDialog oDlg Centered

Return ( Nil )

/*{Protheus.doc} User Function OSAltOK
	Validacoes de alteracao 
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function OSAltOK()

	Local lRet := .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')

	//Atualiza Historico de alteracao                              
	
	If ALTERA
		M->PAA_USRALT	:= AllTrim( Upper( U_ADCHUsr( 04 ) ) )
		M->PAA_DTALT	:= Date()
		M->PAA_HRALT	:= Time()
		M->PAA_VERSAO	:= Iif( !Empty( M->PAA_VERSAO ), RetAsc( ( Val( M->PAA_VERSAO ) + 01 ), 02, .T. ), "01"  )
		M->PAA_HIST		+= Iif( !Empty( M->PAA_HIST ), Chr( 10 ), "" ) + "O.S. Versao " + PAA->PAA_VERSAO + CRLF + AllTrim( PAA->PAA_DESCRI )
	Endif
	
	If M->PAA_TPENCE == "3"
		
		_aDadTrf := TransfOS()
		
		IF _aDadTrf [1]=0
			
			lRet := .F.
			
		Endif
		
	endif
	
	if lRet .and. M->PAA_TECNIC <> PAA->PAA_TECNIC
		U__MAILDC()
	endif
	
	// *** INICIO WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + M->PAA_TECNIC )
	
		IF AA1->AA1_TRELLO == .T. .AND. M->PAA_TRELLO <> ''
		
			IF lRet          == .T.            .AND. ;
			   (M->PAA_TPENCE <> PAA->PAA_TPENCE .OR. ; 
			   M-> PAA_TECNIC <> PAA-> PAA_TECNIC)
			   
			   
			   
			   cUrl      := 'http://'+Alltrim(nIpSrvTrll)+'/api/move/' + ALLTRIM(M->PAA_TRELLO) + '/' + ALLTRIM(M->PAA_TECNIC) + '/' + ALLTRIM(M->PAA_TPENCE)
			   cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
		
			ENDIF
			
			IF lRet          == .T.          .AND. ;
			   M->PAA_PRIOR <> PAA->PAA_PRIOR 
			   
			   cUrl      := 'http://'+Alltrim(nIpSrvTrll)+'/api/label/' + ALLTRIM(M->PAA_TRELLO) + '/' + ALLTRIM(M->PAA_PRIOR )
			   cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
		
			ENDIF
			
			// *** INICIO WILLIAM COSTA 25/10/2018 044776 || OS 045924 || TECNOLOGIA || WILLIAM_COSTA || 8905 || TRELLO *** //
			IF lRet                   == .T.             .AND. ;
			   M->PAA_DRESUM          <> PAA->PAA_DRESUM .AND. ;
			   ALLTRIM(M->PAA_TRELLO) <> '' 
			      
			    cDescResumid := PAA->PAA_DRESUM              
				
			ENDIF
		ENDIF
	ENDIF		
	// *** FINAL WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //
	
Return ( lRet )

/*{Protheus.doc} User Function LegOS
	Legendas
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function LegOS()

	Local _aArea		:= GetArea()
	Local _aLegenda	:= {{ "BR_AMARELO"	, OemToAnsi( STR0077 ) },;
	                    { "BR_BRANCO"	, OemToAnsi( STR0170 ) },;
	                    { "BR_AZUL"		, OemToAnsi( STR0165 ) },;
	                    { "BR_LARANJA"	, OemToAnsi( STR0075 ) },;
	                    { "BR_PINK"		, OemToAnsi( STR0076 ) },;
	                    { "BR_CINZA"	, OemToAnsi( STR0164 ) },;
	                    { "BR_PRETO"	, OemToAnsi( STR0079 ) },;
	                    { "BR_VERDE"	, OemToAnsi( STR0166 ) },;
	                    { "BR_MARROM"	, OemToAnsi( STR0171 ) },;
	                    { "BR_VERMELHO"	, OemToAnsi( STR0078 ) } }

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')						
	
	BrwLegenda( OemToAnsi( STR0007 ), OemToAnsi( STR0023 ), _aLegenda )
	
	RestArea( _aArea )

Return ( Nil )

/*{Protheus.doc} User Function VldTpEnc
	Valida tipo de encerramento da ordem de servico
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function VldTpEnc()

	Local _lRet	:= .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	If AllTrim( Upper( FunName() ) ) == "ADCH005" .And. !INCLUI
		
		If M->PAA_TPENCE == "4"
			_lRet := .F.
			U_OSMsg( STR0013, STR0081 )
		ElseIf M->PAA_TPENCE == "5"
			_lRet := .F.
			U_OSMsg( STR0013, STR0116 )
		ElseIf Empty( M->PAA_TPENCE )
			_lRet := .F.
			U_OSMsg( STR0013, STR0082 )
		EndIf
		
	EndIf

Return ( _lRet )

/*{Protheus.doc} User Function MntArraySX3
	Monta array com os campos SX3 obrigatorios em ordem
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

Static Function MntArraySX3( _cArquivo )

	Local _aArea	:= GetArea()
	Local _aArray	:= {}
	
	dbSelectArea( "SX3" )
	dbSetOrder( 01 )
	
	If !dbSeek( _cArquivo )
		Return( _aArray )
	EndIf
	
	While SX3->( !Eof() ) .And. AllTrim( SX3->X3_ARQUIVO ) == AllTrim( _cArquivo )
		
		If X3Uso( SX3->X3_USADO )
			aAdd( _aArray, { SX3->X3_CAMPO, Iif( SX3->X3_TIPO == "C", "", Iif( SX3->X3_TIPO == "N", 00, Iif( SX3->X3_TIPO == "D", StoD( "" ), "" ) ) ), Nil } )
		EndIf
		
		SX3->( dbSkip() )
		
	EndDo
	
	RestArea( _aArea )

Return ( _aArray )

/*{Protheus.doc} User Function TransfOS
	Transferencia de Ordem de Servico
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

Static Function TransfOS()

	Local _aArea		:= GetArea()
	Local _cTecDest	:= Space( 06 )
	Local _dPrevisao	:= dDataBase
	Local _cObs			:= ""
	Local _nOpca		:= 00
	Private _cNomDest	:= Space( 50 )
	
	//Monta tela de transferencia                                  
	
	Define MsDialog oDlg1 Title OemToAnsi( STR0092 ) + AllTrim( PAA->PAA_CODIGO ) From 05, 00 To 26 /*23*/ , 65
	
	@ 040.0, 05 Say OemToAnsi( STR0089 ) + " " + OemToAnsi( STR0090 ) Size 080, 10 Pixel Of oDlg1
	@ 039.2, 50 MsGet PAA->PAA_TECNIC Size 030, 10 Pixel Of oDlg1 F3 "AA1" When .F.
	@ 039.2, 88 MsGet PAA->PAA_NOMTEC Size 150, 10 Pixel Of oDlg1 When .F.
	
	@ 055.0, 05 Say OemToAnsi( STR0089 ) + " " + OemToAnsi( STR0091 ) Size 080, 10 Pixel Of oDlg1
	@ 054.2, 50 MsGet _cTecDest Size 030, 10 Pixel Of oDlg1 F3 "AA1" Valid RetTec( _cTecDest )
	@ 054.2, 88 MsGet _cNomDest Size 150, 10 Pixel Of oDlg1 When .F.
	
	@ 070.0, 05 Say OemToAnsi( STR0093 ) Size 080, 10 Pixel Of oDlg1
	@ 069.2, 50 MsGet PAA->PAA_DTPREV Size 030, 10 Pixel Of oDlg1 When .F.
	
	@ 085.0, 05 Say OemToAnsi( STR0094 ) Size 080, 10 Pixel Of oDlg1
	@ 084.2, 50 MsGet _dPrevisao Size 030, 10 Pixel Of oDlg1 Valid _dPrevisao >= dDataBase
	
	@ 100.0, 05 Say OemToAnsi( STR0095 ) Size 080, 10 Pixel Of oDlg1
	@ 099.2, 50 Get oMemo Var _cObs MEMO HScroll Size 200, 45 Of oDlg1 Pixel Valid !Empty( _cObs )
	
	Activate MsDialog oDlg1 On Init EnchoiceBar( oDlg1, {||_nOpca := 01, oDlg1:End() },{||_nOpca := 00, oDlg1:End()} ) Centered
	
	RestArea( _aArea )

Return ( { _nOpca, _cTecDest, _cNomDest, _dPrevisao, _cObs } )

/*{Protheus.doc} User Function RetTec
	Retorna nome do tecnico
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

Static Function RetTec( _cTecDest )

	Local _lRet := .F.
	
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + _cTecDest )
		
		_cNomDest	:= AA1->AA1_NOMTEC
		
		_lRet := .T.
		
	Else
		U_OSMsg( STR0013, STR0097 )
	EndIf

Return ( _lRet )

/*{Protheus.doc} User Function WhenAct
	Validacao When - SX3 para campos de aceite
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function WhenAct( _cCampo )

	Local _lRet := .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	If "ADCH004" $ AllTrim( Upper( FunName() ) )
		_lRet := !( AllTrim( Upper( _cCampo ) ) $ "PAA_TPENCE" )
	Else
		
		If INCLUI
			_lRet := !( AllTrim( Upper( _cCampo ) ) $ "PAA_TPENCE/PAA_ACEITE/PAA_USRACT/PAA_DTACT/PAA_HRACT/PAA_AVLACT" )
		Else
			_lRet := !( AllTrim( Upper( _cCampo ) ) $ "PAA_ACEITE/PAA_USRACT/PAA_DTACT/PAA_AVLACT/PAA_HRACT" )
		EndIf
		
	EndIf

Return ( _lRet )

/*{Protheus.doc} User Function InfObsAct
	Obsrvacao do aceite
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

Static Function InfObsAct()

	Local _aArea		:= GetArea()
	Local _cObsAct		:= ""
	Local _nOpca		:= 00
	
	//Monta tela de Observacao do aceite                           
	
	Define MsDialog oDlg1 Title OemToAnsi( STR0108 ) + " " + AllTrim( PAA->PAA_CODIGO ) From 05, 00 To 21, 65  //Fernando Sigoli 22/06/2019

	//@ 020, 05 Get oMemo Var _cObsAct MEMO HScroll Size 246, 075.5 Of oDlg1 Pixel Valid !Empty( _cObsAct )
	@ 033, 05 Get oMemo Var _cObsAct MEMO HScroll Size 246, 075.5 Of oDlg1 Pixel Valid !Empty( _cObsAct ) //Fernando Sigoli 22/06/2019

	Activate MsDialog oDlg1 On Init EnchoiceBar( oDlg1, {||_nOpca := 01, oDlg1:End() },{||_nOpca := 00, oDlg1:End()} ) Centered
	
	RestArea( _aArea )

Return ( { _nOpca == 01, Iif( !Empty( _cObsAct ), _cObsAct, OemToAnsi( STR0109 ) ) } )

/*{Protheus.doc} User Function HrsUtil
	Valida campo Horas utilizadas
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function HrsUtil()

	Local _lRet		:= .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Validacoes
	If INCLUI .Or. ALTERA
		_lRet := .F.
	EndIf
	
	//Calcula quantidade de horas utilizadas
	
	If _lRet
		M->PAA_HRSUTL := ATTotHora( M->PAA_DTINI, M->PAA_HRINI, M->PAA_FIM, M->PAA_HRFIM )
	EndIf

Return ( _lRet )

/*{Protheus.doc} User Function ValidOS
	Valida OS
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

User Function ValidOS()

	Local lREt := .T.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	IF _nOPC=4
		If !M->PAA_TPENCE$"0/2/6/7/8/9"
			lRet:= .F.
			Alert("Permitido somente as opções 0, 2, 6, 7, 8 ou 9")
		Endif
	ELSEIF _nOPC=5
		If !M->PAA_TPENCE$"1/3/4"
			lRet:= .F.
			Alert("Permitido somente as opções 1, 3 ou 4")
		Endif
		
		M->PAA_FIM 		:= DATE()
		M->PAA_HRFIM	:= TIME()
		
	EndIf

Return ( lRet )

User Function INICPO()

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')

	M->PAA_TPENCE := '1'
	M->PAA_FIM 		:= DATE()
	M->PAA_HRFIM	:= TIME()
	
RETURN

User function HSOS

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')	

	//AxCadastro(cAlias,cTitle,cDel,cOk,aRotAdic,bPre,bOK,bTTS,bNoTTS,aAuto,nOpcAuto,aButtons,aACS)
	DBSELECTAREA("PAI")
	PAI->( dbsetfilter({|| PAI_OS = PAA->PAA_CODIGO},"PAI_OS = PAA->PAA_CODIGO") )
	Axcadastro("PAI","Apontamento de Horas - OS "+PAA->PAA_CODIGO)
	DBSELECTAREA("PAA")
	
Return

/*{Protheus.doc} User Function calpos
	SOLICITACAO DE ACOMPANHAMENTO
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

USER FUNCTION CALPOS

	Private aArea:=GetArea()
	Private nopcX:=0
	Private cDescAcom:=""
	Private cHtml:=""
	Private cTo2 :=Space(200)

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	//Valida quanto ao status do chamado              
	
	if PAA->PAA_TPENCE $ '13'
		MsgInfo("Nao e' possivel solicitar acompanhamento a esse chamado"+CRLF+"Chamado encerrado ou transferido")
		Return
	EndIF
	
	//Chamada da Tela de Interassao                   
	
	nopcX:=MntCalPos()
	
	//TRATA O CANCELAMENTO DA ROTINA                  
	
	If nOpcx==0
		Return(NIL)
	EndIf
		
	//MONTA A STRING
	cDescAcomCH:=CRLF+;
	"EM "+DTOC(DATE())+" "+left(time(),5)+" - SOLICITAÇÃO DE ACOMPANHAMENTO"+CRLF+cDescAcom+CRLF+;
	"--------------------------------------------------------------------------------"
	
	//Monta corpo de Email
	cHtml+='<html>'
	cHtml+='<head>'
	cHtml+='<title>SOLICITAÇÃO DE ACOMPANHAMENTO DE CHAMADO</title>'
	cHtml+='</head>'
	cHtml+='<body>'
	
	cHtml+='<table border="1" cellpadding="0" cellspacing="0"  width="70%">'
	cHtml+='<tr>'
	cHtml+='	<th> Chamado:</th>'
	cHtml+='	<td>'+PAA->PAA_CHAMAD+'</td>'
	cHtml+=' </tr>'
	cHtml+='  <tr> '
	cHtml+='	<th> Descricao</th>'
	cHtml+='	<td>'+PAA->PAA_ESCOPO+'</td>'
	cHtml+=' </tr>'
	cHtml+='</table>'
	
	cHtml+='<H2>Solicitacao de Acompanhamento</H2>'
	
	cHtml+='<table border="1" cellpadding="0" cellspacing="0"  width="70%">'
	cHtml+='  <tr>'
	//cHtml+='  		<td>It</td>'
	cHtml+='  		<td >Descrição</td>'
	cHtml+='			<td>Solicitante</td>'
	cHtml+='			<td>Data</td>'
	
	cHtml+='</tr>'
	cHtml+='<tr >'
	//  		<td>001</td>
	cHtml+='		<td ><pre>'+cDescAcom+'</pre></td>'
	cHtml+='		<td>'+CUSERNAME+'</td>             '
	cHtml+='		<td>'+DTOC(DATE())+' - '+TIME()+'</td>'
	cHtml+='</tr>	'
	
	cHtml+='</table> '
	
	cHtml+='</body> '
	cHtml+='</html>'
	
	//GRAVA NA OS O ACOMPANHAMENTO
	
	RECLOCK("PAA",.F.)
	PAA_DESCRI:=PAA_DESCRI+cDescAcomCH
	//PAA_STATUS:="07"	//Aguardando retorno FeedBack
	//PAA_DESCST:="AGUARDANDO DEFINICAO / VALIDACAO USUARIO"
	PAA_TPENCE:='6'
	MSUNLOCK()
	
	// *** INICIO WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
	
		IF AA1->AA1_TRELLO == .T.
		
		   cUrl      := 'http://'+Alltrim(nIpSrvTrll)+'/api/move/' + ALLTRIM(PAA->PAA_TRELLO) + '/' + ALLTRIM(PAA->PAA_TECNIC) + '/' + ALLTRIM(PAA->PAA_TPENCE)
		   cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
		
		ENDIF
	ENDIF		
	// *** FINAL WILL TRELLO ALTERACAO DE ORDEM DE SERVICO*** //
	
	//GRAVA NO CONTROLE DE HORAS
	
	DbSelectAreA("PAI")
	RecLock("PAI",.T.)
	PAI_FILIAL:=XFILIAL("PAI")
	PAI_OS:=PAA->PAA_CODIGO
	PAI_DATA:=DDATABASE
	PAI_DESC:=cDescAcom
	PAI_HORAS:=0.05
	MsUnlock()
	
	//FAZ A PREPARACAO PARA O ENVIO DE EMAIL
	
	dbSelectArea( "PA9" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "PA9" ) + PAA->PAA_CHAMAD )
	
	_cTo := Lower( AllTrim( PA9->PA9_MAILUS ) )
	_cCC := Lower( AllTrim( PA9->PA9_CCOPIA ) )
	
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
		_cTo += Iif( !Empty( _cTo ), ";", "" ) + Lower( AllTrim( AA1->AA1_EMAIL ) )
	EndIf
	
	_cFrom := Alltrim(UsrRetMail(AA1->AA1_CODUSR))
	
	//Envia o Email de solicitacao de acompanhamento   
	
	_cCC:=_cCC+";"+cTo2
	
	MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo,_cCC, "Solicitação de Acompanhamento ["+PAA->PAA_CHAMAD+"]",, cHtml )}, "Enviando Email", "Enviando Solicitação", .F. )
	
	RestArea(aArea)
	
RETURN

/*{Protheus.doc} User Function MntCalPos
	Monta tela de acompanhamento dos chamados
	@type  Function
	@author Celso Costa
	@since 03/10/2007
	@version 01
	
*/

Static Function MntCalPos

	Local oDlg1,oSay1,oSay2,oDescAcom,oTo2
	Local aButtons:={}
	Private nopcX:=0
	
	oDlg1      := MSDialog():New( 216,340,689,883,"Acompanhamento",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 038,004,{||"Descricao"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oDescAcom  := TMultiGet():New( 050,004,{|u| If(PCount()>0,cDescAcom:=u,cDescAcom)},oDlg1,256,128,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	
	oSay2      := TSay():New( 190,004,{||"Copia Para"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oTo2 := TGet():New( 190,050,{|U| IF(PCOUNT()>0,cTo2:=u,cto2 )},oDlg1,160,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTo2,,,, )
	oDlg1:bInit := {|| EnchoiceBar(oDlg1, {|| nopcX:=1,oDlg1:End()}, {|| nopcX:=0,oDlg1:End()},,aButtons)}
	oDlg1:Activate(,,,.T.)

Return(nopcX)

/*{Protheus.doc} User Function _MAILDC
	Monta tela de acompanhamento dos chamados
	@type  Function
	@author ADRIANA OLIVEIRA
	@since 22/05/2014 
	@version 01
	
*/

USER FUNCTION _MAILDC

	Local aArea		:=GetArea()
	Local cHtml		:=""
	Local _cTo   	:=""
	Local _cFrom 	:=""

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + M->PAA_TECNIC )
		_cTo := Lower( Alltrim(UsrRetMail(AA1->AA1_CODUSR)) )
	EndIf
	
	_cFrom := Lower( Alltrim(UsrRetMail(__CUSERID)) )
	
	if AA1->AA1_CODUSR <> __CUSERID
		//Monta corpo de Email
		
		cHtml+='<html>'
		cHtml+='<head>'
		cHtml+='<title>Distribuição de Chamados</title>'
		cHtml+='</head>'
		cHtml+='<body>'
		
		cHtml+='<table border="1" cellpadding="0" cellspacing="0"  width="70%">'
		cHtml+='<tr>'
		cHtml+='	<th> Chamado:</th>'
		cHtml+='	<td>'+PAA->PAA_CHAMAD+'</td>'
		cHtml+=' </tr>'
		cHtml+='  <tr> '
		cHtml+='	<th> Descricao</th>'
		cHtml+='	<td>'+PAA->PAA_ESCOPO+'</td>'
		cHtml+=' </tr>'
		cHtml+='</table>'
		
		cHtml+='<H2>Chamado distribuido para: '+M->PAA_NOMTEC+'</H2>'
		
		cHtml+='</table> '
		
		cHtml+='</body> '
		cHtml+='</html>'
		
		//Envia o Email                                    |
		
		MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo,, "Distribuição Chamado ["+PAA->PAA_CHAMAD+"]",, cHtml )}, "Enviando Email", "Enviando Distribuição", .F. )
		
	Endif
	
	RestArea(aArea)

Return Nil

USER FUNCTION EnviaTrello()

	Local lRetTrello := .F.

	U_ADINF009P('ADCH005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao de Ordens de Servicos')
	
	// *** INICIO WILL Envio de Chamado sem numero de Cartao no Trello 044776 || OS 045924 || TECNOLOGIA || WILLIAM_COSTA || 8905 || TRELLO  *** //
	dbSelectArea( "AA1" )
	dbSetOrder( 01 )
	
	If dbSeek( xFilial( "AA1" ) + PAA->PAA_TECNIC )
	
		IF AA1->AA1_TRELLO == .T.
		
			IF ALLTRIM(PAA->PAA_TRELLO) == ''
			   
			   cUrl := 'http://'+Alltrim(nIpSrvTrll)+'/api/call/' + ALLTRIM(PAA->PAA_CODIGO)    
				cHtmlPage := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
				
				IF !EMPTY(SUBSTRING(cHtmlPage,1,24)) 
				
					RecLock( "PAA", .F. )
					PAA->PAA_TRELLO := SUBSTRING(cHtmlPage,1,24)
					PAA->( MsUnLock() )
					
					M->PAA_TRELLO := SUBSTRING(cHtmlPage,1,24)
				    lRetTrello    := .T.
				    
				ENDIF
		
			ENDIF
		ENDIF
	ENDIF
	
	IF lRetTrello == .T.
	
		MsgAlert("OLÁ " + Alltrim(cUserName)       + CHR(10) + CHR(13)+;
				 " Cartão do Trello criado com Sucesso " )
	
	ELSEIF lRetTrello                 == .F. .AND. ;
	        (ALLTRIM(PAA->PAA_TRELLO) <> '' .OR. ;
	        ALLTRIM(M->PAA_TRELLO)    <> '')
	
		MsgAlert("OLÁ " + Alltrim(cUserName)       + CHR(10) + CHR(13)+;
				 " Não foi possivel Criar o Cartão, cartão já existe: " + M->PAA_TRELLO)
	
	ELSE
	
		MsgAlert("OLÁ " + Alltrim(cUserName)       + CHR(10) + CHR(13)+;
				 " Não foi possivel Criar o Cartão " )
	
	ENDIF		
	// *** FINAL WILL Envio de Chamado sem numero de Cartao no Trello 044776 || OS 045924 || TECNOLOGIA || WILLIAM_COSTA || 8905 || TRELLO  *** //

Return()
