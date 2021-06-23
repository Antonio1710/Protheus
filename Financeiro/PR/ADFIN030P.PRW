#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*/{Protheus.doc} User Function ADFIN030P
	Painel do Contas a Receber - Funções do contas a receber. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
	@history Chamado 045047 - William Costa   - 08/01/2019 - Adicionado botao de chamada de relatorio titulos faturados de Rede e Clientes
	@history Chamado 047186 - William Costa   - 19/02/2019 - Adicionado campos no Relatorio Analitico de Cobranca A1_EMAIL A1_EMAICOB E1_NUMBCO
	@history Chamado 049082 - Everson         - 13/05/2019 - Alterado campo de vendedor. 
	@history Chamado 049215 - Adriano Savoine - 15/05/2019 - Foi alterada a comparação na query onde estava A1_Vend > 0 para A1_VEND <> ''.
	@history Chamado TI     - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado TI     - Adriana         - 30/05/2019 - Correcao chamada das funcoes ADFIN011P-14P
	@history Chamado TI     - Fernando        - 04/10/2019 - Separado a rotina de WF vendedore X WF Financ
	@history Chamado 053260 - WILLIAM COSTA   - 11/11/2019 - Ajustado para poder trazer indiferente se o cnpj que tem o limite está devendo no financeiro ou não
	@history Chamado 056404 - WILLIAM COSTA   - 20/04/2020 - Adicionado botão de co-participação
	@history Chamado 059415 - FWNM            - 03/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	@history Chamado 425    - WILLIAM COSTA   - 30/09/2020 - Adicionado botão do relatório de perdas
	@history Ticket  14417  - ADRIANO SAVOINE - 31/05/2021 - Criado o campo para o usuario digitar a porcentagem no momento da consulta.
/*/
User Function ADFIN030P() // U_ADFIN030P()

	Local aArea			:= GetArea()
	Local oTelMenu
	Local oCobranca
	Local oResultFin
	Local oRelLmtUt
	Local oAltBco
	Local oWorkVend
	Local oWorkFat
	

	Local oFechar

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Painel do Contas a Receber - Funções do contas a receber. ')

	oTelMenu		   := MsDialog():Create()
	oTelMenu:cName     := "oTelMenu"
	oTelMenu:cCaption  := "Contas a Receber"
	oTelMenu:nLeft     := 34
	oTelMenu:nTop      := 222
	oTelMenu:nWidth    := 500 //250
	oTelMenu:nHeight   := 590//550//520//490
	oTelMenu:lShowHint := .F.
	oTelMenu:lCentered := .T.


	oCobranca := TButton():New(016,005,"Cobrança Diária/Controle de Carteira",oTelMenu,{|| cobDia() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

	oResultFin:= TButton():New(039,005,"Lançamentos Contábeis - Result. Fin.",oTelMenu,{|| lancCoRFin() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) // Everson - 04/07/2017. Chamado 035784.

	oResultFin:= TButton():New(062,005,"Cadastros Pendentes",oTelMenu,{|| cadastros() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 26/06/2017. Chamado 034700.

 	oRelLmtUt := TButton():New(085,005,"Rel. Utilização de Limites",oTelMenu,{|| intRelLmUt() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 30/08/2017. Chamado 035785.

	oAltBco   := TButton():New(108,005,"Alteração Banco - Pedidos",oTelMenu,{|| altBancos() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 30/08/2017. Chamado 035785.

	oWorkVend := TButton():New(131,005,"Alteração Banco - Clientes",oTelMenu,{|| altClient() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 19/01/2018. Chamado T.I.
	
	oWorkVend := TButton():New(154,005,"Workflow Vendedores ",oTelMenu,{|| workVend() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 19/01/2018. Chamado T.I.
	
	oWorkFat  := TButton():New(177,005,"Workflow Faturamento",oTelMenu,{|| workFat() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 19/01/2018. Chamado T.I.
	
	oWorkFat  := TButton():New(200,005,"Eficiencia de cobranca",oTelMenu,{|| U_ADFIN069R() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Fernando Sigoli - 09/10/2018 Chamado:043988
	
	oWorkFat  := TButton():New(223,005,"Rel Faturamento Rede Segmento",oTelMenu,{|| U_ADFIN071R() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //William Costa - 08/01/2019 Chamado:045047
	
	oWorkVend := TButton():New(246,005,"Workflow Vencidos ",oTelMenu,{|| workFina() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) //Fernando Sigoli- 04/10/2019. Chamado T.I.
	
	oWorkFat := TButton():New(016,125,"Rel Co-Participação",oTelMenu,{|| U_ADFIN085R() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oWorkFat := TButton():New(039,125,"Pedidos Vendas com adiantamentos",oTelMenu,{|| U_ADFIN090P() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. ) // Chamado 059415 - FWNM - 03/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO

	oWorkFat := TButton():New(062,125,"Rel Fechamento de Perdas",oTelMenu,{|| U_ADFIN096R() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oGroup1  := TGroup():Create(oTelMenu,276,005,151,120,"",,,.T.)

	oFechar := TButton():New(271,200,"Fechar",oTelMenu,{|| oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oTelMenu:Activate(,,,.T.,{||.T.},,{||  })

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function workFat
	Envio de workflow vendedores.
	@type  Function
	@author Everson
	@since 19/01/2018
	@version version
/*/

Static Function workFat()
	
	//
	If ! MsgYesNo("Deseja enviar o workflow de faturamento?","Função workFat")
		Return Nil
		
	EndIf

	MsAguarde({|| U_ADFIN037R() },"Aguarde","Enviando relatório...")

Return Nil

/*/{Protheus.doc} Static Function workVend
	Envio de workflow vendedores.
	@type  Function
	@author Everson
	@since 19/01/2018
	@version version
/*/

