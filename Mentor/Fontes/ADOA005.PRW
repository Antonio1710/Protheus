#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"                 

#define MB_ICONASTERISK 64 

STATIC lFilPB3 	  := .F.     
STATIC nValNivel  := 0 
STATIC nPrazoGer  := 0
STATIC lAltPraz   := .F.  
STATIC lBlqLote   := .f.
STATIC cMotRej    := "" 
STATIC cCodMotivo := ''
STATIC aButtons   := {}
STATIC oDlg
STATIC cModuloZBE := "LIMITE_CREDITO_LOTE"

/*/{Protheus.doc} User Function ADOA005
	Aprovacao de credito de clientes, considerando regras predeterminada
	@type  Function
	@author Vogas Junior
	@since 11/09/2009
	@version 01
	@history Chamado 020821 - Luciano         - 28/10/2014 - Sem detalhamento  
	@history Chamado 025038 - Luciano         - 25/09/2015 - Sem detalhamento
	@history Chamado TI     - Ricardo Lima    - 14/01/2018 - Ajuste de leiaute de tela
	@history Chamado 042689 - Fernando Sigoli - 12/12/2018 - Bloqueio de campos PB3_LIMAPR/PB3_COND para usuarios diferentes do credito, respeitando o nivel de acesso
	@history Chamado 046840 - Ricardo Lima    - 31/01/2019 - Inclusao de parecer em todos os envios
	@history Chamado 046840 - Ricardo Lima    - 31/01/2019 - Alteracao do nome no status
	@history Chamado 046840 - Ricardo Lima    - 04/02/2019 - Ajuste no status
	@history Chamado 046840 - Ricardo Lima    - 14/02/2019 - Retirado o status
	@history Chamado 048627 - Everson         - 22/04/2019 - Tratamento para que seja possivel alterar alguns campos do cadastro pelo financeiro, sem a necessidade de envio de aprovacao
	@history Chamado TI     - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado 049480 - Everson         - 29/05/2019 - Tratamento para que seja possivel alterar alguns campos do cadastro pelo financeiro, sem a necessidade de envio para aprovação, cadastrando no parâmetro MV_#ALPB3.
	@history Chamado 050045 - William         - 27/06/2019 - Tratamento de limite de rede para varios CNPJs diferentes e iguais
	@history Chamado 050877 - William Costa   - 20/08/2019 - Cond.Pag Prazo Cozin
	@history Chamado 051025 - Andrea          - 20/08/2019 - Adicionado regra quando for bloquear ou desbloquear um cliente gravar no campo no SA1 o codigo do motivo e descricao para o comercial
	@history Chamado 053991 - Abel Babini     - 21/10/2019 - Inscricao Estadual permitindo duplicar CNPJ com IE diferente
	@history Chamado 052448 - FWNM            - 11/10/2019 - Bloqueio/Desbloqueio em lote e coluna bloqueado? no browse  
	@history Chamado 051104 - William Costa   - 22/11/2019 - Adicionado campo de Motivo de Rejeito
	@history Chamado 054143 - Everson         - 16/12/2019 - Adicionado tratamento para quando o valor do crédito for maior que o permitido para o supervisor, enviar para o superior (Salesforce).
	@history Chamado 055317 - Everson         - 27/01/2020 - Tratamento para envio de alteração de pagamento para o Salesforce. 
	@history Chamado 056381 - William Costa   - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
	@history Chamado 055871 - Everson		  - 23/04/2020 - Adicionada a mensagem no desbloqueio e clientes que tenham encaminhamento de solicitação vinculado.
	@history Chamado 057646 - William Costa   - 28/04/2020 - Retirado mensagem de pergunta se ajustava ou não o limite das redes com CNPJ's diferentes, foi alterado para um alerta agora, depois de vários testes achamos que ali esteja o problema quando o usuario clica em não, não fazia os ajustes de limites nas tabelas PB3,SA1 e SZF
	@history Chamado 058848 - Everson         - 09/06/2020 - Tratamento para informar ao usuário que o cliente possui pedido em aberto, antes de bloqueá-lo.
	@history CHAMADO: TI    - ADRIANO SAVOINE - 22/07/2020 - Retirado a Corvemelha em CSS do Botão pois estava bloqueando o mesmo em HTML para os vendedores externos.
	@history Chamado 060134 - Everson         - 29/07/2020 - Tratamento para não bloquear cliente com pedido em aberto.
	@history Chamado 059398 - Everson 		  - 31/07/2020 - Tratamento para calcular o prazo de validade do limite de crédito na tela de aprovação de crédito a partir de parâmetro.
	@history Chamado 1687   - Everson         - 16/09/2020 - Declaração de variável para não gerar error log.
	@history Ticket 423 	- Adriana		  - 01/10/2020 - Liberar demais empresas pelo parâmetro MV_#PRECLI
	@history Ticket 8099    - ADRIANO SAVOINE - 15/01/2021 - Ajustada a Rotina para atualizar o Lim. de Credito para Toda Rede quando alterado.
	@history Ticket 8191    - ADRIANO SAVOINE - 19/01/2021 - Alteração na rede de Banco e condição de pagamento para toda Rede.
	@history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
	@history Tickets TI          - Fernando Macieira - 31/08/2021 - Consistência Redes (SZF) para checar outros valores antes de gravar para não "somar".
	@history Tickets 13526  - Everson - 14/10/2021 - Tratamento para gravar a relação A1_XTPDESC x PB3_XTPDES.
	@history Tickets TI  - Leonardo P. Monteiro - 29/10/2021 - Tratamento de error.log gerado por caracter especial informado no código do produto e razão social.
/*/
User Function ADOA005() // U_ADOA005()

	Local aArea			:= GetArea()
	Local cTit      	:= "Aprovação de Crédito"
	Local nRecno        := 0
	Local aAlter        := {}
	Local oComboSetor	:= NIl
	Local aComboSetor	:= {}
	Local cComboSetor	:= ''
	Local oComboMotivo	:= NIL
	Local aComboMotivo	:= {}
	Local cComboMotivo	:= ''
	Local oComboAnalise	:= NIL
	Local aComboAnalise	:= {'', 'Em Análise', 'Aprovado', 'Reprovado', 'Pendencia'}
	Local cComboAnalise	:= 'Pendencia'
	Local oCNPJ			:= NIL
	Local cCNPJ			:= Space(14)
	Local oSigla		:= NIL
	Local cSigla		:= Space(02)
	Local oRazao		:= NIL
	Local cRazao		:= Space(30)
	Local oEnviado		:= NIL
	Local cEnviado		:= Space(30)
	Local oCliente		:= NIL
	Local cCliente		:= Space(06)
	Local oSupervisor	:= NIL
	Local cSupervisor	:= Space(06)
	Local oVendedor		:= NIL
	Local cVendedor		:= Space(06)
	Local oData			:= NIL
	Local dData			:= Ctod('')
	Local oBotaoDocto	:= NIL
	Local oBotaoPrint	:= NIL
	Local oBotaoDadosC	:= NIL
	Local oBotaoHistor	:= NIL
	Local oBotaoEncApr	:= NIL
	Local oBotaoAprCre	:= NIL
	Local oBotaoEmail	:= NIL
	Local oBotaoPriori	:= NIL
	Local oBotaoObserv	:= NIL
	Local oBotaoInclui	:= NIL
	Local oBotaoRelat	:= NIL
	Local oBotaoPosicC	:= NIL
	Local oBotaoQtd		:= Nil
	Local oBotaoLegend	:= Nil
	Local oScrool1		:= Nil
	Local nLarg			:= 75
	Local nAlt			:= 15
	Local nX			:= 20
	Local nY			:= 90
	Local nLimApAnt     := 0
	Local nHRes			:= oMainWnd:nClientWidth			// Resolucao horizontal do monitor
	Local aButtons 		:= { { 'CADEADO'   , { || AdoBloq(	oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ],	oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' })])}, "Bloqueio" },;
							 {   'FILTRO'  , { || ( AdoFiltros( "h", "C") , fGetDados('PB3', PB3->(Recno()), 4,aAlter, cComboMotivo, cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )) }, "Filtro" },;
							 {   'LIMITES' , { || FixLimits() }, "Ajusta Limites em Lote" },; // @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
							 {   '' , { || alVldCrd() }, "Alt. Validade Cred" }} //Everson - 31/07/2020. Chamado 059398.
	Local _lUsaPreCli	:= GETMV("MV_#PRECLI",,.F.) //Ticket 423 por Adriana em 01/10/2020

	Private oDlg		:= NIL
	Private oDlg2       := NIL
	Private oGetD  		:= NIL
	Private oGet2       := NIL
	Private oBtnOK		:= NIL
	Private oBtnCancel	:= NIL
	Private oTPane1   	:= NIL
	Private oCodVen		:= NIL
	Private oNomeVen  	:= NIL
	Private nOpca   	:= 0
	Private nOpcX   	:= 0
	Private cCodVen     := __cUseriD
	Private cNomeVen  	:= Alltrim(GetAdvfVal( 'PB1','PB1_NOME',xFilial('PB1') + __cUseriD,1))+" - " +Alltrim(GetAdvFval( 'PB1','PB1_DESDEP',xFilial('PB1') + __cUseriD,1))
	Private cNvlUsRej   := GetAdvFVal("PB1", "PB1_NIVEL", xFilial("PB1") + __cUserId, 1, " ")
	Private aAux        := {}
	Private aRecs       := {}
	Private aSize       := MsAdvSize()
	Private aObjects	:= {}
	Private aInfo 		:= {}
	Private lPB5   		:= .F.
	Private oBotaoParecer := NIL
	// Ricardo Lima-31/01/2019-CH:046840
	Private cStsCli    := ''
	
	//Alert("precadatro")
	MV_PAR60 := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	If .not. _lUsaPreCli  //Ticket 423 por Adriana em 01/10/2020

		Aviso("ATENCAO","A rotina de Pré-cadastro não está ativa para esta empresa (MV_#PRECLI)",{"OK"})
		Return .F.

	EndIf

	If nHRes == 640									// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nLarg *= 0.6 //0.8
		nAlt  *= 0.6
		nX	  *= 0.5
		nY	  *= 0.5
	ElseIf ( nHRes > 700 ) .OR. ( nHRes <= 900 )	// Resolucao 800x600
		nLarg *= 0.8
		nAlt  *= 0.8
		nX	  *= 0.7
		nY    *= 0.7
	EndIf

	AAdd( aObjects, { 100,  060, .T., .F. })
	AAdd( aObjects, { 100,  010, .T., .T. })
	AAdd( aObjects, { 100,  030, .T., .F. })
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	// Cria pesquisa com Setores
	DbSelectArea('PB0')
	PB0->( DbSetOrder(2))
	PB0->( DbGoTop())
	aAdd( aComboSetor, '')
	While ! PB0->( EOF()) .And. XFilial('PB0') == PB0->PB0_FILIAL
		aAdd( aComboSetor, PB0->PB0_DESCRI)
		PB0->( DbSkip())
	Enddo

	// cria Pesquisa com Motivos
	DbSelectArea( "PB4")
	PB4->(DbSetOrder(1))
	PB4->( DbGoTop())
	aAdd( aComboMotivo, '' )
	While ! PB4->( EOF()) .And. XFilial('PB4') == PB4->PB4_FILIAL
		aAdd( aComboMotivo, PB4->PB4_CODIGO + ' - ' + PB4->PB4_DESCRI)
		PB4->( DbSkip())
	Enddo

	DbSelectArea( "PB3")
	PB3->(DbSetOrder(1))

	INCLUI := .F.
	ALTERA := .T.
	nRecno := PB3->(Recno())
	RegToMemory("PB3", ALTERA)
	nOpca  := 4

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta MsDialog com listMark                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE cTit From aSize[7],0 to aSize[6],aSize[5] PIXEL

	oDlg:lMaximized := .T.

	oTPane1:= TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,70,.T.,.F.)
	oTPane1:Align := CONTROL_ALIGN_TOP


	@ 010,006 SAY "Usuário" SIZE 200,15 OF oTPane1 PIXEL
	@ 009,030 MSGET oNomeVen VAR cNomeVen SIZE 140,10 OF oTPane1 PIXEL  When .F.

	@ 010,190 SAY "Cod. Cliente" SIZE 200,15 OF oTPane1 PIXEL
	@ 010,224 MSGET oCliente VAR cCliente Picture "999999" Valid fVldCar(cCliente) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )	 SIZE 40,10 OF oTPane1 PIXEL

	@ 010,285 /*030,204*/ SAY "CNPJ" SIZE 200,15 OF oTPane1 PIXEL
	@ 009,305 /*029,224*/ MSGET oCNPJ VAR cCNPJ	 Valid fVldCar(cCNPJ) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  ) SIZE 47,10 OF oTPane1 PIXEL

	@ 010,355 /*030,375*/ SAY "Razão Social" SIZE 200,15 OF oTPane1 PIXEL
	@ 009,390 /*029,410*/ MSGET oRazao VAR cRazao  Picture PesqPict("SA2","A2_NOME") Valid fVldCar(cRazao) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData ) SIZE 90,10 OF oTPane1 PIXEL


	//@ 030,006 SAY "Enviado" SIZE 200,15 OF oTPane1 PIXEL
	//@ 030,030 MSGET oEnviado VAR cEnviado Valid fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )SIZE 140,10 OF oTPane1 PIXEL

	// Combo de Setor.
	//@ 030, 190 /*010,270*/ Say "Setor" 	SIZE 200,15 OF oTPane1 PIXEL
	//oComboSetor := tComboBox():New( 030,224/*022, 290*/, {|u|If( pCount() > 0, cComboSetor := u, cComboSetor)},;
	//aComboSetor, 050, 0, oDlg,,{||fGetDados('PB3', PB3->(Recno()), 4,aAlter,Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )},,,,.T.,,,,,,,,,'cComboSetor')
	//oComboSetor := tComboBox():New( 042,224/*022, 290*/, {|u|If( pCount() > 0, cComboSetor := u, cComboSetor)},;

	//@ 030,285 SAY "UF" SIZE 200,15 OF oTPane1 PIXEL
	//@ 029,305 MSGET oSigla VAR cSigla Valid fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )SIZE 40,10 OF oTPane1 PIXEL


	// Combo de Motivo do Cadastro.
	//@ 030,355 /*010, 357*/ Say "Motivo"  SIZE 200,15 OF oTPane1 PIXEL
	//oComboMotivo := tComboBox():New( 030,380 /*022, 380*/, {|u|If( pCount() > 0, cComboMotivo := u, cComboMotivo)},;
	//aComboMotivo, 100, 0, oDlg,,{||fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ),cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  ) },,,,.T.,,,,,,,,,'cComboMotivo')
	//cCodMotivo := Left( cComboMotivo,2 )
	//oComboMotivo := tComboBox():New( 042,380 /*022, 380*/, {|u|If( pCount() > 0, cComboMotivo := u, cComboMotivo)},;

	@ 050,006 Say "Situação da Análise" SIZE 200,15 OF oTPane1 PIXEL
	oComboAnalise := tComboBox():New( 050, 060/*142*/, {|u|If( pCount() > 0, cComboAnalise := u, cComboAnalise)},;
	aComboAnalise, 050, 0, oDlg,,{||fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ) ,cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )},,,,.T.,,,,,,,,,'cComboAnalise')
	//oComboAnalise := tComboBox():New( 060, 060/*142*/, {|u|If( pCount() > 0, cComboAnalise := u, cComboAnalise)},;

	@ 050,123/*193*/ SAY "Vendedor" SIZE 200,15 OF oTPane1 PIXEL
	@ 049,153/*223*/ MSGET oVendedor VAR cVendedor	Valid fVldCar(cVendedor) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  ) SIZE 40,10 OF oTPane1 PIXEL

	@ 050,200/*270*/ SAY "Supervisor" SIZE 200,15 OF oTPane1 PIXEL
	@ 049,230/*300*/ MSGET oSupervisor VAR cSupervisor Valid fVldCar(cSupervisor) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )SIZE 40,10 OF oTPane1 PIXEL

	@ 050,285/*355*/ SAY "Data" SIZE 200,15 OF oTPane1 PIXEL
	@ 049,304/*374*/ MSGET oData VAR dData	 Valid fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )SIZE 40,10 OF oTPane1 PIXEL
    
	@ 050,365 SAY "UF" SIZE 200,15 OF oTPane1 PIXEL
	@ 049,385 MSGET oSigla VAR cSigla Valid fVldCar(cSigla) .and. fGetDados('PB3', PB3->(Recno()), 4,aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )SIZE 40,10 OF oTPane1 PIXEL

	oBotaoParecer 	:= tButton():New( 050, 430,'Parecer',oDlg,{||Adoa5Parec(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ]),/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData)*/ },50,15,,,,.t.,,,,,,,,,,,.f.)
	//oBotaoParecer:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	 CHAMADO: TI - ADRIANO SAVOINE - 22/07/2020

	//oBotaoQtd 		:= tButton():New( 059, 430,'Quantidades',oDlg,{||Adoa5Qtd( oGetd:aHeader, oGetd:aCols )},50,15,,,,.t.,,,,,,,,,,,.f.)

	lFilPB3 := .F.

	// Cria a GetDados
	fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData  )

	// botao que realiza a busca na tabela PB3
	//         oBtn2:=	TButton():New(51,083, STR0026, oDlg,{||aRet:=	CVORecs(cFil), If(aRet[1]>0,(oSay2:SetText(STR0022+Alltrim(Str(aRet[1]))+STR0023 + aRet[2]+STR0024+aRet[3]),oSay2:Refresh()),oDlg:End()) }																																																							 ,32,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	oBotaoDocto := tButton():New(aPosObj[3,1], aPosObj[3,2]/*255,006*/ /*26,02*/,'Documentação/Anexos',oDlg,{||;
																											    MsAguarde({ || AdoaDocto(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])},"Aguarde","Carregando rotina...") ;							    
																											}, nLarg, nAlt /*C(70),C(10)*/ /*75,15*/,,,,.T.)
																											    
																											    
																											    
	oBotaoDadosC:= tButton():New(aPosObj[3,1], aPosObj[3,2] + nY /*255,085*/,'Dados Cadastrais',oDlg,{|| MsAguarde({|| AdoaAltcad(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/ },"Aguarde","Carregando dados cadastrais")  } , nLarg, nAlt /*C(70),C(10)*//*75,15*/,,,,.t.)
	oBotaoEncApr:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 2)/*255,165*/,'Encaminhar/Aprovar',oDlg,{||( Adoa5Enc(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ], cCodVen) /*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/) }, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoHistor:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 3)/*255,245*/,'Histórico/Log',oDlg,{||Adoa5Hist(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])		/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/}, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	//oBotaoPrint := tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 4)/*255,325*/,'Imprimir',oDlg,	{||Ado5Impr2(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])		/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/}, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoAprCre:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 5)/*255,405*/,'Crédito Aprovado',oDlg,{||  MsAguarde({|| Adoa5Cred(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])	/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/},"Aguarde","Carregando dados") } , nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoLegend:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 6)/*255,405*/,'Legenda',oDlg,{||Adoa5Leg() }, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)

	If Val(cNvlUsRej) >= 2
	
		oBotaoRejeit:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 7) /*255,085*/,'Rejeito Comercial',oDlg,{||( AdoReJeita(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ],"VND")/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/)}, nLarg, nAlt /*C(70),C(10)*//*75,15*/,,,,.t.)   //chamado 035744 - 14/06/2017 - fernando sigoli
		oBotaoCondic:= tButton():New(aPosObj[3,1], aPosObj[3,2] + (nY * 8) /*255,085*/,'Alteração Condição',oDlg,{||( AdoCondic(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_CODSA1' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJSA1' }) ],oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_CGC' }) ])/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/)}, nLarg, nAlt /*C(70),C(10)*//*75,15*/,,,,.t.)   //chamado 035744 - 14/06/2017 - fernando sigoli
		
	Endif	

	oBotaoEmail := tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] 		/*275,006*/,'Email',oDlg,{||Adoa5Email(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ]) 			/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/}, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoPriori:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + ny      /*275,085*/,'Prioridade',oDlg,{||(Adoa5Prio(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])		/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/)  }, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoObserv:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 2)/*275,165*/,'Observação',oDlg,{||(Adoa5Obs(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])		/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/) }, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	oBotaoInclui:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 3) /*275,245*/,'Inclui Protheus',oDlg,{||( AdoIncA1(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ])	/*, fGetDados("PB3",nRecno,nOpca,@aAlter, Left( cComboMotivo,2 ), cComboSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cComboAnalise, cSigla, cEnviado, dData )*/)  }, nLarg, nAlt /*C(70),C(10)75,15*/,,,,.t.)
	//oBotaoRelat	:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 4)/*275,325*/,'Relatório Cadastro',oDlg,{|| Ado5Impr()}, nLarg, nAlt /*,75,15*/,,,,.t.)
	oBotaoPosicC:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 5)/*275,405*/,'Posição do Cliente',oDlg,{||AdoaPosic(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' }) ], oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' }) ]) }, nLarg, nAlt /*75,15*/,,,,.t.)
	oBotaoPosicC:= tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 6)/*275,405*/,'Quantidades',oDlg,{||Adoa5Qtd( oGetd:aHeader, oGetd:aCols )}, nLarg, nAlt,,,,.t.,,,,,,,,,,,.f.)

	If Val(cNvlUsRej) >= 2
		oBotaoCISP  := tButton():New(aPosObj[3,1] + nX ,aPosObj[3,2] + (nY * 7)/*275,405*/,'Ficha Cisp',oDlg,{||U_Adoa5CISP(oGetd:aCols[ oGetd:nAt, Ascan( oGetd:aHeader, {|x| AllTrim( x[2] ) == 'PB3_CGC' }) ])}, nLarg, nAlt,,,,.t.,,,,,,,,,,,.f.)
	Endif	

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,;
	{||nOpcX:=1,IIf( U_O040TOK(oGetd:aCols) /*.And. aColsOk( oGetD:aHeader, oGetD:aCols, cCodVen )*/,oDlg:End(),nOpcX:=0)},;
	{||nOpcX:=0,oDlg:End()},.F., aButtons )

	RestArea( aArea )

Return NIL

Static Function fVldCar(cValor)
	Local lRet := .T.

	if "'"$cValor
		MsgStop("Esse campo não permite caracter especial", "Valor Inválido")
		lRet := .F.
	endif

return lRet


/*{Protheus.doc} Static Function FGETDADOS
	Montagem da Enchoice
	@type  Function
	@author Eduardo Fernandes
	@since 10/10/2007
	@version 01
	@history 
*/

Static Function fGetDados(cAlias, nReg, nOpcX, aAlter, cMotivo, cSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cAnalise, cSigla, cEnviado, dData  )

	Local nX		:= 0
	Local aArea		:= GetArea()
	Local aCpoGDa   := {}
	Local cAliasGD	:= "PB3"
	Local cLinOk    := "U_O040LOK()"    // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk   := "U_O040TOK()"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos  := ""      			// Nome dos campos do tipo caracter que utilizarao incremento automatico.
	Local nMax      := 999              // Numero maximo de linhas permitidas. Valor padrao 99
	Local cFieldOk  := "AllwaysTrue()"  // Funcao executada na validacao do campo
	Local cDelOk    := "AllwaysTrue()" 	// Funcao executada para validar a exclusao de uma linha do aCols
	// Chamado n. 052448 || OS 053799 || FINANCAS || TATIANE || 8351 || CAD. CLIENTE - FWNM - 11/10/2019
	Local aCampos	:= {'Bloqueado', 'PB3_BLOQUE', 'PB3_CODSA1', 'PB3_LOJSA1', 'PB3_CGC', 'PB3_NOME', 'PB3_CODVEN', 'PB3_EST','PB3_DTENVI', 'SUPERVISOR', 'SETOR','PB3_MOTACE',"NIVEL", 'PB3_CREDSU', 'PB3_PRAZOS', 'PB3_ENCAMI', 'USUARIO', 'PB3_COD','PB3_LOJA'} 
//	Local aCampos	:= {'PB3_CODSA1', 'PB3_LOJSA1', 'PB3_CGC', 'PB3_NOME', 'PB3_CODVEN', 'PB3_EST','PB3_DTENVI', 'SUPERVISOR', 'SETOR','PB3_MOTACE',"NIVEL", 'PB3_CREDSU', 'PB3_PRAZOS', 'PB3_ENCAMI', 'USUARIO', 'PB3_COD','PB3_LOJA'}
	//

	Private aHeader := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
	Private aCols   := {}               // Array a ser tratado internamente na MsNewGetDados como aCols

	aAlter			:= {}

	DbSelectArea("SX3")
	DbSetOrder(2)

	//MsSeek(cAliasGD)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos visiveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:= 1 To Len(aCampos)
		If SX3->( DbSeek( aCampos[nX] ))
			//		If Alltrim(SX3->X3_CAMPO)<>'PB3_COD'
			AAdd(aCpoGDa,SX3->X3_CAMPO)
			AAdd(aAlter,SX3->X3_CAMPO)
			//		Endif
		Endif
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carga do aHeader³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aHeader, { ;
	''                 , ;    // 01 - Titulo
	'BMP01'            , ;    // 02 - Campo
	'@BMP'             , ;    // 03 - Picture
	10                 , ;    // 04 - Tamanho
	0                  , ;    // 05 - Decimal
	''                 , ;    // 06 - Valid
	''                 , ;    // 07 - Usado
	'C'                , ;    // 08 - Tipo
	''                 , ;    // 09 - F3
	'V'                , ;    // 10 - Contexto
	''                 , ;    // 11 - ComboBox
	'If( Empty( PB3->PB3_OBSAPR) .And. PB3->PB3_PRIOR != "1" , "BR_BRANCO", IF( PB3->PB3_PRIOR == "1", "BR_VERMELHO", "BR_VERDE"))'        , ;    // 12 - Relacao
	''                 , ;    // 13 - Alterar
	'V'                , ;    // 14 - Visual
	''                 } )    // 15 - Valid Usuario

	SX3->(DbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		if aCpoGDa[nX] = "PB3_VEND"
			/* Inclusao deste campo não se faz necessario pois foi criado um campo com o codigo do vendedor
			aAdd( aHeader, { ;
			'Vendedor'     , ;    // 01 - Titulo
			'          '       , ;    // 02 - Campo
			'@!'               , ;    // 03 - Picture
			6                  , ;    // 04 - Tamanho
			0                  , ;    // 05 - Decimal
			''                 , ;    // 06 - Valid
			''                 , ;    // 07 - Usado
			'C'                , ;    // 08 - Tipo
			''                 , ;    // 09 - F3
			'V'                , ;    // 10 - Contexto
			''                 , ;    // 11 - ComboBox
			'Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD")'        , ;    // 12 - Relacao
			''                 , ;    // 13 - Alterar
			'V'                , ;    // 14 - Visual
			''                 } )    // 15 - Valid Usuario
			*/
		else
			if aCpoGDa[nX] = "PB3_MOTACE"
				aAdd( aHeader, { ;
				'Supervisor'            , ;    // 01 - Titulo
				'           '      , ;    // 02 - Campo
				'@!'               , ;    // 03 - Picture
				10                 , ;    // 04 - Tamanho
				0                  , ;    // 05 - Decimal
				''                 , ;    // 06 - Valid
				''                 , ;    // 07 - Usado
				'C'                , ;    // 08 - Tipo
				''                 , ;    // 09 - F3
				'V'                , ;    // 10 - Contexto
				''                 , ;    // 11 - ComboBox
				''      		   , ;    // 12 - Relacao
				''                 , ;    // 13 - Alterar
				'V'                , ;    // 14 - Visual
				''                 } )    // 15 - Valid Usuario

				aAdd( aHeader, { ;
				'Setor'            , ;    // 01 - Titulo
				'           '      , ;    // 02 - Campo
				'@!'               , ;    // 03 - Picture
				10                 , ;    // 04 - Tamanho
				0                  , ;    // 05 - Decimal
				''                 , ;    // 06 - Valid
				''                 , ;    // 07 - Usado
				'C'                , ;    // 08 - Tipo
				''                 , ;    // 09 - F3
				'V'                , ;    // 10 - Contexto
				''                 , ;    // 11 - ComboBox
				''      		   , ;    // 12 - Relacao
				''                 , ;    // 13 - Alterar
				'V'                , ;    // 14 - Visual
				''                 } )    // 15 - Valid Usuario
			endif

			if aCpoGDa[nX] = "PB3_CREDSU"
				aAdd( aHeader, { ;
				'Nivel'            , ;    // 01 - Titulo
				'           '      , ;    // 02 - Campo
				'@!'               , ;    // 03 - Picture
				1                 , ;    // 04 - Tamanho
				0                  , ;    // 05 - Decimal
				''                 , ;    // 06 - Valid
				''                 , ;    // 07 - Usado
				'C'                , ;    // 08 - Tipo
				''                 , ;    // 09 - F3
				'V'                , ;    // 10 - Contexto
				''                 , ;    // 11 - ComboBox
				''      		   , ;    // 12 - Relacao
				''                 , ;    // 13 - Alterar
				'V'                , ;    // 14 - Visual
				''                 } )    // 15 - Valid Usuario
			endif

			if aCpoGDa[nX] = "PB3_BLOQUE"
				aAdd( aHeader, { ;
				'Bloqueado'            , ;    // 01 - Titulo
				'           '      , ;    // 02 - Campo
				'@!'               , ;    // 03 - Picture
				3                 , ;    // 04 - Tamanho
				0                  , ;    // 05 - Decimal
				''                 , ;    // 06 - Valid
				''                 , ;    // 07 - Usado
				'C'                , ;    // 08 - Tipo
				''                 , ;    // 09 - F3
				'V'                , ;    // 10 - Contexto
				''                 , ;    // 11 - ComboBox
				''      		   , ;    // 12 - Relacao
				''                 , ;    // 13 - Alterar
				'V'                , ;    // 14 - Visual
				''                 } )    // 15 - Valid Usuario
			endif

			if AllTrim(aCpoGDa[nX]) <> "PB3_BLOQUE"
				If SX3->(MsSeek(aCpoGDa[nX]))
					Aadd(aHeader,{ AllTrim(X3Titulo()),;
					SX3->X3_CAMPO	,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID	,;
					SX3->X3_USADO	,;
					SX3->X3_TIPO	,;
					SX3->X3_F3 		,;
					SX3->X3_CONTEXT,;
					SX3->X3_CBOX	,;
					SX3->X3_RELACAO})
				Endif
			endif
		endif
	Next nX    
	
	//
	oBotaoParecer:setfocus()
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carga do aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lRetLoadGDX := .F. 
	MsAguarde({|| LoadGDX(@aHeader,@aCols, cMotivo, cSetor, cCNPJ, cRazao, cCliente, cVendedor, cSupervisor, cAnalise, cSigla, cEnviado, dData ) },"Aguarde","Executando LoadGDX")
	If lRetLoadGDX 
		
  		//alert(ValType(oGetD) )               
		If ValType(oGetD)= 'O'
				           
			FreeObj(oGetD:oBrowse)
			FreeObj(oGetD)
			oGetD:= NIl
			oDlg:Refresh()
    		//alert("apagou")
		EndIF
		
	 	//alert("criou")
		oGetD := MsNewGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
		0, cLinOk, cTudoOk, cIniCpos, aAlter, /*nFreeze*/, nMax, cFieldOk, /*cSuperDel*/, cDelOk, oDlg, aHeader, aCols)
		oGetD:ForceRefresh()
		oGetD:oBrowse:bLDblClick := { || RedefCols(oGetD:OBrowse:nAt, oGetD:oBrowse:ColPos) } //{ | nRow, nCol | :RedefCols(nRow,nCol) }
		
	Endif

	RestArea( aArea )

Return


/*{Protheus.doc} Static Function REDEFCOLS
	Sem descricao
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
*/

Static Function RedefCols(nLin,nCol)

	//Validar se linha igual a 1
	//If nLin == 1
		//If nCol == MV_PAR60
			//oGetD:aCols := aSort(oGetD:aCols,,, {|x,y| x[nCol] < y[nCol] })
			//oGetD:ForceRefresh()
		//Else
			//oGetD:aCols := aSort(oGetD:aCols,,, {|x,y| x[nCol] > y[nCol] })
			//oGetD:ForceRefresh()
		//EndIf
		//MV_PAR60 := nCol //Controle.
	//EndIf

Return

/*{Protheus.doc} User Function O040LOK
	Validacao na linha da getdados
	@type  Function
	@author Eduardo Fernandes
	@since 11/10/2007
	@version 01
	@history 
*/

User Function O040LOK()

	Local lRet      := .T.

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

Return lRet

/*{Protheus.doc} User Function O040TOK
	Validacao da getdados apos a sua digitacao
	@type  Function
	@author Eduardo Fernandes
	@since 11/10/2007
	@version 01
	@history 
*/

User Function O040TOK(aCols)

	Local aArea		:= getArea()
	Local lRet		:= U_O040LOK()
	Local i			:= 0
	Local cParecObr := GetAdvFval( 'PB2', 'PB2_OBRINC', xFilial( 'PB2' ) + __cUserId, 1 )
	Local cNomUser	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUseriD, 1 )
	Local cObrig	:= ''

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	DbSelectArea( 'PB9' )
	PB9->( dbSetOrder( 2 ) )

	If cParecObr == '1'

		For i := 1 to len( aCols )

			If ! PB9->( DbSeek( xFilial( 'PB9' ) + aCols[i,2] + aCols[i,3] + cNomUser ))
				cObrig += 'Favor criar parecer para o cliente ' + aCols[i,2] + ' Loja ' + aCols[i,3]
				cObrig += chr(13) + chr(10)
			Endif

		next i

		If !Empty( cObrig )
			lRet	:= .F.
		Endif
	Endif
	RestArea( aArea )
Return lRet

/*{Protheus.doc} Static Function GETUSUARIOS
	Mediante o setor passado por parametro, identifica quais os usuarios (PA3_VEND) pertencentes ao setor e retorna array
	@type  Function
	@author Vogas Junior
	@since 15/09/2009
	@version 01
	@history 
*/

Static Function GetUsuarios( cSetor )

	Local aCodVend	:= {}
	Local aArea		:= GetArea()
	Local cFilPB1	:= xFilial('PB1')

	DbSelectArea( 'PB1' )
	PB1->( DbSetOrder(4))
	If PB1->( DbSeek( cFilPB1 + cSetor))

		While cFilPB1 == PB1->PB1_FILIAL .And. ! PB1->( EOF()) .And. AllTrim(PB1->PB1_DESDEP) == cSetor
			aAdd( aCodVend, PB1->PB1_CODIGO )
			PB1->( DbSkip())
		EndDo

	Endif

	RestArea( aArea )
Return ( aCodVend )

/*{Protheus.doc} Static Function ADOADOCTO
	Insercao de documentos do cliente
	@type  Function
	@author Vogas Junior
	@since 15/09/2009
	@version 01
	@history 
*/

Static Function AdoaDocto( cCliente, cLoja )

	Local oDlgDoc		:= Nil
	Local aArea 		:= GetArea()
	Local cAnexFile 	:= ""
	Local cNomeFile 	:= ""
	Local cDirServer 	:= ""
	Local cRootPath 	:= AllTrim( GetSrvProfString( "RootPath", "\" ) )
	Local nPos      	:= 0
	Local cPathEst  	:= "C:\TEMP"
	Local nPos1 		:= 0
	Local oExcellApp	:= Nil
	Local nAviso		:= 2
	Local lTemAnexo		:= .F.
	Local aAnexos		:= {}
	Local oListBox		:= Nil
	Local i				:= 0
	Local nOpcao		:= 0
	Local cData			:= ''
	Local cNomeAnt		:= ''
	Local cNomeArq		:= ''
	//Local cNomeUsr 		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr 		:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)

	//if Posicione("PB2",1, xFilial("PB2")+__cUserId,"PB2_ANEXAR") <> '1'
	if GetAdvFVal("PB2","PB2_ANEXAR", xFilial("PB2")+__cUserId,1) <> '1'
		Alert( 'Perfil de usuário impossibilita Anexar ou Visualizar os anexos.' )
		RestArea( aArea )
		Return NIL
	endif

	dbSelectArea("PB3")
	PB3->( dbSetOrder(1))
	PB3->( dbSeek( xFilial( 'PB3' ) + cCliente + cLoja ))

	cDirServer := Alltrim(GetPvProfString(GetEnvServer(),"Rootpath","",GetADV97())) + "\Anexos" //GetMv("AC_DIRANEX",,"chamados\")

	if Right(cDirServer,1) <> "\"
		cDirServer += "\"
	endif

	Private cNomeLog	:= "ESPCLI" + DTOS(msDate()) + AllTrim(__cUserId) + StrTran(Time(),":","_") + ".log"

	U_FSAbreLog(cNomeLog,.F.)


	cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
	if !lIsDir(cDirServer)
		makeDir(cDirServer)
	endif

	// verifica se cliente já possui diretório
	cDirServer += ( StrZero( Val( alltrim(cCliente)), 6 ) + cLoja + "\")
	cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
	if lIsDir(cDirServer)
		lTemAnexo:= .T.
	endif

	cMsg := "Diretorio dos Anexos para o cliente " + cCliente + " Loja " + cLoja + " é |" + cDirServer + "|"
	U_FSGrvLog( cMsg )
	// pega os arquivos do cliente
	aAnexos:= Directory( /*cRootPath + */cDirServer + '*.*', '')

	if Len(aAnexos) = 0
		lTemAnexo := .F.
	endif

	if Right(cPathEst,1) <> "\"
		cPathEst += "\"
	endif

	cMsg := "diretorio local do usuario  é |" + cPathEst + "|"
	U_FSGrvLog( cMsg )


	nPos := 1
	nPos1 := 1
	cdirTemp := ""

	While .t.
		nPos := at("\", substr(cPathEst,nPos1))
		if nPos > 3
			cDirTemp := substr(cPathEst,1, nPos1+nPos-1)
			if !lIsDir(cDirTemp)
				makeDir(cDirTemp)
			endif
		Endif
		nPos1 := nPos1+npos
		if nPos1 >= len(cPathEst)
			exit
		Endif
	Enddo

	cAnexFile 	:= StrZero( Val( AllTrim( cCliente )), 6 ) + cLoja  + ".XLS"
	nPos 		:= rat(".", cAnexFile)
	cExtens 	:= ""
	if Len(Dtoc(dDatabase)) = 8
		cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 7, 2 )
	else
		cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 9, 2 )
	endif
	if nPos>0
		cExtens := substr(cAnexFile, nPos+1)
	Endif

	If lTemAnexo

		// apaga arquivos que estejam na maquina do usuario
		If File( cPathEst + cAnexFile )
			Ferase( cPathEst + cAnexFile )
			cMsg := "Apagou o anexo local |" + cPathEst + cAnexFile + "|"
			U_FSGrvLog( cMsg )
		EndIf

		cFileOrig := cDirServer //+cAnexFile
		//	aAnexos:= Directory( GetPvProfString( GetEnvServer(), "RootPath", "", GetAdv97()) )
		// monta array com as informacoes que serao exibidas em tela Nome arquivo, data que foi inserido, usuario que inseriu
		for i:= 1 to len( aAnexos )
			aAnexos[ i, 2 ] := CtoD( SubStr( aAnexos[ i, 1 ], 9, 2 ) + '/' + SubStr( aAnexos[ i, 1 ], 11, 2 ) + '/' + SubStr( aAnexos[ i, 1 ], 13, 2 ) )
			//		aAnexos[ i, 3 ] := Posicione( 'PB1',1,xFilial('PB1') + Substr(aAnexos[ i, 1 ], 21, 6 ),'PB1_NOME')
			aAnexos[ i, 3 ] := GetAdvFVal( 'PB1','PB1_NOME',xFilial('PB1') + Substr(aAnexos[ i, 1 ], 21, 6 ),1)
		Next i

		aSort( aAnexos,,, { | x,y | x[ 02 ] > y[ 02 ] } )  &&Mauricio - Chamado: 037364 29/09/17

		DEFINE MSDIALOG oDlgDoc TITLE "Seleção de Anexos" FROM 10,10 To 400,/*397*/470 OF oMainWnd PIXEL

		@ 000,000 Say 'SELECIONE O ARQUIVO QUE DESEJA VISUALIZAR' SIZE 200,15 OF oDlgDoc PIXEL CENTERED
		@ 020,007 ListBox oListBox Fields HEADER "Arquivo", "Data", "Usuário";
		Size 220 , 170 Of oDlgDoc Pixel ColSizes 100,50,50
		oListBox:SetArray(aAnexos)
		oListBox:bLine := {|| {	aAnexos[oListBox:nAT,01], aAnexos[oListBox:nAT,02], aAnexos[oListBox:nAT,03]}}

		ACTIVATE MSDIALOG oDlgDoc CENTERED ON INIT EnchoiceBar(oDlgDoc,{||nOpcao:=1,;
		Processa( { || lRet := CpyS2T('\Anexos\' + left( aAnexos[ oListBox:nAt, 01 ], 8 ) + '\' + aAnexos[ oListBox:nAt, 01 ], cPathEst,.F.) }, "Transferindo Anexo","Aguarde...",.T.),;
		ShellExecute( "Open", cPathEst + aAnexos[ oListBox:nAt, 01 ], "", cExtens, 1 ), cNomeAnt := aAnexos[ oListBox:nAt, 01 ], oDlgDoc:End()},;
		{||nOpcao:=0,oDlgDoc:End()})

	Else

		If Aviso('Sem Anexo', 'Sem anexo para visualizar. Deseja Incluir Anexo?', {'Sim', 'Não'}, 2 ) == 1

			nOpcao := 1
			// pega documento em branco do servidor e copia para o c:\temp da maquina do usuario
			Processa( { || lRet := CpyS2T('\Anexos\novo.xls', cPathEst ,.F.) }, "Transferindo Anexo","Aguarde...",.T.)
			// remoneia o arquivo para ficar no padronizado (codigocliente+loja+data+ususario)
			FRename( 'C:\Temp\novo.xls', 'C:\Temp\' + Left( cAnexFile, nPos - 1 ) + cData + __cUserID + '.xls')
			cNomeAnt := Left( cAnexFile, nPos - 1 ) + cData + __cUserID + '.xls'
			// executa o arquivo copiado

			cMsg := "Criou	 o anexo local |" + cPathEst + Left( cAnexFile, nPos - 1 ) + cData + __cUserID + '.xls' + "|"
			U_FSGrvLog( cMsg )
			ShellExecute( "Open", cPathEst + Left( cAnexFile, nPos - 1 ) + cData + __cUserID + '.xls', "", cExtens, 1 )
		Endif
	Endif

	// caso nada seja copiado, exclui o c:\temp que foi criado.
	cNomeArq := cPathEst + cNomeAnt

	If nOpcao == 1

		If Aviso( 'Edição do Excel', 'O documento excel já foi editado, salvo e fechado?'+ chr(13) + chr(10)+ 'Ele já pode ser anexado ao cliente?'+ chr(13) + chr(10)+ 'Para Anexar o Documento tecle SIM'+ chr(13) + chr(10)+ 'Para cancelar a ação tecle CANCELAR', {'Sim','Cancelar'}, 2) == 1
			nAviso := 1

			// Caso nao exista
			If ! lIsDir( '\Anexos\' + Left( cAnexFile, nPos -1 ) )
				makeDir( '\Anexos\' + Left( cAnexFile, nPos -1 ) )
			Endif

			// copia o arquivo alterado para o servidor.
			If File(cPathEst + cNomeAnt )
				cNomeArq := cPathEst + Left( cAnexFile, nPos - 1 ) + cData + Alltrim( StrTran( Time(), ':', '') ) + __cUserID +  '.xls'
				FRename( cPathEst + cNomeAnt, cNomeArq )
				cMsg := "Renomeou o anexo local |" + cPathEst + cNomeAnt + "| para |" + cNomeArq + "|"
				U_FSGrvLog( cMsg )
				Processa( { || lRet := CpyT2S( cNomeArq, '\Anexos\' + Left( cAnexFile, nPos - 1 )+ '\' ,.F.) }, "Transferindo Anexo","Aguarde...",.T.)
			Endif
			U_Ado05Log( cCliente, cLoja, cNomeUsr, dDataBase, 'Inseriu novo Anexo', '', Substr( cNomeArq,9) )
		Endif

	Endif

	cMsg := "Apagou o anexo local |" + cNomeArq + "|"
	MsAguarde({|| U_FSGrvLog( cMsg ) },"Aguarde","Executando U_FSGrvLog")
	MsAguarde({|| Ferase( cNomeArq ) },"Aguarde","Executando Ferase")   
	
	If valtype(oGetD) = 'O'
		oGetD:oBrowse:SetFocus() 
		
	EndIf
	
	RestArea(aARea)
	
Return nil

/*{Protheus.doc} Static Function ADOAALTCAD
	Possibilita a alteracao dos dados cadastrais do registro posicionado na acols
	@type  Function
	@author Vogas Junior
	@since 15/09/2009
	@version 01
	@history 
*/

Static Function AdoaAltcad( cCod , cLoja )

	Local aArea			:= GetArea()
	Local oEnchADO005	:= NIl
	Local oDlg			:= Nil
	Local nOpcao 		:= 0
	Local aSize    		:= MsAdvSize()
	Local aInfo			:= {}
	Local aPosObj  		:= {}
	Local aObjects 		:= {}
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local aCampos 	    := {"NOUSER"}
	Local aCamposAlt	:= {}
	Local cMensagem		:= ''
	Local cPara			:= SuperGetMv("FS_MOVMAIL", .F., 0 )
	//Local cAltCad   	:= Posicione( 'PB2', 1, xFilial( 'PB2' ) + __cUserId, 'PB2_MANCLI' )
	Local cAltCad   	:= GetAdvFVal( 'PB2', 'PB2_MANCLI', xFilial( 'PB2' ) + __cUserId, 1 )
	Local lMandEmail	:= .F.
	Local aAreaX3   	:= {}
	Local cNvlUsr   	:= GetAdvFVal("PB1", "PB1_NIVEL", xFilial("PB1") + __cUserId, 1, " ")
	Local cNvlCrd   	:= GetMv("FS_NIVCRED")
	Local nY
	Local cExcluirCpo 	:= ''
	Local cCampoAlt

	Private aTela	[0][0]
	Private aGets	[0]

	If cAltCad <>'1'
		Alert( 'Perfil de usuário impossibilita a alteração dos dados cadastrais. Verificar cadastro de Permissões' )
		RestArea( aArea )
		Return NIL
	Endif


	if cNvlUsr < '3' // CHAMADO 024256 - ALTERADO DE 4 PARA 3 - WILLIAM COSTA
		cExcluirCpo := 'PB3_REGCOB'
	endif

	if cNvlUsr < '4' // CHAMADO:042689
		If !Empty(cExcluirCpo)
			cExcluirCpo := cExcluirCpo+'/PB3_LIMAPR/PB3_COND'
		Else 
			cExcluirCpo := "PB3_LIMAPR/PB3_COND"
		EndIf	 
	endif


	DbSelectArea("PB3")
	PB3->( DbSetOrder( 1 ))
	PB3->( DbSeek( xFilial('PB3') + cCod + cLoja ))

	DbSelectArea( "PB4")
	PB4->(DbSetOrder(1))
	If PB4->( DbSeek( xFilial( 'PB4' ) + Left(PB3->PB3_MOTACE,2)))
		cCampoAlt :=  AllTrim(MSMM(PB4->PB4_CODMEM))
	Endif

	//If Empty(PB3->PB3_DTENVI) .Or. cNvlUsr == cNvlCrd
	aAreaX3 := SX3->(GetArea())
	//Enquanto nao encaminhado para o setor de credito deve permitir alteracao total do cadastro 
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("PB3")
    
		While SX3->(!EoF()) .AnD. X3_ARQUIVO == "PB3"
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If Empty(cExcluirCpo) .Or. !(AllTrim(SX3->X3_CAMPO) $ cExcluirCpo)
				AADD(aCampos, SX3->X3_CAMPO)
			EndIf
		EndIf
		If X3_VISUAL == "A"
			aAdd(aCamposAlt, SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo
	
	
	RestArea(aAreaX3)
	//EndIf

	//Tamanho da tela
	aAdd( aObjects, {   100, 100, .t., .T. } )
	//aAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFilial("SA1")+ M->PB3_CODSA1 + M->PB3_LOJSA1))
	
		//Everson - 22/04/2019. Chamado 048627.
		RecLock("PB3",.F.)
			PB3->PB3_ULTCOM := SA1->A1_ULTCOM
			PB3->PB3_MCOMPR := SA1->A1_MCOMPRA
			PB3->PB3_PRICOM := SA1->A1_PRICOM
			PB3->PB3_NROCOM := SA1->A1_NROCOM
			PB3->PB3_NROPAG := SA1->A1_NROPAG
			PB3->PB3_METR   := SA1->A1_METR
			PB3->PB3_MSALDO := SA1->A1_MSALDO
			PB3->PB3_SALDUP := SA1->A1_SALDUP
			PB3->PB3_SALPED := SA1->A1_SALPED
			PB3->PB3_VACUM  := SA1->A1_VACUM
			PB3->PB3_ATR    := SA1->A1_ATR
			PB3->PB3_SALPEL := SA1->A1_SALPEDL
		PB3->(MsUnlock())
		
	endif

	RegToMemory('PB3', .F. )
    
	DEFINE MSDIALOG oDlg TITLE "Alteração de Dados Cadastrais" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
	oEnchADO005:= MsMGet():New( "PB3" ,, 3, , , , aCampos,{aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4]} , if(cNvlUsr<cNvlCrd, AdoGetCampos(cCampoAlt,.f.),), 3,,,'.T.', oDLG, .F., .F., .F.,, .F.) // MELHORADO
//	oEnchADO005:= MsMGet():New( "PB3" ,, 3, , , , aCampos,{aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4]} , if(cNvlUsr<cNvlCrd, AdoGetCampos(cCampoAlt,.f.),), 3,,,'.T.', oDLG, .F., .T., .F.,, .F.) // ORIGINAL
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) .And. U_ValInf1(oEnchADO005),oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)
	//HABILITAR APOS OS TESTES!!!

	If nOpcao == 1
	
		//Everson - 22/04/2019. Chamado 048627.
		Conout( DToC(Date()) + " " + Time() + " ADOA005 - AdoaAltcad - chkAlt " )
		If ! chkAlt(cCod,cLoja)
			
			// Grava LOG
			//	cNomeUsr := Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
			cNomeUsr := GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
			PB3->( DbSetOrder( 1 ))
			PB3->( DbSeek( xFilial('PB3') + cCod + cLoja ))
	
			U_CREDITOLOG(cCod, cLoja,cNomeUsr,"Dados Cadastrais") //chamado 036175 05/01/2018 WILLIAM COSTA
	
			PB3->( DbSetOrder( 1 ))
			PB3->( DbSeek( xFilial('PB3') + cCod + cLoja ))
			RecLock( 'PB3', .F.)
	
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
	
			PB3->( MsUnLock()	)
	
			&&Mauricio - Chamado 036154 - 07/07/17 - Após gravacao da alteração de dados cadastrais na PB3
			If PB3->PB3_TIPO == "F"  &&consumidor final
				RecLock( 'PB3', .F.)
				PB3->PB3_GRPTRI := "005"
				PB3->( MsUnLock()	)
			Endif
		
		EndIf
		
	Endif

	RestArea( aArea )
	
Return Nil

/*{Protheus.doc} Static Function CHKALT
	Funcao checa quais campos foram alterados
	@type  Function
	@author Everson
	@since 22/04/2019
	@version 01
	@history Chamado 048627 - Everson - 22/04/2019 - Funcao checa quais campos foram alterados
*/

Static Function chkAlt(cCod,cLoja)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local lRet		:= .T.	
	Local lAlt		:= .F.
	Local aNomCpo	:= {}
	Local cMCampo	:= ""
	Local cCampo	:= ""
	Local nAux		:= 1
	Local cParam	:= Alltrim(cValToChar(GetMv("MV_#ALPB3",,"")))
	Local aParam	:= {}
	Local aParam2	:= {}
	Local cChkCmp	:= ""
	Local nY		:= 1
	Local aVtAtu	:= {}
	
	//
	aParam := SEPARA (cParam,"|",.F.) 
	
	//
	For nAux := 1 To Len(aParam)
		aParam2 := SEPARA (aParam[nAux],":",.F.)
		Aadd(aVtAtu,{Alltrim(cValToChar(aParam2[1])),Alltrim(cValToChar(aParam2[2]))})
		cChkCmp += Alltrim(cValToChar(aParam2[1])) + "/"
		
	Next nAux
	
	//
	cChkCmp := Substr(cChkCmp,1,Len(cChkCmp)-1)
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADOA005 - chkAlt" )
	
	//Obtém os campos usados na PB3.
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("PB3"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "PB3"
		
		//
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			Aadd(aNomCpo,{SX3->X3_CAMPO,SX3->X3_TIPO})
			
		EndIf
		
		SX3->(DbSkip())
		
	End
	
	//
	DbSelectArea("PB3")
	PB3->( DbSetOrder( 1 ))
	If PB3->( DbSeek( FWxFilial("PB3") + cCod + cLoja ))
	
		For nAux := 1 to len(aNomCpo)
			
			//
			cMCampo	:= "M->"   + aNomCpo[nAux][1]
			cCampo 	:= "PB3->" + aNomCpo[nAux][1]
			
			//
			If &cMCampo <> &cCampo 
				
				//
				Conout( DToC(Date()) + " " + Time() + " ADOA005 - chkAlt - cMCampo cCampo " + cValToChar(cMCampo) + " " + cValToChar(cCampo) )
				
				//
				If ! ( Alltrim(cValToChar(aNomCpo[nAux][1])) $(cChkCmp) )
					Conout( DToC(Date()) + " " + Time() + " ADOA005 - chkAlt - campo alterado não está no parâmetro " + cValToChar(cMCampo) )
					lRet := .F.
					Exit
				
				Else
					lAlt := .T.
					
				EndIf
																				
			EndIf
			
		Next nAux
			
	EndIf
	
	//
	If lRet .And. lAlt
		
		//Everson - 29/05/2019. Chamado 049480.
		PB3->( DbSetOrder( 1 ))
		If PB3->( DbSeek( xFilial('PB3') + cCod + cLoja ))
		
			RecLock( 'PB3', .F.)
		
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
				
			Next nY
		
			PB3->( MsUnLock() )
			
			
			//Everson - 29/05/2019. Chamado 049480.
			If ! Empty( Alltrim(cValToChar(PB3->PB3_CODSA1))) .And. ! Empty( Alltrim(cValToChar(PB3->PB3_LOJSA1)) )
				
				DbSelectArea("SA1")
				SA1->( DbSetOrder( 1 ))
				SA1->(DbGoTop())
				If SA1->( DbSeek( xFilial('SA1') + Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ))
				
					RecLock( 'SA1', .F.)
				
						For nY := 1 To Len(aVtAtu)
							&(cValtoChar(aVtAtu[nY][2])) := &('M->'+ cValtoChar(aVtAtu[nY][1]) )
							
						Next nY
				
					SA1->( MsUnLock() )
					
					//
					U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.)
	
				
				EndIf			
				
			
			EndIf
		
		EndIf
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet

/*{Protheus.doc} Static Function ADOA5ENC
	Faz encaminhamento para outro vendedor, supervisor e gerente
	@type  Function
	@author Vogas Junior
	@since 16/09/2009
	@version 01
	@history 
*/

Static Function Adoa5Enc( cCodVend, cLojaVend, cVend )

	Local oDlgEnc		:= NIL
	Local oMainWnd		:= NIL
	Local oComboSetor	:= NIL
	Local oComboProvi	:= NIL
	Local oGetLImite	:= NIL
	Local oGetPrazo		:= NIL
	Local oFont
	Local aArea 		:= GetArea()
	Local nLimiteSol	:= GetAdvFVal( 'PB3', 'PB3_CREDSU', xFilial( 'PB3' ) + cCodVend + cLojaVend, 1)
	Local nPrazoSol		:= GetAdvFVal( 'PB3', 'PB3_PRAZOS', xFilial( 'PB3' ) + cCodVend + cLojaVend, 1)
	Local lParecer 		:= GetAdvFVal( 'PB3', 'PB3_PARECE', xFilial( 'PB3' ) + cCodVend + cLojaVend, 1)
	Local lObrgParec    := GetAdvFVal( 'PB2', 'PB2_OBRINC', xFilial( 'PB2' ) +  __cUserID , 1	) = '1'
	Local aSetores     	:= {}
	Local aCodSet       := {}
	Local aProvidencias	:= {}
	Local cSetor		:= ''
	Local cProvidencia	:= ''
	Local cFilPB1		:= xFilial( 'PB1' )
	Local cFilPB8		:= xFilial( 'PB8' )
	Local nOpcao		:= 0
	Local cCodEncaminha	:= ''
	Local cLojencaminha	:= ''
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara			:= SuperGetMv("FS_MOVMAIL", .F., 0 )
	Local cMensagem		:= ''
	Local cVendedor		:= ( SuperGetMv("FS_NIVVEN", .F., 0 ) == GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1))
	Local cCredito		:= SuperGetMv("FS_NIVCRED", .F., 0 )
	Local lCredito		:= .F.
	Local cNivelUs      :=  AllTrim(GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1))
	Local lPodeCred     := .F.
	LOCAL aAUX := {}
	LOCAL NX
	Local cUsuParec		:= GetAdvFVal( 'PB3', 'PB3_VENENC', xFilial( 'PB3' ) + cCodVend + cLojaVend, 1, "")
	Local cDepto		:= GetAdvFVal( 'PB1', 'PB1_DEPTO', xFilial( 'PB1' ) + __cUserId, 1)    &&Mauricio - Chamado 035857 - 14/07/17
	Local lBkOffice     :=  GetAdvFVal( 'PB2', 'PB2_BCKOFI', xFilial( 'PB2' ) + __cUserId, 1) = '1' // fernando sigoli 19/04/2018- CHAMADO: 040989


	dbSelectArea("PB3")
	PB3->( DbSetOrder(1))
	DbSeek( xFilial( 'PB3' ) + cCodVend + cLojaVend ) 

	If Empty(cUsuParec)
		cUsuParec := __cUserId	
		ApMsgAlert("O cadastro ainda não foi encaminhado ou o campo do destinatário esta vazio, assumindo o usuario corrente para avaliar se é necessário parecer!","Aviso")
	Endif

	//lObrgParec    := Posicione( 'PB2', 1, xFilial( 'PB2' ) +  cUsuParec		   , 'PB2_OBRINC'	) = '1'
	lObrgParec    := GetAdvFVal( 'PB2', 'PB2_OBRINC', xFilial( 'PB2' ) +  cUsuParec		   , 1	) = '1'

	if cUsuParec <> __cUserId   .and. lObrgParec .and. !lParecer 
		Alert( 'Aguardando o parecer do usuario |'+cUsuParec+'|.')
		RestArea( aArea)
		Return
	endif

	if lObrgParec .and. !lParecer
		Alert( 'Não se permite o Encaminhamento/Aprovação sem que tenha preenchido o parecer do usuario |'+__cUserId+'|.')
		RestArea( aArea)
		Return
	endif

	&&Mauricio - 14/07/17 - Chamado 035857 - bloqueio de novo encaminhamento enquanto em analise
	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder(1))
	If PB3->( DbSeek( xFilial( 'PB3' ) + cCodVend + cLojaVend ))
		//if PB3->PB3_SITUAC == "4" .And. !(cDepto $ '000002/000001')  &&em analise

		If PB3->PB3_SITUAC $ '2/4' .And. !(cDepto $ '000002/000001') // Fernando - Chamado: 036496 - 01/08/2017
			Alert( 'Cliente em Analise de Credito não pode ser reencaminhado!Aguarde retorno da analise em andamento.')
			RestArea( aArea)
			Return
		Endif

	Endif

	// Varredura entre os niveis
	if cNivelUs <> '1' .and. nLimiteSol <= SuperGetMv("FS_CREDI0" + cNivelUs, .F., 0 ) .and. nPrazoSol <= SuperGetMv("FS_PRZMED" + cNivelUs, .F., 0 )
		lPodeCred := .T.
	endif

	if cNivelUs >= '3' // Gerente sempre pode enviar para credito
		lPodeCred := .T.
	endif
    
	If lBkOffice // fernando sigoli 19/04/2018- CHAMADO: 040989
    
    	lPodeCred := .T.
		
	EndIf
	
	If !lPodeCred
		nEnca := Aviso('Atenção','Deseja encaminhar o cliente ?',{'Não','Superior'},1)

		if nEnca = 2 .Or. IsInCallStack('RESTEXECUTE')  //Enviar ao Superior //Everson - 16/12/2019. Chamado 054143.
			AutSndEnc( cCodVend, cLojaVend, __cUserId )
		endif
		Return
	Endif

	DbSelectArea( "PB1")
	PB1->(DbSetOrder(1))
	PB1->( DbGoTop())
	While ! PB1->( EOF()) .And. PB1->PB1_FILIAL == cFilPB1
		//	cVendedor:= ( SuperGetMv("FS_NIVVEN", .F., 0 ) == PB1->PB1_NIVEL)
		//	If (! cVendedor .Or. ( cVendedor .And. PB1->PB1_NIVEL <> cCredito )) .AND. PB1->PB1_CODIGO <>  __cUserId
		if PB1->PB1_NIVEL >= cCredito .or. PB1->PB1_CODIGO = PB3->PB3_VEND
			Aadd(aAux,{AllTrim( PB1->PB1_NOME ) + ' - ' + PB1->PB1_DESDEP, PB1->PB1_CODIGO})
		Endif
		PB1->( DbSkip())
	Enddo

	Asort(aAux,,,{ |x, y| x[1] < y[1] })

	for nX := 1 to Len(aAux)

		aAdd( aSetores, aAux[nx,1])
		aadd( aCodSet , aAux[nx,2])

	next

	DbSelectArea( "PB8")
	PB8->(DbSetOrder(1))
	PB8->( DbGoTop())
	While ! PB8->( EOF()) .And. PB8->PB8_FILIAL == cFilPB8
		aAdd( aProvidencias, PB8->PB8_DESCRI )
		PB8->( DbSkip())
	Enddo

	If ! IsInCallStack('RESTEXECUTE') //Everson - 09/10/2017. Chamado 037261.

		DEFINE MSDIALOG oDlgEnc TITLE "Encaminhamento/Aprovação" FROM 10,10 To 200,370 OF oMainWnd PIXEL

		@ 40,10 Say "Limite Solicitado" SIZE 200,15 OF oDlgEnc PIXEL
		@ 51,10 Say "Prazo Solicitado" SIZE 200,15 OF oDlgEnc PIXEL
		@ 63,10 Say "Setor/Area" SIZE 200,15 OF oDlgEnc PIXEL
		@ 75,10 Say "Providenciar" SIZE 200,15 OF oDlgEnc PIXEL

		// Get de limite.
		oGetLimite := tGet() :New( 03, 07, {|u|If( pCount()>0, nLimiteSol:= u, nLimiteSol) }, oDlgEnc, 100, 10,;
		'@E 999,999,999.99',{||},,,oFont,,,.F.,,,,,,,.T.,,,'nLimiteSol')

		// Get de Prazo.
		oGetLimite := tGet() :New( 04, 07, {|u|If( pCount()>0, nPrazoSol:= u, nPrazoSol) }, oDlgEnc, 100, 10,;
		'@e 9999.99',{||},,,oFont,,,.F.,,,,,,,.T.,,,'nPrazoSol')

		// Combo de opcoes para os setores.
		//oComboSetor := CIDA():New( 04, 07, {|u|If( pCount() > 0, cSetor := u, cSetor)},;
		//aSetores, 100,20,oDlgEnc,,{||},,,,.F.,,,,,,,,,'cSetor')
		@ 05,07 MSCOMBOBOX oComboSetor VAR cSetor ITEMS aSetores SIZE 100,20 OF oDlgEnc //PIXEL

		// Combo de Motivo da providencia.
		oComboProvi := tComboBox():New( 06, 07, {|u|If( pCount() > 0, cProvidencia := u, cProvidencia)},;
		aProvidencias, 100, 0, oDlgEnc,,{||},,,,.F.,,,,,,,,,'cProvidencia')

		ACTIVATE MSDIALOG oDlgEnc CENTERED ON INIT EnchoiceBar(oDlgEnc,{||nOpcao:=1, oDlgEnc:End()},{||nOpcao:=0,oDlgEnc:End()})

	Else //Everson - 09/10/2017. Chamado 037261.

		nOpcao 		 := 1
		cSetor 		 := aAux[1,1]
		cProvidencia := aProvidencias[1]

	EndIf

	If nOpcao == 1
		DbSelectArea( 'PB3' )
		PB3->( DbSetOrder(1))

		If PB3->( DbSeek( xFilial( 'PB3' ) + cCodVend + cLojaVend ))
			__cMyNivel := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + aCodSet[ Ascan( aSetores, cSetor)], 1)
			//		if cNivelUs = '1' .and.  SuperGetMv("FS_NIVCRED", .F., 0 )<= Posicione( 'PB1', 1, xFilial( 'PB1' ) + aCodSet[ Ascan( aSetores, cSetor)], 'PB1_NIVEL')
			if cNivelUs = '1' .and.  SuperGetMv("FS_NIVCRED", .F., 0 )<= __cMyNivel .and. !lBkOffice
				// Usuario de nivel 1 não pode enviar para credito
				Alert( 'Nivel do Usuario não permite o Encaminhamento/Aprovação')
				RestArea( aArea)
				Return NIL
			elseif cNivelUs $"23" .and. SuperGetMv("FS_NIVCRED", .F., 0 )<= __cMyNivel  .and. !lBkOffice
				if nPrazoSol > GetMV("FS_PRZMED"+cNivelUs ) .or. nLimiteSol > GetMV("FS_CREDI0"+cNivelUs )
					Alert( 'A Alcada do Usuario não permite Encaminhamento/Aprovação')
					RestArea( aArea)
					Return NIL
				endif
			endif

			If  SuperGetMv("FS_NIVCRED", .F., '4' ) <= __cMyNivel
				lCredito := .T.
			else
				//			cPara := mntcPara(cPara,AllTrim(Posicione("SA3",7,xFilial("SA3")+aCodSet[ Ascan( aSetores, cSetor)],"A3_EMAIL") ))
				cPara := mntcPara(cPara,AllTrim(GetAdvFVal("SA3","A3_EMAIL",xFilial("SA3")+aCodSet[ Ascan( aSetores, cSetor)],7) ))
			endif

			//		cNomeUsr := Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
			cNomeUsr := GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
			// Gravacao do Log

			If PB3->PB3_VENENC != aCodSet[ Ascan( aSetores, cSetor)]
				cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_VENENC', 'X3_Titulo' ), PB3->PB3_VENENC+ " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + PB3->PB3_VENENC, 1, " "), Right( aCodSet[ Ascan( aSetores, cSetor)], TamSx3('PB1_CODIGO')[1] ) + " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + Right( aCodSet[ Ascan( aSetores, cSetor)], TamSx3('PB1_CODIGO')[1] ), 1, " ") )
				cPara := mntcPara(cPara,Right( aSetores[ Ascan( aSetores, cSetor)], TamSx3('PB1_CODIGO')[1] ))
			EndIf

			If PB3->PB3_ENCAMI != cVend
				cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_ENCAMI', 'X3_Titulo' ), PB3->PB3_ENCAMI+ " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + PB3->PB3_ENCAMI, 1, " "), cVend+ " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + cVend, 1, " ") )
			Endif
			If PB3->PB3_PROVID != aProvidencias[ Ascan( aProvidencias, cProvidencia)]
				cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_PROVID', 'X3_Titulo' ), PB3->PB3_PROVID, aProvidencias[ Ascan( aProvidencias, cProvidencia)] )
			Endif

			RecLock( 'PB3', .F. )
			// Vendedor para onde o cliente foi encaminhado.
			PB3->PB3_VENENC := aCodSet[ Ascan( aSetores, cSetor)]
			// Vendedor que esta encaminhando.
			PB3->PB3_ENCAMI := cVend + " - " + GetAdvFVal("SA3", "A3_NREDUZ", xFilial("SA3") + cVend, 7, " ")
			// Providencias a serem tomadas.
			PB3->PB3_PROVID := aProvidencias[ Ascan( aProvidencias, cProvidencia)]
			// Parecer não incluido
			PB3->PB3_PARECE := .F.
			// Grava a data de envio
			PB3->PB3_DTENVI := dDataBase

			If lCredito
				//if PB3->PB3_SITUAC <> '2'
				If !PB3->PB3_SITUAC $ '2/4'
					PB3->PB3_SITUAC := '1' // Em Analise
				endif
			Endif

			PB3->( MsUnLock())

			If ! Empty( cPara )
				cMensagem := "Foi encaminhado o cadastro abaixo para as suas providencais"+chr(13) + chr(10)
				cMensagem += chr(13) + chr(10)
				cMensagem += "Codigo       : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				cMensagem += "Loja         : "+ PB3->PB3_LOJA+chr(13) + chr(10)
				cMensagem += "Cliente      : "+ PB3->PB3_NOME+chr(13) + chr(10)
				cMensagem += "CNPJ/CPF     : "+ Transform(PB3->PB3_CGC,U_Pic("PB3","PB3_CGC"))+chr(13) + chr(10)
				cMensagem += "Vendedor     : "+ GetAdvFVal("SA3","A3_COD",xFilial("SA3")+PB3->PB3_VEND,7)+;
				"-"+GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+PB3->PB3_VEND,7)	+chr(13) + chr(10)
				cMensagem += "Motivo Envio : "+ Left(PB3->PB3_MOTACE,2)+"-"+GetAdvFVal( 'PB4', 'PB4_DESCRI', xFilial( 'PB4' ) + Left(PB3->PB3_MOTACE,2), 1	)	+chr(13) + chr(10)

				CriaMail(cPara, 'Cadastro Enviado', cMensagem, /*''*/,, .F., .F.,cCodVend, cLojaVend)
			Else
				Alert( 'Não mandou o e-mail de aviso de encaminhamento pois não tinha email cadastrado')
			EndIf
		Else
			Alert( 'Não localizou o registro solicitado, verifique dados cadastrados!')
		Endif
	Endif

	RestArea( aArea)
Return NIL

/*{Protheus.doc} Static Function ADOA5HIST
	Apresenta Historico/Log com todas as acoes tomadas para o vendedor
	@type  Function
	@author Vogas Junior
	@since 16/09/2009
	@version 01
	@history 
*/

Static Function Adoa5Hist( cCodVend, cLojaVend )

	Local aArea		:= GetArea()
	Local oDlg
	Local oListBox
	Local oComboOrdem
	Local cOrdem	:=''
	Local aOrdem	:= { '','Usuario', 'Data', 'Hora', 'Campo'} //{ '','Usuario', 'Data', 'Campo'}
	Local nx 		:= 0
	Local aSize    	:= MsAdvSize()
	Local aPosObj  	:= {}
	Local aObjects 	:= {}
	Local aInfo		:= {}
	Local aCpos		:= {}
	Local nOpcao	:= 0
	Local aListBox	:= {}
	Local oTik		:= LoadBitMap(GetResources(), 'LBTIK')
	Local oNo		:= LoadBitMap(GetResources(), 'LBNO' )
	Local oMarca	:= LoadBitMap(GetResources(), 's4wb018n.png')
	Local cCampos 	:= ''
	Local cFilPB9	:= xFilial('PB9')

	Private aTela	[0][0]
	Private aGets	[0]


	//Tamanho da tela
	aObjects := {}
	aAdd( aObjects, { 100,  20, .t., .f. } )
	aAdd( aObjects, { 100,  80, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )


	If Empty(cCodVend)                              

		MsgAlert("Atenção! Nenhum cliente Selecinado ")
		Return .f.

	EndIf

	// Adiciona elementos ao Array da ListBox
	dbSelectArea( 'PB9')
	PB9->( dbSetOrder(1))
	If PB9->( DbSeek( cFilPB9 + cCodVend + cLojaVend ))
		While PB9->PB9_CODIGO == cCodVend .And. PB9->PB9_LOJA == cLojaVend .And. PB9->PB9_FILIAL == cFilPB9
			aAdd( aListBox,{ PB9->PB9_USUARI, PB9->PB9_DATA, PB9->PB9_HORA, PB9->PB9_CPOALT, PB9->PB9_CPOANT, PB9->PB9_CPODEP })
			PB9->(DbSkip())
		Enddo
	Endif

	If Empty( aListBox )

		Alert( 'Nenhuma ocorrencia de Histórico para este cliente' )

	Else

		bSort := { |x, y| Dtos(x[2])+x[3] > Dtos(y[2])+y[3] }
		aSort( aListBox , NIL , NIL , bSort )                        

		DEFINE MSDIALOG oDlg TITLE "Histórico/Log" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
		// RICARDO LIMA - 14/01/18
		@ 040,010 Say 'Ordenação' SIZE 200,15 OF oDlg PIXEL
		oComboOrdem := tComboBox():New( 040, 040, {|u|If( pCount() > 0, cOrdem := u, cOrdem)},;
		aOrdem, 040, 0, oDlg,,{||( aListBox := AdoOrdena(cOrdem, alistBox), olistBox:Refresh())},,,,.T.,,,,,,,,,'cOrdem')

		@ aPosObj[2,1],aPosObj[2,2] ListBox oListBox Fields HEADER "Usuario", "Data", "Hora", "Campo", "Antes", "Depois";
		Size aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] Of oDlg Pixel ColSizes 50,30,30,50,100,100

		oListBox:SetArray(aListBox)
		oListBox:bLine := {|| {	aListBox[oListBox:nAT,01], aListBox[oListBox:nAT,02],;
		aListBox[oListBox:nAT,03], aListBox[oListBox:nAT,04], aListBox[oListBox:nAT,05], aListBox[oListBox:nAT,06]}}

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) ,oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)

	Endif

	RestArea( aArea )

Return Nil


/*{Protheus.doc} Static Function ADOORDENA
	Funcao para ordernar o log de ocorrencias
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function AdoOrdena(cOrdem, aBusca )

	Do case
		Case cOrdem == 'Usuario'
		Asort( aBusca,,,{ |x, y| x[1] < y[1] })
		Case cOrdem == 'Data'
		Asort( aBusca,,,{ |x, y| Dtos(x[2])+x[3] < Dtos(y[2])+y[3] })
		Case cOrdem == 'Hora'
		Asort( aBusca,,,{ |x, y| x[3] < y[3] })
		Case cOrdem == 'Campo'
		Asort( aBusca,,,{ |x, y| x[4] < y[4] })
	EndCase

Return (aBusca)

/*{Protheus.doc} Static Function ADOA5CRED
	Responsavel pela aprovacao do credito do cliente
	@type  Function
	@author Vogas Junior
	@since 17/09/2009
	@version 01
	@history 
*/

Static Function Adoa5Cred( cCodcli, cLojacli )

	Local oDlgCred		:= NIL
	Local oMainWnd		:= NIL
	Local oGetLImite	:= NIL
	Local oGetPrazo		:= NIL
	Local oGetLimApr	:= NIL
	Local oGetPrzApr	:= NIL
	Local oGetMotivo	:= NIL
	Local oGetGrupCli	:= NIL
	Local oGetSegto		:= NIL
	Local oGetSubSegto	:= NIL
	Local oDescSegto	:= NIL
	Local oDescSubSegto	:= NIL
	Local oGroup		:= NIL
	Local oCliente		:= NIL
	Local _aClasse      := {'A=Classe A', 'B=Classe B', 'C=Classe C'}
	Local _aTipos 		:= {'F=Cons.Final', 'L=Produtor Rural', 'R=Revendedor', 'S=Solidario', 'X=Exportacao'}
	Local oFont
	Local aArea 		:= GetArea()
	Local cSegto        := ""    
	Local cSubSegto     := ""  
	Local cDescSegto    := ""
	Local cDescSubSeg   := ""
	Local nLimiteSol
	Local cPrazoSol
	Local nPrazoSol
	Local dPB3_VENCLC
	Local cMotivo
	Local cDescMot
	Local cGrupCli
	Local cDscGrupCli
	Local cCliente
	Local cNivel
	Local nLimApr
	Local cPrzApr
	Local aAprova		:= {}
	Local cAprova
	Local nOpcao		:= 0
	Local cCodEncaminha	:= ''
	Local cLojencaminha	:= ''
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId,  1)
	Local cPara         := ''
	Local cMensagem		:= ''
	Local cAprovaCad	:= GetAdvFVal( 'PB2', 'PB2_APROVA', xFilial( 'PB2' ) +  __cUserId, 1)
	Local aButtons 		:= { { 'QMT_EA', { || AdoEnvAp( cCodcli, cLojacli,"ENVAPROV" ),oDlgCred:End() }, "Env.Aprov. SF" },;
	                         { 'QMT_DC', { || AdoSlDoc( cCodcli, cLojacli,"SOLICDOC" ),oDlgCred:End() }, "Soli. Doc. SF" },;
							 { 'QMT_NO', { || AdoReJeita( cCodcli, cLojacli,"CRD" ),oDlgCred:End() }, "Rejeitar" },;
							 { 'QMT_ATU',{ || AdoAtuRev( cCodcli, cLojacli),oDlgCred:End() }, "Atualiza Dt Revisão" },; //Everson - 31/07/2020. Chamado 059398.
							 { 'QMT_ATU',{ || AdoAtuRed( cCodcli, cLojacli, M->PB3_DESC,M->PB3_CODRED,M->PB3_NOMEAS, M->PB3_TPREDE ),oDlgCred:End() };
							 , "Atualiza SA1_PB3" } } //chamado 035744 - 14/06/2017 - fernando sigoli
	Local cnatureza
	Local _cTipo
	Local cBanco
	Local nDesconto
	Local cRisco
	Local dVencto
	Local _cClasse
	Local nMoeda
	Local cDescRisc
	Local lAlterou		:= .F.
	Local aCampos 		:= {"NOUSER"}
	Local bCampo		:= {|nCPO| Field(nCPO) }
	Local nX
	Local lAprov 		:= .F.
	Local lRede         := .F. 
	Local nTotalRede    := 0    
	Local nTotalCnpj    := 0  
	Local nLimApAnt 	:= 0
	Local cDtVlSA1		:= Nil//Everson - 31/07/2020. Chamado 059398. 	

	Private lAltLim     := .F.


	dbSelectArea("PB3")
	dbSetOrder(1)
	dbSeek(xFilial( 'PB3' ) + cCodCli + cLojacli)

	//Everson - 31/07/2020. Chamado 059398.
	If ! Empty(Alltrim(cValToChar(PB3->PB3_CODSA1))) .And.  ! Empty(Alltrim(cValToChar(PB3->PB3_LOJSA1)))
		cDtVlSA1 := DToC(Posicione("SA1",1,FWxFilial("SA1") + Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),"A1_VENCLC" ))

	EndIf
	//

	nLimiteSol	:= PB3->PB3_CREDSU
	cPrazoSol	:= GetAdvFVal( "SE4", "E4_DESCRI", xFilial("SE4")+PB3->PB3_CONDSO, 1)//PB3->PB3_DCONSO
	nPrazoSol	:= PB3->PB3_PRAZOS
	cMotivo		:= Left(PB3->PB3_MOTACE,02)
	cDescMot	:= GetAdvFVal( 'PB4', 'PB4_DESCRI', xFilial( 'PB4' ) + cMotivo				, 1	)
	cGrupCli	:= PB3->PB3_GRPVEN
	cDscGrupCli := GetAdvFVal('ACY', "ACY_DESCRI", xFilial("ACY") + cGrupCli, 1, "")
	cCliente	:= PB3->PB3_NOME
	cNivel		:= GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserID			, 1	)
	nLimApr		:= PB3->PB3_LIMAPR
	cPrzApr		:= PB3->PB3_COND

	cSegto		:= PB3->PB3_SEGTO
	cSubSegto	:= PB3->PB3_SUBSEG

	//chamado 035829 fernando sigoli 20/06/2017 
	If !Empty(cSegto)
		cDescSegto	:= Posicione("SX5",1,xFilial("SX5")+"_S"+Alltrim(cSegto),"X5_DESCRI")     
	EndIF
	If !Empty(cSubSegto)
		cDescSubSeg := Posicione("SX5",1,xFilial("SX5")+"_T"+Alltrim(cSubSegto),"X5_DESCRI") 
	EndIf

	//cDescSegto	:= GetAdvFVal( 'SX5', 'X5_DESCRI', xFilial( 'SX5' ) +'87' + aLLTRIM(cSegto)	 , 1	)//chamado 035829 fernando sigoli 20/06/2017 
	//cDescSubSeg	:= GetAdvFVal( 'SX5', 'X5_DESCRI', xFilial( 'SX5' ) + '88'+ ALLTRIM(cSubSegto) , 1	)//chamado 035829 fernando sigoli 20/06/2017 

	cAprova       := GetAdvFVal( 'PB7', 'PB7_APROVA', xFilial( 'PB7' ) +  cNivel, 1)
	cnatureza	  := PB3->PB3_NATURE
	_cTipo		  := PB3->PB3_TIPO
	cBanco		  := PB3->PB3_BCO1
	nDesconto	  := PB3->PB3_DESC
	cRisco		  := PB3->PB3_RISCO
	dVencto		  := Date() + GetMv("MV_#DVLCRD",,180)//PB3->PB3_VENCLC //Everson - 31/07/2020. Chamado 059398.
	_cClasse	  := PB3->PB3_CLASSE
	nMoeda		  := PB3->PB3_MOEDAL
	cDescRisc	  := PB3->PB3_DSCRIS
	M->PB3_COD_MU := PB3->PB3_COD_MU //CHAMADO 041585 || FINANCAS || LIGIA || 8479 || CADASTRO PB3 WILLIAM COSTA 18/05/2018 
	M->PB3_EST    := PB3->PB3_EST //CHAMADO 041585 || FINANCAS || LIGIA || 8479 || CADASTRO PB3 WILLIAM COSTA 18/05/2018

	//cPara := mntcPara(cPara,AllTrim(GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodcli + cLojacli	, 'PB3_VEND' ), 7, " ")))
	cPara := mntcPara(cPara,AllTrim(GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + GetAdvFVal( 'PB3','PB3_VEND', xFilial( 'PB3' ) + cCodcli + cLojacli	,  1 ), 7, " ")))

	//campo default de natureza
	If Empty( cNatureza )
		cNatureza := '10101'
	Endif

	cPara := mntcPara(cPara, AllTrim(SuperGetMv("FS_MOVMAIL", .F., 0 )))

	If cAprova != '1'
		Alert( 'Perfil de Usuário não permite aprovação. Verificar cadastro de Alçadas')
		RestArea( aArea )
		Return
	Endif


	If cAprovaCad != '1'
		Alert( 'Perfil de Usuário não permite aprovação. Verificar cadastro de permissões do Usuário')
		RestArea( aArea )
		Return
	Endif

	&&Inicio - fernando sigoli 16/02/2017  Chamado 033403     
	If Empty(PB3->PB3_INSCR) .and. Alltrim(PB3->PB3_PESSOA) = 'J' .and. AllTrim( PB3->PB3_EST) != 'EX'
		Alert(ALLTRIM(cusername)+", por favor, corrigir cadastro da Inscrição Estadual" )
		RestArea( aArea )
		Return
	EndIF             

	If !Empty(PB3->PB3_INSCR) .and. Alltrim(PB3->PB3_PESSOA) = 'F' .and. Alltrim(PB3->PB3_TIPO) <> 'L' 
		Alert(ALLTRIM(cusername)+". Cadastro de Cliente Pessoa Fisica, a Inscrição Estadual deverá ficar em branco" )
		RestArea( aArea )
		Return
	EndIF     

	If Empty(PB3->PB3_INSCR) .and. Alltrim(PB3->PB3_PESSOA) = 'F' .and. PB3->PB3_CONTRI != '2'
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Fisica, O campo Contribuinte (FISCAIS) informar como: NÃO" )
		RestArea( aArea )
		Return
	EndIf

	&&Fim - fernando sigoli 16/02/2017  Chamado 033403

	&&Mauricio - 09/06/2017 - Chamado 035623 - Inicio 
	DbSelectArea("SZF")
	dbGoTop()
	DbSetOrder(1)
	IF !Empty(PB3_CODRED)
		IF	SZF->( DbSeek( xFilial("SZF")+SUBSTRING(PB3->PB3_CGC,1,8))) .AND. SZF->ZF_REDE <> PB3->PB3_CODRED		
			ALERT("Atenção Cnpj já utilizado na Rede: " + SZF->ZF_REDE + ' favor verificar.')
			RestArea( aArea )
			Return()
		ENDIF
	ENDIF
	&&Fim 035623 

	&& Inicio - chamado: 034573 - Fernando Sigoli 20/04/2017 
	If !Empty(PB3->PB3_INSCR) .and. Substr(PB3->PB3_INSCR,1,5) <> 'ISENT' .and. !Empty(PB3->PB3_CGC) .and. PB3->PB3_TIPO == 'R' .and. PB3->PB3_CONTRI == '2' .and. Alltrim(PB3->PB3_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Revendedor, O campo Contribuinte informar como: SIM" )
		RestArea( aArea )
		Return
	EndIf

	If (Empty(PB3->PB3_INSCR) .or. Substr(PB3->PB3_INSCR,1,5) = 'ISENT') .and. PB3->PB3_TIPO == 'F' .and. PB3->PB3_CONTRI <> '2' .and. Alltrim(PB3->PB3_PESSOA) = 'J' 
		Alert(ALLTRIM(cusername)+". Para Cadastro de Cliente Pessoa Juridica e classificado como Consumidor final, O campo Contribuinte informar como: NÃO" )
		RestArea( aArea )
		Return	
	EndIf
	&& Fim - chamado: 034573 - Fernando Sigoli 20/04/2017 

	dbSelectArea("SX3")
	dbSetOrder(4)
	dbSeek("PB3"+"8")
	while SX3->X3_ARQUIVO = "PB3" .and. SX3->X3_FOLDER = '8'
		If Alltrim(Upper(SX3->X3_CAMPO)) <> "PB3_LC"
			aadd(aCampos,SX3->X3_CAMPO )
		Endif
		dbSkip()
	enddo
	dbSelectArea("SX3")
	dbSetOrder(1)

	RegToMemory("PB3", .F.)

	//
	M->PB3_VENCLC := Date() + GetMv("MV_#DVLCRD",,180)//Everson - 31/07/2020. Chamado 059398.
	//

	Define Font oBold14 Name 'Arial' Size 12, 12 Bold
	DEFINE MSDIALOG oDlgCred TITLE "Aprovação de Crédito" FROM 10,10 To 550,770 OF oMainWnd PIXEL

	@ 05,10 /*01,01*/ Say "Motivo do Cadastro:" Of oDlgCred Pixel
	@ 05,137/*01,17*/ Say "Cliente:" Of oDlgCred Pixel
	@ 30,10/*04,01*/  Say "Grupo Cliente:" Of oDlgCred Pixel
	@ 30,137/*04,17*/ Say "Segmento:" Of oDlgCred Pixel
	@ 30,257/*04,32*/ Say "Sub-Segmento:" Of oDlgCred Pixel

	//oGroup1 := TGroup():New( 05,1,06,40,'',oDlgCred,,,.F.)
	//oGroup2 := TGroup():New( 07,1,40,40,'',oDlgCred,,,.F.)

	@ 04.5,10 Say "SUGERIDO/SOLICITADO" Font oBold14 //Of oDlgCred Pixel
	If cNivel < SuperGetMv("FS_NIVCRED", .F., 0 )
		@ 06.5,10 Say "APROVADO" Font oBold14 //Of oDlgCred Pixel
	Else
		@ 06.5,10 Say "APROVADO" Font oBold14	//Of oDlgCred Pixel
	Endif

	//Everson - 31/07/2020. Chamado 059398
	@ 06.5,20 Say "Próximo vencimento(SA1)" Font oBold14 COLORS CLR_RED,CLR_WHITE
	@ 06.5,35 Say cDtVlSA1 Font oBold14 COLORS CLR_RED,CLR_WHITE
	//

	@ 70,10/*10,02*/ Say "Crédito:" Of oDlgCred Pixel
	@ 70,140/*12,02*/ Say "Prazo:" Of oDlgCred Pixel


	// Get de Motivo do cadastro.
	oGetMotivo := tGet() :New( 01, 01, {|u|If( pCount()>0, cDescMot:= u, cDescMot) }, oDlgCred, 100, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cDescMot')

	// Get de Cliente.
	oCliente := tGet() :New( 01, 17, {|u|If( pCount()>0, cCliente:= u, cCliente) }, oDlgCred, 140, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cCliente')

	// Get de Grupo de clientes.
	oGetGrupCli := tGet() :New( 03, 01, {|u|If( pCount()>0, cGrupCli:= u, cGrupCli) }, oDlgCred, 020, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cGrupCli')

	oDscGrupCli := tGet() :New( 03, 04, {|u|If( pCount()>0, cDscGrupCli:= u, cDscGrupCli) }, oDlgCred, 080, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cDscGrupCli')

	// Get do Segmento do cliente
	oGetSegto := tGet() :New( 03, 17, {|u|If( pCount()>0, cSegto:= u, cSegto) }, oDlgCred, 020, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cSegto')

	oDescSegto := tGet() :New( 03, 20, {|u|If( pCount()>0, cDescSegto:= u, cDescSegto) }, oDlgCred, 070, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cDescSegto')

	// get do Sub-Segmento do cliente
	oGetSubSegto := tGet() :New( 03, 32, {|u|If( pCount()>0, cSubSegto:= u, cSubSegto) }, oDlgCred, 20, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cSubSegto')

	oDescSubSegto := tGet() :New( 03, 35, {|u|If( pCount()>0, cDescSubSeg:= u, cDescSubSeg) }, oDlgCred, 070, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cDescSubSeg')

	// Get de limite Solicitado.
	oGetLimite := tGet() :New( 05.2, 05, {|u|If( pCount()>0, nLimiteSol:= u, nLimiteSol) }, oDlgCred, 60, 10,;
	'@E 999,999,999.99',{||},,,oFont,,,.F.,,,,,,,.F.,,,'nLimiteSol')

	// Get de Prazo Solicitado.
	oGetPrazo := tGet() :New( 05.2, 20, {|u|If( pCount()>0, cPrazoSol:= u, cPrazoSol) }, oDlgCred, 60, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cPrazoSol')

	If cNivel < SuperGetMv("FS_NIVCRED", .F., 0 )

		@ 130, 227/*10,25*/ Say "Crédito" Of oDlgCred Pixel
		@ 155, 227/*12,25*/ Say "Prazo" Of oDlgCred Pixel

		// get de limite aprovado
		//oGetLimArp := tGet() :New( 10, 31, {|u|If( pCount()>0, nLimApr:= u, nLimapr) }, oDlgCred, 100, 10,;
		//'@E 999,999,999.99',{|| aAprova := VerifAprov( nLimApr, cPrzApr, cNivel, )},,,oFont,,,.F.,,,{||PB3->PB3_SITUAC = '1'},,,,/*.F.*/ !( cNivel >= SuperGetMv("FS_NIVCRED", .F., 0 )),,,'nLimApr')

		oGetLimArp := tGet() :New( 10, 31, {|u|If( pCount()>0, nLimApr:= u, nLimapr) }, oDlgCred, 100, 10,;
		'@E 999,999,999.99',{|| aAprova := VerifAprov( nLimApr, cPrzApr, cNivel,.F.,.T.)},,,oFont,,,.F.,,,{||PB3->PB3_SITUAC $ '1/4'},,,,/*.F.*/ !( cNivel >= SuperGetMv("FS_NIVCRED", .F., 0 )),,,'nLimApr') //SIGOLI 14/12/2016 &&Mauricio - Chamado 035857 - 14/07/17

		// Get de Prazo aprovado.
		//oGetPrazo := tGet() :New( 12, 31, {|u|If( pCount()>0, cPrzApr:= u, cPrzApr) }, oDlgCred, 100, 10,;
		//'@A 999',{||aAprova := VerifAprov( nLimApr, cPrzApr, cNivel )},,,oFont,    ,,.F.,,   , {||PB3->PB3_SITUAC = '1'},    ,    ,,/*.F.*/!( cNivel >= SuperGetMv("FS_NIVCRED", .F., 0 )),,,'cPrzApr')

		oGetPrazo := tGet() :New( 12, 31, {|u|If( pCount()>0, cPrzApr:= u, cPrzApr) }, oDlgCred, 100, 10,;
		'@A 999',{||aAprova := VerifAprov( nLimApr, cPrzApr, cNivel,.T.,.F.)},,,oFont,    ,,.F.,,   , {||PB3->PB3_SITUAC $ '1/4'},    ,    ,,/*.F.*/!( cNivel >= SuperGetMv("FS_NIVCRED", .F., 0 )),,,'cPrzApr')  &&Mauricio - Chamado 035857 - 14/07/17

	Else

		IF !Empty(M->PB3_CODRED) //fernando sigoli 15/02/2017 Chamado: 039834

			DbSelectArea("SZF")
			dbGoTop()
			DbSetOrder(3)   //WILLIAM COSTA AQUI ELE SOMA O LIMITE NA TELA DE CREDITO APROVADO CHAMADO 022332
			If SZF->( DbSeek( xFilial("SZF")+M->PB3_CODRED)) 
			  
				M->PB3_LIMAPR := 0

				IF UPPER(ALLTRIM(SZF->ZF_TPREDE)) <> 'A' //LIMITES DIFERENTES DE ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA

					DbSelectArea( 'SZF' )
					dbGoTop()
					DbSetOrder(3)
					SZF->( DbSeek( xFilial('SZF') + M->PB3_CODRED))
					While !Eof() .and. SZF->ZF_REDE == M->PB3_CODRED
						M->PB3_LIMAPR += SZF->ZF_LCREDE
						//M->PB3_NOMERE := SZF->ZF_NOMERED 
						SZF->(dbSkip())
					Enddo

					// *** INICIO CHAMADO WILLIAM COSTA 12/06/2019 049532 || OS 050844 || FINANCAS || ANDREA || 8319 || APROVACAO DE LIMITES
					// Retirado esse trecho pois nao atualizava a tela de Credito Aprovado com o Saldo da SZF Saldo de Redes.
					
					/*
					IF PB3->PB3_LIMAPR <> M->PB3_LIMAPR .AND. PB3->PB3_LIMAPR > 0 

						M->PB3_LIMAPR := PB3->PB3_LIMAPR
						M->PB3_NOMERE := PB3->PB3_NOMERE 

					ENDIF
					*/
					
					// *** FINAL CHAMADO WILLIAM COSTA 12/06/2019 049532 || OS 050844 || FINANCAS || ANDREA || 8319 || APROVACAO DE LIMITES

				ELSE // LIMITES COM ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA	                                      

					DbSelectArea( 'SZF' )
					dbGoTop()
					DbSetOrder( 2 )
					IF SZF->( DbSeek( xFilial('SZF') + M->PB3_NOMERE))

						M->PB3_LIMAPR := SZF->ZF_LCREDE

					ELSE

						M->PB3_LIMAPR := PB3->PB3_LIMAPR 

					ENDIF

				ENDIF

			ENDIF

			//inicio reposicionar SZF CHAMADO 022332 - WILLIAM COSTA 
			IF UPPER(ALLTRIM(SZF->ZF_TPREDE)) <> 'A'
				DbSelectArea("SZF")
				dbGoTop()
				DbSetOrder(3)   //WILLIAM COSTA AQUI ELE SOMA O LIMITE NA TELA DE CREDITO APROVADO CHAMADO 022332
				If SZF->( DbSeek( xFilial("SZF")+M->PB3_CODRED))   

				ENDIF
			ENDIF
			//final reposicionar SZF CHAMADO 022332 - WILLIAM COSTA

			DBCLOSEAREA("SZF")

		EndIF

		oEnchADO005:= MsMGet():New( "PB3" ,, 4, , , , aCampos,{095,05,255,380} , /*aCamposAlt*/, 3,,,'.T.', oDlgCred, .F., .T., .F.,, .T.)

	Endif

	ACTIVATE MSDIALOG oDlgCred CENTERED ON INIT EnchoiceBar(oDlgCred,{||(if(U_Acredtok(),(nOpcao:=1, oDlgCred:End()),nOpcao:=0 ))},{||nOpcao:=0,oDlgCred:End()},, aButtons)

	If nOpcao == 1

		DbSelectArea( 'PB3' )
		PB3->( DbSetOrder(1))

		If PB3->( DbSeek( xFilial( 'PB3' ) + cCodcli + cLojacli ))

			cMensagem += 'Alteração no cadastro do Cliente ' + AllTrim(cCodcli) + ' - ' + cCliente + ' Loja '+ AllTrim(cLojacli)
			cMensagem += chr(13) + chr(10)

			If nLimiteSol <> PB3->PB3_CREDSU
				cMensagem += 'Limite solicitado foi alterado de R$ ' + AllTrim(Str(PB3->PB3_CREDSU, 12, 2)) + ' para R$ ' + AllTrim(Str(nLimiteSol, 12, 2))
				cMensagem += chr(13) + chr(10)
				lAlterou := .T.
			Endif

			If M->PB3_LIMAPR	<> PB3->PB3_LIMAPR
				cMensagem += 'Limite Aprovado foi alterado de R$ ' + AllTrim(Str(PB3->PB3_LIMAPR, 12, 2)) + ' para R$ ' + AllTrim(Str(nLimApr, 12, 2))
				cMensagem += chr(13) + chr(10)
				lAlterou := .T.
				lAltLim  := .T. //chamado 028674 - Sigoli 07/10/2016

			Endif

			If nPrazoSol <> PB3->PB3_PRAZOS
				cMensagem += 'Prazo Solicitado foi alterado de ' + AllTrim(PB3->PB3_PRAZOS) + ' para ' + AllTrim(cPrazoSol)
				cMensagem += chr(13) + chr(10)
				lAlterou := .T.
				U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_LIMAPR', 'X3_Titulo' ), PB3->PB3_LIMAPR, nLimApr )
			Endif

			If M->PB3_COND <> PB3->PB3_COND
				cMensagem += 'Prazo Aprovado foi alterado de ' + AllTrim(PB3->PB3_COND) + ' para ' + AllTrim(cPrzApr)
				cMensagem += chr(13) + chr(10)
				lAlterou := .T. 
				lAltPraz := .T. //chamado 028674 - Sigoli 07/10/2016
				//U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_COND', 'X3_Titulo' ), PB3->PB3_COND, cPrzApr )
				//U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_COND', 'X3_Titulo' ), PB3->PB3_COND, M->PB3_COND) //chamado 038954 William Costa 09/01/2018

			Endif 

			&& Chamado 032248 Sigoli 11/01/2016 
			If M->PB3_CODRED <> PB3->PB3_CODRED
				lAltLim  := .T. 
			Endif 

			cMensagem += 'Alterado por ' + cNomeUsr + ' em '+ DtoC( dDatabase )
			cMensagem += chr(13) + chr(10)

			//verificar se o cliente pertence a uma rede de compra com raiz mesma raiz cpnj
			//inicio

			If !Empty(M->PB3_CODRED) //esse tratamento é somente se existir rede

				dbSelectArea("PB3")
				nOrden = IndexOrd()  //GUARDO A ORDEM DO INDICE             
				nRecno := Recno()
				dbSetOrder(13)

				If PB3->( DbSeek( xFilial('PB3')+ M->PB3_CODRED))
					lRede := .F.
					While !PB3->( EOF()) .AND. alltrim(PB3->PB3_CODRED) = alltrim(M->PB3_CODRED)
						IF PB3->PB3_BLOQUE = '2'
							lRede := .T.       //EXISTE LOJA ATIVA NESSA REDE
						EndIF
						PB3->( DbSkip() )
					Enddo
				EndIF		

				DbSelectArea("PB3")
				DbSetOrder(nOrden)  //RETORNO A ORDEM 
				DbGoto(nRecno)

			EndIf
			//fim

			//Regra de validação de alçada de aprovação de usuario 
			If (lAprov := VerifAprov( M->PB3_LIMAPR, M->PB3_COND, cNivel)) 

				If !Empty(M->PB3_CODRED) 
					&& antecipado        && avista
					If M->PB3_BLOQUE = '2' .or. lRede == .T. .or. M->PB3_COND = '0' .or. M->PB3_COND = '00' .or. M->PB3_LIMAPR <= nValNivel

						//sigoli 01/06/2017 Chamado:035009
						If GetAdvFVal("SE4", "E4_DMEDI",xFilial("SE4")+M->PB3_COND, 1) > nPrazoGer .and. lAltPraz == .T. .and. cNivel <= '5' 
							MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
							lAprov := .F.	
							Return       
						EndIf		 	

						nLimApAnt:= PesqLimiRed() && rotina para buscar limite da rede

						If nLimApAnt <> M->PB3_LIMAPR .and. cNivel <= '5'

							If !MsgBox(ALLTRIM(cusername)+", limite da rede R$: "+cvaltochar(Alltrim(Transform(nLimApAnt,"@E 999,999,999.99")))+" está diferente do limite solicitado R$: "+cvaltochar(Alltrim(Transform(M->PB3_LIMAPR,"@E 999,999,999.99")))+". Deseja aprovar?"+chr(13)+chr(10)+chr(13)+chr(10),"Limite REDE","YESNO")	
								MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
								lAprov := .F.	
								Return       
							Else
								MSGINFO("Crédito aprovado")
								lAprov := .T.
								U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
							EndIf

						Else
							MSGINFO("Crédito aprovado")
							lAprov := .T.
							U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
						EndIf
					Else 			
						MsgAlert("Rede com todas as lojas bloqueadas. Encaminhe para um nível superior para aprovação")
						lAprov := .F.	//chamado 028674 - Sigoli 07/10/2016
						Return       
					EndIF

				Else && se não for rede e esta no limite, é aprovado			
					MSGINFO("Crédito aprovado")
					lAprov := .T.
					U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
				EndIF
				&& antecipado          && avista 
			ElseIf !Empty(M->PB3_CODRED) .and. (M->PB3_BLOQUE = '2' .or. lRede = .T. .or. M->PB3_COND = '0' .or. M->PB3_COND = '00' .or. M->PB3_LIMAPR <= nValNivel)

				//sigoli 01/06/2017 Chamado:035009
				If GetAdvFVal("SE4", "E4_DMEDI",xFilial("SE4")+M->PB3_COND, 1) > nPrazoGer .and. lAltPraz == .T. .and. cNivel <= '5' 
					MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
					lAprov := .F.	
					Return       
				EndIf		 	

				nLimApAnt:= PesqLimiRed() //rotina para buscar saldo da rede

				If nLimApAnt <> M->PB3_LIMAPR .and. cNivel <= '5'	

					If  M->PB3_LIMAPR > nLimApAnt && é aumentando o limite

						&& verifico se eu posso aumentar limite solicitado
						If M->PB3_LIMAPR <= nValNivel

							If !MsgBox(ALLTRIM(cusername)+", limite da rede R$: "+cvaltochar(Alltrim(Transform(nLimApAnt,"@E 999,999,999.99")))+" esta diferente do limite solicitado R$: "+cvaltochar(Alltrim(Transform(M->PB3_LIMAPR,"@E 999,999,999.99")))+". Deseja aprovar?"+chr(13)+chr(10)+chr(13)+chr(10),"Limite REDE","YESNO")	
								MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
								lAprov := .F.	
								Return       
							Else    
								MSGINFO("Crédito aprovado")
								lAprov := .T.
								U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
							EndIf

						Else && nao posso aumentar o limit devido o meu limite/nivel
							MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
							lAprov := .F.	
							Return       	
						Endif

					ElseIf M->PB3_LIMAPR < PB3->PB3_LIMAPR .or. PB3->PB3_LIMAPR = 0  && reduzindo limite	

						If M->PB3_LIMAPR <= nValNivel

							If !MsgBox(ALLTRIM(cusername)+",limite da Rede R$: "+cvaltochar(Alltrim(Transform(nLimApAnt,"@E 999,999,999.99")))+" esta diferente do limite do solicitado R$: "+cvaltochar(Alltrim(Transform(M->PB3_LIMAPR,"@E 999,999,999.99")))+", deseja aprovar?"+chr(13)+chr(10)+chr(13)+chr(10),"Limite REDE","YESNO")	
								MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
								lAprov := .F.	
								Return       
							Else    
								MSGINFO("Crédito aprovado")
								lAprov := .T.
								U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA	
							EndIf

						Else
							MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
							lAprov := .F.	
							Return       
						EndIf	
					Else

						If M->PB3_LIMAPR <= nValNivel 
							MSGINFO("Crédito aprovado") 
							lAprov := .T.
							U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
						Else

							If M->PB3_LIMAPR <= nLimApAnt .and. (M->PB3_LIMAPR <= nValNivel .or. M->PB3_LIMAPR > PB3->PB3_LIMAPR)

								If !MsgBox(ALLTRIM(cusername)+",limite da rede R$: "+cvaltochar(Alltrim(Transform(nLimApAnt,"@E 999,999,999.99")))+" esta diferente do limite do solicitado R$: "+cvaltochar(Alltrim(Transform(M->PB3_LIMAPR,"@E 999,999,999.99")))+", deseja aprovar?"+chr(13)+chr(10)+chr(13)+chr(10),"Limite REDE","YESNO")	
									MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
									lAprov := .F.	
									Return       
								Else    
									MSGINFO("Crédito aprovado") 
									lAprov 	  := .T.
									U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
								EndIf

							Else
								MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
								lAprov := .F.	
								Return       

							Endif
						EndIf
					EndIF

				Else && se o limite da rede for igual que esta no cliente , entao é aprovado
					MSGINFO("Crédito aprovado")
					lAprov := .T.
					U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
				EndIF

			Else

				IF !Empty(M->PB3_CODRED) .and. M->PB3_BLOQUE = '1' .and. lRede = .F.
					MsgAlert("Rede com todas as lojas bloqueada. Encaminhe para um nível superior para aprovação")
					lAprov := .F.	//chamado 028674 - Sigoli 07/10/2016
					Return       
				EndIf

				If 	lAltLim  == .T. .or. lAltPraz == .T. 
					MsgAlert("Crédito não aprovado. Encaminhe para um nível superior para aprovação") 
					lAprov := .F.	
					Return       
				Else

					MSGINFO("Crédito aprovado")
					lAprov := .T.
					U_CREDITOLOG(cCodcli, cLojacli,cNomeUsr,"Credito Aprovado") //chamado 036175 05/01/2018 WILLIAM COSTA
				EndIf

				lAprov := .T.

			Endif	

			RecLock( 'PB3', .F. )
			M->PB3_PRZAPR	:= GetAdvFVal("SE4", "E4_DMEDI",xFilial("SE4")+M->PB3_COND, 1)

			If lAprov
				M->PB3_SITUAC	:= '2'
				M->PB3_DTAPRO	:= dDataBase
				M->PB3_PRIOR  	:= '2'
			Else
				M->PB3_SITUAC	:= '1'
			Endif

			For nX := 1 TO FCount()

				// Para nao gravar campos virtuais
				If Posicione( 'SX3', 1, FieldName(nX), 'X3_CONTEXT') != 'V'
					If "_FILIAL"$FieldName(nX)
						FieldPut(nX,xFilial('PB3'))
					Else
						FieldPut(nX,M->&(EVAL(bCampo,nX)))
					EndIf
				Endif

			Next nX

			PB3->( MsUnLock())

			&&Mauricio - Chamado 036154 - 07/07/17 - Após gravacao da alteração de dados cadastrais na PB3
			If PB3->PB3_TIPO == "F"  &&consumidor final
				RecLock( 'PB3', .F.)
				PB3->PB3_GRPTRI := "005"
				PB3->( MsUnLock()	)
			Endif

		Endif

	Endif

	RestArea( aArea )
Return NIL

/*{Protheus.doc} Static Function VERIFAPROV
	Mediante os parametros passados, verifica se o nivel do usuario permite que ele ANDREA_RIVELLES aprove o limite e  prazo solicitado
	@type  Function
	@author Vogas Junior
	@since 18/09/2009
	@version 01
	@history 
*/

Static Function VerifAprov( nLimiteSol, cPrazoSol, cNivel)

	Local lRetorno 	 	:= .F.
	Local aArea		 	:= GetArea()
	Local nPrazoSol  	:= ""
	Local nValNivel4 	:= SuperGetMv("FS_CREDI04", .F., 0 ) // ate 120.000
	Local nValNivel5	:= SuperGetMv("FS_CREDI05", .F., 0 ) // ate 150.000
	Local nValNivel6	:= SuperGetMv("FS_CREDI06", .F., 0 ) // ate 180.000
	Local nPrzMedio4	:= SuperGetMv("FS_PRZMED4", .F., 0 ) // Prazo Medio4
	Local nPrzMedio5 	:= SuperGetMv("FS_PRZMED5", .F., 0 ) // Prazo Medio5
	Local nPrzMedio6 	:= SuperGetMv("FS_PRZMED6", .F., 0 ) // Prazo Medio6

	DbSelectArea("SE4")
	nPrazoSol := GetAdvFVal("SE4", "E4_DMEDI",xFilial("SE4")+cPrazoSol, 1)
	nPrazoGer := 0 //variavel declarada como static

	Do Case

		Case cNivel == '4'
		lRetorno := (nLimiteSol <= nValNivel4 .And. nPrazoSol <= nPrzMedio4)
		nValNivel:= nValNivel4   && chamado sigoli
		nPrazoGer:= nPrzMedio4

		Case cNivel == '5'
		lRetorno := (nLimiteSol <= nValNivel5 .And. nPrazoSol <= nPrzMedio5)
		nValNivel:= nValNivel5 && chamado sigoli
		nPrazoGer:= nPrzMedio5

		Case cNivel == '6'
		lRetorno := (nLimiteSol <= nValNivel6 .And. nPrazoSol <= nPrzMedio6)
		nValNivel:= nValNivel6 && chamado sigoli
		nPrazoGer:= nPrzMedio6

		Case cNivel == '7'
		lRetorno := .T.

	EndCase

	//Sigoli 01/06/2017 Chamado: 035009
	If !lRetorno //retornou com falso, porem mexeu apenas no prazo e o prazo esta dentro do nivel  
		If lAltPraz == .T. .and. lAltLim == .F. .and. nPrazoSol <= nPrazoGer      	
			lRetorno := .T. 
		EndIf
	EndIf

	RestArea( aArea )                                     

Return ( lRetorno)

/*{Protheus.doc} User Function ACREDTOK
	Sem detalhametno
	@type  Function
	@author Sem Autor
	@since 05/04/2010
	@version 01
	@history 
*/

User Function Acredtok()  

	Local lRet := .t.

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	If Empty(M->PB3_COND)
		Alert( 'Não foi informada a condição de pagamento. Não se pode aprovar o credito. Favor Verificar.')
		lRet := .f.
	Endif

	IF M->PB3_TIPO == "F" .And. M->PB3_GRPTRIB != '005'        //Por Mauricio em 11/07/17
		Alert( 'Para clientes consumidor final,o Grupo de Clientes é 005.') 
		lRet := .F.
	Endif

	IF M->PB3_TIPO <> "F" .And. M->PB3_GRPTRIB = '005'         //Por Adriana em 11/07/17
		Alert( 'Grp.Clientes = 005, somente para clientes com Tipo = F-Cons.Final')                     
		lRet := .F.
	Endif

Return lRet

/*{Protheus.doc} Static Function ADOA5PRIO
	Atrbui prioridade 1=Alta, 2=Normal ao cadastro espelho de clientes
	@type  Function
	@author Vogas Junior
	@since 21/09/2009
	@version 01
	@history 
*/

Static function Adoa5Prio( cCodCli, cLojCli)

	Local aArea		:= GetArea()
	//Local lPrior 	:= MsgYesNo( 'Deseja Priorizar este Cliente?')
	//Local cNomeUsr 	:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	//Local cNivel	:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NIVEL')
	Local cNomeUsr 	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cNivel	:= GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
	Local oFont		:= NIL
	Local oDlg		:= NIL
	Local oGetMotivo:= NIL
	//Local cDescMot	:= Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodCli + cLojCli, 'PB3_DESPRI')
	Local cDescMot	:= GetAdvFVal( 'PB3', 'PB3_DESPRI', xFilial( 'PB3' ) + cCodCli + cLojCli, 1)
	Local oComboPrio:= NIL
	Local aPriori	:= {'Normal', 'Alta'}
	//Local cPriori	:= If( Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodCli + cLojCli, 'PB3_PRIOR') == '1', aPriori[2], aPriori[1] )
	Local cPriori	:= If( GetAdvFVal( 'PB3', 'PB3_PRIOR', xFilial( 'PB3' ) + cCodCli + cLojCli, 1) == '1', aPriori[2], aPriori[1] )
	Local nOpcao	:= 0
	Local cPara		:= AllTrim(SuperGetMv("FS_MOVMAIL", .F., 0 ))
	Local cMensagem	:= ''

	If val( cNivel ) < 2
		Alert( 'Seu usuário não está autorizado a utilizar esta funcionalidade')
		RestArea( aArea )
		Return
	Endif
	If cPriori == 'Alta'
		Alert( 'Cliente já foi priorizado, não é possível desfazer esta situação')
		RestArea( aArea )
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE "Motivo da Prioridade" FROM 10,10 To 200,400 OF oMainWnd PIXEL


	@ 27, 10 Say 'Grau de Prioridade' SIZE 200,15 OF oDlg PIXEL
	@ 54, 10 Say 'Descrição' SIZE 200,15 OF oDlg PIXEL

	// Combo de definicao da Prioridade
	oComboPrio := tComboBox():New( 04, 07, {|u|If( pCount() > 0, cPriori := u, cPriori)},;
	aPriori, 100, 0, oDlg,,{||},,,,.F.,,,,,,,,,'cPriori')

	// Get de Motivo da prioridade.
	oGetMotivo := tGet() :New( 06, 07, {|u|If( pCount()>0, cDescMot:= u, cDescMot) }, oDlg, 100, 10,;
	'@!',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cDescMot')

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()})

	If nOpcao == 1
		DbSelectArea( 'PB3')
		PB3->( DbsetOrder(1) )
		If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojCli))

			//Grava Log
			U_Ado05Log( cCodcli, cLojcli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_PRIOR', 'X3_Titulo' ), If( PB3->PB3_PRIOR == '1', 'Alta', 'Normal'), cPriori )
			U_Ado05Log( cCodcli, cLojcli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_DESPRI', 'X3_Titulo' ), PB3->PB3_DESPRI, cDescMot )
			RecLock( 'PB3', .F. )

			If cPriori	== 'Alta'
				PB3_PRIOR := '1'
			Else
				PB3_PRIOR := '2'
			Endif
			PB3_DESPRI := cDescMot

			PB3->( MsUnLock() )
		Endif

		//	cMensagem := 'O cliente ' + AllTrim( Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodCli + cLojCli, 'PB3_NOME')) +;
		//	' Código: ' + cCodCli + ' Loja: ' + cLojCli + ' foi priorizado em ' + DtoC( dDataBase ) + ' Por ' + cNomeUsr
		cMensagem := 'O cliente ' + AllTrim( GetAdvFVal( 'PB3', 'PB3_NOME', xFilial( 'PB3' ) + cCodCli + cLojCli, 1)) +;
		' Código: ' + cCodCli + ' Loja: ' + cLojCli + ' foi priorizado em ' + DtoC( dDataBase ) + ' Por ' + cNomeUsr

	Endif

	RestArea( aArea )
Return Nil

/*{Protheus.doc} Static Function ADOA5OBS
	Altera status do cliente posicionado e grava mensagem de observacao para o proximo aprovador
	@type  Function
	@author Vogas Junior
	@since 22/09/2009
	@version 01
	@history 
*/

Static Function Adoa5Obs( cCodCli, cLojaCli )

	Local aArea 		:= GetArea()
	//Local cNomeUsr 		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local oFont			:= NIL
	Local oDlg			:= NIL
	Local oGetObserv	:= NIL
	Local oHistorico	:= Nil
	//Local cObservacao	:= Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodCli + cLojaCli, 'PB3_OBSAPR')
	Local cObservacao	:= GetAdvFVal( 'PB3', 'PB3_OBSAPR', xFilial( 'PB3' ) + cCodCli + cLojaCli, 1)
	Local nOpcao		:= 0
	Local cPara			:= AllTrim(SuperGetMv("FS_MOVMAIL", .F., 0 ))
	Local cMensagem		:= ''
	Local cHistorico	:= AdoGetHist( cCodCli, cLojaCli )

	DEFINE MSDIALOG oDlg TITLE "Observação" FROM 10,10 To 440,640 OF oMainWnd PIXEL

	@ 045,005 Say 'Histórico' Of oDlg Pixel
	@ 142,001 Say 'Observação' Of oDlg Pixel
	// Get da Observacao.
	//	oGetObserv := tGet() :New( 02, 04, {|u|If( pCount()>0, cObservacao:= u, cObservacao) }, oDlg, 150, 10,;
	//	'@!',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cObservacao')

	oHistorico := tMultiGet():New( 03, 06, {|u|If( pCount()>0, cHistorico:= u, cHistorico) }, oDlg, 250, 090,;
	oFont,.T.,,,,.F.,,,,,,.T.,,,,,.T.)

	oGetObserv := tMultiget():New( 11, 06, {|u|if(Pcount()>0, cObservacao:=u, cObservacao) }, oDlg, 250, 30, oFont,,,,,.F.)
	oGetObserv:lWordWrap := .F.


	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,If( Empty( cObservacao ), Alert( 'É necessário informar Algo no campo Observação'), oDlg:End())},{||nOpcao:=0,oDlg:End()})

	If nOpcao == 1
		DbSelectArea( 'PB3')
		PB3->( DbsetOrder(1) )
		If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli))

			//Grava Log
			U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_OBSAPR', 'X3_Titulo' ), PB3->PB3_OBSAPR, cObservacao )
			RecLock( 'PB3', .F. )
			//	PB3_OBSAPR := cObservacao
			MSMM(,TamSx3("PB3_OBSAPR")[1],,cHistorico + chr(13) + chr(10)	+ cObservacao,1,,,"PB3","PB3_OBSMEM")
			PB3->( MsUnLock() )
		Endif

		//	cMensagem := 'O cliente ' + AllTrim( Posicione( 'PB3', 1, xFilial( 'PB3' ) + cCodCli + cLojaCli, 'PB3_NOME'))		+ ;
		//	' Código: ' + cCodCli + ' Loja: ' + cLojaCli + ' teve a Observação ' + cObservacao + ' Inserida Em: '	+ ;
		//	DtoC( dDataBase ) + ' Por ' + cNomeUsr
		cMensagem := 'O cliente ' + AllTrim( GetAdvFVal( 'PB3', 'PB3_NOME', xFilial( 'PB3' ) + cCodCli + cLojaCli, 1))		+ ;
		' Código: ' + cCodCli + ' Loja: ' + cLojaCli + ' teve a Observação ' + cObservacao + ' Inserida Em: '	+ ;
		DtoC( dDataBase ) + ' Por ' + cNomeUsr

	Endif


	RestArea( aArea )
Return NIL

/*{Protheus.doc} Static Function ADOA5EMAIL
	Inicia o processo de envio de email
	@type  Function
	@author Vogas Junior
	@since 22/09/2009
	@version 01
	@history 
*/

Static Function Adoa5Email( cCodCli, cLojaCli )

	Local oDlg			:= NIL
	Local oMainWnd		:= NIL
	Local oEmail2		:= NIL
	Local oEmail3		:= NIL
	Local oGetDe		:= NIL
	Local oSupervisor	:= NIL
	Local oGerente		:= NIL
	Local oEmail1		:= NIL
	Local oMensagem		:= NIL
	Local oVendedor		:= NIL
	Local oFont
	Local aArea 		:= GetArea()
	Local cEmail2		:= Space(50)
	Local cEmail3		:= SuperGetMv("FS_MOVMAIL", .F., 0 ) //Space(50)
	Local cDe			:= Trim( GetMV('MV_RELACNT') )
	Local csup			:= ''
	local cger			:= ''
	Local cSupervisor	:= Space(50)
	Local cGerente		:= Space(50)
	Local cEmail1		:= Space(50)
	Local cVendedor		:= Space(50)
	Local cAssunto		:= Space(100)
	Local cMensagem		:= Space(200)
	Local nOpcao		:= 0
	//Local cNomeUsr		:= ''
	//Local cNomeUsr 		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local lParecer		:= .F.
	Local lAnexo		:= .F.
	Local cPara			:= ''

	cDe := If( !Empty(GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + __cUserId, 7, " ")),;
	GetAdvFVal("SA3", "A3_NOME", xFilial("SA3") + __cUserId, 7, " "),;
	UsrRetMail(__cUserId ))

	DbSelectArea( 'PB3' )
	PB3->( dbSetOrder(1) )
	If PB3->( DbSeek( xFilial('PB3') + cCodCli + cLojaCli))

		//	cSup := Posicione( 'SA3', 7, xFilial('SA3') + PB3->PB3_VEND, 'A3_SUPER')
		//	cGer := Posicione( 'SA3', 7, xFilial('SA3') + PB3->PB3_VEND, 'A3_GEREN')
		//	cVendedor := Posicione( 'SA3', 7, xFilial('SA3') + PB3->PB3_VEND, 'A3_EMAIL')
		cSup := GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND, 7)
		cGer := GetAdvFVal( 'SA3', 'A3_GEREN', xFilial('SA3') + PB3->PB3_VEND, 7)
		cVendedor := GetAdvFVal( 'SA3', 'A3_EMAIL', xFilial('SA3') + PB3->PB3_VEND, 7)
		cSupervisor := GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + cSup, 1, " ")//UsrRetMail( Posicione( 'SA3', 1, xFilial('SA3') + cSup , 'A3_CODUSR') )
		//cGerente	:= GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + cGer, 1, " ")//UsrRetMail( Posicione( 'SA3', 1, xFilial('SA3') + cGer , 'A3_CODUSR') )

	Endif


	DEFINE MSDIALOG oDlg TITLE "Envio de E-Mail" FROM 10,10 To 340,540 OF oMainWnd PIXEL

	@ 017,010 Say "De:" SIZE 200,15 OF oDlg PIXEL
	@ 029,010 Say "E-Mail do Vendedor:" SIZE 200,15 OF oDlg PIXEL
	@ 041,010 Say "E-Mail do Supervisor:" SIZE 200,15 OF oDlg PIXEL
	@ 053,010 Say "E-Mail do Gerente:" SIZE 200,15 OF oDlg PIXEL
	@ 067,010 Say "E-Mail (1):" SIZE 200,15 OF oDlg PIXEL
	@ 079,010 Say "E-Mail (2):" SIZE 200,15 OF oDlg PIXEL
	@ 092,010 Say "E-Mail (3):" SIZE 200,15 OF oDlg PIXEL
	@ 105,010 Say "Assunto" SIZE 200,15 OF oDlg PIXEL
	@ 123,010 Say "Mensagem" SIZE 200,15 OF oDlg PIXEL
	@ 117,080 Say "Deseja Incluir os Pareceres" SIZE 200,15 OF oDlg PIXEL
	@ 117,184 Say "Inclui o Anexo" SIZE 200,15 OF oDlg PIXEL

	// Email do emissor
	oGetDe := tGet() :New( 01, 09, {|u|If( pCount()>0, cDe:= u, cDe) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.T.,,,'cDe')

	// Email do Vendedor
	oVendedor := tGet() :New( 02, 09, {|u|If( pCount()>0, cVendedor:= u, cVendedor) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cVendedor')

	// Email do Supervisor
	oSupervisor := tGet() :New( 03, 09, {|u|If( pCount()>0, cSupervisor:= u, cSupervisor) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cSupervisor')

	// Email do Gerente
	oGerente := tGet() :New( 04, 09, {|u|If( pCount()>0, cGerente:= u, cGerente) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cGerente')

	// Email 1
	oEmail1 := tGet() :New( 05, 09, {|u|If( pCount()>0, cEmail1:= u, cEmail1) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cEmail1')

	//  Email 2
	oEmail2 := tGet() :New( 06, 09, {|u|If( pCount()>0, cEmail2:= u, cEmail2) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cEmail2')

	//  Email 3
	oEmail3 := tGet() :New( 07, 09, {|u|If( pCount()>0, cEmail3:= u, cEmail3) }, oDlg, 150, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cEmail3')

	// Assunto
	oAssunto := tGet() :New( 08, 04, {|u|If( pCount()>0, cAssunto:= u, cAssunto) }, oDlg, 225, 10,;
	'@A',{||},,,oFont,,,.F.,,,,,,,.F.,,,'cAssunto')

	// Inclui Pareceres
	tCheckBox():New( 115, 71, 'Deseja Incluir os Pareceres',{|u|if( pcount()>0, lParecer:= u, lParecer)}, oDlg,10,10,,,,,,,,.T.,'Inclusão de Parecer.')

	// Inclui Anexos
	tCheckBox():New( 115, 175, 'Incluir Anexos',{|u|if( pcount()>0, lAnexo:= u, lAnexo)}, oDlg,10,10,,,,,,,,.T.,'Inclusão de Anexo.')

	// Mensagem
	oMensagem:= tMultiget():New( 10, 01, {|u|if(Pcount()>0, cMensagem:=u, cMensagem) }, oDlg, 250, 30, oFont,,,,,.F.)
	oMensagem:lWordWrap := .F.


	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=0,oDlg:End()})

	If nOpcao == 1

		cPara := If( !Empty(cVendedor)	, Alltrim(cVendedor)  	+ ';'	, '' )
		cPara += if( !Empty(cSupervisor), Alltrim(cSupervisor)	+ ';'	, '' )
		cPara += If( !Empty(cGerente)	, Alltrim(cGerente)	   	+ ';'	, '' )
		cPara += If( !Empty(cEmail1)	, Alltrim(cEmail1) 		+ ';'	, '' )
		cPara += If( !Empty(cEmail2)	, Alltrim(cEmail2) 		+ ';'	, '' )
		cPara += If( !Empty(cEmail3)	, Alltrim(cEmail3) 		+ ';'	, '' )

		cPara := mntcPara(cPara,AllTrim(SuperGetMv("FS_MOVMAIL", .F., 0 )))

		If Empty( cPara )
			Alert( 'Não foi informado o e-Mail do destinatário da mensagem. Favor Verificar.')
		Else
			CriaMail(cPara, cAssunto, cMensagem, cDe,, lAnexo, lParecer, cCodCli, cLojaCli  )
		Endif

	Endif

	RestArea( aArea )

Return Nil

/*{Protheus.doc} Static Function CRIAMAIL
	Faz o envio do email
	@type  Function
	@author Vogas Junior
	@since 22/09/2009
	@version 01
	@history 
*/

Static Function CriaMail(cPara, cAssunto, cMsg, cDe, cCC, lAnexo, lParecer, cCodCli, cLojaCli )

	Local aArea		 :=  GetArea()
	Local lResulConn := .T.
	Local lResulSend := .T.
	Local cError     := ''
	Local cServer    := Trim( GetMV('MV_RELSERV') ) //'smtp.adoro.com.br' // smtp.ig.com.br ou 200.181.100.51
	Local cEmail     := Trim( GetMV('MV_RELACNT') ) // fulano@ig.com.br
	Local cPass      := Trim( GetMV('MV_RELPSW') )  // 123abc
	Local lRet       := .T.
	Local cUser      := ''
	Local lAutentica := .F.
	Local cParecer	 := ''
	Local cAnexo	 := ''
	//Local cNivel	 := Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NIVEL')
	Local cNivel	 := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
	Local cFileLog 	 := Criatrab(,.f.)+".TXT"
	Local cFOpen	 := ''
	Local nOpcao 	 := 0
	Local i			 := 0
	Local aArquivos	 := {}
	Local aArq2		 := {}
	Local cCaminho	 := ''
	Local nPosicao	 := 0
	Local oDlgDoc	 := Nil
	Local oListBox	 := Nil
	Local cRootPath  := AllTrim( GetSrvProfString( "RootPath", "\" ) )
	Local cStartPath := AllTrim( GetSrvProfString( "StartPath", "\" ) )
	Local nPos       := 0
	Local lTemAnexo	 := .F.
	Local oTik		 := LoadBitMap(GetResources(), 'LBTIK')
	Local oNo		 := LoadBitMap(GetResources(), 'LBNO' )
	Local cPathEst   := "C:\TEMP"
	Local aAnexos	 := {}
	//Local cNomeUsr 		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)

	Default cMsg     := ''
	Default cCodCli  := Space(6)
	Private nLastKey := 0

	If Empty( cServer ) .AND. Empty( cEmail ) .AND. Empty( cPass )
		ApMsgStop( 'Não foram definidos os parâmetros no server do Protheus para envio de e-mail', cAssunto )
		Return .F.
	Endif

	If lAnexo

		dbSelectArea("PB3")
		PB3->( dbSetOrder(1))
		PB3->( dbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))

		cDirServer := Alltrim(GetPvProfString(GetEnvServer(),"Rootpath","",GetADV97())) + "\Anexos" //GetMv("AC_DIRANEX",,"chamados\")

		if Right(cDirServer,1) <> "\"
			cDirServer += "\"
		endif

		cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
		if !lIsDir(cDirServer)
			makeDir(cDirServer)
		endif

		// verifica se cliente já possui diretório
		cDirServer += ( StrZero( Val( alltrim(cCodCli)), 6 ) + cLojaCli + "\")
		cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
		if lIsDir(cDirServer)
			lTemAnexo:= .T.
		endif

		if Right(cPathEst,1) <> "\"
			cPathEst += "\"
		endif

		nPos := 1
		nPos1 := 1
		cdirTemp := ""

		While .t.
			nPos := at("\", substr(cPathEst,nPos1))
			if nPos > 3
				cDirTemp := substr(cPathEst,1, nPos1+nPos-1)
				if !lIsDir(cDirTemp)
					makeDir(cDirTemp)
				endif
			Endif
			nPos1 := nPos1+npos
			if nPos1 >= len(cPathEst)
				exit
			Endif
		Enddo

		cAnexFile 	:= StrZero( Val( AllTrim( cCodCli )), 6 ) + cLojaCli  + ".XLS"
		nPos 		:= rat(".", cAnexFile)
		cExtens 	:= ""
		if Len(Dtoc(dDataBase)) = 8
			cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 7, 2 )
		else
			cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 9, 2 )
		endif
		if nPos>0
			cExtens := substr(cAnexFile, nPos+1)
		Endif

		If lTemAnexo

			// apaga arquivos que estejam na maquina do usuario
			If File( cPathEst + cAnexFile )
				Ferase( cPathEst + cAnexFile )
			EndIf

			cFileOrig := cDirServer //+cAnexFile
			// pega os arquivos do cliente
			aAnexos := Directory( /*cRootPath + */cDirServer + '*.*', '')
			If Empty( aAnexos )
				Alert( 'Não existem anexos para o cliente selecionado')
			Else
				// monta array com as informacoes que serao exibidas em tela Nome arquivo, data que foi inserido, usuario que inseriu
				for i:= 1 to len( aAnexos )
					aAnexos[ i, 2 ] := 	aAnexos[ i, 1 ]
					aAnexos[ i, 1 ] := .F.
					aAnexos[ i, 3 ] := CtoD( SubStr( aAnexos[ i, 2 ], 9, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 11, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 13, 2 ) )
					//				aAnexos[ i, 4 ] := Posicione( 'PB1',1,xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ),'PB1_NOME')
					aAnexos[ i, 4 ] := GetAdvFVal( 'PB1', 'PB1_NOME',xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ), 1)
				Next i

				DEFINE MSDIALOG oDlgDoc TITLE "Seleção de Anexos" FROM 10,10 To 400,/*397*/470 OF oMainWnd PIXEL
				// RICARDO LIMA - 14/01/18
				@ 030,000 Say 'SELECIONE O ARQUIVO QUE DESEJA VISUALIZAR' SIZE 200,15 OF oDlgDoc PIXEL CENTERED
				@ 050,007 ListBox oListBox Fields HEADER " ","Arquivo", "Data", "Usuário";
				Size 220 , 170 Of oDlgDoc Pixel ColSizes 25,100,50,50;
				On DBLCLICK (aAnexos[oListBox:nAt,1] := !aAnexos[oListBox:nAt,1] , oListBox:Refresh())
				oListBox:SetArray(aAnexos)
				oListBox:bLine := {|| {If( aAnexos[oListBox:nAT,01], oTIK, oNO ),aAnexos[oListBox:nAT,02],aAnexos[oListBox:nAT,03],aAnexos[oListBox:nAT,04]}}

				ACTIVATE MSDIALOG oDlgDoc CENTERED ON INIT EnchoiceBar(oDlgDoc,{||nOpcao:= 1,oDlgDoc:End()},{||nOpcao:=0,oDlgDoc:End()})
			Endif
		Endif

		// Selecao de arquivos em qqer diretorio
		/*	While nOpcao == 0
		//cFOpen += cGetFile('Todos os Arquivos  (*.*)   | *.*     ','Seleção de Arquivo',1,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD ) 	//+ '; '
		aAdd( aArquivos, cGetFile('Todos os Arquivos  (*.*)   | *.*     ','Seleção de Arquivo',1,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD ))
		If ! msgYesNo( 'Deseja Incluir Novo Arquivo?')
		nOpcao := 1
		EndIf
		//	Enddo		*/
		If nOpcao == 1 .And. !Empty( aAnexos )
			For i:= 1 to len( aAnexos )
				If aAnexos[ i, 1 ]
					aAdd(aArquivos, aAnexos[ i, 2 ] )
				Endif
			Next i

			//copia dos arquivos selecionados para o system
			If !Empty( aArquivos )
				//			cCaminho := MontaDir(cStartPath+'\Anexos\')
				For i := 1 to Len( aArquivos )

					// encontra a posicao da ultima barra
					//				nPosicao := Rat( '\', aArquivos[i] )
					// extrai apenas o nome do arquivo
					cFOpen:= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) )
					// copia o arquivo para o caminho desejado
					//				__copyfile( aArquivos[i] , cStartPath+'\Anexos\' + cFOpen )
					// alimenta array com os nomes de arquivo
					//				aAdd( aArq2, cFOpen )
					//cAnexo += cStartPath+'\Anexos\' + cFOpen + '; '
					cAnexo += cDirServer + cFOpen + ';'
					//cFOpen+= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) ) + '; '
				Next i
			Endif
		Endif
	Endif

	// Deseja enviar os pareceres por anexo
	If lParecer
		cParecer := AdoGetHist( cCodCli, cLojaCli, cNivel )
		memowrite( cFileLog, cParecer )
		//	cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
		cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
	Endif
	cAnexo := Left(cAnexo,len(cAnexo)-1)
	cDe 	:= NIL
	cDe      := IIf( cDe == NIL, AllTrim(GetMv("MV_RELFROM")), AllTrim( cDe ) ) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	cPara    := AllTrim( cPara )
	cCC      := AllTrim( cCC )
	cAssunto := AllTrim( cAssunto )

	CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

	If !lResulConn
		GET MAIL ERROR cError
		CONOUT( 'Falha na conexão para envio de e-mail ' + cError,, .F. )

		If !IsBlind()
			ApMsgStop( 'Falha na conexão para envio de e-mail ' + cError )
		EndIf
		cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

		//Grava LOG
		U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulConn, "Enviado com sucesso!", "Falha de envio!"), " " )

		Return .F.
	Endif

	lAutentica:= GETMV('MV_RELAUTH')
	If lAutentica
		cUser:= GETMV('MV_RELACNT')
		cPass:= GETMV('MV_RELAPSW')
		If !MailAuth(cUser,cPass)
			Msginfo(OemToAnsi('Falha autenticacao Usuario'))
			cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

			//Grava LOG
			U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lAutentica, "Enviado com sucesso!", "Falha de envio!"), " " )
			Return .F.
		Endif
	Endif

	If Empty( cCc ) .AND.  Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend

	ElseIf  Empty( cCc ) .AND. !Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	ElseIf !Empty( cCc ) .AND.  Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend

	Else
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	Endif

	If !lResulSend
		GET MAIL ERROR cError
		lRet := .F.

		If !IsBlind()
			ApMsgStop( 'Falha no envio do e-mail (' + cError + ') ' )
		Else
			CONOUT( 'Falha no envio do e-mail (' + cError + ') ',, .F. )
		EndIf
	Endif
	cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

	//Grava LOG
	U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulSend, "Enviado com sucesso!", "Falha de envio!"), " " )

	DISCONNECT SMTP SERVER
	cMsg :=''

	FERASE( cFileLog )
	//If !Empty( aArq2 )
	//	For i:= 1 to len( aArq2 )
	//		FERASE( cStartPath+'\anexos\' + aArq2[i] )
	//	Next i
	//Endif

	RestArea( aArea )

Return lRet

/*{Protheus.doc} Static Function ADOA5PAREC
	Permite a insercao de pareceres de acordo com a alcada do usuario
	@type  Function
	@author Vogas Junior
	@since 22/09/2009
	@version 01
	@history 
/*/
Static Function Adoa5Parec( cCodCli, cLojaCli, cLtParecer )

	Local aArea 	:= GetArea()
	Local cNomeUsr 	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cNivel	:= GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
	Local oFont		:= NIL
	Local oDlg		:= NIL
	Local oParecer	:= NIL
	Local oHistorico:= NIL
	Local cHistorico:= ""
	Local cParecer	:= ''
	Local nOpcao	:= 0
	Local cFilPBA	:= xFilial( 'PBA' )
	Local cLerParec	:= GetAdvFVal( 'PB2', 'PB2_LER', xFilial( 'PB2' ) +  __cUserId, 1)
	Local cIncluiPar:= GetAdvFVal( 'PB2', 'PB2_INCLUI', xFilial( 'PB2' ) +  __cUserId, 1)
	Local nLimitSol	:= 0
	Local nPrazoSol	:= 0
	Local lPodeCred := .F.
	Local nEnca
	Local cSituaca	:= ""
	Local cDepto	:= GetAdvFVal( 'PB1', 'PB1_DEPTO', xFilial( 'PB1' ) + __cUserId, 1)    //&&Mauricio - Chamado 035857 - 14/07/17 
	Local lBkOffice :=  GetAdvFVal( 'PB2', 'PB2_BCKOFI', xFilial( 'PB2' ) + __cUserId, 1) = '1' // fernando sigoli 19/04/2018- CHAMADO: 040989

	Default cCodCli    := ""
	Default cLojaCli   := ""
	Default cLtParecer := ""

	cHistorico:= AdoGetHist( cCodCli, cLojaCli, cNivel )
	nLimitSol	:= GetAdvFVal( 'PB3', 'PB3_CREDSU', xFilial( 'PB3' ) + cCodCli + cLojaCli, 1)
	nPrazoSol	:= GetAdvFVal( 'PB3', 'PB3_PRAZOS', xFilial( 'PB3' ) + cCodCli + cLojaCli, 1)
	cSituaca	:= GetAdvFVal( 'PB3', 'PB3_SITUAC', xFilial( 'PB3' ) + cCodCli + cLojaCli, 1) //&&Mauricio - Chamado 035857 - 14/07/17

	If Empty(cLtParecer) // @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)

		If cLerParec <> '1' .And. ! IsInCallStack('RESTEXECUTE') //Everson - 09/10/2017. Chamado 037261.
			Alert( 'Usuario sem acesso a visualização de pareceres. Verificar cadastro de Permissões')
			RestArea( aArea )
			Return
		Endif

		If ! IsInCallStack('RESTEXECUTE') 

			DEFINE MSDIALOG oDlg TITLE "Pareceres " FROM 10,10 To 400,640 OF oMainWnd PIXEL

			@ 57, 33 Say 'Nível     Usuario          Data           Hora          Parecer' SIZE 200,15 OF oDlg PIXEL
			@ 110, 10 Say 'Historico' SIZE 200,15 OF oDlg PIXEL
			// Historico de pareceres
			oHistorico := tMultiGet():New( 03, 04, {|u|If( pCount()>0, cHistorico:= u, cHistorico) }, oDlg, 250, 090,;
			oFont,.T.,,,,.F.,,,,,,.T.,,,,,.T.)
			oHistorico:lWordWrap := .F.
			oHistorico:EnableHScroll(.T.)

			If cIncluiPar == '1'
				IF !cSituaca $ '2/4' .Or. (cSituaca $ '2/4' .And. cDepto $ '000002/000001') //credito/financeiro   &&Mauricio - Chamado 035857 - 14/07/17 Em analise não pode ser incluido novo parecer
					@ 200, 10 Say 'Parecer' SIZE 200,15 OF oDlg PIXEL
					// Get do Parecer.
					oParecer := tMultiget():New( 11, 04, {|u|if(Pcount()>0, cParecer:=u, cParecer) }, oDlg, 250, 30, oFont,.F.,,,,.F.)
					oParecer:lWordWrap := .T.
				Endif	  
			Endif

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()},,/*aBotao*/)

		EndIf

		cLtParecer := cParecer

	Else

		If IsInCallStack("FIXLIMITS")
			cParecer := cLtParecer
		EndIf
	
	EndIf

	// @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
	If Empty(cParecer) .and. Empty(cLtParecer)
		cParecer := "Login " + cUserName + " não informou um parecer em " + DtoC(msDate()) + " " + Time()
	EndIf
	//

	If nOpcao == 1 .And. !Empty( cParecer ) .Or. IsInCallStack('RESTEXECUTE') .or. IsInCallStack("FIXLIMITS")

		If !Empty(cCodCli)

			DbSelectArea( 'PBA' )
			RecLock( 'PBA', .T. )

				PBA_FILIAL	:= cFilPBA
				PBA_CODCLI	:= cCodCli
				PBA_LOJACL	:= cLojaCli
				PBA_NIVEL	:= cNivel
				PBA_USUARI	:= __cUserId
				PBA_NOME	:= cNomeUsr
				PBA_DATA	:= dDatabase
				PBA_HORA	:= TIME()
				MSMM(,TamSx3("PBA_PARECE")[1],,UPPER(Iif(! IsInCallStack('RESTEXECUTE'),cParecer,cRestParecer)),1,,,"PBA","PBA_CODMEM")

			PBA->( MsUnLock())

			dbSelectArea("PB3")
			PB3->( DbSetOrder(1))

			If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli )) .and. PB3->PB3_VENENC = __cUserId
				recLock("PB3",.F.)
					PB3->PB3_PARECE := .T.
				msUnlock()
			endif

			If cDepto $ '000002/000001' // &&Mauricio - Chamado 035857 - 14/07/17 Em analise não pode ser incluido novo parecer
				DbSelectArea("PB3")
				PB3->( DbSetOrder(1))	
				If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))
					If PB3->PB3_SITUAC <> '2'	
						recLock("PB3",.F.)
							PB3->PB3_SITUAC := "4"
						PB3->(MsUnlock())
					EndIf
				Endif	
			Endif

			// Varredura entre os niveis
			if cNivel <> '1' .and. nLimitSol <= SuperGetMv("FS_CREDI0" + cNivel, .F., 0 ) .and. nPrazoSol <= SuperGetMv("FS_PRZMED" + cNivel, .F., 0 )
				lPodeCred := .T.
			endif

			if cNivel = '3' // Gerente sempre pode enviar para credito
				lPodeCred := .T.
			endif
			
			If lBkOffice // fernando sigoli 19/04/2018- CHAMADO: 040989
				lPodeCred := .T.
			EndIf
			
			If !IsInCallStack("FIXLIMITS") // @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
				If lPodeCred
					nEnca := Aviso('Atenção','Deseja encaminhar o cliente ?',{'Não','Superior','Crédito'},1)
				Else
					nEnca := Aviso('Atenção','Deseja encaminhar o cliente ?',{'Não','Superior'},1)
				Endif
			Else
				nEnca := 1 // @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
			EndIf

			//Everson - 09/10/2017. Chamado 037261.
			If IsInCallStack('RESTEXECUTE')

				If cNivel <> '1' //Se o cadastro foi gerado pelo serviço rest e o nível do usuário é diferente de 1 (vendedor). O cadastro é encaminhado para o crédito.
					nEnca := 3

				Else
					nEnca := 2

				EndIf

			EndIf
			//

			If nEnca = 2 //Enviar ao Superior

				If cNivel < '4'
					AutSndEnc( cCodCli, cLojaCli, __cUserId ) //__cUserId
				Else
					Adoa5Enc( cCodCli, cLojaCli, __cUserId )
				Endif

			Elseif nEnca = 3 // Enviar ao Credito
				
				Adoa5Enc( cCodCli, cLojaCli, __cUserId )

			ElseIf nEnca = 1 //nao enviar para nenhum superior 

				If cSituaca <> '2' .and. !Empty( cParecer ) .And. cDepto $ '000002/000001'
					DbSelectArea("PB3")
					PB3->( DbSetOrder(1))	
					If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))
						recLock("PB3",.F.)
							PB3->PB3_SITUAC := "1"    
						PB3->(MsUnlock())
					Endif	
				Endif

			Endif

		EndIf

	Elseif nOpcao == 1 .And. Empty( cParecer ) .And. cDepto $ '000002/000001' // &&Mauricio - Chamado 035857 - 14/07/17 Em analise não pode ser incluido novo parecer

		DbSelectArea("PB3")
		PB3->( DbSetOrder(1))	
		If PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))
			RecLock("PB3",.F.)
				PB3->PB3_SITUAC := "4"
			PB3->(MsUnlock())
		Endif

	Endif

	RestArea( aArea )

Return cParecer

/*{Protheus.doc} Static Function ADOGETHIST
	Retorna variavel char com o historico dos pareceres do nivel cliente e loja informados no parametro
	@type  Function
	@author Vogas Junior
	@since 23/09/2009
	@version 01
	@history 
*/

Static function AdoGetHist( cCodCli, cLojaCli, cNivel)

	Local aArea			:= GetArea()
	Local cFilPBA 		:= xFilial( 'PBA' )
	Local cHistorico	:= ''
	Local aHiSt			:= {}
	Local cFilPB3		:= xFilial( 'PB3' )
	Local i				:= 0

	If Empty( cNivel )
		DbSelectArea( 'PB3' )
		PB3->( DbSetOrder( 1 ) )
		If PB3->( DbSeek( cFilPB3 + cCodCli + cLojaCli ))

			cHistorico += AllTrim(MSMM(PB3->PB3_OBSMEM))

		Endif

	Else

		DbSelectArea( 'PBA' )
		PBA->( DbSetOrder( 1 ) )
		// Conforme ultima orientacao de Reginaldo(Ad'oro), os pareceres nao serao separados por niveis, ou seja todos os niveis visualizam todos os pareceres
		If PBA->( DbSeek( cFilPBA + cCodCli + cLojaCli /*+ cNivel*/ ))

			While 	cFilPBA == PBA->PBA_Filial .And.	;
			cCodCli == PBA->PBA_CODCLI .And. 	;
			cLojaCli == PBA->PBA_LOJACL //.And. 	;
				//		 		cNivel == PBA->PBA_NIVEL .And. !PBA->( EOF())
				/*
				cHistorico += 	PBA->PBA_NIVEL + ' - ' 	+;
				AllTrim(PBA->PBA_NOME) + ' - ' 	+;
				DtoC(PBA->PBA_DATA) + ' - ' 	+;
				PBA->PBA_HORA + ' - '  	+;
				AllTrim(MSMM(PBA->PBA_CODMEM))
				cHistorico += chr(13) + chr(10)
				*/
				aAdd( aHist, {	PBA->PBA_NIVEL 			,;
				AllTrim(PBA->PBA_NOME) 	,;
				PBA->PBA_DATA 	,;
				PBA->PBA_HORA 			,;
				AllTrim(MSMM(PBA->PBA_CODMEM))})

				PBA->( DbSkip())
			Enddo
		Endif
	Endif


	// ordenar pareceres em ordem decrescente conforme orientacao de Reginaldo (Ad'oro)
	If !empty( aHist)
		Asort( aHist,,,{ |x, y| Dtos(x[3]) + x[4] > Dtos(y[3])+ y[4] })

		For i:= 1 to len( aHist)
			cHistorico += aHist[i,1] + ' - ' + aHist[i,2] + ' - ' + Dtoc(aHist[i,3]) + ' - ' + aHist[i,4] + ' - ' + aHist[i,5] + chr(13) + chr(10)
		Next i
	Endif

	RestArea( aArea )

Return ( cHistorico )

/*{Protheus.doc} Static Function GETENVIADO
	Filtro para permitir apenas clientes movimentados para um determinado usuario informado no parametro seja mostrados
	@type  Function
	@author Vogas Junior
	@since 28/09/2009
	@version 01
	@history 
*/

/*
Static Function GetEnviado( cCodCli, cLojaCli, cUsuario )

Local lRetorno 	:= .F.
Local aArea		:= GetArea()

DbSelectArea( 'PB9' )
PB9->( DbSetOrder( 2 ))

If PB9->( DbSeek( xFilial( 'PB9' ) + cCodCli + cLojaCli + Alltrim( cUsuario ) ))
lRetorno := .T.
Endif

RestArea( aArea )

Return ( lRetorno )
*/

/*{Protheus.doc} Static Function ADOGETSUPE
	Filtro que permite apenas a apresentacao de registros que foram enviados na data informada por parametro
	@type  Function
	@author Vogas Junior
	@since 29/09/2009
	@version 01
	@history 
*/

Static Function AdoGetSupe( cSuperv, cVend )

	Local aArea		:= GetArea()
	//Local lRetorno	:= ( cSuperv == Posicione( 'SA3', 7, xFilial('SA3') + cVend, 'A3_SUPER' ))
	Local lRetorno	:= ( cSuperv == GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + cVend, 7 ))

	RestArea( aArea )

Return( lRetorno )

/*{Protheus.doc} Static Function ADOINCA1
	Inclui/Altera dados do cadastro de clientes (SA1) mediante as informacoes do cadastro espelho de clientes (PB3)
	@type  Function
	@author Vogas Junior
	@since 29/09/2009
	@version 01
	@history 
*/

Static Function AdoIncA1( cCodCli, cLojaCli)

	Local bCampo		:= {|nCPO| Field(nCPO) }
	Local aArea 		:= GetArea()
	Local cCodSA1 	
	Local cLOJA 	
	Local Nx			:= 0
	Local aEstrutSA1	:= SA1->( DbStruct())
	Local aEstrutPB3	:= PB3->( DbStruct())
	Local lCliNovo		:= .T.
	Local cPara			:= AllTrim( SuperGetMv("FS_MOVMAIL", .F., 0 )) + '; '
	Local cMensagem		:= ''
	//local cNomeVen 	:= Posicione( 'PB1',1,xFilial('PB1') + __cUseriD,'PB1_NOME')
	//Local cNomeUsr	:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	local cNomeVen 		:= GetAdvFVal( 'PB1', 'PB1_NOME',xFilial('PB1') + __cUseriD, 1)
	Local cNomeUsr		:= cNomeVen
	Local nNivelCred	:= Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )
	Local cCodVend  	:= ""
	Local lSucesso  	:= .T.
	Local lTemRede  	:= .F.
	LOcal lMatriz   	:= .F.
	Local cBloqueio	
	Local cCodSup		:= Space(6)
	Local cSupervisor	:= Space(50)
	Local lCnpjDif  	:= .F.
	Local cCodRede  	:= "" 	//Chamado 028674 - Sigoli 07/10/2016
	Local nLimAprov     := 0	//Chamado 028674 - Sigoli 07/10/2016
	Local cCondPag      := "" 	//Chamado 028674 - Sigoli 07/10/2016
	Local cValNivel		:= GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserID			, 1	) //Chamado 028674 - Sigoli 07/10/2016
	Local lVerAprov 	:= .F. //Chamado 028674 - Sigoli 07/10/2016
	Local cOpcao        := "INCLUSAO" 
	Local lAltPraz                    //13/06/2017 Estava apresentando error log
	Local lSales		:= .F. //Everson - 30/01/2018. Chamado 037261.
	Local cUpZC6		:= ""
	Local cUpZBC		:= ""
	Local _cQuery2      := ""
	Local _cQuery4      := ""
	Local _cQuery5      := ""
	Local ncontCNPJ     := 0
	Local cCgcRaizPai   := ''
	Local nLimRedeZF    := 0
	Local nNewLimapr    := 0

	Private lAltLim     := .F. //Everson - 16/09/2020. Chamado 1687.

	// Apenas podem inserir clientes no Protheus, usuarios com nivel do setor de credito ou seus superiores.
	DbSelectArea('PB1')
	PB1->( DbSetOrder( 1 ) )
	PB1->( DbSeek( xFilial( 'PB1' ) + __cUserId ))
	If Val( PB1->PB1_NIVEL ) < nNivelCred
		Alert( 'Perfil de Usuário incompativel com esta funcionalidade' )
		RestArea( aArea )
		Return Nil
	Endif

	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 1 ))
	PB3->( DbSeek( xFilial('PB3') + cCodCli + cLojaCli))

	cCodSA1		:= PB3->PB3_CODSA1
	cLOJA 		:= PB3->PB3_LOJSA1
	cBloqueio	:= PB3->PB3_BLOQUE
	cCodRede    := PB3->PB3_CODRED //Chamado 028674 - Sigoli 07/10/2016
	nLimAprov 	:= PB3->PB3_LIMAPR //Chamado 028674 - Sigoli 07/10/2016
	cCondPag    := PB3->PB3_COND   //Chamado 028674 - Sigoli 07/10/2016
	lDesBloq  	:= iif(cBloqueio = "1", .F., .T.) //incluido por Adriana em 03/08/16, se bloqueado .f. - chamado 029853

	//Se cliente não for cozinha industrial
	//Verificar se o CNPJ do cliente a ser cadastrado já existe no SA1
	if !Alltrim(PB3->PB3_SUBSEG) $ '51#52#53'
		if PB3->PB3_EST <> "EX"
			DbSelectArea('SA1')
			DbSetOrder( 3 )
			if DbSeek( xFilial( 'SA1' ) + PB3->PB3_CGC,.f. ) .and. SA1->A1_COD <> PB3->PB3_CODMAT .and. SA1->A1_COD <> PB3->PB3_CODSA1  .and. ALLTRIM(SA1->A1_INSCR) == ALLTRIM(PB3->PB3_INSCR) //CH.052614 || OS 053991 || INCUBATORIO || VALERIA || (19)3539-1309 || CAD. CLIENTES || ABEL BABINI || 21/10/2019 || VALIDA INSCRICAO ESTADUAL
				DbSetOrder( 1 )
				Alert( 'CNPJ já cadastrado no cliente '+SA1->A1_COD+'-'+Alltrim(SA1->A1_NOME)  )
				RestArea( aArea )
				Return Nil
			Endif
			DbSetOrder( 1 )
		endif
	else

		if Empty(PB3->PB3_CODMAT)
			if Aviso("Atenção","Campo codigo da Matriz em branco. Este cliente é uma matriz de cozinha industrial ? ",{"&Sim","&Não"}) = 2
				RestArea( aArea )
				Return Nil
			endif
		Endif

	endif

	if cBloqueio = '1'

		ldesBloq := Aviso('Atenção','Cliente bloqueado, deseja desbloqueá-lo?',{'Sim','Não'},2) == 1

	Endif 


	// **************************** INICIO VERIFICA SE JÁ EXISTE CNPJ CADASTRADO NA SZF - WILLIAM COSTA *********** //

	DbSelectArea("SZF")
	dbGoTop()
	DbSetOrder(1)  
	IF	SZF->( DbSeek( xFilial("SZF")+SUBSTRING(PB3->PB3_CGC,1,8))) .AND. ;
	SZF->ZF_REDE <> PB3->PB3_CODRED

		ALERT("Atenção Cnpj já utilizado na Rede: " + SZF->ZF_REDE + ' favor verificar.')
		lCnpjDif := .T.

	ENDIF	
	DBCLOSEAREA("SZF")

	//inicio Chamado 028674 - Sigoli 07/10/2016
	If Empty(cCodRede) .and. lDesBloq == .T. .and. cBloqueio = '1' 

		lVerAprov := VerifAprov(nLimAprov,cCondPag,cValNivel)

		If lVerAprov == .F.
			Alert(Alltrim(cNomeUsr)+" Cliente nao Desbloqueado Devido a Restrição da alçada de liberação, Encaminhe para um Nivel superior ")   
			RestArea( aArea )
			Return Nil
		EndIF

	EndIf
	//fim Chamado 028674 - Sigoli 07/10/2016


	IF lCnpjDif == .T.

		RestArea( aArea )
		Return Nil

	ENDIF

	// **************************** FINAL VERIFICA SE JÁ EXISTE CNPJ CADASTRADO NA SZF - WILLIAM COSTA *********** //

	Begin Transaction

		If PB3->PB3_SITUAC == '2'
			__lEnvMail1 := .F.
			if lDesBloq  


				DbSelectArea( 'PB3' )
				PB3->( dbSetOrder( 1 ))

				If PB3->( dbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))

					//Grava LOG
					If cBloqueio = "1"  && Sigoli 08/03/2017 chamado 031202 - 031202
						U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ), 'Bloqueado'/*PB3->PB3_BLOQUE*/, 'Desbloqueado'/*'2'*/ )
					EndIf

					RecLock( 'PB3', .F. )
					PB3->PB3_BLOQUE	:= '2'
					PB3->PB3_MOTBLQ	:= ''		
					PB3->PB3_MOTREJ	:= ''
					PB3->( MsUnLock())

					//desbloquear tambem no cadastro de clientes
					If !Empty( PB3->PB3_CODSA1 )
						DbSelectArea( 'SA1' )
						SA1->( DbSetOrder(1) )
						If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJA))

							RecLock( 'SA1', .F. )
							SA1->A1_MSBLQL  := '2'
							SA1->A1_DTREAT  := dDataBase

							If !Empty(SA1->A1_ULTCOM) .and. cBloqueio = "1" .and. SA1->A1_ROTEIRO <> '200'  && Sigoli Chamado 031202  02/03/2017
								SA1->A1_ROTEIRO = '199' 	
							EndIf									

							SA1->( MsUnLock())

							_aArea:=GetArea()
							U_RESPM001("SA1",4, SA1->(Recno()), .F. )
							RestArea(_aArea)

						Endif
					Endif

					cPara		:= mntcPara(cPara,AllTrim( SuperGetMv("FS_MOVMAIL", .F., 0 )) + '; ')
					cPara 		+= Alltrim(GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + PB3->PB3_VEND, 7, " ")) //AllTrim( UsrRetMail( PB3->PB3_VEND ))

					cMensagem 	:= 	'O cliente ' + PB3->PB3_CODSA1 + ' - ' + PB3->PB3_NOME + ' Loja ' + PB3->PB3_LOJA + cNomeUsr+chr(13) + chr(10)+;
					'Foi desbloqueado em ' + DtoC( dDatabase ) + ' Por ' + cNomeUsr+chr(13) + chr(10)
					cMensagem := "Codigo          : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
					cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)
					cMensagem += "Cliente         : "+ PB3->PB3_NOME+chr(13) + chr(10)
					cMensagem += "CNPJ/CPF        : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
					cMensagem += "Vendedor        : "+ GetAdvFVal("SA3","A3_COD",xFilial("SA3")+PB3->PB3_VEND,7)+;
					"-"+GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+PB3->PB3_VEND,7)	+chr(13) + chr(10)
					cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
					cMensagem += "Prazo           : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
					cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)

					__cMyPara := cPara
					__cMyAssunto := 'Cliente Desbloqueado'
					__cMyMsg := cMensagem
					__cMyCodCli := cCodCli
					__cMyLojaCli := cLojaCli

				Endif

			Endif

			cCodVend    := GetAdvFVal("SA3", "A3_COD", xFilial("SA3") + PB3->PB3_VEND, 7, " ")
			cCodSup		:= GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND, 7 )
			cSupervisor	:= AllTrim( GetAdvFVal( 'SA3','A3_EMAIL', xFilial('SA3') + cCodSup, 1  ) )

			cPara		:= AllTrim( SuperGetMv("FS_MOVMAIL", .F., 0 )) + '; '
			cPara 		+= Alltrim(GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + PB3->PB3_VEND, 7, " ")) //AllTrim( UsrRetMail( PB3->PB3_VEND ))
			cPara		:= mntcPara(cPara,cSupervisor)

			cMensagem 	:= 	'O cliente ' + cCodCli + ' - ' + PB3->PB3_NOME + ' Loja ' + cLojaCli +;
			'Não Foi incluido no Protheus em ' + DtoC( dDatabase ) + ' Por ' + cNomeVen+chr(13) + chr(10)+;
			'Ocorreu um erro no momento da inclusão'

			dbSelectArea("SA3")
			dbSetOrder(1)

			DbSelectArea( 'SA1' )
			SA1->( DbSetOrder( 1 ))

			//Cliente ja cadastrado no SA1
			If !Empty(cCodSA1) .and. DbSeek( xFilial('SA1') + cCodSA1 + cLOJA )

				If U_AtuSa1("A", cCodSA1, cLOJA) // Alterar
					lSucesso := .T.
				Else
					lSucesso := .F.
				Endif

				//FLAG PARA MOSTRAR QUE O CADASTRO DO CLIENTE É DE ALTERAÇÃO E NAO DE INCLUSAO
				cOpcao:= "ALTERACAO"
			Else

				if  Empty(PB3->PB3_CODMAT) // Cliente não Faz parte de uma rede

					//cCodSA1 := PB3->PB3_COD
					cCodSA1 := GetSxeNum('SA1', 'A1_COD')
					dbSelectArea("SA1")
					dbSetOrder(1)
					while dbSeek(xFilial("SA1")+cCodSa1+"00")
						Confirmsx8()
						cCodSA1 := GetSxeNum('SA1', 'A1_COD')
					enddo

					cLoja   := '00'
				else
					cCodSa1 := PB3->PB3_CODMAT // Cliente  faz parte de uma rede
					cLoja   := U_NextLoja(cCodSa1)
				endif

				dbSetOrder(1)

				if	U_AtuSa1("I", cCodSA1, cLOJA) // Incluir Cliente
					lSucesso := .T.
				else
					lSucesso := .F.
				endif

			Endif

			//Loga a acao
			if lSucesso

				//		cMensagem := "Codigo        : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				//		cMensagem += "Loja          : "+ cLOJA+chr(13) + chr(10)
				//		cMensagem += "Cliente       : "+ PB3->PB3_NOME+chr(13) + chr(10)
				//		cMensagem += "CNPJ/CPF      : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
				//		cMensagem += "Vendedor      : "+ Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD")+;
				//		"-"+Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_NOME")	+chr(13) + chr(10)
				//		cMensagem += "Vendedor      : "+ GetAdvFVal("SA3","A3_COD",xFilial("SA3")+PB3->PB3_VEND,7)+;
				//		"-"+GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+PB3->PB3_VEND,7)	+chr(13) + chr(10)
				//		if Empty(PB3->PB3_CODRED)
				//			cMensagem += "Limite Aprov. : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
				//		else
				//			cMensagem += "Rede          : "+ PB3->PB3_CODRED+chr(13) + chr(10)
				//			cMensagem += "Limite Aprov. : "+ Alltrim(Transform(U_LimRede(PB3->PB3_CODRED),"@E 999,999,999.99"))+chr(13) + chr(10)
				//		endif
				//		cMensagem += "Prazo         : "+ PB3->PB3_COND +"-"+Posicione("SE4",1,xFilial("SE4")+PB3->PB3_COND,"E4_DESCRI")+chr(13) + chr(10)
				//		cMensagem += "Prazo         : "+ PB3->PB3_COND +"-"+GetAdvFval("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
				//
				//		cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)

				If !Empty( PB3->PB3_CODSA1 ) .and. lDesbloq //incluido lDesbloq em 02/08/16 chamado 029853
					DbSelectArea( 'SA1' )
					DbSetOrder(1)

					If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1))

						RecLock( 'SA1', .F. )
						SA1->A1_MSBLQL 	:= '2'
						SA1->A1_DTREAT 	:= dDataBase
						// Ricardo Lima-04/02/2019-CH:046840
						// Ricardo Lima-31/01/2019-CH:046840
						cStsCli := '2'

						If !Empty(SA1->A1_ULTCOM) .and. cBloqueio = "1" .and. SA1->A1_ROTEIRO <> '200' && Sigoli Chamado 031202  02/03/2017
							SA1->A1_ROTEIRO = '199' 	
						EndIf

						SA1->( MsUnLock())
						_aArea:=GetArea()
						U_RESPM001("SA1",4, SA1->(Recno()), .F. )
						RestArea(_aArea)

					Endif

				Endif

				// Atualiza os dados da Rede Caso exista.
				If !Empty( PB3->PB3_CODRED )

					lTemRede := .F.
					lMatriz  := .F.

					DbSelectArea( 'SZF' )
					dbGoTop()
					DbSetOrder( 3 )

					If SZF->( DbSeek( xFilial('SZF') + PB3->PB3_CODRED))

						_lAchou   := .T.   //&&checa CNPJ
						_lSemLim  := .T.   //&&checa registros sem ter nenhum com limite cadastrado - Mauricio - 13/07/16
						While !SZF->( EOF()) .And. SZF->ZF_FILIAL = xFilial("SZF") .And. SZF->ZF_REDE = PB3->PB3_CODRED
							IF SZF->ZF_CGCMAT == Left( PB3->PB3_CGC, 8 )
								_lAchou := .F.
							Endif

							RecLock( 'SZF',.F.)

							IF SZF->ZF_LCREDE > 0     &&condição Alberto aonde só atualizaria quando ja existisse limite cadastrado					

								u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 1","FINANCEIRO","ADOA005",;
    		      							"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(PB3->PB3_LIMAPR),ComputerName(),LogUserName())

								SZF->ZF_LCREDE	:= PB3->PB3_LIMAPR
								_lSemLim := .F.

							ENDIF


							SZF->ZF_ZZDESCB := PB3->PB3_DESC   // WILLIAM COSTA CHAMADO 022332
							SZF->ZF_TPREDE  := PB3->PB3_TPREDE // WILLIAM COSTA CHAMADO 022332
							//SZF->ZF_NOMERED := PB3->PB3_NOMERE // WILLIAM COSTA CHAMADO 022332
							SZF->( MsUnLock() )
							lMatriz := .T.

							SZF->( DbSkip() )
						Enddo
						IF _lSemLim                            &&passou na rede no SZF e nao encontrou nenhum registro com limite.				                                       
							DbSelectArea( 'SZF' )              &&É preciso incluir um limite para o primeiro registro Mauricio - 13/07/16 - Chamado 029660
							dbGoTop()
							DbSetOrder( 3 )
							If SZF->( DbSeek( xFilial('SZF') + PB3->PB3_CODRED))

								u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 2","FINANCEIRO","ADOA005",;
    		      							"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(PB3->PB3_LIMAPR),ComputerName(),LogUserName())

								RecLock( 'SZF',.F.)
								SZF->ZF_LCREDE	:= PB3->PB3_LIMAPR			           
								SZF->( MsUnLock() )
							Endif
						Endif
						IF _lAchou    &&se continua true é porque o CNPJ é novo para a rede(NOVA LOJA na rede) e precisa incluir registro na SZF

							u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 3","FINANCEIRO","ADOA005",;
    		      						"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(0),ComputerName(),LogUserName())

							RecLock( 'SZF',.T.)
							SZF->ZF_REDE    := PB3->PB3_CODRED
							SZF->ZF_CGCMAT  := Left( PB3->PB3_CGC, 8 )
							SZF->ZF_LCREDE  := 0
							SZF->ZF_ZZDESCB := PB3->PB3_DESC   // WILLIAM COSTA CHAMADO 022332
							SZF->ZF_TPREDE  := PB3->PB3_TPREDE // WILLIAM COSTA CHAMADO 022332
							SZF->ZF_NOMERED := PB3->PB3_NOMERE // WILLIAM COSTA CHAMADO 022332
							SZF->ZF_COZINDL := If( Alltrim(PB3->PB3_SUBSEG) $ '51 52 53', 'S', 'N')
							PB3->PB3_TPREDE
							SZF->( MsUnLock() )
						Endif

					Else       

						u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 4","FINANCEIRO","ADOA005",;
    		      					"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(PB3->PB3_LIMAPR),ComputerName(),LogUserName())

						RecLock( 'SZF',	.T. )
						SZF->ZF_FILIAL	:= xFilial('SZF')
						SZF->ZF_REDE	:= PB3->PB3_CODRED
						SZF->ZF_NOMERED	:= PB3->PB3_NOME
						SZF->ZF_CGCMAT	:= Left( PB3->PB3_CGC, 8 )
						SZF->ZF_ZZDESCB := PB3->PB3_DESC // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_TPREDE  := PB3->PB3_TPREDE // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_NOMERED := PB3->PB3_NOMERE // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_LCREDE	:= PB3->PB3_LIMAPR


						SZF->ZF_ZZDESCB := PB3->PB3_DESC // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_TPREDE  := PB3->PB3_TPREDE // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_NOMERED := PB3->PB3_NOMERE // WILLIAM COSTA CHAMADO 022332


						SZF->ZF_COZINDL	:= If( Alltrim(PB3->PB3_SUBSEG) $ '51 52 53', 'S', 'N') //Cozinha Industrial devem possuir o subsegmento 51, 52 ou 53 Chamado 020821
						SZF->ZF_ZZDESCB := PB3->PB3_DESC // WILLIAM COSTA CHAMADO 022332
						SZF->ZF_TPREDE  := If( Alltrim(PB3->PB3_SUBSEG) $ '51 52 53', 'C', PB3->PB3_TPREDE) //Cozinha Industrial devem possuir o subsegmento 51, 52 ou 53 Chamado 020821 TAMBEM WLLIAM COSTA CHAMADO 022332
						SZF->ZF_NOMERED := PB3->PB3_NOMERE // WILLIAM COSTA CHAMADO 022332


						SZF->( MsUnLock() )

					Endif
					
					// *** INICIO WILLAM COSTA 12/06/2019 CHAMADO 049532 || OS 050844 || FINANCAS || ANDREA || 8319 || APROVACAO DE LIMITES
					
					// *** INICIO WILLIAM COSTA 27/06/2019 050045 || OS 051350 || FINANCAS || TATIANE || 8351 || REDE DUPLICANDO
					//Inicio Descobrir se e uma rede com dois ou mais CNPJS diferentes ou nao   
					ncontCNPJ := 0
					
					_cQuery4 := ''
					_cQuery4 := " SELECT ZF_REDE, COUNT(*) QTDE "
					_cQuery4 += "   FROM " + RETSQLNAME("SZF") + " "
					_cQuery4 += "  WHERE ZF_REDE     = '" + PB3->PB3_CODRED + "' "
					_cQuery4 += "    AND D_E_L_E_T_ <> '*' "
					_cQuery4 += "  GROUP BY ZF_REDE "
					_cQuery4 += " HAVING  COUNT(*) > 1 "
					
					DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery4), "TRC", .F., .T. )
					DBSELECTAREA( "TRC" )
					DBGOTOP()
					
					WHILE !TRC->(EOF())
			
						ncontCNPJ := TRC->QTDE
			
						TRC->(DBSKIP())
					ENDDO
					TRC->(dbCloseArea())
					
					//Final Descobrir se e uma rede com dois ou mais CNPJS diferentes  
					
					IF ncontCNPJ < 2 //SIGNIFICA QUE A REDE SO TEM UM CNPJ
					
						IF cLoja <> '00' //significa que nao e o pai entao precisa arrumar o limite do pai PB3 / SA1
						
							//atualizacao para PB3				
							_cQuery2:= ""
							_cQuery2:= " UPDATE " + RETSQLNAME("PB3") + " WITH(UPDLOCK) " 
							_cQuery2+= " SET PB3_LIMAPR                          =     " + CVALTOCHAR(PB3->PB3_LIMAPR) + " "		 
							_cQuery2+= " WHERE PB3_CODSA1                        =    '" + Alltrim(cCodSA1)            + "' "		
							_cQuery2+= "   AND PB3_LOJSA1                        = '00'"
							_cQuery2+= "   AND "+RETSQLNAME("PB3")+".D_E_L_E_T_ <> '*' "
				
							TCSQLExec(_cQuery2)
							_cQuery2:=""
							
							
							// MANDA O NOVO VALOR DA REDE PARA O PAI
							dbSelectArea("SA1")
							dbSetOrder(1)
							IF dbSeek(xFilial("SA1")+ cCodSA1 + '00', .T.)
							
								IF PB3->PB3_LIMAPR  > 0               .AND.;
								   SA1->A1_LC      <> PB3->PB3_LIMAPR
								   
									RecLock("SA1",.F.)
									SA1->A1_LC := PB3->PB3_LIMAPR
									msUnlock()
									
								ENDIF
							ENDIF
							DBCLOSEAREA("SA1")
							
							// ZERA O VALOR DA REDE PARA O FILHO
							dbSelectArea("SA1")
							dbSetOrder(1)
							IF dbSeek(xFilial("SA1")+ cCodSA1 + cLoja, .T.)
							
								IF PB3->PB3_LIMAPR  > 0               
								   
									RecLock("SA1",.F.)
									SA1->A1_LC := 0
									msUnlock()
									
								ENDIF
							ENDIF
							DBCLOSEAREA("SA1")
							
						ELSE // LOJA IGUAL A 00 ESSE E O PAI
						
							dbSelectArea("SA1")
							dbSetOrder(1)
							IF dbSeek(xFilial("SA1")+ cCodSA1 + cLoja, .T.)
							
								IF PB3->PB3_LIMAPR  > 0               .AND.;
								   SA1->A1_LC      <> PB3->PB3_LIMAPR
								   
									RecLock("SA1",.F.)
									SA1->A1_LC := PB3->PB3_LIMAPR
									msUnlock()
									
								ENDIF
							ENDIF
							DBCLOSEAREA("SA1")
						
						ENDIF
						
					ELSE // SIGNIFICA QUE TEM MAIS DE UM CNPJ NA REDE
					
						//INICIO IDENTIFICAR QUAL CNPJ TEM VALOR DE LIMITE
						_cQuery5 := ''
						_cQuery5 := " SELECT TOP(1) R_E_C_N_O_,ZF_REDE,ZF_CGCMAT,ZF_NOMERED,ZF_LCREDE "
						_cQuery5 += "   FROM " + RETSQLNAME("SZF") + " "
						_cQuery5 += "  WHERE ZF_REDE     = '" + PB3->PB3_CODRED + "' "
						_cQuery5 += "    AND ZF_LCREDE   > 0 "
						_cQuery5 += "    AND D_E_L_E_T_ <> '*' "
						_cQuery5 += " ORDER BY " + RETSQLNAME("SZF") + ".R_E_C_N_O_ "
						
						DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery5), "TRD", .F., .T. )
						DBSELECTAREA( "TRD" )
						DBGOTOP()
						
						WHILE !TRD->(EOF())
				
							cCgcRaizPai := TRD->ZF_CGCMAT
							
							TRD->(DBSKIP())
						ENDDO
						TRD->(dbCloseArea())
						
						//FINAL IDENTIFICAR QUAL CNPJ TEM VALOR DE LIMITE
						
						IF ALLTRIM(cCgcRaizPai) <> ''
						
							//INICIO REGRA DE LIMITE
							
							MsgAlert("Identificado que essa rede tem mais de um CNPJ, todos os CNPJ's serão ajustados o Limite para: " + CVALTOCHAR(PB3->PB3_LIMAPR) ,"ADOA005")
					
							nNewLimapr := PB3->PB3_LIMAPR
							
							
							// inicio zera os limites salvos
							_cQuery2:= ""
							_cQuery2:= " UPDATE " + RETSQLNAME("PB3") + " WITH(UPDLOCK) " 
							_cQuery2+= " SET PB3_LIMAPR                          = 0 " 		 
							_cQuery2+= " WHERE PB3_CODRED                        = '" + Alltrim(PB3->PB3_CODRED)  + "' "		
							_cQuery2+= "   AND "+RETSQLNAME("PB3")+".D_E_L_E_T_ <> '*' "
				
							TCSQLExec(_cQuery2)
							
							_cQuery2:= ""
							_cQuery2:= " UPDATE " + RETSQLNAME("SA1") + " WITH(UPDLOCK) " 
							_cQuery2+= " SET A1_LC                               = 0 "		 
							_cQuery2+= " WHERE A1_CODRED                         = '" + Alltrim(PB3->PB3_CODRED)  + "' "		
							_cQuery2+= "   AND "+RETSQLNAME("SA1")+".D_E_L_E_T_ <> '*' "
				
							TCSQLExec(_cQuery2)
							
							// final zera os limites salvos
							
							// inicio atualizacao do novo limite para a rede pai
							// Descobrir o PB3_CODSA1 e PB3_CODLOJA do CNPJ PAI
							_cQuery6 := ''
							_cQuery6 := " SELECT TOP(1) PB3_CODSA1,PB3_LOJSA1 "
							_cQuery6 += "   FROM " + RETSQLNAME("PB3") + " "
							_cQuery6 += "  WHERE LEFT(PB3_CGC,8)  = '" + cCgcRaizPai + "' "
							_cQuery6 += "    AND PB3_LOJSA1       = '00' "
							_cQuery6 += "    AND D_E_L_E_T_      <> '*' "
							_cQuery6 += "    ORDER BY R_E_C_N_O_ "
							
							DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery6), "TRE", .F., .T. )
							DBSELECTAREA( "TRE" )
							DBGOTOP()
							
							WHILE !TRE->(EOF())
					
								//atualizacao para PB3				
								_cQuery2:= ""
								_cQuery2:= " UPDATE " + RETSQLNAME("PB3") + " WITH(UPDLOCK) " 
								_cQuery2+= " SET PB3_LIMAPR                          =     " + CVALTOCHAR(PB3->PB3_LIMAPR) + " "		 
								_cQuery2+= " WHERE PB3_CODSA1                        =    '" + Alltrim(TRE->PB3_CODSA1)    + "' "		
								_cQuery2+= "   AND PB3_LOJSA1                        = '00'"
								_cQuery2+= "   AND "+RETSQLNAME("PB3")+".D_E_L_E_T_ <> '*' "
					
								TCSQLExec(_cQuery2)
								_cQuery2:=""
								
								// MANDA O NOVO VALOR DA REDE PARA O PAI
								dbSelectArea("SA1")
								dbSetOrder(1)
								IF dbSeek(xFilial("SA1")+ TRE->PB3_CODSA1 + '00', .T.)
										
										RecLock("SA1",.F.)
										SA1->A1_LC := PB3->PB3_LIMAPR
										msUnlock()
									
								ENDIF
								DBCLOSEAREA("SA1")

								u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 5","FINANCEIRO","ADOA005",;
											"CNPJ: "+ SUBSTR(PB3->PB3_CGC,1,8) + " Saldo de: " + CVALTOCHAR(PB3->PB3_LIMAPR) + " Saldo para: " + CVALTOCHAR(0),ComputerName(),LogUserName())
								
								//ZERA TODA A REDE
								_cQuery3:= " UPDATE 	"+retsqlname("SZF")+" WITH(UPDLOCK) "
								_cQuery3+= "    SET ZF_LCREDE = 0 "		 
								_cQuery3+= " WHERE   "
								_cQuery3+= " ZF_REDE = '" + Alltrim(PB3->PB3_CODRED) + "' "		
								_cQuery3+= " AND "+RETSQLNAME("SZF")+".D_E_L_E_T_=' ' "
								
								TCSQLExec(_cQuery3)

								u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 6","FINANCEIRO","ADOA005",;
											"CNPJ Posicionado: "+ SUBSTR(PB3->PB3_CGC,1,8) + " CNPJ PAI: " + cCgcRaizPai + " Saldo de: " + CVALTOCHAR(0) + " Saldo para: " + CVALTOCHAR(PB3->PB3_LIMAPR),ComputerName(),LogUserName())
								
								//COLOCA O VALOR DA REDE SO NO PAI
								_cQuery3:=" UPDATE 	"+retsqlname("SZF")+" WITH(UPDLOCK) "		 
								_cQuery3+= "    SET ZF_LCREDE = " + CVALTOCHAR(PB3->PB3_LIMAPR)	
								_cQuery3+=" WHERE   "
								_cQuery3+=" ZF_CGCMAT = '" + cCgcRaizPai + "' "		
								_cQuery3+=" AND "+RETSQLNAME("SZF")+".D_E_L_E_T_=' ' "
								
								TCSQLExec(_cQuery3)
								
								TRE->(DBSKIP())
							ENDDO
							TRE->(dbCloseArea())
							
							// final atualizacao do novo limite para a rede pai
							//FINAL REGRA DE LOJA
						
						ENDIF
						
					ENDIF
					
					// *** FINAL WILLAM COSTA 12/06/2019 CHAMADO 049532 || OS 050844 || FINANCAS || ANDREA || 8319 || APROVACAO DE LIMITES
					// *** FINAL WILLIAM COSTA 27/06/2019 050045 || OS 051350 || FINANCAS || TATIANE || 8351 || REDE DUPLICANDO
				ENDIF

				If cOpcao = "INCLUSAO"  && Sigoli 08/03/2017 chamado 031202 - 031202
					U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, 'Gerou Cliente', '', cCodSA1 ) 
				EndIf

				RecLock('PB3', .F.)
				PB3->PB3_CODSA1 := cCodSa1
				PB3->PB3_LOJSA1 := cLoja
				PB3->PB3_VENENC := ''
				PB3->PB3_PRIOR  := '2'
				PB3->PB3_SITUAC := ' '

				if !Empty( PB3->PB3_CODRED ) .AND. PB3->PB3_LOJSA1 <> '00'
					PB3->PB3_LIMAPR := 0
				endif

				PB3->( MsUnLock() )

				while __lSX8
					Confirmsx8()
				enddo 


				//rotina de desbolqueio de cliente, apenas chamada para alguns supervisores  //chamado 034158 sigoli 20/03/2017
				If cBloqueio  = '1' .and. ldesBloq == .T.
					AdoDesbloq( cCodSA1,cLoja,nLimAprov,cCondPag)
				EndIf

				//rotina de solicitação de motivo do desbloqueio, solicitado para apenas alguns supervidores	
				If cOpcao = "INCLUSAO"  && Sigoli 24/03/2017 chamado 034280
					AdoDesbloq(PB3->PB3_CODSA1,PB3->PB3_LOJSA1,PB3->PB3_LIMAPR,PB3->PB3_COND) //chamado 034158 sigoli 20/03/2017
				EndIf

				MessageBox("Registro gravado com sucesso","",MB_ICONASTERISK)

				//Grava LOG
				U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Integracao", "Atualizado com sucesso!", " " ) //Chamado 036175 - Fernando Sigoli 13/07/2017 


				If __lEnvMail1
					CriaMail(__cMyPara, __cMyAssunto, __cMyMsg, /*''*/,, .F., .T., __cMyCodCli, __cMyLojaCli)
				Endif

				cMensagem := "Codigo        : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				cMensagem += "Loja          : "+ cLOJA+chr(13) + chr(10)
				cMensagem += "Cliente       : "+ PB3->PB3_NOME+chr(13) + chr(10)
				cMensagem += "CNPJ/CPF      : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
				cMensagem += "Vendedor      : "+ GetAdvFVal("SA3","A3_COD",xFilial("SA3")+PB3->PB3_VEND,7)+;
				"-"+GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+PB3->PB3_VEND,7)	+chr(13) + chr(10)
				if Empty(PB3->PB3_CODRED)
					cMensagem += "Limite Aprov. : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
				else
					cMensagem += "Rede          : "+ PB3->PB3_CODRED+chr(13) + chr(10)
					cMensagem += "Limite Aprov. : "+ Alltrim(Transform(U_LimRede(PB3->PB3_CODRED),"@E 999,999,999.99"))+chr(13) + chr(10)
				endif
				cMensagem += "Prazo         : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)

				cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)
				// Ricardo Lima-14/02/2019-CH:046840
				//cMensagem += "Status          : "+ IIF(cStsCli='1','Bloqueado','Ativo')

				//Everson - 05/03/2018. Chamado 037261. SalesForce.
				If cOpcao = "INCLUSAO"
					cUpZC6 := " UPDATE " + RetSqlName("ZC6") + " SET ZC6_CODCLI = '" + cCodSa1 + "', ZC6_LOJA = '" + cLoja + "' WHERE ZC6_FILIAL = '" + xFilial("SA1") + "' AND ZC6_CODPB3 = '" + Alltrim(cValToChar(cCodCli)) + "' AND ZC6_LJPB3 = '" + Alltrim(cValToChar(cLojaCli)) + "' AND D_E_L_E_T_ = '' "
					TCSqlExec(cUpZC6)

					cUpZBC := " UPDATE " + RetSqlName("ZBC") + " SET ZBC_CODCLI = '" + cCodSa1 + "', ZBC_LOJA = '" + cLoja + "' WHERE ZBC_FILIAL = '" + xFilial("SA1") + "' AND ZBC_CODPB3 = '" + Alltrim(cValToChar(cCodCli)) + "' AND ZBC_LJPB3 = '" + Alltrim(cValToChar(cLojaCli)) + "' AND D_E_L_E_T_ = '' "
					TCSqlExec(cUpZBC)

				EndIf	
				//
				// Ricardo Lima-31/01/2019-CH:046840
				//Envia e-mail
				CriaMail(cPara, 'CADASTRO APROVADO', cMensagem, ,, .F., .T.,cCodCli, cLojaCli )

				lSales := .T.

			else

				DisarmTransaction()

				U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, 'Erro na Inclusão Cliente', '', cCodSA1 )
				Alert( 'Registro Não gravado' )
				while __lSX8
					RollBackSX8()
				enddo

			endif 


		Else
			Alert( 'Para a inclusão do cliente no Protheus, é necessário que o mesmo esteja aprovado.' )
		Endif


	End Transaction

	//Everson - 30/01/2018. Chamado 037261.
	If lSales .And. ! Empty(Alltrim(cValToChar(PB3->PB3_CODSA1))) .And. ! Empty(Alltrim(cValToChar(PB3->PB3_LOJSA1)))

		/***** Envio de cadastros ao SalesForce *****/
		//Everson - 22/01/2018. Chamado 037261 - Envia cadastro de cliente.
		If Findfunction("U_ADVEN076P")
			U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.)

		EndIf

		//Everson - 22/01/2018. Chamado 037261 - Envia parecer.
		If cOpcao = "INCLUSAO" .Or. cOpcao = "ALTERACAO" .And. !Empty(Alltrim(cValToChar(PB3->PB3_CODSA1))) .And. !Empty(Alltrim(cValToChar(PB3->PB3_LOJSA1)))
			If Findfunction("U_ADVEN052P")
				
				//
				If chkSA1SF(Alltrim(cValToChar(PB3->PB3_CODSA1)),Alltrim(cValToChar(PB3->PB3_LOJSA1))) //Verifica se o cadastro do cliente já foi enviado para o SalesForce.
					U_ADVEN052P(PB3->PB3_COD,PB3->PB3_LOJA,.F., "","D")
				
				EndIf

			EndIf

		EndIf
		/*******************************************/

	EndIf
	//

	RestArea( aArea )

Return Nil

/*{Protheus.doc} Static Function ADOAPOSIC
	Informa a posicao do cliente (funcao padrao do financeiro)
	@type  Function
	@author Vogas Junior
	@since 29/09/2009
	@version 01
	@history 
*/

Static Function AdoaPosic( cCodCli, cLojaCli )

	Local aArea 	:= GetArea()
	//Local cCodSA1 	:= Posicione( 'PB3', 1, xFilial('PB3') + cCodCli + cLojaCli, 'PB3_CODSA1' )
	Local cCodSA1 	:= GetAdvFVal( 'PB3', 'PB3_CODSA1', xFilial('PB3') + cCodCli + cLojaCli, 1 )
	Local cLOJA	    := cLojaCli

	Private cCadastro	:= 'Visualização da Posição do Cliente'
	If Empty( cCodSA1 )
		Alert( 'Cliente ainda nao cadastrado.')
	Else
		DbSelectArea( 'SA1')

		//chamada da função para atualizar/refaz clientes
		If Alltrim(GETMV("MV_#REFAZ")) == '.T.'  
			U_ADFIN035P(cCodSA1)
		EndIf

		SA1->( DbSetOrder( 1 ) )
		If SA1->( DbSeek( xFilial( 'SA1' ) + cCodSA1 + cLOJA ))
			//chama a funcionalidade de posicao do cliente 
			aRotina	:=	{{"Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
			{"Visualizar", "AxVisual" , 0 , 2},;  //"Visualizar"
			{"Consultar", "FC010CON" , 0 , 2},;  //"Consultar"
			{"Impressao", "FC010IMP" , 0 , 4}}   //"Impressao"
			Pergunte("FIC010",.T.)
			fc010con( 'SA1', SA1->( Recno() ), 2 )
		Endif
	Endif

	RestArea( aArea )

Return NIL

/*{Protheus.doc} Static Function ADOA5QTD
	Permite que apresenta a quantidade de registros na tela separados por motivo
	@type  Function
	@author Vogas Junior
	@since 16/10/2009
	@version 01
	@history 
*/

Static Function Adoa5Qtd( aHeader, aCols )

	Local aArea		:= GetArea()
	Local oDlg
	Local oListBox
	Local nCodcli 	:= Ascan( aHeader, {|x| AllTrim( x[2] ) == 'PB3_COD' })
	Local nLojaCli	:= Ascan( aHeader, {|x| AllTrim( x[2] ) == 'PB3_LOJA' })
	Local nMotivo 	:= Ascan( aHeader, {|x| AllTrim( x[2] ) == 'PB3_MOTACE' })
	Local aQuant	:= {}
	Local cMotivo	:= ''
	Local nQuant	:= 0
	Local i			:= 0
	Local aCols2	:= aClone( aCols )
	Local cDescricao := ''

	ASort( aCols2,,,{|x,y| x[ nMotivo ] < y[ nMotivo ] } )

	cMotivo := Left( aCols2[ 1, nMotivo ], 2 )

	For i:= 1 To len( aCols2 )
		If Left( aCols2[ i, nMotivo ], 2 ) == cMotivo
			nQuant += 1
		Else
			//		cDescricao := Posicione( 'PB4', 1, xFilial('PB4') + cMotivo, 'PB4_DESCRI')
			cDescricao := GetAdvFVal( 'PB4', 'PB4_DESCRI', xFilial('PB4') + cMotivo, 1)
			aAdd( aQuant,{ cMotivo, cDescricao, nQuant})
			nQuant := 1
			cMotivo := Left( aCols2[ i, nMotivo ], 2 )
		Endif
	Next i
	If nQuant > 0
		//	cDescricao := Posicione( 'PB4', 1, xFilial('PB4') + cMotivo, 'PB4_DESCRI')
		cDescricao := GetAdvFVal( 'PB4', 'PB4_DESCRI', xFilial('PB4') + cMotivo, 1)
		aAdd( aQuant,{ cMotivo, cDescricao, nQuant})
	Endif

	DEFINE MSDIALOG oDlg TITLE "Quantidades Por Motivos" FROM 00,00 To 280,400 OF oMainWnd PIXEL

	@ 01,01 ListBox oListBox Fields HEADER "Codigo ","Motivo", "Quantidade" Size 200 , 140 Of oDlg Pixel
	oListBox:SetArray(aQuant)
	oListBox:bLine := {|| { aQuant[oListBox:nAT,01], aQuant[oListBox:nAT,02], aQuant[oListBox:nAT,03]}}

	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()},.F.,)

	RestArea( aArea )

Return Nil

/*{Protheus.doc} Static Function ADOBLOQ
	Realiza bloqueio e desbloqueio do cliente
	@type  Function
	@author Vogas Junior
	@since 16/10/2009
	@version 01
	@history 
*/

Static Function AdoBloq( cCliente, cLoja )

	Local oDlg2			:= NIL
	Local oListBox2   	:= NIL
	Local aArea 		:= GetArea()
	Local aMotBloq 		:= {}
	Local nOpcao		:= 0
	Local cBloqueio		:= GetAdvFVal( 'PB3', 'PB3_BLOQUE', xFilial( 'PB3' ) + cCliente + cLoja, 1)
	local i				:= 0
	Local cNomeUsr		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara			:= SuperGetMv("FS_MOVMAIL", .F., 0 )
	Local cNivelUsr 	:= GetAdvFVal("PB1", "PB1_NIVEL", xFilial("PB1") +__cUserId, 1, " ")
	Local cNivelCrd 	:= SuperGetMv("FS_NIVCRED", .F., '4')
	Local cCC  			:= GetAdvFVal("SA3", "A3_EMAIL",xFilial("SA3")+PB3->PB3_VEND, 7)

	//Everson - 09/06/2020. Chamado 058848.
	Local nNumPed		:= 0
	Local cMsgPed		:= ""
	//

	DbSelectArea( 'PB3' )
	PB3->( dbSetOrder( 1 ))
	PB3->( dbSeek( xFilial( 'PB3' ) + cCliente + cLoja ))

	dbSelectArea("SA3")
	dbSetOrder(7)
	dbSeek(xFilial("SA3")+PB3->PB3_VEND)
	cCC := AllTrim(SA3->A3_EMAIL)
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+SA3->A3_SUPER) // Supervisor
	if !Empty(AllTrim(SA3->A3_EMAIL))
		cCC += ";"+AllTrim(SA3->A3_EMAIL)
	endif 

	if cNivelUsr < cNivelCrd
		Alert("Usuário não possui privilégios para Bloquear ou Desbloquear Cliente")
		return
	endif

	dbSelectArea("SA1")
	dbSetOrder(1)
	if !dbSeek(xFilial("SA1")+PB3->(PB3_CODSA1+PB3_LOJSA1))  //chamado 030469 - sigoli
		Alert("Cliente não incluido no Protheus. Não será possivel bloquear.")
		RestArea( aArea )
		return
	endif

	//Everson - 09/06/2020. Chamado 058848.
	nNumPed := getNumPed(PB3->PB3_CODSA1,PB3->PB3_LOJSA1)
	cMsgPed := ""
	If nNumPed > 0
		cMsgPed := " possui " + cValtoChar(nNumPed) + " pedido(s) em aberto(s)"

	EndIf
	//

	If Alltrim( cBloqueio) == '1'

		If Aviso('Atenção','Cliente '+PB3->PB3_CODSA1+"-"+PB3->PB3_LOJSA1+' já bloqueado' + Iif( Empty(Alltrim(PB3->PB3_VENENC)) ,'',' e possui encaminhamento de solicitação vinculado, que será perdido caso ocorra o desbloqueio') +; //Everson - 23/04/2020. Chamado 055871
		         '. Deseja desbloqueá-lo?',{'Sim','Não'},2) == 1 //chamado 030469 - sigoli. 

			DbSelectArea( 'PB3' )
			PB3->( dbSetOrder( 1 ))
			If PB3->( dbSeek( xFilial( 'PB3' ) + cCliente + cLoja ))
				//Grava LOG
				U_Ado05Log( cCliente, cLoja, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ), 'Bloqueado'/*PB3->PB3_BLOQUE*/, 'Desbloqueado'/*'2'*/ ) 

				RecLock( 'PB3', .F. )
				PB3->PB3_BLOQUE	:= '2'
				PB3->PB3_MOTBLQ	:= ''
				PB3->PB3_MOTREJ	:= ''
				PB3->PB3_SITUAC	:= ' '
				PB3->PB3_DTENVI := Ctod('')
				PB3->PB3_VENENC := ' '
				PB3->( MsUnLock())

				//Desbloquear tambem no cadastro de clientes
				If !Empty( PB3->PB3_CODSA1 )
					DbSelectArea( 'SA1' )
					SA1->( DbSetOrder(1) )
					//If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJA))  //chamado 030469 - sigoli
					If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1))  //chamado 030469 - sigoli
						RecLock( 'SA1', .F. )
						SA1->A1_MSBLQL  := '2'
						SA1->A1_DTREAT  := dDataBase
						SA1->A1_XMOTBLQ := '' // WILLIAM COSTA 28/08/2019 - CHAMADO 049742 || OS 051025 || FINANCAS || ANDREA || 8319 || SA1 X PB3
						// Ricardo Lima-04/02/2019-CH:046840
						// Ricardo Lima-31/01/2019-CH:046840
						cStsCli := '2'

						If !Empty(SA1->A1_ULTCOM) .and. SA1->A1_ROTEIRO <> '200' && Sigoli Chamado 031202  02/03/2017
							SA1->A1_ROTEIRO := "199"
						EndIF

						SA1->( MsUnLock())
						_aArea:=GetArea()
						U_RESPM001("SA1",4, SA1->(Recno()), .F. )   
						RestArea(_aArea)
					Endif
				Endif
				// 

				//INICIO : chamado 030469 - sigoli
				//Grava Ocorrencia no parecer do Cliente
				DbSelectArea( 'PBA' )
				RecLock( 'PBA', .T. )
				PBA_FILIAL	:= xFilial('PBA')
				PBA_CODCLI	:= cCliente
				PBA_LOJACL	:= cLoja
				PBA_NIVEL	:= '1'
				PBA_USUARI	:= __cUserId
				PBA_NOME	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
				PBA_DATA	:= dDatabase
				PBA_HORA	:= TIME()
				MSMM(,TamSx3("PBA_PARECE")[1],,"DESBLOQUEADO PELA ROTINA MANUAL",1,,,"PBA","PBA_CODMEM")
				PBA->( MsUnLock())
				//FIM: chamado 030469 - sigoli

				cMensagem 	:= 	'O cliente ' + PB3->PB3_CODSA1 + ' - ' + PB3->PB3_NOME + ' Loja ' + PB3->PB3_LOJSA1 + cNomeUsr+chr(13) + chr(10)+;   //chamado 030469 - sigoli
				'Foi desbloqueado em ' + DtoC( dDatabase ) + ' Por ' + cNomeUsr+chr(13) + chr(10)  
				cMensagem := "Codigo          : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				//cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)   //chamado 030469 - sigoli
				cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)     //chamado 030469 - sigoli
				cMensagem += "Cliente         : "+ PB3->PB3_NOME+chr(13) + chr(10)
				cMensagem += "CNPJ/CPF        : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
				cMensagem += "Vendedor        : "+ GetAdvFval("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
				"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
				cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
				cMensagem += "Prazo           : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
				cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)
				// Ricardo Lima-14/02/2019-CH:046840
				//cMensagem += "Status          : "+ IIF(cStsCli='1','Bloqueado','Ativo')

				// Ricardo Lima-31/01/2019-CH:046840
				CriaMail(cPara, 'Cliente Desbloqueado', cMensagem, /*''*/,cCC, .T., .T., cCliente, cLoja)

				//rotina de solicitação de motivo do desbloqueio, solicitado para apenas alguns supervidores	
				AdoDesbloq(PB3->PB3_CODSA1,PB3->PB3_LOJSA1,PB3->PB3_LIMAPR,PB3->PB3_COND) //chamado 034158 sigoli 20/03/2017

				//Everson - 05/03/2018. Chamado 037261. SalesForce.
				If FindFunction("U_ADVEN076P")

					U_ADVEN076P(PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,.F.,"","LIBFIN",.T.," Cliente desbloqueado. ")

				EndIf

				Alert( 'Cliente Desbloqueado')

				// Chamado n. 052448 || OS 053799 || FINANCAS || TATIANE || 8351 || CAD. CLIENTE - fwnm - 11/10/2019
			    If msgYesNo("Além deste cliente, deseja desbloquear (em lote) as demais lojas deste CNPJ Raiz ?")
					MsAguarde( {|| AdDesBlqLt( cCliente, cLoja, cNomeUsr )}, "Aguarde... Desbloqueando em lote...","Clientes com CNPJ Raiz = " + Left(AllTrim(PB3->PB3_CGC),8) )			    	
					//AdDesBlqLt( cCliente, cLoja, cNomeUsr, cPara, cCC )
				EndIf
				//

			Endif

		Endif

	Else

		//Everson - 29/07/2020. Chamado 060134.
		If nNumPed > 0
			MsgStop('Cliente '+PB3->PB3_CODSA1+"-"+PB3->PB3_LOJSA1+'' + cMsgPed + ". Não será possível bloqueá-lo.")
			RestArea( aArea )
			Return Nil

		EndIf
		//

		If Aviso('Atenção','Deseja Realmente Bloquear o Cliente '+PB3->PB3_CODSA1+"-"+PB3->PB3_LOJSA1+'' + cMsgPed + ' ?',{'Sim','Não'},2) == 1 //chamado 030469 - sigoli
			cBlq01 := ""
			cBlq02 := ""

			DbSelectArea( 'PB5' ) 
			PB5->( dbSetOrder( 1 ))
			PB5->( DbGoTop())
			While ! PB5->( Eof()) .And. PB5->PB5_FILIAL == xFilial( 'PB5' ) 
				If PB5->PB5_GRUPO =  '1' .or. PB5->PB5_GRUPO =  '3'  
					aAdd( aMotBloq,{ PB5->PB5_CODIGO, PB5->PB5_DESCRI } )
				EndIF
				PB5->( dbSkip())
			Enddo

			DEFINE MSDIALOG oDlg2 TITLE "Motivo do Bloqueio" FROM 00,00 To 340,440 OF oMainWnd PIXEL

			@ 020,010 ListBox oListBox2 Fields HEADER "Codigo", "Motivo" Size 200, 140 Of oDlg2 Pixel
			oListBox2:SetArray( aMotBloq )
			oListBox2:bLine := {|| { aMotBloq[ oListBox2:nAT, 01 ], aMotBloq[ oListBox2:nAT, 02 ] }}

			ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{||nOpcao:=1, cBlq01 := aMotBloq[oListBox2:nAT,01], cBlq02 := aMotBloq[oListBox2:nAT,02], (	AdoGrvBloq( cCliente, cLoja, aMotBloq[oListBox2:nAT,01], aMotBloq[oListBox2:nAT,02], cCC), oDlg2:End())},{||nOpcao:=0,oDlg2:End()},.F.,)

			// Chamado n. 052448 || OS 053799 || FINANCAS || TATIANE || 8351 || CAD. CLIENTE - fwnm - 11/10/2019
		    If nOpcao == 1
			    If msgYesNo("Além deste cliente, deseja bloquear (em lote) as demais lojas deste CNPJ Raiz ?")
					AdoBloqLt( cCliente, cLoja, cBlq01, cBlq02, cCC)
			    EndIf
			EndIf
			//

		EndIf

	Endif

	RestArea( aArea )

Return Nil
/*/{Protheus.doc} getNumPed
	Verifica se há pedido de saída para cliente
	com data de entrega igual ou maior que hoje. Chamado 058848 .
	@type  Static Function
	@author Everson
	@since 09/06/2020
	@version 01
	/*/
Static Function getNumPed(cCod,cLoja)

	//Variáveis.
	Local aArea  := GetArea()
	Local cQuery := ""
	Local nNumPed:= 0

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " COUNT(DISTINCT C5_NUM) AS C5_NUMPED " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND C5_CLIENTE = '" + cCod + "' " 
	cQuery += " AND C5_LOJACLI = '" + cLoja + "' " 
	//cQuery += " AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE() AS DATE) " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND C5_NOTA = '' " 
	cQuery += " AND C5_SERIE = '' " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOA005 - getNumPed - cQuery " + cQuery )

	//
	If Select("D_SC5") > 0
		D_SC5->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_SC5"
	D_SC5->(DbGoTop())
		nNumPed := Val(cValToChar(D_SC5->C5_NUMPED))
	D_SC5->(DbCloseArea())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOA005 - getNumPed - nNumPed " + cValToChar(nNumPed) )

	//
	RestArea(aArea)

Return nNumPed
/*{Protheus.doc} Static Function ADOGRVBLOQ
	Grava a informacao de bloqueio
	@type  Function
	@author Sem autor
	@since 15/04/2010
	@version 01
	@history 
*/

Static Function AdoGrvBloq( cCodcli, cLojaCli, cMotivo, cDscMot, cCC)

	//Local cNomeUsr	:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara		:= SuperGetMv("FS_MOVMAIL", .F., 0 )

	DbSelectArea( 'PB3' )
	PB3->( dbSetOrder( 1 ))
	If PB3->( dbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))

		//Grava LOG
		U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ), /*PB3->PB3_BLOQUE*/ 'Desbloqueado', /*'1'*/ 'Bloqueado' )	 //chamado 030469 - sigoli
		U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_MOTBLQ', 'X3_Titulo' ), PB3->PB3_MOTBLQ, cMotivo+" - "+ cDscMot ) 					//chamado 030469 - sigoli


		cMensagem 	:= 	'O cliente ' + PB3->PB3_CODSA1 + ' - ' + PB3->PB3_NOME + ' Loja ' + PB3->PB3_LOJA + cNomeUsr+chr(13) + chr(10)+;
		'Foi bloqueado em ' + DtoC( dDatabase ) + ' Por ' + cNomeUsr+chr(13) + chr(10)+;
		"Motivo : "+cMotivo+" - "+ cDscMot
		RecLock( 'PB3', .F. )
		PB3->PB3_BLOQUE 	:= '1'
		PB3->PB3_MOTBLQ  	:= cMotivo
		PB3->PB3_SITUAC		:= '3'
		PB3->( MsUnLock())
		If !lBlqLote
			alert('Bloqueio realizado!')
		EndIf

		//bloquear tambem no cadastro de clientes
		If !Empty( PB3->PB3_CODSA1 )
			DbSelectArea( 'SA1' )
			SA1->( DbSetOrder(1) )
			//If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJA)) //chamado 030469 - sigoli
			If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1)) //chamado 030469 - sigoli

				RecLock( 'SA1', .F. )
				SA1->A1_MSBLQL  := '1'
				SA1->A1_XMOTBLQ := ALLTRIM(cMotivo) + ' - ' + cDscMot // WILLIAM COSTA 28/08/2019 - CHAMADO 049742 || OS 051025 || FINANCAS || ANDREA || 8319 || SA1 X PB3
				// Ricardo Lima-04/02/2019-CH:046840
				// Ricardo Lima-31/01/2019-CH:046840
				cStsCli := '1'
				SA1->( MsUnLock()) 
				_aArea:=GetArea()
				U_RESPM001("SA1",4, SA1->(Recno()), .F. )   
				RestArea(_aArea)
			Endif
		Endif

		//INICIO: chamado 030469 - sigoli
		//Grava Ocorrencia no parecer do Cliente
		DbSelectArea( 'PBA' )
		RecLock( 'PBA', .T. )
		PBA_FILIAL	:= xFilial('PBA')
		PBA_CODCLI	:= cCodcli
		PBA_LOJACL	:= cLojaCli
		PBA_NIVEL	:= '1'
		PBA_USUARI	:= __cUserId
		PBA_NOME	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
		PBA_DATA	:= dDatabase
		PBA_HORA	:= TIME()
		MSMM(,TamSx3("PBA_PARECE")[1],,"BLOQUEADO : "+cMotivo+'-'+cDscMot,1,,,"PBA","PBA_CODMEM")
		PBA->( MsUnLock())
		//FIM: chamado 030469 - sigoli


		cMensagem := "Codigo          : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
		//cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)	//chamado 030469 - sigoli
		cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)      //chamado 030469 - sigoli
		cMensagem += "Cliente         : "+ PB3->PB3_NOME+chr(13) + chr(10)
		cMensagem += "CNPJ/CPF        : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
		cMensagem += "Vendedor        : "+ GetAdvFVal("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
		"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
		cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
		cMensagem += "Prazo           : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
		cMensagem += "Motivo Bloqueio : "+ cMotivo+" - "+ cDscMot+chr(13) + chr(10)
		cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)
		// Ricardo Lima-14/02/2019-CH:046840
		//cMensagem += "Status          : "+ IIF(cStsCli='1','Bloqueado','Ativo')

		//Everson - 05/03/2018. Chamado 037261. SalesForce.
		If FindFunction("U_ADVEN076P")
			U_ADVEN076P(PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,.F.,,"BLQFN",.T.," Cliente Bloqueado " + cMotivo+" - "+ cDscMot+chr(13) + chr(10) + " " )
		EndIf
		// Ricardo Lima-31/01/2019-CH:046840
		CriaMail(cPara, 'Cliente Bloqueado', cMensagem, ,cCC, .F., .T., cCodcli, cLojaCli)

	Endif

Return nil

/*{Protheus.doc} Static Function ADOREJEITA
	Rejeicao de clientes
	@type  Function
	@author Vogas Junior
	@since 16/10/2009
	@version 01
	@history 
*/

Static function AdoReJeita( cCodcli, cLojacli, cOption )

	Local aArea			:= GetArea()
	Local cNomeUsr		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara 		:= SuperGetMv("FS_MOVMAIL", .F., "")
	Local cEmailVend    := ""
	Local cEmailSuper   := ""
	Local lRej          := .F.
	
	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 1 ))

	If PB3->( DbSeek( xFilial( 'PB3' ) + cCodcli + cLojacli ))
		cCodSup			:= GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND, 7 )
		cEmailVend      := GetAdvFVal( 'SA3', "A3_EMAIL", xFilial("SA3") + PB3->PB3_VEND, 7, " ")	
		cEmailSuper     := GetAdvFVal( 'SA3','A3_EMAIL', xFilial('SA3') + cCodSup, 1  )

		//chamada da rotina para solicitar o motivo do rejeito.

		If cOption == "VND"
			U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_SITUAC', 'X3_Titulo' ),If(PB3->PB3_SITUAC $ '1/4', 'Em Analise',If(PB3->PB3_SITUAC == '2', 'Aprovado', '')), 'Rejeitado' )      &&Mauricio - Chamado 035857 - 14/07/17
			lRej := .T.

		Else

			lRej := MOTIVREJ(cCodcli, cLojaCli, cNomeUsr, cOption)  //chamado 035744 - 14/06/2017 - fernando sigoli

		EndIf 


		If lRej 
            
			If cOption <> "VND" //só mandar email para rejeito com motivos. rejeito comercial nao enviar workflow 044612- Fernando Sigoli
			
				cPara += ";"+ Alltrim(cEmailVend) + ";" + AllTrim(cEmailSuper)

				cMensagem := "Codigo       : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				cMensagem += "Loja         : "+ PB3->PB3_LOJSA1+chr(13) + chr(10)
				cMensagem += "Cliente      : "+ PB3->PB3_NOME+chr(13) + chr(10)
				cMensagem += "CNPJ/CPF     : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
				cMensagem += "Vendedor     : "+ GetAdvFVal("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
				"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
				cMensagem += "Motivo(s)    : "+cvaltochar(cMotRej)+chr(13) + chr(10)

				cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)

				CriaMail(cPara, 'Cadastro Reprovado', cMensagem, /*''*/,, .F., .T., cCodcli, cLojacli)
            
            
				/***** Envio de cadastros ao SalesForce *****/	
			
				//Everson - 22/01/2018. Chamado 037261 - Envia cadastro de cliente.
				If Findfunction("U_ADVEN076P") .And. ! Empty(Alltrim(cValToChar(PB3->PB3_CODSA1))) .And.  ! Empty(Alltrim(cValToChar(PB3->PB3_LOJSA1)))
					U_ADVEN076P( Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ,Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)),.F.)
				EndIf
				
				//Everson - 22/01/2018. Chamado 037261 - Envia parecer.
				If Findfunction("U_ADVEN052P")
				
					//
					If chkSA1SF(Alltrim(cValToChar(PB3->PB3_CODSA1)),Alltrim(cValToChar(PB3->PB3_LOJSA1))) //Verifica se o cadastro do cliente já foi enviado para o SalesForce.			
						U_ADVEN052P( Alltrim(cValToChar(PB3->PB3_COD)) , Alltrim(cValToChar(PB3->PB3_LOJA)) ,.F., Alltrim(cValToChar(cMotRej)),"C" )
				
					EndIf
				
				EndIf
			
			EndIF
			/*******************************************/
			
			Reclock( 'PB3', .F. )
			PB3->PB3_SITUAC := '3'
			PB3->PB3_DTREJE := dDataBase
			PB3->PB3_PRIOR  := '2'
			PB3->PB3_VENENC :=  "  "
			PB3->PB3_MOTREJ :=  IIF(cOption == "VND",'',cCodMotivo)
			PB3->(MsUnLock())

			
			Alert( 'Cadastro de Cliente Rejeitado')

		Else
			Alert( 'Rejeito Cancelado')
		EndIf
		
	Endif

	RestArea( aArea )

Return NIL

/*{Protheus.doc} Static Function ADOSLDOC
	Envia solicitacao de documento ao SalesForce
	@type  Function
	@author Everson
	@since 21/02/2018
	@version 01
	@history 
*/

Static Function AdoSlDoc( cCodcli, cLojacli, cOption )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local cNomeUsr		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara 		:= SuperGetMv("FS_MOVMAIL", .F., "")
	Local cEmailVend    := ""
	Local cEmailSuper   := ""
	Local lEnvSF        := .F.
	Local cDocSolic		:= Space(200)

	//
	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 1 ))

	If PB3->( DbSeek( xFilial( 'PB3' ) + cCodcli + cLojacli ))
		cCodSup			:= GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND, 7 )
		cEmailVend      := GetAdvFVal( 'SA3', "A3_EMAIL", xFilial("SA3") + PB3->PB3_VEND, 7, " ")	
		cEmailSuper     := GetAdvFVal( 'SA3', 'A3_EMAIL', xFilial('SA3') + cCodSup, 1  )

		//
		intSolDoc(@lEnvSF,@cDocSolic,cCodcli,cLojaCli)

		//
		If lEnvSF

			cPara += ";"+ Alltrim(cEmailVend) + ";" + AllTrim(cEmailSuper)

			Reclock( 'PB3', .F. )
			PB3->PB3_SITUAC := '3'
			PB3->PB3_DTREJE := dDataBase
			PB3->PB3_PRIOR  := '2'
			PB3->PB3_VENENC :=  "  "
			PB3->(MsUnLock())

			cMensagem := "Codigo       : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
			cMensagem += "Loja         : "+ PB3->PB3_LOJA+chr(13) + chr(10)
			cMensagem += "Cliente      : "+ PB3->PB3_NOME+chr(13) + chr(10)
			cMensagem += "CNPJ/CPF     : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
			cMensagem += "Vendedor     : "+ GetAdvFVal("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
			"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
			cMensagem += "Documentos    : "+cvaltochar(cDocSolic)+chr(13) + chr(10)

			cMensagem += "Análise realizada por :" + cNomeUsr + ", em " + Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)

			CriaMail(cPara, 'Solicitação de documento.', cMensagem, /*''*/,, .F., .T., cCodcli, cLojacli)

			MsgInfo( 'Solicitação de documento realizada.','Função AdoSlDoc')

			/***** Envio de cadastros ao SalesForce *****/		
			//Everson - 22/01/2018. Chamado 037261 - Envia parecer.
			If Findfunction("U_ADVEN052P")
				
				//
				If chkSA1SF(Alltrim(cValToChar(PB3->PB3_CODSA1)),Alltrim(cValToChar(PB3->PB3_LOJSA1))) //Verifica se o cadastro do cliente já foi enviado para o SalesForce.
					U_ADVEN052P( Alltrim(cValToChar(PB3->PB3_COD)) , Alltrim(cValToChar(PB3->PB3_LOJA)) ,.F., cDocSolic,"A")
				
				EndIf

			EndIf
			/*******************************************/

		Else
			MsgStop( 'Solicitação de documento cancelada.','Função AdoSlDoc')

		EndIf

	Endif

	RestArea( aArea )

Return Nil

/*{Protheus.doc} Static Function ADOENVAP
	Envia aprovacao de Lead para o Salesforce
	@type  Function
	@author Everson
	@since 06/03/2018
	@version 01
	@history 
*/

Static Function AdoEnvAp(cCodcli, cLojacli, cOption)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

	//
	If ! FindFunction("U_ADVEN052P")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If ! MsgYesNo("Deseja enviar o parecer de aprovação de pré-cadastro para o SalesForce.","Função AdoEnvAp")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 1 ))
	If PB3->( DbSeek( xFilial( 'PB3' ) + cCodcli + cLojacli ))
	
		//
		If chkSA1SF(Alltrim(cValToChar(PB3->PB3_CODSA1)),Alltrim(cValToChar(PB3->PB3_LOJSA1))) //Verifica se o cadastro do cliente já foi enviado para o SalesForce.
			U_ADVEN052P(cCodcli,cLojacli,.F., "Reenvio de aprovação","D")
			
		Else
			MsgStop("O cadastro do cliente (SA1) não consta com enviado ao SalesForce. Não será possível enviar o parecer.","Função AdoEnvAp(ADOA005)")
			
		EndIf

	EndIf

	//
	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function INTSOLDOC
	Interface para insercao de texto com a solicitacao de doc
	@type  Function
	@author Everson
	@since 22/02/2018
	@version 01
	@history 
*/

Static Function intSolDoc(lOk,cTexto,cCodcli,cLojaCli)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oDlg2   := Nil

	Private cDesc := Space(200)

	//
	Define Msdialog oDlg2 From 000,000 To 210,590 Title  "Solicitação de Documentos" Pixel

	@ 005,010 Say "Informe os documentos pendentes."  SIZE 142, 007 OF oDlg2 Colors 0, 16777215 Pixel

	TGet():New(030,010,{|u|If(PCount() == 0,cDesc,cDesc := u)},oDlg2,275,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDesc",,,,.T.,,,"",2) 

	@ 080,010 BUTTON "Ok"       Size 40,15 Action(cTexto := cDesc,solDocOK(cCodcli, cLojaCli,cUserName,cTexto),Close(oDlg2),lOk := .T.) Size 037, 012 Of oDlg2 Pixel
	@ 080,245 BUTTON "Cancelar" Size 40,15 Action(lOk := .F.,Close(oDlg2)) SIZE 037, 012 Of oDlg2 Pixel

	Activate MsDialog oDlg2 Centered

Return Nil

/*{Protheus.doc} Static Function SOLDOCOK
	Interface para insercao de texto com a solicitacao de doc
	@type  Function
	@author Everson
	@since 22/02/2018
	@version 01
	@history 
*/

Static Function solDocOK(cCodcli, cLojaCli,cNomeUsr,cTexto) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nVez 	:= 0
	Private nVlrPdg := 0
	
	U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_SITUAC', 'X3_Titulo' ),If(PB3->PB3_SITUAC $ '1/4', 'Em Analise',If(PB3->PB3_SITUAC == '2', 'Aprovado', '')), 'Rejeitado' )

	U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, 'Motivo Rejeito', '', Alltrim(cValToChar(cTexto)) )

	U_GrvParecer(cCodCli, cLojaCli, Alltrim(cValToChar(cTexto)) )

Return

/*{Protheus.doc} Static Function ADOFILTROS
	Filtra os registros de clientes espelho
	@type  Function
	@author Vogas Junior
	@since 20/10/2009
	@version 01
	@history 
*/

Static Function AdoFiltros()

	Local aFilBrowse	:= {{},""}
	Local cFiltro 		:= FilterExpr('PB3')

	If !Empty(cFiltro)
		Set Filter to &cFiltro
	Else
		Set Filter to
	Endif

Return

/*{Protheus.doc} Static Function ADO5IMPR
	Impressao do relatorio
	@type  Function
	@author Vogas Junior
	@since 26/10/2009
	@version 01
	@history 
*/

Static Function Ado5Impr()

	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->( GetArea() )
	Local cPerg	 	:= "ADO100"
	Local lEnd	 	:= .F.
	Local aTamSX3	:= {}
	Local aHelp		:= {}

	PRIVATE nTotPag := 0
	PRIVATE i := 0

	/*Static Function AdoExibPar( cOrdem )*/

	//Alert( cOrdem )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os titulos e Help das perguntas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aHelp, { "Data de Envio De: " 		,	"",	"", { "Data de Envio Inicial" } 				,{""}, {""} } )
	aAdd(aHelp, { "Data de Envio Até: "		,	"",	"", { "Data de Envio Final" } 					,{""}, {""} } )
	aAdd(aHelp, { "Data Aprov/Reprov De: " 	,	"",	"", { "Data de Aprovação Reprovação Inicio" } 	,{""}, {""} } )
	aAdd(aHelp, { "Data Aprov/Reprov Até: "	,	"",	"", { "Data de Aprovação Reprovação Final" } 	,{""}, {""} } )
	aAdd(aHelp, { "Motivo "   				,	"",	"", { "Motivo do Cadastro." } 					,{""}, {""} } )
	aAdd(aHelp, { "Situação " 	 			,	"",	"", { "Situação do Cadastro." } 				,{""}, {""} } )
	aAdd(aHelp, { "Cod. Rede " 	 			,	"",	"", { "Código de rede do cliente." }	 		,{""}, {""} } )
	aAdd(aHelp, { "CPF/CNPJ De: "			,	"",	"", { "CPF OU CNPJ do cliente." } 				,{""}, {""} } )
	aAdd(aHelp, { "CPF/CNPJ até: "			,	"",	"", { "CPF OU CNPJ do cliente." } 				,{""}, {""} } )
	aAdd(aHelp, { "Cod. Cliente De: " 		,	"",	"", { "Código do cliente." }	 				,{""}, {""} } )
	aAdd(aHelp, { "Cod. Cliente Até: " 		,	"",	"", { "Código do cliente." } 					,{""}, {""} } )
	aAdd(aHelp, { "Loja do Cliente De: " 	,	"",	"", { "Loja do cliente." } 						,{""}, {""} } )
	aAdd(aHelp, { "Loja do Cliente Até: " 	,	"",	"", { "Loja do cliente." } 						,{""}, {""} } )
	aAdd(aHelp, { "Vendedor De: " 			,	"",	"", { "Vendedor responsável pelo cliente." } 	,{""}, {""} } )
	aAdd(aHelp, { "Vendedor Até: "			,	"",	"", { "Vendedor responsável pelo cliente." } 	,{""}, {""} } )
	aAdd(aHelp, { "Supervisor De: "			,	"",	"", { "Supervisor resopnável pelo cliente." } 	,{""}, {""} } )
	aAdd(aHelp, { "Supervisor Até: "		,	"",	"", { "Supervisor resopnável pelo cliente." } 	,{""}, {""} } )
	aAdd(aHelp, { "Segmento 1 De: "			,	"",	"", { "Segmento do cliente." } 					,{""}, {""} } )
	aAdd(aHelp, { "Segmento 1 Até: "		,	"",	"", { "Segmento do cliente." } 					,{""}, {""} } )
	aAdd(aHelp, { "Segmento 2 De: "			,	"",	"", { "Segmento do cliente." } 					,{""}, {""} } )
	aAdd(aHelp, { "Segmento 2 Até: "		,	"",	"", { "Segmento do cliente." } 					,{""}, {""} } )
	aAdd(aHelp, { "Analista: "				,	"",	"", { "Analista resopnável pelo cliente." } 	,{""}, {""} } )
	aAdd(aHelp, { "Tipo de Relatorio: "		,	"",	"", { "Escolha um tipo de relatório." } 		,{""}, {""} } )
	//aAdd(aHelp, { "Ordem do Relatório: "	,	"",	"", { "1Env 2ApRp 3Mot 4Sit 5Vend 6Sup 7Seg 8Seg2 9Analista"} 		,{""}, {""} } )
	//         10        20        30        40
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as perguntas no arquivo SX1                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//		cGrupo	cOrde	cDesPor			cDesSpa			cDesEng			cVar		cTipo		cTamanho	cDecimal	nPreSel	cGSC	cValid	cF3		cGrpSXG	cPyme	cVar01		cDef1Por	cDef1Spa	cDef1Eng	cCnt01	  					cDef2Por	cDef2Spa	cDef2Eng	cDef3Por		cDef3Spa		cDef3Eng		cDef4Por	cDef4Spa	cDef4Eng	cDef5Por	cDef5Spa	cDef5Eng	aHelpPor		aHelpEng		aHelpSpa		cHelp)
	aTamSX3	:= TAMSX3( "PB9_DATA" )
	PutSx1(	cPerg,	"01",	aHelp[01,1],	aHelp[01,2],	aHelp[01,3],	"mv_ch1",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	"",		"D",	"mv_par01",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[01,4],	aHelp[01,5],	aHelp[01,6],	"" )
	PutSx1(	cPerg,	"02",	aHelp[02,1],	aHelp[02,2],	aHelp[02,3],	"mv_ch2",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	"",		"D",	"mv_par02",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[02,4],	aHelp[02,5],	aHelp[02,6],	"" )
	PutSx1(	cPerg,	"03",	aHelp[03,1],	aHelp[03,2],	aHelp[03,3],	"mv_ch3",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	"",		"D",	"mv_par03",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[03,4],	aHelp[03,5],	aHelp[03,6],	"" )
	PutSx1(	cPerg,	"04",	aHelp[04,1],	aHelp[04,2],	aHelp[04,3],	"mv_ch4",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	"",		"D",	"mv_par04",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[04,4],	aHelp[04,5],	aHelp[04,6],	"" )
	aTamSX3	:= TAMSX3( "PB4_CODIGO" )
	PutSx1(	cPerg,	"05",	aHelp[05,1],	aHelp[05,2],	aHelp[05,3],	"mv_ch5",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",	"PB4001","",	"C",	"mv_par05",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[05,4],	aHelp[05,5],	aHelp[05,6],	"" )
	aTamSX3 := TAMSX3( "PB3_SITUAC" )
	PutSx1(	cPerg,	"06",	aHelp[06,1],	aHelp[06,2],	aHelp[06,3],	"mv_ch6",	/*aTamSX3[3]*/"N",	aTamSx3[1],	aTamSX3[2],	0,		"C",	"",		"",	 "",	"C",	"mv_par06",	"Análise","Análise","Análise","", "Aprovado", "Aprovado", "Aprovado","Reprovado","Reprovado","Reprovado","Todas",    "Todas",	       "Todas",	   "     ",			"",			"",			aHelp[06,4],	aHelp[06,5],	aHelp[06,6],	"" )
	aTamSX3 := TAMSX3( "PB3_CODRED" )
	PutSx1(	cPerg,	"07",	aHelp[07,1],	aHelp[07,2],	aHelp[07,3],	"mv_ch7",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"","PB3RED",	 "",	"C",	"mv_par07",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[07,4],	aHelp[07,5],	aHelp[07,6],	"" )
	aTamSX3 := TAMSX3( "PB3_CGC" )
	PutSx1(	cPerg,	"08",	aHelp[08,1],	aHelp[08,2],	aHelp[08,3],	"mv_ch8",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par08",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[08,4],	aHelp[08,5],	aHelp[08,6],	"" )
	PutSx1(	cPerg,	"09",	aHelp[09,1],	aHelp[09,2],	aHelp[09,3],	"mv_ch9",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par09",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[09,4],	aHelp[09,5],	aHelp[09,6],	"" )
	aTamSX3 := TAMSX3( "PB3_CODSA1" )
	PutSx1(	cPerg,	"10",	aHelp[10,1],	aHelp[10,2],	aHelp[10,3],	"mv_ch10",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par10",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[10,4],	aHelp[10,5],	aHelp[10,6],	"" )
	PutSx1(	cPerg,	"11",	aHelp[11,1],	aHelp[11,2],	aHelp[11,3],	"mv_ch11",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par11",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[11,4],	aHelp[11,5],	aHelp[11,6],	"" )
	aTamSX3 := TAMSX3( "PB3_LOJA" )
	PutSx1(	cPerg,	"12",	aHelp[12,1],	aHelp[12,2],	aHelp[12,3],	"mv_ch12",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par12",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[12,4],	aHelp[12,5],	aHelp[12,6],	"" )
	PutSx1(	cPerg,	"13",	aHelp[13,1],	aHelp[13,2],	aHelp[13,3],	"mv_ch13",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",	 "",	"C",	"mv_par13",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[13,4],	aHelp[13,5],	aHelp[13,6],	"" )
	aTamSX3 := TAMSX3( "PB3_VEND" )
	PutSx1(	cPerg,	"14",	aHelp[14,1],	aHelp[14,2],	aHelp[14,3],	"mv_ch14",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",  "SA3",  "",	"C",	"mv_par14",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[14,4],	aHelp[14,5],	aHelp[14,6],	"" )
	PutSx1(	cPerg,	"15",	aHelp[15,1],	aHelp[15,2],	aHelp[15,3],	"mv_ch15",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",	 "SA3",  "",	"C",	"mv_par15",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[15,4],	aHelp[15,5],	aHelp[15,6],	"" )
	PutSx1(	cPerg,	"16",	aHelp[16,1],	aHelp[16,2],	aHelp[16,3],	"mv_ch16",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",  "",	"C",	"mv_par16",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[16,4],	aHelp[16,5],	aHelp[16,6],	"" )
	PutSx1(	cPerg,	"17",	aHelp[17,1],	aHelp[17,2],	aHelp[17,3],	"mv_ch17",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",		"",  "",	"C",	"mv_par17",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[17,4],	aHelp[17,5],	aHelp[17,6],	"" )
	aTamSX3 := TAMSX3( "PB3_SEGTO" )
	PutSx1(	cPerg,	"18",	aHelp[18,1],	aHelp[18,2],	aHelp[18,3],	"mv_ch18",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",	"Segto",  "",	"C",	"mv_par18",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[18,4],	aHelp[18,5],	aHelp[18,6],	"" )
	PutSx1(	cPerg,	"19",	aHelp[19,1],	aHelp[19,2],	aHelp[19,3],	"mv_ch19",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",	"Segto",  "",	"C",	"mv_par19",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[19,4],	aHelp[19,5],	aHelp[19,6],	"" )
	aTamSX3 := TAMSX3( "PB3_SUBSEG" )
	PutSx1(	cPerg,	"20",	aHelp[20,1],	aHelp[20,2],	aHelp[20,3],	"mv_ch20",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"","subseg",  "",	"C",	"mv_par20",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[20,4],	aHelp[20,5],	aHelp[20,6],	"" )
	PutSx1(	cPerg,	"21",	aHelp[21,1],	aHelp[21,2],	aHelp[21,3],	"mv_ch21",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"","subseg",  "",	"C",	"mv_par21",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[21,4],	aHelp[21,5],	aHelp[21,6],	"" )
	aTamSX3 := TAMSX3( "PB3_VEND" )
	PutSx1(	cPerg,	"22",	aHelp[22,1],	aHelp[22,2],	aHelp[22,3],	"mv_ch22",	aTamSX3[3],	aTamSx3[1],	aTamSX3[2],	0,		"G",	"",	"PB1001",  "",	"C",	"mv_par22",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[22,4],	aHelp[22,5],	aHelp[22,6],	"" )
	PutSx1(	cPerg,	"23",	aHelp[23,1],	aHelp[23,2],	aHelp[23,3],	"mv_ch23",	/*aTamSX3[3]*/"N",	/*aTamSx3[1]*/,	/*aTamSX3[2]*/,	0,		"C",	"",		"",	 "",	"C",	"mv_par23",	"Analítico","Analítico","Analítico","", "Sintético", "Sintético", "Sintético",		"",				"",				"",				"",   		"",	        "",	   "     ",			"",			"",			aHelp[23,4],	aHelp[23,5],	aHelp[23,6],	"" )
	//PutSx1(	cPerg,	"24",	aHelp[24,1],	aHelp[24,2],	aHelp[24,3],	"mv_ch24",	/*aTamSX3[3]*/"N",	/*aTamSx3[1]*/,	/*aTamSX3[2]*/,	0,		"C",	"",		"",	 "",	"C",	"mv_par24",	"",			"",	 		"",			"",							"",			"",			"",			"",				"",				"",				"",			"",			"",			"",			"",			"",			aHelp[24,4],	aHelp[24,5],	aHelp[24,6],	"" )
	//PutSx1(	cPerg,	"24",	aHelp[24,1],	aHelp[24,2],	aHelp[24,3],	"mv_ch24",	/*aTamSX3[3]*/"N",	/*aTamSx3[1]*/,	/*aTamSX3[2]*/,	0,		"C",	"",		"",	 "",	"C",	"mv_par24",	"Dt.Envio","Dt.Envio","Dt.Envio","9", "Dt.Apr/Rep", "Dt.Apr/Rep", "Dt.Apr/Rep","Motivo","Motivo","Motivo","Situacao","Situacao","Situacao","Vendedor","Vendedor","Vendedor",	"Supervisor","Supervisor","Supervisor","Segmento","Segmento","Segmento","Segmento 2","Segmento 2","Segmento 2","Analista","Analista","Analista",  		aHelp[06,4],	aHelp[06,5],	aHelp[06,6],	"" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Areas originais                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aAreaSX1 )
	RestArea( aAreaAtu )

	If Pergunte(cPerg , .T. )
		RptStatus( { |lEnd| Ado5IprA() }, "Aguarde...", "Processando registros...", .T. )
	EndIf

Return

/*{Protheus.doc} Static Function ADOFILTROS
	Impressao de relatorio
	@type  Function
	@author Vogas Junior
	@since 26/10/2009
	@version 01
	@history 
*/

Static Function Ado5IprA()

	Local oDlgPrint	:= NIL
	Local oListBox2 := NIL
	Local aArea 	:= GetArea()
	Local aOrdem 	:= {	{"01", "Data Envio"} ,;
	{"02", "Data Aprovação / Reprovação"},;
	{"03", "Motivo"},;
	{"04", "Situação"},;
	{"05", "Vendedor"},;
	{"06", "Supervisor"},;
	{"07", "Segmento"},;
	{"08", "Sub-segmento"},;
	{"09", "Analista"}}
	Local nOrdem	:= 0
	Local nOpcao	:= 0

	Local nLinha	:= 50
	//Local oFont1    := TFont():New( 'Arial'	, 08 , 08 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont2    := TFont():New( 'Arial'	, 08 , 08 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont3    := TFont():New( 'Arial'	, 09 , 09 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	Local oFont4	:= TFont():New( 'Arial'	, 09 , 09 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont5 	:= TFont():New( 'Arial'	, 10 , 10 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont6 	:= TFont():New( 'Arial'	, 10 , 10 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	Local oFont7  	:= TFont():New( 'Arial'	, 10 , 10 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont8 	:= TFont():New( 'Arial'	, 12 , 12 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont9 	:= TFont():New( 'Arial'	, 16 , 16 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	Local cSituac	:= ''
	Local cData		:= ''
	Local nPag		:= 0
	Local cCliente	:= ''
	Local nCliente	:= 0
	Local nLimiteS	:= 0
	Local nLimiteA	:= 0
	Local oPrint
	Local	cQuery 	:= " SELECT PB9_DATA, PB4_DESCRI, PB3_SITUAC, PB3_CODSA1, PB3_LOJA, PB3_NOME, "
	cQuery 	+= " PB3_NREDUZ, PB3_CREDSU, PB3_PRAZOS, PB3_LIMAPR, PB3_CNDPGA, PB3_DTAPRO, PB3_DTREJE, A3_COD, A3_SUPER, PB3_COD, PB3_LOJA, PB3_MOTACE "
	cQuery 	+= " FROM " + RetSqlName("PB3") + " PB3 INNER JOIN " + RetSqlName("PB9") + " PB9 ON PB9.PB9_CODIGO = PB3.PB3_COD "
	cQuery 	+= " AND PB9.PB9_LOJA = PB3.PB3_LOJA AND 'Encaminhou' IN(PB9.PB9_CPOALT) "
	cQuery 	+= " INNER JOIN " + RetSqlName("PB4") + " PB4 ON '" + LEFT(PB3_MOTACE, 2)+ "' = PB4_CODIGO "
	cQuery 	+= " INNER JOIN " + RetSqlName("SA3") + " SA3 ON PB3_VEND = A3_CODUSR "
	cQuery 	+= " WHERE PB9.D_E_L_E_T_ <> '*' AND PB3.D_E_L_E_T_ <> '*' AND PB4.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*' "
	/*
	// Data de Envio De
	If !Empty( mv_par01 )
	cQuery 	+= " AND PB9.PB9_DATA >= '" + DtoS(MV_PAR01) + "' "
	Endif
	// Data de Envio Ate
	If !Empty( mv_par02 )
	cQuery 	+= " AND PB9.PB9_DATA <= '" + DtoS(MV_PAR02) + "' "
	Endif
	// Data de Aprovacao ou reprovacao De
	If !Empty( mv_par03 )
	cQuery 	+= " AND (PB3.PB3_DTAPRO >= '" + DtoS(MV_PAR03) + "' OR PB3.PB3_DTREJE >= '" + DtoS(MV_PAR03) + "') "
	Endif
	// Data de reprovacao Ate
	If !Empty( mv_par04 )
	cQuery 	+= " AND ((PB3.PB3_DTAPRO <= '" + DtoS(MV_PAR04) + "' AND PB3.PB3_DTAPRO <> ' ' )OR (PB3.PB3_DTREJE <= '" + DtoS(MV_PAR04) + "' AND PB3.PB3_DTREJE <> ' ')) "
	Endif
	*/
	// Motivo
	If !Empty( mv_par05 )
		cQuery 	+= " AND SUBSTRING(PB3_MOTACE,1,2) = '" + (MV_PAR05) + "' "
	Endif
	//Situacao
	If !Empty( mv_par06 )
		If MV_PAR06 < 4
			cQuery 	+= " AND PB3_SITUAC = '" + Str(MV_PAR06,1,0) + "' "
		Endif
	Endif
	// codigo de rede
	If !Empty( mv_par07 )
		cQuery 	+= " AND PB3_CODRED = '" + MV_PAR07 + "' "
	Endif
	// CNPJ/CGC DE
	If !Empty( mv_par08 )
		cQuery 	+= " AND PB3_CGC >= '" + MV_PAR08 + "' "
	Endif
	// CNPJ/CGC ATE
	If !Empty( mv_par09 )
		cQuery 	+= " AND PB3_CGC <= '" + MV_PAR09 + "' "
	Endif
	//Codigo do Cliente De
	If !Empty( mv_par10 )
		cQuery 	+= " AND PB3_CODSA1 >= '" + MV_PAR10 + "' "
	Endif
	// Codigo do Cliente Ate
	If !Empty( mv_par11 )
		cQuery 	+= " AND PB3_CODSA1 <= '" + MV_PAR11 + "' "
	Endif
	//Loja do cliente De
	If !Empty( mv_par12 )
		cQuery 	+= " AND PB3_LOJA >= '" + MV_PAR12 + "' "
	Endif
	//Loja do cliente Ate
	If !Empty( mv_par13 )
		cQuery 	+= " AND PB3_LOJA <= '" + MV_PAR13 + "' "
	Endif
	// Vendedor De
	If !Empty( mv_par14 )
		cQuery 	+= " AND A3_COD >= '" + MV_PAR14 + "' "
	Endif
	// Vendedor Ate
	If !Empty( mv_par15 )
		cQuery 	+= " AND A3_COD <= '" + MV_PAR15 + "' "
	Endif
	// Supervisor De
	If !Empty( mv_par16 )
		cQuery 	+= " AND A3_SUPER >= '" + MV_PAR16 + "' "
	Endif
	// Supervisor Ate
	If !Empty( mv_par17 )
		cQuery 	+= " AND A3_SUPER <= '" + MV_PAR17 + "' "
	Endif
	// Segmento De
	If !Empty( mv_par18 )
		cQuery 	+= " AND PB3_SEGTO >= '" + MV_PAR18 + "' "
	Endif
	// SubSegmento Ate
	If !Empty( mv_par19 )
		cQuery 	+= " AND PB3_SEGTO <= '" + MV_PAR19 + "' "
	Endif
	// SubSegmento De
	If !Empty( mv_par20 )
		cQuery 	+= " AND PB3_SEGTO >= '" + MV_PAR20 + "' "
	Endif
	// SubSegmento Ate
	If !Empty( mv_par21 )
		cQuery 	+= " AND PB3_SEGTO <= '" + MV_PAR21 + "' "
	Endif
	// filtra por codigo do analista de credito que o vendedor foi encaminhado.
	If !Empty( mv_par22 )
		cQuery 	+= " AND PB3_VENENC <= '" + MV_PAR22 + "' "
	Endif


	DEFINE MSDIALOG oDlgPrint TITLE "Selecione a Ordem do relatório" FROM 00,00 To 245,340 OF oMainWnd PIXEL

	@ 017,005 ListBox oListBox2 Fields HEADER "Codigo", "Ordem" Size 164, 100 Of oDlgPrint Pixel
	oListBox2:SetArray( aOrdem )
	oListBox2:bLine := {|| { aOrdem[ oListBox2:nAT, 01 ], aOrdem[ oListBox2:nAT, 02 ] }}

	ACTIVATE MSDIALOG oDlgPrint CENTERED ON INIT EnchoiceBar(oDlgPrint,{||nOpcao:=1,nOrdem := oListBox2:nAT,01, /*(	AdoExibPar( aOrdem[oListBox2:nAT,01]),*/ oDlgPrint:End()/*)*/},{||nOpcao:=0,oDlgPrint:End()},.F.,)

	// Ordenacao do relatorio.
	If nOpcao == 1
		Do Case
			Case aOrdem[nOrdem,1] == '01'
			cQuery 	+= " ORDER BY PB9_DATA "
			Case aOrdem[nOrdem,1] == '02'
			cQuery 	+= " ORDER BY PB3_DTAPRO, PB3_DTREJE "
			Case aOrdem[nOrdem,1] == '03'
			cQuery 	+= " ORDER BY SUBSTRING( PB3_MOTACE, 5, 20) "
			Case aOrdem[nOrdem,1] == '04'
			cQuery 	+= " ORDER BY PB3_SITUAC "
			Case aOrdem[nOrdem,1] == '05'
			cQuery 	+= " ORDER BY A3_COD "
			Case aOrdem[nOrdem,1] == '06'
			cQuery 	+= " ORDER BY A3_SUPER "
			Case aOrdem[nOrdem,1] == '07'
			cQuery 	+= " ORDER BY PB3_SEGTO "
			Case aOrdem[nOrdem,1] == '08'
			cQuery 	+= " ORDER BY PB3_SUBSEG "
			Case aOrdem[nOrdem,1] == '09'
			cQuery 	+= " ORDER BY PB3_VENENC "
		EndCase
	Endif

	cQuery := ChangeQuery( cQuery )

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf

	DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "TRB", .F., .T. )
	dbSelectArea( "TRB" )
	dbGoTop()

	oPrint := TMSPrinter():New( "Dados Cadastrais" )
	oPrint:SetPortrait()

	If MV_PAR23 == 1 // Relatorio Analitico
		While !TRB->( Eof() )

			Do Case
				Case TRB->PB3_SITUAC $ '1/4'  &&Mauricio - Chamado 035857 - 14/07/17
				cSituac := 'Em Análise'
				Case TRB->PB3_SITUAC == '2'
				cSituac := 'Aprovado'
				Case TRB->PB3_SITUAC == '3'
				cSituac := 'Reprovado'
			EndCase

			cData := Substr(TRB->PB9_DATA, 7, 2) + '/'+ Substr(TRB->PB9_DATA, 5, 2) + '/'+ Left(TRB->PB9_DATA, 4 )

			If nLinha == 50 .Or. nLinha > 3100 //cabecalho
				/*
				oPrint:Say( nLinha , 0100 , '100'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0200 , '200'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0300 , '300'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0400 , '400'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0500 , '500'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0600 , '600'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0700 , '700'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0800 , '800'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 0900 , '900'  			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1000 , '1000' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1100 , '1100' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1200 , '1200' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1300 , '1300' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1400 , '1400' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1500 , '1500' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1600 , '1600' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1700 , '1700' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1800 , '1800' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 1900 , '1900' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2000 , '2000' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2100 , '2100' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2200 , '2200' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2300 , '2300' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2400 , '2400' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2500 , '2500' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2600 , '2600' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2700 , '2700' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2800 , '2800' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 2900 , '2900' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 3000 , '3000' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 3100 , '3100' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 3200 , '3200' 			, oFont4 ,,,, 0  )
				oPrint:Say( nLinha , 3300 , '3300' 			, oFont4 ,,,, 0  )

				nLinha += 50
				*/
				nPag += 1
				oPrint:Say( nLinha , 0050 , 'RELATÓRIO DE ANALISE DE CADASTRO'	, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 2700 , 'Data: ' + DtoC(dDataBase)			, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 3100 , 'Pag.: ' + Str( nPag, 3, 0) 		, oFont7 ,,,, 0  )
				nLinha += 30
				oPrint:Say( nLinha , 0050 , 'Data'  		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 0300 , 'Motivo'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 0700 , 'Situação'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 1000 , 'Cod. Cliente'	, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 1250 , 'Loja'			, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 1350 , 'Razão'			, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 2100 , 'N Fant'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 2500 , 'Lim Sol'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 2700 , 'Lim Aprov'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 2900 , 'Prz Sol'		, oFont7 ,,,, 0  )
				oPrint:Say( nLinha , 3100 , 'Prz Aprov'		, oFont7 ,,,, 0  )
				nLinha += 30
				oPrint:Say( nLinha , 0050 , Replicate( '_',250 ) 		, oFont7 ,,,, 0  )
				nLinha += 50

			EndIf

			oPrint:Say( nLinha , 0050 , cData/*TRB->PB9_DATA*/	, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 0300 , TRB->PB4_DESCRI			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 0700 , cSituac					, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 1000 , TRB->PB3_CODSA1			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 1250 , TRB->PB3_LOJA			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 1350 , TRB->PB3_NOME			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 2100 , TRB->PB3_NREDUZ			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 2450 , Transform(TRB->PB3_CREDSU,"@E 999,999,999.99")	, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 2700 , Transform(TRB->PB3_LIMAPR,"@E 999,999,999.99")	, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 2970 , TRB->PB3_PRAZOS			, oFont4 ,,,, 0  )
			oPrint:Say( nLinha , 3100 , STR(TRB->PB3_CNDPGA)	, oFont4 ,,,, 0  )

			nLinha += 30
			TRB->( Dbskip() )
		Enddo
	Else // relatorio sintetico

		cCliente := TRB->PB3_COD + TRB->PB3_LOJA
		nCliente := 1
		While !TRB->( Eof() )

			If cCliente <> TRB->PB3_COD + TRB->PB3_LOJA
				cCliente := TRB->PB3_COD + TRB->PB3_LOJA
				nCliente += 1
			Endif

			nLimiteA += TRB->PB3_LIMAPR
			nLImiteS += TRB->PB3_CREDSU

			TRB->( Dbskip() )
		EndDo

		oPrint:Say( nLinha , 0050 , 'RELATÓRIO DE ANALISE DE CADASTRO'	, oFont7 ,,,, 0  )
		oPrint:Say( nLinha , 0840 , 'Data: ' + DtoC(dDataBase)			, oFont7 ,,,, 0  )
		nLinha += 50
		oPrint:Say( nLinha , 0050 , 'Qtde Cli'		, oFont7 ,,,, 0  )
		oPrint:Say( nLinha , 0324 , 'Lim Sol'		, oFont7 ,,,, 0  )
		oPrint:Say( nLinha , 0617 , 'Lim Apr'		, oFont7 ,,,, 0  )
		oPrint:Say( nLinha , 0900 , '% Apr Lim'		, oFont7 ,,,, 0  )
		nLinha += 30
		oPrint:Say( nLinha , 0050 , Replicate( '_', 51 ) 		, oFont7 ,,,, 0  )
		nLinha += 50
		oPrint:Say( nLinha , 0040 , Str(nCliente)													, oFont4 ,,,, 0  )
		oPrint:Say( nLinha , 0265 , Transform( nLimiteS, "@E 999,999,999.99" )						, oFont4 ,,,, 0  )
		oPrint:Say( nLinha , 0567 , Transform( nLimiteA, "@E 999,999,999.99" )						, oFont4 ,,,, 0  )
		oPrint:Say( nLinha , 0900 , Transform(( (nLimiteA / nLimiteS) * 100 ), "@E 999.99") + ' %'	, oFont4 ,,,, 0  )

	Endif

	oPrint:EndPage()
	oPrint:Preview()
	TRB->(dbCloseArea())

Return Nil

/*{Protheus.doc} Static Function ADO5IMPR2
	Impressao dos dados cadastrais
	@type  Function
	@author Vogas Junior
	@since 29/10/2009
	@version 01
	@history 
*/

Static Function Ado5Impr2( cCodCli, cLojaCli )

	Local oFont4		:= TFont():New( 'Arial'	, 09 , 09 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont5 		:= TFont():New( 'Arial'	, 10 , 10 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	//Local oFont6 		:= TFont():New( 'Arial'	, 10 , 10 , .T. , .F. , 5 , .T. , 5 , .F. , .F. )
	Local oFont7  		:= TFont():New( 'Arial'	, 10 , 10 , .T. , .T. , 5 , .T. , 5 , .F. , .F. )
	Local nlinha		:= 50
	Local cVendedor     := ''
	Local cSupervisor	:= ''
	Local cCodSup		:= ''
	Local cFilPBE		:= xFilial( 'PBE' )
	Local cFilPBA		:= xFilial( 'PBA' )
	Local aReferencias	:= {}
	Local aPareceres	:= {}
	Local aArea			:= GetArea()
	Local cSituacao		:= ''
	Local i				:= 0
	Local j				:= 0
	Local cDepartamento	:= ''
	Local cNmVend := ""
	Local cNmSup  := ""

	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 1 ))
	PB3->( DbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))

	cVendedor   	:= AllTrim(Posicione( 'SA3', 7, xFilial('SA3') + PB3->PB3_VEND, 'A3_COD' ))
	cNmVend         := SA3->A3_NOME
	cCodSup			:= SA3->A3_SUPER
	cNmSup          := Posicione( 'SA3', 1, xFilial('SA3') + cCodSup, AllTrim( 'A3_NOME' ) )
	cSupervisor		:= SA3->A3_NOME
	cDepartamento 	:= GetAdvFVal( 'PB1', 'PB1_DESDEP', xFilial( 'PB1' ) + PB3->PB3_VEND, 1 )
	// pega as referenticas comerciais.
	DbSelectArea( 'PBE' )
	PBE->( DbSetOrder( 1 ))
	If PBE->( DbSeek( cFilPBE + PB3->PB3_COD + PB3->PB3_LOJA ) )

		While cFilPBE == PBE->PBE_FILIAL .And. PBE->PBE_COD == PB3->PB3_COD .And. PBE->PBE_LOJA == PB3->PB3_LOJA
			aAdd( aReferencias,{ PBE->PBE_NOME, PBE->PBE_DDD, PBE->PBE_FONE, PBE->PBE_OBS })
			PBE->( DbSkip())
		EndDo

	Endif

	// Pega Pareceres
	DbSelectArea( 'PBA' )
	PBA->( DbSetOrder( 1 ))
	If PBA->( DbSeek( cFilPBA + PB3->PB3_COD + PB3->PB3_LOJA ) )

		While cFilPBA == PBA->PBA_FILIAL .And. PBA->PBA_CODCLI == PB3->PB3_COD .And. PBA->PBA_LOJACL == PB3->PB3_LOJA
			aAdd( aPareceres, {PBA->PBA_DATA, PBA->PBA_NOME, PBA->PBA_NIVEL, AllTrim( MSMM( PBA->PBA_CODMEM) )})
			PBA->( DbSkip())
		EndDo

	Endif

	// Situacao
	Do case
		Case PB3->PB3_SITUAC $ '1/4'  &&Mauricio - Chamado 035857 - 14/07/17
		cSituacao := 'Em Andamento'
		Case PB3->PB3_SITUAC == '2'
		cSituacao := 'Aprovado'
		Case PB3->PB3_SITUAC == '3'
		cSituacao := 'Reprovado'
	EndCase

	oPrint := TMSPrinter():New( "Dados Cadastrais" )
	oPrint:SetPortrait()
	oPrint:Say( nLinha 	, 0950 , "RELATÓRIO DE ANÁLISE CADASTRAL"	, oFont7 ,,,, 0  )
	nLinha += 250
	oPrint:Say( nLinha 	, 0050 , "Dados Cadastrais"					, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090
	oPrint:Say( nLinha 	, 0050 , 'Vend.: ' + cVendedor + ' - ' + cNmVend 		, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Superv.: ' + cSupervisor	 + ' - ' + cNmSup	, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Situação: ' + cSituacao						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Motivo: ' + PB3->PB3_MOTACE						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Dt.Envio: ' + DtoC(PB3->PB3_DTENVI)				, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Razão: ' + PB3->PB3_NOME						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Fant.: ' + PB3->PB3_NREDUZ						, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Cód.: ' + PB3->PB3_CODSA1						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 0450 , 'Lj.: ' + PB3->PB3_LOJA						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'CNPJ: ' + PB3->PB3_CGC							, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'I.E. ' + PB3->PB3_INSCR						, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'End.: ' + PB3->PB3_END							, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'N º: ' +  PB3->PB3_NUMERO						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'CEP: ' + PB3->PB3_CEP							, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Bairro: ' + PB3->PB3_BAIRRO						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Munic.: ' + PB3->PB3_MUN						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Est.: ' + PB3->PB3_EST							, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Tel.: ' + PB3->PB3_TEL							, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Fax: ' + PB3->PB3_FAX   						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Email: ' + PB3->PB3_EMAIL  						, oFont4 ,,,, 0  )
	nLinha += 100
	oPrint:Say( nLinha 	, 0050 , "Dados de Cobrança"	, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090
	oPrint:Say( nLinha 	, 0050 , 'End.: ' + PB3->PB3_ENDCOB						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'N º: ' +  PB3->PB3_NUMCOB						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'CEP: ' + PB3->PB3_CEPCOB						, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Bairro: ' + PB3->PB3_BAIRCB						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Mun. Cob.: ' + PB3->PB3_CIDACO					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Est.: ' + PB3->PB3_UFCOB							, oFont4 ,,,, 0  )
	/*
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Tel.: ' + PB3->PB3_TEL							, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Fax: ' + PB3->PB3_FAX   						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Email: ' + PB3->PB3_EMAIL  						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 0050 , "Dados de Entrega"	, oFont7 ,,,, 0  )
	*/
	nLinha += 100
	oPrint:Say( nLinha 	, 0050 , "Dados de Entrega"	, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090
	oPrint:Say( nLinha 	, 0050 , 'Razão: ' + PB3->PB3_NOMEEN					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Fant.: ' + PB3->PB3_NREDUZ					, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'End.: ' + PB3->PB3_ENDENT						, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'N º: ' +  PB3->PB3_NUMENT					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'CEP: ' + PB3->PB3_CEPENT						, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Bairro: ' + PB3->PB3_BAIREN					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Mun. Ent.: ' + PB3->PB3_CIDENT				, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Est.: ' + PB3->PB3_UFENT						, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Reg.Esp.: ' + PB3->PB3_REGESP					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Imp.End.Entr.: ' + If(PB3->PB3_IMPEND == '1', 'Sim', 'Não')	, oFont4 ,,,, 0  )
	nLinha += 100
	oPrint:Say( nLinha 	, 0050 , "Potencial de Compras"	, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090
	oPrint:Say( nLinha 	, 0050 , 'Lim Sol.: ' + Transform(PB3->PB3_CREDSU,"@E 999,999,999.99")	, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 0450 , 'Prz Sol.: ' + Str(PB3->PB3_PRAZOS)					, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Lim Apr.: ' + Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99")	, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Cond Pgto.: ' + Str(PB3->PB3_PRZAPR)				, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Dt Cad.: '  /*+ ?*/							, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Dt 1 Compra: ' + DtoC(PB3->PB3_PRICOM)				, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Dt Ult.Compra: ' + DtoC(PB3->PB3_ULTCOM)			, oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'Vlr.Maior Acum.: ' + Transform(PB3->PB3_VACUM,"@E 999,999,999.99"), oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Vlr.Maior Compra: ' + Transform(PB3->PB3_MCOMPR,"@E 999,999,999.99"), oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Sld Aberto: ' + Transform(PB3->PB3_MSALDO,"@E 999,999,999.99"), oFont4 ,,,, 0  )
	nLinha += 070
	oPrint:Say( nLinha 	, 0050 , 'M.Atrs.: ' + Transform(PB3->PB3_ATR,"@E 999,999,999.99"), oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 01000 , 'Num Compras: ' + Str(PB3->PB3_NROCOM)				, oFont4 ,,,, 0  )
	oPrint:Say( nLinha 	, 1500 , 'Num Pgtos: ' + Str(PB3->PB3_NROPAG)				, oFont4 ,,,, 0  )
	nLinha += 100
	oPrint:Say( nLinha 	, 0050 , "Referências Comerciais"	, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090
	For i:= 1 to Len(aReferencias)
		oPrint:Say( nLinha 	, 0050 , 'Fornec.: ' + aReferencias[ i, 1 ]					, oFont4 ,,,, 0  )
		oPrint:Say( nLinha 	, 01000 , 'Tel.: ' + aReferencias[ i, 3 ]						, oFont4 ,,,, 0  )
		nLinha += 070
		oPrint:Say( nLinha 	, 0050 , 'Obs.: ' + aReferencias[ i, 4 ]					, oFont4 ,,,, 0  )
		nLinha += 070
	Next i
	nLinha += 100

	oPrint:Say( nLinha	, 0050 , "Pareceres"	, oFont7 ,,,, 0  )
	nLinha += 010
	oPrint:Say( nLinha , 0050 , Replicate( '_',120 ) 		, oFont7 ,,,, 0  )
	nLinha += 090

	For i:= 1 to Len(aPareceres)

		oPrint:Say( nLinha 	, 0050 , 'Data: ' 	+ DtoC(aPareceres[ i, 1 ] ), oFont4 ,,,, 0  )
		oPrint:Say( nLinha 	, 01000 , 'Nome: '	+ aPareceres[ i, 2 ]				, oFont4 ,,,, 0  )
		oPrint:Say( nLinha 	, 1500 , 'Nível: ' 	+ aPareceres[ i, 3 ]				, oFont4 ,,,, 0  )
		oPrint:Say( nLinha 	, 1700 , 'Depto: ' 	+ cDepartamento						, oFont4 ,,,, 0  )
		nLinha += 070

		For J := 1 to Len( aPareceres[i,4]) Step 150
			oPrint:Say( nLinha 	, 0050 , If( j == 1, 'Parecer.: ', '' ) + Substr( aPareceres[ i, 4 ], j, 150), oFont4 ,,,, 0  )
			nLinha += 070
		Next j

	Next i

	oPrint:EndPage()
	oPrint:Preview()

	RestArea( aArea )

Return Nil

/*{Protheus.doc} Static Function AUTSNDENC
	Encaminhamento automatico ao superior
	@type  Function
	@author Alexandre Circenis
	@since 26/03/2010
	@version 01
	@history 
*/

Static Function AutSndEnc(cCodVend, cLojaVend, cVend)
	Local cProvid   := SuperGetMv("FS_AUTPRVD", .F., "ANALISE DE CADASTRO" )
	Local cCredito  := SuperGetMv("FS_NIVCRED", .F., "4" )
	Local cMensagem := ""
	Local cPara     := ""
	Local cDest
	Local lCredito := .F.
	Local lBackOffice  :=  GetAdvFVal( 'PB2', 'PB2_BCKOFI', xFilial( 'PB2' ) + __cUserId, 1) = '1' // eh Back Office
	Local cDepto	:= GetAdvFVal( 'PB1', 'PB1_DEPTO', xFilial( 'PB1' ) + __cUserId, 1)    &&Mauricio - Chamado 035857 - 14/07/17

	if lBackOffice
		cVend := PB3->PB3_VEND
	endif

	&&Mauricio - Chamado 035857 - 14/07/17
	//if PB3->PB3_SITUAC == "4" .And. !(cDepto $ '000002/000001') &&em analise

	if PB3->PB3_SITUAC $ '2/4' .And. !(cDepto $ '000002/000001') &&em analise  // Fernando - Chamado: 036496 - 01/08/2017
		Alert( 'Cliente em Analise de Credito não pode ser reencaminhado!Aguarde retorno da analise em andamento.')	  
		Return
	endif

	dbSelectArea("SA3")
	dbSetOrder(7)
	if dbSeek(xFilial("SA3")+cVend)	

		cDest  := Iif( SA3->A3_COD == SA3->A3_SUPER, SA3->A3_GEREN, SA3->A3_SUPER )

		if SA3->A3_SUPER == SA3->A3_GEREN
			cDest := GetAdvFVal("PB1", "PB1_CODIGO", xFilial("PB1") + cCredito, 3, " ")
		else
			cDest := GetAdvFVal("SA3", "A3_CODUSR", xFilial("SA3") + cDest, 1, " ")
		endif

		If Select("PB1") <= 0
			DbSelectArea("PB1")
		EndIf

		If ( SuperGetMv("FS_NIVCRED", .F., 0 ) <= GetAdvFVal("PB1", "PB1_NIVEL", xFilial("PB1") + cVend, 1, " ") )
			lCredito := .T.
		EndIf

		cNomeUsr := AllTrim( GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + cVend, 1, " ") )

		// Gravacao do Log
		cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_VENENC', 'X3_Titulo' ), PB3->PB3_VENENC+ " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + PB3->PB3_VENENC, 1, " "), cDest + " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + cDest, 1, " ") )
		cMensagem += chr(13) + chr(10)

		cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_ENCAMI', 'X3_Titulo' ), PB3->PB3_ENCAMI+ " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + PB3->PB3_ENCAMI, 1, " "), cVend + " - " + GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") +  cVend, 1, " ") )
		cMensagem += chr(13) + chr(10)

		if PB3->PB3_PROVID <> cProvid
			cMensagem += U_Ado05Log( cCodvend, cLojaVend, cNomeUsr, dDataBase, Posicione('SX3', 2,'PB3_PROVID', 'X3_Titulo' ), PB3->PB3_PROVID, cProvid )
			cMensagem += chr(13) + chr(10) 
		endif	

		RecLock( 'PB3', .F. )

		// Vendedor para onde o cliente foi encaminhado.
		PB3->PB3_VENENC := cDest
		// Vendedor que esta encaminhando.
		PB3->PB3_ENCAMI := cVend //+ " - " + GetAdvFVal("SA3", "A3_NREDUZ", xFilial("SA3") + cVend, 7, " ")
		// Providencias a serem tomadas.
		PB3->PB3_PROVID := cProvid
		// Parecer não incluido
		PB3->PB3_PARECE := .F.
		// Grava a data de envio

		If lCredito
			PB3->PB3_DTENVI := dDataBase
			PB3->PB3_SITUAC := '1'
		Endif

		PB3->( MsUnLock())

		cPara	:= GetAdvFVal("SA3", "A3_EMAIL", xFilial("SA3") + Iif( SA3->A3_COD == SA3->A3_SUPER, SA3->A3_GEREN, SA3->A3_SUPER ), 1, " ")

		dbSelectArea("SA3")
		dbSetOrder(1)

		If ! Empty( cPara )

			cMensagem := "Foi encaminhado o cadastro abaixo para as suas providencais"+chr(13) + chr(10)
			cMensagem += chr(13) + chr(10)
			cMensagem += "Codigo       : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
			cMensagem += "Loja         : "+ PB3->PB3_LOJA+chr(13) + chr(10)
			cMensagem += "Cliente      : "+ PB3->PB3_NOME+chr(13) + chr(10)
			cMensagem += "CNPJ/CPF     : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
			cMensagem += "Vendedor     : "+ GetAdvFVal("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
			"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
			cMensagem += "Motivo Envio : "+ Left(PB3->PB3_MOTACE,2)+"-"+GetAdvFval( 'PB4', 'PB4_DESCRI', xFilial( 'PB4' ) + Left(PB3->PB3_MOTACE,2), 1	)	+chr(13) + chr(10)

			CriaMail(cPara, 'Cadastro Enviado', cMensagem, /*''*/,, .F., .F.,cCodVend, cLojaVend)
		Else
			Aviso("Atenção","Nao foi localizado e-mail para encaminhamento do cadastro. O campo e-mail do vendedor -> " + Iif( SA3->A3_COD == SA3->A3_SUPER, SA3->A3_GEREN, SA3->A3_SUPER ) + " não esta preenchido!",{"Ok"})
		EndIf
	else
		Aviso("Atenção","O vendedor código "+cVend+" não encontrato no cadastro de vendedores impossivel determinar o superior",{"Ok"})
	endif

Return

/*{Protheus.doc} Static Function ADOA5LEG
	Legenda da Tela de aprovacao
	@type  Function
	@author Alexandre Circenis
	@since 12/04/2010
	@version 01
	@history 
*/

Static Function Adoa5Leg()
	BrwLegenda("Aprovação de Crédito","Legenda",{	{"BR_BRANCO",OemToAnsi("Normal")},;
	{"BR_VERDE",OemToAnsi("Observação")},;
	{"BR_VERMELHO",OemToAnsi("Prioridade Alta")},;
	{"BR_AZUL",OemToAnsi("Aprovado")}})
Return

/*{Protheus.doc} Static Function ADOGETCAMPOS
	Transforma a variavel caracter em array para permissao de alteracao de campos da MSMGET
	@type  Function
	@author Vogas Junior
	@since 31/08/2009
	@version 01
	@history 
*/

Static Function AdoGetCampos(cCampoAlt, lCredito)
	Local nReg
	Local aRetorno	:= {}
	/*
	Local i 		:= 0
	Local cCampo	:= ''

	For i:= 1 to Len( cCampoAlt )
	Do Case
	Case SubStr( cCampoAlt, i, 1 ) != ' ' .And. SubStr( cCampoAlt, i, 1 ) != ','
	cCampo += SubStr( cCampoAlt, i, 1 )
	OtherWise
	If !Empty( cCampo )
	aAdd( aRetorno, cCampo)
	cCampo := ''
	Endif
	EndCase
	Next i
	*/

	aRetorno := StrToKarr(AllTrim(cCampoAlt),',')
	if lCredito

		dbSelectArea("SX3")
		nReg := Recno()
		dbSetOrder(4)
		dbSeek("PB3"+"8")

		while SX3->X3_ARQUIVO = "PB3" .and. SX3->X3_FOLDER = '8'
			aadd(aRetorno,SX3->X3_CAMPO )
			dbSkip()
		enddo

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbGoto(nReg)

	endif

Return (aRetorno)

/*{Protheus.doc} User Function FLTPB305
	Sem deatalhamento
	@type  Function
	@author Alexandre Circenis
	@since 08/11/2010
	@version 01
	@history 
*/
                                                              
User function FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cVendedor, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSupervisor,cGerente )

	Local cQuery := ""
	Local aArea		:= GetArea()
	Local nCntFor2 	:= 0
	Local aUsuSetor	:= If( Empty( cSetor ), {}, GetUsuarios( cSetor ))
	//Local cSuperv	:= Posicione( 'SA3', 1, xFilial('SA3') + PB3->PB3_VEND, 'A3_SUPER')
	Local cResp 	:= ""
	Local nX
	Local nLinha

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	if lFilPB3
		Return
	endif

	lFilPB3 := .T.

	if cCodAnalise = '4'
		cCodAnalise := ''
		cResp 		:= __cUserId
	endif

	cQuery := "SELECT R_E_C_N_O_ REC"
	cQuery += " FROM "+RetSqlName("PB3")+" (NOLOCK) PB3"
	cQuery += " WHERE PB3_FILIAL ='"+xFilial("PB3")+"'"


	if !Empty(cMotivo) .Or. cMotivo $AllTrim(PB3->PB3_MOTACE)
		cQuery += " AND PB3_MOTACE LIKE '%"+cMotivo+"%'"
	endif

	if !Empty( cCNPJ )
		cQuery += " AND PB3_CGC LIKE '"+AllTrim(cCNPJ)+"%'"
	endif

	if !Empty( cRazao )
		cQuery += " AND PB3_NOME LIKE '%"+AllTrim(cRazao)+"%'"
	endif

	if !Empty( cCliente )
		cQuery += " AND PB3_CODSA1 LIKE '%" +AllTrim( cCliente )+"%'"
	endif

	If !Empty( cVendedor )
		cQuery += " AND PB3_VEND = '"+ cVendedor+"'"
	endif

	if !Empty( cCodAnalise )
		cQuery += " AND PB3_SITUAC ='"+cCodAnalise+"'"
	endif

	If !Empty( cSetor )
		cQuery += " AND PB3_VEND IN ("
		if Len(aUsuSetor) > 0
			for nX := 1 to Len(aUsuSetor)
				cQuery += if(nx=1,"",",")+"'"+aUsuSetor[nX]+"'"
			next nX
		else
			cQuery += "	'******' "
		endif
		cQuery += "	) "
	endif

	if !Empty( cSigla )
		cQuery += " AND PB3_EST ='"+ cSigla+"'"
	endif

	if !Empty( cEnviado )
		cQuery += " AND PB3_ENCAMI ='"+ AllTrim(cEnviado)+"%'"//GetEnviado( PB3->PB3_COD, PB3->PB3_LOJA, cEnviado )
	endif

	if !empty( dData )  //AdoGetData( PB3->PB3_COD, PB3->PB3_LOJA, dData )
		cQuery += " AND PB3_DTENVI = '"+Dtos(dData)+"'"
	endif

	if !empty( cSupervisor )
		//cListSup := Getsuper()
		cQuery += " AND EXISTS (SELECT 1"
		cQuery += "  FROM "+RetSqlName("SA3")+" (NOLOCK) SA31"
		cQuery += "  WHERE A3_FILIAL = '"+xFilial("SA3")+"'"
		cquery += "  AND A3_CODUSR = PB3.PB3_VEND "
		cquery += "  AND A3_CODUSR <> '"+Criavar('A3_CODUSR')+"'"
		cQuery += "  AND A3_SUPER IN " + Formatin(cSupervisor,"/") + " "
		cQuery += "  AND SA31.D_E_L_E_T_ = ' ')"
	endif

	if !empty( cGerente )
		cQuery += " AND EXISTS (SELECT 1"
		cQuery += "  FROM "+RetSqlName("SA3")+" (NOLOCK) SA32"
		cQuery += "  WHERE A3_FILIAL = '"+xFilial("SA3")+"'"
		cquery += "  AND A3_CODUSR = PB3.PB3_VEND "
		cquery += "  AND A3_CODUSR <> '"+Criavar('A3_CODUSR')+"'"
		cQuery += "  AND A3_GEREN IN "+ Formatin(cGerente, "/") + " "
		cQuery += "  AND SA32.D_E_L_E_T_ = ' ')"
	endif

	if !Empty(cResp)
		cQuery += " AND PB3_VENENC ='"+cResp+"'"
	endif

	cQuery += " AND PB3.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY PB3_CODSA1, PB3_LOJSA1"

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf

	DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "TRB", .F., .T. )
	dbSelectArea( "TRB" )

	while !TRB->(Eof())

		aAdd(aCols,Array(Len(aHeader)+1))
		nLinha := Len(aCols)
		For nCntFor2 := 1 To Len(aHeader)
			dbSelectArea("PB3")
			dbGoto(TRB->REC)

			If ( aHeader[nCntFor2][10] != "V" )
				aCols[nLinha][nCntFor2 ] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
			else
				Do Case
					Case AllTrim(aHeader[nCntFor2][1]) == 'Bloqueado' .or. AllTrim(aHeader[nCntFor2][1]) == 'Bloqueado ?'
						aCols[nLinha][nCntFor2] := Iif(AllTrim(PB3->PB3_BLOQUE)=="1","Sim","Nao")
					Case aHeader[nCntFor2][1] == 'Setor'
					//					aCols[nLinha][nCntFor2] := Posicione( 'PB1', 1, xFilial('PB1') + PB3->PB3_VEND, 'PB1_DESDEP')
					aCols[nLinha][nCntFor2] := GetAdvFVal( 'PB1', 'PB1_DESDEP', xFilial('PB1') + PB3->PB3_VEND, 1)
					Case aHeader[nCntFor2][1] == 'Supervisor'
					//					aCols[nLinha][nCntFor2] := Posicione( 'SA3', 7, xFilial('SA3') + PB3->PB3_VEND , 'A3_SUPER'/*'A3_NOME'*/)
					aCols[nLinha][nCntFor2] := GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND , 7)
					Case aHeader[nCntFor2][1] == 'Usuario'
					//					aCols[nLinha][nCntFor2] := Posicione( 'SA3', 1, xFilial('SA3') + PB3->PB3_VEND , 'A3_COD'/*'A3_NOME'*/)
					aCols[nLinha][nCntFor2] := GetAdvFVal( 'SA3', 'A3_COD', xFilial('SA3') + PB3->PB3_VEND , 1)
					/* Esse campo foi substituido pelo campo PB3_CODVEN 
					Case aHeader[nCntFor2][1] == 'Vendedor'
					aCols[nLinha][nCntFor2] := Posicione("SA3",7,xFilial("SA3")+PB3->PB3_VEND,"A3_COD")
					*/
					Case aHeader[nCntFor2][1] == 'Nivel'
					aCols[nLinha][nCntFor2] := GetAdvFVal("PB1", "PB1_NIVEL", xFilial("PB1") +PB3->PB3_VENENC, 1, " ")
					Case nCntFor2 = 1
					aCols[nLinha][nCntFor2] := If( PB3->PB3_SITUAC == '2','BR_AZUL',if( Empty( PB3->PB3_OBSAPR) .And. PB3->PB3_PRIOR != "1" , "BR_BRANCO", IF( PB3->PB3_PRIOR == "1", "BR_VERMELHO", "BR_VERDE")))
					otherwise
					aCols[nLinha][nCntFor2] := CriaVar(aHeader[nCntFor2][2],.T.)
				endcase
			EndIf

		Next nCntFor2

		//	aCols[nLinha, 1 ] := Eval( &('{ ||' + aHeader[1][12] + '}' ) )
		aCols[nLinha, Len(aHeader)+1] := .F.
		If nlinha >= 500
			Alert("Numero de clientes muito alto, Somente os primeiros 500 serão apresentados")
			exit
		endif
		AADD(aRecs, PB3->(Recno()))
		TRB->(dbSkip())

	enddo

	lFilPB3 := .F.

	TRB->(dbCloseArea())
	RestArea(aArea)

Return

/*{Protheus.doc} Static Function LOADGDX
	Rotina para carga do acols da getdados
	@type  Function
	@author Alexandre Circenis
	@since 10/10/2007
	@version 01
	@history 
*/

Static Function LoadGDX(aHeader,aCols, cMotivo, cSetor, cCNPJ, cRazao, cCliente, cVendedor, cSuperv, cAnalise, cSigla, cEnviado, dData )

	Local nX, nCntFor, nCntFor2
	Local aArea			:=	GetArea()
	Local aLinha		:=	{}
	Local nUsado		:=	Len(aHeader)
	Local nPos			:=	0
	Local nLin 			:=	0
	Local cCampo    	:= ""
	Local cGerente		:= ''
	Local cSupervisor	:= ''
	Local lVendedor		:= .F.
	Local lGerente		:= .F.
	Local lSupervisor	:= .F.
	Local aVendGer		:= {}
	Local aVendSup		:= {}
	Local lUsuario		:= .F.
	Local aUsuSetor		:= If( Empty( cSetor ), {}, GetUsuarios( cSetor ))
	Local oBranco		:= LoadBitMap(GetResources(), "BR_BRANCO")
	Local oVerde		:= LoadBitMap(GetResources(), "BR_VERDE")
	Local oVermelho		:= LoadBitMap(GetResources(), "BR_VERMELHO")
	local cteste		:= 'BR_BRANCO'
	Local aComboAnalise	:= {'Em Análise', 'Aprovado', 'Reprovado',"Pendencia"}
	Local cCodAnalise	:= ''
	Local nNivelCred  	:= Val( SuperGetMv("FS_NIVCRED", .F., 0 ) )
	Local cVenOld
	Local lBackOffice := .F.

	/*
	Local nNivelVend  	:= Val( SuperGetMv("FS_NIVVEN", .F., 0 ) )
	Local nNivelSup  	:= Val( SuperGetMv("FS_NIVSUP", .F., 0 ) )
	Local nNivelGer  	:= Val( SuperGetMv("FS_NIVGER", .F., 0 ) )
	*/
	//Local nNivelUsr		:= Val( Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NIVEL'))
	Local nNivelUsr		:= Val( GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1))

	Local nPosCli  		:= Ascan(aHeader,{|x| Alltrim(x[2])=='PB3_COD'})
	Local nPosLoja  	:= Ascan(aHeader,{|x| Alltrim(x[2])=='PB3_LOJA'})
	Local cListVend     := ''

	Default cSetor 		:= ''
	Default cCNPJ  		:= ''
	Default cRazao		:= ''
	Default cCliente	:= ''
	Default cVendedor 	:= ''
	Default cSuperv 	:= ''

	if PB2->(FieldPos("PB2_BCKOFI")) > 0
		//	lBackOffice  :=  Posicione( 'PB2', 1, xFilial( 'PB2' ) + __cUserId, 'PB2_BCKOFI') = '1' // eh Back Office
		lBackOffice  :=  GetAdvFVal( 'PB2', 'PB2_BCKOFI', xFilial( 'PB2' ) + __cUserId, 1) = '1' // eh Back Office
	else
		Aviso("Atenção","Rotina de Back Office ainda não implementada, falta criar o campo PB2_BCKOFI",{"Ok"})
	endif

	If !Empty(cVendedor)
		cVendOld := cVendedor
		//	cVendedor := Posicione( 'SA3', 1, xFilial('SA3') + cVendOld, 'A3_CODUSR')
		cVendedor := GetAdvFVal( 'SA3', 'A3_CODUSR', xFilial('SA3') + cVendOld, 1)
		if Empty(cVendedor)
			cVendedor := "$$$$$$"
		endif	  
	Endif

	// Verifica se Usuario logado e vendedor, gerente ou supervisor.
	DbSelectArea('PB1')
	PB1->( DbSetOrder(1))
	If PB1->( DbSeek( xFilial('PB1') + cCodVen ))
		lUsuario := .T.
		Do Case
			Case PB1->PB1_NIVEL == SuperGetMv("FS_NIVVEN", .F., 0 ) .and. !lBackOffice //'1'
			lVendedor := .T.
			Case PB1->PB1_NIVEL == SuperGetMv("FS_NIVSUP", .F., 0 ) .and. !lBackOffice //'2'
			lSupervisor := .T.
			Case PB1->PB1_NIVEL == SuperGetMv("FS_NIVGER", .F., 0 ) .and. !lBackOffice //'3'
			lGerente := .T.
		EndCase
	Endif

	Do Case
		Case lSupervisor .Or. ! Empty( cSuperv )
		//		cSupervisor  := Posicione( 'SA3', 7, xFilial('SA3') + cCodVen, 'A3_COD')
		cSupervisor	:= GetSuper(cCodVen)
		Case lGerente
		//		cGerente := Posicione( 'SA3', 7, xFilial('SA3') + cCodVen, 'A3_COD')
		cGerente	:= GetGeren(cCodVen)
	EndCase

	cCodAnalise	:= If( Ascan( aComboAnalise, cAnalise ) > 0, Str( Ascan( aComboAnalise, cAnalise ), 1, 0), ' ')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do Acols - PB3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If INCLUI
		aAdd(aCols,Array(nUsado+1))
		For nX := 1 To Len(aHeader)
			aCols[1, nX] := CriaVar(aHeader[nX, 2])
		Next nX
		aCols[Len(aCols), Len(aHeader)+1] := .F.
		aCols[Len(aCols), 1] := "001"
	Else
		/*
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("PB3")
		While ( !Eof() .And. SX3->X3_ARQUIVO == "PB3" )
		If X3USO(SX3->X3_USADO)
		cCampo := SX3->X3_CAMPO
		if FieldPos(cCampo) > 0
		M->&(cCampo) := PB3->(FieldGet(FieldPos(cCampo)))
		endif
		EndIf
		dbSkip()
		EndDo
		*/
		DbSelectArea('PB3')
		PB3->( DbGoTop())
		// Filtro para usuarios do setor de vendas
		If lVendedor .Or. lGerente .Or. lSupervisor
			//	DbSelectArea('PB3')
			PB3->(dbSetOrder(10))
			Do Case
				// Caso Vendedor pega registros do PB3 referentes a este vendedor
				Case lVendedor
				MsAguarde({|| U_FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cCodVen, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSuperv ) },"Aguarde","Executando U_FltPB305")
				// Caso Gerente ou Supervisor, pega registro de todos os vendedores agregados a ele
				Case lSupervisor
				MsAguarde({|| U_FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cVendedor, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSupervisor ) },"Aguarde","Executando U_FltPB305")
				Case lGerente
				MsAguarde({|| U_FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cVendedor, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSuperv, cGerente ) },"Aguarde","Executando U_FltPB305")
			EndCase
			// Usuarios do Nivel de Credito
		ElseIf nNivelUsr >= nNivelCred .or. lBackOffice

			MsAguarde({|| U_FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cVendedor, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSuperv ) },"Aguarde","Executando U_FltPB305")

		Else

			MsAguarde({|| U_FltPB305( aHeader, aCols, cMotivo, cCNPJ, cRazao, cCliente, cVendedor, cCodAnalise, cSetor, cSigla, cEnviado, dData, cSuperv ) },"Aguarde","Executando U_FltPB305")

		EndIf
	Endif
	//If ! Empty( aCols )
	//	Asort( aCols,,,{ |x, y| x[2] < y[2] })
	//Endif
	lRetLoadGDX := lUsuario
	RestArea(aArea)

Return ( lUsuario )

/*{Protheus.doc} User Function LIMREDE
	Calcula o limite de uma rede
	@type  Function
	@author Sem autor
	@since 15/09/2010
	@version 01
	@history 
*/

User FUNCTION LimRede(cCODRED)

	Local nTotal := 0
	Local aArea := GetArea()

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	DbSelectArea( 'SZF' )
	DbSetOrder( 3 )

	DbSeek( xFilial('SZF') + cCODRED)

	while !Eof() .and. SZF->ZF_REDE = cCodRed
		nTotal += SZF->ZF_LCREDE
		dbSkip()
	enddo
	RestArea(aArea)                             

Return nTotal


/*{Protheus.doc} Static Function MNTCPARA
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function mntcPara(cPara,cNovo)

	Local cRet := ""
	If Empty(cPara)
		cRet := cNovo
	Else
		If right(alltrim(cpara),1) <> ";"
			cRet := cPara + ";" + cNovo
		Else
			cRet := cPara + cNovo
		Endif
	Endif 

Return cRet

/*{Protheus.doc} Static Function GETSUPER
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function GetSuper(cCodVen)

	Local cRet := ""
	Local cPrefix:= ""
	Local aAreaSav	:= GetArea()
	Local aAreaSA3	:= SA3->( GetArea() )

	dbSelectArea("SA3")
	dbSetOrder(7)
	dbSeek( xFilial("SA3") + cCodVen )

	While SA3->( !Eof() ) .and. Alltrim(Upper( SA3->A3_CODUSR )) == Alltrim(Upper( cCodVen ))
		cRet += cPrefix + SA3->A3_COD
		cPrefix:= "/"
		SA3->( dbSkip() )
	End

	If Empty(cRet) 
		cRet := Replicate("*",TamSx3("A3_COD")[1])+"/"
	Endif

	RestArea(aAreaSA3)
	RestArea(aAreaSav)

Return cRet

/*{Protheus.doc} Static Function GETGEREN
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function GetGeren(cCodVen)

	Local cRet := ""
	Local cPrefix:= ""
	Local aAreaSav	:= GetArea()
	Local aAreaSA3	:= SA3->( GetArea() )

	dbSelectArea("SA3")
	dbSetOrder(7)
	dbSeek( xFilial("SA3") + cCodVen )

	While SA3->( !Eof() ) .and. Alltrim(Upper( SA3->A3_CODUSR )) == Alltrim(Upper( cCodVen ))
		cRet += cPrefix + SA3->A3_COD
		cPrefix:= "/"
		SA3->( dbSkip() )
	End

	If Empty(cRet) 
		cRet := Replicate("*",TamSx3("A3_COD")[1])+"/"
	Endif

	RestArea(aAreaSA3)
	RestArea(aAreaSav)

Return cRet

/*{Protheus.doc} Static Function ADOATURED
	Inclui/Altera dados do cadastro de clientes (SA1) mediante as informacoes do cadastro espelho de clientes (PB3)
	@type  Function
	@author Vogas Junior
	@since 29/09/2019
	@version 01
	@history 
*/

Static Function AdoAtuRed( cCodPB3, cLojaPB3,nPB3_DESC,cPB3_CODRED,cPB3_NOMEAS,cPB3_TPREDE,dPB3_VENCLC)

	Local aArea       := GetArea()
	Local lRet 	      := .F.
	Local dPB3_VENCLC := M->PB3_VENCLC // Ticket 8099 - 15/01/2021 - ADRIANO SAVOINE
	Local cPB3_BCO1   := M->PB3_BCO1   // Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
	Local cPB3_COND   := M->PB3_COND   // Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
	Local cPB3_ANCC	  := M->PB3_XTPDES // Everson - 14/10/2021. Chamado 13526. 		
	Private oDlg01
	Private oFont1

	&&Mauricio - 25/04/17 - Chamado 034838 - Separar tratamento para associação quando não for REDE!
	IF cPB3_TPREDE == "A" .And. Empty(cPB3_CODRED)
		DEFINE MSDIALOG oDlg01 FROM 00,00 TO 400,800 TITLE "REPLICACAO/ATUALIZACAO CAMPOS TABELAS SA1 e PB3" PIXEL        //500,800

		DEFINE Font oFont1 Name "Arial" SIZE 0,-12 Bold
		@005,005 TO 045,390 OF oDlg01 PIXEL   //045,180
		@010,010 SAY "Esta rotina ira atualizar os campos das tabelas SA1 e PB3 relativos ao  " Font oFont1 OF oDlg01 PIXEL
		@020,010 SAY "desconto e associação, tendo como base os dados do registro posicionado, mostrados nesta tela. " Font oFont1 OF oDlg01 PIXEL
		@030,010 SAY ""	Font oFont1 OF oDlg01 PIXEL

		@050,007 SAY "CLIENTE PB3: " Font oFont1 OF oDlg01 PIXEL
		@050,080 SAY cCODPB3 SIZE 40,10 OF oDlg01 PIXEL

		@050,180 SAY "LOJA PB3: " Font oFont1 OF oDlg01 PIXEL
		@050,240 SAY cLojaPB3 SIZE 40,10 OF oDlg01 Pixel

		_cNMPB3  := Posicione("PB3",1,xFilial("PB3")+cCODPB3+cLojaPB3,"PB3_NOME")
		_cCGCPB3 := Posicione("PB3",1,xFilial("PB3")+cCODPB3+cLojaPB3,"PB3_CGC")
		_cPB3SA1 := Posicione("PB3",1,xFilial("PB3")+cCODPB3+cLojaPB3,"PB3_CODSA1")

		@065,007 SAY "CNPJ: " Font oFont1 OF oDlg01 Pixel
		@065,080 SAY ALLTRIM(_cCGCPB3) PICTURE "@R 99.999.999/9999-99" SIZE 90,10 OF oDlg01 PIXEL

		@065,180 SAY "NOME: " Font oFont1 OF oDlg01 PIXEL
		@065,240 SAY ALLTRIM(_cNMPB3) SIZE 150,10 OF oDlg01 Pixel

		@095,007 SAY "Desconto: " Font oFont1 OF oDlg01 PIXEL
		@095,080 SAY nPB3_DESC PICTURE "@E 999.99" SIZE 60,10 Font oFont1 OF oDlg01 Pixel

		_cTpR := "Associacao de compra"

		@095,180 SAY "Tipo : " Font oFont1 OF oDlg01 PIXEL
		@095,240 SAY _cTpR  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL

		// Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
		@110,180 SAY "Banco : " Font oFont1 OF oDlg01 PIXEL
		@110,240 SAY cPB3_BCO1  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL

		@110,007 SAY "Associação: " Font oFont1 OF oDlg01 PIXEL
		@110,080 SAY cPB3_NOMEAS  SIZE 60,10 Font oFont1 OF oDlg01 Pixel

		// Ticket 8099 - 15/01/2021 - ADRIANO SAVOINE
		@125,007 SAY "Data Lim. Credito: " Font oFont1 OF oDlg01 PIXEL
		@125,080 SAY dPB3_VENCLC  SIZE 60,10 Font oFont1 OF oDlg01 Pixel

		// Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
		@125,180 SAY "Cond. Pagamento: " Font oFont1 OF oDlg01 PIXEL
		@125,240 SAY cPB3_COND  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL 

		//Everson - 14/10/2021. Chamado 13526.
		@140,007 SAY "Apuração NCC: " Font oFont1 OF oDlg01 PIXEL
		@140,080 SAY cPB3_ANCC  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL 
		//
		
		@160,150 BMPBUTTON TYPE 1 ACTION(lRet := .T.,Close(oDlg01))
		@160,185 BMPBUTTON TYPE 2 ACTION(lRet := .F.,Close(oDlg01))

		ACTIVATE DIALOG oDlg01 CENTERED

		IF lRet
			IF MsgYesNo(OEMTOANSI("Confirma inicio da atualização/replicação?"),OEMTOANSI("A T E N Ç Ã O"))

				PROCESSA({||  fReplAss(nPB3_DESC,cCODPB3,cLojaPB3,cPB3_NOMEAS,cPB3_TPREDE,_cCGCPB3,_cPB3SA1,_cNMPB3,cPB3_ANCC)},"atualizando...") // Everson - 14/10/2021. Chamado 13526.
				U_CREDITOLOG(cCodPB3, cLojaPB3,ALLTRIM(cusername),"Atualiza SA1_PB3_SZF") //chamado 036175 05/01/2018 WILLIAM COSTA

			ENDIF
		ENDIF
	Else
		DBSELECTAREA("SZF")
		DBSETORDER(3)
		IF DBSEEK(xFilial("SZF") + cPB3_CODRED, .T.) // Busca exata

			DEFINE MSDIALOG oDlg01 FROM 00,00 TO 400,800 TITLE "REPLICACAO/ATUALIZACAO CAMPOS TABELAS SZF, SA1 e PB3" PIXEL        //500,800

			DEFINE Font oFont1 Name "Arial" SIZE 0,-12 Bold
			@005,005 TO 045,390 OF oDlg01 PIXEL   //045,180
			@010,010 SAY "Esta rotina ira atualizar demais campos da tabelas SZF relativos a esta rede e tambem os campos das tabelas SA1 e PB3 relativos ao  " Font oFont1 OF oDlg01 PIXEL
			@020,010 SAY "desconto, tipo de rede e associação, tendo como base os dados do registro posicionado, mostrados nesta tela. " Font oFont1 OF oDlg01 PIXEL
			@030,010 SAY ""	Font oFont1 OF oDlg01 PIXEL

			@050,007 SAY "CODIGO REDE: " Font oFont1 OF oDlg01 PIXEL
			@050,080 SAY SZF->ZF_REDE SIZE 40,10 OF oDlg01 PIXEL

			@050,180 SAY "NOME REDE: " Font oFont1 OF oDlg01 PIXEL
			@050,240 SAY ALLTRIM(SZF->ZF_NOMERED) SIZE 150,10 OF oDlg01 Pixel

			@065,007 SAY "Matriz CNPJ: " Font oFont1 OF oDlg01 Pixel
			@065,080 SAY SZF->ZF_CGCMAT PICTURE "@R 99999999" SIZE 80,10 OF oDlg01 PIXEL

			@065,180 SAY "Cozinha INDL: " Font oFont1 OF oDlg01 PIXEL
			@065,240 SAY SZF->ZF_COZINDL  SIZE 40,10 OF oDlg01 PIXEL

			@095,007 SAY "Desconto: " Font oFont1 OF oDlg01 PIXEL
			@095,080 SAY nPB3_DESC PICTURE "@E 999.99" SIZE 60,10 Font oFont1 OF oDlg01 Pixel

			_cTpR := ""

			IF cPB3_TPREDE == "R"
				_cTpR := "REDE"
			ELSEIF cPB3_TPREDE == "G"
				_cTpR := "Grupo Economico"
			ELSEIF cPB3_TPREDE == "A"
				_cTpR := "Associacao de compra"
			ELSEIF cPB3_TPREDE == "C"
				_cTpR := "Cozinha Industrial"
			ENDIF

			@095,180 SAY "Tipo Rede: " Font oFont1 OF oDlg01 PIXEL
			@095,240 SAY _cTpR  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL
			
			// Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
			@110,180 SAY "Banco: " Font oFont1 OF oDlg01 PIXEL
			@110,240 SAY cPB3_BCO1  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL

			@110,007 SAY "Associação: " Font oFont1 OF oDlg01 PIXEL
			@110,080 SAY cPB3_NOMEAS  SIZE 60,10 Font oFont1 OF oDlg01 Pixel

			// Ticket 8099 - 15/01/2021 - ADRIANO SAVOINE
			@125,007 SAY "Data Lim. Credito: " Font oFont1 OF oDlg01 PIXEL
			@125,080 SAY dPB3_VENCLC  SIZE 60,10 Font oFont1 OF oDlg01 Pixel 

			// Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
			@125,180 SAY "Cond. Pagamento: " Font oFont1 OF oDlg01 PIXEL
			@125,240 SAY cPB3_COND  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL 

			//Everson - 14/10/2021. Chamado 13526.
			@140,007 SAY "Apuração NCC: " Font oFont1 OF oDlg01 PIXEL
			@140,080 SAY cPB3_ANCC  SIZE 80,10 Font oFont1 OF oDlg01 PIXEL 
			//

			@160,150 BMPBUTTON TYPE 1 ACTION(lRet := .T.,Close(oDlg01))
			@160,185 BMPBUTTON TYPE 2 ACTION(lRet := .F.,Close(oDlg01))

			ACTIVATE DIALOG oDlg01 CENTERED

			IF lRet
				IF MsgYesNo(OEMTOANSI("Confirma inicio da atualização/replicação?"),OEMTOANSI("A T E N Ç Ã O"))

					PROCESSA({||  fReplica(nPB3_DESC,cPB3_CODRED,cPB3_NOMEAS,cPB3_TPREDE,dPB3_VENCLC,cPB3_COND,cPB3_BCO1,cPB3_ANCC)},"atualizando...") //Everson - 14/10/2021. Chamado 13526.
					U_CREDITOLOG(cCodPB3, cLojaPB3,ALLTRIM(cusername),"Atualiza SA1_PB3_SZF") //chamado 036175 05/01/2018 WILLIAM COSTA

				ENDIF
			ENDIF

		ELSE

			MSGSTOP("Não Existe Rede para esse Cliente,Favor Verificar!!!")

		ENDIF

		SZF->( DBCLOSEAREA() )

	Endif

	RestArea(aArea)

RETURN(NIL)

/*{Protheus.doc} Static Function FREPLICA
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

STATIC FUNCTION fReplica(nPB3_DESC,cPB3_CODRED,cPB3_NOMEAS,cPB3_TPREDE,dPB3_VENCLC,cPB3_COND,cPB3_BCO1,cPB3_ANCC)

	Local aArea:= GetArea()
	_nIndexSZF := IndexOrd()
	_nRecnoSZF := RECNO()
	_cRede     := cPB3_CODRED
	_cMatR     := SZF->ZF_CGCMAT
	_nDescB    := nPB3_DESC
	_cTpRed    := cPB3_TPREDE
	_cAssoc    := cPB3_NOMEAS
	_cLimcred  := DTOS(dPB3_VENCLC) // Ticket 8099 - 15/01/2021 - ADRIANO SAVOINE
	_cBanco    := cPB3_BCO1 // Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE
	_cCondP    := cPB3_COND // Ticket 8191 - 19/01/2021 - ADRIANO SAVOINE

	DBSETORDER(3)
	SZF->(DBGOTOP())
	PROCREGUA(RECCOUNT())
	IF DBSEEK(Xfilial("SZF")+_cRede)    

		WHILE SZF->(!EOF()) .And. _cRede == SZF->ZF_REDE
			INCPROC("Replicando/atualizando Rede: "+SZF->ZF_REDE+" Matriz CNPJ: "+SZF->ZF_CGCMAT)

			IF !(SZF->ZF_CGCMAT == _cMatr)
				Reclock("SZF",.F.) 
				SZF->ZF_ZZDESCB := _nDescB
				SZF->ZF_TPREDE  := _cTpRed
				SZF->ZF_NOMEASS := _cAssoc         
				SZF->(MsUnlock())
			ENDIF

			//Everson - 13/12/2017. Chamado - 038633.
			DbSelectArea("ZBE")
			RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH Date()
			Replace ZBE_HORA 	   	WITH Time()
			Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("Alteração de desconto financeiro (A1_ZZDESCB) de " + Alltrim(cValToChar(SA1->A1_ZZDESCB)) + " para " + Alltrim(cValToChar(_nDescB)) + " ")  
			Replace ZBE_MODULO	    WITH "FINANCEIRO"
			Replace ZBE_ROTINA	    WITH "ADOA005" 
			Replace ZBE_PARAME      WITH ("CNPJ RAIZ: " + Alltrim(SZF->ZF_CGCMAT) + " REDE: " + _cRede )
			ZBE->( MsUnLock())
			//

			&&atualizacao para SA1
			_cQuery1:=""
			_cQuery1:=" UPDATE 	"+retsqlname("SA1")+" WITH(UPDLOCK) SET A1_CODRED='"+alltrim(_cRede)+"' , A1_ZZDESCB="+alltrim(STR(_nDescB))+" , A1_TPREDE='"+_cTpRed+"' , A1_NOMEASS='"+_cAssoc+"' , A1_VENCLC='"+_cLimcred+"',"
			_cQuery1+=" A1_BCO1='"+_cBanco+"', A1_COND='"+_cCondP+"', A1_XTPDESC='" + cPB3_ANCC + "'"	// Everson - 14/10/2021. Chamado 13526.	 
			_cQuery1+=" WHERE   "
			_cQuery1+=" LEFT(A1_CGC,8) = '" + Alltrim(SZF->ZF_CGCMAT) + "' "		
			_cQuery1+=" AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "

			&&atualizacao para PB3				
			_cQuery2:=""
			_cQuery2:=" UPDATE 	"+retsqlname("PB3")+" WITH(UPDLOCK) SET PB3_CODRED='"+alltrim(_cRede)+"' , PB3_DESC="+alltrim(STR(_nDescB))+" , PB3_TPREDE='"+_cTpRed+"' , PB3_NOMEAS='"+_cAssoc+"' , PB3_VENCLC='"+_cLimcred+"',"
			_cQuery2+=" PB3_BCO1='"+_cBanco+"', PB3_COND='"+_cCondP+"', PB3_XTPDES='" + cPB3_ANCC + "'"	// Everson - 14/10/2021. Chamado 13526.	 	 
			_cQuery2+=" WHERE   "
			_cQuery2+=" LEFT(PB3_CGC,8) = '" + Alltrim(SZF->ZF_CGCMAT) + "' "		
			_cQuery2+=" AND "+RETSQLNAME("PB3")+".D_E_L_E_T_=' ' "

			&&atualizacao para SZF				
			_cQuery3:=""
			_cQuery3:=" UPDATE 	"+retsqlname("SZF")+" WITH(UPDLOCK) SET ZF_REDE='"+alltrim(_cRede)+"' , ZF_ZZDESCB="+alltrim(STR(_nDescB))+" , ZF_TPREDE='"+_cTpRed+"' , ZF_NOMEASS='"+_cAssoc+"' "		 
			_cQuery3+=" WHERE   "
			_cQuery3+=" ZF_CGCMAT = '" + Alltrim(SZF->ZF_CGCMAT) + "' "		
			_cQuery3+=" AND "+RETSQLNAME("SZF")+".D_E_L_E_T_=' ' "

			TCSQLExec(_cQuery1)

			TCSQLExec(_cQuery2)

			TCSQLExec(_cQuery3)

			//Everson - 21/12/2017. Chamado 037261.
			//If Findfunction("U_ADVEN051P")
				//MsAguarde({|| U_ADVEN051P("DESF",0,"","","",Alltrim(SZF->ZF_CGCMAT))  },"Aguarde","Sincronizando com SalesForce...")

			//EndIf
			//

			SZF->(DBSKIP())

		ENDDO 
	ENDIF

	//
	RestArea(aArea)

	DBSELECTAREA("SZF")
	DBSETORDER(_nIndexSZF)
	DBGOTO(_nRecnoSZF)
	SYSREFRESH() 

RETURN()      

/*{Protheus.doc} Static Function PESQLIMIRED
	Funcao para pesquisar o limite da rede
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function PesqLimiRed()

	Local nLimRede := 0
	Local nLimAprv := PB3->PB3_LIMAPR 	

	DbSelectArea("SZF")
	dbGoTop()
	DbSetOrder(3)   									//WILLIAM COSTA AQUI ELE SOMA O LIMITE NA TELA DE CREDITO APROVADO CHAMADO 022332
	If SZF->( DbSeek( xFilial("SZF")+M->PB3_CODRED))   

		If UPPER(ALLTRIM(SZF->ZF_TPREDE)) <> 'A' 		//LIMITES DIFERENTES DE ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA

			DbSelectArea( 'SZF' )
			dbGoTop()
			DbSetOrder( 3 )
			SZF->( DbSeek( xFilial('SZF') + M->PB3_CODRED))
			While !Eof() .and. SZF->ZF_REDE == M->PB3_CODRED
				nLimRede += SZF->ZF_LCREDE
				SZF->(dbSkip())
			Enddo                

		Else											// LIMITES COM ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA	                                      

			DbSelectArea( 'SZF' )
			dbGoTop()
			DbSetOrder( 2 )
			If SZF->( DbSeek( xFilial('SZF') + M->PB3_NOMERE))
				nLimRede := SZF->ZF_LCREDE
			EndIf

		EndIf
	Else
		If nLimAprv > 0
			nLimRede := nLimAprv
		EndIf	
	EndIf
	DBCLOSEAREA("SZF")

	//inicio reposicionar SZF CHAMADO 022332 - WILLIAM COSTA
	If UPPER(ALLTRIM(SZF->ZF_TPREDE)) <> 'A'
		DbSelectArea("SZF")
		dbGoTop()
		DbSetOrder(3)   //WILLIAM COSTA AQUI ELE SOMA O LIMITE NA TELA DE CREDITO APROVADO CHAMADO 022332
		If SZF->( DbSeek( xFilial("SZF")+M->PB3_CODRED))   
		EndIf
	EndIf
	//final reposicionar SZF CHAMADO 022332 - WILLIAM COSTA

Return nLimRede 

/*{Protheus.doc} Static Function ADODESBLOQ
	Desbloqueio de clientes
	@type  Function
	@author Fernando Sigoli
	@since 28/12/2016
	@version 01
	@history Chamado 032015
*/

Static function AdoDesbloq( cCodcli, cLojacli,nLimite,cCondPag )

	Local aArea		:= GetArea()
	Local aMotDesb  := {}    
	Local cCodSup   := ""

	DbSelectArea( 'PB3' )
	PB3->( DbSetOrder( 11 ))

	If PB3->( DbSeek( xFilial( 'PB3' ) + cCodcli + cLojacli ))

		cCodSup	:= GetAdvFVal( 'SA3', 'A3_SUPER', xFilial('SA3') + PB3->PB3_VEND, 7 )	

		If Alltrim(cCodSup) $ GetMV("MV_SUPVEND")

			DbSelectArea( 'PB5' )
			PB5->( dbSetOrder( 1 ))
			PB5->( DbGoTop())
			While ! PB5->( Eof()) .And. PB5->PB5_FILIAL == xFilial( 'PB5' ) 
				If PB5->PB5_GRUPO = '2' .or. PB5->PB5_GRUPO = '3' 
					aAdd( aMotDesb,{ PB5->PB5_CODIGO, PB5->PB5_DESCRI } )
				EndIF
				PB5->( dbSkip())
			Enddo


			DEFINE MSDIALOG oDlg4 TITLE "Motivo Liberação" FROM 00,00 To 340,440 OF oMainWnd PIXEL

			@ 020,010 ListBox oListBox2 Fields HEADER "Codigo", "Motivo" Size 200, 140 Of oDlg2 Pixel
			oListBox2:SetArray( aMotDesb )
			oListBox2:bLine := {|| { aMotDesb[ oListBox2:nAT, 01 ], aMotDesb[ oListBox2:nAT, 02 ] }}

			ACTIVATE MSDIALOG oDlg4 CENTERED ON INIT EnchoiceBar(oDlg4,{||nOpcao:=1,(  AdoGrvLOG(cCodcli,cLojacli,cCodSup,PB3->PB3_VEND,nLimite,cCondPag,aMotDesb[oListBox2:nAT,01], aMotDesb[oListBox2:nAT,02]), oDlg4:End())},{||nOpcao:=0},.F.,)

		EndIf

	Endif

	RestArea( aArea )

Return NIL

/*{Protheus.doc} Static Function ADOGRVLOG
	Funcao para gravar log e parecer do cliente
	@type  Function
	@author Fernando Sigoli
	@since 28/12/2016
	@version 01
	@history Chamado 032015
*/

Static Function AdoGrvLOG(cCli,cLoj,cSuper,cVend,nLim,cCondp,cCodMot,cDesMot)

	Local cNomeUsr := GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)

	//Grava LOG
	U_Ado05Log( cCli, cLoj, cNomeUsr, dDataBase, "Credito Aprovado", "Motivo: "+cCodMot,Alltrim(cDesMot))

	//Grava Ocorrencia no parecer do Cliente
	DbSelectArea( 'PBA' )
	RecLock( 'PBA', .T. )
	PBA_FILIAL	:= xFilial('PBA')
	PBA_CODCLI	:= cCli
	PBA_LOJACL	:= cLoj
	PBA_NIVEL	:= '1'
	PBA_USUARI	:= __cUserId
	PBA_NOME	:= cNomeUsr
	PBA_DATA	:= dDatabase
	PBA_HORA	:= TIME()
	MSMM(,TamSx3("PBA_PARECE")[1],,"Credito Aprovado: "+cCodMot+'-'+alltrim(cDesMot),1,,,"PBA","PBA_CODMEM")
	PBA->( MsUnLock())

	//-----------------------|
	//log de registro        |
	//-----------------------|
	dbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
	Replace ZBE_DATA 	   	WITH Date()
	Replace ZBE_HORA 	   	WITH TIME()
	Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
	Replace ZBE_LOG	        WITH ("CRED.APROVADO: "+cCodMot+'-'+Alltrim(cDesMot))  
	Replace ZBE_MODULO	    WITH "FINANCEIRO"
	Replace ZBE_ROTINA	    WITH "AdoGrvLOG" 
	Replace ZBE_PARAME      WITH ("CLIENTE:"+cCli+"-"+cLoj+" SUPER:"+cSuper+" VEND:"+cVend+" LIMITE:"+cvaltochar(nLim)+" CONDPAG:"+cCondp)

	ZBE->( MsUnLock())

Return Nil

/*{Protheus.doc} User Function VALCPAG
	Funcao para validar condicao de pagamento na PB3 - PB3_COND
	@type  Function
	@author Fernando Sigoli
	@since 28/12/2016
	@version 01
	@history Chamado 032015
*/

User Function ValCpag(cPrazPag)

	Local nPrzPag  := GetAdvFVal("SE4", "E4_DMEDI",xFilial("SE4")+cPrazPag, 1)
	Local cUsado   := GetAdvFVal("SE4", "E4_USADO",xFilial("SE4")+cPrazPag, 1)
	Local lRetpag  := .T.          

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	If cUsado = 'N'
		Alert("Por favor, verifique o cadastro da condição de pagamento "+cPrazPag+" a mesma encontra-se nao autorizada para Uso")
		lRetpag := .F.
	EndIf

	If nPrzPag  <= 0 .and. (cPrazPag <> '0' .and. cPrazPag <> '00')    
		Alert("Por favor, verifique o cadastro da condição de pagamento "+cPrazPag+" a mesma encontra-se sem informaçoes de Prazo Medio")      
		lRetpag := .F.
	Endif

Return lRetpag

/*{Protheus.doc} Static Function FREPLASS
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

STATIC FUNCTION fReplAss(nPB3_DESC,cCODPB3,cLojaPB3,cPB3_NOMEAS,cPB3_TPREDE,_cCGCPB3,_cPB3SA1,_cNMPB3,cPB3_ANCC)

	Local aArea := GetArea()
	//_nIndexSZF := IndexOrd()
	//_nRecnoSZF := RECNO()
	//_cRede     := cPB3_CODRED
	//_cMatR     := SZF->ZF_CGCMAT
	_nDescB    := nPB3_DESC
	_cCliPB3   := cCODPB3
	_cLojPB3   := cLojaPB3
	_cTpRed    := cPB3_TPREDE
	_cAssoc    := cPB3_NOMEAS

	INCPROC("Replicando/atualizando Cliente: "+_cCliPB3+" Loja: "+_cLojPB3+"-"+_cNMPB3)


	&&atualizacao para SA1
	_cQuery1:=""
	_cQuery1:=" UPDATE 	"+retsqlname("SA1")+" WITH(UPDLOCK) SET A1_ZZDESCB="+alltrim(STR(_nDescB))+" , A1_NOMEASS='"+_cAssoc+"', A1_XTPDESC='" + cPB3_ANCC + "' " // Everson - 14/10/2021. Chamado 13526.
	_cQuery1+=" WHERE   "
	_cQuery1+=" A1_CGC = '" + _cCGCPB3 + "' "
	_cQuery1+=" AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "

	//Everson - 13/12/2017. Chamado - 038633.
	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1") + Alltrim(cValToChar(_cCGCPB3))) )

		If Val(cValToChar(_nDescB)) <> Val(cValToChar(SA1->A1_ZZDESCB))

			DbSelectArea("ZBE")
			RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH Date()
			Replace ZBE_HORA 	   	WITH Time()
			Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("Alteração de desconto financeiro (A1_ZZDESCB) de " + Alltrim(cValToChar(SA1->A1_ZZDESCB)) + " para " + Alltrim(cValToChar(_nDescB)) + " ")  
			Replace ZBE_MODULO	    WITH "FINANCEIRO"
			Replace ZBE_ROTINA	    WITH "ADOA005" 
			Replace ZBE_PARAME      WITH ("CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)) )
			ZBE->( MsUnLock())

		EndIf

	EndIf

	&&atualizacao para PB3
	_cQuery2:=""
	_cQuery2:=" UPDATE 	"+retsqlname("PB3")+" WITH(UPDLOCK) SET PB3_DESC="+alltrim(STR(_nDescB))+" , PB3_NOMEAS='"+_cAssoc+"', PB3_XTPDES='" + cPB3_ANCC + "' " // Everson - 14/10/2021. Chamado 13526.
	_cQuery2+=" WHERE   "
	_cQuery2+=" PB3_CGC = '" + _cCGCPB3 + "' "
	_cQuery2+=" AND "+RETSQLNAME("PB3")+".D_E_L_E_T_=' ' "

	TCSQLExec(_cQuery1)

	TCSQLExec(_cQuery2)

	//Everson - 21/12/2017. Chamado 037261.
	//If Findfunction("U_ADVEN051P")
		//MsAguarde({|| U_ADVEN051P("DESF",0,cCODPB3,cLojaPB3,"","")  },"Aguarde","Sincronizando com SalesForce...")

	//EndIf
	//

	SYSREFRESH()

	//
	RestArea(aArea)

RETURN()

/*{Protheus.doc} Static Function MOTIVREJ
	Selecao de motivos de rejeicao do cliente
	@type  Function
	@author Fernando Sigoli
	@since 14/06/2017
	@version 01
	@history Chamado 035744
*/

Static Function MOTIVREJ(cCodcli, cLojaCli, cUserName) 

	Local lRet := .F.

	SetPrvt("_OMARK,_STRU,CARQ,_CINDEX,_CCHAVE,ACAMPOS")
	SetPrvt("LREFRESH,") 

	Private nVZDSM  := 0

	_stru:={}
	AADD(_stru,{"RB_OK"		,"C",02,0})
	AADD(_stru,{"RB_CODIGO" ,"C",06,0})
	AADD(_stru,{"RB_DESCRI" ,"C",30,0})

	cArq:=Criatrab(_stru,.T.)

	DBUSEAREA(.t.,,carq,"TRB")

	Index On RB_CODIGO to TESTE

	cMarca := GetMark()  

	cQuery := " SELECT * FROM "+RetSqlName('PB5')+" PB5 WHERE D_E_L_E_T_ = '' AND PB5_GRUPO = '1'  "

	TCQUERY cQuery new alias "QPB5"

	DbSelectarea("QPB5")
	DbGotop()
	While !Eof()
		DbSelectarea("TRB")
		RecLock("TRB",.T.) 
		TRB->RB_CODIGO := QPB5->PB5_CODIGO
		TRB->RB_DESCRI := QPB5->PB5_DESCRI
		Msunlock()
		DbSelectarea("QPB5")
		DbSkip()
	EndDo

	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="RB_CODIGO"

	Indregua("TRB",_cIndex,_cchave,,,"Selecionando Registros...")

	dBSETINDEX(_cIndex+ordbagext())

	Define Msdialog oDlg2 From 200,1 To 500,590 Title  "Motivo de Rejeito" Pixel

	aCampos := {}
	AADD(aCampos,{"RB_OK","","@!","2","0"})
	AADD(aCampos,{"RB_CODIGO","Codigo","@!","6","0"}) 
	AADD(aCampos,{"RB_DESCRI","Motivo","@!","30","0"}) 

	@ 6,5 TO 93,290 BROWSE "TRB" FIELDS acampos MARK "RB_OK" object _oMark
	@ 096,010 SAY "Motivos Rejeitos, Selecione o Desejado e Confirme."  SIZE 142, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 110,010 BUTTON "Ok" SIZE 40,15 ACTION (CONFOK(cCodcli, cLojaCli,cUserName),Close(oDlg2),lRet := .T.) SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,060 BUTTON "MARCA TUDO" SIZE 40,15 ACTION Marca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,110 BUTTON "DESMARCA TUDO" SIZE 50,15 ACTION Desmarca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,170 BUTTON "SAIR" SIZE 40,15 ACTION(lRet := .F.,Close(oDlg2)) SIZE 037, 012 OF oDlg2 PIXEL

	If nVZDSM = 0
		Desmarca()
		nVZDSM := 1
	EndIf

	ACTIVATE MSDIALOG oDlg2 CENTERED

	DBSELECTAREA("TRB")
	TRB->(DBCLOSEAREA())
	Ferase(cArq)

	QPB5->(DBCLOSEAREA()) 

Return(lRet)


/*{Protheus.doc} Static Function MARCA
	Marca itens a serem considerados
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function Marca() 

	cMarca := GetMark()

	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		If !Marked("RB_OK") //Registro nao esta marcado
			Reclock("TRB",.F.)
			TRB->RB_OK := cMarca
			MsUnlock()
		EndIf
		DbSkip()
	End
	DbGoTop()
	_oMark:oBrowse:Refresh()

Return

/*{Protheus.doc} Static Function DESMARCA
	Desmarca todos os itens
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function DesMarca() 

	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		If Marked("RB_OK") //Registro esta marcado
			Reclock("TRB",.F.)
			TRB->RB_OK := ThisMark()
			MsUnlock()
		EndIf
		DbSkip()
	End
	DbGoTop()
	_oMark:oBrowse:Refresh()
Return                                                 

/*{Protheus.doc} Static Function CONFOK
	Atualiza log e parecer do cliente, referente aos motivos de rejeito
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

Static Function CONFOK(cCodcli, cLojaCli,cNomeUsr) 

	Private nVez 	:= 0
	Private nVlrPdg := 0
	
	U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_SITUAC', 'X3_Titulo' ),If(PB3->PB3_SITUAC $ '1/4', 'Em Analise',If(PB3->PB3_SITUAC == '2', 'Aprovado', '')), 'Rejeitado' )  &&Mauricio - Chamado 035857 - 14/07/17

	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		If Marked("RB_OK") //Registro nao esta marcado

			If nVez = 0

				cCodMotivo := TRB->RB_CODIGO
				cMotRej    := TRB->RB_DESCRI
				U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, 'Motivo Rejeito', '', ALLTRIM(TRB->RB_DESCRI) )
				//Parecer do cliente 
				U_GrvParecer(cCodCli, cLojaCli, ALLTRIM(TRB->RB_DESCRI))

			Else

				cCodMotivo := TRB->RB_CODIGO
				cMotRej    += "/"
				cMotRej    += TRB->RB_DESCRI
				//log de registro
				U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, 'Motivo Rejeito', '', ALLTRIM(TRB->RB_DESCRI) ) 
				//Parecer do cliente
				U_GrvParecer(cCodCli, cLojaCli, ALLTRIM(TRB->RB_DESCRI))

			EndIf
			nVez := 1
		EndIf 
		DbSkip()
	EndDo

Return

/*{Protheus.doc} User Function GRVPARECER
	Gravar parecer no rejeito do cliente
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

User Function GrvParecer(cCodCli, cLojaCli,cMotRej)  

	Local aArea := GetArea()

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	DbSelectArea( 'PBA' )
	RecLock( 'PBA', .T. )
	PBA_FILIAL	:= xFilial('PBA')
	PBA_CODCLI	:= cCodCli
	PBA_LOJACL	:= cLojaCli
	PBA_USUARI	:= __cUserId
	PBA_NOME	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	PBA_DATA	:= dDatabase
	PBA_HORA	:= TIME()
	MSMM(,TamSx3("PBA_PARECE")[1],,"REJEITO : "+cMotRej,1,,,"PBA","PBA_CODMEM")
	PBA->( MsUnLock())


	RestArea( aArea)

Return

/*{Protheus.doc} User Function CREDITOLOG
	Sem detalhamento
	@type  Function
	@author Sem autor
	@since Sem data
	@version 01
	@history 
*/

USER FUNCTION CREDITOLOG(cCodcli, cLojacli,cNomeUsr,cTela)

	Local nTotLimRede := 0

	U_ADINF009P('ADOA005' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Aprovacao de credito de clientes, considerando regras predeterminada')

	// *** INICIO CHAMADO 038954 WILLIAM COSTA 05/01/2018 *** //

	cMensagem := ''

	cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Apertou Salvar:", "", "")

	IF cTela == "Atualiza SA1_PB3_SZF"

		cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Codigo Rede", cTela+":"+PB3->PB3_CODRED, cTela+":"+M->PB3_CODRED)
		cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Nome Rede", cTela+":"+PB3->PB3_NOMERE, cTela+":"+M->PB3_NOMERE)
		cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Desconto", cTela+":"+CvalToChar(PB3->PB3_DESC), cTela+":"+CvalToChar(M->PB3_DESC))
		cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Tipo Rede", cTela+":"+PB3->PB3_TPREDE, cTela+":"+M->PB3_TPREDE)
		cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Nome Associ", cTela+":"+PB3->PB3_NOMEAS, cTela+":"+M->PB3_NOMEAS)

	ELSE

		IF PB3->PB3_NOME	!= M->PB3_NOME

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_NOME', 'X3_Titulo' ), cTela+":"+PB3->PB3_NOME, cTela+":"+M->PB3_NOME )

		ENDIF

		IF PB3->PB3_PESSOA != M->PB3_PESSOA

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_PESSOA', 'X3_Titulo' ), cTela+":"+PB3->PB3_PESSOA, cTela+":"+M->PB3_PESSOA)

		ENDIF

		IF PB3->PB3_NREDUZ != M->PB3_NREDUZ

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_PESSOA', 'X3_Titulo' ), cTela+":"+PB3->PB3_NREDUZ, cTela+":"+M->PB3_NREDUZ)

		ENDIF

		IF PB3->PB3_END != M->PB3_END

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_END', 'X3_Titulo' ), cTela+":"+PB3->PB3_END, cTela+":"+M->PB3_END)

		ENDIF

		IF PB3->PB3_EST != M->PB3_EST

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_EST', 'X3_Titulo' ), cTela+":"+PB3->PB3_EST, cTela+":"+M->PB3_EST)

		ENDIF

		IF PB3->PB3_COD_MU != M->PB3_COD_MU

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_COD_MU', 'X3_Titulo' ), cTela+":"+PB3->PB3_COD_MU, cTela+":"+M->PB3_COD_MU)

		ENDIF

		IF PB3->PB3_BAIRRO != M->PB3_BAIRRO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BAIRRO', 'X3_Titulo' ), cTela+":"+PB3->PB3_BAIRRO, cTela+":"+M->PB3_BAIRRO)

		ENDIF

		IF PB3->PB3_CEP != M->PB3_CEP

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CEP', 'X3_Titulo' ), cTela+":"+PB3->PB3_CEP, cTela+":"+M->PB3_CEP)

		ENDIF
		IF PB3->PB3_TEL != M->PB3_TEL

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_TEL', 'X3_Titulo' ), cTela+":"+PB3->PB3_TEL, cTela+":"+M->PB3_TEL)

		ENDIF

		IF PB3->PB3_FAX != M->PB3_FAX

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_FAX', 'X3_Titulo' ), cTela+":"+PB3->PB3_FAX, cTela+":"+M->PB3_FAX)

		ENDIF

		IF PB3->PB3_PAIS != M->PB3_PAIS

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_PAIS', 'X3_Titulo' ), cTela+":"+PB3->PB3_PAIS, cTela+":"+M->PB3_PAIS)

		ENDIF

		IF PB3->PB3_CONTAT != M->PB3_CONTAT

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CONTAT', 'X3_Titulo' ), cTela+":"+PB3->PB3_CONTAT, cTela+":"+M->PB3_CONTAT)

		ENDIF

		IF PB3->PB3_CGC != M->PB3_CGC

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CGC', 'X3_Titulo' ), cTela+":"+PB3->PB3_CGC, cTela+":"+M->PB3_CGC)

		ENDIF

		IF PB3->PB3_INSCR != M->PB3_INSCR

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_INSCR', 'X3_Titulo' ), cTela+":"+PB3->PB3_INSCR, cTela+":"+M->PB3_INSCR)

		ENDIF

		IF PB3->PB3_GRPVEN != M->PB3_GRPVEN

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_GRPVEN', 'X3_Titulo' ), cTela+":"+PB3->PB3_GRPVEN, cTela+":"+M->PB3_GRPVEN)

		ENDIF

		IF PB3->PB3_EMAIL != M->PB3_EMAIL

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_EMAIL', 'X3_Titulo' ), cTela+":"+PB3->PB3_EMAIL, cTela+":"+M->PB3_EMAIL)

		ENDIF

		IF PB3->PB3_COMPLE != M->PB3_COMPLE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_COMPLE', 'X3_Titulo' ), cTela+":"+PB3->PB3_COMPLE, cTela+":"+M->PB3_COMPLE)

		ENDIF

		IF PB3->PB3_NUMERO != M->PB3_NUMERO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_NUMERO', 'X3_Titulo' ), cTela+":"+PB3->PB3_NUMERO, cTela+":"+M->PB3_NUMERO)

		ENDIF

		IF PB3->PB3_MUN != M->PB3_MUN

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_MUN', 'X3_Titulo' ), cTela+":"+PB3->PB3_MUN, cTela+":"+M->PB3_MUN)

		ENDIF

		IF PB3->PB3_CEL != M->PB3_CEL

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_CEL', 'X3_Titulo' ), cTela+":"+PB3->PB3_CEL, cTela+":"+M->PB3_CEL)

		ENDIF

		IF PB3->PB3_SEGTO != M->PB3_SEGTO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_SEGTO', 'X3_Titulo' ), cTela+":"+PB3->PB3_SEGTO, cTela+":"+M->PB3_SEGTO)

		ENDIF

		IF PB3->PB3_SUBSEG != M->PB3_SUBSEG

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_SUBSEG', 'X3_Titulo' ), cTela+":"+PB3->PB3_SUBSEG, cTela+":"+M->PB3_SUBSEG)

		ENDIF

		IF PB3->PB3_TIPO  <> M->PB3_TIPO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Tipo", cTela+":"+PB3->PB3_TIPO, cTela+":"+M->PB3_TIPO )

		ENDIF

		IF PB3->PB3_NATURE  <> M->PB3_NATURE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Natureza", cTela+":"+PB3->PB3_NATURE, cTela+":"+M->PB3_NATURE)

		ENDIF

		IF PB3->PB3_VENCLC  <> M->PB3_VENCLC

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Venc.Lim.Cre", cTela+":"+DTOC(PB3->PB3_VENCLC), cTela+":"+DTOC(M->PB3_VENCLC))

		ENDIF

		IF PB3->PB3_CLASSE  <> M->PB3_CLASSE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Classe Cred", cTela+":"+PB3->PB3_CLASSE, cTela+".:"+M->PB3_CLASSE)

		ENDIF

		IF PB3->PB3_BCO1  <> M->PB3_BCO1

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Banco 1", cTela+":"+PB3->PB3_BCO1, cTela+":"+M->PB3_BCO1)

		ENDIF

		IF PB3->PB3_COND  <> M->PB3_COND 

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Cond. Pagto", cTela+":"+PB3->PB3_COND, cTela+":"+M->PB3_COND)

		ENDIF

		IF PB3->PB3_DESC  <> M->PB3_DESC

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Desconto", cTela+":"+CvalToChar(PB3->PB3_DESC), cTela+":"+CvalToChar(M->PB3_DESC))

		ENDIF

		IF PB3->PB3_RISCO  <> M->PB3_RISCO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Risco", cTela+":"+PB3->PB3_RISCO, cTela+":"+M->PB3_RISCO)

		ENDIF

		IF PB3->PB3_MOEDAL  <> M->PB3_MOEDAL

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Moeda do LC", cTela+":"+CVALTOCHAR(PB3->PB3_MOEDAL), cTela+":"+CVALTOCHAR(M->PB3_MOEDAL))

		ENDIF

		IF PB3->PB3_GRPTRI  <> M->PB3_GRPTRI

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Grp.Clientes", cTela+":"+PB3->PB3_GRPTRI, cTela+":"+M->PB3_GRPTRIB)

		ENDIF

		IF PB3->PB3_CODPAI  <> M->PB3_CODPAI

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Pais Bacen", cTela+":"+PB3->PB3_CODPAI, cTela+":"+M->PB3_CODPAI)

		ENDIF

		IF PB3->PB3_CONDPA  <> M->PB3_CONDPA

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "C.Pag Export", cTela+":"+PB3->PB3_CONDPA, cTela+":"+M->PB3_CONDPA)

		ENDIF

		IF PB3->PB3_DIASPA  <> M->PB3_DIASPA

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Dias  Pagto", cTela+":"+CValtochar(PB3->PB3_DIASPA), cTela+":"+CValtochar(M->PB3_DIASPA))

		ENDIF

		IF PB3->PB3_CONTRI  <> M->PB3_CONTRI

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Contribuinte", cTela+":"+IIF(PB3->PB3_CONTRI=='1','SIM','NAO'), cTela+":"+IIF(M->PB3_CONTRI=='1','SIM','NAO'))

		ENDIF

		IF PB3->PB3_CODRED  <> M->PB3_CODRED

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Codigo Rede", cTela+":"+PB3->PB3_CODRED, cTela+":"+M->PB3_CODRED)

		ENDIF

		IF PB3->PB3_NOMERE  <> M->PB3_NOMERE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Nome Rede", cTela+":"+PB3->PB3_NOMERE, cTela+":"+M->PB3_NOMERE)

		ENDIF

		IF PB3->PB3_TPREDE  <> M->PB3_TPREDE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Tipo Rede", cTela+":"+PB3->PB3_TPREDE, cTela+":"+M->PB3_TPREDE)

		ENDIF

		IF PB3->PB3_NOMEAS  <> M->PB3_NOMEAS

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Nome Associ", cTela+":"+PB3->PB3_NOMEAS, cTela+":"+M->PB3_NOMEAS)

		ENDIF

		IF PB3->PB3_LIMAPR <> M->PB3_LIMAPR 

			//cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Crédito aprovado", "Limite:"+Str(M->PB3_LIMAPR), "Condicao: "+ M->PB3_COND )	//Chamado 036175 - Fernando Sigoli 13/07/2017
			nTotLimRede := 0
			DbSelectArea( 'SZF' )
			dbGoTop()
			DbSetOrder( 3 )
			SZF->( DbSeek( xFilial('SZF') + M->PB3_CODRED))
			While !Eof() .and. SZF->ZF_REDE == M->PB3_CODRED
			
				nTotLimRede += SZF->ZF_LCREDE
				 
				SZF->(dbSkip())
			Enddo
						 
			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Limite", cTela+":"+Str(nTotLimRede), cTela+":"+Str(M->PB3_LIMAPR) )

		ENDIF

		IF PB3->PB3_CNDPGA  <> M->PB3_CNDPGA

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Prazo Medio", cTela+":"+CVALTOCHAR(PB3->PB3_CNDPGA), cTela+":"+CVALTOCHAR(M->PB3_CNDPGA))

		ENDIF

		IF PB3->PB3_DSCRIS  <> M->PB3_DSCRIS

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Desc. Risco", cTela+":"+PB3->PB3_DSCRIS, cTela+":"+M->PB3_DSCRIS)

		ENDIF

		IF PB3->PB3_BLOQUE  <> M->PB3_BLOQUE

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Bloqueado ?", cTela+":"+PB3->PB3_BLOQUE, cTela+":"+M->PB3_BLOQUE)

		ENDIF

		IF PB3->PB3_REGCOB  <> M->PB3_REGCOB

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Reg Cobranca", cTela+":"+PB3->PB3_REGCOB, cTela+":"+M->PB3_REGCOB)

		ENDIF

		IF PB3->PB3_XRISCO  <> M->PB3_XRISCO

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "RISCO CISP", cTela+":"+PB3->PB3_XRISCO, cTela+":"+M->PB3_XRISCO)

		ENDIF

		IF PB3->PB3_XDTRIS  <> M->PB3_XDTRIS

			cMensagem += U_Ado05Log( cCodcli, cLojacli, cNomeUsr, dDataBase, "Dt Ult Atual", cTela+":"+DTOC(PB3->PB3_XDTRIS), cTela+":"+DTOC(M->PB3_XDTRIS))

		ENDIF
	ENDIF// FECHA IF da cTela	

	// *** FINAL CHAMADO 038954 WILLIAM COSTA 05/01/2018 *** //

RETURN(NIL)

/*{Protheus.doc} Static Function CHKSA1SF
	Funcao que checa se cliente ja foi enviado para o salesforce
	@type  Function
	@author Everson
	@since 27/06/2018
	@version 01
	@history Chamado 037261
*/

Static Function chkSA1SF(cCod,cLoja)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	
	//
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	
	//
	If SA1->(DbSeek( xFilial("SA1") + cCod + cLoja ))
	
		If Empty(Alltrim(cValToChar(SA1->A1_XIDSF))) //Verifica se já há o código do SalesForce.
			RestArea(aArea)
			Return .F.
		
		EndIf
		
	Else
		RestArea(aArea)
		Return .F.		
	
	EndIf
	
	//
	RestArea(aArea)
	
Return .T.

/*{Protheus.doc} Static Function ADOCONDIC
	Alterar condicao de pagamento para todas as lojas de cliente que tenha varias lojas
	@type  Function
	@author William Costa
	@since 19/08/2019
	@version 01
	@history Chamado 050877 - William Costa - 20/08/2019 - COND.PAG PRAZO COZIN 
*/

Static function AdoCondic(cCodcli,cLojacli,cCGCcli)

	Local aArea      := GetArea()
	Local cNomeUsr   := GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local lValida    := .T.
	Local _cQuery7   := ''
	Local _cQuery9   := ''
	Local _cQuery10  := ''
	Local nContLoja  := 0
	Local cCondPag   := SPACE(TAMSX3("E4_CODIGO")[1])
	Local oCondPagto := NIL
	Local oDlg       := NIL
	Local nOpc       := 0
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Alteração Condição de Pagamento em Massa") From 100,0 To 225,575 PIXEL
	
		@ 03,20 SAY "Deseja realmente trocar a condicao de pagamento de todos esses CNPJS: " + TRANSFORM(cCGCcli,"@R 99.999.999.9999/99") + " ?"	SIZE 260,080 OF oDlg PIXEL
		
		@ 13,20 SAY "Alteracao nas tabelas PB3 e SA1 - Somente Clientes com Cod e Loja SA1 serao alterados"	SIZE 260,080 OF oDlg PIXEL
		
		@ 23,20 SAY "Informe Nova Condicao Pagamento "
		@ 33,20 MSGet oCondPagto VAR cCondPag VALID VAlidCond(cCondPag) .AND. !Empty(cCondPag) F3 "SE4" SIZE 050,10 OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 48,020 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg PIXEL
		DEFINE SBUTTON FROM 48,050 TYPE 2 ACTION (nOpc:=0,oDlg:End()) ENABLE OF oDlg PIXEL
		
	ACTIVATE MSDIALOG  oDlg CENTERED
	
	IF nOpc == 1 
	     
		// *** INICIO VALIDACAO *** //
		
		// *** INICIO IDENTIFICAR SE O CGC TEM VARIAS LOJAS *** //
		_cQuery7 := ''
		_cQuery7 := " SELECT PB3_CODSA1,PB3_LOJSA1,PB3_CGC  "
		_cQuery7 += "   FROM " + RETSQLNAME("PB3") + " "
		_cQuery7 += "  WHERE PB3_CGC     = '" + cCGCcli + "' "
		_cQuery7 += "    AND PB3_CODSA1 <> '' "
		_cQuery7 += "    AND PB3_LOJSA1 <> '' "
		_cQuery7 += "    AND D_E_L_E_T_ <> '*' "
		
		DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery7), "TRF", .F., .T. )
		DBSELECTAREA( "TRF" )
		DBGOTOP()
		
		nContLoja := 0
		
		WHILE !TRF->(EOF())
	
			IF TRF->PB3_LOJSA1 <> '00'
			
				nContLoja := nContLoja + 1
			
			ENDIF
	
			TRF->(DBSKIP())
		ENDDO
		TRF->(dbCloseArea())
		
		IF nContLoja == 0 //significa que o CNPJ não tem lojas
		
			ALERT("So e permitido alteracao de Condicao de Pagamento para Clientes com Lojas.")
			lValida := .F.
			
		ENDIF	
		// *** FINAL IDENTIFICAR SE O CGC TEM VARIAS LOJAS *** //
		
		// *** FINAL VALIDACAO *** // 
	   	    
	    IF lValida == .T.
	
	    	_cQuery9 := ''
			_cQuery9 := " SELECT PB3_CODSA1,PB3_LOJSA1,PB3_CGC,PB3_COD,PB3_LOJA,PB3_COND  "
			_cQuery9 += "   FROM " + RETSQLNAME("PB3") + " "
			_cQuery9 += "  WHERE PB3_CGC     = '" + cCGCcli + "' "
			_cQuery9 += "    AND PB3_CODSA1 <> '' "
			_cQuery9 += "    AND PB3_LOJSA1 <> '' "
			_cQuery9 += "    AND D_E_L_E_T_ <> '*' "
			
			DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery9), "TRH", .F., .T. )
			DBSELECTAREA( "TRH" )
			DBGOTOP()
			
			WHILE !TRH->(EOF())
		
				// Salva no Historico
				U_Ado05Log( TRH->PB3_COD, TRH->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2,'PB3_COND', 'X3_Titulo' ), TRH->PB3_COND, cCondPag )
		
				TRH->(DBSKIP())
			ENDDO
			TRH->(dbCloseArea())
	    	
	    	// *** INICIO ALTERACAO CONDICAO DE PAGAMENTO PB3 E SA1 *** //
	    	_cQuery10:= ""
			_cQuery10:= " UPDATE " + RETSQLNAME("PB3") + " WITH(UPDLOCK) " 
			_cQuery10+= "    SET PB3_COND    = '" + cCondPag + "' "		 
			_cQuery10+= "  WHERE PB3_CGC     = '" + cCGCcli  + "' "		
			_cQuery10+= "    AND PB3_CODSA1 <> '' "
			_cQuery10+= "    AND PB3_LOJSA1 <> '' "
			_cQuery10+= "    AND D_E_L_E_T_ <> '*' "

			TCSQLExec(_cQuery10)
			
			_cQuery11:= ""
			_cQuery11:= " UPDATE " + RETSQLNAME("SA1") + " WITH(UPDLOCK) " 
			_cQuery11+= "    SET A1_COND     = '" + cCondPag + "' "		 
			_cQuery11+= "  WHERE A1_CGC      = '" + cCGCcli  + "' "		
			_cQuery11+= "    AND D_E_L_E_T_ <> '*' "
			
			TCSQLExec(_cQuery11)

			//Everson - 27/01/2020. Chamado 055317.
			U_ADVEN076P("","",.F.," AND A1_CGC      = '" + cCGCcli  + "' "	)
			//
			
			// *** FINAL ALTERACAO CONDICAO DE PAGAMENTO PB3 E SA1 *** //
	    	
		ENDIF
		
		MsgInfo("Condicao de Pagamento alteradas com sucesso","AdoCondic")
		
	ELSE
	
		MsgInfo("Condicao de Pagamento nao alterada","AdoCondic")
	    
	ENDIF
	
	RestArea( aArea )
	
RETURN(.T.)

/*{Protheus.doc} Static Function VALIDCOND
	Validacao da condicao de pagamento usado no botao altera condicao
	@type  Function
	@author William Costa
	@since 19/08/2019
	@version 01
	@history Chamado 050877 - William Costa - 20/08/2019 - COND.PAG PRAZO COZIN 
*/


STATIC FUNCTION VAlidCond(cCondPag)

	Local lVAlidCond := .T.
	Local _cQuery8   := ''
	
	_cQuery8 := ''
	_cQuery8 := " SELECT E4_CODIGO  "
	_cQuery8 += "   FROM " + RETSQLNAME("SE4") + " "
	_cQuery8 += "  WHERE E4_CODIGO   = '" + cCondPag + "' "
	_cQuery8 += "    AND D_E_L_E_T_ <> '*' "
	
	DBUSEAREA( .T., "TOPCONN", TCGENQRY(,,_cQuery8), "TRG", .F., .T. )
	DBSELECTAREA( "TRG" )
	DBGOTOP()
	
	IF TRG->(EOF())

		lVAlidCond := .F.
		
		ALERT("Atencao condicao de pagamento nao existe, informe corretamente.")
		
	ENDIF
	TRG->(dbCloseArea())

RETURN(lVAlidCond)

/*{Protheus.doc} Static Function ADOBLOQLT
	Bloqueio em lote de clientes com mesmo CNPJ Raiz
	@type  Function
	@author Fernando Macieira
	@since 10/11/2019
	@version 01
	@history Chamado 052448 - FWNM - 10/11/2019 - Cad. cliente
*/

Static Function AdoBloqLt(cCliente, cLoja, cMotBlq1, cMotBlq2, cCC)

	Local aAreaAtu  := GetArea() 
	Local aAreaPB3  := PBE->( GetArea() )
	Local cCNPJRaiz := Left(AllTrim(Posicione("PB3",1,FWxFilial("PB3")+cCliente+cLoja,"PB3_CGC")),8)

    If msgYesNo("Tem certeza de que deseja bloquear (em lote) todos os clientes com CNPJ Raiz = " + cCNPJRaiz + " ?")
        
		lBlqLote  := .t.
		                               
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		cQuery := " SELECT PB3_CGC, PB3_COD, PB3_LOJA "
		cQuery += " FROM " + RetSqlName("PB3") + " PB3 (NOLOCK) "
		cQuery += " WHERE PB3_FILIAL='"+FWxFilial("PB3")+"' "
		cQuery += " AND PB3_CGC LIKE '"+cCNPJRaiz+"%' "
		cQuery += " AND PB3_BLOQUE<>'1' "
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		Do While Work->( !EOF() )
				
			MsAguarde( {|| AdoGrvBloq( Work->PB3_COD, Work->PB3_LOJA, cMotBlq1, cMotBlq2, cCC)}, "Aguarde... Bloqueando em lote...","Clientes com CNPJ Raiz = " + cCNPJRaiz )
			//AdoGrvBloq( Work->PB3_COD, Work->PB3_LOJA, cMotBlq1, cMotBlq2, cCC )

			Work->( dbSkip() )		

		EndDo
			
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		msgInfo("Bloqueio em lote finalizado!")
	
	Else
		msgAlert("Bloqueio em lote não realizado!")

	EndIf
	
	RestArea( aAreaAtu )
	RestArea( aAreaPB3 )

Return

/*{Protheus.doc} Static Function ADDESBLQLT
	Desbloqueio em lote de clientes com mesmo CNPJ Raiz
	@type  Function
	@author Fernando Macieira
	@since 10/11/2019
	@version 01
	@history Chamado 052448 - FWNM - 10/11/2019 - Cad. cliente
*/

Static Function AdDesBlqLt( cCliente, cLoja, cNomeUsr, cPara, cCC )
      
	Local aAreaAtu  := GetArea() 
	Local aAreaPB3  := PBE->( GetArea() )
	Local aAreaSA1  := SA1->( GetArea() )
	Local cCNPJRaiz := Left(AllTrim(Posicione("PB3",1,FWxFilial("PB3")+cCliente+cLoja,"PB3_CGC")),8)

    If msgYesNo("Tem certeza de que deseja desbloquear (em lote) todos os clientes com CNPJ Raiz = " + cCNPJRaiz + " ?")

		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		
		cQuery := " SELECT PB3_COD, PB3_LOJA "
		cQuery += " FROM " + RetSqlName("PB3") + " PB3 (NOLOCK) "
		cQuery += " WHERE PB3_FILIAL='"+FWxFilial("PB3")+"' "
		cQuery += " AND PB3_CGC LIKE '"+cCNPJRaiz+"%' "
		cQuery += " AND PB3_BLOQUE='1' " // Bloqueados
		cQuery += " AND D_E_L_E_T_='' "
		
		tcQuery cQuery New Alias "Work"
		
		Work->( dbGoTop() )
		Do While Work->( !EOF() )
			
			////////////////////////             
			cCliente := Work->PB3_COD
			cLoja    := Work->PB3_LOJA
			
			PB3->( dbSetOrder( 1 ) ) // PB3_FILIAL+PB3_COD+PB3_LOJA
			If PB3->( dbSeek( FWxFilial("PB3") + cCliente + cLoja ) )
		
				//Grava LOG
				U_Ado05Log( cCliente, cLoja, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ), 'Bloqueado'/*PB3->PB3_BLOQUE*/, 'Desbloqueado'/*'2'*/ ) 

				RecLock( 'PB3', .F. )
					PB3->PB3_BLOQUE	:= '2'
					PB3->PB3_MOTBLQ	:= ''
					PB3->PB3_MOTREJ	:= ''
					PB3->PB3_SITUAC	:= ' '
					PB3->PB3_DTENVI := Ctod('')
					PB3->PB3_VENENC := ' '
				PB3->( MsUnLock())

				//Desbloquear tambem no cadastro de clientes
				If !Empty( PB3->PB3_CODSA1 )
					DbSelectArea( 'SA1' )
					SA1->( DbSetOrder(1) )
					If SA1->( DbSeek( xFilial('SA1') + PB3->PB3_CODSA1 + PB3->PB3_LOJSA1) )
						RecLock( 'SA1', .F. )
							SA1->A1_MSBLQL  := '2'
							SA1->A1_DTREAT  := dDataBase
							SA1->A1_XMOTBLQ := '' 
							cStsCli := '2'

							If !Empty(SA1->A1_ULTCOM) .and. SA1->A1_ROTEIRO <> '200'
								SA1->A1_ROTEIRO := "199"
							EndIf

							SA1->( MsUnLock())
	
						_aArea:=GetArea()
						U_RESPM001("SA1",4, SA1->(Recno()), .F. )   
						RestArea(_aArea)
					Endif
				Endif
				// 

				//Grava Ocorrencia no parecer do Cliente
				dbSelectArea( 'PBA' )
				RecLock( 'PBA', .T. )
					PBA_FILIAL	:= FWxFilial('PBA')
					PBA_CODCLI	:= cCliente
					PBA_LOJACL	:= cLoja
					PBA_NIVEL	:= '1'
					PBA_USUARI	:= __cUserId
					PBA_NOME	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
					PBA_DATA	:= dDatabase
					PBA_HORA	:= TIME()
					MSMM(,TamSx3("PBA_PARECE")[1],,"DESBLOQUEADO PELA ROTINA MANUAL",1,,,"PBA","PBA_CODMEM")
				PBA->( MsUnLock())

				cMensagem 	:= 	'O cliente ' + PB3->PB3_CODSA1 + ' - ' + PB3->PB3_NOME + ' Loja ' + PB3->PB3_LOJSA1 + cNomeUsr+chr(13) + chr(10)+; 
				'Foi desbloqueado em ' + DtoC( dDatabase ) + ' Por ' + cNomeUsr+chr(13) + chr(10)  
				cMensagem := "Codigo          : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
				cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)     
				cMensagem += "Cliente         : "+ PB3->PB3_NOME+chr(13) + chr(10)
				cMensagem += "CNPJ/CPF        : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
				cMensagem += "Vendedor        : "+ GetAdvFval("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
				"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
				cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
				cMensagem += "Prazo           : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
				cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)

				CriaMail(cPara, 'Cliente Desbloqueado', cMensagem, /*''*/,cCC, .T., .T., cCliente, cLoja)

				//rotina de solicitação de motivo do desbloqueio, solicitado para apenas alguns supervidores	
				AdoDesbloq(PB3->PB3_CODSA1,PB3->PB3_LOJSA1,PB3->PB3_LIMAPR,PB3->PB3_COND) 

				If FindFunction("U_ADVEN076P")
					U_ADVEN076P(PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,PB3->PB3_CODSA1 + PB3->PB3_LOJSA1,.F.,"","LIBFIN",.T.," Cliente desbloqueado. ")
				EndIf
            
            EndIf            
             
        	Work->( dbSkip() )
        	   
    	EndDo
		
		msgInfo("Desbloqueio em lote finalizado!")
		
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaPB3 )
	RestArea( aAreaSA1 )

Return
/*/{Protheus.doc} alVldCrd
	Rotina altera parâmetro de cálculo de validade da data
	de limite de crédito.
	@type  Static Function
	@author Everson
	@since 31/07/2020
	@version 01
	/*/
Static Function alVldCrd() 

	//Variáveis.
	Local aArea 	:= GetArea()
	Local oError 	:= ErrorBlock({|e|MsgAlert("Mensagem de Erro: " +chr(10)+ e:Description,"Função alVldCrd(ADOA005)")})
	Local cDiasP 	:= cValToChar(GetMv("MV_#DVLCRD",,180))
	Local cDiasSet	:= ""

	//
	Begin Sequence
		cDiasSet := FWInputBox("Digite o quantidade de dias para cálculo do vencimento de crédito.", cDiasP)

		//
		If Val(cDiasSet) == 0
			RestArea(aArea)
			Return Nil

		EndIf

		If Val(cDiasSet) < 0
			MsgStop("Digite um número válido.","Função alVldCrd(ADOA005)")
			RestArea(aArea)
			Return Nil 

		EndIf

		//
		PutMv("MV_#DVLCRD",Val(cDiasSet))

	End Sequence

    ErrorBlock(oError)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} AdoAtuRev
	Atualiza data de validade do crédito.
	@type  Static Function
	@author Everson
	@since 31/07/2020
	@version 01
	/*/
Static Function AdoAtuRev(cCoPb3,cLjPb3)

	//Variáveis.
	Local aArea := GetArea()

	//
	DbSelectArea("PB3")
	PB3->(DbSetOrder(1))
	PB3->(DbSeek( FWxFilial("PB3") + cCoPb3 + cLjPb3 ))

	//
	If  ! Empty(Alltrim(cValToChar(PB3->PB3_CODSA1))) .And.  ! Empty(Alltrim(cValToChar(PB3->PB3_LOJSA1)))
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek( FWxFilial("SA1") + Alltrim(cValToChar(PB3->PB3_CODSA1)) + Alltrim(cValToChar(PB3->PB3_LOJSA1)) ))
			RecLock("SA1",.F.)
				SA1->A1_VENCLC := M->PB3_VENCLC
			SA1->(MsUnlock())

		Else 
			MsgStop("Não foi possível localizar o cadastro " + Alltrim(cValToChar(PB3->PB3_CODSA1)) + "/" + Alltrim(cValToChar(PB3->PB3_LOJSA1)) + ".","Função AdoAtuRev(ADOA055)")

		EndIf

	Else
		MsgStop("Cadastro não possui código SA1.","Função AdoAtuRev(ADOA055)")

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function FixLimits()
	Ajuste limites em lote - cliente e redes
	@type  Static Function
	@author FWNM
	@since 26/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	// @history Tickets 18751/18748 - Fernando Macieira - 26/08/2021 - Ajuste de Limites em Lote (Clientes e Redes)
/*/
Static Function FixLimits()

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'Ajuste de Limites em Lote - Clientes e Redes'
    Local clDesc1   := 'O objetivo desta rotina é alterar os valores nas tabelas SA1, PB3 e SZF'
    Local clDesc2   := 'e alimentar os LOGs na PB9'
    Local clDesc3   := ''
    Local clDesc4   := '( Necessário converter, previamente, esta planilha em arquivo CSV = Separado por ";" )'
    Local clDesc5   := ''

	Private cAliasTRB := ""

    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
    If !LockByName("FIXLIMITS", .T., .F.)
        Alert("[FixLimits] - Existe outro processamento sendo executado! Verifique...")
        Return
    EndIf

    // Mensagens de Tela Inicial
    aAdd(alSay, clDesc1)
    aAdd(alSay, clDesc2)
    aAdd(alSay, clDesc3)
    aAdd(alSay, clDesc4)
    aAdd(alSay, clDesc5)

    // Botoes do Formatch
    aAdd(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
    aAdd(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})

    FormBatch(clTitulo, alSay, alButton)

    If lOk
        Processa( { || RunFixLimits() }, "Atualizando limites em lote..." )
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    //³Destrava a rotina para o usuário	    ?
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    UnLockByName("FIXLIMITS")

Return

/*/{Protheus.doc} Static Function RunFixLimits
    (long_description)
    @type  Static Function
    @author FWNM
    @since 26/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunFixLimits()

    Local lFile     := .f.
    Local nCount    := 0
    Local aDadLC    := {}
    Local aCampos   := {}
	
	Private cMsgLim   := ""
	Private lCliente  := .f.
	Private lRede     := .f.
    Private cVerCli   := ""
	Private	cVerRed   := ""
	Private cTxt      := ""
    Private nLinhaXLS := 0
	Private cNumAudit := ""

	Private cCNPJ      := ""
	Private cRazao     := ""
	Private nLimiteXLS := 0
	Private nSA1Recno  := 0
	Private nPB3Recno  := 0
	Private nLimiteNew := 0
	Private cRede      := ""
	Private nSZFRecno  := 0
	Private nLimiteNew := 0

    cFile := cGetFile("Arquivos CSV (Separados por Vírgula) | *.CSV",;
    ("Selecione o diretorio onde encontra-se o arquivo a ser processado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If At(".CSV", upper(cFile)) > 0
        lFile := .t.
        ft_fUse(cFile)
    Else
        Aviso("RunFixLimits-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
		Return
    EndIf

    // Arquivo TXT
    If lFile
        
        ft_fGoTop()
        
        cVerCli := "CNPJ;RAZÃO SOCIAL; LIMITE ;SA1.RECNO;PB3.RECNO;Score; vlr maior acumulo AD'ORO ; EM ABERTO ;LIMITE + 30%;AÇÃO; % AUMENTO LIMITE ; NOVO LIMITE"
		cVerRed := "REDE;R_E_C_N_O_; Soma de LIM.REDE ; Média de SCORE ; Soma de vlr maior acumulo AD'ORO ; Soma de SLD.REDE ;LIMITE + 30%;AÇÃO; NOVO LIMITE ; % AUMENTO LIMITE"
        
        cTxt := AllTrim( ft_fReadLn() )
        
        cMsgLim := ""
		If cVerCli == cTxt
			lCliente := .t.
			cMsgLim := "Ajuste de Limites em lote - Clientes "
		ElseIf cVerRed == cTxt
			lRede := .t.
			cMsgLim := "Ajuste de Limites em lote - Redes "
		Else
            Aviso("RunFixLimits-02", "A importação não será realizada! As colunas do excel precisam ser " + cVerTab, {"&Ok"},, "Versão/Leiaute da planilha incorreta!")
			Return
		EndIf
            
		// Confirmação
		If !MsgYesNo("Confirma Ajuste de Limites em lote?", cMsgLim)
			Return
		EndIf
		
		If Select("TRB") > 0
			TRB->( dbCloseArea() )
		EndIf
			
		// Crio TRB para impressão
		// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
		oTempTable := FWTemporaryTable():New("TRB")
		
		// Arquivo TRB - CONSISTÊNCIAS
		aAdd( aCampos, {'NUMLINHA'   ,"N"    ,6 , 0} )
		aAdd( aCampos, {'STATUS'     ,"C"    ,100, 0} )
		aAdd( aCampos, {'LINHA'      ,"C"    ,254, 0} )
		aAdd( aCampos, {'VALOR_OLD'  ,"N"    ,TamSX3("A1_LC")[1] , TamSX3("A1_LC")[2]} )
		aAdd( aCampos, {'VALOR_NEW'  ,"N"    ,TamSX3("A1_LC")[1] , TamSX3("A1_LC")[2]} )

		oTempTable:SetFields(aCampos)
		oTempTable:AddIndex("01", {"NUMLINHA"} )
		oTempTable:Create()

		ProcRegua(0)

		// Consistência
		ft_fSkip() // Pula linha do cabeçalho
		Do While !ft_fEOF()
			
			IncProc( "Consistindo CSV antes de atualizar... " + StrZero(nCount++, 9) )
			
			nLinhaXLS++
			cTxt    := ft_fReadLn()
			aDadLC  := Separa(cTxt, ";")

			If lCliente
			
				cCNPJ      := aDadLC[1]
				cRazao     := aDadLC[2]
				nLimiteXLS := Val(StrTran(StrTran(aDadLC[3],".",""),",","."))
				nSA1Recno  := Val(aDadLC[4])
				nPB3Recno  := Val(aDadLC[5])
				nLimiteNew := Val(StrTran(StrTran(aDadLC[12],".",""),",","."))
			
			ElseIf lRede

				cRede      := aDadLC[1]
				nSZFRecno  := Val(aDadLC[2])
				nLimiteNew := Val(StrTran(StrTran(aDadLC[9],".",""),",","."))
			
			EndIf

			// Efetua consistências
			lLimOK := ChkDadLim(aDadLC)

			aDadLC := {}
			
			ft_fSkip()
			
		EndDo

		TRB->( dbGoTop() )
		If TRB->( !EOF() )

			If msgYesNo("Consistência finalizada! Existem problemas nos dados que impediram a importação dos títulos de acordo. Deseja listá-las agora?")
				ReportLIM()
			EndIf
		
		Else

			cLtParecer := Adoa5Parec()

			cNumAudit := UpAudit()
			
			ProcRegua(0)

			nCount    := 0
			nLinhaXLS := 0
			aDadLC    := {}

			ft_fGoTop()
			ft_fSkip() // Pula linha do cabeçalho

			// Importação
			Do While !ft_fEOF()
				
				IncProc( "Ajustando " + cMsgLim + StrZero(nCount++, 9) )
				
				nLinhaXLS++
				cTxt   := ft_fReadLn()
				aDadLC := Separa(cTxt, ";")
				
				If lCliente
				
					cCNPJ      := aDadLC[1]
					cRazao     := aDadLC[2]
					nLimiteXLS := Val(StrTran(StrTran(aDadLC[3],".",""),",","."))
					nSA1Recno  := Val(aDadLC[4])
					nPB3Recno  := Val(aDadLC[5])
					nLimiteNew := Val(StrTran(StrTran(aDadLC[12],".",""),",","."))
				
					// Cliente
					SA1->( dbGoTo(nSA1Recno) )
					If SA1->( !EOF() ) .and. AllTrim(cCNPJ) == Left(AllTrim(SA1->A1_CGC),8) //.and. AllTrim(cRazao) == AllTrim(SA1->A1_NOME)

						// Log antes alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(SA1) A1_LC ANTES: " + AllTrim(TransForm(SA1->A1_LC,PesqPict("SA1","A1_LC"))) + " RECNO " + AllTrim(Str(nSA1Recno)) + " CNPJ " + AllTrim(cCNPJ) + " RAZAO " + AllTrim(cRazao),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )
						
						// Log PB9
						U_Ado05Log( SA1->A1_COD, SA1->A1_LOJA, cUserName, msDate(), Posicione('SX3', 2, 'A1_LC', 'X3_Titulo' ), SA1->A1_LC, nLimiteNew )

						RecLock("SA1",.f.)
							SA1->A1_LC := nLimiteNew
						SA1->( MsUnlock() )

						// Log APOS alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(SA1) A1_LC AJUSTADO: " + AllTrim(TransForm(SA1->A1_LC,PesqPict("SA1","A1_LC"))) + " RECNO " + AllTrim(Str(nSA1Recno)) + " CNPJ " + AllTrim(cCNPJ) + " RAZAO " + AllTrim(cRazao),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )

						// Log Parecer
						Adoa5Parec(SA1->A1_COD, SA1->A1_LOJA, cLtParecer)

					Else

						GrvTRB("Algum problema ocorreu que não permitiu o ajuste do Limite crédito - agrupador/auditoria n. " + cNumAudit, nLinhaXLS, cTXT, nValorXLS, nValorNew)

					EndIf

					// Pré-Cadastro
					PB3->( dbGoTo(nPB3Recno) )
					If PB3->( !EOF() ) .and. AllTrim(cCNPJ) == Left(AllTrim(PB3->PB3_CGC),8) //.and. AllTrim(cRazao) == AllTrim(PB3->PB3_NOME)
					
						// Log antes alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(PB3) PB3_LC ANTES: " + AllTrim(TransForm(PB3->PB3_LIMAPR,PesqPict("PB3","PB3_LC"))) + " RECNO " + AllTrim(Str(nPB3Recno)) + " CNPJ " + AllTrim(cCNPJ) + " RAZAO " + AllTrim(cRazao),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )

						// Log PB9
						U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cUserName, msDate(), Posicione('SX3', 2, 'PB3_LC', 'X3_Titulo' ), PB3->PB3_LIMAPR, nLimiteNew )

						RecLock("PB3",.f.)
							PB3->PB3_LC     := nLimiteNew
							PB3->PB3_LIMAPR := nLimiteNew
						PB3->( MsUnlock() )

						// Log APOS alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(PB3) PB3_LC AJUSTADO: " + AllTrim(TransForm(PB3->PB3_LIMAPR,PesqPict("PB3","PB3_LC"))) + " RECNO " + AllTrim(Str(nPB3Recno)) + " CNPJ " + AllTrim(cCNPJ) + " RAZAO " + AllTrim(cRazao),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )

						// Log Parecer
						Adoa5Parec(PB3->PB3_COD, PB3->PB3_LOJA, cLtParecer)

						GrvTRB("CLIENTE - Limite crédito ajustado com sucesso - agrupador/auditoria n. " + cNumAudit, nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)

					Else

						GrvTRB("Algum problema ocorreu que não permitiu o ajuste do Limite crédito - agrupador/auditoria n. " + cNumAudit, nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)

					EndIf

				ElseIf lRede

					cRede      := aDadLC[1]
					nSZFRecno  := Val(aDadLC[2])
					nLimiteNew := Val(StrTran(StrTran(aDadLC[9],".",""),",","."))

					SZF->( dbGoTo(nSZFRecno) )
					If SZF->( !EOF() ) .and. AllTrim(cRede) == AllTrim(SZF->ZF_REDE)

						nLimiteXLS := SZF->ZF_LCREDE

						// Log antes alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(SZF) ZF_LCREDE ANTES: " + AllTrim(TransForm(SZF->ZF_LCREDE,PesqPict("SZF","ZF_LCREDE"))) + " RECNO " + AllTrim(Str(nSZFRecno)) + " REDE " + AllTrim(cRede),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )

						///////////
						// Log PB9
						///////////

						// SA1
						If Select("WorkLOG") > 0
							WorkLOG->( dbCloseArea() )
						EndIf

						cQuery := " SELECT A1_COD, A1_LOJA, A1_CODRED 
						cQuery += " FROM " + RetSqlName("SA1") + " (NOLOCK)
						cQuery += " WHERE A1_FILIAL='"+FWxFilial("SA1")+"'
						cQuery += " AND A1_CODRED='"+SZF->ZF_REDE+"'
						cQuery += " AND D_E_L_E_T_=''

						tcQuery cQuery New Alias "WorkLOG"

						WorkLOG->( dbGoTop() )
						Do While WorkLOG->( !EOF() )
							U_Ado05Log( WorkLOG->A1_COD, WorkLOG->A1_LOJA, cUserName, msDate(), Posicione('SX3', 2, 'ZF_LCREDE', 'X3_Titulo' ), SZF->ZF_LCREDE, nLimiteNew )
							Adoa5Parec( WorkLOG->A1_COD, WorkLOG->A1_LOJA, cLtParecer )
							WorkLOG->( dbSkip() )
						EndDo

						// PB3
						If Select("WorkLOG") > 0
							WorkLOG->( dbCloseArea() )
						EndIf

						cQuery := " SELECT PB3_COD, PB3_LOJA, PB3_CODRED 
						cQuery += " FROM " + RetSqlName("PB3") + " (NOLOCK)
						cQuery += " WHERE PB3_FILIAL='"+FWxFilial("PB3")+"'
						cQuery += " AND PB3_CODRED='"+SZF->ZF_REDE+"'
						cQuery += " AND D_E_L_E_T_=''

						tcQuery cQuery New Alias "WorkLOG"

						WorkLOG->( dbGoTop() )
						Do While WorkLOG->( !EOF() )
							U_Ado05Log( WorkLOG->PB3_COD, WorkLOG->PB3_LOJA, cUserName, msDate(), Posicione('SX3', 2, 'ZF_LCREDE', 'X3_Titulo' ), SZF->ZF_LCREDE, nLimiteNew )
							Adoa5Parec( WorkLOG->PB3_COD, WorkLOG->PB3_LOJA, cLtParecer )
							WorkLOG->( dbSkip() )
						EndDo

						If Select("WorkLOG") > 0
							WorkLOG->( dbCloseArea() )
						EndIf

						RecLock("SZF",.f.)
							SZF->ZF_LCREDE := nLimiteNew
						SZF->( MsUnlock() )

						// Log APOS alteracao
						u_GrLogZBE( msDate(), TIME(), cUserName,;
						"(SZF) ZF_LCREDE AJUSTADO: " + AllTrim(TransForm(SZF->ZF_LCREDE,PesqPict("SZF","ZF_LCREDE"))) + " RECNO " + AllTrim(Str(nSZFRecno)) + " REDE " + AllTrim(cRede),;
						cModuloZBE, cNumAudit, "Aglutinador: " + cNumAudit + " - Arquivo: " + cFile + " - Linha: " + AllTrim(Str(nLinhaXLS)),;
						ComputerName(), LogUserName() )

						GrvTRB("REDE - Limite crédito ajustado com sucesso - agrupador/auditoria n. " + cNumAudit, nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)

					Else
					
						GrvTRB("Algum problema ocorreu que não permitiu o ajuste do Limite crédito - agrupador/auditoria n. " + cNumAudit, nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)

					EndIf

				EndIf

				aDadLC := {}
				
				ft_fSkip()
				
			EndDo
		
			Aviso("ADOA005-01", "Limites de créditos ajustados com sucesso! Será gerado um excel com o detalhamento para sua conferência..." , {"OK"},, "Agrupador/Auditoria (ZBE) n. " + cNumAudit)
			ReportLIM()

		EndIf
            
    EndIf
    
Return

/*/{Protheus.doc} Static Function GrvTRB(1, RC1_NUMTIT, cTXT)
    Popula TRB para listagem
    @type  Static Function
    @author FWNM
    @since 26/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(cDetalhe, nNumLinha, cTXT, nValorXLS, nValorNew)

    Default cDetalhe  := ""
	Default nNumLinha := ""
	Default cTXT      := ""
	Default nValorXLS := 0
	Default nValorNew := 0
	
    RecLock("TRB", .T.)

		TRB->STATUS    := cDetalhe
	    TRB->NUMLINHA  := nNumLinha
		TRB->LINHA     := cTXT
        TRB->VALOR_OLD := nValorXLS
        TRB->VALOR_NEW := nValorNew

	TRB->( msUnLock() )
	
Return

/*/{Protheus.doc} Static Function ReportLIM
    Gera listagem de inconsistência
    @type  Static Function
    @author FWNM
    @since 26/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportLIM()

	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function ReportDef
	ReportDef
	@type  Function
	@author Fernando Macieira
	@version 01
/*/
Static Function ReportDef(cAliasTRB)
                                   
	Local oReport
	Local oTitulos
	Local aOrdem := {}
	  
	Local cTitulo := cMsgLim

	cAliasTRB := "TRB"
	
	oReport := TReport():New("IMPLIMITE"+AllTrim(cUserName)+DtoS(msDate())+StrTran(time(),":","_"),OemToAnsi(cTitulo), /*cPerg*/, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )

	oReport:nDevice     := 4 // XLS

	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oTitulos := TRSection():New(oReport, OemToAnsi(cTitulo),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oReport:SetTotalInLine(.F.)
	
    TRCell():New(oTitulos,	"NUMLINHA"   ,"","Número Linha"                /*Titulo*/,  /*Picture*/ ,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"STATUS"     ,"","Detalhamento da Ocorrência"  /*Titulo*/,  /*Picture*/ ,50 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"LINHA"      ,"","Conteúdo Linha"              /*Titulo*/,  /*Picture*/ ,150 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"VALOR_OLD"  ,"","Limite Crédito Antigo"       /*Titulo*/,  "@E 999,999,999.99" ,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oTitulos,	"VALOR_NEW"  ,"","Limite Crédito Novo"         /*Titulo*/,  "@E 999,999,999.99" ,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return oReport

/*/{Protheus.doc} Static Function ReportPrint
	ReportPrint
	@type  Function
	@version 01
/*/
Static Function ReportPrint(cAliasTRB)

	Local oTitulos := oReport:Section(1)
	
	dbSelectArea("TRB")
	TRB->( dbSetOrder(1) )
	
	oTitulos:SetMeter( LastRec() )
	
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )
		
		oTitulos:IncMeter()
		
		oTitulos:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//Impressao propriamente dita....
		oTitulos:Cell("NUMLINHA")  :SetBlock( {|| TRB->NUMLINHA} )
		oTitulos:Cell("STATUS")    :SetBlock( {|| TRB->STATUS} )
		oTitulos:Cell("LINHA")     :SetBlock( {|| TRB->LINHA} )
		oTitulos:Cell("VALOR_OLD") :SetBlock( {|| TRB->VALOR_OLD} )
    	oTitulos:Cell("VALOR_NEW") :SetBlock( {|| TRB->VALOR_NEW} )

		oTitulos:PrintLine()
		oReport:IncMeter()
	
		TRB->( dbSkip() )
		
	EndDo
	
	oTitulos:Finish()

	If Select("TRB") > 0
		TRB->( dbCloseArea() )
	EndIf
	
	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	//oTempTable:Delete()  

Return

/*/{Protheus.doc} Static Function ChkDadLim(aDadLC)
    Checa dados da planilha em busca de inconsistências
    @type  Static Function
    @author FWNM
    @since 26/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkDadLim(aDadLC)

    Local lRet := .t.
    //Local cQuery  := ""

	If lCliente

		SA1->( dbGoTo(nSA1Recno) )
		If SA1->( !EOF() )

			If AllTrim(cCNPJ) <> Left(AllTrim(SA1->A1_CGC),8)
				lRet := .f.
				GrvTRB("CNPJ Cliente (SA1) divergente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
			EndIf

			/*
			If AllTrim(cRazao) <> AllTrim(SA1->A1_NOME)
				lRet := .f.
				GrvTRB("Nome/Razão Cliente (SA1) divergente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
			EndIf
			*/

		Else
			lRet := .f.
			GrvTRB("RECNO Cliente (SA1) não existente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
		EndIf

		PB3->( dbGoTo(nPB3Recno) )
		If PB3->( !EOF() )

			If AllTrim(cCNPJ) <> Left(AllTrim(PB3->PB3_CGC),8)
				lRet := .f.
				GrvTRB("CNPJ Pré-Cadastro (PB3) divergente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
			EndIf

			/*
			If AllTrim(cRazao) <> AllTrim(PB3->PB3_NOME)
				lRet := .f.
				GrvTRB("Nome/Razão Pré-Cadastro (PB3) divergente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
			EndIf
			*/

		Else
			lRet := .f.
			GrvTRB("RECNO Pré-Cadastro (PB3) não existente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
		EndIf

	ElseIf lRede

		SZF->( dbGoTo(nSZFRecno) )
		If SZF->( !EOF() )

			If AllTrim(cRede) <> AllTrim(SZF->ZF_REDE)
				lRet := .f.
				GrvTRB("Rede (ZF_REDE) divergente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
			Else

				//@history Tickets TI - Fernando Macieira - 31/08/2021 - Consistência Redes (SZF) para checar outros valores antes de gravar para não "somar"
				If Select("WorkSZF") > 0
					WorkSZF->( dbCloseArea() )
				EndIf

				cQuery := " SELECT ZF_REDE, ZF_CGCMAT, ZF_LCREDE, R_E_C_N_O_ RECNO
				cQuery += " FROM " + RetSqlName("SZF") + " (NOLOCK)
				cQuery += " WHERE ZF_REDE='"+cRede+"'
				cQuery += " AND ZF_LCREDE>0
				cQuery += " AND R_E_C_N_O_<>'"+AllTrim(Str(nSZFRecno))+"'
				cQuery += " AND D_E_L_E_T_=''

				tcQuery cQuery New Alias "WorkSZF"

				WorkSZF->( dbGoTop() )
				Do While WorkSZF->( !EOF() )
					lRet := .f.
					GrvTRB("RECNO " + AllTrim(Str(nSZFRecno)) + " desta rede (ZF_REDE) possui valor! Verifique RECNO informado no xls", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
					WorkSZF->( dbSkip() )
				EndDo

				If Select("WorkSZF") > 0
					WorkSZF->( dbCloseArea() )
				EndIf
				//

			EndIf

		Else
			lRet := .f.
			GrvTRB("RECNO Rede (ZSF) não existente", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
		EndIf

	EndIf

	If nLimiteNew < 0
		lRet := .f.
		GrvTRB("Novo Limite de Crédito negativo", nLinhaXLS, cTXT, nLimiteXLS, nLimiteNew)
	EndIf

Return lRet

/*/{Protheus.doc} Static Function UpAudit()
    Agrupador para auditoria
    @type  Static Function
    @author FWNM
    @since 26/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function UpAudit()

    Local cNextCod := "00000000000000000001"
    Local cQuery   := ""

    If Select("WorkNext") > 0
        WorkNext->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ISNULL(MAX(ZBE_ROTINA),'FIRST') AS NEXT_COD
    cQuery += " FROM " + RetSqlName("ZBE") + " (NOLOCK) 
    cQuery += " WHERE D_E_L_E_T_='' 
	cQuery += " AND ZBE_MODULO='LIMITE_CREDITO_LOTE'

    tcQuery cQuery New Alias "WorkNext"

	If AllTrim(WorkNext->NEXT_COD) == "FIRST"
		cNextCod := "00000000000000000001"	
	Else
        cNextCod := Soma1(AllTrim(WorkNext->NEXT_COD))
    EndIf

    If Select("WorkNext") > 0
        WorkNext->( dbCloseArea() )
    EndIf

Return cNextCod
