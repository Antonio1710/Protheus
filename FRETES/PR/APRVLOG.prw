#Include "Protheus.CH"
#Include "MSGRAPHI.CH"
#Include "topconn.CH"

/*/{Protheus.doc} User Function AprvTran
	Tela aprovação para descontos clientes/transportadores.
	@type  Function
	@author Mauricio - MDS TEC
	@since 15/05/2013
	@version 01
	@history Adriana, 24/05/2019, TI-Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM.
	@history Everson, 28/07/2020, Chamado 059891. Tratamento para error log array out of bounds.
	@history Macieir, 16/02/2021, ticket 9574 - Error Log - APRVLOG.PRW) 28/07/2020 16:58:10 line : 608
/*/
User Function AprvTran(cAlias,nReg,nOpc)

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

	Private oOk      			:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo      			:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oDLG
	Private lMark    	:= .F.
	Private lChk     	:= .F.
	Private _aPedido	:= {}         
	Private _aSupervisor := {}
	Private oItemped                  
	Private aHeader		:= {}
	Private aHeadRec	:= {}
	Private aCols		:= {}
	Private aCloneCols	:= {}
	Private aColsRec	:= {}
	Private nUsado		:= 00

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

	DbSelectArea("SE1")
	DbSetOrder(1)
	Dbgotop()

	Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve as dimensoes dos objetos na direita da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aObjects := {}
	
	AADD(_aObjects,{100,100,.T.,.T.,.T.})
	AADD(_aObjects,{100,100,.T.,.T.,.T.})	

	_aSize3	  := aClone(_aPosObj1[02])	
	_aInfo	  := {_aSize3[02],_aSize3[01],_aSize3[04],_aSize3[03],03,03}
	_aPosObj3 := MsObjSize(_aInfo,_aObjects,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Interface ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlg From _aSize[07], 000 To _aSize[06],_aSize[05] Title OemtoAnsi( "Aprovação Desconto à transportadora" ) Pixel Of oMainWnd

	@ _aPosObj2[ 01 ][ 01 ] + 03, _aPosObj2[ 01 ][ 02 ]+250 Say OemToAnsi( "Pedidos/NFs" )			Font oFontBold Color CLR_GRAY Of oDlg Pixel

	MsAguarde( {|| AtuListBox( @_aPedido, @_aSupervisor ) }, OemToAnsi( "Aguarde" ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox Titulos renegociados pendentes de aprovacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj2[01][01]+10,_aPosObj2[01][02] ListBox oPedido Var cVar ;
		Fields Header ;
		OemToAnsi("Pedido"),;
		OemToAnsi("Numero NF"),;
		OemToAnsi("Serie NF"),;
		OemToAnsi("Cliente"),;
		OemToAnsi("Loja"),;
		OemToAnsi("Nome"),;
		OemToAnsi("Data Devolucao"),;
		OemToAnsi("Motivo"),;	
		OemToAnsi("Valor NF"),;
		OemToAnsi("Valor Desconto"),;
		OemToAnsi("Quant. Total"),;
		OemToAnsi("Quant. Quebra"),;     
		OemToAnsi("Observacao"),;   
		Size _aPosObj1[02][04]-20,_aPosObj2[02][04]-07 Of oDlg Pixel
					
	oPedido:bChange := { || fSelSupervisor( _aPedido[ oPedido:nAt ][ 02 ],_aPedido[ oPedido:nAt ][ 03 ] ,@_aSupervisor, "S" ) }

	oPedido:SetArray( _aPedido )

	oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}

	oPedido:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox SZX          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj1[02][01]+14,_aPosObj1[02][02]+02 ListBox oItemped Var cVar ;
		Fields Header ;
		OemToAnsi("Qtd Dev."),;
		OemToAnsi("Produto"),;
		OemToAnsi("Descricao"),;
		OemToAnsi("Quant"),;
		OemToAnsi("Unidade"),;
		OemToAnsi("NF"),;
		OemToAnsi("Serie"),;
		OemToAnsi("Qtd 2"),;
		OemToAnsi("Unid. 2"),;
		OemToAnsi("Qtd. 2"),;
		OemToAnsi("Valor"),;
		OemToAnsi("Quebra"),;
		OemToAnsi("Motivo"),;
		OemToAnsi("Observacao"),;
		OemToAnsi("Item NF"),;    
		Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 90 Of oDlg Pixel
		//Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 60 Of oDlg Pixel
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+170 BUTTON "Aprovar"  SIZE 040,020 PIXEL OF oDlg Action U_APROVT(oPedido:nAt)     //135
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+320 BUTTON "Rejeitar" SIZE 040,020 PIXEL OF oDlg Action U_REJT(oPedido:nAt)	  //135
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+450 BUTTON "Sair"     SIZE 064,014 PIXEL OF oDlg ACTION oDlg:End()                  //135

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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}

	oItemped:Refresh()

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| Processa( {|| MTHCProc() } ), oDlg:End() }, { || _nOpca := 00, oDlg:End() } )

Return (Nil)

Static Function AtuListBox( _aPedido, _aSupervisor)

	If Select("Processo") > 0
	dbSelectarea("Processo")
	dbclosearea("Processo")
	endif   

	_cQuery := "Select "
	_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
	_cQuery += "From "
	_cQuery += RetSqlName( "ZZE" ) + " ZZE "
	_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' "
	_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
	_cQuery += "And ZZE.ZZE_APVTPT = 'S' "
	_cQuery += "Order By ZZE.ZZE_PEDIDO "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
		
	_aPedido := {}

	While Processo->(!Eof())
			
		fSelSupervisor( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

		
		AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
						ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
						transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
						Alltrim(Processo->OBS)  } )
		Processo->(dbSkip())
		
	EndDo
	dbCloseArea("Processo")

	If Len(_aPedido) <= 00
		AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
					,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
	EndIf

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

Return(Nil)


Static Function fSelSupervisor( _cNF,_cSer, _aSupervisor, _cTipo )

	Local _cQuery		   := ""

	_cQuery := "Select "
	_cQuery += "ZX_QTDEV2U,ZX_QTDEV1U,ZX_CODPROD,ZX_DESCRIC,ZX_UNIDADE,ZX_NF,ZX_SERIE,ZX_QTSEGUM,ZX_SEGUM,ZX_TOTAL,ZX_QUEBRA,ZX_MOTIVO,CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX_OBSER)) OBS,ZX_ITEMNF "
	_cQuery += "From "
	_cQuery += RetSqlName( "SZX" ) + " SZX"
	_cQuery += " Where SZX.ZX_NF = '" + _cNF + "' AND SZX.ZX_SERIE = '"+ _cSer +"' "
	_cQuery += "And SZX.ZX_FILIAL = '" + xFilial( "SZX" ) + "' "
	_cQuery += "And SZX.D_E_L_E_T_ = ' ' "                            
	_cQuery += "Order By SZX.ZX_NF, SZX.ZX_ITEMNF "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Titulos", .F., .T. )
	_aSupervisor := {}
	While Titulos->(!Eof())
					
		AADD( _aSupervisor, {Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),ALLTRIM(Titulos->ZX_CODPROD),ALLTRIM(Titulos->ZX_DESCRIC),Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),;
		ALLTRIM(Titulos->ZX_UNIDADE),ALLTRIM(Titulos->ZX_NF),ALLTRIM(Titulos->ZX_SERIE),Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Alltrim(Titulos->ZX_SEGUM),;
		Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Transform(Titulos->ZX_TOTAL,"@E 999,999,999.99"),Transform(Titulos->ZX_QUEBRA,"@E 999,999,999.99"),;
		ALLTRIM(Titulos->ZX_MOTIVO),Alltrim(Titulos->OBS),ALLTRIM(Titulos->ZX_ITEMNF) } )   &&problema com campo MEMO ZX_OBSER
		Titulos->(dbSkip())
		
	EndDo

	dbCloseArea("Titulos")

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
		oItemped:Refresh()

	EndIf

