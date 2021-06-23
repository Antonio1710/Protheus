#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
                  
/*           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CLASCLI2ºAutor  ³Mauricio - MDS TEC   º Data ³  08/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina desenvolvida para nova classificacao dos clientes   º±±
±±º          ³ Considerando media por NF e por IPCT(Inf. Vagner comercial)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CLASCLI2()

Local lRet 	 := .F.

Private dDtIni := CTOD("  /  /  ")
Private dDtFim := CTOD("  /  /  ")
Private dDtMtIn := CTOD("  /  /  ")
Private dDtMtFi := CTOD("  /  /  ")
Private oDlg01
Private oFont1
Private _nRFPRC := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida para nova classificacao dos clientes Considerando media por NF e por IPCT(Inf. Vagner comercial)')

Define msDialog oDlg01 From 00,00 To 290,370 Title "Classsificação de Clientes" Pixel &&145
Define Font oFont1 Name "Arial" Size 0,-14 Bold
Define Font oFont2 Name "Arial" Size 0,14 Bold
@005,005 To 045,180 of oDlg01 Pixel
@010,020 Say "Este programa ira classificar os clientes em" Font oFont1 of oDlg01 Pixel
@020,020 Say "categorias conforme media sobre as NFs e " Font oFont1 of oDlg01 Pixel
@030,020 Say "por IPCT."	Font oFont1 of oDlg01 Pixel
@050,005 Say "Ultima Execucao: "+Traz_C()	Font oFont2 of oDlg01 Pixel
@080,020 say "Data Inicial:"	SIZE 030,007 OF oDlg01 PIXEL
@080,070 MSGet oArq1 VAR dDtIni Size 050,007 OF oDlg01 PIXEL
@090,020 SAY "Data Final:"   	SIZE 030,007 OF oDlg01 PIXEL
@090,070 MSGet oArq2 VAR dDTFim Size 050,007 OF oDlg01 PIXEL
@100,020 say "Data Meta Inicio:"	SIZE 050,007 OF oDlg01 PIXEL
@100,070 MSGet oArq1 VAR dDtMtIn Size 050,007 OF oDlg01 PIXEL
@110,020 SAY "Data Meta Fim:"   	SIZE 050,007 OF oDlg01 PIXEL
@110,070 MSGet oArq2 VAR dDtMtFi Size 050,007 OF oDlg01 PIXEL

@125,115 BmpButton Type 1 Action(lRet := .T.,Close(oDlg01))
@125,150 BmpButton Type 2 Action(lRet := .F.,Close(oDlg01))
Activate Dialog oDlg01 Centered

If lRet
   If MsgYesNo(OemToAnsi("Confirma inicio da reclassificação dos Clientes?"),OemToAnsi("A T E N Ç Ã O"))
    	Processa({|| AnPedCli()},OemToAnsi("Classificando os clientes..."))	
   EndIf
Endif   

Return(lRet)

Static Function AnPedCli()

Local cQuery := ""
Local _cRede := "",_cCliente := ""
Local _cFaixa := ""

ProcRegua(RecCount())  

&&limpo o campo de classificacao antes para poder tratar os clientes que não tiveram pedido no periodo.
_cQuery := " UPDATE "+RetSqlName("SA1")+" WITH(UPDLOCK) SET A1_CLASCLI = '  ' "
_cQuery += " FROM "+RetSqlName("SA1")+" "		
_cQuery += " WHERE "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "
TCSQLExec(_cQuery)

&&Separo em duas querys para trazer em uma os pedidos cliente varejo e em outra clientes Rede.
&&Primeiro os clientes varejo
IF SELECT("TOTV") > 0
   DbSelectArea("TOTV")
   DbCloseArea("TOTV")
Endif
  
cQuery := "SELECT C5_CLIENTE+C5_LOJACLI AS CLIENTE, COUNT(DISTINCT C5_NOTA) AS TOTPED, SUM(C6_UNSVEN) AS TOTCXS "
cQuery += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK), "+RetSqlName("SC6")+" SC6 WITH (NOLOCK)"
cQuery += "WHERE C5_XREDE <> 'S' AND C5_TIPO = 'N' AND "
cQuery += "      SC5.C5_EMISSAO BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_NOTA <> '' AND "
cQuery += "      SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL AND"
cQuery += "      SC5.D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' '"
cQuery += "GROUP BY C5_CLIENTE+C5_LOJACLI "
cQuery += "ORDER BY C5_CLIENTE+C5_LOJACLI "

TCQUERY cQuery NEW ALIAS "TOTV"

dbSelectArea("TOTV")
dbGoTop()

While TOTV->(!Eof())
     
      IncProc(" VAREJO : "+TOTV->CLIENTE )
      
      _cCliente := TOTV->CLIENTE
      _nQtdPed  := TOTV->TOTPED  &&Total de pedidos
      _nQTDCxs  := TOTV->TOTCXS  &&total de caixas
      _nTotalCx := _nQTDCxs/_nQtdPed  &&media pedido por cliente varejo
      
      &&Busca Faixa
      dbSelectArea("ZZX")
	  dbSetOrder(1)
	  dbGoTop()
				
	  While ZZX->(!Eof())
			If _nTotalCx > ZZX->ZZX_VOLINI .And. _nTotalCx <= ZZX->ZZX_VOLFIM			  
			   _cFaixa := Alltrim(ZZX->ZZX_FAXPED)+" "
			   Exit
			EndIf
			ZZX->(dbSkip())
	  EndDo
      /*
      If _ntotalCx <= 8
         _cfaixa := "A "         			
	  Elseif _nTotalCx > 8 .And. _nTotalCx <= 15			  
		 _cFaixa := "B "
	  Elseif _nTotalCx > 15 .And. _nTotalCx <= 25			  
		 _cFaixa := "C "
	  Elseif _nTotalCx > 25 .And. _nTotalCx <= 50			  
		 _cFaixa := "D "
	  Elseif _nTotalCx > 50 .And. _nTotalCx <= 150			  
		 _cFaixa := "E "
	  Elseif _nTotalCx > 150		  
		 _cFaixa := "F " 	 	 
	  Endif	  
	  */	  
	  DbSelectArea("SA1")
	  dbSetOrder(1)
	  If dbseek(xFilial("SA1")+_cCliente)
	     Reclock("SA1",.F.)
	        SA1->A1_CLASCLI := _cFaixa 		
		 MsUnlock()	
	  Endif					
	  DbselectArea("TOTV")
      TOTV->(dbSkip())
