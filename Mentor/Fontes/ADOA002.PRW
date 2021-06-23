#INCLUDE "PROTHEUS.CH"
#INCLUDE 'rwmake.ch' 
#INCLUDE "topconn.ch" 

/*/{Protheus.doc} User Function ADOA002
	Cadastro Espelho de Clientes.
	@type  Function
	@author Vogas Junior
	@since 19/08/2009
	@version 01
	@history Chamado 042689 - Fernando Sigoli   - 12/12/2018 - Bloqueio de campos PB3_LIMAPR/PB3_COND p/usuarios diferentes do credito, respeitando o nivel de acesso
	@history Chamado 048393 - Adriana Oliveira  - 08/04/2019 - Na inclusao do Cliente no SA1 caso usuario nao seja Vendedor sera gravado A1_VEND=MV_VALVEND
	@history Chamado 052614 - Abel Babini       - 18/10/2019 - Na inclusao do Cliente, permitir duplicidade de CPF para clientes do tipo Pessoa Fisica pois produtor rural pode ter varias inscrições estaduais
	@history Chamado 049120 - WILLIAM COSTA     - 23/03/2020 - Adicionado no vetor para gravar o campo A1_XBKPRED, backup da rede para o comercial
	@history chamado 050729 - FWNM              - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history chamado 059812 - Everson 			    - 28/07/2020 - Tratamento para erro de código de município na alteração de cadastro de cliente.
	@history chamado 059553 - Everson 			    - 30/07/2020 - Tratamento para inclusão de preço mínimo de pedido de venda no cadastro do cliente.
	@history Ticket 692 	- Adriana Oliveira 	  - 03/09/2020 - Grava dados do Regime Especial 57608/11
	@history Ticket 423 	- Adriana Oliveira 	  - 01/10/2020 - Habilita rotina para demais empresas
	@history Ticket 8118  - Abel Babini         - 19/01/2021 - Alteração do campo A1_SIMPLES para A1_SIMPNAC
/*/

/*
*************Ao fazer alterações neste fonte, verificar o fonte ADVEN051P (serviço Rest para inclusão de pré-cadastro).
*/

User Function ADOA002()

	Local aArea		:= GetArea()
	Local oComboBusca
	Local oComboMotivo
	Local oDlg
	Local oGet
	Local oFont
	Local oEnchADO002
	Local nx 			:= 0
	Local aComboBusca	:= {'Nome', 'Nome Fantasia', 'Código', 'CPF/CNPJ'}
	Local aComboMotivo	:= {}
	Local nOpcao		:= 0
	Local cComboBusca	:= aComboBusca[1]
	Local aCampoAlt		:= {}
	Local cQuery		:= ''
	Local cFilPB3		:= xFilial("PB3")
	Local cArqTrab 		:= " "
	Local cCodSec 		:= ""
	Local cInd1Trab 	:= " "
	Local aCposBrw 		:= {}
	Local aStruct 		:={}
	Local aTamSx 		:= {}
	Local cAliasQry		:= ''
	Local aSize    		:= MsAdvSize()
	Local aInfo			:= {}
	Local aPosObj  		:= {}
	Local aObjects 		:= {}
	Local cComboMotivo	:= ''
	Local cSuperGerent	:= ''
	Local nNivelCred  	:= Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )
	Local lBackOffice  	:=  Posicione( 'PB2', 1, xFilial( 'PB2' ) + __cUserId, 'PB2_BCKOFI') = '1' // eh Back Office
	Local aButtons 		:= {	{ 'CADEADO', { || U_ShowVer() }, "Versão" } }
	Local _lUsaPreCli	:= GETMV("MV_#PRECLI",,.F.) //Ticket 423 por Adriana em 01/10/2020

	Private cMotivo	:= ''
	Private cBusca   	:= Space(30)
	Private cCampoAlt	:= ''
	Private cCadastro 	:= OemToAnsi('Cadastro de Pré-Clientes')
	Private _nDelBrw    := 0
	Private aRotina 	:= ''
	Private aTela	[0][0]
	Private aGets	[0]
	Private cNomeLog	:= "ESPCLI" + DTOS(Date()) + __cUserId + StrTran(Time(),":","") + ".log"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	If .not. _lUsaPreCli  //Ticket 423 por Adriana em 01/10/2020

		Aviso("ATENCAO","A rotina de Pré-cadastro não está ativa para esta Empresa (MV_#PRECLI)",{"OK"})
		Return .F.

	EndIf

	U_FSAbreLog(cNomeLog,.F.)

	//Private INCLUI

	// Registro esta em analise, somente podera ser alterado por um usuario com nivel de credito ou superior
	DbSelectArea('PB1')
	PB1->( DbSetOrder( 1 ) )
	if PB1->( DbSeek( xFilial( 'PB1' ) + __cUserId ))

		If Val( PB1->PB1_NIVEL ) >= nNivelCred
			cMsg := 'As Rotinas de Pré-Cliente não estão liberadas para seu Nivel.'
			u_FSGrvLog( cMsg + CRLF )
			Alert( cMsg )
			u_FSClsLog()
			Return
		Endif
	else
		cMsg := 'Você não está autorizado a utilizar essa rotina. Solicite permissão ao seu superior.'
		u_FSGrvLog( cMsg + CRLF)
		Alert( cMsg )
		u_FSClsLog()
		Return
	endif

	//Tamanho da tela
	aAdd( aObjects, {   0, 110, .t., .f. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )


	DbSelectArea( "PB4")
	PB4->(DbSetOrder(1))
	PB4->( DbGoTop())
	While ! PB4->( EOF())
		aAdd( aComboMotivo, PB4->PB4_DESCRI)
		aAdd( aCampoAlt,{ PB4->PB4_DESCRI, AllTrim(MSMM(PB4->PB4_CODMEM)) })
		PB4->( DbSkip())
	Enddo

	DEFINE MSDIALOG oDlg TITLE "Cadastro de Pré-Clientes" FROM 10,10 To 200,420 OF oMainWnd PIXEL

	@ 45,10 Say "Buscar Por:" SIZE 200,15 OF oDlg PIXEL
	@ 78,10 Say "Motivo:" SIZE 200,15 OF oDlg PIXEL


	// Combo de opcoes para a busca
	oComboBusca := tComboBox():New( 03, 05, {|u|If( pCount() > 0, cComboBusca := u, cComboBusca)},;
	aComboBusca, 100,20,oDlg,,{||},,,,.F.,,,,,,,,,'cComboBusca')

	// Get de insercao de dados da Busca
	oGet := tGet() :New( 4.5, 05, {|u|If( pCount()>0, cBusca:= u, cBusca) }, oDlg, 100, 15,;
	'@!',{||},,,oFont,,,.F.,,,,,,,,,,'cBusca')

	// Combo de Motivo do Cadastro.
	oComboMotivo := tComboBox():New( 06, 05, {|u|If( pCount() > 0, cComboMotivo := u, cComboMotivo)},;
	aComboMotivo, 100, 20, oDlg,,{||},,,,.F.,,,,,,,,,'cComboMotivo')

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()},.F.,aButtons)

	If nOpcao == 0
		RestArea( aArea )
		cMsg := 'Cancelou a Execução'
		u_FSGrvLog( cMsg + CRLF)
		u_FSClsLog()
		Return
	Endif

	// Obtem o código do motivo escolhido
	If !Empty(cComboMotivo)
		DbSelectArea( "PB4")
		PB4->(DbSetOrder(2))
		If PB4->( DbSeek( xFilial( 'PB4' ) + cComboMotivo))
			cMotivo := PB4->PB4_CODIGO + ' - ' + AllTrim( PB4->PB4_DESCRI )
			u_FSGrvLog( "Escolheu o motivo |" + cMotivo + "|" + CRLF)
		Endif
	Endif

	DbSelectArea("PB3")

	//INCLUI := FazBusca( cBusca, cComboBusca)
	If !Empty( aCampoAlt ) .And. !Empty( cComboMotivo )
		cCampoAlt := aCampoAlt[ Ascan( aCampoAlt,{|x| Alltrim(x[1]) == AllTrim(cComboMotivo)}),2]
	Endif


	cSuperGerent := GetSuperGer()

	aadd(aTamSx,TamSx3("PB3_BLOQUE"))
	aadd(aTamSx,TamSx3("PB3_CGC"))
	aadd(aTamSx,TamSx3("PB3_CODSA1"))
	aadd(aTamSx,TamSx3("PB3_LOJSA1"))
	aadd(aTamSx,TamSx3("PB3_NOME"))
	aadd(aTamSx,TamSx3("PB3_NREDUZ"))

	aCposBrw := {	{ "Bloqueado"		, {|| TRB->PB3_BLOQUE 	}	, (aTamSx[1,3]), (aTamSx[1,1]), (aTamSx[1,2]), '@!' },;
	{ "CPF/CNPJ"		, {|| TRB->PB3_CGC 		}	, (aTamSx[2,3]), (aTamSx[2,1]), (aTamSx[2,2]), '@!' },;
	{ "Codigo"			, {|| TRB->PB3_CODSA1 	}	, (aTamSx[3,3]), (aTamSx[3,1]), (aTamSx[3,2]), '@!' },;
	{ "Loja"			, {|| TRB->PB3_LOJSA1 	}	, (aTamSx[4,3]), (aTamSx[4,1]), (aTamSx[4,2]), '@!' },;
	{ "Nome"			, {|| TRB->PB3_NOME  	}	, (aTamSx[5,3]), (aTamSx[5,1]), (aTamSx[5,2]), '@!' },;
	{ "Nome Fantasia"	, {|| TRB->PB3_NREDUZ 	}	, (aTamSx[6,3]), (aTamSx[6,1]), (aTamSx[6,2]), '@!' }}


	aStruct  := {}

	aAdd( aStruct, { "PB3_FILIAL"  		,  "C" ,2 , 0 } )
	aAdd( aStruct, { "PB3_BLOQUE"		,  "C",  3 , 0, '@! '	} )
	aAdd( aStruct, { "PB3_CGC"			, (aTamSx[2,3]),(aTamSx[2,1]), (aTamSx[2,2]) } )
	aAdd( aStruct, { "PB3_CODSA1"		, (aTamSx[3,3]),(aTamSx[3,1]), (aTamSx[3,2]) } )
	aAdd( aStruct, { "PB3_LOJSA1"		, (aTamSx[4,3]),(aTamSx[4,1]), (aTamSx[4,2]) } )
	aAdd( aStruct, { "PB3_NOME"	   		, (aTamSx[5,3]),(aTamSx[5,1]), (aTamSx[5,2]) } )
	aAdd( aStruct, { "PB3_NREDUZ"		, (aTamSx[6,3]),(aTamSx[6,1]), (aTamSx[6,2]) } )
	aAdd( aStruct, { "PB3_RECNO"		,  "N", 10 , 0, '@E ' } )
	aAdd( aStruct, { "PB3_COD"			, (aTamSx[3,3]),(aTamSx[3,1]), (aTamSx[3,2]) } )

	cArqTrab := CriaTrab( aStruct, .T. )

	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
	//dbUseArea(.T.,"DBFCDX",cArqTrab,"TRB",.F.,.F.)
	dbUseArea(.T.,,cArqTrab,"TRB",.F.,.F.) 

	cInd1Trab := CriaTrab(Nil,.F.)
	IndRegua("TRB",cInd1Trab,"TRB->PB3_FILIAL+TRB->PB3_COD",,,)
	dbClearIndex()
	dbSetIndex(cInd1Trab+OrdBagExt())

	dbSelectArea("TRB")
	dbSetOrder(1)
	cAliasQry := getNextAlias()

	cQuery := " SELECT *,R_E_C_N_O_ RECNO FROM " + RetSQLName("PB3")
	cQuery += " WHERE PB3_FILIAL = '" + cFilPB3 + "'"

	If ! Empty( cBusca )
		Do Case
			Case cComboBusca == 'Nome'
			cQuery += " AND PB3_NOME LIKE '%" 	+ AllTrim( cBusca ) + "%'"
			Case cComboBusca == 'Nome Fantasia'
			cQuery += " AND PB3_NREDUZ LIKE '%" 	+ AllTrim( cBusca ) + "%'"
			Case cComboBusca == 'Código'
			cQuery += " AND PB3_CODSA1 LIKE '%"	+ AllTrim( Left ( cBusca, 6 )) + "%'"
			cQuery += " AND PB3_LOJSA1 LIKE '%"	+ AllTrim( Right( cBusca, 2 )) + "%'"
			Case cComboBusca == 'CPF/CNPJ'
			cQuery += " AND PB3_CGC LIKE '%" 	+ AllTrim( cBusca ) + "%'"
		EndCase
	Endif
	if !lBackOffice
		If ! Empty( cSuperGerent )
			cQuery += " AND ( PB3_VEND IN( " + AllTrim( cSuperGerent ) + " ) Or PB3_VENENC IN( " + AllTrim( cSuperGerent ) + " )  )"
		Else
			cQuery += " AND ( PB3_VEND = '" 	+ AllTrim( __cUserId ) + "' Or PB3_VENENC = '" 	+ AllTrim( __cUserId ) + "'"
		Endif
	endif
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + SqlOrder( PB3->( IndexKey() ) )

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	DbSelectArea(cAliasQry)
	dbGotop()
	While (cAliasQry)->( !Eof() )
		IncProc("Gerando Arquivo de Trabalho...")  // "Gerando Arquivo de Trabalho..."

		//Grava o arquivo de trabalho.

		RecLock("TRB", .T.)
		TRB->PB3_FILIAL	:= (cAliasQry)->PB3_FILIAL
		TRB->PB3_CODSA1 := (cAliasQry)->PB3_CODSA1
		TRB->PB3_LOJSA1	:= (cAliasQry)->PB3_LOJSA1
		TRB->PB3_CGC	:= (cAliasQry)->PB3_CGC
		TRB->PB3_NOME  	:= (cAliasQry)->PB3_NOME
		TRB->PB3_NREDUZ	:= (cAliasQry)->PB3_NREDUZ
		TRB->PB3_RECNO 	:= (cAliasQry)->RECNO
		TRB->PB3_BLOQUE	:= If( Alltrim((cAliasQry)->PB3_BLOQUE) == '1', 'Sim', 'Nao')
		TRB->PB3_COD  	:= (cAliasQry)->PB3_COD

		TRB->( msUnLock() )

		(cAliasQry)->( dbSkip() )
	Enddo

	aRotina := MenuDef()

	dbSelectArea("TRB")
	dbgotop()
	mBrowse( 6, 1,22,75,"TRB",aCposBrw,,,,,,'xFilial("PB3")','xFilial("PB3")')

	dbSelectArea("TRB")
	TRB->( DbCloseArea())

	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
	//fErase(cArqTrab + '.DBF')
	fErase(cArqTrab + GetDBExtension() )
	fErase(cInd1Trab + OrdBagExt() )

	cMsg := 'Encerramento normal do programa' + CRLF
	u_FSGrvLog( cMsg )

	u_FsClsLog()
	RestArea( aArea )