Return ( Nil )

    
User function Aprovt(_nPos)

	Local _nPos
	Private _cProcess := _aPedido[_nPos][1]    

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

	If MsgYesNo("Aprova desconto ao transportador do pedido "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+".")
			Begin transaction
			DbSelectArea("ZZE")
			ZZE->(DbSetOrder(3))
			if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
			If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVTPT == "S" &&Valida o pedido por segurança
				RecLock("ZZE",.F.)
				ZZE->ZZE_AP_REP := "A"   &&Aprovado
				ZZE->ZZE_DTAPRV := Date()
				ZZE->ZZE_HRAPRV := Time()
				ZZE->ZZE_UAPROV := __cUserID
				ZZE->(MsUnlock())			  			  			  
			Endif	  
			Endif	  
					
			Atutp(@_aPedido,@_aSupervisor)
								
			if oPedido != Nil
						
						oPedido:SetArray( _aPedido )
						
						oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}
						
						oPedido:Refresh()
			EndIf
			if oItemped != Nil
						
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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
						oItemped:Refresh()
						
			EndIf
			End transaction								
	Endif
Return()

User function REJT(_nPos)

	Local _nPos
	Private _cProcess := _aPedido[_nPos][1]

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')
		
	If MsgYesNo("Confirma rejeição ao desconto para o transportador do pedido "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+".")
			Begin transaction
			DbSelectArea("ZZE")
			ZZE->(DbSetOrder(3))
			if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
			If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVTPT == "S" &&Valida o pedido por segurança
				RecLock("ZZE",.F.)
				ZZE->ZZE_AP_REP := "R"   &&Aprovado
				ZZE->ZZE_DTAPRV := Date()
				ZZE->ZZE_HRAPRV := Time()
				ZZE->ZZE_UAPROV := __cUserID
				ZZE->(MsUnlock())			  			  			  
			Endif	  
			Endif	  
					
			Atutp(@_aPedido,@_aSupervisor)
								
			if oPedido != Nil
						
						oPedido:SetArray( _aPedido )
						
						oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}
						
						oPedido:Refresh()
			EndIf
			if oItemped != Nil
						
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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
						oItemped:Refresh()
						
			EndIf
			End transaction								
	Endif
Return()

Static function AtuTp(_aPedido,_aSupervisor)
	If Select("Processo") > 0
	dbSelectarea("Processo")
	dbclosearea("Processo")
	endif   

	_cQuery := "Select "
	_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
	_cQuery += "From "
	_cQuery += RetSqlName( "ZZE" ) + " ZZE "
	_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' "
	_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
	_cQuery += "And ZZE.ZZE_APVTPT = 'S' "
	_cQuery += "Order By ZZE.ZZE_PEDIDO "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
		
	_aPedido := {}

	While Processo->(!Eof())
			
		fSelSupervisor( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

		
		AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
						ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
						transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;
						Alltrim(Processo->OBS)  } )
		Processo->(dbSkip())
		
	EndDo
	dbCloseArea("Processo")

	If Len(_aPedido) <= 00
		AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
					,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
		_aSupervisor := {}
		AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})               
					
	EndIf

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

Return()

