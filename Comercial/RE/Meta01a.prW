#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function META01A()
                         
Local _cRet := ""
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Meta de Vendas POR SUPERVISOR ( COMERCIAL )')


SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Meta01  ³ Autor ³  Marcos Bido          ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Meta de Vendas POR SUPERVISOR ( COMERCIAL )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Ateracoes³ Heraldo C. Hebling             11/12/02                    ³±±
±±³          ³1subsititido campo do cadastro de vendedores A3_SUPERVI     ³±±
±±³          ³ pelo campo A3_CODSUP (codigo do supervisor).               ³±±
±±³          ³2incluido os parametros: supervisor ate,                    ³±±
±±³          ³                         segmento de mercado de:            ³±±
±±³          ³                         segmento de mercado ate:           ³±±
±±³          ³3alterado o programa para tratar estes novos parametros     ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // De Data Entrega                      ³
//³ mv_par02             // Ate Data Entrega                     ³
//³ mv_par03             // Do Supervisor                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aOrd             := {}
tamanho          := "G"
limite           := 80
nomeprog         := "META"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg   := "META01"
Pergunte(cPerg,.F.)
IF EMPTY(MV_PAR04)
	MV_PAR04:="ZZZZZZ"
Endif
IF EMPTY(MV_PAR06)
	MV_PAR04:="ZZZ"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SC6"
titulo  := "REALIZADO DE VENDAS DIARIO "
cDesc1  := "Este programa tem como objetivo imprimir posicao VENDAS"
cDesc2  := "por SUPERVISOR / Vendedor participacao de vendas e volumes"
cDesc3  := " By Ad'Oro"
NomeRel := "META01A"

nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o cabecalho padrao para o relatorio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec1 := "| META01A.PRX "+SPACE(14)+"ADORO ALIMENTICIA  " +SPACE(10) + "Da  Entrega : " +DTOC(mv_par01)
Cabec2 := SPACE(20)+ TITULO +SPACE(10)+ "Ate Entrega : " + DTOC(MV_PAR02)
Cabec3 := "|--------------------------------------------------------------------------------|"
Cabec4 := "|  VENDEDOR     | PRODUTO |TOTAL CAIXA | TOTAL KILOS | TOTAL VALOR|  PRECO MEDIO |"
Cabec5 := "|--------------------------------------------------------------------------------|"
//                                   999,999,9999 99999,999.999 99999,999.99   9999.99
//         1 3            16 19     26           39            53           66            80

Cabec10 := "| META01A.PRX "+SPACE(15)+"ADORO ALIMENTICIA  " +SPACE(10) + "Da  Entrega : " +DTOC(mv_par01)
Cabec20 := SPACE(20)+ TITULO +SPACE(10)+ "Ate Entrega : " + DTOC(MV_PAR02)
Cabec30 := "|------------------------------------------------------------------------------|"
Cabec40 := "|                |QUANTIDADE CARTEIRA | QUANTIDADE ESTOQUE |    SALDOS         |"
Cabec50 := "| PRODUTO        |-------------------------------------------------------------|"
Cabec60 := "|                | CAIXAS |  QUILOS   | CAIXAS |   QUILOS  | CAIXAS|   QUILOS  |"
Cabec70 := "|------------------------------------------------------------------------------|"
//|!!! !!!!!!!!!!!!| 999,999|999,999.999| 999,999|999,999.999|999,999|999,999.999|
//2   6             20      28           41      49          61      69

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF WINDOWS
	Processa({|| RunCont()},Titulo )
	Return
	Static Function RunCont()
	ProcRegua(RecCount())
