#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function RFIN170()        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01   

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WNREL,CDESC1,CDESC2,CDESC3,CSTRING,TAMANHO")
SetPrvt("LEND,TITULO,ARETURN,NOMEPROG,ALINHA,NLASTKEY")
SetPrvt("CPERG,M_PAG,LI,CFORANT,CDOCANT,NIPI")
SetPrvt("NICM,NCT,NY,LCONTINUA,LPEDCOM,ADIVERGENCIA")
SetPrvt("APEDIDOS,CPEDIDOS,DDATASAV,ACQ,CLOCDEST,CNOMEGRUPO")
SetPrvt("CABEC1,CABEC2,CABEC3,CBCONT,LIMITE,CSERIE")
SetPrvt("CIMPINC,NIMPINC,NIMPNOINC,CCAMPO,DDATABASE,CPROBLEMA")
SetPrvt("CDIV,NX,COL,NRECN,NORDER,NLIN")
SetPrvt("NCOL,AVENCTO,COLDALIAS,CSPACE,")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 14/05/01 ==> 	#DEFINE PSAY SAY
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RFIN170  ³ Autor ³ Paulo R. Trivelatto   ³ Data ³ 02.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Boletim de Entrada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³09/02/98³05088A³Incluir perg. Imprime Custo Total ou Unit.³±±
±±³Rodrigo Sar.³27/05/98³11234A³Incluir impressao do ICMS solidario.      ³±±
±±³Marcos Simi.³24/06/98³XXXXXX³Acertos do lay-out,Nro. NF com 12 bytes.  ³±±
±±³Bruno       ³15/12/98³melhor³Acertos da soma do total dos impostos para³±±
±±³            ³        ³      ³localizacoes.                             ³±±
±±³ Edson   M. ³30/03/99³XXXXXX³Passar o tamanho na SetPrint.             ³±±
±±³Aline C.Vale³18/10/99³21163a³Imprimir titulos de INSS                  ³±±
±±³Paulo R.Triv³02/02/00³XXXXXX³Conversao p/ RdMake                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Function Matr170()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel   :=""
cDesc1  :="Este programa ira emitir o Boletim de Entrada."
cDesc2  :=""
cDesc3  :=""
cString :="SF1"
tamanho :="P"
lEnd    :=.F.

titulo  :="Boletim de Entrada"
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:="RFIN170"
aLinha  := {}
nLastKey:= 0
cPerg   :="MTR170"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag   := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR170",.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para parametros                         ³
//³ mv_par01             // da Data                              ³
//³ mv_par02             // ate a Data                           ³
//³ mv_par03             // Nota De                              ³
//³ mv_par04             // Nota Ate                             ³
//³ mv_par05             // Imprime Centro Custo X Cta. Contabil ³
//³ mv_par06             // Imprimir o Custo ? Total ou Unit rio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="RFIN170"
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

