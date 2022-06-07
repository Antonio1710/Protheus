#include "TOTVS.CH"
#Include "Protheus.ch"
#Include "topconn.CH"

/*/{Protheus.doc} User Function LIBPED1
	Tela de liberacao de pedidos loja.
	@type  Function
	@author Mauricio
	@since 17/05/2011
	@version 01
	@history Chamado 17/05/2011  - MauricioHC - Desenvolvimento.
	@history Ticket 045119.   Everson 12/11/2018. Comentado o trecho de código que não bloqueava pedido exportação por crédito.  
	@history Ticket T.I - Chamado T.I - Fernado Sigoli 06/06/2019 - tratamemto do erro log, quando existir apenas aprovacao Nível 3.
	@history Ticket 9300 - Leonardo P. Monteiro 10/02/2021 - Inclusão de parâmetro para que a rotina não seja executada na emrpesa Ceres(02) .
	@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/

User Function Libped1()

	Private oOK := LoadBitmap( GetResources(), "CHECKED" )
	Private oNO := LoadBitmap( GetResources(), "UNCHECKED" )
	Private lMark    	:= .F.
	Private lChk     	:= .F.
	Private oDLG
	Private _aPedido	:= {}         //Pedidos   
	Private _aSupervisor := {}
	Private oItemped
	Private aCombo1     := {}
	Private cCombo1     := Space(18)
	Private oCombo1     := NIl
	Private nCombo1     := 1
	Private cExcEmp		:= Alltrim(SuperGetMv("MV_#EMPEXL",,"02"))

	//Ticket 9300 - Leonardo P. Monteiro 10/02/2021 - Inclusão de parâmetro para que a rotina não seja executada na emrpesa Ceres(02) .
	if !cEmpAnt$cExcEmp
	
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos loja ')

		aAdd( aCombo1,"Ordem IPTAB" )
		aAdd( aCombo1,"Ordem Volume" )
		aAdd( aCombo1,"Ordem Supervisor" )              
		_aPedido := {}
		_aSupervisor := {}

		DEFINE DIALOG oDlg TITLE "Liberacao Varejo" FROM 001,001 TO 500,1100 PIXEL
		//260,184    largura, altura 

		@ 001,001 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
		ON CLICK(aEval(_aPedido,{|x| x[1]:=lChk}),oPedido:Refresh())                              

		oPedido := TWBrowse():New( 10 , 01, 500,100,,{OemToAnsi(" "),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Entrega"),OemToAnsi("Cod."),;
		OemToAnsi("Cliente"),OemToAnsi("TB ESC"),OemToAnsi("TB ORI"),OemToAnsi("IPTAB"),OemToAnsi("Qtd.CXs"),;
		OemToAnsi("Valor NF"),OemToAnsi("Val. Desc."),OemToAnsi("Vendedor"),OemToAnsi("Supervisor")},;
		{15,20,20,20,20,40,20,20,20,20,30,20,10,10},;
		oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

		MsAguarde( {|| AtuListBox( @_aPedido, @_aSupervisor,1 ) }, OemToAnsi( "Aguarde" ) )

		oPedido:SetArray(_aPedido)

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
		_aPedido[oPedido:nAt][12],;								
		_aPedido[oPedido:nAt][13],;
		_aPedido[oPedido:nAt][14]}}

		// Troca a imagem no duplo click do mouse
		oPedido:bLDblClick := {|| _aPedido[oPedido:nAt][1] := !_aPedido[oPedido:nAt][1],;
		oPedido:DrawSelect()} 

		oPedido:bChange := { || fSelSupervisor( _aPedido[ oPedido:nAt ][ 02 ], @_aSupervisor, "S" ) }


		//oPedido:Refresh()   aqui reside o problema da apresentação das linhas no listbox....
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta ListBox Itens        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 120,001 ListBox oItemped Var cVar ;
		Fields Header ;
		OemToAnsi("Item"),;
		OemToAnsi("Produto"),;
		OemToAnsi("Descricao"),;
		OemToAnsi("Qtd. KGs"),;               
		OemToAnsi("Valor NF"),;
		OemToAnsi("Qtd. cxs"),;
		OemToAnsi("IPTAB"),;          //12  7
		OemToAnsi("PBTTV"),;          //7   8
		OemToAnsi("PLTTV"),;          //8   9
		OemToAnsi("PLTAB"),;          //9   10
		OemToAnsi("PLTVD"),;          //10  11
		OemToAnsi("PLTSP"),;          //11  12
		Size 500,080 Of oDlg Pixel       //-20  -40


		@ 220,200 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 Pixel Of ODlg on change nCombo1 := oCombo1:nAt    //100
		@ 210,200 BUTTON "REORDENAR" SIZE 040,010 PIXEL OF oDlg Action AtuListBox( @_aPedido, @_aSupervisor, nCombo1 )
		@ 210,030 BUTTON "Aprovar"  SIZE 040,020 PIXEL OF oDlg Action U_APROVA1()     //150
		@ 210,080 BUTTON "Rejeitar" SIZE 040,020 PIXEL OF oDlg Action U_REJEITA1()	  //150 
		@ 210,130 BUTTON "Nomenclaturas"  SIZE 040,020 PIXEL OF oDlg Action U_NOMTAB()     //150

		@ 210,320 BUTTON "SAIR" SIZE 040,020 PIXEL OF oDlg Action oDlg:End()	


		oItemped:SetArray( _aSupervisor )

		oItemped:bLine := { || {_aSupervisor[oItemped:nAt][01],;
		_aSupervisor[oItemped:nAt][02],;
		_aSupervisor[oItemped:nAt][03],;
		_aSupervisor[oItemped:nAt][04],;
		_aSupervisor[oItemped:nAt][05],;
		_aSupervisor[oItemped:nAt][06],;
		_aSupervisor[oItemped:nAt][07],;
		_aSupervisor[oItemped:nAt][08],;
		_aSupervisor[oItemped:nAt][09],;
		_aSupervisor[oItemped:nAt][10],;
		_aSupervisor[oItemped:nAt][11],;									
		_aSupervisor[oItemped:nAt][12]}}

		//oItemped:Refresh()

		ACTIVATE DIALOG oDlg CENTERED
	
	//Ticket 9300 - Leonardo P. Monteiro 10/02/2021 - Inclusão de parâmetro para que a rotina não seja executada na emrpesa Ceres(02) .
	else
		MsgInfo("Não é permitido a execução da rotina na empresa '"+ cEmpAnt +"'! ")
	endif

Return()

Static Function AtuListBox( _aPedido, _aSupervisor,_nOpc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea			:= GetArea()
	Local _cAlias			:= GetNextAlias()
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	Local _dData            := GetMv("MV_DTATR")
	Local _TabOrigem        := ""  
	Local _cNomSup          := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If _nOpc == 1 .Or. _nOpc == 3
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
			SC5.C5_TABELA
			FROM %Table:SC5% SC5
			WHERE SC5.C5_FILIAL = %xFilial:SC5% AND
			SC5.C5_BLQ = %Exp:'1'% AND
			SC5.C5_XREDE = %Exp:'N'% AND
			SC5.C5_LIBEROK <> %Exp:'E'% AND
			SC5.C5_EMISSAO > %Exp:DtoS(_dData)% AND
			SC5.%NotDel%

			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. Tratamento SalesForce. Chamado 037261.

			ORDER BY SC5.C5_XIPTAB ASC
		EndSql
	Elseif _nOpc == 2
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
			SC5.C5_TABELA
			FROM %Table:SC5% SC5
			WHERE SC5.C5_FILIAL = %xFilial:SC5% AND
			SC5.C5_BLQ = %Exp:'1'% AND
			SC5.C5_XREDE = %Exp:'N'% AND
			SC5.C5_LIBEROK <> %Exp:'E'% AND
			SC5.C5_EMISSAO > %Exp:DtoS(_dData)% AND
			SC5.%NotDel%

			AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. Tratamento SalesForce. Chamado 037261.

			ORDER BY SC5.C5_VOLUME1 DESC
		EndSql
	ENDIF

	_aPedido := {}

	While (_cAlias)->(!Eof())

		If Empty((_cAlias)->C5_LIBER1).AND. !(Empty((_cAlias)->C5_APROV1))
			If (_cAlias)->C5_APROV1 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf  Empty((_cAlias)->C5_LIBER2) .AND. !(Empty((_cAlias)->C5_APROV2))
			If (_cAlias)->C5_APROV2 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf    
		ElseIf  Empty((_cAlias)->C5_LIBER3) .AND. !(Empty((_cAlias)->C5_APROV3))
			If (_cAlias)->C5_APROV3 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf 
		Else
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		&&Mauricio - Acrescentar aqui tratamento para nome do vendedor do pedido e aprovador(a partir do codigo do aprovador).
		&&Parei aqui em 10/08/11.
		_cNomVend := Posicione("SA3",1,xfilial("SA3")+(_cAlias)->C5_VEND1,"A3_NOME")
		if !(Empty((_cAlias)->C5_APROV1))    
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV1)
		elseif !(Empty((_cAlias)->C5_APROV2))     
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV2)
		elseif !(Empty((_cAlias)->C5_APROV3))             //Chamado T.I - Fernado Sigoli 06/06/2019     
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV3)
		endif   

		// Alex Borges 08/03/12
		_TabOrigem := Posicione("SA1",1,xfilial("SA1")+(_cAlias)->C5_CLIENTE,"A1_TABELA")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ranking Gerentes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fSelSupervisor( (_cAlias)->C5_NUM, @_aSupervisor, "G" )
		&&anterior sendo substituido....  AADD( _aPedido, {lMark,(_cAlias)->C5_NUM, DTOC(STOD((_cAlias)->C5_EMISSAO)),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,(_cAlias)->C5_NOMECLI,(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999,999.99"),transform((_cAlias)->C5_TOTDIG,"@E 999,999,999,999.99"),transform((_cAlias)->C5_TOTTAB,"@E 999,999,999,999.99")  } )
		//AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 9,999"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,_TabOrigem,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 999,999.9999"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		(_cAlias)->(dbSkip())

	EndDo

	If _nOpc == 3
		aSort(_aPedido,,,{|x,y| x[14] > y[14]})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura area ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida Arrays ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(_aPedido) <= 00
		/*     Mauricio so para testes com o list box
		For _nz := 1 to 30
		AADD(_aPedido,{lMark,OemToAnsi("Nao existem informacoes para a lista" ),STRZERO(_nZ,3),"","","","","",Transform(00,"@E 9,999,999,999.99" ),;
		TransForm(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"000001","000112"})
		Next _nz
		*/
		AADD(_aPedido,{lMark,OemToAnsi("Nao existem informacoes para a lista" ),"","","","","","",Transform(00,"@E 9,999,999,999.99" ),;
		TransForm(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"000001","000112"})               
	EndIf

	If Len(_aSupervisor) <= 00
		AADD(_aSupervisor,{"",OemToAnsi("Nao existem informacoes para a lista"),"",Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),Transform(00,"@E 999,999,999,999.99" ),Transform(00,"@E 999,999,999,999.999")})
	EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fSelSupervisor³ Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna valores de vendas por Supervisores                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
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
	//_cQuery += "SC6.C6_TOTTAB,DA1.DA1_XPRLIQ,SC6.C6_PBTTV, SC6.C6_PLTTV, SC6.C6_PLTVD, SC6.C6_PLTSP, SC6.C6_QTDVEN "   Alex Borges 05/09 Buscar o PLTAB no dia do pedidos e nao na tabela vigente.
	_cQuery += "SC6.C6_TOTTAB,SC6.C6_PBTTV, SC6.C6_PLTTV, SC6.C6_PLTVD, SC6.C6_PLTSP, SC6.C6_PLTAB,SC6.C6_QTDVEN " 
	//_cQuery += "SC6.C6_PRTABV "    &&Mauricio 26/07/11 - aguardando criação de campo em produção.
	_cQuery += "From "
	_cQuery += RetSqlName( "SC5" ) + " SC5, "
	_cQuery += RetSqlName( "SC6" ) + " SC6, "
	_cQuery += RetSqlName( "DA1" ) + " DA1
	_cQuery += " Where SC5.C5_NUM = '" + _cGerente + "' "
	//_cQuery += "And SC5.C5_TIPO = 'N' "
	//_cQuery += "And SC5.C5_BLQ != 'R' "
	_cQuery += "And SC5.C5_FILIAL = '" + xFilial( "SC5" ) + "' "
	_cQuery += "And SC5.D_E_L_E_T_ = ' ' "

	_cQuery += " AND SC5.C5_XGERSF <> '2' " //Everson - 10/05/2018. SalesForce 037261.

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
		&&Mauricio 26/07/11 - aguardando criação de campo em produção.
		//AADD( _aSupervisor,{Itens->C6_ITEM,Itens->C6_PRODUTO,Itens->C6_DESCRI,Transform(Itens->C6_PRCVEN,"@E 9,999,999,999.99"),Transform(Itens->C6_PRTABV,"@E 9,999,999,999.99"),Transform(Itens->C6_UNSVEN,"@E 9,999,999,999.99"),;
		AADD( _aSupervisor,{ALLTRIM(Itens->C6_ITEM),ALLTRIM(Itens->C6_PRODUTO),ALLTRIM(Substr(Itens->C6_DESCRI,1,30)),Transform(Itens->C6_QTDVEN,"@E 999,999.9999"),Transform(Itens->C6_PRCVEN,"@E 99,999.99"),Transform(Itens->C6_UNSVEN,"@E 999,999.9999"),Transform(Itens->C6_XIPTAB,"@E 99.999"),Transform(Itens->C6_PBTTV,"@E 999.99"),;
		Transform(Itens->C6_PLTTV,"@E 999.99"),Transform(Itens->C6_PLTAB,"@E 999.99"),Transform(Itens->C6_PLTVD,"@E 999.99"),;
		Transform(Itens->C6_PLTSP,"@E 999.99")})
		Itens->(dbSkip())
	EndDo

	Itens->( dbCloseArea() )

	If Len(_aSupervisor) <= 00
		AADD(_aSupervisor,{"",OemToAnsi("Nao existem informacoes para a lista"),"",Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),Transform(00,"@E 9,999,999,999.99" ),;
		Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 999,999.99"),Transform(00,"@E 999,999,999,999.99" ),;
		Transform(00,"@E 999,999,999,999.99" ),Transform(00,"@E 999,999,999,999.99" ),Transform(00,"@E 999,999,999,999.999")})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua Refresh ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oItemped != Nil

		oItemped:SetArray( _aSupervisor )

		oItemped:bLine := { || {_aSupervisor[oItemped:nAt][01],;
		_aSupervisor[oItemped:nAt][02],;
		_aSupervisor[oItemped:nAt][03],;
		_aSupervisor[oItemped:nAt][04],;
		_aSupervisor[oItemped:nAt][05],;
		_aSupervisor[oItemped:nAt][06],;
		_aSupervisor[oItemped:nAt][07],;
		_aSupervisor[oItemped:nAt][08],;
		_aSupervisor[oItemped:nAt][09],;
		_aSupervisor[oItemped:nAt][10],;
		_aSupervisor[oItemped:nAt][11],;									
		_aSupervisor[oItemped:nAt][12]}}
		oItemped:Refresh()
		oDlg:Refresh()

	EndIf

