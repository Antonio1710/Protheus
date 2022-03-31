#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ACOMPVEN
   (Acompanhamento de vendas ( COMERCIAL ) )
   @type  Function
   @author Mauricio-MDS TEC 
   @since 11/04/2012
   @version 01
   @histrory TICKET 70540 - ADRIANO SAVOINE - 30/03/2022 - Corrigido o Parametro para entrar com as filiais corretas.
   /*/
         
User Function ACOMPVEN() 
  
SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")


aOrd             := {}
tamanho          := "G"
limite           := 220
nomeprog         := "ACOMPVEN"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.
cPerg            := "ACPVEN"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T. 

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Acompanhamento de vendas ( COMERCIAL )')

Aadd(aHelpPor, 'Selecione as filiais a serem') 
Aadd(aHelpPor, 'utilizadas.')
Aadd( aHelpSpa, '')
Aadd( aHelpEng, '')
PutSX1(cPerg,"01","Data Entrega De "          ,"Data Entrega De "          ,"Data Entrega De "          ,"mv_ch1","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"02","Data Entrega Ate"          ,"Data Entrega Ate"          ,"Data Entrega Ate"          ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
PutSx1(cPerg,"03","Seleciona filiais","","","mv_ch3","C",50,0,0,"G","U_FXFIL()","","","",;
       "mv_par03","","","","","","","","",;
       "","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
PutSX1(cPerg,"04","Supervisor De "          ,"Supervisor De "          ,"Supervisor De "          ,"mv_ch4","C",06,0,0,"G",""         ,"A06","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"05","Supervisor Ate"          ,"Supervisor Ate"          ,"Supervisor Ate"          ,"mv_ch5","C",06,0,0,"G",""         ,"A06","","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"06","Grupo De" ,"Grupo De","Grupo De","mv_ch6","C",4,0,0,"G","","SBM","","","mv_par06" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"07","Grupo Ate","Grupo Ate","Grupo Ate","mv_ch7","C",4,0,0,"G","","SBM","","","mv_par07" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSx1(cPerg,"08","Excecao grupos?"," "," ","mv_ch8","C",99,0,0,	"G","","","","","mv_par8"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informar grupos a serem desconsiderados separados por '/' "},{"Informar grupos a serem desconsiderados separados por '/' "},{"Informar grupos a serem desconsiderados separados por '/' "})
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SC6"
titulo  := "ACOMPANHAMENTO DAS VENDAS "
cDesc1  := "Este programa tem como objetivo imprimir posicao relativa"
cDesc2  := "ao Acompanhamento de venda por data de entrega"
cDesc3  := "By Ad'Oro"
NomeRel := "ACOMPVEN"

//TICKET 70540 - ADRIANO SAVOINE - 30/03/2022
IF TYPE(mv_par03) == "N" .OR. TYPE(mv_par03) == "U"

   MsgAlert("SELECIONE NOS PARAMETROS AS FILIAIS, PARA GERAR ESTE RELATORIO.", "ATENCAO!!!")

   nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

   U_ACOMPVEN()

   ELSE

   nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

ENDIF


If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

_lDiret := .F.
_lGerent := .F.
_lSuperv := .F.
_lVended := .F.
_cVended := ""

_cCodUsua := __cUserID
DbSelectArea("SA3")
DbSetOrder(7)
if dbseek(xFilial("SA3")+_cCodUsua)
   If SA3->A3_NIVETAB == "4"
      _lDiret := .T.
   Elseif SA3->A3_NIVETAB == "3"
      _lGerent := .T.
      _cCodigo := SA3->A3_COD
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

&&Mauricio 21/12/11 - filtra os vendedores que entrarão no relatorio.
fFilVend() 

If Empty(_cVended) .And. !(_lDiret)
   MsgInfo("Nao ha dados a ser apresentados para o seu usuario.","Atenção")
   Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o cabecalho padrao para o relatorio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec1 := " ACOMPVEN.PRX "+SPACE(34)+TITULO+SPACE(10) + "Data de : " +DTOC(mv_par01)+SPACE(05) + "até : " + DTOC(MV_PAR02)
Cabec2 := ""
Cabec3 := "Legenda: " 
_aCab  := {}
_aCab1 := {}
&&original funcionando

DbSelectArea("ZZV")       &&crio o cabecalho dinamico
DbSetorder(1)
Dbgotop()
While ZZV->(!Eof())
      _nAscan := Ascan( _aCab, { |x|x[ 01 ] == ZZV->ZZV_AGRUP } )
      If _nAscan <= 00
         Aadd( _aCab, { ZZV->ZZV_AGRUP } )      
      EndIf  
      Cabec3 += ZZV->ZZV_AGRUP+"-"+ALLTRIM(ZZV->ZZV_DESCRI)+", "
      ZZV->(dbskip())
Enddo

DbSelectArea("ZZV")
DbSetorder(1)
Dbgotop()
While ZZV->(!Eof())
      _nAscan := Ascan( _aCab1, { |x|x[ 01 ] == ZZV->ZZV_AGRUP } )
      If _nAscan <= 00
         Aadd( _aCab1, { ZZV->ZZV_AGRUP,ALltrim(ZZV->ZZV_DESCRI) } )      
      EndIf        
      ZZV->(dbskip())                                                        
Enddo                                     
         
//AADD(_aCab, {" "})
//AADD(_aCab1, {" ","       "})
                  
Cabec3 := Substr(Cabec3,1,len(Cabec3)-2)                                                  //      1            2             3             4             5            6            7               8             9
Cabec4 := ""
Cabec5 := "VENDEDOR          TT CXS TT PEDIDO TT VALOR PRC MEDIO | Ped.     Cxs| Ped.    Cxs.|  Ped.   Cxs.|   Ped.  Cxs.|   Ped.  Cxs.|  Ped.   Cxs.|  Ped.   Cxs.|  Ped.   Cxs.|  Ped.   Cxs.|  Ped.   Cxs.|  Ped.   Cxs.|  Ped.   Cxs." 
//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890  
//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15

Processa({|| fSeleciona()},Titulo )

Processa({|| RunCont()},Titulo )
Return
	
Static Function RunCont()

Local _nx := 0
Local _io := 0
Local _xx := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para totalizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru := {}
AADD (aStru,{"TR_FILIAL"   , "C",02,0})
//AADD (aStru,{"TR_SUPERVI"  , "C",12,0})
AADD (aStru,{"TR_CODSUP"  , "C",06,0})
AADD (aStru,{"TR_NOMVEND"  , "C",12,0})
AADD (aStru,{"TR_VENDEDO"  , "C",06,0})
AADD (aStru,{"TR_PEDIDO"   , "C",06,0})
AADD (aStru,{"TR_PRODUTO"  , "C",15,0})  //6
AADD (aStru,{"TR_AGRUP"    , "C",01,0})
AADD (aStru,{"TR_DESCRI"   , "C",25,0})
AADD (aStru,{"TR_CAIXAS"   , "N",08,0})
AADD (aStru,{"TR_KILOS"    , "N",12,3})
AADD (aStru,{"TR_VALTOT"   , "N",12,2})
AADD (aStru,{"TR_PREMED"   , "N",12,2})
_cNomTrb := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

cIndex   := "TR_CODSUP + TR_VENDEDO + TR_FILIAL + TR_PEDIDO + TR_AGRUP + TR_PRODUTO"
IndRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )

dbSelectArea("TEMP")
dbSetOrder(1)
                                   
aStru := {}

AADD (aStru,{"VENDEDO"  , "C",06,0})
AADD (aStru,{"AGRUP"    , "C",01,0})
AADD (aStru,{"DESCRICAO", "C",25,0})
AADD (aStru,{"CAIXAS"   , "N",08,0})
AADD (aStru,{"QTPED"    , "N",08,0})

_cNomTrb1 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb1,"TEMP2",.F.,.F.)

cIndex2   := "VENDEDO + AGRUP"
IndRegua( "TEMP2", _cNomTrb1, cIndex2,,,"Criando Indice ..." )

dbSelectArea("TEMP2")
dbSetOrder(1)

aStru := {}

AADD (aStru,{"CARTEIRA" , "C",18,0})
AADD (aStru,{"AGRUP"    , "C",01,0})
AADD (aStru,{"CAIXAS"   , "N",08,0})
AADD (aStru,{"QTPED"    , "N",08,0})

_cNomTrb2 := CriaTrab(aStru)
dbUseArea(.T.,,_cNomTrb2,"TEMP3",.F.,.F.)

cIndex3   := "CARTEIRA + AGRUP"
IndRegua( "TEMP3", _cNomTrb2, cIndex3,,,"Criando Indice ..." )

dbSelectArea("TEMP3")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SA3")
dbSetOrder(1)

DbSelectArea("SZR")
dbSetOrder(1)

DbSelectArea("SC6")
dbSetOrder(1)

DbSelectArea("xSC6")
DbGotop()
ProcRegua(RecCount())

While xSC6->(!EOF())
	
	_Produto  := xSC6->C6_PRODUTO	
	_Vendedor := xSC6->C5_VEND1
	_Filial   := xSC6->C6_FILIAL
	_Pedido   := xSC6->C6_NUM
	_Qtd_Cxs  := xSC6->C6_UNSVEN
	_Val_Tot  := xSC6->C6_VALOR
	_Qtd_Qui  := xSC6->C6_QTDVEN
	
	dbSelectArea("SB1")
	
	dbSeek(xfilial("SB1") + _Produto)
		
	&&Mauricio - 14/12/16 - Chamado 031830 - Verificado problema com novo produto 520879 grupo 9028 aonde segundo Vagner nao
	&&eh pra ser considerado e pediu para filtrar o relatorio apenas para os grupo entre 0100 e 0999. 
	&&Implementado tambem aviso em tela caso agrupamento nao preenchido(BM_QBRNVL)
	
	&&Mauricio - 21/12/16 corrigido tratamento anterior implementando parametros no relatorio
	&&implementei filtro de parametro de grupo na select e abaixo só deixei a excessão.
	If !Empty(MV_PAR08)
	   IF Alltrim(SB1->B1_GRUPO) <= Alltrim(MV_PAR06) .Or. Alltrim(SB1->B1_GRUPO) > ALltrim(MV_PAR07)	      	      
             xSC6->(dbskip())
	         loop	        
	   Endif
	   IF Alltrim(SB1->B1_GRUPO) $ Alltrim(MV_PAR08)
	      xSC6->(dbskip())
	      loop
	   ENDIF   
	Endif   
		
	_cAgrup := Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_QBRNVL")
	
	IF Empty(_cAgrup)
	   MsgInfo("Produto/Grupo: "+Alltrim(_Produto)+"/"+SB1->B1_GRUPO+" com quebra nivel(agrupador) em branco no cadastro SBM!")
    Endif   
			
	//IF !(_cAgrup $ "B/A") &&apenas para filtro de debug em teste
	//   xSC6->(dbskip())
	//   loop
	//Endif
	
	dbSelectArea("SA3")
	dbSeek(xfilial("SA3") + _Vendedor)
	
	_Supervis := SA3->A3_CODSUP
	
	If _Supervis >= mv_par04	.AND.  _Supervis <= mv_par05
		dbSelectArea("SZR")				//CADASTRO DE SUPERVIDOR
		DBSETORDER(1)
		dbSeek(xfilial() + SA3->A3_CODSUP)
		//If SZR->ZR_SEGMERC >= mv_par05 .AND. SZR->ZR_SEGMERC <= mv_par06
			
			dbSelectArea("TEMP")
			
			IF !dbSeek(_Supervis + _Vendedor + _Filial + _Pedido + _cAgrup + _Produto)
				
				RecLock("TEMP",.T.)
				
				Repl TR_FILIAL   with _Filial
				Repl TR_CODSUP   with _Supervis
				Repl TR_VENDEDO  with _Vendedor
				Repl TR_NOMVEND  with SA3->A3_NREDUZ
				Repl TR_PEDIDO   with _Pedido
				Repl TR_PRODUTO  with _PRODUTO
				Repl TR_AGRUP    with _cAgrup
				Repl TR_CAIXAS   with _Qtd_Cxs
				Repl TR_KILOS    with _Qtd_Qui
				Repl TR_VALTOT   with _Val_Tot
				Repl TR_PREMED   with TR_VALTOT/TR_KILOS
				
				MsUnLock()
			ELSE
				// SOMAR AS QTD VENDIDAS NAS RESPECTIVOS GRUPOS
				
				RecLock("TEMP",.F.)
				
				Repl TR_CAIXAS   with TR_CAIXAS + _Qtd_Cxs
				Repl TR_KILOS    with TR_KILOS  + _Qtd_Qui
				Repl TR_VALTOT   with TR_VALTOT + _Val_Tot
				Repl TR_PREMED   with TR_VALTOT/TR_KILOS
				
				MsUnLock()
			Endif
		//endif
	endif
	xSC6->(dbskip())
ENDDO

&&Na segunda tabela temporaria trato os totais de pedidos/caixas e agrupadores por vendedor
DbSelectArea("TEMP")
DbGotop()
While TEMP->(!EOF())
      _cVend  := TEMP->TR_VENDEDO
      _nQtPed := 0                              
      _cFil   := TEMP->TR_FILIAL
      _cPed   := TEMP->TR_PEDIDO
      _cJunt  := TEMP->TR_AGRUP
                           
      While _cVend == TEMP->TR_VENDEDO
            &&Mauricio - 31/08/16 adicionado o agrupador na comparacao abaixo.             
            IF _cFil+_cPed + _cJunt == TEMP->TR_FILIAL+TEMP->TR_PEDIDO+TEMP->TR_AGRUP                   
                   _cAg    := TEMP->TR_AGRUP
                   _cDesc  := Posicione("ZZV",1,xfilial("ZZV")+_cAg,"ZZV_DESCRI")
                   
                  dbSelectArea("TEMP2")			
			      IF !dbSeek(_cVend + _cAg)				
				     RecLock("TEMP2",.T.)
			            TEMP2->VENDEDO   := _cVend
			            TEMP2->AGRUP     := _cAg
			            TEMP2->DESCRICAO := _cDesc
			            TEMP2->CAIXAS    := TEMP->TR_CAIXAS
                        TEMP2->QTPED     += 1  //_nQtPed
                     Msunlock()
                  Else      
                     Reclock("TEMP2",.F.)                     
                       TEMP2->CAIXAS    += TEMP->TR_CAIXAS                     
                     MsUnlock()
                  Endif                  
            Else
               _cAg    := TEMP->TR_AGRUP
               _cDesc  := Posicione("ZZV",1,xfilial("ZZV")+_cAg,"ZZV_DESCRI")
                   
                  dbSelectArea("TEMP2")			
			      IF !dbSeek(_cVend + _cAg)				
				     RecLock("TEMP2",.T.)
			            TEMP2->VENDEDO   := _cVend
			            TEMP2->AGRUP     := _cAg
			            TEMP2->DESCRICAO := _cDesc
			            TEMP2->CAIXAS    := TEMP->TR_CAIXAS
                        TEMP2->QTPED     += 1  //_nQtPed
                     Msunlock()
                  Else      
                     Reclock("TEMP2",.F.) 
                       TEMP2->QTPED     += 1                     
                       TEMP2->CAIXAS    += TEMP->TR_CAIXAS                     
                     MsUnlock()
                  Endif                 
            Endif
            _cJunt  := TEMP->TR_AGRUP
             _cFil  := TEMP->TR_FILIAL
            _cPed   := TEMP->TR_PEDIDO    
            DbSelectArea("TEMP")   
            TEMP->(dbskip())
      enddo 
      
Enddo

aSort( _aCab,,, { | x,y | x[ 01 ] < y[ 01 ] } )
aSort( _aCab1,,, { | x,y | x[ 01 ] < y[ 01 ] } )
 
Cabec4 := ""

For _nx := 1 to len(_aCab1)
    If _nx == 1       
          Cabec4 += SPACE(57)+PADR(Alltrim(_aCab1[_nx][2]),10," ")+Space(04)         //SPACE(083)
    else
       Cabec4 += PADR(Substr(Alltrim(_aCab1[_nx][2]),1,10),10," ")+Space(04)
    Endif             
next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A IMPRESSAO DO TEMP          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//titulo   := "REAL. DE VENDAS DIARIO - VENDEDOR "
//Cabec2 := SPACE(20)+ TITULO +SPACE(04)+ "Ate Entrega : " + DTOC(MV_PAR02)

_Vendedor := "   "
_TvCaixas := 0
_Tvkilos  := 0
_TvValtot := 0
_TsCaixas := 0
_Tskilos  := 0
_TsValtot := 0
_TtCaixas := 0
_Ttkilos  := 0
_TtValtot := 0
_nQtPed   := 0
_TSPED    := 0
_TTPED    := 0
_TECaixas := 0
_TEkilos  := 0
_TEValtot := 0
_TICaixas := 0
_TIkilos  := 0
_TIValtot := 0
_TEPed    := 0
_TIPed    := 0

_aTotSup := {}

_aTotGer := {}

_aTotEst := {}
_aTotInt := {}
_aTotVen := {}

_aTotFxCar := {}
_aTotFxTot := {}

dbSelectArea("TEMP")
dbGoTop()

While TEMP->(!EOF())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	IncProc(1)
	
	If nLin > 60
		ImpCabec()
		nLin := nLin + 1
	Endif
	
	_Supervis := TR_CODSUP
	dbSelectArea("SZR")				//CADASTRO DE SUPERVIDOR
	DBSETORDER(1)
	dbSeek(xfilial() + _Supervis)
	_cNomeSupervisor	:=	SZR->ZR_DESCRIC
	
	dbSelectArea("TEMP")
	
	DO WHILE TEMP->(!EOF()) .AND. TR_CODSUP == _Supervis
		
		_Vendedor  := TR_VENDEDO
		_nQtPed := 0
	
		DO WHILE !EOF() .AND. TR_VENDEDO == _vendedor .AND. TR_CODSUP == _Supervis   &&Mauricio
		    _cVend    := TR_VENDEDO
		    _cNVend   := SUBSTR(TR_NOMVEND,1,10)
		    _cPed     := TR_PEDIDO
		    _nQtPed += 1
		    While _cPed == TR_PEDIDO .AND. TR_VENDEDO == _vendedor .AND. TR_CODSUP == _Supervis  &&Mauricio
		          _Tvcaixas := _TVCaixas + TR_CAIXAS
			      _TvKILOS  := _TVKILOS  + TR_KILOS
			      _TvVALTOT := _TVVALTOT + TR_VALTOT			                    			
			      TEMP->(dBSkip())
			Enddo      
				
		Enddo
		 		
		@nLin,000 PSAY  _cVend + " " + _cNVend                       //001
		@nLin,017 PSAY  _Tvcaixas    PICTURE "@E 999999"             //027  020
		@nLin,025 PSAY  _nQtPed     PICTURE "@E 999.999"             //040  028
		@nLin,034 PSAY  _TvVALTOT    PICTURE "@E 9,999,999"       //054  042 037
		@nLin,042 PSAY  _TvVALTOT/_TvKILOS  PICTURE "@E 99,999.999"  //068  054 049
		
		DbSelectArea("ZZW")
		dbSetOrder(1)
		DbGotop()
		_lTrue := .T.   &&valido ter encontrado vendedor na tabela de faixa de carteira
		_cCart := ""
		While ZZW->(!EOF())
		      If alltrim(_cVend) >= ZZW->ZZW_FXINIC .And. alltrim(_cVend) <= ZZW->ZZW_FXFIM
		         _lTrue := .F.
		         _nAscan := Ascan( _aTotFxCar, { |x|x[ 01 ] == ZZW->ZZW_DESCFX } )
                 If _nAscan <= 00
                    AADD(_aTotFxCar,{ZZW->ZZW_DESCFX,_Tvcaixas,_nQtPed,_TvKILOS,_TvVALTOT})
                    _cCart := ZZW->ZZW_DESCFX
                 Else
                    _cCart := ZZW->ZZW_DESCFX
                    _aTotFxCar[ _nAscan ][ 02 ] += _Tvcaixas
                    _aTotFxCar[ _nAscan ][ 03 ] += _nQtPed
                    _aTotFxCar[ _nAscan ][ 04 ] += _TvKILOS
                    _aTotFxCar[ _nAscan ][ 05 ] += _TvVALTOT
                 EndIf
		         exit
		      Endif
		      ZZW->(dbskip())
		Enddo         		      		        		
		
		If _lTrue    &&não achou vendedor na tabela de faixas por carteira. Gravo como outros.
		   _nAscan := Ascan( _aTotFxCar, { |x|x[ 01 ] == "Outros " } )
           If _nAscan <= 00
              AADD(_aTotFxCar,{"Outros ",_Tvcaixas,_nQtPed,_TvKILOS,_TvVALTOT})
              _cCart := ZZW->ZZW_DESCFX
           Else
              _cCart := ZZW->ZZW_DESCFX
              _aTotFxCar[ _nAscan ][ 02 ] += _Tvcaixas
              _aTotFxCar[ _nAscan ][ 03 ] += _nQtPed
              _aTotFxCar[ _nAscan ][ 04 ] += _TvKILOS
              _aTotFxCar[ _nAscan ][ 05 ] += _TvVALTOT
           EndIf
		Endif
		
		dbSelectArea("TEMP")
		
		_nCol := 054         //080 066 061 tirado 14  +5  +7                                                           
		DbSelectArea("TEMP2")
		Dbsetorder(1)
		DbGotop()
		if dbseek(_cVend)		  
		   While TEMP2->(!eof()) .And. _cVend == TEMP2->VENDEDO    
		         _cAG := TEMP2->AGRUP	         
		         While _cAg == TEMP2->AGRUP	.And. _cVend == TEMP2->VENDEDO   &&Mauricio	              	              
		              _nAscan := Ascan( _aTotVen, { |x|x[ 01 ] == TEMP2->AGRUP } )
                      If _nAscan <= 00
                         AADD(_aTotVen,{TEMP2->AGRUP,TEMP2->QTPED,TEMP2->CAIXAS})
                      Else
                         _aTotVen[ _nAscan ][ 02 ] += TEMP2->QTPED
                         _aTotVen[ _nAscan ][ 03 ] += TEMP2->CAIXAS
                      EndIf
		              _nAscan := Ascan( _aTotSup, { |x|x[ 01 ] == TEMP2->AGRUP } )
                      If _nAscan <= 00
                         AADD(_aTotSup,{TEMP2->AGRUP,TEMP2->QTPED,TEMP2->CAIXAS})
                      Else
                         _aTotSup[ _nAscan ][ 02 ] += TEMP2->QTPED
                         _aTotSup[ _nAscan ][ 03 ] += TEMP2->CAIXAS
                      EndIf   		              
		              TEMP2->(dbSkip())
		         Enddo
		   Enddo
		   &&forço gravar todo o range de agrupadores possiveis para coincidir colunas
		   For _nx := 1 to len(_aCab)
		       _nAscan := Ascan( _aTotVen, { |x|x[ 01 ] == _aCab[_nx][1] } )
		       If _nAscan <= 00
                  AADD(_aTotVen,{_aCab[_nx][1],0,0})           
               EndIf
	       next		   
           &&impressão dos agrupadores daquele vendedor
           aSort( _aTotVen,,, { | x,y | x[ 01 ] < y[ 01 ] } )          
           For _nx := 1 to len(_aTotVen)
           
               @nLin,_nCol - 1 Psay "|"
		       @nLin,_nCol Psay _aTotVen[_nx][2] PICTURE "@E 99999"
		       _nCol += 07    //8
		       @nLin,_nCol Psay _aTotVen[_nx][3] PICTURE "@E 999999"
		       _nCol += 07	  //8
		       
		       &&gravo agrupadores em tabela temporaria por carteira e agrupador
		       DbSelectArea("TEMP3")
		       DbSetOrder(1)
		       DbGotop()
		       if dbseek(_cCart+_aTotVen[_nx][1])
		          Reclock("TEMP3",.F.)
		             TEMP3->QTPED  += _aTotVen[_nx][2]
		             TEMP3->CAIXAS += _aTotVen[_nx][3]
		          MsUnlock()
		       Else
		          Reclock("TEMP3",.T.)
		             TEMP3->CARTEIRA := _cCart
		             TEMP3->AGRUP    := _aTotVen[_nx][1]
		             TEMP3->QTPED    := _aTotVen[_nx][2]
		             TEMP3->CAIXAS   := _aTotVen[_nx][3]
		          MsUnlock()		             
		       Endif		       
		       		       
           Next
           _aTotVen := {}           
		Endif
		DbSelectArea("TEMP")
		              
		nLin := nLin + 1
										
		_Tscaixas := _TsCaixas + _TVCaixas
		_TSKILOS  := _TsKilos  + _TVKILOS
		_TSVALTOT := _TsValtot + _TVVALTOT
		_TSPED    := _TSPED + _nQtPed
		
		_TvCaixas := 0
		_Tvkilos  := 0
		_TvValtot := 0
		_nQtPed   := 0
		
		If nLin > 60
			ImpCabec()
			nLin := nLin + 1
		Endif
		
	ENDDO
		
	nLin := nLin + 1	
	@nLin,00 PSAY "TOT " + LEFT(_cNomeSupervisor,12)             //02
	@nLin,017 PSAY  _TsCAIXAS    PICTURE "@E 9999999"
	@nLin,025 PSAY  _TsPED     PICTURE "@E 999.999"
	@nLin,034 PSAY  _TsVALTOT    PICTURE "@E 9,999,999"
	@nLin,042 PSAY  _TsVALTOT/_TsKILOS    PICTURE  "@E 99,999.999"
	_nCol := 054 //080
	&&forço gravar todo o range de agrupadores possiveis para coincidir colunas
	For _nx := 1 to len(_aCab)
	    _nAscan := Ascan( _aTotSup, { |x|x[ 01 ] == _aCab[_nx][1] } )
	    If _nAscan <= 00
           AADD(_aTotSup,{_aCab[_nx][1],0,0})           
        EndIf
	next		   
    
    aSort( _aTotSup,,, { | x,y | x[ 01 ] < y[ 01 ] } )    
	For _nx := 1 to len(_aTotSup)
	    @nLin,_nCol - 1 Psay "|"
	    @nLin,_nCol Psay _aTotSup[_nx][2] PICTURE "@E 99999"
		_nCol += 07   //8
		@nLin,_nCol Psay _aTotSup[_nx][3] PICTURE "@E 999999"
		_nCol += 07   //8
		_nAscan := Ascan( _aTotGer, { |x|x[ 01 ] == _aTotSup[_nx][1] } )
        If _nAscan <= 00
           AADD(_aTotGer,{_aTotSup[_nx][1],_aTotSup[_nx][2],_aTotSup[_nx][3]})
        Else
          _aTotGer[ _nAscan ][ 02 ] += _aTotSup[_nx][2]
          _aTotGer[ _nAscan ][ 03 ] += _aTotSup[_nx][3]
        EndIf
	Next
	nLin := nLin + 2
    _aTotSup := {}
	
	_Ttcaixas := _TtCaixas + _TsCaixas
	_TtKILOS  := _TtKilos  + _TsKILOS
	_TtVALTOT := _TtValtot + _TsVALTOT
	_TTPED    := _TTPED + _TSPED
	
	_TsCaixas := 0
	_Tskilos  := 0
	_TsValtot := 0
	_TSPED    := 0
	//Nlin := 80
	
EndDo

nLin := nLin + 1
If nLin > 60
   ImpCabec()
   nLin := nLin + 2
Endif

@nLin,00 PSAY "TOTAL GERAL "                 //02
@nLin,017 PSAY  _TTCAIXAS    PICTURE "@E 9999999"
@nLin,025 PSAY  _TTPED     PICTURE "@E 9999.999"
@nLin,034 PSAY  _TTVALTOT    PICTURE "@E 9,999,999"
@nLin,042 PSAY  _TTVALTOT/_TTKILOS    PICTURE "@E 99,999.999"
_nCol := 054    //080
For _nx := 1 to len(_aCab)
	    _nAscan := Ascan( _aTotGer, { |x|x[ 01 ] == _aCab[_nx][1] } )
	    If _nAscan <= 00
           AADD(_aTotGer,{_aCab[_nx][1],0,0})           
        EndIf
Next		   
    
aSort( _aTotGer,,, { | x,y | x[ 01 ] < y[ 01 ] } ) 
For _nx := 1 to len(_aTotGer)
        @nLin,_nCol - 1 Psay "|"
	    @nLin,_nCol Psay _aTotGer[_nx][2] PICTURE "@E 9999"
		_nCol += 07  // 8
		@nLin,_nCol Psay _aTotGer[_nx][3] PICTURE "@E 999999"
		_nCol += 07	 // 8
Next

nLin := nLin + 1
If nLin > 60
   ImpCabec()
   nLin := nLin + 2
Endif
&&Verifico se faltam agrupadores
_aTemp3 := {}
For _nx := 1 to len(_aCab)
	    _nAscan := Ascan( _aTotEst, { |x|x[ 01 ] == _aCab[_nx][1] } )
	    If _nAscan <= 00
           AADD(_aTotEst,{_aCab[_nx][1],0,0})           
        EndIf
        DbSelectArea("TEMP3")
        DbSetOrder(1)
        Dbgotop()
        While TEMP3->(!EOF())
              _cCte := TEMP3->CARTEIRA
              _lAchou := .T.
              While TEMP3->CARTEIRA == _cCte
                    If TEMP3->AGRUP == _aCab[_nx][1]
                       _lAchou := .F.                       
                    Endif   
                    TEMP3->(dbSkip())
              Enddo
              If _lachou
                 AADD(_aTEMP3,{_cCte,_aCab[_nx][1],0,0})
              Endif
        Enddo                    
Next _nx

&&atualizo temp3 com agrupadores faltantes
For _io := 1 to len(_aTEMP3)
    DbSelectArea("TEMP3")
    DbSetOrder(1)                                          
    Dbgotop()
    If !dbseek(_aTemp3[_io][1]+_aTemp3[_io][2])   
       Reclock("TEMP3",.T.)
          TEMP3->CARTEIRA := _aTemp3[_io][1]
          TEMP3->AGRUP    := _aTemp3[_io][2]
          TEMP3->QTPED    := 0
          TEMP3->CAIXAS   := 0
       Msunlock()
    Endif
Next _io          		   

For _xx := 1 to len(_aTotFxCar)

    @nLin,00 PSAY "TOTAL "+alltrim(SUBSTR(_aTotFxCar[_xx][1],1,8))      //02
    @nLin,017 PSAY _aTotFxCar[_xx][2] PICTURE "@E 9999999"
    @nLin,025 PSAY _aTotFxCar[_xx][3] PICTURE "@E 9999.999"
    @nLin,034 PSAY _aTotFxCar[_xx][5] PICTURE "@E 9,999,999"
    @nLin,042 PSAY (_aTotFxCar[_xx][5]/_aTotFxCar[_xx][4]) PICTURE "@E 99,999.999"
    _nCol := 054   //080
    DbSelectArea("TEMP3")
    dbSetOrder(1)
    Dbgotop()
    If DbSeek(_aTotFxCar[_xx][1])
       While TEMP3->(!EOF()) .AND. _aTotFxCar[_xx][1] == TEMP3->CARTEIRA
             _cAgp := TEMP3->AGRUP
             While _cAgp == TEMP3->AGRUP .And. _aTotFxCar[_xx][1] == TEMP3->CARTEIRA
                  @nLin,_nCol - 1 Psay "|"
	              @nLin,_nCol Psay TEMP3->QTPED PICTURE "@E 9999"
		          _nCol += 07  // 8
		          @nLin,_nCol Psay TEMP3->CAIXAS PICTURE "@E 999999"
		          _nCol += 07	 // 8
                  TEMP3->(dbskip())
             Enddo
       Enddo
    Endif
    nLin := nLin + 1
    If nLin > 60
       ImpCabec()
       nLin := nLin + 2
    Endif
next _xx    

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

dbSelectArea('TEMP')
dbclosearea("TEMP")
fErase(_cNomTrb+'.*')

dbSelectArea('TEMP2')
dbclosearea("TEMP2")
fErase(_cNomTrb1+'.*')

dbSelectArea('TEMP3')
dbclosearea("TEMP3")
fErase(_cNomTrb2+'.*')

return

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

Static Function fSeleciona()
Local cQuery:=""

If Select("xSC6") > 0
   DbSelectArea("xSC6")
   DbCloseArea("xSC6")
Endif   
/*
cQuery+=" SELECT C6_FILIAL, C6_NUM, C6_UNSVEN, C6_VALOR, C6_QTDVEN, C5_VEND1, C6_PRODUTO "
cQuery += " FROM " + RetSqlName("SC6") + " C6, " + RetSqlName("SC5") + " C5"
cQuery+=" WHERE "
cQuery+=" 	(C6.C6_ENTREG BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND "
cQuery+=" 	C6.C6_FILIAL IN ("+Alltrim(mv_PAR03)+") "
cQuery+=" AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM "
//If !(_lDiret) 
   cQuery+=" AND C5_VEND1 IN("+_cVended+") "
//Endif 
//cQuery+=" AND C5_VEND1 IN('000035','000037') "  
cQuery+=" AND C6.D_E_L_E_T_= '' "
cQuery+=" AND C5.D_E_L_E_T_= '' "
cQuery+=" ORDER BY "
cQuery+=" C6_FILIAL+C6_NUM"
*/
cQuery+=" SELECT C6_FILIAL, C6_NUM, C6_UNSVEN, C6_VALOR, C6_QTDVEN, C5_VEND1, C6_PRODUTO "
cQuery += " FROM " + RetSqlName("SC6") + " C6, " + RetSqlName("SC5") + " C5, "+ RetSqlName("SB1") + " B1 "
cQuery+=" WHERE "
cQuery+=" 	(C6.C6_ENTREG BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND "
cQuery+=" 	C6.C6_FILIAL IN ("+Alltrim(mv_PAR03)+") "
cQuery+=" AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_PRODUTO = B1.B1_COD "
If Empty(MV_PAR08)
   cQuery+=" AND (B1.B1_GRUPO BETWEEN '"+(MV_PAR06)+"' AND '"+(MV_PAR07)+"')