Static Function workVend()
	
	//
	If ! MsgYesNo("Deseja enviar os workflows de vendedores ?","Função workVend")
		Return Nil
		
	EndIf

	MsAguarde({|| U_ADFIN031R() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos (Existem três destinatários)","1/5 - Enviando e-mails Vendedores...")
	//MsAguarde({|| U_ADFIN011P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","2/5 - Enviando e-mails para Clientes Título vencido + 2 dias ...") //Alterado por Fernando Sigoli- 04/10/2019. Chamado T.I.
	//MsAguarde({|| U_ADFIN012P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","3/5 - Enviando e-mails para Clientes Título vencido + 4 dias...")  //Alterado por Fernando Sigoli- 04/10/2019. Chamado T.I.
	//MsAguarde({|| U_ADFIN013P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","4/5 - Enviando e-mails para Clientes Título com situacao F...")  //Alterado por Fernando Sigoli- 04/10/2019. Chamado T.I.
	//MsAguarde({|| U_ADFIN014P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","5/5 - Enviando e-mails para Clientes Título a vencer com dois dias do vencimento...")  //Alterado por Fernando Sigoli- 04/10/2019. Chamado T.I.

Return Nil

/*/{Protheus.doc} Static Function workFina
	Envio de workflow Vencidos para Clientes?
	@type  Function
	@author Everson
	@since 04/10/2019
	@version version
/*/

Static Function workFina()
	
	If ! MsgYesNo("Deseja enviar os workflows Titulos Vencidos para Clientes?","Função workVend")
		Return Nil
		
	EndIf

	MsAguarde({|| U_ADFIN011P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","2/5 - Enviando e-mails para Clientes Título vencido + 2 dias ...") //Alterado por Adriana em 30/05/2019
	MsAguarde({|| U_ADFIN012P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","3/5 - Enviando e-mails para Clientes Título vencido + 4 dias...")  //Alterado por Adriana em 30/05/2019
	MsAguarde({|| U_ADFIN013P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","4/5 - Enviando e-mails para Clientes Título com situacao F...")  //Alterado por Adriana em 30/05/2019
	MsAguarde({|| U_ADFIN014P() },"Aguarde - Envio " + CVALTOCHAR(GETMV('MV_#QTDEMA',,40)) + " e-mails a cada 2 minutos ","5/5 - Enviando e-mails para Clientes Título a vencer com dois dias do vencimento...")  //Alterado por Adriana em 30/05/2019

Return Nil

/*/{Protheus.doc} Static Function cadastros
	Cadastros pendentes. 
	@type  Function
	@author Everson
	@since 11/12/2017
	@version version
/*/

Static Function cadastros()

	logAcesso("CADASTROS")

	U_ADFIN036P()

Return Nil

/*/{Protheus.doc} Static Function altBancos
	Alteração de banco no cadastro do cliente.  
	@type  Function
	@author Everson
	@since 11/12/2017
	@version version
/*/

Static Function altBancos()

	logAcesso("ALTBANCOS")

	U_ADFIN049P()

Return Nil

Static Function altClient()
                 
	logAcesso("ALTCLIENT")

	U_ADFIN059P()

Return Nil

/*/{Protheus.doc} Static Function cobDia
	Cobrança diária. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function cobDia()

	Local aArea			:= GetArea()
	Local oPnlTool
	Local oGrpTool
	Local oTxtBusca
	Local oBusca
	Local cBusca		:= Space(60)
	Local nBusca		:= 0
	Local oSelBusca
	Local aSelBusca		:= {}
	Local cSelBusca		:= ""
	Local oCSVTool
	Local oMenuCSV
	Local oCSVS
	Local oCSVA
	Local oTotFaix

	Local oTitulos
	Local aAltTitulos	:= {}
	Local aColsTitulos	:= {}

	Local oGroup1
	Local oGroup2
	Local oFechar

	Local oPnlFaixaAtr
	Local bIFaxAtr		:= {|| oPnlFiltro:Hide(), oAtul:Disable(), oFaxAt:Disable(), oFitro:Disable()   , oPnlFaixaAtr:Show()}
	Local bFFaxAtr		:= {|| oAtul:Enable()   ,oFaxAt:Enable (), oFitro:Enable() , oPnlFaixaAtr:Hide(),oPnlFiltro:Show() }
	Local oFont 		:= TFont():New(,,-14,,.T.)
	Local oTxtFaixAtr
	Local oGroup3
	Local oGroup4
	Local oCSVFaxAt
	Local oCaFaxAt
	Local oOkFaxAt
	Local oFaixas
	Local aAltFaixas	:= {"FAIXA","DEATR","ATEATR"}
	Local aHFaixas		:= {}
	Local aColsFaixas	:= {}

	Local oPnlFiltro
	Local oFitro
	Local oTxtFiltro
	Local bIFiltro		:= {|| oFaxAt:Enable() , aplGridFilt(),oTFFiltro:SetOption(2),filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),Iif(ValType(oTitulos) == "O",oTitulos:Hide(),Nil), oAtul:Disable(), oFaxAt:Disable(), oFaxAt:Enable(), oFitro:Disable(), oPnlFiltro:Show(), oPnlTool:Hide()}
	Local bFFiltro		:= {|| oFaxAt:Disable(),Iif(ValType(oTitulos) == "O",Eval({||oPnlFiltro:Hide(),oAtul:Enable(),oFaxAt:Enable() ,oFitro:Enable(),oFaxAt:Disable(),oTitulos:Show(),oPnlTool:Show()}),MsgStop("Filtro não aplicado.","Função cobDia"))}
	Local oCaFiltro
	Local oOkFiltro

	Local aTFFiltro  	:= {}
	Local oPnlFCmp
	Local oDataBase
	Local oAplUser

	Local oGrpTab	 
	Local oGrpCmp	 
	Local oGrpFilt
	Local oTxtFCmp
	Local aFTabelas		:= {}
	Local cFTabelas		:= ""
	Local oFTabelas

	Local oPnlFilt1
	Local oGrpFCFx
	Local oMkFxAtr

	Local oGrpFCPort
	Local oMkFxPort

	Local oGrpFCSitu
	Local oMkSitu

	Local oGRpFCRede
	Local oMkRede

	Local oGRpFCTit
	Local oMkTitulo

	Local bApgArqTemp	:= {|| FErase("T_ADFIN030P_CC_*" + GetDBExtension()) }

	Local oFCDetalhes
	Local oExFilExp

	Local i				:= 1

	Private lHistFilt1	:= .F.

	Private cFiltFaixas	:= ""
	Private cFiltPortad	:= ""
	Private cFiltSituad	:= ""
	Private cFiltRede	:= ""
	Private cFiltRedeR	:= ""
	Private cFiltTpTit	:= ""

	Private aHistFxAtr	:= {}
	Private aHistPortad	:= {}
	Private aHistSituac	:= {}
	Private aHistRede	:= {}
	Private aHisTTPTIT	:= {}

	Private cArFxAtr
	Private cArPortad
	Private cArSituac
	Private cArRede
	Private cArTpTit

	Private aHTitulos	:= {}

	Private oCobranca
	Private oPnlDetalhes
	Private oTxtDetalhes
	Private aADetalhes	:= {}
	Private aHDetalhes	:= {}
	Private aColsDetalhes := {}
	Private oDetalhes
	Private oCSVPnDet
	Private oEdtHist

	Private cFilSE1		:= ""
	Private cFilSA1		:= ""
	Private cFilSA3		:= ""
	Private cFilSZF		:= ""

	Private oFilExpress
	Private aHFilExpress   := {}
	Private aColsFilExpress:= {}
	Private aAltFilExpress := {}

	Private dDataIni		:= dDataBase
	Private dDataAnt		:= dDataIni
	Private oSplitter

	Private cUsuarios	:= GetMv("MV_#FICODI")
	Private lAplUser	:= .F.
	Private oTFFiltro

	Private oTotDetS
	Private nTotDetS
	Private nTotDetV
	Private oTotDetV

	Private cFilSaldo := ""
	Private aVlrxSld  := {}
	Private cVlrxSld  := ""
	Private oVlrxSld

	Private nTotTT	  := 0
	Private oTotTT	

	Private bDisableBtn := {|| oAtul:Disable(), oFaxAt:Disable(), oFitro:Disable() }
	Private bEnableBnt	:= {|| oAtul:Enable() , oFitro:Enable() }

	Private bResetFilt	:= {|| lHistFilt1 := .F., aHistFxAtr := {}, aHistPortad := {}, aHistSituac := {}, aHistRede := {}, aHisTTPTIT := {}}

	Private cStatCli 	:= " AND (A1_MSBLQL = '2') "
	Private aCliAtv  	:= {}
	    Private oCliAtv

	Private aRDtCalc	:= {}
	Private nRDtCalc	:= 1	
	Private nRDtCalcA   := nRDtCalc
	Private oRDtCalc

	Private oMkRdBusca

	Private aArqTemp	:= {}

	//Log de acesso.
	logAcesso("COBDIARIA")

	oCobranca			:= MsDialog():Create()
	oCobranca:cName     := "oCobranca"
	oCobranca:cCaption  := "Cobrança Diária"
	oCobranca:nLeft     := 34
	oCobranca:nTop      := 222
	oCobranca:nWidth    := 1200
	oCobranca:nHeight   := 550
	oCobranca:lShowHint := .F.
	oCobranca:lCentered := .T.

	oMenuCSV := TMenu():New( 0,0,0,0,.T.)  
	oCSVS := TMenuItem():New(oCobranca,"CSV Sintético",,,,{|| MsAguarde({||grCSVS(oTitulos,aHTitulos)},"Aguarde","Gerando CSV sintético...") },,,,,,,,,.T.)
	oCSVA := TMenuItem():New(oCobranca,"CSV Analítico",,,,{|| MsAguarde({||grCSVA(oTitulos,aHTitulos)},"Aguarde","Gerando CSV analítico...") },,,,,,,,,.T.)

	oMenuCSV:Add(oCSVS)
	oMenuCSV:Add(oCSVA)

	oPnlTool := TPanel():New(002,005,,oCobranca,,.T.,,CLR_BLACK,CLR_WHITE,535,027,,.T.)
	oPnlTool:SetCss("QLabel{background-color: #F9F9F9;}")

	oGrpTool := TGroup():Create(oPnlTool,001,001,026,534,"",,,.T.)

	oTxtBusca := TSay():New(002,010,{||"Localiza registro:"},oPnlTool,,,,,,.T.,CLR_RED,CLR_WHITE,250,20)
	aSelBusca := {"1=Nome Rede","2=Código Rede"}
	cSelBusca := aSelBusca[1]
	        oSelBusca := TComboBox():New(010,010,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
	        aSelBusca,050,22,oPnlTool,,,,,,.T.,,,,,,,,,'cSelBusca')

	oBusca   := TGet():New(010,062,{|u|If(PCount() == 0,cBusca,cBusca := u)},oPnlTool,100,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"",2) 
	oBtnBusca:= TButton():New(010,165,"Ok",oPnlTool,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnBusca:bAction := {|| nBusca := Ascan(oTitulos:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[Val(cValToChar(cSelBusca))])}),;
	Iif(nBusca > 0,Eval({||oTitulos:ForceRefresh(),oTitulos:GoTo(nBusca),oTitulos:Refresh()}),;
	MsgAlert("Não foi possível localizar o registro","Função cobDia"))}

	oCSVTool := TButton():New(010,369,"CSV",oPnlTool,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCSVTool:SetPopupMenu(oMenuCSV)

	oTotFaix := TButton():New(010,414,"Total Faixa",oPnlTool,{|| Iif((Len(oTitulos:aCols) - 1) > 0, Eval({|| oTitulos:GoTop(), oTitulos:GoTo(Len(oTitulos:aCols) - 1)}) ,Nil) , exibTotFaixa(oTitulos,aHTitulos) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	nTotTT    := 0
	oTotTT  := TGet():New(002,459,{|u|If(PCount() == 0,nTotTT,nTotTT := u)},oPnlTool,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotTT",,,,.T.,,,"Saldo Total:",1) 


	oPnlTool:Hide()

	oSplitter := tSplitter():New(030,005,oCobranca,535,200,2)

	oGroup1  := TGroup():Create(oCobranca,001,545,235,595,"",,,.T.)
	oAtul := TButton():New(006,550,"Atualizar"   ,oCobranca,{|| MsAguarde({|| carrCobDia(oCobranca,oSplitter,@oTitulos,@aAltTitulos,@aColsTitulos) },"Aguarde","Atualizando dados...")},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFaxAt:= TButton():New(021,550,"Faixa Atraso",oCobranca,;
	{|| Iif( ! (Alltrim(cValToChar(__cUserID)) $cUsuarios), MsgStop("Usuário sem acesso ao cadastro","Função cobDia") , Eval({|| Eval(bIFaxAtr), carrFaixaAtr(oFaixas,aHFaixas) })) };
	,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFitro:= TButton():New(036,550,"Filtro",oCobranca,{|| Eval(bIFiltro) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFitro:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #0000CC, stop: 1 #190033);color: white}")

	//Cadastro faixa de atraso.	
	oPnlFaixaAtr := TPanel():New(002,005,,oCobranca,,.T.,,CLR_BLACK,CLR_WHITE,535,234,,.T.)
	oPnlFaixaAtr:SetCss("QLabel{background-color: #F9F9F9;}")

	oGroup4 := TGroup():Create(oPnlFaixaAtr,001,131,231,403,"",,,.T.)
	oTxtFaixAtr	:= TSay():New(006,136,{||"Cadastro de Faixas de Atraso"},oPnlFaixaAtr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,20)
	Aadd(aHFaixas,{"Faixa"               ,"FAIXA" ,"@E 999,999,999" ,11, 0,"","" ,"N","",""})
	Aadd(aHFaixas,{"De - Dias de atraso" ,"DEATR" ,"@E 999,999,999" ,11, 0,"","" ,"N","",""})
	Aadd(aHFaixas,{"Até - Dias de atraso","ATEATR","@E 999,999,999" ,11, 0,"","" ,"N","",""})
	oFaixas  := MsNewGetDados():New(020,136,199,398,GD_INSERT + GD_UPDATE + GD_DELETE,"Allwaystrue()","Allwaystrue()","",aAltFaixas,Nil,999,Nil,Nil,Nil,oPnlFaixaAtr,aHFaixas,@aColsFaixas)

	oGroup3   := TGroup():Create(oPnlFaixaAtr,204,136,226,398,"",,,.T.)
	//oCSVFaxAt := TButton():New(209,141,"Imp. CSV",oPnlFaixaAtr,{|| Eval(bFFaxAtr) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oOkFaxAt  := TButton():New(209,308,"Salvar"  ,oPnlFaixaAtr,;
	{||;
	slvFaixaAtr(oFaixas,aHFaixas),;
	Eval(bFFaxAtr),;
	aplGridFilt(),;
	oTFFiltro:SetOption(2),;
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),;
	},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oCaFaxAt  := TButton():New(209,353,"Cancelar",oPnlFaixaAtr,{|| Eval(bFFaxAtr) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oPnlFaixaAtr:Hide()

	oPnlDetalhes   := TPanel():New(002,005,,oCobranca,,.T.,,CLR_BLACK,CLR_WHITE,535,233,,.T.)
	oPnlDetalhes:SetCss("QLabel{background-color: #F9F9F9;}")

	oCSVPnDet := TButton():New(011,335,"CSV",oPnlDetalhes,{|| MsAguarde({|| grCSVDet(oDetalhes,aHDetalhes)},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	nTotDetS := 0
	oTotDetS := TGet():New(002,380,{|u|If(PCount() == 0,nTotDetS,nTotDetS := u)},oPnlDetalhes,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotDetS",,,,.T.,,,"Saldo Total: ",1) 

	nTotDetV := 0
	oTotDetV := TGet():New(002,455,{|u|If(PCount() == 0,nTotDetV,nTotDetV := u)},oPnlDetalhes,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotDetV",,,,.T.,,,"Valor Total: ",1) 

	oFCDetalhes:= TButton():New(219,490,"Ok",oPnlDetalhes,{|| oPnlDetalhes:Hide(), oSplitter:Show(),Eval(bEnableBnt) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oPnlDetalhes:Hide()
	//

	//Filtro.
	oPnlFiltro  := TPanel():New(002,005,,oCobranca,,.T.,,CLR_BLACK,CLR_WHITE,535,233,,.T.)
	oPnlFiltro:SetCss("QLabel{background-color: #F9F9F9;}")

	oTxtFiltro := TSay():New(006,005,{||"Filtro de Dados"},oPnlFiltro,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,20)

	aTFFiltro := {"Filtro SQL","Faixas de Atraso/Portador/Situação/Rede"}
	oTFFiltro := TFolder():New(020,005,aTFFiltro,,oPnlFiltro,,,,.T.,,525,195)

	oPnlFCmp := TPanel():New(000,000,,oTFFiltro:aDialogs[1],,.T.,,CLR_BLACK,CLR_WHITE,535,233,,)
	oGrpTab	 := TGroup():Create(oPnlFCmp,005,005,180,120,"Parâmetros"   ,,,.T.)

	aRDtCalc := {"Considera 'Data Cálculo'","Não considera 'Data Cálculo'"}
	oRDtCalc := TRadMenu():New (020,010,aRDtCalc,,oPnlFCmp,,,,,,,,100,12,,,,.T.)     
	oRDtCalc:bSetGet := {|u| Iif (PCount() == 0, nRDtCalc, nRDtCalc := u)}

	oRDtCalc:bChange := {||;
	Iif(nRDtCalcA <> nRDtCalc,;
	Eval({||,;
	nRDtCalcA := nRDtCalc,;
	aplGridFilt(),;
	oTFFiltro:SetOption(2),;
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),;
	}),Nil);										
	}

	oDataBase := TGet():New(050,010,{|u|If(PCount() == 0,dDataIni,dDataIni := u)},oPnlFCmp,030,010,"@D",;
	{||NaoVazio()},;
	0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataIni",,,,.T.,,,"Data Cálculo",1) 
	oDataBase:bGotFocus := {|| dDataAnt := dDataIni }
	oDataBase:bLostFocus:= {||;
	Eval(bResetFilt),;
	Iif(dDataAnt <> dDataIni .And. ! Empty(dDataIni),;
	Eval({||;
	aplGridFilt(),;
	oTFFiltro:SetOption(2),;
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),;
	}),;
	Nil);
	}

	cFilSaldo := " AND (SE1010.E1_SALDO=SE1010.E1_VALOR) "
	aVlrxSld  := {"1=Valor Título = Saldo Título","2=Valor Título <> Saldo Título","3=Valor = Saldo ou Valor <> Saldo"}
	cVlrxSld  := aVlrxSld[1]
	        		oVlrxSld  := TComboBox():New(080,010,{|u|if(PCount()>0,cVlrxSld:=u,cVlrxSld)},;
	        		aVlrxSld,100,20,oPnlFCmp,,;
	{|| Iif(cVlrxSld == "1", cFilSaldo := " AND (SE1010.E1_SALDO=SE1010.E1_VALOR) ",;
	Iif(cVlrxSld == "2", cFilSaldo := " AND (SE1010.E1_SALDO <> SE1010.E1_VALOR AND SE1010.E1_SALDO > 0) ",;
	Iif(cVlrxSld == "3", cFilSaldo := " AND ((SE1010.E1_SALDO <> SE1010.E1_VALOR AND SE1010.E1_SALDO > 0) OR (SE1010.E1_SALDO=SE1010.E1_VALOR))",""))),;
	Eval(bResetFilt),;
	aplGridFilt(),;
	oTFFiltro:SetOption(2),;
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),;
	},,,,.T.,,,,,,,,,'cVlrxSld',"Valor | Saldo",1)

	cStatCli := " AND (A1_MSBLQL = '2') "
	aCliAtv  := {"1=Cliente Ativo","2=Cliente Inativo","3=Ambos"}
	cCliAtv  := aCliAtv[1]
	        		oCliAtv  := TComboBox():New(110,010,{|u|if(PCount()>0,cCliAtv:=u,cCliAtv)},;
	        		aCliAtv,100,20,oPnlFCmp,,;
	{|| Iif(cCliAtv == "1", cStatCli := " AND (A1_MSBLQL = '2') ",;
	Iif(cCliAtv == "2", cStatCli := " AND (A1_MSBLQL = '1') ",;
	Iif(cCliAtv == "3", cStatCli := " AND (A1_MSBLQL IN ('1','2') )" ,""))),;
	Eval(bResetFilt),;
	aplGridFilt(),;
	oTFFiltro:SetOption(2),;
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo),;
	},,,,.T.,,,,,,,,,'cCliAtv',"Status Cliente",1)

	//oGrpCmp	 := TGroup():Create(oPnlFCmp,010,105,260,100,"Campos"    ,,,.T.)
	oGrpFilt := TGroup():Create(oPnlFCmp,005,130,180,520,"Tabelas",,,.T.)

	oTxtFCmp := TSay():New(015,135,{||"Selecione a tabela para aplicar filtro de campo"},oPnlFCmp,,,,,,.T.,CLR_RED,CLR_WHITE,190,10)

	aFTabelas := {"","SE1=Contas a Receber","SA1=Clientes","SZF=Rede de Lojas de Clientes"}
	cFTabelas:= aFTabelas[1]
	        		oFTabelas := TComboBox():New(025,135,{|u|if(PCount()>0,cFTabelas:=u,cFTabelas)},;
	        		aFTabelas,100,20,oPnlFCmp,,{|| Eval(bResetFilt), criarFitro(oFilExpress,aHFilExpress,cFTabelas,oFTabelas,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo), oFTabelas:Select(1), oFTabelas:Refresh() };
	        		,,,,.T.,,,,,,,,,'cFTabelas')
	 	
	aHFilExpress   := {}
	aColsFilExpress:= {}
	aAltFilExpress := {}

	Aadd(aHFilExpress,{"Tabela"   ,"TABELA" ,"" ,003, 0,"","" ,"C","",""})
	Aadd(aHFilExpress,{"Expressão","EXPRES" ,"" ,TamSX3("X5_DESCRI")[1], 0,"","" ,"C","",""})

	    // Cria browse de filtro de expressões.
	    oFilExpress := MsNewGetDados():New(040,135,170,515,,"Allwaystrue()","Allwaystrue()","",aAltFilExpress,Nil,999,Nil,Nil,Nil,oPnlFCmp,aHFilExpress,@aColsFilExpress)

	oExFilExp  := TButton():New(025,240,"Apagar",oPnlFCmp,{|| Eval(bResetFilt), apgFilExpres(oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oTFFiltro) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	lAplUser   := .F. 
	oAplUser   := TButton():New(025,465,"Aplicar a Todos",oPnlFCmp,{|| lAplUser := .T., slvFilExpress("","",oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo)},50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	//oAplUser := TCheckBox():New(025,435,'Aplicar a todos usuários',{||lAplUser},oPnlFCmp,100,210,,,,,,,,.T.,,,)

	If ! (Alltrim(cValToChar(__cUserID)) $cUsuarios)
		oAplUser:Disable()

	EndIf

	MsAguarde({||filtFixo(oFilExpress,aHFilExpress)},"Aguarde","Carregando expressões...")

	oPnlFilt1 := TPanel():New(000,000,,oTFFiltro:aDialogs[2],,.T.,,CLR_BLACK,CLR_WHITE,535,233,,)
	oGrpFCFx  := TGroup():Create(oPnlFilt1,005,005,180,075,"Faixas de Atraso",,,.T.)
	oGrpFCPort:= TGroup():Create(oPnlFilt1,005,085,180,185,"Portador",,,.T.)
	oGrpFCSitu:= TGroup():Create(oPnlFilt1,005,195,180,295,"Situação",,,.T.)
	oGRpFCRede:= TGroup():Create(oPnlFilt1,005,305,180,405,"Rede",,,.T.)

	cBuscaRede := Space(8)
	oBuscaRede := TGet():New(015,310,{|u|If(PCount() == 0,cBuscaRede,cBuscaRede := u)},oPnlFilt1,60,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBuscaRede",,,,.T.,,,"Busca:",1) 
	oBtnBscRede:= TButton():New(023,373,"Ok",oPnlFilt1,{|| Iif( Valtype(oMkRdBusca) == "O",;
	MsAguarde({|| bscRede(@oMkRdBusca,cBuscaRede) },"Aguarde","Localizando " + cBuscaRede + "..."),;
	MsgStop("Não há dados carregados.","Função cobDia"))  },018,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGRpFCTit := TGroup():Create(oPnlFilt1,005,415,180,515,"Tipo de Título",,,.T.)	

	oOkFiltro  := TButton():New(219,490,"Aplicar Filtro",oPnlFiltro,{|| filtros(oPnlFiltro,oCobranca,oSplitter,@oTitulos,@aAltTitulos,;
	@aColsTitulos,bFFiltro,bApgArqTemp,oFilExpress,aHFilExpress) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oOkFiltro:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #0000CC, stop: 1 #190033);color: white}")

	//oCaFiltro  := TButton():New(219,490,"Cancelar",oPnlFiltro,{|| Eval(bFFiltro) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oPnlFiltro:Hide()
	//

	oGroup2	 := TGroup():Create(oCobranca,239,005,260,595,"",,,.T.)

	oFechar	 := TButton():New(245,550,"Fechar",oCobranca,{||oCobranca:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oCobranca:Activate(,,,.T.,{||.T.},,{|| Eval(bIFiltro) })	
	//oCobranca:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| carrCobDia(oCobranca,oSplitter,@oTitulos,@aAltTitulos,@aColsTitulos) },"Aguarde","Carregando dados...") })


	//
	If Select("TFXATR") > 0
		TFXATR->(DbCloseArea())

	EndIf

	If Select("TPORTAD") > 0
		TPORTAD->(DbCloseArea())

	EndIf

	If Select("TSITUAC") > 0
		TSITUAC->(DbCloseArea())

	EndIf

	If Select("TREDE") > 0
		TREDE->(DbCloseArea())

	EndIf

	If Select("TTPTIT") > 0
		TTPTIT->(DbCloseArea())

	EndIf

	//
	For i := 1 To Len(aArqTemp)

		If ! Empty( Alltrim(cValToChar(aArqTemp[i])) )

			FErase( Alltrim(cValToChar(aArqTemp[i])) + GetDBExtension() )
			FErase( Alltrim(cValToChar(aArqTemp[i])) + OrdBagExt() )

		EndIf

	Next i

	//
	//Eval(bApgArqTemp)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function edtHist
	Edição do campo de histórico dos títulos a receber. 
	@type  Function
	@author Everson
	@since 01/09/2017
	@version version
/*/

Static Function edtHist(oDetalhes,aHDetalhes)

	Local aArea 		:= GetArea()
	Local oTelEdtHist
	Local oGroup1	
	Local oOk
	Local oFechar
	Local nTmCmp		:= TamSX3("E1_HIST")[1]
	Local cEditTit		:= ""
	Local oEditTit
	Local oTxtTT

	Local cTitulo	:= Alltrim(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "TITULO"  })] ))
	Local cHist		:= Alltrim(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "HIST"    })] ))
	Local cCodCli	:= Alltrim(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "CLIENTE" })] ))
	Local cLjCli	:= Alltrim(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "LOJA"    })] ))
	Local cNmCli	:= Alltrim(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "NMCLI"   })] ))
	Local cCliente	:= cCodCli + "/" + cLjCli + "-" + cNmCli
	Local nRec		:= Val(cValToChar( oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "REC" })] ))

	//
	If Empty(cTitulo) .Or. nRec == 0
		MsgStop("Não há título selecionado.","Função edtHist")
		Return Nil

	EndIf

	//
	cHist := Alltrim(cValToChar(cHist))
	cEditTit := cHist + Iif( (nTmCmp - Len(cHist)) > 0, Space(nTmCmp - Len(cHist)) , "" )

	//
	oTelEdtHist			:= MsDialog():Create()
	oTelEdtHist:cName     := "oTelEdtHist"
	oTelEdtHist:cCaption  := "Editar Histórico"
	oTelEdtHist:nLeft     := 34
	oTelEdtHist:nTop      := 222
	oTelEdtHist:nWidth    := 400
	oTelEdtHist:nHeight   := 250
	oTelEdtHist:lShowHint := .F.
	oTelEdtHist:lCentered := .T.

	oTxtTT := TSay():New(007,005,{||"Título : " + cTitulo + Chr(13) + Chr(10) + "Cliente:" + cCliente + Chr(13) + Chr(10) + "Recno  : " + cValToChar(nRec)},oTelEdtHist,,,,,,.T.,CLR_RED,CLR_WHITE,200,40)

	oEditTit  := TGet():New(040,005,{|u|If(PCount() == 0,cEditTit,cEditTit := u)},oTelEdtHist,190,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEditTit",,,,.T.,,,"Histórico:",1) 

	oGroup1  := TGroup():Create(oTelEdtHist,085,005,105,195,"",,,.T.)

	oOk		:= TButton():New(090,105,"Ok"    ,oTelEdtHist,{|| MsAguarde({|| slvHist(nRec,cEditTit,oDetalhes,aHDetalhes) },"Aguarde","Gravando histórico..."), oTelEdtHist:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar := TButton():New(090,150,"Fechar",oTelEdtHist,{|| oTelEdtHist:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTelEdtHist:Activate(,,,.T.,{||.T.},,{||  })

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function slvHist
	Salva edição do campo de histórico dos títulos a receber.
	@type  Function
	@author Everson
	@since 01/09/2017
	@version version
/*/

Static Function slvHist(nRec,cHist,oDetalhes,aHDetalhes)

	Local aArea 	:= GetArea()
	Local cHistAnt	:= ""

	DbSelectArea("SE1")
	SE1->(DbGoTop())
	SE1->(DbGoTo(nRec))

	//
	cHistAnt := Alltrim(cValToChar(SE1->E1_HIST))
	cHist	 := Alltrim(cValToChar(cHist))

	//
	BeginTran()

	RecLock("SE1",.F.)
	Replace SE1->E1_HIST With cHist
	MsUnlock()

	//Log.
	RecLock("ZBE",.T.)
	ZBE->ZBE_FILIAL := xFilial("SE1")
	ZBE->ZBE_DATA	:= Date()
	ZBE->ZBE_HORA	:= cValToChar(Time())
	ZBE->ZBE_USUARI	:= cUserName
	ZBE->ZBE_LOG	:= "ALT HIST SE1: ANT: " + cHistAnt + " POST: " + cHist
	ZBE->ZBE_MODULO	:= "FINANCEIRO"
	ZBE->ZBE_ROTINA	:= "ADFIN030P"
	MsUnlock()

	oDetalhes:aCols[oDetalhes:nAt,Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "HIST"    })] := cHist
	oDetalhes:Refresh()

	EndTran()

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function bscRede
	Busca rede na MsSelect.
	@type  Function
	@author Everson
	@since 27/06/2017
	@version version
/*/

Static Function bscRede(oMkRdBusca,cCodigo)

	Local aArea := GetArea()
	Local i		:= 1
	Local nAux	:= 1
	Local nPos	:= 1
	Local nPosAt:= oMkRdBusca:oBrowse:nAt

	//
	cCodigo := Alltrim(cValToChar(cCodigo))

	//
	If Empty(cCodigo)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If Select("TREDE") <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	//
	DbSelectArea("TREDE")
	TREDE->(DbGoTop())

	//
	While ! TREDE->(Eof())

		If cCodigo $(Alltrim(cValToChar(TREDE->TMP_RED)))
			nPos := nAux
			Exit

		EndIf

		TREDE->(DbSkip())

		nAux++

	EndDo

	//
	If nPos <= 0
		MsgStop("Registro não encontrado","Função bscRede")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	nPosAt := nPosAt - nPos

	//
	If (nPosAt) <> 0

		If nPosAt > 0

			For i := 1 To nPosAt
				oMkRdBusca:oBrowse:GoDown()

			Next i

		Else

			For i := 1 To nPosAt
				oMkRdBusca:oBrowse:GoUp()

			Next i

		EndIf

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function exibTotFaixa
	Gera aquivo CSV.  
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function exibTotFaixa(oTitulos,aHTitulos)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aAreaFx
	Local oTotFx
	Local aHToFx	:= {}
	Local aAltTotFx	:= {}
	Local aColsTotFx:= {}
	Local oGdToFx
	Local oFechar
	Local i			:= 1
	Local w			:= 1
	Local nTotFx	:= 0
	Local cNmFaixa	:= ""
	Local nTotTT	:= 0
	Local oTxtTT
	Local nFaixaDe	:= 0
	Local nFaixaAte	:= 0

	//
	If ValType(oTitulos) <> "O" .Or. Len(aHTitulos) <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	aAreaFx := GetArea("TFXATR")

	Aadd(aHToFx,{"Faixa","FAIXA","" ,010, 0,"","" ,"C","",""})
	Aadd(aHToFx,{"De - Dias Atraso" ,"DEFX","@E 99999" ,05, 0,"","" ,"N","",""})
	Aadd(aHToFx,{"Até - Dias Atraso","ATFX","@E 99999" ,05, 0,"","" ,"N","",""})
	Aadd(aHToFx,{"Valor","VALOR","@E 999,999,999.99" ,15, 2,"","" ,"N","",""})

	oTotFx			:= MsDialog():Create()
	oTotFx:cName     := "oTotFx"
	oTotFx:cCaption  := "Total por Faixa"
	oTotFx:nLeft     := 34
	oTotFx:nTop      := 222
	oTotFx:nWidth    := 550
	oTotFx:nHeight   := 320
	oTotFx:lShowHint := .F.
	oTotFx:lCentered := .T.

	oGdToFx  := MsNewGetDados():New(010,005,135,270,,"Allwaystrue()","Allwaystrue()","",aAltTotFx,Nil,999,Nil,Nil,Nil,oTotFx,aHToFx,@aColsTotFx)
	oGdToFx:aCols := {}

	If (Len(oTitulos:aCols) - 1) > 0

		For i := 1 To Len(aHTitulos)

			cNmFaixa := Alltrim(cValToChar(aHTitulos[i][1]))

			If Substr(cNmFaixa,1,5) == "Faixa"

				nTotFx := 0
				For w := 1 To (Len(oTitulos:aCols) - 1)

					nTotFx += Val(cValToChar(oTitulos:aCols[w][i]))

				Next w

				nFaixaDe := 0
				nFaixaAte:= 0

				cQuery := ""
				cQuery += " SELECT *  " 
				cQuery += " FROM  " 
				cQuery += " " + RetSqlName("SX5") + " (NOLOCK) AS SX5 " 
				cQuery += " WHERE  " 
				cQuery += " X5_TABELA = 'WX'  " 
				cQuery += " AND D_E_L_E_T_ = '' " 
				cQuery += " AND X5_CHAVE = '" + Alltrim(cValToChar(Substr(cNmFaixa,6,Len(cNmFaixa)))) + "' " 

				If Select("FX_SX5") > 0
					FX_SX5->(DbCloseArea())

				EndIf

				TcQuery cQuery New Alias "FX_SX5"
				DbSelectArea("FX_SX5")
				nFaixaDe := Val(cValToChar(FX_SX5->X5_DESCRI))
				nFaixaAte:= Val(cValToChar(FX_SX5->X5_DESCSPA))
				DbCloseArea("FX_SX5")

				Aadd(oGdToFx:aCols , Array(Len(aHToFx) + 1) )
				oGdToFx:aCols[Len(oGdToFx:aCols), Len(oGdToFx:aCols[1]) ] := .F.

				oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "FAIXA"})] := cNmFaixa
				oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "DEFX" })] := nFaixaDe
				oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "ATFX" })] := nFaixaAte
				oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "VALOR"})] := nTotFx

				nTotTT += nTotFx

			EndIf


		Next i

	EndIf

	//
	If Len(oGdToFx:aCols) <= 0

		Aadd(oGdToFx:aCols , Array(Len(aHToFx) + 1) )
		oGdToFx:aCols[Len(oGdToFx:aCols), Len(oGdToFx:aCols[1]) ] := .F.

		oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "FAIXA" })] := ""
		oGdToFx:aCols[Len(oGdToFx:aCols),Ascan(aHToFx,{|x| AllTrim(x[2]) == "VALOR" })] := 0

	EndIf

	oGdToFx:Refresh()

	oTxtTT := TSay():New(002,005,{||"Total" + Transform(nTotTT,"@E 999,999,999.99")},oTotFx,,,,,,.T.,CLR_RED,CLR_WHITE,250,20)

	oTotFx:Activate(,,,.T.,{||.T.},,{||  })

	RestArea(aArea)
	RestArea(aAreaFx)

Return Nil

