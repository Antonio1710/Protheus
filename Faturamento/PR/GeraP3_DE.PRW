#Include "RwMake.ch"

#Define CRLF  Chr( 13 ) + Chr( 10 )

/*/{Protheus.doc} User Function GeraP3_DE
	GERA PODER DE TERCEIROS
	@type  Function
	@author HCConSys
	@since 20/11/2007
	@version 01
	@history Chamado 057846 - William Costa - 06/05/2020 - Retirado toda a referencia ao campo B1_ATIVO ou B1_ATIVO1
	@history chamado 050729 - FWNM          - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function GeraP3_DE()      

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'GERA PODER DE TERCEIROS DE')
	
	If MsgBox("Confirma o Geracao do Acerto Mercadorias de Terceiros em Nosso Poder ?", "Sim ", "YESNO")
		Processa({|| fGeraP3()}, "Encerramento da Rotina P3 ")
	Endif

Return (.T.)

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 25/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fgerap3()

	Local   cFilSB1        := xFilial("SB1")
	Local   cFilSA2        := xFilial("SA2")
	Local   cFilSA1        := xFilial("SA1")
	Local   cFilSF4        := xFilial("SF4")
	Local   cAviso         := ""
	Local   aFiles         := {}
	Local   lCliForBloq    := .F.
	Local   lProBloq       := .F.
	Private cEmpPad        := cEmpAnt
	Private cFilPad        := cFilAnt
	Private lOk            := .T.
	Private cAssunto       := ""
	Private cErro          := ""
	Private lAutoErrNoFile := .T.
	Private totOk          := 0
	Private totNok         := 0
	Private _cTipoCli      := "" 
	Private _cEstado       := ""
	
	//DbUseArea( .T., "DBFCDX", "SB6DE.DBF", "P3", .T., .F. )
	DbUseArea( .T.,, "SB6DE.DTC", "P3", .T., .F. )
	
	DbSelectArea( "P3" )
	PROCREGUA( Reccount() )
	DbGotop( "P3" )
	
	While( !Eof("P3") )
		
		//- Se item ja processado, desconsidera
		if P3->PROC_OK == "S"
			P3->(dbSkip())
			loop
		endif
		
		IF P3->B6_FILIAL <> cFilAnt   // para so processar registros da filial corrente
			P3->(dbSkip())
			loop
		endif
		
		If cFilAnt == "02" .And. ALLTRIM(P3->B6_PRODUTO) == "309368"   //Solicitado por Valeria
			P3->(dbSkip())
			loop
		endif
		
		If cFilAnt == "04" .And. Alltrim(P3->B6_PRODUTO) == "482950"   //Solicitado por Valeria
			P3->(dbSkip())
			loop
		endif	
		
		//------------------------------------------
		// Atualiza variaveis para montar array
		//------------------------------------------
		_CliFor   := P3->B6_TPCF
		_cCodCF	  := P3->B6_CLIFOR
		_cLoja    := P3->B6_LOJA
		_cProduto := P3->B6_PRODUTO
		_cUm      := P3->B6_UM
		_cDocB6   := P3->B6_DOC
		_cSerieB6 := P3->B6_SERIE
		_cLocal   := P3->B6_LOCAL
		_nQtde    := P3->B6_SALDO
		_nValUnit := P3->B6_PRUNIT
		_nValTot  := ( P3->B6_SALDO * P3->B6_PRUNIT )
		_cTES     := "655"
		_cSerNf   := "ZZ "
		_cB6Ident := P3->B6_IDENT
		_cItem	  := "01"
		_cFormul  := " "
		_cEspecie := "NF"
		_dEmissao := dDataBase
		_dDtDigit := dDataBase
		_cCondPag := ""
		_nBaseIcm := 0
		_nValIcm  := 0
		_nValMerc := 0
		_nValBrut := 0
		_cCcontabil := "111510002"
		if cFilAnt == "02"
		   _cITemcc    := "121"
		Else
		   _cITemcc    := "114"
		Endif
		
		dbSelectArea("P3")
		//--------------------------------------------------------
		//-- Verifica se é cliente ou fornecedor
		//--------------------------------------------------------
		If _CliFor == "F"
			
			_cTipoNF := "N"
			DbSelectArea("SA2")
			dbSetOrder(1)
			// se fornecedor bloqueado , desbloqueia para gerar a nf de retorno
			
	
			if dbSeek( xFilial("SA2") + _cCodCF + _cLoja)
				_cTipoCli  := "R"    //SA2->A2_TIPO
				_cEstado   := SA2->A2_EST
				
		
				if sa2->a2_ativo =="N"    // bloqueado
					lCliForBloq := .T.
					sa2->(recLock("SA2",.F.))
					sa2->a2_ativo  := "S"  // Desbloqueia
					sa2->a2_msblql := "2"
					sa2->(msUnlock())
				endif     
		
				
				
			endif
			
		elseif _CliFor == "C"
			
			_cTipoNF := "D"
			DbSelectArea("SA1")
			dbSetOrder(1)
			// se cliente bloqueado , desbloqueia para gerar a nf de retorno
			if DbSeek( xFilial("SA1") + _cCodCF + _cLoja)
				_cTipoCli  := "R"   //SA1->A1_TIPO
				_cEstado   := SA1->A1_EST
				
		
				if sa1->a1_ativo == "N"  // bloqueado
					lCliForBloq := .T.
					sa1->(recLock("SA1",.F.))
					sa1->a1_ativo  := "S"  // Desbloqueia
					sa1->a1_msblql := "2"
					sa1->(msUnlock())
				endif
	
				
			endif
			
		endif
		
		//-----------------------------------------
		// Verifica se produto está bloqueado.
		// Caso afirmativo, desbloqueia para poder
		// efetuar a nota de retorno.
		//-----------------------------------------
		dbSelectArea("SB1")
		dbSetOrder(1)
		if dbSeek(xFilial("SB1")+_cProduto)
			_cCusto     := sb1->b1_cc
			_cGrupoProd := sb1->b1_grupo
			_cTipoProd  := sb1->b1_tipo
			_nPeso      := sb1->b1_peso
			
		
			IF SB1->B1_MSBLQL == "1"

				lProBloq := .T.

				SB1->(recLock("SB1",.F.))

					SB1->B1_MSBLQL := "2"

				SB1->(msUnlock())

			ENDIF
	
			
		endif
		
		
		//--------------------------------
		// Busca nro do item original
		//--------------------------------
		dbSelectArea("SD1")
		dbSetOrder(4)
		if dbSeek(xFilial("SD1")+P3->B6_IDENT)
			_cItemB6 := SD1->D1_ITEM
		else
			/*
			sd1->(dbSetOrder(3))
			if dbSeek(xFilial("SD2")+P3->B6_DOC+P3->B6_SERIE+P3->B6_CLIFOR+P3->B6_LOJA)
			do while xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
			xFilial("SD2")+P3->B6_DOC+P3->B6_SERIE+P3->B6_CLIFOR+P3->B6_LOJA .and. !eof()
			if P3->B6_IDENT == SD2->D2_IDENTB6
			sd2->(recLock("SD2"),.F.)
			sd2->d2_numseq := sd2->d2_identb6
			sd2->(msUnlock())
			_cItemB6 := SD2->D2_ITEM
			endif
			dbSkip()
			enddo
			else
			*/
			lOk := .F.
			cErro += ""+CRLF+CRLF
			cErro += "--------------------------------------------------------------------------------------------" +CRLF
			cErro += "NOTA FISCAL :  " + _cDocB6 +  "  SERIE " + _cSerieB6  +  " CLIE/FORN:  " + _cCodCF +  "  LOJA: " + _cLoja +CRLF
			cErro += "Nao foi encontrado registro da nota no SF1 / SD1 " +CRLF
			cErro += "--------------------------------------------------------------------------------------------" +CRLF+CRLF+CRLF
			_cItemB6 := "xx"
			//endif
		endif
		
		//--------------------------------------------------------------------------
		// Chama funcao para gerar nota retorno
		//--------------------------------------------------------------------------
		fProcNFS() // Poder De Terceiros .. Gera nota de saida retorno
		
		//-----------------------------------------
		// Volta Bloqueio Cliente / Fornecedor
		// caso o mesmo estivesse bloqueado
		//-----------------------------------------
		if lCliForBloq
			
			lCliForBloq := .F.
			
			If _CliFor == "F"
				DbSelectArea("SA2")
				dbSetOrder(1)
				if dbSeek( xFilial("SA2") + _cCodCF + _cLoja)
					sa2->(recLock("SA2",.F.))
					sa2->a2_ativo := "N"  // Bloqueia
					sa2->a2_msblql := "1"  // Bloqueia
					sa2->(msUnlock())
				endif
				
			elseif _CliFor == "C"
				DbSelectArea("SA1")
				dbSetOrder(1)
				if dbSeek( xFilial("SA1") + _cCodCF + _cLoja)
					sa1->(recLock("SA1",.F.))
					sa1->a1_ativo  := "N"  // Bloqueia
					sa1->a1_msblql := "1"  // Bloqueia
					sa1->(msUnlock())
				endif
			endif
		endif
		
		//-----------------------------------------
		// Volta bloqueio do produto
		// caso estivesse bloqueado
		//-----------------------------------------
		if lProBloq
			lProBloq := .F.
			dbSelectArea("SB1")
			dbSetOrder(1)
			IF dbSeek(xFilial("SB1")+_cProduto)

				SB1->(recLock("SB1",.F.))
				
					SB1->B1_MSBLQL := "1"

				SB1->(msUnlock())

			ENDIF
		endif
		
		//----------------------------------------
		//-- Proxima nota para ser retornada
		//----------------------------------------
		dbSelectArea("P3")
		dbSkip()
		incProc()
	enddo
	dbSelectArea("P3")
	dbCloseArea()
	MemoWrit("ERROR_P3_DE_"+cFilAnt+".LOG",cErro)
	if ! lOk
		alert("Ocorrem erros que impediram a geração de uma ou mais NF Retorno Poder 3os."+CRLF+" Verifique as notas com problemas no arquivo ERROR_P3_DE.LOG")
	else
		ApMsgInfo("Processamento de Atualização [ PODER TERCEIROS ] efetuado com sucesso.")
	endif