/*/{Protheus.doc} User Function nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 16/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function AprvCli(cAlias,nReg,nOpc)

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

	Private oOk      			:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo      			:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oDLG
	Private lMark    	:= .F.
	Private lChk     	:= .F.
	Private _aPedido	:= {}         
	Private _aSupervisor := {}
	Private oItemped                  
	Private aHeader		:= {}
	Private aHeadRec	:= {}
	Private aCols		:= {}
	Private aCloneCols	:= {}
	Private aColsRec	:= {}
	Private nUsado		:= 00

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

	DbSelectArea("SE1")
	DbSetOrder(1)
	Dbgotop()

	Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve as dimensoes dos objetos na direita da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aObjects := {}

	AADD(_aObjects,{100,100,.T.,.T.,.T.})
	AADD(_aObjects,{100,100,.T.,.T.,.T.})	

	_aSize3	  := aClone(_aPosObj1[02])	
	_aInfo	  := {_aSize3[02],_aSize3[01],_aSize3[04],_aSize3[03],03,03}
	_aPosObj3 := MsObjSize(_aInfo,_aObjects,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Interface ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlg From _aSize[07], 000 To _aSize[06],_aSize[05] Title OemtoAnsi( "Aprovação Desconto à Clientes" ) Pixel Of oMainWnd

	@ _aPosObj2[ 01 ][ 01 ] + 03, _aPosObj2[ 01 ][ 02 ]+250 Say OemToAnsi( "Pedidos/NFs" )			Font oFontBold Color CLR_GRAY Of oDlg Pixel

	MsAguarde( {|| AListBox( @_aPedido, @_aSupervisor ) }, OemToAnsi( "Aguarde" ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox Titulos renegociados pendentes de aprovacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj2[01][01]+10,_aPosObj2[01][02] ListBox oPedido Var cVar ;
		Fields Header ;
		OemToAnsi("Pedido"),;
		OemToAnsi("Numero NF"),;
		OemToAnsi("Serie NF"),;
		OemToAnsi("Cliente"),;
		OemToAnsi("Loja"),;
		OemToAnsi("Nome"),;
		OemToAnsi("Data Devolucao"),;
		OemToAnsi("Motivo"),;	
		OemToAnsi("Valor NF"),;
		OemToAnsi("Valor Desconto"),;
		OemToAnsi("Quant. Total"),;
		OemToAnsi("Quant. Quebra"),;     
		OemToAnsi("Observacao"),;   
		Size _aPosObj1[02][04]-20,_aPosObj2[02][04]-07 Of oDlg Pixel
					
	oPedido:bChange := { || fSupervisor( _aPedido[ oPedido:nAt ][ 02 ],_aPedido[ oPedido:nAt ][ 03 ] ,@_aSupervisor, "S" ) }

	oPedido:SetArray( _aPedido )

	if len(_aPedido) >= oPedido:nAt //alterado por Adriana para apenas remontar a linha quando len(_aPedido) >= oPedido:nAt - chamado 036826
		
		//Everson - 28/07/2020. Chamado 059891.
		If Len(_aPedido[oPedido:nAt]) >= 13

			If oPedido:nAt <= Len(_aPedido) // @history Macieir, 16/02/2021, ticket 9574 - Error Log - APRVLOG.PRW) 28/07/2020 16:58:10 line : 608

				oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
									_aPedido[oPedido:nAt][13]}}
			
				oPedido:Refresh()
			
			EndIf
			
		EndIf
		//

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox SZX          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj1[02][01]+14,_aPosObj1[02][02]+02 ListBox oItemped Var cVar ;
		Fields Header ;
		OemToAnsi("Qtd Dev."),;
		OemToAnsi("Produto"),;
		OemToAnsi("Descricao"),;
		OemToAnsi("Quant"),;
		OemToAnsi("Unidade"),;
		OemToAnsi("NF"),;
		OemToAnsi("Serie"),;
		OemToAnsi("Qtd 2"),;
		OemToAnsi("Unid. 2"),;
		OemToAnsi("Qtd. 2"),;
		OemToAnsi("Valor"),;
		OemToAnsi("Quebra"),;
		OemToAnsi("Motivo"),;
		OemToAnsi("Observacao"),;
		OemToAnsi("Item NF"),;    
		Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 90 Of oDlg Pixel

	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+240 BUTTON "Aprovar"   SIZE 040,020 PIXEL OF oDlg Action U_APROVC(oPedido:nAt)  //105
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+310 BUTTON "Rejeitar"  SIZE 040,020 PIXEL OF oDlg Action U_REJC(oPedido:nAt)	  //105
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+380 BUTTON "Pesquisar" SIZE 040,020 PIXEL OF oDlg Action (PesqCli(),oPedido:Refresh(),oItemped:Refresh()) //105
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+450 BUTTON "Sair"      SIZE 040,020 PIXEL OF oDlg ACTION oDlg:End()             //105

	oItemped:SetArray( _aSupervisor )

	//Everson - 28/07/2020. Chamado 059891.
	If Len(_aSupervisor[oItemped:nAt]) >= 15
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
								_aSupervisor[oItemped:nAt][12],;
								_aSupervisor[oItemped:nAt][13],;
								_aSupervisor[oItemped:nAt][14],;													
								_aSupervisor[oItemped:nAt][15]}}

		oItemped:Refresh()

	EndIf
	//

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| Processa( {|| MTHCProc() } ), oDlg:End() }, { || _nOpca := 00, oDlg:End() } )

Return (Nil)

STATIC FUNCTION PesqCli()

	Local _aArea		   := GetArea()
	Local _cPesqNota	   := Space(09)
	Local _nOpca		   := 00  
	Local nLinha           := 0   
	Local nLinhaMsGetDados := 0
	
	Local oDlg1

	Define MsDialog oDlg1 Title OemToAnsi( "Pesquisa" ) From 05, 00 To 12, 45
	
		@ 040.0, 005 Say OemToAnsi("Nota Fiscal:") Size 080, 10 Pixel Of oDlg1
		
		@ 039.2, 035 MsGet _cPesqNota	Size 055, 10 Pixel Of oDlg1 Picture "999999999"
	
	Activate MsDialog oDlg1 On Init EnchoiceBar( oDlg1, {||_nOpca := 01, oDlg1:End() }, {||_nOpca := 00, oDlg1:End()} ) Centered
	
	For nLinha := 1 to Len(_aPedido)
	
        //produto
     	IF UPPER(ALLTRIM(_aPedido[nLinha][2])) == UPPER(ALLTRIM(_cPesqNota))
     	   nLinhaMsGetDados :=  nLinha
     	   
        Else
        
          LOOP
       
        ENDIF
  
    Next nLinha 
    
    IF ALLTRIM(_cPesqNota) <> '' .AND. nLinhaMsGetDados > 0
	   
		oPedido:nat := nLinhaMsGetDados
	    oPedido:Refresh()
	    oPedido:SetFocus()
	    
	    fSupervisor( _aPedido[ oPedido:nAt ][ 02 ],_aPedido[ oPedido:nAt ][ 03 ] ,@_aSupervisor, "S" )
	    
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
								_aSupervisor[oItemped:nAt][12],;
								_aSupervisor[oItemped:nAt][13],;
								_aSupervisor[oItemped:nAt][14],;													
								_aSupervisor[oItemped:nAt][15]}}
		
		oItemped:Refresh()
	
	ELSE
	
		MsgAlert("OLÁ " + Alltrim(cUserName) + " Pesquisa não encontra, favor verifique!!!")
		
    ENDIF
	RestArea( _aArea )

RETURN(NIL)

Static Function AListBox( _aPedido, _aSupervisor)

	If Select("Processo") > 0
	dbSelectarea("Processo")
	dbclosearea("Processo")
	endif   

	_cQuery := "Select "
	_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS"
	_cQuery += "From "
	_cQuery += RetSqlName( "ZZE" ) + " ZZE "
	_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_RPC = ' ' "
	_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
	_cQuery += "And ZZE.ZZE_APVNCC = 'S' "
	_cQuery += "Order By ZZE.ZZE_PEDIDO "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
		
	_aPedido := {}

	While Processo->(!Eof())
			
		fSupervisor( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

		
		AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
						ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
						transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
						Alltrim(Processo->OBS) } )
		Processo->(dbSkip())
		
	EndDo
	dbCloseArea("Processo")

	If Len(_aPedido) <= 00
		AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
					,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
	EndIf

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

Return(Nil)


Static Function fSupervisor( _cNF,_cSer, _aSupervisor, _cTipo )

	Local _cQuery		   := ""

	_cQuery := "Select "
	_cQuery += "ZX_QTDEV2U,ZX_QTDEV1U,ZX_CODPROD,ZX_DESCRIC,ZX_UNIDADE,ZX_NF,ZX_SERIE,ZX_QTSEGUM,ZX_SEGUM,ZX_TOTAL,ZX_QUEBRA,ZX_MOTIVO,ZX_ITEMNF, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX_OBSER)) OBS "
	_cQuery += "From "
	_cQuery += RetSqlName( "SZX" ) + " SZX"
	_cQuery += " Where SZX.ZX_NF = '" + _cNF + "' AND SZX.ZX_SERIE = '"+ _cSer +"' "
	_cQuery += "And SZX.ZX_FILIAL = '" + xFilial( "SZX" ) + "' "
	_cQuery += "And SZX.D_E_L_E_T_ = ' ' "                            
	_cQuery += "Order By SZX.ZX_NF, SZX.ZX_ITEMNF "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Titulos", .F., .T. )
	_aSupervisor := {}
	While Titulos->(!Eof())
					
		AADD( _aSupervisor, {Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),ALLTRIM(Titulos->ZX_CODPROD),ALLTRIM(Titulos->ZX_DESCRIC),Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),;
		ALLTRIM(Titulos->ZX_UNIDADE),ALLTRIM(Titulos->ZX_NF),ALLTRIM(Titulos->ZX_SERIE),Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Alltrim(Titulos->ZX_SEGUM),;
		Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Transform(Titulos->ZX_TOTAL,"@E 999,999,999.99"),Transform(Titulos->ZX_QUEBRA,"@E 999,999,999.99"),;
		ALLTRIM(Titulos->ZX_MOTIVO),ALLTRIM(Titulos->OBS),ALLTRIM(Titulos->ZX_ITEMNF) } )   &&problema com campo MEMO ZX_OBSER
		Titulos->(dbSkip())
		
	EndDo

	dbCloseArea("Titulos")

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
		oItemped:Refresh()

	EndIf

Return ( Nil )
    
User function Aprovc(_nPos)

	Local _nPos
	Private _cProcess  := _aPedido[_nPos][1] 

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')
		
	If MsgYesNo("Aprova desconto ao Cliente do "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+".")
			Begin transaction
			DbSelectArea("ZZE")
			ZZE->(DbSetOrder(4))	
			if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
			If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVNCC == "S" &&Valida o pedido por segurança
				RecLock("ZZE",.F.)
				ZZE->ZZE_AP_RPC := "A"   &&Aprovado
				ZZE->ZZE_DTAPRC := Date()
				ZZE->ZZE_HRAPRC := Time()
				ZZE->ZZE_UAPRVC := __cUserID
				ZZE->(MsUnlock())			  			  			  
			Endif	  
			Endif
			
			_cEst := Posicione("SA1",1,xfilial("SA1")+_aPedido[_nPos][4]+_aPedido[_nPos][5],"A1_EST")
			if _cEst == "SP" .Or. _cEst == "RJ"
			_cCC := "6110"
			else
			_cCC := "6210"
			Endif   
			
			&&gerando NCC ao Cliente.....		
			&&Gravo SE1 
			// ******** INICIO ALTERACAO WILLIAM COSTA CHAMADO 024468 *******************//
			// verifica se ja existe o titulo se sim somente altera se nao ai grava o registro
			DBSELECTAREA("SE1")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(xFilial("SE1")+"MAN"+_aPedido[_nPos][2]+"A  "+"NCC",.T.)
				If MsgYesNo("Já existe um titulo com o valor: " + STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".") + chr(10) + chr(13) + ;
							"Deseja alterá-lo?")
							
							
					RecLock("SE1",.F.)
						SE1->E1_FILIAL  := xFilial("SE1")
						SE1->E1_PREFIXO := "MAN"
						SE1->E1_NUM     := _aPedido[_nPos][2]                                       
						SE1->E1_PARCELA := "A"
						SE1->E1_TIPO    := "NCC"
						SE1->E1_NATUREZ := "24001"
						SE1->E1_CLIENTE := _aPedido[_nPos][4]
						SE1->E1_LOJA    := _aPedido[_nPos][5]
						SE1->E1_NOMCLI  := _aPedido[_nPos][6]
						SE1->E1_VENCTO  := dDatabase
						SE1->E1_VENCREA := DataValida(dDatabase)
						SE1->E1_VALOR   := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //Val(STRTRAN(_aPedido[_nPos][10],".",""))
						SE1->E1_EMIS1   := dDatabase
						SE1->E1_EMISSAO := dDatabase
						SE1->E1_SITUACA := "0"
						SE1->E1_SALDO   := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //VAL(_aPedido[_nPos][10])
						SE1->E1_VENCORI := dDatabase
						SE1->E1_OCORREN := "01"
						SE1->E1_VLCRUZ  := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //VAL(STRTRAN(_aPedido[_nPos][10],".",""))
						SE1->E1_STATUS  := "A"
						SE1->E1_ORIGEM  := "FINA040"
						SE1->E1_FLUXO   := "S"
						SE1->E1_CCD     := _cCC
						SE1->E1_TIPODES := "1"
						SE1->E1_FILORIG := xFilial("SE1")
						SE1->E1_MULTNAT := "2"
						SE1->E1_MSFIL   := xFilial("SE1")
						SE1->E1_MSEMP   := cEmpAnt	
						SE1->E1_PROJPMS := "2"
						SE1->E1_DESDOBR := "2"
						SE1->E1_MODSPB  := "1"
						SE1->E1_DEBITO  := "311220005"
						SE1->E1_ITEMD   := "121"
						SE1->E1_CREDIT  := "191110011"
						SE1->E1_ITEMC   := "121"
						SE1->E1_PEDIDO  := ""
						SE1->E1_SCORGP  := "2"
						SE1->E1_APLVLMN := "1"
						SE1->E1_MOEDA   := 1
						SE1->E1_RELATO  := "2"
						&&SE1->E1_USERLGI
						&&SE1->E1_USERLGA		
					SE1->(MsUnlock())
				
				ENDIF
			
			ELSE
			
				
				RecLock("SE1",.T.)
					SE1->E1_FILIAL  := xFilial("SE1")
					SE1->E1_PREFIXO := "MAN"
					SE1->E1_NUM     := _aPedido[_nPos][2]                                       
					SE1->E1_PARCELA := "A"
					SE1->E1_TIPO    := "NCC"
					SE1->E1_NATUREZ := "24001"
					SE1->E1_CLIENTE := _aPedido[_nPos][4]
					SE1->E1_LOJA    := _aPedido[_nPos][5]
					SE1->E1_NOMCLI  := _aPedido[_nPos][6]
					SE1->E1_VENCTO  := dDatabase
					SE1->E1_VENCREA := DataValida(dDatabase)
					SE1->E1_VALOR   := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //Val(STRTRAN(_aPedido[_nPos][10],".",""))
					SE1->E1_EMIS1   := dDatabase
					SE1->E1_EMISSAO := dDatabase
					SE1->E1_SITUACA := "0"
					SE1->E1_SALDO   := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //VAL(_aPedido[_nPos][10])
					SE1->E1_VENCORI := dDatabase
					SE1->E1_OCORREN := "01"
					SE1->E1_VLCRUZ  := Val(STRTRAN(STRTRAN(_aPedido[_nPos][10],".",""),",",".")) //VAL(STRTRAN(_aPedido[_nPos][10],".",""))
					SE1->E1_STATUS  := "A"
					SE1->E1_ORIGEM  := "FINA040"
					SE1->E1_FLUXO   := "S"
					SE1->E1_CCD     := _cCC
					SE1->E1_TIPODES := "1"
					SE1->E1_FILORIG := xFilial("SE1")
					SE1->E1_MULTNAT := "2"
					SE1->E1_MSFIL   := xFilial("SE1")
					SE1->E1_MSEMP   := cEmpAnt	
					SE1->E1_PROJPMS := "2"
					SE1->E1_DESDOBR := "2"
					SE1->E1_MODSPB  := "1"
					SE1->E1_DEBITO  := "311220005"
					SE1->E1_ITEMD   := "121"
					SE1->E1_CREDIT  := "191110011"
					SE1->E1_ITEMC   := "121"
					SE1->E1_PEDIDO  := ""
					SE1->E1_SCORGP  := "2"
					SE1->E1_APLVLMN := "1"
					SE1->E1_MOEDA   := 1
					SE1->E1_RELATO  := "2"
					&&SE1->E1_USERLGI
					&&SE1->E1_USERLGA		
				SE1->(MsUnlock())
				
			ENDIF
			// ******** FINAL ALTERACAO WILLIAM COSTA CHAMADO 024468 *******************//	
			Atucl(@_aPedido,@_aSupervisor)
								
			if oPedido != Nil .and. len(_aPedido) >= oPedido:nAt //alterado por Adriana para apenas remontar a linha quando len(_aPedido) >= oPedido:nAt - chamado 036826
						
						oPedido:SetArray( _aPedido )
						
						oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}
						
						oPedido:Refresh()
			EndIf
			if oItemped != Nil .and. len(_aSupervisor) >= oItemped:nAt//alterado por Adriana para apenas remontar a linha quando len(_aPedido) >= oPedido:nAt - chamado 036826
						
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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
						oItemped:Refresh()
						
			EndIf
			End transaction								
	Endif
