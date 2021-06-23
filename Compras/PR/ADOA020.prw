#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2 
/*/{Protheus.doc} User Function ADOA020
	ManutenГЦo na tabela de Grupo de CC/Item x Aprovadores.
	AmarraГЦo UsuАrio x Centros de Custo 
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	@history Everson, 23/04/2020, Chamado 057611 - Tratamento para bloquear todos os itens, quando o grupo for bloqueado.
	/*/
User Function ADOA020()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define as variАveis utilizadas na rotina                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local bFiltPAF
	Local aAreaAtu	:= GetArea()
	Local aCores 	:= {	{ "PAF_MSBLQL <> '1'", "BR_VERDE"		},;  // Ativo
	{ "PAF_MSBLQL == '1'", "BR_VERMELHO"	} }  // Inativo
	Local aRegs		:= {}
	Local aIndexPAF	:= {}
	Local lWhen		:= .T.
	Local cPerg		:= PadR( "ADOA02", 10, " ")
	Local cQueryPAF	:= ""
	Local cFilMbPAF	:= ""

	Private cString		:= "PAF"
	Private cCadastro 	:= OemtoAnsi( Alltrim( Posicione( "SX2", 1, cString, "X2_NOME" ) ) )
	Private aRotina		:= MenuDef()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If !Alltrim(__CUSERID) $ SuperGetMV("MV_#USUAPR",.f.,"000000")     //Incluido por Adriana para liberar acesso apenas aos usuАrios autorizados 12/12/2014
		Alert("Usuario nao Autorizado - MV_#USUAPR")
	else
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega as perguntas para a rotina                                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		CriaSX1( cPerg )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Faz a interface com o usuАrio relativo as perguntas de filtro                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Pergunte( cPerg, .T. )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Realiza a Filtragem das revisoes                                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If mv_par01 == 1
			#IFDEF TOP
				cQueryPAF	:= "PAF_MSBLQL <> '1'"
			#ELSE
				cQueryPAF   := "PAF_MSBLQL <> '1'"
				cFilMbPAF	:= "PAF_MSBLQL <> '1'"
				bFiltPAF	:= {|x| If( x == Nil, FilBrowse( "PAF", @aIndexPAF, @cFilMbPAF ),If(x == 1, cFilMbPAF, cQueryPAF ) ) }
				Eval(bFiltPAF)
			#ENDIF
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona no arquivo de usuАrios x centro de custo                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea( "PAF" )
		dbSetOrder( 1 )
		dbGoTop()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Faz a interface com o usuАrio dos registros jА cadastrados                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#IFDEF TOP
			mBrowse(6,1,22,75,"PAF",,,,,,aCores,,,,,,,,cQueryPAF)
		#ELSE
			mBrowse(6,1,22,75,"PAF",,,,,,aCores)
		#ENDIF
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Retorna os indices originais                                                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectArea( "PAF" )
		RetIndex( "PAF" )
		#IFNDEF TOP
			dbClearFilter()
			aEval( aIndexPAF, {|x| Ferase( x[1] + OrdBagExt() ) } )
		#ENDIF
		
	Endif

