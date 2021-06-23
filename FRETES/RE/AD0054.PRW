/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออหออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMANUTENCAO|Autor  บ DANIEL PITTHAN SILVEIRA    บ Data ณ  10/27/06   บฑฑ
ฑฑฬออออออออออุอออออออสออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCORRIGIDO A BUSCA DA INFORMACAO, ALTERADO PARA UMA       บฑฑ
ฑฑบ          ณQUERY. CONTEMPLADO TIPO DE FRETE                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AD0054   บ Autor ณ Gustavo Gonela     บ Data ณ  01/08/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Movimentacao de Frete                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Logistica                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//---------------------------------------------------------------------------
//								MANUTENCAO
//---------------------------------------------------------------------------
//DANIEL- CONSULTA CONTEMPLANDO O NOVO PARAMETRO DO RELATORIO
//

/*/

User Function AD0054

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Movimentacao de Frete')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01             // Data de                              |
//ณ mv_par02             // Data ate                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cPerg   := "AD0054"
Pergunte(cPerg,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cDesc1       := "Este programa tem como objetivo imprimir relatorio "
cDesc2       := "de acordo com os parametros informados pelo usuario."
cDesc3       := "Movimentacao de Frete"
cPict        := ""
titulo       := "Movimentacao de Frete"
nLin         := 80

Cabec1       := ""
Cabec2       := ""
imprime      := .T.
aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "AD0054" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "AD0054" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SZK"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  01/08/03   บฑฑ
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

dbSelectArea(cString)
dbSetOrder(1)
nLin := 80
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())

_dDtEntr  := mv_par01
_dDtEntr2 := mv_par02
_cTipFrt:=MV_PAR03
_nTotFatb   := 0
_nTotPesbal := 0
_nTotFret   := 0
_nTotKM     := 0
_cTipVei    := space(2)

//Cabec1  := "Periodo de : " + substr(_dDataEntr,7,2)+ "/" + substr(_dDataEntr,5,2)+ "/" + substr(_dDataEntr,1,4)+ SPACE(5) +  "Ate : " + substr(_dDataEntr2,7,2)+ "/" + substr(_dDataEntr2,5,2)+ "/" + substr(_dDataEntr2,1,4)
Cabec1  := space(90)+ "Periodo de : " + DTOC(_dDtEntr) + " Ate : " + DTOC(_dDtEntr2)

Cabec3  := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
Cabec4  := "|     VEICULO      |                       |                 DISTRIBUICAO                   |                 PESAGEM                   |        SAIDA         |       RETORNO        |  CONTR.KM  |         |             |"
Cabec5  := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
Cabec6  := "|  PLACA  |  TIPO  |     FORNECEDOR        | ROT |No.ENTR.|ENTR.DEV.|       DESTINO         | EXPEDICAO | BALANCA |   DIF.   |  % DIF.  |   HORA   |    KM     |   HORA   |    KM     |  DIF. KM   |  GUIA   |  VL. FRETE  |"
Cabec7  := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22        23
//          01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posicionamento do primeiro registro e loop principal. Pode-se criar ณ
//ณ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ณ
//ณ cessa enquanto a filial do registro for a filial corrente. Por exem ณ
//ณ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ณ
//ณ                                                                     ณ
//ณ dbSeek(xFilial())                                                   ณ
//ณ While !EOF() .And. xFilial() == A1_FILIAL                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   

_cQuery:="SELECT ZK_PLACAPG,ZK_TPFRETE,ZK_NOMFOR,ZK_ROTEIRO,ZK_ENTREGA,ZK_ENTRDEV,ZK_DESTINO,ZK_PESFATB,ZK_PESOBAL, "
_cQuery+=" ZK_PESOBAL,ZK_PESFATB,ZK_HORASAI,ZK_KMSAI,ZK_HORAENT,ZK_KMENT,ZK_GUIA,ZK_VALFRET,ZK_PESFATB "
_cQuery+=" FROM "+RETSQLNAME("SZK")+" WHERE (ZK_DTENTR BETWEEN "+DTOS(_dDtEntr)+" AND "+DTOS(_dDtEntr2)+") AND ZK_TIPFRT='"+ALLTRIM(_cTipFrt)+"' "
_cQuery+=" AND D_E_L_E_T_='' "
_cQuery+=" ORDER BY ZK_ROTEIRO,ZK_TPFRETE,ZK_PLACAPG "
TCQUERY _cQuery New Alias "TMP"   
DbSelectArea("TMP")
DbGoTop()

//dbSelectArea("SZK") // Arquivo de Frete
//dbSetOrder(8)  // Indice (3) ZK_DTENTR
//dbSeek(xFilial("SZK")+ dtos(_dDtEntr))
DO While !EOF () //.and. (ZK_DTENTR >= _dDtEntr)  .and. (ZK_DTENTR <= _dDtEntr2) .AND. (ALLTRIM(ZK_TIPFRT)=ALLTRIM(_cTipFrt))
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	dbSelectArea("ZV4") // Veiculos
	dbSetOrder(1)  // Indice (1) ZV4_PLACA
	dbSeek(xFilial("ZV4")+ TMP->ZK_PLACAPG)
	_cTipVei := ZV4->ZV4_TIPVEI

	dbSelectArea("TMP")
//	dbSelectArea("SZK")
//	dbSetOrder(8)
	
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		@nLin,000 PSAY CABEC3
		nLin := nLin + 1
		@nLin,000 PSAY CABEC4
		nLin := nLin + 1
		@nLin,000 PSAY CABEC5
		nLin := nLin + 1
		@nLin,000 PSAY CABEC6
		nLin := nLin + 1
		@nLin,000 PSAY CABEC7
		nLin := nLin + 1
		
	Endif
	@nLin,000 PSAY "|"
	@nLin,002 PSAY TMP->ZK_PLACAPG
	@nLin,010 PSAY "|"
	@nLin,012 PSAY _cTipVei+"  "+TMP->ZK_TPFRETE
	@nLin,019 PSAY "|"
	@nLin,021 PSAY SUBSTR (TMP->ZK_NOMFOR,1,20)
	@nLin,043 PSAY "|"
	@nLin,045 PSAY TMP->ZK_ROTEIRO
	@nLin,049 PSAY "|"
	@nLin,051 PSAY TMP->ZK_ENTREGA
	@nLin,058 PSAY "|"
	@nLin,062 PSAY TMP->ZK_ENTRDEV
	@nLin,068 PSAY "|"
	@nLin,070 PSAY SUBSTR(TMP->ZK_DESTINO,1,20)
	@nLin,092 PSAY "|"
	@nLin,094 PSAY TMP->ZK_PESFATB PICTURE '@E 999,999'
	@nLin,104 PSAY "|"
	@nLin,106 PSAY TMP->ZK_PESOBAL PICTURE '@E 999,999'
	@nLin,114 PSAY "|"
	@nLin,117 PSAY ( TMP->ZK_PESOBAL-TMP->ZK_PESFATB ) PICTURE '@E 999,999'
	@nLin,125 PSAY "|"
	If TMP->ZK_PESFATB > 0 .AND.  TMP->ZK_PESOBAL > 0
		@nLin,127 PSAY ((TMP->ZK_PESOBAL-TMP->ZK_PESFATB) /TMP->ZK_PESFATB) * 100 PICTURE '@E 999,999'
	Else
		@nLin,127 PSAY 0 PICTURE '@E 999,999'
	Endif
	@nLin,136 PSAY "|"
	@nLin,138 PSAY TMP->ZK_HORASAI
	@nLin,147 PSAY "|"
	@nLin,149 PSAY TMP->ZK_KMSAI PICTURE '@E 999,999'
	@nLin,159 PSAY "|"
	@nLin,161 PSAY TMP->ZK_HORAENT
	@nLin,170 PSAY "|"
	@nLin,172 PSAY TMP->ZK_KMENT PICTURE '@E 999,999'
	@nLin,182 PSAY "|"
	@nLin,186 PSAY ( TMP->ZK_KMENT - TMP->ZK_KMSAI ) PICTURE '@E 999,999'
	@nLin,195 PSAY "|"
	@nLin,197 PSAY TMP->ZK_GUIA
	@nLin,205 PSAY "|"
	@nLin,207 PSAY TMP->ZK_VALFRET PICTURE '@E 999,999.99'
	@nLin,219 PSAY "|"
	
	_nTotFatb   += TMP->ZK_PESFATB
	_nTotPesbal += TMP->ZK_PESOBAL
	_nTotKM     += ( TMP->ZK_KMENT - TMP->ZK_KMSAI )
	_nTotFret   += TMP->ZK_VALFRET
	
	nLin := nLin + 1
	
	dbSkip()
Enddo

@nLin,000 PSAY "|"
@nLin,001 PSAY REPLICATE ("-",218)
@nLin,219 PSAY "|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,002 PSAY "TOTAL =>"
@nLin,094 PSAY _nTotFatb PICTURE '@E 999,999'
@nLin,106 PSAY _nTotPesbal PICTURE '@E 999,999'
@nLin,186 PSAY _nTotKM PICTURE '@E 999,999'
@nLin,207 PSAY _nTotFret PICTURE '@E 999,999.99'
@nLin,219 PSAY "|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,001 PSAY REPLICATE ("-",218)
@nLin,219 PSAY "|"


dbCloseArea("TMP")
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
