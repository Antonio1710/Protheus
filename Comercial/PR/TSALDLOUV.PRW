#INCLUDE "rwmake.ch"
#Include "PROTHEUS.CH"
#Include "topconn.CH" 
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TSALDLOUV บ Autor ณ Mauricio-MDS TEC   บ Data ณ 24/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tela para trazer os produtos de todos os pedidos de venda  บฑฑ
ฑฑบ          ณ da filial Louveira e seus saldos/quantidades(p/DT.Entrega) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Adoro                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
                     
User Function TSALDLOUV()
PRIVATE O_DIALOG       := NIL

Private _nTotalPedi := 0,_nTotalCx := 0,_nTotalKg := 0,_nTotalBr := 0
Private _nOpca			:= 00     
Private _cProduto   := SPACE(15)
Private _cDescri    := ""
Private _dVcD   := CTOD("  /  /  ")
Private _dVcA   := CTOD("  /  /  ") 
Private _cProd  := Space(15)
Private _cDesc  := Space(40)
//Private _cSupD  := "      "
//Private _cSupA  := "ZZZZZZ"
Private _nOrd   := 000
Private _cCli   := Space(06)
Private _cSupv  := Space(06)
Private _cLoj   := Space(02)
Private _cRaz   := Space(20)
Private _cPed   := Space(06)
Private _cIte   := Space(02)
Private _dDT   := CTOD("  /  /  ")
Private _nQtdP   := 0.0000
Private _nQtdS   := 0.0000
Private _nQtdE   := 0.0000
Private _nQtdR   := 0.0000
Private _nQtdD   := 0.0000
Private _nQtdO   := 0.0000
Private _nQtdC   := 0.0000
Private _aPedido	:= {}
Private oCabD4
Private lLiber	 := .F.
Private	lTrans	 := .F.
Private	lCredito := .F.
Private	lEstoque := .F.
Private	lAvCred	 := .T.
Private	lAvEst	 := .F.
Private _lUsuADMV := .F.
Private _cSupVends := ""
Static oDgl
  
&&Mauricio - 15/07/14 - incluido tratamento para rotina ser utilizada por supervisores e neste caso eles s๓ podem ver os dados/pedidos relativos a eles proprios.
&&Neste caso nem vou disponibilizar na dialog abaixo os parametros para escoha do supervisor De/At้.
&&Aqui sera preciso ver se o usuario ้ ADM VENDAS ou Supervisor(unicos que poderใo utilizar a tela).

_cCodUs := __cUserID
_lRoda  := .F. 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para trazer os produtos de todos os pedidos de venda da filial Louveira e seus saldos/quantidades(p/DT.Entrega)')

