#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2
/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �ADOA030 �Manuten��o na tabela de aprovador substituto                     ���
���            �        �                                                                 ���
�����������������������������������������������������������������������������������������͹��
���Projeto/PL  �PL_01 - Amarra��o Usu�rio x Centros de Custo                              ���
�����������������������������������������������������������������������������������������͹��
���Solicitante �19.03.08�Jos� Eduardo/Everaldo                                            ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �Nil.                                                                      ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function ADOA030()
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis utilizadas na rotina                                                �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()

Private cString		:= "PAH"
Private cCadastro 	:= OemtoAnsi( Alltrim( Posicione( "SX2", 1, cString, "X2_NOME" ) ) )
Private aRotina		:= MenuDef()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If !Alltrim(__CUSERID) $ SuperGetMV("MV_#USUAPR",.f.,"000000")     //Incluido por Adriana para liberar acesso apenas aos usu�rios autorizados 12/12/2014
	Alert("Usuario nao Autorizado - MV_#USUAPR")
else
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Posiciona no arquivo de usu�rios x centro de custo                                      �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAH" )
	dbSetOrder( 2 )
	dbGoTop()
	
	mBrowse(6,1,22,75,"PAH",,,,,,)
	
Endif

RestArea( aAreaAtu )

Return( Nil )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �ADO03Cad�Manuten��o na tabela de aprovador substituto                     ���
���            �        �                                                                 ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �ExpC1 - Alias do Arquivo                                                  ���
���            �ExpN1 - N�mero do Registro no arquivo                                     ���
���            �ExpN2 - Op��o selecionada no aRotina                                      ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Executou a rotina sem diverg�ncia                             ���
���            �        .F. N�o conseguiu executar a rotina                               ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function Ado03Cad( cAlias, nReg, nOpcx )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local oCodGrp, oNomGrp
Local lRetorno		:= .T.
Local aPosObj    	:= {}
Local aObjects   	:= {}
Local aSize      	:= MsAdvSize()
Local nOpcA			:= 0
Local nLoop1		:= 0

Private oDlgMain
Private oFldDados
Private oGDados
Private Inclui		:= .F.
Private Altera		:= .F.
Private lAdo03Vis	:= .F.
Private lAdo03Inc	:= .F.
Private lAdo03Alt	:= .F.
Private lAdo03Exc	:= .F.
Private aCols	 	:= {}
Private aCposGet	:= {}
Private aFields		:= {}
Private aHeader 	:= {}
Private aGets		:= {}
Private aTELA   	:= {}
Private cCodGrp		:= CriaVar( "PAH_CODGRP", .F. )
Private cNomGrp		:= CriaVar( "PAH_NOMGRP", .F. )

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//�����������������������������������������������������������������������������������������Ŀ
//� Posiciona no registro, caso ainda n�o esteja posicionado                                �
//�������������������������������������������������������������������������������������������
dbSelectArea( cAlias )
dbSetOrder( 1 )
dbGoTo( nReg )
//�����������������������������������������������������������������������������������������Ŀ
//� Define a operacao que esta sendo executada                                              �
//�������������������������������������������������������������������������������������������
If nOpcx == 3
	lAdo03Inc	:= .T.
	Inclui		:= .T.
	cCodGrp		:= CriaVar( "PAH_CODGRP", .F. )
	cNomGrp		:= CriaVar( "PAH_NOMGRP", .F. )
ElseIf nOpcx == 4
	lAdo03Alt	:= .T.
	Altera		:= .T.
	cCodGrp		:= PAH->PAH_CODGRP
	cNomGrp		:= GetAdvFVal( "PAF", "PAF_DESCRI", xFilial( "PAF" ) + PAH->PAH_CODGRP, 1, "" )
Elseif nOpcx == 5
	lAdo03Exc	:= .T.
	cCodGrp		:= PAH->PAH_CODGRP
	cNomGrp		:= GetAdvFVal( "PAF", "PAF_DESCRI", xFilial( "PAF" ) + PAH->PAH_CODGRP, 1, "" )
Else
	lAdo03Vis	:= .T.
	cCodGrp		:= PAH->PAH_CODGRP
	cNomGrp		:= GetAdvFVal( "PAF", "PAF_DESCRI", xFilial( "PAF" ) + PAH->PAH_CODGRP, 1, "" )
