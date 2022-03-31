#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function AD0027Y
	(Relatorio Meta de Vendas Supervisor( COMERCIAL  ))
	@type  Function
	@author  Heraldo C. Hebling 
	@since 20/02/2003
	@version 01
	@history 03/10/2003 Conforme solicitado por Decio, os dias que tem  valor  ZERO , nao devem ser consideradas nos calculos de media do Supervisor. Heraldo.                               ³±±
    @history 10/02/2009 - HC CONSYS - Incluido funcao para criar automaticamente perguntas no SX1.
    @history 10/02/2009 - HC CONSYS - Incluido parametro para quebra de mais um grupo Totalizador e alterado numero de sub-grupos de 10 para 20 conforme chamado nro 003194                  ³±±
    @history 21/11/11 - Ajustes de colunas e calculos conforme solicitação do Sr. Fernando.
	@history Ticket 70540 - ADRIANO SAVOINE - 30/03/2022 - Ajuste no parametro de filiais.  
	/*/

User Function AD0027Y()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Meta de Vendas Supervisor( COMERCIAL  )')

SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,cPerg,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTR1,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,") 
Private _aSup := {}
Private cArq
Private oExcelApp
Private _Eof 	:= Chr(13) + Chr(10)
Private cLin := ""
Private cLin6 := ""
Private cLin7 := ""
Private cLin8 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // De Data Entrega                      ³
//³ mv_par02             // Ate Data Entrega                     ³
//³ mv_par03             // Do Supervisor                        ³
//³ mv_par04             // Ate Supervisor                       ³
//³ mv_par05             // Considera Desconto de Redes          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

_aTotaliz  := {}  &&Mauricio 29/11/11 totalizador para supervisor

_nTotQbrB:=0
_nIndice:=0
_cAcumMetaCli:=0
_nVlr:=0
_Supervis1:=""
_Supervis2:=""     
_nTotD:=0
_nAcumVendas:=	0            
_nAcumMtPrc	:=	0
_nAcumRePrc	:=	0
_nAcumRfPrc	:=	0
_nAcumMtVol	:=	0
_nAcVdT     :=	0
_nAcMtPrcT	:=	0
_nAcRePrcT	:=	0
_nAcRfPrcT	:=	0
_nAcMtVolT	:=	0
_nAcVdTT    :=	0
_nAcMPrcTT  :=	0
_nAcRPrcTT  :=	0
_nAcFPrcTT  :=	0
_nAcMVolTT  :=	0 
_cAgrupadores := ""
_cCont1:=0
aAcD:={}
_nTotVendas	:=	0
_nTotMtPrc	:=	0
_nTotRePrc	:=	0
_nTotMtVol	:=	0
_nTotRfPrc	:=	0

_nQtcartT  := 0
_nTotCont  := 0 
_ntotContv := 0
_nTContv2  := 0

_nAcum1T2Vendas	:= 0
_nAcum1T2MtPrc	:= 0
_nAcum1T2RePrc	:= 0
_nAcum1T2MtVol	:= 0
_nAcum1T2RfPrc	:= 0

_nAcum2T2Vendas	:= 0
_nAcum2T2MtPrc	:= 0
_nAcum2T2RePrc	:= 0
_nAcum2T2MtVol	:= 0
_nAcum2T2RfPrc	:= 0

_nAcum3T2Vendas	:= 0
_nAcum3T2MtPrc	:= 0
_nAcum3T2RePrc	:= 0
_nAcum3T2MtVol	:= 0
_nAcum3T2RfPrc	:= 0

_sub:=""

_nMTPRC:=0
_nRFPRC:=0
_nMTVOL:=0   

//cPerg		:="AD0027"
//cPerg		:= PADR("AD0N27",10," ") && Utilizando outro grupo de perguntas por motivo das alteracoes chamado 003194
cPerg		:= PADR("AD027Y",10," ") && Mauricio 30/11/11 - criado grupo de perguntas especificas para o relatorio.

_cNivel		:=""
_aSubGrupo1	:={}
_aSubGrupo2	:={}
_aSubGrupo3	:={}
_cMeta		:=0
mes			:=0
aMetasMes	:={}
_cCont		:=0
_cContv		:=0
_cContv2	:=0
_cCont1		:=0
_cNomGrupo	:=""
_DOC		:=""
_SERIE		:=""
_CLIENTE	:=""
_LOJA		:=""
_nValorT	:=	0
_nQtd		:=	0
_cProduto	:=  ""
_cCodSup	:=	""
_cNomeSup	:=	""
_cDtDE 		:=	""
_cDias		:=	""
_cDtATE 	:=	""
_cDUtil		:=	""
_nMtCli		:=	0
_nReCli		:=	0
_nIndCli	:=	0
_PercDes    :=  SPACE(3)
_Desc       :=  SPACE(10)

aOrd             := {}
tamanho          := "G"
limite           := 220
nomeprog         := "AD0027Y"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
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
//cPerg   := "AD0027"
//cPerg		:="AD0N27"   && Utilizando outro grupo de perguntas por motivo das alteracoes chamado 003194
//cPerg		:=PADR("AD0N27",10," ")   && Utilizando outro grupo de perguntas por motivo das alteracoes chamado 003194

cPerg		:=PADR("AD027Y",10," ")
ValidPerg()
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SC6"
titulo  := "METAS DE VENDAS SUPERVISOR MEDIA SIMPLES-DIR"
cDesc1  := "Este programa tem como objetivo imprimir posicao VENDAS"
cDesc2  := "por Supervisor participacao de vendas e volumes"
cDesc3  := " By Desenvolvimento ADORO"
nomerel := "AD0027Y"

// Ticket 70540 - ADRIANO SAVOINE - 30/03/2022

IF TYPE(MV_PAR05) == "N" .OR. TYPE(MV_PAR05) == "U"

	MsgAlert("SELECIONE NOS PARAMETROS AS FILIAIS, PARA GERAR ESTE RELATORIO.", "ATENCAO!!!")

	nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

	U_AD0027Y()

	ELSE

	nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

ENDIF


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
_lDiret := .F.
Cabec1 := ""
Cabec2 := ""
d1:=""
d2:=""
dt1:=dtos(mv_par01)
dt2:=dtos(mv_par02)

&&Mauricio 30/11/11 - Verifica se o usuario emissor do relatório é Diretor ou Não.
_cCodUsua := __cUserID
DbSelectArea("SA3")
DbSetOrder(7)
if dbseek(xFilial("SA3")+_cCodUsua)
   If SA3->A3_NIVETAB == "4"
      _lDiret := .T.
   Endif   
Endif

/*
____________________________________________________________________________________________________________________________________________________________
SUPERVISOR: 999999 XXXXXXXXXXXXXXXXX                                                                                           DE : 99/99/99     DIAS : 999
ATE: 99/99/99     UTEIS: 999
____________________________________________________________________________________________________________________________________________________________
CLIENTES  META : 9999   REALIZADO: 9999 INDICE: 999,999%
____________________________________________________________________________________________________________________________________________________________
*/

&&Mauricio 30/11/11
if _lDiret
   cabec6 := "|                               |   PRECO FOB (R$/KG)   |     FATURAMENTO(R$)                DIFERENCA FAT.(R$)        |       INDICE      |                  VOLUME(KG)                    |      ATINGIMENTO(%)         |"
   Cabec7 := "|GRUPO DE PRODUTOS:             |  META   REAL.   CT    |   META       REALIZADO       CT     REAL - META  REAL - CT   |      IPM   IPCT   |    META        REALIZ.  PROJETADO  NECESSARIA  |  REALIZADO    PROJETADO COB |"
   Cabec8 := "|_______________________________|_______________________|______________________________________________________________|___________________|________________________________________________|_____________________________|"
   cLin6  := ";;PRC FOB;PRC.FOB;PRC. FOB.;FAT.;FAT.;FAT.;DIF.FAT;DIF.FAT.;INDICE;INDICE;VOL.;VOl.;VOL.;VOL.;ATING.;ATING."+_eof
   cLin7  := "GRUPO;PRODUTOS;META;REAL;CT;META;REALIZADO;CT;REAL - META;REAL _ CT;IPM;IPCT;META;REALIZADO;PROJETADO;NECESSARIA;REALIZADO;PROJETADO"+_eof
   //          1    6   10         20         30         40         50          60          70          80          90          00          10          20          30          40          50          60          70          80          9
Else
   cabec6 := "|                               |   PRECO FOB (R$/KG)   |     FATURAMENTO(R$)                DIFERENCA FAT.(R$)        |       INDICE      |                  VOLUME(KG)                    |      ATINGIMENTO(%)         |"
   Cabec7 := "|GRUPO DE PRODUTOS:             |  META   REAL.         |   META       REALIZADO              REAL - META              |      IPM          |    META        REALIZ.  PROJETADO  NECESSARIA  |  REALIZADO    PROJETADO COB |"
   Cabec8 := "|_______________________________|_______________________|______________________________________________________________|___________________|________________________________________________|_____________________________|"
   cLin6  := ";;PRC FOB;PRC.FOB;FAT.;FAT.;DIF.FAT;INDICE;VOL.;VOl.;VOL.;VOL.;ATING.;ATING."+_eof
   cLin7  := "GRUPO;PRODUTOS;META;REAL;META;REALIZADO;REAL - META;IPM;META;REALIZADO;PROJETADO;NECESSARIA;REALIZADO;PROJETADO"+_eof
   //          1    6   10         20         30         40         50          60          70          80          90          00          10          20          30          40          50          60          70          80          9
Endif   

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
AADD (aStru,{"T1_SUPERVI"  	, "C",06,0}) 		// CODIGO DO SUPERVISOR
AADD (aStru,{"T1_CLIENTE" 	, "C",06,0})		// QUANTIDADE DE CLIENTES ATIVADOS
AADD (aStru,{"T1_NOMESUP" 	, "C",30,0})		// QUANTIDADE DE CLIENTES ATIVADOS
AADD (aStru,{"T1_QTDVEZ" 	, "N",04,0})		// QUANTIDADE DE CLIENTES ATIVADOS
AADD (aStru,{"T1_VALBRUT" 	, "N",14,4})		// VALOR BRUTO

_cNomTr1 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr1,"TEM1",.F.,.F.)

cIndex   := "T1_SUPERVI + T1_CLIENTE"
IndRegua( "TEM1", _cNomTr1, cIndex,,,"Criando Indice ..." )
//************************************************************
aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})		// CODIGO DO SUPERVISOR
AADD (aStru,{"T2_CODGRUP" 	, "C",04,0})	  	// CODIGO DO GRUPO (NETO)
AADD (aStru,{"T2_NOMGRUP" 	, "C",30,0})		// DESCRICAO DO GRUPO (NETO)
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_MT_PRC"   	, "N",12,4})		// META PRECO DO SUPERVISOR
AADD (aStru,{"T2_MT_VOL"   	, "N",07,0})		// META VOLUME DO SUPERVISOR
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// REALIZADO PRECO DO SUPERVISOR
AADD (aStru,{"T2_RF_PRC"   	, "N",12,4})		// REFERENCIA    &&Mauricio MDS TEC 23/11/11.
AADD (aStru,{"T2_EMISSAO"	, "D",08,0})	   	// DATA DE EMISSAO
AADD (aStru,{"T2_QBRNVL"	, "C",01,0})		// QUEBRA NIVEL DOS GRUPOS
AADD (aStru,{"T2_QBRTOT"	, "C",01,0})		// Quebra por novo totalizador - Mauricio 05/10/11.

_cNomTr2 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr2,"TEM2",.F.,.F.)

//cIndex   := "T2_SUPERVI + T2_QBRNVL + T2_CODGRUP + dtos(T2_EMISSAO)"
cIndex   := "T2_SUPERVI + T2_QBRTOT+ T2_QBRNVL + T2_CODGRUP + dtos(T2_EMISSAO)"
IndRegua( "TEM2", _cNomTr2, cIndex,,,"Criando Indice ..." )

If SELECT("CLIENTE") > 0
   DBSELECTAREA("CLIENTE")
   DBCLOSEAREA("CLIENTE")
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para registrar os cliente que pertence a carteira e se esta acima do valor do parametro     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
AADD (aStru,{"CLI_SUPERV"  	, "C",06,0}) 		// CODIGO DO SUPERVISOR
AADD (aStru,{"CLI_COD"   	, "C",06,0})		// CODIGO DE CLIENTE
AADD (aStru,{"CLI_LOJA" 	, "C",02,0})		// LOJA DO CLIENTE
AADD (aStru,{"CLI_VALOR" 	, "N",14,2})		// VALOR FATURADO
//AADD (aStru,{"CLI_FLAG" 	, "C",01,0})		// FLAG QUE DIZ QUE O CLIENTE COMPROU ACIMA DO PARAMETRO
//AADD (aStru,{"CLI_FLAG2" 	, "C",01,0})		// FLAG QUE DIZ QUE O CLIENTE COMPROU ACIMA DO PARAMETRO

_cNomTr1 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr1,"CLIENTE",.F.,.F.)

cIndex   := "CLI_SUPERV + CLI_COD+CLI_LOJA"
IndRegua( "CLIENTE", _cNomTr1, cIndex,,,"Criando Indice ..." )

&&Mauricio - 01/07/15 - Arquivo temporario para cobertura de clientes
//************************************************************
aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})		// CODIGO DO SUPERVISOR
AADD (aStru,{"T2_QBRTOT"	, "C",01,0})		// Quebra por novo totalizador - Mauricio 05/10/11.
AADD (aStru,{"T2_QBRNVL"	, "C",01,0})		// QUEBRA NIVEL DOS GRUPOS
AADD (aStru,{"T2_CODGRUP" 	, "C",04,0})	  	// CODIGO DO GRUPO (NETO)
AADD (aStru,{"T2_CLIENTE"	, "C",06,0})		// CODIGO CLIENTE
AADD (aStru,{"T2_LOJA"	    , "C",02,0})		// CODIGO CLIENTE

_cNomTrM := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrM,"COBSUP",.F.,.F.)
_cIndexM   := "T2_SUPERVI + T2_QBRTOT + T2_QBRNVL + T2_CODGRUP + T2_CLIENTE + T2_LOJA"
IndRegua( "COBSUP", _cNomTrM, _cIndexM,,,"Criando Indice ..." )

_cNomTrN := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrN,"COBTOT",.F.,.F.)
_cIndexN   := "T2_QBRTOT + T2_QBRNVL + T2_CODGRUP + T2_CLIENTE + T2_LOJA"
IndRegua( "COBTOT", _cNomTrN, _cIndexN,,,"Criando Indice ..." )
&&Fim 01/07/15


dbSelectArea("SB1") // PRODUTOS
dbSetOrder(1)

dbSelectArea("SA3")	// VENDEDORES
dbSetOrder(1)

dbSelectArea("SZR")	// SUPERVISORES
dbSetOrder(1)

dbSelectArea("SBM")  // GRUPO DE PRODUTOS
dbSetOrder(1)

dbSelectArea("SX5")  // Totalizadores - Mauricio 05/10/11
dbSetOrder(1)
&&Mauricio 26/10/11 - incluido campos para apuração frete na query
cQuery:="select F2_FILIAL, F2_VEND1, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
"from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
"where F2_FILIAL IN ("+ALLTRIM(MV_PAR05)+") and "+;
"F2_TIPO='N' and "+;
"F2_EMISSAO between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+;
"F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
"SF2.D_E_L_E_T_= '' "+;
"AND SA1.D_E_L_E_T_= '' "+;
"order by F2_EMISSAO,F2_CLIENTE"
TCQUERY cQuery new alias "XF2"
DBSELECTAREA("XF2")
        
/*
cQuery:="select COUNT(distinct F2_EMISSAO) "+; 	// Query incluida por Heraldo 29/10/02
"from "+retsqlname("SF2")+", "+retsqlname("SA3")+", "+retsqlname("SZR")+" "+;
"where F2_VEND1 = A3_COD AND A3_CODSUP = ZR_CODIGO AND F2_FILIAL IN ("+ALLTRIM(MV_PAR22)+") and "+;
"F2_TIPO='N' and "+;
"F2_EMISSAO between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+;
"SF2010.D_E_L_E_T_= '' AND ZR_SEGMERC BETWEEN '"+MV_PAR20+"' AND '"+MV_PAR21+"' "

TCQUERY cQuery new alias "XF2A"
dbSelectArea("XF2A")
_nDiasUtil	:=	XF2A->CFIELD1
XF2A->(dbclosearea()) */

_nDiasUtil	:= MV_PAR06 
_nDiasCorr  := MV_PAR07    &&Mauricio 26/10/11 - novo parametro dias corridos....

dbSelectArea("XF2")
Processa({|| MontaTra()},"Processando NF SAIDA ...")
Return

Static Function MontaTra()

dbSelectArea("SA1")
dbSetOrder(1)
//
dbSelectArea("XF2")
ProcRegua(RecCount())
XF2->(dbgotop())

//_aLista := {}

