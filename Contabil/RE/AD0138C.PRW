#include "rwmake.ch"
#include "topconn.ch"

User Function AD0138C()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,HISTORICO")
SetPrvt("_nTotal,M_PAG,IMPRIME,CSTRING,TITULO,CPERG")
SetPrvt("CDESC1,CDESC2,CDESC3,NOMEREL,ASTRU,_CNOMTRB")
SetPrvt("_VENDEDOR,")


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  ADO138 B³ Autor ³Jose Eduardo Sta Maria ³ Data ³ 26/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Investimos Projetos Temporarios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Manuten  ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_cSupVends	:=""
_cCodVen	:=""
_cCodSup 	:=""
_bFlagVend	:=""
CABEC1:="CONTA CONTABIL                    JANEIRO     FEVEREIRO   MARCO     ABRIL       MAIO         JUNHO        JULHO        AGOSTO       SETEMBRO     OUTUBRO      NOVEMBRO     DEZEMBRO     ACUMULADO"
Cabec2		:=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         |
//³ mv_par01             // do Projeto                           ³
//³ mv_par02             // Ate o Projeto                        ³
//³ mv_par03             // Centro Custo de                      ³
//³ mv_par04             // Centro Custo ate                     ³
//³ mv_par05             // C.Contabil  de                       ³
//³ mv_par06             // C.Contabil ate                       ³
//³ mv_par07             // Acumulado Ate o dia                  |
//³ mv_par08             // Imprime 1 P/Pagina ?                 |
//³ mv_par09             // Sint/Analitico                       |
//| mv_par10             // Imprime Movimento?                   |
//| mv_par11             // Deseja subtotal? (Grupo / Conta Cont)|
//| mv_par12             // Considera data (Emissao / Digitacao) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//³    > > > > >           Valores Fixos no Relatorio         < < < < <    ³
//³                                                                        ³
//³                                                                        ³
//³Tipo de Requisicao:                                                     ³
//³                                                                        ³
//³                   Entrada ---> 501                                     ³
//³                   Saida -----> 101                                     ³
//³                                                                        ³
//³ Fixado nas linhas:                                                     ³
//³                                                                        ³
//³     308 --> _cQuery += " AND   (D3_TM = '501' OR D3_TM = '101')"       ³
//³     543 --> If D3_TM == '101' // VERIFICA SE E ENTRADA NO ALMOXARIFADO ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


tamanho   := "G"
limite    := 220
nomeprog  := "AD0138C"
mv_tabpr  := ""
nTipo     := 18
//aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1,"",1}
nLastKey  := 0
nlin      := 70
nItem     := 1
lContinua := .T.

historico := space(20)
_nTotal   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag     := 01
imprime   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString  := "CT3"
titulo     := " Acompanhamento de Investimentos P/Projeto ( Resumido )"
cPerg    := "AD0138"
cDesc1  := "Este programa tem como objetivo imprimir Investimentos P/Projeto"
cDesc2  := " "
cDesc3  := ""
NomeRel := "AD0138C"

//Variaveis Criadas


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F., ,.T.,Tamanho)

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

Processa({|| RptDetail()},"Acompanhamentos de Investimentos P/Projeto ( Resumido ) ")
Return
Static Function RptDetail()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quantidade de digitos do Ano               ³
//³Se estiver no formato dd/mm/aa pega duas casas.     ³
//³Caso esteja no formato dd/mm/aaaa pega quatro casas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(DtoS(DDataBase)) == 6
   _dDataIni := CTOD('01/01/'+SUBSTR(DTOC(mv_par07),7,2) )
   _dDataMes := CTOD('01/'+SUBSTR(DTOC(mv_par07),4,5) )
Else
   _dDataIni := CTOD('01/01/'+SUBSTR(DTOC(mv_par07),7,4) )
   _dDataMes := CTOD('01/'+SUBSTR(DTOC(mv_par07),4,7) )
