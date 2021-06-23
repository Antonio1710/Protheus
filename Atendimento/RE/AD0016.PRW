#INCLUDE "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0016    º Autor ³ AP5 IDE            º Data ³  24/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Este relatorio faz a totalizacao das devolucoes, agrupando º±±
±±º          ³ por motivos e responsaveis                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0016 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Este relatorio faz a totalizacao das devolucoes, agrupando por motivos e responsaveis')

_aArea:=GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//cPerg   := "DEVOL3"
cPerg   := PADR("DEVOL3",10," ")
If !Pergunte(cPerg,.T.)
	Return
EndIf

Private cString
aOrd := {}
Private CbTxt        := ""
cDesc1         := "Este programa tem como objetivo imprimir relatorio "
cDesc2         := "de ocorrencias de devolucoes, totalizando os motivos e responsaveis"
cDesc3         := "Relatorio de Ocorrencia de Devolucoes"
cPict          := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "AD0016.PRW" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao",2,2, 1, "",1}
Private nLastKey        := 0
Private _nQtdev1u := 0
Private titulo       := "Ocorrencia de Devolucoes"
Private nLin         :=0
Private _cMotivo:=""
Private _nTotQtdGral:=0
Private _nTotGeral:=0
Private _cDevgG:=0
Private _cDevgT:=0
Private _cDevKgTot:=0
Private _cDevRTot:=0
Private _nTotQbr := 0

_dt1:=dtos(mv_par01)
_dt2:=dtos(mv_par02)

_nD2Notas	:=0
_nD2Qtde	:=0
_nD2Valor	:=0
_nTotMot    :=0

//Cabec1       := "Responsaveis          Motivos                  Devolucoes             Devolucoes                 Devolucoes         Vendas"
//Cabec2       := Space(47)+"No.       %          Kls           %             R$          % "
Cabec1 := "   Motivos                    Devolucoes               Devolucoes                 Devolucoes                 Quebra        Venda"
Cabec2 := "                           No.         %            Kls         %               R$         %           Kg         %            %"


Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
imprime      := .T.
Private wnrel      := "AD0016" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SZD"

aItens:={}
aItens2:={}
X:=""
_nTotal:=0
_cDevgG:=0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd ,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP5 IDE            º Data ³  24/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

aStru := {}

dbSelectArea("SZD")
dbSetOrder(2)

//Inclusao para somar as ocorrencias 04/04/06

//------------------------------------------------------------
// CONTA OS MOTIVOS DAS OCORRENCIAS
//------------------------------------------------------------
cQuery:=" SELECT COUNT(ZD_MOTIVO) AS TOT_MOT FROM "+RetSqlName("SZD")+;
" WHERE ZD_DTDEV between '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "+;
" AND ("+retsqlname("SZD")+".ZD_DEVTOT = 'T' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'P' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'Q') AND "+;
retsqlname("SZD")+".D_E_L_E_T_= ''"

TCQUERY cQuery new alias "TMP0"
TMP0->(dbgotop())

_cDevgG:=TMP0->TOT_MOT
DbCloseArea("TMP0")

//------------------------------------------------------------
// LEVANTA RESPOSAVEIS
//------------------------------------------------------------
cQuery := "  select DISTINCT ZD_RESPONS , ZD_RESPNOM, ZD_DESCMOT,ZD_MOTIVO , COUNT(ZD_MOTIVO) AS Total_Motivo "
cQuery += "  FROM "+retsqlname("SZD")
cQuery += "  WHERE ZD_DTDEV between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "
cQuery += "        ("+retsqlname("SZD")+".ZD_DEVTOT = 'T' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'P' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'Q') AND "
cQuery +=  retsqlname("SZD")+".D_E_L_E_T_= ''"
cQuery += "  GROUP BY ZD_RESPONS ,ZD_RESPNOM , ZD_MOTIVO ,ZD_DESCMOT "
cQuery += "  ORDER BY ZD_RESPNOM, ZD_DESCMOT "

TCQUERY cQuery new alias "TMP3"

TMP3->(dbgotop())

