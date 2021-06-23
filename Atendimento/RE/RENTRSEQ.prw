#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RENTRSEQ  º Autor ³ Ana Helena Barreta º Data ³  22/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Entregas realizadas por sequencia. Montado comº±±
±±º            base no relatorio RELENTREG, ajustando para exibir a       º±±
±±º            sequencia ao inves do roteiro. Chamado 020080              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ad'oro                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RENTRSEQ()
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de entregues realizadas por sequencia."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := "Entregas Realizadas - Por Sequencia"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "RENTRSEQ"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "RELENT"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RENTRSEQ"
Private cString := "SZD"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Entregas realizadas por sequencia. Montado com base no relatorio RELENTREG, ajustando para exibir a sequencia ao inves do roteiro. Chamado 020080')

dbSelectArea("SZD")
dbSetOrder(1)

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

DadosRel()

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

dBcLOSEaREA("TRB")
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem

dbSelectArea("TRB")
dbGoTop()

SetRegua(RecCount())
_nFEntr := 0
nTotAentr := 0
nTotEntr  := 0
While !EOF()
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
		@nLin, 001 PSAY "Periodo de : "+DTOC(mv_par01)+ " ate "+DTOC(mv_par02)
		nLin += 2
		@nLin,001 PSAY REPLICATE("-",75)
		nLin += 1
		@nLin,025 PSAY "SEQUENCIA"		
		@nLin,048 PSAY "PEDIDOS"
		nLin += 1
		@nLin,025 PSAY "---------"
		@nLin,038 PSAY REPLICATE("-",38)
		nLin += 1
		@nLin,038 PSAY "A ENTREGAR"
		@nLin,050 PSAY "ENTREGUES"
		@nLin,062 PSAY "% REALIZADAS"
		nLin += 1
		@nLin,001 PSAY REPLICATE("-",75)
		nLin += 1
	Endif
	
	_nFEntr := Entregue(TRB->SEQUENC)
	@nLin, 028 PSAY TRB->SEQUENC Picture "@E 999"
	@nLin, 038 PSAY TRB->AENTR Picture "@E 99999"
	@nLin, 050 PSAY _nFEntr Picture "@E 99999"
	@nLin, 062 PSAY (_nFEntr/(TRB->AENTR))*100 Picture "@E 9999.99%"
	nTotAentr += TRB->AENTR
	nTotEntr  += _nFEntr		

	DbSelectArea("TRB")
	dbSkip()
	nLin += 1
	_nFEntr := 0
EndDo
@nLin,001 PSAY REPLICATE("-",75)
nLin += 2

@nLin,001 PSAY "Total "
@nLin, 038 PSAY nTotAentr Picture "@E 99999"
@nLin, 050 PSAY nTotEntr  Picture "@E 99999"
@nLin, 062 PSAY (nTotEntr/(nTotAentr))*100 Picture "@E 9999.99%"

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


Static function DadosRel()

aStru := {}
AADD (aStru,{"SEQUENC" 	    , "C",03,0})
AADD (aStru,{"DATAD"     	, "D",08,0})
AADD (aStru,{"AENTR"     	, "N",14,0})
_cNomTrb := CriaTrab(aStru)

dbUseArea(.T.,,_cNomTrb,"TRB",.F.,.F.)
cIndex   	:=	 "SEQUENC"
IndRegua( "TRB", _cNomTrb, cIndex,,,"Criando Indice TRB..." )

cQuery:=" SELECT C5_FILIAL, C5_SEQUENC, COUNT(*) AS AENTR FROM "+retsqlname("SC5")+;
" WHERE C5_DTENTR between '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "+;
" AND C5_ROTEIRO between '"+mv_par03+"' AND '"+mv_par04+"' AND "+;
" C5_FILIAL IN ("+Alltrim(mv_par05)+") AND "+;
Iif(MV_PAR06 = 1, "(C5_NOTA <> '' OR C5_LIBEROK = 'E' AND C5_BLQ = '' ) AND ","")+;
retsqlname("SC5")+".D_E_L_E_T_= ''"
cQuery += " GROUP BY C5_FILIAL, C5_SEQUENC "

TCQUERY cQuery new alias "XSC5"

DbSelectArea("TRB")

DbSelectArea("XSC5")
DbGoTop()
While !EOF()
	Reclock("TRB",.T.)
	TRB->SEQUENC := XSC5->C5_SEQUENC
	TRB->AENTR := XSC5->AENTR
	MsUnlock()
	DBSELECTAREA("XSC5")
	DBSKIP()
ENDDO

DBCLOSEAREA()

RETURN()

Static function Entregue(_cSeq)
Local _nTotal := 0
                        
cQuery:="SELECT COUNT(*) AS TOT "+;
"FROM "+retsqlname("SZD")+", "+retsqlname("SC5")+" "+;
"WHERE C5_FILIAL IN ("+ALLTRIM(MV_PAR05)+") AND "+;
"ZD_FILIAL = C5_FILIAL AND "+;
"C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND "+;
"C5_SEQUENC = '"+_cSeq+"' AND "+;
"C5_NUM = ZD_PEDIDO AND "+;
Iif(MV_PAR06 = 1, "(C5_NOTA <> '' OR C5_LIBEROK = 'E' AND C5_BLQ = '' ) AND ","")+;
"ZD_DEVTOT <> 'O' AND "+;
""+RetSqlName("SZD")+ ".D_E_L_E_T_= '' AND "+RetSqlName("SC5")+ ".D_E_L_E_T_= ''"

TCQUERY cQuery new alias "XSZD"

XSZD->(dbgotop())

_nTotal :=XSZD->TOT
DbCloseArea("XSZD")

RETURN(_nTotal)