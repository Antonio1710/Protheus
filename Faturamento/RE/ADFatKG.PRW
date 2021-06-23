#Include "Protheus.CH"
#Include "TopConn.CH"
#Include "Rwmake.ch"

/*/{Protheus.doc} User Function ADFAtKG
	Relatorio - Faturamento mensal em KG 
	@type  Function
	@author Celso Costa
	@since 28/11/2007
	@history Luciano Mafra em 13/06/2014 reestruturação das query´s 
	@history 052541 - Fernando Sigoli em 14/10/2019 - Adicionado novas CFOPS e fitro P.Ve NF que existem carga no Edata
	@history 054801 - Abel Babini em 10/01/2020 - Comentado pergunta de relatório personalizado
	@history 055608 - Everson em 19/02/2020 - Alterações para correção do relatório analítico.
	@history Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE - Alterações para aparecer os dados nas filiais onde não é feito o carregamento pelo Edata e considerar todos os grupos de produtos quando a empresa for diferente da Adoro Varzea e Ceres Varzea.
	@history 10500 - Everson em 08/03/2021. Adicionado o código fiscal 6109 ao bloco interestadual.
	/*/
User Function ADFatKG()  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _cMsg := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _cPerg	:= PADR("RFATKG",10," ")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio - Faturamento mensal em KG ')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunte                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ValidPerg()
	
	If ! Pergunte( _cPerg, .T. )
		Return Nil

	EndIf	
	
	//055608 - Everson em 19/02/2020.
	If MV_PAR04 == 1
		MsAguarde({|| relExcel() },"Aguarde","Gerando relatório analítico...")
		
	Else
		MsAguarde({|| ImpRelFatKG() },"Aguarde","Gerando relatório sintético...")
				
	EndIf	

Return Nil
/*/{Protheus.doc} Static Function ImpRelFatKG
	Relatorio - Faturamento mensal em KG 
	@type  Function
	@author Celso Costa
	@since 28/11/2007
	/*/
Static Function ImpRelFatKG()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local WnRel		:= "ADFATKG"
	Local cbCont	:= 00
	Local Cabec1	:= "FATURAMENTO MENSAL EM KG"
	Local Cabec2	:= ""
	Local Cabec3	:= ""
	Local cString	:= "SD2"
	Local Tamanho	:= "P"
	Local Limite	:= 80
	Local cDesc1	:= "Faturamento mensal em KG"
	Local cDesc2	:= "Ira imprimir os dados do faturamento mensal em KG"
	Local cDesc3	:= "de acordo com a configuracao do usuario."
	Local aOrd		:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aReturn		:= { "Zebrado", 01, "Administracao", 02, 02, 01, "", 01 }
	Private NomeProg	:= "ADFATKG"
	Private nLastKey	:= 00
	Private nlin		:= 80
	Private m_pag		:= 01
	Private Titulo		:= "Faturamento mensal em KG"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Emite relatorio                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WnRel := SetPrint( cString, WnRel, _cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd,, Tamanho )
	
	If nLastKey = 27 
		dbClearFilter()
		Return ( Nil )
	EndIf
	
	SetDefault( aReturn, cString )
	
	If nLastKey = 27
	    dbClearFilter()
	   Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime relatorio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus( {|lEnd| RFatKGImp( @lEnd, Cabec1, Cabec2, Cabec3, Limite, Tamanho, cbCont, WnRel ) }, Titulo )

Return Nil
/*/{Protheus.doc} Static Function RFatKGImp 
	Chamado do relatorio
	@type  Function
	@author Celso Costa
	@since 28/11/2007
	/*/
