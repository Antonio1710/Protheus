#INCLUDE "rwmake.ch"     
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAD0158     บ Autor ณ Daniel Pitthan     บ Data ณ  17/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Controle de Taras FGV                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Logistica                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AD0158


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "CONTROLE DE TARAS X PESO PADRAO"
Local cPict          := ""
Local titulo       := "CONTROLE DE TARAS X PESO PADRAO"
Local nLin         := 80

Local Cabec1       := "LOGISTICA"
Local Cabec2       := "ADORO S/A"
Local imprime      := .T.
Local aOrd := {}   

Local _cRet := ""

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "M"
Private nomeprog         := "AD0158" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "AD0158" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""

Private _dZV1DATA	//Data de Abate Realizado
Private _nZV1NUMNFS	//NF
Private _cZV1CLIBAL	//Clima na Balanca
Private _cZV2PLACA	//Placa
Private _nZV2GUIA	//Guia
Private _nZV21PESO	//1 peso
Private _nZV22PESO	//2 peso
Private _nZV4PESO	//peso do veiculo
Private _nPeLiq     //peso liquido
Private _nDif  //diferenca
Private _dDtaIni // data inicial da pergunta
Private _dDtaFim // data final da pergunta

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ProgramadoX Realizado')

/*PERGUNTAS*/
cPerg:="AD0158"
pergunte(cPerg,.T.)   

_dDtaIni:=MV_PAR01 //DATA INICAL DE ABATE
_dDtaFim:=MV_PAR02 //DATA FINAL DE ABATE


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู



wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  17/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())



//ฺฤฤฤฤฤฤฤฤฤฟ
//ณQUERY SQLณ
//ภฤฤฤฤฤฤฤฤฤู


Cquery:=" SELECT ZV1_NUMOC, ZV1_DATA, ZV1_NUMNFS, ZV1_CLIBAL, ZV1_RPLACA ,"+;
" ZV2_PLACA, ZV2_GUIA, ZV2_1PESO, ZV2_2PESO, ZV1_DTABAT ,"+;
" ZV1_TARAPD "+;
" FROM "+RetSqlName("ZV1")+ ", "+RetSqlName("ZV2")+ ""+;//, ZV4010 "+;
" WHERE "+;
" (ZV1_DTABAT >='" + DTOS(_dDtaIni) + "' AND ZV1_DTABAT  <='" + DTOS(_dDtaFim) + "') "+;
" AND ZV1_GUIAPE  = ZV2_GUIA  "+;//" AND ZV1_RPLACA  = ZV4_PLACA "+;
" AND "+RetSqlName("ZV1")+ ".D_E_L_E_T_ = '' AND "+RetSqlName("ZV2")+ ".D_E_L_E_T_ = '' "

TCQUERY Cquery new alias "TR"
DbSelectArea("TR")


dbGoTop()
While !EOF()
	
	/*Adquirindo campos*/
	
	_dZV1DATA	:=TR->ZV1_DATA	   //Data de Abate Realizado
	_nZV1NUMNFS	:=TR->ZV1_NUMNFS   //NF
	_cZV1CLIBAL	:=TR->ZV1_CLIBAL   //Clima na Balanca
	_cZV2PLACA	:=TR->ZV2_PLACA    //Placa
	_nZV2GUIA	:=TR->ZV2_GUIA     //Guia
	_nZV21PESO	:=TR->ZV2_1PESO    //1 peso
	_nZV22PESO	:=TR->ZV2_2PESO    //2 peso
	_nZV4PESO	:=TR->ZV1_TARAPD   //peso do veiculo
	_nZV1NUMOC  :=TR->ZV1_NUMOC    //Numero da Ordem
	/*Calculos*/
	
	_nPeLiq:= (_nZV21PESO-_nZV4PESO) // alt. conf. chamado 001294 (_nZV21PESO-_nZV22PESO) //peso liquido
	_nDif:=(_nZV22PESO-_nZV4PESO) //diferenca, segunda pesagem - peso do veiculo
	
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8  
		nLin:=Cabec5(nLin)
		nLin:=Cabec4(nLin)	    
	Endif      
		_dDatEntr:=  SUBSTR (_dZV1DATA,7,2)+ "/" + SUBSTR (_dZV1DATA,5,2) +"/"+ SUBSTR (_dZV1DATA,1,4)
	
	@ nlin,003 PSAY _cZV2PLACA
	@ nLin,013 PSAY _nZV2GUIA
	@ nLin,022 PSAY  _nZV1NUMNFS
	@ nLin,031 PSAY _nZV21PESO
	@ nLin,043 PSAY SUBSTR(_cZV1CLIBAL,1,1)
	@ nLin,049 PSAY _nZV22PESO
	@ nLin,060 PSAY "M"
	@ nLin,066 PSAY _nPeLiq
	@ nLin,078 PSAY _nZV4PESO
	@ nLin,091 PSAY _dDatEntr
	@ nLin,103 PSAY _nDif
	@ nLin,115 PSAY _nZV1NUMOC
	nLin:=nLin+1
/*
| VEICULO | GUIA   |   NF   | 1o PESO   | S/M | 2o PESO  | S/M | PESO LIQ. | PESO PADRAO | DATA ABATE | DIFERENCA | ORDEM |
  XXXXXXX   XXXXXX   XXXXXX   XXXXXXXX    X     XXXXXXXX   X     XXXXXXXX    XXXXXXXX      XXXXXXXX     XXXXXXXX    XXXXXX
---------------------------------------------------------------------------------------------------------------------------
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
0         1         2         3         4         5         6         7         8         9        10        11         120
*/
	
	
	dbSkip()
EndDo


DBCLOSEAREA("TR")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
| VEICULO | GUIA   |   NF   | 1o PESO   | S/M | 2o PESO  | S/M | PESO LIQ. | PESO PADRAO | DATA ABATE | DIFERENCA | ORDEM |
XXXXXXX   XXXXXX   XXXXXX   XXXXXXXX    X     XXXXXXXX   X     XXXXXXXX    XXXXXXXX      XXXXXXXX     XXXXXXXX      XXXXXX
---------------------------------------------------------------------------------------------------------------------------
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
0         1         2         3         4         5         6         7         8         9        10        11
*/

/*Cabecalho do relatorio*/

static function Cabec4 (xLin)    
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE (CHR(176),121)
xLin:=xLin+1
@ xLin,000 PSAY "| VEICULO | GUIA   |   NF   | 1o PESO   | S/M | 2o PESO  | S/M | PESO LIQ. | PESO PADRAO | DATA ABATE | DIFERENCA | ORDEM |"
xLin:=xLin+1
@ xLin,000 PSAY REPLICATE (CHR(176),121) 
xLin:=xLin+1
return (xLin)    
 
/*Imprimindo a data de abate*/
static function Cabec5 (xLin)
	@ xLin,000 PSAY "PERIODO DE ABATE"
	xLin:=xLin+1
	@ xLin,000 PSAY REPLICATE ("_",26)
	xLin:=xLin+1 
	@ xLin,000 PSAY "|"
	@ xLin,002 PSAY DTOC(_dDtaIni) 
	@ xLin,012 PSAY "-"	
	@ xLin,014 PSAY DTOC(_dDtaFim)	
	@ xLin,026 PSAY "|"
	xLin:=xLin+1
	@ xLin,000 PSAY REPLICATE ("_",26)	
	xLin:=xLin+2	
	
Return (xLin)
