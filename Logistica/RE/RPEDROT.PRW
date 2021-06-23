#include "rwmake.ch"
#include "topconn.ch"

User Function RPEDROT()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RPEDROT  ³ Autor ³ Rogerio Eduardi Nutti ³ Data ³ 06/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio "PEDIDOS POR ROTEIRO"                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ALTERADO POR HERALDO 14/01/04
PERMITIR SAIR O SOMENTE O MAPA DAS NF JA FATURADAS
Alteracoes feitas por heraldo 01/03/04
- Trocado o set filter por select dentro dos parametros
- Alterado o Layout e quebra de pagina
- Incluido coluna para inclusao manual de numero de lacres
Alteracao feita por heraldo 04/03/04
- Acertado a validacao do supervisor

--DANIEL 05/03/07
--CORRIGIDO O FILTRO DE PEDIDOS JA FATURADOS
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

HCCONSYS - HEVERSON - 23/10/08
INCLUIDO COLUNA DE QUANTIDADE EMBARCADA , PARA ATENDER A NECESSIDADE DO PROJETO CARREGA FATURA E NOTA FISCAL ELETRONICA.

/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        ³
//³ mv_par01              Do Pedido                             ³
//³ mv_par02              Ate o Pedido                          ³
//³ mv_par03              Do Roteiro                            ³
//³ mv_par04		     	  Ate o Roteiro                         ³
//³ mv_par05              Da Entrega                            ³
//³ mv_par06	   	  	  Ate a Entrega                         ³
//³ mv_par07	     		  Do Supervisor                         ³
//³ mv_par08	     	  	  Ate Supervisor
//³ mv_par09                 Do Vendedor                        ³
//³ mv_par10	     	  	  Ate o Vendedor                        ³
//³ mv_par11	     	  	  Filtra so faturados                   ³
//³ mv_par12	     	  	  Carregamento S/N ?                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrd             := {}
tamanho          := "M"
//limite           := 132
limite           := 132
WNREL            := "RPEDROT"
nomeprog         := "RPEDROT"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 99
nItem            := 1
lContinua        := .T.
_lLib     		  := .F.
_aLinha			:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape 	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg   := "RPEDRO"
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SC6"
titulo  := "PEDIDOS POR ROTEIRO"
cDesc1  := "Este programa tem como objetivo imprimir os Pedidos de"
cDesc2  := "Venda por Roteiro."
cDesc3  := ""
_cPag	:=	0
nomerel := "RPEDROT"
nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio "PEDIDOS POR ROTEIRO')

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF WINDOWS
	Processa({|| RunCont()},Titulo )
	Return
	Static Function RunCont()
	ProcRegua(RecCount())
#ELSE
	SetRegua(RecCount())
#ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para Resumo por Produto                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aStru := {}
aAdd(_aStru,{"TR_PRODUTO"  , "C",06,0})
aAdd(_aStru,{"TR_TES"      , "C",03,0})
aAdd(_aStru,{"TR_DESCRI"   , "C",60,0})
aAdd(_aStru,{"TR_CAIXAS"   , "N",06,0})
aAdd(_aStru,{"TR_KILOS"    , "N",12,3})
aAdd(_aStru,{"TR_TARA"     , "C",02,0})
aAdd(_aStru,{"TR_VALTOT"   , "N",12,2})
_cNomTrb := CriaTrab(_aStru)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

_cIndex := "TR_PRODUTO"
IndRegua("TEMP",_cNomTrb, _cIndex,,,"Criando Indice ..." )
dbSelectArea("TEMP") ; dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Areas e Filtros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1") ; dbSetOrder(1)
dbSelectArea("SB2") ; dbSetOrder(1)
dbSelectArea("SA3") ; dbSetOrder(1)
dbSelectArea("SC6") ; dbSetOrder(1)
dbSelectArea("SZC") ; dbSetOrder(1)


// INICIO DO FILTRO POR VENDEDOR - RAFAEL H SILVEIRA 27/04/2006
_cUserName  := Subs(cUsuario,7,15)  // Nome do Usuario