Return( Nil )
/*/{Protheus.doc} User Function Ado02Cad
	ManutenГЦo na tabela de grupo de aprovaГЦo.
	ParБmetros:
			ExpC1 - Alias do Arquivo    
            ExpN1 - NЗmero do Registro no arquivo 
            ExpN2 - OpГЦo selecionada no aRotina
	Retorno:
			ExpL1 - .T. Executou a rotina sem divergЙncia .F. NЦo conseguiu executar a rotina
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02Cad( cAlias, nReg, nOpcx )

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define as variАveis da rotina                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local nOpcConf		:= 0
	Local lRetorno		:= .T.
	Local lGravou		:= .F.
	Local aPosObj    	:= {}
	Local aObjects   	:= {}
	Local aSize      	:= MsAdvSize()
	Local aCposGet		:= {}
	Local nOpcA			:= 0
	Local nLoop1		:= 0
	Local nSaveSX8		:= GetSX8Len()

	Private oDlgMain
	Private oFldDados
	Private oGDados
	Private oVerde   	:= LoadBitMap(GetResources(),"BR_VERDE")
	Private oVermelho	:= LoadBitMap(GetResources(),"BR_VERMELHO")
	Private Inclui		:= .F.
	Private Altera		:= .F.
	Private lAdo02Vis	:= .F.
	Private lAdo02Inc	:= .F.
	Private lAdo02Alt	:= .F.
	Private lAdo02Exc	:= .F.
	Private aCols	 	:= {}
	Private aCposGet	:= {}
	Private aFields		:= {}
	Private aHeader 	:= {}
	Private aGets		:= {}
	Private aTELA   	:= {}

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no registro, caso ainda nЦo esteja posicionado                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea( cAlias )
	dbSetOrder( 1 )
	dbGoTo( nReg )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o status permite movimento                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcX == 6 .And. PAF->PAF_MSBLQL == "1"
		Aviso(	cCadastro,;
		"O cadastro de aprovadores jА esta bloqueado." + CRLF +;
		"OpГЦo nЦo pode ser executada.",;
		{ "&Retorna" },,;
		"Bloqueado" )
		Return( .F. )
	EndIf
	If nOpcX == 7 .And. PAF->PAF_MSBLQL == "2"
		Aviso(	cCadastro,;
		"O cadastro de aprovadores jА esta desbloqueado." + CRLF +;
		"OpГЦo nЦo pode ser executada.",;
		{ "&Retorna" },,;
		"Desbloqueado" )
		Return( .F. )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a operacao que esta sendo executada                                              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcx == 3
		lAdo02Inc	:= .T.
		Inclui		:= .T.
		RegToMemory( "PAF", .T. )
	ElseIf nOpcx == 4
		lAdo02Alt	:= .T.
		Altera		:= .T.
		RegToMemory( "PAF", .F. )
	Elseif nOpcx == 5
		lAdo02Exc	:= .T.
		RegToMemory( "PAF", .F. )
	Else
		lAdo02Vis	:= .T.
		RegToMemory( "PAF", .F. )
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta os campos da enchoice                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea( "SX3" )
	dbSetOrder( 1 )
	MsSeek( "PAF" )
	While	SX3->( !Eof() ) .And. SX3->X3_ARQUIVO $ "PAF"
		If X3USO(X3_USADO) .And.;
			cNivel >= X3_NIVEL .And.;
			( !Alltrim( SX3->X3_CAMPO ) $ "PAF_FILIAL/PAF_MSBLQL/PAF_USERGI/PAF_USERGA")
			aAdd( aFields, AllTrim( SX3->X3_CAMPO ) )
			aAdd( aCposGet, AllTrim( SX3->X3_CAMPO ) )
		EndIf
		SX3->( dbSkip() )
	EndDo
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o header do arquivo                                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea( "SX3" )
	dbSetOrder( 1 )
	MsSeek( "PAG" )
	While	SX3->( !Eof() ) .And. SX3->X3_ARQUIVO $ "PAG"
		If X3USO(X3_USADO) .And.;
			cNivel >= X3_NIVEL .And.;
			( !Alltrim( SX3->X3_CAMPO ) $ "PAG_FILIAL/PAG_CODGRP/PAG_DESCRI/PAG_USERGI/PAG_USERGA")
			aAdd( aHeader,{	AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX,;
			SX3->X3_RELACAO,;
			SX3->X3_WHEN,;
			SX3->X3_VISUAL,;
			SX3->X3_VLDUSER,;
			SX3->X3_PICTVAR,;
			SX3->X3_OBRIGAT})
		EndIf
		SX3->( dbSkip() )
	EndDo
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o acols  do arquivo                                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcx <> 3
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Varre o arquivo e pega os registros relativos a chave                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea( "PAG" )
		dbSetOrder( 1 )
		MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP, .F.)
		While PAG->( !Eof() ) .And. PAG->PAG_FILIAL == xFilial( "PAG" ) .And. PAG->PAG_CODGRP == M->PAF_CODGRP
			aAdd( aCols, Array( Len( aHeader ) + 1 ) )
			For nLoop1 := 1 To Len( aHeader )
				If AllTrim( aHeader[nLoop1,2] ) == "PAG_NOMUSR"
					aCols[Len(aCols),nLoop1]	:= UsrRetName( PAG->PAG_IDUSER )
				ElseIf AllTrim( aHeader[nLoop1,10] ) <> "V"
					aCols[Len(aCols),nLoop1]	:= PAG->&( aHeader[nLoop1,2] )
				Else
					aCols[Len(aCols),nLoop1]	:= Criavar( aHeader[nLoop1,2] )
				EndIf
			Next nLoop1
			aCols[Len(aCols), Len( aHeader ) + 1] := .F.
			PAG->( dbSkip() )
		EndDo
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta os acols se o mesmo estiver vazio                                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcx == 3 .Or. Len( aCols ) == 0
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Adiciona um elemento vazioestiver vazio                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Len( aCols ) == 0
			aAdd( aCols, Array( Len( aHeader ) + 1) )
			For nLoop1 := 1 To Len( aHeader )
				aCols[Len(aCols),nLoop1]	:= CriaVar( aHeader[nLoop1,02] )
			Next nLoop1
			aCols[Len(aCols), Len( aHeader ) + 1] := .F.
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a area dos objetos                                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aObjects := {}
	AAdd( aObjects, { 100, 090, .t., .f. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )

	aInfo 		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj 	:= MsObjSize( aInfo, aObjects )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface principal com o usuАrio                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oDlgMain := TDialog():New(aSize[7],00,aSize[6],aSize[5],cCadastro,,,,,,,,oMainWnd,.T.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta os gets de cabeГalho                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oEnc	:= Enchoice( "PAF", nReg, If( nOpcX == 6 .Or. nOpcX == 7, 2, nOpcX),,,, aFields,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],aPosObj[1,4]-aPosObj[1,2]}, aCposGet,3)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o folder dos itens                                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oFldDados 	:= TFolder():New(aPosObj[2,1]-10,aPosObj[2,2],{ "&Aprovadores" },,oDlgMain,,,,.T.,.T.,(aPosObj[2,4]-aPosObj[2,2]),((aPosObj[2,3]-aPosObj[2,1])+10))
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a getdados da folder                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
	oGDados := MsNewGetDados():New(000,000,oFldDados:aDialogs[1]:nClientHeight/2,oFldDados:aDialogs[1]:nClientWidth/2,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),,,,,,9999,,,,oFldDados:aDialogs[1],@aHeader,@aCols)
	oGDados:bLinhaOk	:= { || U_Ado02LOk() }
	oGDados:bTudoOk 	:= { || U_Ado02TOk() }
	oDlgMain:Activate(,,,,,,{||EnchoiceBar(oDlgMain,{||Iif(nOpcx == 2, (nOpcA := 0,oDlgMain:End()), nOpcA := If(Obrigatorio(aGets,aTela),1,0)),If(nOpcA==1,oDlgMain:End(),Nil)},{||oDlgMain:End()},,)})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Efetua a gravacao das informacoes                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpca == 1
		lGravou := GrvDados( @lRetorno, nOpcX, @nSaveSX8 )
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se for inclusЦo e gravou os dados atualiza SX8                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If INCLUI .And. lGravou
		While GetSx8Len() > nSaveSX8
			ConfirmSX8()
		EndDo
	Else
		While GetSx8Len() > nSaveSX8
			RollBackSX8()
		EndDo
	EndIf

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02ICC
	Valida e Atualiza descriГЦo do centro de custo 
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02ICC()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu	:= GetArea()
	Local aAreaCTT	:= CTT->( GetArea() )
	Local lRetorno	:= .T.
	Local cCampo	:= ReadVar()
	Local cCCusto	:= &( ReadVar() )
	Local cCCIni	:= M->PAF_CCINI
	Local cCCFim	:= M->PAF_CCFIM

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If "PAF_CCINI" $ cCampo
		cCCIni	:= &( ReadVar() )
	EndIf
	If "PAF_CCFIM" $ cCampo
		cCCFim	:= &( ReadVar() )
	EndIf

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pesquisa se o centro de custo existe                                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea( "CTT" )
	dbSetOrder( 1 )
	If !( MsSeek( xFilial( "CTT" ) + cCCusto, .F. ) )
		Aviso(	cCadastro,;
		"Centro de Custo nЦo localizado no cadastro." + Chr(13) + Chr(10) +;
		"Informe um centro de custo vАlido.",;
		{ "&Retorna" },2,;
		"Centro de Custo: " + cCCusto )
		lRetorno	:= .F.
	Else
		If CTT->CTT_CLASSE == "1"
			Aviso(	cCadastro,;
			"Centro de Custo sintИtico. NЦo pode ser utilizado.",;
			{ "&Retorno" },,;
			"Centro de Custo: " + cCCusto )
			lRetorno	:= .F.
		Else
			If lRetorno .And. "PAF_CCINI" $ cCampo .And. !Empty( cCCFim ) .And. cCCIni > cCCFim
				Aviso(	cCadastro,;
				"Centro de Custo inicial nЦo pode ser maior que o final.",;
				{ "&Retorna" },,;
				"Centro de Custo: " + cCCIni )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_CCFIM" $ cCampo .And. !Empty( cCCIni ) .And. cCCFim < cCCIni
				Aviso(	cCadastro,;
				"Centro de Custo final nЦo pode ser menor que o inicial.",;
				{ "&Retorna" },,;
				"Centro de Custo: " + cCCFim )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_CCINI" $ cCampo
				M->PAF_NOMCCI	:= CTT->CTT_DESC01
				If Empty( cCCFim )
					M->PAF_CCFIM	:= cCCusto
					M->PAF_NOMCCF	:= CTT->CTT_DESC01
				EndIf
			ElseIf lRetorno .And. "PAF_CCFIM" $ cCampo
				M->PAF_NOMCCF	:= CTT->CTT_DESC01
			EndIf
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura as Аreas originais                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaCTT )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02IIT
	Valida e Atualiza descriГЦo do item contАbil 
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02IIT()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu	:= GetArea()
	Local aAreaCTD	:= CTD->( GetArea() )
	Local lRetorno	:= .T.
	Local cCampo	:= ReadVar()
	Local cItem		:= &( ReadVar() )
	Local cItIni	:= M->PAF_ITINI
	Local cItFim	:= M->PAF_ITFIM

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If "PAF_ITINI" $ cCampo
		cItIni	:= &( ReadVar() )
	EndIf
	If "PAF_ITFIM" $ cCampo
		cItFim	:= &( ReadVar() )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pesquisa se o centro de custo existe                                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea( "CTD" )
	dbSetOrder( 1 )
	If !( MsSeek( xFilial( "CTD" ) + cItem, .F. ) )
		Aviso(	cCadastro,;
		"Item ContАbil nЦo localizado no cadastro." + Chr(13) + Chr(10) +;
		"Informe um item contАbil vАlido.",;
		{ "&Retorna" },2,;
		"Item ContАbil: " + cItem )
		lRetorno	:= .F.
	Else
		If CTD->CTD_CLASSE == "1"
			Aviso(	cCadastro,;
			"Item ContАbil sintИtico. NЦo pode ser utilizado.",;
			{ "&Retorno" },,;
			"Item ContАbil: " + cItem )
			lRetorno	:= .F.
		Else
			If lRetorno .And. "PAF_ITINI" $ cCampo .And. !Empty( cITFim ) .And. cITIni > cITFim
				Aviso(	cCadastro,;
				"Item ContАbil inicial nЦo pode ser maior que o final.",;
				{ "&Retorna" },,;
				"Item ContАbil: " + cITIni )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_ITFIM" $ cCampo .And. !Empty( cITIni ) .And. cITFim < cITIni
				Aviso(	cCadastro,;
				"Item ContАbil final nЦo pode ser menor que o inicial.",;
				{ "&Retorna" },,;
				"Item ContАbil: " + cITFim )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_ITINI" $ cCampo
				M->PAF_NOMITI	:= CTD->CTD_DESC01
				If Empty( cITFim )
					M->PAF_ITFIM	:= cItem
					M->PAF_NOMITF	:= CTD->CTD_DESC01
				EndIf
			ElseIf lRetorno .And. "PAF_ITFIM" $ cCampo
				M->PAF_NOMITF	:= CTD->CTD_DESC01
			EndIf
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura as Аreas originais                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaCTD )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02IUs
	Inicializa o nome do usuАrio 
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02IUs()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.
	Local nPNomUsr	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_NOMUSR" } )

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualizao nome do usuАrio aprovador                                                     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCols[n,nPNomUsr]	:= UsrRetName( &( ReadVar() ) )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura as Аreas originais                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02VVl
	Valida o Valor Digitado 
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02VVl()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.
	Local nPVlrIni	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_VLRINI" } )
	Local nPVlrFim	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_VLRFIM" } )
	Local cCampo	:= ReadVar()
	Local nVlrIni	:= aCols[n,nPVlrIni]
	Local nVlrFim	:= aCols[n,nPVlrFim]

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If "PAG_VLRINI" $ cCampo
		nVlrIni	:= &( ReadVar() )
	EndIf
	If "PAG_VLRFIM" $ cCampo
		nVlrFim	:= &( ReadVar() )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Valida se o valor inicial И maior que o final                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ( "PAG_VLRINI" $ cCampo .And. !Empty( nVlrFim ) .And. nVlrIni > nVlrFim )
		Aviso(	cCadastro,;
		"Valor inicial superior ao valor final." + Chr(13) + Chr(10) +;
		"Corrigir os valores.",;
		{ "&Retorna" },2,;
		"Valores Divergentes")
		lRetorno	:= .F.
	EndIf
	If ( "PAG_VLRFIM" $ cCampo .And. !Empty( nVlrIni ) .And. nVlrFim < nVlrIni )
		Aviso(	cCadastro,;
		"Valor final inferior ao valor inicial." + Chr(13) + Chr(10) +;
		"Corrigir os valores.",;
		{ "&Retorna" },2,;
		"Valores Divergentes")
		lRetorno	:= .F.
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura as Аreas originais                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02LOk
	ValidaГЦo na linha da getdados  
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02LOk()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu     	:= GetArea()
	Local aAreaSX3		:= SX3->( GetArea() )
	Local lRetorno  	:= .T.
	Local nPIdUser		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_IDUSER" } )
	Local nLoop1		:= 0
	Local cIdUser		:= ""

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se a linha nЦo estiver deletada efetua as validaГУes                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !oGDados:aCols[oGDados:nAt, Len( aHeader ) + 1]
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se as variАveis digitadas sЦo vАlidas                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cIdUser		:= oGDados:aCols[oGDados:nAt, nPIdUser]
		lRetorno	:= UsrExist( cIdUser )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se tem algum campo obrigatСrio e nЦo preenchido                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRetorno
			For nLoop1 := 1 To Len( aHeader )
				dbSelectArea( "SX3" )
				dbSetOrder( 2 )
				If !MsSeek( aHeader[nLoop1, 02], .F. )
					Help( " ", 1, "OBRIGAT", , RetTitle( aHeader[nLoop1, 02] ), 4 )
					lRetorno := .F.
					Exit
				Else
					If	( VerByte( SX3->X3_RESERV,7 ) .Or.;
						( SubStr( BIN2STR( SX3->X3_OBRIGAT ), 1, 1 ) == "x" ) ) .And. Empty( oGDados:aCols[oGDados:nAt, nLoop1] )
						Help( " ", 1, "OBRIGAT", , RetTitle( aHeader[nLoop1, 02] ), 4 )
						lRetorno := .F.
						Exit
					Endif
				Endif
			Next nLoop1
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se tem duplicidade de informaГЦo                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRetorno
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Varre todos os itens do aCols                                                   Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLoop1 := 1 To Len( oGDados:aCols )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se nЦo estiver deletado e nЦo for a linha digitada                          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If	oGDados:aCols[nLoop1, Len( aHeader ) + 1] == .F. .And.;
					nLoop1 <> oGDados:nAt
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se encontra o id em outra linha                                Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If	oGDados:aCols[nLoop1,nPIdUser] == cIdUser
						Help( " ", 1, "JAGRAVADO", , , 4 )
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			Next nLoop1
		EndIf
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura as Аreas originais                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaSX3 )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02TOk
	ValidaГЦo na confirmaГЦo da getdados  
	Retorno:
			ExpL1 - .T. ValidaГУes corretas .F. ValidaГУes com divergЙncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02TOk()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local nLoop1		:= 0
	Local lRetorno		:= .F.
	Local nLnhOri		:= 0

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz a validaГЦo de linha para todos os itens                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nLoop1 := 1 To Len( oGDados:aCols )
		nLnhOri		:= oGDados:nAt
		oGDados:nAt := nLoop1
		lRetorno	:= U_Ado01LOk()
		If !lRetorno
			Exit
		EndIf
	Next nLoop1

Return( lRetorno )
/*/{Protheus.doc} User Function GrvDados
	Grava os dados da rotina 
	Retorno:
			ExpL1 - .T. gravaГЦo com sucesso .F. erro na gravaГЦo 
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
Static Function GrvDados( lRetorno, nOpcX )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declara as variАveis da rotina                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local nLoop1		:= 0
	Local nLoop2		:= 0
	Local nPNivel		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAG_NIVEL" } )
	Local nPIdUser		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAG_IDUSER" } )
	Local bCampo		:= { |nCpo| Field( nCpo ) }


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Validacao do codigo do grupo                                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	//Ana - Incluido para atender chamado 9801 - 04/05/2011
	If !ExistChav("PAF",M->PAF_CODGRP)
		Aviso(	"Grupo de Aprovadores - Aviso",;
		"Codigo do Grupo ja Cadastrado." + Chr(13) + Chr(10) +;
		"NЦo И possivel inclusao de mesmo codigo. O registro nЦo foi gravado!",;
		{ "&Retorna" },2,;
		"Codigo: " + M->PAF_CODGRP )
		Return( .F. )
	Endif

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se a opГЦo escolhida necessita gravaГЦo                                        Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcx > 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa a ampulheta de processamento e o controle de transaГЦo                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		CursorWait()
		Begin Transaction
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Limpa o filtro se nЦo for top                                                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#IFNDEF TOP
			dbSelectArea( "PAF" )
			RetIndex( "PAF" )
			dbClearFilter()
			aEval( aIndexPAF,{ |x| Ferase( x[1] + OrdBagExt() ) } )
		#ENDIF
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona no registro referente ao cabeГalho                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea( "PAF" )
		dbSetOrder( 1 )
		If MsSeek( xFilial( "PAF" ) + M->PAF_CODGRP )
			RecLock( "PAF", .F. )
		Else
			RecLock( "PAF", .T. )
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava os dados do cabeГalho                        		                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nLoop2 := 1 To PAF->( fCount() )
			FieldPut( nLoop2, M->&( Eval( bCampo, nLoop2 ) ) )
		Next nLoop2
		PAF->PAF_FILIAL	:= xFilial( "PAF" )
		MsUnLock()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё OpГЦo para Desbloqueio                                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpcX == 7
			RecLock( "PAF", .F. )
			PAF->PAF_MSBLQL	:= "2"
			MsUnLock()

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё OpГЦo para Bloqueio                                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nOpcX == 6

			//
			RecLock( "PAF", .F. )
				PAF->PAF_MSBLQL	:= "1"
			MsUnLock()

			//Everson - 23/04/2020. Chamado 057611.
				For nLoop1 := 1 To Len( oGDados:aCols )

					//
					DbSelectArea( "PAG" )
					PAG->(DbSetOrder(1))
					PAG->(DbGoTop())
					If PAG->( MsSeek( FWxFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] ) )

						//
						RecLock( "PAG", .F. )
							PAG->PAG_MSBLQL	:= "1"
						MsUnLock()

					EndIf

				Next nLoop1

				//
				DbSelectArea("PAF")
			//

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё OpГЦo para ExclusЦo                                                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nOpcX == 5
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Varre todo o acols                                                              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLoop1 := 1 To Len( oGDados:aCols )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Grava o registro como bloqueado                                             Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea( "PAG" )
				dbSetOrder( 1 )
				If PAG->( MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] ) )
					RecLock( "PAG", .F. )
					dbDelete()
					MsUnLock()
				Endif
			Next nLoop1
			dbSelectArea( "PAF" )
			dbDelete()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё OpГЦo para AlteraГЦo                                                                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nOpcX == 4
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Varre todo o acols                                                              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLoop1 := 1 To Len( oGDados:aCols )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se o item estiver deletado e encontrar o registro na base, deleta        	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If	oGDados:aCols[nLoop1, Len(aHeader) + 1] .And.;
					PAG->( MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] ) )
					RecLock( "PAG", .F. )
					dbDelete()
					MsUnLock()
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se o item nЦo estiver deletado atualiza dados                               Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				ElseIf !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
					dbSelectArea( "PAG" )
					If MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] )
						RecLock( "PAG", .F. )
					Else
						RecLock( "PAG", .T. )
					EndIf
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza os campos do acols                                             Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					For nLoop2 := 1 To Len( aHeader )
						If aHeader[nLoop2, 10] <> "V"
							PAG->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
						EndIf
					Next nLoop2
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza os campos fixos                                                Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PAG->PAG_FILIAL	:= xFilial( "PAG" )
					PAG->PAG_CODGRP	:= M->PAF_CODGRP
					dbSelectArea( "PAG" )
					MsUnlock()
				EndIf
			Next nLoop1
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё OpГЦo para InclusЦo                                                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf nOpcX == 3
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Varre todo o acols                                                              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLoop1 := 1 To Len( oGDados:aCols )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se o item nЦo estiver deletado atualiza dados                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
					dbSelectArea( "PAG" )
					dbSetOrder( 1 )
					If MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] )
						Aviso(	cCadastro,;
						"Foi encontrado registro com a chave pesquisada." + Chr(13) + Chr(10) +;
						"O registro nЦo serА gravado. Contate o Administrador do Sistema.",;
						{ "Retorna" },2,;
						"InclusЦo em Duplicidade" )
						lRetorno	:= .F.
						Exit
					Else
						RecLock( "PAG" , .T. )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza os campos do acols                                             Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						For nLoop2 := 1 To Len( aHeader )
							If aHeader[nLoop2, 10] <> "V"
								PAG->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
							EndIf
						Next nLoop2
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza os campos fixos                                                Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						PAG->PAG_FILIAL	:= xFilial( "PAG" )
						PAG->PAG_CODGRP	:= M->PAF_CODGRP
						dbSelectArea( "PAG" )
						MsUnlock()
					EndIf
				EndIf
			Next nLoop1
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza flag de processamento de gravaГЦo concluido	                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lRetorno	:= .T.
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Finaliza a transacao                               		                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		End Transaction
		CursorArrow()
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza o filtro se necessАrio quando nЦo for top                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If mv_par01 == 1
		#IFNDEF TOP
			Eval( bFiltPAF )
		#ENDIF
	EndIf

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02Leg
	Monta a tela de legenda para a rotina
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02Leg()

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	BrwLegenda("Legenda",cCadastro,{	{ "BR_VERDE"	, "Ativo"		},;
	{ "BR_VERMELHO"	, "Bloqueado"	} } )

