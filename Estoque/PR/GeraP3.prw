#Include "RwMake.ch"
#Include "Protheus.CH"
#Include "TbiConn.CH"

#Define CRLF  Chr( 13 ) + Chr( 10 )

/*/{Protheus.doc} User Function GERAP3
	GERA PODER PARA TERCEIROS
	@type  Function
	@author HCConSys
	@since 20/11/2007
	@version 01
	@history Chamado 057846 - William Costa - 06/05/2020 - Retirado toda a referencia ao campo B1_ATIVO ou B1_ATIVO1
	@history chamado 050729  - FWNM         - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
/*/
User Function GeraP3() 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera poder de Terceiros ')

	If MsgBox("Confirma o Geracao do P3 para esta filial ?", "Sim ", "YESNO")
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

	Local cFilSB1  := xFilial("SB1")
	Local cFilSA2  := xFilial("SA2")
	Local cFilSA1  := xFilial("SA1")
	Local cFilSF4  := xFilial("SF4")
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
	Private _nNota
	Private totOk          := 0
	Private totNok         := 0
	Private lErro          := .F.

	_nNota := memoRead("NFP3.TXT")
	if empty(_nNota)
		_nNota := 0
	else
		_nNota := val(_nNota)
	endif

	//DbUseArea( .T., "DBFCDX", "SB6EM.DBF", "P3", .T., .F. )
	DbUseArea( .T.,, "SB6EM.DTC", "P3", .T., .F. )

	DbSelectArea( "P3" )
	PROCREGUA( Reccount() )
	DbGotop( "P3" )

	While( !Eof("P3") )
		
		//- Se item ja processado, desconsidera
		if P3->PROC_OK == "S"
			P3->(dbSkip())
			loop
		endif
		
		IF alltrim(P3->B6_FILIAL) == "03" .Or. P3->B6_FILIAL == "04"   // para so processar registros da filial corrente
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
		
		//- Nro seq. da nota de acerto
		IF lErro == .F.
		
			_nNota++
			
		ENDIF	
		
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
		_cTES     := "330"
		_cNFiscal := strZero(_nNota,9,0)
		_cSerNf   := "Z1 "
		_cB6Ident := P3->B6_IDENT
		_cItem	  := "0001"
		_cFormul  := ""
		_cEspecie := "NF"
		_dEmissao := dDataBase
		_dDtDigit := dDataBase
		_cCondPag := "15"
		_nBaseIcm := 0
		_nValIcm  := 0
		_nValMerc := 0
		_nValBrut := 0
		_cCcontabil := '332160009' //'334210001' //'321180002' //"111510002"
		if cFilAnt == "02"
		_cITemcc    := "121"
		Else
		_cITemcc    := "114"
		Endif

		// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
		If AllTrim(cEmpAnt) == "01"
			If AllTrim(cFilAnt) == AllTrim(GetMV("MV_#ITAFIL",,"0B"))
				_cITemcc := AllTrim(GetMV("MV_#ITAFIL",,"0B"))
			EndIf
		EndIf
		//
		
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
				_cTipoCli  := SA2->A2_TIPO
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
				_cTipoCli  := SA1->A1_TIPO
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
			_cCusto     := "9999     "   //sb1->b1_cc
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
			dbSelectArea("SD2")
			dbSetOrder(4)
			if dbSeek(xFilial("SD2")+P3->B6_IDENT)
				_cItemB6 := SD2->D2_ITEM
			else
				sd2->(dbSetOrder(3))
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
					lOk := .F.
					cErro += ""+CRLF+CRLF
					cErro += "--------------------------------------------------------------------------------------------" +CRLF
					cErro += "NOTA FISCAL :  " + _cDocB6 +  "  SERIE " + _cSerieB6  +  " CLIE/FORN:  " + _cCodCF +  "  LOJA: " + _cLoja +CRLF
					cErro += "Nao foi encontrado registro da nota no SF2 / SD2 " +CRLF
					cErro += "--------------------------------------------------------------------------------------------" +CRLF+CRLF+CRLF
					_cItemB6 := "xx"
				endif
			endif
		
		//--------------------------------------------------------------------------
		// Chama funcao para gerar nota retorno
		//--------------------------------------------------------------------------
		fProcNFE()
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

	memoWrit("NFP3.TXT",strZero(_nNota,9,0))
	dbSelectArea("P3")
	dbCloseArea()
	MemoWrit("ERROR_P3_EM"+cFilAnt+".LOG",cErro)
	if ! lOk
		alert("Ocorrem erros que impediram a geração de uma ou mais NF Retorno Poder 3os."+CRLF+" Verifique as notas com problemas no arquivo error_p3_em"+cFilAnt+".LOG")
	else
		ApMsgInfo("Processamento de Atualização [ PODER TERCEIROS ] efetuado com sucesso.")
	endif
	ApMsgInfo("Total de Registros Processados....... : "  + strZero((totOk+totNok),5,0) + CRLF + CRLF +;
	"Total de Notas geradas com sucesso... : "  + strZero(totOk,5,0) + CRLF + ;
	"Total de Notas não geradas........... : "  + strZero(totNok,5,0) )

Return