_dDataOut	:=	""
_xPrima		:=	.T.
DO WHILE !EOF()
	
	IncProc(" Filial-NFiscal : "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC + " - Emissao : "+dtoc(stod(XF2->F2_EMISSAO)))
	_cVendedor	 	:=	XF2->F2_VEND1
	_cEmissao 		:=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
	_dDataIn			:=	XF2->F2_EMISSAO
	_cCliente		:=	XF2->F2_CLIENTE
	_nValor			:=	XF2->F2_VALBRUT
	dbSelectArea("SA3")
	dbSeek(xfilial() + _cVendedor)
	_cSuper 		:= SA3->A3_CODSUP
	
	dbSelectArea("TEM1")
	If _cSuper>= mv_par03 .and. _cSuper <= mv_par04
		
		IF !dbSeek(_cSuper+_cCliente) //.and. _cSuper>= mv_par03 .and. _cSuper <= mv_par04
			dbSelectArea("SZR")
			dbSeek(xfilial() + _cSuper)
			
			dbSelectArea("TEM1")
			RecLock("TEM1",.T.)
			TEM1->T1_SUPERVI	:= _cSuper
			TEM1->T1_CLIENTE	:=	_cCliente
			TEM1->T1_NOMESUP	:=	SZR->ZR_DESCRIC
			TEM1->T1_QTDVEZ	:=	1
			TEM1->T1_VALBRUT	:=	_nValor
			MsUnLock()
		Else
			RecLock("TEM1",.F.)
			TEM1->T1_QTDVEZ	:= 	TEM1->T1_QTDVEZ + 1
			TEM1->T1_VALBRUT	:=	TEM1->T1_VALBRUT + _nValor
		Endif
	Else
		dbSelectArea("XF2")
		dbskip()
		Loop
	Endif
	
	_cFIL       :=  XF2->F2_FILIAL
	_cDOC      	:= 	XF2->F2_DOC
	_cSERIE    	:= 	XF2->F2_SERIE
	_cCLIENTE  	:= 	XF2->F2_CLIENTE
	_cLOJA     	:= 	XF2->F2_LOJA

	// Posiciono no Cliente para pegar o valor financeiro
	/*REMOVIDO DANIEL 25/01/07 PASSADO PARA QUERY
	dbSelectArea("SA1")
	dbSetOrder(1)
	DbSeek(xFilial("SA1")+_cCLIENTE+_cLOJA,.T.)
	*/
	//
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xfilial("SD2") + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)
	dbSeek(_cFil + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)    && Chamado 006243. Mauricio HC Consys.
	// 

	DO WHILE !EOF() .AND. 	SD2->D2_DOC		  	== _cDOC     	.AND. ;
		SD2->D2_FILIAL      == _cFIL     .AND. ;
		SD2->D2_SERIE	  	== _cSERIE  	.AND. ;
		SD2->D2_CLIENTE		== _cCLIENTE .AND. ;
		SD2->D2_LOJA		== _cLOJA
		&&Mauricio 29/11/11 - Substituido trecho abaixo, por parte vinda do fonte META05, conforme solicitado para compatibilizar as informaçõe entre os
		&&relatorios.
		/*
		If LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69"  //REMESSA DESCONSIDERA
			dbSelectArea("SD2")
			dbskip()
			LOOP
		Endif
		*/
		&&trecho vindo do META05 -Inicio-
		If SD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
		   dbSelectArea("SD2")
		   dbskip()
		   LOOP
		Endif
		
		If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
		   	LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116") .AND. ;
		   !(LEFT(SD2->D2_CF,4) $ '5922 6922')    
		   //REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922 
		   //REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA 
		   dbSelectArea("SD2")
		   dbskip()
		   LOOP
		Endif 
		&&Trecho -Fim-
		_nQtd      		:=	SD2->D2_QUANT
		_cProduto  		:=	SD2->D2_COD
		_nPrecoU			:=	SD2->D2_PRCVEN
		_nValorT			:=	SD2->D2_TOTAL
		_dEmissao		:=	SD2->D2_EMISSAO
		
		//INCLUIDO DANIEL 25/01/07
		//+---------------------+
		//|DEVOLUCAO            |
		//+---------------------+
		_nQtddev			:= SD2->D2_QTDEDEV *(-1)
		_nValdev			:= SD2->D2_VALDEV *(-1)
		_nValorT			+=_nValDev
		_nQtd				+=_nQtdDev
		
		//ALTERADO DANIEL 25/01/07
		//+--------------------------------------------+
		//| Verificando se existe desconto financeiro  |
		//+--------------------------------------------+
				
		If (XF2->A1_DESC > 0) .and. (_nValorT>0)
			//			_nValorT := SD2->D2_TOTAL-((SD2->D2_TOTAL * XF2->A1_DESC) / 100)
			&&Mauricio 26/10/11 - tratamento para descontar frete...
        	//_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO) 
			&&_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100) 
			_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100) 
		Endif

		// Alex Borges 01/12/11
		_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO) 
		_nValorT := _nValorT - ( _Frete * _nQtd )
		
		dbSelectArea("TEM1")
		If dbSeek(_cSuper+_cCliente)
			RecLock("TEM1",.F.)
			TEM1->T1_VALBRUT 	+=	_nValdev
			MsUnLock()
		Endif
		
		//
		dbSelectArea("SB1") // PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cProduto)
		_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
		//		_cGrupo		:= SB1->B1_XGRPANT
		
		dbSelectArea("SBM") // GRUPO DE PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cGrupo)
		_cNomGrupo	  := SBM->BM_DESC
		_cNivel		  := SBM->BM_NIVEL
		_cQuebraNivel := SBM->BM_QBRNVL
		
		&&Totalizadores - Mauricio 05/10/11
		dbSelectArea("SX5") 
		DbSetOrder(1)
		if dbSeek("02W1"+_cQuebraNivel)    &&Usa cadastro criado somente na filial 02 - tabela criada W1. 
		   _cQuebraTot := Substr(SX5->X5_DESCRI,1,1)
		Else
		   _cQuebraTot :=  "9"                &&Para efeito de ordenação utilizo quando não ha cadastro o codigo 9.
		Endif      
		
		If mv_par01 == mv_par02
			_nNumDias:=1
		Else
			//			_nNumDias:= mv_par02 - mv_par01 + 1
			_nNumDias:= _nDiasUtil
		Endif
		dbSelectArea("TEM2")
		If _cNivel == "3" 
		   	dbSelectArea("CLIENTE")
			IF !dbSeek(_cSuper+_cCLIENTE+_cLoja)
				RecLock("CLIENTE",.T.)
				CLIENTE->CLI_SUPERV := _cSuper
				CLIENTE->CLI_COD    := _cCLIENTE
				CLIENTE->CLI_LOJA   := _cLoja
				CLIENTE->CLI_VALOR  := SD2->D2_TOTAL
			   /*	IF SD2->D2_TOTAL >= MV_PAR08        //10000    &&Mauricio 29/11/11 criado parametro para valor.
					CLIENTE->CLI_FLAG := "S"
				Endif
				IF SD2->D2_TOTAL >= MV_PAR09        //10000    &&Mauricio 30/11/11 criado parametro para valor 2.
					CLIENTE->CLI_FLAG2 := "S"
				Endif  */					
				MsUnLock()			
			Else
			    RecLock("CLIENTE",.F.)
			   	CLIENTE->CLI_VALOR  := CLIENTE->CLI_VALOR + SD2->D2_TOTAL
			   	MsUnLock()
			   /*	IF SD2->D2_TOTAL >= MV_PAR08        //10000    &&Mauricio 29/11/11 criado parametro para valor.
					RecLock("CLIENTE",.F.)
			 		CLIENTE->CLI_FLAG := "S"
			 		MsUnLock()
				EndIF
				IF SD2->D2_TOTAL >= MV_PAR09        //10000    &&Mauricio 30/11/11 criado parametro para valor2.
					RecLock("CLIENTE",.F.)
			 		CLIENTE->CLI_FLAG2 := "S"
			 		MsUnLock()
				EndIF	*/
			EndIF
			
			&&Tratamento para debug/teste....
			//IF !(Alltrim(_cGrupo) == "0111")
			//    dbSelectArea("SD2")
		    //    DbSkip()
			//    loop
			//ENDIf
			//Mauricio log
			//AADD(_aLista,{_cProduto, _cFil, _cDoc, _cSerie, _cCliente, _cLoja, Str(_nQtd),Str(_nValorT)})
						 
		    dbSelectArea("TEM2")
			&&IF !dbSeek(_cSuper+_cQuebraNivel+_cGrupo)       Mauricio 05/10/11 - para considerar totalizador criado.
			IF !dbSeek(_cSuper+_cQuebraTot+_cQuebraNivel+_cGrupo)
				ACHAMETA()
				ACHAREF()                      &&Mauricio MDS TEC 23/11/11.
				dbSelectArea("TEM2")
				RecLock("TEM2",.T.)
				TEM2->T2_SUPERVI  	:=	_cSuper
				TEM2->T2_CODGRUP		:=	_cGrupo
				TEM2->T2_NOMGRUP		:=	_cNomGrupo
				TEM2->T2_VENDAS		:=	_nQtd
				TEM2->T2_MT_PRC		:= _nMTPRC
				TEM2->T2_MT_VOL		:=	_nMTVOL
				TEM2->T2_RE_PRC		:= _nValorT
				TEM2->T2_RF_PRC     :=  _nRFPRC
				TEM2->T2_EMISSAO	:= _dEmissao
				TEM2->T2_QBRNVL		:= _cQuebraNivel
				TEM2->T2_QBRTOT     := _cQuebraTot
				TEM2->(MsUnLock())
			Else
				RecLock("TEM2",.F.)
				TEM2->T2_VENDAS		:=	TEM2->T2_VENDAS	+	_nQtd
				TEM2->T2_RE_PRC		:=	TEM2->T2_RE_PRC	+	_nValorT
				TEM2->(MsUnLock())
			Endif
			
			&&Mauricio - 01/07/15 - Atendimento cobertura de clientes
			&&para total supervisor
			DbSelectArea("COBSUP")
			if !dbseek(_cSuper+_cQuebraTot+_cQuebraNivel+_cGrupo+_cCliente+_cLoja)
			   Reclock("COBSUP",.T.)
			   COBSUP->T2_SUPERVI  	:=	_cSuper
			   COBSUP->T2_QBRNVL	:= _cQuebraNivel
			   COBSUP->T2_QBRTOT    := _cQuebraTot
			   COBSUP->T2_CODGRUP	:=	_cGrupo   
			   COBSUP->T2_CLIENTE   := _cCliente
			   COBSUP->T2_LOJA      := _cLoja			
			   COBSUP->(MsUnlock())
			Endif
			&&para total geral
			DbSelectArea("COBTOT")
			if !dbseek(_cQuebraTot+_cQuebraNivel+_cGrupo+_cCliente+_cLoja)
			   Reclock("COBTOT",.T.)
			   COBTOT->T2_SUPERVI  	:=	_cSuper
			   COBTOT->T2_QBRNVL	:= _cQuebraNivel
			   COBTOT->T2_QBRTOT    := _cQuebraTot
			   COBTOT->T2_CODGRUP	:=	_cGrupo   
			   COBTOT->T2_CLIENTE   := _cCliente
			   COBTOT->T2_LOJA      := _cLoja			
			   COBTOT->(MsUnlock())
			Endif			
			&&fim 01/07/15
			
		Endif
		dbSelectArea("SD2")
		DbSkip()
	Enddo
    //Mauricio log
	//MsgInfo("Ultimo: "+_cProduto+" "+_cFil+" "+_cDoc+" "+_cSerie+" "+_cCliente+" "+_cLoj+" "+Str(_nQtd)+" "+Str(_nValorT)
	
	dbSelectArea("XF2")
	dbskip()
ENDDO
//Mauricio log
/*
cFileLog := "AD0027Y.LOG"
cPath := "D:\TEMP\"

For _nx := 1 to len(_aLista)
    AutoGrLog(_aLista[_nx][1]+";"+_aLista[_nx][2]+";"+_aLista[_nx][3]+";"+_aLista[_nx][4]+";"+_aLista[_nx][5]+";"+_aLista[_nx][6]+";"+_aLista[_nx][7]+";"+_aLista[_nx][8]+";")
Next _nx

//cFileLog := NomeAutoLog()

MsgInfo(cFileLog)

If cFileLog <> ""
   MostraErro(cPath,cFileLog)
Endif
*/
//incluido por Adriana HC para atender solicitacao do analista Alex (TI) e Diogenes (Comercial)
//com a finalidade de incluir as metas definidas para os supervisores, mesmo quando nao houve nenhum faturamento para o grupo de produto

_cQuery := "SELECT "
_cQuery += "ZL_SUPERVI, ZL_GRUPO, "
_cQuery += "COUNT(*) QUANT, "
//_cQuery += "SUM(ZL_VALOR)/COUNT(*) VALOR, SUM(ZL_PESMETA)/COUNT(*) PESO " ALEX BORGES 02/12/11
_cQuery += "SUM(ZL_VALOR)/COUNT(*) AS 'VALOR', 0 AS 'PESO' "
_cQuery += "FROM "+RetSqlName("SZL")+ " "
_cQuery += "WHERE (ZL_SUPERVI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
//_cQuery += "AND (ZL_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "  ALEX BORGES 06/12/11
_cQuery += "AND (ZL_DATA BETWEEN '"+DTOS(MV_PAR10)+"' AND '"+DTOS(MV_PAR11)+"') "
_cQuery += "AND D_E_L_E_T_ = '' AND ZL_VALOR > 0 "
_cQuery += "GROUP BY ZL_SUPERVI, ZL_GRUPO "
//_cQuery += "ORDER BY ZL_SUPERVI, ZL_GRUPO "
// ALEX BORGES 02/12/11 - Acrescentado para separar as quantidades de meta valor e meta volume
_cQuery += " UNION "
_cQuery += "SELECT "
_cQuery += "ZL_SUPERVI, ZL_GRUPO, "
_cQuery += "COUNT(*) QUANT, "
//_cQuery += " 0 AS 'VALOR', SUM(ZL_PESMETA)/COUNT(*) AS 'PESO' "  ALEX BORGES 06/12/11
_cQuery += " 0 AS 'VALOR', SUM(ZL_PESMETA) AS 'PESO' "
_cQuery += "FROM "+RetSqlName("SZL")+ " "
_cQuery += "WHERE (ZL_SUPERVI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
//_cQuery += "AND (ZL_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') " ALEX BORGES 06/12/11 
_cQuery += "AND (ZL_DATA BETWEEN '"+DTOS(MV_PAR10)+"' AND '"+DTOS(MV_PAR11)+"') " 
_cQuery += "AND D_E_L_E_T_ = '' AND ZL_PESMETA > 0 "
_cQuery += "GROUP BY ZL_SUPERVI, ZL_GRUPO "
//_cQuery += "ORDER BY ZL_SUPERVI, ZL_GRUPO "

TCQUERY _cQuery new alias "TMP_SZL"
TMP_SZL->(dbgotop())

While !EOF()
	//if TMP_SZL->PESO > 0    - ALEX BORGES 02/12/11
		dbSelectArea("SBM")
		DbSetOrder(1)
		dbSeek(xfilial() + TMP_SZL->ZL_GRUPO)
		_cNomGrupo	  := SBM->BM_DESC
		_cNivel		  := SBM->BM_NIVEL
		_cQuebraNivel := SBM->BM_QBRNVL
		_ValorMeta    := TMP_SZL->VALOR
		_VolumeMeta   := TMP_SZL->PESO
			
		&&Totalizadores - Mauricio 05/10/11
		dbSelectArea("SX5") 
		DbSetOrder(1)
		if dbSeek("02W1"+_cQuebraNivel)    &&Usa cadastro criado somente na filial 02 - tabela criada W1. 
		   _cQuebraTot := Substr(SX5->X5_DESCRI,1,1)
		Else
		   _cQuebraTot :=  "9"                &&Para efeito de ordenação utilizo quando não ha cadastro codigo 9.
		Endif
 //		ALERT(TMP_SZL->ZL_GRUPO + " VALOR=" + STR(_ValorMeta) + " VOLUME=" + STR(_VolumeMeta))
		dbSelectArea("TEM2")
		if !dbSeek(TMP_SZL->ZL_SUPERVI+_cQuebraTot+_cQuebraNivel+TMP_SZL->ZL_GRUPO)   &&Totalizadores - Mauricio 05/10/11
		&&if !dbSeek(TMP_SZL->ZL_SUPERVI+_cQuebraNivel+TMP_SZL->ZL_GRUPO)
			//dbSelectArea("TEM2")
			RecLock("TEM2",.T.)
			TEM2->T2_SUPERVI  	:=	TMP_SZL->ZL_SUPERVI
			TEM2->T2_CODGRUP	:=	TMP_SZL->ZL_GRUPO
			TEM2->T2_NOMGRUP	:=	_cNomGrupo
			TEM2->T2_VENDAS		:=	0
			If _ValorMeta > 0
				TEM2->T2_MT_PRC		:= 	_ValorMeta
			EndIf
			If _VolumeMeta >0
				TEM2->T2_MT_VOL		:= _VolumeMeta
			EndIf
			TEM2->T2_RE_PRC		:= 	0
			TEM2->T2_RF_PRC     :=  0
			TEM2->T2_EMISSAO	:= 	mv_Par01//DTOS(mv_Par01)
			TEM2->T2_QBRNVL		:= _cQuebraNivel
			TEM2->T2_QBRTOT		:= _cQuebraTot        &&Totalizadores - Mauricio 05/10/11   
			MsUnLock()
		Else
		    //dbSelectArea("TEM2")
			RecLock("TEM2",.F.) 
			If _ValorMeta > 0
				TEM2->T2_MT_PRC		:= 	_ValorMeta
			EndIf
			If _VolumeMeta >0
				TEM2->T2_MT_VOL		:=_VolumeMeta
			EndIf
			MsUnLock()
		Endif
	//Endif   
    
	dbSelectArea("TMP_SZL")
	DbSkip()
End

//
Processa({|| ImpTra1()},"Processando NF SAIDA ...")
XF2->(dbclosearea())
TMP_SZL->(dbclosearea())

//Daniel 25/01/07
//+----------------------------------------+
//|Removido pois o conceito estava errado  |
//|A devolução passou a ser descontada do  |
//|SD2 antes do desconto financeiro        |
//|Mantendo o mesmo conceito do AD0012     |
//+----------------------------------------+

