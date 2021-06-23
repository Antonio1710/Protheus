#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2 
/*/{Protheus.doc} User Function ADOA020
	Manuten��o na tabela de Grupo de CC/Item x Aprovadores.
	Amarra��o Usu�rio x Centros de Custo 
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	@history Everson, 23/04/2020, Chamado 057611 - Tratamento para bloquear todos os itens, quando o grupo for bloqueado.
	/*/
User Function ADOA020()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������

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

	If !Alltrim(__CUSERID) $ SuperGetMV("MV_#USUAPR",.f.,"000000")     //Incluido por Adriana para liberar acesso apenas aos usu�rios autorizados 12/12/2014
		Alert("Usuario nao Autorizado - MV_#USUAPR")
	else
		
		//�����������������������������������������������������������������������������������������Ŀ
		//� Carrega as perguntas para a rotina                                                      �
		//�������������������������������������������������������������������������������������������
		CriaSX1( cPerg )
		//�����������������������������������������������������������������������������������������Ŀ
		//� Faz a interface com o usu�rio relativo as perguntas de filtro                           �
		//�������������������������������������������������������������������������������������������
		Pergunte( cPerg, .T. )
		//�����������������������������������������������������������������������������������������Ŀ
		//� Realiza a Filtragem das revisoes                                                        �
		//�������������������������������������������������������������������������������������������
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
		//�����������������������������������������������������������������������������������������Ŀ
		//� Posiciona no arquivo de usu�rios x centro de custo                                      �
		//�������������������������������������������������������������������������������������������
		dbSelectArea( "PAF" )
		dbSetOrder( 1 )
		dbGoTop()
		//�����������������������������������������������������������������������������������������Ŀ
		//� Faz a interface com o usu�rio dos registros j� cadastrados                              �
		//�������������������������������������������������������������������������������������������
		#IFDEF TOP
			mBrowse(6,1,22,75,"PAF",,,,,,aCores,,,,,,,,cQueryPAF)
		#ELSE
			mBrowse(6,1,22,75,"PAF",,,,,,aCores)
		#ENDIF
		//�����������������������������������������������������������������������������������������Ŀ
		//� Retorna os indices originais                                                            �
		//�������������������������������������������������������������������������������������������
		DbSelectArea( "PAF" )
		RetIndex( "PAF" )
		#IFNDEF TOP
			dbClearFilter()
			aEval( aIndexPAF, {|x| Ferase( x[1] + OrdBagExt() ) } )
		#ENDIF
		
	Endif