Return()

User function REJC(_nPos)

	Local _nPos
	Private _cProcess := _aPedido[_nPos][1]

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')
		
	If MsgYesNo("Confirma rejeição ao desconto para o Cliente do "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+".")
			Begin transaction
			DbSelectArea("ZZE")
			ZZE->(DbSetOrder(4))
			if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
			If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVNCC == "S"  &&Valida o pedido por segurança
				RecLock("ZZE",.F.)
				ZZE->ZZE_AP_RPC := "R"   &&Aprovado
				ZZE->ZZE_DTAPRC := Date()
				ZZE->ZZE_HRAPRC := Time()
				ZZE->ZZE_UAPRVC := __cUserID
				ZZE->(MsUnlock())			  			  			  
			Endif	  
			Endif	  
					
			Atucl(@_aPedido,@_aSupervisor)
								
			if oPedido != Nil .and. len(_aPedido) >= oPedido:nAt //alterado por Adriana para apenas remontar a linha quando len(_aPedido) >= oPedido:nAt - chamado 036826
						
						oPedido:SetArray( _aPedido )
						
						oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}
						
						oPedido:Refresh()
			EndIf
			if oItemped != Nil
						
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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}
						oItemped:Refresh()
						
			EndIf
			End transaction								
	Endif
Return()

Static function AtuCl(_aPedido,_aSupervisor)
	If Select("Processo") > 0
	dbSelectarea("Processo")
	dbclosearea("Processo")
	endif   

	_cQuery := "Select "
	_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS"
	_cQuery += "From "
	_cQuery += RetSqlName( "ZZE" ) + " ZZE "
	_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_RPC = ' ' "
	_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
	_cQuery += "And ZZE.ZZE_APVNCC = 'S' "
	_cQuery += "Order By ZZE.ZZE_PEDIDO "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
		
	_aPedido := {}

	While Processo->(!Eof())
			
		fSupervisor( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

		
		AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
						ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
						transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;
						Alltrim(Processo->OBS)  } )
		Processo->(dbSkip())
		
	EndDo
	dbCloseArea("Processo")

	If Len(_aPedido) <= 00
		AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
					,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
					
		_aSupervisor := {}
		AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})                
	EndIf

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf
                       
Return()

static function MTHCProc()
	oDlg:End()
return(.T.) 