/*
cQuery:="select F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_DTDIGIT "+;
"from "+retsqlname("SF1")+" "+;
"where F1_FILIAL='"+SM0->M0_CODFIL+"' and "+;
"F1_TIPO='D' and "+;
"F1_DTDIGIT between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+;
"D_E_L_E_T_= '' "+;
"order by F1_DTDIGIT,F1_DOC,F1_SERIE"

//TCQUERY cQuery new alias "XF1"
//dbSelectArea("XF1")
//Processa({|| MontaTra1()},"Processando NF DEVOLUCAO ...")
Return

Static Function MontaTra1()

dbSelectArea("XF1")
ProcRegua(RecCount())

XF1->(dbgotop())
do while !XF1->(Eof())

IncProc(" NFiscal Dev.: " + XF1->F1_DOC + " - Dt.Emissao : "+XF1->F1_DTDIGIT)
_cDOC      	:= 	XF1->F1_DOC
_cSERIE    	:= 	XF1->F1_SERIE
_cCLIENTE  	:= 	XF1->F1_FORNECE
_cLOJA     	:= 	XF1->F1_LOJA

dbselectArea("SA1")
dbSeek(xfilial() + _cCliente)
_vendedor	:=	SA1->A1_VEND

dbSelectArea("SA3")
dbSeek(xfilial() + _Vendedor)
_Supervis := A3_CODSUP

IF _Supervis >= mv_par03 .AND. _Supervis <= mv_par04
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xfilial("SD1") + _cDOC + _cSERIE + _cCLIENTE +_cLOJA)

DO WHILE !EOF() .AND. 	SD1->D1_DOC 		== _cDOC     	.AND. ;
SD1->D1_SERIE    	== _cSERIE   	.AND. ;
SD1->D1_FORNECE  	== _cCLIENTE .AND. ;
SD1->D1_LOJA		== _cLOJA

_nQtd      	:= SD1->D1_QUANT	* (-1)
_nVal      	:= SD1->D1_TOTAL	* (-1)
_cProduto	:= SD1->D1_COD
dbSelectArea("SB1")
IF dbSeek(xfilial() + _cProduto)
_cGrupoN	:= SB1->B1_GRUPO       //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
//				_cGrupoN	:= SB1->B1_XGRPANT
Endif
dbSelectArea("SBM")
DbSetOrder(1)
dbSeek(xfilial() + _cGrupoN)
_cNomGrupo	  := SBM->BM_DESC
_cNivel		  := SBM->BM_NIVEL
_cQuebraNivel := SBM->BM_QBRNVL
dbSelectArea("TEM2")
IF 	dbSeek(_Supervis+_cQuebraNivel+_cGrupoN) .and.	_cNivel=="3"
//			IF 	dbSeek(_cSuper+_cGrupoN)
RecLock("TEM2",.F.)
TEM2->T2_VENDAS		:=	TEM2->T2_VENDAS + _nQtd
TEM2->T2_RE_PRC		:= TEM2->T2_RE_PRC	+ _nVal
MsUnLock()

Endif

dbSelectArea("TEM1")
If dbSeek(_Supervis+_cCliente)
RecLock("TEM1",.F.)

TEM1->T1_VALBRUT 	+= 	_nVal
MsUnLock()
Endif


dbSelectArea("SD1")
dbskip()
ENDDO
Endif
dbSelectArea("XF1")
dbskip()
ENDDO
XF1->(dbclosearea())

Set Century Off
dbSelectArea("TEM2")
Processa({|| ImpTra1()},"Processando NF SAIDA ...")
Return
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A IMPRESSAO DO TEMP          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Incrementa a regua                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC FUNCTION IMPTRA1

&&Mauricio 06/03/13 - tratamento para saida Excel solicitada pelo Sr. Vagner.
cPath    := AllTrim(GetTempPath())
cArq     := "AD0027Y"+__cUserID+".CSV" //"AD0027Y.CSV" //Alterado para não travar o relatorio de outro usuario

if file(cPath+"\"+cArq)
	FErase(cPath+"\"+cArq)		
endif

if file("\SYSTEM\"+cArq)
	FErase("\SYSTEM\"+cArq)
endif

nHdl := fCreate(cArq,0)
_Vazia := ";;;;;;;;;;;;;;;;;;"+_eof
&&19 colunas

dbSelectArea("TEM2")
dbGoTop()

_Supervis:= TEM2->T2_SUPERVI

nLin:=5
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

AchaMetaCli(_Supervis,mv_par02)

ImpCabec(_Supervis,_cMeta,_nVlr,1)
_cQuebraAnt:=	TEM2->T2_QBRNVL
_cQuebraTot:=   TEM2->T2_QBRTOT      &&Mauricio 19/10/11
_nContaSup := 1
DO WHILE !EOF()         	
	IncProc(" Supervisor: " + TEM2->T2_SUPERVI)
	&&Mauricio - Se o supervisor nao éo mesmo quebra.....		
	If T2_SUPERVI !=_Supervis
	    _nContaSup += 1
		Quebra(1)
		Quebra2(1)      &&Mauricio 19/10/11
		TotGer(1)
		ImpTotais(_Supervis)
		&&Mauricio 29/11/11.
        Impttlzd2()   &&Mauricio 07/12/11.
		@nLin,000 PSAY "|"+Replic("-",217)+"|"
		nLin := nLin + 1
		@nLin,002 PSAY "|" + _supervis
		@nLin,218 PSAY "|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"+Replic("-",217)+"|"
		nLin := nLin + 1
		_cQuebraAnt:=	TEM2->T2_QBRNVL
		_cQuebraTot:=   TEM2->T2_QBRTOT      &&Mauricio 19/10/11
		//ImpCabec3(T2_SUPERVI,_cMeta,_nVlr,1)
		nLin:=56
	Endif
	
	If nLin > 55 
	    
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 6
		_Supervis:=T2_SUPERVI
		AchaMetaCli(_Supervis,mv_par02)
		ImpCabec(_Supervis,_cMeta,_nVlr,1)    &&ImpCabec(_Supervis,_cMeta,_nVlr,2) Mauricio 05/08/15
	Endif                                     
	
	&&se o quebra de nivel nao é o mesmo, quebra......
	If 	TEM2->T2_QBRNVL != _cQuebraAnt
		
		Quebra(1)
		_cQuebraAnt:=	TEM2->T2_QBRNVL
		&&Mauricio - estas variaveis é que vou ter de armazenar para a nova quebra por totalizador
		_nAcumVendas:=	0
		_nAcumMtPrc	:=	0
		_nAcumRePrc	:=	0
		_nAcumRfPrc	:=	0
		_nAcumMtVol	:=	0
	Endif
	
	If 	TEM2->T2_QBRTOT != _cQuebraTot         &&Mauricio 19/10/11.
		
		Quebra2(1)
		_cQuebraTot:=	TEM2->T2_QBRTOT
		&&Mauricio - estas variaveis é que vou ter de armazenar para a nova quebra por totalizador
		_nAcVdT     :=	0
		_nAcMtPrcT	:=	0
		_nAcRePrcT	:=	0
		_nAcRfPrcT	:=	0
		_nAcMtVolT	:=	0
	Endif
  	if !(ALLTRIM(TEM2->T2_QBRNVL) $ _cAgrupadores)
   		If empty(_cAgrupadores)
   			_cAgrupadores := _cAgrupadores + TEM2->T2_QBRNVL  	
   		Else
   			_cAgrupadores := _cAgrupadores +"+"+ TEM2->T2_QBRNVL  
   		EndIF		  
   	EndIF 
	
	cLin := "" 
	@nLin,000 PSAY "|" + T2_QBRNVL + T2_QBRTOT
	@nLin,004 PSAY T2_CODGRUP
	@nLin,010 PSAY SUBSTR(T2_NOMGRUP,1,20) //STOP
	cLin += T2_QBRNVL + T2_QBRTOT+";"+T2_CODGRUP+" "+SUBSTR(T2_NOMGRUP,1,20)+";"
	@nLin,032 PSAY "|"         &&34
	@nLin,034 PSAY T2_MT_PRC PICTURE "@E 99.99" // "Preço FOB(R$/KG)" Meta  //36
	cLin += Transform(T2_MT_PRC,"@E 99.99")+";"
	@nLin,041 PSAY T2_RE_PRC / T2_VENDAS PICTURE "@E 99.99"  // "Preço FOB(R$/KG)" Realizado  43
	cLin += Transform(T2_RE_PRC / T2_VENDAS,"@E 99.99")+";"
	If _lDiret
	   @nLin,048 PSAY T2_RF_PRC PICTURE "@E 99.99" // "Preço FOB(R$/KG)" Referencia 50
	   cLin += Transform(T2_RF_PRC,"@E 99.99")+";"
	Endif   
	@nLin,056 PSAY "|"  //58

	@nLin,057 PSAY T2_VENDAS *  T2_MT_PRC PICTURE "@E 999,999,999" // "Faturamento(R$)"  Meta 59
	cLin += Transform(T2_VENDAS *  T2_MT_PRC,"@E 999,999,999")+";"
	_nTotD:=0
	_nTotD+=T2_VENDAS *  T2_MT_PRC
	_I:=aScan(aAcD,{|x| x[2]==T2_CODGRUP})
	If _I==0
		AADD(aAcD,{T2_QBRNVL,T2_CODGRUP,_nTotD})
	Else
		aAcD[_I][3]+=_nTotD
	Endif
	
	@nLin,069 PSAY T2_RE_PRC PICTURE "@E 999,999,999"  // "Faturamento(R$)"  Realizado 71
	cLin += Transform(T2_RE_PRC,"@E 999,999,999")+";"
	If _lDiret
	   @nLin,082 PSAY T2_VENDAS *  T2_RF_PRC  PICTURE "@E 999,999,999"// "Faturamento(R$)"  Referencia 84
	   cLin += Transform(T2_VENDAS *  T2_RF_PRC,"@E 999,999,999")+";"
	Endif   
	@nLin,096 PSAY T2_RE_PRC  - (T2_VENDAS *  T2_MT_PRC)	PICTURE "@E 99,999,999" // "Diferenca Fat.(R$)"  Real -Meta    98
	cLin += Transform(T2_RE_PRC  - (T2_VENDAS *  T2_MT_PRC),"@E 99,999,999")+";"
	If _lDiret
	   @nLin,107 PSAY T2_RE_PRC  - (T2_VENDAS *  T2_RF_PRC)	PICTURE "@E 99,999,999"  // "Diferenca Fat.(R$)"  Real -Referencia  109
	   cLin += Transform(T2_RE_PRC  - (T2_VENDAS *  T2_RF_PRC),"@E 99,999,999")+";"
    Endif
	@nLin,119 PSAY "|"   //121
	@nLin,124 PSAY T2_RE_PRC / (T2_VENDAS *  T2_MT_PRC) PICTURE "@E 9.999"  // "Indice" IPM 126
	cLin += Transform(T2_RE_PRC / (T2_VENDAS *  T2_MT_PRC),"@E 9.999")+";"
	If _lDiret
	   &&Mauricio - 09/04/14 - alterado formula de calculo conforme solicitações dos Srs. Marcus e Vagner.
	   @nLin,131 PSAY (T2_RE_PRC / T2_VENDAS) - T2_RF_PRC PICTURE "@E 99.999" // "Indice" IPR  133
	   cLin += Transform((T2_RE_PRC / T2_VENDAS) - T2_RF_PRC,"@E 99.999")+";"
	   	   
	   //@nLin,133 PSAY T2_RE_PRC / (T2_VENDAS *  T2_RF_PRC) PICTURE "@E 99.999" // "Indice" IPR
	   //cLin += Transform(T2_RE_PRC / (T2_VENDAS *  T2_RF_PRC),"@E 99.999")+";"
    Endif
	@nLin,139 PSAY "|"    //141
	//@nLin,142 PSAY "|"
	@nLin,140 PSAY T2_MT_VOL PICTURE "@E 99,999,999"  // "Volume(Kgs) Meta"  143
	cLin += Transform(T2_MT_VOL,"@E 99,999,999")+";"
    @nLin,152 PSAY T2_VENDAS PICTURE "@E 99,999,999"   // Volume(Kgs) Realizado 155
    cLin += Transform(T2_VENDAS,"@E 99,999,999")+";"
	&&@nLin,141 PSAY T2_VENDAS / _nDiasUtil PICTURE "@E 999,999"  //I
	@nLin,162 PSAY (T2_VENDAS / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  // "Volume(Kgs)" Projetado  167 -3 - 2
	cLin += Transform((T2_VENDAS / _nDiasCorr) * _nDiasUtil,"@E 99,999,999")+";"
	&&@nLin,152 PSAY (T2_VENDAS / _nDiasUtil) - T2_MT_VOL  PICTURE "@E 999,999"  //J
	@nLin,177 PSAY (T2_MT_VOL- T2_VENDAS) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999" // "Volume(Kgs)" Necessaria   182 
	cLin += Transform((T2_MT_VOL- T2_VENDAS) / (_nDiasUtil - _nDiasCorr),"@E 99999,999" )+";"
	@nLin,186 PSAY "|"   //191
	&&@nLin,165 PSAY (T2_VENDAS / _nDiasUtil) / T2_MT_VOL PICTURE "@E 99.999"  //k
	@nLin,192 PSAY (T2_VENDAS / T2_MT_VOL)*100 PICTURE "@E 9999.9"  //"Atingimento" Realizado  197
	cLin += Transform((T2_VENDAS / T2_MT_VOL)*100,"@E 9999.9" )+";"
	//@nLin,210 PSAY ((T2_VENDAS / _nDiasCorr) * _nDiasUtil) / T2_VENDAS PICTURE "@E 999.9"  //"Atingimento" Projetado   // Alex Borges 25/11/11
	@nLin,205 PSAY (((T2_VENDAS / _nDiasCorr) * _nDiasUtil) / T2_MT_VOL)*100 PICTURE "@E 9999.9"  //"Atingimento" Projetado  210
	cLin += Transform((((T2_VENDAS / _nDiasCorr) * _nDiasUtil) / T2_MT_VOL)*100,"@E 9999.9" )+";"
	&&Mauricio - 01/07/15 - calculo da cobertura(qtd clientes)
	dBSelectArea("COBSUP")
	DbGotop()
	_nSomCli := 0
	if dbseek(TEM2->T2_SUPERVI+TEM2->T2_QBRTOT+TEM2->T2_QBRNVL+TEM2->T2_CODGRUP)
	   WHILE COBSUP->(!EOF()) .AND. TEM2->T2_SUPERVI+TEM2->T2_QBRTOT+TEM2->T2_QBRNVL+TEM2->T2_CODGRUP == COBSUP->T2_SUPERVI+COBSUP->T2_QBRTOT+COBSUP->T2_QBRNVL+COBSUP->T2_CODGRUP
	         _nSomCli ++
	         COBSUP->(dbSkip())
	   Enddo
	Endif
	DbSelectArea("TEM2")
	@nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
	cLin += Transform(_nSomCli,"@E 9999" )+_eof
	&&fim 01/07/15
	fWrite(nHdl,cLin,Len(cLin))
	@nLin,218 PSAY "|"
	nLin++
	
	_nAcumVendas+=	T2_VENDAS
	_nAcumMtPrc	+=	(T2_VENDAS *  T2_MT_PRC)
	_nAcumRePrc	+=	T2_RE_PRC
	_nAcumMtVol	+=	T2_MT_VOL
	//_nAcumRfPrc +=	T2_RF_PRC Alex Borges - 25/11/11
	_nAcumRfPrc +=	(T2_VENDAS *  T2_RF_PRC)
	
	&&Mauricio 19/10/11 - totalizadores
	_nAcVdT     +=	T2_VENDAS
	_nAcMtPrcT	+=	(T2_VENDAS *  T2_MT_PRC)  
	_nAcRePrcT	+=	T2_RE_PRC
	_nAcMtVolT	+=	T2_MT_VOL
    //_nAcRfPrcT	+=	T2_RF_PRC
    _nAcRfPrcT	+=	(T2_VENDAS * T2_RF_PRC)
    			
	_Supervis:= 	TEM2->T2_SUPERVI
	_cQuebraAnt:=	TEM2->T2_QBRNVL
	_cQuebraTot:=   TEM2->T2_QBRTOT      &&Mauricio 19/10/11
	
	dbSelectArea("TEM2")
	DbSkip()
	
Enddo

Quebra(1)
Quebra2(1)                                &&Mauricio 19/10/11
TotGer(1)                                 &&Mauricio 21/10/11 
ImpTotais(_Supervis)
&&Mauricio 29/11/11.
Impttlzd2()   &&Mauricio 07/12/11
@nLin,00 PSAY "|"+Replic("-",217)+"|"
nLin := nLin + 1
@nLin,02 PSAY _supervis
nLin := nLin + 1
@nLin,00 PSAY "|"+Replic("-",217)+"|"

nLin := nLin + 1
ImpTotGeral()
nLin := 56  //61

//Impttlzd()               
Set Device to Screen


Ms_Flush()

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
endif 
      
fClose(nHdl)

&&Mauricio - 16/04/14 - somente alguns usuarios podem gerar saida em excel....solicitado pela Ana TI.
If __cUserID $ GETMV("MV_#USUTPR")   &&usuario bonificacao ADM VENDAS
   bBloco:={|| _fOpenExcel()}
   MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)
Endif   

dbSelectArea('TEM1')
dbclosearea("TEM1")
dbSelectArea('TEM2')
dbclosearea("TEM2")
dbSelectArea('COBSUP')
dbclosearea("COBTOT")
fErase(_cNomTrM+'.*')
fErase(_cNomTrN+'.*')  
fErase(_cNomTr1+'.*')
fErase(_cNomTr2+'.*')  
if file("\SYSTEM\"+cArq)    //Incluido por Adriana em 11/07/14 para excluir CSV quando nao abre Excel
	FErase("\SYSTEM\"+cArq)
endif

return

//*****************************************************************************
//Static Function ImpCabec(_Supervis,_cMeta)
//******************************************************************************

Static Function ImpCabec(_Supervis,_cMeta,_nVlr,_nExcel)

_nQtdcart := 0

_cQuery := ""
_cQuery += "SELECT COUNT(*) AS 'QTD_CLI'" 
_cQuery += "  FROM "+RetSqlName("SA1")+ " A1,"
_cQuery += "       "+RetSqlName("SA3")+ " A3"
_cQuery += " WHERE A1.D_E_L_E_T_ = ''"
_cQuery += "   AND A3.D_E_L_E_T_ = '' "
_cQuery += "   AND A1.A1_VEND = A3.A3_COD"
_cQuery += "   AND A3.A3_CODSUP = '"+_Supervis+"'"

TCQUERY _cQuery new alias "CARTEIRA"
CARTEIRA->(dbgotop())
While !EOF()
_nQtdcart := CARTEIRA->QTD_CLI
CARTEIRA->(dbskip())
Enddo   
CARTEIRA->(dbclosearea()) 

@nLin,001 PSAY Replic("_",217)
nLin := nLin + 1
/*
dbSelectArea("TEM1")
dbGoTop()
If DbSeek (_Supervis)
	Do While !EOF() .and. TEM1->T1_SUPERVI ==_Supervis
		If T1_QTDVEZ > 0 .AND. T1_VALBRUT >= _nVlr
			_cCont++
			
		Endif
		DbSkip()
	Enddo
Endif    */  

dbSelectArea("CLIENTE")
dbGoTop()
If DbSeek (_Supervis)
	Do While !EOF() .and. CLIENTE->CLI_SUPERV ==_Supervis
		_cCont++
		//If CLIENTE->CLI_FLAG = 'S'    ALEX BORGES 09/12/11
		IF CLIENTE->CLI_VALOR >= MV_PAR08
			_cContv++
		Endif	
		//if CLIENTE->CLI_FLAG2 = 'S'    ALEX BORGES 09/12/11
	   IF CLIENTE->CLI_VALOR >= MV_PAR09
		    _cContv2++			
		EndIf	
	
		DbSkip()
	Enddo
Endif
            
if Ascan(_aSup,_Supervis) == 0
   AADD(_aSup,_Supervis)
   _nQtcartT += _nQtdcart
   _nTotCont  += _cCont   
   _nTotContv += _cContv
   _nTContv2  += _cContv2