Return

Static Function fProcNFS()

	Local aErros   := {}
	Local aCab     := {}
	Local aItem    := {}
	Local aPvlNfs  := {}
	Local cItem
	Local cBody    := ""
	Private lMsErroAuto := .f.
	Private lErro  := .F. 
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+_cProduto)
	
	dbSelectArea("SC5")
	
	//-----------------------------*
	//Geracao do pedido de vendas *
	//-----------------------------*
	cPedido := GetSxeNum("SC5","C5_NUM")
	SC5->(dbSetOrder(1))
	While SC5->(dbSeek(xFilial("SC5")+cPedido))
		ConfirmSX8()
		cPedido := GetSxeNum("SC5","C5_NUM")
	End
	AAdd( aItem  , {{"C6_FILIAL" , xFilial("SC6")              ,Nil},;  // 01
	                {"C6_ITEM"   ,"01"                         ,Nil},;  // 02
	                {"C6_PRODUTO",_cProduto                    ,Nil},;  // 03
	                {"C6_DESCRI" ,SB1->B1_DESC                 ,Nil},;  // 04
	                {"C6_UNSVEN" ,_nQtde                       ,Nil},;  // 05
	                {"C6_PRCVEN" ,_nValUnit                    ,Nil},;  // 06
	                {"C6_UM"     ,_cUM                         ,Nil},;  // 08
	                {"C6_QTDVEN" ,_nQtde                       ,Nil},;  // 09
	                {"C6_TES"    ,"655"                        ,Nil},;  // 10
	                {"C6_QTDLIB" ,_nQtde                       ,Nil},;  // 11
	                {"C6_LOCAL"  ,_cLocal 		               ,Nil},;  // 12
	                {"C6_CLI"    ,_cCodCF                      ,Nil},;  // 13
	                {"C6_DESCONT",0                            ,Nil},;  // 14
	                {"C6_VALDESC",0                            ,Nil},;  // 15
	                {"C6_ENTREG" ,dDataBase                    ,Nil},;  // 16
	                {"C6_LOJA"   ,_cLoja                       ,Nil},;  // 17
	                {"C6_NUM"    ,cPedido                      ,Nil},;  // 18
	                {"C6_NFORI"  ,_cDocB6                      ,Nil},;  // 19
	                {"C6_SERIORI",_cSerieB6                    ,Nil},;  // 20
	                {"C6_ITEMORI",_cItemB6                     ,Nil},;  // 21
	                {"C6_IDENTB6",_cB6Ident                    ,Nil},;  // 22
	                {"C6_PRUNIT" ,_nValUnit		               ,Nil}} ) // 23
	                //{"C6_VALOR"  ,NOROUND(_nQtde * _nValUnit,2),Nil},;  // 07
	
	aCab := {{"C5_FILIAL" ,xFilial("SC5")           ,Nil},; // 01
	         {"C5_NUM"    ,cPedido                  ,Nil},; // 02
	         {"C5_TIPO"   ,IF(_CliFor=="F","B","N") ,Nil},; // 03
	         {"C5_CLIENTE",_cCodCF                  ,Nil},; // 04
	         {"C5_LOJAENT",_cLoja                   ,Nil},; // 05
	         {"C5_LOJACLI",_cLoja                   ,Nil},; // 06
	         {"C5_CONDPAG","0"                      ,Nil},; // 07
	         {"C5_TIPLIB" ,"1"                      ,Nil},; // 08
	         {"C5_TIPOCLI",_cTipoCli                ,Nil},; // 09
	         {"C5_EMISSAO",dDataBase                ,Nil},; // 10
	         {"C5_DTENTR" ,dDataBase                ,Nil},; // 11
	         {"C5_MOEDA"  ,1                        ,Nil},; // 12
	         {"C5_LIBEROK","S"                      ,Nil}}  // 13
	
	RegToMemory("SC5")
	M->C5_FILIAL := xFilial("SC5")
	
	RegToMemory("SC6")
	M->C6_FILIAL := xFilial("SC6")
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItem,3)
	
	
	If lMsErroAuto
		lOk   := .F.
		lErro := .T.
		aErros := GetAutoGrLog()
		For nErro := 1 To Len(aErros)
			cErro+= aErros[nErro]+CRLF
		Next nErro
	EndIf
	
	
	//------------------------------*
	//Liberacao do pedido de venda *
	//------------------------------*
	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SE4->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	SB2->(DbSetOrder(1))
	SF4->(DbSetOrder(1))

	//--------------------------------------*
	//Define Variaveis usados pelo MATA440 *
	//--------------------------------------*
	lGerouPv := .T.
	lLiber   := .T.
	lTrans   := .F.
	lCredito := .F.
	lEstoque := .F.
	lAvCred  := .T.
	lAvEst   := .T.
	lLiberOk := .T.
	lItLib   := .T.
	aPvlNfs  := {}
	@lEstoque:= .F. 
	//-----------------------------*
	//Efetua a Liberacao por item *
	//-----------------------------*
	SC5->(DbSeek(xFilial("SC5")+cPedido))
	SC6->(DbSeek(xFilial("SC6")+cPedido))
	
	While !SC6->(Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM  == cPedido
		
		nQtdLib := SC6->C6_QTDVEN
		
		//----------------------------------------------*
		//Posiciona registros para efetuar a liberacao *
		//----------------------------------------------*
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		
		nQtdL2 := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTrans)
		
		SC9->( dbSetOrder(1) )
		IF SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
			
			SC9->(RecLock("SC9",.F.))
			SC9->C9_BLEST  := ""
			SC9->C9_BLCRED := ""
		
		ELSE
			
			SC9->(RecLock("SC9",.T.))
			SC9->C9_BLEST   := ""
			SC9->C9_BLCRED  := ""
			SC9->C9_DTENTR  := DDATABASE
			SC9->C9_FILIAL  := XFILIAL("SC9")
			SC9->C9_PEDIDO  := SC6->C6_NUM
			SC9->C9_ITEM    := SC6->C6_ITEM
			SC9->C9_CLIENTE := SC6->C6_CLI
			SC9->C9_LOJA    := SC6->C6_LOJA
			SC9->C9_PRODUTO := SC6->C6_PRODUTO
			SC9->C9_DATALIB := dDataBase
			SC9->C9_PRCVEN  := SC6->C6_PRCVEN
			SC9->C9_BLEST   := ""
			SC9->C9_BLCRED  := ""
			SC9->C9_LOCAL   := SC6->C6_LOCAL
			SC9->C9_QTDLIB  := SC6->C6_QTDVEN
			
		ENDIF
		
		SC9->(MsUnLock())
		
		SE4->(DbSeek(XFILIAL("SE4")+SC5->C5_CONDPAG) )
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO) )
		SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL) )
		SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES) )
		
		Aadd(aPvlnfs, { SC9->C9_PEDIDO  ,;
		SC9->C9_ITEM    ,;
		SC9->C9_SEQUEN  ,;
		SC9->C9_QTDLIB  ,;
		SC9->C9_PRCVEN  ,;
		SC9->C9_PRODUTO ,;
		SF4->F4_ISS=="S",;
		SC9->(RecNo())  ,;
		SC5->(RecNo())  ,;
		SC6->(RecNo())  ,;
		SE4->(RecNo())  ,;
		SB1->(RecNo())  ,;
		SB2->(RecNo())  ,;
		SF4->(RecNo())  ,;
		SC9->C9_LOCAL   })
		
		SC6->(DbSkip())
	End
	        
	//---------------------------------*
	//Geracao da nota fiscal de saida *
	//---------------------------------*
	If lGerouPv .And. Len(aPvlnfs) > 0
		Pergunte("MT461A",.f.)
		lMostraCtb   := .F.
		lAglutCtb    := .F.
		lCtbOnLine   := .F.
		lCtbCusto    := .F.
		lReajuste    := .F.
		nCalAcrs     := 0
		nArredPrcLis := 0
		lAtuSA7      := .F.
		lECF         := .F.
		cNota := MaPvlNfs(aPvlNfs,_cSerNf,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF)
		If !SF2->(DbSeek(xFilial("SF2")+cNota+_cSerNf))
			lOk   := .F.
			lErro := .T.
			totNok++
			cErro+="Nao foi possivel gerar Nf de remessa ref nota:  " + _cDocB6 +  "  SERIE " + _cSerieB6  +  " CLIE/FORN:  " + _cCodCF +  "  LOJA: " + _cLoja +CRLF
		else
			P3->(recLock("P3",.F.))
			P3->PROC_OK := "S"
			P3->(msUnlock())
			totOk++
		EndIf
	EndIf

Return(lOk)