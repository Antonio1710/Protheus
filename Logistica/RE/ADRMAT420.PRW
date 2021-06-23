#INCLUDE "MATR420.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR420  ³ Autor ³Michel Diniz           ³ Data ³21/04/2010 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo diario das movimentacos do Kardex Analitico         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR420(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico    - Solicitado por Bisolo conf. proposta A002-10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADRMAT420()

Local Tamanho  		:= "M"
Local titulo   		:= STR0001	//"Resumo Diario do Kardex"
Local cDesc1   		:= STR0002	//"Este programa emite uma rela‡„o ,resumida por dia ,das movimenta‡”es"
Local cDesc2   		:= STR0003	//"dos produtos e materiais de estoque. Ele aglutina as entradas e"
Local cDesc3   		:= STR0004	//"saidas em uma £nica linha para cada dia."
Local cString  		:= "SB1"
Local wnrel    		:= "MATR420"
Local aArea1		:= Getarea()
Local aFilsCalc 	:= {}
Local nTamSX1   	:= Len(SX1->X1_GRUPO)

Private lVEIC   	:= Upper(GetMV("MV_VEICULO"))=="S"
Private aSB1Cod 	:= {}
Private aSB1Ite 	:= {}
Private nCOL1		:= 0
Private aOrd    	:= {OemToAnsi(STR0005),OemToAnsi(STR0006)}		//" Codigo Produto "###" Tipo do Produto"
Private aReturn 	:= {OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
Private nLastKey	:= 0 ,cPerg := "MTR420"
Private bBloco  	:= { |nV,nX| Trim(nV)+IIf(Valtype(nX)='C',"",Str(nX,1)) }
Private lCusUnif 	:= IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Resumo diario das movimentacos do Kardex Analitico')

aSB1Cod	:= TAMSX3("B1_COD")
aSB1Ite	:= TAMSX3("B1_CODITE")

If lCusUnif					&& Ajusta perguntas no SX1 a fim de preparar o relatorio p/
	MTR420CUST(lCusUnif)	&& custo unificado por empresa
EndIf

AjustaSX1()

If lVEIC
   dbSelectArea("SX1")
   dbSetOrder(1)
   dbSeek(PADR(cPerg,nTamSX1))
   Do While SX1->X1_GRUPO == PADR(cPerg,nTamSX1) .AND. !SX1->(EOF())
      If "PRODU" $ Upper(SX1->X1_PERGUNT) .And. Upper(SX1->X1_TIPO) == "C" .And. ;
      (SX1->X1_TAMANHO <> aSB1Ite[1] .Or. Upper(SX1->X1_F3) <> "VR4")
         Reclock("SX1",.F.)
         SX1->X1_TAMANHO := aSB1Ite[1]
         SX1->X1_F3 := "VR4"
         dbCommit()
         MsUnlock()
      EndIf
      dbSkip()
   EndDo
   dbCommitAll()
   RestArea(aArea1)
Else
   dbSelectArea("SX1")
   dbSetOrder(1)
   dbSeek(PADR(cPerg,nTamSX1))
   Do While SX1->X1_GRUPO == PADR(cPerg,nTamSX1) .And. !SX1->(EOF())
      If "PRODU" $ Upper(SX1->X1_PERGUNT) .And. Upper(SX1->X1_TIPO) == "C" .And. ;
      (SX1->X1_TAMANHO <> aSB1Cod[1] .Or. UPPER(SX1->X1_F3) <> "SB1")
         Reclock("SX1",.F.)
         SX1->X1_TAMANHO := aSB1Cod[1]
         SX1->X1_F3 := "SB1"
         dbCommit()
         MsUnlock()
      EndIf
      dbSkip()
   EndDo
   dbCommitAll()
   RestArea(aArea1)
EndIf
                                               
Pergunte("MTR420",.F.)

wnRel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F. ,aOrd)

If nLastKey = 27
	dbSelectArea("SB1")
	dbClearFilter()
	Return
EndIf

aFilsCalc := MatFilCalc((mv_par12 == 1))

If Empty(aFilsCalc)
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	dbSelectArea("SB1")
	dbClearFilter()
	Return
EndIf

Processa( { |lEnd| C420Imp( @lEnd, wnRel, titulo, Tamanho, aFilsCalc ) }, titulo )

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C420IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 14.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C420Imp(lEnd,WnRel,titulo,Tamanho,aFilsCalc)

Local lDev  		&& Flag que indica se nota ‚ devolu‡ao (.T.) ou nao (.F.)
Local cCusto
Local lInvertMov	:= .F.
Local lLocProc   	:= mv_par08 == GetMv("MV_LOCPROC")
Local lRemInt    	:= SuperGetMv("MV_REMINT",.F.,.F.)
Local nInd			:=0,cTrbSD3:=""
Local cArq1			:= "" 
Local nInd1			:= 0
Local lT			:= .F.
Local nForFilial 	:= 0
Local cFilBack   	:= cFilAnt
Local aSalAlmox		:={},aArea:={}
Local cSeek			:=""
Local i				:=0
Local cProdMNT 		:= GetMv("MV_PRODMNT")
Local cProdTER 		:= GetMv("MV_PRODTER")

cProdMNT := cProdMNT + Space(15-Len(cProdMNT))
cProdTER := cProdTER + Space(15-Len(cProdTER))

