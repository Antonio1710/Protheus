#include "rwmake.ch"
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAD0087    บ Autor ณ HERALDO C. HEBLING บ Data ณ  15/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de fatuamento por nome do cliente                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Este relatorio atende a area financeira para se saber      บฑฑ
ฑฑบ          ณ quanto foi faturado por redes em determinado periodo       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Financeiro                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบManutencaoณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function AD0087()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de fatuamento por nome do cliente')

SetPrvt("AAREA,LI,LCABEC,CNUMORC,ACONDICOES,AFORMAPGTO")
SetPrvt("LERROVEND,NFP,OBS,OBS1,")

Private oFont, cCode
nHeight:=15
lBold:= .F.
lUnderLine:= .F.
lPixel:= .T.
lPrint:= .T.
oFont07:= TFont():New( "Times New Roman",,07,,.t.,,,,,.f. )
oFont08:= TFont():New( "Times New Roman",,08,,.F.,,,,,.f. )
oFont09:= TFont():New( "Times New Roman",,09,,.t.,,,,,.f. )
oFont10:= TFont():New( "Times New Roman",,10,,.t.,,,,,.f. )
oFont12:= TFont():New( "Times New Roman",,12,,.t.,,,,,.f. )
oFont14:= TFont():New( "Times New Roman",,14,,.t.,,,,,.f. )
oFont16:= TFont():New( "Times New Roman",,16,,.t.,,,,,.f. )
oFont20:= TFont():New( "Times New Roman",,20,,.t.,,,,,.f. )
oFontC08:= TFont():New( "Courier New",,08,,.t.,,,,,.f. )
oFontC10:= TFont():New( "Courier New",,10,,.t.,,,,,.f. )
oFontA06:= TFont():New( "Arial",,06,,.f.,,,,,.f. )
oFontA07:= TFont():New( "Arial",,07,,.f.,,,,,.f. )
oFontA08:= TFont():New( "Arial",,08,,.t.,,,,,.f. )
oFontA09:= TFont():New( "Arial",,09,,.t.,,,,,.f. )
oFontA10:= TFont():New( "Arial",,10,,.t.,,,,,.f. )
oFontA11:= TFont():New( "Arial",,11,,.t.,,,,,.f. )
oFontA12:= TFont():New( "Arial",,12,,.t.,,,,,.f. ) 
oFontA14:= TFont():New( "Arial",,14,,.t.,,,,,.f.) 
oPrn:=TMSPrinter():New() 
//oFontA14:= TFont():New( "NOME DA FONTE",,TAMANHO,,BOLD,,,,?,SUBLINHADO ) // Primeiro .t. ้ sobre bold ou nao
/**********************************************
/**  mv_par01		:=	DATA DE              **
/**  mv_par02		:=	DATA ATE             **
/**  mv_par03		:=	String de Selecao    **
/**********************************************/
Private cPerg       := "AD0087"
pergunte(cPerg,.T.)

aArea := GetArea()  // Grava a area atual
	
nPag:= 1
_nLin:= 680
_cNomerel	:=	"RELACAO DE FATURAMENTO POR REDE"
_cNomePro	:= "AD0087"
// Posiciona Arquivos                         

cQuery:= 	"SELECT F2_CLIENTE,F2_LOJA, COUNT(*) NFS, SUM(F2_VALBRUT) BRUTO "+;
			"FROM "+retsqlname("SF2")+" AS SF2 "+;
			"WHERE D_E_L_E_T_ <>'*' "+;
			"AND F2_FILIAL = '"+xFilial("SF2")+"' "+;
			"AND F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+ "' "+;
			"AND EXISTS( SELECT * "+;
			"FROM "+retsqlname("SA1")+" AS SA1 "+;
			"WHERE (A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA) "+;
			"AND SA1.D_E_L_E_T_ <>'*' "+;
			"AND A1_NOME LIKE '%"+ALLTRIM(mv_par03)+"%') "+;
			"GROUP BY F2_CLIENTE, F2_LOJA "+;
			"ORDER BY F2_CLIENTE, F2_LOJA "
TCQUERY cQuery new alias "ZAPT"

DBSELECTAREA("ZAPT")
DBGOTOP()

_cCliente	:=	ZAPT->F2_CLIENTE
_cLoja		:=	ZAPT->F2_LOJA
_nQtd		:=	0
_nValor		:=	0

