#Include 'protheus.ch'
#Include "RwMake.ch"
#include "topconn.ch"

Static _cUsuDPR := ""      //por Adriana em 24/05/2017 chamado 035167

/*/{Protheus.doc} User Function MA120BUT
	Ponto de Entrada para inclusao de botoes na tela do PC
	@type  Function
	@author HCCONSYS
	@since ?
	@version version
	@history Chamado 035167	- Adriana		- 24/05/2017 - Tratar compra de produtor rural com desconto para filial Goias
	@history Chamado 036044	- Mauricio		- 07/07/2017 - Ajuste calculo
	@history Chamado 036044	- Adriana		- 07/07/2017 - Trocado forma de calculo para pegar o valor pago ao fornecedor
	@history Chamado 036434	- Adriana		- 25/07/2017 - Verifica se fornecedor possui liminar
	@history Chamado 036682	- William Costa	- 16/08/2017 - Incluir botao para digitar nome do responsavel
	@history Chamado 045319	- Adriana		- 26/11/2018 - Inclusão parametro MV_#SENAR para tratar aliquota do SENAR
	@history Chamado TI     - FWNM          - 26/03/2019 - Permitir alterar fornecedor 
	@history Chamado TI     - Sigoli        - 03/04/2019 - ALTERADO CAMPO DE/: CE_NUM PARA/: CE_NUMCOT
	@history Chamado 048333	- Adriana       - 18/04/2019 - Tratar SENAR sem FUNRURAL
	@history Chamado 048333	- Adriana     	- 24/04/2019 - Informar quando produtor tem Liminar
	@history Chamado TI		- Adriana		- 04/08/2020 - Desabilitar botao MEMO, devido error.log InterFunctionCall: cannot find function U_MEMOCOMP
	@history Ticket  76847  - Fernando Macieira - 20/07/2021 - falha aprovação pedido de compra.
/*/
User Function MA120BUT()

	Local aButtons	:= {}
	
	aAdd( aButtons, { "BUDGET", { || U_ConApr( "SC7", SC7->( Recno() ), 2, "PC" ) }, "Consulta Aprovacao","Aprovação" })  
	
	//por Adriana em 24/05/2017 chamado 035167
	if cempant = "01"
		_cUsuDPR  := Alltrim(GetMv("MV_#USUDPR")    )		
		if Alltrim(__cUserId) $ _cUsuDPR  //por Adriana em 24/05/2017 chamado 035167
			aAdd( aButtons, { "BUDGET", { || U_DescPR() }, "Desc.Prod.Rural","Desc.Pr.Rural" })
		Endif
	endif
	//fim - chamado 035167
	
	//chamado 036682 em 16/08/2017 William Costa
	aAdd( aButtons, { "BUDGET", { || U_RespPedComp() }, "Responsavel","Responsavel" })
	//chamado 036682 em 16/08/2017 William Costa
	
	//Desabilitado em 04/08/2020 por Adriana 
	//chamado 036682 em 16/08/2017 William Costa
	//aAdd( aButtons, { "BUDGET", { || U_MemoComp() }, "Memo","Memo" })
	//chamado 036682 em 16/08/2017 William Costa
	
	// Chamado TI - FWNM - 26/03/2019 - Permitir alterar fornecedor
	If ALTERA
		aAdd( aButtons, { "BUDGET", { || u_AltForPC() }, "Alterar Fornecedor","Alterar Fornecedor" } )
	EndIf	
	//

Return( aButtons )

/*/{Protheus.doc} User Function ConApr
	Consulta Aprovacao
	@type  User Function
	@author Microsiga
	@since 26/03/2019
	/*/