#ELSE
	SetRegua(RecCount())
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para totalizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru := {}
AADD (aStru,{"TR_FILIAL"   , "C",02,0})
AADD (aStru,{"TR_CODSUP"  , "C",06,0})
AADD (aStru,{"TR_NOMVEND"  , "C",12,0})
AADD (aStru,{"TR_VENDEDO"  , "C",06,0})
AADD (aStru,{"TR_PRODUTO"  , "C",06,0})
AADD (aStru,{"TR_DESCRI"   , "C",25,0})
AADD (aStru,{"TR_CAIXAS"   , "N",06,0})
AADD (aStru,{"TR_KILOS"    , "N",12,3})
AADD (aStru,{"TR_VALTOT"   , "N",12,2})
AADD (aStru,{"TR_PREMED"   , "N",12,2})
_cNomTrb := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

cIndex   := "TR_CODSUP + TR_VENDEDO + TR_PRODUTO"
IndRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )

dbSelectArea("TEMP")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SA3")
dbSetOrder(1)

DbSelectArea("SZR")
dbSetOrder(1)

DbSelectArea("SC6")
dbSetOrder(1)

//SET FILTER TO C6_ENTREG >= MV_PAR01 .AND. C6_ENTREG <= MV_PAR02
SET FILTER TO C6_ENTREG >= MV_PAR01 .AND. C6_ENTREG <= MV_PAR02 .AND. C6_FILIAL = CFILANT //ALTERADO LEONARDO (HC) PARA CONTEMPLAR A FILIAL CORRENTE
dbGotop()

While !EOF()
	
	_Produto  := C6_PRODUTO
	_Vendedor := C6_VEND
	_Qtd_Cxs  := C6_UNSVEN
	_Val_Tot  := C6_VALOR
	_Qtd_Qui  := C6_QTDVEN
	
	dbSelectArea("SB1")
	
	dbSeek(xfilial() + _Produto)
	
	dbSelectArea("SA3")
	dbSeek(xfilial() + _Vendedor)
	
	_Supervis := SA3->A3_CODSUP
	
	If _Supervis >= mv_par03	.AND.  _Supervis <= mv_par04
		dbSelectArea("SZR")				//CADASTRO DE SUPERVIDOR
		DBSETORDER(1)
		dbSeek(xfilial() + SA3->A3_CODSUP)
		If SZR->ZR_SEGMERC >= mv_par05 .AND. SZR->ZR_SEGMERC <= mv_par06
			
			dbSelectArea("TEMP")
			
			IF !dbSeek(_Supervis + _Vendedor + _Produto)
				
				RecLock("TEMP",.T.)
				
				Repl TR_FILIAL   with xFilial("SC6")
				Repl TR_CODSUP   with _Supervis
				Repl TR_VENDEDO  with _Vendedor
				Repl TR_NOMVEND  with SA3->A3_NREDUZ
				Repl TR_PRODUTO  with _PRODUTO
				Repl TR_CAIXAS   with _Qtd_Cxs
				Repl TR_KILOS    with _Qtd_Qui
				Repl TR_VALTOT   with _Val_Tot
				Repl TR_PREMED   with TR_VALTOT/TR_KILOS
				
				MsUnLock()
			ELSE
				// SOMAR AS QTD VENDIDAS NAS RESPECTIVOS GRUPOS
				
				RecLock("TEMP",.F.)
				
				Repl TR_CAIXAS   with TR_CAIXAS + _Qtd_Cxs
				Repl TR_KILOS    with TR_KILOS  + _Qtd_Qui
				Repl TR_VALTOT   with TR_VALTOT + _Val_Tot
				Repl TR_PREMED   with TR_VALTOT/TR_KILOS
				
				MsUnLock()
			Endif
		endif
	endif
	dbSelectArea("SC6")
	dbskip()
ENDDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A IMPRESSAO DO TEMP          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

titulo   := "REAL. DE VENDAS DIARIO - VENDEDOR "
Cabec2 := SPACE(20)+ TITULO +SPACE(04)+ "Ate Entrega : " + DTOC(MV_PAR02)

_Vendedor := "   "
_TvCaixas := 0
_Tvkilos  := 0
_TvValtot := 0
_TsCaixas := 0
_Tskilos  := 0
_TsValtot := 0
_TtCaixas := 0
_Ttkilos  := 0
_TtValtot := 0