Enddo      

DbCloseArea("TOTV")

&&Query para clientes REDE
IF SELECT("TOTR") > 0
   DbSelectArea("TOTR")
   DbCloseArea("TOTR")
Endif
                                
cQuery := "SELECT C5_CODRED AS REDE, COUNT(DISTINCT C5_NOTA) AS TOTPED, SUM(C6_UNSVEN) AS TOTCXS "
cQuery += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK), "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
cQuery += "WHERE C5_XREDE = 'S' AND C5_TIPO = 'N' AND "
cQuery += "      SC5.C5_EMISSAO BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"' AND SC5.C5_NOTA <> '' AND "
cQuery += "      SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL AND"
cQuery += "      SC5.D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY C5_CODRED "
cQuery += "ORDER BY C5_CODRED "

TCQUERY cQuery NEW ALIAS "TOTR"
dbSelectArea("TOTR")
dbGoTop()

While TOTR->(!Eof())
     
      IncProc(" REDE : "+TOTR->REDE )
      
      _cRede    := TOTR->REDE
      _nQtdPed  := TOTR->TOTPED  &&Total de pedidos
      _nQTDCxs  := TOTR->TOTCXS  &&total de caixas
      _nTotalCx := _nQTDCxs/_nQtdPed  &&media pedido por cliente rede
            			
	  &&Busca Faixa
	  dbSelectArea("ZZX")
	  dbSetOrder(1)
	  dbGoTop()
				
	  While ZZX->(!Eof())
			If _nTotalCx > ZZX->ZZX_VOLINI .And. _nTotalCx <= ZZX->ZZX_VOLFIM			  
			   _cFaixa := Alltrim(ZZX->ZZX_FAXPED)+" "
			   Exit
			EndIf
			ZZX->(dbSkip())
	  EndDo
	  /*
      If _ntotalCx <= 8
         _cfaixa := "A "         			
	  Elseif _nTotalCx > 8 .And. _nTotalCx <= 15			  
		 _cFaixa := "B "
	  Elseif _nTotalCx > 15 .And. _nTotalCx <= 25			  
		 _cFaixa := "C "
	  Elseif _nTotalCx > 25 .And. _nTotalCx <= 50			  
		 _cFaixa := "D "
	  Elseif _nTotalCx > 50 .And. _nTotalCx <= 150			  
		 _cFaixa := "E "
	  Elseif _nTotalCx > 150		  
		 _cFaixa := "F " 	 	 
	  Endif
	  */
	  
	  _cQuery := " UPDATE "+RetSqlName("SA1")+" WITH(UPDLOCK) SET A1_CLASCLI = '"+_cFaixa+"' "
	  _cQuery += " FROM "+RetSqlName("SA1")+" "		
	  _cQuery += " WHERE A1_REDE = '"+_cRede+"' "
	  _cQuery += " AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "	 
	  TCSQLExec(_cQuery)
	  	  
	  DbselectArea("TOTR")
      TOTR->(dbSkip())