User Function ConApr( cAlias, nReg, nOpcx, cTipoDoc )

	Local aArea		:= GetArea()
	Local aSavCols  := aClone(aCols)
	Local aSavHead  := aClone(aHeader)
	
	Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
	Local cAliasSCR := "TMP"
	Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local cAddHeader:= ""
	
	Local lBloq     := .F.
	
	Local nUsado	:= 0
	Local nSavN		:= N
	Local nX   		:= 0
	Local nY        := 0
	
	Local oDlg
	Local oGet
	Local oBold
	              
	#IFDEF TOP
		Local cQuery   := ""
		Local aStruSCR := {}
	#ENDIF
	
	DEFAULT cTipoDoc := "PC"
	
	dbSelectArea(cAlias)
	dbSetOrder( 1 )
	MsSeek( xFilial( cAlias ) + cA120Num )
	
	IF cTipoDoc == "PC" .Or. cTipoDoc == "AE"
		cTitle    := OemToAnsi("Aprovacao do Pedido de Compra")
		cTitDoc   := OemToAnsi("Pedido")
		cHelpApv  := OemToAnsi("Este pedido nao possui controle de aprovacao." )
		cNumDoc   := SC7->C7_NUM
		cComprador:= UsrRetName(SC7->C7_USER)
		cStatus   := IIF( SC7->C7_CONAPRO == "L", OemToAnsi( "PEDIDO LIBERADO" ), OemToAnsi( "AGUARDANDO LIBERAÇÃO" ) )
	EndIf
	
	If !Empty(cNumDoc)
		
		aHeader:= {}
		aCols  := {}
		
		// Faz a montagem do aHeader com os campos fixos.                
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SCR")
		While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/CR_DATREJ" + cAddHeader
				nUsado++
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
				
				If AllTrim(x3_campo) == "CR_NIVEL"
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Usuário" ),"bCR_NOME",   "",15,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Situação" ),"bCR_SITUACA","",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Tp.Aprovação" ),"bCR_TPAPROV","",15,0,"","","C","",""} )
				EndIf
				
			Endif
			
			dbSelectArea("SX3")
			dbSkip()
		EndDo
		
		#IFDEF TOP
			
			IF cTipoDoc == "PC" .Or. cTipoDoc == "AE"
				
				aStruSCR := SCR->(dbStruct())
				cTipoDoc := "PC"
				cAliasSCR := GetNextAlias()
				cQuery    := "SELECT * FROM "+RetSqlName("SCR")+" SCR "
				cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
				cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
				cQuery    += "SCR.CR_TIPO = 'PC' AND "
				cQuery    += "SCR.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
				
				If (cAliasSCR)->(Eof())
					(cAliasSCR)->(dbCloseArea())
					cTipoDoc  := "AE"
					cAliasSCR := GetNextAlias()
					cQuery    := "SELECT * FROM "+RetSqlName("SCR")+" SCR "
					cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
					cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
					cQuery    += "SCR.CR_TIPO = 'AE' AND "
					cQuery    += "SCR.D_E_L_E_T_=' ' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
				EndIf
				
			EndIf
			
			For nX := 1 To Len(aStruSCR)
				If aStruSCR[nX][2]<>"C"
					TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
				EndIf
			Next nX
		#ELSE
			//  Abre o arquivo SCR sem filtros     
			ChkFile("SCR",.F.,"TMP")
			
			dbSelectArea(cAliasSCR)
			dbSetOrder(1)
			
			IF cTipoDoc == "PC" .Or. cTipoDoc == "AE"
				/*
				//  A rotina a seguir garante o funcionamento correto na base historica dos clientes,  
				//  pois com a implementacao do parametro MV_AEAPROV que estende o controle de alcadas 
				//  para a AE, em 22/07/04 foi alterada a gravacao do tipo do doc para PC e AE afim    
				//  de diferenciar o tipo de doc nos arquivos SC7 e SCR sem afetar o funcionamento ant 
				*/
				cTipoDoc := "PC"
				MsSeek(xFilial("SCR")+cTipoDoc+Padr(SC7->C7_NUM,Len(SCR->CR_NUM)))
				If (cAliasSCR)->( Eof() )
					cTipoDoc := "AE"
					MsSeek(xFilial("SCR")+cTipoDoc+Padr(SC7->C7_NUM,Len(SCR->CR_NUM)))
				EndIf
			EndIf
		#ENDIF
		
		dbSelectArea(cAliasSCR)
		
		While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,;
			len(IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",SC7->C7_NUM ,IIF(cTipoDoc == "CP",SC3->C3_NUM,SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )))) ;
			== xFilial("SCR") + cTipoDoc + cNumDoc
			
			aadd(aCols,Array(nUsado+1))
			nY++
			For nX := 1 to Len(aHeader)
				If aHeader[nX][02] == "bCR_NOME"
					aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
				ElseIf aHeader[nX][02] == "bCR_SITUACA"
					Do Case
						Case (cAliasSCR)->CR_STATUS == "01"
							cSituaca := OemToAnsi("Aguardando")
						Case (cAliasSCR)->CR_STATUS == "02"
							cSituaca := OemToAnsi("Em Aprovacao")
						Case (cAliasSCR)->CR_STATUS == "03"
							cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Aprovado"),IIF(cTipoDoc == "CP",OemToAnsi("Aprovado"),OemToAnsi("Aprovado")))
						Case (cAliasSCR)->CR_STATUS == "04"
							cSituaca := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("Rejeitado"),IIF(cTipoDoc == "CP",OemToAnsi("Rejeitado"),OemToAnsi("Rejeitado")))
							lBloq := .T.
						Case (cAliasSCR)->CR_STATUS == "05"
							cSituaca := OemToAnsi("Nivel Liberado ")
					EndCase
					aCols[nY][nX] := cSituaca
				ElseIf aHeader[nX][02] == "bCR_TPAPROV"
					aCols[nY][nX] := If( (cAliasSCR)->CR_XTPLIB == "V", "Vistador", "Aprovador" )
				ElseIf ( aHeader[nX][10] != "V")
					aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				EndIf
			Next nX
			aCols[nY][nUsado+1] := .F.
			dbSkip()
		EndDo
		
		If !Empty(aCols)
			If lBloq
				cStatus := IIF(cTipoDoc == "PC" .Or. cTipoDoc == "AE",OemToAnsi("REJEITADO"),IIF(cTipoDoc == "CP",OemToAnsi("REJEITADO"),OemToAnsi("REJEITADO")))
			EndIf
			n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
			If cTipoDoc <> "NF"
				@ 015,103 SAY OemToAnsi("Comprador") OF oDlg PIXEL SIZE 033,009 FONT oBold
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIF
			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
			If lBloq
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HRED
			Else
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HBLUE
			EndIf
			@ 132,210 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL
			oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("Atencao",cHelpApv,{"Voltar"}) //###"Este pedido nao possui controle de aprovacao."###
		EndIf
		
		dbSelectArea(cAliasSCR)
		dbCloseArea()
		aHeader := aClone(aSavHead)
		aCols   := aClone(aSavCols)
		N		:= nSavN
	Else
		Aviso("Atencao",cHelpApv,{"Voltar"}) //###"Este Documento nao possui controle de aprovacao."###
	EndIf
	
	dbSelectArea(cAlias)
	RestArea(aArea)

Return

/*/{Protheus.doc} User Function DescPR
	Janela para digitacao Desconto Produtor Rural 
	@type  User Function
	@author ADRIANA OLIVEIRA
	@since 24/05/2017
	@history Chamado 035167
	/*/