Return
/*/{Protheus.doc} User Function MenuDef
	DefiniГЦo das rotinas para o programa.
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
Static Function MenuDef()

	Private aRotina	:= {}

	If( AllTrim( cVersao ) ) == "P10"
		aRotina		:= {	{ "Pesquisar",		"PesqBrw()",								0, 1, 0, Nil },;
		{ "Visualizar",		"U_Ado02Cad('PAF', PAF->( Recno() ), 2)",	0, 2, 0, Nil },;
		{ "Incluir",		"U_Ado02Cad('PAF', PAF->( Recno() ), 3)",	0, 3, 0, Nil },;
		{ "Alterar",		"U_Ado02Cad('PAF', PAF->( Recno() ), 4)",	0, 4, 0, Nil },;
		{ "Excluir",		"U_Ado02Cad('PAF', PAF->( Recno() ), 5)",	0, 5, 0, Nil },;
		{ "Bloquear", 		"U_Ado02Cad('PAF', PAF->( Recno() ), 6)",	0, 6, 0, Nil },;
		{ "Desbloquear",	"U_Ado02Cad('PAF', PAF->( Recno() ), 7)",	0, 6, 0, Nil },;
		{ "Legenda",		"U_Ado02Leg()",								0, 6, 0, Nil },; 
		{ "Rel.Alcadas",	"U_ADCOM026R()",							0, 7, 0, Nil }}
		
	Else
		aRotina		:= {	{ "Pesquisar",		"AxPesqui()",			0, 1 },;
		{ "Visualizar",		"U_Ado02Cad('PAF', PAF->( Recno() ), 2)",	0, 2 },;
		{ "Incluir",		"U_Ado02Cad('PAF', PAF->( Recno() ), 3)",	0, 3 },;
		{ "Alterar",		"U_Ado02Cad('PAF', PAF->( Recno() ), 4)",	0, 4 },;
		{ "Excluir",		"U_Ado02Cad('PAF', PAF->( Recno() ), 5)",	0, 5 },;
		{ "Bloquear",		"U_Ado02Cad('PAF', PAF->( Recno() ), 6)",	0, 6 },;
		{ "Desbloquear",	"U_Ado02Cad('PAF', PAF->( Recno() ), 7)",	0, 6 },;
		{ "Legenda",		"U_Ado02Leg()",								0, 6 },;
		{ "Rel.Alcadas",	"U_ADCOM026R()",							0, 7 }}
	EndIf

Return( aRotina )
/*/{Protheus.doc} User Function CriaSX1
	Cria o grupo de perguntas se nЦo existir.
	ParБmetros:
		ExpC1 = Alias do grupo de perguntas
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
Static Function CriaSX1( cPerg )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define as variАveis da rotina                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->( GetArea() )
	Local aTamSX3	:= {}
	Local aHelp		:= {}
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define os tМtulos e Help das perguntas                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//													"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	aAdd(aHelp,{	"Filtra os Bloqueados",	"",	"", {	"Informe Sim caso tenha necessidade de   ",	"filtrar os registros bloqueados ou NЦo  ",	"para exibir todos os registros          " },	{""},	{""} } )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava as perguntas no arquivo SX1                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//		cGrupo	cOrde	cDesPor			cDesSpa			cDesEng			cVar		cTipo		cTamanho	cDecimal	nPreSel	cGSC	cValid	cF3			cGrpSXG	cPyme	cVar01		cDef1Por		cDef1Spa	cDef1Eng	cCnt01	  					cDef2Por	cDef2Spa	cDef2Eng	cDef3Por	cDef3Spa	cDef3Eng	cDef4Por		cDef4Spa	cDef4Eng	cDef5Por	cDef5Spa	cDef5Eng	aHelpPor		aHelpEng		aHelpSpa		cHelp)
	PutSx1(	cPerg,	"01",	aHelp[01,1],	aHelp[01,2],	aHelp[01,3],	"mv_ch1",	"N",		1,			0,			2,		"C",	"",		"",			"",		"N",	"mv_par01",	"Sim",			"Si",		"Yes",		"",							"NЦo",		"No",		"No",		"",			"",			"",			"",				"",			"",			"",			"",			"",			aHelp[01,4],	aHelp[01,5],	aHelp[01,6],	"" )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Salva as Аreas originais                                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RestArea( aAreaSX1 )
	RestArea( aAreaAtu )

Return( Nil )