User Function JustVend(cAlias,nReg,nOpc)

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

	Private oOk      			:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo      			:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oDLG
	Private lMark    	:= .F.
	Private lChk     	:= .F.
	Private _aPedido	:= {}         
	Private _aSupervisor := {}
	Private oItemped                  
	Private aHeader		:= {}
	Private aHeadRec	:= {}
	Private aCols		:= {}
	Private aCloneCols	:= {}
	Private aColsRec	:= {}
	Private nUsado		:= 00
	Private oSay4
	Private oGet2
	Private cGet2       := Space(230)

	U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

	Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Resolve as dimensoes dos objetos na direita da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aObjects := {}
	
	AADD(_aObjects,{100,100,.T.,.T.,.T.})
	AADD(_aObjects,{100,100,.T.,.T.,.T.})	

	_aSize3	  := aClone(_aPosObj1[02])	
	_aInfo	  := {_aSize3[02],_aSize3[01],_aSize3[04],_aSize3[03],03,03}
	_aPosObj3 := MsObjSize(_aInfo,_aObjects,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Interface ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlg From _aSize[07], 000 To _aSize[06],_aSize[05] Title OemtoAnsi( "Justificativa para desconto ao vendedor" ) Pixel Of oMainWnd

	@ _aPosObj2[ 01 ][ 01 ] + 03, _aPosObj2[ 01 ][ 02 ]+250 Say OemToAnsi( "Pedidos/NFs" )			Font oFontBold Color CLR_GRAY Of oDlg Pixel

	MsAguarde( {|| AtuListVen( @_aPedido, @_aSupervisor ) }, OemToAnsi( "Aguarde" ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox Titulos renegociados pendentes de aprovacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj2[01][01]+10,_aPosObj2[01][02] ListBox oPedido Var cVar ;
		Fields Header ;
		OemToAnsi("Pedido"),;
		OemToAnsi("Numero NF"),;
		OemToAnsi("Serie NF"),;
		OemToAnsi("Cliente"),;
		OemToAnsi("Loja"),;
		OemToAnsi("Nome"),;
		OemToAnsi("Data Devolucao"),;
		OemToAnsi("Motivo"),;	
		OemToAnsi("Valor NF"),;
		OemToAnsi("Valor Desconto"),;
		OemToAnsi("Quant. Total"),;
		OemToAnsi("Quant. Quebra"),;     
		OemToAnsi("Observacao"),;   
		Size _aPosObj1[02][04]-20,_aPosObj2[02][04]-07 Of oDlg Pixel
					
	oPedido:bChange := { || fSelVend( _aPedido[ oPedido:nAt ][ 02 ],_aPedido[ oPedido:nAt ][ 03 ] ,@_aSupervisor, "S" ) }

	oPedido:SetArray( _aPedido )

	oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
							_aPedido[oPedido:nAt][13]}}

	oPedido:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ListBox SZX          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ _aPosObj1[02][01]+14,_aPosObj1[02][02]+02 ListBox oItemped Var cVar ;
		Fields Header ;
		OemToAnsi("Qtd Dev."),;
		OemToAnsi("Produto"),;
		OemToAnsi("Descricao"),;
		OemToAnsi("Quant"),;
		OemToAnsi("Unidade"),;
		OemToAnsi("NF"),;
		OemToAnsi("Serie"),;
		OemToAnsi("Qtd 2"),;
		OemToAnsi("Unid. 2"),;
		OemToAnsi("Qtd. 2"),;
		OemToAnsi("Valor"),;
		OemToAnsi("Quebra"),;
		OemToAnsi("Motivo"),;
		OemToAnsi("Observacao"),;
		OemToAnsi("Item NF"),;    
		Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 90 Of oDlg Pixel
		
	//@ 190, 026 SAY oSay4 PROMPT "Justificativa:" SIZE 109, 011 OF oDlg COLORS 0, 16777215 PIXEL   //210
	//@ 190, 144 MSGET oGet2 VAR cGet2 SIZE 250, 010 OF oDlg VALID .T. COLORS 0, 16777215 PIXEL     //210

	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+050 SAY oSay4 PROMPT "Justificativa:" SIZE 109, 011 OF oDlg COLORS 0, 16777215 PIXEL  
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+090 MSGET oGet2 VAR cGet2 SIZE 250, 010 OF oDlg VALID .T. COLORS 0, 16777215 PIXEL  

	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+360 BUTTON "Concorda"  SIZE 040,020 PIXEL OF oDlg Action U_CONCORD(oPedido:nAt)     
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+430 BUTTON "Discorda" SIZE 040,020 PIXEL OF oDlg Action U_DISCORD(oPedido:nAt)	  
	@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+490 BUTTON "Sair"     SIZE 064,014 PIXEL OF oDlg ACTION oDlg:End() 
					
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
							_aSupervisor[oItemped:nAt][12],;
							_aSupervisor[oItemped:nAt][13],;
							_aSupervisor[oItemped:nAt][14],;													
							_aSupervisor[oItemped:nAt][15]}}

	oItemped:Refresh()

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| Processa( {|| MTHCProc() } ), oDlg:End() }, { || _nOpca := 00, oDlg:End() } )

Return (Nil)

Static Function AtuListVen( _aPedido, _aSupervisor)

If Select("Processo") > 0
   dbSelectarea("Processo")
   dbclosearea("Processo")      
endif

_dDia := Date()   

_cQuery := "Select "
_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_DTDISP,ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
_cQuery += "From "
_cQuery += RetSqlName( "ZZE" ) + " ZZE "                                                    &&Mauricio - retirado por enquanto filtro supervisor para facilitar os testes
_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' AND ZZE.ZZE_USSUPE = '"+__cUserID+"' "
_cQuery += "And ZZE_UJUSTS = '      ' "
_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
_cQuery += "And ZZE.ZZE_APVVDD = 'S' "
_cQuery += "Order By ZZE.ZZE_PEDIDO "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
      
_aPedido := {}

While Processo->(!Eof())

    &&Valido aqui se tem até 3 dias para ser apresentado
    If (_dDia - STOD(Processo->ZZE_DTDISP)) > 3   &&periodo maior que 3 dias
       //Mauricio inclui aqui a aprovação automatica do desconto pois passou de 3 dias.
       DbSelectArea("ZZE")
	   ZZE->(DbSetOrder(5))
	   if dbseek(xFilial("ZZE")+Processo->ZZE_NUMNF+Processo->ZZE_SERIE+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == Processo->ZZE_PEDIDO .AND. ZZE->ZZE_AP_REP == " " .AND. ZZE->ZZE_APVVDD == "S"&&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_AP_REP := "A"   &&Aprovado
			  ZZE->ZZE_DTAPRV := Date()
			  ZZE->ZZE_HRAPRV := Time()
			  ZZE->ZZE_UAPROV := "777777"    &&numero de usuario inexistente. Ficara como aprovação por expiração de prazo(3 dias)
			  ZZE->ZZE_DTJSTS := Date()
			  ZZE->ZZE_HRJSTS := Time()
			  ZZE->ZZE_UJUSTS := "777777"
		      ZZE->ZZE_JUSTSP := "Aprovado pois prazo 3 dias foi ultrapassado para justificativa"
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
	   Endif	  
       Processo->(dbSkip())
       loop
    Endif   
	    
	fSelVend( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

	   
	AADD( _aPedido, {Processo->ZZE_PEDIDO,Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
	                 ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
	                 transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
	                 Alltrim(Processo->OBS)  } )
	Processo->(dbSkip())
	  
 EndDo
dbCloseArea("Processo")

If Len(_aPedido) <= 00
	AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
	               ,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
EndIf

If Len(_aSupervisor) <= 00
         AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
EndIf

Return(Nil)

Static Function fSelVend( _cNF,_cSer, _aSupervisor, _cTipo )

Local _cQuery		   := ""

_cQuery := "Select "
_cQuery += "ZX_QTDEV2U,ZX_QTDEV1U,ZX_CODPROD,ZX_DESCRIC,ZX_UNIDADE,ZX_NF,ZX_SERIE,ZX_QTSEGUM,ZX_SEGUM,ZX_TOTAL,ZX_QUEBRA,ZX_MOTIVO,CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX_OBSER)) OBS,ZX_ITEMNF "
_cQuery += "From "
_cQuery += RetSqlName( "SZX" ) + " SZX"
_cQuery += " Where SZX.ZX_NF = '" + _cNF + "' AND SZX.ZX_SERIE = '"+ _cSer +"' "
_cQuery += "And SZX.ZX_FILIAL = '" + xFilial( "SZX" ) + "' "
_cQuery += "And SZX.D_E_L_E_T_ = ' ' "                            
_cQuery += "Order By SZX.ZX_NF, SZX.ZX_ITEMNF "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Titulos", .F., .T. )
_aSupervisor := {}
While Titulos->(!Eof())
                   
    AADD( _aSupervisor, {Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),ALLTRIM(Titulos->ZX_CODPROD),ALLTRIM(Titulos->ZX_DESCRIC),Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),;
    ALLTRIM(Titulos->ZX_UNIDADE),ALLTRIM(Titulos->ZX_NF),ALLTRIM(Titulos->ZX_SERIE),Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Alltrim(Titulos->ZX_SEGUM),;
    Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Transform(Titulos->ZX_TOTAL,"@E 999,999,999.99"),Transform(Titulos->ZX_QUEBRA,"@E 999,999,999.99"),;
    ALLTRIM(Titulos->ZX_MOTIVO),Alltrim(Titulos->OBS),ALLTRIM(Titulos->ZX_ITEMNF) } )   &&problema com campo MEMO ZX_OBSER
	Titulos->(dbSkip())
	