endif 
 
_NomSup := Posicione("SZR",1,xFilial("SZR")+_Supervis,"ZR_DESCRIC")
_TamNomSUp := LEN(_NomSup)
_nIndice:=(_cCont / _cMeta)*100
&&Mauricio 26/10/11 - incluido dias corridos
//Cabec3 := "| SUPERVISOR: "+ _Supervis + Space(111)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+ "      DIAS " + Space(16)+"|"
Cabec3 := "| SUPERVISOR: "+ _Supervis +" - "+ _NomSup + Space(108-_TamNomSUp)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4) +Space(54)+"  DIAS UTEIS: " +right(str(_nDiasUtil),2)+"  |"
//If _nExcel == 1
   cLin := "SUPERVISOR:;"+_Supervis+";"+_NomSup+";;;;;DE:"+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+";;;;;DIAS UTEIS:;"+right(str(_nDiasUtil),2)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
//Endif 
//Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(6)+ "UTEIS: " +right(str(_nDiasUtil),2)+Space(12)+"|"
Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(2)+Space(51)+ "DIAS CORRIDOS: " +right(str(_nDiasCorr),2)+"  |"
//If _nExcel == 1
   cLin := ";;;;;;;ATE:"+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4)+";;;;;DIAS CORRIDOS:;"+right(str(_nDiasCorr),2)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
//Endif
Cabec5 := "| CLIENTES CARTEIRA : "+right(str(_nQtdcart),5)+"        COBERTURA MES: "+right(str(_cCont),5)+"     ATIVO1: "+right(str(_cContv),5)+"     ATIVO2: "+right(str(_cContv2),5)
//If _nExcel == 1
   cLin := "CLIENTES;CARTEIRA:;"+right(str(_nQtdcart),5)+";;;;COBERTURA;MES:"+right(str(_cCont),5)+";;ATIVO1:;"+right(str(_cContv),5)+";;ATIVO2:;"+right(str(_cContv2),5)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
   fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco
//Endif
cabec5B:="   "+ Space(149)+"|"
_cCont1:=_cCont1+_cCont

@nLin,000 PSAY Cabec3
nLin++

@nLin,00 PSAY Cabec4
nLin++

@nLin,00 PSAY Cabec5

//If _nIndice <= 99.99
//	@nLin,060 PSAY SUBSTR(alltrim(str(_nIndice)),1,5) PICTURE "@E 99.99"
//Else
//	@nLin,060 PSAY SUBSTR(alltrim(str(_nIndice)),1,5) PICTURE "@E 999.99"
//Endif

@nLin,067 PSAY Cabec5B
nLin++

@nLin,000 PSAY "|" + Replic("_",217)+"|"
nLin++

@nLin,00 PSAY Cabec6
//If _nExcel == 1
   fWrite(nHdl,cLin6,Len(cLin6))
//Endif  
nLin++

@nLin,00 PSAY Cabec7
//If _nExcel == 1
   fWrite(nHdl,cLin7,Len(cLin7))
//Endif  
nLin++

@nLin,00 PSAY Cabec8
nLin++
dbSelectArea("TEM2")
_cCont:=0
_cContV:=0
_cContv2:=0
Return

Static Function ImpCabec2

_nIndice:=0

@nLin,001 PSAY Replic("_",217)
nLin := nLin + 1

dbSelectArea("TEM1")
dbGoTop()

_nIndice:=(_cCont1 / _cAcumMetaCli)*100
&&Mauricio 26/10/11 - incluido dias corridos
//Cabec3 := "| SUPERVISOR: "+mv_par03+ " Ate "+mv_par04+ Space(100)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+ "      DIAS " + Space(16)+"|"
Cabec3 := "| SUPERVISOR: "+mv_par03+ " Ate "+mv_par04+ Space(100)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+ Space(54)+"  DIAS UTEIS: " +right(str(_nDiasUtil),2)+"  |"
cLin := "SUPERVISOR:;"+mv_par03+"; Ate "+mv_par04+";;;;;DE:"+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+";;;;;DIAS UTEIS:;"+right(str(_nDiasUtil),2)+";;;"+_eof
fWrite(nHdl,cLin,Len(cLin)) 
//Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(6)+ "UTEIS: " +right(str(_nDiasUtil),2)+Space(12)+"|"
Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(2)+Space(51)+ "DIAS CORRIDOS: " +right(str(_nDiasCorr),2)+Space(49)+"  |"
cLin := ";;;;;;;ATE:"+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4)+";;;;;DIAS CORRIDOS:;"+right(str(_nDiasCorr),2)+";;;"+_eof
fWrite(nHdl,cLin,Len(cLin)) 
//Cabec5 := "| CLIENTES  META : "+right(str(_cAcumMetaCli),4)+"        REALIZADO: "+right(str(_cCont1),4)+"     INDICE: "//+ right(str(_nIndice ),4)+" % "+ Space(107)+"|"
Cabec5 := "| CLIENTES CARTEIRA : "+right(str(_nQtcartT),5)+"        COBERTURA MES: "+right(str(_nTotCont),5)+"     ATIVO1: "+right(str(_ntotContv),5)+"     ATIVO2: "+right(str(_ntContv2),5)
cLin := "CLIENTES;CARTEIRA:;"+right(str(_nQtcartT),5)+";;;;COBERTURA;MES:"+right(str(_nTotCont),5)+";;ATIVO1:;"+right(str(_ntotContv),5)+";;ATIVO2:;"+right(str(_ntContv2),5)+";;;"+_eof
fWrite(nHdl,cLin,Len(cLin))
fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco 
cabec5B:="  "+ Space(150)+"|"
@nLin,000 PSAY Cabec3
nLin++

@nLin,00 PSAY Cabec4
nLin++                    

@nLin,000 PSAY Cabec5
//If _nIndice <= 99.99
//	@nLin,060 PSAY SUBSTR(alltrim(str(_nIndice)),1,5) PICTURE "@E 99.99"
//Else
//	@nLin,060 PSAY SUBSTR(alltrim(str(_nIndice)),1,5) PICTURE "@E 999.99"
//Endif
@nLin,067 PSAY Cabec5b
nLin++

@nLin,000 PSAY "|" + Replic("_",217)+"|"
nLin++

@nLin,00 PSAY Cabec6
fWrite(nHdl,cLin6,Len(cLin6)) 
nLin++

@nLin,00 PSAY Cabec7
fWrite(nHdl,cLin7,Len(cLin7)) 
nLin++

@nLin,00 PSAY Cabec8
nLin++
_cAcumMetaCli :=0
dbSelectArea("TEM2")

Return

STATIC FUNCTION ACHAMETA()

_nMTPRC:=0
_nMTVOL:=0

dbSelectArea("SZL")
dbSetOrder(1)
             
//dbSeek(xfilial("SZL") + _cSuper	+ _cGrupo + DTOS(mv_par01)) ALEX BORGES 06/12/11
dbSeek(xfilial("SZL") + _cSuper	+ _cGrupo + DTOS(mv_par10))

_nContDias	:=	0
Do while !EOF()
	
	//IF (dtos(SZL->ZL_DATA) > DTOS(mv_par02)) .or. _cGrupo != SZL->ZL_grupo  ALEX BORGES 06/12/11
	IF (dtos(SZL->ZL_DATA) > DTOS(mv_par11)) .or. _cGrupo != SZL->ZL_grupo
		exit
	Endif
	//IF dtos(SZL->ZL_DATA) >= DTOS(mv_par01) ALEX BORGES 06/12/11
	IF dtos(SZL->ZL_DATA) >= DTOS(mv_par10)
		//INICIO DA ALTERACAO - HERALDO 03/10/2003
		If SZL->ZL_VALOR > 0		// incluido
			_nMTPRC	:=	_nMTPRC + SZL->ZL_VALOR
			//_nMTVOL	:=	_nMTVOL + SZL->ZL_PESMETA   --ALEX BORGES 06/12/11
			_nContDias++			
		Endif
		// incluido
		// FIM DA ALTERACAO - HERALDO 03/10/2003  
		
		If SZL->ZL_PESMETA > 0		// incluido
			_nMTVOL	:=	_nMTVOL + SZL->ZL_PESMETA
		Endif
	Endif
	dbskip()                    
Enddo
_nMTPRC	:=	_nMTPRC / _nContDias
//_nMTVOL	:=	_nMTVOL         &&Mauricio 16/11/11 retirado media por dia deixando valor acumulado(META MES)    	/ _nContDias


Return
&&Mauricio MDS TEC funcao para buscar o valor de REFERENCIA em nova tabela criada pelo Sr. Alex.
STATIC FUNCTION ACHAREF()

_nRFPRC:=0

dbSelectArea("ZZS")
dbSetOrder(1)             
//dbSeek(xfilial("ZZS") + _cGrupo + DTOS(mv_par01))   ALEX BORGES 06/12/11
dbSeek(xfilial("ZZS") + _cGrupo + DTOS(mv_par10))

_nContDias	:=	0
Do while !EOF()
	
	//IF (dtos(ZZS->ZZS_DATA) > DTOS(mv_par02)) .or. _cGrupo != ZZS->ZZS_GRUPO   ALEX BORGES 06/12/11
	IF (dtos(ZZS->ZZS_DATA) > DTOS(mv_par11)) .or. _cGrupo != ZZS->ZZS_GRUPO
		exit
	Endif
	        
	//IF dtos(ZZS->ZZS_DATA) >= DTOS(mv_par01)	ALEX BORGES 06/12/11
	IF dtos(ZZS->ZZS_DATA) >= DTOS(mv_par10)	
		If ZZS->ZZS_VALOR > 0	
			_nRFPRC	:=	_nRFPRC + ZZS->ZZS_VALOR		
			_nContDias++
		Endif							
	Endif
	ZZS->(dbskip())
Enddo
_nRFPRC	:=	_nRFPRC / _nContDias

Return

/*************************************************************************************************
Static Function AchaMetaCli()
Responsavel por achar a meta de clientes do supervisor em determinado mes
*************************************************************************************************/

Static Function AchaMetaCli(_Supervis,mv_par02)
aMetasMes:={}
_nVlr:=0
mes:=0
mes:=val(substr(dtos(mv_par02),5,2))
dbSelectArea("SZR")
DbSetOrder(1)
If dbSeek(xFilial()+_Supervis)
	Do case
		case mes==01
			_cMeta	:= ZR_MES01
			_nVlr	:= ZR_ATI01
		case mes==02
			_cMeta:=ZR_MES02
			_nVlr	:= ZR_ATI02
		case mes==03
			_cMeta:=ZR_MES03
			_nVlr	:= ZR_ATI03
		case mes==04
			_cMeta:=ZR_MES04
			_nVlr	:= ZR_ATI04
		case mes==05
			_cMeta:=ZR_MES05
			_nVlr	:= ZR_ATI05
		case mes==06
			_cMeta:=ZR_MES06
			_nVlr	:= ZR_ATI06
		case mes==07
			_cMeta:=ZR_MES07
			_nVlr	:= ZR_ATI07
		case mes==08
			_cMeta:=ZR_MES08
			_nVlr	:= ZR_ATI08
		case mes==09
			_cMeta:=ZR_MES09
			_nVlr	:= ZR_ATI09
		case mes==10
			_cMeta:=ZR_MES10
			_nVlr	:= ZR_ATI10
		case mes==11
			_cMeta:=ZR_MES11
			_nVlr	:= ZR_ATI11
		case mes==12
			_cMeta:=ZR_MES12
			_nVlr	:= ZR_ATI12
		Otherwise
			Alert("Erro na meta de Clientes")
	EndCase
Endif
_cAcumMetaCli+=_cMeta
Return(_cMeta,_nVlr)

/*************************************************************************************************
Static Function ImpTotais(_Supervis)
*************************************************************************************************/

Static Function ImpTotais(_Supervis)

_nA1T2Vendas	:= 0
_nA1T2MtPrc	:= 0
_nA1T2RePrc	:= 0
_nA1T2MtVol	:= 0
_nA1T2RfPrc	:= 0

_nA2T2Vendas	:= 0
_nA2T2MtPrc	:= 0
_nA2T2RePrc	:= 0
_nA2T2MtVol	:= 0
_nA2T2RfPrc	:= 0

_nA3T2Vendas	:= 0
_nA3T2MtPrc	:= 0
_nA3T2RePrc	:= 0
_nA3T2MtVol	:= 0
_nA3T2RfPrc	:= 0


_nA4T2Vendas	:= 0
_nA4T2MtPrc	:= 0
_nA4T2RePrc	:= 0
_nA4T2MtVol	:= 0
_nA4T2RfPrc	:= 0

//INCLUIDO LEONARDO (HC) PARA TESTE DE NOVO TOTALIZADOR
_nA5T2Vendas	:= 0
_nA5T2MtPrc	:= 0
_nA5T2RePrc	:= 0
_nA5T2MtVol	:= 0
_nA5T2RfPrc	:= 0

//INCLUIDO ADRIANA  (HC) PARA NOVO TOTALIZADOR 6 - CHAMADO 008151
_nA6T2Vendas	:= 0
_nA6T2MtPrc	:= 0
_nA6T2RePrc	:= 0
_nA6T2MtVol	:= 0
_nA6T2RfPrc	:= 0

dbgotop()
If dbSeek(_Supervis)
	Do While T2_SUPERVI ==_Supervis
		/*
		Do Case
			
			Case T2_CODGRUP $ mv_par06 .or. T2_CODGRUP $ mv_par07
				
				_nA1T2Vendas := _nA1T2Vendas + T2_VENDAS
				_nA1T2MtPrc	:= _nA1T2MtPrc  + T2_MT_PRC
				_nA1T2RePrc	:= _nA1T2RePrc  + T2_RE_PRC
				_nA1T2MtVol	:= _nA1T2MtVol  + T2_MT_VOL
				_nA1T2RfPrc	:= _nA1T2RfPrc  + T2_RF_PRC
				
			Case T2_CODGRUP $ mv_par09 .or. T2_CODGRUP $ mv_par10
				
				_nA2T2Vendas += T2_VENDAS
				_nA2T2MtPrc	+= T2_MT_PRC
				_nA2T2RePrc	+= T2_RE_PRC
				_nA2T2MtVol	+= T2_MT_VOL
				_nA2T2RfPrc	+= T2_RF_PRC
				
			Case T2_CODGRUP $ mv_par12 .or. T2_CODGRUP $ mv_par13
				
				_nA3T2Vendas += T2_VENDAS
				_nA3T2MtPrc	+= T2_MT_PRC
				_nA3T2RePrc	+= T2_RE_PRC
				_nA3T2MtVol	+= T2_MT_VOL
				_nA3T2RfPrc	+= T2_RF_PRC
				
			Case T2_CODGRUP $ mv_par15 .or. T2_CODGRUP $ mv_par16
				
				_nA4T2Vendas += T2_VENDAS
				_nA4T2MtPrc	+= T2_MT_PRC
				_nA4T2RePrc	+= T2_RE_PRC
				_nA4T2MtVol	+= T2_MT_VOL
				_nA4T2RfPrc	+= T2_RF_PRC
				
			//INCLUIDO LEONARDO (HC) TOTALIZADOR 5
			Case T2_CODGRUP $ mv_par18 .or. T2_CODGRUP $ mv_par19
				
				_nA5T2Vendas += T2_VENDAS
				_nA5T2MtPrc	+= T2_MT_PRC
				_nA5T2RePrc	+= T2_RE_PRC
				_nA5T2MtVol	+= T2_MT_VOL
	            _nA5T2RfPrc	+= T2_RF_PRC                

			//INCLUIDO ADRIANA (HC) TOTALIZADOR 6 - CHAMADO 008151
			Case T2_CODGRUP $ mv_par21 .or. T2_CODGRUP $ mv_par22
				
				_nA6T2Vendas += T2_VENDAS
				_nA6T2MtPrc	+= T2_MT_PRC
				_nA6T2RePrc	+= T2_RE_PRC
				_nA6T2MtVol	+= T2_MT_VOL
				_nA6T2RfPrc	+= T2_RF_PRC
				
		EndCase
		*/
		dbSkip()
	Enddo
Endif
/*
@nLin,000 PSAY "|"
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,191 PSAY "|"
@nLin,218 PSAY "|"
nLin++
@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par05
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA1T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta
&&@nLin,141 PSAY _nA1T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I 
@nLin,155 PSAY _nA1T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA1T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
&&@nLin,152 PSAY (_nA1T2Vendas / _nDiasUtil) - _nA1T2MtVol PICTURE "@E 9999,999"  //J
@nLin,182 PSAY (_nA1T2MtVol - _nA1T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY _nA1T2Vendas  / _nA1T2MtVol PICTURE "@E 999.9"  //k
//@nLin,210 PSAY ((_nA1T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA1T2Vendas  PICTURE "@E 999.9"  //"Atingimento(%)" Projetado    //Alex Borges 25/11/11
@nLin,210 PSAY ((_nA1T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA1T2MtVol  PICTURE "@E 999.9"  //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"

nLin++

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par08
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA2T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta

//@nLin,128 PSAY _nA2T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA2T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA2T2Vendas / _nDiasUtil) - _nA2T2MtVol  PICTURE "@E 9999,999"  //J
//@nLin,165 PSAY (_nA2T2Vendas / _nDiasUtil) / _nA2T2MtVol PICTURE "@E 99.999"  //k 

@nLin,155 PSAY _nA2T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA2T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
@nLin,182 PSAY (_nA2T2MtVol - _nA2T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY _nA2T2Vendas / _nA2T2MtVol PICTURE "@E 999.9"
//@nLin,210 PSAY ((_nA2T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA2T2Vendas PICTURE "@E 999.9"  //"Atingimento(%)" Projetado // Alex Borges 25/11/11
@nLin,210 PSAY ((_nA2T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA2T2MtVol PICTURE "@E 999.9" //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"


nLin++


@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par11
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA3T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta
@nLin,155 PSAY _nA3T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA3T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
@nLin,182 PSAY (_nA3T2MtVol - _nA3T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY _nA3T2Vendas / _nA3T2MtVol PICTURE "@E 999.9" 
//@nLin,210 PSAY ((_nA3T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA3T2Vendas PICTURE "@E 999.9"  //"Atingimento(%)" Projetado  //Alex Borges 25/11/11
@nLin,210 PSAY ((_nA3T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA3T2MtVol PICTURE "@E 999.9"  //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"

nLin++

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par14
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA4T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta
@nLin,155 PSAY _nA4T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA4T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
@nLin,182 PSAY (_nA4T2MtVol - _nA4T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY _nA4T2Vendas / _nA4T2MtVol PICTURE "@E 999.9" 
//@nLin,210 PSAY ((_nA4T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA4T2Vendas PICTURE "@E 999.9"  //"Atingimento(%)" Projetado  //Alex Borges 25/11/11
@nLin,210 PSAY ((_nA4T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA4T2MtVol PICTURE "@E 999.9"  //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"

nLin++

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par17
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA5T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta
@nLin,155 PSAY _nA5T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA5T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
@nLin,182 PSAY (_nA5T2MtVol - _nA5T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY _nA5T2Vendas / _nA5T2MtVol PICTURE "@E 999.9" 
//@nLin,210 PSAY ((_nA5T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA5T2Vendas PICTURE "@E 999.9"  //"Atingimento(%)" Projetado //Alex Borges 25/11/11
@nLin,210 PSAY ((_nA5T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA5T2MtVol PICTURE "@E 999.9"  //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"


//INCLUIDO ADRIANA (HC) TOTALIZADOR 6 - CHAMADO 008151

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par20
@nLin,034 PSAY "|"
@nLin,058 PSAY "|"
@nLin,121 PSAY "|"
@nLin,141 PSAY "|"
@nLin,142 PSAY "|"
@nLin,143 PSAY _nA6T2MtVol PICTURE "@E 99,999,999"  //"Volume(KG)" Meta
@nLin,155 PSAY _nA6T2Vendas PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
@nLin,167 PSAY (_nA6T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999"  //"Volume(KG)" Projetado
@nLin,182 PSAY (_nA6T2MtVol - _nA3T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //"Volume(KG)" Necessaria
@nLin,191 PSAY "|"
@nLin,197 PSAY  _nA6T2Vendas / _nA6T2MtVol PICTURE "@E 999.9"
//@nLin,210 PSAY ((_nA6T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA6T2Vendas PICTURE "@E 999.9"  //"Atingimento(%)" Projetado   //Alex Borges 25/11/11
@nLin,210 PSAY ((_nA6T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA6T2MtVol PICTURE "@E 999.9"  //"Atingimento(%)" Projetado
@nLin,218 PSAY "|"

nLin++
*/
return