Endif
//�����������������������������������������������������������������������������������������Ŀ
//� Monta o header do arquivo                                                               �
//�������������������������������������������������������������������������������������������
dbSelectArea( "SX3" )
dbSetOrder( 1 )
MsSeek( "PAH" )
While	SX3->( !Eof() ) .And. SX3->X3_ARQUIVO $ "PAH"
	If X3USO(X3_USADO) .And.;
		cNivel >= X3_NIVEL .And.;
		( !Alltrim( SX3->X3_CAMPO ) $ "PAH_FILIAL/PAH_CODGRP/PAH_NOMGRP/PAH_USERGI/PAH_USERGA")
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
	dbSelectArea( "PAH" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAH" ) + cCodGrp, .F.)
	While PAH->( !Eof() ) .And. PAH->PAH_FILIAL == xFilial( "PAH" ) .And. PAH->PAH_CODGRP == cCodGrp
		aAdd( aCols, Array( Len( aHeader ) + 1 ) )
		For nLoop1 := 1 To Len( aHeader )
			If AllTrim( aHeader[nLoop1,2] ) == "PAH_NOMAPR"
				aCols[Len(aCols),nLoop1]	:= UsrRetName( PAH->PAH_APROFI )
			ElseIf AllTrim( aHeader[nLoop1,2] ) == "PAH_NOMSUB"
				aCols[Len(aCols),nLoop1]	:= UsrRetName( PAH->PAH_APRSUB )
			ElseIf AllTrim( aHeader[nLoop1,10] ) <> "V"
				aCols[Len(aCols),nLoop1]	:= PAH->&( aHeader[nLoop1,2] )
			Else
				aCols[Len(aCols),nLoop1]	:= Criavar( aHeader[nLoop1,2] )
			EndIf
		Next nLoop1
		aCols[Len(aCols), Len( aHeader ) + 1] := .F.
		PAH->( dbSkip() )
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
			If AllTrim( aHeader[nLoop1,2] ) == "PAH_NUMSEQ"
				aCols[Len(aCols),nLoop1]	:= StrZero( 0, TAMSX3( "PAH_NUMSEQ" )[1] )
			Else
				aCols[Len(aCols),nLoop1]	:= CriaVar( aHeader[nLoop1,02] )
			EndIf
		Next nLoop1
		aCols[Len(aCols), Len( aHeader ) + 1] := .F.
	EndIf
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Define a area dos objetos                                                               �
//�������������������������������������������������������������������������������������������
aObjects := {}
AAdd( aObjects, { 100, 030, .t., .f. } )
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
@ aPosObj[1,1],aPosObj[1,2] 		SAY "C�d.Grupo:" OF oDlgMain PIXEL SIZE 50,09 SHADED
@ aPosObj[1,1]+8,aPosObj[1,2] 		MSGET oCodGrp VAR cCodGrp F3 "PAF" PICTURE "999999" ;
VALID VldGrp( oCodGrp, cCodGrp, @oNomGrp, @cNomGrp, nOpcX ) WHEN lAdo03Inc ;
OF oDlgMain PIXEL SIZE 50,09

@ aPosObj[1,1],aPosObj[1,2]+55		SAY "Descri��o:" OF oDlgMain PIXEL SIZE 050,09 SHADED
@ aPosObj[1,1]+8,aPosObj[1,2]+55	MSGET oNomGrp VAR cNomGrp WHEN .F. CENTERED;
OF oDlgMain PIXEL SIZE 150,09
//�������������������������������������������������������������������������������������Ŀ
//� Monta o folder dos itens                                                            �
//���������������������������������������������������������������������������������������
oFldDados 	:= TFolder():New(aPosObj[2,1]-10,aPosObj[2,2],{ "&Aus�ncia de Aprovadores" },,oDlgMain,,,,.T.,.T.,(aPosObj[2,4]-aPosObj[2,2]),((aPosObj[2,3]-aPosObj[2,1])+10))
//�������������������������������������������������������������������������������������Ŀ
//� Monta a getdados da folder                                                          �
//���������������������������������������������������������������������������������������
//MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)
oGDados := MsNewGetDados():New(000,000,oFldDados:aDialogs[1]:nClientHeight/2,oFldDados:aDialogs[1]:nClientWidth/2,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),,,"+PAH_NUMSEQ",,,9999,,,,oFldDados:aDialogs[1],@aHeader,@aCols)
oGDados:bLinhaOk	:= { || U_Ado03LOk() }
oGDados:bTudoOk 	:= { || U_Ado03TOk() }
oGDados:bDelOk		:= { || U_A030Pend(1) }
oDlgMain:Activate(,,,,,,{ || EnchoiceBar(	oDlgMain,;
{||Iif(nOpcx == 2, (nOpcA := 0,oDlgMain:End()), nOpcA := If( Obrigatorio(aGets,aTela) .And. If( nOpcx == 5, U_A030Pend(2), .T. ), 1, 0 ) ), If(nOpcA==1,oDlgMain:End(),Nil)},;
{||oDlgMain:End()},;
,)})
//�����������������������������������������������������������������������������������������Ŀ
//� Efetua a gravacao das informacoes                                                       �
//�������������������������������������������������������������������������������������������
If nOpca == 1
	GrvDados( @lRetorno, cCodGrp, nOpcX )
Endif

Return( lRetorno )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �VldGrp  �Valida e Inicializa o grupo de usu�rio                           ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Static Function VldGrp( oCodGrp, cCodGrp, oNomGrp, cNomGrp, nOpcX )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()
Local aAreaPAF	:= PAF->( GetArea() )
Local aAreaPAH	:= PAH->( GetArea() )
Local lRetorno	:= .T.

If Empty( cCodGrp )
	Aviso(	cCadastro,;
	"Grupo n�o poder� ficar vazio." + Chr(13) + Chr(10) +;
	"Informar um grupo v�lido.",;
	{ "&Retorna" },,;
	"Grupo em branco" )
	lRetorno	:= .F.