EndDo

dbCloseArea("Titulos")

If Len(_aSupervisor) <= 00
         AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
EndIf

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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
	oItemped:Refresh()

EndIf

Return ( Nil ) 

User function Concord(_nPos)

Local _nPos
Private _cProcess := _aPedido[_nPos][1]    

U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

If MsgYesNo("Concordo com o desconto relativo ao pedido "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+".")
        Begin transaction
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(5))
		if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVVDD == "S" &&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_AP_REP := "A"   &&Aprovado
			  ZZE->ZZE_DTAPRV := Date()
			  ZZE->ZZE_HRAPRV := Time()
			  ZZE->ZZE_UAPROV := "888888"    &&numero de usuario inexistente. Ficara como aprovação por concordancia do vendedor.
			  ZZE->ZZE_DTJSTS := Date()
			  ZZE->ZZE_HRJSTS := Time()
			  ZZE->ZZE_UJUSTS := __cUserID
		      ZZE->ZZE_JUSTSP := Alltrim(cGet2)
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
		Endif	  
			  	  
		Atuvd(@_aPedido,@_aSupervisor)
							
		if oPedido != Nil
					
					oPedido:SetArray( _aPedido )
					
					oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
						   _aPedido[oPedido:nAt][13]}}
					
					oPedido:Refresh()
		EndIf
		if oItemped != Nil
					
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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
					oItemped:Refresh()
					
		EndIf
		End transaction								
Endif
cGet2 := Space(230)
oSay4:Refresh()

Return()

User function discord(_nPos)

Local _nPos
Private _cProcess := _aPedido[_nPos][1]

U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')
     
If MsgYesNo("Discordo do desconto(Justificativa deve estar preenchida!) no valor de R$ "+_aPedido[_nPos][10]+".")
        _lJust := .T.
        if Empty(cGet2) .Or. Len(cGet2) < 15
           MsgAlert("Justificativa não preenchida ou muito curta!")
           _lJust := .F.
        Endif
        If _lJust   
        Begin transaction
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(5))
		if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVVDD == "S" &&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_DTJSTS := Date()
			  ZZE->ZZE_HRJSTS := Time()
			  ZZE->ZZE_UJUSTS := __cUserID
		      ZZE->ZZE_JUSTSP := Alltrim(cGet2)
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
		Endif
		
		&&envia email ao sr. jAMES
		mandaemail(__cUserID,_aPedido[_nPos][1],_aPedido[_nPos][2],_aPedido[_nPos][1],Alltrim(cGet2))	  
			  	  
		Atuvd(@_aPedido,@_aSupervisor)
							
		if oPedido != Nil
					
					oPedido:SetArray( _aPedido )
					
					oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
						   _aPedido[oPedido:nAt][13]}}
					
					oPedido:Refresh()
		EndIf
		if oItemped != Nil
					
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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
					oItemped:Refresh()
					
		EndIf
		End transaction
		Endif								
Endif
cGet2 := Space(230)
oSay4:Refresh()
Return()

Static function AtuVd(_aPedido,_aSupervisor)
If Select("Processo") > 0
   dbSelectarea("Processo")
   dbclosearea("Processo")      
endif

_dDia := Date()   

_cQuery := "Select "
_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_DTDISP,ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
_cQuery += "From "
_cQuery += RetSqlName( "ZZE" ) + " ZZE "                                                    &&Mauricio - retirado por enquanto filtro supervisor para facilitar os testes
_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' AND ZZE.ZZE_USSUPE = '"+__cUserID+"' "
_cQuery += "And ZZE_UJUSTS = '      ' "
_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
_cQuery += "And ZZE.ZZE_APVVDD = 'S' "
_cQuery += "Order By ZZE.ZZE_PEDIDO "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
      
_aPedido := {}

While Processo->(!Eof())

    &&Valido aqui se tem até 3 dias para ser apresentado
    If (_dDia - STOD(Processo->ZZE_DTDISP)) > 3   &&periodo maior que 3 dias         
       Processo->(dbSkip())
       loop
    Endif   
	    
	fSelVend( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

	   
	AADD( _aPedido, {Processo->ZZE_PEDIDO,Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
	                 ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
	                 transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
	                 Alltrim(Processo->OBS)  } )
	Processo->(dbSkip())
	  
EndDo
dbCloseArea("Processo")

If Len(_aPedido) <= 00
	AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
	               ,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,})
    _aSupervisor := {}
    AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})	               
EndIf

If Len(_aSupervisor) <= 00
         AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
EndIf

Return()

Static Function MandaEmail(_cU,_cP,_cN,_cS,_cJ)

Local cMotivo 	:= Space(115)
Local nOpt 		:= 0
Local lRet		:= .f.
Local _lMail	:= .f.
Local _nTotSC6	:= 0
Local _cMens	:= " "
Local _cMens1	:= " "
Local _cMens2	:= " "
Local _cMens3	:= " "
Local _cDev
Local _cC
Local _cL
Local _cN
Local _cM
Local _cO   

			_cMens1 := '<html>'
			_cMens1 += '<head>'
			_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
			_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
			_cMens1 += '<title>Devolucao NF</title>'
			_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
			_cMens1 += '</head>'
			_cMens1 += '<body bgcolor="#C0C0C0">'
			_cMens1 += '<center>'
			_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
			_cMens1 += '<tr height="80">'
			_cMens1 += '<td width="100%" height="80" background="">&nbsp;</td>'
			_cMens1 += '</tr>'
			_cMens1 += '</center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%" bgcolor="#386079">'
			_cMens1 += '<div align="left">'
			_cMens1 += '<table border="1" width="100%">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
			_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+_cP+'</font></b>'
			_cMens1 += '</td></tr>'
			_cMens1 += '</table>'
			_cMens1 += '</div>'
			_cMens1 += '</td>'
			_cMens1 += '</tr>' 
			_cMens1 += '<center>'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="100%">'
			_cMens1 += '<table border="1" width="982">'
			_cMens1 += '<tr>'
			_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">NF:</font></td>'
			_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+_cN+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="25" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Serie:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
			_cMens1 += '<p align="center"><font face="Arial" size="1">'+_Cs+'</font></td>'
			_cMens1 += '</center>'
			_cMens1 += '<td width="36" bgcolor="#FAA21B">'
			_cMens1 += '<p align="right"><font face="Arial" size="1">Justificativa:</font></td>'
			_cMens1 += '<center>'
			_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+_cJ+'</font></td>'
			_cMens1 += '</tr>'
			_cMens3	+= '</center>'
			_cMens3	+= '</body>'
			_cMens3	+= '</html>'
		          
		    /*
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
			_eMailVend := SA3->A3_EMAIL
			
			DbSelectArea("SZR")
			DbSetOrder(1)
			DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
			_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))
			cEmail :=_eMailVend+';'+_eMailSup+";james@adoro.com.br;cal@adoro.com.br;expedicao@adoro.com.br"
			*/			
			cEmail := "james@adoro.com.br"   //"mau_silva@hotmail.com"  &&por enquanto forço pra mim o email, quando for entrar em produção comentar esta linha...
			_cMens := _cMens1+_cMens3
			_cData := transform(MsDate(),"@!")
			_cHora := transform(Time(),"@!")  
	        
	        U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"Desconto rejeitado pelo supervisor p/ pedido "+_cP+".","")	  	//Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM	  				  		
         
Return()
       
//Tela para aprovacao de desconto ao vendedor sem concordancia do supervisor
User Function AprvVend(cAlias,nReg,nOpc)

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

Private oOk      			:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Private oNo      			:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Private oDLG
Private lMark    	:= .F.
Private lChk     	:= .F.
Private _aPedido	:= {}         
Private _aSupervisor := {}
Private oItemped                  
Private aHeader		:= {}
Private aHeadRec	:= {}
Private aCols		:= {}
Private aCloneCols	:= {}
Private aColsRec	:= {}
Private nUsado		:= 00
Private oSay4
Private oGet2
Private cGet2       := Space(230)