Return(.T.)

/*{Protheus.doc} Static Function GravaCli
	Realiza a Gravacao dos dados digitados pelo usuario.
	@type  Function
	@author Vogas Junior
	@since 28/08/2009
	@version 01
*/

Static Function GravaCli(/*INCLUI, aHeader, aCols */)

	Local bCampo	:= {|nCPO| Field(nCPO) }
	Local nX		:= 0
	Local nI		:= 0
	Local cUsuario	:= Posicione('PB1', 1, xFilial('PB1') + __cUserId, 'PB1_NOME')
	Local lTemRed	:= .F.
	Local cFilSZF	:= xFilial( 'SZF' )
	Local lVirtual	:= .F.
	Local cFilPBE	:= xFilial( 'PBE' )
	Local cCodVen   := Posicione("SA3",7,xFilial("SA3")+M->PB3_VEND,"A3_COD")
	Local aAreaSav	:= GetArea()
	DbSelectArea('PB3')
	PB3->( DbSetOrder( 1 ))
	PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))

	M->PB3_VENENC := __cUserId

	If INCLUI .and. empty(cCodVen) 	   //Sigoli 06/12/2016 Chamado: 031597
		cCodVen := Getmv("MV_VALVEND") //Se o usuario não estiver cadastrado como Vendedor, o cadastro assumi a carteira MV_VALVEND 
	EndIF                  

	// Grava o temporario para refresh em tela das alteracoes
	//If AllTrim( M->PB3_BLOQUE ) <> PB3->PB3_BLOQUE
	If ! IsInCallStack('RESTEXECUTE') //Everson - 09/10/2017. Chamado 037261. 
		DbSelectArea( 'TRB')
		TRB->( DbGoTop() )
		TRB->( DbSetOrder( 1 ))
		If INCLUI

			RecLock("TRB", INCLUI)

			TRB->PB3_BLOQUE	:= If( Alltrim(M->PB3_BLOQUE) == '1', 'Sim', 'Nao')
			TRB->PB3_CGC	:= M->PB3_CGC
			TRB->PB3_NOME	:= M->PB3_NOME
			TRB->PB3_NREDUZ	:= M->PB3_NREDUZ

			TRB->( msUnLock() )
		Else
			If TRB->( DbSeek( xFilial('PB3') + PB3->PB3_COD ))
				RecLock("TRB", INCLUI)

				TRB->PB3_BLOQUE	:= If( Alltrim(M->PB3_BLOQUE) == '1', 'Sim', 'Nao')
				TRB->PB3_CGC	:= M->PB3_CGC
				TRB->PB3_NOME	:= M->PB3_NOME
				TRB->PB3_NREDUZ	:= M->PB3_NREDUZ

				TRB->( msUnLock() )
			Endif
		Endif

	EndIf
	lProssegue := .T.
	If INCLUI

		If AllTrim( M->PB3_EST ) != 'EX'
			If Empty(M->PB3_CGC)
				lProssegue := .F.
			Endif
		Endif

		If lProssegue
			DbSelectArea('PB3')
			PB3->( DbSetOrder( 3 ))
			//052614 || OS 053991 || INCUBATORIO || VALERIA || CAD. CLIENTES || ABEL BABINI || 18/10/2019 || LIBERADO PARA PRODUTOR RURAL PESSOA FISICA POIS PODEM POSSUIR MAIS DE UMA INSCRIÇÃO ESTADUAL.
			// Regras Para clientes com o mesmo CPF/CNPJ
			If PB3->( DbSeek( xFilial('PB3') + M->PB3_CGC )) .AND. (Alltrim(M->PB3_PESSOA)== "J") //

				If AllTrim( M->PB3_EST ) != 'EX' .And. Empty( M->PB3_REGESP )
					If !Empty(M->PB3_COD) .And. !Empty(PB3->PB3_COD) .and. !Empty(M->PB3_LOJA) .And. !Empty(PB3->PB3_LOJA)
						If M->PB3_COD <> PB3->PB3_COD .OR. M->PB3_LOJA <> PB3->PB3_LOJA

							If IsInCallStack('RESTEXECUTE')
								Aadd(aRestErro,{400,'CPF/CNPJ já cadastrado.'}) //Everson - 09/10/2017. Chamado 037261. 
							Else
								Alert( 'CPF/CNPJ jà Cadastrado!' )

							EndIf

							lProssegue := .F.
						Endif
					Else

						If IsInCallStack('RESTEXECUTE')
							Aadd(aRestErro,{409,'CPF/CNPJ já cadastrado.'}) //Everson - 09/10/2017. Chamado 037261. 
						Else
							Alert( 'CPF/CNPJ jà Cadastrado!' )

						EndIf

						lProssegue := .F.
					Endif
					// E cozinha industrial porem, o codigo do sub-segmento esta errado
				ElseIf !Empty( M->PB3_REGESP ) .And. !(AllTrim( M->PB3_SUBSEG ) $ '51&52&53')

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53.'}) //Everson - 09/10/2017. Chamado 037261. 
					Else
						Alert( 'Para Cadastrar uma Cozinha Industrial, deve-se utilizar o codigo de Subsegmento 51, 52 ou 53 ' )

					EndIf

					lProssegue := .F.

				Elseif (AllTrim( M->PB3_SUBSEG ) $ '51$52$53') .and. Empty(M->PB3_CODMAT)

					If IsInCallStack('RESTEXECUTE')
						Aadd(aRestErro,{400,'Filial de Cozinha Industrial deve ter o Codigo da Matriz preenchido.'}) //Everson - 09/10/2017. Chamado 037261. 
					Else
						Alert( 'Filial de Cozinha Industrial deve ter o Codigo da Matriz preenchido' )

					EndIf

					lProssegue := .F.
				Endif

			Endif

		Endif

	Else

		lProssegue := .T.

	Endif


	If lProssegue
		DbSelectArea('PB3')
		PB3->( DbSetOrder( 1 ))
		PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))


		M->PB3_SITUAC := ' '
		Reclock('PB3', If( INCLUI, .T., .F. ))

		cMsg := ""

		If INCLUI .and. .f. // o que quiseram fazer aqui??? eh um !INCLUI??
			If Empty(M->PB3_CODMAT)
				M->PB3_COD 	:= GetSxeNum("PB3","PB3_COD")
				M->PB3_LOJA := '00'
				cMsg := "Criou um novo codigo para o PB3_COD => |" + M->PB3_COD + "|"
			Else
				cMsg := "Alterou o codigo do PB3_COD => De |" + M->PB3_COD + "| para |" + M->PB3_CODMAT + "|"

				M->PB3_COD    := M->PB3_CODMAT
				M->PB3_LOJA   := '00'
				M->PB3_LOJSA1 := U_NextLoja(M->PB3_CODMAT)
			Endif
		Endif

		U_FsGrvLog( cMsg + CRLF)
		cMsg := ""

		//Inicio - Sigoli 28/11/2016 Chamado 029362
		If Alltrim(M->PB3_PESSOA) == 'F' .and. Empty(M->PB3_INSCR) //Clinte Pessoa Fisica, sem IE, contribuinte = N
			M->PB3_CONTRI := '2'
		EndIF
		//Fim - Sigoli 28/11/2016 Chamado 029362

		//M->PB3_CODVEN :=  cCodVen // chamado 036412 - Fernando Sigoli 26/07/2017
		If Empty(M->PB3_CODVEN)
			M->PB3_CODVEN :=  cCodVen
		EndIf

		If Inclui .and. !Empty(cCodVen)  //Incluido por Adriana em 22/09/16 - chamado 030579
			M->PB3_XVEND2 :=  cCodVen     
		Endif

		/*//Everson - 09/10/2017. Chamado 037261.
		If IsInCallStack('RESTEXECUTE') .And. Empty(Alltrim(cValToChar( M->PB3_COD  ))) .And. Inclui
		M->PB3_COD := GetSx8Num('PB3', 'PB3_COD')
		M->PB3_LOJA:= "00"
		cPreCad := cValToChar(M->PB3_COD ) + cValToChar(M->PB3_LOJA)

		EndIf*/

		For nX := 1 TO FCount()

			// PBra nao gravar campos virtuais
			If Posicione( 'SX3', 1, FieldName(nX), 'X3_CONTEXT') != 'V'
				If "_FILIAL"$FieldName(nX)
					FieldPut(nX,xFilial('PB3'))
				Else
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				EndIf
			Endif

		Next nX

		If INCLUI
			//	M->PB3_COD := GetSxeNum('PB3', 'PB3_COD')
			Confirmsx8()
		Endif

		// exclui registros de referencias comerciais
		If ! INCLUI
			DbSelectArea( 'PBE' )
			PBE->( DbSetOrder( 1 ))
			If PBE->( DbSeek( cFilPBE + M->PB3_COD + M->PB3_LOJA))
				While cFilPBE == PBE->PBE_FILIAL .And. + M->PB3_COD + M->PB3_LOJA == PBE->PBE_COD + PBE->PBE_LOJA
					RecLock( 'PBE', .F. )

					PBE->( DbDelete())
					PBE->( MsUnLock() )

					PBE->( DbSkip())
				Enddo
				cMsg := "Apagou as referencias comerciais do codigo " + M->PB3_COD + ", loja " + M->PB3_LOJA + CRLF
				U_FSGrvLog( cMsg )
			Endif
		Endif

		/*
		Local bCampo   := {|nCPO| Field(nCPO) }
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os campos Memos Virtuais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos") == "A"
		For nX := 1 to Len(aMemos)
		cVar := aMemos[nX][2]
		//Incluído parametro com o nome da tabela de memos => PBra módulo APT
		cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
		MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
		Next nX
		EndIf

		*/
		dbSelectArea("PB3")
		MsUnlock()

		cMsg := REPLICATE("-", 128) + CRLF
		cMsg += "Situação Depois da Atualização" + CRLF
		cMsg += 'Codigo do Cliente : ' + PB3->PB3_CODSA1 + CRLF
		cMsg += 'Loja do Cliente : ' + PB3->PB3_LOJSA1 + CRLF
		cMsg += 'Codigo interno PB3 : ' + PB3->PB3_COD + CRLF
		cMsg += 'Loja interna PB3 : ' + PB3->PB3_LOJA + CRLF
		cMsg += REPLICATE("-", 128) + CRLF
		CMSG += " " + CRLF

		u_FSGrvLog( cMsg )
	Else

		If ! IsInCallStack('RESTEXECUTE') //Everson - 09/10/2017. Chamado 037261.
			Alert( "Dados descartados devido a duplicidade do CGC/CPF" )

		EndIf

		cMsg := REPLICATE("-", 128) + CRLF
		cMsg += "Não efetuada a gravação pois ja existia um CGC identico cadastrado na base" + CRLF
		cMsg += "e não se trata de cozinha industrial."
		cMsg += REPLICATE("-", 128) + CRLF
		CMSG += " " + CRLF
		u_FSGrvLog( cMsg )
	Endif

	RestArea(aAreaSav)
