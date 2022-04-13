#include "rwmake.ch"
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

//@history ticket 70750 - Everson - 07/04/2022 - Adaptação do fonte para nova filial.
User Function AD0082() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Resumo de Descontos e Acrescimos')

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
aCondicoes:= {}
aFormaPgto:= {}
_nLin:= 680

// Posiciona Arquivos                         

cQuery:= 	"SELECT ZV8_COD AS COD, ZV8_EST AS EST, ZV8_CIDADE AS CID, ZV8_KM AS KM,ZV9_DTVAL AS DT, "+;
			"ZV9_VLTON AS CAR, ZV9_VLTK AS TRK, ZV9_VLTC AS TOC "+;
			"FROM "+RetSqlName("ZV8")+ ", "+RetSqlName("ZV9")+ " "+;
			"WHERE ZV8_FILIAL = '" + FWxFilial("ZV8") + "' AND ZV9_FILIAL = '" + FWxFilial("ZV9") + "' AND ZV8_COD = ZV9_REGIAO "+; //ticket 70750 - Everson - 07/04/2022
			"ORDER BY COD, EST, DT DESC"
TCQUERY cQuery new alias "D2A"

DBSELECTAREA("D2A")
DBGOTOP()

_cEstado :=	D2A->COD       
_cTime		:= 	time()
_cDtaBase	:=	RIGHT(DTOS(DDATABASE),2)+"/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+LEFT(DTOS(DDATABASE),4)
_cDtaRefe	:=	RIGHT(DTOS(DATE()),2)+"/"+SUBSTR(DTOS(DATE()),5,2)+"/"+LEFT(DTOS(DATE()),4)
_cNome		:= "Tabela de Preco de Frete"
_cPos		:=	1800/2 - (len(_cNome)/2)
Do While !Eof()                                     
 	if nPag==1.or._nLin>3050	&& Cabecalho
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
		oPrn:Say(0115,0056,"Siga/AD0082/v.AP6 6.09" ,oFontA08,100)
		oPrn:Say(0160,0056,"Hora: "+_cTime ,oFontA08,100)//date()
		oPrn:Say(0100,_cPos,_cNome,oFont16,100)
		oPrn:Say(0070,2000,"Folha.....: " + _cNPag ,oFontA08,100)//nPag
		oPrn:Say(0115,2000,"DT. Ref..: " +_cDtaBase ,oFontA08,100)
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
		oPrn:Say(0425,0075,"Codigo",oFontA09,200)
		oPrn:Say(0425,0210,"Estado",oFontA09,100)
		oPrn:Say(0425,0360,"Cidade",oFontA09,100)
		oPrn:Say(0425,1124,"KM",oFontA09,100)
		oPrn:Say(0425,1323,"Validade de",oFontA09,100)
		oPrn:Say(0425,1577,"Valor Carreta",oFontA09,100)
		oPrn:Say(0425,1827,"Valor Truck",oFontA09,100)
		oPrn:Say(0425,2076,"Valor Toco",oFontA09,100)
		oPrn:Box(0512,0065,3080,0200)
		oPrn:Box(0512,0200,3080,0350)
		oPrn:Box(0512,0350,3080,1114)
		oPrn:Box(0512,1114,3080,1290)
		oPrn:Box(0512,1313,3080,1540)
		oPrn:Box(0512,1567,3080,1817)
		oPrn:Box(0512,1817,3080,2066)
		oPrn:Box(0512,2066,3080,2316)
		_nLin = 0512
		nPag+= 1 
	Endif
	If D2A->DT > DTOS(DDATABASE) 
		DbSelectArea("D2A")
		DBSKIP()
		LOOP
	Endif	
		_cData	:=	substr(D2A->DT,7,2)+"/"+substr(D2A->DT,5,2)+"/"+ substr(D2A->DT,1,4)

		oPrn:Say(_nLin,0075,D2A->COD,oFontA09,100)
		oPrn:Say(_nLin,0220,D2A->EST,oFontA09,100)
		oPrn:Say(_nLin,0370,LEFT(D2A->CID,30),oFontA08,100)
		oPrn:Say(_nLin,1130,D2A->KM,oFontA09,100)

		oPrn:Say(_nLin,1335,_cData,oFontA09,100)
		oPrn:Say(_nLin,1590,transform(D2A->CAR,"@E 9999,999.99") ,oFontA09,100)
		oPrn:Say(_nLin,1840,transform(D2A->TRK,"@E 9999,999.99") ,oFontA09,100)
		oPrn:Say(_nLin,2090,transform(D2A->TOC,"@E 9999,999.99") ,oFontA09,100)
        Do while _cEstado	==	D2A->COD
			DbSelectArea("D2A")
			DBSKIP()
		Enddo
		
		_cEstado	:=	D2A->COD
		_nLIn +=45

Enddo
RestArea( aArea ) // Restaura a area atual
oPrn:Preview()
MS_FLUSH()
DBSELECTAREA("D2A")
dbclosearea("D2A")

Return