Else
	dbSelectArea( "PAH" )
	dbSetOrder( 1 )
	If MsSeek( xFilial( "PAH" ) + cCodGrp ) .And. nOpcX == 3
		Aviso(	cCadastro,;
		"Grupo j� cadastrado.",;
		{ "&Retorna" },,;
		"Grupo: " + cCodGrp )
		lRetorno	:= .F.
	EndIf
	dbSelectArea( "PAF" )
	dbSetOrder( 1 )
	If lRetorno .And. !( MsSeek( xFilial( "PAF" ) + cCodGrp ) )
		Aviso(	cCadastro,;
		"Grupo n�o localizado no cadastro.",;
		{ "&Retorna" },,;
		"Grupo: " + cCodGrp )
		lRetorno	:= .F.
	Else
		cNomGrp	:= PAF->PAF_DESCRI
		oNomGrp:Refresh()
	EndIf
EndIf

RestArea( aAreaPAF )
RestArea( aAreaPAH )
RestArea( aAreaAtu )

Return( lRetorno )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �A030Ofi �Valida o aprovador oficial � o mesmo que efetuou o logim ou se � ���
���            �        �o Administrador do sistema                                       ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function A030Ofi()
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local lRetorno	:= .T.
Local aAreaAtu	:= GetArea()
Local cAprOfi	:= &( ReadVar() )

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//�����������������������������������������������������������������������������������������Ŀ
//� Compatibiliza o conte�do dos campos com o valor digitado                                �
//�������������������������������������������������������������������������������������������
// Almir Bandina - 29.07.08 - Everaldo solicitou que qualquer usu�rio possa efetuar manuten��o no cadastro
/*
If !( Empty( cAprOfi ) ) .And. ( __cUserId <> cAprOfi .And. __cUserId <> "000000" )
Aviso(	cCadastro,;
"Aprovador n�o poder� efetuar a manuten��o de usu�rios diferentes." + Chr(13) + Chr(10) +;
"Selecione um item com o mesmo identificador do seu usu�rio.",;
{ "&Retorna" },2,;
"Id Usu�rio: " + __cUserId )
lRetorno	:= .F.
EndIf
*/

RestArea( aAreaAtu )

Return( lRetorno )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �A030Sub �Valida o aprovador substituto com base nos valores               ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function A030Sub()
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()
Local aAreaPAG	:= PAG->( GetArea() )
Local lRetorno	:= .T.
Local nVlrOfi	:= 0
Local nVlrSub	:= 0
Local cCampo	:= ReadVar()
Local cAprOfi	:= aCols[n,aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_APROFI" } )]
Local cAprSub	:= aCols[n,aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } )]

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
//�����������������������������������������������������������������������������������������Ŀ
//� Compatibiliza o conte�do dos campos com o valor digitado                                �
//�������������������������������������������������������������������������������������������
// 29.07.08 - Almir Bandina - Everaldo solicitou que os usu�rio devem estar vinvulados ao grupo de aprova��o
If "PAH_APRSUB" $ cCampo
	cAprSub	:= &( ReadVar() )
	/*
	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa se j� existe o usu�rio no cadastro                                             �
	//�������������������������������������������������������������������������������������������
	lRetorno	:= UsrExist( cAprSub )
	*/
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obtem as configura��es dos aprovadores                                                  �
	//�������������������������������������������������������������������������������������������
	lRetorno	:= .F.
	dbSelectArea( "PAG" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAG" ) + cCodGrp )
	While !Eof() .And. PAG->PAG_FILIAL == xFilial( "PAG" ) .And. PAG->PAG_CODGRP == cCodGrp
		//�������������������������������������������������������������������������������������Ŀ
		//� Se estiver bloqueado, desconsidera                                                  �
		//���������������������������������������������������������������������������������������
		//ANA 31/03/11 - ALTERADO CHAMADO 8608
		//If PAG->PAG_MSBLQL == "1"
		//	dbSkip()
		//	Loop
		//EndIf
		//�������������������������������������������������������������������������������������Ŀ
		//� Pega os dados do aprovador substituto                                               �
		//���������������������������������������������������������������������������������������
		If PAG->PAG_IDUSER == cAprSub
			lRetorno	:= .T.
		EndIf
		//�������������������������������������������������������������������������������������Ŀ
		//� Pr�ximo registro                                                                    �
		//���������������������������������������������������������������������������������������
		dbSelectArea( "PAG" )
		dbSkip()
	EndDo
	If !lRetorno
		Aviso(	cCadastro,;
		"Aprovador substituto n�o consta do grupo de aprova��o.." + Chr(13) + Chr(10) +;
		"Selecione um aprovador substituto v�lido para o grupo.",;
		{ "&Retorna" },2,;
		"Aprovador Substituto: " + cAprSub )
	EndIf
EndIf
If "PAH_APROFI" $ cCampo
	cAprOfi	:= &( ReadVar() )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obtem as configura��es dos aprovadores                                                  �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAG" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAG" ) + cCodGrp )
	While !Eof() .And. PAG->PAG_FILIAL == xFilial( "PAG" ) .And. PAG->PAG_CODGRP == cCodGrp
		//�������������������������������������������������������������������������������������Ŀ
		//� Se estiver bloqueado, desconsidera                                                  �
		//���������������������������������������������������������������������������������������
		If PAG->PAG_MSBLQL == "1"
			dbSkip()
			Loop
		EndIf
		//�������������������������������������������������������������������������������������Ŀ
		//� Pega os dados do aprovador oficial                                                  �
		//���������������������������������������������������������������������������������������
		If PAG->PAG_IDUSER == cAprOfi
			nVlrOfi	:= PAG->PAG_VLRINI
		EndIf
		//�������������������������������������������������������������������������������������Ŀ
		//� Pega os dados do aprovador substituto                                               �
		//���������������������������������������������������������������������������������������
		If PAG->PAG_IDUSER == cAprSub
			nVlrSub	:= PAG->PAG_VLRINI
		EndIf
		//�������������������������������������������������������������������������������������Ŀ
		//� Pr�ximo registro                                                                    �
		//���������������������������������������������������������������������������������������
		dbSelectArea( "PAG" )
		dbSkip()
	EndDo
	//�����������������������������������������������������������������������������������������Ŀ
	//� Se valor do substituto incompat�vil, n�o deixa associar                                 �
	//�������������������������������������������������������������������������������������������
	//If nVlrSub < nVlrOfi
	//	Aviso(	cCadastro,;
	//			"Valor inicial do aprovador substituto � inferior ao valor do aprovador oficial." + Chr(13) + Chr(10) +;
	//			"Substitui��o n�o permitida. Escolha um substituto com o mesmo perfil do oficial.",;
	//			{ "&Retorna" },2,;
	//			"Valores Incompat�veis" )
	//	lRetorno	:= .F.
	//EndIf