Return Nil

/*{Protheus.doc} Static Function AdoGetCampos
	Transforma a variavel caracter em array para permissao de alteracao de campos da MsMget. 
	@type  Function
	@author Vogas Junior
	@since 31/08/2009
	@version 01
*/

Static Function AdoGetCampos(cCampoAlt, aEx)

	Local aRetorno	:= {}

	aRetorno := StrToKarr(AllTrim(cCampoAlt),',')

Return (aRetorno)

Static Function MenuDef()

	Local   cCodMotivo := SuperGetMv("FS_MOTIVOF", .F., 0 )
	Private cMotivo    := IIF(TYPE("cMotivo")=="U",'',cMotivo) //034091 - WILLIAM COSTA 09/05/2017
	Private aRotina	   := {}
	// Quando motivo do cadastro espelho for novo, a opcao alterar nao sera apresentada no menu.

	If Left( cMotivo, 2 ) == cCodMotivo

		aRotina :=	{	{"Incluir"		, "u_Ado002CRUD('TRB', TRB->( Recno()), 3)"	, 0, 3}} //, 0, nil}}
		//{"Pesquisar"	, "AxPesqui"		, 0, 1, 0, .F.},;
		//					{"Visualizar"	, "u_Ado002CRUD"	, 0, 2, 0, nil},;
	Else

		aRotina :=	{ 	{"Visualizar"	, "u_Ado002CRUD('TRB', TRB->( Recno()), 2)"	, 0, 2, 0, nil},;
		{"Incluir"		, "u_Ado002CRUD('TRB', TRB->( Recno()), 3)"	, 0, 3, 0, nil},;
		{"Alterar"		, "u_Ado002CRUD('TRB', TRB->( Recno()), 4)"	, 0, 4, 0, nil}}
		//{"Pesquisar"	, "AxPesqui"		, 0, 1, 0, .F.},;
	Endif

Return(aRotina)

/*{Protheus.doc} User Function ADOA002CRUD
	Operacao CRUD da mBrowse.
	@type  Function
	@author Vogas Junior
	@since 02/09/2009
	@version 01
*/

User Function Ado002CRUD( cAlias, nReg, nOpc )

	Local aArea		:= GetArea()
	Local oDlg2
	Local oGetd
	Local oEnchADO002
	Local aSize    	:= MsAdvSize()
	Local aInfo		:= {}
	Local aPosObj  	:= {}
	Local aObjects 	:= {}
	Local nOpcao	:= 0
	Local aCampos	:= {'PBE_NOME', 'PBE_DDD', 'PBE_FONE', 'PBE_OBS'}
	Local aAlter	:= aClone( aCampos )
	Local aCpoGDa   := {}
	Local aHeader	:= {}
	Local aCols		:= {}
	Local Nx		:= 0
	Local lInclui   := INCLUI //(nOpc == 3)
	Local lAltera   := ALTERA //(nOpc == 4)
	Local nOpcCrud	:= If( INCLUI, 1, 2)
	//Local cExcluirCpo := "PB3_REGCOB"
	Local cExcluirCpo := "PB3_REGCOB/PB3_COND/PB3_LIMAPR" //Chamado: 042689 
	Local aEncho := {"NOUSER"}

	Local aButtons := {} //Éverson - 05/10/2016. Chamado 030407.

	Private aTela	[0][0]
	Private aGets	[0]

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	DbSelectArea("SX3")
	DbSetOrder(1)

	SX3->(DbSetOrder(1))
	SX3->(DbSeek('PB3'))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'PB3'
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If Empty(cExcluirCpo) .Or. !(AllTrim(SX3->X3_CAMPO) $ cExcluirCpo)
				AADD(aEncho, SX3->X3_CAMPO)
			EndIf
		EndIf
		SX3->(DbSkip())
	End

	RegistroOk('PB3')

	
	AAdd( aObjects, { 100,  /*002*/100, .T., .T. })
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	
	If INCLUI //nOpc == 3 //Inclusao
		RegToMemory('PB3', .T. )

		/* Retirado por conta de novo tratamento chamado 034381 e incluido no fonte ADOA02_3
		&&Mauricio - 07/12/16 - tratamento para validar a inclusão solicitado por vagner chamado 031657
		IF M->PB3_CENTRA == "N"
		_nCont := 0 
		IF M->PB3_TELSEG == "S"
		_nCont ++
		Endif 
		IF M->PB3_TELTER == "S"
		_nCont ++
		Endif 
		IF M->PB3_TELQUA == "S"
		_nCont ++
		Endif 
		IF M->PB3_TELQUI == "S"
		_nCont ++
		Endif
		IF M->PB3_TELSEX == "S"
		_nCont ++
		Endif
		IF _nCont < 2
		MsgInfo("Dois dias da semana de ligação como sim é obrigatorio. Refaça o cadastro!")
		//oDlg2:End()
		RestArea(aArea)
		Return Nil
		Endif
		Endif
		*/      
	Else
		PB3->( DbGoTo(TRB->PB3_RECNO))
		RegToMemory('PB3', .F. )
	Endif

	// Motivo escolhido Para o acesso
	M->PB3_MOTACE := cMotivo
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFilial("SA1")+ M->PB3_CODSA1 + M->PB3_LOJSA1))
		M->PB3_ULTCOM := SA1->A1_ULTCOM
		M->PB3_MCOMPR := SA1->A1_MCOMPRA
		M->PB3_PRICOM := SA1->A1_PRICOM
		M->PB3_NROCOM := SA1->A1_NROCOM
		M->PB3_NROPAG := SA1->A1_NROPAG
		M->PB3_METR   := SA1->A1_METR
		M->PB3_MSALDO := SA1->A1_MSALDO
		M->PB3_SALDUP := SA1->A1_SALDUP
		M->PB3_SALPED := SA1->A1_SALPED
		M->PB3_VACUM  := SA1->A1_VACUM
		M->PB3_ATR    := SA1->A1_ATR
		M->PB3_SALPEL := SA1->A1_SALPEDL
	endif

	/*
	M->PB3_ULTCOM := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_ULTCOM' )
	M->PB3_MCOMPR := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_MCOMPRA' )
	M->PB3_PRICOM := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_PRICOM' )
	M->PB3_NROCOM := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_NROCOM' )
	M->PB3_NROPAG := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_NROPAG' )
	M->PB3_METR   := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_METR' )
	M->PB3_MSALDO := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_MSALDO' )
	M->PB3_SALDUP := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_SALDUP' )
	M->PB3_SALPED := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_SALPED' )
	M->PB3_VACUM  := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_VACUM' )
	M->PB3_ATR    := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_ATR' )
	M->PB3_SALPEL := Posicione( 'SA1', 1, xFilial('SA1') + M->PB3_CODSA1 + M->PB3_LOJA, 'SA1->A1_SALPEDL' )
	*/

	//Éverson - 05/10/2016. Chamado 030407.

	If lAltera
		Aadd(aButtons, {"", {|| gravarLogistica(oDlg2)}, "Gravar Dados Logistica"})
		//Aadd(aButtons, {"", {|| gravarTelevendas(oDlg2)}, "Gravar Agend. Lig."})
		//Aadd(aButtons, {"", {|| grvPromotor(oDlg2)}     , "Grv. Agend. Pmt."})
		//Aadd(aButtons, {"", {|| grvVendedor(oDlg2)}     , "Grv. Agend. Vend."})
		
	EndIf


	DEFINE MSDIALOG oDlg2 TITLE "Cadastro Pre-Clientes" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oEnchADO002:= MsMGet():New( "PB3" ,nReg, /*nOpc*/nOpcCrud, , , , aEncho,{aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4]} , AdoGetCampos(cCampoAlt), 0,,,'.T.', oDLG2, .F., .T., .F.,, .F.)

	ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) .And. U_ValInf1(oEnchADO002),oDlg2:End(),Nil)},{||nOpcao:=0,oDlg2:End()},.F.,aButtons) //Éverson - 05/10/2016. Chamado 030407. Adicionado vetor de botões.

	If nOpcao == 1
		cMsg := REPLICATE("-", 128) + CRLF
		cMsg += "Situação antes da " + Iif(nOpc==2,"Visualização",Iif(nOpc==3,"Inclusão","Alteração")) + CRLF
		cMsg += 'Codigo do Cliente : ' + M->PB3_CODSA1 + CRLF
		cMsg += 'Loja do Cliente : ' + M->PB3_LOJSA1 + CRLF
		cMsg += 'Codigo interno PB3 : ' + M->PB3_COD + CRLF
		cMsg += 'Loja interna PB3 : ' + M->PB3_LOJA + CRLF
		cMsg += REPLICATE("-", 128) + CRLF
		cMsg += ' ' + CRLF

		u_FSGrvLog( cMsg )

		GravaCli(/*If( nOpc == 3, .T., .F.), oGetD:aHeader, oGetD:aCols */)
	Endif

	RestArea( aArea )
Return

/*{Protheus.doc} Static Function gravarTelevendas
	Grava alterações feitas pelo Televendas sem a necessidade de passar por aprovação.  
	@type  Function
	@author Everson
	@since 05/10/2016
	@version 01
*/