If _cCodUs $ GETMV("MV_#USUTPR")   &&usuarios cadastrados como  ADM VENDAS(rotinas liberadas
   _lUsuADMV := .T.
   _lRoda := .T.
Endif

IF !_lRoda
   MsgInfo("Usuario sem acesso a rotina!", "Aten็ใo")
   Return()
Endif	  		 
                  
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Consulta Saldos produtos Filial Louveira") FROM 115,085  TO 850,1300 COLORS 0, 16777215 PIXEL   // 115,085  TO 650,1350

&&Borda Interna da Dialog
@ 002, 002 GROUP oGroup1 TO 335, 610 PROMPT "" OF oDlg COLOR 0, 16777215 PIXEL     //002, 002 TO 265, 632
   
&&vinculo objeto a uma variavel
O_DIALOG := oDlg
&&nใo via ter um produto..vใo ser todos no periodo De/Ate....
//@ 010,008 Say OemToAnsi('Produto: ')   OF oDlg COLORS 0, 16777215 PIXEL
//If _lUsuADMV 
//   @ 010,220 Say OemToAnsi('Supervisor De: ')   OF oDlg COLORS 0, 16777215 PIXEL
//   @ 010,350 Say OemToAnsi('Supervisor Ate: ')   OF oDlg COLORS 0, 16777215 PIXEL
//Endif   
@ 025,008 Say OemToAnsi('DT.Entrega De: ') OF oDlg COLORS 0, 16777215 PIXEL
@ 025,110 Say OemToAnsi('DT.Entrega Ate: ') OF oDlg COLORS 0, 16777215 PIXEL								               

//@ 010,060 MsGet _cProduto          				PICTURE "@!" F3 "SB1" SIZE 045,10 OF oDlg  PIXEL
//@ 010,130 Say   fDesc(_cProduto) OF oDlg PIXEL                 //OF oDlg PIXEL
//If _lUsuADMV
//   @ 010,282 MsGet _cSupD          				PICTURE "@!" F3 "A06" SIZE 045,10 OF oDlg  PIXEL
//   @ 010,402 MsGet _cSupA          				PICTURE "@!" F3 "A06" SIZE 045,10 OF oDlg  PIXEL
//Endif   
@ 025,060 MsGet _dVcD      			            SIZE 045,10 OF oDlg PIXEL
@ 025,150 MsGet _dVcA      			            SIZE 045,10 OF oDlg PIXEL
 
//@ 045,008 Say OemToAnsi('Qtd Pedidos: ')   OF oDlg COLORS 0, 16777215 PIXEL
//@ 045,050 Say _nTTtotPd  SIZE 30,10 OF oDlg PIXEL                                 
//@ 045,170 Say OemToAnsi('TOT CXS ORIG: ') OF oDlg COLORS 0, 16777215 PIXEL
//@ 045,230 Say _nTTCxOri  SIZE 35,10 OF oDlg PIXEL  
//@ 045,290 Say OemToAnsi('TOT CXS APOS AJUST: ') OF oDlg COLORS 0, 16777215 PIXEL
//@ 045,370 Say _nTTCxFim  SIZE 35,10 OF oDlg PIXEL
//@ 045,420 Say OemToAnsi('Ajuste Feito CXS: ') OF oDlg COLORS 0, 16777215 PIXEL
//@ 045,480 Say _nTTCxAju  SIZE 30,10 OF oDlg PIXEL		

@ 025,290 BUTTON "Busca Produtos" SIZE 040,010 ACTION(AtulistBox(@_aPedido,2)) OF oDlg PIXEL 
//@ 025,370 BUTTON "Simular" SIZE 050,010 ACTION(fCalc()) OF oDlg PIXEL
//@ 025,440 BUTTON "Efetua CORTE" SIZE 050,010 ACTION(fCorte()) OF oDlg PIXEL 

&&Mauricio - confirmado com vagner que o saldo a ser trazido em tela eh sempre em CAIXAS.....
&&Trazer todos os produtos com a data de entrega dentro do periodo a ser passado na tela para a filial Louveira, ainda nใo faturados..
&&para valores trazer por produto....Quantidade total em pedidos, SALDO EM ESTOQUE(filial 07),saldo empenhado(filial 07)...

aHeaderT := {}

AAdd(aHeaderT,{"Produto"                   ,"_cProd"    ,"",015,0 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
AAdd(aHeaderT,{"Descri็ใo"                 ,"_cDesc"    ,"",040,0 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
AAdd(aHeaderT,{"Saldo Estoque Cx/BI"             ,"_nQtdS"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
AAdd(aHeaderT,{"Qtd Pedido Cx/BI"       ,"_nQtdP"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
//AAdd(aHeaderT,{"Qtd Pedidos Sistema"       ,"_nQtdE"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
//AAdd(aHeaderT,{"Saldo Estoque"             ,"_nQtdS"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
//AAdd(aHeaderT,{"Qtd Reservada Sistema"     ,"_nQtdR"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
//AAdd(aHeaderT,{"Qtd Empenhada diversos"    ,"_nQtdO"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
//AAdd(aHeaderT,{"Saldo Disponivel Sistema"  ,"_nQtdD"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})
AAdd(aHeaderT,{"Saldo Disponivel Cx/BI"   ,"_nQtdC"    ,"",12,4 ,"" ,"๛" ,"C",""," ","",,,"A",,,})

MsAguarde( {|| AtuListBox( @_aPedido,1) }, OemToAnsi( "Aguarde...." ) )

oCabD4 :=MsNewGetDados():New( 060,007,250,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,350,600
oCabD4:oBrowse:Refresh()
//MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)  

@ 025,550 BUTTON "Sair" SIZE 030,010 ACTION(RECBCD()) OF oDlg PIXEL

ACTIVATE DIALOG ODLG CENTERED

RETURN()

STATIC FUNCTION RECBCD()	
CLOSE(O_DIALOG)				
RETURN (.T.)
	
Static Function AtuListBox( _aPedido,_nOp)   
If (Empty(_dVcA) .Or. Empty(_dVcD)) .Or. _nOp == 1
   _aPedido := {}
   If Len(_aPedido) <= 00
	  AADD(_aPedido,{"","",Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.})	 
   EndIf
   oDlg:Refresh()   
Else 
   
   _nTCXPEDR := 0.0000
   _nTCXPEDS := 0.0000
   _nTCXSLDS := 0.0000
   _nTCXSLDC := 0.0000
   _nTCXEMP  := 0.0000
   _nTCXRES  := 0.0000
   _aPedido := {}   
   _aDados  := {}
          
   If Select("TSC6") > 0
      DbSelectArea("TSC6")
      DbCloseArea("TSC6")
   Endif
                   
   _cQuery  := "SELECT * "
   _cQuery  += "FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5 " 
   _cQuery  += "WHERE C5.D_E_L_E_T_ <> '*'  AND C6.D_E_L_E_T_ <> '*' "   
   _cQuery  += "AND C6.C6_ENTREG >= '"+DTOS(_dVcD)+"' AND C6.C6_ENTREG <= '"+DTOS(_dVcA)+"' "
   _cQuery  += "AND C6.C6_NUM = C5.C5_NUM AND C6.C6_FILIAL = '07' AND C5.C5_FILIAL = '07' AND "
   _cQuery  += "(C6.C6_NOTA = '         ' OR ((C6.C6_QTDENT < C6.C6_QTDVEN) AND C6.C6_NOTA <> '         ')) "
   _cQuery  += "AND C6.C6_LOCAL = '40' AND C5.C5_TIPO = 'N' "  
   _cQuery  += "ORDER BY C6.C6_PRODUTO"
          
   TCQUERY _cQuery NEW ALIAS "TSC6"
                 
   DbSelectArea("TSC6")
   DbGoTop()
   While TSC6->(!Eof())   &&apurando quantidade pendente em pedidos(nใo importa estar liberado ou nใo)
         _cProduto := TSC6->C6_PRODUTO
         _cDescric := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC")
         _nTCXPEDR := 0         
         While TSC6->(!Eof()) .And. TSC6->C6_PRODUTO == _cProduto
               If Empty(TSC6->C6_NOTA)
                  _nTCXPEDR += TSC6->C6_UNSVEN
               Else
                  _nTCXPEDR += TSC6->C6_UNSVEN - TSC6->C6_QTDENT2
               ENDIF                 
               TSC6->(dbSkip())
         Enddo         
         AADD(_aDados,{_cProduto,_nTCXPEDR,0,0,0,0,_cDescric} )                                                                                           
   Enddo
   
   &&Saldo em estoque... conforme visto com Valeria e Vagner o LOCAL DEVE SER SEMPRE O 40.....
   for _nz := 1 to len(_aDados)
       dbSelectArea("SB2")
       dbSetOrder(1)
       if dbseek("07"+_aDados[_nz][1]+"40")
          //_nAscan := Ascan( _aDados, { |x|x[ 01 ] == _aDados[_nz][1] } )
          //_aDados[ _nAscan ][ 02 ] := SB2->B2_QTSEGUM 
          _aDados[_nz ][ 03 ] += SB2->B2_QPEDVE2   
          _aDados[_nz ][ 04 ] += SB2->B2_QTSEGUM    
          _aDados[_nz ][ 05 ] += SB2->B2_RESERV2
          _aDados[_nz ][ 06 ] += SB2->B2_QEMP2
       Endif             
   Next _nz
  
   For _nz := 1 to len(_aDados)
       AADD(_aPedido,{_aDados[_nz][1],_aDados[_nz][7],Transform(_aDados[_nz][4],"@E 999,999,999.99"),Transform(_aDados[_nz][2],"@E 999,999,999.99"),;       
       Transform((_aDados[_nz][4]-_aDados[_nz][2]),"@E 999,999,999.99"),.F.})   
   next _nz
     
   If Len(_aPedido) <= 00
	  AADD(_aPedido,{"","",Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),.F.}) 
   EndIf
    
   oCabD4 :=MsNewGetDados():New( 060,007,250,600,GD_UPDATE,"AllwaysTrue",,"",,,10,,,"AllwaysTrue",oDlg,aHeaderT,@_aPedido)      //060,007,350,600
   oCabD4:oBrowse:Refresh()
   oCabD4:GoBottom()
   oCabD4:GoTop()  
   oCabD4:Refresh(.T.)
   oDlg:Refresh()
   GetdRefresh()
   SysRefresh()
Endif

Return (Nil)