#IFDEF WINDOWS
   RptStatus({|| R170Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==>    RptStatus({|| Execute(R170Imp)})
	Return
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==>    Function R170Imp
Static Function R170Imp()
#ENDIF

/*
#IFDEF WINDOWS
   RptStatus({|lEnd| R170Imp()},Titulo)
#ELSE
   R170Imp()
#ENDIF

Return

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 10.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function R170Imp
Static Function R170Imp()
*/

Li        :=80
cForAnt   :=""
cDocAnt   :=""
nIpi      :=0
nIcm      :=0
nCt       :=0
nY        :=""
lContinua :=.T.
lPedCom   :=.F.
aDivergencia:= {}
aPedidos  :={}
cPedidos  :=""
dDataSav  :=""
aCQ       :={}
cLocDest  := GetMV("MV_CQ")
cNomeGrupo:=""
cabec1    :=""
cabec2    :=""
cabec3    :=""
cbCont    :=0
Limite    := 80
cSerie    :=""
cImpInc   :=""

nImpInc   :=0
nImpNoInc :=0
cCampo    :=""

dbSelectArea("SF1")
dbSetOrder(1)
If !Empty(mv_par03)
	dbSeek(xFilial()+mv_par03,.T.)
Else
	dbSeek(xFilial(),.F.)
EndIf

SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 0,0 PSAY AvalImp(Limite)

While !Eof() .And. F1_FILIAL == xFilial() .And. SF1->F1_DOC <= mv_par04

	#IFNDEF WINDOWS
		If LastKey() == 286    //ALT_A
			lEnd := .t.
		EndIf
	#ENDIF

	If lEnd
      @PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif

   IncRegua()

	If F1_DTDIGIT < mv_par01 .OR. F1_DTDIGIT > mv_par02
		dbSkip()
		Loop
	EndIf

	If F1_DOC < mv_par03 .or. F1_DOC > mv_par04
		dbSkip()
		Loop
	EndIf

	If ( cPaisLoc=="ARG" )
		nImpInc	:=0
		nImpNoInc:=0
		cImpInc	:=GetMv("MV_IMPINCE")
		For nY:=1 to Len(cImpInc)
			cCampo	:="SF1->F1_VALIMP" + STR(nY,1)
			If SUBS(cImpInc,nY,1)=="S"
             nImpInc   := &cCampo + nImpInc
			Else
             nImpNoInc := &cCampo + nImpNoInc
			EndIf
		Next
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Cabecalho.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Li > 20
      R170Cabec()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao dos itens da Nota de Entrada.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	nCt  		   := 1
	cDocAnt 		:= D1_DOC+D1_SERIE
	cForAnt 		:= D1_FORNECE+D1_LOJA
	aDivergencia:= {}
	aPedidos    := {}
	aCq 			:= {}
   Li := Li + 2
   fCabIten()
//   Li := fCabIten()
	While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial()+cDocAnt+cForAnt
      Li := Li + 1
		If Li >= 63
			Li := 1
         fCabItem()
//         Li := fCabIten()
         Li := Li + 1
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona Todos os Arquivos Ref. ao Itens                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial()+SD1->D1_COD)

		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial()+"03"+SB1->B1_GRUPO)
		cNomeGrupo := SubStr(SX5->X5_DESCRI,1,10)

		dbSelectArea("SC7")
		dbSetOrder(1)
		dbSeek(xFilial()+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
		If Found() .and. SD1->D1_COD == C7_PRODUTO
			lPedCom:=.T.
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial()+SD1->D1_TES)
			dDataSav  := dDataBase
			dDataBase := SD1->D1_DTDIGIT
			cProblema := ""
         cDiv := "Q =DIF.NA QUANTIDADE / P =DIF.NO PRECO / E =DIF.DATA DE ENTREGA"
			If SC7->C7_QUANT #SD1->D1_QUANT
            cProblema := cProblema + "Q"
			Else
            cProblema := cProblema + " "
			EndIf
			If IIf(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)) #SD1->D1_VUNIT
            cProblema := cProblema + "P"
			Else
            cProblema := cProblema + " "
			EndIf
			If SC7->C7_DATPRF #SD1->D1_DTDIGIT
            cProblema := cProblema + "E"
			Else
            cProblema := cProblema + " "
			EndIf
			If !Empty(cProblema)
				AADD(aDivergencia,cProblema+" "+SC7->C7_NUM+"-"+SC7->C7_ITEM+" "+SubStr(SB1->B1_DESC,1,30)+" "+Str(SC7->C7_QUANT,11,2)+" "+Transform(IIf(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)),"@E 99,999,999.99")+" "+DTOC(SC7->C7_DATPRF))
			Else
				AADD(aPedidos,SC7->C7_NUM+"-"+SC7->C7_ITEM)
			Endif
			dDataBase := dDataSav
		Endif
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial()+SD1->D1_TES)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa array dos itens que foram enviados ao CQ (SD7)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SD1->D1_NUMCQ) .AND. SF4->F4_ESTOQUE == "S"
			AADD(aCQ,SD1->D1_NUMCQ+SD1->D1_COD+cLocDest+"001"+DTOS(SD1->D1_DTDIGIT))
		Endif

		@Li,00 PSAY SD1->D1_COD
		@Li,16 PSAY SD1->D1_UM
		@Li,19 PSAY SubStr(SB1->B1_DESC,1,30)
		@Li,49 PSAY SD1->D1_VUNIT Picture PesqPict("SD1","D1_VUNIT",14)
		@Li,66 PSAY SD1->D1_TOTAL Picture PesqPict("SD1","D1_TOTAL",14)
      Li := Li + 1
		@Li,00 PSAY SD1->D1_QUANT Picture PesqPictQt("D1_QUANT",15)
		@Li,17 PSAY SD1->D1_IPI	Picture PesqPict("SD1","D1_IPI",5)
		If ( cPaisLoc=="BRA" )
			@Li,23 PSAY SD1->D1_PICM  Picture PesqPict("SD1","D1_PICM",5)
		EndIf

		If mv_par05 == 1
			@Li,29 PSAY Substr(SD1->D1_CONTA,1,15)
		Else
			@Li,29 PSAY SD1->D1_CC
		EndIf
		If ( cPaisLoc=="BRA" )
			@Li,45 PSAY SD1->D1_CF
		Endif
		@Li,49 PSAY SD1->D1_TES
		If mv_par06 == 1
			@Li,55 PSAY SD1->D1_CUSTO Picture PesqPict("SD1","D1_CUSTO",14)
		Else
			@Li,55 PSAY SD1->D1_CUSTO/SD1->D1_QUANT Picture PesqPict("SD1","D1_CUSTO",14)
		Endif
		@Li,70 PSAY cNomeGrupo
      Li := Li + 1
		dbSelectArea("SD1")
		dbSkip()
	EndDo
   Li := Li + 1
	If Li >= 60
		Li := 1
	Endif
   fCabNF()
