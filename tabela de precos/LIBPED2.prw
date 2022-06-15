#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "MSGRAPHI.CH"
#Include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณLIBPED    ณ Autor ณ Mauricio              ณ Data ณ20.04.2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Tela de liberacao de redes                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/********************************************************************************************************************************

Ao efetuar altera็๕es neste fonte, checar o fonte ADVEN052P, pois o servi็o Rest o utiliza para efetuar libera็๕es de pedidos.

*********************************************************************************************************************************/

User Function LibPed2()

	Local _nOpca		:= 00
	Local _lAllMark		:= .F.
	Local oFontBold		:= ""
	Local oAllMark

	Private oDlg
	Private lMark    := .F.
	Private lChk     := .F.
	Private lMark1   := .F.
	Private lChk1    := .F.
	Private _aRede   := {}         //Pedidos
	Private _aItens  := {}
	Private oItemped                      //itens pedidos
	Private oProduto
	Private _lFilGer    := .F.
	Private _lFilSup	:= .F.
	Private _lFilVen	:= .F.
	Private _lFilCli	:= .F.
	Private aHeader		:= {}
	Private aHeadRec	:= {}
	Private aCols		:= {}
	Private aCloneCols	:= {}
	Private aColsRec	:= {}
	Private nUsado		:= 00
	Private _aPedidos	:= {}
	Private oOk         := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo         := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oOk1        := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo1        := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oChk        := Nil
	Private oChk1       := Nil
	Private _cSupervi   := ""
	Private _cGerente   := ""
	Private _cDiretor   := ""
	Private _cChavSc5   := ""
	Private aCombo1     := {}
	Private cCombo1     := Space(18)
	Private oCombo1     := NIl
	Private nCombo1     := 1

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de redes')

	aAdd( aCombo1,"Ordem IPTAB" )
	aAdd( aCombo1,"Ordem Volume" )
	aAdd( aCombo1,"Ordem Supervisor" )

	Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD

	DEFINE DIALOG oDlg TITLE "Liberacao de pedidos Rede" FROM 001,001 TO 500,1500 PIXEL              //1100



	&&TELA ESQUERDA APROVA PELA REDE...
	@ 001,070 Say OemToAnsi( "Aprova pela Rede" )			  Font oFontBold Color CLR_GRAY Of oDlg Pixel
	@ 001,001 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
	ON CLICK(aEval(_aRede,{|x| x[1]:=lChk}),oPedido:Refresh())

	oPedido := TWBrowse():New( 10 , 01, 300,100,,{OemToAnsi(" "),OemToAnsi("Codigo"),OemToAnsi("Rede"),OemToAnsi("IPTAB"),OemToAnsi("Qtd. cxs"),;
	OemToAnsi("Valor NF"),OemToAnsi("Val. Desc."),OemToAnsi("Vendedor"),OemToAnsi("Supervisor")},;
	{15,20,20,20,20,40,20,20,20},;
	oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	MsAguarde( {|| AtuListBox( @_aRede, @_aPedidos,@_aItens,nCombo1 ) }, OemToAnsi( "Aguarde" ) )

	oPedido:bChange := { || fSelSupervisor( _aRede[ oPedido:nAt ][ 10 ], @_aPedidos, "S",@_aitens,nCombo1 ) }

	oPedido:SetArray( _aRede )

	oPedido:bLine := { || { If(_aRede[oPedido:nAt][01],oOk,oNo),;
	_aRede[oPedido:nAt][02],;
	_aRede[oPedido:nAt][03],;
	_aRede[oPedido:nAt][04],;
	_aRede[oPedido:nAt][05],;
	_aRede[oPedido:nAt][06],;
	_aRede[oPedido:nAt][07],;
	_aRede[oPedido:nAt][08],;
	_aRede[oPedido:nAt][09]}}

	oPedido:bChange := { || fSelSupervisor( _aRede[ oPedido:nAt ][ 10 ], @_aPedidos, "S",@_aitens,nCombo1 ) }
	oPedido:bLDblClick := {|| _aRede[oPedido:nAt][1] := !_aRede[oPedido:nAt][1],;
	oPedido:DrawSelect()}

	//oPedido:Refresh()                               

	&&TELA DIREITA APROVA POR PEDIDOS DA REDE...
	@ 001,450 Say OemToAnsi( "Aprova por Pedidos da Rede" ) Font oFontBold Color CLR_GRAY Of oDlg Pixel
	@ 001,305 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
	ON CLICK(aEval(_aPedidos,{|x| x[1]:=lChk1}),oItemped:Refresh())

	oItemped := TWBrowse():New( 10 ,305, 400,100,,{OemToAnsi(" "),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Entrega"),OemToAnsi("Cod."),;
	OemToAnsi("Cliente"),OemToAnsi("TB ESC"),OemToAnsi("TB ORI"),OemToAnsi("IPTAB"),OemToAnsi("Qtd.cxs"),;
	OemToAnsi("Valor NF"),OemToAnsi("Val. Desc."),OemToAnsi("Vendedor"),OemToAnsi("Supervisor")},;
	{15,20,20,20,20,40,20,20,20,20,20,20,20},;
	oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	oItemped:bGotFocus := { || fSelItens(_aPedidos[oItemped:nAt][02],@_aItens,"S")}
	oItemped:bChange   := { || fSelItens(_aPedidos[oItemped:nAt][02],@_aItens,"S")}

	oItemped:SetArray(_aPedidos)

	oItemped:bLine := { || {If(_aPedidos[oItemped:nAt][01],oOk1,oNo1),;
	_aPedidos[oItemped:nAt][02],;
	_aPedidos[oItemped:nAt][03],;
	_aPedidos[oItemped:nAt][04],;
	_aPedidos[oItemped:nAt][05],;
	_aPedidos[oItemped:nAt][06],;
	_aPedidos[oItemped:nAt][07],;
	_aPedidos[oItemped:nAt][08],;
	_aPedidos[oItemped:nAt][09],;
	_aPedidos[oItemped:nAt][10],;
	_aPedidos[oItemped:nAt][11],;
	_aPedidos[oItemped:nAt][12],;
	_aPedidos[oItemped:nAt][13],;
	_aPedidos[oItemped:nAt][14]}}

	oItemped:bLDblClick := {|| _aPedidos[oItemped:nAt][1] := !_aPedidos[oItemped:nAt][1],;
	oItemped:DrawSelect()}						   

	//oItemped:Refresh()

	&&TELA INFERIOR ITENS DOS PEDIDOS DE VENDA...
	@ 110,001 Say OemToAnsi( "Itens dos Pedidos" )		  Font oFontBold Color CLR_GRAY Of oDlg Pixel

	oProduto := TWBrowse():New( 120 , 001, 500,100,,{OemToAnsi("Item"),OemToAnsi("Produto"),OemToAnsi("Descricao"),OemToAnsi("Qtd. kgs"),OemToAnsi("Valor NF"),;
	OemToAnsi("Qtd. cxs"),OemToAnsi("PBTTV"),OemToAnsi("PLTTV"),OemToAnsi("PLTAB"),OemToAnsi("PLTVD"),;
	OemToAnsi("PLTSP"),OemToAnsi("IPTAB")},;
	{15,20,20,20,20,20,20,20,20,20,20,20},;
	oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	oProduto:SetArray(_aItens)

	oProduto:bLine := { || {_aItens[oProduto:nAt][01],;                                          
	_aItens[oProduto:nAt][02],;
	_aItens[oProduto:nAt][03],;
	_aItens[oProduto:nAt][04],;
	_aItens[oProduto:nAt][05],;
	_aItens[oProduto:nAt][06],;
	_aItens[oProduto:nAt][07],;
	_aItens[oProduto:nAt][08],;
	_aItens[oProduto:nAt][09],;
	_aItens[oProduto:nAt][10],;
	_aItens[oProduto:nAt][11],;
	_aItens[oProduto:nAt][12]}}

	//oProduto:Refresh()

	@ 240,200 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 Pixel Of ODlg on change nCombo1 := oCombo1:nAt    //100
	@ 230,200 BUTTON "REORDENAR" SIZE 040,010 PIXEL OF oDlg Action AtuListBox( @_aRede, @_aPedidos,@_aItens,nCombo1 )
	@ 230,030 BUTTON "Aprovar"  SIZE 040,020 PIXEL OF oDlg Action U_APROVA(nCombo1)
	@ 230,080 BUTTON "Rejeitar" SIZE 040,020 PIXEL OF oDlg Action U_REJEITA(nCombo1)
	@ 230,130 BUTTON "Nomenclaturas"  SIZE 040,020 PIXEL OF oDlg Action U_NOMTAB()

	@ 230,320 BUTTON "SAIR" SIZE 040,020 PIXEL OF oDlg Action oDlg:End()	

	ACTIVATE DIALOG oDlg CENTERED
	//Activate MsDialog oDlg On Init EnchoiceBar( oDlg,{|| Processa( {|| MTHCProc()}), oDlg:End()}, { || _nOpca := 00, oDlg:End()})



Return (Nil)

Static Function AtuListBox( _aRede, _aPedidos,_aItens,_nOpc)

	Local _aArea  := GetArea()
	Local _cAlias := GetNextAlias()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona Registros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If _nOpc == 1 .Or. _nOpc == 3
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_IPTAB ASC
		EndSql
	Elseif _nOpc == 2
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_QTDCXS DESC
		EndSql
	Endif

	// Alimenta array REDE
	_aRede := {}

	While (_cAlias)->(!Eof())

		If     Empty((_cAlias)->ZZN_LIBER1) .And. !Empty(ZZN->ZZN_APROV1)
			If __cUserID != (_cAlias)->ZZN_APROV1
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. Empty((_cAlias)->ZZN_LIBER2) .AND. !Empty((_cAlias)->ZZN_APROV2)
			If(_cAlias)->ZZN_APROV2 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. !Empty((_cAlias)->ZZN_LIBER2) .AND. Empty((_cAlias)->ZZN_LIBER3) .AND. !Empty((_cAlias)->ZZN_APROV3)
			If(_cAlias)->ZZN_APROV3 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		Else
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(_cAlias)->Rede+"00")	
			_cRepresent := SA1->A1_VEND                                                    //Vendedor rede
			_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprova็ใo
			_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
		else
			_cRepresent := Space(06)
			_cSupervi   := Space(06)
		endif      
		_cNomVend := Posicione("SA3",1,xfilial("SA3")+_cRepresent,"A3_NOME")
		if !(Empty((_cAlias)->ZZN_APROV1))    
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV1)
		elseif !(Empty((_cAlias)->ZZN_APROV2))     
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV2)
		endif      

		fSelSupervisor((_cAlias)->Chave,@_aPedidos,"G",@_aItens,_nOpc)

		AADD(_aRede,{lMark,ALLTRIM((_cAlias)->Rede),ALLTRIM(SUBSTR((_cAlias)->NOME,1,20)),Transform((_cAlias)->IPTAB,"@E 9.999"),;
		ALLTRIM(Transform((_cAlias)->CAIXAS,"@E 9999")),Transform((_cAlias)->VLRNF,"@E 999,999.99" ),;
		Transform((_cAlias)->DESCO,"@E 999,999.99" ),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup),;
		(_cAlias)->CHAVE})

		(_cAlias)->(dbSkip())

	EndDo

	If _nOpc == 3
		aSort(_aRede,,,{|x,y| x[9] > y[9]})
	Endif

	//EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Restaura area ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(_cAlias)->(dbCloseArea())

	RestArea( _aArea )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida Arrays ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(_aRede) <= 00
		AADD(_aRede,{lMark,OemToAnsi("Nao existem inFormacoes para a lista"),"",Transform(00,"@E 999,999.999"),Transform(00,"@E 9,999,999,999.99"),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"","",""})
	EndIf

	If Len(_aPedidos) <= 00
		AADD(_aPedidos,{lMark1,OemToAnsi("Nao existem informacoes para a lista"),"","","","","",;
		"",Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),"",""})
	EndIf

