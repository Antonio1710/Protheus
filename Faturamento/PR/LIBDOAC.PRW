#Include "Protheus.CH"
#Include "MSGRAPHI.CH"
#Include "topconn.CH"
#INCLUDE "MATA410.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LIBDOAC   ³ Autor ³ Mauricio              ³ Data ³30.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de liberacao de pedidos para Diretoria(Caio)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³versionamento:                                                         ³±±
±±³Everson - 20/12/2018. Chamado 045901. Tratamento para não haver        ³±±
±±³registro duplicado na SC9.                                             ³±±
±±³Fernando - 13/02/2019. Chamado:047185. Liberar Estoque para Pedidos    ³±±
±±³Liberados para doação                                                  ³±±
±±³Fernando - 15/02/2019. Chamado:047185. Liberar Estoque para Pedidos    ³±±
±±³Liberados para doação, apenas pedidos diversos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LIBDOAC(cAlias,nReg,nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea			:= GetArea()
	Local _aSize			:= MsAdvSize( .T. )
	Local _aSize2			:= {}
	Local _aSize3			:= {}
	Local _aInfo			:= {}
	Local _aPosObj1			:= {}
	Local _aPosObj2			:= {}
	Local _aPosObj3			:= {}
	Local _aObjects			:= {}
	Local _nOpca			:= 00
	Local _lAllMark			:= .F.
	Local oFontBold			:= ""
	Local oChk     			:= Nil
	Local oAllMark

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oOk      			:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo      			:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oDLG
	Private lMark    	:= .F.
	Private lChk     	:= .F.
	Private _aPedido	:= {}         //Pedidos
	Private _aSupervisor := {}
	Private oItemped                      //itens pedidos
	Private _lFilGer	:= .F.
	Private _lFilSup	:= .F.
	Private _lFilVen	:= .F.
	Private _lFilCli	:= .F.
	Private aHeader		:= {}
	Private aHeadRec	:= {}
	Private aCols		:= {}
	Private aCloneCols	:= {}
	Private aColsRec	:= {}
	Private nUsado		:= 00

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos para Diretoria(Caio)')

	//ÚÄÄÄÄÄÄÄÄ¿
	//³ Fontes ³
	//ÀÄÄÄÄÄÄÄÄÙ
	Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros para calculo da resolucao da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aObjects	:= {}

	AADD( _aObjects, { 100, 100, .T., .T. } )
	AADD( _aObjects, { 100, 100, .T., .T. } )
	AADD( _aObjects, { 100, 150, .T., .T. } )
	AADD( _aObjects, { 100, 10 , .T., .F. } )

	_aInfo		:= { _aSize[ 01 ], _aSize[ 02 ], _aSize[ 03 ], _aSize[ 04 ], 00, 00 }
	_aPosObj1	:= MsObjSize( _aInfo, _aObjects, .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve as dimensoes dos objetos na esquerda da tela  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aObjects := {}

	AADD( _aObjects, { 100, 100, .T., .T., .T. } )
	AADD( _aObjects, { 100, 100, .T., .T., .T. } )

	_aSize2		:= aClone( _aPosObj1[ 01 ] )
	_aInfo		:= {_aSize2[02],_aSize2[01],_aSize2[04],_aSize2[03],03,03}
	_aPosObj2	:= MsObjSize( _aInfo, _aObjects,,.T. )

	_aObjects := {}

	AADD(_aObjects,{100,100,.T.,.T.,.T.})
	AADD(_aObjects,{100,100,.T.,.T.,.T.})

	_aSize3	  := aClone(_aPosObj1[02])
	_aInfo	  := {_aSize3[02],_aSize3[01],_aSize3[04],_aSize3[03],03,03}
	_aPosObj3 := MsObjSize(_aInfo,_aObjects,,.T.)


	Define MsDialog oDlg From _aSize[07], 000 To _aSize[06],_aSize[05] Title OemtoAnsi( "Liberacao de pedidos Doacao" ) Pixel Of oMainWnd

	@ _aPosObj2[ 01 ][ 01 ] + 03, _aPosObj2[ 01 ][ 02 ]+220 Say OemToAnsi( "Pedidos" )			Font oFontBold Color CLR_GRAY Of oDlg Pixel
	@ _aPosObj2[01][01]+03,_aPosObj2[01][02] CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
		ON CLICK(aEval(_aPedido,{|x| x[1]:=lChk}),oPedido:Refresh())

	MsAguarde( {|| AtuListBox( @_aPedido, @_aSupervisor ) }, OemToAnsi( "Aguarde" ) )


	@ _aPosObj2[01][01]+11,_aPosObj2[01][02] ListBox oPedido Var cVar ;
		Fields Header ;
		OemToAnsi(" "),;
		OemToAnsi("Pedido"),;
		OemToAnsi("Emissao"),;
		OemToAnsi("Entrega"),;
		OemToAnsi("Cod."),;
		OemToAnsi("Cliente"),;
		OemToAnsi("Qtd.CXs"),;
		OemToAnsi("Total Pedido"),;
		OemToAnsi("Valor NF"),;
		OemToAnsi("Val. Desc."),;
		OemToAnsi("Vendedor"),;
		OemToAnsi("Aprovador"),;
		Size _aPosObj1[02][04]-20,_aPosObj2[02][04]-07 Of oDlg Pixel ON dblClick(_aPedido[oPedido:nAt,1] := !_aPedido[oPedido:nAt,1],oPedido:Refresh())

	&&abaixo markbrowse para todos/nenhum
	//@ _aPosObj2[01][01]+60,_aPosObj2[01][02] CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
		//     ON CLICK(aEval(_aPedido,{|x| x[1]:=lChk}),oPedido:Refresh())

	oPedido:bChange := { || fSelSupervisor( _aPedido[ oPedido:nAt ][ 02 ], @_aSupervisor, "S" ) }

	oPedido:SetArray( _aPedido )

	oPedido:bLine := { || { If(_aPedido[oPedido:nAt][01],oOk,oNo),;
		_aPedido[oPedido:nAt][02],;
		_aPedido[oPedido:nAt][03],;
		_aPedido[oPedido:nAt][04],;
		_aPedido[oPedido:nAt][05],;
		_aPedido[oPedido:nAt][06],;
		_aPedido[oPedido:nAt][07],;
		_aPedido[oPedido:nAt][08],;
		_aPedido[oPedido:nAt][09],;
		_aPedido[oPedido:nAt][10],;
		_aPedido[oPedido:nAt][11],;
		_aPedido[oPedido:nAt][12]}}

	oPedido:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox Supervisores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj1[02][01]+14,_aPosObj1[02][02]+02 ListBox oItemped Var cVar ;
		Fields Header ;
		OemToAnsi("Item"),;
		OemToAnsi("Produto"),;
		OemToAnsi("Descricao"),;
		OemToAnsi("Qtd. KGs"),;
		OemToAnsi("Valor NF"),;
		OemToAnsi("Qtd. cxs"),;
		Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 60 Of oDlg Pixel       //-20  -40


	@ _aPosObj1[02][01]+135,_aPosObj2[01][02]+170 BUTTON "Aprovar"  SIZE 040,020 PIXEL OF oDlg Action U_APRV()     //150
	@ _aPosObj1[02][01]+135,_aPosObj2[01][02]+320 BUTTON "Rejeitar" SIZE 040,020 PIXEL OF oDlg Action U_REJE()	  //150
	&& Mauricio - MDS Tecnologia - 07/05/14 - adicionado botao e funcao para visualizar pedido de venda.
	@ _aPosObj1[02][01]+135,_aPosObj2[01][02]+450 BUTTON "Ver Pedido"  SIZE 045,020 PIXEL OF oDlg Action U_VISPEDD(oPedido:nAt)

	oItemped:SetArray( _aSupervisor )

	oItemped:bLine := { || {_aSupervisor[oItemped:nAt][01],;
		_aSupervisor[oItemped:nAt][02],;
		_aSupervisor[oItemped:nAt][03],;
		_aSupervisor[oItemped:nAt][04],;
		_aSupervisor[oItemped:nAt][05],;
		_aSupervisor[oItemped:nAt][06]}}

	oItemped:Refresh()

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| Processa( {|| MTHCProc() } ), oDlg:End() }, { || _nOpca := 00, oDlg:End() } )

	RestArea(_aArea)