//   Li := fCabNF()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime produtos enviados ao Controle de Qualidade SD7       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCQ) > 0
		Li := Li+2
		If Li >= 60
			Li := 1
		Endif
      @ Li, 0 PSAY '----------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------'
		//         123456789012345           99            99          dd/mm/aa
		//                   1         2         3         4         5         6
		//         0123456789012345678901234567890123456789012345678901234567890
      Li := Li + 1
      @Li,0 PSAY "Produto         Local Origem Local Destino Data Transferencia"
      Li := Li + 1
      For nX := 1 to Len(aCQ)
			dbSelectArea("SD7")
			dbSetOrder(1)
			If dbSeek(xFilial()+aCQ[nX],.F.)
            @ Li := Li + 2,00 PSAY SD7->D7_PRODUTO
				@ Li,26 PSAY SD7->D7_LOCAL
				@ Li,40 PSAY SD7->D7_LOCDEST
				@ Li,52 PSAY SD7->D7_DATA
			Endif
		Next nX
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Divergencia com Pedido de Compra.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Li := Li + 2
   @ Li, 0 PSAY '-------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA -----------------------'
   Li := Li + 1
	IF lPedCom
		If !Empty(aPedidos)
         Li := Li + 1
			cPedidos := ""
			For nX := 1 To Len(aPedidos)
            cPedidos := cPedidos + aPedidos[nX]+"\"
			Next nX
			cPedidos := SubStr(cPedidos,1,Len(cPedidos)-1)
         @Li, 0 PSAY "Nao ha divergencias no(s) pedido(s) "+cPedidos
		EndIf
      Li := Li + 1
      @Li, 0 PSAY "COD DIVERGENCIA: "+cDiv
      Li := Li + 1
		If Len(aDivergencia) > 0
         Li := Li + 2
			If Li >= 64
				Li := 1
			Endif
         @Li,0 PSAY "Div Numero    Descricao do Produto            Quantidade Preco Unitar.  Entrega"
			//         123 123456-12 123456789012345678901234567890 99999999,99 99.999.999,99 99/99/99
			//                   1         2         3         4         5         6         7
			//         01234567890123456789012345678901234567890123456789012345678901234567890123456789
		EndIf

		For nX := 1 to Len(aDivergencia)
         Li := Li + 1
			If Li >= 64
				Li := 1
			Endif
			@Li, 0 PSAY aDivergencia[nX]
		Next nX
	Else
		If !Empty(aPedidos)
         Li := Li + 1
			cPedidos := ""
			For nX := 1 To Len(aPedidos)
            cPedidos := cPedidos + aPedidos[nX]+"\"
			Next nX
			cPedidos := SubStr(cPedidos,1,Len(cPedidos)-1)
         @Li, 0 PSAY "Nao ha divergencias no(s) pedido(s) "+cPedidos
		Else
         Li := Li + 1
         @Li, 0 PSAY "Nao ha Pedidos"
		Endif
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime desdobramento de Duplicatas.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	dbSetOrder(6)

   cSerie := GETMV("MV_2DUPREF")
	cSerie := IIF(Len(cSerie) < 3, cSerie+Space(3 - Len(cSerie)), Substr(cSerie,1,3))

	If dbSeek(xFilial("SF1")+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC,.F.)
      Li := Li + 2
		If Li >= 62
			Li := 1
		Endif
		Li := fCabDup(Li)
		Col := 0
		While !Eof() .And. (E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC)

			If cPaisLoc=="BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime dados das duplicatas para Nf com 06 bytes.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Li >= 62
					Li := 1
					Li := fCabDup(Li)
				Endif

				@Li,Col PSAY SE2->E2_PREFIXO+" "+SE2->E2_NUM+' '+SE2->E2_PARCELA+'  '+dtoc(SE2->E2_VENCTO)+Transform(SE2->E2_VALOR,'@E 99,999,999,999.99')
				If Col == 0
					Col := 41
				Else
					Col := 0
               Li := Li + 1
				EndIf

				R170ImpIR( @Li,@Col )
				R170ImpIN( @Li,@Col )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime dados das duplicatas para Nf com 12 bytes.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Li >= 62
					Li := 1
					Li := fCabDup(Li)
				Endif

				@Li,0 PSAY SE2->E2_PREFIXO+" "+SE2->E2_NUM+' '+SE2->E2_PARCELA+'  '+dtoc(SE2->E2_VENCTO)+Transform(SE2->E2_VALOR,'@E 99,999,999,999.99')

            Li := Li + 1

				R170ImpIR( @Li, 0 )
				R170ImpIN( @Li, 0 )

			Endif

			dbSkip()
		EndDo
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Dados do Livros Fiscais.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cPaisLoc=="BRA") //Provisorio, Bruno
		dbSelectArea("SF3")
		dbSetOrder(4)
		If dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE,.F.)
         Li := Li + 2
			If Li >= 58
				Li := 1
			Endif
			Li := fCabLiv(Li)
			While ! Eof() .And. ;
					xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

				If Li >= 58
					Li := 1
					Li := fCabLiv(Li)
				Endif

            Li := Li + 2
            @Li,01 PSAY "Valor Contabil:"
				@Li,16 PSAY SF3->F3_VALCONT	Picture "@E 999,999,999,999.99"
            @Li,54 PSAY "Classificacao Fiscal:"
				@Li,76 PSAY SF3->F3_CFO
            Li := Li + 2
				@Li, 0 PSAY 'ICM'
				@Li,04 PSAY SF3->F3_BASEICM	Picture "@E 999,999,999,999.99"
				@Li,23 PSAY SF3->F3_ALIQICM   Picture "99"
				@Li,26 PSAY SF3->F3_VALICM		Picture "@E 99,999,999,999.99"
				@Li,44 PSAY SF3->F3_ISENICM	Picture "@E 999,999,999,999.99"
				@Li,63 PSAY SF3->F3_OUTRICM	Picture "@E 9,999,999,999.99"
            Li := Li + 1
				If ! EMPTY(SF3->F3_ICMSRET)
					@Li,63 PSAY SF3->F3_ICMSRET	Picture "@E 9,999,999,999.99"
               Li := Li + 1
				Endif
            Li := Li + 1
				If ! EMPTY(SF3->F3_ICMSCOM)
					@Li,63 PSAY SF3->F3_ICMSCOM Picture "@E 9,999,999,999.99"
               Li := Li + 1
				Endif
				@Li, 0 PSAY 'IPI'
				@Li,04 PSAY SF3->F3_BASEIPI	Picture "@E 999,999,999,999.99"
				@Li,26 PSAY SF3->F3_VALIPI		Picture "@E 99,999,999,999.99"
				@Li,44 PSAY SF3->F3_ISENIPI	Picture "@E 999,999,999,999.99"
				@Li,63 PSAY SF3->F3_OUTRIPI	Picture "@E 9,999,999,999.99"
            Li := Li + 1
				If SF3->F3_IPIOBS>0
					@Li,63 PSAY SF3->F3_IPIOBS Picture "@E 9,999,999,999.99"
				Endif

				If !Empty(SF1->F1_CONTSOC)
               LI := Li + 1
					@LI,00 PSAY SF3->F3_OBSERV
               LI := Li + 1
				Endif

				dbSkip()
			EndDo
		Endif
	Endif

	If Li < 60
		Li := 60
	Endif

   @Li,0 PSAY '------------------------------------ VISTOS ------------------------------------'
   Li := Li + 1
	@Li,0 PSAY '                     |                   |                   |'
   Li := Li + 1
	@Li,0 PSAY '--------------------------------------------------------------------------------'
	dbSelectArea("SF1")
	dbSkip()