/*
IF !EMPTY(MV_PAR03)
	SET FILTER TO !empty(TR_CODSUP)
ELSE
	SET FILTER TO !empty(TR_CODSUP) .AND. TR_CODSUP == MV_PAR03
ENDIF
*/
dbSelectArea("TEMP")
dbGoTop()

While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	IncProc(1)
	
	If nLin > 60
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	_Supervis := TR_CODSUP
	dbSelectArea("SZR")				//CADASTRO DE SUPERVIDOR
	DBSETORDER(1)
	dbSeek(xfilial() + _Supervis)
	_cNomeSupervisor	:=	SZR->ZR_DESCRIC
	
	dbSelectArea("TEMP")
	
	DO WHILE !EOF() .AND. TR_CODSUP == _Supervis
		
		_Vendedor  := TR_VENDEDO
		
		DO WHILE !EOF() .AND. TR_VENDEDO == _vendedor
			
			@nLin,000 PSAY "|"
			@nLin,001 PSAY  SUBSTR(TR_NOMVEND,1,10) + " " + SUBSTR(TR_VENDEDO,4,3)
			@nLin,019 PSAY  TR_PRODUTO
			@nLin,027 PSAY  TR_CAIXAS    PICTURE "@E 999,999,999"
			@nLin,040 PSAY  TR_KILOS     PICTURE "@E 999,999.999"
			@nLin,054 PSAY  TR_VALTOT    PICTURE "@E 9999,999.99"
			@nLin,068 PSAY  TR_PREMED    PICTURE "@E 99,999.999"
			
			_Tvcaixas := _TVCaixas + TR_CAIXAS
			_TvKILOS  := _TVKILOS  + TR_KILOS
			_TvVALTOT := _TVVALTOT + TR_VALTOT
			
			@nLin,081 PSAY "|"
			nLin := nLin + 1
			
			dBSkip()
		ENDDO
		@nLin,00 PSAY "|"+Replic("-",80)+"|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,02 PSAY " TOTAL VENDEDOR " + _VENDEDOR
		@nLin,027 PSAY  _TvCAIXAS    PICTURE "@E 999,999,999"
		@nLin,040 PSAY  _TvKILOS     PICTURE "@E 999,999.999"
		@nLin,054 PSAY  _TvVALTOT    PICTURE "@E 9999,999.99"
		
		@nLin,081 PSAY "|"
		nLin := nLin + 1
		@nLin,00 PSAY "|"+Replic("-",80)+"|"
		nLin := nLin + 1
		
		_Tscaixas := _TsCaixas + _TVCaixas
		_TSKILOS  := _TsKilos  + _TVKILOS
		_TSVALTOT := _TsValtot + _TVVALTOT
		
		_TvCaixas := 0
		_Tvkilos  := 0
		_TvValtot := 0
		
		If nLin > 60
			ImpCabec()
			nLin := nLin + 1
		Endif
		
	ENDDO
	@nLin,00 PSAY "|"+Replic("-",80)+"|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"
	@nLin,02 PSAY " TOTAL " + LEFT(_cNomeSupervisor,12)
	@nLin,027 PSAY  _TsCAIXAS    PICTURE "@E  999,999,999"
	@nLin,040 PSAY  _TsKILOS     PICTURE "@E  999,999.999"
	@nLin,054 PSAY  _TsVALTOT    PICTURE "@E  9999,999.99"
	@nLin,081 PSAY "|"
	nLin := nLin + 1
	@nLin,00 PSAY "|"+Replic("-",80)+"|"
	
	_Ttcaixas := _TtCaixas + _TsCaixas
	_TtKILOS  := _TtKilos  + _TsKILOS
	_TtVALTOT := _TtValtot + _TsVALTOT
	
	_TsCaixas := 0
	_Tskilos  := 0
	_TsValtot := 0
	Nlin := 80
	