Enddo

&&Tratamento para indice IPCT. Conforme vagner calculo e  trecho abaixo vem do relatorio AD0027V, para não gerar diferença.
&&Tratamento para cliente varejo
aStru := {}
AADD (aStru,{"T2_CLIENTE"  	, "C",06,0})		// GUARDA CODIGO DO CLIENTE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_CODGRUP" 	, "C",04,0})	  	// CODIGO DO GRUPO (NETO)
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// REALIZADO PRECO DO SUPERVISOR
AADD (aStru,{"T2_RF_PRC"   	, "N",12,4})		// REFERENCIA 
AADD (aStru,{"T2_EMISSAO"	, "D",08,0})	   	// DATA DE EMISSAO

IF SELECT("TEM2") > 0
   DbSelectArea("TEM2")
   DbCloseArea("TEM2")
Endif

_cNomTr2 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr2,"TEM2",.F.,.F.)
cIndex   := "T2_CLIENTE + T2_LOJA + T2_CODGRUP + dtos(T2_EMISSAO)"
IndRegua( "TEM2", _cNomTr2, cIndex,,,"Criando Indice ..." )

dbSelectArea("SB1") // PRODUTOS
dbSetOrder(1)

dbSelectArea("SBM")  // GRUPO DE PRODUTOS
dbSetOrder(1)

&&Varejo A1_REDE = vazio
&&"where F2_FILIAL IN ("+ALLTRIM(MV_PAR05)+") and "+;
cQuery:="select F2_FILIAL, F2_VEND1, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
"from "+retsqlname("SF2")+" SF2 WITH (NOLOCK), "+retsqlname("SA1")+" SA1 WITH (NOLOCK)"+;
"WHERE F2_TIPO='N' and "+;
"F2_EMISSAO between '"+dtos(dDtIni)+"' and '"+dtos(dDtfim)+"' and "+;      
"A1_REDE = '      ' AND "+;
"F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
"SF2.D_E_L_E_T_= '' "+;
"AND SA1.D_E_L_E_T_= '' "+;
"order by F2_EMISSAO,F2_CLIENTE,F2_LOJA"
                              
TCQUERY cQuery new alias "XF2"
DBSELECTAREA("XF2")

dbSelectArea("SA1")
dbSetOrder(1)

dbSelectArea("XF2")
ProcRegua(RecCount())
XF2->(dbgotop())