EndDO

dbSelectArea("SF1")
Set Filter To
dbSetOrder(1)

Set device to Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170ImpIR() ³ Autor ³Ben-Hur M Castilho  ³ Data ³ 03/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Titulo de IR no Desdobramento de Duplicatas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R170ImpIR( ExpN1,ExpN2 )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Linha da Impressao                                 ³±±
±±³          ³ ExpN2 - Coluna da Impressao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function R170ImpIR
Static Function R170ImpIR()

nRecN  := 0
nOrder := 0

If !Empty(SE2->E2_IRRF )

	nRecN  := RecNo()
	nOrder := IndexOrd()

	dbSetOrder(1)
   If dbSeek(xFilial()+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCIR+"TX ",.F.)
		If nLin >= 62
			nLin := 1
         nLin := fCabDup()
		Endif
		@nLin,nCol PSAY SE2->E2_PREFIXO+" "+SE2->E2_NUM+' '+SE2->E2_PARCELA+'  '+dtoc(SE2->E2_VENCTO)+Transform(SE2->E2_VALOR,'@E 999,999,999.99')+" IR"
		If cPaisLoc=="BRA"
			If nCol == 0
				nCol := 41
			Else
				nCol := 0
            nLin := Li + 1
			EndIf
		Else
         nLin := Li + 1
		Endif
	EndIf

	dbSetOrder(nOrder)
	dbGoTo(nRecN)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170ImpIN() ³ Autor ³Aline Correa do Vale³ Data ³ 18/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Titulo de INSS no Desdobramento de Duplicatas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R170ImpIN( ExpN1,ExpN2 )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Linha da Impressao                                 ³±±