Return( Nil )
/*/{Protheus.doc} User Function Ado02Cad
	Manuten��o na tabela de grupo de aprova��o.
	Par�metros:
			ExpC1 - Alias do Arquivo    
            ExpN1 - N�mero do Registro no arquivo 
            ExpN2 - Op��o selecionada no aRotina
	Retorno:
			ExpL1 - .T. Executou a rotina sem diverg�ncia .F. N�o conseguiu executar a rotina
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02Cad( cAlias, nReg, nOpcx )

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis da rotina                                                           �
	//�������������������������������������������������������������������������������������������
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

	//�����������������������������������������������������������������������������������������Ŀ
	//� Posiciona no registro, caso ainda n�o esteja posicionado                                �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( cAlias )
	dbSetOrder( 1 )
	dbGoTo( nReg )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Verifica se o status permite movimento                                                  �
	//�������������������������������������������������������������������������������������������
	If nOpcX == 6 .And. PAF->PAF_MSBLQL == "1"
		Aviso(	cCadastro,;
		"O cadastro de aprovadores j� esta bloqueado." + CRLF +;
		"Op��o n�o pode ser executada.",;
		{ "&Retorna" },,;
		"Bloqueado" )
		Return( .F. )
	EndIf
	If nOpcX == 7 .And. PAF->PAF_MSBLQL == "2"
		Aviso(	cCadastro,;
		"O cadastro de aprovadores j� esta desbloqueado." + CRLF +;
		"Op��o n�o pode ser executada.",;
		{ "&Retorna" },,;
		"Desbloqueado" )
		Return( .F. )
	EndIf
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define a operacao que esta sendo executada                                              �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta os campos da enchoice                                                             �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta o header do arquivo                                                               �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta o acols  do arquivo                                                               �
	//�������������������������������������������������������������������������������������������
	If nOpcx <> 3
		//��������������������������������������������������������������������������������������Ŀ
		//� Varre o arquivo e pega os registros relativos a chave                                �
		//����������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta os acols se o mesmo estiver vazio                                                 �
	//�������������������������������������������������������������������������������������������
	If nOpcx == 3 .Or. Len( aCols ) == 0
		//��������������������������������������������������������������������������������������Ŀ
		//� Adiciona um elemento vazioestiver vazio                                              �
		//����������������������������������������������������������������������������������������
		If Len( aCols ) == 0
			aAdd( aCols, Array( Len( aHeader ) + 1) )
			For nLoop1 := 1 To Len( aHeader )
				aCols[Len(aCols),nLoop1]	:= CriaVar( aHeader[nLoop1,02] )
			Next nLoop1
			aCols[Len(aCols), Len( aHeader ) + 1] := .F.
		EndIf
	EndIf
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define a area dos objetos                                                               �
	//�������������������������������������������������������������������������������������������
	aObjects := {}
	AAdd( aObjects, { 100, 090, .t., .f. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )

	aInfo 		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj 	:= MsObjSize( aInfo, aObjects )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta a interface principal com o usu�rio                                               �
	//�������������������������������������������������������������������������������������������
	oDlgMain := TDialog():New(aSize[7],00,aSize[6],aSize[5],cCadastro,,,,,,,,oMainWnd,.T.)
	//�������������������������������������������������������������������������������������Ŀ
	//� Monta os gets de cabe�alho                                                          �
	//���������������������������������������������������������������������������������������
	oEnc	:= Enchoice( "PAF", nReg, If( nOpcX == 6 .Or. nOpcX == 7, 2, nOpcX),,,, aFields,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],aPosObj[1,4]-aPosObj[1,2]}, aCposGet,3)
	//�������������������������������������������������������������������������������������Ŀ
	//� Monta o folder dos itens                                                            �
	//���������������������������������������������������������������������������������������
	oFldDados 	:= TFolder():New(aPosObj[2,1]-10,aPosObj[2,2],{ "&Aprovadores" },,oDlgMain,,,,.T.,.T.,(aPosObj[2,4]-aPosObj[2,2]),((aPosObj[2,3]-aPosObj[2,1])+10))
	//�������������������������������������������������������������������������������������Ŀ
	//� Monta a getdados da folder                                                          �
	//���������������������������������������������������������������������������������������
	//MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
	oGDados := MsNewGetDados():New(000,000,oFldDados:aDialogs[1]:nClientHeight/2,oFldDados:aDialogs[1]:nClientWidth/2,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),,,,,,9999,,,,oFldDados:aDialogs[1],@aHeader,@aCols)
	oGDados:bLinhaOk	:= { || U_Ado02LOk() }
	oGDados:bTudoOk 	:= { || U_Ado02TOk() }
	oDlgMain:Activate(,,,,,,{||EnchoiceBar(oDlgMain,{||Iif(nOpcx == 2, (nOpcA := 0,oDlgMain:End()), nOpcA := If(Obrigatorio(aGets,aTela),1,0)),If(nOpcA==1,oDlgMain:End(),Nil)},{||oDlgMain:End()},,)})
	//�����������������������������������������������������������������������������������������Ŀ
	//� Efetua a gravacao das informacoes                                                       �
	//�������������������������������������������������������������������������������������������
	If nOpca == 1
		lGravou := GrvDados( @lRetorno, nOpcX, @nSaveSX8 )
	Endif
	//�����������������������������������������������������������������������������������������Ŀ
	//� Se for inclus�o e gravou os dados atualiza SX8                                          �
	//�������������������������������������������������������������������������������������������
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
	Valida e Atualiza descri��o do centro de custo 
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02ICC()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
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

	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa se o centro de custo existe                                                    �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "CTT" )
	dbSetOrder( 1 )
	If !( MsSeek( xFilial( "CTT" ) + cCCusto, .F. ) )
		Aviso(	cCadastro,;
		"Centro de Custo n�o localizado no cadastro." + Chr(13) + Chr(10) +;
		"Informe um centro de custo v�lido.",;
		{ "&Retorna" },2,;
		"Centro de Custo: " + cCCusto )
		lRetorno	:= .F.
	Else
		If CTT->CTT_CLASSE == "1"
			Aviso(	cCadastro,;
			"Centro de Custo sint�tico. N�o pode ser utilizado.",;
			{ "&Retorno" },,;
			"Centro de Custo: " + cCCusto )
			lRetorno	:= .F.
		Else
			If lRetorno .And. "PAF_CCINI" $ cCampo .And. !Empty( cCCFim ) .And. cCCIni > cCCFim
				Aviso(	cCadastro,;
				"Centro de Custo inicial n�o pode ser maior que o final.",;
				{ "&Retorna" },,;
				"Centro de Custo: " + cCCIni )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_CCFIM" $ cCampo .And. !Empty( cCCIni ) .And. cCCFim < cCCIni
				Aviso(	cCadastro,;
				"Centro de Custo final n�o pode ser menor que o inicial.",;
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaCTT )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02IIT
	Valida e Atualiza descri��o do item cont�bil 
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02IIT()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa se o centro de custo existe                                                    �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "CTD" )
	dbSetOrder( 1 )
	If !( MsSeek( xFilial( "CTD" ) + cItem, .F. ) )
		Aviso(	cCadastro,;
		"Item Cont�bil n�o localizado no cadastro." + Chr(13) + Chr(10) +;
		"Informe um item cont�bil v�lido.",;
		{ "&Retorna" },2,;
		"Item Cont�bil: " + cItem )
		lRetorno	:= .F.
	Else
		If CTD->CTD_CLASSE == "1"
			Aviso(	cCadastro,;
			"Item Cont�bil sint�tico. N�o pode ser utilizado.",;
			{ "&Retorno" },,;
			"Item Cont�bil: " + cItem )
			lRetorno	:= .F.
		Else
			If lRetorno .And. "PAF_ITINI" $ cCampo .And. !Empty( cITFim ) .And. cITIni > cITFim
				Aviso(	cCadastro,;
				"Item Cont�bil inicial n�o pode ser maior que o final.",;
				{ "&Retorna" },,;
				"Item Cont�bil: " + cITIni )
				lRetorno	:= .F.
			ElseIf lRetorno .And. "PAF_ITFIM" $ cCampo .And. !Empty( cITIni ) .And. cITFim < cITIni
				Aviso(	cCadastro,;
				"Item Cont�bil final n�o pode ser menor que o inicial.",;
				{ "&Retorna" },,;
				"Item Cont�bil: " + cITFim )
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaCTD )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02IUs
	Inicializa o nome do usu�rio 
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02IUs()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.
	Local nPNomUsr	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_NOMUSR" } )

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//�����������������������������������������������������������������������������������������Ŀ
	//� Atualizao nome do usu�rio aprovador                                                     �
	//�������������������������������������������������������������������������������������������
	aCols[n,nPNomUsr]	:= UsrRetName( &( ReadVar() ) )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02VVl
	Valida o Valor Digitado 
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02VVl()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Valida se o valor inicial � maior que o final                                           �
	//�������������������������������������������������������������������������������������������
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
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02LOk
	Valida��o na linha da getdados  
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02LOk()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu     	:= GetArea()
	Local aAreaSX3		:= SX3->( GetArea() )
	Local lRetorno  	:= .T.
	Local nPIdUser		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAG_IDUSER" } )
	Local nLoop1		:= 0
	Local cIdUser		:= ""

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//�����������������������������������������������������������������������������������������Ŀ
	//� Se a linha n�o estiver deletada efetua as valida��es                                    �
	//�������������������������������������������������������������������������������������������
	If !oGDados:aCols[oGDados:nAt, Len( aHeader ) + 1]
		//�������������������������������������������������������������������������������������Ŀ
		//� Verifica se as vari�veis digitadas s�o v�lidas                                      �
		//���������������������������������������������������������������������������������������
		cIdUser		:= oGDados:aCols[oGDados:nAt, nPIdUser]
		lRetorno	:= UsrExist( cIdUser )
		//�������������������������������������������������������������������������������������Ŀ
		//� Verifica se tem algum campo obrigat�rio e n�o preenchido                            �
		//���������������������������������������������������������������������������������������
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
		//�������������������������������������������������������������������������������������Ŀ
		//� Verifica se tem duplicidade de informa��o                                           �
		//���������������������������������������������������������������������������������������
		If lRetorno
			//���������������������������������������������������������������������������������Ŀ
			//� Varre todos os itens do aCols                                                   �
			//�����������������������������������������������������������������������������������
			For nLoop1 := 1 To Len( oGDados:aCols )
				//�����������������������������������������������������������������������������Ŀ
				//� Se n�o estiver deletado e n�o for a linha digitada                          �
				//�������������������������������������������������������������������������������
				If	oGDados:aCols[nLoop1, Len( aHeader ) + 1] == .F. .And.;
					nLoop1 <> oGDados:nAt
					//�������������������������������������������������������������������������Ŀ
					//� Verifica se encontra o id em outra linha                                �
					//���������������������������������������������������������������������������
					If	oGDados:aCols[nLoop1,nPIdUser] == cIdUser
						Help( " ", 1, "JAGRAVADO", , , 4 )
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			Next nLoop1
		EndIf
	EndIf
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaSX3 )
	RestArea( aAreaAtu )

Return( lRetorno )
/*/{Protheus.doc} User Function Ado02TOk
	Valida��o na confirma��o da getdados  
	Retorno:
			ExpL1 - .T. Valida��es corretas .F. Valida��es com diverg�ncia
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
User Function Ado02TOk()
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
	Local nLoop1		:= 0
	Local lRetorno		:= .F.
	Local nLnhOri		:= 0

	U_ADINF009P('ADOA020' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//�����������������������������������������������������������������������������������������Ŀ
	//� Faz a valida��o de linha para todos os itens                                            �
	//�������������������������������������������������������������������������������������������
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
			ExpL1 - .T. grava��o com sucesso .F. erro na grava��o 
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
Static Function GrvDados( lRetorno, nOpcX )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Declara as vari�veis da rotina                                                          �
	//�������������������������������������������������������������������������������������������
	Local nLoop1		:= 0
	Local nLoop2		:= 0
	Local nPNivel		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAG_NIVEL" } )
	Local nPIdUser		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAG_IDUSER" } )
	Local bCampo		:= { |nCpo| Field( nCpo ) }


	//�����������������������������������������������������������������������������������������Ŀ
	//� Validacao do codigo do grupo                                                    �
	//�������������������������������������������������������������������������������������������

	//Ana - Incluido para atender chamado 9801 - 04/05/2011
	If !ExistChav("PAF",M->PAF_CODGRP)
		Aviso(	"Grupo de Aprovadores - Aviso",;
		"Codigo do Grupo ja Cadastrado." + Chr(13) + Chr(10) +;
		"N�o � possivel inclusao de mesmo codigo. O registro n�o foi gravado!",;
		{ "&Retorna" },2,;
		"Codigo: " + M->PAF_CODGRP )
		Return( .F. )
	Endif

	//�����������������������������������������������������������������������������������������Ŀ
	//� Verifica se a op��o escolhida necessita grava��o                                        �
	//�������������������������������������������������������������������������������������������
	If nOpcx > 2
		//�������������������������������������������������������������������������������������Ŀ
		//� Inicializa a ampulheta de processamento e o controle de transa��o                   �
		//���������������������������������������������������������������������������������������
		CursorWait()
		Begin Transaction
		//���������������������������������������������������������������������������������Ŀ
		//� Limpa o filtro se n�o for top                                                   �
		//�����������������������������������������������������������������������������������
		#IFNDEF TOP
			dbSelectArea( "PAF" )
			RetIndex( "PAF" )
			dbClearFilter()
			aEval( aIndexPAF,{ |x| Ferase( x[1] + OrdBagExt() ) } )
		#ENDIF
		//���������������������������������������������������������������������������������Ŀ
		//� Posiciona no registro referente ao cabe�alho                                    �
		//�����������������������������������������������������������������������������������
		dbSelectArea( "PAF" )
		dbSetOrder( 1 )
		If MsSeek( xFilial( "PAF" ) + M->PAF_CODGRP )
			RecLock( "PAF", .F. )
		Else
			RecLock( "PAF", .T. )
		EndIf
		//���������������������������������������������������������������������������������Ŀ
		//� Grava os dados do cabe�alho                        		                        �
		//�����������������������������������������������������������������������������������
		For nLoop2 := 1 To PAF->( fCount() )
			FieldPut( nLoop2, M->&( Eval( bCampo, nLoop2 ) ) )
		Next nLoop2
		PAF->PAF_FILIAL	:= xFilial( "PAF" )
		MsUnLock()
		//�������������������������������������������������������������������������������������Ŀ
		//� Op��o para Desbloqueio                                                              �
		//���������������������������������������������������������������������������������������
		If nOpcX == 7
			RecLock( "PAF", .F. )
			PAF->PAF_MSBLQL	:= "2"
			MsUnLock()

		//�������������������������������������������������������������������������������������Ŀ
		//� Op��o para Bloqueio                                                                 �
		//���������������������������������������������������������������������������������������
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

			//�������������������������������������������������������������������������������������Ŀ
			//� Op��o para Exclus�o                                                                 �
			//���������������������������������������������������������������������������������������
		ElseIf nOpcX == 5
			//���������������������������������������������������������������������������������Ŀ
			//� Varre todo o acols                                                              �
			//�����������������������������������������������������������������������������������
			For nLoop1 := 1 To Len( oGDados:aCols )
				//�����������������������������������������������������������������������������Ŀ
				//� Grava o registro como bloqueado                                             �
				//�������������������������������������������������������������������������������
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
			//�������������������������������������������������������������������������������������Ŀ
			//� Op��o para Altera��o                                                                �
			//���������������������������������������������������������������������������������������
		ElseIf nOpcX == 4
			//���������������������������������������������������������������������������������Ŀ
			//� Varre todo o acols                                                              �
			//�����������������������������������������������������������������������������������
			For nLoop1 := 1 To Len( oGDados:aCols )
				//�����������������������������������������������������������������������������Ŀ
				//� Se o item estiver deletado e encontrar o registro na base, deleta        	�
				//�������������������������������������������������������������������������������
				If	oGDados:aCols[nLoop1, Len(aHeader) + 1] .And.;
					PAG->( MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] ) )
					RecLock( "PAG", .F. )
					dbDelete()
					MsUnLock()
					//�����������������������������������������������������������������������������Ŀ
					//� Se o item n�o estiver deletado atualiza dados                               �
					//�������������������������������������������������������������������������������
				ElseIf !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
					dbSelectArea( "PAG" )
					If MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] )
						RecLock( "PAG", .F. )
					Else
						RecLock( "PAG", .T. )
					EndIf
					//�������������������������������������������������������������������������Ŀ
					//� Atualiza os campos do acols                                             �
					//���������������������������������������������������������������������������
					For nLoop2 := 1 To Len( aHeader )
						If aHeader[nLoop2, 10] <> "V"
							PAG->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
						EndIf
					Next nLoop2
					//�������������������������������������������������������������������������Ŀ
					//� Atualiza os campos fixos                                                �
					//���������������������������������������������������������������������������
					PAG->PAG_FILIAL	:= xFilial( "PAG" )
					PAG->PAG_CODGRP	:= M->PAF_CODGRP
					dbSelectArea( "PAG" )
					MsUnlock()
				EndIf
			Next nLoop1
			//�������������������������������������������������������������������������������������Ŀ
			//� Op��o para Inclus�o                                                                 �
			//���������������������������������������������������������������������������������������
		ElseIf nOpcX == 3
			//���������������������������������������������������������������������������������Ŀ
			//� Varre todo o acols                                                              �
			//�����������������������������������������������������������������������������������
			For nLoop1 := 1 To Len( oGDados:aCols )
				//�����������������������������������������������������������������������������Ŀ
				//� Se o item n�o estiver deletado atualiza dados                               �
				//�������������������������������������������������������������������������������
				If !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
					dbSelectArea( "PAG" )
					dbSetOrder( 1 )
					If MsSeek( xFilial( "PAG" ) + M->PAF_CODGRP + oGDados:aCols[nLoop1,nPNivel] + oGDados:aCols[nLoop1,nPIdUser] )
						Aviso(	cCadastro,;
						"Foi encontrado registro com a chave pesquisada." + Chr(13) + Chr(10) +;
						"O registro n�o ser� gravado. Contate o Administrador do Sistema.",;
						{ "Retorna" },2,;
						"Inclus�o em Duplicidade" )
						lRetorno	:= .F.
						Exit
					Else
						RecLock( "PAG" , .T. )
						//�������������������������������������������������������������������������Ŀ
						//� Atualiza os campos do acols                                             �
						//���������������������������������������������������������������������������
						For nLoop2 := 1 To Len( aHeader )
							If aHeader[nLoop2, 10] <> "V"
								PAG->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
							EndIf
						Next nLoop2
						//�������������������������������������������������������������������������Ŀ
						//� Atualiza os campos fixos                                                �
						//���������������������������������������������������������������������������
						PAG->PAG_FILIAL	:= xFilial( "PAG" )
						PAG->PAG_CODGRP	:= M->PAF_CODGRP
						dbSelectArea( "PAG" )
						MsUnlock()
					EndIf
				EndIf
			Next nLoop1
		EndIf
		//���������������������������������������������������������������������������������Ŀ
		//� Atualiza flag de processamento de grava��o concluido	                        �
		//�����������������������������������������������������������������������������������
		lRetorno	:= .T.
		//�������������������������������������������������������������������������������������Ŀ
		//� Finaliza a transacao                               		                            �
		//���������������������������������������������������������������������������������������
		End Transaction
		CursorArrow()
	EndIf
	//�����������������������������������������������������������������������������������������Ŀ
	//� Realiza o filtro se necess�rio quando n�o for top                                       �
	//�������������������������������������������������������������������������������������������
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
	Defini��o das rotinas para o programa.
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
	Cria o grupo de perguntas se n�o existir.
	Par�metros:
		ExpC1 = Alias do grupo de perguntas
	@type  Function
	@author Almir Bandina
	@since 01/05/2008
	@version 01
	/*/
Static Function CriaSX1( cPerg )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis da rotina                                                           �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->( GetArea() )
	Local aTamSX3	:= {}
	Local aHelp		:= {}
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define os t�tulos e Help das perguntas                                                  �
	//�������������������������������������������������������������������������������������������
	//													"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	aAdd(aHelp,{	"Filtra os Bloqueados",	"",	"", {	"Informe Sim caso tenha necessidade de   ",	"filtrar os registros bloqueados ou N�o  ",	"para exibir todos os registros          " },	{""},	{""} } )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Grava as perguntas no arquivo SX1                                                       �
	//�������������������������������������������������������������������������������������������
	//		cGrupo	cOrde	cDesPor			cDesSpa			cDesEng			cVar		cTipo		cTamanho	cDecimal	nPreSel	cGSC	cValid	cF3			cGrpSXG	cPyme	cVar01		cDef1Por		cDef1Spa	cDef1Eng	cCnt01	  					cDef2Por	cDef2Spa	cDef2Eng	cDef3Por	cDef3Spa	cDef3Eng	cDef4Por		cDef4Spa	cDef4Eng	cDef5Por	cDef5Spa	cDef5Eng	aHelpPor		aHelpEng		aHelpSpa		cHelp)
	PutSx1(	cPerg,	"01",	aHelp[01,1],	aHelp[01,2],	aHelp[01,3],	"mv_ch1",	"N",		1,			0,			2,		"C",	"",		"",			"",		"N",	"mv_par01",	"Sim",			"Si",		"Yes",		"",							"N�o",		"No",		"No",		"",			"",			"",			"",				"",			"",			"",			"",			"",			aHelp[01,4],	aHelp[01,5],	aHelp[01,6],	"" )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Salva as �reas originais                                                                �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaSX1 )
	RestArea( aAreaAtu )

Return( Nil )