EndIf


RestArea( aAreaPAG )
RestArea( aAreaAtu )

Return( lRetorno )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �ADO03LOk�Valida��o na linha da getdados                                   ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 17.07.08 - Almir Bandina - Incluir valida��o para pedidos pendentes para ���
���            �            o aprovador substituto.                                       ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function Ado03LOk()
//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Local aAreaAtu     	:= GetArea()
Local aAreaSX3		:= SX3->( GetArea() )
Local lRetorno  	:= .T.
Local nPAprOfi		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_APROFI" } )
Local nPAprSub		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } )
Local nPDatIni		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_DATINI" } )
Local nPDatFim		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_DATFIM" } )
Local nLoop1		:= 0
Local cAprOfi		:= ""
Local cAprSub		:= ""
Local dDatIni		:= CToD( "  /  /  " )
Local dDatFim		:= CToD( "  /  /  " )

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
//�����������������������������������������������������������������������������������������Ŀ
//� Se a linha n�o estiver deletada efetua as valida��es                                    �
//�������������������������������������������������������������������������������������������
If !oGDados:aCols[oGDados:nAt, Len( aHeader ) + 1]
	//�������������������������������������������������������������������������������������Ŀ
	//� Verifica se as vari�veis digitadas s�o v�lidas                                      �
	//���������������������������������������������������������������������������������������
	dDatIni		:= oGDados:aCols[oGDados:nAt,nPDatIni]
	dDatFim		:= oGDados:aCols[oGDados:nAt,nPDatFim]
	cAprOfi		:= oGDados:aCols[oGDados:nAt,nPAprOfi]
	lRetorno	:= UsrExist( cAprOfi )
	cAprSub		:= oGDados:aCols[oGDados:nAt,nPAprSub]
	lRetorno	:= UsrExist( cAprSub )
	If lRetorno .And. cAprOfi == cAprSub
		Aviso(	cCadastro,;
		"Aprovador substituto � o mesmo que o aprovador oficial." + Chr(13) + Chr(10) +;
		"Inclus�o n�o permitida.",;
		{ "&Retorna" },2,;
		"Aprovador Substituto: " + cAprSub )
		lRetorno	:= .F.
	EndIf
	If lRetorno .And. Empty( dDatIni )
		Aviso(	cCadastro,;
		"Data de aus�ncia inicial n�o pode ficar vazia." + Chr(13) + Chr(10) +;
		"Inclus�o n�o permitida.",;
		{ "&Retorna" },2,;
		"Data em branco" )
		lRetorno	:= .F.
	EndIf
	If lRetorno .And. Empty( dDatFim )
		Aviso(	cCadastro,;
		"Data de aus�ncia final n�o pode ficar vazia." + Chr(13) + Chr(10) +;
		"Inclus�o n�o permitida.",;
		{ "&Retorna" },2,;
		"Data em branco" )
		lRetorno	:= .F.
	EndIf
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
				//� Verifica se encontra o id em outra linha para o mesmo intervalo de data �
				//���������������������������������������������������������������������������
				If	oGDados:aCols[nLoop1,nPAprOfi] == cAprOfi .And.;
					oGDados:aCols[nLoop1,nPAprSub] == cAprSub .And.;
					( ( dDatIni >= oGDados:aCols[nLoop1,nPDatIni] .And. dDatIni <= oGDados:aCols[nLoop1,nPDatFim] ) .Or.;
					( dDatFim >= oGDados:aCols[nLoop1,nPDatIni] .And. dDatFim <= oGDados:aCols[nLoop1,nPDatFim] ) )
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


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �ADO03TOk�Valida��o na confirma��o da getdados                             ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function Ado03TOk()
//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Local nLoop1		:= 0
Local lRetorno		:= .F.
Local nLnhOri		:= 0

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
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


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �GrvDados�Grava os dados da rotina                                         ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. grava��o com sucesso                                          ���
���            �        .F. erro na grava��o                                              ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Static Function GrvDados( lRetorno, cCodGrp, nOpcX )
//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Local nLoop1		:= 0
Local nLoop2		:= 0
Local nPAprOfi		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAH_APROFI" } )
Local nPAprSub		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAH_APRSUB" } )
Local nPDatIni		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAH_DATINI" } )
Local nPNumSeq		:= aScan( aHeader,  { |x| AllTrim( x[2] ) == "PAH_NUMSEQ" } )
//�����������������������������������������������������������������������������������������Ŀ
//� Verifica se a op��o escolhida necessita grava��o                                        �
//�������������������������������������������������������������������������������������������
If nOpcx > 2
	//�������������������������������������������������������������������������������������Ŀ
	//� Inicializa a ampulheta de processamento e o controle de transa��o                   �
	//���������������������������������������������������������������������������������������
	CursorWait()
	Begin Transaction
	//�������������������������������������������������������������������������������������Ŀ
	//� Op��o para Exclus�o                                                                 �
	//���������������������������������������������������������������������������������������
	If nOpcX == 5
		//���������������������������������������������������������������������������������Ŀ
		//� Varre todo o acols                                                              �
		//�����������������������������������������������������������������������������������
		For nLoop1 := 1 To Len( oGDados:aCols )
			//�����������������������������������������������������������������������������Ŀ
			//� Grava o registro como bloqueado                                             �
			//�������������������������������������������������������������������������������
			dbSelectArea( "PAH" )
			//dbSetOrder( 1 )		// FILIAL + CODGRP + APROFI + APRSUB + DATINI
			//If PAH->( MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPAprOfi] + oGDados:aCols[nLoop1,nPAprSub] + DToS( oGDados:aCols[nLoop1,nPDatIni] ) ) )
			dbSetOrder( 2 )		// FILIAL + CODGRP + NUMSEQ
			If PAH->( MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPNumSeq] ) )
				RecLock( "PAH", .F. )
				dbDelete()
				MsUnLock()
			Endif
		Next nLoop1
		//�������������������������������������������������������������������������������������Ŀ
		//� Op��o para Altera��o                                                                �
		//���������������������������������������������������������������������������������������
	ElseIf nOpcX == 4
		//���������������������������������������������������������������������������������Ŀ
		//� Varre todo o acols                                                              �
		//�����������������������������������������������������������������������������������
		dbSelectArea( "PAH" )
		dbSetOrder( 2 )
		For nLoop1 := 1 To Len( oGDados:aCols )
			//�����������������������������������������������������������������������������Ŀ
			//� Se o item estiver deletado e encontrar o registro na base, deleta        	�
			//�������������������������������������������������������������������������������
			If	oGDados:aCols[nLoop1, Len(aHeader) + 1] .And.;
				PAH->( MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPNumSeq] ) )
				//PAH->( MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPAprOfi] + oGDados:aCols[nLoop1,nPAprSub] + DToS( oGDados:aCols[nLoop1,nPDatIni] ) ) )
				RecLock( "PAH", .F. )
				dbDelete()
				MsUnLock()
				//�����������������������������������������������������������������������������Ŀ
				//� Se o item n�o estiver deletado atualiza dados                               �
				//�������������������������������������������������������������������������������
			ElseIf !( oGDados:aCols[nLoop1, Len(aHeader) + 1] )
				dbSelectArea( "PAH" )
				dbSetOrder( 2 )
				If MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPNumSeq] )
					//If MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPAprOfi] + oGDados:aCols[nLoop1,nPAprSub] + DToS( oGDados:aCols[nLoop1,nPDatIni] ) )
					RecLock( "PAH", .F. )
				Else
					RecLock( "PAH", .T. )
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Atualiza os campos do acols                                             �
				//���������������������������������������������������������������������������
				For nLoop2 := 1 To Len( aHeader )
					If aHeader[nLoop2, 10] <> "V"
						PAH->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
					EndIf
				Next nLoop2
				//�������������������������������������������������������������������������Ŀ
				//� Atualiza os campos fixos                                                �
				//���������������������������������������������������������������������������
				PAH->PAH_FILIAL	:= xFilial( "PAH" )
				PAH->PAH_CODGRP	:= cCodGrp
				dbSelectArea( "PAH" )
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
				dbSelectArea( "PAH" )
				dbSetOrder( 2 )
				//If MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPAprOfi] + oGDados:aCols[nLoop1,nPAprSub] + DToS( oGDados:aCols[nLoop1,nPDatIni] ) )
				If MsSeek( xFilial( "PAH" ) + cCodGrp + oGDados:aCols[nLoop1,nPNumSeq] )
					Aviso(	cCadastro,;
					"Foi encontrado registro com a chave pesquisada." + Chr(13) + Chr(10) +;
					"O registro n�o ser� gravado. Contate o Administrador do Sistema.",;
					{ "Retorna" },2,;
					"Inclus�o em Duplicidade" )
					lRetorno	:= .F.
					Exit
				Else
					RecLock( "PAH", .T. )
					//�������������������������������������������������������������������������Ŀ
					//� Atualiza os campos do acols                                             �
					//���������������������������������������������������������������������������
					For nLoop2 := 1 To Len( aHeader )
						If aHeader[nLoop2, 10] <> "V"
							PAH->&( AllTrim( aHeader[nLoop2,02] ) ) := oGDados:aCols[nLoop1,nLoop2]
						EndIf
					Next nLoop2
					//�������������������������������������������������������������������������Ŀ
					//� Atualiza os campos fixos                                                �
					//���������������������������������������������������������������������������
					PAH->PAH_FILIAL	:= xFilial( "PAH" )
					PAH->PAH_CODGRP	:= cCodGrp
					dbSelectArea( "PAH" )
					MsUnlock()
				EndIf
			EndIf
		Next nLoop1
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Finaliza a transacao                               		                            �
	//���������������������������������������������������������������������������������������
	End Transaction
	CursorArrow()