ENDIF   
//If !(_lDiret) 
   cQuery+=" AND C5_VEND1 IN("+_cVended+") "
//Endif 
//cQuery+=" AND C5_VEND1 IN('000035','000037','000038')" //,'000043') "  
cQuery+=" AND C6.D_E_L_E_T_= '' "
cQuery+=" AND C5.D_E_L_E_T_= '' "
cQuery+=" ORDER BY "
cQuery+=" C6_FILIAL+C6_NUM"

TCQUERY cQuery NEW ALIAS "xSC6"
dbselectArea("xSC6")
DbgoTop()                            

Return()

 
Static function fFilVend()

If _lSuperv   
   If Select("TSA3") > 0
      DbSelectArea("TSA3")
      DbCloseArea("TSA3")
   Endif

   _cQuery := ""
   _cQuery += "SELECT A3_COD FROM "+RetSqlName("SA3")+" SA3 "
   _cQuery += " WHERE SA3.A3_CODSUP = '"+_cCodigo+"' AND SA3.D_E_L_E_T_ = '' " 
				
   TCQUERY _cQuery NEW ALIAS "TSA3"

   dbSelectArea("TSA3")
   dbGoTop()
   While TSA3->(!Eof())
	     _cVended += "'"+TSA3->A3_COD+"',"
         TSA3->(dbSkip())
   Enddo 

   dbCloseArea("TSA3") 

   _cVended := Substr(_cVended,1,Len(_cVended)-1)
   