//------------------------------------------------------------
// TOTAL DE DEVOLUCOES(QTD DE ATENDIMENTOS)
//------------------------------------------------------------
cQuery := "   SELECT COUNT(ZD_MOTIVO) AS Total_Periodo   "          //Acha o Numero Total de Devolucoes do perido
cQuery += "   FROM " +retsqlname("SZD")
cQuery += "   WHERE ZD_DTDEV between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "
cQuery += "     and ("+retsqlname("SZD")+".ZD_DEVTOT = 'T' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'P'OR "+retsqlname("SZD")+".ZD_DEVTOT = 'Q') AND "
cQuery += retsqlname("SZD")+".D_E_L_E_T_= ''"

TCQUERY cQuery new alias "TMP1"

TMP1->(dbgotop())

_nTotal:=TMP1->Total_Periodo
DbCloseArea("TMP1")

//------------------------------------------------------------
// TOTALIZADOR
//------------------------------------------------------------
cQuery := "   SELECT SUM("+retsqlname("SZX")+".ZX_TOTAL) AS Total_Valor,SUM("+retsqlname("SZX")+".ZX_QTDEV1U) AS TotalQtde1U, SUM("+retsqlname("SZX")+".ZX_QUEBRA) AS TotalQUEBRA "
cQuery += "   FROM "+retsqlname("SZX")+"  INNER JOIN "+retsqlname("SZD")
cQuery += "     ON  "+retsqlname("SZX")+".ZX_NF ="+retsqlname("SZD")+".ZD_NUMNF"
cQuery += "      AND "+retsqlname("SZX")+".ZX_SERIE ="+retsqlname("SZD")+".ZD_SERIE"
cQuery += "      AND ("+retsqlname("SZD")+".ZD_DEVTOT = 'T' OR "+retsqlname("SZD")+".ZD_DEVTOT = 'P'OR "+retsqlname("SZD")+".ZD_DEVTOT = 'Q') "
cQuery += "    WHERE ZD_DTDEV between '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "
cQuery += retsqlname("SZD")+".D_E_L_E_T_= '' and " +retsqlname("SZX")+".D_E_L_E_T_= ''"

TCQUERY cQuery new alias "TMP2"

TMP2->(dbgotop())
_nTotGeral:=TMP2->Total_Valor
_nTotQtdGral:=TMP2->TotalQtde1U
_nTotQuebra := TMP2->TotalQUEBRA

DbCloseArea("TMP2")

X:=""
cQuery:= " SELECT ZD_RESPNOM, ZD_RESPONS, ZD_MOTIVO, ZD_DESCMOT, ZX_TOTAL Total_Valor, ZX_QTDEV1U TotalQtde1U, ZX_QUEBRA TotalQUEBRA,  "+;
" D2_QTDEDEV TotalDev1U "+;
" FROM "+retsqlname("SZX")+" SZX, "+retsqlname("SZD")+" SZD, "+retsqlname("SD2")+;
" WHERE "+;
" ZX_NF = ZD_NUMNF"+;
" AND ZX_SERIE = ZD_SERIE"+;
" AND D2_DOC = ZX_NF"+;
" AND D2_SERIE = ZX_SERIE"+;
" AND D2_COD = ZX_CODPROD"+;
" AND ZD_DTDEV BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "+;
" AND ZD_DEVTOT IN ('T','P','Q')"+;
" AND SZD.D_E_L_E_T_= '' and SZX.D_E_L_E_T_= ''  "+;
" ORDER BY ZD_RESPONS , ZD_MOTIVO"
TCQUERY cQuery new alias "TMP4"
TMP4->(dbgotop())

While !EOF()
	//Conta Total Motivo
	_cMotivo := ZD_MOTIVO
	_cResp   := ZD_RESPONS
	_nTotMot := 0
	Motivos()
	dbSelectArea("TMP4")
	_nQtdev1u  := 0
	X:=0
	_nPercTot  := ( _nTotMot /_nTotal) *100
	_cRespMot  := _cMotivo + _cResp
	_cPosMatrz := Ascan(aItens,{|x| x[1]==_cRespMot} )
	If _cPosMatrz = 0
		aadd(aItens,{_cRespMot,TMP4->ZD_RESPNOM,TMP4->ZD_DESCMOT,_nTotMot,_nPercTot,TMP4->Total_valor, TotalDev1U,TotalQUEBRA})
		//                  1             2                3        4         5                 6         7               8
		_cDevgT	   := _cDevgT + _nTotMot
	Else
		aItens[_cPosMatrz][4] := _nTotMot
		aItens[_cPosMatrz][5] := aItens[_cPosMatrz][5]
		aItens[_cPosMatrz][6] := aItens[_cPosMatrz][6] + TMP4->Total_valor
		aItens[_cPosMatrz][7] := aItens[_cPosMatrz][7] + TotalDev1U
		aItens[_cPosMatrz][8] := aItens[_cPosMatrz][8] + TMP4->TotalQUEBRA
	Endif
	
	Dbskip()