EndIf

Return( lRetorno )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �MenuDef �Defini��o das rotinas para o programa                            ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01.05.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �Nil.                                                                      ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Static Function MenuDef()
//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Private aRotina	:= {}

/*
If( AllTrim( cVersao ) ) == "P10"
aRotina		:= {	{ "Pesquisar",		"PesqBrw()",								0, 1, 0, Nil },;
{ "Visualizar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 2)",	0, 2, 0, Nil },;
{ "Incluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 3)",	0, 3, 0, Nil },;
{ "Alterar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 4)",	0, 4, 0, Nil },;
{ "Excluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 5)",	0, 5, 0, Nil } }
Else
aRotina		:= {	{ "Pesquisar",		"AxPesqui()",								0, 1 },;
{ "Visualizar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 2)",	0, 2 },;
{ "Incluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 3)",	0, 3 },;
{ "Alterar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 4)",	0, 4 },;
{ "Excluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 5)",	0, 5 } }
EndIf
*/
aRotina		:= {	{ "Pesquisar",		"PesqBrw()",								0, 1, 0, Nil },;
{ "Visualizar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 2)",	0, 2, 0, Nil },;
{ "Incluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 3)",	0, 3, 0, Nil },;
{ "Alterar",		"U_Ado03Cad('PAH', PAH->( Recno() ), 4)",	0, 4, 0, Nil },;
{ "Excluir",		"U_Ado03Cad('PAH', PAH->( Recno() ), 5)",	0, 5, 0, Nil },;
{ "Substituir",		"U_Ado03Sub('PAH', PAH->( Recno() ), 6)",	0, 4, 0, Nil } }