Static Function gravarTelevendas(oDlg2)

	Local aArea			:= GetArea()
	Local cMsg			:= ""
	Local lEncontrou 	:= .T.    &&Chamado 034672 - Sigoli 11/04/2017

	//Solicita confirmação do usuário.
	If ! MsgYesNo("Deseja prosseguir com a alteração dos dados de Agendamento?","Função gravarTelevendas(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	BeginTran()

	//Atualiza dados na tabela PB3.
	DbSelectArea('PB3')
	PB3->(DbSetOrder(1))
	PB3->(DbGoTop())
	If ! PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))

		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Não foi possível atualizar os dados de Agendamento na tabela PB3.","Função gravarTelevendas(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	/*	//Everson - 31/01/2018. Chamado 037261.
	If Empty(Alltrim(cValToChar(M->PB3_LIGFRQ))) .Or. Empty(Alltrim(cValToChar(M->PB3_LIGSEM)))
		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Necessário informar a frequência e semana de ligações.","Função gravarTelevendas(ADOA002)")
		RestArea(aArea)
		Return Nil
			
	EndIf*/

	&&Mauricio - 25/04/17 - chamado 034381					
	IF M->PB3_CENTRA == "N" .Or. M->PB3_CENTRA == " "
		_nCont := 0
		IF M->PB3_TELSEG == "S"
			_nCont ++
		Endif
		IF M->PB3_TELTER == "S"
			_nCont ++
		Endif
		IF M->PB3_TELQUA =="S"
			_nCont ++
		Endif
		IF M->PB3_TELQUI == "S"
			_nCont ++
		Endif
		IF M->PB3_TELSEX == "S"
			_nCont ++
		Endif
		IF _nCont < 1
			Disarmtransaction()
			MsUnlockAll() 
			MsgStop("Pelo menos um dia da semana de ligação é obrigatorio!","Função gravarTelevendas(ADOA002)")
			oDlg2:End()
			RestArea(aArea)
			Return Nil								
		Endif
	Endif

	//Grava dados.
	RecLock("PB3",.F.)
	Replace PB3_TEL2	With M->PB3_TEL2
	Replace PB3_TEL3	With M->PB3_TEL3
	Replace PB3_TEL4	With M->PB3_TEL4
	Replace PB3_XTELCO	With M->PB3_XTELCO
	Replace PB3_TELSEG	With M->PB3_TELSEG
	Replace PB3_TELTER	With M->PB3_TELTER
	Replace PB3_TELQUA	With M->PB3_TELQUA
	Replace PB3_TELQUI	With M->PB3_TELQUI
	Replace PB3_TELSEX	With M->PB3_TELSEX
	Replace PB3_LIGFRQ	With M->PB3_LIGFRQ //Everson - 31/01/2018. Chamado 037261.
	Replace PB3_LIGSEM	With M->PB3_LIGSEM //Everson - 31/01/2018. Chamado 037261.
	Replace PB3_LIGHOR	With M->PB3_LIGHOR //Everson - 31/01/2018. Chamado 037261.
	MsUnlock()

	//Atualiza a tabela SA1.
	/*
	If ! U_AtuSa1("A",PB3->PB3_CODSA1,PB3->PB3_LOJSA1)

	Disarmtransaction()
	MsUnlockAll()
	MsgStop("Não foi possível atualizar os dados de Televendas na tabela SA1.","Função gravarTelevendas(ADOA002)")
	oDlg2:End()
	RestArea(aArea)
	Return Nil

	EndIf
	*/
	//Alterada por Adriana pois esta opção é exclusiva para gravação apenas dos dados de televendas - em 28/10/2016 - CHAMADO 031058

	//Grava dados SA1
	DbSelectArea("SA1")
	DbSetOrder(1)
	If ! SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1 ))

		//Disarmtransaction() && retirado a regra de retorno, caso nao encontrar o cliente na SA1 : Chamado 034672 - Sigoli 11/04/2017
		//MsUnlockAll() 
		//MsgStop("Não foi possível atualizar os dados de Agendamento na tabela SA1.","Função gravarTelevendas(ADOA002)")
		//oDlg2:End()
		//RestArea(aArea)
		//Return Nil

		MsgAlert("Não foi possível atualizar os dados de Agendamento na tabela SA1, apenas na PB3.","Função gravarTelevendas(ADOA002)")
		lEncontrou := .F.

	EndIf

	If lEncontrou && Chamado 034672 - Sigoli 11/04/2017

		RecLock("SA1",.F.)
		Replace A1_TEL2		With M->PB3_TEL2
		Replace A1_TEL3		With M->PB3_TEL3
		Replace A1_TEL4		With M->PB3_TEL4
		Replace A1_XTELCON	With M->PB3_XTELCO
		MsUnlock()

		//U_ADVEN029P(xFilial("SA1"),PB3->PB3_CODSA1,PB3->PB3_LOJSA1,4)    //para atualizar calendario TECLAN 

	EndIf

	//Fim alteracao por Adriana 		
	cMsg := REPLICATE("-", 128) + CRLF
	cMsg += "Situação Depois da Atualização" + CRLF
	cMsg += 'Codigo do Cliente : ' + PB3->PB3_CODSA1 + CRLF
	cMsg += 'Loja do Cliente : ' + PB3->PB3_LOJSA1 + CRLF
	cMsg += 'Codigo interno PB3 : ' + PB3->PB3_COD + CRLF
	cMsg += 'Loja interna PB3 : ' + PB3->PB3_LOJA + CRLF
	cMsg += 'Alterado dados do Agendamento' + CRLF
	cMsg += REPLICATE("-", 128) + CRLF
	cMSG += " " + CRLF

	u_FSGrvLog( cMsg )

	EndTran()
	
	//Everson - 04/03/2018. Chamado 037261. SalesForce.
/*	If FindFunction("U_ADVEN076P")
		U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.,"","AGLIG",.T.)
	
	EndIf*/

	MsgInfo("Dados de Agendamento alterados.","Função gravarTelevendas(ADOA002)")

	//Fecha a interface de edição de cadastro.
	oDlg2:End()

	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function grvPromotor
	Grava agenda do promotor. 
	@type  Function
	@author Everson
	@since 08/12/2017
	@version 01
*/

Static Function grvPromotor(oDlg2)

	Local aArea			:= GetArea()
	Local cMsg			:= ""
	Local lEncontrou 	:= .T. 

	//Solicita confirmação do usuário.
	If ! MsgYesNo("Deseja prosseguir com a alteração dos dados de agendamento do promotor?","Função grvPromotor(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	BeginTran()

	//Atualiza dados na tabela PB3.
	DbSelectArea('PB3')
	PB3->(DbSetOrder(1))
	PB3->(DbGoTop())
	If ! PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))

		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Não foi possível atualizar os dados de Agendamento na tabela PB3.","Função grvPromotor(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	&&Mauricio - 25/04/17 - chamado 034381					
	/*
	IF M->PB3_CENTRA == "N" .Or. M->PB3_CENTRA == " "

		_nCont := 0

		IF M->PB3_PRMSEG == "S"
			_nCont ++

		Endif
		IF M->PB3_PRMTER == "S"
			_nCont ++

		Endif
		IF M->PB3_PRMQUA == "S"
			_nCont ++

		Endif
		IF M->PB3_PRMQUI == "S"
			_nCont ++

		Endif
		IF M->PB3_PRMSEX == "S"
			_nCont ++

		Endif

		IF _nCont < 1

			Disarmtransaction()
			MsUnlockAll() 
			MsgStop("Pelo menos um dia da semana é obrigatório!","Função grvPromotor(ADOA002)")
			RestArea(aArea)
			Return Nil		

		Endif

	Endif

	//Grava dados.
	RecLock("PB3",.F.)
		Replace PB3_PRMSEG	With M->PB3_PRMSEG
		Replace PB3_PRMTER	With M->PB3_PRMTER
		Replace PB3_PRMQUA	With M->PB3_PRMQUA
		Replace PB3_PRMQUI	With M->PB3_PRMQUI
		Replace PB3_PRMSEX	With M->PB3_PRMSEX
		Replace PB3_PRMSAB	With M->PB3_PRMSAB
		Replace PB3_PRMFRQ	With M->PB3_PRMFRQ
		Replace PB3_PRMSEM	With M->PB3_PRMSEM
		Replace PB3_PRMHOR	With M->PB3_PRMHOR
		//
	MsUnlock()
	*/
	//Grava dados SA1.
	DbSelectArea("SA1")
	DbSetOrder(1)
	If ! SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1 ) )
		MsgAlert("Não foi possível atualizar os dados de Agendamento na tabela SA1, apenas na PB3.","Função grvPromotor(ADOA002)")
		lEncontrou := .F.

	EndIf

	//
	//If lEncontrou
		//U_ADVEN057P(xFilial("SA1"),PB3->PB3_CODSA1,PB3->PB3_LOJSA1,4,"P")

	//EndIf

	//	
	cMsg := REPLICATE("-", 128) + CRLF
	cMsg += "Situação Depois da Atualização" + CRLF
	cMsg += 'Codigo do Cliente : ' + PB3->PB3_CODSA1 + CRLF
	cMsg += 'Loja do Cliente : ' + PB3->PB3_LOJSA1 + CRLF
	cMsg += 'Codigo interno PB3 : ' + PB3->PB3_COD + CRLF
	cMsg += 'Loja interna PB3 : ' + PB3->PB3_LOJA + CRLF
	cMsg += 'Alterado dados do Agend. prom.' + CRLF
	cMsg += REPLICATE("-", 128) + CRLF
	cMSG += " " + CRLF

	//
	u_FSGrvLog( cMsg )

	EndTran()
	
	//Everson - 04/03/2018. Chamado 037261. SalesForce.
/*	If FindFunction("U_ADVEN076P")
		U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.,"","AGPRM",.T.)
	
	EndIf*/

	//
	MsgInfo("Dados de Agendamento alterados.","Função grvPromotor(ADOA002)")

	//Fecha a interface de edição de cadastro.
	oDlg2:End()

	//
	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function grvVendedor
	Grava agenda do vendedor.
	@type  Function
	@author Everson 
	@since 31/01/2018
	@version 01
*/	

Static Function grvVendedor(oDlg2)

	Local aArea			:= GetArea()
	Local cMsg			:= ""
	Local lEncontrou 	:= .T. 

	//Solicita confirmação do usuário.
	If ! MsgYesNo("Deseja prosseguir com a alteração dos dados de agendamento do vendedor?","Função grvVendedor(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	BeginTran()

	//Atualiza dados na tabela PB3.
	DbSelectArea('PB3')
	PB3->(DbSetOrder(1))
	PB3->(DbGoTop())
	If ! PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))

		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Não foi possível atualizar os dados de Agendamento na tabela PB3.","Função grvVendedor(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf
	
	/*	//Everson - 31/01/2018. Chamado 037261.
	If Empty(Alltrim(cValToChar(M->PB3_VEDFRQ))) .Or. Empty(Alltrim(cValToChar(M->PB3_VRDSEM)))
		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Necessário informar a frequência e semana de visitas.","Função grvVendedor(ADOA002)")
		oDlg2:End()
		RestArea(aArea)
		Return Nil
			
	EndIf*/
	
	//
	IF M->PB3_CENTRA == "N" .Or. M->PB3_CENTRA == " "

		_nCont := 0

		IF M->PB3_VEDSEG == "S"
			_nCont ++

		Endif
		IF M->PB3_VEDTER == "S"
			_nCont ++

		Endif
		IF M->PB3_VEDQUA == "S"
			_nCont ++

		Endif
		IF M->PB3_VEDQUI == "S"
			_nCont ++

		Endif
		IF M->PB3_VEDSEX == "S"
			_nCont ++

		Endif

		IF _nCont < 1

			Disarmtransaction()
			MsUnlockAll() 
			MsgStop("Pelo menos um dia da semana é obrigatório!","Função grvVendedor(ADOA002)")
			oDlg2:End()
			RestArea(aArea)
			Return Nil		

		Endif

	Endif

	//Grava dados.
	RecLock("PB3",.F.)
		Replace PB3_VEDSEG	With M->PB3_VEDSEG
		Replace PB3_VEDTER	With M->PB3_VEDTER
		Replace PB3_VEDQUA	With M->PB3_VEDQUA
		Replace PB3_VEDQUI	With M->PB3_VEDQUI
		Replace PB3_VEDSEX	With M->PB3_VEDSEX
		Replace PB3_VEDFRQ	With M->PB3_VEDFRQ
		Replace PB3_VRDSEM	With M->PB3_VRDSEM
		Replace PB3_VEDHOR	With M->PB3_VEDHOR
	MsUnlock()

	//Grava dados SA1.
	DbSelectArea("SA1")
	DbSetOrder(1)
	If ! SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1 ) )
		MsgAlert("Não foi possível atualizar os dados de Agendamento na tabela SA1, apenas na PB3.","Função grvVendedor(ADOA002)")
		lEncontrou := .F.

	EndIf

	//
	//If lEncontrou
		//U_ADVEN057P(xFilial("SA1"),PB3->PB3_CODSA1,PB3->PB3_LOJSA1,4,"V")

	//EndIf

	//	
	cMsg := REPLICATE("-", 128) + CRLF
	cMsg += "Situação Depois da Atualização" + CRLF
	cMsg += 'Codigo do Cliente : ' + PB3->PB3_CODSA1 + CRLF
	cMsg += 'Loja do Cliente : ' + PB3->PB3_LOJSA1 + CRLF
	cMsg += 'Codigo interno PB3 : ' + PB3->PB3_COD + CRLF
	cMsg += 'Loja interna PB3 : ' + PB3->PB3_LOJA + CRLF
	cMsg += 'Alterado dados do Agend. prom.' + CRLF
	cMsg += REPLICATE("-", 128) + CRLF
	cMSG += " " + CRLF

	//
	u_FSGrvLog( cMsg )

	EndTran()
	
	//Everson - 04/03/2018. Chamado 037261. SalesForce.