Endif   
//
// BUSCANDO DADOS EM PROJETOS
_cQuery := "SELECT AF8_FILIAL, AF8_PROJET, AF8_DESCRI FROM " +  RetSqlName("AF8")
_cQuery	+= " WHERE (AF8_PROJET BETWEEN '" + ALLTRIM(mv_par01)  +"' AND '"+ALLTRIM(mv_par02)+ "')"
_cQuery	+= " AND (D_E_L_E_T_ <> '*') "
_cQuery	+= " ORDER BY AF8_PROJET"
TCQUERY _cQuery new alias "XF8"
XF8->(dbgotop())
//
_cProj      := '????'  // Codigo do Projeto
_x1Vez	    :=	.T.
nLin        := 8
_nTotMes    := {}
_nTotGer    := {}
_nTotPrj    := {}
//
_cCentro    := ''            // codigo centro de custo
_nTotAcu    := 0
_nTotAcuG   := 0  // Total acumulado anual
_nTotAcuM   := 0  // Total acumulado centro custo mensal
_nTotAcuP   := 0  // Total acumulado por projeto
//
//
_GrupoAnt   := ""   // Armazena o grupo anterior para verificacao do parametro mv_par11
_ccAnt      := ""   // Armazena o Centro de Custo anterior para verificacao do parametro mv_par11
_nAcumTot   := 0    // Armazena o acumulado do total unitario

//
_nVetor      := 1
DO WHILE _nVetor <= 12
	AADD(_nTotMes,{_nVetor,0.00})
	AADD(_nTotGer,{_nVetor,0.00})
	AADD(_nTotPrj,{_nVetor,0.00})
	//
	_nTotMes[_nVetor][1] :=0
	_nTotGer[_nVetor][1] :=0
	_nTotPrj[_nVetor][1] :=0
	//
	_nVetor := _nVetor + 1