Return (Nil)

Static Function AtuListBox( _aPedido, _aSupervisor)

	Local _aArea			:= GetArea()
	Local _cAlias			:= GetNextAlias()
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	Local _TabOrigem        := ""
	Local _cNomSup          := ""

	BeginSql Alias _cAlias
		SELECT SC5.C5_NUM, 
		SC5.C5_EMISSAO,
		SC5.C5_DTENTR, 
		SC5.C5_CLIENTE,
		SC5.C5_NOMECLI,
		SC5.C5_XIPTAB,
		SC5.C5_TOTDIG,
		SC5.C5_TOTTAB,
		SC5.C5_APROV1,
		SC5.C5_LIBER1,
		SC5.C5_APROV2,
		SC5.C5_LIBER2,
		SC5.C5_APROV3,
		SC5.C5_LIBER3,
		SC5.C5_VALORNF,
		SC5.C5_DESCTBP,
		SC5.C5_VOLUME1,
		SC5.C5_VEND1,
		SC5.C5_APRVDOA,
		SC5.C5_TABELA,
		SUM(SC6.C6_VALOR) AS C6TOTVL
		FROM %Table:SC5% SC5
		INNER JOIN %Table:SC6% SC6 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM
		WHERE SC5.C5_FILIAL = %xFilial:SC5% AND
		SC5.C5_BLQ = %Exp:'1'% AND
		SC5.C5_STATDOA = %Exp:'B'% AND
		SC5.C5_LIBEROK <> %Exp:'E'% AND          
		SC5.%NotDel% AND
		SC6.%NotDel%	      
		GROUP BY SC5.C5_NUM,SC5.C5_EMISSAO,SC5.C5_DTENTR,SC5.C5_CLIENTE,SC5.C5_NOMECLI,SC5.C5_XIPTAB,SC5.C5_TOTDIG,SC5.C5_TOTTAB,SC5.C5_APROV1,SC5.C5_LIBER1,SC5.C5_APROV2,SC5.C5_LIBER2,SC5.C5_APROV3,SC5.C5_LIBER3,SC5.C5_VALORNF,SC5.C5_DESCTBP,SC5.C5_VOLUME1,SC5.C5_VEND1,SC5.C5_APRVDOA,SC5.C5_TABELA
		//SC5.C5_EMISSAO > %Exp:DtoS(_dData)% AND
	EndSql

	_aPedido := {}

	While (_cAlias)->(!Eof())
		If (_cAlias)->C5_APRVDOA != __cUserID
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		_cNomVend := Posicione("SA3",1,xfilial("SA3")+(_cAlias)->C5_VEND1,"A3_NOME")
		_cNomSup  := UsrRetName((_cAlias)->C5_APRVDOA)


		// Alex Borges 08/03/12
		//_TabOrigem := Posicione("SA1",1,xfilial("SA1")+(_cAlias)->C5_CLIENTE,"A1_TABELA")

		fSelSupervisor( (_cAlias)->C5_NUM, @_aSupervisor, "G" )
		&&anterior sendo substituido....  AADD( _aPedido, {lMark,(_cAlias)->C5_NUM, DTOC(STOD((_cAlias)->C5_EMISSAO)),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,(_cAlias)->C5_NOMECLI,(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999,999.99"),transform((_cAlias)->C5_TOTDIG,"@E 999,999,999,999.99"),transform((_cAlias)->C5_TOTTAB,"@E 999,999,999,999.99")  } )
		//AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 9,999"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),transform((_cAlias)->C5_VOLUME1,"@E 999999,9999"),transform((_cAlias)->C6TOTVL,"@E 999,999.99"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		(_cAlias)->(dbSkip())

	EndDo

	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )

	If Len(_aPedido) <= 00
		//compatibilizado _aPedido com array de 12 devido ao error.log gerado - por Adriana em 22/09/14 chamado 20426
		AADD(_aPedido,{lMark,OemToAnsi("Nao existem informacoes para a lista" ),"","","","",Transform(00,"@E 9,999,999,999.99"),;
			TransForm(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"",""})
	EndIf

	If Len(_aSupervisor) <= 00
		AADD(_aSupervisor,{"",OemToAnsi("Nao existem informacoes para a lista"),"",Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),;
			Transform(00,"@E 999,999,999,999.999")})
	EndIf

Return(Nil)

Static Function fSelSupervisor( _cGerente, _aSupervisor, _cTipo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _cQuery		   := ""
	Local _aRetVendas	   := {}
	Local _aRetFaturamento := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := "Select "
	_cQuery += "SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_DESCRI,SC6.C6_PRCVEN, SC6.C6_UNSVEN, SC6.C6_VALOR,SC6.C6_XIPTAB, SC6.C6_TOTDIG, "
	_cQuery += "SC6.C6_TOTTAB,SC6.C6_PBTTV, SC6.C6_PLTTV, SC6.C6_PLTVD, SC6.C6_PLTSP, SC6.C6_PLTAB,SC6.C6_QTDVEN "
	_cQuery += "From "
	_cQuery += RetSqlName( "SC5" ) + " SC5, "
	_cQuery += RetSqlName( "SC6" ) + " SC6, "
	_cQuery += RetSqlName( "DA1" ) + " DA1
	_cQuery += " Where SC5.C5_NUM = '" + _cGerente + "' "
	_cQuery += "And SC5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
	_cQuery += "And SC5.D_E_L_E_T_ = ' ' "
	_cQuery += "And SC6.C6_NUM = SC5.C5_NUM "
	_cQuery += "And SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' "
	_cQuery += "And DA1.DA1_FILIAL = '" + xFilial( "DA1" ) + "' "
	_cQuery += "And DA1.DA1_CODTAB = SC5.C5_TABELA "
	_cQuery += "And DA1.DA1_CODPRO = SC6.C6_PRODUTO "
	_cQuery += "And SC6.D_E_L_E_T_ = ' ' "
	_cQuery += "And DA1.D_E_L_E_T_ = ' ' "
	_cQuery += "Order By SC6.C6_NUM, SC6.C6_ITEM "
	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Itens", .F., .T. )

	_aSupervisor := {}

	While Itens->(!Eof())
		AADD( _aSupervisor,{ALLTRIM(Itens->C6_ITEM),ALLTRIM(Itens->C6_PRODUTO),ALLTRIM(Substr(Itens->C6_DESCRI,1,30)),Transform(Itens->C6_QTDVEN,"@E 99999,9999"),Transform(Itens->C6_PRCVEN,"@E 99,999.99"),Transform(Itens->C6_UNSVEN,"@E 999999,9999")})
		Itens->(dbSkip())
	EndDo

	Itens->( dbCloseArea() )

	If Len(_aSupervisor) <= 00
		AADD(_aSupervisor,{"",OemToAnsi("Nao existem informacoes para a lista"),"",Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" )})
	EndIf

	If oItemped != Nil

		oItemped:SetArray( _aSupervisor )

		oItemped:bLine := { || {_aSupervisor[oItemped:nAt][01],;
			_aSupervisor[oItemped:nAt][02],;
			_aSupervisor[oItemped:nAt][03],;
			_aSupervisor[oItemped:nAt][04],;
			_aSupervisor[oItemped:nAt][05],;
			_aSupervisor[oItemped:nAt][06]}}
		oItemped:Refresh()

	EndIf

Return ( Nil )

User Function VISPEDD(_nPOS)
	
	//Private aRotina := Static Call( MATA410 , MenuDef )
	
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	Private aRotina := MenuDef() // Copiado do fonte MATA410

	U_ADINF009P('LIBDOAC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos para Diretoria(Caio)')

	_cNumero := _aPedido[_nPos][2]

	DbSelectArea("SC5") ; DbSetOrder(1)
	If DbSeek( xFilial( "SC5" ) + _cNumero )
		A410Visual( Alias() , Recno() , 2 )
	Else
		Alert("Pedido não encontrado na base de dados")
	Endif

	oPedido:Refresh()
Return()

Static Function MarkPed2()

	For _n1 := 1 to Len(_aPedido)
		If _aPedido[_n1][01]
			MsgAlert("Pedido marcado: "+_aPedido[_n1][02])
		EndIf
	Next

Return

User function Aprv()

	Local _lPedi  := .F.

	U_ADINF009P('LIBDOAC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos para Diretoria(Caio)')

	For _n1 := 1 to Len(_aPedido)
		If  _aPedido[_n1][01]
			_lPedi := .T.
		EndIf
	Next

	If _lPedi == .F.
		ApMsgInfo(OemToAnsi("Selecione os pedidos para aprovação!"))
	Else
		AprvPed()
	EndIf

Return()

User Function REJE()

	Local _lPedi  := .F.

	U_ADINF009P('LIBDOAC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos para Diretoria(Caio)')

	For _n1 := 1 to Len(_aPedido)
		If _aPedido[_n1][01]
			_lPedi := .T.
		EndIf
	Next

	If  _lPedi
		RejPed()
	Else
		ApMsgInfo(OemToAnsi("Selecione pelo menos um pedido para ser rejeitado!"))
	EndIf

Return()

Static Function AprvPed()

	Local _cQueryP := ""
	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F.
	Local lLibEst  := .F.
	Local cTipPs   := ""  //chamado:047185 Fernando Sigoli 13/02/2019

	For _n1 := 1 to Len(_aPedido)

		If _aPedido[_n1][01]
			_cPed1   := _aPedido[_n1][02]

			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If  SC5->(dbSeek(xfilial("SC5")+_cPed1))
				_cDtEn := SC5->C5_DTENTR
				_cVend := SC5->C5_VEND1
				cTipPs := SC5->C5_XTIPO  //tipo de pesagens : 1=Normal;2=Diversos;3=Transferencia. //chamado:047185 Fernando Sigoli 13/02/2019

				Reclock("SC5",.F.)
				SC5->C5_BLQ := " "
				SC5->C5_LIBEROK := "S"
				SC5->C5_STATDOA := "A"
				SC5->C5_DTAPDOA := Date()
				SC5->C5_HRAPDOA := Time()
				MSUNLOCK()

				//Everson - 20/12/2018. Chamado 045901. Faz a exclusão na SC9, se houver registros.
				DbSelectArea("SC9")
				SC9->(dbSetOrder(1))
				if SC9->(dbseek(xFilial("SC9")+_cPed1))
					While ! SC9->(Eof()) .And. _cPed1 == SC9->C9_PEDIDO .And. xfilial("SC9") == SC9->C9_FILIAL
						RecLock("SC9",.F.)
						dbdelete()
						MsUnlock()
						SC9->(dbSkip())
					EndDo
				Endif
				//

				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				If  SC6->(dbSeek(xFilial("SC6")+_cPed1))

					While ! SC6->(Eof()) .And. _cPed1 == SC6->C6_NUM .And. xFilial("SC6") == SC6->C6_FILIAL //Everson - 20/12/2018. Chamado 045901. Adiconada filial.
						_nQtdLiber := SC6->C6_QTDVEN
						RecLock("SC6")
						// Efetua a liberação item a item de cada pedido
						Begin transaction
							MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
						End transaction
						SC6->(MsUnLock())
						Begin Transaction
							SC6->(MaLiberOk({_cPed1},.F.))
						End Transaction
						SC6->(dbSkip())
					EndDo

					DbSelectArea("SC9")
					SC9->(dbSetOrder(1))
					if SC9->(dbseek(xFilial("SC9")+_cPed1))
						While ! SC9->(Eof()) .And. _cPed1 == SC9->C9_PEDIDO .And. xfilial("SC9") == SC9->C9_FILIAL //Everson - 20/12/2018. Chamado 045901. Adiconada filial.
							RecLock("SC9",.F.)
							SC9->C9_DTENTR := _cDtEn
							SC9->C9_VEND1  := _cVend

							If cTipPs = '2'
								SC9->C9_BLEST  := '' //chamado:047185 Fernando Sigoli 13/02/2019
							EndIf

							MsUnlock()
							SC9->(dbSkip())
						EndDo
					Endif

				EndIf
			Endif
		EndIf

	Next _n1

	AtuPed(@_aPedido)

	If oPedido != Nil

		oPedido:SetArray( _aPedido )

		oPedido:bLine := { || { Iif(_aPedido[oPedido:nAt][01],oOk,oNo),;
			_aPedido[ oPedido:nAt ][ 02 ]	,;
			_aPedido[ oPedido:nAt ][ 03 ]	,;
			_aPedido[ oPedido:nAt ][ 04 ]	,;
			_aPedido[ oPedido:nAt ][ 05 ]	,;
			_aPedido[ oPedido:nAt ][ 06 ]	,;
			_aPedido[ oPedido:nAt ][ 07 ]	,;
			_aPedido[ oPedido:nAt ][ 08 ]	,;
			_aPedido[ oPedido:nAt ][ 09 ]	,;
			_aPedido[ oPedido:nAt ][ 10 ]	,;
			_aPedido[ oPedido:nAt ][ 11 ]	,;
			_aPedido[ oPedido:nAt ][ 12 ] } }

		oPedido:Refresh()

	Endif


Return()

Static Function RejPed()           &&Mauricio 13/05/11 - rotina de rejeicao por pedidos.

	For _n1 := 1 to Len(_aPedido)

		If _aPedido[_n1][01]
			_cPed1 := _aPedido[_n1][02]

			dbSelectArea("SC5")
			dbSetOrder(1)

			If dbSeek(xfilial("SC5")+_cPed1)

				RecLock("SC5",.F.)
				SC5->C5_DTAPDOA  := DATE()
				SC5->C5_HRAPDOA  := TIME()
				SC5->C5_STATDOA := "R"
				SC5->C5_BLQ     := " "
				SC5->C5_LIBEROK := 'E'
				MsUnLock()
			Endif
			&&Mauricio - 30/09/13 - precisa ser verificado se devera ser deletado ou não os pedidos rejeitados!!!!

			&&Mauricio 19/07/11 - Pedidos rejeitados (nao aprovados) devem ser excluidos conforme solicitacao Comercial/Sr. Alex.
			RecLock("SC5",.F.)
			dbdelete()
			MsUnlock()
			_aASC6 := {}
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek(xfilial("SC6")+_cPed1)
				While !Eof() .And. SC6->C6_NUM == _cPed1
					AADD(_aASC6,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_TES,SC6->C6_UM,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR})
					Reclock("SC6",.F.)
					dbdelete()
					Msunlock()
					SC6->(dbskip())
				Enddo
			Endif
			dbSelectArea("SC9")
			dbSetOrder(1)
			If dbSeek(xfilial("SC9")+_cPed1)
				While !Eof() .And. SC9->C9_PEDIDO == _cPed1
					Reclock("SC9",.F.)
					dbdelete()
					Msunlock()
					SC9->(dbskip())
				Enddo
			Endif
			&&Mauricio 03/08/11 - envio de email ao vendedor para pedidos rejeitados(excluidos).
			_cVend1 := SC5->C5_VEND1
			U_EMAILPEDRJ(_cPed1,_cVend1,_aASC6,"3")
		EndIf
	Next

	AtuPed(@_aPedido)

	If oPedido != Nil

		oPedido:SetArray( _aPedido )

		oPedido:bLine := { || { Iif(_aPedido[oPedido:nAt][01],oOk,oNo),;
			_aPedido[ oPedido:nAt ][ 02 ]	,;
			_aPedido[ oPedido:nAt ][ 03 ]	,;
			_aPedido[ oPedido:nAt ][ 04 ]	,;
			_aPedido[ oPedido:nAt ][ 05 ]	,;
			_aPedido[ oPedido:nAt ][ 06 ]	,;
			_aPedido[ oPedido:nAt ][ 07 ]	,;
			_aPedido[ oPedido:nAt ][ 08 ]	,;
			_aPedido[ oPedido:nAt ][ 09 ]	,;
			_aPedido[ oPedido:nAt ][ 10 ]	,;
			_aPedido[ oPedido:nAt ][ 11 ]	,;
			_aPedido[ oPedido:nAt ][ 12 ] } }

		oPedido:Refresh()

	Endif

Return()

Static Function AtuPed( _aPedido)
	Local _aArea			:= GetArea()
	Local _cAlias			:= GetNextAlias()
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	Local _TabOrigem        := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	BeginSql Alias _cAlias
		SELECT SC5.C5_NUM, 
		SC5.C5_EMISSAO,
		SC5.C5_DTENTR, 
		SC5.C5_CLIENTE,
		SC5.C5_NOMECLI,
		SC5.C5_XIPTAB,
		SC5.C5_TOTDIG,
		SC5.C5_TOTTAB,
		SC5.C5_APROV1,
		SC5.C5_LIBER1,
		SC5.C5_APROV2,
		SC5.C5_LIBER2,
		SC5.C5_APROV3,
		SC5.C5_LIBER3,
		SC5.C5_VALORNF,
		SC5.C5_DESCTBP,
		SC5.C5_VOLUME1,
		SC5.C5_VEND1,
		SC5.C5_APRVDOA,
		SC5.C5_TABELA,
		SUM(SC6.C6_VALOR) AS C6TOTVL
		FROM %Table:SC5% SC5
		INNER JOIN %Table:SC6% SC6 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM
		WHERE SC5.C5_FILIAL = %xFilial:SC5% AND
		SC5.C5_BLQ = %Exp:'1'% AND
		SC5.C5_STATDOA = %Exp:'B'% AND
		SC5.C5_LIBEROK <> %Exp:'E'% AND          
		SC5.%NotDel% AND
		SC6.%NotDel%	      
		GROUP BY SC5.C5_NUM,SC5.C5_EMISSAO,SC5.C5_DTENTR,SC5.C5_CLIENTE,SC5.C5_NOMECLI,SC5.C5_XIPTAB,SC5.C5_TOTDIG,SC5.C5_TOTTAB,SC5.C5_APROV1,SC5.C5_LIBER1,SC5.C5_APROV2,SC5.C5_LIBER2,SC5.C5_APROV3,SC5.C5_LIBER3,SC5.C5_VALORNF,SC5.C5_DESCTBP,SC5.C5_VOLUME1,SC5.C5_VEND1,SC5.C5_APRVDOA,SC5.C5_TABELA
		//SC5.C5_EMISSAO > %Exp:DtoS(_dData)% AND
	EndSql

	_aPedido := {}

	While (_cAlias)->(!Eof())

		If (_cAlias)->C5_APRVDOA != __cUserID
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		_cNomVend := Posicione("SA3",1,xfilial("SA3")+(_cAlias)->C5_VEND1,"A3_NOME")
		_cNomSup  := UsrRetName((_cAlias)->C5_APRVDOA)


		// Alex Borges 08/03/12
		//_TabOrigem := Posicione("SA1",1,xfilial("SA1")+(_cAlias)->C5_CLIENTE,"A1_TABELA")

		fSelSupervisor( (_cAlias)->C5_NUM, @_aSupervisor, "G" )
		&&anterior sendo substituido....  AADD( _aPedido, {lMark,(_cAlias)->C5_NUM, DTOC(STOD((_cAlias)->C5_EMISSAO)),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,(_cAlias)->C5_NOMECLI,(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999,999.99"),transform((_cAlias)->C5_TOTDIG,"@E 999,999,999,999.99"),transform((_cAlias)->C5_TOTTAB,"@E 999,999,999,999.99")  } )
		//AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 9,999"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),transform((_cAlias)->C5_VOLUME1,"@E 999999,9999"),transform((_cAlias)->C6TOTVL,"@E 999,999.99"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		(_cAlias)->(dbSkip())

	EndDo

	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )

	If Len(_aPedido) <= 00
		//compatibilizado _aPedido com array de 12 devido ao error.log gerado - por Adriana em 22/09/14 chamado 20426
		AADD(_aPedido,{lMark,OemToAnsi("Nao existem informacoes para a lista" ),"","","","",Transform(00,"@E 9,999,999,999.99"),;
			TransForm(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"",""})
	EndIf

Return ( Nil )

static function MTHCProc()
	oDlg:End()
return(.T.)


/*/
	??????????????????????????????????????
	???????????????????????????????????????
	???????????????????????????????????????
	??rograma  ?enuDef   ?Autor ?Marco Bianchi         ?Data ?1/09/2006??
	???????????????????????????????????????
	??escri?o ?Utilizacao de menu Funcional                               ??
	??         ?                                                           ??
	??         ?                                                           ??
	???????????????????????????????????????
	??etorno   ?rray com opcoes da rotina.                                 ??
	???????????????????????????????????????
	??arametros?arametros do array a Rotina:                               ??
	??         ?. Nome a aparecer no cabecalho                             ??
	??         ?. Nome da Rotina associada                                 ??
	??         ?. Reservado                                                ??
	??         ?. Tipo de Transa?o a ser efetuada:                        ??
	??         ?  1 - Pesquisa e Posiciona em um Banco de Dados           ??
	??         ?   2 - Simplesmente Mostra os Campos                       ??
	??         ?   3 - Inclui registros no Bancos de Dados                 ??
	??         ?   4 - Altera o registro corrente                          ??
	??         ?   5 - Remove o registro corrente do Banco de Dados        ??
	??         ?. Nivel de acesso                                          ??
	??         ?. Habilita Menu Funcional                                  ??
	???????????????????????????????????????
	??  DATA   ?Programador   ?anutencao efetuada                         ??
	???????????????????????????????????????
	??         ?              ?                                           ??
	???????????????????????????????????????
	???????????????????????????????????????
	???????????????????????????????????????
/*/
Static Function MenuDef()

	Local nPos       := 0
	Local aEntRelac  := {}
	Local aAtiv      := {}
	Local aAnotac    := {}
	Local aRotina2  := {{STR0003,"A410Barra",0,3},;							   // "Incluir"
	{STR0004,"A410Barra",0,4}}								// "Alterar"
	Local aRotina3  := {{ OemToAnsi(STR0005),"A410Deleta"	,0,5,21,NIL},;
		{ OemToAnsi(STR0109),"Ma410Resid",0,2,0,NIL}}			//"Residuo"

	Private aRotina := {	{	OemToAnsi(STR0001),"AxPesqui"		,0,1,0 ,.F.},;		//"Pesquisar"
	{ OemToAnsi(STR0002),"A410Visual"	,0,2,0 ,NIL},;		//"Visual"
	{ OemToAnsi(STR0003),"A410Inclui"	,0,3,0 ,NIL},;		//"Incluir"
	{ OemToAnsi(STR0004),"A410Altera"	,0,4,20,NIL},;		//"Alterar"
	{ OemToAnsi(STR0005),IIf((Type("l410Auto") <> "U" .And. l410Auto),"A410Deleta",aRotina3),0,5,0,NIL},; // Excluir
	{ OemToAnsi(STR0006),aRotina2 		,0,3,0 ,NIL},;		//"Cod.barra"
	{ OemToAnsi(STR0042),"a410PCopia('SC5',SC5->(RecNo()),4)"	,0,6,0 ,NIL},;		//"Copia"
	{ OemToAnsi(STR0052),"A410Devol('SC5',SC5->(RecNo()),4)"	,0,3,0 ,.F.},;		//"Dev. Compras"
	{ OemToAnsi(STR0095),"Ma410PvNfs"	,0,2,0 ,NIL},;		//"Prep.Doc.Sa?a"
	{ OemToAnsi(STR0311),"CTBC662", 0, 7, 0, Nil },; 		//"Tracker Cont?il"
	{ OemToAnsi(STR0032),"A410Legend"	,0,1,0 ,.F.} }		//"Legenda"

	Aadd(aEntRelac, { STR0103, "MsDocument('SC5',SC5->(RecNo()),4)", 0, 4, 0, NIL })//"Conhecimento"

	If nModulo == 73

		Aadd(aEntRelac, { STR0243, "CRMA200('SC5')", 0, 8, 0, NIL })//"Privil?ios"

		aEntRelac := CRMXINCROT("SC5",aEntRelac)

		nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
		If nPos > 0
			//ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
			AAdd( aRotina, { aEntRelac[nPos][1], aEntRelac[nPos][2], 0, 8, 0, .F.})
			Adel(aEntRelac,nPos)
			Asize(aEntRelac,Len(aEntRelac)-1)
		EndIf

		nPos := ASCAN(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
		If nPos > 0
			//ADD OPTION aAtiv   TITLE STR0253 ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade"
			//ADD OPTION aAtiv   TITLE STR0254 ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
			AAdd( aAtiv, { STR0253, "CRMA180(,,,3,,)" 	, 0, 8, 0, .F.})
			AAdd( aAtiv, { STR0254, "CRMA180()"			, 0, 8, 0, .F.})

			aEntRelac[nPos][2] := aAtiv
			
		EndIf

		nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
		If nPos > 0
			//ADD OPTION aAnotac   TITLE STR0255 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anota?o"
			//ADD OPTION aAnotac   TITLE STR0256 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anota?es"
			AAdd( aAnotac, { STR0255, "CRMA090(3)"	, 0, 8, 0, .F.})
			AAdd( aAnotac, { STR0256, "CRMA090()"	, 0, 8, 0, .F.})
			aEntRelac[nPos][2] := aAnotac
		EndIf
	EndIf

	Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
	Aadd(aRotina, {STR0257,aEntRelac	, 0 , 8 , 3 	, .T.	})//"Relacionadas"

	//?????????????????????????????????????
	//?erifica motivo de bloqueio por regra/verba                             ?
	//?????????????????????????????????????
	If	SuperGetMv("MV_VEBLQRG", .F., .F.)
		aAdd(aRotina,{ OemToAnsi(STR0192) ,"BlqRegBrw",0,0,0 ,NIL} )		//"Blq. Regra"
	EndIf

	If ExistBlock("MA410MNU")
		ExecBlock("MA410MNU",.F.,.F.)
	EndIf

	//PONTO DE ENTRADA para Incluir chamada de acao relacionada no menu do pedido
	If FindFunction("OGX225F") .AND. (SuperGetMV("MV_AGRUBS",.F.,.F.))
		aRotina := OGX225F(aRotina)
	EndIf
Return(aRotina)