Elseif _lGerent
   If Select("TSA3") > 0
      DbSelectArea("TSA3")
      DbCloseArea("TSA3")
   Endif

   _cQuery := ""
   _cQuery += "SELECT A3_COD FROM "+RetSqlName("SA3")+" SA3 "
   _cQuery += " WHERE SA3.A3_GEREN = '"+_cCodigo+"' AND (SA3.A3_CODSUP >= '"+mv_par04+"' AND SA3.A3_CODSUP <= '"+mv_par05+"') AND SA3.D_E_L_E_T_ = '' " 
				
   TCQUERY _cQuery NEW ALIAS "TSA3"

   dbSelectArea("TSA3")
   dbGoTop()
   While TSA3->(!Eof())
	     _cVended += "'"+TSA3->A3_COD+"',"
         TSA3->(dbSkip())
   Enddo 

   dbCloseArea("TSA3") 

   _cVended := Substr(_cVended,1,Len(_cVended)-1)   
Elseif _lDiret
   If Select("TSA3") > 0
      DbSelectArea("TSA3")
      DbCloseArea("TSA3")
   Endif

   _cQuery := ""
   _cQuery += "SELECT A3_COD FROM "+RetSqlName("SA3")+" SA3 "
   _cQuery += " WHERE SA3.A3_CODSUP >= '"+mv_par04+"' AND SA3.A3_CODSUP <= '"+mv_par05+"' AND SA3.D_E_L_E_T_ = '' " 
				
   TCQUERY _cQuery NEW ALIAS "TSA3"

   dbSelectArea("TSA3")
   dbGoTop()
   While TSA3->(!Eof())
	     _cVended += "'"+TSA3->A3_COD+"',"
         TSA3->(dbSkip())
   Enddo 

   dbCloseArea("TSA3") 

   _cVended := Substr(_cVended,1,Len(_cVended)-1)   

Elseif _lVended
   _cVended := "'"+_cCodigo+"'"
Endif   
   
Return()