/*/{Protheus.doc} Static Function grCSVS
	Gera aquivo CSV.  
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function grCSVS(oTitulos,aHTitulos)

	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local cArq  	:= "S_COBDIARIA"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSVS")
		Return Nil

	EndIf

	//
	cLin := ""
	For i := 1 To Len(aHTitulos)
		cLin += cValToChar(aHTitulos[i][1]) + ";"

	Next i

	cLin += cEof

	For i := 1 To Len(oTitulos:aCols)

		For w := 1 To Len(aHTitulos)

			If Alltrim(cValToChar(aHTitulos[w][8])) == "N"

				cLin += Transform(Val(cValToChar(oTitulos:aCols[i][w])),"@E 999,999,999.99") + ";"

			Else
				cLin += cValToChar(oTitulos:aCols[i][w]) + ";"

			EndIf

		Next w

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função grCSVS")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function grCSVA
	Relatório detalhado. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function grCSVA(oTitulos,aHTitulos)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cLin		:= ""
	Local cPortador	:= ""
	Local nDesconto	:= 0
	Local cArq  	:= "A_COBDIARIA"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cDir		:= ""
	Local cVend		:= ""
	Local cEmail	:= ""

	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSVA")
		Return Nil

	EndIf

	//
	cQuery := sqlCobDia(8)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If Select("CSV_DET") > 0
		CSV_DET->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "CSV_DET"
	DbSelectArea("CSV_DET")

	cLin := ""
	cLin := "E1_FILIAL;E1_CLIENTE;E1_LOJA;A1_NOME;REDE;CGC_R;A1_DDD;A1_TEL;TECLAN;E1_NUM;E1_PARCELA;E1_TIPO;E1_PORTADO;A6_NOME;E1_SITUACA;E1_HIST;E1_VALOR;"
	cLin += "E1_SALDO;%;A1_ZZDESCB;E1_EMISSAO;E1_VENCREA;E1_BAIXA;A1_VEND;A3_NOME;A3_EMAIL;ATRASO;FAIXA;A1_EMAIL;A1_EMAICO;E1_NUMBCO" + cEof //19/02/2019 - William - chamado 047186 //Everson - 13/05/2019. Chamado 049082.
	FWrite(nHdl,cLin,Len(cLin))
	cLin := ""
	While ! CSV_DET->(Eof())

		cPortador 	:= Posicione("SA6",1,xFilial("SA6") + CSV_DET->E1_PORTADO, "A6_NOME") //CHAMADO; 041135 - FERNANDO SIGOIL 20/04/2018
		nDesconto 	:= cValToChar(Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(CSV_DET->E1_CLIENTE)) + Alltrim(cValToChar(CSV_DET->E1_LOJA)) , "A1_ZZDESCB"))
		cVend		:= Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar(CSV_DET->A1_VEND)),"A3_NOME")
		cEmail		:= Posicione("SA3",1,xFilial("SA3") + Alltrim(cValToChar(CSV_DET->A1_VEND)),"A3_EMAIL")
		
		cLin += StrTran(CSV_DET->E1_FILIAL,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_CLIENTE,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_LOJA,";"," ") + ";"
		cLin += StrTran(CSV_DET->A1_NOME,";"," ") + ";"
		cLin += StrTran(CSV_DET->REDE,";"," ") + ";"
		cLin += StrTran(CSV_DET->CGC_R,";"," ") + ";"
		cLin += StrTran(CSV_DET->A1_DDD,";"," ") + ";"
		cLin += StrTran(CSV_DET->A1_TEL,";"," ") + ";"
		cLin += StrTran(CSV_DET->A1_TEL2,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_NUM,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_PARCELA,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_TIPO,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_PORTADO,";"," ") + ";"
		cLin += StrTran(cPortador,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_SITUACA,";"," ") + ";"
		cLin += StrTran(CSV_DET->E1_HIST,";"," ") + ";"
		cLin += Transform(Val(cValToChar(CSV_DET->E1_VALOR)),"@E 999,999,999.99") + ";"
		cLin += Transform(Val(cValToChar(CSV_DET->E1_SALDO)),"@E 999,999,999.99") + ";"
		cLin += Transform((Val(cValToChar(CSV_DET->E1_SALDO)) / Val(cValToChar(CSV_DET->E1_VALOR)))*100,"@E 999,999,999.99") + ";"
		cLin += Transform(Val(cValToChar(nDesconto)),"@E 999,999,999.99") + ";"
		cLin += DToC(SToD(cValToChar(CSV_DET->E1_EMISSAO))) + ";"
		cLin += DToC(SToD(cValToChar(CSV_DET->E1_VENCREA))) + ";"
		cLin += DToC(SToD(cValToChar(CSV_DET->E1_BAIXA))) + ";"

		cLin += StrTran(CSV_DET->A1_VEND,";"," ") + ";" //Everson - 13/05/2019. Chamado 049082.
		cLin += StrTran(cVend,";"," ") + ";"
		cLin += StrTran(cEmail,";"," ") + ";" //Everson - 13/05/2019. Chamado 049082.

		cLin += Transform(Val(cValToChar(CSV_DET->ATRASO)),"@E 999,999,999,999")  + ";"
		cLin += StrTran(CSV_DET->FAIXA,";"," ") + ";" 
		cLin += StrTran(CSV_DET->A1_EMAIL,";"," ") + ";"         //19/02/2019 - William - chamado 047186
		cLin += StrTran(CSV_DET->A1_EMAICO,";"," ") + ";"        //19/02/2019 - William - chamado 047186
		cLin += StrTran(CSV_DET->E1_NUMBCO,";"," ") + ";" + cEof //19/02/2019 - William - chamado 047186

		CSV_DET->(DbSkip())

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	EndDo

	DbCloseArea("CSV_DET")

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função grCSVA")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function grCSVDet
	Gera arquivo CSV da interface de detalhes. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function grCSVDet(oDetalhes,aHDetalhes)

	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local cArq  	:= "D_COBDIARIA"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

	If ValType(oDetalhes) <> "O" .Or. Len(aHDetalhes) <= 0
		RestArea(aArea)
		Return Nil

	EndIf

	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSVS")
		Return Nil

	EndIf

	cLin := ""
	For i := 1 To Len(aHDetalhes)
		cLin += cValToChar(aHDetalhes[i][1]) + ";"

	Next i

	cLin += cEof

	For i := 1 To Len(oDetalhes:aCols)

		For w := 1 To Len(aHDetalhes)

			If Alltrim(cValToChar(aHDetalhes[w][8])) == "N"

				cLin += Transform(Val(cValToChar(oDetalhes:aCols[i][w])),"@E 999,999,999.99") + ";"

			Else
				cLin += cValToChar(oDetalhes:aCols[i][w]) + ";"

			EndIf

		Next w

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função grCSVDet")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtros
	Aplica filtros. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtros(oPnlFiltro,oCobranca,oSplitter,oTitulos,aAltTitulos,aColsTitulos,bFFiltro,bApgArqTemp,oFilExpress,aHFilExpress)

	Local aArea		:= GetArea()
	Local lRtCarrDb := .F.

	lHistFilt1  := .T.

	//Filtro de Faixa.
	cFiltFaixas := "''"
	If Select("TFXATR") > 0
		cFiltFaixas := ""
		aHistFxAtr  := {}
		DbSelectArea("TFXATR")
		TFXATR->(DbGoTop())

		If TFXATR->(Eof())
			cFiltFaixas := "''"

		Else

			While ! TFXATR->(Eof())

				If ! Empty(TFXATR->OK) .And. ! Empty(Alltrim(cValToChar(TFXATR->TMP_FAIXA)))
					cFiltFaixas += "'" + Alltrim(cValToChar(TFXATR->TMP_FAIXA)) + "',"
					Aadd(aHistFxAtr,{Alltrim(cValToChar(TFXATR->TMP_FAIXA))})
				EndIf

				TFXATR->(DbSkip())
			EndDo
			cFiltFaixas := Substr(cFiltFaixas,1,Len(cFiltFaixas) - 1)
			If Empty(cFiltFaixas)
				cFiltFaixas := "''"

			EndIf

		EndIf

		//DbCloseArea("TFXATR")

	EndIf
	//

	//Filtro de Portador.
	cFiltPortad := "''"
	If Select("TPORTAD") > 0
		cFiltPortad := ""
		aHistPortad := {}
		DbSelectArea("TPORTAD")
		TPORTAD->(DbGoTop())

		If TPORTAD->(Eof())
			cFiltPortad := "''"

		Else

			While ! TPORTAD->(Eof())

				If ! Empty(TPORTAD->OK) 
					cFiltPortad += "'" + Alltrim(cValToChar(TPORTAD->TMP_PORT)) + "',"
					Aadd(aHistPortad,{Alltrim(cValToChar(TPORTAD->TMP_PORT))})

				EndIf

				TPORTAD->(DbSkip())
			EndDo
			cFiltPortad := Substr(cFiltPortad,1,Len(cFiltPortad) - 1)
			If Empty(cFiltPortad)
				cFiltPortad := "''"

			EndIf

		EndIf

		//DbCloseArea("TPORTAD")	

	EndIf
	//

	//Filtro de situação.
	cFiltSituad := "''"
	If Select("TSITUAC") > 0
		cFiltSituad := ""
		aHistSituac := {}
		DbSelectArea("TSITUAC")
		TSITUAC->(DbGoTop())

		If TSITUAC->(Eof())
			cFiltSituad := "''"

		Else

			While ! TSITUAC->(Eof())

				If ! Empty(TSITUAC->OK) .And. ! Empty(Alltrim(cValToChar(TSITUAC->TMP_SITU)))
					cFiltSituad += "'" + Alltrim(cValToChar(TSITUAC->TMP_SITU)) + "',"
					Aadd(aHistSituac,{Alltrim(cValToChar(TSITUAC->TMP_SITU))})

				EndIf

				TSITUAC->(DbSkip())
			EndDo
			cFiltSituad := Substr(cFiltSituad,1,Len(cFiltSituad) - 1)
			If Empty(cFiltSituad)
				cFiltSituad := "''"

			EndIf

		EndIf

		//DbCloseArea("TSITUAC")	

	EndIf
	//	

	//Filtro de rede.
	If Select("TREDE") > 0
		cFiltRede := ""
		cFiltRedeR:= ""
		aHistRede := {}
		DbSelectArea("TREDE")
		TREDE->(DbGoTop())

		If TREDE->(Eof())
			cFiltRede := "''"
			cFiltRedeR:= "''"

		Else

			While ! TREDE->(Eof())

				If Empty(Alltrim(cValToChar(TREDE->OK))) .And. ! Empty(Alltrim(cValToChar(TREDE->TMP_RED)))
					cFiltRede += "'" + Alltrim(cValToChar(TREDE->TMP_RED)) + "',"

				ElseIf ! Empty(Alltrim(cValToChar(TREDE->OK))) .And. ! Empty(Alltrim(cValToChar(TREDE->TMP_RED)))

					cFiltRedeR += "'" + Alltrim(cValToChar(TREDE->TMP_RED)) + "',"

					Aadd(aHistRede,{Alltrim(cValToChar(TREDE->TMP_RED))})

				EndIf

				TREDE->(DbSkip())
			EndDo
			cFiltRede := Substr(cFiltRede,1,Len(cFiltRede) - 1)
			cFiltRedeR:= Substr(cFiltRedeR,1,Len(cFiltRedeR) - 1)

			If Empty(cFiltRede)
				cFiltRede := "''"

			EndIf

			If Empty(cFiltRedeR)
				cFiltRedeR:= "''"

			EndIf

		EndIf

		//DbCloseArea("TREDE")

	EndIf
	//

	//Filtro de tipo de título.
	cFiltTpTit := "''"
	If Select("TTPTIT") > 0
		cFiltTpTit := ""
		aHisTTPTIT := {}
		DbSelectArea("TTPTIT")
		TTPTIT->(DbGoTop())

		If TTPTIT->(Eof())
			cFiltTpTit := "''"

		Else

			While ! TTPTIT->(Eof())

				If ! Empty(TTPTIT->OK) .And. ! Empty(Alltrim(cValToChar(TTPTIT->TMP_TPT)))
					cFiltTpTit += "'" + Alltrim(cValToChar(TTPTIT->TMP_TPT)) + "',"
					Aadd(aHisTTPTIT,{Alltrim(cValToChar(TTPTIT->TMP_TPT))})

				EndIf

				TTPTIT->(DbSkip())
			EndDo
			cFiltTpTit := Substr(cFiltTpTit,1,Len(cFiltTpTit) - 1)
			If Empty(cFiltTpTit)
				cFiltTpTit := "''"

			EndIf

		EndIf

		//DbCloseArea("TTPTIT")	

	EndIf
	//

	//Aplica filtro de expressão.
	aplGridFilt()

	//Carrega títulos.
	MsAguarde({|| lRtCarrDb := carrCobDia(oCobranca,oSplitter,@oTitulos,@aAltTitulos,@aColsTitulos) },"Aguarde","Carregando dados...")

	//
	If lRtCarrDb
		//Eval(bApgArqTemp)
		Eval(bFFiltro)

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function aplGridFilt
	Aplica filtros.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function aplGridFilt()

	Local aArea		:= GetArea()	
	Local i			:= 1
	Local cTabFilt	:= ""
	Local cExpreFilt:= ""

	If Empty(dDataIni)
		RestArea(aArea)
		Return Nil

	EndIf


	//Aplica filtro de expressão.
	cFilSE1 := ""
	cFilSA1 := ""
	cFilSA3 := ""
	cFilSZF := ""
	For i := 1 To Len(oFilExpress:aCols)

		cTabFilt   := Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]))
		cExpreFilt := Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })]))

		If ! Empty(cExpreFilt)

			If cTabFilt == "SE1"

				cFilSE1 += " AND " + Iif(At("OR",Upper(cExpreFilt)) > 0 .Or. At("AND",Upper(cExpreFilt)) > 0, " ( " + cExpreFilt + " ) ",cExpreFilt)

			ElseIf cTabFilt == "SA1"

				cFilSA1 += " AND " + Iif(At("OR",Upper(cExpreFilt)) > 0 .Or. At("AND",Upper(cExpreFilt)) > 0, " ( " + cExpreFilt + " ) ",cExpreFilt)

			ElseIf cTabFilt == "SA3"

				cFilSA3 += " AND " + Iif(At("OR",Upper(cExpreFilt)) > 0 .Or. At("AND",Upper(cExpreFilt)) > 0, " ( " + cExpreFilt + " ) ",cExpreFilt)

			ElseIf cTabFilt == "SZF"

				cFilSZF += " AND " + Iif(At("OR",Upper(cExpreFilt)) > 0 .Or. At("AND",Upper(cExpreFilt)) > 0, " ( " + cExpreFilt + " ) ",cExpreFilt)

			EndIf

		EndIf

	Next i

	//

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function apgFilExpres
	Apaga expressão sql.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function apgFilExpres(oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oTFFiltro)

	Local aArea		:= GetArea()
	Local cExpres	:= Alltrim(cValToChar(oFilExpress:aCols[oFilExpress:nAt][aScan(aHFilExpress,{|x| Alltrim(cValToChar(x[2])) == "EXPRES"})]))

	If Empty(cExpres)
		RestArea(aArea)
		Return Nil

	EndIf

	If ! MsgYesNo("Deseja excluir a expressão abaixo?" + Chr(13) + Chr(10) + cExpres,"Função apgFilExpres")
		RestArea(aArea)
		Return Nil

	EndIf

	//oFilExpress:DelLine()
	oFilExpress:aCols[oFilExpress:nAt,Len(aHFilExpress)+1] := .T.

	oFilExpress:Refresh()

	MsAguarde({|| slvFilExpress("","",oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede) },"Aguarde","Excluindo expressão...")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function criarFitro
	Cria expressão sql.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function criarFitro(oFilExpress,aHFilExpress,cArquivo,oFTabelas,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo)

	Local aArea		 := GetArea()
	Local cFiltroRet := ""
	Local cTabela	 := ""
	Local nLimitExp	 := TamSX3("X5_DESCRI")[1]

	//
	cArquivo := Alltrim(cValToChar(cArquivo))

	If Empty(cArquivo)
		RestArea(aArea)
		Return Nil

	EndIf

	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	If SX2->(DbSeek(cArquivo))   
		cTabela := X2Nome()

	EndIf
	     
	cFiltroRet := BuildExpr(cArquivo,,cFiltroRet,.T.,,,,cArquivo + " | " + cTabela)
	cFiltroRet := Alltrim(cValToChar(cFiltroRet))

	If ! Empty(cFiltroRet)

		/*		If ! MsgYesNo("Deseja salvar a expressão abaixo?" + Chr(13) + Chr(10) + cFiltroRet,"Função criarFitro")
		RestArea(aArea)
		Return Nil

		EndIf*/

		If Len(cFiltroRet) > nLimitExp
			MsgStop("O tamanho da expressão excede " + cValToChar(nLimitExp) + " caracteres. A expressão não poderá ser salva.","Função criarFitro")
			RestArea(aArea)
			Return Nil

		EndIf

		If Substr(cFiltroRet,1,3) == "AND"
			MsgStop("A expressão não pode iniciar com 'AND'. A expressão não poderá ser salva.","Função criarFitro")
			RestArea(aArea)
			Return Nil

		EndIf

		MsAguarde({|| slvFilExpress(cArquivo,cFiltroRet,oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo) },"Aguarde","Salvando expressão...")

	EndIf

	oFTabelas:Select(1)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function slvFilExpress
	Salva expressão sql.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function slvFilExpress(cArquivo,cFiltroRet,oFilExpress,aHFilExpress,oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo)

	Local aArea 	:= GetArea()
	Local aDados	:= {}
	Local i			:= 1
	Local cUpdate	:= "UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = '*' WHERE X5_TABELA = 'WY' AND D_E_L_E_T_ = '' "	
	Local cChVWY  := ""

	//
	If ValType(oTFFiltro) == "O"
		oTFFiltro:SetOption(2)

	EndIf

	//
	cArquivo 	:= Alltrim(cValToChar(cArquivo))
	cFiltroRet	:= Alltrim(cValToChar(cFiltroRet))

	//Atualiza grid.
	For i := 1 To Len(oFilExpress:aCols)

		If ! Empty(Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]))) .And. !  (oFilExpress:aCols[i,Len(aHFilExpress)+1]) 

			Aadd(aDados,{oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })],;
			oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })]})

		EndIf

	Next i

	oFilExpress:aCols := {}

	For i := 1 To Len(aDados)

		Aadd(oFilExpress:aCols , Array(Len(aHFilExpress) + 1) )
		oFilExpress:aCols[Len(oFilExpress:aCols), Len(oFilExpress:aCols[1]) ] := .F.

		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })] := Alltrim(cValToChar(aDados[i][1]))
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })] := Alltrim(cValToChar(aDados[i][2]))

	Next i

	If ! Empty(cArquivo)

		Aadd(oFilExpress:aCols , Array(Len(aHFilExpress) + 1) )
		oFilExpress:aCols[Len(oFilExpress:aCols), Len(oFilExpress:aCols[1]) ] := .F.

		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })] := cArquivo
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })] := cFiltroRet

	EndIf

	If Len(oFilExpress:aCols) == 0

		Aadd(oFilExpress:aCols , Array(Len(aHFilExpress) + 1) )
		oFilExpress:aCols[Len(oFilExpress:aCols), Len(oFilExpress:aCols[1]) ] := .F.
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })] := cArquivo
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })] := cFiltroRet

	EndIf

	oFilExpress:Refresh()
	//

	If lAplUser

		//
		If TCSqlExec(cUpdate) < 0
			MsgStop("Ocorreu um erro na atualização dos parâmetros de consulta " + Chr(13) + Chr(10) + TCSQLError(),"Função slvFilExpress")
			RestArea(aArea)
			Return Nil

		EndIf

		For i := 1 To Len(oFilExpress:aCols)

			If ! Empty(Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]))) .And. !  (oFilExpress:aCols[i,Len(aHFilExpress)+1]) 

				//Obtém chave.
				cChVWY  := cChaveWY()

				RecLock("SX5",.T.)
				SX5->X5_TABELA	:= "WY"
				SX5->X5_CHAVE  	:= cChVWY
				SX5->X5_DESCRI	:= Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]))
				SX5->X5_DESCSPA	:= Alltrim(cValToChar(oFilExpress:aCols[i,Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })]))
				MsUnLock()

			EndIf

			lAplUser := .F.

		Next i

		//
		filtFixo(oFilExpress,aHFilExpress)

	EndIf

	//Aplica filtro de expressão.
	aplGridFilt()

	//
	filtro1(@oPnlFilt1,@oMkFxAtr,@oMkFxPort,@oMkSitu,@oMkRede,@oMkTitulo)

	//
	If ValType(oTFFiltro) == "O"
		//oTFFiltro:SetOption(1)

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function cChaveWY
	Obtém chave da tabela WY. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function cChaveWY()

	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cChave	:= "1"

	cQuery := ""
	cQuery += " SELECT MAX(X5_CHAVE) AS  X5_CHAVE " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " X5_TABELA = 'WY' "

	If Select("CHV_WY") > 0
		CHV_WY->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "CHV_WY"
	DbSelectArea("CHV_WY")

	If ! CHV_WY->(Eof())

		cChave := cValToChar(Val(CHV_WY->X5_CHAVE)+1)

	EndIf

	DbCloseArea("CHV_WY")

Return cChave