User Function DescPR()

	Local aAreaAnt 		:= GetArea() 
	Local _nOpt			:= 0
	Local _nPosXPDESCR 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_XPDESCR" } ) 
	Local _nPosXVDESCR 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_XVDESCR" } )
	Local _nPosTOTAL 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_TOTAL" } )
	
	Private oDlg
	
	//Mauricio - 07/07/2017 - Chamado 036044    
	_nSenar		:= GetMv("MV_#SENAR") //incluido por Adriana em 26/11/2018 - chamado 045319
	_lCalcIns	:= (posicione("SA2",1,xFilial("SA2")+ca120Forn+ca120Loj,"A2_XLIMINS")) <> "S" //se produtor nao tem liminar para INSS, calcula INSS - por Adriana em 24/04/2019 - chamado 048333  
	_cImp  		:= Alltrim(GetMv("MV_CONTSOC")    )
	_n_Pos 		:= at("/", _cImp)
	_nImp  		:= iif(_lCalcIns,(VAL(Substr(_cImp,1,_n_Pos)) / 100),0) // por Adriana em 18/04/2019 - chamado 048333
	_nImp  		:= _nImp + (_nSenar/100) //por Adriana em 18/04/2019 - chamado 048333
	_nImp  		:= iif(!Empty(Alltrim(posicione("SA2",1,xFilial("SA2")+ca120Forn+ca120Loj,"A2_TIPORUR"))),_nImp,0)       // se produtor rural considera o FUNRURAL - 036434 - Adriana em 25/07/2017
	_nPDescR 	:= Acols[1,_nPosXPDESCR]     
	_nPVescR 	:= Acols[1,_nPosXVDESCR]
	_nTotal  	:= Acols[1,_nPosTOTAL]
	
	_nPagFor 	:= 0.00
	
	_lCopia 	:= lCop
	
	If Alltrim(__cUserId) $ _cUsuDPR
		
		If INCLUI .OR. ALTERA .OR. _lCopia
			
			@0,0 TO 220,400 DIALOG oDlg TITLE "% Desconto Produtor Rural"
			
			//Chamado 036044 - 07/07/2017 - Trocado forma de calculo para pegar o valor pago ao fornecedor ao invés do desconto, o qual
			//sera calculado a partir do valor pago.
			/*
			@20,20 SAY "% Desconto            : "
			@20,80 MSGET _nPDescR picture "@E 99.99999" SIZE 80,10 PIXEL OF oDlg
			@40,20 SAY "Valor Desconto        : " + transform(_nTOTAL*(_nPDescR/100),"@E 9,999,999,999.99") SIZE 220,10 PIXEL OF oDlg
			@60,20 SAY "Valor Total - Desconto: " + transform(_nTotal-(_nTOTAL*(_nPDescR/100)),"@E 9,999,999,999.99") SIZE 220,10 PIXEL OF oDlg
			*/
			
			@20,20 SAY "Valor pago Fornecedor : "
			@20,80 MSGET _nPagFor picture "@E 9,999,999,999.99" SIZE 80,10 PIXEL OF oDlg
			@40,20 SAY "Valor Desconto        : " + transform((_nTOTAL - (_nTOTAL * _nImp)) - _nPagFor,"@E 9,999,999,999.99") SIZE 220,10 PIXEL OF oDlg
			@60,20 SAY "% Desconto: " + transform(((((_nTOTAL - (_nTOTAL * _nImp)) - _nPagFor)/_nTOTAL)*100),"@E 999.99999") SIZE 220,10 PIXEL OF oDlg
			@80,20 SAY "% FUNRURAL: " + transform( _nImp,"@E 999.99999") + iif(!_lCalcIns,"   *** Tem Liminar ***","") SIZE 220,10 PIXEL OF oDlg //informar se produtor tem liminar - por Adriana em 24/04/2019 - chamado 048333
			
			@ 88,100 BUTTON "&Gravar" SIZE 33,14 PIXEL ACTION (_nOpt := 1,oDlg:End())
			@ 88,150 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()
			
			ACTIVATE DIALOG oDlg CENTER
			
			if _nOpt = 1
				_nPDescR := ((((_nTOTAL - (_nTOTAL * _nImp)) - _nPagFor)/_nTOTAL)*100)
				_nVDescR := (_nTOTAL - (_nTOTAL * _nImp)) - _nPagFor
				Acols[1,_nPosXPDESCR] := _nPDescR
				Acols[1,_nPosXVDESCR] := _nVDescR
				
			Endif
			
		Else  //Visualizacao
			
			@0,0 TO 220,400 DIALOG oDlg TITLE "% Desconto Produtor Rural"
			
			@20,20 SAY "Valor pago Fornecedor : " + transform( Round((_nTOTAL - (_nTOTAL * _nImp)) - ((_nPDescR / 100) * _nTOTAL),0),"@E 9,999,999,999.99") SIZE 220,10 PIXEL OF oDlg
			@40,20 SAY "Valor Desconto        : " + transform( Round(((_nPDescR / 100) * _nTOTAL),0),"@E 9,999,999,999.99") SIZE 220,10 PIXEL OF oDlg
			@60,20 SAY "% Desconto: " + transform(_nPDescR,"@E 999.99999") SIZE 220,10 PIXEL OF oDlg		
			@80,20 SAY "% FUNRURAL: " + transform( _nImp,"@E 999.99999") SIZE 220,10 PIXEL OF oDlg  //Incluido para informar quando tem FUNRURAL - chamado 036434 - em 25/07/2017 por Adriana
			
			@ 88,150 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()
			
			ACTIVATE DIALOG oDlg CENTER
			
		Endif
	ENDIF
	
	RestArea(aAreaAnt)

Return

/*/{Protheus.doc} User Function RespPedComp
	Janela para digitacao Responsavel 
	@type  User Function
	@author William Costa
	@since 16/08/2017
	@history Chamado 036682
	/*/

User Function RespPedComp()

	Local aAreaAnt 		:= GetArea() 
	Local nOpcaoTela    := 0
	Local cResponsavel  := SPACE(60)
	Local nPosXRespon 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_XRESPON" } ) 
	Local nCont         := 0
	Private oDlg
	
	IF !EMPTY(Acols[1,nPosXRespon])             
	
		cResponsavel := Acols[1,nPosXRespon] 
	
	ENDIF
	
	If INCLUI .OR. ALTERA .OR. lCop // copia
		
		@0,0 TO 110,300 DIALOG oDlg TITLE "Responsável"
		@10,20 SAY "Digite o Responsável pelo Pedido : "
		@20,20 MSGET cResponsavel picture "@!" SIZE 120,10 PIXEL OF oDlg
		
		@ 40,050 BUTTON "&Gravar" SIZE 33,14 PIXEL ACTION (nOpcaoTela := 1,oDlg:End())
		@ 40,108 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()
		
		ACTIVATE DIALOG oDlg CENTER
		
		IF nOpcaoTela = 1
		
			FOR nCont:=1 TO LEN(Acols)
			
				Acols[nCont,nPosXRespon] := cResponsavel
			
			NEXT nCont
			
		ENDIF
		
	ELSE  //Visualizacao
		
		@0,0 TO 110,300 DIALOG oDlg TITLE "Responsável"
		@10,20 SAY "Digite o Responsável pelo Pedido : "
		@20,20 MSGET cResponsavel picture "@!" SIZE 120,10 PIXEL OF oDlg
		
		@ 40,108 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()
		
		ACTIVATE DIALOG oDlg CENTER
		
	Endif
	
	RestArea(aAreaAnt)
	