Private cProdAnt  	:= ""
Private cAnt 	  	:= ""
Private lFirst1   	:= .T.
Private aSalAtu   	:= {}
Private nEntPriUM,nSaiPriUM,nEntSegUM,nSaiSegUM,nEntraVal,nSaidaVal
Private nRec1,nRec2,nRec3,nRecCN,nRecCM,nSavRec
Private dDataIni,dDataFim,dCntData
Private cPicB2Qt  	:= PesqPictQt("B2_QATU"   ,16)
Private cPicB2Qt2 	:= PesqPictQt("B2_QTSEGUM",16)
Private nEntrada  	:= nSaida 	:=0
Private nCEntrada 	:= nCSaida	:=0
Private cPicD1Cust	:= PesqPict("SD1","D1_CUSTO",18,mv_par10)
Private aEntrada	:= {}
Private aSaida		:= {}      
Private nSaldoLinha := 0
Private nTotEnt		:= 0
Private nTotSai		:= 0

dDataIni:= mv_par05
dDataFim:= mv_par06

For nForFilial := 1 To Len( aFilsCalc )

	If aFilsCalc[ nForFilial, 1 ]
	
		cFilAnt := aFilsCalc[ nForFilial, 2 ]

		&& Variaveis utilizadas para Impressao do Cabecalho e Rodape 
		cbtxt := SPACE(10)
		cbcont:= 0
		li    := 80
		m_pag := 01
		
		nTipo := IIF(aReturn[4]==1,15,18)
		

		cabec1:= "DATA DO    |             E  N  T  R  A  D  A  S             |              S  A  I  D  A  S                 |    S  A  L  D  O  "
		cabec2:= "MOVIMENTO  |HORARIO    NF.ORIG.    PLACA    CFOP      QUANT.|HORARIO    ROTEIRO    PLACA    CFOP      QUANT.|       QUANTIDADE "
		//***     11/11/1111   1111234567890.12  1111123456789010.12   1111234567890.12  1111123456789010.12    1112345678900.12    1111234567890110.12
		//***     0         1         2         3         4         5         6         7         8         9        10        11        12        13
		//***     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
		
		&& Adiciona a ordem escolhida ao titulo do relatorio
		If Type("NewHead")#"U"
			NewHead += STR0011+AllTrim(aOrd[aReturn[8]])+STR0012+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par10))))+")"		//" (Por "###" ,em "
		Else
			Titulo  += STR0011+AllTrim(aOrd[aReturn[8]])+STR0012+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par10))))+")"		//" (Por "###" ,em "
		EndIf
		
		//------------------------- Pega a data inicial ideal no SD1
		dbSelectArea("SD1")
		nSavRec := recno()
		dbSetOrder(6)
		dbSeeK(xFilial("SD1")+DTOS(mv_par05),.T.)
		If Day(D1_DTDIGIT) > 0
			dDataIni := D1_DTDIGIT
		EndIf
		//------------------------- Pega a data final ideal no SD1
		dbSeeK(xFilial("SD1")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If Day(D1_DTDIGIT) > 0 .and. D1_DTDIGIT <= mv_par06
			dDataFim := D1_DTDIGIT
		EndIf
		GoTo nSavRec
		
		//------------------------- Pega a data inicial ideal no SD2
		dbSelectArea("SD2")
		nSavRec := recno()
		dbSetOrder(5)
		dbSeeK(xFilial("SD2")+DTOS(mv_par05),.T.)
		If !EOF() .And. D2_EMISSAO < dDataIni
			If Day(D2_EMISSAO) > 0
				dDataIni := D2_EMISSAO
			EndIf
		EndIf
		//------------------------- Pega a data final ideal no SD2
		dbSeeK(xFilial("SD2")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If D2_EMISSAO > dDataFim .and. D2_EMISSAO <= mv_par06
			dDataFim := D2_EMISSAO
		EndIf
		GoTo nSavRec
		
		//------------------------- Pega a data inicial ideal no SD3
		dbSelectArea("SD3")
		nSavRec := recno()
		dbSetOrder(6)
		dbSeeK(xFilial("SD3")+DTOS(mv_par05),.T.)
		If !EOF() .And. D3_EMISSAO < dDataIni
			If Day(D3_EMISSAO) > 0
				dDataIni := D3_EMISSAO
			EndIf
		EndIf
		//------------------------- Pega a data final ideal no SD3
		dbSeeK(xFilial("SD3")+DTOS(mv_par06)+"zzzz",.T.)
		If !BOF()
			dbSkip(-1)
		EndIf
		If D3_EMISSAO > dDataFim .and. D3_EMISSAO <= mv_par06
			dDataFim := D3_EMISSAO
		EndIf
		GoTo nSavRec

		If dDataIni < mv_par05
			dDataIni := mv_par05
		EndIF
		
		If dDataFim > mv_par06
			dDataFim := mv_par06
		EndIf

		lCusUnif:=lCusUnif .And. mv_par08 == "**"	&& Verifica se utiliza custo unificado por empresa
		
		// Caso imprima armazem de processo cria indice de trabalho
		If lLocProc .Or. lCusUnif
			cTRBSD3 := CriaTrab(,.F.)
			INDREGUA("SD3",cTrbSD3,"D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ",,DBFilter())
			nInd := RetIndex("SD3")
			#IFNDEF TOP
				dbSetIndex(cTrbSD3+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd+1)
		Else
			dbSetOrder(7)
		EndIf
		
		dbSelectArea("SB2")
		dbSetOrder(1)

		&& Verifica a Ordem do Relatorio a ser impresso
		dbSelectArea("SB1")
		If aReturn[8]==1
		   If !lVEIC
				dbSetOrder(1)
				cCond1:="B1_COD"
			Else
				cCond1:="B1_CODITE"
				cArq1	:= CriaTrab( nil,.F. )
				IndRegua('SB1',cArq1,"B1_FILIAL+B1_CODITE")
				nInd1	:= RetIndex('SB1')
				#IFNDEF TOP
					dbSetIndex(cArq1 + OrdBagExt())
				#ENDIF
				dbSetOrder(nInd1 + 1)
			EndIf	
			dbseek(xFilial("SB1")+mv_par01,.T.)
			cCond2:="mv_par02"
		ElseIf aReturn[8] == 2
		   If !lVEIC
				dbSetOrder(2)
		   Else
				cArq1	:= CriaTrab( nil,.F. )
				IndRegua('SB1',cArq1,"B1_FILIAL+B1_TIPO+B1_CODITE")
				nInd1	:= RetIndex('SB1')
				#IFNDEF TOP
					dbSetIndex(cArq1 + OrdBagExt())
				#ENDIF
				dbSetOrder(nInd1 + 1)
			EndIf
			dbseek(xFilial("SB1")+mv_par03,.T.)
			cCond1:="B1_TIPO"
			cCond2:="mv_par04"
		EndIf
		
		&& Inicializa variaveis para controlar cursor de progressao
		ProcRegua( RecCount() )
		
		While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") .and. &cCond1 <= &cCond2
			
			If lEnd
				@PROW()+1,001 PSay STR0013		//"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			&& Não imprimir o produto MANUTENCAO (MV_PRDMNT) qdo integrado com MNT.
			If (FindFunction("MTR420IsMNT"))
				If MTR420IsMNT() .and. AllTrim(SB1->B1_COD) == AllTrim(cProdMNT) .and. AllTrim(SB1->B1_COD) == AllTrim(cProdTER)
					DbSkip()
					Loop
				EndIf	
			EndIf
			
			IncProc( STR0001 + " - " + aFilsCalc[ nForFilial, 3 ] )
			
			dbSelectArea("SB1")
			&&  Filtra por Tipo
			If SB1->B1_TIPO < mv_par03 .or. SB1->B1_TIPO > mv_par04
				dbSkip()
				Loop
			EndIf
			
			&& Filtra por Produto
			lT := .F.
			If ! lVEIC
				If SB1->B1_COD < mv_par01 .or. SB1->B1_COD > mv_par02
					lT := .T.
				EndIf
			Else
				If SB1->B1_CODITE < mv_par01 .or. SB1->B1_CODITE > mv_par02
					lT := .T.
				EndIf
			EndIf
			If lT
				dbSkip()
				Loop
			EndIf
			
			dbSelectArea("SB2")
			dbSeek(xFilial("SB2")+SB1->B1_COD+If( lCusUnif, "", mv_par08))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrar no arquivo de saldos ,nao lista ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Eof()
				dbSelectArea("SB1")
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Saldo Inicial do Produto             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEntrada := nSaida  := 0
			nCEntrada:= nCSaida := 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Saldo Inicial do Produto             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCusUnif
				aArea:=GetArea()
				aSalAtu  := { 0,0,0,0,0,0,0 }
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek(cSeek:=xFilial("SB2") + (SB1->B1_COD))
				While !Eof() .And. SB2->B2_FILIAL+SB2->B2_COD == cSeek
					aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,mv_par05)
					For i:=1 to Len(aSalAtu)
						aSalAtu[i] += aSalAlmox[i]
					Next i
					dbSkip()
				End
				RestArea(aArea)
			Else
				aSalAtu := CalcEst(SB1->B1_COD,mv_par08,mv_par05)
			EndIf
			
			cProdAnt  := SB1->B1_COD
			cLocalAnt := mv_par08
			dCntData  := dDataIni
			Store 0 To nRec1,nRec2,nRec3,nRecCM,nRecCN
			lFirst1  := .T.
			
			// Posiciona pela Data mais Proxima no Movimento de Entrada
			dbSelectArea("SD1")
			dbSetOrder(7)
			dbSeek(xFilial("SD1")+SB1->B1_COD+If(lCusUnif,"",mv_par08+dtos(mv_par05)),.T.)
			
			// Posiciona pela Data mais Proxima no Movimento de Saida
			dbSelectArea("SD2")
			dbSetOrder(6)
			dbSeek(xFilial("SD2")+SB1->B1_COD+If(lCusUnif,"",mv_par08+dtos(mv_par05)),.T.)
			
			// Posiciona pela Data mais Proxima na Movimentacao Interna
			dbSelectArea("SD3")
			dbSeek(xFilial("SD3")+SB1->B1_COD+If(lLocProc .Or. lCusUnif,"",mv_par08)+dtos(mv_par05),.T.)
			

			While .T.
				
				Store 0 To nEntPriUM,nSaiPriUM,nEntSegUM,nSaiSegUM,nEntraVal,nSaidaVal
				aEntrada	:= {}
				aSaida		:= {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as entradas do dia                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				dbSelectArea("SD1")
				While !eof() .And. d1_filial == xFilial("SD1") .and. SD1->d1_dtdigit <= dDataFim .and. SD1->d1_dtdigit = dCntData .and. SD1->d1_cod = cProdAnt .and. If(lLocProc .Or. lCusUnif,.T.,SD1->D1_LOCAL == cLocalAnt)
					
					dbSelectArea("SF4")
					dbSeek(xFilial("SF4")+SD1->D1_TES)
					dbSelectArea("SD1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SD1->D1_ORIGLAN $ "LF" .Or. SF4->F4_ESTOQUE != "S"
						dbSkip()
						Loop
					EndIf
					
					If cPaisLoc != "BRA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Desconsiderar notas de remito e notas geradas pelo EIC       ³
						//| com excecao da nota de FOB.									 |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(SD1->D1_REMITO) .Or. SD1->D1_TIPO_NF $ '6789AB'
							SD1->(dbSkip())
							Loop
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Desconsiderar notas de entrada tipo 10 quando o cliente uti_ |
						//| lizar o conceito de remito interno com importacao (SIGAEIC)  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lRemInt
							If !Empty(SD1->D1_CONHEC) .And. SD1->D1_TIPO_NF $ '5' .And. SD1->D1_TIPODOC $ '10'
								SD1->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					lDev:=MTR420Dev()
					dbSelectArea("SF1")
					SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
					dbselectarea("SD1")
					If SD1->D1_TES <= "500" .And. !lDev                                               
						
						nEnt := Ascan(aEntrada,{|x|x[3]+x[4]+x[5]==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_PLACA+SD1->D1_CF } )
						If nEnt == 0
							aAdd( aEntrada, { SD1->D1_DTDIGIT, SF1->F1_HORA, SD1->D1_DOC+SD1->D1_SERIE, SD1->D1_PLACA, SD1->D1_CF, SD1->D1_QUANT, SD1->D1_QUANT } )
						Else
							aEntrada[nEnt,06] += SD1->D1_QUANT
							aEntrada[nEnt,07] += SD1->D1_QUANT
						EndIf	
						nEntrada  += SD1->D1_QUANT
						nEntPriUM += SD1->D1_QUANT
						nEntSegUM += SD1->D1_QTSEGUM
						nCEntrada += &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						nEntraVal += &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
					Else
						If !lDev                                          
							nEnt := Ascan(aSaida,{|x|x[3]+x[4]+x[5]==SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_PLACA+SD1->D1_CF } )
							If nEnt == 0
								aAdd( aSaida, { SD1->D1_DTDIGIT, SF1->F1_HORA, SD1->D1_DOC+SD1->D1_SERIE, SD1->D1_PLACA, SD1->D1_CF, SD1->D1_QUANT, -SD1->D1_QUANT } )
							Else
								aSaida[nEnt,06] += SD1->D1_QUANT
								aSaida[nEnt,07] -= SD1->D1_QUANT
							EndIf
							nSaida    += SD1->D1_QUANT
							nSaiPriUM -= SD1->D1_QUANT
							nSaiSegUM -= SD1->D1_QTSEGUM
							nCSaida   += &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
							nSaidaVal -= &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						Else                                                  
							nEnt := Ascan(aSaida,{|x|x[3]+x[4]+x[5]==SD1->D1_NFORI+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_CF } )
							If nEnt == 0
								aAdd( aSaida, { SD1->D1_DTDIGIT, SF1->F1_HORA, SD1->D1_DOC+SD1->D1_SERIE, SD1->D1_PLACA, SD1->D1_CF, -SD1->D1_QUANT, SD1->D1_QUANT } )
							Else
								aSaida[nEnt,06] -= SD1->D1_QUANT
								aSaida[nEnt,07] += SD1->D1_QUANT
							EndIf						
							nSaida    -= SD1->D1_QUANT
							nSaiPriUM += SD1->D1_QUANT
							nSaiSegUM += SD1->D1_QTSEGUM
							nCSaida   -= &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
							nSaidaVal += &(Eval(bBloco,"SD1->D1_CUSTO",iif(mv_par10==1," ",mv_par10)))
						EndIf
					EndIf
					nRec1++
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as movimentacoes internas do dia            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD3")
				While !Eof() .And. SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_EMISSAO <= dDataFim .And. SD3->D3_EMISSAO == dCntData .And. SD3->D3_COD == cProdAnt .And. If(lLocProc .Or. lCusUnif,.T.,SD3->D3_LOCAL == cLocalAnt)
					If !D3Valido()
						dbSkip()
						Loop
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando movimento ref apropr. indireta, so considera os         ³
					//³ movimentos com destino ao almoxarifado de apropriacao indireta.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lInvertMov := .F.
					If SD3->D3_LOCAL != cLocalAnt
						If !(SubStr(D3_CF,3,1) $ "3")
							If !lCusUnif						
								dbSkip()
								Loop
							EndIf
						Else
							lInvertMov := .T.
						EndIf
					EndIf
					
					dbSelectArea("SF5")
					dbSeek(xFilial("SF5")+SD3->D3_TM)
					dbSelectArea("SD3")
					
					If lInvertMov
						If D3_TM > "500"                                    
							
							nEnt := Ascan(aEntrada,{|x|x[1]==SD3->D3_EMISSAO } )
							If nEnt == 0
								aAdd( aEntrada, { SD3->D3_EMISSAO, Space(05) , SD3->D3_DOC, '', '', SD3->D3_QUANT, SD3->D3_QUANT } )
							Else
								aEntrada[nEnt,06] += SD3->D3_QUANT
								aEntrada[nEnt,07] += SD3->D3_QUANT
							EndIf
													
							nEntrada  += SD3->D3_QUANT
							nEntPriUM += SD3->D3_QUANT
							nEntSegUM += SD3->D3_QTSEGUM
							nCEntrada += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
						Else                                                
							nEnt := Ascan(aSaida,{|x|x[1]==SD3->D3_EMISSAO } )
							If nEnt == 0
								aAdd( aSaida, { SD3->D3_EMISSAO, Space(05) , SD3->D3_DOC, '', '', SD3->D3_QUANT, -SD3->D3_QUANT } )
							Else
								aSaida[nEnt,06] += SD3->D3_QUANT
								aSaida[nEnt,07] -= SD3->D3_QUANT
							EndIf						
							nSaida    += SD3->D3_QUANT
							nSaiPriUM -= SD3->D3_QUANT
							nSaiSegUM -= SD3->D3_QTSEGUM
							nCSaida   += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
							nSaidaVal -= &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
						EndIf
					Else
						If D3_TM <= "500"                                   
							nEnt := Ascan(aEntrada,{|x|x[1]==SD3->D3_EMISSAO } )
							If nEnt == 0
								aAdd( aEntrada, { SD3->D3_EMISSAO, Space(05) , SD3->D3_DOC, '', '', SD3->D3_QUANT, SD3->D3_QUANT } )
							Else
								aEntrada[nEnt,06] += SD3->D3_QUANT
								aEntrada[nEnt,07] += SD3->D3_QUANT
							EndIf						
							nEntrada  += SD3->D3_QUANT
							nEntPriUM += SD3->D3_QUANT
							nEntSegUM += SD3->D3_QTSEGUM
							nCEntrada += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
						Else     
							nEnt := Ascan(aEntrada,{|x|x[1]==SD3->D3_EMISSAO } )
							If nEnt == 0
								aAdd( aEntrada, { SD3->D3_EMISSAO, Space(05) , SD3->D3_DOC, '', '', SD3->D3_QUANT, -SD3->D3_QUANT } )
							Else
								aEntrada[nEnt,06] += SD3->D3_QUANT
								aEntrada[nEnt,07] -= SD3->D3_QUANT
							EndIf						
							nSaida    += SD3->D3_QUANT
							nSaiPriUM -= SD3->D3_QUANT
							nSaiSegUM -= SD3->D3_QTSEGUM
							nCSaida   += &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
							nSaidaVal -= &(Eval(bBloco,"SD3->D3_CUSTO",mv_par10))
						EndIf
					EndIf
					nRec3++
					dbSkip()
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le as saidas do dia                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD2")
				While !Eof() .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_EMISSAO <= dDataFim .And. SD2->D2_EMISSAO == dCntData;
					  .And. SD2->D2_COD == cProdAnt .And. If(lLocProc .Or. lCusUnif,.T.,SD2->D2_LOCAL == cLocalAnt)
					
					dbSelectArea("SF4")
					dbSeek(xFilial("SF4")+SD2->D2_TES)
					dbSelectArea("SD2")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SD2->D2_ORIGLAN == "LF" .Or. SF4->F4_ESTOQUE != "S"
						dbSkip()
						Loop
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza Notas Fiscais com Remito(Localizacao)                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(cPaisLoc $ "BRA|CHI")
						If ! Empty(SD2->D2_REMITO) .AND. !(SD2->D2_TPDCENV $ "1A")
							dbSkip()
							Loop
						EndIf
					EndIf
					If cPaisLoc == "CHI" .And.IsRemito(1,'SD2->D2_TIPODOC') .And. SD2->D2_QTDEFAT > 0
						dbSkip()
						Loop
					EndIf

					dbSelectArea("SF2")
					SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE))
					dbselectarea("SD2")					
					lDev:=MTR420Dev()
					If SD2->D2_TES <= "500" .Or. lDev
						If !lDev                   
							nEnt := Ascan(aEntrada,{|x|x[3]+x[4]+x[5]==SF2->F2_ROTEIRO+SF2->F2_PLACA+SD2->D2_CF } )
							If nEnt == 0
								aAdd( aEntrada, { SD2->D2_EMISSAO, SF2->F2_HORA, SF2->F2_ROTEIRO, SF2->F2_PLACA, SD2->D2_CF, SD2->D2_QUANT, SD2->D2_QUANT } )
							Else
								aEntrada[nEnt,06] += SD2->D2_QUANT
								aEntrada[nEnt,07] += SD2->D2_QUANT
							EndIf	
													
							nEntrada  += SD2->D2_QUANT
							nEntPriUM += SD2->D2_QUANT
							nEntSegUM += SD2->D2_QTSEGUM
							nCEntrada += &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
							nEntraVal += &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
						Else                                                 
							nEnt := Ascan(aEntrada,{|x|x[2]+x[4]+x[5] == SF2->F2_ROTEIRO+SF2->F2_PLACA+SD2->D2_CF } )
							If nEnt == 0
								aAdd( aEntrada, { SD2->D2_EMISSAO, SF2->F2_HORA, SF2->F2_ROTEIRO, SF2->F2_PLACA, SD2->D2_CF, -SD2->D2_QUANT, -SD2->D2_QUANT } )
							Else
								aEntrada[nEnt,06] -= SD2->D2_QUANT
								aEntrada[nEnt,07] -= SD2->D2_QUANT
							EndIf	
							nEntrada  -= SD2->D2_QUANT
							nEntPriUM -= SD2->D2_QUANT
							nEntSegUM -= SD2->D2_QTSEGUM
							nCEntrada -= &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
							nEntraVal -= &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
						EndIf
					Else                                                                                             
						nEnt := Ascan(aSaida,{|x|x[3]+x[4]+x[5] == SF2->F2_ROTEIRO+SF2->F2_PLACA+SD2->D2_CF } )
						If nEnt == 0
							aAdd( aSaida, { SD2->D2_EMISSAO, SF2->F2_HORA, SF2->F2_ROTEIRO, SF2->F2_PLACA, SD2->D2_CF, SD2->D2_QUANT, SD2->D2_QUANT } )
						Else
							aSaida[nEnt,06] += SD2->D2_QUANT
							aSaida[nEnt,07] += SD2->D2_QUANT
						EndIf	
						nSaida    += SD2->D2_QUANT
						nSaiPriUM -= SD2->D2_QUANT
						nSaiSegUM -= SD2->D2_QTSEGUM
						nCSaida   += &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
						nSaidaVal -= &(Eval(bBloco,"SD2->D2_CUSTO",mv_par10))
					EndIf
					nRec2++
					dbSkip()
				EndDo
				
				aSort(aEntrada,,, {|x,y| x[1] > y[1] })
				aSort(aSaida  ,,, {|x,y| x[1] > y[1] })
		        
				aFim := {}
				
				For n1 := 1 to Len(aEntrada)
					
					nEnt := Ascan(aFim,{|x|x[2]+x[3]== aEntrada[n1,02]+aEntrada[n1,03] } )
					If nEnt == 0
						aAdd(aFim,  { aEntrada[n1,01] ,aEntrada[n1,02],aEntrada[n1,03],aEntrada[n1,04],aEntrada[n1,05],aEntrada[n1,06],aEntrada[n1,07],;
									  Criavar('D2_EMISSAO',.f.),Criavar('F2_HORA',.f.),Criavar('F2_ROTEIRO',.f.),Criavar('F2_PLACA',.f.),Criavar('D2_CF',.f.),Criavar('D2_QUANT',.f.),Criavar('D2_QUANT',.f.)} )
					EndIf
					
				Next n1
				
				For n1 := 1 to Len(aSaida)
					
					nEnt := Ascan(aFim,{|x|x[2]== aSaida[n1,02] } )
					If nEnt == 0
						aAdd(aFim, { Criavar('D2_EMISSAO',.f.),Criavar('F2_HORA',.f.),Criavar('F2_ROTEIRO',.f.),Criavar('F2_PLACA',.f.),Criavar('D2_CF',.f.),Criavar('D2_QUANT',.f.),Criavar('D2_QUANT',.f.),;
									 aSaida[n1,01]     ,aSaida[n1,02],aSaida[n1,03],aSaida[n1,04],aSaida[n1,05],aSaida[n1,06], aSaida[n1,07]} )
					Else
						aFim[nEnt,07] := aSaida[n1,01]
						aFim[nEnt,08] := aSaida[n1,02]
						aFim[nEnt,09] := aSaida[n1,03]
						aFim[nEnt,10] := aSaida[n1,04]
						aFim[nEnt,11] := aSaida[n1,05]
						aFim[nEnt,12] := aSaida[n1,06]
						aFim[nEnt,13] := aSaida[n1,07]
					EndIf
					
				Next n1
	                
    			
				//If nEntPriUM != 0 .Or. nEntraVal != 0 .Or. nEntSegUM != 0 .Or.;
				//	nSaiPriUM != 0 .Or. nSaidaVal != 0 .Or. nSaiSegUM != 0
				aSort(aFim,,, {|x,y| x[2]+x[9]+x[5] < y[2]+y[9]+y[12] })
				nTotEnt		:= 0
				nTotSai		:= 0
				If Len(aFim) > 0
					
					For n1 := 1 to Len(aFim)
					
					
						If li > 60
							If mv_par12 == 1
								li	:=	cabec(titulo + " - " + aFilsCalc[ nForFilial, 3 ], cabec1, cabec2, wnrel, Tamanho, nTipo )
							Else
								li	:=	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
							EndIf
							Li++
						EndIf      

						If lFirst1
							MR420ImpCb(aSalAtu,@Li,cPicB2Qt)
							nSaldoLinha += aSalAtu[1]
							lFirst1 := .F.
						EndIf


						//aSalAtu[1] := aSalAtu[1] + nEntPriUM + nSaiPriUM
						//aSalAtu[mv_par10+1] := aSalAtu[mv_par10+1] + nEntraVal + nSaidaVal
						//aSalAtu[7] := aSalAtu[7] + nEntSegUM + nSaiSegUM
						
						nSaldoLinha += ( aFim[n1,06] - aFim[n1,13] )   
						nTotEnt		+= aFim[n1,06]
						nTotSai		+= aFim[n1,13]
						
						@ Li,000 PSay dCntData
						
			 			@ Li,012 PSay aFim[n1,02] 	//Iif(!Empty(aFim[n1,02]),aFim[n1,02],'X')
			 			@ Li,023 PSay aFim[n1,03]	//Iif(!Empty(aFim[n1,03]),aFim[n1,03],'X')
			 			@ Li,035 PSay aFim[n1,04]	//Iif(!Empty(aFim[n1,04]),aFim[n1,04],'X')
			 			@ Li,044 PSay aFim[n1,05]	//Iif(!Empty(aFim[n1,05]),aFim[n1,05],'X')
			 			@ Li,052 PSay aFim[n1,06] 	Picture '@E 99999.99'
			 			                                             	
			 			@ Li,061 PSay aFim[n1,09]
			 			@ Li,072 PSay aFim[n1,10]
			 			@ Li,083 PSay aFim[n1,11]
			 			@ Li,092 PSay aFim[n1,12]	
			 			@ Li,100 PSay aFim[n1,13]	Picture '@E 99999.99'

			 			@ Li,114 PSay nSaldoLinha	Picture '@E 999999999.99'
						
						Li++
					
					Next n1
					
				EndIf
				 
				dCntData++           
				
				//If dCntData > dDataFim
				//	Exit
				//Endif
				&& Total do Dia 
				If dCntData <= dDataFim
					If	(nRec1 > 0 .or. nRec2 > 0 .or. nRec3 > 0 .or. nRecCM > 0 .or. nRecCN > 0)
						Li++
						If li > 60
							If mv_par12 == 1
								li	:=	cabec(titulo + " - " + aFilsCalc[ nForFilial, 3 ], cabec1, cabec2, wnrel, Tamanho, nTipo )
							Else
								li	:=	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
							EndIf
							Li++
						EndIf
						If lFirst1
							MR420ImpCb(aSalAtu,@Li,cPicB2Qt)
							nSaldoLinha += aSalAtu[1]
							lFirst1 := .F.
						EndIf             
						                                                     
						@ li,000 PSay "TOTAL EM " + Dtoc(dCntData-1)
						
						@ Li,050 PSay nTotEnt		Picture '@E 9999999.99'
						@ Li,098 PSay nTotSai		Picture '@E 9999999.99'
						@ Li,114 PSay nSaldoLinha	Picture '@E 999999999.99'

						Li++
						@ Li,000 PSay __PrtThinLine()
						Li++
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve ou nao listar os produtos s/movimento ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par07 $ "Ss"
							If li > 58
								li	:=	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
								Li++
							EndIf
							MR420ImpCb(aSalAtu,@Li,cPicB2Qt)
							@Li ,  0 PSay "NAO HOUVE MOVIMENTACAO PARA ESTE PRODUTO"
							Li++
							@Li ,  0 PSay __PrtThinLine()
							Li++
						EndIf
					EndIf
				Else
					If	(nRec1 > 0 .or. nRec2 > 0 .or. nRec3 > 0 .or. nRecCM > 0 .or. nRecCN > 0)
						Li++
						If li > 60
							If mv_par12 == 1
								li	:=	cabec(titulo + " - " + aFilsCalc[ nForFilial, 3 ], cabec1, cabec2, wnrel, Tamanho, nTipo )
							Else
								li	:=	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
							EndIf
							Li++
						EndIf
						If lFirst1
							MR420ImpCb(aSalAtu,@Li,cPicB2Qt)
							lFirst1 := .F.
						EndIf
						@ li,000 PSay "TOTAL EM " + Dtoc(dCntData-1)
						
						@ Li,050 PSay nTotEnt		Picture '@E 9999999.99'
						@ Li,098 PSay nTotSai		Picture '@E 9999999.99'
						@ Li,114 PSay nSaldoLinha	Picture '@E 999999999.99'
						Li++
						@ Li,000 PSay __PrtThinLine()
						Li++
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve ou nao listar os produtos s/movimento ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par07 $ "Ss"
							If li > 58
								li	:=	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
								Li++
							EndIf
							MR420ImpCb(aSalAtu,@Li,cPicB2Qt)
							@Li ,  0 PSay STR0016		//"NAO HOUVE MOVIMENTACAO PARA ESTE PRODUTO"
							Li++
							@Li ,  0 PSay __PrtThinLine()
							Li++
						EndIf
					EndIf
					Exit
				EndIf
				*/
			EndDo
			
			dbSelectArea("SB1")
			dbSkip()
			
		EndDo
		
	
	EndIf
		
Next nForFilial

If li != 80
	Roda(cbcont,cbtxt,Tamanho)
EndIf

cFilAnt := cFilBack

dbSelectArea("SB1")
dbClearFilter()
If !Empty(cArq1) .And. File(cArq1 + OrdBagExt())
	RetIndex('SB1')
	FERASE(cArq1 + OrdBagExt())
EndIf

dbSetOrder(1)
dbSelectArea("SB2")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)
dbSelectArea("SD3")
If lLocProc .Or. lCusUnif
	dbClearFilter()
	RetIndex("SD3")
	If File(cTrbSD3+OrdBagExt())
		Ferase(cTrbSD3+OrdBagExt())
	EndIf
