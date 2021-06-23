#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Fileio.ch"
/*/{Protheus.doc} User Function ADFIN059P
	Rotina para alteração do código do banco no cadastro do cliente.
	@type  Function
	@author Fernando Sigoli 
	@since 09/07/2018
	@version 01
	@history, 11/12/2018, William Costa - 044944 - acrescentar Loja na
	Regra para alterar o Cliente, Adicionado Log, ajuste botao
	restaurar, adicionar botao Total ver numero BCO.
	@history, 08/07/2020, Everson, Chamado: 059490. Rotina para geração de log de alteração de banco.
	/*/
User Function ADFIN059P() // U_ADFIN059P()

	Local aArea 	  := GetArea()
	Local oInterface
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oGroup4
	Local oFiltro
	Local oBtnFiltro
	Local oGroup2
	Local oFechar
	
	Local oTodos
	Local oAtualizar
	Local oRestaurar
	Local oAplicar
	Local oBCAlt
	
	Private oClientes
	
	Private cBCAlt	 := Space(TamSX3("A6_COD")[1])
	Private cArq	 := ""
	Private stru	 := {}
	Private aCpoBro	 := {}
	Private lInverte := .F.
	Private cMark    := GetMark()
	Private cFiltro	 := Space(TamSX3("A6_COD")[1])
	Private oTotCli
	Private nTotCli	 := 0
	
	Private cBuscaCli:= Space(6)
	Private oBuscaCli
	Private oBtnBscCli
	
	Private aSelBusca:= {}
	Private cSelBusca:= ""
	Private oSelBusca
	
	Private dDtDe := Date()+1
	Private dDtAt := Date()+1
	Private oDtDe
	Private oDtAt
	
	Private oTotVlr
	Private nTotVlr := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para alteração do código do banco no cadastro do cliente.')

	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Alteração de Banco"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1000
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
	//
	oGroup1 := TGroup():Create(oInterface,005,005,035,495,"",,,.T.)
	
	oBuscaCli := TGet():New(010,010,{|u|If(PCount() == 0,cBuscaCli,cBuscaCli := u)},oInterface,40,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBuscaCli",,,,.T.,,,"Busca cliente:",1)
	oBtnBscCli:= TButton():New(018,055,"Ok",oInterface,{|| Iif( Valtype(oClientes) == "O",;
	MsAguarde({|| bscCli(@oClientes,cBuscaCli) },"Aguarde","Localizando " + cBuscaCli + "..."),;
	MsgStop("Não há dados carregados.","Função ADFIN059P"))  },018,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//oBtnFiltro  := TButton():New(018,135,"Ok",oInterface,,18,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oBtnFiltro:bAction := {|| MsAguarde({|| carrArq(@cFiltro,@oClientes,@oInterface) },"Aguarde","Carregando dados...") }
	
	//
	oBCAlt   := TGet():New(010,185,{|u|If(PCount() == 0,cBCAlt,cBCAlt := u)},oInterface,020,010,"@C",{|| Iif(Empty(Alltrim(cValToChar(cBCAlt))),.T.,ExistCpo("SA6",cBCAlt)) },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBCAlt",,,,.T.,,,"Aplicar banco:",1)
	oBCAlt:bF3 := &('{|| IIf(ConPad1(,,,"SA6",,,.F.),Eval({|| cBCAlt := SA6->A6_COD,oBCAlt:Refresh()}),.T.)}')
	
	oAplicar    := TButton():New(018,220,"Alterar"  ,oInterface,{|| altRest(@cBCAlt,@cFiltro,@oClientes,1,@oInterface) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRestaurar	:= TButton():New(018,265,"Restaurar",oInterface,{|| altRest(@cBCAlt,@cFiltro,@oClientes,2,@oInterface) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//
	oGroup3 := TGroup():Create(oInterface,040,005,234,400,"",,,.T.)
	
	//Cria arquivo strutura.
	stru := {}
	Aadd(stru,{"OK"        ,"C",02	,0})
	Aadd(stru,{"A1_COD"    ,"C"	,TamSX3("A1_COD")[1]  ,0})
	Aadd(stru,{"A1_LOJA"   ,"C"	,TamSX3("A1_LOJA")[1]  ,0}) // 044944
	Aadd(stru,{"A1_NOME"   ,"C"	,TamSX3("A1_NOME")[1] ,0})
	Aadd(stru,{"A1_BCO1"   ,"C"	,TamSX3("A1_BCO1")[1] ,0})
	Aadd(stru,{"A1_XBCOO"  ,"C"	,TamSX3("A1_BCO1")[1],0})
	Aadd(stru,{"A1_CODRED" ,"C"	,TamSX3("A1_CODRED")[1],0}) //045787
	Aadd(stru,{"ATIVO"     ,"C"	,3})
	
	//Cria tabela temporária.
	cArq := Criatrab(,.F.)
	MsCreate(cArq,stru,"DBFCDX")
	
	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArq,"TTRAG",.T.,.F.)
	
	//
	aCpoBro := {}
	Aadd(aCpoBro,{"OK"       ,, "Mark"})
	Aadd(aCpoBro,{"A1_COD"   ,,"Cliente"})
	Aadd(aCpoBro,{"A1_LOJA"  ,,"Loja"}) // 044944
	Aadd(aCpoBro,{"A1_NOME"  ,,"Nome"})
	Aadd(aCpoBro,{"A1_BCO1"  ,,"Banco"})
	Aadd(aCpoBro,{"A1_XBCOO" ,,"Banco Orig."})
	Aadd(aCpoBro,{"A1_CODRED",,"Rede"}) //045787
	Aadd(aCpoBro,{"ATIVO"    ,,"Ativo"})
	
	RecLock("TTRAG",.T.)
	
	TTRAG->A1_COD    := ""
	TTRAG->A1_LOJA   := "" // 044944
	TTRAG->A1_NOME   := ""
	TTRAG->A1_BCO1   := ""
	TTRAG->A1_XBCOO  := ""
	TTRAG->A1_CODRED := "" //045787
	TTRAG->ATIVO     := ""
	
	TTRAG->(MsUnlock())
	
	oClientes := MsSelect():New("TTRAG","OK","",aCpoBro ,@lInverte,@cMark ,{040,005,234,400},,,oInterface,,)
	oClientes:bMark := {| | DispFxAtr(@oClientes,@cMark) }
	oClientes:oBrowse:bAllMark := {|| FxAtrInvert(@oClientes,@cMark) }
	
	//
	oGroup4 := TGroup():Create(oInterface,040,405,234,495,"",,,.T.)
	
	/*
	oDtDe := TGet():New(050,410,{|u|If(PCount() == 0,dDtDe,dDtDe := u)},oInterface,050,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtDe",,,,.T.,,,"Data entr. de:",1)
	oDtAt := TGet():New(080,410,{|u|If(PCount() == 0,dDtAt,dDtAt := u)},oInterface,050,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtAt",,,,.T.,,,"Data entr. até:",1)
	*/
	
	aSelBusca := {"1=Ativos","2=Bloqueados","3=Todos"}
	cSelBusca := aSelBusca[1]
	oSelBusca := TComboBox():New(075,410,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
	aSelBusca,065,22,oInterface,,,,,,.T.,,,,,,,,,'cSelBusca')
		
	//oFiltro     := TGet():New(111,410,{|u|If(PCount() == 0,cFiltro,cFiltro := u)},oInterface,020,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFiltro",,,,.T.,,,"Filtro banco:",1)
	oFiltro     := TGet():New(050,410,{|u|If(PCount() == 0,cFiltro,cFiltro := u)},oInterface,020,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFiltro",,,,.T.,,,"Filtro banco:",1)
	oFiltro:bF3 := &('{|| IIf(ConPad1(,,,"SA6",,,.F.),Eval({|| cFiltro := SA6->A6_COD,oFiltro:Refresh()}),.T.)}')
	
	TButton():New(170,410,"Log",  oInterface,{|| MsAguarde({|| grlLog() },"Função ADFIN059P(ADFIN059P)",) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson, 08/07/2020. Chamado 059490.
	oAtualizar	:= TButton():New(185,410,"Filtrar",  oInterface,{|| MsAguarde({|| carrArq(@cFiltro,@oClientes,@oInterface,"FILTRAR") },"Aguarde","Filtrando clientes...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTodos   	:= TButton():New(200,410,"Todos",    oInterface,{|| MsAguarde({|| carrArq(@cFiltro,@oClientes,@oInterface) },"Aguarde","Carregando todos os clientes...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCSV	    := TButton():New(215,410,"CSV"      ,oInterface,{|| MsAguarde({|| grCSV() },"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oTotBco	    := TButton():New(180,410,"Total Bco",oInterface,{|| MsAguarde({|| totBco() },"Aguarde","Gerando interface...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//
	oGroup2	 := TGroup():Create(oInterface,239,005,260,495,"",,,.T.)
	
	oTotCli  := TGet():New(245,010,{|u|If(PCount() == 0,nTotCli,nTotCli := u)},oInterface,050,010,"@E 999,999,999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotCli",,,,.T.,,,"Total registros:",2)
	
	//oTotVlr  := TGet():New(245,100,{|u|If(PCount() == 0,nTotVlr,nTotVlr := u)},oInterface,080,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotVlr",,,,.T.,,,"Valor Total:",2)
	
	oFechar	 := TButton():New(245,450,"Fechar",oInterface,{||oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")
	
	oInterface:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| carrArq("",@oClientes,@oInterface,"ATIVOS") },"Aguarde","Carregando clientes ativos...") })
	
	//
	If Select("TTRAG") > 0
		TTRAG->(DbCloseArea())
		
	EndIf
	
	//
	FErase( cArq + GetDBExtension() )
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} totBco
	Total por banco. Chamado 038276.
	@type  Static Function
	@author Everson
	@since 07/12/2017
	@version 01
	/*/
Static Function totBco()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local cQuery	:= scriptSql("",2)
	Local aColsDt	:= {}
	Local aBrowse	:= {}
	Local cNmBanco	:= ""
	Local oFechar
	Local oIntBco
	Local oFechar
	Local oTotVlrBco
	Local nTotVlrBco	:= 0
	
	//
	If Select("D_BANCOS") > 0
		D_BANCOS->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "D_BANCOS"
	DbSelectArea("D_BANCOS")
	D_BANCOS->(DbGoTop())
	
	//
	If D_BANCOS->(Eof())
		Aadd(aBrowse,{"","",0})
		
	EndIf
	
	//
	While ! D_BANCOS->(Eof())
		
		cNmBanco := Posicione("SA6",1,xFilial("SA6") + D_BANCOS->A1_BCO1, "A6_NOME"  )
		
		Aadd(aBrowse,{D_BANCOS->A1_BCO1,cNmBanco,D_BANCOS->TOTAL})
		
		nTotVlrBco += Val(cValToChar(D_BANCOS->TOTAL))
		
		D_BANCOS->(DbSkip())
	EndDo
	D_BANCOS->(DbCloseArea())
	
	//
	oIntBco			 := MsDialog():Create()
	oIntBco:cName     := "oIntBco"
	oIntBco:cCaption  := "Saldo por Banco"
	oIntBco:nLeft     := 34
	oIntBco:nTop      := 222
	oIntBco:nWidth    := 400
	oIntBco:nHeight   := 290
	oIntBco:lShowHint := .F.
	oIntBco:lCentered := .T.
	
	// Cria Browse.
	aColsDt := colunaBrw()
	oBrowse := TCBrowse():New(005,005, 190, 100,, aColsDt,{20,50,50,50}, oIntBco,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
	// Seta vetor para a browse
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{;
	aBrowse[oBrowse:nAt,01],;
	aBrowse[oBrowse:nAt,02],;
	Transform(aBrowse[oBrowse:nAt,03],'@E 999,999,999.99');
	} }
	
	oBrowse:DrawSelect()
	oBrowse:GoTop()
	
	oTotVlrBco  := TGet():New(115,005,{|u|If(PCount() == 0,nTotVlrBco,nTotVlrBco := u)},oIntBco,080,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotVlrBco",,,,.T.,,,"Valor Total:",2)
	
	oFechar	 := TButton():New(115,155,"Fechar",oIntBco,{||oIntBco:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oIntBco:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} colunaBrw
	Retorna colunas do objeto TCBrowse. Chamado 038276.
	@type  Static Function
	@author Everson
	@since 07/12/2017
	@version 01
	/*/
Static Function colunaBrw()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local aColunas	:= {}
	
	aColunas := {'Código banco','Nome','Ativo'}
	
	//
	RestArea(aArea)

Return aColunas
/*/{Protheus.doc} bscCli
	Busca cliente na MsSelect. Chamado 038276.
	@type  Static Function
	@author Everson
	@since 07/12/2017
	@version 01
	/*/
Static Function bscCli(oClientes,cCodigo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea := GetArea()
	Local i		:= 1
	Local nAux	:= 1
	Local nPos	:= 1
	Local nPosAt:= oClientes:oBrowse:nAt
	
	//
	cCodigo := Alltrim(cValToChar(cCodigo))
	
	//
	If Empty(cCodigo)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Select("TTRAG") <= 0
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	DbSelectArea("TTRAG")
	TTRAG->(DbGoTop())
	
	//
	While ! TTRAG->(Eof())
		
		If cCodigo $(Alltrim(cValToChar(TTRAG->A1_COD)))
			nPos := nAux
			Exit
			
		EndIf
		
		TTRAG->(DbSkip())
		
		nAux++
		
	EndDo
	
	//
	If nPos <= 0
		MsgStop("Registro não encontrado.","Função bscCli")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	nPosAt := nPosAt - nPos
	
	//
	If (nPosAt) <> 0
		
		If nPosAt > 0
			
			For i := 1 To nPosAt
				oClientes:oBrowse:GoDown()
				
			Next i
			
		Else
			
			For i := 1 To nPosAt
				oClientes:oBrowse:GoUp()
				
			Next i
			
		EndIf
		
	EndIf

Return Nil
/*/{Protheus.doc} altRest
	Busca cliente na MsSelect. Chamado 038276.
	@type  Static Function
	@author Everson
	@since 07/12/2017
	@version 01
	/*/
Static Function altRest(cBCAlt,cFiltro,oClientes,nOpc,oInterface)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea := GetArea()
	Local aReg	:= {}
	
	//
	//cFiltro:= Alltrim(cValToChar(cFiltro))
	//cBCAlt := Alltrim(cValToChar(cBCAlt))
	
	//
	DbSelectArea("TTRAG")
	TTRAG->(DbGoTop())
	While ! TTRAG->(Eof())
		
		//
		If (! Empty(Alltrim(cValToChar(TTRAG->OK))) .And. nOpc == 1 .And. ( Alltrim(cValToChar(TTRAG->A1_BCO1)) <> Alltrim(cValToChar(cBCAlt)) ) ) .Or.;
			(! Empty(Alltrim(cValToChar(TTRAG->OK))) .And. nOpc == 2 .And. ! Empty(Alltrim(cValToChar(TTRAG->A1_XBCOO))) )
			
			Aadd(aReg,{TTRAG->A1_COD,TTRAG->A1_LOJA,cBCAlt})
			
		EndIf
		
		TTRAG->(DbSkip())
		
	EndDo
	TTRAG->(DbGoTop())
	
	//
	If Len(aReg) <= 0
		MsgStop("Não há registros a serem processados.","Função altRest")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! MsgYesNo("Será(ão) processado(s) " + cValToChar(Len(aReg)) + " registro(s). Deseja prosseguir?")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	Processa({|| process(@aReg,@nOpc) },"Alterando portador nas tabelas SA1 e PB3...")
	
	//
	MsAguarde({|| carrArq(@cFiltro,@oClientes,@oInterface,"ATIVOS") },"Aguarde","Carregando todos os clientes...")
	
	//
	MsgInfo("Registro(s) processado(s).","Função altRest")
	
	//
	//If Empty(cFiltro)
		cFiltro := Space(TamSX3("A6_COD")[1])
		
	//EndIf
	
	//
	//If Empty(cBCAlt)
		cBCAlt := Space(TamSX3("A6_COD")[1])
		
	//EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} process
	Altera banco no cadastro. Chamado 038276.
	@type  Static Function
	@author Everson
	@since 05/12/2017
	@version 01
	/*/
Static Function process(aReg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local i		:= 1
	
	//
	ProcRegua(Len(aReg))
	
	//
	For i := 1 To Len(aReg)
		
		IncProc("Cliente " + Alltrim(cValToChar(aReg[i][1])) )
		
		Begin Transaction
		
		If alteraPB3(Alltrim(cValToChar(aReg[i][1])),Alltrim(cValToChar(aReg[i][2])),Alltrim(cValToChar(aReg[i][3])),nOpc) // Altera PB3.
			
			If ! alteraSA1(Alltrim(cValToChar(aReg[i][1])),Alltrim(cValToChar(aReg[i][2])),Alltrim(cValToChar(aReg[i][3])),nOpc) // Altera SA1.
				
				DisarmTransaction()
				Break
				
			EndIf
			
		Else
			
			DisarmTransaction()
			Break
			
		EndIf
		
		End Transaction
		
	Next i

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} alteraSA1
	Altera cadastro SA1.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 08/12/2017
	@version 01
	/*/
Static Function alteraSA1(cCodigo,cLoja,cBanco,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea  := GetArea()
	Local cBCO1  := '' 
	Local cXBCOO := '' 
	
	//
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	
	//Altera cadastro SA1.
	If ! SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja))
		MsgStop("Não foi possível localizar o cliente " + cCodigo + '||' + cLoja + "(SA1).","Função alteraSA1")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	While ! SA1->(Eof()) .And. Alltrim(cValToChar(SA1->A1_COD)) == cCodigo .And. Alltrim(cValToChar(SA1->A1_LOJA)) == cLoja
	
		cBCO1  := SA1->A1_BCO1 
	    cXBCOO := SA1->A1_XBCOO
		
		If nOpc == 1
			
			//Log.
			RecLock("ZBE",.T.)
			
				ZBE->ZBE_FILIAL := xFilial("ZBE")
				ZBE->ZBE_DATA	:= Date()
				ZBE->ZBE_HORA	:= cValToChar(Time())
				ZBE->ZBE_USUARI	:= cUserName
				ZBE->ZBE_LOG	:= "A1_COD: " + SA1->A1_COD + " A1_LOJA: " + SA1->A1_LOJA + " ALTERACAO DE REGISTRO SA1 A1_BCO1 DE " + SA1->A1_BCO1 + " PARA " + cBanco + " CAMPO 2 A1_XBCOO DE: " + SA1->A1_XBCOO + " PARA: " + Iif(Empty(Alltrim(cValToChar(SA1->A1_BCO1))),"BBB",SA1->A1_BCO1)
				ZBE->ZBE_MODULO	:= "FINANCEIRO"
				ZBE->ZBE_ROTINA	:= "ADFIN059P"
			
			MsUnlock()
			
			RecLock("SA1",.F.)
			
				Replace SA1->A1_XBCOO With Iif(Empty(Alltrim(cValToChar(SA1->A1_BCO1))),"BBB",SA1->A1_BCO1)
				Replace SA1->A1_BCO1  With cBanco
			
			MsUnlock()
			
		ElseIf nOpc == 2
			
			//Log.
			RecLock("ZBE",.T.)
			
				ZBE->ZBE_FILIAL := xFilial("ZBE")
				ZBE->ZBE_DATA	:= Date()
				ZBE->ZBE_HORA	:= cValToChar(Time())
				ZBE->ZBE_USUARI	:= cUserName
				ZBE->ZBE_LOG	:= "A1_COD: " + SA1->A1_COD + " A1_LOJA: " + SA1->A1_LOJA + " RESTAURACAO DE REGISTRO SA1 A1_BCO1 DE: " + SA1->A1_BCO1 + " PARA: " + IIF(ALLTRIM(cXBCOO) == "",cBCO1,cXBCOO) + " CAMPO 2 A1_XBCOO DE: " + SA1->A1_XBCOO + " PARA: " + cBCO1 
				ZBE->ZBE_MODULO	:= "FINANCEIRO"
				ZBE->ZBE_ROTINA	:= "ADFIN059P"
			
			MsUnlock()
			
			RecLock("SA1",.F.)
			
				Replace SA1->A1_BCO1  With IIF(ALLTRIM(cXBCOO) == "",cBCO1,cXBCOO)
				Replace SA1->A1_XBCOO With cBCO1
			
			MsUnlock()
			
		EndIf
		
		SA1->(DbSkip())
		
	EndDo
	
	SA1->(DbCloseArea())
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} alteraPB3
	Altera cadastro PB3.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 08/12/2017
	@version 01
	/*/
Static Function alteraPB3(cCodigo,cLoja,cBanco,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea  := GetArea()
	Local cBCO1  := '' 
	Local cXBCOO := '' 
	
	//
	DbSelectArea("PB3")
	PB3->(DbSetOrder(11))
	PB3->(DbGoTop())
	
	//Altera cadastro PB3.
	If ! PB3->(DbSeek(xFilial("PB3") + cCodigo + cLoja))
		MsgStop("Não foi possível localizar o cliente " + cCodigo + '||' + cLoja + "(PB3).","Função alteraPB3")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	While ! PB3->(Eof()) .And. Alltrim(cValToChar(PB3->PB3_CODSA1)) == cCodigo .And. Alltrim(cValToChar(PB3->PB3_LOJSA1)) == cLoja
		
		cBCO1  := PB3->PB3_BCO1 
	    cXBCOO := PB3->PB3_BCOO
	    
		If nOpc == 1
			
			//Log.
			RecLock("ZBE",.T.)
			
				ZBE->ZBE_FILIAL := xFilial("ZBE")
				ZBE->ZBE_DATA	:= Date()
				ZBE->ZBE_HORA	:= cValToChar(Time())
				ZBE->ZBE_USUARI	:= cUserName
				ZBE->ZBE_LOG	:= "PB3_CODSA1: " + PB3->PB3_CODSA1 + " PB3_LOJSA1: " + PB3->PB3_LOJSA1 + " ALTERACAO DE REGISTRO PB3 PB3_BCO1 DE " + PB3->PB3_BCO1 + " PARA " + cBanco + " CAMPO 2 PB3_BCOO DE: " + PB3->PB3_BCOO + " PARA: " + Iif(Empty(Alltrim(cValToChar(PB3->PB3_BCO1))),"BBB",PB3->PB3_BCO1)
				ZBE->ZBE_MODULO	:= "FINANCEIRO"
				ZBE->ZBE_ROTINA	:= "ADFIN059P"
			
			MsUnlock()
			
			RecLock("PB3",.F.)
			
				Replace PB3_BCOO With Iif(Empty(Alltrim(cValToChar(PB3->PB3_BCO1))),"BBB",PB3->PB3_BCO1)
				Replace PB3_BCO1 With cBanco
			
			MsUnlock()
			
		ElseIf nOpc == 2
			
			//Log.
			RecLock("ZBE",.T.)
			
				ZBE->ZBE_FILIAL := xFilial("ZBE")
				ZBE->ZBE_DATA	:= Date()
				ZBE->ZBE_HORA	:= cValToChar(Time())
				ZBE->ZBE_USUARI	:= cUserName
				ZBE->ZBE_LOG	:= "PB3_CODSA1: " + PB3->PB3_CODSA1 + " PB3_LOJSA1: " + PB3->PB3_LOJSA1 + " RESTAURACAO DE REGISTRO PB3 PB3_BCO1 DE " + PB3->PB3_BCO1 + " PARA " + Iif(PB3->PB3_BCOO == "BBB","",PB3->PB3_BCOO) + " CAMPO 2 PB3_BCOO DE: " + PB3->PB3_BCOO + " PARA: " + Iif(Empty(Alltrim(cValToChar(PB3->PB3_BCO1))),"BBB",PB3->PB3_BCO1)
				ZBE->ZBE_MODULO	:= "FINANCEIRO"
				ZBE->ZBE_ROTINA	:= "ADFIN059P"
			
			MsUnlock()
			
			RecLock("PB3",.F.)
				
				Replace PB3_BCO1 With IIF(ALLTRIM(cXBCOO) == "",cBCO1,cXBCOO)
				Replace PB3_BCOO With cBCO1
			
			MsUnlock()
			
		EndIf
		
		PB3->(DbSkip())
		
	EndDo
	
	PB3->(DbCloseArea())
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} carrArq
	Carrega os registros na MsSelect.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 05/12/2017
	@version 01
	/*/
Static Function carrArq(cBanco,oClientes,oInterface,cFiltro)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local aClientes	:= {}
	Local i			:= 1
	Local cQuery	:= ""
	
	Default cFiltro := ""
	
	//
	If Select("TTRAG") > 0
		TTRAG->(DbCloseArea())
		FErase( cArq + GetDBExtension() )
		
	EndIf
	
	//
	nTotCli:= 0
	nTotVlr:= 0
	oTotCli:Refresh()
	//oTotVlr:Refresh()
	
	//
	cQuery := scriptSql(cBanco, , cFiltro)
	
	//
	If Select("D_CLIENTES") > 0
		D_CLIENTES->(DbCloseArea())
		
	EndIf
	
	//Obtém os dados das visistas.
	TcQuery cQuery New Alias "D_CLIENTES"
	DbSelectArea("D_CLIENTES")
	D_CLIENTES->(DbGoTop())
	While ! D_CLIENTES->(Eof())
		
		Aadd(aClientes,{D_CLIENTES->A1_COD,D_CLIENTES->A1_LOJA,D_CLIENTES->A1_NOME,D_CLIENTES->A1_BCO1,D_CLIENTES->A1_XBCOO,D_CLIENTES->A1_CODRED,D_CLIENTES->ATIVO})
		
		//
		nTotCli++
		//
		D_CLIENTES->(DbSkip())
		
	EndDo
	
	D_CLIENTES->(DbCloseArea())
	
	//Cria arquivo strutura.
	stru := {}
	Aadd(stru,{"OK"        ,"C",02	,0})
	Aadd(stru,{"A1_COD"    ,"C"	,TamSX3("A1_COD")[1]  ,0})
	Aadd(stru,{"A1_LOJA"   ,"C"	,TamSX3("A1_LOJA")[1] ,0})
	Aadd(stru,{"A1_NOME"   ,"C"	,TamSX3("A1_NOME")[1] ,0})
	Aadd(stru,{"A1_BCO1"   ,"C"	,TamSX3("A1_BCO1")[1] ,0})
	Aadd(stru,{"A1_XBCOO"  ,"C"	,TamSX3("A1_BCO1")[1] ,0})
	Aadd(stru,{"A1_CODRED" ,"C"	,TamSX3("A1_CODRED")[1] ,0}) //045787
	Aadd(stru,{"ATIVO"     ,"C"	,03,0})
	
	//Cria tabela temporária.
	cArq := Criatrab(,.F.)
	MsCreate(cArq,stru,"DBFCDX")
	
	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArq,"TTRAG",.T.,.F.)
	
	//
	aCpoBro := {}
	Aadd(aCpoBro,{"OK"       ,, "Mark"})
	Aadd(aCpoBro,{"A1_COD"   ,, "Cliente"})
	Aadd(aCpoBro,{"A1_LOJA"  ,, "Loja"})
	Aadd(aCpoBro,{"A1_NOME"  ,, "Nome"})
	Aadd(aCpoBro,{"A1_BCO1"  ,, "Banco"})
	Aadd(aCpoBro,{"A1_XBCOO" ,, "Banco Orig."})
	Aadd(aCpoBro,{"A1_CODRED",, "Rede"}) //045787
	Aadd(aCpoBro,{"ATIVO"    ,, "Ativo"})
	
	For i := 1 To Len(aClientes)
		
		//IncProc("Carregando cadastro de clientes " + cvaltochar(i) +" De: "+cvlatochar(Len(aClientes)))
		
		RecLock("TTRAG",.T.)
		
		TTRAG->Ok        := cMark
		TTRAG->A1_COD    := Alltrim(cValToChar(aClientes[i][1]))
		TTRAG->A1_LOJA   := Alltrim(cValToChar(aClientes[i][2]))
		TTRAG->A1_NOME   := Alltrim(cValToChar(aClientes[i][3]))
		TTRAG->A1_BCO1   := Alltrim(cValToChar(aClientes[i][4]))
		TTRAG->A1_XBCOO  := Alltrim(cValToChar(aClientes[i][5]))
		TTRAG->A1_CODRED := Alltrim(cValToChar(aClientes[i][6])) //045787
		TTRAG->ATIVO     := Alltrim(cValToChar(aClientes[i][7]))
		
		TTRAG->(MsUnlock())
		
	Next i
	
	//
	If nTotCli <= 0
		
		RecLock("TTRAG",.T.)
		
		TTRAG->A1_COD    := ""
		TTRAG->A1_LOJA   := ""
		TTRAG->A1_NOME   := ""
		TTRAG->A1_BCO1   := ""
		TTRAG->A1_XBCOO  := ""
		TTRAG->A1_CODRED := "" //045787
		TTRAG->ATIVO     := ""
		
		TTRAG->(MsUnlock())
		
	EndIf
	TTRAG->(DbGoTop())
	
	//
	Eval(oClientes:oBrowse:bGoTop)
	oClientes:oBrowse:Refresh()
	Eval(oClientes:oBrowse:bGoTop)
	
	For i := 1 To nTotCli
		oClientes:oBrowse:GoUp()
		
	Next i
	
	//oTotVlr:Refresh()
	oTotCli:Refresh()

Return Nil
/*/{Protheus.doc} DispFxAtr
	Função para marcação de filtro de faixa por atraso.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 11/05/2017
	@version 01
	/*/
Static Function DispFxAtr(oClientes,cMark)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	
	DbSelectArea("TTRAG")
	
	If TTRAG->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	RecLock("TTRAG",.F.)
	
	If Marked("OK")
		TTRAG->OK := cMark
	Else
		TTRAG->OK := ""
	Endif
	
	MsUnlock()
	
	oClientes:oBrowse:Refresh()
	
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} FxAtrInvert
	FxAtrInvert.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 06/12/2017
	@version 01
	/*/
Static Function FxAtrInvert(oClientes,cMark)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	
	DbSelectArea( "TTRAG" )
	TTRAG->(DbGotop())
	
	If TTRAG->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	Do While ! TTRAG->(EoF())
		
		If Marked("OK")
			RecLock("TTRAG",.F.)
			TTRAG->OK := ""
			MsUnlock()
			
		Else
			RecLock("TTRAG",.F.)
			TTRAG->OK := cMark
			MsUnlock()
			
		Endif
		
		TTRAG->(DbSkip())
		
	EndDo
	
	Eval(oClientes:oBrowse:bGoTop)
	oClientes:oBrowse:Refresh()
	
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptSql
	Script sql.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 05/12/2017
	@version 01
	/*/
Static Function scriptSql(cBanco, nOpc, cFiltro)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local cAtivo    := ""
	
	Default nOpc	:= 2
	
	Default cAtivo	:= 2
	Default cFiltro := ""
	
	If Empty(cBanco)
		cBanco := Space(TamSX3("A6_COD")[1])
	EndIf
	
	cQuery := ""
	cQuery += " SELECT A1_COD,A1_LOJA, A1_NOME, A1_BCO1, A1_XBCOO, A1_CODRED, CASE WHEN  A1_MSBLQL = 2 THEN 'SIM' ELSE 'NAO' END 'ATIVO' "
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) WHERE A1_FILIAL = '"+xFilial("SA1")+"' " 
	
	If cFiltro == "FILTRAR"
		cQuery += " AND A1_BCO1 = '"+cBanco+"' " 
	
		// aSelBusca := {"1=Ativos","2=Bloqueados","3=Todos"}
		If cSelBusca == "1"
			cQuery += " AND A1_MSBLQL <> '1' "
			
		ElseIf cSelBusca == "2"
			cQuery += " AND A1_MSBLQL = '1' "
		
		EndIf
	
	ElseIf cFiltro == "ATIVOS"
		cQuery += " AND A1_MSBLQL <> '1' "
	
	EndIf
	
	cQuery += " AND SA1.D_E_L_E_T_ = ''  "
	cQuery += " ORDER BY A1_COD, A1_LOJA " // 044944
	
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} grCSV
	Gera aquivo CSV.  Chamado 038276.
	@type  Static Function
	@author Everson
	@since 06/12/2017
	@version 01
	/*/
Static Function grCSV()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Loca aAreaTTRAG := {}
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local cArq  	:= "Banco"+__cUserID + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	
	//
	If Select("TTRAG") <= 0
		MsgStop("Não há tabela temporária para gerar o arquivo CSV.","Função grCSV")
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
		MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSV")
		Return Nil
		
	EndIf
	
	//
	cLin := ""
	For i := 2 To Len(aCpoBro)
		cLin += cValToChar(aCpoBro[i][2]) + ";"
		
	Next i
	
	cLin += cEof
	
	//
	aAreaTTRAG := GetArea("TTRAG")
	DbSelectArea("TTRAG")
	TTRAG->(DbGoTop())
	
	While ! TTRAG->(Eof())
		
		cLin += Alltrim(cValToChar(TTRAG->A1_COD))   + ";" +;
		Alltrim(cValToChar(TTRAG->A1_LOJA))  + ";" +;
		Alltrim(cValToChar(TTRAG->A1_NOME))  + ";" +;
		Alltrim(cValToChar(TTRAG->A1_BCO1))  + ";" +;
		Alltrim(cValToChar(TTRAG->A1_XBCOO)) + ";" +;
		Alltrim(cValToChar(TTRAG->A1_CODRED))+ ";" +; //045787
		Alltrim(cValToChar(TTRAG->ATIVO))
		
		cLin += cEof
		
		FWrite(nHdl,cLin,Len(cLin))
		
		cLin := ""
		
		TTRAG->(DbSkip())
		
	EndDo
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	WinExec("Explorer.exe" + Space(1) + cDir )
	
	MsgInfo("Arquivo gerado.","Função grCSV")
	
	//
	TTRAG->(DbGoTop())
	RestArea(aAreaTTRAG)
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grlLog
	Gera de alteração de bancos.
	@type  Static Function
	@author Everson
	@since 08/07/2020
	@version 01
	/*/
Static Function grlLog()

	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local cTitulo		:= "Log Alteração de banco." 
	Local aParamBox		:= {}   
	Local aRet 			:= {}  
	Local cPath			:= ""
	Local cArq  		:= "log_banco.csv"

	//
	Aadd( aParamBox ,{1,"Data De "     ,CtoD(space(8)),"" ,'.T.',,'.T.',80,.T.})
	Aadd( aParamBox ,{1,"Data Até"     ,CtoD(space(8)),"" ,'.T.',,'.T.',80,.T.})
	Aadd( aParamBox ,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

	//
	If ! ParamBox( aParamBox, cTitulo, @aRet,,,,,,,,.T.,.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf

	//
	If Empty(Alltrim(aRet[3]))
		MsgStop("Local de gravação inválido","Função grlLog(ADFIN059P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cQuery := sqlLog(DToS(aRet[1]), DToS(aRet[2]))

	//
	cPath := Alltrim(cValToChar(aRet[3])) 

	//

	Processa({|| procLog(cQuery,cPath,cArq) },"Função grlLog (ADFIN059P)","Gerando csv...")

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} procLog
	Processa geração de relatório de log.
	@type  Static Function
	@author Everson
	@since 08/07/2020
	@version 01
	/*/
Static Function procLog(cQuery,cPath,cArq)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cBuffer	:= "Data;Hora;Usuário;Log" + Chr(13) + Chr(10)
	Local nHd1  	:= FCreate(cPath + cArq)

	//
	If nHd1 < 0
		MsgStop("Erro ao criar o arquivo. " + cValToChar(Ferror()),"Função procLog(ADFIN059P)")
		RestArea(aArea)
		Return Nil 

	EndIf

	//
	If Select("D_LOG") > 0
		D_LOG->(DbCloseArea())

	EndIf

	//
	FWrite(nHd1,cBuffer)
	cBuffer := ""
	TcQuery cQuery New Alias "D_LOG"
	DbSelectArea("D_LOG")
	D_LOG->(DbGoTop())
	ProcRegua(Contar("D_LOG","!Eof()"))
	D_LOG->(DbGoTop())
	While ! D_LOG->(Eof())

		//
		IncProc()

		//
		cBuffer := DToC(SToD(D_LOG->ZBE_DATA)) + ";" + Alltrim(cValToChar(D_LOG->ZBE_HORA)) + ";" + Alltrim(cValToChar(D_LOG->ZBE_USUARI)) + ";" + Alltrim(cValToChar(D_LOG->ZBE_LOG)) + Chr(13) + Chr(10)

		//
		FWrite(nHd1,cBuffer)

		//
		D_LOG->(DbSkip())
		cBuffer := ""

	End

	//
	FClose(nHd1)

	//
	WinExec("Explorer.exe" + Space(1) + cPath )

	//
	D_LOG->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} sqlLog
	Gera de alteração de bancos.
	@type  Static Function
	@author Everson
	@since 08/07/2020
	@version 01
	/*/
Static Function sqlLog(cDtIni,cDtFim)
	
	//Variáveis.
	Local cQuery := ""

	//
	cQuery += " SELECT " 
	cQuery += " ZBE_DATA, " 
	cQuery += " ZBE_HORA, " 
	cQuery += " ZBE_USUARI, " 
	cQuery += " ZBE_LOG " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZBE") + " (NOLOCK) AS ZBE " 
	cQuery += " WHERE " 
	cQuery += " ZBE_FILIAL = '" + FWxFilial("ZBE") + "' " 
	cQuery += " AND ZBE_ROTINA = 'ADFIN059P' " 
	cQuery += " AND ZBE_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' " 
	cQuery += " AND D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY ZBE_DATA, ZBE_HORA, ZBE.R_E_C_N_O_ " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN059P - sqlLog - cQuery " + cQuery )

Return cQuery