±±³          ³ ExpN2 - Coluna da Impressao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function R170ImpIN       //(nLin,nCol)
Static Function R170ImpIN       //(nLin,nCol)()

nRecN  := RecNo()
nOrder := IndexOrd()

If !Empty( E2_INSS )
	dbSetOrder(1)
	If dbSeek(xFilial()+E2_PREFIXO+E2_NUM+E2_PARCINS+"INS",.F.)
		If nLin >= 62
			nLin := 1
			nLin := fCabDup(nLin)
		Endif
		@nLin,nCol PSAY SE2->E2_PREFIXO+" "+SE2->E2_NUM+' '+SE2->E2_PARCELA+'  '+dtoc(SE2->E2_VENCTO)+Transform(SE2->E2_VALOR,'@E 999,999,999.99')+" INSS"
		If cPaisLoc=="BRA"
			If nCol == 0
				nCol := 41
			Else
				nCol := 0
            nLin := nLin + 1
			EndIf
		Else
         nLin := nLin + 1
		Endif
	EndIf

	dbSetOrder(nOrder)
	dbGoTo(nRecN)
EndIf

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCabIten()  ³ Autor ³                    ³ Data ³ 19.11.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cabecalho de Itens.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabNF()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function fCabIten
Static Function fCabIten()

@Li, 0 PSAY "----------------------------- DADOS DA NOTA FISCAL -----------------------------"
Li := Li + 1
@Li, 0 PSAY "Codigo Material UN Descricao da Mercadoria       Valor Unitario      Valor Total"
Li := Li + 1
@Li, 0 PSAY "Quantidade         IPI  ICM  " + IIF(mv_par05 == 1,"Cta Contabil    ","Centro de Custo ") + IIF(mv_par06 == 2 ,"CFO TE    Custo Unitario Grupo","CFO TE       Custo Total Grupo")
Li := Li + 1
@Li, 0 PSAY RepLi('-',80)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCabNF()    ³ Autor ³                    ³ Data ³ 19.11.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dados Totais da Nota Fiscal.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabIten()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function fCabNF
Static Function fCabNF()