Return( aRotina )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���                            TOTVS S/A - F�brica Tradicional                            ���
�����������������������������������������������������������������������������������������͹��
���Programa    �A030Pend�Verifica se existem pedidos pendentes de aprova��o               ���
�����������������������������������������������������������������������������������������͹��
���Autor       �17.07.08�Almir Bandina                                                    ���
�����������������������������������������������������������������������������������������͹��
���Par�metros  �Nil                                                                       ���
�����������������������������������������������������������������������������������������͹��
���Retorno     �ExpL1 - .T. Valida��es corretas                                           ���
���            �        .F. Valida��es com diverg�ncia                                    ���
�����������������������������������������������������������������������������������������͹��
���Observa��es �                                                                          ���
�����������������������������������������������������������������������������������������͹��
���Altera��es  � 99.99.99 - Consultor - Descri��o da Altera��o                            ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function A030Pend( nChamada )
//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Local oLst
Local oDlg
Local bCancel   := {|| oDlg:End() }
Local bOk       := {|| oDlg:End() }
Local aAreaAtu	:= GetArea()
Local aStruSCr	:= {}
Local aLst		:= {}
Local lRetorno	:= .T.
Local nLoop1	:= 0
Local cLst		:= ""
Local cQry		:= ""
Local cAprSub	:= ""
Local cAprOfi	:= ""
Local cNivel	:= ""

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
//�����������������������������������������������������������������������������������������Ŀ
//� Ajusta vari�vel de acordo com a Chamada                                                 �
//�������������������������������������������������������������������������������������������
If nChamada == 1	// LinhaOk
	//cAprSub	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } ) ]
	cAprSub	:= oGDados:aCols[n, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } ) ]
	cAprOfi	:= oGDados:aCols[n, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_APROFI" } ) ]
	cNivel	:= GetNivel( cAprOfi )
	GetPedPen( @aLst, cAprSub, cNivel, oGDados:aCols[n, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_DATINI" } ) ], oGDados:aCols[n, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_DATFIM" } ) ] )
