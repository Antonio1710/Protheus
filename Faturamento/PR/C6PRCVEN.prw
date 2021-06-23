#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C6PRCVENº Autor ³Mauricio - MDS TEC   º Data ³  28/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validações customizadas para campo C6_PRCVEN. Para atender º±±
±±º          ³ necessidade comercial quando de corte de pedido de venda.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro - Area Comercial(Sr. Vagner)                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
User Function C6PRCVEN()

Local nSegUM	:= &(ReadVar())
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nQtdConv  := 0
Local lGrade    := MaGrade()
Local cProduto  := ""
Local cItem	    := ""
local _lRet     := .T.
Local _cUsuCod  := GetMV("MV_#USUTPR")
Local _cVend    := M->C5_VEND1

_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cVend,"A3_CODSUP")
_cSupUsu    := Posicione("SA3",1,xFilial("SA3")+_cVend,"A3_SUPER")
_cCodUs     := Posicione("SA3",1,xFilial("SA3")+_cSupUsu,"A3_CODUSR")  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validações customizadas para campo C6_PRCVEN. Para atender necessidade comercial quando de corte de pedido de venda.')

If (ALTERA .And. (__cUserID $ _cUsuCod)) .OR. (ALTERA .And. (__cUserID == _cCodUs))  &&se usuarios do comercial contidos no parametro, faz validação customizada(não zerar campo preço unitario).
                                        &&somente na alteração.
   If ( nSegUm != cCampo )
	  cProduto := aCols[n][nPProduto]
	  cItem	   := aCols[n][nPItem]
	  If ( lGrade )
		  MatGrdPrrf(@cProduto)
	  EndIf
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³Posiciona no Item atual do Pedido de Venda                              ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  dbSelectArea("SC6")
	  dbSetOrder(1)
	  MsSeek(xFilial("SC6")+M->C5_NUM+cItem+cProduto)
	
	  nQtdConv  := Round( ConvUm(cProduto,aCols[n,nPQtdVen],nSegUm,1), TamSX3( "C6_QTDVEN" )[2] )
	  //_lRet := A410MultT("C6_QTDVEN",nQtdConv)   
	
	  If _lRet
		 aCols[n,nPQtdVen] := nQtdConv
	
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Nao aceita qtde. inferior `a qtde ja' faturada               ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 SC6->(dbEval({|| _lRet := If(aCols[n,nPQtdVen] < SC6->C6_QTDENT,.F.,_lRet)},Nil,;
			 {|| 	xFilial("SC6")	==	SC6->C6_FILIAL 	.And.;
			 M->C5_NUM		==	SC6->C6_NUM			.And.;
			 cItem				== SC6->C6_ITEM		.And.;
			 cProduto			== SC6->C6_PRODUTO },Nil,Nil,.T.))
	
		 If ( !_lRet )
			 Help(" ",1,"A410PEDJFT")
		 EndIf
    
	  Endif

   Else
	  _lRet := .T.
   EndIf
Else &&Se não é alteração e usuario é normal(fora do parametro) faz a validação padrão
   _lRet := A410Quant()
Endif   
   
Return(_lRet)