EndDo

@nLin,00 PSAY "|"+Replic("-",80)+"|"

nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,02 PSAY " TOTAL GERAL  "
@nLin,027 PSAY  _TTCAIXAS    PICTURE "@E 999,999,999"
@nLin,040 PSAY  _TTKILOS     PICTURE "@E  999,999.999"
@nLin,054 PSAY  _TTVALTOT    PICTURE "@E  9999,999.99"

@nLin,081 PSAY "|"
nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",80)+"|"
nLin := NLIN + 6



//*************************************************************************
/// AQUI COMECA O RESUMO POR supervisor.
//*************************************************************************

titulo   := "REAL. DE VENDAS DIARIO - SUPERVISOR "
Cabec2 := SPACE(20)+ TITULO +SPACE(04)+ "Ate Entrega : " + DTOC(MV_PAR02)

dbSelectArea("TEMP")
cIndex   := "TR_CODSUP + TR_PRODUTO"
indRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )
/*
IF EMPTY(MV_PAR03)
	SET FILTER TO !empty(TR_CODSUP)
ELSE
	SET FILTER TO !empty(TR_CODSUP) .AND. TR_CODSUP == MV_PAR03
ENDIF
*/
DBGOTOP()

While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	#IFnDEF WINDOWS
		IncRegua()
	#ELSE
		IncProc(1)
	#ENDIF
	
	If nLin > 60
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	_Supervis := TR_CODSUP
	dbSelectArea("SZR")				//CADASTRO DE SUPERVIDOR
	DBSETORDER(1)
	dbSeek(xfilial() + _Supervis)
	_cNomeSupervisor	:=	SZR->ZR_DESCRIC
	
	dbSelectArea("TEMP")
		
	DO WHILE !EOF() .AND. TR_CODSUP == _Supervis
		
		_Produto := TR_PRODUTO
		_Caixas  := 0
		_Kilos   := 0
		_Valtot  := 0
		
		DO WHILE !EOF() .AND. TR_PRODUTO == _produto .and. TR_CODSUP == _Supervis
			
			_Caixas := _Caixas + TR_CAIXAS
			_Kilos  := _Kilos  + TR_KILOS
			_Valtot := _Valtot + TR_VALTOT
			
			Dbskip()
		Enddo
		
		@nLin,000 PSAY "|"
		
		@nLin,001 PSAY  _Supervis
		@nLin,019 PSAY  _Produto
		@nLin,027 PSAY  _CAIXAS    PICTURE "@E  999,999,999"
		@nLin,040 PSAY  _KILOS     PICTURE "@E  999,999.999"
		@nLin,054 PSAY  _VALTOT    PICTURE "@E  9999,999.99"
		@nLin,068 PSAY  (_valtot/_kilos)    PICTURE "@E  99,999.999"
		
		_Tvcaixas := _TVCaixas + _CAIXAS
		_TvKILOS  := _TVKILOS  + _KILOS
		_TvVALTOT := _TVVALTOT + _VALTOT
		
		@nLin,081 PSAY "|"
		nLin := nLin + 1
		
	ENDDO
	
	@nLin,00 PSAY "|"+Replic("-",80)+"|"
	nLin := nLin + 1
	@nLin,000 PSAY "|"
	@nLin,02 PSAY " TOTAL " + left(_cNomeSupervisor,12)
	@nLin,027 PSAY  _TvCAIXAS    PICTURE "@E  999,999,999"
	@nLin,040 PSAY  _TvKILOS     PICTURE "@E  999,999.999"
	@nLin,054 PSAY  _TvVALTOT    PICTURE "@E  9999,999.99"
	
	@nLin,081 PSAY "|"
	nLin := nLin + 1
	@nLin,00 PSAY "|"+Replic("-",80)+"|"
	nLin := nLin + 1
	
	_Tscaixas := _TsCaixas + _TVCaixas
	_TSKILOS  := _TsKilos  + _TVKILOS
	_TSVALTOT := _TsValtot + _TVVALTOT
	
	_TvCaixas := 0
	_Tvkilos  := 0
	_TvValtot := 0
	
	If nLin > 60
		ImpCabec()
		nLin := nLin + 1
	Endif
	