ENDDO
//
cFilterUser:=aReturn[7]
//
dbSelectArea("XF8")
dbGotop()
DO WHILE !EOF()
	//
	IF (_x1Vez .or. nLin > 45)
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
		_x1Vez	:=	.F.
	ENDIF
	//
	_cProj    := AF8_PROJET  
	_cProjN   := SUBSTR(ALLTRIM(AF8_DESCRI),1,19)
	_nTotAcuP := 0
	_nVetor   := 1
	DO WHILE _nVetor <= 12
		_nTotPrj[_nVetor][1] := 0
		_nVetor := _nVetor + 1
	ENDDO
	//
	IF (_x1Vez .or. nLin > 60)
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
		_x1Vez	:=	.F.
	ENDIF
	//
	_nTotAcuM    := 0
	_nVetor      := 1
	DO WHILE _nVetor <= 12
		_nTotMes[_nVetor][1] := 0
		_nVetor := _nVetor + 1
	ENDDO
	//
	IF mv_par10 <> 3
		// pesquisando todos os lanctos de entrada ref. ccusto, ccontabil e periodo de data
		_cQuery := "SELECT D1_FILIAL, D1_COD, D1_QUANT, D1_TOTAL, D1_CONTA, D1_GRUPO, D1_CC, D1_PEDIDO, D1_FORNECE, D1_EMISSAO, D1_DOC,D1_PROJETO,D1_VUNIT,D1_GRUPO,D1_DTDIGIT FROM " +  RetSqlName("SD1")
		_cQuery	+= " WHERE (D1_PROJETO = '" + _cProj + "')" 
		IF ALLTRIM(mv_par05) <> '' .OR. ALLTRIM(mv_par06) <> ''
		  _cQuery	+= " AND (D1_CONTA BETWEEN '" + AllTrim(mv_par05)  +"' AND '"+AllTrim(mv_par06)+ "')"
        ENDIF	
        //
		IF ALLTRIM(mv_par03) <> '' .OR. ALLTRIM(mv_par04) <> ''
			_cQuery	+= " AND (D1_CC BETWEEN '" + AllTrim(mv_par03)  +"' AND '"+AllTrim(mv_par04)+ "')"
		ENDIF
		//
		IF mv_par12 == 1 // considera data de emissao
   			_cQuery	+= "AND (D1_EMISSAO BETWEEN '" + DTOS(_dDataIni) +"' AND '"+DTOS(mv_par07)+ "')"
   		ELSE             // considera data de digitacao
   			_cQuery	+= "AND (D1_DTDIGIT BETWEEN '" + DTOS(_dDataIni) +"' AND '"+DTOS(mv_par07)+ "')"    		
   		ENDIF	
   		//
		_cQuery	+= " AND (D_E_L_E_T_ <> '*') "
		TCQUERY _cQuery new alias "XD1"
		//
		dbSelectArea("XD1")
		dbGotop()
		DO WHILE ! EOF()
   			IF mv_par12 == 1 // considera data de emissao
				_dEmissao 	   := Ctod(Right(XD1->D1_EMISSAO,2) +"/"+Substr(XD1->D1_EMISSAO,5,2) +"/"+Left(XD1->D1_EMISSAO,4))
			ELSE             // considera data de digitacao
				_dEmissao 	   := Ctod(Right(XD1->D1_DTDIGIT,2) +"/"+Substr(XD1->D1_DTDIGIT,5,2) +"/"+Left(XD1->D1_DTDIGIT,4))
			ENDIF
 			//	
			_NMes       	   := Month(_dEmissao)
			_nTotMes[_nMes][1] := _nTotMes[_nMes][1] + XD1->D1_TOTAL
			_nTotGer[_nMes][1] := _nTotGer[_nMes][1] + XD1->D1_TOTAL
			_nTotPrj[_nMes][1] := _nTotPrj[_nMes][1] + XD1->D1_TOTAL
			_nTotAcu           := _nTotAcu           + XD1->D1_TOTAL
			_nTotAcuM          := _nTotAcuM          + XD1->D1_TOTAL
			_nTotAcuG          := _nTotAcuG          + XD1->D1_TOTAL
			_nTotAcuP          := _nTotAcuP          + XD1->D1_TOTAL  
			//
			// verificando se existe lancto de devolucao
			SD2->(DbSetOrder()) // Indexa por Filial + Nota Fiscal
			IF SD2->(DbSeek(xFilial("SD2") + XD1->D1_DOC))  
				_dEmissao 		   := Ctod(Right(SD2->D2_EMISSAO,2) +"/"+Substr(SD2->D2_EMISSAO,5,2) +"/"+Left(SD2->D2_EMISSAO,4))
				_NMes       	   := Month(_dEmissao)
				_nTotMes[_nMes][1] := _nTotMes[_nMes][1] - SD2->D2_TOTAL
				_nTotGer[_nMes][1] := _nTotGer[_nMes][1] - SD2->D2_TOTAL
				_nTotPrj[_nMes][1] := _nTotPrj[_nMes][1] - SD2->D2_TOTAL
				_nTotAcu           := _nTotAcu           - SD2->D2_TOTAL
				_nTotAcuM          := _nTotAcuM          - SD2->D2_TOTAL
				_nTotAcuG          := _nTotAcuG          - SD2->D2_TOTAL
				_nTotAcuP          := _nTotAcuP          - SD2->D2_TOTAL
			ENDIF
			DBSKIP()
		ENDDO
		XD1->(dbclosearea()) 
		//
	ENDIF
	//
	IF mv_par10 <> 2
		_cQuery := "SELECT D3_CC,D3_TM,D3_CONTA,D3_EMISSAO,D3_PROJETO,D3_QUANT,D3_CUSTO1,D3_DOC,D3_GRUPO,D3_COD FROM "  +  RetSqlName("SD3")
		_cQuery	+= " WHERE (D3_PROJETO = '" + _cProj + "')"
		_cQuery += " AND   (D3_TM = '501' OR D3_TM = '101' OR D3_TM = '499')"   
		IF ALLTRIM(mv_par05) <> '' .OR. ALLTRIM(mv_par06) <> ''
		  _cQuery	+= " AND (D3_CONTA BETWEEN '" + AllTrim(mv_par05)  +"' AND '"+AllTrim(mv_par06)+ "')"
        ENDIF
		IF ALLTRIM(mv_par03) <> '' .OR. ALLTRIM(mv_par04) <> ''
			_cQuery	+= " AND   (D3_CC BETWEEN '" + AllTrim(mv_par03)  +"' AND '"+AllTrim(mv_par04)+ "')"
		ENDIF
		_cQuery	+= " AND   (D3_EMISSAO BETWEEN '" + DTOS(_dDataIni) +"' AND '"+DTOS(mv_par07)+ "')"
		_cQuery	+= " AND   (D_E_L_E_T_ <> '*') "
		TCQUERY _cQuery new alias "XD3" 
		//
		dbSelectArea("XD3")
		dbGotop()
		DO WHILE ! EOF()
			_dEmissao 			:= Ctod(Right(XD3->D3_EMISSAO,2) +"/"+Substr(XD3->D3_EMISSAO,5,2) +"/"+Left(XD3->D3_EMISSAO,4))
			_NMes       		:= Month(_dEmissao)
			_TotReg           	:= XD3->D3_CUSTO1 
			_TotUnt             := (XD3->D3_CUSTO1/XD3->D3_QUANT)   
			//
			IF (XD3->D3_TM == '101' .OR. XD3->D3_TM == '499') // VERIFICA SE E ENTRADA NO ALMOXARIFADO(DEVOLUCAO DE UMA SAIDA)
				_nTotMes[_nMes][1] 	:= _nTotMes[_nMes][1]	  -  _TotReg
				_nTotGer[_nMes][1]  := _nTotGer[_nMes][1]	  -  _TotReg
				_nTotPrj[_nMes][1]  := _nTotPrj[_nMes][1]	  -  _TotReg
				_nTotAcu            := _nTotAcu               -  _TotReg
				_nTotAcuM           := _nTotAcuM              -  _TotReg
				_nTotAcuG           := _nTotAcuG              -  _TotReg
				_nTotAcuP           := _nTotAcuP              -  _TotReg
            ELSE
				_nTotMes[_nMes][1] 	:= _nTotMes[_nMes][1]	  +  _TotReg
				_nTotGer[_nMes][1]  := _nTotGer[_nMes][1]	  +  _TotReg
				_nTotPrj[_nMes][1]  := _nTotPrj[_nMes][1]	  +  _TotReg
				_nTotAcu            := _nTotAcu               +  _TotReg
				_nTotAcuM           := _nTotAcuM              +  _TotReg
				_nTotAcuG           := _nTotAcuG              +  _TotReg
				_nTotAcuP           := _nTotAcuP              +  _TotReg
			ENDIF
			//
			dbSkip()
		ENDDO
		XD3->(dbclosearea()) 
        //
	ENDIF
	//
	// imprimindo os totais
	IF _nTotAcuM <> 0
	 	@nLin,000 PSAY _cProj + ' '+ _cProjN
		@nLin,034 PSAY _nTotMes[01][1]     		PICTURE   '@E 999,999.99'
		@nLin,045 PSAY _nTotMes[02][1]      	PICTURE   '@E 999,999.99'
		@nLin,056 PSAY _nTotMes[03][1]      	PICTURE   '@E 999,999.99'
		@nLin,068 PSAY _nTotMes[04][1]      	PICTURE   '@E 999,999.99'
		@nLin,080 PSAY _nTotMes[05][1]      	PICTURE   '@E 999,999.99'
		@nLin,093 PSAY _nTotMes[06][1]      	PICTURE   '@E 999,999.99'
		@nLin,106 PSAY _nTotMes[07][1]       	PICTURE   '@E 999,999.99'
		@nLin,119 PSAY _nTotMes[08][1]      	PICTURE   '@E 999,999.99'
		@nLin,132 PSAY _nTotMes[09][1]      	PICTURE   '@E 999,999.99'
		@nLin,145 PSAY _nTotMes[10][1]      	PICTURE   '@E 999,999.99'
		@nLin,155 PSAY _nTotMes[11][1]      	PICTURE   '@E 999,999.99'
		@nLin,171 PSAY _nTotMes[12][1]      	PICTURE   '@E 999,999.99'
		@nLin,184 PSAY _nTotAcuM  	     	  	PICTURE '@E 9,999,999.99'
		nLin++
    ENDIF
	dbSelectArea("XF8")
	dbSkip()
