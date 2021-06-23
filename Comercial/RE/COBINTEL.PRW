#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"
            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³COBINTEL  ³ Autor ³Mauricio-MDS TEC       ³ Data ³ 23/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Cobertura Inteligente(solicitado Vagner)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function COBINTEL() 
  
SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,") 
SetPrvt("_lDiret,_lSuperv,_lVended,_cCodigo")
Private cArqExc
Private oExcelApp   
Private _cTes := ""
Private _cLin1 := "                                    |      |        |     |    |     |       |      |         |         |       |        |       |      |        |      |       |        |" 
Private _cLin2 := "|      |        |     |    |     |       |      |         |         |       |        |       |      |        |      |       |        |" 
Private _Eof 	:= Chr(13) + Chr(10)

aOrd             := {}
tamanho          := "G"
limite           := 220
nomeprog         := "COBINTEL"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.
cPerg            := "COBINT"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Cobertura Inteligente(solicitado Vagner)')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T. 

PutSX1(cPerg,"01","Vendedor De "          ,"Vendedor De "            ,"Vendedor De "            ,"mv_ch1","C",06,0,0,"G",""          ,"SA3","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"02","Vendedor Ate"          ,"Vendedor Ate"            ,"Vendedor Ate"            ,"mv_ch2","C",06,0,0,"G",""          ,"SA3","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"03","Supervisor De "        ,"Supervisor De "          ,"Supervisor De "          ,"mv_ch3","C",06,0,0,"G",""          ,"A06","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"04","Supervisor Ate"        ,"Supervisor Ate"          ,"Supervisor Ate"          ,"mv_ch4","C",06,0,0,"G",""          ,"A06","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"05","Dt Atual De "          ,"Dt Atual De "            ,"Dt Atual De "            ,"mv_ch5","D",08,0,0,"G",""          ,""   ,"","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"06","Dt Atual Até "         ,"Dt Atual De "            ,"Dt Atual De "            ,"mv_ch6","D",08,0,0,"G",""          ,""   ,"","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"07","Dt Historico De "      ,"Dt Historico De "        ,"Dt Historico De "        ,"mv_ch7","D",08,0,0,"G",""          ,""   ,"","","mv_par07" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"08","Dt Historico Até "     ,"Dt Historico Até "       ,"Dt Historico Até "       ,"mv_ch8","D",08,0,0,"G",""          ,""   ,"","","mv_par08" ,"","","","","","","","","","","","","","",""," ")
     
Pergunte(cPerg,.F.)

cString := "SF2"
titulo  := "COBERTURA INTELIGENTE"
cDesc1  := "Este programa tem como objetivo efetuar a impressao do relatorio"
cDesc2  := "de cobertura inteligente"
cDesc3  := "By Ad'Oro"
NomeRel := "COBINTEL"

nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//Mauricio convertido arquivo saida excel(EXC) para uso como TEMP novo (abaixo)....saida excel sera em .CSV a ser implementado tratamento.
aCampos := {}

If Select("TEMP") > 0
   DbSelectArea("TEMP")
   DbCloseArea("TEMP")
Endif