/*/{Protheus.doc} Static Function filtro1
	Lê os arquivos temporários para criação de filtros.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtro1(oPnlFilt1,oMkFxAtr,oMkFxPort,oMkSitu,oMkRede,oMkTitulo)

	Local aArea		:= GetArea()

	If Empty(dDataIni)
		RestArea(aArea)
		Return Nil

	EndIf

	MsAguarde({||filtFaixa(@oPnlFilt1,@oMkFxAtr)},"Aguarde","Carregando filtro de faixa de atraso...")

	MsAguarde({||filtPortad(@oPnlFilt1,@oMkFxPort)},"Aguarde","Carregando filtro de portador...")

	MsAguarde({||filtSitu(@oPnlFilt1,@oMkSitu)},"Aguarde","Carregando filtro de situação...")

	MsAguarde({||filtRede(@oPnlFilt1,@oMkRede)},"Aguarde","Carregando filtro de rede...")

	MsAguarde({||filtTitulo(@oPnlFilt1,@oMkTitulo)},"Aguarde","Carregando filtro de tipo de título...")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtFaixa
	Filtro por faixa de atraso. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtFaixa(oPnlFilt1,oMkFxAtr)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aFaixas	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark     := GetMark() 
	Local aStru
	Local nPosFxAtr

	//Valida o objeto.
	If Valtype(oMkFxAtr) == "O"
		FreeObj(oMkFxAtr:oBrowse)
		FreeObj(oMkFxAtr)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCobDia(2)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTFAIXA") > 0
		D_FILTFAIXA->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTFAIXA"
	DbSelectArea("D_FILTFAIXA")
	D_FILTFAIXA->(DbGoTop())

	/*	If D_FILTFAIXA->(Eof())
	DbCloseArea("D_FILTFAIXA")
	RestArea(aArea)
	Return Nil

	EndIf*/

	While ! D_FILTFAIXA->(Eof())

		Aadd(aFaixas,Val(cValToChar(D_FILTFAIXA->FAIXA)))

		D_FILTFAIXA->(DbSkip())

	EndDo

	DbCloseArea("D_FILTFAIXA")

	Asort(aFaixas)

	aStru := {}
	Aadd(aStru,{"OK" 		 ,"C",02,0})
	Aadd(aStru,{"TMP_FAIXA"  ,"C",10,0})

	//Iif(! Empty(Alltrim(cValToChar(cArFxAtr)))  .And. File(cArFxAtr  + GetDBExtension()),FErase(cArFxAtr  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArFxAtr := "T_ADFIN030P_CC_" + Criatrab(,.F.)
	Aadd(aArqTemp,cArFxAtr)
	MsCreate(cArFxAtr,aStru,"DBFCDX")

	If Select("TFXATR") > 0
		TFXATR->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArFxAtr,"TFXATR",.T.,.F.)

	For i := 1 To Len(aFaixas)

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			//Recarrega filtro de faixa de atraso conforme já aplicado.
			nPosFxAtr := 0
			nPosFxAtr := Ascan(aHistFxAtr,{|x| Val(Alltrim(cValToChar(x[1]))) == Val(Alltrim(cValToChar(aFaixas[i]))) })

			RecLock("TFXATR",.T.)		
			TFXATR->OK				:= Iif(nPosFxAtr == 0,"",cMark)
			TFXATR->TMP_FAIXA		:= cValToChar(aFaixas[i])
			MsunLock()

		Else
			RecLock("TFXATR",.T.)		
			TFXATR->OK				:= cMark
			TFXATR->TMP_FAIXA		:= cValToChar(aFaixas[i])
			MsunLock()

		EndIf



	Next i

	//
	If Len(aFaixas) == 0

		RecLock("TFXATR",.T.)		
		TFXATR->OK				:= ""
		TFXATR->TMP_FAIXA		:= ""
		MsunLock()

	EndIf

	Aadd(aCpoBro,{"OK"		 ,, ""})		
	Aadd(aCpoBro,{"TMP_FAIXA",,"Faixa"})		

	oMkFxAtr := MsSelect():New("TFXATR","OK","",aCpoBro ,.F.,@cMark ,{017,010,170,070},,,oPnlFilt1,,)
	oMkFxAtr:bMark := {| | DispFxAtr(oMkFxAtr,cMark) }
	oMkFxAtr:oBrowse:bAllMark := {|| FxAtrInvert(oMkFxAtr,cMark) }
	Eval(oMkFxAtr:oBrowse:bGoTop)
	oMkFxAtr:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function FxAtrInvert
	Inverter marcação do filtro por faixa de atraso. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function FxAtrInvert(oMkFxAtr,cMark) 

	Local aArea		:= GetArea()

	    DbSelectArea( "TFXATR" ) 
	    TFXATR->(DbGotop())

	If TFXATR->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	     While ! TFXATR->(EoF())

	If Marked("OK")	
		RecLock("TFXATR",.F.)
		TFXATR->OK := ""
		MsUnlock()

	Else
		RecLock("TFXATR",.F.)
		TFXATR->OK := cMark
		MsUnlock()

	Endif

	     	TFXATR->(DbSkip())

	     EndDo 

	Eval(oMkFxAtr:oBrowse:bGoTop)
	oMkFxAtr:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispFxAtr
	Função para marcação de filtro de faixa por atraso. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispFxAtr(oMkFxAtr,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TFXATR")

	If TFXATR->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	RecLock("TFXATR",.F.)

	If Marked("OK")	
		TFXATR->OK := cMark
	Else	
		TFXATR->OK := ""
	Endif             

	MsUnlock()

	oMkFxAtr:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtPortad
	Filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtPortad(oPnlFilt1,oMkFxPort)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aPortadores	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local aStru
	Local nPosPortad
	Local nNomePort	:= ""

	//Valida o objeto.
	If Valtype(oMkFxPort) == "O"
		FreeObj(oMkFxPort:oBrowse)
		FreeObj(oMkFxPort)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCobDia(3)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTPORTA") > 0
		D_FILTPORTA->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTPORTA"
	DbSelectArea("D_FILTPORTA")
	D_FILTPORTA->(DbGoTop())

	/*	If D_FILTPORTA->(Eof())
	DbCloseArea("D_FILTPORTA")
	RestArea(aArea)
	Return Nil

	EndIf*/

	While ! D_FILTPORTA->(Eof())

		Aadd(aPortadores,cValToChar(D_FILTPORTA->E1_PORTADO))

		D_FILTPORTA->(DbSkip())

	EndDo

	DbCloseArea("D_FILTPORTA")

	Asort(aPortadores)

	aStru := {}
	Aadd(aStru,{"OK" 	   ,"C",02,0})
	Aadd(aStru,{"TMP_PORT" ,"C",05,0})
	Aadd(aStru,{"TMP_NMPT" ,"C",40,0})

	//Iif(! Empty(Alltrim(cValToChar(cArPortad))) .And. File(cArPortad + GetDBExtension()),FErase(cArPortad  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArPortad := "T_ADFIN030P_CC_" + Criatrab(,.F.)
	Aadd(aArqTemp,cArPortad)
	MsCreate(cArPortad,aStru,"DBFCDX")

	If Select("TPORTAD") > 0
		TPORTAD->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArPortad,"TPORTAD",.T.,.F.)

	For i := 1 To Len(aPortadores)

		nNomePort := Posicione("SA6",1,xFilial("SA6") + aPortadores[i], "A6_NOME") //CHAMADO; 041135 - FERNANDO SIGOIL 20/04/2018

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			//Recarrega filtro de faixa de atraso conforme já aplicado.
			nPosPortad := 0
			nPosPortad := Ascan(aHistPortad,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aPortadores[i])) })

			RecLock("TPORTAD",.T.)		
			TPORTAD->OK			:= Iif(nPosPortad == 0,"",cMark)
			TPORTAD->TMP_PORT	:= cValToChar(aPortadores[i])
			TPORTAD->TMP_NMPT	:= nNomePort
			MsunLock()

		Else
			RecLock("TPORTAD",.T.)		
			TPORTAD->OK				:= cMark
			TPORTAD->TMP_PORT	:= cValToChar(aPortadores[i])
			TPORTAD->TMP_NMPT	:= nNomePort
			MsunLock()

		EndIf



	Next i

	//
	If Len(aPortadores) == 0

		RecLock("TPORTAD",.T.)		
		TPORTAD->OK			:= ""
		TPORTAD->TMP_PORT	:= ""
		TPORTAD->TMP_NMPT	:= ""
		MsunLock()	

	EndIf

	Aadd(aCpoBro,{"OK"		 ,, ""})		
	Aadd(aCpoBro,{"TMP_PORT",,"Portador"})
	Aadd(aCpoBro,{"TMP_NMPT",,"Nome"})		

	oMkFxPort := MsSelect():New("TPORTAD","OK","",aCpoBro ,.F.,@cMark ,{017,090,170,180},,,oPnlFilt1,,)
	oMkFxPort:bMark := {| | DispPortad(oMkFxPort,cMark)}
	oMkFxPort:oBrowse:bAllMark := {|| PortadInvert(oMkFxPort,cMark) }
	Eval(oMkFxPort:oBrowse:bGoTop)
	oMkFxPort:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function PortadInvert
	Função para inverter filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function PortadInvert(oMkFxPort,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TPORTAD" ) 
	     TPORTAD->(DbGotop())

	If TPORTAD->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	     While ! TPORTAD->(EoF())

	If Marked("OK")	
		RecLock("TPORTAD",.F.)
		TPORTAD->OK := ""
		MsUnlock()

	Else
		RecLock("TPORTAD",.F.)
		TPORTAD->OK := cMark
		MsUnlock()

	Endif

	     	TPORTAD->(DbSkip())

	     EndDo 

	Eval(oMkFxPort:oBrowse:bGoTop)
	oMkFxPort:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispPortad
	Função de marcação   filtro por portador.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispPortad(oMkFxPort,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TPORTAD")

	If TPORTAD->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	RecLock("TPORTAD",.F.)

	If Marked("OK")	
		TPORTAD->OK := cMark
	Else	
		TPORTAD->OK := ""
	Endif             

	MsUnlock()

	oMkFxPort:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtSitu
	Função de filtro por situação do título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtSitu(oPnlFilt1,oMkSitu)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aSituacoes	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local aStru
	Local nPosSitua
	Local nDescSitu	:= ""

	//Valida o objeto.
	If Valtype(oMkSitu) == "O"
		FreeObj(oMkSitu:oBrowse)
		FreeObj(oMkSitu)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCobDia(4)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTSITUA") > 0
		D_FILTSITUA->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTSITUA"
	DbSelectArea("D_FILTSITUA")
	D_FILTSITUA->(DbGoTop())

	While ! D_FILTSITUA->(Eof())

		Aadd(aSituacoes,cValToChar(D_FILTSITUA->E1_SITUACA))

		D_FILTSITUA->(DbSkip())

	EndDo

	DbCloseArea("D_FILTSITUA")

	Asort(aSituacoes)

	aStru := {}
	Aadd(aStru,{"OK" 	   ,"C",02,0})
	Aadd(aStru,{"TMP_SITU" ,"C",02,0})
	Aadd(aStru,{"TMP_DESC" ,"C",40,0})

	//Iif(! Empty(Alltrim(cValToChar(cArSituac))) .And. File(cArSituac + GetDBExtension()),FErase(cArSituac  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArSituac := "T_ADFIN030P_CC_" + Criatrab(,.F.)
	Aadd(aArqTemp,cArSituac)
	MsCreate(cArSituac,aStru,"DBFCDX")

	If Select("TSITUAC") > 0
		TSITUAC->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArSituac,"TSITUAC",.T.,.F.)

	For i := 1 To Len(aSituacoes)

		nDescSitu := Posicione("SX5",1,xFilial("SX5")+"07"+ Alltrim(cValToChar(aSituacoes[i])),"X5_DESCRI") 

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			//Recarrega filtro de faixa de atraso conforme já aplicado.
			nPosSitua := 0
			nPosSitua := Ascan(aHistSituac,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aSituacoes[i])) })

			RecLock("TSITUAC",.T.)		
			TSITUAC->OK			:= Iif(nPosSitua == 0,"",cMark)
			TSITUAC->TMP_SITU	:= cValToChar(aSituacoes[i])
			TSITUAC->TMP_DESC	:= nDescSitu
			MsunLock()

		Else
			RecLock("TSITUAC",.T.)		
			TSITUAC->OK			:= cMark
			TSITUAC->TMP_SITU	:= cValToChar(aSituacoes[i])
			TSITUAC->TMP_DESC	:= nDescSitu
			MsunLock()

		EndIf

	Next i

	If Len(aSituacoes) == 0

		RecLock("TSITUAC",.T.)		
		TSITUAC->OK			:= ""
		TSITUAC->TMP_SITU	:= ""
		TSITUAC->TMP_DESC	:= ""
		MsunLock()	

	EndIf

	Aadd(aCpoBro,{"OK"		 ,, ""})		
	Aadd(aCpoBro,{"TMP_SITU",,"Situação"})	
	Aadd(aCpoBro,{"TMP_DESC",,"Descrição"})	

	oMkSitu := MsSelect():New("TSITUAC","OK","",aCpoBro ,.F.,@cMark ,{017,200,170,290},,,oPnlFilt1,,)
	oMkSitu:bMark := {| | DispSituac(oMkSitu,cMark)}
	oMkSitu:oBrowse:bAllMark := {|| SituacInvert(oMkSitu,cMark) }
	Eval(oMkSitu:oBrowse:bGoTop)
	oMkSitu:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function SituacInvert
	Função para inverter marcação do filtro por situação do título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function SituacInvert(oMkSitu,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TSITUAC" ) 
	     TSITUAC->(DbGotop())

	If TSITUAC->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	     While ! TSITUAC->(EoF())

	If Marked("OK")	
		RecLock("TSITUAC",.F.)
		TSITUAC->OK := ""
		MsUnlock()

	Else
		RecLock("TSITUAC",.F.)
		TSITUAC->OK := cMark
		MsUnlock()

	Endif

	     	TSITUAC->(DbSkip())

	     EndDo 

	Eval(oMkSitu:oBrowse:bGoTop)
	oMkSitu:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispSituac
	Função de  marcação do filtro por situação do título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispSituac(oMkSitu,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TSITUAC")

	If TSITUAC->(Eof())
		RestArea(aArea)
		Return Nil

	EndIf

	RecLock("TSITUAC",.F.)

	If Marked("OK")	
		TSITUAC->OK := cMark
	Else	
		TSITUAC->OK := ""
	Endif             

	MsUnlock()

	oMkSitu:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtRede
	Filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtRede(oPnlFilt1,oMkRede)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aRedes	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local aStru
	Local nPosRede
	Local cIndex

	//Valida o objeto.
	If Valtype(oMkRede) == "O"
		FreeObj(oMkRede:oBrowse)
		FreeObj(oMkRede)

	EndIf

	//Valida o objeto.
	If Valtype(oMkRdBusca) == "O"
		FreeObj(oMkRdBusca:oBrowse)
		FreeObj(oMkRdBusca)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCobDia(6)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTREDE") > 0
		D_FILTREDE->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTREDE"
	DbSelectArea("D_FILTREDE")
	D_FILTREDE->(DbGoTop())

	aStru := {}
	Aadd(aStru,{"OK" 	   ,"C",02,0})
	Aadd(aStru,{"TMP_RED"  ,"C",10,0})
	Aadd(aStru,{"TMP_DESC" ,"C",40,0})

	//Iif(! Empty(Alltrim(cValToChar(cArRede)))   .And. File(cArRede   + GetDBExtension())  ,FErase(cArRede  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArRede := "T_ADFIN030P_CC_" + Criatrab(,.F.)
	Aadd(aArqTemp,cArRede)
	MsCreate(cArRede,aStru,"DBFCDX")

	If Select("TREDE") > 0
		TREDE->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArRede,"TREDE",.T.,.F.)	

	DbSelectArea("D_FILTREDE")
	While ! D_FILTREDE->(Eof())

		Aadd(aRedes,{D_FILTREDE->REDE,D_FILTREDE->NOME_REDE})

		D_FILTREDE->(DbSkip())

	EndDo

	DbCloseArea("D_FILTREDE")

	//
	For i := 1 To Len(aRedes)

		If lHistFilt1 //Verifica se já foi aplicado filtro.
			//Recarrega filtro de faixa de atraso conforme já aplicado.
			nPosRede := 0
			nPosRede := Ascan(aHisTREDE,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aRedes[i][1])) })

			RecLock("TREDE",.T.)		
			TREDE->OK		:= Iif(nPosRede == 0,"",cMark)
			TREDE->TMP_RED	:= Alltrim(cValToChar(aRedes[i][1]))
			TREDE->TMP_DESC	:= Alltrim(cValToChar(aRedes[i][2]))
			MsunLock()

		Else
			RecLock("TREDE",.T.)		
			TREDE->OK		:= cMark
			TREDE->TMP_RED	:= Alltrim(cValToChar(aRedes[i][1]))
			TREDE->TMP_DESC	:= Alltrim(cValToChar(aRedes[i][2]))
			MsunLock()

		EndIf

	Next i

	//
	If Len(aRedes) <= 0

		RecLock("TREDE",.T.)		
		TREDE->OK		:= ""
		TREDE->TMP_RED	:= ""
		TREDE->TMP_DESC	:=""
		MsunLock()	

	EndIf

	Aadd(aCpoBro,{"OK"	     ,, ""})		
	Aadd(aCpoBro,{"TMP_RED"  ,,"Rede"})	
	Aadd(aCpoBro,{"TMP_DESC" ,,"Nome"})

	oMkRede := MsSelect():New("TREDE","OK","",aCpoBro ,.F.,@cMark ,{037,310,170,400},,,oPnlFilt1,,)
	oMkRede:bMark := {| | DispRede(oMkRede,cMark)} 
	oMkRede:oBrowse:bAllMark := {|| RedeInvert(oMkRede,cMark) }
	Eval(oMkRede:oBrowse:bGoTop)
	oMkRede:oBrowse:Refresh()

	oMkRdBusca := oMkRede

	oPnlFilt1:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function RedeInvert
	Inverter marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function RedeInvert(oMkRede,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TREDE" ) 
	     TREDE->(DbGotop())

	     While ! TREDE->(EoF())

	If Marked("OK")	
		RecLock("TREDE",.F.)
		TREDE->OK := ""
		MsUnlock()

	Else
		RecLock("TREDE",.F.)
		TREDE->OK := cMark
		MsUnlock()

	Endif

	     	TREDE->(DbSkip())

	     EndDo 

	Eval(oMkRede:oBrowse:bGoTop)
	oMkRede:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispRede
	Marcação de filtro por rede.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispRede(oMkRede,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TREDE")
	RecLock("TREDE",.F.)

	If Marked("OK")	
		TREDE->OK := cMark
	Else	
		TREDE->OK := ""
	Endif             

	MsUnlock()

	oMkRede:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtTitulo
	Filtro por título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtTitulo(oPnlFilt1,oMkTitulo)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aTpTit	:= {}
	Local i			:= 1
	Local nLinha	:= 5
	Local nColuna	:= 5
	Local aCpoBro	:= {}
	Local cMark   	:= GetMark() 
	Local aStru
	Local nPosTit
	Local cIndex
	Local cDescTit	:= ""

	//Valida o objeto.
	If Valtype(oMkTitulo) == "O"
		FreeObj(oMkTitulo:oBrowse)
		FreeObj(oMkTitulo)

	EndIf

	//Obtém o script sql.
	cQuery := sqlCobDia(7)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_FILTTIT") > 0
		D_FILTTIT->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_FILTTIT"
	DbSelectArea("D_FILTTIT")
	D_FILTTIT->(DbGoTop())

	/*	If D_FILTTIT->(Eof())
	DbCloseArea("D_FILTTIT")
	RestArea(aArea)
	Return Nil

	EndIf*/

	aStru := {}
	Aadd(aStru,{"OK" 	 ,"C",02,0})
	Aadd(aStru,{"TMP_TPT","C",10,0})
	Aadd(aStru,{"TMP_DESC" ,"C",40,0})

	//Iif(! Empty(Alltrim(cValToChar(cArTpTit)))  .And. File(cArTpTit  + GetDBExtension())  ,FErase(cArTpTit  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArTpTit := "T_ADFIN030P_CC_" + Criatrab(,.F.)
	Aadd(aArqTemp,cArTpTit)
	MsCreate(cArTpTit,aStru,"DBFCDX")

	If Select("TTPTIT") > 0
		TTPTIT->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArTpTit,"TTPTIT",.T.,.F.)	

	//
	If D_FILTTIT->(Eof())

		RecLock("TTPTIT",.T.)		
		TTPTIT->OK		:= ""
		TTPTIT->TMP_TPT	:= ""
		TTPTIT->TMP_DESC	:= ""
		MsunLock()

	EndIf

	While ! D_FILTTIT->(Eof())

		cDescTit := nDescSitu := Posicione("SX5",1,xFilial("SX5")+"05"+ Alltrim(cValToChar(D_FILTTIT->E1_TIPO)),"X5_DESCRI")

		If lHistFilt1 //Verifica se já foi aplicado filtro.

			nPosTit := 0
			nPosTit := Ascan(aHisTTPTIT,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(D_FILTTIT->E1_TIPO)) })

			RecLock("TTPTIT",.T.)		
			TTPTIT->OK		:= Iif(nPosTit == 0,"",cMark)
			TTPTIT->TMP_TPT	:= D_FILTTIT->E1_TIPO
			TTPTIT->TMP_DESC:= cDescTit
			MsunLock()

		Else
			RecLock("TTPTIT",.T.)		
			TTPTIT->OK		:= cMark
			TTPTIT->TMP_TPT	:= D_FILTTIT->E1_TIPO
			TTPTIT->TMP_DESC:= cDescTit
			MsunLock()

		EndIf

		D_FILTTIT->(DbSkip())

	EndDo

	DbSelectArea("TTPTIT")

	Aadd(aCpoBro,{"OK"	   ,, ""})		
	Aadd(aCpoBro,{"TMP_TPT",,"Tipo"})	
	Aadd(aCpoBro,{"TMP_DESC" ,,"Desc"})

	oMkTitulo := MsSelect():New("TTPTIT","OK","",aCpoBro ,.F.,@cMark ,{017,420,170,510},,,oPnlFilt1,,)
	oMkTitulo:bMark := {| | DispTpTit(oMkTitulo,cMark)} 
	oMkTitulo:oBrowse:bAllMark := {|| TpTitInvert(oMkTitulo,cMark) }
	Eval(oMkTitulo:oBrowse:bGoTop)
	oMkTitulo:oBrowse:Refresh()

	oPnlFilt1:Refresh()

	//DbCloseArea("D_FILTTIT")

	RestArea(aArea)	

Return Nil