Static Function RFatKGImp( lEnd, Cabec1, Cabec2, Cabec3, Limite, Tamanho, cbCont, WnRel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _cQuery			:= ""
	Local cbTxt				:= Space( 10 )
	Local _aEstadual		:= { { 00, 00, 00 }, { 00, 00, 00 } }
	Local _aInterestadual	:= { { 00, 00, 00 }, { 00, 00, 00 } }
	Local _aExportacao		:= { { 00, 00, 00 }, { 00, 00, 00 } }
	Local _aSubEstadual		:= { { 00, 00, 00 }, { 00, 00, 00 } }
	Local _aSubInter		:= { { 00, 00, 00 }, { 00, 00, 00 } }

	Local cSubPrd	:= GetMv("MV_SUBPROD")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o layout do Cabecalho                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o layout do Cabecalho                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111
	//000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	//                 +-----------------------------------------------------------+
	//                 |                              99/99/99 a 99/99/99          |
	//                 +-------------------+-------------------+-------------------+
	//                 | Faturamento Bruto |    Devolucoes     |Faturamento Liquido|
	//                 +-------------------+-------------------+-------------------+
	//  Estadual       |                   |                   |                   |      
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+
	//                 |                   |                   |                   |
	//  Interestadual  |                   |                   |                   |
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+
	//                 |                   |                   |                   |
	//  Exportacao     |                   |                   |                   |
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+  
	//                 |                   |                   |                   |
	//  SubProd Estad. |                   |                   |                   |
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+
	//                 |                   |                   |                   |
	//  SubProd Inter. |                   |                   |                   |
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+
	//                 |                   |                   |                   |
	//  Venda          |                   |                   |                   |
	//  CIF            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  FOB            | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ---------------+-------------------+-------------------+-------------------+
	//  Total          | 99.999.999.999,99 |(99.999.999.999,99)| 99.999.999.999,99 |
	//  ===============+===================+===================+===================+
	        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros - Estadual (CIF,FOB)                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//055608 - Everson em 19/02/2020.
	_cQuery := " SELECT FONTE.C5_TPFRETE, SUM( FONTE.D2_QUANT ) AS FAT_BRUTO, SUM( FONTE.D2_QTDEDEV ) DEVOLUCOES, SUM( FONTE.D2_QUANT - FONTE.D2_QTDEDEV ) AS FAT_LIQUIDO "
	_cQuery += " FROM ( "	
	_cQuery += scriptBase(MV_PAR03,cSubPrd,1)
	_cQuery += " ) AS FONTE "	
	_cQuery += " GROUP BY FONTE.C5_TPFRETE "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFATKG - RFatKGImp - 1 _cQuery " + _cQuery )

	//
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )
	QRYTMP->(DbGoTop())
	While ! QRYTMP->(Eof())

		//
		If Alltrim(QRYTMP->C5_TPFRETE) == "C"
			_aEstadual[ 01 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aEstadual[ 01 ][ 02 ] := QRYTMP->DEVOLUCOES         
			_aEstadual[ 01 ][ 03 ] := QRYTMP->FAT_LIQUIDO
	
		Else
			_aEstadual[ 02 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aEstadual[ 02 ][ 02 ] := QRYTMP->DEVOLUCOES
			_aEstadual[ 02 ][ 03 ] := QRYTMP->FAT_LIQUIDO

		EndIf

		QRYTMP->(DbSkip())

	End
	
	//
	QRYTMP->( dbCloseArea() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros - Interestadual (CIF,FOB)                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//055608 - Everson em 19/02/2020.
	_cQuery := " SELECT FONTE.C5_TPFRETE, SUM( FONTE.D2_QUANT ) AS FAT_BRUTO, SUM( FONTE.D2_QTDEDEV ) DEVOLUCOES, SUM( FONTE.D2_QUANT - FONTE.D2_QTDEDEV ) AS FAT_LIQUIDO "
	_cQuery += " FROM ( "	
	_cQuery += scriptBase(MV_PAR03,cSubPrd,2)
	_cQuery += " ) AS FONTE "	
	_cQuery += " GROUP BY FONTE.C5_TPFRETE "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFATKG - RFatKGImp - 2 _cQuery " + _cQuery )

	//
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )
	QRYTMP->(DbGoTop())
	While ! QRYTMP->(Eof())

		//
		If Alltrim(QRYTMP->C5_TPFRETE) == "C"
			_aInterestadual[ 01 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aInterestadual[ 01 ][ 02 ] := QRYTMP->DEVOLUCOES         
			_aInterestadual[ 01 ][ 03 ] := QRYTMP->FAT_LIQUIDO
	
		Else
			_aInterestadual[ 02 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aInterestadual[ 02 ][ 02 ] := QRYTMP->DEVOLUCOES
			_aInterestadual[ 02 ][ 03 ] := QRYTMP->FAT_LIQUIDO

		EndIf

		QRYTMP->(DbSkip())

	End
	
	//
	QRYTMP->( dbCloseArea() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros - Exportacao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//055608 - Everson em 19/02/2020.
	_cQuery := " SELECT FONTE.C5_TPFRETE, SUM( FONTE.D2_QUANT ) AS FAT_BRUTO, SUM( FONTE.D2_QTDEDEV ) DEVOLUCOES, SUM( FONTE.D2_QUANT - FONTE.D2_QTDEDEV ) AS FAT_LIQUIDO "
	_cQuery += " FROM ( "	
	_cQuery += scriptBase(MV_PAR03,cSubPrd,3)
	_cQuery += " ) AS FONTE "	
	_cQuery += " GROUP BY FONTE.C5_TPFRETE "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFATKG - RFatKGImp - 3 _cQuery " + _cQuery )

	//
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )
	QRYTMP->(DbGoTop())
	While ! QRYTMP->(Eof())

		//
		If Alltrim(QRYTMP->C5_TPFRETE) == "C"
			_aExportacao[ 01 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aExportacao[ 01 ][ 02 ] := QRYTMP->DEVOLUCOES         
			_aExportacao[ 01 ][ 03 ] := QRYTMP->FAT_LIQUIDO
	
		Else
			_aExportacao[ 02 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aExportacao[ 02 ][ 02 ] := QRYTMP->DEVOLUCOES
			_aExportacao[ 02 ][ 03 ] := QRYTMP->FAT_LIQUIDO

		EndIf

		QRYTMP->(DbSkip())

	End
	
	//
	QRYTMP->( dbCloseArea() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros - Sub Produto (CIF,FOB) - Estadual       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//055608 - Everson em 19/02/2020.
	_cQuery := " SELECT FONTE.C5_TPFRETE, SUM( FONTE.D2_QUANT ) AS FAT_BRUTO, SUM( FONTE.D2_QTDEDEV ) DEVOLUCOES, SUM( FONTE.D2_QUANT - FONTE.D2_QTDEDEV ) AS FAT_LIQUIDO "
	_cQuery += " FROM ( "	
	_cQuery += scriptBase(MV_PAR03,cSubPrd,4)
	_cQuery += " ) AS FONTE "	
	_cQuery += " GROUP BY FONTE.C5_TPFRETE "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFATKG - RFatKGImp - 4 _cQuery " + _cQuery )

	//
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )
	QRYTMP->(DbGoTop())
	While ! QRYTMP->(Eof())

		//
		If Alltrim(QRYTMP->C5_TPFRETE) == "C"
			_aSubEstadual[ 01 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aSubEstadual[ 01 ][ 02 ] := QRYTMP->DEVOLUCOES         
			_aSubEstadual[ 01 ][ 03 ] := QRYTMP->FAT_LIQUIDO
	
		Else
			_aSubEstadual[ 02 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aSubEstadual[ 02 ][ 02 ] := QRYTMP->DEVOLUCOES
			_aSubEstadual[ 02 ][ 03 ] := QRYTMP->FAT_LIQUIDO

		EndIf

		QRYTMP->(DbSkip())

	End
	
	//
	QRYTMP->( dbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros - Sub Produto (CIF,FOB) - Interestadual  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//055608 - Everson em 19/02/2020.
	_cQuery := " SELECT FONTE.C5_TPFRETE, SUM( FONTE.D2_QUANT ) AS FAT_BRUTO, SUM( FONTE.D2_QTDEDEV ) DEVOLUCOES, SUM( FONTE.D2_QUANT - FONTE.D2_QTDEDEV ) AS FAT_LIQUIDO "
	_cQuery += " FROM ( "	
	_cQuery += scriptBase(MV_PAR03,cSubPrd,5)
	_cQuery += " ) AS FONTE "	
	_cQuery += " GROUP BY FONTE.C5_TPFRETE "

	//
	Conout( DToC(Date()) + " " + Time() + " ADFATKG - RFatKGImp - 5 _cQuery " + _cQuery )

	//
	dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. )
	QRYTMP->(DbGoTop())
	While ! QRYTMP->(Eof())

		//
		If Alltrim(QRYTMP->C5_TPFRETE) == "C"
			_aSubInter[ 01 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aSubInter[ 01 ][ 02 ] := QRYTMP->DEVOLUCOES         
			_aSubInter[ 01 ][ 03 ] := QRYTMP->FAT_LIQUIDO
	
		Else
			_aSubInter[ 02 ][ 01 ] := QRYTMP->FAT_BRUTO
			_aSubInter[ 02 ][ 02 ] := QRYTMP->DEVOLUCOES
			_aSubInter[ 02 ][ 03 ] := QRYTMP->FAT_LIQUIDO

		EndIf

		QRYTMP->(DbSkip())

	End
	
	//
	QRYTMP->( dbCloseArea() )    
	
	If mv_par03 == 1               //Incluido em 14/07/16 por Wesley para atender o chamado 029379
		_cMsg:= "Data de Emissao"  //para indicar no relatorio se foi impresso por data de emissao

	Else                           //ou data de entrega.
		_cMSg:= "Data de Entrega"

	Endif 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime registros                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55
		Cabec( Titulo, "", Cabec2, NomeProg, Tamanho, 18 )
		nLin := 8 //Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, 18 )

	EndIf        
	
	nLin++
	@ nLin, 00 PSay "                 +-----------------------------------------------------------+"
	nLin++
	@ nLin, 00 PSay "                 | " + _cMsg + " de " + DtoC( mv_par01 ) + " a " + DtoC( mv_par02 ) + "                |"
	nLin++
	@ nLin, 00 PSay "                 +-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "                 | Faturamento Bruto |    Devolucoes     |Faturamento Liquido|"
	nLin++
	@ nLin, 00 PSay "                 +-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Estadual       |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aEstadual[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aEstadual[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aEstadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aEstadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aEstadual[ 01, 01 ] + _aEstadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 01, 02 ] + _aEstadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aEstadual[ 01, 03 ] + _aEstadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	nLin++
	@ nLin, 00 PSay "                 |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  Interestadual  |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aInterestadual[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aInterestadual[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                            
	@ nLin, 59 PSay _aInterestadual[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aInterestadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aInterestadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                 	
	@ nLin, 59 PSay _aInterestadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aInterestadual[ 01, 01 ] + _aInterestadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aInterestadual[ 01, 02 ] + _aInterestadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aInterestadual[ 01, 03 ] + _aInterestadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	nLin++
	@ nLin, 00 PSay "                 |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  Exportacao     |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aExportacao[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("                                 	
	@ nLin, 39 PSay _aExportacao[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aExportacao[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aExportacao[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aExportacao[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                 	
	@ nLin, 59 PSay _aExportacao[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aExportacao[ 01, 01 ] + _aExportacao[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aExportacao[ 01, 02 ] + _aExportacao[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aExportacao[ 01, 03 ] + _aExportacao[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	nLin++
	@ nLin, 00 PSay "                 |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay " SubProd Estadual|                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aSubEstadual[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("                                 	
	@ nLin, 39 PSay _aSubEstadual[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aSubEstadual[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aSubEstadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aSubEstadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                 	
	@ nLin, 59 PSay _aSubEstadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"  
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aSubEstadual[ 01, 01 ] + _aSubEstadual[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aSubEstadual[ 01, 02 ] + _aSubEstadual[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aSubEstadual[ 01, 03 ] + _aSubEstadual[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	nLin++
	@ nLin, 00 PSay "                 |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay " SubProd Inter   |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aSubInter[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("                                 	
	@ nLin, 39 PSay _aSubInter[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aSubInter[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aSubInter[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aSubInter[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                 	
	@ nLin, 59 PSay _aSubInter[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aSubInter[ 01, 01 ] + _aSubInter[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aSubInter[ 01, 02 ] + _aSubInter[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aSubInter[ 01, 03 ] + _aSubInter[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	nLin++
	@ nLin, 00 PSay "                 |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  Venda          |                   |                   |                   |"
	nLin++
	@ nLin, 00 PSay "  CIF            |"
	@ nLin, 19 PSay _aEstadual[ 01, 01 ] + _aInterestadual[ 01, 01 ] + _aExportacao[ 01, 01 ] + _aSubEstadual[ 01, 01 ] + _aSubInter[ 01, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 01, 02 ] + _aInterestadual[ 01, 02 ] + _aExportacao[ 01, 02 ] + _aSubEstadual[ 01, 02 ] + _aSubInter[ 01, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aEstadual[ 01, 03 ] + _aInterestadual[ 01, 03 ] + _aExportacao[ 01, 03 ] + _aSubEstadual[ 01, 03 ] + _aSubInter[ 01, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  FOB            |"
	@ nLin, 19 PSay _aEstadual[ 02, 01 ] + _aInterestadual[ 02, 01 ] + _aExportacao[ 02, 01 ] + _aSubEstadual[ 02, 01 ] + _aSubInter[ 02, 01 ]  Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 02, 02 ] + _aInterestadual[ 02, 02 ] + _aExportacao[ 02, 02 ] + _aSubEstadual[ 02, 02 ] + _aSubInter[ 02, 02 ]  Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"                                 	
	@ nLin, 59 PSay _aEstadual[ 02, 03 ] + _aInterestadual[ 02, 03 ] + _aExportacao[ 02, 03 ] + _aSubEstadual[ 02, 03 ] + _aSubInter[ 02, 03 ]  Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ---------------+-------------------+-------------------+-------------------+"
	nLin++
	@ nLin, 00 PSay "  Total          |"
	@ nLin, 19 PSay _aEstadual[ 01, 01 ] + _aEstadual[ 02, 01 ] + _aInterestadual[ 01, 01 ] + _aInterestadual[ 02, 01 ] + _aExportacao[ 01, 01 ] + _aExportacao[ 02, 01 ] + _aSubEstadual[ 01, 01 ] + _aSubEstadual[ 02, 01 ]  + _aSubInter[ 01, 01 ] + _aSubInter[ 02, 01 ] Picture "@E 99,999,999,999.99"
	@ nLin, 37 PSay "|("
	@ nLin, 39 PSay _aEstadual[ 01, 02 ] + _aEstadual[ 02, 02 ] + _aInterestadual[ 01, 02 ] + _aInterestadual[ 02, 02 ] + _aExportacao[ 01, 02 ] + _aExportacao[ 02, 02 ] + _aSubEstadual[ 01, 02 ] + _aSubEstadual[ 02, 02 ]  + _aSubInter[ 01, 02 ] + _aSubInter[ 02, 02 ] Picture "@E 99,999,999,999.99"
	@ nLin, 56 PSay ")|"
	@ nLin, 59 PSay _aEstadual[ 01, 03 ] + _aEstadual[ 02, 03 ] + _aInterestadual[ 01, 03 ] + _aInterestadual[ 02, 03 ] + _aExportacao[ 01, 03 ] + _aExportacao[ 02, 03 ] + _aSubEstadual[ 01, 03 ] + _aSubEstadual[ 02, 03 ]  + _aSubInter[ 01, 03 ] + _aSubInter[ 02, 03 ] Picture "@E 99,999,999,999.99"
	@ nLin, 77 PSay "|"
	nLin++
	@ nLin, 00 PSay "  ===============+===================+===================+===================+"
	
	//
	If nLin != 80
		Roda( cbCont, cbTxt, "M" )

	EndIf
	
	//
	If aReturn[ 05 ] = 01
		Set Printer To
		Commit
		OurSpool( WnRel )
	EndIf
	
	//
	MS_Flush()

Return Nil
/*/{Protheus.doc} ValidPerg
	Cria pergunta.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function ValidPerg()
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                 
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    U_xPutSx1(_cPerg,'01','Data  De                     ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(_cPerg,'02','Data  Ate                    ?','','','mv_ch2','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSX1(_cPerg,"03",'Data Emissao ou Data Entrega ?','','',"mv_ch3","C",01,0,01,"C","","","","","MV_PAR03" ,"Emissao","Emissao","Emissao","","Entrega","Entrega","Entrega","","","","","","","",""," ")
	U_xPutSX1(_cPerg,"04",'Tipo Relatorio               ?','','',"mv_ch4","N",01,0,01,"C","","","","","MV_PAR04" ,"Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico","","","","","","","",""," ")
	
Return(Nil)            
/*/{Protheus.doc} relExcel
	Gera relatório análico em Excel.
	@type  Static Function
	@author user
	@since 19/02/2020
	@version 01
	/*/
Static Function relExcel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oExcel      := FWMSEXCEL():New()
	Private oMsExcel	:= Nil
	Private aAbas		:= {}
	Private aLinhas     := {}

	//
	//055608 - Everson em 19/02/2020.
	Aadd(aAbas,{"ADFAT ESTADUAL","ADFAT ESTADUAL"})
	Aadd(aAbas,{"ADFAT INTERESTADUAL","ADFAT INTERESTADUAL"})
	Aadd(aAbas,{"ADFAT EXPORTAÇÃO","ADFAT EXPORTAÇÃO"})
	Aadd(aAbas,{"ADFAT SUBPRODUTO EST","ADFAT SUBPRODUTO EST"})
	Aadd(aAbas,{"ADFAT SUBPRODUTO INT","ADFAT SUBPRODUTO INT"})
	
	//
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função GERAEXCEL()")   
		    Break
		    
		EndIF
		
		//Gera o cabeçalho.
		//055608 - Everson em 19/02/2020.
		MsAguarde({|| CabecExcel() },"Aguarde","Criando cabeçalho...")  
		          
		Processa({|| GeraExcel()  },"Aguarde","Processando relatório analítico...")

		MsAguarde({|| SalvaXml()  },"Aguarde","Salvando relatório analítico...")
		
		MsAguarde({|| CriaExcel() },"Aguarde","Abrindo arquivo...")
		
		MsgInfo("Arquivo Excel gerado!","Função GERAEXCEL(ADFATKG)")    
	    
	End Sequence

Return Nil
/*/{Protheus.doc} CabecExcel
	Cabeçalho do relatório analítico.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function CabecExcel() 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nAux	:= 1

	//
	//055608 - Everson em 19/02/2020.
	For nAux := 1 To Len(aAbas)

		//
		oExcel:AddworkSheet(aAbas[nAux][1])
		oExcel:AddTable (aAbas[nAux][1],aAbas[nAux][2])
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_DOC "	  ,1,1) // 01 A
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_SERIE   "  ,1,1) // 02 B
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_CLIENTE "  ,1,1) // 03 C
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_LOJA "     ,1,1) // 04 D
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_QUANT "	  ,1,1) // 05 E
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_QTDEDEV "  ,1,1) // 06 F
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"FAT_LIQUIDO " ,1,1) // 07 G
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"C5_ROTEIRO "  ,1,1) // 08 H
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_CF "       ,1,1) // 09 I
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"D2_COD "      ,1,1) // 10 J
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"B1_DESC "     ,1,1) // 11 K
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"A1_COD "      ,1,1) // 12 L
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"A1_LOJA "     ,1,1) // 13 M
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"A1_NOME "     ,1,1) // 14 N
		oExcel:AddColumn(aAbas[nAux][1],aAbas[nAux][2],"C5_TPFRETE "  ,1,1) // 15 O

	Next nAux
	
Return Nil
/*/{Protheus.doc} GeraExcel
	Processa os dados do relatório.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function GeraExcel()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cQuery		:= ""
	Local cSubPrd		:= GetMv("MV_SUBPROD") //055608 - Everson em 19/02/2020.
	Local nAux			:= 1 //055608 - Everson em 19/02/2020.
	
	//
	//055608 - Everson em 19/02/2020.
	For nAux := 1 To Len(aAbas)

		//
		aLinhas := {}
		nLinha  := 0
		cQuery	:= scriptBase(MV_PAR03,cSubPrd,nAux) 

		//
		If Select("TRB") > 0
			TRB->(DbCloseArea())

		EndIf

		//
		TcQuery cQuery New Alias "TRB"
		DbSelectArea("TRB")
		TRB->(DbGoTop())

		//Conta o Total de registros.
		nTotReg := Contar("TRB","!Eof()")
		
		//Atribui a quantidade de registros à régua de processamento.
		ProcRegua(nTotReg)
		TRB->(DbGoTop())
		While ! TRB->(Eof()) 

			//
			incProc(aAbas[nAux][1])

			//
			nLinha  := nLinha + 1                                       
		
			//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			Aadd(aLinhas,{ "", ; // 01 A  
						"", ; // 02 B   
						"", ; // 03 C  
						"", ; // 04 D  
						"", ; // 05 E  
						"", ; // 06 F   
						"", ; // 07 G  
						"", ; // 08 H
						"", ; // 09 I  
						"", ; // 10 J   
						"", ; // 11 K  
						"", ; // 12 L  
						"", ; // 13 M  
						"", ; // 14 N 
						""  ; // 15 O 
							})
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
			
			//Dados do pedido.
			aLinhas[nLinha][01] := TRB->D2_DOC      // 01 A	
			aLinhas[nLinha][02] := TRB->D2_SERIE    // 02 B
			aLinhas[nLinha][03] := TRB->D2_CLIENTE  // 03 C
			aLinhas[nLinha][04] := TRB->D2_LOJA     // 04 D
			aLinhas[nLinha][05] := TRB->D2_QUANT    // 05 E
			aLinhas[nLinha][06] := TRB->D2_QTDEDEV  // 06 F
			aLinhas[nLinha][07] := TRB->FAT_LIQUIDO // 07 G
			aLinhas[nLinha][08] := TRB->C5_ROTEIRO  // 08 H
			aLinhas[nLinha][09] := TRB->D2_CF       // 09 I	
			aLinhas[nLinha][10] := TRB->D2_COD      // 10 J
			aLinhas[nLinha][11] := TRB->B1_DESC     // 11 K
			aLinhas[nLinha][12] := TRB->A1_COD      // 12 L
			aLinhas[nLinha][13] := TRB->A1_LOJA     // 13 M
			aLinhas[nLinha][14] := TRB->A1_NOME     // 14 N
			aLinhas[nLinha][15] := TRB->C5_TPFRETE  // 15 N
			
			TRB->(DBSKIP())    
			
		ENDDO
		
		TRB->(DbCloseArea())    
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		For nExcel := 1 To nLinha
			
			oExcel:AddRow(aAbas[nAux][1],aAbas[nAux][2],{aLinhas[nExcel][01],;  // 01 A  
											aLinhas[nExcel][02],;  // 02 B  
											aLinhas[nExcel][03],;  // 03 C  
											aLinhas[nExcel][04],;  // 04 D  
											aLinhas[nExcel][05],;  // 05 E  
											aLinhas[nExcel][06],;  // 06 F  
											aLinhas[nExcel][07],;  // 07 G  
											aLinhas[nExcel][08],;  // 08 H
											aLinhas[nExcel][09],;  // 09 I  
											aLinhas[nExcel][10],;  // 10 J  
											aLinhas[nExcel][11],;  // 11 K  
											aLinhas[nExcel][12],;  // 12 L  
											aLinhas[nExcel][13],;  // 13 M  
											aLinhas[nExcel][14],;  // 14 N 
											aLinhas[nExcel][15] ;  // 15 O 
																}) 	
																			
		Next nExcel 
		//============================== FINAL IMPRIME LINHA NO EXCEL

   Next nAux
 	
Return .T.                       
/*/{Protheus.doc} SalvaXml
	Salva arquivo Xml.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_ADFATKG.XML")

Return Nil
/*/{Protheus.doc} CriaExcel
	Abre arquivo xml.
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_ADFATKG.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil
/*/{Protheus.doc} scriptBase
	Script Sql base.
	@type  Static Function
	@author Everson
	@since 19/02/2020
	@version 01
	/*/
Static Function scriptBase(nData,cSubPrd,nTpFrt)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local cQuery	:= ""

	//
	cQuery := ""
	cQuery += " SELECT "

		//
		cQuery += " D2_DOC, " 
		cQuery += " D2_SERIE, " 
		cQuery += " D2_CLIENTE, " 
		cQuery += " D2_LOJA, " 
		cQuery += " D2_QUANT, " 
		cQuery += " D2_QTDEDEV, " 
		cQuery += " D2_QUANT - D2_QTDEDEV AS FAT_LIQUIDO, " 
		cQuery += " C5_ROTEIRO, " 
		cQuery += " C5_TPFRETE, "
		cQuery += " D2_CF, " 
		cQuery += " D2_COD, " 
		cQuery += " (SELECT B1_DESC FROM SB1010 SB1 WITH (NOLOCK) WHERE B1_FILIAL = '' AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ <> '*') AS B1_DESC, " 
		cQuery += " A1_COD, " 
		cQuery += " A1_LOJA, " 
		cQuery += " A1_NOME " 
		
		cQuery += " FROM "
		cQuery += " " + RetSqlName("SD2") + " D2 WITH (NOLOCK) " 
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SC5") + " C5  WITH (NOLOCK) ON " 
			cQuery += " D2.D2_FILIAL = C5.C5_FILIAL " 
			cQuery += " AND D2.D2_PEDIDO = C5.C5_NUM " 
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SA1") + " SA1 WITH (NOLOCK) ON " 
			cQuery += " A1_COD = C5_CLIENTE " 
			cQuery += " AND A1_LOJA = C5_LOJACLI " 

		cQuery += " WHERE " 
		cQuery += " C5.C5_FILIAL = '" + FWxFilial("SC5") + "' " 

		//
		If nData == 1
			cQuery += " AND D2.D2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "' "
			
		Else
			cQuery += " AND C5.C5_DTENTR BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "' " 

		EndIf

		//
		If nTpFrt == 1
			cQuery += " AND C5.C5_ROTEIRO BETWEEN '000' AND '999' " 
			cQuery += " AND C5_XTIPO = '1' " 
			cQuery += " AND D2.D2_COD NOT IN (" + cSubPrd + ") " 
			cQuery += " AND D2.D2_EST = 'SP' " 
			// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			IF cEmpAnt == '01' .AND. cFilAnt == '02'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0927' " 
			ENDIF

			IF cEmpAnt == '02' .AND. cFilAnt == '01'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0927' " 
			ENDIF
			// FIM Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			cQuery += " AND ( "
				cQuery += " D2.D2_CF    = '5101' " 
				cQuery += " OR D2.D2_CF = '5102' " 
				cQuery += " OR D2.D2_CF = '5105' " 
				cQuery += " OR D2.D2_CF = '5922' " 
				cQuery += " OR D2.D2_CF = '5118' " 
				cQuery += " OR D2.D2_CF = '5122' " 
				cQuery += " OR D2.D2_CF = '5401' " 
				cQuery += " OR D2.D2_CF = '5557' " 
				cQuery += " OR D2.D2_CF = '5924' " 
				cQuery += " OR D2.D2_CF = '5923' " 
				cQuery += " OR D2.D2_CF = '5910' "
			cQuery += " ) " 

		ElseIf nTpFrt == 2
			cQuery += " AND D2.D2_COD NOT IN (" + cSubPrd + ") " 
			cQuery += " AND D2.D2_EST NOT IN ('SP','EX') " 
			// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			IF cEmpAnt == '01' .AND. cFilAnt == '02'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0899' " 
			ENDIF	

			IF cEmpAnt == '02' .AND. cFilAnt == '01'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0899' " 
			ENDIF	
			// FIM Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			cQuery += " AND ( "
				cQuery += " D2.D2_CF      = '6101' "
				cQuery += " OR D2.D2_CF   = '6105' "  
				cQuery += " OR D2.D2_CF   = '6922' " 
				cQuery += " OR D2.D2_CF   = '5924' " //Chamado: 052541 14/10/2019 - Fernando Sigoli
				cQuery += " OR D2.D2_CF   = '5923' " //Chamado: 052541 14/10/2019 - Fernando Sigoli				
				cQuery += " OR D2.D2_CF   = '6118' "
				cQuery += " OR   D2.D2_CF = '6122' "   
				cQuery += " OR   D2.D2_CF = '6401' "
				cQuery += " OR   D2.D2_CF = '6109' " //Everson - 08/03/2021. Chamado 10500.
			cQuery += " ) " 

		ElseIf nTpFrt == 3
			cQuery += " AND D2.D2_COD NOT IN (" + cSubPrd + ") " 
			cQuery += " AND D2.D2_EST = 'EX' "
			// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			IF cEmpAnt == '01' .AND. cFilAnt == '02'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0899' "
			ENDIF 

			IF cEmpAnt == '02' .AND. cFilAnt == '01'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0110' AND '0899' "
			ENDIF 
			// FIM Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			cQuery += " AND (D2.D2_CF = '7101' ) "

		ElseIf nTpFrt == 4
			cQuery += " AND D2.D2_COD IN (" + cSubPrd + ") "
			cQuery += " AND D2.D2_EST = 'SP' "
			// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			IF cEmpAnt == '01' .AND. cFilAnt == '02'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0911' AND '0914' "  
			ENDIF 

			IF cEmpAnt == '02' .AND. cFilAnt == '01'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0911' AND '0914' "  
			ENDIF 
			// FIM Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			cQuery += " AND ( "
				cQuery += " D2.D2_CF    = '5101' " 
				cQuery += " OR D2.D2_CF = '5105' " 
				cQuery += " OR D2.D2_CF = '5922' " 
				cQuery += " OR D2.D2_CF = '5924' " //Chamado: 052541 14/10/2019 - Fernando Sigoli
				cQuery += " OR D2.D2_CF = '5923' " //Chamado: 052541 14/10/2019 - Fernando Sigoli			
				cQuery += " OR D2.D2_CF = '5118' "
				cQuery += " OR D2.D2_CF = '5122' " 
				cQuery += " OR D2.D2_CF = '5401' "
				cQuery += " OR D2.D2_CF = '5151' "
			cQuery += " ) " 

		ElseIf nTpFrt == 5
			cQuery += " AND D2.D2_COD IN (" + cSubPrd + ") "
			cQuery += " AND D2.D2_EST NOT IN ('SP','EX') "
			// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			IF cEmpAnt == '01' .AND. cFilAnt == '02'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0911' AND '0914' " 
			ENDIF

			IF cEmpAnt == '02' .AND. cFilAnt == '01'
				cQuery += " AND D2.D2_GRUPO BETWEEN '0911' AND '0914' " 
			ENDIF
			// FIM Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
			cQuery += " AND ( "
				cQuery += " D2.D2_CF = '5101'  "
				cQuery += " OR D2.D2_CF = '5105' " 
				cQuery += " OR D2.D2_CF = '5922' " 
				cQuery += " OR D2.D2_CF = '5924' " //Chamado: 052541 14/10/2019 - Fernando Sigoli
				cQuery += " OR D2.D2_CF = '5923' " //Chamado: 052541 14/10/2019 - Fernando Sigoli			
				cQuery += " OR D2.D2_CF = '5118' "
				cQuery += " OR D2.D2_CF = '5122' " 
				cQuery += " OR D2.D2_CF = '5401' "
				cQuery += " OR D2.D2_CF = '5151' "
			cQuery += " ) " 

		EndIf 

		//
		cQuery += " AND D2.D2_TIPO = 'N' " 
		// Inicio Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
		IF cEmpAnt == '01' .AND. cFilAnt == '02'
			cQuery += " AND C5_X_SQED <> '' " 
			cQuery += " AND C5_XINT = '3' " 
		ENDIF

		IF cEmpAnt == '02' .AND. cFilAnt == '01'
			cQuery += " AND C5_X_SQED <> '' " 
			cQuery += " AND C5_XINT = '3' " 
		ENDIF
		// Fim Ticket 9703 - 23/02/2021 - ADRIANO SAVOINE 
		cQuery += " AND C5.D_E_L_E_T_  <> '*' " 
		cQuery += " AND D2.D_E_L_E_T_  <> '*' " 
		cQuery += " AND SA1.D_E_L_E_T_ <> '*' " 

		//
		Conout( DToC(Date()) + " " + Time() + " ADFATKG - scriptBase - nTpFrt - cQuery " + cValToChar(nTpFrt) + " " + cQuery )

Return cQuery