dbSelectArea("SF1")

@Li,  0 PSAY repLi('-',80)
Li := Li + 1
@Li,  0 PSAY "Valor Mercadoria "
@Li, 18 PSAY SF1->F1_VALMERC 			Picture '@E 999,999,999,999.99'
@Li, 37 PSAY "ICM"
If ( cPaisLoc=="BRA" )
	@Li, 41 PSAY SF1->F1_VALICM			Picture '@E 99,999,999,999.99'
Else
	@Li, 41 PSAY nImpNoInc					Picture '@E 99,999,999,999.99'
EndIf

@Li, 59 PSAY "IPI"

If ( cPaisLoc=="ARG" )
	@Li, 64 PSAY nImpInc			Picture '@E 9,999,999,999.99'
Else
	@Li, 64 PSAY SF1->F1_VALIPI			Picture '@E 9,999,999,999.99'
EndIf
Li := Li + 1

If SF1->F1_ICMSRET > 0
   @Li,  0 PSAY "ICMS Solid."
	@Li, 18 PSAY SF1->F1_ICMSRET Picture '@E 999,999,999,999.99'
   Li := Li + 1
Endif

If SF1->F1_CONTSOC > 0
   @Li,  0 PSAY "Desp. Acessorias"
	@Li, 18 PSAY (SF1->F1_DESPESA+SF1->F1_FRETE) 	Picture '@E 999,999,999,999.99'
   @Li, 37 PSAY "Contr.Seguridade Social"
	@LI, 64 PSAY SF1->F1_CONTSOC 							Picture '@E 9,999,999,999.99'
Else
   @Li,  0 PSAY "Desp. Acessorias"
	@Li, 18 PSAY (SF1->F1_DESPESA+SF1->F1_FRETE) 	Picture '@E 999,999,999,999.99'
Endif

Li := Li + 1
@Li, 0 PSAY "Descontos "
@Li,18 PSAY SF1->F1_DESCONT 																						Picture '@E 999,999,999,999.99'
@Li,37 PSAY "Valor Total da Nota"
If ( cPaisLoc=="ARG" )
   @Li,60 PSAY (SF1->F1_VALMERC+SF1->F1_DESPESA+SF1->F1_FRETE-SF1->F1_DESCONT+nImpInc) 	Picture '@E 999,999,999,999.99'