Static Function ImpTotais2()

_nA1T2Vendas	:= 0
_nA1T2MtPrc	:= 0
_nA1T2RePrc	:= 0
_nA1T2MtVol	:= 0
_nA1T2RfPrc	:= 0

_nA2T2Vendas	:= 0
_nA2T2MtPrc	:= 0
_nA2T2RePrc	:= 0
_nA2T2MtVol	:= 0
_nA2T2RfPrc	:= 0

_nA3T2Vendas	:= 0
_nA3T2MtPrc	:= 0
_nA3T2RePrc	:= 0
_nA3T2MtVol	:= 0
_nA3T2RfPrc	:= 0

_nA4T2Vendas	:= 0
_nA4T2MtPrc	:= 0
_nA4T2RePrc	:= 0
_nA4T2MtVol	:= 0
_nA4T2RfPrc	:= 0

//INCLUIDO LEONARDO (HC) PARA TESTE DE NOVO TOTALIZADOR
_nA5T2Vendas	:= 0
_nA5T2MtPrc	:= 0
_nA5T2RePrc	:= 0
_nA5T2MtVol	:= 0
_nA5T2RfPrc	:= 0

//INCLUIDO ADRIANA  (HC) PARA NOVO TOTALIZADOR 6 - CHAMADO 008151
_nA6T2Vendas	:= 0
_nA6T2MtPrc	:= 0
_nA6T2RePrc	:= 0
_nA6T2MtVol	:= 0
_nA6T2RfPrc	:= 0

dbgotop()
/*
While !EOF() .and. T2_SUPERVI >= mv_par03 .and. T2_SUPERVI <= mv_par04 

    //If nLin > 60   //60
	//	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	//	nLin := 8
	//	ImpCabec2(_cAcumMetaCli)
	//Endif
	
	
	If T2_CODGRUP $ mv_par06 .or. T2_CODGRUP $ mv_par07
		
		_nA1T2Vendas += T2_VENDAS
		_nA1T2MtPrc	+= T2_MT_PRC
		_nA1T2RePrc	+= T2_RE_PRC
		_nA1T2MtVol	+= T2_MT_VOL
		_nA1T2RfPrc	+= T2_RF_PRC
	Endif
	
	If T2_CODGRUP $ mv_par09 .or. T2_CODGRUP $ mv_par10
		
		_nA2T2Vendas += T2_VENDAS
		_nA2T2MtPrc	+= T2_MT_PRC
		_nA2T2RePrc	+= T2_RE_PRC
		_nA2T2MtVol	+= T2_MT_VOL
		_nA2T2RfPrc	+= T2_RF_PRC
	Endif
	
	If T2_CODGRUP $ mv_par12 .or. T2_CODGRUP $ mv_par13
		
		_nA3T2Vendas += T2_VENDAS
		_nA3T2MtPrc	+= T2_MT_PRC
		_nA3T2RePrc	+= T2_RE_PRC
		_nA3T2MtVol	+= T2_MT_VOL
		_nA3T2RfPrc	+= T2_RF_PRC
		
	Endif
	
	
	If T2_CODGRUP $ mv_par15 .or. T2_CODGRUP $ mv_par16
		
		_nA4T2Vendas += T2_VENDAS
		_nA4T2MtPrc	+= T2_MT_PRC
		_nA4T2RePrc	+= T2_RE_PRC
		_nA4T2MtVol	+= T2_MT_VOL
		_nA4T2RfPrc	+= T2_RF_PRC
		
	Endif
	
	//INCLUIDO LEONARDO (HC) TOTALIZADOR 5
	If T2_CODGRUP $ mv_par18 .or. T2_CODGRUP $ mv_par19
		
		_nA5T2Vendas += T2_VENDAS
		_nA5T2MtPrc	+= T2_MT_PRC
		_nA5T2RePrc	+= T2_RE_PRC
		_nA5T2MtVol	+= T2_MT_VOL
		_nA5T2RfPrc	+= T2_RF_PRC
		
	Endif
	
	//INCLUIDO ADRIANA  (HC) TOTALIZADOR 6 - CHAMADO 008151
	If T2_CODGRUP $ mv_par21 .or. T2_CODGRUP $ mv_par22
		
		_nA6T2Vendas += T2_VENDAS
		_nA6T2MtPrc	+= T2_MT_PRC
		_nA6T2RePrc	+= T2_RE_PRC
		_nA6T2MtVol	+= T2_MT_VOL
		_nA6T2RfPrc	+= T2_RF_PRC
		
	Endif

	dbSkip()
Enddo
*/
/*
@nLin,000 PSAY "|"
@nLin,034 PSAY "|"
@nLin,045 PSAY "|"
@nLin,127 PSAY "|"
@nLin,173 PSAY "|"
nLin++
@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par05
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA1T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|" 

//@nLin,128 PSAY _nA1T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA1T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA1T2Vendas / _nDiasUtil) - _nA1T2MtVol PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA1T2Vendas / _nDiasUtil) / _nA1T2MtVol PICTURE "@E 999.999"  //k 

@nLin,128 PSAY _nA1T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA1T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA1T2MtVol - _nA1T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA1T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA1T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"

nLin++
@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par08
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA2T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|"

//@nLin,128 PSAY _nA2T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA2T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA2T2Vendas / _nDiasUtil) - _nA2T2MtVol  PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA2T2Vendas / _nDiasUtil) / _nA2T2MtVol PICTURE "@E 999.999"  //k

@nLin,128 PSAY _nA2T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA2T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA2T2MtVol - _nA2T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA2T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA2T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"

nLin++
@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par11
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA3T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|"

//@nLin,128 PSAY _nA3T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA3T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA3T2Vendas / _nDiasUtil) - _nA3T2MtVol PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA3T2Vendas / _nDiasUtil) / _nA3T2MtVol PICTURE "@E 999.999"  //k

@nLin,128 PSAY _nA3T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA3T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA3T2MtVol - _nA3T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA3T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA3T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"
nLin++


@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par14
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA4T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|" 

//@nLin,128 PSAY _nA4T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA4T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA4T2Vendas / _nDiasUtil) - _nA4T2MtVol  PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA4T2Vendas / _nDiasUtil) / _nA4T2MtVol PICTURE "@E 999.999"  //k

@nLin,128 PSAY _nA4T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA4T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA4T2MtVol - _nA4T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA4T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA4T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"
nLin++

//INCLUIDO LEONARDO (HC) TOTALIZADOR 5

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par17
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA5T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|"

//@nLin,128 PSAY _nA5T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA5T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA5T2Vendas / _nDiasUtil) - _nA5T2MtVol  PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA5T2Vendas / _nDiasUtil) / _nA5T2MtVol PICTURE "@E 999.999"  //k

@nLin,128 PSAY _nA5T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA5T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA5T2MtVol - _nA5T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA5T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA5T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"
nLin++

//INCLUIDO ADRIANA  (HC) TOTALIZADOR 6  - CHAMADO 008151

@nLin,000 PSAY "|"
@nLin,005 PSAY mv_par20
@nLin,034 PSAY "|"
@nLin,036 PSAY _nA6T2Vendas PICTURE "@E 99999,999"   //A
@nLin,045 PSAY "|"
@nLin,127 PSAY "|"

//@nLin,128 PSAY _nA6T2MtVol PICTURE "@E 9999,999"  //H
//@nLin,141 PSAY _nA6T2Vendas / _nDiasUtil PICTURE "@E 999,999"  //I
//@nLin,152 PSAY (_nA6T2Vendas / _nDiasUtil) - _nA6T2MtVol  PICTURE "@E 9999,999"  //J
//@nLin,164 PSAY (_nA6T2Vendas / _nDiasUtil) / _nA6T2MtVol PICTURE "@E 999.999"  //k

@nLin,128 PSAY _nA6T2MtVol PICTURE "@E 9999,999"  //H
@nLin,141 PSAY (_nA6T2Vendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nA6T2MtVol - _nA6T2Vendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 9999,999"  //J
@nLin,165 PSAY ((_nA6T2Vendas / _nDiasCorr) * _nDiasUtil) / _nA6T2MtVol PICTURE "@E 99.999"  //k
@nLin,173 PSAY "|"
nLin++
*/

&&Mauricio 29/11/11.
Impttlzd()

@nLin,000 PSAY "|"+Replic("_",217)+"|"

return

/*************************************************************************************************
Static Function Quebra()
*************************************************************************************************/

Static Function Quebra(_nO)
@nLin,000 PSAY "|"
@nLin,032 PSAY "|"        //34
@nLin,056 PSAY "|"        //58
@nLin,119 PSAY "|"        //121
@nLin,139 PSAY "|"        //141
//@nLin,142 PSAY "|"
@nLin,186 PSAY "|"        //191
@nLin,218 PSAY "|"

//nLin++
cLin := ""
@nLin,000 PSAY "|"
@nLin,002 PSAY "SubTotal - Grupo"
cLin += "SubTotal; - Grupo"+";"
@nLin,032 PSAY "|"   //34
@nLin,034 PSAY _nAcumMtPrc / _nAcumVendas 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Meta   36
cLin += Transform(_nAcumMtPrc / _nAcumVendas,"@E 99.99")+";"
@nLin,041 PSAY _nAcumRePrc / _nAcumVendas 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Realizado   43
cLin += Transform(_nAcumRePrc / _nAcumVendas,"@E 99.99")+";"
If _lDiret
   @nLin,048 PSAY _nAcumRfPrc / _nAcumVendas 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Referencia  50
   cLin += Transform(_nAcumRfPrc / _nAcumVendas,"@E 99.99")+";"
Endif   
@nLin,056 PSAY "|"    //58
@nLin,057 PSAY _nAcumMtPrc 						PICTURE "@E 999,999,999" // Total "Faturamento(R$)" Meta   59
cLin += Transform(_nAcumMtPrc,"@E 999,999,999")+";"
@nLin,069 PSAY _nAcumRePrc 						PICTURE "@E 999,999,999"  // Total "Faturamento(R$)" Realizado 71
cLin += Transform(_nAcumRePrc,"@E 999,999,999")+";"
If _lDiret 
   @nLin,082 PSAY _nAcumRfPrc 						PICTURE "@E 999,999,999"  //Total "Faturamento(R$)" Referencia 84
   cLin += Transform(_nAcumRfPrc,"@E 999,999,999")+";"
Endif   
@nLin,096 PSAY _nAcumRePrc  -  	_nAcumMtPrc		PICTURE "@E 9,999,999" //Total "Diferenca Fat(R$) Real - Meta 98
cLin += Transform(_nAcumRePrc  -  	_nAcumMtPrc,"@E 9,999,999")+";"  
If _lDiret
   @nLin,107 PSAY _nAcumRePrc  -  	_nAcumRfPrc		PICTURE "@E 9,999,999"//Total "Diferenca Fat(R$) Real - Referencia 109
   cLin += Transform(_nAcumRePrc  -  	_nAcumRfPrc,"@E 9,999,999")+";"  
Endif   
@nLin,119 PSAY "|"     //121
@nLin,124 PSAY _nAcumRePrc /   	_nAcumMtPrc 	PICTURE "@E 9.999"  //Total "Indice" IPM 126
cLin += Transform(_nAcumRePrc /   	_nAcumMtPrc,"@E 9.999")+";"
If _lDiret
   &&Mauricio - 09/04/14 - Alterado formula de calculo conforme solicitações dos Srs. Marcus e Vagner
   @nLin,131 PSAY (_nAcumRePrc / _nAcumVendas) - (_nAcumRfPrc / _nAcumVendas) 	PICTURE "@E 99.999"//Total "Indice" IPR 133
   cLin += transform((_nAcumRePrc / _nAcumVendas) - (_nAcumRfPrc / _nAcumVendas),"@E 99.999")+";"  
   
   //@nLin,133 PSAY _nAcumRePrc /   	_nAcumRfPrc 	PICTURE "@E 9.999"//Total "Indice" IPR
   //cLin += transform(_nAcumRePrc /   	_nAcumRfPrc,"@E 9.999")+";"