_dDataOut	:=	""
_xPrima		:=	.T.
DO WHILE !EOF()
	
	IncProc("VJ Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC + "-Emissao:"+dtoc(stod(XF2->F2_EMISSAO)))
	_cVendedor 	:=	XF2->F2_VEND1   
	_cEmissao 	:=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
	_dDataIn	:=	XF2->F2_EMISSAO
	_cCliente	:=	XF2->F2_CLIENTE
	_nValor		:=	XF2->F2_VALBRUT	
	_cFIL       :=  XF2->F2_FILIAL
	_cDOC      	:= 	XF2->F2_DOC
	_cSERIE    	:= 	XF2->F2_SERIE
	_cCLIENTE  	:= 	XF2->F2_CLIENTE
	_cLOJA     	:= 	XF2->F2_LOJA
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(_cFil + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)    

	DO WHILE SD2->(!EOF()) .AND. 	SD2->D2_DOC		  	== _cDOC     	.AND. ;
		SD2->D2_FILIAL      == _cFIL     .AND. ;
		SD2->D2_SERIE	  	== _cSERIE  	.AND. ;
		SD2->D2_CLIENTE		== _cCLIENTE .AND. ;
		SD2->D2_LOJA		== _cLOJA
		&&trecho vindo do META05 -Inicio-
		If SD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
		   dbSelectArea("SD2")
		   SD2->(dbskip())
		   LOOP
		Endif
		
		If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
		   	LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116") .AND. ;
		   !(LEFT(SD2->D2_CF,4) $ '5922 6922')    
		   //REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922 
		   //REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA 
		   dbSelectArea("SD2")
		   SD2->(dbskip())
		   LOOP
		Endif 
		&&Trecho -Fim-
		_nQtd      		:=	SD2->D2_QUANT
		_cProduto  		:=	SD2->D2_COD
		_nPrecoU		:=	SD2->D2_PRCVEN
		_nValorT		:=	SD2->D2_TOTAL
		_dEmissao		:=	SD2->D2_EMISSAO
		
		//INCLUIDO DANIEL 25/01/07
		//+---------------------+
		//|DEVOLUCAO            |
		//+---------------------+
		_nQtddev		:= SD2->D2_QTDEDEV *(-1)
		_nValdev		:= SD2->D2_VALDEV *(-1)
		_nValorT		+=_nValDev
		_nQtd			+=_nQtdDev
		
		//ALTERADO DANIEL 25/01/07
		//+--------------------------------------------+
		//| Verificando se existe desconto financeiro  |
		//+--------------------------------------------+
				
		If (XF2->A1_DESC > 0) .and. (_nValorT>0)	
			_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100) 
		Endif

		// Alex Borges 01/12/11
		_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO) 
		_nValorT := _nValorT - ( _Frete * _nQtd )			
				
		dbSelectArea("SB1") // PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cProduto)
		_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO				 			
		
		dbSelectArea("SBM") // GRUPO DE PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cGrupo)	
		_cNivel := SBM->BM_NIVEL
			
		dbSelectArea("TEM2")
		If _cNivel == "3" 		   			    
			IF !dbSeek(_cCliente+_cLoja+_cGrupo)
				//ACHAMETA()
				ACHAREF()                      
				
				dbSelectArea("TEM2")
				RecLock("TEM2",.T.)
				TEM2->T2_CLIENTE  	:=	_cCliente
				TEM2->T2_LOJA  	   :=	_cLoja
				TEM2->T2_CODGRUP	:=	_cGrupo			
				TEM2->T2_VENDAS		:=	_nQtd			
				TEM2->T2_RE_PRC		:= _nValorT
				TEM2->T2_RF_PRC     :=  _nRFPRC
				TEM2->T2_EMISSAO	:= _dEmissao			
				MsUnLock()
			Else
				RecLock("TEM2",.F.)
				TEM2->T2_VENDAS		:=	TEM2->T2_VENDAS	+	_nQtd
				TEM2->T2_RE_PRC		:=	TEM2->T2_RE_PRC	+	_nValorT
				MsUnLock()
			Endif
		Endif
		dbSelectArea("SD2")
		SD2->(DbSkip())
	Enddo

	dbSelectArea("XF2")
	XF2->(dbskip())
ENDDO

dbCloseArea("XF2")

DbSelectArea("TEM2")
dbgotop()
While TEM2->(!Eof())
      _cCodCli := TEM2->T2_CLIENTE
      _cCodLoj := TEM2->T2_LOJA
      _nValTot := 0
      _nValref := 0
      While _cCodCli+_cCodLoj == TEM2->T2_CLIENTE+TEM2->T2_LOJA
            _nValTot += TEM2->T2_RE_PRC
            _nValRef += TEM2->T2_VENDAS * TEM2->T2_RF_PRC
            TEM2->(dbskip())
      Enddo
      _nValIpct := _nValTot/_nValRef
      dbSelectArea("ZZX")
	  dbSetOrder(2)
	  dbGoTop()
				
	  While ZZX->(!Eof())
			If _nValIpct >= ZZX->ZZX_IPCTIN .And. _nValIpct < ZZX->ZZX_IPCTFI			  
			   _cFaixa := ZZX->ZZX_FAXIPC
			   Exit
			EndIf
			ZZX->(dbSkip())
	  EndDo
      
      /*
      if _nValIpct < 0.950
         _cFaixa := "1"
      elseif _nValIpct >= 0.950 .And. _nValIpct < 0.975
         _cFaixa := "2"
      elseif _nValIpct >= 0.975 .And. _nValIpct < 1.000
         _cFaixa := "3"   
      elseif _nValIpct >= 1.000 .And. _nValIpct < 1.025
         _cFaixa := "4"
      elseif _nValIpct >= 1.025 .And. _nValIpct < 1.050
         _cFaixa := "5"
      Else
         _cFaixa := "6"
      Endif
      */
      DbSelectArea("SA1")
      DbSetOrder(1)
      if dbseek(xFilial("SA1")+_cCodCli+_cCodLoj)
         RecLock("SA1",.F.)
            SA1->A1_CLASCLI := Substr(SA1->A1_CLASCLI,1,1)+_cFaixa  &&mantenho classificacao anterior e acrescento atual ipct     
         MsUnlock()
         SA1->(dbskip())
      Endif   
