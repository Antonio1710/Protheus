#include "rwmake.ch"
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0089    º Autor ³ Gustavo Gonela     º Data ³  12/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio da posicao de entrega dos pedidos.               º±±
±±º          ³                                                            º±±
±±º          ³ Este relatorio atende a area comercial para se saber       º±±
±±º          ³ a posicao de entrega dos pedidos                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logistica / Comercial                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºManutencao³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AD0089()   

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio da posicao de entrega dos pedidos.')


Private cPerg := "AD0089"
Pergunte(cPerg,.T.)


SetPrvt("AAREA,LI,LCABEC,CNUMORC,ACONDICOES,AFORMAPGTO")
SetPrvt("LERROVEND,NFP,OBS,OBS1,")

Private oFont, cCode
nHeight:=15
lBold:= .F.
lUnderLine:= .F.
lPixel:= .T.
lPrint:= .T.
PRIVATE oFontA06:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
PRIVATE oFontA07:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
PRIVATE oPrn:=TMSPrinter():New()
_nItens:=0
_aLInha	:={}

//oFontA14:= TFont():New( "NOME DA FONTE",,TAMANHO,,BOLD,,,,?,SUBLINHADO ) // Primeiro .t. é sobre bold ou nao
//**********************************************//
//  mv_par01		:=	DATA DE      ?          //
//  mv_par02		:=	DATA ATE     ?          //
//  mv_par03        :=  VENDEDIR DE  ?          //
//  mv_par04        :=  VEBDEDOR ATE ?          //
//**********************************************//

aArea := GetArea()  // Grava a area atual

nPag:= 1
_nLin:= 680
_cNomerel	:=	"RELACAO DE ENTREGA DOS PEDIDOS DE VENDA"
_cNomePro	:= "AD0089"
_cData   := mv_par01
_cData2  := mv_par02
_nOK     := 0

_cCodVen := SPACE(6)
_cCodSup := SPACE(6)

_cUserName  := Subs(cUsuario,7,15)   // Nome do Usuario

dbSelectArea("SA3")
dbSetOrder(2)
If dbSeek(xFilial("SA3")+_cUserName)
	_cCodVen := SA3->A3_COD
	_nOK     := 1
Else
	dbSelectArea("SZR")
	dbSetOrder(2)
	If dbSeek(xFilial("SZR")+_cUserName)
		_cCodSup := SZR->ZR_CODIGO
		_nOK     := 2
	Else
		_nOK     := 3
	Endif
Endif


If _nOK = 1   // Se usuário for vendedor
	cQuery:= "SELECT  SC5.C5_NUM, SC5.C5_NOTA, SC5.C5_DTENTR, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_NOMECLI, "+;
	"SC5.C5_ROTEIRO, SC5.C5_SEQUENC , SF2.F2_EMISSAO ,SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_QTDVEN, SC6.C6_PRCVEN "+;
	"FROM "+retsqlname("SC5")+" SC5 ,"+retsqlname("SC6")+" SC6  ,"+retsqlname("SF2")+" SF2 "+;
	"WHERE SC5.C5_NUM = SC6.C6_NUM "+;
	"AND   SC5.C5_DTENTR = SC6.C6_ENTREG "+;
	"AND   SC5.C5_NOTA = SF2.F2_DOC "+;
	"AND   SC5.C5_TIPO = 'N' "+; // seleciona somente pedido normais
	"AND   SC5.C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "+;
	"AND   SC5.C5_VEND1 = '" +_cCodVen+"' "+;
	"AND   SC5.D_E_L_E_T_ <> '*' "+;
	"AND   SC6.D_E_L_E_T_ <> '*' "+;
	"AND   SF2.D_E_L_E_T_ <> '*' "+;
	"ORDER BY SC5.C5_DTENTR, SC5.C5_NUM, SC5.C5_ROTEIRO, SC5.C5_SEQUENC "