EndIf
dbSetOrder(1) 

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR420ImpCb³ Autor ³ Eveli Morasco         ³ Data ³ 28/11/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do item                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MR420ImpCb(ExpA1,ExpN1,@ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com informacoes do saldo inicial do item     ³±±
±±³          ³   [1] = Saldo inicial em quantidade                        ³±±
±±³          ³   [2] = Saldo inicial em valor                             ³±±
±±³          ³   [3] = Saldo inicial na 2a unidade de medida              ³±±
±±³          ³ ExpN1 = Numero da linha corrente de impressao              ³±±
±±³          ³ ExpN2 = Picture Do Campo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MR420ImpCb(aSalAtu,Li,cPicB2Qt)

If ! lVeic
	@ Li,000 PSay STR0017+SB1->B1_COD			//"Cod: "
	@ Li,022 PSay SubStr(SB1->B1_DESC,1,25)
	@ Li,050 PSay STR0018+SB1->B1_UM			//"UM: "
	@ Li,058 PSay STR0019+SB1->B1_TIPO			//"TIPO: "
	@ Li,068 PSay STR0020+SB1->B1_GRUPO			//"GRUPO: "
	@ Li,114 PSay aSalAtu[1] Picture cPicB2Qt
	//@ Li,096 PSay aSalAtu[1] Picture cPicB2Qt
	//@ Li,114 PSay aSalAtu[mv_par10+1] Picture cPicD1Cust
	Li += 2
Else
	@ Li,000 PSay STR0017 + '[ ' + SB1->B1_CODITE + ' ] [ ' + SB1->B1_COD + ' ]'			//"Cod: "
	@ Li,PCOL() PSay ' [ ' + SB1->B1_DESC + ' ]'
	@ Li,096 PSay aSalAtu[1] Picture cPicB2Qt
	@ Li,114 PSay aSalAtu[mv_par10+1] Picture cPicD1Cust
	Li ++
	@ Li,000 PSay STR0018 + '[ ' + SB1->B1_UM + ' ]'			//"UM: "
	@ Li,PCOL() + 5 PSay STR0019 + '[ ' + SB1->B1_TIPO + ' ]'		//"TIPO: "
	@ Li,PCOL() + 5 PSay STR0020 + '[ ' +SB1->B1_GRUPO + ' ]'		//"GRUPO: "
	Li ++
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTR420Dev³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 25.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Avalia se item pertence a uma nota de devolu‡ao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTR420Dev()
Local cAlias:=Alias(),lRet:=.F.

If cAlias == "SD1"
	dbSelectArea("SF1")
	dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
	If SF1->F1_TIPO == "D" .And. IIf(cPaisLoc <> "BRA",SF1->F1_ESPECIE <> "NCC",.T.)
		lRet:=.T.
	EndIf
ElseIf cAlias == "SD2"
	dbSelectArea("SF2")
	dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
	If SF2->F2_TIPO == "D"
		lRet:=.T.
	EndIf
EndIf
dbSelectArea(cAlias)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR420CUST ³ Autor ³Rodrigo de A. Sartorio ³ Data ³26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta grupo de perguntas p/ Custo Unificado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MTR420Cunf(ExpL1)					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Custo Unificado								 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTR420CUST(lCusUnif)
Local aSvAlias:=GetArea()
Local nTamSX1 :=Len(SX1->X1_GRUPO)
dbSelectArea("SX1")
If dbSeek(PADR("MTR420",nTamSX1)+"08",.F.)
	If !("MTR420VAXX" $ X1_VALID)
		RecLock("SX1",.F.)
		If Empty(X1_VALID)
			Replace X1_VALID With "MTR420VAXX"
		Else
			Replace X1_VALID With X1_VALID+".And.MTR420VAXX"
		EndIf
		MsUnlock()
	EndIf
	If lCusUnif .And. X1_CNT01 != "**"
		RecLock("SX1",.F.)
		Replace X1_CNT01 With "**"
		MsUnlock()
	EndIf
EndIf
RestArea(aSvAlias)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR420VAXX ³ Autor ³Rodrigo de A. Sartorio ³ Data ³26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Almoxarifado do KARDEX com relacao a custo unificado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTR420VAXX()
Local lRet:=.T.
Local cConteudo:=&(ReadVar())
Local nOpc:=2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por Empresa/Filial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),GetMV("MV_CUSFIL",.F.))
If lCusUnif .And. cConteudo != "**"
	nOpc := Aviso(STR0033,STR0034,{STR0035,STR0036})	//"Aten‡„o"###"Ao alterar o almoxarifado o custo medio unificado sera desconsiderado."###"Confirma"###"Abandona"
	If nOpc == 2
		lRet:=.F.
	EndIf