Return(Nil)

Static Function fSelSupervisor(_cGerente,_aPedidos,_cTipo,_aItens,_nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis Locais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local _cQuery			:= ""
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	Local _TabOrigem        := ""
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona registros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	_cQuery := "SELECT SC5.C5_NUM   ,SC5.C5_EMISSAO,SC5.C5_DTENTR,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_NOMECLI, "
	_cQuery += "       SC5.C5_EST   ,SC5.C5_CHAVE  ,SC5.C5_XIPTAB,SC5.C5_TOTDIG ,SC5.C5_TOTTAB ,SC5.C5_LIBER1 , "
	_cQuery += "       SC5.C5_LIBER2,SC5.C5_APROV1 ,SC5.C5_APROV2,SC5.C5_APROV3,SC5.C5_TABELA,SC5.C5_VALORNF,SC5.C5_DESCTBP,SC5.C5_VOLUME1,SC5.C5_VEND1 "
	_cQuery += "FROM "+RetSqlName("ZZN")+" ZZN, "+RetSqlName("SC5")+" SC5 "
	_cQuery += "WHERE ZZN.ZZN_CHAVE = '"+_cGerente+"' AND "
	_cQuery += "      SC5.C5_CHAVE = ZZN.ZZN_CHAVE AND "
	//_cQuery += "      SC5.C5_TIPO = 'N' AND "
	//_cQuery += "      SC5.C5_BLQ = '1' AND "
	_cQuery += "      SC5.C5_LIBEROK <> 'E' AND"
	
	_cQuery += " SC5.C5_XGERSF <> '2' AND " //Everson - 10/05/2018. SalesForce 037261.
	
	_cQuery += "      SC5.C5_FILIAL  = '"+xFilial("SC5")+"' AND "
	_cQuery += "      ZZN.ZZN_FILIAL = '"+xFilial("ZZN")+"' AND "
	_cQuery += "      SC5.D_E_L_E_T_ = ' ' AND "
	_cQuery += "      ZZN.D_E_L_E_T_ = ' ' "
	IF _nOpc == 1 .Or. _nOpc == 3
		_cQuery += "ORDER BY SC5.C5_XIPTAB ASC"
	Elseif _nOpc == 2
		_cQuery += "ORDER BY SC5.C5_VOLUME1 DESC"
	Endif 
	_cQuery := ChangeQuery( _cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Supervisor", .F., .T. )

	_aPedidos := {}
	_aItens   := {}

	While Supervisor->(!Eof()) 

		_cNomVend := Posicione("SA3",1,xfilial("SA3")+Supervisor->C5_VEND1,"A3_NOME")
		if !(Empty(Supervisor->C5_APROV1))    
			_cNomSup  := UsrRetName(Supervisor->C5_APROV1)
		elseif !(Empty(Supervisor->C5_APROV2))     
			_cNomSup  := UsrRetName(Supervisor->C5_APROV2)
		endif   

		// Alex Borges 08/03/12
		_TabOrigem := Posicione("SA1",1,xfilial("SA1")+Supervisor->C5_CLIENTE,"A1_TABELA")

		fSelItens(Supervisor->C5_NUM,@_aItens)

		AADD( _aPedidos, {lMark1,ALLTRIM(Supervisor->C5_NUM), ALLTRIM(DTOC(STOD(Supervisor->C5_EMISSAO))),allTRIM(DTOC(STOD(Supervisor->C5_DTENTR))), ALLTRIM(Supervisor->C5_CLIENTE),;
		aLLTRIM(Supervisor->C5_NOMECLI),Supervisor->C5_TABELA,_TabOrigem,transform(Supervisor->C5_XIPTAB,"@E 999.999"),transform(Supervisor->C5_VOLUME1,"@E 9,999"),;
		transform(Supervisor->C5_VALORNF,"@E 999,999.99"),transform(Supervisor->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )						   

		Supervisor->(dbSkip())

	EndDo

	If _nOpc == 3
		aSort(_aPedidos,,,{|x,y| x[14] > y[14]})
	Endif

	Supervisor->(dbCloseArea())

	If Len(_aPedidos) <= 00
		AADD(_aPedidos,{lMark1,OemToAnsi("Nao existem informacoes para a lista"),"","","","","",;
		"",Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),"",""})
	EndIf

	If oItemped != Nil

		oItemped:SetArray(_aPedidos)

		oItemped:bLine := { || {If(_aPedidos[oItemped:nAt][01],oOk1,oNo1),;
		_aPedidos[oItemped:nAt][02],;
		_aPedidos[oItemped:nAt][03],;
		_aPedidos[oItemped:nAt][04],;
		_aPedidos[oItemped:nAt][05],;
		_aPedidos[oItemped:nAt][06],;
		_aPedidos[oItemped:nAt][07],;
		_aPedidos[oItemped:nAt][08],;
		_aPedidos[oItemped:nAt][09],;
		_aPedidos[oItemped:nAt][10],;
		_aPedidos[oItemped:nAt][11],;
		_aPedidos[oItemped:nAt][12],;
		_aPedidos[oItemped:nAt][13],;
		_aPedidos[oItemped:nAt][14]}}
		oItemped:Refresh()

	EndIf

Return(Nil)

Static Function fSelItens( _cPed,_aItens)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis Locais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local _cQuery			:= ""
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	//Local _cPed

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona registros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_cQuery := "SELECT SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_DESCRI,SC6.C6_UNSVEN, SC6.C6_PRCVEN, SC6.C6_VALOR,SC6.C6_XIPTAB, SC6.C6_TOTDIG, SC6.C6_TOTTAB, "
	//_cQuery += "DA1.DA1_XPRLIQ,SC6.C6_PBTTV, SC6.C6_PLTTV, SC6.C6_PLTVD, SC6.C6_PLTSP,SC6.C6_QTDVEN " Alex Borges 05/09 Buscar o PLTAB no dia do pedidos e nao na tabela vigente.
	_cQuery += "SC6.C6_PBTTV, SC6.C6_PLTTV, SC6.C6_PLTVD, SC6.C6_PLTSP, SC6.C6_PLTAB,SC6.C6_QTDVEN "
	//_cQuery += "SC6.C6_PRTABV "  &&Mauricio 26/07/11 - Aguardando cria็ใo de campo para implementar
	_cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6  "                                                                               
	//_cQuery += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("DA1")+" DA1  "  ALEX BORGES 27/03                                                                             
	_cQuery += "WHERE SC5.C5_NUM = '"+_cPed+"' AND "
	_cQuery += "      SC5.C5_TIPO = 'N' AND "
	_cQuery += "      SC5.C5_BLQ != 'R' AND "
	_cQuery += "      SC5.C5_FILIAL = '"+ xFilial("SC5")+"' AND "
	_cQuery += "      SC5.D_E_L_E_T_ = ' ' AND "
	_cQuery += "      SC6.C6_NUM = SC5.C5_NUM AND "
	//_cQuery += "      DA1.DA1_FILIAL = '" + xFilial( "DA1" ) + "' "
	//_cQuery += "And DA1.DA1_CODTAB = SC5.C5_TABELA "
	//_cQuery += "And DA1.DA1_CODPRO = SC6.C6_PRODUTO "
	_cQuery += "   SC6.C6_FILIAL = '"+xFilial("SC6" )+"' AND "
	_cQuery += "      SC6.D_E_L_E_T_ = ' ' "
	//_cQuery += "And DA1.D_E_L_E_T_ = ' ' "
	
	_cQuery += " AND SC5.C5_XGERSF <> '2' " //Everson - 10/05/2018. SalesForce 037261.
	
	_cQuery += "ORDER BY SC6.C6_NUM, SC6.C6_ITEM"
	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Itens", .F., .T. )

	_aItens := {}

	While Itens->(!Eof())

		AADD( _aItens,{ALLTRIM(Itens->C6_ITEM),ALLTRIM(Itens->C6_PRODUTO),ALLTRIM(SUBSTR(Itens->C6_DESCRI,1,30)),Transform(Itens->C6_QTDVEN,"@E 999,999"),;
		Transform(Itens->C6_PRCVEN,"@E 999,999.99"),Transform(Itens->C6_UNSVEN,"@E 9999"),;
		Transform(Itens->C6_PBTTV,"@E 999.99"),Transform(Itens->C6_PLTTV,"@E 999.99"),;
		Transform(Itens->C6_PLTAB,"@E 999.99"),Transform(Itens->C6_PLTVD,"@E 999.99"),;
		Transform(Itens->C6_PLTSP,"@E 999.99"),Transform(Itens->C6_XIPTAB,"@E 999.999")})		  			  

		Itens->(dbSkip())

	EndDo

	Itens->(dbCloseArea())

	If Len(_aItens) <= 00
		AADD(_aItens,{"",OemToAnsi("Nao existem inFormacoes para a lista"),"",Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 9,999,999,999.99"),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 9,999,999,999.99")})
	EndIf

	If oProduto != Nil

		oProduto:SetArray( _aItens )

		oProduto:bLine := { || {_aItens[oProduto:nAt][01],;
		_aItens[oProduto:nAt][02],;
		_aItens[oProduto:nAt][03],;
		_aItens[oProduto:nAt][04],;
		_aItens[oProduto:nAt][05],;
		_aItens[oProduto:nAt][06],;
		_aItens[oProduto:nAt][07],;
		_aItens[oProduto:nAt][08],;
		_aItens[oProduto:nAt][09],;
		_aItens[oProduto:nAt][10],;
		_aItens[oProduto:nAt][11],;
		_aItens[oProduto:nAt][12]}}

		oProduto:Refresh()

	EndIf
Return (Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VISPED2  บAutor  ณ Mauricio           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza็ใo do Pedido de Venda                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VISPED2(_nPOS)

	Local _cNumero := _aPedidos[_nPos][2]  

	&&Mauricio - 03/05/2011 - Quando usuario eh TABELA apresenta erro.....

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xfilial("SC5")+_cNumero)
		A410Visual("SC5",SC5->( Recno() ), 2 )
	Else
		ApMsgInfo(OemToAnsi("Pedido nao encontrado na base de dados"))
	EndIf

	oItemped:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ MARKPED  บAutor  ณ Mauricio           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza็ใo do Pedido de Venda                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MarkPed()
	Local _n1
	For _n1 := 1 to len(_aRede)
		If _aRede[_n1][01]
			ApMsgAlert(OemToAnsi("Pedido marcado: "+_aRede[_n1][02]))
		EndIf
	Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ APROVA   บAutor  ณ Mauricio           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a aprova็ใo do pedido de vendas da rede             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Aprova(_nOpc)

	Local _lRede := .F.
	Local _lPedi  := .F.
	Local _n1
	U_ADINF009P('LIBPED2' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de redes')

	For _n1 := 1 to Len(_aRede)   // Verifica rede
		If _aRede[_n1][01]
			_lRede := .T.
		EndIf
	Next

	For _n1 := 1 to Len(_aPedidos) // Verifica loja
		If _aPedidos[_n1][01]
			_lPedi := .T.
		EndIf
	Next

	If      _lRede .And. _lPedi        
		ApMsgInfo(OemToAnsi("Escolha aprova็ใo pela REDE ou pelos PEDIDOS da rede, nunca pelos dois!"))
	ElseIf  _lRede .And. _lPedi == .F.
		AprvRede(_nOpc)  &&Chama aprova็ใo de TODA A REDE - Mauricio 13/05/11.
	ElseIf  _lRede == .F. .And. _lPedi
		AprvPed(_nOpc)   &&Chama aprova็ใo de alguns pedidos da Rede - Mauricio 13/05/11.
	Else
		ApMsgInfo(OemToAnsi("Selecione ou aprova็ใo pela REDE ou por PEDIDOS da rede!"))
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ REJEITA  บAutor  ณ Mauricio           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a rejei็ใo de pedidos de vendas da rede             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function REJEITA(_nOpc)

	Local _lRede := .F.
	Local _lPedi  := .F.
	Local _n1
	U_ADINF009P('LIBPED2' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de redes')

	For _n1 := 1 to Len(_aRede)    // Verifica a rede
		If _aRede[_n1][01]
			_lRede := .T.
		EndIf
	Next

	For _n1 := 1 to Len(_aPedidos) // Verifica a Loja
		If _aPedidos[_n1][01]
			_lPedi := .T.
		EndIf
	Next

	If     _lRede .And. _lPedi
		ApMsgInfo(OemToAnsi("Escolha ou por REDE ou por PEDIDO, nunca pelos dois!"))
	ElseIf _lRede .And. _lPedi == .F.
		RejRede(_nOpc)  // Chama rejeicao de TODA A REDE - Mauricio 13/05/11.
	ElseIf _lRede == .F. .And. _lPedi   
		RejPed(_nOpc)   // Chama aprova็ใo de alguns pedidos da Rede - Mauricio 13/05/11.
	ElseIf _lRede == .F. .And. _lPedi == .F.
		ApMsgInfo(OemToAnsi("Selecione a REDE ou os PEDIDOS que serใo rejeitados!"))
	EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ APRVREDE บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de aprova็ใo para toda a rede                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AprvRede(_nOpc)           &&Mauricio 13/05/11 - rotina de aprova็ใo para toda a Rede

	Local _cQueryR := ""
	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F.  //.T.  Mauricio 26/07/11.
	Local lAvAp1   := .F.
	Local lAvAp2   := .F.
	Local lAvAp3   := .F.
	Local _n1
	For _n1 := 1 to Len(_aRede)

		/*
		Ao fazer altera็๕es na variแvel _aRede, verificar o fonte ADVEN052P, pois a rotina AprvRede estแ sendo utilizada no fonte
		ADVEN052P (servi็o Rest).
		Everson - 03/10/2017. Chamado 037261.
		*/
		If _aRede[_n1][01]

			_cRede   := _aRede[_n1][02]
			_cChave  := _aRede[_n1][10]

			_cQueryR := "SELECT * FROM "+RetSqlName("SC5")+" "
			_cQueryR += "WHERE C5_CODRED = '"+_cRede+"' AND "
			_cQueryR += "      C5_CHAVE  = '"+_cChave+"' AND "
			_cQueryR += "      C5_FILIAL = '"+cFilAnt+"' AND "
			_cQueryR += "      D_E_L_E_T_= ' ' "
			
			_cQueryR += "      AND C5_XGERSF <> '2' " //Everson - 10/05/2018. SalesForce 037261.
			
			_cQueryR += "ORDER BY C5_NUM"

			TCQUERY _cQueryR NEW ALIAS "LIBR"

			dbSelectArea("LIBR")
			dbGoTop()

			While LIBR->(!Eof())

				_cPed  := LIBR->C5_NUM
				_cDtEn := STOD(LIBR->C5_DTENTR)
				_cVend := LIBR->C5_VEND1

				dbSelectArea("SC5")
				dbSetOrder(1)

				If dbSeek(xFilial("SC5")+_cPed)
					If Empty(SC5->C5_LIBER1) .And. !Empty(SC5->C5_APROV1)  // tem aprovador 1
						RecLock("SC5",.F.)
						SC5->C5_LIBER1 := "S"
						SC5->C5_DTLIB1 := DATE()
						SC5->C5_HRLIB1 := TIME()
						MsUnlock()

						If Empty(SC5->C5_APROV2) .AND. Empty(SC5->C5_APROV3)  // se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
							RecLock("SC5",.F.)
							SC5->C5_BLQ     := " "
							SC5->C5_LIBEROK := "S"
							MsUnlock()

							&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
							dbSelectArea("SC9")
							dbSetOrder(1)
							If dbSeek(xfilial("SC9")+_cPed)
								While !Eof() .And. SC9->C9_PEDIDO == _cPed
									Reclock("SC9",.F.)
									dbdelete()
									Msunlock()
									SC9->(dbskip())
								Enddo
							Endif

							dbSelectArea("SC6")
							dbSetOrder(1)
							If dbSeek(xFilial("SC6")+_cPed)
								While !Eof() .And. _cPed == SC6->C6_NUM
									_nQtdLiber := SC6->C6_QTDVEN
									RecLock("SC6")
									// Efetua a libera็ใo item a item de cada pedido
									Begin transaction
										MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
									End transaction
									SC6->(MsUnLock())

									Begin Transaction
										SC6->(MaLiberOk({_cPed},.F.))
									End Transaction

									SC6->(dbSkip())
								EndDo

								dbSelectArea("SC9")
								dbSetOrder(1)
								If dbSeek(xFilial("SC9")+_cPed)
									While !Eof() .And. _cPed == SC9->C9_PEDIDO
										RecLock("SC9",.F.)
										SC9->C9_DTENTR := _cDtEn
										SC9->C9_VEND1  := _cVend
										MsUnlock()
										SC9->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf

					ElseIf !Empty(SC5->C5_LIBER1) .AND. Empty(SC5->C5_LIBER2) .AND. !Empty(SC5->C5_APROV2)        // tem aprovador 2 e ja aprovou 1
						RecLock("SC5",.F.)
						SC5->C5_LIBER2 := "S"
						SC5->C5_DTLIB2 := DATE()
						SC5->C5_HRLIB2 := TIME()
						MsUnlock()

						If Empty(SC5->C5_APROV3)   // Mauricio 13/05/11- se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
							RecLock("SC5",.F.)
							SC5->C5_BLQ := " "
							SC5->C5_LIBEROK := "S"
							MsUnlock()

							&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
							dbSelectArea("SC9")
							dbSetOrder(1)
							If dbSeek(xfilial("SC9")+_cPed)
								While !Eof() .And. SC9->C9_PEDIDO == _cPed
									Reclock("SC9",.F.)
									dbdelete()
									Msunlock()
									SC9->(dbskip())
								Enddo
							Endif

							dbSelectArea("SC6")
							dbSetOrder(1)
							If  dbSeek(xFilial("SC6")+_cPed)
								While !Eof() .And. _cPed == SC6->C6_NUM
									_nQtdLiber := SC6->C6_QTDVEN
									RecLock("SC6")
									// Efetua a libera็ใo item a item de cada pedido
									Begin transaction
										MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
									End transaction
									SC6->(MsUnLock())

									Begin Transaction
										SC6->(MaLiberOk({_cPed},.F.))
									End Transaction
									SC6->(dbSkip())
								EndDo
								DbSelectArea("SC9")
								dbSetOrder(1)
								If dbseek(xFilial("SC9")+_cPed)
									While !Eof() .And. _cPed == SC9->C9_PEDIDO
										RecLock("SC9",.F.)
										SC9->C9_DTENTR := _cDtEn
										SC9->C9_VEND1  := _cVend
										MsUnlock()
										SC9->(dbSkip())
									EndDo
								Endif
							EndIf

						EndIf
					ElseIf !Empty(SC5->C5_LIBER2) .AND. Empty(SC5->C5_LIBER3) .AND. !Empty(SC5->C5_APROV3)    &&tem aprovador 3 e ja aprovou 1 e 2
						RecLock("SC5",.F.)
						SC5->C5_LIBER3 := "S"                         &&Mauricio 23/03/16 corrigido grava็ใo da aprova็ao 3 nos campos corretos
						SC5->C5_DTLIB3 := DATE()
						SC5->C5_HRLIB3 := TIME()
						SC5->C5_BLQ    := " "
						SC5->C5_LIBEROK := "S"
						MsUnlock()

						&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
						dbSelectArea("SC9")
						dbSetOrder(1)
						If dbSeek(xfilial("SC9")+_cPed)
							While !Eof() .And. SC9->C9_PEDIDO == _cPed
								Reclock("SC9",.F.)
								dbdelete()
								Msunlock()
								SC9->(dbskip())
							Enddo
						Endif

						dbSelectArea("SC6")      // como ้ o ultimo aprovador libero o pedido
						dbSetOrder(1)
						If  dbSeek(xFilial("SC6")+_cPed)
							While !Eof() .And. _cPed == SC6->C6_NUM
								_nQtdLiber := SC6->C6_QTDVEN
								RecLock("SC6")
								// Efetua a libera็ใo item a item de cada pedido
								Begin transaction
									MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
								End transaction
								SC6->(MsUnLock())

								Begin Transaction
									SC6->(MaLiberOk({_cPed},.F.))
								End Transaction
								SC6->(dbSkip())
							EndDo
							DbSelectArea("SC9")
							dbSetOrder(1)
							if dbseek(xFilial("SC9")+_cPed)
								While !Eof() .And. _cPed == SC9->C9_PEDIDO
									RecLock("SC9",.F.)
									SC9->C9_DTENTR := _cDtEn
									SC9->C9_VEND1  := _cVend
									MsUnlock()
									SC9->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
				EndIf
				
				//Everson - 16/07/2018. Checa libera็ใo financeira.
				//Fun็ใo chkBlCred disponํvel no fonte LIBPED1.
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				If SC9->(Dbseek(xFilial("SC9")+_cPed))
					//Static Call(LIBPED1,chkBlCred, SC9->C9_CLIENTE,SC9->C9_LOJA,_cPed)
					//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
					u_LIBPEDA0( SC9->C9_CLIENTE,SC9->C9_LOJA,_cPed )					
				
				EndIf

				//log de aprova็ใo de pedido do para toda a rede - fernando 20/07/2017
				u_GrLogZBE (Date(),TIME(),cUserName,"APROVACAO PEDIDO PARA TODA A REDE","COMERCIAL","LIBPED2",;
				"PEDIDO: "+_cPed,ComputerName(),LogUserName())  

				dbSelectArea("LIBR")
				LIBR->(dbSkip())

			EndDo

			dbSelectArea("ZZN")
			dbSetOrder(2)
			If dbSeek(xfilial("ZZN")+_cChave)

				RecLock("ZZN",.F.)
				&&	/*&&Mauricio 08/07/11 - retirado este tratamento e substituido pelo abaixo em fun็ใo de nใo estar funcionando corretamente.
				//If  __cUserId == ZZN->ZZN_APROV1 .AND. Empty(ZZN->ZZN_APROV2) .AND. Empty(ZZN->ZZN_APROV3)
				//	ZZN->ZZN_AVALIA := "S"
				//EndIf


				If  __cUserID == ZZN->ZZN_APROV1 .And. Empty(ZZN->ZZN_LIBER1)
					ZZN->ZZN_LIBER1 := "S"
				Elseif	__cUserId == ZZN->ZZN_APROV2  .AND. !(empty(ZZN->ZZN_LIBER1)) .And. empty(ZZN->ZZN_LIBER2)
					ZZN->ZZN_LIBER2 := "S"
				Elseif 	__cUserId == ZZN->ZZN_APROV2 .And. Empty(ZZN->ZZN_LIBER1) .And. Empty(ZZN->ZZN_LIBER2) .And. Empty(ZZN->ZZN_APROV1)
					ZZN->ZZN_LIBER2 := "S"
				Elseif __cUserID == ZZN->ZZN_APROV3  .AND. !(empty(ZZN->ZZN_LIBER1)) .And. !(empty(ZZN->ZZN_LIBER2)) .And. empty(ZZN->ZZN_LIBER3)
					ZZN->ZZN_LIBER3 := "S"
				Elseif 	__cUserId == ZZN->ZZN_APROV3 .And. Empty(ZZN->ZZN_LIBER1) .And. Empty(ZZN->ZZN_LIBER2) .And. Empty(ZZN->ZZN_LIBER3) .And.;
				Empty(ZZN->ZZN_APROV1) .And. Empty(ZZN->ZZN_APROV2)
					ZZN->ZZN_LIBER3 := "S"
				EndIf

				If !(Empty(ZZN->ZZN_APROV1)) .And. !(Empty(ZZN->ZZN_LIBER1)) .And. Empty(ZZN->ZZN_APROV2) .And. Empty(ZZN->ZZN_APROV3)
					ZZN->ZZN_AVALIA := "S"
				Elseif !(empty(ZZN->ZZN_APROV1)) .And. !(Empty(ZZN->ZZN_LIBER1)) .And. !(Empty(ZZN->ZZN_APROV2)) .And. !(Empty(ZZN->ZZN_LIBER2));
				.And. Empty(ZZN->ZZN_APROV3)
					ZZN->ZZN_AVALIA := "S"
				Elseif !(empty(ZZN->ZZN_APROV1)) .And. !(Empty(ZZN->ZZN_LIBER1)) .And. !(Empty(ZZN->ZZN_APROV2)) .And. !(Empty(ZZN->ZZN_LIBER2));
				.And. !(Empty(ZZN->ZZN_APROV3)) .And. !(Empty(ZZN->ZZN_LIBER3))
					ZZN->ZZN_AVALIA := "S"
				Endif

				/*&&Mauricio 08/07/11 - retirado este tratamento e substituido pelo acima em fun็ใo de nใo estar funcionando corretamente.
				&&  Alex Borges - 05/07/11
				If __cUserID == ZZN->ZZN_APROV2
				ZZN->ZZN_LIBER2 := "S"
				EndIf

				If __cUserId == ZZN->ZZN_APROV2  .AND. !(empty(ZZN->ZZN_LIBER1))
				ZZN->ZZN_LIBER2 := "S"
				EndIf

				If __cUserId == ZZN->ZZN_APROV3 .And. !(Empty(ZZN->ZZN_LIBER1)) .And. !(Empty(ZZN->ZZN_LIBER2))
				ZZN->ZZN_AVALIA := "S"
				ZZN->ZZN_LIBER3 := "S"
				EndIf
				*/
				MsUnlock()
			EndIf

			dbSelectArea("LIBR")
			LIBR->(dbCloseArea())

		EndIf


	Next

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.   
		AtuRede2(@_aRede,@_aPedidos,_nOpc)

	EndIf

	//Everson - 21/09/2017. Chamado 037261.  
	If ! IsInCallStack('RESTEXECUTE') .And. oPedido != Nil

		oPedido:SetArray( _aRede )

		oPedido:bLine := { || { If( _aRede[oPedido:nAt][01],oOk,oNo),;
		_aRede[oPedido:nAt][02],;
		_aRede[oPedido:nAt][03],;
		_aRede[oPedido:nAt][04],;
		_aRede[oPedido:nAt][05],;
		_aRede[oPedido:nAt][06],;
		_aRede[oPedido:nAt][07],;
		_aRede[oPedido:nAt][08],;
		_aRede[oPedido:nAt][09]}}

		oPedido:Refresh()
	EndIf

	//Everson - 21/09/2017. Chamado 037261.  
	If ! IsInCallStack('RESTEXECUTE') .And. oItemped != Nil

		oItemped:SetArray(_aPedidos)

		oItemped:bLine := { || {If(_aPedidos[oItemped:nAt][01],oOk1,oNo1),;
		_aPedidos[oItemped:nAt][02],;
		_aPedidos[oItemped:nAt][03],;
		_aPedidos[oItemped:nAt][04],;
		_aPedidos[oItemped:nAt][05],;
		_aPedidos[oItemped:nAt][06],;
		_aPedidos[oItemped:nAt][07],;
		_aPedidos[oItemped:nAt][08],;
		_aPedidos[oItemped:nAt][09],;
		_aPedidos[oItemped:nAt][10],;
		_aPedidos[oItemped:nAt][11],;
		_aPedidos[oItemped:nAt][12],;
		_aPedidos[oItemped:nAt][13],;
		_aPedidos[oItemped:nAt][14]}}

		oItemped:Refresh()

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ APRVPED  บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de aprova็ใo por pedido para a rede                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AprvPed(_nOpc)           &&Mauricio 13/05/11 - rotina de aprova็ใo por pedidos para a Rede.

	Local _cQueryP := ""
	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F. //.T. Mauricio 26/07/11
	Local _nSomDig := 0
	Local _nSomTab := 0
	Local _nSomPes := 0
	Local _lPedi   := .F.
	Local _cCodRd  := ""
	Local _cC5CHAV := ""
	Local _lDir    := .F.
	Local _lGer    := .F.
	Local _lfinal  := .F.
	Local _nSomTot := 0
	Local _n1
	For _n1 := 1 to Len(_aPedidos)
		If !(_aPedidos[_n1][01])
			_lPedi := .T.
		EndIf
	Next

	//Everson - 21/09/2017. Chamado 037261.  
	If ! IsInCallStack('RESTEXECUTE') .And. (_lPedi == .F. .Or. len(_aPedidos) == 1) &&so utiliza esta rotina se tiver pelo menos um pedido de venda desmarcado para aprova็ใo e se houver mais de um pedido de venda
		ApMsginfo(OemToAnsi("Voce nใo deixou nenhum pedido desmarcado ou ha somente um unico pedido para aprova็ใo. Neste caso utilize a aprova็ใo pelo total da Rede!"),OemToAnsi("A T E N ว ร O"))
		Return()

	EndIf

	For _n1 := 1 to Len(_aPedidos)
		If _aPedidos[_n1][01]
			_cPed1   := _aPedidos[_n1][02]

			dbSelectArea("SC5")
			dbSetOrder(1)
			If  dbSeek(xfilial("SC5")+_cPed1)
				_cChavSc5 := SC5->C5_CHAVE
				_cDtEn := SC5->C5_DTENTR
				_cVend := SC5->C5_VEND1
				If  Empty(SC5->C5_LIBER1) .And. !Empty(SC5->C5_APROV1)  &&tem aprovador 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER1 := "S"
					SC5->C5_DTLIB1 := DATE()
					SC5->C5_HRLIB1 := TIME()
					MsUnlock()
					dbSelectArea("ZZN")
					dbSetOrder(2)
					If dbSeek(xFilial("ZZN")+_cChavSc5)
						RecLock("ZZN",.F.)
						ZZN->ZZN_LIBER1 := "S"
						MsUnlock()
					EndIf

					If  Empty(SC5->C5_APROV2) .And. Empty(SC5->C5_APROV3)     &&se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
						RecLock("SC5",.F.)
						SC5->C5_BLQ := " "
						SC5->C5_LIBEROK := "S"
						MsUnlock()

						&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
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

						dbSelectArea("SC6")
						dbSetOrder(1)
						If  dbSeek(xFilial("SC6")+_cPed1)
							While !Eof() .And. _cPed1 == SC6->C6_NUM
								_nQtdLiber := SC6->C6_QTDVEN
								RecLock("SC6")
								// Efetua a libera็ใo item a item de cada pedido
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
							dbSetOrder(1)
							if dbseek(xFilial("SC9")+_cPed1)
								While !Eof() .And. _cPed1 == SC9->C9_PEDIDO
									RecLock("SC9",.F.)
									SC9->C9_DTENTR := _cDtEn
									SC9->C9_VEND1  := _cVend
									MsUnlock()
									SC9->(dbSkip())
								EndDo
							Endif
						EndIf
						dbSelectArea("ZZN")
						dbSetOrder(2)
						If dbSeek(xFilial("ZZN")+_cChavSc5)
							RecLock("ZZN",.F.)
							ZZN->ZZN_AVALIA := "S"
							MsUnlock()
						EndIf
					EndIf
				ElseIf Empty(SC5->C5_LIBER2) .AND. !Empty(SC5->C5_APROV2)     &&tem aprovador 2 e ja aprovou 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER2 := "S"
					SC5->C5_DTLIB2 := DATE()
					SC5->C5_HRLIB2 := TIME()
					MsUnlock()
					dbSelectArea("ZZN")
					dbSetOrder(2)
					If dbSeek(xFilial("ZZN")+_cChavSc5)
						RecLock("ZZN",.F.)
						ZZN->ZZN_LIBER2 := "S"
						MsUnlock()
					EndIf
					If Empty(SC5->C5_APROV3)   &&Mauricio 13/05/11- se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
						RecLock("SC5",.F.)
						SC5->C5_BLQ := " "
						SC5->C5_LIBEROK := "S"
						MsUnlock()

						&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
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

						dbSelectArea("SC6")
						dbSetOrder(1)
						If  dbSeek(xFilial("SC6")+_cPed1)
							While !Eof() .And. _cPed1 == SC6->C6_NUM
								_nQtdLiber := SC6->C6_QTDVEN
								RecLock("SC6")
								// Efetua a libera็ใo item a item de cada pedido
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
							dbSetOrder(1)
							if dbseek(xFilial("SC9")+_cPed1)
								While !Eof() .And. _cPed1 == SC9->C9_PEDIDO
									RecLock("SC9",.F.)
									SC9->C9_DTENTR := _cDtEn
									SC9->C9_VEND1  := _cVend
									MsUnlock()
									SC9->(dbSkip())
								EndDo
							Endif
						EndIf
						dbSelectArea("ZZN")
						dbSetOrder(2)
						If dbSeek(xFilial("ZZN")+_cChavSc5)
							RecLock("ZZN",.F.)
							ZZN->ZZN_AVALIA := "S"
							MsUnlock()
						EndIf
					EndIf

				ElseIf Empty(SC5->C5_LIBER3) .AND. !Empty(SC5->C5_APROV3)  &&tem aprovador 3 e ja aprovou 1 e 2
					RecLock("SC5",.F.)
					SC5->C5_LIBER3 := "S"
					SC5->C5_DTLIB3 := DATE()
					SC5->C5_HRLIB3 := TIME()
					SC5->C5_BLQ := " "
					SC5->C5_LIBEROK := "S"
					MsUnlock()
					dbSelectArea("ZZN")
					dbSetOrder(2)
					If dbSeek(xFilial("ZZN")+_cChavSc5)
						RecLock("ZZN",.F.)
						ZZN->ZZN_LIBER3 := "S"
						MsUnlock()
					EndIf

					&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
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

					dbSelectArea("SC6")      &&como ้ o ultimo aprovador libero o pedido
					dbSetOrder(1)
					If  dbSeek(xFilial("SC6")+_cPed1)
						While !Eof() .And. _cPed1 == SC6->C6_NUM
							_nQtdLiber := SC6->C6_QTDVEN
							RecLock("SC6")
							// Efetua a libera็ใo item a item de cada pedido
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
						dbSetOrder(1)
						if dbseek(xFilial("SC9")+_cPed1)
							While !Eof() .And. _cPed1 == SC9->C9_PEDIDO
								RecLock("SC9",.F.)
								SC9->C9_DTENTR := _cDtEn
								SC9->C9_VEND1  := _cVend
								MsUnlock()
								SC9->(dbSkip())
							EndDo
						Endif	
					
					EndIf
					dbSelectArea("ZZN")
					dbSetOrder(2)
					If dbSeek(xFilial("ZZN")+_cChavSc5)
						RecLock("ZZN",.F.)
						ZZN->ZZN_AVALIA := "S"
						MsUnlock()
					EndIf
				EndIf
				
				//Everson - 16/07/2018. Checa libera็ใo financeira.
				//Fun็ใo chkBlCred disponํvel no fonte LIBPED1.
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				If SC9->(Dbseek(xFilial("SC9")+_cPed1))
					//Static Call(LIBPED1,chkBlCred, SC9->C9_CLIENTE,SC9->C9_LOJA,_cPed1)
					//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
					u_LIBPEDA0( SC9->C9_CLIENTE,SC9->C9_LOJA,_cPed1 )
				EndIf

				//log de aprova็ใo de pedido a pedido para a rede - fernando 20/07/2017
				u_GrLogZBE (Date(),TIME(),cUserName,"APROVACAO PEDIDO A PEDIDO PARA A REDE","COMERCIAL","LIBPED2",;
				"PEDIDO: "+_cPed1,ComputerName(),LogUserName())  

			EndIf


		EndIf


	Next


	For _n1 := 1 to Len(_aPedidos)

		If !(_aPedidos[_n1][01])
			_cPed1 := _aPedidos[_n1][02]

			dbSelectArea("SC5")
			dbSetOrder(1)		
			If dbSeek(xfilial("SC5")+_cPed1)
				If  Empty(SC5->C5_LIBER1) .And. !Empty(SC5->C5_APROV1)   &&tem aprovador 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER1  := "N"
					SC5->C5_DTLIB1  := DATE()
					SC5->C5_HRLIB1  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnlock()

				ElseIf Empty(SC5->C5_LIBER2) .AND. !Empty(SC5->C5_APROV2)    &&tem aprovador 2 e ja aprovou 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER2  := "N"
					SC5->C5_DTLIB2  := DATE()
					SC5->C5_HRLIB2  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnlock()

				ElseIf Empty(SC5->C5_LIBER3) .AND. !Empty(SC5->C5_APROV3)    &&tem aprovador 3 e ja aprovou 1 e 2
					RecLock("SC5",.F.)
					SC5->C5_LIBER3  := "N"
					SC5->C5_DTLIB3  := DATE()
					SC5->C5_HRLIB3  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnlock()
				EndIf			
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
				U_EMAILPEDRJ(_cPed1,_cVend1,_aASC6,"2")  		                   
			EndIf
		EndIf
	Next

	IPTAB2(_nOpc)  &&forco o recalculo do IPTAB por causa do pedido desconsiderado e reavalio a libera็ใo da rede.

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.

		AtuRede2(@_aRede,@_aPedidos,_nOpc)

	EndIf

	//Everson - 29/09/2017. Chamado 037261.
	If ! IsInCallStack('RESTEXECUTE') .And. oPedido != Nil

		oPedido:SetArray( _aRede )

		oPedido:bLine := { || { If( _aRede[oPedido:nAt][01],oOk,oNo),;
		_aRede[oPedido:nAt][02],;
		_aRede[oPedido:nAt][03],;
		_aRede[oPedido:nAt][04],;
		_aRede[oPedido:nAt][05],;
		_aRede[oPedido:nAt][06],;
		_aRede[oPedido:nAt][07],;
		_aRede[oPedido:nAt][08],;
		_aRede[oPedido:nAt][09]}}

		oPedido:Refresh()
	EndIf

	//Everson - 29/09/2017. Chamado 037261.
	If ! IsInCallStack('RESTEXECUTE') .And. oItemped != Nil

		oItemped:SetArray(_aPedidos)

		oItemped:bLine := { || {If(_aPedidos[oItemped:nAt][01],oOk1,oNo1),;
		_aPedidos[oItemped:nAt][02],;
		_aPedidos[oItemped:nAt][03],;
		_aPedidos[oItemped:nAt][04],;
		_aPedidos[oItemped:nAt][05],;
		_aPedidos[oItemped:nAt][06],;
		_aPedidos[oItemped:nAt][07],;
		_aPedidos[oItemped:nAt][08],;
		_aPedidos[oItemped:nAt][09],;
		_aPedidos[oItemped:nAt][10],;
		_aPedidos[oItemped:nAt][11],;
		_aPedidos[oItemped:nAt][12],;
		_aPedidos[oItemped:nAt][13],;
		_aPedidos[oItemped:nAt][14]}}

		oItemped:Refresh()

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ REJREDE  บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de rejei็ใo para toda a rede                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RejRede(_nOpc)           &&Mauricio 13/05/11 - rotina de rejei็ใo para toda a Rede
	Local _cQueryR := ""
	Local _n1
	/*
	Ao fazer altera็๕es na variแvel _aRede, verificar o fonte ADVEN052P, pois a rotina AprvRede estแ sendo utilizada no fonte
	ADVEN052P (servi็o Rest).
	Everson - 03/10/2017. Chamado 037261.
	*/

	For _n1 := 1 to len(_aRede)
		If _aRede[_n1][01]
			_cRede   := _aRede[_n1][02]
			_cChave  := _aRede[_n1][10]	

			_cQueryR := "SELECT * FROM "+RetSqlName("SC5")+" "
			_cQueryR += "WHERE C5_CODRED = '"+_cRede+"' AND "
			_cQueryR += "      C5_CHAVE  = '"+_cChave+"' AND "
			_cQueryR += "      C5_FILIAL = '"+cFilAnt+"' AND "
			_cQueryR += "      D_E_L_E_T_= ' ' "
			
			_cQueryR += "      AND C5_XGERSF <> '2' " //Everson - 10/05/2018. SalesForce 037261.
			
			_cQueryR += "ORDER BY C5_NUM"

			TCQUERY _cQueryR NEW ALIAS "LIBR"

			dbSelectArea("LIBR")
			dbGoTop()

			While LIBR->(!Eof())

				_cPed := LIBR->C5_NUM

				dbSelectArea("SC5")
				dbSetOrder(1)
				If dbSeek(xfilial("SC5")+_cPed)
					If     Empty(SC5->C5_LIBER1) .And. !Empty(SC5->C5_APROV1)   &&tem aprovador 1
						RecLock("SC5",.F.)
						SC5->C5_LIBER1  := "N"
						SC5->C5_DTLIB1  := DATE()
						SC5->C5_HRLIB1  := TIME()
						SC5->C5_BLQ     := " "
						SC5->C5_LIBEROK := 'E'
						MsUnlock()

					ElseIf Empty(SC5->C5_LIBER2) .AND. !Empty(SC5->C5_APROV2)   &&tem aprovador 2 e ja aprovou 1
						RecLock("SC5",.F.)
						SC5->C5_LIBER2  := "N"
						SC5->C5_DTLIB2  := DATE()
						SC5->C5_HRLIB2  := TIME()
						SC5->C5_BLQ     := " "
						SC5->C5_LIBEROK := 'E'
						MsUnlock()

					ElseIf Empty(SC5->C5_LIBER3) .AND. !Empty(SC5->C5_APROV3)   &&tem aprovador 3 e ja aprovou 1 e 2
						RecLock("SC5",.F.)
						SC5->C5_LIBER3  := "N"
						SC5->C5_DTLIB3  := DATE()
						SC5->C5_HRLIB3  := TIME()
						SC5->C5_BLQ     := " "
						SC5->C5_LIBEROK := 'E'
						MsUnlock()
					EndIf
					&&Mauricio 19/07/11 - Pedidos rejeitados (nao aprovados) devem ser excluidos conforme solicitacao Comercial/Sr. Alex.
					RecLock("SC5",.F.)
					dbdelete()
					MsUnlock()
					_aASC6 := {}
					dbSelectArea("SC6")
					dbSetOrder(1)		
					If dbSeek(xfilial("SC6")+_cPed)
						While !Eof() .And. SC6->C6_NUM == _cPed
							AADD(_aASC6,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_TES,SC6->C6_UM,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR})
							Reclock("SC6",.F.)
							dbdelete()
							Msunlock()
							SC6->(dbskip())
						Enddo
					Endif   

					dbSelectArea("SC9")
					dbSetOrder(1)		
					If dbSeek(xfilial("SC9")+_cPed)
						While !Eof() .And. SC9->C9_PEDIDO == _cPed
							Reclock("SC9",.F.)
							dbdelete()
							Msunlock()
							SC9->(dbskip())
						Enddo
					Endif

					&&Mauricio 03/08/11 - envio de email ao vendedor para pedidos rejeitados(excluidos).
					_cVend1 := SC5->C5_VEND1		  
					U_EMAILPEDRJ(_cPed,_cVend1,_aASC6,"2")

				EndIf

				dbSelectArea("ZZN")
				dbSetOrder(2)
				If dbSeek(xFilial("ZZN")+_cChave)
					RecLock("ZZN",.F.)
					ZZN->ZZN_AVALIA := "N"
					MsUnlock()
					RecLock("ZZN",.F.)
					dbdelete()
					MsUnlock()
				EndIf

				//log de rejeito de pedido do para toda a rede - fernando 20/07/2017
				u_GrLogZBE (Date(),TIME(),cUserName,"REJEITO PEDIDO PARA TODA A REDE","COMERCIAL","LIBPED2",;
				"PEDIDO: "+_cPed,ComputerName(),LogUserName())  


				dbSelectArea("LIBR")
				LIBR->(dbSkip())
			EndDo

			dbSelectArea("LIBR")
			LIBR->(dbCloseArea())
		EndIf


	Next

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.   
		AtuRede2(@_aRede,@_aPedidos,_nOpc)

	EndIf

	If ! IsInCallStack('RESTEXECUTE') .And. oPedido != Nil

		oPedido:SetArray( _aRede )

		oPedido:bLine := { || { If( _aRede[oPedido:nAt][01],oOk,oNo),;
		_aRede[oPedido:nAt][02],;
		_aRede[oPedido:nAt][03],;
		_aRede[oPedido:nAt][04],;
		_aRede[oPedido:nAt][05],;
		_aRede[oPedido:nAt][06],;
		_aRede[oPedido:nAt][07],;
		_aRede[oPedido:nAt][08],;
		_aRede[oPedido:nAt][09]}}

		oPedido:Refresh()
	EndIf


	If ! IsInCallStack('RESTEXECUTE') .And. oItemped != Nil

		oItemped:SetArray(_aPedidos)

		oItemped:bLine := { || {If(_aPedidos[oItemped:nAt][01],oOk1,oNo1),;
		_aPedidos[oItemped:nAt][02],;
		_aPedidos[oItemped:nAt][03],;
		_aPedidos[oItemped:nAt][04],;
		_aPedidos[oItemped:nAt][05],;
		_aPedidos[oItemped:nAt][06],;
		_aPedidos[oItemped:nAt][07],;
		_aPedidos[oItemped:nAt][08],;
		_aPedidos[oItemped:nAt][09],;
		_aPedidos[oItemped:nAt][10],;
		_aPedidos[oItemped:nAt][11],;
		_aPedidos[oItemped:nAt][12],;
		_aPedidos[oItemped:nAt][13],;
		_aPedidos[oItemped:nAt][14]}}

		oItemped:Refresh()

	EndIf 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ REJPED   บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de rejei็ใo por pedidos para a rede                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RejPed(_nOpc)           &&Mauricio 13/05/11 - rotina de rejeicao por pedidos para a Rede.

	Local _cQueryP := ""               &&Mauricio 18/05/11 - somente havera rejei็ใo para toda a Rede.
	&&VAgner solicitou da forma descrita abaixo.
	ApMsgInfo(OemToAnsi("Nao ha rejeicao por pedido. Fa็a a aprova็ใo por PEDIDO, sendo que os nao escolhidos serao rejeitados!"),OemToAnsi("A T E N ว ร O"))

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ IPTAB    บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua o calculo do IPTAB                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IPTAB(_nOpc)

	Local _n1
	Private _nSomaDig := 0
	Private _nSomaTab := 0
	Private _cNrPed   := ""
	Private _cC5REDE  := ""

	For _n1 := 1 to len(_aPedidos)
		_cNrPed := _aPedidos[_n1][02]
		If _aPedidos[_n1][01]
			CalcIp()
		EndIf
	Next

	dbSelectArea("ZZN")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZN")+_cC5REDE)
		RecLock("ZZN",.F.)
		ZZN->ZZN_VALDIG := _nSomaDig
		ZZN->ZZN_VALTAB := _nSomaTab
		ZZN->ZZN_IPTAB  := Round((_nSomaDig/_nSomaTab),3)
		MsUnlock()
	EndIf

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.   
		AtuRede(@_aRede,_nOpc)

	EndIf

	If oPedido != Nil

		oPedido:SetArray( _aRede )

		oPedido:bLine := { || { If(_aRede[oPedido:nAt][01],oOk,oNo),;
		_aRede[oPedido:nAt][02],;
		_aRede[oPedido:nAt][03],;
		_aRede[oPedido:nAt][04],;
		_aRede[oPedido:nAt][05],;
		_aRede[oPedido:nAt][06],;
		_aRede[oPedido:nAt][07],;
		_aRede[oPedido:nAt][08],;
		_aRede[oPedido:nAt][09]}}
		oPedido:Refresh()
	EndIf

return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ CALCIP   บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a somat๓ria do total digitado, do total de tabela e บฑฑ
ฑฑบ          ณ a REDE para o calculo do IPTAB                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CalcIp()

	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+_cNrPed)
		_nSomaDig += SC5->C5_TOTDIG
		_nSomaTab += SC5->C5_TOTTAB
		_cC5REDE  := SC5->C5_CODRED
	EndIf

return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ ATUREDE  บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o valor da REDE                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtuRede(_aRede,_nOpc)

	Local _aArea  := GetArea()
	Local _cAlias := GetNextAlias()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona Registros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If _nOpc == 1 .Or. _nOpc == 3
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_IPTAB ASC
		EndSql
	Elseif _nOpc == 2
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_QTDCXS DESC
		EndSql
	Endif

	// Alimenta array REDE
	_aRede := {}


	While (_cAlias)->(!Eof())

		If     Empty((_cAlias)->ZZN_LIBER1) .And. !Empty(ZZN->ZZN_APROV1)
			If __cUserID != (_cAlias)->ZZN_APROV1
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. Empty((_cAlias)->ZZN_LIBER2) .AND. !Empty((_cAlias)->ZZN_APROV2)
			If(_cAlias)->ZZN_APROV2 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. !Empty((_cAlias)->ZZN_LIBER2) .AND. Empty((_cAlias)->ZZN_LIBER3) .AND. !Empty((_cAlias)->ZZN_APROV3)
			If(_cAlias)->ZZN_APROV3 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		Else
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(_cAlias)->Rede+"00")	
			_cRepresent := SA1->A1_VEND                                                    //Vendedor rede
			_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprova็ใo
			_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
		else
			_cRepresent := Space(06)
			_cSupervi   := Space(06)
		endif      
		_cNomVend := Posicione("SA3",1,xfilial("SA3")+_cRepresent,"A3_NOME")
		if !(Empty((_cAlias)->ZZN_APROV1))    
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV1)
		elseif !(Empty((_cAlias)->ZZN_APROV2))     
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV2)
		endif      

		fSelSupervisor((_cAlias)->Chave,@_aPedidos,"G",@_aItens,_nOpc)

		AADD(_aRede,{lMark,ALLTRIM((_cAlias)->Rede),ALLTRIM(SUBSTR((_cAlias)->NOME,1,20)),Transform((_cAlias)->IPTAB,"@E 9.999"),;
		Transform((_cAlias)->CAIXAS,"@E 9999"),Transform((_cAlias)->VLRNF,"@E 999,999.99" ),;
		Transform((_cAlias)->DESCO,"@E 999,999.99" ),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup),;
		(_cAlias)->CHAVE})

		(_cAlias)->(dbSkip())

	EndDo
	If _nOpc == 3
		aSort(_aRede,,,{|x,y| x[9] > y[9]})
	Endif

	//EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Restaura area ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(_cAlias)->(dbCloseArea())

	RestArea( _aArea )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida Arrays ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(_aRede) <= 00
		AADD(_aRede,{lMark,OemToAnsi("Nao existem inFormacoes para a lista"),"",Transform(00,"@E 999,999.999"),Transform(00,"@E 9,999,999,999.99"),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"","",""})
	EndIf

	If Len(_aPedidos) <= 00
		AADD(_aPedidos,{lMark1,OemToAnsi("Nao existem informacoes para a lista"),"","","","",;
		"",Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),"",""})
	EndIf

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ ATUREDE2 บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o valor da REDE                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuRede2(_aRede,_aPedidos,_nOpc)

	Local _aArea  := GetArea()
	Local _cAlias := GetNextAlias()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona Registros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If _nOpc == 1 .Or. _nOpc == 3
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_IPTAB ASC
		EndSql
	Elseif _nOpc == 2
		BeginSql Alias _cAlias
			SELECT DISTINCT
			ZZN.ZZN_REDE   AS REDE,
			ZZN.ZZN_NOME   AS NOME,
			ZZN.ZZN_IPTAB  AS IPTAB,
			ZZN.ZZN_VALDIG AS VALDIG,
			ZZN.ZZN_VALTAB AS VALTAB,
			ZZN.ZZN_CHAVE  AS CHAVE,
			//ZZN.ZZN_QTCXS  AS CAIXAS,
			ZZN.ZZN_QTDCXS  AS CAIXAS,
			ZZN.ZZN_VLRNF  AS VLRNF,
			ZZN.ZZN_DESTBP AS DESCO,
			ZZN.ZZN_APROV1,
			ZZN.ZZN_APROV2,
			ZZN.ZZN_APROV3,
			ZZN.ZZN_LIBER1,
			ZZN.ZZN_LIBER2,
			ZZN.ZZN_LIBER3
			FROM
			%Table:ZZN% ZZN, %Table:SC5% SC5
			WHERE ZZN.ZZN_FILIAL = %xFilial:ZZN% AND
			ZZN.ZZN_CHAVE = SC5.C5_CHAVE AND
			ZZN.ZZN_AVALIA = %Exp:' '% AND
			SC5.%NotDel% AND
			ZZN.%NotDel%
			
			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.
			
			ORDER BY ZZN.ZZN_QTDCXS DESC
		EndSql
	Endif

	// Alimenta array REDE
	_aRede := {}
	_aPedidos := {}

	While (_cAlias)->(!Eof())

		If     Empty((_cAlias)->ZZN_LIBER1) .And. !Empty(ZZN->ZZN_APROV1)
			If __cUserID != (_cAlias)->ZZN_APROV1
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. Empty((_cAlias)->ZZN_LIBER2) .AND. !Empty((_cAlias)->ZZN_APROV2)
			If(_cAlias)->ZZN_APROV2 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf !Empty((_cAlias)->ZZN_LIBER1) .AND. !Empty((_cAlias)->ZZN_LIBER2) .AND. Empty((_cAlias)->ZZN_LIBER3) .AND. !Empty((_cAlias)->ZZN_APROV3)
			If(_cAlias)->ZZN_APROV3 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		Else
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(_cAlias)->Rede+"00")	
			_cRepresent := SA1->A1_VEND                                                    //Vendedor rede
			_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprova็ใo
			_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
		else
			_cRepresent := Space(06)
			_cSupervi   := Space(06)
		endif      
		_cNomVend := Posicione("SA3",1,xfilial("SA3")+_cRepresent,"A3_NOME")
		if !(Empty((_cAlias)->ZZN_APROV1))    
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV1)
		elseif !(Empty((_cAlias)->ZZN_APROV2))     
			_cNomSup  := UsrRetName((_cAlias)->ZZN_APROV2)
		endif      

		fSelSupervisor((_cAlias)->Chave,@_aPedidos,"G",@_aItens,_nOpc)

		AADD(_aRede,{lMark,ALLTRIM((_cAlias)->Rede),ALLTRIM(SUBSTR((_cAlias)->NOME,1,20)),Transform((_cAlias)->IPTAB,"@E 9.999"),;
		Transform((_cAlias)->CAIXAS,"@E 9999"),Transform((_cAlias)->VLRNF,"@E 999,999.99" ),;
		Transform((_cAlias)->DESCO,"@E 999,999.99" ),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup),;
		(_cAlias)->CHAVE})

		(_cAlias)->(dbSkip())

	EndDo
	If _nOpc == 3
		aSort(_aRede,,,{|x,y| x[9] > y[9]})
	Endif
	//EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Restaura area ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(_cAlias)->(dbCloseArea())

	RestArea( _aArea )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida Arrays ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(_aRede) <= 00
		AADD(_aRede,{lMark,OemToAnsi("Nao existem inFormacoes para a lista"),"",Transform(00,"@E 999,999.999"),Transform(00,"@E 9,999,999,999.99"),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"","",""})
	EndIf

	If Len(_aPedidos) <= 00
		AADD(_aPedidos,{lMark1,OemToAnsi("Nao existem informacoes para a lista"),"","","","","",;
		"",Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),"",""})
	EndIf

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ IPTAB2   บAutor  ณ Mauricio Silva     บ Data ณ  13/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recalcula o IPTAB quando aprova็ใo por pedido e libera pe- บฑฑ
ฑฑบ          ณ didos com recalculo superior a 1 (IPTAB), ignorando al็a-- บฑฑ
ฑฑบ          ณ das posteriores                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico A'DORO                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IPTAB2(_nOpc)
	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F. //.T. Mauricio 26/07/11
	Local _n1

	Private _nSomaDig := 0
	Private _nSomaTab := 0
	Private _cNrPed   := ""
	Private _cC5REDE  := ""

	For _n1 := 1 to len(_aPedidos)
		_cNrPed := _aPedidos[_n1][02]
		If _aPedidos[_n1][01]
			CalcIp()
		EndIf
	Next

	dbSelectArea("ZZN")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZN")+_cC5REDE)
		RecLock("ZZN",.F.)
		ZZN->ZZN_VALDIG := _nSomaDig
		ZZN->ZZN_VALTAB := _nSomaTab
		ZZN->ZZN_IPTAB  := Round((_nSomaDig/_nSomaTab),3)
		MsUnlock()
		If _nSomaDig >= _nSomaTab  &&caso iptab fique positivo
			_cRede   := ZZN->ZZN_REDE
			_cChave  := ZZN->ZZN_CHAVE

			If Select("LIBR") > 0
				dbSelectArea("LIBR")
				DbCLoseArea("LIBR")
			EndIf   

			_cQueryR := "SELECT * FROM "+RetSqlName("SC5")+" "
			_cQueryR += "WHERE C5_CODRED = '"+_cRede+"' AND "
			_cQueryR += "      C5_CHAVE  = '"+_cChave+"' AND "
			_cQueryR += "      C5_FILIAL = '"+cFilAnt+"' AND "
			_cQueryR += "      C5_LIBEROK <> 'E' AND C5_LIBEROK <> 'S' AND"
			_cQueryR += "      D_E_L_E_T_= ' ' "
			
			_cQueryR += "      AND C5_XGERSF <> '2' " //Everson - 10/05/2018. SalesForce 037261.
			
			_cQueryR += "ORDER BY C5_NUM"

			TCQUERY _cQueryR NEW ALIAS "LIBR"

			dbSelectArea("LIBR")
			dbGoTop()

			While LIBR->(!Eof())

				_cPed := LIBR->C5_NUM
				_cDtEn := STOD(LIBR->C5_DTENTR)
				_cVend := LIBR->C5_VEND1

				dbSelectArea("SC5")
				dbSetOrder(1)

				If  dbSeek(xfilial("SC5")+_cPed)
					RecLock("SC5",.F.)
					SC5->C5_BLQ := " "
					SC5->C5_LIBEROK := "S"
					MsUnlock()

					&&Mauricio - 18/06/14 - Tratamento para garantir que nใo ha SC9 gerado(problema duplicidade de registros nesta tabela)
					dbSelectArea("SC9")
					dbSetOrder(1)		
					If dbSeek(xfilial("SC9")+_cPed)
						While !Eof() .And. SC9->C9_PEDIDO == _cPed
							Reclock("SC9",.F.)
							dbdelete()
							Msunlock()
							SC9->(dbskip())
						Enddo
					endif

					dbSelectArea("SC6")
					dbSetOrder(1)
					If  dbSeek(xFilial("SC6")+_cPed)
						While !Eof() .And. _cPed == SC6->C6_NUM
							_nQtdLiber := SC6->C6_QTDVEN
							RecLock("SC6")
							// Efetua a libera็ใo item a item de cada pedido
							Begin transaction
								MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
							End transaction
							SC6->(MsUnLock())

							Begin Transaction
								SC6->(MaLiberOk({_cPed},.F.))
							End Transaction
							SC6->(dbSkip())
						EndDo
						DbSelectArea("SC9")
						dbSetOrder(1)
						if dbseek(xFilial("SC9")+_cPed)
							While !Eof() .And. _cPed == SC9->C9_PEDIDO								
								RecLock("SC9",.F.)
								SC9->C9_DTENTR := _cDtEn
								SC9->C9_VEND1  := _cVend
								MsUnlock()   
								SC9->(dbSkip())
							EndDo
						Endif
					EndIf
				EndIf
				dbSelectArea("LIBR")
				LIBR->(dbSkip())			
			EndDo

			dbSelectArea("ZZN")
			dbSetOrder(2)
			If dbSeek(xfilial("ZZN")+_cChave)			
				RecLock("ZZN",.F.)			
				If __cUserId == ZZN->ZZN_APROV1
					ZZN->ZZN_AVALIA := "S"
					ZZN->ZZN_LIBER1 := "S"
				EndIf
				If __cUserId == ZZN->ZZN_APROV2  .AND. !(empty(ZZN->ZZN_LIBER1))
					ZZN->ZZN_AVALIA := "S"
					ZZN->ZZN_LIBER2 := "S"
				EndIf
				If __cUserId == ZZN->ZZN_APROV3.And. !(Empty(ZZN->ZZN_LIBER1)) .And. !(Empty(ZZN->ZZN_LIBER2))
					ZZN->ZZN_AVALIA := "S"
					ZZN->ZZN_LIBER3 := "S"
				EndIf                     			  
				MsUnlock()
			EndIf

			dbSelectArea("LIBR")
			LIBR->(dbCloseArea())	    
		EndIf
	EndIf

	If ! IsInCallStack('RESTEXECUTE')
		AtuRede(@_aRede,_nOpc)

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Efetua Refresh ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ! IsInCallStack('RESTEXECUTE') .And. oPedido != Nil

		oPedido:SetArray( _aRede )

		oPedido:bLine := { || { If(_aRede[oPedido:nAt][01],oOk,oNo),;
		_aRede[oPedido:nAt][02],;
		_aRede[oPedido:nAt][03],;
		_aRede[oPedido:nAt][04],;
		_aRede[oPedido:nAt][05],;
		_aRede[oPedido:nAt][06],;
		_aRede[oPedido:nAt][07],;
		_aRede[oPedido:nAt][08],;
		_aRede[oPedido:nAt][09]}}
		oPedido:Refresh()
	EndIf



return() 

static function MTHCProc()
	oDlg:End()
return(.T.)