Else
	@Li,60 PSAY (SF1->F1_VALMERC+If(SF1->F1_TIPO=="P",0,SF1->F1_VALIPI)+SF1->F1_DESPESA+SF1->F1_FRETE+SF1->F1_ICMSRET-SF1->F1_DESCONT) 	Picture '@E 999,999,999,999.99'
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCabDup()   ³ Autor ³                    ³ Data ³ 19.11.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Desdobramento de DupLicatas.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabDup()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function fCabDup         //(Li)
Static Function fCabDup         //(Li)()

If cPaisLoc=="BRA"
   @Li, 0 PSAY '------------------------ DESDOBRAMENTO DE DUPLICATAS ---------------------------'
   Li := Li + 1
   @Li, 0 PSAY "Ser Titulo PC Vencmnto  Valor do Titulo  Ser.Titulo PC Vencmnto  Valor do Titulo"
   Li := Li + 1
Else
   @Li, 0 PSAY '------------------------ DESDOBRAMENTO DE DUPLICATAS ---------------------------'
   Li := Li + 1
   @Li, 0 PSAY "Ser Titulo       PC Vencmnto  Valor do Titulo "
   Li := Li + 1
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCabLiv()   ³ Autor ³                    ³ Data ³ 19.11.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Demonstrativos dos Livros Fiscais.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabLiv()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function fCabLiv        //(Li)
Static Function fCabLiv        //(Li)()

@Li,0 PSAY '--------------------- DEMONSTRATIVO DOS LIVROS FISCAIS -------------------------'
Li := Li + 2
@Li,08 PSAY 'Operacoes c/ credito de Imposto        Operacoes s/ credito de Imposto'
Li := Li + 1
@Li,09 PSAY 'Base de     ALiq.     Imposto            Isentas         Outras'
Li := Li + 1
@Li,09 PSAY 'Calculo              Creditado                              Obsevacoes'

Return(Li)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R170Cabec() ³ Autor ³ Jose Lucas         ³ Data ³ 19.11.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime cabecalho do Boletim.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A170Cabec()		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function R170Cabec
Static Function R170Cabec()

aVencto  := {}
cOldAlias:= "" 
cSpace   := IF(Len(DTOC(SF1->F1_EMISSAO))==8," ","")
cSerie   := ""

If SF1->F1_TIPO $ "DB"
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC)
   Do While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC
		AADD(aVencto,E1_VENCTO)
		dbSkip()
   EndDo
	Li := 01
   @Li,0 PSAY 'BOLETIM DE ENTRADA      Material recebido em: '+dtoc(SF1->F1_DTDIGIT)+IIf( SF1->F1_TIPO == 'D'," - (Devolucao)","")
   Li := Li + 1
	@li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL
   Li := Li + 1
	@Li,0 PSAY Replicate('-',80)
   Li := Li + 1
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA)

	If cPaisLoc=="BRA"
      @Li,0 PSAY 'CLiente                                      | Nota Fiscal  | Emissao  | Vencto'
      Li := Li + 1
		@Li, 0 PSAY SUBS(SA1->A1_NOME,1,27)+' '+SA1->A1_COD
		@Li,43 PSAY '| '+SF1->F1_SERIE+' '+SF1->F1_DOC
		@Li,58 PSAY '|'+cSpace+DTOC(SF1->F1_EMISSAO)+cSpace+'|'
	Else
      @Li,0 PSAY 'CLiente                                      | Nota Fiscal  | Emissao  | Vencto'
      Li := Li + 1
		@Li, 0 PSAY SUBS(SA1->A1_NOME,1,29)+' '+SA1->A1_COD
		@Li,39 PSAY '| '+SF1->F1_SERIE+' '+SF1->F1_DOC
		@Li,60 PSAY '| '+DTOC(SF1->F1_EMISSAO)+' |'
	Endif

	cOldAlias:=Alias()
	dbSelectArea("SE2")
	dbSetOrder(6)

	cSerie := &(GETMV("MV_2DUPREF"))
	cSerie := IIF(Len(cSerie) < 3, cSerie+Space(3 - Len(cSerie)), Substr(cSerie,1,3))

	If dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC,.F.)
      @Li,70 PSAY cSpace+IIf( Len(aVencto) == 1, DTOC(aVencto[1]),"Diversos" )
	EndIf
	dbSelectArea(cOldAlias)
   Li := Li + 1
	@Li,0 PSAY Substr(SA1->A1_END,1,29)
   @Li,45-IIf(cPaisLoc=="BRA",0,6) PSAY '| Valor Total   '+transform((SF1->F1_VALMERC+SF1->F1_VALiPI+SF1->F1_DESPESA+SF1->F1_FRETE-SF1->F1_DESCONT),"@E 99,999,999,999.99")
   Li := Li + 1
	@Li,0 PSAY SA1->A1_MUN+' '+SA1->A1_EST+' '+transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