Return ( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VISPED3        Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza o pedido de vendas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VISPED3(_nPOS)

	_cNumero := _aPedido[_nPos][2]  //posicao da coluna numero do pedido no _aPedido

	U_ADINF009P('LIBPED1' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos loja ')

	DbSelectArea("SC5")
	DbSetOrder(1)
	If dbSeek(xFilial("SC5")+_cNumero)
		A410Visual("SC5",SC5->( Recno() ), 1 )
	Else
		ApMsgInfo(OemToAnsi("Pedido nao encontrado na base de dados"))
	Endif   

	oPedido:Refresh()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MARKPED2     ³ Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca os pedidos a serem aprovados ou não                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MarkPed2()
	Local _n1
	For _n1 := 1 to Len(_aPedido)
		If _aPedido[_n1][01]
			MsgAlert("Pedido marcado: "+_aPedido[_n1][02])
		EndIf
	Next       

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ APROVA1      ³ Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a aprovação dos pedidos marcados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function APROVA1()

	Local _lPedi  := .F.
	Local _n1
	U_ADINF009P('LIBPED1' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos loja ')

	For _n1 := 1 to Len(_aPedido)   // Verifica Loja
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ REJEITA1     ³ Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a rejeição dos pedidos de vendas da loja            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function REJEITA1()

	Local _lPedi  := .F.
	Local _n1
	U_ADINF009P('LIBPED1' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de liberacao de pedidos loja ')

	For _n1 := 1 to Len(_aPedido)   // Verifica Loja
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ APRVPED  ºAutor  ³ Mauricio Silva     º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de aprovação por pedido(Loja)                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico A'DORO                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AprvPed()           &&Mauricio 13/05/11 - rotina de aprovação por pedidos.

	Local _cQueryP := ""
	Local lLiber   := .F.
	Local lTrans   := .F.
	Local lCredito := .F.
	Local lEstoque := .F.
	Local lAvCred  := .T.
	Local lAvEst   := .F.  //.T. Mauricio 26/07/11.
	Local _n1

	For _n1 := 1 to Len(_aPedido)

		If _aPedido[_n1][01]
			_cPed1   := _aPedido[_n1][02]

			dbSelectArea("SC5")
			dbSetOrder(1)
			If  dbSeek(xfilial("SC5")+_cPed1)
				_cDtEn := SC5->C5_DTENTR
				_cVend := SC5->C5_VEND1
				If  Empty(SC5->C5_LIBER1) .And. !Empty(SC5->C5_APROV1)  &&tem aprovador 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER1 := "S"
					SC5->C5_DTLIB1 := DATE()
					SC5->C5_HRLIB1 := TIME()
					MSUNLOCK()

					If  Empty(SC5->C5_APROV2) .And. Empty(SC5->C5_APROV3)     &&se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
						Reclock("SC5",.F.)
						SC5->C5_BLQ := " "
						SC5->C5_LIBEROK := "S"
						MSUNLOCK()

						&&Mauricio - 18/06/14 - Tratamento para garantir que não ha SC9 gerado(problema duplicidade de registros nesta tabela)
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
					EndIf
				ElseIf Empty(SC5->C5_LIBER2) .AND. !Empty(SC5->C5_APROV2)     &&tem aprovador 2 e ja aprovou 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER2 := "S"
					SC5->C5_DTLIB2 := DATE()
					SC5->C5_HRLIB2 := TIME()
					MSUNLOCK()

					If Empty(SC5->C5_APROV3)   &&Mauricio 13/05/11- se nao tem mais aprovadores libero o pedido, senao aguardo proximo aprovador
						Reclock("SC5",.F.)
						SC5->C5_BLQ := " "
						SC5->C5_LIBEROK := "S"
						MSUNLOCK()

						&&Mauricio - 18/06/14 - Tratamento para garantir que não ha SC9 gerado(problema duplicidade de registros nesta tabela)
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
					EndIf

				ElseIf Empty(SC5->C5_LIBER3) .AND. !Empty(SC5->C5_APROV3)  &&tem aprovador 3 e ja aprovou 1 e 2
					RecLock("SC5",.F.)
					SC5->C5_LIBER3 := "S"
					SC5->C5_DTLIB3 := DATE()
					SC5->C5_HRLIB3 := TIME()
					SC5->C5_BLQ := " "
					SC5->C5_LIBEROK := "S"
					MSUNLOCK()

					&&Mauricio - 18/06/14 - Tratamento para garantir que não ha SC9 gerado(problema duplicidade de registros nesta tabela)
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

					dbSelectArea("SC6")      &&como é o ultimo aprovador libero o pedido
					dbSetOrder(1)
					If  dbSeek(xFilial("SC6")+_cPed1)
						While !Eof() .And. _cPed1 == SC6->C6_NUM
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
				EndIf
				
				//Everson - 16/07/2018. Checa liberação financeira.
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				If SC9->(Dbseek(xFilial("SC9")+_cPed1))
					chkBlCred(SC9->C9_CLIENTE,SC9->C9_LOJA,_cPed1)
				
				EndIf

				//log de aprovação de pedido do varejo  - fernando 20/07/2017
				u_GrLogZBE (Date(),TIME(),cUserName,"APROVACAO PEDIDO VAREJO","COMERCIAL","LIBPED1",;
				"PEDIDO: "+_cPed1,ComputerName(),LogUserName())  

			EndIf

		EndIf


	Next

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.
		AtuPed(@_aPedido)

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua Refresh                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		_aPedido[ oPedido:nAt ][ 12 ]	,;								
		_aPedido[ oPedido:nAt ][ 13 ]   ,;
		_aPedido[ oPedido:nAt ][ 14 ] } }

		oPedido:Refresh()
		oDlg:Refresh()

	Endif    


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ REJPED   ºAutor  ³ Mauricio Silva     º Data ³  13/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de rejeição por pedidos para LOJA                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico A'DORO                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RejPed()           &&Mauricio 13/05/11 - rotina de rejeicao por pedidos.
	Local _n1
	
	For _n1 := 1 to Len(_aPedido)

		If _aPedido[_n1][01]
			_cPed1 := _aPedido[_n1][02]

			dbSelectArea("SC5")
			dbSetOrder(1)

			If dbSeek(xfilial("SC5")+_cPed1)
				If     Empty(SC5->C5_LIBER1) .And. !(Empty(SC5->C5_APROV1))   &&tem aprovador 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER1  := "N"
					SC5->C5_DTLIB1  := DATE()
					SC5->C5_HRLIB1  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnLock()

				ElseIf Empty(SC5->C5_LIBER2) .AND. !(Empty(SC5->C5_APROV2))    &&tem aprovador 2 e ja aprovou 1
					RecLock("SC5",.F.)
					SC5->C5_LIBER2  := "N"
					SC5->C5_DTLIB2  := DATE()
					SC5->C5_HRLIB2  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnLock()

				ElseIf Empty(SC5->C5_LIBER3) .AND. !(Empty(SC5->C5_APROV3))    &&tem aprovador 3 e ja aprovou 1 e 2
					RecLock("SC5",.F.)
					SC5->C5_LIBER3  := "N"
					SC5->C5_DTLIB3  := DATE()
					SC5->C5_HRLIB3  := TIME()
					SC5->C5_BLQ     := " "
					SC5->C5_LIBEROK := 'E'
					MsUnLock()
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
				U_EMAILPEDRJ(_cPed1,_cVend1,_aASC6,"1")

				//log de rejeito de pedido do varejo
				u_GrLogZBE (Date(),TIME(),cUserName,"REJEITO PEDIDO VAREJO","COMERCIAL","LIBPED1",;
				"PEDIDO: "+_cPed1,ComputerName(),LogUserName())  

			EndIf

		EndIf


	Next

	If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.
		AtuPed(@_aPedido)

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua Refresh                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		_aPedido[ oPedido:nAt ][ 12 ]	,;								
		_aPedido[ oPedido:nAt ][ 13 ]   ,;
		_aPedido[ oPedido:nAt ][ 14 ] } }

		oPedido:Refresh()
		oDlg:Refresh()

	Endif    

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ATUPED       ³ Autor ³ Mauricio          ³ Data ³20.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a atualização do pedido de venda                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuPed( _aPedido)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea			:= GetArea()
	Local _cAlias			:= GetNextAlias()
	Local _aRetVendas		:= {}
	Local _aRetFaturamento	:= {}
	Local _dData            := GetMv("MV_DTATR") 
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
		SC5.C5_TABELA
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %xFilial:SC5% AND
		SC5.C5_BLQ = %Exp:'1'% AND
		SC5.C5_XREDE = %Exp:'N'% AND
		SC5.C5_LIBEROK <> %Exp:'E'% AND
		SC5.C5_EMISSAO > %Exp:DtoS(_dData)% AND
		SC5.%NotDel%

		AND SC5.C5_XGERSF <> %Exp:'2'% //Everson - 10/05/2018. SalesForce 037261.

		ORDER BY SC5.C5_XIPTAB
	EndSql

	_aPedido := {}

	While (_cAlias)->(!Eof())

		If Empty((_cAlias)->C5_LIBER1).AND. !(Empty((_cAlias)->C5_APROV1))
			If (_cAlias)->C5_APROV1 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf
		ElseIf  Empty((_cAlias)->C5_LIBER2) .AND. !(Empty((_cAlias)->C5_APROV2))
			If (_cAlias)->C5_APROV2 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf    
		ElseIf  Empty((_cAlias)->C5_LIBER3) .AND. !(Empty((_cAlias)->C5_APROV3))
			If (_cAlias)->C5_APROV3 != __cUserID
				(_cAlias)->(dbSkip())
				Loop
			EndIf 
		Else
			(_cAlias)->(dbSkip())
			Loop
		EndIf

		&&Mauricio - Acrescentar aqui tratamento para nome do vendedor do pedido e aprovador(a partir do codigo do aprovador).
		&&Parei aqui em 10/08/11.
		_cNomVend := Posicione("SA3",1,xfilial("SA3")+(_cAlias)->C5_VEND1,"A3_NOME")
		
		if !(Empty((_cAlias)->C5_APROV1))    
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV1)
		elseif !(Empty((_cAlias)->C5_APROV2))     
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV2)
		elseif !(Empty((_cAlias)->C5_APROV3))             //Chamado T.I - Fernado Sigoli 06/06/2019     
			_cNomSup  := UsrRetName((_cAlias)->C5_APROV3)
		endif   

		// Alex Borges 08/03/12
		_TabOrigem := Posicione("SA1",1,xfilial("SA1")+(_cAlias)->C5_CLIENTE,"A1_TABELA")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ranking Gerentes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! IsInCallStack('RESTEXECUTE') //Everson - 21/09/2017. Chamado 037261.  
			fSelSupervisor( (_cAlias)->C5_NUM, @_aSupervisor, "G" )	

		EndIf

		AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,_TabOrigem,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 99,999.99"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		//AADD( _aPedido, {lMark,ALLTRIM((_cAlias)->C5_NUM), ALLTRIM(DTOC(STOD((_cAlias)->C5_EMISSAO))),DTOC(STOD((_cAlias)->C5_DTENTR)), (_cAlias)->C5_CLIENTE,ALLTRIM((_cAlias)->C5_NOMECLI),(_cAlias)->C5_TABELA,transform((_cAlias)->C5_XIPTAB,"@E 999.999"),transform((_cAlias)->C5_VOLUME1,"@E 99,999.99"),transform((_cAlias)->C5_VALORNF,"@E 999,999.99"),transform((_cAlias)->C5_DESCTBP,"@E 999,999.99"),ALLTRIM(_cNomVend),ALLTRIM(_cNomSup)  } )
		//ALEX BORGES 08/03/12

		(_cAlias)->(dbSkip())

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura area ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(_cAlias)->( dbCloseArea() )

	RestArea( _aArea )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida Arrays ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(_aPedido,{lMark,OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",Transform(00,"@E 9,999,999,999.99" ),;
	TransForm(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),Transform(00,"@E 9,999,999,999.99"),"","",""})