ENDDO
@nLin,00 PSAY "|"+Replic("-",80)+"|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,02 PSAY " TOTAL GERAL "
@nLin,027 PSAY  _TsCAIXAS    PICTURE "@E  999,999,999"
@nLin,040 PSAY  _TsKILOS     PICTURE "@E  999,999.999"
@nLin,054 PSAY  _TsVALTOT    PICTURE "@E  9999,999.99"
@nLin,081 PSAY "|"
nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",80)+"|"

@nLin,081 PSAY "|"
nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",80)+"|"
nLin := NLIN + 6
Nlin := 80


//*************************************************************************
/// AQUI COMECA O RESUMO POR GERENTE
//*************************************************************************

dbSelectArea("TEMP")
cIndex   := "TR_PRODUTO"
indRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )
/*
IF EMPTY(MV_PAR03)
	SET FILTER TO !empty(TR_CODSUP)
ELSE
	SET FILTER TO !empty(TR_CODSUP) .AND. TR_CODSUP == MV_PAR03
ENDIF
*/
DBGOTOP()

titulo   := "REAL. DE VENDAS DIARIO - GERENCIA "
Cabec2 := SPACE(20)+ TITULO +SPACE(04)+ "Ate Entrega : " + DTOC(MV_PAR02)
While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	#IFnDEF WINDOWS
		IncRegua()
	#ELSE
		IncProc(1)
	#ENDIF
	
	If nLin > 60
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	_Produto := TR_PRODUTO
	_Caixas  := 0
	_Kilos   := 0
	_Valtot  := 0
	
	DO WHILE !EOF() .AND. TR_PRODUTO == _produto
		_Caixas := _Caixas + TR_CAIXAS
		_Kilos  := _Kilos  + TR_KILOS
		_Valtot := _Valtot + TR_VALTOT
		Dbskip()
	Enddo
	@nLin,000 PSAY "|"
	@nLin,019 PSAY  _Produto
	@nLin,027 PSAY  _CAIXAS    PICTURE "@E  999,999,999"
	@nLin,040 PSAY  _KILOS     PICTURE "@E  999,999.999"
	@nLin,054 PSAY  _VALTOT    PICTURE "@E  9999,999.99"
	@nLin,068 PSAY  (_valtot/_kilos)    PICTURE "@E  99,999.999"
	_Tvcaixas := _TVCaixas + _CAIXAS
	_TvKILOS  := _TVKILOS  + _KILOS
	_TvVALTOT := _TVVALTOT + _VALTOT
	
	@nLin,081 PSAY "|"
	nLin := nLin + 1
	
ENDDO

@nLin,00 PSAY "|"+Replic("-",80)+"|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,02 PSAY " TOTAL GERAL "
@nLin,027 PSAY  _TvCAIXAS    PICTURE "@E  999,999,999"
@nLin,040 PSAY  _TvKILOS     PICTURE "@E  999,999.999"
@nLin,054 PSAY  _TvVALTOT    PICTURE "@E  9999,999.99"

@nLin,081 PSAY "|"

nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",80)+"|"
nLin := nLin + 1


//*************************************************************************
/// AQUI COMECA O RESUMO POR PRODUTO.
//*************************************************************************

titulo   := "REAL. DE VENDAS x POSICAO ESTOQUE "
Cabec2 := SPACE(20)+ TITULO +SPACE(10)+ "Ate Entrega : " + DTOC(MV_PAR02)
dbSelectArea("TEMP")
DBGOTOP()

nLin      := 80
_TQtdCx   := 0
_TQtdKl   := 0
_TEstCxs  := 0
_TEstKil  := 0