/*/{Protheus.doc} Static Function TpTitInvert
	Inverter marcação de filtro por título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function TpTitInvert(oMkTitulo,cMark) 

	Local aArea		:= GetArea()

	     DbSelectArea( "TTPTIT" ) 
	     TTPTIT->(DbGotop())

	     While ! TTPTIT->(EoF())

	If Marked("OK")	
		RecLock("TTPTIT",.F.)
		TTPTIT->OK := ""
		MsUnlock()

	Else
		RecLock("TTPTIT",.F.)
		TTPTIT->OK := cMark
		MsUnlock()

	Endif

	     	TTPTIT->(DbSkip())

	     EndDo 

	Eval(oMkTitulo:oBrowse:bGoTop)
	oMkTitulo:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DispTpTit
	Marcação de filtro por título.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DispTpTit(oMkTitulo,cMark)

	Local aArea		:= GetArea()

	DbSelectArea("TTPTIT")
	RecLock("TTPTIT",.F.)

	If Marked("OK")	
		TTPTIT->OK := cMark
	Else	
		TTPTIT->OK := ""
	Endif             

	MsUnlock()

	oMkTitulo:oBrowse:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function carrCobDia
	Carregar interface com os títulos.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function carrCobDia(oCobranca,oSplitter,oTitulos,aAltTitulos,aColsTitulos)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lCont		:= .T.
	Local aFaixas	:= {}
	Local nPosFaixa	:= 0
	Local i			:= 1
	Local w			:= 1
	Local aFaixas2	:= {}
	Local nTotal	:= 0
	Local cRede		:= ""
	Local aStru		:= {}
	Local cNomTr1	:= ""
	Local cIndex	:= ""
	Local lAchou	:= .F.
	Local aTotais	:= {}
	Local cTpFx	:= ""

	//Obtém o script sql.
	cQuery := sqlCobDia(1)
	
	//
	If Empty(cQuery)
		RestArea(aArea)
		Return .F.

	EndIf

	//Valida o objeto msnewgetdados.
	If Valtype(oTitulos) == "O"
		oTitulos:oBrowse:End()
		FreeObj(oTitulos:oBrowse)
		FreeObj(oTitulos)

	EndIf

	nTotTT := 0

	oTitulos    := Nil
	aAltTitulos	:= {}
	aHTitulos	:= {}
	aColsTitulos:= {}

	Aadd(aHTitulos,{"Nome","NOME","" ,TamSX3("A1_NOME")[1], 0,"","" ,"C","",""})
	Aadd(aHTitulos,{"Código/Rede","REDE","" ,(TamSX3("A1_COD")[1]) + 3, 0,"","" ,"C","",""})

	If Select("D_COBDIA") > 0
		D_COBDIA->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_COBDIA"
	DbSelectArea("D_COBDIA")
	D_COBDIA->(DbGoTop())

	//Verifica se há registros.
	If D_COBDIA->(Eof())

		oTitulos := MsNewGetDados():New(001,005,234,540,,"Allwaystrue()","Allwaystrue()","",aAltTitulos,1,999,Nil,Nil,Nil,oSplitter,aHTitulos,@aColsTitulos)
		oTitulos:oBrowse:bLDblClick := {|| obterDetalhe(oTitulos,oSplitter) }

		oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "REDE" })] := ""
		oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "NOME" })] := ""

		RestArea(aArea)
		Return .F.

	EndIf 

	//Obtém as faixas para criação do aHeader.
	While ! D_COBDIA->(Eof())

		nPosFaixa := aScan(aFaixas,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(D_COBDIA->FAIXA))})

		If nPosFaixa == 0
			Aadd(aFaixas,{Val(cValToChar(D_COBDIA->FAIXA))})

		EndIf

		D_COBDIA->(DbSkip())

	EndDo

	aStru := {}
	Aadd(aStru,{"TM_REDE"  	    , "C",10,0})	
	Aadd(aStru,{"TM_NOME"		, "C",60,0})
	Aadd(aStru,{"TM_TOTAL" 		, "N",15,2})
	Aadd(aStru,{"TM_TOTALF" 	, "N",15,2})

	//Ordena array.

	For i := 1 To Len(aFaixas)
		Aadd(aFaixas2,Val(cValToChar(aFaixas[i][1])))

	Next i

	Asort(aFaixas2)

	For i := 1 To Len(aFaixas2)
		Aadd(aHTitulos,{"Faixa" + cValToChar(aFaixas2[i]),"FAIXA" + cValToChar(aFaixas2[i]),"@E 999,999,999.99" ,15, 0,"","" ,"N","",""})

		Aadd(aStru,{"TM_F" + cValToChar(aFaixas2[i]) 		, "N",015,2})

	Next i

	Aadd(aHTitulos,{"Total","TOTAL","@E 999,999,999.99" ,15,2,"","" ,"N","",""})

	//Cria arquivo temporário.
	cNomTr1 := CriaTrab(aStru)

	//Define arquivo de dados com área de trabalho disponível.
	DbUseArea(.T.,,cNomTr1,"TEMP",.F.,.F.)

	//Define o índice do arquivo temporário.
	cIndex   := "TM_TOTALF"

	//Cria índice no arquivo temporário.
	IndRegua("TEMP", cNomTr1, cIndex,,,"Criando índice..." )

	DbSelectArea("D_COBDIA")
	D_COBDIA->(DbGoTop())
	While ! D_COBDIA->(Eof())

		DbSelectArea("TEMP")
		TEMP->(DbGoTop())

		//
		lAchou := .F.
		DbSelectArea("TEMP")
		TEMP->(DbGoTop())
		While ! TEMP->(Eof())

			If Alltrim(cValToChar(D_COBDIA->REDE)) == Alltrim(cValToChar(TEMP->TM_REDE))
				lAchou := .T.
				Exit

			EndIf

			TEMP->(DbSkip())
		EndDo

		If lAchou

			RecLock("TEMP",.F.)
			TEMP->&("TM_F"  + Alltrim(cValToChar(D_COBDIA->FAIXA))) += D_COBDIA->E1_SALDO
			TEMP->TM_TOTAL  += D_COBDIA->E1_SALDO
			TEMP->TM_TOTALF += (D_COBDIA->E1_SALDO * (-1))
			MsUnlock()

		Else

			RecLock("TEMP",.T.)
			TEMP->TM_REDE  := D_COBDIA->REDE
			TEMP->TM_NOME  := D_COBDIA->NOME_REDE
			TEMP->&("TM_F" + Alltrim(cValToChar(D_COBDIA->FAIXA))) := D_COBDIA->E1_SALDO
			TEMP->TM_TOTAL  := D_COBDIA->E1_SALDO
			TEMP->TM_TOTALF := (D_COBDIA->E1_SALDO * (-1))			
			MsUnlock()

		EndIf

		D_COBDIA->(DbSkip())

	EndDo

	oTitulos := MsNewGetDados():New(001,005,234,540,,"Allwaystrue()","Allwaystrue()","",aAltTitulos,1,999,Nil,Nil,Nil,oSplitter,aHTitulos,@aColsTitulos)
	oTitulos:oBrowse:bLDblClick := {|| Eval(bDisableBtn), obterDetalhe(oTitulos,oSplitter) }
	oTitulos:aCols := {}

	//Popula aCols.
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())	
	While ! TEMP->(Eof())

		Aadd(oTitulos:aCols , Array(Len(aHTitulos) + 1) )
		oTitulos:aCols[Len(oTitulos:aCols), Len(oTitulos:aCols[1]) ] := .F.

		oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "REDE" })] := TEMP->TM_REDE
		oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "NOME" })] := TEMP->TM_NOME

		For i := 1 To Len(aFaixas2)

			oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "FAIXA" + Alltrim(cValToChar(aFaixas2[i])) })] := TEMP->&("TM_F" + Alltrim(cValToChar(aFaixas2[i])))
			nTotal += TEMP->&("TM_F" + Alltrim(cValToChar(aFaixas2[i])))

		Next i

		oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == "TOTAL" })]:= TEMP->TM_TOTAL

		nTotTT += TEMP->TM_TOTAL

		TEMP->(DbSkip())

	EndDo

	//
	oTotTT:Refresh()

	//
	oTitulos:Refresh()

	//
	For i := 1 To Len(aHTitulos)

		cTpFx := Alltrim(cValToChar(aHTitulos[i][8]))

		If cTpFx == "N"

			nTotFx := 0
			For w := 1 To Len(oTitulos:aCols)

				nTotFx += Val(cValToChar(oTitulos:aCols[w][i]))

			Next w

			Aadd(aTotais,{Alltrim(cValToChar(aHTitulos[i][2])),nTotFx})

		Else

			Aadd(aTotais,{Alltrim(cValToChar(aHTitulos[i][2])),Iif(i == 1,"TOTAIS --> ","")})

		EndIf


	Next i

	//Cria os totais na grid.
	If Len(aTotais) > 0

		Aadd(oTitulos:aCols , Array(Len(aHTitulos) + 1) )
		oTitulos:aCols[Len(oTitulos:aCols), Len(oTitulos:aCols[1]) ] := .F.

		For i := 1 To Len(aHTitulos)

			oTitulos:aCols[Len(oTitulos:aCols),Ascan(aHTitulos,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aTotais[i][1])) })] := aTotais[i][2]

		Next i

		//
		oTitulos:Refresh()

	EndIf

	//Fecha arquivo temporário.
	DbSelectArea("TEMP")
	TEMP->(DbCloseArea())

	//Apaga o arquivo temporário.

	If ! Empty(Alltrim(cValToChar(cNomTr1)))
		FErase( Alltrim(cValToChar(cNomTr1)) + GetDBExtension() )
		FErase( Alltrim(cValToChar(cNomTr1)) + OrdBagExt() )

	EndIf

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} Static Function obterDetalhe
	Obtém detalhes dos títulos.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function obterDetalhe(oTitulos,oSplitter)

	Local aArea			:= GetArea()
	Local nLinha		:= oTitulos:nAt
	Local nColuna		:= oTitulos:oBrowse:ColPos
	Local nTitColum		:= Alltrim(cValToChar(aHTitulos[nColuna][1]))
	Local cQuery		:= ""
	Local cRede			:= Alltrim(cValToChar(oTitulos:aCols[nLinha][aScan(aHTitulos,{|x| Alltrim(cValToChar(x[2])) == "REDE"})]))
	Local cFaixa		:= Alltrim(cValToChar(Iif(Substr(nTitColum,1,5) <> "Faixa","",Substr(nTitColum,6,10))))
	Local cNmRede		:= Alltrim(cValToChar(oTitulos:aCols[nLinha][aScan(aHTitulos,{|x| Alltrim(cValToChar(x[2])) == "NOME"})]))

	Local oFont 		:= TFont():New(,,-14,,.T.)

	//
	nTotDetS := 0
	nTotDetV := 0

	//
	cQuery := sqlCobDia(5,cRede,cFaixa)

	//
	If Empty(cQuery)
		RestArea(aArea)
		Return Nil

	EndIf

	If Select("D_DETALHE") > 0
		D_DETALHE->(DbCloseArea())

	EndIf

	MsAguarde({||DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery),"D_DETALHE" , .F., .T. )},"Aguarde","Carregando dados...")
	DbSelectArea("D_DETALHE")
	D_DETALHE->(DbGoTop())

	If D_DETALHE->(Eof())
		RestArea(aArea)
		DbCloseArea("D_DETALHE")
		Return Nil

	EndIf

	If ValType(oDetalhes) == "O"
		FreeObj(oDetalhes:oBrowse)
		FreeObj(oDetalhes)

	EndIf

	If ValType(oTxtDetalhes) == "O"
		FreeObj(oTxtDetalhes)

	EndIf

	//
	aADetalhes	:= {}
	aHDetalhes	:= {}
	aColsDetalhes := {}

	//
	oSplitter:Hide()

	//
	oPnlDetalhes:Show()

	oTxtDetalhes := TSay():New(009,005,{||"Detalhes " + cRede + " | " + cNmRede + Iif(! Empty(cFaixa)," | Faixa " + cFaixa,"")},oPnlDetalhes,,oFont,,,,.T.,CLR_RED,CLR_WHITE,260,25)

	Aadd(aHDetalhes,{RetTitle("E1_FILIAL") ,"FILIAL" ,"" ,(TamSX3("E1_FILIAL")[1])  , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_NUM")    ,"TITULO" ,"" ,(TamSX3("E1_NUM")[1])     , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_PARCELA"),"PARCELA","" ,(TamSX3("E1_PARCELA")[1]) , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_TIPO")   ,"TIPO"   ,"" ,(TamSX3("E1_TIPO")[1])    , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_PORTADO"),"PORTADO","" ,(TamSX3("E1_PORTADO")[1]) , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("A6_NOME")   ,"NPORTADO","" ,(TamSX3("A6_NOME")[1])   , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_CLIENTE"),"CLIENTE","" ,(TamSX3("E1_CLIENTE")[1]) , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_LOJA")   ,"LOJA"   ,"" ,(TamSX3("E1_LOJA")[1])    , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_NOMCLI") ,"NMCLI"  ,"" ,(TamSX3("E1_NOMCLI")[1])  , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_VALOR")  ,"VALOR"  ,"@E 999,999,999.99" ,(TamSX3("E1_VALOR")[1])   , 0,"","" ,"N","",""})
	Aadd(aHDetalhes,{RetTitle("E1_HIST")   ,"HIST"   ,"" ,(TamSX3("E1_HIST")[1])    , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_SITUACA"),"SITUAC" ,"" ,(TamSX3("E1_SITUACA")[1]) , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_SALDO")  ,"SALDO"  ,"@E 999,999,999.99" ,(TamSX3("E1_SALDO")[1])   , (TamSX3("E1_SALDO")[2]),"","" ,"N","",""})
	Aadd(aHDetalhes,{RetTitle("E1_VEND1")  ,"VEND"   ,"" ,(TamSX3("E1_VEND1")[1])   , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_EMISSAO"),"EMISSAO","" ,10 , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{RetTitle("E1_VENCREA"),"VENCREA","" ,10 , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"CNPJ Raiz"           ,"CNPJR"  ,"" ,08                        , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"Cliente Rede"        ,"CLIREDE","" ,(TamSX3("ZF_REDE")[1])    , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"DDD"                 ,"DDD"    ,"" ,(TamSX3("A1_DDD")[1])     , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"Telefone"            ,"TELEF"  ,"" ,(TamSX3("A1_TEL")[1])     , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"E-mail vendedor"     ,"EMAILVE","" ,(TamSX3("A3_EMAIL")[1])   , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"D. Atraso"           ,"DATRASO","" ,05                        , 0,"","" ,"N","",""})
	Aadd(aHDetalhes,{"Faixa"               ,"FAIXA"  ,"" ,03                        , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"Telefone TecLan"     ,"TELTECL","" ,(TamSX3("A1_TEL2")[1])    , 0,"","" ,"C","",""})
	Aadd(aHDetalhes,{"Recno"     		   ,"REC"    ,"@E 999999999999999"    ,15   , 0,"","" ,"N","",""})

	oDetalhes := MsNewGetDados():New(025,005,214,530,,"Allwaystrue()","Allwaystrue()","",aADetalhes,Nil,999,Nil,Nil,Nil,oPnlDetalhes,aHDetalhes,@aColsDetalhes)
	oDetalhes:oBrowse:bLDblClick := {|| edtHist(oDetalhes,aHDetalhes) }
	oDetalhes:aCols := {}

	DbSelectArea("D_DETALHE")
	D_DETALHE->(DbGoTop())

	While ! D_DETALHE->(Eof())

		Aadd(oDetalhes:aCols , Array(Len(aHDetalhes) + 1) )
		oDetalhes:aCols[Len(oDetalhes:aCols), Len(oDetalhes:aCols[1]) ] := .F.

		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "FILIAL"  })] := D_DETALHE->E1_FILIAL
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "TITULO"  })] := D_DETALHE->E1_NUM
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "PARCELA" })] := D_DETALHE->E1_PARCELA
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "TIPO"    })] := D_DETALHE->E1_TIPO
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "PORTADO" })] := D_DETALHE->E1_PORTADO
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "NPORTADO"})] := Posicione("SA6",1,xFilial("SA6") + D_DETALHE->E1_PORTADO, "A6_NOME") //CHAMADO; 041135 - FERNANDO SIGOIL 20/04/2018
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "CLIENTE" })] := D_DETALHE->E1_CLIENTE
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "LOJA"    })] := D_DETALHE->E1_LOJA
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "NMCLI"   })] := D_DETALHE->A1_NOME
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "VALOR"   })] := Val(cValToChar(D_DETALHE->E1_VALOR))
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "HIST"    })] := D_DETALHE->E1_HIST
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "SITUAC"  })] := D_DETALHE->E1_SITUACA
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "SALDO"   })] := Val(cValToChar(D_DETALHE->E1_SALDO))
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "VEND"    })] := D_DETALHE->E1_VEND1
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "EMISSAO" })] := DToC(SToD(cValToChar(D_DETALHE->E1_EMISSAO)))
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "VENCREA" })] := DToC(SToD(cValToChar(D_DETALHE->E1_VENCREA)))
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "CNPJR"   })] := D_DETALHE->CGC_R
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "CLIREDE" })] := D_DETALHE->REDE
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "DDD"     })] := D_DETALHE->A1_DDD
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "TELEF"   })] := D_DETALHE->A1_TEL
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "EMAILVE" })] := D_DETALHE->A3_EMAIL
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "DATRASO" })] := Val(cValToChar(D_DETALHE->ATRASO))
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "FAIXA"   })] := D_DETALHE->FAIXA
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "TELTECL" })] := D_DETALHE->A1_TEL2
		oDetalhes:aCols[Len(oDetalhes:aCols),Ascan(aHDetalhes,{|x| AllTrim(x[2]) == "REC"     })] := Val(cValToChar(D_DETALHE->REC))

		nTotDetS += Val(cValToChar(D_DETALHE->E1_SALDO))

		nTotDetV += Val(cValToChar(D_DETALHE->E1_VALOR))

		D_DETALHE->(DbSkip())

	EndDo

	oTotDetS:Refresh()
	oTotDetV:Refresh()

	DbCloseArea("D_DETALHE")

	oDetalhes:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function carrFaixaAtr
	Carrega faixas de atraso.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function carrFaixaAtr(oFaixas,aHFaixas)

	Local aArea		:= GetArea()
	Local cQuery	:= ""

	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_TABELA = 'WX' ORDER BY CAST(X5_CHAVE AS FLOAT) " 

	If Select("D_FAIXAATR") > 0
		D_FAIXAATR->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "D_FAIXAATR"
	DbSelectArea("D_FAIXAATR")
	D_FAIXAATR->(DbGoTop())

	If D_FAIXAATR->(Eof())
		DbCloseArea("D_FAIXAATR")
		RestArea(aArea)
		Return Nil

	EndIf

	oFaixas:aCols := {}

	If D_FAIXAATR->(Eof())

		Aadd(oFaixas:aCols , Array(Len(aHFaixas) + 1) )
		oFaixas:aCols[Len(oFaixas:aCols), Len(oFaixas:aCols[1]) ] := .F.

		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "FAIXA" })]  := 0
		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "DEATR" })]  := 0
		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "ATEATR"})]  := 0

	EndIf

	While ! D_FAIXAATR->(Eof())

		Aadd(oFaixas:aCols , Array(Len(aHFaixas) + 1) )
		oFaixas:aCols[Len(oFaixas:aCols), Len(oFaixas:aCols[1]) ] := .F.

		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "FAIXA" })]  := Val(cValToChar(D_FAIXAATR->X5_CHAVE))
		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "DEATR" })]  := Val(cValToChar(D_FAIXAATR->X5_DESCRI))
		oFaixas:aCols[Len(oFaixas:aCols),Ascan(aHFaixas,{|x| AllTrim(x[2]) == "ATEATR"})]  := Val(cValToChar(D_FAIXAATR->X5_DESCSPA))

		D_FAIXAATR->(DbSkip())

	EndDo

	oFaixas:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function filtFixo
	Carrega expressões sql. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function filtFixo(oFilExpress,aHFilExpress)

	Local aArea		:= GetArea()
	Local cQuery	:= ""

	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_TABELA = 'WY' ORDER BY X5_CHAVE  " 

	If Select("D_FILTFIXO") > 0
		D_FILTFIXO->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "D_FILTFIXO"
	DbSelectArea("D_FILTFIXO")
	D_FILTFIXO->(DbGoTop())

	If D_FILTFIXO->(Eof())
		DbCloseArea("D_FILTFIXO")
		RestArea(aArea)
		Return Nil

	EndIf

	oFilExpress:aCols := {}

	If D_FILTFIXO->(Eof())

		Aadd(oFilExpress:aCols , Array(Len(aHFilExpress) + 1) )
		oFilExpress:aCols[Len(oFilExpress:aCols), Len(oFilExpress:aCols[1]) ] := .F.

		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]  := ""
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })]  := ""

	EndIf

	While ! D_FILTFIXO->(Eof())

		Aadd(oFilExpress:aCols , Array(Len(aHFilExpress) + 1) )
		oFilExpress:aCols[Len(oFilExpress:aCols), Len(oFilExpress:aCols[1]) ] := .F.

		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "TABELA" })]  := Alltrim(cValToChar(D_FILTFIXO->X5_DESCRI))
		oFilExpress:aCols[Len(oFilExpress:aCols),Ascan(aHFilExpress,{|x| AllTrim(x[2]) == "EXPRES" })]  := Alltrim(cValToChar(D_FILTFIXO->X5_DESCSPA))

		D_FILTFIXO->(DbSkip())

	EndDo

	oFilExpress:Refresh()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function slvFaixaAtr
	Salva faixa de atraso. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function slvFaixaAtr(oFaixas,aHFaixas)

	Local aArea		:= GetArea()
	Local i			:= 1
	Local cUpdate	:= "UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = '*' WHERE X5_TABELA = 'WX' AND D_E_L_E_T_ = '' "	
	Local cFaixa	:= ""
	Local cDeAtr	:= ""
	Local cAteAtr	:= ""

	If TCSqlExec(cUpdate) < 0
		MsgStop("Ocorreu um erro na atualização das faixas de atraso " + Chr(13) + Chr(10) + TCSQLError(),"Função slvFaixaAtr")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	For i := 1 To Len(oFaixas:aCols)

		If ! (oFaixas:aCols[i,Len(oFaixas:aCols[1])]) 

			cFaixa := Alltrim(cValToChar(oFaixas:aCols[i,Ascan(aHFaixas,{|x| AllTrim(x[2]) == "FAIXA" })]))
			cAtraso:= Alltrim(cValToChar(oFaixas:aCols[i,Ascan(aHFaixas,{|x| AllTrim(x[2]) == "DEATR"})]))
			cAteAtr:= Alltrim(cValToChar(oFaixas:aCols[i,Ascan(aHFaixas,{|x| AllTrim(x[2]) == "ATEATR"})]))

			RecLock("SX5",.T.)
			SX5->X5_TABELA	:= "WX"
			SX5->X5_CHAVE  	:= cFaixa
			SX5->X5_DESCRI	:= cAtraso
			SX5->X5_DESCSPA	:= cAteAtr
			MsUnlock()

		EndIf

	Next i

	MsgInfo("Registros salvos.","Função slvFaixaAtr")

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function sqlCobDia
	Script sql base.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlCobDia(nOpc,cRede,cFaixa)

	Local aArea	:= GetArea()
	Local cQuery:= ""

	//
	cRede	:= Alltrim(cValToChar(cRede))
	cFaixa	:= Alltrim(cValToChar(cFaixa))

	If nOpc == 1
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " FONTE.REDE, "
		cQuery += " FONTE.NOME_REDE, "
		cQuery += " FONTE.FAIXA, "
		cQuery += " SUM(FONTE.E1_SALDO) AS E1_SALDO "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 2 //Obtém faixas de atraso.
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE.FAIXA "
		cQuery += " FROM "
		cQuery += " ( "	

	ElseIf nOpc == 3
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE.E1_PORTADO "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 4	
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE.E1_SITUACA "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 5	
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " * "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 6	
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE.REDE, FONTE.NOME_REDE "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 7	
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " DISTINCT FONTE.E1_TIPO "
		cQuery += " FROM "
		cQuery += " ( "

	ElseIf nOpc == 8
		cQuery := ""
		cQuery += " SELECT "
		cQuery += " * "
		cQuery += " FROM "
		cQuery += " ( "

	EndIf

	cQuery += " SELECT * "
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " SELECT  " 
	cQuery += " SE1.*, " 
	cQuery += " FAIXATRASO.X5_CHAVE AS FAIXA, " 
	cQuery += " CASE WHEN REDE.ZF_REDE IS NULL THEN CAST(RTRIM(LTRIM(SE1.E1_CLIENTE)) AS VARCHAR) + CAST(RTRIM(LTRIM(SE1.E1_LOJA)) AS VARCHAR) ELSE REDE.ZF_REDE END AS REDE,  " 
	cQuery += " CASE WHEN REDE.ZF_NOMERED IS NULL THEN SE1.A1_NOME ELSE REDE.ZF_NOMERED END AS NOME_REDE, REDE.* " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " SE1010.E1_FILIAL,  " 
	cQuery += " SE1010.E1_NUM,  " 
	cQuery += " SE1010.E1_PARCELA,  " 
	cQuery += " SE1010.E1_TIPO,  " 
	cQuery += " SE1010.E1_PORTADO,  "
	cQuery += " SE1010.E1_NUMBCO,  "  //19/02/2019 - William - chamado 047186
	cQuery += " SE1010.E1_CLIENTE,  " 
	cQuery += " SE1010.E1_LOJA,  " 
	cQuery += " SE1010.E1_NOMCLI,  " 
	cQuery += " SE1010.E1_EMISSAO, " 
	cQuery += " SE1010.E1_VENCREA,  " 
	cQuery += " SE1010.E1_BAIXA,  "
	cQuery += " SE1010.E1_VALOR,  " 
	cQuery += " SE1010.E1_HIST,  " 
	cQuery += " SE1010.E1_SITUACA,  " 
	cQuery += " SE1010.E1_SALDO,  " 
	cQuery += " SE1010.E1_VEND1, SE1010.R_E_C_N_O_ AS REC," 
	cQuery += " CASE WHEN DATEDIFF(DAY,CAST(E1_VENCREA AS DATE),CAST(GETDATE() AS DATE)) < 0 THEN 0 ELSE DATEDIFF(DAY,CAST(E1_VENCREA AS DATE),CAST(GETDATE() AS DATE))END AS ATRASO, " 
	cQuery += " A1_NOME, " 
	cQuery += " A3_EMAIL, " 
	cQuery += " A1_CGC, " 
	cQuery += " SUBSTRING(A1_CGC,1,8) AS CGC_R, " 
	cQuery += " A1_DDD, " 
	cQuery += " A1_EMAIL, "  //19/02/2019 - William - chamado 047186
	cQuery += " A1_EMAICO, " //19/02/2019 - William - chamado 047186
	cQuery += " A1_TEL, " 
	cQuery += " A1_VEND, "   //13/05/2019 - Everson - chamado 049082
	cQuery += " A1_TEL2 " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) SE1010 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("SA3") + " (NOLOCK) AS SA3 WHERE SA3.D_E_L_E_T_ = '') AS SA3    " 
	cQuery += " ON E1_VEND1 =  A3_COD " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += " ON E1_CLIENTE = A1_COD " 
	cQuery += " AND E1_LOJA = A1_LOJA " 
	cQuery += " WHERE " 
	cQuery += " SE1010.D_E_L_E_T_= '' " 
	cQuery += " " + cFilSE1 + " "
	cQuery += " AND SA1.D_E_L_E_T_ = '' " 
	cQuery += " " + cFilSA1 + " "
	cQuery += " " + cStatCli + " "

	//
	If nRDtCalc == 1
		cQuery += " AND (CAST(SE1010.E1_VENCREA AS DATE) < CAST('" + DToS(dDataIni) + "' AS DATE)) " 

	EndIf

	//
	cQuery += cFilSaldo 
	cQuery += " ) AS SE1 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " X5_CHAVE, X5_DESCRI, X5_DESCSPA " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SX5") + " (NOLOCK) AS SX5 " 
	cQuery += " WHERE  " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_TABELA = 'WX' " 
	cQuery += " ) AS FAIXATRASO " 
	cQuery += " ON CAST(SE1.ATRASO AS FLOAT) BETWEEN CAST(FAIXATRASO.X5_DESCRI AS FLOAT) AND CAST(FAIXATRASO.X5_DESCSPA AS FLOAT) " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " * " 
	cQuery += " FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF  " 
	cQuery += " WHERE " 
	cQuery += " SZF.D_E_L_E_T_='' " 
	cQuery += " ) AS REDE " 
	cQuery += " ON SE1.CGC_R = REDE.ZF_CGCMAT  "
	cQuery += " ) AS FONTE1 "

	If ! Empty(cFilSZF) 
		cQuery += " WHERE "
		cQuery += " " + Substr(Alltrim(cValToChar(cFilSZF)),4,Len(cFilSZF)) + " "

	EndIf

	If nOpc == 1
		cQuery += " ) AS FONTE "
		cQuery += " WHERE "
		cQuery += " FONTE.FAIXA IN (" + cFiltFaixas + ") "
		cQuery += " AND FONTE.E1_PORTADO IN (" + cFiltPortad + ") "
		cQuery += " AND FONTE.E1_SITUACA IN (" + cFiltSituad + ") "

		//
		If ! Empty(cFiltRede) .And. Len(cFiltRede) <= Len(cFiltRedeR)
			cQuery += " AND FONTE.REDE NOT IN (" + cFiltRede + ") "

		ElseIf ! Empty(cFiltRedeR) .And. Len(cFiltRede) >= Len(cFiltRedeR)
			cQuery += " AND FONTE.REDE IN (" + cFiltRedeR + ") "


		EndIf

		cQuery += " AND FONTE.E1_TIPO IN (" + cFiltTpTit + ") "
		cQuery += " GROUP BY "
		cQuery += " FONTE.REDE, "
		cQuery += " FONTE.FAIXA, "
		cQuery += " FONTE.NOME_REDE "

		cQuery += " ORDER BY FONTE.REDE, CAST(FONTE.FAIXA AS FLOAT) "

	ElseIf nOpc == 2
		cQuery += " ) AS FONTE "

	ElseIf nOpc == 3
		cQuery += " ) AS FONTE "

	ElseIf nOpc == 4
		cQuery += " ) AS FONTE "

	ElseIf nOpc == 5
		cQuery += " ) AS FONTE "
		cQuery += " WHERE "
		cQuery += " FONTE.E1_PORTADO IN (" + cFiltPortad + ") "
		cQuery += " AND FONTE.E1_SITUACA IN (" + cFiltSituad + ") "
		cQuery += " AND FONTE.E1_TIPO IN (" + cFiltTpTit + ") "

		If ! Empty(Alltrim(cValToChar(cRede)))

			cQuery += " AND FONTE.REDE = '" + cRede + "' "

		EndIf

		If ! Empty(cFaixa)
			cQuery += " AND FONTE.FAIXA = '" + cFaixa + "' "

		Else
			cQuery += " AND FONTE.FAIXA IN (" + cFiltFaixas + ") "

		EndIf

		cQuery += " ORDER BY  FONTE.E1_FILIAL, FONTE.E1_CLIENTE, FONTE.E1_LOJA, FONTE.E1_NUM, FONTE.E1_PARCELA "

	ElseIf nOpc == 6
		cQuery += " ) AS FONTE "
		cQuery += " ORDER BY  FONTE.REDE "

	ElseIf nOpc == 7
		cQuery += " ) AS FONTE "
		cQuery += " ORDER BY  FONTE.E1_TIPO "


	ElseIf nOpc == 8
		cQuery += " ) AS FONTE "
		cQuery += " WHERE "
		cQuery += " FONTE.E1_PORTADO IN (" + cFiltPortad + ") "
		cQuery += " AND FONTE.E1_SITUACA IN (" + cFiltSituad + ") "
		cQuery += " AND FONTE.E1_TIPO IN (" + cFiltTpTit + ") "
		cQuery += " AND FONTE.FAIXA IN (" + cFiltFaixas + ") "

		cQuery += " ORDER BY  FONTE.E1_FILIAL, FONTE.E1_CLIENTE, FONTE.E1_LOJA, FONTE.E1_NUM, FONTE.E1_PARCELA "

	EndIf
	

	//
	Iif(Len(cQuery) > 15980,Eval({|| cQuery := "", MsgStop("Não será possível executar a consulta pois o script sql excede o tamanho máximo (15.980).","Função sqlCobDia")}),Nil)

	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function lancCoRFin
	Lançamentos Contábeis - Resultado Financeiro.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function lancCoRFin()

	Local aArea		:= GetArea()
	Local oLCRF
	Local oGroup1
	Local oAtul
	Local oGroup2
	Local oGroup3
	Local oFechar
	Local oTFLCRF
	Local aTFLCRF	:= {}

	Local oBase
	Local aAltBase	:= {}
	Local aHBase	:= {}
	Local aColsBase	:= {}

	Local oAnalise
	Local aAltAnalis:= {}
	Local aHAnalise	:= {}
	Local aColsAnali:= {}

	Local oPeriodo
	Local cPeriodo

	Local cEmail	:= GetMv("MV_#LCRF")
	Local oCSV
	Local oCSVB

	Private lParam	:= .T.

	Private cCCCrD
	Private oCCCrD

	Private cCCCrA
	Private oCCCrA

	Private cCCDeD
	Private oCCDeD

	Private cCCDeA
	Private oCCDeA

	//Log de acesso.
	logAcesso("LCRF")

	oLCRF			:= MsDialog():Create()
	oLCRF:cName     := "oLCRF"
	oLCRF:cCaption  := "Lançamentos Contábeis - Resultado Financeiro"
	oLCRF:nLeft     := 34
	oLCRF:nTop      := 222
	oLCRF:nWidth    := 1200
	oLCRF:nHeight   := 550
	oLCRF:lShowHint := .F.
	oLCRF:lCentered := .T.

	aTFLCRF := {"Base","Análise"}
	oTFLCRF := TFolder():New(001,005,aTFLCRF,,oLCRF,,,,.T.,,535,235)
	oTFLCRF:SetOption(2)

	Aadd(aHBase,{"D/C"      ,"DC"   ,"" ,01, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Data"     ,"DATA" ,"" ,10, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Conta"    ,"CONTA" ,"",15, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Desc Conta","DCONTA" ,"",40, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Valor"    ,"VLR"  ,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
	Aadd(aHBase,{"Lote"     ,"LOTE" ,"" ,06, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Sub-Lote" ,"SLOT" ,"" ,06, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Docto"    ,"DOCT" ,"" ,09, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Linha"    ,"LINH" ,"" ,05, 0,"","" ,"C","",""})
	Aadd(aHBase,{"CTA Deb"  ,"CTDEB","" ,15, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Desc Deb" ,"DCTDE","" ,40, 0,"","" ,"C","",""})
	Aadd(aHBase,{"CTA Cred" ,"CTDCR","" ,15, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Desc Cred","DCTCR","" ,40, 0,"","" ,"C","",""})
	Aadd(aHBase,{"Histórico","HIST" ,"" ,TamSX3("CT2_HIST")[1], 0,"","" ,"C","",""})
	oBase 	:= MsNewGetDados():New(002,002,205,530,,"Allwaystrue()","Allwaystrue()","",aAltBase,Nil,999,Nil,Nil,Nil,oTFLCRF:aDialogs[1],aHBase,@aColsBase)

	oCSVB	:= TButton():New(210,485,"CSV",oTFLCRF:aDialogs[1],{|| MsAguarde({|| grLRCCSV(oBase,aHBase,"LCRF_BASE_" + cUserName + "_" + DToS(dDataBase) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	Aadd(aHAnalise,{"Conta Contábil" ,"CONTA","" ,TamSX3("CT1_CONTA")[1], 0,"","" ,"C","",""})
	Aadd(aHAnalise,{"Desc. CC"   	 ,"DCONTA","",TamSX3("CT1_DESC01")[1], 0,"","" ,"C","",""})
	Aadd(aHAnalise,{"Débito" ,"DEB"  ,"@E 9999,999,999.99" ,15, 2,"","" ,"N","",""})
	Aadd(aHAnalise,{"Crédito","CRED" ,"@E 9999,999,999.99" ,15, 2,"","" ,"N","",""})
	Aadd(aHAnalise,{"Vlr.Liq","VLRL" ,"@E 9999,999,999.99" ,15, 2,"","" ,"N","",""})

	oAnalise:= MsNewGetDados():New(002,002,220,430,,"Allwaystrue()","Allwaystrue()","",aAltAnalis,1,999,Nil,Nil,Nil,oTFLCRF:aDialogs[2],aHAnalise,@aColsAnali)
	oAnalise:oBrowse:bLDblClick := {|| MsAguarde({|| DetLCRF(oAnalise,aHAnalise) },"Aguarde","Carregando registros...") }

	oGroup3  := TGroup():Create(oTFLCRF:aDialogs[2],002,435,220,530,"",,,.T.)
	oTxtCC:= TSay():New(010,440,{||"Parâmetros de Conta Contábil."},oTFLCRF:aDialogs[2],,,,,,.T.,CLR_RED,CLR_WHITE,190,20)

	lParam  := .F.
	oCkCC   := TCheckBox():New(035,440,'Utiliza parâmetros de CC',{|u|If(PCount() == 0,lParam,lParam := u)},oTFLCRF:aDialogs[2],100,210,,,,,,,,.T.,,,)

	cCCCrD  := Space(TamSX3("CT1_CONTA")[1])
	oCCCrD  := TGet():New(055,440,{|u|If(PCount() == 0,cCCCrD,cCCCrD := u)},oTFLCRF:aDialogs[2],85,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCCCrD",,,,.T.,,,"CC Crédito De:",1) 
	oCCCrD:bF3 	:= &('{|| IIf(ConPad1(,,,"CT1",,,.F.),Eval({|| cCCCrD := CT1->CT1_CONTA,oCCCrD:Refresh()}),.T.)}')

	cCCCrA	:= Space(TamSX3("CT1_CONTA")[1])
	oCCCrA  := TGet():New(080,440,{|u|If(PCount() == 0,cCCCrA,cCCCrA := u)},oTFLCRF:aDialogs[2],85,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCCCrA",,,,.T.,,,"CC Crédito Até:",1) 
	oCCCrA:bF3 	:= &('{|| IIf(ConPad1(,,,"CT1",,,.F.),Eval({|| cCCCrA := CT1->CT1_CONTA,oCCCrD:Refresh()}),.T.)}')

	cCCDeD  := Space(TamSX3("CT1_CONTA")[1])
	oCCDeD  := TGet():New(110,440,{|u|If(PCount() == 0,cCCDeD,cCCDeD := u)},oTFLCRF:aDialogs[2],85,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCCDeD",,,,.T.,,,"CC Débito De:",1) 
	oCCDeD:bF3 	:= &('{|| IIf(ConPad1(,,,"CT1",,,.F.),Eval({|| cCCDeD := CT1->CT1_CONTA,oCCCrD:Refresh()}),.T.)}')

	cCCDeA	:= Space(TamSX3("CT1_CONTA")[1])
	oCCDeA  := TGet():New(135,440,{|u|If(PCount() == 0,cCCDeA,cCCDeA := u)},oTFLCRF:aDialogs[2],85,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCCDeA",,,,.T.,,,"CC Débito Até:",1) 
	oCCDeA:bF3 	:= &('{|| IIf(ConPad1(,,,"CT1",,,.F.),Eval({|| cCCDeA := CT1->CT1_CONTA,oCCCrD:Refresh()}),.T.)}')

	oCSV	 := TButton():New(205,440,"CSV",oTFLCRF:aDialogs[2],{|| MsAguarde({|| grLRCCSV(oAnalise,aHAnalise,"LCRF_ANALISE_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGroup1  := TGroup():Create(oLCRF,001,545,236,595,"",,,.T.)

	cPeriodo := cValToChar(Month(dDataBase-7)) + "/" + cValToChar(Year(dDataBase-7))
	oPeriodo  := TGet():New(006,550,{|u|If(PCount() == 0,cPeriodo,cPeriodo := u)},oLCRF,40,010,"@C",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cPeriodo",,,,.T.,,,"Período:",1) 

	oAtul 	  := TButton():New(031,550,"Atualizar"  ,oLCRF,  {|| MsAguarde({|| atlLCRF(oBase,aHBase,oAnalise,aHAnalise) },"Aguarde","Atualizando dados...")},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCadEmail := TButton():New(046,550,"Cad. e-mail",oLCRF,{|| cadEmailLCRF() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oEnvEmail := TButton():New(061,550,"Env. e-mail",oLCRF,{|| MsAguarde({|| envMaillcrf(.F.)  },"Aguarde","Enviando relatório...")},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGroup2	 := TGroup():Create(oLCRF,240,005,260,595,"",,,.T.)

	oFechar	 := TButton():New(245,550,"Fechar",oLCRF,{||oLCRF:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oLCRF:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| atlLCRF(oBase,aHBase,oAnalise,aHAnalise) },"Aguarde","Carregando dados...") })	

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function DetLCRF
	Detalhes LCRF. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function DetLCRF(oAnalise,aHAnalise)

	Local aArea		:= GetArea()
	Local oDLCRF
	Local oGroup2
	Local oFechar
	Local cQuery	:= ""
	Local aAltDet	:= {}
	Local aHDet	:= {}
	Local aColsDet	:= {}
	Local cVCCDeb	:= Val(cValToChar( oAnalise:aCols[oAnalise:nAt][ aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "DEB" })]))
	Local cVCCCred	:= Val(cValToChar( oAnalise:aCols[oAnalise:nAt][ aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "CRED" })]))
	Local cVlrLiq	:= Val(cValToChar( oAnalise:aCols[oAnalise:nAt][ aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "VLRL" })])) 
	Local cConta	:= Alltrim(cValToChar( oAnalise:aCols[oAnalise:nAt][ aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "CONTA" })]))
	Local nColuna	:= oAnalise:oBrowse:ColPos
	Local cNomeColu	:= Alltrim(cValToChar(aHAnalise[nColuna][2]))
	Local cTituJan	:= ""
	Local oCSV
	Local oTxtCC
	Local oFont 	:= TFont():New(,,-14,,.T.)

	//
	If nColuna == 2 .Or. nColuna == 1
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If cNomeColu == "CRED"  .And. cVCCCred == 0
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If cNomeColu == "DEB"  .And. cVCCDeb == 0
		RestArea(aArea)
		Return Nil

	EndIf	

	//
	If cNomeColu == "VLRL"  .And. cVCCDeb == 0 .And. cVCCCred == 0
		RestArea(aArea)
		Return Nil

	EndIf

	cQuery := ""
	cQuery := " SELECT * FROM ("
	cQuery += scriptLCRF(.F.)	
	cQuery += " ) AS FONTE "

	If		cNomeColu == "DEB" .Or. ( cNomeColu == "VLRL" .And. cVCCCred == 0  .And. cVCCDeb <> 0 )
		cQuery += " WHERE "
		cQuery += " FONTE.D_C = 'D' "

		If cConta <> "Total"
			cQuery += " AND FONTE.Conta = '" + cConta + "' "

		EndIf

		cTituJan := "Conta Débito " + cConta

	ElseIf	cNomeColu == "CRED" .Or. ( cNomeColu == "VLRL" .And. cVCCDeb == 0 .And. cVCCCred <> 0 )
		cQuery += " WHERE "
		cQuery += " FONTE.D_C = 'C' "

		If cConta <> "Total"
			cQuery += " AND FONTE.Conta = '" + cConta + "' "

		EndIf

		cTituJan := "Conta Crédito " + cConta

	ElseIf cNomeColu == "VLRL" .And. cVCCDeb <> 0 .And. cVCCCred <> 0

		If cConta <> "Total"
			cQuery += " WHERE "
			cQuery += " FONTE.Conta = '" + cConta + "'  "

		EndIf

		cTituJan := "Conta Débito " + cConta + " | Conta Crédito " + cConta

	Else
		RestArea(aArea)
		Return Nil

	EndIf

	

	oDLCRF			:= MsDialog():Create()
	oDLCRF:cName     := "oDLCRF"
	oDLCRF:cCaption  := "Lançamentos Contábeis - Resultado Financeiro"
	oDLCRF:nLeft     := 34
	oDLCRF:nTop      := 222
	oDLCRF:nWidth    := 1200
	oDLCRF:nHeight   := 550
	oDLCRF:lShowHint := .F.
	oDLCRF:lCentered := .T.

	Aadd(aHDet,{"D/C"      ,"DC"   ,"" ,01, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Data"     ,"DATA" ,"" ,10, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Conta"    ,"CONTA" ,"",15, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Desc Conta","DCONTA" ,"",40, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Valor"    ,"VLR"  ,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
	Aadd(aHDet,{"Lote"     ,"LOTE" ,"" ,06, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Sub-Lote" ,"SLOT" ,"" ,06, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Docto"    ,"DOCT" ,"" ,09, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Linha"    ,"LINH" ,"" ,05, 0,"","" ,"C","",""})
	Aadd(aHDet,{"CTA Deb"  ,"CTDEB","" ,15, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Desc Deb" ,"DCTDE","" ,40, 0,"","" ,"C","",""})
	Aadd(aHDet,{"CTA Cred" ,"CTDCR","" ,15, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Desc Cred","DCTCR","" ,40, 0,"","" ,"C","",""})
	Aadd(aHDet,{"Histórico","HIST" ,"" ,TamSX3("CT2_HIST")[1], 0,"","" ,"C","",""})

	oDetalhe 	:= MsNewGetDados():New(020,002,220,595,,"Allwaystrue()","Allwaystrue()","",aAltDet,,999,Nil,Nil,Nil,oDLCRF,aHDet,@aColsDet)

	If Select("DET_LCRF") > 0
		DET_LCRF->(DbCloseArea())

	EndIf
	
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"DET_LCRF",.T.,.F.) },"Aguarde","Consultando BD...")

	//TcQuery cQuery New Alias "DET_LCRF"
	DbSelectArea("DET_LCRF")
	DET_LCRF->(DbGoTop())

	If ! DET_LCRF->(Eof())
		oDetalhe:aCols := {}

	EndIf

	While ! DET_LCRF->(Eof())

		Aadd(oDetalhe:aCols , Array(Len(aHDet) + 1) )
		oDetalhe:aCols[Len(oDetalhe:aCols), Len(oDetalhe:aCols[1]) ] := .F.

		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DC"   })] := DET_LCRF->D_C
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DATA" })] := DET_LCRF->Data
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "CONTA"})] := DET_LCRF->Conta
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DCONTA"})] := DET_LCRF->Desc_Conta
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "VLR"  })] := DET_LCRF->Valor
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "LOTE" })] := DET_LCRF->Lote
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "SLOT" })] := DET_LCRF->Sub_Lote
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DOCT" })] := DET_LCRF->Docto
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "LINH" })] := DET_LCRF->Linha
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "CTDEB"})] := DET_LCRF->Conta_Deb
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DCTDE"})] := DET_LCRF->Desc_Deb
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "CTDCR"})] := DET_LCRF->Conta_Cred
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DCTCR"})] := DET_LCRF->Desc_Cred
		oDetalhe:aCols[Len(oDetalhe:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "HIST" })] := DET_LCRF->Historico

		DET_LCRF->(DbSkip())

	EndDo

	//
	oTxtCC := TSay():New(010,002,{|| cTituJan },oDLCRF,,oFont,,,,.T.,CLR_RED,CLR_WHITE,190,20)

	//
	oGroup2	 := TGroup():Create(oDLCRF,240,005,260,595,"",,,.T.)
	oCSV	 := TButton():New(245,505,"CSV"   ,oDLCRF,{|| MsAguarde({|| grLRCCSV(oDetalhe,aHDet,"LCRF_DET_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar	 := TButton():New(245,550,"Fechar",oDLCRF,{||oDLCRF:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oDLCRF:Activate(,,,.T.,{||.T.},,{|| })	

	//
	RestArea(aArea)	

Return Nil

/*/{Protheus.doc} Static Function atlLCRF
	Atualiza Lançamentos Contábeis - Resultado Financeiro.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function atlLCRF(oBase,aHBase,oAnalise,aHAnalise)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cArLCRF	:= ""
	Local cIndex	:= ""
	Local aStru		:= {}

	Local nTDeb		:= 0
	Local nTCred	:= 0
	Local nTVlrLiq	:= 0

	aStru := {}
	Aadd(aStru,{"COD_CONTA"  ,"C",TamSX3("CT1_CONTA") [1],0})
	Aadd(aStru,{"DES_CONTA"  ,"C",TamSX3("CT1_DESC01")[1],0})
	Aadd(aStru,{"VLR_DEB"    ,"N",15,2})
	Aadd(aStru,{"VLR_CRED"   ,"N",15,2})
	Aadd(aStru,{"VLR_LIQD"   ,"N",15,2})

	//Iif(! Empty(Alltrim(cValToChar(cArLCRF)))  .And. File(cArLCRF  + GetDBExtension()),FErase(cArLCRF  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArLCRF := "T_" + Criatrab(,.F.)
	MsCreate(cArLCRF,aStru,"DBFCDX")

	If Select("TLCRF") > 0
		TLCRF->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArLCRF,"TLCRF",.T.,.F.)

	//Define o índice do arquivo temporário.
	cIndex   := "COD_CONTA"

	//Cria índice no arquivo temporário.
	IndRegua("TLCRF", cArLCRF, cIndex,,,"Criando índice..." )

	//Débito.
	cQuery := scriptLCRF(.F.)


	If Select("Q_LCRF") > 0
		Q_LCRF->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "Q_LCRF"
	DbSelectArea("Q_LCRF")

	//
	oBase:aCols := {}

	While ! Q_LCRF->(Eof())

		Aadd(oBase:aCols , Array(Len(aHBase) + 1) )
		oBase:aCols[Len(oBase:aCols), Len(oBase:aCols[1]) ] := .F.

		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DC"   })] := Q_LCRF->D_C
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DATA" })] := Q_LCRF->Data
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CONTA"})] := Q_LCRF->Conta
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DCONTA"})] := Q_LCRF->Desc_Conta
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VLR"  })] := Q_LCRF->Valor
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LOTE" })] := Q_LCRF->Lote
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "SLOT" })] := Q_LCRF->Sub_Lote
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DOCT" })] := Q_LCRF->Docto
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LINH" })] := Q_LCRF->Linha
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CTDEB"})] := Q_LCRF->Conta_Deb
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DCTDE"})] := Q_LCRF->Desc_Deb
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CTDCR"})] := Q_LCRF->Conta_Cred
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DCTCR"})] := Q_LCRF->Desc_Cred
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "HIST" })] := Q_LCRF->Historico

		DbSelectArea("TLCRF")
		TLCRF->(DbGoTop())

		//
		If TLCRF->(DbSeek(Alltrim(cValToChar(Q_LCRF->Conta))))

			If Alltrim(cValToChar(Q_LCRF->D_C)) == "D"

				RecLock("TLCRF",.F.)
				TLCRF->VLR_DEB += (Q_LCRF->Valor * -1)
				MsUnlock()

			ElseIf Alltrim(cValToChar(Q_LCRF->D_C)) == "C"

				RecLock("TLCRF",.F.)
				TLCRF->VLR_CRED += Q_LCRF->Valor
				MsUnlock()

			EndIf

		Else

			If Alltrim(cValToChar(Q_LCRF->D_C)) == "D"

				RecLock("TLCRF",.T.)
				TLCRF->DES_CONTA := Alltrim(cValToChar(Q_LCRF->Desc_Conta))
				TLCRF->COD_CONTA := Alltrim(cValToChar(Q_LCRF->Conta))
				TLCRF->VLR_DEB   := (Q_LCRF->Valor * -1)
				MsUnlock()

			ElseIf Alltrim(cValToChar(Q_LCRF->D_C)) == "C"

				RecLock("TLCRF",.T.)
				TLCRF->DES_CONTA := Alltrim(cValToChar(Q_LCRF->Desc_Conta))
				TLCRF->COD_CONTA    := Alltrim(cValToChar(Q_LCRF->Conta))
				TLCRF->VLR_CRED := Q_LCRF->Valor
				MsUnlock()

			EndIf


		EndIf

		Q_LCRF->(DbSkip())

	EndDo

	//
	If Len(oBase:aCols) == 0

		Aadd(oBase:aCols , Array(Len(aHBase) + 1) )
		oBase:aCols[Len(oBase:aCols), Len(oBase:aCols[1]) ] := .F.

		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DC"   })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DATA" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VLR"  })] := 0
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LOTE" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "SLOT" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DOCT" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LINH" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CTDEB"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DCTDE"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CTDCR"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DCTCR"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "HIST" })] := ""

	EndIf

	DbSelectArea("TLCRF")
	TLCRF->(DbGoTop())

	If ! TLCRF->(Eof())
		oAnalise:aCols := {}

	EndIf

	While ! TLCRF->(Eof())

		Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
		oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.

		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "CONTA" })] := TLCRF->COD_CONTA
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "DCONTA"})] := TLCRF->DES_CONTA
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "DEB"   })] := TLCRF->VLR_DEB
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "CRED"  })] := TLCRF->VLR_CRED
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "VLRL"  })] := TLCRF->VLR_DEB + TLCRF->VLR_CRED

		//Totalizadores
		nTDeb   += TLCRF->VLR_DEB
		nTCred  += TLCRF->VLR_CRED
		nTVlrLiq+= TLCRF->VLR_DEB + TLCRF->VLR_CRED

		TLCRF->(DbSkip())

	EndDo

	//Atribui totais.
	If nTVlrLiq <> 0

		Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
		oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.

		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "CONTA" })] := "Total"
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "DCONTA"})] := ""
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "DEB"   })] := nTDeb
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "CRED"  })] := nTCred
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "VLRL"  })] := nTVlrLiq

	Endif

	DbCloseArea("TLCRF")

	//
	//Iif(! Empty(Alltrim(cValToChar(cArLCRF)))  .And. File(cArLCRF  + GetDBExtension()),FErase(cArLCRF  + GetDBExtension()) ,Nil)
	If ! Empty(Alltrim(cValToChar(cArLCRF)))
		FErase( Alltrim(cValToChar(cArLCRF)) + GetDBExtension() )
		FErase( Alltrim(cValToChar(cArLCRF)) + OrdBagExt() )

	EndIf

	//
	oBase:Refresh()	
	oAnalise:Refresh()

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function cadEmailLCRF
	Cadastro de e-mail para envio do relatório LCRF.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function cadEmailLCRF()

	Local aArea		:= GetArea()
	Local oEmail
	Local oTxtEmail
	Local oGroup1
	Local oOk
	Local oFechar

	Private cEmail	:= GetMv("MV_#LCRF")

	//
	cEmail := cEmail + Iif((200 - Len(cEmail)) > 0,Space(200 - Len(cEmail)),"")

	oCadMail			:= MsDialog():Create()
	oCadMail:cName     := "oCadMail"
	oCadMail:cCaption  := "Cadastro de E-mail"
	oCadMail:nLeft     := 34
	oCadMail:nTop      := 222
	oCadMail:nWidth    := 400
	oCadMail:nHeight   := 250
	oCadMail:lShowHint := .F.
	oCadMail:lCentered := .T.

	oTxtEmail:= TSay():New(010,005,{||"Utilize ';' para separar os endereços de e-mail."},oCadMail,,,,,,.T.,CLR_RED,CLR_WHITE,190,20)
	oEmail   := TGet():New(030,005,{|u|If(PCount() == 0,cEmail,cEmail := u)},oCadMail,190,010,"@C",{|| NaoVazio() },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmail",,,,.T.,,,"E-mail's:",1) 

	oGroup1  := TGroup():Create(oCadMail,085,005,105,195,"",,,.T.)

	oOk	     := TButton():New(090,105,"Ok",oCadMail,{||;
	PutMv("MV_#LCRF",Alltrim(cValToChar(cEmail))),;
	MsgInfo("Parâmetro alterado.","Função cadEmailLCRF"),;
	oCadMail:End();
	},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar	 := TButton():New(090,150,"Cancelar",oCadMail,{||oCadMail:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oCadMail:Activate(,,,.T.,{||.T.},,{||})	

	//
	RestArea(aArea)	

Return Nil

/*/{Protheus.doc} Static Function envMaillcrf
	Envia relatório por e-mail Lançamentos Contábeis - Resultado Financeiro.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

// ****Função também é utilizada no fonte ADFIN032R, por chamada de função estática**** //

Static Function envMaillcrf(lAut) 

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cEmail	:= GetMv("MV_#LCRF")
	Local aStru		:= {}
	Local cArEmail	:= ""

	Local nTDeb		:= 0
	Local nTCred	:= 0
	Local nTVlrLiq	:= 0
	Local cHtml		:= ""
	Local aDados	:= {}

	//
	If ! lAut

		If ! MsgYesNo("Deseja enviar o relatório para os e-mail's cadastrados?","Função envMaillcrf")
			RestArea(aArea)
			Return Nil

		EndIf

	EndIf

	aStru := {}
	Aadd(aStru,{"COD_CONTA"  ,"C",TamSX3("CT1_CONTA") [1],0})
	Aadd(aStru,{"DES_CONTA"  ,"C",TamSX3("CT1_DESC01")[1],0})
	Aadd(aStru,{"VLR_DEB"    ,"N",15,2})
	Aadd(aStru,{"VLR_CRED"   ,"N",15,2})
	Aadd(aStru,{"VLR_LIQD"   ,"N",15,2})

	//Iif(! Empty(Alltrim(cValToChar(cArEmail)))  .And. File(cArEmail  + GetDBExtension()),FErase(cArEmail  + GetDBExtension()) ,Nil)

	//Cria arquivo temporário.
	cArEmail := "T_" + Criatrab(,.F.)
	MsCreate(cArEmail,aStru,"DBFCDX")

	If Select("ETLCRF") > 0
		ETLCRF->(DbCloseArea())

	EndIf

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArEmail,"ETLCRF",.T.,.F.)

	//Define o índice do arquivo temporário.
	cIndex   := "COD_CONTA"

	//Cria índice no arquivo temporário.
	IndRegua("ETLCRF", cArEmail, cIndex,,,"Criando índice..." )

	//
	cQuery := scriptLCRF(lAut)

	If Select("D_EMAIL") > 0
		D_EMAIL->(DbCloseArea())

	EndIf

	TcQuery cQuery New Alias "D_EMAIL"
	DbSelectArea("D_EMAIL")
	D_EMAIL->(DbGoTop())

	While ! D_EMAIL->(Eof())

		DbSelectArea("ETLCRF")
		ETLCRF->(DbGoTop())

		//
		If ETLCRF->(DbSeek(Alltrim(cValToChar(D_EMAIL->Conta))))

			If Alltrim(cValToChar(D_EMAIL->D_C)) == "D"

				RecLock("ETLCRF",.F.)
				ETLCRF->VLR_DEB  += (D_EMAIL->Valor * -1)
				ETLCRF->VLR_LIQD += (D_EMAIL->Valor * -1)
				MsUnlock() 

			ElseIf Alltrim(cValToChar(D_EMAIL->D_C)) == "C"

				RecLock("ETLCRF",.F.)
				ETLCRF->VLR_CRED += D_EMAIL->Valor
				ETLCRF->VLR_LIQD += D_EMAIL->Valor
				MsUnlock()

			EndIf

		Else

			If Alltrim(cValToChar(D_EMAIL->D_C)) == "D"

				RecLock("ETLCRF",.T.)
				ETLCRF->COD_CONTA := Alltrim(cValToChar(D_EMAIL->Conta))
				ETLCRF->DES_CONTA := Alltrim(cValToChar(D_EMAIL->Desc_Conta))
				ETLCRF->VLR_DEB   := (D_EMAIL->Valor * -1)
				ETLCRF->VLR_LIQD  := (D_EMAIL->Valor * -1)
				MsUnlock()

			ElseIf Alltrim(cValToChar(D_EMAIL->D_C)) == "C"

				RecLock("ETLCRF",.T.)
				ETLCRF->COD_CONTA := Alltrim(cValToChar(D_EMAIL->Conta))
				ETLCRF->DES_CONTA := Alltrim(cValToChar(D_EMAIL->Desc_Conta))
				ETLCRF->VLR_CRED  := D_EMAIL->Valor
				ETLCRF->VLR_LIQD  := D_EMAIL->Valor
				MsUnlock()

			EndIf


		EndIf

		D_EMAIL->(DbSkip())

	EndDo

	DbSelectArea("ETLCRF")
	ETLCRF->(DbGoTop())

	While ! ETLCRF->(Eof())

		Aadd(aDados,{;
		ETLCRF->COD_CONTA,;
		ETLCRF->DES_CONTA,;
		ETLCRF->VLR_DEB,;
		ETLCRF->VLR_CRED,;
		ETLCRF->VLR_LIQD;
		})

		//Totalizadores
		nTDeb   += ETLCRF->VLR_DEB
		nTCred  += ETLCRF->VLR_CRED
		nTVlrLiq+= ETLCRF->VLR_DEB + ETLCRF->VLR_CRED

		ETLCRF->(DbSkip())

	EndDo

	//Gera relatório html.
	cHtml := templateHml(aDados,nTDeb,nTCred,nTVlrLiq)

	//Enviar e-mail.
	enviarEmail("Relatório - Lançamentos Contábeis - Resultado Financeiro",cHtml,cEmail,"")

	//Iif(! Empty(Alltrim(cValToChar(cArEmail)))  .And. File(cArEmail  + GetDBExtension()),FErase(cArEmail  + GetDBExtension()) ,Nil)

	If ! Empty(Alltrim(cValToChar(cArEmail)))
		FErase( Alltrim(cValToChar(cArEmail)) + GetDBExtension() )
		FErase( Alltrim(cValToChar(cArEmail)) + OrdBagExt() )

	EndIf

	//
	If ! lAut
		MsgInfo("Relatório enviado.","Função envMaillcrf")

	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function templateHml
	Template html do relatório enviado por e-mail.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function templateHml(aDados,nTDeb,nTCred,nTVlrLiq)

	Local aArea		:= GetArea()
	Local cHtml		:= ""
	Local i			:= 1

	cHtml += " <html> "
	cHtml += " <head> "
	cHtml += " <meta charset='UTF-8'> "
	cHtml += " <style> "
	cHtml += " body{background-color: #fdfdfd; color:black;} "
	cHtml += " td {border-bottom: 1px solid white;padding-left:5px;padding-right:5px;padding-top:2px;} "
	cHtml += " </style> "
	cHtml += " </head> "
	cHtml += " <body> "
	cHtml += " <div style='margin: 0 auto;width: 100%;padding: 10px;'> "
	cHtml += " <p><strong>Relatório: Lançamentos Contábeis -  Resultado Financeiro</strong></p> "
	cHtml += " <p><strong>Gerado em: " + DToC(Date()) + " - " + cValToChar(Time()) + "</strong></p> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "

	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d;border-bottom: 1px solid white;color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'><strong>Período: </strong></td> "
	cHtml += " <td style='background-color: #f7be62;color:black'><strong>" + cValToChar(Month(dDataBase-7)) + " - " + cValToChar(Year(dDataBase-7)) + "</strong></td> "
	cHtml += " </tr> "

	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'><strong>Conta Contábil</strong></td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'><strong>Desc. CC</strong></td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'><strong>Débito</strong></td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'><strong>Crédito</strong></td> "
	cHtml += " <td align='center'><strong>Valor Líquido</strong></td> "
	cHtml += " </tr> "

	For i := 1 To Len(aDados)

		cHtml += " <tr>
		cHtml += " <td align='left'>" + Alltrim(cValToChar(aDados[i][1])) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='left'>" + Alltrim(cValToChar(aDados[i][2])) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + Transform(Val(Alltrim(cValToChar(aDados[i][3]))),"@E 999,999,999.99") + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + Transform(Val(Alltrim(cValToChar(aDados[i][4]))),"@E 999,999,999.99") + "</td> "
		cHtml += " <td align='right'>" + Transform(Val(Alltrim(cValToChar(aDados[i][5]))),"@E 999,999,999.99") + "</td> "
		cHtml += " </tr> "

	Next i

	cHtml += " <tr style='background-color: #ffb236'>
	cHtml += " <td style='border-right: 1px solid white' colspan='2' align='right'><strong>Total</strong></td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'><strong>" + Transform(Val(Alltrim(cValToChar(nTDeb)))   ,"@E 999,999,999.99") + "</strong></td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'><strong>" + Transform(Val(Alltrim(cValToChar(nTCred)))  ,"@E 999,999,999.99") + "</strong></td> "
	cHtml += " <td align='right'><strong>" + Transform(Val(Alltrim(cValToChar(nTVlrLiq))),"@E 999,999,999.99") + "</strong></td> "
	cHtml += " </tr> "


	cHtml += " </table> "
	cHtml += " </div> "
	cHtml += " </body> "
	cHtml += " </html> "

	RestArea(aArea)

Return cHtml

/*/{Protheus.doc} Static Function scriptLCRF
	Script Sql Lançamentos Contábeis - Resultado Financeiro.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function scriptLCRF(lAut)

	Local aArea		:= GetArea()	
	Local cQuery	:= ""
	Local dData		:= dDataBase-7

	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " 'D' AS 'D_C' " 
	cQuery += " ,CONVERT(VARCHAR(10),CAST(CT2_DATA AS DATE),103) AS 'Data' " 
	cQuery += " ,CT2_DEBITO AS 'Conta' " 
	cQuery += " ,ISNULL(CT1DEB.CT1_DESC01,'') AS 'Desc_Conta' "
	cQuery += " ,CT2_VALOR AS 'Valor' " 
	cQuery += " ,CT2_LOTE AS 'Lote' " 
	cQuery += " ,CT2_SBLOTE AS 'Sub_Lote' " 
	cQuery += " ,CT2_DOC AS 'Docto' " 
	cQuery += " ,CT2_LINHA AS 'Linha' " 
	cQuery += " ,CT2_DEBITO AS 'Conta_Deb' " 
	cQuery += " ,ISNULL(CT1DEB.CT1_DESC01,'') AS 'Desc_Deb' " 
	cQuery += " ,ISNULL(CT2_CREDIT,'') AS 'Conta_Cred' " 
	cQuery += " ,ISNULL(CT1CRD.CT1_DESC01,'') AS 'Desc_Cred' "  
	cQuery += " ,CT2_HIST AS 'Historico' " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("CT2") + " (NOLOCK) AS  CT2CRD " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("CT1") + " (NOLOCK) AS CT1 WHERE CT1.D_E_L_E_T_ = '') AS CT1CRD " 
	cQuery += " ON CT2_CREDIT = CT1CRD.CT1_CONTA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("CT1") + " (NOLOCK) AS CT1 WHERE CT1.D_E_L_E_T_ = '') AS CT1DEB " 
	cQuery += " ON CT2_DEBITO = CT1DEB.CT1_CONTA " 
	cQuery += " WHERE  " 
	cQuery += " CT2CRD.D_E_L_E_T_ = '' " 
	cQuery += " AND MONTH(CT2CRD.CT2_DATA) = MONTH('" + DTos(dData) + "')  " 
	cQuery += " AND YEAR(CT2CRD.CT2_DATA)  = YEAR('" + DTos(dData) + "')  "


	If lAut
		cQuery += " AND (CT2_DEBITO>='335110001' AND CT2_DEBITO<='335999999') "

	Else

		If lParam
			cQuery += " AND (CT2_DEBITO>='" + Alltrim(cValToChar(cCCDeD)) + "' AND CT2_DEBITO<='" + Alltrim(cValToChar(cCCDeA)) + "') "

		Else
			cQuery += " AND (CT2_DEBITO>='335110001' AND CT2_DEBITO<='335999999') "

		EndIf

	EndIf

	cQuery += " UNION ALL " 

	//Crédito.
	cQuery += " SELECT  " 
	cQuery += " 'C' AS 'D_C' " 
	cQuery += " ,CONVERT(VARCHAR(10),CAST(CT2_DATA AS DATE),103) AS 'Data' " 
	cQuery += " ,CT2_CREDIT AS 'Conta' " 
	cQuery += " ,ISNULL(CT1CRD.CT1_DESC01,'') AS 'Desc_Conta' " 
	cQuery += " ,CT2_VALOR AS 'Valor' " 
	cQuery += " ,CT2_LOTE AS 'Lote' " 
	cQuery += " ,CT2_SBLOTE AS 'Sub_Lote' " 
	cQuery += " ,CT2_DOC AS 'Docto' " 
	cQuery += " ,CT2_LINHA AS 'Linha' " 
	cQuery += " ,CT2_DEBITO AS 'Conta_Deb' " 
	cQuery += " ,ISNULL(CT1DEB.CT1_DESC01,'') AS 'Desc_Deb' " 
	cQuery += " ,ISNULL(CT2_CREDIT,'') AS 'Conta_Cred' " 
	cQuery += " ,ISNULL(CT1CRD.CT1_DESC01,'') AS 'Desc_Cred' "  
	cQuery += " ,CT2_HIST AS 'Historico' " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("CT2") + " (NOLOCK) AS  CT2CRD " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("CT1") + " (NOLOCK) AS CT1 WHERE CT1.D_E_L_E_T_ = '') AS CT1CRD " 
	cQuery += " ON CT2_CREDIT = CT1CRD.CT1_CONTA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT * FROM " + RetSqlName("CT1") + " (NOLOCK) AS CT1 WHERE CT1.D_E_L_E_T_ = '') AS CT1DEB " 
	cQuery += " ON CT2_DEBITO = CT1DEB.CT1_CONTA " 
	cQuery += " WHERE  " 
	cQuery += " CT2CRD.D_E_L_E_T_ = '' " 
	cQuery += " AND MONTH(CT2CRD.CT2_DATA) = MONTH('" + DTos(dData) + "')  " 
	cQuery += " AND YEAR(CT2CRD.CT2_DATA)  = YEAR('" + DTos(dData) + "')  "

	If lAut
		cQuery += " AND (CT2CRD.CT2_CREDIT>='335110001' AND CT2CRD.CT2_CREDIT<='335999999') " 

	Else

		If lParam
			cQuery += " AND (CT2CRD.CT2_CREDIT>='" + Alltrim(cValToChar(cCCCrD)) + "' AND CT2CRD.CT2_CREDIT<='" + Alltrim(cValToChar(cCCCrA)) + "') " 

		Else
			cQuery += " AND (CT2CRD.CT2_CREDIT>='335110001' AND CT2CRD.CT2_CREDIT<='335999999') " 

		EndIf

	EndIf

	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function intRelLmUt
	Interface Relatório utilização de limites
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function intRelLmUt()

	Local aArea 	:= GetArea()
	Local oCadEmail
	Local oCadPorEsp
	Local oEnvRel
	Local oSlv
	Local oGroup1
	Local oFechar

	//
	logAcesso("INTRELLMUT")

	//
	oTelConf			:= MsDialog():Create()
	oTelConf:cName     := "oTelConf"
	oTelConf:cCaption  := "Relatório Utilização de Limites"
	oTelConf:nLeft     := 34
	oTelConf:nTop      := 222
	oTelConf:nWidth    := 250
	oTelConf:nHeight   := 437
	oTelConf:lShowHint := .F.
	oTelConf:lCentered := .T.

	oCadEmail  := TButton():New(016,005,"Cadastrar e-mail",oTelConf,{|| cadEmail() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

	oCadPorEsp := TButton():New(039,005,"Portador Especial",oTelConf,{|| cadPorEsp() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

	oEnvRel	   := TButton():New(062,005,"Enviar relatório",oTelConf,{|| MsAguarde({|| gerRelLmUt(1) },"Aguarde","Gerando relatório...") },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

	oSlv	   := TButton():New(085,005,"Salvar relatório",oTelConf,{|| MsAguarde({|| gerRelLmUt(2) },"Aguarde","Gerando relatório...") },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGroup1    := TGroup():Create(oTelConf,115,005,135,120,"",,,.T.)

	oFechar    := TButton():New(120,075,"Fechar",oTelConf,{|| oTelConf:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTelConf:Activate(,,,.T.,{||.T.},,{||  })

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function cadEmail
	Cadastro de e-mail - relatório utilização de limites.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/
Static Function cadEmail()

	Local aArea 	:= GetArea()
	Local oTelCadEm
	Local oFechar
	Local oOk
	Local cEmails	:= GetMv("MV_#EMRLUL")
	Local oEmails
	Local oGroup1
	Local bOk		:= {|| PutMv("MV_#EMRLUL",cEmails), MsgInfo("Parâmetro salvo.","Função cadEmail"), oTelCadEm:End() }

	//
	cEmails := Alltrim(cValToChar(cEmails))
	cEmails := cEmails + Iif((200 - Len(cEmails)) < 0,"",Space((200 - Len(cEmails))))

	//
	oTelCadEm			:= MsDialog():Create()
	oTelCadEm:cName     := "oTelCadEm"
	oTelCadEm:cCaption  := "Cadastro de E-mail"
	oTelCadEm:nLeft     := 34
	oTelCadEm:nTop      := 222
	oTelCadEm:nWidth    := 400
	oTelCadEm:nHeight   := 190
	oTelCadEm:lShowHint := .F.
	oTelCadEm:lCentered := .T.

	oTxtBusca := TSay():New(010,005,{||"Por favor, informe os e-mail's que receberão o relatório."},oTelCadEm,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oEmails := TGet():New(020,005,{|u|If(PCount() == 0,cEmails,cEmails := u)},oTelCadEm,190,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmails",,,,.T.,,,"E-mail:",1)

	//
	oGroup1 := TGroup():Create(oTelCadEm,055,005,075,195,"",,,.T.)
	oOk		:= TButton():New(060,060,"Salvar"  ,oTelCadEm,{|| Eval(bOk) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar := TButton():New(060,105,"Cancelar",oTelCadEm,{|| oTelCadEm:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTelCadEm:Activate(,,,.T.,{||.T.},,{||  })

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function cadPorEsp
	Cadastro de e-mail - relatório utilização de limites.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function cadPorEsp()

	Local aArea 	:= GetArea()
	Local oTelCadEm
	Local oFechar
	Local oOk
	Local cPortadores	:= GetMv("MV_#PSRELF")
	Local oEmails
	Local oGroup1
	Local bOk		:= {|| PutMv("MV_#PSRELF",cPortadores), MsgInfo("Parâmetro salvo.","Função cadPorEsp"), oTelCadEm:End() }

	//
	cPortadores := Alltrim(cValToChar(cPortadores))
	cPortadores := cPortadores + Iif((200 - Len(cPortadores)) < 0,"",Space((200 - Len(cPortadores))))

	//
	oTelCadEm			:= MsDialog():Create()
	oTelCadEm:cName     := "oTelCadEm"
	oTelCadEm:cCaption  := "Cadastro de Portadores Especiais"
	oTelCadEm:nLeft     := 34
	oTelCadEm:nTop      := 222
	oTelCadEm:nWidth    := 400
	oTelCadEm:nHeight   := 190
	oTelCadEm:lShowHint := .F.
	oTelCadEm:lCentered := .T.

	oTxtBusca := TSay():New(010,005,{||"Por favor, informe os portadores especiais."},oTelCadEm,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oEmails := TGet():New(020,005,{|u|If(PCount() == 0,cPortadores,cPortadores := u)},oTelCadEm,190,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPortadores",,,,.T.,,,"Portadores:",1)

	//
	oGroup1 := TGroup():Create(oTelCadEm,055,005,075,195,"",,,.T.)
	oOk		:= TButton():New(060,060,"Salvar"  ,oTelCadEm,{|| Eval(bOk) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar := TButton():New(060,105,"Cancelar",oTelCadEm,{|| oTelCadEm:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTelCadEm:Activate(,,,.T.,{||.T.},,{||  })

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function gerRelLmUt
	Relatório utilização de limites.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function gerRelLmUt(nOpc)

	Local aArea		:= GetArea()
	Local oExcel 	:= FWMSEXCEL():New()
	Local cAssunto	:= "Relatório Utilização de Limites"
	Local cMensagem	:= "Segue anexo o relatório Utilização de Limites"
	Local cEmail	:= GetMv("MV_#EMRLUL")
	Local cPorEsp	:= Alltrim(cValToChar(GetMv("MV_#PSRELF")))
	Local cAtach	:= "\rel_fin\rel_uti_lmt.xml"
	Local cDir		:= ""
	Local cPorcent  := 0
	//

	

	cPorcent := FWInputBox("Informe a porcentagem Limite ex: 50,70 ou 100 porcento", "100") // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	

	cEmail := Alltrim(cValToChar(cEmail))
	If Empty(cEmail) .And. nOpc == 1
		MsgStop("Não há e-mail cadastrado.","Função gerRelLmUt")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If Empty(cPorEsp)
		MsgStop("Não há portador especial cadastrado.","Função gerRelLmUt")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	If nOpc == 2
		cDir := cGetFile("Relatório", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
		//
		If Empty(Alltrim(cValToChar(cDir)))
			Return Nil

		EndIf

	EndIf

	//
	MsAguarde({|| relRedes(oExcel,cPorcent) },"Aguarde","Gerando aba Redes...") // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	//
	MsAguarde({|| relClientes(oExcel,cPorcent) },"Aguarde","Gerando aba Clientes...") // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	oExcel:Activate()
	oExcel:GetXMLFile(cAtach)

	//
	If nOpc == 1
		MsAguarde({|| enviarEmail(cAssunto,cMensagem,cEmail,cAtach) },"Aguarde","Enviando e-mail...")

	ElseIf nOpc == 2

		If CpyS2T(cAtach,cDir,.F.)

			WinExec("Explorer.exe" + Space(1) + cDir )

			MsgInfo("Relatório gerado.","Função gerRelLmUt")

		Else

			MsgStop("Não foi possível gerar o relatório.","Função gerRelLmUt")

		EndIf

	EndIf

	//	
	Sleep(1000)
	FErase(cAtach)

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function relRedes
	Gera aba com os dados da redes.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function relRedes(oExcel,cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	Local aArea	 := GetArea()
	Local cQuery := ""

	//
	oExcel:AddworkSheet("Redes")
	oExcel:AddTable ("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE")

	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","COD REDE"      ,1,1)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","LIMITE CRÉDITO",3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","SLD RECEBER"   ,3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","VLR LIM EXC"   ,3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","% USO"         ,3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","À VENCER"      ,3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","VENCIDOS"      ,3,3)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","PORT ESP"      ,3,3)	
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","ATIVO"         ,1,1)
	oExcel:AddColumn("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE","DT VENC +ANTIGA",3,1)

	//
	If Select("REDES") > 0
		REDES->(DbCloseArea())

	EndIf

	cQuery := sqlRedes(cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"REDES",.T.,.F.) },"Aguarde","Obtendo dados de redes...")
	DbSelectArea("REDES")
	REDES->(DbGoTop())

	While ! REDES->(Eof())

		oExcel:AddRow("Redes","LIMITES UTILIZADOS - AGRUPADO POR REDE",;
		{REDES->ZF_REDE ,;
		REDES->LMT_CRED ,;
		REDES->SLD_RCB  ,;
		REDES->VLR_EXEC ,;
		REDES->PERC_EXEC,;
		REDES->VLR_ABT  ,;
		REDES->VLR_VENC ,;
		REDES->PORT_ESP ,;
		REDES->ATIVO,;
		REDES->DT_VENC})

		REDES->(DbSkip())

	EndDo

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function relClientes
	Gera aba com os dados dos clientes. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function relClientes(oExcel,cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	Local aArea	 := GetArea()
	Local cQuery := ""

	//
	oExcel:AddworkSheet("Clientes")
	oExcel:AddTable ("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES")

	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","CNPJ(Raiz)"    ,1,1)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","CLIENTE"       ,1,1)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","LIMITE CRÉDITO",3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","SLD RECEBER"   ,3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","VLR LIM EXC"   ,3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","% USO"         ,3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","À VENCER"      ,3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","VENCIDOS"      ,3,3)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","PORT ESP"      ,3,3)	
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","ATIVO"         ,1,1)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","COND PAG"      ,1,1)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","COD VEND"      ,1,1)
	oExcel:AddColumn("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES","DT VENC +ANTIGA"      ,3,1)

	//
	If Select("Clientes") > 0
		Clientes->(DbCloseArea())

	EndIf

	cQuery := sqlClientes(cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"Clientes",.T.,.F.) },"Aguarde","Obtendo dados de clientes...")
	DbSelectArea("Clientes")
	Clientes->(DbGoTop())

	While ! Clientes->(Eof())

		oExcel:AddRow("Clientes","LIMITES UTILIZADOS - AGRUPADO POR CLIENTES",;
		{Clientes->CNPJRAIZ ,;
		Clientes->CLIENTE ,;
		Clientes->LMT_CRED ,;
		Clientes->SLD_RCB  ,;
		Clientes->VLR_EXCED ,;
		Clientes->PERC_EXCED,;
		Clientes->VLR_ABERTO  ,;
		Clientes->VLR_VENCIDO ,;
		Clientes->PORT_ESP ,;
		Clientes->ATIVO,;
		Clientes->CONDPAG,;
		Clientes->A1_VEND,;
		Clientes->DT_VENC})

		Clientes->(DbSkip())

	EndDo

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function sqlRedes
	Script sql com os dados das redes.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlRedes(cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	Local aArea		:= GetArea()	
	Local cQuery	:= ""
	Local cPorEsp	:= Alltrim(cValToChar(GetMv("MV_#PSRELF")))
	Local aPorEsp	:= {}
	Local i			:= 1
	Local cStrPEsp	:= ""
	

	//Obtém códigos de portadores especiais.
	If ! Empty(cPorEsp)

		aPorEsp := StrToKarr(cPorEsp,"/")

		For i := 1 To Len(aPorEsp)

			cStrPEsp += "'" + Alltrim(cValToChar(aPorEsp[i])) + "',"

		Next i

		cStrPEsp := Substr(cStrPEsp,1,Len(cStrPEsp) - 1)

	EndIf


	//
	cQuery := ""
	cQuery += " SELECT   " 
	cQuery += " ZF_REDE,    " 
	cQuery += " MAX(ZF_LCREDE) AS LMT_CRED,    " 
	cQuery += " SUM(VLR_ABERTO+VLR_VENCIDO) AS SLD_RCB,    " 
	cQuery += " CASE WHEN (SUM(VLR_ABERTO+VLR_VENCIDO) - MAX(ZF_LCREDE)) > 0 THEN ( SUM(VLR_ABERTO+VLR_VENCIDO) - MAX(ZF_LCREDE)) ELSE 0 END AS VLR_EXEC ,   " 
	cQuery += " CASE WHEN SUM(VLR_ABERTO+VLR_VENCIDO) > 0 AND MAX(ZF_LCREDE) > 0 THEN ( SUM(VLR_ABERTO+VLR_VENCIDO)/ MAX(ZF_LCREDE))*100 ELSE 0 END AS PERC_EXEC,   " 
	cQuery += " SUM(VLR_ABERTO) AS VLR_ABT, SUM(VLR_VENCIDO) AS VLR_VENC,   " 
	cQuery += " SUM(VLR_PORT_ESP) AS PORT_ESP,   " 
	cQuery += " CASE WHEN SUM(CASE WHEN A1_MSBLQL = 'Não' THEN 1 ELSE 0 END) > 0 THEN 'Sim' ELSE 'Não' END AS ATIVO, " 
	cQuery += " MIN(DT_VENC) AS DT_VENC " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT         " 
	cQuery += " B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA, B_CLIENTE.A1_NOME, B_CLIENTE.A1_MSBLQL,         " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCER,0) AS VLR_ABERTO, ISNULL(B_TITULO.VRL_VENCIDO,0) AS VLR_VENCIDO,          " 
	cQuery += " B_CLIENTE.A1_VEND, B_REDE.ZF_REDE, B_REDE.ZF_LCREDE, ISNULL(B_TITULO.PORT_ESP,0) AS VLR_PORT_ESP,    " 
	cQuery += " CONVERT(VARCHAR(10),CAST((SELECT MIN(E1_EMISSAO) AS EMISSAO FROM " + RetSqlName("SE1") + " AS SE1 WHERE SE1.D_E_L_E_T_ = '' AND E1_SALDO > 0  AND (CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE)) AND E1_CLIENTE = B_CLIENTE.A1_COD AND E1_LOJA = B_CLIENTE.A1_LOJA AND E1_PORTADO NOT IN(" + cStrPEsp + ") AND E1_TIPO = 'NF') AS DATE),103) AS DT_VENC  " 
	cQuery += " FROM         " 
	cQuery += " (         " 
	cQuery += " SELECT          " 
	cQuery += " A1_COD,          " 
	cQuery += " A1_LOJA,          " 
	cQuery += " A1_NOME,           " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,          " 
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,         " 
	cQuery += " A1_VEND         " 
	cQuery += " FROM          " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1         " 
	cQuery += " WHERE          " 
	cQuery += " SA1.D_E_L_E_T_=''         " 
	cQuery += " AND A1_VEND <> ''         "  /* Alterado 15/05/2019 no Chamado 049215 - Por ADRIANO SAVOINE */
	cQuery += " ) AS B_CLIENTE         " 
	cQuery += " INNER JOIN         " 
	cQuery += " (         " 
	cQuery += " SELECT          " 
	cQuery += " ZF_CGCMAT, ZF_REDE,  MAX(ZF_LCREDE) AS ZF_LCREDE       " 
	cQuery += " FROM          " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF       " 
	cQuery += " INNER JOIN     " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1     " 
	cQuery += " ON ZF_CGCMAT = LEFT(A1_CGC,8)      " 
	cQuery += " WHERE          " 
	cQuery += " SZF.D_E_L_E_T_=''       " 
	cQuery += " GROUP BY         " 
	cQuery += " ZF_CGCMAT, ZF_REDE         " 
	cQuery += " ) AS B_REDE         " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT         " 
    cQuery += " LEFT JOIN        " // CHAMADO 053260 - WILLIAM COSTA - 11/11/2019 - Ajustado para poder trazer indiferente se o cnpj que tem o limite está devendo no financeiro ou não
	cQuery += " (         " 
	cQuery += " SELECT          " 
	cQuery += " E1_CLIENTE,          " 
	cQuery += " E1_LOJA,          " 

	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) AND E1_PORTADO NOT IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS VRL_VENCIDO,       " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) AND E1_PORTADO NOT IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS VRL_VENCER,   " 
	cQuery += " SUM(CASE WHEN  E1_PORTADO IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS PORT_ESP      " 

	cQuery += " FROM          " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1         " 
	cQuery += " WHERE          " 
	cQuery += " SE1.D_E_L_E_T_= ''          " 
	cQuery += " AND E1_SALDO > 0          " 
	cQuery += " AND E1_PORTADO <> 'P13'         " 
	cQuery += " AND E1_TIPO IN ('NF')         " 
	cQuery += " GROUP BY       " 
	cQuery += " E1_CLIENTE,          " 
	cQuery += " E1_LOJA          " 
	cQuery += " ) AS B_TITULO         " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE         " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA           " 
	cQuery += " WHERE    " 
	cQuery += " B_REDE.ZF_REDE IN     " 
	cQuery += " (    " 
	cQuery += " SELECT         " 
	cQuery += " DISTINCT ZF_REDE       " 
	cQuery += " FROM         " 
	cQuery += " " + RetSqlName("SZF") + "  (NOLOCK) SZF      " 
	cQuery += " INNER JOIN    " 
	cQuery += " SA1010  (NOLOCK) SA1    " 
	cQuery += " ON ZF_CGCMAT = LEFT(A1_CGC,8)     " 
	cQuery += " WHERE         " 
	cQuery += " SZF.D_E_L_E_T_ = ''      " 
	cQuery += " )     " 
	cQuery += " ) AS FONTE   " 
	cQuery += " GROUP BY   " 
	cQuery += " FONTE.ZF_REDE   " 
	cQuery += " HAVING   " 
	cQuery += " SUM(VLR_ABERTO+VLR_VENCIDO) > 0   " 
	cQuery += " AND ((CASE WHEN SUM(VLR_ABERTO+VLR_VENCIDO) > 0 AND MAX(ZF_LCREDE) > 0 THEN ( SUM(VLR_ABERTO+VLR_VENCIDO)/ MAX(ZF_LCREDE))*100 ELSE 0 END) >= "+cPorcent+" )  " // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021
	cQuery += " ORDER BY   " 
	cQuery += " PERC_EXEC DESC,FONTE.ZF_REDE " 

	//
	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function sqlCliente
	Script sql com os dados dos clientes.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function sqlClientes(cPorcent) // Ticket  14417  - ADRIANO SAVOINE - 31/05/2021

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cPorEsp	:= Alltrim(cValToChar(GetMv("MV_#PSRELF")))
	Local aPorEsp	:= {}
	Local i			:= 1
	Local cStrPEsp	:= ""
	

	//Obtém códigos de portadores especiais.
	If ! Empty(cPorEsp)

		aPorEsp := StrToKarr(cPorEsp,"/")

		For i := 1 To Len(aPorEsp)

			cStrPEsp += "'" + Alltrim(cValToChar(aPorEsp[i])) + "',"

		Next i

		cStrPEsp := Substr(cStrPEsp,1,Len(cStrPEsp) - 1)

	EndIf

	//
	cQuery := ""
	cQuery += " SELECT       " 
	cQuery += " SUBSTRING(B_CLIENTE.A1_CGC,1,8) AS CNPJRAIZ, " 
	cQuery += " RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE,   " 
	cQuery += " B_CLIENTE.A1_LC AS LMT_CRED, " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0) AS SLD_RCB, " 
	cQuery += " CASE WHEN (ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0) - B_CLIENTE.A1_LC ) > 0 THEN (ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0) - B_CLIENTE.A1_LC ) ELSE 0 END AS VLR_EXCED, " 
	cQuery += " CASE WHEN B_CLIENTE.A1_LC > 0 THEN ((ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0))/B_CLIENTE.A1_LC)*100 ELSE 0 END AS PERC_EXCED, " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCER,0) AS VLR_ABERTO, " 
	cQuery += " ISNULL(B_TITULO.VRL_VENCIDO,0) AS VLR_VENCIDO, " 
	cQuery += " ISNULL(B_TITULO.PORT_ESP,0) AS PORT_ESP, " 
	cQuery += " B_CLIENTE.A1_MSBLQL AS ATIVO, " 
	cQuery += " B_CLIENTE.A1_COND AS CONDPAG, B_CLIENTE.A1_VEND,  " 
	cQuery += " CONVERT(VARCHAR(10),CAST((SELECT MIN(E1_EMISSAO) AS EMISSAO FROM " + RetSqlName("SE1") + " AS SE1 WHERE SE1.D_E_L_E_T_ = '' AND E1_SALDO > 0  AND (CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE)) AND E1_XCGC = SUBSTRING(B_CLIENTE.A1_CGC,1,8) AND E1_PORTADO NOT IN(" + cStrPEsp + ") AND E1_TIPO = 'NF') AS DATE),103) AS DT_VENC  " 
	cQuery += " FROM       " 
	cQuery += " (       " 
	cQuery += " SELECT   " 
	cQuery += " A1_CGC,      " 
	cQuery += " A1_COD,        " 
	cQuery += " A1_LOJA,        " 
	cQuery += " A1_NOME,         " 
	cQuery += " LEFT(A1_CGC,8) AS RAIZ_CGC,        " 
	cQuery += " CASE WHEN A1_MSBLQL = '2' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL,       " 
	cQuery += " A1_VEND,   " 
	cQuery += " A1_LC, " 
	cQuery += " A1_COND  " 
	cQuery += " FROM        " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1       " 
	cQuery += " WHERE        " 
	cQuery += " SA1.D_E_L_E_T_=''       " 
	cQuery += " AND A1_VEND <> '' "  /* Alterado 15/05/2019 no Chamado 049215 - Por ADRIANO SAVOINE */
	cQuery += " AND A1_CGC <> ''       " 
	cQuery += " ) AS B_CLIENTE       " 
	cQuery += " LEFT OUTER JOIN      " 
	cQuery += " (       " 
	cQuery += " SELECT        " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE       " 
	cQuery += " FROM        " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF       " 
	cQuery += " WHERE        " 
	cQuery += " SZF.D_E_L_E_T_=''       " 
	cQuery += " GROUP BY       " 
	cQuery += " ZF_CGCMAT, ZF_REDE       " 
	cQuery += " ) AS B_REDE       " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT       " 
	cQuery += " INNER JOIN      " 
	cQuery += " (       " 
	cQuery += " SELECT        " 
	cQuery += " E1_CLIENTE,        " 
	cQuery += " E1_LOJA,        " 

	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE)  < CAST(GETDATE() AS DATE) AND E1_PORTADO NOT IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS VRL_VENCIDO,     " 
	cQuery += " SUM(CASE WHEN  CAST(E1_VENCREA AS DATE) >= CAST(GETDATE() AS DATE) AND E1_PORTADO NOT IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS VRL_VENCER, " 
	cQuery += " SUM(CASE WHEN  E1_PORTADO IN(" + cStrPEsp + ") THEN E1_SALDO ELSE 0 END) AS PORT_ESP      " 

	cQuery += " FROM        " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1       " 
	cQuery += " WHERE        " 
	cQuery += " SE1.D_E_L_E_T_= ''        " 
	cQuery += " AND E1_SALDO > 0        " 
	cQuery += " AND E1_PORTADO <> 'P13'       " 
	cQuery += " AND E1_TIPO IN ('NF')       " 
	cQuery += " GROUP BY     " 
	cQuery += " E1_CLIENTE,        " 
	cQuery += " E1_LOJA        " 
	cQuery += " ) AS B_TITULO       " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE       " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA       " 
	cQuery += " WHERE       " 
	cQuery += " ZF_REDE IS NULL    " 
	cQuery += " AND ((CASE WHEN B_CLIENTE.A1_LC > 0 THEN ((ISNULL(B_TITULO.VRL_VENCER,0)+ISNULL(B_TITULO.VRL_VENCIDO,0))/B_CLIENTE.A1_LC)*100 ELSE 0 END) >= "+cPorcent+"  ) "  //Ticket  14417  - ADRIANO SAVOINE - 31/05/2021
	cQuery += " ORDER BY       " 
	cQuery += " PERC_EXCED DESC, CNPJRAIZ " 

	//
	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} Static Function enviarEmail
	Envia e-mail.
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function enviarEmail(cAssunto,cMensagem,cEmail,cAtach)

	Local aArea			 := GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := cEmail
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
	Local cSubject      := ""

	//Assunto do e-mail.
	cSubject := cAssunto

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)

		Else
			lAutOk := .T.

		EndIf

	EndIf

	If lOk .And. lAutOk   

		//Envia o e-mail.     
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  

		//Tratamento de erro no envio do e-mail.          
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)

		EndIf

	Else
		Get Mail Error cErrorMsg
		ConOut("Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server

	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function logAcesso
	Log de acesso de rotina. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function logAcesso(cRotina)

	Local aArea		:= GetArea()

	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
	ZBE->ZBE_FILIAL := xFilial("SE1")
	ZBE->ZBE_DATA	:= Date()
	ZBE->ZBE_HORA	:= cValToChar(Time())
	ZBE->ZBE_USUARI	:= cUserName
	ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
	ZBE->ZBE_MODULO	:= "FINANCEIRO"
	ZBE->ZBE_ROTINA	:= "ADFIN030P"
	MsUnlock()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function grLRCCSV
	Gera aquivo CSV. 
	@type  Function
	@author Everson
	@since 11/05/2017
	@version version
/*/

Static Function grLRCCSV(oRegistros,aHReg,cArq)

	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grLRCCSV")
		Return Nil

	EndIf

	//
	cLin := ""
	For i := 1 To Len(aHReg)
		cLin += cValToChar(aHReg[i][1]) + ";"

	Next i

	cLin += cEof

	For i := 1 To Len(oRegistros:aCols)

		For w := 1 To Len(aHReg)

			If Alltrim(cValToChar(aHReg[w][8])) == "N"

				cLin += Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + ";"

			Else
				cLin += cValToChar(oRegistros:aCols[i][w]) + ";"

			EndIf

		Next w

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função grLRCCSV")

	RestArea(aArea)

Return Nil