Else
	For nLoop1 := 1 To Len( oGDados:aCols )
		//cAprSub	+= If( !Empty( cAprSub ), "/", "" ) + oGDados:aCols[nLoop1, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } ) ]
		cAprSub	:= oGDados:aCols[nLoop1, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_APRSUB" } ) ]
		cAprOfi	+= If( !Empty( cAprOfi ), "/", "" ) + oGDados:aCols[nLoop1, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_APROFI" } ) ]
		cNivel	:= GetNivel( cAprOfi )
		GetPedPen( @aLst, cAprSub, cNivel, oGDados:aCols[nLoop1, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_DATINI" } ) ], oGDados:aCols[nLoop1, aScan( oGDados:aHeader, { |x| AllTrim( x[2] ) == "PAH_DATFIM" } ) ] )
	Next nLoop1
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Se encontrar pedidos rejeitados ou liberados mostra para usu�rio e n�o permite excluir  �
//�������������������������������������������������������������������������������������������
If Len( aLst ) > 0
	lRetorno	:= .F.
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta a tela de interface com o usu�rio                                                 �
	//�������������������������������������������������������������������������������������������
	DEFINE MSDIALOG oDlg TITLE "Pedidos Liberados/Rejeitados" From 000,000 To 265,410 OF oMainWnd PIXEL
	@ 015,003 LISTBOX oLst VAR cLst Fields	HEADER ;
	"Pedido",;
	"Emiss�o",;
	"Valor Total",;
	"Tipo de Libera��o" ;
	COLSIZES ;
	15,;
	35,;
	50,;
	30 ;
	SIZE 200,115 PIXEL
	oLst:SetArray(aLst)
	oLst:bLine	:= { || {	aLst[oLst:nAt,1],;											// N�mero Pedido
	aLst[oLst:nAt,2],;											// Data Emiss�o
	Transform( aLst[oLst:nAt,3], "@E 999,999,999.99" ),;		// Valor Pedido
	iIf( aLst[oLst:nAt,4] == "A", "Aprovador", "Vistador" ) ;	// Tipo
	} }
	oLst:Refresh()
	ACTIVATE MSDIALOG oDlg Centered ON INIT EnchoiceBar( oDlg, bOk, bcancel )
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Restaura a �rea original do arquivo                                                     �
//�������������������������������������������������������������������������������������������
RestArea( aAreaAtu )

Return( lRetorno )


Static Function GetNivel( cAprov )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()
Local cQry		:= ""
Local cArqQry1	:= GetNextAlias()
Local cNivel	:= ""
//�����������������������������������������������������������������������������������������Ŀ
//� Monta a string da query para obter o nivel do aprovador substituto                      �
//�������������������������������������������������������������������������������������������
cQry	:= " SELECT PAG.PAG_NIVEL"
cQry	+= " FROM " + RetSqlName( "PAG" ) + " PAG"
cQry	+= " WHERE PAG.PAG_FILIAL = '" + xFilial( "PAG" ) + "'"
cQry	+= " AND PAG.PAG_CODGRP = '" + cCodGrp + "'"
//cQry	+= " AND PAG.PAG_IDUSER IN " + FormatIn( cAprSub, "/" )
cQry	+= " AND PAG.PAG_IDUSER IN " + FormatIn( cAprov, "/" )
cQry	+= " AND PAG.D_E_L_E_T_ = ' '"
//�����������������������������������������������������������������������������������������Ŀ
//� Compatibiliza a query com o banco em uso                                                �
//�������������������������������������������������������������������������������������������
cQry	:= ChangeQuery( cQry )
//�����������������������������������������������������������������������������������������Ŀ
//� Executa a sele��o dos registros                                                         �
//�������������������������������������������������������������������������������������������
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQry ),cArqQry1 )
//�����������������������������������������������������������������������������������������Ŀ
//� Seleciona o arquivo tempor�rio e obtem o n�vel do aprovador                             �
//�������������������������������������������������������������������������������������������
dbSelectArea( cArqQry1 )
dbGoTop()
While !Eof()
	cNivel	+= If( !Empty( cNivel ), "/" + ( cArqQry1 )->PAG_NIVEL, "" + ( cArqQry1 )->PAG_NIVEL )
	dbSkip()
EndDo
//�����������������������������������������������������������������������������������������Ŀ
//� Fecha o arquivo de trabalho e restaura a area original                                  �
//�������������������������������������������������������������������������������������������
dbSelectArea( cArqQry1 )
dbCloseArea()
RestArea( aAreaAtu )

Return( cNivel )


Static Function GetPedPen( aLst, cAprSub, cNivel, dDatIni, dDatFim )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()
Local cQry		:= ""
Local cArqQry2	:= GetNextAlias()
Local nLoop1		:= 0
//�����������������������������������������������������������������������������������������Ŀ
//� Monta a string da query para obter os pedidos liberados ou rejeitados para o aprovador  �
//�������������������������������������������������������������������������������������������
cQry	:= " SELECT SCR.CR_NUM,SCR.CR_TOTAL,SCR.CR_XTPLIB,SCR.CR_EMISSAO"
cQry	+= " FROM " + RetSqlName( "SCR" ) + " SCR"
cQry	+= " WHERE SCR.CR_FILIAL = '" + xFilial( "SCR" ) + "'"
cQry	+= " AND SCR.CR_APROV = '" + cCodGrp + "'"
//cQry	+= " AND SCR.CR_USER = '" + cAprSub + "'"
cQry	+= " AND SCR.CR_USER IN " + FormatIn( cAprSub, "/" )
cQry	+= " AND SCR.CR_STATUS IN ( '03', '04' )"
cQry	+= " AND SCR.CR_NIVEL IN " + FormatIn( cNivel, "/" )
cQry	+= " AND SCR.CR_EMISSAO BETWEEN '" + DToS( dDatIni ) + "' AND '" + DToS( dDatFim ) + "'
cQry	+= " AND SCR.D_E_L_E_T_ = ' '"
//�����������������������������������������������������������������������������������������Ŀ
//� Compatibiliza a query com o banco em uso                                                �
//�������������������������������������������������������������������������������������������
cQry	:= ChangeQuery( cQry )
//�����������������������������������������������������������������������������������������Ŀ
//� Executa a sele��o dos registros                                                         �
//�������������������������������������������������������������������������������������������
dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQry ),cArqQry2 )
//�����������������������������������������������������������������������������������������Ŀ
//� Compatibiliza os campos com a TopField                                                  �
//�������������������������������������������������������������������������������������������
aStruSCR := SCR->( dbStruct() )
For nLoop1 := 1 To Len( aStruSCR )
	If aStruSCR[nLoop1,2] <> "C"
		TcSetField( cArqQry2, aStruSCR[nLoop1,1], aStruSCR[nLoop1,2], aStruSCR[nLoop1,3], aStruSCR[nLoop1,4] )
	EndIf