EndIf
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Nereu Humberto Junior ³ Data ³04/10/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera descricao da pergunta no SX1                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aHelpPor :={} 
Local aHelpEng :={} 
Local aHelpSpa :={} 

/*-----------------------MV_PAR11--------------------------*/
Aadd( aHelpPor, "Imprime descricao do Armazem. Sim ou Nao" )

Aadd( aHelpEng, "Print warehouse description. Yes or No  " )

Aadd( aHelpSpa, "Imprime descripcion del almacen. Si o No" )

PutSx1( "MTR420","11","Imprime descricao do Armazem ?","Imprime descripc. del almacen?","Print warehouse description ?","mv_chb",;
"N",1,0,2,"C","","","","","mv_par11","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

Aadd( aHelpPor, { 'Seleciona as filiais desejadas. Se NAO',;
                  'apenas a filial corrente sera afetada.',;
                  '' } )
Aadd( aHelpSpa, { 'Selecciona las sucursales deseadas. Si',;
                  'NO solamente la sucursal actual es',;
                  'afectado.' } ) 
Aadd( aHelpEng, { 'Select desired branch offices. If NO',;
                  'only current branch office will be',;
                  'affected.' } )
PutSx1('MTR420',               ; //-- 01 - X1_GRUPO
    '12',                      ; //-- 02 - X1_ORDEM
    'Seleciona Filiais?',      ; //-- 03 - X1_PERGUNT
    '¿Selecciona Sucursales?', ; //-- 04 - X1_PERSPA
    'Select branch offices?',  ; //-- 05 - X1_PERENG
    'mv_chc',                  ; //-- 06 - X1_VARIAVL
    'C',                       ; //-- 07 - X1_TIPO
    1,                         ; //-- 08 - X1_TAMANHO
    0,                         ; //-- 09 - X1_DECIMAL
    2,                         ; //-- 10 - X1_PRESEL
    'C',                       ; //-- 11 - X1_GSC
    '',                        ; //-- 12 - X1_VALID
    '',                        ; //-- 13 - X1_F3
    '',                        ; //-- 14 - X1_GRPSXG
    '',                        ; //-- 15 - X1_PYME
    'mv_par12',                ; //-- 16 - X1_VAR01
    'Sim',                     ; //-- 17 - X1_DEF01
    'Si',                      ; //-- 18 - X1_DEFSPA1
    'Yes',                     ; //-- 19 - X1_DEFENG1
    '',                        ; //-- 20 - X1_CNT01
    'Nao',                     ; //-- 21 - X1_DEF02
    'No',                      ; //-- 22 - X1_DEFSPA2
    'No',                      ; //-- 23 - X1_DEFENG2
    '',                        ; //-- 24 - X1_DEF03
    '',                        ; //-- 25 - X1_DEFSPA3
    '',                        ; //-- 26 - X1_DEFENG3
    '',                        ; //-- 27 - X1_DEF04
    '',                        ; //-- 28 - X1_DEFSPA4
    '',                        ; //-- 29 - X1_DEFENG4
    '',                        ; //-- 30 - X1_DEF05
    '',                        ; //-- 31 - X1_DEFSPA5
    '',                        ; //-- 32 - X1_DEFENG5
    aHelpPor,                  ; //-- 33 - HelpPor
    aHelpSpa,                  ; //-- 34 - HelpSpa
    aHelpEng,                  ; //-- 35 - HelpEng
     '')                        //-- 36 - X1_HELP

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR420IsMN³ Autor ³ Lucas                 ³ Data ³ 03.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se há integração com o modulo SigaMNT/NG          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTR420IsMNT()
Local aArea
Local aAreaSB1
Local cProdMNT	 := GetMv("MV_PRODMNT")
Local lIntegrMNT := .F.

cProdMNT := cProdMNT + Space(15-Len(cProdMNT))

If !Empty(cProdMNT)
	aArea	 := GetArea()
	aAreaSB1 := SB1->(GetArea())
	SB1->(dbSelectArea( "SB1" ))
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek( xFilial('SB1') + cProdMNT ))
		lIntegrMNT := .T.
	EndIf 
	RestArea(aAreaSB1)
	RestArea(aArea)
EndIf 
Return( lIntegrMNT )