//+------------------------------------------------------------------------------------------------+
//|daniel 25/01/07 removido para que os supervisores possam retirar o mapa de todos os vendedores  |
//+------------------------------------------------------------------------------------------------+
/*
dbSelectArea("SZR")
dbSetOrder(2)            // ZR_FILIAL+ZR_DESCRIC
If dbSeek( xFilial("SZR")+_cUserName )
mv_par07:=ZR_CODIGO
mv_par08:=ZR_CODIGO
ELSE
*/
/*
dbSelectArea("SA3")
DbSetOrder(2)
If dbSeek( xFilial("SA3")+_cUserName )
mv_par09:= A3_COD
mv_par10:= A3_COD
dbclosearea("SA3")
ENDIF
//ENDIF
dbclosearea("SZR")
// FIM DO FILTRO POR VENDEDOR - RAFAEL H SILVEIRA 27/04/2006
*/


_cCodVen := ''
_cCodSup := ''
_cSupVends := ''

_cUserName  := Subs(cUsuario,7,15)   // Nome do Usuario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1a. Verificacao - E' Gerente ?                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(Alltrim(_cUserName) $ GetMV("MV_GERENTE") )         // Se for gerente nao tem Filtro
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 2a. Verificacao - E' Supervisor ?                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZR")
	dbSetOrder(2)            // ZR_FILIAL+ZR_DESCRIC
	If dbSeek( xFilial("SZR")+_cUserName )
		
		_cCodSup := SZR->ZR_CODIGO            // Busca Codigo Supervisor
		
		dbSelectArea("SA3")
		dbSetOrder(5)        // A3_FILIAL+A3_SUPER
		If dbSeek( xFilial("SA3")+_cCodSup )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena em _cSupVends todos os Vendedores do Supervisor     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cSupVends  := ""
			Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
				_cCodSup       == SA3->A3_SUPER
				_cSupVends  :=  _cSupVends + "'"+SA3->A3_COD+"', "
				
				dbSelectArea("SA3")
				dbSkip()
			Enddo
			if !empty(_cSupVends                                                    )
				_cSupVends := left(_cSupVends,len(_cSupVends)-2)
			endif
			
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 3a. Verificacao - E' Vendedor ?                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA3")
		dbSetOrder(2)
		If dbSeek( xFilial("SA3")+_cUserName )
			
			_cSupVends := "'"+SA3->A3_COD+"'"              // Busca Codigo Vendedor
			
		Endif
		
	Endif
	
Endif