ENDDO
nLin++
@nLin,000 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
nLin++
IF (_x1Vez .or. nLin > 55)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 10
	_x1Vez	:=	.F.
	@nLin,000 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    nLin++
ENDIF
//
@nLin,000 PSAY "TOTAL GERAL:"
@nLin,034 PSAY _nTotGer[01][01]    		PICTURE   '@E 999,999.99'
@nLin,045 PSAY _nTotGer[02][01]      	PICTURE   '@E 999,999.99'
@nLin,056 PSAY _nTotGer[03][01]      	PICTURE   '@E 999,999.99'
@nLin,068 PSAY _nTotGer[04][01]      	PICTURE   '@E 999,999.99'
@nLin,080 PSAY _nTotGer[05][01]      	PICTURE   '@E 999,999.99'
@nLin,093 PSAY _nTotGer[06][01]      	PICTURE   '@E 999,999.99'
@nLin,106 PSAY _nTotGer[07][01]      	PICTURE   '@E 999,999.99'
@nLin,119 PSAY _nTotGer[08][01]      	PICTURE   '@E 999,999.99'
@nLin,132 PSAY _nTotGer[09][01]      	PICTURE   '@E 999,999.99'
@nLin,145 PSAY _nTotGer[10][01]      	PICTURE   '@E 999,999.99'
@nLin,155 PSAY _nTotGer[11][01]      	PICTURE   '@E 999,999.99'
@nLin,171 PSAY _nTotGer[12][01]      	PICTURE   '@E 999,999.99'
@nLin,184 PSAY _nTotAcuG  	     	  	PICTURE '@E 9,999,999.99'

//XI3->(dbclosearea())
XF8->(dbclosearea())  
Roda(0,"","M")

Set Device to Screen
If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
Endif
Return