Else
	If _nOK = 2  // Se usuario for Supervisor 
		cQuery:= "SELECT  SC5.C5_NUM, SC5.C5_NOTA, SC5.C5_DTENTR, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_NOMECLI, "+;
		"SC5.C5_ROTEIRO, SC5.C5_SEQUENC , SF2.F2_EMISSAO ,SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SA3.A3_CODSUP "+;
		"FROM "+retsqlname("SC5")+" SC5 ,"+retsqlname("SC6")+" SC6  ,"+retsqlname("SF2")+" SF2 ,"+retsqlname("SA3")+" SA3 "+;
		"WHERE SC5.C5_NUM = SC6.C6_NUM "+;
		"AND   SC5.C5_DTENTR = SC6.C6_ENTREG "+;
		"AND   SC5.C5_NOTA = SF2.F2_DOC "+;
		"AND   SC5.C5_VEND1 = SA3.A3_COD "+;
		"AND   SC5.C5_TIPO = 'N' "+; // seleciona somente pedido normais
		"AND   SC5.C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "+;
		"AND   SA3.A3_CODSUP = '"+ _cCodSup +"' "+;
		"AND   SC5.D_E_L_E_T_ <> '*' "+;
		"AND   SC6.D_E_L_E_T_ <> '*' "+;
		"AND   SF2.D_E_L_E_T_ <> '*' "+;
		"AND   SA3.D_E_L_E_T_ <> '*' "+;
		"ORDER BY SC5.C5_DTENTR, SC5.C5_NUM, SC5.C5_ROTEIRO, SC5.C5_SEQUENC "
	Else
		If _nOK = 3  // Se usuario for diferente de Vendedor e Supervisor
			cQuery:= "SELECT  SC5.C5_NUM, SC5.C5_NOTA, SC5.C5_DTENTR, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_NOMECLI, "+;
			"SC5.C5_ROTEIRO, SC5.C5_SEQUENC , SF2.F2_EMISSAO ,SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_QTDVEN, SC6.C6_PRCVEN "+;
			"FROM "+retsqlname("SC5")+" SC5 ,"+retsqlname("SC6")+" SC6  ,"+retsqlname("SF2")+" SF2 "+;
			"WHERE SC5.C5_NUM = SC6.C6_NUM "+;
			"AND   SC5.C5_DTENTR = SC6.C6_ENTREG "+;
			"AND   SC5.C5_NOTA = SF2.F2_DOC "+;
			"AND   SC5.C5_TIPO = 'N' "+; // seleciona somente pedido normais
			"AND   SC5.C5_DTENTR BETWEEN '"+dtos(mv_par01)+"' and '"+dtos(mv_par02)+"' "+;
			"AND   SC5.C5_VEND1 BETWEEN '"+ mv_par03 +"' and '"+ mv_par04 +"' "+;
			"AND   SC5.D_E_L_E_T_ <> '*' "+;
			"AND   SC6.D_E_L_E_T_ <> '*' "+;
			"AND   SF2.D_E_L_E_T_ <> '*' "+;
			"ORDER BY SC5.C5_DTENTR, SC5.C5_NUM, SC5.C5_ROTEIRO, SC5.C5_SEQUENC "
		Endif
	Endif
Endif

TCQUERY cQuery new alias "ZC5"

_cPedAnt := space(6)

DbSelectArea("ZC5")
DbGotop()
//_cPed := C5_NUM
Do While !Eof()
	if nPag==1.or._nLinI>2800	&& Cabecalho
		if nPag<>1
			oPrn:Endpage()
			oPrn:Startpage()
		endif
		
		_cNPag	:=	STR(nPag)
		
		_fCabec(_cNomeRel,_cNomePro,_cNPag) // Cabecalho
		
		nPag += 1
		_nLinI	:=	400
		
	ENDIF
	//	oPrn:Line(0060,0190,2400,0190)
	If _cPedAnt <> C5_NUM  // Se pedido anterior for diferente do atual
		_nLinI	+=	50
		//               Linha,Coluna, Linha, Coluna
		oPrn:Box(_nLinI,0100,_nLinI+0080,2300) // Box 1
		oPrn:Box(_nLinI+0080,0100,_nLinI+0175,2300) // Box 2
		
		oPrn:Say(_nLinI+0030,0125,"No.Pedido :"+SPACE(2)+C5_NUM ,oFontA07,100) // Box1
		oPrn:Say(_nLinI+0030,0650,"Dt.Entrega :"+ RIGHT(ZC5->C5_DTENTR,2)+"/"+SUBSTR(ZC5->C5_DTENTR,5,2)+"/"+LEFT(ZC5->C5_DTENTR,4) ,oFontA06,100) // Box2
		oPrn:Say(_nLinI+0030,1300,"Cliente :"	+SPACE(2)+C5_CLIENTE+"/"+C5_LOJACLI+SPACE(2)+C5_NOMECLI   ,oFontA06,100) // Box3
		
		oPrn:Say(_nLinI+0105,0125,"Cod.Produto "	,oFontA06,100) // Box1
		oPrn:Say(_nLinI+0105,0380,"Descricao "	    ,oFontA06,100) // Box2
		oPrn:Say(_nLinI+0105,1300,"Qtd. "	        ,oFontA06,100) // Box3
		oPrn:Say(_nLinI+0105,1450,"Prc.Unit. "	    ,oFontA06,100) // Box4
		oPrn:Say(_nLinI+0105,1650,"Rot./Seq. "	    ,oFontA06,100) // Box5
		oPrn:Say(_nLinI+0105,1880,"No.Nota   "	    ,oFontA06,100) // Box6
		oPrn:Say(_nLinI+0105,2095,"Dt.Emissao "	    ,oFontA06,100) // Box7
		_cPedAnt := C5_NUM // igualando 
	Endif
	_nAdic	:=	180
	Do While !EOF().and. C5_NUM == _cPedAnt // enquanto pedido anterior for igual o atual
		AADD(_aLInha,{C6_PRODUTO,SUBSTR(C6_DESCRI,1,38),C6_QTDVEN,C6_PRCVEN,C5_ROTEIRO+"/"+C5_SEQUENC,C5_NOTA,RIGHT(F2_EMISSAO,2)+"/"+SUBSTR(F2_EMISSAO,5,2)+"/"+LEFT(F2_EMISSAO,4)})
		_nAdic += 50
		_nItens++
		DbSelectArea("ZC5")
		DbSkip()
	Enddo
	oPrn:Box(_nLinI+0150,0100,(_nLinI+(0070+_nAdic)),2300) // Box7
	_nAdic	:=	180
	For _nI	:=	1 to len(_aLinha) // Lendo e imprimindo o array
		oPrn:Say(_nLinI+_nAdic,0130,_aLInha[_nI][1]  ,oFontA06,100) // Box1
		oPrn:Say(_nLinI+_nAdic,0380,_aLInha[_nI][2]  ,oFontA06,100) // Box2
		oPrn:Say(_nLinI+_nAdic,1260,transform(_aLInha[_nI][3],"@E 9999,999")   ,oFontA06,100) // Box3
		oPrn:Say(_nLinI+_nAdic,1440,transform(_aLInha[_nI][4],"@E 999,999.99") ,oFontA06,100) // Box4
		oPrn:Say(_nLinI+_nAdic,1660,_aLInha[_nI][5]  ,oFontA06,100) // Box5
		oPrn:Say(_nLinI+_nAdic,1890,_aLInha[_nI][6]  ,oFontA06,100) // Box6
		oPrn:Say(_nLinI+_nAdic,2100,_aLInha[_nI][7]  ,oFontA06,100) // Box7
		_nAdic += 50
	Next
	_nLinI	+=	090 + _nAdic
	_aLInha	:={} // limpando o array