Enddo             
DbCloseArea("TEM2")

&&Tratamento para cliente REDE
aStru := {}
AADD (aStru,{"T2_CLIENTE"  	, "C",06,0})		// GUARDA CODIGO DA REDE
AADD (aStru,{"T2_CODGRUP" 	, "C",04,0})	  	// CODIGO DO GRUPO (NETO)
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// REALIZADO PRECO DO SUPERVISOR
AADD (aStru,{"T2_RF_PRC"   	, "N",12,4})		// REFERENCIA 
AADD (aStru,{"T2_EMISSAO"	, "D",08,0})	   	// DATA DE EMISSAO

IF SELECT("TEM3") > 0
   DbSelectArea("TEM3")
   DbCloseArea("TEM3")
Endif

_cNomTr2 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr2,"TEM3",.F.,.F.)
cIndex   := "T2_CLIENTE + T2_CODGRUP + dtos(T2_EMISSAO)"
IndRegua( "TEM3", _cNomTr2, cIndex,,,"Criando Indice ..." )

dbSelectArea("SB1") // PRODUTOS
dbSetOrder(1)

dbSelectArea("SBM")  // GRUPO DE PRODUTOS
dbSetOrder(1)

&&Para redes A1_REDE = preenchido
&&"where F2_FILIAL IN ("+ALLTRIM(MV_PAR05)+") and "+;
cQuery:="select F2_FILIAL, F2_VEND1, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
"from "+retsqlname("SF2")+" SF2 WITH (NOLOCK), "+retsqlname("SA1")+" SA1 WITH (NOLOCK) "+;
"WHERE F2_TIPO='N' and "+;
"F2_EMISSAO between '"+dtos(dDtIni)+"' and '"+dtos(dDtFim)+"' and "+;      
"A1_REDE <> '      ' AND "+;
"F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
"SF2.D_E_L_E_T_= '' "+;
"AND SA1.D_E_L_E_T_= '' "+;
"order by F2_EMISSAO,A1_REDE"
                              
TCQUERY cQuery new alias "XF2"
DBSELECTAREA("XF2")

dbSelectArea("SA1")
dbSetOrder(1)

dbSelectArea("XF2")
ProcRegua(RecCount())
XF2->(dbgotop())