Return

/*/{Protheus.doc} Static Function Memo(nTipo)
	? 
	@type  Static Function
	@author ?
	@since 26/03/2019
	@history Chamado  
	/*/

Static Function Memo(nTipo)

    //Variáveis para HotKey F4.
    Local nPCod         := ""
    Local cProduto      := ""
    Local aParametro    := {}
    //

    Local aDados        := {}

    //Variáveis para Hotkey .
    Local cPedido       := ""
    //

    Private cNomeUser   := ""//Alltrim(UsrRetName(__CUSERID))

    If nTipo == 1

        If Type ("aCols") == "A"

            nPCod       := aScan( aHeader, {|x| AllTrim(x[2]) == "C7_PRODUTO" } )

            If nPCod = 0
                Return
            EndIf

            cProduto    := aCols[n,nPCod]

            //If Empty(Alltrim(cValToChar(cProduto)))
                //Return
            //EndIf

            Aadd(aParametro,{1,cProduto})   //Parâmetros a serem passados a função de consulta ao DB.
            aDados := consultarDB(aParametro)         //Consulta ao banco de dados.

            //Verifica se há dados no retorno do DB.
            If Len(aDados) > 0
                montarTela(aDados,cProduto)
            Else
                MsgStop(cNomeUser + "Não há dados a serem exibidos.")
            EndIf
            //

        EndIf

    ElseIf nTipo == 2

        If Type ("aCols") == "A"

            cPedido := SC7->C7_NUM
            Aadd(aParametro,{2,cPedido})   //Parâmetros a serem passados a função de consulta ao DB.
            aDados := consultarDB(aParametro)         //Consulta ao banco de dados.
            //Verifica se há dados no retorno do DB.
            If Len(aDados) > 0
                montarTela(aDados)
            Else
                MsgStop(cNomeUser + "! Não há dados a serem exibidos.")
            EndIf
            //
            MsgInfo(cNomeUser + " Segunda HotKey F11 número do pedido " + cValToChar(cPedido) + ".")

        EndIf

    EndIF

Return


/*/{Protheus.doc} Static Function montarTela(aDados,cProduto)
	? 
	@type  Static Function
	@author ?
	@since 26/03/2019
	@history Chamado  
	/*/

