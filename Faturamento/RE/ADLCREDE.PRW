#include "rwmake.ch"
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLCREDE  ºAutor  ³Microsiga           º Data ³  12/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Listagem Consolidada do Limite de Credito por Rede         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADLCREDE() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Listagem Consolidada do Limite de Credito por Rede')
 
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
oFontA07:= TFont():New( "Arial",,07,,.T.,,,,,.f. )
oFontA08:= TFont():New( "Arial",,08,,.t.,,,,,.f. )
oFontA09:= TFont():New( "Arial",,09,,.t.,,,,,.f. )
oFontA10:= TFont():New( "Arial",,10,,.t.,,,,,.f. )
oFontA11:= TFont():New( "Arial",,11,,.t.,,,,,.f. )
oFontA12:= TFont():New( "Arial",,12,,.t.,,,,,.f. ) 
oFontA14:= TFont():New( "Arial",,14,,.t.,,,,,.T.) 
oPrn:=TMSPrinter():New() 
//oFontA14:= TFont():New( "NOME DA FONTE",,TAMANHO,,BOLD,,,,?,SUBLINHADO ) // Primeiro .t. é sobre bold ou nao

aArea := GetArea()  // Grava a area atual
	
nPag:= 1
_nLin:= 680

/*/ Posiciona Arquivos                         
cQuery:= 	"SELECT ZV8_COD AS COD, ZV8_EST AS EST, ZV8_CIDADE AS CID, ZV8_KM AS KM,ZV9_DTVAL AS DT, "+;
			"ZV9_VLTON AS CAR, ZV9_VLTK AS TRK, ZV9_VLTC AS TOC "+;
			"FROM ZV8010, ZV9010 "+;
			"WHERE ZV8_COD = ZV9_REGIAO "+;
			"ORDER BY COD, EST, DT DESC"
/*/			
cQuery := "SELECT ZF_REDE, ZF_NOMEREDE, ZF_CGCMAT, ZF_LCREDE, ZF_SLDREDE FROM : "+RetSqlName("SZF")+ " " +;
          "ORDER BY ZF_REDE, ZF_NOMEREDE"

TCQUERY cQuery new alias "D2A"

DBSELECTAREA("D2A")
DBGOTOP()

_cDtaBase	:=	RIGHT(DTOS(DDATABASE),2)+"/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+LEFT(DTOS(DDATABASE),4)
_cNome		:= "Consolidado Limite de Credito de Redes"
_cPos		:=	1800/2 - (len(_cNome)/2)
Do While !Eof()                                     
 	if nPag == 1 .or. _nLin > 3050	&& Cabecalho
		if nPag<>1
			oPrn:Endpage()
			oPrn:Startpage()

		endif
		_cNPag	:=	STR(nPag)
		//Imprime Cabecalho
//		oPrn:Say(0050,0100,"Adoro2",oFont20,100)
		// Logotipo
		if file("\Adoro2.Bmp")
		   cBitMap:= "\Adoro2.Bmp"
		   oPrn:SayBitmap(0040,0025,cBitMap,240,150)
		endif	
		oPrn:Say(0115,0056,"Siga/ADLCREDE/v.AP8 8.11" ,oFontA08,100)
		oPrn:Say(0100,_cPos,_cNome,oFont16,100)
		oPrn:Say(0070,2000,"Folha.....: " + _cNPag ,oFontA08,100)//nPag
		oPrn:Say(0160,2000,"Emissao: " + _cDtaRefe,oFontA08,100)
		
		//Imprime as linhas
		oPrn:Line(0050,0060,0050,2300)
		oPrn:Line(0051,0060,0051,2300)
		oPrn:Line(0052,0060,0052,2300)
		oPrn:Line(0053,0060,0053,2300)
		oPrn:Line(0200,0060,0200,2300)
		oPrn:Line(0201,0060,0201,2300)
		oPrn:Line(0202,0060,0202,2300)
		oPrn:Line(0203,0060,0203,2300)
		oPrn:Line(0214,0060,0214,2300)
		
		//Imprime as caixas
		oPrn:Box(0415,0065,0485,0200)
		oPrn:Box(0415,0200,0485,0350)
		oPrn:Box(0415,0350,0485,1114)
		oPrn:Box(0415,1114,0485,1290)
		oPrn:Box(0415,1313,0485,1540)
		oPrn:Box(0415,1567,0485,1817)
		oPrn:Box(0415,1817,0485,2066)
		oPrn:Box(0415,2066,0485,2316)
		oPrn:Say(0425,0075,"REDE",oFontA09,200)
		oPrn:Say(0425,0210,"NOME DA REDE",oFontA09,100)
		oPrn:Say(0425,0360,"CGC",oFontA09,100)
		oPrn:Say(0425,1124,"LIMITE CREDITO",oFontA09,100)
		oPrn:Say(0425,1323,"SALDO EM ABERTO",oFontA09,100)
		oPrn:Box(0512,0065,3080,0200)
		oPrn:Box(0512,0200,3080,0350)
		oPrn:Box(0512,0350,3080,1114)
		oPrn:Box(0512,1114,3080,1290)
		oPrn:Box(0512,1313,3080,1540)
		oPrn:Box(0512,1567,3080,1817)
		oPrn:Box(0512,1817,3080,2066)
		oPrn:Box(0512,2066,3080,2316)
		_nLin = 0512
		nPag += 1 
	Endif

	oPrn:Say(_nLin,0075,D2A->ZF_REDE,oFontA09,100)
	oPrn:Say(_nLin,0220,D2A->ZF_NOMEREDE,oFontA09,100)
	oPrn:Say(_nLin,0370,D2A->ZF_CGCMAT,oFontA09,100)
	oPrn:Say(_nLin,0800,transform(D2A->ZF_LCREDE ,"@E 9,999,999.99") ,oFontA09,100)
	oPrn:Say(_nLin,1200,transform(D2A->ZF_SLDCRED,"@E 9,999,999.99") ,oFontA09,100)
	
	DbSelectArea("D2A")
	DBSKIP()
		_nLIn += 1

Enddo
RestArea( aArea ) // Restaura a area atual
oPrn:Preview()
MS_FLUSH()
DBSELECTAREA("D2A")
dbclosearea("D2A")

Return