Enddo

RestArea( aArea ) // Restaura a area atual
oPrn:Preview()
MS_FLUSH()
DBSELECTAREA("ZC5")
dbclosearea("ZC5")
Return

Static Function _fCabec(_cNome,_cProg,_cPagina) // Funcao que monta o cabecalho
_cTime		:= 	time()
_cDtaBase	:=	RIGHT(DTOS(DDATABASE),2)+"/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+LEFT(DTOS(DDATABASE),4)
_cDtaRefe	:=	RIGHT(DTOS(DATE()),2)+"/"+SUBSTR(DTOS(DATE()),5,2)+"/"+LEFT(DTOS(DATE()),4)
_nPos		:=	2300/3 - (len(_cNome)/2)
_cData      := RIGHT(DTOS(mv_par01),2)+"/"+SUBSTR(DTOS(mv_par01),5,2)+"/"+LEFT(DTOS(mv_par01),4)
_cData2     := RIGHT(DTOS(mv_par02),2)+"/"+SUBSTR(DTOS(mv_par02),5,2)+"/"+LEFT(DTOS(mv_par02),4)

if file("\Adoro2.Bmp")
	cBitMap:= "\Adoro2.Bmp"
	oPrn:SayBitmap(0040,0025,cBitMap,240,150)
endif
oPrn:Say(0065,0056,"Siga/"+_cProg+"/v.AP6 6.09"	,oFontA06,100)
oPrn:Say(0110,0056,"Hora: "	+_cTime 			,oFontA06,100)//date()
oPrn:Say(0155,0056,"User: "	+_cUserName 		,oFontA06,100)//Usuário login
oPrn:Say(0100,_nPos,_cNome					,oFontA06,100)
oPrn:Say(0065,1950,"Folha.....: " 	+ _cPagina 	,oFontA06,100)//nPag
oPrn:Say(0110,1950,"DT. Ref..: " 	+ _cDtaBase ,oFontA06,100)
oPrn:Say(0155,1950,"Emissao: " 		+ _cDtaRefe	,oFontA06,100)
oPrn:Say(0220,0720,"Data de Entrega de : "+ _cData ,oFontA06,100)
oPrn:Say(0220,1290,"Ate: "+ _cData2	,oFontA06 ,100)
oPrn:Say(0280,0720,"Vendedor de :"+ mv_par03 ,oFontA06,100)
oPrn:Say(0280,1290,"Ate: "+ mv_par04	      ,oFontA06,100)


oPrn:Line(0050,0030,0050,2300)
oPrn:Line(0051,0030,0051,2300)
oPrn:Line(0052,0030,0052,2300)
oPrn:Line(0053,0030,0053,2300)

oPrn:Line(0200,0030,0200,2300)
oPrn:Line(0201,0030,0201,2300)
oPrn:Line(0202,0030,0202,2300)
oPrn:Line(0203,0030,0203,2300)
oPrn:Line(0335,0030,0335,2300)

Return