Static Function montarTela(aDados,cProduto)

    Local i
    Local cString   := ""
    Local aSB1
    Local cDescProd
    Local nPreco    := ""
    Local nQtd      := ""
    Local cCond     := ""
    Local cData     := ""
    Local cFornec   := ""
    Local cMemo     := ""

    //Variáveis para montagem da tela.
    Local oButton1
    Local oSay1
    Local oDlg
    Local oGroup1
    Local oGroup2
    //

    Local aMenoCot  := {}
    Local aMenoComp := {}

    aSB1 := GetArea("SB1")
    cDescProd := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
    RestArea(aSB1)

    For i := 1 To Len(aDados)
        nPreco  := Transform(aDados[i][1],"@E 999,999.99")
        nQtd    := cValToChar(aDados[i][2])+" "+ cValToChar(aDados[i][8])
        cData   := cValToChar(aDados[i][3])
        cFornec := cValToChar(aDados[i][4])
        cFiscal := cValToChar(aDados[i][6])
        cPedido := cValToChar(aDados[i][5])
        cMemo   := Alltrim(cValToChar(aDados[i][7]))
        cCond   := Alltrim(cValToChar(aDados[i][9]))

        cPP     := cValToChar(aDados[i][10])
        cES     := cValToChar(aDados[i][11])
        cLT     := cValToChar(aDados[i][12])
        cLE     := cValToChar(aDados[i][13])
    Next

    aMenoCot    := getMenoColt(cProduto)
    aMenoComp   := getMenoComp(cProduto)

    DEFINE FONT oFont BOLD

  	//Montagem da tela com as informações do item do pedido de compra.
    Define MsDialog oDlg Title "Informações de Compras" From 000, 000  To 500, 800 COLORS 0, 16777215 Pixel Style DS_MODALFRAME

        @ 005, 011 Say oSay1 Prompt "Seguem abaixo informações referentes ao item: " + Alltrim(cProduto) +"-"+cDescProd Size 500, 011 FONT oFont COLOR CLR_RED Of oDlg Pixel

        //Bloco com informações da última compra.
        @ 021, 011 GROUP oGroup1 To 100, 260 PROMPT "Última Compra"       Of oDlg COLOR 0, 16777215 Pixel
        @ 034, 015 Say "Preço: "            Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 034, 055 Say "R$ "+ nPreco        Size 100, 011 Of oDlg Pixel

        @ 034, 095 Say "Nota Fiscal: "      Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 034, 130 Say cFiscal              Size 200, 011 Of oDlg Pixel

        @ 034, 175 Say "Pedido: "           Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 034, 200 Say cPedido              Size 200, 011 Of oDlg Pixel

        @ 047, 015 Say "Qtd.: "             Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 047, 055 Say nQtd                 Size 100, 011 Of oDlg Pixel

        @ 060, 015 Say "Cond. Pag.: "       Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 060, 055 Say cCond                Size 100, 011 Of oDlg Pixel

        @ 073, 015 Say "Data: "             Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 073, 055 Say cData                Size 100, 011 Of oDlg Pixel

        @ 086, 015 Say "Fornecedor: "       Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 086, 055 Say cFornec              Size 200, 011 Of oDlg Pixel

        //Bloco com informações da gestão de estoque.
        //@ 096, 011 GROUP oGroup2 To 100, 385 PROMPT "Gestão de Estoque" Of oScroll COLOR 0, 16777215 Pixel
        //@ 109, 015 Say "Giro de estoque: "   Size 200, 011 Of oScroll Pixel

        @ 021, 270 GROUP oGroup1 To 142, 390 PROMPT ""       Of oDlg COLOR 0, 16777215 Pixel
        If Len(aMenoCot) > 0
        //Bloco com os valores da menor cotação
            @ 023, 274 Say "Menor Cotação"                        Size 100, 011 FONT oFont COLOR CLR_RED Of oDlg Pixel

            @ 033, 274 Say "Data: "                               Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 033, 309 Say cValToChar(aMenoCot[1][2])             Size 200, 011 Of oDlg Pixel

            @ 043, 274 Say "Forn.: "                              Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 043, 309 Say cValToChar(aMenoCot[1][3])             Size 100, 011 Of oDlg Pixel

            @ 053, 274 Say "Preço "                               Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 053, 309 Say Alltrim(Transform(aMenoCot[1][1],"@E 999,999.99"))             Size 100, 011 Of oDlg Pixel

            @ 063, 274 Say "Qtd. "                                Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 063, 309 Say cValToChar(aMenoCot[1][4])             Size 100, 011 Of oDlg Pixel

            @ 073, 274 Say "Cond. Pag "                           Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 073, 309 Say cValToChar(aMenoCot[1][5])             Size 100, 011 Of oDlg Pixel

        EndIf
        @ 078, 274 Say "-------------------------------------------------------------------"Size 112, 011 Of oDlg Pixel
    	If Len(aMenoComp) > 0
        //Bloco com os valores de menor preço de compra
            @ 083, 274 Say "Menor preço de compra"                Size 100, 011 FONT oFont COLOR CLR_RED Of oDlg Pixel

            @ 093, 274 Say "Data: "                               Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 093, 309 Say cValToChar(aMenoComp[1][2])            Size 200, 011 Of oDlg Pixel

            @ 103, 274 Say "Forn.: "                              Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 103, 309 Say cValToChar(aMenoComp[1][3])            Size 100, 011 Of oDlg Pixel

            @ 113, 274 Say "Preço "                               Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 113, 309 Say Alltrim(Transform(aMenoComp[1][1],"@E 999,999.99"))             Size 100, 011 Of oDlg Pixel

            @ 123, 274 Say "Qtd. "                                Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 123, 309 Say cValToChar(aMenoComp[1][4])            Size 100, 011 Of oDlg Pixel

            @ 133, 274 Say "Cond. Pag "                           Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
            @ 133, 309 Say cValToChar(aMenoComp[1][5])            Size 100, 011 Of oDlg Pixel
 
        EndIf

        //Bloco com memo do último
        @ 110, 011 Say oSay1 Prompt "Memo" Size 50, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 120, 011 Scrollbox oScroll Vertical Horizontal Size 100,200 Pixel of oDlg Border
        @ 002, 005 Say cMemo Size 400, 400 Of oScroll Pixel
        //

        @ 143, 220 GROUP oGroup2 To 220, 395 PROMPT "MRP/Suprimentos" Of oDlg COLOR 0, 16777215 Pixel

        @ 153, 224 Say "Ponto de pedido "       Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 153, 290 Say cPP                      Size 100, 011 Of oDlg Pixel

        @ 163, 224 Say "Estoque de segurança"   Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 163, 290 Say cES                      Size 200, 011 Of oDlg Pixel

        @ 173, 224 Say "Lead time"              Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 173, 290 Say cLT                      Size 200, 011 Of oDlg Pixel

        @ 183, 224 Say "Lote economico"         Size 100, 011 FONT oFont COLOR CLR_BLACK Of oDlg Pixel
        @ 183, 290 Say cLE                      Size 100, 011 Of oDlg Pixel

        //Bloco com os botões da interface.
        @ 230, 230 Button oButton1 Prompt "Ok"          SIZE 050, 011    Of oDlg Action (oDlg:End()) Pixel
        @ 230, 285 Button oButton1 Prompt "Cotações"    SIZE 050, 011    Of oDlg Action (gerarGrfCotacao(cProduto)) Pixel
        @ 230, 340 Button oButton1 Prompt "Consumo"     SIZE 050, 011    Of oDlg Action (gerarGrafico(cProduto)) Pixel
 
    Activate MSDIALOG oDlg Centered
 
Return

/*/{Protheus.doc} Static Function consultarDB(aTipo)
	? 
	@type  Static Function
	@author ?
	@since 26/03/2019
	@history Chamado  
	/*/