Endif   
@nLin,139 PSAY "|"   //141
//@nLin,142 PSAY "|"
@nLin,140 PSAY _nAcumMtVol PICTURE "@E 99999,999"  //Total "Volume(Kg)" Meta 143
cLin += Transform(_nAcumMtVol,"@E 99999,999")+";"
@nLin,152 PSAY _nAcumVendas PICTURE "@E 99999,999"   // Total Volume(kgs) Realizado  155
cLin += Transform(_nAcumVendas,"@E 99999,999")+";"
@nLin,162 PSAY (_nAcumVendas / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //Total "Volume" Projetado 167
cLin += Transform((_nAcumVendas / _nDiasCorr) * _nDiasUtil,"@E 99999,999")+";"
@nLin,177 PSAY (_nAcumMtVol - _nAcumVendas) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999"  // Total "Volume" Necessaria 182
cLin += Transform((_nAcumMtVol - _nAcumVendas) / (_nDiasUtil - _nDiasCorr),"@E 99999,999")+";"
@nLin,186 PSAY "|"      //191

/*
@nLin,141 PSAY _nAcumVendas / _nDiasUtil PICTURE "@E 999,999"  //I
@nLin,152 PSAY (_nAcumVendas / _nDiasUtil) - _nAcumMtVol PICTURE "@E 999,999"  //J
@nLin,164 PSAY (_nAcumVendas / _nDiasUtil) / _nAcumMtVol PICTURE "@E 999.999"  //k
*/

@nLin,192 PSAY (_nAcumVendas / _nAcumMtVol)*100 PICTURE "@E 9999.9" //Total "Atingimento(%)" Realizado 197
cLin += Transform((_nAcumVendas / _nAcumMtVol)*100,"@E 9999.9")+";"  
//@nLin,210 PSAY ((_nAcumVendas / _nDiasCorr) * _nDiasUtil) / _nAcumVendas PICTURE "@E 999.9"  //Total "Atingimento(%)" Projetado //Alex Borges 25/11/11
@nLin,205 PSAY (((_nAcumVendas / _nDiasCorr) * _nDiasUtil) / _nAcumMtVol)*100 PICTURE "@E 9999.9"  //Total "Atingimento(%)" Projetado 210
cLin += Transform((((_nAcumVendas / _nDiasCorr) * _nDiasUtil) / _nAcumMtVol)*100,"@E 9999.9")+";"
&&Mauricio - 08/07/15 - calculo da cobertura(qtd clientes)

&&Mauricio - parei aqui - 01/07/15 - fiz o nascan abaixo e deu certo para esta quebra subtotal grupo do supervisor, porem tambem aparece no subtotal grupo do final do relatorio que eh um
&&totalizador geral. Assim para cada supervisor e total deste esta OK, porem vou precisar ajustar as demais funções(quebra2, imptotageral) e mesmo esta função Quebra() com passagem de parametro
&&para quando for totais(final do relatorio) para realizar um tratamento diferenciado quanto ao momento que estas são chamadas(Ex. quebra(1), quebra(2), sendo 1 por supervisor e 2 para os totais
&&e implementar tratamento na parte abaixo, inclusive utilizando tabela COBTOT ao inves da COBSUP e ajustar o cabecalho do relatorio...
If _nO == 1
	dBSelectArea("COBSUP")
	DbGotop()
	_nSomCli := 0
	if dbseek(_Supervis+_cQuebraTot+_cQuebraAnt)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBSUP->(!EOF()) .AND. _Supervis+_cQuebraTot+_cQuebraAnt == COBSUP->T2_SUPERVI+COBSUP->T2_QBRTOT+COBSUP->T2_QBRNVL
			_nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
			If _nAscan <= 00
				Aadd( _aCliCob, { COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
				_nSomCli ++
			Endif
			COBSUP->(dbSkip())
		Enddo
	Endif
Else
	dBSelectArea("COBTOT")
	DbGotop()
	_nSomCli := 0
	if dbseek(_cQuebraTot+_cQuebraAnt)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBTOT->(!EOF()) .AND. _cQuebraTot+_cQuebraAnt == COBTOT->T2_QBRTOT+COBTOT->T2_QBRNVL
			_nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
			If _nAscan <= 00
				Aadd( _aCliCob, { COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
				_nSomCli ++
			Endif
			COBTOT->(dbSkip())
		Enddo
	Endif
Endif

DbSelectArea("TEM2")
@nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
cLin += Transform(_nSomCli,"@E 9999" )+_eof
&&fim 01/07/15
fWrite(nHdl,cLin,Len(cLin)) 
@nLin,218 PSAY "|"

nLin++
@nLin,000 PSAY "|"
@nLin,032 PSAY "|"   //34
@nLin,056 PSAY "|"   //58
@nLin,119 PSAY "|"   //121
@nLin,139 PSAY "|"   //141
//@nLin,142 PSAY "|"
@nLin,218 PSAY "|"
nLin++
_nAcumVendas:=	0
_nAcumMtPrc	:=	0
_nAcumRePrc	:=	0
_nAcumMtVol	:=	0
_nAcumRfPrc	:=	0
return

/*************************************************************************************************
Static Function Quebra2()       Mauricio 19/10/11.
*************************************************************************************************/

Static Function Quebra2(_nO)

_nMeta :=  _nAcMtPrcT / _nAcVdT
_nRealiz := _nAcRePrcT / _nAcVdT
_nReferen := _nAcRfPrcT / _nAcVdT

_nAcMeta := _nAcMtPrcT
_nAcReal := _nAcRePrcT
_nAcRefer := _nAcRfPrcT
_nDifMet := _nAcRePrcT  -  _nAcMtPrcT
_nDifRef := _nAcRePrcT  -  _nAcRfPrcT

_nIPM := _nAcRePrcT /   _nAcMtPrcT
_nIPR := _nAcRePrcT /   _nAcRfPrcT

_nVolMet := _nAcMtVolT
_nVolRea := _nAcVdT
  
// "Volume(kg)" Projetado
_nVolProj := (_nAcVdT / _nDiasCorr) * _nDiasUtil
//"Volume(kg)" Necessaria
_nVolNec := (_nAcMtVolT - _nAcVdT) / (_nDiasUtil - _nDiasCorr)
//"Atingimento(%)" REalizado
_nAtgRea := (_nAcVdT / _nAcMtVolT) * 100  
//"Atingimento(%)" Projetado
_nAtgPrj := (((_nAcVdT / _nDiasCorr) * _nDiasUtil) / _nAcMtVolT) * 100 

&&Mauricio 29/11/11 - totaliza para o supervisor
AADD(_aTotaliz,{_cAgrupadores,_nMeta,_nRealiz,_nReferen,_nAcMeta,_nAcReal,_nAcRefer,_nDifMet,_nDifRef,_nIPM,_nIPR,_nVolMet,_nVolRea,_nVolProj,_nVolNec,;
    _nAtgRea,_nAtgPrj})
                
&&totalizador geral Mauricio 21/10/11.
_nAcVdTT    +=  _nAcVdt
_nAcMPrcTT  +=  _nAcMtPrcT
_nAcRPrcTT  +=  _nAcRePrcT
_nAcMVolTT  +=  _nAcMtVolT
_nDiasUtTT  := _nDiasUtil
_nAcFPrcTT  +=  _nAcRfPrcT
                          
_nAcVdT     :=	0
_nAcMtPrcT	:=	0
_nAcRePrcT	:=	0
_nAcMtVolT	:=	0 
_nAcRfPrcT	:=	0
_cAgrupadores := ""
return 

Static Function TotGer(_nO)                            

//nLin++
cLin := ""
@nLin,000 PSAY "|"
@nLin,002 PSAY "Totaliz.Geral"
cLin += ";Totaliz.Geral;"                 
@nLin,032 PSAY "|"
@nLin,034 PSAY _nAcMPrcTT / _nAcVdTT		PICTURE "@E 99.99"  //"Preco Fob(R$/KG)" Meta
cLin += Transform(_nAcMPrcTT / _nAcVdTT,"@E 99.99")+";" 
@nLin,041 PSAY _nAcRPrcTT  / _nAcVdTT 		PICTURE "@E 99.99"  //"Preco Fob(R$/KG)" Realizado
cLin += Transform(_nAcRPrcTT  / _nAcVdTT,"@E 99.99")+";" 
If _lDiret
   @nLin,048 PSAY  _nAcFPrcTT  / _nAcVdTT 		PICTURE "@E 99.99" //""Preco Fob(R$/KG)" Referencial
   cLin += Transform(_nAcFPrcTT  / _nAcVdTT,"@E 99.99")+";" 
Endif   
@nLin,056 PSAY "|"
@nLin,057 PSAY _nAcMPrcTT 						PICTURE "@E 999,999,999" //"Faturamento(R$)" Meta
cLin += Transform(_nAcMPrcTT,"@E 999,999,999")+";" 
@nLin,069 PSAY _nAcRPrcTT 						PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
cLin += Transform(_nAcRPrcTT,"@E 999,999,999")+";"  
If _lDiret
   @nLin,082 PSAY  _nAcFPrcTT 						PICTURE "@E 999,999,999" //"Faturamento(R$)" Referencial
   cLin += Transform(_nAcFPrcTT,"@E 999,999,999")+";"
Endif   
@nLin,096 PSAY _nAcRPrcTT  -  _nAcMPrcTT		PICTURE "@E 9,999,999" //"Diferenca Fat(R$)" Real - Meta
cLin += Transform(_nAcRPrcTT  -  _nAcMPrcTT,"@E 9,999,999")+";"
If _lDiret
   @nLin,107 PSAY _nAcRPrcTT - _nAcFPrcTT  		PICTURE "@E 9,999,999" //"Diferenca Fat(R$)" Real - Referencial
   cLin += Transform(_nAcRPrcTT - _nAcFPrcTT,"@E 9,999,999")+";" 
Endif   
@nLin,119 PSAY "|"
@nLin,124 PSAY _nAcRPrcTT /   _nAcMPrcTT 	PICTURE "@E 9.999"  //"Indice" IPM
cLin += Transform(_nAcRPrcTT /   _nAcMPrcTT,"@E 9.999")+";" 
If _lDiret
   &&Mauricio - 09/04/14 - alteração na formula de calculo conforme solicitações dos Srs. Marcos e vagner.
   @nLin,131 PSAY (_nAcRPrcTT  / _nAcVdTT) - (_nAcFPrcTT  / _nAcVdTT) 	PICTURE "@E 99.999"//"Indice" IPR
   cLin += Transform((_nAcRPrcTT  / _nAcVdTT) - (_nAcFPrcTT  / _nAcVdTT), "@E 99.999")+";" 

   //@nLin,133 PSAY _nAcFPrcTT /   _nAcMPrcTT 	PICTURE "@E 99.999"//"Indice" IPR         ALEX BORGES 16/12/2011
   //@nLin,133 PSAY _nAcRPrcTT /   _nAcFPrcTT 	PICTURE "@E 99.999"//"Indice" IPR
   //cLin += Transform(_nAcRPrcTT /   _nAcFPrcTT, "@E 99.999")+";" 
Endif   
@nLin,139 PSAY "|"
//@nLin,142 PSAY "|"
@nLin,140 PSAY _nAcMVolTT PICTURE "@E 99999,999"  //"Volume(KG)" Meta
cLin += Transform(_nAcMVolTT, "@E 99999,999")+";"  
@nLin,152 PSAY _nAcVdTT PICTURE "@E 99999,999"   //"Volume(kg)" Realizado
cLin += Transform(_nAcVdTT, "@E 99999,999")+";" 
@nLin,162 PSAY (_nAcVdTT / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //"Volume(kg)" Projetado
cLin += Transform((_nAcVdTT / _nDiasCorr) * _nDiasUtil, "@E 99999,999")+";" 
@nLin,177 PSAY (_nAcMVolTT - _nAcVdTT) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999"   //"Volume(kg)" Necessaria 
cLin += Transform((_nAcMVolTT - _nAcVdTT) / (_nDiasUtil - _nDiasCorr), "@E 99999,999")+";" 
@nLin,186 PSAY "|"
@nLin,192 PSAY (_nAcVdTT / _nAcMVolTT)*100 PICTURE "@E 9999.9" //"Atingimento(%)" Realizado
cLin += Transform((_nAcVdTT / _nAcMVolTT)*100, "@E 9999.9")+";" 
//@nLin,210 PSAY ((_nAcVdTT / _nDiasCorr) * _nDiasUtil)/ _nAcVdTT PICTURE "@E 9.999"  //"Atingimento(%)" Projetado  //Alex Borges 25/11/11
@nLin,205 PSAY (((_nAcVdTT / _nDiasCorr) * _nDiasUtil)/ _nAcMVolTT)*100 PICTURE "@E 9999.9"  //"Atingimento(%)" Projetado
cLin += Transform((((_nAcVdTT / _nDiasCorr) * _nDiasUtil)/ _nAcMVolTT)*100, "@E 9999.9")+";"
If _nO == 1
	dBSelectArea("COBSUP")
	DbGotop()
	_nSomCli := 0
	if dbseek(_Supervis)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBSUP->(!EOF()) .AND. _Supervis == COBSUP->T2_SUPERVI
			_nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
			If _nAscan <= 00
				Aadd( _aCliCob, { COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
				_nSomCli ++
			Endif
			COBSUP->(dbSkip())
		Enddo
	Endif
Else
	dBSelectArea("COBTOT")
	DbGotop()
	_nSomCli := 0
	//if dbseek(_cQuebraTot+_cQuebraAnt)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBTOT->(!EOF()) //.AND. _cQuebraTot+_cQuebraAnt == COBTOT->T2_QBRTOT+COBTOT->T2_QBRNVL
			_nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
			If _nAscan <= 00
				Aadd( _aCliCob, { COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
				_nSomCli ++
			Endif
			COBTOT->(dbSkip())
		Enddo
	//Endif
Endif
DbSelectArea("TEM2")
@nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
cLin += Transform(_nSomCli,"@E 9999" )+_eof
fWrite(nHdl,cLin,Len(cLin))
@nLin,218 PSAY "|" 
                         
nLin++
@nLin,000 PSAY "|"
@nLin,032 PSAY "|"
@nLin,056 PSAY "|"
@nLin,119 PSAY "|"
@nLin,139 PSAY "|"
//@nLin,142 PSAY "|"
@nLin,186 PSAY "|"
@nLin,218 PSAY "|"
nLin++
&&totalizador geral Mauricio 21/10/11.
_nAcVdTT    :=	0
_nAcMPrcTT  :=	0
_nAcRPrcTT  :=	0
_nAcMVolTT  :=	0
_nAcFPrcTT  :=	0
//_nDiasUtTT  := _nDiasUtil
                          
_nAcVdT     :=	0
_nAcMtPrcT	:=	0
_nAcRePrcT	:=	0
_nAcMtVolT	:=	0
_nAcRfPrcT	:=	0
  
return

/*************************************************************************************************
Static Function ImpTotGeral()
*************************************************************************************************/

Static Function ImpTotGeral()

_cQuebra:=""
_cCod	:=""
_aCodGrup:={}
_aQbr:={}
_bE:=0

DbSelectArea("TEM2")
//cIndex   := "T2_QBRNVL + T2_CODGRUP"
cIndex   := "T2_QBRTOT + T2_QBRNVL + T2_CODGRUP"    &&Mauricio 19/10/11.
IndRegua( "TEM2", _cNomTr2, cIndex,,,"Criando Indice ..." )
DbGoTop()
//====================================//
_Supervis:= TEM2->T2_SUPERVI
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 5
ImpCabec2(_cAcumMetaCli)

_cQuebraAnt:=	TEM2->T2_QBRNVL
_cQuebraGrp	:=	TEM2->T2_CODGRUP
_cQuebraTot	:=	TEM2->T2_QBRTOT        &&Mauricio 19/10/11.
_anNOMGRUP	:=	TEM2->T2_NOMGRUP
_acVendas	:=	0
_acMT_PRC	:=	0
_acRE_prc	:=	0
_acMT_VOL	:=	0
_acMT_FaR	:=	0
_acVendasT	:=	0
_acMT_PRCT	:=	0
_acRE_prcT	:=	0
_acMT_VOLT	:=	0
_acMT_FaRT	:=	0 
_acRF_prc	:=	0
_acRF_prcT	:=	0
_acRF_FaR	:=	0
_acRF_FaRT	:=	0 

DO WHILE !EOF()
	
	If nLin > 55   //60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 5
		ImpCabec2(_cAcumMetaCli)
	Endif 
	If	_cQuebraGrp	!=	TEM2->T2_CODGRUP
	    cLin := ""
		@nLin,000 PSAY "|" + _cQuebraAnt+_cQuebraTot
		@nLin,004 PSAY _cQuebraGrp
		@nLin,010 PSAY SUBSTR(_anNOMGRUP,1,20)
		cLin += _cQuebraAnt+_cQuebraTot+";"+_cQuebraGrp+" "+SUBSTR(_anNOMGRUP,1,20)+";"
		@nLin,032 PSAY "|"
		@nLin,034 PSAY _acMT_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Meta
		cLin += Transform(_acMT_PRC,"@E 99.99")+";"
		@nLin,041 PSAY _acRE_PRC / _acVENDAS PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Realizado
		cLin += Transform(_acRE_PRC / _acVENDAS,"@E 99.99")+";"
		If _lDiret
		   //@nLin,050 PSAY _acRF_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Referencial   ALEX BORGES 12/12/11
		   @nLin,048 PSAY _acRF_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Referencial
		   cLin += Transform(_acRF_PRC,"@E 99.99")+";"
		Endif   
		@nLin,056 PSAY "|"

		//		@nLin,070 PSAY _acVENDAS *  _acMT_PRC PICTURE "@E 99,999,999.99" //D_acMT_FaR
		@nLin,057 PSAY _acMT_FaR PICTURE "@E 999,999,999" //"Faturamento(R$)" Meta
		cLin += Transform(_acMT_FaR,"@E 999,999,999")+";"
		@nLin,069 PSAY _acRE_PRC PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
		cLin += Transform(_acRE_PRC,"@E 999,999,999")+";"
		If _lDiret
		   @nLin,082 PSAY _acRF_FAR PICTURE "@E 999,999,999"// "Faturamento(R$)" Referencial_acRF_PRC
		   cLin += Transform(_acRF_FAR,"@E 999,999,999")+";"
		Endif   
		@nLin,096 PSAY _acRE_PRC  - _acMT_FaR	PICTURE "@E 99,999,999" //"Diferenca Fat(R$)" Real - Meta
		cLin += Transform(_acRE_PRC  - _acMT_FaR,"@E 99,999,999" )+";"
		If _lDiret
		   @nLin,107 PSAY _acRE_PRC - _acRF_FAR PICTURE "@E 99,999,999"//"Diferenca Fat(R$)" Real - Referencial _acRF_PRC
		   cLin += Transform(_acRE_PRC - _acRF_FAR,"@E 99,999,999" )+";"
		Endif   
		@nLin,119 PSAY "|"
		@nLin,124 PSAY _acRE_PRC / _acMT_FaR PICTURE "@E 9.999"  //"indice" IPM
		cLin += Transform(_acRE_PRC / _acMT_FaR,"@E 9.999" )+";"
		If _lDiret
		   &&Mauricio - 09/04/14 - alteração na formula de calculo conforme solicitação dos Srs. Marcus e Vagner
		   @nLin,131 PSAY (_acRE_PRC / _acVENDAS) - _acRF_PRC PICTURE "@E 99.999"  // "indice" IPR
		   cLin += Transform((_acRE_PRC / _acVENDAS) - _acRF_PRC ,"@E 99.999" )+";"
		
		   //@nLin,133 PSAY _acRE_PRC / _acRF_FAR PICTURE "@E 99.999"  // "indice" IPR
		   //cLin += Transform(_acRE_PRC / _acRF_FAR,"@E 99.999" )+";"
		Endif   
		@nLin,139 PSAY "|"
		//@nLin,142 PSAY "|"
		@nLin,140 PSAY _acMT_VOL PICTURE "@E 99999,999"  //"Volume(kg)" Meta
		cLin += Transform(_acMT_VOL,"@E 99999,999" )+";"
		/*
		@nLin,141 PSAY _acVENDAS / _nDiasUtil PICTURE "@E 999,999"  //I
		@nLin,152 PSAY (_acVENDAS / _nDiasUtil) - _acMT_VOL  PICTURE "@E 999,999"  //J
		@nLin,165 PSAY (_acVENDAS / _nDiasUtil) / _acMT_VOL PICTURE "@E 99.999"  //k
		*/
        @nLin,152 PSAY _acVENDAS PICTURE "@E 99999,999"   //"Volume(kg)" Realizado
        cLin += Transform(_acVENDAS,"@E 99999,999" )+";"
        @nLin,162 PSAY (_acVENDAS / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //"Volume(kg" Projetado
        cLin += Transform((_acVENDAS / _nDiasCorr) * _nDiasUtil ,"@E 999,999")+";"
		@nLin,177 PSAY (_acMT_VOL - _acVENDAS) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999" //"Volume(KG)" Necessaria
		cLin += Transform((_acMT_VOL - _acVENDAS) / (_nDiasUtil - _nDiasCorr) ,"@E 99999,999")+";"
	   	@nLin,186 PSAY "|"
	   	@nLin,192 PSAY (_acVENDAS / _acMT_VOL)*100 PICTURE "@E 999.9"// "Atingimento(%)" Realizado
	   	cLin += Transform((_acVENDAS / _acMT_VOL)*100 ,"@E 999.9")+";"
		//@nLin,210 PSAY ((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acVENDAS PICTURE "@E 999.9"  // "Atingimento(%)" Projetado  //Alex Borges 25/11/11		
		@nLin,205 PSAY (((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acMT_VOL)*100 PICTURE "@E 999.9"  // "Atingimento(%)" Projetado		
		cLin += Transform((((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acMT_VOL)*100  ,"@E 999.9")+";"
		dBSelectArea("COBTOT")
	    DbGotop()
	    _nSomCli := 0
	    if dbseek(_cQuebraTot+_cQuebraAnt+_cQuebraGrp)
		   _aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		   WHILE COBTOT->(!EOF()) .AND. _cQuebraTot+_cQuebraAnt+_cQuebraGrp == COBTOT->T2_QBRTOT+COBTOT->T2_QBRNVL+COBTOT->T2_CODGRUP
			     _nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
			     If _nAscan <= 00
				    Aadd( _aCliCob, { COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
				    _nSomCli ++
			     Endif
			     COBTOT->(dbSkip())
		   Enddo
	    Endif
	    DbSelectArea("TEM2")
        @nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
        cLin += Transform(_nSomCli,"@E 9999" )+_eof
		
		fWrite(nHdl,cLin,Len(cLin))
		@nLin,218 PSAY "|"
		nLin++
		_nAcumMtPrc	+=	_acMT_FaR
		_nAcumRePrc	+=	_acRE_prc
		_nAcumRfPrc	+=	_acRF_Far //_acRF_prc Mauricio hoje
		_nAcMtPrcT  +=  _acMT_FaR  &&Mauricio 19/10/11 totalizadores
		_nAcRePrcT  +=  _acRE_prc  &&Mauricio 19/10/11 totalizadores
		_nAcRfPrcT  +=  _acRF_Far  //_acRF_prc  MAuricio 14/12/11.  &&Mauricio 19/10/11 totalizadores
		_acVendas	:=	0
		_acMT_PRC	:=	0
		_acRE_prc	:=	0
		_acMT_VOL	:=	0
		_acMT_FaR	:=	0
		_acRF_FaR	:=	0
		_acRF_prc	:=	0
		&&Mauricio 19/10/11 totalizadores
		_acVendasT	:=	0
		_acMT_PRCT	:=	0
		_acRE_prcT	:=	0
		_acMT_VOLT	:=	0
		_acMT_FaRT	:=	0
		_acRF_FaRT	:=	0
		_acRF_prcT	:=	0
				
		_cQuebraGrp	:=	TEM2->T2_CODGRUP
		_anNOMGRUP	:=	TEM2->T2_NOMGRUP
		//_cQuebraTot	:=	TEM2->T2_QBRTOT        &&Mauricio 19/10/11.
	Endif
	If _cQuebraAnt	!=	TEM2->T2_QBRNVL
		Quebra(2)
		_cQuebraAnt :=	TEM2->T2_QBRNVL
		//_cQuebraTot	:=	TEM2->T2_QBRTOT        &&Mauricio 19/10/11.
	Endif
	If _cQuebraTot	!=	TEM2->T2_QBRTOT        &&Mauricio 19/10/11 totalizadores.	    
		Quebra2(2)
		_cQuebraTot	:=	TEM2->T2_QBRTOT
	Endif
	if !(ALLTRIM(TEM2->T2_QBRNVL) $ _cAgrupadores)
   		If empty(_cAgrupadores)
   			_cAgrupadores := _cAgrupadores + TEM2->T2_QBRNVL  	
   		Else
   			_cAgrupadores := _cAgrupadores +"+"+ TEM2->T2_QBRNVL  
   		EndIF		  
   	EndIF
	
	_acVendas	+=	TEM2->T2_VENDAS		//A
	_acMT_FaR	+= 	iif(TEM2->T2_VENDAS=0,TEM2->T2_MT_PRC,TEM2->T2_MT_PRC * TEM2->T2_VENDAS) //D
	_acRE_prc	+=	TEM2->T2_RE_PRC		//E
	_acMT_VOL	+=	TEM2->T2_MT_VOL		//H
	_acMT_PRC	:= iif(_acVendas=0,_acMT_FaR/_nContaSup,_acMT_FaR / _acVendas) 	//B 
	_acRF_FaR	+= 	TEM2->T2_RF_PRC * TEM2->T2_VENDAS
	_acRF_prc	:=	_acRF_FaR / _acVendas 	   &&mAURICIO 09/12/11 - _acRF_prc	+=	TEM2->T2_RF_PRC
	_nAcumVendas+=	T2_VENDAS			   		//A
	_nAcumMtVol	+=	T2_MT_VOL					//H 
	
	&&Mauricio 19/10/11 totalizadores.
	_acVendasT	+=	TEM2->T2_VENDAS		//A
	_acMT_FaRT	+= 	TEM2->T2_MT_PRC * TEM2->T2_VENDAS //D
	_acRE_prcT	+=	TEM2->T2_RE_PRC		//E
	_acMT_VOLT	+=	TEM2->T2_MT_VOL		//H
	_acMT_PRCT	:=	_acMT_FaRT / _acVendasT 	//B 
	_acRF_FaRT	+= 	TEM2->T2_RF_PRC * TEM2->T2_VENDAS
	_acRF_prcT	:=	_acRF_FaRT  / _acVendasT   &&_acRF_prcT	+=	TEM2->T2_RF_PRC  mAURICIO 09/12/11
		
	
	_nAcVdT     +=	T2_VENDAS			   		//A
	_nAcMtVolT	+=	T2_MT_VOL					//H 
	
	dbSelectArea("TEM2")
	DbSkip()
	
Enddo
cLin := ""
@nLin,000 PSAY "|" + _cQuebraAnt + _cQuebraTot
@nLin,004 PSAY _cQuebraGrp
@nLin,010 PSAY SUBSTR(_anNOMGRUP,1,20)
cLin += _cQuebraAnt+_cQuebraTot+";"+_cQuebraGrp+" "+SUBSTR(_anNOMGRUP,1,20)+";"
@nLin,032 PSAY "|" 
@nLin,034 PSAY _acMT_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Meta
cLin += Transform(_acMT_PRC,"@E 99.99")+";"
		@nLin,041 PSAY _acRE_PRC / _acVENDAS PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Realizado
		cLin += Transform(_acRE_PRC / _acVENDAS,"@E 99.99")+";"
		If _lDiret
		   //@nLin,050 PSAY _acRF_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Referencial   ALEX BORGES 12/12/11
		   @nLin,048 PSAY _acRF_PRC PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Referencial
		   cLin += Transform(_acRF_PRC,"@E 99.99")+";"
		Endif   
		@nLin,056 PSAY "|"

		//		@nLin,070 PSAY _acVENDAS *  _acMT_PRC PICTURE "@E 99,999,999.99" //D_acMT_FaR
		@nLin,057 PSAY _acMT_FaR PICTURE "@E 999,999,999" //"Faturamento(R$)" Meta
		cLin += Transform(_acMT_FaR,"@E 999,999,999")+";"
		@nLin,069 PSAY _acRE_PRC PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
		cLin += Transform(_acRE_PRC,"@E 999,999,999")+";"
		If _lDiret
		   @nLin,082 PSAY _acRF_FAR PICTURE "@E 999,999,999"// "Faturamento(R$)" Referencial_acRF_PRC
		   cLin += Transform(_acRF_FAR,"@E 999,999,999")+";"
		Endif   
		@nLin,096 PSAY _acRE_PRC  - _acMT_FaR	PICTURE "@E 99,999,999" //"Diferenca Fat(R$)" Real - Meta
		cLin += Transform(_acRE_PRC  - _acMT_FaR,"@E 99,999,999")+";"
		If _lDiret
		   @nLin,107 PSAY _acRE_PRC - _acRF_FAR PICTURE "@E 99,999,999"//"Diferenca Fat(R$)" Real - Referencial _acRF_PRC
		   cLin += Transform(_acRE_PRC - _acRF_FAR,"@E 99,999,999")+";"
		Endif   
		@nLin,119 PSAY "|"
		@nLin,124 PSAY _acRE_PRC / _acMT_FaR PICTURE "@E 9.999"  //"indice" IPM
     	cLin += Transform(_acRE_PRC / _acMT_FaR,"@E 9.999")+";"
		If _lDiret
		   &&Mauricio - 09/04/14 - alteração formula de calculo conforme solicitação Srs. Marcus e Vagner
		   @nLin,131 PSAY (_acRE_PRC / _acVENDAS) - _acRF_PRC PICTURE "@E 99.999"  // "indice" IPR 
		   cLin += Transform((_acRE_PRC / _acVENDAS) - _acRF_PRC,"@E 99.999")+";"
		
		   //@nLin,133 PSAY _acRE_PRC / _acRF_FAR PICTURE "@E 99.999"  // "indice" IPR 
		   //cLin += Transform(_acRE_PRC / _acRF_FAR,"@E 99.999")+";"
		Endif   
		@nLin,139 PSAY "|"
		//@nLin,142 PSAY "|"
		@nLin,140 PSAY _acMT_VOL PICTURE "@E 99999,999"  //"Volume(kg)" Meta
		cLin += Transform(_acMT_VOL,"@E 99999,999")+";"
		/*
		@nLin,141 PSAY _acVENDAS / _nDiasUtil PICTURE "@E 999,999"  //I
		@nLin,152 PSAY (_acVENDAS / _nDiasUtil) - _acMT_VOL  PICTURE "@E 999,999"  //J
		@nLin,165 PSAY (_acVENDAS / _nDiasUtil) / _acMT_VOL PICTURE "@E 99.999"  //k
		*/
        @nLin,152 PSAY _acVENDAS PICTURE "@E 99999,999"   //"Volume(kg)" Realizado
        cLin += Transform(_acVENDAS,"@E 99999,999")+";"
        @nLin,162 PSAY (_acVENDAS / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //"Volume(kg" Projetado
        cLin += Transform((_acVENDAS / _nDiasCorr) * _nDiasUtil,"@E 999,999")+";"
		@nLin,177 PSAY (_acMT_VOL - _acVENDAS) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999" //"Volume(KG)" Necessaria
		cLin += Transform((_acMT_VOL - _acVENDAS) / (_nDiasUtil - _nDiasCorr),"@E 99999,999")+";"
	   	@nLin,186 PSAY "|"
	   	@nLin,192 PSAY (_acVENDAS / _acMT_VOL)*100 PICTURE "@E 999.9"// "Atingimento(%)" Realizado
	   	cLin += Transform((_acVENDAS / _acMT_VOL)*100,"@E 999.9")+";"
		//@nLin,210 PSAY ((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acVENDAS PICTURE "@E 999.9"  // "Atingimento(%)" Projetado  //Alex Borges 25/11/11		
		@nLin,205 PSAY (((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acMT_VOL)*100 PICTURE "@E 999.9"  // "Atingimento(%)" Projetado
		cLin += Transform((((_acVENDAS / _nDiasCorr) * _nDiasUtil) / _acMT_VOL)*100 ,"@E 999.9")+";"
		dBSelectArea("COBTOT")
	    DbGotop()
	    _nSomCli := 0
	    if dbseek(_cQuebraTot+_cQuebraAnt)
		   _aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		   WHILE COBTOT->(!EOF()) .AND. _cQuebraTot+_cQuebraAnt == COBTOT->T2_QBRTOT+COBTOT->T2_QBRNVL
			     _nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
			     If _nAscan <= 00
				    Aadd( _aCliCob, { COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
				    _nSomCli ++
			     Endif
			     COBTOT->(dbSkip())
		   Enddo
	    Endif
	    DbSelectArea("TEM2")
        @nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
        cLin += Transform(_nSomCli,"@E 9999" )+_eof
        fWrite(nHdl,cLin,Len(cLin)) 		

@nLin,218 PSAY "|"
nLin++
_nAcumMtPrc	+=	_acMT_FaR
_nAcumRePrc	+=	_acRE_prc
_nAcumRfPrc	+=	_acRF_Far  //_acRF_prc MAuricio Hoje

&&Mauricio 19/10/11 totalizadores.
_nAcMtPrcT	+=	_acMT_FaRT
_nAcRePrcT	+=	_acRE_prcT
_nAcRfPrcT	+=	_acRF_FaRT   //_acRF_prcT  Mauricio Hoje

Quebra(2)
Quebra2(2)       &&Mauricio 19/10/11 totalizadores.
TotGer(2)        &&Mauricio 21/10/11 
ImpTotais2(2)

nLin := nLin + 1
nLin := 56  //61
//************************//

return




//*-----------------------------------------------------*
Static Function ValidPerg
// Por Hc Consys - 10/02/2009
//*-----------------------------------------------------*
PutSX1(cPerg,"01","Data de Entrega de ","Data de Entrega de ","Data de Entrega de ","mv_ch1","D",8,0,0,"G","","   ","","","mv_par01" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"02","Data de Entrega ate","Data de Entrega ate","Data de Entrega ate","mv_ch2","D",8,0,0,"G","","   ","","","mv_par02" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"03","Do Supervisor      ","Do Supervisor      ","Do Supervisor      ","mv_ch3","C",6,0,0,"G","","A06","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"04","Ate Supervisor     ","Ate Supervisor     ","Ate Supervisor     ","mv_ch4","C",6,0,0,"G","","A06","","","mv_par04" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
/*
PutSX1(cPerg,"05","Grupo 1-Totalizador ","Grupo 1-Totalizador ","Grupo 1-Totalizador ","mv_ch5","C",15,0,0,"G","","   ","","","mv_par05" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"06","Grupo 1-Sub-Grupos  ","Grupo 1-Sub-Grupos  ","Grupo 1-Sub-Grupos  ","mv_ch6","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par06" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"07","Cont->1-Sub-Grupos  ","Cont->1-Sub-Grupos  ","Cont->1-Sub-Grupos  ","mv_ch7","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par07" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"08","Grupo 2-Totalizador ","Grupo 2-Totalizador ","Grupo 2-Totalizador ","mv_ch8","C",15,0,0,"G","","   ","","","mv_par08" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"09","Grupo 2-Sub-Grupos  ","Grupo 2-Sub-Grupos  ","Grupo 2-Sub-Grupos  ","mv_ch9","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par09" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"10","Cont->2-Sub-Grupos  ","Cont->2-Sub-Grupos  ","Cont->2-Sub-Grupos  ","mv_cha","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par10" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"11","Grupo 3-Totalizador ","Grupo 3-Totalizador ","Grupo 3-Totalizador ","mv_chb","C",15,0,0,"G","","   ","","","mv_par11" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"12","Grupo 3-Sub-Grupos  ","Grupo 3-Sub-Grupos  ","Grupo 3-Sub-Grupos  ","mv_chc","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par12" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"13","Cont->3-Sub-Grupos  ","Cont->3-Sub-Grupos  ","Cont->3-Sub-Grupos  ","mv_chd","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par13" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"14","Grupo 4-Totalizador ","Grupo 4-Totalizador ","Grupo 4-Totalizador ","mv_che","C",15,0,0,"G","","   ","","","mv_par14" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"15","Grupo 4-Sub-Grupos  ","Grupo 4-Sub-Grupos  ","Grupo 4-Sub-Grupos  ","mv_chf","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par15" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"16","Cont->4-Sub-Grupos  ","Cont->4-Sub-Grupos  ","Cont->4-Sub-Grupos  ","mv_chg","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par16" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"17","Grupo 5-Totalizador ","Grupo 5-Totalizador ","Grupo 5-Totalizador ","mv_chh","C",15,0,0,"G","","   ","","","mv_par17" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"18","Grupo 5-Sub-Grupos  ","Grupo 5-Sub-Grupos  ","Grupo 5-Sub-Grupos  ","mv_chi","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par18" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"19","Cont->5-Sub-Grupos  ","Cont->5-Sub-Grupos  ","Cont->5-Sub-Grupos  ","mv_chj","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par19" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

//Incluido por Adriana para atender o chamado 008151
PutSX1(cPerg,"20","Grupo 6-Totalizador ","Grupo 6-Totalizador ","Grupo 6-Totalizador ","mv_chk","C",15,0,0,"G","","   ","","","mv_par20" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"21","Grupo 6-Sub-Grupos  ","Grupo 6-Sub-Grupos  ","Grupo 6-Sub-Grupos  ","mv_chl","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par21" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"22","Cont->6-Sub-Grupos  ","Cont->6-Sub-Grupos  ","Cont->6-Sub-Grupos  ","mv_chm","C",99,0,0,"G","U_ADGRUPO()","","","","mv_par22" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")

PutSX1(cPerg,"23","Seg. Dias Uteis de?","Seg. Dias Uteis de?","Seg. Dias Uteis de?","mv_chn","C",3,0,0,"G","","SZN","","","mv_par23" ,"    "          ," "," ","","    "         ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"24","Seg. Dias Uteis ate","Seg. Dias Uteis ate","Seg. Dias Uteis ate","mv_cho","C",3,0,0,"G","","SZN","","","mv_par24" ,"    "          ," "," ","","    "         ,"","",     "","","","","","","",""," ")
*/
PutSx1(cPerg,"05","Seleciona filiais"  ,"Seleciona filiais"  ,"Seleciona filiais"  ,"mv_ch5","C",50,0,0,"G","U_FXFIL()","","","","mv_par05","","","","","","","","","","","","","","","","","","","")
&& Seleciona Filiais - Mauricio Chamado 006243.

PutSx1(cPerg,"06","Nr.dias Uteis meta"  ,"Nr.dias Uteis meta"  ,"Nr.dias Uteis meta"  ,"mv_ch6","N",2,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","","","","")

PutSx1(cPerg,"07","Nr.dias corridos"    ,"Nr.dias corridos"  ,"Nr.dias corridos"        ,"mv_ch7","N",2,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","","","","")
&&Mauricio 29/11/11 - acrescentado valor limite
PutSx1(cPerg,"08","Valor limite 1"    ,"Valor limite 1"  ,"Valor limite 1"        ,"mv_ch8","N",12,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","","","","")
&&Mauricio 30/11/11 - acrescentado valor limite 2
PutSx1(cPerg,"09","Valor limite 2"    ,"Valor limite 2"  ,"Valor limite 2"        ,"mv_ch9","N",12,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","","","","")
// ALEX BORGES 06/12/11 INSERIDO PARAMETRO DE PERIODO DA META"                       
PutSx1(cPerg,"10","Data Meta Inicio"    ,"Data Meta Inicio"  ,"Data Meta Inicio"        ,"mv_ch10","D",8,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"11","Data Meta Inicio"    ,"Data Meta Inicio"  ,"Data Meta Inicio"        ,"mv_ch11","D",8,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","","","","")

Return 

static function fbuscafrt(_cF,_cPedido)
&&Mauricio 26/10/11 - Ver com Alex se ao inves desta função não da para passar na aprovação de pedidos o valor do frete para um campo do sistema...
&&e ai pegar desse campo o valor...
Local _cPedido
Local _cF
Local _nFrete := 0

DbSelectArea("SC5")
DbSetOrder(1)
if dbSeek(_cF+_cPedido)
      if (ALLTRIM(SC5->C5_TPFRETE) = "C")    // ALEX BORGES    16/12/11    Para considerar frete caso o pedido for CIF
      		_nFrete := SC5->C5_FRETAPV
      Else
       		_nFrete := 0
      End If
      
Endif   

&&substituido pelo tratameno acima(criado campo SC5) Mauricio 16/11/11.
/*
If empty(_cRede) &&varejo
   // Busco frete para Cliente
   _cRegiao := ""   
				
   // Localizo o municipio do cliente, se este for loja
   If !Empty(_cMunic)
      _cRegiao:= Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA") // Localizo a regiao do cliente
   EndIf
				
   If !Empty(_cRegiao)
       _nFrete := Posicione('ZZI',1,xFilial("ZZI")+_cRegiao,"ZZI_VALOR")         // Valor do frete para a região
   Else
       dbSelectArea("ZZI")                                                       // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
	   dbSetOrder(3)
	   dbSeek(xFilial("ZZI")+_cEst)				
       While !Eof() .And. ZZI->ZZI_ESTADO == _cEst						
             If _nFrete < ZZI->ZZI_VALOR
				_nFrete := ZZI->ZZI_VALOR
			 EndIf
			 ZZI->(dbSkip())						
             EndDo
   EndIf
Else  &&Rede
      dbSelectArea("SA1")
	  dbSetOrder(1)
	  dbSeek(xFilial("SA1")+_cRede)			
	  // Busco frete para Cliente
	  _nFrete := 0
	  _cRegiao := ""			
      If !Empty(_cMunic)
	     _cRegiao:= Posicione('CC2',1,xFilial("CC2")+_cEst+_cMunic,"CC2_XREGIA") // Localizo a regiao do cliente
	  EndIf
			
	  If !Empty(_cRegiao)
	     _nFrete := Posicione('ZZI',1,xFilial("ZZI")+_cRegiao,"ZZI_VALOR")       // Valor do frete para a regiao
	  Else
		 dbSelectArea("ZZI") // Caso nao tenha frete para aquela regiao pego o maior valor do estado.
		 dbSetOrder(3)
		 dbSeek(_cEst)				
		 While !Eof() .And. ZZI->ZZI_ESTADO == _cEst					
               If _nFrete < ZZI->ZZI_VALOR
			      _nFrete := ZZI->ZZI_VALOR
		       EndIf					
			   ZZI->(dbSkip())					
         EndDo				
	  EndIf
Endif
*/   
Return(_nFrete) 

Static Function Impttlzd()

	Local _yy := 0

For _yy := 1 to len(_aTotaliz)    
    If nLin > 55   //60 
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
    cLin := ""
    @nLin,000 PSAY "|"
    @nLin,002 PSAY "Totalizador ("+ALLTRIM(_aTotaliz[_yy,1])+")"
    cLin += "Totalizador;("+ALLTRIM(_aTotaliz[_yy,1])+");"
    @nLin,032 PSAY "|"
    @nLin,034 PSAY _aTotaliz[_yy,2]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Meta
    cLin += Transform(_aTotaliz[_yy,2],"@E 99.99")+";" 
    @nLin,041 PSAY _aTotaliz[_yy,3]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Realizado
    cLin += Transform(_aTotaliz[_yy,3],"@E 99.99")+";"
    if _lDiret
       @nLin,048 PSAY _aTotaliz[_yy,4]  	PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Referencial
       cLin += Transform(_aTotaliz[_yy,4],"@E 99.99")+";"  
    Endif   
    @nLin,056 PSAY "|"
    @nLin,057 PSAY _aTotaliz[_yy,5] 	PICTURE "@E 999,999,999" // "Faturamento(R$)" Meta
    cLin += Transform(_aTotaliz[_yy,5],"@E 999,999,999")+";"  
    @nLin,069 PSAY _aTotaliz[_yy,6] 	PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
    cLin += Transform(_aTotaliz[_yy,6],"@E 999,999,999")+";"
    if _lDiret    
       @nLin,082 PSAY _aTotaliz[_yy,7] 	PICTURE "@E 999,999,999"  // "Faturamento(R$)" Referencial
       cLin += Transform(_aTotaliz[_yy,7],"@E 999,999,999")+";"
    Endif    
    @nLin,096 PSAY _aTotaliz[_yy,8]		PICTURE "@E 9,999,999" // "Diferenca Fat(R$)" Real - Meta
    cLin += Transform(_aTotaliz[_yy,8],"@E 9,999,999")+";"
    if _lDiret     
       @nLin,107 PSAY _aTotaliz[_yy,9]  	PICTURE "@E 9,999,999" // Diferenca Fat(R$)" Real - Referencial
       cLin += Transform(_aTotaliz[_yy,9],"@E 9,999,999")+";"
    Endif   
    @nLin,119 PSAY "|"
    @nLin,124 PSAY _aTotaliz[_yy,10] 	PICTURE "@E 9.999"  // "indice" IPM
    cLin += Transform(_aTotaliz[_yy,10],"@E 9.999")+";"  
    if _lDiret
       &&Mauricio - 09/04/14 - alteração na formula de calculo conforme solicitação dos Srs. Marcus e Vagner.
       @nLin,131 PSAY _aTotaliz[_yy,3] - _aTotaliz[_yy,4] PICTURE "@E 99.999"  // "indice" IPR  // Alex Borges 24/11/11
       cLin += Transform(_aTotaliz[_yy,3] - _aTotaliz[_yy,4],"@E 99.999")+";"
         
       //@nLin,133 PSAY _aTotaliz[_yy,11]    PICTURE "@E 9.999"  // "indice" IPR  // Alex Borges 24/11/11
       //cLin += Transform(_aTotaliz[_yy,11],"@E 9.999")+";"
    Endif   
    @nLin,139 PSAY "|"
    //@nLin,142 PSAY "|"
    @nLin,140 PSAY _aTotaliz[_yy,12]    PICTURE "@E 99999,999"  // "Volume(kg)" Meta
    cLin += Transform(_aTotaliz[_yy,12],"@E 99999,999" )+";"
    @nLin,152 PSAY _aTotaliz[_yy,13]    PICTURE "@E 99999,999"   // "Volume(kg)" Realizado
    cLin += Transform(_aTotaliz[_yy,13],"@E 99999,999" )+";"   
    @nLin,162 PSAY _aTotaliz[_yy,14]    PICTURE "@E 99,999,999,999"  // "Volume(kg)" Projetado
    cLin += Transform(_aTotaliz[_yy,14],"@E 99999,999" )+";"    
    @nLin,177 PSAY _aTotaliz[_yy,15]    PICTURE "@E 99999,999" //"Volume(kg)" Necessaria
    cLin += Transform(_aTotaliz[_yy,15],"@E 99999,999" )+";"
    @nLin,186 PSAY "|" 
    @nLin,192 PSAY _aTotaliz[_yy,16]    PICTURE "@E 9999.9" //"Atingimento(%)" REalizado
    cLin += Transform(_aTotaliz[_yy,16],"@E 9999.9")+";"
    @nLin,205 PSAY _aTotaliz[_yy,17]    PICTURE "@E 9999.9"  //"Atingimento(%)" Projetado
    cLin += Transform(_aTotaliz[_yy,17],"@E 9999.9")+";"
    dBSelectArea("COBTOT")
	DbGotop()
	_nSomCli := 0
	//if dbseek(_Supervis)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBTOT->(!EOF()) //.AND. _Supervis == COBSUP->T2_SUPERVI
		    IF alltrim(COBTOT->T2_QBRNVL) $ _aTotaliz[_yy,1] 
			   _nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
			   If _nAscan <= 00
				  Aadd( _aCliCob, { COBTOT->T2_CLIENTE+COBTOT->T2_LOJA } )
				  _nSomCli ++
			   Endif
			Endif   
			COBTOT->(dbSkip())
		Enddo
	//Endif
	DbSelectArea("TEM2")
    @nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
    cLin += Transform(_nSomCli,"@E 9999" )+_eof
    fWrite(nHdl,cLin,Len(cLin))
    @nLin,218 PSAY "|"
    nLin++
    //@nLin,000 PSAY "|"
    //@nLin,034 PSAY "|"
    //@nLin,058 PSAY "|"
    //@nLin,121 PSAY "|"
    //@nLin,141 PSAY "|"
    //@nLin,142 PSAY "|"
    //@nLin,191 PSAY "|" 
    //@nLin,218 PSAY "|"
    //nLin++ 
Next

_aTotaliz := {}
    
Return()

Static Function Impttlzd2()

	Local _yy:= 0

For _yy := 1 to len(_aTotaliz)
    
    If nLin > 55   //60 
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
    cLin := ""
    @nLin,000 PSAY "|"
    @nLin,002 PSAY "Totalizador ("+ALLTRIM(_aTotaliz[_yy,1])+")"
    cLin += "Totalizador;("+ALLTRIM(_aTotaliz[_yy,1])+");"
    @nLin,032 PSAY "|"
    @nLin,034 PSAY _aTotaliz[_yy,2]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Meta
    cLin += Transform(_aTotaliz[_yy,2],"@E 99.99")+";" 
    @nLin,041 PSAY _aTotaliz[_yy,3]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Realizado
    cLin += Transform(_aTotaliz[_yy,3],"@E 99.99")+";"
    if _lDiret
       @nLin,048 PSAY _aTotaliz[_yy,4]  	PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Referencial
       cLin += Transform(_aTotaliz[_yy,4],"@E 99.99")+";"  
    Endif   
    @nLin,056 PSAY "|"
    @nLin,057 PSAY _aTotaliz[_yy,5] 	PICTURE "@E 999,999,999" // "Faturamento(R$)" Meta 
    cLin += Transform(_aTotaliz[_yy,5],"@E 999,999,999")+";"  
    @nLin,069 PSAY _aTotaliz[_yy,6] 	PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
    cLin += Transform(_aTotaliz[_yy,6],"@E 999,999,999")+";"
    if _lDiret    
       @nLin,082 PSAY _aTotaliz[_yy,7] 	PICTURE "@E 999,999,999"  // "Faturamento(R$)" Referencial
       cLin += Transform(_aTotaliz[_yy,7],"@E 999,999,999")+";"
    Endif    
    @nLin,096 PSAY _aTotaliz[_yy,8]		PICTURE "@E 9,999,999" // "Diferenca Fat(R$)" Real - Meta
    cLin += Transform(_aTotaliz[_yy,8],"@E 9,999,999")+";"
    if _lDiret     
       @nLin,107 PSAY _aTotaliz[_yy,9]  	PICTURE "@E 9,999,999" // Diferenca Fat(R$)" Real - Referencial
       cLin += Transform(_aTotaliz[_yy,9],"@E 9,999,999")+";"
    Endif   
    @nLin,119 PSAY "|"
    @nLin,124 PSAY _aTotaliz[_yy,10] 	PICTURE "@E 9.999"  // "indice" IPM
    cLin += Transform(_aTotaliz[_yy,10],"@E 9.999")+";"
    if _lDiret
       &&Mauricio - 09/04/14 - alteração na formula de calculo conforme solicitação dos Srs. Marcus e Vagner
       @nLin,131 PSAY _aTotaliz[_yy,3] - _aTotaliz[_yy,4]   PICTURE "@E 99.999"  // "indice" IPR  // Alex Borges 24/11/11
       cLin += Transform(_aTotaliz[_yy,3] - _aTotaliz[_yy,4],"@E 99.999")+";"
             
       //@nLin,133 PSAY _aTotaliz[_yy,11]    PICTURE "@E 9.999"  // "indice" IPR  // Alex Borges 24/11/11
       //cLin += Transform(_aTotaliz[_yy,11],"@E 9.999")+";"
    Endif   
    @nLin,139 PSAY "|"
    //@nLin,142 PSAY "|"
    @nLin,140 PSAY _aTotaliz[_yy,12]    PICTURE "@E 99999,999"  // "Volume(kg)" Meta
    cLin += Transform(_aTotaliz[_yy,12],"@E 99999,999")+";"
    @nLin,152 PSAY _aTotaliz[_yy,13]    PICTURE "@E 99999,999"   // "Volume(kg)" Realizado
    cLin += Transform(_aTotaliz[_yy,13],"@E 99999,999")+";"  
    @nLin,162 PSAY _aTotaliz[_yy,14]    PICTURE "@E 99,999,999,999"  // "Volume(kg)" Projetado
    cLin += Transform(_aTotaliz[_yy,14],"@E 99999,999")+";"     
    @nLin,177 PSAY _aTotaliz[_yy,15]    PICTURE "@E 99999,999" //"Volume(kg)" Necessaria
    cLin += Transform(_aTotaliz[_yy,15],"@E 99999,999")+";"
    @nLin,186 PSAY "|" 
    @nLin,192 PSAY _aTotaliz[_yy,16]    PICTURE "@E 9999.9" //"Atingimento(%)" REalizado
    cLin += Transform(_aTotaliz[_yy,16],"@E 9999.9")+";"
    @nLin,205 PSAY _aTotaliz[_yy,17]    PICTURE "@E 9999.9"  //"Atingimento(%)" Projetado
    cLin += Transform(_aTotaliz[_yy,17],"@E 9999.9")+";"
    dBSelectArea("COBSUP")
	DbGotop()
	_nSomCli := 0
	if dbseek(_Supervis)
		_aCliCob := {}      &&array para armazenar apenas uma vez um mesmo cliente
		WHILE COBSUP->(!EOF()) .AND. _Supervis == COBSUP->T2_SUPERVI
		    IF alltrim(COBSUP->T2_QBRNVL) $ _aTotaliz[_yy,1] 
			   _nAscan := Ascan( _aCliCob, { |x|x[ 01 ] == COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
			   If _nAscan <= 00
				  Aadd( _aCliCob, { COBSUP->T2_CLIENTE+COBSUP->T2_LOJA } )
				  _nSomCli ++
			   Endif
			Endif   
			COBSUP->(dbSkip())
		Enddo
	Endif
	DbSelectArea("TEM2")
    @nLin,212 PSAY _nSomCli PICTURE "@E 9999"  //"Atingimento" Projetado
    cLin += Transform(_nSomCli,"@E 9999" )+_eof
    fWrite(nHdl,cLin,Len(cLin))
    @nLin,218 PSAY "|"
    nLin++
    //@nLin,000 PSAY "|"
    //@nLin,034 PSAY "|"
    //@nLin,058 PSAY "|"
    //@nLin,121 PSAY "|"
    //@nLin,141 PSAY "|"
    //@nLin,142 PSAY "|"
    //@nLin,191 PSAY "|" 
    //@nLin,218 PSAY "|"
    //nLin++ 
Next

_aTotaliz := {}
    
Return()

Static Function _fOpenExcel()
cArqSai := "D:\TEMP\"     // Arquivo de Saida local

CpyS2T("\SYSTEM\"+cArq,cPath,.T.)

CpyS2T("\SYSTEM\"+cArq,cArqSai,.T.)

FerasE("\SYSTEM\"+cArq)

//------------------------------
// Abre MS-EXCEL
//------------------------------
If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return()

Static Function ImpCabec3(_Sps,_cMeta,_nVlr,_nExcel)

_nQtdcart := 0

_cQuery := ""
_cQuery += "SELECT COUNT(*) AS 'QTD_CLI'" 
_cQuery += "  FROM "+RetSqlName("SA1")+ " A1,"
_cQuery += "       "+RetSqlName("SA3")+ " A3"
_cQuery += " WHERE A1.D_E_L_E_T_ = ''"
_cQuery += "   AND A3.D_E_L_E_T_ = '' "
_cQuery += "   AND A1.A1_VEND = A3.A3_COD"
_cQuery += "   AND A3.A3_COD = '"+_Sps+"'"

TCQUERY _cQuery new alias "CARTEIRA"
CARTEIRA->(dbgotop())
While !EOF()
_nQtdcart := CARTEIRA->QTD_CLI
CARTEIRA->(dbskip())
Enddo   
CARTEIRA->(dbclosearea()) 


dbSelectArea("CLIENTE")
dbGoTop()
If DbSeek (_Sps)
	Do While !EOF() .and. CLIENTE->CLI_SUPERV ==_Sps
		_cCont++
		//If CLIENTE->CLI_FLAG = 'S'    ALEX BORGES 09/12/11
		IF CLIENTE->CLI_VALOR >= MV_PAR08
			_cContv++
		Endif	
		//if CLIENTE->CLI_FLAG2 = 'S'    ALEX BORGES 09/12/11
	   IF CLIENTE->CLI_VALOR >= MV_PAR09
		    _cContv2++			
		EndIf	
	
		DbSkip()
	Enddo
Endif 

if Ascan(_aSup,_Sps) == 0
   AADD(_aSup,_Sps)
   _nQtcartT += _nQtdcart
   _nTotCont  += _cCont   
   _nTotContv += _cContv
   _nTContv2  += _cContv2
endif

&&Mauricio - 20/02/13 - tratamento para saida excel
cLin := ""
&&Mauricio - 30/07/14 - nome errado supervisor
//_NomSup := Posicione("SA3",1,xFilial("SA3")+_Sps,"A3_NOME")
_NomSup := Posicione("SA3",10,xFilial("SA3")+_Sps,"A3_NOMSUP")
_TamNomSUp := LEN(ALLTRIM(_NomSup))
_nIndice:=(_cCont / _cMeta)*100
&&Mauricio 26/10/11 - incluido dias corridos
Cabec3 := "| SUPERVISOR: "+ _Sps +" - "+ _NomSup + Space(108-_TamNomSUp)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4) +Space(54)+"  DIAS UTEIS: " +right(str(_nDiasUtil),2)+"  |"
//If _nExcel == 1
   cLin := "SUPERVISOR:;"+_Sps+";"+_NomSup+";;;;;DE:"+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+";;;;;DIAS UTEIS:;"+right(str(_nDiasUtil),2)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
//Endif 
//Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(6)+ "UTEIS: " +right(str(_nDiasUtil),2)+Space(12)+"|"
Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(2)+Space(51)+ "DIAS CORRIDOS: " +right(str(_nDiasCorr),2)+"  |"
//If _nExcel == 1
   cLin := ";;;;;;;ATE:"+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4)+";;;;;DIAS CORRIDOS:;"+right(str(_nDiasCorr),2)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
//Endif
Cabec5 := "| CLIENTES CARTEIRA : "+right(str(_nQtdcart),5)+"        COBERTURA MES: "+right(str(_cCont),5)+"     ATIVO1: "+right(str(_cContv),5)+"     ATIVO2: "+right(str(_cContv2),5)
//If _nExcel == 1
   cLin := "CLIENTES;CARTEIRA:;"+right(str(_nQtdcart),5)+";;;;COBERTURA;MES:"+right(str(_cCont),5)+";;ATIVO1:;"+right(str(_cContv),5)+";;ATIVO2:;"+right(str(_cContv2),5)+";;;"+_eof
   fWrite(nHdl,cLin,Len(cLin))
   fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco 
//Endif
//If _nExcel == 1
   fWrite(nHdl,cLin6,Len(cLin6))
//Endif   
                            
//If _nExcel == 1
   fWrite(nHdl,cLin7,Len(cLin7))
//Endif    

dbSelectArea("TEM2")
_cCont:=0
_cContV:=0
_cContv2:=0
Return()