Enddo

//Quantidade devolvida

dbSelectArea("TMP4")
DbCloseArea("TMP4")

dbSelectArea("TMP3")
DbCloseArea("TMP3")

cQuery:="SELECT COUNT(DISTINCT D2_DOC) AS Total_Notas, SUM(D2_QUANT) AS Total_Qtde, SUM(D2_TOTAL) AS Total_Valor "+;
"from "+retsqlname("SD2") +" SD2"+;
" WHERE D2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' and "+;
" SD2.D_E_L_E_T_ = '' AND D2_TP='PA' AND "+;
" ( SD2.D2_GRUPO BETWEEN '"+mv_par03+"' and '"+ mv_par04+"' ) AND "+; // ICLUIDO POR HERALDO 15/07
" SUBSTRING (D2_CF, 1 , 2) != '59' AND "+;
" SUBSTRING (D2_CF, 1 , 2) != '69' AND EXISTS "+;
"(SELECT * "+;
" FROM " +retsqlname("SF2") +" SF2 "+;
" WHERE SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SF2.F2_TIPO = 'N' AND D_E_L_E_T_ = '') "

TCQUERY cQuery new alias "TMP5"
TMP5->(dbgotop())

_nD2Notas	:=TMP5->Total_Notas
_nD2Qtde 	:=TMP5->Total_Qtde
_nD2Valor	:=TMP5->Total_Valor