/*	If FindFunction("U_ADVEN076P")
		U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.,"","AGVEND",.T.)
	
	EndIf*/

	//
	MsgInfo("Dados de Agendamento alterados.","Função grvVendedor(ADOA002)")

	//Fecha a interface de edição de cadastro.
	oDlg2:End()

	//
	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function gravarLogistica
	Grava alterações feitas pela Logisticas sem a necessidade de passar por aprovação.
	@type  Function
	@author WILLIAM COSTA
	@since 03/04/2017
	@version 01
*/

Static Function gravarLogistica(oDlg2)

	Local aArea	:= GetArea()
	Local cMsg		:= ""

	//Solicita confirmação do usuário.
	If ! MsgYesNo("Deseja prosseguir com a alteração dos dados da Logistica?","Função gravarLogistica(ADOA002)")
		RestArea(aArea)
		Return Nil

	EndIf

	BeginTran()

	//Atualiza dados na tabela PB3.
	DbSelectArea('PB3')
	PB3->(DbSetOrder(1))
	PB3->(DbGoTop())
	If ! PB3->( DbSeek( xFilial('PB3') + M->PB3_COD + M->PB3_LOJA ))

		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Não foi possível atualizar os dados da Logistica na tabela PB3.","Função gravarLogistica(ADOA002)")
		oDlg2:End()
		RestArea(aArea)
		Return Nil

	EndIf

	//Grava dados.
	RecLock("PB3",.F.)    

	Replace PB3_XLONGI	With M->PB3_XLONGI
	Replace PB3_XLATIT	With M->PB3_XLATIT
	Replace PB3_HRINIM	With M->PB3_HRINIM
	Replace PB3_HRFINM	With M->PB3_HRFINM
	Replace PB3_HRINIT	With M->PB3_HRINIT
	Replace PB3_HRFINT	With M->PB3_HRFINT

	MsUnlock()

	//Grava dados SA1
	DbSelectArea("SA1")
	DbSetOrder(1)
	If ! SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1 ))

		Disarmtransaction()
		MsUnlockAll() 
		MsgStop("Não foi possível atualizar os dados da Logistica na tabela SA1.","Função gravarLogistica(ADOA002)")
		oDlg2:End()
		RestArea(aArea)
		Return Nil

	EndIf

	RecLock("SA1",.F.)

	Replace A1_XLONGIT	With M->PB3_XLONGI
	Replace A1_XLATITU	With M->PB3_XLATIT
	Replace A1_HRINIM	With M->PB3_HRINIM
	Replace A1_HRFINM	With M->PB3_HRFINM
	Replace A1_HRINIT	With M->PB3_HRINIT
	Replace A1_HRFINT	With M->PB3_HRFINT

	MsUnlock()

	//Fim alteracao por Adriana 		
	cMsg := REPLICATE("-", 128)                                + CRLF
	cMsg += "Situação Depois da Atualização"                   + CRLF
	cMsg += 'Codigo do Cliente : '           + PB3->PB3_CODSA1 + CRLF
	cMsg += 'Loja do Cliente : '             + PB3->PB3_LOJSA1 + CRLF
	cMsg += 'Codigo interno PB3 : '          + PB3->PB3_COD    + CRLF
	cMsg += 'Loja interna PB3 : '            + PB3->PB3_LOJA   + CRLF
	cMsg += 'Alterado dados da Logistica'                      + CRLF
	cMsg += REPLICATE("-", 128)                                + CRLF
	cMSG += " "                                                + CRLF

	u_FSGrvLog( cMsg )

	EndTran()
	
	//Everson - 04/03/2018. Chamado 037261. SalesForce.
	/*	If FindFunction("U_ADVEN076P")
		U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.,"","LOGI",.T.)
	
	EndIf*/

	MsgInfo("Dados da Logistica alterados.","Função gravarTelevendas(ADOA002)")

	//Fecha a interface de edição de cadastro.
	oDlg2:End()

	RestArea(aArea)

Return Nil

/*{Protheus.doc} User Function Ado5Edit
	Verifica a possibilidade de edicao do campo no cadastro de espelho de clientes. 
	@type  Function
	@author Vogas Junior
	@since 01/10/2009
	@version 01
*/

User Function Ado5Edit()

	Local lRetorno := .F.

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	// Situacoes em que o endereco de entrega podera ser alterado.

	//Eh cozinha industrial e possui o mesmo CNPJ
	If Alltrim(M->PB3_SUBSEG) $ '51&52&53' .AND. !Empty(M->PB3_REGESP) .AND. M->PB3_IMPEND =='1' .AND. ;
	M->PB3_CGC == /*M->PB3_CNPJMA*/ M->PB3_CPFENT .AND. !Empty(M->PB3_CGC) .AND. !Empty(M->PB3_CPFENT)
		lRetorno := .T.
	Endif

	// Nao eh cozinha industrial e possui CNPJ diferente da pasta dos dados cadastrais
	If M->PB3_IMPEND =='1' .AND. M->PB3_CGC <> M->PB3_CPFENT .AND.;
	!Empty(M->PB3_CGC) .AND. !Empty(M->PB3_CPFENT)
		lRetorno := .T.
	Endif

	// Nao eh cozinha, nao possui o CNPJ diferente da pasta dados cadastrais e possui uf entrega == uf dados cadastrais.
	If M->PB3_EST == M->PB3_UFENT .AND. !EMPTY(M->PB3_UFENT) .AND. M->PB3_IMPEND =='1' .AND. M->PB3_CGC <> M->PB3_CPFENT  .AND.;
	!Empty(M->PB3_CGC) .AND. !Empty(M->PB3_CPFENT)
		lRetorno := .T.
	Endif

	/*
	If M->PB3_IMPEND = '2' //! lRetorno
	M->PB3_ENDENT	:= M->PB3_END
	M->PB3_NUMENT  	:= M->PB3_NUMERO
	M->PB3_COMPEN	:= M->PB3_COMPLE
	M->PB3_BAIREN	:= M->PB3_BAIRRO
	M->PB3_CODMUE	:= M->PB3_COD_MU
	M->PB3_CIDENT	:= M->PB3_MUN
	M->PB3_CEPENT   := M->PB3_CEP
	M->PB3_UFENT	:= Criavar("PB3_UFENT")
	M->PB3_CPFENT   := Criavar("PB3_CPFENT")
	M->PB3_NOMEEN   := Criavar("PB3_NOMEEN")
	M->PB3_INSCEN   := Criavar("PB3_INSCEN")
	M->PB3_REGESP   := Criavar("PB3_REGESP")
	Endif
	*/
Return(lRetorno)

/*{Protheus.doc} Static Function GetSuperGer
	Realiza busca na tabela de vendedores procurando registros vinculados ao usuario logado que pode ser gerente/supervisor. 
	@type  Function
	@author Vogas Junior
	@since 14/10/2009
	@version 01
*/

Static Function GetSuperGer()

	Local aArea 	:= GetArea()
	Local cFilSA3	:= xFilial( 'SA3' )
	Local cVend 	:= "'"+__cUserId + "', "
	Local cGerente	:= Posicione( 'SA3', 7, xFilial('SA3') + __cUserId, 'A3_COD')
	Local cSuperv	:= Posicione( 'SA3', 7, xFilial('SA3') + __cUserId, 'A3_COD')

	DbSelectArea( 'SA3')
	SA3->( dbSetOrder( 5 ))
	If SA3->( DbSeek( cFilSA3 + cSuperv )) .And. !Empty( cSuperv )

		While ! SA3->(EOF()) .And. SA3->A3_FILIAL == cFilSA3 .And. SA3->A3_SUPER == cSuperv
			cVend += "'" +AllTrim( SA3->A3_CODUSR ) + "', "
			SA3->( dbSkip())
		Enddo
	Else
		SA3->( dbSetOrder( 4 ))
		If SA3->( DbSeek( cFilSA3 + cGerente )) .And. !Empty( cGerente )

			While ! SA3->(EOF()) .And. SA3->A3_FILIAL == cFilSA3 .And. SA3->A3_GEREN == cGerente
				cVend += "'" +AllTrim( SA3->A3_CODUSR ) + "', "
				SA3->( dbSkip())
			Enddo

		Endif
	Endif
	If ! Empty( cVend )
		cVend := Left( cVend, Len( cVend ) - 2 )
	Endif

	RestArea( aArea )
Return (cVend)

/*{Protheus.doc} User Function ADOCGC
	adaptacao da funcao padrao A030CGC utilizada para validacao do CPF/CNPJ. 
	@type  Function
	@author Vogas Junior
	@since 15/10/2009
	@version 01
*/