Static Function consultarDB(aTipo)

    Local aRet      := {}
    Local cQuery    := ""

        cQuery += " SELECT  TOP 1"
        cQuery += " D1_VUNIT, D1_QUANT, CONVERT(VARCHAR(10),CAST(D1_DTDIGIT AS DATE),103) AS D1_DTDIGIT,"
        cQuery += " D1_FORNECE+'/'+D1_LOJA+'-'+A2_NOME AS FORNEC, "
        cQuery += " D1_PEDIDO, D1_DOC+'-'+D1_SERIE AS NOTA, CONVERT(VARCHAR(8000),CONVERT(BINARY(8000) ,C7_XMEMO)) AS MEMO, D1_UM, E4_DESCRI, "

        cQuery += " B1_EMIN, B1_ESTFOR, CAST(B1_PE AS VARCHAR)+'-'+CAST(B1_TIPE AS VARCHAR)  AS LT, B1_LE "

        cQuery += " FROM "
        cQuery += " " + RetSqlName("SD1") + " (NOLOCK) AS SD1 "
        cQuery += " INNER JOIN "
        cQuery += "  " + RetSqlName("SB1") + "  (NOLOCK) AS SB1 "
        cQuery += " ON D1_COD = B1_COD "
        cQuery += " INNER JOIN "
        cQuery += "  " + RetSqlName("SF4") + "  (NOLOCK) AS SF4 "
        cQuery += " ON D1_TES = F4_CODIGO "
        cQuery += " INNER JOIN "
        cQuery += "  " + RetSqlName("SA2") + "  (NOLOCK) AS SA2 "
        cQuery += " ON D1_FORNECE = A2_COD "
        cQuery += " AND D1_LOJA = A2_LOJA "

        cQuery += " LEFT OUTER JOIN "
        cQuery += "  " + RetSqlName("SC7") + "  (NOLOCK) AS SC7 "
        cQuery += " ON D1_FILIAL = C7_FILIAL "
        cQuery += " AND D1_PEDIDO = C7_NUM "
        cQuery += " AND D1_FORNECE = C7_FORNECE "
        cQuery += " AND D1_LOJA = C7_LOJA "
        cQuery += " AND D1_COD = C7_PRODUTO "

        cQuery += " INNER JOIN "
        cQuery += "  " + RetSqlName("SE4") + "  (NOLOCK) AS SE4 "
        cQuery += " ON C7_COND = E4_CODIGO "

        cQuery += " WHERE "
        cQuery += " SD1.D_E_L_E_T_ = '' "
        cQuery += " AND SB1.D_E_L_E_T_ = '' "
        cQuery += " AND SF4.D_E_L_E_T_ = '' "
        cQuery += " AND SA2.D_E_L_E_T_ = '' "
        cQuery += " AND SC7.D_E_L_E_T_ = '' "
        cQuery += " AND SE4.D_E_L_E_T_ = '' "
        cQuery += " AND F4_DUPLIC = 'S' "
        cQuery += " AND D1_DOC <> '' "

        If aTipo[1][1] == 1

            cQuery += " AND D1_COD = '" + Alltrim(cValToChar(aTipo[1][2])) + "' "
            cQuery += " ORDER BY CAST(D1_DTDIGIT AS DATE) DESC  "
        ElseIf aTipo[1][1] == 2

            cQuery += " AND D1_PEDIDO = '" + Alltrim(cValToChar(aTipo[1][2])) + "' "

        EndIf

    If Select("DADOS") > 0
        DADOS->(DbCloseArea())
    EndIF

    TcQuery cQuery New Alias "DADOS"

    DbSelectArea("DADOS")
    DADOS->(DbGoTop())
    While !DADOS->(Eof())

        Aadd(aRet,{;
                    DADOS->D1_VUNIT     ,; //1-Preço unitário.
                    DADOS->D1_QUANT     ,; //2-Quantidade.
                    DADOS->D1_DTDIGIT   ,; //3-Data de digitação.
                    DADOS->FORNEC       ,; //4-Fornecedor.
                    DADOS->D1_PEDIDO    ,; //5-Pedido.
                    DADOS->NOTA         ,; //6-Nota.
                    DADOS->MEMO         ,; //7-Memo.
                    DADOS->D1_UM        ,; //8-Unidade.
                    DADOS->E4_DESCRI    ,; //9-Prazo de pagamento.
                    DADOS->B1_EMIN      ,; //10-Ponto de pedido.
                    DADOS->B1_ESTFOR    ,; //11-Estoque de segurança.
                    DADOS->LT           ,; //12-Lead Time
                    DADOS->B1_LE         ; //13-Lote economico
        })

        DADOS->(DbSkip())
    EndDo
    DbCloseArea("DADOS")

Return aRet

/*/{Protheus.doc} User Function AltForPC()
	Permite alterar fornecedor seguindo alguns criterios para manter a integridade dos dados   
	@type  User Function
	@author FWNM 
	@since 26/03/2019
	@history Chamado  
	/*/