DbCloseArea("TMP5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o cancelamento pelo usuario...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAbortPrint
	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	//	Exit
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	
	nLin := 8
Endif


nLin:=8
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

nLin++
X:=""  //aItens[1][1]
Y:=""
Z:=0
a:=0
_cDev:=0
_cDevR  :=0
_cDevKg:=0
_nQbr := 0
For _I:=1 to len(aItens)
	If aItens[_I][2]!=X
		@nlin,001 PSAY "Responsavel: "+aItens[_I][2]   //Responsavel
		nLin++
		_cDev:=0
		_cDevR  :=0
		_cDevKg:=0
		_nQbr := 0
	Endif
	
	@nLin,001 Psay "-->"
	@nlin,004 PSAY aItens[_I][3]  					 			 // Motivo
	
	_cDev  :=_cDev+ aItens[_I][4]					 		         // Num de Devolucoes (Resp.)
	_nPerc := aItens[_I][4] / _nTotal * 100
	@nlin,027 PSAY aItens[_I][4]  PICTURE "@E 9999"   			     // Num de Devolucoes (Resp. X Motivo)
	@nlin,032 PSAY _nPerc         PICTURE "@E 9999.9999" 				 // Porcentagem do num. de devolucoes
	
	_cDevKg:= _cDevKg + aItens[_I][7] 					    	 //Acumula para exibir Total do responsavel (em Kg)
	@nlin,044 PSAY aItens[_I][7]  PICTURE "@E 9,999,999.99"		 //Devolucao em KG
	@nlin,057 PSAY (aItens[_I][7] / _nTotQtdGral)*100  PICTURE "@E 9999.9999"          //Indice Kg Geral / Kg Resp.
	
	_cDevR:=_cDevR + aItens[_I][6] 								//Acumula Valor (em R$) do Resp.
	@nlin,071 PSAY aItens[_I][6] PICTURE "@E 9,999,999.99" 		 //Devolucao em Reais
	@nlin,084 PSAY (aItens[_I][6] / _nTotGeral)* 100 PICTURE "@E 9999.9999"             //Indice Valor (R$) Geral / Valor Resp  errado
	
	_nQbr += aItens[_I][8]  // quebras
	@nlin,097 PSAY (aItens[_I][8])   PICTURE "@E 9999.9999"
	@nlin,107 PSAY (aItens[_I][8] / _nTotQtdGral)* 100 PICTURE "@E 9999.9999"
	
	@nlin,121 PSAY (aItens[_I][6] / _nD2Valor) * 100 PICTURE "@E 9999.9999"
	
	nLin++
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	If _I <= len(aItens)-1 .or. _I = 1
		If aItens[_I][2]!= aItens[_I+1][2]
			
			nLin++
			@nLin,004 PSAY "Total do Responsavel: "
			@nLin,027 PSAY _cDev PICTURE "@E 9999"
			@nLin,032 PSAY (_cDev /_cDevgG )*100  PICTURE "@E 9999.9999"
			
			_cDevKgTot+=_cDevKg
			@nLin,044 PSAY _cDevKg  PICTURE "@E 9,999,999.99"
			@nLin,057 PSAY (_cDevKg / _nTotQtdGral) * 100 PICTURE "@E 9999.9999"          //certo
			
			_cDevRTot+=_cDevR
			@nLin,071 PSAY _cDevR  PICTURE "@E 9,999,999.99"
			@nLin,084 PSAY (_cDevR / _nTotGeral) PICTURE "@E 9999.9999"
			
			_nTotQbr += _nQbr
			@nLin,097 PSAY _nQbr  PICTURE "@E 9999.9999"
			@nLin,107 PSAY (_nQbr / _nTotQtdGral ) PICTURE "@E 9999.9999"
			
			@nlin,121 PSAY (_cDevR / _nD2Valor) * 100 PICTURE "@E 9999.9999"
			nLin++
			@nLin,001 PSAY REPLICATE("-",124)
			nLin++
			nLin++
			
		Endif
	Endif
	
	If _I == len(aItens)
		
		nLin++
		@nLin,004 PSAY "Total do Responsavel: "
		@nLin,027 PSAY _cDev PICTURE "@E 9999"
		@nLin,032 PSAY (_cDev /_cDevgG )*100  PICTURE "@E 9999.9999"
		
		_cDevKgTot+=_cDevKg
		@nLin,044 PSAY _cDevKg  PICTURE "@E 9,999,999.99"
		@nLin,057 PSAY (_cDevKg / _nTotQtdGral) * 100 PICTURE "@E 9999.9999"          //certo
		
		_cDevRTot+=_cDevR
		@nLin,071 PSAY _cDevR  PICTURE "@E 9,999,999.99"
		@nLin,084 PSAY (_cDevR / _cDevRTot) PICTURE "@E 9999.9999"
		
		_nTotQbr += _nQbr
		@nLin,097 PSAY _nQbr  PICTURE "@E 9999.9999"
		@nLin,107 PSAY (_nQbr / _nTotQbr ) PICTURE "@E 9999.9999"
		
		@nlin,121 PSAY (_cDevR / _nD2Valor) * 100 PICTURE "@E 9999.9999"
		nLin++
		@nLin,001 PSAY REPLICATE("-",124)
		nLin++
		
	Endif
	
	
	X:=aItens[_I][2]
	
Next

nLin++
@nLin,001 PSAY REPLICATE("-",124)
nLin++

@nlin,003 PSAY "Total Devolucao: "
@nlin,040 PSAY _cDevgT    PICTURE "9999"
@nLin,055 PSAY _cDevKgTot PICTURE "@E 999,999,999.99"
@nLin,082 PSAY _cDevRTot  PICTURE "@E 999,999,999.99"
@nLin,107 PSAY _nTotQbr   PICTURE "@E 999,999.99"

nLin++
@nlin,003 PSAY "Total Vendas: "
@nlin,040 PSAY _nD2Notas  PICTURE "9999"
@nLin,055 PSAY _nD2Qtde   PICTURE "@E 999,999,999.99"
@nLin,082 PSAY _nD2Valor  PICTURE "@E 999,999,999.99"

nLin++
@nlin,003 PSAY "Devolucoes / Vendas: "
@nlin,037 PSAY (_cDevgG / _nD2Notas)*100  PICTURE "@E 999.999"
@nLin,062 PSAY (_cDevKgTot / _nD2Qtde)*100 PICTURE "@E 999.999"
@nLin,089 PSAY (_cDevRTot / _nD2Valor)*100 PICTURE "@E 999.999"

nLin := nLin + 2

//@nlin,045 PSAY _cDevgT  PICTURE "999"



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
RestArea(_aArea)
Return

Static Function Motivos()

_nTotMot := 0
dbSelectArea("TMP3")
TMP3->(dbgotop())
Do While !eof()
	If ZD_MOTIVO ==	_cMotivo .and. ZD_RESPONS  == _cResp
		_nTotMot := Total_Motivo
		//_cDevgT	 :=	_cDevgT + Total_Motivo
		EXIT
	Endif
	DbSkip()
Enddo

Return