_dDataOut	:=	""
_xPrima		:=	.T.
DO WHILE !EOF()
	
	IncProc("RD Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC + "-Emissao:"+dtoc(stod(XF2->F2_EMISSAO)))
	_cVendedor 	:=	XF2->F2_VEND1   
	_cEmissao 	:=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
	_dDataIn	:=	XF2->F2_EMISSAO
	_cCliente	:=	XF2->F2_CLIENTE
	_nValor		:=	XF2->F2_VALBRUT	
	_cFIL       :=  XF2->F2_FILIAL
	_cDOC      	:= 	XF2->F2_DOC
	_cSERIE    	:= 	XF2->F2_SERIE
	_cCLIENTE  	:= 	XF2->F2_CLIENTE
	_cLOJA     	:= 	XF2->F2_LOJA
	_cRede      :=  XF2->A1_REDE
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(_cFil + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)    

	DO WHILE SD2->(!EOF()) .AND. 	SD2->D2_DOC		  	== _cDOC     	.AND. ;
		SD2->D2_FILIAL      == _cFIL     .AND. ;
		SD2->D2_SERIE	  	== _cSERIE  	.AND. ;
		SD2->D2_CLIENTE		== _cCLIENTE .AND. ;
		SD2->D2_LOJA		== _cLOJA
		&&trecho vindo do META05 -Inicio-
		If SD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
		   dbSelectArea("SD2")
		   SD2->(dbskip())
		   LOOP
		Endif
		
		If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
		   	LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116") .AND. ;
		   !(LEFT(SD2->D2_CF,4) $ '5922 6922')    
		   //REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922 
		   //REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA 
		   dbSelectArea("SD2")
		   SD2->(dbskip())
		   LOOP
		Endif 
		&&Trecho -Fim-
		_nQtd      		:=	SD2->D2_QUANT
		_cProduto  		:=	SD2->D2_COD
		_nPrecoU		:=	SD2->D2_PRCVEN
		_nValorT		:=	SD2->D2_TOTAL
		_dEmissao		:=	SD2->D2_EMISSAO
		
		//INCLUIDO DANIEL 25/01/07
		//+---------------------+
		//|DEVOLUCAO            |
		//+---------------------+
		_nQtddev		:= SD2->D2_QTDEDEV *(-1)
		_nValdev		:= SD2->D2_VALDEV *(-1)
		_nValorT		+=_nValDev
		_nQtd			+=_nQtdDev
		
		//ALTERADO DANIEL 25/01/07
		//+--------------------------------------------+
		//| Verificando se existe desconto financeiro  |
		//+--------------------------------------------+
				
		If (XF2->A1_DESC > 0) .and. (_nValorT>0)	
			_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100) 
		Endif

		// Alex Borges 01/12/11
		_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO) 
		_nValorT := _nValorT - ( _Frete * _nQtd )			
				
		dbSelectArea("SB1") // PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cProduto)
		_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO				 			
		
		dbSelectArea("SBM") // GRUPO DE PRODUTO
		DbSetOrder(1)
		dbSeek(xfilial() + _cGrupo)	
		_cNivel := SBM->BM_NIVEL
			
		dbSelectArea("TEM3")
		If _cNivel == "3" 		   			    
			IF !dbSeek(_cRede+_cGrupo)
				//ACHAMETA()
				ACHAREF()                      
				
				dbSelectArea("TEM3")
				RecLock("TEM3",.T.)
				TEM3->T2_CLIENTE  	:=	_cRede				
				TEM3->T2_CODGRUP	:=	_cGrupo			
				TEM3->T2_VENDAS		:=	_nQtd			
				TEM3->T2_RE_PRC		:= _nValorT
				TEM3->T2_RF_PRC     :=  _nRFPRC
				TEM3->T2_EMISSAO	:= _dEmissao			
				MsUnLock()
			Else
				RecLock("TEM3",.F.)
				TEM3->T2_VENDAS		:=	TEM3->T2_VENDAS	+	_nQtd
				TEM3->T2_RE_PRC		:=	TEM3->T2_RE_PRC	+	_nValorT
				MsUnLock()
			Endif
		Endif
		dbSelectArea("SD2")
		SD2->(DbSkip())
	Enddo

	dbSelectArea("XF2")
	XF2->(dbskip())
ENDDO

dbCloseArea("XF2")

DbSelectArea("TEM3")
dbgotop()
While TEM3->(!Eof())
      _cCodCli := TEM3->T2_CLIENTE      
      _nValTot := 0
      _nValref := 0
      While _cCodCli == TEM3->T2_CLIENTE
            _nValTot += TEM3->T2_RE_PRC
            _nValRef += TEM3->T2_VENDAS * TEM3->T2_RF_PRC
            TEM3->(dbskip())
      Enddo
      _nValIpct := _nValTot/_nValRef
      dbSelectArea("ZZX")
	  dbSetOrder(2)
	  dbGoTop()
	    			
	  While ZZX->(!Eof())
			If _nValIpct >= ZZX->ZZX_IPCTIN .And. _nValIpct < ZZX->ZZX_IPCTFI			  
			   _cFaixa := ZZX->ZZX_FAXIPC
			   Exit
			EndIf
			ZZX->(dbSkip())
	  EndDo
      /*
      if _nValIpct < 0.950
         _cFaixa := "1"
      elseif _nValIpct >= 0.950 .And. _nValIpct < 0.975
         _cFaixa := "2"
      elseif _nValIpct >= 0.975 .And. _nValIpct < 1.000
         _cFaixa := "3"   
      elseif _nValIpct >= 1.000 .And. _nValIpct < 1.025
         _cFaixa := "4"
      elseif _nValIpct >= 1.025 .And. _nValIpct < 1.050
         _cFaixa := "5"
      Else
         _cFaixa := "6"
      Endif
      */
       
      DbSelectArea("SA1")
      DbSetOrder(11)
      if dbseek(xFilial("SA1")+_cCodCli)
         While SA1->(!EOF()) .AND. SA1->A1_REDE == _cCodCli
               RecLock("SA1",.F.)
                  SA1->A1_CLASCLI := Substr(SA1->A1_CLASCLI,1,1)+_cFaixa  &&mantenho classificacao anterior e acrescento atual ipct rede    
               MsUnlock()
               SA1->(dbskip())
         Enddo      
      Endif   