User Function AltForPC()

	Local lRet       := .t.
	Local cNumPC     := SC7->C7_NUM
	Local cForPC     := SC7->C7_FORNECE
	Local cLojPC     := SC7->C7_LOJA
	Local cNumCot    := SC7->C7_NUMCOT

	Local aAreaFIE   := FIE->( GetArea() )
	Local aAreaSA2   := SA2->( GetArea() )

	// parametros
	Local lUsrAut    := GetMV("MV_#USRLIG",,.f.) // Ativa controle de usuarios autorizados
	Local cUsrAut    := GetMV("MV_#USRPCF",,"000000") // Usuarios autorizados

	// dialog
	Local oDlgAltFor	
	Local lOKAltFor  := .f.
	Local cNEWCodFor := Space(06)
	Local cNEWLojFor := Space(02)
	Local oCmpNewFor := Array(01)
	Local oCmpNewLoj := Array(01)
	Local oBtnAltFor := Array(02)

	// Consisto usuarios autorizados
	If lUsrAut
		If !(cUsrAut $ RetCodUsr())
			lRet := .f.
			Aviso(	"MA120BUT-05",;
					"Login não autorizado... Alteração do fornecedor não permitida!",;
					{ "&Retorna" },,;
					"Altera Fornecedor" )
		EndIf
	EndIf


	// Consisto se o PC teve movimentacoees
	/*
	aAdd(aCores,    { 'C7_QUJE==0 .And. C7_QTDACLA==0'   		, 'ENABLE'})	  	//-- Pendente
	aAdd(aCores,    { 'C7_QUJE<>0.And.C7_QUJE<C7_QUANT'			, 'BR_AMARELO'}) 	//-- Pedido Parcialmente Atendido
	aAdd(aCores,    { 'C7_QUJE>=C7_QUANT'   					, 'DISABLE'})	  	//-- Pedido Atendido
	aAdd(aCores,    { 'C7_QTDACLA >0' 							, 'BR_LARANJA'}) 	//-- Pedido Usado em Pre-Nota
	*/
	If lRet
		If SC7->C7_QUJE <> 0
			lRet := .f.
			Aviso(	"MA120BUT-01",;
					"Pedido de compra atendido ou parcialmente atendido... Alteração do fornecedor não permitida!",;
					{ "&Retorna" },,;
					"Altera Fornecedor" )
		EndIf
	EndIf
		
	If lRet
		If SC7->C7_QTDACLA > 0
			lRet := .f.
			Aviso(	"MA120BUT-02",;
					"Pedido de compra usado em pré-nota... Alteração do fornecedor não permitida!",;
					{ "&Retorna" },,;
					"Altera Fornecedor" )
		EndIf
	EndIf
	
	// Consisto se o PC possui adiantamento incluido ou amarrado pela rotina padrao do pedido de compras
	If lRet
		FIE->( dbSetOrder(1) ) // FIE_FILIAL+FIE_CART+FIE_PEDIDO
		If FIE->( dbSeek( FWxFilial("FIE")+"P"+cNumPC ) )
			lRet := .f.
			Aviso(	"MA120BUT-03",;
					"Pedido de compra possui amarração com adiantamento... Alteração do fornecedor não permitida!",;
					{ "&Retorna" },,;
					"Altera Fornecedor" )
		EndIf
	EndIf
		
	// Efetuo a alteracao do fornecedor
	If lRet
	
		Do While .T.
		
			DEFINE MSDIALOG oDlgAltFor TITLE "Novo Fornecedor" FROM 0,0 TO 135,340  OF oMainWnd PIXEL
				
				@ 003, 003 TO 050,165 PIXEL OF oDlgAltFor
				
				@ 015,018 Say "Cod. Fornecedor:" of oDlgAltFor PIXEL
				@ 010,065 MsGet oCmpNewFor Var cNewCodFor SIZE 70,12 of oDlgAltFor PIXEL Valid (!Empty(cNewCodFor) .and. ExistCpo("SA2",cNewCodFor)) F3 'SA2'
	
				@ 030,018 Say "Loja Fornecedor:" of oDlgAltFor PIXEL
				@ 025,065 MsGet oCmpNewLoj Var cNewLojFor SIZE 35,12 of oDlgAltFor PIXEL Valid (!Empty(cNewLojFor)) 
				
				@ 052,015 BUTTON oBtnAltFor[01] PROMPT "Confirma"     of oDlgAltFor   SIZE 68,12 PIXEL ACTION (lOKAltFor := .t. , oDlgAltFor:End())
				@ 052,089 BUTTON oBtnAltFor[02] PROMPT "Cancela"      of oDlgAltFor   SIZE 68,12 PIXEL ACTION oDlgAltFor:End()
				
			ACTIVATE MSDIALOG oDlgAltFor CENTERED
			                                      
			// Botao confirmar
			If lOKAltFor
				// Carrego CNPJ do fornecedor original (SC7) para checar o tronco com o novo codigo informado
				cCNPJOri := Posicione("SA2",1,FWxFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_CGC")
				
				SA2->( dbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
				If SA2->( dbSeek( FWxFilial("SA2")+cNewCodFor+cNewLojFor ) )
					// Comparo se o fornecedor/loja informado e igual ao ja cadastrado
					If cForPC == cNewCodFor .and. cLojPC == cNewLojFor
						lRet := .f.
						Aviso(	"MA120BUT-07",;
						"Fornecedor/Loja informados são iguais ao já utilizados no pedido de compras... Alteração do fornecedor não realizada!",;
						{ "&Retorna" },,;
						"Fornecedor/Loja informado iguais" )
						Exit
					EndIf
					
					// Comparo se e o mesmo tronco
					If lRet
						If Left(AllTrim(SA2->A2_CGC),8) <> Left(AllTrim(cCNPJOri),8)
							lRet := .f.
							Aviso(	"MA120BUT-08",;
							"CNPJ raiz do novo fornecedor não é igual ao utilizado no pedido de compras... Alteração do fornecedor não realizada!",;
							{ "&Retorna" },,;
							"CNPJ Raiz diferente" )
							Exit
						EndIf
					EndIf
					
					// Confirmo com o usuário se realmente deseja alterar o fornecedor do pc
					If lRet
						If msgNoYes("Tem certeza de que deseja alterar o fornecedor neste pedido de compra? " + CHR(13) + CHR(10) + "Atenção: O fornecedor será alterado a partir desta confirmação mesmo que você feche o pedido de compras ou clique no botão cancelar...")
							MsgRun( "Efetuando alteração do fornecedor...","Específico - Altera Fornecedor", { || RunAltForPC(cNumPC,cForPC,cLojPC,cNumCot,cNEWCodFor,cNEWLojFor) } )
							MessageBox("Mesmo que você feche o sistema ou este pedido de compras ou clique no botão cancelar, o fornecedor já foi alterado!","Alteração do fornecedor concluída com sucesso!",0)
							Exit
						Else
							Alert("Fornecedor não alterado!")
							Exit
						EndIf
					EndIf
				Else
					lRet := .f.
					Aviso(	"MA120BUT-06",;
					"Fornecedor/Loja informados não cadastrado... Alteração do fornecedor não permitida!",;
					{ "&Retorna" },,;
					"Fornecedor Inválido" )
					Exit
				EndIf
			Else
				Alert("Fornecedor não alterado!")
				Exit
			Endif
		
		EndDo
	
	EndIf

	RestArea( aAreaFIE )
	RestArea( aAreaSA2 )

Return lRet

/*/{Protheus.doc} Static Function RunAltForPC
	?
	@type  Static Function
	@author FWNM 
	@since 26/03/2019
	@history Chamado  
	/*/

Static Function RunAltForPC(cNumPC,cForPC,cLojPC,cNumCot,cNEWCodFor,cNEWLojFor)

	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaSC8 := SC8->( GetArea() )
	Local aAreaSCE := SCE->( GetArea() )
	Local aAreaSCR := SCR->( GetArea() )
	
	Begin Transaction
	
		// Gravo Log ZBE
		u_GrLogZBE (Date(),TIME(),cUserName,"PC " + cNumPC + " - VER PC ANTES DA ALTERACAO NA TABELA SCY ","COMPRAS ","MA120BUT ",;
					   		   				"ADORO - ALTERA FORNECEDOR ",ComputerName(),LogUserName()) 
		
		// Gero SCY - Historico PC (Antes da alteracao - usuario pode clicar em cancelar e a rotina padrao nao ira gerar a mesma
		GrvSCY()
		
		// PC
		SC7->( dbGoTop() )
		
		SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		If SC7->( dbSeek( FWxFilial("SC7")+cNumPC ) )
			Do While SC7->( !EOF() ) .and. SC7->C7_FILIAL == FWxFilial("SC7") .and. AllTrim(SC7->C7_NUM) == AllTrim(cNumPC)
				RecLock("SC7", .f.)
					SC7->C7_FORNECE := cNEWCodFor
					SC7->C7_LOJA    := cNEWLojFor
					SC7->C7_CONAPRO := "B" // Bloqueio PC
				SC7->( msUnLock() )
			
				SC7->( dbSkip() )
			EndDo
		EndIf
		
		// Alcada
		//SCR->( dbSetOrder(4) ) // CR_FILIAL+CR_NUM
		SCR->( dbOrderNickName("SCRNUM") ) // CR_FILIAL, CR_NUM, R_E_C_N_O_, D_E_L_E_T_ // @history Ticket  76847  - Fernando Macieira - 20/07/2021 - falha aprovação pedido de compra
		If SCR->( dbSeek( FWxFilial("SCR")+cNumPC ) )
			Do While SCR->( !EOF() ) .and. SCR->CR_FILIAL == FWxFilial("SCR") .and. AllTrim(SCR->CR_NUM) == AllTrim(cNumPC)
				RecLock("SCR", .f.)
					SCR->CR_STATUS  := Iif(AllTrim(SCR->CR_NIVEL)=="01","02","01")
					SCR->CR_DATALIB := CtoD("  /  /  ")
					SCR->CR_VALLIB  := 0
					SCR->CR_WF      := ""
					SCR->CR_WFID    := ""
					SCR->CR_XHORA   := ""
				SCR->( msUnLock() )
			
				SCR->( dbSkip() )
			EndDo
		EndIf
        
		// Cotacao
		SC8->( dbSetOrder(1) ) // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
		If SC8->( dbSeek( FWxFilial("SC8")+cNumCot+cForPC+cLojPC ) )
			Do While SC8->( !EOF() ) .and. SC8->C8_FILIAL == FWxFilial("SC8") .and. AllTrim(SC8->C8_NUM) == AllTrim(cNumCot) .and. AllTrim(SC8->C8_FORNECE) == AllTrim(cForPC) .and. AllTrim(SC8->C8_LOJA) == AllTrim(cLojPC)
				RecLock("SC8", .f.)
					SC8->C8_FORNECE := cNEWCodFor
					SC8->C8_LOJA    := cNEWLojFor
				SC8->( msUnLock() )
			
				SC8->( dbSkip() )
			EndDo
		EndIf
		
		// Encerramento cotacoes
		SCE->( dbSetOrder(1) ) // CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_FORNECE+CE_LOJA+CE_ITEMGRD
		If SCE->( dbSeek( FWxFilial("SCE")+cNumCot ) )
			Do While SCE->( !EOF() ) .and. SCE->CE_FILIAL == FWxFilial("SCE") .and. AllTrim(SCE->CE_NUMCOT) == AllTrim(cNumCot)  //Chamado : TI 03/04/2019 . Fernando Sigoli
				If SCE->CE_FORNECE == cForPC .and. SCE->CE_LOJA == cLojPC
					RecLock("SCE", .f.)
						SCE->CE_FORNECE := cNEWCodFor
						SCE->CE_LOJA    := cNEWLojFor
					SCE->( msUnLock() )
				EndIf
				
				SCE->( dbSkip() )
			EndDo
		EndIf
		
		// Atualizao variaveis private utilizadas na rotina padrao apos ajustes de integridade de dados realizados acima
		cA120Forn := cNewCodFor
		cA120Loj  := cNewLojFor
		
	End Transaction
	
	RestArea( aAreaSC7 )
	RestArea( aAreaSC8 )
	RestArea( aAreaSCE )
	RestArea( aAreaSCR )

Return

/*/{Protheus.doc} Static Function GrvSCY
	?
	@type  Static Function
	@author FWNM 
	@since 26/03/2019
	@history Chamado  
	/*/

Static Function GrvSCY()

	Local cQuery   := ""
	Local aAreaAtu := GetArea()

	//  Verifica a ultima versao de alteracao do pedido no SCY e    
	//  disponibiliza a proxima versao disponivel para a alteracao. 
	If Select("MA120GRVQ2") > 0
		MA120GRVQ2->( dbCloseArea() )
	EndIf

	cVerSCY := StrZero(0,Len(SCY->CY_VERSAO))

	cQuery := "SELECT MAX(CY_VERSAO) VERSCY "
	cQuery += "FROM "+RetSqlName("SCY")+" SCY "
	cQuery += "WHERE CY_FILIAL='"+xFilial("SCY")+"' AND "
	cQuery += "CY_NUM ='"+cA120Num+"' AND "
	cQuery += "SCY.D_E_L_E_T_=' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"MA120GRVQ2",.T.,.T.)

	cVerSCY := Substr(VERSCY,1,TamSX3("CY_VERSAO")[1])

	dbCloseArea()
	dbSelectArea("SCY")
		
	cVerSCY := Soma1(cVerSCY,Len(SCY->CY_VERSAO))
      
	//  Antes de atualizar o Pedido de Compras SC7 com a alteracao  
	//  atual, grava o SCY com os dados do SC7 gerando assim um     
	//  historico com as versoes anteriores da alteracoes do PC.    
	nPosRecno := Len(aHeader)
	For nX :=1 to Len(aCols)
		If aCols[nX][nPosRecno] > 0
			dbSelectArea("SC7")
			MsGoto(aCols[nX][nPosRecno])
			RecLock("SCY",.T.)
				dbSelectArea("SCY")
				For nA := 1 to SCY->(FCount())
					nB := SC7->(FieldPos("C7"+SubStr(SCY->(FieldName(nA)),3)))
					If ( nB <> 0 )
						FieldPut(nA,SC7->(FieldGet(nB)))
					EndIf
				Next nA
				SCY->CY_VERSAO := cVerSCY
			SCY->(msUnlock())
		EndIf

		//MaAvalPC("SC7",3,(nX == Len(aCols))) 

	Next nX

	RestArea( aAreaAtu )
	
Return