U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

Define FONT oFontBold NAME "Arial" Size 07, 17 BOLD

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resolve as dimensoes dos objetos na direita da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aObjects := {}
 
AADD(_aObjects,{100,100,.T.,.T.,.T.})
AADD(_aObjects,{100,100,.T.,.T.,.T.})	

_aSize3	  := aClone(_aPosObj1[02])	
_aInfo	  := {_aSize3[02],_aSize3[01],_aSize3[04],_aSize3[03],03,03}
_aPosObj3 := MsObjSize(_aInfo,_aObjects,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Interface ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define MsDialog oDlg From _aSize[07], 000 To _aSize[06],_aSize[05] Title OemtoAnsi( "Aprovação de desconto ao vendedor" ) Pixel Of oMainWnd

@ _aPosObj2[ 01 ][ 01 ] + 03, _aPosObj2[ 01 ][ 02 ]+250 Say OemToAnsi( "Pedidos/NFs" )			Font oFontBold Color CLR_GRAY Of oDlg Pixel

MsAguarde( {|| AtuList( @_aPedido, @_aSupervisor ) }, OemToAnsi( "Aguarde" ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta ListBox Titulos renegociados pendentes de aprovacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ _aPosObj2[01][01]+10,_aPosObj2[01][02] ListBox oPedido Var cVar ;
	Fields Header ;
	OemToAnsi("Pedido"),;
	OemToAnsi("Numero NF"),;
	OemToAnsi("Serie NF"),;
	OemToAnsi("Cliente"),;
	OemToAnsi("Loja"),;
    OemToAnsi("Nome"),;
	OemToAnsi("Data Devolucao"),;
	OemToAnsi("Motivo"),;	
	OemToAnsi("Valor NF"),;
    OemToAnsi("Valor Desconto"),;
    OemToAnsi("Quant. Total"),;
    OemToAnsi("Quant. Quebra"),;     
    OemToAnsi("Observacao"),;
    OemToAnsi("Justificativa Supervisor"),;   
    Size _aPosObj1[02][04]-20,_aPosObj2[02][04]-07 Of oDlg Pixel
                
oPedido:bChange := { || fVend( _aPedido[ oPedido:nAt ][ 02 ],_aPedido[ oPedido:nAt ][ 03 ] ,@_aSupervisor, "S" ) }

oPedido:SetArray( _aPedido )

oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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

oPedido:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta ListBox SZX          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ _aPosObj1[02][01]+14,_aPosObj1[02][02]+02 ListBox oItemped Var cVar ;
	Fields Header ;
	OemToAnsi("Qtd Dev."),;
    OemToAnsi("Produto"),;
    OemToAnsi("Descricao"),;
    OemToAnsi("Quant"),;
    OemToAnsi("Unidade"),;
    OemToAnsi("NF"),;
    OemToAnsi("Serie"),;
    OemToAnsi("Qtd 2"),;
    OemToAnsi("Unid. 2"),;
    OemToAnsi("Qtd. 2"),;
    OemToAnsi("Valor"),;
    OemToAnsi("Quebra"),;
    OemToAnsi("Motivo"),;
    OemToAnsi("Observacao"),;
    OemToAnsi("Item NF"),;    
    Size _aPosObj1[ 02 ][ 04 ] - 20 , _aPosObj1[ 02 ][ 03 ] - 90 Of oDlg Pixel
    
//@ 190, 026 SAY oSay4 PROMPT "Justificativa:" SIZE 109, 011 OF oDlg COLORS 0, 16777215 PIXEL   //210
//@ 190, 144 MSGET oGet2 VAR cGet2 SIZE 250, 010 OF oDlg VALID .T. COLORS 0, 16777215 PIXEL     //210

@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+170 BUTTON "Aprova"  SIZE 040,020 PIXEL OF oDlg Action U_APRVVDD(oPedido:nAt)     
@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+320 BUTTON "Reprova" SIZE 040,020 PIXEL OF oDlg Action U_REJVDD(oPedido:nAt)	  
@ _aPosObj1[02][01]+155,_aPosObj2[01][02]+450 BUTTON "Sair"     SIZE 064,014 PIXEL OF oDlg ACTION oDlg:End() 
                
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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}

oItemped:Refresh()

Activate MsDialog oDlg On Init EnchoiceBar( oDlg, {|| Processa( {|| MTHCProc() } ), oDlg:End() }, { || _nOpca := 00, oDlg:End() } )

Return (Nil)

Static Function AtuList( _aPedido, _aSupervisor)
&&processo apenas para limpar registros nao aprovados pelos supervisores em ate 3 dias....
If Select("Processo") > 0
   dbSelectarea("Processo")
   dbclosearea("Processo")      
endif

_dDia := Date()   

_cQuery := "Select "
_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_DTDISP,ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
_cQuery += "From "
_cQuery += RetSqlName( "ZZE" ) + " ZZE "                                                    //&&aqui enxerga de todos os supervisores ainda nao aprovados
_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' "    //AND ZZE.ZZE_USSUPE = '"+__cUserID+"' "
_cQuery += "And ZZE_UJUSTS = '      ' "
_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
_cQuery += "And ZZE.ZZE_APVVDD = 'S' "
_cQuery += "Order By ZZE.ZZE_PEDIDO "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
      
While Processo->(!Eof())

    &&Valido aqui se tem até 3 dias para ser apresentado
    If (_dDia - STOD(Processo->ZZE_DTDISP)) > 3   &&periodo maior que 3 dias
       //Mauricio inclui aqui a aprovação automatica do desconto pois passou de 3 dias.
       DbSelectArea("ZZE")
	   ZZE->(DbSetOrder(5))
	   if dbseek(xFilial("ZZE")+Processo->ZZE_NUMNF+Processo->ZZE_SERIE+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == Processo->ZZE_PEDIDO .AND. ZZE->ZZE_AP_REP == " " .AND. ZZE->ZZE_APVVDD == "S"&&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_AP_REP := "A"   &&Aprovado
			  ZZE->ZZE_DTAPRV := Date()
			  ZZE->ZZE_HRAPRV := Time()
			  ZZE->ZZE_UAPROV := "777777"    &&numero de usuario inexistente. Ficara como aprovação por expiração de prazo(3 dias)
			  ZZE->ZZE_DTJSTS := Date()
			  ZZE->ZZE_HRJSTS := Time()
			  ZZE->ZZE_UJUSTS := "777777"
		      ZZE->ZZE_JUSTSP := "Aprovado pois prazo 3 dias foi ultrapassado para justificativa"
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
	   Endif	  
       Processo->(dbSkip())
       loop
    Endif   
    Processo->(dbSkip())
Enddo    

DbCloseArea("Processo")
&&terminado processo de validar aprovacoes a mais de 3 dias....

If Select("Processo") > 0
   dbSelectarea("Processo")
   dbclosearea("Processo")      
endif
 
_dDia := Date()   

_cQuery := "Select "
_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_DTDISP,ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT, ZZE_QTQBRA, ZZE_UJUSTS, ZZE_JUSTSP, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
_cQuery += "From "
_cQuery += RetSqlName( "ZZE" ) + " ZZE "
_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' AND ZZE.ZZE_DTJSTS <> ' ' "
_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
_cQuery += "And ZZE.ZZE_APVVDD = 'S' "
_cQuery += "Order By ZZE.ZZE_PEDIDO "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
      
_aPedido := {}

While Processo->(!Eof())
      	    
	fVend( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

	   
	AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
	                 ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
	                 transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
	                 Alltrim(Processo->OBS),Alltrim(Processo->ZZE_JUSTSP)  } )
	Processo->(dbSkip())
	  
EndDo

dbCloseArea("Processo")

If Len(_aPedido) <= 00
	AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
	               ,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,,})
EndIf

If Len(_aSupervisor) <= 00
         AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
EndIf

Return(Nil)


Static Function fVend( _cNF,_cSer, _aSupervisor, _cTipo )

Local _cQuery		   := ""