Enddo             
DbCloseArea("TEM3")

&&Para os clientes que não entraram no calculo acima no periodo, classifico estes como "ZZ" conforme definido junto ao Sr. Wagner do comercial.

_cQuery := " UPDATE "+RetSqlName("SA1")+" WITH(UPDLOCK) SET A1_CLASCLI = 'ZZ' "
_cQuery += " FROM "+RetSqlName("SA1")+" "		
_cQuery += " WHERE A1_CLASCLI = '  ' "
_cQuery += " AND "+RETSQLNAME("SA1")+".D_E_L_E_T_=' ' "	 
TCSQLExec(_cQuery)

DbCloseArea("TOTV")
DbCloseArea("TOTR")         

Grava_C()

Return()

STATIC FUNCTION ACHAREF()

_nRFPRC:=0

dbSelectArea("ZZS")
dbSetOrder(1)             
dbSeek(xfilial("ZZS") + _cGrupo + DTOS(dDtMtIn))

_nContDias	:=	0
Do while !EOF()
	
	IF (dtos(ZZS->ZZS_DATA) > DTOS(dDtMtFi)) .or. _cGrupo != ZZS->ZZS_GRUPO
		exit
	Endif
	        
	IF dtos(ZZS->ZZS_DATA) >= DTOS(dDtMtIn)	
		If ZZS->ZZS_VALOR > 0	
			_nRFPRC	:=	_nRFPRC + ZZS->ZZS_VALOR		
			_nContDias++
		Endif							
	Endif
	ZZS->(dbskip())
Enddo
_nRFPRC	:=	_nRFPRC / _nContDias

Return()

static function fbuscafrt(_cF,_cPedido)
Local _cPedido
Local _cF
Local _nFrete := 0

DbSelectArea("SC5")
DbSetOrder(1)
if dbSeek(_cF+_cPedido)
      if (ALLTRIM(SC5->C5_TPFRETE) = "C")
      		_nFrete := SC5->C5_FRETAPV
      Else
       		_nFrete := 0
      EndIf      
Endif   
   
Return(_nFrete)                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRAVA_C   ºAutor  ³ADRIANA OLIVEIRA    º Data ³  08/08/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava_C()

Local cKeyX5 := cFilAnt+"_C000002"

SX5->( dbSetOrder(1) ) //X5_FILIAL+X5_TABELA+X5_CHAVE

If SX5->( dbSeek(cKeyX5) )
	RecLock("SX5",.f.)
	SX5->X5_DESCRI := dtoc(date())+" as "+time()+" por "+cUserName
	SX5->( msUnLock() )
Else
	RecLock("SX5",.t.)
	SX5->X5_FILIAL := xFilial("SX5")
	SX5->X5_TABELA := "_C"
	SX5->X5_CHAVE  := "000002"
	SX5->X5_DESCRI := dtoc(date())+" as "+time()+" por "+cUserName
	SX5->( msUnLock() )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRAZ_C    ºAutor  ³ADRIANA OLIVEIRA    º Data ³  08/08/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Traz_C()
Local _cRetorno := ""
Local cKeyX5 := xFilial("SX5")+"_C000002"

SX5->( dbSetOrder(1) ) //X5_FILIAL+X5_TABELA+X5_CHAVE

If SX5->( dbSeek(cKeyX5) )
	_cRetorno := SX5->X5_DESCRI
Else
	_cRetorno := "..."
EndIf

Return _cRetorno