User Function ADOCGC(cTipPes,cCNPJ)

	Local aArea     	:= GetArea()
	Local aAreaPB3  	:= PB3->(GetArea())
	Local lRetorno  	:= .T.
	Local cCNPJBase 	:= ""
	Local cMv_ValCNPJ 	:= GetNewPar("MV_VALCNPJ","1")
	Local cMv_ValCPF 	:= GetNewPar("MV_VALCPF","1")
	Local nPos 	 		:= 20    //chamado 028674 - Sigoli 04/11/2016
	Local cQuery 		:= ""    //chamado 028674 - Sigoli 04/11/2016

	DEFAULT cCNPJ   	:= &(ReadVar())

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o tipo de pessoa                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipPes == "F" .AND. !(Len(AllTrim(cCNPJ))==11)
		Help(" ",1,"CPFINVALID")
		lRetorno := .F.
	ElseIf cTipPes == "J" .AND. !(Len(AllTrim(cCNPJ))==14)
		Help(" ",1,"CGC")
		lRetorno := .F.
	EndIf
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a duplicidade do CGC                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .AND. Pcount() > 1
	If cTipPes == "J"
	if  cCNPZ <> '00000000000000'
	dbSelectArea("PB3")
	dbSetOrder(3)
	If DbSeek(xFilial("PB3")+cCNPJ)
	Aviso('Atenção','O CNPJ informado já foi utilizado no cliente '+PB3->PB3_COD+"/"+PB3->PB3_LOJA+" - "+PB3->PB3_NOME+".",{"Ok"})//"Atenção"###"O CNPJ informado já foi utilizado no cliente "
	lRetorno := .F.
	Endif
	EndIf
	Else
	dbSelectArea("PB3")
	dbSetOrder(3)
	If DbSeek(xFilial("PB3")+cCNPJ) .And. M->PB3_COD+M->PB3_LOJA <> PB3->PB3_COD+PB3->PB3_LOJA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O parametro MV_VALCPF verifica se a validacao do CPF deve ser feita:                              ³
	//³1 = informando ao usuario que ja existe o CPF na base e verificando se deseja incluir mesmo assim ³
	//³2 = nao permitindo que o usuario insira o mesmo CPF                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMv_ValCPF == "1"
	If !_SetAutoMode()
	If Aviso('Atenção','O CNPJ informado já foi utilizado no cliente '+PB3->PB3_COD+"/"+PB3->PB3_LOJA+" - "+PB3->PB3_NOME+".",{'Aceitar','Cancelar'},2)==2//"Atenção"###"O CPF informado já foi utilizado cliente "###"Aceitar"###"Cancelar"
	lRetorno := .F.
	EndIf
	EndIf
	Else
	Aviso('Atenção','O CNPJ informado já foi utilizado no cliente '+PB3->PB3_COD+"/"+PB3->PB3_LOJA+" - "+PB3->PB3_NOME+".",{"Ok"})//"Atenção"###"O CPF informado já foi utilizado no cliente "
	lRetorno := .F.
	Endif
	EndIf
	EndIf
	EndIf
	*/   

	//tratamento para mostrar INICIO - chamado 028674 - Sigoli 04/11/2016
	IF !empty(cCNPJ)

		//Query para selecionar apenas os logs de exportaÃ§Ã£o
		cQuery += " SELECT PB3_CODSA1,PB3_LOJSA1,PB3_CGC,PB3_NOME, PB3_NREDUZ FROM "+retSqlName("PB3")+" 
		cQuery += " WHERE D_E_L_E_T_ = '' and (PB3_CGCSOC = '"+cCNPJ+"' OR PB3_CGCSO2= '"+cCNPJ+"' OR PB3_CGCSO3 = '"+cCNPJ+"')" 

		TcQuery cQuery new alias "LOGA"

		If !LOGA->(EOF()) //Ticket 423 por Adriana em 01/10/2020

			@ 000,000 To 280,530 Dialog oDlgSoc Title "Log de Solciedades"
			@ 005,010 Say "HISTORICO DE SOCIEDADE(S)"

			while !LOGA->(EOF())
				@ nPos,010 Say "CLIENTE: "+LOGA->PB3_CODSA1+"-"+LOGA->PB3_LOJSA1+" CNPJ/CPF "+Transform( LOGA->PB3_CGC, "@R 99.999.999/9999-99" )+" NOME: "+LOGA->PB3_NOME
				nPos += 10
				LOGA->(dbSkip())
			endDo

			@ 120,180 BmpButton Type 1 Action Close(oDlgSoc)  

			Activate Dialog oDlgSoc Centered

		Endif
		
		LOGA->(dbCloseArea())

	EndIF
	//Fim       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia o site da Receita Federal - Mashups                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .AND. GetNewPar("MV_MASHUPS",.F.) .AND. !_SetAutoMode()
		RFMashups(M->PB3_CGC,{"M->PB3_NOME","M->PB3_NREDUZ","M->PB3_END","M->PB3_CEP","M->PB3_BAIRRO","M->PB3_MUN","M->PB3_EST"})
	EndIf

	RestArea(aAreaPB3)
	RestArea(aArea)

Return lRetorno

/*{Protheus.doc} Static Function AdoRefer
	Apresentacao e cadastro de referencias comerciais do cliente 
	@type  Function
	@author Vogas Junior
	@since 15/10/2009
	@version 01
*/

/*
Static Function AdoRefer( cCodcli, cLojaCli )

Local aArea 		:= GetArea()
Local cNomeUsr		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
Local cNivel		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NIVEL')
Local oFont			:= NIL
Local oDlg			:= NIL
Local oPBrecer		:= NIL
Local oHistorico	:= NIL
Local cHistorico	:= AdoGetHist( cCodCli, cLojaCli, cNivel )
Local cPBrecer		:= ''
Local nOpcao		:= 0
Local cFilPBD		:= xFilial( 'PBD' )
//Local cLerPBrec	:= Posicione( 'PB2', 1, xFilial( 'PB2' ) +  __cUserId, 'PB2_LER')
//Local cIncluiPar	:= Posicione( 'PA2', 1, xFilial( 'PA2' ) +  __cUserId, 'PA2_INCLUI')


DEFINE MSDIALOG oDlg TITLE "Referencias Comerciais" FROM 10,10 To 340,640 OF oMainWnd PIXEL

@ 01, 05 Say 'Usuario                Data           Hora          Referência'
@ 02, 01 Say 'Historico'
// Historico das referencias
oHistorico := tMultiGet():New( 02, 05, {|u|If( pCount()>0, cHistorico:= u, cHistorico) }, oDlg, 250, 090,;
oFont,.T.,,,,.F.,,,,,,.T.,,,,,.T.)
oHistorico:lWordWrap := .F.
oHistorico:EnableHScroll(.T.)

//	If cIncluiPar == '1'
@ 10, 01 Say 'Referência'
// Get do Parecer.
oParecer := tMultiget():New( 10, 05, {|u|if(Pcount()>0, cParecer:=u, cParecer) }, oDlg, 250, 30, oFont,,,,,.F.)
oParecer:lWordWrap := .F.
//    Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()})

If nOpcao == 1

DbSelectArea( 'PAD' )
RecLock( 'PBD', .T. )

PBD_FILIAL	:= cFilPBD
PBD_CLIENT	:= cCodCli
PBD_LOJA		:= cLojaCli
PBD_USUARI	:= __cUserId
PBD_NOME		:= cNomeUsr
PBD_DATA		:= dDatabase
PBD_HORA		:= TIME()
MSMM(,TamSx3("PBD_REFERE")[1],,cPBrecer,1,,,"PAD","PAD_CODMEM")

PBD->( MsUnLock())

Endif

RestArea( aArea )
Return NIL
*/

/*
Static function AdoGetHist( cCodCli, cLojaCli, cNivel )

Local cFilPAD 		:= xFilial( 'PAD' )
Local cHistorico	:= ''

DbSelectArea( 'PAD' )
PAD->( DbSetOrder( 1 ) )
If PAD->( DbSeek( cFilPAD + cCodCli + cLojaCli + cNivel ))

While 	cFilPAD == PAD->PAD_Filial .And.	;
cCodCli == PAD->PAD_CLIENT .And. 	;
cLojaCli == PAD->PAD_LOJA .And. 	;
!PAD->( EOF())

cHistorico += 	AllTrim(PAD->PAD_NOME)	+ ' - ' 	+;
DtoC(PAD->PAD_DATA) 		+ ' - ' 	+;
PAD->PAD_HORA 				+ ' - ' 	+;
AllTrim(MSMM(PAD->PAD_CODMEM))
cHistorico += chr(13) + chr(10)

PAD->( DbSkip())
Enddo
Endif

Return ( cHistorico )
*/

/*{Protheus.doc} Static Function ADOVEND
	Valida a alteracao de vendedor desde que nivel de usuario logado seja maior ou igual a 2.
	@type  Function
	@author Vogas Junior
	@since 15/10/2009
	@version 01
*/

User Function AdoVend( cCodUsu )

	Local lRetorno	:= .F.
	Local aArea		:= GetArea()

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	DbSelectArea( 'PB1' )

	If PB1->( DbSeek( xFilial('PB1') + cCodUsu ))

		If Val( PB1->PB1_NIVEL ) > 1
			lRetorno	:= .T.
		Endif
	Endif

	RestArea( aArea )
Return( lRetorno )

/*{Protheus.doc} Static Function ArrayCli
	Retorna um array com os dados do cliente.
	@type  Function
	@author Alexandre Circenis
	@since 22/03/2010
	@version 01
*/