Next nX
//�����������������������������������������������������������������������������������������Ŀ
//� Seleciona o arquivo tempor�rio e obtem o n�vel do aprovador                             �
//�������������������������������������������������������������������������������������������
dbSelectArea( cArqQry2 )
dbGoTop()
While !Eof()
	aAdd( aLst, {	Left( (cArqQry2)->CR_NUM, 10 ),;
	(cArqQry2)->CR_EMISSAO,;
	(cArqQry2)->CR_TOTAL,;
	(cArqQry2)->CR_XTPLIB ;
	} )
	dbSkip()
EndDo
dbSelectArea( cArqQry2 )
dbCloseArea()
RestArea( aAreaAtu )

Return( Nil )


//�������������������������������������������������������������������������������������������������Ŀ
//� Fun��o disponivel para escolher um aprovador e atualizar para todos os grupos automaticamente  �
//���������������������������������������������������������������������������������������������������
User Function Ado03Sub()

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_cAprovAtu := space(6)
_dDtIni := CTOD("  /  /  ")
_dDtFim := CTOD("  /  /  ")
_cAprovSub := space(6)

DEFINE MSDIALOG _oDlg TITLE "Criar novo aprovador substituto" FROM (235),(480) TO (489),(919) PIXEL
@ (000),(001) TO (115),(218) LABEL "Dados" PIXEL OF _oDlg
@ (015),(010) Say "Aprovador Atual:" Size (050),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (015),(090) MsGet o_cAprovAtu Var _cAprovAtu F3 "USR" Size (030),(009) COLOR CLR_BLACK PIXEL OF _oDlg
@ (030),(010) Say "Data Inicio:" Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (030),(090) MsGet o_dDtIni Var _dDtIni Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (045),(010) Say "Data Final:" Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (045),(090) MsGet o_dDtFim Var _dDtFim Size (035),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (060),(010) Say "Aprovador Subst.:" Size (050),(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ (060),(090) MsGet o_cAprovSub Var _cAprovSub F3 "USR" Size (030),(008) COLOR CLR_BLACK PIXEL OF _oDlg

DEFINE SBUTTON FROM (100),(070) TYPE 1 ENABLE OF _oDlg ACTION (U_IncSub(_cAprovAtu,_cAprovSub,_dDtIni,_dDtFim))
DEFINE SBUTTON FROM (100),(130) TYPE 2 ENABLE OF _oDlg ACTION ( _oDlg:END())
ACTIVATE MSDIALOG _oDlg CENTERED

Return()

User Function IncSub(_cAprovAtu,_cAprovSub,_dDtIni,_dDtFim)

U_ADINF009P('ADOA030' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

dbSelectArea("PAG")
dbSetOrder(1)
dbGoTop()
While !Eof()
	If Alltrim(_cAprovAtu) == Alltrim(PAG->PAG_IDUSER)
		If PAG->PAG_MSBLQL <> "1"
			
			If Select( "TMP0" ) > 0
				dbSelectArea( "TMP0" )
				dbCloseArea()
			EndIf
			
			cQuery:=" SELECT MAX(PAH_NUMSEQ) AS NUMSEQ FROM " + RetSqlName("PAH")
			cQuery+=" WHERE D_E_L_E_T_ <> '*' "
			cQuery+=" AND PAH_CODGRP = '" + Alltrim(PAG->PAG_CODGRP) + "' "
			
			TCQUERY cQuery new alias "TMP0"
			TMP0->(dbgotop())
			
			RecLock("PAH",.T.)
			PAH_FILIAL := xFilial("PAG")
			PAH_NUMSEQ := Strzero(Val(TMP0->NUMSEQ) + 1,3)
			PAH_CODGRP := Alltrim(PAG->PAG_CODGRP)
			PAH_APROFI := _cAprovAtu
			PAH_DATINI := _dDtIni
			PAH_DATFIM := _dDtFim
			PAH_APRSUB := _cAprovSub
			PAH_MSBLQL := "2"
			MsUnLock()
		Endif
	Endif
	dbSelectArea("PAG")
	PAG->(dbSkip())
Enddo

Alert("Processo Finalizado")

Return()