Else
	dbSelectArea("SE2")
	dbSetOrder(6)

   cSerie := GETMV("MV_2DUPREF")
	cSerie := IIF(Len(cSerie) < 3, cSerie+Space(3 - Len(cSerie)), Substr(cSerie,1,3))

	dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC)
	While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC
		AADD(aVencto,E2_VENCTO)
		dbSkip()
	End
	Li := 01
   @Li,0 PSAY 'BOLETIM DE ENTRADA      Material recebido em: '+dtoc(SF1->F1_DTDIGIT)+IIf( SF1->F1_TIPO == 'D'," - (Devolucao)","")
   Li := Li + 1
	@li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL
   Li := Li + 1
	@Li,0 PSAY Replicate('-',80)
   Li := Li + 1

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA)

	If cPaisLoc=="BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime dados das duplicatas para Nf com 06 bytes.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      @Li,0 PSAY 'Fornecedor                                 | Nota Fiscal  | Emissao  |  Vencto'
      Li := Li + 1
		@Li,00 PSAY SUBS(SA2->A2_NOME,1,32)+' '+SA2->A2_COD
		@Li,43 PSAY '| '+SF1->F1_SERIE+' '+SF1->F1_DOC
		@Li,58 PSAY '|'+cSpace+DTOC(SF1->F1_EMISSAO)+cSpace+'|'
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime dados das duplicatas para Nf com 12 bytes.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      @Li,0 PSAY 'Fornecedor                                   | Nota Fiscal  | Emissao  | Vencto'
      Li := Li + 1
		@Li,00 PSAY SUBS(SA2->A2_NOME,1,29)+' '+SA2->A2_COD
		@Li,39 PSAY '| '+SF1->F1_SERIE+' '+SF1->F1_DOC
		@Li,60 PSAY '| '+DTOC(SF1->F1_EMISSAO)+' |'
	Endif

	cOldAlias:=Alias()
	dbSelectArea("SE2")
	dbSetOrder(6)
	If dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+cSerie+SF1->F1_DOC,.F.)
		@Li,70 PSAY cSpace+IIf( Len(aVencto) == 1, DTOC(aVencto[1]),"Diversos" )
	EndIf

	dbSelectArea(cOldAlias)
   Li := Li + 1
	@Li,0 PSAY Substr(SA2->A2_END,1,35)
   @Li,45-IIf(cPaisLoc=="BRA",0,6) PSAY '| Valor Total   '+Transform(IIf(cPaisLoc=="BRA",(SF1->F1_VALMERC+SF1->F1_VALiPI+SF1->F1_DESPESA+SF1->F1_FRETE-SF1->F1_DESCONT),(SF1->F1_VALMERC+nImpInc+SF1->F1_DESPESA+SF1->F1_FRETE-SF1->F1_DESCONT)),"@E 9,999,999,999.99")
   Li := Li + 1
	@Li,0 PSAY SA2->A2_MUN+' '+SA2->A2_EST+' '+Transform(SA2->A2_CGC,Iif(cPaisLoc=="ARG","@R 99-99.999.999-9","@R 99.999.999/9999-99"))
EndIf

Return