Static Function fProcNFE()

	Local   aErros      := {}
	Private lMsErroAuto := .F.

	aItem	 := {}

	//----------------------------------------------------------------
	// Atualiza Item da Nota Fiscal Entrada
	//----------------------------------------------------------------
	AAdd(aItem,{{"D1_FILIAL" ,xFilial("SD1"),Nil},;
				{"D1_COD"    ,_cProduto     ,Nil},;
				{"D1_TES"    ,_cTES         ,Nil},;
				{"D1_NFORI"  ,_cDocB6       ,Nil},;
				{"D1_SERIORI",_cSerieB6     ,Nil},;
				{"D1_ITEMORI",_cItemB6      ,Nil},;
				{"D1_DOC"    ,_cNFiscal     ,Nil},;
				{"D1_SERIE"  ,_cSerNf       ,Nil},;
				{"D1_ITEM"   ,_cItem        ,Nil},;
				{"D1_UM"     ,_cUm          ,Nil},;
				{"D1_QUANT"  ,_nQtde        ,Nil},;
				{"D1_VUNIT"  ,_nValUnit     ,Nil},;
				{"D1_TOTAL"  ,_nValTot      ,Nil},;
				{"D1_PICM"   ,0             ,Nil},;
				{"D1_IPI"    ,0             ,Nil},;
				{"D1_FORNECE",_cCodCF       ,Nil},;
				{"D1_LOJA"   ,_cLoja        ,Nil},;
				{"D1_EMISSAO",_dEmissao     ,Nil},;
				{"D1_DTDIGIT",_dDtDigit     ,Nil},;
				{"D1_LOCAL"  ,_cLocal       ,Nil},;
				{"D1_CC"     ,_cCusto       ,Nil},;
				{"D1_ITEMCTA",_cItemcc      ,Nil},;
				{"D1_CONTA"  ,_cCcontabil   ,Nil},;
				{"D1_GRUPO"  ,_cGrupoProd   ,Nil},;
				{"D1_TP"     ,_cTipoProd    ,Nil},;
				{"D1_FORMUL" ,_cFormul      ,Nil},;
				{"D1_TIPO"   ,_cTipoNF      ,Nil},;
				{"D1_PESO"   ,_nPeso        ,Nil},;
				{"D1_DESC"   ,0             ,Nil},;
				{"D1_IDENTB6",_cB6Ident     ,Nil},;
				{"D1_VALDESC",0             ,Nil}})
				
	//----------------------------------------------------------------
	// Atualiza Cabecalho da Nota Fiscal Entrada
	//----------------------------------------------------------------
	aCab := {{"F1_FILIAL" , xFilial("SF1") ,NIL},;
	{"F1_TIPO"   , _cTipoNF  ,NIL},;
	{"F1_FORMUL" , _cFormul  ,NIL},;
	{"F1_DOC"    , _cNFiscal ,NIL},;
	{"F1_SERIE"  , _cSerNf   ,NIL},;
	{"F1_EMISSAO", _dEmissao ,NIL},;
	{"F1_DTDIGIT", _dDtDigit ,NIL},;
	{"F1_FORNECE", _cCodCF   ,NIL},;
	{"F1_LOJA"   , _cLoja    ,NIL},;
	{"F1_EST"    , _cEstado  ,Nil},;
	{"F1_COND"   , _cCondPag ,NIL},;
	{"F1_ESPECIE", _cEspecie ,NIL},;
	{"F1_BASEICM", 0         ,NIL},;
	{"F1_VALICM" , 0         ,NIL},;
	{"F1_VALMERC", _nValTot  ,NIL},;
	{"F1_VALBRUT", _nValTot  ,NIL}}

	//-----------------------------------------------------------
	// Executa MsExecAuto para gerar a nota fiscal de retorno
	//-----------------------------------------------------------
	lMsErroAuto := .F.
	//MSExecAuto({|x,y,z| Mata103(x,y,z) }, aCab, aItem, 3)
	MsExecAuto({|x,y| MATA103(x,y)},aCab,aItem,3)// Inclusao
	//MostraErro()
	If lMsErroAuto
		//MostraErro() 
		lErro  := .T.
		aErros := GetAutoGrLog()
	ELSE

		lErro := .F.	
		
	endif

	//- Verifica se gerou a nota, grava flag de ok
	dbSelectArea("SF1")
	dbSetOrder(1)
	if dbSeek( xFilial("SF1") + _cNFiscal + _cSerNf + _cCodCF + _cLoja )
		P3->(recLock("P3",.F.))
		P3->PROC_OK := "S"
		P3->(msUnlock())
		totOk++
	else
		lOk := .F.
		cErro += ""+CRLF+CRLF
		cErro += "--------------------------------------------------------------------------------------------" +CRLF
		cErro += "NOTA FISCAL :  " + _cDocB6 +  "  SERIE " + "Z1"  +  " CLIE/FORN:  " + _cCodCF +  "  LOJA: " + _cLoja +CRLF
		cErro += "--------------------------------------------------------------------------------------------" +CRLF+CRLF+CRLF
		For nErro := 1 To Len(aErros)
			cErro+= aErros[nErro]+CRLF
		Next nErro
		cErro += ""+CRLF+CRLF
		totNok++
	EndIf

Return