AADD(aCampos,{"VENDEDOR"  , "C", 006,0})
AADD(aCampos,{"NOME"      , "C", 020,0})
AADD(aCampos,{"SUPER "    , "C", 020,0})
AADD(aCampos,{"CLIENTE"   , "C", 006,0})
AADD(aCampos,{"LOJA"      , "C", 002,0})
AADD(aCampos,{"RAZAO"     , "C", 025,0})
AADD(aCampos,{"ORDEM"     , "C", 001,0})
AADD(aCampos,{"CPMA"      , "C", 001,0})
AADD(aCampos,{"RFRG"      , "C", 001,0})
AADD(aCampos,{"RPT"       , "C", 001,0})
AADD(aCampos,{"RCOX"      , "C", 001,0})
AADD(aCampos,{"RASA"      , "C", 001,0})
AADD(aCampos,{"RFILE"     , "C", 001,0})
AADD(aCampos,{"DTAMB"     , "C", 001,0})
AADD(aCampos,{"D50PT"     , "C", 001,0})
AADD(aCampos,{"DFCXC"     , "C", 001,0})
AADD(aCampos,{"DFCXS"     , "C", 001,0})
AADD(aCampos,{"DFATI"     , "C", 001,0})
AADD(aCampos,{"MPASS"     , "C", 001,0})
AADD(aCampos,{"MCOXI"     , "C", 001,0})
AADD(aCampos,{"M50AS"     , "C", 001,0})
AADD(aCampos,{"NSALS"     , "C", 001,0})
AADD(aCampos,{"NCOX"      , "C", 001,0})
AADD(aCampos,{"NMIUD"     , "C", 001,0})     &&Em 10/04/13 - vagner exclui subgrupo miudo e criou coracao CORAC, mas continuei gravando no mesmo campo...
AADD(aCampos,{"N50AS"     , "C", 001,0})	 &&Idem acima incluido 1/2 Asa....	
cArqEXC := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cArqEXC,"TEMP",.F.,.F.)
cIndexB   := "VENDEDOR + ORDEM + CLIENTE + LOJA"
IndRegua( "TEMP", cArqExc, cIndexB,,,"Criando Indice ..." )

dbSelectArea("TEMP")
dbSetOrder(1)
	
Cabec1 := " COBINTEL.PRX "+SPACE(34)+TITULO+SPACE(10) + "DT ATUAL De-Ate : " +DTOC(MV_PAR05)+"-" +DTOC(MV_PAR06)+ " DT HIST. De-Ate: "  +DTOC(MV_PAR07)+"-" +DTOC(MV_PAR08)
Cabec2 := " Legenda: Branco->Nunca Comprou; R->Reposicao; P->Positivação; N->Nao Comprou atual"
Cabec3 := ""                   
Cabec3 := "Vendedor                  Supervisor|Compra|           RESFRIADOS            |              DESSOSSADOS                  |       MARINADOS       |     NOVOS PRODUTOS              |"       
Cabec4 := "Cliente                             |  MA  |   FRG  | PT  | CX | ASA | FILE  | TAMB | FCX C/P | FCX S/P | FATIA | 1/2 PT |  PASS | COXI | 1/2ASA | SALS | COXIN | CORAC  | 1/2ASA  |"
Cabec5 := "                                    |      |        |     |    |     |       |      |         |         |       |        |       |      |        |      |       |        |         |" 
//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890  
//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15

&&Verifica se o usuario emissor do relatório é Diretor ou Não.
_cCodUsua := __cUserID
_lDiret  := .F.
_lSuperv := .F.
_lVended := .F.
_cCodigo := Space(06)
if _cCodUsua $ "000460/001169"  &&Mauricio 06/02/13 - Vagner solicitou liberar para usuarios Thaina e Thais uso do relatorio
   _lDiret := .T.
Else
   DbSelectArea("SA3")
   DbSetOrder(7)
   if dbseek(xFilial("SA3")+_cCodUsua)
      If SA3->A3_NIVETAB == "4"
         _lDiret := .T.
      Elseif SA3->A3_NIVETAB == "3"
         _lDiret := .T.         
      Elseif SA3->A3_NIVETAB == "2"
         _lSuperv := .T.
         _cCodigo := SA3->A3_CODSUP
      Else
         _lVended := .T.
         _cCodigo := SA3->A3_COD        
      Endif
   Else
      MsgInfo("Seu usuario não possui cadastro na tabela de vendedores e não podera emitir este relatorio.","Atenção")
      Return()
   Endif
Endif

Processa({|| fSeleciona()},Titulo )    &&todos clientes SA1 com vendedores

//RptStatus({|| RunCont() },Titulo)

Processa({|| RunCont()},Titulo )
Return
	
Static Function RunCont()

DbSelectArea("TEMP")
DbGotop()
ProcRegua(RecCount())