DO WHILE !EOF()
	
	If nLin > 60
		ImpACabec()
	Endif
	
	_Produto := TR_PRODUTO
	
	_QtdCx   := 0
	_QtdKl   := 0
	_EstCxs  := 0
	_EstKil  := 0
	
	do While TR_PRODUTO == _Produto
		
		_QtdCx := _QtdCx + TR_CAIXAS
		_QtdKl := _QtdKl + TR_KILOS
		dbskip()
	enddo
	
	dbSelectArea("SB1")
	dbSeek(xfilial() + _Produto)
	
	dbSelectArea("SB2")
	//ALTERADO LEONARDO (HC) PARA CONTEMPLAR ARMAZEM 30 DA FILIAL 06 - ITUPEVA
	If cFilAnt <> '06'
		dbSeek(xfilial("SB2") + _Produto + SPACE(09) + "10")
	Else
		dbSeek(xfilial("SB2") + _Produto + SPACE(09) + "30")
	EndIf
	
	_EstKil := B2_QATU
	_EstCxs := B2_QATU / SB1->B1_CONV
	
	dbSelectArea("TEMP")
	
	@nLin,000 PSAY "|"
	@nLin,002 PSAY  _PRODUTO
	@nLin,019 PSAY  _QTDCX              PICTURE "@E  999999"
	@nLin,027 PSAY  _QTDKL              PICTURE "@E  999999.999
	@nLin,039 PSAY  _EstCxs             PICTURE "@E  999999"
	@nLin,049 PSAY  _EstKIL             PICTURE "@E  999999.999"
	@nLin,061 PSAY  (_EstCxs - _QtdCx)  PICTURE "@E  999999"
	@nLin,069 PSAY  (_EstKil - _QtdKl)  PICTURE "@E  999999.999"
	@nLin,078 PSAY "|"
	
	nLin := nLin + 1
	
	_TQtdCx   := _TqtdCx + _qtdcx
	_TQtdKl   := _Tqtdkl + _qtdkl
	
	
ENDDO
@nLin,00 PSAY "|"+Replic("-",79)+"|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,02 PSAY " TOTAL GERAL "

@nLin,020 PSAY  _TQTDCX      PICTURE "@E  999,999"
@nLin,028 PSAY  _TQTDKL      PICTURE "@E  999999.999

//         @nLin,041 PSAY  _EstCxs       PICTURE "@E  999,999"
//         @nLin,049 PSAY  _EstKIL       PICTURE "@E  999,999.999"

@nLin,080 PSAY "|"
nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",79)+"|"
nLin := 80

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

dbSelectArea('TEMP')
dbclosearea("TEMP")
//fErase(_cNomTrb+'.*')
MSErase(_cNomTrb+'.*')

return

******************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function ImpCabec
Static Function ImpCabec()
******************************************************************************
nLin := 1

@nLin,00 PSAY "|"+Replic("-",78)+"|"
nLin := nLin + 1

@ nlin,00 PSAY Cabec1
nLin := nLin + 1

@nLin,00 PSAY Cabec2
nLin := nLin + 1

@nLin,00 PSAY Cabec3
nLin := nLin + 1

@nLin,00 PSAY Cabec4
nLin := nLin + 1

@nLin,00 PSAY Cabec5
//nLin := nLin + 1

Return



******************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function ImpCabec
Static Function ImpACabec()
******************************************************************************
nLin := 1

@nLin,00 PSAY "|"+Replic("-",78)+"|"
nLin := nLin + 1

@ nlin,00 PSAY Cabec10
nLin := nLin + 1

@nLin,00 PSAY Cabec20
nLin := nLin + 1

@nLin,00 PSAY Cabec30
nLin := nLin + 1

@nLin,00 PSAY Cabec40
nLin := nLin + 1

@nLin,00 PSAY Cabec50
nLin := nLin + 1

@nLin,00 PSAY Cabec60
nLin := nLin + 1

@nLin,00 PSAY Cabec70
nLin := nLin + 1

Return