User Function ArrayCli(cCodSa1, cLoja, cAcx, nVlrDes)

	Local aCli := {}

	Local lRet     		:= .T.
	Local aCampPB3 		:= {}
	Local aCampSA1 		:= {}
	Local aVetor   		:= {}
	Local nLastCar 		:= Len(SX3->X3_CAMPO)-4
	Local nCntFor  		:= 0
	Local nPosPb3  		:= 0
	Local cAlias   		:= Alias()
	Local aDifPB3SA1	:= U_DFPB3SA1()
	Local cIgnorar 		:= "A1_SUBCOD A1_DDD A1_MSBLQL A1_ULTCOM" 	//Chamado 031170 - Adriana em 11/11/2016 (acrescentei A1_ULTCOM)
	Local cRoteiro      := "199"									//Chamado 030747- Sigoli
	//
	Local cNomeUsr 		:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cEndEntr      := "" // Chamado: 031202 Sigoli 24/03/2017             
	Local cNumEntr      := "" // Chamado: 031202 Sigoli 24/03/2017 
	Local cCodVen   	:= "" // Chamado: 048393 Adriana em 08/04/2019 

	//Everson - 30/07/2020. Chamado 059553.
	Local cSegCli		:= ""
	Local nVlrPeMin 	:= 0
	//
	
	lMsErroAuto := .F.

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SA1")
	while !Eof() .and. SX3->X3_ARQUIVO = "SA1"
		if SX3->X3_CONTEXT <> "V"
			Aadd(aCampSa1,{SX3->X3_CAMPO,SX3->X3_TITULO})
		endif
		dbSkip()
	enddo

	dbSeek("PB3")
	while !Eof() .and. SX3->X3_ARQUIVO = "PB3"
		if SX3->X3_CONTEXT <> "V"
			Aadd(aCampPB3,{SX3->X3_CAMPO,SX3->X3_TITULO})
		endif
		dbSkip()
	enddo                                  


	dbSelectArea("SA1")

	For nCntFor := 1 To Len(aCampSA1)

		if !Alltrim(aCampSa1[nCntFor, 1]) $ cIgnorar
			
			if Alltrim(aCampSa1[nCntFor, 1]) == "A1_VEND"

				//If !Empty(PB3->PB3_VEND)
				//	Aadd(aVetor , { aCampSa1[nCntFor, 1] , Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD"), NIL }  )
				//Else
				//	Aadd(aVetor , { aCampSa1[nCntFor, 1] , Space(TamSx3("A1_VEND")[1]), NIL }  )
				//Endif
				//inicio- fernando sigoli 26/07/2017  - Chamado: 036412
				If cAcx <> 'A' 

					If !Empty(PB3->PB3_VEND)
						// Chamado: 048393 Adriana em 08/04/2019
						cCodVen := Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD") 
						cCodVen := iif(cCodVen<>"      ",cCodVen,Getmv("MV_VALVEND")) // Se não existir cod. vendedor para o usuario utiliza parametro MV_VALVEND
						Aadd(aVetor , { aCampSa1[nCntFor, 1] , cCodVen, NIL }  )
						// Fim Chamado: 048393 
					Else
						Aadd(aVetor , { aCampSa1[nCntFor, 1] , Space(TamSx3("A1_VEND")[1]), NIL }  )
					Endif

				Else

					Aadd(aVetor , { aCampSa1[nCntFor, 1] , PB3->PB3_CODVEN, NIL }  )

				EndIf

				//fim- fernando sigoli 26/07/2017  - Chamado: 036412

			elseif "A1_COD" == Alltrim(aCampSa1[nCntFor, 1]) .and. !Empty(cCodSa1)
				Aadd(aVetor , { aCampSa1[nCntFor, 1] , cCodSa1, NIL }  )
			elseif "A1_LOJA" == Alltrim(aCampSa1[nCntFor, 1]) .and. !Empty(cLoja)
				Aadd(aVetor , { aCampSa1[nCntFor, 1] , cLoja, NIL }  )
			elseif "A1_CEP" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_CEP", PB3->PB3_CEP, 'AllwaysTrue()'})
			elseif "A1_END" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_END",  Alltrim(PB3->PB3_END)+", "+Alltrim(PB3->PB3_NUMERO),NIL})
			elseif "A1_ENDCOB" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_ENDCOB", Alltrim(PB3->PB3_ENDCOB)+", "+Alltrim(PB3->PB3_NUMCOB),NIL})

			elseif "A1_ENDENT" == Alltrim(aCampSa1[nCntFor, 1])

				Aadd(aVetor, {"A1_ENDENT",Alltrim(PB3->PB3_ENDENT)+", "+Alltrim(PB3->PB3_NUMENT),NIL})
				// Chamado: 031202 Sigoli 24/03/2017
				cEndEntr := FwNoAccent(Alltrim(SUBSTR(A1_ENDENT,  1  ,   At(",",alltrim(A1_ENDENT))-1)   )) 
				cNumEntr := FwNoAccent(Alltrim(SUBSTR(A1_ENDENT, At(",",alltrim(A1_ENDENT))+1  ,  LEN(alltrim(A1_ENDENT))-At(",",alltrim(A1_ENDENT))))) 

				If !empty(A1_ENDENT) .and. !Empty(A1_ULTCOM) .and. cAcx = 'A' .and. A1_ROTEIRO <> '200' .and. ;
				((Substr(cEndEntr,1,20) <> Substr(Alltrim(FwNoAccent(PB3->PB3_ENDENT)),1,20)) .or. (Alltrim(cNumEntr) <> Alltrim(PB3->PB3_NUMENT)))

					Aadd(aVetor, {"A1_ROTEIRO",cRoteiro,NIL})  
					//log
					U_Ado05Log( PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, 'Roteiro', A1_ROTEIRO , '199' ) && Sigoli 08/03/2017 chamado 031202 - 031202
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_ENDENT', 'X3_Titulo' ),Alltrim(A1_ENDENT),(alltrim(SUBSTR(PB3->PB3_ENDENT,1,30))+", "+Alltrim(PB3->PB3_NUMENT)))  && Sigoli 08/03/2017 chamado 031202 - 031202 
				EndIF 

			elseif "A1_TEL" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_DDD",Left(PB3->PB3_TEL,3),NIL})
				Aadd(aVetor, {"A1_TEL",Substr(PB3->PB3_TEL,4),NIL})

				//Éverson - 05/10/2016. Chamado 030407.
			elseIf "A1_TEL2" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_TEL2",PB3->PB3_TEL2,NIL})

			elseIf "A1_TEL3" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_TEL3",PB3->PB3_TEL3,NIL})

			elseIf "A1_TEL4" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_TEL4",PB3->PB3_TEL4,NIL})

			elseIf "A1_XTELCON" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_XTELCON",PB3->PB3_XTELCO,NIL})
				//

			elseif "A1_IMPENT" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_IMPENT",if(PB3->PB3_IMPEND= '1', 'S','N'),NIL})
			elseif "A1_IMPENT" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_IMPENT",if(PB3->PB3_IMPEND= '1', 'S','N'),NIL})	
			elseif "A1_ZZDESCB" == Alltrim(aCampSa1[nCntFor, 1])
				nVlrDes := Val(cValToChar(PB3->PB3_DESC))
				Aadd(aVetor, {"A1_ZZDESCB",PB3->PB3_DESC,NIL}) //chamado 022064 - WILL
			elseif "A1_DESC" == Alltrim(aCampSa1[nCntFor, 1])
				//Aadd(aVetor, {"A1_DESC",0,NIL}) //chamado 022064 - WILL
			elseif "A1_LC" == Alltrim(aCampSa1[nCntFor, 1])  
				Aadd(aVetor, {"A1_LC",PB3->PB3_LIMAPR,NIL}) //chamado 022064 - WILL
			elseif "A1_EMAIL" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_EMAIL",STRTRAN(PB3->PB3_EMAIL,'	',''),NIL}) //chamado  - ADRIANA

			elseif "A1_BAIRROE" == Alltrim(aCampSa1[nCntFor, 1])
				Aadd(aVetor, {"A1_BAIRROE", PB3->PB3_BAIREN, NIL})				

				If !empty(A1_BAIRROE) .and. !Empty(A1_ULTCOM) .and. A1_ROTEIRO <> '200' .and. (LTRIM(FwNoAccent(A1_BAIRROE)) <> LTRIM(FwNoAccent(PB3->PB3_BAIREN))) .and. cAcx = 'A'// Chamado: 031202 Sigoli 24/03/2017

					Aadd(aVetor, {"A1_ROTEIRO",cRoteiro,NIL})
					//log
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BAIREN', 'X3_Titulo' ),alltrim(A1_BAIRROE),alltrim(SUBSTR(PB3->PB3_BAIREN,1,20)))  && Sigoli 08/03/2017 chamado 031202 - 031202
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, 'Roteiro', A1_ROTEIRO , '199' ) && Sigoli 08/03/2017 chamado 031202 - 031202

				EndIF       

			elseif "A1_CEPE" == Alltrim(aCampSa1[nCntFor, 1])  
				Aadd(aVetor, {"A1_CEPE", PB3->PB3_CEPENT, 'AllwaysTrue()'})  	// sigoli 25/09 Chamado: 030620

				If !empty(A1_CEPE) .and. !Empty(A1_ULTCOM) .and. A1_ROTEIRO <> '200' .and. (LTRIM(A1_CEPE) <> LTRIM(PB3->PB3_CEPENT)) .and. cAcx = 'A' // Chamado: 031202 Sigoli 24/03/2017 

					Aadd(aVetor, {"A1_ROTEIRO",cRoteiro,NIL}) 
					//log
					U_Ado05Log( PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, 'Roteiro', A1_ROTEIRO , '199' ) && Sigoli 08/03/2017 chamado 031202 - 031202
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CEPENT', 'X3_Titulo' ),alltrim(A1_CEPE),alltrim(PB3->PB3_CEPENT)) && Sigoli 08/03/2017 chamado 031202 - 031202 
				EndIF

			ElseIf "A1_MUNE" == Alltrim(aCampSa1[nCntFor, 1])  //Chamado 030747- Sigoli  

				If !empty(A1_MUNE) .and. !Empty(A1_ULTCOM) .and. A1_ROTEIRO <> '200' .and. (LTRIM(FwNoAccent(A1_MUNE)) <> LTRIM(FwNoAccent(PB3->PB3_CIDENT))) .and. (Alltrim(A1_CODMUNE) <> Alltrim(PB3->PB3_CODMUE)) .and. cAcx = 'A' 

					Aadd(aVetor, {"A1_ROTEIRO",cRoteiro,NIL})
					//log
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, 'Roteiro', A1_ROTEIRO , '199' ) && Sigoli 08/03/2017 chamado 031202 - 031202
					U_Ado05Log(PB3->PB3_COD,PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CIDENT', 'X3_Titulo' ),alltrim(A1_MUNE),alltrim(PB3->PB3_CIDENT)) && Sigoli 08/03/2017 chamado 031202 - 031202 

				EndIf  
				
			ElseIf "A1_XPROMOT" == Alltrim(aCampSa1[nCntFor, 1]) // Everson - 07/03/2018. Chamado 037261. SalesForce.
				Aadd(aVetor, {"A1_XPROMOT",PB3->PB3_PROMOT,NIL})
				
			ElseIf "A1_XEMCSF" == Alltrim(aCampSa1[nCntFor, 1]) //Everson - 03/04/2018. Chamado 037261. SalesForce.
				Aadd(aVetor, {"A1_XEMCSF",PB3->PB3_EMCSF,NIL})

			// *** INICIO WILLIAM COSTA - 23/03/2020 - CHAMADO 049120 || OS 050388 || FINANCAS || ANDREA || 8319 || CREDITO
			ELSEIF "A1_XBKPRED" == Alltrim(aCampSa1[nCntFor, 1]) 

				IF ALLTRIM(PB3->PB3_CODRED) <> ''

					Aadd(aVetor, {"A1_XBKPRED",PB3->PB3_CODRED,NIL})	

				ENDIF
			// *** FINAL WILLIAM COSTA - 23/03/2020 - CHAMADO 049120 || OS 050388 || FINANCAS || ANDREA || 8319 || CREDITO

			Else 

				nPosPb3 := Ascan( aDifPB3SA1, {|x| Alltrim(x[2]) == Alltrim(aCampSa1[nCntFor, 1]) })

				if nPosPb3 > 0 // .and. !Empty(&("PB3->"+aDifPB3SA1[nPosPb3,1]))
					Aadd(aVetor , { aCampSa1[nCntFor, 1] , &("PB3->"+aDifPB3SA1[nPosPb3,1]), NIL }  )
				else
					nPosPb3 := Ascan(aCampPB3, {|x| Substr(x[1],5,nLastCar) ==  Substr(aCampSa1[nCntFor, 1],4,nLastCar) } )

					If nPosPb3 > 0 //.and. !Empty(&("PB3->"+aCampPB3[nPosPb3][1]))
						Aadd( aVetor,{ aCampSA1[nCntFor][1], &("PB3->"+aCampPB3[nPosPb3][1]), NIL } )
					EndIf

				endif

			endif
		endif
	Next nCntFor

	//Everson - 30/07/2020. Chamado 059553.
		nVlrPeMin := getPedMin(Alltrim(cValToChar(PB3->PB3_SEGTO)))
		Aadd(aVetor, {"A1_XPEDMIN",nVlrPeMin,Nil})
	//

Return (aVetor)
/*/{Protheus.doc} getPedMin
	Obtém o preço mínimo do pedido do cliente.
	@type  Static Function
	@author Everson
	@since 30/07/2020
	@version 01
	/*/
Static Function getPedMin(cSegCli)

	//Variáveis.
	Local aArea     := GetArea()
	Local nVlrPeMin := 0

	//
	nVlrPeMin := Posicione("ZBP", 1, FWxFilial("ZBP") + cSegCli, "ZBP_VALMIN" )

	//
	Conout( DToC(Date()) + " " + Time() + " ADOA002 - getPedMin - nVlrPeMin " + cValToChar(nVlrPeMin) )

	//
	RestArea(aArea)

Return nVlrPeMin

/*{Protheus.doc} Static Function AltCliB3
	Garava os dados do cliente com os dados dos PB3
	@type  Function
	@author Alexandre Circenis
	@since 23/03/2010
	@version 01
*/

User Function AltCliB3(cCodCli, cloja, aCli, cAcao, nVlrDes)

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local nOpc
	Local nVlrDSA1 := 0

	lMsErroAuto := .F.

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	dbSelectArea("SA1")
	dbSetOrder(1)

	if cAcao = "I" // Incluir
		nOpc := 3
	elseif cAcao = "A"
		nOpc := 4
		dbSeek(xFilial("SA1")+cCodCli+cLoja) // Posicionar no Cliente a Alterar
		
		nVlrDSA1 := SA1->A1_ZZDESCB
		
	endif

	//Everson, 28/07/2020. Chamado 059812 .
	DbSelectArea("CC2")
	CC2->(DbSetOrder(1))
	//

	SA3->(dbSetOrder(1))

	//
	aCli := FWVetByDic(aCli,"SA1",.F.) //Everson - 24/07/2020. Chamado 059932.

	MsExecAuto({|x,y| MATA030(x,y)},aCli,nOpc)

	If lMsErroAuto
		MostraErro()
		lRet := .F.
	Else
		
		//
		If cAcao = "A" .And. nVlrDes <> nVlrDSA1
		
			DbSelectArea("ZBE")
				RecLock("ZBE",.T.)
				Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
				Replace ZBE_DATA 	   	WITH Date()
				Replace ZBE_HORA 	   	WITH Time()
				Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
				Replace ZBE_LOG	        WITH ("Alteração de desconto financeiro (A1_ZZDESCB) de " + Alltrim(cValToChar(nVlrDSA1)) + " para " + Alltrim(cValToChar(nVlrDes)) + " ")  
				Replace ZBE_MODULO	    WITH "FINANCEIRO"
				Replace ZBE_ROTINA	    WITH "ADOA002" 
				Replace ZBE_PARAME      WITH ("CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)) )
			ZBE->( MsUnLock())
			
		EndIf
	
		//Inicio Ticket 692 por Adriana Oliveira em 03/09/2020
		If !Empty(PB3->PB3_N57608)
			Grava57608()
		Endif
		//Fim Ticket 692 por Adriana Oliveira em 03/09/2020

		lRet := .T.
		
	EndIf

	RestArea(aArea)

Return( lRet )

/*{Protheus.doc} Static Function AtuSA1
	Atualiza os dados no SA1
	@type  Function
	@author Alexandre Circenis
	@since 24/03/2010
	@version 01
*/

User Function AtuSa1(cAcao,cCodSa1, cLoja)

	Local nVlrDes := 0 //Everson - 08/01/2018.
	Local aAcli   := U_ArrayCli(cCodSa1, cLoja,cAcao,@nVlrDes)  //Chamado 030747- Sigoli [Acrecentei o parametro "cAcao" //Everson - 08/01/2018, adicionada variável nVlrDes.

	Default cAcao := "A" // Alteracao

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	// Assumimos que o PB3 ja esta atualizado e posicionado

Return U_AltCliB3(cCodSa1, cLoja, aACli, cAcao, nVlrDes)

User Function DFPB3SA1()
	//Ticket 8118  - Abel Babini         - 19/01/2021 - Alteração do campo A1_SIMPLES para A1_SIMPNAC
	Local aDif := {;
	{"PB3_CODSA1","A1_COD"},;
	{"PB3_LOJSA1","A1_LOJA"},;
	{"PB3_EST","A1_EST"},;
	{"PB3_GRPVEN","A1_GRPVEN"},;
	{"PB3_COD_MU","A1_COD_MUN"},;
	{"PB3_CODMUE","A1_CODMUNE"},;
	{"PB3_NATURE","A1_NATUREZ"},;
	{"PB3_CONTAT","A1_CONTATO"},;
	{"PB3_PFISIC","A1_PFISICA"},;
	{"PB3_MCOMPR","A1_MCOMPRA"},;
	{"PB3_CLASVE","A1_CLASVEN"},;
	{"PB3_MENSAG","A1_MENSAGE"},;
	{"PB3_SALPEL","A1_SALPEDL"},;
	{"PB3_SUFRAM","A1_SUFRAMA"},;
	{"PB3_TITPRO","A1_TITPROT"},;
	{"PB3_DTULTI","A1_DTULTIT"},;
	{"PB3_CHQDEV","A1_CHQDEVO"},;
	{"PB3_DTULCH","A1_DTULCHQ"},;
	{"PB3_MAIDUP","A1_MAIDUPL"},;
	{"PB3_CXPOST","A1_CXPOSTA"},;
	{"PB3_SALDUF","A1_SALDUPM"},;
	{"PB3_ATIVID","A1_ATIVIDA"},;
	{"PB3_CALCSU","A1_CALCSUF"},;
	{"PB3_SALPEB","A1_SALPEDB"},;
	{"PB3_GRPTRI","A1_GRPTRIB"},;
	{"PB3_TPISSR","A1_TPISSRS"},;
	{"PB3_CODPAI","A1_CODPAIS"},;
	{"PB3_TPESSO","A1_TPESSOA"},;
	{"PB3_CODMAR","A1_CODMARC"},;
	{"PB3_RECINS","A1_RECINSS"},;
	{"PB3_RECCOF","A1_RECCOFI"},;
	{"PB3_RECCSL","A1_RECCSLL"},;
	{"PB3_INSCRU","A1_INSCRUR"},;
	{"PB3_CODHIS","A1_CODHIST"},;
	{"PB3_TIPOCL","A1_TIPOCLI"},;
	{"PB3_VINCUL","A1_VINCULO"},;
	{"PB3_FRETIS","A1_FRETISS"},;
	{"PB3_ABATIM","A1_ABATIMP"},;
	{"PB3_COMPLE","A1_COMPLEM"},;
	{"PB3_FOMEZE","A1_FOMEZER"},;
	{"PB3_CONTRI","A1_CONTRIB"},;
	{"PB3_TIMEKE","A1_TIMEKEE"},;
	{"PB3_RECIRR","A1_RECIRRF"},;
	{"PB3_BLEMAI","A1_BLEMAIL"},;
	{"PB3_LOCCON","A1_LOCCONS"},;
	{"PB3_SIMPLE","A1_SIMPNAC"},;
	{"PB3_NOMSO1","A1_NOMSOC1"},;
	{"PB3_NOMSO2","A1_NOMSOC2"},;
	{"PB3_CGCSOC","A1_CPFSOC1"},;
	{"PB3_CGCSO2","A1_CPFSOC2"},;
	{"PB3_CGCSO3","A1_CPFSOC1"},;
	{"PB3_NOMSO3","A1_NOMSOC3"},;
	{"PB3_CEPCOB","A1_CEPC"},;
	{"PB3_CIDACO","A1_MUNC"},;
	{"PB3_CIDENT","A1_MUNE"},;
	{"PB3_BAIRCB","A1_BAIRROC"},;
	{"PB3_CEPENT","A1_CEPE"},;
	{"PB3_UFCOB","A1_ESTC"},;
	{"PB3_UFENT","A1_ESTE"},;
	{"PB3_NOMEEN","A1_RAZENT"},;
	{"PB3_CPFENT","A1_CGCENT"},;
	{"PB3_LIMAPR","A1_LC"},;
	{"PB3_BAIREN","A1_BAIRROE"},;
	{"PB3_INSCEN","A1_INSENT"},;
	{"PB3_SEGTO","A1_SATIV1"},;
	{"PB3_SUBSEG","A1_SATIV2"},;
	{"PB3_REGESP","A1_NRE"},;
	{"PB3_DESC","A1_ZZDESCB"},; //chamado 022064 - WILL
	{"PB3_XTELCO","A1_XTELCON"},; //chamado 030795 - por Adriana em 05/10/2016
	{"PB3_REGIST","A1_REGIMST"},; //chamado 038349 - por Fernando Sigoli 28/11/2017
	{"PB3_BLOQUE","A1_MSBLQL"},;
	{"PB3_PROMOT","A1_XPROMOT"}} //Everson - 07/03/2018. Chamado 037261. SalesForce.

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

Return aDif

/*{Protheus.doc} User Function ClieLoja
	Determina o numero da Ultima Loja do cliente
	@type  Function
	@author Alexandre Circenis
	@since 26/03/2010
	@version 01
*/

User Function ClieLoja(cCliente)

	Local cLoja := '00'
	Local cQuery := ''
	Local aArea := GetArea()

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	cQuery += "select Max(A1_LOJA) LOJA"
	cQuery += " from " + RetSQLName("SA1")
	cQuery += " where
	cQuery += " A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " and A1_COD = '"+cCliente+"'"
	cQuery += " and D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "TRB", .F., .T. )
	dbSelectArea( "TRB" )

	if !Eof()
		cLoja := TRB->LOJA
	endif

	TRB->(dbCloseArea())
	RestArea(aArea)

Return cLoja

/*{Protheus.doc} User Function NextLoja
	Retorna o proxima loja valida para um cliente
	@type  Function
	@author Alexandre Circenis
	@since 03/05/2010
	@version 01
*/

User Function NextLoja(cCliente)

	Local cRetorno
	Local cMay
	Local cLoja := Soma1(U_ClieLoja(cCliente))

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	cMay := "SA1"+xFilial("SA1")+cCliente+cLoja
	While !MayIUseCode(cMay)
		cLoja := Soma1(cLoja)
		cMay := "SA1"+xFilial("SA1")+cCliente+cLoja
	EndDo
	cRetorno := cLoja

Return cRetorno

User Function VLPB3CGC()

	Local lRet 		:= .t.
	Local aArea 	:= GetArea()
	Local aAreaPB3 	:= PB3->(GetArea())
	Local aAreaSA1 	:= SA1->(GetArea())
	Local lAchouPB3	:= .F.
	Local lAchouSA1	:= .F.
	Local lCozinha	:= Nil

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	dbSelectArea("PB3")
	dbSetOrder(3)
	if dbSeek(xFilial("PB3")+M->PB3_CGC)
		lAchouPB3	:= .T.
		If lCozinha == Nil
			lCozinha := Alltrim(Upper(PB3->PB3_SUBSEG))$"51/52/53"
		Endif
	endif

	dbSelectArea("SA1")
	dbSetOrder(3)
	if dbSeek(xFilial("SA1")+M->PB3_CGC)
		lAchouSA1 := .T.
		If lCozinha == Nil
			lCozinha := Alltrim(Upper(SA1->A1_SATIV2))$"50/51/52/53"
		Endif
	endif

	If lAchouPB3 .or. lAchouSA1
		if Aviso("Atenção", "Esse CNPJ/CPF já foi cadastrado para o cliente "+PB3->PB3_CODSA1+"-"+Alltrim(PB3->PB3_NOME)+". Confirma a Inclusão",{"&Sim","&Não"})= 2
			lRet := .F.
		endif
	Endif

	If lAchouSA1 .and. lRet .and. !lAchouPB3 .and. !lCozinha
		ApMsgAlert("O CNPJ/CPF já foi cadastrado para o cliente "+PB3->PB3_CODSA1+"-"+Alltrim(PB3->PB3_NOME)+" no Cadastro de clientes e não existe no pre-cadastro de clientes, Inclusão não permitida." , "Atenção")
		lRet := .F.
	Endif

	RestArea(aAreaSA1)
	RestArea(aAreaPB3)
	RestArea(aArea)

Return lRet

/*{Protheus.doc} User Function PIC
	Retorna a Picture para Pessoa Fisica ou Juridica, deve ser usada for do campo X3_PICTVAR
	@type  Function
	@author Alexandre Circenis
	@since 14/03/2011
	@version 01
*/

User Function Pic(cPessoa)

Return PicPesFJ(cPessoa)

/*{Protheus.doc} User Function PIX
	Retorna a Picture para Pessoa Fisica ou Juridica, deve ser usada no campo X3_PICVAR
	@type  Function
	@author Alexandre Circenis
	@since 14/03/2011
	@version 01
*/

User Function Pix(cPessoa)

Return PicPes(cPessoa)

/*{Protheus.doc} User Function vldSSeg
	Valida o subsegmento quando ja informado o CGC
	@type  Function
	@author wmanfre
	@since 23/05/2011
	@version 01
*/

User Function vldSSeg()

	Local lRet 			:= .T.
	Local aAreaSav 		:= GetArea()
	Local aAreaPB3 		:= PB3->( GetArea() )
	Local cMsg 			:= ""

	U_ADINF009P('ADOA002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Espelho de Clientes')

	If substr( M->PB3_SUBSEG,1,1) <> SUBSTR(M->PB3_SEGTO,1,1)
		ApMsgStop("O primeiro caracter do Sub-segmento |"+Alltrim( M->PB3_SUBSEG )+"| é diferente do primeiro caracter do segmento |"+Alltrim(M->PB3_SEGTO)+"|." , "Atenção")
		lRet := .F.
	Endif

	If lRet
		If !Empty(M->PB3_CGC)
			dbSelectArea("PB3")
			dbSetOrder(3)
			if dbSeek(xFilial("PB3")+M->PB3_CGC)
				lRet := .F.
				If !Empty( M->PB3_REGESP ) .And. (AllTrim( M->PB3_SUBSEG ) $ '51&52&53') .and.  !Empty(M->PB3_CODMAT)
					lRet := .T.
				Else
					cMsg := "Regime especial não preenchido |"+Alltrim(M->PB3_REGESP)+"| ou, "
					cMsg += "Sub-Segmento diferente de 51 ou 52 ou 53 |"+Alltrim( M->PB3_SUBSEG)+"| ou, "
					cMsg += "Codigo da Matriz |"+Alltrim(M->PB3_CODMAT)+"| não foi preenchido."
					ApMsgStop(cMsg , "Atenção")
				Endif
			endif
		Endif
	Endif

	RestArea(aAreaPB3)
	RestArea(aAreaSav)

Return lRet

/*{Protheus.doc} Static Function Grava5760
	Grava dados do regime especial na ZG4 - Ticket 692
	@type  Function
	@author Adriana Oliveira
	@since 03/09/2020
	@version 01
*/

Static Function Grava57608

	DbSelectArea("ZG4")
	If !Dbseek(xFilial("ZG4")+PB3->PB3_CODSA1+PB3->PB3_LOJSA1)
		Reclock("ZG4",.t.)
		ZG4->ZG4_FILIAL := xFilial("ZG4")
		ZG4->ZG4_CODIGO := PB3->PB3_CODSA1
		ZG4->ZG4_LOJA	:= PB3->PB3_LOJSA1
	Else
		Reclock("ZG4",.f.)
	Endif

	ZG4->ZG4_NUMERO	:= PB3->PB3_N57608
	ZG4->ZG4_DTINI	:= PB3->PB3_D57608

	ZG4->(MsUnlock())

Return
