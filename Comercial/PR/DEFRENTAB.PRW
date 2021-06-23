#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
                  
/*           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEFRENTAB ºAutor  ³Mauricio - MDS TEC   º Data ³  16/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina desenvolvida para classificacao e definição de perioº±±
±±º          ³ dos e valores para relatorio 50 maiores por Rentabilidade  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³          ³ clientes e supervisores vem de arquivo CSV                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DEFRENTAB()

Local lRet 	 := .T.
Local cPerg  := PADR("DEFMOR",10," ")

Private dDtIni  := CTOD("  /  /  ")
Private dDtFim  := CTOD("  /  /  ")
Private dDtMtIn := CTOD("  /  /  ")
Private dDtMtFi := CTOD("  /  /  ")
Private oDlg01
Private oFont1
Private _nRFPRC := 0
Private _nMTPRC := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida para classificacao e definição de periodos e valores para relatorio 50 maiores por Rentabilidade')

_nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
_nHdl    	:= Nil           		// Handle para abertura do arquivo
_cTXT 	:= Space(_nTamLin+1) 	// Variavel para leitura
_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
_cDelimit	:= ";"                 //Delimitador do arquivo CSV

PutSX1(cPerg,"01","Periodo De ","Periodo De ","Periodo De ","mv_ch1","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"02","Periodo Ate","Periodo Ate","Periodo Ate","mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"03","Sem. 1 De ","Sem. 1 De ","Sem. 1 De "   ,"mv_ch3","D",08,0,0,"G",""         ,"","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"04","Sem. 1 Ate","Sem. 1 Ate","Sem. 1 Ate"   ,"mv_ch4","D",08,0,0,"G",""         ,"","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"05","Sem. 2 De ","Sem. 2 De ","Sem. 2 De "   ,"mv_ch5","D",08,0,0,"G",""         ,"","","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"06","Sem. 2 Ate","Sem. 2 Ate","Sem. 2 Ate"   ,"mv_ch6","D",08,0,0,"G",""         ,"","","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"07","Sem. 3 De ","Sem. 3 De ","Sem. 3 De "   ,"mv_ch7","D",08,0,0,"G",""         ,"","","","mv_par07" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"08","Sem. 3 Ate","Sem. 3 Ate","Sem. 3 Ate"   ,"mv_ch8","D",08,0,0,"G",""         ,"","","","mv_par08" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"09","Sem. 4 De ","Sem. 4 De ","Sem. 4 De "   ,"mv_ch9","D",08,0,0,"G",""         ,"","","","mv_par09" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"10","Sem. 4 Ate","Sem. 4 Ate","Sem. 4 Ate"   ,"mv_cha","D",08,0,0,"G",""         ,"","","","mv_par10" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"11","Sem. 5 De ","Sem. 5 De ","Sem. 5 De "   ,"mv_chb","D",08,0,0,"G",""         ,"","","","mv_par11" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"12","Sem. 5 Ate","Sem. 5 Ate","Sem. 5 Ate"   ,"mv_chc","D",08,0,0,"G",""         ,"","","","mv_par12" ,"","","","","","","","","","","","","","",""," ")
PutSx1(cPerg,"13","Fator Meta","Fator Meta","Fator Meta"   ,"mv_chd","N",10,2,0,"G",""         ,"","","","mv_par13" ,"","","","","","","","","","","","","","",""," ")
PutSx1(cPerg,"14","Nr. Dias Consol. Pesquisa","Nr. Dias Consol. Pesquisa","Nr. Dias Consol. Pesquisa"   ,"mv_che","N",3,0,0,"G",""    ,"","","","mv_par14" ,"","","","","","","","","","","","","","",""," ")

Pergunte(cPerg,.T.)
                                 
_cFile := cGetFile( "Lista Arquivos |*.*",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)

If Empty( _cFile )
   MsgInfo("Não foi escolhido corretamente o arquivo CSV para importação de dados!.","Atenção")
   Return()
End

If lRet
   If MsgYesNo(OemToAnsi("Confirma inicio da Rotina?.Tabela do periodo sera limpa e recalculada."),OemToAnsi("A T E N Ç Ã O"))
      _nHdl := fOpen(_cFile,2) // Abre o arquivo
	  fClose(_nHdl)
      If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cFile),{"Sair"} )
	  else
    	Processa({|| ApurCli()},OemToAnsi("Atualizando/Calculando..."))	
      Endif	
   EndIf
Endif   

Return(lRet)

Static Function ApurCli()
Local cQuery := ""
Local _cRede := "",_cCliente := ""
Local _cFaixa := ""

_cLF     := Chr( 10 )
_cTxt    := ''
_cChr    := ''
_nTam    := 0

&&limpo a tabela de classificacao para nova apuração de valores e classificacao
DbSelectArea("ZZZ")
DbSetOrder(1)
Dbgotop()
While ZZZ->(!EOF())
      Reclock("ZZZ",.F.)
        dbDelete()
      MsUnlock()
      ZZZ->(dbskip())
Enddo

&&Crio uma tabela temporaria para gravar os clientes REDE + Varejo juntos, pois desta tabela é que vou gerar os 100 maiores e gravar na tabela ZZZ.
aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})
AADD (aStru,{"T2_SUPUSUA"  	, "C",06,0})
AADD (aStru,{"T2_CLIENTE"  	, "C",06,0})		// GUARDA CODIGO DO CLIENTE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_TIPO"  	, "C",01,0})		// REDE ou VAREJO
AADD (aStru,{"T2_MT_PRC"    , "N",11,2})        // MEta para IPM  TEM2->T2_MT_PRC		:= _nMTPRC
AADD (aStru,{"T2_VEND"  	, "C",06,0})		// VENDEDOR
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// VALOR REALIZADO 

IF SELECT("MAIOR") > 0
   DbSelectArea("MAIOR")
   DbCloseArea("MAIOR")
Endif

_cNomTrZ := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrZ,"MAIOR",.F.,.F.)
cIndexZ   := "T2_SUPERVI + DESCEND(STR(T2_RE_PRC,11,2))"
IndRegua( "MAIOR", _cNomTrZ, cIndexZ,,,"Criando Indice ..." )

DbSelectArea("MAIOR")
        
&&Separo em duas querys.Uma para apurar valores de classificação para os clientes somente varejo e outra para trazer somente clientes Rede.

&&Primeiro os clientes varejo
&&Vou ter de efetuar calculo para indice IPM conforme relatorio AD0027V
aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})
AADD (aStru,{"T2_SUPUSUA"  	, "C",06,0})
AADD (aStru,{"T2_CLIENTE"  	, "C",06,0})		// GUARDA CODIGO DO CLIENTE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_VEND"  	, "C",06,0})        // VENDEDOR
AADD (aStru,{"T2_MT_PRC"    , "N",11,2}) 
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// VALOR REALIZADO 
AADD (aStru,{"T2_EMISSAO"	, "D",08,0})	   	// DATA DE EMISSAO

IF SELECT("TEM2") > 0
   DbSelectArea("TEM2")
   DbCloseArea("TEM2")
Endif

_cNomTr  := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr,"TEM2",.F.,.F.)
cIndex   := "T2_SUPERVI + T2_CLIENTE + T2_LOJA "
IndRegua( "TEM2", _cNomTr, cIndex,,,"Criando Indice ..." )

aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})
AADD (aStru,{"T2_SUPUSUA"  	, "C",06,0})
AADD (aStru,{"T2_CLIENTE"  	, "C",06,0})		// GUARDA CODIGO DO CLIENTE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_VEND"  	, "C",06,0})        // VENDEDOR
AADD (aStru,{"T2_MT_PRC"    , "N",11,2}) 
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// VALOR REALIZADO 

IF SELECT("RANK") > 0
   DbSelectArea("RANK")
   DbCloseArea("RANK")
Endif

_cNomTr1 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr1,"RANK",.F.,.F.)
cIndex   := "T2_SUPERVI + DESCEND(STR(T2_RE_PRC,11,2))"
IndRegua( "RANK", _cNomTr1, cIndex,,,"Criando Indice ..." )

&&temporario para clientes REDE
aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})
AADD (aStru,{"T2_SUPUSUA"  	, "C",06,0})
AADD (aStru,{"T2_REDE"  	, "C",06,0})		// GUARDA CODIGO DA REDE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_VEND"  	, "C",06,0})        // VENDEDOR
AADD (aStru,{"T2_MT_PRC"    , "N",11,2})
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// VALOR REALIZADO 
AADD (aStru,{"T2_EMISSAO"	, "D",08,0})	   	// DATA DE EMISSAO

IF SELECT("TEMR") > 0
   DbSelectArea("TEMR")
   DbCloseArea("TEMR")
Endif

_cNomTrR  := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrR,"TEMR",.F.,.F.)
cIndexR   := "T2_SUPERVI + T2_REDE "
IndRegua( "TEMR", _cNomTrR, cIndexR,,,"Criando Indice ..." )

aStru := {}
AADD (aStru,{"T2_SUPERVI"  	, "C",06,0})
AADD (aStru,{"T2_SUPUSUA"  	, "C",06,0})
AADD (aStru,{"T2_REDE"  	, "C",06,0})		// GUARDA CODIGO DA REDE
AADD (aStru,{"T2_LOJA"  	, "C",02,0})		// GUARDA LOJA DO CLIENTE
AADD (aStru,{"T2_VEND"  	, "C",06,0})        // VENDEDOR
AADD (aStru,{"T2_MT_PRC"    , "N",11,2})
AADD (aStru,{"T2_VENDAS"   	, "N",11,0})		// TOTAL DE VENDAS (PESO) REALIZADO NO PERIODO
AADD (aStru,{"T2_RE_PRC"   	, "N",11,2})		// VALOR REALIZADO 

IF SELECT("RANKR") > 0
   DbSelectArea("RANKR")
   DbCloseArea("RANKR")
Endif

_cNomTr2 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTr2,"RANKR",.F.,.F.)
cIndex2   := "T2_SUPERVI + DESCEND(STR(T2_RE_PRC,11,2))"
IndRegua( "RANKR", _cNomTr2, cIndex2,,,"Criando Indice ..." )

dbSelectArea("SB1") // PRODUTOS
dbSetOrder(1)

dbSelectArea("SBM")  // GRUPO DE PRODUTOS
dbSetOrder(1)

&&Abro arquivo CSV e inicio importacao/apuração...
FT_FUse( _cFile ) 
_nTam += FT_FlastRec()
_nTam ++
FT_FGoTop()
ProcRegua( _nTam )
_nLinha := 1
_cSuper := ""
_cClien := ""
_cLoj   := ""
_cTIP   := ""
While ! ( FT_FEof() )
          
      IncProc( 'Aguarde, importando registros e apurando valores..' )
      _cTxt :=  FT_FReadLN()
      _nCmp := 1
      FOR I := 1 TO 4
            If I < 4
	   	       _cTxtPos := Substr(_cTxt,1,At(_cDelimit, _cTxt)-1)
	   	    Else
	   	      _cTxtPos := Substr(_cTxt,1,At(_cDelimit, _cTxt)-1)
	   	      If Empty(_cTxtPos)
	   	         _cTxtPos := _cTxt
	   	      Endif   
	   	    Endif   
			if _nCmp = 1	
				_cSuper    := _cTxtPos				
			elseif _nCmp = 2   
			    _cClien := _cTxtPos 			 
			elseif _nCmp = 3   
			    _cLoj   := _cTXTPOS
			elseif _nCmp = 4   
			    _cTIP   := Alltrim(_cTXTPOS)
			endif  
			_cTxt := Substr(_cTxt,At(";", _cTxt)+1)
			_nCmp++
	  End      
                 
      If _cTIP == "V"      &&Se for cliente de varejo...
         cQuery:="select F2_FILIAL, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_VEND, A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 		
         "from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
         "WHERE F2_TIPO='N' and "+;
         "F2_EMISSAO between '"+dtos(MV_PAR01)+"' and '"+dtos(MV_PAR02)+"' and "+;      
         "F2_CLIENTE = '"+Alltrim(_cClien)+"' AND F2_LOJA = '"+Alltrim(_cLoj)+"' AND "+;     
         "F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
         "SF2.D_E_L_E_T_= '' "+;
         "AND SA1.D_E_L_E_T_= '' "+;
         "ORDER BY F2_CLIENTE,F2_LOJA,F2_EMISSAO"
                              
         TCQUERY cQuery new alias "XF2"
         DBSELECTAREA("XF2")

         dbSelectArea("SA1")
         dbSetOrder(1)

         dbSelectArea("XF2")
         ProcRegua(RecCount())
         XF2->(dbgotop()) 
                        
         _dDataOut	:=	""
         _xPrima		:=	.T.
         _lVar := .F.
         DO WHILE XF2->(!EOF())
	
	        IncProc("VJ Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC )
	        _cVendedor  :=	XF2->A1_VEND
	        _cSuperv    := Alltrim(_cSuper)    ///Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_CODSUP")
	        _cSupUsu    := Alltrim(_cSuper)    ///Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_SUPER")   
	        _cEmissao 	 :=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
	        _cCliente	 :=	XF2->F2_CLIENTE
	        _nValor	 :=	XF2->F2_VALBRUT	
	        _cFIL       := XF2->F2_FILIAL
	        _cDOC       := XF2->F2_DOC
	        _cSERIE     := XF2->F2_SERIE
	        _cCLIENTE   := XF2->F2_CLIENTE
	        _cLOJA      := XF2->F2_LOJA
	      
	        _lVar := .T.
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
		       _nQtd		+=_nQtdDev
		
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
			      IF !dbSeek(_cSuperv+_cCliente+_cLoja)
				     ACHAMETA() 	 &&meta para calculo do IPM											
				     dbSelectArea("TEM2")
				     RecLock("TEM2",.T.)
				     TEM2->T2_SUPERVI    :=  _cSuperv
				     TEM2->T2_SUPUSUA    :=  _cSupusu 
				     TEM2->T2_CLIENTE  	:=	_cCliente
				     TEM2->T2_LOJA  	    :=	_cLoja
				     TEM2->T2_VEND       := 	_cVendedor
				     TEM2->T2_MT_PRC		:=  _nMTPRC
				     TEM2->T2_VENDAS		:=	_nQtd			
				     TEM2->T2_RE_PRC		:=  _nValorT			
				     MsUnLock()
			      Else
			         dbSelectArea("TEM2")
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
         /*
         DbSelectArea("TEM2")
         dbgotop()
         While TEM2->(!Eof())    &&arquivo ja esta em ordem de supervisor+cliente+loja(unica)+valor faturado
               RecLock("RANK",.T.)     &&jogo para arquivo RANK para ordenar somente pelo supervisor+faturamento+cliente(100 maiores por supervisor)
               RANK->T2_SUPERVI := TEM2->T2_SUPERVI
               RANK->T2_SUPUSUA := TEM2->T2_SUPUSUA
               RANK->T2_CLIENTE := TEM2->T2_CLIENTE
               RANK->T2_LOJA    := TEM2->T2_LOJA
               RANK->T2_MT_PRC  := TEM2->T2_MT_PRC
               RANK->T2_VEND    := TEM2->T2_VEND
               RANK->T2_RE_PRC  := TEM2->T2_RE_PRC
               RANK->T2_VENDAS  := TEM2->T2_VENDAS
               MsUnlock()
               TEM2->(dbskip())
         Enddo
         */
      
      Else &&se for cliente de rede...      
           cQuery:="select F2_FILIAL, F2_VEND1, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
           "from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
           "WHERE F2_TIPO='N' and "+;
           "F2_EMISSAO between '"+dtos(MV_PAR01)+"' and '"+dtos(MV_PAR02)+"' and "+;      
           "A1_REDE = '"+_cClien+"' AND "+;
           "F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
           "SF2.D_E_L_E_T_= '' "+;
           "AND SA1.D_E_L_E_T_= '' "+;
           "order by A1_REDE, F2_EMISSAO"
                              
           TCQUERY cQuery new alias "XF2"
           DBSELECTAREA("XF2")

           dbSelectArea("SA1")
           dbSetOrder(1)

           dbSelectArea("XF2")
           ProcRegua(RecCount())
           XF2->(dbgotop())

           _dDataOut	:=	""
           _xPrima		:=	.T.
           DO WHILE XF2->(!EOF())
	
	          IncProc("RD Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC )
	          _cVendedor  :=  Posicione("SA1",1,xFilial("SA1")+XF2->A1_REDE,"A1_VEND")  && REDE vendedor e supervisor vem do CLIENTE PAI da REDE conf. Vagner e MArcus.  XF2->A1_VEND
	          _cSuperv    :=  Alltrim(_cSuper)   //Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_CODSUP")
              _cSupUsu    :=  Alltrim(_cSuper)   //Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_SUPER")  
    	      _cEmissao   :=  ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
	          _nValor	  :=  XF2->F2_VALBRUT	
	          _cFIL       :=  XF2->F2_FILIAL
	          _cDOC       :=  XF2->F2_DOC
    	      _cSERIE     :=  XF2->F2_SERIE
	          _cCLIENTE   :=  XF2->F2_CLIENTE
	          _cLOJA      :=  XF2->F2_LOJA
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
			
		         dbSelectArea("TEMR")
		         If _cNivel == "3"		 		   			    
			        IF !dbSeek(_cSuperv+_cRede)
			           ACHAMETA() 												
				       dbSelectArea("TEMR")
				       RecLock("TEMR",.T.)
				       TEMR->T2_SUPERVI    := _cSuperv
				       TEMR->T2_SUPUSUA    := _cSupUsu 
				       TEMR->T2_REDE   	:= _cRede
				       TEMR->T2_VEND  	    :=	_cVendedor
				       TEMR->T2_MT_PRC		:= _nMTPRC				
				       TEMR->T2_VENDAS		:=	_nQtd			
				       TEMR->T2_RE_PRC		:= _nValorT			
				       MsUnLock()
			        Else
				       RecLock("TEMR",.F.)
				       TEMR->T2_VENDAS		:=	TEMR->T2_VENDAS	+	_nQtd
				       TEMR->T2_RE_PRC		:=	TEMR->T2_RE_PRC	+	_nValorT
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
           /*
           DbSelectArea("TEMR")
           dbgotop()
           While TEMR->(!Eof())    &&arquivo ja esta em ordem de supervisor+Rede(unica)+valor faturado
                 RecLock("RANKR",.T.)     &&jogo para arquivo RANK para ordenar somente pelo supervisor+faturamento Rede(100 maiores por supervisor)
                 RANKR->T2_SUPERVI := TEMR->T2_SUPERVI
                 RANKR->T2_SUPUSUA := TEMR->T2_SUPUSUA
                 RANKR->T2_REDE    := TEMR->T2_REDE
                 RANKR->T2_VEND    := TEMR->T2_VEND
                 RANKR->T2_MT_PRC  := TEMR->T2_MT_PRC
                 RANKR->T2_RE_PRC  := TEMR->T2_RE_PRC
                 RANKR->T2_VENDAS  := TEMR->T2_VENDAS
                 MsUnlock()
                 TEMR->(dbskip())
           Enddo
           */                  
      Endif           
      _nLinha ++
      ft_fSkip()
Enddo

FT_FUse()

DbSelectArea("TEM2")
dbgotop()
While TEM2->(!Eof())    &&arquivo ja esta em ordem de supervisor+cliente+loja(unica)+valor faturado
               RecLock("RANK",.T.)     &&jogo para arquivo RANK para ordenar somente pelo supervisor+faturamento+cliente(100 maiores por supervisor)
               RANK->T2_SUPERVI := TEM2->T2_SUPERVI
               RANK->T2_SUPUSUA := TEM2->T2_SUPUSUA
               RANK->T2_CLIENTE := TEM2->T2_CLIENTE
               RANK->T2_LOJA    := TEM2->T2_LOJA
               RANK->T2_MT_PRC  := TEM2->T2_MT_PRC
               RANK->T2_VEND    := TEM2->T2_VEND
               RANK->T2_RE_PRC  := TEM2->T2_RE_PRC
               RANK->T2_VENDAS  := TEM2->T2_VENDAS
               MsUnlock()
               TEM2->(dbskip())
Enddo

DbSelectArea("TEMR")
dbgotop()
While TEMR->(!Eof())    &&arquivo ja esta em ordem de supervisor+Rede(unica)+valor faturado
                 RecLock("RANKR",.T.)     &&jogo para arquivo RANK para ordenar somente pelo supervisor+faturamento Rede(100 maiores por supervisor)
                 RANKR->T2_SUPERVI := TEMR->T2_SUPERVI
                 RANKR->T2_SUPUSUA := TEMR->T2_SUPUSUA
                 RANKR->T2_REDE    := TEMR->T2_REDE
                 RANKR->T2_VEND    := TEMR->T2_VEND
                 RANKR->T2_MT_PRC  := TEMR->T2_MT_PRC
                 RANKR->T2_RE_PRC  := TEMR->T2_RE_PRC
                 RANKR->T2_VENDAS  := TEMR->T2_VENDAS
                 MsUnlock()
                TEMR->(dbskip())
Enddo           
      
&&gravo na tabela MAIOR para depois gravar na ZZZ        
DbSelectArea("RANK")   &&varejo
dbgotop()
While RANK->(!Eof())    
            _cCodSup := RANK->T2_SUPERVI
            _nCont := 0
            While _cCodSup == RANK->T2_SUPERVI
                 &&retirado em 23/10/13 pois os clientes vem de arquivo CSV e não ha limite...
                 //If _nCont > 100  &&limita a apenas 100 clientes(se houver)
                 //   RANK->(dbskip())
                 //   loop
                 //endif
                 RecLock("MAIOR",.T.)
                 MAIOR->T2_SUPERVI := RANK->T2_SUPERVI
                 MAIOR->T2_SUPUSUA := RANK->T2_SUPUSUA
                 MAIOR->T2_CLIENTE := RANK->T2_CLIENTE
                 MAIOR->T2_LOJA    := RANK->T2_LOJA
                 MAIOR->T2_TIPO    := "V" &&Varejo
                 MAIOR->T2_VEND    := RANK->T2_VEND
                 MAIOR->T2_MT_PRC	 := RANK->T2_MT_PRC
                 MAIOR->T2_RE_PRC  := RANK->T2_RE_PRC
                 MAIOR->T2_VENDAS   := RANK->T2_VENDAS
            MSunlock()           
            _nCont ++
            RANK->(dbskip())
      Enddo        
Enddo

DbSelectArea("MAIOR")                 
&&Arquivo pronto para uso por ordem de supervisor+clientes REDE com maior faturamento do maior para o menor para a rede         
DbSelectArea("RANKR")
dbgotop()
While RANKR->(!Eof())    
      _cCodSup := RANKR->T2_SUPERVI
      _nCont := 0
      While _cCodSup == RANKR->T2_SUPERVI
            //If _nCont > 100  &&limita a apenas 100 clientes(se houver)
            //   RANK->(dbskip())
            //   loop
            //endif
            DbSelectArea("MAIOR")            
            RecLock("MAIOR",.T.)
               MAIOR->T2_SUPERVI := RANKR->T2_SUPERVI
               MAIOR->T2_SUPUSUA := RANKR->T2_SUPUSUA
               MAIOR->T2_CLIENTE := RANKR->T2_REDE
               MAIOR->T2_LOJA    := RANKR->T2_LOJA
               MAIOR->T2_TIPO    := "R" &&Varejo
               MAIOR->T2_MT_PRC	 := RANKR->T2_MT_PRC
               MAIOR->T2_VEND    := RANKR->T2_VEND
               MAIOR->T2_RE_PRC  := RANKR->T2_RE_PRC
               MAIOR->T2_VENDAS   := RANKR->T2_VENDAS
            MSunlock()            
            _nCont ++
            RANKR->(dbskip())
      Enddo        
Enddo                        

DbSelectArea("MAIOR")
dbgotop()
While MAIOR->(!Eof())    
      _cCodSup := MAIOR->T2_SUPERVI     
      _nCont := 0
      While _cCodSup == MAIOR->T2_SUPERVI
            //If _nCont > 100  &&limita a apenas 100 clientes(se houver) por supervisor
            //   MAIOR->(dbskip())
            //   loop
            //endif
            _cNomeC := Posicione("SA1",1,xfilial("SA1")+MAIOR->T2_CLIENTE,"A1_NOME")
            DBSELECTAREA("MAIOR")           
			_cCodUs := Posicione("SA3",1,xFilial("SA3")+MAIOR->T2_SUPUSUA,"A3_CODUSR")                                    
            DBSELECTAREA("MAIOR")             
            RecLock("ZZZ",.T.)  &&tabela a ser criada               
               ZZZ->ZZZ_SUPERV   := MAIOR->T2_SUPERVI
               ZZZ->ZZZ_CDUSSP   := _cCodUs
               ZZZ->ZZZ_RANK     := _nCont + 1
               ZZZ->ZZZ_CLIENT   := MAIOR->T2_CLIENTE
               ZZZ->ZZZ_LOJA     := MAIOR->T2_LOJA
               ZZZ->ZZZ_NOME     := _cNomeC
               ZZZ->ZZZ_REDVAR   := MAIOR->T2_TIPO
               ZZZ->ZZZ_VEND     := MAIOR->T2_VEND
               ZZZ->ZZZ_IPM      := (MAIOR->T2_RE_PRC/(MAIOR->T2_VENDAS*MAIOR->T2_MT_PRC))
               ZZZ->ZZZ_FATURA   := MAIOR->T2_RE_PRC
               ZZZ->ZZZ_VOLUME   := MAIOR->T2_VENDAS
               ZZZ->ZZZ_VALIDO := "X"   &&flag de clientes que serao considerados e acompanhados em relatorio neste caso sao todos,nao ha o que escolher.
               ZZZ->ZZZ_PERINI   := MV_PAR01
               ZZZ->ZZZ_PERFIM   := MV_PAR02
               ZZZ->ZZZ_SEM1IN   := MV_PAR03
               ZZZ->ZZZ_SEM1FN   := MV_PAR04
               ZZZ->ZZZ_SEM2IN   := MV_PAR05         
               ZZZ->ZZZ_SEM2FN   := MV_PAR06
               ZZZ->ZZZ_SEM3IN   := MV_PAR07
               ZZZ->ZZZ_SEM3FN   := MV_PAR08
               ZZZ->ZZZ_SEM4IN   := MV_PAR09
               ZZZ->ZZZ_SEM4FN   := MV_PAR10       
               ZZZ->ZZZ_SEM5IN   := MV_PAR11
               ZZZ->ZZZ_SEM5FN   := MV_PAR12     
               ZZZ->ZZZ_FATOR    := MV_PAR13
               ZZZ->ZZZ_DIATOT   := MV_PAR14
               ZZZ->ZZZ_DTDEFI   := DATE()
               ZZZ->ZZZ_USUDEF   := __cUSERID                                           
            Msunlock()
            _nCont ++
            DBSELECTAREA("MAIOR")
            MAIOR->(dbskip())
      Enddo        
Enddo
Return()

STATIC FUNCTION ACHAMETA()
&&para clientes _nMTVOL sempre é zero(condicao passada por vagner)

_nMTPRC:=0
_nMTVOL:=0

dbSelectArea("SZL")
dbSetOrder(1)
             
dbSeek(xfilial("SZL") + _cSuperv	+ _cGrupo + DTOS(mv_par01))

_nContDias	:=	0
Do while !EOF()
		
	IF (dtos(SZL->ZL_DATA) > DTOS(mv_par02)) .or. _cGrupo != SZL->ZL_grupo
		exit
	Endif

	IF dtos(SZL->ZL_DATA) >= DTOS(mv_par01)
		If SZL->ZL_VALOR > 0		// incluido
			_nMTPRC	:=	_nMTPRC + SZL->ZL_VALOR
			_nContDias++			
		Endif		
		//If SZL->ZL_PESMETA > 0		// incluido
		//	_nMTVOL	:=	_nMTVOL + SZL->ZL_PESMETA
		//Endif
	Endif
	dbskip()                    
Enddo
_nMTPRC	:=	_nMTPRC / _nContDias
Return

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