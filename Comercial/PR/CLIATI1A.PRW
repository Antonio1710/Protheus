#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function Cliati1a
	Resumo de Clientes Ativos 
	@type  Function
	@author Rogerio Eduardo Nutti
	@since 07/06/2002
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 050729 - FWNM - 24/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE	
/*/
User Function Cliati1a()  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Resumo de Clientes Ativos')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Public titulo  :="RELATORIOS DE CLIENTES ATIVOS"
	Public cDesc1  :="Relatorios de Clientes Ativos"
	Public cDesc2  :=""
	Public cDesc3  :=""
	Public cbCont  :=""
	Public cabec1  :=""
	Public cabec2  :=""
	Public cString :="SZ7"
	Public wnrel   :="CLIATI1A"
	Public cPerg   :="CLIAT1"
	Public aReturn := { "LandScap", 1,"Administracao", 1, 2, 1, "",0 }
	Private aOrd    := {}                                        
	Private _cSeg1 := ''
	Private _cSeg2 := ''
	Public nomeprog:="CLIATI1A"
	Public nLastKey:=0
	Public Tamanho :="G"
	Public li      :=50
	Public limite  :=220
	Public lRodape :=.F.
	Public lEnd         := .F.
	Public lAbortPrint  := .F.
	Public CbTxt        := ""
	Public  nTipo       := 15
	Public  nLin        := 80
	//Private cbtxt      := Space(10)
	Public  cbcont      := 00
	Public  CONTFL      := 01
	Public  m_pag       := 01
	PUBLIC _cLoteCli    := Space(10)
	PUBLIC _cTesValid   := Space(1)
	PUBLIC _cPrdValid   := Space(1)
	PUBLIC _cPrcPrec    := Space(1)
	Private _nSegVLRFAT   := 0
	Private _nRegTVLRFAT  := 0
	Private _nVendTVLRFAT := 0
	Private _nToTTVLRFAT  := 0
	Private _nPERCTOT     := 0
	Private _cContrSeq  := 'MV_CLIATI '
	Private imprime        := .T.
	Private aOrd := {}


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                       ³
	//³ Grupo no SX1010 - CLIAT1                                   ³
	//³ CLIAT1   ¦ mv_par01       ¦ Data Inicial                   ³
	//³ CLIAT1   ¦ mv_par02       ¦ Data Final                     ³
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
	//³ CLIAT1   ¦ mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par08       ¦ Da Divisao  ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par09       ¦ Ate Divisao ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par12       ¦ Do Vendedor  F2_VEND1          ³
	//³ CLIAT1   ¦ mv_par13       ¦ Ate Vendedor F2_VEND1          ³
	//³ CLIAT1   ¦ mv_par14       ¦ Reprocessa                     ³
	//³ CLIAT1   ¦ mv_par15       ¦ Imprime 1-Qtde  			   ³
	//³ CLIAT1   ¦ mv_par16       ¦ 2-Precos Med  				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PutSX1(cPerg,"20","So clientes Ativos ?","So Clientes Ativos ?"	,"So clientes Ativos ?","mv_chk","N",01,0,01,"C","","","","","mv_par20" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")

	IF 	pergunte(cPerg,.T.)=.F.
		RETURN
	ENDIF

	//wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.)
	wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif


	PUBLIC _dDATAINI := mv_par01
	PUBLIC _dDATAFIM := mv_par02
	PUBLIC _cESCFIL  := MV_PAR19
	// Incrementa para cada Relatorio Gerado
	dbSelectArea("SX6")
	DbSetorder(1)
	If dbSeek("  "+_cContrSeq)
		RecLock("SX6",.F.)  // com .f. sem append blank
		///	_nControle := SUBSTR(X6_CONTEUD,1,12)    With STR(VAL(X6_CONTEUD)+1,11) + SUBSTR(X6_CONTEUD,12,200)              // Lote em processamento
		_nControle := strzero(val(SUBSTR(X6_CONTEUD,1,10))+1,10)
		_cTesValid := SUBSTR(X6_CONTEUD,11,200)
		_cPrdValid := SUBSTR(X6_CONTSPA,1,100)
		_cPrcPrec  := SUBSTR(X6_CONTENG,1,1)
		Replace  X6_CONTEUD   With _nControle + _cTesValid         // Lote em processamento
		_cLoteCli  := _nControle
		MsUnlock()
	Endif

	// _cLoteCli := '0000001583'


	// So processo se o parametro de impressao estiver ativo para alguns dos relatorios
	If (mv_par03 + mv_par04 + mv_par05) > 0
		
		// Este processo esta por fora no scledule
		If mv_par14 = 1
			//ExecBlock("clia_prc",.F.,.F.)  /// ,mv_par01, mv_par02)
		Endif
		
		//If mv_par20 = 1
		// Proximo passo e permitir a reimpressao a partir uma consulta....
		ExecBlock("clia_Trb",.F.,.F.) /// ,mv_par01, mv_par02)
		
		// mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
		// mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
		// mv_par08       ¦ Da Divisao  ZP_AGRUPO          ³
		// mv_par09       ¦ Ate Divisao ZP_AGRUPO          ³
		// mv_par10       ¦ Da Regiao  A3_REGIAO           ³
		// mv_par11       ¦ Ate Regiao A3_REGIAO           ³
		// mv_par12       ¦ Do Vendedor  F2_VEND1          ³
		// mv_par13       ¦ Ate Vendedor F2_VEND1          ³
		
		//Endif
	Endif

	//
	//  _cCtrImpre := .f.
	// If mv_par03 = 1   //  ¦ 1 - Resumo - Todos Segmentos
	//  	ExecBlock("cliaImp1",.F.,.F.)
	// 	_cCtrImpre := .t.
	//  Endif
	// If mv_par04 = 1   //  ¦ 2 - Analit Por Regiao
	//  	ExecBlock("cliaImp2",.F.,.F.)
	// 	_cCtrImpre := .t.
	//  Endif
	// If mv_par05 = 1    //  ¦ 3 - Analit Por Vendedor
	//  	ExecBlock("cliaImp3",.F.,.F.)
	// 	_cCtrImpre := .t.
	//  Endif



	RptStatus({||RunReport(Cabec1,Cabec2,Titulo,nLin)},Titulo)



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga arquivos de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If mv_par03 = 1   //  ¦ 1 - Resumo - Todos Segmentos
		_cFileTRB = 'REL1'
		dbSelectArea("REL1")
		dbCloseArea()
		//FErase( _cFileTRB+".DBF")
		FErase( _cFileTRB+GetDBExtension()) // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
		FErase( _cFileTRB+OrdBagExt())
	Endif

	If mv_par04 = 1   //  ¦ 1 - Resumo - Todos Segmentos
		_cFileTRB = 'REL2'
		dbSelectArea("REL2")
		dbCloseArea()
		FErase( _cFileTRB+GetDBExtension())
		FErase( _cFileTRB+OrdBagExt())
	Endif

	If mv_par05 = 1   //  ¦ 1 - Resumo - Todos Segmentos
		_cFileTRB = 'REL3'
		dbSelectArea("REL3")
		dbCloseArea()
		FErase( _cFileTRB+GetDBExtension())
		FErase( _cFileTRB+OrdBagExt())
	Endif

Return

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
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET DEVICE TO SCREEN


	If mv_par03 = 1   //  ¦ 1 - Resumo - Todos Segmentos
		Cliaimp1()
	Endif
	If mv_par04 = 1   //  ¦ 2 - Analit Por Regiao
		cliaImp2()
	Endif
	If mv_par05 = 1    //  ¦ 3 - Analit Por Vendedor
		cliaImp3()
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If aReturn[5]==1



	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
	//Endif
	MS_FLUSH()

Return

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
Static Function Cliaimp1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir RELatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Clientes Ativos por Vendedor (Regiao)"
	Local cPict          := ""
	Local titulo         := "Clientes Ativos por Vendedor (Regiao)"
	Local nLin           := 64
	Local Cabec1         := "Clientes Ativos por Vendedor (Regiao)"
	Local Cabec2         := "Clientes Ativos por Vendedor (Regiao)"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo TEMPORARIO (Para Impressao)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_aCampos := {}
	Aadd( _aCampos, {"_SEQRELA","C",27,0} )  // Sequencia do Relatorio
	Aadd( _aCampos, {"_DATAINI","D",27,0} )  //    Data Inicial
	Aadd( _aCampos, {"_DATAFIM","D",27,0} )  //    Data Final
	Aadd( _aCampos, {"_SEGMERC","C",03,0} )  // Segmento de Mercado
	Aadd( _aCampos, {"_SEGDESC","C",15,0} )  // Descricao Segmento de Mercado
	Aadd( _aCampos, {"_AGRUPO" ,"C",01,0} )  // Divisao do Segmento
	Aadd( _aCampos, {"_REGIAO" ,"C",06,0} )  // Regiao
	Aadd( _aCampos, {"_REGDESC","C",25,0} )  // Descricao da Regiao
	Aadd( _aCampos, {"_VENDED" ,"C",06,0} )  // Vendedor
	Aadd( _aCampos, {"_VENDESC","C",25,0} )  // Vendedor
	Aadd( _aCampos, {"_REDE"   ,"C",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_NUMREDE","N",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_CLIENTE","C",06,0} )  // Quebra - Cliente
	Aadd( _aCampos, {"_LOJA"   ,"C",02,0} )  // Quebra - Loja
	Aadd( _aCampos, {"_CLIDESC","C",35,0} )  // Quebra - Cliente
	Aadd( _aCampos, {"_NUMREDES" ,"N",05,0} )  // Numero de Redes
	Aadd( _aCampos, {"_CT"     ,"N",04,0} )  // Clientes Total
	Aadd( _aCampos, {"_INAT"   ,"N",04,0} )  // Clientes Inativos
	Aadd( _aCampos, {"_FMA0"   ,"N",04,0} )  // Frequencia > 0
	Aadd( _aCampos, {"_F0"     ,"N",04,0} )  // Frequencia = 0
	Aadd( _aCampos, {"_F1"     ,"N",04,0} )  // Frequencia = 1
	Aadd( _aCampos, {"_FMA1"   ,"N",04,0} )  // Frequencia > 1
	Aadd( _aCampos, {"_IPT"    ,"N",07,4} )  // Indices IPT
	Aadd( _aCampos, {"_IPG"    ,"N",07,4} )  // Indices IPG
	Aadd( _aCampos, {"_IPS"    ,"N",07,4} )  // Indices IPS
	Aadd( _aCampos, {"_VALORPED" ,"N",14,2} )  // PEDIDO - Valor
	Aadd( _aCampos, {"_PESOPED" ,"N",09,0} )  // PEDIDO - Peso
	Aadd( _aCampos, {"_FREQUE" ,"N",06,1} )  // Frequencia
	Aadd( _aCampos, {"_VALORFAT" ,"N",14,2} )  // Faturamento
	Aadd( _aCampos, {"_PRAZOMED" ,"N",07,2} )  // Prazo Medio
	//Aadd( _aCampos, {"_PRAZOMED" ,"N",07,2} )  // Prazo Medio
	Aadd( _aCampos, {"_PESOTOT" ,"N",09,0} )  // Peso Total
	Aadd( _aCampos, {"_PERCFAT" ,"N",09,4} )  // Peso Total
	Aadd( _aCampos, {"_GRUPOPROD"  ,"C",04,0} )  // Grupo Produto
	Aadd( _aCampos, {"_DESCGRUPO","C",04,0} )  // Descricao Grupo Produto
	Aadd( _aCampos, {"_TOTGRUP1" ,"N",14,0} ) // Total Grupo um - Grupo do 1o. parametro
	Aadd( _aCampos, {"_TOTGRUP2" ,"N",14,0} ) // Total Grupo dois - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO01" ,"N",14,0} ) // Qtd Faturada - Grupo do 1o. parametro
	Aadd( _aCampos, {"_GRUPO02" ,"N",14,0} ) // Qtd Faturada - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO03" ,"N",14,0} ) // Qtd Faturada - Grupo do 3o. parametro
	Aadd( _aCampos, {"_GRUPO04" ,"N",14,0} ) // Qtd Faturada - Grupo do 4o. parametro
	Aadd( _aCampos, {"_GRUPO05" ,"N",14,0} ) // Qtd Faturada - Grupo do 5o. parametro
	Aadd( _aCampos, {"_GRUPO06" ,"N",14,0} ) // Qtd Faturada - Grupo do 6o. parametro
	Aadd( _aCampos, {"_GRUPO07" ,"N",14,0} ) // Qtd Faturada - Grupo do 7o. parametro
	Aadd( _aCampos, {"_GRUPO08" ,"N",14,0} ) // Qtd Faturada - Grupo do 8o. parametro
	Aadd( _aCampos, {"_GRUPO09" ,"N",14,0} ) // Qtd Faturada - Grupo do 9o. parametro
	Aadd( _aCampos, {"_GRUPO10" ,"N",14,0} ) // Qtd Faturada - Grupo do 10o. parametro
	Aadd( _aCampos, {"_GRUPO11" ,"N",14,0} ) // Qtd Faturada - Grupo do 11o. parametro
	Aadd( _aCampos, {"_GRUPO12" ,"N",14,0} ) // Qtd Faturada - Grupo do 12o. parametro
	Aadd( _aCampos, {"_GRUPO13" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO14" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO15" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_PRECO01" ,"N",12,4} ) // Preco Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_PRECO02" ,"N",12,4} ) // Preco Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_PRECO03" ,"N",12,4} ) // Preco Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_PRECO04" ,"N",12,4} ) // Preco Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_PRECO05" ,"N",12,4} ) // Preco Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_PRECO06" ,"N",12,4} ) // Preco Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_PRECO07" ,"N",12,4} ) // Preco Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_PRECO08" ,"N",12,4} ) // Preco Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_PRECO09" ,"N",12,4} ) // Preco Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_PRECO10" ,"N",12,4} ) // Preco Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_PRECO11" ,"N",12,4} ) // Preco Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_PRECO12" ,"N",12,4} ) // Preco Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_PRECO13" ,"N",12,4} ) // Preco Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_PRECO14" ,"N",12,4} ) // Preco Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_PRECO15" ,"N",12,4} ) // Preco Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_PRECO16" ,"N",12,4} ) // Preco Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_PRECO17" ,"N",12,4} ) // Preco Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_PRECO18" ,"N",12,4} ) // Preco Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_PRECO19" ,"N",12,4} ) // Preco Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_PRECO20" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPO01" ,"N",14,4} ) // VLRPo Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_VLRPO02" ,"N",14,4} ) // VLRPo Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_VLRPO03" ,"N",14,4} ) // VLRPo Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_VLRPO04" ,"N",14,4} ) // VLRPo Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_VLRPO05" ,"N",14,4} ) // VLRPo Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_VLRPO06" ,"N",14,4} ) // VLRPo Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_VLRPO07" ,"N",14,4} ) // VLRPo Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_VLRPO08" ,"N",14,4} ) // VLRPo Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_VLRPO09" ,"N",14,4} ) // VLRPo Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_VLRPO10" ,"N",14,4} ) // VLRPo Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_VLRPO11" ,"N",14,4} ) // VLRPo Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_VLRPO12" ,"N",14,4} ) // VLRPo Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_VLRPO13" ,"N",14,4} ) // VLRPo Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_VLRPO14" ,"N",14,4} ) // VLRPo Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_VLRPO15" ,"N",14,4} ) // VLRPo Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_VLRPO16" ,"N",14,4} ) // VLRPo Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_VLRPO17" ,"N",14,4} ) // VLRPo Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_VLRPO18" ,"N",14,4} ) // VLRPo Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_VLRPO19" ,"N",14,4} ) // VLRPo Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_VLRPO20" ,"N",14,4} ) // VLRPo Medio  - Grupo do 20o. parametro

	Aadd( _aCampos, {"_QTDPO01" ,"N",14,4} ) // VLRPo Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_QTDPO02" ,"N",14,4} ) // VLRPo Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_QTDPO03" ,"N",14,4} ) // VLRPo Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_QTDPO04" ,"N",14,4} ) // VLRPo Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_QTDPO05" ,"N",14,4} ) // VLRPo Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_QTDPO06" ,"N",14,4} ) // VLRPo Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_QTDPO07" ,"N",14,4} ) // VLRPo Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_QTDPO08" ,"N",14,4} ) // VLRPo Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_QTDPO09" ,"N",14,4} ) // VLRPo Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_QTDPO10" ,"N",14,4} ) // VLRPo Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_QTDPO11" ,"N",14,4} ) // VLRPo Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_QTDPO12" ,"N",14,4} ) // VLRPo Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_QTDPO13" ,"N",14,4} ) // VLRPo Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_QTDPO14" ,"N",14,4} ) // VLRPo Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_QTDPO15" ,"N",14,4} ) // VLRPo Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_QTDPO16" ,"N",14,4} ) // VLRPo Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_QTDPO17" ,"N",14,4} ) // VLRPo Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_QTDPO18" ,"N",14,4} ) // VLRPo Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_QTDPO19" ,"N",14,4} ) // VLRPo Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_QTDPO20" ,"N",14,4} ) // VLRPo Medio  - Grupo do 20o. parametro



	_cIndex   := "_SEGMERC + _REGIAO +_SEQRELA"
	_cFileREL := CriaTrab(_aCampos,.T.)
	dbUseArea(.T.,,_cFileREL,"REL1",.T.,.F.)
	IndRegua( "REL1", _cFileREL, _cIndex,,,"Criando Indice ..." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo Temporario  e Grava o de Impressao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
	//³ CLIAT1   ¦ mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par08       ¦ Da Divisao  ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par09       ¦ Ate Divisao ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par12       ¦ Do Vendedor  F2_VEND1          ³
	//³ CLIAT1   ¦ mv_par13       ¦ Ate Vendedor F2_VEND1          ³
	//
	Private _cSegTAnt  := space(3)
	Private _nCT       := 0
	Private _nFMA0     := 0
	Private _nF0       := 0
	Private _nF1       := 0
	Private _nFMA1     := 0
	Private _nIPT      := 0
	Private _nIPG      := 0
	Private _nIPS      := 0
	Private _nVLRFAT   := 0
	Private _nPESO     := 0
	Private _nTINAT    := 0
	Private _nTCT      := 0
	Private _nTFMA0    := 0
	Private _nTF0      := 0
	Private _nTF1      := 0
	Private _nTFMA1    := 0
	Private _nTIPT     := 0
	Private _nTIPG     := 0
	Private _nTIPS        := 0
	Private _nVLRFAT      := 0
	Private _nPESO        := 0
	Private _nFREQUE      := 0
	Private _nTFREQUE     := 0
	Private _PrzMed       := 0
	Private _TPrzMed      := 0
	Private _nVLRFAT      := 0
	Private _nTVLRFAT     := 0
	Private _nPERCFAT     := 0
	Private _nPESO        := 0
	Private _nTOTGRUP1    := 0
	Private _nTOTGRUP2    := 0
	Private _nTTOTGRUP1   := 0
	Private _nTTOTGRUP2   := 0
	Private _nTGRUP01     := 0
	Private _nTGRUP02     := 0
	Private _nTGRUP03     := 0
	Private _nTGRUP04     := 0
	Private _nTGRUP05     := 0
	Private _nTGRUP06     := 0
	Private _nTGRUP07     := 0
	Private _nTGRUP08     := 0
	Private _nTGRUP09     := 0
	Private _nTGRUP10     := 0
	Private _nTOTGRUP1    := 0
	Private _nTOTGRUP2    := 0
	Private _nGRUP01      := 0
	Private _nGRUP02      := 0
	Private _nGRUP03      := 0
	Private _nGRUP04      := 0
	Private _nGRUP05      := 0
	Private _nGRUP06      := 0
	Private _nGRUP07      := 0
	Private _nGRUP08      := 0
	Private _nGRUP09      := 0
	Private _nGRUP10      := 0
	Private _nTGRUP11     := 0
	Private _nPRC01       := 0
	Private _nPRC02       := 0
	Private _nPRC03       := 0
	Private _nPRC04       := 0
	Private _nPRC05       := 0
	Private _nPRC06       := 0
	Private _nPRC07       := 0
	Private _nPRC08       := 0
	Private _nPRC09       := 0
	Private _nPRC10       := 0
	Private _nPRC11       := 0
	Private _nPRC12       := 0
	Private _nPRC13       := 0
	Private _nPRC14       := 0
	Private _nPRC15       := 0
	Private _TotFatInd    := 0
	Private _TotPesInd    := 0
	Private _nSegVLRFAT   := 0
	Private _nRegTVLRFAT  := 0
	Private _nVendTVLRFAT := 0
	Private _nToTTVLRFAT  := 0
	Private _nPERCTOT     := 0
	Private _nTIPS		  := 0
	Private _nTIPG		  := 0
	Private _nTIPT        := 0
	Private _nTPERCFAT    := 0
	Private _nTPESO       := 0
	Private _nTNUMREDES   := 0
	Private _nSomGrp001 := 0
	Private _nSomGrp002 := 0
	Private _nSomGrp003 := 0
	Private _nSomGrp004 := 0
	Private _nSomGrp005 := 0
	Private _nSomGrp006 := 0
	Private _nSomGrp007 := 0
	Private _nSomGrp008 := 0
	Private _nSomGrp009 := 0
	Private _nSomGrp010 := 0
	Private _nSomGrp011 := 0
	Private _nSomGrp012 := 0
	Private _nSomGrp013 := 0
	Private _nSomGrp014 := 0
	Private _nSomGrp015 := 0
	Private _nSomGrp016 := 0
	Private _nSomGrp017 := 0
	Private _nSomGrp018 := 0
	Private _nSomGrp019 := 0
	Private _nSomGrp020 := 0
	Private _nTPRC01 := 0
	Private _nTPRC02 := 0
	Private _nTPRC03 := 0
	Private _nTPRC04 := 0
	Private _nTPRC05 := 0
	Private _nTPRC06 := 0
	Private _nTPRC07 := 0
	Private _nTPRC08 := 0
	Private _nTPRC09 := 0
	Private _nTPRC10 := 0
	Private _nTPRC11 := 0
	Private _nTPRC12 := 0
	Private _nTPRC13 := 0
	Private _nTPRC14 := 0
	Private _nTPRC15 := 0
	Private _nTotGrp001 := 0
	Private _nTotGrp002 := 0
	Private _nTotGrp003 := 0
	Private _nTotGrp004 := 0
	Private _nTotGrp005 := 0
	Private _nTotGrp006 := 0
	Private _nTotGrp007 := 0
	Private _nTotGrp008 := 0
	Private _nTotGrp009 := 0
	Private _nTotGrp010 := 0
	Private _nTotGrp011 := 0
	Private _nTotGrp012 := 0
	Private _nTotGrp013 := 0
	Private _nTotGrp014 := 0
	Private _nTotGrp015 := 0


	dbSelectArea("SZ7")
	dbSetOrder(2)            // _cIndex   := "Z7_FILIAL+Z7_LOTE+ DTOS(Z7_DATINI) + DTOS(Z7_DATFIM)"

	Processa({|| RunImp2SZ71()},"1-Calculando Total de Faturamento para Clientes Ativos ...")

Return

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
Static Function RunImp2SZ71()

	// ProcRegua(RecCount())
	// dbGoTop()
	// DbSeek(xFilial("SZ7")+_cLoteCli + DTOS(_dDataIni) + DTOS(_dDatafim))
	// Do While !Eof() .AND. Z7_LOTE == _cLoteCli .AND. SZ7->Z7_DATINI == _dDataIni .and. SZ7->Z7_DATFIM == _dDatafim
	// 	IncProc('Totalizando Faturamento do Periodo')
	// 	If SZ7->Z7_SEGMERC >= mv_par06  .AND.  SZ7->Z7_SEGMERC <= mv_par07
	// 		_nSegVLRFAT :=_nSegVLRFAT + SZ7->Z7_VLRFAT				// IF  Condicao da opcao do relatorio
	// 		If SZ7->Z7_REGIAO  >= mv_par10  .AND.  SZ7->Z7_REGIAO <= mv_par11
	// 			_nRegTVLRFAT := _nRegTVLRFAT + SZ7->Z7_VLRFAT			// IF  Condicao da opcao do relatorio
	// 			If SZ7->Z7_VENDED  >=  mv_par12  .AND.  SZ7->Z7_VENDED <= mv_par13
	// 				_nVendTVLRFAT := _nVendTVLRFAT + SZ7->Z7_VLRFAT	// IF  Condicao da opcao do relatorio
	// 			Endif
	// 		Endif
	// 	Endif
	// 	_nToTTVLRFAT := _nToTTVLRFAT +SZ7->Z7_VLRFAT  // IF  Condicao da opcao do relatorio
	// 	dbSelectArea("SZ7")
	// 	dbSkip()
	// Enddo
	// ***********
	// Total Vendedor
	cQuery :="SELECT SUM (Z7_VLRFAT) AS _nVendVLR "
	cQuery +="FROM  "+RetSqlName("SZ7")+ "  "
	cQuery +="WHERE "
	cQuery +=" (Z7_DATINI >= '"+DTOS(_dDataIni)+"' ) AND "
	cQuery +=" (Z7_DATFIM <= '"+DTOS(_dDatafim)+"' ) AND "
	cQuery +=" (Z7_LOTE='"+_cLoteCli+"')    AND "
	cQuery +=" (Z7_SEGMERC BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' ) AND "
	cQuery +=" (Z7_REGIAO  BETWEEN '"+mv_par10+"' AND '"+mv_par11+"' ) AND "
	cQuery +=" (Z7_VENDED  BETWEEN '"+mv_par12+"' AND '"+mv_par13+"' ) "
	TCQUERY cQuery new alias "VEND"
	dbSelectArea ("VEND")
	DBGOTOP()
	_nVendTVLRFAT := _nVendVLR
	dbCloseArea("VEND")
	// Total Regiao
	cQuery :="SELECT SUM (Z7_VLRFAT) AS _nRegVLR "
	cQuery +="FROM  "+RetSqlName("SZ7")+ "  "
	cQuery +="WHERE "
	cQuery +=" (Z7_DATINI >= '"+DTOS(_dDataIni)+"' ) AND "
	cQuery +=" (Z7_DATFIM <= '"+DTOS(_dDatafim)+"' ) AND "
	cQuery +=" (Z7_LOTE='"+_cLoteCli+"')    AND "
	cQuery +=" (Z7_SEGMERC BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' ) AND "
	cQuery +=" (Z7_REGIAO  BETWEEN '"+mv_par10+"' AND '"+mv_par11+"' ) "
	TCQUERY cQuery new alias "REGI"
	dbSelectArea ("REGI")
	DBGOTOP()
	_nRegTVLRFAT := _nRegVLR
	dbCloseArea("REGI")
	// Total Supervisor
	cQuery := "SELECT SUM (Z7_VLRFAT) AS _nSegVLR "
	cQuery += "FROM  "+RetSqlName("SZ7")+ "  "
	cQuery += "WHERE  "
	cQuery += " (Z7_DATINI >= '"+DTOS(_dDataIni)+"' ) AND "
	cQuery += " (Z7_DATFIM <= '"+DTOS(_dDatafim)+"' ) AND "
	cQuery += " (Z7_LOTE='"+_cLoteCli+"')    AND  "
	cQuery += " (Z7_SEGMERC BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' ) AND "
	cQuery += " (Z7_REGIAO  BETWEEN '"+mv_par10+"' AND '"+mv_par11+"' )  "
	TCQUERY cQuery new alias "SUPV"
	dbSelectArea ("SUPV")
	DBGOTOP()
	_nSegVLRFAT := _nSegVLR
	dbCloseArea("SUPV")
	// Total Geral
	cQuery := "SELECT SUM (Z7_VLRFAT) AS _nToTVLR "
	cQuery += "FROM  "+RetSqlName("SZ7")+ "  "
	cQuery += "WHERE  "
	cQuery += " (Z7_DATINI >= '"+DTOS(_dDataIni)+"' ) AND "
	cQuery += " (Z7_DATFIM <= '"+DTOS(_dDatafim)+"' ) AND "
	cQuery += " (Z7_LOTE='"+_cLoteCli+"') "
	TCQUERY cQuery new alias "TOTG"
	dbSelectArea ("TOTG")
	DBGOTOP()
	_nToTTVLRFAT := _nToTVLR
	dbCloseArea("TOTG")
	***********

	dbSelectArea("SZ7")
	dbSetOrder(3)            // _cIndex   := "Z7_FILIAL+Z7_SEGMERC+Z7_REGIAO+Z7_VENDE+ Z7_REDE + Z7_CLIENTE + Z7_LOJA"

	ProcRegua(RecCount())
	_cContr_Imp := 0
	dbGoTop()
	DbSeek(xFilial("SZ7")+_cLoteCli+ mv_par06 )
	Do While !Eof() .AND. Z7_LOTE = _cLoteCli
		IncProc('Gerando Resumo por Segmento de Mercado ')
		If SZ7->Z7_SEGMERC >= mv_par06  .AND.  SZ7->Z7_SEGMERC <= mv_par07
			If SZ7->Z7_REGIAO  >= mv_par10  .AND.  SZ7->Z7_REGIAO <= mv_par11
				If SZ7->Z7_VENDED  >=  mv_par12  .AND.  SZ7->Z7_VENDED <= mv_par13
					// Incluir dois  Atributos na Tabela  (Segmento de Mercado) para informar
					// Se entra no resumo ou nao e no futuro ordenar conforme a sequencia do atritubo
					If SZ7->Z7_IMPSEG = 'N'  // Se no segmento estiver marcado não pula
						dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
						dbSkip()
						Loop
					Endif
					
					If SZ7->Z7_SEGMERC <> _cSegTAnt
						_TotPesInd  := 0
					Endif
					_cSEGMERC  := SZ7->Z7_SEGMERC
					_cREGIAO      := SZ7->Z7_REGIAO
					_cVENDED     := SZ7->Z7_VENDED
					_cCLIENTE     := SZ7->Z7_CLIENTE
					_cVENDED     := SZ7->Z7_VENDED
					_cVENDESC   := SZ7->Z7_VENDESC
					_nLoja	  := 0
					// Opcoes para impressao
					//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
					//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
					//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
					// Conforme tipo de relatorio solicitado
					// Resumo dos Segmento que e o sintetivo de cada Regiao como quebra o Segmento
					// Analitico de Cada Vendedor temdo como detalhe o Cliente
					// Faco uma outra jogada para agrupar a loja que controla rede
					_cCtrCliente := '00000000'   // 8 Carac.
					_cCLIENTE    := space(6)
					_cCLINOME    := space(6)
					_cSeqOrder   := '000'  // space(3)
					_cSeqInvert  := _cSeqOrder + SZ7->Z7_SEGMERC + SZ7->Z7_REGIAO + _cCtrCliente
					// //                  3                 3                6               8     = 20
					// Monto a chave conforme o tipo de cliente
					_cTrIndice := _cSeqInvert
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava arquivo Temporario de Impressao                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Neste Caso grava as redes totalizadas
					If SZ7->Z7_VLRFAT > 0
						_cContr_Imp := 1
						Grav_Arq1()
						//Gero Total ponderedo
						// Pondero os Indices
						If (SZ7->Z7_PESTOT + _nTPESO) > 0
							If  SZ7->Z7_IPT > 0              
								//Se for a primeira vez assume o valor do primeiro, para calcular o total ponderado
								If _nTIPT = 0                                                                                          
									_nCalcQuo := (SZ7->Z7_IPT * SZ7->Z7_PESTOT ) 
								Else
									_nCalcQuo := ((SZ7->Z7_IPT * SZ7->Z7_PESTOT ) + (_nTIPT * _nTPESO))							
								Endif
								_nCalcDiv := ((SZ7->Z7_PESTOT + _nTPESO))
								//_nTIPT    := ROUND(_nCalcQuo / _nCalcDiv,3)
								_nTIPT    :=  _nCalcQuo / _nCalcDiv
							Endif
							If  SZ7->Z7_IPG > 0        //////If REL1->_IPG > 0
								//Se for a primeira vez assume o valor do primeiro, para calcular o total ponderado						
								If _nTIPG  = 0
									_nCalcQuo := (SZ7->Z7_IPG * SZ7->Z7_PESTOT )
								Else
									_nCalcQuo := ((SZ7->Z7_IPG * SZ7->Z7_PESTOT ) + (_nTIPG * _nTPESO))
								Endif		
								_nCalcDiv := ((SZ7->Z7_PESTOT + _nTPESO))
								// _nTIPG    := ROUND(_nCalcQuo / _nCalcDiv,3)
								_nTIPG    :=  _nCalcQuo / _nCalcDiv
							Endif
							If  SZ7->Z7_IPS > 0           
								//Se for a primeira vez assume o valor do primeiro, para calcular o total ponderado						
								If  _nTIPS  = 0
										_nCalcQuo := (SZ7->Z7_IPS * SZ7->Z7_PESTOT ) 
								Else		
										_nCalcQuo := ((SZ7->Z7_IPS * SZ7->Z7_PESTOT ) + (_nTIPS * _nTPESO))
								Endif
								_nCalcDiv := ((SZ7->Z7_PESTOT + _nTPESO))
								//_nTIPS    := ROUND(_nCalcQuo / _nCalcDiv,3)
								_nTIPS    := _nCalcQuo / _nCalcDiv
							Endif
							_nTPESO    := _nTPESO    + SZ7->Z7_PESTOT
							
						Endif
						_TPrzMed     := ((SZ7->Z7_PRZMED *  SZ7->Z7_VLRFAT) + (_TPrzMed * _nTVLRFAT)) /  (SZ7->Z7_VLRFAT + _nTVLRFAT)
						_nTVLRFAT   := _nTVLRFAT  + SZ7->Z7_VLRFAT
						_nTFREQUE  := REL1->_FREQUE  + _nTFREQUE
						_nTCT         := SZ7->Z7_CT   + _nTCT
						_nTINAT      := SZ7->Z7_INAT + _nTINAT
						_nTFMA0    := SZ7->Z7_FMA0 + _nTFMA0
						_nTF0          := SZ7->Z7_F0   + _nTF0
						_nTF1          := SZ7->Z7_F1   + _nTF1
						_nTFMA1     := SZ7->Z7_FMA1 + _nTFMA1
						
						// Calcula Preço Medio
						
						If (SZ7->Z7_PESTOT  + SZ7->Z7_VLRFAT) > 0
							If SZ7->Z7_VLR01 <> 0
								_nTPRC01    := ((_nTPRC01 * _nTotGrp001)+SZ7->Z7_VLR01) / (SZ7->Z7_QTD01 + _nTotGrp001)
								_nTotGrp001 := _nTotGrp001 + SZ7->Z7_QTD01
							Endif
							
							If SZ7->Z7_VLR02 <> 0
								_nTPRC02    := ((_nTPRC02 * _nTotGrp002)+SZ7->Z7_VLR02) / (SZ7->Z7_QTD02 + _nTotGrp002)
								_nTotGrp002 := _nTotGrp002 + SZ7->Z7_QTD02
							Endif
							
							If SZ7->Z7_VLR03 <> 0
								_nTPRC03    := ((_nTPRC03 * _nTotGrp003)+SZ7->Z7_VLR03) / (SZ7->Z7_QTD03 + _nTotGrp003)
								_nTotGrp003 := _nTotGrp003 + SZ7->Z7_QTD03
							Endif
							
							If SZ7->Z7_VLR04 <> 0
								_nTPRC04    := ((_nTPRC04 * _nTotGrp004)+SZ7->Z7_VLR04) / (SZ7->Z7_QTD04 + _nTotGrp004)
								_nTotGrp004 := _nTotGrp004 + SZ7->Z7_QTD04
							Endif
							
							If SZ7->Z7_VLR05 <> 0
								_nTPRC05    := ((_nTPRC05 * _nTotGrp005)+SZ7->Z7_VLR05) / (SZ7->Z7_QTD05 + _nTotGrp005)
								_nTotGrp005 := _nTotGrp005 + SZ7->Z7_QTD05
							Endif
							If SZ7->Z7_VLR06 <> 0
								_nTPRC06    := ((_nTPRC06 * _nTotGrp006)+SZ7->Z7_VLR06) / (SZ7->Z7_QTD06 + _nTotGrp006)
								_nTotGrp006 := _nTotGrp006 + SZ7->Z7_QTD06
							Endif
							If SZ7->Z7_VLR07 <> 0
								_nTPRC07    := ((_nTPRC07 * _nTotGrp007)+SZ7->Z7_VLR07) / (SZ7->Z7_QTD07 + _nTotGrp007)
								_nTotGrp007 := _nTotGrp007 + SZ7->Z7_QTD07
							Endif
							
							If SZ7->Z7_VLR08 <> 0
								_nTPRC08    := ((_nTPRC08 * _nTotGrp008)+SZ7->Z7_VLR08) / (SZ7->Z7_QTD08 + _nTotGrp008)
								_nTotGrp008 := _nTotGrp008 + SZ7->Z7_QTD08
							Endif
							If SZ7->Z7_VLR08 <> 0
								_nTPRC08    := ((_nTPRC08 * _nTotGrp008)+SZ7->Z7_VLR08) / (SZ7->Z7_QTD08 + _nTotGrp008)
								_nTotGrp008 := _nTotGrp008 + SZ7->Z7_QTD08
							Endif
							If SZ7->Z7_VLR09 <> 0
								_nTPRC09    := ((_nTPRC09 * _nTotGrp009)+SZ7->Z7_VLR09) / (SZ7->Z7_QTD09 + _nTotGrp009)
								_nTotGrp009 := _nTotGrp009 + SZ7->Z7_QTD09
							Endif
							
							If SZ7->Z7_VLR10 <> 0
								_nTPRC10    := ((_nTPRC10 * _nTotGrp010)+SZ7->Z7_VLR10) / (SZ7->Z7_QTD10 + _nTotGrp010)
								_nTotGrp010 := _nTotGrp010 + SZ7->Z7_QTD10
							Endif
							If SZ7->Z7_VLR11 <> 0
								_nTPRC113    := ((_nTPRC11 * _nTotGrp011)+SZ7->Z7_VLR11) / (SZ7->Z7_QTD11 + _nTotGrp011)
								_nTotGrp011 := _nTotGrp011 + SZ7->Z7_QTD11
							Endif
							If SZ7->Z7_VLR12 <> 0
								_nTPRC12    := ((_nTPRC12 * _nTotGrp012)+SZ7->Z7_VLR12) / (SZ7->Z7_QTD12 + _nTotGrp012)
								_nTotGrp012 := _nTotGrp012 + SZ7->Z7_QTD12
							Endif
							
							If SZ7->Z7_VLR12 <> 0
								_nTPRC12    := ((_nTPRC12 * _nTotGrp012)+SZ7->Z7_VLR12) / (SZ7->Z7_QTD12 + _nTotGrp012)
								_nTotGrp012 := _nTotGrp012 + SZ7->Z7_QTD12
							Endif
							
							If SZ7->Z7_VLR13 <> 0
								_nTPRC13    := ((_nTPRC13 * _nTotGrp013)+SZ7->Z7_VLR13) / (SZ7->Z7_QTD13 + _nTotGrp013)
								_nTotGrp013 := _nTotGrp013 + SZ7->Z7_QTD13
							Endif
							
							If SZ7->Z7_VLR14 <> 0
								_nTPRC14    := ((_nTPRC14 * _nTotGrp014)+SZ7->Z7_VLR14) / (SZ7->Z7_QTD14 + _nTotGrp014)
								_nTotGrp014 := _nTotGrp014 + SZ7->Z7_QTD14
							Endif
							If SZ7->Z7_VLR15 <> 0
								_nTPRC15    := ((_nTPRC15 * _nTotGrp015)+SZ7->Z7_VLR15) / (SZ7->Z7_QTD15 + _nTotGrp015)
								_nTotGrp015 := _nTotGrp015 + SZ7->Z7_QTD15
							Endif
						Endif
					Endif
					_cSegTAnt := SZ7->Z7_SEGMERC
				Endif
			Endif
		Endif
		dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
		dbSkip()
	Enddo


	If MV_PAR17 = 1
		// Apos gerar arquivo verifica se faz uma copia
		_cData     := dtos( dDataBase )
		_cArqOrig  := _cDirOrig := "\SIGAADV\"+_cFileREL + GetDBExtension()
		//*******************************************************
		_cTime  := substr(time(),4,2)+substr(time(),7,1)
		_cLabel := 'S'+substr( _cData , 5 , 4 ) +_cTime + GetDBExtension()
		If empty(MV_PAR18)
			_cDire = "C:\"
		Else
			_cDire =alltrim(MV_PAR18)
		Endif
		_cDestin := _cDire+_cLabel    // "C:\xxxx\yyy\"+nome
		dbSelectArea("REL1")
		dbGoTop()
		Copy File &(_cArqOrig) To  &(_cDestin)    // Copy to &_cDestin
		
		// Copy File &(_cArqOrig) To &(_cArqDest)
		//*******************************************************
	Endif

	// Impressao dos Relatorios ....
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³

	// Carrego Matriz dos Nomes dos Grupos
	_mGrupoPrd  :={}        //  //   Gerar uma matriz para os grupos de pesos
	_mGrupoPrc  :={}         //  //   Gerar uma matriz para os grupos de precos
	dbSelectArea("SBM")
	dbSetOrder(1)
	//Processa({|| RunNomGr1()},"Gera matriz dos grupo e sub-grupo dos produtos ...")
	//Return

	//Static Function RunNomGr1()

	//ProcRegua(RecCount())
	dbGoTop()
	_nSeqMatrPes := 1             //   Controla a sequencia de Pesos
	Do While _nSeqMatrPes <= 80  //50 //30
		AADD(_mGrupoPrd,{_nSeqMatrPes,'      ','      '})
		AADD(_mGrupoPrc,{_nSeqMatrPes,'       ','       '})
		_nSeqMatrPes   := _nSeqMatrPes  + 1      //   Controla a sequencia de Pesos
	Enddo
	_nSeqMatrPes   := 1            //   Controla a sequencia de Pesos
	_nSeqMatrPrc   := 1            //   Controla a sequencia de Preços
	// Atualizo Matriz de Peso
	_cIndTrab1  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab1 ,"strzero(SBM->BM_Ctrpes,2)",,,' Criando Indice de Usuario')
	_nIndex1 := RetIndex('SBM')+1
	DbsetOrder(_nIndex1)
	dbGoTop()
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPes > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPes < 80 //50 //30     // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrd,{|x| x[1]==SBM->BM_Ctrpes } )
				If _cPosMatrz = 0
					_cPosMatrz := SBM->BM_Ctrpes
				Endif
				_mGrupoPrd[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,6)
				_mGrupoPrd[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,6)
				_nSeqMatrPes := _nSeqMatrPes + 1
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo

	dbGoTop()
	_cIndTrab2  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab2 ,"strzero(SBM->BM_CtrPrc,2)",,,' Criando Indice de Usuario')
	_nIndex2 := RetIndex('SBM')+1
	DbsetOrder(_nIndex2)
	dbGoTop()
	// Atualizo Matriz de Preco
	_nSeqMatrPrc  := 1
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPrc > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPrc  <  80  //50 //30    // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrc,{|x| x[1]==SBM->BM_Ctrprc})
				If _cPosMatrz = 0
					_cPosMatrz    := SBM->BM_Ctrprc
					_nSeqMatrPrc  := _nSeqMatrPrc + 1
				Endif
				_mGrupoPrc[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,7)
				_mGrupoPrc[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,7)
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo a Tabela de  Regiao para Peso                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Forco um filtro por Regiao  Conforme Parmetro
	//³ CLIAT1   ¦ mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SZN010 para buscar dados do Segmento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _cCodSegto := space(3)
	Private Li := 80
	dbSelectArea("SZN")
	dbSetOrder(1)         // ZN_FILIAL+ZN_CODIGO
	dbGoTop()
	Do While !Eof()
		_cCodSegto := SZN->ZN_CODIGO
		If SZN->ZN_CODIGO < mv_par06 .OR. SZN->ZN_CODIGO > mv_par07
			dbSkip()
			Loop
		Endif
		// Apenas os que fazem parte da regiao analizada
		//  ¦ 1 - Resumo - Todos Segmentos
		//   Imprime 1-Qtde / 2-Precos Med  ³
		If mv_par15 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			Impr_Rel1()
		Endif
		dbSelectArea("SZN")
		dbSkip()
	Enddo

	// ***********************
	// Total Geral Quantidade
	// ***********************
	If (_nTCT  + _nTINAT) > 0
		@ Li,001 PSAY "|============================================================================================================================================================================================================================|"
		Li := 	Li + 1
		@ Li,001 PSAY  "|  TOTAL EMPRESA ==> "
		@ Li,031 PSAY  "|"
		@ Li,036 PSAY  "|"
		@ Li,041 PSAY  "|"
		@ Li,046 PSAY  "|"
		@ Li,051 PSAY  "|"
		@ Li,056 PSAY  "|"  + Transform( _nTIPT  , "@E 9.999" )
		@ Li,062 PSAY  "|"  + Transform( _nTIPG  , "@E 9.999" )
		@ Li,068 PSAY  "|"  + Transform( _nTIPS  , "@E 9.999" )
		@ Li,074 PSAY  "|"  + Transform( (_nTVLRFAT /_nTFREQUE)  , "@E 999999.999")
		@ Li,085 PSAY  "|"  + Transform( (_nTPESO /_nTFREQUE)  , "@E 999999.999" )
		@ Li,096 PSAY  "|"  + Transform( _nTFREQUE , "@E 9999" )
		@ Li,101 PSAY  "|"  + Transform( _TPrzMed , "@E 999.9" )
		@ Li,106 PSAY  "|"  + Transform( _nTVLRFAT  , "@E 999999,999,999" )
		@ Li,121 PSAY  "|"  + Transform( _nPERCTOT  , "@E 999.9" )
		@ Li,127 PSAY  "|"  + Transform( _nTPESO  , "@E 99999,999" )
		@ Li,137 PSAY  "|"  + Transform( _nTTOTGRUP1 , "@E 999999" )
		@ Li,144 PSAY  "|"  + Transform( _nTTOTGRUP2 , "@E 999999" )
		@ Li,151 PSAY  "|"  + Transform( _nTGRUP01  , "@E 999999" )
		@ Li,158 PSAY  "|"  + Transform( _nTGRUP02  , "@E 999999" )
		@ Li,165 PSAY  "|"  + Transform( _nTGRUP03  , "@E 999999" )
		@ Li,172 PSAY  "|"  + Transform( _nTGRUP04  , "@E 999999" )
		@ Li,179 PSAY  "|"  + Transform( _nTGRUP05  , "@E 999999" )
		@ Li,186 PSAY  "|"  + Transform( _nTGRUP06  , "@E 999999" )
		@ Li,193 PSAY  "|"  + Transform( _nTGRUP07  , "@E 999999" )
		@ Li,200 PSAY  "|"  + Transform( _nTGRUP08  , "@E 999999" )
		@ Li,207 PSAY  "|"  + Transform( _nTGRUP09  , "@E 999999" )
		@ Li,214 PSAY  "|"  + Transform( _nTGRUP10  , "@E 999999" )
		@ Li,221 PSAY  "|"
		Li := 	Li+1
		@ Li,001 PSAY  "|============================================================================================================================================================================================================================|"
		Li := 	Li+1
		@ Li,030 PSAY  " Total de  Clintes        "   + Transform(_nTCT , "@E 9999,999" )
		Li := 	Li+1
		@ Li,030 PSAY  " Frequencia maior que zero"   + Transform(_nTFMA0, "@E 9999,999" )
		Li := 	Li+1
		@ Li,030 PSAY  " Frequencia zero          "   + Transform(_nTF0, "@E 9999,999" )
		Li := 	Li+1
		@ Li,030 PSAY  " Frequencia igual a um    "   + Transform(_nTF1, "@E 9999,999" )
		Li := 	Li+1
		@ Li,030 PSAY  " Frequencia maior que um  "   + Transform(_nTFMA1, "@E 9999,999" )
		
	Endif
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo a Tabela de  Regiao para Preco                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SZN010 para buscar dados do Segmento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private	li := 80
	dbSelectArea("SZN")
	dbSetOrder(1)         // ZN_FILIAL+ZN_CODIGO
	dbGoTop()
	Do While !Eof()
		_cCodSegto = SZN->ZN_CODIGO
		If SZN->ZN_CODIGO < mv_par06 .OR. SZN->ZN_CODIGO > mv_par07
			dbSkip()
			Loop
		Endif
		// Apenas os que fazem parte da regiao analizada
		//  ¦ 1 - Resumo - Todos Segmentos
		//   Imprime 1-Qtde / 2-Precos Med  ³
		If mv_par16 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			Impr_Rel1a()
		Endif
		dbSelectArea("SZN")
		dbSkip()
	Enddo
	//  *******************
	//  Total Geral Precos
	//  *******************

	If (_nTCT  + _nTINAT) > 0
		
		@ Li,001 PSAY  "|============================================================================================================================================================================================================================|"
		Li := 	Li+1
		
		@ Li,001 PSAY  "|"
		@ Li,031 PSAY  "|"  + Transform(_nTCT , "@E 9999" )
		@ Li,036 PSAY  "|"  + Transform(_nTFMA0, "@E 9999" )
		@ Li,041 PSAY  "|"  + Transform(_nTF0, "@E 9999" )
		@ Li,046 PSAY  "|"  + Transform(_nTF1, "@E 9999" )
		@ Li,051 PSAY  "|"  + Transform(_nTFMA1, "@E 9999" )
		@ Li,056 PSAY  "|"  + Transform(_nTIPT  , "@E 99.999" )
		@ Li,063 PSAY  "|"  + Transform(_nTIPG  , "@E 99.999" )
		@ Li,070 PSAY  "|"  + Transform(_nTIPS  , "@E 99.999" )
		@ Li,078 PSAY  "|"  + Transform( _nTVLRFAT , "@E 999999,999")
		@ Li,090 PSAY  "|"  + Transform( _nTPESO  , "@E 999999,999" )
		
		@ Li,101 PSAY  "|"    + Transform( _nTPRC01  , "@E 99.9999" )
		@ Li,109 PSAY  "|"    + Transform( _nTPRC02  , "@E 99.9999" )
		@ Li,117 PSAY  "|"    + Transform( _nTPRC03  , "@E 99.9999" )
		@ Li,125 PSAY  "|"    + Transform( _nTPRC04  , "@E 99.9999" )
		@ Li,133 PSAY  "|"    + Transform( _nTPRC05  , "@E 99.9999" )
		@ Li,141 PSAY  "|"    + Transform( _nTPRC06  , "@E 99.9999" )
		@ Li,149 PSAY  "|"    + Transform( _nTPRC07  , "@E 99.9999" )
		@ Li,157 PSAY  "|"    + Transform( _nTPRC08  , "@E 99.9999" )
		@ Li,165 PSAY  "|"    + Transform( _nTPRC09  , "@E 99.9999" )
		@ Li,173 PSAY  "|"    + Transform( _nTPRC10  , "@E 99.9999" )
		@ Li,181 PSAY  "|"    + Transform( _nTPRC11  , "@E 99.9999" )
		@ Li,189 PSAY  "|"    + Transform( _nTPRC12  , "@E 99.9999" )
		@ Li,197 PSAY  "|"    + Transform( _nTPRC13  , "@E 99.9999" )
		@ Li,205 PSAY  "|"    + Transform( _nTPRC14  , "@E 99.9999" )
		@ Li,213 PSAY  "|"    + Transform( _nTPRC15  , "@E 99.9999" )
		@ Li,221 PSAY  "|"    //+ Transform( _nPRC15  , "@E 9.99999" )
		Li := 	Li+1
		@ Li,001 PSAY  "|===========================================================================================================================================================================================================================|"
		
	Endif

	Return

	// Funcao de Impressao da Quantidades

	//***********
	Static Function Impr_Rel1()
	//
	//   Impressao
	_cTipoRel  := "( QUANTIDADE FATURADA (PESO) )"
	titulo    :="CLASSIFICACAO DOS CLIENTES ATIVOS POR REGIAO  (QUANTIDADE)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	// Zero as Variaveis
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_PrzMed := 0
	_nNUMREDES := 0
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nGRUP01   := 0
	_nGRUP02 := 0
	_nGRUP03 := 0
	_nGRUP04 := 0
	_nGRUP05 := 0
	_nGRUP06 := 0
	_nGRUP07 := 0
	_nGRUP08 := 0
	_nGRUP09 := 0
	_nGRUP10 := 0
	_nGRUP11 := 0
	dbSelectArea("REL1")
	dbSetOrder(1)
	dbGoTop()      
	// Forço posicionar o registro proximo 
	//Set SOFTSEEK on
	DbSeek( _cCodSegto)
	// Desativo  o comando
	//Set SOFTSEEK off
	Do While !Eof()
		// // // //
		If REL1->_SEGMERC  == _cCodSegto
			// So imprime se for clientes
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			If li > 64
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM )  +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				@ Li,001  PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001  PSAY "|"
				@ Li,04    PSAY "SEGMENTO : " +REL1->_SEGMERC  +'  '+ REL1->_SEGDESC
				@ Li,209  PSAY "Impr_Rel1"							
				@ Li,221  PSAY "|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|*****************|********************|****|*****|*************|*****|**********|*************************"+_cTipoRel+"***************************|"
				Li := Li + 1
				@ Li,001 PSAY "|                                                      |     INDICES     |    PEDIDO  MEDIO   |    | PRZ |    FATURA-  |  %  |   PESO   |  SUB TOTAL  |"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				
				_cBMTTH1 = 'GRUPO1'
				_cBMTTH2 = 'GRUPO2'
				_cBMGp01 = (_mGrupoPrd[1,3])
				_cBMGp02 = (_mGrupoPrd[2,3])
				_cBMGp03 = (_mGrupoPrd[3,3])
				_cBMGp04 = (_mGrupoPrd[4,3])
				_cBMGp05 = (_mGrupoPrd[5,3])
				_cBMGp06 = (_mGrupoPrd[6,3])
				_cBMGp07 = (_mGrupoPrd[7,3])
				_cBMGp08 = (_mGrupoPrd[8,3])
				_cBMGp09 = (_mGrupoPrd[9,3])
				_cBMGp10 = (_mGrupoPrd[10,3])
				Li := Li + 1
				@ Li,001 PSAY "|          REGIAO             |CT  | F>0| F0 | F1 |F>1 | IPT   IPG   IPS |  VALOR   |   PESO  |FREQ| MED |     MENTO   |FATUR|  TOTAL   |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"
				//	@ Li,001 PSAY "|          REGIAO             |CT  | F>0| F0 | F1 |F>1 | IPG   IPS   IPR |  VALOR   |   PESO  |FREQ| MED |     MENTO   |FATUR|  TOTAL   |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|" ALEX BORGES 13/03/12
				//@ Li,001 PSAY "|          REGIAO              |CT   |F>0 | F0 | F1|F>1|SEG    SUP   REG |  VALOR   |   PESO  |FREQ| MED |     MENTO   |FATUR|  TOTAL   |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"
				Li := Li + 1
				@ Li,001 PSAY "|*****************************|****|****|****|****|****|*****|*****|*****|**********|*********|****|*****|*************|*****|**********|******|******|******|******|******|******|******|******|******|******|******|******|"
				Li := Li + 1
			Else
				If _nCT = 0
					@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
					Li := Li + 1
					@ Li,001 PSAY "|"
					@ Li,04        PSAY "SEGMENTO : " +REL1->_SEGMERC +'  '+ REL1->_SEGDESC
					@ Li,209 PSAY "Impr_Rel1"				
					@ Li,221 PSAY "|"
					Li := Li + 1
					@ Li,001 PSAY "|******************************************************|*****************|********************|*****|****|*************|*****|*********|*************************"+_cTipoRel+"*****************************|"
					Li := Li + 1
				Endif
			Endif
			// Frequencia do Cliente
			// // //
			_nCT        := REL1->_CT   + _nCT
			_nINAT     := REL1->_INAT + _nINAT
			_nFMA0   := REL1->_FMA0 + _nFMA0
			_nF0        := REL1->_F0   + _nF0
			_nF1        := REL1->_F1   + _nF1
			_nFMA1   := REL1->_FMA1 + _nFMA1
			
			_nNUMREDES = REL1->_NUMREDES + _nNUMREDES
			
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL1->_REGIAO +' '+SUBSTR(REL1->_REGDESC,1,17)		   // 6 + 1 + 21 = 28
			@ Li,031 PSAY  "|"    + Transform(REL1->_CT , "@E 9999" )
			@ Li,036 PSAY  "|"    + Transform(REL1->_FMA0, "@E 9999" )
			@ Li,041 PSAY  "|"    + Transform(REL1->_F0, "@E 9999" )
			@ Li,046 PSAY  "|"    + Transform(REL1->_F1, "@E 9999" )
			@ Li,051 PSAY  "|"    + Transform(REL1->_FMA1, "@E 9999" )
			@ Li,056 PSAY  "|"    + Transform(REL1->_IPT  , "@E 9.999" )
			@ Li,062 PSAY  "|"    + Transform(REL1->_IPG  , "@E 9.999" )
			@ Li,068 PSAY  "|"    + Transform(REL1->_IPS  , "@E 9.999" )
			@ Li,074 PSAY  "|"    + Transform(REL1->_VALORPED  , "@E 999999,999")  // 999999.999
			@ Li,085 PSAY  "|"    + Transform(REL1->_PESOPED  , "@E 99999,999")  // 999999.999
			@ Li,095 PSAY  "|"    + Transform(REL1->_FREQUE  , "@E 9999" )
			@ Li,100 PSAY  "|"    + Transform(REL1->_PRAZOMED  , "@E 999.9" )
			@ Li,106 PSAY  "|"    + Transform(REL1->_VALORFAT  , "@E 9999,999,999" )
			@ Li,120 PSAY  "|"    + Transform((REL1->_VALORFAT /_nToTTVLRFAT)*100 , "@E 999.9" )
			@ Li,126 PSAY  "|"    + Transform(REL1->_PESOTOT  , "@E 999999,999" )
			@ Li,137 PSAY  "|"    + Transform(REL1->_TOTGRUP1 , "@E 999999" )
			@ Li,144 PSAY  "|"    + Transform(REL1->_TOTGRUP2 , "@E 999999" )
			@ Li,151 PSAY  "|"    + Transform(REL1->_GRUPO01  , "@E 999999" )
			@ Li,158 PSAY  "|"    + Transform(REL1->_GRUPO02  , "@E 999999" )
			@ Li,165 PSAY  "|"    + Transform(REL1->_GRUPO03  , "@E 999999" )
			@ Li,172 PSAY  "|"    + Transform(REL1->_GRUPO04  , "@E 999999" )
			@ Li,179 PSAY  "|"    + Transform(REL1->_GRUPO05  , "@E 999999" )
			@ Li,186 PSAY  "|"    + Transform(REL1->_GRUPO06  , "@E 999999" )
			@ Li,193 PSAY  "|"    + Transform(REL1->_GRUPO07  , "@E 999999" )
			@ Li,200 PSAY  "|"    + Transform(REL1->_GRUPO08  , "@E 999999" )
			@ Li,207 PSAY  "|"    + Transform(REL1->_GRUPO09  , "@E 999999" )
			@ Li,214 PSAY  "|"    + Transform(REL1->_GRUPO10  , "@E 999999" )
			@ Li,221 PSAY  "|"
			Li := Li + 1
			
			// Pondero os Indices
			If ( REL1->_PESOTOT + _nPESO) > 0
				If REL1->_IPT > 0              
					If  _nIPT = 0    
						_nCalcQuo := (REL1->_IPT * REL1->_PESOTOT ) 
					Else				
						_nCalcQuo := ((REL1->_IPT * REL1->_PESOTOT ) + (_nIPT * _nPESO))									
					Endif
					_nCalcDiv   := ((REL1->_PESOTOT + _nPESO))
					//_nIPT     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPT     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL1->_IPG > 0
					If  _nIPG =0    
						_nCalcQuo := (REL1->_IPG * REL1->_PESOTOT ) 
					Else
						_nCalcQuo := ((REL1->_IPG * REL1->_PESOTOT ) + (_nIPG * _nPESO))									
					Endif

					_nCalcDiv := ((REL1->_PESOTOT + _nPESO))
					//_nIPG     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPG     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL1->_IPS > 0
					If _nIPS = 0
					_nCalcQuo := (REL1->_IPS * REL1->_PESOTOT ) 
					Else
					_nCalcQuo := ((REL1->_IPS * REL1->_PESOTOT ) + (_nIPS * _nPESO))				
					Endif
					_nCalcDiv := ((REL1->_PESOTOT + _nPESO))
					//_nIPS     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPS     := _nCalcQuo / _nCalcDiv
				Endif
				_PrzMed := ((REL1->_PRAZOMED *  REL1->_VALORFAT) + (_PrzMed * _nVLRFAT)) /  (REL1->_VALORFAT + _nVLRFAT)
				// Faz somatoria dos totais
				_nPESO        := REL1->_PESOTOT   + _nPESO
				_nFREQUE    := REL1->_FREQUE    + _nFREQUE
				_nVLRFAT     := REL1->_VALORFAT +_nVLRFAT
			Endif
			
			If _nVLRFAT > 0
				_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
			Endif
			_nVLRPES := REL1->_PESOPED  + _nVLRPES
			_nVLRPED := REL1->_VALORPED + _nVLRPED
			// Somo as colunas de grupos
			_nTOTGRUP1 := REL1->_TOTGRUP1 + _nTOTGRUP1
			_nTOTGRUP2 := REL1->_TOTGRUP2 + _nTOTGRUP2
			_nGRUP01   := REL1->_GRUPO01 + _nGRUP01
			_nGRUP02 := REL1->_GRUPO02 + _nGRUP02
			_nGRUP03 := REL1->_GRUPO03 + _nGRUP03
			_nGRUP04 := REL1->_GRUPO04 + _nGRUP04
			_nGRUP05 := REL1->_GRUPO05 + _nGRUP05
			_nGRUP06 := REL1->_GRUPO06 + _nGRUP06
			_nGRUP07 := REL1->_GRUPO07 + _nGRUP07
			_nGRUP08 := REL1->_GRUPO08 + _nGRUP08
			_nGRUP09 := REL1->_GRUPO09 + _nGRUP09 //alterado Ana estava grupo incorreto
			_nGRUP10 := REL1->_GRUPO10 + _nGRUP10 //alterado Ana estava grupo incorreto
			_nGRUP11 := REL1->_GRUPO11 + _nGRUP11 //alterado Ana estava grupo incorreto
			// Faco a somatoria para o total geral
			_nTTOTGRUP1 := REL1->_TOTGRUP1 + _nTTOTGRUP1
			_nTTOTGRUP2 := REL1->_TOTGRUP2 + _nTTOTGRUP2
			_nTGRUP01 := REL1->_GRUPO01 + _nTGRUP01
			_nTGRUP02 := REL1->_GRUPO02 + _nTGRUP02
			_nTGRUP03 := REL1->_GRUPO03 + _nTGRUP03
			_nTGRUP04 := REL1->_GRUPO04 + _nTGRUP04
			_nTGRUP05 := REL1->_GRUPO05 + _nTGRUP05
			_nTGRUP06 := REL1->_GRUPO06 + _nTGRUP06
			_nTGRUP07 := REL1->_GRUPO07 + _nTGRUP07
			_nTGRUP08 := REL1->_GRUPO08 + _nTGRUP08
			_nTGRUP09 := REL1->_GRUPO09 + _nTGRUP09
			_nTGRUP10 := REL1->_GRUPO10 + _nTGRUP10
			_nTGRUP11 := REL1->_GRUPO11 + _nTGRUP11
			
		Endif
		dbSelectArea("REL1")
		dbSkip()
	Enddo

	// So imprime se entrou no Vendedor
	If (_nCT  + _nINAT) > 0
		@ Li,001 PSAY  "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li + 1
		@ Li,001 PSAY  "|"
		@ Li,031 PSAY  "|"  + Transform(_nCT , "@E 9999" )
		@ Li,036 PSAY  "|"  + Transform(_nFMA0, "@E 9999" )
		@ Li,041 PSAY  "|"  + Transform(_nF0, "@E 9999" )
		@ Li,046 PSAY  "|"  + Transform(_nF1, "@E 9999" )
		@ Li,051 PSAY  "|"  + Transform(_nFMA1, "@E 9999" )
		@ Li,056 PSAY  "|"  + Transform( _nIPT  , "@E 9.999" )
		@ Li,062 PSAY  "|"  + Transform( _nIPG  , "@E 9.999" )
		@ Li,068 PSAY  "|"  + Transform( _nIPS  , "@E 9.999" )
		@ Li,074 PSAY  "|"  + Transform( (_nVLRFAT /_nFREQUE)  , "@E 999999,999")
		@ Li,085 PSAY  "|"  + Transform( (_nPESO /_nFREQUE)  , "@E 99999,999" )
		@ Li,095 PSAY  "|"  + Transform( _nFREQUE , "@E 9999" )
		//@ Li,100 PSAY  "|"  //   + Transform( _PrzMed , "@E 999.9" )
		@ Li,099 PSAY  "|"  + Transform( _PrzMed , "@E 999.9" )	
		@ Li,106 PSAY  "|"  + Transform( _nVLRFAT  , "@E 99999,999,999" )
		@ Li,120 PSAY  "|"  + Transform( _nPERCFAT , "@E 999.9" )
		@ Li,126 PSAY  "|"  + Transform( _nPESO  , "@E 999999,999" )
		@ Li,137 PSAY  "|"  + Transform( _nTOTGRUP1 , "@E 999999" )
		@ Li,144 PSAY  "|"  + Transform( _nTOTGRUP2 , "@E 999999" )
		@ Li,151 PSAY  "|"  + Transform( _nGRUP01  , "@E 999999" )
		@ Li,158 PSAY  "|"  + Transform( _nGRUP02  , "@E 999999" )
		@ Li,165 PSAY  "|"  + Transform( _nGRUP03  , "@E 999999" )
		@ Li,172 PSAY  "|"  + Transform( _nGRUP04  , "@E 999999" )
		@ Li,179 PSAY  "|"  + Transform( _nGRUP05  , "@E 999999" )
		@ Li,186 PSAY  "|"  + Transform( _nGRUP06  , "@E 999999" )
		@ Li,193 PSAY  "|"  + Transform( _nGRUP07  , "@E 999999" )
		@ Li,200 PSAY  "|"  + Transform( _nGRUP08  , "@E 999999" )
		@ Li,207 PSAY  "|"  + Transform( _nGRUP09  , "@E 999999" )
		@ Li,214 PSAY  "|"  + Transform( _nGRUP10  , "@E 999999" )
		@ Li,221 PSAY  "|"
		Li := 	Li+1
		@ Li,001 PSAY  "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Total Geral do Relatorio
		_nPERCTOT :=  _nPERCTOT + _nPERCFAT
	Endif


	Return
	//***********

	// Funcao de Impressao dos precos medios

	//***********
	Static Function Impr_Rel1a()
	//
	*******
	* Impressao
	*******
	_cTipoRel  := "(  P R E C O S  M E D I O S  )"
	titulo     :="CLASSIFICACAO DOS CLIENTES ATIVOS POR REGIAO (PRECOS)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	// Zero as Variaveis
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_nNUMREDES := 0
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nPRC01	:= 0
	_nPRC02	:= 0
	_nPRC03	:= 0
	_nPRC04	:= 0
	_nPRC05	:= 0
	_nPRC06	:= 0
	_nPRC07	:= 0
	_nPRC08	:= 0
	_nPRC09	:= 0
	_nPRC10	:= 0
	_nPRC11	:= 0
	_nPRC12	:= 0
	_nPRC13	:= 0
	_nPRC14	:= 0
	_nPRC15	:= 0
	_nPRC16	:= 0

	_nPESIT01 :=0
	_nPESIT02 :=0
	_nPESIT03 :=0
	_nPESIT04 :=0
	_nPESIT05 :=0
	_nPESIT06 :=0
	_nPESIT07 :=0
	_nPESIT08 :=0
	_nPESIT09 :=0
	_nPESIT10 :=0
	_nPESIT11 :=0
	_nPESIT12 :=0
	_nPESIT13 :=0
	_nPESIT14 :=0
	_nPESIT15 :=0
	_nPESIT16 :=0


	dbSelectArea("REL1")
	dbSetOrder(1)
	dbGoTop()
	Do While !Eof()
		// // // //
		If REL1->_SEGMERC  == _cCodSegto
			// So imprime se for clientes
			// // //
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			
			If li > 64
				Li := 8
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM )  +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001 PSAY "|"
				@ Li,04        PSAY "SEGMENTO : " +REL1->_SEGMERC  +'  '+ REL1->_SEGDESC
				@ Li,209 PSAY "Impr_Rel1a"
				@ Li,221 PSAY "|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|*********************|**********************|*****************************************"+_cTipoRel+"************************************************|"
				Li := Li + 1
				@ Li,001 PSAY "|                             |    |    |    |    |    |       INDICES       |      FATURAMENTO     |"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				//			@ Li,Pcol() PSAY (_mGrupoPrc[16,2])+"|"
				_cBMGp01 = (_mGrupoPrc[1,3])
				_cBMGp02 = (_mGrupoPrc[2,3])
				_cBMGp03 = (_mGrupoPrc[3,3])
				_cBMGp04 = (_mGrupoPrc[4,3])
				_cBMGp05 = (_mGrupoPrc[5,3])
				_cBMGp06 = (_mGrupoPrc[6,3])
				_cBMGp07 = (_mGrupoPrc[7,3])
				_cBMGp08 = (_mGrupoPrc[8,3])
				_cBMGp09 = (_mGrupoPrc[9,3])
				_cBMGp10 = (_mGrupoPrc[10,3])
				_cBMGp11 = (_mGrupoPrc[11,3])
				_cBMGp12 = (_mGrupoPrc[12,3])
				_cBMGp13 = (_mGrupoPrc[13,3])
				_cBMGp14 = (_mGrupoPrc[14,3])
				_cBMGp15 = (_mGrupoPrc[15,3])
				//			_cBMGp16 = (_mGrupoPrc[16,3])
				
				Li := Li + 1
				@ Li,001 PSAY "|          REGIAO             | CT | F>0| F0 | F1 | F>1|  IPT   IPG     IPS  |    VALOR      PESO   |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|"
				//@ Li,001 PSAY "|          REGIAO             | CT | F>0| F0 | F1 | F>1|  IPG   IPS     IPR  |    VALOR      PESO   |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|" ALEX BORGES 13/03/12
				//@ Li,001 PSAY "|          REGIAO              |CT   |F>0 | F0 | F1|F>1|SEG    SUP   REG |  VALOR   |   PESO  |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|"
				Li := Li + 1
				@ Li,001 PSAY "|*****************************|****|****|****|****|****|******|******|*******|***********|**********|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|"
				Li := Li + 1
			Else
				If _nCT = 0
					@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
					Li := Li + 1
					@ Li,001 PSAY "|"
					@ Li,04        PSAY "SEGMENTO : " +REL1->_SEGMERC +'  '+ REL1->_SEGDESC
					@ Li,209 PSAY "Impr_Rel1a"				
					@ Li,221 PSAY "|"
					Li := Li + 1
					@ Li,001 PSAY "|******************************************************|*****************|********************|*****|****|*************|*****|*********|*************************"+_cTipoRel+"****************************|"
					Li := Li + 1
				Endif
				
			Endif
			
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL1->_REGIAO +' '+SUBSTR(REL1->_REGDESC,1,21)		   // 6 + 1 + 21 = 28
			@ Li,031 PSAY  "|"    + Transform(REL1->_CT , "@E 9999" )
			@ Li,036 PSAY  "|"    + Transform(REL1->_FMA0, "@E 9999" )
			@ Li,041 PSAY  "|"    + Transform(REL1->_F0, "@E 9999" )
			@ Li,046 PSAY  "|"    + Transform(REL1->_F1, "@E 9999" )
			@ Li,051 PSAY  "|"    + Transform(REL1->_FMA1, "@E 9999" )
			@ Li,056 PSAY  "|"   + Transform( REL1->_IPT  , "@E 9.999" )
			@ Li,063 PSAY  "|"   + Transform( REL1->_IPG  , "@E 9.999" )
			@ Li,070 PSAY  "|"   + Transform( REL1->_IPS  , "@E 9.999" )
			@ Li,078 PSAY  "|"   + Transform( REL1->_VALORFAT  , "@E 999999,999")
			@ Li,090 PSAY  "|"   + Transform( REL1->_PESOTOT  , "@E 999999,999" )
			
			@ Li,101 PSAY  "|"   + Transform( REL1->_PRECO01  , "@E 99.9999" )
			@ Li,109 PSAY  "|"   + Transform( REL1->_PRECO02  , "@E 99.9999" )
			@ Li,117 PSAY  "|"   + Transform( REL1->_PRECO03  , "@E 99.9999" )
			@ Li,125 PSAY  "|"   + Transform( REL1->_PRECO04  , "@E 99.9999" )
			@ Li,133 PSAY  "|"   + Transform( REL1->_PRECO05  , "@E 99.9999" )
			@ Li,141 PSAY  "|"   + Transform( REL1->_PRECO06  , "@E 99.9999" )
			@ Li,149 PSAY  "|"   + Transform( REL1->_PRECO07  , "@E 99.9999" )
			@ Li,157 PSAY  "|"   + Transform( REL1->_PRECO08  , "@E 99.9999" )
			@ Li,165 PSAY  "|"   + Transform( REL1->_PRECO09  , "@E 99.9999" )
			@ Li,173 PSAY  "|"   + Transform( REL1->_PRECO10  , "@E 99.9999" )
			@ Li,181 PSAY  "|"   + Transform( REL1->_PRECO11  , "@E 99.9999" )
			@ Li,189 PSAY  "|"   + Transform( REL1->_PRECO12  , "@E 99.9999" )
			@ Li,197 PSAY  "|"   + Transform( REL1->_PRECO13  , "@E 99.9999" )
			@ Li,205 PSAY  "|"   + Transform( REL1->_PRECO14  , "@E 99.9999" )
			@ Li,213 PSAY  "|"   + Transform( REL1->_PRECO15  , "@E 99.9999" )
			@ Li,221 PSAY  "|"   //+ Transform( REL1->_PRECO16  , "@E 99.9999" )
			Li := Li + 1
			// Faz somatoria dos totais
			// Frequencia do Cliente
			_nCT       := _CT   + _nCT
			_nINAT    := _INAT + _nINAT
			_nFMA0  := _FMA0 + _nFMA0
			_nF0       := _F0   + _nF0
			_nF1       := _F1   + _nF1
			_nFMA1  := _FMA1 + _nFMA1
			_nNUMREDES = REL1->_NUMREDES + _nNUMREDES
			// Pondero os Indices
			If (REL1->_PESOTOT + _nPESO) > 0
				If REL1->_IPT > 0                                                                                   
					If _nIPT =	0
					_nCalcQuo := (REL1->_IPT * REL1->_PESOTOT )
					Else
					_nCalcQuo := ((REL1->_IPT * REL1->_PESOTOT ) + (_nIPT * _nPESO))				
					Endif
					_nCalcDiv := ((REL1->_PESOTOT + _nPESO))
					//_nIPT     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPT     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL1->_IPG > 0
					If _nIPG = 0
						_nCalcQuo := (REL1->_IPG * REL1->_PESOTOT ) 
					Else
						_nCalcQuo := ((REL1->_IPG * REL1->_PESOTOT ) + (_nIPG * _nPESO))
					Endif
					_nCalcDiv := ((REL1->_PESOTOT + _nPESO))
					//_nIPG     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPG     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL1->_IPS > 0
					If _nIPS = 0
						_nCalcQuo := (REL1->_IPS * REL1->_PESOTOT ) 
					Else
						_nCalcQuo := ((REL1->_IPS * REL1->_PESOTOT ) + (_nIPS * _nPESO))
					Endif
					_nCalcDiv := ((REL1->_PESOTOT + _nPESO))
					// _nIPS     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPS     :=  _nCalcQuo / _nCalcDiv
				Endif
				// Somatoria dos totais
				_nPESO    := REL1->_PESOTOT    + _nPESO
				_nVLRFAT  := REL1->_VALORFAT  + _nVLRFAT
				_nFREQUE  := REL1->_FREQUE     + _nFREQUE
			Endif
			If _nVLRFAT > 0
				_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
			Endif
			_nVLRPED = REL1->_VALORPED + _nVLRPED
			// Somo as colunas de grupos
			If (REL1->_PESOTOT + _nPESO) > 0
				If REL1->_PRECO01 <> 0
					_nPRC01ant :=_nPRC01
					_nPRC01 = ((REL1->_PRECO01 * REL1->_PESOTOT) + (_nPRC01ant * _nPESIT01)) /  (REL1->_PESOTOT + _nPESIT01)
					_nPESIT01  := _nPESIT01 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO02 <> 0
					_nPRC02ant :=_nPRC02
					_nPRC02 = ((REL1->_PRECO02 * REL1->_PESOTOT) + (_nPRC02ant * _nPESIT02)) /  (REL1->_PESOTOT + _nPESIT02)
					_nPESIT02  := _nPESIT02 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO03 <> 0
					_nPRC03ant :=_nPRC03
					_nPRC03 = ((REL1->_PRECO03 * REL1->_PESOTOT) + (_nPRC03ant * _nPESIT03)) /  (REL1->_PESOTOT + _nPESIT03)
					_nPESIT03  := _nPESIT03 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO04 <> 0
					_nPRC04ant :=_nPRC04
					_nPRC04 = ((REL1->_PRECO04 * REL1->_PESOTOT) + (_nPRC04ant * _nPESIT04)) /  (REL1->_PESOTOT + _nPESIT04)
					_nPESIT04  := _nPESIT04 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO05 <> 0
					_nPRC05ant =_nPRC05
					_nPRC05 = ((REL1->_PRECO05 * REL1->_PESOTOT) + (_nPRC05ant * _nPESIT05)) /  (REL1->_PESOTOT + _nPESIT05)
					_nPESIT05  := _nPESIT05 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO06 <> 0
					_nPRC06ant :=_nPRC06
					_nPRC06 = ((REL1->_PRECO06 * REL1->_PESOTOT) + (_nPRC06ant * _nPESIT06)) /  (REL1->_PESOTOT + _nPESIT06)
					_nPESIT06  := _nPESIT06 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO07 <> 0
					_nPRC07ant :=_nPRC07
					_nPRC07 = ((REL1->_PRECO07 * REL1->_PESOTOT) + (_nPRC07ant * _nPESIT07)) /  (REL1->_PESOTOT + _nPESIT07)
					_nPESIT07  := _nPESIT07 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO08 <> 0
					_nPRC08ant :=_nPRC08
					_nPRC08 = ((REL1->_PRECO08 * REL1->_PESOTOT) + (_nPRC08ant * _nPESIT08)) /  (REL1->_PESOTOT + _nPESIT08)
					_nPESIT08  := _nPESIT08 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO09 <> 0
					_nPRC09ant :=_nPRC09
					_nPRC09 = ((REL1->_PRECO09 * REL1->_PESOTOT) + (_nPRC09ant * _nPESIT09)) / (REL1->_PESOTOT + _nPESIT09)
					_nPESIT09  := _nPESIT09 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO10 <> 0
					_nPRC10ant :=_nPRC10
					_nPRC10 = ((REL1->_PRECO10 * REL1->_PESOTOT) + (_nPRC10ant * _nPESIT10)) /  (REL1->_PESOTOT + _nPESIT10)
					_nPESIT10  := _nPESIT10 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO11 <> 0
					_nPRC11ant :=_nPRC11
					_nPRC11 = ((REL1->_PRECO11 * REL1->_PESOTOT) + (_nPRC11ant * _nPESIT11)) /  (REL1->_PESOTOT + _nPESIT11)
					_nPESIT11  := _nPESIT11 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO12 <> 0
					_nPRC12ant :=_nPRC12
					_nPRC12 = ((REL1->_PRECO12 * REL1->_PESOTOT) + (_nPRC12ant * _nPESIT12)) /  (REL1->_PESOTOT + _nPESIT12)
					_nPESIT12  := _nPESIT12 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO13 <> 0
					_nPRC13ant :=_nPRC13
					_nPRC13 = ((REL1->_PRECO13 * REL1->_PESOTOT) + (_nPRC13ant * _nPESIT13)) /  (REL1->_PESOTOT + _nPESIT13)
					_nPESIT13  := _nPESIT13 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO14 <> 0
					_nPRC14ant :=_nPRC14
					_nPRC14 = ((REL1->_PRECO14 * REL1->_PESOTOT) + (_nPRC14ant * _nPESIT14)) /  (REL1->_PESOTOT + _nPESIT14)
					_nPESIT14  := _nPESIT14 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO15 <> 0
					_nPRC15ant :=_nPRC15
					_nPRC15 = ((REL1->_PRECO15 *REL1->_PESOTOT) + (_nPRC15ant * _nPESIT15)) /  (REL1->_PESOTOT + _nPESIT15)
					_nPESIT15  := _nPESIT15 + REL1->_PESOTOT
				Endif
				If REL1->_PRECO16 <> 0
					_nPRC16ant :=_nPRC16
					_nPRC16 = ((REL1->_PRECO16 *REL1->_PESOTOT) + (_nPRC16ant * _nPESIT16)) /  (REL1->_PESOTOT + _nPESIT16)
					_nPESIT16  := _nPESIT16 + REL1->_PESOTOT
				Endif
			Endif
			// Controla o Total Geral do Relatorio Precos
			_nTTOTGRUP1 = REL1->_TOTGRUP1 + _nTTOTGRUP1
			_nTTOTGRUP2 = REL1->_TOTGRUP2 + _nTTOTGRUP2
			
		Endif
		dbSelectArea("REL1")
		dbSkip()
	Enddo

	If (_nCT  + _nINAT) > 0
		@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		@ Li,001 PSAY  "|"
		@ Li,031 PSAY  "|"    + Transform(_nCT , "@E 9999" )
		@ Li,036 PSAY  "|"    + Transform(_nFMA0, "@E 9999" )
		@ Li,041 PSAY  "|"    + Transform(_nF0, "@E 9999" )
		@ Li,046 PSAY  "|"    + Transform(_nF1, "@E 9999" )
		@ Li,051 PSAY  "|"    + Transform(_nFMA1, "@E 9999" )
		@ Li,056 PSAY  "|"  + Transform( _nIPT  , "@E 99.999" )
		@ Li,063 PSAY  "|"  + Transform( _nIPG  , "@E 99.999" )
		@ Li,070 PSAY  "|"  + Transform( _nIPS  , "@E 99.999" )
		@ Li,078 PSAY  "|"  + Transform( _nVLRFAT , "@E 999999,999")
		@ Li,090 PSAY  "|"  + Transform( _nPESO  , "@E 999999,999" )
		@ Li,101 PSAY  "|"    + Transform( _nPRC01  , "@E 99.9999" )
		@ Li,109 PSAY  "|"    + Transform( _nPRC02  , "@E 99.9999" )
		@ Li,117 PSAY  "|"    + Transform( _nPRC03  , "@E 99.9999" )
		@ Li,125 PSAY  "|"    + Transform( _nPRC04  , "@E 99.9999" )
		@ Li,133 PSAY  "|"    + Transform( _nPRC05  , "@E 99.9999" )
		@ Li,141 PSAY  "|"    + Transform( _nPRC06  , "@E 99.9999" )
		@ Li,149 PSAY  "|"    + Transform( _nPRC07  , "@E 99.9999" )
		@ Li,157 PSAY  "|"    + Transform( _nPRC08  , "@E 99.9999" )
		@ Li,165 PSAY  "|"    + Transform( _nPRC09  , "@E 99.9999" )
		@ Li,173 PSAY  "|"    + Transform( _nPRC10  , "@E 99.9999" )
		@ Li,181 PSAY  "|"    + Transform( _nPRC11  , "@E 99.9999" )
		@ Li,189 PSAY  "|"    + Transform( _nPRC12  , "@E 99.9999" )
		@ Li,197 PSAY  "|"    + Transform( _nPRC13  , "@E 99.9999" )
		@ Li,205 PSAY  "|"    + Transform( _nPRC14  , "@E 99.9999" )
		@ Li,213 PSAY  "|"    + Transform( _nPRC15  , "@E 99.9999" )
		@ Li,221 PSAY  "|"    //+ Transform( _nPRC15  , "@E 9.99999" )
		Li := 	Li+1
		@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	Endif

	Return

	//***********


	Static Function Grav_Arq1()
	// Chave do Indice
	//  _cIndex   := "_SEGMERC + _REGIAO  +_SEQRELA"
	//	_cSEGMERC    _cREGIAO    _cTrIndice
	// Variaveis dos Indices
	_nVlr_IPT = 0     // Indices IPT
	_nVlr_IPG = 0     // Indices IPG
	_nVlr_IPS = 0     // Indices IPS

	dbSelectArea("REL1")             // _cIndex   := "_SEQRELA"
	If dbSeek(_cSEGMERC  +  _cREGIAO  + _cTrIndice)
		RecLock("REL1",.F.)   //  com .f. sem append blank
	Else
		RecLock("REL1",.T.)   // com .t. com append blank
		Replace _SEQRELA    WITH _cTrIndice         // Controle para sequencia do Relatorio
		Replace _DATAINI       With SZ7->Z7_DATINI    // Data Inicial
		Replace _DATAFIM     With SZ7->Z7_DATFIM    // Data Final
		Replace _SEGMERC   WITH _cSEGMERC          // Segmento de Mercado
		Replace _SEGDESC    WITH SZ7->Z7_SEGDESC   // Descricao Segmento de Mercado
		Replace _REGIAO        WITH _cREGIAO           // Regiao
		Replace _REGDESC     WITH SZ7->Z7_REGDESC   // Descricao da Regiao
		Replace _VENDED       WITH _cVENDED 		   // Vendedor
		Replace _VENDESC     WITH _cVENDESC  		   // Vendedor
		Replace _REDE            WITH SZ7->Z7_REDE      //  Rede que o Cliente pertence
		Replace _CLIENTE       WITH _cCLIENTE          // Quebra - Cliente
		Replace _CLIDESC       WITH _cCLINOME          // Quebra - Cliente
		Replace _LOJA            WITH SZ7->Z7_LOJA      // Quebra - Loja
	Endif

	If SZ7->Z7_PESTOT > 0
		If REL1->_IPT <> 0
			_nCalVlr1 := ((REL1->_IPT * REL1->_PESOTOT) + (SZ7->Z7_IPT * SZ7->Z7_PESTOT ))
			_nCalQtd1 := (REL1->_PESOTOT  + SZ7->Z7_PESTOT)
			//_nVlr_IPT := round((_nCalVlr1 / _nCalQtd1),3)
			_nVlr_IPT := (_nCalVlr1 / _nCalQtd1)		
		Else
			_nVlr_IPT := SZ7->Z7_IPT
		Endif
		If REL1->_IPG <> 0
			_nCalVlr2 := ((REL1->_IPG * REL1->_PESOTOT) + (SZ7->Z7_IPG * SZ7->Z7_PESTOT))
			_nCalQtd2 := (REL1->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPG := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPG :=  (_nCalVlr2 / _nCalQtd2)		
		Else
			_nVlr_IPG := SZ7->Z7_IPG
		Endif
		If REL1->_IPS <> 0
			_nCalVlr3 := ((REL1->_IPS * REL1->_PESOTOT) + (SZ7->Z7_IPS * SZ7->Z7_PESTOT))
			_nCalQtd3 := (REL1->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPS := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPS :=  (_nCalVlr3 / _nCalQtd3)		
		Else
			_nVlr_IPS := SZ7->Z7_IPS
		Endif
		
		// Faco somatoria para fazer indice ponderado
		_TotPesInd := _TotPesInd + SZ7->Z7_PESTOT
	Endif

	Replace _CT        WITH _CT   + SZ7->Z7_CT    // Clientes Total
	Replace _INAT      WITH _INAT + SZ7->Z7_INAT  // Clientes Inativos
	Replace _FMA0      WITH _FMA0 + SZ7->Z7_FMA0  // Frequencia > 0
	Replace _F0        WITH _F0   + SZ7->Z7_F0    // Frequencia = 0
	Replace _F1        WITH _F1   + SZ7->Z7_F1    // Frequencia = 1
	Replace _FMA1      WITH _FMA1 + SZ7->Z7_FMA1  // Frequencia > 1
	Replace _NUMREDES  WITH _NUMREDES + _nLoja     // Numero de Lojas da Rede
	If _nVlr_IPT <> 0 .and.  _nVlr_IPT  < 9.999
		Replace _IPT       WITH _nVlr_IPT    // Indices IPT
	Endif
	If _nVlr_IPG <> 0 .and.  _nVlr_IPG  < 9.999
		Replace _IPG       WITH _nVlr_IPG    // Indices IPG
	Endif
	If _nVlr_IPS <> 0 .and.  _nVlr_IPS < 9.999
		Replace _IPS       WITH _nVlr_IPS    // Indices IPS
	Endif
	Replace _FREQUE    WITH _FREQUE + SZ7->Z7_FREQUE  // Frequencia
	Replace _PRAZOMED  WITH ((_PRAZOMED  * _VALORFAT) +(SZ7->Z7_PRZMED *SZ7->Z7_VLRFAT))/ (_VALORFAT+SZ7->Z7_VLRFAT) // Prazo Medio
	Replace _GRUPOPROD WITH SZ7->Z7_GRUPO     // Grupo Produto
	//Replace _DESCGRUPO WITH SZ7->Z7_DESCGRP   // Descricao Grupo Produto
	Replace _GRUPO01   WITH _GRUPO01 + SZ7->Z7_QTGP01  // Qtd Faturada - Grupo do 1o. parametro
	Replace _GRUPO02   WITH _GRUPO02 + SZ7->Z7_QTGP02  // Qtd Faturada - Grupo do 2o. parametro
	Replace _GRUPO03   WITH _GRUPO03 + SZ7->Z7_QTGP03  // Qtd Faturada - Grupo do 3o. parametro
	Replace _GRUPO04   WITH _GRUPO04 + SZ7->Z7_QTGP04  // Qtd Faturada - Grupo do 4o. parametro
	Replace _GRUPO05   WITH _GRUPO05 + SZ7->Z7_QTGP05  // Qtd Faturada - Grupo do 5o. parametro
	Replace _GRUPO06   WITH _GRUPO06 + SZ7->Z7_QTGP06  // Qtd Faturada - Grupo do 6o. parametro
	Replace _GRUPO07   WITH _GRUPO07 + SZ7->Z7_QTGP07  // Qtd Faturada - Grupo do 7o. parametro
	Replace _GRUPO08   WITH _GRUPO08 + SZ7->Z7_QTGP08  // Qtd Faturada - Grupo do 8o. parametro
	Replace _GRUPO09   WITH _GRUPO09 + SZ7->Z7_QTGP09  // Qtd Faturada - Grupo do 9o. parametro
	Replace _GRUPO10   WITH _GRUPO10 + SZ7->Z7_QTGP10  // Qtd Faturada - Grupo do 10o. parametro
	Replace _GRUPO11   WITH _GRUPO11 + SZ7->Z7_QTGP11  // Qtd Faturada - Grupo do 11o. parametro
	Replace _GRUPO12   WITH _GRUPO12 + SZ7->Z7_QTGP12  // Qtd Faturada - Grupo do 12o. parametro
	Replace _GRUPO13   WITH _GRUPO13 + SZ7->Z7_QTGP13  // Qtd Faturada - Grupo do 13o. parametro
	Replace _GRUPO14   WITH _GRUPO14 + SZ7->Z7_QTGP14  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO15   WITH _GRUPO15 + SZ7->Z7_QTGP15  // Qtd Faturada - Grupo do 14o. parametro
	If (SZ7->Z7_PESTOT  + SZ7->Z7_VLRFAT)  > 0
		If SZ7->Z7_VLR01 <> 0
			Replace _PRECO01   WITH ((_PRECO01 * _QTDPO01)+SZ7->Z7_VLR01) /(_QTDPO01 + SZ7->Z7_QTD01)   // Preco Medio  - Grupo do 1o. parametro
			Replace _VLRPO01   WITH (_VLRPO01 + SZ7->Z7_VLR01)
			Replace	_QTDPO01   WITH (_QTDPO01 + SZ7->Z7_QTD01)
		Endif
		If SZ7->Z7_VLR02 <> 0
			Replace _PRECO02   WITH ((_PRECO02 * _QTDPO02)+SZ7->Z7_VLR02) /(_QTDPO02 + SZ7->Z7_QTD02)   // Preco Medio  - Grupo do 2o. parametro
			Replace _VLRPO02   WITH (_VLRPO02 + SZ7->Z7_VLR02)
			Replace	_QTDPO02   WITH (_QTDPO02 + SZ7->Z7_QTD02)
		Endif
		If SZ7->Z7_VLR03 <> 0
			Replace _PRECO03   WITH ((_PRECO03 * _QTDPO03)+SZ7->Z7_VLR03) /(_QTDPO03 + SZ7->Z7_QTD03)   // Preco Medio  - Grupo do 3o. parametro
			Replace _VLRPO03   WITH (_VLRPO03 + SZ7->Z7_VLR03)
			Replace	_QTDPO03   WITH (_QTDPO03 + SZ7->Z7_QTD03)
		Endif
		If SZ7->Z7_VLR04 <> 0
			Replace _PRECO04   WITH ((_PRECO04 * _QTDPO04)+SZ7->Z7_VLR04) /(_QTDPO04 + SZ7->Z7_QTD04)   // Preco Medio  - Grupo do 4o. parametro
			Replace _VLRPO04   WITH (_VLRPO04 + SZ7->Z7_VLR04)
			Replace	_QTDPO04   WITH (_QTDPO04 + SZ7->Z7_QTD04)
		Endif
		If SZ7->Z7_VLR05 <> 0
			Replace _PRECO05   WITH ((_PRECO05 * _QTDPO05)+SZ7->Z7_VLR05) /(_QTDPO05 + SZ7->Z7_QTD05)   // Preco Medio  - Grupo do 5o. parametro
			Replace _VLRPO05   WITH (_VLRPO05 + SZ7->Z7_VLR05)
			Replace	_QTDPO05   WITH (_QTDPO05 + SZ7->Z7_QTD05)
		Endif
		If SZ7->Z7_VLR06 <> 0
			Replace _PRECO06   WITH ((_PRECO06 * _QTDPO06)+SZ7->Z7_VLR06) /(_QTDPO06 + SZ7->Z7_QTD06)   // Preco Medio  - Grupo do 6o. parametro
			Replace _VLRPO06   WITH (_VLRPO06 + SZ7->Z7_VLR06)
			Replace	_QTDPO06   WITH (_QTDPO06 + SZ7->Z7_QTD06)
		Endif
		If SZ7->Z7_VLR07 <> 0
			Replace _PRECO07   WITH ((_PRECO07 * _QTDPO07)+SZ7->Z7_VLR07) /(_QTDPO07 + SZ7->Z7_QTD07)   // Preco Medio  - Grupo do 7o. parametro
			Replace _VLRPO07   WITH (_VLRPO07 + SZ7->Z7_VLR07)
			Replace	_QTDPO07   WITH (_QTDPO07 + SZ7->Z7_QTD07)
		Endif
		If SZ7->Z7_VLR08 <> 0
			Replace _PRECO08   WITH ((_PRECO08 * _QTDPO08)+SZ7->Z7_VLR08) /(_QTDPO08 + SZ7->Z7_QTD08)   // Preco Medio  - Grupo do 8o. parametro
			Replace _VLRPO08   WITH (_VLRPO08 + SZ7->Z7_VLR08)
			Replace	_QTDPO08   WITH (_QTDPO08 + SZ7->Z7_QTD08)
		Endif
		If SZ7->Z7_VLR09 <> 0
			Replace _PRECO09   WITH ((_PRECO09 * _QTDPO09)+SZ7->Z7_VLR09) /(_QTDPO09 + SZ7->Z7_QTD09)  // Preco Medio  - Grupo do 9o. parametro
			Replace _VLRPO09   WITH (_VLRPO09 + SZ7->Z7_VLR09)
			Replace	_QTDPO09   WITH (_QTDPO09 + SZ7->Z7_QTD09)
		Endif
		If SZ7->Z7_VLR10 <> 0
			Replace _PRECO10   WITH ((_PRECO10 * _QTDPO10)+SZ7->Z7_VLR10) /(_QTDPO10 + SZ7->Z7_QTD10)   // Preco Medio  - Grupo do 10o. parametro
			Replace _VLRPO10   WITH (_VLRPO10 + SZ7->Z7_VLR10)
			Replace	_QTDPO10   WITH (_QTDPO10 + SZ7->Z7_QTD10)
		Endif
		If SZ7->Z7_VLR11 <> 0
			Replace _PRECO11   WITH ((_PRECO11 * _QTDPO11)+SZ7->Z7_VLR11) /(_QTDPO11 + SZ7->Z7_QTD11)  // Preco Medio  - Grupo do 11o. parametro
			Replace _VLRPO11   WITH (_VLRPO11 + SZ7->Z7_VLR11)
			Replace	_QTDPO11   WITH (_QTDPO11 + SZ7->Z7_QTD11)
		Endif
		If SZ7->Z7_VLR12 <> 0
			Replace _PRECO12   WITH ((_PRECO12 * _QTDPO12)+SZ7->Z7_VLR12) /(_QTDPO12 + SZ7->Z7_QTD12)  // Preco Medio  - Grupo do 12o. parametro
			Replace _VLRPO12   WITH (_VLRPO12 + SZ7->Z7_VLR12)
			Replace	_QTDPO12   WITH (_QTDPO12 + SZ7->Z7_QTD12)
		Endif
		If SZ7->Z7_VLR13 <> 0
			Replace _PRECO13   WITH ((_PRECO13 * _QTDPO13)+SZ7->Z7_VLR13) /(_QTDPO13 + SZ7->Z7_QTD13)  // Preco Medio  - Grupo do 13o. parametro
			Replace _VLRPO13   WITH (_VLRPO13 + SZ7->Z7_VLR13)
			Replace	_QTDPO13   WITH (_QTDPO13 + SZ7->Z7_QTD13)
		Endif
		If SZ7->Z7_VLR14 <> 0
			Replace _PRECO14   WITH ((_PRECO14 * _QTDPO14)+SZ7->Z7_VLR14) /(_QTDPO14 + SZ7->Z7_QTD14)  // Preco Medio  - Grupo do 14o. parametro
			Replace _VLRPO14   WITH (_VLRPO14 + SZ7->Z7_VLR14)
			Replace	_QTDPO14   WITH (_QTDPO14 + SZ7->Z7_QTD14)
		Endif
		If SZ7->Z7_VLR15 <> 0
			Replace _PRECO15   WITH ((_PRECO15 * _QTDPO15)+SZ7->Z7_VLR15) /(_QTDPO15 + SZ7->Z7_QTD15)   // Preco Medio  - Grupo do 15o. parametro
			Replace _VLRPO15   WITH (_VLRPO15 + SZ7->Z7_VLR15)
			Replace	_QTDPO15   WITH (_QTDPO15 + SZ7->Z7_QTD15)
		Endif
		If SZ7->Z7_VLR16 <> 0
			Replace _PRECO16   WITH ((_PRECO16 * _QTDPO16)+SZ7->Z7_VLR16) /(_QTDPO16 + SZ7->Z7_QTD16)  // Preco Medio  - Grupo do 16o. parametro
			Replace _VLRPO16   WITH (_VLRPO16 + SZ7->Z7_VLR16)
			Replace	_QTDPO16   WITH (_QTDPO16 + SZ7->Z7_QTD16)
		Endif
		If SZ7->Z7_VLR17 <> 0
			Replace _PRECO17   WITH ((_PRECO17 * _QTDPO17)+SZ7->Z7_VLR17) /(_QTDPO17 + SZ7->Z7_QTD17)  // Preco Medio  - Grupo do 17o. parametro
			Replace _VLRPO17   WITH (_VLRPO17 + SZ7->Z7_VLR17)
			Replace	_QTDPO17   WITH (_QTDPO17 + SZ7->Z7_QTD17)
		Endif
		If SZ7->Z7_VLR18 <> 0
			Replace _PRECO18   WITH ((_PRECO18 * _QTDPO18)+SZ7->Z7_VLR18) /(_QTDPO18 + SZ7->Z7_QTD18)   // Preco Medio  - Grupo do 18o. parametro
			Replace _VLRPO18   WITH (_VLRPO18 + SZ7->Z7_VLR18)
			Replace	_QTDPO18   WITH (_QTDPO18 + SZ7->Z7_QTD18)
		Endif
		If SZ7->Z7_VLR19 <> 0
			Replace _PRECO19   WITH ((_PRECO19 * _QTDPO19)+SZ7->Z7_VLR19) /(_QTDPO19 + SZ7->Z7_QTD19)   // Preco Medio  - Grupo do 19o. parametro
			Replace _VLRPO19   WITH (_VLRPO19 + SZ7->Z7_VLR19)
			Replace	_QTDPO19   WITH (_QTDPO19 + SZ7->Z7_QTD19)
		Endif
		If SZ7->Z7_VLR20 <> 0
			Replace _PRECO20   WITH ((_PRECO20 * _QTDPO20)+SZ7->Z7_VLR20) / (_QTDPO20 + SZ7->Z7_QTD20)   // Preco Medio  - Grupo do 20o. parametro
			Replace _VLRPO20   WITH (_VLRPO20 + SZ7->Z7_VLR20)
			Replace	_QTDPO20   WITH (_QTDPO20 + SZ7->Z7_QTD20)
		Endif
	Endif
	Replace _PESOTOT   WITH _PESOTOT   + SZ7->Z7_PESTOT  // Peso Total
	Replace _VALORFAT  WITH _VALORFAT  + SZ7->Z7_VLRFAT  // Faturamento
	Replace _PERCFAT   WITH _VALORFAT / _nToTTVLRFAT * 100        // Peso Total
	Replace _VALORPED  WITH _VALORFAT / _FREQUE    // PEDIDO - Valor
	Replace _PESOPED   WITH _PESOTOT  / _FREQUE    // PEDIDO - Peso


	Return


	//*********************
	// 2 Impressao
	//*********************

	Static Function Cliaimp2()

	/*/
	//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	//±±³Fun‡ao    ³Impressao ³ Autor ³ Rogerio  Nutti/Werner ³ Data ³          ³±±
	//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	//±±³Descri‡ao ³ Gera dados para Impressao dos 3 Layouts de Clientes Ativos ³±±
	//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	//±±³ Uso      ³ Espec¡fico ADORO ALIMENTICIA                               ³±±
	//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	//±±³Observacao³ Inicio em Outubro/2002                                     ³±±
	//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	//
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Clientes Ativos por Vendedor (Regiao)"
	Local cPict          := ""
	Local titulo         := "Clientes Ativos por Vendedor (Regiao)"
	Local nLin           := 64
	Local Cabec1         := "Clientes Ativos por Vendedor (Regiao)"
	Local Cabec2         := "Clientes Ativos por Vendedor (Regiao)"



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo TEMPORARIO (Para Impressao)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_aCampos := {}
	Aadd( _aCampos, {"_SEQRELA","C",27,0} )  // Sequencia do Relatorio
	Aadd( _aCampos, {"_DATAINI","D",27,0} )  //    Data Inicial
	Aadd( _aCampos, {"_DATAFIM","D",27,0} )  //    Data Final
	Aadd( _aCampos, {"_SEGMERC","C",03,0} )  // Segmento de Mercado
	Aadd( _aCampos, {"_SEGDESC","C",15,0} )  // Descricao Segmento de Mercado
	Aadd( _aCampos, {"_AGRUPO" ,"C",01,0} )  // Divisao do Segmento
	Aadd( _aCampos, {"_REGIAO" ,"C",06,0} )  // Regiao
	Aadd( _aCampos, {"_REGDESC","C",25,0} )  // Descricao da Regiao
	Aadd( _aCampos, {"_VENDED" ,"C",06,0} )  // Vendedor
	Aadd( _aCampos, {"_VENDESC","C",25,0} )  // Vendedor
	Aadd( _aCampos, {"_REDE"   ,"C",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_NUMREDE","N",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_CLIENTE","C",06,0} )  // Quebra - Cliente
	Aadd( _aCampos, {"_LOJA"   ,"C",02,0} )  // Quebra - Loja
	Aadd( _aCampos, {"_CLIDESC","C",35,0} )  // Quebra - Cliente
	Aadd( _aCampos, {"_NUMREDES" ,"N",05,0} )  // Numero de Redes
	Aadd( _aCampos, {"_CT"     ,"N",04,0} )  // Clientes Total
	Aadd( _aCampos, {"_INAT"   ,"N",04,0} )  // Clientes Inativos
	Aadd( _aCampos, {"_FMA0"   ,"N",04,0} )  // Frequencia > 0
	Aadd( _aCampos, {"_F0"     ,"N",04,0} )  // Frequencia = 0
	Aadd( _aCampos, {"_F1"     ,"N",04,0} )  // Frequencia = 1
	Aadd( _aCampos, {"_FMA1"   ,"N",04,0} )  // Frequencia > 1
	Aadd( _aCampos, {"_IPT"    ,"N",07,4} )  // Indices IPT
	Aadd( _aCampos, {"_IPG"    ,"N",07,4} )  // Indices IPG
	Aadd( _aCampos, {"_IPS"    ,"N",07,4} )  // Indices IPS
	Aadd( _aCampos, {"_VALORPED" ,"N",14,2} )  // PEDIDO - Valor
	Aadd( _aCampos, {"_PESOPED" ,"N",09,0} )  // PEDIDO - Peso
	Aadd( _aCampos, {"_FREQUE" ,"N",06,1} )  // Frequencia
	Aadd( _aCampos, {"_VALORFAT" ,"N",14,2} )  // Faturamento
	Aadd( _aCampos, {"_PRAZOMED" ,"N",07,2} )  // Prazo Medio
	//Aadd( _aCampos, {"_PRAZOMED" ,"N",05,2} )  // Prazo Medio
	Aadd( _aCampos, {"_PESOTOT" ,"N",09,0} )  // Peso Total
	Aadd( _aCampos, {"_PERCFAT" ,"N",09,4} )  // Peso Total
	Aadd( _aCampos, {"_GRUPOPROD"  ,"C",04,0} )  // Grupo Produto
	Aadd( _aCampos, {"_DESCGRUPO","C",04,0} )  // Descricao Grupo Produto
	Aadd( _aCampos, {"_TOTGRUP1" ,"N",14,0} ) // Total Grupo um - Grupo do 1o. parametro
	Aadd( _aCampos, {"_TOTGRUP2" ,"N",14,0} ) // Total Grupo dois - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO01" ,"N",14,0} ) // Qtd Faturada - Grupo do 1o. parametro
	Aadd( _aCampos, {"_GRUPO02" ,"N",14,0} ) // Qtd Faturada - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO03" ,"N",14,0} ) // Qtd Faturada - Grupo do 3o. parametro
	Aadd( _aCampos, {"_GRUPO04" ,"N",14,0} ) // Qtd Faturada - Grupo do 4o. parametro
	Aadd( _aCampos, {"_GRUPO05" ,"N",14,0} ) // Qtd Faturada - Grupo do 5o. parametro
	Aadd( _aCampos, {"_GRUPO06" ,"N",14,0} ) // Qtd Faturada - Grupo do 6o. parametro
	Aadd( _aCampos, {"_GRUPO07" ,"N",14,0} ) // Qtd Faturada - Grupo do 7o. parametro
	Aadd( _aCampos, {"_GRUPO08" ,"N",14,0} ) // Qtd Faturada - Grupo do 8o. parametro
	Aadd( _aCampos, {"_GRUPO09" ,"N",14,0} ) // Qtd Faturada - Grupo do 9o. parametro
	Aadd( _aCampos, {"_GRUPO10" ,"N",14,0} ) // Qtd Faturada - Grupo do 10o. parametro
	Aadd( _aCampos, {"_GRUPO11" ,"N",14,0} ) // Qtd Faturada - Grupo do 11o. parametro
	Aadd( _aCampos, {"_GRUPO12" ,"N",14,0} ) // Qtd Faturada - Grupo do 12o. parametro
	Aadd( _aCampos, {"_GRUPO13" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO14" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO15" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_PRECO01" ,"N",12,4} ) // Preco Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_PRECO02" ,"N",12,4} ) // Preco Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_PRECO03" ,"N",12,4} ) // Preco Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_PRECO04" ,"N",12,4} ) // Preco Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_PRECO05" ,"N",12,4} ) // Preco Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_PRECO06" ,"N",12,4} ) // Preco Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_PRECO07" ,"N",12,4} ) // Preco Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_PRECO08" ,"N",12,4} ) // Preco Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_PRECO09" ,"N",12,4} ) // Preco Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_PRECO10" ,"N",12,4} ) // Preco Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_PRECO11" ,"N",12,4} ) // Preco Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_PRECO12" ,"N",12,4} ) // Preco Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_PRECO13" ,"N",12,4} ) // Preco Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_PRECO14" ,"N",12,4} ) // Preco Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_PRECO15" ,"N",12,4} ) // Preco Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_PRECO16" ,"N",12,4} ) // Preco Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_PRECO17" ,"N",12,4} ) // Preco Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_PRECO18" ,"N",12,4} ) // Preco Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_PRECO19" ,"N",12,4} ) // Preco Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_PRECO20" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPO01" ,"N",14,4} ) // VLRPo Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_VLRPO02" ,"N",14,4} ) // VLRPo Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_VLRPO03" ,"N",14,4} ) // VLRPo Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_VLRPO04" ,"N",14,4} ) // VLRPo Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_VLRPO05" ,"N",14,4} ) // VLRPo Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_VLRPO06" ,"N",14,4} ) // VLRPo Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_VLRPO07" ,"N",14,4} ) // VLRPo Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_VLRPO08" ,"N",14,4} ) // VLRPo Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_VLRPO09" ,"N",14,4} ) // VLRPo Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_VLRPO10" ,"N",14,4} ) // VLRPo Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_VLRPO11" ,"N",14,4} ) // VLRPo Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_VLRPO12" ,"N",14,4} ) // VLRPo Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_VLRPO13" ,"N",14,4} ) // VLRPo Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_VLRPO14" ,"N",14,4} ) // VLRPo Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_VLRPO15" ,"N",14,4} ) // VLRPo Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_VLRPO16" ,"N",14,4} ) // VLRPo Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_VLRPO17" ,"N",14,4} ) // VLRPo Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_VLRPO18" ,"N",14,4} ) // VLRPo Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_VLRPO19" ,"N",14,4} ) // VLRPo Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_VLRPO20" ,"N",14,4} ) // VLRPo Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPO01" ,"N",14,4} ) // VLRPo Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_QTDPO02" ,"N",14,4} ) // VLRPo Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_QTDPO03" ,"N",14,4} ) // VLRPo Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_QTDPO04" ,"N",14,4} ) // VLRPo Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_QTDPO05" ,"N",14,4} ) // VLRPo Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_QTDPO06" ,"N",14,4} ) // VLRPo Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_QTDPO07" ,"N",14,4} ) // VLRPo Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_QTDPO08" ,"N",14,4} ) // VLRPo Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_QTDPO09" ,"N",14,4} ) // VLRPo Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_QTDPO10" ,"N",14,4} ) // VLRPo Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_QTDPO11" ,"N",14,4} ) // VLRPo Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_QTDPO12" ,"N",14,4} ) // VLRPo Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_QTDPO13" ,"N",14,4} ) // VLRPo Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_QTDPO14" ,"N",14,4} ) // VLRPo Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_QTDPO15" ,"N",14,4} ) // VLRPo Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_QTDPO16" ,"N",14,4} ) // VLRPo Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_QTDPO17" ,"N",14,4} ) // VLRPo Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_QTDPO18" ,"N",14,4} ) // VLRPo Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_QTDPO19" ,"N",14,4} ) // VLRPo Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_QTDPO20" ,"N",14,4} ) // VLRPo Medio  - Grupo do 20o. parametro




	_cIndex   := "_SEGMERC + _REGIAO + _VENDED +_SEQRELA"
	_cFileREL := CriaTrab(_aCampos,.T.)
	dbUseArea(.T.,,_cFileREL,"REL2",.T.,.F.)
	IndRegua( "REL2", _cFileREL, _cIndex,,,"Criando Indice ..." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo Temporario  e Grava o de Impressao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
	//³ CLIAT1   ¦ mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par08       ¦ Da Divisao  ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par09       ¦ Ate Divisao ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par12       ¦ Do Vendedor  F2_VEND1          ³
	//³ CLIAT1   ¦ mv_par13       ¦ Ate Vendedor F2_VEND1          ³
	//

	_cSegTAnt := space(3)
	_cRegAnt  := space(6)
	_cVendAnt := space(6)
	_TotFatInd:=0

	_nRegTVLRFAT  := 0
	_nTotPesInd := 0
	_nSomGrp001 := 0
	_nSomGrp002 := 0
	_nSomGrp003 := 0
	_nSomGrp004 := 0
	_nSomGrp005 := 0
	_nSomGrp006 := 0
	_nSomGrp007 := 0
	_nSomGrp008 := 0
	_nSomGrp009 := 0
	_nSomGrp010 := 0
	_nSomGrp011 := 0
	_nSomGrp012 := 0
	_nSomGrp013 := 0
	_nSomGrp014 := 0
	_nSomGrp015 := 0
	_nSomGrp016 := 0
	_nSomGrp017 := 0
	_nSomGrp018 := 0
	_nSomGrp019 := 0
	_nSomGrp020 := 0

	dbSelectArea("SZ7")
	dbSetOrder(2)
	Processa({|| RunImp2()},"2-Calculando Total de Faturamento para Clientes Ativos ...")

	Static Function RunImp2()

	dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_LOTE+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
	dbSetOrder(3)


	ProcRegua(RecCount())
	dbGoTop()
	DbSeek(xFilial("SZ7")+_cLoteCli)
	Do While !Eof() .AND. Z7_LOTE = _cLoteCli
		IncProc('Totalizando Faturamento do Periodo')
		If SZ7->Z7_SEGMERC >= mv_par06  .AND.  SZ7->Z7_SEGMERC <= mv_par07
			If SZ7->Z7_REGIAO  >= mv_par10  .AND.  SZ7->Z7_REGIAO <= mv_par11
				If SZ7->Z7_VENDED  >=  mv_par12  .AND.  SZ7->Z7_VENDED <= mv_par11
					If SZ7->Z7_SEGMERC <> _cSegTAnt .and. SZ7->Z7_REGIAO <> _cRegAnt .and. SZ7->Z7_VENDED <> _cVendAnt
						_TotFatInd  := 0
						
						_nPESIT01 := 0
						_nPESIT02 := 0
						_nPESIT03 := 0
						_nPESIT04 := 0
						_nPESIT05 := 0
						_nPESIT06 := 0
						_nPESIT07 := 0
						_nPESIT08 := 0
						_nPESIT09 := 0
						_nPESIT10 := 0
						_nPESIT11 := 0
						_nPESIT12 := 0
						_nPESIT13 := 0
						_nPESIT14 := 0
						_nPESIT15 := 0
					Endif
					_cSEGMERC := SZ7->Z7_SEGMERC
					_cREGIAO  := SZ7->Z7_REGIAO
					_cVENDED  := SZ7->Z7_VENDED
					_cCLIENTE := SZ7->Z7_CLIENTE
					_cVENDED  := SZ7->Z7_VENDED
					_cVENDESC := SZ7->Z7_VENDESC
					_nLoja	  := 0
					// Opcoes para impressao
					//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
					//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
					//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
					// Conforme tipo de relatorio solicitado
					// Resumo dos Segmento que e o sintetivo de cada Regiao como quebra o Segmento
					// Analitico de Cada Vendedor temdo como detalhe o Cliente
					// Faco uma outra jogada para agrupar a loja que controla rede
					_cCtrCliente := '00000000'   // 8 Carac.
					_cCLIENTE    := space(6)
					_cCLINOME    := space(6)
					_cSeqOrder   := '000'  // space(3)
					_cSeqInvert  := _cSeqOrder + SZ7->Z7_SEGMERC + SZ7->Z7_REGIAO + _cCtrCliente
					// //                  3                 3                6               8     = 20
					// Monto a chave conforme o tipo de cliente
					_cTrIndice := _cSeqInvert
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava arquivo Temporario de Impressao                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Neste Caso grava as redes totalizadas
					If SZ7->Z7_VLRFAT > 0
						Grav_Arq2()
					Endif
					_cSegTAnt := SZ7->Z7_SEGMERC
					_cRegAnt  := SZ7->Z7_REGIAO
					_cVendAnt := SZ7->Z7_VENDED
				Endif
			Endif
		Endif
		dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
		dbSkip()
	Enddo
	If MV_PAR17 = 1
		// Apos gerar arquivo verifica se faz uma copia
		_cData     := dtos( dDataBase )
		_cArqOrig  := _cDirOrig := "\SIGAADV\"+_cFileREL + GetDBExtension()
		//*******************************************************
		_cTime  := substr(time(),4,2)+substr(time(),7,1)
		_cLabel := 'R'+substr( _cData , 5 , 4 ) +_cTime + GetDBExtension()
		If empty(MV_PAR18)
			_cDire = "C:\"
		Else
			_cDire =alltrim(MV_PAR18)
		Endif
		_cDestin := _cDire+_cLabel    // "C:\xxxx\yyy\"+nome
		dbSelectArea("REL2")
		dbGoTop()
		Copy File &(_cArqOrig) To  &(_cDestin)    // Copy to &_cDestin
		
		// Copy File &(_cArqOrig) To &(_cArqDest)
		//*******************************************************
		
	Endif

	// Impressao dos Relatorios ....
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³

	// Carrego Matriz dos Nomes dos Grupos
	_mGrupoPrd  :={}        //  //   Gerar uma matriz para os grupos de pesos
	_mGrupoPrc  :={}         //  //   Gerar uma matriz para os grupos de precos
	dbSelectArea("SBM")
	dbSetOrder(1)
	//Processa({|| RunNomGr1()},"Gera matriz dos grupo e sub-grupo dos produtos ...")
	//Return

	//Static Function RunNomGr1()

	//ProcRegua(RecCount())
	dbGoTop()
	_nSeqMatrPes := 1             //   Controla a sequencia de Pesos
	Do While _nSeqMatrPes <= 80 //50  //30
		AADD(_mGrupoPrd,{_nSeqMatrPes,'      ','      '})
		AADD(_mGrupoPrc,{_nSeqMatrPes,'       ','       '})
		_nSeqMatrPes   := _nSeqMatrPes  + 1      //   Controla a sequencia de Pesos
	Enddo
	_nSeqMatrPes   := 1            //   Controla a sequencia de Pesos
	_nSeqMatrPrc   := 1            //   Controla a sequencia de Preços
	// Atualizo Matriz de Peso
	_cIndTrab1  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab1 ,"strzero(SBM->BM_Ctrpes,2)",,,' Criando Indice de Usuario')
	_nIndex1 := RetIndex('SBM')+1
	DbsetOrder(_nIndex1)
	dbGoTop()
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPes > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPes < 80 //50 //30     // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrd,{|x| x[1]==SBM->BM_Ctrpes } )
				If _cPosMatrz = 0
					_cPosMatrz := SBM->BM_Ctrpes
				Endif
				_mGrupoPrd[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,6)
				_mGrupoPrd[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,6)
				_nSeqMatrPes := _nSeqMatrPes + 1
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo
	dbGoTop()
	_cIndTrab2  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab2 ,"strzero(SBM->BM_CtrPrc,2)",,,' Criando Indice de Usuario')
	_nIndex2 := RetIndex('SBM')+1
	DbsetOrder(_nIndex2)
	dbGoTop()
	// Atualizo Matriz de Preco
	_nSeqMatrPrc := 1
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPrc > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPrc  < 80 //50 //30    // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrd,{|x| x[1]==SBM->BM_Ctrprc } )
				If _cPosMatrz = 0
					_cPosMatrz   := SBM->BM_Ctrprc
					_nSeqMatrPrc := _nSeqMatrPrc + 1
				Endif
				_mGrupoPrc[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,7)
				_mGrupoPrc[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,7)
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo a Tabela de  Regiao para Peso                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Forco um filtro por Regiao  Conforme Parmetro
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO         ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO         ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SZP010 para buscar dados da Regiao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZP")
	dbSetOrder(1)         // A3_FILIAL+A3_REGIAO
	dbGoTop()
	Do While !Eof()
		_cCodRegiao = SZP->ZP_CODIGO
		If SZP->ZP_CODIGO < mv_par10 .OR. SZP->ZP_CODIGO > mv_par11
			dbSkip()
			Loop
		Endif
		// Apenas os que fazem parte da regiao analizada
		//  ¦ 1 - Resumo - Todos Segmentos
		//   Imprime 1-Qtde / 2-Precos Med  ³
		li        := 80
		If mv_par15 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			Impr_Rel2()
		Endif
		dbSelectArea("SZP")
		dbSkip()
	Enddo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo a Tabela de  Regiao para Preco                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Forco um filtro por Regiao  Conforme Parmetro
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO         ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO         ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SZP010 para buscar dados da Regiao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZP")
	dbSetOrder(1)         // A3_FILIAL+A3_REGIAO
	dbGoTop()
	Do While !Eof()
		_cCodRegiao = SZP->ZP_CODIGO
		If SZP->ZP_CODIGO < mv_par10 .OR. SZP->ZP_CODIGO > mv_par11
			dbSkip()
			Loop
		Endif
		// Apenas os que fazem parte da regiao analizada
		//  ¦ 1 - Resumo - Todos Segmentos
		//   Imprime 1-Qtde / 2-Precos Med  ³
		li         := 80
		If mv_par16 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			Impr_Rel2a()
		Endif
		dbSelectArea("SZP")
		dbSkip()
	Enddo

	Return

	// Funcao de Impressao da Quantidades

	//***********
	Static Function Impr_Rel2()
	//
	//   Impressao
	_cTipoRel  := "( QUANTIDADE FATURADA (PESO) )"
	titulo    :="CLASSIFICACAO DOS CLIENTES ATIVOS POR VENDEDOR (QUANTIDADE)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	// Zero as Variaveis
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_nNUMREDES := 0
	_PrzMed := 0
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nGRUP01   := 0
	_nGRUP02 := 0
	_nGRUP03 := 0
	_nGRUP04 := 0
	_nGRUP05 := 0
	_nGRUP06 := 0
	_nGRUP07 := 0
	_nGRUP08 := 0
	_nGRUP09 := 0
	_nGRUP10 := 0
	_nGRUP11 := 0
	dbSelectArea("REL2")
	dbSetOrder(1)
	dbGoTop()
	Do While !Eof()
		// // // //
		If REL2->_REGIAO  == _cCodRegiao
			// So imprime se for clientes
			// Frequencia do Cliente
			_nCT        := REL2->_CT   + _nCT
			_nINAT     := REL2->_INAT + _nINAT
			_nFMA0   := REL2->_FMA0 + _nFMA0
			_nF0        := REL2->_F0   + _nF0
			_nF1        := REL2->_F1   + _nF1
			_nFMA1   := REL2->_FMA1 + _nFMA1
			_nNUMREDES := REL2->_NUMREDES + _nNUMREDES
			// // //
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			If li > 64
				Li := 8
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM )  +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				
				@ Li,001 PSAY "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001 PSAY "|"
				@ Li,04        PSAY "REGIAO DE VENDAS: " +REL2->_REGIAO + REL2->_REGDESC
				@ Li,209 PSAY "Impr_Rel2"
				@ Li,220 PSAY "|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|********************|*********************|*****|**************|*****|*********|*************************"+_cTipoRel+"****************************|"
				Li := Li + 1
				@ Li,001 PSAY "|                             |    |    |    |    |    |       INDICES      |  PEDIDO    MEDIO    |     |    FATURA-   |  %  |  PESO   |  SUB TOTAL  |"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				_cBMTTH1 = 'GRUPO1'
				_cBMTTH2 = 'GRUPO2'
				_cBMGp01 = (_mGrupoPrd[1,3])
				_cBMGp02 = (_mGrupoPrd[2,3])
				_cBMGp03 = (_mGrupoPrd[3,3])
				_cBMGp04 = (_mGrupoPrd[4,3])
				_cBMGp05 = (_mGrupoPrd[5,3])
				_cBMGp06 = (_mGrupoPrd[6,3])
				_cBMGp07 = (_mGrupoPrd[7,3])
				_cBMGp08 = (_mGrupoPrd[8,3])
				_cBMGp09 = (_mGrupoPrd[9,3])
				_cBMGp10 = (_mGrupoPrd[10,3])
				
				Li := Li + 1
					@ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 |MED |  IPT   IPG    IPS  |  VALOR       PESO   |FREQ.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"
				//@ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 |MED |  IPG   IPS    IPR  |  VALOR       PESO   |FREQ.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"  ALEX BORGES 13/03/12
				// @ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 |MED |  SEG   SUP   REG  |  VALOR       PESO   |FREQ.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"
				Li := Li + 1
				@ Li,001 PSAY "|*****************************|****|****|****|****|****|******|******|******|**********|**********|*****|**************|*****|*********|******|******|******|******|******|******|******|******|******|******|******|******|"
				Li := Li + 1
			Endif
			
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL2->_VENDED +' '+SUBSTR(REL2->_VENDESC,1,21)		 // 6 + 1 + 21 = 28
			@ Li,031 PSAY  "|"    + Transform(REL2->_CT , "@E 9999" )
			@ Li,036 PSAY  "|"    + Transform(REL2->_FMA0, "@E 9999" )
			@ Li,041 PSAY  "|"    + Transform(REL2->_F0, "@E 9999" )
			@ Li,046 PSAY  "|"    + Transform(REL2->_F1, "@E 9999" )
			@ Li,051 PSAY  "|"    + Transform(REL2->_PRAZOMED, "@E 9999" )
			@ Li,056 PSAY  "|"    + Transform( REL2->_IPT  , "@E 9.999" )
			@ Li,063 PSAY  "|"    + Transform( REL2->_IPG  , "@E 9.999" )
			@ Li,070 PSAY  "|"    + Transform( REL2->_IPS  , "@E 9.999" )
			
			@ Li,077 PSAY  "|"    + Transform( REL2->_VALORPED  , "@E 999999999")
			@ Li,088 PSAY  "|"    + Transform( REL2->_PESOPED  , "@E 999999999" )
			@ Li,099 PSAY  "|"    + Transform( REL2->_FREQUE  , "@E 9999" )
			@ Li,105 PSAY  "|"    + Transform( REL2->_VALORFAT  , "@E 999999,999,999" )
			@ Li,120 PSAY  "|"    + Transform( (REL2->_VALORFAT /_nToTTVLRFAT)*100 , "@E 999.9" )
			@ Li,126 PSAY  "|"    + Transform( REL2->_PESOTOT  , "@E 99999,999" )
			@ Li,136 PSAY  "|"    + Transform( REL2->_TOTGRUP1 , "@E 999999" )
			@ Li,143 PSAY  "|"    + Transform( REL2->_TOTGRUP2 , "@E 999999" )
			@ Li,150 PSAY  "|"    + Transform( REL2->_GRUPO01  , "@E 999999" )
			@ Li,157 PSAY  "|"    + Transform( REL2->_GRUPO02  , "@E 999999" )
			@ Li,164 PSAY  "|"    + Transform( REL2->_GRUPO03  , "@E 999999" )
			@ Li,171 PSAY  "|"    + Transform( REL2->_GRUPO04  , "@E 999999" )
			@ Li,178 PSAY  "|"    + Transform( REL2->_GRUPO05  , "@E 999999" )
			@ Li,185 PSAY  "|"    + Transform( REL2->_GRUPO06  , "@E 999999" )
			@ Li,192 PSAY  "|"    + Transform( REL2->_GRUPO07  , "@E 999999" )
			@ Li,199 PSAY  "|"    + Transform( REL2->_GRUPO08  , "@E 999999" )
			@ Li,206 PSAY  "|"    + Transform( REL2->_GRUPO09  , "@E 999999" )
			@ Li,213 PSAY  "|"    + Transform( REL2->_GRUPO10  , "@E 999999" )
			@ Li,220 PSAY  "|"
			Li := Li + 1
			
			// Pondero os Indices para o total do relatório
			If (REL2->_PESOTOT + _nPESO) > 0
				If REL2->_IPT > 0
					// A primeira vez assume o valor para calcular o ponderado	
					If _nIPT = 0
						_nCalcQuo := (REL2->_IPT * REL2->_PESOTOT )
					Else
						_nCalcQuo := ((REL2->_IPT * REL2->_PESOTOT ) + (_nIPT * _nPESO))
					Endif
					_nCalcDiv := ((REL2->_PESOTOT + _nPESO))
					//_nIPT     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPT     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL2->_IPG > 0
					// A primeira vez assume o valor para calcular o ponderado	
					If _nIPG = 0
						_nCalcQuo := (REL2->_IPG * REL2->_PESOTOT ) 
					Else
						_nCalcQuo := ((REL2->_IPG * REL2->_PESOTOT ) + (_nIPG * _nPESO))
					Endif				
					_nCalcDiv := ((REL2->_PESOTOT + _nPESO))
					//_nIPG     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPG     :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL2->_IPS > 0
					// A primeira vez assume o valor para calcular o ponderado	
					If _nIPS = 0
						_nCalcQuo := (REL2->_IPS * REL2->_PESOTOT ) 	                
					Else
						_nCalcQuo := ((REL2->_IPS * REL2->_PESOTOT ) + (_nIPS * _nPESO))
					Endif
					_nCalcDiv := ((REL2->_PESOTOT + _nPESO))
					// _nIPS     := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPS     :=  _nCalcQuo / _nCalcDiv
				Endif
				_PrzMed := ((REL2->_PRAZOMED *  REL2->_VALORFAT) + (_PrzMed * _nVLRFAT)) /  (REL2->_VALORFAT + _nVLRFAT)
				//	**	// Faz somatoria dos totais
				_nFREQUE := REL2->_FREQUE   + _nFREQUE
				_nVLRFAT := REL2->_VALORFAT +_nVLRFAT
				_nPESO   := REL2->_PESOTOT  + _nPESO					
			Endif
			//	**	// Faz somatoria dos totais
			///	**	_nPESO   := REL2->_PESOTOT  + _nPESO
			//	**	_nFREQUE := REL2->_FREQUE   + _nFREQUE
			//	**	_nVLRFAT := REL2->_VALORFAT +_nVLRFAT
			If _nVLRFAT > 0
				_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
			Endif
			_nVLRPES = REL2->_PESOPED  + _nVLRPES
			_nVLRPED = REL2->_VALORPED + _nVLRPED
			// Somo as colunas de grupos
			_nTOTGRUP1 = REL2->_TOTGRUP1 + _nTOTGRUP1
			_nTOTGRUP2 = REL2->_TOTGRUP2 + _nTOTGRUP2
			_nGRUP01   = REL2->_GRUPO01 + _nGRUP01
			_nGRUP02 = REL2->_GRUPO02 + _nGRUP02
			_nGRUP03 = REL2->_GRUPO03 + _nGRUP03
			_nGRUP04 = REL2->_GRUPO04 + _nGRUP04
			_nGRUP05 = REL2->_GRUPO05 + _nGRUP05
			_nGRUP06 = REL2->_GRUPO06 + _nGRUP06
			_nGRUP07 = REL2->_GRUPO07 + _nGRUP07
			_nGRUP08 = REL2->_GRUPO08 + _nGRUP08
			_nGRUP09 = REL2->_GRUPO09 + _nGRUP09  //alterado ana, estava grupo incorreto
			_nGRUP10 = REL2->_GRUPO10 + _nGRUP10  //alterado ana, estava grupo incorreto
			_nGRUP11 = REL2->_GRUPO11 + _nGRUP11  //alterado ana, estava grupo incorreto
		Endif
		dbSelectArea("REL2")
		dbSkip()
	Enddo

	// So imprime se entrou no Vendedor
	If (_nCT  + _nINAT) > 0
		@ Li,001 PSAY "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li + 1
		@ Li,001 PSAY  "|"
		
		@ Li,031 PSAY  "|"    + Transform(_nCT , "@E 9999" )
		@ Li,036 PSAY  "|"    + Transform(_nFMA0, "@E 9999" )
		@ Li,041 PSAY  "|"    + Transform(_nF0, "@E 9999" )
		@ Li,046 PSAY  "|"    + Transform(_nF1, "@E 9999" )
		@ Li,051 PSAY  "|"    + Transform(_PrzMed, "@E 9999" )
		@ Li,056 PSAY  "|"  + Transform( _nIPT  , "@E 9.999" )
		@ Li,063 PSAY  "|"  + Transform( _nIPG  , "@E 9.999" )
		@ Li,070 PSAY  "|"  + Transform( _nIPS  , "@E 9.999" )
		
		@ Li,077 PSAY  "|"    + Transform( _nVLRFAT/_nFREQUE  , "@E 999999999")
		@ Li,088 PSAY  "|"    + Transform( _nPESO/_nFREQUE , "@E 999999999" )
		@ Li,099 PSAY  "|"    + Transform( _nFREQUE  , "@E 9999" )
		
		@ Li,105 PSAY  "|"  + Transform( _nVLRFAT   , "@E 999999,999,999" )
		
		@ Li,120 PSAY  "|"  + Transform( _nPERCFAT , "@E 999.9" )
		
		@ Li,126 PSAY  "|"  + Transform( _nPESO  , "@E 99999,999" )
		@ Li,136 PSAY  "|"  + Transform( _nTOTGRUP1 , "@E 999999" )
		@ Li,143 PSAY  "|"  + Transform( _nTOTGRUP2 , "@E 999999" )
		@ Li,150 PSAY  "|"  + Transform( _nGRUP01  , "@E 999999" )
		@ Li,157 PSAY  "|"  + Transform( _nGRUP02  , "@E 999999" )
		@ Li,164 PSAY  "|"  + Transform( _nGRUP03  , "@E 999999" )
		@ Li,171 PSAY  "|"  + Transform( _nGRUP04  , "@E 999999" )
		@ Li,178 PSAY  "|"  + Transform( _nGRUP05  , "@E 999999" )
		@ Li,185 PSAY  "|"  + Transform( _nGRUP06  , "@E 999999" )
		@ Li,192 PSAY  "|"  + Transform( _nGRUP07  , "@E 999999" )
		@ Li,199 PSAY  "|"  + Transform( _nGRUP08  , "@E 999999" )
		@ Li,206 PSAY  "|"  + Transform( _nGRUP09  , "@E 999999" )
		@ Li,213 PSAY  "|"  + Transform( _nGRUP10  , "@E 999999" )
		@ Li,220 PSAY  "|"
		Li := 	Li+1
		@ Li,001 PSAY "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Endif

	Return
	//***********

	// Funcao de Impressao dos precos medios

	//***********
	Static Function Impr_Rel2a()
	//
	*******
	* Impressao
	*******
	_cTipoRel  := "(  P R E C O S  M E D I O S  )"
	titulo     :="CLASSIFICACAO DOS CLIENTES ATIVOS POR VENDEDOR (PRECOS)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	// Zero as Variaveis
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_nNUMREDES := 0
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nPRC01	:= 0
	_nPRC02	:= 0
	_nPRC03	:= 0
	_nPRC04	:= 0
	_nPRC05	:= 0
	_nPRC06	:= 0
	_nPRC07	:= 0
	_nPRC08	:= 0
	_nPRC09	:= 0
	_nPRC10	:= 0
	_nPRC11	:= 0
	_nPRC12	:= 0
	_nPRC13	:= 0
	_nPRC14	:= 0
	_nPRC15	:= 0
	_nPRC16	:= 0
	_nPESIT01 :=0
	_nPESIT02 :=0
	_nPESIT03 :=0
	_nPESIT04 :=0
	_nPESIT05 :=0
	_nPESIT06 :=0
	_nPESIT07 :=0
	_nPESIT08 :=0
	_nPESIT09 :=0
	_nPESIT10 :=0
	_nPESIT11 :=0
	_nPESIT12 :=0
	_nPESIT13 :=0
	_nPESIT14 :=0
	_nPESIT15 :=0
	_nPESIT16 :=0


	dbSelectArea("REL2")
	dbSetOrder(1)
	dbGoTop()
	Do While !Eof()
		// // // //
		If REL2->_REGIAO  == _cCodRegiao
			// So imprime se for clientes
			// // //
			// // //
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif

		IF REL2->_REGIAO = 'CPS'
			_TESTE:= '000'
		ENDIF
			
			If li > 64
				Li := 8
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM ) +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001 PSAY "|"
				@ Li,04   PSAY "REGIAO DE VENDAS : "  +REL2->_REGIAO + REL2->_REGDESC
				@ Li,204 PSAY "Impr_Rel2a"
				@ Li,215 PSAY "|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|********************|*****************|*****************************************"+_cTipoRel+"************************************************|"
				Li := Li + 1
				@ Li,001 PSAY "|                             |    |    |    |    |    |       INDICES      |  FATURAMENTO    |"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				//			@ Li,Pcol() PSAY (_mGrupoPrc[16,2])+"|"
				_cBMGp01 = (_mGrupoPrc[1,3])
				_cBMGp02 = (_mGrupoPrc[2,3])
				_cBMGp03 = (_mGrupoPrc[3,3])
				_cBMGp04 = (_mGrupoPrc[4,3])
				_cBMGp05 = (_mGrupoPrc[5,3])
				_cBMGp06 = (_mGrupoPrc[6,3])
				_cBMGp07 = (_mGrupoPrc[7,3])
				_cBMGp08 = (_mGrupoPrc[8,3])
				_cBMGp09 = (_mGrupoPrc[9,3])
				_cBMGp10 = (_mGrupoPrc[10,3])
				_cBMGp11 = (_mGrupoPrc[11,3])
				_cBMGp12 = (_mGrupoPrc[12,3])
				_cBMGp13 = (_mGrupoPrc[13,3])
				_cBMGp14 = (_mGrupoPrc[14,3])
				_cBMGp15 = (_mGrupoPrc[15,3])
				//			_cBMGp16 = (_mGrupoPrc[16,3])
				
				Li := Li + 1
				@ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 | F>1|  IPT   IPG    IPS  |  VALOR  | PESO  |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|"
				//@ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 | F>1|  IPG   IPS    IPR  |  VALOR  | PESO  |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|"
				//@ Li,001 PSAY "|          VENDEDOR           | CT | F>0| F0 | F1 | F>1|  SEG   SUP    REG  |  VALOR  | PESO  |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|" //+_cBMGp16+"|"
				Li := Li + 1
				@ Li,001 PSAY "|*****************************|****|****|****|****|****|******|******|******|*********|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|*******|"
				Li := Li + 1
			Endif
			
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL2->_VENDED +' '+SUBSTR(REL2->_VENDESC,1,21)		   // 6 + 1 + 21 = 28
			@ Li,031 PSAY  "|"    + Transform(REL2->_CT , "@E 9999" )
			@ Li,036 PSAY  "|"    + Transform(REL2->_FMA0, "@E 9999" )
			@ Li,041 PSAY  "|"    + Transform(REL2->_F0, "@E 9999" )
			@ Li,046 PSAY  "|"    + Transform(REL2->_F1, "@E 9999" )
			@ Li,051 PSAY  "|"    + Transform(REL2->_FMA1, "@E 9999" )
			@ Li,056 PSAY  "|"   + Transform( REL2->_IPT  , "@E 9.999" )
			@ Li,063 PSAY  "|"   + Transform( REL2->_IPG  , "@E 9.999" )
			@ Li,070 PSAY  "|"   + Transform( REL2->_IPS  , "@E 9.999" )
			@ Li,077 PSAY  "|"   + Transform( REL2->_VALORFAT  , "@E 99999,999")
			@ Li,087 PSAY  "|"   + Transform( REL2->_PESOTOT  , "@E 999,999" )
			@ Li,095 PSAY  "|"   + Transform( REL2->_PRECO01  , "@E 99.9999" )
			@ Li,103 PSAY  "|"   + Transform( REL2->_PRECO02  , "@E 99.9999" )
			@ Li,111 PSAY  "|"   + Transform( REL2->_PRECO03  , "@E 99.9999" )
			@ Li,119 PSAY  "|"   + Transform( REL2->_PRECO04  , "@E 99.9999" )
			@ Li,127 PSAY  "|"   + Transform( REL2->_PRECO05  , "@E 99.9999" )
			@ Li,135 PSAY  "|"   + Transform( REL2->_PRECO06  , "@E 99.9999" )
			@ Li,143 PSAY  "|"   + Transform( REL2->_PRECO07  , "@E 99.9999" )
			@ Li,151 PSAY  "|"   + Transform( REL2->_PRECO08  , "@E 99.9999" )
			@ Li,159 PSAY  "|"   + Transform( REL2->_PRECO09  , "@E 99.9999" )
			@ Li,167 PSAY  "|"   + Transform( REL2->_PRECO10  , "@E 99.9999" )
			@ Li,175 PSAY  "|"   + Transform( REL2->_PRECO11  , "@E 99.9999" )
			@ Li,183 PSAY  "|"   + Transform( REL2->_PRECO12  , "@E 99.9999" )
			@ Li,191 PSAY  "|"   + Transform( REL2->_PRECO13  , "@E 99.9999" )
			@ Li,199 PSAY  "|"   + Transform( REL2->_PRECO14  , "@E 99.9999" )
			@ Li,207 PSAY  "|"   + Transform( REL2->_PRECO15  , "@E 99.9999" )
			@ Li,215 PSAY  "|"   //+ Transform( REL1->_PRECO16  , "@E 99.9999" )
			Li := Li + 1
			// Faz somatoria dos totais
			// Frequencia do Cliente
			_nCT    = _CT   + _nCT
			_nINAT  = _INAT + _nINAT
			_nFMA0  = _FMA0 + _nFMA0
			_nF0    = _F0   + _nF0
			_nF1    = _F1   + _nF1
			_nFMA1  = _FMA1 + _nFMA1
			_nNUMREDES = REL2->_NUMREDES + _nNUMREDES
			
			// Pondero os Indices

			If ( REL2->_PESOTOT + _nPESO) > 0
				If REL2->_IPT > 0
					// Na primeira vez não somo o total 
					If _nIPT =0
						_nCalcQuo := (REL2->_IPT * REL2->_PESOTOT ) 
					Else
						_nCalcQuo := (REL2->_IPT * REL2->_PESOTOT ) + (_nIPT * _nPESO)
					Endif
					_nCalcDiv   := (REL2->_PESOTOT + _nPESO)
					//_nIPT         := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPT         :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL2->_IPG > 0
					If _nIPG =0
						_nCalcQuo := (REL2->_IPG * REL2->_PESOTOT )
					Else
						_nCalcQuo := (REL2->_IPG * REL2->_PESOTOT ) + (_nIPG * _nPESO)
					Endif
					_nCalcDiv   := (REL2->_PESOTOT + _nPESO)
					//_nIPG        := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPG        :=  _nCalcQuo / _nCalcDiv
				Endif
				If REL2->_IPS > 0           
					If _nIPS =0
					_nCalcQuo := (REL2->_IPS * REL2->_PESOTOT ) 
					Else
					_nCalcQuo := (REL2->_IPS * REL2->_PESOTOT ) + (_nIPS * _nPESO)				
					Endif
					_nCalcDiv   := (REL2->_PESOTOT + _nPESO)
					//_nIPS         := ROUND(_nCalcQuo / _nCalcDiv,3)
					_nIPS         :=  _nCalcQuo / _nCalcDiv
				Endif
				//_nTotPesInd := _nTotPesInd + REL2->_PESOTOT
				_nFREQUE = REL2->_FREQUE   + _nFREQUE
				_nVLRFAT = REL2->_VALORFAT + _nVLRFAT
				_nVLRPED = REL2->_PESOTOT  + _nVLRPED
				_nPESO   = REL2->_PESOTOT    + _nPESO
				
			Endif
			If _nVLRFAT > 0
				_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
			Endif
			// Somo as colunas de grupos
			If (REL2->_PESOTOT + _nPESO) > 0
				If REL2->_PRECO01 <> 0
					_nPRC01ant :=_nPRC01
					_nPRC01 = ((REL2->_PRECO01 * REL2->_PESOTOT) + (_nPRC01ant * _nPESIT01)) /  (REL2->_PESOTOT + _nPESIT01)
					_nPESIT01  := _nPESIT01 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO02 <> 0
					_nPRC02ant :=_nPRC02
					_nPRC02 = ((REL2->_PRECO02 * REL2->_PESOTOT) + (_nPRC02ant * _nPESIT02)) /  (REL2->_PESOTOT + _nPESIT02)
					_nPESIT02  := _nPESIT02 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO03 <> 0
					_nPRC03ant :=_nPRC03
					_nPRC03 = ((REL2->_PRECO03 * REL2->_PESOTOT) + (_nPRC03ant * _nPESIT03)) /  (REL2->_PESOTOT + _nPESIT03)
					_nPESIT03  := _nPESIT03 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO04 <> 0
					_nPRC04ant :=_nPRC04
					_nPRC04 = ((REL2->_PRECO04 * REL2->_PESOTOT) + (_nPRC04ant * _nPESIT04)) /  (REL2->_PESOTOT + _nPESIT04)
					_nPESIT04  := _nPESIT04 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO05 <> 0
					_nPRC05ant =_nPRC05
					_nPRC05 = ((REL2->_PRECO05 * REL2->_PESOTOT) + (_nPRC05ant * _nPESIT05)) /  (REL2->_PESOTOT + _nPESIT05)
					_nPESIT05  := _nPESIT05 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO06 <> 0
					_nPRC06ant :=_nPRC06
					_nPRC06 = ((REL2->_PRECO06 * REL2->_PESOTOT) + (_nPRC06ant * _nPESIT06)) /  (REL2->_PESOTOT + _nPESIT06)
					_nPESIT06  := _nPESIT06 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO07 <> 0
					_nPRC07ant :=_nPRC07
					_nPRC07 = ((REL2->_PRECO07 * REL2->_PESOTOT) + (_nPRC07ant * _nPESIT07)) /  (REL2->_PESOTOT + _nPESIT07)
					_nPESIT07  := _nPESIT07 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO08 <> 0
					_nPRC08ant :=_nPRC08
					_nPRC08 = ((REL2->_PRECO08 * REL2->_PESOTOT) + (_nPRC08ant * _nPESIT08)) /  (REL2->_PESOTOT + _nPESIT08)
					_nPESIT08  := _nPESIT08 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO09 <> 0
					_nPRC09ant :=_nPRC09
					_nPRC09 = ((REL2->_PRECO09 * REL2->_PESOTOT) + (_nPRC09ant * _nPESIT09)) / (REL2->_PESOTOT + _nPESIT09)
					_nPESIT09  := _nPESIT09 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO10 <> 0
					_nPRC10ant :=_nPRC10
					_nPRC10 = ((REL2->_PRECO10 * REL2->_PESOTOT) + (_nPRC10ant * _nPESIT10)) /  (REL2->_PESOTOT + _nPESIT10)
					_nPESIT10  := _nPESIT10 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO11 <> 0
					_nPRC11ant :=_nPRC11
					_nPRC11 = ((REL2->_PRECO11 * REL2->_PESOTOT) + (_nPRC11ant * _nPESIT11)) /  (REL2->_PESOTOT + _nPESIT11)
					_nPESIT11  := _nPESIT11 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO12 <> 0
					_nPRC12ant :=_nPRC12
					_nPRC12 = ((REL2->_PRECO12 * REL2->_PESOTOT) + (_nPRC12ant * _nPESIT12)) /  (REL2->_PESOTOT + _nPESIT12)
					_nPESIT12  := _nPESIT12 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO13 <> 0
					_nPRC13ant :=_nPRC13
					_nPRC13 = ((REL2->_PRECO13 * REL2->_PESOTOT) + (_nPRC13ant * _nPESIT13)) /  (REL2->_PESOTOT + _nPESIT13)
					_nPESIT13  := _nPESIT13 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO14 <> 0
					_nPRC14ant :=_nPRC14
					_nPRC14 = ((REL2->_PRECO14 * REL2->_PESOTOT) + (_nPRC14ant * _nPESIT14)) /  (REL2->_PESOTOT + _nPESIT14)
					_nPESIT14  := _nPESIT14 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO15 <> 0
					_nPRC15ant :=_nPRC15
					_nPRC15 = ((REL2->_PRECO15 *REL2->_PESOTOT) + (_nPRC15ant * _nPESIT15)) /  (REL2->_PESOTOT + _nPESIT15)
					_nPESIT15  := _nPESIT15 + REL2->_PESOTOT
				Endif
				If REL2->_PRECO16 <> 0
					_nPRC16ant :=_nPRC16
					_nPRC16 = ((REL2->_PRECO16 *REL2->_PESOTOT) + (_nPRC16ant * _nPESIT16)) /  (REL2->_PESOTOT + _nPESIT16)
					_nPESIT16  := _nPESIT16 + REL2->_PESOTOT
				Endif
			Endif
		Endif
		dbSelectArea("REL2")
		dbSkip()
	Enddo
	If  (_nCT  + _nINAT) > 0
		@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		@ Li,001 PSAY  "|"
		@ Li,031 PSAY  "|"    + Transform(_nCT , "@E 9999" )
		@ Li,036 PSAY  "|"    + Transform(_nFMA0, "@E 9999" )
		@ Li,041 PSAY  "|"    + Transform(_nF0, "@E 9999" )
		@ Li,046 PSAY  "|"    + Transform(_nF1, "@E 9999" )
		@ Li,051 PSAY  "|"    + Transform(_nFMA1, "@E 9999" )
		@ Li,056 PSAY  "|"  + Transform( _nIPT  , "@E 9.999" )
		@ Li,063 PSAY  "|"  + Transform( _nIPG  , "@E 9.999" )
		@ Li,070 PSAY  "|"  + Transform( _nIPS  , "@E 9.999" )
		@ Li,077 PSAY  "|"  + Transform( _nVLRFAT , "@E 99999,999")
		@ Li,087 PSAY  "|"  + Transform( _nVLRPED , "@E 999,999" )
		@ Li,095 PSAY  "|"    + Transform( _nPRC01  , "@E 99.9999" )
		@ Li,103 PSAY  "|"    + Transform( _nPRC02  , "@E 99.9999" )
		@ Li,111 PSAY  "|"    + Transform( _nPRC03  , "@E 99.9999" )
		@ Li,119 PSAY  "|"    + Transform( _nPRC04  , "@E 99.9999" )
		@ Li,127 PSAY  "|"    + Transform( _nPRC05  , "@E 99.9999" )
		@ Li,135 PSAY  "|"    + Transform( _nPRC06  , "@E 99.9999" )
		@ Li,143 PSAY  "|"    + Transform( _nPRC07  , "@E 99.9999" )
		@ Li,151 PSAY  "|"    + Transform( _nPRC08  , "@E 99.9999" )
		@ Li,159 PSAY  "|"    + Transform( _nPRC09  , "@E 99.9999" )
		@ Li,167 PSAY  "|"    + Transform( _nPRC10  , "@E 99.9999" )
		@ Li,175 PSAY  "|"    + Transform( _nPRC11  , "@E 99.9999" )
		@ Li,183 PSAY  "|"    + Transform( _nPRC12  , "@E 99.9999" )
		@ Li,191 PSAY  "|"    + Transform( _nPRC13  , "@E 99.9999" )
		@ Li,199 PSAY  "|"    + Transform( _nPRC14  , "@E 99.9999" )
		@ Li,207 PSAY  "|"    + Transform( _nPRC15  , "@E 99.9999" )
		@ Li,215 PSAY  "|"    //+ Transform( _nPRC15  , "@E 9.99999" )
		
		Li := 	Li+1
		@ Li,001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	Endif

	Return
	//***********


	Static Function Grav_Arq2()
	// Chave do Indice
	//  _cIndex   := "_SEGMERC + _REGIAO  +_SEQRELA"
	//	_cSEGMERC    _cREGIAO    _cTrIndice
	// Variaveis dos Indices
	_nVlr_IPT = 0   // Indices IPT
	_nVlr_IPG = 0   // Indices IPG
	_nVlr_IPS = 0   // Indices IPS

	dbSelectArea("REL2")             // _cIndex   := "_SEQRELA"
	If dbSeek(_cSEGMERC  +  _cREGIAO  + _cVENDED + _cTrIndice)
		RecLock("REL2",.F.)   //  com .f. sem append blank
	Else
		RecLock("REL2",.T.)   // com .t. com append blank
		Replace _SEQRELA  WITH _cTrIndice         // Controle para sequencia do Relatorio
		Replace _DATAINI  With SZ7->Z7_DATINI    // Data Inicial
		Replace _DATAFIM  With SZ7->Z7_DATFIM    // Data Final
		Replace _SEGMERC  WITH _cSEGMERC          // Segmento de Mercado
		Replace _SEGDESC  WITH SZ7->Z7_SEGDESC   // Descricao Segmento de Mercado
		Replace _REGIAO   WITH _cREGIAO           // Regiao
		Replace _REGDESC  WITH SZ7->Z7_REGDESC   // Descricao da Regiao
		Replace _VENDED   WITH _cVENDED 		   // Vendedor
		Replace _VENDESC  WITH _cVENDESC  		   // Vendedor
		Replace _REDE     WITH SZ7->Z7_REDE      //  Rede que o Cliente pertence
		Replace _CLIENTE  WITH _cCLIENTE          // Quebra - Cliente
		Replace _CLIDESC  WITH _cCLINOME          // Quebra - Cliente
		Replace _LOJA     WITH SZ7->Z7_LOJA      // Quebra - Loja
	Endif

	If SZ7->Z7_PESTOT > 0
		//Crio um total para controlar o indice medio
		_nTotPesInd := _nTotPesInd + SZ7->Z7_PESTOT	
		If REL2->_IPT > 0
			//Na primeira vez forço ser o mesmo indice
			_nCalVlr1 := ((REL2->_IPT * REL2->_PESOTOT) +  (SZ7->Z7_IPT * SZ7->Z7_PESTOT))
			_nCalQtd1 := (REL2->_PESOTOT+ SZ7->Z7_PESTOT)
			//_nVlr_IPT := round((_nCalVlr1 / _nCalQtd1),3)
			_nVlr_IPT := (_nCalVlr1 / _nCalQtd1)
		Else
			_nVlr_IPT := SZ7->Z7_IPT
		Endif
		If REL2->_IPG > 0
			_nCalVlr2 := ((REL2->_IPG *REL2->_PESOTOT) + (SZ7->Z7_IPG * SZ7->Z7_PESTOT))
			_nCalQtd2 := (REL2->_PESOTOT+ SZ7->Z7_PESTOT)
			//_nVlr_IPG := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPG :=  (_nCalVlr2 / _nCalQtd2)
		Else
			_nVlr_IPG := SZ7->Z7_IPG
		Endif
		If REL2->_IPS > 0
			_nCalVlr3 := ((REL2->_IPS *REL2->_PESOTOT) + (SZ7->Z7_IPS * SZ7->Z7_PESTOT))
			_nCalQtd3 := (REL2->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPS := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPS :=  (_nCalVlr3 / _nCalQtd3)		
		Else
			_nVlr_IPS := SZ7->Z7_IPS
		Endif
		_TotFatInd  := _TotFatInd + SZ7->Z7_VLRFAT
		//_nTotPesInd := _nTotPesInd + SZ7->Z7_PESTOT
		
	Endif
	Replace _CT        WITH _CT   + SZ7->Z7_CT    // Clientes Total
	Replace _INAT      WITH _INAT + SZ7->Z7_INAT  // Clientes Inativos
	Replace _FMA0      WITH _FMA0 + SZ7->Z7_FMA0  // Frequencia > 0
	Replace _F0        WITH _F0   + SZ7->Z7_F0    // Frequencia = 0
	Replace _F1        WITH _F1   + SZ7->Z7_F1    // Frequencia = 1
	Replace _FMA1      WITH _FMA1 + SZ7->Z7_FMA1  // Frequencia > 1
	Replace _NUMREDES  WITH _NUMREDES + _nLoja     // Numero de Lojas da Rede
	If _nVlr_IPT > 0 .and.  _nVlr_IPT < 9.999
		Replace _IPT       WITH _nVlr_IPT  // Indices IPT
	Endif
	If _nVlr_IPG > 0 .and.  _nVlr_IPG < 9.999
		Replace _IPG       WITH _nVlr_IPG  // Indices IPG
	Endif
	If _nVlr_IPS > 0 .and.  _nVlr_IPS < 9.999
		Replace _IPS       WITH _nVlr_IPS  // Indices IPS
	Endif
	Replace _FREQUE    WITH _FREQUE + SZ7->Z7_FREQUE  // Frequencia
	Replace _PRAZOMED  WITH ((_PRAZOMED  * _VALORFAT) +(SZ7->Z7_PRZMED *SZ7->Z7_VLRFAT))/ (_VALORFAT+SZ7->Z7_VLRFAT) // Prazo Medio
	Replace _GRUPOPROD WITH SZ7->Z7_GRUPO     // Grupo Produto
	//Replace _DESCGRUPO WITH SZ7->Z7_DESCGRP   // Descricao Grupo Produto
	Replace _GRUPO01   WITH _GRUPO01 + SZ7->Z7_QTGP01  // Qtd Faturada - Grupo do 1o. parametro
	Replace _GRUPO02   WITH _GRUPO02 + SZ7->Z7_QTGP02  // Qtd Faturada - Grupo do 2o. parametro
	Replace _GRUPO03   WITH _GRUPO03 + SZ7->Z7_QTGP03  // Qtd Faturada - Grupo do 3o. parametro
	Replace _GRUPO04   WITH _GRUPO04 + SZ7->Z7_QTGP04  // Qtd Faturada - Grupo do 4o. parametro
	Replace _GRUPO05   WITH _GRUPO05 + SZ7->Z7_QTGP05  // Qtd Faturada - Grupo do 5o. parametro
	Replace _GRUPO06   WITH _GRUPO06 + SZ7->Z7_QTGP06  // Qtd Faturada - Grupo do 6o. parametro
	Replace _GRUPO07   WITH _GRUPO07 + SZ7->Z7_QTGP07  // Qtd Faturada - Grupo do 7o. parametro
	Replace _GRUPO08   WITH _GRUPO08 + SZ7->Z7_QTGP08  // Qtd Faturada - Grupo do 8o. parametro
	Replace _GRUPO09   WITH _GRUPO09 + SZ7->Z7_QTGP09  // Qtd Faturada - Grupo do 9o. parametro
	Replace _GRUPO10   WITH _GRUPO10 + SZ7->Z7_QTGP10  // Qtd Faturada - Grupo do 10o. parametro
	Replace _GRUPO11   WITH _GRUPO11 + SZ7->Z7_QTGP11  // Qtd Faturada - Grupo do 11o. parametro
	Replace _GRUPO12   WITH _GRUPO12 + SZ7->Z7_QTGP12  // Qtd Faturada - Grupo do 12o. parametro
	Replace _GRUPO13   WITH _GRUPO13 + SZ7->Z7_QTGP13  // Qtd Faturada - Grupo do 13o. parametro
	Replace _GRUPO14   WITH _GRUPO14 + SZ7->Z7_QTGP14  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO15   WITH _GRUPO15 + SZ7->Z7_QTGP15  // Qtd Faturada - Grupo do 14o. parametro

	If SZ7->Z7_PESTOT  + SZ7->Z7_VLRFAT  >0
		
		If SZ7->Z7_VLR01 <> 0
			Replace _PRECO01   WITH ((_PRECO01 * _QTDPO01)+SZ7->Z7_VLR01) /(_QTDPO01 + SZ7->Z7_QTD01)   // Preco Medio  - Grupo do 1o. parametro
			Replace _VLRPO01   WITH (_VLRPO01 + SZ7->Z7_VLR01)
			Replace	_QTDPO01   WITH (_QTDPO01 + SZ7->Z7_QTD01)
		Endif
		If SZ7->Z7_VLR02 <> 0
			Replace _PRECO02   WITH ((_PRECO02 * _QTDPO02)+SZ7->Z7_VLR02) /(_QTDPO02 + SZ7->Z7_QTD02)   // Preco Medio  - Grupo do 2o. parametro
			Replace _VLRPO02   WITH (_VLRPO02 + SZ7->Z7_VLR02)
			Replace	_QTDPO02   WITH (_QTDPO02 + SZ7->Z7_QTD02)
		Endif
		If SZ7->Z7_VLR03 <> 0
			Replace _PRECO03   WITH ((_PRECO03 * _QTDPO03)+SZ7->Z7_VLR03) /(_QTDPO03 + SZ7->Z7_QTD03)   // Preco Medio  - Grupo do 3o. parametro
			Replace _VLRPO03   WITH (_VLRPO03 + SZ7->Z7_VLR03)
			Replace	_QTDPO03   WITH (_QTDPO03 + SZ7->Z7_QTD03)
		Endif
		If SZ7->Z7_VLR04 <> 0
			Replace _PRECO04   WITH ((_PRECO04 * _QTDPO04)+SZ7->Z7_VLR04) /(_QTDPO04 + SZ7->Z7_QTD04)   // Preco Medio  - Grupo do 4o. parametro
			Replace _VLRPO04   WITH (_VLRPO04 + SZ7->Z7_VLR04)
			Replace	_QTDPO04   WITH (_QTDPO04 + SZ7->Z7_QTD04)
		Endif
		If SZ7->Z7_VLR05 <> 0
			Replace _PRECO05   WITH ((_PRECO05 * _QTDPO05)+SZ7->Z7_VLR05) /(_QTDPO05 + SZ7->Z7_QTD05)   // Preco Medio  - Grupo do 5o. parametro
			Replace _VLRPO05   WITH (_VLRPO05 + SZ7->Z7_VLR05)
			Replace	_QTDPO05   WITH (_QTDPO05 + SZ7->Z7_QTD05)
		Endif
		If SZ7->Z7_VLR06 <> 0
			Replace _PRECO06   WITH ((_PRECO06 * _QTDPO06)+SZ7->Z7_VLR06) /(_QTDPO06 + SZ7->Z7_QTD06)   // Preco Medio  - Grupo do 6o. parametro
			Replace _VLRPO06   WITH (_VLRPO06 + SZ7->Z7_VLR06)
			Replace	_QTDPO06   WITH (_QTDPO06 + SZ7->Z7_QTD06)
		Endif
		If SZ7->Z7_VLR07 <> 0
			Replace _PRECO07   WITH ((_PRECO07 * _QTDPO07)+SZ7->Z7_VLR07) /(_QTDPO07 + SZ7->Z7_QTD07)   // Preco Medio  - Grupo do 7o. parametro
			Replace _VLRPO07   WITH (_VLRPO07 + SZ7->Z7_VLR07)
			Replace	_QTDPO07   WITH (_QTDPO07 + SZ7->Z7_QTD07)
		Endif
		If SZ7->Z7_VLR08 <> 0
			Replace _PRECO08   WITH ((_PRECO08 * _QTDPO08)+SZ7->Z7_VLR08) /(_QTDPO08 + SZ7->Z7_QTD08)   // Preco Medio  - Grupo do 8o. parametro
			Replace _VLRPO08   WITH (_VLRPO08 + SZ7->Z7_VLR08)
			Replace	_QTDPO08   WITH (_QTDPO08 + SZ7->Z7_QTD08)
		Endif
		If SZ7->Z7_VLR09 <> 0
			Replace _PRECO09   WITH ((_PRECO09 * _QTDPO09)+SZ7->Z7_VLR09) /(_QTDPO09 + SZ7->Z7_QTD09)  // Preco Medio  - Grupo do 9o. parametro
			Replace _VLRPO09   WITH (_VLRPO09 + SZ7->Z7_VLR09)
			Replace	_QTDPO09   WITH (_QTDPO09 + SZ7->Z7_QTD09)
		Endif
		If SZ7->Z7_VLR10 <> 0
			Replace _PRECO10   WITH ((_PRECO10 * _QTDPO10)+SZ7->Z7_VLR10) /(_QTDPO10 + SZ7->Z7_QTD10)   // Preco Medio  - Grupo do 10o. parametro
			Replace _VLRPO10   WITH (_VLRPO10 + SZ7->Z7_VLR10)
			Replace	_QTDPO10   WITH (_QTDPO10 + SZ7->Z7_QTD10)
		Endif
		If SZ7->Z7_VLR11 <> 0
			Replace _PRECO11   WITH ((_PRECO11 * _QTDPO11)+SZ7->Z7_VLR11) /(_QTDPO11 + SZ7->Z7_QTD11)  // Preco Medio  - Grupo do 11o. parametro
			Replace _VLRPO11   WITH (_VLRPO11 + SZ7->Z7_VLR11)
			Replace	_QTDPO11   WITH (_QTDPO11 + SZ7->Z7_QTD11)
		Endif
		If SZ7->Z7_VLR12 <> 0
			Replace _PRECO12   WITH ((_PRECO12 * _QTDPO12)+SZ7->Z7_VLR12) /(_QTDPO12 + SZ7->Z7_QTD12)  // Preco Medio  - Grupo do 12o. parametro
			Replace _VLRPO12   WITH (_VLRPO12 + SZ7->Z7_VLR12)
			Replace	_QTDPO12   WITH (_QTDPO12 + SZ7->Z7_QTD12)
		Endif
		If SZ7->Z7_VLR13 <> 0
			Replace _PRECO13   WITH ((_PRECO13 * _QTDPO13)+SZ7->Z7_VLR13) /(_QTDPO13 + SZ7->Z7_QTD13)  // Preco Medio  - Grupo do 13o. parametro
			Replace _VLRPO13   WITH (_VLRPO13 + SZ7->Z7_VLR13)
			Replace	_QTDPO13   WITH (_QTDPO13 + SZ7->Z7_QTD13)
		Endif
		If SZ7->Z7_VLR14 <> 0
			Replace _PRECO14   WITH ((_PRECO14 * _QTDPO14)+SZ7->Z7_VLR14) /(_QTDPO14 + SZ7->Z7_QTD14)  // Preco Medio  - Grupo do 14o. parametro
			Replace _VLRPO14   WITH (_VLRPO14 + SZ7->Z7_VLR14)
			Replace	_QTDPO14   WITH (_QTDPO14 + SZ7->Z7_QTD14)
		Endif
		If SZ7->Z7_VLR15 <> 0
			Replace _PRECO15   WITH ((_PRECO15 * _QTDPO15)+SZ7->Z7_VLR15) /(_QTDPO15 + SZ7->Z7_QTD15)   // Preco Medio  - Grupo do 15o. parametro
			Replace _VLRPO15   WITH (_VLRPO15 + SZ7->Z7_VLR15)
			Replace	_QTDPO15   WITH (_QTDPO15 + SZ7->Z7_QTD15)
		Endif
		If SZ7->Z7_VLR16 <> 0
			Replace _PRECO16   WITH ((_PRECO16 * _QTDPO16)+SZ7->Z7_VLR16) /(_QTDPO16 + SZ7->Z7_QTD16)  // Preco Medio  - Grupo do 16o. parametro
			Replace _VLRPO16   WITH (_VLRPO16 + SZ7->Z7_VLR16)
			Replace	_QTDPO16   WITH (_QTDPO16 + SZ7->Z7_QTD16)
		Endif
		If SZ7->Z7_VLR17 <> 0
			Replace _PRECO17   WITH ((_PRECO17 * _QTDPO17)+SZ7->Z7_VLR17) /(_QTDPO17 + SZ7->Z7_QTD17)  // Preco Medio  - Grupo do 17o. parametro
			Replace _VLRPO17   WITH (_VLRPO17 + SZ7->Z7_VLR17)
			Replace	_QTDPO17   WITH (_QTDPO17 + SZ7->Z7_QTD17)
		Endif
		If SZ7->Z7_VLR18 <> 0
			Replace _PRECO18   WITH ((_PRECO18 * _QTDPO18)+SZ7->Z7_VLR18) /(_QTDPO18 + SZ7->Z7_QTD18)   // Preco Medio  - Grupo do 18o. parametro
			Replace _VLRPO18   WITH (_VLRPO18 + SZ7->Z7_VLR18)
			Replace	_QTDPO18   WITH (_QTDPO18 + SZ7->Z7_QTD18)
		Endif
		If SZ7->Z7_VLR19 <> 0
			Replace _PRECO19   WITH ((_PRECO19 * _QTDPO19)+SZ7->Z7_VLR19) /(_QTDPO19 + SZ7->Z7_QTD19)   // Preco Medio  - Grupo do 19o. parametro
			Replace _VLRPO19   WITH (_VLRPO19 + SZ7->Z7_VLR19)
			Replace	_QTDPO19   WITH (_QTDPO19 + SZ7->Z7_QTD19)
		Endif
		If SZ7->Z7_VLR20 <> 0
			Replace _PRECO20   WITH ((_PRECO20 * _QTDPO20)+SZ7->Z7_VLR20) / (_QTDPO20 + SZ7->Z7_QTD20)   // Preco Medio  - Grupo do 20o. parametro
			Replace _VLRPO20   WITH (_VLRPO20 + SZ7->Z7_VLR20)
			Replace	_QTDPO20   WITH (_QTDPO20 + SZ7->Z7_QTD20)
		Endif
	Endif
	Replace _PESOTOT  WITH _PESOTOT   + SZ7->Z7_PESTOT  // Peso Total
	Replace _VALORFAT WITH _VALORFAT  + SZ7->Z7_VLRFAT  // Faturamento
	Replace _PERCFAT  WITH _VALORFAT / _nToTTVLRFAT * 100        // Peso Total
	Replace _VALORPED WITH _VALORFAT / _FREQUE    // PEDIDO - Valor
	Replace _PESOPED  WITH _PESOTOT  / _FREQUE    // PEDIDO - Peso


	Return


	//*********************
	// 3 Impressao
	//*********************
	Static Function Cliaimp3()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡ao    ³Impressao ³ Autor ³ Rogerio  Nutti/Werner ³ Data ³          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Gera dados para Impressao dos 3 Layouts de Clientes Ativos ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Espec¡fico ADORO ALIMENTICIA                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observacao³ Inicio em Outubro/2002                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Clientes Ativos por Vendedor (Regiao)"
	Local cPict          := ""
	Local titulo         := "Clientes Ativos por Vendedor (Regiao)"
	Local nLin           := 64
	Local Cabec1         := "Clientes Ativos por Vendedor (Regiao)"
	Local Cabec2         := "Clientes Ativos por Vendedor (Regiao)"
	Local imprime        := .T.


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo TEMPORARIO (Para Impressao)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_aCampos := {}
	Aadd( _aCampos, {"_SEQRELA","C",27,0} )  // Sequencia do Relatorio
	Aadd( _aCampos, {"_DATAINI","D",27,0} )  //    Data Inicial
	Aadd( _aCampos, {"_DATAFIM","D",27,0} )  //    Data Final
	Aadd( _aCampos, {"_SEGMERC","C",03,0} )  // Segmento de Mercado
	Aadd( _aCampos, {"_SEGDESC","C",15,0} )  // Descricao Segmento de Mercado
	Aadd( _aCampos, {"_AGRUPO" ,"C",01,0} )  // Divisao do Segmento
	Aadd( _aCampos, {"_REGIAO" ,"C",06,0} )  // Regiao
	Aadd( _aCampos, {"_REGDESC","C",25,0} )  // Descricao da Regiao
	Aadd( _aCampos, {"_VENDED" ,"C",06,0} )  // Vendedor
	Aadd( _aCampos, {"_VENDESC","C",25,0} )  // Vendedor
	Aadd( _aCampos, {"_REDE"   ,"C",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_NUMREDE","N",06,0} )  // Rede que o Cliente pertence
	Aadd( _aCampos, {"_CLIENTE","C",06,0} )  // Quebra - Cliente
	Aadd( _aCampos, {"_LOJA"   ,"C",02,0} )  // Quebra - Loja
	Aadd( _aCampos, {"_UF"   ,"C",02,0} )  // Quebra - Loja
	Aadd( _aCampos, {"_MUN"   ,"C",20,0} )  // Quebra - Loja
	Aadd( _aCampos, {"_CLIDESC","C",35,0} )  // Quebra - Cliente
	AAdd( _aCampos, {"_SEG1"    ,"C",30,0}) // Segmento do cliente (A1_SATIV1) incluido por Adriana em 11/03/08 por solicitação do Sr. Decio - comercial
	AAdd( _aCampos, {"_SEG2"    ,"C",30,0}) // Segmento do cliente (A1_SATIV2) incluido por Adriana em 11/03/08 por solicitação do Sr. Decio - comercial
	Aadd( _aCampos, {"_NUMREDES" ,"N",05,0} )  // Numero de Redes
	Aadd( _aCampos, {"_CT"     ,"N",04,0} )  // Clientes Total
	Aadd( _aCampos, {"_INAT"   ,"N",04,0} )  // Clientes Inativos
	Aadd( _aCampos, {"_FMA0"   ,"N",04,0} )  // Frequencia > 0
	Aadd( _aCampos, {"_F0"     ,"N",04,0} )  // Frequencia = 0
	Aadd( _aCampos, {"_F1"     ,"N",04,0} )  // Frequencia = 1
	Aadd( _aCampos, {"_FMA1"   ,"N",04,0} )  // Frequencia > 1
	Aadd( _aCampos, {"_IPT"    ,"N",06,3} )  // Indices IPT
	Aadd( _aCampos, {"_IPG"    ,"N",06,3} )  // Indices IPG
	Aadd( _aCampos, {"_IPS"    ,"N",06,3} )  // Indices IPS
	Aadd( _aCampos, {"_VALORPED" ,"N",14,2} )  // PEDIDO - Valor
	Aadd( _aCampos, {"_PESOPED" ,"N",09,0} )  // PEDIDO - Peso
	Aadd( _aCampos, {"_FREQUE" ,"N",06,1} )  // Frequencia
	Aadd( _aCampos, {"_VALORFAT" ,"N",14,2} )  // Faturamento
	Aadd( _aCampos, {"_PRAZOMED" ,"N",07,2} )  // Prazo Medio
	//Aadd( _aCampos, {"_PRAZOMED" ,"N",05,2} )  // Prazo Medio
	Aadd( _aCampos, {"_PESOTOT" ,"N",09,0} )  // Peso Total
	Aadd( _aCampos, {"_PERCFAT" ,"N",09,4} )  // Peso Total
	Aadd( _aCampos, {"_GRUPOPROD"  ,"C",04,0} )  // Grupo Produto
	Aadd( _aCampos, {"_DESCGRUPO","C",04,0} )  // Descricao Grupo Produto
	Aadd( _aCampos, {"_TOTGRUP1" ,"N",14,0} ) // Total Grupo um - Grupo do 1o. parametro
	Aadd( _aCampos, {"_TOTGRUP2" ,"N",14,0} ) // Total Grupo dois - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO01" ,"N",14,0} ) // Qtd Faturada - Grupo do 1o. parametro
	Aadd( _aCampos, {"_GRUPO02" ,"N",14,0} ) // Qtd Faturada - Grupo do 2o. parametro
	Aadd( _aCampos, {"_GRUPO03" ,"N",14,0} ) // Qtd Faturada - Grupo do 3o. parametro
	Aadd( _aCampos, {"_GRUPO04" ,"N",14,0} ) // Qtd Faturada - Grupo do 4o. parametro
	Aadd( _aCampos, {"_GRUPO05" ,"N",14,0} ) // Qtd Faturada - Grupo do 5o. parametro
	Aadd( _aCampos, {"_GRUPO06" ,"N",14,0} ) // Qtd Faturada - Grupo do 6o. parametro
	Aadd( _aCampos, {"_GRUPO07" ,"N",14,0} ) // Qtd Faturada - Grupo do 7o. parametro
	Aadd( _aCampos, {"_GRUPO08" ,"N",14,0} ) // Qtd Faturada - Grupo do 8o. parametro
	Aadd( _aCampos, {"_GRUPO09" ,"N",14,0} ) // Qtd Faturada - Grupo do 9o. parametro
	Aadd( _aCampos, {"_GRUPO10" ,"N",14,0} ) // Qtd Faturada - Grupo do 10o. parametro
	Aadd( _aCampos, {"_GRUPO11" ,"N",14,0} ) // Qtd Faturada - Grupo do 11o. parametro
	Aadd( _aCampos, {"_GRUPO12" ,"N",14,0} ) // Qtd Faturada - Grupo do 12o. parametro
	Aadd( _aCampos, {"_GRUPO13" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO14" ,"N",14,0} ) // Qtd Faturada - Grupo do 13o. parametro
	Aadd( _aCampos, {"_GRUPO15" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO16" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO17" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO18" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO19" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO20" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO21" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO22" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO23" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO24" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO25" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO26" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO27" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO28" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO29" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO30" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO31" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO32" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO33" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO34" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO35" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO36" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO37" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO38" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO39" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO40" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO41" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO42" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO43" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO44" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO45" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO46" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO47" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO48" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO49" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro
	Aadd( _aCampos, {"_GRUPO50" ,"N",14,0} ) // Qtd Faturada - Grupo do 14o. parametro

	Aadd( _aCampos, {"_PRECO01" ,"N",12,4} ) // Preco Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_PRECO02" ,"N",12,4} ) // Preco Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_PRECO03" ,"N",12,4} ) // Preco Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_PRECO04" ,"N",12,4} ) // Preco Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_PRECO05" ,"N",12,4} ) // Preco Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_PRECO06" ,"N",12,4} ) // Preco Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_PRECO07" ,"N",12,4} ) // Preco Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_PRECO08" ,"N",12,4} ) // Preco Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_PRECO09" ,"N",12,4} ) // Preco Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_PRECO10" ,"N",12,4} ) // Preco Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_PRECO11" ,"N",12,4} ) // Preco Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_PRECO12" ,"N",12,4} ) // Preco Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_PRECO13" ,"N",12,4} ) // Preco Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_PRECO14" ,"N",12,4} ) // Preco Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_PRECO15" ,"N",12,4} ) // Preco Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_PRECO16" ,"N",12,4} ) // Preco Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_PRECO17" ,"N",12,4} ) // Preco Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_PRECO18" ,"N",12,4} ) // Preco Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_PRECO19" ,"N",12,4} ) // Preco Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_PRECO20" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO21" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO22" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO23" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO24" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO25" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO26" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO27" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO28" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO29" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO30" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_PRECO31" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO32" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO33" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO34" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO35" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO36" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO37" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO38" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO39" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO40" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO41" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO42" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO43" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO44" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO45" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO46" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO47" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO48" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO49" ,"N",12,4} )
	Aadd( _aCampos, {"_PRECO50" ,"N",12,4} )


	//************************************
	// Controle das Quantidades dos precos
	//************************************
	Aadd( _aCampos, {"_QTDPR01" ,"N",12,4} ) // Preco Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_QTDPR02" ,"N",12,4} ) // Preco Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_QTDPR03" ,"N",12,4} ) // Preco Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_QTDPR04" ,"N",12,4} ) // Preco Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_QTDPR05" ,"N",12,4} ) // Preco Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_QTDPR06" ,"N",12,4} ) // Preco Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_QTDPR07" ,"N",12,4} ) // Preco Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_QTDPR08" ,"N",12,4} ) // Preco Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_QTDPR09" ,"N",12,4} ) // Preco Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_QTDPR10" ,"N",12,4} ) // Preco Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_QTDPR11" ,"N",12,4} ) // Preco Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_QTDPR12" ,"N",12,4} ) // Preco Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_QTDPR13" ,"N",12,4} ) // Preco Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_QTDPR14" ,"N",12,4} ) // Preco Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_QTDPR15" ,"N",12,4} ) // Preco Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_QTDPR16" ,"N",12,4} ) // Preco Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_QTDPR17" ,"N",12,4} ) // Preco Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_QTDPR18" ,"N",12,4} ) // Preco Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_QTDPR19" ,"N",12,4} ) // Preco Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_QTDPR20" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR21" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR22" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR23" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR24" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR25" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR26" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR27" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR28" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR29" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR30" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_QTDPR31" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR32" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR33" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR34" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR35" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR36" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR37" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR38" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR39" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR40" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR41" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR42" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR43" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR44" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR45" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR46" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR47" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR48" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR49" ,"N",12,4} )
	Aadd( _aCampos, {"_QTDPR50" ,"N",12,4} )

	//************************************
	// Controle dos Valores de precos
	//************************************
	Aadd( _aCampos, {"_VLRPR01" ,"N",12,4} ) // Preco Medio  - Grupo do 1o. parametro
	Aadd( _aCampos, {"_VLRPR02" ,"N",12,4} ) // Preco Medio  - Grupo do 2o. parametro
	Aadd( _aCampos, {"_VLRPR03" ,"N",12,4} ) // Preco Medio  - Grupo do 3o. parametro
	Aadd( _aCampos, {"_VLRPR04" ,"N",12,4} ) // Preco Medio  - Grupo do 4o. parametro
	Aadd( _aCampos, {"_VLRPR05" ,"N",12,4} ) // Preco Medio  - Grupo do 5o. parametro
	Aadd( _aCampos, {"_VLRPR06" ,"N",12,4} ) // Preco Medio  - Grupo do 6o. parametro
	Aadd( _aCampos, {"_VLRPR07" ,"N",12,4} ) // Preco Medio  - Grupo do 7o. parametro
	Aadd( _aCampos, {"_VLRPR08" ,"N",12,4} ) // Preco Medio  - Grupo do 8o. parametro
	Aadd( _aCampos, {"_VLRPR09" ,"N",12,4} ) // Preco Medio  - Grupo do 9o. parametro
	Aadd( _aCampos, {"_VLRPR10" ,"N",12,4} ) // Preco Medio  - Grupo do 10o. parametro
	Aadd( _aCampos, {"_VLRPR11" ,"N",12,4} ) // Preco Medio  - Grupo do 11o. parametro
	Aadd( _aCampos, {"_VLRPR12" ,"N",12,4} ) // Preco Medio  - Grupo do 12o. parametro
	Aadd( _aCampos, {"_VLRPR13" ,"N",12,4} ) // Preco Medio  - Grupo do 13o. parametro
	Aadd( _aCampos, {"_VLRPR14" ,"N",12,4} ) // Preco Medio  - Grupo do 14o. parametro
	Aadd( _aCampos, {"_VLRPR15" ,"N",12,4} ) // Preco Medio  - Grupo do 15o. parametro
	Aadd( _aCampos, {"_VLRPR16" ,"N",12,4} ) // Preco Medio  - Grupo do 16o. parametro
	Aadd( _aCampos, {"_VLRPR17" ,"N",12,4} ) // Preco Medio  - Grupo do 17o. parametro
	Aadd( _aCampos, {"_VLRPR18" ,"N",12,4} ) // Preco Medio  - Grupo do 18o. parametro
	Aadd( _aCampos, {"_VLRPR19" ,"N",12,4} ) // Preco Medio  - Grupo do 19o. parametro
	Aadd( _aCampos, {"_VLRPR20" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR21" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR22" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR23" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR24" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR25" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR26" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR27" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR28" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR29" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR30" ,"N",12,4} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_VLRPR31" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR32" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR33" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR34" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR35" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR36" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR37" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR38" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR39" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR40" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR41" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR42" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR43" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR44" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR45" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR46" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR47" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR48" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR49" ,"N",12,4} )
	Aadd( _aCampos, {"_VLRPR50" ,"N",12,4} )

	//************


	Aadd( _aCampos, {"_CliMeta" ,"N",12,0} ) // Preco Medio  - Grupo do 20o. parametro
	Aadd( _aCampos, {"_CliValor" ,"N",12,0} ) // Preco Medio  - Grupo do 20o. parametro
								

	_cIndex   := "_VENDED +_SEQRELA"
	_cFileREL := CriaTrab(_aCampos,.T.)
	dbUseArea(.T.,,_cFileREL,"REL3",.T.,.F.)
	IndRegua( "REL3", _cFileREL, _cIndex,,,"Criando Indice ..." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo Temporario  e Grava o de Impressao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
	//³ CLIAT1   ¦ mv_par06       ¦ Do Segmento Mercado  ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par07       ¦ Ate Segmento Mercado ZP_SEGMERC³
	//³ CLIAT1   ¦ mv_par08       ¦ Da Divisao  ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par09       ¦ Ate Divisao ZP_AGRUPO          ³
	//³ CLIAT1   ¦ mv_par10       ¦ Da Regiao  A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par11       ¦ Ate Regiao A3_REGIAO           ³
	//³ CLIAT1   ¦ mv_par12       ¦ Do Vendedor  F2_VEND1          ³
	//³ CLIAT1   ¦ mv_par13       ¦ Ate Vendedor F2_VEND1          ³
	//

	_nRegTVLRFAT  := 0
	_nTotPesInd   := 0
	_nCliMeta     := 0            // Preco Medio  - Grupo do 20o. parametro
	_nCliValor    := 0            // Preco Medio  - Grupo do 20o. parametro
	_cSeqInvert   := Space(11)
	_cUF          := Space(2)
	_cUltVend     := Space(1)
	_cMUN         := Space(20)
	dbSelectArea("SZ7")
	dbSetOrder(2)                 // _cIndex   := "Z7_FILIAL+Z7_LOTE+ DTOS(Z7_DATINI) + DTOS(Z7_DATFIM)"
	Processa({|| RunImp3SZ71()},"3-Calculando Total de Faturamento para Clientes Ativos ...")

	Static Function RunImp3SZ71()


	dbSelectArea("SZ7")       // _cIndex   := "Z7_FILIAL+Z7_LOTE+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
	dbSetOrder(3)

	///Processa({|| RunImp3SZ72()},"Gerando Arquivo de Impressao para Clientes Ativos por Regiao... ")
	//Return

	///Static Function RunImp3SZ72()
	ProcRegua(RecCount())
	dbGoTop()
	Set softseek on
	DbSeek(xFilial("SZ7")+_cLoteCli)
	Set softseek off
	Do While !Eof() .AND. Z7_LOTE = _cLoteCli
		IncProc('Gerando Relatorio Analitico de Vendedores. ')
		If SZ7->Z7_SEGMERC >= mv_par06  .AND.  SZ7->Z7_SEGMERC <= mv_par07
			If SZ7->Z7_REGIAO  >= mv_par10  .AND.  SZ7->Z7_REGIAO <= mv_par11
				If SZ7->Z7_VENDED  >=  mv_par12  .AND.  SZ7->Z7_VENDED <= mv_par11
					// Vou no Supervisor pegar o Valor da Meta e quantidade de Clientes Ativos
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona em SZR010 para buscar dados do Segmento no Supervisor     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SZR")
					dbSetOrder(1)         // ZR_FILIAL+ZR_CODIGO
					If dbSeek( xFilial("SZR") +SZ7->Z7_SUPERV)          // SA3->A3_SUPER
						DO CASE
							
							CASE month(SZ7->Z7_DATINI) = 1
								_nCliMeta  := SZR->ZR_Mes01      // Preco Medio  - Grupo do 20o. parametro
								_nCliValor := SZR->ZR_Ati01      // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 2
								_nCliMeta  = SZR->ZR_Mes02          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati02          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 3
								_nCliMeta  = SZR->ZR_Mes03          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati03          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 4
								_nCliMeta  = SZR->ZR_Mes04          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati04          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 5
								_nCliMeta  = SZR->ZR_Mes05          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati05          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 6
								_nCliMeta  = SZR->ZR_Mes06          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati06          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 7
								_nCliMeta  = SZR->ZR_Mes07          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati07          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 8
								_nCliMeta  = SZR->ZR_Mes08          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati08          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 9
								_nCliMeta  = SZR->ZR_Mes09          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati09          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 10
								_nCliMeta  = SZR->ZR_Mes10          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati10          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 11
								_nCliMeta  = SZR->ZR_Mes11          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati11          // Preco Medio  - Grupo do 20o. parametro
							CASE month(SZ7->Z7_DATINI) = 12
								_nCliMeta  = SZR->ZR_Mes12          // Preco Medio  - Grupo do 20o. parametro
								_nCliValor = SZR->ZR_Ati12          // Preco Medio  - Grupo do 20o. parametro
						EndCase
					Endif
					dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_LOTE+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
					dbSetOrder(3)
					_cSEGMERC := SZ7->Z7_SEGMERC
					_cREGIAO     := SZ7->Z7_REGIAO
					_cVENDED    := SZ7->Z7_VENDED
					_cCLIENTE    := SZ7->Z7_CLIENTE
					_cVENDED     := SZ7->Z7_VENDED
					_cVENDESC  := SZ7->Z7_VENDESC
					_cCtrCliente    := SZ7->Z7_CLIENTE
					_cCLIENTE     := SZ7->Z7_CLIENTE
					_cF2Loja	      := SZ7->Z7_LOJA
					_cUF              := SZ7->Z7_UF
					_cMUN           := SZ7->Z7_MUN
					_nLoja	          := 0       
					//incluido por Adriana em 11/03/2008
					//_cSeg1 := alltrim(posicione("SX5",1,XFILIAL("SX5")+"87"+;  &&Mauricio Chamado 06247 - Nao houve necessidade de filtro por filial, mas sim acerto para buscar dados do SX5 apenas de Varzea onde eh efetuado o cadastro.
					_cSeg1 := alltrim(posicione("SX5",1,"02"+"87"+;
									posicione('SA1',1,xfilial("SA1")+SZ7->Z7_CLIENTE+SZ7->Z7_LOJA,"A1_SATIV1"),"X5_DESCRI"))
									
					//_cSeg2 := alltrim(posicione("SX5",1,XFILIAL("SX5")+"88"+;	 &&Mauricio Chamado 06247 - Nao houve necessidade de filtro por filial, mas sim acerto para buscar dados do SX5 apenas de Varzea onde eh efetuado o cadastro.			
					_cSeg2 := alltrim(posicione("SX5",1,"02"+"88"+;
									posicione('SA1',1,xfilial("SA1")+SZ7->Z7_CLIENTE+SZ7->Z7_LOJA,"A1_SATIV2"),"X5_DESCRI"))

					// Opcoes para impressao
					//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
					//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
					//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³
					// Conforme tipo de relatorio solicitado
					// Resumo dos Segmento que e o sintetivo de cada Regiao como quebra o Segmento
					// Analitico de Cada Vendedor temdo como detalhe o Cliente
					// Faco uma outra jogada para agrupar a loja que controla rede
					If empty(SZ7->Z7_REDE)
						_cRede = '000000'
					Else
						If SZ7->Z7_REDE == SZ7->Z7_CLIENTE
							_cRede    := SZ7->Z7_REDE
							_cCLIENTE := SZ7->Z7_REDE
						Else
							_cRede    := SZ7->Z7_REDE
							_cCLIENTE := SZ7->Z7_CLIENTE
							_nLoja	  := 1
						Endif
					Endif
					_cCLINOME    := SZ7->Z7_CLIDESC
					If SZ7->Z7_VlrFat > 0
						// Apos a soma refaco este calculo
						_cSeqInvert := STRZERO((10000000000-SZ7->Z7_VlrFat),11)
					Else
						_cSeqInvert := '99999999999'
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava arquivo Temporario de Impressao                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Neste Caso grava as redes totalizadas
					If !empty(SZ7->Z7_REDE)
						//Forco pegar o nome da Rede
						If SZ7->Z7_REDE == SZ7->Z7_CLIENTE
							dbSelectArea("SA1")
							dbSetOrder(1)      // A1_FILIAL + A1_COD
							dbSeek( xFilial("SA1")+SZ7->Z7_REDE)
							If Found()
								_cCLINOME    := SA1->A1_NOME
							Else
								_cCLINOME    := SZ7->Z7_CLIDESC
							Endif
							dbSelectArea("SZ7")
						Endif
						_cSeqInvert  := SZ7->Z7_REDE+'BA'  // Tiro um caracter para compensar
						_cCtrCliente := SZ7->Z7_REDE
						_cCLIENTE  := SZ7->Z7_REDE		  // Forço considerar o cliente como rede.
						//_cCLIENTE  := SZ7->Z7_CLIENTE
						_cPref = 'C'        // Crio um prefixo para diferenciar o relatori de rede para os de clientes
						Grav_Arq3()
						
						// Grava no sub total
						_cSeqInvert  := SZ7->Z7_REDE+'BA'  // Tiro um caracter para compensar
						_cCtrCliente := SZ7->Z7_CLIENTE
						_cCLIENTE  := SZ7->Z7_CLIENTE					
						_cPref = 'R'	        // Crio um prefixo para diferenciar o relatori de rede para os de clientes
						Grav_Arq3()
						// Grava no proprio cliente para ter o Total no relatorio de redes
						//Forco pegar o nome da Rede
						dbSelectArea("SA1")
						dbSetOrder(1)      // A1_FILIAL + A1_COD
						dbSeek( xFilial("SA1")+SZ7->Z7_REDE)
						If Found()
							_cCLINOME    := SA1->A1_NOME
						Else
							_cCLINOME    := SZ7->Z7_CLIDESC
						Endif
						dbSelectArea("SZ7")
						_cPref       := 'R'	        // Crio um prefixo para diferenciar o relatori de rede para os de clientes
						_cCtrCliente := SZ7->Z7_REDE+'T'
						_cSeqInvert  := SZ7->Z7_REDE+'BT'  // Tiro um caracter para compensar
						_cCLIENTE    := SZ7->Z7_CLIENTE
						Grav_Arq3()
					Else
						_cPref = 'C'	        // Crio um prefixo para diferenciar o relatori de rede para os de clientes
						Grav_Arq3()
					Endif
					If _cUltVend <> SZ7->Z7_VENDED
						_nTotPesInd := 0
					Endif
					_cUltVend := SZ7->Z7_VENDED
					
				Endif
			Endif
		Endif
		dbSelectArea("SZ7")             // _cIndex   := "Z7_FILIAL+Z7_INDICE+Z7_REDE+ Z7_CLIENTE + Z7_LOJA"
		dbSkip()
	Enddo
	// Reprocesso para forcar o indice dos totais
	dbSelectArea("REL3")
	dbSetOrder(0)
	dbGoTop()
	Do While !Eof()
		// // // // Monto o indice novamente
		_cPref       := SUBSTR(REL3->_SEQRELA,1,1)
		_cSeqInvert  := STRZERO((10000000000-REL3->_ValorFat),11)
		_cRede       := SUBSTR(REL3->_SEQRELA,13,6)
		_cCtrCliente := SUBSTR(REL3->_SEQRELA,19,6)
		_cTrIndice :=_cPref+_cSeqInvert + _cRede  + _cCtrCliente
		RecLock("REL3",.F.)
		If _cPref = 'C'
			Replace  _SEQRELA  WITH _cTrIndice         // Controle para sequencia do Relatorio
		Endif
		MsUnlock()
		dbSelectArea("REL3")
		dbSkip()
	Enddo

	If MV_PAR17 = 1
		// Apos gerar arquivo verifica se faz uma copia
		_cData     := dtos( dDataBase )
		_cArqOrig  := _cDirOrig := "\SIGAADV\"+_cFileREL + GetDBExtension()
		//*******************************************************
		_cTime  := substr(time(),4,2)+substr(time(),7,1)
		_cLabel := 'C'+substr( _cData , 5 , 4 ) +_cTime + GetDBExtension()
		If empty(MV_PAR18)
			_cDire = "C:\"
		Else
			_cDire =alltrim(MV_PAR18)
		Endif
		_cDestin := _cDire+_cLabel    // "C:\xxxx\yyy\"+nome
		dbSelectArea("REL3")
		dbGoTop()
		Copy File &(_cArqOrig) To  &(_cDestin)    // Copy to &_cDestin
		
		// Copy File &(_cArqOrig) To &(_cArqDest)
		//*******************************************************
		
	Endif

	// Impressao dos Relatorios ....
	//³ CLIAT1   ¦ mv_par03       ¦ 1 - Resumo - Todos Segmentos   ³
	//³ CLIAT1   ¦ mv_par04       ¦ 2 - Analit Por Regiao          ³
	//³ CLIAT1   ¦ mv_par05       ¦ 3 - Analit Por Vendedor        ³

	// Carrego Matriz dos Nomes dos Grupos
	_mGrupoPrd  :={}        //  //   Gerar uma matriz para os grupos de pesos
	_mGrupoPrc  :={}         //  //   Gerar uma matriz para os grupos de precos
	dbSelectArea("SBM")
	dbSetOrder(1)
	//Processa({|| RunNomGr1()},"Gera matriz dos grupo e sub-grupo dos produtos ...")
	//Return

	//Static Function RunNomGr1()

	//ProcRegua(RecCount())
	dbGoTop()
	_nSeqMatrPes := 1             //   Controla a sequencia de Pesos
	Do While _nSeqMatrPes < 80 //50 //30
		AADD(_mGrupoPrd,{_nSeqMatrPes,'      ','      '})
		AADD(_mGrupoPrc,{_nSeqMatrPes,'       ','       '})
		_nSeqMatrPes   := _nSeqMatrPes  + 1      //   Controla a sequencia de Pesos
	Enddo
	_nSeqMatrPes   := 1            //   Controla a sequencia de Pesos
	_nSeqMatrPrc   := 1            //   Controla a sequencia de Preços
	// Atualizo Matriz de Peso
	_cIndTrab1  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab1 ,"strzero(SBM->BM_Ctrpes,2)",,,' Criando Indice de Usuario')
	_nIndex1 := RetIndex('SBM')+1
	DbsetOrder(_nIndex1)
	dbGoTop()
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPes > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPes < 80 //50 //30     // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrd,{|x| x[1]==SBM->BM_Ctrpes } )
				If _cPosMatrz = 0
					_cPosMatrz := SBM->BM_Ctrpes
				Endif
				_mGrupoPrd[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,6)
				_mGrupoPrd[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,6)
				_nSeqMatrPes := _nSeqMatrPes + 1
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo
	dbGoTop()
	_cIndTrab2  := CriaTrab(,.F. )
	IndRegua('SBM',_cIndTrab2 ,"strzero(SBM->BM_CtrPrc,2)",,,' Criando Indice de Usuario')
	_nIndex2 := RetIndex('SBM')+1
	DbsetOrder(_nIndex2)
	dbGoTop()
	// Atualizo Matriz de Preco
	_nSeqMatrPrc := 0
	Do While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		IncProc()
		dbSelectArea("SBM")
		If SBM->BM_CtrPrc > 0 .and. SBM->BM_Cliati = 'S'
			If _nSeqMatrPrc  < 80 //50  //30    // Não pode ultrapassar 30
				// Usar o conceito definido mas tera que mudar, falar com Heraldo e Vicente
				_cPosMatrz  :=	 Ascan(_mGrupoPrd,{|x| x[1]==SBM->BM_Ctrprc } )
				If _cPosMatrz = 0
					_cPosMatrz    := SBM->BM_Ctrprc
	//				_nSeqMatrPrc  := _nSeqMatrPrc + 1  		// retirado por Daniel G.Jr. em 16/12/09
				Endif
				_mGrupoPrc[_cPosMatrz,2] := Substr(SBM->BM_Desc,1,7)
				_mGrupoPrc[_cPosMatrz,3] := Substr(SBM->BM_Grurel,1,7)
				_nSeqMatrPrc  := _nSeqMatrPrc + 1			// incluído por Daniel G.Jr. em 16/12/09
			Endif
		Endif
		dbSelectArea("SBM")
		DbSkip()
	Enddo


	// Forco um filtro por Vendedor Conforme Parmetro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em SA3010 para buscar dados da Vendedor          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA3")
	dbSetOrder(9)//dbSetOrder(8)- Alterado 16/02/13. Ana - Ajuste para atualizacao Protheus 11         // A3_FILIAL+A3_REGIAO
	dbGoTop()
	Do While !Eof()
		_cCodVende = SA3->A3_COD
		If SA3->A3_COD < mv_par12 .OR. SA3->A3_COD > mv_par13
			dbSkip()
			Loop
		Endif
		// Apenas os que fazem parte da regiao analizada
		//  ¦ 1 - Resumo - Todos Segmentos
		//   Imprime 1-Qtde / 2-Precos Med  ³
		If mv_par15 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			// Imprime Clientes
			_TipCliRed := 'C'
			Impr_Rel3()
			// Continua imprimindo as redes
			_TipCliRed := 'R'
			Impr_Rel3()
		Endif
		If mv_par16 = 1   //    ¦ Imprime 1-Qtde / 2-Precos Med
			// Inprime Clientes
			_TipCliRed := 'C'
			Impr_Rel3a()
			// Continua imprimindo as redes
			_TipCliRed := 'R'
			Impr_Rel3()
			
		Endif
		dbSelectArea("SA3")
		dbSkip()
	Enddo


	Return

	// Funcao de Impressao da Quantidades

	//***********
	Static Function Impr_Rel3()
	//
	//   Impressao
	_cTipoRel  := "( QUANTIDADE FATURADA (PESO) )"
	titulo    :="CLASSIFICACAO DE CLIENTES ATIVOS (QUANTIDADE)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	If _TipCliRed == 'C'
		li      := 80
	Endif
	// Zero as Variaveis
	_nValorMet := 0
	_nCliAtivo := 0
	_nMetaCli  := 0
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_nNUMREDES := 0
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nRedeQb := space(6)
	_cMarca  :=space(1)
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nGRUP01   := 0
	_nGRUP02 := 0
	_nGRUP03 := 0
	_nGRUP04 := 0
	_nGRUP05 := 0
	_nGRUP06 := 0
	_nGRUP07 := 0
	_nGRUP08 := 0
	_nGRUP09 := 0
	_nGRUP10 := 0
	_nGRUP11 := 0
	dbSelectArea("REL3")
	dbSetOrder(1)
	dbGoTop()
	Do While !Eof()
		// // // //
		If REL3->_VENDED == _cCodVende
			// So imprime se for clientes
			// Soma clientes Ativos Junto com as redes
			_cMarca := ' '
			If REL3->_VALORFAT >= REL3->_CLIVALOR
				If SUBSTR(_SEQRELA,1,1) == 'R' .AND. SUBSTR(_SEQRELA,22,1) == 'T'
					// Faz uma marca se  for a soma
					_cMarca := '*'
				Else
					If SUBSTR(_SEQRELA,1,1) == 'C' .AND. SUBSTR(_SEQRELA,22,2) = '  '
						
					Else
						_nCliAtivo := _nCliAtivo + 1
					Endif
				Endif
			Endif
			
			If SUBSTR(_SEQRELA,1,1) = _TipCliRed
				// Frequencia do Cliente
				_nCT    = _CT   + _nCT
				_nINAT  = _INAT + _nINAT
				_nFMA0  = _FMA0 + _nFMA0
				_nF0    = _F0   + _nF0
				_nF1    = _F1   + _nF1
				_nFMA1  = _FMA1 + _nFMA1
				_nNUMREDES = REL3->_NUMREDES + _nNUMREDES
			Else
				dbSelectArea("REL3")
				dbSkip()
				Loop
			Endif
			// // //
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			If li > 64
				Li := 8
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM ) +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				@ Li,001 PSAY "|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001 PSAY "|"
				If _TipCliRed == 'C'
					@ Li,04        PSAY "REGIAO DE VENDAS : " +REL3->_VENDED+'  '+ SA3->A3_NOME
				Else
					@ Li,04        PSAY "REGIAO DE VENDAS : " +REL3->_VENDED+'  '+ SA3->A3_NOME+'       " CONTROLES DAS REDES " '
				Endif
				@ Li,206 PSAY	 "Impr_Rel3"
				If _TipCliRed == 'C'
					@ Li,217 PSAY "|"
					Li := Li + 1
					@ Li,001 PSAY "|*********************************************|*****|********************|*****************|*****|****|**************|*****|*********|*************************"+_cTipoRel+"****************************|"
					Li := Li + 1
					@ Li,001 PSAY "|                                             |     |       INDICES      |  PEDIDO  MEDIO  |     |PRAZ|    FATURA-   |  %  |  PESO   |  SUB TOTAL  |"
				Else
					@ Li,217 PSAY "|"
					Li := Li + 1
					@ Li,001 PSAY "|***************************************************|********************|*****************|*****|****|**************|*****|*********|*************************"+_cTipoRel+"****************************|"
					Li := Li + 1
					@ Li,001 PSAY "|                                                   |       INDICES      |  PEDIDO  MEDIO  |     |PRAZ|    FATURA-   |  %  |  PESO   |  SUB TOTAL  |"
				Endif
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				@ Li,Pcol() PSAY space(6)+"|"
				_cBMTTH1 = 'GRUPO1'
				_cBMTTH2 = 'GRUPO2'
				_cBMGp14 = (_mGrupoPrd[1,3])
				_cBMGp15 = (_mGrupoPrd[2,3])
				_cBMGp16 = (_mGrupoPrd[3,3])
				_cBMGp17 = (_mGrupoPrd[4,3])
				_cBMGp18 = (_mGrupoPrd[5,3])
				_cBMGp19 = (_mGrupoPrd[6,3])
				_cBMGp20 = (_mGrupoPrd[7,3])
				_cBMGp21 = (_mGrupoPrd[8,3])
				_cBMGp22 = (_mGrupoPrd[9,3])
				_cBMGp23 = (_mGrupoPrd[10,3])
				Li := Li + 1
				If _TipCliRed == 'C'
					@ Li,001 PSAY "|  CLIENTE                                    |LOJAS|  IPT   IPG    IPS  |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|"
					//@ Li,001 PSAY "|  CLIENTE                                    |LOJAS|  IPG   IPS    IPR  |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|" ALEX BORGES 13/03/12
					//@ Li,001 PSAY "|  CLIENTE                                    |LOJAS|  SEG    SUP   REG |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|"
					Li := Li + 1
					@ Li,001 PSAY "|*********************************************|*****|******|******|******|*****************|*****|****|**************|*****|*********|******|******|******|******|******|******|******|******|******|******|******|******|"
				Else
					@ Li,001 PSAY "|  CLIENTE                                     REDE  |  IPT   IPG    IPS  |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|"
					//@ Li,001 PSAY "|  CLIENTE                                     REDE  |  IPG   IPS    IPR  |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|" ALEX BORGES 13/03/12
					//@ Li,001 PSAY "|  CLIENTE                                     REDE  | SEG   SUP   REG  |  VALOR    PESO  |FREQ.|MED.|     MENTO    |FATUR|  TOTAL  |"+_cBMTTH1+"|"+_cBMTTH2+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"+_cBMGp17+"|"+_cBMGp18+"|"+_cBMGp19+"|"+_cBMGp20+"|"+_cBMGp21+"|"+_cBMGp22+"|"+_cBMGp23+"|"
					Li := Li + 1
					@ Li,001 PSAY "|***************************************************|******|******|******|*****************|*****|****|**************|*****|*********|******|******|******|******|******|******|******|******|******|******|******|******|"
				Endif
				Li := Li + 1
			Endif
			//12345678901234567890123456789012345678901234567890123
			//|***************************************************|
			//|999999/01 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL3->_CLIENTE +' '+ REL3->_LOJA
			If _TipCliRed == 'C'
				@ Li,012 PSAY  SUBSTR(REL3->_CLIDESC,1,35)
				@ Li,047 PSAY  "|"    + Transform( REL3->_NUMREDES , "@E 999" )
			Else
				@ Li,012 PSAY  SUBSTR(REL3->_CLIDESC,1,31)+_cMarca+' '+REL3->_REDE
			Endif
			@ Li,053 PSAY  "|"    + Transform( REL3->_IPT  , "@E 99.999" )
			@ Li,060 PSAY  "|"    + Transform( REL3->_IPG  , "@E 99.999" )
			@ Li,067 PSAY  "|"    + Transform( REL3->_IPS  , "@E 99.999" )
			//@ Li,074 PSAY  "|"    + Transform( REL3->_VALORPED  , "@E 99999.99")
			@ Li,074 PSAY  "|"    + Transform( REL3->_VALORPED  , "@E 999999.99")
			//@ Li,084 PSAY  "|"    + Transform( REL3->_PESOPED  , "@E 99999999" )
			@ Li,084 PSAY  "|"    + Transform( REL3->_PESOPED  , "@E 9999999" )
			@ Li,091 PSAY  "|"    + Transform( REL3->_FREQUE  , "@E 999.9")
			@ Li,097 PSAY  "|"    + Transform( REL3->_PRAZOMED  , "@E 999")
			@ Li,102 PSAY  "|"    + Transform( REL3->_VALORFAT  , "@E 999999999.99" )
			@ Li,117 PSAY  "|"    + Transform( (REL3->_VALORFAT /_nToTTVLRFAT)*100 , "@E 999.9" )
			@ Li,123 PSAY  "|"    + Transform( REL3->_PESOTOT  , "@E 99999,999" )
			@ Li,133 PSAY  "|"    + Transform( REL3->_TOTGRUP1 , "@E 999999" )
			@ Li,140 PSAY  "|"    + Transform( REL3->_TOTGRUP2 , "@E 999999" )
			@ Li,147 PSAY  "|"    + Transform( REL3->_GRUPO01  , "@E 999999" )
			@ Li,154 PSAY  "|"    + Transform( REL3->_GRUPO02  , "@E 999999" )
			@ Li,161 PSAY  "|"    + Transform( REL3->_GRUPO03  , "@E 999999" )
			@ Li,168 PSAY  "|"    + Transform( REL3->_GRUPO04  , "@E 999999" )
			@ Li,175 PSAY  "|"    + Transform( REL3->_GRUPO05  , "@E 999999" )
			@ Li,182 PSAY  "|"    + Transform( REL3->_GRUPO06  , "@E 999999" )
			@ Li,189 PSAY  "|"    + Transform( REL3->_GRUPO07  , "@E 999999" )
			@ Li,196 PSAY  "|"    + Transform( REL3->_GRUPO08  , "@E 999999" )
			@ Li,203 PSAY  "|"    + Transform( REL3->_GRUPO09  , "@E 999999" )
			@ Li,210 PSAY  "|"    + Transform( REL3->_GRUPO10  , "@E 999999" )
			@ Li,217 PSAY  "|"
			Li := Li + 1
			If SUBSTR(_SEQRELA,1,1) == 'R' .AND. SUBSTR(_SEQRELA,22,1) == 'T'
				@ Li,001 PSAY  "|"
				@ Li,217 PSAY  "|"
				Li := Li + 1
			Endif
			
			// Parametros de clientes Ativos
			If REL3->_CLIVALOR	<> 0 .and.  REL3->_CLIMETA <> 0
				_nValorMet := REL3->_CLIVALOR
				_nMetaCli  := REL3->_CLIMETA
			Endif
			// Pondero os Indices
			// Zera total se e outra rede
			If SUBSTR(_SEQRELA,1,1) = 'R' .AND. SUBSTR(_SEQRELA,22,1) = 'T'
				_nPERCFAT = 0
			Else
				If (REL3->_PESOTOT + _nPESO) > 0
					If REL3->_IPT > 0
						If _nIPT = 0
							_nCalcQuo := (REL3->_IPT * REL3->_PESOTOT ) 				
						Else                                                                                                   
							_nCalcQuo := ((REL3->_IPT * REL3->_PESOTOT ) + (_nIPT * _nPESO))					
						Endif
						_nCalcDiv := ((REL3->_PESOTOT + _nPESO))
						//_nIPT     := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPT     := (_nCalcQuo / _nCalcDiv)
					Endif
					If REL3->_IPG > 0
						If _nIPG = 0				
							_nCalcQuo := (REL3->_IPG * REL3->_PESOTOT )
						Else
							_nCalcQuo := ((REL3->_IPG * REL3->_PESOTOT ) + (_nIPG * _nPESO))
						Endif
						_nCalcDiv := ((REL3->_PESOTOT + _nPESO))
						//_nIPG     := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPG     :=  (_nCalcQuo / _nCalcDiv)					
					Endif
					If REL3->_IPS > 0
						If _nIPS = 0								
							_nCalcQuo := (REL3->_IPS * REL3->_PESOTOT ) 
						Else
							_nCalcQuo := ((REL3->_IPS * REL3->_PESOTOT ) + (_nIPS * _nPESO))					
						Endif
						_nCalcDiv := ((REL3->_PESOTOT + _nPESO))
						//_nIPS     := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPS     :=  (_nCalcQuo / _nCalcDiv)					
					Endif
					_nPESO   := REL3->_PESOTOT  + _nPESO
				Endif
				// Faz somatoria dos totais
				_nFREQUE := REL3->_FREQUE   + _nFREQUE
				_nVLRFAT := REL3->_VALORFAT +_nVLRFAT
				If _nVLRFAT > 0
					_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
				Endif
				_nVLRPES = REL3->_PESOPED  + _nVLRPES
				_nVLRPED = REL3->_VALORPED + _nVLRPED
				// Somo as colunas de grupos
				_nTOTGRUP1 = REL3->_TOTGRUP1 + _nTOTGRUP1
				_nTOTGRUP2 = REL3->_TOTGRUP2 + _nTOTGRUP2
				_nGRUP01   = REL3->_GRUPO01 + _nGRUP01
				_nGRUP02 = REL3->_GRUPO02 + _nGRUP02
				_nGRUP03 = REL3->_GRUPO03 + _nGRUP03
				_nGRUP04 = REL3->_GRUPO04 + _nGRUP04
				_nGRUP05 = REL3->_GRUPO05 + _nGRUP05
				_nGRUP06 = REL3->_GRUPO06 + _nGRUP06
				_nGRUP07 = REL3->_GRUPO07 + _nGRUP07
				_nGRUP08 = REL3->_GRUPO08 + _nGRUP08
				_nGRUP09 = REL3->_GRUPO09 + _nGRUP09
				_nGRUP10 = REL3->_GRUPO10 + _nGRUP10
				_nGRUP11 = REL3->_GRUPO11 + _nGRUP11
			Endif
			_nRedeQb := REL3->	_REDE
		Endif
		dbSelectArea("REL3")
		dbSkip()
	Enddo
	// So imprime se entrou no Vendedor
	If (_nCT  + _nINAT) > 0
		@ Li,001 PSAY "|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li + 1
		@ Li,001 PSAY  "|"
		@ Li,003 PSAY  " CT=" + Transform(_nCT , "@E 9999" )
		@ Li,011 PSAY  " F>0=" + Transform(_nFMA0, "@E 999" )
		@ Li,021 PSAY  " F0=" + Transform(_nF0, "@E 999" )
		@ Li,031 PSAY  "F>1=" + Transform(_nF1, "@E 999" )
		@ Li,040 PSAY  "F1=" + Transform(_nFMA1, "@E 9999" )
		@ Li,053 PSAY  "|"  + Transform( _nIPT  , "@E 9.999" )
		@ Li,060 PSAY  "|"  + Transform( _nIPG  , "@E 9.999" )
		@ Li,067 PSAY  "|"  + Transform( _nIPS  , "@E 9.999" )
		//@ Li,074 PSAY  "|"  + Transform( (_nVLRFAT/_nFREQUE)  , "@E 99999.99")
		//@ Li,083 PSAY  "|"  + Transform( (_nPESO/_nFREQUE)  , "@E 99999999" )
		@ Li,074 PSAY  "|"  + Transform( (_nVLRFAT/_nFREQUE)  , "@E 99999.99")
		@ Li,084 PSAY  "|"  + Transform( (_nPESO/_nFREQUE)  , "@E 9999999" )	
		@ Li,091 PSAY  "|"  + Transform( _nFREQUE  , "@E 999.9" )
		@ Li,097 PSAY  "|"
		@ Li,102 PSAY  "|"  + Transform( _nVLRFAT   , "@E 999999999.99" )
		@ Li,117 PSAY  "|"  + Transform( _nPERCFAT , "@E 999.9" )
		@ Li,123 PSAY  "|"  + Transform( _nPESO  , "@E 99999,999" )
		@ Li,133 PSAY  "|"  + Transform( _nTOTGRUP1 , "@E 999999" )
		@ Li,140 PSAY  "|"  + Transform( _nTOTGRUP2 , "@E 999999" )
		@ Li,147 PSAY  "|"  + Transform( _nGRUP01  , "@E 999999" )
		@ Li,154 PSAY  "|"  + Transform( _nGRUP02  , "@E 999999" )
		@ Li,161 PSAY  "|"  + Transform( _nGRUP03  , "@E 999999" )
		@ Li,168 PSAY  "|"  + Transform( _nGRUP04  , "@E 999999" )
		@ Li,175 PSAY  "|"  + Transform( _nGRUP05  , "@E 999999" )
		@ Li,182 PSAY  "|"  + Transform( _nGRUP06  , "@E 999999" )
		@ Li,189 PSAY  "|"  + Transform( _nGRUP07  , "@E 999999" )
		@ Li,196 PSAY  "|"  + Transform( _nGRUP08  , "@E 999999" )
		@ Li,203 PSAY  "|"  + Transform( _nGRUP09  , "@E 999999" )
		@ Li,210 PSAY  "|"  + Transform( _nGRUP10  , "@E 999999" )
		@ Li,217 PSAY  "|"
		Li := 	Li+1
		@ Li,001 PSAY "|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		If _TipCliRed == 'C'
			@ Li,15 PSAY  " Numero de Clientes   " +	 str(_nCliAtivo,12)
			Li := 	Li+1
			@ Li,15 PSAY  " Valor da Meta  " +   str(_nValorMet,12,2)               // Preco Medio  - Grupo do 20o. parametro
		Endif
		Li := 80
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Endif

	Return
	//***********

	// Funcao de Impressao dos precos medios

	//***********
	Static Function Impr_Rel3a()
	//
	*******
	* Impressao
	*******
	_cTipoRel  := "(  P R E C O S  M E D I O S  )"
	titulo    :="CLASSIFICACAO DE CLIENTES ATIVOS (PRECOS)"
	_cKbFilial  := ""
	_cKbSegMerc := ""
	_cKbAgrupo  := ""
	_cKbRegiao  := ""
	_cKbVended  := ""
	Li := 80
	// Zero as Variaveis
	_nMetaCli := 0
	_nCT    := 0
	_nINAT  := 0
	_nFMA0  := 0
	_nF0    := 0
	_nF1    := 0
	_nFMA1  := 0
	_nNUMREDES := 0
	_nRedeQb := space(6)
	_cMarca  :=space(1)
	_nIPT := 0
	_nIPG := 0
	_nIPS := 0
	_nVLRPED := 0
	_nVLRPES := 0
	_nFREQUE := 0
	_nVLRPES := 0
	_nVLRFAT := 0
	_nPERCFAT := 0
	_nPESO := 0
	_nTOTGRUP1 := 0
	_nTOTGRUP2 := 0
	_nCliAtivo := 0
	_nPRC01	:= 0
	_nPRC02	:= 0
	_nPRC03	:= 0
	_nPRC04	:= 0
	_nPRC05	:= 0
	_nPRC06	:= 0
	_nPRC07	:= 0
	_nPRC08	:= 0
	_nPRC09	:= 0
	_nPRC10	:= 0
	_nPRC11	:= 0
	_nPRC12	:= 0
	_nPRC13	:= 0
	_nPRC14	:= 0
	_nPRC15	:= 0
	_nPRC16	:= 0

	_nPESIT01 :=0
	_nPESIT02 :=0
	_nPESIT03 :=0
	_nPESIT04 :=0
	_nPESIT05 :=0
	_nPESIT06 :=0
	_nPESIT07 :=0
	_nPESIT08 :=0
	_nPESIT09 :=0
	_nPESIT10 :=0
	_nPESIT11 :=0
	_nPESIT12 :=0
	_nPESIT13 :=0
	_nPESIT14 :=0
	_nPESIT15 :=0
	_nPESIT16 :=0
	dbSelectArea("REL3")
	dbSetOrder(1)
	dbGoTop()
	Do While !Eof()
		// // // //
		
		If REL3->_VENDED == _cCodVende
			// So imprime se for clientes
			// Soma clientes Ativos Junto com as redes
			_cMarca := ' '
			If REL3->_VALORFAT >= REL3->_CLIVALOR
				If SUBSTR(_SEQRELA,1,1) == 'R' .AND. SUBSTR(_SEQRELA,22,1) == 'T'
					// Faz uma marca se  for a soma
					_cMarca := '*'
				Else
					If SUBSTR(_SEQRELA,1,1) == 'C' .AND. SUBSTR(_SEQRELA,22,2) = '  '
						
					Else
						_nCliAtivo := _nCliAtivo + 1
					Endif
				Endif
			Endif
			
			If SUBSTR(_SEQRELA,1,1) = _TipCliRed .AND. REL3->_VALORFAT > 0
				// Frequencia do Cliente
				_nCT    = _CT   + _nCT
				_nINAT  = _INAT + _nINAT
				_nFMA0  = _FMA0 + _nFMA0
				_nF0    = _F0   + _nF0
				_nF1    = _F1   + _nF1
				_nFMA1  = _FMA1 + _nFMA1
				_nNUMREDES = REL3->_NUMREDES + _nNUMREDES
			Else
				dbSelectArea("REL3")
				dbSkip()
				Loop
			Endif
			// // //
			// // //
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			//                                                                                                   1                                                                                                   2
			//         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
			//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			//|  REGIAO DE VENDAS: CPS   CAMPINAS                                                                                                                                                                                        |
			//|******************************************************|********************|*****************|*****|***|**************|*****|*********|*************************( QUANTIDADE FATURADA (PESO) )****************************|
			//|                                                      |       INDICES      |  PEDIDO  MEDIO  |     |PRZ|    FATURA-   |  %  |  PESO   |  SUB TOTAL  |TEMPER|FRANGO|DESOSS|DESOSS|DESOSS|      |      |      |      |      |
			//|         CLIENTE                                      | IPG    IPS    IPR  |  VALOR |  PESO  |FREQ.|MED|     MENTO    |FATUR|  TOTAL  |GRUPO1|GRUPO2|P.V.A |P.V.A |P.V.A |P.V.A |P.V.A |      |      |      |      |      |
			//|******************************************************|******|******|******|********|********|*****|***|**************|*****|*********|******|******|******|******|******|******|******|******|******|******|******|******|
			//|000060 00 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX!      | 0,000| 0,000| 0,000|9   0,00|       0|  0,0|  0|        0,00  |  0,0|        0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|
			//|000060 00 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX!      | 0,000| 0,000| 0,000|    0,00|       0|  0,0|  0|        0,00  |  0,0|        0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|
			//|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			//|                                                      | 0,000| 0,000| 0,000|    0,00|       0|  0,0|   |        0,00  |  0,0|        0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|     0|
			//|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			//                                                                                                   1                                                                                                   2
			//         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
			//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			//|  REGIAO DE VENDAS : 000079  RG-SAO VICENTE/STOS                                                                                                                                                       |
			//|******************************************************|********************|*****************|****************************************(  P R E C O S  M E D I O S  )***********************************|
			//|                                              |LOJAS  |       INDICES      |  FATURAMENTO    |   1  |  2   |   3  |  4   |   5   |6EMPER|7RANGO|8ESOSS|9ESOSS|10SOSS|11    |12    |13    |14    |15    |
			//| Cliente                                              |  IPG   IPS    IPR  |  VALOR  |  PESO |      |      |      |      |       |P.V.A |P.V.A |P.V.A |P.V.A |P.V.A |      |      |      |      |      |
			//|******************************************************|******|******|******|*********|*******|******|******|******|******|*******|******|******|******|******|******|******|******|******|******|******|
			//|016945 00 CIA BRASILEIRA DE DISTRIBUICAO LTDA | 00000 | 0,000| 0,000| 0,000|9999990,0|9999999|0,0000|0,0000|0,0000|0,0000|0,00000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|
			//|016952 00 CIA BRASILEIRA DE DISTRIBUICAO LTDA | 00000 | 0,000| 0,000| 0,000|      0,0| 0,0   |0,0000|0,0000|0,0000|0,0000|0,00000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|
			//|016953 00 CIA BRASILEIRA DE DISTRIBUICAO LTDA | 00000 | 0,000| 0,000| 0,000|      0,0| 0,0   |0,0000|0,0000|0,0000|0,0000|0,00000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|
			//|017290 00 SUPERMERCADOS ONDAS DA PRAIA GRANDE | 00000 | 0,000| 0,000| 0,000|      0,0| 0,0   |0,0000|0,0000|0,0000|0,0000|0,00000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|0,0000|
			//|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			//| CT=9999 F>0=999   F0=194    F1=999   F>1=999         | 0,000| 0,000| 0,000|  4276,80|      0|0,0000|0,0000|0,0000|0,0000|0,00000|0,0000|0,0000|0,0000|0,0000|1,4741|0,0000|0,0000|0,0000|0,0000|0,0000|
			//|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
			If li > 64
				Li := 8
				_cPeriodo := " - Periodo de "+DtoC(_DATAINI )+" a "+DtoC(_DATAFIM )  +"        Lote: "+_cLoteCli
				Cabec(Titulo+_cPeriodo,Cabec1,Cabec2,NomeProg,Tamanho,18)
				@ Li,001 PSAY "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
				Li := Li + 1
				@ Li,001 PSAY "|"
				If _TipCliRed == 'C'
					@ Li,04        PSAY "REGIAO DE VENDAS : " +REL3->_VENDED+'  '+ SA3->A3_NOME
				Else
					@ Li,04        PSAY "REGIAO DE VENDAS : " +REL3->_VENDED+'  '+ SA3->A3_NOME+'       " CONTROLES DAS REDES " '
				Endif
				@ Li,224 PSAY "|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|*********************|*****************|***********************************************"+_cTipoRel+"**************************************************|"
				Li := Li + 1
				If _TipCliRed == 'C'
					@ Li,001 PSAY "|                                              |LOJAS  |        INDICES      |  FATURAMENTO    |"
				Else
					@ Li,001 PSAY "|                                               REDE   |        INDICES      |  FATURAMENTO    |"
				Endif
				// @ Li,Pcol() PSAY (_mGrupoPrc[1,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[2,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[3,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[4,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[5,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[6,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[7,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[8,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[9,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[10,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[11,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[12,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[13,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[14,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[15,2])+"|"
				// @ Li,Pcol() PSAY (_mGrupoPrc[16,2])+"|"
				
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				@ Li,Pcol() PSAY space(7)+"|"
				
				
				_cBMGp01 = (_mGrupoPrc[1,3])
				_cBMGp02 = (_mGrupoPrc[2,3])
				_cBMGp03 = (_mGrupoPrc[3,3])
				_cBMGp04 = (_mGrupoPrc[4,3])
				_cBMGp05 = (_mGrupoPrc[5,3])
				_cBMGp06 = (_mGrupoPrc[6,3])
				_cBMGp07 = (_mGrupoPrc[7,3])
				_cBMGp08 = (_mGrupoPrc[8,3])
				_cBMGp09 = (_mGrupoPrc[9,3])
				_cBMGp10 = (_mGrupoPrc[10,3])
				_cBMGp11 = (_mGrupoPrc[11,3])
				_cBMGp12 = (_mGrupoPrc[12,3])
				_cBMGp13 = (_mGrupoPrc[13,3])
				_cBMGp14 = (_mGrupoPrc[14,3])
				_cBMGp15 = (_mGrupoPrc[15,3])
				_cBMGp16 = (_mGrupoPrc[16,3])
				Li := Li + 1
				@ Li,001 PSAY "| Cliente                                              |   IPT   IPG    IPS  |  VALOR  |  PESO |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"
				//@ Li,001 PSAY "| Cliente                                              |   IPG   IPS    IPR  |  VALOR  |  PESO |"+_cBMGp01+"|"+_cBMGp02+"|"+_cBMGp03+"|"+_cBMGp04+"|"+_cBMGp05+"|"+_cBMGp06+"|"+_cBMGp07+"|"+_cBMGp08+"|"+_cBMGp09+"|"+_cBMGp10+"|"+_cBMGp11+"|"+_cBMGp12+"|"+_cBMGp13+"|"+_cBMGp14+"|"+_cBMGp15+"|"+_cBMGp16+"|"
				Li := Li + 1
				@ Li,001 PSAY "|******************************************************|*********************|*****************|*******************************************************************************************************************************|"
				Li := Li + 1
			Endif
			//12345678901234567890123456789012345678901234567890123
			//|***************************************************|
			//|999999/01 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
			// Deve pular se for Total das Redes
			@ Li,001 PSAY  "|"
			@ Li,002 PSAY  REL3->_CLIENTE+' '+REL3->_LOJA    //  6 + 1 + 2 = 9
			If _TipCliRed == 'C'
				@ Li,012 PSAY  SUBSTR(REL3->_CLIDESC,1,34)		//  12 + 36 = 48
				@ Li,047 PSAY  "|"   + Transform( REL3->_NUMREDES , "@E 999" )
			Else
				@ Li,012 PSAY  SUBSTR(REL3->_CLIDESC,1,31)+_cMarca+' '+REL3->_REDE 		//  12 + 36 = 48
			Endif
			@ Li,056 PSAY  "|"   + Transform( REL3->_IPT  , "@E 9.999" )
			@ Li,063 PSAY  "|"   + Transform( REL3->_IPG  , "@E 9.999" )
			@ Li,070 PSAY  "|"   + Transform( REL3->_IPS  , "@E 9.999" )
			@ Li,078 PSAY  "|"   + Transform( REL3->_VALORFAT  , "@E 999999.99" )
			@ Li,088 PSAY  "|"   + Transform( REL3->_PESOTOT   , "@E 9999999" )
			@ Li,096 PSAY  "|"   + Transform( REL3->_PRECO01  , "@E 99.9999" )
			@ Li,104 PSAY  "|"   + Transform( REL3->_PRECO02  , "@E 99.9999" )
			@ Li,112 PSAY  "|"   + Transform( REL3->_PRECO03  , "@E 99.9999" )
			@ Li,120 PSAY  "|"   + Transform( REL3->_PRECO04  , "@E 99.9999" )
			@ Li,128 PSAY  "|"   + Transform( REL3->_PRECO05  , "@E 99.9999" )
			@ Li,136 PSAY  "|"   + Transform( REL3->_PRECO06  , "@E 99.9999" )
			@ Li,144 PSAY  "|"   + Transform( REL3->_PRECO07  , "@E 99.9999" )
			@ Li,152 PSAY  "|"   + Transform( REL3->_PRECO08  , "@E 99.9999" )
			@ Li,160 PSAY  "|"   + Transform( REL3->_PRECO09  , "@E 99.9999" )
			@ Li,168 PSAY  "|"   + Transform( REL3->_PRECO10  , "@E 99.9999" )
			@ Li,176 PSAY  "|"   + Transform( REL3->_PRECO11  , "@E 99.9999" )
			@ Li,184 PSAY  "|"   + Transform( REL3->_PRECO12  , "@E 99.9999" )
			@ Li,192 PSAY  "|"   + Transform( REL3->_PRECO13  , "@E 99.9999" )
			@ Li,200 PSAY  "|"   + Transform( REL3->_PRECO14  , "@E 99.9999" )
			@ Li,208 PSAY  "|"   + Transform( REL3->_PRECO15  , "@E 99.9999" )
			@ Li,216 PSAY  "|"   + Transform( REL3->_PRECO16  , "@E 99.9999" )
			@ Li,224 PSAY  "|"
			Li := Li + 1
			If SUBSTR(_SEQRELA,1,1) == 'R' .AND. SUBSTR(_SEQRELA,22,1) == 'T'
				@ Li,001 PSAY  "|"
				@ Li,217 PSAY  "|"
				Li := Li + 1
			Endif
			
			// Soma clientes Ativos
			If REL3->_CLIVALOR	<> 0 .and. REL3->_CLIMETA <> 0
				_nValorMet := REL3->_CLIVALOR
				_nMetaCli  := REL3->_CLIMETA
			Endif
			// Pondero os Indices
			//
			If SUBSTR(_SEQRELA,1,1) = 'R' .AND. SUBSTR(_SEQRELA,22,1) = 'T'
				_nPERCFAT = 0
			Else
				If (REL3->_PESOTOT + _nPESO) > 0   
					If REL3->_IPT > 0 
						If _nIPT = 0
							_nCalcQuo := (REL3->_IPT * REL3->_PESOTOT ) 
						Else                                                                                                   
							_nCalcQuo := ((REL3->_IPT * REL3->_PESOTOT ) + (_nIPT * _nPESO))					
						Endif
						_nCalcDiv := ((REL3->_PESOTOT + _nPESO))
						//_nIPT     := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPT     :=  (_nCalcQuo / _nCalcDiv)
					Endif
					If REL3->_IPG > 0
						If _nIPG = 0
							_nCalcQuo := (REL3->_IPG * REL3->_PESOTOT ) 
						Else                                                                                                    
							_nCalcQuo := ((REL3->_IPG * REL3->_PESOTOT ) + (_nIPG * _nPESO))					
						Endif
						_nCalcDiv   := ((REL3->_PESOTOT + _nPESO))
						//_nIPG        := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPG        := (_nCalcQuo / _nCalcDiv)					
					Endif
					If REL3->_IPS > 0
						If _nIPS = 0
							_nCalcQuo := (REL3->_IPS * REL3->_PESOTOT ) 
						Else                                                                                                    
							_nCalcQuo := ((REL3->_IPS * REL3->_PESOTOT ) + (_nIPS * _nPESO))					
						Endif
						_nCalcDiv   := ((REL3->_PESOTOT + _nPESO))
						//_nIPS         := ROUND(_nCalcQuo / _nCalcDiv,3)
						_nIPS         := (_nCalcQuo / _nCalcDiv)
					Endif
				Endif
				If _nVLRFAT > 0
					_nPERCFAT =  _nVLRFAT /_nToTTVLRFAT * 100
				Endif
				_nVLRPED = REL3->_VALORPED + _nVLRPED
				// Somo as colunas de grupos
				If (REL3->_PESOTOT + _nPESO) > 0
					If REL3->_PRECO01 <> 0
						_nPRC01ant :=_nPRC01
						_nPRC01 = ((REL3->_PRECO01 * REL3->_PESOTOT) + (_nPRC01ant * _nPESIT01)) /  (REL3->_PESOTOT + _nPESIT01)
						_nPESIT01  := _nPESIT01 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO02 <> 0
						_nPRC02ant :=_nPRC02
						_nPRC02 = ((REL3->_PRECO02 * REL3->_PESOTOT) + (_nPRC02ant * _nPESIT02)) /  (REL3->_PESOTOT + _nPESIT02)
						_nPESIT02  := _nPESIT02 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO03 <> 0
						_nPRC03ant :=_nPRC03
						_nPRC03 = ((REL3->_PRECO03 * REL3->_PESOTOT) + (_nPRC03ant * _nPESIT03)) /  (REL3->_PESOTOT + _nPESIT03)
						_nPESIT03  := _nPESIT03 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO04 <> 0
						_nPRC04ant :=_nPRC04
						_nPRC04 = ((REL3->_PRECO04 * REL3->_PESOTOT) + (_nPRC04ant * _nPESIT04)) /  (REL3->_PESOTOT + _nPESIT04)
						_nPESIT04  := _nPESIT04 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO05 <> 0
						_nPRC05ant =_nPRC05
						_nPRC05 = ((REL3->_PRECO05 * REL3->_PESOTOT) + (_nPRC05ant * _nPESIT05)) /  (REL3->_PESOTOT + _nPESIT05)
						_nPESIT05  := _nPESIT05 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO06 <> 0
						_nPRC06ant :=_nPRC06
						_nPRC06 = ((REL3->_PRECO06 * REL3->_PESOTOT) + (_nPRC06ant * _nPESIT06)) /  (REL3->_PESOTOT + _nPESIT06)
						_nPESIT06  := _nPESIT06 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO07 <> 0
						_nPRC07ant :=_nPRC07
						_nPRC07 = ((REL3->_PRECO07 * REL3->_PESOTOT) + (_nPRC07ant * _nPESIT07)) /  (REL3->_PESOTOT + _nPESIT07)
						_nPESIT07  := _nPESIT07 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO08 <> 0
						_nPRC08ant :=_nPRC08
						_nPRC08 = ((REL3->_PRECO08 * REL3->_PESOTOT) + (_nPRC08ant * _nPESIT08)) /  (REL3->_PESOTOT + _nPESIT08)
						_nPESIT08  := _nPESIT08 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO09 <> 0
						_nPRC09ant :=_nPRC09
						_nPRC09 = ((REL3->_PRECO09 * REL3->_PESOTOT) + (_nPRC09ant * _nPESIT09)) / (REL3->_PESOTOT + _nPESIT09)
						_nPESIT09  := _nPESIT09 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO10 <> 0
						_nPRC10ant :=_nPRC10
						_nPRC10 = ((REL3->_PRECO10 * REL3->_PESOTOT) + (_nPRC10ant * _nPESIT10)) /  (REL3->_PESOTOT + _nPESIT10)
						_nPESIT10  := _nPESIT10 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO11 <> 0
						_nPRC11ant :=_nPRC11
						_nPRC11 = ((REL3->_PRECO11 * REL3->_PESOTOT) + (_nPRC11ant * _nPESIT11)) /  (REL3->_PESOTOT + _nPESIT11)
						_nPESIT11  := _nPESIT11 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO12 <> 0
						_nPRC12ant :=_nPRC12
						_nPRC12 = ((REL3->_PRECO12 * REL3->_PESOTOT) + (_nPRC12ant * _nPESIT12)) /  (REL3->_PESOTOT + _nPESIT12)
						_nPESIT12  := _nPESIT12 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO13 <> 0
						_nPRC13ant :=_nPRC13
						_nPRC13 = ((REL3->_PRECO13 * REL3->_PESOTOT) + (_nPRC13ant * _nPESIT13)) /  (REL3->_PESOTOT + _nPESIT13)
						_nPESIT13  := _nPESIT13 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO14 <> 0
						_nPRC14ant :=_nPRC14
						_nPRC14 = ((REL3->_PRECO14 * REL3->_PESOTOT) + (_nPRC14ant * _nPESIT14)) /  (REL3->_PESOTOT + _nPESIT14)
						_nPESIT14  := _nPESIT14 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO15 <> 0
						_nPRC15ant :=_nPRC15
						_nPRC15 = ((REL3->_PRECO15 *REL3->_PESOTOT) + (_nPRC15ant * _nPESIT15)) /  (REL3->_PESOTOT + _nPESIT15)
						_nPESIT15  := _nPESIT15 + REL3->_PESOTOT
					Endif
					If REL3->_PRECO16 <> 0
						_nPRC16ant :=_nPRC16
						_nPRC16 = ((REL3->_PRECO16 *REL3->_PESOTOT) + (_nPRC16ant * _nPESIT16)) /  (REL3->_PESOTOT + _nPESIT16)
						_nPESIT16  := _nPESIT16 + REL3->_PESOTOT
					Endif
					
					// Faz somatoria dos totais
					_nPESO   := REL3->_PESOTOT  + _nPESO
					_nFREQUE := REL3->_FREQUE   + _nFREQUE
					_nVLRFAT := REL3->_VALORFAT + _nVLRFAT
				Endif
			Endif
			_nRedeQb := REL3->	_REDE
		Endif
		dbSelectArea("REL3")
		dbSkip()
	Enddo
	If  (_nCT  + _nINAT) > 0
		@ Li,001 PSAY "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		@ Li,001 PSAY  "|"
		@ Li,003 PSAY  "CT=" + Transform(_nCT , "@E 9999" )
		@ Li,013 PSAY  "F>0=" + Transform(_nFMA0, "@E 999" )
		@ Li,023 PSAY  "F0=" + Transform(_nF0, "@E 999" )
		@ Li,033 PSAY  "F>1=" + Transform(_nF1, "@E 999" )
		@ Li,042 PSAY  "F1=" + Transform(_nFMA1, "@E 999" )
		@ Li,056 PSAY  "|"  + Transform( _nIPT  , "@E 9.999" )
		@ Li,063 PSAY  "|"  + Transform( _nIPG  , "@E 9.999" )
		@ Li,070 PSAY  "|"  + Transform( _nIPS  , "@E 9.999" )
		@ Li,078 PSAY  "|"  + Transform( _nVLRFAT  , "@E 99999.99")
		@ Li,088 PSAY  "|"  + Transform( _nPESO  , "@E 999999" )
		
		@ Li,096 PSAY  "|"    + Transform( _nPRC01  , "@E 99.9999" )
		@ Li,104 PSAY  "|"    + Transform( _nPRC02  , "@E 99.9999" )
		@ Li,112 PSAY  "|"    + Transform( _nPRC03  , "@E 99.9999" )
		@ Li,120 PSAY  "|"    + Transform( _nPRC04  , "@E 99.9999" )
		@ Li,128 PSAY  "|"    + Transform( _nPRC05  , "@E 99.9999" )
		@ Li,136 PSAY  "|"    + Transform( _nPRC06  , "@E 99.9999" )
		@ Li,144 PSAY  "|"    + Transform( _nPRC07  , "@E 99.9999" )
		@ Li,152 PSAY  "|"    + Transform( _nPRC08  , "@E 99.9999" )
		@ Li,160 PSAY  "|"    + Transform( _nPRC09  , "@E 99.9999" )
		@ Li,168 PSAY  "|"    + Transform( _nPRC10  , "@E 99.9999" )
		@ Li,176 PSAY  "|"    + Transform( _nPRC11  , "@E 99.9999" )
		@ Li,184 PSAY  "|"    + Transform( _nPRC12  , "@E 99.9999" )
		@ Li,192 PSAY  "|"    + Transform( _nPRC13  , "@E 99.9999" )
		@ Li,200 PSAY  "|"    + Transform( _nPRC14  , "@E 99.9999" )
		@ Li,208 PSAY  "|"    + Transform( _nPRC15  , "@E 99.9999" )
		@ Li,216 PSAY  "|"    + Transform( _nPRC16  , "@E 99.9999" )
		@ Li,224 PSAY  "|"
		Li := 	Li+1
		@ Li,001 PSAY  "|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
		Li := 	Li+1
		If _TipCliRed == 'C'
			@ Li,45 PSAY  " Numero de Clientes " +	 str(_nCliAtivo,12)
			Li := 	Li+1
			@ Li,15 PSAY  " Valor da Meta  " +   str(REL3->_CLIVALOR,12,2)               // Preco Medio  - Grupo do 20o. parametro
		Endif
		Li := 80
	Endif

	Return

	//***********
	// Sub-Rotina que grava Indices
	Static Function Grav_Arq3()

	// Variaveis dos Indices
	_nVlr_IPT = 0   // Indices IPT
	_nVlr_IPG = 0   // Indices IPG
	_nVlr_IPS = 0   // Indices IPS

	dbSelectArea("REL3")             // _cIndex   := "_SEQRELA"
	dbSetOrder(1)
	dbGoTop()


	// Monto a chave conforme o tipo de cliente
	_cTrIndice :=_cPref+_cSeqInvert + _cRede  + _cCtrCliente

	If dbSeek(_cVENDED + _cTrIndice)
		RecLock("REL3",.F.)   //  com .f. sem append blank
	Else
		RecLock("REL3",.T.)   // com .t. com append blank
		
		Replace _SEQRELA    WITH _cTrIndice         // Controle para sequencia do Relatorio
		Replace _DATAINI       With  SZ7->Z7_DATINI         // Data Inicial
		Replace _DATAFIM     With  SZ7->Z7_DATFIM         // Data Final
		Replace _SEGMERC   WITH SZ7->Z7_SEGMERC   // Segmento de Mercado
		Replace _SEGDESC   WITH SZ7->Z7_SEGDESC   // Descricao Segmento de Mercado
		Replace _REGIAO       WITH SZ7->Z7_REGIAO    // Regiao
		Replace _REGDESC   WITH SZ7->Z7_REGDESC   // Descricao da Regiao
		Replace _VENDED     WITH _cVENDED 		   // Vendedor
		Replace _VENDESC   WITH _cVENDESC  		   // Vendedor
		Replace _REDE          WITH SZ7->Z7_REDE      //  Rede que o Cliente pertence
		Replace _CLIENTE     WITH _cCLIENTE          // Quebra - Cliente
		Replace _CLIDESC     WITH _cCLINOME          // Quebra - Cliente
		Replace _UF               WITH _cUF               // Estado  - Cliente
		Replace _MUN            WITH _cMUN              // Municipio  - Cliente
		Replace _LOJA           WITH SZ7->Z7_LOJA      // Quebra - Loja
	Endif

	If SZ7->Z7_PESTOT > 0
		_nTotPesInd := _nTotPesInd + SZ7->Z7_PESTOT	
		If REL3->_IPT <> 0
			_nCalVlr1 := ((REL3->_IPT * REL3->_PESOTOT) + (SZ7->Z7_IPT * SZ7->Z7_PESTOT))
			_nCalQtd1 := (REL3->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPT := round((_nCalVlr1 / _nCalQtd1),3)
			_nVlr_IPT :=  (_nCalVlr1 / _nCalQtd1)
		Else
			_nVlr_IPT := SZ7->Z7_IPT
		Endif
		If REL3->_IPG <> 0
			_nCalVlr2 := ((REL3->_IPG * REL3->_PESOTOT) + (SZ7->Z7_IPG *SZ7->Z7_PESTOT))
			_nCalQtd2 := (REL3->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPG := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPG :=  (_nCalVlr2 / _nCalQtd2)
		Else
			_nVlr_IPG := SZ7->Z7_IPG
		Endif
		If REL3->_IPS <> 0
			_nCalVlr3 := ((REL3->_IPS *REL3->_PESOTOT) + (SZ7->Z7_IPS * SZ7->Z7_PESTOT))
			_nCalQtd3 := (REL3->_PESOTOT + SZ7->Z7_PESTOT)
			//_nVlr_IPS := round((_nCalVlr2 / _nCalQtd2),3)
			_nVlr_IPS :=  (_nCalVlr3 / _nCalQtd3)		
		Else
			_nVlr_IPS := SZ7->Z7_IPS
		Endif

	Endif


	Replace _CT                WITH _CT   + SZ7->Z7_CT    // Clientes Total
	Replace _INAT             WITH _INAT + SZ7->Z7_INAT  // Clientes Inativos
	Replace _FMA0           WITH _FMA0 + SZ7->Z7_FMA0  // Frequencia > 0
	Replace _F0                WITH _F0   + SZ7->Z7_F0    // Frequencia = 0
	Replace _F1                WITH _F1   + SZ7->Z7_F1    // Frequencia = 1
	Replace _FMA1           WITH _FMA1 + SZ7->Z7_FMA1  // Frequencia > 1
	Replace _NUMREDES  WITH _NUMREDES + _nLoja     // Numero de Lojas da Rede
	If _nVlr_IPT > 0  .and.  _nVlr_IPT < 9.999
		Replace _IPT                WITH _nVlr_IPT   // Indices IPT
	Endif
	If _nVlr_IPG > 0  .and.  _nVlr_IPG < 9.999
		Replace _IPG               WITH _nVlr_IPG   // Indices IPG
	Endif
	If _nVlr_IPS > 0   .and.  _nVlr_IPS < 9.999
		Replace _IPS               WITH _nVlr_IPS   // Indices IPS
	Endif

	Replace _FREQUE       WITH _FREQUE + SZ7->Z7_FREQUE  // Frequencia
	Replace _PRAZOMED   WITH ((_PRAZOMED  * _VALORFAT) +(SZ7->Z7_PRZMED *SZ7->Z7_VLRFAT))/ (_VALORFAT+SZ7->Z7_VLRFAT) // Prazo Medio
	Replace _GRUPOPROD WITH SZ7->Z7_GRUPO     // Grupo Produto
	Replace _GRUPO01       WITH _GRUPO01 + SZ7->Z7_QTGP01  // Qtd Faturada - Grupo do 1o. parametro
	Replace _GRUPO02       WITH _GRUPO02 + SZ7->Z7_QTGP02  // Qtd Faturada - Grupo do 2o. parametro
	Replace _GRUPO03       WITH _GRUPO03 + SZ7->Z7_QTGP03  // Qtd Faturada - Grupo do 3o. parametro
	Replace _GRUPO04       WITH _GRUPO04 + SZ7->Z7_QTGP04  // Qtd Faturada - Grupo do 4o. parametro
	Replace _GRUPO05        WITH _GRUPO05 + SZ7->Z7_QTGP05  // Qtd Faturada - Grupo do 5o. parametro
	Replace _GRUPO06        WITH _GRUPO06 + SZ7->Z7_QTGP06  // Qtd Faturada - Grupo do 6o. parametro
	Replace _GRUPO07        WITH _GRUPO07 + SZ7->Z7_QTGP07  // Qtd Faturada - Grupo do 7o. parametro
	Replace _GRUPO08        WITH _GRUPO08 + SZ7->Z7_QTGP08  // Qtd Faturada - Grupo do 8o. parametro
	Replace _GRUPO09        WITH _GRUPO09 + SZ7->Z7_QTGP09  // Qtd Faturada - Grupo do 9o. parametro
	Replace _GRUPO10        WITH _GRUPO10 + SZ7->Z7_QTGP10  // Qtd Faturada - Grupo do 10o. parametro
	Replace _GRUPO11        WITH _GRUPO11 + SZ7->Z7_QTGP11  // Qtd Faturada - Grupo do 11o. parametro
	Replace _GRUPO12        WITH _GRUPO12 + SZ7->Z7_QTGP12  // Qtd Faturada - Grupo do 12o. parametro
	Replace _GRUPO13        WITH _GRUPO13 + SZ7->Z7_QTGP13  // Qtd Faturada - Grupo do 13o. parametro
	Replace _GRUPO14        WITH _GRUPO14 + SZ7->Z7_QTGP14  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO15        WITH _GRUPO15 + SZ7->Z7_QTGP15  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO16        WITH _GRUPO16 + SZ7->Z7_QTGP16  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO17        WITH _GRUPO17 + SZ7->Z7_QTGP17  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO18        WITH _GRUPO18 + SZ7->Z7_QTGP18  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO19        WITH _GRUPO19 + SZ7->Z7_QTGP19  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO20        WITH _GRUPO20 + SZ7->Z7_QTGP20  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO21        WITH _GRUPO21 + SZ7->Z7_QTGP21  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO22        WITH _GRUPO22 + SZ7->Z7_QTGP22  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO23        WITH _GRUPO23 + SZ7->Z7_QTGP23  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO24        WITH _GRUPO24 + SZ7->Z7_QTGP24  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO25        WITH _GRUPO25 + SZ7->Z7_QTGP25  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO26         WITH _GRUPO26 + SZ7->Z7_QTGP26  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO27         WITH _GRUPO27 + SZ7->Z7_QTGP27  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO28         WITH _GRUPO28 + SZ7->Z7_QTGP28  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO29          WITH _GRUPO29 + SZ7->Z7_QTGP29  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO30          WITH _GRUPO30 + SZ7->Z7_QTGP30  // Qtd Faturada - Grupo do 14o. parametro
	Replace _GRUPO31          WITH _GRUPO30 + SZ7->Z7_QTGP31
	Replace _GRUPO32          WITH _GRUPO30 + SZ7->Z7_QTGP32
	Replace _GRUPO33          WITH _GRUPO30 + SZ7->Z7_QTGP33
	Replace _GRUPO34          WITH _GRUPO30 + SZ7->Z7_QTGP34
	Replace _GRUPO35          WITH _GRUPO30 + SZ7->Z7_QTGP35
	Replace _GRUPO36          WITH _GRUPO30 + SZ7->Z7_QTGP36
	Replace _GRUPO37          WITH _GRUPO30 + SZ7->Z7_QTGP37
	Replace _GRUPO38          WITH _GRUPO30 + SZ7->Z7_QTGP38
	Replace _GRUPO39          WITH _GRUPO30 + SZ7->Z7_QTGP39
	Replace _GRUPO40          WITH _GRUPO30 + SZ7->Z7_QTGP40
	Replace _GRUPO41          WITH _GRUPO30 + SZ7->Z7_QTGP41
	Replace _GRUPO42          WITH _GRUPO30 + SZ7->Z7_QTGP42
	Replace _GRUPO43          WITH _GRUPO30 + SZ7->Z7_QTGP43
	Replace _GRUPO44          WITH _GRUPO30 + SZ7->Z7_QTGP44
	Replace _GRUPO45          WITH _GRUPO30 + SZ7->Z7_QTGP45
	Replace _GRUPO46          WITH _GRUPO30 + SZ7->Z7_QTGP46
	Replace _GRUPO47          WITH _GRUPO30 + SZ7->Z7_QTGP47
	Replace _GRUPO48          WITH _GRUPO30 + SZ7->Z7_QTGP48
	Replace _GRUPO49          WITH _GRUPO30 + SZ7->Z7_QTGP49
	Replace _GRUPO50          WITH _GRUPO30 + SZ7->Z7_QTGP50

	Replace _PRECO01   WITH ((_PRECO01 * _PESOTOT)+SZ7->Z7_VLR01) /(SZ7->Z7_QTD01 +_PESOTOT)   // Preco Medio  - Grupo do 1o. parametro
	Replace _PRECO02   WITH ((_PRECO02 * _PESOTOT)+SZ7->Z7_VLR02) /(SZ7->Z7_QTD02 +_PESOTOT)   // Preco Medio  - Grupo do 2o. parametro
	Replace _PRECO03   WITH ((_PRECO03 * _PESOTOT)+SZ7->Z7_VLR03) /(SZ7->Z7_QTD03 +_PESOTOT)   // Preco Medio  - Grupo do 3o. parametro
	Replace _PRECO04   WITH ((_PRECO04 * _PESOTOT)+SZ7->Z7_VLR04) /(SZ7->Z7_QTD04 +_PESOTOT)   // Preco Medio  - Grupo do 4o. parametro
	Replace _PRECO05   WITH ((_PRECO05 * _PESOTOT)+SZ7->Z7_VLR05) /(SZ7->Z7_QTD05 +_PESOTOT)   // Preco Medio  - Grupo do 5o. parametro
	Replace _PRECO06   WITH ((_PRECO06 * _PESOTOT)+SZ7->Z7_VLR06) /(SZ7->Z7_QTD06 +_PESOTOT)   // Preco Medio  - Grupo do 6o. parametro
	Replace _PRECO07   WITH ((_PRECO07 * _PESOTOT)+SZ7->Z7_VLR07) /(SZ7->Z7_QTD07 +_PESOTOT)   // Preco Medio  - Grupo do 7o. parametro
	Replace _PRECO08   WITH ((_PRECO08 * _PESOTOT)+SZ7->Z7_VLR08) /(SZ7->Z7_QTD08 +_PESOTOT)   // Preco Medio  - Grupo do 8o. parametro
	Replace _PRECO09   WITH ((_PRECO09 * _PESOTOT)+SZ7->Z7_VLR09) /(SZ7->Z7_QTD09 +_PESOTOT)   // Preco Medio  - Grupo do 9o. parametro
	Replace _PRECO10   WITH ((_PRECO10 * _PESOTOT)+SZ7->Z7_VLR10) /(SZ7->Z7_QTD10 +_PESOTOT)   // Preco Medio  - Grupo do 10o. parametro
	Replace _PRECO11   WITH ((_PRECO11 * _PESOTOT)+SZ7->Z7_VLR11) /(SZ7->Z7_QTD11 +_PESOTOT)   // Preco Medio  - Grupo do 11o. parametro
	Replace _PRECO12   WITH ((_PRECO12 * _PESOTOT)+SZ7->Z7_VLR12) /(SZ7->Z7_QTD12 +_PESOTOT)   // Preco Medio  - Grupo do 12o. parametro
	Replace _PRECO13   WITH ((_PRECO13 * _PESOTOT)+SZ7->Z7_VLR13) /(SZ7->Z7_QTD13 +_PESOTOT)   // Preco Medio  - Grupo do 13o. parametro
	Replace _PRECO14   WITH ((_PRECO14 * _PESOTOT)+SZ7->Z7_VLR14) /(SZ7->Z7_QTD14 +_PESOTOT)   // Preco Medio  - Grupo do 14o. parametro
	Replace _PRECO15   WITH ((_PRECO15 * _PESOTOT)+SZ7->Z7_VLR15) /(SZ7->Z7_QTD15 +_PESOTOT)   // Preco Medio  - Grupo do 15o. parametro
	Replace _PRECO16   WITH ((_PRECO16 * _PESOTOT)+SZ7->Z7_VLR16) /(SZ7->Z7_QTD16 +_PESOTOT)   // Preco Medio  - Grupo do 16o. parametro
	Replace _PRECO17   WITH ((_PRECO17 * _PESOTOT)+SZ7->Z7_VLR17) /(SZ7->Z7_QTD17 +_PESOTOT)   // Preco Medio  - Grupo do 17o. parametro
	Replace _PRECO18   WITH ((_PRECO18 * _PESOTOT)+SZ7->Z7_VLR18) /(SZ7->Z7_QTD18 +_PESOTOT)   // Preco Medio  - Grupo do 18o. parametro
	Replace _PRECO19   WITH ((_PRECO19 * _PESOTOT)+SZ7->Z7_VLR19) /(SZ7->Z7_QTD19 +_PESOTOT)   // Preco Medio  - Grupo do 19o. parametro
	Replace _PRECO20   WITH ((_PRECO20 * _PESOTOT)+SZ7->Z7_VLR20) /(SZ7->Z7_QTD20 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO21   WITH ((_PRECO21 * _PESOTOT)+SZ7->Z7_VLR21) /(SZ7->Z7_QTD21 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO22   WITH ((_PRECO22 * _PESOTOT)+SZ7->Z7_VLR22) /(SZ7->Z7_QTD22 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO23   WITH ((_PRECO23 * _PESOTOT)+SZ7->Z7_VLR23) /(SZ7->Z7_QTD23 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO24   WITH ((_PRECO24 * _PESOTOT)+SZ7->Z7_VLR24) /(SZ7->Z7_QTD24 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO25   WITH ((_PRECO25 * _PESOTOT)+SZ7->Z7_VLR25) /(SZ7->Z7_QTD25 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO26   WITH ((_PRECO26 * _PESOTOT)+SZ7->Z7_VLR26) /(SZ7->Z7_QTD26 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO27   WITH ((_PRECO27 * _PESOTOT)+SZ7->Z7_VLR27) /(SZ7->Z7_QTD27 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO28   WITH ((_PRECO28 * _PESOTOT)+SZ7->Z7_VLR28) /(SZ7->Z7_QTD28 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO29   WITH ((_PRECO29 * _PESOTOT)+SZ7->Z7_VLR29) /(SZ7->Z7_QTD29 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO30   WITH ((_PRECO30 * _PESOTOT)+SZ7->Z7_VLR30) /(SZ7->Z7_QTD30 +_PESOTOT)   // Preco Medio  - Grupo do 20o. parametro
	Replace _PRECO31   WITH ((_PRECO31 * _PESOTOT)+SZ7->Z7_VLR31) /(SZ7->Z7_QTD31 +_PESOTOT)
	Replace _PRECO32   WITH ((_PRECO32 * _PESOTOT)+SZ7->Z7_VLR32) /(SZ7->Z7_QTD32 +_PESOTOT)
	Replace _PRECO33   WITH ((_PRECO33 * _PESOTOT)+SZ7->Z7_VLR33) /(SZ7->Z7_QTD33 +_PESOTOT)
	Replace _PRECO34   WITH ((_PRECO34 * _PESOTOT)+SZ7->Z7_VLR34) /(SZ7->Z7_QTD34 +_PESOTOT)
	Replace _PRECO35   WITH ((_PRECO35 * _PESOTOT)+SZ7->Z7_VLR35) /(SZ7->Z7_QTD35 +_PESOTOT)
	Replace _PRECO36   WITH ((_PRECO36 * _PESOTOT)+SZ7->Z7_VLR36) /(SZ7->Z7_QTD36 +_PESOTOT)
	Replace _PRECO37   WITH ((_PRECO37 * _PESOTOT)+SZ7->Z7_VLR37) /(SZ7->Z7_QTD37 +_PESOTOT)
	Replace _PRECO38   WITH ((_PRECO38 * _PESOTOT)+SZ7->Z7_VLR38) /(SZ7->Z7_QTD38 +_PESOTOT)
	Replace _PRECO39   WITH ((_PRECO39 * _PESOTOT)+SZ7->Z7_VLR39) /(SZ7->Z7_QTD39 +_PESOTOT)
	Replace _PRECO40   WITH ((_PRECO40 * _PESOTOT)+SZ7->Z7_VLR40) /(SZ7->Z7_QTD40 +_PESOTOT)
	Replace _PRECO41   WITH ((_PRECO41 * _PESOTOT)+SZ7->Z7_VLR41) /(SZ7->Z7_QTD41 +_PESOTOT)
	Replace _PRECO42   WITH ((_PRECO42 * _PESOTOT)+SZ7->Z7_VLR42) /(SZ7->Z7_QTD42 +_PESOTOT)
	Replace _PRECO43   WITH ((_PRECO43 * _PESOTOT)+SZ7->Z7_VLR43) /(SZ7->Z7_QTD43 +_PESOTOT)
	Replace _PRECO44   WITH ((_PRECO44 * _PESOTOT)+SZ7->Z7_VLR44) /(SZ7->Z7_QTD44 +_PESOTOT)
	Replace _PRECO45   WITH ((_PRECO45 * _PESOTOT)+SZ7->Z7_VLR45) /(SZ7->Z7_QTD45 +_PESOTOT)
	Replace _PRECO46   WITH ((_PRECO46 * _PESOTOT)+SZ7->Z7_VLR46) /(SZ7->Z7_QTD46 +_PESOTOT)
	Replace _PRECO47   WITH ((_PRECO47 * _PESOTOT)+SZ7->Z7_VLR47) /(SZ7->Z7_QTD47 +_PESOTOT)
	Replace _PRECO48   WITH ((_PRECO48 * _PESOTOT)+SZ7->Z7_VLR48) /(SZ7->Z7_QTD48 +_PESOTOT)
	Replace _PRECO49   WITH ((_PRECO49 * _PESOTOT)+SZ7->Z7_VLR49) /(SZ7->Z7_QTD49 +_PESOTOT)
	Replace _PRECO50   WITH ((_PRECO50 * _PESOTOT)+SZ7->Z7_VLR50) /(SZ7->Z7_QTD50 +_PESOTOT)

	//*******************************
	// Somatoria controle de precos
	//*******************************

	Replace _QTDPR01  WITH _QTDPR01 + SZ7->Z7_QTD01      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR02  WITH _QTDPR02 + SZ7->Z7_QTD02      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR03  WITH _QTDPR03 + SZ7->Z7_QTD03      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR04  WITH _QTDPR04 + SZ7->Z7_QTD04      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR05  WITH _QTDPR05 + SZ7->Z7_QTD05      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR06  WITH _QTDPR06 + SZ7->Z7_QTD06      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR07  WITH _QTDPR07 + SZ7->Z7_QTD07      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR08  WITH _QTDPR08 + SZ7->Z7_QTD08      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR09  WITH _QTDPR09 + SZ7->Z7_QTD09      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR10  WITH _QTDPR10 + SZ7->Z7_QTD10      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR11  WITH _QTDPR11 + SZ7->Z7_QTD11     // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR12  WITH _QTDPR12 + SZ7->Z7_QTD12      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR13  WITH _QTDPR13 + SZ7->Z7_QTD13      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR14  WITH _QTDPR14 + SZ7->Z7_QTD14      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR15  WITH _QTDPR15 + SZ7->Z7_QTD15      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR16  WITH _QTDPR16 + SZ7->Z7_QTD16      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR17  WITH _QTDPR17 + SZ7->Z7_QTD17      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR18  WITH _QTDPR18 + SZ7->Z7_QTD18      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR19  WITH _QTDPR19 + SZ7->Z7_QTD19      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR20  WITH _QTDPR20 + SZ7->Z7_QTD20      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR21  WITH _QTDPR21 + SZ7->Z7_QTD21      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR22  WITH _QTDPR22 + SZ7->Z7_QTD22      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR23  WITH _QTDPR23 + SZ7->Z7_QTD23      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR24  WITH _QTDPR24 + SZ7->Z7_QTD24      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR25  WITH _QTDPR25 + SZ7->Z7_QTD25      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR26  WITH _QTDPR26 + SZ7->Z7_QTD26      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR27  WITH _QTDPR27 + SZ7->Z7_QTD27      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR28  WITH _QTDPR28 + SZ7->Z7_QTD28      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR29  WITH _QTDPR29 + SZ7->Z7_QTD29      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR30  WITH _QTDPR30 + SZ7->Z7_QTD30      // Preco Medio  - Grupo de Quantidade
	Replace _QTDPR31  WITH _QTDPR31 + SZ7->Z7_QTD31
	Replace _QTDPR32  WITH _QTDPR32 + SZ7->Z7_QTD32
	Replace _QTDPR33  WITH _QTDPR33 + SZ7->Z7_QTD33
	Replace _QTDPR34  WITH _QTDPR34 + SZ7->Z7_QTD34
	Replace _QTDPR35  WITH _QTDPR35 + SZ7->Z7_QTD35
	Replace _QTDPR36  WITH _QTDPR36 + SZ7->Z7_QTD36
	Replace _QTDPR37  WITH _QTDPR37 + SZ7->Z7_QTD37
	Replace _QTDPR38  WITH _QTDPR38 + SZ7->Z7_QTD38
	Replace _QTDPR39  WITH _QTDPR39 + SZ7->Z7_QTD39
	Replace _QTDPR40  WITH _QTDPR40 + SZ7->Z7_QTD40
	Replace _QTDPR41  WITH _QTDPR41 + SZ7->Z7_QTD41
	Replace _QTDPR42  WITH _QTDPR42 + SZ7->Z7_QTD42
	Replace _QTDPR43  WITH _QTDPR43 + SZ7->Z7_QTD43
	Replace _QTDPR44  WITH _QTDPR44 + SZ7->Z7_QTD44
	Replace _QTDPR45  WITH _QTDPR45 + SZ7->Z7_QTD45
	Replace _QTDPR46  WITH _QTDPR46 + SZ7->Z7_QTD46
	Replace _QTDPR47  WITH _QTDPR47 + SZ7->Z7_QTD47
	Replace _QTDPR48  WITH _QTDPR48 + SZ7->Z7_QTD48
	Replace _QTDPR49  WITH _QTDPR49 + SZ7->Z7_QTD49
	Replace _QTDPR50  WITH _QTDPR50 + SZ7->Z7_QTD50

	Replace _VLRPR01  WITH _VLRPR01 + SZ7->Z7_VLR01 // Preco Medio  - Grupo de Valores
	Replace _VLRPR02  WITH _VLRPR02 + SZ7->Z7_VLR02 // Preco Medio  - Grupo de Valores
	Replace _VLRPR03  WITH _VLRPR03 + SZ7->Z7_VLR03 // Preco Medio  - Grupo de Valores
	Replace _VLRPR04  WITH _VLRPR04 + SZ7->Z7_VLR04 // Preco Medio  - Grupo de Valores
	Replace _VLRPR05  WITH _VLRPR05 + SZ7->Z7_VLR05 // Preco Medio  - Grupo de Valores
	Replace _VLRPR06  WITH _VLRPR06 + SZ7->Z7_VLR06 // Preco Medio  - Grupo de Valores
	Replace _VLRPR07  WITH _VLRPR07 + SZ7->Z7_VLR07 // Preco Medio  - Grupo de Valores
	Replace _VLRPR08  WITH _VLRPR08 + SZ7->Z7_VLR08 // Preco Medio  - Grupo de Valores
	Replace _VLRPR09  WITH _VLRPR09 + SZ7->Z7_VLR09 // Preco Medio  - Grupo de Valores
	Replace _VLRPR10  WITH _VLRPR10 + SZ7->Z7_VLR10 // Preco Medio  - Grupo de Valores
	Replace _VLRPR11  WITH _VLRPR11 + SZ7->Z7_VLR11 // Preco Medio  - Grupo de Valores
	Replace _VLRPR12  WITH _VLRPR12 + SZ7->Z7_VLR12 // Preco Medio  - Grupo de Valores
	Replace _VLRPR13  WITH _VLRPR13 + SZ7->Z7_VLR13 // Preco Medio  - Grupo de Valores
	Replace _VLRPR14  WITH _VLRPR14 + SZ7->Z7_VLR14 // Preco Medio  - Grupo de Valores
	Replace _VLRPR15  WITH _VLRPR15 + SZ7->Z7_VLR15 // Preco Medio  - Grupo de Valores
	Replace _VLRPR16  WITH _VLRPR16 + SZ7->Z7_VLR16 // Preco Medio  - Grupo de Valores
	Replace _VLRPR17  WITH _VLRPR17 + SZ7->Z7_VLR17 // Preco Medio  - Grupo de Valores
	Replace _VLRPR18  WITH _VLRPR18 + SZ7->Z7_VLR18 // Preco Medio  - Grupo de Valores
	Replace _VLRPR19  WITH _VLRPR19 + SZ7->Z7_VLR19 // Preco Medio  - Grupo de Valores
	Replace _VLRPR20  WITH _VLRPR20 + SZ7->Z7_VLR20 // Preco Medio  - Grupo de Valores
	Replace _VLRPR21  WITH _VLRPR21 + SZ7->Z7_VLR21 // Preco Medio  - Grupo de Valores
	Replace _VLRPR22  WITH _VLRPR22 + SZ7->Z7_VLR22 // Preco Medio  - Grupo de Valores
	Replace _VLRPR23  WITH _VLRPR23 + SZ7->Z7_VLR23 // Preco Medio  - Grupo de Valores
	Replace _VLRPR24  WITH _VLRPR24 + SZ7->Z7_VLR24 // Preco Medio  - Grupo de Valores
	Replace _VLRPR25  WITH _VLRPR25 + SZ7->Z7_VLR25 // Preco Medio  - Grupo de Valores
	Replace _VLRPR26  WITH _VLRPR26 + SZ7->Z7_VLR26 // Preco Medio  - Grupo de Valores
	Replace _VLRPR27  WITH _VLRPR27 + SZ7->Z7_VLR27 // Preco Medio  - Grupo de Valores
	Replace _VLRPR28  WITH _VLRPR27 + SZ7->Z7_VLR28 // Preco Medio  - Grupo de Valores
	Replace _VLRPR29  WITH _VLRPR29 + SZ7->Z7_VLR29 // Preco Medio  - Grupo de Valores
	Replace _VLRPR30  WITH _VLRPR30 + SZ7->Z7_VLR30
	Replace _VLRPR31  WITH _VLRPR31 + SZ7->Z7_VLR31
	Replace _VLRPR32  WITH _VLRPR32 + SZ7->Z7_VLR32
	Replace _VLRPR33  WITH _VLRPR33 + SZ7->Z7_VLR33
	Replace _VLRPR34  WITH _VLRPR34 + SZ7->Z7_VLR34
	Replace _VLRPR35  WITH _VLRPR35 + SZ7->Z7_VLR35
	Replace _VLRPR36  WITH _VLRPR36 + SZ7->Z7_VLR36
	Replace _VLRPR37  WITH _VLRPR37 + SZ7->Z7_VLR37
	Replace _VLRPR38  WITH _VLRPR38 + SZ7->Z7_VLR38
	Replace _VLRPR39  WITH _VLRPR39 + SZ7->Z7_VLR39
	Replace _VLRPR40  WITH _VLRPR40 + SZ7->Z7_VLR40
	Replace _VLRPR41  WITH _VLRPR41 + SZ7->Z7_VLR41
	Replace _VLRPR42  WITH _VLRPR42 + SZ7->Z7_VLR42
	Replace _VLRPR43  WITH _VLRPR43 + SZ7->Z7_VLR43
	Replace _VLRPR44  WITH _VLRPR44 + SZ7->Z7_VLR44
	Replace _VLRPR45  WITH _VLRPR45 + SZ7->Z7_VLR45
	Replace _VLRPR46  WITH _VLRPR46 + SZ7->Z7_VLR46
	Replace _VLRPR47  WITH _VLRPR47 + SZ7->Z7_VLR47
	Replace _VLRPR48  WITH _VLRPR48 + SZ7->Z7_VLR48
	Replace _VLRPR49  WITH _VLRPR49 + SZ7->Z7_VLR49
	//Replace _VLRPR50  WITH _VLRPR50 + SZ7->Z7_VLR50

	Replace _PESOTOT   WITH _PESOTOT   + SZ7->Z7_PESTOT  // Peso Total
	Replace _VALORFAT  WITH _VALORFAT  + SZ7->Z7_VLRFAT  // Faturamento
	Replace _PERCFAT   WITH _VALORFAT / _nToTTVLRFAT * 100        // Peso Total
	Replace _VALORPED  WITH _VALORFAT / _FREQUE     // PEDIDO - Valor
	Replace _PESOPED   WITH _PESOTOT  / _FREQUE     // PEDIDO - Peso
	Replace _CLIMETA   WITH _nCliMeta               // Preco Medio  - Grupo do 20o. parametro
	Replace _CLIVALOR  WITH _nCliValor              // Preco Medio  - Grupo do 20o. parametro
	Replace _SEG1      WITH _cSeg1              // Segmento 1 do Cliente                   
	Replace _SEG2      WITH _cSeg2              // Segmento 2 do Cliente                   

Return