_cQuery := "Select "
_cQuery += "ZX_QTDEV2U,ZX_QTDEV1U,ZX_CODPROD,ZX_DESCRIC,ZX_UNIDADE,ZX_NF,ZX_SERIE,ZX_QTSEGUM,ZX_SEGUM,ZX_TOTAL,ZX_QUEBRA,ZX_MOTIVO,CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZX_OBSER)) OBS,ZX_ITEMNF "
_cQuery += "From "
_cQuery += RetSqlName( "SZX" ) + " SZX"
_cQuery += " Where SZX.ZX_NF = '" + _cNF + "' AND SZX.ZX_SERIE = '"+ _cSer +"' "
_cQuery += "And SZX.ZX_FILIAL = '" + xFilial( "SZX" ) + "' "
_cQuery += "And SZX.D_E_L_E_T_ = ' ' "                            
_cQuery += "Order By SZX.ZX_NF, SZX.ZX_ITEMNF "
_cQuery := ChangeQuery( _cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Titulos", .F., .T. )
_aSupervisor := {}
While Titulos->(!Eof())
                   
    AADD( _aSupervisor, {Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),ALLTRIM(Titulos->ZX_CODPROD),ALLTRIM(Titulos->ZX_DESCRIC),Transform(Titulos->ZX_QTDEV2U,"@E 999,999,999.99"),;
    ALLTRIM(Titulos->ZX_UNIDADE),ALLTRIM(Titulos->ZX_NF),ALLTRIM(Titulos->ZX_SERIE),Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Alltrim(Titulos->ZX_SEGUM),;
    Transform(Titulos->ZX_QTSEGUM,"@E 999,999,999.99"),Transform(Titulos->ZX_TOTAL,"@E 999,999,999.99"),Transform(Titulos->ZX_QUEBRA,"@E 999,999,999.99"),;
    ALLTRIM(Titulos->ZX_MOTIVO),Alltrim(Titulos->OBS),ALLTRIM(Titulos->ZX_ITEMNF) } )   &&problema com campo MEMO ZX_OBSER
	Titulos->(dbSkip())
	
EndDo

dbCloseArea("Titulos")

If Len(_aSupervisor) <= 00
         AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
         "","",Transform(0,"@E 999,999,999.99"),"",;        
         Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
EndIf

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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
	oItemped:Refresh()

EndIf

Return ( Nil ) 

User function APRVVDD(_nPos)

Local _nPos
Private _cProcess := _aPedido[_nPos][1]    

U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')

If MsgYesNo("Aprova desconto relativo ao pedido "+_aPedido[_nPos][1]+" no valor de R$ "+_aPedido[_nPos][10]+" para o vendedor.")
        Begin transaction
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(5))
		if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVVDD == "S" &&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_AP_REP := "A"   &&Aprovado
			  ZZE->ZZE_DTAPRV := Date()
			  ZZE->ZZE_HRAPRV := Time()
			  ZZE->ZZE_UAPROV := __cUserID			  
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
		Endif	  
			  	  
		Atud(@_aPedido,@_aSupervisor)
							
		if oPedido != Nil
					
					oPedido:SetArray( _aPedido )
					
					oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
					
					oPedido:Refresh()
		EndIf
		if oItemped != Nil
					
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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
					oItemped:Refresh()
					
		EndIf
		End transaction								
Endif
Return()

User function REJVDD(_nPos)

Local _nPos
Private _cProcess := _aPedido[_nPos][1]

U_ADINF009P('APRVLOG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela aprovação para descontos clientes/transportadores')
     
If MsgYesNo("Rejeita desconto ao vendedor no valor de R$ "+_aPedido[_nPos][10]+".")        
        Begin transaction
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(5))
		if dbseek(xFilial("ZZE")+_aPedido[_nPos][2]+_aPedido[_nPos][3]+"S")  &&posiciona no registro pelo numero da NF e serie.
		   If ZZE->ZZE_PEDIDO == _aPedido[_nPos][1] .AND. ZZE->ZZE_APVVDD == "S"  &&Valida o pedido por segurança
		      RecLock("ZZE",.F.)
			  ZZE->ZZE_AP_REP := "R"   &&Rejeitado
			  ZZE->ZZE_DTAPRV := Date()
			  ZZE->ZZE_HRAPRV := Time()
			  ZZE->ZZE_UAPROV := __cUserID	
			  ZZE->(MsUnlock())			  			  			  
		   Endif	  
		Endif
			
		Atud(@_aPedido,@_aSupervisor)
							
		if oPedido != Nil
					
					oPedido:SetArray( _aPedido )
					
					oPedido:bLine := { || { _aPedido[oPedido:nAt][01],;
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
					
					oPedido:Refresh()
		EndIf
		if oItemped != Nil
					
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
						_aSupervisor[oItemped:nAt][12],;
						_aSupervisor[oItemped:nAt][13],;
						_aSupervisor[oItemped:nAt][14],;													
						_aSupervisor[oItemped:nAt][15]}}
					oItemped:Refresh()
					
		EndIf
		End transaction								
Endif
Return()

Static function Atud(_aPedido,_aSupervisor)
	If Select("Processo") > 0
	dbSelectarea("Processo")
	dbclosearea("Processo")
	endif   

	_cQuery := "Select "
	_cQuery += "ZZE_PEDIDO, ZZE_NUMNF, ZZE_SERIE, ZZE_CODCLI, ZZE_LOJA, ZZE_NOME, ZZE_VLDESC, ZZE_DTDEV, ZZE_DTDISP,ZZE_MOTIVO, ZZE_VLRNF, ZZE_QUANT,ZZE_UJUSTS, ZZE_QTQBRA, ZZE_JUSTSP, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZE_OBS)) OBS "
	_cQuery += "From "
	_cQuery += RetSqlName( "ZZE" ) + " ZZE "
	_cQuery += "Where ZZE.ZZE_FILIAL = '" + xFilial( "ZZE" ) + "' AND ZZE.ZZE_AP_REP = ' ' AND ZZE.ZZE_DTJSTS <> ' ' "
	_cQuery += "And ZZE.D_E_L_E_T_ = ' ' "                            
	_cQuery += "And ZZE.ZZE_APVVDD = 'S' "
	_cQuery += "Order By ZZE.ZZE_PEDIDO "
	_cQuery := ChangeQuery( _cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "Processo", .F., .T. )
		
	_aPedido := {}

	While Processo->(!Eof())
			
		fVend( Processo->ZZE_NUMNF, Processo->ZZE_SERIE, @_aSupervisor, "G" )

		
		AADD( _aPedido, {Processo->ZZE_PEDIDO, Processo->ZZE_NUMNF,Processo->ZZE_SERIE,ALLTRIM(Processo->ZZE_CODCLI),ALLTRIM(Processo->ZZE_LOJA),;
						ALLTRIM(Processo->ZZE_NOME),ALLTRIM(DTOC(STOD(Processo->ZZE_DTDEV))),ALLTRIM(Processo->ZZE_MOTIVO),transform(Processo->ZZE_VLRNF,"@E 99,999,999,999.99"),;
						transform(Processo->ZZE_VLDESC,"@E 99,999,999,999.99"),transform(Processo->ZZE_QUANT,"@E 999,999,999.9999"),transform(Processo->ZZE_QTQBRA,"@E 999,999,999.9999"),;	                 
						Alltrim(Processo->OBS),Alltrim(Processo->ZZE_JUSTSP)  } )
		Processo->(dbSkip())
		
	EndDo
	dbCloseArea("Processo")
		
	If Len(_aPedido) <= 00
		AADD(_aPedido,{"",OemToAnsi("Nao existem informacoes para a lista" ),"","","","","",;
					,Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),Transform(00,"@E 999,999,999.99"),,,})
		_aSupervisor := {}
		AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})	               
	EndIf

	If Len(_aSupervisor) <= 00
			AADD( _aSupervisor,{Transform(0,"@E 999,999,999.99"),OemToAnsi("Nao existem titulos para a lista"),"",Transform(0,"@E 999,999,999.99"),"",;
			"","",Transform(0,"@E 999,999,999.99"),"",;        
			Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),"","",""})
	EndIf

Return()