While TEMP->(!EOF())
	  _cVend     := TEMP->VENDEDOR
	  _cCliente	 := TEMP->CLIENTE
	  _cLoja     := TEMP->LOJA
	  	
	  IncProc("Vendedor/Cliente/Loja :"+_cVend+"/"+_cCliente+"/"+_cLoja)	
	  
	  &&calculo se cliente comprou qualquer produto mes atual
	  _lCp := .F.
	  _lCp := qqprodMA(TEMP->CLIENTE,TEMP->LOJA)
	  DbSelectArea("TEMP")
	  If _lCP
	     RecLock("TEMP",.F.)
	     TEMP->CPMA := "S"
	     TEMP->(MsUnlock())
	  Else
	     RecLock("TEMP",.F.)
	     TEMP->CPMA := "N"
	     TEMP->(MsUnlock())
	  Endif
	  
	  &&calculo se cliente comprou produtos ZZ5 no periodo atual/periodo historico
	  
	  &&grupo Resfriados
	  DbSelectArea("ZZ5")
	  DbSetOrder(2)      
	  if dbseek(xFilial("ZZ5")+"RESFRIADOS     ")
	     _cGrupo  := ZZ5->ZZ5_GRUPO	    	     
	     While ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO
	           _cSubG := ZZ5->ZZ5_SUBGRP
	           _lCpPatu := .F.
	           _lCpPhis := .F.
	           While  ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO .And. _cSubG == ZZ5->ZZ5_SUBGRP
	                  If !_lCpPatu
	                     _lCpPatu := fBscPAtu(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif
	                  If !_lCpPhis   
	                     _lCpPhis := fBscPHis(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif   
	                  ZZ5->(dbSkip())
	           Enddo       
	           If _lCpPatu .And. _lCpPhis  &&R comprou no historico e no atual tambem
	              If Alltrim(_cSubG) == "FRG"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFRG := "R"	            	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RPT := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFILE := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->RCOX := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "ASA"
	                 Reclock("TEMP",.F.)
	                 TEMP->RASA := "R"	              
	                 TEMP->(MsUnlock())
	              Endif   	                 
	           Elseif !_lCpPatu .And. !_lCpPhis  &&branco..nao comprou no atual e nem no historico
	              If Alltrim(_cSubG) == "FRG"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFRG := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RPT := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFILE := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->RCOX := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "ASA"
	                 Reclock("TEMP",.F.)
	                 TEMP->RASA := " "	              
	                 TEMP->(MsUnlock())
	              Endif	              	              	              	             	              
	           Elseif _lCpPatu .And. !_lCpPhis   && P comprou no atual e nao comprou no historico
	              If Alltrim(_cSubG) == "FRG"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFRG := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RPT := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFILE := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->RCOX := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "ASA"
	                 Reclock("TEMP",.F.)
	                 TEMP->RASA := "P"	              
	                 TEMP->(MsUnlock())
	              Endif
	           Elseif !_lCpPatu .And. _lCpPhis  && N nao comprou no atual mas comprou no historico
	              If Alltrim(_cSubG) == "FRG"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFRG := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RPT := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->RFILE := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->RCOX := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "ASA"
	                 Reclock("TEMP",.F.)
	                 TEMP->RASA := "N"	              
	                 TEMP->(MsUnlock())
	              Endif
	          Endif    	           	           	           	           	           
	     Enddo
	  Endif
	  
	  &&grupo dessossados
	  DbSelectArea("ZZ5")
	  Dbgotop()
	  if dbseek(xFilial("ZZ5")+"DESOSSADOS     ")
	     _cGrupo  := ZZ5->ZZ5_GRUPO	    	     
	     While ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO
	           _cSubG := ZZ5->ZZ5_SUBGRP
	           _lCpPatu := .F.
	           _lCpPhis := .F.
	           While  ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO .And. _cSubG == ZZ5->ZZ5_SUBGRP
	                  If !_lCpPatu
	                     _lCpPatu := fBscPAtu(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif
	                  If !_lCpPhis   
	                     _lCpPhis := fBscPHis(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif   
	                  ZZ5->(dbSkip())
	           Enddo       
	           If _lCpPatu .And. _lCpPhis  &&R comprou no historico e no atual tambem
	              If Alltrim(_cSubG) == "MEIOPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->D50PT := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXCP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXC := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXSP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXS := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FATIA"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFATI := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "TAMB"
	                 Reclock("TEMP",.F.)
	                 TEMP->DTAMB := "R"	              
	                 TEMP->(MsUnlock())
	              Endif   	                 
	           Elseif !_lCpPatu .And. !_lCpPhis  &&branco..nao comprou no atual e nem no historico
	              If Alltrim(_cSubG) == "MEIOPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->D50PT := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXCP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXC := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXSP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXS := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FATIA"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFATI := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "TAMB"
	                 Reclock("TEMP",.F.)
	                 TEMP->DTAMB := " "	              
	                 TEMP->(MsUnlock())
	              Endif   	              	              	             	              
	           Elseif _lCpPatu .And. !_lCpPhis   && P comprou no atual e nao comprou no historico
	              If Alltrim(_cSubG) == "MEIOPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->D50PT := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXCP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXC := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXSP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXS := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FATIA"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFATI := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "TAMB"
	                 Reclock("TEMP",.F.)
	                 TEMP->DTAMB := "P"	              
	                 TEMP->(MsUnlock())
	              Endif
	           Elseif !_lCpPatu .And. _lCpPhis  && N nao comprou no atual mas comprou no historico
	              If Alltrim(_cSubG) == "MEIOPT"
	                 Reclock("TEMP",.F.)
	                 TEMP->D50PT := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXCP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXC := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FCXSP"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFCXS := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "FATIA"
	                 Reclock("TEMP",.F.)
	                 TEMP->DFATI := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "TAMB"
	                 Reclock("TEMP",.F.)
	                 TEMP->DTAMB := "N"	              
	                 TEMP->(MsUnlock())
	              Endif
	          Endif    	           	           	           	           	           
	     Enddo
	  Endif
	  
	  &&grupo Marinados
	  DbSelectArea("ZZ5")
	  Dbgotop()
	  if dbseek(xFilial("ZZ5")+"MARINADOS      ")
	     _cGrupo  := ZZ5->ZZ5_GRUPO	    	     
	     While ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO
	           _cSubG := ZZ5->ZZ5_SUBGRP
	           _lCpPatu := .F.
	           _lCpPhis := .F.
	           While  ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO .And. _cSubG == ZZ5->ZZ5_SUBGRP
	                  If !_lCpPatu
	                     _lCpPatu := fBscPAtu(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif
	                  If !_lCpPhis   
	                     _lCpPhis := fBscPHis(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif   
	                  ZZ5->(dbSkip())
	           Enddo       
	           If _lCpPatu .And. _lCpPhis  &&R comprou no historico e no atual tambem
	              If Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->M50AS := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->MCOXI := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PASS"
	                 Reclock("TEMP",.F.)
	                 TEMP->MPASS := "R"	              
	                 TEMP->(MsUnlock())	              
	              Endif   	                 
	           Elseif !_lCpPatu .And. !_lCpPhis  &&branco..nao comprou no atual e nem no historico
	              If Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->M50AS := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->MCOXI := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PASS"
	                 Reclock("TEMP",.F.)
	                 TEMP->MPASS := " "	              
	                 TEMP->(MsUnlock())	              
	              Endif   	              	              	             	              
	           Elseif _lCpPatu .And. !_lCpPhis   && P comprou no atual e nao comprou no historico
	              If Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->M50AS := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->MCOXI := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PASS"
	                 Reclock("TEMP",.F.)
	                 TEMP->MPASS := "P"	              
	                 TEMP->(MsUnlock())	              
	              Endif
	           Elseif !_lCpPatu .And. _lCpPhis  && N nao comprou no atual mas comprou no historico
	              If Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->M50AS := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->MCOXI := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "PASS"
	                 Reclock("TEMP",.F.)
	                 TEMP->MPASS := "N"	              
	                 TEMP->(MsUnlock())	              
	              Endif
	          Endif               	           	           	           	           
	     Enddo
      Endif
	  
	  &&grupo Novos produtos
	  DbSelectArea("ZZ5")
	  Dbgotop()
	  if dbseek(xFilial("ZZ5")+"NV PRODUTOS    ")
	     _cGrupo  := ZZ5->ZZ5_GRUPO	    	     
	     While ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO
	           _cSubG := ZZ5->ZZ5_SUBGRP
	           _lCpPatu := .F.
	           _lCpPhis := .F.
	           While  ZZ5->(!Eof()) .And. _cGrupo == ZZ5->ZZ5_GRUPO .And. _cSubG == ZZ5->ZZ5_SUBGRP
	                  If !_lCpPatu
	                     _lCpPatu := fBscPAtu(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif
	                  If !_lCpPhis   
	                     _lCpPhis := fBscPHis(_cCliente,_cLoja,ZZ5->ZZ5_COD)
	                  Endif   
	                  ZZ5->(dbSkip())
	           Enddo       
	           If _lCpPatu .And. _lCpPhis  &&R comprou no historico e no atual tambem
	              If Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->NCOX := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "CORAC"  &&10/04/13 por solicitacao Vagner trocado MIUDO por CORACAO(ZZ5)
	                 Reclock("TEMP",.F.)
	                 TEMP->NMIUD := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "SALS"
	                 Reclock("TEMP",.F.)
	                 TEMP->NSALS := "R"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->N50AS := "R"	              
	                 TEMP->(MsUnlock())   
	              Endif   	                 	                 
	           Elseif !_lCpPatu .And. !_lCpPhis  &&branco..nao comprou no atual e nem no historico
	              If Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->NCOX := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "CORAC"
	                 Reclock("TEMP",.F.)
	                 TEMP->NMIUD := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "SALS"
	                 Reclock("TEMP",.F.)
	                 TEMP->NSALS := " "	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->N50AS := " "	              
	                 TEMP->(MsUnlock())   
	              Endif
	              	                	              	              	             	              
	           Elseif _lCpPatu .And. !_lCpPhis   && P comprou no atual e nao comprou no historico
	              If Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->NCOX := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "CORAC"
	                 Reclock("TEMP",.F.)
	                 TEMP->NMIUD := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "SALS"
	                 Reclock("TEMP",.F.)
	                 TEMP->NSALS := "P"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->N50AS := "P"	              
	                 TEMP->(MsUnlock())   
	              Endif
	           Elseif !_lCpPatu .And. _lCpPhis  && N nao comprou no atual mas comprou no historico
	              If Alltrim(_cSubG) == "COXI"
	                 Reclock("TEMP",.F.)
	                 TEMP->NCOX := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "CORAC"
	                 Reclock("TEMP",.F.)
	                 TEMP->NMIUD := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "SALS"
	                 Reclock("TEMP",.F.)
	                 TEMP->NSALS := "N"	              
	                 TEMP->(MsUnlock())
	              Elseif Alltrim(_cSubG) == "MEIOAS"
	                 Reclock("TEMP",.F.)
	                 TEMP->N50AS := "N"	              
	                 TEMP->(MsUnlock())   
	              Endif
	           Endif    	           	           	           	           	           
	     Enddo
	  Endif
	  DbSelectArea("TEMP")	  	     	  
	  TEMP->(dbskip())	  	
Enddo

cPath    := AllTrim(GetTempPath())
cArq     := "COBINTEL.CSV"

if file(cPath+"\COBINTEL.CSV")
	FErase(cPath+"\COBINTEL.CSV")		
endif

if file("\SYSTEM\COBINTEL.CSV")
	FErase("\SYSTEM\COBINTEL.CSV")
endif

nHdl := fCreate(cArq,0)
_Vazia := ";;;;;;;;;;;;;;;;;;;;;;"+_eof
cLin := ""
&&23 colunas
//cLin := ";;;;;;;;;;;SEM 1;;;SEM 2;;;SEM 3;;;SEM 4;;;SEM 5;;;;;;;;;Dias Corr.:;"+Transform(MV_PAR01,"@E 999")+";"+_eof
//fWrite(nHdl,cLin,Len(cLin))
//          1       2       3        4      5      6             7            8       9        10       11         12         13        14           15             16           17           18          19         20              21            22          23
cLin := "Vendedor;Nome;Supervisor;Cliente;Loja;Nome Cliente;Compra atual;Resf. FRG;Resf. PT;Resf. CX;Resf. Asa; Resf. File;Dess.Tamb;Dess. FCX CP;Dess. FCX SP;Dess. Fatia.;Dess. 1/2 PT;Marin. Pass.;Marin. CX;Marin. 1/2 Asa;NV Prod. Sals.;NV Prod. CX;NV Prod. Miudos"+_eof
fWrite(nHdl,cLin,Len(cLin))
fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco
                 
 
&&inicio da impressão do relatorio
DbSelectArea("TEMP")
DbGotop()

While TEMP->(!EOF())
      cLin := ""
      _cVend := TEMP->VENDEDOR
      If nLin > 60
         ImpCabec()
         nLin := nLin + 2
      Endif      
      incproc("Gerando a impressao ...")
      @nlin,000 Psay _cVend
      @nLin,009 Psay Alltrim(TEMP->NOME)
      @nLin,029 Psay TEMP->SUPER
      cLin += _cVend+";"
      cLin += Alltrim(TEMP->NOME)+";"
      cLin += TEMP->SUPER+";"
      //@nLin,036 Psay _cLin2
      nLin ++
      While TEMP->(!Eof()) .And. _cVend == TEMP->VENDEDOR
            If nLin > 60
               ImpCabec()
               nLin := nLin + 2
            Endif 
            @nLin,000 Psay TEMP->CLIENTE+"-"+TEMP->LOJA
            cLin += TEMP->CLIENTE + ";"
            cLin += TEMP->LOJA + ";"
            @nLin,011 Psay TEMP->RAZAO
            cLin += TEMP->RAZAO + ";"
            @nLin,036 Psay "|"
            @nLin,040 Psay TEMP->CPMA
            cLin += TEMP->CPMA + ";"
            @nLin,043 Psay "|"
            @nLin,048 Psay TEMP->RFRG
            cLin += TEMP->RFRG + ";"
            @nLin,052 Psay "|"
            @nLin,055 Psay TEMP->RPT
            cLin += TEMP->RPT + ";"
            @nLin,058 Psay "|"
            @nLin,061 Psay TEMP->RCOX
            cLin += TEMP->RCOX + ";"
            @nLin,063 Psay "|"
            @nLin,066 Psay TEMP->RASA
            cLin += TEMP->RASA + ";"
            @nLin,069 Psay "|"
            @nLin,073 Psay TEMP->RFILE
            cLin += TEMP->RFILE + ";"
            @nLin,077 Psay "|"
            @nLin,080 Psay TEMP->DTAMB
            cLin += TEMP->DTAMB + ";"
            @nLin,084 Psay "|"
            @nLin,089 Psay TEMP->DFCXC
            cLin += TEMP->DFCXC + ";"
            @nLin,094 Psay "|"
            @nLin,099 Psay TEMP->DFCXS
            cLin += TEMP->DFCXS + ";"
            @nLin,104 Psay "|"
            @nLin,108 Psay TEMP->DFATI
            cLin += TEMP->DFATI + ";"
            @nLin,112 Psay "|"
            @nLin,116 Psay TEMP->D50PT
            cLin += TEMP->D50PT + ";"
            @nLin,121 Psay "|"
            @nLin,125 Psay TEMP->MPASS
            cLin += TEMP->MPASS + ";"
            @nLin,129 Psay "|"
            @nLin,132 Psay TEMP->MCOXI
            cLin += TEMP->MCOXI + ";"
            @nLin,136 Psay "|"
            @nLin,140 Psay TEMP->M50AS
            cLin += TEMP->M50AS + ";"
            @nLin,145 Psay "|"
            @nLin,149 Psay TEMP->NSALS
            cLin += TEMP->NSALS + ";"
            @nLin,152 Psay "|"
            @nLin,156 Psay TEMP->NCOX
            cLin += TEMP->NCOX + ";"
            @nLin,160 Psay "|"
            @nLin,164 Psay TEMP->NMIUD
            cLin += TEMP->NMIUD + ";"+_eof
            @nLin,169 Psay "|"
            fWrite(nHdl,cLin,Len(cLin))
		    cLin := ";;;"                                                                             
            nLin ++
            TEMP->(dbSkip())   
      Enddo
      fWrite(nHdl,_Vazia,Len(_vazia))  &&linha vazia
      @nLin,000 Psay _cLin1
      nLin ++                                     
ENDDO
 
Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

Ms_Flush()

fClose(nHdl)

bBloco:={|| _fOpenExcel()}
MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)

dbSelectArea('TEMP')
dbclosearea("TEMP")
//fErase(_cNomTrb+'.*')

return

Static Function fSeleciona()
Local cQuery:=""

If Select("VCLI") > 0
   DbSelectArea("VCLI")
   DbCloseArea("VCLI")
Endif

cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME, A3_CODSUP, A3_NOME, A1_VEND "
cQuery += "FROM "+retsqlname("SA1") +" A1, "+retsqlname("SA3") +" A3 "
cQuery += "WHERE A1_VEND >= '"+mv_par01+"' AND A1_VEND <= '"+mv_par02+"' AND "
cQuery += "A1_VEND = A3_COD   AND (A3_CODSUP  BETWEEN '"+ (mv_par03) +"' AND  '"+(mv_par04) +"') AND "
//cQuery += "(A1_COD = '001312' OR A1_COD = '006858' OR A1_COD = '007350' OR A1_COD = '032322' OR A1_COD = '032557' OR A1_COD = '011584' OR A1_COD = '019342') AND "  &&somente para testes utilizando vendedor 000001
If !_ldiret
   If _lVended  &&vendedor só enxerga o seu proprio cliente
      cQuery += "A3_COD = '"+_cCodigo+"' AND "                                              
   Endif
   If _lSuperv
      cQuery += "A3_CODSUP = '"+_cCodigo+"' AND "  
   Endif
Endif     
cQuery += "A1.D_E_L_E_T_ <> '*' AND A3.D_E_L_E_T_ <> '*' " 
cQuery += "ORDER BY A1_VEND, A1_COD, A1_LOJA" 

TCQUERY cQuery NEW ALIAS "VCLI" 

dbselectArea("VCLI")
DbgoTop()
While VCLI->(!Eof())
      RecLock("TEMP",.T.)
      TEMP->VENDEDOR := VCLI->A1_VEND
      TEMP->NOME     := VCLI->A3_NOME
      TEMP->SUPER    := Posicione("SA3",10,xFilial("SA3")+VCLI->A3_CODSUP,"A3_NOME")
      TEMP->CLIENTE  := VCLI->A1_COD
      TEMP->LOJA     := VCLI->A1_LOJA
      TEMP->RAZAO    := VCLI->A1_NOME
      TEMP->ORDEM    := "B"                 
      TEMP->(MsUnlock())
      dbselectArea("VCLI")
      VCLI->(dbSkip())
Enddo                            

Return()

//******************************************************************************
Static Function ImpCabec()
//******************************************************************************
nLin := 1

//@nLin,00 PSAY "|"+Replic("-",78)+"|"
//nLin := nLin + 1

@ nlin,00 PSAY Cabec1
nLin := nLin + 1

@nLin,00 PSAY Cabec2
nLin := nLin + 1

@nLin,00 PSAY Cabec3
nLin := nLin + 1

@nLin,00 PSAY Cabec4
nLin := nLin + 1

@nLin,00 PSAY Cabec5
//nLin := nLin + 1

Return()


Static Function _fOpenExcel()
CpyS2T("\SYSTEM\COBINTEL.CSV",cPath,.T.)

FerasE("\SYSTEM\COBINTEL.CSV")

If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return()

Static function qqprodMa(_cCli,_cLj)
Local _lRet := .F.
Local cQuery:=""

If Select("xCMP") > 0
   DbSelectArea("xCMP")
   DbCloseArea("xCMP")
Endif

cQuery := "SELECT D2_CLIENTE, D2_LOJA "
cQuery += "FROM "+retsqlname("SD2") +" D2 "
cQuery += "WHERE D2_CLIENTE = '"+_cCli+"' AND D2_LOJA = '"+_cLj+"' AND "
cQuery += "D2_EMISSAO BETWEEN '"+ DTOS(mv_par05) +"' AND  '"+DTOS(mv_par06) +"' AND "
cQuery += "D2_QUANT > D2_QTDEDEV AND "   &&se devolvido total desconsidera...
cQuery += "D2.D_E_L_E_T_ <> '*' " 

TCQUERY cQuery NEW ALIAS "xCMP" 

dbselectArea("xCMP")
DbgoTop()
While xCMP->(!Eof())
      If _lRet
         exit
      Endif   
      _lRet := .T.
      xCMP->(dbSkip())      
Enddo

Return(_lRet)

Static function fBscPAtu(_cCli,_cLj,_cPrd)
Local _lRet := .F.
Local cQuery:=""

If Select("xCMP") > 0
   DbSelectArea("xCMP")
   DbCloseArea("xCMP")
Endif

cQuery := "SELECT D2_CLIENTE, D2_LOJA "
cQuery += "FROM "+retsqlname("SD2") +" D2 "
cQuery += "WHERE D2_CLIENTE = '"+_cCli+"' AND D2_LOJA = '"+_cLj+"' AND "
cQuery += "D2_EMISSAO BETWEEN '"+ DTOS(mv_par05) +"' AND  '"+DTOS(mv_par06) +"' AND "
cQuery += "D2_COD = '"+ _cPrd +"' AND "
cQuery += "D2_QUANT > D2_QTDEDEV AND "   &&se devolvido total desconsidera...
cQuery += "D2.D_E_L_E_T_ <> '*' " 

TCQUERY cQuery NEW ALIAS "xCMP" 

dbselectArea("xCMP")
DbgoTop()
While xCMP->(!Eof())
       If _lRet
         exit
      Endif   
      _lRet := .T.
      xCMP->(dbSkip())
Enddo

Return(_lRet)

Static function fBscPHis(_cCli,_cLj,_cPrd)
Local _lRet := .F.
Local cQuery:=""

If Select("xCMP") > 0
   DbSelectArea("xCMP")
   DbCloseArea("xCMP")
Endif
 
cQuery := "SELECT D2_CLIENTE, D2_LOJA "
cQuery += "FROM "+retsqlname("SD2") +" D2 "
cQuery += "WHERE D2_CLIENTE = '"+_cCli+"' AND D2_LOJA = '"+_cLj+"' AND "
cQuery += "D2_EMISSAO BETWEEN '"+ DTOS(mv_par07) +"' AND  '"+DTOS(mv_par08) +"' AND "
cQuery += "D2_COD = '"+ _cPrd +"' AND "
cQuery += "D2_QUANT > D2_QTDEDEV AND "   &&se devolvido total desconsidera...
cQuery += "D2.D_E_L_E_T_ <> '*' " 

TCQUERY cQuery NEW ALIAS "xCMP" 

dbselectArea("xCMP")
DbgoTop()
While xCMP->(!Eof())
       If _lRet
         exit
      Endif   
      _lRet := .T.
      xCMP->(dbSkip())
Enddo

Return(_lRet)