If mv_par11 == 1
	cQuery	:=	"SELECT SC5.C5_FILIAL , SC5.C5_NUM , SC5.C5_TIPO, SC5.C5_CLIENTE , SC5.C5_LOJAENT , SC5.C5_DTENTR, "+;
	" SC5.C5_VEND1 , SC5.C5_NUM , SC5.C5_NOTA , SC5.C5_ROTEIRO , SC5.C5_SEQUENC , SC5.C5_CONDPAG, "+;
	" SC5.C5_CLIENTE  , SC5.C5_LOJAENT  , SC5.C5_PLACA , SC5.C5_VEND1 , SC5.C5_PLACA, SA3.A3_CODSUP "+;
	" FROM " + retsqlname("SC5")+" SC5, "+retsqlname("SA3")+ " SA3 " + ;
	" WHERE SC5.C5_VEND1 = SA3.A3_COD "+;
	"AND SC5.C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
	"AND SC5.C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
	"AND SC5.C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
	iif(!empty(_cSupVends),"AND SC5.C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
	"AND SA3.A3_CODSUP BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"+;
	"AND SC5.C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
	"AND SC5.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*' "+;
	"AND SC5.C5_VEND1 <> '' "+;
	"AND SC5.C5_FILIAL = '"+XFILIAL("SC5")+"' "+;
	"UNION "+;
	"SELECT C5_FILIAL , C5_NUM , C5_TIPO, C5_CLIENTE , C5_LOJAENT , C5_DTENTR, "+;
	" C5_VEND1 , C5_NUM , C5_NOTA , C5_ROTEIRO , C5_SEQUENC , C5_CONDPAG, "+;
	" C5_CLIENTE  , C5_LOJAENT  , C5_PLACA , C5_VEND1 , C5_PLACA, '' "+;
	" FROM " + retsqlname("SC5")+;
	" WHERE C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
	"AND C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
	"AND C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
	iif(!empty(_cSupVends),"AND C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
	"AND C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
	"AND D_E_L_E_T_ <> '*' "+;
	"AND C5_VEND1 = '' "+;
	"AND C5_TIPO <> 'N' "+;
	"AND C5_FILIAL = '"+XFILIAL("SC5")+"' "+;
	"ORDER BY C5_ROTEIRO, C5_SEQUENC"	
Else
	cQuery	:= " SELECT SC5.C5_FILIAL , SC5.C5_NUM , SC5.C5_TIPO, SC5.C5_CLIENTE , SC5.C5_LOJAENT , SC5.C5_DTENTR, "+;
	" SC5.C5_VEND1 , SC5.C5_NUM , SC5.C5_NOTA , SC5.C5_ROTEIRO , SC5.C5_SEQUENC , SC5.C5_CONDPAG, "+;
	" SC5.C5_CLIENTE  , SC5.C5_LOJAENT  , SC5.C5_PLACA , SC5.C5_VEND1 , SC5.C5_PLACA, SA3.A3_CODSUP "+;
	" FROM " + retsqlname("SC5")+" SC5, "+retsqlname("SA3")+ " SA3 " + ;
	" WHERE SC5.C5_VEND1 = SA3.A3_COD "+;
	" AND SC5.C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
	"AND SC5.C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
	"AND SC5.C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
	iif(!empty(_cSupVends),"AND SC5.C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
	"AND SA3.A3_CODSUP BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+;
	"AND SC5.C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
	"AND SC5.D_E_L_E_T_ <> '*' AND SA3.D_E_L_E_T_ <> '*' "+;
	"AND SC5.C5_VEND1 <> '' " +;
	"AND SC5.C5_FILIAL = '"+XFILIAL("SC5")+"' "+;
	"UNION "+;
	"SELECT C5_FILIAL , C5_NUM , C5_TIPO, C5_CLIENTE , C5_LOJAENT , C5_DTENTR, "+;
	" C5_VEND1 , C5_NUM , C5_NOTA , C5_ROTEIRO , C5_SEQUENC , C5_CONDPAG, "+;
	" C5_CLIENTE  , C5_LOJAENT  , C5_PLACA , C5_VEND1 , C5_PLACA, '' "+;
	" FROM " + retsqlname("SC5")+;
	" WHERE C5_NUM BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR02 +"' " +;
	"AND C5_DTENTR BETWEEN '"+ dtos(mv_par05)+"' AND '" + dtos(mv_par06) +"' " +;
	"AND C5_VEND1  BETWEEN '"+ mv_par09+"' AND '" + mv_par10 +"' " +;
	iif(!empty(_cSupVends),"AND C5_VEND1  IN ("+ _cSupVends +") " ,"")+;
	"AND C5_ROTEIRO BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 +"' "+;
	"AND "+RetSqlName("SC5")+ ".D_E_L_E_T_ <> '*' "+;
	"AND C5_VEND1 = '' "+;
	"AND C5_TIPO <> 'N' " +;
	"AND C5_FILIAL = '"+XFILIAL("SC5")+"' "+;
	"ORDER BY C5_ROTEIRO, C5_SEQUENC"
	
Endif
TCQUERY cQuery new alias "XC5"
dbSelectArea("XC5")
dbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Totalizaras                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_nTTotCaixas := 0
_nTTotKilos  := 0
_nTTotValTot := 0
_nTotCaixas  := 0
_nTotKilos   := 0
_nTotValTot  := 0
_Placa       := space(02)
_DtEntre     := date()

Do While !Eof()
	
	IncProc()
	
	// Forcar ir no SC6010 para saber se este pedido já foi faturado
	// na condição de pedidos faturados
	/*
	If mv_par11 = 1
	_cFaturou = 'N'
	dbSelectArea("SC6")
	dbSeek( xFilial("SC6") + XC5->C5_NUM )
	Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and.;
	SC6->C6_NUM    == XC5->C5_NUM
	// Se tem nota Fiscal em apenas um item entra para impressão
	IF !EMPTY(SC6->C6_NOTA)
	_cFaturou = 'S'
	Exit
	Endif
	dbSkip()
	Enddo
	If _cFaturou = 'N'
	DbSelectArea("XC5")
	DbSkip()
	Loop
	Endif
	Endif
	*/
	//daniel - ALTERADO PARA VERIFICAR NO SC5 05/03/07
	IF MV_PAR11=1 //SIM
		IF EMPTY(XC5->C5_NOTA)
			DBSKIP()
			LOOP
		ENDIF
	Else
		IF !EMPTY(XC5->C5_NOTA)
			DBSKIP()
			LOOP
		ENDIF
	ENDIF
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Vendedor para encontrar o Supervisor do Vendedor        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//DANIEL 08/03/07 - ALTERADO PARA QUE QUANDO NAO ENCONTRAR O VENDEDOR
	//IMPRIMIR VAZIO
	dbSelectArea("SA3")
	DBSETORDER(1)
	If	dbSeek( xFilial("SA3") + XC5->C5_VEND1 )
		
		_cNomVend1 := SA3->A3_NOME
		_cNomSuper := SA3->A3_SUPERVIS
	Else
		_cNomVend1 := ''
		_cNomSuper := ''
	EndIf
	
	/*	IF !EMPTY(MV_PAR07)
	//		If SA3->A3_SUPERVIS != mv_par07     ---- Alterado por heraldo 04/03/04
	If SA3->A3_CODSUP != alltrim(mv_par07)
	dbSelectArea("XC5")
	dbSkip()
	Loop
	Endif
	Endif
	*/
	
	IF !XC5->C5_TIPO $ 'BD'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o Cliente                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//daniel 08/03/07 - alterado para quando nao achar o codigo do cliente imprimir branco
		dbSelectArea("SA1")
		dbsetorder(1)
		If dbSeek( xFilial("SA1") + XC5->C5_CLIENTE + XC5->C5_LOJAENT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime dados do cabecalho do Pedido de Venda                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !empty(alltrim(SA1->A1_ENDENT))   // INCLUIDO POR HERALDO 26/08/03
				_cEndEnt	:= SA1->A1_ENDENT
				_cTelEnt	:= PADR(ALLTRIM(SA1->A1_DDD)+IIF(!EMPTY(ALLTRIM(SA1->A1_DDD))," ","")+ALLTRIM(SA1->A1_TEL),15)//SA1->A1_TEL
				_cMunEnt	:= SA1->A1_MUNE
				_cBaiEnt	:= SA1->A1_BAIRROE
				_cUFEnt  := SA1->A1_ESTE
				_cCEPEnt	:= SA1->A1_CEPE
			Else
				_cEndEnt	:= SA1->A1_END
				_cTelEnt	:= PADR(ALLTRIM(SA1->A1_DDD)+IIF(!EMPTY(ALLTRIM(SA1->A1_DDD))," ","")+ALLTRIM(SA1->A1_TEL),15) //SA1->A1_TEL
				_cMunEnt	:= SA1->A1_MUN
				_cBaiEnt	:= SA1->A1_BAIRRO
				_cUFEnt	:= SA1->A1_EST
				_cCEPEnt	:= SA1->A1_CEP
			Endif
			_cCNPJ      := SA1->A1_CGC
			_cInsc      := SA1->A1_INSCR
			_cNomCli		:=SA1->A1_NOME
		Else
			_cEndEnt	:= ''
			_cTelEnt	:= ''
			_cMunEnt	:= ''
			_cBaiEnt	:= ''
			_cUFEnt	:= ''
			_cCEPEnt	:= ''
			_cCNPJ   := ''
			_cInsc   := ''
			_cNomCli	:= ''
		endif
	ELSE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o Fornecedor                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA2")
		dbsetorder(1)
		If dbSeek( xFilial("SA2") + XC5->C5_CLIENTE + XC5->C5_LOJAENT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime dados do cabecalho do Pedido de Venda                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cEndEnt	:= SA2->A2_END
			_cTelEnt	:= PADR(ALLTRIM(SA2->A2_DDD)+IIF(!EMPTY(ALLTRIM(SA2->A2_DDD))," ","")+ALLTRIM(SA2->A2_TEL),15) //SA2->A2_TEL
			_cMunEnt	:= SA2->A2_MUN
			_cBaiEnt	:= SA2->A2_BAIRRO
			_cUFEnt  := SA2->A2_EST
			_cCEPEnt	:= SA2->A2_CEP
			_cCNPJ   := SA2->A2_CGC
			_cInsc   := SA2->A2_INSCR
			_cNomCli	:=SA2->A2_NOME
		Else
			_cEndEnt	:= ''
			_cTelEnt	:= ''
			_cMunEnt	:= ''
			_cBaiEnt	:= ''
			_cUFEnt	:= ''
			_cCEPEnt	:= ''
			_cCNPJ   := ''
			_cInsc   := ''
			_cNomCli	:= ''
		EndIf
	EndIf
	
	dbSelectArea("XC5")
	_Placa :=XC5->C5_PLACA
	
	If nLin > 55
		_cPag++
		nLin := 1
		@ nLin,001 PSAY "RPEDROT"
		if mv_par12 == 2
			@ nLin,025 PSAY  " R E L A T O R I O   D E   C O N F E R E N C I A    D E   P E D I D O"
		else
			@ nLin,025 PSAY  " R E L A T O R I O   D E   C A R R E G A M E N T O  D E   P E D I D O"
		endif
		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//          1         2         3         4         5         6         7         8         9         100
		@ nLin,110 PSAY str(_cPag,3)
		@ nLin,120 PSAY date()
	Endif
	nLin := nLin + 2
	@ nLin, 000 PSAY "PEDIDO  : "	+	XC5->C5_NUM + "  TIPO "+XC5->C5_TIPO
	@ nLin, 029 PSAY "NUM. NF : "	+	XC5->C5_NOTA
	nLin := nLin + 1
	@ nLin, 000 PSAY "ROTEIRO : "    +	XC5->C5_ROTEIRO +" Seq.: "+XC5->C5_SEQUENC
	@ nLin, 029 PSAY "CLIENTE : " 	+ 	XC5->C5_CLIENTE +"/"+ XC5->C5_LOJAENT +" "+ _cNomCli
	@ nLin, 104 PSAY "TELEFONE: "	+	_cTelEnt
	nLin := nLin + 1
	@ nLin, 000 PSAY "C.N.P.J.: "    +	_cCNPJ
	@ nLin, 029 PSAY "INSC.CLIENTE : " 	+ 	_cInsc
	nLin := nLin + 1
	
	@ nLin, 000 PSAY "PLACA   : " 	+	XC5->C5_PLACA
	@ nLin, 029 PSAY "ENDERECO: " 	+ 	_cEndEnt
	@ nLin, 079 PSAY "CIDADE	 : "	+	_cMunEnt
	@ nLin, 104 PSAY "BAIRRO: "		+	_cBaiEnt
	nLin := nLin + 1
	@ nLin, 000 PSAY "VENDEDOR: "	+	XC5->C5_VEND1
	@ nLin, 029 PSAY "SUPERV. : "	+	_cNomSuper
	@ nLin, 079 PSAY "ESTADO : " 	+ 	_cUFEnt
	@ nLin, 104 PSAY "CEP: "    		+ 	_cCEPEnt
	
	
	nLin := nLin + 1
	@ nLin, 000 PSAY Repl("=",limite)
	nLin := nLin + 1
	// Alteracao hcconsys - 23/10/08
	If mv_par12 == 2
		@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM   Valor Total"
	ELSE
		@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM       QTDE CX"
	ENDIF
	
	nLin := nLin + 1
	@ nLin, 000 PSAY Repl("-",limite)
	nLin := nLin + 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Item do Pedido de Venda e imprime os itens              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTotCaixas := 0
	_nTotKilos  := 0
	_nTotValTot := 0
	_produto    := space(06)
	_c2Um       := space(02)
	dbSelectArea("SC6")
	dbSeek( xFilial("SC6") + XC5->C5_NUM )
	// Verifico se todos os itens foram faturados
	Do While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and.;
		SC6->C6_NUM    == XC5->C5_NUM
		If (SC6->C6_NOTA  <> ' ' .AND. mv_par11 == 1) .OR.( mv_par11 <> 1 ) .OR. (XC5->C5_TIPO $ 'DB')
			If nLin > 68
				nLin := 1
				If mv_par12 == 2
					@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM   Valor Total"
				else
					@ nLin, 000 PSAY "Produto    Descricao do Produto                                          TES Qtde Cx 2UM  Valor Unit.  Qtde  Kg   UM       QTDE CX"
				endif
				nLin := nLin + 1
				@ nLin, 000 PSAY Repl("-",limite)
				nLin := nLin + 2
			Endif
			
			_Produto := left(C6_PRODUTO,10) //C6_PRODUTO
			_tes     := C6_TES
			_Descri  := C6_DESCRI
			_DtEntre := C6_ENTREG
			_c2Um    := C6_SEGUM
			
			@ nLin, 000  PSAY _PRODUTO
			@ nLin, 011  PSAY _Descri //016
			
			
			dbSelectArea("SC9") // Itens de pedido liberado
			dbSetOrder(01) // Indice ( pedido )
			If dbSeek( xFilial("SC9")+ XC5->C5_NUM)
			    
				// INICIO CHAMADO 033454 - WILLIAM COSTA
				While !SC9->(Eof()) .AND. SC9->(C9_FILIAL+C9_PEDIDO) == (xFilial("SC9")+ XC5->C5_NUM)
				
					// SOMA PESO BRUTO DAS NOTAS QUE SENSIBILIZAM O ESTOQUE
					If Empty(SC9->C9_BLEST ) .AND. Empty(SC9->C9_BLCRED)
						_lLib	:= .t.
					else
						_lLib := .f.
						EXIT
					Endif
					SC9->(dbSkip())
				ENDDO	
				// FINAL CHAMADO 033454 - WILLIAM COSTA
			Else
				_lLib := .f.
			Endif
			
			dbSelectArea("SC6")
			if _lLib .or. mv_par12 == 2 .or. C6_QTDENT>0
				@ nLin, 073  PSAY C6_TES   //incluido por Adriana em 09/06/08
				@ nLin, 078  PSAY C6_UNSVEN  PICTURE "@E 999,999"
				@ nLin, 087  PSAY C6_SEGUM
				@ nLin, 091  PSAY C6_PRCVEN  PICTURE "@E 999999.9999"      // VUnit UM2
				@ nLin, 104  PSAY C6_QTDVEN  PICTURE "@E 999999.99"        // Qtd UM1
				@ nLin, 115  PSAY C6_UM                                    // UM  1
				
				// alteracao hcconsys 23/10/08
				
				If mv_par12 == 2
					@ nLin, 118  PSAY C6_VALOR   PICTURE "@E 999,999,999.99"   // Vlt Total
					nLin := nLin + 1
				else
					@ nLin, 118  PSAY iif(C6_QTDENT>0,"__ FATURADO  __","_______________")
					nLin := nLin + 2
					//fim alteracao hcconsys 23/10/08
				endif
				
				_nTotCaixas := _nTotCaixas + C6_UNSVEN
				_nTotkilos  := _nTotKilos  + C6_QTDVEN
				_nTotValTot := _nTotValtot + C6_VALOR
				
				//CORIGIR O PONTO CHUMBADO
				//PASSAR PARA UM PARAMETRO
				If  !(SUBSTR(C6_CF,2,3) $ ALLTRIM(GETMV("MV_NOSC6CF")))
					dbSelectArea("TEMP")
					
					If !dbSeek(_Produto )
						RecLock("TEMP",.T.)
					Else
						RecLock("TEMP",.F.)
					Endif
					Replace TR_PRODUTO   With _Produto
					Replace TR_TES       With _tes
					Replace TR_DESCRI    With _DESCRI
					Replace TR_CAIXAS    With TR_CAIXAS + SC6->C6_UNSVEN
					Replace TR_KILOS     With TR_KILOS  + SC6->C6_QTDVEN
					Replace TR_TARA      With _c2Um
					Replace TR_VALTOT    With TR_VALTOT + SC6->C6_VALOR
					MsUnlock()
				Endif
			Else
				@ nLin, 073  PSAY "--------------    N A O   L I B E R A D O    --------------"     //incluido por Adriana em 09/06/08
				nLin := nLin + 2
			Endif
		Endif
		
		dbSelectArea("SC6")
		dbSkip()
		Loop
	Enddo
	
	@ nLin, 000 PSAY Repl("-",limite)
	nLin := nLin + 1
	
	@ nLin, 003 PSAY "Cond.Pagto.: "+ XC5->C5_CONDPAG + "  Data Entrega : " +dToC(_DtEntre)
	@ nLin, 049 PSAY "TOTAL PEDIDO: "
	@ nLin, 079  PSAY Transform(_nTotCaixas ,"@E 999999")           // Total Qtd UM2
	@ nLin, 104  PSAY Transform(_nTotKilos  ,"@E 999999.99")        // Total Qtd UM1
	@ nLin, 118  PSAY Transform(_nTotValTot ,"@E 999,999,999.99")   // Total Vlt Total
	nLin := nLin + 1
	@ nLin, 000 PSAY Repl("*",limite)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera totalizados por pedido                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	_nTTotKilos  := _nTTOTkILOS  + _nTotKILOS
	_nTTotCaixas := _nTTOTcAIXAS + _nTotCAIXAS
	
	_nTotCaixas := 0
	_nTotKilos  := 0
	_nTotValTot := 0
	
	dbSelectArea("XC5")
	dbSkip()
	
Enddo

nLin := nLin + 1

@ nLin, 049 PSAY "TOTAL GERAL  "
@ nLin, 079  PSAY Transform(_ntTotCaixas ,"@E 999999")           // Total Qtd UM2
@ nLin, 118  PSAY Transform(_ntTotKilos  ,"@E 999999.99")        // Total Qtd UM1

nLin := nLin + 1

@ nLin, 001 PSAY Repl("#",limite)

if mv_par03 == MV_PAR04 //do roteiro ate o roteiro
	
	_nTTotCaixas := 0
	_nTTotKilos  := 0
	_nTTotPbr    := 0
	_nTTotPGer   := 0
	_nTTotVal	 := 0
	_nTara := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Resumo por Produto                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(_aLinha,{"|INICIO:                   |"}) 	//1
	aAdd(_aLinha,{"|                          |"})	//2
	aAdd(_aLinha,{"|TERMINO:                  |"})	//3
	aAdd(_aLinha,{"|--------------------------|"})	//4
	aAdd(_aLinha,{"|LACRES:                   |"})	//5
	aAdd(_aLinha,{"|        |         |       |"})	//6
	aAdd(_aLinha,{"|        |         |       |"})	//7
	aAdd(_aLinha,{"|--------------------------|"})	//8
	aAdd(_aLinha,{"|        |         |       |"})	//9
	aAdd(_aLinha,{"|        |         |       |"})	//10
	aAdd(_aLinha,{"|--------------------------|"})	//11
	aAdd(_aLinha,{"|CONFERENTE:               |"})	//12
	aAdd(_aLinha,{"|                          |"})	//13
	aAdd(_aLinha,{"|                          |"})	//14
	aAdd(_aLinha,{"|--------------------------|"})	//15
	
	dbSelectArea("TEMP")
	dbSetOrder(1)
	dbGoTop()
	
	nLin := 1
	
	nlin := nLin + 2
	@ nLin,000 PSAY "RPEDROT"
	@ nLin,040 PSAY "R E S U M O   D E   C A R R E G A M E N T O "
	nlin := nLin + 3
	@ nLin, 000 PSAY Repl("-",limite)
	nLin := nLin + 2
	@ nLin,000 PSAY "ROTEIRO NUMERO " + MV_PAR03 + SPACE(15)+ " Data Entrega : " + DTOC(_DTENTRE) + SPACE(20)+ "       PLACA VEICULO : " + _Placa
	nlin := nLin + 2
	@ nLin, 000 PSAY Repl("-",limite)
	nLin := nLin + 2
	@ nLin, 000 PSAY "Produto    Descricao do Produto                                  TES Qtde        Peso       Peso "
	nLin  := nLin + 2
	@ nLin, 000 PSAY "                                                                       Cx        Liquido     Bruto "
	nLin := nLin + 2
	@ nLin, 000 PSAY Repl("-",limite)
	
	_lPrima	:=	.t.
	For _nI := 1 to 15
		
		Do While !Eof()	.and. _lPrima
			
			nLin := nLin + 1
			If MOD(_nI,2) == 0
				@ nLin, 000 PSAY AllTrim(TR_PRODUTO)
				@ nLin, 011 PSAY AllTrim(TR_DESCRI)
				@ nLin, 065 PSAY TR_TES
				@ nLin, 069 PSAY TR_CAIXAS  PICTURE "999999"
				@ nLin, 076 PSAY TR_KILOS   PICTURE "999,999.99"
				
				dbSelectArea("SZC")
				dbSetOrder(1)
				If dbSeek(xFilial("SZC")+ TEMP->TR_TARA)
					_nTara := ZC_TARA
				Endif
				
				dbSelectArea("TEMP")
				_nTTotPbr := ((TR_CAIXAS * _nTara) + TR_KILOS)
				
				@ nLin, 091 PSAY _nTTotPbr  PICTURE "999,999.99"
				_nTTotCaixas 	:= _nTTotCaixas + TR_CAIXAS
				_nTTotKilos  	:= _nTTotKilos  + TR_KILOS
				_nTTotPGer  	+= _nTTotPbr
				_nTTotVal		+= TR_VALTOT
				dbSkip()
			Endif
			If _nI <= 15
				@ nLin, 105 PSAY _aLinha[_nI][1]
			Endif
			_nI++
		Enddo
		If eof();_lPrima	:=	.f.;Endif
		If	_nI < 16
			nLin := nLin + 1
			@ nLin, 105 PSAY _aLinha[_nI][1]
		Endif
	Next _nI
	nLin := nLin + 2
	@ nLin, 000 PSAY Repl("-",limite)
	nLin := nLin + 2
	@ nLin, 000 PSAY "TOTAL ROTEIRO "
	@ nLin, 069 PSAY _NTTotCaixas   PICTURE "999999"
	@ nLin, 076 PSAY _NTTotKilos    PICTURE "999,999.99"
	@ nLin, 091 PSAY _nTTotPGer    	PICTURE "999,999.99"
	@ nLin, 105 PSAY _nTTotVal    	PICTURE "999,999.99"
	nLin := nLin + 2
	@ nLin, 000 PSAY Repl("*",limite)
	
ENDIF

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

dbSelectArea("TEMP")
dbclosearea("TEMP")
fErase(_cNomTRB+'.*')
DBSELECTAREA("XC5")
dbclosearea("XC5")

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ LAYOUT                                                              ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

1         2         3         4         5         6         7         8         9        10        11        12        13
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

------------------------------------------------------------------------------------------------------------------------------------
PEDIDO: 999999     ROTEIRO/SEQUENCIA: 999/99                             VENDEDOR: 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
SUPERVISOR: 999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CLIENTE: 999999/00 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ENDERECO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX         TELEFONE: XXXXXXXXXXXXXXX
CIDADE: XXXXXXXXXXXXXXX   BAIRRO: XXXXXXXXXXXXXXXXXXXX   ESTADO: XX   CEP: 99999-99
------------------------------------------------------------------------------------------------------------------------------------
Produto    Descricao do Produto                                            Qtde  UM       Valor         Qtde                 Valor
Cx        Unitario           Kg  UM             Total
------------------------------------------------------------------------------------------------------------------------------------
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  XX 999999.9999    999999.99  XX    999,999,999.99
------------------------------------------------------------------------------------------------------------------------------------
Condicao Pagamento: 999-XXXXXXXXXXXXXXX                 TOTAL PEDIDO:  999999                    999999.99  XX    999,999,999.99
------------------------------------------------------------------------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ LAYOUT RESUMO POR PRODUTO                                           ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


------------------------------------------------------------------------------------------------------------------------------------
1         2         3         4         5         6         7         8         9         10        11        12        13
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
------------------------------------------------------------------------------------------------------------------------------------
|INICIO:                   |
116   CORTES TP CG FRANGO (COXA E   SOBRECOXA) SV                    999999 999,999.99     999,999.99   |                          |
|TERMINO:                  |
117   CORTES TP CG FRANGO (ASAS) SV                                      40     720.00         732.00   |--------------------------|
|LACRES:                   |
209   RECORTES TP CG FRANGO (COXINHADA ASA) SV SACO                      15     270.00         274.50   |        |         |       |
|        |         |       |
210   RECORTES TP CG FRANGO (MEIO DAASA) SV SACO                         10     180.00         183.00   |--------------------------|
|        |         |       |
219   CORTES TP CG FRANGO (PEITO)   IND.15 KG                            30     450.00         459.00   |        |         |       |
|--------------------------|
53    FRANGO TEMP CG SV LV                                               30     540.00         549.60   |CONFERENTE:               |
|                          |
59    MIUDO CONG DE AVES  (MOELA)CP                                       5      90.00          91.50   |                          |
|--------------------------|

/*/