Do While !Eof()                                     
 	if nPag==1.or._nLin>3050	&& Cabecalho
		if nPag<>1
			oPrn:Endpage()
			oPrn:Startpage()

		endif
		_cNPag	:=	STR(nPag)
		_fCabec(_cNomeRel,_cNomePro,_cNPag)
		nPag+= 1
		
	//	oPrn:Line(0060,0190,2400,0190)
		oPrn:Say(0200,0100,"Data de: "+DTOS(mv_par01)		,oFontA08,100)
		oPrn:Say(0200,0500,"ate: "+DTOS(mv_par02)			,oFontA08,100)
		oPrn:Say(0260,0100,"String de Pesquisa: "+mv_par03	,oFontA08,100)
		
		oPrn:Box(0400,0100,0495,0460)
		oPrn:Box(0400,0485,0495,1735)
		oPrn:Box(0400,1765,0495,1875)
		oPrn:Box(0400,1900,0495,2300)
		oPrn:Box(0500,0100,3100,0460)
		oPrn:Box(0500,0485,3100,1735)
		oPrn:Box(0500,1765,3100,1875)
		oPrn:Box(0500,1900,3100,2300)
		oPrn:Say(0460,0115,"codigo do cliente/loja"		,oFontA08,100)
		oPrn:Say(0460,0500,"nome do cliente"			,oFontA08,100)
		oPrn:Say(0440,1780,"qtd. de"					,oFontA08,100)
		oPrn:Say(0460,1780,"notas"						,oFontA08,100)
		oPrn:Say(0460,1915,"valor total bruto faturado"	,oFontA08,100)
		_nLin := 0580
	Endif
	oPrn:Say(_nLin,0130,ZAPT->F2_CLIENTE+"-"+ZAPT->F2_LOJA	,oFontA14,100)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1") + ZAPT->F2_CLIENTE+ZAPT->F2_LOJA)
	oPrn:Say(_nLin,0515,SA1->A1_NOME	,oFontA14,100)
	oPrn:Say(_nLin,1780,transform(ZAPT->NFS,"@E 9999") ,oFontA11,100)
	oPrn:Say(_nLin,1915,transform(ZAPT->BRUTO,"@E 999,999,999.99") ,oFontA14,100)
	_nQtd	+=	ZAPT->NFS
	_nValor	+=	ZAPT->BRUTO
	_nLin += 060
	DbSelectArea("ZAPT")
	DBSKIP()
Enddo
oPrn:Line(_nLin,0100,_nLin,2300)
oPrn:Line(_nLin+1,0100,_nLin+1,2300)
oPrn:Line(_nLin+2,0100,_nLin+2,2300)
oPrn:Line(_nLin+3,0100,_nLin+3,2300)
_nLin += 060
oPrn:Say(_nLin,0515,"T  O  T  A  L  --->>>>"	,oFontA14,100)
oPrn:Say(_nLin,1780,transform(_nQtd		,"@E 9999") ,oFontA11,100)
oPrn:Say(_nLin,1915,transform(_nValor	,"@E 999,999,999.99") ,oFontA14,100)
_nLin += 060
oPrn:Line(_nLin,0100,_nLin,0600)
oPrn:Line(_nLin+2,0100,_nLin+2,0600)
oPrn:Line(_nLin+4,0100,_nLin+4,0600)

oPrn:Line(_nLin,0600,3000,1800)
oPrn:Line(_nLin+2,0600,3000,1800)
oPrn:Line(_nLin+4,0600,3000,1800)
oPrn:Line(3000,1800,_nLin,2300)
oPrn:Line(3000,1800,_nLin+1,2300)
oPrn:Line(3000,1800,_nLin+2,2300)

RestArea( aArea ) // Restaura a area atual
oPrn:Preview()
MS_FLUSH()
DBSELECTAREA("ZAPT")
dbclosearea("ZAPT")
Return

Static Function _fCabec(_cNome,_cProg,_cPagina)
	_cTime		:= 	time()
	_cDtaBase	:=	RIGHT(DTOS(DDATABASE),2)+"/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+LEFT(DTOS(DDATABASE),4)
	_cDtaRefe	:=	RIGHT(DTOS(DATE()),2)+"/"+SUBSTR(DTOS(DATE()),5,2)+"/"+LEFT(DTOS(DATE()),4)
	_nPos		:=	2300/3.5 - (len(_cNome)/2)
	  
	if file("\Adoro2.Bmp")
	   cBitMap:= "\Adoro2.Bmp"
	   oPrn:SayBitmap(0040,0025,cBitMap,240,150)
	endif	
	oPrn:Say(0115,0056,"Siga/"+_cProg+"/v.AP6 6.09"	,oFontA08,100)
	oPrn:Say(0160,0056,"Hora: "	+_cTime 			,oFontA08,100)//date()
	oPrn:Say(0100,_nPos,_cNome						,oFont16,100)
	oPrn:Say(0070,2000,"Folha.....: " 	+ _cPagina 	,oFontA08,100)//nPag
	oPrn:Say(0115,2000,"DT. Ref..: " 	+_cDtaBase 	,oFontA08,100)
	oPrn:Say(0160,2000,"Emissao: " 		+ _cDtaRefe	,oFontA08,100)
	oPrn:Line(0050,0030,0050,2300)
	oPrn:Line(0051,0030,0051,2300)
	oPrn:Line(0052,0030,0052,2300)
	oPrn:Line(0053,0030,0053,2300)

	oPrn:Line(0190,0030,0190,2300)
	oPrn:Line(0191,0030,0191,2300)
	oPrn:Line(0192,0030,0192,2300)
	oPrn:Line(0193,0030,0193,2300)

Return