Return ( Nil ) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³chkBlCred      ºAutor  ³Everson      º Data ³ 16/07/2018    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Check liberação financeira.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 042565 .                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
	
	!!! Função chkBlCred chamada por static call nos fontes LIBPED2 e ADVEN090P !!!
	
*/
Static Function chkBlCred(cCliente,cLoja,cNumPed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	   := GetArea()		
	Local nLimCred := Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_LC")
	Local nSldAb   := fBscSld(cCliente,cLoja)
	Local nVlrItem := 0
	Local cTipo    := ""
	Local cEstado  := ""

	//
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6") + cNumPed))
		While !SC6->(Eof()) .And. SC6->C6_NUM == cNumPed
			If SC6->C6_QTDENT < SC6->C6_QTDVEN
				nVlrItem := ((SC6->C6_QTDVEN - SC6->C6_QTDENT) * SC6->C6_PRCVEN)

			EndIf

			//
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+cNumPed))
				cTipo     := SC5->C5_Tipo
				cEstado   := SC5->C5_EST

			EndIf

			//
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			If SF4->(Dbseek(xFilial("SF4") + SC6->C6_TES))

				If ((ALLTRIM(SF4->F4_DUPLIC) = 'S') .and. (ALLTRIM(cTipo) $ "N/C")) //.and. (ALLTRIM(cEstado)<> "EX")) //Everson - 12/11/2018. Chamado 045119. Pedido exportação deve ficar bloqueado por crédito.
					If (nVlrItem + nSldAb) > nLimCred
						DbSelectArea("SC9")
						SC9->(DbSetOrder(1))
						If SC9->(Dbseek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
							If Empty(SC9->C9_BLCRED)
								Conout("LIBPED1 Bloqueio financeiro por crédito cliente: " + cCliente + cLoja + " pedido: " + cNumPed + " Limite: " + cValToChar(nLimCred) + " Item: " + cValToChar(nVlrItem + nSldAb) )
								Reclock("SC9",.F.) 
									SC9->C9_BLCRED := "01" // Bloqueio por crédito.
								MsUnlock()
							EndIf      
						EndIf
					EndIf 
				Else
					DbSelectArea("SC9")
					SC9->(DbSetOrder(1))
					If SC9->(Dbseek(xFilial("SC9") + cNumPed + SC6->C6_ITEM))
						Reclock("SC9",.F.)
							SC9->C9_BLCRED := ""
						MsUnlock()
					EndIf
				EndIf  
			EndIf
			nLimCred -= nVlrItem  //Deduzo o valor do item já validado do limite utilizado.
			SC6->(dbSkip())
			
		Enddo

	EndIf      

	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³chkBlCred      ºAutor  ³Everson      º Data ³ 16/07/2018    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Check liberação financeira.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamado 042565 .                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBscSld(cCliente,cLoja)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	 := GetArea()
	Local nSld   := 0
	Local cQuery := ""
	
	//
	If Select("TSE1") > 0
		TSE1->(DbCloseArea())
		
	EndIf
	
	//
	cQuery := " SELECT SUM(E1_SALDO) E1_SALDO " 
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.E1_CLIENTE = '"+cCliente+"' AND SE1.E1_LOJA = '" + cLoja + "' " 
	cQuery += " AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "TSE1"

	DbSelectArea("TSE1")

	IF TSE1->(!Eof())
		nSld += TSE1->E1_SALDO
		
	EndIf
	
	//
	TSE1->(DbcloseArea())   
	
Return(nSld)

/*/{Protheus.doc} u_LIBPEDA0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LIBPEDA0( uPar1, uPar2, uPar3 )
Return( chkBlCred(uPar1, uPar2, uPar3) )
